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


    spec:RegisterPack( "Frost DK", 20200926, [[dKK2ucqirvEesiTjkQrjs6uIuwLOs6vIGzjI6wiHQ2fk)suYWev1XuQAzIcpteX0erY1evSnKq8nrLQghsOCorKY6evkY8qIUhG2NOOdkIuvluKQhkQuyIiHkCrrKk2OOsLrkIujNejuPvIu6LIkLQBkIuP2Pi0pfvkQgQisvwQOsP8uGMQiXxrcv0Ej5VenykDyQwSQ6XGMSsUm0Mj1Nby0iPtlz1IkL8AKIzt42kLDRYVvmCkCCrLy5s9CunDHRRkBhj47uKXlQuuoVsL1lk18rQ2pIv7vPOaxEGQeZi)mYp)Kwguew(jTmYjJCVcm2zGkqdhsJdavGNVHkWCxp8GyP4i3Uc0W3jgFPsrbYNxdrfi1im45MYklavq99zWzllET9eEuZbBxhzXRnywkW)Rebf3t9vGlpqvIzKFg5NFsldkcl)Kwg5Kpftb6VG60kqWAl3qbsTwl8uFf4c5qfifLyZD9WdILId0dQeBU9Raqni0srjwq0iWTp2eBguKKj2mYpJ8j0sOLIsS5gu9daYZnrOLIsSu8elf3dkElKyt6UUfXM7AeZgzeAPOelfpXM0FTiwTleFhsdXQNMyF86aqSjDYTrXzYeBsVj3rSLMyne(oSj26QO8a5eB6diX(r90iXAmJOoaeRyauqIT4elC2meyGlgHwkkXsXtS5gu9dasSH3aWGf1gkJrUkKyJHyJAdLXixfsSXqSposS4bN3fytSc8aeuj22dQytSbv)iwJjWlkxqSr7CQe7c9GkNrOLIsSu8eBUXiweBsxO3bX63IyBhwUGydtOtdNPaffp4QuuGWrSKurVdvkQe3RsrbIN)f4sLUce2vGD5kW)tRzWrSKurVdgpCineBMeBoeRzInQnugJCviXsjXcaUuGomQ5uGqQEDC5OLfevHkXmuPOaXZ)cCPsxbc7kWUCfyQe7)P1moIb16aiBhaYACZRJtSusSaGlInnI1mX(FAnJJyqToaY2bGSNHc0HrnNces1RJlhTSGOkujMevkkq88VaxQ0vGWUcSlxbMkX(FAnZOecVLJwQ7HhSg3864elLajwaWfXMReBQe7EInbIfoJynMoMUhEyAxVXL6xVJ1OV2rSPrS0PtS)NwZmkHWB5OL6E4bRXnVooXsjX2VdzrTHYyKjHytJyntS)NwZmkHWB5OL6E4b7zqSMj2ujwpBSRazfCNewHVqbR9JgILsGe7EILoDI9)0A2VrpOkhTKx3QDad3zpdInnI1mXMhXgUaVGvqe6gm88Vaxkqhg1CkqivVoUC0YcIQqLysPsrbIN)f4sLUce2vGD5kW)tRzgLq4TC0sDp8G14MxhNyPKyPyeRzI9)0A27OoIDsE04biOYACZRJtSusSaGlInxj2uj29eBcelCgXAmDmDp8W0UEJl1VEhRrFTJytJyntS)NwZEh1rStYJgpabvwJBEDCI1mX(FAnZOecVLJwQ7HhSNbXAMytLy9SXUcKvWDsyf(cfS2pAiwkbsS7jw60j2)tRz)g9GQC0sEDR2bmCN9mi20iwZeBEeB4c8cwbrOBWWZ)cCPaDyuZPaHu964YrlliQcvI5OsrbIN)f4sLUce2vGD5kWuj2)tRzfCNewHVqbRXnVooXsjXMuelD6e7)P1ScUtcRWxOG14MxhNyPKy73HSO2qzmYKqSPrSMj2)tRzfCNewHVqb7zqSMjwpBSRazfCNewHVqbR9JgIntGeBgeRzInpI9)0A2VrpOkhTKx3QDad3zpdI1mXMhXgUaVGvqe6gm88Vaxkqhg1CkqivVoUC0YcIQqLifrLIcep)lWLkDfiSRa7YvG)NwZk4ojScFHc2ZGyntS)NwZEh1rStYJgpabv2ZGyntSE2yxbYk4ojScFHcw7hneBMaj2miwZeBEe7)P1SFJEqvoAjVUv7agUZEgeRzInpInCbEbRGi0ny45FbUuGomQ5uGqQEDC5OLfevHkXCVkffiE(xGlv6kqyxb2LRa)pTMzucH3Yrl19WdwJBEDCILsInPiwZe7)P1mJsi8woAPUhEWEgeRzInCbEbRGi0ny45FbUiwZe7)P1m4iwsQO3bJhoKgIntGe7EkgXAMy9SXUcKvWDsyf(cfS2pAiwkbsS7vGomQ5uGqQEDC5OLfevHkrkMkffiE(xGlv6kqyxb2LRa)pTMzucH3Yrl19Wd2ZGyntSHlWlyfeHUbdp)lWfXAMy9SXUcKvWDsyf(cfS2pAi2mbsSzqSMj2uj2)tRzWrSKurVdgpCineBMaj29jnI1mX(FAnRG7KWk8fkynU51XjwkjwaWfXAMy)pTMvWDsyf(cfSNbXsNoX(FAn7DuhXojpA8aeuzpdI1mX(FAndoILKk6DW4HdPHyZeiXUNIrSPPaDyuZPaHu964YrlliQcvOaNVOcS9OMtLIkX9QuuG45FbUuPRaHDfyxUcmCbEbdGhuXUoasEm9gdp)lWLc0HrnNcSXTP5Oa5CPP6cSvHkXmuPOaXZ)cCPsxb6WOMtboFrfy7bQaHDfyxUcmvIDH)NwZAp7PliY4HdPHyPKyZHyPtNyx4)P1S2ZE6cISg3864elLe7(8j20iwZeBEeB4c8cMUhEWH7cQidp)lWfXAMyZJy)pTM11gYEgeRzILBGcHm8gagCg1XKOoaYVW5bXMjqInjkq4oOaLH3aWGRsCVkujMevkkq88VaxQ0vGWUcSlxbMhXgUaVGP7HhC4UGkYWZ)cCrSMj28i2)tRzDTHSNbXAMy5gOqidVbGbNrDmjQdG8lCEqSzcKytIc0HrnNcC(IkW2dufQetkvkkq88VaxQ0vGWUcSlxbMkX(FAnJMsiQdGCZHuRdzn6WGyPtNytLy)pTMrtje1bqU5qQ1HSNbXAMytLynAKcsaWfBpt3dpK8OlAqILoDI1OrkibaxS9mQJjrDaKFHZdILoDI1OrkibaxS9machwUq6lk4hej20i20i20iwZel3afcz4nam4mDp8Gd3furIntGeBgkqhg1CkqDp8Gd3furvOsmhvkkq88VaxQ0vGomQ5uGZxub2EGkqyxb2LRatLyx4)P1S2ZE6cImE4qAiwkj2Ciw60j2f(FAnR9SNUGiRXnVooXsjXUpFInnI1mX(FAnJMsiQdGCZHuRdzn6WGyPtNytLy)pTMrtje1bqU5qQ1HSNbXAMytLynAKcsaWfBpt3dpK8OlAqILoDI1OrkibaxS9mQJjrDaKFHZdILoDI1OrkibaxS9machwUq6lk4hej20i20uGWDqbkdVbGbxL4EvOsKIOsrbIN)f4sLUce2vGD5kW)tRz0ucrDaKBoKADiRrhgelD6eBQe7)P1mAkHOoaYnhsToK9miwZeBQeRrJuqcaUy7z6E4HKhDrdsS0PtSgnsbja4ITNrDmjQdG8lCEqS0PtSgnsbja4ITNbq4WYfsFrb)GiXMgXMMc0HrnNcC(IkW2dufQeZ9QuuG45FbUuPRaHDfyxUc0HrrbuIhUviNyZKyZqb6WOMtbUqpOYLRhQcvIumvkkq88VaxQ0vGWUcSlxb6WOOakXd3kKtSzsSzOaDyuZPaxOhuL(TKle67uHkXKMkffiE(xGlv6kqyxb2LRatLyZJy)pTM11gYEgelD6eB)UckngtyZwOUGvqSusS7ZNyPtNy73HSO2qzmYmi2mjwaWfXMgXAMy5gOqidVbGbNbq4WYfsFrb)GiXMjqIndfOdJAofiaHdlxi9ff8dIQqL4(8vPOaXZ)cCPsxbc7kWUCf4)P1SU2q2ZGyntSCduiKH3aWGZOoMe1bq(fopi2mbsSzOaDyuZPaPoMe1bq(fopuHkX97vPOaXZ)cCPsxb6WOMtbQ7HhsE0fnOce2vGD5kWuj2f(FAnR9SNUGiJhoKgILsInhILoDIDH)NwZAp7PliYACZRJtSusS7ZNytJyntS5rS)NwZ6AdzpdILoDITFxbLgJjSzluxWkiwkj295tS0PtS97qwuBOmgzgeBMela4IyntS5rSHlWly6E4bhUlOIm88Vaxkq4oOaLH3aWGRsCVkujUpdvkkq88VaxQ0vGWUcSlxbMhX(FAnRRnK9miw60j2(DfuAmMWMTqDbRGyPKy3NpXsNoX2VdzrTHYyKzqSzsSaGlfOdJAofOUhEi5rx0GQqL4(KOsrbIN)f4sLUce2vGD5kW)tRzDTHSNHc0HrnNcK6ysuha5x48qfQe3NuQuuG45FbUuPRaDyuZPaNVOcS9avGWUcSlxbMkXUW)tRzTN90fez8WH0qSusS5qS0PtSl8)0Aw7zpDbrwJBEDCILsIDF(eBAeRzInpInCbEbt3dp4WDbvKHN)f4sbc3bfOm8gagCvI7vHkX95Osrb6WOMtboFrfy7bQaXZ)cCPsxfQqb(hUmkin1bqLIkX9QuuG45FbUuPRaHDfyxUceoJynMogUzmMWw2VdLMq3yowJBEDCfOdJAofOrjeElhTu3dpuHkXmuPOaDyuZPaXnJXe2Y(DO0e6gZPaXZ)cCPsxfQetIkffiE(xGlv6kqhg1CkW5lQaBpqfiSRa7YvGPsSl8)0Aw7zpDbrgpCinelLeBoelD6e7c)pTM1E2txqK14MxhNyPKy3NpXMgXAMy73vqPXycBILsGeBsYGyntS5rSHlWly6E4bhUlOIm88Vaxkq4oOaLH3aWGRsCVkujMuQuuG45FbUuPRaHDfyxUcSFxbLgJjSjwkbsSjjdfOdJAof48fvGThOkujMJkffiE(xGlv6kqyxb2LRadxGxWa4bvSRdGKhtVXWZ)cCPaDyuZPaBCBAokqoxAQUaBvOsKIOsrbIN)f4sLUce2vGD5kW)tRzDTHSNHc0HrnNcK6ysuha5x48qfQeZ9QuuG45FbUuPRaDyuZPaNVOcS9avGWUcSlxbMkXUW)tRzTN90fez8WH0qSusS5qS0PtSl8)0Aw7zpDbrwJBEDCILsIDF(eBAeRzITFhYIAdLXiZHyPKybaxelD6eB)UckngtytSucKytQCiwZeBEeB4c8cMUhEWH7cQidp)lWLceUdkqz4nam4Qe3RcvIumvkkq88VaxQ0vGWUcSlxb2VdzrTHYyK5qSusSaGlILoDITFxbLgJjSjwkbsSjvokqhg1CkW5lQaBpqvOsmPPsrbIN)f4sLUce2vGD5kW)tRz0ucrDaKBoKADi7zqSMjwUbkeYWBayWz6E4bhUlOIeBMaj2muGomQ5uG6E4bhUlOIQqL4(8vPOaXZ)cCPsxbc7kWUCfy)UckngtyZwOUGvqSzcKytsgeRzITFhYIAdLXitcXMjXcaUuGomQ5uGuN(KJwAQUaBvOsC)Evkkqhg1CkWg3MMJcKZLMQlWwbIN)f4sLUkujUpdvkkq88VaxQ0vGWUcSlxbYnqHqgEdadot3dp4WDbvKyZeiXMHc0HrnNcu3dp4WDbvufQe3Nevkkq88VaxQ0vGomQ5uGZxub2EGkqyxb2LRatLyx4)P1S2ZE6cImE4qAiwkj2Ciw60j2f(FAnR9SNUGiRXnVooXsjXUpFInnI1mX2VRGsJXe2SfQlyfeBMeBg5qS0PtS97qIntInjeRzInpInCbEbt3dp4WDbvKHN)f4sbc3bfOm8gagCvI7vHkX9jLkffiE(xGlv6kqyxb2LRa73vqPXycB2c1fScIntInJCiw60j2(DiXMjXMefOdJAof48fvGThOkujUphvkkq88VaxQ0vGWUcSlxb2VRGsJXe2SfQlyfeBMeBo5RaDyuZPa9g6hkJPB8cvOcfiCgXAmDCvkQe3RsrbIN)f4sLUc0HrnNc0ZMt1BNl1ZfYrlngtyRaHDfyxUcmvIfoJynMogUzmMWw2VdLMq3yowJ(AhXAMyZJyPG3L)fiBcQylNt(4OeZLxzyGlInnILoDInvIfoJynMoMrjeElhTu3dpynU51XjwkbsS7ZNyntSuW7Y)cKnbvSLZjFCuI5YRmmWfXMMc88nub6zZP6TZL65c5OLgJjSvHkXmuPOaXZ)cCPsxb6WOMtbkEnnyZL1XRvnpUeqPdfiSRa7YvGHlWly)g9GQC0sEDR2bmCNHN)f4IyntSPsSPsSWzeRX0XmkHWB5OL6E4bRXnVooXsjqIDF(eRzILcEx(xGSjOITCo5JJsmxELHbUi20iw60j2uj2)tRzgLq4TC0sDp8G9miwZeBEelf8U8VaztqfB5CYhhLyU8kddCrSPrSPrS0PtSPsS)NwZmkHWB5OL6E4b7zqSMj28i2Wf4fSFJEqvoAjVUv7agUZWZ)cCrSPPapFdvGIxtd2CzD8AvZJlbu6qfQetIkffiE(xGlv6kqhg1Ckq4oOyIEUck)cNhkqyxb2LRaZJy)pTMzucH3Yrl19Wd2ZqbE(gQaH7GIj65kO8lCEOcvIjLkffiE(xGlv6kqyxb2LRatLyHZiwJPJzucH3Yrl19WdwJ(AhXsNoXcNrSgthZOecVLJwQ7HhSg3864eBMeBg5tSPrSMj2uj28i2Wf4fSFJEqvoAjVUv7agUZWZ)cCrS0PtSWzeRX0XWnJXe2Y(DO0e6gZXACZRJtSzsSjTCi20uGomQ5uGpokRa34QqLyoQuuG45FbUuPRaDyuZPaDovk4hYLTN90s40Uqbc7kWUCf4c)pTM1E2tlHt7c5c)pTMTgtNc88nub6CQuWpKlBp7PLWPDHkujsruPOaXZ)cCPsxb6WOMtb6CQuWpKlBp7PLWPDHce2vGD5kq4mI1y6y4MXycBz)ouAcDJ5ynU51Xj2mj2Kw(eRzIDH)NwZAp7PLWPDHCH)NwZEgeRzILcEx(xGSjOITCo5JJsmxELHbUiw60j2)tRz)g9GQC0sEDR2bmCN9miwZe7c)pTM1E2tlHt7c5c)pTM9miwZeBEelf8U8VaztqfB5CYhhLyU8kddCrS0PtS)NwZWnJXe2Y(DO0e6gZXEgeRzIDH)NwZAp7PLWPDHCH)NwZEgeRzInpInCbEb73OhuLJwYRB1oGH7m88VaxelD6eBuBOmg5QqILsInJ9kWZ3qfOZPsb)qUS9SNwcN2fQqLyUxLIcep)lWLkDfOdJAofyUfYLuhtcSvGWUcSlxbMkXI5YRmmWft8AAWMlRJxRAECjGsheRzI9)0AMrjeElhTu3dpynU51Xj20iw60j2uj28iwmxELHbUyIxtd2CzD8AvZJlbu6GyntS)NwZmkHWB5OL6E4bRXnVooXsjXUpdI1mX(FAnZOecVLJwQ7HhSNbXMMc88nubMBHCj1XKaBvOsKIPsrbIN)f4sLUc0HrnNcKMBc5OL(bl8cP(17uGWUcSlxbcNrSgthd3mgtyl73HstOBmhRXnVooXMjXMu5RapFdvG0CtihT0pyHxi1VENkujM0uPOaXZ)cCPsxb6WOMtbcONdaxA01MlKTdavGWUcSlxb2VdjwkbsSjHyntS5rS)NwZmkHWB5OL6E4b7zqSMj2uj28i2)tRz)g9GQC0sEDR2bmCN9miw60j28i2Wf4fSFJEqvoAjVUv7agUZWZ)cCrSPPapFdvGa65aWLgDT5cz7aqvOsCF(QuuG45FbUuPRapFdvGTN96D0WL)cGSXL8)IyofOdJAofy7zVEhnC5VaiBCj)ViMtfQe3VxLIcep)lWLkDfOdJAof4g2inbvNl1(bqbc7kWUCfyEe7)P1SFJEqvoAjVUv7agUZEgeRzInpI9)0AMrjeElhTu3dpypdf45BOcCdBKMGQZLA)aOcvI7ZqLIcep)lWLkDfiSRa7YvG)NwZmkHWB5OL6E4b7zqSMj2)tRz4MXycBz)ouAcDJ5ypdfOdJAofOXe1CQqL4(KOsrbIN)f4sLUce2vGD5kW)tRzgLq4TC0sDp8G9miwZe7)P1mCZymHTSFhknHUXCSNHc0HrnNc8lMzj1VENkujUpPuPOaXZ)cCPsxbc7kWUCf4)P1mJsi8woAPUhEWEgkqhg1CkWp2CSPPoaQqL4(CuPOaXZ)cCPsxbc7kWUCfyQeBEe7)P1mJsi8woAPUhEWEgeRzI1HrrbuIhUviNyZeiXMbXMgXsNoXMhX(FAnZOecVLJwQ7HhSNbXAMytLy73HSfQlyfeBMaj2CiwZeB)UckngtyZwOUGvqSzcKyPi5tSPPaDyuZPa9g6hknEcoQcvI7PiQuuG45FbUuPRaHDfyxUc8)0AMrjeElhTu3dpypdfOdJAofOOaqn4YCR3cWgEHkujUp3RsrbIN)f4sLUce2vGD5kWWBayWIAdLXixfsSzsS7tkfOdJAofiNQdPrGYGkkFNPPdQ7uHkX9umvkkq88VaxQ0vGWUcSlxb6WOOakXd3kKtSzsSzqS0PtS)HZvGomQ5uG(F2QZJAoPO2(QqL4(KMkffiE(xGlv6kqyxb2LRaDyuuaL4HBfYj2mj2miw60j2)W5kqhg1CkqUjV3QdGCR4HkujMr(QuuGomQ5uGTxCuUqFPaXZ)cCPsxfQeZyVkffiE(xGlv6kqyxb2LRa)pTMzucH3Yrl19Wd2ZGyntS)NwZWnJXe2Y(DO0e6gZXEgkqhg1Ckq)GipAxiHUqOcvIzKHkffiE(xGlv6kqyxb2LRa)pTMzucH3Yrl19WdwJBEDCILsGelfJyntS)NwZWnJXe2Y(DO0e6gZXEgkqhg1CkqD14xmZsfQeZijQuuG45FbUuPRaHDfyxUc8)0AMrjeElhTu3dpypdI1mXMkX(FAnZOecVLJwQ7HhSg3864elLeBoeRzInCbEbdoILKk6DWWZ)cCrS0PtS5rSHlWlyWrSKurVdgE(xGlI1mX(FAnZOecVLJwQ7HhSg3864elLeBsi20iwZeRdJIcOepCRqoXcKy3tS0PtS)NwZ4iguRdGSDai7zqSMjwhgffqjE4wHCIfiXUxb6WOMtb(DaYrlJUG0WvHkXmskvkkq88VaxQ0vGWUcSlxbMkXcNrSgthd3mgtyl73HstOBmhRXnVooXsNoXgUaVGvqe6gm88VaxeBAeRzInpI9)0AMrjeElhTu3dpypdfOdJAofOrjeElhTu3dpuHkXmYrLIcep)lWLkDfiSRa7YvGWzeRX0XWnJXe2Y(DO0e6gZXACZRJtSMjw4mI1y6ygLq4TC0sDp8G14Mxhxb6WOMtb(B0dQYrl51TAhWWDf4JJYrRLaGlvI7vHkXmOiQuuG45FbUuPRaHDfyxUceoJynMoMrjeElhTu3dpyn6RDeRzInCbEbB(IkW2JAogE(xGlI1mX2VdzrTHYyK5qSzsSaGlI1mX2VRGsJXe2SfQlyfeBMaj295tS0PtSrTHYyKRcjwkj2mYxb6WOMtbIBgJjSL97qPj0nMtfQeZi3RsrbIN)f4sLUce2vGD5kWujw4mI1y6ygLq4TC0sDp8G1OV2rS0PtSrTHYyKRcjwkj2mYNytJyntSHlWly)g9GQC0sEDR2bmCNHN)f4IyntS97kO0ymHnXMjXsrYxb6WOMtbIBgJjSL97qPj0nMtfQeZGIPsrbIN)f4sLUce2vGD5kWWf4fScIq3GHN)f4IyntS97qILsInjkqhg1CkqCZymHTSFhknHUXCQqLygjnvkkqhg1CkqQ7mMGk2BfuA0ihpiQaXZ)cCPsxfQets(QuuG45FbUuPRaHDfyxUcmCbEbdoILKk6DWWZ)cCrSMj2uj2uj2)tRzWrSKurVdgpCineBMaj295tSMj2f(FAnR9SNUGiJhoKgIfiXMdXMgXsNoXg1gkJrUkKyPeiXcaUi20uGomQ5uGqxiKomQ5KIIhkqrXd55BOceoILKk6DOcvIjzVkffiE(xGlv6kqyxb2LRatLy)pTMzucH3Yrl19Wd2ZGyntSE2yxbYk4ojScFHcw7hnelLaj29eRzInvI9)0AMrjeElhTu3dpynU51XjwkbsSaGlILoDI9)0A27OoIDsE04biOYACZRJtSucKybaxeRzI9)0A27OoIDsE04biOYEgeBAeBAkqhg1CkqDp8W0UEJl1VENkujMKmuPOaXZ)cCPsxbc7kWUCfyQe7)P1ScUtcRWxOG9miwZeBEeB4c8cwbrOBWWZ)cCrSMj2uj2)tRzVJ6i2j5rJhGGk7zqS0PtS)NwZk4ojScFHcwJBEDCILsGela4IytJytJyPtNy)pTMvWDsyf(cfSNbXAMy)pTMvWDsyf(cfSg3864elLajwaWfXAMydxGxWkicDdgE(xGlI1mX(FAnZOecVLJwQ7HhSNHc0HrnNcu3dpmTR34s9R3PcvIjjjQuuG45FbUuPRaHDfyxUcmQnugJCviXsjXcaUiw60j2uj2O2qzmYvHelLelCgXAmDmJsi8woAPUhEWACZRJtSMj2)tRzVJ6i2j5rJhGGk7zqSPPaDyuZPa19Wdt76nUu)6DQqfkW)WLgZiQdGkfvI7vPOaXZ)cCPsxbc7kWUCf4)P1SU2q2Zqb6WOMtbsDmjQdG8lCEOcvIzOsrbIN)f4sLUc0HrnNcC(IkW2dubc7kWUCfyQe7c)pTM1E2txqKXdhsdXsjXMdXsNoXUW)tRzTN90feznU51Xjwkj295tSPrSMj2(DfuAmMWMTqDbRGyZeiXMroeRzInpInCbEbt3dp4WDbvKHN)f4sbc3bfOm8gagCvI7vHkXKOsrbIN)f4sLUce2vGD5kW(DfuAmMWMTqDbRGyZeiXMrokqhg1CkW5lQaBpqvOsmPuPOaXZ)cCPsxbc7kWUCfy)UckngtyZwOUGvqSusSzKpXAMy5gOqidVbGbNbq4WYfsFrb)GiXMjqIndI1mXcNrSgthZOecVLJwQ7HhSg3864eBMeBokqhg1CkqachwUq6lk4hevHkXCuPOaXZ)cCPsxb6WOMtbQ7HhsE0fnOce2vGD5kWuj2f(FAnR9SNUGiJhoKgILsInhILoDIDH)NwZAp7PliYACZRJtSusS7ZNytJyntS97kO0ymHnBH6cwbXsjXMr(eRzInpInCbEbt3dp4WDbvKHN)f4IyntSWzeRX0XmkHWB5OL6E4bRXnVooXMjXMJceUdkqz4nam4Qe3RcvIuevkkq88VaxQ0vGWUcSlxb2VRGsJXe2SfQlyfelLeBg5tSMjw4mI1y6ygLq4TC0sDp8G14MxhNyZKyZrb6WOMtbQ7HhsE0fnOkujM7vPOaXZ)cCPsxbc7kWUCf4)P1mAkHOoaYnhsToK9miwZeB)UckngtyZwOUGvqSzsSPsS7ZHytGydxGxW63vqPhbEppQ5y45FbUi2CLytcXMgXAMy5gOqidVbGbNP7HhC4UGksSzcKyZqb6WOMtbQ7HhC4UGkQcvIumvkkq88VaxQ0vGWUcSlxb2VRGsJXe2SfQlyfeBMaj2uj2KKdXMaXgUaVG1VRGspc8EEuZXWZ)cCrS5kXMeInnI1mXYnqHqgEdadot3dp4WDbvKyZeiXMHc0HrnNcu3dp4WDbvufQetAQuuG45FbUuPRaDyuZPaNVOcS9avGWUcSlxbMkXUW)tRzTN90fez8WH0qSusS5qS0PtSl8)0Aw7zpDbrwJBEDCILsIDF(eBAeRzITFxbLgJjSzluxWki2mbsSPsSjjhInbInCbEbRFxbLEe498OMJHN)f4IyZvInjeBAeRzInpInCbEbt3dp4WDbvKHN)f4sbc3bfOm8gagCvI7vHkX95RsrbIN)f4sLUce2vGD5kW(DfuAmMWMTqDbRGyZeiXMkXMKCi2ei2Wf4fS(Dfu6rG3ZJAogE(xGlInxj2KqSPPaDyuZPaNVOcS9avHkX97vPOaXZ)cCPsxbc7kWUCfiCgXAmDmJsi8woAPUhEWACZRJtSzsS97qwuBOmgzsrSMj2(DfuAmMWMTqDbRGyPKytQ8jwZel3afcz4nam4machwUq6lk4hej2mbsSzOaDyuZPabiCy5cPVOGFqufQe3NHkffiE(xGlv6kqhg1CkqDp8qYJUObvGWUcSlxbMkXUW)tRzTN90fez8WH0qSusS5qS0PtSl8)0Aw7zpDbrwJBEDCILsIDF(eBAeRzIfoJynMoMrjeElhTu3dpynU51Xj2mj2(DilQnugJmPiwZeB)UckngtyZwOUGvqSusSjv(eRzInpInCbEbt3dp4WDbvKHN)f4sbc3bfOm8gagCvI7vHkX9jrLIcep)lWLkDfiSRa7YvGWzeRX0XmkHWB5OL6E4bRXnVooXMjX2VdzrTHYyKjfXAMy73vqPXycB2c1fScILsInPYxb6WOMtbQ7HhsE0fnOkuHc0Or4S99qLIkX9QuuGomQ5uGgtuZPaXZ)cCPsxfQeZqLIcep)lWLkDf45BOc0ZMt1BNl1ZfYrlngtyRaDyuZPa9S5u925s9CHC0sJXe2QqLysuPOaXZ)cCPsxbogkqogkqhg1Ckqk4D5FbQaPGlEOcmvIfZLxzyGl2nX0184sacFvEmnx(9faKyPtNyXC5vgg4IbNUFgbUKae(Q8yAU87laiXsNoXI5YRmmWfdoD)mcCjbi8v5X0C5gUCHOMJyPtNyXC5vgg4IrHYfYrl9R28axYVyMfXsNoXI5YRmmWftxnpKBEGCj3yhaHZ5elD6elMlVYWaxSClKlPoMeytS0PtSyU8kddCXUjMUMhxcq4RYJP5YnC5crnhXsNoXI5YRmmWfZ5uPGFix2E2tlHt7cInnfif8wE(gQaNGk2Y5KpokXC5vgg4sfQqb6dQsrL4Evkkq88VaxQ0vGWUcSlxbgUaVGbWdQyxhajpMEJHN)f4IyPtNytLy9SXUcKP7jB8KbUzG8G1(rdXAMy5gOqidVbGbN1420CuGCU0uDb2eBMaj2KqSMj28i2)tRzDTHSNbXMMc0HrnNcSXTP5Oa5CPP6cSvHkXmuPOaXZ)cCPsxbc7kWUCfy4c8cMUhEWH7cQidp)lWLc0HrnNceGWHLlK(Ic(brvOsmjQuuG45FbUuPRaDyuZPa19Wdjp6Igubc7kWUCfyQe7c)pTM1E2txqKXdhsdXsjXMdXsNoXUW)tRzTN90feznU51Xjwkj295tSPrSMjw4mI1y6ynUnnhfiNlnvxGnRXnVooXsjqIndInxjwaWfXAMydxGxWa4bvSRdGKhtVXWZ)cCrSMj28i2Wf4fmDp8Gd3furgE(xGlfiChuGYWBayWvjUxfQetkvkkq88VaxQ0vGWUcSlxbcNrSgthRXTP5Oa5CPP6cSznU51XjwkbsSzqS5kXcaUiwZeB4c8cgapOIDDaK8y6ngE(xGlfOdJAofOUhEi5rx0GQqLyoQuuG45FbUuPRaHDfyxUc8)0AwxBi7zOaDyuZPaPoMe1bq(fopuHkrkIkffiE(xGlv6kqyxb2LRa)pTMrtje1bqU5qQ1HSNHc0HrnNcu3dp4WDbvufQeZ9QuuG45FbUuPRaHDfyxUcSFxbLgJjSzluxWkiwkj2uj295qSjqSHlWly97kO0JaVNh1Cm88VaxeBUsSjHyttb6WOMtbcq4WYfsFrb)GOkujsXuPOaXZ)cCPsxb6WOMtbQ7HhsE0fnOce2vGD5kWuj2f(FAnR9SNUGiJhoKgILsInhILoDIDH)NwZAp7PliYACZRJtSusS7ZNytJyntS97kO0ymHnBH6cwbXsjXMkXUphInbInCbEbRFxbLEe498OMJHN)f4IyZvInjeBAeRzInpInCbEbt3dp4WDbvKHN)f4sbc3bfOm8gagCvI7vHkXKMkffiE(xGlv6kqyxb2LRa73vqPXycB2c1fScILsInvIDFoeBceB4c8cw)Uck9iW75rnhdp)lWfXMReBsi20iwZeBEeB4c8cMUhEWH7cQidp)lWLc0HrnNcu3dpK8OlAqvOsCF(QuuG45FbUuPRaHDfyxUc0HrrbuIhUviNyZKyZqb6WOMtbUqpOYLRhQcvI73RsrbIN)f4sLUce2vGD5kqhgffqjE4wHCIntIndfOdJAof4c9GQ0VLCHqFNkujUpdvkkqhg1CkWg3MMJcKZLMQlWwbIN)f4sLUkujUpjQuuGomQ5uG6E4bhUlOIkq88VaxQ0vHkX9jLkffiE(xGlv6kqhg1CkW5lQaBpqfiSRa7YvGPsSl8)0Aw7zpDbrgpCinelLeBoelD6e7c)pTM1E2txqK14MxhNyPKy3NpXMgXAMy73vqPXycB2c1fScIntInvInJCi2ei2Wf4fS(Dfu6rG3ZJAogE(xGlInxj2KqSPrSMj28i2Wf4fmDp8Gd3furgE(xGlfiChuGYWBayWvjUxfQe3NJkffiE(xGlv6kqyxb2LRa73vqPXycB2c1fScIntInvInJCi2ei2Wf4fS(Dfu6rG3ZJAogE(xGlInxj2KqSPPaDyuZPaNVOcS9avHkX9uevkkqhg1CkqachwUq6lk4hevG45FbUuPRcvI7Z9QuuG45FbUuPRaDyuZPa19Wdjp6Igubc7kWUCfyQe7c)pTM1E2txqKXdhsdXsjXMdXsNoXUW)tRzTN90feznU51Xjwkj295tSPrSMj28i2Wf4fmDp8Gd3furgE(xGlfiChuGYWBayWvjUxfQe3tXuPOaDyuZPa19Wdjp6IgubIN)f4sLUkujUpPPsrb6WOMtbsD6toAPP6cSvG45FbUuPRcvIzKVkffOdJAofO3q)qzmDJxOaXZ)cCPsxfQqbUqT)eHkfvI7vPOaDyuZPa3QBj1nIzJkq88VaxQ0vHkXmuPOaXZ)cCPsxbc7kWUCfyEe7AcMUhEi1ifWMffKM6aqSMj2uj28i2Wf4fSFJEqvoAjVUv7agUZWZ)cCrS0PtSWzeRX0X(n6bv5OL86wTdy4oRXnVooXMjXUphInnfOdJAofi1XKOoaYVW5HkujMevkkq88VaxQ0vGWUcSlxb(FAnRG7KHlMJZACZRJtSucKybaxeRzI9)0Awb3jdxmhN9miwZel3afcz4nam4machwUq6lk4hej2mbsSzqSMj2uj28i2Wf4fSFJEqvoAjVUv7agUZWZ)cCrS0PtSWzeRX0X(n6bv5OL86wTdy4oRXnVooXMjXUphInnfOdJAofiaHdlxi9ff8dIQqLysPsrbIN)f4sLUce2vGD5kW)tRzfCNmCXCCwJBEDCILsGela4IyntS)NwZk4oz4I54SNbXAMytLyZJydxGxW(n6bv5OL86wTdy4odp)lWfXsNoXcNrSgth73OhuLJwYRB1oGH7Sg3864eBMe7(Ci20uGomQ5uG6E4HKhDrdQcvI5OsrbIN)f4sLUc0HrnNce6cH0HrnNuu8qbkkEipFdvGiNJhe5QqLifrLIcep)lWLkDfOdJAofi0fcPdJAoPO4Hcuu8qE(gQaHZiwJPJRcvI5Evkkq88VaxQ0vGWUcSlxb(FAn73OhuLJwYRB1oGH7SNHc0HrnNcSFN0HrnNuu8qbkkEipFdvG)HlJcstDauHkrkMkffiE(xGlv6kqyxb2LRadxGxW(n6bv5OL86wTdy4odp)lWfXAMytLytLyHZiwJPJ9B0dQYrl51TAhWWDwJBEDCIfiXMpXAMyHZiwJPJzucH3Yrl19WdwJBEDCILsIDF(eBAelD6eBQelCgXAmDSFJEqvoAjVUv7agUZACZRJtSusSzKpXAMyJAdLXixfsSusSjjhInnInnfOdJAofy)oPdJAoPO4Hcuu8qE(gQa)dxAmJOoaQqLystLIcep)lWLkDfiSRa7YvG)NwZmkHWB5OL6E4b7zqSMj2Wf4fS5lQaBpQ5y45FbUuGomQ5uG97KomQ5KIIhkqrXd55BOcC(IkW2JAovOsCF(QuuG45FbUuPRaHDfyxUc0HrrbuIhUviNyZeiXMHc0HrnNcSFN0HrnNuu8qbkkEipFdvG(GQqL4(9QuuG45FbUuPRaDyuZPaHUqiDyuZjffpuGIIhYZ3qfip8B59sfQqbYd)wEVuPOsCVkffOdJAofyJBtZrbY5st1fyRaXZ)cCPsxfQeZqLIcep)lWLkDfiSRa7YvGWzeRX0XACBAokqoxAQUaBwJBEDCILsGeBgeBUsSaGlI1mXgUaVGbWdQyxhajpMEJHN)f4sb6WOMtbQ7HhsE0fnOkujMevkkq88VaxQ0vGWUcSlxb(FAnRRnK9muGomQ5uGuhtI6ai)cNhQqLysPsrbIN)f4sLUce2vGD5kWWf4fScIq3GHN)f4IyntS)NwZmkHWB5OL6E4b7zqSMjwpBSRazfCNewHVqbR9JgIntGeBgkqhg1CkW5lQaBpqvOsmhvkkq88VaxQ0vGWUcSlxbMhX(FAnt3t24jnEcoYEgeRzInCbEbt3t24jnEcoYWZ)cCPaDyuZPaNVOcS9avHkrkIkffiE(xGlv6kqyxb2LRa73vqPXycB2c1fScILsInvIDFoeBceB4c8cw)Uck9iW75rnhdp)lWfXMReBsi20uGomQ5uG6E4HKhDrdQcvI5Evkkq88VaxQ0vGWUcSlxb(FAnJMsiQdGCZHuRdzpdI1mX2VdzrTHYyKjfXMjqIfaCPaDyuZPa19WdoCxqfvHkrkMkffiE(xGlv6kqyxb2LRa73vqPXycB2c1fScIntInvInJCi2ei2Wf4fS(Dfu6rG3ZJAogE(xGlInxj2KqSPPaDyuZPaNVOcS9avHkXKMkffOdJAofOUhEi5rx0Gkq88VaxQ0vHkX95Rsrb6WOMtbsD6toAPP6cSvG45FbUuPRcvI73Rsrb6WOMtb6n0pugt34fkq88VaxQ0vHkuGiNJhe5QuujUxLIcep)lWLkDfiSRa7YvG)NwZmkHWB5OL6E4b7zqSMj2uj2)tRzgLq4TC0sDp8G14MxhNyPKy3NpXAMytLy)pTM9B0dQYrl51TAhWWD2ZGyPtNydxGxWMVOcS9OMJHN)f4IyPtNydxGxWkicDdgE(xGlI1mXMhX6zJDfiRG7KWk8fky45FbUi20iw60j2)tRzfCNewHVqb7zqSMj2Wf4fScIq3GHN)f4Iyttb6WOMtb(fZSKJwgurjE42ovOsmdvkkq88VaxQ0vGWUcSlxbMhXgUaVGvqe6gm88VaxelD6eB4c8cwbrOBWWZ)cCrSMjwpBSRazfCNewHVqbdp)lWfXAMy)pTMzucH3Yrl19WdwJBEDCILsILIqSMj2)tRzgLq4TC0sDp8G9miw60j2Wf4fScIq3GHN)f4IyntS5rSE2yxbYk4ojScFHcgE(xGlfOdJAofiGN3RYp5OLE2ypbvvOsmjQuuG45FbUuPRaHDfyxUc8)0AMrjeElhTu3dpynU51Xjwkj2CiwZe7)P1mJsi8woAPUhEWEgelD6eBuBOmg5QqILsInhfOdJAofiKAjesE0OtJkujMuQuuG45FbUuPRaHDfyxUc8)0AwJqAeiNl1tdr2ZGyPtNy)pTM1iKgbY5s90qucN3fyZ4HdPHyPKy3Vxb6WOMtbgur57(Z7ws90qufQeZrLIcep)lWLkDfiSRa7YvG5rS)NwZmkHWB5OL6E4b7zqSMj28i2)tRz)g9GQC0sEDR2bmCN9muGomQ5uG6b(44s6zJDfO8J(MkujsruPOaXZ)cCPsxbc7kWUCfyEe7)P1mJsi8woAPUhEWEgeRzInpI9)0A2VrpOkhTKx3QDad3zpdI1mXUMGbNdIx0EGlPw4BO8)6J14MxhNybsS5RaDyuZPaHZbXlApWLul8nufQeZ9QuuG45FbUuPRaHDfyxUc8)0AMrjeElhTu3dpypdILoDI9)0AgUzmMWw2VdLMq3yo2ZGyPtNyHZiwJPJ9B0dQYrl51TAhWWDwJBEDCIntILIKpXMaXUphILoDIfoD)mIAooRouR9VaLr)cQm88Vaxkqhg1CkqttlwuaRt2iFo)GOkujsXuPOaXZ)cCPsxbc7kWUCfyEe7)P1mJsi8woAPUhEWEgeRzInpI9)0A2VrpOkhTKx3QDad3zpdfOdJAofyxggcuwNKB4qufQetAQuuG45FbUuPRaHDfyxUc8)0AgUzmMWw2VdLMq3yowJBEDCILsInhI1mX(FAn73OhuLJwYRB1oGH7SNbXsNoXMkX2VdzrTHYyKzqSzsSaGlI1mX2VRGsJXe2elLeBo5tSPPaDyuZPa3WTP3jhTu8G1sUA034QqL4(8vPOaDyuZPaB0nQdGul8nKRaXZ)cCPsxfQqfkqkGnVMtLyg5Nr(5tXYGIXsIc0K3xDa4kqkUBgth4Iy3NpX6WOMJyffp4mcTkqJE0LavGuuIn31dpiwkoqpOsS52Vca1GqlfLybrJa3(ytSzqrsMyZi)mYNqlHwkkXMBq1paip3eHwkkXsXtSuCpO4TqInP76weBURrmBKrOLIsSu8eBs)1Iy1Uq8DineREAI9XRdaXM0j3gfNjtSj9MChXwAI1q47WMyRRIYdKtSPpGe7h1tJeRXmI6aqSIbqbj2ItSWzZqGbUyeAPOelfpXMBq1paiXgEdadwuBOmg5QqIngInQnugJCviXgdX(4iXIhCExGnXkWdqqLyBpOInXgu9JynMaVOCbXgTZPsSl0dQCgHwkkXsXtS5gJyrSjDHEheRFlITDy5cInmHonCgHwcTuuInPtUzi8f4Iy)OEAKyHZ23dI9JaQJZi2K(qiAeCI9MJINQ3B6NGyDyuZXj25e7yeADyuZXzgncNTVhjamlJjQ5i06WOMJZmAeoBFpsaywpokRa3s(8neONnNQ3oxQNlKJwAmMWMqRdJAooZOr4S99ibGzrbVl)lWKpFdbobvSLZjFCuI5YRmmWvYuWfpeyQyU8kddCXUjMUMhxcq4RYJP5YVVaG0PJ5YRmmWfdoD)mcCjbi8v5X0C53xaq60XC5vgg4IbNUFgbUKae(Q8yAUCdxUquZrNoMlVYWaxmkuUqoAPF1Mh4s(fZSOthZLxzyGlMUAEi38a5sUXoacNZPthZLxzyGlwUfYLuhtcSPthZLxzyGl2nX0184sacFvEmnxUHlxiQ5OthZLxzyGlMZPsb)qUS9SNwcN2fPrOLqlfLyt6KBgcFbUiwKcyVJyJAdj2GksSomMMyloX6uWlH)fiJqRdJAooWT6wsDJy2iHwkkXM03WqSJyZD9WdIn3HuaBI1VfXU51fEDelfx4oInfxmhNqRdJAoEcaZI6ysuha5x48i5sdmV1emDp8qQrkGnlkin1bWCQ5fUaVG9B0dQYrl51TAhWWDgE(xGl60HZiwJPJ9B0dQYrl51TAhWWDwJBED8m3NtAeADyuZXtaywaeoSCH0xuWpiMCPb(FAnRG7KHlMJZACZRJtjqaWL5)tRzfCNmCXCC2ZWm3afcz4nam4machwUq6lk4heZeygMtnVWf4fSFJEqvoAjVUv7agUZWZ)cCrNoCgXAmDSFJEqvoAjVUv7agUZACZRJN5(CsJqRdJAoEcaZs3dpK8OlAWKlnW)tRzfCNmCXCCwJBEDCkbcaUm)FAnRG7KHlMJZEgMtnVWf4fSFJEqvoAjVUv7agUZWZ)cCrNoCgXAmDSFJEqvoAjVUv7agUZACZRJN5(CsJqRdJAoEcaZc6cH0HrnNuu8i5Z3qGiNJhe5eADyuZXtaywqxiKomQ5KIIhjF(gceoJynMooHwhg1C8eaMv)oPdJAoPO4rYNVHa)dxgfKM6aKCPb(FAn73OhuLJwYRB1oGH7SNbHwhg1C8eaMv)oPdJAoPO4rYNVHa)dxAmJOoajxAGHlWly)g9GQC0sEDR2bmCNHN)f4YCQPcNrSgth73OhuLJwYRB1oGH7Sg3864aZ3mCgXAmDmJsi8woAPUhEWACZRJt5(8tJo9uHZiwJPJ9B0dQYrl51TAhWWDwJBEDCkZiFZrTHYyKRcPmj5KwAeADyuZXtayw97KomQ5KIIhjF(gcC(IkW2JAUKlnW)tRzgLq4TC0sDp8G9mmhUaVGnFrfy7rnhdp)lWfHwhg1C8eaMv)oPdJAoPO4rYNVHa9btU0aDyuuaL4HBfYZeygeADyuZXtaywqxiKomQ5KIIhjF(gcKh(T8ErOLqRdJAooZheyJBtZrbY5st1fyNCPbgUaVGbWdQyxhajpMEJHN)f4Io9u9SXUcKP7jB8KbUzG8G1(rJzUbkeYWBayWznUnnhfiNlnvxGDMatI58(pTM11gYEgPrO1HrnhN5dMaWSaiCy5cPVOGFqm5sdmCbEbt3dp4WDbvKHN)f4IqRdJAooZhmbGzP7HhsE0fnyYWDqbkdVbGbh4(KlnWux4)P1S2ZE6cImE4qAOmh60x4)P1S2ZE6cISg3864uUp)0mdNrSgthRXTP5Oa5CPP6cSznU51XPeyg5ka4YC4c8cgapOIDDaK8y6ngE(xGlZ5fUaVGP7HhC4UGkYWZ)cCrO1HrnhN5dMaWS09Wdjp6Igm5sdeoJynMowJBtZrbY5st1fyZACZRJtjWmYvaWL5Wf4fmaEqf76ai5X0Bm88VaxeADyuZXz(GjamlQJjrDaKFHZJKlnW)tRzDTHSNbHwhg1CCMpycaZs3dp4WDbvm5sd8)0AgnLquha5MdPwhYEgeADyuZXz(GjamlachwUq6lk4hetU0a73vqPXycB2c1fScktDFojeUaVG1VRGspc8EEuZXWZ)cCLRjjncTomQ54mFWeaMLUhEi5rx0Gjd3bfOm8gagCG7tU0atDH)NwZAp7PliY4HdPHYCOtFH)NwZAp7PliYACZRJt5(8tZC)UckngtyZwOUGvqzQ7ZjHWf4fS(Dfu6rG3ZJAogE(xGRCnjPzoVWf4fmDp8Gd3furgE(xGlcTomQ54mFWeaMLUhEi5rx0GjxAG97kO0ymHnBH6cwbLPUpNecxGxW63vqPhbEppQ5y45FbUY1KKM58cxGxW09WdoCxqfz45FbUi06WOMJZ8btaywl0dQC56HjxAGomkkGs8WTc5zMbHwhg1CCMpycaZAHEqv63sUqOVl5sd0HrrbuIhUvipZmi06WOMJZ8btaywnUnnhfiNlnvxGnHwhg1CCMpycaZs3dp4WDbvKqRdJAooZhmbGznFrfy7bMmChuGYWBayWbUp5sdm1f(FAnR9SNUGiJhoKgkZHo9f(FAnR9SNUGiRXnVooL7ZpnZ97kO0ymHnBH6cwrMPMrojeUaVG1VRGspc8EEuZXWZ)cCLRjjnZ5fUaVGP7HhC4UGkYWZ)cCrO1HrnhN5dMaWSMVOcS9atU0a73vqPXycB2c1fSImtnJCsiCbEbRFxbLEe498OMJHN)f4kxtsAeADyuZXz(GjamlachwUq6lk4hej06WOMJZ8btayw6E4HKhDrdMmChuGYWBayWbUp5sdm1f(FAnR9SNUGiJhoKgkZHo9f(FAnR9SNUGiRXnVooL7ZpnZ5fUaVGP7HhC4UGkYWZ)cCrO1HrnhN5dMaWS09Wdjp6IgKqRdJAooZhmbGzrD6toAPP6cSj06WOMJZ8btaywEd9dLX0nEbHwcTuuIn9g9GkXoAIfSUv7agUtSgZiQdaX2t4rnhXMBIy5H3bNyZiFoX(r90iXM0RecVj2rtS5UE4bXMaXM(asSEJeRtbVe(xGeADyuZXz)HlnMruhaGuhtI6ai)cNhjxAG)NwZ6AdzpdcTomQ54S)WLgZiQdqcaZA(IkW2dmz4oOaLH3aWGdCFYLgyQl8)0Aw7zpDbrgpCinuMdD6l8)0Aw7zpDbrwJBEDCk3NFAM73vqPXycB2c1fSImbMroMZlCbEbt3dp4WDbvKHN)f4IqRdJAoo7pCPXmI6aKaWSMVOcS9atU0a73vqPXycB2c1fSImbMroeADyuZXz)HlnMruhGeaMfaHdlxi9ff8dIjxAG97kO0ymHnBH6cwbLzKVzUbkeYWBayWzaeoSCH0xuWpiMjWmmdNrSgthZOecVLJwQ7HhSg3864zMdHwhg1CC2F4sJze1bibGzP7HhsE0fnyYWDqbkdVbGbh4(KlnWux4)P1S2ZE6cImE4qAOmh60x4)P1S2ZE6cISg3864uUp)0m3VRGsJXe2SfQlyfuMr(MZlCbEbt3dp4WDbvKHN)f4YmCgXAmDmJsi8woAPUhEWACZRJNzoeADyuZXz)HlnMruhGeaMLUhEi5rx0GjxAG97kO0ymHnBH6cwbLzKVz4mI1y6ygLq4TC0sDp8G14MxhpZCi06WOMJZ(dxAmJOoajamlDp8Gd3fuXKlnW)tRz0ucrDaKBoKADi7zyUFxbLgJjSzluxWkYm195Kq4c8cw)Uck9iW75rnhdp)lWvUMK0mZnqHqgEdadot3dp4WDbvmtGzqO1HrnhN9hU0ygrDasayw6E4bhUlOIjxAG97kO0ymHnBH6cwrMatnj5Kq4c8cw)Uck9iW75rnhdp)lWvUMK0mZnqHqgEdadot3dp4WDbvmtGzqO1HrnhN9hU0ygrDasaywZxub2EGjd3bfOm8gagCG7tU0atDH)NwZAp7PliY4HdPHYCOtFH)NwZAp7PliYACZRJt5(8tZC)UckngtyZwOUGvKjWutsojeUaVG1VRGspc8EEuZXWZ)cCLRjjnZ5fUaVGP7HhC4UGkYWZ)cCrO1HrnhN9hU0ygrDasaywZxub2EGjxAG97kO0ymHnBH6cwrMatnj5Kq4c8cw)Uck9iW75rnhdp)lWvUMK0i06WOMJZ(dxAmJOoajamlachwUq6lk4hetU0aHZiwJPJzucH3Yrl19WdwJBED8m73HSO2qzmYKYC)UckngtyZwOUGvqzsLVzUbkeYWBayWzaeoSCH0xuWpiMjWmi06WOMJZ(dxAmJOoajamlDp8qYJUObtgUdkqz4nam4a3NCPbM6c)pTM1E2txqKXdhsdL5qN(c)pTM1E2txqK14MxhNY95NMz4mI1y6ygLq4TC0sDp8G14MxhpZ(DilQnugJmPm3VRGsJXe2SfQlyfuMu5BoVWf4fmDp8Gd3furgE(xGlcTomQ54S)WLgZiQdqcaZs3dpK8OlAWKlnq4mI1y6ygLq4TC0sDp8G14MxhpZ(DilQnugJmPm3VRGsJXe2SfQlyfuMu5tOLqlfLyZDUq8DineBme7JJeBsVj3LmXM0j3gfNeRjQ4rSpo2u81vr5bYj20hqI1OXnpEnk2Xi06WOMJZ(dxgfKM6aa0OecVLJwQ7HhjxAGWzeRX0XWnJXe2Y(DO0e6gZXACZRJtO1HrnhN9hUmkin1bibGzHBgJjSL97qPj0nMJqRdJAoo7pCzuqAQdqcaZA(IkW2dmz4oOaLH3aWGdCFYLgyQl8)0Aw7zpDbrgpCinuMdD6l8)0Aw7zpDbrwJBEDCk3NFAM73vqPXycBkbMKmmNx4c8cMUhEWH7cQidp)lWfHwhg1CC2F4YOG0uhGeaM18fvGThyYLgy)UckngtytjWKKbHwhg1CC2F4YOG0uhGeaMvJBtZrbY5st1fyNCPbgUaVGbWdQyxhajpMEJHN)f4IqRdJAoo7pCzuqAQdqcaZI6ysuha5x48i5sd8)0AwxBi7zqO1HrnhN9hUmkin1bibGznFrfy7bMmChuGYWBayWbUp5sdm1f(FAnR9SNUGiJhoKgkZHo9f(FAnR9SNUGiRXnVooL7ZpnZ97qwuBOmgzoucaUOtVFxbLgJjSPeysLJ58cxGxW09WdoCxqfz45FbUi06WOMJZ(dxgfKM6aKaWSMVOcS9atU0a73HSO2qzmYCOeaCrNE)UckngtytjWKkhcTomQ54S)WLrbPPoajamlDp8Gd3fuXKlnW)tRz0ucrDaKBoKADi7zyMBGcHm8gagCMUhEWH7cQyMaZGqRdJAoo7pCzuqAQdqcaZI60NC0st1fyNCPb2VRGsJXe2SfQlyfzcmjzyUFhYIAdLXitsMaGlcTomQ54S)WLrbPPoajamRg3MMJcKZLMQlWMqRdJAoo7pCzuqAQdqcaZs3dp4WDbvm5sdKBGcHm8gagCMUhEWH7cQyMaZGqRdJAoo7pCzuqAQdqcaZA(IkW2dmz4oOaLH3aWGdCFYLgyQl8)0Aw7zpDbrgpCinuMdD6l8)0Aw7zpDbrwJBEDCk3NFAM73vqPXycB2c1fSImZih6073HzMeZ5fUaVGP7HhC4UGkYWZ)cCrO1HrnhN9hUmkin1bibGznFrfy7bMCPb2VRGsJXe2SfQlyfzMro0P3VdZmjeADyuZXz)HlJcstDasaywEd9dLX0nErYLgy)UckngtyZwOUGvKzo5tOLqlfLyZngXIyPIEhelCUvf1CCcTomQ54m4iwsQO3bqivVoUC0YcIjxAG)NwZGJyjPIEhmE4qAYmhZrTHYyKRcPeaCrO1HrnhNbhXssf9osaywqQEDC5OLfetU0at9)0AghXGADaKTdaznU51XPeaCLM5)tRzCedQ1bq2oaK9mi06WOMJZGJyjPIEhjamlivVoUC0YcIjxAGP(FAnZOecVLJwQ7HhSg3864uceaCLRPUpb4mI1y6y6E4HPD9gxQF9owJ(AxA0P)FAnZOecVLJwQ7HhSg3864u2VdzrTHYyKjjnZ)NwZmkHWB5OL6E4b7zyovpBSRazfCNewHVqbR9JgkbUNo9)tRz)g9GQC0sEDR2bmCN9msZCEHlWlyfeHUbdp)lWfHwhg1CCgCeljv07ibGzbP61XLJwwqm5sd8)0AMrjeElhTu3dpynU51XPKIz()0A27OoIDsE04biOYACZRJtja4kxtDFcWzeRX0X09Wdt76nUu)6DSg91U0m)FAn7DuhXojpA8aeuznU51Xn)FAnZOecVLJwQ7HhSNH5u9SXUcKvWDsyf(cfS2pAOe4E60)pTM9B0dQYrl51TAhWWD2ZinZ5fUaVGvqe6gm88VaxeADyuZXzWrSKurVJeaMfKQxhxoAzbXKlnWu)pTMvWDsyf(cfSg3864uMu0P)FAnRG7KWk8fkynU51XPSFhYIAdLXitsAM)pTMvWDsyf(cfSNHzpBSRazfCNewHVqbR9JMmbMH58(pTM9B0dQYrl51TAhWWD2ZWCEHlWlyfeHUbdp)lWfHwhg1CCgCeljv07ibGzbP61XLJwwqm5sd8)0Awb3jHv4luWEgM)pTM9oQJyNKhnEacQSNHzpBSRazfCNewHVqbR9JMmbMH58(pTM9B0dQYrl51TAhWWD2ZWCEHlWlyfeHUbdp)lWfHwhg1CCgCeljv07ibGzbP61XLJwwqm5sd8)0AMrjeElhTu3dpynU51XPmPm)FAnZOecVLJwQ7HhSNH5Wf4fScIq3GHN)f4Y8)P1m4iwsQO3bJhoKMmbUNIz2Zg7kqwb3jHv4luWA)OHsG7j06WOMJZGJyjPIEhjamlivVoUC0YcIjxAG)NwZmkHWB5OL6E4b7zyoCbEbRGi0ny45FbUm7zJDfiRG7KWk8fkyTF0KjWmmN6)P1m4iwsQO3bJhoKMmbUpPz()0Awb3jHv4luWACZRJtja4Y8)P1ScUtcRWxOG9mOt))0A27OoIDsE04biOYEgM)pTMbhXssf9oy8WH0KjW9uS0i0sO1HrnhNbNrSgthh4JJYkWTKpFdb6zZP6TZL65c5OLgJjStU0atfoJynMogUzmMWw2VdLMq3yowJ(AN58OG3L)fiBcQylNt(4OeZLxzyGR0Otpv4mI1y6ygLq4TC0sDp8G14MxhNsG7Z3mf8U8VaztqfB5CYhhLyU8kddCLgHwhg1CCgCgXAmD8eaM1JJYkWTKpFdbkEnnyZL1XRvnpUeqPJKlnWWf4fSFJEqvoAjVUv7agUZWZ)cCzo1uHZiwJPJzucH3Yrl19WdwJBEDCkbUpFZuW7Y)cKnbvSLZjFCuI5YRmmWvA0PN6)P1mJsi8woAPUhEWEgMZJcEx(xGSjOITCo5JJsmxELHbUsln60t9)0AMrjeElhTu3dpypdZ5fUaVG9B0dQYrl51TAhWWDgE(xGR0i06WOMJZGZiwJPJNaWSECuwbUL85Biq4oOyIEUck)cNhjxAG59FAnZOecVLJwQ7HhSNbHwhg1CCgCgXAmD8eaM1JJYkWnEYLgyQWzeRX0XmkHWB5OL6E4bRrFTJoD4mI1y6ygLq4TC0sDp8G14MxhpZmYpnZPMx4c8c2VrpOkhTKx3QDad3z45FbUOthoJynMogUzmMWw2VdLMq3yowJBED8mtA5KgHwhg1CCgCgXAmD8eaM1JJYkWTKpFdb6CQuWpKlBp7PLWPDrYLg4c)pTM1E2tlHt7c5c)pTMTgthHwhg1CCgCgXAmD8eaM1JJYkWTKpFdb6CQuWpKlBp7PLWPDrYLgiCgXAmDmCZymHTSFhknHUXCSg3864zM0Y38c)pTM1E2tlHt7c5c)pTM9mmtbVl)lq2euXwoN8XrjMlVYWax0P)FAn73OhuLJwYRB1oGH7SNH5f(FAnR9SNwcN2fYf(FAn7zyopk4D5FbYMGk2Y5KpokXC5vgg4Io9)tRz4MXycBz)ouAcDJ5ypdZl8)0Aw7zpTeoTlKl8)0A2ZWCEHlWly)g9GQC0sEDR2bmCNHN)f4Io9O2qzmYvHuMXEcTomQ54m4mI1y64jamRhhLvGBjF(gcm3c5sQJjb2jxAGPI5YRmmWft8AAWMlRJxRAECjGshM)pTMzucH3Yrl19WdwJBED80Otp18WC5vgg4IjEnnyZL1XRvnpUeqPdZ)NwZmkHWB5OL6E4bRXnVooL7ZW8)P1mJsi8woAPUhEWEgPrO1HrnhNbNrSgthpbGz94OScCl5Z3qG0CtihT0pyHxi1VExYLgiCgXAmDmCZymHTSFhknHUXCSg3864zMu5tO1HrnhNbNrSgthpbGz94OScCl5Z3qGa65aWLgDT5cz7aWKlnW(DiLatI58(pTMzucH3Yrl19Wd2ZWCQ59FAn73OhuLJwYRB1oGH7SNbD65fUaVG9B0dQYrl51TAhWWDgE(xGR0i06WOMJZGZiwJPJNaWSECuwbUL85BiW2ZE9oA4YFbq24s(FrmhHwhg1CCgCgXAmD8eaM1JJYkWTKpFdbUHnstq15sTFasU0aZ7)0A2VrpOkhTKx3QDad3zpdZ59FAnZOecVLJwQ7HhSNbHwhg1CCgCgXAmD8eaMLXe1CjxAG)NwZmkHWB5OL6E4b7zy()0AgUzmMWw2VdLMq3yo2ZGqRdJAoodoJynMoEcaZ6lMzj1VExYLg4)P1mJsi8woAPUhEWEgM)pTMHBgJjSL97qPj0nMJ9mi06WOMJZGZiwJPJNaWS(yZXMM6aKCPb(FAnZOecVLJwQ7HhSNbHwhg1CCgCgXAmD8eaML3q)qPXtWXKlnWuZ7)0AMrjeElhTu3dpypdZomkkGs8WTc5zcmJ0OtpV)tRzgLq4TC0sDp8G9mmNA)oKTqDbRitG5yUFxbLgJjSzluxWkYeifj)0i06WOMJZGZiwJPJNaWSefaQbxMB9wa2WlsU0a)pTMzucH3Yrl19Wd2ZGqRdJAoodoJynMoEcaZIt1H0iqzqfLVZ00b1DjxAGH3aWGf1gkJrUkmZ9jfHwhg1CCgCgXAmD8eaML)NT68OMtkQTFYLgOdJIcOepCRqEMzqN(F4CcTomQ54m4mI1y64jamlUjV3QdGCR4rYLgOdJIcOepCRqEMzqN(F4CcTomQ54m4mI1y64jamR2lokxOVi06WOMJZGZiwJPJNaWS8dI8ODHe6crYLg4)P1mJsi8woAPUhEWEgM)pTMHBgJjSL97qPj0nMJ9mi06WOMJZGZiwJPJNaWS0vJFXmRKlnW)tRzgLq4TC0sDp8G14MxhNsGumZ)NwZWnJXe2Y(DO0e6gZXEgeADyuZXzWzeRX0XtaywFhGC0YOlin8KlnW)tRzgLq4TC0sDp8G9mmN6)P1mJsi8woAPUhEWACZRJtzoMdxGxWGJyjPIEhm88Vax0PNx4c8cgCeljv07GHN)f4Y8)P1mJsi8woAPUhEWACZRJtzssZSdJIcOepCRqoW90P)FAnJJyqToaY2bGSNHzhgffqjE4wHCG7j0sOLIsS5UE4bXcNrSgthNqRdJAoodoJynMoEcaZYOecVLJwQ7HhjxAGPcNrSgthd3mgtyl73HstOBmhRXnVooD6HlWlyfeHUbdp)lWvAMZ7)0AMrjeElhTu3dpypdcTomQ54m4mI1y64jamRFJEqvoAjVUv7agUN8JJYrRLaGlG7tU0aHZiwJPJHBgJjSL97qPj0nMJ14Mxh3mCgXAmDmJsi8woAPUhEWACZRJtO1HrnhNbNrSgthpbGzHBgJjSL97qPj0nMl5sdeoJynMoMrjeElhTu3dpyn6RDMdxGxWMVOcS9OMJHN)f4YC)oKf1gkJrMtMaGlZ97kO0ymHnBH6cwrMa3NpD6rTHYyKRcPmJ8j06WOMJZGZiwJPJNaWSWnJXe2Y(DO0e6gZLCPbMkCgXAmDmJsi8woAPUhEWA0x7OtpQnugJCviLzKFAMdxGxW(n6bv5OL86wTdy4odp)lWL5(DfuAmMWotks(eADyuZXzWzeRX0Xtayw4MXycBz)ouAcDJ5sU0adxGxWkicDdgE(xGlZ97qktcHwhg1CCgCgXAmD8eaMf1Dgtqf7TcknAKJhej06WOMJZGZiwJPJNaWSGUqiDyuZjffps(8neiCeljv07i5sdmCbEbdoILKk6DWWZ)cCzo1u)pTMbhXssf9oy8WH0KjW95BEH)NwZAp7PliY4HdPbyoPrNEuBOmg5QqkbcaUsJqRdJAoodoJynMoEcaZs3dpmTR34s9R3LCPbM6)P1mJsi8woAPUhEWEgM9SXUcKvWDsyf(cfS2pAOe4EZP(FAnZOecVLJwQ7HhSg3864uceaCrN()P1S3rDe7K8OXdqqL14MxhNsGaGlZ)NwZEh1rStYJgpabv2ZiT0i06WOMJZGZiwJPJNaWS09Wdt76nUu)6DjxAGP(FAnRG7KWk8fkypdZ5fUaVGvqe6gm88VaxMt9)0A27OoIDsE04biOYEg0P)FAnRG7KWk8fkynU51XPeia4kT0Ot))0Awb3jHv4luWEgM)pTMvWDsyf(cfSg3864uceaCzoCbEbRGi0ny45FbUm)FAnZOecVLJwQ7HhSNbHwhg1CCgCgXAmD8eaMLUhEyAxVXL6xVl5sdmQnugJCviLaGl60tnQnugJCviLWzeRX0XmkHWB5OL6E4bRXnVoU5)tRzVJ6i2j5rJhGGk7zKgHwcTomQ54mKZXdICGFXml5OLbvuIhUTl5sd8)0AMrjeElhTu3dpypdZP(FAnZOecVLJwQ7HhSg3864uUpFZP(FAn73OhuLJwYRB1oGH7SNbD6HlWlyZxub2EuZXWZ)cCrNE4c8cwbrOBWWZ)cCzoppBSRazfCNewHVqbdp)lWvA0P)FAnRG7KWk8fkypdZHlWlyfeHUbdp)lWvAeADyuZXziNJhe5jamlapVxLFYrl9SXEcQjxAG5fUaVGvqe6gm88Vax0PhUaVGvqe6gm88VaxM9SXUcKvWDsyf(cfm88VaxM)pTMzucH3Yrl19WdwJBEDCkPiM)pTMzucH3Yrl19Wd2ZGo9Wf4fScIq3GHN)f4YCEE2yxbYk4ojScFHcgE(xGlcTomQ54mKZXdI8eaMfKAjesE0OttYLg4)P1mJsi8woAPUhEWACZRJtzoM)pTMzucH3Yrl19Wd2ZGo9O2qzmYvHuMdHwhg1CCgY54brEcaZkOIY39N3TK6PHyYLg4)P1SgH0iqoxQNgISNbD6)NwZAesJa5CPEAikHZ7cSz8WH0q5(9eADyuZXziNJhe5jaml9aFCCj9SXUcu(rFl5sdmV)tRzgLq4TC0sDp8G9mmN3)P1SFJEqvoAjVUv7agUZEgeADyuZXziNJhe5jaml4Cq8I2dCj1cFdtU0aZ7)0AMrjeElhTu3dpypdZ59FAn73OhuLJwYRB1oGH7SNH51em4Cq8I2dCj1cFdL)xFSg3864aZNqRdJAood5C8GipbGzzAAXIcyDYg5Z5hetU0a)pTMzucH3Yrl19Wd2ZGo9)tRz4MXycBz)ouAcDJ5ypd60HZiwJPJ9B0dQYrl51TAhWWDwJBED8mPi5NW(COthoD)mIAooRouR9VaLr)cQm88VaxeADyuZXziNJhe5jamRUmmeOSoj3WHyYLgyE)NwZmkHWB5OL6E4b7zyoV)tRz)g9GQC0sEDR2bmCN9mi06WOMJZqohpiYtaywB4207KJwkEWAjxn6B8KlnW)tRz4MXycBz)ouAcDJ5ynU51XPmhZ)NwZ(n6bv5OL86wTdy4o7zqNEQ97qwuBOmgzgzcaUm3VRGsJXe2uMt(PrO1HrnhNHCoEqKNaWSA0nQdGul8nKtOLqlfLyZn)lQaBpQ5i2EcpQ5i06WOMJZMVOcS9OMdyJBtZrbY5st1fyNCPbgUaVGbWdQyxhajpMEJHN)f4IqRdJAooB(IkW2JAUeaM18fvGThyYWDqbkdVbGbh4(KlnWux4)P1S2ZE6cImE4qAOmh60x4)P1S2ZE6cISg3864uUp)0mNx4c8cMUhEWH7cQidp)lWL58(pTM11gYEgM5gOqidVbGbNrDmjQdG8lCEKjWKqO1HrnhNnFrfy7rnxcaZA(IkW2dm5sdmVWf4fmDp8Gd3furgE(xGlZ59FAnRRnK9mmZnqHqgEdadoJ6ysuha5x48itGjHqRdJAooB(IkW2JAUeaMLUhEWH7cQyYLgyQ)NwZOPeI6ai3Ci16qwJomOtp1)tRz0ucrDaKBoKADi7zyovJgPGeaCX2Z09Wdjp6IgKoDJgPGeaCX2ZOoMe1bq(fopOt3OrkibaxS9machwUq6lk4hetlT0mZnqHqgEdadot3dp4WDbvmtGzqO1HrnhNnFrfy7rnxcaZA(IkW2dmz4oOaLH3aWGdCFYLgyQl8)0Aw7zpDbrgpCinuMdD6l8)0Aw7zpDbrwJBEDCk3NFAM)pTMrtje1bqU5qQ1HSgDyqNEQ)NwZOPeI6ai3Ci16q2ZWCQgnsbja4ITNP7HhsE0fniD6gnsbja4ITNrDmjQdG8lCEqNUrJuqcaUy7zaeoSCH0xuWpiMwAeADyuZXzZxub2EuZLaWSMVOcS9atU0a)pTMrtje1bqU5qQ1HSgDyqNEQ)NwZOPeI6ai3Ci16q2ZWCQgnsbja4ITNP7HhsE0fniD6gnsbja4ITNrDmjQdG8lCEqNUrJuqcaUy7zaeoSCH0xuWpiMwAeADyuZXzZxub2EuZLaWSwOhu5Y1dtU0aDyuuaL4HBfYZmdcTomQ54S5lQaBpQ5saywl0dQs)wYfc9DjxAGomkkGs8WTc5zMbHwhg1CC28fvGTh1CjamlachwUq6lk4hetU0atnV)tRzDTHSNbD697kO0ymHnBH6cwbL7ZNo9(DilQnugJmJmbaxPzMBGcHm8gagCgaHdlxi9ff8dIzcmdcTomQ54S5lQaBpQ5saywuhtI6ai)cNhjxAG)NwZ6AdzpdZCduiKH3aWGZOoMe1bq(fopYeygeADyuZXzZxub2EuZLaWS09Wdjp6Igmz4oOaLH3aWGdCFYLgyQl8)0Aw7zpDbrgpCinuMdD6l8)0Aw7zpDbrwJBEDCk3NFAMZ7)0AwxBi7zqNE)UckngtyZwOUGvq5(8PtVFhYIAdLXiZitaWL58cxGxW09WdoCxqfz45FbUi06WOMJZMVOcS9OMlbGzP7HhsE0fnyYLgyE)NwZ6Adzpd6073vqPXycB2c1fSck3NpD697qwuBOmgzgzcaUi06WOMJZMVOcS9OMlbGzrDmjQdG8lCEKCPb(FAnRRnK9mi06WOMJZMVOcS9OMlbGznFrfy7bMmChuGYWBayWbUp5sdm1f(FAnR9SNUGiJhoKgkZHo9f(FAnR9SNUGiRXnVooL7ZpnZ5fUaVGP7HhC4UGkYWZ)cCrO1HrnhNnFrfy7rnxcaZA(IkW2dKqlHwkkXcg(T8ErS86aiqk(WBayqS9eEuZrO1HrnhNXd)wEVa2420CuGCU0uDb2eADyuZXz8WVL3ReaMLUhEi5rx0GjxAGWzeRX0XACBAokqoxAQUaBwJBEDCkbMrUcaUmhUaVGbWdQyxhajpMEJHN)f4IqRdJAooJh(T8ELaWSOoMe1bq(fopsU0a)pTM11gYEgeADyuZXz8WVL3ReaM18fvGThyYLgy4c8cwbrOBWWZ)cCz()0AMrjeElhTu3dpypdZE2yxbYk4ojScFHcw7hnzcmdcTomQ54mE43Y7vcaZA(IkW2dm5sdmV)tRz6EYgpPXtWr2ZWC4c8cMUNSXtA8eCKHN)f4IqRdJAooJh(T8ELaWS09Wdjp6Igm5sdSFxbLgJjSzluxWkOm195Kq4c8cw)Uck9iW75rnhdp)lWvUMK0i06WOMJZ4HFlVxjamlDp8Gd3fuXKlnW)tRz0ucrDaKBoKADi7zyUFhYIAdLXitQmbcaUi06WOMJZ4HFlVxjamR5lQaBpWKlnW(DfuAmMWMTqDbRiZuZiNecxGxW63vqPhbEppQ5y45FbUY1KKgHwhg1CCgp8B59kbGzP7HhsE0fniHwhg1CCgp8B59kbGzrD6toAPP6cSj06WOMJZ4HFlVxjamlVH(HYy6gVqbYnqOkXmYzVkuHsb]] )

end
