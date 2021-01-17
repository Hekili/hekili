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


    spec:RegisterPack( "Frost DK", 20210117, [[d40WfcqiGIhHeHlrfvfSjQuFsrmkIItruAvavQxjIAwujDlQOQq7cv)srPHHe1XuKwgvINruX0aQ4AavTnaK(gqLmoauohsKADevAEaLUhq2hs4GaiSqffpuePjsfvvUise1gbqfFejImsQOQuNKkQYkvu9sQOQQzkIyNij)eavnuauPLcGONIutLkYvPIQI(ksKySaWEP4Vu1GbDyHfJOhtyYkCzOnlQplsJgbNwYQPIQsEnsQzJYTrODl1VvA4a64irslxvpNstN01jY2bOVlcJNkkNNOQ1tfvMpvy)QSzQXjd9iu0qLlu2LPuE6uWfNYuA5qPbhxm0Q8ardnWqqDKIg6oiIgAao)A1d68Z5VHgyipBJHXjdTDLEbAOjOkqRCND20sjirYflXzTfrjwO12IpY6S2IOywdnPuXuNxBin0JqrdvUqzxMs5PtbxCktPLdLwoYXqhskH9n00fXKAOjuJb2gsd9aTcdnL4Go)WqjCqN)DLsqpiaNFT6nNsCW5rlfV8hCk4Y1d6cLDzQHMvw1ACYqVKSsXp0ABpWDzvNACYq1uJtgASdsgomZyOfFP4xHHwdg2kpnuc4xDQ3Q7tKJDqYWXbD44GIThsLYraXp)Rv5yhKmCCqhoo4l1yE)uKtwA1PEXYgCSdsgooOdhhmeAbi6XgjwO9Gua6GUyOdHwBBOFK4(wKHwRpr1k(g1qLlgNm0yhKmCyMXql(sXVcdnPuoZ)IiYLaAOdHwBBOjSjyvN6jzHvnQHk5yCYqJDqYWHzgdDi0ABd9sYkf)qrdT4lf)km0Ks5mN6IXQo1tmeeQg5pgc1qlKxWqVgFkQwdvtnQHkWX4KHg7GKHdZmgAXxk(vyOTargZRXNIQLNYcrfmFmamAbEqkaDqxoO7d(sDj8a3e4ZhyUeLEqWEqakLn0HqRTn0PSqubZhdaJwGg1qf4nozOXoiz4WmJHoeATTHo)Rv9w9lQrdT4lf)km0VuxcpWnb(8bMlrPheSheCrzdTqEbd9A8POAnun1OgQaOgNm0yhKmCyMXqhcT22qVKSsXpu0ql(sXVcd9l14bP4GGJHwiVGHEn(uuTgQMAudvGlJtgASdsgomZyOfFP4xHHoeAbi6XgjwO9Gua6GGZbDFqzoiyo4adLGp6HFGIqEUwcQRo9GUpOybe7OvExPeuFoWd6WXbbZbflGyhTY7kLG6ZbEqzn0HqRTn05FTQviVsanQrn0ILn8eW4vJtgQMACYqJDqYWHzgdT4lf)km05kLG6FKyuT9GG9GPIHHoeATTHwqiQ263SVeOrnu5IXjdn2bjdhMzm0IVu8RWqdMdQbdBLVKSsXp0ABo2bjdhh09bjLYzoWIXI3VzF(xRYFKyuT9GG9GY5GUpiPuoZbwmw8(n7Z)AvUeWd6(GKs5mxSSHNagVYTAiO(Gua6GtPSHoeATTHwqiQ263SVeOrnujhJtgASdsgomZyOfFP4xHHgmhudg2kFjzLIFO12CSdsgooO7doWqj4PURuck)LAmVFkYZbJHTx8s2yG)bDFqWCqsPCMdSyS49B2N)1QCjGh09bL5GKs5mxSSHNagVYTAiO(Gua6GtbOh09bjLYzUutyzY7T6JDQsGlb8GoCCqsPCMlw2WtaJx5wneuFqkaDWPu6d6(GIDzJnrZbwmw8(n7Z)Av(JeJQThKIdoLYhuwdDi0ABdTGquT1VzFjqJAOcCmozOXoiz4WmJHw8LIFfgAWCqnyyR8LKvk(HwBZXoiz44GUpiyo4adLGN6UsjO8xQX8(Piphmg2EXlzJb(h09bjLYzUyzdpbmELB1qq9bPa0bNs5d6(GG5GKs5mhyXyX73Sp)Rv5sapO7dk2Ln2enhyXyX73Sp)Rv5psmQ2EqkoOlu2qhcT22qlievB9B2xc0OgQaVXjdn2bjdhMzm0IVu8RWqRbdBLVKSsXp0ABo2bjdhh09bbZbjLYzoWIXI3VzF(xRYLaEq3huMdskLZCXYgEcy8k3QHG6dsbOdofGEq3hKukN5snHLjV3Qp2PkbUeWd6WXbjLYzUyzdpbmELB1qq9bPa0bNsPpOdhhuSlBSjAoWIXI3VzF(xRYFKyuT9GG9GY5GUpiPuoZflB4jGXRCRgcQpifGo4uW5GYAOdHwBBOfeIQT(n7lbAuJAOxswP4hATTXjdvtnozOXoiz4WmJHw8LIFfg6qOfGOhBKyH2dsbOdkNd6(GYCqnyyR80qjGF1PERUpro2bjdhh0HJdk2Eivkhbe)8VwLJDqYWXbD44GVuJ59trozPvN6flBWXoiz44GYAOdHwBBOFK4(wKHwRpr1k(g1qLlgNm0yhKmCyMXql(sXVcdnyo4yvE(xR6ZiG4Z1sqD1Ph09bbZbjLYzo1fJvDQNyiiunYLaAOdHwBBOjSjyvN6jzHvnQHk5yCYqJDqYWHzgdT4lf)km0Ks5mN6IXQo1tmeeQg5pgc9GUpOfiYyEn(uuT88Vw1kKxjGhKcqh0Ld6(GYCqsPCMpWqjy9djKB1qq9bbDqa2bD44GG5Gdmuc(Oh(bkc55AjOU60d6WXbbZbflGyhTY7kLG6ZbEqzn0HqRTn05FTQviVsanQHkWX4KHg7GKHdZmg6qO12g6LKvk(HIgAXxk(vyOjLYzo1fJvDQNyiiunYFme6bD44GG5GKs5m)lIixc4bDFqlqKX8A8POA5e2eSQt9KSWQhKcqhuogAH8cg614tr1AOAQrnubEJtgASdsgomZyOfFP4xHH2cezmVgFkQwEklevW8XaWOf4bPa0bD5GUpOmh8L6s4bUjWNpWCjk9GG9GtP8bD44GVuJCTiIED9UCqkoyQyCqzpOdhhuMdoqsPCM)HZTFjqUvdb1heShe8h0HJdoqsPCM)HZTFjq(JeJQTheShCk4pOSg6qO12g6uwiQG5JbGrlqJAOcGACYqJDqYWHzgdT4lf)km0IThsLYXpgLi0Qt9KSnbh7GKHJd6(GKs5mh)yuIqRo1tY2eCRgcQpiOd6YbDFWqOfGOhBKyH2dc6Gtn0HqRTn05FTQ3QFrnAudvGlJtgASdsgomZyOfFP4xHHMukN5Fre5sapO7dAbImMxJpfvlNWMGvDQNKfw9Gua6GUyOdHwBBOjSjyvN6jzHvnQHkaMXjdn2bjdhMzm0IVu8RWqBbImMxJpfvlpLfIky(yay0c8Gua6GUyOdHwBBOtzHOcMpgagTanQHkkTXjdn2bjdhMzm0HqRTn05FTQ3QFrnAOfFP4xHHgmhudg2kpamyrliGCSdsgooO7dcMdskLZCQlgR6upXqqOAKlb8GoCCqnyyR8aWGfTGaYXoiz44GUpiyoiPuoZ)IiYLaAOfYlyOxJpfvRHQPg1q1ukBCYqJDqYWHzgdT4lf)km0Ks5m)lIixcOHoeATTHMWMGvDQNKfw1OgQMo14KHg7GKHdZmg6qO12g6LKvk(HIgAH8cg614tr1AOAQrnQH2QrpIFyCYq1uJtgASdsgomZyOfFP4xHHwdg2kpnuc4xDQ3Q7tKJDqYWXbD44GIThsLYraXp)Rv5yhKmCCqhoo4l1yE)uKtwA1PEXYgCSdsgom0HqRTn0psCFlYqR1NOAfFJAOYfJtgASdsgomZyOfFP4xHHgmhCGHsWtDxPeu(l1yE)uK)HZTFjWd6(GYCWbskLZ8pCU9lbYTAiO(GG9GG)GoCCWbskLZ8pCU9lbYFKyuT9GG9GGRdkRHoeATTHoLfIky(yay0c0OgQKJXjdn2bjdhMzm0IVu8RWql2Ln2en)rI7BrgAT(evR4ZFKyuT9GGf0bD5GG7dMkgh09b1GHTYtdLa(vN6T6(e5yhKmCyOdHwBBOZ)AvVv)IA0OgQahJtgASdsgomZyOfFP4xHHwS9qQuo(XOeHwDQNKTj4yhKmCCq3hKukN54hJseA1PEs2MGB1qq9bbDqxoOdhhuS9qQuUuZWWsah(8JTZjph7GKHJd6(GKs5mxQzyyjGdF(X25KN)iXOA7bb7bLZbDFqsPCMl1mmSeWHp)y7CYZLaAOdHwBBOZ)AvVv)IA0OgQaVXjdn2bjdhMzm0IVu8RWqtkLZ8ViICjGg6qO12gAcBcw1PEswyvJAOcGACYqJDqYWHzgdT4lf)km0G5GKs5mp)RZHThOeZICjGh09b1GHTYZ)6Cy7bkXSih7GKHJd6WXbjLYzo1fJvDQNyiiunYFme6bD44Gdmuc(Oh(bkc55AjOU60d6(GIfqSJw5DLsq95apO7dskLZ8bgkbRFiHCRgcQpifheGDqhoo4l1ixlIOxxp4CqWc6GPIHHoeATTHEjzLIFOOrnubUmozOXoiz4WmJHw8LIFfg6xQlHh4MaF(aZLO0dc2dkZbNc(dM8b1GHTYFPUe(qvSLcT2MJDqYWXbb3huohuwdDi0ABdD(xR6T6xuJg1qfaZ4KHg7GKHdZmgAXxk(vyOFPUeEGBc85dmxIspifhuMd6c4pyYhudg2k)L6s4dvXwk0ABo2bjdhheCFq5Cqzn0HqRTn0ljRu8dfnQHkkTXjdDi0ABdD(xR6T6xuJgASdsgomZyudvtPSXjdDi0ABdnH9B)M9jQwX3qJDqYWHzgJAOA6uJtg6qO12g64frJED)hB1qJDqYWHzgJAudn5A9a3LvDQXjdvtnozOXoiz4WmJHw8LIFfgAsPCM)frKlb0qhcT22qtytWQo1tYcRAudvUyCYqJDqYWHzgdT4lf)km0Hqlarp2iXcThKcqh0Ld6WXbFPg5Are966b)bblOdMkgh09bL5GAWWw5PHsa)Qt9wDFICSdsgooOdhhuS9qQuoci(5FTkh7GKHJd6WXbFPgZ7NICYsRo1lw2GJDqYWXbL1qhcT22q)iX9TidTwFIQv8nQHk5yCYqJDqYWHzgdDi0ABd9sYkf)qrdT4lf)km0VuxcpWnb(8bMlrPhKcqh0fWBOfYlyOxJpfvRHQPg1qf4yCYqJDqYWHzgdT4lf)km0VuxcpWnb(8bMlrPheSh0fkFq3h0cezmVgFkQwEklevW8XaWOf4bPa0bD5GUpOyx2yt0CGfJfVFZ(8VwL)iXOA7bP4GG3qhcT22qNYcrfmFmamAbAudvG34KHg7GKHdZmg6qO12g68Vw1B1VOgn0IVu8RWq)sDj8a3e4ZhyUeLEqWEqxO8bDFqXUSXMO5alglE)M95FTk)rIr12dsXbbVHwiVGHEn(uuTgQMAudvauJtgASdsgomZyOfFP4xHHMukN5uxmw1PEIHGq1i)XqOh09bFPUeEGBc85dmxIspifhuMdof8hm5dQbdBL)sDj8HQylfATnh7GKHJdcUpOCoOSh09bTargZRXNIQLN)1QwH8kb8Gua6GUCq3huMdskLZ8bgkbRFiHCRgcQpiOdcWoOdhhemhCGHsWh9Wpqripxlb1vNEqhooiyoOybe7OvExPeuFoWdkRHoeATTHo)RvTc5vcOrnubUmozOXoiz4WmJHw8LIFfg6xQlHh4MaF(aZLO0dsbOdkZbLd4pyYhudg2k)L6s4dvXwk0ABo2bjdhheCFq5CqzpO7dAbImMxJpfvlp)RvTc5vc4bPa0bD5GUpOmhKukN5dmucw)qc5wneuFqqheGDqhooiyo4adLGp6HFGIqEUwcQRo9GoCCqWCqXci2rR8UsjO(CGhuwdDi0ABdD(xRAfYReqJAOcGzCYqJDqYWHzgdDi0ABd9sYkf)qrdT4lf)km0VuxcpWnb(8bMlrPhKcqhuMdkhWFWKpOgmSv(l1LWhQITuO12CSdsgooi4(GY5GYAOfYlyOxJpfvRHQPg1qfL24KHg7GKHdZmgAXxk(vyOf7YgBIMdSyS49B2N)1Q8hjgvBpifh8LAKRfr0RRhCoO7d(sDj8a3e4ZhyUeLEqWEqWHYh09bTargZRXNIQLNYcrfmFmamAbEqkaDqxm0HqRTn0PSqubZhdaJwGg1q1ukBCYqJDqYWHzgdDi0ABdD(xR6T6xuJgAXxk(vyOf7YgBIMdSyS49B2N)1Q8hjgvBpifh8LAKRfr0RRhCoO7d(sDj8a3e4ZhyUeLEqWEqWHYgAH8cg614tr1AOAQrnQHwSaID0Q14KHQPgNm0yhKmCyMXql(sXVcd9h1WJaITYJXWYR(GuCWPG)GoCCqWCWpQHhbeBLhJHLJoRSQ9GoCCWqOfGOhBKyH2dsbOd6IHoeATTHEGHsW6hsOrnu5IXjdn2bjdhMzm0IVu8RWqhcTae9yJel0EqqhC6bDFWxQlHh4MaF(aZLO0dsXbLZbDFqXUSXMO5alglE)M95FTk)rIr12dc2dkNd6(GG5GAWWw5Kpgkb)M92QhFKU2GJDqYWXbDFqzoiyo4h1WJaITYJXWYrNvw1Eqhoo4h1WJaITYJXWYR(GuCWPG)GYAOdHwBBOTjINy1PEILvnQHk5yCYqJDqYWHzgdT4lf)km0Hqlarp2iXcThKcqh0Ld6(GG5GAWWw5Kpgkb)M92QhFKU2GJDqYWHHoeATTH2MiEIvN6jww1OgQahJtgASdsgomZyOfFP4xHHwdg2kN8Xqj43S3w94J01gCSdsgooO7dkZbjLYzo5JHsWVzVT6XhPRn4sapO7dkZbdHwaIESrIfApiOdo9GUp4l1LWdCtGpFG5su6bP4GGdLpOdhhmeAbi6XgjwO9Gua6GUCq3h8L6s4bUjWNpWCjk9GuCqakLpOSh0HJdcMdskLZCYhdLGFZEB1JpsxBWLaEq3huSlBSjAo5JHsWVzVT6XhPRn4psmQ2Eqzn0HqRTn02eXtS6upXYQg1qf4nozOXoiz4WmJHw8LIFfg6qOfGOhBKyH2dc6GtpO7dk2Ln2enhyXyX73Sp)Rv5psmQ2EqWEq5Cq3huMdcMd(rn8iGyR8ymSC0zLvTh0HJd(rn8iGyR8ymS8QpifhCk4pOSg6qO12g6GCjwDO12EwrK0OgQaOgNm0yhKmCyMXql(sXVcdDi0cq0JnsSq7bPa0bDXqhcT22qhKlXQdT22ZkIKg1qf4Y4KHg7GKHdZmgAXxk(vyOdHwaIESrIfApiOdo9GUpOyx2yt0CGfJfVFZ(8VwL)iXOA7bb7bLZbDFqzoiyo4h1WJaITYJXWYrNvw1Eqhoo4h1WJaITYJXWYR(GuCWPG)GYAOdHwBBOTecb1m0ReqVuNyFLG8g1qfaZ4KHg7GKHdZmgAXxk(vyOdHwaIESrIfApifGoOlg6qO12gAlHqqnd9kb0l1j2xjiVrnQHg4JILizOgNmQHwSlBSjARXjdvtnozOXoiz4WmJHw8LIFfgAXUSXMO5alglE)M95FTk)Xyi)bD44GIDzJnrZbwmw8(n7Z)Av(JeJQThKId6cLn0HqRTn0sw0xks0AudvUyCYqJDqYWHzgdT4lf)km0Ks5mhyXyX73Sp)Rv5sapO7dskLZCKiWnb((xQrFcmaUnxcOHoeATTHg4Q12g1qLCmozOXoiz4WmJHw8LIFfgAsPCMdSyS49B2N)1QCjGh09bjLYzose4MaF)l1Opbga3Mlb0qhcT22qtY2D4ZsV8g1qf4yCYqJDqYWHzgdT4lf)km0Ks5mhyXyX73Sp)Rv5san0HqRTn0K4BXN6QtnQHkWBCYqJDqYWHzgdT4lf)km0YCqWCqsPCMdSyS49B2N)1QCjGh09bdHwaIESrIfApifGoOlhu2d6WXbbZbjLYzoWIXI3VzF(xRYLaEq3huMd(snYhyUeLEqkaDqWFq3h8L6s4bUjWNpWCjk9Gua6GaukFqzn0HqRTn0XlIg9aLyw0OgQaOgNm0yhKmCyMXql(sXVcdnPuoZbwmw8(n7Z)AvUeqdDi0ABdnRsjOwVZxsJuIyRg1qf4Y4KHg7GKHdZmgAXxk(vyOjLYzoWIXI3VzF(xRYLaEq3hKukN5irGBc89VuJ(eyaCBUeqdDi0ABdD0c0QFW8IGXmQHkaMXjdn2bjdhMzm0IVu8RWqtkLZCGfJfVFZ(8VwL)iXOA7bblOdcWoO7dskLZCKiWnb((xQrFcmaUnxcOHoeATTHoxpsY2DyudvuAJtgASdsgomZyOfFP4xHHMukN5alglE)M95FTkxc4bDFWqOfGOhBKyH2dc6GtpO7dkZbjLYzoWIXI3VzF(xRYFKyuT9GG9GG)GUpOgmSvUyzdpbmELJDqYWXbD44GG5GAWWw5ILn8eW4vo2bjdhh09bjLYzoWIXI3VzF(xRYFKyuT9GG9GY5GYAOdHwBBOjJu)M96xcQTg1q1ukBCYqJDqYWHzgdT4lf)km0AWWw5ljRu8dT2MJDqYWXbDFqzoOyx2yt0CGfJfVFZ(8VwL)ymK)GUp4l1ixlIOxxp4pifhmvmoO7d(sDj8a3e4ZhyUeLEqkaDWPu(GoCCqsPCMdSyS49B2N)1QCjGh09bFPg5Are966b)bP4GPIXbL9GoCCWCLsq9psmQ2EqWEqxOSHoeATTHgjcCtGV)LA0NadGBBudvtNACYqJDqYWHzgdT4lf)km0AWWw5Kpgkb)M92QhFKU2GJDqYWXbDFWxQlHh4MaF(aZLO0dsXbbhkFq3h8LAKRfr0RRh8hKIdMkgh09bL5GKs5mN8Xqj43S3w94J01gCjGh0HJdMRucQ)rIr12dc2d6cLpOSg6qO12gAKiWnb((xQrFcmaUTrnun1fJtgASdsgomZyOfFP4xHHwdg2kVeOiaYXoiz44GUp4l14bb7bLJHoeATTHgjcCtGV)LA0NadGBBudvtLJXjdn2bjdhMzm0IVu8RWqRbdBLt(yOe8B2BRE8r6Ado2bjdhh09bL5GIDzJnrZjFmuc(n7Tvp(iDTb)rIr12d6WXbf7YgBIMt(yOe8B2BRE8r6Ad(JXq(d6(GVuxcpWnb(8bMlrPheSheGs5dkRHoeATTHgyXyX73Sp)RvnQHQPGJXjdn2bjdhMzm0IVu8RWqRbdBLxcuea5yhKmCCq3hemhKukN5alglE)M95FTkxcOHoeATTHgyXyX73Sp)RvnQHQPG34KHg7GKHdZmgAXxk(vyO1GHTYxswP4hATnh7GKHJd6(GYCqnyyR80qjGF1PERUpro2bjdhh09bjLYz(Je33Im0A9jQwXNlb8GoCCqWCqnyyR80qjGF1PERUpro2bjdhhuwdDi0ABdnWIXI3VzF(xRAudvtbOgNm0yhKmCyMXql(sXVcdnPuoZbwmw8(n7Z)AvUeqdDi0ABdn5JHsWVzVT6XhPRnmQHQPGlJtgASdsgomZyOfFP4xHHMukN5alglE)M95FTk)rIr12dc2dMkgh09bjLYzoWIXI3VzF(xRYLaEq3hemhudg2kFjzLIFO12CSdsgom0HqRTn05FTAc5FIwFw6L3OgQMcWmozOXoiz4WmJHw8LIFfg6qOfGOhBKyH2dsbOd6YbDFqzoiPuoZbwmw8(n7Z)AvUeWd6(GKs5mhyXyX73Sp)Rv5psmQ2EqWEWuX4GoCCWpQHhbeBLhJHLJoRSQ9GUp4h1WJaITYJXWYFKyuT9GG9GPIXbD44G5kLG6FKyuT9GG9GPIXbL1qhcT22qN)1QjK)jA9zPxEJAOAkL24KHg7GKHdZmgAXxk(vyO1GHTYxswP4hATnh7GKHJd6(GG5GKs5mhyXyX73Sp)Rv5sapO7dkZbL5GKs5mxQjSm59w9XovjWLaEqhooiyo4adLGN6UsjO8xQX8(Piphmg2EXlzJb(hu2d6(GYCWbskLZ8pCU9lbYTAiO(GGoi4pOdhhemhCGHsWtDxPeu(l1yE)uK)HZTFjWdk7bL1qhcT22qN)1QjK)jA9zPxEJAOYfkBCYqJDqYWHzgdT4lf)km0AWWw5Kpgkb)M92QhFKU2GJDqYWXbDFWxQlHh4MaF(aZLO0dsXbbhkFq3h8LA8Gua6GY5GUpiPuoZbwmw8(n7Z)AvUeWd6WXbbZb1GHTYjFmuc(n7Tvp(iDTbh7GKHJd6(GVuxcpWnb(8bMlrPhKcqh0fWBOdHwBBOjipWvjGpXs4b(OfBbAudvUm14KHg7GKHdZmgAXxk(vyOjLYzoWIXI3VzF(xRYLaAOdHwBBO)OSOFGXWOgQCXfJtgASdsgomZyOfFP4xHHoeAbi6XgjwO9Gua6GUCq3huMdcevEkHvIXFKyuT9GG9GPIXbD44GA8POY1Ii611pk8GG9GPIXbL1qhcT22qBdXx5subZdmeQrnu5ICmozOXoiz4WmJHw8LIFfg6qOfGOhBKyH2dsXbb)bD44GVuJ59troqcy8lXTrlh7GKHddDi0ABd9adLGp6HFGIqEJAudn5A9AjOU6uJtgQMACYqJDqYWHzgdDi0ABd9sYkf)qrdT4lf)km0VuxcpWnb(8bMlrPhKcqheGszdTqEbd9A8POAnun1OgQCX4KHg7GKHdZmgAXxk(vyO1GHTYtdLa(vN6T6(e5yhKmCCqhooOy7HuPCeq8Z)Avo2bjdhh0HJd(snM3pf5KLwDQxSSbh7GKHJd6WXbdHwaIESrIfApifGoOlg6qO12g6hjUVfzO16tuTIVrnujhJtgASdsgomZyOfFP4xHHMukN5Fre5sapO7dkZbFPUeEGBc85dmxIspiypi4b)bD44GVuJCTiIED9Y5GGf0btfJd6WXbTargZRXNIQLtytWQo1tYcREqkaDqxoOSg6qO12gAcBcw1PEswyvJAOcCmozOXoiz4WmJHoeATTHEjzLIFOOHw8LIFfg6xQrUwerVUEW5GG9GPIXbD44GVuxcpWnb(8bMlrPhKcqheCaVHwiVGHEn(uuTgQMAudvG34KHg7GKHdZmgAXxk(vyOjLYzo1fJvDQNyiiunYLaEq3h0cezmVgFkQwE(xRAfYReWdsbOd6YbDFqzoiyo4adLGp6HFGIqEUwcQRo9GUpOybe7OvExPeuFoWd6WXbbZbflGyhTY7kLG6ZbEqzn0HqRTn05FTQviVsanQHkaQXjdn2bjdhMzm0IVu8RWq)sDj8a3e4ZhyUeLEqkaDqWHYh09bFPg5Are966LZbP4GPIHHoeATTHMW(TFZ(evR4BudvGlJtgASdsgomZyOfFP4xHH2cezmVgFkQwE(xRAfYReWdsbOd6YbDFqzoiPuoZhyOeS(HeYTAiO(GGoia7GoCCqWCWbgkbF0d)afH8CTeuxD6bD44GG5GIfqSJw5DLsq95apOSg6qO12g68Vw1kKxjGg1qfaZ4KHg7GKHdZmg6qO12g6LKvk(HIgAXxk(vyOFPUeEGBc85dmxIspifh0fWFq3h8LA8GuCq5yOfYlyOxJpfvRHQPg1qfL24KHg7GKHdZmgAXxk(vyOjLYz(xerUeqdDi0ABdnHnbR6upjlSQrnunLYgNm0yhKmCyMXql(sXVcd9l1LWdCtGpFG5su6bP4GGNYg6qO12g64frJED)hB1Og1qpWCiXuJtgQMACYqhcT22qtS6Hp)i6COHg7GKHdZmg1qLlgNm0yhKmCyMXql(sXVcdnyo4yvE(xR6ZiG4Z1sqD1Ph09bL5GAWWw5Lafbqo2bjdhh0HJdk2Ln2enN8Xqj43S3w94J01g8hjgvBpifhCk4pOdhhudg2kFjzLIFO12CSdsgooO7dk2Ln2enhyXyX73Sp)Rv5psmQ2Eq3hemhKukN5uxmw1PEIHGq1ixc4bL1qhcT22qtytWQo1tYcRAudvYX4KHg7GKHdZmgAXxk(vyOjLYzEjK3RbBBl)rIr12dcwqhmvmoO7dskLZ8siVxd22wUeWd6(GwGiJ514tr1YtzHOcMpgagTapifGoOlh09bL5GG5GAWWw5Kpgkb)M92QhFKU2GJDqYWXbD44GIDzJnrZjFmuc(n7Tvp(iDTb)rIr12dsXbNc(dkRHoeATTHoLfIky(yay0c0OgQahJtgASdsgomZyOfFP4xHHMukN5LqEVgSTT8hjgvBpiybDWuX4GUpiPuoZlH8EnyBB5sapO7dkZbbZb1GHTYjFmuc(n7Tvp(iDTbh7GKHJd6WXbf7YgBIMt(yOe8B2BRE8r6Ad(JeJQThKIdof8huwdDi0ABdD(xR6T6xuJg1qf4nozOXoiz4WmJHoeATTHwemMpeATTNvw1qZkR67GiAOflGyhTAnQHkaQXjdn2bjdhMzm0HqRTn0IGX8HqRT9SYQgAwzvFherdTyx2yt0wJAOcCzCYqJDqYWHzgdT4lf)km0AWWw5ILn8eW4vo2bjdhh09bL5GKs5mxSSHNagVYTAiO(Gua6GtP8bDFqzo4ajLYz(ho3(La5wneuFqqhe8h0HJdcMdoWqj4PURuck)LAmVFkY)W52Ve4bL9GoCCWCLsq9psmQ2EqWc6GPIXbL1qhcT22qlcgZhcT22ZkRAOzLv9Dqen0ILn8eW4vJAOcGzCYqJDqYWHzgdT4lf)km0Ks5mN8Xqj43S3w94J01gCjGg6qO12g6xQ9HqRT9SYQgAwzvFherdn5A9AjOU6uJAOIsBCYqJDqYWHzgdT4lf)km0AWWw5Kpgkb)M92QhFKU2GJDqYWXbDFqzoOyx2yt0CYhdLGFZEB1JpsxBWFKyuT9GG9GtP8bL1qhcT22q)sTpeATTNvw1qZkR67GiAOjxRh4USQtnQHQPu24KHg7GKHdZmgAXxk(vyOjLYzoWIXI3VzF(xRYLaEq3hudg2kFjzLIFO12CSdsgom0HqRTn0Vu7dHwB7zLvn0SYQ(oiIg6LKvk(HwBBudvtNACYqJDqYWHzgdT4lf)km0AWWw5ljRu8dT2MJDqYWXbDFqXUSXMO5alglE)M95FTk)rIr12dc2doLYg6qO12g6xQ9HqRT9SYQgAwzvFherd9sYkf)qRT9a3LvDQrnun1fJtgASdsgomZyOfFP4xHHoeAbi6XgjwO9Gua6GUyOdHwBBOFP2hcT22ZkRAOzLv9Dqen0XIg1q1u5yCYqJDqYWHzgdDi0ABdTiymFi0ABpRSQHMvw13br0qB1OhXpmQrn0XIgNmun14KHoeATTH(rI7BrgAT(evR4BOXoiz4WmJrnu5IXjdn2bjdhMzm0IVu8RWqRbdBLN)1QwH8kbKJDqYWHHoeATTHoLfIky(yay0c0OgQKJXjdn2bjdhMzm0HqRTn05FTQ3QFrnAOfFP4xHHwSlBSjA(Je33Im0A9jQwXN)iXOA7bblOd6Ybb3hmvmoO7dQbdBLNgkb8Ro1B19jYXoiz4WqlKxWqVgFkQwdvtnQHkWX4KHg7GKHdZmgAXxk(vyOjLYz(xerUeqdDi0ABdnHnbR6upjlSQrnubEJtgASdsgomZyOfFP4xHHEGHsWh9Wpqripxlb1vNEq3huSaID0kVRucQph4bDFqsPCMpWqjy9djKB1qq9bP4GamdDi0ABd9sYkf)qrJAOcGACYqJDqYWHzgdT4lf)km0Ks5mN6IXQo1tmeeQg5pgc9GUpOmhemhCGHsWh9Wpqripxlb1vNEq3huSaID0kVRucQph4bD44GG5GIfqSJw5DLsq95apOSg6qO12g68Vw1kKxjGg1qf4Y4KHg7GKHdZmgAXxk(vyOFPUeEGBc85dmxIspiypOmhCk4pyYhudg2k)L6s4dvXwk0ABo2bjdhheCFq5Cqzn0HqRTn0PSqubZhdaJwGg1qfaZ4KHg7GKHdZmg6qO12g68Vw1B1VOgn0IVu8RWq)sDj8a3e4ZhyUeLEqWEqzo4uWFWKpOgmSv(l1LWhQITuO12CSdsgooi4(GY5GYAOfYlyOxJpfvRHQPg1qfL24KHg7GKHdZmgAXxk(vyObZbhyOe8rp8dueYZ1sqD1Ph09bflGyhTY7kLG6ZbEqhooiyoOybe7OvExPeuFoqdDi0ABdD(xRAfYReqJAOAkLnozOXoiz4WmJHoeATTHEjzLIFOOHw8LIFfg6xQlHh4MaF(aZLO0dsXbL5GUa(dM8b1GHTYFPUe(qvSLcT2MJDqYWXbb3huohuwdTqEbd9A8POAnun1OgQMo14KHoeATTHoLfIky(yay0c0qJDqYWHzgJAOAQlgNm0yhKmCyMXqhcT22qN)1QER(f1OHwiVGHEn(uuTgQMAudvtLJXjdDi0ABdnH9B)M9jQwX3qJDqYWHzgJAOAk4yCYqhcT22qhViA0R7)yRgASdsgomZyuJAudnG4BRTnu5cLDHYtDzQCm0jIVRo1AOPuaiaiPY5rfLKCp4bDIaEWIiW91dM3)GtwswP4hATTh4USQtNCWhPuLQhhh0UeXdgs6smuCCqbHOtrl)MNKQXdovUhmPBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZuNjl)MNKQXdovUhmPBdi(koo4KxQX8(PihatoOUhCYl1yE)uKdao2bjdhtoOmtDMS8BEsQgp4u5EWKUnG4R44GteBpKkLdGjhu3dorS9qQuoa4yhKmCm5GYm1zYYV53CkfacasQCEurjj3dEqNiGhSicCF9G59p4eXYgEcy86Kd(iLQu944G2LiEWqsxIHIJdkieDkA538KunEqxK7bt62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYm1zYYV5jPA8GYrUhmPBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZuNjl)MNKQXdcoY9GjDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzM6mz538KunEqWl3dM0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLzQZKLFZV5ukaeaKu58OIssUh8Gorapyre4(6bZ7FWjljRu8dT2EYbFKsvQECCq7sepyiPlXqXXbfeIofT8BEsQgp4u5EWKUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmtDMS8BEsQgp4u5EWKUnG4R44GtEPgZ7NICam5G6EWjVuJ59troa4yhKmCm5GYm1zYYV5jPA8GtL7bt62aIVIJdorS9qQuoaMCqDp4eX2dPs5aGJDqYWXKdkZuNjl)MNKQXdcqL7bt62aIVIJdorS9qQuoaMCqDp4eX2dPs5aGJDqYWXKdkZuNjl)MNKQXdsPL7bt62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GY4IZKLFZV5ukaeaKu58OIssUh8Gorapyre4(6bZ7FWjKR1RLG6QtNCWhPuLQhhh0UeXdgs6smuCCqbHOtrl)MNKQXd6ICpys3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMPotw(npjvJh0f5EWKUnG4R44GtEPgZ7NICam5G6EWjVuJ59troa4yhKmCm5GYm1zYYV5jPA8GUi3dM0TbeFfhhCIy7HuPCam5G6EWjIThsLYbah7GKHJjhuMPotw(n)MtPaqaqsLZJkkj5EWd6eb8GfrG7RhmV)bNy1OhXpMCWhPuLQhhh0UeXdgs6smuCCqbHOtrl)MNKQXdovUhmPBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZuNjl)MNKQXdovUhmPBdi(koo4KxQX8(PihatoOUhCYl1yE)uKdao2bjdhtoyOhKsgGpjhuMPotw(npjvJhCQCpys3gq8vCCWjIThsLYbWKdQ7bNi2EivkhaCSdsgoMCqzM6mz538KunEq5i3dM0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbd9GuYa8j5GYm1zYYV5jPA8GGJCpys3gq8vCCWjIThsLYbWKdQ7bNi2EivkhaCSdsgoMCqzCXzYYV5jPA8Gau5EWKUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmtDMS8BEsQgpi4sUhmPBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZuNjl)MNKQXdcWK7bt62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYm1zYYV53CkfacasQCEurjj3dEqNiGhSicCF9G59p4eY16bUlR60jh8rkvP6XXbTlr8GHKUedfhhuqi6u0YV5jPA8GUi3dM0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLzQZKLFZts14bDrUhmPBdi(koo4KxQX8(PihatoOUhCYl1yE)uKdao2bjdhtoOmtDMS8BEsQgpOlY9GjDBaXxXXbNi2EivkhatoOUhCIy7HuPCaWXoiz4yYbLzQZKLFZts14bbOY9GjDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzM6mz538KunEqWLCpys3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMPotw(npjvJheGj3dM0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLzQZKLFZV5ukaeaKu58OIssUh8Gorapyre4(6bZ7FWjIDzJnrBNCWhPuLQhhh0UeXdgs6smuCCqbHOtrl)MNKQXdoLYY9GjDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzM6mz538KunEWPtL7bt62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYm1zYYV5jPA8GtDrUhmPBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZuNjl)MNKQXdovoY9GjDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzM6mz538KunEWPGJCpys3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMPotw(npjvJhCk4L7bt62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYm1zYYV5jPA8GtbxY9GjDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCWqpiLmaFsoOmtDMS8BEsQgp4ukTCpys3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMPotw(npjvJh0fkl3dM0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLXfNjl)MNKQXd6ICK7bt62aIVIJdo5LAmVFkYbWKdQ7bN8snM3pf5aGJDqYWXKdg6bPKb4tYbLzQZKLFZV5ukaeaKu58OIssUh8Gorapyre4(6bZ7FWjIfqSJwTto4JuQs1JJdAxI4bdjDjgkooOGq0POLFZts14bDrUhmPBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZuNjl)MNKQXdkh5EWKUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoyOhKsgGpjhuMPotw(npjvJheCK7bt62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYm1zYYV53CkfacasQCEurjj3dEqNiGhSicCF9G59p4KbMdjMo5GpsPkvpooODjIhmK0LyO44GccrNIw(npjvJh0f5EWKUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmU4mz538KunEq5i3dM0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLzQZKLFZts14bbh5EWKUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmtDMS8BEsQgpi4sUhmPBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZuNjl)MNKQXdsPL7bt62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYm1zYYV5jPA8GtPSCpys3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhm0dsjdWNKdkZuNjl)MNKQXdoDQCpys3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMPotw(n)MtPaqaqsLZJkkj5EWd6eb8GfrG7RhmV)bNelo5GpsPkvpooODjIhmK0LyO44GccrNIw(npjvJh0f5EWKUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoyOhKsgGpjhuMPotw(npjvJhuoY9GjDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCWqpiLmaFsoOmtDMS8BEsQgpi4sUhmPBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZuNjl)MNKQXdcWK7bt62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYm1zYYV5jPA8GtPSCpys3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMPotw(n)M78icCFfhhCkLpyi0A7dYkRA53CdTfikmu5c4NAOb(BUyOHMsCqNFyOeoOZ)UsjOheGZVw9Mtjo48OLIx(dofC56bDHYUm9MFZPehKs2zOqsXXbraXx(dQfr8Gkb8GHq3)GL9GbGrXcsgYV5HqRTTGiw9WNFeDo8MtjoiabqGm5piaNFT6bb4GaI)bJECqIr1Au9bDEc5pOtbBB7npeATTnzqZsytWQo1tYcR6ALbbMXQ88Vw1NraXNRLG6QtDlJgmSvEjqra0HdXUSXMO5Kpgkb)M92QhFKU2G)iXOAlftbVdhAWWw5ljRu8dT22Tyx2yt0CGfJfVFZ(8VwL)iXOARBWqkLZCQlgR6upXqqOAKlbu2BEi0ABBYGMnLfIky(yay0c01kdIukN5LqEVgSTT8hjgvBblOuXWnPuoZlH8EnyBB5saDBbImMxJpfvlpLfIky(yay0cKcqU4wgWObdBLt(yOe8B2BRE8r6Adhoe7YgBIMt(yOe8B2BRE8r6Ad(JeJQTumf8YEZdHwBBtg0S5FTQ3QFrn6ALbrkLZ8siVxd22w(JeJQTGfuQy4MukN5LqEVgSTTCjGULbmAWWw5Kpgkb)M92QhFKU2WHdXUSXMO5Kpgkb)M92QhFKU2G)iXOAlftbVS3CkXbtkHDT4bbieAT9bzLvpOUh8L6BEi0ABBYGMvemMpeATTNvw11oiIGelGyhTAV5HqRTTjdAwrWy(qO12Ewzvx7GicsSlBSjA7npeATTnzqZkcgZhcT22ZkR6AherqILn8eW4vxRminyyRCXYgEcy8QBziLYzUyzdpbmELB1qqnfGMsz3YmqsPCM)HZTFjqUvdb1GaVdhGzGHsWtDxPeu(l1yE)uK)HZTFjqzD4ixPeu)JeJQTGfuQyi7npeATTnzqZ(sTpeATTNvw11oiIGixRxlb1vN6ALbrkLZCYhdLGFZEB1JpsxBWLaEZdHwBBtg0SVu7dHwB7zLvDTdIiiY16bUlR6uxRminyyRCYhdLGFZEB1JpsxB4wgXUSXMO5Kpgkb)M92QhFKU2G)iXOAlyNszzV5HqRTTjdA2xQ9HqRT9SYQU2bre0sYkf)qRTDTYGiLYzoWIXI3VzF(xRYLa6wdg2kFjzLIFO1238qO122Kbn7l1(qO12Ewzvx7GicAjzLIFO12EG7YQo11kdsdg2kFjzLIFO12Uf7YgBIMdSyS49B2N)1Q8hjgvBb7ukFZdHwBBtg0SVu7dHwB7zLvDTdIiOyrxRmOqOfGOhBKyHwka5YnpeATTnzqZkcgZhcT22ZkR6Aherqwn6r8JB(nNsCqaILs(GaKRgAT9npeATTLhlc6rI7BrgAT(evR4FZdHwBB5XIjdA2uwiQG5JbGrlqxRminyyR88Vw1kKxjG38qO12wESyYGMn)Rv9w9lQrxfYlyOxJpfvlOPUwzqIDzJnrZFK4(wKHwRpr1k(8hjgvBblixa3PIHBnyyR80qjGF1PERUpXBEi0ABlpwmzqZsytWQo1tYcR6ALbrkLZ8ViICjG38qO12wESyYGMDjzLIFOORvg0adLGp6HFGIqEUwcQRo1Tybe7OvExPeuFoq3Ks5mFGHsW6hsi3QHGAkay38qO12wESyYGMn)RvTc5vcORvgePuoZPUySQt9edbHQr(JHqDldygyOe8rp8dueYZ1sqD1PUflGyhTY7kLG6Zb6WbyelGyhTY7kLG6Zbk7npeATTLhlMmOztzHOcMpgagTaDTYGEPUeEGBc85dmxIsbRmtbFYAWWw5VuxcFOk2sHwBdULJS38qO12wESyYGMn)Rv9w9lQrxfYlyOxJpfvlOPUwzqVuxcpWnb(8bMlrPGvMPGpznyyR8xQlHpufBPqRTb3Yr2BEi0ABlpwmzqZM)1QwH8kb01kdcmdmuc(Oh(bkc55AjOU6u3IfqSJw5DLsq95aD4amIfqSJw5DLsq95aV5HqRTT8yXKbn7sYkf)qrxfYlyOxJpfvlOPUwzqVuxcpWnb(8bMlrPuiJlGpznyyR8xQlHpufBPqRTb3Yr2BEi0ABlpwmzqZMYcrfmFmamAbEZdHwBB5XIjdA28Vw1B1VOgDviVGHEn(uuTGMEZdHwBB5XIjdAwc73(n7tuTI)npeATTLhlMmOzJxen619FS1B(nNsCWzEmuchCZhKU6XhPRnoiWDzvNEWF1qRTpOCpOvJxThCkLThKeZ7JhCML(GL9GbGrXcsgEZdHwBB5KR1dCxw1PGiSjyvN6jzHvDTYGiLYz(xerUeWBEi0ABlNCTEG7YQonzqZ(iX9TidTwFIQv8DTYGcHwaIESrIfAPaKloC8snY1Ii611dEWckvmClJgmSvEAOeWV6uVv3NOdhIThsLYraXp)RvD44LAmVFkYjlT6uVyzdzV5uIdorJpfvFLbrmCMCLzGKs5m)dNB)sGCRgcQtEQSoFqMbskLZ8pCU9lbYFKyuTn5PYcUhyOe8u3vkbL)snM3pf5F4C7xcCYbbirGyO2dghKTQRhuju2dw2dwTI9ahhu3dQXNI6bvc4bjuPeqREqGFTFPYFqSrIYFWeLs4GrFWGSyLk)bvcHEWefJDWaiqM8h8dNB)sGhSYh8LAmVFko4h0jcHEqsS60dg9bXgjk)btukHds5dA1qqT11dU)bJ(GyJeL)GkHqpOsap4ajLY5dMOySdA3Tpi6mG1JhCB(npeATTLtUwpWDzvNMmOzxswP4hk6QqEbd9A8POAbn11kd6L6s4bUjWNpWCjkLcqUa(BEi0ABlNCTEG7YQonzqZMYcrfmFmamAb6ALb9sDj8a3e4ZhyUeLcwxOSBlqKX8A8POA5PSqubZhdaJwGuaYf3IDzJnrZbwmw8(n7Z)Av(JeJQTua(BEi0ABlNCTEG7YQonzqZM)1QER(f1ORc5fm0RXNIQf0uxRmOxQlHh4MaF(aZLOuW6cLDl2Ln2enhyXyX73Sp)Rv5psmQ2sb4V5HqRTTCY16bUlR60KbnB(xRAfYReqxRmisPCMtDXyvN6jgccvJ8hdH6(L6s4bUjWNpWCjkLczMc(K1GHTYFPUe(qvSLcT2gClhzDBbImMxJpfvlp)RvTc5vcifGCXTmKs5mFGHsW6hsi3QHGAqamhoaZadLGp6HFGIqEUwcQRo1HdWiwaXoAL3vkb1Ndu2BEi0ABlNCTEG7YQonzqZM)1QwH8kb01kd6L6s4bUjWNpWCjkLcqYihWNSgmSv(l1LWhQITuO12GB5iRBlqKX8A8POA55FTQviVsaPaKlULHukN5dmucw)qc5wneudcG5WbygyOe8rp8dueYZ1sqD1PoCagXci2rR8UsjO(CGYEZdHwBB5KR1dCxw1PjdA2LKvk(HIUkKxWqVgFkQwqtDTYGEPUeEGBc85dmxIsPaKmYb8jRbdBL)sDj8HQylfATn4woYEZdHwBB5KR1dCxw1PjdA2uwiQG5JbGrlqxRmiXUSXMO5alglE)M95FTk)rIr1wkEPg5Are966bh3VuxcpWnb(8bMlrPGfCOSBlqKX8A8POA5PSqubZhdaJwGuaYLBEi0ABlNCTEG7YQonzqZM)1QER(f1ORc5fm0RXNIQf0uxRmiXUSXMO5alglE)M95FTk)rIr1wkEPg5Are966bh3VuxcpWnb(8bMlrPGfCO8n)Mtjo4mpgkHdU5dsx94J01gheGqOfG4bbixn0A7BEi0ABlNCTETeuxDkOLKvk(HIUkKxWqVgFkQwqtDTYGEPUeEGBc85dmxIsPaeaLY38qO12wo5A9AjOU60Kbn7Je33Im0A9jQwX31kdsdg2kpnuc4xDQ3Q7t0HdX2dPs5iG4N)1QoC8snM3pf5KLwDQxSSHdhHqlarp2iXcTuaYLBEi0ABlNCTETeuxDAYGMLWMGvDQNKfw11kdIukN5Fre5saDlZl1LWdCtGpFG5sukybp4D44LAKRfr0RRxoGfuQy4WHfiYyEn(uuTCcBcw1PEswyvka5IS38qO12wo5A9AjOU60Kbn7sYkf)qrxfYlyOxJpfvlOPUwzqVuJCTiIED9GdytfdhoEPUeEGBc85dmxIsPae4a(BEi0ABlNCTETeuxDAYGMn)RvTc5vcORvgePuoZPUySQt9edbHQrUeq3wGiJ514tr1YZ)AvRqELasbixCldygyOe8rp8dueYZ1sqD1PUflGyhTY7kLG6Zb6WbyelGyhTY7kLG6Zbk7npeATTLtUwVwcQRonzqZsy)2VzFIQv8DTYGEPUeEGBc85dmxIsPae4qz3VuJCTiIED9YHIuX4MhcT22YjxRxlb1vNMmOzZ)AvRqELa6ALbzbImMxJpfvlp)RvTc5vcifGCXTmKs5mFGHsW6hsi3QHGAqamhoaZadLGp6HFGIqEUwcQRo1HdWiwaXoAL3vkb1Ndu2BEi0ABlNCTETeuxDAYGMDjzLIFOORc5fm0RXNIQf0uxRmOxQlHh4MaF(aZLOukCb8UFPgPqo38qO12wo5A9AjOU60KbnlHnbR6upjlSQRvgePuoZ)IiYLaEZdHwBB5KR1RLG6Qttg0SXlIg96(p2QRvg0l1LWdCtGpFG5sukfGNY38BoL4GjDzJd68ngVEWKU9O0AB7npeATTLlw2WtaJxbjievB9B2xc01kdkxPeu)JeJQTGnvmU5uId68Pfp4q6Ro9GaClgl(dMOuch05jqraC2zEmuc38qO12wUyzdpbmEnzqZkievB9B2xc01kdcmAWWw5ljRu8dT22nPuoZbwmw8(n7Z)Av(JeJQTGvoUjLYzoWIXI3VzF(xRYLa6MukN5ILn8eW4vUvdb1uaAkLV5uIdcWlP2AGhCZheGBXyXFqjlgP4btukHd68eOiao7mpgkHBEi0ABlxSSHNagVMmOzfeIQT(n7lb6ALbbgnyyR8LKvk(HwB7EGHsWtDxPeu(l1yE)uKNdgdBV4LSXaF3GHukN5alglE)M95FTkxcOBziLYzUyzdpbmELB1qqnfGMcqDtkLZCPMWYK3B1h7uLaxcOdhKs5mxSSHNagVYTAiOMcqtP0Uf7YgBIMdSyS49B2N)1Q8hjgvBPykLL9MhcT22YflB4jGXRjdAwbHOARFZ(sGUwzqGrdg2kFjzLIFO12UbZadLGN6UsjO8xQX8(Piphmg2EXlzJb(UjLYzUyzdpbmELB1qqnfGMsz3GHukN5alglE)M95FTkxcOBXUSXMO5alglE)M95FTk)rIr1wkCHY3CkXbb4(iGyRhmPlBCqNVX41dUaIViacS60doK(QtpiWIXI)MhcT22YflB4jGXRjdAwbHOARFZ(sGUwzqAWWw5ljRu8dT22nyiLYzoWIXI3VzF(xRYLa6wgsPCMlw2WtaJx5wneutbOPau3Ks5mxQjSm59w9XovjWLa6WbPuoZflB4jGXRCRgcQPa0ukTdhIDzJnrZbwmw8(n7Z)Av(JeJQTGvoUjLYzUyzdpbmELB1qqnfGMcoYEZV5uIdcW3h05tlEqNNIeTUEqaURwBFWOhheGmevWS38qO12wUyx2yt0wqsw0xks06ALbj2Ln2enhyXyX73Sp)Rv5pgd5D4qSlBSjAoWIXI3VzF(xRYFKyuTLcxO8npeATTLl2Ln2eTnzqZcC1ABxRmisPCMdSyS49B2N)1QCjGUjLYzose4MaF)l1Opbga3Mlb8MhcT22Yf7YgBI2MmOzjz7o8zPxExRmisPCMdSyS49B2N)1QCjGUjLYzose4MaF)l1Opbga3Mlb8MhcT22Yf7YgBI2MmOzjX3Ip1vN6ALbrkLZCGfJfVFZ(8VwLlb8MhcT22Yf7YgBI2MmOzJxen6bkXSORvgKmGHukN5alglE)M95FTkxcO7qOfGOhBKyHwka5ISoCagsPCMdSyS49B2N)1QCjGUL5LAKpWCjkLcqG39l1LWdCtGpFG5sukfGaOuw2BEi0ABlxSlBSjABYGMLvPeuR35lPrkrSvxRmisPCMdSyS49B2N)1QCjG38qO12wUyx2yt02KbnB0c0QFW8IGXCTYGiLYzoWIXI3VzF(xRYLa6MukN5irGBc89VuJ(eyaCBUeWBEi0ABlxSlBSjABYGMnxpsY2D4ALbrkLZCGfJfVFZ(8VwL)iXOAlybbWCtkLZCKiWnb((xQrFcmaUnxc4npeATTLl2Ln2eTnzqZsgP(n71VeuBDTYGiLYzoWIXI3VzF(xRYLa6oeAbi6XgjwOf0u3YqkLZCGfJfVFZ(8VwL)iXOAlybVBnyyRCXYgEcy8kh7GKHdhoaJgmSvUyzdpbmELJDqYWHBsPCMdSyS49B2N)1Q8hjgvBbRCK9Mtjoys3Ln2eT9MhcT22Yf7YgBI2MmOzrIa3e47FPg9jWa42UwzqAWWw5ljRu8dT22TmIDzJnrZbwmw8(n7Z)Av(JXqE3VuJCTiIED9GNIuXW9l1LWdCtGpFG5sukfGMszhoiLYzoWIXI3VzF(xRYLa6(LAKRfr0RRh8uKkgY6WrUsjO(hjgvBbRlu(MhcT22Yf7YgBI2MmOzrIa3e47FPg9jWa42UwzqAWWw5Kpgkb)M92QhFKU2W9l1LWdCtGpFG5sukfGdLD)snY1Ii611dEksfd3YqkLZCYhdLGFZEB1JpsxBWLa6WrUsjO(hjgvBbRluw2BEi0ABlxSlBSjABYGMfjcCtGV)LA0NadGB7ALbPbdBLxcueaD)sncw5CZdHwBB5IDzJnrBtg0SalglE)M95FTQRvgKgmSvo5JHsWVzVT6XhPRnClJyx2yt0CYhdLGFZEB1JpsxBWFKyuT1HdXUSXMO5Kpgkb)M92QhFKU2G)ymK39l1LWdCtGpFG5sukybOuw2BEi0ABlxSlBSjABYGMfyXyX73Sp)RvDTYG0GHTYlbkcGUbdPuoZbwmw8(n7Z)AvUeWBEi0ABlxSlBSjABYGMfyXyX73Sp)RvDTYG0GHTYxswP4hATTBz0GHTYtdLa(vN6T6(e5yhKmC4MukN5psCFlYqR1NOAfFUeqhoaJgmSvEAOeWV6uVv3Nih7GKHdzV5HqRTTCXUSXMOTjdAwYhdLGFZEB1JpsxB4ALbrkLZCGfJfVFZ(8VwLlb8MhcT22Yf7YgBI2MmOzZ)A1eY)eT(S0lVRvgePuoZbwmw8(n7Z)Av(JeJQTGnvmCtkLZCGfJfVFZ(8VwLlb0ny0GHTYxswP4hAT9npeATTLl2Ln2eTnzqZM)1QjK)jA9zPxExRmOqOfGOhBKyHwka5IBziLYzoWIXI3VzF(xRYLa6MukN5alglE)M95FTk)rIr1wWMkgoC8rn8iGyR8ymSC0zLvTU)OgEeqSvEmgw(JeJQTGnvmC4ixPeu)JeJQTGnvmK9MhcT22Yf7YgBI2MmOzZ)A1eY)eT(S0lVRvgKgmSv(sYkf)qRTDdgsPCMdSyS49B2N)1QCjGULrgsPCMl1ewM8ER(yNQe4saD4amdmucEQ7kLGYFPgZ7NI8CWyy7fVKng4lRBzgiPuoZ)W52Vei3QHGAqG3HdWmWqj4PURuck)LAmVFkY)W52VeOSYEZdHwBB5IDzJnrBtg0SeKh4QeWNyj8aF0ITaDTYG0GHTYjFmuc(n7Tvp(iDTH7xQlHh4MaF(aZLOukahk7(LAKcqYXnPuoZbwmw8(n7Z)AvUeqhoaJgmSvo5JHsWVzVT6XhPRnC)sDj8a3e4ZhyUeLsbixa)npeATTLl2Ln2eTnzqZ(rzr)aJHRvgePuoZbwmw8(n7Z)AvUeWBEi0ABlxSlBSjABYGM1gIVYLOcMhyiuxRmOqOfGOhBKyHwka5IBzaIkpLWkX4psmQ2c2uXWHdn(uu5Are966hfc2uXq2BEi0ABlxSlBSjABYGMDGHsWh9WpqriVRvgui0cq0JnsSqlfG3HJxQX8(Pihibm(L42O9MFZPehmPlGyhTEqacYIvAH2BEi0ABlxSaID0Qf0adLG1pKqxRmOpQHhbeBLhJHLxnftbVdhG5JA4raXw5Xyy5OZkRAD4ieAbi6XgjwOLcqUCZdHwBB5IfqSJwTjdAwBI4jwDQNyzvxRmOqOfGOhBKyHwqtD)sDj8a3e4ZhyUeLsHCCl2Ln2enhyXyX73Sp)Rv5psmQ2cw54gmAWWw5Kpgkb)M92QhFKU2WTmG5JA4raXw5Xyy5OZkRAD44JA4raXw5Xyy5vtXuWl7npeATTLlwaXoA1MmOzTjINy1PEILvDTYGcHwaIESrIfAPaKlUbJgmSvo5JHsWVzVT6XhPRnU5HqRTTCXci2rR2KbnRnr8eRo1tSSQRvgKgmSvo5JHsWVzVT6XhPRnCldPuoZjFmuc(n7Tvp(iDTbxcOBzcHwaIESrIfAbn19l1LWdCtGpFG5sukfGdLD4ieAbi6XgjwOLcqU4(L6s4bUjWNpWCjkLcakLL1HdWqkLZCYhdLGFZEB1JpsxBWLa6wSlBSjAo5JHsWVzVT6XhPRn4psmQ2k7npeATTLlwaXoA1MmOzdYLy1HwB7zfrsxRmOqOfGOhBKyHwqtDl2Ln2enhyXyX73Sp)Rv5psmQ2cw54wgW8rn8iGyR8ymSC0zLvToC8rn8iGyR8ymS8QPyk4L9MhcT22YflGyhTAtg0Sb5sS6qRT9SIiPRvgui0cq0JnsSqlfGC5MhcT22YflGyhTAtg0SwcHGAg6vcOxQtSVsqExRmOqOfGOhBKyHwqtDl2Ln2enhyXyX73Sp)Rv5psmQ2cw54wgW8rn8iGyR8ymSC0zLvToC8rn8iGyR8ymS8QPyk4L9MhcT22YflGyhTAtg0SwcHGAg6vcOxQtSVsqExRmOqOfGOhBKyHwka5Yn)MtjoiapjRu8dT2(G)QHwBFZdHwBB5ljRu8dT2g0Je33Im0A9jQwX31kdkeAbi6XgjwOLcqYXTmAWWw5PHsa)Qt9wDFIoCi2Eivkhbe)8Vw1HJxQX8(PiNS0Qt9ILnK9MhcT22YxswP4hATDYGMLWMGvDQNKfw11kdcmJv55FTQpJaIpxlb1vN6gmKs5mN6IXQo1tmeeQg5saV5HqRTT8LKvk(HwBNmOzZ)AvRqELa6ALbrkLZCQlgR6upXqqOAK)yiu3wGiJ514tr1YZ)AvRqELasbixCldPuoZhyOeS(HeYTAiOgeaZHdWmWqj4JE4hOiKNRLG6QtD4amIfqSJw5DLsq95aL9MhcT22YxswP4hATDYGMDjzLIFOORc5fm0RXNIQf0uxRmisPCMtDXyvN6jgccvJ8hdH6WbyiLYz(xerUeq3wGiJ514tr1YjSjyvN6jzHvPaKCU5HqRTT8LKvk(HwBNmOztzHOcMpgagTaDTYGSargZRXNIQLNYcrfmFmamAbsbixClZl1LWdCtGpFG5sukyNszhoEPg5Are966DHIuXqwhoKzGKs5m)dNB)sGCRgcQbl4D4yGKs5m)dNB)sG8hjgvBb7uWl7npeATTLVKSsXp0A7KbnB(xR6T6xuJUwzqIThsLYXpgLi0Qt9KSnHBsPCMJFmkrOvN6jzBcUvdb1GCXDi0cq0JnsSqlOP38qO12w(sYkf)qRTtg0Se2eSQt9KSWQUwzqKs5m)lIixcOBlqKX8A8POA5e2eSQt9KSWQuaYLBEi0ABlFjzLIFO12jdA2uwiQG5JbGrlqxRmilqKX8A8POA5PSqubZhdaJwGuaYLBEi0ABlFjzLIFO12jdA28Vw1B1VOgDviVGHEn(uuTGM6ALbbgnyyR8aWGfTGa6gmKs5mN6IXQo1tmeeQg5saD4qdg2kpamyrliGUbdPuoZ)IiYLaEZdHwBB5ljRu8dT2ozqZsytWQo1tYcR6ALbrkLZ8ViICjG38qO12w(sYkf)qRTtg0SljRu8dfDviVGHEn(uuTGMEZV5uIdcWDxw1PheGZ(heGNKvk(HwBl3dsRXR2doLYh0IITh2dsI59XdcWTyS4p4MpiaNFT6bflr0EWnNpysD(DZdHwBB5ljRu8dT22dCxw1PGEK4(wKHwRpr1k(UwzqAWWw5PHsa)Qt9wDFIoCi2Eivkhbe)8Vw1HJxQX8(PiNS0Qt9ILnC4ieAbi6XgjwOLcqUCZdHwBB5ljRu8dT22dCxw1PjdAwcBcw1PEswyvxRmisPCM)frKlb8MhcT22YxswP4hATTh4USQttg0SljRu8dfDviVGHEn(uuTGM6ALbrkLZCQlgR6upXqqOAK)yi0BEi0ABlFjzLIFO12EG7YQonzqZMYcrfmFmamAb6ALbzbImMxJpfvlpLfIky(yay0cKcqU4(L6s4bUjWNpWCjkfSaukFZdHwBB5ljRu8dT22dCxw1PjdA28Vw1B1VOgDviVGHEn(uuTGM6ALb9sDj8a3e4ZhyUeLcwWfLV5HqRTT8LKvk(HwB7bUlR60Kbn7sYkf)qrxfYlyOxJpfvlOPUwzqVuJuao38qO12w(sYkf)qRT9a3LvDAYGMn)RvTc5vcORvgui0cq0JnsSqlfGah3YaMbgkbF0d)afH8CTeuxDQBXci2rR8UsjO(CGoCagXci2rR8UsjO(CGYEZV5uIdsRrpIFCqB1Pm05JA8POEWF1qRTV5HqRTTCRg9i(bOhjUVfzO16tuTIVRvgKgmSvEAOeWV6uVv3NOdhIThsLYraXp)RvD44LAmVFkYjlT6uVyzJBEi0ABl3QrpIFKmOztzHOcMpgagTaDTYGaZadLGN6UsjO8xQX8(Pi)dNB)sGULzGKs5m)dNB)sGCRgcQbl4D4yGKs5m)dNB)sG8hjgvBbl4s2BEi0ABl3QrpIFKmOzZ)AvVv)IA01kdsSlBSjA(Je33Im0A9jQwXN)iXOAlyb5c4ovmCRbdBLNgkb8Ro1B19jEZdHwBB5wn6r8JKbnB(xR6T6xuJUwzqIThsLYXpgLi0Qt9KSnHBsPCMJFmkrOvN6jzBcUvdb1GCXHdX2dPs5snddlbC4Zp2oN8UjLYzUuZWWsah(8JTZjp)rIr1wWkh3Ks5mxQzyyjGdF(X25KNlb8MhcT22YTA0J4hjdAwcBcw1PEswyvxRmisPCM)frKlb8MhcT22YTA0J4hjdA2LKvk(HIUwzqGHukN55FDoS9aLywKlb0TgmSvE(xNdBpqjMfD4GukN5uxmw1PEIHGq1i)XqOoCmWqj4JE4hOiKNRLG6QtDlwaXoAL3vkb1Nd0nPuoZhyOeS(HeYTAiOMcaMdhVuJCTiIED9GdybLkg38qO12wUvJEe)izqZM)1QER(f1ORvg0l1LWdCtGpFG5sukyLzk4twdg2k)L6s4dvXwk0ABWTCK9MhcT22YTA0J4hjdA2LKvk(HIUwzqVuxcpWnb(8bMlrPuiJlGpznyyR8xQlHpufBPqRTb3Yr2BEi0ABl3QrpIFKmOzZ)AvVv)IA8MhcT22YTA0J4hjdAwc73(n7tuTI)npeATTLB1OhXpsg0SXlIg96(p2QrnQXa]] )

end
