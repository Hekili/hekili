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


    spec:RegisterPack( "Frost DK", 20210831, [[d4KU4cqiqkpssjUeuvQnrL8jvIrbrDkOWQGi0RKuzwurUfuuWUi6xGqddkYXujTmOkpdQQMgerxdI02GIkFtsj14GQIohvQsRJkvMhi4EqL9jP4GqrvlusvpKkQMiuvcxekkzJqe4JqvjnsOQeDsOQWkbrVekkuZusP2jvk)ekkAOqe0sPsv8ucnvjrxfkkK(kuuQXcs1Ef6VcgmWHPSyi9yQAYQ4YiBwIpdkJguDArRgkkeVgKmBuUne2Tu)wvdxL64skjlxPNJQPt66eSDO03LKgpvuoVKW6PsvnFQW(vC8ASYO4Xuk6gEycVRycFI)RsmHprsKIuKmkQvCtrXBZdLbJIITHGIIib7Z1bGVaZ4O4Tvb7TtSYOi)fwpffHR6n3DqeIWsfUaQ0)iGipriWmn)2VwrHipr4Hyuevizk(OJOrXJPu0n8WeExXe(e)xLycFIKifjXCrrtqH)Buumr48Oi88COoIgfpe3hfXxqMcFayg3jm46aqc2NRdKyEbycCDa4)QtdapmH31bYbsNd3AyeFGeZWaCpeIhlDgaZ4kMbo5)(mabUbJgWxgGZHBzZhWxga(WtdW4di1bCEI3x0bCZSkgqvIXgq2d4EnVMEsoqIzya4l((IoapCRBInaKagXH7xROd4iSzdBa1VKPWhWxgGy2N1G9Ctgfzjx5XkJIpklvAnn)oC)plByXkJUDnwzuKAdLrNy9rrZR53rXLq8lNyeNhQMTsBu8qC)M3A(Duej8Fw2WgasWVdaZeLLkTMMF7UbiQ2Q8bCftdGt(Vp8bGsLFPbGeMmMTd4ldajyFUoa)JG4d4lLb4C8frr)MkTPffXABAOmsUvdOcLcFaoCmaZRjwkqnHij(aQb3aWlQr3WlwzuKAdLrNy9rr)MkTPffnVMyPa1eIK4da3aUoaxdaRTPHYizzFUg46Mqrb)3hHu5rrZR53rXY(CnW1nHIIA0n8hRmksTHYOtS(OO5187O4JYsLwtPOOFtL20IIOcLIeQKXYgwaH5HNnjxY8Au0xHNrb1wyKYJUDnQr3qYyLrrQnugDI1hf9BQ0MwueRTPHYi5(AXh2ebffnVMFhfH)vzzdlGYmUg1OBinwzuKAdLrNy9rr)MkTPff53eJfuBHrkxcJz(0yb7G1ApnGAWna8gGRbScD6d3FvALhQK(uhaegaMdtrrZR53rrymZNglyhSw7POgDdZfRmksTHYOtS(OO5187OyzFUg46Mqrrr)MkTPffxHo9H7VkTYdvsFQdacdOwJPOOVcpJcQTWiLhD7AuJUvRJvgfP2qz0jwFu08A(Du8rzPsRPuu0VPsBArXvOPbudUbG)OOVcpJcQTWiLhD7AuJUHpJvgfP2qz0jwFu0VPsBArrZRjwkqnHij(aQb3aqYb4AaqBayTnnugjpKPW5HJafmVMyPOO5187OyzFUY9vOWPOg1OO)zNaCYwnwz0TRXkJIuBOm6eRpkAEn)ok6HBzZdFjKEkkEiUFZBn)okIzuonGJWMnSbGeMmMTdOAQWha(WtE7gI1VKPWJI(nvAtlkcTbOgJAv(OSuP108Bj1gkJodW1aqfkf5DYy2g(sOSpxLc3dW1aqfkfP)zNaCYwvYvZd1aQb3aUIPb4AaipauHsrENmMTHVek7Zv5siSS5dacdaM)maK4aqEaxhqDdW)p78vBzzFUwTIfbpue2kKlzNkgagdWHJbGkuksHg(ZQiW1LAykC5siSS5dacdaM)mahogaQqPi9WTNhqTMKlHWYMpaimay(ZaWiQr3WlwzuKAdLrNy9rrZR53rrpClBE4lH0trXdX9BER53rrmtbLNhAaFzaiHjJz7ae4KbJgq1uHpa8HN82neRFjtHhf9BQ0MwueAdqng1Q8rzPsRP53sQnugDgGRbCitHhGQtyWv5k0u5xyKSymg1b)kWTdTdW1aG2aqfkf5DYy2g(sOSpxLc3dW1a8)ZoF1wENmMTHVek7Zv5siSS5dOMbCfPdW1aqEaOcLI0)StaozRk5Q5HAa1GBaxX0aCnaKhaQqPifA4pRIaxxQHPWLc3dWHJbGkukspC75buRjPW9aWyaoCmauHsr6F2jaNSvLC18qnGAWnGR4Faye1OB4pwzuKAdLrNy9rr)MkTPffH2auJrTkFuwQ0AA(TKAdLrNb4AaqBahYu4bO6egCvUcnv(fgjlgJrDWVcC7q7aCnauHsr6F2jaNSvLC18qnGAWnGRyAaUga0gaQqPiVtgZ2WxcL95Qu4EaUgG)F25R2Y7KXSn8LqzFUkxcHLnFa1ma8Wuu08A(Du0d3YMh(si9uuJUHKXkJIuBOm6eRpkAEn)ok6HBzZdFjKEkkEiUFZBn)okIeUewQ1b48NDga(sYwDapwA929D2WgWryZg2aUtgZ2OOFtL20IIQXOwLpklvAnn)wsTHYOZaCnaOnauHsrENmMTHVek7ZvPW9aCnaKhaQqPi9p7eGt2QsUAEOgqn4gWvKCaUgaYdavOuKcn8NvrGRl1Wu4sH7b4WXaqfkfPhU98aQ1Ku4EaymahogaQqPi9p7eGt2QsUAEOgqn4gWv37aC4ya()zNVAlVtgZ2WxcL95QCjew28baHbG)b4AaOcLI0)StaozRk5Q5HAa1GBaxrYbGruJAu8rzPsRP53XkJUDnwzuKAdLrNy9rrZR53rXLq8lNyeNhQMTsBu8qC)M3A(DueZeLLkTMMFpG9vtZVJI(nvAtlkAEnXsbQjejXhqn4ga(hGRbG120qzKCRgqfkfEuJUHxSYOi1gkJoX6JI(nvAtlkcTbGkuksOsglBybeMhE2Ku4EaUgWk00aQb3aW)aCnaKhaQqPi3ebjxcHLnFaqya4FaUgaQqPi3ebjfUhGdhdW8AILcNxLL95AOqyPDaqyaMxtSuGAcrs8bGru08A(Due(xLLnSakZ4AuJUH)yLrrQnugDI1hf9BQ0MwuevOuKqLmw2Wcimp8Sj5sMxhGRbWVjglO2cJuUSSpx5(ku40aQb3aWBaUga0gawBtdLrYdzkCE4iqbZRjwkkAEn)okw2NRCFfkCkQr3qYyLrrQnugDI1hfnVMFhfFuwQ0Akff9BQ0MwuevOuKqLmw2Wcimp8Sj5sMxJI(k8mkO2cJuE0TRrn6gsJvgfP2qz0jwFu0VPsBArr(nXyb1wyKYLWyMpnwWoyT2tdOgCdaVb4AaipGvOtF4(RsR8qL0N6aGWaUIPb4WXawHMKAIGc6hWBa1may(ZaWyaoCmaKhWHqfkf5AU)VPNKC18qnaimaKoahogWHqfkf5AU)VPNKlHWYMpaimGRiDayefnVMFhfHXmFASGDWATNIA0nmxSYOi1gkJoX6JI(nvAtlkAEnXsbQjejXhaUbCDaUgawBtdLrYY(CnW1nHIc(VpcPYJIMxZVJIL95AGRBcff1OB16yLrrQnugDI1hf9BQ0MwueRTPHYi5(AXh2ebnaxdGFtmwqTfgPCj8VklBybuMX1budUbGxu08A(Due(xLLnSakZ4AuJUHpJvgfP2qz0jwFu0VPsBArr(nXyb1wyKYLWyMpnwWoyT2tdOgCdaVOO5187OimM5tJfSdwR9uuJU5EJvgfP2qz0jwFu08A(DuSSpxdCDtOOOOFtL20IIqBaQXOwLgwJzThojP2qz0zaUga0gaQqPiHkzSSHfqyE4ztsH7b4WXauJrTknSgZApCssTHYOZaCnaOnaS2MgkJK7RfFyte0aC4yayTnnugj3xl(WMiOb4AaRqtsnrqb9d4nGAWnay(tu0xHNrb1wyKYJUDnQr3UIPyLrrQnugDI1hf9BQ0MwueRTPHYi5(AXh2ebffnVMFhfH)vzzdlGYmUg1OBxVgRmksTHYOtS(OO5187O4JYsLwtPOOVcpJcQTWiLhD7AuJAuKRwFS9eRm621yLrrQnugDI1hfnVMFhfxcXVCIrCEOA2kTrXdX9BER53rrr16JTNbWZggJWmO2cJ0bSVAA(Du0VPsBArrS2MgkJKB1aQqPWJA0n8IvgfP2qz0jwFu0VPsBArruHsrcvYyzdlGW8WZMKlzEnkAEn)ok(OSuP1ukQr3WFSYOi1gkJoX6JI(nvAtlkI120qzKCFT4dBIGgGRbGkukYnrqYLqyzZhaega(JIMxZVJIW)QSSHfqzgxJA0nKmwzuKAdLrNy9rr)MkTPffXABAOmsw2NRbUUjuuW)9rivEu08A(DuSSpxdCDtOOOgDdPXkJIuBOm6eRpk63uPnTOi0gWHmfEaQoHbxLRqtLFHrY1C)Ftpnaxda5bCiuHsrUM7)B6jjxnpudacdaPdWHJbCiuHsrUM7)B6j5siSS5dacdOwpamIIMxZVJIWyMpnwWoyT2trn6gMlwzuKAdLrNy9rr)MkTPff9)ZoF1wUeIF5eJ48q1SvALlHWYMpaiGBa4naK4aG5pdW1auJrTkHzkCAZgwGR)IqsTHYOtu08A(DuSSpxdCDtOOOgDRwhRmksTHYOtS(OOFtL20IIyTnnugj3xl(WMiOOO5187Oi8VklBybuMX1OgDdFgRmksTHYOtS(OOFtL20IIqBaOcLISSV7tD4wGXjPW9aCna1yuRYY(Up1HBbgNKuBOm6mahogawBtdLrYdzkCE4iqbZRjwAaUgaQqPipKPW5HJaj5Q5HAaqyai5aC4yaRqtsnrqb9di5aGaUbaZFIIMxZVJIpklvAnLIA0n3BSYOi1gkJoX6JI(nvAtlkUcD6d3FvALhQK(uhaegaYd4kshqDdqng1QCf60hmvPwW08Bj1gkJodajoaKoamIIMxZVJIL95AGRBcff1OBxXuSYOi1gkJoX6JI(nvAtlkUcD6d3FvALhQK(uhqnda5bGhshqDdqng1QCf60hmvPwW08Bj1gkJodajoaKoamIIMxZVJIpklvAnLIA0TRxJvgfnVMFhfl7Z1ax3ekkksTHYOtS(OgD7kEXkJIMxZVJIW)TdFjunBL2Oi1gkJoX6JA0TR4pwzu08A(Du0wV1uq)DPwJIuBOm6eRpQrnkUMpngpwz0TRXkJIuBOm6eRpkAEn)okIY()ekcBfrXdX9BER53rr3J5tJnampAYsnjEu0VPsBArruHsrENmMTHVek7ZvPWDuJUHxSYOi1gkJoX6JI(nvAtlkIkukY7KXSn8LqzFUkfUJIMxZVJIO0YPfQSHf1OB4pwzuKAdLrNy9rr)MkTPffrEaqBaOcLI8ozmBdFju2NRsH7b4AaMxtSuGAcrs8budUbG3aWyaoCmaOnauHsrENmMTHVek7ZvPW9aCnaKhWk0K8qL0N6aQb3aq6aCnGvOtF4(RsR8qL0N6aQb3aWCyAayefnVMFhfT1BnfUfyCkQr3qYyLrrQnugDI1hf9BQ0MwuevOuK3jJzB4lHY(CvkChfnVMFhfzjm4kpGzeHdmeuRrn6gsJvgfP2qz0jwFu0VPsBArruHsrENmMTHVek7ZvPW9aCnauHsrsiU)Q0gwHMcvj7(BPWDu08A(Du0ApX11ybVXyrn6gMlwzuKAdLrNy9rr)MkTPffrfkf5DYy2g(sOSpxLlHWYMpaiGBa4Zb4AaOcLI8ozmBdFju2NRsH7b4AaOcLIKqC)vPnScnfQs293sH7OO5187OyjxcL9)jQr3Q1XkJIuBOm6eRpk63uPnTOiQqPiVtgZ2WxcL95Qu4EaUgG51elfOMqKeFa4gW1b4AaipauHsrENmMTHVek7Zv5siSS5dacdaPdW1auJrTk9p7eGt2QsQnugDgGdhdaAdqng1Q0)StaozRkP2qz0zaUgaQqPiVtgZ2WxcL95QCjew28baHbG)bGru08A(Due1Gf(sq30dfpQrnk6FSuBTYJvgD7ASYOi1gkJoX6JIMxZVJIhYu48WrGIIhI738wZVJIo)XsT16aW8Ojl1K4rr)MkTPffXABAOmsY1WnZ6oBydWHJbG120qzK0ohEyjew2rn6gEXkJIuBOm6eRpk63uPnTO4k0PpC)vPvEOs6tDa1mGR4FaUgG)F25R2Y7KXSn8LqzFUkxcHLnFaqya4FaUga0gGAmQvj6sMcp8Lap7ZAWEUjP2qz0zaUgawBtdLrsUgUzw3zdlkAEn)okYRAlISHfqKCnQr3WFSYOi1gkJoX6JI(nvAtlkcTbOgJAvIUKPWdFjWZ(SgSNBsQnugDgGRbG120qzK0ohEyjew2rrZR53rrEvBrKnSaIKRrn6gsgRmksTHYOtS(OOFtL20IIQXOwLOlzk8Wxc8SpRb75MKAdLrNb4AaipauHsrIUKPWdFjWZ(SgSNBsH7b4AaipaS2MgkJKCnCZSUZg2aCnGvOtF4(RsR8qL0N6aQzaijMgGdhdaRTPHYiPDo8WsiSShGRbScD6d3FvALhQK(uhqndaZHPb4WXaWABAOmsANdpSecl7b4AaRLNaHLAvANdxUeclB(aGWaCVdaJb4WXaG2aqfkfj6sMcp8Lap7ZAWEUjfUhGRb4)ND(QTeDjtHh(sGN9znyp3KlHWYMpamIIMxZVJI8Q2IiBybejxJA0nKgRmksTHYOtS(OOFtL20II()zNVAlVtgZ2WxcL95QCjew28baHbG)b4AayTnnugj5A4MzDNnSb4Aaipa1yuRs0LmfE4lbE2N1G9CtsTHYOZaCnGvOtF4(RsR8qL0N6aGWaWCyAaUgG)F25R2s0LmfE4lbE2N1G9CtUeclB(aGWaWBaoCmaOna1yuRs0LmfE4lbE2N1G9CtsTHYOZaWikAEn)okAOpISnn)oWseOrn6gMlwzuKAdLrNy9rr)MkTPffXABAOmsANdpSecl7OO5187OOH(iY2087alrGg1OB16yLrrQnugDI1hf9BQ0MwueRTPHYijxd3mR7SHnaxda5b4)ND(QT8ozmBdFju2NRYLqyzZhaega(hGdhdqng1Qm9K3ULuBOm6mamIIMxZVJIC4Mhkgfu4uqOR(RcVIOgDdFgRmksTHYOtS(OOFtL20IIyTnnugjTZHhwcHLDu08A(DuKd38qXOGcNccD1Fv4ve1OBU3yLrrQnugDI1hf9BQ0MwueAdavOuK3jJzB4lHY(CvkCpaxdaAdavOuKOlzk8Wxc8SpRb75Mu4EaUgaYdG)cm0SpYBbUkWOaTc3A(TKAdLrNb4WXa4Vadn7Je7ZmnzuG)mSuRsQnugDgagrXSvAxHBnKLOi)fyOzFKyFMPjJc8NHLAnkMTs7kCRHebc6KMsrXRrrZR53rXcJ4W9Rv0Oy2kTRWTgGXEuJffVg1OgfTNIvgD7ASYOi1gkJoX6JIhI738wZVJIy(hZAaUNxnn)okAEn)okUeIF5eJ48q1SvAJA0n8IvgfP2qz0jwFu0VPsBArr1yuRYY(CL7RqHtsQnugDIIMxZVJIWyMpnwWoyT2trn6g(JvgfP2qz0jwFu08A(DuSSpxdCDtOOOOVcpJcQTWiLhD7Au0VPsBArr))SZxTLlH4xoXiopunBLw5siSS5dac4gaEdajoay(ZaCna1yuRsyMcN2SHf46ViKuBOm6efpe3V5TMFhfrc(fHaZs)aS779np8bO)a8lzknaBa3Cs48d4EZFtTIbO2cJ0bWsUoGYVdWUVzvKnSbSM7)B6PbK9aSNIA0nKmwzuKAdLrNy9rr)MkTPffXABAOmsUVw8HnrqrrZR53rr4Fvw2WcOmJRrn6gsJvgfP2qz0jwFu0VPsBArrS2MgkJKhYu48WrGcMxtS0aCnauHsrEitHZdhbsYvZd1aGWaqYOO5187O4JYsLwtPOgDdZfRmksTHYOtS(OOFtL20IIOcLIeQKXYgwaH5HNnjxY86aCnaOnaS2MgkJKhYu48WrGcMxtSuu08A(DuSSpx5(ku4uuJUvRJvgfP2qz0jwFu0VPsBArXvOtF4(RsR8qL0N6aGWaqEaxr6aQBaQXOwLRqN(GPk1cMMFlP2qz0zaiXbG)bGru08A(DuegZ8PXc2bR1EkQr3WNXkJIuBOm6eRpkAEn)okw2NRbUUjuuu0VPsBArXvOtF4(RsR8qL0N6aGWaqEaxr6aQBaQXOwLRqN(GPk1cMMFlP2qz0zaiXbG0bGru0xHNrb1wyKYJUDnQr3CVXkJIuBOm6eRpk63uPnTOi0gawBtdLrYdzkCE4iqbZRjwkkAEn)okw2NRCFfkCkQr3UIPyLrrQnugDI1hfnVMFhfFuwQ0Akff9BQ0MwuCf60hU)Q0kpuj9PoGAgaYdapKoG6gGAmQv5k0PpyQsTGP53sQnugDgasCaiDayef9v4zuqTfgP8OBxJA0TRxJvgfnVMFhfHXmFASGDWATNIIuBOm6eRpQr3UIxSYOi1gkJoX6JIMxZVJIL95AGRBcfff9v4zuqTfgP8OBxJA0TR4pwzu08A(Due(VD4lHQzR0gfP2qz0jwFuJUDfjJvgfnVMFhfT1Bnf0FxQ1Oi1gkJoX6JAuJIOppC)plByXkJUDnwzuKAdLrNy9rrZR53rr4Fvw2WcOmJRrXdX9BER53rX6xYu4d4ldqm7ZAWEUnG7)zzdBa7RMMFpa3naUARYhWvmXhakv(Lgq9V4as(amSwYmugff9BQ0MwueRTPHYi5(AXh2ebf1OB4fRmksTHYOtS(OOFtL20IIMxtSuGAcrs8budUbG3aC4yaRqtsnrqb9diDaqa3aG5pdW1aWABAOmsUvdOcLcpkAEn)okUeIF5eJ48q1SvAJA0n8hRmksTHYOtS(OO5187O4JYsLwtPOOFtL20IIRqN(W9xLw5HkPp1budUbGhsJI(k8mkO2cJuE0TRrn6gsgRmksTHYOtS(OOFtL20IIRqN(W9xLw5HkPp1baHbGhMgGRbWVjglO2cJuUegZ8PXc2bR1EAa1GBa4naxdW)p78vB5DYy2g(sOSpxLlHWYMpGAgasJIMxZVJIWyMpnwWoyT2trn6gsJvgfP2qz0jwFu08A(DuSSpxdCDtOOOOFtL20IIRqN(W9xLw5HkPp1baHbGhMgGRb4)ND(QT8ozmBdFju2NRYLqyzZhqndaPrrFfEgfuBHrkp621OgDdZfRmksTHYOtS(OOFtL20IIOcLIeQKXYgwaH5HNnjxY86aCnGvOtF4(RsR8qL0N6aQzaipGRiDa1na1yuRYvOtFWuLAbtZVLuBOm6maK4aq6aWyaUga)MySGAlms5YY(CL7RqHtdOgCdaVb4AaqBayTnnugjpKPW5HJafmVMyPOO5187OyzFUY9vOWPOgDRwhRmksTHYOtS(OOFtL20IIRqN(W9xLw5HkPp1budUbG8aWpshqDdqng1QCf60hmvPwW08Bj1gkJodajoaKoamgGRbWVjglO2cJuUSSpx5(ku40aQb3aWBaUga0gawBtdLrYdzkCE4iqbZRjwkkAEn)okw2NRCFfkCkQr3WNXkJIuBOm6eRpk63uPnTOO)F25R2Y7KXSn8LqzFUkxcHLnFa1mGvOjPMiOG(bKCaUgWk0PpC)vPvEOs6tDaqyaijMgGRbWVjglO2cJuUegZ8PXc2bR1EAa1GBa4ffnVMFhfHXmFASGDWATNIA0n3BSYOi1gkJoX6JIMxZVJIL95AGRBcfff9BQ0Mwu0)p78vB5DYy2g(sOSpxLlHWYMpGAgWk0Kuteuq)asoaxdyf60hU)Q0kpuj9PoaimaKetrrFfEgfuBHrkp621Og1O49s(hbQPXkJUDnwzuKAdLrNy9rX)okYjnlrr)MkTPff1nBOivQxLWnEqGtbuHszaUgaYdaAdqng1QeDjtHh(sGN9znyp3KuBOm6maxda5bOB2qrQuVk9)ZoF1wEewtZVha(Ea()zNVAlVtgZ2WxcL95Q8iSMMFpaCdatdaJb4WXauJrTkrxYu4HVe4zFwd2Znj1gkJodW1aqEa()zNVAlrxYu4HVe4zFwd2Zn5rynn)Ea47bOB2qrQuVk9)ZoF1wEewtZVhaUbGPbGXaC4yaQXOwLPN82TKAdLrNbGru8qC)M3A(DueZcRXemL4dWgGUzdfP8b4)ND(QTtd4KyZdDgaAfd4ozmBhWxgqzFUoGFha6sMcFaFza8SpRb752f(a8)ZoF1woa8rzaPEHpaSgtGgaCJpG(hWsiSSp0oGLuHThWvNgaX40awsf2EaysIuzueRTH2qqrrDZgksdxd8kAFu08A(DueRTPHYOOiwJjqbIXPOiMKinkI1ycuu8AuJUHxSYOi1gkJoX6JI)DuKtAwIIMxZVJIyTnnugffXABOneuuu3SHI0aEbEfTpk63uPnTOOUzdfPsfpjCJhe4uavOugGRbG8aG2auJrTkrxYu4HVe4zFwd2Znj1gkJodW1aqEa6MnuKkv8K()zNVAlpcRP53daFpa))SZxTL3jJzB4lHY(CvEewtZVhaUbGPbGXaC4yaQXOwLOlzk8Wxc8SpRb75MKAdLrNb4Aaipa))SZxTLOlzk8Wxc8SpRb75M8iSMMFpa89a0nBOivQ4j9)ZoF1wEewtZVhaUbGPbGXaC4yaQXOwLPN82TKAdLrNbGrueRXeOaX4uuetsKgfXAmbkkEnQr3WFSYOi1gkJoX6JI)DuKtAwII(nvAtlkcTbOB2qrQuVkHB8GaNcOcLYaCnaDZgksLkEs4gpiWPaQqPmahogGUzdfPsfpjCJhe4uavOugGRbG8aqEa6MnuKkv8K()zNVAlpcRP53daIdq3SHIuPINevOuchH1087bGXaqIda5bCvI0bu3a0nBOivQ4jHB8aQqPi56snmf(aWyaiXbG8aWABAOmsQB2qrAaVaVI2pamgagdOMbG8aqEa6MnuKk1Rs))SZxTLhH1087baXbOB2qrQuVkrfkLWrynn)EaymaK4aqEaxLiDa1naDZgksL6vjCJhqfkfjxxQHPWhagdajoaKhawBtdLrsDZgksdxd8kA)aWyayefpe3V5TMFhfXS4AIWuIpaBa6MnuKYhawJjqdaTIb4Fe32MnSbOWPb4)ND(Q9a(Yau40a0nBOi1PbCsS5HodaTIbOWPbCewtZVhWxgGcNgaQqPmGuhW9(yZdXLdaFPXhGnaUUudtHpae)jljTdq)balXsdWga8egCAhW9M)MAfdq)bW1LAyk8bOB2qrk3Pby8buLySby8bydaXFYss7ak)oGSmaBa6MnuKoGQjJnGFhq1KXgq)6a4v0(bunv4dW)p78vBUmkI12qBiOOOUzdfPH7n)n1kIIMxZVJIyTnnugffXAmbkqmoffVgfXAmbkkIxuJUHKXkJIuBOm6eRpk(3rroPrrZR53rrS2MgkJIIynMaffvJrTkHzkCAZgwGR)IqsTHYOZaC4ya(VpcPkjS0w2NRsQnugDgGdhdyfAQ8lmsIMA2Wc(NDKuBOm6efXABOneuuCRgqfkfEuJUH0yLrrZR53rXcJ4W9Rv0Oi1gkJoX6JAuJI()zNVAZJvgD7ASYOi1gkJoX6JI(nvAtlkIkukY7KXSn8LqzFUkfUJIhI738wZVJIiHVMFhfnVMFhfVFn)oQr3WlwzuKAdLrNy9rrZR53rrcX9xL2Wk0uOkz3Fhfpe3V5TMFhfD()SZxT5rr)MkTPffvJrTkFuwQ0AA(TKAdLrNb4AaRqtdacdaZnaxda5bG120qzKKRHBM1D2WgGdhdaRTPHYiPDo8WsiSShagdW1aqEa()zNVAlVtgZ2WxcL95QCjew28baHbG0b4Aaipa))SZxTLfgXH7xROYLqyzZhqndaPdW1a4Vadn7J8wGRcmkqRWTMFlP2qz0zaoCmaOna(lWqZ(iVf4QaJc0kCR53sQnugDgagdWHJbGkukY7KXSn8LqzFUkfUhagdWHJbG(C(aCnGscdUgwcHLnFaqya4HPOgDd)XkJIuBOm6eRpk63uPnTOOAmQvj6sMcp8Lap7ZAWEUjP2qz0zaUgWk0PpC)vPvEOs6tDa1ma8JPb4AaRqtsnrqb9diDa1may(ZaCnaKhaQqPirxYu4HVe4zFwd2ZnPW9aC4yaLegCnSeclB(aGWaWdtdaJOO5187OiH4(RsByfAkuLS7VJA0nKmwzuKAdLrNy9rr)MkTPffvJrTktp5TBj1gkJorrZR53rrcX9xL2Wk0uOkz3Fh1OBinwzuKAdLrNy9rr)MkTPffvJrTkrxYu4HVe4zFwd2Znj1gkJodW1aqEayTnnugj5A4MzDNnSb4WXaWABAOmsANdpSecl7bGXaCnaKhG)F25R2s0LmfE4lbE2N1G9CtUeclB(aC4ya()zNVAlrxYu4HVe4zFwd2Zn5s2PIb4AaRqN(W9xLw5HkPp1baHbGumnamIIMxZVJI3jJzB4lHY(CnQr3WCXkJIuBOm6eRpk63uPnTOOAmQvz6jVDlP2qz0zaUga0gaQqPiVtgZ2WxcL95Qu4okAEn)okENmMTHVek7Z1OgDRwhRmksTHYOtS(OOFtL20IIQXOwLpklvAnn)wsTHYOZaCnaKhawBtdLrsUgUzw3zdBaoCmaS2MgkJK25WdlHWYEaymaxda5bOgJAvcZu40MnSax)fHKAdLrNb4AaOcLICje)YjgX5HQzR0kfUhGdhdaAdqng1QeMPWPnBybU(lcj1gkJodaJOO5187O4DYy2g(sOSpxJA0n8zSYOi1gkJoX6JI(nvAtlkIkukY7KXSn8LqzFUkfUJIMxZVJIOlzk8Wxc8SpRb75wuJU5EJvgfP2qz0jwFu0VPsBArrZRjwkqnHij(aWnGRdW1aqfkf5DYy2g(sOSpxLlHWYMpaimay(ZaCnauHsrENmMTHVek7ZvPW9aCnaOna1yuRYhLLkTMMFlP2qz0zaUgaYdaAdyT8eiSuRs7C4sYzjx5dWHJbSwEcewQvPDoCz2dOMbGFmnamgGdhdOKWGRHLqyzZhaega(JIMxZVJIL95A1kwe8qryRiQr3UIPyLrrQnugDI1hf9BQ0Mwu08AILcutisIpGAWna8gGRbG8aqfkf5DYy2g(sOSpxLc3dWHJbSwEcewQvPDoCz2dOMb4)ND(QT8ozmBdFju2NRYLqyzZhagdW1aqEaOcLI8ozmBdFju2NRYLqyzZhaegam)zaoCmG1YtGWsTkTZHlxcHLnFaqyaW8NbGru08A(DuSSpxRwXIGhkcBfrn621RXkJIuBOm6eRpk63uPnTOOAmQv5JYsLwtZVLuBOm6maxdavOuK3jJzB4lHY(CvkCpaxda5bG8aqfkf5DYy2g(sOSpxLlHWYMpaimay(ZaC4yaOcLIuOH)SkcCDPgMcxkCpaxdavOuKcn8NvrGRl1Wu4YLqyzZhaegam)zaymaxda5bCiuHsrUM7)B6jjxnpuda3aq6aC4yaqBahYu4bO6egCvUcnv(fgjxZ9)n90aWyayefnVMFhfl7Z1QvSi4HIWwruJUDfVyLrrQnugDI1hf9BQ0Mwuung1QeDjtHh(sGN9znyp3KuBOm6maxdyf60hU)Q0kpuj9PoGAgasIPb4AaRqtdac4ga(hGRbG8aqfkfj6sMcp8Lap7ZAWEUjfUhGdhdW)p78vBj6sMcp8Lap7ZAWEUjxcHLnFa1maKetdaJb4WXaG2auJrTkrxYu4HVe4zFwd2Znj1gkJodW1awHo9H7VkTYdvsFQdOgCdapKgfnVMFhfHxX9RWPfr6d3lXP2trn62v8hRmksTHYOtS(OOFtL20II()zNVAlVtgZ2WxcL95QCjew28babCdaPrrZR53rX1sofoKDIA0TRizSYOi1gkJoX6JI(nvAtlkAEnXsbQjejXhqn4gaEdW1aqEaOpNpaxdOKWGRHLqyzZhaega(hGdhdaAdavOuKOlzk8Wxc8SpRb75Mu4EaUgaYd4Mujm4VatUeclB(aGWaG5pdWHJbSwEcewQvPDoC5siSS5dacda)dW1awlpbcl1Q0ohUm7buZaUjvcd(lWKlHWYMpamgagrrZR53rrU53SK(0yHBZRrn62vKgRmksTHYOtS(OOFtL20IIMxtSuGAcrs8buZaq6aC4yaRqtLFHrYB4KTpIVjUKAdLrNOO5187O4HmfEW6t4qERIOg1OOUzdfP8yLr3UgRmksTHYOtS(OO5187Oy2C)kOgkJc1kbRvbeHdHn9uu8qC)M3A(DuSYnBOiLhf9BQ0MwuevOuK3jJzB4lHY(CvkCpahogGAlmsLAIGc6hU9AapmnaimaKoahoga6Z5dW1akjm4Ayjew28baHbG31OgDdVyLrrQnugDI1hfnVMFhf1nBOi9Au8qC)M3A(DuSs40a0nBOiDavtf(au40aGNWGtCDaexteMsNbG1ycKtdOAYydaLgGaNodOKlxhG1NbCB5sNbunv4dajmzmBhWxgasW(Cvgf9BQ0MwueAdaRTPHYij)M8zjPtq3SHI0b4AaOcLI8ozmBdFju2NRsH7b4AaipaOna1yuRY0tE7wsTHYOZaC4yaQXOwLPN82TKAdLrNb4AaOcLI8ozmBdFju2NRYLqyzZhqn4gWvmnamgGRbG8aG2a0nBOivQ4jHB8G)F25R2dWHJbOB2qrQuXt6)ND(QTCjew28b4WXaWABAOmsQB2qrA4EZFtTIbGBaxhagdWHJbOB2qrQuVkrfkLWrynn)Ea1GBaLegCnSeclBEuJUH)yLrrQnugDI1hf9BQ0MwueAdaRTPHYij)M8zjPtq3SHI0b4AaOcLI8ozmBdFju2NRsH7b4AaipaOna1yuRY0tE7wsTHYOZaC4yaQXOwLPN82TKAdLrNb4AaOcLI8ozmBdFju2NRYLqyzZhqn4gWvmnamgGRbG8aG2a0nBOivQxLWnEW)p78v7b4WXa0nBOivQxL()zNVAlxcHLnFaoCmaS2MgkJK6MnuKgU383uRya4gaEdaJb4WXa0nBOivQ4jrfkLWrynn)Ea1GBaLegCnSeclBEu08A(Duu3SHIu8IA0nKmwzuKAdLrNy9rrZR53rrDZgksVgfpe3V5TMFhfXhLb8nRIb8nnGVhGaNgGUzdfPd4EFS5H4dWgaQqP40ae40au40aEfoTd47b4)ND(QTCayM7aYYaAkv40oaDZgkshW9(yZdXhGnauHsXPbiWPbG(k8b89a8)ZoF1wgf9BQ0MwueAdq3SHIuPEvc34bbofqfkLb4AaipaDZgksLkEs))SZxTLlHWYMpahoga0gGUzdfPsfpjCJhe4uavOugagdWHJb4)ND(QT8ozmBdFju2NRYLqyzZhqndapmf1OBinwzuKAdLrNy9rr)MkTPffH2a0nBOivQ4jHB8GaNcOcLYaCnaKhGUzdfPs9Q0)p78vB5siSS5dWHJbaTbOB2qrQuVkHB8GaNcOcLYaWyaoCma))SZxTL3jJzB4lHY(CvUeclB(aQza4HPOO5187OOUzdfP4f1OgfpuXeyASYOBxJvgfnVMFhfrK9juwICFkksTHYOtS(OgDdVyLrrQnugDI1hf)7OiN0OO5187OiwBtdLrrrSgtGIIipaQwjK330rMn3VcQHYOqTsWAvar4qytpnaxdW)p78vBz2C)kOgkJc1kbRvbeHdHn9KCj7uXaWikEiUFZBn)okIeUewQ1bWVjFws6maDZgks5daLYg2ae40zavtf(amb9ryA6halBIhfXABOneuuKFt(SK0jOB2qrAuJUH)yLrrQnugDI1hf)7OiN0OO5187OiwBtdLrrrSgtGIIMxtSuGAcrs8bGBaxhGRbG8awlpbcl1Q0ohUm7buZaUI0b4WXaG2awlpbcl1Q0ohUKCwYv(aWikI12qBiOOixd3mR7SHf1OBizSYOi1gkJoX6JI)DuKtAu08A(DueRTPHYOOiwJjqrrZRjwkqnHij(aQb3aWBaUgaYdaAdyT8eiSuRs7C4sYzjx5dWHJbSwEcewQvPDoCj5SKR8b4AaipG1YtGWsTkTZHlxcHLnFa1maKoahogqjHbxdlHWYMpGAgWvmnamgagrrS2gAdbffTZHhwcHLDuJUH0yLrrQnugDI1hf)7OiN0OO5187OiwBtdLrrrSgtGIIOcLICteKu4EaUgaYdaAdyfAQ8lmsUgmk8LGcNcL9DFQdE4gI78Bj1gkJodWHJbScnv(fgjxdgf(sqHtHY(Up1bpCdXD(TKAdLrNb4AaRqN(W9xLw5HkPp1buZaWNdaJOiwBdTHGII7RfFyteuuJUH5IvgfP2qz0jwFu8VJICsJIMxZVJIyTnnugffXAmbkk6)(iKQKw7KEtZgwaL9vhGRbGkuksATt6nnBybu2xvYvZd1aWna8gGdhdW)9rivPqZiJdNoHYsT7xHKAdLrNb4AaOcLIuOzKXHtNqzP29RqUeclB(aGWaqEaW8NbGehaEdaJOiwBdTHGIIL95AGRBcff8FFesLh1OB16yLrrQnugDI1hf)7OiN0OO5187OiwBtdLrrrSgtGIIhYu4bRpHd5TkKA6HkBydW1a8pwQTwLDcdUgkgffXABOneuu8qMcNhocuW8AILIA0n8zSYOi1gkJoX6JIMxZVJIlH4xoXiopunBL2O4H4(nV187OiM)(MvXaqc2NRdajGWsRtdaHLTAzpa8HVIbuPX(MpaRpdakIUhG7Hq8lNyeNpam7SvAhW(mw2WII(nvAtlk6)(iKQKWsBzFUoaxdqng1QeMPWPnBybU(lcj1gkJodW1aG2auJrTkFuwQ0AA(TKAdLrNb4Aa()zNVAlVtgZ2WxcL95QCjew28OgDZ9gRmksTHYOtS(OO5187Oi8VklBybuMX1OOFtL20IINxLL95AOqyPvUuzjoCdLrdW1aqEaQXOwLPN82TKAdLrNb4WXaG2aqfkfj6sMcp8Lap7ZAWEUjfUhGRbOgJAvIUKPWdFjWZ(SgSNBsQnugDgGdhdqng1Q8rzPsRP53sQnugDgGRb4)ND(QT8ozmBdFju2NRYLqyzZhGRbaTbGkuksOsglBybeMhE2Ku4Eayef9v4zuqTfgP8OBxJA0TRykwzuKAdLrNy9rr)MkTPffrfkfz6RiOg7BUCjew28babCdaM)maxdavOuKPVIGASV5sH7b4Aa8BIXcQTWiLlHXmFASGDWATNgqn4gaEdW1aqEaqBaQXOwLOlzk8Wxc8SpRb75MKAdLrNb4WXa8)ZoF1wIUKPWdFjWZ(SgSNBYLqyzZhqnd4kshagrrZR53rrymZNglyhSw7POgD761yLrrQnugDI1hf9BQ0MwuevOuKPVIGASV5YLqyzZhaeWnay(ZaCnauHsrM(kcQX(MlfUhGRbG8aG2auJrTkrxYu4HVe4zFwd2Znj1gkJodWHJbaTbGkuks0LmfE4lbE2N1G9CtkCpaxdW)p78vBj6sMcp8Lap7ZAWEUjxcHLnFa1mGRyAayefnVMFhfl7Z1ax3ekkQr3UIxSYOi1gkJoX6JIhI738wZVJIoh()CAayEVMFpawY1bO)awHokAEn)ok6nglyEn)oWsUgfzjxdTHGII(hl1wR8OgD7k(JvgfP2qz0jwFu08A(Du0BmwW8A(DGLCnkYsUgAdbffxZNgJh1OBxrYyLrrQnugDI1hfnVMFhf9gJfmVMFhyjxJISKRH2qqrrDZgks5rn62vKgRmksTHYOtS(OO5187OO3ySG5187al5AuKLCn0gckk6)ND(QnpQr3UI5IvgfP2qz0jwFu0VPsBArr1yuRs)Zob4KTQKAdLrNb4AaipaOnauHsrcvYyzdlGW8WZMKc3dWHJbOgJAvIUKPWdFjWZ(SgSNBsQnugDgagdW1aqEahcvOuKR5()MEsYvZd1aWnaKoahoga0gWHmfEaQoHbxLRqtLFHrY1C)FtpnamIIMxZVJIEJXcMxZVdSKRrrwY1qBiOOO)zNaCYwnQr3UwRJvgfP2qz0jwFu0VPsBArruHsrIUKPWdFjWZ(SgSNBsH7OO5187O4k0bZR53bwY1Oil5AOneuue95bn9qLnSOgD7k(mwzuKAdLrNy9rr)MkTPffvJrTkrxYu4HVe4zFwd2Znj1gkJodW1aqEa()zNVAlrxYu4HVe4zFwd2Zn5siSS5dacd4kMgagdW1aqEaRLNaHLAvANdxM9aQza4H0b4WXaG2awlpbcl1Q0ohUKCwYv(aC4ya()zNVAlVtgZ2WxcL95QCjew28baHbCftdW1awlpbcl1Q0ohUKCwYv(aCnG1YtGWsTkTZHlZEaqyaxX0aWikAEn)okUcDW8A(DGLCnkYsUgAdbffrFE4(Fw2WIA0TRU3yLrrQnugDI1hf9BQ0MwuevOuK3jJzB4lHY(CvkCpaxdqng1Q8rzPsRP53sQnugDIIMxZVJIRqhmVMFhyjxJISKRH2qqrXhLLkTMMFh1OB4HPyLrrQnugDI1hf9BQ0Mwuung1Q8rzPsRP53sQnugDgGRb4)ND(QT8ozmBdFju2NRYLqyzZhaegWvmnaxda5bG120qzKKRHBM1D2WgGdhdyT8eiSuRs7C4sYzjx5dW1awlpbcl1Q0ohUm7baHbCftdWHJbaTbSwEcewQvPDoCj5SKR8bGru08A(DuCf6G5187al5AuKLCn0gckk(OSuP1087W9)SSHf1OB4DnwzuKAdLrNy9rr)MkTPffnVMyPa1eIK4dOgCdaVOO5187O4k0bZR53bwY1Oil5AOneuu0EkQr3WdVyLrrQnugDI1hfnVMFhf9gJfmVMFhyjxJISKRH2qqrrUA9X2tuJAue95bn9qLnSyLr3UgRmksTHYOtS(OO5187O4JYsLwtPOOVcpJcQTWiLhD7Au0VPsBArXvOtF4(RsR8qL0N6aQb3aqEaijshqDdqng1QCf60hmvPwW08Bj1gkJodajoaKoamIIhI738wZVJI1VKPWhWxgGy2N1G9CBayEVMyPb4EE1087OgDdVyLrrQnugDI1hf9BQ0MwueRTPHYi5wnGkuk8b4WXamVMyPa1eIK4dOgCdaVb4WXawHo9H7VkTdacda)4ffnVMFhfxcXVCIrCEOA2kTrn6g(JvgfP2qz0jwFu0VPsBArXvOtF4(Rs7aGWaWpErrZR53rXdzk8G1NWH8wfrn6gsgRmksTHYOtS(OOFtL20IIyTnnugj3xl(WMiOb4AaipGvOtF4(RsR8qL0N6aGWaqkshGdhdyfAsQjckOFa)dac4gam)zaoCmGvOPYVWi5AWOWxckCku239Po4HBiUZVLuBOm6mahoga)MySGAlms5s4Fvw2WcOmJRdOgCdaVb4WXaqfkf5Mii5siSS5dacda)daJb4WXawHo9H7VkTdacda)4ffnVMFhfH)vzzdlGYmUg1OBinwzuKAdLrNy9rr)MkTPffrfkfjujJLnSacZdpBskCpaxdGFtmwqTfgPCzzFUY9vOWPbudUbG3aCnaOnaS2MgkJKhYu48WrGcMxtSuu08A(DuSSpx5(ku4uuJUH5IvgfP2qz0jwFu0VPsBArXvOtF4(RsR8qL0N6aQb3aqsmnaxdyfAsQjckOFa)dOMbaZFIIMxZVJIW)TdFjunBL2OgDRwhRmksTHYOtS(OOFtL20II8BIXcQTWiLll7ZvUVcfonGAWna8gGRbaTbG120qzK8qMcNhocuW8AILIIMxZVJIL95k3xHcNIA0n8zSYOi1gkJoX6JIMxZVJIpklvAnLII(nvAtlkUcD6d3FvALhQK(uhqndapKoahogWk0Kuteuq)a(haegam)jk6RWZOGAlms5r3Ug1OBU3yLrrQnugDI1hf9BQ0MwueRTPHYi5(AXh2ebffnVMFhfH)vzzdlGYmUg1OBxXuSYOi1gkJoX6JI(nvAtlkUcD6d3FvALhQK(uhqndaPykkAEn)okAR3AkO)UuRrnQrnkILwE(D0n8WeExXe(ep3BuSQTD2W4rrmBmV7Xn8HB4RUBadOs40ase3)QdO87aU4F2jaNSvVmGLQvc5sNbWFe0amb9rykDgGhU1WiUCGS2ztd4Q7gGZ)glTkDgWf1yuRsOFza6pGlQXOwLqxsTHYOZLbG8vNHHCGS2ztdap3naN)nwAv6mGlQXOwLq)Ya0FaxuJrTkHUKAdLrNlda5Rodd5azTZMga(D3aC(3yPvPZaUOgJAvc9ldq)bCrng1Qe6sQnugDUmaKV6mmKdK1oBAaiP7gGZ)glTkDgWf1yuRsOFza6pGlQXOwLqxsTHYOZLbG8vNHHCGCGeZgZ7ECdF4g(Q7gWaQeonGeX9V6ak)oGlpklvAnn)(YawQwjKlDga)rqdWe0hHP0zaE4wdJ4YbYANnna3R7gGZ)glTkDgWf1yuRsOFza6pGlQXOwLqxsTHYOZLbGmEodd5a5ajMnM394g(Wn8v3nGbujCAajI7F1bu(DaxqFEqtpuzd7YawQwjKlDga)rqdWe0hHP0zaE4wdJ4YbYANnnGRUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaYxDggYbYANnnaK0DdW5FJLwLod4Yk0u5xyKe6xgG(d4Yk0u5xyKe6sQnugDUmaKV6mmKdKdKy2yE3JB4d3WxD3agqLWPbKiU)vhq53bCX)yP2ALFzalvReYLodG)iObyc6JWu6mapCRHrC5azTZMgaEUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaYxDggYbYANnna87Ub48VXsRsNbCrng1Qe6xgG(d4IAmQvj0LuBOm6CzaiF1zyihiRD20aqs3naN)nwAv6mGlQXOwLq)Ya0FaxuJrTkHUKAdLrNlda5Rodd5azTZMgasD3aC(3yPvPZaUOgJAvc9ldq)bCrng1Qe6sQnugDUmaKXZzyihiRD20aQ1UBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaYxDggYbYANnna3R7gGZ)glTkDgWf(lWqZ(iH(LbO)aUWFbgA2hj0LuBOm6CzaiJNZWqoqoqIzJ5DpUHpCdF1DdyavcNgqI4(xDaLFhWfUA9X2ZLbSuTsix6ma(JGgGjOpctPZa8WTggXLdK1oBAayo3naN)nwAv6mGlQXOwLq)Ya0FaxuJrTkHUKAdLrNldW0bGzHzw7bG8vNHHCGS2ztdaF6Ub48VXsRsNbCrng1Qe6xgG(d4IAmQvj0LuBOm6CzaiF1zyihiRD20aCVUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaYxDggYbYANnnGRyYDdW5FJLwLod4IAmQvj0Vma9hWf1yuRsOlP2qz05Yaq(QZWqoqoqIzJ5DpUHpCdF1DdyavcNgqI4(xDaLFhWf0NhU)NLnSldyPALqU0za8hbnatqFeMsNb4HBnmIlhiRD20aWCUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaYxDggYbYANnnGAT7gGZ)glTkDgWf1yuRsOFza6pGlQXOwLqxsTHYOZLbG8vNHHCGCGeZgZ7ECdF4g(Q7gWaQeonGeX9V6ak)oGl3l5FeOMEzalvReYLodG)iObyc6JWu6mapCRHrC5azTZMgWv3naN)nwAv6maXeHZhaVIwnNna8n(Ea6pGAlydaXFeyc8b830A6Vdaz8ngdaz8CggYbYANnnGRUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaY43zyihiRD20aU6Ub48VXsRsNbCr3SHIu5vj0Vma9hWfDZgksL6vj0VmaKXVZWqoqw7SPbGN7gGZ)glTkDgGyIW5dGxrRMZga(gFpa9hqTfSbG4pcmb(a(BAn93bGm(gJbGmEodd5azTZMgaEUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaY43zyihiRD20aWZDdW5FJLwLod4IUzdfPs8Kq)Ya0Fax0nBOivQ4jH(LbGm(DggYbYANnna87Ub48VXsRsNbiMiC(a4v0Q5SbGVhG(dO2c2aoj2KNFpG)Mwt)DaidrmgaY45mmKdK1oBAa43DdW5FJLwLod4IUzdfPYRsOFza6pGl6MnuKk1RsOFzaiJKodd5azTZMga(D3aC(3yPvPZaUOB2qrQepj0Vma9hWfDZgksLkEsOFzaiJuNHHCGS2ztdajD3aC(3yPvPZaUOgJAvc9ldq)bCrng1Qe6sQnugDUmaKV6mmKdK1oBAaiP7gGZ)glTkDgWLvOPYVWij0Vma9hWLvOPYVWij0LuBOm6CzaMoamlmZApaKV6mmKdK1oBAaiP7gGZ)glTkDgWf)3hHuLq)Ya0Fax8FFesvcDj1gkJoxgaYxDggYbYbsmBmV7Xn8HB4RUBadOs40ase3)QdO87aU4)ND(Qn)YawQwjKlDga)rqdWe0hHP0zaE4wdJ4YbYANnna8C3aC(3yPvPZaUOgJAvc9ldq)bCrng1Qe6sQnugDUmaKV6mmKdK1oBAa45Ub48VXsRsNbCH)cm0SpsOFza6pGl8xGHM9rcDj1gkJoxgaY45mmKdK1oBAa43DdW5FJLwLod4IAmQvj0Vma9hWf1yuRsOlP2qz05Yaq(QZWqoqw7SPbGKUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgGPdaZcZS2da5Rodd5azTZMgasD3aC(3yPvPZaUOgJAvc9ldq)bCrng1Qe6sQnugDUmaKV6mmKdK1oBAayo3naN)nwAv6mGlQXOwLq)Ya0FaxuJrTkHUKAdLrNlda5Rodd5azTZMgqT2DdW5FJLwLod4IAmQvj0Vma9hWf1yuRsOlP2qz05Yaq(QZWqoqw7SPb4ED3aC(3yPvPZaUOgJAvc9ldq)bCrng1Qe6sQnugDUmaKV6mmKdK1oBAaxV6Ub48VXsRsNbCrng1Qe6xgG(d4IAmQvj0LuBOm6CzaiF1zyihiRD20aUIN7gGZ)glTkDgWf1yuRsOFza6pGlQXOwLqxsTHYOZLbGmEodd5azTZMgWvK6Ub48VXsRsNbCzfAQ8lmsc9ldq)bCzfAQ8lmscDj1gkJoxgGPdaZcZS2da5Rodd5a5ajMnM394g(Wn8v3nGbujCAajI7F1bu(Dax0nBOiLFzalvReYLodG)iObyc6JWu6mapCRHrC5azTZMgaEUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaY45mmKdK1oBAa45Ub48VXsRsNbCr3SHIu5vj0Vma9hWfDZgksL6vj0VmaKV6mmKdK1oBAa45Ub48VXsRsNbCr3SHIujEsOFza6pGl6MnuKkv8Kq)YaqgpNHHCGS2ztda)UBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaY45mmKdK1oBAa43DdW5FJLwLod4IUzdfPYRsOFza6pGl6MnuKk1RsOFzaiJNZWqoqw7SPbGF3naN)nwAv6mGl6MnuKkXtc9ldq)bCr3SHIuPINe6xgaYxDggYbYANnnaK0DdW5FJLwLod4IUzdfPYRsOFza6pGl6MnuKk1RsOFzaiF1zyihiRD20aqs3naN)nwAv6mGl6MnuKkXtc9ldq)bCr3SHIuPINe6xgaY45mmKdK1oBAai1DdW5FJLwLod4IUzdfPYRsOFza6pGl6MnuKk1RsOFzaiJNZWqoqw7SPbGu3naN)nwAv6mGl6MnuKkXtc9ldq)bCr3SHIuPINe6xgaYxDggYbYbsmBmV7Xn8HB4RUBadOs40ase3)QdO87aUCOIjW0ldyPALqU0za8hbnatqFeMsNb4HBnmIlhiRD20aqQ7gGZ)glTkDgWLvOPYVWij0Vma9hWLvOPYVWij0LuBOm6CzaiJNZWqoqw7SPbG5C3aC(3yPvPZaU4)(iKQe6xgG(d4I)7JqQsOlP2qz05Yaq(QZWqoqw7SPbGpD3aC(3yPvPZaUOgJAvc9ldq)bCrng1Qe6sQnugDUmaKXZzyihiRD20aCVUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaY43zyihiRD20aUIj3naN)nwAv6mGlQXOwLq)Ya0FaxuJrTkHUKAdLrNlda5Rodd5azTZMgW1RUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaYxDggYbYANnnGRyo3naN)nwAv6mGlQXOwLq)Ya0FaxuJrTkHUKAdLrNldaz8CggYbYANnnGR4t3naN)nwAv6mGlQXOwLq)Ya0FaxuJrTkHUKAdLrNlda5Rodd5azTZMgWv3R7gGZ)glTkDgWf1yuRsOFza6pGlQXOwLqxsTHYOZLby6aWSWmR9aq(QZWqoqw7SPbGhMC3aC(3yPvPZaUOgJAvc9ldq)bCrng1Qe6sQnugDUmaKV6mmKdKdKy2yE3JB4d3WxD3agqLWPbKiU)vhq53bCXE6YawQwjKlDga)rqdWe0hHP0zaE4wdJ4YbYANnna8C3aC(3yPvPZaUOgJAvc9ldq)bCrng1Qe6sQnugDUmathaMfMzThaYxDggYbYANnna87Ub48VXsRsNbCrng1Qe6xgG(d4IAmQvj0LuBOm6CzaMoamlmZApaKV6mmKdK1oBAa1A3naN)nwAv6mGlQXOwLq)Ya0FaxuJrTkHUKAdLrNlda5Rodd5azTZMga(0DdW5FJLwLod4IAmQvj0Vma9hWf1yuRsOlP2qz05Yaq(QZWqoqw7SPbCftUBao)BS0Q0zaxuJrTkH(LbO)aUOgJAvcDj1gkJoxgaYxDggYbYbs8bI7Fv6mGR4FaMxZVhal5kxoqgfV3VKmkkwl1YaWxqMcFayg3jm46aqc2NRdK1sTmamVambUoa8F1PbGhMW76a5azTuldW5WTggXhiRLAzayggG7Hq8yPZaygxXmWj)3NbiWny0a(YaCoClB(a(YaWhEAagFaPoGZt8(IoGBMvXaQsm2aYEa3R510tYbYAPwgaMHbGV47l6a8WTUj2aqcyehUFTIoGJWMnSbu)sMcFaFzaIzFwd2Zn5a5azTmamlSgtWuIpaBa6MnuKYhG)F25R2onGtInp0zaOvmG7KXSDaFzaL956a(DaOlzk8b8LbWZ(SgSNBx4dW)p78vB5aWhLbK6f(aWAmbAaWn(a6FalHWY(q7awsf2EaxDAaeJtdyjvy7bGjjsLdKMxZV5Y7L8pcutRdheXABAOmYP2qq40nBOinCnWRO9o9344KMfNWAmbc3vNWAmbkqmoHdtsK6K)7tQ5340nBOivEvc34bbofqfkfxidn1yuRs0LmfE4lbE2N1G9CZfY6MnuKkVk9)ZoF1wEewtZVX34B))SZxTL3jJzB4lHY(CvEewtZVXHjmC4qng1QeDjtHh(sGN9znyp3CHS)F25R2s0LmfE4lbE2N1G9CtEewtZVX34BDZgksLxL()zNVAlpcRP534WegoCOgJAvMEYB3ymqAEn)MlVxY)iqnToCqeRTPHYiNAdbHt3SHI0aEbEfT3P)ghN0S4ewJjq4U6ewJjqbIXjCysIuN8FFsn)gNUzdfPs8KWnEqGtbuHsXfYqtng1QeDjtHh(sGN9znyp3CHSUzdfPs8K()zNVAlpcRP534B8T)F25R2Y7KXSn8LqzFUkpcRP534WegoCOgJAvIUKPWdFjWZ(SgSNBUq2)p78vBj6sMcp8Lap7ZAWEUjpcRP534B8TUzdfPs8K()zNVAlpcRP534WegoCOgJAvMEYB3ymqwldaZIRjctj(aSbOB2qrkFaynMana0kgG)rCBB2WgGcNgG)F25R2d4ldqHtdq3SHIuNgWjXMh6ma0kgGcNgWrynn)EaFzakCAaOcLYasDa37Jnpexoa8LgFa2a46snmf(aq8NSK0oa9haSelnaBaWtyWPDa3B(BQvma9haxxQHPWhGUzdfPCNgGXhqvIXgGXhGnae)jljTdO87aYYaSbOB2qr6aQMm2a(DavtgBa9RdGxr7hq1uHpa))SZxT5YbsZR53C59s(hbQP1HdIyTnnug5uBiiC6MnuKgU383uRWP)ghN0S4ewJjq4WZjSgtGceJt4U6K)7tQ534GMUzdfPYRs4gpiWPaQqP4s3SHIujEs4gpiWPaQqP4WHUzdfPs8KWnEqGtbuHsXfYiRB2qrQepP)F25R2YJWAA(n(w3SHIujEsuHsjCewtZVXajI8vjsRt3SHIujEs4gpGkuksUUudtHJbsezS2MgkJK6MnuKgWlWRO9yGrniJSUzdfPYRs))SZxTLhH108B8TUzdfPYRsuHsjCewtZVXajI8vjsRt3SHIu5vjCJhqfkfjxxQHPWXajImwBtdLrsDZgksdxd8kApgymqAEn)MlVxY)iqnToCqeRTPHYiNAdbHBRgqfkfUtynMaHtng1QeMPWPnBybU(lcho8FFesvsyPTSpxD4yfAQ8lmsIMA2Wc(NDginVMFZL3l5FeOMwhoiwyehUFTIoqoqwl1YaWSCg5fu6maclTvmanrqdqHtdW86Vdi5dWWAjZqzKCG08A(nhhISpHYsK7tdK1Yaqcxcl16a43KpljDgGUzdfP8bGszdBacC6mGQPcFaMG(imn9dGLnXhinVMFZRdheXABAOmYP2qq443KpljDc6MnuK6ewJjq4qMQvc59nDKzZ9RGAOmkuReSwfqeoe20tU8)ZoF1wMn3VcQHYOqTsWAvar4qytpjxYovGXaP518BED4GiwBtdLro1gcchxd3mR7SH5ewJjq4mVMyPa1eIK44U6c51YtGWsTkTZHlZUMRi1HdOTwEcewQvPDoCj5SKRCmginVMFZRdheXABAOmYP2qq4SZHhwcHLTtynMaHZ8AILcutisIxdo8CHm0wlpbcl1Q0ohUKCwYvUdhRLNaHLAvANdxsol5k3fYRLNaHLAvANdxUeclBEni1HJscdUgwcHLnVMRycdmginVMFZRdheXABAOmYP2qq42xl(WMiiNWAmbchQqPi3ebjfUDHm0wHMk)cJKRbJcFjOWPqzF3N6GhUH4o)2HJvOPYVWi5AWOWxckCku239Po4HBiUZVDTcD6d3FvALhQK(uRbFIXaP518BED4GiwBtdLro1gccxzFUg46Mqrb)3hHu5oH1yceo)3hHuL0AN0BA2WcOSVQluHsrsRDsVPzdlGY(QsUAEOWHNdh(VpcPkfAgzC40juwQD)kCHkuksHMrghoDcLLA3Vc5siSS5qazy(dsepmginVMFZRdheXABAOmYP2qq4oKPW5HJafmVMyjNWAmbc3HmfEW6t4qERcPMEOYgMl)JLARvzNWGRHIrdK1YaW833SkgasW(CDaibewADAaiSSvl7bGp8vmGkn238by9zaqr09aCpeIF5eJ48bGzNTs7a2NXYg2aP518BED4G4si(LtmIZdvZwP1PSGZ)9rivjHL2Y(C1LAmQvjmtHtB2WcC9xeUGMAmQv5JYsLwtZVD5)ND(QT8ozmBdFju2NRYLqyzZhinVMFZRdheH)vzzdlGYmU6KVcpJcQTWiLJ7Qtzb35vzzFUgkewALlvwId3qzKlKvJrTktp5TBhoGgQqPirxYu4HVe4zFwd2ZnPWTl1yuRs0LmfE4lbE2N1G9CZHd1yuRYhLLkTMMF7Y)p78vB5DYy2g(sOSpxLlHWYM7cAOcLIeQKXYgwaH5HNnjfUXyG08A(nVoCqegZ8PXc2bR1EYPSGdvOuKPVIGASV5YLqyzZHaoy(JluHsrM(kcQX(MlfUDXVjglO2cJuUegZ8PXc2bR1EQgC45czOPgJAvIUKPWdFjWZ(SgSNBoC4)ND(QTeDjtHh(sGN9znyp3KlHWYMxZvKIXaP518BED4GyzFUg46MqroLfCOcLIm9veuJ9nxUeclBoeWbZFCHkukY0xrqn23CPWTlKHMAmQvj6sMcp8Lap7ZAWEU5Wb0qfkfj6sMcp8Lap7ZAWEUjfUD5)ND(QTeDjtHh(sGN9znyp3KlHWYMxZvmHXazTmaNd)FonamVxZVhal56a0FaRqpqAEn)Mxhoi6nglyEn)oWsU6uBiiC(hl1wR8bsZR5386WbrVXybZR53bwYvNAdbHBnFAm(aP518BED4GO3ySG5187al5QtTHGWPB2qrkFG08A(nVoCq0BmwW8A(DGLC1P2qq48)ZoF1MpqAEn)Mxhoi6nglyEn)oWsU6uBiiC(NDcWjBvNYco1yuRs)Zob4KTQlKHgQqPiHkzSSHfqyE4ztsHBhouJrTkrxYu4HVe4zFwd2ZnmCH8Hqfkf5AU)VPNKC18qHdPoCaTdzk8auDcdUkxHMk)cJKR5()MEcJbsZR5386WbXvOdMxZVdSKRo1gcch6ZdA6HkByoLfCOcLIeDjtHh(sGN9znyp3Kc3dKMxZV51HdIRqhmVMFhyjxDQneeo0NhU)NLnmNYco1yuRs0LmfE4lbE2N1G9CZfY()zNVAlrxYu4HVe4zFwd2Zn5siSS5q4kMWWfYRLNaHLAvANdxMDn4HuhoG2A5jqyPwL25WLKZsUYD4W)p78vB5DYy2g(sOSpxLlHWYMdHRyY1A5jqyPwL25WLKZsUYDTwEcewQvPDoCz2q4kMWyG08A(nVoCqCf6G5187al5QtTHGW9OSuP108BNYcouHsrENmMTHVek7ZvPWTl1yuRYhLLkTMMFpqAEn)MxhoiUcDW8A(DGLC1P2qq4EuwQ0AA(D4(Fw2WCkl4uJrTkFuwQ0AA(Tl))SZxTL3jJzB4lHY(CvUeclBoeUIjxiJ120qzKKRHBM1D2WC4yT8eiSuRs7C4sYzjx5Uwlpbcl1Q0ohUmBiCftoCaT1YtGWsTkTZHljNLCLJXaP518BED4G4k0bZR53bwYvNAdbHZEYPSGZ8AILcutisIxdo8ginVMFZRdhe9gJfmVMFhyjxDQneeoUA9X2Za5azTmam)Jzna3ZRMMFpqAEn)MlTNWTeIF5eJ48q1SvAhinVMFZL2t1HdIWyMpnwWoyT2toLfCQXOwLL95k3xHcNgiRLbGe8lcbML(by337BE4dq)b4xYuAa2aU5KW5hW9M)MAfdqTfgPdGLCDaLFhGDFZQiBydyn3)30tdi7bypnqAEn)MlTNQdhel7Z1ax3ekYjFfEgfuBHrkh3vNYco))SZxTLlH4xoXiopunBLw5siSS5qahEiry(Jl1yuRsyMcN2SHf46ViginVMFZL2t1HdIW)QSSHfqzgxDkl4WABAOmsUVw8HnrqdKMxZV5s7P6WbXhLLkTMsoLfCyTnnugjpKPW5HJafmVMyjxOcLI8qMcNhocKKRMhkiGKdKMxZV5s7P6WbXY(CL7RqHtoLfCOcLIeQKXYgwaH5HNnjxY8QlOH120qzK8qMcNhocuW8AILginVMFZL2t1HdIWyMpnwWoyT2toLfCRqN(W9xLw5HkPpviG8vKwNAmQv5k0PpyQsTGP53ir8JXaP518BU0EQoCqSSpxdCDtOiN8v4zuqTfgPCCxDkl4wHo9H7VkTYdvsFQqa5RiTo1yuRYvOtFWuLAbtZVrIifJbsZR53CP9uD4GyzFUY9vOWjNYcoOH120qzK8qMcNhocuW8AILginVMFZL2t1HdIpklvAnLCYxHNrb1wyKYXD1PSGBf60hU)Q0kpuj9PwdY4H06uJrTkxHo9btvQfmn)gjIumginVMFZL2t1HdIWyMpnwWoyT2tdKMxZV5s7P6WbXY(CnW1nHICYxHNrb1wyKYXDDG08A(nxApvhoic)3o8Lq1SvAhinVMFZL2t1HdI26TMc6Vl16a5azTmG6xYu4d4ldqm7ZAWEUnG7)zzdBa7RMMFpa3naUARYhWvmXhakv(Lgq9V4as(amSwYmugnqAEn)MlrFE4(Fw2WWb)RYYgwaLzC1PSGdRTPHYi5(AXh2ebnqAEn)MlrFE4(Fw2WQdhexcXVCIrCEOA2kToLfCMxtSuGAcrs8AWHNdhRqtsnrqb9difc4G5pUWABAOmsUvdOcLcFGSwQLbCrTfgPHSGdH5m3H8Hqfkf5AU)VPNKC18qv3vmW3iFiuHsrUM7)B6j5siSS51DfdK4HmfEaQoHbxLRqtLFHrY1C)FtpDzaUh6MmLpaBaSxDAak8KpGKpGSvQp0za6pa1wyKoafona4jm4exhW9M)MAfdGAcrfdOAQWhG1dWqtwQvmafUPdOAYydWUVzvmG1C)FtpnGSmGvOPYVWOJCavc30bGszdBawpaQjevmGQPcFayAaC18qXDAa)oaRha1eIkgGc30bOWPbCiuHszavtgBa8)7bqo7oxAaFlhinVMFZLOppC)plBy1HdIpklvAnLCYxHNrb1wyKYXD1PSGBf60hU)Q0kpuj9Pwdo8q6aP518BUe95H7)zzdRoCqegZ8PXc2bR1EYPSGBf60hU)Q0kpuj9Pcb8WKl(nXyb1wyKYLWyMpnwWoyT2t1Gdpx()zNVAlVtgZ2WxcL95QCjew28Aq6aP518BUe95H7)zzdRoCqSSpxdCDtOiN8v4zuqTfgPCCxDkl4wHo9H7VkTYdvsFQqapm5Y)p78vB5DYy2g(sOSpxLlHWYMxdshinVMFZLOppC)plBy1HdIL95k3xHcNCkl4qfkfjujJLnSacZdpBsUK5vxRqN(W9xLw5HkPp1Aq(ksRtng1QCf60hmvPwW08BKisXWf)MySGAlms5YY(CL7RqHt1GdpxqdRTPHYi5HmfopCeOG51elnqAEn)MlrFE4(Fw2WQdhel7ZvUVcfo5uwWTcD6d3FvALhQK(uRbhY4hP1PgJAvUcD6dMQulyA(nsePy4IFtmwqTfgPCzzFUY9vOWPAWHNlOH120qzK8qMcNhocuW8AILginVMFZLOppC)plBy1HdIWyMpnwWoyT2toLfC()zNVAlVtgZ2WxcL95QCjew28AwHMKAIGc6hqsxRqN(W9xLw5HkPpviGKyYf)MySGAlms5symZNglyhSw7PAWH3aP518BUe95H7)zzdRoCqSSpxdCDtOiN8v4zuqTfgPCCxDkl48)ZoF1wENmMTHVek7Zv5siSS51Scnj1ebf0pGKUwHo9H7VkTYdvsFQqajX0a5azTmG6xYu4d4ldqm7ZAWEUnamVxtS0aCpVAA(9aP518BUe95bn9qLnmCpklvAnLCYxHNrb1wyKYXD1PSGBf60hU)Q0kpuj9PwdoKrsKwNAmQv5k0PpyQsTGP53irKIXaP518BUe95bn9qLnS6WbXLq8lNyeNhQMTsRtzbhwBtdLrYTAavOu4oCyEnXsbQjejXRbhEoCScD6d3FvAHa(XBG08A(nxI(8GMEOYgwD4G4HmfEW6t4qERcNYcUvOtF4(RsleWpEdKMxZV5s0Nh00dv2WQdheH)vzzdlGYmU6uwWH120qzKCFT4dBIGCH8k0PpC)vPvEOs6tfcifPoCScnj1ebf0pGFiGdM)4WXk0u5xyKCnyu4lbfofk77(uh8Wne353oCWVjglO2cJuUe(xLLnSakZ4An4WZHduHsrUjcsUeclBoeWpgoCScD6d3FvAHa(XBG08A(nxI(8GMEOYgwD4GyzFUY9vOWjNYcouHsrcvYyzdlGW8WZMKc3U43eJfuBHrkxw2NRCFfkCQgC45cAyTnnugjpKPW5HJafmVMyPbsZR53Cj6ZdA6HkBy1HdIW)TdFjunBLwNYcUvOtF4(RsR8qL0NAn4qsm5AfAsQjckOFa)1aZFginVMFZLOppOPhQSHvhoiw2NRCFfkCYPSGJFtmwqTfgPCzzFUY9vOWPAWHNlOH120qzK8qMcNhocuW8AILginVMFZLOppOPhQSHvhoi(OSuP1uYjFfEgfuBHrkh3vNYcUvOtF4(RsR8qL0NAn4HuhowHMKAIGc6hWpeG5pdKMxZV5s0Nh00dv2WQdheH)vzzdlGYmU6uwWH120qzKCFT4dBIGginVMFZLOppOPhQSHvhoiAR3AkO)UuRoLfCRqN(W9xLw5HkPp1AqkMgihiRLAzao)zNbGVKSvhGZ)(KA(nFGSwQLbyEn)Ml9p7eGt2Q48WTS5HVesp5uwWvsyW1WsiSS5qaM)4c5vOjiGNdhqdvOuKqLmw2Wcimp8SjPWTlKHgcl7aCRps8G7cvOuK(NDcWjBvjxnpu1GdjRBfAQ8lmsc1Z0CnEOyy)1Hdew2b4wFK4b3fQqPi9p7eGt2QsUAEOQbFw3k0u5xyKeQNP5A8qXW(lgoCGkuksOsglBybeMhE2Ku42fYqdHLDaU1hjEWDHkuks)Zob4KTQKRMhQAWN1Tcnv(fgjH6zAUgpumS)6Wbcl7aCRps8G7cvOuK(NDcWjBvjxnpu1Cft1Tcnv(fgjH6zAUgpumS)IbgdK1YaWmkNgWryZg2aqctgZ2bunv4daF4jVDdX6xYu4dKMxZV5s)Zob4KTAD4GOhULnp8Lq6jNYcoOPgJAv(OSuP108BxOcLI8ozmBdFju2NRsHBxOcLI0)StaozRk5Q5HQgCxXKlKrfkf5DYy2g(sOSpxLlHWYMdby(dse5R15)ND(QTSSpxRwXIGhkcBfYLStfy4WbQqPifA4pRIaxxQHPWLlHWYMdby(JdhOcLI0d3EEa1AsUeclBoeG5pymqwldaZuq55HgWxgasyYy2oabozWObunv4daF4jVDdX6xYu4dKMxZV5s)Zob4KTAD4GOhULnp8Lq6jNYcoOPgJAv(OSuP108BxhYu4bO6egCvUcnv(fgjlgJrDWVcC7qRlOHkukY7KXSn8LqzFUkfUD5)ND(QT8ozmBdFju2NRYLqyzZR5ksDHmQqPi9p7eGt2QsUAEOQb3vm5czuHsrk0WFwfbUUudtHlfUD4avOuKE42ZdOwtsHBmC4avOuK(NDcWjBvjxnpu1G7k(XyG08A(nx6F2jaNSvRdhe9WTS5HVesp5uwWbn1yuRYhLLkTMMF7cAhYu4bO6egCvUcnv(fgjlgJrDWVcC7qRluHsr6F2jaNSvLC18qvdURyYf0qfkf5DYy2g(sOSpxLc3U8)ZoF1wENmMTHVek7Zv5siSS51GhMgiRLbGeUewQ1b48NDga(sYwDapwA929D2WgWryZg2aUtgZ2bsZR53CP)zNaCYwToCq0d3YMh(si9KtzbNAmQv5JYsLwtZVDbnuHsrENmMTHVek7ZvPWTlKrfkfP)zNaCYwvYvZdvn4UIKUqgvOuKcn8NvrGRl1Wu4sHBhoqfkfPhU98aQ1Ku4gdhoqfkfP)zNaCYwvYvZdvn4U6ED4W)p78vB5DYy2g(sOSpxLlHWYMdb87cvOuK(NDcWjBvjxnpu1G7ksIXa5azTmaKWxZVhinVMFZL()zNVAZXD)A(TtzbhQqPiVtgZ2WxcL95Qu4EGSwgGZ)ND(QnFG08A(nx6)ND(QnVoCqKqC)vPnScnfQs293oLfCQXOwLpklvAnn)21k0eeWCUqgRTPHYijxd3mR7SH5WbwBtdLrs7C4HLqyzJHlK9)ZoF1wENmMTHVek7Zv5siSS5qaPUq2)p78vBzHrC4(1kQCjew28AqQl(lWqZ(iVf4QaJc0kCR53oCan(lWqZ(iVf4QaJc0kCR53y4WbQqPiVtgZ2WxcL95Qu4gdhoqFo3vjHbxdlHWYMdb8W0aP518BU0)p78vBED4GiH4(RsByfAkuLS7VDkl4uJrTkrxYu4HVe4zFwd2ZnxRqN(W9xLw5HkPp1AWpMCTcnj1ebf0pG0AG5pUqgvOuKOlzk8Wxc8SpRb75Mu42HJscdUgwcHLnhc4HjmginVMFZL()zNVAZRdheje3FvAdRqtHQKD)TtzbNAmQvz6jVDpqAEn)Ml9)ZoF1MxhoiENmMTHVek7ZvNYco1yuRs0LmfE4lbE2N1G9CZfYyTnnugj5A4MzDNnmhoWABAOmsANdpSeclBmCHS)F25R2s0LmfE4lbE2N1G9CtUeclBUdh()zNVAlrxYu4HVe4zFwd2Zn5s2PcxRqN(W9xLw5HkPpviGumHXaP518BU0)p78vBED4G4DYy2g(sOSpxDkl4uJrTktp5TBxqdvOuK3jJzB4lHY(CvkCpqAEn)Ml9)ZoF1MxhoiENmMTHVek7ZvNYco1yuRYhLLkTMMF7czS2MgkJKCnCZSUZgMdhyTnnugjTZHhwcHLngUqwng1QeMPWPnBybU(lcj1gkJoUqfkf5si(LtmIZdvZwPvkC7Wb0uJrTkHzkCAZgwGR)IqsTHYOdgdKMxZV5s))SZxT51HdIOlzk8Wxc8SpRb75MtzbhQqPiVtgZ2WxcL95Qu4EG08A(nx6)ND(QnVoCqSSpxRwXIGhkcBfoLfCMxtSuGAcrsCCxDHkukY7KXSn8LqzFUkxcHLnhcW8hxOcLI8ozmBdFju2NRsHBxqtng1Q8rzPsRP53UqgARLNaHLAvANdxsol5k3HJ1YtGWsTkTZHlZUg8JjmC4OKWGRHLqyzZHa(hinVMFZL()zNVAZRdhel7Z1QvSi4HIWwHtzbN51elfOMqKeVgC45czuHsrENmMTHVek7ZvPWTdhRLNaHLAvANdxMDn()zNVAlVtgZ2WxcL95QCjew2CmCHmQqPiVtgZ2WxcL95QCjew2CiaZFC4yT8eiSuRs7C4YLqyzZHam)bJbsZR53CP)F25R286WbXY(CTAflcEOiSv4uwWPgJAv(OSuP108BxOcLI8ozmBdFju2NRsHBxiJmQqPiVtgZ2WxcL95QCjew2CiaZFC4avOuKcn8NvrGRl1Wu4sHBxOcLIuOH)SkcCDPgMcxUeclBoeG5py4c5dHkukY1C)Ftpj5Q5HchsD4aAhYu4bO6egCvUcnv(fgjxZ9)n9egymqAEn)Ml9)ZoF1MxhoicVI7xHtlI0hUxItTNCkl4uJrTkrxYu4HVe4zFwd2ZnxRqN(W9xLw5HkPp1Aqsm5AfAcc4WVlKrfkfj6sMcp8Lap7ZAWEUjfUD4W)p78vBj6sMcp8Lap7ZAWEUjxcHLnVgKety4Wb0uJrTkrxYu4HVe4zFwd2ZnxRqN(W9xLw5HkPp1AWHhshinVMFZL()zNVAZRdhexl5u4q2XPSGZ)p78vB5DYy2g(sOSpxLlHWYMdbCiDG08A(nx6)ND(QnVoCqKB(nlPpnw428QtzbN51elfOMqKeVgC45cz0NZDvsyW1WsiSS5qa)oCanuHsrIUKPWdFjWZ(SgSNBsHBxiFtQeg8xGjxcHLnhcW8hhowlpbcl1Q0ohUCjew2CiGFxRLNaHLAvANdxMDn3KkHb)fyYLqyzZXaJbsZR53CP)F25R286WbXdzk8G1NWH8wfoLfCMxtSuGAcrs8AqQdhRqtLFHrYB4KTpIVj(a5azTmaN)yP2ADayE0KLAs8bsZR53CP)XsT1kh3HmfopCeiNYcoS2MgkJKCnCZSUZgMdhyTnnugjTZHhwcHL9aP518BU0)yP2ALxhoiYRAlISHfqKC1PSGBf60hU)Q0kpuj9PwZv87Y)p78vB5DYy2g(sOSpxLlHWYMdb87cAQXOwLOlzk8Wxc8SpRb75MlS2MgkJKCnCZSUZg2aP518BU0)yP2ALxhoiYRAlISHfqKC1PSGdAQXOwLOlzk8Wxc8SpRb75MlS2MgkJK25WdlHWYEG08A(nx6FSuBTYRdhe5vTfr2WcisU6uwWPgJAvIUKPWdFjWZ(SgSNBUqgvOuKOlzk8Wxc8SpRb75Mu42fYyTnnugj5A4MzDNnmxRqN(W9xLw5HkPp1Aqsm5WbwBtdLrs7C4HLqyz7Af60hU)Q0kpuj9PwdMdtoCG120qzK0ohEyjew2Uwlpbcl1Q0ohUCjew2Ci4EXWHdOHkuks0LmfE4lbE2N1G9CtkC7Y)p78vBj6sMcp8Lap7ZAWEUjxcHLnhJbsZR53CP)XsT1kVoCq0qFezBA(DGLiqDkl48)ZoF1wENmMTHVek7Zv5siSS5qa)UWABAOmsY1WnZ6oByUqwng1QeDjtHh(sGN9znyp3CTcD6d3FvALhQK(uHaMdtU8)ZoF1wIUKPWdFjWZ(SgSNBYLqyzZHaEoCan1yuRs0LmfE4lbE2N1G9CdJbsZR53CP)XsT1kVoCq0qFezBA(DGLiqDkl4WABAOmsANdpSecl7bsZR53CP)XsT1kVoCqKd38qXOGcNccD1Fv4v4uwWH120qzKKRHBM1D2WCHS)F25R2Y7KXSn8LqzFUkxcHLnhc43Hd1yuRY0tE7gJbsZR53CP)XsT1kVoCqKd38qXOGcNccD1Fv4v4uwWH120qzK0ohEyjew2dKMxZV5s)JLARvED4GyHrC4(1kQtzbh0qfkf5DYy2g(sOSpxLc3UGgQqPirxYu4HVe4zFwd2ZnPWTlK5Vadn7J8wGRcmkqRWTMF7Wb)fyOzFKyFMPjJc8NHLAfdNYwPDfU1qIabDstjCxDkBL2v4wdWypQXWD1PSvAxHBnKfC8xGHM9rI9zMMmkWFgwQ1bYbYAzayMOSuP1087bSVAA(9aP518BU8rzPsRP534wcXVCIrCEOA2kToLfCMxtSuGAcrs8AWHFxyTnnugj3QbuHsHpqAEn)MlFuwQ0AA(DD4Gi8VklBybuMXvNYcoOHkuksOsglBybeMhE2Ku421k0un4WVlKrfkf5Mii5siSS5qa)Uqfkf5MiiPWTdhMxtSu48QSSpxdfclTqW8AILcutisIJXaP518BU8rzPsRP531HdIL95k3xHcNCkl4qfkfjujJLnSacZdpBsUK5vx8BIXcQTWiLll7ZvUVcfovdo8CbnS2MgkJKhYu48WrGcMxtS0aP518BU8rzPsRP531HdIpklvAnLCYxHNrb1wyKYXD1PSGdvOuKqLmw2Wcimp8Sj5sMxhinVMFZLpklvAnn)UoCqegZ8PXc2bR1EYPSGJFtmwqTfgPCjmM5tJfSdwR9un4WZfYRqN(W9xLw5HkPpviCftoCScnj1ebf0pGxnW8hmC4a5dHkukY1C)Ftpj5Q5Hcci1HJdHkukY1C)FtpjxcHLnhcxrkgdKMxZV5YhLLkTMMFxhoiw2NRbUUjuKtzbN51elfOMqKeh3vxyTnnugjl7Z1ax3ekk4)(iKkFG08A(nx(OSuP10876Wbr4Fvw2WcOmJRoLfCyTnnugj3xl(WMiix8BIXcQTWiLlH)vzzdlGYmUwdo8ginVMFZLpklvAnn)UoCqegZ8PXc2bR1EYPSGJFtmwqTfgPCjmM5tJfSdwR9un4WBG08A(nx(OSuP10876WbXY(CnW1nHICYxHNrb1wyKYXD1PSGdAQXOwLgwJzTho5cAOcLIeQKXYgwaH5HNnjfUD4qng1Q0WAmR9WjxqdRTPHYi5(AXh2eb5WbwBtdLrY91IpSjcY1k0Kuteuq)aE1GdM)mqAEn)MlFuwQ0AA(DD4Gi8VklBybuMXvNYcoS2MgkJK7RfFyte0aP518BU8rzPsRP531HdIpklvAnLCYxHNrb1wyKYXDDGCGSwgas4)SSHnaKGFhaMjklvAnn)2DdquTv5d4kMgaN8FF4daLk)sdajmzmBhWxgasW(CDa(hbXhWxkdW54lginVMFZLpklvAnn)oC)plBy4wcXVCIrCEOA2kToLfCyTnnugj3QbuHsH7WH51elfOMqKeVgC4nqAEn)MlFuwQ0AA(D4(Fw2WQdhel7Z1ax3ekYPSGZ8AILcutisIJ7QlS2MgkJKL95AGRBcff8FFesLpqAEn)MlFuwQ0AA(D4(Fw2WQdheFuwQ0Ak5KVcpJcQTWiLJ7QtzbhQqPiHkzSSHfqyE4ztYLmVoqAEn)MlFuwQ0AA(D4(Fw2WQdheH)vzzdlGYmU6uwWH120qzKCFT4dBIGginVMFZLpklvAnn)oC)plBy1HdIWyMpnwWoyT2toLfC8BIXcQTWiLlHXmFASGDWATNQbhEUwHo9H7VkTYdvsFQqaZHPbsZR53C5JYsLwtZVd3)ZYgwD4GyzFUg46Mqro5RWZOGAlms54U6uwWTcD6d3FvALhQK(uHqTgtdKMxZV5YhLLkTMMFhU)NLnS6WbXhLLkTMso5RWZOGAlms54U6uwWTcnvdo8pqAEn)MlFuwQ0AA(D4(Fw2WQdhel7ZvUVcfo5uwWzEnXsbQjejXRbhs6cAyTnnugjpKPW5HJafmVMyPbYbYAzaUhZNgBayE0KLAs8bsZR53C5A(0yCCOS)pHIWwHtzbhQqPiVtgZ2WxcL95Qu4EG08A(nxUMpngVoCqeLwoTqLnmNYcouHsrENmMTHVek7ZvPW9aP518BUCnFAmED4GOTERPWTaJtoLfCidnuHsrENmMTHVek7ZvPWTlZRjwkqnHijEn4WddhoGgQqPiVtgZ2WxcL95Qu42fYRqtYdvsFQ1GdPUwHo9H7VkTYdvsFQ1GdZHjmginVMFZLR5tJXRdhezjm4kpGzeHdmeuRoLfCOcLI8ozmBdFju2NRsH7bsZR53C5A(0y86WbrR9exxJf8gJ5uwWHkukY7KXSn8LqzFUkfUDHkukscX9xL2Wk0uOkz3FlfUhinVMFZLR5tJXRdhel5sOS)poLfCOcLI8ozmBdFju2NRYLqyzZHao8PluHsrENmMTHVek7ZvPWTluHsrsiU)Q0gwHMcvj7(BPW9aP518BUCnFAmED4GiQbl8LGUPhkUtzbhQqPiVtgZ2WxcL95Qu42L51elfOMqKeh3vxiJkukY7KXSn8LqzFUkxcHLnhci1LAmQvP)zNaCYwvsTHYOJdhqtng1Q0)StaozRkP2qz0XfQqPiVtgZ2WxcL95QCjew2CiGFmgihiRLbiQwFS9maE2WyeMb1wyKoG9vtZVhinVMFZLC16JThClH4xoXiopunBLwNYcoS2MgkJKB1aQqPWhinVMFZLC16JTN6WbXhLLkTMsoLfCOcLIeQKXYgwaH5HNnjxY86aP518BUKRwFS9uhoic)RYYgwaLzC1PSGdRTPHYi5(AXh2eb5cvOuKBIGKlHWYMdb8pqAEn)Ml5Q1hBp1HdIL95AGRBcf5uwWH120qzKSSpxdCDtOOG)7JqQ8bsZR53CjxT(y7PoCqegZ8PXc2bR1EYPSGdAhYu4bO6egCvUcnv(fgjxZ9)n9KlKpeQqPixZ9)n9KKRMhkiGuhooeQqPixZ9)n9KCjew2CiuRXyG08A(nxYvRp2EQdhel7Z1ax3ekYPSGZ)p78vB5si(LtmIZdvZwPvUeclBoeWHhseM)4sng1QeMPWPnBybU(lIbsZR53CjxT(y7PoCqe(xLLnSakZ4QtzbhwBtdLrY91IpSjcAG08A(nxYvRp2EQdheFuwQ0Ak5uwWbnuHsrw239PoClW4Ku42LAmQvzzF3N6WTaJtoCG120qzK8qMcNhocuW8AILCHkukYdzkCE4iqsUAEOGas6WXk0Kuteuq)ascbCW8NbsZR53CjxT(y7PoCqSSpxdCDtOiNYcUvOtF4(RsR8qL0Nkeq(ksRtng1QCf60hmvPwW08BKisXyG08A(nxYvRp2EQdheFuwQ0Ak5uwWTcD6d3FvALhQK(uRbz8qADQXOwLRqN(GPk1cMMFJerkgdKMxZV5sUA9X2tD4GyzFUg46MqrdKMxZV5sUA9X2tD4Gi8F7WxcvZwPDG08A(nxYvRp2EQdheT1Bnf0FxQ1bYbYAzavUzdfP8bsZR53CPUzdfPCCzZ9RGAOmkuReSwfqeoe20toLfCOcLI8ozmBdFju2NRsHBhouBHrQuteuq)WTxd4HjiGuhoqFo3vjHbxdlHWYMdb8UoqwldOs40a0nBOiDavtf(au40aGNWGtCDaexteMsNbG1ycKtdOAYydaLgGaNodOKlxhG1NbCB5sNbunv4dajmzmBhWxgasW(CvoqAEn)Ml1nBOiLxhoiQB2qr6vNYcoOH120qzKKFt(SK0jOB2qrQluHsrENmMTHVek7ZvPWTlKHMAmQvz6jVD7WHAmQvz6jVD7cvOuK3jJzB4lHY(CvUeclBEn4UIjmCHm00nBOivINeUXd()zNVA7WHUzdfPs8K()zNVAlxcHLn3HdS2MgkJK6MnuKgU383uRa3vmC4q3SHIu5vjQqPeocRP531GRKWGRHLqyzZhinVMFZL6MnuKYRdhe1nBOifpNYcoOH120qzKKFt(SK0jOB2qrQluHsrENmMTHVek7ZvPWTlKHMAmQvz6jVD7WHAmQvz6jVD7cvOuK3jJzB4lHY(CvUeclBEn4UIjmCHm00nBOivEvc34b))SZxTD4q3SHIu5vP)F25R2YLqyzZD4aRTPHYiPUzdfPH7n)n1kWHhgoCOB2qrQepjQqPeocRP531GRKWGRHLqyzZhiRLbGpkd4Bwfd4BAaFpabonaDZgkshW9(yZdXhGnauHsXPbiWPbOWPb8kCAhW3dW)p78vB5aWm3bKLb0uQWPDa6MnuKoG79XMhIpaBaOcLItdqGtda9v4d47b4)ND(QTCG08A(nxQB2qrkVoCqu3SHI0RoLfCqt3SHIu5vjCJhe4uavOuCHSUzdfPs8K()zNVAlxcHLn3HdOPB2qrQepjCJhe4uavOuWWHd))SZxTL3jJzB4lHY(CvUeclBEn4HPbsZR53CPUzdfP86WbrDZgksXZPSGdA6MnuKkXtc34bbofqfkfxiRB2qrQ8Q0)p78vB5siSS5oCanDZgksLxLWnEqGtbuHsbdho8)ZoF1wENmMTHVek7Zv5siSS51GhMII8BYhDdpKEnQrngb]] )


end
