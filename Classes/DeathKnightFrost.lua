-- DeathKnightFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [x] Accelerated Cold
-- [x] Biting Cold
-- [x] Eradicating Blow
-- [x] Unleashed Frenzy


if UnitClassBase( "player" ) == "DEATHKNIGHT" then
    local spec = Hekili:NewSpecialization( 251 )

    spec:RegisterResource( Enum.PowerType.Runes, {
        rune_regen = {
            last = function ()
                return state.query_time
            end,

            interval = function( time, val )
                local r = state.runes

                if val == 6 then return -1 end
                return r.expiry[ val + 1 ] - time
            end,

            stop = function( x )
                return x == 6
            end,

            value = 1
        },

        empower_rune = {
            aura = "empower_rune_weapon",

            last = function ()
                return state.buff.empower_rune_weapon.applied + floor( state.query_time - state.buff.empower_rune_weapon.applied )
            end,

            stop = function ( x )
                return x == 6
            end,

            interval = 5,
            value = 1
        },
    }, setmetatable( {
        expiry = { 0, 0, 0, 0, 0, 0 },
        cooldown = 10,
        regen = 0,
        max = 6,
        forecast = {},
        fcount = 0,
        times = {},
        values = {},
        resource = "runes",

        reset = function()
            local t = state.runes

            for i = 1, 6 do
                local start, duration, ready = GetRuneCooldown( i )

                start = start or 0
                duration = duration or ( 10 * state.haste )

                t.expiry[ i ] = ready and 0 or start + duration
                t.cooldown = duration
            end

            table.sort( t.expiry )

            t.actual = nil
        end,

        gain = function( amount )
            local t = state.runes

            for i = 1, amount do
                t.expiry[ 7 - i ] = 0
            end
            table.sort( t.expiry )

            t.actual = nil
        end,

        spend = function( amount )
            local t = state.runes

            for i = 1, amount do
                t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
                table.sort( t.expiry )
            end

            state.gain( amount * 10, "runic_power" )

            if state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
                state.buff.remorseless_winter.expires = state.buff.remorseless_winter.expires + ( 0.5 * amount )
            end

            t.actual = nil
        end,

        timeTo = function( x )
            return state:TimeToResource( state.runes, x )
        end,
    }, {
        __index = function( t, k, v )
            if k == "actual" then
                local amount = 0

                for i = 1, 6 do
                    if t.expiry[ i ] <= state.query_time then
                        amount = amount + 1
                    end
                end

                return amount

            elseif k == "current" then
                -- If this is a modeled resource, use our lookup system.
                if t.forecast and t.fcount > 0 then
                    local q = state.query_time
                    local index, slice

                    if t.values[ q ] then return t.values[ q ] end

                    for i = 1, t.fcount do
                        local v = t.forecast[ i ]
                        if v.t <= q then
                            index = i
                            slice = v
                        else
                            break
                        end
                    end

                    -- We have a slice.
                    if index and slice then
                        t.values[ q ] = max( 0, min( t.max, slice.v ) )
                        return t.values[ q ]
                    end
                end

                return t.actual

            elseif k == "deficit" then
                return t.max - t.current

            elseif k == "time_to_next" then
                return t[ "time_to_" .. t.current + 1 ]

            elseif k == "time_to_max" then
                return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

            elseif k == "add" then
                return t.gain

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower, {
        breath = {
            talent = "breath_of_sindragosa",
            aura = "breath_of_sindragosa",

            last = function ()
                return state.buff.breath_of_sindragosa.applied + floor( state.query_time - state.buff.breath_of_sindragosa.applied )
            end,

            stop = function ( x ) return x < 16 end,

            interval = 1,
            value = -16
        },

        empower_rp = {
            aura = "empower_rune_weapon",

            last = function ()
                return state.buff.empower_rune_weapon.applied + floor( state.query_time - state.buff.empower_rune_weapon.applied )
            end,

            interval = 5,
            value = 5
        },

        swarming_mist = {
            aura = "swarming_mist",

            last = function ()
                return state.buff.swarming_mist.applied + floor( state.query_time - state.buff.swarming_mist.applied )
            end,

            interval = 1,
            value = function () return min( 15, state.true_active_enemies * 3 ) end,
        },
    } )


    local virtual_rp_spent_since_pof = 0

    local spendHook = function( amt, resource, noHook )
        if amt > 0 and resource == "runic_power" and buff.breath_of_sindragosa.up and runic_power.current < 16 then
            removeBuff( "breath_of_sindragosa" )
        end

        if amt > 0 and resource == "runes" and active_dot.shackle_the_unworthy > 0 then
            reduceCooldown( "shackle_the_unworthy", 4 * amt )
        end
    end

    spec:RegisterHook( "spend", spendHook )


    -- Talents
    spec:RegisterTalents( {
        inexorable_assault = 22016, -- 253593
        icy_talons = 22017, -- 194878
        cold_heart = 22018, -- 281208

        runic_attenuation = 22019, -- 207104
        murderous_efficiency = 22020, -- 207061
        horn_of_winter = 22021, -- 57330

        deaths_reach = 22515, -- 276079
        asphyxiate = 22517, -- 108194
        blinding_sleet = 22519, -- 207167

        avalanche = 22521, -- 207142
        frozen_pulse = 22523, -- 194909
        frostscythe = 22525, -- 207230

        permafrost = 22527, -- 207200
        wraith_walk = 22530, -- 212552
        death_pact = 23373, -- 48743

        gathering_storm = 22531, -- 194912
        hypothermic_presence = 22533, -- 321995
        glacial_advance = 22535, -- 194913

        icecap = 22023, -- 207126
        obliteration = 22109, -- 281238
        breath_of_sindragosa = 22537, -- 152279
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        bitter_chill = 5435, -- 356470
        chill_streak = 706, -- 305392
        dark_simulacrum = 3512, -- 77606
        dead_of_winter = 3743, -- 287250
        deathchill = 701, -- 204080
        deaths_echo = 5427, -- 356367
        delirium = 702, -- 233396
        dome_of_ancient_shadow = 5369, -- 328718
        shroud_of_winter = 3439, -- 199719
        spellwarden = 5424, -- 356332
        strangulate = 5429, -- 47476
    } )


    -- Auras
    spec:RegisterAuras( {
        antimagic_shell = {
            id = 48707,
            duration = function () return ( legendary.deaths_embrace.enabled and 2 or 1 ) * 5 + ( conduit.reinforced_shell.mod * 0.001 ) end,
            max_stack = 1,
        },
        antimagic_zone = {
            id = 145629,
            duration = 8,
            max_stack = 1,
        },
        asphyxiate = {
            id = 108194,
            duration = 4,
            max_stack = 1,
        },
        blinding_sleet = {
            id = 207167,
            duration = 5,
            max_stack = 1,
        },
        breath_of_sindragosa = {
            id = 152279,
            duration = 3600,
            max_stack = 1,
            dot = "buff"
        },
        chains_of_ice = {
            id = 45524,
            duration = 8,
            max_stack = 1,
        },
        cold_heart_item = {
            id = 235599,
            duration = 3600,
            max_stack = 20
        },
        cold_heart_talent = {
            id = 281209,
            duration = 3600,
            max_stack = 20,
        },
        cold_heart = {
            alias = { "cold_heart_item", "cold_heart_talent" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600,
            max_stack = 20,
        },
        dark_command = {
            id = 56222,
            duration = 3,
            max_stack = 1,
        },
        dark_succor = {
            id = 101568,
            duration = 20,
        },
        death_and_decay = {
            id = 43265,
            duration = 10,
            max_stack = 1,
        },
        death_pact = {
            id = 48743,
            duration = 15,
            max_stack = 1,
        },
        deaths_advance = {
            id = 48265,
            duration = 10,
            max_stack = 1,
        },
        empower_rune_weapon = {
            id = 47568,
            duration = 20,
            max_stack = 1,
        },
        frost_breath = {
            id = 279303,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        frost_fever = {
            id = 55095,
            duration = 30,
            type = "Disease",
            max_stack = 1,
        },
        frost_shield = {
            id = 207203,
            duration = 10,
            max_stack = 1,
        },
        frostwyrms_fury = {
            id = 279303,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        frozen_pulse = {
            -- pseudo aura for talent.
            name = "Frozen Pulse",
            meta = {
                up = function () return runes.current < 3 end,
                down = function () return runes.current >= 3 end,
                stack = function () return runes.current < 3 and 1 or 0 end,
                duration = 15,
                remains = function () return runes.time_to_3 end,
                applied = function () return runes.current < 3 and query_time or 0 end,
                expires = function () return runes.current < 3 and ( runes.time_to_3 + query_time ) or 0 end,
            }
        },
        gathering_storm = {
            id = 211805,
            duration = 3600,
            max_stack = 9,
        },
        hypothermic_presence = {
            id = 321995,
            duration = 8,
            max_stack = 1,
        },
        icebound_fortitude = {
            id = 48792,
            duration = 8,
            max_stack = 1,
        },
        icy_talons = {
            id = 194879,
            duration = 6,
            max_stack = 3,
        },
        inexorable_assault = {
            id = 253595,
            duration = 3600,
            max_stack = 5,
        },
        killing_machine = {
            id = 51124,
            duration = 10,
            max_stack = 1,
        },
        lichborne = {
            id = 49039,
            duration = 10,
            max_stack = 1,
        },
        obliteration = {
            id = 281238,
        },
        on_a_pale_horse = {
            id = 51986,
        },
        path_of_frost = {
            id = 3714,
            duration = 600,
            max_stack = 1,
        },
        pillar_of_frost = {
            id = 51271,
            duration = 12,
            max_stack = 1,
        },
        razorice = {
            id = 51714,
            duration = 26,
            max_stack = 5,
        },
        remorseless_winter = {
            id = 196770,
            duration = 8,
            max_stack = 1,
        },
        rime = {
            id = 59052,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        runic_empowerment = {
            id = 81229,
        },
        unholy_strength = {
            id = 53365,
            duration = 15,
            max_stack = 1,
        },
        wraith_walk = {
            id = 212552,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },


        -- PvP Talents
        -- Chill Streak
        chilled = {
            id = 204206,
            duration = 4,
            max_stack = 1
        },

        dead_of_winter = {
            id = 289959,
            duration = 4,
            max_stack = 5,
        },

        deathchill = {
            id = 204085,
            duration = 4,
            max_stack = 1
        },

        delirium = {
            id = 233396,
            duration = 15,
            max_stack = 1,
        },

        shroud_of_winter = {
            id = 199719,
            duration = 3600,
            max_stack = 1,
        },

        lichborne = {
            id = 287081,
            duration = 10,
            max_stack = 1,
        },


        -- Azerite Powers
        cold_hearted = {
            id = 288426,
            duration = 8,
            max_stack = 1
        },

        frostwhelps_indignation = {
            id = 287338,
            duration = 6,
            max_stack = 1,
        },
    } )


    spec:RegisterGear( "acherus_drapes", 132376 )
    spec:RegisterGear( "aggramars_stride", 132443 )
    spec:RegisterGear( "cold_heart", 151796 ) -- chilled_heart stacks NYI
        spec:RegisterAura( "cold_heart_item", {
            id = 235599,
            duration = 3600,
            max_stack = 20
        } )
    spec:RegisterGear( "consorts_cold_core", 144293 )
    spec:RegisterGear( "kiljaedens_burning_wish", 144259 )
    spec:RegisterGear( "koltiras_newfound_will", 132366 )
    spec:RegisterGear( "perseverance_of_the_ebon_martyr", 132459 )
    spec:RegisterGear( "rethus_incessant_courage", 146667 )
    spec:RegisterGear( "seal_of_necrofantasia", 137223 )
    spec:RegisterGear( "shackles_of_bryndaor", 132365 ) -- NYI
    spec:RegisterGear( "soul_of_the_deathlord", 151640 )
    spec:RegisterGear( "toravons_whiteout_bindings", 132458 )


    spec:RegisterTotem( "ghoul", 1100170 )


    local any_dnd_set = false

    spec:RegisterHook( "reset_precast", function ()
        if state:IsKnown( "deaths_due" ) then
            class.abilities.any_dnd = class.abilities.deaths_due
            cooldown.any_dnd = cooldown.deaths_due
            setCooldown( "death_and_decay", cooldown.deaths_due.remains )
        elseif state:IsKnown( "defile" ) then
            class.abilities.any_dnd = class.abilities.defile
            cooldown.any_dnd = cooldown.defile
            setCooldown( "death_and_decay", cooldown.defile.remains )
        else
            class.abilities.any_dnd = class.abilities.death_and_decay
            cooldown.any_dnd = cooldown.death_and_decay
        end

        if not any_dnd_set then
            class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any]|r " .. class.abilities.death_and_decay.name
            any_dnd_set = true
        end

        local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up then
            summonPet( "controlled_undead", control_expires - now )
        end

        -- Reset CDs on any Rune abilities that do not have an actual cooldown.
        for action in pairs( class.abilityList ) do
            local data = class.abilities[ action ]
            if data.cooldown == 0 and data.spendType == "runes" then
                setCooldown( action, 0 )
            end
        end
    end )


    -- Abilities
    spec:RegisterAbilities( {
        antimagic_shell = {
            id = 48707,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136120,

            handler = function ()
                applyBuff( "antimagic_shell" )
            end,
        },


        antimagic_zone = {
            id = 51052,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 237510,

            handler = function ()
                applyBuff( "antimagic_zone" )
            end,
        },


        asphyxiate = {
            id = 108194,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 538558,

            toggle = "interrupts",

            talent = "asphyxiate",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                applyDebuff( "target", "asphyxiate" )
                interrupt()
            end,
        },


        blinding_sleet = {
            id = 207167,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 135836,

            talent = "blinding_sleet",

            handler = function ()
                applyDebuff( "target", "blinding_sleet" )
                active_dot.blinding_sleet = max( active_dot.blinding_sleet, active_enemies )
            end,
        },


        breath_of_sindragosa = {
            id = 152279,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 16,
            readySpend = function () return settings.bos_rp end,
            spendType = "runic_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1029007,

            handler = function ()
                gain( 2, "runes" )
                applyBuff( "breath_of_sindragosa" )
            end,
        },


        chains_of_ice = {
            id = 45524,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 135834,

            handler = function ()
                applyDebuff( "target", "chains_of_ice" )
                removeBuff( "cold_heart_item" )
                removeBuff( "cold_heart_talent" )
            end,
        },


        chill_streak = {
            id = 305392,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "chill_streak"
            end,

            handler = function ()
                applyDebuff( "target", "chilled" )
            end,
        },


        control_undead = {
            id = 111673,
            cast = 1.5,
            hasteCD = true,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = false,
            texture = 237273,

            usable = function () return target.is_undead and target.level <= level + 1, "requires undead target up to 1 level above player" end,
            handler = function ()
                summonPet( "controlled_undead", 300 )
            end,
        },


        dark_command = {
            id = 56222,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 136088,

            handler = function ()
                applyDebuff( "target", "dark_command" )
            end,
        },


        dark_simulacrum = {
            id = 77606,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 135888,

            pvptalent = "dark_simulacrum",

            usable = function ()
                if not target.is_player then return false, "target is not a player" end
                return true
            end,
            handler = function ()
                applyDebuff( "target", "dark_simulacrum" )
            end,
        },


        death_and_decay = {
            id = 43265,
            noOverride = 324128,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 136144,

            handler = function ()
                applyBuff( "death_and_decay" )
            end,
        },


        death_coil = {
            id = 47541,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.hypothermic_presence.up and 0.65 or 1 ) * 40 end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 136145,

            handler = function ()
            end,
        },


        --[[ death_gate = {
            id = 50977,
            cast = 4,
            hasteCD = true,
            cooldown = 60,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = false,
            texture = 135766,

            handler = function ()
            end,
        }, ]]


        death_grip = {
            id = 49576,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 237532,

            handler = function ()
                applyDebuff( "target", "death_grip" )
                setDistance( 5 )
                if conduit.unending_grip.enabled then applyDebuff( "target", "unending_grip" ) end
            end,
        },


        death_pact = {
            id = 48743,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136146,

            talent = "death_pact",

            handler = function ()
                gain( health.max * 0.5, "health" )
                applyDebuff( "player", "death_pact" )
            end,
        },


        death_strike = {
            id = 49998,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.dark_succor.up then return 0 end
                return 35 * ( buff.hypothermic_presence.up and 0.65 or 1 )
            end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237517,

            handler = function ()
                gain( health.max * 0.10, "health" )
            end,
        },


        deaths_advance = {
            id = 48265,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 237561,

            handler = function ()
                applyBuff( "deaths_advance" )
                if conduit.fleeting_wind.enabled then applyBuff( "fleeting_wind" ) end
            end,
        },


        empower_rune_weapon = {
            id = 47568,
            cast = 0,
            charges = 1,
            cooldown = function () return ( conduit.accelerated_cold.enabled and 0.9 or 1 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 55 and 105 or 120 ) end,
            recharge = function () return ( conduit.accelerated_cold.enabled and 0.9 or 1 ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 55 and 105 or 120 ) end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135372,

            nobuff = "empower_rune_weapon",

            handler = function ()
                stat.haste = state.haste + 0.15 + ( conduit.accelerated_cold.mod * 0.01 )
                gain( 1, "runes" )
                gain( 5, "runic_power" )
                applyBuff( "empower_rune_weapon" )
            end,

            copy = "empowered_rune_weapon" -- typo often in SimC APL.
        },


        frost_strike = {
            id = 49143,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.hypothermic_presence.up and 0.65 or 1 ) * 25 end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237520,

            cycle = function ()
                if death_knight.runeforge.razorice then return "razorice" end
            end,

            handler = function ()
                applyDebuff( "target", "razorice", 20, 2 )
                if talent.obliteration.enabled and buff.pillar_of_frost.up then applyBuff( "killing_machine" ) end
                removeBuff( "eradicating_blow" )
                if conduit.unleashed_frenzy.enabled then addStack( "eradicating_frenzy", nil, 1 ) end
                if pvptalent.bitter_chill.enabled and debuff.chains_of_ice.up then
                    applyDebuff( "target", "chains_of_ice" )
                end
            end,

            auras = {
                unleashed_frenzy = {
                    id = 338501,
                    duration = 6,
                    max_stack = 5,
                }
            }
        },


        frostscythe = {
            id = 207230,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 1060569,

            talent = "frostscythe",

            range = 7,

            handler = function ()
                removeBuff( "killing_machine" )
                removeStack( "inexorable_assault" )
            end,
        },


        frostwyrms_fury = {
            id = 279302,
            cast = 0,
            cooldown = function () return legendary.absolute_zero.enabled and 90 or 180 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 341980,

            handler = function ()
                applyDebuff( "target", "frost_breath" )

                if legendary.absolute_zero.enabled then applyDebuff( "target", "absolute_zero" ) end
            end,

            auras = {
                -- Legendary.
                absolute_zero = {
                    id = 334693,
                    duration = 3,
                    max_stack = 1,
                }
            }
        },


        glacial_advance = {
            id = 194913,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",

            spend = function () return ( buff.hypothermic_presence.up and 0.65 or 1 ) * 30 end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 537514,

            handler = function ()
                applyDebuff( "target", "razorice", nil, 1 )
            end,
        },


        horn_of_winter = {
            id = 57330,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 134228,

            talent = "horn_of_winter",

            handler = function ()
                gain( 2, "runes" )
                gain( 25, "runic_power" )
            end,
        },


        howling_blast = {
            id = 49184,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.rime.up and 0 or 1 end,
            spendType = "runes",

            startsCombat = true,
            texture = 135833,

            handler = function ()
                applyDebuff( "target", "frost_fever" )
                active_dot.frost_fever = max( active_dot.frost_fever, active_enemies )

                if talent.obliteration.enabled and buff.pillar_of_frost.up then applyBuff( "killing_machine" ) end
                if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end

                if legendary.rage_of_the_frozen_champion.enabled and buff.rime.up then
                    gain( 8, "runic_power" )
                end

                removeBuff( "rime" )
            end,
        },


        hypothermic_presence = {
            id = 321995,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 236224,

            handler = function ()
                applyBuff( "hypothermic_presence" )
            end,
        },


        icebound_fortitude = {
            id = 48792,
            cast = 0,
            cooldown = function () return 180 - ( azerite.cold_hearted.enabled and 15 or 0 ) + ( conduit.chilled_resilience.mod * 0.001 ) end,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 237525,

            handler = function ()
                applyBuff( "icebound_fortitude" )
            end,
        },


        lichborne = {
            id = 49039,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 136187,

            toggle = "defensives",

            handler = function ()
                applyBuff( "lichborne" )
                if conduit.hardened_bones.enabled then applyBuff( "hardened_bones" ) end
            end,
        },


        mind_freeze = {
            id = 47528,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 237527,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                if conduit.spirit_drain.enabled then gain( conduit.spirit_drain.mod * 0.1, "runic_power" ) end
                interrupt()
            end,
        },


        obliterate = {
            id = 49020,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 2,
            spendType = "runes",

            startsCombat = true,
            texture = 135771,

            cycle = function ()
                if death_knight.runeforge.razorice then return "razorice" end
            end,

            handler = function ()
                removeStack( "inexorable_assault" )
                -- Koltira's Favor is not predictable.
                if conduit.eradicating_blow.enabled then addStack( "eradicating_blow", nil, 1 ) end
            end,

            auras = {
                -- Conduit
                eradicating_blow = {
                    id = 337936,
                    duration = 10,
                    max_stack = 2
                }
            }
        },


        path_of_frost = {
            id = 3714,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = false,
            texture = 237528,

            handler = function ()
                applyBuff( "path_of_frost" )
            end,
        },


        pillar_of_frost = {
            id = 51271,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            startsCombat = false,
            texture = 458718,

            handler = function ()
                applyBuff( "pillar_of_frost" )
                if azerite.frostwhelps_indignation.enabled then applyBuff( "frostwhelps_indignation" ) end
                virtual_rp_spent_since_pof = 0
            end,
        },


        --[[ raise_ally = {
            id = 61999,
            cast = 0,
            cooldown = 600,
            gcd = "spell",

            spend = 30,
            spendType = "runic_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136143,

            handler = function ()
            end,
        }, ]]


        raise_dead = {
            id = 46585,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1100170,

            usable = function () return not pet.alive, "cannot have an active pet" end,

            handler = function ()
                summonPet( "ghoul" )
            end,
        },


        remorseless_winter = {
            id = 196770,
            cast = 0,
            cooldown = function () return pvptalent.dead_of_winter.enabled and 45 or 20 end,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = false,
            texture = 538770,

            range = 7,

            handler = function ()
                applyBuff( "remorseless_winter" )

                if active_enemies > 2 and legendary.biting_cold.enabled then
                    applyBuff( "rime" )
                end

                if conduit.biting_cold.enabled then applyDebuff( "target", "biting_cold" ) end
                -- if pvptalent.deathchill.enabled then applyDebuff( "target", "deathchill" ) end
            end,

            auras = {
                -- Conduit
                biting_cold = {
                    id = 337989,
                    duration = 8,
                    max_stack = 10
                }
            }
        },


        sacrificial_pact = {
            id = 327574,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = 20,
            spendType = "runic_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136133,

            usable = function () return pet.alive, "requires an undead pet" end,

            handler = function ()
                dismissPet( "ghoul" )
                gain( 0.25 * health.max, "health" )
            end,
        },


        wraith_walk = {
            id = 212552,
            cast = 4,
            channeled = true,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            texture = 1100041,

            start = function ()
                applyBuff( "wraith_walk" )
            end,
        },


    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 8,

        potion = "potion_of_spectral_strength",

        package = "Frost DK",
    } )


    spec:RegisterSetting( "bos_rp", 50, {
        name = "Runic Power for |T1029007:0|t Breath of Sindragosa",
        desc = "The addon will recommend |T1029007:0|t Breath of Sindragosa only if you have this much Runic Power (or more).",
        icon = 1029007,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 16,
        max = 100,
        step = 1,
        width = 1.5
    } )


    spec:RegisterPack( "Frost DK", 20210403, [[d40rCcqiaYJacDjesQnrP6tkQgfIQtHOSkes8kffZIe5wabv7cv)cGAyKahtQQLrj1ZOuyAieUgcLTbe4BKGY4ibX5qijRJsrZdHQ7HG9rI6GiezHkk9qPcMijiLlIquTrPIKpscsgjqqXjriLvcGxceuAMsf1oPK8tGGmuPIulfHu9usAQukDvsqQ6RieLXceTxb)vObd6WuTyu8ysnzfUm0MLYNvKrduNw0QjbPYRbsZgPBJi7wYVvz4a64KGQLRQNtX0jUokTDPkFxQ04Lk05jHwVurmFkX(v6q)GTb1HlyWkRvG19varOaBW73VpXSbiiOkkcedQaDnO(egulNegu7u)zKfQqde2Gkqxr65JGTbvZX(AmOcweGgBcyapLcywgU(ibytsIL6sEL(9Maytssd4GkdBsfIwfycQdxWGvwRaR7RaIqb2G3VFFIzdIiO6Sc47dQQjPoeubNJbwbMG6an6GQcn0fWlee2kNallSt9Nrwaisa)KUqRvAHwRaR7VaSa0bWEnHMfaq4lKOJKUE4yHu3iGWnO(QXczn(eUWRTWoa2ZYSWRTqIMgxOBwyklCCOPMllei1vCHDrkDHzTqGVRLuJ8GknnIjyBq9yOPGVl5vrG3rZAkyBWQ(bBdQy5muCeMnO6AjVkO(iP7nifnMy3Se8dQd0O)eOKxfu703rZAAHDQ7xiiednf8DjVYMluv8xmlSVcwOb1xnmlKbB3JlStNuQ)l8AlSt9NrwO(iHMfET2c7GcTGQ(tb)0dQItXs4tUag)SMIg5EsCSCgkowOflluF1Gnfo2d)2FgHJLZqXXcTyzHpBHT7Nqotkznf1hDWXYzO4yHwSSqxlzpmIfskrZcvMWcToibRSoyBqflNHIJWSbv9Nc(PhuzyBn(NKqolWGQRL8QGk4RlnRPid1nsqcwzJGTbvSCgkocZguDTKxfupgAk47cgu1Fk4NEqLHT14GMuAwtrsUgCwi)rxlbvTIAkgf)NqXeSQFqcwrebBdQy5muCeMnOQ)uWp9GQbisPrX)jum8jQRtNg9rpV04cvMWcTEH2x4ZwPoc86IpFGTuNYcj(cbbkiO6AjVkOorDD60Op65LgdsWkIfSnOILZqXry2GQRL8QGA7pJenYNGIbv9Nc(PhuF2k1rGxx85dSL6uwiXxOctbbvTIAkgf)NqXeSQFqcwbcc2guXYzO4imBq11sEvq9yOPGVlyqv)PGF6b1NTWfQ8cjIGQwrnfJI)tOycw1pibRuybBdQy5muCeMnOQ)uWp9GQRLShgXcjLOzHktyHeXcTVqYxiGw4aDbC0RrCGAxrUKAqZAAH2xO(6HLxcVYjWsS54cTyzHaAH6RhwEj8kNalXMJlKSGQRL8QGA7pJy0kkGXGeKGQ(OJiy0FjyBWQ(bBdQy5muCeMnO6AjVkOQb7zzIxlMAmOoqJ(tGsEvqvHEdUWb7N10c70jL6)c7Mc4fs00O2bc4zF0fWbv9Nc(Phub0cfNILWpgAk47sEfhlNHIJfAFHmSTghysP(hVwS9Nr4psYZYSqIVqBSq7lKHT14atk1)41IT)mcNf4cTVqg2wJRp6icg9x4gX1GUqLjSW(kiibRSoyBqflNHIJWSbvxl5vbvnyplt8AXuJb1bA0FcuYRcQGqSIjh4cV2c70jL6)cznOpHlSBkGxirtJAhiGN9rxahu1Fk4NEqfqluCkwc)yOPGVl5vCSCgkowO9foqxahbTYjWc)zlSD)eYBoLIvu)SgFG)cTVqaTqg2wJdmPu)Jxl2(ZiCwGl0(cjFHmSTgxF0rem6VWnIRbDHktyH9bbl0(czyBnoBb(OkgnYJ1KaMZcCHwSSqg2wJRp6icg9x4gX1GUqLjSW(evl0(c13rhx3IdmPu)Jxl2(Zi8hj5zzwOYlSVcwizbjyLnc2guXYzO4imBqv)PGF6bvaTqXPyj8JHMc(UKxXXYzO4yH2xiGw4aDbCe0kNal8NTW29tiV5ukwr9ZA8b(l0(czyBnU(OJiy0FHBexd6cvMWc7RGfAFHaAHmSTghysP(hVwS9Nr4SaxO9fQVJoUUfhysP(hVwS9Nr4psYZYSqLxO1kiO6AjVkOQb7zzIxlMAmibRiIGTbvSCgkocZguDTKxfu1G9SmXRftnguhOr)jqjVkO2PFShwYc7Wrhleeg0FzHxp81oqGznTWb7N10cbMuQ)bv9Nc(PhufNILWpgAk47sEfhlNHIJfAFHaAHmSTghysP(hVwS9Nr4SaxO9fs(czyBnU(OJiy0FHBexd6cvMWc7dcwO9fYW2AC2c8rvmAKhRjbmNf4cTyzHmSTgxF0rem6VWnIRbDHktyH9jQwOflluFhDCDloWKs9pETy7pJWFKKNLzHeFH2yH2xidBRX1hDebJ(lCJ4AqxOYewyFIyHKfKGeupgAk47sEvW2Gv9d2guXYzO4imBq11sEvq9rs3BqkAmXUzj4huhOr)jqjVkOccXqtbFxYRw4FIl5vbv9Nc(PhuDTK9WiwiPenluzcl0gl0(cjFHItXs4tUag)SMIg5EsCSCgkowOflluF1Gnfo2d)2FgHJLZqXXcTyzHpBHT7Nqotkznf1hDWXYzO4yHKfKGvwhSnOILZqXry2GQ(tb)0dQaAHJt4T)msSH9WNlPg0SMwO9fcOfYW2ACqtknRPijxdolKZcmO6AjVkOc(6sZAkYqDJeKGv2iyBqflNHIJWSbv9Nc(PhuzyBnoOjLM1uKKRbNfYF01YcTVqdqKsJI)tOy4T)mIrROagxOYewO1l0(cjFHmSTgFGUa2ehSi3iUg0fsyHkKfAXYcb0chOlGJEnIdu7kYLudAwtl0ILfcOfQVEy5LWRCcSeBoUqYcQUwYRcQT)mIrROagdsWkIiyBqflNHIJWSbvxl5vb1JHMc(UGbv9Nc(PhuzyBnoOjLM1uKKRbNfYF01YcTyzHaAHmSTg)tsiNf4cTVqdqKsJI)tOy4GVU0SMImu3iluzcl0gbvTIAkgf)NqXeSQFqcwrSGTbvSCgkocZgu1Fk4NEq1aeP0O4)ekg(e11PtJ(ONxACHktyHwVq7lK8f(SvQJaVU4Zhyl1PSqIVW(kyHwSSWNTqUKKWOCrRxOYlCspwizl0ILfs(chidBRXFVtUp1i3iUg0fs8fsSfAXYchidBRXFVtUp1i)rsEwMfs8f2NylKSGQRL8QG6e11PtJ(ONxAmibRabbBdQy5muCeMnOQ)uWp9GQ(QbBkC89rQDjRPid96YXYzO4yH2xidBRXX3hP2LSMIm0Rl3iUg0fsyHwVq7l01s2dJyHKs0SqclSFq11sEvqT9NrIg5tqXGeSsHfSnOILZqXry2GQ(tb)0dQmSTg)tsiNf4cTVqdqKsJI)tOy4GVU0SMImu3iluzcl06GQRL8QGk4RlnRPid1nsqcwPqc2guXYzO4imBqv)PGF6bvdqKsJI)tOy4tuxNon6JEEPXfQmHfADq11sEvqDI660PrF0ZlngKGvevbBdQy5muCeMnO6AjVkO2(ZirJ8jOyqv)PGF6bvaTqXPyjCVNt9sdg5y5muCSq7leqlKHT14GMuAwtrsUgCwiNf4cTyzHItXs4EpN6LgmYXYzO4yH2xiGwidBRX)KeYzbgu1kQPyu8FcftWQ(bjyvFfeSnOILZqXry2GQ(tb)0dQmSTg)tsiNfyq11sEvqf81LM1uKH6gjibR63pyBqflNHIJWSbvxl5vb1JHMc(UGbvTIAkgf)NqXeSQFqcsqL5mrj1GM1uW2Gv9d2guXYzO4imBq11sEvq9yOPGVlyqvROMIrX)jumbR6hu1Fk4NEq9zRuhbEDXNpWwQtzHktyHGafeuhOr)jqjVkOo7JUaEHxBHQznEF6m(cjsAj7HlKOFIl5vbjyL1bBdQy5muCeMnOQ)uWp9GQ4uSe(KlGXpRPOrUNehlNHIJfAXYc1xnytHJ9WV9Nr4y5muCSqlww4Zwy7(jKZKswtr9rhCSCgkowOfll01s2dJyHKs0SqLjSqRdQUwYRcQps6EdsrJj2nlb)GeSYgbBdQy5muCeMnOQ)uWp9GkdBRX)KeYzbUq7lK8f(SvQJaVU4Zhyl1PSqIVqIrSfAXYcF2c5sscJYfTXcjoHfoPhl0ILfAaIuAu8Fcfdh81LM1uKH6gzHktyHwVqYcQUwYRcQGVU0SMImu3ibjyfreSnOILZqXry2GQRL8QG6XqtbFxWGQ(tb)0dQpBHCjjHr5IeXcj(cN0JfAXYcF2k1rGxx85dSL6uwOYewirqSGQwrnfJI)tOycw1pibRiwW2GkwodfhHzdQ6pf8tpOYW2ACqtknRPijxdolKZcCH2xObisPrX)jum82FgXOvuaJluzcl06fAFHKVqaTWb6c4OxJ4a1UICj1GM10cTVq91dlVeELtGLyZXfAXYcb0c1xpS8s4vobwInhxizbvxl5vb12FgXOvuaJbjyfiiyBqflNHIJWSbv9Nc(PhuF2k1rGxx85dSL6uwOYewirOGfAFHpBHCjjHr5I2yHkVWj9iO6AjVkOc((kETy3Se8dsWkfwW2GkwodfhHzdQ6pf8tpOAaIuAu8FcfdV9NrmAffW4cvMWcTEH2xi5lKHT14d0fWM4Gf5gX1GUqcluHSqlwwiGw4aDbC0RrCGAxrUKAqZAAHwSSqaTq91dlVeELtGLyZXfswq11sEvqT9NrmAffWyqcwPqc2guXYzO4imBq11sEvq9yOPGVlyqv)PGF6b1NTsDe41fF(aBPoLfQ8cTMyl0(cF2cxOYl0gbvTIAkgf)NqXeSQFqcwrufSnOILZqXry2GQ(tb)0dQmSTg)tsiNfyq11sEvqf81LM1uKH6gjibR6RGGTbvSCgkocZgu1Fk4NEq9zRuhbEDXNpWwQtzHkVqIPGGQRL8QGQ)AVWOC)JLeKGeu9dd2gSQFW2GkwodfhHzdQd0O)eOKxfujshr(cj6N4sEvq11sEvq9rs3BqkAmXUzj4hKGvwhSnOILZqXry2GQ(tb)0dQItXs4T)mIrROag5y5muCeuDTKxfuNOUoDA0h98sJbjyLnc2guXYzO4imBq11sEvqT9NrIg5tqXGQ(tb)0dQ67OJRBXFK09gKIgtSBwc(8hj5zzwiXjSqRxirzHt6XcTVqXPyj8jxaJFwtrJCpjowodfhbvTIAkgf)NqXeSQFqcwrebBdQy5muCeMnOQ)uWp9GkdBRX)KeYzbguDTKxfubFDPznfzOUrcsWkIfSnOILZqXry2GQ(tb)0dQd0fWrVgXbQDf5sQbnRPfAFH6RhwEj8kNalXMJl0(czyBn(aDbSjoyrUrCnOlK4lKicQUwYRcQhdnf8DbdsWkqqW2GkwodfhHzdQ6pf8tpOYW2ACqtknRPijxdolK)ORLfAFHKVqaTWb6c4OxJ4a1UICj1GM10cTVq91dlVeELtGLyZXfAXYcb0c1xpS8s4vobwInhxizbvxl5vb12FgXOvuaJbjyLclyBqflNHIJWSbv9Nc(PhuF2k1rGxx85dSL6uwiXxi5lSpXw4mluCkwc)zRuhDrWI1L8kowodfhlKOSqBSqYcQUwYRcQtuxNon6JEEPXGeSsHeSnOILZqXry2GQRL8QGA7pJenYNGIbv9Nc(PhuF2k1rGxx85dSL6uwiXxi5lSpXw4mluCkwc)zRuhDrWI1L8kowodfhlKOSqBSqYcQAf1umk(pHIjyv)GeSIOkyBqflNHIJWSbv9Nc(Phub0chOlGJEnIdu7kYLudAwtl0(c1xpS8s4vobwInhxOflleqluF9WYlHx5eyj2CmO6AjVkO2(ZigTIcymibR6RGGTbvSCgkocZguDTKxfupgAk47cgu1Fk4NEq9zRuhbEDXNpWwQtzHkVqYxO1eBHZSqXPyj8NTsD0fblwxYR4y5muCSqIYcTXcjlOQvutXO4)ekMGv9dsWQ(9d2guDTKxfuNOUoDA0h98sJbvSCgkocZgKGv9ToyBqflNHIJWSbvxl5vb12FgjAKpbfdQAf1umk(pHIjyv)GeSQVnc2guDTKxfubFFfVwSBwc(bvSCgkocZgKGv9jIGTbvxl5vbv)1EHr5(hljOILZqXry2GeKG6aBolvc2gSQFW2GQRL8QGkPSgX2JyNGbvSCgkocZgKGvwhSnOILZqXry2G6bmOAqjO6AjVkO2Z)0zOyqTNtzXGk5lev4SjqG4GNLr)SIZqXOcN1lHLuCG9snUq7luFhDCDlEwg9ZkodfJkCwVewsXb2l1i)rFO4cjlOoqJ(tGsEvqTt)ypSKfAaI6SL4yHYNfOOywidM10czn4yHDtb8cDw5i5sQxinl0eu75FSCsyq1ae1zlXru(SafLGeSYgbBdQy5muCeMnO6AjVkO(iP7nifnMy3Se8dQd0O)eOKxfujsabsvCHDQ)mYc7uyp8vAHK8SepRfs00kUqBD6vMf61yHGIiWfs0rs3BqkAmlKillb)f(hLM1uqv)PGF6bv9vd2u4yp8B)zeowodfhl0(cfNILWNCbm(znfnY9K4y5muCSq7leqluCkwc)yOPGVl5vCSCgkowO9fQVJoUUfhysP(hVwS9Nr4psYZYeKGverW2GkwodfhHzdQUwYRcQGVU0SMImu3ib1bA0FcuYRcQejGaPkUWo1FgzHDkSh(l0RXcj5zjEwlKOPvCH260Rmbv9Nc(Phub0chNWB)zKyd7HpxsnOznTq7lK8fkoflHNAu7a5y5muCSqlwwO(o646wCMhDbC8ArtwJ3NoJZFKKNLzHkVW(eBHwSSqXPyj8JHMc(UKxXXYzO4yH2xO(o646wCGjL6F8AX2FgH)ijplZcTVqaTqg2wJdAsPznfj5AWzHCwGlKSGeSIybBdQy5muCeMnOQ)uWp9GkdBRXtTIrXPxz4psYZYSqItyHt6XcTVqg2wJNAfJItVYWzbUq7l0aeP0O4)ekg(e11PtJ(ONxACHktyHwVq7lK8fcOfkoflHZ8OlGJxlAYA8(0zCowodfhl0ILfQVJoUUfN5rxahVw0K149PZ48hj5zzwOYlSpXwizbvxl5vb1jQRtNg9rpV0yqcwbcc2guXYzO4imBqv)PGF6bvg2wJNAfJItVYWFKKNLzHeNWcN0JfAFHmSTgp1kgfNELHZcCH2xi5leqluCkwcN5rxahVw0K149PZ4CSCgkowOflluFhDCDloZJUaoETOjRX7tNX5psYZYSqLxyFITqYcQUwYRcQT)ms0iFckgKGvkSGTbvSCgkocZguhOr)jqjVkO2bW3zWfsK0sE1cPPrwOCl8zRGQRL8QGQ2P0ORL8QinnsqLMgjwojmOQVEy5LycsWkfsW2GkwodfhHzdQUwYRcQANsJUwYRI00ibvAAKy5KWG6760PMGeSIOkyBqflNHIJWSbvxl5vbvTtPrxl5vrAAKGknnsSCsyqv(Safftqcw1xbbBdQy5muCeMnO6AjVkOQDkn6AjVkstJeuPPrILtcdQ67OJRBzcsWQ(9d2guXYzO4imBqv)PGF6bvXPyjC9rhrWO)chlNHIJfAFHmSTgxF0rem6VWnIRbDHktyH9vWcTVqYx4azyBn(7DY9Pg5gX1GUqclKyl0ILfcOfoqxahbTYjWc)zlSD)eYFVtUp14cjlO6AjVkOQDkn6AjVkstJeuPPrILtcdQ6JoIGr)LGeSQV1bBdQy5muCeMnOQ)uWp9GkdBRXzE0fWXRfnznEF6moNfyq11sEvq9zRORL8QinnsqLMgjwojmOYCMOKAqZAkibR6BJGTbvSCgkocZgu1Fk4NEqvCkwcN5rxahVw0K149PZ4CSCgkowO9fs(c13rhx3IZ8OlGJxlAYA8(0zC(JK8SmlK4lSVcwizbvxl5vb1NTIUwYRI00ibvAAKy5KWGkZzIaVJM1uqcw1Nic2guXYzO4imBqv)PGF6bvg2wJdmPu)Jxl2(ZiCwGl0(cfNILWpgAk47sEfhlNHIJGQRL8QG6Zwrxl5vrAAKGknnsSCsyq9yOPGVl5vbjyvFIfSnOILZqXry2GQ(tb)0dQItXs4hdnf8DjVIJLZqXXcTVq9D0X1T4atk1)41IT)mc)rsEwMfs8f2xbbvxl5vb1NTIUwYRI00ibvAAKy5KWG6XqtbFxYRIaVJM1uqcw1heeSnOILZqXry2GQ(tb)0dQUwYEyelKuIMfQmHfADq11sEvq9zRORL8QinnsqLMgjwojmO6hgKGv9vybBdQy5muCeMnO6AjVkOQDkn6AjVkstJeuPPrILtcdQgXRH)JGeKG6760PMGTbR6hSnOILZqXry2GQRL8QGkd9UrSX(kguhOr)jqjVkOs0DD60fsKysAkjAcQ6pf8tpOYW2ACGjL6F8AX2FgHZcmibRSoyBqflNHIJWSbv9Nc(PhuzyBnoWKs9pETy7pJWzbguDTKxfuzW3GpOznfKGv2iyBqflNHIJWSbv9Nc(PhujFHaAHmSTghysP(hVwS9Nr4SaxO9f6Aj7HrSqsjAwOYewO1lKSfAXYcb0czyBnoWKs9pETy7pJWzbUq7lK8f(SfYhyl1PSqLjSqITq7l8zRuhbEDXNpWwQtzHktyHGafSqYcQUwYRcQ(R9cJazPgmibRiIGTbvSCgkocZgu1Fk4NEqLHT14atk1)41IT)mcNfyq11sEvqLMtGftuHo2XejSKGeSIybBdQy5muCeMnOQ)uWp9GkdBRXbMuQ)XRfB)zeolWfAFHmSTghjb86IF8zlm2fDGxXzbguDTKxfu9sJg5DAu7uAqcwbcc2guXYzO4imBqv)PGF6bvg2wJdmPu)Jxl2(Zi8hj5zzwiXjSqfYcTVqg2wJJKaEDXp(Sfg7IoWR4SadQUwYRcQT8rg6DJGeSsHfSnOILZqXry2GQ(tb)0dQmSTghysP(hVwS9Nr4SaxO9f6Aj7HrSqsjAwiHf2FH2xi5lKHT14atk1)41IT)mc)rsEwMfs8fsSfAFHItXs46JoIGr)fowodfhl0ILfcOfkoflHRp6icg9x4y5muCSq7lKHT14atk1)41IT)mc)rsEwMfs8fAJfswq11sEvqLXNIxlkFQb1eKGeu1xpS8smbBdw1pyBqflNHIJWSbvxl5vb1b6cytCWIb1bA0FcuYRcQD46HLxYcjsmjnLenbv9Nc(PhuFphrShwc3hddpRfQ8c7tSfAXYcb0cFphrShwc3hddh7yAeZcTyzHUwYEyelKuIMfQmHfADqcwzDW2GkwodfhHzdQ6pf8tpO6Aj7HrSqsjAwiHf2FH2x4ZwPoc86IpFGTuNYcvEH2yH2xO(o646wCGjL6F8AX2FgH)ijplZcj(cTXcTVqaTqXPyjCMhDbC8ArtwJ3NoJZXYzO4yH2xi5leql89CeXEyjCFmmCSJPrml0ILf(EoIypSeUpggEwlu5f2NylKSGQRL8QGQPR)KYAksknsqcwzJGTbvSCgkocZgu1Fk4NEq11s2dJyHKs0SqLjSqRxO9fcOfkoflHZ8OlGJxlAYA8(0zCowodfhbvxl5vbvtx)jL1uKuAKGeSIic2guXYzO4imBqv)PGF6bvXPyjCMhDbC8ArtwJ3NoJZXYzO4yH2xi5lKHT14mp6c441IMSgVpDgNZcCH2xi5l01s2dJyHKs0SqclS)cTVWNTsDe41fF(aBPoLfQ8cjcfSqlwwORLShgXcjLOzHktyHwVq7l8zRuhbEDXNpWwQtzHkVqqGcwizl0ILfcOfYW2ACMhDbC8ArtwJ3NoJZzbUq7luFhDCDloZJUaoETOjRX7tNX5psYZYSqYcQUwYRcQMU(tkRPiP0ibjyfXc2guXYzO4imBqv)PGF6bvxlzpmIfskrZcjSW(l0(c13rhx3IdmPu)Jxl2(Zi8hj5zzwiXxOnwO9fs(cb0cFphrShwc3hddh7yAeZcTyzHVNJi2dlH7JHHN1cvEH9j2cjlO6AjVkO6mhPSCjVkstsmbjyfiiyBqflNHIJWSbv9Nc(PhuDTK9WiwiPenluzcl06GQRL8QGQZCKYYL8QinjXeKGvkSGTbvSCgkocZgu1Fk4NEq11s2dJyHKs0SqclS)cTVq9D0X1T4atk1)41IT)mc)rsEwMfs8fAJfAFHKVqaTW3Zre7HLW9XWWXoMgXSqlww475iI9Ws4(yy4zTqLxyFITqYcQUwYRcQgWUgukgfWyKT6EVawXGeSsHeSnOILZqXry2GQ(tb)0dQUwYEyelKuIMfQmHfADq11sEvq1a21GsXOagJSv37fWkgKGeub(O(iX4sW2Geu13rhx3YeSnyv)GTbvSCgkocZgu1Fk4NEqLHT14atk1)41IT)mcNf4cTVqg2wJJKaEDXp(Sfg7IoWR4SadQd0O)eOKxfu70NKxfuDTKxfubEsEvqcwzDW2GkwodfhHzdQUwYRcQijGxx8JpBHXUOd8QG6an6pbk5vb1oChDCDltqv)PGF6bvXPyj8JHMc(UKxXXYzO4yH2xi5luFhDCDloWKs9pETy7pJWF0hkUq7l8zlKljjmkxKylu5foPhl0(cF2k1rGxx85dSL6uwOYewyFfSqlwwidBRXbMuQ)XRfB)zeolWfAFHpBHCjjHr5IeBHkVWj9yHKTqlwwylNalXhj5zzwiXxO1kiibRSrW2GkwodfhHzdQ6pf8tpOkoflHZ8OlGJxlAYA8(0zCowodfhl0(cF2k1rGxx85dSL6uwOYlKiuWcTVWNTqUKKWOCrITqLx4KESq7lK8fYW2ACMhDbC8ArtwJ3NoJZzbUqlwwylNalXhj5zzwiXxO1kyHKfuDTKxfursaVU4hF2cJDrh4vbjyfreSnOILZqXry2GQ(tb)0dQItXs4Pg1oqowodfhl0(cF2cxiXxOncQUwYRcQijGxx8JpBHXUOd8QGeSIybBdQy5muCeMnOQ)uWp9GQ4uSeoZJUaoETOjRX7tNX5y5muCSq7lK8fQVJoUUfN5rxahVw0K149PZ48hj5zzwOflluFhDCDloZJUaoETOjRX7tNX5p6dfxO9f(SvQJaVU4Zhyl1PSqIVqqGcwizbvxl5vbvGjL6F8AX2FgjibRabbBdQy5muCeMnOQ)uWp9GQ4uSeEQrTdKJLZqXXcTVqaTqg2wJdmPu)Jxl2(ZiCwGbvxl5vbvGjL6F8AX2FgjibRuybBdQy5muCeMnOQ)uWp9GQ4uSe(XqtbFxYR4y5muCSq7lK8fkoflHp5cy8ZAkAK7jXXYzO4yH2xidBRXFK09gKIgtSBwc(CwGl0ILfcOfkoflHp5cy8ZAkAK7jXXYzO4yHKfuDTKxfubMuQ)XRfB)zKGeSsHeSnOILZqXry2GQ(tb)0dQmSTghysP(hVwS9Nr4SadQUwYRcQmp6c441IMSgVpDgpibRiQc2guXYzO4imBqv)PGF6bvg2wJdmPu)Jxl2(Zi8hj5zzwiXx4KESq7lKHT14atk1)41IT)mcNf4cTVqaTqXPyj8JHMc(UKxXXYzO4iO6AjVkO2(ZiDv8jzIn2xXGeSQVcc2guXYzO4imBqv)PGF6bvxlzpmIfskrZcvMWcTEH2xi5lKHT14atk1)41IT)mcNf4cTVqg2wJdmPu)Jxl2(Zi8hj5zzwiXx4KESqlww475iI9Ws4(yy4yhtJywO9f(EoIypSeUpgg(JK8SmlK4lCspwOfllSLtGL4JK8SmlK4lCspwizbvxl5vb12FgPRIpjtSX(kgKGv97hSnOILZqXry2GQ(tb)0dQItXs4hdnf8DjVIJLZqXXcTVqaTqg2wJdmPu)Jxl2(ZiCwGl0(cjFHKVqg2wJZwGpQIrJ8ynjG5SaxOflleqlCGUaocALtGf(Zwy7(jK3CkfRO(zn(a)fs2cTVqYx4azyBn(7DY9Pg5gX1GUqclKyl0ILfcOfoqxahbTYjWc)zlSD)eYFVtUp14cjBHKfuDTKxfuB)zKUk(KmXg7Ryqcw136GTbvSCgkocZgu1Fk4NEqvCkwcN5rxahVw0K149PZ4CSCgkowO9f(SvQJaVU4Zhyl1PSqLxirOGfAFHpBHluzcl0gl0(czyBnoWKs9pETy7pJWzbUqlwwiGwO4uSeoZJUaoETOjRX7tNX5y5muCSq7l8zRuhbEDXNpWwQtzHktyHwtSGQRL8QGkyfbEcy8jL6iWhnyPXGeSQVnc2guXYzO4imBqv)PGF6bvg2wJdmPu)Jxl2(ZiCwGbvxl5vb13tdghOpcsWQ(erW2GkwodfhHzdQ6pf8tpO6Aj7HrSqsjAwOYewO1l0(cjFHarHpb(yP8hj5zzwiXx4KESqlwwO4)ekCjjHr5IJexiXx4KESqYcQUwYRcQgx)zl1PtJaDTeKGv9jwW2GkwodfhHzdQ6pf8tpO6Aj7HrSqsjAwOYlKyl0ILf(Sf2UFc5abJ(FKUcnCSCgkocQUwYRcQd0fWrVgXbQDfdsqcQYNfOOyc2gSQFW2GkwodfhHzdQUwYRcQzz0pR4mumQWz9syjfhyVuJb1bA0FcuYRcQ2(zbkkMGQ(tb)0dQmSTghysP(hVwS9Nr4SaxOfllu8FcfUKKWOCrGAjATcwiXxiXwOfllSLtGL4JK8SmlK4l06(bjyL1bBdQy5muCeMnOQ)uWp9GkdBRXbMuQ)XRfB)zeolWfAFHKVqaTqXPyj8uJAhihlNHIJfAXYcfNILWtnQDGCSCgkowO9fYW2ACGjL6F8AX2FgH)ijplZcvMWc7RGfswq11sEvqL1GXuqsMGeKGkZzIaVJM1uW2Gv9d2guXYzO4imBq11sEvqf81LM1uKH6gjOoqJ(tGsEvqD2hDb8cV2cvZA8(0z8fc8oAwtl8pXL8QfAZfAe)fZc7RaZczW294cN9uxyAwO3ZtQZqXGQ(tb)0dQmSTg)tsiNfyqcwzDW2GkwodfhHzdQ6pf8tpO6Aj7HrSqsjAwOYewO1l0ILf(SfYLKegLlsSfsCclCspwO9fs(cfNILWNCbm(znfnY9K4y5muCSqlwwO(QbBkCSh(T)mchlNHIJfAXYcF2cB3pHCMuYAkQp6GJLZqXXcjlO6AjVkO(iP7nifnMy3Se8dsWkBeSnOILZqXry2GQRL8QG6XqtbFxWGQwrnfJI)tOycw1pOQ)uWp9G6ZwPoc86IpFGTuNYcvMWcTMyb1bA0FcuYRcQZf)NqjMncK8oAtYhidBRXFVtUp1i3iUg0z6tgrn5dKHT14V3j3NAK)ijplZm9jJOmqxahbTYjWc)zlSD)eYFVtUp148fs0rGOlMf6lKEIsluaNMfMMfMLG1ahluUfk(pHYcfW4cbNtGrJSqGFEFkkUqSqskUWUPaEHETqNjPPO4cfWUSWUjLUqhiqQIl89o5(uJlmBl8zlSD)eo4l0wWUSqgmRPf61cXcjP4c7Mc4fQGfAexdQrPfE)c9AHyHKuCHcyxwOagx4azyBTf2nP0fAURwi2rG5Jl8kEqcwrebBdQy5muCeMnOQ)uWp9G6ZwPoc86IpFGTuNYcj(cTwbl0(cnarknk(pHIHprDD60Op65LgxOYewO1l0(c13rhx3IdmPu)Jxl2(Zi8hj5zzwOYlKybvxl5vb1jQRtNg9rpV0yqcwrSGTbvSCgkocZguDTKxfuB)zKOr(eumOQ)uWp9G6ZwPoc86IpFGTuNYcj(cTwbl0(c13rhx3IdmPu)Jxl2(Zi8hj5zzwOYlKybvTIAkgf)NqXeSQFqcwbcc2guXYzO4imBqv)PGF6bvg2wJdAsPznfj5AWzH8hDTSq7l8zRuhbEDXNpWwQtzHkVqYxyFITWzwO4uSe(ZwPo6IGfRl5vCSCgkowirzH2yHKTq7l0aeP0O4)ekgE7pJy0kkGXfQmHfA9cTVqYxidBRXhOlGnXblYnIRbDHewOczHwSSqaTWb6c4OxJ4a1UICj1GM10cTyzHaAH6RhwEj8kNalXMJlKSGQRL8QGA7pJy0kkGXGeSsHfSnOILZqXry2GQ(tb)0dQpBL6iWRl(8b2sDkluzclK8fAdITWzwO4uSe(ZwPo6IGfRl5vCSCgkowirzH2yHKTq7l0aeP0O4)ekgE7pJy0kkGXfQmHfA9cTVqYxidBRXhOlGnXblYnIRbDHewOczHwSSqaTWb6c4OxJ4a1UICj1GM10cTyzHaAH6RhwEj8kNalXMJlKSGQRL8QGA7pJy0kkGXGeSsHeSnOILZqXry2GQRL8QG6XqtbFxWGQ(tb)0dQpBL6iWRl(8b2sDkluzclK8fAdITWzwO4uSe(ZwPo6IGfRl5vCSCgkowirzH2yHKfu1kQPyu8FcftWQ(bjyfrvW2GkwodfhHzdQ6pf8tpOQVJoUUfhysP(hVwS9Nr4psYZYSqLx4ZwixssyuUirSq7l8zRuhbEDXNpWwQtzHeFHeHcwO9fAaIuAu8FcfdFI660PrF0ZlnUqLjSqRdQUwYRcQtuxNon6JEEPXGeSQVcc2guXYzO4imBq11sEvqT9NrIg5tqXGQ(tb)0dQ67OJRBXbMuQ)XRfB)ze(JK8Smlu5f(SfYLKegLlsel0(cF2k1rGxx85dSL6uwiXxirOGGQwrnfJI)tOycw1pibjOAeVg(pc2gSQFW2GkwodfhHzdQUwYRcQps6EdsrJj2nlb)G6an6pbk5vbvvXRH)JfAYAIIGWf)NqzH)jUKxfu1Fk4NEqvCkwcFYfW4N1u0i3tIJLZqXXcTyzH6RgSPWXE43(ZiCSCgkowOfll8zlSD)eYzsjRPO(OdowodfhbjyL1bBdQy5muCeMnOQ)uWp9GkGw4aDbCe0kNal8NTW29ti)9o5(uJl0(cjFHdKHT14V3j3NAKBexd6cj(cj2cTyzHdKHT14V3j3NAK)ijplZcj(cvylKSGQRL8QG6e11PtJ(ONxAmibRSrW2GkwodfhHzdQ6pf8tpOQVJoUUf)rs3BqkAmXUzj4ZFKKNLzHeNWcTEHeLfoPhl0(cfNILWNCbm(znfnY9K4y5muCeuDTKxfuB)zKOr(eumibRiIGTbvSCgkocZgu1Fk4NEqvF1Gnfo((i1UK1uKHED5y5muCSq7lKHT1447Ju7swtrg61LBexd6cjSqRxOflluF1GnfoBrr3aghX2JvNOihlNHIJfAFHmSTgNTOOBaJJy7XQtuK)ijplZcj(cTXcTVqg2wJZwu0nGXrS9y1jkYzbguDTKxfuB)zKOr(eumibRiwW2GkwodfhHzdQ6pf8tpOYW2A8pjHCwGbvxl5vbvWxxAwtrgQBKGeSceeSnOILZqXry2GQ(tb)0dQaAHmSTgV9xNGveil1GCwGl0(cfNILWB)1jyfbYsnihlNHIJfAXYczyBnoOjLM1uKKRbNfYF01YcTyzHd0fWrVgXbQDf5sQbnRPfAFH6RhwEj8kNalXMJl0(czyBn(aDbSjoyrUrCnOlu5fQqwOfll8zlKljjmkxKiwiXjSWj9iO6AjVkOEm0uW3fmibRuybBdQy5muCeMnOQ)uWp9G6ZwPoc86IpFGTuNYcj(cjFH9j2cNzHItXs4pBL6OlcwSUKxXXYzO4yHeLfAJfswq11sEvqT9NrIg5tqXGeSsHeSnOILZqXry2GQ(tb)0dQpBL6iWRl(8b2sDklu5fs(cTMylCMfkoflH)SvQJUiyX6sEfhlNHIJfsuwOnwizbvxl5vb1JHMc(UGbjyfrvW2GQRL8QGA7pJenYNGIbvSCgkocZgKGv9vqW2GQRL8QGk47R41IDZsWpOILZqXry2GeSQF)GTbvxl5vbv)1EHr5(hljOILZqXry2GeKGeu7HVjVkyL1kW6(kWg9jIGAx)RSMmbvImIer3kIMvku2CHl0wW4ctsaVxwy7(fo)yOPGVl5vrG3rZAA(cFuHZMpowO5iHl0zLJKl4yHAWEnHg(cqNZcxyFBUWoCvp8fCSW5ItXs4GC(cLBHZfNILWbjhlNHIJ5lK8(DKm(cqNZcxyFBUWoCvp8fCSW5pBHT7NqoiNVq5w48NTW29tihKCSCgkoMVqY73rY4laDolCH9T5c7Wv9WxWXcNRVAWMchKZxOClCU(QbBkCqYXYzO4y(cjVFhjJVaSaqKrKi6wr0SsHYMlCH2cgxysc49YcB3VW56JoIGr)L5l8rfoB(4yHMJeUqNvosUGJfQb71eA4laDolCH9T5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqY73rY4laDolCHwBZf2HR6HVGJfoxCkwchKZxOClCU4uSeoi5y5muCmFHK3VJKXxa6Cw4cTHnxyhUQh(cow4CXPyjCqoFHYTW5ItXs4GKJLZqXX8fsE)osgFbOZzHlKiS5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqY73rY4lalaezejIUvenRuOS5cxOTGXfMKaEVSW29lC(XqtbFxYRMVWhv4S5JJfAos4cDw5i5cowOgSxtOHVa05SWf23MlSdx1dFbhlCU4uSeoiNVq5w4CXPyjCqYXYzO4y(cjVFhjJVa05SWf23MlSdx1dFbhlC(Zwy7(jKdY5luUfo)zlSD)eYbjhlNHIJ5lK8(DKm(cqNZcxyFBUWoCvp8fCSW56RgSPWb58fk3cNRVAWMchKCSCgkoMVqY73rY4laDolCHGaBUWoCvp8fCSW56RgSPWb58fk3cNRVAWMchKCSCgkoMVqY73rY4laDolCHev2CHD4QE4l4yHZfNILWb58fk3cNloflHdsowodfhZxi5w3rY4lalaezejIUvenRuOS5cxOTGXfMKaEVSW29lCoZzIsQbnRP5l8rfoB(4yHMJeUqNvosUGJfQb71eA4laDolCHwBZf2HR6HVGJfoxCkwchKZxOClCU4uSeoi5y5muCmFHK3VJKXxa6Cw4cT2MlSdx1dFbhlC(Zwy7(jKdY5luUfo)zlSD)eYbjhlNHIJ5lK8(DKm(cqNZcxO12CHD4QE4l4yHZ1xnytHdY5luUfoxF1Gnfoi5y5muCmFHK3VJKXxawaiYiseDRiAwPqzZfUqBbJlmjb8EzHT7x4C91dlVeZ8f(OcNnFCSqZrcxOZkhjxWXc1G9Acn8fGoNfUqRT5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqY73rY4laDolCH2WMlSdx1dFbhlCU4uSeoiNVq5w4CXPyjCqYXYzO4y(cDzHe5GqDEHK3VJKXxa6Cw4cjcBUWoCvp8fCSW5ItXs4GC(cLBHZfNILWbjhlNHIJ5lK8(DKm(cWcargrIOBfrZkfkBUWfAlyCHjjG3llSD)cNBeVg(pMVWhv4S5JJfAos4cDw5i5cowOgSxtOHVa05SWf23MlSdx1dFbhlCU4uSeoiNVq5w4CXPyjCqYXYzO4y(cjVFhjJVa05SWf23MlSdx1dFbhlC(Zwy7(jKdY5luUfo)zlSD)eYbjhlNHIJ5l0LfsKdc15fsE)osgFbOZzHlSVnxyhUQh(cow4C9vd2u4GC(cLBHZ1xnytHdsowodfhZxi597iz8fGoNfUqByZf2HR6HVGJfoxCkwchKZxOClCU4uSeoi5y5muCmFHUSqICqOoVqY73rY4laDolCHeHnxyhUQh(cow4C9vd2u4GC(cLBHZ1xnytHdsowodfhZxi5w3rY4laDolCHGaBUWoCvp8fCSW5ItXs4GC(cLBHZfNILWbjhlNHIJ5lK8(DKm(cqNZcxOcZMlSdx1dFbhlCU4uSeoiNVq5w4CXPyjCqYXYzO4y(cjVFhjJVa05SWfQqS5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqY73rY4lalaezejIUvenRuOS5cxOTGXfMKaEVSW29lCoZzIaVJM108f(OcNnFCSqZrcxOZkhjxWXc1G9Acn8fGoNfUqRT5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqY73rY4laDolCHwBZf2HR6HVGJfo)zlSD)eYb58fk3cN)Sf2UFc5GKJLZqXX8fsE)osgFbOZzHl0ABUWoCvp8fCSW56RgSPWb58fk3cNRVAWMchKCSCgkoMVqY73rY4laDolCHGaBUWoCvp8fCSW5ItXs4GC(cLBHZfNILWbjhlNHIJ5lK8(DKm(cqNZcxOcZMlSdx1dFbhlCU4uSeoiNVq5w4CXPyjCqYXYzO4y(cjVFhjJVa05SWfQqS5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqY73rY4lalaezejIUvenRuOS5cxOTGXfMKaEVSW29lCU(o646wM5l8rfoB(4yHMJeUqNvosUGJfQb71eA4laDolCHwBZf2HR6HVGJfoxCkwchKZxOClCU4uSeoi5y5muCmFHK3VJKXxa6Cw4cTHnxyhUQh(cow4CXPyjCqoFHYTW5ItXs4GKJLZqXX8fsE)osgFbOZzHlKiS5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqY73rY4laDolCHeZMlSdx1dFbhlCU4uSeoiNVq5w4CXPyjCqYXYzO4y(cjVFhjJVa05SWfccS5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqY73rY4laDolCHkmBUWoCvp8fCSW5ItXs4GC(cLBHZfNILWbjhlNHIJ5lK8(DKm(cqNZcxirLnxyhUQh(cow4CXPyjCqoFHYTW5ItXs4GKJLZqXX8f6YcjYbH68cjVFhjJVa05SWf2VVnxyhUQh(cow4CXPyjCqoFHYTW5ItXs4GKJLZqXX8fsE)osgFbOZzHlSV12CHD4QE4l4yHZfNILWb58fk3cNloflHdsowodfhZxi5w3rY4laDolCH9jMnxyhUQh(cow48NTW29tihKZxOClC(Zwy7(jKdsowodfhZxOllKiheQZlK8(DKm(cWcargrIOBfrZkfkBUWfAlyCHjjG3llSD)cNlFwGIIz(cFuHZMpowO5iHl0zLJKl4yHAWEnHg(cqNZcxO12CHD4QE4l4yHZfNILWb58fk3cNloflHdsowodfhZxi5w3rY4lalaezejIUvenRuOS5cxOTGXfMKaEVSW29lC(aBolvMVWhv4S5JJfAos4cDw5i5cowOgSxtOHVa05SWfAdBUWoCvp8fCSW5ItXs4GC(cLBHZfNILWbjhlNHIJ5lKCR7iz8fGoNfUqByZf2HR6HVGJfoxF1GnfoiNVq5w4C9vd2u4GKJLZqXX8fsE)osgFbOZzHlKiS5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqYTUJKXxa6Cw4cjMnxyhUQh(cow4CXPyjCqoFHYTW5ItXs4GKJLZqXX8fsE)osgFbOZzHleeyZf2HR6HVGJfoxCkwchKZxOClCU4uSeoi5y5muCmFHK3VJKXxa6Cw4c733MlSdx1dFbhlCU4uSeoiNVq5w4CXPyjCqYXYzO4y(cjVFhjJVa05SWf23g2CHD4QE4l4yHZfNILWb58fk3cNloflHdsowodfhZxi597iz8fGoNfUW(eHnxyhUQh(cow4CXPyjCqoFHYTW5ItXs4GKJLZqXX8f6YcjYbH68cjVFhjJVa05SWf2Ny2CHD4QE4l4yHZfNILWb58fk3cNloflHdsowodfhZxi597iz8fGfaImIer3kIMvku2CHl0wW4ctsaVxwy7(fo3pC(cFuHZMpowO5iHl0zLJKl4yHAWEnHg(cqNZcxO12CHD4QE4l4yHZfNILWb58fk3cNloflHdsowodfhZxOllKiheQZlK8(DKm(cqNZcxOnS5c7Wv9WxWXcNloflHdY5luUfoxCkwchKCSCgkoMVqxwiroiuNxi597iz8fGoNfUqfMnxyhUQh(cow4CXPyjCqoFHYTW5ItXs4GKJLZqXX8fsE)osgFbOZzHluHyZf2HR6HVGJfoxCkwchKZxOClCU4uSeoi5y5muCmFHK3VJKXxa6Cw4c7RaBUWoCvp8fCSW5ItXs4GC(cLBHZfNILWbjhlNHIJ5lK8(DKm(cWcarJeW7fCSW(wVqxl5vlKMgXWxacQa)RLumOcIG4cvOHUaEHGWw5eyzHDQ)mYcaicIlKib8t6cTwPfATcSU)cWcaicIlSdG9AcnlaGiiUqq4lKOJKUE4yHu3iGWnO(QXczn(eUWRTWoa2ZYSWRTqIMgxOBwyklCCOPMllei1vCHDrkDHzTqGVRLuJ8fGfaqeexirEpNY6cAwOVq5ZcuumluFhDCDlLw4i7LdCSqgfxiWKs9FHxBHT)mYcVFHmp6c4fETfAYA8(0z85MfQVJoUUfFHeT2ctzUzH9CklUqWUzH1TWhj5znWFHpkSFTW(kTqKAWf(OW(1cvaNy8faqeexORL8kdh4J6JeJle65F6muuPYjHeKplqrj2pAuS0kDajyqjBk1ZPSiH(k1ZPSyePgKGc4etj9vJuYRiiFwGIcVphSBISgmYW2A2jhqItXs4mp6c441IMSgVpDg3o5YNfOOW7Z13rhx3IpyFxYRiQjQ13rhx3IdmPu)Jxl2(Zi8b77sEfbfqMflItXs4mp6c441IMSgVpDg3o567OJRBXzE0fWXRfnznEF6moFW(UKxrutulFwGIcVpxFhDCDl(G9DjVIGciZIfXPyj8uJAhizlaGiiUqxl5vgoWh1hjgxMHaG75F6muuPYjHeKplqrjAD0OyPv6asWGs2uQNtzrc9vQNtzXisnibfWjMs6RgPKxrq(SaffU1CWUjYAWidBRzNCajoflHZ8OlGJxlAYA8(0zC7KlFwGIc3AU(o646w8b77sEfrnrT(o646wCGjL6F8AX2FgHpyFxYRiOaYSyrCkwcN5rxahVw0K149PZ42jxFhDCDloZJUaoETOjRX7tNX5d23L8kIAIA5Zcuu4wZ13rhx3IpyFxYRiOaYSyrCkwcp1O2bs2caicIlKi3ijjxqZc9fkFwGIIzH9CklUqgfxO(ib0)SMwOagxO(o646wl8AluaJlu(SaffLw4i7LdCSqgfxOagx4G9DjVAHxBHcyCHmST2ctzHa)RxoqdFHGW4Mf6l0ipwtc4fs6gzlXFHYTWPShUqFHGZjW4VqGFEFkkUq5wOrESMeWlu(SaffJsl0nlSlsPl0nl0xiPBKTe)f2UFHzBH(cLplqrzHDtkDH3VWUjLUW6KfAuS0lSBkGxO(o646wg(caicIl01sELHd8r9rIXLzia4E(NodfvQCsib5ZcuuIa)8(uuuPdibdkztPEoLfjyTs9CklgrQbj0xj9vJuYRiai5Zcuu495GDtK1Grg2wZU8zbkkCR5GDtK1Grg2wZIf5Zcuu4wZb7MiRbJmSTMDYjx(SaffU1C9D0X1T4d23L8kIA5Zcuu4wZb(NM7LIXbqdFW(UKxrgrH8(CInJ8zbkkCR5GDtKHT14g5XAsatgrH8E(Nodf5YNfOOeToAuS0KrMYKtU8zbkk8(C9D0X1T4d23L8kIA5Zcuu495a)tZ9sX4aOHpyFxYRiJOqEFoXMr(SaffEFoy3ezyBnUrESMeWKruiVN)PZqrU8zbkkX(rJILMmYwawaarqCHe5De1Scowi2dFfxOKKWfkGXf6A5(fMMf698K6muKVa4AjVYqGuwJy7rStWfaqCHD6h7HLSqdquNTehlu(SaffZczWSMwiRbhlSBkGxOZkhjxs9cPzHMfaxl5vMzia4E(NodfvQCsibdquNTehr5ZcuuuQNtzrcKJkC2eiqCWZYOFwXzOyuHZ6LWskoWEPgTRVJoUUfplJ(zfNHIrfoRxclP4a7LAK)OpuKSfaqCHejGaPkUWo1FgzHDkSh(kTqsEwIN1cjAAfxOTo9kZc9ASqqre4cj6iP7nifnMfsKLLG)c)JsZAAbW1sELzgca(rs3BqkAmXUzj4Ru2iOVAWMch7HF7pJyxCkwcFYfW4N1u0i3tYoGeNILWpgAk47sELD9D0X1T4atk1)41IT)mc)rsEwMfaqCHejGaPkUWo1FgzHDkSh(l0RXcj5zjEwlKOPvCH260RmlaUwYRmZqaWGVU0SMImu3ikLncaACcV9NrInSh(Cj1GM1KDYfNILWtnQDGwSOVJoUUfN5rxahVw0K149PZ48hj5zzuUpXSyrCkwc)yOPGVl5v213rhx3IdmPu)Jxl2(Zi8hj5zzSdig2wJdAsPznfj5AWzHCwGKTa4AjVYmdbaprDD60Op65LgvkBeyyBnEQvmko9kd)rsEwgItyspSZW2A8uRyuC6vgolq7gGiLgf)NqXWNOUoDA0h98sJktWA7KdiXPyjCMhDbC8ArtwJ3NoJBXI(o646wCMhDbC8ArtwJ3NoJZFKKNLr5(eJSfaxl5vMzia42FgjAKpbfvkBeyyBnEQvmko9kd)rsEwgItyspSZW2A8uRyuC6vgolq7KdiXPyjCMhDbC8ArtwJ3NoJBXI(o646wCMhDbC8ArtwJ3NoJZFKKNLr5(eJSfaqCHDa8DgCHejTKxTqAAKfk3cF2AbW1sELzgcaw7uA01sEvKMgrPYjHe0xpS8smlaUwYRmZqaWANsJUwYRI00ikvojKW760PMfaxl5vMziayTtPrxl5vrAAeLkNesq(SaffZcGRL8kZmeaS2P0ORL8QinnIsLtcjOVJoUULzbW1sELzgcaw7uA01sEvKMgrPYjHe0hDebJ(lkLncItXs46JoIGr)f7mSTgxF0rem6VWnIRbvzc9vGDYhidBRXFVtUp1i3iUguceZIfanqxahbTYjWc)zlSD)eYFVtUp1izlaUwYRmZqaWpBfDTKxfPPruQCsibMZeLudAwtkLncmSTgN5rxahVw0K149PZ4CwGlaUwYRmZqaWpBfDTKxfPPruQCsibMZebEhnRjLYgbXPyjCMhDbC8ArtwJ3NoJBNC9D0X1T4mp6c441IMSgVpDgN)ijpldX7RaYwaCTKxzMHaGF2k6AjVkstJOu5Kqchdnf8DjVsPSrGHT14atk1)41IT)mcNfODXPyj8JHMc(UKxTa4AjVYmdba)Sv01sEvKMgrPYjHeogAk47sEve4D0SMukBeeNILWpgAk47sELD9D0X1T4atk1)41IT)mc)rsEwgI3xblaUwYRmZqaWpBfDTKxfPPruQCsib)qLYgbxlzpmIfskrJYeSEbW1sELzgcaw7uA01sEvKMgrPYjHemIxd)hlalaG4cjshr(cj6N4sE1cGRL8kd3pKWJKU3Gu0yIDZsWFbW1sELH7hodbaprDD60Op65LgvkBeeNILWB)zeJwrbmUa4AjVYW9dNHaGB)zKOr(euujTIAkgf)NqXqOVszJG(o646w8hjDVbPOXe7MLGp)rsEwgItWAIYKEyxCkwcFYfW4N1u0i3tAbW1sELH7hodbad(6sZAkYqDJOu2iWW2A8pjHCwGlaUwYRmC)Wzia4JHMc(UGkLncd0fWrVgXbQDf5sQbnRj76RhwEj8kNalXMJ2zyBn(aDbSjoyrUrCnOeNiwaCTKxz4(HZqaWT)mIrROagvkBeyyBnoOjLM1uKKRbNfYF01IDYb0aDbC0RrCGAxrUKAqZAYU(6HLxcVYjWsS5OflasF9WYlHx5eyj2CKSfaxl5vgUF4mea8e11PtJ(ONxAuPSr4zRuhbEDXNpWwQtH4K3NyZioflH)SvQJUiyX6sEfrXgKTa4AjVYW9dNHaGB)zKOr(euujTIAkgf)NqXqOVszJWZwPoc86IpFGTuNcXjVpXMrCkwc)zRuhDrWI1L8kIIniBbW1sELH7hodba3(ZigTIcyuPSraqd0fWrVgXbQDf5sQbnRj76RhwEj8kNalXMJwSai91dlVeELtGLyZXfaxl5vgUF4mea8XqtbFxqL0kQPyu8FcfdH(kLncpBL6iWRl(8b2sDkktU1eBgXPyj8NTsD0fblwxYRik2GSfaxl5vgUF4mea8e11PtJ(ONxACbW1sELH7hodba3(ZirJ8jOOsAf1umk(pHIHq)faxl5vgUF4meam47R41IDZsWFbW1sELH7hodba7V2lmk3)yjlalaG4cN9rxaVWRTq1SgVpDgFHaVJM10c)tCjVAH2CHgXFXSW(kWSqgSDpUWzp1fMMf698K6muCbW1sELHZCMiW7Oznra81LM1uKH6grPSrGHT14Fsc5SaxaCTKxz4mNjc8oAwtZqaWps6EdsrJj2nlbFLYgbxlzpmIfskrJYeS2ILNTqUKKWOCrIrCct6HDYfNILWNCbm(znfnY9KSyrF1Gnfo2d)2FgXILNTW29tiNjLSMI6JoiBbaex4CX)juIzJajVJ2K8bYW2A837K7tnYnIRbDM(Krut(azyBn(7DY9Pg5psYZYmtFYikd0fWrqRCcSWF2cB3pH837K7tnoFHeDei6IzH(cPNO0cfWPzHPzHzjynWXcLBHI)tOSqbmUqW5ey0ile4N3NIIlelKKIlSBkGxOxl0zsAkkUqbSllSBsPl0bcKQ4cFVtUp14cZ2cF2cB3pHd(cTfSllKbZAAHETqSqskUWUPaEHkyHgX1GAuAH3VqVwiwijfxOa2LfkGXfoqg2wBHDtkDHM7QfIDey(4cVIVa4AjVYWzote4D0SMMHaGpgAk47cQKwrnfJI)tOyi0xPSr4zRuhbEDXNpWwQtrzcwtSfaxl5vgoZzIaVJM10mea8e11PtJ(ONxAuPSr4zRuhbEDXNpWwQtH4wRa7gGiLgf)NqXWNOUoDA0h98sJktWA767OJRBXbMuQ)XRfB)ze(JK8SmktSfaxl5vgoZzIaVJM10meaC7pJenYNGIkPvutXO4)ekgc9vkBeE2k1rGxx85dSL6uiU1kWU(o646wCGjL6F8AX2FgH)ijplJYeBbW1sELHZCMiW7Oznndba3(ZigTIcyuPSrGHT14GMuAwtrsUgCwi)rxl2F2k1rGxx85dSL6uuM8(eBgXPyj8NTsD0fblwxYRik2Gm7gGiLgf)NqXWB)zeJwrbmQmbRTtodBRXhOlGnXblYnIRbLGcXIfanqxah9AehO2vKlPg0SMSybq6RhwEj8kNalXMJKTa4AjVYWzote4D0SMMHaGB)zeJwrbmQu2i8SvQJaVU4Zhyl1POmbYTbXMrCkwc)zRuhDrWI1L8kIIniZUbisPrX)jum82FgXOvuaJktWA7KZW2A8b6cytCWICJ4AqjOqSybqd0fWrVgXbQDf5sQbnRjlwaK(6HLxcVYjWsS5izlaUwYRmCMZebEhnRPzia4JHMc(UGkPvutXO4)ekgc9vkBeE2k1rGxx85dSL6uuMa52GyZioflH)SvQJUiyX6sEfrXgKTa4AjVYWzote4D0SMMHaGNOUoDA0h98sJkLnc67OJRBXbMuQ)XRfB)ze(JK8Smk)SfYLKegLlse2F2k1rGxx85dSL6uiorOa7gGiLgf)NqXWNOUoDA0h98sJktW6faxl5vgoZzIaVJM10meaC7pJenYNGIkPvutXO4)ekgc9vkBe03rhx3IdmPu)Jxl2(Zi8hj5zzu(zlKljjmkxKiS)SvQJaVU4Zhyl1PqCIqblalaG4cN9rxaVWRTq1SgVpDgFHejTK9Wfs0pXL8Qfaxl5vgoZzIsQbnRjchdnf8DbvsROMIrX)jume6Ru2i8SvQJaVU4Zhyl1POmbqGcwaCTKxz4mNjkPg0SMMHaGFK09gKIgtSBwc(kLncItXs4tUag)SMIg5EswSOVAWMch7HF7pJyXYZwy7(jKZKswtr9rhwS4Aj7HrSqsjAuMG1laUwYRmCMZeLudAwtZqaWGVU0SMImu3ikLncmSTg)tsiNfODYF2k1rGxx85dSL6uioXiMflpBHCjjHr5I2G4eM0dlwmarknk(pHIHd(6sZAkYqDJOmbRjBbW1sELHZCMOKAqZAAgca(yOPGVlOsAf1umk(pHIHqFLYgHNTqUKKWOCrIG4t6HflpBL6iWRl(8b2sDkktGii2cGRL8kdN5mrj1GM10meaC7pJy0kkGrLYgbg2wJdAsPznfj5AWzHCwG2narknk(pHIH3(ZigTIcyuzcwBNCanqxah9AehO2vKlPg0SMSRVEy5LWRCcSeBoAXcG0xpS8s4vobwInhjBbW1sELHZCMOKAqZAAgcag89v8AXUzj4Ru2i8SvQJaVU4Zhyl1POmbIqb2F2c5sscJYfTHYt6XcGRL8kdN5mrj1GM10meaC7pJy0kkGrLYgbdqKsJI)tOy4T)mIrROagvMG12jNHT14d0fWM4Gf5gX1GsqHyXcGgOlGJEnIdu7kYLudAwtwSai91dlVeELtGLyZrYwaCTKxz4mNjkPg0SMMHaGpgAk47cQKwrnfJI)tOyi0xPSr4zRuhbEDXNpWwQtrzRjM9NTqLTXcGRL8kdN5mrj1GM10meam4RlnRPid1nIszJadBRX)KeYzbUa4AjVYWzotusnOznndba7V2lmk3)yjkLncpBL6iWRl(8b2sDkktmfSaSaaIG4c7Wrhleeg0FzHD4Qrk5vMfaqeexORL8kdxF0rem6Vqqd2ZYeVwm1OszJqlNalXhj5zzi(KESaaIluHEdUWb7N10c70jL6)c7Mc4fs00O2bc4zF0fWlaUwYRmC9rhrWO)YmeaSgSNLjETyQrLYgbajoflHFm0uW3L8k7mSTghysP(hVwS9Nr4psYZYqCByNHT14atk1)41IT)mcNfODg2wJRp6icg9x4gX1GQmH(kybaexiieRyYbUWRTWoDsP(Vqwd6t4c7Mc4fs00O2bc4zF0fWlaUwYRmC9rhrWO)YmeaSgSNLjETyQrLYgbajoflHFm0uW3L8k7d0fWrqRCcSWF2cB3pH8MtPyf1pRXh4BhqmSTghysP(hVwS9Nr4SaTtodBRX1hDebJ(lCJ4AqvMqFqGDg2wJZwGpQIrJ8ynjG5SaTyHHT146JoIGr)fUrCnOktOprLD9D0X1T4atk1)41IT)mc)rsEwgL7RaYwaCTKxz46JoIGr)Lziaynyplt8AXuJkLncasCkwc)yOPGVl5v2b0aDbCe0kNal8NTW29tiV5ukwr9ZA8b(2zyBnU(OJiy0FHBexdQYe6Ra7aIHT14atk1)41IT)mcNfOD9D0X1T4atk1)41IT)mc)rsEwgLTwblaG4c70p2dlzHD4OJfccd6VSWRh(AhiWSMw4G9ZAAHatk1)faxl5vgU(OJiy0Fzgcawd2ZYeVwm1OszJG4uSe(XqtbFxYRSdig2wJdmPu)Jxl2(ZiCwG2jNHT146JoIGr)fUrCnOktOpiWodBRXzlWhvXOrESMeWCwGwSWW2AC9rhrWO)c3iUguLj0NOYIf9D0X1T4atk1)41IT)mc)rsEwgIBd7mSTgxF0rem6VWnIRbvzc9jcYwawaaXf2PpjVAbW1sELHRVJoUULzgcag4j5vkLncmSTghysP(hVwS9Nr4SaTZW2ACKeWRl(XNTWyx0bEfNf4caiUWoChDCDlZcGRL8kdxFhDCDlZmeamsc41f)4ZwySl6aVsPSrqCkwc)yOPGVl5v2jxFhDCDloWKs9pETy7pJWF0hkA)zlKljjmkxKykpPh2F2k1rGxx85dSL6uuMqFfyXcdBRXbMuQ)XRfB)zeolq7pBHCjjHr5Iet5j9GmlwA5eyj(ijpldXTwblaUwYRmC9D0X1TmZqaWijGxx8JpBHXUOd8kLYgbXPyjCMhDbC8ArtwJ3NoJB)zRuhbEDXNpWwQtrzIqb2F2c5sscJYfjMYt6HDYzyBnoZJUaoETOjRX7tNX5SaTyPLtGL4JK8Sme3Afq2cGRL8kdxFhDCDlZmeamsc41f)4ZwySl6aVsPSrqCkwcp1O2bA)zlK42ybW1sELHRVJoUULzgcagysP(hVwS9NrukBeeNILWzE0fWXRfnznEF6mUDY13rhx3IZ8OlGJxlAYA8(0zC(JK8SmwSOVJoUUfN5rxahVw0K149PZ48h9HI2F2k1rGxx85dSL6uioiqbKTa4AjVYW13rhx3YmdbadmPu)Jxl2(ZikLncItXs4Pg1oq7aIHT14atk1)41IT)mcNf4cGRL8kdxFhDCDlZmeamWKs9pETy7pJOu2iioflHFm0uW3L8k7KloflHp5cy8ZAkAK7jXXYzO4WodBRXFK09gKIgtSBwc(CwGwSaiXPyj8jxaJFwtrJCpjowodfhKTa4AjVYW13rhx3YmdbaZ8OlGJxlAYA8(0zCLYgbg2wJdmPu)Jxl2(ZiCwGlaUwYRmC9D0X1TmZqaWT)msxfFsMyJ9vuPSrGHT14atk1)41IT)mc)rsEwgIpPh2zyBnoWKs9pETy7pJWzbAhqItXs4hdnf8DjVAbW1sELHRVJoUULzgcaU9Nr6Q4tYeBSVIkLncUwYEyelKuIgLjyTDYzyBnoWKs9pETy7pJWzbANHT14atk1)41IT)mc)rsEwgIpPhwS8EoIypSeUpggo2X0ig7VNJi2dlH7JHH)ijpldXN0dlwA5eyj(ijpldXN0dYwaCTKxz467OJRBzMHaGB)zKUk(KmXg7ROszJG4uSe(XqtbFxYRSdig2wJdmPu)Jxl2(ZiCwG2jNCg2wJZwGpQIrJ8ynjG5SaTybqd0fWrqRCcSWF2cB3pH8MtPyf1pRXh4tMDYhidBRXFVtUp1i3iUguceZIfanqxahbTYjWc)zlSD)eYFVtUp1izKTa4AjVYW13rhx3YmdbadwrGNagFsPoc8rdwAuPSrqCkwcN5rxahVw0K149PZ42F2k1rGxx85dSL6uuMiuG9NTqLjyd7mSTghysP(hVwS9Nr4SaTybqItXs4mp6c441IMSgVpDg3(ZwPoc86IpFGTuNIYeSMylaUwYRmC9D0X1TmZqaWVNgmoqFOu2iWW2ACGjL6F8AX2FgHZcCbW1sELHRVJoUULzgca246pBPoDAeORfLYgbxlzpmIfskrJYeS2o5arHpb(yP8hj5zzi(KEyXI4)ekCjjHr5IJej(KEq2cGRL8kdxFhDCDlZmea8aDbC0RrCGAxrLYgbxlzpmIfskrJYeZILNTW29tihiy0)J0vOzbybaexyhUEy5LSqIetstjrZcGRL8kdxF9WYlXqyGUa2ehSOszJW75iI9Ws4(yy4zPCFIzXcGEphrShwc3hddh7yAeJflUwYEyelKuIgLjy9cGRL8kdxF9WYlXmdbaB66pPSMIKsJOu2i4Aj7HrSqsjAi03(ZwPoc86IpFGTuNIY2WU(o646wCGjL6F8AX2FgH)ijpldXTHDajoflHZ8OlGJxlAYA8(0zC7KdO3Zre7HLW9XWWXoMgXyXY75iI9Ws4(yy4zPCFIr2cGRL8kdxF9WYlXmdbaB66pPSMIKsJOu2i4Aj7HrSqsjAuMG12bK4uSeoZJUaoETOjRX7tNXxaCTKxz46RhwEjMziaytx)jL1uKuAeLYgbXPyjCMhDbC8ArtwJ3NoJBNCg2wJZ8OlGJxlAYA8(0zColq7K7Aj7HrSqsjAi03(ZwPoc86IpFGTuNIYeHcSyX1s2dJyHKs0OmbRT)SvQJaVU4Zhyl1POmiqbKzXcGyyBnoZJUaoETOjRX7tNX5SaTRVJoUUfN5rxahVw0K149PZ48hj5zziBbW1sELHRVEy5LyMHaGDMJuwUKxfPjjgLYgbxlzpmIfskrdH(213rhx3IdmPu)Jxl2(Zi8hj5zziUnStoGEphrShwc3hddh7yAeJflVNJi2dlH7JHHNLY9jgzlaUwYRmC91dlVeZmeaSZCKYYL8QinjXOu2i4Aj7HrSqsjAuMG1laUwYRmC91dlVeZmeaSbSRbLIrbmgzRU3lGvuPSrW1s2dJyHKs0qOVD9D0X1T4atk1)41IT)mc)rsEwgIBd7KdO3Zre7HLW9XWWXoMgXyXY75iI9Ws4(yy4zPCFIr2cGRL8kdxF9WYlXmdbaBa7AqPyuaJr2Q79cyfvkBeCTK9WiwiPenktW6fGfaqCHGqm0uW3L8Qf(N4sE1cGRL8kd)yOPGVl5veEK09gKIgtSBwc(kLncUwYEyelKuIgLjyd7KloflHp5cy8ZAkAK7jzXI(QbBkCSh(T)mIflpBHT7Nqotkznf1hDq2cGRL8kd)yOPGVl5vZqaWGVU0SMImu3ikLncaACcV9NrInSh(Cj1GM1KDaXW2ACqtknRPijxdolKZcCbW1sELHFm0uW3L8Qzia42FgXOvuaJkLncmSTgh0KsZAksY1GZc5p6AXUbisPrX)jum82FgXOvuaJktWA7KZW2A8b6cytCWICJ4AqjOqSybqd0fWrVgXbQDf5sQbnRjlwaK(6HLxcVYjWsS5izlaUwYRm8JHMc(UKxndbaFm0uW3fujTIAkgf)NqXqOVszJadBRXbnP0SMIKCn4Sq(JUwSybqmSTg)tsiNfODdqKsJI)tOy4GVU0SMImu3iktWglaUwYRm8JHMc(UKxndbaprDD60Op65LgvkBemarknk(pHIHprDD60Op65LgvMG12j)zRuhbEDXNpWwQtH49vGflpBHCjjHr5IwR8KEqMflKpqg2wJ)ENCFQrUrCnOeNywSmqg2wJ)ENCFQr(JK8SmeVpXiBbW1sELHFm0uW3L8Qzia42FgjAKpbfvkBe0xnytHJVpsTlznfzOxx7mSTghFFKAxYAkYqVUCJ4AqjyTDxlzpmIfskrdH(laUwYRm8JHMc(UKxndbad(6sZAkYqDJOu2iWW2A8pjHCwG2narknk(pHIHd(6sZAkYqDJOmbRxaCTKxz4hdnf8DjVAgcaEI660PrF0ZlnQu2iyaIuAu8FcfdFI660PrF0ZlnQmbRxaCTKxz4hdnf8DjVAgcaU9NrIg5tqrL0kQPyu8FcfdH(kLncasCkwc375uV0Gr7aIHT14GMuAwtrsUgCwiNfOflItXs4EpN6LgmAhqmSTg)tsiNf4cGRL8kd)yOPGVl5vZqaWGVU0SMImu3ikLncmSTg)tsiNf4cGRL8kd)yOPGVl5vZqaWhdnf8DbvsROMIrX)jume6VaSaaIlStFhnRPf2PUFHGqm0uW3L8kBUqvXFXSW(kyHguF1WSqgSDpUWoDsP(VWRTWo1FgzH6JeAw41AlSdk0waCTKxz4hdnf8DjVkc8oAwteEK09gKIgtSBwc(kLncItXs4tUag)SMIg5EswSOVAWMch7HF7pJyXYZwy7(jKZKswtr9rhwS4Aj7HrSqsjAuMG1laUwYRm8JHMc(UKxfbEhnRPziayWxxAwtrgQBeLYgbg2wJ)jjKZcCbW1sELHFm0uW3L8QiW7OznndbaFm0uW3fujTIAkgf)NqXqOVszJadBRXbnP0SMIKCn4Sq(JUwwaCTKxz4hdnf8DjVkc8oAwtZqaWtuxNon6JEEPrLYgbdqKsJI)tOy4tuxNon6JEEPrLjyT9NTsDe41fF(aBPofIdcuWcGRL8kd)yOPGVl5vrG3rZAAgcaU9NrIg5tqrL0kQPyu8FcfdH(kLncpBL6iWRl(8b2sDkexHPGfaxl5vg(XqtbFxYRIaVJM10mea8XqtbFxqL0kQPyu8FcfdH(kLncpBHktelaUwYRm8JHMc(UKxfbEhnRPzia42FgXOvuaJkLncUwYEyelKuIgLjqe2jhqd0fWrVgXbQDf5sQbnRj76RhwEj8kNalXMJwSai91dlVeELtGLyZrYwawaaXfs0DD60fsKysAkjAwaCTKxz4VRtNAiWqVBeBSVIkLncmSTghysP(hVwS9Nr4SaxaCTKxz4VRtNAMHaGzW3GpOznPu2iWW2ACGjL6F8AX2FgHZcCbW1sELH)UoDQzgca2FTxyeil1GkLncKdig2wJdmPu)Jxl2(ZiCwG2DTK9WiwiPenktWAYSybqmSTghysP(hVwS9Nr4SaTt(ZwiFGTuNIYeiM9NTsDe41fF(aBPofLjacuazlaUwYRm831PtnZqaW0CcSyIk0XoMiHLOu2iWW2ACGjL6F8AX2FgHZcCbW1sELH)UoDQzgca2lnAK3PrTtPkLncmSTghysP(hVwS9Nr4SaTZW2ACKeWRl(XNTWyx0bEfNf4cGRL8kd)DD6uZmeaClFKHE3qPSrGHT14atk1)41IT)mc)rsEwgItqHyNHT14ijGxx8JpBHXUOd8kolWfaxl5vg(760PMziaygFkETO8PguJszJadBRXbMuQ)XRfB)zeolq7UwYEyelKuIgc9TtodBRXbMuQ)XRfB)ze(JK8SmeNy2fNILW1hDebJ(lCSCgkoSybqItXs46JoIGr)fowodfh2zyBnoWKs9pETy7pJWFKKNLH42GSfGfaqCHQIxd)hl0K1efbHl(pHYc)tCjVAbW1sELHBeVg(pi8iP7nifnMy3Se8vkBeeNILWNCbm(znfnY9KSyrF1Gnfo2d)2FgXILNTW29tiNjLSMI6JowaCTKxz4gXRH)Jzia4jQRtNg9rpV0OszJaGgOlGJGw5eyH)Sf2UFc5V3j3NA0o5dKHT14V3j3NAKBexdkXjMfldKHT14V3j3NAK)ijpldXvyKTa4AjVYWnIxd)hZqaWT)ms0iFckQu2iOVJoUUf)rs3BqkAmXUzj4ZFKKNLH4eSMOmPh2fNILWNCbm(znfnY9KwaCTKxz4gXRH)Jzia42FgjAKpbfvkBe0xnytHJVpsTlznfzOxx7mSTghFFKAxYAkYqVUCJ4AqjyTfl6RgSPWzlk6gW4i2ES6efTZW2AC2IIUbmoIThRorr(JK8Sme3g2zyBnoBrr3aghX2JvNOiNf4cGRL8kd3iEn8Fmdbad(6sZAkYqDJOu2iWW2A8pjHCwGlaUwYRmCJ41W)Xmea8XqtbFxqLYgbaXW2A82FDcwrGSudYzbAxCkwcV9xNGveil1GwSWW2ACqtknRPijxdolK)ORflwgOlGJEnIdu7kYLudAwt21xpS8s4vobwInhTZW2A8b6cytCWICJ4AqvwHyXYZwixssyuUirqCct6XcGRL8kd3iEn8Fmdba3(ZirJ8jOOszJWZwPoc86IpFGTuNcXjVpXMrCkwc)zRuhDrWI1L8kIIniBbW1sELHBeVg(pMHaGpgAk47cQu2i8SvQJaVU4Zhyl1POm5wtSzeNILWF2k1rxeSyDjVIOydYwaCTKxz4gXRH)Jzia42FgjAKpbfxaCTKxz4gXRH)JziayW3xXRf7MLG)cGRL8kd3iEn8Fmdba7V2lmk3)yjlalaG4cT9ZcuumlaUwYRmC5ZcuumeYYOFwXzOyuHZ6LWskoWEPgvkBeyyBnoWKs9pETy7pJWzbAXI4)ekCjjHr5Ia1s0AfqCIzXslNalXhj5zziU19xaCTKxz4YNfOOyMHaGznymfKKrPSrGHT14atk1)41IT)mcNfODYbK4uSeEQrTd0IfXPyj8uJAhODg2wJdmPu)Jxl2(Zi8hj5zzuMqFfq2caicIl0wW4cLplqrzHDtb8cfW4cbNtGrJSq0ijjxWXc75uwuPf2nP0fYGlK1GJf2Y3il0RXcb65JJf2nfWlStNuQ)l8AlSt9Nr4laGiiUqxl5vgU8zbkkMziaywdgtbjPKHEcb5Zcuu6Ru2iaOE(Nodf5gGOoBjoIYNfOOyNHT14atk1)41IT)mcNfODYbK4uSeEQrTd0IfXPyj8uJAhODg2wJdmPu)Jxl2(Zi8hj5zzuMqFfqMDYbK8zbkkCR5GDtuFhDCDllwKplqrHBnxFhDCDl(JK8SmwS0Z)0zOix(SafLiWpVpffj0NmlwKplqrH3Nd8pn3lfJdGg(G9DjVszcTCcSeFKKNLzbaebXf6AjVYWLplqrXmdbaZAWykijLm0tiiFwGII1kLncaQN)PZqrUbiQZwIJO8zbkk2zyBnoWKs9pETy7pJWzbANCajoflHNAu7aTyrCkwcp1O2bANHT14atk1)41IT)mc)rsEwgLj0xbKzNCajFwGIcVphSBI67OJRBzXI8zbkk8(C9D0X1T4psYZYyXsp)tNHIC5ZcuuIa)8(uuKG1KzXI8zbkkCR5a)tZ9sX4aOHpyFxYRuMqlNalXhj5zzwaarqCHeT2cVIQ4cVcx4vlK1Glu(SafLfc8VE5anl0xidBRP0czn4cfW4cpbm(l8QfQVJoUUfFHGq)cZ2clmfW4Vq5ZcuuwiW)6Ld0SqFHmSTMslK1GlK5eWl8QfQVJoUUfFbaebXf6AjVYWLplqrXmdbaZAWykijLm0tiiFwGIsFLYgbajFwGIcVphSBISgmYW2A2jx(SaffU1C9D0X1T4psYZYyXcGKplqrHBnhSBISgmYW2AKzXI(o646wCGjL6F8AX2FgH)ijplJYwRGfaqeexORL8kdx(SaffZmeamRbJPGKuYqpHG8zbkkwRu2iai5Zcuu4wZb7MiRbJmSTMDYLplqrH3NRVJoUUf)rsEwglwaK8zbkk8(CWUjYAWidBRrMfl67OJRBXbMuQ)XRfB)ze(JK8SmkBTccQgGOoyL1eRFqcsia]] )


end
