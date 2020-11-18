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


    spec:RegisterPack( "Frost DK", 20201117, [[d0eVJbqiaPhPsbxssLQytuv9jvkuJsLsNcqSkjvYRGQAwub3ssLQYUi5xufnmjvDma1YOk8mQszAQu01KuABuLkFdkvmoOuvNdkvzDuLQQ5jP4EQK9bv5GsQuzHuHEivPkMiuQKUOkfI2OKkfFKQuLYiPkvP6KsQuALQu9sQsvYmvPqODcL8tvkKmujvQslLQuvEQQAQqfxvLcbFvsLQQ9c6VenyjoSWIvLhJYKvXLr2mP(SKmAO40IwTkfs9AQsMnKBdWUv63kgov64qPsTCPEoQMoLRd02Hs57urJhkvIZdvA9sQy(uv2pHHadXb(pHrqS8OEpQhyGbg7O8WB16DEZ7GFdxxc(DdMxrfb)BaGG)6ME4MOGD17f87g4IM4aXb(5dyZi4hJzUCVFp9SknmGpfBa4jpbaIclNL1H28KNayEc)pWez1Tl8b)NWiiwEuVh1dmWaJDuE4TA9oVDt4panmtd))eG3d8JjphAHp4)qCg8FdIc2vkmmII3RnRWyIsDtpCtC)gefSgSraEulkaJDCqu8OEpQxCxC)geLpM4morXE4IYTypv9kpac8JsUXH4a)SbDKyOOnioqSagId8tB8q0b6i8Z60Ood4xNvymztaIC5IsnIsf7ik(8jkpqTw5Miu0Yrl19WnvtaIC5IsnII3ef)IYduRvSbDKyOOnf3cMxIYLO4r9IIFrbOIIfiAn18qPrDy5SkAJhIoWFWSCw4NHjYLlhTmze0Gy5beh4N24HOd0r4N1PrDgWVfiAn18qPrDy5SkAJhIoIIFrbOIYduRvUjcfTC0sDpCtb6kk(fLBfLhOwRyd6iXqrBkUfmVef8UefG9orXVO8a1Af4Izq4k5wtBLHrb6kk(8jkpqTwXg0rIHI2uClyEjk4DjkaJ9efGa)bZYzHFgMixUC0YKrqdAW)8qPrDy5SqCGybmeh4N24HOd0r4N1PrDgWVfiAnvvyyOo3kj3MgGI24HOJO4xucMLyJK0sasIlk4DjkEd(dMLZc)nbyAoHiox6mxJAObXYdioWpTXdrhOJWpRtJ6mGFGkkNXu6E4MutyJALLmVYTsu8lkavuEGATYReHYTsciyyYLuGUWFWSCw4hZ4eLBL8HcUbniwEdId8tB8q0b6i8Z60Ood4)bQ1kVsek3kjGGHjxs1uWmrXVOWDjesArxrgxP7HBCgUggsuW7su8a(dMLZc)6E4gNHRHHGgeRBcXb(PnEi6aDe(dMLZc)ZdLg1HrWpRtJ6mG)hOwR8krOCRKacgMCjvtbZefF(efGkkpqTw1jasb6kk(ffUlHqsl6kY4kmJtuUvYhk4MOG3LO4n4NHldrsl6kY4qSagAqSQfId8tB8q0b6i8Z60Ood4N7siK0IUImUQcfSmqY4GTyzKOG3LO4HO4xuUvuAWnzs3Xj1QdPtwAIsnIcW1lk(8jkn4sklbqsBKEik4jkvSJOaerXNpr5wr5qpqTw1rDMozKIBbZlrPgrPwrXNpr5qpqTw1rDMozKQjarUCrPgrb4AffGa)bZYzH)kuWYajJd2ILrqdIL3bXb(PnEi6aDe(zDAuNb8ZM9aMMI64KSWYTs(qJtfTXdrhrXVO8a1Af1XjzHLBL8HgNkUfmVeLlrXdrXVOemlXgjPLaKexuUefGH)Gz5SWVUhUj5wNErqdIf2bId8tB8q0b6i8Z60Ood4)bQ1QobqkqxrXVOWDjesArxrgxHzCIYTs(qb3ef8UefpG)Gz5SWpMXjk3k5dfCdAqSW(qCGFAJhIoqhHFwNg1za)CxcHKw0vKXvvOGLbsghSflJef8UefpG)Gz5SWFfkyzGKXbBXYiObXc7bXb(PnEi6aDe(dMLZc)6E4MKBD6fb)SonQZa(BWnzs3Xj1QdPtwAIsnIcW1lk(8jkn4sklbqsBKEik4jkvSJO4ZNOaur5bQ1Qobqkqx4NHldrsl6kY4qSagAqSaUEioWpTXdrhOJWpRtJ6mG)hOwR6eaPaDH)Gz5SWpMXjk3k5dfCdAqSagyioWpTXdrhOJWFWSCw4FEO0Oomc(z4YqK0IUImoelGHg0G)3WLwY8k3kioqSagId8tB8q0b6i8hmlNf(NhknQdJGFwNg1za)n4MmP74KArPMlr5M1d)mCzisArxrghIfWqdILhqCGFAJhIoqhHFwNg1za)wGO1uvHHH6CRKCBAakAJhIoIIpFIsWSeBKKwcqsCrbVlrXd4pywol83eGP5eI4CPZCnQHgelVbXb(PnEi6aDe(zDAuNb8)a1AvNaifOl8hmlNf(Xmor5wjFOGBqdI1nH4a)0gpeDGoc)bZYzH)5HsJ6Wi4N1PrDgWFdUKYsaK0g5nfLAeLk2ru85tuAWnzs3Xj1IsnxIYnRf(z4YqK0IUImoelGHgeRAH4a)0gpeDGoc)SonQZa(FGATYReHYTsciyyYLuGUIIFrH7siK0IUImUs3d34mCnmKOG3LO4b8hmlNf(19WnodxddbniwEheh4N24HOd0r4N1PrDgWFdUjt6ooPwDiDYstuW7suUz9IIFrPbxszjasAJ0BIcEIsf7a)bZYzHFmtVYrlDMRrn0GyHDG4a)0gpeDGoc)SonQZa(5UecjTORiJR09Wnodxddjk4DjkEa)bZYzHFDpCJZW1WqqdIf2hId8tB8q0b6i8hmlNf(NhknQdJGFwNg1za)n4MmP74KA1H0jlnrbprXJAffF(eLgCjrbprXBWpdxgIKw0vKXHybm0GyH9G4a)0gpeDGoc)SonQZa(BWnzs3Xj1QdPtwAIcEIsT1d)bZYzH)OzXssB6MwdAqd(joNwgXH4aXcyioWpTXdrhOJWpRtJ6mG)hOwRCtekA5OL6E4Mc0vu8lk3kkpqTw5Miu0Yrl19WnvtaIC5IsnIcW1lk(fLBfLhOwREnfgg5OL8CpDun8qb6kk(8jkwGO1uZdLg1HLZQOnEi6ik(8jkwGO1ujJyHRI24HOJO4xuaQOe1H60ivYWvYsloesrB8q0ruaIO4ZNO8a1AvYWvYsloesb6kk(fflq0AQKrSWvrB8q0ruac8hmlNf(FOzoYrlnmKKwcaUqdILhqCGFAJhIoqhHFwNg1za)avuSarRPsgXcxfTXdrhrXNprXceTMkzelCv0gpeDef)IsuhQtJujdxjlT4qifTXdrhrXVO8a1ALBIqrlhTu3d3unbiYLlk1ikENO4xuEGATYnrOOLJwQ7HBkqxrXNprXceTMkzelCv0gpeDef)IcqfLOouNgPsgUswAXHqkAJhIoWFWSCw4Vcm6tgRC0YOoupggObXYBqCGFAJhIoqhHFwNg1za)pqTw5Miu0Yrl19WnvtaIC5IsnIsTIIFr5bQ1k3eHIwoAPUhUPaDffF(eflbqsBKNKeLAeLAH)Gz5SWpdtIqsU1u4f0GyDtioWpTXdrhOJWpRtJ6mG)hOwRAI5fI4CPEAgPaDffF(eLhOwRAI5fI4CPEAgjzd4AuR4wW8suQruagy4pywol8Byij4(gW9i1tZiObXQwioWpTXdrhOJWpRtJ6mGFGkkpqTw5Miu0Yrl19WnfORO4xuaQO8a1A1RPWWihTKN7PJQHhkqx4pywol8RhgiNoYOouNgjFuaaAqS8oioWpTXdrhOJWpRtJ6mGFGkkpqTw5Miu0Yrl19WnfORO4xuaQO8a1A1RPWWihTKN7PJQHhkqxrXVOCgtXMLrR1HrhPgfai5dSxvtaIC5IYLOup8hmlNf(zZYO16WOJuJcae0GyHDG4a)0gpeDGoc)SonQZa(bQO8a1ALBIqrlhTu3d3uGUIIFrbOIYduRvVMcdJC0sEUNoQgEOaDH)Gz5SWVlyNACZTs(qb3GgelSpeh4N24HOd0r4N1PrDgW)duRvUjcfTC0sDpCtb6kk(8jkpqTwraChNulBWLKoPWDwfORO4ZNOWMbDgNR61uyyKJwYZ90r1WdvtaIC5IcEII3vVOGVOaCTIIpFIcHDdMUU0rLlP1XdrsRbnmIIpFIcHDdMUU0rLlP1XdrsRbnmYbd8hmlNf(Don6Gnkxzt8zJLrqdIf2dId8tB8q0b6i8Z60Ood4hOIYduRvUjcfTC0sDpCtb6kk(ffGkkpqTw9AkmmYrl55E6OA4Hc0f(dMLZc)D66IizUsUBWiObXc46H4a)0gpeDGoc)SonQZa(FGATIa4ooPw2GljDsH7SQMae5YfLAeLAff)IYduRvVMcdJC0sEUNoQgEOaDffF(eLBfLgCjLLaiPnspef8eLk2ru8lkn4MmP74KArPgrP26ffGa)bZYzHFaeGPXvoAjcKLh5PPaahAqSagyioWpTXdrhOJWpRtJ6mGFl6kYuyOazyKUmtuWtuW(1lk(8jkw0vKPWqbYWiDzMOuJO4r9IIpFIIoRWyYMae5YfLAeLAH)Gz5SWFtHBUvsnkaqCObn4)nCP7mOCRG4aXcyioWpTXdrhOJWpRtJ6mG)hOwR6eaPaDH)Gz5SWpMXjk3k5dfCdAqS8aId8tB8q0b6i8Z60Ood43ceTMQkmmuNBLKBtdqrB8q0ru8lkn4sIcExIsTIIpFIsWSeBKKwcqsCrbVlrXd4pywol83eGP5eI4CPZCnQHgelVbXb(PnEi6aDe(dMLZc)ZdLg1HrWpRtJ6mG)gCtM0DCsT6q6KLMOG3LO4rTWpdxgIKw0vKXHybm0GyDtioWpTXdrhOJWpRtJ6mG)gCtM0DCsT6q6KLMOuJO4r9IIFrH7siK0IUImUQcfSmqY4GTyzKOG3LO4HO4xuyZGoJZv5Miu0Yrl19WnvtaIC5IcEIsTWFWSCw4VcfSmqY4GTyze0Gyvleh4N24HOd0r4pywol8R7HBsU1Pxe8Z60Ood4Vb3KjDhNuRoKozPjk1ikEuVO4xuyZGoJZv5Miu0Yrl19WnvtaIC5IcEIsTWpdxgIKw0vKXHybm0Gy5DqCGFAJhIoqhHFwNg1za)pqTw5vIq5wjbemm5skqxrXVO0GBYKUJtQvhsNS0ef8eLBffGRvuWxuSarRPAWnzYWmAbdlNvrB8q0ruQlrXBIcqef)Ic3LqiPfDfzCLUhUXz4AyirbVlrXd4pywol8R7HBCgUggcAqSWoqCGFAJhIoqhHFwNg1za)n4MmP74KA1H0jlnrbVlr5wrXB1kk4lkwGO1un4MmzygTGHLZQOnEi6ik1LO4nrbiIIFrH7siK0IUImUs3d34mCnmKOG3LO4b8hmlNf(19WnodxddbniwyFioWpTXdrhOJWFWSCw4FEO0Oomc(zDAuNb83GBYKUJtQvhsNS0ef8UeLBffVvROGVOybIwt1GBYKHz0cgwoRI24HOJOuxII3efGa)mCzisArxrghIfWqdIf2dId8tB8q0b6i8Z60Ood4Nnd6moxLBIqrlhTu3d3unbiYLlk4jkn4sklbqsBK3uu8lkn4MmP74KA1H0jlnrPgr5M1lk(ffUlHqsl6kY4QkuWYajJd2ILrIcExIIhWFWSCw4VcfSmqY4GTyze0GybC9qCGFAJhIoqhH)Gz5SWVUhUj5wNErWpRtJ6mGF2mOZ4CvUjcfTC0sDpCt1eGixUOGNO0GlPSeajTrEtrXVO0GBYKUJtQvhsNS0eLAeLBwp8ZWLHiPfDfzCiwadnOb)UnXgaVWG4an4pgcIdelGH4a)0gpeDGoc)SonQZa(TarRPQcdd15wj520au0gpeDG)Gz5SWFtaMMtiIZLoZ1OgAqS8aId8tB8q0b6i8Z60Ood43ceTMs3d34mCnmKI24HOd8hmlNf(RqbldKmoylwgbniwEdId8tB8q0b6i8hmlNf(19Wnj360lc(zDAuNb8ZMbDgNRQjatZjeX5sN5AuRAcqKlxuQ5su8quQlrPIDef)IIfiAnvvyyOo3kj3MgGI24HOd8ZWLHiPfDfzCiwadniw3eId8tB8q0b6i8Z60Ood4)bQ1Qobqkqx4pywol8JzCIYTs(qb3GgeRAH4a)0gpeDGoc)SonQZa(FGATYReHYTsciyyYLuGUWFWSCw4x3d34mCnme0Gy5DqCGFAJhIoqhHFwNg1za)n4MmP74KA1H0jlnrPgr5wrb4Aff8fflq0AQgCtMmmJwWWYzv0gpeDeL6su8MOae4pywol8xHcwgizCWwSmcAqSWoqCGFAJhIoqhH)Gz5SWVUhUj5wNErWpRtJ6mG)gCtM0DCsT6q6KLMOuJOCROaCTIc(IIfiAnvdUjtgMrlyy5SkAJhIoIsDjkEtuac8ZWLHiPfDfzCiwadniwyFioWFWSCw4VjatZjeX5sN5Aud)0gpeDGocniwypioWFWSCw4x3d34mCnme8tB8q0b6i0GybC9qCGFAJhIoqhH)Gz5SW)8qPrDye8Z60Ood4Vb3KjDhNuRoKozPjk4jk3kkEuROGVOybIwt1GBYKHz0cgwoRI24HOJOuxII3efGa)mCzisArxrghIfWqdIfWadXb(dMLZc)vOGLbsghSflJGFAJhIoqhHgelG9aId8tB8q0b6i8hmlNf(19Wnj360lc(z4YqK0IUImoelGHgelG9geh4pywol8Jz6voAPZCnQHFAJhIoqhHgelGVjeh4pywol8hnlwsAt30AWpTXdrhOJqdAWpBg0zCUCioqSagId8tB8q0b6i8Z60Ood4Nnd6moxLBIqrlhTu3d3unfhCffF(ef2mOZ4CvUjcfTC0sDpCt1eGixUOGNO4r9WFWSCw4hKtY0iaCObXYdioWpTXdrhOJWpRtJ6mG)hOwRCtekA5OL6E4Mc0vu8lkpqTwraChNulBWLKoPWDwfOl8hmlNf(DhlNfAqS8geh4N24HOd0r4N1PrDgW)duRvUjcfTC0sDpCtb6kk(fLhOwRiaUJtQLn4ssNu4oRc0f(dMLZc)p0mhPgSXfAqSUjeh4N24HOd0r4N1PrDgW)duRvUjcfTC0sDpCtb6c)bZYzH)h1CQ9k3kObXQwioWpTXdrhOJWpRtJ6mG)BffGkkpqTw5Miu0Yrl19WnfORO4xucMLyJK0sasIlk4DjkEikaru85tuaQO8a1ALBIqrlhTu3d3uGUIIFr5wrPbxsDiDYstuW7suQvu8lkn4MmP74KA1H0jlnrbVlrX7Qxuac8hmlNf(JMfljDbrCcAqS8oioWpTXdrhOJWpRtJ6mG)hOwRCtekA5OL6E4Mc0f(dMLZc)OScJXL3ObpvaO1GgelSdeh4N24HOd0r4N1PrDgW)duRvUjcfTC0sDpCtb6kk(fLhOwRiaUJtQLn4ssNu4oRc0f(dMLZc)XYiU1bsYcecAqSW(qCGFAJhIoqhHFwNg1za)pqTw5Miu0Yrl19WnvtaIC5IsnxIc2xu8lkpqTwraChNulBWLKoPWDwfOl8hmlNf(1ztp0mhObXc7bXb(PnEi6aDe(zDAuNb8)a1ALBIqrlhTu3d3uGUIIFr5wr5bQ1k3eHIwoAPUhUPAcqKlxuQruQvu8lkwGO1uSbDKyOOnfTXdrhrXNprbOIIfiAnfBqhjgkAtrB8q0ru8lkpqTw5Miu0Yrl19WnvtaIC5IsnII3efGik(fLGzj2ijTeGK4IYLOam8hmlNf(FrLC0sRtMxCObXc46H4a)0gpeDGoc)SonQZa(TarRPMhknQdlNvrB8q0ru8lk3kkSzqNX5QCtekA5OL6E4MQP4GRO4xuAWLuwcGK2iRvuWtuQyhrXVO0GBYKUJtQvhsNS0ef8UefGRxu85tuEGATYnrOOLJwQ7HBkqxrXVO0GlPSeajTrwROGNOuXoIcqefF(efDwHXKnbiYLlk1ikEup8hmlNf(jaUJtQLn4ssNu4ol0GybmWqCGFAJhIoqhHFwNg1za)wGO1uVMcdJC0sEUNoQgEOOnEi6ik(fLgCtM0DCsT6q6KLMOGNOCZ6ff)IsdUKYsaK0gzTIcEIsf7ik(fLBfLhOwREnfgg5OL8CpDun8qb6kk(8jk6ScJjBcqKlxuQru8OErbiWFWSCw4Na4ooPw2GljDsH7SqdIfWEaXb(PnEi6aDe(zDAuNb8BbIwtLmIfUkAJhIoIIFrPbxsuQru8g8hmlNf(jaUJtQLn4ssNu4ol0GybS3G4a)0gpeDGoc)SonQZa(TarRPEnfgg5OL8CpDun8qrB8q0ru8lk3kkSzqNX5QEnfgg5OL8CpDun8q1eGixUO4ZNOWMbDgNR61uyyKJwYZ90r1WdvtXbxrXVO0GBYKUJtQvhsNS0eLAefVRErbiWFWSCw43nrOOLJwQ7HBqdIfW3eId8tB8q0b6i8Z60Ood43ceTMkzelCv0gpeDef)IcqfLhOwRCtekA5OL6E4Mc0f(dMLZc)UjcfTC0sDpCdAqSaUwioWpTXdrhOJWpRtJ6mGFlq0AQ5HsJ6WYzv0gpeDef)IYTIIfiAnvvyyOo3kj3MgGI24HOJO4xuEGATQjatZjeX5sN5AuRaDffF(efGkkwGO1uvHHH6CRKCBAakAJhIoIcqG)Gz5SWVBIqrlhTu3d3GgelG9oioWpTXdrhOJWpRtJ6mG)hOwRCtekA5OL6E4Mc0f(dMLZc)VMcdJC0sEUNoQgEaniwaJDG4a)0gpeDGoc)SonQZa(FGATYnrOOLJwQ7HBQMae5YfLAeLk2ru8lkpqTw5Miu0Yrl19WnfORO4xuaQOybIwtnpuAuhwoRI24HOd8hmlNf(19WnN42a4snyJl0Gybm2hId8tB8q0b6i8Z60Ood4pywInsslbijUOG3LO4HO4xuyZGoJZv5Miu0Yrl19WnvtaIC5Ic(IcW1kk4jkw0vKPSeajTrEssu85tu0zfgt2eGixUOuJOuXoWFWSCw4x3d3CIBdGl1GnUqdIfWypioWpTXdrhOJWpRtJ6mGFlq0AQ5HsJ6WYzv0gpeDef)IcqfLhOwRCtekA5OL6E4Mc0vu8lk3kk3kkpqTwbUygeUsU10wzyuGUIIpFIcqfLdfggPxBwHXun4s6PRiLoqiALSgKhhQffGik(fLBfLd9a1Avh1z6KrkUfmVeLlrPwrXNprbOIYHcdJ0RnRWyQgCj90vKQJ6mDYirbiIcqG)Gz5SWVUhU5e3gaxQbBCHgelpQhId8tB8q0b6i8Z60Ood43ceTM61uyyKJwYZ90r1WdfTXdrhrXVO0GBYKUJtQvhsNS0ef8eLBwVO4xuAWLef8UefVjk(fLhOwRCtekA5OL6E4Mc0vu85tuaQOybIwt9AkmmYrl55E6OA4HI24HOJO4xuAWnzs3Xj1QdPtwAIcExIIh1c)bZYzHFm46oggQbKmPBtCAze0Gy5bWqCGFAJhIoqhHFwNg1za)pqTw5Miu0Yrl19WnfOl8hmlNf(7i5K8qXbAqS8WdioWFWSCw4hdfTjjoNwgb)0gpeDGocnOb)hshGidIdelGH4a)bZYzHFa5EK6MO6qWpTXdrhOJqdILhqCGFAJhIoqhHFwNg1za)avuoJP09WnPMWg1klzELBLO4xuUvuSarRPsgXcxfTXdrhrXNprHnd6mox1RPWWihTKN7PJQHhQMae5Yff8efGRvu85tuSarRPMhknQdlNvrB8q0ru8lkSzqNX5QCtekA5OL6E4MQjarUCrPgr5mMs3d3KAcBuRAcqKlxuac8hmlNf(Xmor5wjFOGBqdIL3G4a)0gpeDGoc)SonQZa(FGATkz4kTanlx1eGixUOuZLOuXoIIFr5bQ1QKHR0c0SCfORO4xu4UecjTORiJRQqbldKmoylwgjk4DjkEik(fLBffGkkwGO1uVMcdJC0sEUNoQgEOOnEi6ik(8jkSzqNX5QEnfgg5OL8CpDun8q1eGixUOGNOaCTIcqG)Gz5SWFfkyzGKXbBXYiObX6MqCGFAJhIoqhHFwNg1za)pqTwLmCLwGMLRAcqKlxuQ5suQyhrXVO8a1AvYWvAbAwUc0vu8lk3kkavuSarRPEnfgg5OL8CpDun8qrB8q0ru85tuyZGoJZv9AkmmYrl55E6OA4HQjarUCrbprb4AffGa)bZYzHFDpCtYTo9IGgeRAH4a)0gpeDGoc)bZYzHFwGqYGz5SsuYn4hLCtUbac(zZGoJZLdniwEheh4N24HOd0r4pywol8ZcesgmlNvIsUb)OKBYnaqWpX50Yio0GyHDG4a)0gpeDGoc)SonQZa(TarRPyd6iXqrBkAJhIoIIFr5wr5bQ1k2Gosmu0MIBbZlrbVlrb46ff)IYTIYHEGATQJ6mDYif3cMxIYLOuRO4ZNOaur5qHHr61MvymvdUKE6ks1rDMozKOaerXNprrNvymztaIC5IsnxIsf7ikab(dMLZc)SaHKbZYzLOKBWpk5MCdae8Zg0rIHI2GgelSpeh4N24HOd0r4N1PrDgW)duRvVMcdJC0sEUNoQgEOaDH)Gz5SWFdUYGz5SsuYn4hLCtUbac(FdxAjZRCRGgelSheh4N24HOd0r4N1PrDgWVfiAn1RPWWihTKN7PJQHhkAJhIoIIFr5wrHnd6mox1RPWWihTKN7PJQHhQMae5YfLAefGRxuac8hmlNf(BWvgmlNvIsUb)OKBYnaqW)B4s3zq5wbniwaxpeh4N24HOd0r4N1PrDgW)duRvUjcfTC0sDpCtb6kk(fflq0AQ5HsJ6WYzv0gpeDG)Gz5SWFdUYGz5SsuYn4hLCtUbac(NhknQdlNfAqSagyioWpTXdrhOJWpRtJ6mG)Gzj2ijTeGK4IcExIIhWFWSCw4VbxzWSCwjk5g8JsUj3aab)XqqdIfWEaXb(PnEi6aDe(dMLZc)SaHKbZYzLOKBWpk5MCdae8ZTyprFGg0GFUf7j6dehiwadXb(PnEi6aDe(zDAuNb8BbIwtvfggQZTsYTPbOOnEi6ik(8jkSzpGPPiSrTUhUPOnEi6ik(8jkn4s6PRi1lTCRKSbDue2ny66sh4pywol83eGP5eI4CPZCnQHgelpG4a)0gpeDGoc)SonQZa(bQOCOWWi9AZkmMQbxspDfP6OotNmsu8lk3kkh6bQ1QoQZ0jJuClyEjk1ik1kk(8jkh6bQ1QoQZ0jJunbiYLlk1ikyhrbiWFWSCw4VcfSmqY4GTyze0Gy5nioWpTXdrhOJWpRtJ6mGF2mOZ4CvnbyAoHiox6mxJAvtaIC5IsnxIIhIsDjkvSJO4xuSarRPQcdd15wj520au0gpeDG)Gz5SWVUhUj5wNErqdI1nH4a)0gpeDGoc)SonQZa(zZEattbUik4yOJu30whCv0gpeDef)IYduRvGlIcog6i1nT1bxvtaIC5IsnII3efF(ef2ShW0uuhNKfwUvYhACQOnEi6ik(fLhOwROoojlSCRKp04uXTG5LOCjkEa)bZYzHFDpCtYTo9IGgeRAH4a)0gpeDGoc)SonQZa(FGATQtaKc0f(dMLZc)ygNOCRKpuWnObXY7G4a)0gpeDGoc)SonQZa(bQO8a1ALUN6qR0feXjfORO4xuSarRP09uhALUGioPOnEi6a)bZYzH)5HsJ6WiObXc7aXb(PnEi6aDe(zDAuNb83GBYKUJtQvhsNS0eLAeLBffGRvuWxuSarRPAWnzYWmAbdlNvrB8q0ruQlrXBIcqG)Gz5SWVUhUj5wNErqdIf2hId8tB8q0b6i8Z60Ood4)bQ1kVsek3kjGGHjxsb6kk(fLgCjLLaiPnYBkk4DjkvSd8hmlNf(19WnodxddbniwypioWpTXdrhOJWpRtJ6mG)gCtM0DCsT6q6KLMOGNOCRO4rTIc(IIfiAnvdUjtgMrlyy5SkAJhIoIsDjkEtuac8hmlNf(NhknQdJGgelGRhId8hmlNf(19Wnj360lc(PnEi6aDeAqSagyioWFWSCw4hZ0RC0sN5Aud)0gpeDGocniwa7beh4pywol8hnlwsAt30AWpTXdrhOJqdAqd(Xg18CwiwEuVh1dmWaJDGFNrV5wXH)6(R78(WQUflV38(ffrbhmKOKaCN2ef90IYnM4CAze)glknHDdMnDef(aGeLa0gaHrhrHHj2kIRe3Vrmxsu8M3VO49ml2O2OJOCJTORitbSYsaK0g5jPBSOyJOCJTeajTrEs6glk3cm2fGOe3f3RBb4oTrhrb7jkbZYzffuYnUsCh(D7rNic(Vbrb7kfggrX71MvymrPUPhUjUFdIcwd2iapQffGXooikEuVh1lUlUFdIYhtCgNOypCr5wSNQELharCxC)geLBKyxigOrhrHWg14kkwcGefddjkbZMwusUOeylsu8qKsCpywol)cqUhPUjQoK4(nik1DUUiCfL6ME4MOu3qyJArj2JOaiY1ICfL6wgUIcobAwU4EWSCwo(xEIzCIYTs(qb3Ci1xa9mMs3d3KAcBuRSK5vUv(V1ceTMkzelCv0gpeD85Jnd6mox1RPWWihTKN7PJQHhQMae5YXd4A95ZceTMAEO0OoSCwfTXdrh)SzqNX5QCtekA5OL6E4MQjarU8AoJP09WnPMWg1QMae5YbI4EWSCwo(xEwHcwgizCWwSmYHuF9a1AvYWvAbAwUQjarU8AUQyh)pqTwLmCLwGMLRaD9ZDjesArxrgxvHcwgizCWwSmcVlp8FlqTarRPEnfgg5OL8CpDun8qrB8q0XNp2mOZ4CvVMcdJC0sEUNoQgEOAcqKlhpGRfiI7bZYz54F5PUhUj5wNEroK6RhOwRsgUslqZYvnbiYLxZvf74)bQ1QKHR0c0SCfOR)BbQfiAn1RPWWihTKN7PJQHhkAJhIo(8XMbDgNR61uyyKJwYZ90r1WdvtaIC54bCTarC)gefVhmZWjrPUJz5SIck5MOyJO0GR4EWSCwo(xEYcesgmlNvIsU5WgaOl2mOZ4C5I7bZYz54F5jlqizWSCwjk5MdBaGUioNwgXf3dMLZYX)YtwGqYGz5SsuYnh2aaDXg0rIHI2Ci1xwGO1uSbDKyOOnfTXdrh)3(a1AfBqhjgkAtXTG5fExaxV)Bp0duRvDuNPtgP4wW86QwF(a6HcdJ0RnRWyQgCj90vKQJ6mDYiG4ZNoRWyYMae5YR5QIDaI4EWSCwo(xE2GRmywoReLCZHnaqxVHlTK5vUvoK6RhOwREnfgg5OL8CpDun8qb6kUhmlNLJ)LNn4kdMLZkrj3Cyda01B4s3zq5w5qQVSarRPEnfgg5OL8CpDun8qrB8q0X)TSzqNX5QEnfgg5OL8CpDun8q1eGixEnaxpqe3dMLZYX)YZgCLbZYzLOKBoSba6AEO0OoSCwhs91duRvUjcfTC0sDpCtb663ceTMAEO0OoSCwfTXdrhX9Gz5SC8V8SbxzWSCwjk5MdBaGUIHCi1xbZsSrsAjajXX7YdX9Gz5SC8V8KfiKmywoReLCZHnaqxCl2t0hXDX9BquQ7MBKII33yHLZkUhmlNLRIHUAcW0CcrCU0zUg1oK6llq0AQQWWqDUvsUnnafTXdrhX9Gz5SCvme(xEwHcwgizCWwSmYHuFzbIwtP7HBCgUggsrB8q0rCpywolxfdH)LN6E4MKBD6f5adxgIKw0vKXVa2HuFXMbDgNRQjatZjeX5sN5AuRAcqKlVMlpQRk2XVfiAnvvyyOo3kj3MgGI24HOJ4EWSCwUkgc)lpXmor5wjFOGBoK6RhOwR6eaPaDf3dMLZYvXq4F5PUhUXz4Ayihs91duRvELiuUvsabdtUKc0vCpywolxfdH)LNvOGLbsghSflJCi1xn4MmP74KA1H0jlTAUf4AX3ceTMQb3KjdZOfmSCwfTXdrN6YBarCpywolxfdH)LN6E4MKBD6f5adxgIKw0vKXVa2HuF1GBYKUJtQvhsNS0Q5wGRfFlq0AQgCtMmmJwWWYzv0gpeDQlVbeX9Gz5SCvme(xE2eGP5eI4CPZCnQf3dMLZYvXq4F5PUhUXz4AyiX9Gz5SCvme(xEopuAuhg5adxgIKw0vKXVa2HuF1GBYKUJtQvhsNS0W7wpQfFlq0AQgCtMmmJwWWYzv0gpeDQlVbeX9Gz5SCvme(xEwHcwgizCWwSmsCpywolxfdH)LN6E4MKBD6f5adxgIKw0vKXVawCpywolxfdH)LNyMELJw6mxJAX9Gz5SCvme(xEgnlwsAt30AI7I73GO4ytHHrugTO8Z90r1WdrXDguUvIspwy5SII3VOWTOnUOaC9Cr5r6PjrXX5lkjxucSfjkEisCpywolx9gU0DguUvxygNOCRKpuWnhs91duRvDcGuGUI7bZYz5Q3WLUZGYTc)lpBcW0CcrCU0zUg1oK6llq0AQQWWqDUvsUnnafTXdrh)n4s4DvRpFbZsSrsAjajXX7YdX9BquUXw0vKjt9fGa7I3)Th6bQ1QoQZ0jJuClyEHpWaPUNBp0duRvDuNPtgPAcqKlhFGbsDDOWWi9AZkmMQbxspDfP6OotNm6glkEFKlfgxucrbnMdIIHj5IsYfLCnAp0ruSruSORitummKOGjRWqCtuC7C60WvuOLaGRO4mnmIsSIs8suA4kkgMWefNjcjkHRlcxrPJ6mDYirj1IsdUKE6k6OefCWeMO8OCReLyffAja4kkotdJOuVOWTG5f3brzArjwrHwcaUIIHjmrXWqIYHEGATO4mrirHpZkke2f3SjrzwL4EWSCwU6nCP7mOCRW)YZ5HsJ6Wihy4YqK0IUIm(fWoK6RgCtM0DCsT6q6KLgExEuR4EWSCwU6nCP7mOCRW)YZkuWYajJd2ILroK6RgCtM0DCsT6q6KLwnEuVFUlHqsl6kY4QkuWYajJd2ILr4D5HF2mOZ4CvUjcfTC0sDpCt1eGixoE1kUhmlNLREdx6odk3k8V8u3d3KCRtVihy4YqK0IUIm(fWoK6RgCtM0DCsT6q6KLwnEuVF2mOZ4CvUjcfTC0sDpCt1eGixoE1kUhmlNLREdx6odk3k8V8u3d34mCnmKdP(6bQ1kVsek3kjGGHjxsb66Vb3KjDhNuRoKozPH3Taxl(wGO1un4MmzygTGHLZQOnEi6uxEdi(5UecjTORiJR09WnodxddH3LhI7bZYz5Q3WLUZGYTc)lp19Wnodxdd5qQVAWnzs3Xj1QdPtwA4DDR3QfFlq0AQgCtMmmJwWWYzv0gpeDQlVbe)CxcHKw0vKXv6E4gNHRHHW7YdX9Gz5SC1B4s3zq5wH)LNZdLg1HroWWLHiPfDfz8lGDi1xn4MmP74KA1H0jln8UU1B1IVfiAnvdUjtgMrlyy5SkAJhIo1L3aI4EWSCwU6nCP7mOCRW)YZkuWYajJd2ILroK6l2mOZ4CvUjcfTC0sDpCt1eGixoEn4sklbqsBK30FdUjt6ooPwDiDYsRMBwVFUlHqsl6kY4QkuWYajJd2ILr4D5H4EWSCwU6nCP7mOCRW)YtDpCtYTo9ICGHldrsl6kY4xa7qQVyZGoJZv5Miu0Yrl19WnvtaIC541GlPSeajTrEt)n4MmP74KA1H0jlTAUz9I7I73GO4ytHHrugTO8Z90r1WdrPUJzj2irX7BSWYzf3dMLZYvVHlTK5vUvxZdLg1HroWWLHiPfDfz8lGDi1xn4MmP74K6AUUz9I7bZYz5Q3WLwY8k3k8V8SjatZjeX5sN5Au7qQVSarRPQcdd15wj520au0gpeD85lywInsslbijoExEiUhmlNLREdxAjZRCRW)YtmJtuUvYhk4MdP(6bQ1QobqkqxX9Gz5SC1B4slzELBf(xEopuAuhg5adxgIKw0vKXVa2HuF1GlPSeajTrEZAQyhF(AWnzs3Xj11CDZAf3dMLZYvVHlTK5vUv4F5PUhUXz4Ayihs91duRvELiuUvsabdtUKc01p3LqiPfDfzCLUhUXz4Ayi8U8qCpywolx9gU0sMx5wH)LNyMELJw6mxJAhs9vdUjt6ooPwDiDYsdVRBwV)gCjLLaiPnsVHxf7iUhmlNLREdxAjZRCRW)YtDpCJZW1WqoK6lUlHqsl6kY4kDpCJZW1Wq4D5H4EWSCwU6nCPLmVYTc)lpNhknQdJCGHldrsl6kY4xa7qQVAWnzs3Xj1QdPtwA45rT(81GlHN3e3dMLZYvVHlTK5vUv4F5z0SyjPnDtR5qQVAWnzs3Xj1QdPtwA4vB9I7I73GO49mOJO49ofTjkEpZEslNLlUhmlNLRyd6iXqrBxmmrUC5OLjJCi1x6ScJjBcqKlVMk2XNVhOwRCtekA5OL6E4MQjarU8A8M)hOwRyd6iXqrBkUfmVU8OE)a1ceTMAEO0OoSCwfTXdrhX9Gz5SCfBqhjgkAd)lpzyIC5Yrltg5qQVSarRPMhknQdlNvrB8q0XpqFGATYnrOOLJwQ7HBkqx)3(a1AfBqhjgkAtXTG5fExa7D(FGATcCXmiCLCRPTYWOaD957bQ1k2Gosmu0MIBbZl8Uag7beXDX9BquUrTIYncCsuQBnca3brPU3XYzfLypII3xWYaXf3dMLZYvSzqNX5YVa5Kmnca3HuFXMbDgNRYnrOOLJwQ7HBQMIdU(8XMbDgNRYnrOOLJwQ7HBQMae5YXZJ6f3dMLZYvSzqNX5YX)Yt3XYzDi1xpqTw5Miu0Yrl19WnfOR)hOwRiaUJtQLn4ssNu4oRc0vCpywolxXMbDgNlh)lpFOzosnyJRdP(6bQ1k3eHIwoAPUhUPaD9)a1AfbWDCsTSbxs6Kc3zvGUI7bZYz5k2mOZ4C54F55JAo1ELBLdP(6bQ1k3eHIwoAPUhUPaDf3dMLZYvSzqNX5YX)YZOzXssxqeNCi1x3c0hOwRCtekA5OL6E4Mc01FWSeBKKwcqsC8U8ai(8b0hOwRCtekA5OL6E4Mc01)Tn4sQdPtwA4DvR)gCtM0DCsT6q6KLgExEx9arCpywolxXMbDgNlh)lprzfgJlVrdEQaqR5qQVEGATYnrOOLJwQ7HBkqxX9Gz5SCfBg0zCUC8V8mwgXToqswGqoK6RhOwRCtekA5OL6E4Mc01)duRvea3Xj1YgCjPtkCNvb6kUhmlNLRyZGoJZLJ)LN6SPhAMJdP(6bQ1k3eHIwoAPUhUPAcqKlVMlSV)hOwRiaUJtQLn4ssNu4oRc0vCpywolxXMbDgNlh)lpFrLC0sRtMxChs91duRvUjcfTC0sDpCtb66)2hOwRCtekA5OL6E4MQjarU8AQ1VfiAnfBqhjgkAtrB8q0XNpGAbIwtXg0rIHI2u0gpeD8)a1ALBIqrlhTu3d3unbiYLxJ3aI)Gzj2ijTeGK4xalUFdII3ZmOZ4C5I7bZYz5k2mOZ4C54F5jbWDCsTSbxs6Kc3zDi1xwGO1uZdLg1HLZQOnEi64)w2mOZ4CvUjcfTC0sDpCt1uCW1FdUKYsaK0gzT4vXo(BWnzs3Xj1QdPtwA4DbC9(89a1ALBIqrlhTu3d3uGU(BWLuwcGK2iRfVk2bi(8PZkmMSjarU8A8OEX9Gz5SCfBg0zCUC8V8Ka4ooPw2GljDsH7SoK6llq0AQxtHHroAjp3thvdpu0gpeD83GBYKUJtQvhsNS0W7M17VbxszjasAJSw8Qyh)3(a1A1RPWWihTKN7PJQHhkqxF(0zfgt2eGixEnEupqe3dMLZYvSzqNX5YX)YtcG74KAzdUK0jfUZ6qQVSarRPsgXcxfTXdrh)n4s14nX9Gz5SCfBg0zCUC8V80nrOOLJwQ7HBoK6llq0AQxtHHroAjp3thvdpu0gpeD8FlBg0zCUQxtHHroAjp3thvdpunbiYL7ZhBg0zCUQxtHHroAjp3thvdpunfhC93GBYKUJtQvhsNS0QX7QhiI7bZYz5k2mOZ4C54F5PBIqrlhTu3d3Ci1xwGO1ujJyHRI24HOJFG(a1ALBIqrlhTu3d3uGUI7bZYz5k2mOZ4C54F5PBIqrlhTu3d3Ci1xwGO1uZdLg1HLZQOnEi64)wlq0AQQWWqDUvsUnnafTXdrh)pqTw1eGP5eI4CPZCnQvGU(8bulq0AQQWWqDUvsUnnafTXdrhGiUhmlNLRyZGoJZLJ)LNVMcdJC0sEUNoQgE4qQVEGATYnrOOLJwQ7HBkqxX9Gz5SCfBg0zCUC8V8u3d3CIBdGl1GnUoK6RhOwRCtekA5OL6E4MQjarU8AQyh)pqTw5Miu0Yrl19WnfORFGAbIwtnpuAuhwoRI24HOJ4EWSCwUInd6moxo(xEQ7HBoXTbWLAWgxhs9vWSeBKKwcqsC8U8WpBg0zCUk3eHIwoAPUhUPAcqKlhFGRfpl6kYuwcGK2ipj5ZNoRWyYMae5YRPIDe3dMLZYvSzqNX5YX)YtDpCZjUnaUud246qQVSarRPMhknQdlNvrB8q0XpqFGATYnrOOLJwQ7HBkqx)3E7duRvGlMbHRKBnTvggfORpFa9qHHr61MvymvdUKE6ksPdeIwjRb5XHAG4)2d9a1Avh1z6KrkUfmVUQ1NpGEOWWi9AZkmMQbxspDfP6OotNmciarCpywolxXMbDgNlh)lpXGR7yyOgqYKUnXPLroK6llq0AQxtHHroAjp3thvdpu0gpeD83GBYKUJtQvhsNS0W7M17VbxcVlV5)bQ1k3eHIwoAPUhUPaD95dOwGO1uVMcdJC0sEUNoQgEOOnEi64Vb3KjDhNuRoKozPH3Lh1kUhmlNLRyZGoJZLJ)LNDKCsEO44qQVEGATYnrOOLJwQ7HBkqxX9Gz5SCfBg0zCUC8V8edfTjjoNwgjUlUhmlNLRioNwgXVEOzoYrlnmKKwcaUoK6RhOwRCtekA5OL6E4Mc01)TpqTw5Miu0Yrl19WnvtaIC51aC9(V9bQ1QxtHHroAjp3thvdpuGU(8zbIwtnpuAuhwoRI24HOJpFwGO1ujJyHRI24HOJFGg1H60ivYWvYsloesrB8q0bi(89a1AvYWvYsloesb663ceTMkzelCv0gpeDaI4EWSCwUI4CAzeh)lpRaJ(KXkhTmQd1JHXHuFbulq0AQKrSWvrB8q0XNplq0AQKrSWvrB8q0XFuhQtJujdxjlT4qifTXdrh)pqTw5Miu0Yrl19WnvtaIC514D(FGATYnrOOLJwQ7HBkqxF(SarRPsgXcxfTXdrh)anQd1PrQKHRKLwCiKI24HOJ4EWSCwUI4CAzeh)lpzysesYTMcVCi1xpqTw5Miu0Yrl19WnvtaIC51uR)hOwRCtekA5OL6E4Mc01Npl6kYuaRSeajTrEsQMAf3dMLZYveNtlJ44F5PHHKG7Ba3JupnJCi1xpqTw1eZleX5s90msb66Z3duRvnX8crCUupnJKSbCnQvClyEvdWalUhmlNLRioNwgXX)Yt9Wa50rg1H60i5JcaoK6lG(a1ALBIqrlhTu3d3uGU(b6duRvVMcdJC0sEUNoQgEOaDf3dMLZYveNtlJ44F5jBwgTwhgDKAuaGCi1xa9bQ1k3eHIwoAPUhUPaD9d0hOwREnfgg5OL8CpDun8qb66)mMInlJwRdJosnkaqYhyVQMae5YVQxCpywolxrCoTmIJ)LNUGDQXn3k5dfCZHuFb0hOwRCtekA5OL6E4Mc01pqFGAT61uyyKJwYZ90r1WdfOR4EWSCwUI4CAzeh)lpDon6Gnkxzt8zJLroK6RhOwRCtekA5OL6E4Mc01NVhOwRiaUJtQLn4ssNu4oRc01Np2mOZ4CvVMcdJC0sEUNoQgEOAcqKlhpVRE8bUwF(iSBW01LoQCjToEisAnOHXNpc7gmDDPJkxsRJhIKwdAyKdgX9Gz5SCfX50Yio(xE2PRlIK5k5UbJCi1xa9bQ1k3eHIwoAPUhUPaD9d0hOwREnfgg5OL8CpDun8qb6kUhmlNLRioNwgXX)YtaeGPXvoAjcKLh5PPaa3HuF9a1AfbWDCsTSbxs6Kc3zvnbiYLxtT(FGAT61uyyKJwYZ90r1WdfORpF32GlPSeajTr6bEvSJ)gCtM0DCsDn1wpqe3dMLZYveNtlJ44F5ztHBUvsnkaqChs9LfDfzkmuGmmsxMHh2VEF(SORitHHcKHr6YSA8OEF(0zfgt2eGixEn1kUlUFdIYnQhknQdlNvu6XclNvCpywolxnpuAuhwo7vtaMMtiIZLoZ1O2HuFzbIwtvfggQZTsYTPbOOnEi64pywInsslbijoExEtCpywolxnpuAuhwol(xEIzCIYTs(qb3Ci1xa9mMs3d3KAcBuRSK5vUv(b6duRvELiuUvsabdtUKc0vCpywolxnpuAuhwol(xEQ7HBCgUggYHuF9a1ALxjcLBLeqWWKlPAkyMFUlHqsl6kY4kDpCJZW1Wq4D5H4EWSCwUAEO0OoSCw8V8CEO0OomYbgUmejTORiJFbSdP(6bQ1kVsek3kjGGHjxs1uWmF(a6duRvDcGuGU(5UecjTORiJRWmor5wjFOGB4D5nX9Gz5SC18qPrDy5S4F5zfkyzGKXbBXYihs9f3LqiPfDfzCvfkyzGKXbBXYi8U8W)Tn4MmP74KA1H0jlTAaUEF(AWLuwcGK2i9aVk2bi(8D7HEGATQJ6mDYif3cMx1uRpFh6bQ1QoQZ0jJunbiYLxdW1ceX9Gz5SC18qPrDy5S4F5PUhUj5wNEroK6l2ShW0uuhNKfwUvYhACQOnEi64)bQ1kQJtYcl3k5dnovClyED5H)Gzj2ijTeGK4xalUhmlNLRMhknQdlNf)lpXmor5wjFOGBoK6RhOwR6eaPaD9ZDjesArxrgxHzCIYTs(qb3W7YdX9Gz5SC18qPrDy5S4F5zfkyzGKXbBXYihs9f3LqiPfDfzCvfkyzGKXbBXYi8U8qCpywolxnpuAuhwol(xEQ7HBsU1PxKdmCzisArxrg)cyhs9vdUjt6ooPwDiDYsRgGR3NVgCjLLaiPnspWRID85dOpqTw1jasb6kUhmlNLRMhknQdlNf)lpXmor5wjFOGBoK6RhOwR6eaPaDf3dMLZYvZdLg1HLZI)LNZdLg1HroWWLHiPfDfz8lGf3f3Vbr5BXEI(ik8CRquDFw0vKjk9yHLZkUhmlNLR4wSNOpxnbyAoHiox6mxJAhs9LfiAnvvyyOo3kj3MgGI24HOJpFSzpGPPiSrTUhUPOnEi64ZxdUKE6ks9sl3kjBqhfHDdMUU0rCpywolxXTyprFW)YZkuWYajJd2ILroK6lGEOWWi9AZkmMQbxspDfP6OotNmY)Th6bQ1QoQZ0jJuClyEvtT(8DOhOwR6OotNms1eGixEnyhGiUhmlNLR4wSNOp4F5PUhUj5wNEroK6l2mOZ4CvnbyAoHiox6mxJAvtaIC51C5rDvXo(TarRPQcdd15wj520au0gpeDe3dMLZYvCl2t0h8V8u3d3KCRtVihs9fB2dyAkWfrbhdDK6M26GRI24HOJ)hOwRaxefCm0rQBARdUQMae5YRXB(8XM9aMMI64KSWYTs(qJtfTXdrh)pqTwrDCswy5wjFOXPIBbZRlpe3dMLZYvCl2t0h8V8eZ4eLBL8HcU5qQVEGATQtaKc0vCpywolxXTyprFW)YZ5HsJ6Wihs9fqFGATs3tDOv6cI4Kc01VfiAnLUN6qR0feXjfTXdrhX9Gz5SCf3I9e9b)lp19Wnj360lYHuF1GBYKUJtQvhsNS0Q5wGRfFlq0AQgCtMmmJwWWYzv0gpeDQlVbeX9Gz5SCf3I9e9b)lp19Wnodxdd5qQVEGATYReHYTsciyyYLuGU(BWLuwcGK2iVjExvSJ4EWSCwUIBXEI(G)LNZdLg1HroK6RgCtM0DCsT6q6KLgE36rT4BbIwt1GBYKHz0cgwoRI24HOtD5nGiUhmlNLR4wSNOp4F5PUhUj5wNErI7bZYz5kUf7j6d(xEIz6voAPZCnQf3dMLZYvCl2t0h8V8mAwSK0MUP1GFUlXGy5rTadnObHa]] )

end
