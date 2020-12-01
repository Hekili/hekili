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


    spec:RegisterPack( "Frost DK", 20201201, [[d4ud8bqiGIhbuQUesHc2Kc8jj0OqQ6uivwfsbELe0SOs6waukAxO6xkKggsrhtbTmQGNrkX0ak5AavTnaQ8nKczCaLY5OcvTosjnpGk3di7Ju4GuHkluH4HsGMiaLQlcqv2isHQpIuqnsakfojafwPc1lbOuAMsa7eP0pbOKHIuO0sbOONIKPsk1vrkuOVIuqglazVu8xQAWGoSWIr0JjzYk6YqBwsFwIgncoTOvJuOOxtLy2OCBeA3s9BLgoGooav1Yv1ZP00jUoPA7a47uPgpviNNu06PcL5tfTFv2m0OTHAgcAO1bA6anh6anhYhQfWpulgkrtGOHcyOCjkrdvherdfn(Vw5Ga2bS1qbm0KTX0OTHYU6VcnueebOvRJoAzke0j5QL4O2KOolKCB1hvzuBsunQHIupzcGrBinuZqqdToqthO5qhO5q(qTa(HoqJmuHUqyFdfvsSGgkc5CITH0qnrRYqb2piGDmecheW2oljihKg)xRCJb7heWoQqIK4FWHUEqhOPd08gFJb7hKIqmx3SON2dsVJNttUd0zOyPvSgTnuljlf8dj32dCxw2LgTn0o0OTHc7GKHtZigk1Nc(zyOKGHTWldHa(zx6TY(e5yhKmCEqNopOA7PEkCea8R)Afo2bjdNh0PZd(6nw3Ve5KPKDPxTSjh7GKHZd605bdLKaGESrIjApOgGoOdgQqj52gQhjUVfzO16DNTGVrm06GrBdf2bjdNMrmuQpf8ZWqrQxR8pjICDGgQqj52gkcRBw2LEswyfJyOvlgTnuyhKmCAgXqfkj32qTKSuWpe0qP(uWpddfPETYDjzSSl9edfHSr(JHsmuknvm0lXxII1q7qJyOfSmABOWoiz40mIHs9PGFggklqKX8s8LOy5LSqLbZhtaIwHhudqh0Hdo4GVENkpW1n(8jwtvkheCheWrtdvOKCBdvjluzW8XeGOvOrm0cEJ2gkSdsgonJyOcLKBBOQ)AfVv(0f0qP(uWpdd1R3PYdCDJpFI1uLYbb3bPr00qP0uXqVeFjkwdTdnIHwaNrBdf2bjdNMrmuHsYTnuljlf8dbnuQpf8ZWq96nEqnoiyzOuAQyOxIVefRH2HgXqlnYOTHc7GKHtZigk1Nc(zyOcLKaGESrIjApOgGoiyDWbhK(dcMdoXqi4JE6NOk0KlPYLSlp4GdQwaWoAH3zjbXxd8GoDEqWCq1ca2rl8olji(AGhKodvOKCBdv9xRyvAkeqJyedLAztpbmEXOTH2HgTnuyhKmCAgXqP(uWpddvnlji(hjgzBpi4oyPAEqNopiPETYbMmw8(T6R)Af(JeJSTheChulhCWbj1RvUAztpbmEHBLq5YbbDqhO5bhCqWCqjyyl8LKLc(HKBZXoiz40qfkj32qPiezB9B1Nk0igADWOTHc7GKHtZigk1Nc(zyOKGHTWxswk4hsUnh7GKHZdo4GG5GK61khyYyX73QV(Rv46ap4Gds)bj1RvUAztpbmEHBLq5Yb1a0bhc4o4GdsQxRC9MWY00BLh7sHaxh4bD68GK61kxTSPNagVWTsOC5GAa6GdD8h0PZdQ2Lnx3nhyYyX73QV(Rv4psmY2EqWDqTCWbhKuVw5QLn9eW4fUvcLlhudqhCiyDq6muHsYTnukcr2w)w9PcnIrmuljlf8dj32OTH2HgTnuyhKmCAgXqP(uWpddvOKea0Jnsmr7b1a0b1YbhCq6pOemSfEzieWp7sVv2Nih7GKHZd605bvBp1tHJaGF9xRWXoiz48GoDEWxVX6(LiNmLSl9QLn5yhKmCEq6muHsYTnupsCFlYqR17oBbFJyO1bJ2gkSdsgonJyOuFk4NHHcmhCUcV(Rv8vea85sQCj7Ydo4GG5GK61k3LKXYU0tmueYg56anuHsYTnuew3SSl9KSWkgXqRwmABOWoiz40mIHs9PGFggks9AL7sYyzx6jgkczJ8hdLCWbh0cezmVeFjkwE9xRyvAkeWdQbOd6WbhCq6piPETYNyieS(PoYTsOC5GGoiy7GoDEqWCWjgcbF0t)evHMCjvUKD5bD68GG5GQfaSJw4Dwsq81apiDgQqj52gQ6VwXQ0uiGgXqlyz02qHDqYWPzedvOKCBd1sYsb)qqdL6tb)mmuK61k3LKXYU0tmueYg5pgk5GoDEqWCqs9AL)jrKRd8GdoOfiYyEj(suSCcRBw2LEswyLdQbOdQfdLstfd9s8LOyn0o0igAbVrBdf2bjdNMrmuQpf8ZWqzbImMxIVeflVKfQmy(ycq0k8GAa6GoCWbhK(d(6DQ8ax34ZNynvPCqWDWH08GoDEWxVrUKerVSEhoOghSunpiDh0PZds)bNiPETY)WX2pvi3kHYLdcUdc(d605bNiPETY)WX2pvi)rIr22dcUdoe8hKodvOKCBdvjluzW8XeGOvOrm0c4mABOWoiz40mIHs9PGFggk12t9u44hZufs2LEs26MJDqYW5bhCqs9ALJFmtvizx6jzRBUvcLlhe0bD4GdoyOKea0Jnsmr7bbDWHgQqj52gQ6VwXBLpDbnIHwAKrBdf2bjdNMrmuQpf8ZWqrQxR8pjICDGhCWbTargZlXxIILtyDZYU0tYcRCqnaDqhmuHsYTnuew3SSl9KSWkgXqlyZOTHc7GKHtZigk1Nc(zyOSargZlXxIILxYcvgmFmbiAfEqnaDqhmuHsYTnuLSqLbZhtaIwHgXqRJ3OTHc7GKHtZigQqj52gQ6VwXBLpDbnuQpf8ZWqbMdkbdBHhaeSOveqo2bjdNhCWbbZbj1RvUljJLDPNyOiKnY1bEqNopOemSfEaqWIwra5yhKmCEWbhemhKuVw5Fse56anuknvm0lXxII1q7qJyODinnABOWoiz40mIHs9PGFggks9AL)jrKRd0qfkj32qryDZYU0tYcRyedTdhA02qHDqYWPzedvOKCBd1sYsb)qqdLstfd9s8LOyn0o0igXqzLONXpnABODOrBdf2bjdNMrmuQpf8ZWqjbdBHxgcb8ZU0BL9jYXoiz48GoDEq12t9u4ia4x)1kCSdsgopOtNh81BSUFjYjtj7sVAzto2bjdNgQqj52gQhjUVfzO16DNTGVrm06GrBdf2bjdNMrmuQpf8ZWqbMdoXqi4DPZscc)1BSUFjY)WX2pv4bhCq6p4ej1Rv(ho2(Pc5wjuUCqWDqWFqNop4ej1Rv(ho2(Pc5psmY2EqWDqA0bPZqfkj32qvYcvgmFmbiAfAedTAXOTHc7GKHtZigk1Nc(zyOu7YMR7M)iX9TidTwV7Sf85psmY2EqWb6GoCqAWblvZdo4GsWWw4LHqa)Sl9wzFICSdsgonuHsYTnu1FTI3kF6cAedTGLrBdf2bjdNMrmuQpf8ZWqP2EQNch)yMQqYU0tYw3CSdsgop4GdsQxRC8JzQcj7spjBDZTsOC5GGoOdh0PZdQ2EQNcxVzyyjGtF9X2X0KJDqYW5bhCqs9ALR3mmSeWPV(y7yAYFKyKT9GG7GA5GdoiPETY1Bggwc40xFSDmn56anuHsYTnu1FTI3kF6cAedTG3OTHc7GKHtZigk1Nc(zyOi1Rv(NerUoqdvOKCBdfH1nl7spjlSIrm0c4mABOWoiz40mIHs9PGFggkWCqs9ALx)1XW2duNzrUoWdo4GsWWw41FDmS9a1zwKJDqYWPHkusUTHAjzPGFiOrm0sJmABOWoiz40mIHs9PGFggQxVtLh46gF(eRPkLdcUds)bhc(dw4bLGHTWF9ov(qeS1dj3MJDqYW5bPbhulhKodvOKCBdv9xR4TYNUGgXqlyZOTHc7GKHtZigk1Nc(zyOE9ovEGRB85tSMQuoOghK(d6a4pyHhucg2c)17u5drWwpKCBo2bjdNhKgCqTCq6muHsYTnuljlf8dbnIHwhVrBdvOKCBdv9xR4TYNUGgkSdsgonJyedTdPPrBdvOKCBdfH9B)w9UZwW3qHDqYWPzeJyOD4qJ2gQqj52gQ4vrJEz)hBXqHDqYWPzeJyedLAx2CD3wJ2gAhA02qHDqYWPzedL6tb)mmuQDzZ1DZbMmw8(T6R)Af(JXuZd605bv7YMR7MdmzS49B1x)1k8hjgzBpOgh0bAAOcLKBBO0TOpfKO1igADWOTHc7GKHtZigk1Nc(zyOi1RvoWKXI3VvF9xRW1bEWbhKuVw5irGRB89VEJE3yaCBUoqdvOKCBdfWvYTnIHwTy02qHDqYWPzedL6tb)mmuK61khyYyX73QV(Rv46ap4GdsQxRCKiW1n((xVrVBmaUnxhOHkusUTHIKT70x1FnnIHwWYOTHc7GKHtZigk1Nc(zyOi1RvoWKXI3VvF9xRW1bAOcLKBBOiX3IVlzxAedTG3OTHc7GKHtZigk1Nc(zyOO)GG5GK61khyYyX73QV(Rv46ap4Gdgkjba9yJet0EqnaDqhoiDh0PZdcMdsQxRCGjJfVFR(6VwHRd8Gdoi9h81BKpXAQs5GAa6GG)Gdo4R3PYdCDJpFI1uLYb1a0bbC08G0zOcLKBBOIxfn6bQZSOrm0c4mABOWoiz40mIHs9PGFggks9ALdmzS49B1x)1kCDGgQqj52gkwwsqSEAm1NLeXwmIHwAKrBdf2bjdNMrmuQpf8ZWqrQxRCGjJfVFR(6VwHRd8GdoiPETYrIax347F9g9UXa42CDGgQqj52gQOvOv(G5vbJzedTGnJ2gkSdsgonJyOuFk4NHHIuVw5atglE)w91FTc)rIr22dcoqheSDWbhKuVw5irGRB89VEJE3yaCBUoqdvOKCBdvnFKKT70igAD8gTnuyhKmCAgXqP(uWpddfPETYbMmw8(T6R)AfUoWdo4GHssaqp2iXeThe0bhEWbhK(dsQxRCGjJfVFR(6VwH)iXiB7bb3bb)bhCqjyylC1YMEcy8ch7GKHZd605bbZbLGHTWvlB6jGXlCSdsgop4GdsQxRCGjJfVFR(6VwH)iXiB7bb3b1YbPZqfkj32qrgL(T6LpvUynIH2H00OTHc7GKHtZigk1Nc(zyOKGHTWxswk4hsUnh7GKHZdo4G0Fq1US56U5atglE)w91FTc)XyQ5bhCWxVrUKerVSEWFqnoyPAEWbh817u5bUUXNpXAQs5GAa6GdP5bD68GK61khyYyX73QV(Rv46ap4Gd(6nYLKi6L1d(dQXblvZds3bD68G1SKG4FKyKT9GG7GoqtdvOKCBdfse46gF)R3O3nga32igAho0OTHc7GKHtZigk1Nc(zyOKGHTWjFmec(T6Tzp)OCTbh7GKHZdo4GVENkpW1n(8jwtvkhuJdcw08Gdo4R3ixsIOxwp4pOghSunp4Gds)bj1Rvo5JHqWVvVn75hLRn46apOtNhSMLee)JeJSTheCh0bAEq6muHsYTnuirGRB89VEJE3yaCBJyODOdgTnuyhKmCAgXqP(uWpddLemSfEQqvaKJDqYW5bhCWxVXdcUdQfdvOKCBdfse46gF)R3O3nga32igAhQfJ2gkSdsgonJyOuFk4NHHscg2cN8Xqi43Q3M98JY1gCSdsgop4Gds)bv7YMR7Mt(yie8B1BZE(r5Ad(JeJSTh0PZdQ2Lnx3nN8Xqi43Q3M98JY1g8hJPMhCWbF9ovEGRB85tSMQuoi4oiGJMhKodvOKCBdfWKXI3VvF9xRyedTdblJ2gkSdsgonJyOuFk4NHHscg2cpvOkaYXoiz48GdoiyoiPETYbMmw8(T6R)AfUoqdvOKCBdfWKXI3VvF9xRyedTdbVrBdf2bjdNMrmuQpf8ZWqjbdBHVKSuWpKCBo2bjdNhCWbP)GsWWw4LHqa)Sl9wzFICSdsgop4GdsQxR8hjUVfzO16DNTGpxh4bD68GG5GsWWw4LHqa)Sl9wzFICSdsgopiDgQqj52gkGjJfVFR(6VwXigAhc4mABOWoiz40mIHs9PGFggks9ALdmzS49B1x)1kCDGgQqj52gkYhdHGFREB2ZpkxByedTdPrgTnuyhKmCAgXqP(uWpddfPETYbMmw8(T6R)Af(JeJSTheChSunp4GdsQxRCGjJfVFR(6VwHRd8GdoiyoOemSf(sYsb)qYT5yhKmCAOcLKBBOQ)Af3A(eT(Q(RPrm0oeSz02qHDqYWPzedL6tb)mmuHssaqp2iXeThudqh0Hdo4G0Fqs9ALdmzS49B1x)1kCDGhCWbj1RvoWKXI3VvF9xRWFKyKT9GG7GLQ5bD68GFKtpca2cpMtlhDuAf7bhCWpYPhbaBHhZPL)iXiB7bb3blvZd605bRzjbX)iXiB7bb3blvZdsNHkusUTHQ(RvCR5t06R6VMgXq7qhVrBdf2bjdNMrmuQpf8ZWqjbdBHVKSuWpKCBo2bjdNhCWbbZbj1RvoWKXI3VvF9xRW1bEWbhK(ds)bj1RvUEtyzA6TYJDPqGRd8GoDEqWCWjgcbVlDwsq4VEJ19lrEnymS9Qx3gt8piDhCWbP)GtKuVw5F4y7NkKBLq5YbbDqWFqNopiyo4edHG3Lolji8xVX6(Li)dhB)uHhKUdsNHkusUTHQ(RvCR5t06R6VMgXqRd00OTHc7GKHtZigk1Nc(zyOKGHTWjFmec(T6Tzp)OCTbh7GKHZdo4GVENkpW1n(8jwtvkhuJdcw08Gdo4R34b1a0b1YbhCqs9ALdmzS49B1x)1kCDGh0PZdcMdkbdBHt(yie8B1BZE(r5Ado2bjdNhCWbF9ovEGRB85tSMQuoOgGoOdG3qfkj32qrqtGRqaFIPYd8rl2k0igADyOrBdf2bjdNMrmuQpf8ZWqrQxRCGjJfVFR(6VwHRd0qfkj32q9rAr)eJPrm06GdgTnuyhKmCAgXqP(uWpddvOKea0Jnsmr7b14GG)GoDEWxVX6(Lihibm(L42OLJDqYWPHkusUTHAIHqWh90prvOPrmIHsTaGD0I1OTH2HgTnuyhKmCAgXqP(uWpdd1h50JaGTWJ50YZ(GACWHG)GoDEqWCWpYPhbaBHhZPLJokTI9GoDEWqjjaOhBKyI2dQbOd6GHkusUTHAIHqW6N6Orm06GrBdf2bjdNMrmuQpf8ZWqfkjba9yJet0EqqhC4bhCWxVtLh46gF(eRPkLdQXb1YbhCq1US56U5atglE)w91FTc)rIr22dcUdQLdo4GG5GsWWw4Kpgcb)w92SNFuU2GJDqYW5bhCq6piyo4h50JaGTWJ50YrhLwXEqNop4h50JaGTWJ50YZ(GACWHG)G0zOcLKBBOSUJNy2LEIPvmIHwTy02qHDqYWPzedL6tb)mmuHssaqp2iXeThudqh0Hdo4GG5GsWWw4Kpgcb)w92SNFuU2GJDqYWPHkusUTHY6oEIzx6jMwXigAblJ2gkSdsgonJyOuFk4NHHscg2cN8Xqi43Q3M98JY1gCSdsgop4Gds)bj1Rvo5JHqWVvVn75hLRn46ap4Gds)bdLKaGESrIjApiOdo8Gdo4R3PYdCDJpFI1uLYb14GGfnpOtNhmusca6XgjMO9GAa6GoCWbh817u5bUUXNpXAQs5GACqahnpiDh0PZdcMdsQxRCYhdHGFREB2ZpkxBW1bEWbhuTlBUUBo5JHqWVvVn75hLRn4psmY2Eq6muHsYTnuw3Xtm7spX0kgXql4nABOWoiz40mIHs9PGFggQqjjaOhBKyI2dc6Gdp4GdQ2Lnx3nhyYyX73QV(Rv4psmY2EqWDqTCWbhK(dcMd(ro9iayl8yoTC0rPvSh0PZd(ro9iayl8yoT8SpOghCi4piDgQqj52gQGCjMDi52EwsK0igAbCgTnuyhKmCAgXqP(uWpddvOKea0Jnsmr7b1a0bDWqfkj32qfKlXSdj32ZsIKgXqlnYOTHc7GKHtZigk1Nc(zyOcLKaGESrIjApiOdo8GdoOAx2CD3CGjJfVFR(6VwH)iXiB7bb3b1YbhCq6piyo4h50JaGTWJ50YrhLwXEqNop4h50JaGTWJ50YZ(GACWHG)G0zOcLKBBOSecLlm0leqVE7EFHGMgXqlyZOTHc7GKHtZigk1Nc(zyOcLKaGESrIjApOgGoOdgQqj52gklHq5cd9cb0R3U3xiOPrmIHc4JQLizigTnIHkw0OTH2HgTnuHsYTnupsCFlYqR17oBbFdf2bjdNMrmIHwhmABOWoiz40mIHs9PGFggkjyyl86VwXQ0uiGCSdsgonuHsYTnuLSqLbZhtaIwHgXqRwmABOWoiz40mIHkusUTHQ(Rv8w5txqdL6tb)mmuQDzZ1DZFK4(wKHwR3D2c(8hjgzBpi4aDqhoin4GLQ5bhCqjyyl8YqiGF2LERSpro2bjdNgkLMkg6L4lrXAODOrm0cwgTnuyhKmCAgXqP(uWpddfPETY)KiY1bAOcLKBBOiSUzzx6jzHvmIHwWB02qHDqYWPzedL6tb)mmuK61k3LKXYU0tmueYg5pgk5Gdoi9hemhCIHqWh90prvOjxsLlzxEWbhuTaGD0cVZscIVg4bD68GG5GQfaSJw4Dwsq81apiDgQqj52gQ6VwXQ0uiGgXqlGZOTHc7GKHtZigk1Nc(zyOE9ovEGRB85tSMQuoi4oi9hCi4pyHhucg2c)17u5drWwpKCBo2bjdNhKgCqTCq6muHsYTnuLSqLbZhtaIwHgXqlnYOTHc7GKHtZigQqj52gQ6VwXBLpDbnuQpf8ZWq96DQ8ax34ZNynvPCqWDq6p4qWFWcpOemSf(R3PYhIGTEi52CSdsgopin4GA5G0zOuAQyOxIVefRH2HgXqlyZOTHkusUTH6rI7BrgATE3zl4BOWoiz40mIrm064nABOWoiz40mIHs9PGFggkWCWjgcbF0t)evHMCjvUKD5bhCq1ca2rl8olji(AGh0PZdcMdQwaWoAH3zjbXxd0qfkj32qv)1kwLMcb0igAhstJ2gkSdsgonJyOcLKBBOwswk4hcAOuFk4NHH617u5bUUXNpXAQs5GACq6pOdG)GfEqjyyl8xVtLpebB9qYT5yhKmCEqAWb1YbPZqP0uXqVeFjkwdTdnIH2HdnABOcLKBBOkzHkdMpMaeTcnuyhKmCAgXigAh6GrBdf2bjdNMrmuHsYTnu1FTI3kF6cAOuAQyOxIVefRH2HgXq7qTy02qfkj32qry)2VvV7Sf8nuyhKmCAgXigAhcwgTnuHsYTnuXRIg9Y(p2IHc7GKHtZigXigQjwdDMy02q7qJ2gQqj52gkIzp91hrhdnuyhKmCAgXigADWOTHc7GKHtZigk1Nc(zyOaZbNRWR)AfFfbaFUKkxYU8Gdoi9hucg2cpvOkaYXoiz48GoDEq1US56U5Kpgcb)w92SNFuU2G)iXiB7b14Gdb)bD68GsWWw4ljlf8dj3MJDqYW5bhCq1US56U5atglE)w91FTc)rIr22dcUdoxHx)1k(kca(8hjgzBpiDgQqj52gkcRBw2LEswyfJyOvlgTnuyhKmCAgXqP(uWpddfPETYtLMEjyBB5psmY2EqWb6GLQ5bhCqs9ALNkn9sW22Y1bEWbh0cezmVeFjkwEjluzW8XeGOv4b1a0bD4Gdoi9hemhucg2cN8Xqi43Q3M98JY1gCSdsgopOtNhuTlBUUBo5JHqWVvVn75hLRn4psmY2Eqno4qWFq6muHsYTnuLSqLbZhtaIwHgXqlyz02qHDqYWPzedL6tb)mmuK61kpvA6LGTTL)iXiB7bbhOdwQMhCWbj1RvEQ00lbBBlxh4bhCq6piyoOemSfo5JHqWVvVn75hLRn4yhKmCEqNopOAx2CD3CYhdHGFREB2ZpkxBWFKyKT9GACWHG)G0zOcLKBBOQ)AfVv(0f0igAbVrBdf2bjdNMrmuHsYTnuQGX8HsYT9S0kgkwAfFherdLAba7OfRrm0c4mABOWoiz40mIHkusUTHsfmMpusUTNLwXqXsR47GiAOu7YMR72AedT0iJ2gkSdsgonJyOcLKBBOubJ5dLKB7zPvmuS0k(oiIgk0AXwHwJyOfSz02qHDqYWPzedL6tb)mmusWWw4QLn9eW4fo2bjdNhCWbP)GK61kxTSPNagVWTsOC5GAa6GdP5bhCq6p4ej1Rv(ho2(Pc5wjuUCqqhe8h0PZdcMdoXqi4DPZscc)1BSUFjY)WX2pv4bP7GoDEWAwsq8psmY2EqWb6GLQ5bPZqfkj32qPcgZhkj32ZsRyOyPv8DqenuQLn9eW4fJyO1XB02qHDqYWPzedL6tb)mmuK61kN8Xqi43Q3M98JY1gCDGgQqj52gQxV9HsYT9S0kgkwAfFherdf5A9sQCj7sJyODinnABOWoiz40mIHs9PGFggkjyylCYhdHGFREB2ZpkxBWXoiz48Gdoi9huTlBUUBo5JHqWVvVn75hLRn4psmY2EqWDWH08G0zOcLKBBOE92hkj32ZsRyOyPv8DqenuKR1dCxw2LgXq7WHgTnuyhKmCAgXqP(uWpddfPETYbMmw8(T6R)AfUoWdo4GsWWw4ljlf8dj3MJDqYWPHkusUTH61BFOKCBplTIHILwX3br0qTKSuWpKCBJyODOdgTnuyhKmCAgXqP(uWpddvOKea0Jnsmr7b1a0bDWqfkj32q96TpusUTNLwXqXsR47GiAOIfnIH2HAXOTHc7GKHtZigQqj52gkvWy(qj52EwAfdflTIVdIOHYkrpJFAeJyOixRxsLlzxA02q7qJ2gkSdsgonJyOcLKBBOwswk4hcAOuFk4NHH617u5bUUX)GGd0bblAAOuAQyOxIVefRH2HgXqRdgTnuyhKmCAgXqP(uWpddLemSfEzieWp7sVv2Nih7GKHZd605bvBp1tHJaGF9xRWXoiz48GoDEWxVX6(LiNmLSl9QLn5yhKmCEqNopyOKea0Jnsmr7b1a0bDWqfkj32q9iX9TidTwV7Sf8nIHwTy02qHDqYWPzedL6tb)mmuK61k)tIixhOHkusUTHIW6MLDPNKfwXigAblJ2gkSdsgonJyOcLKBBOwswk4hcAOuFk4NHH61BKljr0lRhSoi4oyPAEqNop4R3PYdCDJ)bbhOdcwG3qP0uXqVeFjkwdTdnIHwWB02qHDqYWPzedL6tb)mmuK61k3LKXYU0tmueYg56ap4GdAbImMxIVeflV(RvSknfc4b1a0bD4Gdoi9hemhCIHqWh90prvOjxsLlzxEWbhuTaGD0cVZscIVg4bD68GG5GQfaSJw4Dwsq81apiDgQqj52gQ6VwXQ0uiGgXqlGZOTHc7GKHtZigk1Nc(zyOE9ovEGRB85tSMQuoOgGoiyrZdo4GVEJCjjIEz9A5GACWs10qfkj32qry)2VvV7Sf8nIHwAKrBdf2bjdNMrmuQpf8ZWqzbImMxIVeflV(RvSknfc4b1a0bD4Gdoi9hKuVw5tmecw)uh5wjuUCqqheSDqNopiyo4edHGp6PFIQqtUKkxYU8GoDEqWCq1ca2rl8olji(AGhKodvOKCBdv9xRyvAkeqJyOfSz02qHDqYWPzedvOKCBd1sYsb)qqdL6tb)mmuVENkpW1n(8jwtvkhuJd6a4pOtNh81B8GACqTyOuAQyOxIVefRH2HgXqRJ3OTHc7GKHtZigk1Nc(zyOE9ovEGRB85tSMQuoOghe800qfkj32qfVkA0l7)ylgXigkY16bUll7sJ2gAhA02qHDqYWPzedL6tb)mmuK61k)tIixhOHkusUTHIW6MLDPNKfwXigADWOTHc7GKHtZigk1Nc(zyOcLKaGESrIjApOgGoOdh0PZd(6nYLKi6L1d(dcoqhSunp4Gds)bLGHTWldHa(zx6TY(e5yhKmCEqNopOA7PEkCea8R)Afo2bjdNh0PZd(6nw3Ve5KPKDPxTSjh7GKHZdsNHkusUTH6rI7BrgATE3zl4BedTAXOTHc7GKHtZigQqj52gQLKLc(HGgk1Nc(zyOE9ovEGRB85tSMQuoOgGoOdG3qP0uXqVeFjkwdTdnIHwWYOTHc7GKHtZigk1Nc(zyOE9ovEGRB85tSMQuoi4oOd08GdoOfiYyEj(suS8swOYG5JjarRWdQbOd6WbhCq1US56U5atglE)w91FTc)rIr22dQXbbVHkusUTHQKfQmy(ycq0k0igAbVrBdf2bjdNMrmuHsYTnu1FTI3kF6cAOuFk4NHH617u5bUUXNpXAQs5GG7GoqZdo4GQDzZ1DZbMmw8(T6R)Af(JeJSThuJdcEdLstfd9s8LOyn0o0igAbCgTnuyhKmCAgXqP(uWpddfPETYDjzSSl9edfHSr(JHso4Gd(6DQ8ax34ZNynvPCqnoi9hCi4pyHhucg2c)17u5drWwpKCBo2bjdNhKgCqTCq6o4GdAbImMxIVeflV(RvSknfc4b1a0bD4Gdoi9hKuVw5tmecw)uh5wjuUCqqheSDqNopiyo4edHGp6PFIQqtUKkxYU8GoDEqWCq1ca2rl8olji(AGhKodvOKCBdv9xRyvAkeqJyOLgz02qHDqYWPzedL6tb)mmuVENkpW1n(8jwtvkhudqhK(dQfWFWcpOemSf(R3PYhIGTEi52CSdsgopin4GA5G0DWbh0cezmVeFjkwE9xRyvAkeWdQbOd6WbhCq6piPETYNyieS(PoYTsOC5GGoiy7GoDEqWCWjgcbF0t)evHMCjvUKD5bD68GG5GQfaSJw4Dwsq81apiDgQqj52gQ6VwXQ0uiGgXqlyZOTHc7GKHtZigQqj52gQLKLc(HGgk1Nc(zyOE9ovEGRB85tSMQuoOgGoi9hulG)GfEqjyyl8xVtLpebB9qYT5yhKmCEqAWb1YbPZqP0uXqVeFjkwdTdnIHwhVrBdf2bjdNMrmuQpf8ZWqP2Lnx3nhyYyX73QV(Rv4psmY2Eqno4R3ixsIOxwpyDWbh817u5bUUXNpXAQs5GG7GGfnp4GdAbImMxIVeflVKfQmy(ycq0k8GAa6GoyOcLKBBOkzHkdMpMaeTcnIH2H00OTHc7GKHtZigQqj52gQ6VwXBLpDbnuQpf8ZWqP2Lnx3nhyYyX73QV(Rv4psmY2Eqno4R3ixsIOxwpyDWbh817u5bUUXNpXAQs5GG7GGfnnuknvm0lXxII1q7qJyeJyOaaFBUTHwhOPd0C4qhaldL747SlTgkAihhGjTag0sdR1dEqTjGhmjcCF5G19pyXLKLc(HKB7bUll7YIh8raF98X5bTlr8GHUSedbNhuri6s0YVXfiB8Gd16bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8G0p0r0XVXfiB8Gd16bl42aGVGZdw81BSUFjYbuXdk7bl(6nw3Ve5aIJDqYWzXds)qhrh)gxGSXdouRhSGBda(copyr12t9u4aQ4bL9GfvBp1tHdio2bjdNfpi9dDeD8B8nMgYXbyslGbT0WA9GhuBc4btIa3xoyD)dwuTSPNagVu8Gpc4RNpopODjIhm0LLyi48GkcrxIw(nUazJhCOwpyb3ga8fCEWIsWWw4aQ4bL9GfLGHTWbeh7GKHZIhmKdc4byvGds)qhrh)gxGSXd6Gwpyb3ga8fCEWIsWWw4aQ4bL9GfLGHTWbeh7GKHZIhK(HoIo(n(gtd54amPfWGwAyTEWdQnb8GjrG7lhSU)blUKSuWpKC7Ih8raF98X5bTlr8GHUSedbNhuri6s0YVXfiB8Gd16bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8G0p0r0XVXfiB8Gd16bl42aGVGZdw81BSUFjYbuXdk7bl(6nw3Ve5aIJDqYWzXds)qhrh)gxGSXdouRhSGBda(copyr12t9u4aQ4bL9GfvBp1tHdio2bjdNfpi9dDeD8BCbYgpiGtRhSGBda(copyr12t9u4aQ4bL9GfvBp1tHdio2bjdNfpi9dDeD8BCbYgpOJxRhSGBda(copyrjyylCav8GYEWIsWWw4aIJDqYWzXdsVdoIo(n(gtd54amPfWGwAyTEWdQnb8GjrG7lhSU)blsUwVKkxYUS4bFeWxpFCEq7sepyOllXqW5bveIUeT8BCbYgpOdA9GfCBaWxW5blkbdBHdOIhu2dwucg2chqCSdsgolEq6h6i6434cKnEqh06bl42aGVGZdw81BSUFjYbuXdk7bl(6nw3Ve5aIJDqYWzXds)qhrh)gxGSXd6Gwpyb3ga8fCEWIQTN6PWbuXdk7blQ2EQNchqCSdsgolEq6h6i6434BmnKJdWKwadAPH16bpO2eWdMebUVCW6(hSOvIEg)S4bFeWxpFCEq7sepyOllXqW5bveIUeT8BCbYgp4qTEWcUna4l48GfLGHTWbuXdk7blkbdBHdio2bjdNfpi9dDeD8BCbYgp4qTEWcUna4l48GfF9gR7xICav8GYEWIVEJ19lroG4yhKmCw8GHCqapaRcCq6h6i6434cKnEWHA9GfCBaWxW5blQ2EQNchqfpOShSOA7PEkCaXXoiz4S4bPFOJOJFJlq24b1Iwpyb3ga8fCEWIsWWw4aQ4bL9GfLGHTWbeh7GKHZIhmKdc4byvGds)qhrh)gxGSXdcwA9GfCBaWxW5blQ2EQNchqfpOShSOA7PEkCaXXoiz4S4bP3bhrh)gxGSXdc406bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8GHCqapaRcCq6h6i6434cKnEqAKwpyb3ga8fCEWIsWWw4aQ4bL9GfLGHTWbeh7GKHZIhK(HoIo(nUazJheSP1dwWTbaFbNhSOemSfoGkEqzpyrjyylCaXXoiz4S4bPFOJOJFJVX0qooatAbmOLgwRh8GAtapyse4(YbR7FWIKR1dCxw2Lfp4Ja(65JZdAxI4bdDzjgcopOIq0LOLFJlq24bDqRhSGBda(copyrjyylCav8GYEWIsWWw4aIJDqYWzXds)qhrh)gxGSXd6Gwpyb3ga8fCEWIVEJ19lroGkEqzpyXxVX6(LihqCSdsgolEq6h6i6434cKnEqh06bl42aGVGZdwuT9upfoGkEqzpyr12t9u4aIJDqYWzXds)qhrh)gxGSXdc406bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8G0p0r0XVXfiB8G0iTEWcUna4l48GfLGHTWbuXdk7blkbdBHdio2bjdNfpi9dDeD8BCbYgpiytRhSGBda(copyrjyylCav8GYEWIsWWw4aIJDqYWzXds)qhrh)gFJPHCCaM0cyqlnSwp4b1MaEWKiW9Ldw3)Gfv7YMR72w8Gpc4RNpopODjIhm0LLyi48GkcrxIw(nUazJhCin16bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8G0p0r0XVXfiB8GdhQ1dwWTbaFbNhSOemSfoGkEqzpyrjyylCaXXoiz4S4bPFOJOJFJlq24bh6Gwpyb3ga8fCEWIsWWw4aQ4bL9GfLGHTWbeh7GKHZIhK(HoIo(nUazJhCOw06bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8G0p0r0XVXfiB8GdblTEWcUna4l48GfLGHTWbuXdk7blkbdBHdio2bjdNfpi9dDeD8BCbYgp4qWR1dwWTbaFbNhSOemSfoGkEqzpyrjyylCaXXoiz4S4bPFOJOJFJlq24bhsJ06bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8GHCqapaRcCq6h6i6434cKnEWHoETEWcUna4l48GfLGHTWbuXdk7blkbdBHdio2bjdNfpi9dDeD8BCbYgpOd0uRhSGBda(copyrjyylCav8GYEWIsWWw4aIJDqYWzXdsVdoIo(nUazJh0bh06bl42aGVGZdw81BSUFjYbuXdk7bl(6nw3Ve5aIJDqYWzXdgYbb8aSkWbPFOJOJFJVX0qooatAbmOLgwRh8GAtapyse4(YbR7FWIQfaSJwSfp4Ja(65JZdAxI4bdDzjgcopOIq0LOLFJlq24bDqRhSGBda(copyrjyylCav8GYEWIsWWw4aIJDqYWzXds)qhrh)gxGSXdQfTEWcUna4l48GfLGHTWbuXdk7blkbdBHdio2bjdNfpyiheWdWQahK(HoIo(nUazJheS06bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8G0p0r0XVX3yAihhGjTag0sdR1dEqTjGhmjcCF5G19pyXjwdDMu8Gpc4RNpopODjIhm0LLyi48GkcrxIw(nUazJh0bTEWcUna4l48GfLGHTWbuXdk7blkbdBHdio2bjdNfpi9o4i6434cKnEqTO1dwWTbaFbNhSOemSfoGkEqzpyrjyylCaXXoiz4S4bPFOJOJFJlq24bblTEWcUna4l48GfLGHTWbuXdk7blkbdBHdio2bjdNfpi9dDeD8BCbYgpiytRhSGBda(copyrjyylCav8GYEWIsWWw4aIJDqYWzXds)qhrh)gxGSXdoKMA9GfCBaWxW5blkbdBHdOIhu2dwucg2chqCSdsgolEq6h6i6434cKnEWHd16bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8GHCqapaRcCq6h6i6434BmnKJdWKwadAPH16bpO2eWdMebUVCW6(hSySyXd(iGVE(48G2LiEWqxwIHGZdQieDjA534cKnEqh06bl42aGVGZdwucg2chqfpOShSOemSfoG4yhKmCw8GHCqapaRcCq6h6i6434cKnEqTO1dwWTbaFbNhSOemSfoGkEqzpyrjyylCaXXoiz4S4bd5GaEawf4G0p0r0XVXfiB8GaoTEWcUna4l48GfLGHTWbuXdk7blkbdBHdio2bjdNfpi9dDeD8BCbYgpinsRhSGBda(copyrjyylCav8GYEWIsWWw4aIJDqYWzXds)qhrh)gxGSXdoKMA9GfCBaWxW5blkbdBHdOIhu2dwucg2chqCSdsgolEq6h6i6434BmGbrG7l48GdP5bdLKBFqwAfl)gBOa(BnzOHcSFqa7yieoiGTDwsqoin(Vw5gd2piGDuHejX)GdD9GoqthO5n(gd2pifHyUUzrpThKEhpNMChO7gFJb7heWZrOsxW5braWxZdkjr8Gcb8GHs2)GP9GbarYcsgYVXHsYTTGiM90xFeDm8gd2pOJdiqMMhKg)xRCqACea8py0ZdsmYwISpiGHsZdQDW22EJdLKBBle0Oew3SSl9KSWkUMvqGzUcV(Rv8vea85sQCj7Yb0lbdBHNkufaD6uTlBUUBo5JHqWVvVn75hLRn4psmY2QXqW70PemSf(sYsb)qYThO2Lnx3nhyYyX73QV(Rv4psmY2cU5k86VwXxraWN)iXiBlD34qj522cbnAjluzW8XeGOvORzfePETYtLMEjyBB5psmY2coqLQ5as9ALNkn9sW22Y1boWcezmVeFjkwEjluzW8XeGOvOgGCya9Grcg2cN8Xqi43Q3M98JY1goDQ2Lnx3nN8Xqi43Q3M98JY1g8hjgzB1yi4P7ghkj32wiOrR)AfVv(0f01ScIuVw5PstVeSTT8hjgzBbhOs1CaPETYtLMEjyBB56ahqpyKGHTWjFmec(T6Tzp)OCTHtNQDzZ1DZjFmec(T6Tzp)OCTb)rIr2wngcE6UXG9dwqc7AXd64usU9bzPvoOSh817BCOKCBBHGgvfmMpusUTNLwX1oiIGulayhTyVXHsYTTfcAuvWy(qj52EwAfx7GicsTlBUUB7nousUTTqqJQcgZhkj32ZsR4AherqO1ITcT34qj522cbnQkymFOKCBplTIRDqebPw20taJxCnRGKGHTWvlB6jGXldONuVw5QLn9eW4fUvcLlAaAinhq)ej1Rv(ho2(Pc5wjuUac8oDcMjgcbVlDwsq4VEJ19lr(ho2(PcPZPZAwsq8psmY2coqLQjD34qj522cbn6R3(qj52EwAfx7GicICTEjvUKDPRzfePETYjFmec(T6Tzp)OCTbxh4nousUTTqqJ(6TpusUTNLwX1oiIGixRh4USSlDnRGKGHTWjFmec(T6Tzp)OCTXa6v7YMR7Mt(yie8B1BZE(r5Ad(JeJSTGBinP7ghkj32wiOrF92hkj32ZsR4Aherqljlf8dj321ScIuVw5atglE)w91FTcxh4ajyyl8LKLc(HKBFJdLKBBle0OVE7dLKB7zPvCTdIiOyrxZkOqjjaOhBKyIwna5WnousUTTqqJQcgZhkj32ZsR4Aherqwj6z8ZB8ngSFqh3c4DqaZvcj3(ghkj32YJfb9iX9TidTwV7Sf8VXHsYTT8yXcbnAjluzW8XeGOvORzfKemSfE9xRyvAkeWBCOKCBlpwSqqJw)1kER8PlORknvm0lXxIIf0qxZki1US56U5psCFlYqR17oBbF(JeJSTGdKd0Gs1CGemSfEzieWp7sVv2N4nousUTLhlwiOrjSUzzx6jzHvCnRGi1Rv(NerUoWBCOKCBlpwSqqJw)1kwLMcb01ScIuVw5UKmw2LEIHIq2i)XqjdOhmtmec(ON(jQcn5sQCj7YbQfaSJw4Dwsq81aD6emQfaSJw4Dwsq81aP7ghkj32YJfle0OLSqLbZhtaIwHUMvqVENkpW1n(8jwtvkGJ(HGVqjyyl8xVtLpebB9qYTPbAHUBCOKCBlpwSqqJw)1kER8PlORknvm0lXxIIf0qxZkOxVtLh46gF(eRPkfWr)qWxOemSf(R3PYhIGTEi520aTq3nousUTLhlwiOrFK4(wKHwR3D2c(34qj52wESyHGgT(RvSknfcORzfeyMyie8rp9tufAYLu5s2LdulayhTW7SKG4Rb60jyulayhTW7SKG4RbEJdLKBB5XIfcA0LKLc(HGUQ0uXqVeFjkwqdDnRGE9ovEGRB85tSMQu0GEhaFHsWWw4VENkFic26HKBtd0cD34qj52wESyHGgTKfQmy(ycq0k8ghkj32YJfle0O1FTI3kF6c6Qstfd9s8LOybn8ghkj32YJfle0Oe2V9B17oBb)BCOKCBlpwSqqJgVkA0l7)yl34Bmy)GJ8yieo4wpiv2ZpkxBCqG7YYU8G)kHKBFqTEqReVyp4qAApijw3hp4il1bt7bdaIKfKm8ghkj32YjxRh4USSlbryDZYU0tYcR4AwbrQxR8pjICDG34qj52wo5A9a3LLDzHGg9rI7BrgATE3zl47Awbfkjba9yJet0QbihC681BKljr0lRh8GduPAoGEjyyl8YqiGF2LERSprNovBp1tHJaGF9xR405R3yD)sKtMs2LE1YM0DJb7hSOeFjk(ScIy4iTs)ej1Rv(ho2(Pc5wjuUu4q6OXa9tKuVw5F4y7NkK)iXiBBHdPJgmXqi4DPZscc)1BSUFjY)WX2pvyXdcyIaXqShmoiBfxpOqiThmThmBb7jopOShuIVeLdkeWdsiljGw5Ga)C)u08GyJe18GUtHWbJ(GbzYsrZdkec5GUtg7GbqGmnp4ho2(Pcpywp4R3yD)sCYpO2ec5GKy2Lhm6dInsuZd6ofchKMh0kHYfRRhC)dg9bXgjQ5bfcHCqHaEWjsQxRh0DYyh0UBFq0raZhp428BCOKCBlNCTEG7YYUSqqJUKSuWpe0vLMkg6L4lrXcAORzf0R3PYdCDJpFI1uLIgGCa834qj52wo5A9a3LLDzHGgTKfQmy(ycq0k01Sc617u5bUUXNpXAQsbCoqZbwGiJ5L4lrXYlzHkdMpMaeTc1aKddu7YMR7MdmzS49B1x)1k8hjgzB1a834qj52wo5A9a3LLDzHGgT(Rv8w5txqxvAQyOxIVeflOHUMvqVENkpW1n(8jwtvkGZbAoqTlBUUBoWKXI3VvF9xRWFKyKTvdWFJdLKBB5KR1dCxw2LfcA06VwXQ0uiGUMvqK61k3LKXYU0tmueYg5pgkzWR3PYdCDJpFI1uLIg0pe8fkbdBH)6DQ8HiyRhsUnnql0nWcezmVeFjkwE9xRyvAkeqna5Wa6j1Rv(edHG1p1rUvcLlGaBoDcMjgcbF0t)evHMCjvUKDPtNGrTaGD0cVZscIVgiD34qj52wo5A9a3LLDzHGgT(RvSknfcORzf0R3PYdCDJpFI1uLIgGOxlGVqjyyl8xVtLpebB9qYTPbAHUbwGiJ5L4lrXYR)AfRstHaQbihgqpPETYNyieS(PoYTsOCbeyZPtWmXqi4JE6NOk0KlPYLSlD6emQfaSJw4Dwsq81aP7ghkj32YjxRh4USSlle0Oljlf8dbDvPPIHEj(suSGg6Awb96DQ8ax34ZNynvPObi61c4lucg2c)17u5drWwpKCBAGwO7ghkj32YjxRh4USSlle0OLSqLbZhtaIwHUMvqQDzZ1DZbMmw8(T6R)Af(JeJSTA86nYLKi6L1dwdE9ovEGRB85tSMQuahyrZbwGiJ5L4lrXYlzHkdMpMaeTc1aKd34qj52wo5A9a3LLDzHGgT(Rv8w5txqxvAQyOxIVeflOHUMvqQDzZ1DZbMmw8(T6R)Af(JeJSTA86nYLKi6L1dwdE9ovEGRB85tSMQuahyrZB8ngSFWrEmechCRhKk75hLRnoOJtjja4bbmxjKC7BCOKCBlNCTEjvUKDjOLKLc(HGUQ0uXqVeFjkwqdDnRGE9ovEGRB8bhiWIM34qj52wo5A9sQCj7Ycbn6Je33Im0A9UZwW31Scscg2cVmec4NDP3k7t0Pt12t9u4ia4x)1koD(6nw3Ve5KPKDPxTSPtNHssaqp2iXeTAaYHBCOKCBlNCTEjvUKDzHGgLW6MLDPNKfwX1ScIuVw5Fse56aVXHsYTTCY16Lu5s2LfcA0LKLc(HGUQ0uXqVeFjkwqdDnRGE9g5sse9Y6blWvQMoD(6DQ8ax34doqGf4VXHsYTTCY16Lu5s2LfcA06VwXQ0uiGUMvqK61k3LKXYU0tmueYg56ahybImMxIVeflV(RvSknfcOgGCya9GzIHqWh90prvOjxsLlzxoqTaGD0cVZscIVgOtNGrTaGD0cVZscIVgiD34qj52wo5A9sQCj7YcbnkH9B)w9UZwW31Sc617u5bUUXNpXAQsrdqGfnh86nYLKi6L1RfnkvZBCOKCBlNCTEjvUKDzHGgT(RvSknfcORzfKfiYyEj(suS86VwXQ0uiGAaYHb0tQxR8jgcbRFQJCRekxab2C6emtmec(ON(jQcn5sQCj7sNobJAba7OfENLeeFnq6UXHsYTTCY16Lu5s2LfcA0LKLc(HGUQ0uXqVeFjkwqdDnRGE9ovEGRB85tSMQu0WbW705R3OgA5ghkj32YjxRxsLlzxwiOrJxfn6L9FSfxZkOxVtLh46gF(eRPkfnapnVX3yW(bl4YMheWgy8Ybl42ZuYTT34qj52wUAztpbmEbKIqKT1VvFQqxZkOAwsq8psmY2cUs10Pts9ALdmzS49B1x)1k8hjgzBbNwgqQxRC1YMEcy8c3kHYfqoqZbGrcg2cFjzPGFi523yW(bPX(iaylhSGlBEqaBGXlhCbaFvaey2LhCQ)zxEqGjJf)nousUTLRw20taJxke0Okcr2w)w9PcDnRGKGHTWxswk4hsU9aWqQxRCGjJfVFR(6VwHRdCa9K61kxTSPNagVWTsOCrdqdbCdi1RvUEtyzA6TYJDPqGRd0Pts9ALRw20taJx4wjuUObOHoENov7YMR7MdmzS49B1x)1k8hjgzBbNwgqQxRC1YMEcy8c3kHYfnaneSO7gFJb7heWQpingT4bbmeKO11dsJDLC7dg98GaMHkdM9ghkj32Yv7YMR72cs3I(uqIwxZki1US56U5atglE)w91FTc)XyQPtNQDzZ1DZbMmw8(T6R)Af(JeJSTA4anVXHsYTTC1US56UTfcAuGRKB7AwbrQxRCGjJfVFR(6VwHRdCaPETYrIax347F9g9UXa42CDG34qj52wUAx2CD32cbnkjB3PVQ)A6AwbrQxRCGjJfVFR(6VwHRdCaPETYrIax347F9g9UXa42CDG34qj52wUAx2CD32cbnkj(w8Dj7sxZkis9ALdmzS49B1x)1kCDG34qj52wUAx2CD32cbnA8QOrpqDMfDnRGOhmK61khyYyX73QV(Rv46ahekjba9yJet0QbihOZPtWqQxRCGjJfVFR(6VwHRdCa9VEJ8jwtvkAac8dE9ovEGRB85tSMQu0aeGJM0DJdLKBB5QDzZ1DBle0OSSKGy90yQpljIT4AwbrQxRCGjJfVFR(6VwHRd8ghkj32Yv7YMR72wiOrJwHw5dMxfmMRzfePETYbMmw8(T6R)AfUoWbK61khjcCDJV)1B07gdGBZ1bEJdLKBB5QDzZ1DBle0O18rs2UtxZkis9ALdmzS49B1x)1k8hjgzBbhiW2as9ALJebUUX3)6n6DJbWT56aVXHsYTTC1US56UTfcAuYO0VvV8PYfRRzfePETYbMmw8(T6R)AfUoWbHssaqp2iXeTGgoGEs9ALdmzS49B1x)1k8hjgzBbh4hibdBHRw20taJx4yhKmC60jyKGHTWvlB6jGXlCSdsgohqQxRCGjJfVFR(6VwH)iXiBl40cD3yW(bl4US56UT34qj52wUAx2CD32cbnkse46gF)R3O3nga321Scscg2cFjzPGFi52dOxTlBUUBoWKXI3VvF9xRWFmMAo41BKljr0lRh8AuQMdE9ovEGRB85tSMQu0a0qA60jPETYbMmw8(T6R)AfUoWbVEJCjjIEz9GxJs1KoNoRzjbX)iXiBl4CGM34qj52wUAx2CD32cbnkse46gF)R3O3nga321Scscg2cN8Xqi43Q3M98JY1gdE9ovEGRB85tSMQu0aSO5GxVrUKerVSEWRrPAoGEs9ALt(yie8B1BZE(r5AdUoqNoRzjbX)iXiBl4CGM0DJdLKBB5QDzZ1DBle0OirGRB89VEJE3yaCBxZkijyyl8uHQa4GxVrWPLBCOKCBlxTlBUUBBHGgfyYyX73QV(RvCnRGKGHTWjFmec(T6Tzp)OCTXa6v7YMR7Mt(yie8B1BZE(r5Ad(JeJSToDQ2Lnx3nN8Xqi43Q3M98JY1g8hJPMdE9ovEGRB85tSMQuahGJM0DJdLKBB5QDzZ1DBle0OatglE)w91FTIRzfKemSfEQqvaCayi1RvoWKXI3VvF9xRW1bEJdLKBB5QDzZ1DBle0OatglE)w91FTIRzfKemSf(sYsb)qYThqVemSfEzieWp7sVv2Nih7GKHZbK61k)rI7BrgATE3zl4Z1b60jyKGHTWldHa(zx6TY(e5yhKmCs3nousUTLR2Lnx3TTqqJs(yie8B1BZE(r5AdxZkis9ALdmzS49B1x)1kCDG34qj52wUAx2CD32cbnA9xR4wZNO1x1FnDnRGi1RvoWKXI3VvF9xRWFKyKTfCLQ5as9ALdmzS49B1x)1kCDGdaJemSf(sYsb)qYTVXHsYTTC1US56UTfcA06VwXTMprRVQ)A6Awbfkjba9yJet0QbihgqpPETYbMmw8(T6R)AfUoWbK61khyYyX73QV(Rv4psmY2cUs10PZpYPhbaBHhZPLJokTIDWh50JaGTWJ50YFKyKTfCLQPtN1SKG4FKyKTfCLQjD34qj52wUAx2CD32cbnA9xR4wZNO1x1FnDnRGKGHTWxswk4hsU9aWqQxRCGjJfVFR(6VwHRdCa90tQxRC9MWY00BLh7sHaxhOtNGzIHqW7sNLee(R3yD)sKxdgdBV61TXeF6gq)ej1Rv(ho2(Pc5wjuUac8oDcMjgcbVlDwsq4VEJ19lr(ho2(PcPJUBCOKCBlxTlBUUBBHGgLGMaxHa(etLh4JwSvORzfKemSfo5JHqWVvVn75hLRng86DQ8ax34ZNynvPObyrZbVEJAasldi1RvoWKXI3VvF9xRW1b60jyKGHTWjFmec(T6Tzp)OCTXGxVtLh46gF(eRPkfna5a4VXHsYTTC1US56UTfcA0psl6NymDnRGi1RvoWKXI3VvF9xRW1bEJdLKBB5QDzZ1DBle0Otmec(ON(jQcnDnRGcLKaGESrIjA1a8oD(6nw3Ve5ajGXVe3gT34Bmy)GfCba7OLd64itwkjAVXHsYTTC1ca2rlwqtmecw)uhDnRG(iNEeaSfEmNwE2Ame8oDcMpYPhbaBHhZPLJokTI1PZqjjaOhBKyIwna5WnousUTLRwaWoAXwiOrTUJNy2LEIPvCnRGcLKaGESrIjAbnCWR3PYdCDJpFI1uLIgAzGAx2CD3CGjJfVFR(6VwH)iXiBl40YaWibdBHt(yie8B1BZE(r5AJb0dMpYPhbaBHhZPLJokTI1PZpYPhbaBHhZPLNTgdbpD34qj52wUAba7OfBHGg16oEIzx6jMwX1Sckusca6XgjMOvdqomamsWWw4Kpgcb)w92SNFuU24ghkj32YvlayhTyle0Ow3Xtm7spX0kUMvqsWWw4Kpgcb)w92SNFuU2ya9K61kN8Xqi43Q3M98JY1gCDGdOpusca6XgjMOf0WbVENkpW1n(8jwtvkAaw00PZqjjaOhBKyIwna5WGxVtLh46gF(eRPkfnaC0KoNobdPETYjFmec(T6Tzp)OCTbxh4a1US56U5Kpgcb)w92SNFuU2G)iXiBlD34qj52wUAba7OfBHGgnixIzhsUTNLejDnRGcLKaGESrIjAbnCGAx2CD3CGjJfVFR(6VwH)iXiBl40Ya6bZh50JaGTWJ50YrhLwX605h50JaGTWJ50YZwJHGNUBCOKCBlxTaGD0ITqqJgKlXSdj32ZsIKUMvqHssaqp2iXeTAaYHBCOKCBlxTaGD0ITqqJAjekxyOxiGE929(cbnDnRGcLKaGESrIjAbnCGAx2CD3CGjJfVFR(6VwH)iXiBl40Ya6bZh50JaGTWJ50YrhLwX605h50JaGTWJ50YZwJHGNUBCOKCBlxTaGD0ITqqJAjekxyOxiGE929(cbnDnRGcLKaGESrIjA1aKd34Bmy)GawKSuWpKC7d(ResU9nousUTLVKSuWpKCBqpsCFlYqR17oBbFxZkOqjjaOhBKyIwnaPLb0lbdBHxgcb8ZU0BL9j60PA7PEkCea8R)AfNoF9gR7xICYuYU0Rw2KUBCOKCBlFjzPGFi52fcAucRBw2LEswyfxZkiWmxHx)1k(kca(CjvUKD5aWqQxRCxsgl7spXqriBKRd8ghkj32Yxswk4hsUDHGgT(RvSknfcORzfePETYDjzSSl9edfHSr(JHsgybImMxIVeflV(RvSknfcOgGCya9K61kFIHqW6N6i3kHYfqGnNobZedHGp6PFIQqtUKkxYU0PtWOwaWoAH3zjbXxdKUBCOKCBlFjzPGFi52fcA0LKLc(HGUQ0uXqVeFjkwqdDnRGi1RvUljJLDPNyOiKnYFmuItNGHuVw5Fse56ahybImMxIVeflNW6MLDPNKfwrdqA5ghkj32Yxswk4hsUDHGgTKfQmy(ycq0k01ScYcezmVeFjkwEjluzW8XeGOvOgGCya9VENkpW1n(8jwtvkGBinD681BKljr0lR3bnkvt6C6K(jsQxR8pCS9tfYTsOCbCG3PZjsQxR8pCS9tfYFKyKTfCdbpD34qj52w(sYsb)qYTle0O1FTI3kF6c6AwbP2EQNch)yMQqYU0tYw3di1Rvo(XmvHKDPNKTU5wjuUaYHbHssaqp2iXeTGgEJdLKBB5ljlf8dj3UqqJsyDZYU0tYcR4AwbrQxR8pjICDGdSargZlXxIILtyDZYU0tYcRObihUXHsYTT8LKLc(HKBxiOrlzHkdMpMaeTcDnRGSargZlXxIILxYcvgmFmbiAfQbihUXHsYTT8LKLc(HKBxiOrR)AfVv(0f0vLMkg6L4lrXcAORzfeyKGHTWdacw0kc4aWqQxRCxsgl7spXqriBKRd0Ptjyyl8aGGfTIaoamK61k)tIixh4nousUTLVKSuWpKC7cbnkH1nl7spjlSIRzfePETY)KiY1bEJdLKBB5ljlf8dj3UqqJUKSuWpe0vLMkg6L4lrXcA4n(gd2pin2DzzxEqA89piGfjlf8dj3wRhKsIxShCinpOfvBpThKeR7JhKgBYyXFWTEqA8FTYbvlr0EWTwpybbSFJdLKBB5ljlf8dj32dCxw2LGEK4(wKHwR3D2c(UMvqsWWw4LHqa)Sl9wzFIoDQ2EQNchba)6VwXPZxVX6(LiNmLSl9QLnD6musca6XgjMOvdqoCJdLKBB5ljlf8dj32dCxw2LfcAucRBw2LEswyfxZkis9AL)jrKRd8ghkj32Yxswk4hsUTh4USSlle0Oljlf8dbDvPPIHEj(suSGg6AwbrQxRCxsgl7spXqriBK)yOKBCOKCBlFjzPGFi52EG7YYUSqqJwYcvgmFmbiAf6AwbzbImMxIVeflVKfQmy(ycq0kudqom417u5bUUXNpXAQsbCaoAEJdLKBB5ljlf8dj32dCxw2LfcA06VwXBLpDbDvPPIHEj(suSGg6Awb96DQ8ax34ZNynvPaoAenVXHsYTT8LKLc(HKB7bUll7Ycbn6sYsb)qqxvAQyOxIVeflOHUMvqVEJAaw34qj52w(sYsb)qYT9a3LLDzHGgT(RvSknfcORzfuOKea0JnsmrRgGaRb0dMjgcbF0t)evHMCjvUKD5a1ca2rl8olji(AGoDcg1ca2rl8olji(AG0DJVXG9dsjrpJFEqB2LmeWMs8LOCWFLqYTVXHsYTTCRe9m(jOhjUVfzO16DNTGVRzfKemSfEzieWp7sVv2NOtNQTN6PWraWV(RvC681BSUFjYjtj7sVAzZBCOKCBl3krpJFwiOrlzHkdMpMaeTcDnRGaZedHG3Lolji8xVX6(Li)dhB)uHdOFIK61k)dhB)uHCRekxah4D6CIK61k)dhB)uH8hjgzBbhnIUBCOKCBl3krpJFwiOrR)AfVv(0f01ScsTlBUUB(Je33Im0A9UZwWN)iXiBl4a5anOunhibdBHxgcb8ZU0BL9jEJdLKBB5wj6z8ZcbnA9xR4TYNUGUMvqQTN6PWXpMPkKSl9KS19as9ALJFmtvizx6jzRBUvcLlGCWPt12t9u46nddlbC6Rp2oMMdi1RvUEZWWsaN(6JTJPj)rIr2wWPLbK61kxVzyyjGtF9X2X0KRd8ghkj32YTs0Z4NfcAucRBw2LEswyfxZkis9AL)jrKRd8ghkj32YTs0Z4NfcA0LKLc(HGUMvqGHuVw51FDmS9a1zwKRdCGemSfE9xhdBpqDMfVXHsYTTCRe9m(zHGgT(Rv8w5txqxZkOxVtLh46gF(eRPkfWr)qWxOemSf(R3PYhIGTEi520aTq3nousUTLBLONXple0Oljlf8dbDnRGE9ovEGRB85tSMQu0GEhaFHsWWw4VENkFic26HKBtd0cD34qj52wUvIEg)SqqJw)1kER8Pl4nousUTLBLONXple0Oe2V9B17oBb)BCOKCBl3krpJFwiOrJxfn6L9FSfdLfiQm06a4hAeJyma]] )

end
