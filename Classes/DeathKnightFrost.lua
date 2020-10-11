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


    spec:RegisterPack( "Frost DK", 20201011, [[dKecwcqirfpciL2efzuIKoLiXQevrVseAwIOUfqQ0Uq5xIsgMOQoMsLLjk6zIGMMiGRjQ02asvFtuLY4asX5ebQ1jQsO5be3dq7tu4GIajluKQhkQs0efvjPlcKkAJIQunsrGuoPiq0krkEjqQGBkceANIi)ueiyOIQKyPIQe8uKmvrkFfivO9sQ)s0GP0HPAXQQhJyYk5YqBMKpdWObQtlz1IQK61iLMnHBRu2Tk)wXWPWXfvHLl1Zr10fUUQSDGKVtrnErGuDELQwVOuZhPA)GwVtNMMA5bQtkZ8Zm)D5VBhBx(je0KaGgnvS3a1ugoHwhaQPoFd1u59E4b0Mxf0bnLHVxm(sNMMIpVMGAkWryWZlMvwaQa87ZiZww8A7j8OMJ0UkYIxBKS0u)xjIeKN(RPwEG6KYm)mZFx(72X2LFcbnjqEtt5Va80AkQAlVutbUwl80Fn1c5enfOfAZ79WdOnVk6byOf0HRaaoG0aAH2eeiX8XgA3TlzOnZ8ZmFinqAaTqBEjy)aG88IqAaTqlOl0MG8iI3cH2eeRBbT59gXSrgKgql0c6cTjOwlOv5cX3j0cTQPH2hVoaqlOZ8cGoMm0MxzY7qBPGwdHVhBOTUkkpqo0M(qbTFunncTgZiQda0kgafbAlo0sMndbg4IbPb0cTGUqBEjy)aGqB4namyrTHYyKRcH2yG2O2qzmYvHqBmq7JJqlEK5Db2qRapabyOT9am2qBa2pO1yc8IYfqB0ohm0UqpaZzqAaTqlOl0MxoIf0MGg6DaT(TG22jLlG2Wm60YzAkrXdUonnfzeljy07qNMoPD600u45FbU0PRPiDfyxUM6)ukgzeljy07GXdNql0Mb0Ml0AcAJAdLXixfcTGaTailnLtIAonfbSxhxokzrqDOtktDAAk88Vax601uKUcSlxtLk0(FkfJJyaUoaY2bGSg3864qliqlaYcAtbAnbT)NsX4igGRdGSDai7zOPCsuZPPiG964YrjlcQdDsjuNMMcp)lWLoDnfPRa7Y1uPcT)NsXmkHWB5OKQE4bRXnVoo0ccqOfazbT5j0Mk0UdAteAjZiwJ5JP6HhM33BCP617zn6R9qBkqlD6q7)PumJsi8wokPQhEWACZRJdTGaT97qwuBOmgzcH2uGwtq7)PumJsi8wokPQhEWEgqRjOnvO1Zg7kqwr2ljv4luWA)OfAbbi0UdAPthA)pLI9B0dWYrj51TAhWWD2ZaAtbAnbT5aTHlWlyfbjUbdp)lWLMYjrnNMIa2RJlhLSiOo0jLa600u45FbU0PRPiDfyxUM6)ukMrjeElhLu1dpynU51XHwqGwqd0AcA)pLI9oWJyVKhnEacWSg3864qliqlaYcAZtOnvODh0Mi0sMrSgZht1dpmVV34s1R3ZA0x7H2uGwtq7)PuS3bEe7L8OXdqaM14MxhhAnbT)NsXmkHWB5OKQE4b7zaTMG2uHwpBSRazfzVKuHVqbR9JwOfeGq7oOLoDO9)uk2VrpalhLKx3QDad3zpdOnfO1e0Md0gUaVGveK4gm88VaxAkNe1CAkcyVoUCuYIG6qNuU600u45FbU0PRPiDfyxUMkvO9)ukwr2ljv4luWACZRJdTGaTja0sNo0(FkfRi7LKk8fkynU51XHwqG2(DilQnugJmHqBkqRjO9)ukwr2ljv4luWEgqRjO1Zg7kqwr2ljv4luWA)OfAZai0Mj0AcAZbA)pLI9B0dWYrj51TAhWWD2ZaAnbT5aTHlWlyfbjUbdp)lWLMYjrnNMIa2RJlhLSiOo0jb61PPPWZ)cCPtxtr6kWUCn1)PuSISxsQWxOG9mGwtq7)PuS3bEe7L8OXdqaM9mGwtqRNn2vGSISxsQWxOG1(rl0MbqOntO1e0Md0(Fkf73OhGLJsYRB1oGH7SNb0AcAZbAdxGxWkcsCdgE(xGlnLtIAonfbSxhxokzrqDOtkVPtttHN)f4sNUMI0vGD5AQ)tPygLq4TCusvp8G14MxhhAbbAtaO1e0(FkfZOecVLJsQ6HhSNb0AcAdxGxWkcsCdgE(xGlO1e0(FkfJmILem6DW4HtOfAZai0Ud0aTMGwpBSRazfzVKuHVqbR9JwOfeGq7onLtIAonfbSxhxokzrqDOtc0OtttHN)f4sNUMI0vGD5AQ)tPygLq4TCusvp8G9mGwtqB4c8cwrqIBWWZ)cCbTMGwpBSRazfzVKuHVqbR9JwOndGqBMqRjOnvO9)ukgzeljy07GXdNql0MbqODxcgAnbT)NsXkYEjPcFHcwJBEDCOfeOfazbTMG2)tPyfzVKuHVqb7zaT0PdT)NsXEh4rSxYJgpaby2ZaAnbT)NsXiJyjbJEhmE4eAH2macT7anqBkAkNe1CAkcyVoUCuYIG6qhAQ5lQaBpQ50PPtANonnfE(xGlD6Aksxb2LRPcxGxWa4bySRdGKhtVXWZ)cCPPCsuZPPACBAokqoxAUUaBDOtktDAAk88Vax601uojQ50uZxub2EGAksxb2LRPsfAx4)PuS2ZE6IGmE4eAHwqG2CHw60H2f(FkfR9SNUiiRXnVoo0cc0UlFOnfO1e0Md0gUaVGP6HhCY(amYWZ)cCbTMG2CG2)tPyDTHSNb0AcA5gOqidVbGbNbEmlQdG8lCEaTzaeAtOMISNiqz4nam46K2PdDsjuNMMcp)lWLoDnfPRa7Y1u5aTHlWlyQE4bNSpaJm88VaxqRjOnhO9)ukwxBi7zaTMGwUbkeYWBayWzGhZI6ai)cNhqBgaH2eQPCsuZPPMVOcS9a1HoPeqNMMcp)lWLoDnfPRa7Y1uPcT)NsXOTeI6ai3Cc46qwJojGw60H2uH2)tPy0wcrDaKBobCDi7zaTMG2uHwJgbLeazX2Xu9Wdjp6IweAPthAnAeusaKfBhd8ywuha5x48aAPthAnAeusaKfBhdGWjLlK(cu(rqOnfOnfOnfO1e0YnqHqgEdadot1dp4K9byeAZai0MPMYjrnNMs1dp4K9byuh6KYvNMMcp)lWLoDnLtIAon18fvGThOMI0vGD5AQuH2f(FkfR9SNUiiJhoHwOfeOnxOLoDODH)NsXAp7PlcYACZRJdTGaT7YhAtbAnbT)NsXOTeI6ai3Cc46qwJojGw60H2uH2)tPy0wcrDaKBobCDi7zaTMG2uHwJgbLeazX2Xu9Wdjp6IweAPthAnAeusaKfBhd8ywuha5x48aAPthAnAeusaKfBhdGWjLlK(cu(rqOnfOnfnfzprGYWBayW1jTth6Ka9600u45FbU0PRPiDfyxUM6)ukgTLquha5MtaxhYA0jb0sNo0Mk0(FkfJ2siQdGCZjGRdzpdO1e0Mk0A0iOKail2oMQhEi5rx0IqlD6qRrJGscGSy7yGhZI6ai)cNhqlD6qRrJGscGSy7yaeoPCH0xGYpccTPaTPOPCsuZPPMVOcS9a1HoP8MonnfE(xGlD6Aksxb2LRPCsuGcL4HBfYH2mG2m1uojQ50ul0dWC56H6qNeOrNMMcp)lWLoDnfPRa7Y1uojkqHs8WTc5qBgqBMAkNe1CAQf6byPFl5cj(EDOtkbRtttHN)f4sNUMI0vGD5AQuH2CG2)tPyDTHSNb0sNo02VRisJXm2SfQksfqliq7U8Hw60H2(DilQnugJmtOndOfazbTPaTMGwUbkeYWBayWzaeoPCH0xGYpccTzaeAZut5KOMttbq4KYfsFbk)iOo0jTlFDAAk88Vax601uKUcSlxt9FkfRRnK9mGwtql3afcz4nam4mWJzrDaKFHZdOndGqBMAkNe1CAkWJzrDaKFHZdDOtA3oDAAk88Vax601uojQ50uQE4HKhDrlQPiDfyxUMkvODH)NsXAp7PlcY4HtOfAbbAZfAPthAx4)PuS2ZE6IGSg3864qliq7U8H2uGwtqBoq7)PuSU2q2ZaAPthA73vePXygB2cvfPcOfeODx(qlD6qB)oKf1gkJrMj0Mb0cGSGwtqBoqB4c8cMQhEWj7dWidp)lWLMISNiqz4nam46K2PdDs7YuNMMcp)lWLoDnfPRa7Y1u5aT)NsX6AdzpdOLoDOTFxrKgJzSzluvKkGwqG2D5dT0PdT97qwuBOmgzMqBgqlaYst5KOMttP6HhsE0fTOo0jTlH600u45FbU0PRPiDfyxUM6)ukwxBi7zOPCsuZPPapMf1bq(fop0HoPDjGonnfE(xGlD6AkNe1CAQ5lQaBpqnfPRa7Y1uPcTl8)ukw7zpDrqgpCcTqliqBUqlD6q7c)pLI1E2txeK14MxhhAbbA3Lp0Mc0AcAZbAdxGxWu9WdozFagz45FbU0uK9ebkdVbGbxN0oDOtAxU600uojQ50uZxub2EGAk88Vax601Ho0u)HlJIqBDa0PPtANonnfE(xGlD6Aksxb2LRPiZiwJ5JHBgJzSL97qPz0nMJ14Mxhxt5KOMttzucH3Yrjv9WdDOtktDAAkNe1CAkCZymJTSFhknJUXCAk88Vax601HoPeQtttHN)f4sNUMYjrnNMA(IkW2dutr6kWUCnvQq7c)pLI1E2txeKXdNql0cc0Ml0sNo0UW)tPyTN90fbznU51XHwqG2D5dTPaTMG2(DfrAmMXgAbbi0MWmHwtqBoqB4c8cMQhEWj7dWidp)lWLMISNiqz4nam46K2PdDsjGonnfE(xGlD6Aksxb2LRP63vePXygBOfeGqBcZut5KOMttnFrfy7bQdDs5QtttHN)f4sNUMI0vGD5AQWf4fmaEag76ai5X0Bm88VaxAkNe1CAQg3MMJcKZLMRlWwh6Ka9600u45FbU0PRPiDfyxUM6)ukwxBi7zOPCsuZPPapMf1bq(fop0HoP8MonnfE(xGlD6AkNe1CAQ5lQaBpqnfPRa7Y1uPcTl8)ukw7zpDrqgpCcTqliqBUqlD6q7c)pLI1E2txeK14MxhhAbbA3Lp0Mc0AcA73HSO2qzmYCHwqGwaKf0sNo02VRisJXm2qliaH2eixO1e0Md0gUaVGP6HhCY(amYWZ)cCPPi7jcugEdadUoPD6qNeOrNMMcp)lWLoDnfPRa7Y1u97qwuBOmgzUqliqlaYcAPthA73vePXygBOfeGqBcKRMYjrnNMA(IkW2duh6KsW600u45FbU0PRPiDfyxUM6)ukgTLquha5MtaxhYEgqRjOLBGcHm8gagCMQhEWj7dWi0MbqOntnLtIAonLQhEWj7dWOo0jTlFDAAk88Vax601uKUcSlxt1VRisJXm2SfQksfqBgaH2eMj0AcA73HSO2qzmYecTzaTailnLtIAonf4Pp5OKMRlWwh6K2TtNMMYjrnNMQXTP5Oa5CP56cS1u45FbU0PRdDs7YuNMMcp)lWLoDnfPRa7Y1uCduiKH3aWGZu9WdozFagH2macTzQPCsuZPPu9WdozFag1HoPDjuNMMcp)lWLoDnLtIAon18fvGThOMI0vGD5AQuH2f(FkfR9SNUiiJhoHwOfeOnxOLoDODH)NsXAp7PlcYACZRJdTGaT7YhAtbAnbT97kI0ymJnBHQIub0Mb0MzUqlD6qB)oeAZaAti0AcAZbAdxGxWu9WdozFagz45FbU0uK9ebkdVbGbxN0oDOtAxcOtttHN)f4sNUMI0vGD5AQ(DfrAmMXMTqvrQaAZaAZmxOLoDOTFhcTzaTjut5KOMttnFrfy7bQdDs7YvNMMcp)lWLoDnfPRa7Y1u97kI0ymJnBHQIub0Mb0MB(AkNe1CAkVj(HYy6gVqh6qtHCoEeKRttN0oDAAk88Vax601uKUcSlxt9FkfZOecVLJsQ6HhSNb0AcAtfA)pLIzucH3Yrjv9WdwJBEDCOfeODx(qRjOnvO9)uk2VrpalhLKx3QDad3zpdOLoDOnCbEbB(IkW2JAogE(xGlOLoDOnCbEbRiiXny45FbUGwtqBoqRNn2vGSISxsQWxOGHN)f4cAtbAPthA)pLIvK9ssf(cfSNb0AcAdxGxWkcsCdgE(xGlOnfnLtIAon1xmZsokzagL4HB71HoPm1PPPWZ)cCPtxtr6kWUCnvoqB4c8cwrqIBWWZ)cCbT0PdTHlWlyfbjUbdp)lWf0AcA9SXUcKvK9ssf(cfm88VaxqRjO9)ukMrjeElhLu1dpynU51XHwqGwqp0AcA)pLIzucH3Yrjv9Wd2ZaAPthAdxGxWkcsCdgE(xGlO1e0Md06zJDfiRi7LKk8fky45FbU0uojQ50uaEEVk)KJs6zJ9eG1HoPeQtttHN)f4sNUMI0vGD5AQ)tPygLq4TCusvp8G14MxhhAbbAZfAnbT)NsXmkHWB5OKQE4b7zaT0PdTrTHYyKRcHwqG2C1uojQ50ueWLqi5rJoT6qNucOtttHN)f4sNUMI0vGD5AQ)tPynsOvGCUunnbzpdOLoDO9)ukwJeAfiNlvttqjzExGnJhoHwOfeOD3onLtIAonvagLV7pVBjvttqDOtkxDAAk88Vax601uKUcSlxtLd0(FkfZOecVLJsQ6HhSNb0AcAZbA)pLI9B0dWYrj51TAhWWD2Zqt5KOMttPgYJJlPNn2vGYp6B6qNeOxNMMcp)lWLoDnfPRa7Y1u5aT)NsXmkHWB5OKQE4b7zaTMG2CG2)tPy)g9aSCusEDR2bmCN9mGwtq7AcgzocEr7bUKkHVHY)RpwJBEDCOfi0MVMYjrnNMImhbVO9axsLW3qDOtkVPtttHN)f4sNUMI0vGD5AQ)tPygLq4TCusvp8G9mGw60H2)tPy4MXygBz)ouAgDJ5ypdOLoDOLmJynMp2VrpalhLKx3QDad3znU51XH2mGwqF(qBIq7UCHw60HwY09ZiQ54S6qLY)cug9laZWZ)cCPPCsuZPPmpTybkSozJ858JG6qNeOrNMMcp)lWLoDnfPRa7Y1u5aT)NsXmkHWB5OKQE4b7zaTMG2CG2)tPy)g9aSCusEDR2bmCN9m0uojQ50uDzyiqzDsUHtqDOtkbRtttHN)f4sNUMI0vGD5AQ)tPy4MXygBz)ouAgDJ5ynU51XHwqG2CHwtq7)PuSFJEawokjVUv7agUZEgqlD6qBQqB)oKf1gkJrMj0Mb0cGSGwtqB)UIingZydTGaT5Mp0MIMYjrnNMAd3MEVCusXJul5QrFJRdDs7YxNMMcp)lWLoDnfPRa7Y1u5aT)NsXmkHWB5OKQE4b7zaTMG2CG2)tPy)g9aSCusEDR2bmCN9mGwtqBQqB4namyGrxeGLgKaAZai0cAYhAPthAdVbGbdm6IaS0GeqliaH2mZhAPthAvfaWHSXnVoo0cc0Ma5cTPOPCsuZPPA0nQdGuj8nKRdDOP(dxAmJOoa600jTtNMMcp)lWLoDnfPRa7Y1u)NsX6AdzpdnLtIAonf4XSOoaYVW5Ho0jLPonnfE(xGlD6AkNe1CAQ5lQaBpqnfPRa7Y1uPcTl8)ukw7zpDrqgpCcTqliqBUqlD6q7c)pLI1E2txeK14MxhhAbbA3Lp0Mc0AcA73vePXygB2cvfPcOndGqBM5cTMG2CG2Wf4fmvp8Gt2hGrgE(xGlnfzprGYWBayW1jTth6KsOonnfE(xGlD6Aksxb2LRP63vePXygB2cvfPcOndGqBM5QPCsuZPPMVOcS9a1HoPeqNMMcp)lWLoDnfPRa7Y1u97kI0ymJnBHQIub0cc0Mz(qRjOLBGcHm8gagCgaHtkxi9fO8JGqBgaH2mHwtqlzgXAmFmJsi8wokPQhEWACZRJdTzaT5QPCsuZPPaiCs5cPVaLFeuh6KYvNMMcp)lWLoDnLtIAonLQhEi5rx0IAksxb2LRPsfAx4)PuS2ZE6IGmE4eAHwqG2CHw60H2f(FkfR9SNUiiRXnVoo0cc0UlFOnfO1e02VRisJXm2SfQksfqliqBM5dTMG2CG2Wf4fmvp8Gt2hGrgE(xGlO1e0sMrSgZhZOecVLJsQ6HhSg3864qBgqBUAkYEIaLH3aWGRtANo0jb61PPPWZ)cCPtxtr6kWUCnv)UIingZyZwOQivaTGaTzMp0AcAjZiwJ5JzucH3Yrjv9WdwJBEDCOndOnxnLtIAonLQhEi5rx0I6qNuEtNMMcp)lWLoDnfPRa7Y1u)NsXOTeI6ai3Cc46q2ZaAnbT97kI0ymJnBHQIub0Mb0Mk0UlxOnrOnCbEbRFxrKEe498OMJHN)f4cAZtOnHqBkqRjOLBGcHm8gagCMQhEWj7dWi0MbqOntnLtIAonLQhEWj7dWOo0jbA0PPPWZ)cCPtxtr6kWUCnv)UIingZyZwOQivaTzaeAtfAtyUqBIqB4c8cw)UIi9iW75rnhdp)lWf0MNqBcH2uGwtql3afcz4nam4mvp8Gt2hGrOndGqBMAkNe1CAkvp8Gt2hGrDOtkbRtttHN)f4sNUMYjrnNMA(IkW2dutr6kWUCnvQq7c)pLI1E2txeKXdNql0cc0Ml0sNo0UW)tPyTN90fbznU51XHwqG2D5dTPaTMG2(DfrAmMXMTqvrQaAZai0Mk0MWCH2eH2Wf4fS(Dfr6rG3ZJAogE(xGlOnpH2ecTPaTMG2CG2Wf4fmvp8Gt2hGrgE(xGlnfzprGYWBayW1jTth6K2LVonnfE(xGlD6Aksxb2LRP63vePXygB2cvfPcOndGqBQqBcZfAteAdxGxW63vePhbEppQ5y45FbUG28eAti0MIMYjrnNMA(IkW2duh6K2TtNMMcp)lWLoDnfPRa7Y1uKzeRX8XmkHWB5OKQE4bRXnVoo0Mb02VdzrTHYyKja0AcA73vePXygB2cvfPcOfeOnbYhAnbTCduiKH3aWGZaiCs5cPVaLFeeAZai0MPMYjrnNMcGWjLlK(cu(rqDOtAxM600u45FbU0PRPCsuZPPu9Wdjp6Iwutr6kWUCnvQq7c)pLI1E2txeKXdNql0cc0Ml0sNo0UW)tPyTN90fbznU51XHwqG2D5dTPaTMGwYmI1y(ygLq4TCusvp8G14MxhhAZaA73HSO2qzmYeaAnbT97kI0ymJnBHQIub0cc0Ma5dTMG2CG2Wf4fmvp8Gt2hGrgE(xGlnfzprGYWBayW1jTth6K2LqDAAk88Vax601uKUcSlxtrMrSgZhZOecVLJsQ6HhSg3864qBgqB)oKf1gkJrMaqRjOTFxrKgJzSzluvKkGwqG2eiFnLtIAonLQhEi5rx0I6qhAkJgjZ23dDA6K2Pttt5KOMttzmrnNMcp)lWLoDDOtktDAAk88Vax601uNVHAkpBoyVDUunxihL0ymJTMYjrnNMYZMd2BNlvZfYrjngZyRdDsjuNMMcp)lWLoDn1yOP4yOPCsuZPPaL3L)fOMcuU4HAQuHwmpELHbUy3etxZJlbi8v5X0C53xaqOLoDOfZJxzyGlgz6(ze4scq4RYJP5YVVaGqlD6qlMhVYWaxmY09ZiWLeGWxLhtZLB4YfIAoOLoDOfZJxzyGlgOkxihL0VAZdCj)IzwqlD6qlMhVYWaxmv18qU5bYLCJ9aeoNdT0PdTyE8kddCXYRrUe8ywGn0sNo0I5XRmmWf7My6AECjaHVkpMMl3WLle1CqlD6qlMhVYWaxmNdgu(HCz7zpTKmTlG2u0uGYB55BOMAcWylNt(4OeZJxzyGlDOdnfzgXAmFCDA6K2PtttHN)f4sNUMYjrnNMYZMd2BNlvZfYrjngZyRPiDfyxUMkvOLmJynMpgUzmMXw2VdLMr3yowJ(Ap0AcAZbAbL3L)fiBcWylNt(4OeZJxzyGlOnfOLoDOnvOLmJynMpMrjeElhLu1dpynU51XHwqacT7YhAnbTGY7Y)cKnbySLZjFCuI5XRmmWf0MIM68nut5zZb7TZLQ5c5OKgJzS1HoPm1PPPWZ)cCPtxt5KOMttjEnTyZL1XRvnpUeqPcnfPRa7Y1uHlWly)g9aSCusEDR2bmCNHN)f4cAnbTPcTPcTKzeRX8XmkHWB5OKQE4bRXnVoo0ccqODx(qRjOfuEx(xGSjaJTCo5JJsmpELHbUG2uGw60H2uH2)tPygLq4TCusvp8G9mGwtqBoqlO8U8VaztagB5CYhhLyE8kddCbTPaTPaT0PdTPcT)NsXmkHWB5OKQE4b7zaTMG2CG2Wf4fSFJEawokjVUv7agUZWZ)cCbTPOPoFd1uIxtl2CzD8AvZJlbuQqh6KsOonnfE(xGlD6AkNe1CAkYEIyIEUIi)cNhAksxb2LRPYbA)pLIzucH3Yrjv9Wd2ZqtD(gQPi7jIj65kI8lCEOdDsjGonnfE(xGlD6Aksxb2LRPsfAjZiwJ5JzucH3Yrjv9WdwJ(Ap0sNo0sMrSgZhZOecVLJsQ6HhSg3864qBgqBM5dTPaTMG2uH2CG2Wf4fSFJEawokjVUv7agUZWZ)cCbT0PdTKzeRX8XWnJXm2Y(DO0m6gZXACZRJdTzaTj4CH2u0uojQ50upokRa346qNuU600u45FbU0PRPCsuZPPCoyq5hYLTN90sY0Uqtr6kWUCn1c)pLI1E2tljt7c5c)pLITgZNM68nut5CWGYpKlBp7PLKPDHo0jb61PPPWZ)cCPtxt5KOMtt5CWGYpKlBp7PLKPDHMI0vGD5AkYmI1y(y4MXygBz)ouAgDJ5ynU51XH2mG2eC(qRjODH)NsXAp7PLKPDHCH)NsXEgqRjOfuEx(xGSjaJTCo5JJsmpELHbUGw60H2)tPy)g9aSCusEDR2bmCN9mGwtq7c)pLI1E2tljt7c5c)pLI9mGwtqBoqlO8U8VaztagB5CYhhLyE8kddCbT0PdT)NsXWnJXm2Y(DO0m6gZXEgqRjODH)NsXAp7PLKPDHCH)NsXEgqRjOnhOnCbEb73OhGLJsYRB1oGH7m88VaxqlD6qBuBOmg5QqOfeOnZDAQZ3qnLZbdk)qUS9SNwsM2f6qNuEtNMMcp)lWLoDnLtIAonvEnYLGhZcS1uKUcSlxtLk0I5XRmmWft8AAXMlRJxRAECjGsfqRjO9)ukMrjeElhLu1dpynU51XH2uGw60H2uH2CGwmpELHbUyIxtl2CzD8AvZJlbuQaAnbT)NsXmkHWB5OKQE4bRXnVoo0cc0UltO1e0(FkfZOecVLJsQ6HhSNb0MIM68nutLxJCj4XSaBDOtc0OtttHN)f4sNUMYjrnNMI2Bc5OK(rk8cP6171uKUcSlxtrMrSgZhd3mgZyl73HsZOBmhRXnVoo0Mb0Ma5RPoFd1u0EtihL0psHxivVEVo0jLG1PPPWZ)cCPtxt5KOMttbONdaxA01MlKTda1uKUcSlxt1VdHwqacTjeAnbT5aT)NsXmkHWB5OKQE4b7zaTMG2uH2CG2)tPy)g9aSCusEDR2bmCN9mGw60H2CG2Wf4fSFJEawokjVUv7agUZWZ)cCbTPOPoFd1ua65aWLgDT5cz7aqDOtAx(600u45FbU0PRPoFd1uTN96D0YL)cGSXL8)IyonLtIAonv7zVEhTC5VaiBCj)ViMth6K2TtNMMcp)lWLoDnLtIAon1g2iTbyNlv(bqtr6kWUCnvoq7)PuSFJEawokjVUv7agUZEgqRjOnhO9)ukMrjeElhLu1dpypdn15BOMAdBK2aSZLk)aOdDs7YuNMMcp)lWLoDnfPRa7Y1u)NsXmkHWB5OKQE4b7zaTMG2)tPy4MXygBz)ouAgDJ5ypdnLtIAonLXe1C6qN0UeQtttHN)f4sNUMI0vGD5AQ)tPygLq4TCusvp8G9mGwtq7)PumCZymJTSFhknJUXCSNHMYjrnNM6lMzjvVEVo0jTlb0PPPWZ)cCPtxtr6kWUCn1)PumJsi8wokPQhEWEgAkNe1CAQp2CSPToa6qN0UC1PPPWZ)cCPtxtr6kWUCnvQqBoq7)PumJsi8wokPQhEWEgqRjO1jrbkuIhUvihAZai0Mj0Mc0sNo0Md0(FkfZOecVLJsQ6HhSNb0AcAtfA73HSfQksfqBgaH2CHwtqB)UIingZyZwOQivaTzaeAb95dTPOPCsuZPP8M4hknEcoQdDs7a9600u45FbU0PRPiDfyxUM6)ukMrjeElhLu1dpypdnLtIAonLOaao4Y863cWgEHo0jTlVPtttHN)f4sNUMI0vGD5AQWBayWIAdLXixfcTzaT7sanLtIAonfhStOvGYamkFN5PdW71HoPDGgDAAk88Vax601uKUcSlxt5KOafkXd3kKdTzaTzcT0PdT)HZ1uojQ50u(F2QZJAoPO2(6qN0UeSonnfE(xGlD6Aksxb2LRPCsuGcL4HBfYH2mG2mHw60H2)W5AkNe1CAkUzV3QdGCR4Ho0jLz(600uojQ50uTxCuUqFPPWZ)cCPtxh6KYCNonnfE(xGlD6Aksxb2LRP(pLIzucH3Yrjv9Wd2ZaAnbT)NsXWnJXm2Y(DO0m6gZXEgAkNe1CAk)iipAxijUqOdDszMPonnfE(xGlD6Aksxb2LRP(pLIzucH3Yrjv9WdwJBEDCOfeGqlObAnbT)NsXWnJXm2Y(DO0m6gZXEgAkNe1CAkv14xmZsh6KYmH600u45FbU0PRPiDfyxUM6)ukMrjeElhLu1dpypdO1e0Mk0(FkfZOecVLJsQ6HhSg3864qliqBUqRjOnCbEbJmILem6DWWZ)cCbT0PdT5aTHlWlyKrSKGrVdgE(xGlO1e0(FkfZOecVLJsQ6HhSg3864qliqBcH2uGwtqRtIcuOepCRqo0ceA3bT0PdT)NsX4igGRdGSDai7zaTMGwNefOqjE4wHCOfi0Utt5KOMtt9DaYrjJUi0Y1HoPmtaDAAk88Vax601uKUcSlxtLk0sMrSgZhd3mgZyl73HsZOBmhRXnVoo0sNo0gUaVGveK4gm88VaxqBkqRjOnhO9)ukMrjeElhLu1dpypdnLtIAonLrjeElhLu1dp0HoPmZvNMMcp)lWLoDnfPRa7Y1uKzeRX8XWnJXm2Y(DO0m6gZXACZRJdTMGwYmI1y(ygLq4TCusvp8G14Mxhxt5KOMtt9B0dWYrj51TAhWWDn1JJYrPKailDs70HoPmb9600u45FbU0PRPiDfyxUMImJynMpMrjeElhLu1dpyn6R9qRjOnCbEbB(IkW2JAogE(xGlO1e02VdzrTHYyK5cTzaTailO1e02VRisJXm2SfQksfqBgaH2D5dT0PdTrTHYyKRcHwqG2mZxt5KOMttHBgJzSL97qPz0nMth6KYmVPtttHN)f4sNUMI0vGD5AQuHwYmI1y(ygLq4TCusvp8G1OV2dT0PdTrTHYyKRcHwqG2mZhAtbAnbTHlWly)g9aSCusEDR2bmCNHN)f4cAnbT97kI0ymJn0Mb0c6Zxt5KOMttHBgJzSL97qPz0nMth6KYe0OtttHN)f4sNUMI0vGD5AQWf4fSIGe3GHN)f4cAnbT97qOfeOnHAkNe1CAkCZymJTSFhknJUXC6qNuMjyDAAkNe1CAkW7nMam2BfrA0ihpcQPWZ)cCPtxh6Ksy(600u45FbU0PRPiDfyxUMkCbEbJmILem6DWWZ)cCbTMG2uH2uH2)tPyKrSKGrVdgpCcTqBgaH2D5dTMG2f(FkfR9SNUiiJhoHwOfi0Ml0Mc0sNo0g1gkJrUkeAbbi0cGSG2u0uojQ50uexiKojQ5KIIhAkrXd55BOMImILem6DOdDsjCNonnfE(xGlD6Aksxb2LRPsfA)pLIzucH3Yrjv9Wd2ZaAnbTE2yxbYkYEjPcFHcw7hTqliaH2DqRjOnvO9)ukMrjeElhLu1dpynU51XHwqacTailOLoDO9)uk27apI9sE04biaZACZRJdTGaeAbqwqRjO9)uk27apI9sE04biaZEgqBkqBkAkNe1CAkvp8W8(EJlvVEVo0jLWm1PPPWZ)cCPtxtr6kWUCnvQq7)PuSISxsQWxOG9mGwtqBoqB4c8cwrqIBWWZ)cCbTMG2uH2)tPyVd8i2l5rJhGam7zaT0PdT)NsXkYEjPcFHcwJBEDCOfeGqlaYcAtbAtbAPthA)pLIvK9ssf(cfSNb0AcA)pLIvK9ssf(cfSg3864qliaHwaKf0AcAdxGxWkcsCdgE(xGlO1e0(FkfZOecVLJsQ6HhSNHMYjrnNMs1dpmVV34s1R3RdDsjmH600u45FbU0PRPiDfyxUMkQnugJCvi0cc0cGSGw60H2uH2O2qzmYvHqliqlzgXAmFmJsi8wokPQhEWACZRJdTMG2)tPyVd8i2l5rJhGam7zaTPOPCsuZPPu9WdZ77nUu9696qhAkE43Y7LonDs70PPPCsuZPPACBAokqoxAUUaBnfE(xGlD66qNuM600u45FbU0PRPiDfyxUMImJynMpwJBtZrbY5sZ1fyZACZRJdTGaeAZeAZtOfazbTMG2Wf4fmaEag76ai5X0Bm88VaxAkNe1CAkvp8qYJUOf1HoPeQtttHN)f4sNUMI0vGD5AQ)tPyDTHSNHMYjrnNMc8ywuha5x48qh6KsaDAAk88Vax601uKUcSlxtfUaVGveK4gm88VaxqRjO9)ukMrjeElhLu1dpypdO1e06zJDfiRi7LKk8fkyTF0cTzaeAZut5KOMttnFrfy7bQdDs5QtttHN)f4sNUMI0vGD5AQCG2)tPyQEYgpPXtWr2ZaAnbTHlWlyQEYgpPXtWrgE(xGlnLtIAon18fvGThOo0jb61PPPWZ)cCPtxtr6kWUCnv)UIingZyZwOQivaTGaTPcT7YfAteAdxGxW63vePhbEppQ5y45FbUG28eAti0MIMYjrnNMs1dpK8OlArDOtkVPtttHN)f4sNUMI0vGD5AQ)tPy0wcrDaKBobCDi7zaTMG2(DilQnugJmbG2macTailnLtIAonLQhEWj7dWOo0jbA0PPPWZ)cCPtxtr6kWUCnv)UIingZyZwOQivaTzaTPcTzMl0Mi0gUaVG1VRispc8EEuZXWZ)cCbT5j0MqOnfnLtIAon18fvGThOo0jLG1PPPCsuZPPu9Wdjp6IwutHN)f4sNUo0jTlFDAAkNe1CAkWtFYrjnxxGTMcp)lWLoDDOtA3oDAAkNe1CAkVj(HYy6gVqtHN)f4sNUo0HMAHk)jcDA6K2Pttt5KOMttTv3sQAeZg1u45FbU0PRdDszQtttHN)f4sNUMI0vGD5AQCG21emvp8qQqqHnlkcT1baAnbTPcT5aTHlWly)g9aSCusEDR2bmCNHN)f4cAPthAjZiwJ5J9B0dWYrj51TAhWWDwJBEDCOndODxUqBkAkNe1CAkWJzrDaKFHZdDOtkH600u45FbU0PRPiDfyxUM6)ukwr2ldxmhN14MxhhAbbi0cGSGwtq7)PuSISxgUyoo7zaTMGwUbkeYWBayWzaeoPCH0xGYpccTzaeAZeAnbTPcT5aTHlWly)g9aSCusEDR2bmCNHN)f4cAPthAjZiwJ5J9B0dWYrj51TAhWWDwJBEDCOndODxUqBkAkNe1CAkacNuUq6lq5hb1HoPeqNMMcp)lWLoDnfPRa7Y1u)NsXkYEz4I54Sg3864qliaHwaKf0AcA)pLIvK9YWfZXzpdO1e0Mk0Md0gUaVG9B0dWYrj51TAhWWDgE(xGlOLoDOLmJynMp2VrpalhLKx3QDad3znU51XH2mG2D5cTPOPCsuZPPu9Wdjp6Iwuh6KYvNMMcp)lWLoDnLtIAonfXfcPtIAoPO4HMsu8qE(gQPqohpcY1HojqVonnfE(xGlD6AkNe1CAkIlesNe1CsrXdnLO4H88nutrMrSgZhxh6KYB600u45FbU0PRPiDfyxUM6)uk2VrpalhLKx3QDad3zpdnLtIAonv)oPtIAoPO4HMsu8qE(gQP(dxgfH26aOdDsGgDAAk88Vax601uKUcSlxtfUaVG9B0dWYrj51TAhWWDgE(xGlO1e0Mk0Mk0sMrSgZh73OhGLJsYRB1oGH7Sg3864qlqOnFO1e0sMrSgZhZOecVLJsQ6HhSg3864qliq7U8H2uGw60H2uHwYmI1y(y)g9aSCusEDR2bmCN14MxhhAbbAZmFO1e0g1gkJrUkeAbbAtyUqBkqBkAkNe1CAQ(DsNe1CsrXdnLO4H88nut9hU0ygrDa0HoPeSonnfE(xGlD6Aksxb2LRP(pLIzucH3Yrjv9Wd2ZaAnbTHlWlyZxub2EuZXWZ)cCPPCsuZPP63jDsuZjffp0uIIhYZ3qn18fvGTh1C6qN0U81PPPWZ)cCPtxtr6kWUCnLtIcuOepCRqo0MbqOntnLtIAonv)oPtIAoPO4HMsu8qE(gQP8b1HoPD70PPPWZ)cCPtxt5KOMttrCHq6KOMtkkEOPefpKNVHAkE43Y7Lo0HMYhuNMoPD600u45FbU0PRPiDfyxUMkCbEbdGhGXUoasEm9gdp)lWf0sNo0Mk06zJDfit1t24jdCZa5bR9JwO1e0YnqHqgEdadoRXTP5Oa5CP56cSH2macTjeAnbT5aT)NsX6AdzpdOnfnLtIAonvJBtZrbY5sZ1fyRdDszQtttHN)f4sNUMI0vGD5AQWf4fmvp8Gt2hGrgE(xGlnLtIAonfaHtkxi9fO8JG6qNuc1PPPWZ)cCPtxt5KOMttP6HhsE0fTOMI0vGD5AQuH2f(FkfR9SNUiiJhoHwOfeOnxOLoDODH)NsXAp7PlcYACZRJdTGaT7YhAtbAnbTKzeRX8XACBAokqoxAUUaBwJBEDCOfeGqBMqBEcTailO1e0gUaVGbWdWyxhajpMEJHN)f4cAnbT5aTHlWlyQE4bNSpaJm88VaxAkYEIaLH3aWGRtANo0jLa600u45FbU0PRPiDfyxUMImJynMpwJBtZrbY5sZ1fyZACZRJdTGaeAZeAZtOfazbTMG2Wf4fmaEag76ai5X0Bm88VaxAkNe1CAkvp8qYJUOf1HoPC1PPPWZ)cCPtxtr6kWUCn1)PuSU2q2Zqt5KOMttbEmlQdG8lCEOdDsGEDAAk88Vax601uKUcSlxt9FkfJ2siQdGCZjGRdzpdnLtIAonLQhEWj7dWOo0jL30PPPWZ)cCPtxtr6kWUCnv)UIingZyZwOQivaTGaTPcT7YfAteAdxGxW63vePhbEppQ5y45FbUG28eAti0MIMYjrnNMcGWjLlK(cu(rqDOtc0OtttHN)f4sNUMYjrnNMs1dpK8OlArnfPRa7Y1uPcTl8)ukw7zpDrqgpCcTqliqBUqlD6q7c)pLI1E2txeK14MxhhAbbA3Lp0Mc0AcA73vePXygB2cvfPcOfeOnvODxUqBIqB4c8cw)UIi9iW75rnhdp)lWf0MNqBcH2uGwtqBoqB4c8cMQhEWj7dWidp)lWLMISNiqz4nam46K2PdDsjyDAAk88Vax601uKUcSlxt1VRisJXm2SfQksfqliqBQq7UCH2eH2Wf4fS(Dfr6rG3ZJAogE(xGlOnpH2ecTPaTMG2CG2Wf4fmvp8Gt2hGrgE(xGlnLtIAonLQhEi5rx0I6qN0U81PPPWZ)cCPtxtr6kWUCnLtIcuOepCRqo0Mb0MPMYjrnNMAHEaMlxpuh6K2TtNMMcp)lWLoDnfPRa7Y1uojkqHs8WTc5qBgqBMAkNe1CAQf6byPFl5cj(EDOtAxM600uojQ50unUnnhfiNlnxxGTMcp)lWLoDDOtAxc1PPPCsuZPPu9WdozFag1u45FbU0PRdDs7saDAAk88Vax601uojQ50uZxub2EGAksxb2LRPsfAx4)PuS2ZE6IGmE4eAHwqG2CHw60H2f(FkfR9SNUiiRXnVoo0cc0UlFOnfO1e02VRisJXm2SfQksfqBgqBQqBM5cTjcTHlWly97kI0JaVNh1Cm88VaxqBEcTjeAtbAnbT5aTHlWlyQE4bNSpaJm88VaxAkYEIaLH3aWGRtANo0jTlxDAAk88Vax601uKUcSlxt1VRisJXm2SfQksfqBgqBQqBM5cTjcTHlWly97kI0JaVNh1Cm88VaxqBEcTjeAtrt5KOMttnFrfy7bQdDs7a9600uojQ50uaeoPCH0xGYpcQPWZ)cCPtxh6K2L30PPPWZ)cCPtxt5KOMttP6HhsE0fTOMI0vGD5AQuH2f(FkfR9SNUiiJhoHwOfeOnxOLoDODH)NsXAp7PlcYACZRJdTGaT7YhAtbAnbT5aTHlWlyQE4bNSpaJm88VaxAkYEIaLH3aWGRtANo0jTd0Ottt5KOMttP6HhsE0fTOMcp)lWLoDDOtAxcwNMMYjrnNMc80NCusZ1fyRPWZ)cCPtxh6KYmFDAAkNe1CAkVj(HYy6gVqtHN)f4sNUo0Ho0uGcBEnNoPmZpZ8ZpbNjOxtz27RoaCnvcYnJPdCbT7YhADsuZbTIIhCgKgnf3aj6KYm3DAkJEuLa1uGwOnV3dpG28QOhGHwqhUca4asdOfAtqGeZhBOD3UKH2mZpZ8H0aPb0cT5LG9daYZlcPb0cTGUqBcYJiEleAtqSUf0M3BeZgzqAaTqlOl0MGATGwLleFNql0QMgAF86aaTGoZla6yYqBELjVdTLcAne(ESH26QO8a5qB6df0(r10i0AmJOoaqRyaueOT4qlz2meyGlgKgql0c6cT5LG9dacTH3aWGf1gkJrUkeAJbAJAdLXixfcTXaTpocT4rM3fydTc8aeGH22dWydTby)GwJjWlkxaTr7CWq7c9amNbPb0cTGUqBE5iwqBcAO3b063cABNuUaAdZOtlNbPbsdOfAbDMGosEbUG2pQMgHwYS99aA)iG64mOnbfHGgbhAV5aDb79M6jGwNe1CCODoXEgKgNe1CCMrJKz77rIaZYyIAoinojQ54mJgjZ23JebM1JJYkWTKpFdb6zZb7TZLQ5c5OKgJzSH04KOMJZmAKmBFpseywGY7Y)cm5Z3qGtagB5CYhhLyE8kddCLmOCXdbMkMhVYWaxSBIPR5XLae(Q8yAU87laiD6yE8kddCXit3pJaxsacFvEmnx(9faKoDmpELHbUyKP7NrGljaHVkpMMl3WLle1C0PJ5XRmmWfduLlKJs6xT5bUKFXml60X84vgg4IPQMhYnpqUKBShGW5C60X84vgg4ILxJCj4XSaB60X84vgg4IDtmDnpUeGWxLhtZLB4YfIAo60X84vgg4I5CWGYpKlBp7PLKPDrkqAG0aAHwqNjOJKxGlOfbf27H2O2qOnaJqRtIPH2IdToO8s4FbYG04KOMJdCRULu1iMncPb0cTjOmme7H28Ep8aAZ7iOWgA9BbTBEDHxh0MGKShAtZfZXH04KOMJNiWSapMf1bq(fopsUuaZznbt1dpKkeuyZIIqBDamLAoHlWly)g9aSCusEDR2bmCNHN)f4IoDYmI1y(y)g9aSCusEDR2bmCN14MxhpJD5McKgNe1C8ebMfaHtkxi9fO8JGjxkG)NsXkYEz4I54Sg3864Gaeazz6)ukwr2ldxmhN9mmXnqHqgEdadodGWjLlK(cu(rWmaMPPuZjCbEb73OhGLJsYRB1oGH7m88Vax0PtMrSgZh73OhGLJsYRB1oGH7Sg3864zSl3uG04KOMJNiWSu9Wdjp6Iwm5sb8)ukwr2ldxmhN14MxhheGailt)NsXkYEz4I54SNHPuZjCbEb73OhGLJsYRB1oGH7m88Vax0PtMrSgZh73OhGLJsYRB1oGH7Sg3864zSl3uG04KOMJNiWSiUqiDsuZjffps(8neiY54rqoKgNe1C8ebMfXfcPtIAoPO4rYNVHajZiwJ5JdPXjrnhprGz1Vt6KOMtkkEK85BiW)WLrrOToajxkG)NsX(n6by5OK86wTdy4o7zaPXjrnhprGz1Vt6KOMtkkEK85BiW)WLgZiQdqYLcy4c8c2VrpalhLKx3QDad3z45FbUmLAQKzeRX8X(n6by5OK86wTdy4oRXnVooW8nrMrSgZhZOecVLJsQ6HhSg3864GSl)uOtpvYmI1y(y)g9aSCusEDR2bmCN14MxhhKmZ3uuBOmg5QqqsyUPKcKgNe1C8ebMv)oPtIAoPO4rYNVHaNVOcS9OMl5sb8)ukMrjeElhLu1dpypdtHlWlyZxub2EuZXWZ)cCbPXjrnhprGz1Vt6KOMtkkEK85BiqFWKlfqNefOqjE4wH8maMjKgNe1C8ebMfXfcPtIAoPO4rYNVHa5HFlVxqAG0aAH2eudOtOnVWeEuZbPXjrnhN5dcSXTP5Oa5CP56cStUuadxGxWa4bySRdGKhtVXWZ)cCrNEQE2yxbYu9KnEYa3mqEWA)O1e3afcz4nam4Sg3MMJcKZLMRlWodGj0uo)NsX6AdzpJuG04KOMJZ8bteywaeoPCH0xGYpcMCPagUaVGP6HhCY(amYWZ)cCbPXjrnhN5dMiWSu9Wdjp6IwmzYEIaLH3aWGdCxYLcyQl8)ukw7zpDrqgpCcTGKlD6l8)ukw7zpDrqwJBEDCq2LFkMiZiwJ5J1420CuGCU0CDb2Sg3864GamZ8eazzkCbEbdGhGXUoasEm9gdp)lWLPCcxGxWu9WdozFagz45FbUG04KOMJZ8bteywQE4HKhDrlMCPasMrSgZhRXTP5Oa5CP56cSznU51XbbyM5jaYYu4c8cgapaJDDaK8y6ngE(xGlinojQ54mFWebMf4XSOoaYVW5rYLc4)PuSU2q2ZasJtIAooZhmrGzP6HhCY(amMCPa(FkfJ2siQdGCZjGRdzpdinojQ54mFWebMfaHtkxi9fO8JGjxkG97kI0ymJnBHQIubiPUl3edxGxW63vePhbEppQ5y45FbUYZeMcKgNe1CCMpyIaZs1dpK8OlAXKj7jcugEdadoWDjxkGPUW)tPyTN90fbz8Wj0csU0PVW)tPyTN90fbznU51Xbzx(PyQFxrKgJzSzluvKkaj1D5My4c8cw)UIi9iW75rnhdp)lWvEMWumLt4c8cMQhEWj7dWidp)lWfKgNe1CCMpyIaZs1dpK8OlAXKlfW(DfrAmMXMTqvrQaKu3LBIHlWly97kI0JaVNh1Cm88Vax5zctXuoHlWlyQE4bNSpaJm88VaxqACsuZXz(GjcmRf6byUC9WKlfqNefOqjE4wH8mYesJtIAooZhmrGzTqpal9BjxiX3NCPa6KOafkXd3kKNrMqACsuZXz(GjcmRg3MMJcKZLMRlWgsJtIAooZhmrGzP6HhCY(amcPXjrnhN5dMiWSMVOcS9atMSNiqz4nam4a3LCPaM6c)pLI1E2txeKXdNqli5sN(c)pLI1E2txeK14MxhhKD5NIP(DfrAmMXMTqvrQiJuZm3edxGxW63vePhbEppQ5y45FbUYZeMIPCcxGxWu9WdozFagz45FbUG04KOMJZ8bteywZxub2EGjxkG97kI0ymJnBHQIurgPMzUjgUaVG1VRispc8EEuZXWZ)cCLNjmfinojQ54mFWebMfaHtkxi9fO8JGqACsuZXz(Gjcmlvp8qYJUOftMSNiqz4nam4a3LCPaM6c)pLI1E2txeKXdNqli5sN(c)pLI1E2txeK14MxhhKD5NIPCcxGxWu9WdozFagz45FbUG04KOMJZ8bteywQE4HKhDrlcPXjrnhN5dMiWSap9jhL0CDb2qACsuZXz(GjcmlVj(HYy6gVasdKgql0MEJEagAhf0sv3QDad3HwJze1baA7j8OMdAZlcT8W7GdTzMphA)OAAeAZRucH3q7OG28Ep8aAteAtFOGwVrO1bLxc)lqinojQ54S)WLgZiQdaqWJzrDaKFHZJKlfW)tPyDTHSNbKgNe1CC2F4sJze1birGznFrfy7bMmzprGYWBayWbUl5sbm1f(FkfR9SNUiiJhoHwqYLo9f(FkfR9SNUiiRXnVooi7Ypft97kI0ymJnBHQIurgaZmxt5eUaVGP6HhCY(amYWZ)cCbPXjrnhN9hU0ygrDaseywZxub2EGjxkG97kI0ymJnBHQIurgaZmxinojQ54S)WLgZiQdqIaZcGWjLlK(cu(rWKlfW(DfrAmMXMTqvrQaKmZ3e3afcz4nam4macNuUq6lq5hbZayMMiZiwJ5JzucH3Yrjv9WdwJBED8mYfsJtIAoo7pCPXmI6aKiWSu9Wdjp6IwmzYEIaLH3aWGdCxYLcyQl8)ukw7zpDrqgpCcTGKlD6l8)ukw7zpDrqwJBEDCq2LFkM63vePXygB2cvfPcqYmFt5eUaVGP6HhCY(amYWZ)cCzImJynMpMrjeElhLu1dpynU51XZixinojQ54S)WLgZiQdqIaZs1dpK8OlAXKlfW(DfrAmMXMTqvrQaKmZ3ezgXAmFmJsi8wokPQhEWACZRJNrUqACsuZXz)HlnMruhGebMLQhEWj7dWyYLc4)PumAlHOoaYnNaUoK9mm1VRisJXm2SfQksfzK6UCtmCbEbRFxrKEe498OMJHN)f4kptykM4gOqidVbGbNP6HhCY(amMbWmH04KOMJZ(dxAmJOoajcmlvp8Gt2hGXKlfW(DfrAmMXMTqvrQidGPMWCtmCbEbRFxrKEe498OMJHN)f4kptykM4gOqidVbGbNP6HhCY(amMbWmH04KOMJZ(dxAmJOoajcmR5lQaBpWKj7jcugEdadoWDjxkGPUW)tPyTN90fbz8Wj0csU0PVW)tPyTN90fbznU51Xbzx(PyQFxrKgJzSzluvKkYayQjm3edxGxW63vePhbEppQ5y45FbUYZeMIPCcxGxWu9WdozFagz45FbUG04KOMJZ(dxAmJOoajcmR5lQaBpWKlfW(DfrAmMXMTqvrQidGPMWCtmCbEbRFxrKEe498OMJHN)f4kptykqACsuZXz)HlnMruhGebMfaHtkxi9fO8JGjxkGKzeRX8XmkHWB5OKQE4bRXnVoEg97qwuBOmgzcyQFxrKgJzSzluvKkajbY3e3afcz4nam4macNuUq6lq5hbZayMqACsuZXz)HlnMruhGebMLQhEi5rx0Ijt2teOm8gagCG7sUuatDH)NsXAp7PlcY4HtOfKCPtFH)NsXAp7PlcYACZRJdYU8tXezgXAmFmJsi8wokPQhEWACZRJNr)oKf1gkJrMaM63vePXygB2cvfPcqsG8nLt4c8cMQhEWj7dWidp)lWfKgNe1CC2F4sJze1birGzP6HhsE0fTyYLcizgXAmFmJsi8wokPQhEWACZRJNr)oKf1gkJrMaM63vePXygB2cvfPcqsG8H0aPb0cT5Dxi(oHwOngO9XrOnVYK3tgAbDMxa0rO1my8G2hhBq36QO8a5qB6df0A04MhVgf7zqACsuZXz)HlJIqBDaaAucH3Yrjv9WJKlfqYmI1y(y4MXygBz)ouAgDJ5ynU51XH04KOMJZ(dxgfH26aKiWSWnJXm2Y(DO0m6gZbPXjrnhN9hUmkcT1birGznFrfy7bMmzprGYWBayWbUl5sbm1f(FkfR9SNUiiJhoHwqYLo9f(FkfR9SNUiiRXnVooi7Ypft97kI0ymJniatyMMYjCbEbt1dp4K9byKHN)f4csJtIAoo7pCzueARdqIaZA(IkW2dm5sbSFxrKgJzSbbycZesJtIAoo7pCzueARdqIaZQXTP5Oa5CP56cStUuadxGxWa4bySRdGKhtVXWZ)cCbPXjrnhN9hUmkcT1birGzbEmlQdG8lCEKCPa(FkfRRnK9mG04KOMJZ(dxgfH26aKiWSMVOcS9atMSNiqz4nam4a3LCPaM6c)pLI1E2txeKXdNqli5sN(c)pLI1E2txeK14MxhhKD5NIP(DilQnugJmxqaqw0P3VRisJXm2GambY1uoHlWlyQE4bNSpaJm88VaxqACsuZXz)HlJIqBDaseywZxub2EGjxkG97qwuBOmgzUGaGSOtVFxrKgJzSbbycKlKgNe1CC2F4YOi0whGebMLQhEWj7dWyYLc4)PumAlHOoaYnNaUoK9mmXnqHqgEdadot1dp4K9bymdGzcPXjrnhN9hUmkcT1birGzbE6tokP56cStUua73vePXygB2cvfPImaMWmn1VdzrTHYyKjmdaKfKgNe1CC2F4YOi0whGebMvJBtZrbY5sZ1fydPXjrnhN9hUmkcT1birGzP6HhCY(amMCPaYnqHqgEdadot1dp4K9bymdGzcPXjrnhN9hUmkcT1birGznFrfy7bMmzprGYWBayWbUl5sbm1f(FkfR9SNUiiJhoHwqYLo9f(FkfR9SNUiiRXnVooi7Ypft97kI0ymJnBHQIurgzMlD697WmsOPCcxGxWu9WdozFagz45FbUG04KOMJZ(dxgfH26aKiWSMVOcS9atUua73vePXygB2cvfPImYmx6073HzKqinojQ54S)WLrrOToajcmlVj(HYy6gVi5sbSFxrKgJzSzluvKkYi38H0aPb0cT5LJybTGrVdOLm3QIAooKgNe1CCgzeljy07aibSxhxokzrWKlfW)tPyKrSKGrVdgpCcTzKRPO2qzmYvHGaGSG04KOMJZiJyjbJEhjcmlcyVoUCuYIGjxkGP(FkfJJyaUoaY2bGSg3864GaGSsX0)PumoIb46aiBhaYEgqACsuZXzKrSKGrVJebMfbSxhxokzrWKlfWu)pLIzucH3Yrjv9WdwJBEDCqacGSYZu3LizgXAmFmvp8W8(EJlvVEpRrFTpf60)pLIzucH3Yrjv9WdwJBEDCq63HSO2qzmYeMIP)tPygLq4TCusvp8G9mmLQNn2vGSISxsQWxOG1(rlia3rN()PuSFJEawokjVUv7agUZEgPykNWf4fSIGe3GHN)f4csJtIAooJmILem6DKiWSiG964YrjlcMCPa(FkfZOecVLJsQ6HhSg3864GaAm9Fkf7DGhXEjpA8aeGznU51XbbazLNPUlrYmI1y(yQE4H599gxQE9EwJ(AFkM(pLI9oWJyVKhnEacWSg3864M(pLIzucH3Yrjv9Wd2ZWuQE2yxbYkYEjPcFHcw7hTGaChD6)NsX(n6by5OK86wTdy4o7zKIPCcxGxWkcsCdgE(xGlinojQ54mYiwsWO3rIaZIa2RJlhLSiyYLcyQ)NsXkYEjPcFHcwJBEDCqsa60)pLIvK9ssf(cfSg3864G0VdzrTHYyKjmft)NsXkYEjPcFHc2ZWKNn2vGSISxsQWxOG1(rBgaZ0uo)NsX(n6by5OK86wTdy4o7zykNWf4fSIGe3GHN)f4csJtIAooJmILem6DKiWSiG964YrjlcMCPa(FkfRi7LKk8fkypdt)NsXEh4rSxYJgpaby2ZWKNn2vGSISxsQWxOG1(rBgaZ0uo)NsX(n6by5OK86wTdy4o7zykNWf4fSIGe3GHN)f4csJtIAooJmILem6DKiWSiG964YrjlcMCPa(FkfZOecVLJsQ6HhSg3864GKaM(pLIzucH3Yrjv9Wd2ZWu4c8cwrqIBWWZ)cCz6)ukgzeljy07GXdNqBga3bAm5zJDfiRi7LKk8fkyTF0ccWDqACsuZXzKrSKGrVJebMfbSxhxokzrWKlfW)tPygLq4TCusvp8G9mmfUaVGveK4gm88VaxM8SXUcKvK9ssf(cfS2pAZayMMs9)ukgzeljy07GXdNqBga3LGn9FkfRi7LKk8fkynU51Xbbazz6)ukwr2ljv4luWEg0P)Fkf7DGhXEjpA8aeGzpdt)NsXiJyjbJEhmE4eAZa4oqtkqAG04KOMJZiZiwJ5Jd8Xrzf4wYNVHa9S5G925s1CHCusJXm2jxkGPsMrSgZhd3mgZyl73HsZOBmhRrFT3uoGY7Y)cKnbySLZjFCuI5XRmmWvk0PNkzgXAmFmJsi8wokPQhEWACZRJdcWD5BcuEx(xGSjaJTCo5JJsmpELHbUsbsJtIAooJmJynMpEIaZ6Xrzf4wYNVHafVMwS5Y641QMhxcOurYLcy4c8c2VrpalhLKx3QDad3z45FbUmLAQKzeRX8XmkHWB5OKQE4bRXnVooia3LVjq5D5FbYMam2Y5KpokX84vgg4kf60t9)ukMrjeElhLu1dpypdt5akVl)lq2eGXwoN8XrjMhVYWaxPKcD6P(FkfZOecVLJsQ6HhSNHPCcxGxW(n6by5OK86wTdy4odp)lWvkqACsuZXzKzeRX8XteywpokRa3s(8neizprmrpxrKFHZJKlfWC(pLIzucH3Yrjv9Wd2ZasJtIAooJmJynMpEIaZ6Xrzf4gp5sbmvYmI1y(ygLq4TCusvp8G1OV2tNozgXAmFmJsi8wokPQhEWACZRJNrM5NIPuZjCbEb73OhGLJsYRB1oGH7m88Vax0PtMrSgZhd3mgZyl73HsZOBmhRXnVoEgj4CtbsJtIAooJmJynMpEIaZ6Xrzf4wYNVHaDoyq5hYLTN90sY0Ui5sbCH)NsXAp7PLKPDHCH)NsXwJ5dsJtIAooJmJynMpEIaZ6Xrzf4wYNVHaDoyq5hYLTN90sY0Ui5sbKmJynMpgUzmMXw2VdLMr3yowJBED8msW5BAH)NsXAp7PLKPDHCH)NsXEgMaL3L)fiBcWylNt(4OeZJxzyGl60)pLI9B0dWYrj51TAhWWD2ZW0c)pLI1E2tljt7c5c)pLI9mmLdO8U8VaztagB5CYhhLyE8kddCrN()PumCZymJTSFhknJUXCSNHPf(FkfR9SNwsM2fYf(Fkf7zykNWf4fSFJEawokjVUv7agUZWZ)cCrNEuBOmg5QqqYChKgNe1CCgzgXAmF8ebM1JJYkWTKpFdbMxJCj4XSa7KlfWuX84vgg4IjEnTyZL1XRvnpUeqPct)NsXmkHWB5OKQE4bRXnVoEk0PNAoyE8kddCXeVMwS5Y641QMhxcOuHP)tPygLq4TCusvp8G14MxhhKDzA6)ukMrjeElhLu1dpypJuG04KOMJZiZiwJ5JNiWSECuwbUL85BiqAVjKJs6hPWlKQxVp5sbKmJynMpgUzmMXw2VdLMr3yowJBED8msG8H04KOMJZiZiwJ5JNiWSECuwbUL85Biqa9Ca4sJU2CHSDayYLcy)oeeGj0uo)NsXmkHWB5OKQE4b7zyk1C(pLI9B0dWYrj51TAhWWD2ZGo9CcxGxW(n6by5OK86wTdy4odp)lWvkqACsuZXzKzeRX8XteywpokRa3s(8ney7zVEhTC5VaiBCj)ViMdsJtIAooJmJynMpEIaZ6Xrzf4wYNVHa3WgPna7CPYpajxkG58Fkf73OhGLJsYRB1oGH7SNHPC(pLIzucH3Yrjv9Wd2ZasJtIAooJmJynMpEIaZYyIAUKlfW)tPygLq4TCusvp8G9mm9Fkfd3mgZyl73HsZOBmh7zaPXjrnhNrMrSgZhprGz9fZSKQxVp5sb8)ukMrjeElhLu1dpypdt)NsXWnJXm2Y(DO0m6gZXEgqACsuZXzKzeRX8XteywFS5ytBDasUua)pLIzucH3Yrjv9Wd2ZasJtIAooJmJynMpEIaZYBIFO04j4yYLcyQ58FkfZOecVLJsQ6HhSNHjNefOqjE4wH8maMzk0PNZ)PumJsi8wokPQhEWEgMsTFhYwOQivKbWCn1VRisJXm2SfQksfzae0NFkqACsuZXzKzeRX8XteywIca4GlZRFlaB4fjxkG)NsXmkHWB5OKQE4b7zaPXjrnhNrMrSgZhprGzXb7eAfOmaJY3zE6a8(KlfWWBayWIAdLXixfMXUeasJtIAooJmJynMpEIaZY)ZwDEuZjf12p5sb0jrbkuIhUvipJmPt)pCoKgNe1CCgzgXAmF8ebMf3S3B1bqUv8i5sb0jrbkuIhUvipJmPt)pCoKgNe1CCgzgXAmF8ebMv7fhLl0xqACsuZXzKzeRX8Xteyw(rqE0UqsCHi5sb8)ukMrjeElhLu1dpypdt)NsXWnJXm2Y(DO0m6gZXEgqACsuZXzKzeRX8XteywQQXVyMvYLc4)PumJsi8wokPQhEWACZRJdcqqJP)tPy4MXygBz)ouAgDJ5ypdinojQ54mYmI1y(4jcmRVdqokz0fHwEYLc4)PumJsi8wokPQhEWEgMs9)ukMrjeElhLu1dpynU51XbjxtHlWlyKrSKGrVdgE(xGl60ZjCbEbJmILem6DWWZ)cCz6)ukMrjeElhLu1dpynU51XbjHPyYjrbkuIhUvih4o60)pLIXrmaxhaz7aq2ZWKtIcuOepCRqoWDqAG0aAH28Ep8aAjZiwJ5JdPXjrnhNrMrSgZhprGzzucH3Yrjv9WJKlfWujZiwJ5JHBgJzSL97qPz0nMJ14MxhNo9Wf4fSIGe3GHN)f4kft58FkfZOecVLJsQ6HhSNbKgNe1CCgzgXAmF8ebM1VrpalhLKx3QDad3t(Xr5OusaKfWDjxkGKzeRX8XWnJXm2Y(DO0m6gZXACZRJBImJynMpMrjeElhLu1dpynU51XH04KOMJZiZiwJ5JNiWSWnJXm2Y(DO0m6gZLCPasMrSgZhZOecVLJsQ6HhSg91EtHlWlyZxub2EuZXWZ)cCzQFhYIAdLXiZndaKLP(DfrAmMXMTqvrQidG7YNo9O2qzmYvHGKz(qACsuZXzKzeRX8Xteyw4MXygBz)ouAgDJ5sUuatLmJynMpMrjeElhLu1dpyn6R90Ph1gkJrUkeKmZpftHlWly)g9aSCusEDR2bmCNHN)f4Yu)UIingZyNbOpFinojQ54mYmI1y(4jcmlCZymJTSFhknJUXCjxkGHlWlyfbjUbdp)lWLP(DiijesJtIAooJmJynMpEIaZc8EJjaJ9wrKgnYXJGqACsuZXzKzeRX8XteywexiKojQ5KIIhjF(gcKmILem6DKCPagUaVGrgXscg9oy45FbUmLAQ)NsXiJyjbJEhmE4eAZa4U8nTW)tPyTN90fbz8Wj0cm3uOtpQnugJCviiabqwPaPXjrnhNrMrSgZhprGzP6HhM33BCP617tUuat9)ukMrjeElhLu1dpypdtE2yxbYkYEjPcFHcw7hTGaCNPu)pLIzucH3Yrjv9WdwJBEDCqacGSOt))uk27apI9sE04biaZACZRJdcqaKLP)tPyVd8i2l5rJhGam7zKskqACsuZXzKzeRX8XteywQE4H599gxQE9(KlfWu)pLIvK9ssf(cfSNHPCcxGxWkcsCdgE(xGltP(Fkf7DGhXEjpA8aeGzpd60)pLIvK9ssf(cfSg3864GaeazLsk0P)FkfRi7LKk8fkypdt)NsXkYEjPcFHcwJBEDCqacGSmfUaVGveK4gm88VaxM(pLIzucH3Yrjv9Wd2ZasJtIAooJmJynMpEIaZs1dpmVV34s1R3NCPag1gkJrUkeeaKfD6Pg1gkJrUkeeYmI1y(ygLq4TCusvp8G14Mxh30)PuS3bEe7L8OXdqaM9msbsdKgNe1CCgY54rqoWVyMLCuYamkXd32NCPa(FkfZOecVLJsQ6HhSNHPu)pLIzucH3Yrjv9WdwJBEDCq2LVPu)pLI9B0dWYrj51TAhWWD2ZGo9Wf4fS5lQaBpQ5y45FbUOtpCbEbRiiXny45FbUmLJNn2vGSISxsQWxOGHN)f4kf60)pLIvK9ssf(cfSNHPWf4fSIGe3GHN)f4kfinojQ54mKZXJG8ebMfGN3RYp5OKE2ypb4KlfWCcxGxWkcsCdgE(xGl60dxGxWkcsCdgE(xGltE2yxbYkYEjPcFHcgE(xGlt)NsXmkHWB5OKQE4bRXnVooiGEt)NsXmkHWB5OKQE4b7zqNE4c8cwrqIBWWZ)cCzkhpBSRazfzVKuHVqbdp)lWfKgNe1CCgY54rqEIaZIaUecjpA0Pn5sb8)ukMrjeElhLu1dpynU51Xbjxt)NsXmkHWB5OKQE4b7zqNEuBOmg5QqqYfsJtIAood5C8iiprGzfGr57(Z7ws10em5sb8)ukwJeAfiNlvttq2ZGo9)tPynsOvGCUunnbLK5Db2mE4eAbz3oinojQ54mKZXJG8ebMLAipoUKE2yxbk)OVLCPaMZ)PumJsi8wokPQhEWEgMY5)uk2VrpalhLKx3QDad3zpdinojQ54mKZXJG8ebMfzocEr7bUKkHVHjxkG58FkfZOecVLJsQ6HhSNHPC(pLI9B0dWYrj51TAhWWD2ZW0AcgzocEr7bUKkHVHY)RpwJBEDCG5dPXjrnhNHCoEeKNiWSmpTybkSozJ858JGjxkG)NsXmkHWB5OKQE4b7zqN()PumCZymJTSFhknJUXCSNbD6KzeRX8X(n6by5OK86wTdy4oRXnVoEgG(8tCxU0PtMUFgrnhNvhQu(xGYOFbygE(xGlinojQ54mKZXJG8ebMvxggcuwNKB4em5sbmN)tPygLq4TCusvp8G9mmLZ)PuSFJEawokjVUv7agUZEgqACsuZXziNJhb5jcmRnCB69YrjfpsTKRg9nEYLc4)PumCZymJTSFhknJUXCSg3864GKRP)tPy)g9aSCusEDR2bmCN9mOtp1(DilQnugJmZmaqwM63vePXygBqYn)uG04KOMJZqohpcYteywn6g1bqQe(gYtUuaZ5)ukMrjeElhLu1dpypdt58Fkf73OhGLJsYRB1oGH7SNHPudVbGbdm6IaS0Gezae0KpD6H3aWGbgDrawAqcqaMz(0PRkaGdzJBEDCqsGCtbsdKgql0MGWxub2EuZbT9eEuZbPXjrnhNnFrfy7rnhWg3MMJcKZLMRlWo5sbmCbEbdGhGXUoasEm9gdp)lWfKgNe1CC28fvGTh1CjcmR5lQaBpWKj7jcugEdadoWDjxkGPUW)tPyTN90fbz8Wj0csU0PVW)tPyTN90fbznU51Xbzx(PykNWf4fmvp8Gt2hGrgE(xGlt58FkfRRnK9mmXnqHqgEdadod8ywuha5x48idGjesJtIAooB(IkW2JAUebM18fvGThyYLcyoHlWlyQE4bNSpaJm88VaxMY5)ukwxBi7zyIBGcHm8gagCg4XSOoaYVW5rgatiKgNe1CC28fvGTh1Cjcmlvp8Gt2hGXKlfWu)pLIrBje1bqU5eW1HSgDsqNEQ)NsXOTeI6ai3Cc46q2ZWuQgnckjaYITJP6HhsE0fTiD6gnckjaYITJbEmlQdG8lCEqNUrJGscGSy7yaeoPCH0xGYpcMskPyIBGcHm8gagCMQhEWj7dWygaZesJtIAooB(IkW2JAUebM18fvGThyYK9ebkdVbGbh4UKlfWux4)PuS2ZE6IGmE4eAbjx60x4)PuS2ZE6IGSg3864GSl)um9FkfJ2siQdGCZjGRdzn6KGo9u)pLIrBje1bqU5eW1HSNHPunAeusaKfBht1dpK8OlAr60nAeusaKfBhd8ywuha5x48GoDJgbLeazX2XaiCs5cPVaLFemLuG04KOMJZMVOcS9OMlrGznFrfy7bMCPa(FkfJ2siQdGCZjGRdzn6KGo9u)pLIrBje1bqU5eW1HSNHPunAeusaKfBht1dpK8OlAr60nAeusaKfBhd8ywuha5x48GoDJgbLeazX2XaiCs5cPVaLFemLuG04KOMJZMVOcS9OMlrGzTqpaZLRhMCPa6KOafkXd3kKNrMqACsuZXzZxub2EuZLiWSwOhGL(TKlK47tUuaDsuGcL4HBfYZitinojQ54S5lQaBpQ5seywaeoPCH0xGYpcMCPaMAo)NsX6Adzpd6073vePXygB2cvfPcq2LpD697qwuBOmgzMzaGSsXe3afcz4nam4macNuUq6lq5hbZayMqACsuZXzZxub2EuZLiWSapMf1bq(fopsUua)pLI11gYEgM4gOqidVbGbNbEmlQdG8lCEKbWmH04KOMJZMVOcS9OMlrGzP6HhsE0fTyYK9ebkdVbGbh4UKlfWux4)PuS2ZE6IGmE4eAbjx60x4)PuS2ZE6IGSg3864GSl)umLZ)PuSU2q2ZGo9(DfrAmMXMTqvrQaKD5tNE)oKf1gkJrMzgailt5eUaVGP6HhCY(amYWZ)cCbPXjrnhNnFrfy7rnxIaZs1dpK8OlAXKlfWC(pLI11gYEg0P3VRisJXm2SfQksfGSlF6073HSO2qzmYmZaazbPXjrnhNnFrfy7rnxIaZc8ywuha5x48i5sb8)ukwxBi7zaPXjrnhNnFrfy7rnxIaZA(IkW2dmzYEIaLH3aWGdCxYLcyQl8)ukw7zpDrqgpCcTGKlD6l8)ukw7zpDrqwJBEDCq2LFkMYjCbEbt1dp4K9byKHN)f4csJtIAooB(IkW2JAUebM18fvGThiKginGwOLk8B59cA51bqGGUH3aWaA7j8OMdsJtIAooJh(T8EbSXTP5Oa5CP56cSH04KOMJZ4HFlVxjcmlvp8qYJUOftUuajZiwJ5J1420CuGCU0CDb2Sg3864GamZ8eazzkCbEbdGhGXUoasEm9gdp)lWfKgNe1CCgp8B59krGzbEmlQdG8lCEKCPa(FkfRRnK9mG04KOMJZ4HFlVxjcmR5lQaBpWKlfWWf4fSIGe3GHN)f4Y0)PumJsi8wokPQhEWEgM8SXUcKvK9ssf(cfS2pAZayMqACsuZXz8WVL3RebM18fvGThyYLcyo)NsXu9KnEsJNGJSNHPWf4fmvpzJN04j4idp)lWfKgNe1CCgp8B59krGzP6HhsE0fTyYLcy)UIingZyZwOQivasQ7YnXWf4fS(Dfr6rG3ZJAogE(xGR8mHPaPXjrnhNXd)wEVseywQE4bNSpaJjxkG)NsXOTeI6ai3Cc46q2ZWu)oKf1gkJrMazaeazbPXjrnhNXd)wEVseywZxub2EGjxkG97kI0ymJnBHQIurgPMzUjgUaVG1VRispc8EEuZXWZ)cCLNjmfinojQ54mE43Y7vIaZs1dpK8OlArinojQ54mE43Y7vIaZc80NCusZ1fydPXjrnhNXd)wEVseywEt8dLX0nEHo0Hwd]] )

end
