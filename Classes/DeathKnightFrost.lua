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

            cycle = function ()
                if death_knight.runeforge.razorice then return "razorice" end
            end,

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


    spec:RegisterPack( "Frost DK", 20201124, [[d4uM8bqirPEesP0LqkvI2evvFcqnksvDksvwfqIELOWSOk6wiLkHDHQFPanmGuhtbTmsLEgvbtdiPRbqTnfG(gvHyCiLQohvHQ1PaAEaI7bu7dPYbPkKwOOKhcizIajGlIukAJajOpIukmsKsLKtQaWkbWlbsGMjaPDIu8tGeAOiLkvlvbqpfjtfPQRIuQK6RiLkglsj7LK)sLbJ4WclgupMWKv0LH2SiFwHgniDAjRgPuP8ArrZgLBdIDl1VvA4IQJtvOSCvEortNY1jLTdeFNQY4biopPI1di18PkTFvTAOIEf1mmurJUGwxqpCOUGkxxpa4HaguvuMo5OIkpezgJOIQdiOIcu4Ts7jGcakOIkp0HTXurVIsUANavuqnlxoWbhCSmOAWCXczqzbrJfwTT4IKnOSGigurbRvmBa0kyf1mmurJUGwxqpCOUGkxxpa4HdbSIk0mO7POOkiaLIcAnNyRGvutukuu02Nakagg0NakyxJqTNak8wP9aqBFcnliiey8EIUGQNprxqRlOFaEaOTpHcAmxFSONYNOVhNdAUU6POyL0Kk6vuOuITaLk6v0murVIc7aMHtvwkkXvgEvOOG1sjEEXyX52KlDR04A5pX)t0)jWAPepVyS4CBYLUvA8dHevlFcqEYqq)e)pr)NaRLsC4dddQBtoz1ZlgxzW1YFIxVpXcg2gFHzLHxy12CSdygoFIxVpXcg2gVeOiY5yhWmC(e)pj7NeanELH8sOJtuwmrgh7aMHZNO3t869jWAPeVe64eLftKX1YFI)NybdBJxcue5CSdygoFIEkQqy12kky2Ut3MCgu0HncrhLPOrxf9kkSdygovzPOexz4vHIk7NybdBJxcue5CSdygoFIxVpXcg2gVeOiY5yhWmC(e)pjaA8kd5LqhNOSyImo2bmdNpX)tG1sjEEXyX52KlDR04hcjQw(eG8Kb8j(FcSwkXZlglo3MCPBLgxl)jE9(elyyB8sGIiNJDaZW5t8)KSFsa04vgYlHoorzXezCSdygovuHWQTvuJAXnRODBYfanERbvzkA8GIEff2bmdNQSuuIRm8QqrbRLs88IXIZTjx6wPXpesuT8ja5ja(j(FcSwkXZlglo3MCPBLgxl)jE9(eRGGoBDZcFcqEcGvuHWQTvucOfJ5K2HrMktrdOQOxrHDaZWPklfL4kdVkuuWAPe)qrMmukDP9eixl)jE9(eyTuIFOitgkLU0Ec0jwT2WJlTqK5taYtgourfcR2wrzqrNwdVA90L2tGktrdGv0ROWoGz4uLLIsCLHxfkQSFcSwkXZlglo3MCPBLgxl)j(Fs2pbwlL4Whggu3MCYQNxmUYGRLROcHvBROsRqtItxa04vg6GXaIYu0mGk6vuyhWmCQYsrjUYWRcfv2pbwlL45fJfNBtU0TsJRL)e)pj7NaRLsC4dddQBtoz1ZlgxzW1YFI)NmxJl2wGTDHHtxIfqqhS218dHevlFc4NaAfviSABfLyBb22fgoDjwabvMIgpIIEff2bmdNQSuuIRm8QqrL9tG1sjEEXyX52KlDR04A5pX)tY(jWAPeh(WWG62Ktw98IXvgCTCfviSABfvU2vjDQE0bZcPPmfn0Ef9kkSdygovzPOexz4vHIcwlL45fJfNBtU0TsJRL)eVEFcSwkXri5Rp8CNwJoFyKVnxl)jE9(eXUS56R5Whggu3MCYQNxmUYGFiKOA5tO7jdiOFsgpziGFIxVpb9yAvEoo5vJPuaZqNDAg0N417tqpMwLNJtE1ykfWm0zNMb1TqvuHWQTvu(2JnbbR2DOC7OfOYu04Xv0ROWoGz4uLLIsCLHxfkQSFcSwkXZlglo3MCPBLgxl)j(Fs2pbwlL4Whggu3MCYQNxmUYGRLROcHvBROUkpNHUQDY8qGktrZqqROxrHDaZWPklfL4kdVkuuWAPehHKV(WZDAn68Hr(28dHevlFcqEcGFI)NaRLsC4dddQBtoz1ZlgxzW1YFIxVpr)NCAnYTcc6S1P7tO7jJI5t8)KtRlHlF9H3taYtamOFIEkQqy12kkiiK90XTjhttut38WaIuzkAgourVIc7aMHtvwkkXvgEvOOS4grJdfdMb1LlSNq3tO9G(jE9(elUr04qXGzqD5c7ja5j6c6N417ts1iuZDiKOA5taYtaSIkewTTI6WiV6rxIfqqPYuMIAHzLHxy12k6v0murVIc7aMHtvwkkXvgEvOOSGHTXhddkEvp6K2Eq4yhWmC(e)pjewbc6WgHuO8j0b(jEqrfcR2wrDiK9KidLsNVQn8uMIgDv0ROWoGz4uLLIsCLHxfkQSFYCnE6wP5sii4XTsKz1JpX)tY(jWAPepZIXQE0bjeqRg5A5kQqy12kkORpw1JoywinLPOXdk6vuyhWmCQYsrjUYWRcffSwkXZSySQhDqcb0Qr(HHWEI)NiZrgZzXnIMKNUvAsHogu8j0b(j6(e)pr)NK9tMyyqDrpDtue6WTsKz1JpX)teliyhTX7AeQ5sb(eVEFs2prSGGD0gVRrOMlf4t0trfcR2wrLUvAsHoguuzkAavf9kkSdygovzPOexz4vHIcwlL4zwmw1JoiHaA1i)WqypXR3NK9tG1sj(vqqUw(t8)ezoYyolUr0KCORpw1JoywiTNqh4N4bfviSABf1cZkdVWqfLqhbdDwCJOjv0muzkAaSIEff2bmdNQSuuIRm8QqrjZrgZzXnIMKpYcrfmxmbjAb(e6a)eDFI)NO)toTUeU81hE8jMkrzpbipziOFIxVp50AKBfe0zRt3Nq3tgfZNO3t869j6)KjcRLs8la69kbYLwiY8ja5ja(jE9(KjcRLs8la69kbYpesuT8ja5jdb8t0trfcR2wrnYcrfmxmbjAbQmfndOIEff2bmdNQSuuIRm8Qqrj2EQvghVywIWQE0bZwFCSdygoFI)NaRLsC8IzjcR6rhmB9XLwiY8jGFIUpX)tcHvGGoSrifkFc4NmurfcR2wrLUvAoPDvMOYu04ru0ROWoGz4uLLIsCLHxfkkyTuIFfeKRL)e)prMJmMZIBenjh66Jv9OdMfs7j0b(j6QOcHvBROGU(yvp6GzH0uMIgAVIEff2bmdNQSuuIRm8QqrjZrgZzXnIMKpYcrfmxmbjAb(e6a)eDvuHWQTvuJSqubZftqIwGktrJhxrVIc7aMHtvwkkXvgEvOOoTUeU81hE8jMkrzpbipziOFIxVp50AKBfe0zRt3Nq3tgfZN417tY(jWAPe)kiixlxrfcR2wrLUvAoPDvMOIsOJGHolUr0KkAgQmfndbTIEff2bmdNQSuuIRm8QqrbRLs8RGGCTCfviSABff01hR6rhmlKMYu0mCOIEff2bmdNQSuuHWQTvulmRm8cdvucDem0zXnIMurZqLPmff8kDwjYS6rf9kAgQOxrHDaZWPklfL4kdVkuuNwxcx(6dVNaeWpbubTIkewTTIAHzLHxyOIsOJGHolUr0KkAgQmfn6QOxrHDaZWPklfL4kdVkuuwWW24JHbfVQhDsBpiCSdygoFIxVpjewbc6WgHuO8j0b(j6QOcHvBROoeYEsKHsPZx1gEktrJhu0ROWoGz4uLLIsCLHxfkkyTuIFfeKRLROcHvBROGU(yvp6GzH0uMIgqvrVIc7aMHtvwkkXvgEvOOoTg5wbbD26a1NaKNmkMpXR3NCADjC5Rp8Ecqa)eqfWkQqy12kQfMvgEHHkkHocg6S4grtQOzOYu0ayf9kkSdygovzPOexz4vHIcwlL4zwmw1JoiHaA1ixl)j(FImhzmNf3iAsE6wPjf6yqXNqh4NO7t8)e9Fs2pzIHb1f90nrrOd3krMvp(e)prSGGD0gVRrOMlf4t869jz)eXcc2rB8UgHAUuGprpfviSABfv6wPjf6yqrLPOzav0ROWoGz4uLLIsCLHxfkQtRlHlF9HhFIPsu2tOd8tavq)e)p50AKBfe0zRZdpHUNmkMkQqy12kkO71Un58vTHNYu04ru0ROWoGz4uLLIsCLHxfkkzoYyolUr0K80Tstk0XGIpHoWpr3N4)j6)KSFYeddQl6PBIIqhUvImRE8j(FIybb7OnExJqnxkWN417tY(jIfeSJ24Dnc1CPaFIEkQqy12kQ0Tstk0XGIktrdTxrVIc7aMHtvwkkXvgEvOOoTUeU81hE8jMkrzpHUNOlGFIxVp50A8j09epOOcHvBROwywz4fgQOe6iyOZIBenPIMHktrJhxrVIc7aMHtvwkkXvgEvOOoTUeU81hE8jMkrzpHUNayqROcHvBROIten6S9oSnLPmfL0IEg3urVIMHk6vuyhWmCQYsrjUYWRcfLfmSn(yyqXR6rN02dch7aMHZN417teBp1kJJGGx6wPXXoGz48jE9(KtRX0EJihUSQhDILnvuHWQTvuhczpjYqP05RAdpLPOrxf9kkSdygovzPOexz4vHIk7NmXWG6YSRrOg)0AmT3iYVaO3Re4t8)e9FYeH1sj(fa9ELa5slez(eG8ea)eVEFYeH1sj(fa9ELa5hcjQw(eG8epYt0trfcR2wrnYcrfmxmbjAbQmfnEqrVIc7aMHtvwkkXvgEvOOe7YMRVMFiK9KidLsNVQn84hcjQw(eGa(j6(eq5tgfZN4)jwWW24JHbfVQhDsBpiCSdygovuHWQTvuPBLMtAxLjQmfnGQIEff2bmdNQSuuIRm8Qqrj2EQvghVywIWQE0bZwFCSdygoFI)NaRLsC8IzjcR6rhmB9XLwiY8jGFIUpXR3Ni2EQvgxRzyiHItx6WgO1HJDaZW5t8)eyTuIR1mmKqXPlDyd06WpesuT8ja5jE4j(FcSwkX1AggsO40LoSbAD4A5kQqy12kQ0TsZjTRYevMIgaROxrHDaZWPklfL4kdVkuuWAPe)kiixlxrfcR2wrbD9XQE0bZcPPmfndOIEff2bmdNQSuuIRm8QqrL9tG1sjE6wGgBxUgtICT8N4)jwWW24PBbASD5AmjYXoGz4urfcR2wrTWSYWlmuzkA8ik6vuyhWmCQYsrjUYWRcf1P1LWLV(WJpXujk7ja5j6)KHa(jz8elyyB8tRlHlmdBTWQT5yhWmC(eq5t8Wt0trfcR2wrLUvAoPDvMOYu0q7v0ROWoGz4uLLIsCLHxfkQtRlHlF9HhFIPsu2tO7j6)eDb8tY4jwWW24Nwxcxyg2AHvBZXoGz48jGYN4HNONIkewTTIAHzLHxyOYu04Xv0ROcHvBROs3knN0UkturHDaZWPklLPOziOv0ROcHvBROGUx72KZx1gEkkSdygovzPmfndhQOxrfcR2wrfNiA0z7DyBkkSdygovzPmLPOeliyhTjv0ROzOIEff2bmdNQSuuIRm8QqrDrnDiiyB8yoL8QFcDpziGFIxVpj7NCrnDiiyB8yoLCeqkPjFIxVpjewbc6WgHuO8j0b(j6QOcHvBROMyyqLUPgQmfn6QOxrHDaZWPklfL4kdVkuuHWkqqh2iKcLpb8tg(e)p506s4YxF4XNyQeL9e6EIhEI)Ni2LnxFnpVyS4CBYLUvA8dHevlFcqEIhEI)NK9tSGHTXHpmmOUn5KvpVyCLbh7aMHZN4)j6)KSFYf10HGGTXJ5uYraPKM8jE9(KlQPdbbBJhZPKx9tO7jdb8t0trfcR2wrj9fhKQhDqkPPmfnEqrVIc7aMHtvwkkXvgEvOOcHvGGoSrifkFcDGFIUpX)tY(jwWW24Whggu3MCYQNxmUYGJDaZWPIkewTTIs6loivp6GustzkAavf9kkSdygovzPOexz4vHIYcg2gh(WWG62Ktw98IXvgCSdygoFI)NO)tG1sjo8HHb1TjNS65fJRm4A5pX)t0)jHWkqqh2iKcLpb8tg(e)p506s4YxF4XNyQeL9e6EcOc6N417tcHvGGoSrifkFcDGFIUpX)toTUeU81hE8jMkrzpHUNmGG(j69eVEFs2pbwlL4Whggu3MCYQNxmUYGRL)e)prSlBU(Ao8HHb1TjNS65fJRm4hcjQw(e9uuHWQTvusFXbP6rhKsAktrdGv0ROWoGz4uLLIsCLHxfkQqyfiOdBesHYNa(jdFI)Ni2LnxFnpVyS4CBYLUvA8dHevlFcqEIhEI)NO)tY(jxuthcc2gpMtjhbKsAYN417tUOMoeeSnEmNsE1pHUNmeWprpfviSABfvaVqQoSABhRGaRmfndOIEff2bmdNQSuuIRm8QqrfcRabDyJqku(e6a)eDvuHWQTvub8cP6WQTDSccSYu04ru0ROWoGz4uLLIsCLHxfkQqyfiOdBesHYNa(jdFI)Ni2LnxFnpVyS4CBYLUvA8dHevlFcqEIhEI)NO)tY(jxuthcc2gpMtjhbKsAYN417tUOMoeeSnEmNsE1pHUNmeWprpfviSABfLeAiYKHodk60AF7zq1rzkAO9k6vuyhWmCQYsrjUYWRcfviSce0HncPq5tOd8t0vrfcR2wrjHgImzOZGIoT23EguDuMYuuWR0LVlR6rf9kAgQOxrHDaZWPklfL4kdVkuuWAPe)kiixlxrfcR2wrbD9XQE0bZcPPmfn6QOxrHDaZWPklfL4kdVkuuwWW24JHbfVQhDsBpiCSdygoFI)NCAn(e6a)ea)eVEFsiSce0HncPq5tOd8t0vrfcR2wrDiK9KidLsNVQn8uMIgpOOxrHDaZWPklfL4kdVkuuNwxcx(6dp(etLOSNqh4NOlGvuHWQTvulmRm8cdvucDem0zXnIMurZqLPObuv0ROWoGz4uLLIsCLHxfkQtRlHlF9HhFIPsu2taYt0f0pX)tK5iJ5S4grtYhzHOcMlMGeTaFcDGFIUpX)te7YMRVMNxmwCUn5s3kn(HqIQLpHUNayfviSABf1ilevWCXeKOfOYu0ayf9kkSdygovzPOexz4vHI606s4YxF4XNyQeL9eG8eDb9t8)eXUS56R55fJfNBtU0TsJFiKOA5tO7jawrfcR2wrLUvAoPDvMOIsOJGHolUr0KkAgQmfndOIEff2bmdNQSuuIRm8QqrbRLs8mlgR6rhKqaTAKRL)e)p506s4YxF4XNyQeL9e6EI(pziGFsgpXcg2g)06s4cZWwlSABo2bmdNpbu(ep8e9EI)NiZrgZzXnIMKNUvAsHogu8j0b(j6(e)pr)NK9tMyyqDrpDtue6WTsKz1JpX)teliyhTX7AeQ5sb(eVEFs2prSGGD0gVRrOMlf4t0trfcR2wrLUvAsHoguuzkA8ik6vuyhWmCQYsrjUYWRcf1P1LWLV(WJpXujk7j0b(j6)epa4NKXtSGHTXpTUeUWmS1cR2MJDaZW5taLpXdprVN4)jYCKXCwCJOj5PBLMuOJbfFcDGFIUpX)t0)jz)Kjggux0t3efHoCRezw94t8)eXcc2rB8UgHAUuGpXR3NK9teliyhTX7AeQ5sb(e9uuHWQTvuPBLMuOJbfvMIgAVIEff2bmdNQSuuIRm8QqrDADjC5Rp84tmvIYEcDGFI(pXda(jz8elyyB8tRlHlmdBTWQT5yhWmC(eq5t8Wt0trfcR2wrTWSYWlmurj0rWqNf3iAsfndvMIgpUIEff2bmdNQSuuIRm8Qqrj2LnxFnpVyS4CBYLUvA8dHevlFcDp50AKBfe0zRduFI)NCADjC5Rp84tmvIYEcqEcOc6N4)jYCKXCwCJOj5JSqubZftqIwGpHoWprxfviSABf1ilevWCXeKOfOYu0me0k6vuyhWmCQYsrjUYWRcfLyx2C9188IXIZTjx6wPXpesuT8j09KtRrUvqqNToq9j(FYP1LWLV(WJpXujk7ja5jGkOvuHWQTvuPBLMtAxLjQOe6iyOZIBenPIMHktzkQ8dfle4Wu0RmfvSOIEfndv0ROcHvBROoeYEsKHsPZx1gEkkSdygovzPmfn6QOxrHDaZWPklfL4kdVkuuwWW24PBLMuOJbf5yhWmCQOcHvBROgzHOcMlMGeTavMIgpOOxrHDaZWPklfL4kdVkuuIDzZ1xZpeYEsKHsPZx1gE8dHevlFcqa)eDFcO8jJI5t8)elyyB8XWGIx1JoPTheo2bmdNkQqy12kQ0TsZjTRYevucDem0zXnIMurZqLPObuv0ROWoGz4uLLIsCLHxfkkyTuIFfeKRLROcHvBROGU(yvp6GzH0uMIgaROxrHDaZWPklfL4kdVkuuWAPepZIXQE0bjeqRg5A5pX)t0)jz)Kjggux0t3efHoCRezw94t8)eXcc2rB8UgHAUuGpXR3NK9teliyhTX7AeQ5sb(e9uuHWQTvuPBLMuOJbfvMIMburVIc7aMHtvwkkXvgEvOOoTUeU81hE8jMkrzpbipr)NmeWpjJNybdBJFADjCHzyRfwTnh7aMHZNakFIhEIEkQqy12kQrwiQG5IjirlqLPOXJOOxrHDaZWPklfL4kdVkuuNwxcx(6dp(etLOSNaKNO)tgc4NKXtSGHTXpTUeUWmS1cR2MJDaZW5taLpXdprpfviSABfv6wP5K2vzIkkHocg6S4grtQOzOYu0q7v0ROcHvBROoeYEsKHsPZx1gEkkSdygovzPmfnECf9kkSdygovzPOexz4vHIk7NmXWG6IE6MOi0HBLiZQhFI)NiwqWoAJ31iuZLc8jE9(KSFIybb7OnExJqnxkqfviSABfv6wPjf6yqrLPOziOv0ROWoGz4uLLIsCLHxfkQtRlHlF9HhFIPsu2tO7j6)eDb8tY4jwWW24Nwxcxyg2AHvBZXoGz48jGYN4HNONIkewTTIAHzLHxyOIsOJGHolUr0KkAgQmfndhQOxrfcR2wrnYcrfmxmbjAbQOWoGz4uLLYu0muxf9kkSdygovzPOcHvBROs3knN0Ukturj0rWqNf3iAsfndvMIMHEqrVIkewTTIc6ETBtoFvB4POWoGz4uLLYu0meuv0ROcHvBROIten6S9oSnff2bmdNQSuMYuutmfAmtrVIMHk6vuHWQTvuqQE6shIanQOWoGz4uLLYu0ORIEff2bmdNQSuuIRm8QqrL9tMRXt3knxcbbpUvImRE8j(FI(pXcg2gVeOiY5yhWmC(eVEFIyx2C91C4dddQBtoz1ZlgxzWpesuT8j09KHa(jE9(elyyB8fMvgEHvBZXoGz48j(FIyx2C9188IXIZTjx6wPXpesuT8ja5jZ14PBLMlHGGh)qir1YNONIkewTTIc66Jv9OdMfstzkA8GIEff2bmdNQSuuIRm8QqrbRLs8sOJZc22s(HqIQLpbiGFYOy(e)pbwlL4LqhNfSTLCT8N4)jYCKXCwCJOj5JSqubZftqIwGpHoWpr3N4)j6)KSFIfmSno8HHb1TjNS65fJRm4yhWmC(eVEFIyx2C91C4dddQBtoz1ZlgxzWpesuT8j09KHa(j6POcHvBROgzHOcMlMGeTavMIgqvrVIc7aMHtvwkkXvgEvOOG1sjEj0XzbBBj)qir1YNaeWpzumFI)NaRLs8sOJZc22sUw(t8)e9Fs2pXcg2gh(WWG62Ktw98IXvgCSdygoFIxVprSlBU(Ao8HHb1TjNS65fJRm4hcjQw(e6EYqa)e9uuHWQTvuPBLMtAxLjQmfnawrVIc7aMHtvwkQqy12kkrWyUqy12owjnffRKMRdiOIsSGGD0MuzkAgqf9kkSdygovzPOcHvBROebJ5cHvB7yL0uuSsAUoGGkkXUS56RLktrJhrrVIc7aMHtvwkQqy12kkrWyUqy12owjnffRKMRdiOIcLsSfOuzkAO9k6vuyhWmCQYsrfcR2wrjcgZfcR22XkPPOexz4vHIYcg2gxSSPdkgNXXoGz48j(FI(pbwlL4ILnDqX4mU0crMpHoWpziOFI)NO)tMiSwkXVaO3ReixAHiZNa(ja(jE9(KSFYeddQlZUgHA8tRX0EJi)cGEVsGprVN417ts1iuZDiKOA5tac4NmkMprpffRKMRdiOIsSSPdkgNPmfnECf9kkSdygovzPOcHvBROoT2fcR22XkPPOexz4vHIcwlL4Whggu3MCYQNxmUYGRLROyL0CDabvuWR0zLiZQhvMIMHGwrVIc7aMHtvwkQqy12kQtRDHWQTDSsAkkXvgEvOOSGHTXHpmmOUn5KvpVyCLbh7aMHZN4)j6)eXUS56R5Whggu3MCYQNxmUYGFiKOA5taYtgc6NONIIvsZ1beurbVsx(USQhvMIMHdv0ROWoGz4uLLIkewTTI60AxiSABhRKMIsCLHxfkkyTuINxmwCUn5s3knUw(t8)elyyB8fMvgEHvBZXoGz4urXkP56acQOwywz4fwTTYu0muxf9kkSdygovzPOcHvBROoT2fcR22XkPPOexz4vHIkewbc6WgHuO8j0b(j6QOyL0CDabvuXIktrZqpOOxrHDaZWPklfviSABfLiymxiSABhRKMIIvsZ1beurjTONXnvMYuuIDzZ1xlv0ROzOIEff2bmdNQSuuIRm8Qqrj2LnxFnpVyS4CBYLUvA8dJPopXR3Ni2LnxFnpVyS4CBYLUvA8dHevlFcDprxqROcHvBRO0KORmeIuzkA0vrVIc7aMHtvwkkXvgEvOOG1sjEEXyX52KlDR04A5pX)tG1sjocjF9HN70A05dJ8T5A5kQqy12kQ81QTvMIgpOOxrHDaZWPklfL4kdVkuuWAPepVyS4CBYLUvACT8N4)jWAPehHKV(WZDAn68Hr(2CTCfviSABffmB3PlPD6OmfnGQIEff2bmdNQSuuIRm8QqrbRLs88IXIZTjx6wPX1YvuHWQTvuW4jXlZQhvMIgaROxrHDaZWPklfL4kdVkuu6)KSFcSwkXZlglo3MCPBLgxl)j(FsiSce0HncPq5tOd8t09j69eVEFs2pbwlL45fJfNBtU0TsJRL)e)pr)NCAnYNyQeL9e6a)ea)e)p506s4YxF4XNyQeL9e6a)Kbe0prpfviSABfvCIOrxUgtIktrZaQOxrHDaZWPklfL4kdVkuuWAPepVyS4CBYLUvACTCfviSABffRgHAshTBAZriyBktrJhrrVIc7aMHtvwkkXvgEvOOG1sjEEXyX52KlDR04A5pX)tG1sjocjF9HN70A05dJ8T5A5kQqy12kQOfO0UG5ebJPmfn0Ef9kkSdygovzPOexz4vHIcwlL45fJfNBtU0TsJFiKOA5tac4Nq7FI)NaRLsCes(6dp3P1OZhg5BZ1YvuHWQTvuP6qy2UtLPOXJROxrHDaZWPklfL4kdVkuuWAPepVyS4CBYLUvACT8N4)jHWkqqh2iKcLpb8tg(e)pr)NaRLs88IXIZTjx6wPXpesuT8ja5ja(j(FIfmSnUyzthumoJJDaZW5t869jz)elyyBCXYMoOyCgh7aMHZN4)jWAPepVyS4CBYLUvA8dHevlFcqEIhEIEkQqy12kk4y0TjNDLitPYu0me0k6vuyhWmCQYsrjUYWRcfLfmSn(cZkdVWQT5yhWmC(e)pr)Ni2LnxFnpVyS4CBYLUvA8dJPopX)toTg5wbbD26a8tO7jJI5t8)KtRlHlF9HhFIPsu2tOd8tgc6N417tG1sjEEXyX52KlDR04A5pX)toTg5wbbD26a8tO7jJI5t07jE9(Kunc1ChcjQw(eG8eDbTIkewTTIcHKV(WZDAn68Hr(2ktrZWHk6vuyhWmCQYsrjUYWRcfLfmSno8HHb1TjNS65fJRm4yhWmC(e)p506s4YxF4XNyQeL9e6EcOc6N4)jNwJCRGGoBDa(j09KrX8j(FI(pbwlL4Whggu3MCYQNxmUYGRL)eVEFsQgHAUdHevlFcqEIUG(j6POcHvBROqi5Rp8CNwJoFyKVTYu0muxf9kkSdygovzPOexz4vHIYcg2gVeOiY5yhWmC(e)p50A8ja5jEqrfcR2wrHqYxF45oTgD(WiFBLPOzOhu0ROWoGz4uLLIsCLHxfkklyyBC4dddQBtoz1ZlgxzWXoGz48j(FI(prSlBU(Ao8HHb1TjNS65fJRm4hcjQw(eVEFIyx2C91C4dddQBtoz1ZlgxzWpmM68e)p506s4YxF4XNyQeL9eG8Kbe0prpfviSABfvEXyX52KlDR0uMIMHGQIEff2bmdNQSuuIRm8QqrzbdBJxcue5CSdygoFI)NK9tG1sjEEXyX52KlDR04A5kQqy12kQ8IXIZTjx6wPPmfndbSIEff2bmdNQSuuIRm8QqrzbdBJVWSYWlSABo2bmdNpX)t0)jwWW24JHbfVQhDsBpiCSdygoFI)NaRLs8dHSNezOu68vTHhxl)jE9(KSFIfmSn(yyqXR6rN02dch7aMHZNONIkewTTIkVyS4CBYLUvAktrZWburVIc7aMHtvwkkXvgEvOOG1sjEEXyX52KlDR04A5kQqy12kk4dddQBtoz1ZlgxzOmfnd9ik6vuyhWmCQYsrjUYWRcffSwkXZlglo3MCPBLg)qir1YNaKNmkMpX)tG1sjEEXyX52KlDR04A5pX)tY(jwWW24lmRm8cR2MJDaZWPIkewTTIkDR08PZbr6sANoktrZqAVIEff2bmdNQSuuIRm8QqrfcRabDyJqku(e6a)eDFI)Ni2LnxFnpVyS4CBYLUvA8dHevlFsgpziGFcDpXIBenUvqqNTUzHpXR3NKQrOM7qir1YNaKNmkMkQqy12kQ0TsZNohePlPD6Omfnd94k6vuyhWmCQYsrjUYWRcfLfmSn(cZkdVWQT5yhWmC(e)pj7NaRLs88IXIZTjx6wPX1YFI)NO)t0)jWAPexRHUmDCs7WE0GY1YFIxVpj7NmXWG6YSRrOg)0AmT3iYtbJHTtCAYyI3t07j(FI(pzIWAPe)cGEVsGCPfImFc4Na4N417tY(jtmmOUm7AeQXpTgt7nI8la69kb(e9EIEkQqy12kQ0TsZNohePlPD6Omfn6cAf9kkSdygovzPOexz4vHIYcg2gh(WWG62Ktw98IXvgCSdygoFI)NCADjC5Rp84tmvIYEcDpbub9t8)KtRXNqh4N4HN4)jWAPepVyS4CBYLUvACT8N417tY(jwWW24Whggu3MCYQNxmUYGJDaZW5t8)KtRlHlF9HhFIPsu2tOd8t0fWkQqy12kkO6KVgu8Gucx(HsSfOYu0O7qf9kkSdygovzPOexz4vHIcwlL45fJfNBtU0TsJRLROcHvBROUOKOBIXuzkA0vxf9kQqy12kkOyCMdLsSfOIc7aMHtvwktzkkXYMoOyCMIEfndv0ROWoGz4uLLIsCLHxfkQunc1ChcjQw(eG8KrX8jE9(eyTuINxmwCUn5s3kn(HqIQLpbipXdpX)tG1sjUyzthumoJlTqK5ta)eDb9t8)KSFIfmSn(cZkdVWQT5yhWmCQOcHvBROeqJQLUn5kbQmfn6QOxrHDaZWPklfL4kdVkuuwWW24lmRm8cR2MJDaZW5t8)KSFcSwkXZlglo3MCPBLgxl)j(FI(pbwlL4ILnDqX4mU0crMpHoWpz4a(e)pbwlL4An0LPJtAh2JguUw(t869jWAPexSSPdkgNXLwiY8j0b(jd94prpfviSABfLaAuT0TjxjqLPmLPOabpzTTIgDbTUGE4WHEefLV46QhLkkAhp6aKMban0gd8jpHEO4tki57zpjT3tawSSPdkgNb8to0JPvhoFICHGpj0Sfsy48jcOrpIs(daGwn(KHd8ja12GGNHZNaSfmSnoTa(j2(eGTGHTXPfh7aMHtGFsypH2eueqFI(dbe94paaA14t0DGpbO2ge8mC(eGTGHTXPfWpX2NaSfmSnoT4yhWmCc8t0FiGOh)b4bG2XJoaPzaqdTXaFYtOhk(Kcs(E2ts79eGxywz4fwTnWp5qpMwD48jYfc(KqZwiHHZNiGg9ik5paaA14tgoWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(j6peq0J)aaOvJpzah4taQTbbpdNpbyX2tTY40c4Ny7tawS9uRmoT4yhWmCc8t0FiGOh)b4bG2XJoaPzaqdTXaFYtOhk(Kcs(E2ts79eGHxPZkrMvpc8to0JPvhoFICHGpj0Sfsy48jcOrpIs(daGwn(eDh4taQTbbpdNpbylyyBCAb8tS9jaBbdBJtlo2bmdNa)e9hci6XFaEaOD8OdqAga0qBmWN8e6HIpPGKVN9K0EpbyPf9mUjWp5qpMwD48jYfc(KqZwiHHZNiGg9ik5paaA14tgoWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(j6peq0J)aaOvJpz4aFcqTni4z48jal2EQvgNwa)eBFcWITNALXPfh7aMHtGFI(dbe94paaA14t8WaFcqTni4z48jaBbdBJtlGFITpbylyyBCAXXoGz4e4Ne2tOnbfb0NO)qarp(daGwn(eqDGpbO2ge8mC(eGfBp1kJtlGFITpbyX2tTY40IJDaZWjWprFDbe94paaA14tgWb(eGABqWZW5ta2cg2gNwa)eBFcWwWW240IJDaZWjWpjSNqBckcOpr)HaIE8haaTA8jEKb(eGABqWZW5ta2cg2gNwa)eBFcWwWW240IJDaZWjWpr)HaIE8haaTA8j0(b(eGABqWZW5ta2cg2gNwa)eBFcWwWW240IJDaZWjWpr)HaIE8hGhaAhp6aKMban0gd8jpHEO4tki57zpjT3tagLsSfOe4NCOhtRoC(e5cbFsOzlKWW5teqJEeL8haaTA8jEyGpbO2ge8mC(eGT4grJpKBfe0zRBwiWpX2NaSvqqNTUzHa)e9hci6XFaEaOD8OdqAga0qBmWN8e6HIpPGKVN9K0Epby4v6Y3Lv9iWp5qpMwD48jYfc(KqZwiHHZNiGg9ik5paaA14t0DGpbO2ge8mC(eGTGHTXPfWpX2NaSfmSnoT4yhWmCc8t0FiGOh)baqRgFYaoWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(j6peq0J)aaOvJpXJmWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(j6peq0J)aaOvJpH2pWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(j6peq0J)a8aq74rhG0maOH2yGp5j0dfFsbjFp7jP9EcWIDzZ1xlb(jh6X0QdNprUqWNeA2cjmC(eb0Ohrj)baqRgFYqqpWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(j6peq0J)aaOvJpz4Wb(eGABqWZW5ta2cg2gNwa)eBFcWwWW240IJDaZWjWpr)HaIE8haaTA8jd1DGpbO2ge8mC(eGTGHTXPfWpX2NaSfmSnoT4yhWmCc8t0FiGOh)baqRgFYqpmWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(j6peq0J)aaOvJpziOoWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(j6peq0J)aaOvJpziGh4taQTbbpdNpbylyyBCAb8tS9jaBbdBJtlo2bmdNa)e9hci6XFaa0QXNm0JmWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(jH9eAtqra9j6peq0J)aaOvJpzOhFGpbO2ge8mC(eGTGHTXPfWpX2NaSfmSnoT4yhWmCc8t0FiGOh)baqRgFIUGEGpbO2ge8mC(eGTGHTXPfWpX2NaSfmSnoT4yhWmCc8t0xxarp(dWdaTJhDasZaGgAJb(KNqpu8jfK89SNK27jalwqWoAtc8to0JPvhoFICHGpj0Sfsy48jcOrpIs(daGwn(eDh4taQTbbpdNpbylyyBCAb8tS9jaBbdBJtlo2bmdNa)e9hci6XFaa0QXN4Hb(eGABqWZW5ta2cg2gNwa)eBFcWwWW240IJDaZWjWpjSNqBckcOpr)HaIE8haaTA8jG6aFcqTni4z48jaBbdBJtlGFITpbylyyBCAXXoGz4e4NO)qarp(dWdaTJhDasZaGgAJb(KNqpu8jfK89SNK27japXuOXmGFYHEmT6W5tKle8jHMTqcdNpran6ruYFaa0QXNO7aFcqTni4z48jaBbdBJtlGFITpbylyyBCAXXoGz4e4NOVUaIE8haaTA8jEyGpbO2ge8mC(eGTGHTXPfWpX2NaSfmSnoT4yhWmCc8t0FiGOh)baqRgFcTFGpbO2ge8mC(eGTGHTXPfWpX2NaSfmSnoT4yhWmCc8t0FiGOh)baqRgFYqqpWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(j6peq0J)aaOvJpz4Wb(eGABqWZW5ta2cg2gNwa)eBFcWwWW240IJDaZWjWpjSNqBckcOpr)HaIE8hGhaAhp6aKMban0gd8jpHEO4tki57zpjT3taowe4NCOhtRoC(e5cbFsOzlKWW5teqJEeL8haaTA8j6oWNauBdcEgoFcWwWW240c4Ny7ta2cg2gNwCSdygob(jH9eAtqra9j6peq0J)aaOvJpXdd8ja12GGNHZNaSfmSnoTa(j2(eGTGHTXPfh7aMHtGFsypH2eueqFI(dbe94paaA14tgWb(eGABqWZW5ta2cg2gNwa)eBFcWwWW240IJDaZWjWpr)HaIE8haaTA8jEKb(eGABqWZW5ta2cg2gNwa)eBFcWwWW240IJDaZWjWpr)HaIE8haaTA8jdb9aFcqTni4z48jaBbdBJtlGFITpbylyyBCAXXoGz4e4NO)qarp(dWdWaas(EgoFYqq)Kqy12pHvstYFauuYCuOOrxapurLFBQyOII2(eqbWWG(eqb7AeQ9eqH3kThaA7tOzbbHaJ3t0fu98j6cADb9dWdaT9juqJ56Jf9u(e994CqZ1vVhGhaA7tOnbeuOz48jii4PZtScc(edk(Kqy79Ks(KaKOybmd5paHWQTLGHu90LoebA8bG2(epAEotNNak8wP9eqHii49KONpbsuTfv)KbGqNNqFW2w(aecR2wMb4bHU(yvp6GzH08SsGZEUgpDR0Cjee84wjYS6r)6BbdBJxcue5E9k2LnxFnh(WWG62Ktw98IXvg8dHevlPBiG961cg2gFHzLHxy12(f7YMRVMNxmwCUn5s3kn(HqIQLazUgpDR0Cjee84hcjQwQ3dqiSABzgGhCKfIkyUycs0c0ZkbgwlL4LqhNfSTL8dHevlbc4rX0pSwkXlHoolyBl5A5(L5iJ5S4grtYhzHOcMlMGeTaPdSU(1pBlyyBC4dddQBtoz1Zlgxz41Ryx2C91C4dddQBtoz1ZlgxzWpesuTKUHawVhGqy12Ymapy6wP5K2vzIEwjWWAPeVe64SGTTKFiKOAjqapkM(H1sjEj0XzbBBjxl3V(zBbdBJdFyyqDBYjREEX4kdo2bmdNE9k2LnxFnh(WWG62Ktw98IXvg8dHevlPBiG17bG2(eGc6Us8jEuHvB)ewjTNy7toT(biewTTmdWdkcgZfcR22XkP5zhqqWIfeSJ2KpaHWQTLzaEqrWyUqy12owjnp7accwSlBU(A5dqiSABzgGhuemMlewTTJvsZZoGGGrPeBbkFacHvBlZa8GIGXCHWQTDSsAE2beeSyzthumoZZkb2cg2gxSSPdkgN5xFyTuIlw20bfJZ4slezsh4HG2V(tewlL4xa07vcKlTqKjya71B2tmmOUm7AeQXpTgt7nI8la69kbQNxVPAeQ5oesuTeiGhft9EacHvBlZa8GNw7cHvB7yL08Sdiiy4v6SsKz1JEwjWWAPeh(WWG62Ktw98IXvgCT8hGqy12Ymap4P1Uqy12owjnp7accgELU8Dzvp6zLaBbdBJdFyyqDBYjREEX4kd)6l2LnxFnh(WWG62Ktw98IXvg8dHevlbYqqR3dqiSABzgGh80AxiSABhRKMNDabbVWSYWlSABpReyyTuINxmwCUn5s3knUwUFlyyB8fMvgEHvB)aecR2wMb4bpT2fcR22XkP5zhqqWXIEwjWHWkqqh2iKcL0bw3hGqy12YmapOiymxiSABhRKMNDabblTONXnFaEaOTpXJU0MpzaUwy12paHWQTL8yrWhczpjYqP05RAdVhGqy12sESygGhCKfIkyUycs0c0Zkb2cg2gpDR0KcDmO4dqiSABjpwmdWdMUvAoPDvMONcDem0zXnIMe8qpReyXUS56R5hczpjYqP05RAdp(HqIQLabSUGYrX0VfmSn(yyqXR6rN02dYdqiSABjpwmdWdcD9XQE0bZcP5zLadRLs8RGGCT8hGqy12sESygGhmDR0KcDmOONvcmSwkXZSySQhDqcb0QrUwUF9ZEIHb1f90nrrOd3krMvp6xSGGD0gVRrOMlfOxVzlwqWoAJ31iuZLcuVhGqy12sESygGhCKfIkyUycs0c0Zkb(06s4YxF4XNyQeLbe9hc4mSGHTXpTUeUWmS1cR2gu6b9EacHvBl5XIzaEW0TsZjTRYe9uOJGHolUr0KGh6zLaFADjC5Rp84tmvIYaI(dbCgwWW24Nwxcxyg2AHvBdk9GEpaHWQTL8yXmap4Hq2tImukD(Q2W7biewTTKhlMb4bt3knPqhdk6zLaN9eddQl6PBIIqhUvImRE0Vybb7OnExJqnxkqVEZwSGGD0gVRrOMlf4dqiSABjpwmdWdUWSYWlm0tHocg6S4grtcEONvc8P1LWLV(WJpXujkJo91fWzybdBJFADjCHzyRfwTnO0d69aecR2wYJfZa8GJSqubZftqIwGpaHWQTL8yXmapy6wP5K2vzIEk0rWqNf3iAsWdFacHvBl5XIzaEqO71Un58vTH3dqiSABjpwmdWdgNiA0z7DyBpapa02NK1HHb9jB6juvpVyCLXtY3Lv94tU1cR2(jd8jslot(KHGw(eymTh(KSwQNuYNeGeflGz4dqiSABjhELU8Dzvpcg66Jv9OdMfsZZkbgwlL4xbb5A5paHWQTLC4v6Y3Lv9ygGh8qi7jrgkLoFvB45zLaBbdBJpggu8QE0jT9G4)0AKoWa2R3qyfiOdBesHs6aR7daT9jaBXnIMRsGHeaYa1FIWAPe)cGEVsGCPfImZyOE0Uu)jcRLs8la69kbYpesuTmJH6bkNyyqDz21iuJFAnM2Be5xa07vce4NmaXCmm5tINWwZZNyql5tk5tQ2WEIZNy7tS4gr7jgu8jqRrOO0Es(v7vMopbBeIopXxzqFs0pjGlwz68edAypXxXypjYZz68Kla69kb(Kk9KtRX0EJ4K)e6Hg2tGXQhFs0pbBeIopXxzqFcOFI0crMspFYEpj6NGncrNNyqd7jgu8jtewlLEIVIXEIC3(jiGKxh(KT5paHWQTLC4v6Y3Lv9ygGhCHzLHxyONcDem0zXnIMe8qpRe4tRlHlF9HhFIPsugDG1fWpaHWQTLC4v6Y3Lv9ygGhCKfIkyUycs0c0Zkb(06s4YxF4XNyQeLbeDbTFzoYyolUr0K8rwiQG5Ijirlq6aRRFXUS56R55fJfNBtU0TsJFiKOAjDa(biewTTKdVsx(USQhZa8GPBLMtAxLj6PqhbdDwCJOjbp0Zkb(06s4YxF4XNyQeLbeDbTFXUS56R55fJfNBtU0TsJFiKOAjDa(biewTTKdVsx(USQhZa8GPBLMuOJbf9SsGH1sjEMfJv9OdsiGwnY1Y9FADjC5Rp84tmvIYOt)HaodlyyB8tRlHlmdBTWQTbLEqp)YCKXCwCJOj5PBLMuOJbfPdSU(1p7jggux0t3efHoCRezw9OFXcc2rB8UgHAUuGE9MTybb7OnExJqnxkq9EacHvBl5WR0LVlR6Xmapy6wPjf6yqrpRe4tRlHlF9HhFIPsugDG13daodlyyB8tRlHlmdBTWQTbLEqp)YCKXCwCJOj5PBLMuOJbfPdSU(1p7jggux0t3efHoCRezw9OFXcc2rB8UgHAUuGE9MTybb7OnExJqnxkq9EacHvBl5WR0LVlR6Xmap4cZkdVWqpf6iyOZIBenj4HEwjWNwxcx(6dp(etLOm6aRVhaCgwWW24Nwxcxyg2AHvBdk9GEpaHWQTLC4v6Y3Lv9ygGhCKfIkyUycs0c0ZkbwSlBU(AEEXyX52KlDR04hcjQws3P1i3kiOZwhO6)06s4YxF4XNyQeLbeqf0(L5iJ5S4grtYhzHOcMlMGeTaPdSUpaHWQTLC4v6Y3Lv9ygGhmDR0Cs7Qmrpf6iyOZIBenj4HEwjWIDzZ1xZZlglo3MCPBLg)qir1s6oTg5wbbD26av)Nwxcx(6dp(etLOmGaQG(b4bG2(KSommOpztpHQ65fJRmEIhvyfi4tgGRfwT9dqiSABjhELoRezw9i4fMvgEHHEk0rWqNf3iAsWd9SsGpTUeU81hEabmOc6hGqy12so8kDwjYS6Xmap4Hq2tImukD(Q2WZZkb2cg2gFmmO4v9OtA7bXR3qyfiOdBesHs6aR7dqiSABjhELoRezw9ygGhe66Jv9OdMfsZZkbgwlL4xbb5A5paHWQTLC4v6SsKz1JzaEWfMvgEHHEk0rWqNf3iAsWd9SsGpTg5wbbD26avGmkME9EADjC5Rp8acyqfWpaHWQTLC4v6SsKz1JzaEW0Tstk0XGIEwjWWAPepZIXQE0bjeqRg5A5(L5iJ5S4grtYt3knPqhdkshyD9RF2tmmOUONUjkcD4wjYS6r)IfeSJ24Dnc1CPa96nBXcc2rB8UgHAUuG69aecR2wYHxPZkrMvpMb4bHUx72KZx1gEEwjWNwxcx(6dp(etLOm6adQG2)P1i3kiOZwNhOBumFacHvBl5WR0zLiZQhZa8GPBLMuOJbf9SsGL5iJ5S4grtYt3knPqhdkshyD9RF2tmmOUONUjkcD4wjYS6r)IfeSJ24Dnc1CPa96nBXcc2rB8UgHAUuG69aecR2wYHxPZkrMvpMb4bxywz4fg6PqhbdDwCJOjbp0Zkb(06s4YxF4XNyQeLrNUa2R3tRr68WdqiSABjhELoRezw9ygGhmor0OZ27W28SsGpTUeU81hE8jMkrz0byq)a8aqBFcqTS5tODfgN9eGA7zz12YhGqy12sUyzthumodSaAuT0TjxjqpRe4unc1ChcjQwcKrX0RxyTuINxmwCUn5s3kn(HqIQLaXd(H1sjUyzthumoJlTqKjyDbT)STGHTXxywz4fwT9dqiSABjxSSPdkgNLb4bfqJQLUn5kb6zLaBbdBJVWSYWlSAB)zdRLs88IXIZTjx6wPX1Y9RpSwkXflB6GIXzCPfImPd8Wb0pSwkX1AOlthN0oShnOCTCVEH1sjUyzthumoJlTqKjDGh6X17b4bG2(eqX(j0UwIpzayiePNpH291QTFs0ZNmadrfm5dqiSABjxSlBU(Ajynj6kdHi9SsGf7YMRVMNxmwCUn5s3kn(HXuhVEf7YMRVMNxmwCUn5s3kn(HqIQL0PlOFacHvBl5IDzZ1xlZa8G5RvB7zLadRLs88IXIZTjx6wPX1Y9dRLsCes(6dp3P1OZhg5BZ1YFacHvBl5IDzZ1xlZa8GWSDNUK2PJNvcmSwkXZlglo3MCPBLgxl3pSwkXri5Rp8CNwJoFyKVnxl)biewTTKl2LnxFTmdWdcJNeVmRE0ZkbgwlL45fJfNBtU0TsJRL)aecR2wYf7YMRVwMb4bJten6Y1ys0Zkbw)SH1sjEEXyX52KlDR04A5(dHvGGoSrifkPdSU651B2WAPepVyS4CBYLUvACTC)6FAnYNyQeLrhya7)06s4YxF4XNyQeLrh4be069aecR2wYf7YMRVwMb4bz1iut6ODtBocbBZZkbgwlL45fJfNBtU0TsJRL)aecR2wYf7YMRVwMb4bJwGs7cMtemMNvcmSwkXZlglo3MCPBLgxl3pSwkXri5Rp8CNwJoFyKVnxl)biewTTKl2LnxFTmdWdMQdHz7o9SsGH1sjEEXyX52KlDR04hcjQwceW0E)WAPehHKV(WZDAn68Hr(2CT8hGqy12sUyx2C91YmapiCm62KZUsKP0ZkbgwlL45fJfNBtU0TsJRL7pewbc6WgHuOe8q)6dRLs88IXIZTjx6wPXpesuTeia2VfmSnUyzthumoJJDaZWPxVzBbdBJlw20bfJZ4yhWmC6hwlL45fJfNBtU0TsJFiKOAjq8GEpa02Nau7YMRVw(aecR2wYf7YMRVwMb4bri5Rp8CNwJoFyKVTNvcSfmSn(cZkdVWQT9RVyx2C9188IXIZTjx6wPXpmM64)0AKBfe0zRdW0nkM(pTUeU81hE8jMkrz0bEiO96fwlL45fJfNBtU0TsJRL7)0AKBfe0zRdW0nkM651BQgHAUdHevlbIUG(biewTTKl2LnxFTmdWdIqYxF45oTgD(WiFBpReylyyBC4dddQBtoz1Zlgxz4)06s4YxF4XNyQeLrhOcA)NwJCRGGoBDaMUrX0V(WAPeh(WWG62Ktw98IXvgCTCVEt1iuZDiKOAjq0f069aecR2wYf7YMRVwMb4bri5Rp8CNwJoFyKVTNvcSfmSnEjqrK7)0AeiE4biewTTKl2LnxFTmdWdMxmwCUn5s3knpReylyyBC4dddQBtoz1Zlgxz4xFXUS56R5Whggu3MCYQNxmUYGFiKOAPxVIDzZ1xZHpmmOUn5KvpVyCLb)WyQJ)tRlHlF9HhFIPsugqgqqR3dqiSABjxSlBU(AzgGhmVyS4CBYLUvAEwjWwWW24LafrU)SH1sjEEXyX52KlDR04A5paHWQTLCXUS56RLzaEW8IXIZTjx6wP5zLaBbdBJVWSYWlSAB)6BbdBJpggu8QE0jT9GWXoGz40pSwkXpeYEsKHsPZx1gECTCVEZ2cg2gFmmO4v9OtA7bHJDaZWPEpaHWQTLCXUS56RLzaEq4dddQBtoz1Zlgxz4zLadRLs88IXIZTjx6wPX1YFacHvBl5IDzZ1xlZa8GPBLMpDoisxs70XZkbgwlL45fJfNBtU0TsJFiKOAjqgft)WAPepVyS4CBYLUvACTC)zBbdBJVWSYWlSA7hGqy12sUyx2C91Ymapy6wP5tNdI0L0oD8SsGdHvGGoSrifkPdSU(f7YMRVMNxmwCUn5s3kn(HqIQLzmeW0zXnIg3kiOZw3SqVEt1iuZDiKOAjqgfZhGqy12sUyx2C91Ymapy6wP5tNdI0L0oD8SsGTGHTXxywz4fwTT)SH1sjEEXyX52KlDR04A5(1xFyTuIR1qxMooPDypAq5A5E9M9eddQlZUgHA8tRX0EJipfmg2oXPjJjE65x)jcRLs8la69kbYLwiYemG96n7jgguxMDnc14NwJP9gr(fa9ELa1tVhGqy12sUyx2C91YmapiuDYxdkEqkHl)qj2c0Zkb2cg2gh(WWG62Ktw98IXvg(pTUeU81hE8jMkrz0bQG2)P1iDG9GFyTuINxmwCUn5s3knUwUxVzBbdBJdFyyqDBYjREEX4kd)Nwxcx(6dp(etLOm6aRlGFacHvBl5IDzZ1xlZa8Gxus0nXy6zLadRLs88IXIZTjx6wPX1YFacHvBl5IDzZ1xlZa8GqX4mhkLylWhGhaA7taQfeSJ2EIhfUyLvO8biewTTKlwqWoAtcEIHbv6MAONvc8f10HGGTXJ5uYRMUHa2R3SVOMoeeSnEmNsociL0KE9gcRabDyJqkushyDFacHvBl5IfeSJ2KzaEqPV4Gu9OdsjnpRe4qyfiOdBesHsWd9FADjC5Rp84tmvIYOZd(f7YMRVMNxmwCUn5s3kn(HqIQLaXd(Z2cg2gh(WWG62Ktw98IXvg(1p7lQPdbbBJhZPKJasjnPxVxuthcc2gpMtjVA6gcy9EacHvBl5IfeSJ2KzaEqPV4Gu9OdsjnpRe4qyfiOdBesHs6aRR)STGHTXHpmmOUn5KvpVyCLXdqiSABjxSGGD0MmdWdk9fhKQhDqkP5zLaBbdBJdFyyqDBYjREEX4kd)6dRLsC4dddQBtoz1ZlgxzW1Y9RFiSce0HncPqj4H(pTUeU81hE8jMkrz0bQG2R3qyfiOdBesHs6aRR)tRlHlF9HhFIPsugDdiO1ZR3SH1sjo8HHb1TjNS65fJRm4A5(f7YMRVMdFyyqDBYjREEX4kd(HqIQL69aecR2wYfliyhTjZa8Gb8cP6WQTDSccSNvcCiSce0HncPqj4H(f7YMRVMNxmwCUn5s3kn(HqIQLaXd(1p7lQPdbbBJhZPKJasjnPxVxuthcc2gpMtjVA6gcy9EacHvBl5IfeSJ2KzaEWaEHuDy12owbb2Zkboewbc6WgHuOKoW6(aecR2wYfliyhTjZa8GsOHitg6mOOtR9TNbvhpRe4qyfiOdBesHsWd9l2LnxFnpVyS4CBYLUvA8dHevlbIh8RF2xuthcc2gpMtjhbKsAsVEVOMoeeSnEmNsE10neW69aecR2wYfliyhTjZa8GsOHitg6mOOtR9TNbvhpRe4qyfiOdBesHs6aR7dWdqiSABjhLsSfOemmB3PBtodk6WgHOJNvcmSwkXZlglo3MCPBLgxl3V(WAPepVyS4CBYLUvA8dHevlbYqq7xFyTuIdFyyqDBYjREEX4kdUwUxVwWW24lmRm8cR2MJDaZWPxVwWW24Lafroh7aMHt)zhanELH8sOJtuwmrgh7aMHt986fwlL4LqhNOSyImUwUFlyyB8sGIiNJDaZWPEpaHWQTLCukXwGYmap4OwCZkA3MCbqJ3Aq9SsGZ2cg2gVeOiY5yhWmC61RfmSnEjqrKZXoGz40Fa04vgYlHoorzXezCSdygo9dRLs88IXIZTjx6wPXpesuTeidOFyTuINxmwCUn5s3knUwUxVwWW24Lafroh7aMHt)zhanELH8sOJtuwmrgh7aMHZhGqy12sokLylqzgGhuaTymN0omY0ZkbgwlL45fJfNBtU0TsJFiKOAjqaSFyTuINxmwCUn5s3knUwUxVwCJOXhYTcc6S1nleia(biewTTKJsj2cuMb4bnOOtRHxTE6s7jqpReyyTuIFOitgkLU0EcKRL71lSwkXpuKjdLsxApb6eRwB4XLwiYeidh(aecR2wYrPeBbkZa8GPvOjXPlaA8kdDWyaXZkboByTuINxmwCUn5s3knUwU)SH1sjo8HHb1TjNS65fJRm4A5paHWQTLCukXwGYmapOyBb22fgoDjwab9SsGZgwlL45fJfNBtU0TsJRL7pByTuIdFyyqDBYjREEX4kdUwU)5ACX2cSTlmC6sSac6G1UMFiKOAjyq)aecR2wYrPeBbkZa8G5AxL0P6rhmlKMNvcC2WAPepVyS4CBYLUvACTC)zdRLsC4dddQBtoz1ZlgxzW1YFacHvBl5OuITaLzaEqF7XMGGv7ouUD0c0ZkbgwlL45fJfNBtU0TsJRL71lSwkXri5Rp8CNwJoFyKVnxl3RxXUS56R5Whggu3MCYQNxmUYGFiKOAjDdiOZyiG96f9yAvEoo5vJPuaZqNDAguVErpMwLNJtE1ykfWm0zNMb1TqFacHvBl5OuITaLzaEWRYZzORANmpeONvcC2WAPepVyS4CBYLUvACTC)zdRLsC4dddQBtoz1ZlgxzW1YFacHvBl5OuITaLzaEqiiK90XTjhttut38WaI0ZkbgwlL4iK81hEUtRrNpmY3MFiKOAjqaSFyTuIdFyyqDBYjREEX4kdUwUxV6FAnYTcc6S1PlDJIP)tRlHlF9HhqamO17biewTTKJsj2cuMb4bpmYRE0Lybeu6zLaBXnIghkgmdQlxy0r7bTxVwCJOXHIbZG6Yfgq0f0E9MQrOM7qir1sGa4hGhaA7tafHzLHxy12p5wlSA7hGqy12s(cZkdVWQTbFiK9KidLsNVQn88SsGTGHTXhddkEvp6K2Eq8hcRabDyJqkushyp8aecR2wYxywz4fwTDgGhe66Jv9OdMfsZZkbo75A80TsZLqqWJBLiZQh9NnSwkXZSySQhDqcb0QrUw(dqiSABjFHzLHxy12zaEW0Tstk0XGIEwjWWAPepZIXQE0bjeqRg5hgcZVmhzmNf3iAsE6wPjf6yqr6aRRF9ZEIHb1f90nrrOd3krMvp6xSGGD0gVRrOMlfOxVzlwqWoAJ31iuZLcuVhGqy12s(cZkdVWQTZa8GlmRm8cd9uOJGHolUr0KGh6zLadRLs8mlgR6rhKqaTAKFyimVEZgwlL4xbb5A5(L5iJ5S4grtYHU(yvp6GzH0OdShEacHvBl5lmRm8cR2odWdoYcrfmxmbjAb6zLalZrgZzXnIMKpYcrfmxmbjAbshyD9R)P1LWLV(WJpXujkdidbTxVNwJCRGGoBD6s3OyQNxV6pryTuIFbqVxjqU0crMabWE9oryTuIFbqVxjq(HqIQLaziG17biewTTKVWSYWlSA7mapy6wP5K2vzIEwjWITNALXXlMLiSQhDWS1NFyTuIJxmlryvp6GzRpU0crMG11FiSce0HncPqj4HpaHWQTL8fMvgEHvBNb4bHU(yvp6GzH08SsGH1sj(vqqUwUFzoYyolUr0KCORpw1Joywin6aR7dqiSABjFHzLHxy12zaEWrwiQG5IjirlqpReyzoYyolUr0K8rwiQG5Ijirlq6aR7dqiSABjFHzLHxy12zaEW0TsZjTRYe9uOJGHolUr0KGh6zLaFADjC5Rp84tmvIYaYqq717P1i3kiOZwNU0nkME9MnSwkXVccY1YFacHvBl5lmRm8cR2odWdcD9XQE0bZcP5zLadRLs8RGGCT8hGqy12s(cZkdVWQTZa8GlmRm8cd9uOJGHolUr0KGh(a8aqBFcLf9mU5tKvpYqAxyXnI2tU1cR2(biewTTKlTONXnbFiK9KidLsNVQn88SsGTGHTXhddkEvp6K2Eq86vS9uRmoccEPBLMxVNwJP9groCzvp6elB(aecR2wYLw0Z4MzaEWrwiQG5IjirlqpRe4SNyyqDz21iuJFAnM2Be5xa07vc0V(tewlL4xa07vcKlTqKjqaSxVtewlL4xa07vcKFiKOAjq8i69aecR2wYLw0Z4MzaEW0TsZjTRYe9SsGf7YMRVMFiK9KidLsNVQn84hcjQwceW6ckhft)wWW24JHbfVQhDsBpipaHWQTLCPf9mUzgGhmDR0Cs7QmrpReyX2tTY44fZsew1Joy26ZpSwkXXlMLiSQhDWS1hxAHitW661Ry7PwzCTMHHekoDPdBGwh)WAPexRzyiHItx6WgO1HFiKOAjq8GFyTuIR1mmKqXPlDyd06W1YFacHvBl5sl6zCZmapi01hR6rhmlKMNvcmSwkXVccY1YFacHvBl5sl6zCZmap4cZkdVWqpRe4SH1sjE6wGgBxUgtICTC)wWW24PBbASD5Amj(aecR2wYLw0Z4MzaEW0TsZjTRYe9SsGpTUeU81hE8jMkrzar)HaodlyyB8tRlHlmdBTWQTbLEqVhGqy12sU0IEg3mdWdUWSYWlm0Zkb(06s4YxF4XNyQeLrN(6c4mSGHTXpTUeUWmS1cR2gu6b9EacHvBl5sl6zCZmapy6wP5K2vzIpaHWQTLCPf9mUzgGhe6ETBtoFvB49aecR2wYLw0Z4MzaEW4erJoBVdBtzktPa]] )

end
