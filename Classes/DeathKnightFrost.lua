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


    spec:RegisterPack( "Frost DK", 20210125.1, [[d4KOkcqiGIhHKuxcOKGnjH(KI0OiQ6uevwfsGELIWSeuUfsaSlc)cGmmKqhtrzzcuptaAAaL6Aav2MGQ6BijQXbuIZjOkwNayEavDpeSpKOdIKilur0dfqMisa6IibLnIeqFejOAKaLKCsKGSsfvVeOKuZuqLDsu8tbvPHcusTuKe6Pi1ufixfOKOVIKGgla1EP0FfAWGomvlgrpgvtwHldTzj9zjA0a50IwnqjHEnrPzJYTrODl1VvA4a64ijWYv1ZPy6KUor2oa(UemEbuNhj16rsY8fK9RY2z2GS0dxrRmbtXGNrXzbdorWuCw4dUWJLwPgiAPb6Cz9s0s3or0stb(RrpifqWQT0aDQzRpSbzPnR0ZrlnivbAcaGauzQGKif8LiGmjrjMR5283RkGmjroGS0KsjtPqTL0spCfTYemfdEgfNfm4ebtXzHp4alwAxsbTVLMojgilnOCmW2sAPhOHBPPAQ(GuarxbDqWQ7SeKEqkWFn6nNQP6do3Bj)P(GbdUWoyWum4z38Bovt1hmqG8Uen3CQMQpifGdsfrIla44Gm3OuamiF7XbLmEjEWTEWabYZ2CWTEqkehpOBoyQhCSOPNQheiZP(Gfqg7GzFqGVZ1KJclnlnQXgKLEjzPIVR52rG7YYU0gKvMz2GS0y7KmCyN0s7Cn32s)iX9nidnMyHSv8T0d0W)eOMBBPbR3LLD5bPa3)GHxswQ47AUDaoiT6VAo4mkEqdY3Eyoijw3hpiyDYy(FWTEqkWFn6b5lr0CWTwpyGOaAP5FQ4NULwDg2QO0vq4NDz0O7tuGTtYWXbdf6G8ThsPkqaWV(Rrfy7KmCCWqHo4l1yD)suqMA2Lr(YgcSDsgooyOqh05AcagXgjMO5Gus4GbBvRmbBdYsJTtYWHDsln)tf)0T0Ks1Q4tIOqcOL25AUTLg0wGLDzKK5g1QwzcOniln2ojdh2jT0oxZTT0ljlv8DfT08pv8t3stkvRcztgl7YirNdkBu8OZvlnNAodJQ)LOASYmZQwzaBBqwASDsgoStAP5FQ4NUL2aezSO6FjQgrjZ5PZI(aaV54bPKWbd(Gfp4l1jpcClGVyG1KN6bb)bdFkAPDUMBBPlzopDw0ha4nhTQvgWzdYsJTtYWHDslTZ1CBlD9xJgn6NYIwA(Nk(PBPFPo5rGBb8fdSM8upi4pivMIwAo1Cggv)lr1yLzMvTYe(2GS0y7KmCyN0s7Cn32sVKSuX3v0sZ)uXpDl9l14bP8GGTLMtnNHr1)sunwzMzvRmuzBqwASDsgoStAP5FQ4NUL25AcagXgjMO5Gus4GG9blEq5piyo4aDfu07rCGCNAHMCzZU8GfpiFbaBVvrNLG0y1Xdgk0bbZb5lay7Tk6SeKgRoEq5S0oxZTT01FnQHtTccTQvT08LnIGq)vBqwzMzdYsJTtYWHDslTZ1CBlnhKNTjU1yYrl9an8pbQ52wAWkn4bhsF2LheSozm)pyHubDqkeh5oqan5JUcYsZ)uXpDlnyoO6mSvXsYsfFxZTfy7KmCCWIhKuQwfatgZ)4wJ1FnQ4rIE2Mdc(dgWdw8GKs1QayYy(h3AS(RrfsapyXdskvRc(YgrqO)QWOox2dsjHdoJIw1ktW2GS0y7KmCyN0s7Cn32sZb5zBIBnMC0spqd)tGAUTLo8kPMCGhCRheSozm)pOKb9s8Gfsf0bPqCK7ab0Kp6kiln)tf)0T0G5GQZWwfljlv8Dn3wGTtYWXblEWb6kOOSDwcsfVuJ19lrr1zmSJ8xY4d8pyXdcMdskvRcGjJ5FCRX6Vgvib8GfpO8hKuQwf8LnIGq)vHrDUShKschCw4FWIhKuQwfsnOLrD0Op2LkiHeWdgk0bjLQvbFzJii0FvyuNl7bPKWbNfEoyXdY3Ln2cTayYy(h3AS(Rrfps0Z2Cqkp4mkEq5SQvMaAdYsJTtYWHDsln)tf)0T0G5GQZWwfljlv8Dn3wGTtYWXblEqWCWb6kOOSDwcsfVuJ19lrr1zmSJ8xY4d8pyXdskvRc(YgrqO)QWOox2dsjHdoJIhS4bbZbjLQvbWKX8pU1y9xJkKaEWIhKVlBSfAbWKX8pU1y9xJkEKONT5GuEWGPOL25AUTLMdYZ2e3Am5OvTYa22GS0y7KmCyN0s7Cn32sZb5zBIBnMC0spqd)tGAUTLgS(raWwpyGw24GGvH(RhCbaFUdey2LhCi9zxEqGjJ5VLM)PIF6wA1zyRILKLk(UMBlW2jz44GfpiyoiPuTkaMmM)XTgR)AuHeWdw8GYFqsPAvWx2icc9xfg15YEqkjCWzH)blEqsPAvi1Gwg1rJ(yxQGesapyOqhKuQwf8LnIGq)vHrDUShKschCw45GHcDq(USXwOfatgZ)4wJ1FnQ4rIE2Mdc(dgWdw8GKs1QGVSree6VkmQZL9Gus4GZa7dkNvTQLEjzPIVR522GSYmZgKLgBNKHd7KwANR52w6hjUVbzOXelKTIVLEGg(Na1CBlD4LKLk(UMBFWFvxZTT08pv8t3s7CnbaJyJet0CqkjCWaEWIhu(dQodBvu6ki8ZUmA09jkW2jz44GHcDq(2dPufia4x)1OcSDsgooyOqh8LASUFjkitn7YiFzdb2ojdhhuoRALjyBqwASDsgoStAP5FQ4NULgmhCSQO(RrJvea8fAYLn7Ydw8GG5GKs1Qq2KXYUms05GYgfsaT0oxZTT0G2cSSlJKm3Ow1ktaTbzPX2jz4WoPLM)PIF6wAsPAviBYyzxgj6CqzJIhDUEWIh0aezSO6FjQgr9xJA4uRGWdsjHdg8blEq5piPuTkgORGmXHekmQZL9Geoiy5GHcDqWCWb6kOO3J4a5o1cn5YMD5bdf6GG5G8faS9wfDwcsJvhpOCwANR52w66Vg1WPwbHw1kdyBdYsJTtYWHDslTZ1CBl9sYsfFxrln)tf)0T0Ks1Qq2KXYUms05GYgfp6C9GHcDqWCqsPAv8jruib8GfpObiYyr1)suncqBbw2LrsMB0dsjHdgqlnNAodJQ)LOASYmZQwzaNniln2ojdh2jT08pv8t3sBaImwu9VevJOK580zrFaG3C8Gus4GbFWIhu(d(sDYJa3c4lgyn5PEqWFWzu8GHcDWxQrHMeXOUXGpiLhSKpoOChmuOdk)bhiPuTkENQ2p5OWOox2dc(dcUdgk0bhiPuTkENQ2p5O4rIE2Mdc(dodChuolTZ1CBlDjZ5PZI(aaV5OvTYe(2GS0y7KmCyN0sZ)uXpDlnF7HuQc89rYDn7YijBliW2jz44GfpiPuTkW3hj31SlJKSTGWOox2ds4GbFWIh05AcagXgjMO5Geo4mlTZ1CBlD9xJgn6NYIw1kdv2gKLgBNKHd7KwA(Nk(PBPjLQvXNerHeWdw8GgGiJfv)lr1iaTfyzxgjzUrpiLeoyWwANR52wAqBbw2LrsMBuRALbSydYsJTtYWHDsln)tf)0T0gGiJfv)lr1ikzopDw0ha4nhpiLeoyWwANR52w6sMZtNf9baEZrRALj8ydYsJTtYWHDslTZ1CBlD9xJgn6NYIwA(Nk(PBPbZbvNHTkCaCM3CqOaBNKHJdw8GG5GKs1Qq2KXYUms05GYgfsapyOqhuDg2QWbWzEZbHcSDsgooyXdcMdskvRIpjIcjGwAo1Cggv)lr1yLzMvTYmJI2GS0y7KmCyN0sZ)uXpDlnPuTk(KikKaAPDUMBBPbTfyzxgjzUrTQvMzZSbzPX2jz4WoPL25AUTLEjzPIVROLMtnNHr1)sunwzMzvRAPnQ3d)h2GSYmZgKLgBNKHd7KwANR52w6hjUVbzOXelKTIVLEGg(Na1CBlnT69W)XbnzxYqkaQ)LOEWFvxZTT08pv8t3sRodBvu6ki8ZUmA09jkW2jz44GHcDq(2dPufia4x)1OcSDsgooyOqh8LASUFjkitn7YiFzdb2ojdhw1ktW2GS0y7KmCyN0sZ)uXpDlnyo4aDfuu2olbPIxQX6(LO4DQA)KJhS4bL)GdKuQwfVtv7NCuyuNl7bb)bb3bdf6GdKuQwfVtv7NCu8irpBZbb)bPYhuolTZ1CBlDjZ5PZI(aaV5OvTYeqBqwASDsgoStAP5FQ4NULMVlBSfAXJe33Gm0yIfYwXx8irpBZbbpHdg8bPGhSKpoyXdQodBvu6ki8ZUmA09jkW2jz4Ws7Cn32sx)1OrJ(PSOvTYa22GS0y7KmCyN0sZ)uXpDlnF7HuQc89rYDn7YijBliW2jz44GfpiPuTkW3hj31SlJKSTGWOox2ds4GbFWqHoiF7HuQcPMHUbeoI1hBQIAb2ojdhhS4bjLQvHuZq3achX6JnvrT4rIE2Mdc(dgWdw8GKs1QqQzOBaHJy9XMQOwib0s7Cn32sx)1OrJ(PSOvTYaoBqwASDsgoStAP5FQ4NULMuQwfFsefsaT0oxZTT0G2cSSlJKm3Ow1kt4BdYsJTtYWHDsln)tf)0T0G5GKs1QO(lvHDeOeZGcjGhS4bvNHTkQ)svyhbkXmOaBNKHJdgk0bjLQvHSjJLDzKOZbLnkE056bdf6Gd0vqrVhXbYDQfAYLn7Ydw8G8faS9wfDwcsJvhpyXdskvRIb6kitCiHcJ6CzpiLheSCWqHo4l1OqtIyu3iyFqWt4GL8HL25AUTLEjzPIVROvTYqLTbzPX2jz4WoPLM)PIF6w6xQtEe4waFXaRjp1dc(dk)bNbUdoXbvNHTkEPo5rxvSLCn3wGTtYWXbPGhmGhuolTZ1CBlD9xJgn6NYIw1kdyXgKLgBNKHd7KwA(Nk(PBPFPo5rGBb8fdSM8upiLhu(dgm4o4ehuDg2Q4L6KhDvXwY1CBb2ojdhhKcEWaEq5S0oxZTT0ljlv8DfTQvMWJnilTZ1CBlD9xJgn6NYIwASDsgoStAvRmZOOnilTZ1CBlnO974wJfYwX3sJTtYWHDsRALz2mBqwANR52wA)5EJrD)hB1sJTtYWHDsRAvlTVOniRmZSbzPX2jz4WoPLEGg(Na1CBlnvAPWoivCvxZTT0oxZTT0psCFdYqJjwiBfFRALjyBqwASDsgoStAP5FQ4NULwDg2QO(RrnCQvqOaBNKHdlTZ1CBlDjZ5PZI(aaV5OvTYeqBqwASDsgoStAPDUMBBPR)A0Or)uw0sZ)uXpDlnFx2yl0IhjUVbzOXelKTIV4rIE2MdcEchm4dsbpyjFCWIhuDg2QO0vq4NDz0O7tuGTtYWHLMtnNHr1)sunwzMzvRmGTniln2ojdh2jT08pv8t3stkvRIpjIcjGwANR52wAqBbw2LrsMBuRALbC2GS0y7KmCyN0sZ)uXpDl9aDfu07rCGCNAHMCzZU8GfpiFbaBVvrNLG0y1Xdw8GKs1QyGUcYehsOWOox2ds5bblwANR52w6LKLk(UIw1kt4BdYsJTtYWHDsln)tf)0T0Ks1Qq2KXYUms05GYgfp6C9GfpO8hemhCGUck69ioqUtTqtUSzxEWIhKVaGT3QOZsqAS64bdf6GG5G8faS9wfDwcsJvhpOCwANR52w66Vg1WPwbHw1kdv2gKLgBNKHd7KwA(Nk(PBPFPo5rGBb8fdSM8upi4pO8hCg4o4ehuDg2Q4L6KhDvXwY1CBb2ojdhhKcEWaEq5S0oxZTT0LmNNol6da8MJw1kdyXgKLgBNKHd7KwANR52w66VgnA0pLfT08pv8t3s)sDYJa3c4lgyn5PEqWFq5p4mWDWjoO6mSvXl1jp6QITKR52cSDsgooif8Gb8GYzP5uZzyu9VevJvMzw1kt4XgKLgBNKHd7KwA(Nk(PBPbZbhORGIEpIdK7ul0KlB2LhS4b5lay7Tk6SeKgRoEWqHoiyoiFbaBVvrNLG0y1rlTZ1CBlD9xJA4uRGqRALzgfTbzPX2jz4WoPL25AUTLEjzPIVROLM)PIF6w6xQtEe4waFXaRjp1ds5bL)GbdUdoXbvNHTkEPo5rxvSLCn3wGTtYWXbPGhmGhuolnNAodJQ)LOASYmZQwzMnZgKL25AUTLUK580zrFaG3C0sJTtYWHDsRALzwW2GS0y7KmCyN0s7Cn32sx)1OrJ(PSOLMtnNHr1)sunwzMzvRmZcOnilTZ1CBlnO974wJfYwX3sJTtYWHDsRALzgyBdYs7Cn32s7p3BmQ7)yRwASDsgoStAvRAPjxte4USSlTbzLzMniln2ojdh2jT0oxZTT0G2cSSlJKm3Ow6bA4FcuZTT0t(ORGo4wpiD2J3lxJFqG7YYU8G)QUMBFWaCqJ6VAo4mkAoijw3hp4Kl9btZbDa8K5Km0sZ)uXpDlnPuTk(KikKaAvRmbBdYsJTtYWHDsln)tf)0T0oxtaWi2iXenhKschm4dgk0bFPgfAseJ6gb3bbpHdwYhhS4bL)GQZWwfLUcc)SlJgDFIcSDsgooyOqhKV9qkvbca(1FnQaBNKHJdgk0bFPgR7xIcYuZUmYx2qGTtYWXbLZs7Cn32s)iX9nidnMyHSv8TQvMaAdYsJTtYWHDslTZ1CBl9sYsfFxrlnNAodJQ)LOASYmZsZ)uXpDl9l1jpcClGVyG1KN6bPKWbdgCw6bA4FcuZTT0tv)lrnMvce9aha5hiPuTkENQ2p5OWOox2jMjhyfKFGKs1Q4DQA)KJIhj6zBMyMCuWb6kOOSDwcsfVuJ19lrX7u1(jhNEqQiceD1Cq)GSvd7GkO0CW0CWSvSh44G6Eq1)supOccpiOSeeA0dc8Z9tL6dInsK6dwivqh07d6KjlvQpOcY1dwizSd6abYO(GVtv7NC8Gz9GVuJ19lXH4GbbY1dsIzxEqVpi2irQpyHubDqkEqJ6CznHDW9pO3heBKi1hub56bvq4bhiPuTEWcjJDqZU9bXadmF8GBlSQvgW2gKLgBNKHd7KwA(Nk(PBPFPo5rGBb8fdSM8upi4pyWu8GfpObiYyr1)sunIsMZtNf9baEZXdsjHdg8blEq(USXwOfatgZ)4wJ1FnQ4rIE2Mds5bbNL25AUTLUK580zrFaG3C0QwzaNniln2ojdh2jT0oxZTT01FnA0OFklAP5FQ4NUL(L6KhbUfWxmWAYt9GG)GbtXdw8G8DzJTqlaMmM)XTgR)AuXJe9SnhKYdcolnNAodJQ)LOASYmZQwzcFBqwASDsgoStAP5FQ4NULMuQwfYMmw2LrIohu2O4rNRhS4bFPo5rGBb8fdSM8upiLhu(dodChCIdQodBv8sDYJUQyl5AUTaBNKHJdsbpyapOChS4bnarglQ(xIQru)1Ogo1ki8Gus4GbFWIhu(dskvRIb6kitCiHcJ6CzpiHdcwoyOqhemhCGUck69ioqUtTqtUSzxEWqHoiyoiFbaBVvrNLG0y1XdkNL25AUTLU(RrnCQvqOvTYqLTbzPX2jz4WoPLM)PIF6w6xQtEe4waFXaRjp1dsjHdk)bdi4o4ehuDg2Q4L6KhDvXwY1CBb2ojdhhKcEWaEq5oyXdAaImwu9VevJO(RrnCQvq4bPKWbd(GfpO8hKuQwfd0vqM4qcfg15YEqcheSCWqHoiyo4aDfu07rCGCNAHMCzZU8GHcDqWCq(ca2ERIolbPXQJhuolTZ1CBlD9xJA4uRGqRALbSydYsJTtYWHDslTZ1CBl9sYsfFxrln)tf)0T0VuN8iWTa(IbwtEQhKschu(dgqWDWjoO6mSvXl1jp6QITKR52cSDsgooif8Gb8GYzP5uZzyu9VevJvMzw1kt4XgKLgBNKHd7KwA(Nk(PBP57YgBHwamzm)JBnw)1OIhj6zBoiLh8LAuOjrmQBeSpyXd(sDYJa3c4lgyn5PEqWFqWMIhS4bnarglQ(xIQruYCE6SOpaWBoEqkjCWGT0oxZTT0LmNNol6da8MJw1kZmkAdYsJTtYWHDslTZ1CBlD9xJgn6NYIwA(Nk(PBP57YgBHwamzm)JBnw)1OIhj6zBoiLh8LAuOjrmQBeSpyXd(sDYJa3c4lgyn5PEqWFqWMIwAo1Cggv)lr1yLzMvTQLg4J8LiPR2GSQLMVlBSfAJniRmZSbzPX2jz4WoPL25AUTLwYGXurIgl9an8pbQ52w6WBFqWkn4bPqks0e2bbRxn3(GEpoiv05PZmwA(Nk(PBP57YgBHwamzm)JBnw)1OIh9b1hmuOdY3Ln2cTayYy(h3AS(Rrfps0Z2CqkpyWu0Qwzc2gKLgBNKHd7KwA(Nk(PBPjLQvbWKX8pU1y9xJkKaEWIhKuQwfirGBb8JVuJXcOdCBHeqlTZ1CBlnWvZTTQvMaAdYsJTtYWHDsln)tf)0T0Ks1QayYy(h3AS(RrfsapyXdskvRcKiWTa(XxQXyb0bUTqcOL25AUTLMKT7iwLEQTQvgW2gKLgBNKHd7KwA(Nk(PBPjLQvbWKX8pU1y9xJkKaAPDUMBBPjX3GVSzxAvRmGZgKLgBNKHd7KwA(Nk(PBPL)GG5GKs1QayYy(h3AS(RrfsapyXd6CnbaJyJet0CqkjCWGpOChmuOdcMdskvRcGjJ5FCRX6Vgvib8GfpO8h8LAumWAYt9Gus4GG7Gfp4l1jpcClGVyG1KN6bPKWbdFkEq5S0oxZTT0(Z9gJaLyg0QwzcFBqwASDsgoStAP5FQ4NULMuQwfatgZ)4wJ1FnQqcOL25AUTLMLLGuteSIsJsIyRw1kdv2gKLgBNKHd7KwA(Nk(PBPjLQvbWKX8pU1y9xJkKaEWIhKuQwfirGBb8JVuJXcOdCBHeqlTZ1CBlT3C0OVZICNXSQvgWIniln2ojdh2jT08pv8t3stkvRcGjJ5FCRX6Vgv8irpBZbbpHdcwoyXdskvRcKiWTa(XxQXyb0bUTqcOL25AUTLUMpsY2DyvRmHhBqwASDsgoStAP5FQ4NULMuQwfatgZ)4wJ1FnQqc4blEqNRjayeBKyIMds4GZoyXdk)bjLQvbWKX8pU1y9xJkEKONT5GG)GG7GfpO6mSvbFzJii0FvGTtYWXbdf6GG5GQZWwf8LnIGq)vb2ojdhhS4bjLQvbWKX8pU1y9xJkEKONT5GG)Gb8GYzPDUMBBPj9Y4wJ6NCznw1kZmkAdYsJTtYWHDslTZ1CBlnse4wa)4l1ySa6a32spqd)tGAUTLoq7YgBH2yP5FQ4NULwDg2QyjzPIVR52cSDsgooyXdk)b57YgBHwamzm)JBnw)1OIh9b1hS4bFPgfAseJ6gb3bP8GL8XblEWxQtEe4waFXaRjp1dsjHdoJIhmuOdskvRcGjJ5FCRX6Vgvib8Gfp4l1OqtIyu3i4oiLhSKpoOChmuOdwZsqA8rIE2Mdc(dgmfTQvMzZSbzPX2jz4WoPLM)PIF6wA1zyRcYhDfuCRrt2J3lxJlW2jz44Gfp4l1jpcClGVyG1KN6bP8GGnfpyXd(snk0Kig1ncUds5bl5Jdw8GYFqsPAvq(ORGIBnAYE8E5ACHeWdgk0bRzjin(irpBZbb)bdMIhuolTZ1CBlnse4wa)4l1ySa6a32QwzMfSniln2ojdh2jT08pv8t3sRodBvKCK7afy7KmCCWIh8LA8GG)Gb0s7Cn32sJebUfWp(snglGoWTTQvMzb0gKLgBNKHd7KwA(Nk(PBPvNHTkiF0vqXTgnzpEVCnUaBNKHJdw8GYFq(USXwOfKp6kO4wJMShVxUgx8irpBZbdf6G8DzJTqliF0vqXTgnzpEVCnU4rFq9blEWxQtEe4waFXaRjp1dc(dg(u8GYzPDUMBBPbMmM)XTgR)AuRALzgyBdYsJTtYWHDsln)tf)0T0QZWwfjh5oqb2ojdhhS4bbZbjLQvbWKX8pU1y9xJkKaAPDUMBBPbMmM)XTgR)AuRALzg4SbzPX2jz4WoPLM)PIF6wA1zyRILKLk(UMBlW2jz44GfpO8huDg2QO0vq4NDz0O7tuGTtYWXblEqsPAv8iX9nidnMyHSv8fsapyOqhemhuDg2QO0vq4NDz0O7tuGTtYWXbLZs7Cn32sdmzm)JBnw)1Ow1kZSW3gKLgBNKHd7KwA(Nk(PBPjLQvbWKX8pU1y9xJkKaAPDUMBBPjF0vqXTgnzpEVCnUvTYmJkBdYsJTtYWHDsln)tf)0T0Ks1QayYy(h3AS(Rrfps0Z2CqWFWs(4GfpiPuTkaMmM)XTgR)AuHeWdw8GG5GQZWwfljlv8Dn3wGTtYWHL25AUTLU(Rrlq9t0eRsp1w1kZmWIniln2ojdh2jT08pv8t3s7CnbaJyJet0CqkjCWGpyXdk)bjLQvbWKX8pU1y9xJkKaEWIhKuQwfatgZ)4wJ1FnQ4rIE2Mdc(dwYhhmuOd(EoIiayRcFmmcmWPrnhS4bFphreaSvHpggXJe9Snhe8hSKpoyOqhSMLG04Je9Snhe8hSKpoOCwANR52w66VgTa1prtSk9uBvRmZcp2GS0y7KmCyN0sZ)uXpDlT6mSvXsYsfFxZTfy7KmCCWIhemhKuQwfatgZ)4wJ1FnQqc4blEq5pO8hKuQwfsnOLrD0Op2LkiHeWdgk0bbZbhORGIY2zjiv8snw3VefvNXWoYFjJpW)GYDWIhu(doqsPAv8ovTFYrHrDUShKWbb3bdf6GG5Gd0vqrz7SeKkEPgR7xII3PQ9toEq5oOCwANR52w66VgTa1prtSk9uBvRmbtrBqwASDsgoStAP5FQ4NULwDg2QG8rxbf3A0K949Y14cSDsgooyXd(sDYJa3c4lgyn5PEqkpiytXdw8GVuJhKschmGhS4bjLQvbWKX8pU1y9xJkKaEWqHoiyoO6mSvb5JUckU1Oj7X7LRXfy7KmCCWIh8L6KhbUfWxmWAYt9Gus4GbdolTZ1CBlniQbUki8jM8iWhnyZrRALj4z2GS0y7KmCyN0sZ)uXpDlnPuTkaMmM)XTgR)AuHeqlTZ1CBl97PbJd0hw1ktWbBdYsJTtYWHDsln)tf)0T0oxtaWi2iXenhKschm4dw8GYFqGOkkbTsmXJe9Snhe8hSKpoyOqhu9VevHMeXOUXrIhe8hSKpoOCwANR52wAJZ)SM80zrGoxTQvMGdOniln2ojdh2jT08pv8t3s7CnbaJyJet0Cqkpi4oyOqh8LASUFjkacc9FjUnAey7KmCyPDUMBBPhORGIEpIdK7uBvRAPhy1LyQniRmZSbzPDUMBBPjM9iwFePk0sJTtYWHDsRALjyBqwASDsgoStAPDUMBBPbTfyzxgjzUrT0d0W)eOMBBPPsabYO(GuG)A0dsbIaG)b9ECqIE2QN9bPqCQpyqoBBJLM)PIF6wAWCWXQI6VgnwraWxOjx2SlpyXdk)bvNHTksoYDGcSDsgooyOqhKVlBSfAb5JUckU1Oj7X7LRXfps0Z2Cqkp4mWDWqHoO6mSvXsYsfFxZTfy7KmCCWIhKVlBSfAbWKX8pU1y9xJkEKONT5GfpiyoiPuTkKnzSSlJeDoOSrHeWdkNvTYeqBqwASDsgoStAP5FQ4NULMuQwfjN6O6STnIhj6zBoi4jCWs(4GfpiPuTkso1r1zBBesapyXdAaImwu9VevJOK580zrFaG3C8Gus4GbFWIhu(dcMdQodBvq(ORGIBnAYE8E5ACb2ojdhhmuOdY3Ln2cTG8rxbf3A0K949Y14Ihj6zBoiLhCg4oOCwANR52w6sMZtNf9baEZrRALbSTbzPX2jz4WoPLM)PIF6wAsPAvKCQJQZ22iEKONT5GGNWbl5Jdw8GKs1Qi5uhvNTTrib8GfpO8hemhuDg2QG8rxbf3A0K949Y14cSDsgooyOqhKVlBSfAb5JUckU1Oj7X7LRXfps0Z2Cqkp4mWDq5S0oxZTT01FnA0OFklAvRmGZgKLgBNKHd7Kw6bA4FcuZTT0bc0Ug8GujUMBFqwA0dQ7bFP2s7Cn32sZDgl6Cn3oYsJAPzPrJTteT08faS9wnw1kt4BdYsJTtYWHDslTZ1CBln3zSOZ1C7ilnQLMLgn2or0sZ3Ln2cTXQwzOY2GS0y7KmCyN0sZ)uXpDlT6mSvbFzJii0FvGTtYWXblEqsPAvWx2icc9xfg15YEqkjCWzu8GfpO8hCGKs1Q4DQA)KJcJ6CzpiHdcUdgk0bbZbhORGIY2zjiv8snw3VefVtv7NC8GYzPDUMBBP5oJfDUMBhzPrT0S0OX2jIwA(YgrqO)QvTYawSbzPX2jz4WoPLM)PIF6wAsPAvq(ORGIBnAYE8E5ACHeqlTZ1CBl9l1rNR52rwAulnlnASDIOLMCnrn5YMDPvTYeESbzPX2jz4WoPLM)PIF6wA1zyRcYhDfuCRrt2J3lxJlW2jz44GfpO8hKVlBSfAb5JUckU1Oj7X7LRXfps0Z2CqWFWzu8GYzPDUMBBPFPo6Cn3oYsJAPzPrJTteT0KRjcCxw2Lw1kZmkAdYsJTtYWHDsln)tf)0T0Ks1QayYy(h3AS(RrfsapyXdQodBvSKSuX31CBb2ojdhwANR52w6xQJoxZTJS0OwAwA0y7erl9sYsfFxZTTQvMzZSbzPX2jz4WoPLM)PIF6wA1zyRILKLk(UMBlW2jz44GfpiFx2yl0cGjJ5FCRX6Vgv8irpBZbb)bNrrlTZ1CBl9l1rNR52rwAulnlnASDIOLEjzPIVR52rG7YYU0QwzMfSniln2ojdh2jT08pv8t3s7CnbaJyJet0CqkjCWGT0oxZTT0VuhDUMBhzPrT0S0OX2jIwAFrRALzwaTbzPX2jz4WoPL25AUTLM7mw05AUDKLg1sZsJgBNiAPnQ3d)hw1QwAY1e1KlB2L2GSYmZgKLgBNKHd7KwANR52w6LKLk(UIwAo1Cggv)lr1yLzMLM)PIF6w6xQtEe4waFXaRjp1dsjHdg(u0spqd)tGAUTLEYhDf0b36bPZE8E5A8dsL4AcaEqQ4QUMBBvRmbBdYsJTtYWHDsln)tf)0T0QZWwfLUcc)SlJgDFIcSDsgooyOqhKV9qkvbca(1FnQaBNKHJdgk0bFPgR7xIcYuZUmYx2qGTtYWXbdf6GoxtaWi2iXenhKschmylTZ1CBl9Je33Gm0yIfYwX3QwzcOniln2ojdh2jT08pv8t3stkvRIpjIcjGhS4bL)GVuN8iWTa(IbwtEQhe8heCG7GHcDWxQrHMeXOUXaEqWt4GL8Xbdf6GgGiJfv)lr1iaTfyzxgjzUrpiLeoyWhuolTZ1CBlnOTal7YijZnQvTYa22GS0y7KmCyN0s7Cn32sVKSuX3v0sZ)uXpDl9l1OqtIyu3iyFqWFWs(4GHcDWxQtEe4waFXaRjp1dsjHdc2GZsZPMZWO6FjQgRmZSQvgWzdYsJTtYWHDsln)tf)0T0Ks1Qq2KXYUms05GYgfsapyXdAaImwu9VevJO(RrnCQvq4bPKWbd(GfpO8hemhCGUck69ioqUtTqtUSzxEWIhKVaGT3QOZsqAS64bdf6GG5G8faS9wfDwcsJvhpOCwANR52w66Vg1WPwbHw1kt4BdYsJTtYWHDsln)tf)0T0VuN8iWTa(IbwtEQhKscheSP4blEWxQrHMeXOUXaEqkpyjFyPDUMBBPbTFh3ASq2k(w1kdv2gKLgBNKHd7KwA(Nk(PBPnarglQ(xIQru)1Ogo1ki8Gus4GbFWIhu(dskvRIb6kitCiHcJ6CzpiHdcwoyOqhemhCGUck69ioqUtTqtUSzxEWqHoiyoiFbaBVvrNLG0y1XdkNL25AUTLU(RrnCQvqOvTYawSbzPX2jz4WoPL25AUTLEjzPIVROLM)PIF6w6xQtEe4waFXaRjp1ds5bdgChS4bFPgpiLhmGwAo1Cggv)lr1yLzMvTYeESbzPX2jz4WoPLM)PIF6wAsPAv8jruib0s7Cn32sdAlWYUmsYCJAvRmZOOniln2ojdh2jT08pv8t3s)sDYJa3c4lgyn5PEqkpi4OOL25AUTL2FU3yu3)XwTQvT08faS9wn2GSYmZgKLgBNKHd7KwANR52w6b6kitCiHw6bA4FcuZTT0bAbaBV1dsLitwQjAS08pv8t3s)EoIiayRcFmmISpiLhCg4oyOqhemh89CeraWwf(yyeyGtJAoyOqh05AcagXgjMO5Gus4GbBvRmbBdYsJTtYWHDsln)tf)0T0oxtaWi2iXenhKWbNDWIh8L6KhbUfWxmWAYt9GuEWaEWIhKVlBSfAbWKX8pU1y9xJkEKONT5GG)Gb8GfpiyoO6mSvb5JUckU1Oj7X7LRXfy7KmCCWIhu(dcMd(EoIiayRcFmmcmWPrnhmuOd(EoIiayRcFmmISpiLhCg4oOCwANR52wAtb)jMDzKyAuRALjG2GS0y7KmCyN0sZ)uXpDlTZ1eamInsmrZbPKWbd(GfpiyoO6mSvb5JUckU1Oj7X7LRXfy7KmCyPDUMBBPnf8Ny2LrIPrTQvgW2gKLgBNKHd7KwA(Nk(PBPvNHTkiF0vqXTgnzpEVCnUaBNKHJdw8GYFqsPAvq(ORGIBnAYE8E5ACHeWdw8GYFqNRjayeBKyIMds4GZoyXd(sDYJa3c4lgyn5PEqkpiytXdgk0bDUMaGrSrIjAoiLeoyWhS4bFPo5rGBb8fdSM8upiLhm8P4bL7GHcDqWCqsPAvq(ORGIBnAYE8E5ACHeWdw8G8DzJTqliF0vqXTgnzpEVCnU4rIE2MdkNL25AUTL2uWFIzxgjMg1QwzaNniln2ojdh2jT08pv8t3s7CnbaJyJet0CqchC2blEq(USXwOfatgZ)4wJ1FnQ4rIE2Mdc(dgWdw8GYFqWCW3ZrebaBv4JHrGbonQ5GHcDW3ZrebaBv4JHrK9bP8GZa3bLZs7Cn32s7KlXSDn3oYsIKw1kt4BdYsJTtYWHDsln)tf)0T0oxtaWi2iXenhKschmylTZ1CBlTtUeZ21C7iljsAvRmuzBqwASDsgoStAP5FQ4NUL25AcagXgjMO5Geo4Sdw8G8DzJTqlaMmM)XTgR)AuXJe9Snhe8hmGhS4bL)GG5GVNJica2QWhdJadCAuZbdf6GVNJica2QWhdJi7ds5bNbUdkNL25AUTL2aY5YYWOccJsDH9vquBvRmGfBqwASDsgoStAP5FQ4NUL25AcagXgjMO5Gus4GbBPDUMBBPnGCUSmmQGWOuxyFfe1w1Qw1sda(MCBRmbtXGNrXzbd2w6c(3zxAS0uHujQOmuizOWdWbpyqGWdMebUVEW6(hC6sYsfFxZTJa3LLD50d(ivGu(44GMLiEqxsxIUIJdYb5DjAe38WLnEWzb4GbABaWxXXbNQodBva4Phu3dovDg2QaWcSDsgoMEq5Nfy5e38WLnEWzb4GbABaWxXXbN(snw3VefaE6b19GtFPgR7xIcalW2jz4y6bLFwGLtCZdx24bNfGdgOTbaFfhhCkF7HuQcap9G6EWP8ThsPkaSaBNKHJPhu(zbwoXn)MtfsLOIYqHKHcpah8Gbbcpyse4(6bR7FWP8LnIGq)1Ph8rQaP8XXbnlr8GUKUeDfhhKdY7s0iU5HlB8GZcWbd02aGVIJdovDg2QaWtpOUhCQ6mSvbGfy7KmCm9GYplWYjU5HlB8GbhGdgOTbaFfhhCQ6mSvbGNEqDp4u1zyRcalW2jz4y6bLFwGLtCZdx24bdyaoyG2ga8vCCWPQZWwfaE6b19GtvNHTkaSaBNKHJPhu(zbwoXnpCzJheSdWbd02aGVIJdovDg2QaWtpOUhCQ6mSvbGfy7KmCm9GYplWYjU53CQqQevugkKmu4b4Ghmiq4btIa3xpyD)doDjzPIVR52tp4Jubs5JJdAwI4bDjDj6kooihK3LOrCZdx24bNfGdgOTbaFfhhCQ6mSvbGNEqDp4u1zyRcalW2jz4y6bLFwGLtCZdx24bNfGdgOTbaFfhhC6l1yD)sua4Phu3do9LASUFjkaSaBNKHJPhu(zbwoXnpCzJhCwaoyG2ga8vCCWP8ThsPka80dQ7bNY3EiLQaWcSDsgoMEq5Nfy5e38WLnEWWpahmqBda(koo4u(2dPufaE6b19Gt5BpKsvayb2ojdhtpO8ZcSCIBE4Ygpy4jahmqBda(koo4u1zyRcap9G6EWPQZWwfawGTtYWX0dkFWbwoXn)MtfsLOIYqHKHcpah8Gbbcpyse4(6bR7FWPKRjQjx2SlNEWhPcKYhhh0SeXd6s6s0vCCqoiVlrJ4MhUSXdgCaoyG2ga8vCCWPQZWwfaE6b19GtvNHTkaSaBNKHJPhu(zbwoXnpCzJhm4aCWaTna4R44GtFPgR7xIcap9G6EWPVuJ19lrbGfy7KmCm9GYplWYjU5HlB8GbhGdgOTbaFfhhCkF7HuQcap9G6EWP8ThsPkaSaBNKHJPhu(zbwoXn)MtfsLOIYqHKHcpah8Gbbcpyse4(6bR7FWPg17H)JPh8rQaP8XXbnlr8GUKUeDfhhKdY7s0iU5HlB8GZcWbd02aGVIJdovDg2QaWtpOUhCQ6mSvbGfy7KmCm9GYplWYjU5HlB8GZcWbd02aGVIJdo9LASUFjka80dQ7bN(snw3VefawGTtYWX0d66bPWcVH7GYplWYjU5HlB8GZcWbd02aGVIJdoLV9qkvbGNEqDp4u(2dPufawGTtYWX0dk)SalN4MhUSXdgWaCWaTna4R44GtvNHTka80dQ7bNQodBvayb2ojdhtpORhKcl8gUdk)SalN4MhUSXdc2b4GbABaWxXXbNY3EiLQaWtpOUhCkF7HuQcalW2jz4y6bLp4alN4MhUSXdg(b4GbABaWxXXbNQodBva4Phu3dovDg2QaWcSDsgoMEq5Nfy5e38WLnEqQCaoyG2ga8vCCWPQZWwfaE6b19GtvNHTkaSaBNKHJPhu(zbwoXnpCzJheSeGdgOTbaFfhhCQ6mSvbGNEqDp4u1zyRcalW2jz4y6bLFwGLtCZV5uHujQOmuizOWdWbpyqGWdMebUVEW6(hCk5AIa3LLD50d(ivGu(44GMLiEqxsxIUIJdYb5DjAe38WLnEWGdWbd02aGVIJdovDg2QaWtpOUhCQ6mSvbGfy7KmCm9GYplWYjU5HlB8GbhGdgOTbaFfhhC6l1yD)sua4Phu3do9LASUFjkaSaBNKHJPhu(zbwoXnpCzJhm4aCWaTna4R44Gt5BpKsva4Phu3doLV9qkvbGfy7KmCm9GYplWYjU5HlB8GHFaoyG2ga8vCCWPQZWwfaE6b19GtvNHTkaSaBNKHJPhu(zbwoXnpCzJhKkhGdgOTbaFfhhCQ6mSvbGNEqDp4u1zyRcalW2jz4y6bLFwGLtCZdx24bblb4GbABaWxXXbNQodBva4Phu3dovDg2QaWcSDsgoMEq5Nfy5e38BovivIkkdfsgk8aCWdgei8GjrG7RhSU)bNY3Ln2cTz6bFKkqkFCCqZsepOlPlrxXXb5G8UenIBE4Ygp4mkgGdgOTbaFfhhCQ6mSvbGNEqDp4u1zyRcalW2jz4y6bLFwGLtCZdx24bNnlahmqBda(koo4u1zyRcap9G6EWPQZWwfawGTtYWX0dk)SalN4MhUSXdol4aCWaTna4R44GtvNHTka80dQ7bNQodBvayb2ojdhtpO8ZcSCIBE4Ygp4SagGdgOTbaFfhhCQ6mSvbGNEqDp4u1zyRcalW2jz4y6bLFwGLtCZdx24bNb2b4GbABaWxXXbNQodBva4Phu3dovDg2QaWcSDsgoMEq5Nfy5e38WLnEWzGlahmqBda(koo4u1zyRcap9G6EWPQZWwfawGTtYWX0dk)SalN4MhUSXdoJkhGdgOTbaFfhhCQ6mSvbGNEqDp4u1zyRcalW2jz4y6bD9GuyH3WDq5Nfy5e38WLnEWzHNaCWaTna4R44GtvNHTka80dQ7bNQodBvayb2ojdhtpO8ZcSCIBE4YgpyWumahmqBda(koo4u1zyRcap9G6EWPQZWwfawGTtYWX0dkFWbwoXnpCzJhm4agGdgOTbaFfhhC6l1yD)sua4Phu3do9LASUFjkaSaBNKHJPh01dsHfEd3bLFwGLtCZV5uHujQOmuizOWdWbpyqGWdMebUVEW6(hCkFbaBVvZ0d(ivGu(44GMLiEqxsxIUIJdYb5DjAe38WLnEWGdWbd02aGVIJdovDg2QaWtpOUhCQ6mSvbGfy7KmCm9GYplWYjU5HlB8GbmahmqBda(koo4u1zyRcap9G6EWPQZWwfawGTtYWX0d66bPWcVH7GYplWYjU5HlB8GGDaoyG2ga8vCCWPQZWwfaE6b19GtvNHTkaSaBNKHJPhu(zbwoXn)MtfsLOIYqHKHcpah8Gbbcpyse4(6bR7FWPdS6smD6bFKkqkFCCqZsepOlPlrxXXb5G8UenIBE4YgpyWb4GbABaWxXXbNQodBva4Phu3dovDg2QaWcSDsgoMEq5doWYjU5HlB8GbmahmqBda(koo4u1zyRcap9G6EWPQZWwfawGTtYWX0dk)SalN4MhUSXdc2b4GbABaWxXXbNQodBva4Phu3dovDg2QaWcSDsgoMEq5Nfy5e38WLnEqQCaoyG2ga8vCCWPQZWwfaE6b19GtvNHTkaSaBNKHJPhu(zbwoXnpCzJhm8eGdgOTbaFfhhCQ6mSvbGNEqDp4u1zyRcalW2jz4y6bLFwGLtCZdx24bNrXaCWaTna4R44GtvNHTka80dQ7bNQodBvayb2ojdhtpORhKcl8gUdk)SalN4MhUSXdoBwaoyG2ga8vCCWPQZWwfaE6b19GtvNHTkaSaBNKHJPhu(zbwoXn)MtfsLOIYqHKHcpah8Gbbcpyse4(6bR7FWP(Itp4Jubs5JJdAwI4bDjDj6kooihK3LOrCZdx24bdoahmqBda(koo4u1zyRcap9G6EWPQZWwfawGTtYWX0d66bPWcVH7GYplWYjU5HlB8GbmahmqBda(koo4u1zyRcap9G6EWPQZWwfawGTtYWX0d66bPWcVH7GYplWYjU5HlB8Gu5aCWaTna4R44GtvNHTka80dQ7bNQodBvayb2ojdhtpO8ZcSCIBE4YgpiyjahmqBda(koo4u1zyRcap9G6EWPQZWwfawGTtYWX0dk)SalN4MhUSXdoJIb4GbABaWxXXbNQodBva4Phu3dovDg2QaWcSDsgoMEq5Nfy5e38BofIiW9vCCWzu8GoxZTpilnQrCZT0a)TMm0st1u9bPaIUc6GGv3zji9GuG)A0Bovt1hCU3s(t9bdgCHDWGPyWZU53CQMQpyGa5DjAU5unvFqkahKkIexaWXbzUrPayq(2Jdkz8s8GB9GbcKNT5GB9GuioEq3CWup4yrtpvpiqMt9blGm2bZ(GaFNRjhf38Bovt1hKclWixsXXbraWN6dQjr8Gki8Gox3)GP5GoaEYCsgkU5oxZTneiM9iwFePk8Mt1hKkbeiJ6dsb(Rrpifica(h07Xbj6zRE2hKcXP(Gb5STn3CNR52MjiaiqBbw2LrsMB0WYkbWmwvu)1OXkca(cn5YMDzr5vNHTksoYDGHcX3Ln2cTG8rxbf3A0K949Y14Ihj6zBOCg4cfsDg2QyjzPIVR52f57YgBHwamzm)JBnw)1OIhj6zBkcgsPAviBYyzxgj6CqzJcjGYDZDUMBBMGaGkzopDw0ha4nhdlReiLQvrYPoQoBBJ4rIE2gWtOKpkskvRIKtDuD22gHeWIgGiJfv)lr1ikzopDw0ha4nhPKqWfLhmQZWwfKp6kO4wJMShVxUgpui(USXwOfKp6kO4wJMShVxUgx8irpBdLZaNC3CNR52MjiaO6VgnA0pLfdlReiLQvrYPoQoBBJ4rIE2gWtOKpkskvRIKtDuD22gHeWIYdg1zyRcYhDfuCRrt2J3lxJhkeFx2yl0cYhDfuCRrt2J3lxJlEKONTHYzGtUBovFWabAxdEqQexZTpiln6b19GVuFZDUMBBMGaG4oJfDUMBhzPrdRDIib(ca2ERMBUZ1CBZeeae3zSOZ1C7ilnAyTtejW3Ln2cT5M7Cn32mbbaXDgl6Cn3oYsJgw7erc8LnIGq)1WYkb1zyRc(YgrqO)ArsPAvWx2icc9xfg15YsjHzuSO8dKuQwfVtv7NCuyuNllbWfkeygORGIY2zjiv8snw3VefVtv7NCuUBUZ1CBZeea0l1rNR52rwA0WANisGCnrn5YMDzyzLaPuTkiF0vqXTgnzpEVCnUqc4n35AUTzcca6L6OZ1C7ilnAyTtejqUMiWDzzxgwwjOodBvq(ORGIBnAYE8E5A8IYZ3Ln2cTG8rxbf3A0K949Y14Ihj6zBa)mkk3n35AUTzcca6L6OZ1C7ilnAyTtejSKSuX31C7WYkbsPAvamzm)JBnw)1OcjGfvNHTkwswQ47AU9n35AUTzcca6L6OZ1C7ilnAyTtejSKSuX31C7iWDzzxgwwjOodBvSKSuX31C7I8DzJTqlaMmM)XTgR)AuXJe9SnGFgfV5oxZTntqaqVuhDUMBhzPrdRDIibFXWYkbNRjayeBKyIgkje8n35AUTzccaI7mw05AUDKLgnS2jIemQ3d)h38BovFqQ0sHDqQ4QUMBFZDUMBBe(IeEK4(gKHgtSq2k(3CNR52gHV4eeaujZ5PZI(aaV5yyzLG6mSvr9xJA4uRGWBUZ1CBJWxCccaQ(RrJg9tzXW4uZzyu9VevdHzHLvc8DzJTqlEK4(gKHgtSq2k(Ihj6zBapHGPGL8rr1zyRIsxbHF2LrJUpXBUZ1CBJWxCccac0wGLDzKK5gnSSsGuQwfFsefsaV5oxZTncFXjiaOLKLk(UIHLvcd0vqrVhXbYDQfAYLn7YI8faS9wfDwcsJvhlskvRIb6kitCiHcJ6CzPeSCZDUMBBe(Itqaq1FnQHtTccdlReiLQvHSjJLDzKOZbLnkE05Ar5bZaDfu07rCGCNAHMCzZUSiFbaBVvrNLG0y1XqHadFbaBVvrNLG0y1r5U5oxZTncFXjiaOsMZtNf9baEZXWYkHxQtEe4waFXaRjpvWl)mWnH6mSvXl1jp6QITKR52uWak3n35AUTr4lobbav)1OrJ(PSyyCQ5mmQ(xIQHWSWYkHxQtEe4waFXaRjpvWl)mWnH6mSvXl1jp6QITKR52uWak3n35AUTr4lobbav)1Ogo1kimSSsamd0vqrVhXbYDQfAYLn7YI8faS9wfDwcsJvhdfcm8faS9wfDwcsJvhV5oxZTncFXjiaOLKLk(UIHXPMZWO6FjQgcZclReEPo5rGBb8fdSM8uPu(Gb3eQZWwfVuN8ORk2sUMBtbdOC3CNR52gHV4eeaujZ5PZI(aaV54n35AUTr4lobbav)1OrJ(PSyyCQ5mmQ(xIQHWSBUZ1CBJWxCccac0(DCRXczR4FZDUMBBe(Itqaq(Z9gJ6(p26n)Mt1hCYhDf0b36bPZE8E5A8dcCxw2Lh8x11C7dgGdAu)vZbNrrZbjX6(4bNCPpyAoOdGNmNKH3CNR52gb5AIa3LLDjbqBbw2LrsMB0WYkbsPAv8jruib8M7Cn32iixte4USSlNGaGEK4(gKHgtSq2k(HLvcoxtaWi2iXenusi4qHEPgfAseJ6gbh4juYhfLxDg2QO0vq4NDz0O7tmui(2dPufia4x)1OHc9snw3VefKPMDzKVSHC3CQ(Gtv)lrnMvce9aha5hiPuTkENQ2p5OWOox2jMjhyfKFGKs1Q4DQA)KJIhj6zBMyMCuWb6kOOSDwcsfVuJ19lrX7u1(jhNEqQiceD1Cq)GSvd7GkO0CW0CWSvSh44G6Eq1)supOccpiOSeeA0dc8Z9tL6dInsK6dwivqh07d6KjlvQpOcY1dwizSd6abYO(GVtv7NC8Gz9GVuJ19lXH4GbbY1dsIzxEqVpi2irQpyHubDqkEqJ6CznHDW9pO3heBKi1hub56bvq4bhiPuTEWcjJDqZU9bXadmF8GBlU5oxZTncY1ebUll7YjiaOLKLk(UIHXPMZWO6FjQgcZclReEPo5rGBb8fdSM8uPKqWG7M7Cn32iixte4USSlNGaGkzopDw0ha4nhdlReEPo5rGBb8fdSM8ubFWuSObiYyr1)sunIsMZtNf9baEZrkjeCr(USXwOfatgZ)4wJ1FnQ4rIE2gkb3n35AUTrqUMiWDzzxobbav)1OrJ(PSyyCQ5mmQ(xIQHWSWYkHxQtEe4waFXaRjpvWhmflY3Ln2cTayYy(h3AS(Rrfps0Z2qj4U5oxZTncY1ebUll7YjiaO6Vg1WPwbHHLvcKs1Qq2KXYUms05GYgfp6CT4l1jpcClGVyG1KNkLYpdCtOodBv8sDYJUQyl5AUnfmGYv0aezSO6FjQgr9xJA4uRGqkjeCr5jLQvXaDfKjoKqHrDUSealHcbMb6kOO3J4a5o1cn5YMDzOqGHVaGT3QOZsqAS6OC3CNR52gb5AIa3LLD5eeau9xJA4uRGWWYkHxQtEe4waFXaRjpvkjiFab3eQZWwfVuN8ORk2sUMBtbdOCfnarglQ(xIQru)1Ogo1kiKscbxuEsPAvmqxbzIdjuyuNllbWsOqGzGUck69ioqUtTqtUSzxgkey4lay7Tk6SeKgRok3n35AUTrqUMiWDzzxobbaTKSuX3vmmo1Cggv)lr1qywyzLWl1jpcClGVyG1KNkLeKpGGBc1zyRIxQtE0vfBjxZTPGbuUBUZ1CBJGCnrG7YYUCccaQK580zrFaG3CmSSsGVlBSfAbWKX8pU1y9xJkEKONTHYxQrHMeXOUrWU4l1jpcClGVyG1KNk4bBkw0aezSO6FjQgrjZ5PZI(aaV5iLec(M7Cn32iixte4USSlNGaGQ)A0Or)uwmmo1Cggv)lr1qywyzLaFx2yl0cGjJ5FCRX6Vgv8irpBdLVuJcnjIrDJGDXxQtEe4waFXaRjpvWd2u8MFZP6do5JUc6GB9G0zpEVCn(bPsCnbapivCvxZTV5oxZTncY1e1KlB2LewswQ47kggNAodJQ)LOAimlSSs4L6KhbUfWxmWAYtLscHpfV5oxZTncY1e1KlB2LtqaqpsCFdYqJjwiBf)WYkb1zyRIsxbHF2LrJUpXqH4BpKsvGaGF9xJgk0l1yD)suqMA2Lr(YgHc5CnbaJyJet0qjHGV5oxZTncY1e1KlB2LtqaqG2cSSlJKm3OHLvcKs1Q4tIOqcyr5FPo5rGBb8fdSM8ubp4axOqVuJcnjIrDJbe8ek5JqHmarglQ(xIQraAlWYUmsYCJsjHGL7M7Cn32iixtutUSzxobbaTKSuX3vmmo1Cggv)lr1qywyzLWl1OqtIyu3iyd(s(iuOxQtEe4waFXaRjpvkja2G7M7Cn32iixtutUSzxobbav)1Ogo1kimSSsGuQwfYMmw2LrIohu2OqcyrdqKXIQ)LOAe1FnQHtTccPKqWfLhmd0vqrVhXbYDQfAYLn7YI8faS9wfDwcsJvhdfcm8faS9wfDwcsJvhL7M7Cn32iixtutUSzxobbabA)oU1yHSv8dlReEPo5rGBb8fdSM8uPKaytXIVuJcnjIrDJbKYs(4M7Cn32iixtutUSzxobbav)1Ogo1kimSSsWaezSO6FjQgr9xJA4uRGqkjeCr5jLQvXaDfKjoKqHrDUSealHcbMb6kOO3J4a5o1cn5YMDzOqGHVaGT3QOZsqAS6OC3CNR52gb5AIAYLn7YjiaOLKLk(UIHXPMZWO6FjQgcZclReEPo5rGBb8fdSM8uPmyWv8LAKYaEZDUMBBeKRjQjx2SlNGaGaTfyzxgjzUrdlReiLQvXNerHeWBUZ1CBJGCnrn5YMD5eeaK)CVXOU)JTgwwj8sDYJa3c4lgyn5Psj4O4n)Mt1u9bd0YgheSk0F9GbA7rQ52MBovt1h05AUTrWx2icc9xjWb5zBIBnMCmSSsOMLG04Je9SnGVKpU5u9bbR0GhCi9zxEqW6KX8)Gfsf0bPqCK7ab0Kp6kOBUZ1CBJGVSree6VobbaXb5zBIBnMCmSSsamQZWwfljlv8Dn3UiPuTkaMmM)XTgR)AuXJe9SnGpGfjLQvbWKX8pU1y9xJkKawKuQwf8LnIGq)vHrDUSusygfV5u9bdVsQjh4b36bbRtgZ)dkzqVepyHubDqkeh5oqan5JUc6M7Cn32i4lBebH(RtqaqCqE2M4wJjhdlReaJ6mSvXsYsfFxZTloqxbfLTZsqQ4LASUFjkQoJHDK)sgFGFrWqkvRcGjJ5FCRX6VgvibSO8Ks1QGVSree6VkmQZLLscZc)IKs1QqQbTmQJg9XUubjKagkePuTk4lBebH(RcJ6CzPKWSWtr(USXwOfatgZ)4wJ1FnQ4rIE2gkNrr5U5oxZTnc(YgrqO)6eeaehKNTjU1yYXWYkbWOodBvSKSuX31C7IGzGUckkBNLGuXl1yD)suuDgd7i)Lm(a)IKs1QGVSree6VkmQZLLscZOyrWqkvRcGjJ5FCRX6VgvibSiFx2yl0cGjJ5FCRX6Vgv8irpBdLbtXBovFqW6hbaB9GbAzJdcwf6VEWfa85oqGzxEWH0ND5bbMmM)3CNR52gbFzJii0FDccaIdYZ2e3Am5yyzLG6mSvXsYsfFxZTlcgsPAvamzm)JBnw)1OcjGfLNuQwf8LnIGq)vHrDUSusyw4xKuQwfsnOLrD0Op2LkiHeWqHiLQvbFzJii0FvyuNllLeMfEcfIVlBSfAbWKX8pU1y9xJkEKONTb8bSiPuTk4lBebH(RcJ6CzPKWmWwUB(nNQpy4TpiyLg8GuifjAc7GG1RMBFqVhhKk680zMBUZ1CBJGVlBSfAdbjdgtfjAclRe47YgBHwamzm)JBnw)1OIh9b1HcX3Ln2cTayYy(h3AS(Rrfps0Z2qzWu8M7Cn32i47YgBH2mbbabC1C7WYkbsPAvamzm)JBnw)1OcjGfjLQvbse4wa)4l1ySa6a3wib8M7Cn32i47YgBH2mbbarY2DeRsp1HLvcKs1QayYy(h3AS(RrfsalskvRcKiWTa(XxQXyb0bUTqc4n35AUTrW3Ln2cTzccaIeFd(YMDzyzLaPuTkaMmM)XTgR)AuHeWBUZ1CBJGVlBSfAZeeaK)CVXiqjMbdlReKhmKs1QayYy(h3AS(Rrfsal6CnbaJyJet0qjHGLluiWqkvRcGjJ5FCRX6VgvibSO8VuJIbwtEQusaCfFPo5rGBb8fdSM8uPKq4tr5U5oxZTnc(USXwOntqaqSSeKAIGvuAuseBnSSsGuQwfatgZ)4wJ1FnQqc4n35AUTrW3Ln2cTzccaYBoA03zrUZyHLvcKs1QayYy(h3AS(RrfsalskvRcKiWTa(XxQXyb0bUTqc4n35AUTrW3Ln2cTzccaQMpsY2DewwjqkvRcGjJ5FCRX6Vgv8irpBd4jawkskvRcKiWTa(XxQXyb0bUTqc4n35AUTrW3Ln2cTzccaI0lJBnQFYL1ewwjqkvRcGjJ5FCRX6VgvibSOZ1eamInsmrdHzfLNuQwfatgZ)4wJ1FnQ4rIE2gWdUIQZWwf8LnIGq)vb2ojdhHcbg1zyRc(YgrqO)QaBNKHJIKs1QayYy(h3AS(Rrfps0Z2a(ak3nNQpyG2Ln2cT5M7Cn32i47YgBH2mbbaHebUfWp(snglGoWTdlReuNHTkwswQ47AUDr557YgBHwamzm)JBnw)1OIh9b1fFPgfAseJ6gbhLL8rXxQtEe4waFXaRjpvkjmJIHcrkvRcGjJ5FCRX6VgvibS4l1OqtIyu3i4OSKpKluOAwcsJps0Z2a(GP4n35AUTrW3Ln2cTzccacjcClGF8LAmwaDGBhwwjOodBvq(ORGIBnAYE8E5A8IVuN8iWTa(IbwtEQuc2uS4l1OqtIyu3i4OSKpkkpPuTkiF0vqXTgnzpEVCnUqcyOq1SeKgFKONTb8btr5U5oxZTnc(USXwOntqaqirGBb8JVuJXcOdC7WYkb1zyRIKJChyXxQrWhWBUZ1CBJGVlBSfAZeeaeWKX8pU1y9xJgwwjOodBvq(ORGIBnAYE8E5A8IYZ3Ln2cTG8rxbf3A0K949Y14Ihj6zBcfIVlBSfAb5JUckU1Oj7X7LRXfp6dQl(sDYJa3c4lgyn5Pc(WNIYDZDUMBBe8DzJTqBMGaGaMmM)XTgR)A0WYkb1zyRIKJChyrWqkvRcGjJ5FCRX6Vgvib8M7Cn32i47YgBH2mbbabmzm)JBnw)1OHLvcQZWwfljlv8Dn3UO8QZWwfLUcc)SlJgDFIcSDsgokskvRIhjUVbzOXelKTIVqcyOqGrDg2QO0vq4NDz0O7tuGTtYWHC3CNR52gbFx2yl0MjiaiYhDfuCRrt2J3lxJhwwjqkvRcGjJ5FCRX6Vgvib8M7Cn32i47YgBH2mbbav)1OfO(jAIvPN6WYkbsPAvamzm)JBnw)1OIhj6zBaFjFuKuQwfatgZ)4wJ1FnQqcyrWOodBvSKSuX31C7BUZ1CBJGVlBSfAZeeau9xJwG6NOjwLEQdlReCUMaGrSrIjAOKqWfLNuQwfatgZ)4wJ1FnQqcyrsPAvamzm)JBnw)1OIhj6zBaFjFek075iIaGTk8XWiWaNg1u89CeraWwf(yyeps0Z2a(s(iuOAwcsJps0Z2a(s(qUBUZ1CBJGVlBSfAZeeau9xJwG6NOjwLEQdlReuNHTkwswQ47AUDrWqkvRcGjJ5FCRX6VgvibSO8YtkvRcPg0YOoA0h7sfKqcyOqGzGUckkBNLGuXl1yD)suuDgd7i)Lm(aF5kk)ajLQvX7u1(jhfg15YsaCHcbMb6kOOSDwcsfVuJ19lrX7u1(jhLtUBUZ1CBJGVlBSfAZeeaeiQbUki8jM8iWhnyZXWYkb1zyRcYhDfuCRrt2J3lxJx8L6KhbUfWxmWAYtLsWMIfFPgPKqalskvRcGjJ5FCRX6VgvibmuiWOodBvq(ORGIBnAYE8E5A8IVuN8iWTa(IbwtEQusiyWDZDUMBBe8DzJTqBMGaGEpnyCG(iSSsGuQwfatgZ)4wJ1FnQqc4n35AUTrW3Ln2cTzccaY48pRjpDweOZ1WYkbNRjayeBKyIgkjeCr5bIQOe0kXeps0Z2a(s(iui1)sufAseJ6ghjc(s(qUBUZ1CBJGVlBSfAZeea0aDfu07rCGCN6WYkbNRjayeBKyIgkbxOqVuJ19lrbqqO)lXTrZn)Mt1hmqlay7TEqQezYsnrZn35AUTrWxaW2B1qyGUcYehsyyzLW75iIaGTk8XWiYMYzGluiW8EoIiayRcFmmcmWPrnHc5CnbaJyJet0qjHGV5oxZTnc(ca2ERMjiaitb)jMDzKyA0WYkbNRjayeBKyIgcZk(sDYJa3c4lgyn5PszalY3Ln2cTayYy(h3AS(Rrfps0Z2a(awemQZWwfKp6kO4wJMShVxUgVO8G59CeraWwf(yyeyGtJAcf69CeraWwf(yyezt5mWj3n35AUTrWxaW2B1mbbazk4pXSlJetJgwwj4CnbaJyJet0qjHGlcg1zyRcYhDfuCRrt2J3lxJFZDUMBBe8faS9wntqaqMc(tm7YiX0OHLvcQZWwfKp6kO4wJMShVxUgVO8Ks1QG8rxbf3A0K949Y14cjGfL35AcagXgjMOHWSIVuN8iWTa(IbwtEQuc2umuiNRjayeBKyIgkjeCXxQtEe4waFXaRjpvkdFkkxOqGHuQwfKp6kO4wJMShVxUgxibSiFx2yl0cYhDfuCRrt2J3lxJlEKONTrUBUZ1CBJGVaGT3QzccaYjxIz7AUDKLejdlReCUMaGrSrIjAimRiFx2yl0cGjJ5FCRX6Vgv8irpBd4dyr5bZ75iIaGTk8XWiWaNg1ek075iIaGTk8XWiYMYzGtUBUZ1CBJGVaGT3QzccaYjxIz7AUDKLejdlReCUMaGrSrIjAOKqW3CNR52gbFbaBVvZeeaKbKZLLHrfegL6c7RGOoSSsW5AcagXgjMOHWSI8DzJTqlaMmM)XTgR)AuXJe9SnGpGfLhmVNJica2QWhdJadCAutOqVNJica2QWhdJiBkNbo5U5oxZTnc(ca2ERMjiaidiNlldJkimk1f2xbrDyzLGZ1eamInsmrdLec(MFZP6dgEjzPIVR52h8x11C7BUZ1CBJyjzPIVR52eEK4(gKHgtSq2k(HLvcoxtaWi2iXenusiGfLxDg2QO0vq4NDz0O7tmui(2dPufia4x)1OHc9snw3VefKPMDzKVSHC3CNR52gXsYsfFxZTNGaGaTfyzxgjzUrdlReaZyvr9xJgRia4l0KlB2LfbdPuTkKnzSSlJeDoOSrHeWBUZ1CBJyjzPIVR52tqaq1FnQHtTccdlReiLQvHSjJLDzKOZbLnkE05ArdqKXIQ)LOAe1FnQHtTccPKqWfLNuQwfd0vqM4qcfg15YsaSekeygORGIEpIdK7ul0KlB2LHcbg(ca2ERIolbPXQJYDZDUMBBeljlv8Dn3EccaAjzPIVRyyCQ5mmQ(xIQHWSWYkbsPAviBYyzxgj6CqzJIhDUgkeyiLQvXNerHeWIgGiJfv)lr1iaTfyzxgjzUrPKqaV5oxZTnILKLk(UMBpbbavYCE6SOpaWBogwwjyaImwu9VevJOK580zrFaG3CKscbxu(xQtEe4waFXaRjpvWpJIHc9snk0Kig1ngmLL8HCHcj)ajLQvX7u1(jhfg15YcEWfk0ajLQvX7u1(jhfps0Z2a(zGtUBUZ1CBJyjzPIVR52tqaq1FnA0OFklgwwjW3EiLQaFFKCxZUmsY2cfjLQvb((i5UMDzKKTfeg15Ysi4IoxtaWi2iXeneMDZDUMBBeljlv8Dn3Eccac0wGLDzKK5gnSSsGuQwfFsefsalAaImwu9VevJa0wGLDzKK5gLscbFZDUMBBeljlv8Dn3EccaQK580zrFaG3CmSSsWaezSO6FjQgrjZ5PZI(aaV5iLec(M7Cn32iwswQ47AU9eeau9xJgn6NYIHXPMZWO6FjQgcZclReaJ6mSvHdGZ8MdclcgsPAviBYyzxgj6CqzJcjGHcPodBv4a4mV5GWIGHuQwfFsefsaV5oxZTnILKLk(UMBpbbabAlWYUmsYCJgwwjqkvRIpjIcjG3CNR52gXsYsfFxZTNGaGwswQ47kggNAodJQ)LOAim7MFZP6dcwVll7YdsbU)bdVKSuX31C7aCqA1F1CWzu8GgKV9WCqsSUpEqW6KX8)GB9GuG)A0dYxIO5GBTEWarb8M7Cn32iwswQ47AUDe4USSlj8iX9nidnMyHSv8dlReuNHTkkDfe(zxgn6(edfIV9qkvbca(1FnAOqVuJ19lrbzQzxg5lBekKZ1eamInsmrdLec(M7Cn32iwswQ47AUDe4USSlNGaGaTfyzxgjzUrdlReiLQvXNerHeWBUZ1CBJyjzPIVR52rG7YYUCccaAjzPIVRyyCQ5mmQ(xIQHWSWYkbsPAviBYyzxgj6CqzJIhDUEZDUMBBeljlv8Dn3ocCxw2LtqaqLmNNol6da8MJHLvcgGiJfv)lr1ikzopDw0ha4nhPKqWfFPo5rGBb8fdSM8ubF4tXBUZ1CBJyjzPIVR52rG7YYUCccaQ(RrJg9tzXW4uZzyu9VevdHzHLvcVuN8iWTa(IbwtEQGNktXBUZ1CBJyjzPIVR52rG7YYUCccaAjzPIVRyyCQ5mmQ(xIQHWSWYkHxQrkb7BUZ1CBJyjzPIVR52rG7YYUCccaQ(RrnCQvqyyzLGZ1eamInsmrdLea7IYdMb6kOO3J4a5o1cn5YMDzr(ca2ERIolbPXQJHcbg(ca2ERIolbPXQJYDZV5u9bPvVh(poOj7sgsbq9Ve1d(R6AU9n35AUTryuVh(pi8iX9nidnMyHSv8dlReuNHTkkDfe(zxgn6(edfIV9qkvbca(1FnAOqVuJ19lrbzQzxg5lBCZDUMBBeg17H)JjiaOsMZtNf9baEZXWYkbWmqxbfLTZsqQ4LASUFjkENQ2p5yr5hiPuTkENQ2p5OWOoxwWdUqHgiPuTkENQ2p5O4rIE2gWtLL7M7Cn32imQ3d)htqaq1FnA0OFklgwwjW3Ln2cT4rI7BqgAmXczR4lEKONTb8ecMcwYhfvNHTkkDfe(zxgn6(eV5oxZTncJ69W)Xeeau9xJgn6NYIHLvc8ThsPkW3hj31SlJKSTqrsPAvGVpsURzxgjzBbHrDUSecoui(2dPufsndDdiCeRp2uf1fjLQvHuZq3achX6JnvrT4rIE2gWhWIKs1QqQzOBaHJy9XMQOwib8M7Cn32imQ3d)htqaqG2cSSlJKm3OHLvcKs1Q4tIOqc4n35AUTryuVh(pMGaGwswQ47kgwwjagsPAvu)LQWocuIzqHeWIQZWwf1FPkSJaLygmuisPAviBYyzxgj6CqzJIhDUgk0aDfu07rCGCNAHMCzZUSiFbaBVvrNLG0y1XIKs1QyGUcYehsOWOoxwkblHc9snk0Kig1nc2GNqjFCZDUMBBeg17H)JjiaO6VgnA0pLfdlReEPo5rGBb8fdSM8ubV8Za3eQZWwfVuN8ORk2sUMBtbdOC3CNR52gHr9E4)yccaAjzPIVRyyzLWl1jpcClGVyG1KNkLYhm4MqDg2Q4L6KhDvXwY1CBkyaL7M7Cn32imQ3d)htqaq1FnA0OFklEZDUMBBeg17H)Jjiaiq73XTglKTI)n35AUTryuVh(pMGaG8N7ng19FSvlTbiYTYem4MzvRATa]] )

end
