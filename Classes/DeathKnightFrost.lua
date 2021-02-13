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


    spec:RegisterPack( "Frost DK", 20210213, [[d4ejncqiGIhjaCjbvfSjj4tkIrrk1PiLSkGk1RuKmlbLBbujSlu9laYWqrCmfLLjq9muKMgqfxdfyBaL4BOGQXbusNtqv16eGMhqv3db7df6GOGyHks9qbKjcuj6IavsBuqv8ruqPrkOQKtcuQwjaEPGQsntbv2jPWpfuLgkqP0srbPNIstvGCvbvf9vGsXybO2lL(Rqdg0HPAXi6XKmzfUm0ML0NLOrdKtlA1cQk0RjfnBKUncTBP(TsdhqhhfuSCv9CkMoX1jvBxr13LqJxa15rrTEbqZxq2VkBNzdYYoCbTAemtcEgtcEgt5ZyAWmaCc2YkmdeTSaDLMEjAzBNiAzdp)AKdcUm8TLfOZmD9HnilRz1FfAzbjcqtabeGktbKojxTebKjjQtDj3w9EvaKjjQaKLLupPcyVTKw2HlOvJGzsWZysWZykFgtdMbGZmlRRlG23YYMedKLfuogyBjTSd0OSSbqaCqWLOlGoy47olbjhm88RroacGa4GHhK819N5doJPHDWGzsWZoaoacGa4GbcK3LO5aiacGdcU4GmuK4ohhhK6gbCHbvBpoOUXlXdU1dgiqE2MdU1dc2v4bDZbt5GJfn9e5GaPoZhSisPhm7dc8DLKkKBzPPrm2GSSljnf8Dj3ocCxA2L2GSAmZgKLfBNKId70wwxj52w2hjUVbPOXelMTGVLDGg1NaLCBlly7U0Slpy4z)dgEjPPGVl52b8GSI)I5GZyYbnOA7H5GKyDF8GGTjL6)b36bdp)AKdQwIO5GBTEWabU0YQ(uWpDlR4uSfEPlGWp7YOr2NihBNKIJdgk0bvBp0tHJZXV(Rr4y7KuCCWqHo4R3yD)sKtMs2Lr1shCSDskooyOqh0vsohJyJet0CqgjCWGTIvJGTbzzX2jP4WoTLv9PGF6wws9AL)jrKRd0Y6kj32YcAlsZUmssDJyfRgm1gKLfBNKId70wwxj52w2LKMc(UGww1Nc(PBzj1RvUMjLMDzKORaLnYF0vILvXSIIrX)sumwnMzfRgGJnill2ojfh2PTSQpf8t3YAaIuAu8VefdVK6Q0PrFm3BfEqgjCWGpyHd(6DQIa3I4ZhynvPCqWFqWctSSUsYTTSLuxLon6J5ERqRy1Gb2GSSy7KuCyN2Y6kj32Yw)1irJ8PMOLv9PGF6w2xVtve4weF(aRPkLdc(dYWzILvXSIIrX)sumwnMzfRgGfBqwwSDskoStBzDLKBBzxsAk47cAzvFk4NUL91B8GmEqWXYQywrXO4FjkgRgZSIvdgUnill2ojfh2PTSQpf8t3Y6kjNJrSrIjAoiJeoi4CWchu7dcMdoqxaf9EehOYzMlPsZSlpyHdQ25y7TW7SeKeRoEWqHoiyoOANJT3cVZsqsS64b1YY6kj32Yw)1igfZci0kwXYQw6icc9xSbz1yMnill2ojfh2PTSUsYTTSkqE2M4wJPcTSd0O(eOKBBzdFAWdo0)SlpiyBsP(FWIPa6GGDfQCGaA6hDbKLv9PGF6wwWCqXPyl8LKMc(UKBZX2jP44GfoiPETYbMuQ)XTgR)Ae(Je9Snhe8hKPhSWbj1RvoWKs9pU1y9xJW1bEWchKuVw5QLoIGq)fUrCLMhKrchCgtSIvJGTbzzX2jP4WoTL1vsUTLvbYZ2e3AmvOLDGg1NaLCBlB4vxm5ap4wpiyBsP(FqDd6L4blMcOdc2vOYbcOPF0fqww1Nc(PBzbZbfNITWxsAk47sUnhBNKIJdw4Gd0fqrn7SeKWF9gR7xI8QtPyhvVUXh4FWchemhKuVw5atk1)4wJ1Fncxh4blCqTpiPETYvlDebH(lCJ4knpiJeo4mWYblCqs9ALR3GwkZrJ8yxkG46apyOqhKuVw5QLoIGq)fUrCLMhKrchCw4)GfoOAx6yl2CGjL6FCRX6VgH)irpBZbz8GZyYb1YkwnyQnill2ojfh2PTSQpf8t3YcMdkofBHVK0uW3LCBo2ojfhhSWbbZbhOlGIA2zjiH)6nw3Ve5vNsXoQEDJpW)GfoiPETYvlDebH(lCJ4knpiJeo4mMCWchemhKuVw5atk1)4wJ1Fncxh4blCq1U0XwS5atk1)4wJ1Fnc)rIE2MdY4bdMjwwxj52wwfipBtCRXuHwXQb4ydYYITtsXHDAlRRKCBlRcKNTjU1yQql7anQpbk52wwW2hNJTCWaT0XbdFH(lhCNJVYbcm7Ydo0)SlpiWKs93YQ(uWpDlR4uSf(sstbFxYT5y7KuCCWchemhKuVw5atk1)4wJ1Fncxh4blCqTpiPETYvlDebH(lCJ4knpiJeo4mWYblCqs9ALR3GwkZrJ8yxkG46apyOqhKuVw5QLoIGq)fUrCLMhKrchCw4)GHcDq1U0XwS5atk1)4wJ1Fnc)rIE2Mdc(dY0dw4GK61kxT0ree6VWnIR08Gms4GZaNdQLvSILDjPPGVl522GSAmZgKLfBNKId70wwxj52w2hjUVbPOXelMTGVLDGg1NaLCBlB4LKMc(UKBFWFfxYTTSQpf8t3Y6kjNJrSrIjAoiJeoitpyHdQ9bfNITWlDbe(zxgnY(e5y7KuCCWqHoOA7HEkCCo(1FnchBNKIJdgk0bF9gR7xICYuYUmQw6GJTtsXXb1Ykwnc2gKLfBNKId70ww1Nc(PBzbZbhRWR)AKyfNJpxsLMzxEWchemhKuVw5AMuA2LrIUcu2ixhOL1vsUTLf0wKMDzKK6gXkwnyQnill2ojfh2PTSQpf8t3YsQxRCntkn7YirxbkBK)ORKdw4GgGiLgf)lrXWR)AeJIzbeEqgjCWGpyHdQ9bj1Rv(aDbKjo0rUrCLMhKWbbRhmuOdcMdoqxaf9EehOYzMlPsZSlpyOqhemhuTZX2BH3zjijwD8GAzzDLKBBzR)AeJIzbeAfRgGJnill2ojfh2PTSUsYTTSljnf8DbTSQpf8t3YsQxRCntkn7YirxbkBK)ORKdgk0bbZbj1Rv(NerUoWdw4GgGiLgf)lrXWbTfPzxgjPUroiJeoitTSkMvumk(xIIXQXmRy1Gb2GSSy7KuCyN2YQ(uWpDlRbisPrX)sum8sQRsNg9XCVv4bzKWbd(GfoO2h817ufbUfXNpWAQs5GG)GZyYbdf6GVEJCjjIrzJbFqgpyPACqToyOqhu7doqs9AL)EaUFQqUrCLMhe8hKbhmuOdoqs9AL)EaUFQq(Je9Snhe8hCgdoOwwwxj52w2sQRsNg9XCVvOvSAawSbzzX2jP4WoTLv9PGF6ww12d9u447Ju5s2Lrs6wKJTtsXXblCqs9ALJVpsLlzxgjPBrUrCLMhKWbd(GfoORKCogXgjMO5Geo4mlRRKCBlB9xJenYNAIwXQbd3gKLfBNKId70ww1Nc(PBzj1Rv(NerUoWdw4GgGiLgf)lrXWbTfPzxgjPUroiJeoyWwwxj52wwqBrA2LrsQBeRy1aSAdYYITtsXHDAlR6tb)0TSgGiLgf)lrXWlPUkDA0hZ9wHhKrchmylRRKCBlBj1vPtJ(yU3k0kwnc)2GSSy7KuCyN2Y6kj32Yw)1irJ8PMOLv9PGF6wwWCqXPylCFUt9wbc5y7KuCCWchemhKuVw5AMuA2LrIUcu2ixh4bdf6GItXw4(CN6TceYX2jP44GfoiyoiPETY)KiY1bAzvmROyu8VefJvJzwXQXmMydYYITtsXHDAlR6tb)0TSK61k)tIixhOL1vsUTLf0wKMDzKK6gXkwnMnZgKLfBNKId70wwxj52w2LKMc(UGwwfZkkgf)lrXy1yMvSIL1iEp8FydYQXmBqwwSDskoStBzDLKBBzFK4(gKIgtSy2c(w2bAuFcuYTTSSI3d)hh0KDjfbxi(xIYb)vCj32YQ(uWpDlR4uSfEPlGWp7YOr2NihBNKIJdgk0bvBp0tHJZXV(Rr4y7KuCCWqHo4R3yD)sKtMs2Lr1shCSDskoSIvJGTbzzX2jP4WoTLv9PGF6wwWCWb6cOOMDwcs4VEJ19lr(7b4(PcpyHdQ9bhiPETYFpa3pvi3iUsZdc(dYGdgk0bhiPETYFpa3pvi)rIE2Mdc(dYWpOwwwxj52w2sQRsNg9XCVvOvSAWuBqwwSDskoStBzvFk4NULvTlDSfB(Je33Gu0yIfZwWN)irpBZbbpHdg8bb3hSunoyHdkofBHx6ci8ZUmAK9jYX2jP4WY6kj32Yw)1irJ8PMOvSAao2GSSy7KuCyN2YQ(uWpDlRA7HEkC89rQCj7YijDlYX2jP44GfoiPETYX3hPYLSlJK0Ti3iUsZds4GbFWqHoOA7HEkC9MIUbeoI1h7aKzo2ojfhhSWbj1RvUEtr3achX6JDaYm)rIE2Mdc(dY0dw4GK61kxVPOBaHJy9XoazMRd0Y6kj32Yw)1irJ8PMOvSAWaBqwwSDskoStBzvFk4NULLuVw5Fse56aTSUsYTTSG2I0SlJKu3iwXQbyXgKLfBNKId70ww1Nc(PBzbZbj1RvE93ae7iqDQb56apyHdkofBHx)naXocuNAqo2ojfhhmuOdsQxRCntkn7YirxbkBK)ORKdgk0bhOlGIEpIdu5mZLuPz2LhSWbv7CS9w4DwcsIvhpyHdsQxR8b6citCOJCJ4knpiJheSEWqHo4R3ixsIyu2i4CqWt4GLQHL1vsUTLDjPPGVlOvSAWWTbzzX2jP4WoTLv9PGF6w2xVtve4weF(aRPkLdc(dQ9bNXGdo1bfNITWF9ovrxeS1Dj3MJTtsXXbb3hKPhullRRKCBlB9xJenYNAIwXQby1gKLfBNKId70ww1Nc(PBzF9ovrGBr85dSMQuoiJhu7dgmdo4uhuCk2c)17ufDrWw3LCBo2ojfhheCFqMEqTSSUsYTTSljnf8DbTIvJWVnilRRKCBlB9xJenYNAIwwSDskoStBfRgZyInilRRKCBllO974wJfZwW3YITtsXHDARy1y2mBqwwxj52ww)vEJrz)hBXYITtsXHDARyflRANJT3IXgKvJz2GSSy7KuCyN2Y6kj32YoqxazIdD0YoqJ6tGsUTLnq7CS9woidHmPPKOXYQ(uWpDl775iIZXw4(yy4zFqgp4mgCWqHoiyo475iIZXw4(yy4yGtJyoyOqh0vsohJyJet0CqgjCWGTIvJGTbzzX2jP4WoTLv9PGF6wwxj5CmInsmrZbjCWzhSWbF9ovrGBr85dSMQuoiJhKPhSWbv7shBXMdmPu)JBnw)1i8hj6zBoi4pitpyHdcMdkofBHt(OlGIBnAYE8E5ACo2ojfhhSWb1(GG5GVNJiohBH7JHHJbonI5GHcDW3ZreNJTW9XWWZ(GmEWzm4GAzzDLKBBznf9Ny2LrIPrSIvdMAdYYITtsXHDAlR6tb)0TSUsY5yeBKyIMdYiHdg8blCqWCqXPylCYhDbuCRrt2J3lxJZX2jP4WY6kj32YAk6pXSlJetJyfRgGJnill2ojfh2PTSQpf8t3YkofBHt(OlGIBnAYE8E5ACo2ojfhhSWb1(GK61kN8rxaf3A0K949Y14CDGhSWb1(GUsY5yeBKyIMds4GZoyHd(6DQIa3I4ZhynvPCqgpi4WKdgk0bDLKZXi2iXenhKrchm4dw4GVENQiWTi(8bwtvkhKXdcwyYb16GHcDqWCqs9ALt(OlGIBnAYE8E5ACUoWdw4GQDPJTyZjF0fqXTgnzpEVCno)rIE2MdQLL1vsUTL1u0FIzxgjMgXkwnyGnill2ojfh2PTSQpf8t3Y6kjNJrSrIjAoiHdo7GfoOAx6yl2CGjL6FCRX6VgH)irpBZbb)bz6blCqTpiyo475iIZXw4(yy4yGtJyoyOqh89CeX5ylCFmm8SpiJhCgdoOwwwxj52wwNCjMTl52rAsK0kwnal2GSSy7KuCyN2YQ(uWpDlRRKCogXgjMO5Gms4GbBzDLKBBzDYLy2UKBhPjrsRy1GHBdYYITtsXHDAlR6tb)0TSUsY5yeBKyIMds4GZoyHdQ2Lo2InhysP(h3AS(Rr4ps0Z2CqWFqMEWchu7dcMd(EoI4CSfUpggog40iMdgk0bFphrCo2c3hddp7dY4bNXGdQLL1vsUTL1aYvAsXOacJ6DX9fqmBfRgGvBqwwSDskoStBzvFk4NUL1vsohJyJet0CqgjCWGTSUsYTTSgqUstkgfqyuVlUVaIzRyfll5AIa3LMDPniRgZSbzzX2jP4WoTL1vsUTLf0wKMDzKK6gXYoqJ6tGsUTLD6hDb0b36bzZE8E5A8dcCxA2Lh8xXLC7dgWdAe)fZbNXeZbjX6(4bNEzpyAoOp3tQtsrlR6tb)0TSK61k)tIixhOvSAeSnill2ojfh2PTSQpf8t3Y6kjNJrSrIjAoiJeoyWhmuOd(6nYLKigLnYGdcEchSunoyHdQ9bfNITWlDbe(zxgnY(e5y7KuCCWqHoOA7HEkCCo(1FnchBNKIJdgk0bF9gR7xICYuYUmQw6GJTtsXXb1YY6kj32Y(iX9nifnMyXSf8TIvdMAdYYITtsXHDAlRRKCBl7sstbFxqlRIzffJI)LOySAmZYQ(uWpDl7R3PkcClIpFG1uLYbzKWbdMbw2bAuFcuYTTSte)lrjMvce9ahqThiPETYFpa3pvi3iUsZPMPv4dApqs9AL)EaUFQq(Je9SntntlW9aDbuuZolbj8xVX6(Li)9aC)uHtoidfbIUyoOFq6kHDqbuAoyAoy2c2dCCqzpO4FjkhuaHheuwccnYbb(5(PW8bXgjY8blMcOd69bDYKMcZhua5YblMu6bDGaPmFW3dW9tfEWSEWxVX6(L4GFWGa5YbjXSlpO3heBKiZhSykGoitoOrCLMMWo4(h07dInsK5dkGC5Gci8GdKuVwpyXKspOz3(GyGbMpEWT5wXQb4ydYYITtsXHDAlR6tb)0TSVENQiWTi(8bwtvkhe8hmyMCWch0aeP0O4FjkgEj1vPtJ(yU3k8Gms4GbFWchuTlDSfBoWKs9pU1y9xJWFKONT5GmEqgyzDLKBBzlPUkDA0hZ9wHwXQbdSbzzX2jP4WoTL1vsUTLT(RrIg5tnrlR6tb)0TSVENQiWTi(8bwtvkhe8hmyMCWchuTlDSfBoWKs9pU1y9xJWFKONT5GmEqgyzvmROyu8VefJvJzwXQbyXgKLfBNKId70ww1Nc(PBzj1RvUMjLMDzKORaLnYF0vYblCWxVtve4weF(aRPkLdY4b1(GZyWbN6GItXw4VENQOlc26UKBZX2jP44GG7dY0dQ1blCqdqKsJI)LOy41FnIrXSacpiJeoyWhSWb1(GK61kFGUaYeh6i3iUsZds4GG1dgk0bbZbhOlGIEpIdu5mZLuPz2LhmuOdcMdQ25y7TW7SeKeRoEqTSSUsYTTS1FnIrXSacTIvdgUnill2ojfh2PTSQpf8t3Y(6DQIa3I4ZhynvPCqgjCqTpitzWbN6GItXw4VENQOlc26UKBZX2jP44GG7dY0dQ1blCqdqKsJI)LOy41FnIrXSacpiJeoyWhSWb1(GK61kFGUaYeh6i3iUsZds4GG1dgk0bbZbhOlGIEpIdu5mZLuPz2LhmuOdcMdQ25y7TW7SeKeRoEqTSSUsYTTS1FnIrXSacTIvdWQnill2ojfh2PTSUsYTTSljnf8DbTSQpf8t3Y(6DQIa3I4ZhynvPCqgjCqTpitzWbN6GItXw4VENQOlc26UKBZX2jP44GG7dY0dQLLvXSIIrX)sumwnMzfRgHFBqwwSDskoStBzvFk4NULvTlDSfBoWKs9pU1y9xJWFKONT5GmEWxVrUKeXOSrW5Gfo4R3PkcClIpFG1uLYbb)bbhMCWch0aeP0O4FjkgEj1vPtJ(yU3k8Gms4GbBzDLKBBzlPUkDA0hZ9wHwXQXmMydYYITtsXHDAlRRKCBlB9xJenYNAIww1Nc(PBzv7shBXMdmPu)JBnw)1i8hj6zBoiJh81BKljrmkBeCoyHd(6DQIa3I4ZhynvPCqWFqWHjwwfZkkgf)lrXy1yMvSILf4JQLiPl2GSILvTlDSfBJniRgZSbzzX2jP4WoTL1vsUTLv3GXuqIgl7anQpbk52w2WBFWWNg8GGDbjAc7GGTRKBFqVhhKH6Q0PglR6tb)0TSQDPJTyZbMuQ)XTgR)Ae(J(G5dgk0bv7shBXMdmPu)JBnw)1i8hj6zBoiJhmyMyfRgbBdYYITtsXHDAlR6tb)0TSK61khysP(h3AS(Rr46apyHdsQxRCKiWTi(XxVXyr0bUnxhOL1vsUTLf4k52wXQbtTbzzX2jP4WoTLv9PGF6wws9ALdmPu)JBnw)1iCDGhSWbj1Rvose4we)4R3ySi6a3MRd0Y6kj32Yss3DeR6pZwXQb4ydYYITtsXHDAlR6tb)0TSK61khysP(h3AS(Rr46aTSUsYTTSK4BWxZSlTIvdgydYYITtsXHDAlR6tb)0TSAFqWCqs9ALdmPu)JBnw)1iCDGhSWbDLKZXi2iXenhKrchm4dQ1bdf6GG5GK61khysP(h3AS(Rr46apyHdQ9bF9g5dSMQuoiJeoidoyHd(6DQIa3I4ZhynvPCqgjCqWctoOwwwxj52ww)vEJrG6udAfRgGfBqwwSDskoStBzvFk4NULLuVw5atk1)4wJ1FncxhOL1vsUTLLMLGetm8r9rjrSfRy1GHBdYYITtsXHDAlR6tb)0TSK61khysP(h3AS(Rr46apyHdsQxRCKiWTi(XxVXyr0bUnxhOL1vsUTL1BfAK3PrLtPwXQby1gKLfBNKId70ww1Nc(PBzj1RvoWKs9pU1y9xJWFKONT5GGNWbbRhSWbj1Rvose4we)4R3ySi6a3MRd0Y6kj32YwZhjP7oSIvJWVnill2ojfh2PTSQpf8t3YsQxRCGjL6FCRX6VgHRd8GfoORKCogXgjMO5Geo4Sdw4GAFqs9ALdmPu)JBnw)1i8hj6zBoi4pidoyHdkofBHRw6icc9x4y7KuCCWqHoiyoO4uSfUAPJii0FHJTtsXXblCqs9ALdmPu)JBnw)1i8hj6zBoi4pitpOwwwxj52wwsVmU1O8PstJvSAmJj2GSSy7KuCyN2Y6kj32YIebUfXp(6nglIoWTTSd0O(eOKBBzd0U0XwSnww1Nc(PBzfNITWxsAk47sUnhBNKIJdw4GAFq1U0XwS5atk1)4wJ1Fnc)rFW8blCWxVrUKeXOSrgCqgpyPACWch817ufbUfXNpWAQs5Gms4GZyYbdf6GK61khysP(h3AS(Rr46apyHd(6nYLKigLnYGdY4blvJdQ1bdf6G1SeKeFKONT5GG)GbZeRy1y2mBqwwSDskoStBzvFk4NULvCk2cN8rxaf3A0K949Y14CSDskooyHd(6DQIa3I4ZhynvPCqgpi4WKdw4GVEJCjjIrzJm4GmEWs14GfoO2hKuVw5Kp6cO4wJMShVxUgNRd8GHcDWAwcsIps0Z2CqWFWGzYb1YY6kj32YIebUfXp(6nglIoWTTIvJzbBdYYITtsXHDAlR6tb)0TSItXw4Pcvoqo2ojfhhSWbF9gpi4pitTSUsYTTSirGBr8JVEJXIOdCBRy1ygtTbzzX2jP4WoTLv9PGF6wwXPylCYhDbuCRrt2J3lxJZX2jP44GfoO2huTlDSfBo5JUakU1Oj7X7LRX5ps0Z2CWqHoOAx6yl2CYhDbuCRrt2J3lxJZF0hmFWch817ufbUfXNpWAQs5GG)GGfMCqTSSUsYTTSatk1)4wJ1FnIvSAmdCSbzzX2jP4WoTLv9PGF6wwXPyl8uHkhihBNKIJdw4GG5GK61khysP(h3AS(Rr46aTSUsYTTSatk1)4wJ1FnIvSAmJb2GSSy7KuCyN2YQ(uWpDlR4uSf(sstbFxYT5y7KuCCWchu7dkofBHx6ci8ZUmAK9jYX2jP44GfoiPETYFK4(gKIgtSy2c(CDGhmuOdcMdkofBHx6ci8ZUmAK9jYX2jP44GAzzDLKBBzbMuQ)XTgR)AeRy1ygyXgKLfBNKId70ww1Nc(PBzj1RvoWKs9pU1y9xJW1bAzDLKBBzjF0fqXTgnzpEVCnUvSAmJHBdYYITtsXHDAlR6tb)0TSK61khysP(h3AS(Rr4ps0Z2CqWFWs14GfoiPETYbMuQ)XTgR)AeUoWdw4GG5GItXw4ljnf8Dj3MJTtsXHL1vsUTLT(RrkY8t0eR6pZwXQXmWQnill2ojfh2PTSQpf8t3Y6kjNJrSrIjAoiJeoyWhSWb1(GK61khysP(h3AS(Rr46apyHdsQxRCGjL6FCRX6VgH)irpBZbb)blvJdgk0bFphrCo2c3hddhdCAeZblCW3ZreNJTW9XWWFKONT5GG)GLQXbdf6G1SeKeFKONT5GG)GLQXb1YY6kj32Yw)1ifz(jAIv9NzRy1yw43gKLfBNKId70ww1Nc(PBzfNITWxsAk47sUnhBNKIJdw4GG5GK61khysP(h3AS(Rr46apyHdQ9b1(GK61kxVbTuMJg5XUuaX1bEWqHoiyo4aDbuuZolbj8xVX6(LiV6uk2r1RB8b(huRdw4GAFWbsQxR83dW9tfYnIR08GeoidoyOqhemhCGUakQzNLGe(R3yD)sK)EaUFQWdQ1b1YY6kj32Yw)1ifz(jAIv9NzRy1iyMydYYITtsXHDAlR6tb)0TSItXw4Kp6cO4wJMShVxUgNJTtsXXblCWxVtve4weF(aRPkLdY4bbhMCWch81B8Gms4Gm9GfoiPETYbMuQ)XTgR)AeUoWdgk0bbZbfNITWjF0fqXTgnzpEVCnohBNKIJdw4GVENQiWTi(8bwtvkhKrchmygyzDLKBBzbXmWvaHpXufb(ObBfAfRgbpZgKLfBNKId70ww1Nc(PBzj1RvoWKs9pU1y9xJW1bAzDLKBBzFpnyCG(WkwncoyBqwwSDskoStBzvFk4NUL1vsohJyJet0CqgjCWGpyHdQ9bbIcVe0Qt5ps0Z2CqWFWs14GHcDqX)su4sseJYghjEqWFWs14GAzzDLKBBznU6ZAQsNgb6kXkwncMP2GSSy7KuCyN2YQ(uWpDlRRKCogXgjMO5GmEqgCWqHo4R3yD)sKdee6)sCB0WX2jP4WY6kj32Yoqxaf9EehOYz2kwXYsUMOKknZU0gKvJz2GSSy7KuCyN2Y6kj32YUK0uW3f0YQywrXO4FjkgRgZSSQpf8t3Y(6DQIa3I4ZhynvPCqgjCqWctSSd0O(eOKBBzN(rxaDWTEq2ShVxUg)GmeLKZXdYqxXLCBRy1iyBqwwSDskoStBzvFk4NULvCk2cV0fq4NDz0i7tKJTtsXXbdf6GQTh6PWX54x)1iCSDskooyOqh81BSUFjYjtj7YOAPdo2ojfhhmuOd6kjNJrSrIjAoiJeoyWwwxj52w2hjUVbPOXelMTGVvSAWuBqwwSDskoStBzvFk4NULLuVw5Fse56apyHdQ9bF9ovrGBr85dSMQuoi4pidyWbdf6GVEJCjjIrzJm9GGNWblvJdgk0bnarknk(xIIHdAlsZUmssDJCqgjCWGpOwwwxj52wwqBrA2LrsQBeRy1aCSbzzX2jP4WoTL1vsUTLDjPPGVlOLv9PGF6w2xVrUKeXOSrW5GG)GLQXbdf6GVENQiWTi(8bwtvkhKrcheCyGLvXSIIrX)sumwnMzfRgmWgKLfBNKId70ww1Nc(PBzj1RvUMjLMDzKORaLnY1bEWch0aeP0O4FjkgE9xJyumlGWdYiHdg8blCqTpiyo4aDbu07rCGkNzUKknZU8GfoOANJT3cVZsqsS64bdf6GG5GQDo2El8olbjXQJhullRRKCBlB9xJyumlGqRy1aSydYYITtsXHDAlR6tb)0TSVENQiWTi(8bwtvkhKrcheCyYblCWxVrUKeXOSrMEqgpyPAyzDLKBBzbTFh3ASy2c(wXQbd3gKLfBNKId70ww1Nc(PBznarknk(xIIHx)1igfZci8Gms4GbFWchu7dsQxR8b6citCOJCJ4knpiHdcwpyOqhemhCGUak69ioqLZmxsLMzxEWqHoiyoOANJT3cVZsqsS64b1YY6kj32Yw)1igfZci0kwnaR2GSSy7KuCyN2Y6kj32YUK0uW3f0YQ(uWpDl7R3PkcClIpFG1uLYbz8GbZGdw4GVEJhKXdYulRIzffJI)LOySAmZkwnc)2GSSy7KuCyN2YQ(uWpDllPETY)KiY1bAzDLKBBzbTfPzxgjPUrSIvJzmXgKLfBNKId70ww1Nc(PBzF9ovrGBr85dSMQuoiJhKbmXY6kj32Y6VYBmk7)ylwXkw2bwDDQydYQXmBqwwxj52wwIzpI1hXaeTSy7KuCyN2kwnc2gKLfBNKId70wwxj52w2hjUVbPOXelMTGVLDGg1NaLCBlldbiqkZhm88Rroy4bNJFyhKONT4zFqWUI5dgKt32CqVhhutebEqgksCFdsrJ5GGnzl4FWFP0SlTSQpf8t3YQ2EONchNJF9xJWX2jP44GfoO4uSfEPlGWp7YOr2NihBNKIJdw4GG5GItXw4ljnf8Dj3MJTtsXXblCq1U0XwS5atk1)4wJ1Fnc)rIE2gRy1GP2GSSy7KuCyN2Y6kj32YcAlsZUmssDJyzhOr9jqj32YYqacKY8bdp)AKdgEW54FqVhhKONT4zFqWUI5dgKt32yzvFk4NULfmhCScV(RrIvCo(CjvAMD5blCqTpO4uSfEQqLdKJTtsXXbdf6GQDPJTyZjF0fqXTgnzpEVCno)rIE2MdY4bNXGdgk0bfNITWxsAk47sUnhBNKIJdw4GQDPJTyZbMuQ)XTgR)Ae(Je9SnhSWbbZbj1RvUMjLMDzKORaLnY1bEqTSIvdWXgKLfBNKId70ww1Nc(PBzj1RvEQyokoDBd)rIE2MdcEchSunoyHdsQxR8uXCuC62gUoWdw4GgGiLgf)lrXWlPUkDA0hZ9wHhKrchm4dw4GAFqWCqXPylCYhDbuCRrt2J3lxJZX2jP44GHcDq1U0XwS5Kp6cO4wJMShVxUgN)irpBZbz8GZyWb1YY6kj32YwsDv60OpM7TcTIvdgydYYITtsXHDAlR6tb)0TSK61kpvmhfNUTH)irpBZbbpHdwQghSWbj1RvEQyokoDBdxh4blCqTpiyoO4uSfo5JUakU1Oj7X7LRX5y7KuCCWqHoOAx6yl2CYhDbuCRrt2J3lxJZFKONT5GmEWzm4GAzzDLKBBzR)AKOr(ut0kwnal2GSSy7KuCyN2YoqJ6tGsUTLnqG21GhKHOKC7dstJCqzp4R3wwxj52wwLtPrxj52rAAellnnsSDIOLvTZX2BXyfRgmCBqwwSDskoStBzDLKBBzvoLgDLKBhPPrSS00iX2jIww1U0XwSnwXQby1gKLfBNKId70ww1Nc(PBzfNITWvlDebH(lCSDskooyHdsQxRC1shrqO)c3iUsZdYiHdoJjhSWb1(GdKuVw5VhG7NkKBexP5bjCqgCWqHoiyo4aDbuuZolbj8xVX6(Li)9aC)uHhullRRKCBlRYP0ORKC7innILLMgj2or0YQw6icc9xSIvJWVnill2ojfh2PTSQpf8t3YsQxRCYhDbuCRrt2J3lxJZ1bAzDLKBBzF9o6kj3ostJyzPPrITteTSKRjkPsZSlTIvJzmXgKLfBNKId70ww1Nc(PBzfNITWjF0fqXTgnzpEVCnohBNKIJdw4GAFq1U0XwS5Kp6cO4wJMShVxUgN)irpBZbb)bNXKdQLL1vsUTL917ORKC7innILLMgj2or0YsUMiWDPzxAfRgZMzdYYITtsXHDAlR6tb)0TSK61khysP(h3AS(Rr46apyHdkofBHVK0uW3LCBo2ojfhwwxj52w2xVJUsYTJ00iwwAAKy7erl7sstbFxYTTIvJzbBdYYITtsXHDAlR6tb)0TSItXw4ljnf8Dj3MJTtsXXblCq1U0XwS5atk1)4wJ1Fnc)rIE2Mdc(doJjwwxj52w2xVJUsYTJ00iwwAAKy7erl7sstbFxYTJa3LMDPvSAmJP2GSSy7KuCyN2YQ(uWpDlRRKCogXgjMO5Gms4GbBzDLKBBzF9o6kj3ostJyzPPrITteTS(IwXQXmWXgKLfBNKId70wwxj52wwLtPrxj52rAAellnnsSDIOL1iEp8FyfRyz9fTbz1yMnill2ojfh2PTSd0O(eOKBBzzil46bzOR4sUTL1vsUTL9rI7BqkAmXIzl4BfRgbBdYYITtsXHDAlR6tb)0TSItXw41FnIrXSac5y7KuCyzDLKBBzlPUkDA0hZ9wHwXQbtTbzzX2jP4WoTL1vsUTLT(RrIg5tnrlR6tb)0TSQDPJTyZFK4(gKIgtSy2c(8hj6zBoi4jCWGpi4(GLQXblCqXPyl8sxaHF2LrJSpro2ojfhwwfZkkgf)lrXy1yMvSAao2GSSy7KuCyN2YQ(uWpDllPETY)KiY1bAzDLKBBzbTfPzxgjPUrSIvdgydYYITtsXHDAlR6tb)0TSd0fqrVhXbQCM5sQ0m7Ydw4GQDo2El8olbjXQJhSWbj1Rv(aDbKjo0rUrCLMhKXdcwTSUsYTTSljnf8DbTIvdWInill2ojfh2PTSQpf8t3YsQxRCntkn7YirxbkBK)ORKdw4GAFqWCWb6cOO3J4avoZCjvAMD5blCq1ohBVfENLGKy1Xdgk0bbZbv7CS9w4DwcsIvhpOwwwxj52w26VgXOywaHwXQbd3gKLfBNKId70ww1Nc(PBzF9ovrGBr85dSMQuoi4pO2hCgdo4uhuCk2c)17ufDrWw3LCBo2ojfhheCFqMEqTSSUsYTTSLuxLon6J5ERqRy1aSAdYYITtsXHDAlRRKCBlB9xJenYNAIww1Nc(PBzF9ovrGBr85dSMQuoi4pO2hCgdo4uhuCk2c)17ufDrWw3LCBo2ojfhheCFqMEqTSSkMvumk(xIIXQXmRy1i8BdYYITtsXHDAlR6tb)0TSG5Gd0fqrVhXbQCM5sQ0m7Ydw4GQDo2El8olbjXQJhmuOdcMdQ25y7TW7SeKeRoAzDLKBBzR)AeJIzbeAfRgZyInill2ojfh2PTSUsYTTSljnf8DbTSQpf8t3Y(6DQIa3I4ZhynvPCqgpO2hmygCWPoO4uSf(R3Pk6IGTUl52CSDskooi4(Gm9GAzzvmROyu8VefJvJzwXQXSz2GSSUsYTTSLuxLon6J5ERqll2ojfh2PTIvJzbBdYYITtsXHDAlRRKCBlB9xJenYNAIwwfZkkgf)lrXy1yMvSAmJP2GSSUsYTTSG2VJBnwmBbFll2ojfh2PTIvJzGJnilRRKCBlR)kVXOS)JTyzX2jP4WoTvSIvSSZX3KBB1iyMe8mMmlygWNzzl6FNDPXYc2WqyOAa21GHnGh8Gbbcpyse4(YbR7FWjljnf8Dj3ocCxA2Lto4Jmm65JJdAwI4bDDzj6cooOcK3LOHFaeUSXdolGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1EwG1IFaeUSXdolGhmqBphFbhhCYR3yD)sKd4jhu2do51BSUFjYbmhBNKIJjhu7zbwl(bq4Ygp4SaEWaT9C8fCCWjQTh6PWb8Kdk7bNO2EONchWCSDskoMCqTNfyT4hahaGnmegQgGDnyyd4bpyqGWdMebUVCW6(hCIAPJii0FzYbFKHrpFCCqZsepORllrxWXbvG8Uen8dGWLnEWzb8GbA754l44GteNITWb8Kdk7bNiofBHdyo2ojfhtoO2ZcSw8dGWLnEWGd4bd02ZXxWXbNiofBHd4jhu2dorCk2chWCSDskoMCqTNfyT4haHlB8GmnGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1EwG1IFaeUSXdcob8GbA754l44GteNITWb8Kdk7bNiofBHdyo2ojfhtoO2ZcSw8dGdaWggcdvdWUgmSb8Ghmiq4btIa3xoyD)dozjPPGVl52to4Jmm65JJdAwI4bDDzj6cooOcK3LOHFaeUSXdolGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1EwG1IFaeUSXdolGhmqBphFbhhCYR3yD)sKd4jhu2do51BSUFjYbmhBNKIJjhu7zbwl(bq4Ygp4SaEWaT9C8fCCWjQTh6PWb8Kdk7bNO2EONchWCSDskoMCqTNfyT4haHlB8GGLaEWaT9C8fCCWjQTh6PWb8Kdk7bNO2EONchWCSDskoMCqTNfyT4haHlB8GH)aEWaT9C8fCCWjItXw4aEYbL9GteNITWbmhBNKIJjhu7GdSw8dGdaWggcdvdWUgmSb8Ghmiq4btIa3xoyD)doHCnrjvAMD5Kd(idJE(44GMLiEqxxwIUGJdQa5DjA4haHlB8GbhWdgOTNJVGJdorCk2chWtoOShCI4uSfoG5y7KuCm5GAplWAXpacx24bdoGhmqBphFbhhCYR3yD)sKd4jhu2do51BSUFjYbmhBNKIJjhu7zbwl(bq4YgpyWb8GbA754l44GtuBp0tHd4jhu2dorT9qpfoG5y7KuCm5GAplWAXpaoaaByimuna7AWWgWdEWGaHhmjcCF5G19p4eJ49W)XKd(idJE(44GMLiEqxxwIUGJdQa5DjA4haHlB8GZc4bd02ZXxWXbNiofBHd4jhu2dorCk2chWCSDskoMCqTNfyT4haHlB8GZc4bd02ZXxWXbN86nw3Ve5aEYbL9GtE9gR7xICaZX2jP4yYbD5GGRH3WDqTNfyT4haHlB8GZc4bd02ZXxWXbNO2EONchWtoOShCIA7HEkCaZX2jP4yYb1EwG1IFaeUSXdY0aEWaT9C8fCCWjItXw4aEYbL9GteNITWbmhBNKIJjh0LdcUgEd3b1EwG1IFaeUSXdcob8GbA754l44GtuBp0tHd4jhu2dorT9qpfoG5y7KuCm5GAhCG1IFaeUSXdcwc4bd02ZXxWXbNiofBHd4jhu2dorCk2chWCSDskoMCqTNfyT4haHlB8Gm8aEWaT9C8fCCWjItXw4aEYbL9GteNITWbmhBNKIJjhu7zbwl(bq4YgpiynGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1EwG1IFaCaa2WqyOAa21GHnGh8Gbbcpyse4(YbR7FWjKRjcCxA2Lto4Jmm65JJdAwI4bDDzj6cooOcK3LOHFaeUSXdgCapyG2Eo(coo4eXPylCap5GYEWjItXw4aMJTtsXXKdQ9SaRf)aiCzJhm4aEWaT9C8fCCWjVEJ19lroGNCqzp4KxVX6(LihWCSDskoMCqTNfyT4haHlB8GbhWdgOTNJVGJdorT9qpfoGNCqzp4e12d9u4aMJTtsXXKdQ9SaRf)aiCzJheSeWdgOTNJVGJdorCk2chWtoOShCI4uSfoG5y7KuCm5GAplWAXpacx24bz4b8GbA754l44GteNITWb8Kdk7bNiofBHdyo2ojfhtoO2ZcSw8dGWLnEqWAapyG2Eo(coo4eXPylCap5GYEWjItXw4aMJTtsXXKdQ9SaRf)a4aaSHHWq1aSRbdBap4bdceEWKiW9Ldw3)Gtu7shBX2m5GpYWONpooOzjIh01LLOl44GkqExIg(bq4Ygp4mMeWdgOTNJVGJdorCk2chWtoOShCI4uSfoG5y7KuCm5GAplWAXpacx24bNnlGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1EwG1IFaeUSXdol4aEWaT9C8fCCWjItXw4aEYbL9GteNITWbmhBNKIJjhu7zbwl(bq4Ygp4mMgWdgOTNJVGJdorCk2chWtoOShCI4uSfoG5y7KuCm5GAplWAXpacx24bNbob8GbA754l44GteNITWb8Kdk7bNiofBHdyo2ojfhtoO2ZcSw8dGWLnEWzmiGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1EwG1IFaeUSXdoJHhWdgOTNJVGJdorCk2chWtoOShCI4uSfoG5y7KuCm5GUCqW1WB4oO2ZcSw8dGWLnEWzH)aEWaT9C8fCCWjItXw4aEYbL9GteNITWbmhBNKIJjhu7zbwl(bq4YgpyWmjGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1o4aRf)aiCzJhmyMgWdgOTNJVGJdo51BSUFjYb8Kdk7bN86nw3Ve5aMJTtsXXKd6YbbxdVH7GAplWAXpaoaaByimuna7AWWgWdEWGaHhmjcCF5G19p4e1ohBVfZKd(idJE(44GMLiEqxxwIUGJdQa5DjA4haHlB8GbhWdgOTNJVGJdorCk2chWtoOShCI4uSfoG5y7KuCm5GAplWAXpacx24bzAapyG2Eo(coo4eXPylCap5GYEWjItXw4aMJTtsXXKd6YbbxdVH7GAplWAXpacx24bbNaEWaT9C8fCCWjItXw4aEYbL9GteNITWbmhBNKIJjhu7zbwl(bWbayddHHQbyxdg2aEWdgei8GjrG7lhSU)bNmWQRtLjh8rgg98XXbnlr8GUUSeDbhhubY7s0Wpacx24bdoGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1o4aRf)aiCzJhm4aEWaT9C8fCCWjQTh6PWb8Kdk7bNO2EONchWCSDskoMCqTNfyT4haHlB8GmnGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1o4aRf)aiCzJheCc4bd02ZXxWXbNiofBHd4jhu2dorCk2chWCSDskoMCqTNfyT4haHlB8GmiGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1EwG1IFaeUSXdcwd4bd02ZXxWXbNiofBHd4jhu2dorCk2chWCSDskoMCqTNfyT4haHlB8GZysapyG2Eo(coo4eXPylCap5GYEWjItXw4aMJTtsXXKdQ9SaRf)aiCzJhC2SaEWaT9C8fCCWjItXw4aEYbL9GteNITWbmhBNKIJjh0LdcUgEd3b1EwG1IFaeUSXdol4aEWaT9C8fCCWjItXw4aEYbL9GteNITWbmhBNKIJjhu7zbwl(bWbayddHHQbyxdg2aEWdgei8GjrG7lhSU)bN4lo5GpYWONpooOzjIh01LLOl44GkqExIg(bq4YgpyWb8GbA754l44GteNITWb8Kdk7bNiofBHdyo2ojfhtoOlheCn8gUdQ9SaRf)aiCzJhKPb8GbA754l44GteNITWb8Kdk7bNiofBHdyo2ojfhtoOlheCn8gUdQ9SaRf)aiCzJhKHhWdgOTNJVGJdorCk2chWtoOShCI4uSfoG5y7KuCm5GAplWAXpacx24bbRb8GbA754l44GteNITWb8Kdk7bNiofBHdyo2ojfhtoO2ZcSw8dGWLnEWzmjGhmqBphFbhhCI4uSfoGNCqzp4eXPylCaZX2jP4yYb1EwG1IFaCaa2jcCFbhhCgtoORKC7dstJy4hawwdquz1iygmZYc83AsrlBaeaheCj6cOdg(UZsqYbdp)AKdGaiaoy4bjFD)z(GZyAyhmyMe8SdGdGaiaoyGa5DjAoacGa4GGloidfjUZXXbPUraxyq12JdQB8s8GB9GbcKNT5GB9GGDfEq3CWuo4yrtproiqQZ8blIu6bZ(GaFxjPc5hahabqaCqW1aJkDbhheNJpZhusI4bfq4bDLS)btZb95EsDskYpaCLKBBiqm7rS(igG4bqaCqgcqGuMpy45xJCWWdoh)WoirpBXZ(GGDfZhmiNUT5GEpoOMic8GmuK4(gKIgZbbBYwW)G)sPzxEa4kj32mfba9iX9nifnMyXSf8dlReuBp0tHJZXV(RrkiofBHx6ci8ZUmAK9jwamItXw4ljnf8Dj3UGAx6yl2CGjL6FCRX6VgH)irpBZbqaCqgcqGuMpy45xJCWWdoh)d694Ge9Sfp7dc2vmFWGC62Mdaxj52MPiaiqBrA2LrsQBKWYkbWmwHx)1iXkohFUKknZUSG2ItXw4PcvoWqHu7shBXMt(OlGIBnAYE8E5AC(Je9SnmoJbHcjofBHVK0uW3LC7cQDPJTyZbMuQ)XTgR)Ae(Je9SnfadPETY1mP0SlJeDfOSrUoqToaCLKBBMIaGkPUkDA0hZ9wHHLvcK61kpvmhfNUTH)irpBd4juQgfi1RvEQyokoDBdxhybdqKsJI)LOy4LuxLon6J5ERqgjeCbTbJ4uSfo5JUakU1Oj7X7LRXdfsTlDSfBo5JUakU1Oj7X7LRX5ps0Z2W4mgO1bGRKCBZueau9xJenYNAIHLvcK61kpvmhfNUTH)irpBd4juQgfi1RvEQyokoDBdxhybTbJ4uSfo5JUakU1Oj7X7LRXdfsTlDSfBo5JUakU1Oj7X7LRX5ps0Z2W4mgO1bqaCWabAxdEqgIsYTpinnYbL9GVEFa4kj32mfbaPCkn6kj3ostJew7ercQDo2ElMdaxj52MPiaiLtPrxj52rAAKWANisqTlDSfBZbGRKCBZueaKYP0ORKC7innsyTtejOw6icc9xclReeNITWvlDebH(lfi1RvUAPJii0FHBexPjJeMXKcApqs9AL)EaUFQqUrCLMeyqOqGzGUakQzNLGe(R3yD)sK)EaUFQqToaCLKBBMIaGE9o6kj3ostJew7ercKRjkPsZSldlRei1Rvo5JUakU1Oj7X7LRX56apaCLKBBMIaGE9o6kj3ostJew7ercKRjcCxA2LHLvcItXw4Kp6cO4wJMShVxUgVG2QDPJTyZjF0fqXTgnzpEVCno)rIE2gWpJjADa4kj32mfba96D0vsUDKMgjS2jIewsAk47sUDyzLaPETYbMuQ)XTgR)AeUoWcItXw4ljnf8Dj3(aWvsUTzkca617ORKC7innsyTtejSK0uW3LC7iWDPzxgwwjiofBHVK0uW3LC7cQDPJTyZbMuQ)XTgR)Ae(Je9SnGFgtoaCLKBBMIaGE9o6kj3ostJew7erc(IHLvcUsY5yeBKyIggje8bGRKCBZueaKYP0ORKC7innsyTtejyeVh(poaoacGdYqwW1dYqxXLC7daxj52gUViHhjUVbPOXelMTG)bGRKCBd3xCkcaQK6Q0PrFm3BfgwwjiofBHx)1igfZci8aWvsUTH7lofbav)1irJ8PMyykMvumk(xIIHWSWYkb1U0XwS5psCFdsrJjwmBbF(Je9SnGNqWG7s1OG4uSfEPlGWp7YOr2N4bGRKCBd3xCkcac0wKMDzKK6gjSSsGuVw5Fse56apaCLKBB4(Itraqljnf8DbdlRegOlGIEpIdu5mZLuPz2Lfu7CS9w4DwcsIvhlqQxR8b6citCOJCJ4knzeSEa4kj32W9fNIaGQ)AeJIzbegwwjqQxRCntkn7YirxbkBK)ORKcAdMb6cOO3J4avoZCjvAMDzb1ohBVfENLGKy1XqHaJANJT3cVZsqsS6OwhaUsYTnCFXPiaOsQRsNg9XCVvyyzLWR3PkcClIpFG1uLc41EgdMsCk2c)17ufDrWw3LCBWnt16aWvsUTH7lofbav)1irJ8PMyykMvumk(xIIHWSWYkHxVtve4weF(aRPkfWR9mgmL4uSf(R3Pk6IGTUl52GBMQ1bGRKCBd3xCkcaQ(RrmkMfqyyzLaygOlGIEpIdu5mZLuPz2Lfu7CS9w4DwcsIvhdfcmQDo2El8olbjXQJhaUsYTnCFXPiaOLKMc(UGHPywrXO4FjkgcZclReE9ovrGBr85dSMQuyu7GzWuItXw4VENQOlc26UKBdUzQwhaUsYTnCFXPiaOsQRsNg9XCVv4bGRKCBd3xCkcaQ(RrIg5tnXWumROyu8VefdHzhaUsYTnCFXPiaiq73XTglMTG)bGRKCBd3xCkcaYFL3yu2)XwoaoacGdo9JUa6GB9GSzpEVCn(bbUln7Yd(R4sU9bd4bnI)I5GZyI5GKyDF8GtVShmnh0N7j1jP4bGRKCBdNCnrG7sZUKaOTin7Yij1nsyzLaPETY)KiY1bEa4kj32Wjxte4U0SlNIaGEK4(gKIgtSy2c(HLvcUsY5yeBKyIggjeCOqVEJCjjIrzJma8ekvJcAlofBHx6ci8ZUmAK9jgkKA7HEkCCo(1FnsOqVEJ19lrozkzxgvlDO1bqaCWjI)LOeZkbIEGdO2dKuVw5VhG7NkKBexP5uZ0k8bThiPETYFpa3pvi)rIE2MPMPf4EGUakQzNLGe(R3yD)sK)EaUFQWjhKHIarxmh0piDLWoOaknhmnhmBb7booOShu8VeLdkGWdcklbHg5Ga)C)uy(GyJez(Gftb0b9(GozstH5dkGC5Gftk9GoqGuMp47b4(Pcpywp4R3yD)sCWpyqGC5GKy2Lh07dInsK5dwmfqhKjh0iUsttyhC)d69bXgjY8bfqUCqbeEWbsQxRhSysPh0SBFqmWaZhp428daxj52go5AIa3LMD5uea0sstbFxWWumROyu8VefdHzHLvcVENQiWTi(8bwtvkmsiygCa4kj32Wjxte4U0SlNIaGkPUkDA0hZ9wHHLvcVENQiWTi(8bwtvkGpyMuWaeP0O4FjkgEj1vPtJ(yU3kKrcbxqTlDSfBoWKs9pU1y9xJWFKONTHrgCa4kj32Wjxte4U0SlNIaGQ)AKOr(utmmfZkkgf)lrXqywyzLWR3PkcClIpFG1uLc4dMjfu7shBXMdmPu)JBnw)1i8hj6zByKbhaUsYTnCY1ebUln7YPiaO6VgXOywaHHLvcK61kxZKsZUms0vGYg5p6kPWR3PkcClIpFG1uLcJApJbtjofBH)6DQIUiyR7sUn4MPAvWaeP0O4FjkgE9xJyumlGqgjeCbTj1Rv(aDbKjo0rUrCLMeaRHcbMb6cOO3J4avoZCjvAMDzOqGrTZX2BH3zjijwDuRdaxj52go5AIa3LMD5ueau9xJyumlGWWYkHxVtve4weF(aRPkfgjOntzWuItXw4VENQOlc26UKBdUzQwfmarknk(xIIHx)1igfZciKrcbxqBs9ALpqxazIdDKBexPjbWAOqGzGUak69ioqLZmxsLMzxgkeyu7CS9w4DwcsIvh16aWvsUTHtUMiWDPzxofbaTK0uW3fmmfZkkgf)lrXqywyzLWR3PkcClIpFG1uLcJe0MPmykXPyl8xVtv0fbBDxYTb3mvRdaxj52go5AIa3LMD5ueauj1vPtJ(yU3kmSSsqTlDSfBoWKs9pU1y9xJWFKONTHXxVrUKeXOSrWPWR3PkcClIpFG1uLc4bhMuWaeP0O4FjkgEj1vPtJ(yU3kKrcbFa4kj32Wjxte4U0SlNIaGQ)AKOr(utmmfZkkgf)lrXqywyzLGAx6yl2CGjL6FCRX6VgH)irpBdJVEJCjjIrzJGtHxVtve4weF(aRPkfWdom5a4aiao40p6cOdU1dYM949Y14hKHOKCoEqg6kUKBFa4kj32WjxtusLMzxsyjPPGVlyykMvumk(xIIHWSWYkHxVtve4weF(aRPkfgjawyYbGRKCBdNCnrjvAMD5uea0Je33Gu0yIfZwWpSSsqCk2cV0fq4NDz0i7tmui12d9u44C8R)AKqHE9gR7xICYuYUmQw6iuixj5CmInsmrdJec(aWvsUTHtUMOKknZUCkcac0wKMDzKK6gjSSsGuVw5Fse56alO9R3PkcClIpFG1uLc4zadcf61BKljrmkBKPGNqPAekKbisPrX)sumCqBrA2LrsQBegjeSwhaUsYTnCY1eLuPz2Ltraqljnf8DbdtXSIIrX)sumeMfwwj86nYLKigLncoGVuncf617ufbUfXNpWAQsHrcGddoaCLKBB4KRjkPsZSlNIaGQ)AeJIzbegwwjqQxRCntkn7YirxbkBKRdSGbisPrX)sum86VgXOywaHmsi4cAdMb6cOO3J4avoZCjvAMDzb1ohBVfENLGKy1XqHaJANJT3cVZsqsS6OwhaUsYTnCY1eLuPz2LtraqG2VJBnwmBb)WYkHxVtve4weF(aRPkfgjaomPWR3ixsIyu2itzSunoaCLKBB4KRjkPsZSlNIaGQ)AeJIzbegwwjyaIuAu8VefdV(RrmkMfqiJecUG2K61kFGUaYeh6i3iUstcG1qHaZaDbu07rCGkNzUKknZUmuiWO25y7TW7SeKeRoQ1bGRKCBdNCnrjvAMD5uea0sstbFxWWumROyu8VefdHzHLvcVENQiWTi(8bwtvkmgmdk86nYitpaCLKBB4KRjkPsZSlNIaGaTfPzxgjPUrclRei1Rv(NerUoWdaxj52go5AIsQ0m7YPiai)vEJrz)hBjSSs417ufbUfXNpWAQsHrgWKdGdGaiaoyGw64GHVq)LdgOThPKBBoacGa4GUsYTnC1shrqO)cbfipBtCRXuHHLvc1SeKeFKONTb8LQXbqaCWWNg8Gd9p7Ydc2MuQ)hSykGoiyxHkhiGM(rxaDa4kj32WvlDebH(ltraqkqE2M4wJPcdlReaJ4uSf(sstbFxYTlqQxRCGjL6FCRX6VgH)irpBd4zAbs9ALdmPu)JBnw)1iCDGfi1RvUAPJii0FHBexPjJeMXKdGa4GHxDXKd8GB9GGTjL6)b1nOxIhSykGoiyxHkhiGM(rxaDa4kj32WvlDebH(ltraqkqE2M4wJPcdlReaJ4uSf(sstbFxYTlmqxaf1SZsqc)1BSUFjYRoLIDu96gFGFbWqQxRCGjL6FCRX6VgHRdSG2K61kxT0ree6VWnIR0KrcZalfi1RvUEdAPmhnYJDPaIRdmuis9ALRw6icc9x4gXvAYiHzH)cQDPJTyZbMuQ)XTgR)Ae(Je9SnmoJjADa4kj32WvlDebH(ltraqkqE2M4wJPcdlReaJ4uSf(sstbFxYTlaMb6cOOMDwcs4VEJ19lrE1PuSJQx34d8lqQxRC1shrqO)c3iUstgjmJjfadPETYbMuQ)XTgR)AeUoWcQDPJTyZbMuQ)XTgR)Ae(Je9SnmgmtoacGdc2(4CSLdgOLooy4l0F5G7C8voqGzxEWH(ND5bbMuQ)haUsYTnC1shrqO)YueaKcKNTjU1yQWWYkbXPyl8LKMc(UKBxamK61khysP(h3AS(Rr46alOnPETYvlDebH(lCJ4knzKWmWsbs9ALR3GwkZrJ8yxkG46adfIuVw5QLoIGq)fUrCLMmsyw4pui1U0XwS5atk1)4wJ1Fnc)rIE2gWZ0cK61kxT0ree6VWnIR0KrcZahToaoacGdgE7dg(0GheSlirtyheSDLC7d694GmuxLo1Ca4kj32Wv7shBX2qq3GXuqIMWYkb1U0XwS5atk1)4wJ1Fnc)rFWCOqQDPJTyZbMuQ)XTgR)Ae(Je9SnmgmtoaCLKBB4QDPJTyBMIaGaUsUDyzLaPETYbMuQ)XTgR)AeUoWcK61khjcClIF81BmweDGBZ1bEa4kj32Wv7shBX2mfbars3DeR6pZHLvcK61khysP(h3AS(Rr46alqQxRCKiWTi(XxVXyr0bUnxh4bGRKCBdxTlDSfBZueaej(g81m7YWYkbs9ALdmPu)JBnw)1iCDGhaUsYTnC1U0XwSntraq(R8gJa1PgmSSsqBWqQxRCGjL6FCRX6VgHRdSGRKCogXgjMOHrcbRvOqGHuVw5atk1)4wJ1FncxhybTF9g5dSMQuyKadk86DQIa3I4ZhynvPWibWct06aWvsUTHR2Lo2ITzkcaIMLGetm8r9rjrSLWYkbs9ALdmPu)JBnw)1iCDGhaUsYTnC1U0XwSntraqERqJ8onQCknSSsGuVw5atk1)4wJ1Fncxhybs9ALJebUfXp(6nglIoWT56apaCLKBB4QDPJTyBMIaGQ5JK0DhHLvcK61khysP(h3AS(Rr4ps0Z2aEcG1cK61khjcClIF81BmweDGBZ1bEa4kj32Wv7shBX2mfbar6LXTgLpvAAclRei1RvoWKs9pU1y9xJW1bwWvsohJyJet0qywbTj1RvoWKs9pU1y9xJWFKONTb8mOG4uSfUAPJii0FHJTtsXrOqGrCk2cxT0ree6VWX2jP4OaPETYbMuQ)XTgR)Ae(Je9SnGNPADaeahmq7shBX2Ca4kj32Wv7shBX2mfbaHebUfXp(6nglIoWTdlReeNITWxsAk47sUDbTv7shBXMdmPu)JBnw)1i8h9bZfE9g5sseJYgzaJLQrHxVtve4weF(aRPkfgjmJjHcrQxRCGjL6FCRX6VgHRdSWR3ixsIyu2idySun0kuOAwcsIps0Z2a(GzYbGRKCBdxTlDSfBZueaese4we)4R3ySi6a3oSSsqCk2cN8rxaf3A0K949Y14fE9ovrGBr85dSMQuyeCysHxVrUKeXOSrgWyPAuqBs9ALt(OlGIBnAYE8E5ACUoWqHQzjij(irpBd4dMjADa4kj32Wv7shBX2mfbaHebUfXp(6nglIoWTdlReeNITWtfQCGfE9gbptpaCLKBB4QDPJTyBMIaGaMuQ)XTgR)AKWYkbXPylCYhDbuCRrt2J3lxJxqB1U0XwS5Kp6cO4wJMShVxUgN)irpBtOqQDPJTyZjF0fqXTgnzpEVCno)rFWCHxVtve4weF(aRPkfWdwyIwhaUsYTnC1U0XwSntraqatk1)4wJ1FnsyzLG4uSfEQqLdSayi1RvoWKs9pU1y9xJW1bEa4kj32Wv7shBX2mfbabmPu)JBnw)1iHLvcItXw4ljnf8Dj3UG2ItXw4LUac)SlJgzFICSDskokqQxR8hjUVbPOXelMTGpxhyOqGrCk2cV0fq4NDz0i7tKJTtsXHwhaUsYTnC1U0XwSntraqKp6cO4wJMShVxUgpSSsGuVw5atk1)4wJ1Fncxh4bGRKCBdxTlDSfBZueau9xJuK5NOjw1FMdlRei1RvoWKs9pU1y9xJWFKONTb8LQrbs9ALdmPu)JBnw)1iCDGfaJ4uSf(sstbFxYTpaCLKBB4QDPJTyBMIaGQ)AKIm)enXQ(ZCyzLGRKCogXgjMOHrcbxqBs9ALdmPu)JBnw)1iCDGfi1RvoWKs9pU1y9xJWFKONTb8LQrOqVNJiohBH7JHHJbonIPW75iIZXw4(yy4ps0Z2a(s1iuOAwcsIps0Z2a(s1qRdaxj52gUAx6yl2MPiaO6VgPiZprtSQ)mhwwjiofBHVK0uW3LC7cGHuVw5atk1)4wJ1FncxhybT1MuVw56nOLYC0ip2LciUoWqHaZaDbuuZolbj8xVX6(LiV6uk2r1RB8b(Avq7bsQxR83dW9tfYnIR0Kadcfcmd0fqrn7SeKWF9gR7xI83dW9tfQLwhaUsYTnC1U0XwSntraqGyg4kGWNyQIaF0GTcdlReeNITWjF0fqXTgnzpEVCnEHxVtve4weF(aRPkfgbhMu41BKrcmTaPETYbMuQ)XTgR)AeUoWqHaJ4uSfo5JUakU1Oj7X7LRXl86DQIa3I4ZhynvPWiHGzWbGRKCBdxTlDSfBZuea07PbJd0hHLvcK61khysP(h3AS(Rr46apaCLKBB4QDPJTyBMIaGmU6ZAQsNgb6kjSSsWvsohJyJet0WiHGlOnqu4LGwDk)rIE2gWxQgHcj(xIcxsIyu24irWxQgADa4kj32Wv7shBX2mfbanqxaf9EehOYzoSSsWvsohJyJet0Widcf61BSUFjYbcc9FjUnAoaoacGdgODo2ElhKHqM0us0Ca4kj32Wv7CS9wmegOlGmXHogwwj8EoI4CSfUpggE2moJbHcbM3ZreNJTW9XWWXaNgXekKRKCogXgjMOHrcbFa4kj32Wv7CS9wmtraqMI(tm7YiX0iHLvcUsY5yeBKyIgcZk86DQIa3I4ZhynvPWitlO2Lo2InhysP(h3AS(Rr4ps0Z2aEMwamItXw4Kp6cO4wJMShVxUgVG2G59CeX5ylCFmmCmWPrmHc9EoI4CSfUpggE2moJbADa4kj32Wv7CS9wmtraqMI(tm7YiX0iHLvcUsY5yeBKyIggjeCbWiofBHt(OlGIBnAYE8E5A8daxj52gUANJT3IzkcaYu0FIzxgjMgjSSsqCk2cN8rxaf3A0K949Y14f0MuVw5Kp6cO4wJMShVxUgNRdSG2UsY5yeBKyIgcZk86DQIa3I4ZhynvPWi4WKqHCLKZXi2iXenmsi4cVENQiWTi(8bwtvkmcwyIwHcbgs9ALt(OlGIBnAYE8E5ACUoWcQDPJTyZjF0fqXTgnzpEVCno)rIE2gToaCLKBB4QDo2ElMPiaiNCjMTl52rAsKmSSsWvsohJyJet0qywb1U0XwS5atk1)4wJ1Fnc)rIE2gWZ0cAdM3ZreNJTW9XWWXaNgXek075iIZXw4(yy4zZ4mgO1bGRKCBdxTZX2BXmfba5KlXSDj3ostIKHLvcUsY5yeBKyIggje8bGRKCBdxTZX2BXmfbaza5knPyuaHr9U4(ciMdlReCLKZXi2iXeneMvqTlDSfBoWKs9pU1y9xJWFKONTb8mTG2G59CeX5ylCFmmCmWPrmHc9EoI4CSfUpggE2moJbADa4kj32Wv7CS9wmtraqgqUstkgfqyuVlUVaI5WYkbxj5CmInsmrdJec(a4aiaoy4LKMc(UKBFWFfxYTpaCLKBB4ljnf8Dj3MWJe33Gu0yIfZwWpSSsWvsohJyJet0WibMwqBXPyl8sxaHF2LrJSpXqHuBp0tHJZXV(Rrcf61BSUFjYjtj7YOAPdToaCLKBB4ljnf8Dj3Ekcac0wKMDzKK6gjSSsamJv41FnsSIZXNlPsZSllags9ALRzsPzxgj6kqzJCDGhaUsYTn8LKMc(UKBpfbav)1igfZcimSSsGuVw5AMuA2LrIUcu2i)rxjfmarknk(xIIHx)1igfZciKrcbxqBs9ALpqxazIdDKBexPjbWAOqGzGUak69ioqLZmxsLMzxgkeyu7CS9w4DwcsIvh16aWvsUTHVK0uW3LC7PiaOLKMc(UGHPywrXO4FjkgcZclRei1RvUMjLMDzKORaLnYF0vsOqGHuVw5Fse56alyaIuAu8Vefdh0wKMDzKK6gHrcm9aWvsUTHVK0uW3LC7PiaOsQRsNg9XCVvyyzLGbisPrX)sum8sQRsNg9XCVviJecUG2VENQiWTi(8bwtvkGFgtcf61BKljrmkBmyglvdTcfs7bsQxR83dW9tfYnIR0e8miuObsQxR83dW9tfYFKONTb8ZyGwhaUsYTn8LKMc(UKBpfbav)1irJ8PMyyzLGA7HEkC89rQCj7YijDlwGuVw547Ju5s2Lrs6wKBexPjHGl4kjNJrSrIjAim7aWvsUTHVK0uW3LC7PiaiqBrA2LrsQBKWYkbs9AL)jrKRdSGbisPrX)sumCqBrA2LrsQBegje8bGRKCBdFjPPGVl52traqLuxLon6J5ERWWYkbdqKsJI)LOy4LuxLon6J5ERqgje8bGRKCBdFjPPGVl52traq1Fns0iFQjgMIzffJI)LOyimlSSsamItXw4(CN6TcewamK61kxZKsZUms0vGYg56adfsCk2c3N7uVvGWcGHuVw5Fse56apaCLKBB4ljnf8Dj3Ekcac0wKMDzKK6gjSSsGuVw5Fse56apaCLKBB4ljnf8Dj3EkcaAjPPGVlyykMvumk(xIIHWSdGdGa4GGT7sZU8GHN9py4LKMc(UKBhWdYk(lMdoJjh0GQThMdsI19Xdc2MuQ)hCRhm88RroOAjIMdU16bde4Ydaxj52g(sstbFxYTJa3LMDjHhjUVbPOXelMTGFyzLG4uSfEPlGWp7YOr2NyOqQTh6PWX54x)1iHc96nw3Ve5KPKDzuT0rOqUsY5yeBKyIggje8bGRKCBdFjPPGVl52rG7sZUCkcac0wKMDzKK6gjSSsGuVw5Fse56apaCLKBB4ljnf8Dj3ocCxA2Ltraqljnf8DbdtXSIIrX)sumeMfwwjqQxRCntkn7YirxbkBK)ORKdaxj52g(sstbFxYTJa3LMD5ueauj1vPtJ(yU3kmSSsWaeP0O4FjkgEj1vPtJ(yU3kKrcbx417ufbUfXNpWAQsb8GfMCa4kj32WxsAk47sUDe4U0SlNIaGQ)AKOr(utmmfZkkgf)lrXqywyzLWR3PkcClIpFG1uLc4z4m5aWvsUTHVK0uW3LC7iWDPzxofbaTK0uW3fmmfZkkgf)lrXqywyzLWR3iJGZbGRKCBdFjPPGVl52rG7sZUCkcaQ(RrmkMfqyyzLGRKCogXgjMOHrcGtbTbZaDbu07rCGkNzUKknZUSGANJT3cVZsqsS6yOqGrTZX2BH3zjijwDuRdGdGa4GSI3d)hh0KDjfbxi(xIYb)vCj3(aWvsUTHBeVh(pi8iX9nifnMyXSf8dlReeNITWlDbe(zxgnY(edfsT9qpfooh)6VgjuOxVX6(LiNmLSlJQLooaCLKBB4gX7H)JPiaOsQRsNg9XCVvyyzLaygOlGIA2zjiH)6nw3Ve5VhG7NkSG2dKuVw5VhG7NkKBexPj4zqOqdKuVw5VhG7NkK)irpBd4z4ADa4kj32WnI3d)htraq1Fns0iFQjgwwjO2Lo2In)rI7BqkAmXIzl4ZFKONTb8ecgCxQgfeNITWlDbe(zxgnY(epaCLKBB4gX7H)JPiaO6VgjAKp1edlReuBp0tHJVpsLlzxgjPBXcK61khFFKkxYUmss3ICJ4knjeCOqQTh6PW1Bk6gq4iwFSdqMlqQxRC9MIUbeoI1h7aKz(Je9SnGNPfi1RvUEtr3achX6JDaYmxh4bGRKCBd3iEp8FmfbabAlsZUmssDJewwjqQxR8pjICDGhaUsYTnCJ49W)Xuea0sstbFxWWYkbWqQxR86Vbi2rG6udY1bwqCk2cV(BaIDeOo1GHcrQxRCntkn7YirxbkBK)ORKqHgOlGIEpIdu5mZLuPz2Lfu7CS9w4DwcsIvhlqQxR8b6citCOJCJ4knzeSgk0R3ixsIyu2i4aEcLQXbGRKCBd3iEp8Fmfbav)1irJ8PMyyzLWR3PkcClIpFG1uLc41EgdMsCk2c)17ufDrWw3LCBWnt16aWvsUTHBeVh(pMIaGwsAk47cgwwj86DQIa3I4ZhynvPWO2bZGPeNITWF9ovrxeS1Dj3gCZuToaCLKBB4gX7H)JPiaO6VgjAKp1epaCLKBB4gX7H)JPiaiq73XTglMTG)bGRKCBd3iEp8Fmfba5VYBmk7)ylwXkwla]] )

end
