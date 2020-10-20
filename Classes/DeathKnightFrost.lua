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


    spec:RegisterTotem( "ghoul", 1100170 )


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

            spend = function ()
                if buff.dark_succor.up then return 0 end
                return 35 * ( buff.transfusion.up and 0.5 or 1 ) * ( buff.hypothermic_presence.up and 0.65 or 1 )
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


    spec:RegisterPack( "Frost DK", 20201014.1, [[dOKzicqirrpsPQytukJsPWPeLAvkLIxrjAwuQ6wuQa7cLFjkzykLCmLkltu4zuQ00ukvxtKyBkvv9nLQsnokvKZPuk16OurvZdr6EQQ2hLKdQukXcfj9qkvqtuPusDrLQkzJkvvmsLsjXjvQQuRer5LkvLKzQukjDtLQsQDsj8tLQs0qvQkHLsPIspfHPsj1xPurH9s0FPyWKCyHfRkpgPjRKldTzs9zr1Ob40swnLkQ8AeXSr1Tvv2Tk)wXWfXXPuHwUupNW0P66aTDLQ8DrQXtPIIopIQ1Ru08b0(bTCN0AjXkCuArgBLXw72A32z7sz772EkscN8eusKeusICusCXhkj2p9iCOAB9(kjrsqoFIL0AjHyaBkkja4EIWoFwzLxoaWhJoFzjQpqE41C0o0EwI6JMLK4bwCF)(KpjXkCuArgBLXw72A32z7sz772(2LebOdyAjbr9zhkjauRfEYNKyHcQKyFGQ9tpchQ2wJHdaQ2xDvoahs2(av7lP(8WgQ2TD7HQm2kJTGKbjBFGk7qaXLJc78qY2hOYoaQ2VpkhCHq1(66wq1(PrCtKbjBFGk7aOABzTGkDW5VGscuPNgQaf1Ldv7x2zTZWEOAFXSFGQsdvj8GCSHQ6kVchfqvQdbu9q90iuLmdVUCOIp5ffQkburNVeo64IbjBFGk7aOYoeqC5iu5rNJoZRp04Jzviu5du51hA8XSkeQ8bQafiuHhDaphBOIJxUdaQ6WbGnu5aIdQsghpVcou5DiaavlmCacgKS9bQSdGk7WHVGQTvWODOkUfu1bTcou5PXGebtsWlHlKwljOdFzaGr7sRLwStATKaV4XXLmvjbTlh7kKe6khGBA8lQtavKcv50fubeiu9a1AwsX5rBgTr3JWzn(f1jGksHk7cv2GQhOwZOdFzaGr7mHhusGQFOkJTGkBqvMqLhC8C284LJD41Cm8IhhxsIG61CsckGOoHz0MIIsxArgsRLe4fpoUKPkjOD5yxHKWdoEoBE8YXo8AogEXJJlOYguLju9a1AwsX5rBgTr3JWzGjqLnOAdO6bQ1m6Wxgay0ot4bLeOYQFOA3(dv2GQhOwZapadNCJWB8YDamWeOciqO6bQ1m6Wxgay0ot4bLeOYQFOA32gQYwseuVMtsqbe1jmJ2uuu6sxsmpE5yhEnN0APf7KwljWlECCjtvsq7YXUcjHhC8CwE4aWUUCJWN(JHx844sseuVMts0430cKJcHjDDo2sxArgsRLe4fpoUKPkjcQxZjjMhVCSdhLe0UCSRqsSbuTWhOwZ6yZPlkYeEqjbQifQsbQaceQw4duRzDS50ffzn(f1jGksHQDBbvzdv2GQmHkp445mDpcxqj3bGm8IhhxqLnOktO6bQ1SU(qgycuzdQejiNB8OZrxWamP51LBE8q4qLv)qLDLeuYPC04rNJUqAXoPlTWUsRLe4fpoUKPkjOD5yxHKitOYdoEot3JWfuYDaidV4XXfuzdQYeQEGAnRRpKbMav2GkrcY5gp6C0fmatAED5Mhpeouz1puzxjrq9AojX84LJD4O0LwSDP1sc8IhhxYuLe0UCSRqsSbu9a1AgjfNxxU5lOaQdznguhQaceQ2aQEGAnJKIZRl38fua1HmWeOYguTbuL04EMC6ITJP7r4gH3fjiubeiuL04EMC6ITJbysZRl384HWHkGaHQKg3ZKtxSDSCEqRGBI1EXrrOkBOkBOkBOYgujsqo34rNJUGP7r4ck5oaeQS6hQYqseuVMtsO7r4ck5oau6slsrATKaV4XXLmvjrq9AojX84LJD4OKG2LJDfsInGQf(a1AwhBoDrrMWdkjqfPqvkqfqGq1cFGAnRJnNUOiRXVOoburkuTBlOkBOYgu9a1AgjfNxxU5lOaQdznguhQaceQ2aQEGAnJKIZRl38fua1HmWeOYguTbuL04EMC6ITJP7r4gH3fjiubeiuL04EMC6ITJbysZRl384HWHkGaHQKg3ZKtxSDSCEqRGBI1EXrrOkBOkBjbLCkhnE05OlKwSt6sl2FP1sc8IhhxYuLe0UCSRqs8a1AgjfNxxU5lOaQdznguhQaceQ2aQEGAnJKIZRl38fua1HmWeOYguTbuL04EMC6ITJP7r4gH3fjiubeiuL04EMC6ITJbysZRl384HWHkGaHQKg3ZKtxSDSCEqRGBI1EXrrOkBOkBjrq9AojX84LJD4O0LwSVLwljWlECCjtvsq7YXUcjrq9Ap0Gh(vOaQScQYqseuVMtsSWWbimlqu6slStsRLe4fpoUKPkjOD5yxHKiOEThAWd)kuavwbvzijcQxZjjwy4amXTmlKgKlDPfBBP1sc8IhhxYuLe0UCSRqsSbuLju9a1AwxFidmbQaceQAWROMKjn2SfQlA5qfPq1UTGkGaHQg8qMxFOXhtgqLvqvoDbvzdv2GkrcY5gp6C0fSCEqRGBI1EXrrOYQFOkdjrq9AojropOvWnXAV4OO0LwSBlP1sc8IhhxYuLe0UCSRqs8a1AwxFidmbQSbvIeKZnE05OlyaM086YnpEiCOYQFOkdjrq9AojbGjnVUCZJhcx6sl2TtATKaV4XXLmvjrq9AojHUhHBeExKGscAxo2vij2aQw4duRzDS50ffzcpOKavKcvPavabcvl8bQ1So2C6IISg)I6eqfPq1UTGQSHkBqvMq1duRzD9HmWeOciqOQbVIAsM0yZwOUOLdvKcv72cQaceQAWdzE9HgFmzavwbv50fuzdQYeQ8GJNZ09iCbLChaYWlECCjjOKt5OXJohDH0IDsxAXUmKwljWlECCjtvsq7YXUcjrMq1duRzD9HmWeOciqOQbVIAsM0yZwOUOLdvKcv72cQaceQAWdzE9HgFmzavwbv50LKiOEnNKq3JWncVlsqPlTyNDLwljWlECCjtvsq7YXUcjXduRzD9HmWejrq9AojbGjnVUCZJhcx6sl2TDP1sc8IhhxYuLeb1R5KeZJxo2HJscAxo2vij2aQw4duRzDS50ffzcpOKavKcvPavabcvl8bQ1So2C6IISg)I6eqfPq1UTGQSHkBqvMqLhC8CMUhHlOK7aqgEXJJljbLCkhnE05OlKwSt6sl2LI0Ajrq9AojX84LJD4OKaV4XXLmvPlDjXBegVOKuxU0APf7KwljWlECCjtvseuVMtsmpE5yhokjOD5yxHKydOAHpqTM1XMtxuKj8GscurkuLcubeiuLjuTWWbyi5QCaoRbpupDoY6yZPlkcvabcvl8bQ1So2C6IISg)I6eqfPq1UTGQSHkBqvdEf1KmPXgQi9hQ2(wqLnOktOYdoEot3JWfuYDaidV4XXLKGsoLJgp6C0fsl2jDPfziTwsGx844sMQKG2LJDfsIg8kQjzsJnur6puT9TKeb1R5KeZJxo2HJsxAHDLwljWlECCjtvsq7YXUcjHhC8CwE4aWUUCJWN(JHx844sseuVMts0430cKJcHjDDo2sxAX2LwljWlECCjtvsq7YXUcjXduRzD9HmWejrq9AojbGjnVUCZJhcx6slsrATKaV4XXLmvjrq9AojX84LJD4OKG2LJDfsInGQf(a1AwhBoDrrMWdkjqfPqvkqfqGqvMq1cdhGHKRYb4Sg8q905iRJnNUOiubeiuTWhOwZ6yZPlkYA8lQtavKcv72cQYgQSbvn4HmV(qJpMuGksHQC6cQaceQAWROMKjn2qfP)q12tbQSbvzcvEWXZz6EeUGsUdaz4fpoUKeuYPC04rNJUqAXoPlTy)LwljWlECCjtvsq7YXUcjrdEiZRp04JjfOIuOkNUGkGaHQg8kQjzsJnur6puT9uKeb1R5KeZJxo2HJsxAX(wATKaV4XXLmvjbTlh7kKepqTMrsX51LB(ckG6qgycuzdQejiNB8OZrxW09iCbLChacvw9dvzijcQxZjj09iCbLChakDPf2jP1sc8IhhxYuLe0UCSRqs0GxrnjtASzlux0YHkR(Hk7MbuzdQAWdzE9HgFm2fQScQYPljrq9AojbGPpZOnPRZXw6sl22sRLeb1R5Ken(nTa5OqysxNJTKaV4XXLmvPlTy3wsRLe4fpoUKPkjOD5yxHKqKGCUXJohDbt3JWfuYDaiuz1puLHKiOEnNKq3JWfuYDaO0LwSBN0AjbEXJJlzQsIG61CsI5Xlh7WrjbTlh7kKeBavl8bQ1So2C6IImHhusGksHQuGkGaHQmHQfgoadjxLdWzn4H6PZrwhBoDrrOciqOAHpqTM1XMtxuK14xuNaQifQ2TfuLnuzdQAWROMKjn2SfQlA5qLvqvgPavabcvn4HqLvqLDHkBqvMqLhC8CMUhHlOK7aqgEXJJljbLCkhnE05OlKwSt6sl2LH0AjbEXJJlzQscAxo2vijAWROMKjn2SfQlA5qLvqvgPavabcvn4HqLvqLDLeb1R5KeZJxo2HJsxAXo7kTwsGx844sMQKG2LJDfsIg8kQjzsJnBH6IwouzfuLYwsIG61CsIOPXHgF6gpx6sxsGcbEuuiTwAXoP1sc8IhhxYuLe0UCSRqs8a1AwsX5rBgTr3JWzGjqLnOAdO6bQ1SKIZJ2mAJUhHZA8lQtavKcv72cQSbvBavpqTM9AmCaMrBe1T6iFebdmbQaceQ8GJNZMhVCSdVMJHx844cQaceQ8GJNZkksJegEXJJlOYguLjufBID5iROKBOLhlKZWlECCbvzdvabcvpqTMvuYn0YJfYzGjqLnOYdoEoROinsy4fpoUGQSLeb1R5Kep(mlZOnoa0Gh(rU0LwKH0AjbEXJJlzQscAxo2vijYeQ8GJNZkksJegEXJJlOciqOYdoEoROinsy4fpoUGkBqvSj2LJSIsUHwESqodV4XXfuzdQEGAnlP48OnJ2O7r4Sg)I6eqfPq1(dv2GQhOwZskopAZOn6EeodmbQaceQ8GJNZkksJegEXJJlOYguLjufBID5iROKBOLhlKZWlECCjjcQxZjjYbJEvXzgTj2e7XbiDPf2vATKaV4XXLmvjbTlh7kKepqTMLuCE0MrB09iCwJFrDcOIuOkfOYgu9a1AwsX5rBgTr3JWzGjqfqGqLxFOXhZQqOIuOkfjrq9AojbfqX5gH3yqI0LwSDP1sc8IhhxYuLe0UCSRqs8a1AwJus4Oqy0ttrgycubeiu9a1AwJus4Oqy0ttrdDaphBMWdkjqfPq1UDsIG61CschaAaV3aElJEAkkDPfPiTwsGx844sMQKG2LJDfsImHQhOwZskopAZOn6EeodmbQSbvzcvpqTM9AmCaMrBe1T6iFebdmrseuVMtsOhkOaxMytSlhnpm(KU0I9xATKaV4XXLmvjbTlh7kKezcvpqTMLuCE0MrB09iCgycuzdQYeQEGAn71y4amJ2iQB1r(icgycuzdQwJZOZrXZ7WXLrZJp08a7J14xuNaQ(HQTKeb1R5Ke05O45D44YO5XhkDPf7BP1sc8IhhxYuLe0UCSRqs8a1AwsX5rBgTr3JWzGjqfqGq1duRz4xYKgBtdEOjngjZXatGkGaHk6m81K(yVgdhGz0grDRoYhrWA8lQtavwbv7)wqLLq1UuGkGaHk60nyIxZjy1HAD84OXBqhadV4XXLKiOEnNKi9081EyDMgfZfhfLU0c7K0AjbEXJJlzQscAxo2vijYeQEGAnlP48OnJ2O7r4mWeOYguLju9a1A2RXWbygTru3QJ8remWejrq9AojrxjjC0uNrKeuu6sl22sRLe4fpoUKPkjOD5yxHK4bQ1m8lzsJTPbp0KgJK5yn(f1jGksHQuGkBq1duRzVgdhGz0grDRoYhrWatGkGaHQnGQg8qMxFOXhtgqLvqvoDbv2GQg8kQjzsJnurkuLYwqv2sIG61CsIp8BAYnJ2WbP1YSAm(esxAXUTKwljWlECCjtvsq7YXUcjrMq1duRzjfNhTz0gDpcNbMav2GQmHQhOwZEngoaZOnI6wDKpIGbMav2GQnGkp6C0zaWG7amjuhQS6hQStBbvabcvE05OZaGb3bysOour6puLXwqfqGqLUYb4Mg)I6eqfPq12tbQYwseuVMts0yKuxUrZJpuiDPljEJWKmdVUCP1sl2jTwsGx844sMQKG2LJDfsIhOwZ66dzGjsIG61CscatAED5MhpeU0LwKH0AjbEXJJlzQscAxo2vij8GJNZYdha21LBe(0Fm8IhhxqLnOQbpeQS6hQsrseuVMts0430cKJcHjDDo2sxAHDLwljWlECCjtvseuVMtsmpE5yhokjOD5yxHKydOAHpqTM1XMtxuKj8GscurkuLcubeiuLjuTWWbyi5QCaoRbpupDoY6yZPlkcvabcvl8bQ1So2C6IISg)I6eqfPq1UTGQSHkBqvdEf1KmPXMTqDrlhQS6hQYifOYguLju5bhpNP7r4ck5oaKHx844ssqjNYrJhDo6cPf7KU0ITlTwsGx844sMQKG2LJDfsIg8kQjzsJnBH6Iwouz1puLrksIG61CsI5Xlh7WrPlTifP1sc8IhhxYuLe0UCSRqs0GxrnjtASzlux0YHksHQm2cQSbvIeKZnE05Oly58Gwb3eR9IJIqLv)qvgqLnOIodFnPpwsX5rBgTr3JWzn(f1jGkRGQuKeb1R5Ke58Gwb3eR9IJIsxAX(lTwsGx844sMQKiOEnNKq3JWncVlsqjbTlh7kKeBavl8bQ1So2C6IImHhusGksHQuGkGaHQmHQfgoadjxLdWzn4H6PZrwhBoDrrOciqOAHpqTM1XMtxuK14xuNaQifQ2TfuLnuzdQAWROMKjn2SfQlA5qfPqvgBbv2GQmHkp445mDpcxqj3bGm8IhhxqLnOIodFnPpwsX5rBgTr3JWzn(f1jGkRGQuKeuYPC04rNJUqAXoPlTyFlTwsGx844sMQKG2LJDfsIg8kQjzsJnBH6IwourkuLXwqLnOIodFnPpwsX5rBgTr3JWzn(f1jGkRGQuKeb1R5Ke6EeUr4DrckDPf2jP1sc8IhhxYuLe0UCSRqs8a1AgjfNxxU5lOaQdzGjqLnOQbVIAsM0yZwOUOLdvwbvBav7sbQSeQ8GJNZAWROMWD8adVMJHx844cQ2gOYUqv2qLnOsKGCUXJohDbt3JWfuYDaiuz1puLHKiOEnNKq3JWfuYDaO0LwSTLwljWlECCjtvsq7YXUcjrdEf1KmPXMTqDrlhQS6hQ2aQSBkqLLqLhC8CwdEf1eUJhy41Cm8Ihhxq12av2fQYgQSbvIeKZnE05Oly6EeUGsUdaHkR(HQmKeb1R5Ke6EeUGsUdaLU0IDBjTwsGx844sMQKiOEnNKyE8YXoCusq7YXUcjXgq1cFGAnRJnNUOit4bLeOIuOkfOciqOktOAHHdWqYv5aCwdEOE6CK1XMtxueQaceQw4duRzDS50ffzn(f1jGksHQDBbvzdv2GQg8kQjzsJnBH6Iwouz1puTbuz3uGklHkp445Sg8kQjChpWWR5y4fpoUGQTbQSluLnuzdQYeQ8GJNZ09iCbLChaYWlECCjjOKt5OXJohDH0IDsxAXUDsRLe4fpoUKPkjOD5yxHKObVIAsM0yZwOUOLdvw9dvBav2nfOYsOYdoEoRbVIAc3Xdm8AogEXJJlOABGk7cvzljcQxZjjMhVCSdhLU0IDziTwsGx844sMQKG2LJDfsc6m81K(yjfNhTz0gDpcN14xuNaQScQAWdzE9HgFmBhQSbvn4vutYKgB2c1fTCOIuOA7Bbv2GkrcY5gp6C0fSCEqRGBI1EXrrOYQFOkdjrq9AojropOvWnXAV4OO0LwSZUsRLe4fpoUKPkjcQxZjj09iCJW7Ieusq7YXUcjXgq1cFGAnRJnNUOit4bLeOIuOkfOciqOktOAHHdWqYv5aCwdEOE6CK1XMtxueQaceQw4duRzDS50ffzn(f1jGksHQDBbvzdv2Gk6m81K(yjfNhTz0gDpcN14xuNaQScQAWdzE9HgFmBhQSbvn4vutYKgB2c1fTCOIuOA7Bbv2GQmHkp445mDpcxqj3bGm8Ihhxsck5uoA8OZrxiTyN0LwSB7sRLe4fpoUKPkjOD5yxHKGodFnPpwsX5rBgTr3JWzn(f1jGkRGQg8qMxFOXhZ2HkBqvdEf1KmPXMTqDrlhQifQ2(wsIG61CscDpc3i8UibLU0LejnsNVx4sRLwStATKaV4XXLmvjXfFOKi2uai6qy0Z5MrBsM0yljcQxZjjInfaIoeg9CUz0MKjn2sxArgsRLe4fpoUKPkjMejHaDjrq9AojXErxXJJsI9coikj2aQq7iyLKGl2n(01akm58yvHpTW8IvocvabcvODeSssWfJoDdM44YKZJvf(0cZlw5iubeiuH2rWkjbxm60nyIJltopwv4tlmF4k48AoOciqOcTJGvscUy7vb3mAtC1x44Y84ZSGkGaHk0ocwjj4IPRw4MVWrHrKqEopecOciqOcTJGvscUy25qHbWKMJnubeiuH2rWkjbxSB8PRbuyY5XQcFAH5dxbNxZbvabcvODeSssWflea2louy6yZPn0PdouLTKyVOnx8HsIXbGTzodOanODeSssWL0LUKiguAT0IDsRLe4fpoUKPkjOD5yxHKWdoEolpCayxxUr4t)XWlECCbvabcvBavXMyxoY09SjEgh)sqHZ64ibQSbvIeKZnE05Olyn(nTa5OqysxNJnuz1puzxOYguLju9a1AwxFidmbQYwseuVMts0430cKJcHjDDo2sxArgsRLe4fpoUKPkjOD5yxHKWdoEot3JWfuYDaidV4XXLKiOEnNKiNh0k4MyTxCuu6slSR0AjbEXJJlzQsIG61CscDpc3i8UibLe0UCSRqsSbuTWhOwZ6yZPlkYeEqjbQifQsbQaceQYeQwy4amKCvoaN1GhQNohzDS50ffHkGaHQf(a1AwhBoDrrwJFrDcOIuOA3wqv2qLnOIodFnPpwJFtlqokeM015yZA8lQtavK(dvzavBduLtxqLnOYdoEolpCayxxUr4t)XWlECCbv2GQmHkp445mDpcxqj3bGm8Ihhxsck5uoA8OZrxiTyN0LwSDP1sc8IhhxYuLe0UCSRqsqNHVM0hRXVPfihfct66CSzn(f1jGks)HQmGQTbQYPlOYgu5bhpNLhoaSRl3i8P)y4fpoUKeb1R5Ke6EeUr4DrckDPfPiTwsGx844sMQKG2LJDfsIhOwZ66dzGjsIG61CscatAED5MhpeU0LwS)sRLe4fpoUKPkjOD5yxHK4bQ1mskoVUCZxqbuhYatKeb1R5Ke6EeUGsUdaLU0I9T0AjbEXJJlzQscAxo2vijAWROMKjn2SfQlA5qfPq1gq1UuGklHkp445Sg8kQjChpWWR5y4fpoUGQTbQSluLTKiOEnNKiNh0k4MyTxCuu6slStsRLe4fpoUKPkjcQxZjj09iCJW7Ieusq7YXUcjXgq1cFGAnRJnNUOit4bLeOIuOkfOciqOktOAHHdWqYv5aCwdEOE6CK1XMtxueQaceQw4duRzDS50ffzn(f1jGksHQDBbvzdv2GQg8kQjzsJnBH6IwourkuTbuTlfOYsOYdoEoRbVIAc3Xdm8AogEXJJlOABGk7cvzdv2GQmHkp445mDpcxqj3bGm8Ihhxsck5uoA8OZrxiTyN0LwSTLwljWlECCjtvsq7YXUcjrdEf1KmPXMTqDrlhQifQ2aQ2Lcuzju5bhpN1GxrnH74bgEnhdV4XXfuTnqLDHQSHkBqvMqLhC8CMUhHlOK7aqgEXJJljrq9AojHUhHBeExKGsxAXUTKwljWlECCjtvsq7YXUcjrq9Ap0Gh(vOaQScQYqseuVMtsSWWbimlqu6sl2TtATKaV4XXLmvjbTlh7kKeb1R9qdE4xHcOYkOkdjrq9AojXcdhGjULzH0GCPlTyxgsRLeb1R5Ken(nTa5OqysxNJTKaV4XXLmvPlTyNDLwljcQxZjj09iCbLChakjWlECCjtv6sl2TDP1sc8IhhxYuLeb1R5KeZJxo2HJscAxo2vij2aQw4duRzDS50ffzcpOKavKcvPavabcvzcvlmCagsUkhGZAWd1tNJSo2C6IIqfqGq1cFGAnRJnNUOiRXVOoburkuTBlOkBOYgu1GxrnjtASzlux0YHkRGQnGQmsbQSeQ8GJNZAWROMWD8adVMJHx844cQ2gOYUqv2qLnOktOYdoEot3JWfuYDaidV4XXLKGsoLJgp6C0fsl2jDPf7srATKaV4XXLmvjbTlh7kKen4vutYKgB2c1fTCOYkOAdOkJuGklHkp445Sg8kQjChpWWR5y4fpoUGQTbQSluLTKiOEnNKyE8YXoCu6sl2T)sRLeb1R5Ke58Gwb3eR9IJIsc8IhhxYuLU0ID7BP1sc8IhhxYuLeb1R5Ke6EeUr4DrckjOD5yxHKydOAHpqTM1XMtxuKj8GscurkuLcubeiuLjuTWWbyi5QCaoRbpupDoY6yZPlkcvabcvl8bQ1So2C6IISg)I6eqfPq1UTGQSHkBqvMqLhC8CMUhHlOK7aqgEXJJljbLCkhnE05OlKwSt6sl2zNKwljcQxZjj09iCJW7IeusGx844sMQ0LwSBBlTwseuVMtsay6ZmAt66CSLe4fpoUKPkDPfzSL0Ajrq9Aojr004qJpDJNljWlECCjtv6sxsqNHVM0NqAT0IDsRLe4fpoUKPkjOD5yxHKqx5aCtJFrDcOYkOA32Leb1R5KecabLeoACaOb8spTdGCPlTidP1sc8IhhxYuLe0UCSRqseuV2dn4HFfkGkRGQmGkGaHQ3iesIG61CsI4nF1fEnNHxFpPlTWUsRLe4fpoUKPkjOD5yxHKiOEThAWd)kuavwbvzavabcvVriKeb1R5KeI0r)vxU5ReU0LwSDP1sIG61CsIokbAwySKe4fpoUKPkDPfPiTwsGx844sMQKG2LJDfsIhOwZskopAZOn6EeodmbQSbvpqTMHFjtASnn4HM0yKmhdmrseuVMtsehffEhCdn4CPlTy)LwljWlECCjtvsq7YXUcjXduRzjfNhTz0gDpcN14xuNaQi9hQStqLnO6bQ1m8lzsJTPbp0KgJK5yGjsIG61CscD14JpZs6sl23sRLe4fpoUKPkjOD5yxHK4bQ1SKIZJ2mAJUhHZatGkBq1gq1duRzjfNhTz0gDpcN14xuNaQifQsbQSbvEWXZz0HVmaWODgEXJJlOciqOktOYdoEoJo8LbagTZWlECCbv2GQhOwZskopAZOn6EeoRXVOoburkuzxOkBOYgufuV2dn4HFfkGQFOAhubeiu9a1AMarhqD5MoYrgycuzdQcQx7Hg8WVcfq1puTtseuVMts8ICZOnExusesxAHDsATKaV4XXLmvjbTlh7kKeEWXZzZJxo2HxZXWlECCbv2GQnGk6m81K(yjfNhTz0gDpcN1ySihQSbvn4HmV(qJpMuGkRGQC6cQSbvn4vutYKgB2c1fTCOYQFOA3wqfqGq1duRzjfNhTz0gDpcNbMav2GQg8qMxFOXhtkqLvqvoDbvzdvabcv6khGBA8lQtavKcvzSLKiOEnNKa)sM0yBAWdnPXizoPlTyBlTwsGx844sMQKG2LJDfsInGQhOwZEngoaZOnI6wDKpIGbMavabcv6khGBA8lQtavKcvzSfuLnuzdQ8GJNZEngoaZOnI6wDKpIGHx844cQSbvn4vutYKgB2c1fTCOYkOYUBbv2GQg8qMxFOXhtkqLvqvoDjjcQxZjjWVKjn2Mg8qtAmsMt6sl2TL0AjbEXJJlzQscAxo2vij8GJNZkksJegEXJJlOYgu1GhcvKcv2vseuVMtsGFjtASnn4HM0yKmN0LwSBN0AjbEXJJlzQscAxo2vij8GJNZEngoaZOnI6wDKpIGHx844cQSbv0z4Rj9XEngoaZOnI6wDKpIG14xuNaQaceQ8GJNZkksJegEXJJlOYguLju9a1AwsX5rBgTr3JWzGjsIG61CsIKIZJ2mAJUhHlDPf7YqATKaV4XXLmvjbTlh7kKeEWXZzZJxo2HxZXWlECCbv2GQnGkp445S8WbGDD5gHp9hdV4XXfuzdQEGAnRXVPfihfct66CSzGjqLnOIodFnPpwhLanlmwSgJf5qfqGqfDg(AsFSokbAwySyn(f1jGkGaHQmHkp445S8WbGDD5gHp9hdV4XXfuLTKiOEnNKiP48OnJ2O7r4sxAXo7kTwsGx844sMQKG2LJDfsc6m81K(yjfNhTz0gDpcN1ySihQSbvn4vutYKgB2c1fTCOIuOA)3sseuVMts8AmCaMrBe1T6iFeHKauGMrRn50L0IDsxAXUTlTwsGx844sMQKG2LJDfsIhOwZskopAZOn6EeoRXVOoburkuLtxqLnO6bQ1SKIZJ2mAJUhHZatGkBqvMqLhC8C284LJD41Cm8IhhxsIG61CscDpcpn59NWObBYLU0IDPiTwsGx844sMQKG2LJDfsIG61EObp8Rqbuz1puLbuzdQOZWxt6JLuCE0MrB09iCwJFrDcOYsOAxkqLvqLUYb4Mg)I6eqfqGqLUYb4Mg)I6eqfPqvoDjjcQxZjj09i80K3FcJgSjx6sl2T)sRLe4fpoUKPkjOD5yxHKWdoEoBE8YXo8AogEXJJlOYguLju9a1AwsX5rBgTr3JWzGjqLnOAdOAdOAHHdWqYv5aCwdEOE6CKPdohpdTbfXcBOYgu9a1Ag4by4KBeEJxUdGbMavzdvabcvBavlmCagsUkhGZAWd1tNJSo2C6IIqLnOAHpqTM1XMtxuKj8Gscu9dvPavzdvabcvBavzcvlmCagsUkhGZAWd1tNJSo2C6IIqLnOktOAHHdWqYv5aCwdEOE6CKPdohpdTbfXcBOkBOkBjrq9AojHUhHNM8(ty0Gn5sxAXU9T0AjbEXJJlzQscAxo2vij8GJNZEngoaZOnI6wDKpIGHx844cQSbvn4vutYKgB2c1fTCOYkOA7Bbv2GQg8qOYQFOYUqLnOIodFnPpwsX5rBgTr3JWzGjqfqGqvMqLhC8C2RXWbygTru3QJ8rem8IhhxqLnOQbVIAsM0yZwOUOLdvw9dvzKIKiOEnNKaa5jJda7VIAsAuGhfLU0ID2jP1sc8IhhxYuLe0UCSRqs8a1AwsX5rBgTr3JWzGjsIG61CsIokbAwySKU0IDBBP1sc8IhhxYuLe0UCSRqseuV2dn4HFfkGkR(HQmGkBq1gqvc6SCadiN14xuNaQifQYaQ2gOkNUGkGaHkDLdWnn(f1jGksHQmGQTbQYPlOkBjrq9AojHiODPlAfCtsqDPlDjXc1bi3LwlTyN0Ajrq9AojXxDlJUrCtusGx844sMQ0LwKH0AjbEXJJlzQscAxo2vijYeQwJZ09iCJg3dBMxusQlhQSbvBavEWXZzffPrcdV4XXfubeiurNHVM0h71y4amJ2iQB1r(icwJFrDcOYkOAxkqfqGqLhC8C284LJD41Cm8IhhxqLnOIodFnPpwsX5rBgTr3JWzn(f1jGksHQ14mDpc3OX9WM14xuNaQYwseuVMtsaysZRl384HWLU0c7kTwsGx844sMQKG2LJDfsIhOwZkk5gp4Zjyn(f1jGks)HQC6cQSbvpqTMvuYnEWNtWatGkBqLib5CJhDo6cwopOvWnXAV4Oiuz1puLbuzdQ2aQYeQ8GJNZEngoaZOnI6wDKpIGHx844cQaceQOZWxt6J9AmCaMrBe1T6iFebRXVOobuzfuTlfOkBjrq9AojropOvWnXAV4OO0LwSDP1sc8IhhxYuLe0UCSRqs8a1Awrj34bFobRXVOobur6puLtxqLnO6bQ1SIsUXd(CcgycuzdQ2aQYeQ8GJNZEngoaZOnI6wDKpIGHx844cQaceQOZWxt6J9AmCaMrBe1T6iFebRXVOobuzfuTlfOkBjrq9AojHUhHBeExKGsxArksRLe4fpoUKPkjcQxZjjObNBcQxZz4LWLe8s4Ml(qjbke4rrH0LwS)sRLe4fpoUKPkjcQxZjjObNBcQxZz4LWLe8s4Ml(qjbDg(AsFcPlTyFlTwsGx844sMQKG2LJDfscp445m6Wxgay0odV4XXfuzdQ2aQEGAnJo8LbagTZeEqjbQS6hQ2TfuzdQ2aQw4duRzDS50ffzcpOKav)qvkqfqGqvMq1cdhGHKRYb4Sg8q905iRJnNUOiuLnubeiuPRCaUPXVOobur6puLtxqv2sIG61CscAW5MG61CgEjCjbVeU5Ipusqh(YaaJ2LU0c7K0AjbEXJJlzQscAxo2vijEGAn71y4amJ2iQB1r(icgyIKiOEnNKObptq9AodVeUKGxc3CXhkjEJW4fLK6YLU0ITT0AjbEXJJlzQscAxo2vij8GJNZEngoaZOnI6wDKpIGHx844cQSbvBavBav0z4Rj9XEngoaZOnI6wDKpIG14xuNaQ(HQTGkBqfDg(AsFSKIZJ2mAJUhHZA8lQtavKcv72cQYgQaceQ2aQOZWxt6J9AmCaMrBe1T6iFebRXVOoburkuLXwqLnOYRp04Jzviurkuz3uGQSHQSLeb1R5Ken4zcQxZz4LWLe8s4Ml(qjXBeMKz41LlDPf72sATKaV4XXLmvjbTlh7kKepqTMLuCE0MrB09iCgycuzdQ8GJNZMhVCSdVMJHx844sseuVMts0GNjOEnNHxcxsWlHBU4dLeZJxo2HxZjDPf72jTwsGx844sMQKG2LJDfsIG61EObp8Rqbuz1puLHKiOEnNKObptq9AodVeUKGxc3CXhkjIbLU0IDziTwsGx844sMQKiOEnNKGgCUjOEnNHxcxsWlHBU4dLecpUv0lPlTyNDLwljWlECCjtvsq7YXUcjXduRzjfNhTz0gDpcNbMav2GQhOwZWVKjn2Mg8qtAmsMJbMijcQxZjjsgVMt6sl2TDP1sIG61CscqbAkh)esc8IhhxYuLU0IDPiTwsGx844sMQKG2LJDfsIhOwZskopAZOn6EeodmbQSbvpqTMHFjtASnn4HM0yKmhdmrseuVMts84ZSmAWMCPlTy3(lTwsGx844sMQKG2LJDfsIhOwZskopAZOn6EeodmrseuVMts8WwGnj1LlDPf723sRLe4fpoUKPkjOD5yxHKydOktO6bQ1SKIZJ2mAJUhHZatGkBqvq9Ap0Gh(vOaQS6hQYaQYgQaceQYeQEGAnlP48OnJ2O7r4mWeOYguTbu1GhYwOUOLdvw9dvPav2GQg8kQjzsJnBH6Iwouz1puT)BbvzljcQxZjjIMghAsa5cu6sl2zNKwljWlECCjtvsq7YXUcjXduRzjfNhTz0gDpcNbMijcQxZjj4voaxySZbUY)WZLU0IDBBP1sc8IhhxYuLe0UCSRqs8a1AwsX5rBgTr3JWzGjqLnO6bQ1m8lzsJTPbp0KgJK5yGjsIG61CsI4OOW7GBObNlDPfzSL0AjbEXJJlzQscAxo2vijEGAnlP48OnJ2O7r4Sg)I6eqfP)qLDcQSbvpqTMHFjtASnn4HM0yKmhdmrseuVMtsORgF8zwsxArg7KwljWlECCjtvsq7YXUcjXduRzjfNhTz0gDpcNbMav2GQnGQhOwZskopAZOn6EeoRXVOoburkuLcuzdQ8GJNZOdFzaGr7m8IhhxqfqGqvMqLhC8CgD4ldamANHx844cQSbvpqTMLuCE0MrB09iCwJFrDcOIuOYUqv2qLnOkOEThAWd)kuav)q1oOciqO6bQ1mbIoG6YnDKJmWeOYgufuV2dn4HFfkGQFOANKiOEnNK4f5MrB8UOKiKU0LecpUv0lP1sl2jTwseuVMts0430cKJcHjDDo2sc8IhhxYuLU0ImKwljWlECCjtvsq7YXUcjbDg(AsFSg)MwGCuimPRZXM14xuNaQi9hQYaQ2gOkNUGkBqLhC8CwE4aWUUCJWN(JHx844sseuVMtsO7r4gH3fjO0LwyxP1sc8IhhxYuLe0UCSRqs8a1AwxFidmrseuVMtsaysZRl384HWLU0ITlTwsGx844sMQKG2LJDfscp445SII0iHHx844cQSbvpqTMLuCE0MrB09iCgycuzdQInXUCKvuYn0YJfYzDCKavw9dvzijcQxZjjMhVCSdhLU0IuKwljWlECCjtvsq7YXUcjrMq1duRz6E2eptcixGmWeOYgu5bhpNP7zt8mjGCbYWlECCjjcQxZjjMhVCSdhLU0I9xATKaV4XXLmvjbTlh7kKen4vutYKgB2c1fTCOIuOAdOAxkqLLqLhC8CwdEf1eUJhy41Cm8Ihhxq12av2fQYwseuVMtsO7r4gH3fjO0LwSVLwljWlECCjtvsq7YXUcjXduRzKuCED5MVGcOoKbMav2GQg8qMxFOXhZ2HkR(HQC6sseuVMtsO7r4ck5oau6slStsRLe4fpoUKPkjOD5yxHKObVIAsM0yZwOUOLdvwbvBavzKcuzju5bhpN1GxrnH74bgEnhdV4XXfuTnqLDHQSLeb1R5KeZJxo2HJsxAX2wATKiOEnNKq3JWncVlsqjbEXJJlzQsxAXUTKwljcQxZjjam9zgTjDDo2sc8IhhxYuLU0ID7KwljcQxZjjIMghA8PB8CjbEXJJlzQsx6sxsSh2IAoPfzSvgBTBRDBxsKo6RUCHKy)(lzAhxq1UTGQG61CqfVeUGbjtsK0JU4OKyFGQ9tpchQ2wJHdaQ2xDvoahs2(av7lP(8WgQ2TD7HQm2kJTGKbjBFGk7qaXLJc78qY2hOYoaQ2VpkhCHq1(66wq1(PrCtKbjBFGk7aOABzTGkDW5VGscuPNgQaf1Ldv7x2zTZWEOAFXSFGQsdvj8GCSHQ6kVchfqvQdbu9q90iuLmdVUCOIp5ffQkburNVeo64IbjBFGk7aOYoeqC5iu5rNJoZRp04Jzviu5du51hA8XSkeQ8bQafiuHhDaphBOIJxUdaQ6WbGnu5aIdQsghpVcou5DiaavlmCacgKS9bQSdGk7WHVGQTvWODOkUfu1bTcou5PXGebdsgKS9bQ2VSZePGoUGQhQNgHk689chQEyEDcguTTqPyIlGQBo7aar)Pb5qvq9AobunhNCgKSG61CcwsJ057f(pOanLJF2FXh(hBkaeDim65CZOnjtASHKfuVMtWsAKoFVWT8pR9IUIhhT)Ip8FCayBMZakqdAhbRKeCz)Ebhe)3aTJGvscUy34txdOWKZJvf(0cZlw5iqGODeSssWfJoDdM44YKZJvf(0cZlw5iqGODeSssWfJoDdM44YKZJvf(0cZhUcoVMdiq0ocwjj4ITxfCZOnXvFHJlZJpZciq0ocwjj4IPRw4MVWrHrKqEopecGar7iyLKGlMDouyamP5ydeiAhbRKeCXUXNUgqHjNhRk8PfMpCfCEnhqGODeSssWflea2louy6yZPn0PdE2qYGKTpq1(LDMif0XfuH7Hn5qLxFiu5aqOkO(0qvjGQyVO4XJJmizb1R5e)F1Tm6gXnriz7duTTKKWjhQ2p9iCOA)G7Hnuf3cQ(I68OoOA)MsouzDWNtajlOEnNWY)SamP51LBE8q42x6)mxJZ09iCJg3dBMxusQl32gEWXZzffPrcdV4XXfqG0z4Rj9XEngoaZOnI6wDKpIG14xuNWQDPaeOhC8C284LJD41Cm8Ihhx2OZWxt6JLuCE0MrB09iCwJFrDcsxJZ09iCJg3dBwJFrDISHKfuVMty5Fw58Gwb3eR9IJI2x6)hOwZkk5gp4Zjyn(f1ji9pNUS9a1Awrj34bFobdmXMib5CJhDo6cwopOvWnXAV4OOv)zyBJm9GJNZEngoaZOnI6wDKpIGHx844ciq6m81K(yVgdhGz0grDRoYhrWA8lQty1UuYgswq9AoHL)zP7r4gH3fjO9L()bQ1SIsUXd(CcwJFrDcs)ZPlBpqTMvuYnEWNtWatSTrMEWXZzVgdhGz0grDRoYhrWWlECCbeiDg(AsFSxJHdWmAJOUvh5Jiyn(f1jSAxkzdjBFGQTfQxZbvBRwchQSddoxajlOEnNWY)SObNBcQxZz4LWT)Ip8hfc8OOaswq9AoHL)zrdo3euVMZWlHB)fF4pDg(AsFcizb1R5ew(Nfn4Ctq9AodVeU9x8H)0HVmaWOD7l9VhC8CgD4ldamANHx844Y2gpqTMrh(YaaJ2zcpOKy1)UTSTXcFGAnRJnNUOit4bLK)uacmZfgoadjxLdWzn4H6PZrwhBoDrXSbcux5aCtJFrDcs)ZPRSHKfuVMty5Fwn4zcQxZz4LWT)Ip8)ncJxusQl3(s))a1A2RXWbygTru3QJ8remWeizb1R5ew(NvdEMG61CgEjC7V4d)FJWKmdVUC7l9VhC8C2RXWbygTru3QJ8rem8Ihhx22yd6m81K(yVgdhGz0grDRoYhrWA8lQt8VLn6m81K(yjfNhTz0gDpcN14xuNG0DBLnqGBqNHVM0h71y4amJ2iQB1r(icwJFrDcsZylBE9HgFmRcj1UPKD2qYcQxZjS8pRg8mb1R5m8s42FXh(ppE5yhEnN9L()bQ1SKIZJ2mAJUhHZatS5bhpNnpE5yhEnhdV4XXfKSG61Ccl)ZQbptq9AodVeU9x8H)XG2x6)G61EObp8RqHv)zajlOEnNWY)SObNBcQxZz4LWT)Ip8x4XTIEbjlOEnNWY)SsgVMZ(s))a1AwsX5rBgTr3JWzGj2EGAnd)sM0yBAWdnPXizogycKS9bQcQxZjS8plqbAkh)S)Ip8xuNgKBY5XQcFAH5fRC0mAJg7Hwo52x6Fp445SxJHdWmAJOUvh5Jiy4fpoUS9a1A2RXWbygTru3QJ8remWeOcQGkOcswq9AoHL)zbkqt54Nas2(av2zdAfCOAB5vCVqbKSG61Ccl)Z6XNzz0Gn52x6)hOwZskopAZOn6EeodmX2duRz4xYKgBtdEOjngjZXatGKfuVMty5FwpSfytsD52x6)hOwZskopAZOn6Eeodmbswq9AoHL)zfnno0KaYfO9L(FJmFGAnlP48OnJ2O7r4mWeBb1R9qdE4xHcR(ZiBGaZ8bQ1SKIZJ2mAJUhHZatSTrdEiBH6IwUv)PyRbVIAsM0yZwOUOLB1)(Vv2qYcQxZjS8plELdWfg7CGR8p8C7l9)duRzjfNhTz0gDpcNbMajlOEnNWY)SIJIcVdUHgCU9L()bQ1SKIZJ2mAJUhHZatS9a1Ag(LmPX20GhAsJrYCmWeizb1R5ew(NLUA8XNzzFP)FGAnlP48OnJ2O7r4Sg)I6eK(BNS9a1Ag(LmPX20GhAsJrYCmWeizb1R5ew(N1lYnJ24DrjryFP)FGAnlP48OnJ2O7r4mWeBB8a1AwsX5rBgTr3JWzn(f1jinfBEWXZz0HVmaWODgEXJJlGaZ0doEoJo8LbagTZWlECCz7bQ1SKIZJ2mAJUhHZA8lQtqQDZ2wq9Ap0Gh(vO4FhqGpqTMjq0buxUPJCKbMylOEThAWd)ku8VdsgKS9bQ2wM9lOYo74HxZbjlOEnNGfd(3430cKJcHjDDo22x6Fp445S8WbGDD5gHp9hdV4XXfqGBeBID5it3ZM4zC8lbfoRJJeBIeKZnE05Olyn(nTa5OqysxNJTv)21wMpqTM11hYatYgswq9Aoblg0Y)SY5bTcUjw7fhfTV0)EWXZz6EeUGsUdaz4fpoUGKfuVMtWIbT8plDpc3i8UibTNsoLJgp6C0f)7SV0)BSWhOwZ6yZPlkYeEqjH0uacmZfgoadjxLdWzn4H6PZrwhBoDrrGax4duRzDS50ffzn(f1jiD3wzBJodFnPpwJFtlqokeM015yZA8lQtq6FgBtoDzZdoEolpCayxxUr4t)XWlECCzltp445mDpcxqj3bGm8IhhxqYcQxZjyXGw(NLUhHBeExKG2x6F6m81K(yn(nTa5OqysxNJnRXVOobP)zSn50Lnp445S8WbGDD5gHp9hdV4XXfKSG61CcwmOL)zbysZRl384HWTV0)pqTM11hYatGKfuVMtWIbT8plDpcxqj3bG2x6)hOwZiP486YnFbfqDidmbswq9Aoblg0Y)SY5bTcUjw7fhfTV0)n4vutYKgB2c1fTCs3yxkw6bhpN1GxrnH74bgEnhdV4XX12y3SHKfuVMtWIbT8plDpc3i8UibTNsoLJgp6C0f)7SV0)BSWhOwZ6yZPlkYeEqjH0uacmZfgoadjxLdWzn4H6PZrwhBoDrrGax4duRzDS50ffzn(f1jiD3wzBRbVIAsM0yZwOUOLt6g7sXsp445Sg8kQjChpWWR5y4fpoU2g7MTTm9GJNZ09iCbLChaYWlECCbjlOEnNGfdA5Fw6EeUr4DrcAFP)BWROMKjn2SfQlA5KUXUuS0doEoRbVIAc3Xdm8AogEXJJRTXUzBltp445mDpcxqj3bGm8IhhxqYcQxZjyXGw(N1cdhGWSar7l9Fq9Ap0Gh(vOWQmGKfuVMtWIbT8pRfgoatClZcPb52x6)G61EObp8RqHvzajlOEnNGfdA5Fwn(nTa5OqysxNJnKSG61CcwmOL)zP7r4ck5oaeswq9Aoblg0Y)SMhVCSdhTNsoLJgp6C0f)7SV0)BSWhOwZ6yZPlkYeEqjH0uacmZfgoadjxLdWzn4H6PZrwhBoDrrGax4duRzDS50ffzn(f1jiD3wzBRbVIAsM0yZwOUOLB1gzKILEWXZzn4vut4oEGHxZXWlECCTn2nBBz6bhpNP7r4ck5oaKHx844cswq9Aoblg0Y)SMhVCSdhTV0)n4vutYKgB2c1fTCR2iJuS0doEoRbVIAc3Xdm8AogEXJJRTXUzdjlOEnNGfdA5Fw58Gwb3eR9IJIqYcQxZjyXGw(NLUhHBeExKG2tjNYrJhDo6I)D2x6)nw4duRzDS50ffzcpOKqAkabM5cdhGHKRYb4Sg8q905iRJnNUOiqGl8bQ1So2C6IISg)I6eKUBRSTLPhC8CMUhHlOK7aqgEXJJlizb1R5eSyql)Zs3JWncVlsqizb1R5eSyql)ZcW0Nz0M015ydjlOEnNGfdA5FwrtJdn(0nEoKmiz7duLAJHdaQgnuru3QJ8reqvYm86YHQE8WR5Gk78qLWJ2fqvgBjGQhQNgHQ9ffNhnunAOA)0JWHklHQuhcOkAeQI9IIhpocjlOEnNG9gHjzgED5)aM086YnpEiC7l9)duRzD9HmWeizb1R5eS3imjZWRl3Y)SA8BAbYrHWKUohB7l9VhC8CwE4aWUUCJWN(JHx844YwdEOv)PajlOEnNG9gHjzgED5w(N184LJD4O9uYPC04rNJU4FN9L(FJf(a1AwhBoDrrMWdkjKMcqGzUWWbyi5QCaoRbpupDoY6yZPlkce4cFGAnRJnNUOiRXVOobP72kBBn4vutYKgB2c1fTCR(ZifBz6bhpNP7r4ck5oaKHx844cswq9Aob7nctYm86YT8pR5Xlh7Wr7l9FdEf1KmPXMTqDrl3Q)msbswq9Aob7nctYm86YT8pRCEqRGBI1EXrr7l9FdEf1KmPXMTqDrlN0m2YMib5CJhDo6cwopOvWnXAV4OOv)zyJodFnPpwsX5rBgTr3JWzn(f1jSkfizb1R5eS3imjZWRl3Y)S09iCJW7Ie0Ek5uoA8OZrx8VZ(s)VXcFGAnRJnNUOit4bLestbiWmxy4amKCvoaN1GhQNohzDS50ffbcCHpqTM1XMtxuK14xuNG0DBLTTg8kQjzsJnBH6IwoPzSLTm9GJNZ09iCbLChaYWlECCzJodFnPpwsX5rBgTr3JWzn(f1jSkfizb1R5eS3imjZWRl3Y)S09iCJW7Ie0(s)3GxrnjtASzlux0YjnJTSrNHVM0hlP48OnJ2O7r4Sg)I6ewLcKSG61Cc2BeMKz41LB5Fw6EeUGsUdaTV0)pqTMrsX51LB(ckG6qgyITg8kQjzsJnBH6IwUvBSlfl9GJNZAWROMWD8adVMJHx844ABSB22ejiNB8OZrxW09iCbLChaA1FgqYcQxZjyVrysMHxxUL)zP7r4ck5oa0(s)3GxrnjtASzlux0YT6Fd7MILEWXZzn4vut4oEGHxZXWlECCTn2nBBIeKZnE05Oly6EeUGsUdaT6pdizb1R5eS3imjZWRl3Y)SMhVCSdhTNsoLJgp6C0f)7SV0)BSWhOwZ6yZPlkYeEqjH0uacmZfgoadjxLdWzn4H6PZrwhBoDrrGax4duRzDS50ffzn(f1jiD3wzBRbVIAsM0yZwOUOLB1)g2nfl9GJNZAWROMWD8adVMJHx844ABSB22Y0doEot3JWfuYDaidV4XXfKSG61Cc2BeMKz41LB5FwZJxo2HJ2x6)g8kQjzsJnBH6IwUv)By3uS0doEoRbVIAc3Xdm8AogEXJJRTXUzdjlOEnNG9gHjzgED5w(NvopOvWnXAV4OO9L(NodFnPpwsX5rBgTr3JWzn(f1jSQbpK51hA8XSDBn4vutYKgB2c1fTCs3(w2ejiNB8OZrxWY5bTcUjw7fhfT6pdizb1R5eS3imjZWRl3Y)S09iCJW7Ie0Ek5uoA8OZrx8VZ(s)VXcFGAnRJnNUOit4bLestbiWmxy4amKCvoaN1GhQNohzDS50ffbcCHpqTM1XMtxuK14xuNG0DBLTn6m81K(yjfNhTz0gDpcN14xuNWQg8qMxFOXhZ2T1GxrnjtASzlux0YjD7Bzltp445mDpcxqj3bGm8IhhxqYcQxZjyVrysMHxxUL)zP7r4gH3fjO9L(NodFnPpwsX5rBgTr3JWzn(f1jSQbpK51hA8XSDBn4vutYKgB2c1fTCs3(wqYGKfuVMtWEJW4fLK6YT8pR5Xlh7Wr7PKt5OXJohDX)o7l9)gl8bQ1So2C6IImHhusinfGaZCHHdWqYv5aCwdEOE6CK1XMtxueiWf(a1AwhBoDrrwJFrDcs3Tv22AWROMKjn2K(V9TSLPhC8CMUhHlOK7aqgEXJJlizb1R5eS3imErjPUCl)ZAE8YXoC0(s)3GxrnjtASj9F7BbjlOEnNG9gHXlkj1LB5Fwn(nTa5OqysxNJT9L(3doEolpCayxxUr4t)XWlECCbjlOEnNG9gHXlkj1LB5FwaM086YnpEiC7l9)duRzD9HmWeizb1R5eS3imErjPUCl)ZAE8YXoC0Ek5uoA8OZrx8VZ(s)VXcFGAnRJnNUOit4bLestbiWmxy4amKCvoaN1GhQNohzDS50ffbcCHpqTM1XMtxuK14xuNG0DBLTTg8qMxFOXhtkKMtxab2GxrnjtASj9F7Pyltp445mDpcxqj3bGm8IhhxqYcQxZjyVry8IssD5w(N184LJD4O9L(VbpK51hA8XKcP50fqGn4vutYKgBs)3EkqYcQxZjyVry8IssD5w(NLUhHlOK7aq7l9)duRzKuCED5MVGcOoKbMytKGCUXJohDbt3JWfuYDaOv)zajlOEnNG9gHXlkj1LB5FwaM(mJ2KUohB7l9FdEf1KmPXMTqDrl3QF7MHTg8qMxFOXhJDTkNUGKfuVMtWEJW4fLK6YT8pRg)MwGCuimPRZXgswq9Aob7ncJxusQl3Y)S09iCbLChaAFP)fjiNB8OZrxW09iCbLChaA1FgqYcQxZjyVry8IssD5w(N184LJD4O9uYPC04rNJU4FN9L(FJf(a1AwhBoDrrMWdkjKMcqGzUWWbyi5QCaoRbpupDoY6yZPlkce4cFGAnRJnNUOiRXVOobP72kBBn4vutYKgB2c1fTCRYifGaBWdTYU2Y0doEot3JWfuYDaidV4XXfKSG61Cc2BegVOKuxUL)znpE5yhoAFP)BWROMKjn2SfQlA5wLrkab2GhALDHKfuVMtWEJW4fLK6YT8pROPXHgF6gp3(s)3GxrnjtASzlux0YTkLTGKbjBFGk7WHVGkay0ourNBvEnNaswq9AobJo8LbagT)tbe1jmJ2uu0(s)RRCaUPXVOobP50fqGpqTMLuCE0MrB09iCwJFrDcsTRThOwZOdFzaGr7mHhus(ZylBz6bhpNnpE5yhEnhdV4XXfKSG61CcgD4ldamA3Y)SOaI6eMrBkkAFP)9GJNZMhVCSdVMJHx844YwMpqTMLuCE0MrB09iCgyITnEGAnJo8LbagTZeEqjXQ)D7VThOwZapadNCJWB8YDamWeGaFGAnJo8LbagTZeEqjXQ)DB7SHKbjlOEnNGrNHVM0NWY)SeackjC04aqd4LEAha52x6FDLdWnn(f1jSA32HKfuVMtWOZWxt6ty5FwXB(Ql8AodV(E2x6)G61EObp8RqHvzae4Becizb1R5em6m81K(ew(NLiD0F1LB(kHBFP)dQx7Hg8WVcfwLbqGVriGKfuVMtWOZWxt6ty5FwDuc0SWybjlOEnNGrNHVM0NWY)SIJIcVdUHgCU9L()bQ1SKIZJ2mAJUhHZatS9a1Ag(LmPX20GhAsJrYCmWeizb1R5em6m81K(ew(NLUA8XNzzFP)FGAnlP48OnJ2O7r4Sg)I6eK(BNS9a1Ag(LmPX20GhAsJrYCmWeizb1R5em6m81K(ew(N1lYnJ24DrjryFP)FGAnlP48OnJ2O7r4mWeBB8a1AwsX5rBgTr3JWzn(f1jinfBEWXZz0HVmaWODgEXJJlGaZ0doEoJo8LbagTZWlECCz7bQ1SKIZJ2mAJUhHZA8lQtqQDZ2wq9Ap0Gh(vO4FhqGpqTMjq0buxUPJCKbMylOEThAWd)ku8VdsgKS9bQ2p9iCOIodFnPpbKSG61CcgDg(AsFIF8lzsJTPbp0KgJK5SV0)EWXZzZJxo2HxZXWlECCzBd6m81K(yjfNhTz0gDpcN1ySi3wdEiZRp04JjfRYPlBn4vutYKgB2c1fTCR(3TfqGpqTMLuCE0MrB09iCgyITg8qMxFOXhtkwLtxzdeOUYb4Mg)I6eKMXwqYcQxZjy0z4Rj9jS8pl8lzsJTPbp0KgJK5SV0)B8a1A2RXWbygTru3QJ8remWeGa1voa304xuNG0m2kBBEWXZzVgdhGz0grDRoYhrWWlECCzRbVIAsM0yZwOUOLBLD3YwdEiZRp04JjfRYPlizb1R5em6m81K(ew(Nf(LmPX20GhAsJrYC2x6Fp445SII0iHHx844YwdEiP2fswq9AobJodFnPpHL)zLuCE0MrB09iC7l9VhC8C2RXWbygTru3QJ8rem8Ihhx2OZWxt6J9AmCaMrBe1T6iFebRXVOobqGEWXZzffPrcdV4XXLTmFGAnlP48OnJ2O7r4mWeizb1R5em6m81K(ew(NvsX5rBgTr3JWTV0)EWXZzZJxo2HxZXWlECCzBdp445S8WbGDD5gHp9hdV4XXLThOwZA8BAbYrHWKUohBgyIn6m81K(yDuc0SWyXAmwKdeiDg(AsFSokbAwySyn(f1jacmtp445S8WbGDD5gHp9hdV4XXv2qYcQxZjy0z4Rj9jS8pRxJHdWmAJOUvh5JiShuGMrRn501)o7l9pDg(AsFSKIZJ2mAJUhHZAmwKBRbVIAsM0yZwOUOLt6(VfKSG61CcgDg(AsFcl)Zs3JWttE)jmAWMC7l9)duRzjfNhTz0gDpcN14xuNG0C6Y2duRzjfNhTz0gDpcNbMyltp445S5Xlh7WR5y4fpoUGKfuVMtWOZWxt6ty5Fw6EeEAY7pHrd2KBFP)dQx7Hg8WVcfw9NHn6m81K(yjfNhTz0gDpcN14xuNWYDPyLUYb4Mg)I6eabQRCaUPXVOobP50fKSG61CcgDg(AsFcl)Zs3JWttE)jmAWMC7l9VhC8C284LJD41Cm8Ihhx2Y8bQ1SKIZJ2mAJUhHZatSTXglmCagsUkhGZAWd1tNJmDW54zOnOiwyB7bQ1mWdWWj3i8gVChadmjBGa3yHHdWqYv5aCwdEOE6CK1XMtxu02cFGAnRJnNUOit4bLK)uYgiWnYCHHdWqYv5aCwdEOE6CK1XMtxu0wMlmCagsUkhGZAWd1tNJmDW54zOnOiwyND2qYcQxZjy0z4Rj9jS8plaKNmoaS)kQjPrbEu0(s)7bhpN9AmCaMrBe1T6iFebdV4XXLTg8kQjzsJnBH6IwUvBFlBn4Hw9BxB0z4Rj9XskopAZOn6EeodmbiWm9GJNZEngoaZOnI6wDKpIGHx844YwdEf1KmPXMTqDrl3Q)msbswq9AobJodFnPpHL)z1rjqZcJL9L()bQ1SKIZJ2mAJUhHZatGKfuVMtWOZWxt6ty5FwIG2LUOvWnjb1TV0)b1R9qdE4xHcR(ZW2gjOZYbmGCwJFrDcsZyBYPlGa1voa304xuNG0m2MC6kBizqYcQxZjyOqGhff)p(mlZOnoa0Gh(rU9L()bQ1SKIZJ2mAJUhHZatSTXduRzjfNhTz0gDpcN14xuNG0DBzBJhOwZEngoaZOnI6wDKpIGbMaeOhC8C284LJD41Cm8Ihhxab6bhpNvuKgjm8Ihhx2Ym2e7Yrwrj3qlpwiNHx844kBGaFGAnROKBOLhlKZatS5bhpNvuKgjm8IhhxzdjlOEnNGHcbEuuy5Fw5GrVQ4mJ2eBI94aSV0)z6bhpNvuKgjm8Ihhxab6bhpNvuKgjm8Ihhx2InXUCKvuYn0YJfYz4fpoUS9a1AwsX5rBgTr3JWzn(f1jiD)T9a1AwsX5rBgTr3JWzGjab6bhpNvuKgjm8Ihhx2Ym2e7Yrwrj3qlpwiNHx844cswq9Aobdfc8OOWY)SOako3i8gdsSV0)pqTMLuCE0MrB09iCwJFrDcstX2duRzjfNhTz0gDpcNbMaeOxFOXhZQqstbswq9Aobdfc8OOWY)SCaOb8Ed4Tm6PPO9L()bQ1SgPKWrHWONMImWeGaFGAnRrkjCuim6PPOHoGNJnt4bLes3Tdswq9Aobdfc8OOWY)S0dfuGltSj2LJMhgF2x6)mFGAnlP48OnJ2O7r4mWeBz(a1A2RXWbygTru3QJ8remWeizb1R5emuiWJIcl)ZIohfpVdhxgnp(q7l9FMpqTMLuCE0MrB09iCgyITmFGAn71y4amJ2iQB1r(icgyIT14m6Cu88oCCz084dnpW(yn(f1j(3cswq9Aobdfc8OOWY)SspnFThwNPrXCXrr7l9)duRzjfNhTz0gDpcNbMae4duRz4xYKgBtdEOjngjZXatacKodFnPp2RXWbygTru3QJ8reSg)I6ewT)Bz5UuacKoDdM41CcwDOwhpoA8g0bWWlECCbjlOEnNGHcbEuuy5FwDLKWrtDgrsqr7l9FMpqTMLuCE0MrB09iCgyITmFGAn71y4amJ2iQB1r(icgycKSG61Ccgke4rrHL)z9HFttUz0goiTwMvJXNW(s))a1Ag(LmPX20GhAsJrYCSg)I6eKMIThOwZEngoaZOnI6wDKpIGbMae4gn4HmV(qJpMmSkNUS1GxrnjtASjnLTYgswq9Aobdfc8OOWY)SAmsQl3O5XhkSV0)z(a1AwsX5rBgTr3JWzGj2Y8bQ1SxJHdWmAJOUvh5JiyGj22WJohDgam4oatc1T63oTfqGE05OZaGb3bysOoP)zSfqG6khGBA8lQtq62tjBizqY2hOAF5Jxo2HxZbv94HxZbjlOEnNGnpE5yhEn3FJFtlqokeM015yBFP)9GJNZYdha21LBe(0Fm8IhhxqYcQxZjyZJxo2HxZz5FwZJxo2HJ2tjNYrJhDo6I)D2x6)nw4duRzDS50ffzcpOKqAkabUWhOwZ6yZPlkYA8lQtq6UTY2wMEWXZz6EeUGsUdaz4fpoUSL5duRzD9HmWeBIeKZnE05OlyaM086YnpEiCR(TlKSG61Cc284LJD41Cw(N184LJD4O9L(ptp445mDpcxqj3bGm8Ihhx2Y8bQ1SU(qgyInrcY5gp6C0fmatAED5MhpeUv)2fswq9AobBE8YXo8Aol)Zs3JWfuYDaO9L(FJhOwZiP486YnFbfqDiRXG6abUXduRzKuCED5MVGcOoKbMyBJKg3ZKtxSDmDpc3i8UibbcmPX9m50fBhdWKMxxU5XdHdeysJ7zYPl2owopOvWnXAV4Oy2zNTnrcY5gp6C0fmDpcxqj3bGw9NbKSG61Cc284LJD41Cw(N184LJD4O9uYPC04rNJU4FN9L(FJf(a1AwhBoDrrMWdkjKMcqGl8bQ1So2C6IISg)I6eKUBRST9a1AgjfNxxU5lOaQdznguhiWnEGAnJKIZRl38fua1HmWeBBK04EMC6ITJP7r4gH3fjiqGjnUNjNUy7yaM086YnpEiCGatACptoDX2XY5bTcUjw7fhfZoBizb1R5eS5Xlh7WR5S8pR5Xlh7Wr7l9)duRzKuCED5MVGcOoK1yqDGa34bQ1mskoVUCZxqbuhYatSTrsJ7zYPl2oMUhHBeExKGabM04EMC6ITJbysZRl384HWbcmPX9m50fBhlNh0k4MyTxCum7SHKfuVMtWMhVCSdVMZY)Swy4aeMfiAFP)dQx7Hg8WVcfwLbKSG61Cc284LJD41Cw(N1cdhGjULzH0GC7l9Fq9Ap0Gh(vOWQmGKfuVMtWMhVCSdVMZY)SY5bTcUjw7fhfTV0)BK5duRzD9HmWeGaBWROMKjn2SfQlA5KUBlGaBWdzE9HgFmzyvoDLTnrcY5gp6C0fSCEqRGBI1EXrrR(Zaswq9AobBE8YXo8Aol)ZcWKMxxU5XdHBFP)FGAnRRpKbMytKGCUXJohDbdWKMxxU5XdHB1FgqYcQxZjyZJxo2HxZz5Fw6EeUr4DrcApLCkhnE05Ol(3zFP)3yHpqTM1XMtxuKj8GscPPae4cFGAnRJnNUOiRXVOobP72kBBz(a1AwxFidmbiWg8kQjzsJnBH6IwoP72ciWg8qMxFOXhtgwLtx2Y0doEot3JWfuYDaidV4XXfKSG61Cc284LJD41Cw(NLUhHBeExKG2x6)mFGAnRRpKbMaeydEf1KmPXMTqDrlN0DBbeydEiZRp04JjdRYPlizb1R5eS5Xlh7WR5S8platAED5MhpeU9L()bQ1SU(qgycKSG61Cc284LJD41Cw(N184LJD4O9uYPC04rNJU4FN9L(FJf(a1AwhBoDrrMWdkjKMcqGl8bQ1So2C6IISg)I6eKUBRSTLPhC8CMUhHlOK7aqgEXJJlizb1R5eS5Xlh7WR5S8pR5Xlh7WrizqY2hOIWJBf9cQe1LZr7ap6C0HQE8WR5GKfuVMtWeECROx)n(nTa5OqysxNJnKSG61CcMWJBf9YY)S09iCJW7Ie0(s)tNHVM0hRXVPfihfct66CSzn(f1ji9pJTjNUS5bhpNLhoaSRl3i8P)y4fpoUGKfuVMtWeECROxw(NfGjnVUCZJhc3(s))a1AwxFidmbswq9Aobt4XTIEz5FwZJxo2HJ2x6Fp445SII0iHHx844Y2duRzjfNhTz0gDpcNbMyl2e7Yrwrj3qlpwiN1XrIv)zajlOEnNGj84wrVS8pR5Xlh7Wr7l9FMpqTMP7zt8mjGCbYatS5bhpNP7zt8mjGCbYWlECCbjlOEnNGj84wrVS8plDpc3i8UibTV0)n4vutYKgB2c1fTCs3yxkw6bhpN1GxrnH74bgEnhdV4XX12y3SHKfuVMtWeECROxw(NLUhHlOK7aq7l9)duRzKuCED5MVGcOoKbMyRbpK51hA8XSDR(ZPlizb1R5emHh3k6LL)znpE5yhoAFP)BWROMKjn2SfQlA5wTrgPyPhC8CwdEf1eUJhy41Cm8IhhxBJDZgswq9Aobt4XTIEz5Fw6EeUr4DrccjlOEnNGj84wrVS8platFMrBsxNJnKSG61CcMWJBf9YY)SIMghA8PB8CjHibPslYiLDsx6sj]] )

end
