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


    spec:RegisterPack( "Frost DK", 20201213, [[d4K2fcqieWJqqQlHefInrL6tkIrruCkIsRcbjVsc1SOs6wirH0Uq1VuKAyiroMIYYOs8mIkMgcIRHGABai9nKOY4aq5CurjRJOsZdb6EazFiHdcGWcvK8qjKMiaQ0frIs2iaQ4JirrJejQkDsQOuRur1lrIQQzkHyNij)eavnuKOGLcGONIutLkYvrIc1xrIsnwayVu8xQAWGoSWIr0JjmzfUm0ML0NLOrduNw0QrIQIxJKA2OCBeA3s9BLgoGoosuLLRQNtPPt66ez7a03LGXtfvNNOQ1tffZNkSFv2mZ4KHEekAOYfk5cLM5Ym5WNrjctjcXzzOv5bIgAGHG6Oen0Dqen0aC(1QheGlLFdnWqE2gdJtgA7k9c0qdwvGw5o90LPcwIKlwItBtIsSqZTfFu1PTjrX0gAsPKPo72qAOhHIgQCHsUqPzUmto8zuIWuIqKJHoKuW7BOPtIf1qdohdSnKg6bAfgAc9bb4IHc(Gu(7SeSEqao)A1BoH(GaCrbsKe)dotoUEqxOKluYqZsRAnozOxswQ4hAUTh4USSlnozOAMXjdn2bjdhMPm0Ipv8ZWqRbdBLxgky8ZU0B19jYXoiz44GoCCqX2dPu5iG4x)1QCSdsgooOdhh8LASUFjYjtn7sVyzdo2bjdhh0HJdgcnbe9yJet0EqkaDqxm0HqZTn0psCFlYqR1xiBfFJAOYfJtgASdsgomtzOfFQ4NHHMuQw5Fse5san0HqZTn0G3cSSl9KSWQg1qLCmozOXoiz4WmLHoeAUTHEjzPIFOOHw8PIFggAsPALtDYyzx6jgcWzJ8hdHAOfYlyOxJVevRHQzg1qfHyCYqJDqYWHzkdT4tf)mm0wGiJ514lr1YlzHidMpgagTapifGoOlh09bFPofEGBb85dSMIupibpiaLsg6qO52g6swiYG5JbGrlqJAOIWgNm0yhKmCyMYqhcn32qx)1QER(j1OHw8PIFgg6xQtHh4waF(aRPi1dsWds5OKHwiVGHEn(suTgQMzudvauJtgASdsgomtzOdHMBBOxswQ4hkAOfFQ4NHH(LA8GuCqcXqlKxWqVgFjQwdvZmQHkkNXjdn2bjdhMPm0Ipv8ZWqhcnbe9yJet0EqkaDqc5GUpOmhKahCGHc2h9Wpqripxtb1zxEq3huSaID0kVZsWQVg4bD44Ge4GIfqSJw5Dwcw91apOSg6qO52g66Vw1kKxbJg1OgAXYgEWy8QXjdvZmozOXoiz4WmLHw8PIFgg6Awcw9psmY2EqcEWsXWqhcn32qlahzB9B1Nc0OgQCX4KHg7GKHdZugAXNk(zyOjWb1GHTYxswQ4hAUnh7GKHJd6(GKs1khyYyX73QV(Rv5psmY2EqcEq5Cq3hKuQw5atglE)w91FTkxc4bDFqsPALlw2WdgJx5wneuFqkaDWzuYqhcn32qlahzB9B1Nc0OgQKJXjdn2bjdhMPm0Ipv8ZWqtGdQbdBLVKSuXp0CBo2bjdhh09bhyOG9u3zjyL)snw3Ve51GXW2lEjBmW)GUpOmhKuQw5ILn8GX4vUvdb1hKcqhCga9GUpiPuTYLAWltEVvFSlvWCjGh0HJdskvRCXYgEWy8k3QHG6dsbOdoZzDq3huSlBSfAoWKXI3VvF9xRYFKyKT9GuCWzu6GYAOdHMBBOfGJST(T6tbAudveIXjdn2bjdhMPm0Ipv8ZWqtGdQbdBLVKSuXp0CBo2bjdhh09bjWbhyOG9u3zjyL)snw3Ve51GXW2lEjBmW)GUpiPuTYflB4bJXRCRgcQpifGo4mkDq3hKuQw5atglE)w91FTkxc4bDFqXUSXwO5atglE)w91FTk)rIr22dsXbDHsg6qO52gAb4iBRFR(uGg1qfHnozOXoiz4WmLHw8PIFggAnyyR8LKLk(HMBZXoiz44GUpiboiPuTYbMmw8(T6R)AvUeWd6(GYCqsPALlw2WdgJx5wneuFqkaDWza0d6(GKs1kxQbVm59w9XUubZLaEqhooiPuTYflB4bJXRCRgcQpifGo4mN1bD44GIDzJTqZbMmw8(T6R)Av(JeJSThKGhuoh09bjLQvUyzdpymELB1qq9bPa0bNrihuwdDi0CBdTaCKT1VvFkqJAud9sYsf)qZTnozOAMXjdn2bjdhMPm0Ipv8ZWqhcnbe9yJet0EqkaDq5Cq3huMdQbdBLxgky8ZU0B19jYXoiz44GoCCqX2dPu5iG4x)1QCSdsgooOdhh8LASUFjYjtn7sVyzdo2bjdhhuwdDi0CBd9Je33Im0A9fYwX3OgQCX4KHg7GKHdZugAXNk(zyOjWbhRYR)AvFfbeFUMcQZU8GUpiboiPuTYPozSSl9edb4SrUeqdDi0CBdn4Tal7spjlSQrnujhJtgASdsgomtzOfFQ4NHHMuQw5uNmw2LEIHaC2i)XqOh09bTargZRXxIQLx)1QwH8ky8Gua6GUCq3huMdskvR8bgkyRFiHCRgcQpiOdcWoOdhhKahCGHc2h9Wpqripxtb1zxEqhooiboOybe7OvENLGvFnWdkRHoeAUTHU(RvTc5vWOrnurigNm0yhKmCyMYqhcn32qVKSuXpu0ql(uXpddnPuTYPozSSl9edb4Sr(JHqpOdhhKahKuQw5Fse5sapO7dAbImMxJVevlh8wGLDPNKfw9Gua6GYXqlKxWqVgFjQwdvZmQHkcBCYqJDqYWHzkdT4tf)mm0wGiJ514lr1YlzHidMpgagTapifGoOlh09bL5GVuNcpWTa(8bwtrQhKGhCgLoOdhh8LAKRjr0RR3LdsXblfJdk7bD44GYCWbskvR8pCM9tbYTAiO(Ge8Ge(GoCCWbskvR8pCM9tbYFKyKT9Ge8GZi8bL1qhcn32qxYcrgmFmamAbAudvauJtgASdsgomtzOfFQ4NHHwS9qkvo(XifHMDPNKTf4yhKmCCq3hKuQw54hJueA2LEs2wGB1qq9bbDqxoO7dgcnbe9yJet0EqqhCMHoeAUTHU(Rv9w9tQrJAOIYzCYqJDqYWHzkdT4tf)mm0Ks1k)tIixc4bDFqlqKX8A8LOA5G3cSSl9KSWQhKcqh0fdDi0CBdn4Tal7spjlSQrnubWmozOXoiz4WmLHw8PIFggAlqKX8A8LOA5LSqKbZhdaJwGhKcqh0fdDi0CBdDjlezW8XaWOfOrnu5SmozOXoiz4WmLHoeAUTHU(Rv9w9tQrdT4tf)mm0e4GAWWw5bGblAbyKJDqYWXbDFqcCqsPALtDYyzx6jgcWzJCjGh0HJdQbdBLhagSOfGro2bjdhh09bjWbjLQv(NerUeqdTqEbd9A8LOAnunZOgQMrjJtgASdsgomtzOfFQ4NHHMuQw5Fse5san0HqZTn0G3cSSl9KSWQg1q1SzgNm0yhKmCyMYqhcn32qVKSuXpu0qlKxWqVgFjQwdvZmQrn0wn6r8dJtgQMzCYqJDqYWHzkdT4tf)mm0AWWw5LHcg)Sl9wDFICSdsgooOdhhuS9qkvoci(1FTkh7GKHJd6WXbFPgR7xICYuZU0lw2GJDqYWHHoeAUTH(rI7BrgAT(czR4BudvUyCYqJDqYWHzkdT4tf)mm0e4GdmuWEQ7SeSYFPgR7xI8pCM9tbEq3huMdoqsPAL)HZSFkqUvdb1hKGhKWh0HJdoqsPAL)HZSFkq(JeJSThKGhKYDqzn0HqZTn0LSqKbZhdaJwGg1qLCmozOXoiz4WmLHw8PIFggAXUSXwO5psCFlYqR1xiBfF(JeJSThKGGoOlhKqDWsX4GUpOgmSvEzOGXp7sVv3Nih7GKHddDi0CBdD9xR6T6NuJg1qfHyCYqJDqYWHzkdT4tf)mm0IThsPYXpgPi0Sl9KSTah7GKHJd6(GKs1kh)yKIqZU0tY2cCRgcQpiOd6YbD44GIThsPYLAggwW4WxFSDg55yhKmCCq3hKuQw5snddlyC4Rp2oJ88hjgzBpibpOCoO7dskvRCPMHHfmo81hBNrEUeqdDi0CBdD9xR6T6NuJg1qfHnozOXoiz4WmLHw8PIFggAsPAL)jrKlb0qhcn32qdElWYU0tYcRAudvauJtgASdsgomtzOfFQ4NHHMahKuQw51FDgS9aLywKlb8GUpOgmSvE9xNbBpqjMf5yhKmCCqhooiPuTYPozSSl9edb4Sr(JHqpOdhhCGHc2h9Wpqripxtb1zxEq3huSaID0kVZsWQVg4bDFqsPALpWqbB9djKB1qq9bP4GaSd6WXbFPg5Ase966jKdsqqhSumm0HqZTn0ljlv8dfnQHkkNXjdn2bjdhMPm0Ipv8ZWq)sDk8a3c4ZhynfPEqcEqzo4mcFWIpOgmSv(l1PWhQITuO52CSdsgooiH6GY5GYAOdHMBBOR)AvVv)KA0OgQaygNm0yhKmCyMYql(uXpdd9l1PWdClGpFG1uK6bP4GYCqxi8bl(GAWWw5VuNcFOk2sHMBZXoiz44GeQdkNdkRHoeAUTHEjzPIFOOrnu5SmozOdHMBBOR)AvVv)KA0qJDqYWHzkJAOAgLmozOdHMBBObVF73QVq2k(gASdsgomtzudvZMzCYqhcn32qhViA0R7)yRgASdsgomtzuJAOJfnozOAMXjdDi0CBd9Je33Im0A9fYwX3qJDqYWHzkJAOYfJtgASdsgomtzOfFQ4NHHwdg2kV(RvTc5vWih7GKHddDi0CBdDjlezW8XaWOfOrnujhJtgASdsgomtzOdHMBBOR)AvVv)KA0ql(uXpddTyx2yl08hjUVfzO16lKTIp)rIr22dsqqh0LdsOoyPyCq3hudg2kVmuW4NDP3Q7tKJDqYWHHwiVGHEn(suTgQMzudveIXjdn2bjdhMPm0Ipv8ZWqtkvR8pjICjGg6qO52gAWBbw2LEswyvJAOIWgNm0yhKmCyMYql(uXpdd9adfSp6HFGIqEUMcQZU8GUpOybe7OvENLGvFnWd6(GKs1kFGHc26hsi3QHG6dsXbbyg6qO52g6LKLk(HIg1qfa14KHg7GKHdZugAXNk(zyOjLQvo1jJLDPNyiaNnYFme6bDFqzoibo4adfSp6HFGIqEUMcQZU8GUpOybe7OvENLGvFnWd6WXbjWbflGyhTY7SeS6RbEqzn0HqZTn01FTQviVcgnQHkkNXjdn2bjdhMPm0Ipv8ZWq)sDk8a3c4ZhynfPEqcEqzo4mcFWIpOgmSv(l1PWhQITuO52CSdsgooiH6GY5GYAOdHMBBOlzHidMpgagTanQHkaMXjdn2bjdhMPm0HqZTn01FTQ3QFsnAOfFQ4NHH(L6u4bUfWNpWAks9Ge8GYCWze(GfFqnyyR8xQtHpufBPqZT5yhKmCCqc1bLZbL1qlKxWqVgFjQwdvZmQHkNLXjdDi0CBd9Je33Im0A9fYwX3qJDqYWHzkJAOAgLmozOXoiz4WmLHw8PIFggAcCWbgkyF0d)afH8CnfuND5bDFqXci2rR8olbR(AGh0HJdsGdkwaXoAL3zjy1xd0qhcn32qx)1QwH8ky0OgQMnZ4KHg7GKHdZug6qO52g6LKLk(HIgAXNk(zyOFPofEGBb85dSMIupifhuMd6cHpyXhudg2k)L6u4dvXwk0CBo2bjdhhKqDq5Cqzn0c5fm0RXxIQ1q1mJAOAMlgNm0HqZTn0LSqKbZhdaJwGgASdsgomtzudvZKJXjdn2bjdhMPm0HqZTn01FTQ3QFsnAOfYlyOxJVevRHQzg1q1mcX4KHoeAUTHg8(TFR(czR4BOXoiz4WmLrnunJWgNm0HqZTn0XlIg96(p2QHg7GKHdZug1OgAY16bUll7sJtgQMzCYqJDqYWHzkdT4tf)mm0Ks1k)tIixcOHoeAUTHg8wGLDPNKfw1OgQCX4KHg7GKHdZugAXNk(zyOdHMaIESrIjApifGoOlh0HJd(snY1Ki611t4dsqqhSumoO7dkZb1GHTYldfm(zx6T6(e5yhKmCCqhooOy7HuQCeq8R)Avo2bjdhh0HJd(snw3Ve5KPMDPxSSbh7GKHJdkRHoeAUTH(rI7BrgAT(czR4BudvYX4KHg7GKHdZug6qO52g6LKLk(HIgAXNk(zyOFPofEGBb85dSMIupifGoOle2qlKxWqVgFjQwdvZmQHkcX4KHg7GKHdZugAXNk(zyOFPofEGBb85dSMIupibpOlu6GUpOfiYyEn(suT8swiYG5JbGrlWdsbOd6YbDFqXUSXwO5atglE)w91FTk)rIr22dsXbjSHoeAUTHUKfImy(yay0c0OgQiSXjdn2bjdhMPm0HqZTn01FTQ3QFsnAOfFQ4NHH(L6u4bUfWNpWAks9Ge8GUqPd6(GIDzJTqZbMmw8(T6R)Av(JeJSThKIdsydTqEbd9A8LOAnunZOgQaOgNm0yhKmCyMYql(uXpddnPuTYPozSSl9edb4Sr(JHqpO7d(sDk8a3c4ZhynfPEqkoOmhCgHpyXhudg2k)L6u4dvXwk0CBo2bjdhhKqDq5CqzpO7dAbImMxJVevlV(RvTc5vW4bPa0bD5GUpOmhKuQw5dmuWw)qc5wneuFqqheGDqhooibo4adfSp6HFGIqEUMcQZU8GoCCqcCqXci2rR8olbR(AGhuwdDi0CBdD9xRAfYRGrJAOIYzCYqJDqYWHzkdT4tf)mm0VuNcpWTa(8bwtrQhKcqhuMdkhcFWIpOgmSv(l1PWhQITuO52CSdsgooiH6GY5GYEq3h0cezmVgFjQwE9xRAfYRGXdsbOd6YbDFqzoiPuTYhyOGT(HeYTAiO(GGoia7GoCCqcCWbgkyF0d)afH8CnfuND5bD44Ge4GIfqSJw5Dwcw91apOSg6qO52g66Vw1kKxbJg1qfaZ4KHg7GKHdZug6qO52g6LKLk(HIgAXNk(zyOFPofEGBb85dSMIupifGoOmhuoe(GfFqnyyR8xQtHpufBPqZT5yhKmCCqc1bLZbL1qlKxWqVgFjQwdvZmQHkNLXjdn2bjdhMPm0Ipv8ZWql2Ln2cnhyYyX73QV(Rv5psmY2Eqko4l1ixtIOxxpHCq3h8L6u4bUfWNpWAks9Ge8GecLoO7dAbImMxJVevlVKfImy(yay0c8Gua6GUyOdHMBBOlzHidMpgagTanQHQzuY4KHg7GKHdZug6qO52g66Vw1B1pPgn0Ipv8ZWql2Ln2cnhyYyX73QV(Rv5psmY2Eqko4l1ixtIOxxpHCq3h8L6u4bUfWNpWAks9Ge8GecLm0c5fm0RXxIQ1q1mJAudnWhflrYqnozudTyx2yl0wJtgQMzCYqJDqYWHzkdT4tf)mm0IDzJTqZbMmw8(T6R)Av(JXq(d6WXbf7YgBHMdmzS49B1x)1Q8hjgzBpifh0fkzOdHMBBOLSOpvKO1OgQCX4KHg7GKHdZugAXNk(zyOjLQvoWKXI3VvF9xRYLaEq3hKuQw5irGBb89VuJ(cyaCBUeqdDi0CBdnWvZTnQHk5yCYqJDqYWHzkdT4tf)mm0Ks1khyYyX73QV(Rv5sapO7dskvRCKiWTa((xQrFbmaUnxcOHoeAUTHMKT7WxLE5nQHkcX4KHg7GKHdZugAXNk(zyOjLQvoWKXI3VvF9xRYLaAOdHMBBOjX3Ip1zxAudve24KHg7GKHdZugAXNk(zyOL5Ge4GKs1khyYyX73QV(Rv5sapO7dgcnbe9yJet0EqkaDqxoOSh0HJdsGdskvRCGjJfVFR(6VwLlb8GUpOmh8LAKpWAks9Gua6Ge(GUp4l1PWdClGpFG1uK6bPa0bbOu6GYAOdHMBBOJxen6bkXSOrnubqnozOXoiz4WmLHw8PIFggAsPALdmzS49B1x)1QCjGg6qO52gAwwcwTEkFKgLeXwnQHkkNXjdn2bjdhMPm0Ipv8ZWqtkvRCGjJfVFR(6VwLlb8GUpiPuTYrIa3c47FPg9fWa42CjGg6qO52g6OfOv)G5fbJzudvamJtgASdsgomtzOfFQ4NHHMuQw5atglE)w91FTk)rIr22dsqqheGDq3hKuQw5irGBb89VuJ(cyaCBUeqdDi0CBdDnFKKT7WOgQCwgNm0yhKmCyMYql(uXpddnPuTYbMmw8(T6R)AvUeWd6(GHqtarp2iXeThe0bNDq3huMdskvRCGjJfVFR(6VwL)iXiB7bj4bj8bDFqnyyRCXYgEWy8kh7GKHJd6WXbjWb1GHTYflB4bJXRCSdsgooO7dskvRCGjJfVFR(6VwL)iXiB7bj4bLZbL1qhcn32qtgL(T61pfuBnQHQzuY4KHg7GKHdZugAXNk(zyO1GHTYxswQ4hAUnh7GKHJd6(GYCqXUSXwO5atglE)w91FTk)Xyi)bDFWxQrUMerVUEcFqkoyPyCq3h8L6u4bUfWNpWAks9Gua6GZO0bD44GKs1khyYyX73QV(Rv5sapO7d(snY1Ki611t4dsXblfJdk7bD44G1SeS6FKyKT9Ge8GUqjdDi0CBdnse4waF)l1OVaga32OgQMnZ4KHg7GKHdZugAXNk(zyO1GHTYjFmuW(T6Tzp(OCTbh7GKHJd6(GVuNcpWTa(8bwtrQhKIdsiu6GUp4l1ixtIOxxpHpifhSumoO7dkZbjLQvo5JHc2VvVn7XhLRn4sapOdhhSMLGv)JeJSThKGh0fkDqzn0HqZTn0irGBb89VuJ(cyaCBJAOAMlgNm0yhKmCyMYql(uXpddTgmSvEkqraKJDqYWXbDFWxQXdsWdkhdDi0CBdnse4waF)l1OVaga32OgQMjhJtgASdsgomtzOfFQ4NHHwdg2kN8Xqb73Q3M94JY1gCSdsgooO7dkZbf7YgBHMt(yOG9B1BZE8r5Ad(JeJSTh0HJdk2Ln2cnN8Xqb73Q3M94JY1g8hJH8h09bFPofEGBb85dSMIupibpiaLshuwdDi0CBdnWKXI3VvF9xRAudvZieJtgASdsgomtzOfFQ4NHHwdg2kpfOiaYXoiz44GUpiboiPuTYbMmw8(T6R)AvUeqdDi0CBdnWKXI3VvF9xRAudvZiSXjdn2bjdhMPm0Ipv8ZWqRbdBLVKSuXp0CBo2bjdhh09bL5GAWWw5LHcg)Sl9wDFICSdsgooO7dskvR8hjUVfzO16lKTIpxc4bD44Ge4GAWWw5LHcg)Sl9wDFICSdsgooOSg6qO52gAGjJfVFR(6Vw1OgQMbqnozOXoiz4WmLHw8PIFggAsPALdmzS49B1x)1QCjGg6qO52gAYhdfSFREB2JpkxByudvZOCgNm0yhKmCyMYql(uXpddnPuTYbMmw8(T6R)Av(JeJSThKGhSumoO7dskvRCGjJfVFR(6VwLlb8GUpiboOgmSv(sYsf)qZT5yhKmCyOdHMBBOR)A1cY)eT(Q0lVrnundGzCYqJDqYWHzkdT4tf)mm0Hqtarp2iXeThKcqh0Ld6(GYCqsPALdmzS49B1x)1QCjGh09bjLQvoWKXI3VvF9xRYFKyKT9Ge8GLIXbD44GFKdpci2kpgdlhDEAv7bDFWpYHhbeBLhJHL)iXiB7bj4blfJd6WXbRzjy1)iXiB7bj4blfJdkRHoeAUTHU(Rvli)t06RsV8g1q1mNLXjdn2bjdhMPm0Ipv8ZWqRbdBLVKSuXp0CBo2bjdhh09bjWbjLQvoWKXI3VvF9xRYLaEq3huMdkZbjLQvUudEzY7T6JDPcMlb8GoCCqcCWbgkyp1Dwcw5VuJ19lrEnymS9IxYgd8pOSh09bL5GdKuQw5F4m7NcKB1qq9bbDqcFqhooibo4adfSN6olbR8xQX6(Li)dNz)uGhu2dkRHoeAUTHU(Rvli)t06RsV8g1qLluY4KHg7GKHdZugAXNk(zyO1GHTYjFmuW(T6Tzp(OCTbh7GKHJd6(GVuNcpWTa(8bwtrQhKIdsiu6GUp4l14bPa0bLZbDFqsPALdmzS49B1x)1QCjGh0HJdsGdQbdBLt(yOG9B1BZE8r5Ado2bjdhh09bFPofEGBb85dSMIupifGoOle2qhcn32qdwEGRcgFIPWd8rl2c0OgQCzMXjdn2bjdhMPm0Ipv8ZWqtkvRCGjJfVFR(6VwLlb0qhcn32q)rAr)aJHrnu5IlgNm0yhKmCyMYql(uXpddDi0eq0Jnsmr7bPa0bD5GUpOmheiQ8sWReJ)iXiB7bj4blfJd6WXb14lrLRjr0RRFK4bj4blfJdkRHoeAUTH2gIpRPidMhyiuJAOYf5yCYqJDqYWHzkdT4tf)mm0Hqtarp2iXeThKIds4d6WXbFPgR7xICGGX4xIBJwo2bjdhg6qO52g6bgkyF0d)afH8g1Og6bwdjMACYq1mJtg6qO52gAIzp81hrNbn0yhKmCyMYOgQCX4KHg7GKHdZugAXNk(zyOjWbhRYR)AvFfbeFUMcQZU8GUpOmhudg2kpfOiaYXoiz44GoCCqXUSXwO5Kpgky)w92ShFuU2G)iXiB7bP4GZi8bD44GAWWw5ljlv8dn3MJDqYWXbDFqXUSXwO5atglE)w91FTk)rIr22d6(Ge4GKs1kN6KXYU0tmeGZg5sapOSg6qO52gAWBbw2LEswyvJAOsogNm0yhKmCyMYql(uXpddnPuTYtH8EnyBB5psmY2Eqcc6GLIXbDFqsPALNc59AW22YLaEq3h0cezmVgFjQwEjlezW8XaWOf4bPa0bD5GUpOmhKahudg2kN8Xqb73Q3M94JY1gCSdsgooOdhhuSlBSfAo5JHc2VvVn7XhLRn4psmY2Eqko4mcFqzn0HqZTn0LSqKbZhdaJwGg1qfHyCYqJDqYWHzkdT4tf)mm0Ks1kpfY71GTTL)iXiB7bjiOdwkgh09bjLQvEkK3RbBBlxc4bDFqzoiboOgmSvo5JHc2VvVn7XhLRn4yhKmCCqhooOyx2yl0CYhdfSFREB2JpkxBWFKyKT9GuCWze(GYAOdHMBBOR)AvVv)KA0OgQiSXjdn2bjdhMPm0HqZTn0IGX8HqZT9S0QgAwAvFherdTybe7OvRrnubqnozOXoiz4WmLHoeAUTHwemMpeAUTNLw1qZsR67GiAOf7YgBH2AudvuoJtgASdsgomtzOfFQ4NHHwdg2kxSSHhmgVYXoiz44GUpOmhKuQw5ILn8GX4vUvdb1hKcqhCgLoO7dkZbhiPuTY)Wz2pfi3QHG6dc6Ge(GoCCqcCWbgkyp1Dwcw5VuJ19lr(hoZ(PapOSh0HJdwZsWQ)rIr22dsqqhSumoOSg6qO52gArWy(qO52EwAvdnlTQVdIOHwSSHhmgVAudvamJtgASdsgomtzOfFQ4NHHMuQw5Kpgky)w92ShFuU2Glb0qhcn32q)sTpeAUTNLw1qZsR67GiAOjxRxtb1zxAudvolJtgASdsgomtzOfFQ4NHHwdg2kN8Xqb73Q3M94JY1gCSdsgooO7dkZbf7YgBHMt(yOG9B1BZE8r5Ad(JeJSThKGhCgLoOSg6qO52g6xQ9HqZT9S0QgAwAvFherdn5A9a3LLDPrnunJsgNm0yhKmCyMYql(uXpddnPuTYbMmw8(T6R)AvUeWd6(GAWWw5ljlv8dn3MJDqYWHHoeAUTH(LAFi0CBplTQHMLw13br0qVKSuXp0CBJAOA2mJtgASdsgomtzOfFQ4NHHwdg2kFjzPIFO52CSdsgooO7dk2Ln2cnhyYyX73QV(Rv5psmY2EqcEWzuYqhcn32q)sTpeAUTNLw1qZsR67GiAOxswQ4hAUTh4USSlnQHQzUyCYqJDqYWHzkdT4tf)mm0Hqtarp2iXeThKcqh0fdDi0CBd9l1(qO52EwAvdnlTQVdIOHow0OgQMjhJtgASdsgomtzOdHMBBOfbJ5dHMB7zPvn0S0Q(oiIgARg9i(HrnQHMCTEnfuNDPXjdvZmozOXoiz4WmLHoeAUTHEjzPIFOOHw8PIFgg6xQtHh4waF(aRPi1dsbOdcqPKHwiVGHEn(suTgQMzudvUyCYqJDqYWHzkdT4tf)mm0AWWw5LHcg)Sl9wDFICSdsgooOdhhuS9qkvoci(1FTkh7GKHJd6WXbFPgR7xICYuZU0lw2GJDqYWXbD44GHqtarp2iXeThKcqh0fdDi0CBd9Je33Im0A9fYwX3OgQKJXjdn2bjdhMPm0Ipv8ZWqtkvR8pjICjGh09bL5GVuNcpWTa(8bwtrQhKGhKWe(GoCCWxQrUMerVUE5Cqcc6GLIXbD44GwGiJ514lr1YbVfyzx6jzHvpifGoOlhuwdDi0CBdn4Tal7spjlSQrnurigNm0yhKmCyMYqhcn32qVKSuXpu0ql(uXpdd9l1ixtIOxxpHCqcEWsX4GoCCWxQtHh4waF(aRPi1dsbOdsie2qlKxWqVgFjQwdvZmQHkcBCYqJDqYWHzkdT4tf)mm0Ks1kN6KXYU0tmeGZg5sapO7dAbImMxJVevlV(RvTc5vW4bPa0bD5GUpOmhKahCGHc2h9Wpqripxtb1zxEq3huSaID0kVZsWQVg4bD44Ge4GIfqSJw5Dwcw91apOSg6qO52g66Vw1kKxbJg1qfa14KHg7GKHdZugAXNk(zyOFPofEGBb85dSMIupifGoiHqPd6(GVuJCnjIED9Y5GuCWsXWqhcn32qdE)2VvFHSv8nQHkkNXjdn2bjdhMPm0Ipv8ZWqBbImMxJVevlV(RvTc5vW4bPa0bD5GUpOmhKuQw5dmuWw)qc5wneuFqqheGDqhooibo4adfSp6HFGIqEUMcQZU8GoCCqcCqXci2rR8olbR(AGhuwdDi0CBdD9xRAfYRGrJAOcGzCYqJDqYWHzkdDi0CBd9sYsf)qrdT4tf)mm0VuNcpWTa(8bwtrQhKId6cHpO7d(snEqkoOCm0c5fm0RXxIQ1q1mJAOYzzCYqJDqYWHzkdT4tf)mm0Ks1k)tIixcOHoeAUTHg8wGLDPNKfw1OgQMrjJtgASdsgomtzOfFQ4NHH(L6u4bUfWNpWAks9GuCqctjdDi0CBdD8IOrVU)JTAuJAOflGyhTAnozOAMXjdn2bjdhMPm0Ipv8ZWq)ro8iGyR8ymS8SpifhCgHpOdhhKah8JC4raXw5Xyy5OZtRApOdhhmeAci6XgjMO9Gua6GUyOdHMBBOhyOGT(HeAudvUyCYqJDqYWHzkdT4tf)mm0Hqtarp2iXeThe0bNDq3h8L6u4bUfWNpWAks9GuCq5Cq3huSlBSfAoWKXI3VvF9xRYFKyKT9Ge8GY5GUpiboOgmSvo5JHc2VvVn7XhLRn4yhKmCCq3huMdsGd(ro8iGyR8ymSC05PvTh0HJd(ro8iGyR8ymS8SpifhCgHpOSg6qO52gABH4jMDPNyAvJAOsogNm0yhKmCyMYql(uXpddDi0eq0Jnsmr7bPa0bD5GUpiboOgmSvo5JHc2VvVn7XhLRn4yhKmCyOdHMBBOTfINy2LEIPvnQHkcX4KHg7GKHdZugAXNk(zyO1GHTYjFmuW(T6Tzp(OCTbh7GKHJd6(GYCqsPALt(yOG9B1BZE8r5AdUeWd6(GYCWqOjGOhBKyI2dc6GZoO7d(sDk8a3c4ZhynfPEqkoiHqPd6WXbdHMaIESrIjApifGoOlh09bFPofEGBb85dSMIupifheGsPdk7bD44Ge4GKs1kN8Xqb73Q3M94JY1gCjGh09bf7YgBHMt(yOG9B1BZE8r5Ad(JeJSThuwdDi0CBdTTq8eZU0tmTQrnuryJtgASdsgomtzOfFQ4NHHoeAci6XgjMO9GGo4Sd6(GIDzJTqZbMmw8(T6R)Av(JeJSThKGhuoh09bL5Ge4GFKdpci2kpgdlhDEAv7bD44GFKdpci2kpgdlp7dsXbNr4dkRHoeAUTHoixIzhAUTNLejnQHkaQXjdn2bjdhMPm0Ipv8ZWqhcnbe9yJet0EqkaDqxm0HqZTn0b5sm7qZT9SKiPrnur5mozOXoiz4WmLHw8PIFgg6qOjGOhBKyI2dc6GZoO7dk2Ln2cnhyYyX73QV(Rv5psmY2EqcEq5Cq3huMdsGd(ro8iGyR8ymSC05PvTh0HJd(ro8iGyR8ymS8SpifhCgHpOSg6qO52gAl4qqnd9ky0l1f2xblVrnubWmozOXoiz4WmLHw8PIFgg6qOjGOhBKyI2dsbOd6IHoeAUTH2coeuZqVcg9sDH9vWYBuJAudnG4BZTnu5cLCHsZCHsoldDH47SlTgAkBacasQC2urzk3dEqNaJhmjcCF9G19p4KLKLk(HMB7bUll7Yjh8rkpP8XXbTlr8GHKUedfhhuao6s0YV5fjB8GZK7bl62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYmZ5YYV5fjB8GZK7bl62aIVIJdo5LASUFjYbWKdQ7bN8snw3Ve5aGJDqYWXKdkZmNll)MxKSXdotUhSOBdi(koo4eX2dPu5ayYb19GteBpKsLdao2bjdhtoOmZCUS8B(nNYgGaGKkNnvuMY9Gh0jW4btIa3xpyD)dorSSHhmgVo5Gps5jLpooODjIhmK0LyO44GcWrxIw(nVizJh0f5EWIUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmZCUS8BErYgpOCK7bl62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYmZ5YYV5fjB8GeICpyr3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMzoxw(nVizJhKWY9GfDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzM5Cz538BoLnabajvoBQOmL7bpOtGXdMebUVEW6(hCYsYsf)qZTNCWhP8KYhhh0UeXdgs6smuCCqb4Olrl)MxKSXdotUhSOBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZmNll)MxKSXdotUhSOBdi(koo4KxQX6(LihatoOUhCYl1yD)sKdao2bjdhtoOmZCUS8BErYgp4m5EWIUnG4R44GteBpKsLdGjhu3dorS9qkvoa4yhKmCm5GYmZ5YYV5fjB8Gau5EWIUnG4R44GteBpKsLdGjhu3dorS9qkvoa4yhKmCm5GYmZ5YYV5fjB8Gol5EWIUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmU4Cz538BoLnabajvoBQOmL7bpOtGXdMebUVEW6(hCc5A9AkOo7Yjh8rkpP8XXbTlr8GHKUedfhhuao6s0YV5fjB8GUi3dw0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLzMZLLFZls24bDrUhSOBdi(koo4KxQX6(LihatoOUhCYl1yD)sKdao2bjdhtoOmZCUS8BErYgpOlY9GfDBaXxXXbNi2EiLkhatoOUhCIy7HuQCaWXoiz4yYbLzMZLLFZV5u2aeaKu5SPIYuUh8Gobgpyse4(6bR7FWjwn6r8Jjh8rkpP8XXbTlr8GHKUedfhhuao6s0YV5fjB8GZK7bl62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYmZ5YYV5fjB8GZK7bl62aIVIJdo5LASUFjYbWKdQ7bN8snw3Ve5aGJDqYWXKdg6bPSa4lYbLzMZLLFZls24bNj3dw0TbeFfhhCIy7HuQCam5G6EWjIThsPYbah7GKHJjhuMzoxw(nVizJhuoY9GfDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCWqpiLfaFroOmZCUS8BErYgpiHi3dw0TbeFfhhCIy7HuQCam5G6EWjIThsPYbah7GKHJjhugxCUS8BErYgpiavUhSOBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZmNll)MxKSXds5K7bl62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYmZ5YYV5fjB8Gam5EWIUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmZCUS8B(nNYgGaGKkNnvuMY9Gh0jW4btIa3xpyD)doHCTEG7YYUCYbFKYtkFCCq7sepyiPlXqXXbfGJUeT8BErYgpOlY9GfDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzM5Cz538IKnEqxK7bl62aIVIJdo5LASUFjYbWKdQ7bN8snw3Ve5aGJDqYWXKdkZmNll)MxKSXd6ICpyr3gq8vCCWjIThsPYbWKdQ7bNi2EiLkhaCSdsgoMCqzM5Cz538IKnEqaQCpyr3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMzoxw(nVizJhKYj3dw0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLzMZLLFZls24bbyY9GfDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzM5Cz538BoLnabajvoBQOmL7bpOtGXdMebUVEW6(hCIyx2yl02jh8rkpP8XXbTlr8GHKUedfhhuao6s0YV5fjB8GZOKCpyr3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMzoxw(nVizJhC2m5EWIUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmZCUS8BErYgp4mxK7bl62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYmZ5YYV5fjB8GZKJCpyr3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhuMzoxw(nVizJhCgHi3dw0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLzMZLLFZls24bNry5EWIUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmZCUS8BErYgp4mkNCpyr3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhm0dszbWxKdkZmNll)MxKSXdoZzj3dw0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLzMZLLFZls24bDHsY9GfDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzCX5YYV5fjB8GUih5EWIUnG4R44GtEPgR7xICam5G6EWjVuJ19lroa4yhKmCm5GHEqkla(ICqzM5Cz538BoLnabajvoBQOmL7bpOtGXdMebUVEW6(hCIybe7Ov7Kd(iLNu(44G2LiEWqsxIHIJdkahDjA538IKnEqxK7bl62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYmZ5YYV5fjB8GYrUhSOBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdg6bPSa4lYbLzMZLLFZls24bje5EWIUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmZCUS8B(nNYgGaGKkNnvuMY9Gh0jW4btIa3xpyD)dozG1qIPto4JuEs5JJdAxI4bdjDjgkooOaC0LOLFZls24bDrUhSOBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkJloxw(nVizJhuoY9GfDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzM5Cz538IKnEqcrUhSOBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdkZmNll)MxKSXds5K7bl62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYmZ5YYV5fjB8Gol5EWIUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmZCUS8BErYgp4mkj3dw0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbd9Guwa8f5GYmZ5YYV5fjB8GZMj3dw0TbeFfhhCIgmSvoaMCqDp4enyyRCaWXoiz4yYbLzMZLLFZV5u2aeaKu5SPIYuUh8Gobgpyse4(6bR7FWjXIto4JuEs5JJdAxI4bdjDjgkooOaC0LOLFZls24bDrUhSOBdi(koo4enyyRCam5G6EWjAWWw5aGJDqYWXKdg6bPSa4lYbLzMZLLFZls24bLJCpyr3gq8vCCWjAWWw5ayYb19Gt0GHTYbah7GKHJjhm0dszbWxKdkZmNll)MxKSXds5K7bl62aIVIJdordg2khatoOUhCIgmSvoa4yhKmCm5GYmZ5YYV5fjB8Gam5EWIUnG4R44Gt0GHTYbWKdQ7bNObdBLdao2bjdhtoOmZCUS8BErYgp4SzY9GfDBaXxXXbNObdBLdGjhu3dordg2khaCSdsgoMCqzM5Cz538BUZMiW9vCCWzu6GHqZTpilTQLFZn0a)TMm0qtOpiaxmuWhKYFNLG1dcW5xREZj0heGlkqIK4FWzYX1d6cLCHs38BoH(Guwohfskooici(YFqnjIhubJhme6(hmThmamswqYq(npeAUTfeXSh(6JOZG3Cc9bbiacKj)bb48Rvpiaheq8py0JdsmYwJSpOZwi)bDkyBBV5HqZTTfdAAWBbw2LEswyvxZkicmwLx)1Q(kci(CnfuNDPBz0GHTYtbkcGoCi2Ln2cnN8Xqb73Q3M94JY1g8hjgzBPygHD4qdg2kFjzPIFO52Uf7YgBHMdmzS49B1x)1Q8hjgzBDtasPALtDYyzx6jgcWzJCjGYEZdHMBBlg00LSqKbZhdaJwGUMvqKs1kpfY71GTTL)iXiBlbbvkgUjLQvEkK3RbBBlxcOBlqKX8A8LOA5LSqKbZhdaJwGuaYf3YqanyyRCYhdfSFREB2JpkxB4WHyx2yl0CYhdfSFREB2JpkxBWFKyKTLIzew2BEi0CBBXGMU(Rv9w9tQrxZkisPALNc59AW22YFKyKTLGGkfd3Ks1kpfY71GTTLlb0Tmeqdg2kN8Xqb73Q3M94JY1goCi2Ln2cnN8Xqb73Q3M94JY1g8hjgzBPygHL9MtOpyrbVRfpiaHqZTpilT6b19GVuFZdHMBBlg00IGX8HqZT9S0QU2breKybe7Ov7npeAUTTyqtlcgZhcn32ZsR6AherqIDzJTqBV5HqZTTfdAArWy(qO52EwAvx7GicsSSHhmgV6AwbPbdBLlw2WdgJxDldPuTYflB4bJXRCRgcQPa0mk5wMbskvR8pCM9tbYTAiOgeHD4GadmuWEQ7SeSYFPgR7xI8pCM9tbkRdh1SeS6FKyKTLGGkfdzV5HqZTTfdA6xQ9HqZT9S0QU2bree5A9AkOo7sxZkisPALt(yOG9B1BZE8r5AdUeWBEi0CBBXGM(LAFi0CBplTQRDqebrUwpWDzzx6AwbPbdBLt(yOG9B1BZE8r5Ad3Yi2Ln2cnN8Xqb73Q3M94JY1g8hjgzBj4mkj7npeAUTTyqt)sTpeAUTNLw11oiIGwswQ4hAUTRzfePuTYbMmw8(T6R)AvUeq3AWWw5ljlv8dn3(Mhcn32wmOPFP2hcn32ZsR6Aherqljlv8dn32dCxw2LUMvqAWWw5ljlv8dn32Tyx2yl0CGjJfVFR(6VwL)iXiBlbNrPBEi0CBBXGM(LAFi0CBplTQRDqebfl6Awbfcnbe9yJet0sbixU5HqZTTfdAArWy(qO52EwAvx7GicYQrpIFCZV5e6dcqSuwheGC1qZTV5HqZTT8yrqpsCFlYqR1xiBf)BEi0CBlpwSyqtxYcrgmFmamAb6AwbPbdBLx)1QwH8ky8Mhcn32YJflg001FTQ3QFsn6QqEbd9A8LOAbnZ1ScsSlBSfA(Je33Im0A9fYwXN)iXiBlbb5cHQumCRbdBLxgky8ZU0B19jEZdHMBB5XIfdAAWBbw2LEswyvxZkisPAL)jrKlb8Mhcn32YJflg00ljlv8dfDnRGgyOG9rp8dueYZ1uqD2LUflGyhTY7SeS6Rb6MuQw5dmuWw)qc5wneutba7Mhcn32YJflg001FTQviVcgDnRGiLQvo1jJLDPNyiaNnYFmeQBziWadfSp6HFGIqEUMcQZU0Tybe7OvENLGvFnqhoiGybe7OvENLGvFnqzV5HqZTT8yXIbnDjlezW8XaWOfORzf0l1PWdClGpFG1uKkbLzgHlwdg2k)L6u4dvXwk0CBcLCK9Mhcn32YJflg001FTQ3QFsn6QqEbd9A8LOAbnZ1Sc6L6u4bUfWNpWAksLGYmJWfRbdBL)sDk8HQylfAUnHsoYEZdHMBB5XIfdA6hjUVfzO16lKTI)npeAUTLhlwmOPR)AvRqEfm6AwbrGbgkyF0d)afH8CnfuNDPBXci2rR8olbR(AGoCqaXci2rR8olbR(AG38qO52wESyXGMEjzPIFOORc5fm0RXxIQf0mxZkOxQtHh4waF(aRPivkKXfcxSgmSv(l1PWhQITuO52ek5i7npeAUTLhlwmOPlzHidMpgagTaV5HqZTT8yXIbnD9xR6T6NuJUkKxWqVgFjQwqZU5HqZTT8yXIbnn49B)w9fYwX)Mhcn32YJflg00XlIg96(p26n)MtOp4upgk4dU1dsN94JY1ghe4USSlp4VAO52huUh0QXR2doJs2dsI19Xdo1sFW0EWaWizbjdV5HqZTTCY16bUll7sqG3cSSl9KSWQUMvqKs1k)tIixc4npeAUTLtUwpWDzzxwmOPFK4(wKHwRVq2k(UMvqHqtarp2iXeTuaYfhoEPg5Ase966jmbbvkgULrdg2kVmuW4NDP3Q7t0HdX2dPu5iG4x)1QoC8snw3Ve5KPMDPxSSHS3Cc9bNOXxIQpRGigoxUYmqsPAL)HZSFkqUvdb1fptwkJiZajLQv(hoZ(Pa5psmY2w8mzjudmuWEQ7SeSYFPgR7xI8pCM9tbo5GaKiqmu7bJdYw11dQGt7bt7bZwXEGJdQ7b14lr9Gky8GGZsWOvpiWp3pv5pi2ir5pyHubFWOpyqMSuL)Gk4qpyHKXoyaeit(d(HZSFkWdM1d(snw3Veh8d6e4qpijMD5bJ(GyJeL)Gfsf8bP0bTAiO266b3)GrFqSrIYFqfCOhubJhCGKs16blKm2bT72heDoW8XdUn)Mhcn32YjxRh4USSllg00ljlv8dfDviVGHEn(suTGM5Awb9sDk8a3c4ZhynfPsbixi8npeAUTLtUwpWDzzxwmOPlzHidMpgagTaDnRGEPofEGBb85dSMIujOluYTfiYyEn(suT8swiYG5JbGrlqka5IBXUSXwO5atglE)w91FTk)rIr2wki8npeAUTLtUwpWDzzxwmOPR)AvVv)KA0vH8cg614lr1cAMRzf0l1PWdClGpFG1uKkbDHsUf7YgBHMdmzS49B1x)1Q8hjgzBPGW38qO52wo5A9a3LLDzXGMU(RvTc5vWORzfePuTYPozSSl9edb4Sr(JHqD)sDk8a3c4ZhynfPsHmZiCXAWWw5VuNcFOk2sHMBtOKJSUTargZRXxIQLx)1QwH8kyKcqU4wgsPALpWqbB9djKB1qqniaMdheyGHc2h9Wpqripxtb1zx6WbbelGyhTY7SeS6Rbk7npeAUTLtUwpWDzzxwmOPR)AvRqEfm6Awb9sDk8a3c4ZhynfPsbizKdHlwdg2k)L6u4dvXwk0CBcLCK1TfiYyEn(suT86Vw1kKxbJuaYf3YqkvR8bgkyRFiHCRgcQbbWC4GadmuW(Oh(bkc55AkOo7shoiGybe7OvENLGvFnqzV5HqZTTCY16bUll7YIbn9sYsf)qrxfYlyOxJVevlOzUMvqVuNcpWTa(8bwtrQuasg5q4I1GHTYFPof(qvSLcn3MqjhzV5HqZTTCY16bUll7YIbnDjlezW8XaWOfORzfKyx2yl0CGjJfVFR(6VwL)iXiBlfVuJCnjIED9eI7xQtHh4waF(aRPivcsiuYTfiYyEn(suT8swiYG5JbGrlqka5YnpeAUTLtUwpWDzzxwmOPR)AvVv)KA0vH8cg614lr1cAMRzfKyx2yl0CGjJfVFR(6VwL)iXiBlfVuJCnjIED9eI7xQtHh4waF(aRPivcsiu6MFZj0hCQhdf8b36bPZE8r5AJdcqi0eq8GaKRgAU9npeAUTLtUwVMcQZUe0sYsf)qrxfYlyOxJVevlOzUMvqVuNcpWTa(8bwtrQuacGsPBEi0CBlNCTEnfuNDzXGM(rI7BrgAT(czR47AwbPbdBLxgky8ZU0B19j6WHy7HuQCeq8R)AvhoEPgR7xICYuZU0lw2WHJqOjGOhBKyIwka5YnpeAUTLtUwVMcQZUSyqtdElWYU0tYcR6AwbrkvR8pjICjGUL5L6u4bUfWNpWAksLGeMWoC8snY1Ki611lhccQumC4WcezmVgFjQwo4Tal7spjlSkfGCr2BEi0CBlNCTEnfuNDzXGMEjzPIFOORc5fm0RXxIQf0mxZkOxQrUMerVUEcHGLIHdhVuNcpWTa(8bwtrQuaIqi8npeAUTLtUwVMcQZUSyqtx)1QwH8ky01ScIuQw5uNmw2LEIHaC2ixcOBlqKX8A8LOA51FTQviVcgPaKlULHadmuW(Oh(bkc55AkOo7s3IfqSJw5Dwcw91aD4GaIfqSJw5Dwcw91aL9Mhcn32YjxRxtb1zxwmOPbVF73QVq2k(UMvqVuNcpWTa(8bwtrQuaIqOK7xQrUMerVUE5qrPyCZdHMBB5KR1RPG6Sllg001FTQviVcgDnRGSargZRXxIQLx)1QwH8kyKcqU4wgsPALpWqbB9djKB1qqniaMdheyGHc2h9Wpqripxtb1zx6WbbelGyhTY7SeS6Rbk7npeAUTLtUwVMcQZUSyqtVKSuXpu0vH8cg614lr1cAMRzf0l1PWdClGpFG1uKkfUqy3VuJuiNBEi0CBlNCTEnfuNDzXGMg8wGLDPNKfw11ScIuQw5Fse5saV5HqZTTCY161uqD2LfdA64frJED)hB11Sc6L6u4bUfWNpWAksLcctPB(nNqFWIUSXbP8fJxpyr3EKAUT9Mhcn32YflB4bJXRGeGJST(T6tb6AwbvZsWQ)rIr2wcwkg3Cc9bPm2IhCi9zxEqkdjJf)blKk4d6SfOiao9upgk4BEi0CBlxSSHhmgVwmOPfGJST(T6tb6AwbranyyR8LKLk(HMB7MuQw5atglE)w91FTk)rIr2wckh3Ks1khyYyX73QV(Rv5saDtkvRCXYgEWy8k3QHGAkanJs3Cc9bb4LuBoWdU1dszizS4pOKfJs8Gfsf8bD2cueaNEQhdf8npeAUTLlw2WdgJxlg00cWr2w)w9PaDnRGiGgmSv(sYsf)qZTDpWqb7PUZsWk)LASUFjYRbJHTx8s2yGVBziLQvUyzdpymELB1qqnfGMbqDtkvRCPg8YK3B1h7sfmxcOdhKs1kxSSHhmgVYTAiOMcqZCwUf7YgBHMdmzS49B1x)1Q8hjgzBPygLK9Mhcn32YflB4bJXRfdAAb4iBRFR(uGUMvqeqdg2kFjzPIFO52UjWadfSN6olbR8xQX6(LiVgmg2EXlzJb(UjLQvUyzdpymELB1qqnfGMrj3Ks1khyYyX73QV(Rv5saDl2Ln2cnhyYyX73QV(Rv5psmY2sHlu6MtOpiLHhbeB9GfDzJds5lgVEWfq8fbqGzxEWH0ND5bbMmw838qO52wUyzdpymETyqtlahzB9B1Nc01Scsdg2kFjzPIFO52UjaPuTYbMmw8(T6R)AvUeq3YqkvRCXYgEWy8k3QHGAkandG6MuQw5sn4LjV3Qp2LkyUeqhoiLQvUyzdpymELB1qqnfGM5SC4qSlBSfAoWKXI3VvF9xRYFKyKTLGYXnPuTYflB4bJXRCRgcQPa0mcr2B(nNqFqa((GugBXd6SvKO11dszy1C7dg94GaKHidM9Mhcn32Yf7YgBH2csYI(urIwxZkiXUSXwO5atglE)w91FTk)XyiVdhIDzJTqZbMmw8(T6R)Av(JeJSTu4cLU5HqZTTCXUSXwOTfdAAGRMB7AwbrkvRCGjJfVFR(6VwLlb0nPuTYrIa3c47FPg9fWa42CjG38qO52wUyx2yl02IbnnjB3HVk9Y7AwbrkvRCGjJfVFR(6VwLlb0nPuTYrIa3c47FPg9fWa42CjG38qO52wUyx2yl02Ibnnj(w8Po7sxZkisPALdmzS49B1x)1QCjG38qO52wUyx2yl02IbnD8IOrpqjMfDnRGKHaKs1khyYyX73QV(Rv5saDhcnbe9yJet0sbixK1HdcqkvRCGjJfVFR(6VwLlb0TmVuJ8bwtrQuaIWUFPofEGBb85dSMIuPaeaLsYEZdHMBB5IDzJTqBlg00SSeSA9u(inkjIT6AwbrkvRCGjJfVFR(6VwLlb8Mhcn32Yf7YgBH2wmOPJwGw9dMxemMRzfePuTYbMmw8(T6R)AvUeq3Ks1khjcClGV)LA0xadGBZLaEZdHMBB5IDzJTqBlg0018rs2UdxZkisPALdmzS49B1x)1Q8hjgzBjiiaMBsPALJebUfW3)sn6lGbWT5saV5HqZTTCXUSXwOTfdAAYO0VvV(PGARRzfePuTYbMmw8(T6R)AvUeq3Hqtarp2iXeTGM5wgsPALdmzS49B1x)1Q8hjgzBjiHDRbdBLlw2WdgJx5yhKmC4Wbb0GHTYflB4bJXRCSdsgoCtkvRCGjJfVFR(6VwL)iXiBlbLJS3Cc9bl6USXwOT38qO52wUyx2yl02Ibnnse4waF)l1OVaga321Scsdg2kFjzPIFO52ULrSlBSfAoWKXI3VvF9xRYFmgY7(LAKRjr0RRNWuukgUFPofEGBb85dSMIuPa0mk5WbPuTYbMmw8(T6R)AvUeq3VuJCnjIED9eMIsXqwhoQzjy1)iXiBlbDHs38qO52wUyx2yl02Ibnnse4waF)l1OVaga321Scsdg2kN8Xqb73Q3M94JY1gUFPofEGBb85dSMIuPGqOK7xQrUMerVUEctrPy4wgsPALt(yOG9B1BZE8r5AdUeqhoQzjy1)iXiBlbDHsYEZdHMBB5IDzJTqBlg00irGBb89VuJ(cyaCBxZkinyyR8uGIaO7xQrckNBEi0CBlxSlBSfABXGMgyYyX73QV(RvDnRG0GHTYjFmuW(T6Tzp(OCTHBze7YgBHMt(yOG9B1BZE8r5Ad(JeJSToCi2Ln2cnN8Xqb73Q3M94JY1g8hJH8UFPofEGBb85dSMIujiaLsYEZdHMBB5IDzJTqBlg00atglE)w91FTQRzfKgmSvEkqra0nbiLQvoWKXI3VvF9xRYLaEZdHMBB5IDzJTqBlg00atglE)w91FTQRzfKgmSv(sYsf)qZTDlJgmSvEzOGXp7sVv3Nih7GKHd3Ks1k)rI7BrgAT(czR4ZLa6Wbb0GHTYldfm(zx6T6(e5yhKmCi7npeAUTLl2Ln2cTTyqtt(yOG9B1BZE8r5AdxZkisPALdmzS49B1x)1QCjG38qO52wUyx2yl02IbnD9xRwq(NO1xLE5DnRGiLQvoWKXI3VvF9xRYFKyKTLGLIHBsPALdmzS49B1x)1QCjGUjGgmSv(sYsf)qZTV5HqZTTCXUSXwOTfdA66VwTG8prRVk9Y7Awbfcnbe9yJet0sbixCldPuTYbMmw8(T6R)AvUeq3Ks1khyYyX73QV(Rv5psmY2sWsXWHJpYHhbeBLhJHLJopTQ19h5WJaITYJXWYFKyKTLGLIHdh1SeS6FKyKTLGLIHS38qO52wUyx2yl02IbnD9xRwq(NO1xLE5DnRG0GHTYxswQ4hAUTBcqkvRCGjJfVFR(6VwLlb0TmYqkvRCPg8YK3B1h7sfmxcOdheyGHc2tDNLGv(l1yD)sKxdgdBV4LSXaFzDlZajLQv(hoZ(Pa5wneudIWoCqGbgkyp1Dwcw5VuJ19lr(hoZ(PaLv2BEi0CBlxSlBSfABXGMgS8axfm(etHh4JwSfORzfKgmSvo5JHc2VvVn7XhLRnC)sDk8a3c4ZhynfPsbHqj3VuJuasoUjLQvoWKXI3VvF9xRYLa6Wbb0GHTYjFmuW(T6Tzp(OCTH7xQtHh4waF(aRPivka5cHV5HqZTTCXUSXwOTfdA6psl6hymCnRGiLQvoWKXI3VvF9xRYLaEZdHMBB5IDzJTqBlg002q8znfzW8adH6Awbfcnbe9yJet0sbixCldqu5LGxjg)rIr2wcwkgoCOXxIkxtIOxx)ircwkgYEZdHMBB5IDzJTqBlg00dmuW(Oh(bkc5DnRGcHMaIESrIjAPGWoC8snw3Ve5abJXVe3gT38BoH(GfDbe7O1dcqqMSut0EZdHMBB5IfqSJwTGgyOGT(He6Awb9ro8iGyR8ymS8SPygHD4GaFKdpci2kpgdlhDEAvRdhHqtarp2iXeTuaYLBEi0CBlxSaID0QTyqtBlepXSl9etR6Awbfcnbe9yJet0cAM7xQtHh4waF(aRPivkKJBXUSXwO5atglE)w91FTk)rIr2wckh3eqdg2kN8Xqb73Q3M94JY1gULHaFKdpci2kpgdlhDEAvRdhFKdpci2kpgdlpBkMryzV5HqZTTCXci2rR2IbnTTq8eZU0tmTQRzfui0eq0JnsmrlfGCXnb0GHTYjFmuW(T6Tzp(OCTXnpeAUTLlwaXoA1wmOPTfINy2LEIPvDnRG0GHTYjFmuW(T6Tzp(OCTHBziLQvo5JHc2VvVn7XhLRn4saDlti0eq0JnsmrlOzUFPofEGBb85dSMIuPGqOKdhHqtarp2iXeTuaYf3VuNcpWTa(8bwtrQuaqPKSoCqasPALt(yOG9B1BZE8r5AdUeq3IDzJTqZjFmuW(T6Tzp(OCTb)rIr2wzV5HqZTTCXci2rR2IbnDqUeZo0CBpljs6Awbfcnbe9yJet0cAMBXUSXwO5atglE)w91FTk)rIr2wckh3YqGpYHhbeBLhJHLJopTQ1HJpYHhbeBLhJHLNnfZiSS38qO52wUybe7OvBXGMoixIzhAUTNLejDnRGcHMaIESrIjAPaKl38qO52wUybe7OvBXGM2coeuZqVcg9sDH9vWY7Awbfcnbe9yJet0cAMBXUSXwO5atglE)w91FTk)rIr2wckh3YqGpYHhbeBLhJHLJopTQ1HJpYHhbeBLhJHLNnfZiSS38qO52wUybe7OvBXGM2coeuZqVcg9sDH9vWY7Awbfcnbe9yJet0sbixU53Cc9bb4jzPIFO52h8xn0C7BEi0CBlFjzPIFO52GEK4(wKHwRVq2k(UMvqHqtarp2iXeTuasoULrdg2kVmuW4NDP3Q7t0HdX2dPu5iG4x)1QoC8snw3Ve5KPMDPxSSHS38qO52w(sYsf)qZTlg00G3cSSl9KSWQUMvqeySkV(Rv9veq85AkOo7s3eGuQw5uNmw2LEIHaC2ixc4npeAUTLVKSuXp0C7IbnD9xRAfYRGrxZkisPALtDYyzx6jgcWzJ8hdH62cezmVgFjQwE9xRAfYRGrka5IBziLQv(adfS1pKqUvdb1GayoCqGbgkyF0d)afH8CnfuNDPdheqSaID0kVZsWQVgOS38qO52w(sYsf)qZTlg00ljlv8dfDviVGHEn(suTGM5AwbrkvRCQtgl7spXqaoBK)yiuhoiaPuTY)KiYLa62cezmVgFjQwo4Tal7spjlSkfGKZnpeAUTLVKSuXp0C7IbnDjlezW8XaWOfORzfKfiYyEn(suT8swiYG5JbGrlqka5IBzEPofEGBb85dSMIuj4mk5WXl1ixtIOxxVluukgY6WHmdKuQw5F4m7NcKB1qqnbjSdhdKuQw5F4m7NcK)iXiBlbNryzV5HqZTT8LKLk(HMBxmOPR)AvVv)KA01ScsS9qkvo(XifHMDPNKTfCtkvRC8Jrkcn7spjBlWTAiOgKlUdHMaIESrIjAbn7Mhcn32YxswQ4hAUDXGMg8wGLDPNKfw11ScIuQw5Fse5saDBbImMxJVevlh8wGLDPNKfwLcqUCZdHMBB5ljlv8dn3UyqtxYcrgmFmamAb6AwbzbImMxJVevlVKfImy(yay0cKcqUCZdHMBB5ljlv8dn3Uyqtx)1QER(j1ORc5fm0RXxIQf0mxZkicObdBLhagSOfGr3eGuQw5uNmw2LEIHaC2ixcOdhAWWw5bGblAby0nbiLQv(NerUeWBEi0CBlFjzPIFO52fdAAWBbw2LEswyvxZkisPAL)jrKlb8Mhcn32YxswQ4hAUDXGMEjzPIFOORc5fm0RXxIQf0SB(nNqFqkd7YYU8GaC2)Ga8KSuXp0CB5EqAnE1EWzu6GwuS9WEqsSUpEqkdjJf)b36bb48RvpOyjI2dU16blka3BEi0CBlFjzPIFO52EG7YYUe0Je33Im0A9fYwX31Scsdg2kVmuW4NDP3Q7t0HdX2dPu5iG4x)1QoC8snw3Ve5KPMDPxSSHdhHqtarp2iXeTuaYLBEi0CBlFjzPIFO52EG7YYUSyqtdElWYU0tYcR6AwbrkvR8pjICjG38qO52w(sYsf)qZT9a3LLDzXGMEjzPIFOORc5fm0RXxIQf0mxZkisPALtDYyzx6jgcWzJ8hdHEZdHMBB5ljlv8dn32dCxw2LfdA6swiYG5JbGrlqxZkilqKX8A8LOA5LSqKbZhdaJwGuaYf3VuNcpWTa(8bwtrQeeGsPBEi0CBlFjzPIFO52EG7YYUSyqtx)1QER(j1ORc5fm0RXxIQf0mxZkOxQtHh4waF(aRPivcs5O0npeAUTLVKSuXp0CBpWDzzxwmOPxswQ4hk6QqEbd9A8LOAbnZ1Sc6LAKcc5Mhcn32YxswQ4hAUTh4USSllg001FTQviVcgDnRGcHMaIESrIjAPaeH4wgcmWqb7JE4hOiKNRPG6SlDlwaXoAL3zjy1xd0HdciwaXoAL3zjy1xdu2B(nNqFqAn6r8JdAZUKHugvJVe1d(RgAU9npeAUTLB1OhXpa9iX9TidTwFHSv8DnRG0GHTYldfm(zx6T6(eD4qS9qkvoci(1FTQdhVuJ19lrozQzx6flBCZdHMBB5wn6r8JIbnDjlezW8XaWOfORzfebgyOG9u3zjyL)snw3Ve5F4m7Nc0TmdKuQw5F4m7NcKB1qqnbjSdhdKuQw5F4m7NcK)iXiBlbPCYEZdHMBB5wn6r8JIbnD9xR6T6NuJUMvqIDzJTqZFK4(wKHwRVq2k(8hjgzBjiixiuLIHBnyyR8YqbJF2LERUpXBEi0CBl3QrpIFumOPR)AvVv)KA01ScsS9qkvo(XifHMDPNKTfCtkvRC8Jrkcn7spjBlWTAiOgKloCi2EiLkxQzyybJdF9X2zK3nPuTYLAggwW4WxFSDg55psmY2sq54MuQw5snddlyC4Rp2oJ8CjG38qO52wUvJEe)OyqtdElWYU0tYcR6AwbrkvR8pjICjG38qO52wUvJEe)OyqtVKSuXpu01ScIaKs1kV(RZGThOeZICjGU1GHTYR)6my7bkXSOdhKs1kN6KXYU0tmeGZg5pgc1HJbgkyF0d)afH8CnfuNDPBXci2rR8olbR(AGUjLQv(adfS1pKqUvdb1uaWC44LAKRjr0RRNqiiOsX4Mhcn32YTA0J4hfdA66Vw1B1pPgDnRGEPofEGBb85dSMIujOmZiCXAWWw5VuNcFOk2sHMBtOKJS38qO52wUvJEe)OyqtVKSuXpu01Sc6L6u4bUfWNpWAksLczCHWfRbdBL)sDk8HQylfAUnHsoYEZdHMBB5wn6r8JIbnD9xR6T6NuJ38qO52wUvJEe)OyqtdE)2VvFHSv8V5HqZTTCRg9i(rXGMoEr0Ox3)Xwn0wGOWqLleEMrnQXaa]] )

end
