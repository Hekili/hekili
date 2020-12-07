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


    spec:RegisterPack( "Frost DK", 20201206, [[d4elecqiGIhPGQUeIqk2Ke6tkWOivCkevRcrOELe0SOs6wicP0Uq1VaGHbu5ykKLrf8msLmnebxdOQTPGIVHikJdreNJkHSosLAEaLUhq2hI0bvqjlub5HsGMOcQOlIieBubv4JiIKrIiQsNKkHALkuVeruvZucyNik)ubvAOicjlvbL6Pi1ujv5QicP6RiIuJfaTxk(lvnyqhwyXi5XKmzfDzOnlPplrJgbNw0QrevXRPcnBuUncTBP(Tsdhqhhruz5Q65uA6exNu2oa9DQuJNkrNNuvRNkbZNkA)QSzKrpd9me0qMdGZbWnYbWnmChgboWPRrgArFGOHgyOCmkrdDherd9WXVw5GdNK8n0ad9zBmn6zOTR2RqdnbraA1naaqzke0O4QLiaSjrnwi52QpQcaSjrfam0uAjtCXTHYqpdbnK5a4CaCJCaCdd3HrGdCoOldDOje23qtNelOHMqoNyBOm0t0Qm0d)bhoXqiCqs(Dwsqo4WXVw5gp8hC4evirk8p4W46bDaCoaUB8nE4pinHyUUzrpThuhxehCChi3qZsRyn6zOxkwk4hsUTh4USSln6ziBKrpdn2bfdNMHm0Qpf8ZWqlbdBHxgcb8ZU0BL9jYXoOy48GoDEq12tTu4iG4x)1kCSdkgopOtNh81ASUFjYPsj7sVAzto2bfdNh0PZdgkjbe9yJet0EqsbDqhm0HsYTn0psCFlYqR17oBbFJyiZbJEgASdkgondzOvFk4NHHMsRw5Fse5Aan0HsYTn0ew3SSl9uSWkgXqMUm6zOXoOy40mKHousUTHEPyPGFiOHw9PGFggAkTAL7yYyzx6jgkczJ8hdLyOv6RyOxIVefRHSrgXqgjy0ZqJDqXWPzidT6tb)mm0wGiJ5L4lrXYlzHkdMpMagTcpiPGoOdhS4bFTovEGRB85tSMQuoiyp4WaodDOKCBdDjluzW8XeWOvOrmKbEJEgASdkgondzOdLKBBOR)AfVv(0r0qR(uWpdd9R1PYdCDJpFI1uLYbb7bjzGZqR0xXqVeFjkwdzJmIHSHXONHg7GIHtZqg6qj52g6LILc(HGgA1Nc(zyOFTgpiPhKem0k9vm0lXxII1q2iJyiJKz0ZqJDqXWPzidT6tb)mm0Hssarp2iXeThKuqhKeoyXdQZbbZbNyie8rp9tuf6ZLu5y2LhS4bvlGyhTW7SKG4RbEqNopiyoOAbe7OfENLeeFnWdsUHousUTHU(RvSk9fcOrmIHwTSPNagVy0Zq2iJEgASdkgondzOvFk4NHHUMLee)JeJSTheShSunn0HsYTn0kcr2w)w9PcnIHmhm6zOXoOy40mKHw9PGFggAWCqjyyl8LILc(HKBZXoOy48GfpiLwTYbMmw8(T6R)Af(JeJSTheShuxhS4bP0QvoWKXI3VvF9xRW1aEWIhKsRw5QLn9eW4fUvcLJhKuqhCe4m0HsYTn0kcr2w)w9PcnIHmDz0ZqJDqXWPzidT6tb)mm0G5GsWWw4lflf8dj3MJDqXW5blEWjgcbVJDwsq4VwJ19lrEnymS9QxZgt8pyXdQZbP0QvUAztpbmEHBLq54bjf0bhnmhS4bP0QvUwtyz67TYJDPqGRb8GoDEqkTALRw20taJx4wjuoEqsbDWrUOdw8GQDzZ1DZbMmw8(T6R)Af(JeJSThK0docChKCdDOKCBdTIqKT1VvFQqJyiJem6zOXoOy40mKHw9PGFggAWCqjyyl8LILc(HKBZXoOy48Gfpiyo4edHG3Xolji8xRX6(LiVgmg2E1RzJj(hS4bP0QvUAztpbmEHBLq54bjf0bhbUdw8GuA1khyYyX73QV(Rv4AapyXdQ2Lnx3nhyYyX73QV(Rv4psmY2EqspOdGZqhkj32qRiezB9B1Nk0igYaVrpdn2bfdNMHm0Qpf8ZWqlbdBHVuSuWpKCBo2bfdNhS4bbZbP0QvoWKXI3VvF9xRW1aEWIhuNdsPvRC1YMEcy8c3kHYXdskOdoAyoyXdsPvRCTMWY03BLh7sHaxd4bD68GuA1kxTSPNagVWTsOC8GKc6GJCrh0PZdQ2Lnx3nhyYyX73QV(Rv4psmY2EqWEqDDWIhKsRw5QLn9eW4fUvcLJhKuqhCejCqYn0HsYTn0kcr2w)w9PcnIrm0lflf8dj32ONHSrg9m0yhumCAgYqR(uWpddDOKeq0Jnsmr7bjf0b11blEqDoOemSfEzieWp7sVv2Nih7GIHZd605bvBp1sHJaIF9xRWXoOy48GoDEWxRX6(LiNkLSl9QLn5yhumCEqYn0HsYTn0psCFlYqR17oBbFJyiZbJEgASdkgondzOvFk4NHHgmhCUcV(Rv8veq85sQCm7Ydw8GG5GuA1k3XKXYU0tmueYg5Aan0HsYTn0ew3SSl9uSWkgXqMUm6zOXoOy40mKHw9PGFggAkTAL7yYyzx6jgkczJ8hdLCWIh0cezmVeFjkwE9xRyv6leWdskOd6WblEqDoiLwTYNyieS(PgYTsOC8GGoij5GoDEqWCWjgcbF0t)evH(CjvoMD5bD68GG5GQfqSJw4Dwsq81api5g6qj52g66VwXQ0xiGgXqgjy0ZqJDqXWPzidDOKCBd9sXsb)qqdT6tb)mm0uA1k3XKXYU0tmueYg5pgk5GoDEqWCqkTAL)jrKRb8GfpOfiYyEj(suSCcRBw2LEkwyLdskOdQldTsFfd9s8LOynKnYigYaVrpdn2bfdNMHm0Qpf8ZWqBbImMxIVeflVKfQmy(ycy0k8GKc6GoCWIhuNd(ADQ8ax34ZNynvPCqWEWrG7GoDEWxRrUKerVSEhoiPhSunpi5h0PZdQZbNiLwTY)Wf2pvi3kHYXdc2dc(d605bNiLwTY)Wf2pvi)rIr22dc2doc8hKCdDOKCBdDjluzW8XeWOvOrmKnmg9m0yhumCAgYqR(uWpddTA7PwkC8JzQcj7spfBDZXoOy48GfpiLwTYXpMPkKSl9uS1n3kHYXdc6GoCWIhmusci6XgjMO9GGo4idDOKCBdD9xR4TYNoIgXqgjZONHg7GIHtZqgA1Nc(zyOP0Qv(NerUgWdw8GwGiJ5L4lrXYjSUzzx6PyHvoiPGoOdg6qj52gAcRBw2LEkwyfJyiJKy0ZqJDqXWPzidT6tb)mm0wGiJ5L4lrXYlzHkdMpMagTcpiPGoOdg6qj52g6swOYG5JjGrRqJyiZfz0ZqJDqXWPzidDOKCBdD9xR4TYNoIgA1Nc(zyObZbLGHTWdadw0kcih7GIHZdw8GG5GuA1k3XKXYU0tmueYg5AapOtNhucg2cpamyrRiGCSdkgopyXdcMdsPvR8pjICnGgAL(kg6L4lrXAiBKrmKncCg9m0yhumCAgYqR(uWpddnLwTY)KiY1aAOdLKBBOjSUzzx6PyHvmIHSrJm6zOXoOy40mKHousUTHEPyPGFiOHwPVIHEj(suSgYgzeJyOTs0Z4Ng9mKnYONHg7GIHtZqgA1Nc(zyOLGHTWldHa(zx6TY(e5yhumCEqNopOA7PwkCeq8R)Afo2bfdNh0PZd(Anw3Ve5uPKDPxTSjh7GIHtdDOKCBd9Je33Im0A9UZwW3igYCWONHg7GIHtZqgA1Nc(zyObZbNyie8o2zjbH)Anw3Ve5F4c7Nk8GfpOohCIuA1k)dxy)uHCRekhpiypi4pOtNhCIuA1k)dxy)uH8hjgzBpiypij7GKBOdLKBBOlzHkdMpMagTcnIHmDz0ZqJDqXWPzidT6tb)mm0QDzZ1DZFK4(wKHwR3D2c(8hjgzBpiybDqhoij(GLQ5blEqjyyl8YqiGF2LERSpro2bfdNg6qj52g66VwXBLpDenIHmsWONHg7GIHtZqgA1Nc(zyOvBp1sHJFmtvizx6PyRBo2bfdNhS4bP0Qvo(XmvHKDPNITU5wjuoEqqh0Hd605bvBp1sHR1mmSeWPV(y7c6ZXoOy48GfpiLwTY1Aggwc40xFSDb95psmY2EqWEqDDWIhKsRw5AnddlbC6Rp2UG(CnGg6qj52g66VwXBLpDenIHmWB0ZqJDqXWPzidT6tb)mm0uA1k)tIixdOHousUTHMW6MLDPNIfwXigYggJEgASdkgondzOvFk4NHHgmhKsRw51FDbS9a1ywKRb8GfpOemSfE9xxaBpqnMf5yhumCAOdLKBBOxkwk4hcAedzKmJEgASdkgondzOvFk4NHH(16u5bUUXNpXAQs5GG9G6CWrG)GfEqjyyl8xRtLpebBTqYT5yhumCEqs8b11bj3qhkj32qx)1kER8PJOrmKrsm6zOXoOy40mKHw9PGFgg6xRtLh46gF(eRPkLds6b15Goa(dw4bLGHTWFTov(qeS1cj3MJDqXW5bjXhuxhKCdDOKCBd9sXsb)qqJyiZfz0Zqhkj32qx)1kER8PJOHg7GIHtZqgXq2iWz0Zqhkj32qty)2VvV7Sf8n0yhumCAgYigYgnYONHousUTHoEv0Ox2)Xwm0yhumCAgYigXqRwaXoAXA0Zq2iJEgASdkgondzOvFk4NHH(JC6raXw4XCA5zFqsp4iWFqNopiyo4h50JaITWJ50YrxMwXEqNopyOKeq0Jnsmr7bjf0bDWqhkj32qpXqiy9tn0igYCWONHg7GIHtZqgA1Nc(zyOdLKaIESrIjApiOdo6Gfp4R1PYdCDJpFI1uLYbj9G66GfpOAx2CD3CGjJfVFR(6VwH)iXiB7bb7b11blEqWCqjyylCQhdHGFREB2ZpkxBWXoOy48GfpOohemh8JC6raXw4XCA5OltRypOtNh8JC6raXw4XCA5zFqsp4iWFqYn0HsYTn0w3Xtm7spX0kgXqMUm6zOXoOy40mKHw9PGFgg6qjjGOhBKyI2dskOd6WblEqWCqjyylCQhdHGFREB2ZpkxBWXoOy40qhkj32qBDhpXSl9etRyedzKGrpdn2bfdNMHm0Qpf8ZWqlbdBHt9yie8B1BZE(r5Ado2bfdNhS4b15GuA1kN6Xqi43Q3M98JY1gCnGhS4b15GHssarp2iXeThe0bhDWIh816u5bUUXNpXAQs5GKEqsaCh0PZdgkjbe9yJet0EqsbDqhoyXd(ADQ8ax34ZNynvPCqsp4WaUds(bD68GG5GuA1kN6Xqi43Q3M98JY1gCnGhS4bv7YMR7Mt9yie8B1BZE(r5Ad(JeJSThKCdDOKCBdT1D8eZU0tmTIrmKbEJEgASdkgondzOvFk4NHHousci6XgjMO9GGo4Odw8GQDzZ1DZbMmw8(T6R)Af(JeJSTheShuxhS4b15GG5GFKtpci2cpMtlhDzAf7bD68GFKtpci2cpMtlp7ds6bhb(dsUHousUTHoOwIzhsUTNLePmIHSHXONHg7GIHtZqgA1Nc(zyOdLKaIESrIjApiPGoOdg6qj52g6GAjMDi52EwsKYigYizg9m0yhumCAgYqR(uWpddDOKeq0Jnsmr7bbDWrhS4bv7YMR7MdmzS49B1x)1k8hjgzBpiypOUoyXdQZbbZb)iNEeqSfEmNwo6Y0k2d605b)iNEeqSfEmNwE2hK0doc8hKCdDOKCBdTLqOCKHEHa61A37le03igYijg9m0yhumCAgYqR(uWpddDOKeq0Jnsmr7bjf0bDWqhkj32qBjekhzOxiGET29(cb9nIrm0uR1dCxw2Lg9mKnYONHg7GIHtZqgA1Nc(zyOP0Qv(NerUgqdDOKCBdnH1nl7spflSIrmK5Grpdn2bfdNMHm0Qpf8ZWqhkjbe9yJet0EqsbDqhoOtNh81AKljr0lRh8heSGoyPAEWIhuNdkbdBHxgcb8ZU0BL9jYXoOy48GoDEq12tTu4iG4x)1kCSdkgopOtNh81ASUFjYPsj7sVAzto2bfdNhKCdDOKCBd9Je33Im0A9UZwW3igY0Lrpdn2bfdNMHm0HsYTn0lflf8dbn0Qpf8ZWq)ADQ8ax34ZNynvPCqsbDqhaVHwPVIHEj(suSgYgzedzKGrpdn2bfdNMHm0Qpf8ZWq)ADQ8ax34ZNynvPCqWEqha3blEqlqKX8s8LOy5LSqLbZhtaJwHhKuqh0Hdw8GQDzZ1DZbMmw8(T6R)Af(JeJSThK0dcEdDOKCBdDjluzW8XeWOvOrmKbEJEgASdkgondzOdLKBBOR)AfVv(0r0qR(uWpdd9R1PYdCDJpFI1uLYbb7bDaChS4bv7YMR7MdmzS49B1x)1k8hjgzBpiPhe8gAL(kg6L4lrXAiBKrmKnmg9m0yhumCAgYqR(uWpddnLwTYDmzSSl9edfHSr(JHsoyXd(ADQ8ax34ZNynvPCqspOohCe4pyHhucg2c)16u5drWwlKCBo2bfdNhKeFqDDqYpyXdAbImMxIVeflV(RvSk9fc4bjf0bD4GfpOohKsRw5tmecw)ud5wjuoEqqhKKCqNopiyo4edHGp6PFIQqFUKkhZU8GoDEqWCq1ci2rl8olji(AGhKCdDOKCBdD9xRyv6leqJyiJKz0ZqJDqXWPzidT6tb)mm0VwNkpW1n(8jwtvkhKuqhuNdQlWFWcpOemSf(R1PYhIGTwi52CSdkgopij(G66GKFWIh0cezmVeFjkwE9xRyv6leWdskOd6WblEqDoiLwTYNyieS(PgYTsOC8GGoij5GoDEqWCWjgcbF0t)evH(CjvoMD5bD68GG5GQfqSJw4Dwsq81api5g6qj52g66VwXQ0xiGgXqgjXONHg7GIHtZqg6qj52g6LILc(HGgA1Nc(zyOFTovEGRB85tSMQuoiPGoOohuxG)GfEqjyyl8xRtLpebBTqYT5yhumCEqs8b11bj3qR0xXqVeFjkwdzJmIHmxKrpdn2bfdNMHm0Qpf8ZWqR2Lnx3nhyYyX73QV(Rv4psmY2Eqsp4R1ixsIOxwpjCWIh816u5bUUXNpXAQs5GG9GKa4oyXdAbImMxIVeflVKfQmy(ycy0k8GKc6GoyOdLKBBOlzHkdMpMagTcnIHSrGZONHg7GIHtZqg6qj52g66VwXBLpDen0Qpf8ZWqR2Lnx3nhyYyX73QV(Rv4psmY2Eqsp4R1ixsIOxwpjCWIh816u5bUUXNpXAQs5GG9GKa4m0k9vm0lXxII1q2iJyednWhvlrQqm6zedDSOrpdzJm6zOdLKBBOFK4(wKHwR3D2c(gASdkgondzedzoy0ZqJDqXWPzidT6tb)mm0sWWw41FTIvPVqa5yhumCAOdLKBBOlzHkdMpMagTcnIHmDz0ZqJDqXWPzidDOKCBdD9xR4TYNoIgA1Nc(zyOv7YMR7M)iX9TidTwV7Sf85psmY2EqWc6GoCqs8blvZdw8GsWWw4LHqa)Sl9wzFICSdkgon0k9vm0lXxII1q2iJyiJem6zOXoOy40mKHw9PGFggAkTAL)jrKRb0qhkj32qtyDZYU0tXcRyedzG3ONHg7GIHtZqgA1Nc(zyOP0QvUJjJLDPNyOiKnYFmuYblEqDoiyo4edHGp6PFIQqFUKkhZU8GfpOAbe7OfENLeeFnWd605bbZbvlGyhTW7SKG4RbEqYn0HsYTn01FTIvPVqanIHSHXONHg7GIHtZqgA1Nc(zyOFTovEGRB85tSMQuoiypOohCe4pyHhucg2c)16u5drWwlKCBo2bfdNhKeFqDDqYn0HsYTn0LSqLbZhtaJwHgXqgjZONHg7GIHtZqg6qj52g66VwXBLpDen0Qpf8ZWq)ADQ8ax34ZNynvPCqWEqDo4iWFWcpOemSf(R1PYhIGTwi52CSdkgopij(G66GKBOv6RyOxIVefRHSrgXqgjXONHousUTH(rI7BrgATE3zl4BOXoOy40mKrmK5Im6zOXoOy40mKHw9PGFggAWCWjgcbF0t)evH(CjvoMD5blEq1ci2rl8olji(AGh0PZdcMdQwaXoAH3zjbXxd0qhkj32qx)1kwL(cb0igYgboJEgASdkgondzOdLKBBOxkwk4hcAOvFk4NHH(16u5bUUXNpXAQs5GKEqDoOdG)GfEqjyyl8xRtLpebBTqYT5yhumCEqs8b11bj3qR0xXqVeFjkwdzJmIHSrJm6zOdLKBBOlzHkdMpMagTcn0yhumCAgYigYg5Grpdn2bfdNMHm0HsYTn01FTI3kF6iAOv6RyOxIVefRHSrgXq2iDz0Zqhkj32qty)2VvV7Sf8n0yhumCAgYigYgrcg9m0HsYTn0XRIg9Y(p2IHg7GIHtZqgXigAQ16Lu5y2Lg9mKnYONHg7GIHtZqg6qj52g6LILc(HGgA1Nc(zyOFTovEGRB85tSMQuoiPGo4WaodTsFfd9s8LOynKnYigYCWONHg7GIHtZqgA1Nc(zyOLGHTWldHa(zx6TY(e5yhumCEqNopOA7PwkCeq8R)Afo2bfdNh0PZd(Anw3Ve5uPKDPxTSjh7GIHZd605bdLKaIESrIjApiPGoOdg6qj52g6hjUVfzO16DNTGVrmKPlJEgASdkgondzOvFk4NHHMsRw5Fse5AapyXdQZbFTovEGRB85tSMQuoiypi4b)bD68GVwJCjjIEz966GGf0blvZd605bTargZlXxIILtyDZYU0tXcRCqsbDqhoi5g6qj52gAcRBw2LEkwyfJyiJem6zOXoOy40mKHousUTHEPyPGFiOHw9PGFgg6xRrUKerVSEs4GG9GLQ5bD68GVwNkpW1n(8jwtvkhKuqhKeaVHwPVIHEj(suSgYgzedzG3ONHg7GIHtZqgA1Nc(zyOP0QvUJjJLDPNyOiKnY1aEWIh0cezmVeFjkwE9xRyv6leWdskOd6WblEqDoiyo4edHGp6PFIQqFUKkhZU8GfpOAbe7OfENLeeFnWd605bbZbvlGyhTW7SKG4RbEqYn0HsYTn01FTIvPVqanIHSHXONHg7GIHtZqgA1Nc(zyOFTovEGRB85tSMQuoiPGoijaUdw8GVwJCjjIEz966GKEWs10qhkj32qty)2VvV7Sf8nIHmsMrpdn2bfdNMHm0Qpf8ZWqBbImMxIVeflV(RvSk9fc4bjf0bD4GfpOohKsRw5tmecw)ud5wjuoEqqhKKCqNopiyo4edHGp6PFIQqFUKkhZU8GoDEqWCq1ci2rl8olji(AGhKCdDOKCBdD9xRyv6leqJyiJKy0ZqJDqXWPzidDOKCBd9sXsb)qqdT6tb)mm0VwNkpW1n(8jwtvkhK0d6a4pyXd(AnEqspOUm0k9vm0lXxII1q2iJyiZfz0ZqJDqXWPzidT6tb)mm0uA1k)tIixdOHousUTHMW6MLDPNIfwXigYgboJEgASdkgondzOvFk4NHH(16u5bUUXNpXAQs5GKEqWdodDOKCBdD8QOrVS)JTyeJyONyn0yIrpdzJm6zOdLKBBOjM90xFeDb0qJDqXWPziJyiZbJEgASdkgondzOvFk4NHHgmhCUcV(Rv8veq85sQCm7Ydw8G6Cqjyyl8uHQaih7GIHZd605bv7YMR7Mt9yie8B1BZE(r5Ad(JeJSThK0doc8h0PZdkbdBHVuSuWpKCBo2bfdNhS4bv7YMR7MdmzS49B1x)1k8hjgzBpiyp4CfE9xR4RiG4ZFKyKT9GKBOdLKBBOjSUzzx6PyHvmIHmDz0ZqJDqXWPzidT6tb)mm0uA1kpv67LGTTL)iXiB7bblOdwQMhS4bP0QvEQ03lbBBlxd4blEqlqKX8s8LOy5LSqLbZhtaJwHhKuqh0Hdw8G6CqWCqjyylCQhdHGFREB2ZpkxBWXoOy48GoDEq1US56U5upgcb)w92SNFuU2G)iXiB7bj9GJa)bj3qhkj32qxYcvgmFmbmAfAedzKGrpdn2bfdNMHm0Qpf8ZWqtPvR8uPVxc22w(JeJSTheSGoyPAEWIhKsRw5PsFVeSTTCnGhS4b15GG5GsWWw4upgcb)w92SNFuU2GJDqXW5bD68GQDzZ1DZPEmec(T6Tzp)OCTb)rIr22ds6bhb(dsUHousUTHU(Rv8w5thrJyid8g9m0yhumCAgYqhkj32qRcgZhkj32ZsRyOzPv8Dqen0QfqSJwSgXq2Wy0ZqJDqXWPzidDOKCBdTkymFOKCBplTIHMLwX3br0qR2Lnx3T1igYizg9m0yhumCAgYqR(uWpddTemSfUAztpbmEHJDqXW5blEqDoiLwTYvlB6jGXlCRekhpiPGo4iWDWIhuNdorkTAL)HlSFQqUvcLJhe0bb)bD68GG5GtmecEh7SKGWFTgR7xI8pCH9tfEqYpOtNhSMLee)JeJSTheSGoyPAEqYn0HsYTn0QGX8HsYT9S0kgAwAfFherdTAztpbmEXigYijg9m0yhumCAgYqR(uWpddnLwTYPEmec(T6Tzp)OCTbxdOHousUTH(1AFOKCBplTIHMLwX3br0qtTwVKkhZU0igYCrg9m0yhumCAgYqR(uWpddTemSfo1JHqWVvVn75hLRn4yhumCEWIhuNdQ2Lnx3nN6Xqi43Q3M98JY1g8hjgzBpiyp4iWDqYn0HsYTn0Vw7dLKB7zPvm0S0k(oiIgAQ16bUll7sJyiBe4m6zOXoOy40mKHw9PGFggAkTALdmzS49B1x)1kCnGhS4bLGHTWxkwk4hsUnh7GIHtdDOKCBd9R1(qj52EwAfdnlTIVdIOHEPyPGFi52gXq2Org9m0yhumCAgYqR(uWpddTemSf(sXsb)qYT5yhumCEWIhuTlBUUBoWKXI3VvF9xRWFKyKT9GG9GJaNHousUTH(1AFOKCBplTIHMLwX3br0qVuSuWpKCBpWDzzxAedzJCWONHg7GIHtZqgA1Nc(zyOdLKaIESrIjApiPGoOdg6qj52g6xR9HsYT9S0kgAwAfFherdDSOrmKnsxg9m0yhumCAgYqhkj32qRcgZhkj32ZsRyOzPv8Dqen0wj6z8tJyedTAx2CD3wJEgYgz0ZqJDqXWPzidT6tb)mm0QDzZ1DZbMmw8(T6R)Af(JXu)d605bv7YMR7MdmzS49B1x)1k8hjgzBpiPh0bWzOdLKBBO1SOpfKO1igYCWONHg7GIHtZqgA1Nc(zyOP0QvoWKXI3VvF9xRW1aEWIhKsRw5irGRB89VwJE3yaCBUgqdDOKCBdnWvYTnIHmDz0ZqJDqXWPzidT6tb)mm0uA1khyYyX73QV(Rv4AapyXdsPvRCKiW1n((xRrVBmaUnxdOHousUTHMIT70x1E9nIHmsWONHg7GIHtZqgA1Nc(zyOP0QvoWKXI3VvF9xRW1aAOdLKBBOPW3IVJzxAedzG3ONHg7GIHtZqgA1Nc(zyO15GG5GuA1khyYyX73QV(Rv4AapyXdgkjbe9yJet0EqsbDqhoi5h0PZdcMdsPvRCGjJfVFR(6VwHRb8GfpOoh81AKpXAQs5GKc6GG)Gfp4R1PYdCDJpFI1uLYbjf0bhgWDqYn0HsYTn0XRIg9a1yw0igYggJEgASdkgondzOvFk4NHHMsRw5atglE)w91FTcxdOHousUTHMLLeeRNKhTzjrSfJyiJKz0ZqJDqXWPzidT6tb)mm0uA1khyYyX73QV(Rv4AapyXdsPvRCKiW1n((xRrVBmaUnxdOHousUTHoAfALpyEvWygXqgjXONHg7GIHtZqgA1Nc(zyOP0QvoWKXI3VvF9xRWFKyKT9GGf0bjjhS4bP0Qvose46gF)R1O3nga3MRb0qhkj32qxZhPy7onIHmxKrpdn2bfdNMHm0Qpf8ZWqtPvRCGjJfVFR(6VwHRb8GfpyOKeq0Jnsmr7bbDWrhS4b15GuA1khyYyX73QV(Rv4psmY2EqWEqWFWIhucg2cxTSPNagVWXoOy48GoDEqWCqjyylC1YMEcy8ch7GIHZdw8GuA1khyYyX73QV(Rv4psmY2EqWEqDDqYn0HsYTn0urPFRE5tLJwJyiBe4m6zOXoOy40mKHw9PGFggAjyyl8LILc(HKBZXoOy48GfpOohuTlBUUBoWKXI3VvF9xRWFmM6FWIh81AKljr0lRh8hK0dwQMhS4bFTovEGRB85tSMQuoiPGo4iWDqNopiLwTYbMmw8(T6R)AfUgWdw8GVwJCjjIEz9G)GKEWs18GKFqNopynlji(hjgzBpiypOdGZqhkj32qJebUUX3)An6DJbWTnIHSrJm6zOXoOy40mKHw9PGFggAjyylCQhdHGFREB2ZpkxBWXoOy48Gfp4R1PYdCDJpFI1uLYbj9GKa4oyXd(AnYLKi6L1d(ds6blvZdw8G6CqkTALt9yie8B1BZE(r5AdUgWd605bRzjbX)iXiB7bb7bDaChKCdDOKCBdnse46gF)R1O3nga32igYg5Grpdn2bfdNMHm0Qpf8ZWqlbdBHNkufa5yhumCEWIh81A8GG9G6Yqhkj32qJebUUX3)An6DJbWTnIHSr6YONHg7GIHtZqgA1Nc(zyOLGHTWPEmec(T6Tzp)OCTbh7GIHZdw8G6Cq1US56U5upgcb)w92SNFuU2G)iXiB7bD68GQDzZ1DZPEmec(T6Tzp)OCTb)XyQ)blEWxRtLh46gF(eRPkLdc2domG7GKBOdLKBBObMmw8(T6R)AfJyiBejy0ZqJDqXWPzidT6tb)mm0sWWw4Pcvbqo2bfdNhS4bbZbP0QvoWKXI3VvF9xRW1aAOdLKBBObMmw8(T6R)AfJyiBe4n6zOXoOy40mKHw9PGFggAjyyl8LILc(HKBZXoOy48GfpOohucg2cVmec4NDP3k7tKJDqXW5blEqkTAL)iX9TidTwV7Sf85AapOtNhemhucg2cVmec4NDP3k7tKJDqXW5bj3qhkj32qdmzS49B1x)1kgXq2OHXONHg7GIHtZqgA1Nc(zyOP0QvoWKXI3VvF9xRW1aAOdLKBBOPEmec(T6Tzp)OCTHrmKnIKz0ZqJDqXWPzidT6tb)mm0uA1khyYyX73QV(Rv4psmY2EqWEWs18GfpiLwTYbMmw8(T6R)AfUgWdw8GG5GsWWw4lflf8dj3MJDqXWPHousUTHU(RvCR)t06RAV(gXq2isIrpdn2bfdNMHm0Qpf8ZWqhkjbe9yJet0EqsbDqhoyXdQZbP0QvoWKXI3VvF9xRW1aEWIhKsRw5atglE)w91FTc)rIr22dc2dwQMh0PZd(ro9iGyl8yoTC0LPvShS4b)iNEeqSfEmNw(JeJSTheShSunpOtNhSMLee)JeJSTheShSunpi5g6qj52g66VwXT(prRVQ96BedzJCrg9m0yhumCAgYqR(uWpddTemSf(sXsb)qYT5yhumCEWIhemhKsRw5atglE)w91FTcxd4blEqDoOohKsRw5AnHLPV3kp2LcbUgWd605bbZbNyie8o2zjbH)Anw3Ve51GXW2REnBmX)GKFWIhuNdorkTAL)HlSFQqUvcLJhe0bb)bD68GG5GtmecEh7SKGWFTgR7xI8pCH9tfEqYpi5g6qj52g66VwXT(prRVQ96BedzoaoJEgASdkgondzOvFk4NHHwcg2cN6Xqi43Q3M98JY1gCSdkgopyXd(ADQ8ax34ZNynvPCqspijaUdw8GVwJhKuqhuxhS4bP0QvoWKXI3VvF9xRW1aEqNopiyoOemSfo1JHqWVvVn75hLRn4yhumCEWIh816u5bUUXNpXAQs5GKc6GoaEdDOKCBdnb9bUcb8jMkpWhTyRqJyiZHrg9m0yhumCAgYqR(uWpddnLwTYbMmw8(T6R)AfUgqdDOKCBd9hPf9tmMgXqMdoy0ZqJDqXWPzidT6tb)mm0Hssarp2iXeThKuqh0Hdw8G6CqGOWljSAm(JeJSTheShSunpOtNhuIVefUKerVS(zIheShSunpi5g6qj52gABO(SMQmyEGHsmIHmh0Lrpdn2bfdNMHm0Qpf8ZWqhkjbe9yJet0Eqspi4pOtNh81ASUFjYbsaJFjUnA5yhumCAOdLKBBONyie8rp9tuf6BeJyednG4BZTnK5a4CaCJCaCJm0UJVZU0AOjPhwdBYCXKrsP7dEq9iGhmjcCF5G19p4GLILc(HKB7bUll7Ybh8rsoT8X5bTlr8GHMSedbNhuri6s0YVXfiB8GJ09bl42aIVGZdoqcg2chGdoOShCGemSfoa5yhumCo4G6mYLKZVXfiB8GJ09bl42aIVGZdo41ASUFjYb4Gdk7bh8Anw3Ve5aKJDqXW5GdQZixso)gxGSXdos3hSGBdi(cop4a12tTu4aCWbL9GduBp1sHdqo2bfdNdoOoJCj58B8nMKEynSjZftgjLUp4b1JaEWKiW9Ldw3)GdulB6jGXldo4JKCA5JZdAxI4bdnzjgcopOIq0LOLFJlq24bDq3hSGBdi(cop4ajyylCao4GYEWbsWWw4aKJDqXW5GdQZixso)gxGSXdQlDFWcUnG4l48GdKGHTWb4Gdk7bhibdBHdqo2bfdNdoOoJCj58BCbYgpijO7dwWTbeFbNhCGemSfoahCqzp4ajyylCaYXoOy4CWb1zKljNFJlq24bbVUpyb3gq8fCEWbsWWw4aCWbL9GdKGHTWbih7GIHZbhuNrUKC(n(gtspSg2K5IjJKs3h8G6rapyse4(YbR7FWblflf8dj3EWbFKKtlFCEq7sepyOjlXqW5bveIUeT8BCbYgp4iDFWcUnG4l48GdKGHTWb4Gdk7bhibdBHdqo2bfdNdoOoJCj58BCbYgp4iDFWcUnG4l48GdETgR7xICao4GYEWbVwJ19lroa5yhumCo4G6mYLKZVXfiB8GJ09bl42aIVGZdoqT9ulfoahCqzp4a12tTu4aKJDqXW5GdQZixso)gxGSXdom6(GfCBaXxW5bhO2EQLchGdoOShCGA7PwkCaYXoOy4CWb1zKljNFJlq24bDr6(GfCBaXxW5bhibdBHdWbhu2doqcg2chGCSdkgohCqDCWLKZVX3ys6H1WMmxmzKu6(Ghupc4btIa3xoyD)doGATEjvoMD5Gd(ijNw(48G2LiEWqtwIHGZdQieDjA534cKnEqh09bl42aIVGZdoqcg2chGdoOShCGemSfoa5yhumCo4G6mYLKZVXfiB8GoO7dwWTbeFbNhCWR1yD)sKdWbhu2do41ASUFjYbih7GIHZbhuNrUKC(nUazJh0bDFWcUnG4l48GduBp1sHdWbhu2doqT9ulfoa5yhumCo4G6mYLKZVX3ys6H1WMmxmzKu6(Ghupc4btIa3xoyD)doWkrpJFo4GpsYPLpopODjIhm0KLyi48GkcrxIw(nUazJhCKUpyb3gq8fCEWbsWWw4aCWbL9GdKGHTWbih7GIHZbhuNrUKC(nUazJhCKUpyb3gq8fCEWbVwJ19lroahCqzp4GxRX6(LihGCSdkgohCWqoijYWTahuNrUKC(nUazJhCKUpyb3gq8fCEWbQTNAPWb4Gdk7bhO2EQLchGCSdkgohCqDg5sY534cKnEqDP7dwWTbeFbNhCGemSfoahCqzp4ajyylCaYXoOy4CWbd5GKid3cCqDg5sY534cKnEqsq3hSGBdi(cop4a12tTu4aCWbL9GduBp1sHdqo2bfdNdoOoo4sY534cKnEWHr3hSGBdi(cop4ajyylCao4GYEWbsWWw4aKJDqXW5GdgYbjrgUf4G6mYLKZVXfiB8GKmDFWcUnG4l48GdKGHTWb4Gdk7bhibdBHdqo2bfdNdoOoJCj58BCbYgpijr3hSGBdi(cop4ajyylCao4GYEWbsWWw4aKJDqXW5GdQZixso)gFJjPhwdBYCXKrsP7dEq9iGhmjcCF5G19p4aQ16bUll7Ybh8rsoT8X5bTlr8GHMSedbNhuri6s0YVXfiB8GoO7dwWTbeFbNhCGemSfoahCqzp4ajyylCaYXoOy4CWb1zKljNFJlq24bDq3hSGBdi(cop4GxRX6(LihGdoOShCWR1yD)sKdqo2bfdNdoOoJCj58BCbYgpOd6(GfCBaXxW5bhO2EQLchGdoOShCGA7PwkCaYXoOy4CWb1zKljNFJlq24bhgDFWcUnG4l48GdKGHTWb4Gdk7bhibdBHdqo2bfdNdoOoJCj58BCbYgpijt3hSGBdi(cop4ajyylCao4GYEWbsWWw4aKJDqXW5GdQZixso)gxGSXdss09bl42aIVGZdoqcg2chGdoOShCGemSfoa5yhumCo4G6mYLKZVX3ys6H1WMmxmzKu6(Ghupc4btIa3xoyD)doqTlBUUB7Gd(ijNw(48G2LiEWqtwIHGZdQieDjA534cKnEWrGt3hSGBdi(cop4ajyylCao4GYEWbsWWw4aKJDqXW5GdQZixso)gxGSXdoAKUpyb3gq8fCEWbsWWw4aCWbL9GdKGHTWbih7GIHZbhuNrUKC(nUazJhCKd6(GfCBaXxW5bhibdBHdWbhu2doqcg2chGCSdkgohCqDg5sY534cKnEWr6s3hSGBdi(cop4ajyylCao4GYEWbsWWw4aKJDqXW5GdQZixso)gxGSXdoIe09bl42aIVGZdoqcg2chGdoOShCGemSfoa5yhumCo4G6mYLKZVXfiB8GJaVUpyb3gq8fCEWbsWWw4aCWbL9GdKGHTWbih7GIHZbhuNrUKC(nUazJhCejt3hSGBdi(cop4ajyylCao4GYEWbsWWw4aKJDqXW5GdgYbjrgUf4G6mYLKZVXfiB8GJCr6(GfCBaXxW5bhibdBHdWbhu2doqcg2chGCSdkgohCqDg5sY534cKnEqhaNUpyb3gq8fCEWbsWWw4aCWbL9GdKGHTWbih7GIHZbhuhhCj58BCbYgpOd6s3hSGBdi(cop4GxRX6(LihGdoOShCWR1yD)sKdqo2bfdNdoyihKez4wGdQZixso)gFJjPhwdBYCXKrsP7dEq9iGhmjcCF5G19p4a1ci2rl2bh8rsoT8X5bTlr8GHMSedbNhuri6s0YVXfiB8GoO7dwWTbeFbNhCGemSfoahCqzp4ajyylCaYXoOy4CWb1zKljNFJlq24b1LUpyb3gq8fCEWbsWWw4aCWbL9GdKGHTWbih7GIHZbhmKdsImClWb1zKljNFJlq24bjbDFWcUnG4l48GdKGHTWb4Gdk7bhibdBHdqo2bfdNdoOoJCj58B8nMKEynSjZftgjLUp4b1JaEWKiW9Ldw3)GdMyn0yYGd(ijNw(48G2LiEWqtwIHGZdQieDjA534cKnEqh09bl42aIVGZdoqcg2chGdoOShCGemSfoa5yhumCo4G64GljNFJlq24b1LUpyb3gq8fCEWbsWWw4aCWbL9GdKGHTWbih7GIHZbhuNrUKC(nUazJhKe09bl42aIVGZdoqcg2chGdoOShCGemSfoa5yhumCo4G6mYLKZVXfiB8GKmDFWcUnG4l48GdKGHTWb4Gdk7bhibdBHdqo2bfdNdoOoJCj58BCbYgpOls3hSGBdi(cop4ajyylCao4GYEWbsWWw4aKJDqXW5GdQZixso)gxGSXdocC6(GfCBaXxW5bhibdBHdWbhu2doqcg2chGCSdkgohCWqoijYWTahuNrUKC(nUazJhC0iDFWcUnG4l48GdKGHTWb4Gdk7bhibdBHdqo2bfdNdoOoJCj58B8nMKEynSjZftgjLUp4b1JaEWKiW9Ldw3)GdIfhCWhj50YhNh0UeXdgAYsmeCEqfHOlrl)gxGSXd6GUpyb3gq8fCEWbsWWw4aCWbL9GdKGHTWbih7GIHZbhmKdsImClWb1zKljNFJlq24b1LUpyb3gq8fCEWbsWWw4aCWbL9GdKGHTWbih7GIHZbhmKdsImClWb1zKljNFJlq24bhgDFWcUnG4l48GdKGHTWb4Gdk7bhibdBHdqo2bfdNdoOoJCj58BCbYgpijt3hSGBdi(cop4ajyylCao4GYEWbsWWw4aKJDqXW5GdQZixso)gxGSXdocC6(GfCBaXxW5bhibdBHdWbhu2doqcg2chGCSdkgohCqDg5sY534BSlMiW9fCEWrG7GHsYTpilTILFJn0wGOYqMdGFKHg4V1KHg6H)GdNyieoij)oljihC44xRCJh(doCIkKif(hCyC9Goaoha3n(gp8hKMqmx3SON2dQJlIdoUdKFJVXd)bjrCjQ0eCEqeq81)GssepOqapyOK9pyApyayKSGIH8BCOKCBliIzp91hrxaVXd)bhwabY0)Gdh)ALdoCGaI)bJEEqIr2sK9bDXk9pOEbBB7nousUTTqqaGW6MLDPNIfwX1SccmZv41FTIVIaIpxsLJzxwuhjyyl8uHQaOtNQDzZ1DZPEmec(T6Tzp)OCTb)rIr2wshbENoLGHTWxkwk4hsUDr1US56U5atglE)w91FTc)rIr2wWoxHx)1k(kci(8hjgzBj)ghkj32wiiauYcvgmFmbmAf6AwbrPvR8uPVxc22w(JeJSTGfuPAwKsRw5PsFVeSTTCnGfTargZlXxIILxYcvgmFmbmAfskihkQdyKGHTWPEmec(T6Tzp)OCTHtNQDzZ1DZPEmec(T6Tzp)OCTb)rIr2wshbEYVXHsYTTfcca1FTI3kF6i6AwbrPvR8uPVxc22w(JeJSTGfuPAwKsRw5PsFVeSTTCnGf1bmsWWw4upgcb)w92SNFuU2WPt1US56U5upgcb)w92SNFuU2G)iXiBlPJap534H)GfKWUw8GdlLKBFqwALdk7bFT(ghkj32wiiaOcgZhkj32ZsR4AherqQfqSJwS34qj522cbbavWy(qj52EwAfx7GicsTlBUUB7nousUTTqqaqfmMpusUTNLwX1oiIGulB6jGXlUMvqsWWw4QLn9eW4LI6qPvRC1YMEcy8c3kHYrsbncCf1zIuA1k)dxy)uHCRekhbbENobZedHG3Xolji8xRX6(Li)dxy)uHK70znlji(hjgzBblOs1K8BCOKCBBHGaWR1(qj52EwAfx7GicIATEjvoMDPRzfeLwTYPEmec(T6Tzp)OCTbxd4nousUTTqqa41AFOKCBplTIRDqebrTwpWDzzx6AwbjbdBHt9yie8B1BZE(r5AJI6O2Lnx3nN6Xqi43Q3M98JY1g8hjgzBb7iWr(nousUTTqqa41AFOKCBplTIRDqebTuSuWpKCBxZkikTALdmzS49B1x)1kCnGfLGHTWxkwk4hsU9nousUTTqqa41AFOKCBplTIRDqebTuSuWpKCBpWDzzx6AwbjbdBHVuSuWpKC7IQDzZ1DZbMmw8(T6R)Af(JeJSTGDe4UXHsYTTfccaVw7dLKB7zPvCTdIiOyrxZkOqjjGOhBKyIwsb5WnousUTTqqaqfmMpusUTNLwX1oiIGSs0Z4N34B8WFWH1sICWH9kHKBFJdLKBB5XIGEK4(wKHwR3D2c(34qj52wESyHGaqjluzW8XeWOvORzfKemSfE9xRyv6leWBCOKCBlpwSqqaO(Rv8w5thrxv6RyOxIVeflOrUMvqQDzZ1DZFK4(wKHwR3D2c(8hjgzBblihiXLQzrjyyl8YqiGF2LERSpXBCOKCBlpwSqqaGW6MLDPNIfwX1ScIsRw5Fse5AaVXHsYTT8yXcbbG6VwXQ0xiGUMvquA1k3XKXYU0tmueYg5pgkPOoGzIHqWh90prvOpxsLJzxwuTaID0cVZscIVgOtNGrTaID0cVZscIVgi534qj52wESyHGaqjluzW8XeWOvORzf0R1PYdCDJpFI1uLcy1ze4lucg2c)16u5drWwlKCBsSUi)ghkj32YJfleeaQ)AfVv(0r0vL(kg6L4lrXcAKRzf0R1PYdCDJpFI1uLcy1ze4lucg2c)16u5drWwlKCBsSUi)ghkj32YJfleeaEK4(wKHwR3D2c(34qj52wESyHGaq9xRyv6leqxZkiWmXqi4JE6NOk0NlPYXSllQwaXoAH3zjbXxd0PtWOwaXoAH3zjbXxd8ghkj32YJfleeawkwk4hc6QsFfd9s8LOybnY1Sc616u5bUUXNpXAQsHuDCa8fkbdBH)ADQ8HiyRfsUnjwxKFJdLKBB5XIfccaLSqLbZhtaJwH34qj52wESyHGaq9xR4TYNoIUQ0xXqVeFjkwqJUXHsYTT8yXcbbac73(T6DNTG)nousUTLhlwiiaeVkA0l7)yl34B8WFWHEmechCRhKo75hLRnoiWDzzxEWFLqYTpOUpOvIxShCe4ShKcR7JhCOL(GP9GbGrYckgEJdLKBB5uR1dCxw2LGiSUzzx6PyHvCnRGO0Qv(NerUgWBCOKCBlNATEG7YYUSqqa4rI7BrgATE3zl47Awbfkjbe9yJet0skihC681AKljr0lRh8GfuPAwuhjyyl8YqiGF2LERSprNovBp1sHJaIF9xR405R1yD)sKtLs2LE1YMKFJh(doqIVefFwbrmCPU1zIuA1k)dxy)uHCRekhlCe5KOrNjsPvR8pCH9tfYFKyKTTWrKtINyie8o2zjbH)Anw3Ve5F4c7NkCWbh2iqme7bJdYwX1dkes7bt7bZwWEIZdk7bL4lr5Gcb8GeYscOvoiWp3pf9pi2ir9pO7uiCWOpyqLSu0)GcHqoO7KXoyaeit)d(HlSFQWdM1d(Anw3VeN8dQhHqoifMD5bJ(GyJe1)GUtHWbb3bTsOC066b3)GrFqSrI6FqHqihuiGhCIuA16bDNm2bT72heDjW8XdUn)ghkj32YPwRh4USSlleeawkwk4hc6QsFfd9s8LOybnY1Sc616u5bUUXNpXAQsHuqoa(BCOKCBlNATEG7YYUSqqaOKfQmy(ycy0k01Sc616u5bUUXNpXAQsbSoaUIwGiJ5L4lrXYlzHkdMpMagTcjfKdfv7YMR7MdmzS49B1x)1k8hjgzBjf834qj52wo1A9a3LLDzHGaq9xR4TYNoIUQ0xXqVeFjkwqJCnRGETovEGRB85tSMQuaRdGROAx2CD3CGjJfVFR(6VwH)iXiBlPG)ghkj32YPwRh4USSlleeaQ)AfRsFHa6AwbrPvRChtgl7spXqriBK)yOKIVwNkpW1n(8jwtvkKQZiWxOemSf(R1PYhIGTwi52KyDrErlqKX8s8LOy51FTIvPVqajfKdf1HsRw5tmecw)ud5wjuocIK40jyMyie8rp9tuf6ZLu5y2LoDcg1ci2rl8olji(AGKFJdLKBB5uR1dCxw2Lfcca1FTIvPVqaDnRGETovEGRB85tSMQuifKo6c8fkbdBH)ADQ8HiyRfsUnjwxKx0cezmVeFjkwE9xRyv6leqsb5qrDO0Qv(edHG1p1qUvcLJGijoDcMjgcbF0t)evH(CjvoMDPtNGrTaID0cVZscIVgi534qj52wo1A9a3LLDzHGaWsXsb)qqxv6RyOxIVeflOrUMvqVwNkpW1n(8jwtvkKcshDb(cLGHTWFTov(qeS1cj3MeRlYVXHsYTTCQ16bUll7YcbbGswOYG5JjGrRqxZki1US56U5atglE)w91FTc)rIr2wsFTg5sse9Y6jHIVwNkpW1n(8jwtvkGLeaxrlqKX8s8LOy5LSqLbZhtaJwHKcYHBCOKCBlNATEG7YYUSqqaO(Rv8w5thrxv6RyOxIVeflOrUMvqQDzZ1DZbMmw8(T6R)Af(JeJSTK(AnYLKi6L1tcfFTovEGRB85tSMQualjaUB8nE4p4qpgcHdU1dsN98JY1ghCyPKeq8Gd7vcj3(ghkj32YPwRxsLJzxcAPyPGFiORk9vm0lXxIIf0ixZkOxRtLh46gF(eRPkfsbnmG7ghkj32YPwRxsLJzxwiia8iX9TidTwV7Sf8DnRGKGHTWldHa(zx6TY(eD6uT9ulfoci(1FTItNVwJ19lrovkzx6vlB60zOKeq0JnsmrlPGC4ghkj32YPwRxsLJzxwiiaqyDZYU0tXcR4AwbrPvR8pjICnGf1516u5bUUXNpXAQsbSGh8oD(AnYLKi6L1RlWcQunD60cezmVeFjkwoH1nl7spflScPGCG8BCOKCBlNATEjvoMDzHGaWsXsb)qqxv6RyOxIVeflOrUMvqVwJCjjIEz9KaylvtNoFTovEGRB85tSMQuifeja(BCOKCBlNATEjvoMDzHGaq9xRyv6leqxZkikTAL7yYyzx6jgkczJCnGfTargZlXxIILx)1kwL(cbKuqouuhWmXqi4JE6NOk0NlPYXSllQwaXoAH3zjbXxd0PtWOwaXoAH3zjbXxdK8BCOKCBlNATEjvoMDzHGaaH9B)w9UZwW31Sc616u5bUUXNpXAQsHuqKa4k(AnYLKi6L1RlslvZBCOKCBlNATEjvoMDzHGaq9xRyv6leqxZkilqKX8s8LOy51FTIvPVqajfKdf1HsRw5tmecw)ud5wjuocIK40jyMyie8rp9tuf6ZLu5y2LoDcg1ci2rl8olji(AGKFJdLKBB5uR1lPYXSlleeawkwk4hc6QsFfd9s8LOybnY1Sc616u5bUUXNpXAQsHuhaFXxRrs11nousUTLtTwVKkhZUSqqaGW6MLDPNIfwX1ScIsRw5Fse5AaVXHsYTTCQ16Lu5y2LfccaXRIg9Y(p2IRzf0R1PYdCDJpFI1uLcPGhC34B8WFWcUS5bj5fJxoyb3EMsUT9ghkj32YvlB6jGXlGueIST(T6tf6AwbvZscI)rIr2wWwQM34H)GKOBXdo1(SlpijQKXI)GUtHWbDXkufabWqpgcHBCOKCBlxTSPNagVuiiaOiezB9B1Nk01SccmsWWw4lflf8dj3UiLwTYbMmw8(T6R)Af(JeJSTGvxfP0QvoWKXI3VvF9xRW1awKsRw5QLn9eW4fUvcLJKcAe4UXd)bhUAInN4b36bjrLmw8huZIrjEq3Pq4GUyfQcGayOhdHWnousUTLRw20taJxkeeaueIST(T6tf6Awbbgjyyl8LILc(HKBxCIHqW7yNLee(R1yD)sKxdgdBV61SXe)I6qPvRC1YMEcy8c3kHYrsbnAyksPvRCTMWY03BLh7sHaxdOtNuA1kxTSPNagVWTsOCKuqJCrfv7YMR7MdmzS49B1x)1k8hjgzBjDe4i)ghkj32YvlB6jGXlfccakcr2w)w9PcDnRGaJemSf(sXsb)qYTlcMjgcbVJDwsq4VwJ19lrEnymS9QxZgt8lsPvRC1YMEcy8c3kHYrsbncCfP0QvoWKXI3VvF9xRW1awuTlBUUBoWKXI3VvF9xRWFKyKTLuha3nE4pijQhbeB5GfCzZdsYlgVCWfq8vbqGzxEWP2ND5bbMmw834qj52wUAztpbmEPqqaqriY263QpvORzfKemSf(sXsb)qYTlcgkTALdmzS49B1x)1kCnGf1HsRw5QLn9eW4fUvcLJKcA0WuKsRw5AnHLPV3kp2LcbUgqNoP0QvUAztpbmEHBLq5iPGg5IC6uTlBUUBoWKXI3VvF9xRWFKyKTfS6QiLwTYvlB6jGXlCRekhjf0isG8B8nE4p4WTpij6w8GUybjAD9GKOwj3(Grpp4WouzWS34qj52wUAx2CD3wqAw0Ncs06AwbP2Lnx3nhyYyX73QV(Rv4pgt9D6uTlBUUBoWKXI3VvF9xRWFKyKTLuha3nousUTLR2Lnx3TTqqaa4k52UMvquA1khyYyX73QV(Rv4AalsPvRCKiW1n((xRrVBmaUnxd4nousUTLR2Lnx3TTqqaGIT70x1E9DnRGO0QvoWKXI3VvF9xRW1awKsRw5irGRB89VwJE3yaCBUgWBCOKCBlxTlBUUBBHGaaf(w8Dm7sxZkikTALdmzS49B1x)1kCnG34qj52wUAx2CD32cbbG4vrJEGAml6AwbPdyO0QvoWKXI3VvF9xRW1awmusci6XgjMOLuqoqUtNGHsRw5atglE)w91FTcxdyrDETg5tSMQuife4l(ADQ8ax34ZNynvPqkOHbCKFJdLKBB5QDzZ1DBleeayzjbX6j5rBwseBX1ScIsRw5atglE)w91FTcxd4nousUTLR2Lnx3TTqqaiAfALpyEvWyUMvquA1khyYyX73QV(Rv4AalsPvRCKiW1n((xRrVBmaUnxd4nousUTLR2Lnx3TTqqaOMpsX2D6AwbrPvRCGjJfVFR(6VwH)iXiBlybrsksPvRCKiW1n((xRrVBmaUnxd4nousUTLR2Lnx3TTqqaGkk9B1lFQC06AwbrPvRCGjJfVFR(6VwHRbSyOKeq0JnsmrlOrf1HsRw5atglE)w91FTc)rIr2wWc(IsWWw4QLn9eW4fo2bfdNoDcgjyylC1YMEcy8ch7GIHZIuA1khyYyX73QV(Rv4psmY2cwDr(nE4pyb3Lnx3T9ghkj32Yv7YMR72wiiaGebUUX3)An6DJbWTDnRGKGHTWxkwk4hsUDrDu7YMR7MdmzS49B1x)1k8hJP(fFTg5sse9Y6bpPLQzXxRtLh46gF(eRPkfsbncCoDsPvRCGjJfVFR(6VwHRbS4R1ixsIOxwp4jTunj3PZAwsq8psmY2cwha3nousUTLR2Lnx3TTqqaajcCDJV)1A07gdGB7AwbjbdBHt9yie8B1BZE(r5AJIVwNkpW1n(8jwtvkKscGR4R1ixsIOxwp4jTunlQdLwTYPEmec(T6Tzp)OCTbxdOtN1SKG4FKyKTfSoaoYVXHsYTTC1US56UTfccairGRB89VwJE3yaCBxZkijyyl8uHQayXxRrWQRBCOKCBlxTlBUUBBHGaaWKXI3VvF9xR4AwbjbdBHt9yie8B1BZE(r5AJI6O2Lnx3nN6Xqi43Q3M98JY1g8hjgzBD6uTlBUUBo1JHqWVvVn75hLRn4pgt9l(ADQ8ax34ZNynvPa2HbCKFJdLKBB5QDzZ1DBleeaaMmw8(T6R)AfxZkijyyl8uHQayrWqPvRCGjJfVFR(6VwHRb8ghkj32Yv7YMR72wiiaamzS49B1x)1kUMvqsWWw4lflf8dj3UOosWWw4LHqa)Sl9wzFICSdkgolsPvR8hjUVfzO16DNTGpxdOtNGrcg2cVmec4NDP3k7tKJDqXWj534qj52wUAx2CD32cbbaQhdHGFREB2ZpkxB4AwbrPvRCGjJfVFR(6VwHRb8ghkj32Yv7YMR72wiiau)1kU1)jA9vTxFxZkikTALdmzS49B1x)1k8hjgzBbBPAwKsRw5atglE)w91FTcxdyrWibdBHVuSuWpKC7BCOKCBlxTlBUUBBHGaq9xR4w)NO1x1E9DnRGcLKaIESrIjAjfKdf1HsRw5atglE)w91FTcxdyrkTALdmzS49B1x)1k8hjgzBbBPA605h50JaITWJ50YrxMwXw8JC6raXw4XCA5psmY2c2s10PZAwsq8psmY2c2s1K8BCOKCBlxTlBUUBBHGaq9xR4w)NO1x1E9DnRGKGHTWxkwk4hsUDrWqPvRCGjJfVFR(6VwHRbSOo6qPvRCTMWY03BLh7sHaxdOtNGzIHqW7yNLee(R1yD)sKxdgdBV61SXeFYlQZeP0Qv(hUW(Pc5wjuocc8oDcMjgcbVJDwsq4VwJ19lr(hUW(PcjN8BCOKCBlxTlBUUBBHGaab9bUcb8jMkpWhTyRqxZkijyylCQhdHGFREB2ZpkxBu816u5bUUXNpXAQsHusaCfFTgjfKUksPvRCGjJfVFR(6VwHRb0PtWibdBHt9yie8B1BZE(r5AJIVwNkpW1n(8jwtvkKcYbWFJdLKBB5QDzZ1DBleea(iTOFIX01ScIsRw5atglE)w91FTcxd4nousUTLR2Lnx3TTqqaWgQpRPkdMhyOexZkOqjjGOhBKyIwsb5qrDaIcVKWQX4psmY2c2s10Ptj(su4sse9Y6Njc2s1K8BCOKCBlxTlBUUBBHGaWedHGp6PFIQqFxZkOqjjGOhBKyIwsbVtNVwJ19lroqcy8lXTr7n(gp8hSGlGyhTCWHfvYsjr7nousUTLRwaXoAXcAIHqW6NAORzf0h50JaITWJ50YZM0rG3PtW8ro9iGyl8yoTC0LPvSoDgkjbe9yJet0skihUXHsYTTC1ci2rl2cbbaR74jMDPNyAfxZkOqjjGOhBKyIwqJk(ADQ8ax34ZNynvPqQUkQ2Lnx3nhyYyX73QV(Rv4psmY2cwDvemsWWw4upgcb)w92SNFuU2OOoG5JC6raXw4XCA5OltRyD68JC6raXw4XCA5zt6iWt(nousUTLRwaXoAXwiiayDhpXSl9etR4Awbfkjbe9yJet0skihkcgjyylCQhdHGFREB2ZpkxBCJdLKBB5QfqSJwSfccaw3Xtm7spX0kUMvqsWWw4upgcb)w92SNFuU2OOouA1kN6Xqi43Q3M98JY1gCnGf1jusci6XgjMOf0OIVwNkpW1n(8jwtvkKscGZPZqjjGOhBKyIwsb5qXxRtLh46gF(eRPkfshgWrUtNGHsRw5upgcb)w92SNFuU2GRbSOAx2CD3CQhdHGFREB2ZpkxBWFKyKTL8BCOKCBlxTaID0ITqqaiOwIzhsUTNLePCnRGcLKaIESrIjAbnQOAx2CD3CGjJfVFR(6VwH)iXiBly1vrDaZh50JaITWJ50YrxMwX605h50JaITWJ50YZM0rGN8BCOKCBlxTaID0ITqqaiOwIzhsUTNLePCnRGcLKaIESrIjAjfKd34qj52wUAbe7OfBHGaGLqOCKHEHa61A37le031Sckusci6XgjMOf0OIQDzZ1DZbMmw8(T6R)Af(JeJSTGvxf1bmFKtpci2cpMtlhDzAfRtNFKtpci2cpMtlpBshbEYVXHsYTTC1ci2rl2cbbalHq5id9cb0R1U3xiOVRzfuOKeq0JnsmrlPGC4gFJh(doCPyPGFi52h8xjKC7BCOKCBlFPyPGFi52GEK4(wKHwR3D2c(UMvqHssarp2iXeTKcsxf1rcg2cVmec4NDP3k7t0Pt12tTu4iG4x)1koD(Anw3Ve5uPKDPxTSj534qj52w(sXsb)qYTleeaiSUzzx6PyHvCnRGaZCfE9xR4RiG4ZLu5y2LfbdLwTYDmzSSl9edfHSrUgWBCOKCBlFPyPGFi52fcca1FTIvPVqaDnRGO0QvUJjJLDPNyOiKnYFmusrlqKX8s8LOy51FTIvPVqajfKdf1HsRw5tmecw)ud5wjuocIK40jyMyie8rp9tuf6ZLu5y2LoDcg1ci2rl8olji(AGKFJdLKBB5lflf8dj3UqqayPyPGFiORk9vm0lXxIIf0ixZkikTAL7yYyzx6jgkczJ8hdL40jyO0Qv(NerUgWIwGiJ5L4lrXYjSUzzx6PyHvifKUUXHsYTT8LILc(HKBxiiauYcvgmFmbmAf6AwbzbImMxIVeflVKfQmy(ycy0kKuqouuNxRtLh46gF(eRPkfWocCoD(AnYLKi6L17aPLQj5oDQZeP0Qv(hUW(Pc5wjuocwW705eP0Qv(hUW(Pc5psmY2c2rGN8BCOKCBlFPyPGFi52fcca1FTI3kF6i6AwbP2EQLch)yMQqYU0tXw3fP0Qvo(XmvHKDPNITU5wjuocYHIHssarp2iXeTGgDJdLKBB5lflf8dj3UqqaGW6MLDPNIfwX1ScIsRw5Fse5AalAbImMxIVeflNW6MLDPNIfwHuqoCJdLKBB5lflf8dj3UqqaOKfQmy(ycy0k01ScYcezmVeFjkwEjluzW8XeWOviPGC4ghkj32Yxkwk4hsUDHGaq9xR4TYNoIUQ0xXqVeFjkwqJCnRGaJemSfEayWIwralcgkTAL7yYyzx6jgkczJCnGoDkbdBHhagSOveWIGHsRw5Fse5AaVXHsYTT8LILc(HKBxiiaqyDZYU0tXcR4AwbrPvR8pjICnG34qj52w(sXsb)qYTleeawkwk4hc6QsFfd9s8LOybn6gFJh(dsIAxw2LhC4y)doCPyPGFi526(G0s8I9GJa3bTOA7P9GuyDF8GKOsgl(dU1doC8RvoOAjI2dU16bl4W5nousUTLVuSuWpKCBpWDzzxc6rI7BrgATE3zl47AwbjbdBHxgcb8ZU0BL9j60PA7PwkCeq8R)AfNoFTgR7xICQuYU0Rw20PZqjjGOhBKyIwsb5WnousUTLVuSuWpKCBpWDzzxwiiaqyDZYU0tXcR4AwbrPvR8pjICnG34qj52w(sXsb)qYT9a3LLDzHGaWsXsb)qqxv6RyOxIVeflOrUMvquA1k3XKXYU0tmueYg5pgk5ghkj32Yxkwk4hsUTh4USSlleeakzHkdMpMagTcDnRGSargZlXxIILxYcvgmFmbmAfskihk(ADQ8ax34ZNynvPa2HbC34qj52w(sXsb)qYT9a3LLDzHGaq9xR4TYNoIUQ0xXqVeFjkwqJCnRGETovEGRB85tSMQualjdC34qj52w(sXsb)qYT9a3LLDzHGaWsXsb)qqxv6RyOxIVeflOrUMvqVwJKsc34qj52w(sXsb)qYT9a3LLDzHGaq9xRyv6leqxZkOqjjGOhBKyIwsbrcf1bmtmec(ON(jQc95sQCm7YIQfqSJw4Dwsq81aD6emQfqSJw4Dwsq81aj)gFJh(dslrpJFEqB2LmKeTs8LOCWFLqYTVXHsYTTCRe9m(jOhjUVfzO16DNTGVRzfKemSfEzieWp7sVv2NOtNQTNAPWraXV(RvC681ASUFjYPsj7sVAzZBCOKCBl3krpJFwiiauYcvgmFmbmAf6AwbbMjgcbVJDwsq4VwJ19lr(hUW(PclQZeP0Qv(hUW(Pc5wjuocwW705eP0Qv(hUW(Pc5psmY2cwsg534qj52wUvIEg)SqqaO(Rv8w5thrxZki1US56U5psCFlYqR17oBbF(JeJSTGfKdK4s1SOemSfEzieWp7sVv2N4nousUTLBLONXpleeaQ)AfVv(0r01ScsT9ulfo(XmvHKDPNITUlsPvRC8JzQcj7spfBDZTsOCeKdoDQ2EQLcxRzyyjGtF9X2f0ViLwTY1Aggwc40xFSDb95psmY2cwDvKsRw5AnddlbC6Rp2UG(CnG34qj52wUvIEg)SqqaGW6MLDPNIfwX1ScIsRw5Fse5AaVXHsYTTCRe9m(zHGaWsXsb)qqxZkiWqPvR86VUa2EGAmlY1awucg2cV(RlGThOgZI34qj52wUvIEg)SqqaO(Rv8w5thrxZkOxRtLh46gF(eRPkfWQZiWxOemSf(R1PYhIGTwi52KyDr(nousUTLBLONXpleeawkwk4hc6Awb9ADQ8ax34ZNynvPqQooa(cLGHTWFTov(qeS1cj3MeRlYVXHsYTTCRe9m(zHGaq9xR4TYNoI34qj52wUvIEg)SqqaGW(TFRE3zl4FJdLKBB5wj6z8ZcbbG4vrJEz)hBXigXyaa]] )

end
