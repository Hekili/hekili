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


    spec:RegisterPvpTalents( {
        cadaverous_pallor = 3515, -- 201995
        chill_streak = 706, -- 305392
        dark_simulacrum = 3512, -- 77606
        dead_of_winter = 3743, -- 287250
        deathchill = 701, -- 204080
        delirium = 702, -- 233396
        dome_of_ancient_shadow = 5369, -- 328718
        heartstop_aura = 3439, -- 199719
        necrotic_aura = 43, -- 199642
        transfusion = 3749, -- 288977
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
            duration = 3600,
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
            duration = 15,
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

        heartstop_aura = {
            id = 199719,
            duration = 3600,
            max_stack = 1,
        },

        lichborne = {
            id = 287081,
            duration = 10,
            max_stack = 1,
        },

        transfusion = {
            id = 288977,
            duration = 7,
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


    spec:RegisterHook( "reset_precast", function ()
        local control_expires = action.control_undead.lastCast + 300

        if control_expires > now and pet.up then
            summonPet( "controlled_undead", control_expires - now )
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
            cooldown = 120,
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

            spend = function () return buff.dark_succor.up and 0 or ( ( ( buff.transfusion.up and 0.5 or 1 ) * 35 ) * ( buff.hypothermic_presence.up and 0.65 and 1 ) ) end,
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

            handler = function ()
                applyDebuff( "target", "razorice", 20, 2 )
                if talent.obliteration.enabled and buff.pillar_of_frost.up then applyBuff( "killing_machine" ) end
                removeBuff( "eradicating_blow" )
                if conduit.unleashed_frenzy.enabled then addStack( "eradicating_frenzy", nil, 1 ) end
                -- if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end
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
                -- if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end

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
            cooldown = 45,
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

            handler = function ()
                -- applies unholy_strength (53365)
            end,
        },


        transfusion = {
            id = 288977,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = -20,
            spendType = "runic_power",

            startsCombat = false,
            texture = 237515,

            pvptalent = "transfusion",

            handler = function ()
                applyBuff( "transfusion" )
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

        potion = "potion_of_unbridled_fury",

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


    spec:RegisterPack( "Frost DK", 20201013, [[dKeYvcqirLEeqkTjkYOejDkrIvjQIELiQzjcDlrq0Uq5xIsgMOQoMsvltu0ZebMgqQUMOITjcsFtuLY4asX5ebvRtuLqZdiUhG2NivhueuYcffEOOkrtuuLKUOii0gfvPAKIGs1jfbfTsKsVuee4MIGcTtrKFkckyOIQKyPIQe8uKmvrkFvee0Ej1FjAWu6WuTyv1JrmzLCzOntYNby0a1PLSArvs9AKIzt42kLDRYVvmCkCCrvy5s9CunDHRRkBhi57uuJxeukNxPY6fLA(iv7h069600ulpqDszMFM5Vp)9jGLpOjhqpbGgnvSZa1ugoHghaQPoFd1u59E4b0MxnHanLHVtm(sNMMIpVMGAkWryWZlMvwaQa87ZiZww8A7j8OMJ0UkYIxBKS0u)xjIeMN(RPwEG6KYm)mZFF(7talFqtoGEcYBAk)fGNwtrvB5LAkW1AHN(RPwiNOPaTqBEVhEaT5vrpadTjeCfaWbKwql0MWajMp2q7(eKi0Mz(zMpKwiTGwOnVeSFaqEEriTGwOnHeAtyEeXBHqBcJ1TG28EJy2idslOfAtiH2ewRf0QCH47eAGw10q7JxhaOnHyEHecteAZRm5DOTuqRHW3Hn0wxfLhihAZyOG2pQMgHwJze1baAfdGIaTfhAjZMHadCXG0cAH2esOnVeSFaqOn8gagSO2qzmYvHqBmqBuBOmg5QqOngO9XrOfpY8UaBOvGhGam02EagBOna7h0AmbEr5cOnANdgAxOhG5miTGwOnHeAZlhXcAtyh9oGw)wqB7KYfqBygDA4mnLO4bxNMMImILem6DOttN0EDAAk88Vax6m0uKUcSlxt9FkfJmILem6DW4HtObAthAZbAnbTrTHYyKRcHwqGwaKLMYjrnNMIa2RJlhLSiOo0jLPonnfE(xGlDgAksxb2LRPsfA)pLIXrmaxhaz7aqwJBEDCOfeOfazbTPaTMG2)tPyCedW1bq2oaK9m0uojQ50ueWEDC5OKfb1HoPeOtttHN)f4sNHMI0vGD5AQuH2)tPygLq4TCusvp8G14MxhhAbbi0cGSG28eAtfA3dTjdTKzeRX8Xu9WdZ76nUu96DSg91oOnfOLoDO9)ukMrjeElhLu1dpynU51XHwqG2(DilQnugJmbqBkqRjO9)ukMrjeElhLu1dpypdO1e0Mk06zJDfiRi7KKk8fkyTF0aTGaeA3dT0PdT)NsX(n6by5OK86wTdy4o7zaTPaTMG2CH2Wf4fSIGe3GHN)f4st5KOMttra71XLJsweuh6KaDDAAk88Vax6m0uKUcSlxt9FkfZOecVLJsQ6HhSg3864qliqlObAnbT)NsXEh4rStYJgpabywJBEDCOfeOfazbT5j0Mk0UhAtgAjZiwJ5JP6HhM31BCP617yn6RDqBkqRjO9)uk27apIDsE04biaZACZRJdTMG2)tPygLq4TCusvp8G9mGwtqBQqRNn2vGSIStsQWxOG1(rd0ccqODp0sNo0(Fkf73OhGLJsYRB1oGH7SNb0Mc0AcAZfAdxGxWkcsCdgE(xGlnLtIAonfbSxhxokzrqDOtkhDAAk88Vax6m0uKUcSlxtLk0(FkfRi7KKk8fkynU51XHwqGwqhAPthA)pLIvKDssf(cfSg3864qliqB)oKf1gkJrMaOnfO1e0(FkfRi7KKk8fkypdO1e06zJDfiRi7KKk8fkyTF0aTPdeAZeAnbT5cT)NsX(n6by5OK86wTdy4o7zaTMG2CH2Wf4fSIGe3GHN)f4st5KOMttra71XLJsweuh6KsO600u45FbU0zOPiDfyxUM6)ukwr2jjv4luWEgqRjO9)uk27apIDsE04biaZEgqRjO1Zg7kqwr2jjv4luWA)ObAthi0Mj0AcAZfA)pLI9B0dWYrj51TAhWWD2ZaAnbT5cTHlWlyfbjUbdp)lWLMYjrnNMIa2RJlhLSiOo0jL30PPPWZ)cCPZqtr6kWUCn1)PumJsi8wokPQhEWACZRJdTGaTGo0AcA)pLIzucH3Yrjv9Wd2ZaAnbTHlWlyfbjUbdp)lWf0AcA)pLIrgXscg9oy8Wj0aTPdeA3dAGwtqRNn2vGSIStsQWxOG1(rd0ccqODVMYjrnNMIa2RJlhLSiOo0jbA0PPPWZ)cCPZqtr6kWUCn1)PumJsi8wokPQhEWEgqRjOnCbEbRiiXny45FbUGwtqRNn2vGSIStsQWxOG1(rd0MoqOntO1e0Mk0(FkfJmILem6DW4HtObAthi0UpHdTMG2)tPyfzNKuHVqbRXnVoo0cc0cGSGwtq7)PuSIStsQWxOG9mGw60H2)tPyVd8i2j5rJhGam7zaTMG2)tPyKrSKGrVdgpCcnqB6aH29GgOnfnLtIAonfbSxhxokzrqDOdn18fvGTh1C600jTxNMMcp)lWLodnfPRa7Y1uHlWlya8am21bqYJP3y45FbU0uojQ50unUnnhfiNlnxxGTo0jLPonnfE(xGlDgAkNe1CAQ5lQaBpqnfPRa7Y1uPcTl8)ukw7zpDrqgpCcnqliqBoqlD6q7c)pLI1E2txeK14MxhhAbbA3Np0Mc0AcAZfAdxGxWu9Wdozxagz45FbUGwtqBUq7)PuSU2q2ZaAnbTCduiKH3aWGZapMf1bq(fopG20bcTjqtr2reOm8gagCDs71HoPeOtttHN)f4sNHMI0vGD5AQCH2Wf4fmvp8Gt2fGrgE(xGlO1e0Ml0(FkfRRnK9mGwtql3afcz4nam4mWJzrDaKFHZdOnDGqBc0uojQ50uZxub2EG6qNeORtttHN)f4sNHMI0vGD5AQuH2)tPy0ucrDaKBobCDiRrNeqlD6qBQq7)PumAkHOoaYnNaUoK9mGwtqBQqRrJGscGSy7zQE4HKhDrdcT0PdTgnckjaYITNbEmlQdG8lCEaT0PdTgnckjaYITNbq4KYfsFbk)ii0Mc0Mc0Mc0AcA5gOqidVbGbNP6HhCYUamcTPdeAZut5KOMttP6HhCYUamQdDs5OtttHN)f4sNHMYjrnNMA(IkW2dutr6kWUCnvQq7c)pLI1E2txeKXdNqd0cc0Md0sNo0UW)tPyTN90fbznU51XHwqG295dTPaTMG2)tPy0ucrDaKBobCDiRrNeqlD6qBQq7)PumAkHOoaYnNaUoK9mGwtqBQqRrJGscGSy7zQE4HKhDrdcT0PdTgnckjaYITNbEmlQdG8lCEaT0PdTgnckjaYITNbq4KYfsFbk)ii0Mc0MIMISJiqz4nam46K2RdDsjuDAAk88Vax6m0uKUcSlxt9FkfJMsiQdGCZjGRdzn6KaAPthAtfA)pLIrtje1bqU5eW1HSNb0AcAtfAnAeusaKfBpt1dpK8OlAqOLoDO1OrqjbqwS9mWJzrDaKFHZdOLoDO1OrqjbqwS9macNuUq6lq5hbH2uG2u0uojQ50uZxub2EG6qNuEtNMMcp)lWLodnfPRa7Y1uojkqHs8WTc5qB6qBMAkNe1CAQf6byUC9qDOtc0OtttHN)f4sNHMI0vGD5AkNefOqjE4wHCOnDOntnLtIAon1c9aS0VLCHeFNo0jLW1PPPWZ)cCPZqtr6kWUCnvQqBUq7)PuSU2q2ZaAPthA73vePXygB2cvfPcOfeODF(qlD6qB)oKf1gkJrMj0Mo0cGSG2uGwtql3afcz4nam4macNuUq6lq5hbH20bcTzQPCsuZPPaiCs5cPVaLFeuh6K2NVonnfE(xGlDgAksxb2LRP(pLI11gYEgqRjOLBGcHm8gagCg4XSOoaYVW5b0MoqOntnLtIAonf4XSOoaYVW5Ho0jTFVonnfE(xGlDgAkNe1CAkvp8qYJUOb1uKUcSlxtLk0UW)tPyTN90fbz8Wj0aTGaT5aT0PdTl8)ukw7zpDrqwJBEDCOfeODF(qBkqRjOnxO9)ukwxBi7zaT0PdT97kI0ymJnBHQIub0cc0UpFOLoDOTFhYIAdLXiZeAthAbqwqRjOnxOnCbEbt1dp4KDbyKHN)f4str2reOm8gagCDs71HoP9zQtttHN)f4sNHMI0vGD5AQCH2)tPyDTHSNb0sNo02VRisJXm2SfQksfqliq7(8Hw60H2(DilQnugJmtOnDOfazPPCsuZPPu9Wdjp6Iguh6K2NaDAAk88Vax6m0uKUcSlxt9FkfRRnK9m0uojQ50uGhZI6ai)cNh6qN0EqxNMMcp)lWLodnLtIAon18fvGThOMI0vGD5AQuH2f(FkfR9SNUiiJhoHgOfeOnhOLoDODH)NsXAp7PlcYACZRJdTGaT7ZhAtbAnbT5cTHlWlyQE4bNSlaJm88VaxAkYoIaLH3aWGRtAVo0jTphDAAkNe1CAQ5lQaBpqnfE(xGlDg6qhAQ)WLrrOPoa600jTxNMMcp)lWLodnfPRa7Y1uKzeRX8XWnJXm2Y(DO0m6gZXACZRJRPCsuZPPmkHWB5OKQE4Ho0jLPonnLtIAonfUzmMXw2VdLMr3yonfE(xGlDg6qNuc0PPPWZ)cCPZqt5KOMttnFrfy7bQPiDfyxUMkvODH)NsXAp7PlcY4HtObAbbAZbAPthAx4)PuS2ZE6IGSg3864qliq7(8H2uGwtqB)UIingZydTGaeAtqMqRjOnxOnCbEbt1dp4KDbyKHN)f4str2reOm8gagCDs71HojqxNMMcp)lWLodnfPRa7Y1u97kI0ymJn0ccqOnbzQPCsuZPPMVOcS9a1HoPC0PPPWZ)cCPZqtr6kWUCnv4c8cgapaJDDaK8y6ngE(xGlnLtIAonvJBtZrbY5sZ1fyRdDsjuDAAk88Vax6m0uKUcSlxt9FkfRRnK9m0uojQ50uGhZI6ai)cNh6qNuEtNMMcp)lWLodnLtIAon18fvGThOMI0vGD5AQuH2f(FkfR9SNUiiJhoHgOfeOnhOLoDODH)NsXAp7PlcYACZRJdTGaT7ZhAtbAnbT97qwuBOmgzoqliqlaYcAPthA73vePXygBOfeGqlONd0AcAZfAdxGxWu9Wdozxagz45FbU0uKDebkdVbGbxN0EDOtc0OtttHN)f4sNHMI0vGD5AQ(DilQnugJmhOfeOfazbT0PdT97kI0ymJn0ccqOf0Zrt5KOMttnFrfy7bQdDsjCDAAk88Vax6m0uKUcSlxt9FkfJMsiQdGCZjGRdzpdO1e0YnqHqgEdadot1dp4KDbyeAthi0MPMYjrnNMs1dp4KDbyuh6K2NVonnfE(xGlDgAksxb2LRP63vePXygB2cvfPcOnDGqBcYeAnbT97qwuBOmgzcG20HwaKLMYjrnNMc80NCusZ1fyRdDs73Rttt5KOMtt1420CuGCU0CDb2Ak88Vax6m0HoP9zQtttHN)f4sNHMI0vGD5AkUbkeYWBayWzQE4bNSlaJqB6aH2m1uojQ50uQE4bNSlaJ6qN0(eOtttHN)f4sNHMYjrnNMA(IkW2dutr6kWUCnvQq7c)pLI1E2txeKXdNqd0cc0Md0sNo0UW)tPyTN90fbznU51XHwqG295dTPaTMG2(DfrAmMXMTqvrQaAthAZmhOLoDOTFhcTPdTjaAnbT5cTHlWlyQE4bNSlaJm88VaxAkYoIaLH3aWGRtAVo0jTh01PPPWZ)cCPZqtr6kWUCnv)UIingZyZwOQivaTPdTzMd0sNo02VdH20H2eOPCsuZPPMVOcS9a1HoP95OtttHN)f4sNHMI0vGD5AQ(DfrAmMXMTqvrQaAthAZjFnLtIAonL3e)qzmDJxOdDOPqohpcY1PPtAVonnfE(xGlDgAksxb2LRP(pLIzucH3Yrjv9Wd2ZaAnbTPcT)NsXmkHWB5OKQE4bRXnVoo0cc0UpFO1e0Mk0(Fkf73OhGLJsYRB1oGH7SNb0sNo0gUaVGnFrfy7rnhdp)lWf0sNo0gUaVGveK4gm88VaxqRjOnxO1Zg7kqwr2jjv4luWWZ)cCbTPaT0PdT)NsXkYojPcFHc2ZaAnbTHlWlyfbjUbdp)lWf0MIMYjrnNM6lMzjhLmaJs8WTD6qNuM600u45FbU0zOPiDfyxUMkxOnCbEbRiiXny45FbUGw60H2Wf4fSIGe3GHN)f4cAnbTE2yxbYkYojPcFHcgE(xGlO1e0(FkfZOecVLJsQ6HhSg3864qliqBcfAnbT)NsXmkHWB5OKQE4b7zaT0PdTHlWlyfbjUbdp)lWf0AcAZfA9SXUcKvKDssf(cfm88VaxAkNe1CAkapVxLFYrj9SXEcW6qNuc0PPPWZ)cCPZqtr6kWUCn1)PumJsi8wokPQhEWACZRJdTGaT5aTMG2)tPygLq4TCusvp8G9mGw60H2O2qzmYvHqliqBoAkNe1CAkc4siK8OrNgDOtc01PPPWZ)cCPZqtr6kWUCn1)PuSgj0iqoxQMMGSNb0sNo0(FkfRrcncKZLQPjOKmVlWMXdNqd0cc0UFVMYjrnNMkaJY39N3TKQPjOo0jLJonnfE(xGlDgAksxb2LRPYfA)pLIzucH3Yrjv9Wd2ZaAnbT5cT)NsX(n6by5OK86wTdy4o7zOPCsuZPPud5XXL0Zg7kq5h9nDOtkHQtttHN)f4sNHMI0vGD5AQCH2)tPygLq4TCusvp8G9mGwtqBUq7)PuSFJEawokjVUv7agUZEgqRjODnbJmhbVO9axsLW3q5)1hRXnVoo0ceAZxt5KOMttrMJGx0EGlPs4BOo0jL30PPPWZ)cCPZqtr6kWUCn1)PumJsi8wokPQhEWEgqlD6q7)PumCZymJTSFhknJUXCSNb0sNo0sMrSgZh73OhGLJsYRB1oGH7Sg3864qB6qBcnFOnzODFoqlD6qlz6(ze1CCwDOs5FbkJ(fGz45FbU0uojQ50uMNwSafwNSr(C(rqDOtc0OtttHN)f4sNHMI0vGD5AQCH2)tPygLq4TCusvp8G9mGwtqBUq7)PuSFJEawokjVUv7agUZEgAkNe1CAQUmmeOSoj3WjOo0jLW1PPPWZ)cCPZqtr6kWUCn1)PumCZymJTSFhknJUXCSg3864qliqBoqRjO9)uk2VrpalhLKx3QDad3zpdOLoDOnvOTFhYIAdLXiZeAthAbqwqRjOTFxrKgJzSHwqG2CYhAtrt5KOMttTHBtVtokP4rQLC1OVX1HoP95RtttHN)f4sNHMI0vGD5AQCH2)tPygLq4TCusvp8G9mGwtqBUq7)PuSFJEawokjVUv7agUZEgqRjOnvOn8gagmWOlcWsdsaTPdeAbn5dT0PdTH3aWGbgDrawAqcOfeGqBM5dT0PdTQca4q24MxhhAbbAb9CG2u0uojQ50un6g1bqQe(gY1Ho0u)HlnMruhaDA6K2RtttHN)f4sNHMI0vGD5AQ)tPyDTHSNHMYjrnNMc8ywuha5x48qh6KYuNMMcp)lWLodnLtIAon18fvGThOMI0vGD5AQuH2f(FkfR9SNUiiJhoHgOfeOnhOLoDODH)NsXAp7PlcYACZRJdTGaT7ZhAtbAnbT97kI0ymJnBHQIub0MoqOnZCGwtqBUqB4c8cMQhEWj7cWidp)lWLMISJiqz4nam46K2RdDsjqNMMcp)lWLodnfPRa7Y1u97kI0ymJnBHQIub0MoqOnZC0uojQ50uZxub2EG6qNeORtttHN)f4sNHMI0vGD5AQ(DfrAmMXMTqvrQaAbbAZmFO1e0YnqHqgEdadodGWjLlK(cu(rqOnDGqBMqRjOLmJynMpMrjeElhLu1dpynU51XH20H2C0uojQ50uaeoPCH0xGYpcQdDs5OtttHN)f4sNHMYjrnNMs1dpK8OlAqnfPRa7Y1uPcTl8)ukw7zpDrqgpCcnqliqBoqlD6q7c)pLI1E2txeK14MxhhAbbA3Np0Mc0AcA73vePXygB2cvfPcOfeOnZ8HwtqBUqB4c8cMQhEWj7cWidp)lWf0AcAjZiwJ5JzucH3Yrjv9WdwJBEDCOnDOnhnfzhrGYWBayW1jTxh6KsO600u45FbU0zOPiDfyxUMQFxrKgJzSzluvKkGwqG2mZhAnbTKzeRX8XmkHWB5OKQE4bRXnVoo0Mo0MJMYjrnNMs1dpK8OlAqDOtkVPtttHN)f4sNHMI0vGD5AQ)tPy0ucrDaKBobCDi7zaTMG2(DfrAmMXMTqvrQaAthAtfA3Nd0Mm0gUaVG1VRispc8EEuZXWZ)cCbT5j0MaOnfO1e0YnqHqgEdadot1dp4KDbyeAthi0MPMYjrnNMs1dp4KDbyuh6Kan600u45FbU0zOPiDfyxUMQFxrKgJzSzluvKkG20bcTPcTjihOnzOnCbEbRFxrKEe498OMJHN)f4cAZtOnbqBkqRjOLBGcHm8gagCMQhEWj7cWi0MoqOntnLtIAonLQhEWj7cWOo0jLW1PPPWZ)cCPZqt5KOMttnFrfy7bQPiDfyxUMkvODH)NsXAp7PlcY4HtObAbbAZbAPthAx4)PuS2ZE6IGSg3864qliq7(8H2uGwtqB)UIingZyZwOQivaTPdeAtfAtqoqBYqB4c8cw)UIi9iW75rnhdp)lWf0MNqBcG2uGwtqBUqB4c8cMQhEWj7cWidp)lWLMISJiqz4nam46K2RdDs7ZxNMMcp)lWLodnfPRa7Y1u97kI0ymJnBHQIub0MoqOnvOnb5aTjdTHlWly97kI0JaVNh1Cm88VaxqBEcTjaAtrt5KOMttnFrfy7bQdDs73RtttHN)f4sNHMI0vGD5AkYmI1y(ygLq4TCusvp8G14MxhhAthA73HSO2qzmsqhAnbT97kI0ymJnBHQIub0cc0c65dTMGwUbkeYWBayWzaeoPCH0xGYpccTPdeAZut5KOMttbq4KYfsFbk)iOo0jTptDAAk88Vax6m0uojQ50uQE4HKhDrdQPiDfyxUMkvODH)NsXAp7PlcY4HtObAbbAZbAPthAx4)PuS2ZE6IGSg3864qliq7(8H2uGwtqlzgXAmFmJsi8wokPQhEWACZRJdTPdT97qwuBOmgjOdTMG2(DfrAmMXMTqvrQaAbbAb98HwtqBUqB4c8cMQhEWj7cWidp)lWLMISJiqz4nam46K2RdDs7tGonnfE(xGlDgAksxb2LRPiZiwJ5JzucH3Yrjv9WdwJBEDCOnDOTFhYIAdLXibDO1e02VRisJXm2SfQksfqliqlONVMYjrnNMs1dpK8OlAqDOdnLrJKz77HonDs71PPPWZ)cCPZqtD(gQP8S5G925s1CHCusJXm2AkNe1CAkpBoyVDUunxihL0ymJTo0jLPonnfE(xGlDgAQXqtXXqt5KOMttbkVl)lqnfOCXd1uPcTyE8kddCXUjMUMhxcq4RYJP5YVVaGqlD6qlMhVYWaxmY09ZiWLeGWxLhtZLFFbaHw60HwmpELHbUyKP7NrGljaHVkpMMl3WLle1CqlD6qlMhVYWaxmqvUqokPF1Mh4s(fZSGw60HwmpELHbUyQQ5HCZdKl5g7aiCohAPthAX84vgg4ILxJCj4XSaBOLoDOfZJxzyGl2nX0184sacFvEmnxUHlxiQ5Gw60HwmpELHbUyohmO8d5Y2ZEAjzAxaTPOPaL3YZ3qn1eGXwoN8XrjMhVYWax6qhAkYmI1y(4600jTxNMMcp)lWLodnLtIAonLNnhS3oxQMlKJsAmMXwtr6kWUCnvQqlzgXAmFmCZymJTSFhknJUXCSg91oO1e0Ml0ckVl)lq2eGXwoN8XrjMhVYWaxqBkqlD6qBQqlzgXAmFmJsi8wokPQhEWACZRJdTGaeA3Np0AcAbL3L)fiBcWylNt(4OeZJxzyGlOnfn15BOMYZMd2BNlvZfYrjngZyRdDszQtttHN)f4sNHMYjrnNMs8AAWMlRJxRAECjGsfAksxb2LRPcxGxW(n6by5OK86wTdy4odp)lWf0AcAtfAtfAjZiwJ5JzucH3Yrjv9WdwJBEDCOfeGq7(8HwtqlO8U8VaztagB5CYhhLyE8kddCbTPaT0PdTPcT)NsXmkHWB5OKQE4b7zaTMG2CHwq5D5FbYMam2Y5KpokX84vgg4cAtbAtbAPthAtfA)pLIzucH3Yrjv9Wd2ZaAnbT5cTHlWly)g9aSCusEDR2bmCNHN)f4cAtrtD(gQPeVMgS5Y641QMhxcOuHo0jLaDAAk88Vax6m0uojQ50uKDeXe9Cfr(fop0uKUcSlxtLl0(FkfZOecVLJsQ6HhSNHM68nutr2ret0Zve5x48qh6KaDDAAk88Vax6m0uKUcSlxtLk0sMrSgZhZOecVLJsQ6HhSg91oOLoDOLmJynMpMrjeElhLu1dpynU51XH20H2mZhAtbAnbTPcT5cTHlWly)g9aSCusEDR2bmCNHN)f4cAPthAjZiwJ5JHBgJzSL97qPz0nMJ14MxhhAthAt45aTPOPCsuZPPECuwbUX1HoPC0PPPWZ)cCPZqt5KOMtt5CWGYpKlBp7PLKPDHMI0vGD5AQf(FkfR9SNwsM2fYf(FkfBnMpn15BOMY5GbLFix2E2tljt7cDOtkHQtttHN)f4sNHMYjrnNMY5GbLFix2E2tljt7cnfPRa7Y1uKzeRX8XWnJXm2Y(DO0m6gZXACZRJdTPdTj88Hwtq7c)pLI1E2tljt7c5c)pLI9mGwtqlO8U8VaztagB5CYhhLyE8kddCbT0PdT)NsX(n6by5OK86wTdy4o7zaTMG2f(FkfR9SNwsM2fYf(Fkf7zaTMG2CHwq5D5FbYMam2Y5KpokX84vgg4cAPthA)pLIHBgJzSL97qPz0nMJ9mGwtq7c)pLI1E2tljt7c5c)pLI9mGwtqBUqB4c8c2VrpalhLKx3QDad3z45FbUGw60H2O2qzmYvHqliqBM71uNVHAkNdgu(HCz7zpTKmTl0HoP8MonnfE(xGlDgAkNe1CAQ8AKlbpMfyRPiDfyxUMkvOfZJxzyGlM410GnxwhVw184saLkGwtq7)PumJsi8wokPQhEWACZRJdTPaT0PdTPcT5cTyE8kddCXeVMgS5Y641QMhxcOub0AcA)pLIzucH3Yrjv9WdwJBEDCOfeODFMqRjO9)ukMrjeElhLu1dpypdOnfn15BOMkVg5sWJzb26qNeOrNMMcp)lWLodnLtIAonfn3eYrj9Ju4fs1R3PPiDfyxUMImJynMpgUzmMXw2VdLMr3yowJBEDCOnDOf0ZxtD(gQPO5MqokPFKcVqQE9oDOtkHRtttHN)f4sNHMYjrnNMcqphaU0ORnxiBhaQPiDfyxUMQFhcTGaeAta0AcAZfA)pLIzucH3Yrjv9Wd2ZaAnbTPcT5cT)NsX(n6by5OK86wTdy4o7zaT0PdT5cTHlWly)g9aSCusEDR2bmCNHN)f4cAtrtD(gQPa0ZbGln6AZfY2bG6qN0(81PPPWZ)cCPZqtD(gQPAp717OHl)fazJl5)fXCAkNe1CAQ2ZE9oA4YFbq24s(FrmNo0jTFVonnfE(xGlDgAkNe1CAQnSrAcWoxQ8dGMI0vGD5AQCH2)tPy)g9aSCusEDR2bmCN9mGwtqBUq7)PumJsi8wokPQhEWEgAQZ3qn1g2inbyNlv(bqh6K2NPonnfE(xGlDgAksxb2LRP(pLIzucH3Yrjv9Wd2ZaAnbT)NsXWnJXm2Y(DO0m6gZXEgAkNe1CAkJjQ50HoP9jqNMMcp)lWLodnfPRa7Y1u)NsXmkHWB5OKQE4b7zaTMG2)tPy4MXygBz)ouAgDJ5ypdnLtIAon1xmZsQE9oDOtApORtttHN)f4sNHMI0vGD5AQ)tPygLq4TCusvp8G9m0uojQ50uFS5yttDa0HoP95OtttHN)f4sNHMI0vGD5AQuH2CH2)tPygLq4TCusvp8G9mGwtqRtIcuOepCRqo0MoqOntOnfOLoDOnxO9)ukMrjeElhLu1dpypdO1e0Mk02VdzluvKkG20bcT5aTMG2(DfrAmMXMTqvrQaAthi0MqZhAtrt5KOMtt5nXpuA8eCuh6K2Nq1PPPWZ)cCPZqtr6kWUCn1)PumJsi8wokPQhEWEgAkNe1CAkrbaCWL51VfGn8cDOtAFEtNMMcp)lWLodnfPRa7Y1uH3aWGf1gkJrUkeAthA3d6AkNe1CAkoyNqJaLbyu(oZthG3PdDs7bn600u45FbU0zOPiDfyxUMYjrbkuIhUvihAthAZeAPthA)dNRPCsuZPP8)SvNh1CsrT91HoP9jCDAAk88Vax6m0uKUcSlxt5KOafkXd3kKdTPdTzcT0PdT)HZ1uojQ50uCZEVvha5wXdDOtkZ81PPPCsuZPPAV4OCH(stHN)f4sNHo0jL5EDAAk88Vax6m0uKUcSlxt9FkfZOecVLJsQ6HhSNb0AcA)pLIHBgJzSL97qPz0nMJ9m0uojQ50u(rqE0UqsCHqh6KYmtDAAk88Vax6m0uKUcSlxt9FkfZOecVLJsQ6HhSg3864qliaHwqd0AcA)pLIHBgJzSL97qPz0nMJ9m0uojQ50uQQXVyMLo0jLzc0PPPWZ)cCPZqtr6kWUCn1)PumJsi8wokPQhEWEgqRjOnvO9)ukMrjeElhLu1dpynU51XHwqG2CGwtqB4c8cgzeljy07GHN)f4cAPthAZfAdxGxWiJyjbJEhm88VaxqRjO9)ukMrjeElhLu1dpynU51XHwqG2eaTPaTMGwNefOqjE4wHCOfi0UhAPthA)pLIXrmaxhaz7aq2ZaAnbTojkqHs8WTc5qlqODVMYjrnNM67aKJsgDrOHRdDszc6600u45FbU0zOPiDfyxUMkvOLmJynMpgUzmMXw2VdLMr3yowJBEDCOLoDOnCbEbRiiXny45FbUG2uGwtqBUq7)PumJsi8wokPQhEWEgAkNe1CAkJsi8wokPQhEOdDszMJonnfE(xGlDgAksxb2LRPiZiwJ5JHBgJzSL97qPz0nMJ14MxhhAnbTKzeRX8XmkHWB5OKQE4bRXnVoUMYjrnNM63OhGLJsYRB1oGH7AQhhLJsjbqw6K2RdDszMq1PPPWZ)cCPZqtr6kWUCnfzgXAmFmJsi8wokPQhEWA0x7GwtqB4c8c28fvGTh1Cm88VaxqRjOTFhYIAdLXiZbAthAbqwqRjOTFxrKgJzSzluvKkG20bcT7ZhAPthAJAdLXixfcTGaTzMVMYjrnNMc3mgZyl73HsZOBmNo0jLzEtNMMcp)lWLodnfPRa7Y1uPcTKzeRX8XmkHWB5OKQE4bRrFTdAPthAJAdLXixfcTGaTzMp0Mc0AcAdxGxW(n6by5OK86wTdy4odp)lWf0AcA73vePXygBOnDOnHMVMYjrnNMc3mgZyl73HsZOBmNo0jLjOrNMMcp)lWLodnfPRa7Y1uHlWlyfbjUbdp)lWf0AcA73HqliqBc0uojQ50u4MXygBz)ouAgDJ50HoPmt4600uojQ50uG3zmbyS3kI0OroEeutHN)f4sNHo0jLG81PPPWZ)cCPZqtr6kWUCnv4c8cgzeljy07GHN)f4cAnbTPcTPcT)NsXiJyjbJEhmE4eAG20bcT7ZhAnbTl8)ukw7zpDrqgpCcnqlqOnhOnfOLoDOnQnugJCvi0ccqOfazbTPOPCsuZPPiUqiDsuZjffp0uIIhYZ3qnfzeljy07qh6KsWEDAAk88Vax6m0uKUcSlxtLk0(FkfZOecVLJsQ6HhSNb0AcA9SXUcKvKDssf(cfS2pAGwqacT7HwtqBQq7)PumJsi8wokPQhEWACZRJdTGaeAbqwqlD6q7)PuS3bEe7K8OXdqaM14MxhhAbbi0cGSGwtq7)PuS3bEe7K8OXdqaM9mG2uG2u0uojQ50uQE4H5D9gxQE9oDOtkbzQtttHN)f4sNHMI0vGD5AQuH2)tPyfzNKuHVqb7zaTMG2CH2Wf4fSIGe3GHN)f4cAnbTPcT)NsXEh4rStYJgpaby2ZaAPthA)pLIvKDssf(cfSg3864qliaHwaKf0Mc0Mc0sNo0(FkfRi7KKk8fkypdO1e0(FkfRi7KKk8fkynU51XHwqacTailO1e0gUaVGveK4gm88VaxqRjO9)ukMrjeElhLu1dpypdnLtIAonLQhEyExVXLQxVth6Ksqc0PPPWZ)cCPZqtr6kWUCnvuBOmg5QqOfeOfazbT0PdTPcTrTHYyKRcHwqGwYmI1y(ygLq4TCusvp8G14MxhhAnbT)NsXEh4rStYJgpaby2ZaAtrt5KOMttP6HhM31BCP6170Ho0u8WVL3lDA6K2Rttt5KOMtt1420CuGCU0CDb2Ak88Vax6m0HoPm1PPPWZ)cCPZqtr6kWUCnfzgXAmFSg3MMJcKZLMRlWM14MxhhAbbi0Mj0MNqlaYcAnbTHlWlya8am21bqYJP3y45FbU0uojQ50uQE4HKhDrdQdDsjqNMMcp)lWLodnfPRa7Y1u)NsX6AdzpdnLtIAonf4XSOoaYVW5Ho0jb6600u45FbU0zOPiDfyxUMkCbEbRiiXny45FbUGwtq7)PumJsi8wokPQhEWEgqRjO1Zg7kqwr2jjv4luWA)ObAthi0MPMYjrnNMA(IkW2duh6KYrNMMcp)lWLodnfPRa7Y1u5cT)NsXu9KnEsJNGJSNb0AcAdxGxWu9KnEsJNGJm88VaxAkNe1CAQ5lQaBpqDOtkHQtttHN)f4sNHMI0vGD5AQ(DfrAmMXMTqvrQaAbbAtfA3Nd0Mm0gUaVG1VRispc8EEuZXWZ)cCbT5j0MaOnfnLtIAonLQhEi5rx0G6qNuEtNMMcp)lWLodnfPRa7Y1u)NsXOPeI6ai3Cc46q2ZaAnbT97qwuBOmgjOdTPdeAbqwAkNe1CAkvp8Gt2fGrDOtc0OtttHN)f4sNHMI0vGD5AQ(DfrAmMXMTqvrQaAthAtfAZmhOnzOnCbEbRFxrKEe498OMJHN)f4cAZtOnbqBkAkNe1CAQ5lQaBpqDOtkHRttt5KOMttP6HhsE0fnOMcp)lWLodDOtAF(600uojQ50uGN(KJsAUUaBnfE(xGlDg6qN0(9600uojQ50uEt8dLX0nEHMcp)lWLodDOdn1cv(te600jTxNMMYjrnNMARULu1iMnQPWZ)cCPZqh6KYuNMMcp)lWLodnfPRa7Y1u5cTRjyQE4HuHGcBwueAQda0AcAtfAZfAdxGxW(n6by5OK86wTdy4odp)lWf0sNo0sMrSgZh73OhGLJsYRB1oGH7Sg3864qB6q7(CG2u0uojQ50uGhZI6ai)cNh6qNuc0PPPWZ)cCPZqtr6kWUCn1)PuSIStgUyooRXnVoo0ccqOfazbTMG2)tPyfzNmCXCC2ZaAnbTCduiKH3aWGZaiCs5cPVaLFeeAthi0Mj0AcAtfAZfAdxGxW(n6by5OK86wTdy4odp)lWf0sNo0sMrSgZh73OhGLJsYRB1oGH7Sg3864qB6q7(CG2u0uojQ50uaeoPCH0xGYpcQdDsGUonnfE(xGlDgAksxb2LRP(pLIvKDYWfZXznU51XHwqacTailO1e0(FkfRi7KHlMJZEgqRjOnvOnxOnCbEb73OhGLJsYRB1oGH7m88VaxqlD6qlzgXAmFSFJEawokjVUv7agUZACZRJdTPdT7ZbAtrt5KOMttP6HhsE0fnOo0jLJonnfE(xGlDgAkNe1CAkIlesNe1CsrXdnLO4H88nutHCoEeKRdDsjuDAAk88Vax6m0uojQ50uexiKojQ5KIIhAkrXd55BOMImJynMpUo0jL30PPPWZ)cCPZqtr6kWUCn1)PuSFJEawokjVUv7agUZEgAkNe1CAQ(DsNe1CsrXdnLO4H88nut9hUmkcn1bqh6Kan600u45FbU0zOPiDfyxUMkCbEb73OhGLJsYRB1oGH7m88VaxqRjOnvOnvOLmJynMp2VrpalhLKx3QDad3znU51XHwGqB(qRjOLmJynMpMrjeElhLu1dpynU51XHwqG295dTPaT0PdTPcTKzeRX8X(n6by5OK86wTdy4oRXnVoo0cc0Mz(qRjOnQnugJCvi0cc0MGCG2uG2u0uojQ50u97KojQ5KIIhAkrXd55BOM6pCPXmI6aOdDsjCDAAk88Vax6m0uKUcSlxt9FkfZOecVLJsQ6HhSNb0AcAdxGxWMVOcS9OMJHN)f4st5KOMtt1Vt6KOMtkkEOPefpKNVHAQ5lQaBpQ50HoP95RtttHN)f4sNHMI0vGD5AkNefOqjE4wHCOnDGqBMAkNe1CAQ(DsNe1CsrXdnLO4H88nut5dQdDs73RtttHN)f4sNHMYjrnNMI4cH0jrnNuu8qtjkEipFd1u8WVL3lDOdnLpOonDs71PPPWZ)cCPZqtr6kWUCnv4c8cgapaJDDaK8y6ngE(xGlOLoDOnvO1Zg7kqMQNSXtg4MbYdw7hnqRjOLBGcHm8gagCwJBtZrbY5sZ1fydTPdeAta0AcAZfA)pLI11gYEgqBkAkNe1CAQg3MMJcKZLMRlWwh6KYuNMMcp)lWLodnfPRa7Y1uHlWlyQE4bNSlaJm88VaxAkNe1CAkacNuUq6lq5hb1HoPeOtttHN)f4sNHMYjrnNMs1dpK8OlAqnfPRa7Y1uPcTl8)ukw7zpDrqgpCcnqliqBoqlD6q7c)pLI1E2txeK14MxhhAbbA3Np0Mc0AcAjZiwJ5J1420CuGCU0CDb2Sg3864qliaH2mH28eAbqwqRjOnCbEbdGhGXUoasEm9gdp)lWf0AcAZfAdxGxWu9Wdozxagz45FbU0uKDebkdVbGbxN0EDOtc01PPPWZ)cCPZqtr6kWUCnfzgXAmFSg3MMJcKZLMRlWM14MxhhAbbi0Mj0MNqlaYcAnbTHlWlya8am21bqYJP3y45FbU0uojQ50uQE4HKhDrdQdDs5OtttHN)f4sNHMI0vGD5AQ)tPyDTHSNHMYjrnNMc8ywuha5x48qh6KsO600u45FbU0zOPiDfyxUM6)ukgnLquha5MtaxhYEgAkNe1CAkvp8Gt2fGrDOtkVPtttHN)f4sNHMI0vGD5AQ(DfrAmMXMTqvrQaAbbAtfA3Nd0Mm0gUaVG1VRispc8EEuZXWZ)cCbT5j0MaOnfnLtIAonfaHtkxi9fO8JG6qNeOrNMMcp)lWLodnLtIAonLQhEi5rx0GAksxb2LRPsfAx4)PuS2ZE6IGmE4eAGwqG2CGw60H2f(FkfR9SNUiiRXnVoo0cc0UpFOnfO1e02VRisJXm2SfQksfqliqBQq7(CG2KH2Wf4fS(Dfr6rG3ZJAogE(xGlOnpH2eaTPaTMG2CH2Wf4fmvp8Gt2fGrgE(xGlnfzhrGYWBayW1jTxh6Ks4600u45FbU0zOPiDfyxUMQFxrKgJzSzluvKkGwqG2uH295aTjdTHlWly97kI0JaVNh1Cm88VaxqBEcTjaAtbAnbT5cTHlWlyQE4bNSlaJm88VaxAkNe1CAkvp8qYJUOb1HoP95RtttHN)f4sNHMI0vGD5AkNefOqjE4wHCOnDOntnLtIAon1c9amxUEOo0jTFVonnfE(xGlDgAksxb2LRPCsuGcL4HBfYH20H2m1uojQ50ul0dWs)wYfs8D6qN0(m1PPPCsuZPPACBAokqoxAUUaBnfE(xGlDg6qN0(eOttt5KOMttP6HhCYUamQPWZ)cCPZqh6K2d6600u45FbU0zOPCsuZPPMVOcS9a1uKUcSlxtLk0UW)tPyTN90fbz8Wj0aTGaT5aT0PdTl8)ukw7zpDrqwJBEDCOfeODF(qBkqRjOTFxrKgJzSzluvKkG20H2uH2mZbAtgAdxGxW63vePhbEppQ5y45FbUG28eAta0Mc0AcAZfAdxGxWu9Wdozxagz45FbU0uKDebkdVbGbxN0EDOtAFo600u45FbU0zOPiDfyxUMQFxrKgJzSzluvKkG20H2uH2mZbAtgAdxGxW63vePhbEppQ5y45FbUG28eAta0MIMYjrnNMA(IkW2duh6K2Nq1PPPCsuZPPaiCs5cPVaLFeutHN)f4sNHo0jTpVPtttHN)f4sNHMYjrnNMs1dpK8OlAqnfPRa7Y1uPcTl8)ukw7zpDrqgpCcnqliqBoqlD6q7c)pLI1E2txeK14MxhhAbbA3Np0Mc0AcAZfAdxGxWu9Wdozxagz45FbU0uKDebkdVbGbxN0EDOtApOrNMMYjrnNMs1dpK8OlAqnfE(xGlDg6qN0(eUonnLtIAonf4Pp5OKMRlWwtHN)f4sNHo0jLz(600uojQ50uEt8dLX0nEHMcp)lWLodDOdDOPaf28AoDszMFM5Vp)971uM9(QdaxtLWCZy6axq7(8HwNe1CqRO4bNbPvtXnqIoPmZzVMYOhvjqnfOfAZ79WdOnVk6byOnHGRaaoG0cAH2egiX8XgA3NGeH2mZpZ8H0cPf0cT5LG9daYZlcPf0cTjKqBcZJiEleAtySUf0M3BeZgzqAbTqBcj0MWATGwLleFNqd0QMgAF86aaTjeZlKqyIqBELjVdTLcAne(oSH26QO8a5qBgdf0(r10i0AmJOoaqRyaueOT4qlz2meyGlgKwql0MqcT5LG9dacTH3aWGf1gkJrUkeAJbAJAdLXixfcTXaTpocT4rM3fydTc8aeGH22dWydTby)GwJjWlkxaTr7CWq7c9amNbPf0cTjKqBE5iwqBc7O3b063cABNuUaAdZOtdNbPfslOfAtiMWgsEbUG2pQMgHwYS99aA)iG64mOnHfHGgbhAV5sib79M6jGwNe1CCODoXogKwNe1CCMrJKz77bWhhLvGBjE(gc0ZMd2BNlvZfYrjngZydP1jrnhNz0iz2(EKmWSaL3L)fyINVHaNam2Y5KpokX84vgg4krq5IhcmvmpELHbUy3etxZJlbi8v5X0C53xaq60X84vgg4IrMUFgbUKae(Q8yAU87laiD6yE8kddCXit3pJaxsacFvEmnxUHlxiQ5OthZJxzyGlgOkxihL0VAZdCj)Izw0PJ5XRmmWftvnpKBEGCj3yhaHZ50PJ5XRmmWflVg5sWJzb20PJ5XRmmWf7My6AECjaHVkpMMl3WLle1C0PJ5XRmmWfZ5GbLFix2E2tljt7IuG0cPf0cTjetydjVaxqlckS3bTrTHqBagHwNetdTfhADq5LW)cKbP1jrnhh4wDlPQrmBeslOfAtyzyi2bT59E4b0M3rqHn063cA386cVoOnHjzh0MMlMJdP1jrnhpzGzbEmlQdG8lCEKyPaM7AcMQhEiviOWMffHM6ayk1CdxGxW(n6by5OK86wTdy4odp)lWfD6KzeRX8X(n6by5OK86wTdy4oRXnVoE67ZjfiTojQ54jdmlacNuUq6lq5hbtSua)pLIvKDYWfZXznU51XbbiaYY0)PuSIStgUyoo7zyIBGcHm8gagCgaHtkxi9fO8JGPdmttPMB4c8c2VrpalhLKx3QDad3z45FbUOtNmJynMp2VrpalhLKx3QDad3znU51XtFFoPaP1jrnhpzGzP6HhsE0fnyILc4)PuSIStgUyooRXnVooiabqwM(pLIvKDYWfZXzpdtPMB4c8c2VrpalhLKx3QDad3z45FbUOtNmJynMp2VrpalhLKx3QDad3znU51XtFFoPaP1jrnhpzGzrCHq6KOMtkkEK45BiqKZXJGCiTojQ54jdmlIlesNe1CsrXJepFdbsMrSgZhhsRtIAoEYaZQFN0jrnNuu8iXZ3qG)HlJIqtDasSua)pLI9B0dWYrj51TAhWWD2ZasRtIAoEYaZQFN0jrnNuu8iXZ3qG)HlnMruhGelfWWf4fSFJEawokjVUv7agUZWZ)cCzk1ujZiwJ5J9B0dWYrj51TAhWWDwJBEDCG5BImJynMpMrjeElhLu1dpynU51XbzF(PqNEQKzeRX8X(n6by5OK86wTdy4oRXnVooizMVPO2qzmYvHGKGCsjfiTojQ54jdmR(DsNe1CsrXJepFdboFrfy7rnxILc4)PumJsi8wokPQhEWEgMcxGxWMVOcS9OMJHN)f4csRtIAoEYaZQFN0jrnNuu8iXZ3qG(GjwkGojkqHs8WTc5PdmtiTojQ54jdmlIlesNe1CsrXJepFdbYd)wEVG0cPf0cTjSMeIqBEHj8OMdsRtIAooZheyJBtZrbY5sZ1fyNyPagUaVGbWdWyxhajpMEJHN)f4Io9u9SXUcKP6jB8KbUzG8G1(rJjUbkeYWBayWznUnnhfiNlnxxGD6atGPC)pLI11gYEgPaP1jrnhN5dMmWSaiCs5cPVaLFemXsbmCbEbt1dp4KDbyKHN)f4csRtIAooZhmzGzP6HhsE0fnyIKDebkdVbGbh4(elfWux4)PuS2ZE6IGmE4eAajh60x4)PuS2ZE6IGSg3864GSp)umrMrSgZhRXTP5Oa5CP56cSznU51XbbyM5jaYYu4c8cgapaJDDaK8y6ngE(xGlt5gUaVGP6HhCYUamYWZ)cCbP1jrnhN5dMmWSu9Wdjp6IgmXsbKmJynMpwJBtZrbY5sZ1fyZACZRJdcWmZtaKLPWf4fmaEag76ai5X0Bm88VaxqADsuZXz(GjdmlWJzrDaKFHZJelfW)tPyDTHSNbKwNe1CCMpyYaZs1dp4KDbymXsb8)ukgnLquha5MtaxhYEgqADsuZXz(GjdmlacNuUq6lq5hbtSua73vePXygB2cvfPcqsDFojhUaVG1VRispc8EEuZXWZ)cCLNjifiTojQ54mFWKbMLQhEi5rx0Gjs2reOm8gagCG7tSuatDH)NsXAp7PlcY4HtObKCOtFH)NsXAp7PlcYACZRJdY(8tXu)UIingZyZwOQivasQ7Zj5Wf4fS(Dfr6rG3ZJAogE(xGR8mbPyk3Wf4fmvp8Gt2fGrgE(xGliTojQ54mFWKbMLQhEi5rx0GjwkG97kI0ymJnBHQIubiPUpNKdxGxW63vePhbEppQ5y45FbUYZeKIPCdxGxWu9Wdozxagz45FbUG06KOMJZ8btgywl0dWC56HjwkGojkqHs8WTc5PNjKwNe1CCMpyYaZAHEaw63sUqIVlXsb0jrbkuIhUvip9mH06KOMJZ8btgywnUnnhfiNlnxxGnKwNe1CCMpyYaZs1dp4KDbyesRtIAooZhmzGznFrfy7bMizhrGYWBayWbUpXsbm1f(FkfR9SNUiiJhoHgqYHo9f(FkfR9SNUiiRXnVooi7Zpft97kI0ymJnBHQIur6PMzojhUaVG1VRispc8EEuZXWZ)cCLNjift5gUaVGP6HhCYUamYWZ)cCbP1jrnhN5dMmWSMVOcS9atSua73vePXygB2cvfPI0tnZCsoCbEbRFxrKEe498OMJHN)f4kptqkqADsuZXz(GjdmlacNuUq6lq5hbH06KOMJZ8btgywQE4HKhDrdMizhrGYWBayWbUpXsbm1f(FkfR9SNUiiJhoHgqYHo9f(FkfR9SNUiiRXnVooi7Zpft5gUaVGP6HhCYUamYWZ)cCbP1jrnhN5dMmWSu9Wdjp6IgesRtIAooZhmzGzbE6tokP56cSH06KOMJZ8btgywEt8dLX0nEbKwiTGwOnJg9am0okOLQUv7agUdTgZiQda02t4rnh0MxeA5H3bhAZmFo0(r10i0MxPecVH2rbT59E4b0Mm0MXqbTEJqRdkVe(xGqADsuZXz)HlnMruhaGGhZI6ai)cNhjwkG)NsX6AdzpdiTojQ54S)WLgZiQdqYaZA(IkW2dmrYoIaLH3aWGdCFILcyQl8)ukw7zpDrqgpCcnGKdD6l8)ukw7zpDrqwJBEDCq2NFkM63vePXygB2cvfPI0bMzoMYnCbEbt1dp4KDbyKHN)f4csRtIAoo7pCPXmI6aKmWSMVOcS9atSua73vePXygB2cvfPI0bMzoqADsuZXz)HlnMruhGKbMfaHtkxi9fO8JGjwkG97kI0ymJnBHQIubizMVjUbkeYWBayWzaeoPCH0xGYpcMoWmnrMrSgZhZOecVLJsQ6HhSg3864PNdKwNe1CC2F4sJze1bizGzP6HhsE0fnyIKDebkdVbGbh4(elfWux4)PuS2ZE6IGmE4eAajh60x4)PuS2ZE6IGSg3864GSp)um1VRisJXm2SfQksfGKz(MYnCbEbt1dp4KDbyKHN)f4YezgXAmFmJsi8wokPQhEWACZRJNEoqADsuZXz)HlnMruhGKbMLQhEi5rx0GjwkG97kI0ymJnBHQIubizMVjYmI1y(ygLq4TCusvp8G14Mxhp9CG06KOMJZ(dxAmJOoajdmlvp8Gt2fGXelfW)tPy0ucrDaKBobCDi7zyQFxrKgJzSzluvKksp195KC4c8cw)UIi9iW75rnhdp)lWvEMGumXnqHqgEdadot1dp4KDbymDGzcP1jrnhN9hU0ygrDasgywQE4bNSlaJjwkG97kI0ymJnBHQIur6atnb5KC4c8cw)UIi9iW75rnhdp)lWvEMGumXnqHqgEdadot1dp4KDbymDGzcP1jrnhN9hU0ygrDasgywZxub2EGjs2reOm8gagCG7tSuatDH)NsXAp7PlcY4HtObKCOtFH)NsXAp7PlcYACZRJdY(8tXu)UIingZyZwOQivKoWutqojhUaVG1VRispc8EEuZXWZ)cCLNjift5gUaVGP6HhCYUamYWZ)cCbP1jrnhN9hU0ygrDasgywZxub2EGjwkG97kI0ymJnBHQIur6atnb5KC4c8cw)UIi9iW75rnhdp)lWvEMGuG06KOMJZ(dxAmJOoajdmlacNuUq6lq5hbtSuajZiwJ5JzucH3Yrjv9WdwJBED8073HSO2qzmsq3u)UIingZyZwOQivacONVjUbkeYWBayWzaeoPCH0xGYpcMoWmH06KOMJZ(dxAmJOoajdmlvp8qYJUObtKSJiqz4nam4a3NyPaM6c)pLI1E2txeKXdNqdi5qN(c)pLI1E2txeK14MxhhK95NIjYmI1y(ygLq4TCusvp8G14Mxhp9(DilQnugJe0n1VRisJXm2SfQksfGa65Bk3Wf4fmvp8Gt2fGrgE(xGliTojQ54S)WLgZiQdqYaZs1dpK8OlAWelfqYmI1y(ygLq4TCusvp8G14Mxhp9(DilQnugJe0n1VRisJXm2SfQksfGa65dPfslOfAZ7Uq8DcnqBmq7JJqBELjVNi0MqmVqcHqRzW4bTpo2jK1vr5bYH2mgkO1OXnpEnk2XG06KOMJZ(dxgfHM6aa0OecVLJsQ6HhjwkGKzeRX8XWnJXm2Y(DO0m6gZXACZRJdP1jrnhN9hUmkcn1bizGzHBgJzSL97qPz0nMdsRtIAoo7pCzueAQdqYaZA(IkW2dmrYoIaLH3aWGdCFILcyQl8)ukw7zpDrqgpCcnGKdD6l8)ukw7zpDrqwJBEDCq2NFkM63vePXygBqaMGmnLB4c8cMQhEWj7cWidp)lWfKwNe1CC2F4YOi0uhGKbM18fvGThyILcy)UIingZydcWeKjKwNe1CC2F4YOi0uhGKbMvJBtZrbY5sZ1fyNyPagUaVGbWdWyxhajpMEJHN)f4csRtIAoo7pCzueAQdqYaZc8ywuha5x48iXsb8)ukwxBi7zaP1jrnhN9hUmkcn1bizGznFrfy7bMizhrGYWBayWbUpXsbm1f(FkfR9SNUiiJhoHgqYHo9f(FkfR9SNUiiRXnVooi7Zpft97qwuBOmgzoGaGSOtVFxrKgJzSbbiONJPCdxGxWu9Wdozxagz45FbUG06KOMJZ(dxgfHM6aKmWSMVOcS9atSua73HSO2qzmYCabazrNE)UIingZydcqqphiTojQ54S)WLrrOPoajdmlvp8Gt2fGXelfW)tPy0ucrDaKBobCDi7zyIBGcHm8gagCMQhEWj7cWy6aZesRtIAoo7pCzueAQdqYaZc80NCusZ1fyNyPa2VRisJXm2SfQksfPdmbzAQFhYIAdLXitq6ailiTojQ54S)WLrrOPoajdmRg3MMJcKZLMRlWgsRtIAoo7pCzueAQdqYaZs1dp4KDbymXsbKBGcHm8gagCMQhEWj7cWy6aZesRtIAoo7pCzueAQdqYaZA(IkW2dmrYoIaLH3aWGdCFILcyQl8)ukw7zpDrqgpCcnGKdD6l8)ukw7zpDrqwJBEDCq2NFkM63vePXygB2cvfPI0Zmh6073HPNat5gUaVGP6HhCYUamYWZ)cCbP1jrnhN9hUmkcn1bizGznFrfy7bMyPa2VRisJXm2SfQksfPNzo0P3VdtpbqADsuZXz)HlJIqtDasgywEt8dLX0nErILcy)UIingZyZwOQivKEo5dPfslOfAZlhXcAbJEhqlzUvf1CCiTojQ54mYiwsWO3bqcyVoUCuYIGjwkG)NsXiJyjbJEhmE4eAsphtrTHYyKRcbbazbP1jrnhNrgXscg9osgyweWEDC5OKfbtSuat9)ukghXaCDaKTdaznU51XbbazLIP)tPyCedW1bq2oaK9mG06KOMJZiJyjbJEhjdmlcyVoUCuYIGjwkGP(FkfZOecVLJsQ6HhSg3864GaeazLNPUpzYmI1y(yQE4H5D9gxQE9owJ(Axk0P)FkfZOecVLJsQ6HhSg3864G0VdzrTHYyKjift)NsXmkHWB5OKQE4b7zykvpBSRazfzNKuHVqbR9JgqaUNo9)tPy)g9aSCusEDR2bmCN9msXuUHlWlyfbjUbdp)lWfKwNe1CCgzeljy07izGzra71XLJswemXsb8)ukMrjeElhLu1dpynU51Xbb0y6)uk27apIDsE04biaZACZRJdcaYkptDFYKzeRX8Xu9WdZ76nUu96DSg91Uum9Fkf7DGhXojpA8aeGznU51Xn9FkfZOecVLJsQ6HhSNHPu9SXUcKvKDssf(cfS2pAab4E60)pLI9B0dWYrj51TAhWWD2Zift5gUaVGveK4gm88VaxqADsuZXzKrSKGrVJKbMfbSxhxokzrWelfWu)pLIvKDssf(cfSg3864Ga60P)FkfRi7KKk8fkynU51XbPFhYIAdLXitqkM(pLIvKDssf(cfSNHjpBSRazfzNKuHVqbR9JM0bMPPC)pLI9B0dWYrj51TAhWWD2ZWuUHlWlyfbjUbdp)lWfKwNe1CCgzeljy07izGzra71XLJswemXsb8)ukwr2jjv4luWEgM(pLI9oWJyNKhnEacWSNHjpBSRazfzNKuHVqbR9JM0bMPPC)pLI9B0dWYrj51TAhWWD2ZWuUHlWlyfbjUbdp)lWfKwNe1CCgzeljy07izGzra71XLJswemXsb8)ukMrjeElhLu1dpynU51Xbb0n9FkfZOecVLJsQ6HhSNHPWf4fSIGe3GHN)f4Y0)PumYiwsWO3bJhoHM0bUh0yYZg7kqwr2jjv4luWA)ObeG7H06KOMJZiJyjbJEhjdmlcyVoUCuYIGjwkG)NsXmkHWB5OKQE4b7zykCbEbRiiXny45FbUm5zJDfiRi7KKk8fkyTF0KoWmnL6)PumYiwsWO3bJhoHM0bUpHB6)ukwr2jjv4luWACZRJdcaYY0)PuSIStsQWxOG9mOt))uk27apIDsE04biaZEgM(pLIrgXscg9oy8Wj0KoW9GMuG0cP1jrnhNrMrSgZhh4JJYkWTepFdb6zZb7TZLQ5c5OKgJzStSuatLmJynMpgUzmMXw2VdLMr3yowJ(ANPCbL3L)fiBcWylNt(4OeZJxzyGRuOtpvYmI1y(ygLq4TCusvp8G14MxhheG7Z3eO8U8VaztagB5CYhhLyE8kddCLcKwNe1CCgzgXAmF8KbM1JJYkWTepFdbkEnnyZL1XRvnpUeqPIelfWWf4fSFJEawokjVUv7agUZWZ)cCzk1ujZiwJ5JzucH3Yrjv9WdwJBEDCqaUpFtGY7Y)cKnbySLZjFCuI5XRmmWvk0PN6)PumJsi8wokPQhEWEgMYfuEx(xGSjaJTCo5JJsmpELHbUsjf60t9)ukMrjeElhLu1dpypdt5gUaVG9B0dWYrj51TAhWWDgE(xGRuG06KOMJZiZiwJ5JNmWSECuwbUL45BiqYoIyIEUIi)cNhjwkG5(FkfZOecVLJsQ6HhSNbKwNe1CCgzgXAmF8KbM1JJYkWnEILcyQKzeRX8XmkHWB5OKQE4bRrFTJoDYmI1y(ygLq4TCusvp8G14Mxhp9mZpftPMB4c8c2VrpalhLKx3QDad3z45FbUOtNmJynMpgUzmMXw2VdLMr3yowJBED80t45KcKwNe1CCgzgXAmF8KbM1JJYkWTepFdb6CWGYpKlBp7PLKPDrILc4c)pLI1E2tljt7c5c)pLITgZhKwNe1CCgzgXAmF8KbM1JJYkWTepFdb6CWGYpKlBp7PLKPDrILcizgXAmFmCZymJTSFhknJUXCSg3864PNWZ30c)pLI1E2tljt7c5c)pLI9mmbkVl)lq2eGXwoN8XrjMhVYWax0P)Fkf73OhGLJsYRB1oGH7SNHPf(FkfR9SNwsM2fYf(Fkf7zykxq5D5FbYMam2Y5KpokX84vgg4Io9)tPy4MXygBz)ouAgDJ5ypdtl8)ukw7zpTKmTlKl8)uk2ZWuUHlWly)g9aSCusEDR2bmCNHN)f4Io9O2qzmYvHGK5EiTojQ54mYmI1y(4jdmRhhLvGBjE(gcmVg5sWJzb2jwkGPI5XRmmWft8AAWMlRJxRAECjGsfM(pLIzucH3Yrjv9WdwJBED8uOtp1CX84vgg4IjEnnyZL1XRvnpUeqPct)NsXmkHWB5OKQE4bRXnVooi7Z00)PumJsi8wokPQhEWEgPaP1jrnhNrMrSgZhpzGz94OScClXZ3qG0CtihL0psHxivVExILcizgXAmFmCZymJTSFhknJUXCSg3864Pd65dP1jrnhNrMrSgZhpzGz94OScClXZ3qGa65aWLgDT5cz7aWelfW(DiiatGPC)pLIzucH3Yrjv9Wd2ZWuQ5(Fkf73OhGLJsYRB1oGH7SNbD65gUaVG9B0dWYrj51TAhWWDgE(xGRuG06KOMJZiZiwJ5JNmWSECuwbUL45BiW2ZE9oA4YFbq24s(FrmhKwNe1CCgzgXAmF8KbM1JJYkWTepFdbUHnsta25sLFasSuaZ9)uk2VrpalhLKx3QDad3zpdt5(FkfZOecVLJsQ6HhSNbKwNe1CCgzgXAmF8KbMLXe1CjwkG)NsXmkHWB5OKQE4b7zy6)ukgUzmMXw2VdLMr3yo2ZasRtIAooJmJynMpEYaZ6lMzjvVExILc4)PumJsi8wokPQhEWEgM(pLIHBgJzSL97qPz0nMJ9mG06KOMJZiZiwJ5JNmWS(yZXMM6aKyPa(FkfZOecVLJsQ6HhSNbKwNe1CCgzgXAmF8KbML3e)qPXtWXelfWuZ9)ukMrjeElhLu1dpypdtojkqHs8WTc5PdmZuOtp3)tPygLq4TCusvp8G9mmLA)oKTqvrQiDG5yQFxrKgJzSzluvKkshycn)uG06KOMJZiZiwJ5JNmWSefaWbxMx)wa2WlsSua)pLIzucH3Yrjv9Wd2ZasRtIAooJmJynMpEYaZId2j0iqzagLVZ80b4DjwkGH3aWGf1gkJrUkm99GoKwNe1CCgzgXAmF8KbML)NT68OMtkQTFILcOtIcuOepCRqE6zsN(F4CiTojQ54mYmI1y(4jdmlUzV3QdGCR4rILcOtIcuOepCRqE6zsN(F4CiTojQ54mYmI1y(4jdmR2lokxOVG06KOMJZiZiwJ5JNmWS8JG8ODHK4crILc4)PumJsi8wokPQhEWEgM(pLIHBgJzSL97qPz0nMJ9mG06KOMJZiZiwJ5JNmWSuvJFXmRelfW)tPygLq4TCusvp8G14MxhheGGgt)NsXWnJXm2Y(DO0m6gZXEgqADsuZXzKzeRX8XtgywFhGCuYOlcn8elfW)tPygLq4TCusvp8G9mmL6)PumJsi8wokPQhEWACZRJdsoMcxGxWiJyjbJEhm88Vax0PNB4c8cgzeljy07GHN)f4Y0)PumJsi8wokPQhEWACZRJdscsXKtIcuOepCRqoW90P)FkfJJyaUoaY2bGSNHjNefOqjE4wHCG7H0cPf0cT59E4b0sMrSgZhhsRtIAooJmJynMpEYaZYOecVLJsQ6HhjwkGPsMrSgZhd3mgZyl73HsZOBmhRXnVooD6HlWlyfbjUbdp)lWvkMY9)ukMrjeElhLu1dpypdiTojQ54mYmI1y(4jdmRFJEawokjVUv7agUN4JJYrPKailG7tSuajZiwJ5JHBgJzSL97qPz0nMJ14Mxh3ezgXAmFmJsi8wokPQhEWACZRJdP1jrnhNrMrSgZhpzGzHBgJzSL97qPz0nMlXsbKmJynMpMrjeElhLu1dpyn6RDMcxGxWMVOcS9OMJHN)f4Yu)oKf1gkJrMt6ailt97kI0ymJnBHQIur6a3NpD6rTHYyKRcbjZ8H06KOMJZiZiwJ5JNmWSWnJXm2Y(DO0m6gZLyPaMkzgXAmFmJsi8wokPQhEWA0x7OtpQnugJCviizMFkMcxGxW(n6by5OK86wTdy4odp)lWLP(DfrAmMXo9eA(qADsuZXzKzeRX8Xtgyw4MXygBz)ouAgDJ5sSuadxGxWkcsCdgE(xGlt97qqsaKwNe1CCgzgXAmF8KbMf4Dgtag7TIinAKJhbH06KOMJZiZiwJ5JNmWSiUqiDsuZjffps88neizeljy07iXsbmCbEbJmILem6DWWZ)cCzk1u)pLIrgXscg9oy8Wj0KoW95BAH)NsXAp7PlcY4HtObyoPqNEuBOmg5QqqacGSsbsRtIAooJmJynMpEYaZs1dpmVR34s1R3LyPaM6)PumJsi8wokPQhEWEgM8SXUcKvKDssf(cfS2pAab4EtP(FkfZOecVLJsQ6HhSg3864GaeazrN()PuS3bEe7K8OXdqaM14MxhheGailt)NsXEh4rStYJgpaby2ZiLuG06KOMJZiZiwJ5JNmWSu9WdZ76nUu96DjwkGP(FkfRi7KKk8fkypdt5gUaVGveK4gm88VaxMs9)uk27apIDsE04biaZEg0P)FkfRi7KKk8fkynU51XbbiaYkLuOt))ukwr2jjv4luWEgM(pLIvKDssf(cfSg3864GaeazzkCbEbRiiXny45FbUm9FkfZOecVLJsQ6HhSNbKwNe1CCgzgXAmF8KbMLQhEyExVXLQxVlXsbmQnugJCviiail60tnQnugJCviiKzeRX8XmkHWB5OKQE4bRXnVoUP)tPyVd8i2j5rJhGam7zKcKwiTojQ54mKZXJGCGFXml5OKbyuIhUTlXsb8)ukMrjeElhLu1dpypdtP(FkfZOecVLJsQ6HhSg3864GSpFtP(Fkf73OhGLJsYRB1oGH7SNbD6HlWlyZxub2EuZXWZ)cCrNE4c8cwrqIBWWZ)cCzkxpBSRazfzNKuHVqbdp)lWvk0P)FkfRi7KKk8fkypdtHlWlyfbjUbdp)lWvkqADsuZXziNJhb5jdmlapVxLFYrj9SXEcWjwkG5gUaVGveK4gm88Vax0PhUaVGveK4gm88VaxM8SXUcKvKDssf(cfm88VaxM(pLIzucH3Yrjv9WdwJBEDCqsOM(pLIzucH3Yrjv9Wd2ZGo9Wf4fSIGe3GHN)f4YuUE2yxbYkYojPcFHcgE(xGliTojQ54mKZXJG8KbMfbCjesE0OttILc4)PumJsi8wokPQhEWACZRJdsoM(pLIzucH3Yrjv9Wd2ZGo9O2qzmYvHGKdKwNe1CCgY54rqEYaZkaJY39N3TKQPjyILc4)PuSgj0iqoxQMMGSNbD6)NsXAKqJa5CPAAckjZ7cSz8Wj0aY(9qADsuZXziNJhb5jdml1qECCj9SXUcu(rFlXsbm3)tPygLq4TCusvp8G9mmL7)PuSFJEawokjVUv7agUZEgqADsuZXziNJhb5jdmlYCe8I2dCjvcFdtSuaZ9)ukMrjeElhLu1dpypdt5(Fkf73OhGLJsYRB1oGH7SNHP1emYCe8I2dCjvcFdL)xFSg3864aZhsRtIAood5C8iipzGzzEAXcuyDYg5Z5hbtSua)pLIzucH3Yrjv9Wd2ZGo9)tPy4MXygBz)ouAgDJ5ypd60jZiwJ5J9B0dWYrj51TAhWWDwJBED80tO5N8(COtNmD)mIAooRouP8VaLr)cWm88VaxqADsuZXziNJhb5jdmRUmmeOSoj3WjyILcyU)NsXmkHWB5OKQE4b7zyk3)tPy)g9aSCusEDR2bmCN9mG06KOMJZqohpcYtgywB4207KJskEKAjxn6B8elfW)tPy4MXygBz)ouAgDJ5ynU51Xbjht)NsX(n6by5OK86wTdy4o7zqNEQ97qwuBOmgzMPdGSm1VRisJXm2GKt(PaP1jrnhNHCoEeKNmWSA0nQdGuj8nKNyPaM7)PumJsi8wokPQhEWEgMY9)uk2VrpalhLKx3QDad3zpdtPgEdadgy0fbyPbjshiOjF60dVbGbdm6IaS0GeGamZ8PtxvaahYg3864Ga65KcKwiTGwOnHHVOcS9OMdA7j8OMdsRtIAooB(IkW2JAoGnUnnhfiNlnxxGDILcy4c8cgapaJDDaK8y6ngE(xGliTojQ54S5lQaBpQ5sgywZxub2EGjs2reOm8gagCG7tSuatDH)NsXAp7PlcY4HtObKCOtFH)NsXAp7PlcYACZRJdY(8tXuUHlWlyQE4bNSlaJm88VaxMY9)ukwxBi7zyIBGcHm8gagCg4XSOoaYVW5r6ataKwNe1CC28fvGTh1CjdmR5lQaBpWelfWCdxGxWu9Wdozxagz45FbUmL7)PuSU2q2ZWe3afcz4nam4mWJzrDaKFHZJ0bMaiTojQ54S5lQaBpQ5sgywQE4bNSlaJjwkGP(FkfJMsiQdGCZjGRdzn6KGo9u)pLIrtje1bqU5eW1HSNHPunAeusaKfBpt1dpK8OlAq60nAeusaKfBpd8ywuha5x48GoDJgbLeazX2ZaiCs5cPVaLFemLusXe3afcz4nam4mvp8Gt2fGX0bMjKwNe1CC28fvGTh1CjdmR5lQaBpWej7icugEdadoW9jwkGPUW)tPyTN90fbz8Wj0aso0PVW)tPyTN90fbznU51XbzF(Py6)ukgnLquha5MtaxhYA0jbD6P(FkfJMsiQdGCZjGRdzpdtPA0iOKail2EMQhEi5rx0G0PB0iOKail2Eg4XSOoaYVW5bD6gnckjaYITNbq4KYfsFbk)iykPaP1jrnhNnFrfy7rnxYaZA(IkW2dmXsb8)ukgnLquha5MtaxhYA0jbD6P(FkfJMsiQdGCZjGRdzpdtPA0iOKail2EMQhEi5rx0G0PB0iOKail2Eg4XSOoaYVW5bD6gnckjaYITNbq4KYfsFbk)iykPaP1jrnhNnFrfy7rnxYaZAHEaMlxpmXsb0jrbkuIhUvip9mH06KOMJZMVOcS9OMlzGzTqpal9BjxiX3LyPa6KOafkXd3kKNEMqADsuZXzZxub2EuZLmWSaiCs5cPVaLFemXsbm1C)pLI11gYEg0P3VRisJXm2SfQksfGSpF6073HSO2qzmYmthazLIjUbkeYWBayWzaeoPCH0xGYpcMoWmH06KOMJZMVOcS9OMlzGzbEmlQdG8lCEKyPa(FkfRRnK9mmXnqHqgEdadod8ywuha5x48iDGzcP1jrnhNnFrfy7rnxYaZs1dpK8OlAWej7icugEdadoW9jwkGPUW)tPyTN90fbz8Wj0aso0PVW)tPyTN90fbznU51XbzF(Pyk3)tPyDTHSNbD697kI0ymJnBHQIubi7ZNo9(DilQnugJmZ0bqwMYnCbEbt1dp4KDbyKHN)f4csRtIAooB(IkW2JAUKbMLQhEi5rx0GjwkG5(FkfRRnK9mOtVFxrKgJzSzluvKkazF(0P3VdzrTHYyKzMoaYcsRtIAooB(IkW2JAUKbMf4XSOoaYVW5rILc4)PuSU2q2ZasRtIAooB(IkW2JAUKbM18fvGThyIKDebkdVbGbh4(elfWux4)PuS2ZE6IGmE4eAajh60x4)PuS2ZE6IGSg3864GSp)umLB4c8cMQhEWj7cWidp)lWfKwNe1CC28fvGTh1CjdmR5lQaBpqiTqAbTqlv43Y7f0YRdGatidVbGb02t4rnhKwNe1CCgp8B59cyJBtZrbY5sZ1fydP1jrnhNXd)wEVsgywQE4HKhDrdMyPasMrSgZhRXTP5Oa5CP56cSznU51XbbyM5jaYYu4c8cgapaJDDaK8y6ngE(xGliTojQ54mE43Y7vYaZc8ywuha5x48iXsb8)ukwxBi7zaP1jrnhNXd)wEVsgywZxub2EGjwkGHlWlyfbjUbdp)lWLP)tPygLq4TCusvp8G9mm5zJDfiRi7KKk8fkyTF0KoWmH06KOMJZ4HFlVxjdmR5lQaBpWelfWC)pLIP6jB8KgpbhzpdtHlWlyQEYgpPXtWrgE(xGliTojQ54mE43Y7vYaZs1dpK8OlAWelfW(DfrAmMXMTqvrQaKu3NtYHlWly97kI0JaVNh1Cm88Vax5zcsbsRtIAooJh(T8ELmWSu9WdozxagtSua)pLIrtje1bqU5eW1HSNHP(DilQnugJe0thiaYcsRtIAooJh(T8ELmWSMVOcS9atSua73vePXygB2cvfPI0tnZCsoCbEbRFxrKEe498OMJHN)f4kptqkqADsuZXz8WVL3RKbMLQhEi5rx0GqADsuZXz8WVL3RKbMf4Pp5OKMRlWgsRtIAooJh(T8ELmWS8M4hkJPB8cDOdTga]] )

end
