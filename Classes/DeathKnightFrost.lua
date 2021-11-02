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


    spec:RegisterPack( "Frost DK", 20211101, [[d4uybdqiaLhjPexIkr1MOI(KkvJcf6uOiRcOIELKkZcLQBHckSlc)cq1Wqr1XuPSmukpJkvMgqLUgkkBdfK(gqfmojfPZjPiwNKcZdOQ7Hs2NKOdsLiTqjv9qQu1ePseCruq0gbQqFKkr0iPse6KOGQvcuEjkOOMPKsTtQK(PKsQHIcclLkr5Pe1uLeUkkOi9vuqPXIcSxr9xrgmOdtzXq6Xu1KvXLr2SeFgGrdKtlSAuqr8Aaz2qDBiSBP(TQgUk54skjlxPNJQPt66ez7q03LKgpvcNNkL1lPOMpvy)koFlxrw(ykLDLnMZ2TB3y(nbB3ax2ax2YYQBxuw(Y8azaOSCBiOSm44(CDGUeyyolFzUHF7KRilZFP1tzzqQEXRbWboGqbjHk8pcGZdesytJV9RvuGZdeEGNLrLcSYW7mAw(ykLDLnMZ2TB3y(nbB3ax2ChdnlBskOFZYYbc3NLbfNd1z0S8H4(SSlbYuqdKH5oaashi44(CDaRw71hL2bYgdL9bYgZz72a2aM7bznaIpGXWyGUmcXJKodeBCLHbN8FFgOe3aqd8ld09GSO5d8ldKH7PbA8bg6appX776aVWMBdSkHXdm6bETMxdpjgWyymqxcFFxhOhK1nHhi4iM4G8Rv0bEK2ObmW6xYuqd8lduo6ZAaEUjYY4GR8Cfz5hfhkTMgFNU(hhnGCfzxVLRiltTHIPtU(SS5147S8si(LtyIZtvJwPnlFiUFJln(olZq8poAadeC83bwRrXHsRPX31yGYQTkFG3y(a5K)7dFGOu5xAGmebgB7a)Yabh3NRd0)ii(a)szGU3Lqw2VHsByzzK2ggkMeB1eQuPWhOdhd08AGKsuticIpWkznq2YA2v2YvKLP2qX0jxFw2VHsByzz(fHXj1waKYfaWMpmCYoiT2tdSswdKTb6CGQHPwfL95k37McIeuBOy6KLnVgFNLbGnFy4KDqATNYA2v3LRiltTHIPtU(SSFdL2WYYOsLIaOaJJgqcH5bfnjwY86aDoqZRbskrnHii(aRCGSnqNdeydePTHHIjXHmfepDKOK51ajLLnVgFNLl7ZvU3nfeL1SRGBUISm1gkMo56ZYMxJVZYpkouAnLYY(nuAdllJkvkcGcmoAajeMhu0KyjZRzzVBEmLuBbqkp76TSMDLz5kYYuBOy6KRpl73qPnSSS51ajLOMqeeFGSg4Tb6CGiTnmumjk7Z1ex3aik5)(ifkplBEn(olx2NRjUUbquwZUYqZvKLP2qX0jxFw28A8Dw(rXHsRPuw2VHsByzzuPsrauGXrdiHW8GIMelzEnl7DZJPKAlas5zxVL1SRGd5kYYuBOy6KRpl73qPnSSmsBddftI91IpTbcklBEn(old6RIJgqcfBCnRzxRP5kYYuBOy6KRpl73qPnSSm)IW4KAlas5cayZhgozhKw7PbwjRbY2aDoWvQdF66RsR4qLWh6ab)azOmplBEn(oldaB(WWj7G0ApL1SR1KCfzzQnumDY1NLnVgFNLl7Z1ex3aikl73qPnSS8k1HpD9vPvCOs4dDGGFGGdmpl7DZJPKAlas5zxVL1SR3yEUISm1gkMo56ZYMxJVZYpkouAnLYY(nuAdllVsnnWkznq3LL9U5XusTfaP8SR3YA21B3YvKLP2qX0jxFw2VHsByzzZRbskrnHii(aRK1ab3b6CGaBGiTnmumjoKPG4PJeLmVgiPSS5147SCzFUY9UPGOSM1SS)XNeiYwnxr21B5kYYuBOy6KRplBEn(ol7bzrZtFjfEklFiUFJln(olZWuonWJ0gnGbYqeySTdSAOGgid3tE7c41VKPGYY(nuAdlldSbQgMAv8O4qP104Bb1gkMod05arLkfXvGX2M(sQSpxfsxd05arLkfH)XNeiYwvWvZd0aRK1aVX8b6CGmoquPsrCfySTPVKk7ZvXsiSO5de8deG)mqW5azCG3gyDd0)p(8vBrzFUw1TfbpvKw3elzh3gitd0HJbIkvkcPg0JDlX1LAakiXsiSO5de8deG)mqhogiQuPi8GSNNqTMelHWIMpqWpqa(ZazkRzxzlxrwMAdftNC9zzZRX3zzpilAE6lPWtz5dX9BCPX3z5ATKYJdnWVmqgIaJTDGsCYaqdSAOGgid3tE7c41VKPGYY(nuAdlldSbQgMAv8O4qP104Bb1gkMod05apKPGsa1baqQyLAQ8lasummM6KFL42H2b6CGaBGOsLI4kWyBtFjv2NRcPRb6CG()XNVAlUcm220xsL95Qyjew08bw5aVXSb6CGmoquPsr4F8jbISvfC18anWkznWBmFGohiJdevQuesnOh7wIRl1auqcPRb6WXarLkfHhK98eQ1Kq6AGmnqhogiQuPi8p(Kar2QcUAEGgyLSg4n3nqMYA2v3LRiltTHIPtU(SSFdL2WYYaBGQHPwfpkouAnn(wqTHIPZaDoqGnWdzkOeqDaaKkwPMk)cGefdJPo5xjUDODGohiQuPi8p(Kar2QcUAEGgyLSg4nMpqNdeydevQuexbgBB6lPY(CviDnqNd0)p(8vBXvGX2M(sQSpxflHWIMpWkhiBmplBEn(ol7bzrZtFjfEkRzxb3CfzzQnumDY1NLnVgFNL9GSO5PVKcpLLpe3VXLgFNLziwcj16aD)Jpd0LizRoWhjTE76kAad8iTrdyGxbgBBw2VHsByzz1WuRIhfhkTMgFlO2qX0zGohiWgiQuPiUcm220xsL95Qq6AGohiJdevQue(hFsGiBvbxnpqdSswd8g4oqNdKXbIkvkcPg0JDlX1LAakiH01aD4yGOsLIWdYEEc1AsiDnqMgOdhdevQue(hFsGiBvbxnpqdSswd8wnzGoCmq))4ZxTfxbgBB6lPY(CvSeclA(ab)aD3aDoquPsr4F8jbISvfC18anWkznWBG7azkRznl)O4qP1047CfzxVLRiltTHIPtU(SS5147S8si(LtyIZtvJwPnlFiUFJln(olxRrXHsRPX3dCF1047SSFdL2WYYMxdKuIAcrq8bwjRb6Ub6CGiTnmumj2QjuPsHN1SRSLRiltTHIPtU(SSFdL2WYYaBGOsLIaOaJJgqcH5bfnjKUgOZbUsnnWkznq3nqNdKXbIkvkInqqILqyrZhi4hO7gOZbIkvkInqqcPRb6WXanVgiP05vrzFUMkesAhi4hO51ajLOMqeeFGmLLnVgFNLb9vXrdiHInUM1SRUlxrwMAdftNC9zz)gkTHLLb2arLkfbqbghnGecZdkAsiDnqNdKFryCsTfaPCbaS5ddNSdsR90aRK1azBGoCmqGnquPsrauGXrdiHW8GIMesxd05azCGhcvQueRvZ)gEsWvZd0ab)az2aD4yGhcvQueRvZ)gEsSeclA(ab)ab4pdeCoqWDGmLLnVgFNLbGnFy4KDqATNYA2vWnxrwMAdftNC9zz)gkTHLLrLkfbqbghnGecZdkAsSK51b6CG8lcJtQTaiLlk7ZvU3nfenWkhiBd05ab2arAByOysCitbXthjkzEnqszzZRX3z5Y(CL7Dtbrzn7kZYvKLP2qX0jxFw28A8Dw(rXHsRPuw2VHsByzzuPsrauGXrdiHW8GIMelzEnl7DZJPKAlas5zxVL1SRm0CfzzQnumDY1NL9BO0gww28AGKsuticIpqwd82aDoqK2ggkMeL95AIRBaeL8FFKcLNLnVgFNLl7Z1ex3aikRzxbhYvKLP2qX0jxFw2VHsByzzK2ggkMe7RfFAde0aDoq(fHXj1waKYfG(Q4ObKqXgxhyLSgiBzzZRX3zzqFvC0asOyJRzn7AnnxrwMAdftNC9zz)gkTHLL5xegNuBbqkxaaB(WWj7G0ApnWkznq2YYMxJVZYaWMpmCYoiT2tzn7AnjxrwMAdftNC9zzZRX3z5Y(CnX1naIYY(nuAdlldSbQgMAvyinS1EqKGAdftNb6CGaBGOsLIaOaJJgqcH5bfnjKUgOdhdunm1QWqAyR9Gib1gkMod05ab2arAByOysSVw8Pnqqd0HJbI02WqXKyFT4tBGGgOZbUsnj0abL0pX2aRK1ab4pzzVBEmLuBbqkp76TSMD9gZZvKLP2qX0jxFw2VHsByzzK2ggkMe7RfFAdeuw28A8Dwg0xfhnGek24AwZUE7wUISm1gkMo56ZYMxJVZYpkouAnLYYE38ykP2cGuE21BznRzzUA9X2tUISR3YvKLP2qX0jxFw28A8DwEje)YjmX5PQrR0MLpe3VXLgFNLLvRp2EgipAayIHHAlash4(QPX3zz)gkTHLLrAByOysSvtOsLcpRzxzlxrwMAdftNC9zz)gkTHLLrLkfbqbghnGecZdkAsSK51SS5147S8JIdLwtPSMD1D5kYYuBOy6KRpl73qPnSSmsBddftI91IpTbcAGohiQuPi2abjwcHfnFGGFGUllBEn(old6RIJgqcfBCnRzxb3CfzzQnumDY1NL9BO0gwwgPTHHIjrzFUM46garj)3hPq5zzZRX3z5Y(CnX1naIYA2vMLRiltTHIPtU(SSFdL2WYYaBGhYuqjG6aaivSsnv(fajwRM)n80aDoqgh4HqLkfXA18VHNeC18anqWpqMnqhog4HqLkfXA18VHNelHWIMpqWpqa(ZabNdeChitzzZRX3zzayZhgozhKw7PSMDLHMRiltTHIPtU(SSFdL2WYY()XNVAlwcXVCctCEQA0kTILqyrZhi4znq2gi4CGa8Nb6CGQHPwfamfeTrdiX1FriO2qX0jlBEn(olx2NRjUUbquwZUcoKRiltTHIPtU(SSFdL2WYYiTnmumj2xl(0giOSS5147SmOVkoAajuSX1SMDTMMRiltTHIPtU(SSFdL2WYYRuh(01xLwXHkHp0bc(bY4aVXSbw3avdtTkwPo8jtvQLmn(wqTHIPZabNdKzdKPSS5147SCzFUM46garzn7AnjxrwMAdftNC9zz)gkTHLLb2arLkfrz)AM60LeMtcPRb6CGQHPwfL9RzQtxsyojO2qX0zGoCmqK2ggkMehYuq80rIsMxdK0aDoquPsrCitbXthjsWvZd0ab)ab3b6WXavdtTkaykiAJgqIR)IqqTHIPZaDoquPsrSeIF5eM48u1OvAfsxd0HJbUsD4txFvAfhQe(qhyLdKXbYgZgyDdunm1QyL6WNmvPwY04Bb1gkModeCoqMnqMYYMxJVZYpkouAnLYA21Bmpxrw28A8DwUSpxtCDdGOSm1gkMo56ZA21B3YvKLnVgFNLb9BN(sQA0kTzzQnumDY1N1SR3ylxrw28A8Dw2wV1us)DPwZYuBOy6KRpRznlJ(8KgEGIgqUISR3YvKLP2qX0jxFw28A8Dw(rXHsRPuw27Mhtj1waKYZUEll73qPnSS8k1HpD9vPvCOs4dDGvYAGmoqWLzdSUbQgMAvSsD4tMQulzA8TGAdftNbcohiZgitz5dX9BCPX3z56xYuqd8lduo6ZAaEUnqxQxdK0aDzVAA8DwZUYwUISm1gkMo56ZY(nuAdllJ02WqXKyRMqLkf(aD4yGMxdKuIAcrq8bwjRbY2aD4yGRuh(01xL2bc(b6o2YYMxJVZYlH4xoHjopvnAL2SMD1D5kYYuBOy6KRpl73qPnSS8k1HpD9vPDGGFGUJTSS5147S8HmfuY6t6qEZTSMDfCZvKLP2qX0jxFw2VHsByzzK2ggkMe7RfFAde0aDoqgh4k1HpD9vPvCOs4dDGGFGmJzd0HJbUsnj0abL0p5UbcEwdeG)mqhog4k1u5xaKynau6ljfeLk7xZuN8GmexX3cQnumDgOdhdKFryCsTfaPCbOVkoAajuSX1bwjRbY2aD4yGOsLIydeKyjew08bc(b6UbY0aD4yGRuh(01xL2bc(b6o2YYMxJVZYG(Q4ObKqXgxZA2vMLRiltTHIPtU(SSFdL2WYYOsLIaOaJJgqcH5bfnjKUgOZbYVimoP2cGuUOSpx5E3uq0aRCGSnqNdeydePTHHIjXHmfepDKOK51ajLLnVgFNLl7ZvU3nfeL1SRm0CfzzQnumDY1NLnVgFNLFuCO0AkLL9BO0gwwgvQueafyC0asimpOOjXsMxZYE38ykP2cGuE21Bzn7k4qUISm1gkMo56ZY(nuAdllVsD4txFvAfhQe(qhyLSgi4Y8b6CGRutcnqqj9tUBGvoqa(tw28A8Dwg0VD6lPQrR0M1SR10CfzzQnumDY1NL9BO0gwwMFryCsTfaPCrzFUY9UPGObw5azBGohiWgisBddftIdzkiE6irjZRbsklBEn(olx2NRCVBkikRzxRj5kYYuBOy6KRplBEn(ol)O4qP1ukl73qPnSS8k1HpD9vPvCOs4dDGvoq2y2aD4yGRutcnqqj9tUBGGFGa8NSS3npMsQTaiLND9wwZUEJ55kYYuBOy6KRpl73qPnSSmsBddftI91IpTbcklBEn(old6RIJgqcfBCnRzxVDlxrwMAdftNC9zz)gkTHLLxPo8PRVkTIdvcFOdSYbYmMNLnVgFNLT1BnL0FxQ1SM1SS)rsT1kpxr21B5kYYuBOy6KRplBEn(olFitbXthjklFiUFJln(ol7(hj1wRd0LIg4qdINL9BO0gwwgPTHHIjbxtxyR7ObmqhogisBddftc7C4PLqyrN1SRSLRiltTHIPtU(SSFdL2WYYRuh(01xLwXHkHp0bw5aV5Ub6CG()XNVAlUcm220xsL95Qyjew08bc(b6Ub6CGaBGQHPwfOlzkO0xs8OpRb45MGAdftNb6CGiTnmumj4A6cBDhnGSS5147SmVQTiIgqcrW1SMD1D5kYYuBOy6KRpl73qPnSSmWgOAyQvb6sMck9Lep6ZAaEUjO2qX0zGohisBddftc7C4PLqyrNLnVgFNL5vTfr0asicUM1SRGBUISm1gkMo56ZY(nuAdllRgMAvGUKPGsFjXJ(SgGNBcQnumDgOZbY4arLkfb6sMck9Lep6ZAaEUjKUgOZbY4arAByOysW10f26oAad05axPo8PRVkTIdvcFOdSYbcUmFGoCmqK2ggkMe25WtlHWIEGoh4k1HpD9vPvCOs4dDGvoqgkZhOdhdePTHHIjHDo80siSOhOZbUwCsesQvHDoCXsiSO5de8dSMmqNdCT4KiKuRc7C4cYfbx5dKPb6WXab2arLkfb6sMck9Lep6ZAaEUjKUgOZb6)hF(QTaDjtbL(sIh9znap3elHWIMpqMYYMxJVZY8Q2IiAajebxZA2vMLRiltTHIPtU(SSFdL2WYY()XNVAlUcm220xsL95Qyjew08bc(b6Ub6CGiTnmumj4A6cBDhnGb6CGmoq1WuRc0Lmfu6ljE0N1a8CtqTHIPZaDoWvQdF66RsR4qLWh6ab)azOmFGohO)F85R2c0Lmfu6ljE0N1a8CtSeclA(ab)azBGoCmqGnq1WuRc0Lmfu6ljE0N1a8CtqTHIPZazklBEn(olBOpIOnn(oHdeOzn7kdnxrwMAdftNC9zz)gkTHLLrAByOysyNdpTecl6SS5147SSH(iI2047eoqGM1SRGd5kYYuBOy6KRpl73qPnSSmsBddftcUMUWw3rdyGohiJd0)p(8vBXvGX2M(sQSpxflHWIMpqWpq3nqhogOAyQvr4jVDjO2qX0zGmLLnVgFNL5GmpqykPGOKux9xfKBzn7AnnxrwMAdftNC9zz)gkTHLLrAByOysyNdpTecl6SS5147SmhK5bctjfeLK6Q)QGClRzxRj5kYYuBOy6KRpl73qPnSSmWgiQuPiUcm220xsL95Qq6AGohiWgiQuPiqxYuqPVK4rFwdWZnH01aDoqghi)LWOrFexsCvctjALU04Bb1gkMod0HJbYFjmA0hbYhBAGPe)XiPwfuBOy6mqMYYrR0UsxAkkzz(lHrJ(iq(ytdmL4pgj1AwoAL2v6stbce0jmLYY3YYMxJVZYfmXb5xROz5OvAxPlnba)OgolFlRznl7)hF(Qnpxr21B5kYYuBOy6KRpl73qPnSSmQuPiUcm220xsL95Qq6klFiUFJln(olZq8A8Dw28A8Dw(6147SMDLTCfzzQnumDY1NLnVgFNLjexFvAtRutPQKD9Dw(qC)gxA8Dw29)JpF1MNL9BO0gwwwnm1Q4rXHsRPX3cQnumDgOZbUsnnqWpqg6aDoqghisBddftcUMUWw3rdyGoCmqK2ggkMe25WtlHWIEGmnqNdKXb6)hF(QT4kWyBtFjv2NRILqyrZhi4hiZgOZbY4a9)JpF1wuWehKFTIkwcHfnFGvoqMnqNdK)sy0OpIljUkHPeTsxA8TGAdftNb6WXab2a5Vegn6J4sIRsykrR0LgFlO2qX0zGmnqhogiQuPiUcm220xsL95Qq6AGmnqhogi6Z5d05albaqAAjew08bc(bYgZZA2v3LRiltTHIPtU(SSFdL2WYYQHPwfOlzkO0xs8OpRb45MGAdftNb6CGRuh(01xLwXHkHp0bw5aDhZhOZbUsnj0abL0pXSbw5ab4pd05azCGOsLIaDjtbL(sIh9znap3esxd0HJbwcaG00siSO5de8dKnMpqMYYMxJVZYeIRVkTPvQPuvYU(oRzxb3CfzzQnumDY1NL9BO0gwwwnm1Qi8K3UeuBOy6KLnVgFNLjexFvAtRutPQKD9DwZUYSCfzzQnumDY1NL9BO0gwwwnm1QaDjtbL(sIh9znap3euBOy6mqNdKXbI02WqXKGRPlS1D0agOdhdePTHHIjHDo80siSOhitd05azCG()XNVAlqxYuqPVK4rFwdWZnXsiSO5d0HJb6)hF(QTaDjtbL(sIh9znap3elzh3gOZbUsD4txFvAfhQe(qhi4hiZy(azklBEn(olFfySTPVKk7Z1SMDLHMRiltTHIPtU(SSFdL2WYYQHPwfHN82LGAdftNb6CGaBGOsLI4kWyBtFjv2NRcPRSS5147S8vGX2M(sQSpxZA2vWHCfzzQnumDY1NL9BO0gwwwnm1Q4rXHsRPX3cQnumDgOZbUsD4txFvAhyLSgiBmBGohiJdePTHHIjbxtxyR7ObmqhogisBddftc7C4PLqyrpqMgOZbY4avdtTkaykiAJgqIR)IqqTHIPZaDoquPsrSeIF5eM48u1OvAfsxd0HJbcSbQgMAvaWuq0gnGex)fHGAdftNbYuw28A8Dw(kWyBtFjv2NRzn7AnnxrwMAdftNC9zz)gkTHLLrLkfXvGX2M(sQSpxfsxzzZRX3zz0Lmfu6ljE0N1a8ClRzxRj5kYYuBOy6KRpl73qPnSSS51ajLOMqeeFGSg4Tb6CGOsLI4kWyBtFjv2NRILqyrZhi4hia)zGohiQuPiUcm220xsL95Qq6AGohiWgOAyQvXJIdLwtJVfuBOy6mqNdKXbcSbUwCsesQvHDoCb5IGR8b6WXaxlojcj1QWohUi6bw5aDhZhitd0HJbwcaG00siSO5de8d0DzzZRX3z5Y(CTQBlcEQiTUL1SR3yEUISm1gkMo56ZY(nuAdllBEnqsjQjebXhyLSgiBd05azCGOsLI4kWyBtFjv2NRcPRb6WXaxlojcj1QWohUGCrWv(aDoW1ItIqsTkSZHlIEGvoq))4ZxTfxbgBB6lPY(CvSeclA(aRBGGddKPb6CGmoquPsrCfySTPVKk7ZvXsiSO5de8deG)mqhog4AXjriPwf25WfKlcUYhOZbUwCsesQvHDoCXsiSO5de8deG)mqMYYMxJVZYL95Av3we8urADlRzxVDlxrwMAdftNC9zz)gkTHLLvdtTkEuCO0AA8TGAdftNb6CGOsLI4kWyBtFjv2NRcPRb6CGmoqghiQuPiUcm220xsL95Qyjew08bc(bcWFgOdhdevQuesnOh7wIRl1auqcPRb6CGOsLIqQb9y3sCDPgGcsSeclA(ab)ab4pdKPb6CGmoWdHkvkI1Q5Fdpj4Q5bAGSgiZgOdhdeyd8qMckbuhaaPIvQPYVaiXA18VHNgitdKPSS5147SCzFUw1TfbpvKw3YA21BSLRiltTHIPtU(SSFdL2WYYQHPwfOlzkO0xs8OpRb45MGAdftNb6CGRuh(01xLwXHkHp0bw5abxMpqNdCLAAGGN1aD3aDoqghiQuPiqxYuqPVK4rFwdWZnH01aD4yG()XNVAlqxYuqPVK4rFwdWZnXsiSO5dSYbcUmFGmnqhogiWgOAyQvb6sMck9Lep6ZAaEUjO2qX0zGoh4k1HpD9vPvCOs4dDGvYAGSXSSS5147Smi3UEfeTicF6Ajo1EkRzxV5UCfzzQnumDY1NL9BO0gww2)p(8vBXvGX2M(sQSpxflHWIMpqWZAGmllBEn(olVwWP0HStwZUEdCZvKLP2qX0jxFw2VHsByzzZRbskrnHii(aRK1azBGohiJdSeaaPPLqyrZhi4hO7gOdhdeydevQueOlzkO0xs8OpRb45Mq6AGohiJd8IubaqVewSeclA(ab)ab4pd0HJbUwCsesQvHDoCb5IGR8b6CGRfNeHKAvyNdxSeclA(ab)aD3aDoW1ItIqsTkSZHlIEGvoWlsfaa9syXsiSO5dKPbYuw28A8DwMB(nkHpmC6Y8AwZUEJz5kYYuBOy6KRpl73qPnSSS51ajLOMqeeFGvoqMnqhog4k1u5xaK4cez7J4BIlO2qX0jlBEn(olFitbLS(KoK3ClRznlJ(801)4ObKRi76TCfzzQnumDY1NLnVgFNLxcXVCctCEQA0kTz5dX9BCPX3z56xYuqd8lduo6ZAaEUnWR)XrdyG7RMgFpWAmqUARYh4nMZhikv(Lgy9V8ad(anKwGnumLL9BO0gww28AGKsuticIpWkznq2gOdhdePTHHIjXwnHkvk8SMDLTCfzzQnumDY1NLnVgFNLFuCO0AkLL9BO0gwwgvQueafyC0asimpOOjXsMxhOZb6)hF(QT4kWyBtFjv2NRILqyrZhyLd0DzzVBEmLuBbqkp76TSMD1D5kYYuBOy6KRpl73qPnSSmsBddftI91IpTbcklBEn(old6RIJgqcfBCnRzxb3CfzzQnumDY1NL9BO0gwwgvQueafyC0asimpOOjXsMxhOZbUsD4txFvAfhQe(qhyLdKXbEJzdSUbQgMAvSsD4tMQulzA8TGAdftNbcohiZgitd05a5xegNuBbqkxu2NRCVBkiAGvoq2gOZbcSbI02WqXK4qMcINosuY8AGKYYMxJVZYL95k37McIYA2vMLRiltTHIPtU(SSFdL2WYYRuh(01xLwXHkHp0bwjRbY4aDhZgyDdunm1QyL6WNmvPwY04Bb1gkModeCoqMnqMgOZbYVimoP2cGuUOSpx5E3uq0aRCGSnqNdeydePTHHIjXHmfepDKOK51ajLLnVgFNLl7ZvU3nfeL1SRm0CfzzQnumDY1NLnVgFNLFuCO0AkLL9BO0gwwEL6WNU(Q0kouj8HoWkznq2yww27Mhtj1waKYZUElRzxbhYvKLP2qX0jxFw2VHsByz5vQdF66RsR4qLWh6ab)azJ5d05a5xegNuBbqkxaaB(WWj7G0ApnWkznq2gOZb6)hF(QT4kWyBtFjv2NRILqyrZhyLdKzzzZRX3zzayZhgozhKw7PSMDTMMRiltTHIPtU(SS5147SCzFUM46garzz)gkTHLLxPo8PRVkTIdvcFOde8dKnMpqNd0)p(8vBXvGX2M(sQSpxflHWIMpWkhiZYYE38ykP2cGuE21Bzn7AnjxrwMAdftNC9zz)gkTHLL9)JpF1wCfySTPVKk7ZvXsiSO5dSYbUsnj0abL0pbUd05axPo8PRVkTIdvcFOde8deCz(aDoq(fHXj1waKYfaWMpmCYoiT2tdSswdKTSS5147SmaS5ddNSdsR9uwZUEJ55kYYuBOy6KRplBEn(olx2NRjUUbquw2VHsByzz))4ZxTfxbgBB6lPY(CvSeclA(aRCGRutcnqqj9tG7aDoWvQdF66RsR4qLWh6ab)abxMNL9U5XusTfaP8SR3YAwZYxl5FeOMMRi76TCfzzQnumDY1NL)RSmN0OKL9BO0gwww3ObIuHEtaY4jjoLqLkLb6CGmoqGnq1WuRc0Lmfu6ljE0N1a8CtqTHIPZaDoqghOUrdePc9MW)p(8vBXrAnn(EGU8b6)hF(QT4kWyBtFjv2NRIJ0AA89aznqMpqMgOdhdunm1QaDjtbL(sIh9znap3euBOy6mqNdKXb6)hF(QTaDjtbL(sIh9znap3ehP1047b6YhOUrdePc9MW)p(8vBXrAnn(EGSgiZhitd0HJbQgMAveEYBxcQnumDgitz5dX9BCPX3zzgsKgwYuIpqBG6gnqKYhO)F85R2SpWtGmo0zGOUnWRaJTDGFzGL956a)DGOlzkOb(LbYJ(SgGNB35d0)p(8vBXaz4Lbg6D(arAyjAGGm(a7FGlHWI(q7axsL2EG3yFGeMtdCjvA7bYCbZezzK2MAdbLL1nAGinDlXDR9zzZRX3zzK2ggkMYYinSeLimNYYmxWSSmsdlrz5Bzn7kB5kYYuBOy6KRpl)xzzoPrjlBEn(olJ02WqXuwgPTP2qqzzDJgistSL4U1(SSFdL2WYY6gnqKku2eGmEsItjuPszGohiJdeydunm1QaDjtbL(sIh9znap3euBOy6mqNdKXbQB0arQqzt4)hF(QT4iTMgFpqx(a9)JpF1wCfySTPVKk7ZvXrAnn(EGSgiZhitd0HJbQgMAvGUKPGsFjXJ(SgGNBcQnumDgOZbY4a9)JpF1wGUKPGsFjXJ(SgGNBIJ0AA89aD5du3ObIuHYMW)p(8vBXrAnn(EGSgiZhitd0HJbQgMAveEYBxcQnumDgitzzKgwIseMtzzMlywwgPHLOS8TSMD1D5kYYuBOy6KRpl)xzzoPrjl73qPnSSmWgOUrdePc9MaKXtsCkHkvkd05a1nAGivOSjaz8KeNsOsLYaD4yG6gnqKku2eGmEsItjuPszGohiJdKXbQB0arQqzt4)hF(QT4iTMgFpqGpqDJgisfkBcuPsjDKwtJVhitdeCoqgh4nbZgyDdu3ObIuHYMaKXtOsLIGRl1auqdKPbcohiJdePTHHIjHUrdePj2sC3A)azAGmnWkhiJdKXbQB0arQqVj8)JpF1wCKwtJVhiWhOUrdePc9MavQushP1047bY0abNdKXbEtWSbw3a1nAGivO3eGmEcvQueCDPgGcAGmnqW5azCGiTnmumj0nAGinDlXDR9dKPbYuw(qC)gxA8DwMHKRbctj(aTbQB0arkFGinSenqu3gO)rCzB0agOcIgO)F85R2d8ldubrdu3ObIu2h4jqgh6mqu3gOcIg4rAnn(EGFzGkiAGOsLYadDGx7JmoexmqxIgFG2a56snaf0ar8NOe0oq9hiGajnqBGGcaGODGxB8BOUnq9hixxQbOGgOUrdePC2hOXhyvcJhOXhOnqe)jkbTdS87aJYaTbQB0ar6aRgy8a)DGvdmEG9RdK7w7hy1qbnq))4ZxT5ISmsBtTHGYY6gnqKMU243qDllBEn(olJ02WqXuwgPHLOeH5uw(wwgPHLOSmBzn7k4MRiltTHIPtU(S8FLL5KMLnVgFNLrAByOyklJ0Wsuwwnm1QaGPGOnAajU(lcb1gkMod0HJb6)(ifQGqsBzFUkO2qX0zGoCmWvQPYVaibAOrdi5F8rqTHIPtwgPTP2qqz5TAcvQu4zn7kZYvKLnVgFNLlyIdYVwrZYuBOy6KRpRznlBpLRi76TCfzzQnumDY1NLpe3VXLgFNLDPpd5aDzVAA8Dw28A8DwEje)YjmX5PQrR0M1SRSLRiltTHIPtU(SSFdL2WYYQHPwfL95k37McIeuBOy6KLnVgFNLbGnFy4KDqATNYA2v3LRiltTHIPtU(SSFdL2WYYOsLIaOaJJgqcH5bfnjwY86aDoqGnqK2ggkMehYuq80rIsMxdKuw28A8DwUSpx5E3uquwZUcU5kYYuBOy6KRpl73qPnSSmsBddftI91IpTbcAGohOAyQvHH0Ww7brcQnumDYYMxJVZYG(Q4ObKqXgxZA2vMLRiltTHIPtU(SSFdL2WYYaBGOsLIydeKq6AGohO51ajLOMqeeFGGN1aD3aD4yGMxdKuIAcrq8bw5aDxw28A8Dwga28HHt2bP1EkRzxzO5kYYuBOy6KRplBEn(olx2NRjUUbquw27Mhtj1waKYZUEll73qPnSSS)F85R2ILq8lNWeNNQgTsRyjew08bcEwdKTbcohia)zGohOAyQvbatbrB0asC9xecQnumDYYhI734sJVZYGJ)IqcBHFG211(Mh0a1FG(LmLgOnWlojD(bETXVH62avBbq6aXbxhy53bAxxy3IgWaxRM)n80aJEG2tzn7k4qUISm1gkMo56ZY(nuAdllJ02WqXKyFT4tBGGYYMxJVZYG(Q4ObKqXgxZA21AAUISm1gkMo56ZY(nuAdllJkvkcaMcI2ObK46Viesxd05anVgiPe1eIG4dSYbY2aDoqGnqK2ggkMehYuq80rIsMxdKuw28A8DwUSpx5E3uquwZUwtYvKLP2qX0jxFw2VHsByzzK2ggkMehYuq80rIsMxdK0aDoquPsrCitbXthjsWvZd0ab)ab3b6WXarLkfbatbrB0asC9xecPRSS5147S8JIdLwtPSMD9gZZvKLP2qX0jxFw28A8DwUSpxtCDdGOSSFdL2WYYRuh(01xLwXHkHp0bc(bY4aVXSbw3avdtTkwPo8jtvQLmn(wqTHIPZabNdKzdKPSS3npMsQTaiLND9wwZUE7wUISm1gkMo56ZY(nuAdlldSbI02WqXK4qMcINosuY8AGKYYMxJVZYL95k37McIYA21BSLRiltTHIPtU(SS5147S8JIdLwtPSSFdL2WYYRuh(01xLwXHkHp0bw5azCGSXSbw3avdtTkwPo8jtvQLmn(wqTHIPZabNdKzdKPSS3npMsQTaiLND9wwZUEZD5kYYMxJVZYaWMpmCYoiT2tzzQnumDY1N1SR3a3CfzzZRX3z5Y(CL7DtbrzzQnumDY1N1SR3ywUISm1gkMo56ZYMxJVZYL95AIRBaeLL9U5XusTfaP8SR3YA21Bm0CfzzZRX3zzq)2PVKQgTsBwMAdftNC9zn76nWHCfzzZRX3zzB9wtj93LAnltTHIPtU(SM1SSUrdeP8CfzxVLRiltTHIPtU(SS5147SC0C)kPgkMs1kjRvjePdHm8uw(qC)gxA8DwUInAGiLNL9BO0gwwgvQuexbgBB6lPY(CviDnqhogOAlasfAGGs6NU8AInMpqWpqMnqhogi6Z5d05albaqAAjew08bc(bY2TSMDLTCfzzQnumDY1NLnVgFNL1nAGi9ww(qC)gxA8DwUcq0a1nAGiDGvdf0avq0abfaarCDGexdeMsNbI0Wse7dSAGXdeLgOeNodSelxhO1NbEzXsNbwnuqdKHiWyBh4xgi44(CvKL9BO0gwwgydePTHHIjb)I8rjOts3ObI0b6CGOsLI4kWyBtFjv2NRcPRb6CGmoqGnq1WuRIWtE7sqTHIPZaD4yGQHPwfHN82LGAdftNb6CGOsLI4kWyBtFjv2NRILqyrZhyLSg4nMpqMgOZbY4ab2a1nAGivOSjaz8K)F85R2d0HJbQB0arQqzt4)hF(QTyjew08b6WXarAByOysOB0arA6AJFd1TbYAG3gitd0HJbQB0arQqVjqLkL0rAnn(EGvYAGLaainTeclAEwZU6UCfzzQnumDY1NL9BO0gwwgydePTHHIjb)I8rjOts3ObI0b6CGOsLI4kWyBtFjv2NRcPRb6CGmoqGnq1WuRIWtE7sqTHIPZaD4yGQHPwfHN82LGAdftNb6CGOsLI4kWyBtFjv2NRILqyrZhyLSg4nMpqMgOZbY4ab2a1nAGivO3eGmEY)p(8v7b6WXa1nAGivO3e()XNVAlwcHfnFGoCmqK2ggkMe6gnqKMU243qDBGSgiBdKPb6WXa1nAGivOSjqLkL0rAnn(EGvYAGLaainTeclAEw28A8Dww3ObIu2YA2vWnxrwMAdftNC9zzZRX3zzDJgisVLLpe3VXLgFNLz4Lb(n2Tb(nnWVhOeNgOUrdePd8AFKXH4d0giQuPW(aL40avq0aFfeTd87b6)hF(QTyG16DGrzGnfkiAhOUrdePd8AFKXH4d0giQuPW(aL40arFf0a)EG()XNVAlYY(nuAdlldSbQB0arQqVjaz8KeNsOsLYaDoqghOUrdePcLnH)F85R2ILqyrZhOdhdeydu3ObIuHYMaKXtsCkHkvkdKPb6WXa9)JpF1wCfySTPVKk7ZvXsiSO5dSYbYgZZA2vMLRiltTHIPtU(SSFdL2WYYaBG6gnqKku2eGmEsItjuPszGohiJdu3ObIuHEt4)hF(QTyjew08b6WXab2a1nAGivO3eGmEsItjuPszGmnqhogO)F85R2IRaJTn9LuzFUkwcHfnFGvoq2yEw28A8Dww3ObIu2YAwZYhQysynxr21B5kYYMxJVZYiI(Kklr1mLLP2qX0jxFwZUYwUISm1gkMo56ZY)vwMtAw28A8DwgPTHHIPSmsdlrzzghivRKIRl6iIM7xj1qXuQwjzTkHiDiKHNgOZb6)hF(QTiAUFLudftPALK1QeI0HqgEsSKDCBGmLLpe3VXLgFNLziwcj16a5xKpkbDgOUrdeP8bIsrdyGsC6mWQHcAGMK(imn8dehnXZYiTn1gcklZViFuc6K0nAGinRzxDxUISm1gkMo56ZY)vwMtAw28A8DwgPTHHIPSmsdlrzzZRbskrnHii(aznWBd05azCGRfNeHKAvyNdxe9aRCG3y2aD4yGaBGRfNeHKAvyNdxqUi4kFGmLLrABQneuwMRPlS1D0aYA2vWnxrwMAdftNC9z5)klZjnlBEn(olJ02WqXuwgPHLOSS51ajLOMqeeFGvYAGSnqNdKXbcSbUwCsesQvHDoCb5IGR8b6WXaxlojcj1QWohUGCrWv(aDoqgh4AXjriPwf25WflHWIMpWkhiZgOdhdSeaaPPLqyrZhyLd8gZhitdKPSmsBtTHGYY25WtlHWIoRzxzwUISm1gkMo56ZY)vwMtAw28A8DwgPTHHIPSmsdlrzzuPsrSbcsiDnqNdKXbcSbUsnv(fajwdaL(ssbrPY(1m1jpidXv8TGAdftNb6WXaxPMk)cGeRbGsFjPGOuz)AM6KhKH4k(wqTHIPZaDoWvQdF66RsR4qLWh6aRCG10bYuwgPTP2qqz591IpTbckRzxzO5kYYuBOy6KRpl)xzzoPzzZRX3zzK2ggkMYYinSeLL9FFKcvqRDcVPrdiHI)Qd05arLkfbT2j8MgnGek(Rk4Q5bAGSgiBd0HJb6)(ifQqQXKXbrNuzPUMDtqTHIPZaDoquPsri1yY4GOtQSuxZUjwcHfnFGGFGmoqa(ZabNdKTbYuwgPTP2qqz5Y(CnX1naIs(VpsHYZA2vWHCfzzQnumDY1NL)RSmN0SS5147SmsBddftzzKgwIYYhYuqjRpPd5n3eA4bkAad05a9psQTwfDaaKMkgLLrABQneuw(qMcINosuY8AGKYA21AAUISm1gkMo56ZYMxJVZYlH4xoHjopvnAL2S8H4(nU047SSl96c72abh3NRdeCKqsl7deHfTArpqgU3TbwHH)MpqRpdeiIUgOlJq8lNWeNpqg2OvAh4(yC0aYY(nuAdll7)(ifQGqsBzFUoqNdunm1QaGPGOnAajU(lcb1gkMod05ab2avdtTkEuCO0AA8TGAdftNb6CG()XNVAlUcm220xsL95Qyjew08SMDTMKRiltTHIPtU(SS5147SmOVkoAajuSX1SSFdL2WYYNxfL95AQqiPvSuzjoidftd05azCGQHPwfHN82LGAdftNb6WXab2arLkfb6sMck9Lep6ZAaEUjKUgOZbQgMAvGUKPGsFjXJ(SgGNBcQnumDgOdhdunm1Q4rXHsRPX3cQnumDgOZb6)hF(QT4kWyBtFjv2NRILqyrZhOZbcSbIkvkcGcmoAajeMhu0Kq6AGmLL9U5XusTfaP8SR3YA21BmpxrwMAdftNC9zz)gkTHLLrLkfr4DlPg(BUyjew08bcEwdeG)mqNdunm1Qi8ULud)nxqTHIPZaDoq(fHXj1waKYfaWMpmCYoiT2tdSswdKTb6CGmoq1WuRIWtE7sqTHIPZaD4yGQHPwfOlzkO0xs8OpRb45MGAdftNb6CG()XNVAlqxYuqPVK4rFwdWZnXsiSO5dSYbEJzd0HJbQgMAv8O4qP104Bb1gkMod05ab2arLkfXvGX2M(sQSpxfsxdKPSS5147SmaS5ddNSdsR9uwZUE7wUISm1gkMo56ZY(nuAdllJkvkIW7wsn83CXsiSO5de8Sgia)zGohOAyQvr4DlPg(BUGAdftNb6CGmoq1WuRIWtE7sqTHIPZaD4yGQHPwfOlzkO0xs8OpRb45MGAdftNb6CGaBGOsLIaDjtbL(sIh9znap3esxd05a9)JpF1wGUKPGsFjXJ(SgGNBILqyrZhyLd8gZhOdhdunm1Q4rXHsRPX3cQnumDgOZbcSbIkvkIRaJTn9LuzFUkKUgitzzZRX3z5Y(CnX1naIYA21BSLRiltTHIPtU(S8H4(nU047SS7b9pNgOl1RX3dehCDG6pWvQZYMxJVZYEdJtMxJVt4GRzzCW1uBiOSS)rsT1kpRzxV5UCfzzQnumDY1NLnVgFNL9ggNmVgFNWbxZY4GRP2qqz518HH5zn76nWnxrwMAdftNC9zzZRX3zzVHXjZRX3jCW1Smo4AQneuww3ObIuEwZUEJz5kYYuBOy6KRplBEn(ol7nmozEn(oHdUMLXbxtTHGYY()XNVAZZA21Bm0CfzzQnumDY1NL9BO0gwwwnm1QW)4tcezRkO2qX0zGohiJdeydevQueafyC0asimpOOjH01aD4yGQHPwfOlzkO0xs8OpRb45MGAdftNbY0aDoqgh4HqLkfXA18VHNeC18anqwdKzd0HJbcSbEitbLaQdaGuXk1u5xaKyTA(3WtdKPSS5147SS3W4K5147eo4AwghCn1gckl7F8jbISvZA21BGd5kYYuBOy6KRpl73qPnSSmQuPiqxYuqPVK4rFwdWZnH0vw28A8DwEL6K5147eo4AwghCn1gcklJ(8KgEGIgqwZUERMMRiltTHIPtU(SSFdL2WYYQHPwfOlzkO0xs8OpRb45MGAdftNb6CGmoq))4ZxTfOlzkO0xs8OpRb45Myjew08bc(bEJ5dKPb6CGmoW1ItIqsTkSZHlIEGvoq2y2aD4yGaBGRfNeHKAvyNdxqUi4kFGoCmq))4ZxTfxbgBB6lPY(CvSeclA(ab)aVX8b6CGRfNeHKAvyNdxqUi4kFGoh4AXjriPwf25WfrpqWpWBmFGmLLnVgFNLxPozEn(oHdUMLXbxtTHGYYOppD9poAazn76TAsUISm1gkMo56ZY(nuAdllJkvkIRaJTn9LuzFUkKUgOZbQgMAv8O4qP104Bb1gkMozzZRX3z5vQtMxJVt4GRzzCW1uBiOS8JIdLwtJVZA2v2yEUISm1gkMo56ZY(nuAdllRgMAv8O4qP104Bb1gkMod05a9)JpF1wCfySTPVKk7ZvXsiSO5de8d8gZhOZbY4arAByOysW10f26oAad0HJbUwCsesQvHDoCb5IGR8b6CGRfNeHKAvyNdxe9ab)aVX8b6WXab2axlojcj1QWohUGCrWv(azklBEn(olVsDY8A8DchCnlJdUMAdbLLFuCO0AA8D66FC0aYA2v2ULRiltTHIPtU(SSFdL2WYYMxdKuIAcrq8bwjRbYww28A8DwEL6K5147eo4AwghCn1gcklBpL1SRSXwUISm1gkMo56ZYMxJVZYEdJtMxJVt4GRzzCW1uBiOSmxT(y7jRznlVMpmmpxr21B5kYYuBOy6KRplBEn(olJI))KksRBz5dX9BCPX3zzxM5ddpqxkAGdniEw2VHsByzzuPsrCfySTPVKk7ZvH0vwZUYwUISm1gkMo56ZY(nuAdllJkvkIRaJTn9LuzFUkKUYYMxJVZYO0YPfOObK1SRUlxrwMAdftNC9zz)gkTHLLzCGaBGOsLI4kWyBtFjv2NRcPRb6CGMxdKuIAcrq8bwjRbY2azAGoCmqGnquPsrCfySTPVKk7ZvH01aDoqgh4k1K4qLWh6aRK1az2aDoWvQdF66RsR4qLWh6aRK1azOmFGmLLnVgFNLT1BnLUKWCkRzxb3CfzzQnumDY1NL9BO0gwwgvQuexbgBB6lPY(CviDLLnVgFNLXbaqkpXWePdaeuRzn7kZYvKLP2qX0jxFw2VHsByzzuPsrCfySTPVKk7ZvH01aDoquPsrqiU(Q0MwPMsvj76BH0vw28A8Dw2ApX11WjVHXzn7kdnxrwMAdftNC9zz)gkTHLLrLkfXvGX2M(sQSpxflHWIMpqWZAG10b6CGOsLI4kWyBtFjv2NRcPRb6CGOsLIGqC9vPnTsnLQs213cPRSS5147SCjwcf))jRzxbhYvKLP2qX0jxFw2VHsByzzuPsrCfySTPVKk7ZvH01aDoqZRbskrnHii(aznWBd05azCGOsLI4kWyBtFjv2NRILqyrZhi4hiZgOZbQgMAv4F8jbISvfuBOy6mqhogiWgOAyQvH)XNeiYwvqTHIPZaDoquPsrCfySTPVKk7ZvXsiSO5de8d0DdKPSS5147SmQbi9LKUHhiEwZAwZYiPLhFNDLnMZ2nMxtD3TSCvB7ObWZYmSUuxMRmCxDjRXahyfGObgiU(vhy53bE)rXHsRPX3PR)Xrd4(axQwjflDgi)rqd0K0hHP0zGEqwdG4IbSAhnnq2QXaD)3iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqthidzTU2dKXBUGjXa2agdRl1L5kd3vxYAmWbwbiAGbIRF1bw(DG39p(Kar2Q3h4s1kPyPZa5pcAGMK(imLod0dYAaexmGv7OPbERgd09FJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(az8MlysmGv7OPbYwngO7)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bY4nxWKyaR2rtd0D1yGU)BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJ3CbtIbSAhnnqWTgd09FJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(az8MlysmGnGXW6sDzUYWD1LSgdCGvaIgyG46xDGLFh49hfhkTMgFFFGlvRKILodK)iObAs6JWu6mqpiRbqCXawTJMgynPgd09FJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(azKnxWKyaBaJH1L6YCLH7Qlzng4aRaenWaX1V6al)oW7OppPHhOObCFGlvRKILodK)iObAs6JWu6mqpiRbqCXawTJMg4TAmq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKXBUGjXawTJMgi4wJb6(VrsRsNbEFLAQ8lasWG7du)bEFLAQ8lasWab1gkMo3hiJ3CbtIbSbmgwxQlZvgURUK1yGdScq0adex)QdS87aV7FKuBTYVpWLQvsXsNbYFe0anj9rykDgOhK1aiUyaR2rtdKTAmq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKXBUGjXawTJMgO7QXaD)3iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgV5cMedy1oAAGGBngO7)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bY4nxWKyaR2rtdKz1yGU)BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJS5cMedy1oAAGGd1yGU)BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJ3CbtIbSAhnnWAsngO7)gjTkDg4D(lHrJ(iyW9bQ)aVZFjmA0hbdeuBOy6CFGmYMlysmGnGXW6sDzUYWD1LSgdCGvaIgyG46xDGLFh4DUA9X2Z9bUuTskw6mq(JGgOjPpctPZa9GSgaXfdy1oAAGm0Amq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7d00bYqwRR9az8MlysmGv7OPbwtRXaD)3iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgV5cMedy1oAAG1KAmq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKr35cMedydymSUuxMRmCxDjRXahyfGObgiU(vhy53bEh95PR)Xrd4(axQwjflDgi)rqd0K0hHP0zGEqwdG4IbSAhnnqWTgd09FJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(az8MlysmGv7OPbYSAmq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKXBUGjXa2agdRl1L5kd3vxYAmWbwbiAGbIRF1bw(DG3VwY)iqn9(axQwjflDgi)rqd0K0hHP0zGEqwdG4IbSAhnnWB1yGU)BK0Q0zGYbc3pqUBTAUyGUCx(a1FG1wYgiI)iHL4d8VO10FhiJUCMgiJS5cMedy1oAAG3QXaD)3iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgDNlysmGv7OPbERgd09FJKwLod8UUrdePIBcgCFG6pW76gnqKk0BcgCFGm6oxWKyaR2rtdKTAmq3)nsAv6mq5aH7hi3TwnxmqxUlFG6pWAlzdeXFKWs8b(x0A6VdKrxotdKr2CbtIbSAhnnq2QXaD)3iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgDNlysmGv7OPbYwngO7)gjTkDg4DDJgisfSjyW9bQ)aVRB0arQqztWG7dKr35cMedy1oAAGURgd09FJKwLoduoq4(bYDRvZfd0Lpq9hyTLSbEcKbp(EG)fTM(7aze4mnqgzZfmjgWQD00aDxngO7)gjTkDg4DDJgisf3em4(a1FG31nAGivO3em4(azeCDbtIbSAhnnq3vJb6(VrsRsNbEx3ObIubBcgCFG6pW76gnqKku2em4(azKzUGjXawTJMgi4wJb6(VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGmEZfmjgWQD00ab3Amq3)nsAv6mW7RutLFbqcgCFG6pW7RutLFbqcgiO2qX05(anDGmK16ApqgV5cMedy1oAAGGBngO7)gjTkDg4D)3hPqfm4(a1FG39FFKcvWab1gkMo3hiJ3CbtIbSbmgwxQlZvgURUK1yGdScq0adex)QdS87aV7)hF(Qn)(axQwjflDgi)rqd0K0hHP0zGEqwdG4IbSAhnnq2QXaD)3iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgV5cMedy1oAAGSvJb6(VrsRsNbEN)sy0OpcgCFG6pW78xcJg9rWab1gkMo3hiJS5cMedy1oAAGURgd09FJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(az8MlysmGv7OPbcU1yGU)BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hOPdKHSwx7bY4nxWKyaR2rtdKz1yGU)BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJ3CbtIbSAhnnqgAngO7)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bY4nxWKyaR2rtdeCOgd09FJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(az8MlysmGv7OPbwtQXaD)3iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgV5cMedy1oAAG3UvJb6(VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGmEZfmjgWQD00aVXwngO7)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYiBUGjXawTJMg4nMvJb6(VrsRsNbEFLAQ8lasWG7du)bEFLAQ8lasWab1gkMo3hOPdKHSwx7bY4nxWKyaBaJH1L6YCLH7Qlzng4aRaenWaX1V6al)oW76gnqKYVpWLQvsXsNbYFe0anj9rykDgOhK1aiUyaR2rtdKTAmq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKr2CbtIbSAhnnq2QXaD)3iPvPZaVRB0arQ4MGb3hO(d8UUrdePc9MGb3hiJ3CbtIbSAhnnq2QXaD)3iPvPZaVRB0arQGnbdUpq9h4DDJgisfkBcgCFGmYMlysmGv7OPb6UAmq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKr2CbtIbSAhnnq3vJb6(VrsRsNbEx3ObIuXnbdUpq9h4DDJgisf6nbdUpqgzZfmjgWQD00aDxngO7)gjTkDg4DDJgisfSjyW9bQ)aVRB0arQqztWG7dKXBUGjXawTJMgi4wJb6(VrsRsNbEx3ObIuXnbdUpq9h4DDJgisf6nbdUpqgV5cMedy1oAAGGBngO7)gjTkDg4DDJgisfSjyW9bQ)aVRB0arQqztWG7dKr2CbtIbSAhnnqMvJb6(VrsRsNbEx3ObIuXnbdUpq9h4DDJgisf6nbdUpqgzZfmjgWQD00azwngO7)gjTkDg4DDJgisfSjyW9bQ)aVRB0arQqztWG7dKXBUGjXa2agdRl1L5kd3vxYAmWbwbiAGbIRF1bw(DG3puXKW69bUuTskw6mq(JGgOjPpctPZa9GSgaXfdy1oAAGmRgd09FJKwLod8(k1u5xaKGb3hO(d8(k1u5xaKGbcQnumDUpqgzZfmjgWQD00azO1yGU)BK0Q0zG39FFKcvWG7du)bE3)9rkubdeuBOy6CFGmEZfmjgWQD00aRP1yGU)BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJS5cMedy1oAAG1KAmq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKr35cMedy1oAAG3yEngO7)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYi46cMedy1oAAG3UvJb6(VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGmcUUGjXawTJMg4ngAngO7)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYiBUGjXawTJMg4TAAngO7)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bY4nxWKyaR2rtd8wnPgd09FJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(anDGmK16ApqgV5cMedy1oAAGSX8Amq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKXBUGjXa2agdRl1L5kd3vxYAmWbwbiAGbIRF1bw(DG3TNUpWLQvsXsNbYFe0anj9rykDgOhK1aiUyaR2rtdKTAmq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7d00bYqwRR9az8MlysmGv7OPbcU1yGU)BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hOPdKHSwx7bY4nxWKyaR2rtdKHwJb6(VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGMoqgYADThiJ3CbtIbSAhnnWBmVgd09FJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(az8MlysmGv7OPbEJTAmq3)nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKXBUGjXa2agdhX1VkDg4n3nqZRX3dehCLlgWYY8lYNDLnMDllFTFjWuwUwQLb6sGmf0azyUdaG0bcoUpxhWQLAzG1AV(O0oq2yOSpq2yoB3gWgWQLAzGUhK1ai(awTuldKHXaDzeIhjDgi24kddo5)(mqjUbGg4xgO7bzrZh4xgid3td04dm0bEEI331bEHn3gyvcJhy0d8AnVgEsmGvl1YazymqxcFFxhOhK1nHhi4iM4G8Rv0bEK2ObmW6xYuqd8lduo6ZAaEUjgWgWQLbYqI0WsMs8bAdu3ObIu(a9)JpF1M9bEcKXHode1TbEfySTd8ldSSpxh4VdeDjtbnWVmqE0N1a8C7oFG()XNVAlgidVmWqVZhisdlrdeKXhy)dCjew0hAh4sQ02d8g7dKWCAGlPsBpqMlyMyaZ8A8nxCTK)rGAADSaosBddftS3gcILUrdePPBjUBTN9)IfN0OWosdlrSUXosdlrjcZjwmxWm29FFcn(MLUrdePIBcqgpjXPeQuP4KrGPgMAvGUKPGsFjXJ(SgGNBozu3ObIuXnH)F85R2IJ0AA8Tl3L7)hF(QT4kWyBtFjv2NRIJ0AA8nlMZKdhQHPwfOlzkO0xs8OpRb45Mtg9)JpF1wGUKPGsFjXJ(SgGNBIJ0AA8Tl3LRB0arQ4MW)p(8vBXrAnn(MfZzYHd1WuRIWtE7IPbmZRX3CX1s(hbQP1Xc4iTnmumXEBiiw6gnqKMylXDR9S)xS4Kgf2rAyjI1n2rAyjkryoXI5cMXU)7tOX3S0nAGivWMaKXtsCkHkvkozeyQHPwfOlzkO0xs8OpRb45Mtg1nAGivWMW)p(8vBXrAnn(2L7Y9)JpF1wCfySTPVKk7ZvXrAnn(MfZzYHd1WuRc0Lmfu6ljE0N1a8CZjJ()XNVAlqxYuqPVK4rFwdWZnXrAnn(2L7Y1nAGivWMW)p(8vBXrAnn(MfZzYHd1WuRIWtE7IPbSAzGmKCnqykXhOnqDJgis5dePHLObI62a9pIlBJgWavq0a9)JpF1EGFzGkiAG6gnqKY(apbY4qNbI62avq0apsRPX3d8ldubrdevQugyOd8AFKXH4Ib6s04d0gixxQbOGgiI)eLG2bQ)abeiPbAdeuaaeTd8AJFd1TbQ)a56snaf0a1nAGiLZ(an(aRsy8an(aTbI4prjODGLFhyugOnqDJgishy1aJh4VdSAGXdSFDGC3A)aRgkOb6)hF(QnxmGzEn(MlUwY)iqnTowahPTHHIj2BdbXs3ObI001g)gQBS)xS4Kgf2rAyjIfBSJ0WsuIWCI1n29FFcn(MfW0nAGivCtaY4jjoLqLkfN6gnqKkytaY4jjoLqLkfho0nAGivWMaKXtsCkHkvkozKrDJgisfSj8)JpF1wCKwtJVD56gnqKkytGkvkPJ0AA8ntGtgVjywD6gnqKkytaY4juPsrW1LAakiMaNmI02WqXKq3ObI0eBjUBTNjMQKrg1nAGivCt4)hF(QT4iTMgF7Y1nAGivCtGkvkPJ0AA8ntGtgVjywD6gnqKkUjaz8eQuPi46snafetGtgrAByOysOB0arA6wI7w7zIPbmZRX3CX1s(hbQP1Xc4iTnmumXEBiiwB1eQuPWzhPHLiwQHPwfamfeTrdiX1Fr4WH)7JuOccjTL95QdhRutLFbqc0qJgqY)4ZaM514BU4Aj)Ja106yb8cM4G8Rv0bSbSAPwgidPliVKsNbsiP1TbQbcAGkiAGMx)DGbFGgslWgkMedyMxJV5Sqe9jvwIQzAaRwgidXsiPwhi)I8rjOZa1nAGiLpqukAaduItNbwnuqd0K0hHPHFG4Oj(aM514BEDSaosBddftS3gcIf)I8rjOts3ObIu2rAyjIfJuTskUUOJiAUFLudftPALK1QeI0HqgEYP)F85R2IO5(vsnumLQvswRsishcz4jXs2XnMgWmVgFZRJfWrAByOyI92qqS4A6cBDhna2rAyjIL51ajLOMqeeN1nNmUwCsesQvHDoCr0vEJzoCaS1ItIqsTkSZHlixeCLZ0aM514BEDSaosBddftS3gcILDo80siSOzhPHLiwMxdKuIAcrq8kzXMtgb2AXjriPwf25WfKlcUYD4yT4KiKuRc7C4cYfbx5ozCT4KiKuRc7C4ILqyrZRKzoCucaG00siSO5vEJ5mX0aM514BEDSaosBddftS3gcI1(AXN2abXosdlrSqLkfXgiiH0Ltgb2k1u5xaKynau6ljfeLk7xZuN8GmexX3oCSsnv(fajwdaL(ssbrPY(1m1jpidXv8TZvQdF66RsR4qLWhAL1uMgWmVgFZRJfWrAByOyI92qqSk7Z1ex3aik5)(ifkNDKgwIy5)(ifQGw7eEtJgqcf)vDIkvkcATt4nnAaju8xvWvZdel2C4W)9rkuHuJjJdIoPYsDn7MtuPsri1yY4GOtQSuxZUjwcHfnh8mcWFaNSX0aM514BEDSaosBddftS3gcI1HmfepDKOK51ajXosdlrSoKPGswFshYBUj0Wdu0aC6FKuBTk6aainvmAaRwgOl96c72abh3NRdeCKqsl7deHfTArpqgU3TbwHH)MpqRpdeiIUgOlJq8lNWeNpqg2OvAh4(yC0agWmVgFZRJfWxcXVCctCEQA0kTShfw(VpsHkiK0w2NRovdtTkaykiAJgqIR)IWjWudtTkEuCO0AA8Tt))4ZxTfxbgBB6lPY(CvSeclA(aM514BEDSaoOVkoAajuSXv29U5XusTfaPCw3ypkSoVkk7Z1uHqsRyPYsCqgkMCYOAyQvr4jVD5WbWqLkfb6sMck9Lep6ZAaEUjKUCQgMAvGUKPGsFjXJ(SgGNBoCOgMAv8O4qP104BN()XNVAlUcm220xsL95Qyjew0CNadvQueafyC0asimpOOjH0ftdyMxJV51Xc4aWMpmCYoiT2tShfwOsLIi8ULud)nxSeclAo4zbWFCQgMAveE3sQH)M7KFryCsTfaPCbaS5ddNSdsR9uLSyZjJQHPwfHN82LdhQHPwfOlzkO0xs8OpRb45Mt))4ZxTfOlzkO0xs8OpRb45Myjew08kVXmhoudtTkEuCO0AA8TtGHkvkIRaJTn9LuzFUkKUyAaZ8A8nVowaVSpxtCDdGi2JcluPsreE3sQH)MlwcHfnh8Sa4povdtTkcVBj1WFZDYOAyQvr4jVD5WHAyQvb6sMck9Lep6ZAaEU5eyOsLIaDjtbL(sIh9znap3esxo9)JpF1wGUKPGsFjXJ(SgGNBILqyrZR8gZD4qnm1Q4rXHsRPX3obgQuPiUcm220xsL95Qq6IPbSAzGUh0)CAGUuVgFpqCW1bQ)axPEaZ8A8nVowa3ByCY8A8DchCL92qqS8psQTw5dyMxJV51Xc4EdJtMxJVt4GRS3gcI1A(WW8bmZRX386ybCVHXjZRX3jCWv2BdbXs3ObIu(aM514BEDSaU3W4K5147eo4k7THGy5)hF(QnFaZ8A8nVowa3ByCY8A8DchCL92qqS8p(Kar2QShfwQHPwf(hFsGiBvNmcmuPsrauGXrdiHW8GIMesxoCOgMAvGUKPGsFjXJ(SgGNBm5KXdHkvkI1Q5Fdpj4Q5bIfZC4ayhYuqjG6aaivSsnv(fajwRM)n8etdyMxJV51Xc4RuNmVgFNWbxzVneel0NN0Wdu0aypkSqLkfb6sMck9Lep6ZAaEUjKUgWmVgFZRJfWxPozEn(oHdUYEBiiwOppD9poAaShfwQHPwfOlzkO0xs8OpRb45Mtg9)JpF1wGUKPGsFjXJ(SgGNBILqyrZb)nMZKtgxlojcj1QWohUi6kzJzoCaS1ItIqsTkSZHlixeCL7WH)F85R2IRaJTn9LuzFUkwcHfnh83yUZ1ItIqsTkSZHlixeCL7CT4KiKuRc7C4IOb)nMZ0aM514BEDSa(k1jZRX3jCWv2BdbX6rXHsRPX3ShfwOsLI4kWyBtFjv2NRcPlNQHPwfpkouAnn(EaZ8A8nVowaFL6K5147eo4k7THGy9O4qP104701)4ObWEuyPgMAv8O4qP104BN()XNVAlUcm220xsL95Qyjew0CWFJ5ozePTHHIjbxtxyR7Ob4WXAXjriPwf25WfKlcUYDUwCsesQvHDoCr0G)gZD4ayRfNeHKAvyNdxqUi4kNPbmZRX386yb8vQtMxJVt4GRS3gcIL9e7rHL51ajLOMqeeVswSnGzEn(MxhlG7nmozEn(oHdUYEBiiwC16JTNbSbSAzGU0NHCGUSxnn(EaZ8A8nxypXAje)YjmX5PQrR0oGzEn(MlSNQJfWbGnFy4KDqATNypkSudtTkk7ZvU3nfenGzEn(MlSNQJfWl7ZvU3nfeXEuyHkvkcGcmoAajeMhu0KyjZRobgsBddftIdzkiE6irjZRbsAaZ8A8nxypvhlGd6RIJgqcfBCL9OWcPTHHIjX(AXN2ab5unm1QWqAyR9GObmZRX3CH9uDSaoaS5ddNSdsR9e7rHfWqLkfXgiiH0LtZRbskrnHiio4z5ohomVgiPe1eIG4v6UbSAzGGJ)IqcBHFG211(Mh0a1FG(LmLgOnWlojD(bETXVH62avBbq6aXbxhy53bAxxy3IgWaxRM)n80aJEG2tdyMxJV5c7P6yb8Y(CnX1naIy37Mhtj1waKYzDJ9OWY)p(8vBXsi(LtyIZtvJwPvSeclAo4zXg4eG)4unm1QaGPGOnAajU(lIbmZRX3CH9uDSaoOVkoAajuSXv2JclK2ggkMe7RfFAde0aM514BUWEQowaVSpx5E3uqe7rHfQuPiaykiAJgqIR)IqiD508AGKsuticIxjBobgsBddftIdzkiE6irjZRbsAaZ8A8nxypvhlG)O4qP1uI9OWcPTHHIjXHmfepDKOK51aj5evQuehYuq80rIeC18abEW1HduPsraWuq0gnGex)fHq6AaZ8A8nxypvhlGx2NRjUUbqe7E38ykP2cGuoRBShfwRuh(01xLwXHkHpuWZ4nMvNAyQvXk1HpzQsTKPX3GtMX0aM514BUWEQowaVSpx5E3uqe7rHfWqAByOysCitbXthjkzEnqsdyMxJV5c7P6yb8hfhkTMsS7DZJPKAlas5SUXEuyTsD4txFvAfhQe(qRKr2ywDQHPwfRuh(KPk1sMgFdozgtdyMxJV5c7P6ybCayZhgozhKw7PbmZRX3CH9uDSaEzFUY9UPGObmZRX3CH9uDSaEzFUM46garS7DZJPKAlas5SUnGzEn(MlSNQJfWb9BN(sQA0kTdyMxJV5c7P6ybCB9wtj93LADaBaRwgy9lzkOb(Lbkh9znap3g41)4ObmW9vtJVhyngixTv5d8gZ5deLk)sdS(xEGbFGgslWgkMgWmVgFZfOppD9poAaSwcXVCctCEQA0kTShfwMxdKuIAcrq8kzXMdhiTnmumj2QjuPsHpGzEn(MlqFE66FC0aQJfWFuCO0AkXU3npMsQTaiLZ6g7rHfQuPiakW4ObKqyEqrtILmV60)p(8vBXvGX2M(sQSpxflHWIMxP7gWmVgFZfOppD9poAa1Xc4G(Q4ObKqXgxzpkSqAByOysSVw8PnqqdyMxJV5c0NNU(hhnG6yb8Y(CL7DtbrShfwOsLIaOaJJgqcH5bfnjwY8QZvQdF66RsR4qLWhALmEJz1PgMAvSsD4tMQulzA8n4Kzm5KFryCsTfaPCrzFUY9UPGOkzZjWqAByOysCitbXthjkzEnqsdyMxJV5c0NNU(hhnG6yb8Y(CL7DtbrShfwRuh(01xLwXHkHp0kzXO7ywDQHPwfRuh(KPk1sMgFdozgto5xegNuBbqkxu2NRCVBkiQs2CcmK2ggkMehYuq80rIsMxdK0awTuld8UAlastrHfcZf1GXdHkvkI1Q5Fdpj4Q5bQUBm5Yz8qOsLIyTA(3WtILqyrZR7gtGZdzkOeqDaaKkwPMk)cGeRvZ)gE6(aDz0fzkFG2aXVY(avqbFGbFGrRuFOZa1FGQTaiDGkiAGGcaGiUoWRn(nu3gi1ec3gy1qbnqRhOHg4qDBGkithy1aJhODDHDBGRvZ)gEAGrzGRutLFbqhXaRaKPdeLIgWaTEGutiCBGvdf0az(a5Q5bIZ(a)DGwpqQjeUnqfKPdubrd8qOsLYaRgy8a5)3dKCXvS0a)wmGzEn(MlqFE66FC0aQJfWFuCO0AkXU3npMsQTaiLZ6g7rH1k1HpD9vPvCOs4dTswSXSbmZRX3Cb6Ztx)JJgqDSaoaS5ddNSdsR9e7rH1k1HpD9vPvCOs4df8SXCN8lcJtQTaiLlaGnFy4KDqATNQKfBo9)JpF1wCfySTPVKk7ZvXsiSO5vYSbmZRX3Cb6Ztx)JJgqDSaEzFUM46garS7DZJPKAlas5SUXEuyTsD4txFvAfhQe(qbpBm3P)F85R2IRaJTn9LuzFUkwcHfnVsMnGzEn(MlqFE66FC0aQJfWbGnFy4KDqATNypkS8)JpF1wCfySTPVKk7ZvXsiSO5vUsnj0abL0pbUoxPo8PRVkTIdvcFOGhCzUt(fHXj1waKYfaWMpmCYoiT2tvYITbmZRX3Cb6Ztx)JJgqDSaEzFUM46garS7DZJPKAlas5SUXEuy5)hF(QT4kWyBtFjv2NRILqyrZRCLAsObckPFcCDUsD4txFvAfhQe(qbp4Y8bSbSAzG1VKPGg4xgOC0N1a8CBGUuVgiPb6YE1047bmZRX3Cb6ZtA4bkAaSEuCO0AkXU3npMsQTaiLZ6g7rH1k1HpD9vPvCOs4dTswmcUmRo1WuRIvQdFYuLAjtJVbNmJPbmZRX3Cb6ZtA4bkAa1Xc4lH4xoHjopvnALw2JclK2ggkMeB1eQuPWD4W8AGKsuticIxjl2C4yL6WNU(Q0cE3X2aM514BUa95jn8afnG6yb8dzkOK1N0H8MBShfwRuh(01xLwW7o2gWmVgFZfOppPHhOObuhlGd6RIJgqcfBCL9OWcPTHHIjX(AXN2ab5KXvQdF66RsR4qLWhk4zgZC4yLAsObckPFYDGNfa)XHJvQPYVaiXAaO0xskikv2VMPo5bziUIVD4GFryCsTfaPCbOVkoAajuSX1kzXMdhOsLIydeKyjew0CW7oMC4yL6WNU(Q0cE3X2aM514BUa95jn8afnG6yb8Y(CL7DtbrShfwOsLIaOaJJgqcH5bfnjKUCYVimoP2cGuUOSpx5E3uquLS5eyiTnmumjoKPG4PJeLmVgiPbmZRX3Cb6ZtA4bkAa1Xc4pkouAnLy37Mhtj1waKYzDJ9OWcvQueafyC0asimpOOjXsMxhWmVgFZfOppPHhOObuhlGd63o9Lu1OvAzpkSwPo8PRVkTIdvcFOvYcCzUZvQjHgiOK(j3vja)zaZ8A8nxG(8KgEGIgqDSaEzFUY9UPGi2Jcl(fHXj1waKYfL95k37McIQKnNadPTHHIjXHmfepDKOK51ajnGzEn(MlqFEsdpqrdOowa)rXHsRPe7E38ykP2cGuoRBShfwRuh(01xLwXHkHp0kzJzoCSsnj0abL0p5oWdWFgWmVgFZfOppPHhOObuhlGd6RIJgqcfBCL9OWcPTHHIjX(AXN2abnGzEn(MlqFEsdpqrdOowa3wV1us)DPwzpkSwPo8PRVkTIdvcFOvYmMpGnGvl1YaD)Jpd0LizRoq3)9j04B(awTuld08A8nx4F8jbISvz5bzrZtFjfEI9OWQeaaPPLqyrZbpa)XjJRutGNnhoagQuPiakW4ObKqyEqrtcPlNmcmew0jqwFeSbYjQuPi8p(Kar2QcUAEGQKf4w3k1u5xaKaOhRXA8uXq(RdhiSOtGS(iydKtuPsr4F8jbISvfC18avznTUvQPYVaibqpwJ14PIH8xMC4avQueafyC0asimpOOjH0Ltgbgcl6eiRpc2a5evQue(hFsGiBvbxnpqvwtRBLAQ8lasa0J1ynEQyi)1Hdew0jqwFeSbYjQuPi8p(Kar2QcUAEGQ8gZRBLAQ8lasa0J1ynEQyi)LjMgWQLbYWuonWJ0gnGbYqeySTdSAOGgid3tE7c41VKPGgWmVgFZf(hFsGiB16ybCpilAE6lPWtShfwatnm1Q4rXHsRPX3orLkfXvGX2M(sQSpxfsxorLkfH)XNeiYwvWvZduLSUXCNmIkvkIRaJTn9LuzFUkwcHfnh8a8hWjJ3QZ)p(8vBrzFUw1TfbpvKw3elzh3yYHduPsri1GESBjUUudqbjwcHfnh8a8hhoqLkfHhK98eQ1Kyjew0CWdWFyAaRwgyTws5XHg4xgidrGX2oqjozaObwnuqdKH7jVDb86xYuqdyMxJV5c)JpjqKTADSaUhKfnp9Lu4j2JclGPgMAv8O4qP104BNhYuqjG6aaivSsnv(fajkggtDYVsC7qRtGHkvkIRaJTn9LuzFUkKUC6)hF(QT4kWyBtFjv2NRILqyrZR8gZCYiQuPi8p(Kar2QcUAEGQK1nM7KruPsri1GESBjUUudqbjKUC4avQueEq2ZtOwtcPlMC4avQue(hFsGiBvbxnpqvY6M7yAaZ8A8nx4F8jbISvRJfW9GSO5PVKcpXEuybm1WuRIhfhkTMgF7eyhYuqjG6aaivSsnv(fajkggtDYVsC7qRtuPsr4F8jbISvfC18avjRBm3jWqLkfXvGX2M(sQSpxfsxo9)JpF1wCfySTPVKk7ZvXsiSO5vYgZhWQLbYqSesQ1b6(hFgOlrYwDGpsA921v0ag4rAJgWaVcm22bmZRX3CH)XNeiYwTowa3dYIMN(sk8e7rHLAyQvXJIdLwtJVDcmuPsrCfySTPVKk7ZvH0LtgrLkfH)XNeiYwvWvZduLSUbUozevQuesnOh7wIRl1auqcPlhoqLkfHhK98eQ1Kq6IjhoqLkfH)XNeiYwvWvZduLSUvtC4W)p(8vBXvGX2M(sQSpxflHWIMdE35evQue(hFsGiBvbxnpqvY6g4Y0a2awTmqgIxJVhWmVgFZf()XNVAZzD9A8n7rHfQuPiUcm220xsL95Qq6AaRwgO7)hF(QnFaZ8A8nx4)hF(QnVowaNqC9vPnTsnLQs213ShfwQHPwfpkouAnn(25k1e4zOozePTHHIjbxtxyR7Ob4WbsBddftc7C4PLqyrZKtg9)JpF1wCfySTPVKk7ZvXsiSO5GNzoz0)p(8vBrbtCq(1kQyjew08kzMt(lHrJ(iUK4QeMs0kDPX3oCam(lHrJ(iUK4QeMs0kDPX3m5WbQuPiUcm220xsL95Qq6IjhoqFo3zjaastlHWIMdE2y(aM514BUW)p(8vBEDSaoH46RsBALAkvLSRVzpkSudtTkqxYuqPVK4rFwdWZnNRuh(01xLwXHkHp0kDhZDUsnj0abL0pXSkb4pozevQueOlzkO0xs8OpRb45Mq6YHJsaaKMwcHfnh8SXCMgWmVgFZf()XNVAZRJfWjexFvAtRutPQKD9n7rHLAyQvr4jVDnGzEn(Ml8)JpF1MxhlGFfySTPVKk7Zv2Jcl1WuRc0Lmfu6ljE0N1a8CZjJiTnmumj4A6cBDhnahoqAByOysyNdpTeclAMCYO)F85R2c0Lmfu6ljE0N1a8CtSeclAUdh()XNVAlqxYuqPVK4rFwdWZnXs2XnNRuh(01xLwXHkHpuWZmMZ0aM514BUW)p(8vBEDSa(vGX2M(sQSpxzpkSudtTkcp5TlNadvQuexbgBB6lPY(CviDnGzEn(Ml8)JpF1MxhlGFfySTPVKk7Zv2Jcl1WuRIhfhkTMgF7CL6WNU(Q0wjl2yMtgrAByOysW10f26oAaoCG02WqXKWohEAjew0m5Kr1WuRcaMcI2ObK46VieuBOy64evQuelH4xoHjopvnALwH0Ldhatnm1QaGPGOnAajU(lcb1gkMomnGzEn(Ml8)JpF1MxhlGJUKPGsFjXJ(SgGNBShfwOsLI4kWyBtFjv2NRcPRbmZRX3CH)F85R286yb8Y(CTQBlcEQiTUXEuyzEnqsjQjebXzDZjQuPiUcm220xsL95Qyjew0CWdWFCIkvkIRaJTn9LuzFUkKUCcm1WuRIhfhkTMgF7KrGTwCsesQvHDoCb5IGRChowlojcj1QWohUi6kDhZzYHJsaaKMwcHfnh8UBaZ8A8nx4)hF(QnVowaVSpxR62IGNksRBShfwMxdKuIAcrq8kzXMtgrLkfXvGX2M(sQSpxfsxoCSwCsesQvHDoCb5IGRCNRfNeHKAvyNdxeDL()XNVAlUcm220xsL95Qyjew086ahyYjJOsLI4kWyBtFjv2NRILqyrZbpa)XHJ1ItIqsTkSZHlixeCL7CT4KiKuRc7C4ILqyrZbpa)HPbmZRX3CH)F85R286yb8Y(CTQBlcEQiTUXEuyPgMAv8O4qP104BNOsLI4kWyBtFjv2NRcPlNmYiQuPiUcm220xsL95Qyjew0CWdWFC4avQuesnOh7wIRl1auqcPlNOsLIqQb9y3sCDPgGcsSeclAo4b4pm5KXdHkvkI1Q5Fdpj4Q5bIfZC4ayhYuqjG6aaivSsnv(fajwRM)n8etmnGzEn(Ml8)JpF1MxhlGdYTRxbrlIWNUwItTNypkSudtTkqxYuqPVK4rFwdWZnNRuh(01xLwXHkHp0kbxM7CLAc8SCNtgrLkfb6sMck9Lep6ZAaEUjKUC4W)p(8vBb6sMck9Lep6ZAaEUjwcHfnVsWL5m5WbWudtTkqxYuqPVK4rFwdWZnNRuh(01xLwXHkHp0kzXgZgWmVgFZf()XNVAZRJfWxl4u6q2H9OWY)p(8vBXvGX2M(sQSpxflHWIMdEwmBaZ8A8nx4)hF(QnVowaNB(nkHpmC6Y8k7rHL51ajLOMqeeVswS5KXsaaKMwcHfnh8UZHdGHkvkc0Lmfu6ljE0N1a8CtiD5KXlsfaa9syXsiSO5GhG)4WXAXjriPwf25WfKlcUYDUwCsesQvHDoCXsiSO5G3Doxlojcj1QWohUi6kVivaa0lHflHWIMZetdyMxJV5c))4ZxT51Xc4hYuqjRpPd5n3ypkSmVgiPe1eIG4vYmhowPMk)cGexGiBFeFt8bSbSAzGU)rsT16aDPObo0G4dyMxJV5c)JKARvoRdzkiE6irShfwiTnmumj4A6cBDhnahoqAByOysyNdpTecl6bmZRX3CH)rsT1kVowaNx1werdiHi4k7rH1k1HpD9vPvCOs4dTYBUZP)F85R2IRaJTn9LuzFUkwcHfnh8UZjWudtTkqxYuqPVK4rFwdWZnNiTnmumj4A6cBDhnGbmZRX3CH)rsT1kVowaNx1werdiHi4k7rHfWudtTkqxYuqPVK4rFwdWZnNiTnmumjSZHNwcHf9aM514BUW)iP2ALxhlGZRAlIObKqeCL9OWsnm1QaDjtbL(sIh9znap3CYiQuPiqxYuqPVK4rFwdWZnH0LtgrAByOysW10f26oAaoxPo8PRVkTIdvcFOvcUm3HdK2ggkMe25WtlHWI25k1HpD9vPvCOs4dTsgkZD4aPTHHIjHDo80siSODUwCsesQvHDoCXsiSO5GVM4CT4KiKuRc7C4cYfbx5m5WbWqLkfb6sMck9Lep6ZAaEUjKUC6)hF(QTaDjtbL(sIh9znap3elHWIMZ0aM514BUW)iP2ALxhlGBOpIOnn(oHdeOShfw()XNVAlUcm220xsL95Qyjew0CW7oNiTnmumj4A6cBDhnaNmQgMAvGUKPGsFjXJ(SgGNBoxPo8PRVkTIdvcFOGNHYCN()XNVAlqxYuqPVK4rFwdWZnXsiSO5GNnhoaMAyQvb6sMck9Lep6ZAaEUX0aM514BUW)iP2ALxhlGBOpIOnn(oHdeOShfwiTnmumjSZHNwcHf9aM514BUW)iP2ALxhlGZbzEGWusbrjPU6Vki3ypkSqAByOysW10f26oAaoz0)p(8vBXvGX2M(sQSpxflHWIMdE35WHAyQvr4jVDX0aM514BUW)iP2ALxhlGZbzEGWusbrjPU6Vki3ypkSqAByOysyNdpTecl6bmZRX3CH)rsT1kVowaVGjoi)AfL9OWcyOsLI4kWyBtFjv2NRcPlNadvQueOlzkO0xs8OpRb45Mq6YjJ8xcJg9rCjXvjmLOv6sJVD4G)sy0OpcKp20atj(JrsTYe7rR0UsxAkqGGoHPeRBShTs7kDPja4h1WSUXE0kTR0LMIcl(lHrJ(iq(ytdmL4pgj16a2awTmWAnkouAnn(EG7RMgFpGzEn(MlEuCO0AA8nRLq8lNWeNNQgTsl7rHL51ajLOMqeeVswUZjsBddftITAcvQu4dyMxJV5IhfhkTMgFxhlGd6RIJgqcfBCL9OWcyOsLIaOaJJgqcH5bfnjKUCUsnvjl35KruPsrSbcsSeclAo4DNtuPsrSbcsiD5WH51ajLoVkk7Z1uHqsl4nVgiPe1eIG4mnGzEn(MlEuCO0AA8DDSaoaS5ddNSdsR9e7rHfWqLkfbqbghnGecZdkAsiD5KFryCsTfaPCbaS5ddNSdsR9uLSyZHdGHkvkcGcmoAajeMhu0Kq6YjJhcvQueRvZ)gEsWvZde4zMdhhcvQueRvZ)gEsSeclAo4b4pGtWLPbmZRX3CXJIdLwtJVRJfWl7ZvU3nfeXEuyHkvkcGcmoAajeMhu0KyjZRo5xegNuBbqkxu2NRCVBkiQs2CcmK2ggkMehYuq80rIsMxdK0aM514BU4rXHsRPX31Xc4pkouAnLy37Mhtj1waKYzDJ9OWcvQueafyC0asimpOOjXsMxhWmVgFZfpkouAnn(UowaVSpxtCDdGi2JclZRbskrnHiioRBorAByOysu2NRjUUbquY)9rku(aM514BU4rXHsRPX31Xc4G(Q4ObKqXgxzpkSqAByOysSVw8Pnqqo5xegNuBbqkxa6RIJgqcfBCTswSnGzEn(MlEuCO0AA8DDSaoaS5ddNSdsR9e7rHf)IW4KAlas5cayZhgozhKw7PkzX2aM514BU4rXHsRPX31Xc4L95AIRBaeXU3npMsQTaiLZ6g7rHfWudtTkmKg2ApiYjWqLkfbqbghnGecZdkAsiD5WHAyQvHH0Ww7brobgsBddftI91IpTbcYHdK2ggkMe7RfFAdeKZvQjHgiOK(j2QKfa)zaZ8A8nx8O4qP10476ybCqFvC0asOyJRShfwiTnmumj2xl(0giObmZRX3CXJIdLwtJVRJfWFuCO0AkXU3npMsQTaiLZ62a2awTmqgI)XrdyGGJ)oWAnkouAnn(UgduwTv5d8gZhiN8FF4deLk)sdKHiWyBh4xgi44(CDG(hbXh4xkd09UegWmVgFZfpkouAnn(oD9poAaSwcXVCctCEQA0kTShfwiTnmumj2QjuPsH7WH51ajLOMqeeVswSnGzEn(MlEuCO0AA8D66FC0aQJfWbGnFy4KDqATNypkS4xegNuBbqkxaaB(WWj7G0Apvjl2CQgMAvu2NRCVBkiAaZ8A8nx8O4qP104701)4ObuhlGx2NRCVBkiI9OWcvQueafyC0asimpOOjXsMxDAEnqsjQjebXRKnNadPTHHIjXHmfepDKOK51ajnGzEn(MlEuCO0AA8D66FC0aQJfWFuCO0AkXU3npMsQTaiLZ6g7rHfQuPiakW4ObKqyEqrtILmVoGzEn(MlEuCO0AA8D66FC0aQJfWl7Z1ex3aiI9OWY8AGKsuticIZ6MtK2ggkMeL95AIRBaeL8FFKcLpGzEn(MlEuCO0AA8D66FC0aQJfWFuCO0AkXU3npMsQTaiLZ6g7rHfQuPiakW4ObKqyEqrtILmVoGzEn(MlEuCO0AA8D66FC0aQJfWb9vXrdiHInUYEuyH02WqXKyFT4tBGGgWmVgFZfpkouAnn(oD9poAa1Xc4aWMpmCYoiT2tShfw8lcJtQTaiLlaGnFy4KDqATNQKfBoxPo8PRVkTIdvcFOGNHY8bmZRX3CXJIdLwtJVtx)JJgqDSaEzFUM46garS7DZJPKAlas5SUXEuyTsD4txFvAfhQe(qbp4aZhWmVgFZfpkouAnn(oD9poAa1Xc4pkouAnLy37Mhtj1waKYzDJ9OWALAQswUBaZ8A8nx8O4qP104701)4ObuhlGx2NRCVBkiI9OWY8AGKsuticIxjlW1jWqAByOysCitbXthjkzEnqsdydy1YaDzMpm8aDPObo0G4dyMxJV5I18HH5SqX)FsfP1n2JcluPsrCfySTPVKk7ZvH01aM514BUynFyyEDSaokTCAbkAaShfwOsLI4kWyBtFjv2NRcPRbmZRX3CXA(WW86ybCB9wtPljmNypkSyeyOsLI4kWyBtFjv2NRcPlNMxdKuIAcrq8kzXgtoCamuPsrCfySTPVKk7ZvH0LtgxPMehQe(qRKfZCUsD4txFvAfhQe(qRKfdL5mnGzEn(MlwZhgMxhlGJdaGuEIHjshaiOwzpkSqLkfXvGX2M(sQSpxfsxdyMxJV5I18HH51Xc4w7jUUgo5nmM9OWcvQuexbgBB6lPY(CviD5evQueeIRVkTPvQPuvYU(wiDnGzEn(MlwZhgMxhlGxILqX)FypkSqLkfXvGX2M(sQSpxflHWIMdEw1uNOsLI4kWyBtFjv2NRcPlNOsLIGqC9vPnTsnLQs213cPRbmZRX3CXA(WW86ybCudq6ljDdpqC2JcluPsrCfySTPVKk7ZvH0LtZRbskrnHiioRBozevQuexbgBB6lPY(CvSeclAo4zMt1WuRc)JpjqKTQGAdfthhoaMAyQvH)XNeiYwvqTHIPJtuPsrCfySTPVKk7ZvXsiSO5G3DmnGnGvlduwT(y7zG8ObGjggQTaiDG7RMgFpGzEn(Ml4Q1hBpSwcXVCctCEQA0kTShfwiTnmumj2QjuPsHpGzEn(Ml4Q1hBp1Xc4pkouAnLypkSqLkfbqbghnGecZdkAsSK51bmZRX3CbxT(y7Powah0xfhnGek24k7rHfsBddftI91IpTbcYjQuPi2abjwcHfnh8UBaZ8A8nxWvRp2EQJfWl7Z1ex3aiI9OWcPTHHIjrzFUM46garj)3hPq5dyMxJV5cUA9X2tDSaoaS5ddNSdsR9e7rHfWoKPGsa1baqQyLAQ8lasSwn)B4jNmEiuPsrSwn)B4jbxnpqGNzoCCiuPsrSwn)B4jXsiSO5GhG)aobxMgWmVgFZfC16JTN6yb8Y(CnX1naIypkS8)JpF1wSeIF5eM48u1OvAflHWIMdEwSbob4povdtTkaykiAJgqIR)IyaZ8A8nxWvRp2EQJfWb9vXrdiHInUYEuyH02WqXKyFT4tBGGgWmVgFZfC16JTN6yb8Y(CnX1naIypkSwPo8PRVkTIdvcFOGNXBmRo1WuRIvQdFYuLAjtJVbNmJPbmZRX3CbxT(y7Powa)rXHsRPe7rHfWqLkfrz)AM60LeMtcPlNQHPwfL9RzQtxsyo5WbsBddftIdzkiE6irjZRbsYjQuPioKPG4PJej4Q5bc8GRdhQHPwfamfeTrdiX1Fr4evQuelH4xoHjopvnALwH0LdhRuh(01xLwXHkHp0kzKnMvNAyQvXk1HpzQsTKPX3GtMX0aM514BUGRwFS9uhlGx2NRjUUbq0aM514BUGRwFS9uhlGd63o9Lu1OvAhWmVgFZfC16JTN6ybCB9wtj93LADaBaRwgyfB0arkFaZ8A8nxOB0arkNv0C)kPgkMs1kjRvjePdHm8e7rHfQuPiUcm220xsL95Qq6YHd1waKk0abL0pD51eBmh8mZHd0NZDwcaG00siSO5GNTBdy1YaRaenqDJgishy1qbnqfenqqbaqexhiX1aHP0zGinSeX(aRgy8arPbkXPZalXY1bA9zGxwS0zGvdf0azicm22b(LbcoUpxfdyMxJV5cDJgis51Xc46gnqKEJ9OWcyiTnmumj4xKpkbDs6gnqK6evQuexbgBB6lPY(CviD5KrGPgMAveEYBxoCOgMAveEYBxorLkfXvGX2M(sQSpxflHWIMxjRBmNjNmcmDJgisfSjaz8K)F85R2oCOB0arQGnH)F85R2ILqyrZD4aPTHHIjHUrdePPRn(nu3yDJjho0nAGivCtGkvkPJ0AA8DLSkbaqAAjew08bmZRX3CHUrdeP86ybCDJgiszJ9OWcyiTnmumj4xKpkbDs6gnqK6evQuexbgBB6lPY(CviD5KrGPgMAveEYBxoCOgMAveEYBxorLkfXvGX2M(sQSpxflHWIMxjRBmNjNmcmDJgisf3eGmEY)p(8vBho0nAGivCt4)hF(QTyjew0ChoqAByOysOB0arA6AJFd1nwSXKdh6gnqKkytGkvkPJ0AA8DLSkbaqAAjew08bSAzGm8Ya)g72a)Mg43duItdu3ObI0bETpY4q8bAdevQuyFGsCAGkiAGVcI2b(9a9)JpF1wmWA9oWOmWMcfeTdu3ObI0bETpY4q8bAdevQuyFGsCAGOVcAGFpq))4ZxTfdyMxJV5cDJgis51Xc46gnqKEJ9OWcy6gnqKkUjaz8KeNsOsLItg1nAGivWMW)p(8vBXsiSO5oCamDJgisfSjaz8KeNsOsLctoC4)hF(QT4kWyBtFjv2NRILqyrZRKnMpGzEn(Ml0nAGiLxhlGRB0arkBShfwat3ObIubBcqgpjXPeQuP4KrDJgisf3e()XNVAlwcHfn3HdGPB0arQ4MaKXtsCkHkvkm5WH)F85R2IRaJTn9LuzFUkwcHfnVs2yEwZAoda]] )


end
