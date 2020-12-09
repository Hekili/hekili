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


    spec:RegisterPack( "Frost DK", 20201209, [[d4K(dcqiGIhHiIlbuvk2Ke6tkWOikofIQvbuv9kjOzrL0TaQkL2fQ(LcQHHiCmfYYOs8mIsMgqvUgqLTbG03qevJdavNdrKwhrPMhqP7bK9HiDqaewOcYdLanrau0fbQk2iak8rerXiPcjPtsfsTsfQxsfsQzkbSteLFcGsdfOQKLcGONIutLOYvbQkvFfruASaWEP4Vu1GbDyHfJKhtyYk6YqBwsFwIgncoTOvtfsIxtu1Sr52i0UL63knCaDCQqILRQNtPPt66ez7a03PsnEQqDEQG1tfI5tfTFv2mYiNHEgkAiZfs4cjg5cjiPCsqsL1iWbWn0QdardnWqiFuIg6oiIgAag)A1dcW0rTHgy4aBJProdTDLEbAOjOkqRShE4YujirXflXHTjrjwO52IpQ6W2KOyydnLuYuhDBOm0ZqrdzUqcxiXixibjLtcsQSgbosUHoKuc7BOPtIf0qtiNtSnug6jAfgAsYbbyIHs4GoQ7SKGEqag)A1Bmj5GamrbsKc)dssD9GUqcxiHHMLw1AKZqVuSuXp0CBpWDzzxAKZq2iJCgASdkgondzOfFQ4NHHwdg2kVmuc4NDP3Q7tKJDqXW5bD68GITNsPYraXV(Rv5yhumCEqNop4l1yD)sKtLA2LEXYMCSdkgopOtNhmeAci6XgjMO9GKc6GUyOdHMBBOFK4(wKHwR3D2k(g1qMlg5m0yhumCAgYql(uXpddnLuTY)KiYLaAOdHMBBOjSUzzx6PyHvnQHmzzKZqJDqXWPzidDi0CBd9sXsf)qrdT4tf)mm0us1kx(KXYU0tmeeYg5pgc1qlCqWqVgFjQwdzJmQHmWZiNHg7GIHtZqgAXNk(zyOTargZRXxIQLxYcrgmFmbmAbEqsbDqxoyXd(sDk8ax34ZNynfPEqWEqakjm0HqZTn0LSqKbZhtaJwGg1qg4mYzOXoOy40mKHoeAUTHU(Rv9w9t5rdT4tf)mm0VuNcpW1n(8jwtrQheShKKtcdTWbbd9A8LOAnKnYOgYaOg5m0yhumCAgYqhcn32qVuSuXpu0ql(uXpdd9l14bj9GGNHw4GGHEn(suTgYgzudzKCJCgASdkgondzOfFQ4NHHoeAci6XgjMO9GKc6GG3blEqzoiyo4edLGp6PFIIWbUMc5ZU8GfpOybe7OvENLeuFnWd605bbZbflGyhTY7SKG6RbEqYn0HqZTn01FTQv4GsanQrn0ILn9eW4vJCgYgzKZqJDqXWPzidT4tf)mm01SKG6FKyKT9GG9GLIPHoeAUTHwqiY263QpfOrnK5Irodn2bfdNMHm0Ipv8ZWqdMdQbdBLVuSuXp0CBo2bfdNhS4bPKQvoWKXI3VvF9xRYFKyKT9GG9GY6GfpiLuTYbMmw8(T6R)AvUeWdw8Gus1kxSSPNagVYTAiK)GKc6GJiHHoeAUTHwqiY263QpfOrnKjlJCgASdkgondzOfFQ4NHHgmhudg2kFPyPIFO52CSdkgopyXdoXqj4LVZsck)LASUFjYRbJHTx8s2yI)blEqzoiLuTYflB6jGXRCRgc5piPGo4ia6blEqkPALl1ewMdER(yxQe4sapOtNhKsQw5ILn9eW4vUvdH8hKuqhCej9GfpOyx2CD3CGjJfVFR(6VwL)iXiB7bj9GJiXbj3qhcn32qliezB9B1Nc0OgYapJCgASdkgondzOfFQ4NHHgmhudg2kFPyPIFO52CSdkgopyXdcMdoXqj4LVZsck)LASUFjYRbJHTx8s2yI)blEqkPALlw20taJx5wneYFqsbDWrK4GfpiLuTYbMmw8(T6R)AvUeWdw8GIDzZ1DZbMmw8(T6R)Av(JeJSThK0d6cjm0HqZTn0ccr2w)w9PanQHmWzKZqJDqXWPzidT4tf)mm0AWWw5lflv8dn3MJDqXW5blEqWCqkPALdmzS49B1x)1QCjGhS4bL5Gus1kxSSPNagVYTAiK)GKc6GJaOhS4bPKQvUutyzo4T6JDPsGlb8GoDEqkPALlw20taJx5wneYFqsbDWrK0d605bf7YMR7MdmzS49B1x)1Q8hjgzBpiypOSoyXdsjvRCXYMEcy8k3QHq(dskOdoc8oi5g6qO52gAbHiBRFR(uGg1Og6LILk(HMBBKZq2iJCgASdkgondzOfFQ4NHHoeAci6XgjMO9GKc6GY6GfpOmhudg2kVmuc4NDP3Q7tKJDqXW5bD68GITNsPYraXV(Rv5yhumCEqNop4l1yD)sKtLA2LEXYMCSdkgopi5g6qO52g6hjUVfzO16DNTIVrnK5Irodn2bfdNMHm0Ipv8ZWqdMdoxLx)1Q(kci(CnfYND5blEqWCqkPALlFYyzx6jgcczJCjGg6qO52gAcRBw2LEkwyvJAitwg5m0yhumCAgYql(uXpddnLuTYLpzSSl9edbHSr(JHqpyXdAbImMxJVevlV(RvTchuc4bjf0bD5GfpOmhKsQw5tmucw)uc5wneYFqqheGFqNopiyo4edLGp6PFIIWbUMc5ZU8GoDEqWCqXci2rR8oljO(AGhKCdDi0CBdD9xRAfoOeqJAid8mYzOXoOy40mKHoeAUTHEPyPIFOOHw8PIFggAkPALlFYyzx6jgcczJ8hdHEqNopiyoiLuTY)KiYLaEWIh0cezmVgFjQwoH1nl7spflS6bjf0bLLHw4GGHEn(suTgYgzudzGZiNHg7GIHtZqgAXNk(zyOTargZRXxIQLxYcrgmFmbmAbEqsbDqxoyXdkZbFPofEGRB85tSMIupiyp4isCqNop4l1ixtIOxxVlhK0dwkMhK8d605bL5GtKsQw5F4i7NcKB1qi)bb7bb3bD68GtKsQw5F4i7NcK)iXiB7bb7bhbUdsUHoeAUTHUKfImy(ycy0c0OgYaOg5m0yhumCAgYql(uXpddTy7PuQC8Jzkcn7spfBDZXoOy48GfpiLuTYXpMPi0Sl9uS1n3QHq(dc6GUCWIhmeAci6XgjMO9GGo4idDi0CBdD9xR6T6NYJg1qgj3iNHg7GIHtZqgAXNk(zyOPKQv(NerUeWdw8GwGiJ514lr1YjSUzzx6PyHvpiPGoOlg6qO52gAcRBw2LEkwyvJAidGBKZqJDqXWPzidT4tf)mm0wGiJ514lr1YlzHidMpMagTapiPGoOlg6qO52g6swiYG5JjGrlqJAiJKAKZqJDqXWPzidDi0CBdD9xR6T6NYJgAXNk(zyObZb1GHTYdadw0ccih7GIHZdw8GG5Gus1kx(KXYU0tmeeYg5sapOtNhudg2kpamyrliGCSdkgopyXdcMdsjvR8pjICjGgAHdcg614lr1AiBKrnKnIeg5m0yhumCAgYql(uXpddnLuTY)KiYLaAOdHMBBOjSUzzx6PyHvnQHSrJmYzOXoOy40mKHoeAUTHEPyPIFOOHw4GGHEn(suTgYgzuJAOTA0Z4Ng5mKnYiNHg7GIHtZqgAXNk(zyO1GHTYldLa(zx6T6(e5yhumCEqNopOy7PuQCeq8R)Avo2bfdNh0PZd(snw3Ve5uPMDPxSSjh7GIHtdDi0CBd9Je33Im0A9UZwX3OgYCXiNHg7GIHtZqgAXNk(zyObZbNyOe8Y3zjbL)snw3Ve5F4i7Nc8GfpOmhCIus1k)dhz)uGCRgc5piypi4oOtNhCIus1k)dhz)uG8hjgzBpiypij)GKBOdHMBBOlzHidMpMagTanQHmzzKZqJDqXWPzidT4tf)mm0IDzZ1DZFK4(wKHwR3D2k(8hjgzBpiybDqxoi4)GLI5blEqnyyR8YqjGF2LERUpro2bfdNg6qO52g66Vw1B1pLhnQHmWZiNHg7GIHtZqgAXNk(zyOfBpLsLJFmtrOzx6PyRBo2bfdNhS4bPKQvo(XmfHMDPNITU5wneYFqqh0Ld605bfBpLsLl1mmSeWPV(y7ioWXoOy48GfpiLuTYLAggwc40xFSDeh4psmY2EqWEqzDWIhKsQw5snddlbC6Rp2oIdCjGg6qO52g66Vw1B1pLhnQHmWzKZqJDqXWPzidT4tf)mm0us1k)tIixcOHoeAUTHMW6MLDPNIfw1OgYaOg5m0yhumCAgYql(uXpddnyoiLuTYR)6iy7bkXSixc4blEqnyyR86Voc2EGsmlYXoOy40qhcn32qVuSuXpu0OgYi5g5m0yhumCAgYql(uXpdd9l1PWdCDJpFI1uK6bb7bL5GJa3bl8GAWWw5VuNcFOk2sHMBZXoOy48GG)dkRdsUHoeAUTHU(Rv9w9t5rJAidGBKZqJDqXWPzidT4tf)mm0VuNcpW1n(8jwtrQhK0dkZbDbChSWdQbdBL)sDk8HQylfAUnh7GIHZdc(pOSoi5g6qO52g6LILk(HIg1qgj1iNHoeAUTHU(Rv9w9t5rdn2bfdNMHmQHSrKWiNHoeAUTHMW(TFRE3zR4BOXoOy40mKrnKnAKrodDi0CBdD8IOrVU)JTAOXoOy40mKrnQHMATEG7YYU0iNHSrg5m0yhumCAgYql(uXpddnLuTY)KiYLaAOdHMBBOjSUzzx6PyHvnQHmxmYzOXoOy40mKHw8PIFgg6qOjGOhBKyI2dskOd6YbD68GVuJCnjIED9G7GGf0blfZdw8GYCqnyyR8YqjGF2LERUpro2bfdNh0PZdk2EkLkhbe)6VwLJDqXW5bD68GVuJ19lrovQzx6flBYXoOy48GKBOdHMBBOFK4(wKHwR3D2k(g1qMSmYzOXoOy40mKHoeAUTHEPyPIFOOHw8PIFgg6xQtHh46gF(eRPi1dskOd6c4m0chem0RXxIQ1q2iJAid8mYzOXoOy40mKHw8PIFgg6xQtHh46gF(eRPi1dc2d6cjoyXdAbImMxJVevlVKfImy(ycy0c8GKc6GUCWIhuSlBUUBoWKXI3VvF9xRYFKyKT9GKEqWzOdHMBBOlzHidMpMagTanQHmWzKZqJDqXWPzidDi0CBdD9xR6T6NYJgAXNk(zyOFPofEGRB85tSMIupiypOlK4GfpOyx2CD3CGjJfVFR(6VwL)iXiB7bj9GGZqlCqWqVgFjQwdzJmQHmaQrodn2bfdNMHm0Ipv8ZWqtjvRC5tgl7spXqqiBK)yi0dw8GVuNcpW1n(8jwtrQhK0dkZbhbUdw4b1GHTYFPof(qvSLcn3MJDqXW5bb)huwhK8dw8GwGiJ514lr1YR)AvRWbLaEqsbDqxoyXdkZbPKQv(edLG1pLqUvdH8he0bb4h0PZdcMdoXqj4JE6NOiCGRPq(SlpOtNhemhuSaID0kVZscQVg4bj3qhcn32qx)1QwHdkb0OgYi5g5m0yhumCAgYql(uXpdd9l1PWdCDJpFI1uK6bjf0bL5GYcChSWdQbdBL)sDk8HQylfAUnh7GIHZdc(pOSoi5hS4bTargZRXxIQLx)1QwHdkb8GKc6GUCWIhuMdsjvR8jgkbRFkHCRgc5piOdcWpOtNhemhCIHsWh90prr4axtH8zxEqNopiyoOybe7OvENLeuFnWdsUHoeAUTHU(RvTchucOrnKbWnYzOXoOy40mKHoeAUTHEPyPIFOOHw8PIFgg6xQtHh46gF(eRPi1dskOdkZbLf4oyHhudg2k)L6u4dvXwk0CBo2bfdNhe8FqzDqYn0chem0RXxIQ1q2iJAiJKAKZqJDqXWPzidT4tf)mm0IDzZ1DZbMmw8(T6R)Av(JeJSThK0d(snY1Ki611dEhS4bFPofEGRB85tSMIupiypi4rIdw8GwGiJ514lr1YlzHidMpMagTapiPGoOlg6qO52g6swiYG5JjGrlqJAiBejmYzOXoOy40mKHoeAUTHU(Rv9w9t5rdT4tf)mm0IDzZ1DZbMmw8(T6R)Av(JeJSThK0d(snY1Ki611dEhS4bFPofEGRB85tSMIupiypi4rcdTWbbd9A8LOAnKnYOg1qlwaXoA1AKZq2iJCgASdkgondzOfFQ4NHH(JC6raXw5XCA5zFqsp4iWDqNopiyo4h50JaITYJ50YrhNw1EqNopyi0eq0Jnsmr7bjf0bDXqhcn32qpXqjy9tj0OgYCXiNHg7GIHtZqgAXNk(zyOdHMaIESrIjApiOdo6Gfp4l1PWdCDJpFI1uK6bj9GY6GfpOyx2CD3CGjJfVFR(6VwL)iXiB7bb7bL1blEqWCqnyyRCQhdLGFREB2ZpkxBWXoOy48GfpOmhemh8JC6raXw5XCA5OJtRApOtNh8JC6raXw5XCA5zFqsp4iWDqYn0HqZTn0w3Xtm7spX0Qg1qMSmYzOXoOy40mKHw8PIFgg6qOjGOhBKyI2dskOd6YblEqWCqnyyRCQhdLGFREB2ZpkxBWXoOy40qhcn32qBDhpXSl9etRAudzGNrodn2bfdNMHm0Ipv8ZWqRbdBLt9yOe8B1BZE(r5Ado2bfdNhS4bL5Gus1kN6Xqj43Q3M98JY1gCjGhS4bL5GHqtarp2iXeThe0bhDWIh8L6u4bUUXNpXAks9GKEqWJeh0PZdgcnbe9yJet0EqsbDqxoyXd(sDk8ax34ZNynfPEqspiaLehK8d605bbZbPKQvo1JHsWVvVn75hLRn4sapyXdk2Lnx3nN6Xqj43Q3M98JY1g8hjgzBpi5g6qO52gAR74jMDPNyAvJAidCg5m0yhumCAgYql(uXpddDi0eq0Jnsmr7bbDWrhS4bf7YMR7MdmzS49B1x)1Q8hjgzBpiypOSoyXdkZbbZb)iNEeqSvEmNwo640Q2d605b)iNEeqSvEmNwE2hK0docChKCdDi0CBdDqTeZo0CBpljszudzauJCgASdkgondzOfFQ4NHHoeAci6XgjMO9GKc6GUyOdHMBBOdQLy2HMB7zjrkJAiJKBKZqJDqXWPzidT4tf)mm0Hqtarp2iXeThe0bhDWIhuSlBUUBoWKXI3VvF9xRYFKyKT9GG9GY6GfpOmhemh8JC6raXw5XCA5OJtRApOtNh8JC6raXw5XCA5zFqsp4iWDqYn0HqZTn0wcHqEg6vcOxQDVVsWbJAidGBKZqJDqXWPzidT4tf)mm0Hqtarp2iXeThKuqh0fdDi0CBdTLqiKNHELa6LA37ReCWOg1qd8rXsKkuJCg1ql2Lnx3T1iNHSrg5m0yhumCAgYql(uXpddTyx2CD3CGjJfVFR(6VwL)ymD4GoDEqXUS56U5atglE)w91FTk)rIr22ds6bDHeg6qO52gAjl6tfjAnQHmxmYzOXoOy40mKHw8PIFggAkPALdmzS49B1x)1QCjGhS4bPKQvose46gF)l1O3nga3Mlb0qhcn32qdC1CBJAitwg5m0yhumCAgYql(uXpddnLuTYbMmw8(T6R)AvUeWdw8Gus1khjcCDJV)LA07gdGBZLaAOdHMBBOPy7o9vP3bJAid8mYzOXoOy40mKHw8PIFggAkPALdmzS49B1x)1QCjGg6qO52gAk8T4lF2Lg1qg4mYzOXoOy40mKHw8PIFggAzoiyoiLuTYbMmw8(T6R)AvUeWdw8GHqtarp2iXeThKuqh0Lds(bD68GG5Gus1khyYyX73QV(Rv5sapyXdkZbFPg5tSMIupiPGoi4oyXd(sDk8ax34ZNynfPEqsbDqakjoi5g6qO52g64frJEGsmlAudzauJCgASdkgondzOfFQ4NHHMsQw5atglE)w91FTkxcOHoeAUTHMLLeuR3rfPzjrSvJAiJKBKZqJDqXWPzidT4tf)mm0us1khyYyX73QV(Rv5sapyXdsjvRCKiW1n((xQrVBmaUnxcOHoeAUTHoAbA1pyErWyg1qga3iNHg7GIHtZqgAXNk(zyOPKQvoWKXI3VvF9xRYFKyKT9GGf0bb4hS4bPKQvose46gF)l1O3nga3Mlb0qhcn32qxZhPy7onQHmsQrodn2bfdNMHm0Ipv8ZWqtjvRCGjJfVFR(6VwLlb8Gfpyi0eq0Jnsmr7bbDWrhS4bL5Gus1khyYyX73QV(Rv5psmY2EqWEqWDWIhudg2kxSSPNagVYXoOy48GoDEqWCqnyyRCXYMEcy8kh7GIHZdw8Gus1khyYyX73QV(Rv5psmY2EqWEqzDqYn0HqZTn0urPFRE9tH8wJAiBejmYzOXoOy40mKHw8PIFggAnyyR8LILk(HMBZXoOy48GfpOmhuSlBUUBoWKXI3VvF9xRYFmMoCWIh8LAKRjr0RRhChK0dwkMhS4bFPofEGRB85tSMIupiPGo4isCqNopiLuTYbMmw8(T6R)AvUeWdw8GVuJCnjIED9G7GKEWsX8GKFqNopynljO(hjgzBpiypOlKWqhcn32qJebUUX3)sn6DJbWTnQHSrJmYzOXoOy40mKHw8PIFggAnyyRCQhdLGFREB2ZpkxBWXoOy48Gfp4l1PWdCDJpFI1uK6bj9GGhjoyXd(snY1Ki611dUds6blfZdw8GYCqkPALt9yOe8B1BZE(r5AdUeWd605bRzjb1)iXiB7bb7bDHehKCdDi0CBdnse46gF)l1O3nga32OgYg5Irodn2bfdNMHm0Ipv8ZWqRbdBLNcuea5yhumCEWIh8LA8GG9GYYqhcn32qJebUUX3)sn6DJbWTnQHSrYYiNHg7GIHtZqgAXNk(zyO1GHTYPEmuc(T6Tzp)OCTbh7GIHZdw8GYCqXUS56U5upgkb)w92SNFuU2G)iXiB7bD68GIDzZ1DZPEmuc(T6Tzp)OCTb)Xy6WblEWxQtHh46gF(eRPi1dc2dcqjXbj3qhcn32qdmzS49B1x)1Qg1q2iWZiNHg7GIHtZqgAXNk(zyO1GHTYtbkcGCSdkgopyXdcMdsjvRCGjJfVFR(6VwLlb0qhcn32qdmzS49B1x)1Qg1q2iWzKZqJDqXWPzidT4tf)mm0AWWw5lflv8dn3MJDqXW5blEqzoOgmSvEzOeWp7sVv3Nih7GIHZdw8Gus1k)rI7BrgATE3zR4ZLaEqNopiyoOgmSvEzOeWp7sVv3Nih7GIHZdsUHoeAUTHgyYyX73QV(RvnQHSrauJCgASdkgondzOfFQ4NHHMsQw5atglE)w91FTkxcOHoeAUTHM6Xqj43Q3M98JY1gg1q2isUrodn2bfdNMHm0Ipv8ZWqtjvRCGjJfVFR(6VwL)iXiB7bb7blfZdw8Gus1khyYyX73QV(Rv5sapyXdcMdQbdBLVuSuXp0CBo2bfdNg6qO52g66Vw1TdprRVk9oyudzJa4g5m0yhumCAgYql(uXpddDi0eq0Jnsmr7bjf0bD5GfpOmhKsQw5atglE)w91FTkxc4blEqkPALdmzS49B1x)1Q8hjgzBpiypyPyEqNop4h50JaITYJ50YrhNw1EWIh8JC6raXw5XCA5psmY2EqWEWsX8GoDEWAwsq9psmY2EqWEWsX8GKBOdHMBBOR)Av3o8eT(Q07GrnKnIKAKZqJDqXWPzidT4tf)mm0AWWw5lflv8dn3MJDqXW5blEqWCqkPALdmzS49B1x)1QCjGhS4bL5GYCqkPALl1ewMdER(yxQe4sapOtNhemhCIHsWlFNLeu(l1yD)sKxdgdBV4LSXe)ds(blEqzo4ePKQv(hoY(Pa5wneYFqqheCh0PZdcMdoXqj4LVZsck)LASUFjY)Wr2pf4bj)GKBOdHMBBOR)Av3o8eT(Q07GrnK5cjmYzOXoOy40mKHw8PIFggAnyyRCQhdLGFREB2ZpkxBWXoOy48Gfp4l1PWdCDJpFI1uK6bj9GGhjoyXd(snEqsbDqzDWIhKsQw5atglE)w91FTkxc4bD68GG5GAWWw5upgkb)w92SNFuU2GJDqXW5blEWxQtHh46gF(eRPi1dskOd6c4m0HqZTn0eCa4QeWNyk8aF0ITanQHmxgzKZqJDqXWPzidT4tf)mm0us1khyYyX73QV(Rv5san0HqZTn0FKw0pXyAudzU4Irodn2bfdNMHm0Ipv8ZWqhcnbe9yJet0EqsbDqxoyXdkZbbIkVKWkX4psmY2EqWEWsX8GoDEqn(su5Ase966NjEqWEWsX8GKBOdHMBBOTH4ZAkYG5bgc1OgYCrwg5m0yhumCAgYql(uXpddDi0eq0Jnsmr7bj9GG7GoDEWxQX6(Lihibm(L42OLJDqXWPHoeAUTHEIHsWh90prr4GrnQHMATEnfYNDProdzJmYzOXoOy40mKHoeAUTHEPyPIFOOHw8PIFgg6xQtHh46gF(eRPi1dskOdcqjHHw4GGHEn(suTgYgzudzUyKZqJDqXWPzidT4tf)mm0AWWw5LHsa)Sl9wDFICSdkgopOtNhuS9ukvoci(1FTkh7GIHZd605bFPgR7xICQuZU0lw2KJDqXW5bD68GHqtarp2iXeThKuqh0fdDi0CBd9Je33Im0A9UZwX3OgYKLrodn2bfdNMHm0Ipv8ZWqtjvR8pjICjGhS4bL5GVuNcpW1n(8jwtrQheSheCG7GoDEWxQrUMerVUEzDqWc6GLI5bD68GwGiJ514lr1YjSUzzx6PyHvpiPGoOlhKCdDi0CBdnH1nl7spflSQrnKbEg5m0yhumCAgYqhcn32qVuSuXpu0ql(uXpdd9l1ixtIOxxp4DqWEWsX8GoDEWxQtHh46gF(eRPi1dskOdcEGZqlCqWqVgFjQwdzJmQHmWzKZqJDqXWPzidT4tf)mm0us1kx(KXYU0tmeeYg5sapyXdAbImMxJVevlV(RvTchuc4bjf0bD5GfpOmhemhCIHsWh90prr4axtH8zxEWIhuSaID0kVZscQVg4bD68GG5GIfqSJw5Dwsq91api5g6qO52g66Vw1kCqjGg1qga1iNHg7GIHtZqgAXNk(zyOFPofEGRB85tSMIupiPGoi4rIdw8GVuJCnjIED9Y6GKEWsX0qhcn32qty)2VvV7Sv8nQHmsUrodn2bfdNMHm0Ipv8ZWqBbImMxJVevlV(RvTchuc4bjf0bD5GfpOmhKsQw5tmucw)uc5wneYFqqheGFqNopiyo4edLGp6PFIIWbUMc5ZU8GoDEqWCqXci2rR8oljO(AGhKCdDi0CBdD9xRAfoOeqJAidGBKZqJDqXWPzidDi0CBd9sXsf)qrdT4tf)mm0VuNcpW1n(8jwtrQhK0d6c4oyXd(snEqspOSm0chem0RXxIQ1q2iJAiJKAKZqJDqXWPzidT4tf)mm0us1k)tIixcOHoeAUTHMW6MLDPNIfw1OgYgrcJCgASdkgondzOfFQ4NHH(L6u4bUUXNpXAks9GKEqWrcdDi0CBdD8IOrVU)JTAuJAONynKyQrodzJmYzOdHMBBOjM90xFeDe0qJDqXWPziJAiZfJCgASdkgondzOfFQ4NHHgmhCUkV(Rv9veq85AkKp7Ydw8GYCqnyyR8uGIaih7GIHZd605bf7YMR7Mt9yOe8B1BZE(r5Ad(JeJSThK0docCh0PZdQbdBLVuSuXp0CBo2bfdNhS4bf7YMR7MdmzS49B1x)1Q8hjgzBpyXdcMdsjvRC5tgl7spXqqiBKlb8GKBOdHMBBOjSUzzx6PyHvnQHmzzKZqJDqXWPzidT4tf)mm0us1kpfo41GTTL)iXiB7bblOdwkMhS4bPKQvEkCWRbBBlxc4blEqlqKX8A8LOA5LSqKbZhtaJwGhKuqh0Ldw8GYCqWCqnyyRCQhdLGFREB2ZpkxBWXoOy48GoDEqXUS56U5upgkb)w92SNFuU2G)iXiB7bj9GJa3bj3qhcn32qxYcrgmFmbmAbAudzGNrodn2bfdNMHm0Ipv8ZWqtjvR8u4Gxd22w(JeJSTheSGoyPyEWIhKsQw5PWbVgSTTCjGhS4bL5GG5GAWWw5upgkb)w92SNFuU2GJDqXW5bD68GIDzZ1DZPEmuc(T6Tzp)OCTb)rIr22ds6bhbUdsUHoeAUTHU(Rv9w9t5rJAidCg5m0yhumCAgYqhcn32qlcgZhcn32ZsRAOzPv9Dqen0IfqSJwTg1qga1iNHg7GIHtZqg6qO52gArWy(qO52EwAvdnlTQVdIOHwSlBUUBRrnKrYnYzOXoOy40mKHw8PIFggAnyyRCXYMEcy8kh7GIHZdw8GYCqkPALlw20taJx5wneYFqsbDWrK4GfpOmhCIus1k)dhz)uGCRgc5piOdcUd605bbZbNyOe8Y3zjbL)snw3Ve5F4i7Nc8GKFqNopynljO(hjgzBpiybDWsX8GKBOdHMBBOfbJ5dHMB7zPvn0S0Q(oiIgAXYMEcy8QrnKbWnYzOXoOy40mKHw8PIFggAkPALt9yOe8B1BZE(r5AdUeqdDi0CBd9l1(qO52EwAvdnlTQVdIOHMATEnfYNDPrnKrsnYzOXoOy40mKHw8PIFggAnyyRCQhdLGFREB2ZpkxBWXoOy48GfpOmhuSlBUUBo1JHsWVvVn75hLRn4psmY2EqWEWrK4GKBOdHMBBOFP2hcn32ZsRAOzPv9Dqen0uR1dCxw2Lg1q2isyKZqJDqXWPzidT4tf)mm0us1khyYyX73QV(Rv5sapyXdQbdBLVuSuXp0CBo2bfdNg6qO52g6xQ9HqZT9S0QgAwAvFherd9sXsf)qZTnQHSrJmYzOXoOy40mKHw8PIFggAnyyR8LILk(HMBZXoOy48GfpOyx2CD3CGjJfVFR(6VwL)iXiB7bb7bhrcdDi0CBd9l1(qO52EwAvdnlTQVdIOHEPyPIFO52EG7YYU0OgYg5Irodn2bfdNMHm0Ipv8ZWqhcnbe9yJet0EqsbDqxm0HqZTn0Vu7dHMB7zPvn0S0Q(oiIg6yrJAiBKSmYzOXoOy40mKHoeAUTHwemMpeAUTNLw1qZsR67GiAOTA0Z4Ng1Og6yrJCgYgzKZqhcn32q)iX9TidTwV7Sv8n0yhumCAgYOgYCXiNHg7GIHtZqgAXNk(zyO1GHTYR)AvRWbLaYXoOy40qhcn32qxYcrgmFmbmAbAudzYYiNHg7GIHtZqg6qO52g66Vw1B1pLhn0Ipv8ZWql2Lnx3n)rI7BrgATE3zR4ZFKyKT9GGf0bD5GG)dwkMhS4b1GHTYldLa(zx6T6(e5yhumCAOfoiyOxJVevRHSrg1qg4zKZqJDqXWPzidT4tf)mm0us1k)tIixcOHoeAUTHMW6MLDPNIfw1OgYaNrodn2bfdNMHm0Ipv8ZWqtjvRC5tgl7spXqqiBK)yi0dw8GYCqWCWjgkbF0t)efHdCnfYND5blEqXci2rR8oljO(AGh0PZdcMdkwaXoAL3zjb1xd8GKBOdHMBBOR)AvRWbLaAudzauJCgASdkgondzOfFQ4NHH(L6u4bUUXNpXAks9GG9GYCWrG7GfEqnyyR8xQtHpufBPqZT5yhumCEqW)bL1bj3qhcn32qxYcrgmFmbmAbAudzKCJCgASdkgondzOdHMBBOR)AvVv)uE0ql(uXpdd9l1PWdCDJpFI1uK6bb7bL5GJa3bl8GAWWw5VuNcFOk2sHMBZXoOy48GG)dkRdsUHw4GGHEn(suTgYgzudzaCJCg6qO52g6hjUVfzO16DNTIVHg7GIHtZqg1qgj1iNHg7GIHtZqgAXNk(zyObZbNyOe8rp9tueoW1uiF2LhS4bflGyhTY7SKG6RbEqNopiyoOybe7OvENLeuFnqdDi0CBdD9xRAfoOeqJAiBejmYzOXoOy40mKHoeAUTHEPyPIFOOHw8PIFgg6xQtHh46gF(eRPi1ds6bL5GUaUdw4b1GHTYFPof(qvSLcn3MJDqXW5bb)huwhKCdTWbbd9A8LOAnKnYOgYgnYiNHoeAUTHUKfImy(ycy0c0qJDqXWPziJAiBKlg5m0yhumCAgYqhcn32qx)1QER(P8OHw4GGHEn(suTgYgzudzJKLrodDi0CBdnH9B)w9UZwX3qJDqXWPziJAiBe4zKZqhcn32qhViA0R7)yRgASdkgondzuJAudnG4BZTnK5cjCHeJCHeaudT747SlTgAswacasYC0KrYi7dEq5iGhmjcCF9G19p4GLILk(HMB7bUll7Ybh8rhfP8X5bTlr8GHKUedfNhuqi6s0YVXfiB8GJK9bl42aIVIZdoqdg2khadoOUhCGgmSvoa4yhumCo4GYmYXKZVXfiB8GJK9bl42aIVIZdo4LASUFjYbWGdQ7bh8snw3Ve5aGJDqXW5GdkZihto)gxGSXdos2hSGBdi(kop4aX2tPu5ayWb19GdeBpLsLdao2bfdNdoOmJCm58B8nMKfGaGKmhnzKmY(Ghuoc4btIa3xpyD)doqSSPNagVo4Gp6OiLpopODjIhmK0LyO48GccrxIw(nUazJh0fzFWcUnG4R48Gd0GHTYbWGdQ7bhObdBLdao2bfdNdoOmJCm58BCbYgpOSK9bl42aIVIZdoqdg2khadoOUhCGgmSvoa4yhumCo4GYmYXKZVXfiB8GGNSpyb3gq8vCEWbAWWw5ayWb19Gd0GHTYbah7GIHZbhuMroMC(nUazJheCY(GfCBaXxX5bhObdBLdGbhu3doqdg2khaCSdkgohCqzg5yY534BmjlabajzoAYizK9bpOCeWdMebUVEW6(hCWsXsf)qZThCWhDuKYhNh0UeXdgs6smuCEqbHOlrl)gxGSXdos2hSGBdi(kop4anyyRCam4G6EWbAWWw5aGJDqXW5GdkZihto)gxGSXdos2hSGBdi(kop4GxQX6(LihadoOUhCWl1yD)sKdao2bfdNdoOmJCm58BCbYgp4izFWcUnG4R48GdeBpLsLdGbhu3doqS9ukvoa4yhumCo4GYmYXKZVXfiB8GauzFWcUnG4R48GdeBpLsLdGbhu3doqS9ukvoa4yhumCo4GYmYXKZVXfiB8GKuzFWcUnG4R48Gd0GHTYbWGdQ7bhObdBLdao2bfdNdoOmU4yY534BmjlabajzoAYizK9bpOCeWdMebUVEW6(hCa1A9AkKp7Ybh8rhfP8X5bTlr8GHKUedfNhuqi6s0YVXfiB8GUi7dwWTbeFfNhCGgmSvoagCqDp4anyyRCaWXoOy4CWbLzKJjNFJlq24bDr2hSGBdi(kop4GxQX6(LihadoOUhCWl1yD)sKdao2bfdNdoOmJCm58BCbYgpOlY(GfCBaXxX5bhi2EkLkhadoOUhCGy7PuQCaWXoOy4CWbLzKJjNFJVXKSaeaKK5OjJKr2h8GYrapyse4(6bR7FWbwn6z8Zbh8rhfP8X5bTlr8GHKUedfNhuqi6s0YVXfiB8GJK9bl42aIVIZdoqdg2khadoOUhCGgmSvoa4yhumCo4GYmYXKZVXfiB8GJK9bl42aIVIZdo4LASUFjYbWGdQ7bh8snw3Ve5aGJDqXW5Gdg6bbFaylWbLzKJjNFJlq24bhj7dwWTbeFfNhCGy7PuQCam4G6EWbITNsPYbah7GIHZbhuMroMC(nUazJhuwY(GfCBaXxX5bhObdBLdGbhu3doqdg2khaCSdkgohCWqpi4daBboOmJCm58BCbYgpi4j7dwWTbeFfNhCGy7PuQCam4G6EWbITNsPYbah7GIHZbhugxCm58BCbYgpiav2hSGBdi(kop4anyyRCam4G6EWbAWWw5aGJDqXW5Gdg6bbFaylWbLzKJjNFJlq24bj5Y(GfCBaXxX5bhObdBLdGbhu3doqdg2khaCSdkgohCqzg5yY534cKnEqaUSpyb3gq8vCEWbAWWw5ayWb19Gd0GHTYbah7GIHZbhuMroMC(n(gtYcqaqsMJMmsgzFWdkhb8GjrG7RhSU)bhqTwpWDzzxo4Gp6OiLpopODjIhmK0LyO48GccrxIw(nUazJh0fzFWcUnG4R48Gd0GHTYbWGdQ7bhObdBLdao2bfdNdoOmJCm58BCbYgpOlY(GfCBaXxX5bh8snw3Ve5ayWb19GdEPgR7xICaWXoOy4CWbLzKJjNFJlq24bDr2hSGBdi(kop4aX2tPu5ayWb19GdeBpLsLdao2bfdNdoOmJCm58BCbYgpiav2hSGBdi(kop4anyyRCam4G6EWbAWWw5aGJDqXW5GdkZihto)gxGSXdsYL9bl42aIVIZdoqdg2khadoOUhCGgmSvoa4yhumCo4GYmYXKZVXfiB8GaCzFWcUnG4R48Gd0GHTYbWGdQ7bhObdBLdao2bfdNdoOmJCm58B8nMKfGaGKmhnzKmY(Ghuoc4btIa3xpyD)doqSlBUUB7Gd(OJIu(48G2LiEWqsxIHIZdkieDjA534cKnEWrKq2hSGBdi(kop4anyyRCam4G6EWbAWWw5aGJDqXW5GdkZihto)gxGSXdoAKSpyb3gq8vCEWbAWWw5ayWb19Gd0GHTYbah7GIHZbhuMroMC(nUazJhCKlY(GfCBaXxX5bhObdBLdGbhu3doqdg2khaCSdkgohCqzg5yY534cKnEWrYs2hSGBdi(kop4anyyRCam4G6EWbAWWw5aGJDqXW5GdkZihto)gxGSXdoc8K9bl42aIVIZdoqdg2khadoOUhCGgmSvoa4yhumCo4GYmYXKZVXfiB8GJaNSpyb3gq8vCEWbAWWw5ayWb19Gd0GHTYbah7GIHZbhuMroMC(nUazJhCejx2hSGBdi(kop4anyyRCam4G6EWbAWWw5aGJDqXW5Gdg6bbFaylWbLzKJjNFJlq24bhrsL9bl42aIVIZdoqdg2khadoOUhCGgmSvoa4yhumCo4GYmYXKZVXfiB8GUqczFWcUnG4R48Gd0GHTYbWGdQ7bhObdBLdao2bfdNdoOmU4yY534cKnEqxKLSpyb3gq8vCEWbVuJ19lroagCqDp4GxQX6(LihaCSdkgohCWqpi4daBboOmJCm58B8nMKfGaGKmhnzKmY(Ghuoc4btIa3xpyD)doqSaID0QDWbF0rrkFCEq7sepyiPlXqX5bfeIUeT8BCbYgpOlY(GfCBaXxX5bhObdBLdGbhu3doqdg2khaCSdkgohCqzg5yY534cKnEqzj7dwWTbeFfNhCGgmSvoagCqDp4anyyRCaWXoOy4CWbd9GGpaSf4GYmYXKZVXfiB8GGNSpyb3gq8vCEWbAWWw5ayWb19Gd0GHTYbah7GIHZbhuMroMC(n(gtYcqaqsMJMmsgzFWdkhb8GjrG7RhSU)bhmXAiX0bh8rhfP8X5bTlr8GHKUedfNhuqi6s0YVXfiB8GUi7dwWTbeFfNhCGgmSvoagCqDp4anyyRCaWXoOy4CWbLXfhto)gxGSXdklzFWcUnG4R48Gd0GHTYbWGdQ7bhObdBLdao2bfdNdoOmJCm58BCbYgpi4j7dwWTbeFfNhCGgmSvoagCqDp4anyyRCaWXoOy4CWbLzKJjNFJlq24bj5Y(GfCBaXxX5bhObdBLdGbhu3doqdg2khaCSdkgohCqzg5yY534cKnEqsQSpyb3gq8vCEWbAWWw5ayWb19Gd0GHTYbah7GIHZbhuMroMC(nUazJhCejK9bl42aIVIZdoqdg2khadoOUhCGgmSvoa4yhumCo4GHEqWha2cCqzg5yY534cKnEWrJK9bl42aIVIZdoqdg2khadoOUhCGgmSvoa4yhumCo4GYmYXKZVX3yswacasYC0KrYi7dEq5iGhmjcCF9G19p4GyXbh8rhfP8X5bTlr8GHKUedfNhuqi6s0YVXfiB8GUi7dwWTbeFfNhCGgmSvoagCqDp4anyyRCaWXoOy4CWbd9GGpaSf4GYmYXKZVXfiB8GYs2hSGBdi(kop4anyyRCam4G6EWbAWWw5aGJDqXW5Gdg6bbFaylWbLzKJjNFJlq24bbOY(GfCBaXxX5bhObdBLdGbhu3doqdg2khaCSdkgohCqzg5yY534cKnEqsUSpyb3gq8vCEWbAWWw5ayWb19Gd0GHTYbah7GIHZbhuMroMC(nUazJhCejK9bl42aIVIZdoqdg2khadoOUhCGgmSvoa4yhumCo4GYmYXKZVX3yhnrG7R48GJiXbdHMBFqwAvl)gBOTarHHmxa3idnWFRjdn0KKdcWedLWbDu3zjb9Gam(1Q3ysYbbyIcKif(hKK66bDHeUqIB8nMKCqWhhJcjfNhebeFhoOMeXdQeWdgcD)dM2dgagjlOyi)ghcn32cIy2tF9r0rWBmj5GaeabYC4Gam(1QheGbci(hm65bjgzRr2h0rlC4GYfSTT34qO522cbnmH1nl7spflSQRzfeyMRYR)AvFfbeFUMc5ZUSOmAWWw5PafbqNof7YMR7Mt9yOe8B1BZE(r5Ad(JeJSTKocCoDQbdBLVuSuXp0C7IIDzZ1DZbMmw8(T6R)Av(JeJSTfbdLuTYLpzSSl9edbHSrUeqYVXHqZTTfcA4swiYG5JjGrlqxZkikPALNch8AW22YFKyKTfSGkfZIus1kpfo41GTTLlbSOfiYyEn(suT8swiYG5JjGrlqsb5srzaJgmSvo1JHsWVvVn75hLRnC6uSlBUUBo1JHsWVvVn75hLRn4psmY2s6iWr(noeAUTTqqdx)1QER(P8ORzfeLuTYtHdEnyBB5psmY2cwqLIzrkPALNch8AW22YLawugWObdBLt9yOe8B1BZE(r5AdNof7YMR7Mt9yOe8B1BZE(r5Ad(JeJSTKocCKFJjjhSGe21IheGqO52hKLw9G6EWxQVXHqZTTfcAyrWy(qO52EwAvx7GicsSaID0Q9ghcn32wiOHfbJ5dHMB7zPvDTdIiiXUS56UT34qO522cbnSiymFi0CBplTQRDqebjw20taJxDnRG0GHTYflB6jGXRfLHsQw5ILn9eW4vUvdH8KcAejkkZePKQv(hoY(Pa5wneYdcCoDcMjgkbV8Dwsq5VuJ19lr(hoY(Paj3PZAwsq9psmY2cwqLIj534qO522cbn8l1(qO52EwAvx7GicIATEnfYNDPRzfeLuTYPEmuc(T6Tzp)OCTbxc4noeAUTTqqd)sTpeAUTNLw11oiIGOwRh4USSlDnRG0GHTYPEmuc(T6Tzp)OCTrrze7YMR7Mt9yOe8B1BZE(r5Ad(JeJSTGDeji)ghcn32wiOHFP2hcn32ZsR6Aherqlflv8dn321ScIsQw5atglE)w91FTkxcyrnyyR8LILk(HMBFJdHMBBle0WVu7dHMB7zPvDTdIiOLILk(HMB7bUll7sxZkinyyR8LILk(HMBxuSlBUUBoWKXI3VvF9xRYFKyKTfSJiXnoeAUTTqqd)sTpeAUTNLw11oiIGIfDnRGcHMaIESrIjAjfKl34qO522cbnSiymFi0CBplTQRDqebz1ONXpVX3ysYbbiwWNdcqUAO5234qO52wESiOhjUVfzO16DNTI)noeAUTLhlwiOHlzHidMpMagTaDnRG0GHTYR)AvRWbLaEJdHMBB5XIfcA46Vw1B1pLhDv4GGHEn(suTGg5Awbj2Lnx3n)rI7BrgATE3zR4ZFKyKTfSGCb8xkMf1GHTYldLa(zx6T6(eVXHqZTT8yXcbnmH1nl7spflSQRzfeLuTY)KiYLaEJdHMBB5XIfcA46Vw1kCqjGUMvqus1kx(KXYU0tmeeYg5pgcTOmGzIHsWh90prr4axtH8zxwuSaID0kVZscQVgOtNGrSaID0kVZscQVgi534qO52wESyHGgUKfImy(ycy0c01Sc6L6u4bUUXNpXAksfSYmcCfQbdBL)sDk8HQylfAUn4xwKFJdHMBB5XIfcA46Vw1B1pLhDv4GGHEn(suTGg5Awb9sDk8ax34ZNynfPcwzgbUc1GHTYFPof(qvSLcn3g8llYVXHqZTT8yXcbn8Je33Im0A9UZwX)ghcn32YJfle0W1FTQv4GsaDnRGaZedLGp6PFIIWbUMc5ZUSOybe7OvENLeuFnqNobJybe7OvENLeuFnWBCi0CBlpwSqqdVuSuXpu0vHdcg614lr1cAKRzf0l1PWdCDJpFI1uKkPY4c4kudg2k)L6u4dvXwk0CBWVSi)ghcn32YJfle0WLSqKbZhtaJwG34qO52wESyHGgU(Rv9w9t5rxfoiyOxJVevlOr34qO52wESyHGgMW(TFRE3zR4FJdHMBB5XIfcA44frJED)hB9gFJjjhCOhdLWb36bPZE(r5AJdcCxw2Lh8xn0C7dk7dA14v7bhrc7bPW6(4bhAPpyApyayKSGIH34qO52wo1A9a3LLDjicRBw2LEkwyvxZkikPAL)jrKlb8ghcn32YPwRh4USSlle0WpsCFlYqR17oBfFxZkOqOjGOhBKyIwsb5ItNVuJCnjIED9GdSGkfZIYObdBLxgkb8ZU0B19j60Py7PuQCeq8R)AvNoFPgR7xICQuZU0lw2K8Bmj5Gd04lr1NvqedhlBzMiLuTY)Wr2pfi3QHq(chro4BKzIus1k)dhz)uG8hjgzBlCe5G)jgkbV8Dwsq5VuJ19lr(hoY(PahCqaseigQ9GXbzR66bvcP9GP9GzRypX5b19GA8LOEqLaEqczjb0Qhe4N7NQdheBKOdh0DQeoy0hmOswQoCqLqOh0DYyhmacK5Wb)Wr2pf4bZ6bFPgR7xIt(bLJqOhKcZU8GrFqSrIoCq3Ps4GK4GwneYBD9G7FWOpi2irhoOsi0dQeWdorkPA9GUtg7G2D7dIogy(4b3MFJdHMBB5uR1dCxw2LfcA4LILk(HIUkCqWqVgFjQwqJCnRGEPofEGRB85tSMIujfKlG7ghcn32YPwRh4USSlle0WLSqKbZhtaJwGUMvqVuNcpW1n(8jwtrQG1fsu0cezmVgFjQwEjlezW8XeWOfiPGCPOyx2CD3CGjJfVFR(6VwL)iXiBlPG7ghcn32YPwRh4USSlle0W1FTQ3QFkp6QWbbd9A8LOAbnY1Sc6L6u4bUUXNpXAksfSUqIIIDzZ1DZbMmw8(T6R)Av(JeJSTKcUBCi0CBlNATEG7YYUSqqdx)1QwHdkb01ScIsQw5YNmw2LEIHGq2i)XqOfFPofEGRB85tSMIujvMrGRqnyyR8xQtHpufBPqZTb)YI8IwGiJ514lr1YR)AvRWbLaskixkkdLuTYNyOeS(PeYTAiKhea3PtWmXqj4JE6NOiCGRPq(SlD6emIfqSJw5Dwsq91aj)ghcn32YPwRh4USSlle0W1FTQv4GsaDnRGEPofEGRB85tSMIujfKmYcCfQbdBL)sDk8HQylfAUn4xwKx0cezmVgFjQwE9xRAfoOeqsb5srzOKQv(edLG1pLqUvdH8Ga4oDcMjgkbF0t)efHdCnfYNDPtNGrSaID0kVZscQVgi534qO52wo1A9a3LLDzHGgEPyPIFOORchem0RXxIQf0ixZkOxQtHh46gF(eRPivsbjJSaxHAWWw5VuNcFOk2sHMBd(Lf534qO52wo1A9a3LLDzHGgUKfImy(ycy0c01ScsSlBUUBoWKXI3VvF9xRYFKyKTL0xQrUMerVUEWR4l1PWdCDJpFI1uKkybpsu0cezmVgFjQwEjlezW8XeWOfiPGC5ghcn32YPwRh4USSlle0W1FTQ3QFkp6QWbbd9A8LOAbnY1ScsSlBUUBoWKXI3VvF9xRYFKyKTL0xQrUMerVUEWR4l1PWdCDJpFI1uKkybpsCJVXKKdo0JHs4GB9G0zp)OCTXbbieAciEqaYvdn3(ghcn32YPwRxtH8zxcAPyPIFOORchem0RXxIQf0ixZkOxQtHh46gF(eRPivsbbqjXnoeAUTLtTwVMc5ZUSqqd)iX9TidTwV7Sv8DnRG0GHTYldLa(zx6T6(eD6uS9ukvoci(1FTQtNVuJ19lrovQzx6flB60zi0eq0JnsmrlPGC5ghcn32YPwRxtH8zxwiOHjSUzzx6PyHvDnRGOKQv(NerUeWIY8sDk8ax34ZNynfPcwWboNoFPg5Ase966LfybvkMoDAbImMxJVevlNW6MLDPNIfwLuqUq(noeAUTLtTwVMc5ZUSqqdVuSuXpu0vHdcg614lr1cAKRzf0l1ixtIOxxp4b2sX0PZxQtHh46gF(eRPivsbbEG7ghcn32YPwRxtH8zxwiOHR)AvRWbLa6AwbrjvRC5tgl7spXqqiBKlbSOfiYyEn(suT86Vw1kCqjGKcYLIYaMjgkbF0t)efHdCnfYNDzrXci2rR8oljO(AGoDcgXci2rR8oljO(AGKFJdHMBB5uR1RPq(Slle0We2V9B17oBfFxZkOxQtHh46gF(eRPivsbbEKO4l1ixtIOxxVSiTumVXHqZTTCQ161uiF2LfcA46Vw1kCqjGUMvqwGiJ514lr1YR)AvRWbLaskixkkdLuTYNyOeS(PeYTAiKhea3PtWmXqj4JE6NOiCGRPq(SlD6emIfqSJw5Dwsq91aj)ghcn32YPwRxtH8zxwiOHxkwQ4hk6QWbbd9A8LOAbnY1Sc6L6u4bUUXNpXAksLuxaxXxQrsL1noeAUTLtTwVMc5ZUSqqdtyDZYU0tXcR6AwbrjvR8pjICjG34qO52wo1A9AkKp7YcbnC8IOrVU)JT6Awb9sDk8ax34ZNynfPsk4iXn(gtsoybx28GoQIXRhSGBptn32EJdHMBB5ILn9eW4vqccr2w)w9PaDnRGQzjb1)iXiBlylfZBmj5GGVBXdoL(Slpi4RKXI)GUtLWbD0cueahEOhdLWnoeAUTLlw20taJxle0Wccr2w)w9PaDnRGaJgmSv(sXsf)qZTlsjvRCGjJfVFR(6VwL)iXiBlyLvrkPALdmzS49B1x)1QCjGfPKQvUyztpbmELB1qipPGgrIBmj5GaSsQnN4b36bbFLmw8huYIrjEq3Ps4GoAbkcGdp0JHs4ghcn32YflB6jGXRfcAybHiBRFR(uGUMvqGrdg2kFPyPIFO52fNyOe8Y3zjbL)snw3Ve51GXW2lEjBmXVOmus1kxSSPNagVYTAiKNuqJaOfPKQvUutyzo4T6JDPsGlb0PtkPALlw20taJx5wneYtkOrK0IIDzZ1DZbMmw8(T6R)Av(JeJSTKoIeKFJdHMBB5ILn9eW41cbnSGqKT1VvFkqxZkiWObdBLVuSuXp0C7IGzIHsWlFNLeu(l1yD)sKxdgdBV4LSXe)Ius1kxSSPNagVYTAiKNuqJirrkPALdmzS49B1x)1QCjGff7YMR7MdmzS49B1x)1Q8hjgzBj1fsCJjjhe81JaITEWcUS5bDufJxp4ci(IaiWSlp4u6ZU8Gatgl(BCi0CBlxSSPNagVwiOHfeIST(T6tb6AwbPbdBLVuSuXp0C7IGHsQw5atglE)w91FTkxcyrzOKQvUyztpbmELB1qipPGgbqlsjvRCPMWYCWB1h7sLaxcOtNus1kxSSPNagVYTAiKNuqJiPoDk2Lnx3nhyYyX73QV(Rv5psmY2cwzvKsQw5ILn9eW4vUvdH8KcAe4r(n(gtsoiaBFqW3T4bD0ks066bbFTAU9bJEEqaYqKbZEJdHMBB5IDzZ1DBbjzrFQirRRzfKyx2CD3CGjJfVFR(6VwL)ymDWPtXUS56U5atglE)w91FTk)rIr2wsDHe34qO52wUyx2CD32cbnmWvZTDnRGOKQvoWKXI3VvF9xRYLawKsQw5irGRB89VuJE3yaCBUeWBCi0CBlxSlBUUBBHGgMIT70xLEhCnRGOKQvoWKXI3VvF9xRYLawKsQw5irGRB89VuJE3yaCBUeWBCi0CBlxSlBUUBBHGgMcFl(YNDPRzfeLuTYbMmw8(T6R)AvUeWBCi0CBlxSlBUUBBHGgoEr0OhOeZIUMvqYagkPALdmzS49B1x)1QCjGfdHMaIESrIjAjfKlK70jyOKQvoWKXI3VvF9xRYLawuMxQr(eRPivsbbUIVuNcpW1n(8jwtrQKccGscYVXHqZTTCXUS56UTfcAywwsqTEhvKMLeXwDnRGOKQvoWKXI3VvF9xRYLaEJdHMBB5IDzZ1DBle0WrlqR(bZlcgZ1ScIsQw5atglE)w91FTkxcyrkPALJebUUX3)sn6DJbWT5saVXHqZTTCXUS56UTfcA4A(ifB3PRzfeLuTYbMmw8(T6R)Av(JeJSTGfeaViLuTYrIax347FPg9UXa42CjG34qO52wUyx2CD32cbnmvu63Qx)uiV11ScIsQw5atglE)w91FTkxcyXqOjGOhBKyIwqJkkdLuTYbMmw8(T6R)Av(JeJSTGfCf1GHTYflB6jGXRCSdkgoD6emAWWw5ILn9eW4vo2bfdNfPKQvoWKXI3VvF9xRYFKyKTfSYI8Bmj5GfCx2CD32BCi0CBlxSlBUUBBHGggjcCDJV)LA07gdGB7AwbPbdBLVuSuXp0C7IYi2Lnx3nhyYyX73QV(Rv5pgthk(snY1Ki611doslfZIVuNcpW1n(8jwtrQKcAejC6KsQw5atglE)w91FTkxcyXxQrUMerVUEWrAPysUtN1SKG6FKyKTfSUqIBCi0CBlxSlBUUBBHGggjcCDJV)LA07gdGB7AwbPbdBLt9yOe8B1BZE(r5AJIVuNcpW1n(8jwtrQKcEKO4l1ixtIOxxp4iTumlkdLuTYPEmuc(T6Tzp)OCTbxcOtN1SKG6FKyKTfSUqcYVXHqZTTCXUS56UTfcAyKiW1n((xQrVBmaUTRzfKgmSvEkqraS4l1iyL1noeAUTLl2Lnx3TTqqddmzS49B1x)1QUMvqAWWw5upgkb)w92SNFuU2OOmIDzZ1DZPEmuc(T6Tzp)OCTb)rIr2wNof7YMR7Mt9yOe8B1BZE(r5Ad(JX0HIVuNcpW1n(8jwtrQGfGscYVXHqZTTCXUS56UTfcAyGjJfVFR(6Vw11Scsdg2kpfOiawemus1khyYyX73QV(Rv5saVXHqZTTCXUS56UTfcAyGjJfVFR(6Vw11Scsdg2kFPyPIFO52fLrdg2kVmuc4NDP3Q7tKJDqXWzrkPAL)iX9TidTwV7Sv85saD6emAWWw5LHsa)Sl9wDFICSdkgoj)ghcn32Yf7YMR72wiOHPEmuc(T6Tzp)OCTHRzfeLuTYbMmw8(T6R)AvUeWBCi0CBlxSlBUUBBHGgU(RvD7Wt06RsVdUMvqus1khyYyX73QV(Rv5psmY2c2sXSiLuTYbMmw8(T6R)AvUeWIGrdg2kFPyPIFO5234qO52wUyx2CD32cbnC9xR62HNO1xLEhCnRGcHMaIESrIjAjfKlfLHsQw5atglE)w91FTkxcyrkPALdmzS49B1x)1Q8hjgzBbBPy605h50JaITYJ50YrhNw1w8JC6raXw5XCA5psmY2c2sX0PZAwsq9psmY2c2sXK8BCi0CBlxSlBUUBBHGgU(RvD7Wt06RsVdUMvqAWWw5lflv8dn3UiyOKQvoWKXI3VvF9xRYLawugzOKQvUutyzo4T6JDPsGlb0PtWmXqj4LVZsck)LASUFjYRbJHTx8s2yIp5fLzIus1k)dhz)uGCRgc5bboNobZedLGx(oljO8xQX6(Li)dhz)uGKt(noeAUTLl2Lnx3TTqqdtWbGRsaFIPWd8rl2c01Scsdg2kN6Xqj43Q3M98JY1gfFPofEGRB85tSMIujf8irXxQrsbjRIus1khyYyX73QV(Rv5saD6emAWWw5upgkb)w92SNFuU2O4l1PWdCDJpFI1uKkPGCbC34qO52wUyx2CD32cbn8hPf9tmMUMvqus1khyYyX73QV(Rv5saVXHqZTTCXUS56UTfcAyBi(SMImyEGHqDnRGcHMaIESrIjAjfKlfLbiQ8scReJ)iXiBlylftNo14lrLRjr0RRFMiylftYVXHqZTTCXUS56UTfcA4jgkbF0t)efHdUMvqHqtarp2iXeTKcoNoFPgR7xICGeW4xIBJ2B8nMKCWcUaID06bbiOswQjAVXHqZTTCXci2rRwqtmucw)ucDnRG(iNEeqSvEmNwE2KocCoDcMpYPhbeBLhZPLJooTQ1PZqOjGOhBKyIwsb5YnoeAUTLlwaXoA1wiOHTUJNy2LEIPvDnRGcHMaIESrIjAbnQ4l1PWdCDJpFI1uKkPYQOyx2CD3CGjJfVFR(6VwL)iXiBlyLvrWObdBLt9yOe8B1BZE(r5AJIYaMpYPhbeBLhZPLJooTQ1PZpYPhbeBLhZPLNnPJah534qO52wUybe7OvBHGg26oEIzx6jMw11SckeAci6XgjMOLuqUuemAWWw5upgkb)w92SNFuU24ghcn32YflGyhTAle0Ww3Xtm7spX0QUMvqAWWw5upgkb)w92SNFuU2OOmus1kN6Xqj43Q3M98JY1gCjGfLjeAci6XgjMOf0OIVuNcpW1n(8jwtrQKcEKWPZqOjGOhBKyIwsb5sXxQtHh46gF(eRPivsbOKGCNobdLuTYPEmuc(T6Tzp)OCTbxcyrXUS56U5upgkb)w92SNFuU2G)iXiBl534qO52wUybe7OvBHGgoOwIzhAUTNLePCnRGcHMaIESrIjAbnQOyx2CD3CGjJfVFR(6VwL)iXiBlyLvrzaZh50JaITYJ50YrhNw1605h50JaITYJ50YZM0rGJ8BCi0CBlxSaID0QTqqdhulXSdn32ZsIuUMvqHqtarp2iXeTKcYLBCi0CBlxSaID0QTqqdBjec5zOxjGEP29(kbhCnRGcHMaIESrIjAbnQOyx2CD3CGjJfVFR(6VwL)iXiBlyLvrzaZh50JaITYJ50YrhNw1605h50JaITYJ50YZM0rGJ8BCi0CBlxSaID0QTqqdBjec5zOxjGEP29(kbhCnRGcHMaIESrIjAjfKl34Bmj5GaSuSuXp0C7d(RgAU9noeAUTLVuSuXp0CBqpsCFlYqR17oBfFxZkOqOjGOhBKyIwsbjRIYObdBLxgkb8ZU0B19j60Py7PuQCeq8R)AvNoFPgR7xICQuZU0lw2K8BCi0CBlFPyPIFO52fcAycRBw2LEkwyvxZkiWmxLx)1Q(kci(CnfYNDzrWqjvRC5tgl7spXqqiBKlb8ghcn32YxkwQ4hAUDHGgU(RvTchucORzfeLuTYLpzSSl9edbHSr(JHqlAbImMxJVevlV(RvTchuciPGCPOmus1kFIHsW6Nsi3QHqEqaCNobZedLGp6PFIIWbUMc5ZU0PtWiwaXoAL3zjb1xdK8BCi0CBlFPyPIFO52fcA4LILk(HIUkCqWqVgFjQwqJCnRGOKQvU8jJLDPNyiiKnYFmeQtNGHsQw5Fse5salAbImMxJVevlNW6MLDPNIfwLuqY6ghcn32YxkwQ4hAUDHGgUKfImy(ycy0c01ScYcezmVgFjQwEjlezW8XeWOfiPGCPOmVuNcpW1n(8jwtrQGDejC68LAKRjr0RR3fslftYD6uMjsjvR8pCK9tbYTAiKhSGZPZjsjvR8pCK9tbYFKyKTfSJah534qO52w(sXsf)qZTle0W1FTQ3QFkp6Awbj2EkLkh)yMIqZU0tXw3fPKQvo(XmfHMDPNITU5wneYdYLIHqtarp2iXeTGgDJdHMBB5lflv8dn3UqqdtyDZYU0tXcR6AwbrjvR8pjICjGfTargZRXxIQLtyDZYU0tXcRskixUXHqZTT8LILk(HMBxiOHlzHidMpMagTaDnRGSargZRXxIQLxYcrgmFmbmAbskixUXHqZTT8LILk(HMBxiOHR)AvVv)uE0vHdcg614lr1cAKRzfey0GHTYdadw0ccyrWqjvRC5tgl7spXqqiBKlb0PtnyyR8aWGfTGawemus1k)tIixc4noeAUTLVuSuXp0C7cbnmH1nl7spflSQRzfeLuTY)KiYLaEJdHMBB5lflv8dn3UqqdVuSuXpu0vHdcg614lr1cA0n(gtsoi4RDzzxEqag7FqawkwQ4hAUTSpiTgVAp4isCqlk2EApifw3hpi4RKXI)GB9Gam(1QhuSer7b3A9GfeG5noeAUTLVuSuXp0CBpWDzzxc6rI7BrgATE3zR47AwbPbdBLxgkb8ZU0B19j60Py7PuQCeq8R)AvNoFPgR7xICQuZU0lw20PZqOjGOhBKyIwsb5YnoeAUTLVuSuXp0CBpWDzzxwiOHjSUzzx6PyHvDnRGOKQv(NerUeWBCi0CBlFPyPIFO52EG7YYUSqqdVuSuXpu0vHdcg614lr1cAKRzfeLuTYLpzSSl9edbHSr(JHqVXHqZTT8LILk(HMB7bUll7YcbnCjlezW8XeWOfORzfKfiYyEn(suT8swiYG5JjGrlqsb5sXxQtHh46gF(eRPivWcqjXnoeAUTLVuSuXp0CBpWDzzxwiOHR)AvVv)uE0vHdcg614lr1cAKRzf0l1PWdCDJpFI1uKkyj5K4ghcn32YxkwQ4hAUTh4USSlle0Wlflv8dfDv4GGHEn(suTGg5Awb9snsk4DJdHMBB5lflv8dn32dCxw2LfcA46Vw1kCqjGUMvqHqtarp2iXeTKcc8kkdyMyOe8rp9tueoW1uiF2LfflGyhTY7SKG6Rb60jyelGyhTY7SKG6Rbs(n(gtsoiTg9m(5bTzxYqW3QXxI6b)vdn3(ghcn32YTA0Z4NGEK4(wKHwR3D2k(UMvqAWWw5LHsa)Sl9wDFIoDk2EkLkhbe)6Vw1PZxQX6(LiNk1Sl9ILnVXHqZTTCRg9m(zHGgUKfImy(ycy0c01SccmtmucE57SKGYFPgR7xI8pCK9tbwuMjsjvR8pCK9tbYTAiKhSGZPZjsjvR8pCK9tbYFKyKTfSKCYVXHqZTTCRg9m(zHGgU(Rv9w9t5rxZkiXUS56U5psCFlYqR17oBfF(JeJSTGfKlG)sXSOgmSvEzOeWp7sVv3N4noeAUTLB1ONXple0W1FTQ3QFkp6Awbj2EkLkh)yMIqZU0tXw3fPKQvo(XmfHMDPNITU5wneYdYfNofBpLsLl1mmSeWPV(y7iouKsQw5snddlbC6Rp2oId8hjgzBbRSksjvRCPMHHLao91hBhXbUeWBCi0CBl3QrpJFwiOHjSUzzx6PyHvDnRGOKQv(NerUeWBCi0CBl3QrpJFwiOHxkwQ4hk6AwbbgkPALx)1rW2duIzrUeWIAWWw51FDeS9aLyw8ghcn32YTA0Z4NfcA46Vw1B1pLhDnRGEPofEGRB85tSMIubRmJaxHAWWw5VuNcFOk2sHMBd(Lf534qO52wUvJEg)SqqdVuSuXpu01Sc6L6u4bUUXNpXAksLuzCbCfQbdBL)sDk8HQylfAUn4xwKFJdHMBB5wn6z8ZcbnC9xR6T6NYJ34qO52wUvJEg)Sqqdty)2VvV7Sv8VXHqZTTCRg9m(zHGgoEr0Ox3)XwnQrnga]] )

end
