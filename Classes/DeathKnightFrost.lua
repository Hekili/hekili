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

        -- Reset CDs on any Rune abilities that do not have an actual cooldown.
        for action in pairs( class.abilityList ) do
            local data = class.abilities[ action ]
            if data.cooldown == 0 and data.spendType == "runes" then
                setCooldown( action, 0 )
            end
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


    spec:RegisterPack( "Frost DK", 20210314, [[d8usCcqiaYJqiCjesQnrP6tkQgfj4uiQwfcjELIKzrIClGcv7cv)cGAyikoMIYYOK6zuk10ak6Aiu2gqbFdrPmoeI6CiKK1rPK5Hq19qW(irDqes1cvK6HsfmreLuDreIyJsfjFerjzKafkDseszLa4LikPyMsf1nbku0oPK8tGczOsfPwkIs8usAQukUkIsk9veI0ybkTxb)vObd6WuTyu8ysnzfUm0MLYNLQgnqoTOvduOWRbQMns3gr2TKFRYWb0XruQwUQEoftN46O02veFxQ04Lk05jHwVurmFkX(v6WSGnb1HlyWkRjJ1ZiJTNbMCRjdysmYqKdQIIaXGkqxdU3Jb1YjHb1o1FgzHK1jRjOc0vKE(iytq1CSVgdQGebOXwagW9PaILHRpsa2KKyPUKxPFVja2KK0aoOYWMuHOvbMG6WfmyL1KX6zKX2ZatU1KbmbtIr2cQoRa6(GQAsQdbvq5yGvGjOoqJoOswhDb0cjRPYEqYc7u)zKfaWy6Vg0cNbMkTqRjJ1Zwawa6aiV6rZcay8fswqs3eCSqQBeW4guF1yHSgVhx41wyha5zzw41wirtJl0nlmLfoo0uZLfcK6kUWUiLUWSwiW31sQrEqLMgXeSjOEm0uW3L8QiW7Oz1hSjy1SGnbvSCgkocthuDTKxfuFK09gKIgtSBwc(b1bA0FcuYRcQD67Oz1VWo19lemIHMc(UKxzRfQk(lMfoJml0G6RgMfYGT7Xf2Ptk1)fETf2P(ZiluFKqZcVwBHDGSEqv)PGF6bvXPyj8ExaHFw9rJCpjowodfhl0ILfQVAWMchNGF7pJWXYzO4yHwSSWNTW299iNjLS6J6Jo4y5muCSqlwwORLCcgXcjLOzHktyHwhKGvwhSjOILZqXry6GQ(tb)0dQmSTg)tsiNfyq11sEvqf01LMvFKH6gjibRSDWMGkwodfhHPdQUwYRcQhdnf8DbdQ6pf8tpOYW2ACWtknR(ijxdklK)ORLGQwrnfJI)9OycwnlibRaZGnbvSCgkocthu1Fk4NEq1aeP0O4FpkgEp11PtJ(yIxACHktyHwVq7l8zRuhbEDXNpWwQtzHeFHGbYeuDTKxfu7PUoDA0ht8sJbjyfXc2euXYzO4imDq11sEvqT9NrIg5tWXGQ(tb)0dQpBL6iWRl(8b2sDklK4lKSrMGQwrnfJI)9OycwnlibRadbBcQy5muCeMoO6AjVkOEm0uW3fmOQ)uWp9G6Zw4cvEHGzqvROMIrX)EumbRMfKGvKTGnbvSCgkocthu1Fk4NEq11sobJyHKs0SqLjSqWCH2xOcleqlCGUak61ioqTRixsn4z1Vq7luFtWYlHxzpij2CCHwSSqaTq9nblVeEL9GKyZXfsEq11sEvqT9NrmAffqyqcsqvF0ree6VeSjy1SGnbvSCgkocthuDTKxfu1G8SmXRftnguhOr)jqjVkOswRbx4G9ZQFHD6Ks9FHDtb0cjAAu7ab80p6cOGQ(tb)0dQaAHItXs4hdnf8DjVIJLZqXXcTVqg2wJdmPu)Jxl2(Zi8hj5zzwiXxOTxO9fYW2ACGjL6F8AX2FgHZcCH2xidBRX1hDebH(lCJ4AWxOYew4mYeKGvwhSjOILZqXry6GQRL8QGQgKNLjETyQXG6an6pbk5vbvWiwXKdCHxBHD6Ks9FHSg07Xf2nfqlKOPrTdeWt)OlGcQ6pf8tpOcOfkoflHFm0uW3L8kowodfhl0(chOlGIGxzpiH)Sf2UVh5nNsXkQFwJpWFH2xiGwidBRXbMuQ)XRfB)zeolWfAFHkSqg2wJRp6icc9x4gX1GVqLjSWzGHfAFHmSTgNTaDufJg5XQxaXzbUqlwwidBRX1hDebH(lCJ4AWxOYew4mIQfAFH67OJRBXbMuQ)XRfB)ze(JK8Smlu5foJmlK8GeSY2bBcQy5muCeMoOQ)uWp9GkGwO4uSe(XqtbFxYR4y5muCSq7leqlCGUakcEL9Ge(Zwy7(EK3CkfRO(zn(a)fAFHmSTgxF0ree6VWnIRbFHktyHZiZcTVqaTqg2wJdmPu)Jxl2(ZiCwGl0(c13rhx3IdmPu)Jxl2(Zi8hj5zzwOYl0AYeuDTKxfu1G8SmXRftngKGvGzWMGkwodfhHPdQUwYRcQAqEwM41IPgdQd0O)eOKxfu70poblzHD4OJfcgl6VSWBc(AhiWS6x4G9ZQFHatk1)GQ(tb)0dQItXs4hdnf8DjVIJLZqXXcTVqaTqg2wJdmPu)Jxl2(ZiCwGl0(cvyHmSTgxF0ree6VWnIRbFHktyHZadl0(czyBnoBb6OkgnYJvVaIZcCHwSSqg2wJRp6icc9x4gX1GVqLjSWzevl0ILfQVJoUUfhysP(hVwS9Nr4psYZYSqIVqBVq7lKHT146JoIGq)fUrCn4luzclCgyUqYdsqcQhdnf8DjVkytWQzbBcQy5muCeMoO6AjVkO(iP7nifnMy3Se8dQd0O)eOKxfubJyOPGVl5vl8pXL8QGQ(tb)0dQUwYjyelKuIMfQmHfA7fAFHkSqXPyj8ExaHFw9rJCpjowodfhl0ILfQVAWMchNGF7pJWXYzO4yHwSSWNTW299iNjLS6J6Jo4y5muCSqYdsWkRd2euXYzO4imDqv)PGF6bvaTWXj82Fgj2Wj4ZLudEw9l0(cb0czyBno4jLMvFKKRbLfYzbguDTKxfubDDPz1hzOUrcsWkBhSjOILZqXry6GQ(tb)0dQmSTgh8KsZQpsY1GYc5p6AzH2xObisPrX)Eum82FgXOvuaHluzcl06fAFHkSqg2wJpqxazIdwKBexd(cjSqI8cTyzHaAHd0fqrVgXbQDf5sQbpR(fAXYcb0c13eS8s4v2dsInhxi5bvxl5vb12FgXOvuaHbjyfygSjOILZqXry6GQRL8QG6XqtbFxWGQ(tb)0dQmSTgh8KsZQpsY1GYc5p6AzHwSSqaTqg2wJ)jjKZcCH2xObisPrX)EumCqxxAw9rgQBKfQmHfA7GQwrnfJI)9OycwnlibRiwWMGkwodfhHPdQ6pf8tpOAaIuAu8VhfdVN660PrFmXlnUqLjSqRxO9fQWcF2k1rGxx85dSL6uwiXx4mYSqlww4ZwixssyuUO1lu5f2RhlK8fAXYcvyHdKHT14V3j3NAKBexd(cj(cj2cTyzHdKHT14V3j3NAK)ijplZcj(cNrSfsEq11sEvqTN660PrFmXlngKGvGHGnbvSCgkocthu1Fk4NEqvF1Gnfo((i1UKvFKHED5y5muCSq7lKHT1447Ju7sw9rg61LBexd(cjSqRxO9f6AjNGrSqsjAwiHfolO6AjVkO2(ZirJ8j4yqcwr2c2euXYzO4imDqv)PGF6bvg2wJ)jjKZcCH2xObisPrX)EumCqxxAw9rgQBKfQmHfADq11sEvqf01LMvFKH6gjibRiYbBcQy5muCeMoOQ)uWp9GQbisPrX)Eum8EQRtNg9XeV04cvMWcToO6AjVkO2tDD60OpM4LgdsWkIQGnbvSCgkocthuDTKxfuB)zKOr(eCmOQ)uWp9GkGwO4uSeUpXPEPbHCSCgkowO9fcOfYW2ACWtknR(ijxdklKZcCHwSSqXPyjCFIt9sdc5y5muCSq7leqlKHT14Fsc5SadQAf1umk(3JIjy1SGeSAgzc2euXYzO4imDqv)PGF6bvg2wJ)jjKZcmO6AjVkOc66sZQpYqDJeKGvZMfSjOILZqXry6GQRL8QG6XqtbFxWGQwrnfJI)9OycwnlibjOYCMOKAWZQpytWQzbBcQy5muCeMoO6AjVkOEm0uW3fmOQvutXO4FpkMGvZcQ6pf8tpO(SvQJaVU4Zhyl1PSqLjSqWazcQd0O)eOKxfuN(rxaTWRTq1SgV3FgFHeDTKtWfswoXL8QGeSY6GnbvSCgkocthu1Fk4NEqvCkwcV3fq4NvF0i3tIJLZqXXcTyzH6RgSPWXj43(ZiCSCgkowOfll8zlSDFpYzsjR(O(Odowodfhl0ILf6AjNGrSqsjAwOYewO1bvxl5vb1hjDVbPOXe7MLGFqcwz7GnbvSCgkocthu1Fk4NEqLHT14Fsc5SaxO9fQWcF2k1rGxx85dSL6uwiXxiXi2cTyzHpBHCjjHr5I2EHeNWc71JfAXYcnarknk(3JIHd66sZQpYqDJSqLjSqRxi5bvxl5vbvqxxAw9rgQBKGeScmd2euXYzO4imDq11sEvq9yOPGVlyqv)PGF6b1NTqUKKWOCrWCHeFH96XcTyzHpBL6iWRl(8b2sDkluzclemjwqvROMIrX)EumbRMfKGvelytqflNHIJW0bv9Nc(PhuzyBno4jLMvFKKRbLfYzbUq7l0aeP0O4FpkgE7pJy0kkGWfQmHfA9cTVqfwiGw4aDbu0RrCGAxrUKAWZQFH2xO(MGLxcVYEqsS54cTyzHaAH6BcwEj8k7bjXMJlK8GQRL8QGA7pJy0kkGWGeScmeSjOILZqXry6GQ(tb)0dQpBL6iWRl(8b2sDkluzclemjZcTVWNTqUKKWOCrBVqLxyVEeuDTKxfubDFfVwSBwc(bjyfzlytqflNHIJW0bv9Nc(Phunarknk(3JIH3(ZigTIciCHktyHwVq7luHfYW2A8b6citCWICJ4AWxiHfsKxOflleqlCGUak61ioqTRixsn4z1VqlwwiGwO(MGLxcVYEqsS54cjpO6AjVkO2(ZigTIcimibRiYbBcQy5muCeMoO6AjVkOEm0uW3fmOQ)uWp9G6ZwPoc86IpFGTuNYcvEHwtSfAFHpBHlu5fA7GQwrnfJI)9OycwnlibRiQc2euXYzO4imDqv)PGF6bvg2wJ)jjKZcmO6AjVkOc66sZQpYqDJeKGvZitWMGkwodfhHPdQ6pf8tpO(SvQJaVU4Zhyl1PSqLxiXitq11sEvq1FTxyuU)XscsqcQgXRH)JGnbRMfSjOILZqXry6GQRL8QG6JKU3Gu0yIDZsWpOoqJ(tGsEvqvv8A4)yHMS6PiyCX)Euw4FIl5vbv9Nc(PhufNILW7Dbe(z1hnY9K4y5muCSqlwwO(QbBkCCc(T)mchlNHIJfAXYcF2cB33JCMuYQpQp6GJLZqXrqcwzDWMGkwodfhHPdQ6pf8tpOcOfoqxafbVYEqc)zlSDFpYFVtUp14cTVqfw4azyBn(7DY9Pg5gX1GVqIVqITqlww4azyBn(7DY9Pg5psYZYSqIVqY2cjpO6AjVkO2tDD60OpM4LgdsWkBhSjOILZqXry6GQ(tb)0dQ67OJRBXFK09gKIgtSBwc(8hj5zzwiXjSqRxirzH96XcTVqXPyj8ExaHFw9rJCpjowodfhbvxl5vb12FgjAKpbhdsWkWmytqflNHIJW0bv9Nc(Phu1xnytHJVpsTlz1hzOxxowodfhl0(czyBno((i1UKvFKHED5gX1GVqcl06fAXYc1xnytHZwu0nGWrS9y1jkYXYzO4yH2xidBRXzlk6gq4i2ES6ef5psYZYSqIVqBVq7lKHT14SffDdiCeBpwDIICwGbvxl5vb12FgjAKpbhdsWkIfSjOILZqXry6GQ(tb)0dQmSTg)tsiNfyq11sEvqf01LMvFKH6gjibRadbBcQy5muCeMoOQ)uWp9GkGwidBRXB)1jyfbYsniNf4cTVqXPyj82FDcwrGSudYXYzO4yHwSSqg2wJdEsPz1hj5AqzH8hDTSqlww4aDbu0RrCGAxrUKAWZQFH2xO(MGLxcVYEqsS54cTVqg2wJpqxazIdwKBexd(cvEHe5fAXYcF2c5sscJYfbZfsCclSxpcQUwYRcQhdnf8DbdsWkYwWMGkwodfhHPdQ6pf8tpO(SvQJaVU4Zhyl1PSqIVqfw4mITWPwO4uSe(ZwPo6IGfRl5vCSCgkowirzH2EHKhuDTKxfuB)zKOr(eCmibRiYbBcQy5muCeMoOQ)uWp9G6ZwPoc86IpFGTuNYcvEHkSqRj2cNAHItXs4pBL6OlcwSUKxXXYzO4yHeLfA7fsEq11sEvq9yOPGVlyqcwrufSjO6AjVkO2(ZirJ8j4yqflNHIJW0bjy1mYeSjO6AjVkOc6(kETy3Se8dQy5muCeMoibRMnlytq11sEvq1FTxyuU)XscQy5muCeMoibjOYCMiW7Oz1hSjy1SGnbvSCgkocthuDTKxfubDDPz1hzOUrcQd0O)eOKxfuN(rxaTWRTq1SgV3FgFHaVJMv)c)tCjVAH2AHgXFXSWzKXSqgSDpUWPp1fMMf6t8K6mumOQ)uWp9GkdBRX)KeYzbgKGvwhSjOILZqXry6GQ(tb)0dQUwYjyelKuIMfQmHfA9cTyzHpBHCjjHr5IeBHeNWc71JfAFHkSqXPyj8ExaHFw9rJCpjowodfhl0ILfQVAWMchNGF7pJWXYzO4yHwSSWNTW299iNjLS6J6Jo4y5muCSqYdQUwYRcQps6EdsrJj2nlb)GeSY2bBcQy5muCeMoO6AjVkOEm0uW3fmOQvutXO4FpkMGvZcQ6pf8tpO(SvQJaVU4Zhyl1PSqLjSqRjwqDGg9NaL8QG6CX)EuIzJajVJ2sHbYW2A837K7tnYnIRbFQzKtuRWazyBn(7DY9Pg5psYZYm1mYjkd0fqrWRShKWF2cB33J837K7tnoFHKfei6IzH(cPNO0cfqPzHPzHzjynWXcLBHI)9OSqbeUqqzpi0ile4N3NIIlelKKIlSBkGwOxl0zsAkkUqbKllSBsPl0bcKQ4cFVtUp14cZ2cF2cB33Jd(cTbKllKbZQFHETqSqskUWUPaAHKzHgX1GBuAH3VqVwiwijfxOaYLfkGWfoqg2wBHDtkDHM7QfIDey(4cVIhKGvGzWMGkwodfhHPdQ6pf8tpO(SvQJaVU4Zhyl1PSqIVqRjZcTVqdqKsJI)9Oy49uxNon6JjEPXfQmHfA9cTVq9D0X1T4atk1)41IT)mc)rsEwMfQ8cjwq11sEvqTN660PrFmXlngKGvelytqflNHIJW0bvxl5vb12FgjAKpbhdQ6pf8tpO(SvQJaVU4Zhyl1PSqIVqRjZcTVq9D0X1T4atk1)41IT)mc)rsEwMfQ8cjwqvROMIrX)EumbRMfKGvGHGnbvSCgkocthu1Fk4NEqLHT14GNuAw9rsUguwi)rxll0(cF2k1rGxx85dSL6uwOYluHfoJylCQfkoflH)SvQJUiyX6sEfhlNHIJfsuwOTxi5l0(cnarknk(3JIH3(ZigTIciCHktyHwVq7luHfYW2A8b6citCWICJ4AWxiHfsKxOflleqlCGUak61ioqTRixsn4z1VqlwwiGwO(MGLxcVYEqsS54cjpO6AjVkO2(ZigTIcimibRiBbBcQy5muCeMoOQ)uWp9G6ZwPoc86IpFGTuNYcvMWcvyH2MylCQfkoflH)SvQJUiyX6sEfhlNHIJfsuwOTxi5l0(cnarknk(3JIH3(ZigTIciCHktyHwVq7luHfYW2A8b6citCWICJ4AWxiHfsKxOflleqlCGUak61ioqTRixsn4z1VqlwwiGwO(MGLxcVYEqsS54cjpO6AjVkO2(ZigTIcimibRiYbBcQy5muCeMoO6AjVkOEm0uW3fmOQ)uWp9G6ZwPoc86IpFGTuNYcvMWcvyH2MylCQfkoflH)SvQJUiyX6sEfhlNHIJfsuwOTxi5bvTIAkgf)7rXeSAwqcwrufSjOILZqXry6GQ(tb)0dQ67OJRBXbMuQ)XRfB)ze(JK8Smlu5f(SfYLKegLlcMl0(cF2k1rGxx85dSL6uwiXxiysMfAFHgGiLgf)7rXW7PUoDA0ht8sJluzcl06GQRL8QGAp11PtJ(yIxAmibRMrMGnbvSCgkocthuDTKxfuB)zKOr(eCmOQ)uWp9GQ(o646wCGjL6F8AX2FgH)ijplZcvEHpBHCjjHr5IG5cTVWNTsDe41fF(aBPoLfs8fcMKjOQvutXO4FpkMGvZcsqcQ67OJRBzc2eSAwWMGkwodfhHPdQ6pf8tpOYW2ACGjL6F8AX2FgHZcCH2xidBRXrsaVU4hF2cJDrh4vCwGb1bA0FcuYRcQD6tYRcQUwYRcQapjVkibRSoytqflNHIJW0bvxl5vbvKeWRl(XNTWyx0bEvqDGg9NaL8QGAhUJoUULjOQ)uWp9GQ4uSe(XqtbFxYR4y5muCSq7luHfQVJoUUfhysP(hVwS9Nr4p6dfxO9f(SfYLKegLlsSfQ8c71JfAFHpBL6iWRl(8b2sDkluzclCgzwOfllKHT14atk1)41IT)mcNf4cTVWNTqUKKWOCrITqLxyVESqYxOfllSL9GK4JK8SmlK4l0AYeKGv2oytqflNHIJW0bv9Nc(PhufNILWzE0fqXRfnznEV)mohlNHIJfAFHpBL6iWRl(8b2sDklu5fcMKzH2x4ZwixssyuUiXwOYlSxpwO9fQWczyBnoZJUakETOjRX79NX5SaxOfllSL9GK4JK8SmlK4l0AYSqYdQUwYRcQijGxx8JpBHXUOd8QGeScmd2euXYzO4imDqv)PGF6bvXPyj8uJAhihlNHIJfAFHpBHlK4l02bvxl5vbvKeWRl(XNTWyx0bEvqcwrSGnbvSCgkocthu1Fk4NEqvCkwcN5rxafVw0K149(Z4CSCgkowO9fQWc13rhx3IZ8OlGIxlAYA8E)zC(JK8Sml0ILfQVJoUUfN5rxafVw0K149(Z48h9HIl0(cF2k1rGxx85dSL6uwiXxiyGmlK8GQRL8QGkWKs9pETy7pJeKGvGHGnbvSCgkocthu1Fk4NEqvCkwcp1O2bYXYzO4yH2xiGwidBRXbMuQ)XRfB)zeolWGQRL8QGkWKs9pETy7pJeKGvKTGnbvSCgkocthu1Fk4NEqvCkwc)yOPGVl5vCSCgkowO9fQWcfNILW7Dbe(z1hnY9K4y5muCSq7lKHT14ps6EdsrJj2nlbFolWfAXYcb0cfNILW7Dbe(z1hnY9K4y5muCSqYdQUwYRcQatk1)41IT)msqcwrKd2euXYzO4imDqv)PGF6bvg2wJdmPu)Jxl2(ZiCwGbvxl5vbvMhDbu8ArtwJ37pJhKGvevbBcQy5muCeMoOQ)uWp9GkdBRXbMuQ)XRfB)ze(JK8SmlK4lSxpwO9fYW2ACGjL6F8AX2FgHZcCH2xiGwO4uSe(XqtbFxYR4y5muCeuDTKxfuB)zKUk(KmXg7RyqcwnJmbBcQy5muCeMoOQ)uWp9GQRLCcgXcjLOzHktyHwVq7luHfYW2ACGjL6F8AX2FgHZcCH2xidBRXbMuQ)XRfB)ze(JK8SmlK4lSxpwOfll89CeXjyjCFmmCSJPrml0(cFphrCcwc3hdd)rsEwMfs8f2Rhl0ILf2YEqs8rsEwMfs8f2RhlK8GQRL8QGA7pJ0vXNKj2yFfdsWQzZc2euXYzO4imDqv)PGF6bvXPyj8JHMc(UKxXXYzO4yH2xiGwidBRXbMuQ)XRfB)zeolWfAFHkSqfwidBRXzlqhvXOrES6fqCwGl0ILfcOfoqxafbVYEqc)zlSDFpYBoLIvu)SgFG)cjFH2xOclCGmSTg)9o5(uJCJ4AWxiHfsSfAXYcb0chOlGIGxzpiH)Sf2UVh5V3j3NACHKVqYdQUwYRcQT)msxfFsMyJ9vmibRMzDWMGkwodfhHPdQ6pf8tpOkoflHZ8OlGIxlAYA8E)zCowodfhl0(cF2k1rGxx85dSL6uwOYlemjZcTVWNTWfQmHfA7fAFHmSTghysP(hVwS9Nr4SaxOflleqluCkwcN5rxafVw0K149(Z4CSCgkowO9f(SvQJaVU4Zhyl1PSqLjSqRjwq11sEvqfKIapbe(KsDe4JgS0yqcwnZ2bBcQy5muCeMoOQ)uWp9GkdBRXbMuQ)XRfB)zeolWGQRL8QG67PbJd0hbjy1mWmytqflNHIJW0bv9Nc(PhuDTKtWiwiPenluzcl06fAFHkSqGOW7bDSu(JK8SmlK4lSxpwOfllu8VhfUKKWOCXrIlK4lSxpwi5bvxl5vbvJR)SL60PrGUwcsWQzelytqflNHIJW0bv9Nc(PhuDTKtWiwiPenlu5fsSfAXYcF2cB33JCGGq)psxHgowodfhbvxl5vb1b6cOOxJ4a1UIbjib1b2CwQeSjy1SGnbvxl5vbvsznIThXobdQy5muCeMoibRSoytqflNHIJW0b1dyq1Gsq11sEvqDI)PZqXG6eNYIbvfwis2ztGaXbplJ(zfNHIrYoRxclP4aNKACH2xO(o646w8Sm6NvCgkgj7SEjSKIdCsQr(J(qXfsEqDGg9NaL8QGAN(Xjyjl0ae1zlXXcLplWrXSqgmR(fYAWXc7McOf6SYrYLuVqAwOjOoX)y5KWGQbiQZwIJO8zbokbjyLTd2euXYzO4imDq11sEvq9rs3BqkAmXUzj4huhOr)jqjVkOs0bcKQ4c7u)zKf2PWj4R0cj5zjEwlKOPvCH240Rml0RXcbhrGlKSGKU3Gu0ywirAwc(l8pknR(GQ(tb)0dQ6RgSPWXj43(ZiCSCgkowO9fkoflH37ci8ZQpAK7jXXYzO4yH2xiGwO4uSe(XqtbFxYR4y5muCSq7luFhDCDloWKs9pETy7pJWFKKNLjibRaZGnbvSCgkocthuDTKxfubDDPz1hzOUrcQd0O)eOKxfuj6absvCHDQ)mYc7u4e8xOxJfsYZs8SwirtR4cTXPxzcQ6pf8tpOcOfooH3(ZiXgobFUKAWZQFH2xOcluCkwcp1O2bYXYzO4yHwSSq9D0X1T4mp6cO41IMSgV3FgN)ijplZcvEHZi2cTyzHItXs4hdnf8DjVIJLZqXXcTVq9D0X1T4atk1)41IT)mc)rsEwMfAFHaAHmSTgh8KsZQpsY1GYc5Saxi5bjyfXc2euXYzO4imDqv)PGF6bvg2wJNAfJItVYWFKKNLzHeNWc71JfAFHmSTgp1kgfNELHZcCH2xObisPrX)Eum8EQRtNg9XeV04cvMWcTEH2xOcleqluCkwcN5rxafVw0K149(Z4CSCgkowOflluFhDCDloZJUakETOjRX79NX5psYZYSqLx4mITqYdQUwYRcQ9uxNon6JjEPXGeScmeSjOILZqXry6GQ(tb)0dQmSTgp1kgfNELH)ijplZcjoHf2Rhl0(czyBnEQvmko9kdNf4cTVqfwiGwO4uSeoZJUakETOjRX79NX5y5muCSqlwwO(o646wCMhDbu8ArtwJ37pJZFKKNLzHkVWzeBHKhuDTKxfuB)zKOr(eCmibRiBbBcQy5muCeMoOoqJ(tGsEvqTdGUZGlKORL8QfstJSq5w4Zwbvxl5vbvTtPrxl5vrAAKGknnsSCsyqvFtWYlXeKGve5GnbvSCgkocthuDTKxfu1oLgDTKxfPPrcQ00iXYjHb131PtnbjyfrvWMGkwodfhHPdQUwYRcQANsJUwYRI00ibvAAKy5KWGQ8zbokMGeSAgzc2euXYzO4imDq11sEvqv7uA01sEvKMgjOstJelNegu13rhx3YeKGvZMfSjOILZqXry6GQ(tb)0dQItXs46JoIGq)fowodfhl0(czyBnU(OJii0FHBexd(cvMWcNrMfAFHkSWbYW2A837K7tnYnIRbFHewiXwOflleqlCGUakcEL9Ge(Zwy7(EK)ENCFQXfsEq11sEvqv7uA01sEvKMgjOstJelNegu1hDebH(lbjy1mRd2euXYzO4imDqv)PGF6bvg2wJZ8OlGIxlAYA8E)zColWGQRL8QG6Zwrxl5vrAAKGknnsSCsyqL5mrj1GNvFqcwnZ2bBcQy5muCeMoOQ)uWp9GQ4uSeoZJUakETOjRX79NX5y5muCSq7luHfQVJoUUfN5rxafVw0K149(Z48hj5zzwiXx4mYSqYdQUwYRcQpBfDTKxfPPrcQ00iXYjHbvMZebEhnR(GeSAgygSjOILZqXry6GQ(tb)0dQmSTghysP(hVwS9Nr4SaxO9fkoflHFm0uW3L8kowodfhbvxl5vb1NTIUwYRI00ibvAAKy5KWG6XqtbFxYRcsWQzelytqflNHIJW0bv9Nc(PhufNILWpgAk47sEfhlNHIJfAFH67OJRBXbMuQ)XRfB)ze(JK8SmlK4lCgzcQUwYRcQpBfDTKxfPPrcQ00iXYjHb1JHMc(UKxfbEhnR(GeSAgyiytqflNHIJW0bv9Nc(PhuDTKtWiwiPenluzcl06GQRL8QG6Zwrxl5vrAAKGknnsSCsyq1pmibRMr2c2euXYzO4imDq11sEvqv7uA01sEvKMgjOstJelNegunIxd)hbjibvGpQpsmUeSjibv)WGnbRMfSjOILZqXry6G6an6pbk5vbvI(rKSqYYjUKxfuDTKxfuFK09gKIgtSBwc(bjyL1bBcQy5muCeMoOQ)uWp9GQ4uSeE7pJy0kkGqowodfhbvxl5vb1EQRtNg9XeV0yqcwz7GnbvSCgkocthuDTKxfuB)zKOr(eCmOQ)uWp9GQ(o646w8hjDVbPOXe7MLGp)rsEwMfsCcl06fsuwyVESq7luCkwcV3fq4NvF0i3tIJLZqXrqvROMIrX)EumbRMfKGvGzWMGkwodfhHPdQ6pf8tpOYW2A8pjHCwGbvxl5vbvqxxAw9rgQBKGeSIybBcQy5muCeMoOQ)uWp9G6aDbu0RrCGAxrUKAWZQFH2xO(MGLxcVYEqsS54cTVqg2wJpqxazIdwKBexd(cj(cjYbvxl5vb1JHMc(UGbjyfyiytqflNHIJW0bv9Nc(PhuzyBno4jLMvFKKRbLfYF01YcTVqfwiGw4aDbu0RrCGAxrUKAWZQFH2xO(MGLxcVYEqsS54cTyzHaAH6BcwEj8k7bjXMJlK8GQRL8QGA7pJy0kkGWGeSISfSjOILZqXry6GQ(tb)0dQpBL6iWRl(8b2sDklK4luHfoJylCQfkoflH)SvQJUiyX6sEfhlNHIJfsuwOTxi5bvxl5vb1EQRtNg9XeV0yqcwrKd2euXYzO4imDq11sEvqT9NrIg5tWXGQ(tb)0dQpBL6iWRl(8b2sDklK4luHfoJylCQfkoflH)SvQJUiyX6sEfhlNHIJfsuwOTxi5bvTIAkgf)7rXeSAwqcwrufSjOILZqXry6GQ(tb)0dQaAHd0fqrVgXbQDf5sQbpR(fAFH6BcwEj8k7bjXMJl0ILfcOfQVjy5LWRShKeBoguDTKxfuB)zeJwrbegKGvZitWMGkwodfhHPdQUwYRcQhdnf8DbdQ6pf8tpO(SvQJaVU4Zhyl1PSqLxOcl0AITWPwO4uSe(ZwPo6IGfRl5vCSCgkowirzH2EHKhu1kQPyu8VhftWQzbjy1SzbBcQUwYRcQ9uxNon6JjEPXGkwodfhHPdsWQzwhSjOILZqXry6GQRL8QGA7pJenYNGJbvTIAkgf)7rXeSAwqcwnZ2bBcQUwYRcQGUVIxl2nlb)GkwodfhHPdsWQzGzWMGQRL8QGQ)AVWOC)JLeuXYzO4imDqcsqv(SahftWMGvZc2euXYzO4imDq11sEvqnlJ(zfNHIrYoRxclP4aNKAmOoqJ(tGsEvq1MplWrXeu1Fk4NEqLHT14atk1)41IT)mcNf4cTyzHI)9OWLKegLlculrRjZcj(cj2cTyzHTShKeFKKNLzHeFHwplibRSoytqflNHIJW0bv9Nc(PhuzyBnoWKs9pETy7pJWzbUq7luHfcOfkoflHNAu7a5y5muCSqlwwO4uSeEQrTdKJLZqXXcTVqg2wJdmPu)Jxl2(Zi8hj5zzwOYew4mYSqYdQUwYRcQSgmMcsYeKGeu13eS8smbBcwnlytqflNHIJW0bvxl5vb1b6citCWIb1bA0FcuYRcQD4MGLxYcj6mjnLenbv9Nc(PhuFphrCcwc3hddpRfQ8cNrSfAXYcb0cFphrCcwc3hddh7yAeZcTyzHUwYjyelKuIMfQmHfADqcwzDWMGkwodfhHPdQ6pf8tpO6AjNGrSqsjAwiHfoBH2x4ZwPoc86IpFGTuNYcvEH2EH2xO(o646wCGjL6F8AX2FgH)ijplZcj(cT9cTVqaTqXPyjCMhDbu8ArtwJ37pJZXYzO4yH2xOcleql89CeXjyjCFmmCSJPrml0ILf(EoI4eSeUpggEwlu5foJylK8GQRL8QGQPR)KYQpsknsqcwz7GnbvSCgkocthu1Fk4NEq11sobJyHKs0SqLjSqRxO9fcOfkoflHZ8OlGIxlAYA8E)zCowodfhbvxl5vbvtx)jLvFKuAKGeScmd2euXYzO4imDqv)PGF6bvXPyjCMhDbu8ArtwJ37pJZXYzO4yH2xOclKHT14mp6cO41IMSgV3FgNZcCH2xOcl01sobJyHKs0SqclC2cTVWNTsDe41fF(aBPoLfQ8cbtYSqlwwORLCcgXcjLOzHktyHwVq7l8zRuhbEDXNpWwQtzHkVqWazwi5l0ILfcOfYW2ACMhDbu8ArtwJ37pJZzbUq7luFhDCDloZJUakETOjRX79NX5psYZYSqYdQUwYRcQMU(tkR(iP0ibjyfXc2euXYzO4imDqv)PGF6bvxl5emIfskrZcjSWzl0(c13rhx3IdmPu)Jxl2(Zi8hj5zzwiXxOTxO9fQWcb0cFphrCcwc3hddh7yAeZcTyzHVNJioblH7JHHN1cvEHZi2cjpO6AjVkO6mhPSCjVkstsmbjyfyiytqflNHIJW0bv9Nc(PhuDTKtWiwiPenluzcl06GQRL8QGQZCKYYL8QinjXeKGvKTGnbvSCgkocthu1Fk4NEq11sobJyHKs0SqclC2cTVq9D0X1T4atk1)41IT)mc)rsEwMfs8fA7fAFHkSqaTW3ZreNGLW9XWWXoMgXSqlww475iItWs4(yy4zTqLx4mITqYdQUwYRcQgqUgCkgfqyKT6EVasXGeSIihSjOILZqXry6GQ(tb)0dQUwYjyelKuIMfQmHfADq11sEvq1aY1GtXOacJSv37fqkgKGeuFxNo1eSjy1SGnbvSCgkocthuDTKxfuzO3nIn2xXG6an6pbk5vbvYIRtNUqIotstjrtqv)PGF6bvg2wJdmPu)Jxl2(ZiCwGbjyL1bBcQy5muCeMoOQ)uWp9GkdBRXbMuQ)XRfB)zeolWGQRL8QGkd(g8bpR(GeSY2bBcQy5muCeMoOQ)uWp9GQcleqlKHT14atk1)41IT)mcNf4cTVqxl5emIfskrZcvMWcTEHKVqlwwiGwidBRXbMuQ)XRfB)zeolWfAFHkSWNTq(aBPoLfQmHfsSfAFHpBL6iWRl(8b2sDkluzclemqMfsEq11sEvq1FTxyeil1GbjyfygSjOILZqXry6GQ(tb)0dQmSTghysP(hVwS9Nr4SadQUwYRcQ0ShKyIGXGD0tcljibRiwWMGkwodfhHPdQ6pf8tpOYW2ACGjL6F8AX2FgHZcCH2xidBRXrsaVU4hF2cJDrh4vCwGbvxl5vbvV0OrENg1oLgKGvGHGnbvSCgkocthu1Fk4NEqLHT14atk1)41IT)mc)rsEwMfsCclKiVq7lKHT14ijGxx8JpBHXUOd8kolWGQRL8QGAlFKHE3iibRiBbBcQy5muCeMoOQ)uWp9GkdBRXbMuQ)XRfB)zeolWfAFHUwYjyelKuIMfsyHZwO9fQWczyBnoWKs9pETy7pJWFKKNLzHeFHeBH2xO4uSeU(OJii0FHJLZqXXcTyzHaAHItXs46JoIGq)fowodfhl0(czyBnoWKs9pETy7pJWFKKNLzHeFH2EHKhuDTKxfuz8(41IYNAWnbjibjOobFtEvWkRjJ1ZiJTNrMGAx)RS6nbvIuIozXkIMvKv2AHl0gq4ctsaVxwy7(fo)yOPGVl5vrG3rZQF(cFKSZMpowO5iHl0zLJKl4yHAqE1Jg(cqNZcx4mBTWoC1e8fCSW5ItXs4GD(cLBHZfNILWblhlNHIJ5luHzDKC(cqNZcx4mBTWoC1e8fCSW5pBHT77royNVq5w48NTW299ihSCSCgkoMVqfM1rY5laDolCHZS1c7WvtWxWXcNRVAWMchSZxOClCU(QbBkCWYXYzO4y(cvywhjNVaSaqKs0jlwr0SISYwlCH2acxysc49YcB3VW56JoIGq)L5l8rYoB(4yHMJeUqNvosUGJfQb5vpA4laDolCHZS1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqfM1rY5laDolCHwBRf2HRMGVGJfoxCkwchSZxOClCU4uSeoy5y5muCmFHkmRJKZxa6Cw4cTTTwyhUAc(cow4CXPyjCWoFHYTW5ItXs4GLJLZqXX8fQWSosoFbOZzHlemT1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqfM1rY5lalaePeDYIvenRiRS1cxOnGWfMKaEVSW29lC(XqtbFxYRMVWhj7S5JJfAos4cDw5i5cowOgKx9OHVa05SWfoZwlSdxnbFbhlCU4uSeoyNVq5w4CXPyjCWYXYzO4y(cvywhjNVa05SWfoZwlSdxnbFbhlC(Zwy7(EKd25luUfo)zlSDFpYblhlNHIJ5luHzDKC(cqNZcx4mBTWoC1e8fCSW56RgSPWb78fk3cNRVAWMchSCSCgkoMVqfM1rY5laDolCHGbBTWoC1e8fCSW56RgSPWb78fk3cNRVAWMchSCSCgkoMVqfM1rY5laDolCHev2AHD4Qj4l4yHZfNILWb78fk3cNloflHdwowodfhZxOcw3rY5lalaePeDYIvenRiRS1cxOnGWfMKaEVSW29lCoZzIsQbpR(5l8rYoB(4yHMJeUqNvosUGJfQb5vpA4laDolCHwBRf2HRMGVGJfoxCkwchSZxOClCU4uSeoy5y5muCmFHkmRJKZxa6Cw4cT2wlSdxnbFbhlC(Zwy7(EKd25luUfo)zlSDFpYblhlNHIJ5luHzDKC(cqNZcxO12AHD4Qj4l4yHZ1xnytHd25luUfoxF1Gnfoy5y5muCmFHkmRJKZxawaisj6KfRiAwrwzRfUqBaHlmjb8EzHT7x4C9nblVeZ8f(izNnFCSqZrcxOZkhjxWXc1G8Qhn8fGoNfUqRT1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqfM1rY5laDolCH22wlSdxnbFbhlCU4uSeoyNVq5w4CXPyjCWYXYzO4y(cDzHejGrDEHkmRJKZxa6Cw4cbtBTWoC1e8fCSW5ItXs4GD(cLBHZfNILWblhlNHIJ5luHzDKC(cWcarkrNSyfrZkYkBTWfAdiCHjjG3llSD)cNBeVg(pMVWhj7S5JJfAos4cDw5i5cowOgKx9OHVa05SWfoZwlSdxnbFbhlCU4uSeoyNVq5w4CXPyjCWYXYzO4y(cvywhjNVa05SWfoZwlSdxnbFbhlC(Zwy7(EKd25luUfo)zlSDFpYblhlNHIJ5l0LfsKag15fQWSosoFbOZzHlCMTwyhUAc(cow4C9vd2u4GD(cLBHZ1xnytHdwowodfhZxOcZ6i58fGoNfUqBBRf2HRMGVGJfoxCkwchSZxOClCU4uSeoy5y5muCmFHUSqIeWOoVqfM1rY5laDolCHGPTwyhUAc(cow4C9vd2u4GD(cLBHZ1xnytHdwowodfhZxOcw3rY5laDolCHGbBTWoC1e8fCSW5ItXs4GD(cLBHZfNILWblhlNHIJ5luHzDKC(cqNZcxizZwlSdxnbFbhlCU4uSeoyNVq5w4CXPyjCWYXYzO4y(cvywhjNVa05SWfsKT1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqfM1rY5lalaePeDYIvenRiRS1cxOnGWfMKaEVSW29lCoZzIaVJMv)8f(izNnFCSqZrcxOZkhjxWXc1G8Qhn8fGoNfUqRT1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqfM1rY5laDolCHwBRf2HRMGVGJfo)zlSDFpYb78fk3cN)Sf2UVh5GLJLZqXX8fQWSosoFbOZzHl0ABTWoC1e8fCSW56RgSPWb78fk3cNRVAWMchSCSCgkoMVqfM1rY5laDolCHGbBTWoC1e8fCSW5ItXs4GD(cLBHZfNILWblhlNHIJ5luHzDKC(cqNZcxizZwlSdxnbFbhlCU4uSeoyNVq5w4CXPyjCWYXYzO4y(cvywhjNVa05SWfsKT1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqfM1rY5lalaePeDYIvenRiRS1cxOnGWfMKaEVSW29lCU(o646wM5l8rYoB(4yHMJeUqNvosUGJfQb5vpA4laDolCHwBRf2HRMGVGJfoxCkwchSZxOClCU4uSeoy5y5muCmFHkmRJKZxa6Cw4cTTTwyhUAc(cow4CXPyjCWoFHYTW5ItXs4GLJLZqXX8fQWSosoFbOZzHlemT1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqfM1rY5laDolCHeZwlSdxnbFbhlCU4uSeoyNVq5w4CXPyjCWYXYzO4y(cvywhjNVa05SWfcgS1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqfM1rY5laDolCHKnBTWoC1e8fCSW5ItXs4GD(cLBHZfNILWblhlNHIJ5luHzDKC(cqNZcxirLTwyhUAc(cow4CXPyjCWoFHYTW5ItXs4GLJLZqXX8f6YcjsaJ68cvywhjNVa05SWfoBMTwyhUAc(cow4CXPyjCWoFHYTW5ItXs4GLJLZqXX8fQWSosoFbOZzHlCM12AHD4Qj4l4yHZfNILWb78fk3cNloflHdwowodfhZxOcw3rY5laDolCHZiMTwyhUAc(cow48NTW299ihSZxOClC(Zwy7(EKdwowodfhZxOllKibmQZluHzDKC(cWcarkrNSyfrZkYkBTWfAdiCHjjG3llSD)cNlFwGJIz(cFKSZMpowO5iHl0zLJKl4yHAqE1Jg(cqNZcxO12AHD4Qj4l4yHZfNILWb78fk3cNloflHdwowodfhZxOcw3rY5lalaePeDYIvenRiRS1cxOnGWfMKaEVSW29lC(aBolvMVWhj7S5JJfAos4cDw5i5cowOgKx9OHVa05SWfABBTWoC1e8fCSW5ItXs4GD(cLBHZfNILWblhlNHIJ5lubR7i58fGoNfUqBBRf2HRMGVGJfoxF1GnfoyNVq5w4C9vd2u4GLJLZqXX8fQWSosoFbOZzHlemT1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqfSUJKZxa6Cw4cjMTwyhUAc(cow4CXPyjCWoFHYTW5ItXs4GLJLZqXX8fQWSosoFbOZzHlemyRf2HRMGVGJfoxCkwchSZxOClCU4uSeoy5y5muCmFHkmRJKZxa6Cw4cNnZwlSdxnbFbhlCU4uSeoyNVq5w4CXPyjCWYXYzO4y(cvywhjNVa05SWfoZ22AHD4Qj4l4yHZfNILWb78fk3cNloflHdwowodfhZxOcZ6i58fGoNfUWzGPTwyhUAc(cow4CXPyjCWoFHYTW5ItXs4GLJLZqXX8f6YcjsaJ68cvywhjNVa05SWfoJy2AHD4Qj4l4yHZfNILWb78fk3cNloflHdwowodfhZxOcZ6i58fGfaIuIozXkIMvKv2AHl0gq4ctsaVxwy7(fo3pC(cFKSZMpowO5iHl0zLJKl4yHAqE1Jg(cqNZcxO12AHD4Qj4l4yHZfNILWb78fk3cNloflHdwowodfhZxOllKibmQZluHzDKC(cqNZcxOTT1c7WvtWxWXcNloflHd25luUfoxCkwchSCSCgkoMVqxwircyuNxOcZ6i58fGoNfUqYMTwyhUAc(cow4CXPyjCWoFHYTW5ItXs4GLJLZqXX8fQWSosoFbOZzHlKiBRf2HRMGVGJfoxCkwchSZxOClCU4uSeoy5y5muCmFHkmRJKZxa6Cw4cNrgBTWoC1e8fCSW5ItXs4GD(cLBHZfNILWblhlNHIJ5luHzDKC(cWcarJeW7fCSWzwVqxl5vlKMgXWxacQgGOoyL1eBwqf4FTKIbvIGiwizD0fqlKSMk7bjlSt9NrwaicIyHGX0FnOfodmvAHwtgRNTaSaqeeXc7aiV6rZcarqelem(cjliPBcowi1ncyCdQVASqwJ3Jl8AlSdG8Sml8AlKOPXf6MfMYchhAQ5YcbsDfxyxKsxywle47Aj1iFbybGiiIfsKmXPSUGMf6lu(SahfZc13rhx3sPfoYj5ahlKrXfcmPu)x41wy7pJSW7xiZJUaAHxBHMSgV3FgFUzH67OJRBXxirRTWuMBw4eNYIleKBwyDl8rsEwd8x4Jc7xlCMslePgCHpkSFTqYWjgFbGiiIf6AjVYWb(O(iX4cHj(NodfvQCsib5ZcCuIZIgflTshqcguYMstCklsyMstCklgrQbjqgoXusF1iL8kcYNf4OWNXb5MiRbJmSTMDfaK4uSeoZJUakETOjRX79NXTRG8zbok8zC9D0X1T4d23L8kIAIA9D0X1T4atk1)41IT)mcFW(UKxrGmKBXI4uSeoZJUakETOjRX79NXTRG(o646wCMhDbu8ArtwJ37pJZhSVl5ve1e1YNf4OWNX13rhx3IpyFxYRiqgYTyrCkwcp1O2bs(carqel01sELHd8r9rIXLPia4j(NodfvQCsib5ZcCuIwhnkwALoGemOKnLM4uwKWmLM4uwmIudsGmCIPK(Qrk5veKplWrHBnhKBISgmYW2A2vaqItXs4mp6cO41IMSgV3Fg3UcYNf4OWTMRVJoUUfFW(UKxrutuRVJoUUfhysP(hVwS9Nr4d23L8kcKHClweNILWzE0fqXRfnznEV)mUDf03rhx3IZ8OlGIxlAYA8E)zC(G9DjVIOMOw(SahfU1C9D0X1T4d23L8kcKHClweNILWtnQDGKVaqeeXcjsmssYf0SqFHYNf4Oyw4eNYIlKrXfQpsa9pR(fkGWfQVJoUU1cV2cfq4cLplWrrPfoYj5ahlKrXfkGWfoyFxYRw41wOacxidBRTWuwiW)MKd0WxiySUzH(cnYJvVaAHKUr2s8xOClSpNGl0xiOShe(le4N3NIIluUfAKhREb0cLplWrXO0cDZc7Iu6cDZc9fs6gzlXFHT7xy2wOVq5ZcCuwy3Ksx49lSBsPlSozHgfl9c7McOfQVJoUULHVaqeeXcDTKxz4aFuFKyCzkcaEI)PZqrLkNesq(SahLiWpVpffv6asWGs2uAItzrcwR0eNYIrKAqcZusF1iL8kcas(Sahf(moi3eznyKHT1SlFwGJc3Aoi3eznyKHT1Syr(SahfU1CqUjYAWidBRzxbfKplWrHBnxFhDCDl(G9DjVIOw(SahfU1CG)P5EPyCa0WhSVl5vKtuuygNytjFwGJc3Aoi3ezyBnUrES6fqKtuuyI)PZqrU8zbokrRJgfln5KRSckiFwGJcFgxFhDCDl(G9DjVIOw(Sahf(moW)0CVumoaA4d23L8kYjkkmJtSPKplWrHpJdYnrg2wJBKhREbe5effM4F6muKlFwGJsCw0OyPjN8fGfaIGiwirshrnRGJfItWxXfkjjCHciCHUwUFHPzH(epPodf5laUwYRmeiL1i2Ee7eCbGiwyN(Xjyjl0ae1zlXXcLplWrXSqgmR(fYAWXc7McOf6SYrYLuVqAwOzbW1sELzkcaEI)PZqrLkNesWae1zlXru(SahfLM4uwKGcizNnbceh8Sm6NvCgkgj7SEjSKIdCsQr767OJRBXZYOFwXzOyKSZ6LWskoWjPg5p6dfjFbGiwirhiqQIlSt9NrwyNcNGVslKKNL4zTqIMwXfAJtVYSqVgleCebUqYcs6EdsrJzHePzj4VW)O0S6xaCTKxzMIaGFK09gKIgtSBwc(kLnc6RgSPWXj43(Zi2fNILW7Dbe(z1hnY9KSdiXPyj8JHMc(UKxzxFhDCDloWKs9pETy7pJWFKKNLzbGiwirhiqQIlSt9NrwyNcNG)c9ASqsEwIN1cjAAfxOno9kZcGRL8kZueamORlnR(id1nIszJaGgNWB)zKydNGpxsn4z1BxbXPyj8uJAhOfl67OJRBXzE0fqXRfnznEV)mo)rsEwgLNrmlweNILWpgAk47sELD9D0X1T4atk1)41IT)mc)rsEwg7aIHT14GNuAw9rsUguwiNfi5laUwYRmtraW9uxNon6JjEPrLYgbg2wJNAfJItVYWFKKNLH4e61d7mSTgp1kgfNELHZc0UbisPrX)Eum8EQRtNg9XeV0OYeS2UcasCkwcN5rxafVw0K149(Z4wSOVJoUUfN5rxafVw0K149(Z48hj5zzuEgXiFbW1sELzkcaU9NrIg5tWrLYgbg2wJNAfJItVYWFKKNLH4e61d7mSTgp1kgfNELHZc0UcasCkwcN5rxafVw0K149(Z4wSOVJoUUfN5rxafVw0K149(Z48hj5zzuEgXiFbGiwyhaDNbxirxl5vlKMgzHYTWNTwaCTKxzMIaG1oLgDTKxfPPruQCsib9nblVeZcGRL8kZueaS2P0ORL8QinnIsLtcj8UoDQzbW1sELzkcaw7uA01sEvKMgrPYjHeKplWrXSa4AjVYmfbaRDkn6AjVkstJOu5Kqc67OJRBzwaCTKxzMIaG1oLgDTKxfPPruQCsib9rhrqO)IszJG4uSeU(OJii0FXodBRX1hDebH(lCJ4AWvMWmYyxHbYW2A837K7tnYnIRbNaXSybqd0fqrWRShKWF2cB33J837K7tns(cGRL8kZuea8Zwrxl5vrAAeLkNesG5mrj1GNvVszJadBRXzE0fqXRfnznEV)moNf4cGRL8kZuea8Zwrxl5vrAAeLkNesG5mrG3rZQxPSrqCkwcN5rxafVw0K149(Z42vqFhDCDloZJUakETOjRX79NX5psYZYq8zKH8faxl5vMPia4NTIUwYRI00ikvojKWXqtbFxYRukBeyyBnoWKs9pETy7pJWzbAxCkwc)yOPGVl5vlaUwYRmtraWpBfDTKxfPPruQCsiHJHMc(UKxfbEhnRELYgbXPyj8JHMc(UKxzxFhDCDloWKs9pETy7pJWFKKNLH4ZiZcGRL8kZuea8Zwrxl5vrAAeLkNesWpuPSrW1sobJyHKs0OmbRxaCTKxzMIaG1oLgDTKxfPPruQCsibJ41W)XcWcarSqI(rKSqYYjUKxTa4AjVYW9dj8iP7nifnMy3Se8xaCTKxz4(HtraW9uxNon6JjEPrLYgbXPyj82FgXOvuaHlaUwYRmC)WPia42FgjAKpbhvsROMIrX)EumeMPu2iOVJoUUf)rs3BqkAmXUzj4ZFKKNLH4eSMO0Rh2fNILW7Dbe(z1hnY9KwaCTKxz4(HtraWGUU0S6Jmu3ikLncmSTg)tsiNf4cGRL8kd3pCkca(yOPGVlOszJWaDbu0RrCGAxrUKAWZQ3U(MGLxcVYEqsS5ODg2wJpqxazIdwKBexdoXjYlaUwYRmC)WPia42FgXOvuaHkLncmSTgh8KsZQpsY1GYc5p6AXUcaAGUak61ioqTRixsn4z1BxFtWYlHxzpij2C0IfaPVjy5LWRShKeBos(cGRL8kd3pCkcaUN660PrFmXlnQu2i8SvQJaVU4Zhyl1PqCfMrSPeNILWF2k1rxeSyDjVIOyBYxaCTKxz4(HtraWT)ms0iFcoQKwrnfJI)9OyimtPSr4zRuhbEDXNpWwQtH4kmJytjoflH)SvQJUiyX6sEfrX2KVa4AjVYW9dNIaGB)zeJwrbeQu2iaOb6cOOxJ4a1UICj1GNvVD9nblVeEL9GKyZrlwaK(MGLxcVYEqsS54cGRL8kd3pCkca(yOPGVlOsAf1umk(3JIHWmLYgHNTsDe41fF(aBPofLvWAInL4uSe(ZwPo6IGfRl5vefBt(cGRL8kd3pCkcaUN660PrFmXlnUa4AjVYW9dNIaGB)zKOr(eCujTIAkgf)7rXqy2cGRL8kd3pCkcag09v8AXUzj4Va4AjVYW9dNIaG9x7fgL7FSKfGfaIyHt)OlGw41wOAwJ37pJVqG3rZQFH)jUKxTqBTqJ4Vyw4mYywid2Uhx40N6ctZc9jEsDgkUa4AjVYWzote4D0S6ja66sZQpYqDJOu2iWW2A8pjHCwGlaUwYRmCMZebEhnR(Pia4hjDVbPOXe7MLGVszJGRLCcgXcjLOrzcwBXYZwixssyuUiXioHE9WUcItXs49Uac)S6Jg5EswSOVAWMchNGF7pJyXYZwy7(EKZKsw9r9rhKVaqelCU4FpkXSrGK3rBPWazyBn(7DY9Pg5gX1Gp1mYjQvyGmSTg)9o5(uJ8hj5zzMAg5eLb6cOi4v2ds4pBHT77r(7DY9PgNVqYcceDXSqFH0tuAHcO0SW0SWSeSg4yHYTqX)EuwOacxiOSheAKfc8Z7trXfIfssXf2nfql0Rf6mjnffxOaYLf2nP0f6absvCHV3j3NACHzBHpBHT77XbFH2aYLfYGz1VqVwiwijfxy3uaTqYSqJ4AWnkTW7xOxlelKKIlua5Ycfq4chidBRTWUjLUqZD1cXocmFCHxXxaCTKxz4mNjc8oAw9traWhdnf8DbvsROMIrX)EumeMPu2i8SvQJaVU4Zhyl1POmbRj2cGRL8kdN5mrG3rZQFkcaUN660PrFmXlnQu2i8SvQJaVU4Zhyl1PqCRjJDdqKsJI)9Oy49uxNon6JjEPrLjyTD9D0X1T4atk1)41IT)mc)rsEwgLj2cGRL8kdN5mrG3rZQFkcaU9NrIg5tWrL0kQPyu8VhfdHzkLncpBL6iWRl(8b2sDke3AYyxFhDCDloWKs9pETy7pJWFKKNLrzITa4AjVYWzote4D0S6NIaGB)zeJwrbeQu2iWW2ACWtknR(ijxdklK)ORf7pBL6iWRl(8b2sDkkRWmInL4uSe(ZwPo6IGfRl5vefBtUDdqKsJI)9Oy4T)mIrROacvMG12vGHT14d0fqM4Gf5gX1GtGiBXcGgOlGIEnIdu7kYLudEw9wSai9nblVeEL9GKyZrYxaCTKxz4mNjc8oAw9traWT)mIrROacvkBeE2k1rGxx85dSL6uuMGc2MytjoflH)SvQJUiyX6sEfrX2KB3aeP0O4FpkgE7pJy0kkGqLjyTDfyyBn(aDbKjoyrUrCn4eiYwSaOb6cOOxJ4a1UICj1GNvVflasFtWYlHxzpij2CK8faxl5vgoZzIaVJMv)uea8XqtbFxqL0kQPyu8VhfdHzkLncpBL6iWRl(8b2sDkktqbBtSPeNILWF2k1rxeSyDjVIOyBYxaCTKxz4mNjc8oAw9traW9uxNon6JjEPrLYgb9D0X1T4atk1)41IT)mc)rsEwgLF2c5sscJYfbt7pBL6iWRl(8b2sDkehmjJDdqKsJI)9Oy49uxNon6JjEPrLjy9cGRL8kdN5mrG3rZQFkcaU9NrIg5tWrL0kQPyu8VhfdHzkLnc67OJRBXbMuQ)XRfB)ze(JK8Smk)SfYLKegLlcM2F2k1rGxx85dSL6uioysMfGfaIyHt)OlGw41wOAwJ37pJVqIUwYj4cjlN4sE1cGRL8kdN5mrj1GNvpHJHMc(UGkPvutXO4FpkgcZukBeE2k1rGxx85dSL6uuMayGmlaUwYRmCMZeLudEw9traWps6EdsrJj2nlbFLYgbXPyj8ExaHFw9rJCpjlw0xnytHJtWV9NrSy5zlSDFpYzsjR(O(OdlwCTKtWiwiPenktW6faxl5vgoZzIsQbpR(PiayqxxAw9rgQBeLYgbg2wJ)jjKZc0UcpBL6iWRl(8b2sDkeNyeZILNTqUKKWOCrBtCc96HflgGiLgf)7rXWbDDPz1hzOUruMG1KVa4AjVYWzotusn4z1pfbaFm0uW3fujTIAkgf)7rXqyMszJWZwixssyuUiys8E9WILNTsDe41fF(aBPofLjaMeBbW1sELHZCMOKAWZQFkcaU9NrmAffqOszJadBRXbpP0S6JKCnOSqolq7gGiLgf)7rXWB)zeJwrbeQmbRTRaGgOlGIEnIdu7kYLudEw9213eS8s4v2dsInhTybq6BcwEj8k7bjXMJKVa4AjVYWzotusn4z1pfbad6(kETy3Se8vkBeE2k1rGxx85dSL6uuMaysg7pBHCjjHr5I2w5E9ybW1sELHZCMOKAWZQFkcaU9NrmAffqOszJGbisPrX)Eum82FgXOvuaHktWA7kWW2A8b6citCWICJ4AWjqKTybqd0fqrVgXbQDf5sQbpRElwaK(MGLxcVYEqsS5i5laUwYRmCMZeLudEw9traWhdnf8DbvsROMIrX)EumeMPu2i8SvQJaVU4Zhyl1POS1eZ(ZwOY2EbW1sELHZCMOKAWZQFkcag01LMvFKH6grPSrGHT14Fsc5SaxaCTKxz4mNjkPg8S6NIaG9x7fgL7FSeLYgHNTsDe41fF(aBPofLjgzwawaicIyHD4OJfcgl6VSWoC1iL8kZcarqel01sELHRp6icc9xiOb5zzIxlMAuPSrOL9GK4JK8SmeVxpwaiIfswRbx4G9ZQFHD6Ks9FHDtb0cjAAu7ab80p6cOfaxl5vgU(OJii0FzkcawdYZYeVwm1OszJaGeNILWpgAk47sELDg2wJdmPu)Jxl2(Zi8hj5zziUTTZW2ACGjL6F8AX2FgHZc0odBRX1hDebH(lCJ4AWvMWmYSaqelemIvm5ax41wyNoPu)xiRb9ECHDtb0cjAAu7ab80p6cOfaxl5vgU(OJii0FzkcawdYZYeVwm1OszJaGeNILWpgAk47sEL9b6cOi4v2ds4pBHT77rEZPuSI6N14d8Tdig2wJdmPu)Jxl2(ZiCwG2vGHT146JoIGq)fUrCn4ktygyWodBRXzlqhvXOrES6fqCwGwSWW2AC9rhrqO)c3iUgCLjmJOYU(o646wCGjL6F8AX2FgH)ijplJYZid5laUwYRmC9rhrqO)YueaSgKNLjETyQrLYgbajoflHFm0uW3L8k7aAGUakcEL9Ge(Zwy7(EK3CkfRO(zn(aF7mSTgxF0ree6VWnIRbxzcZiJDaXW2ACGjL6F8AX2FgHZc0U(o646wCGjL6F8AX2FgH)ijplJYwtMfaIyHD6hNGLSWoC0XcbJf9xw4nbFTdeyw9lCW(z1VqGjL6)cGRL8kdxF0ree6VmfbaRb5zzIxlMAuPSrqCkwc)yOPGVl5v2bedBRXbMuQ)XRfB)zeolq7kWW2AC9rhrqO)c3iUgCLjmdmyNHT14SfOJQy0ipw9ciolqlwyyBnU(OJii0FHBexdUYeMruzXI(o646wCGjL6F8AX2FgH)ijpldXTTDg2wJRp6icc9x4gX1GRmHzGj5lalaeXc70NKxTa4AjVYW13rhx3Ymfbad8K8kLYgbg2wJdmPu)Jxl2(ZiCwG2zyBnosc41f)4ZwySl6aVIZcCbGiwyhUJoUULzbW1sELHRVJoUULzkcagjb86IF8zlm2fDGxPu2iioflHFm0uW3L8k7kOVJoUUfhysP(hVwS9Nr4p6dfT)SfYLKegLlsmL71d7pBL6iWRl(8b2sDkktygzSyHHT14atk1)41IT)mcNfO9NTqUKKWOCrIPCVEqUflTShKeFKKNLH4wtMfaxl5vgU(o646wMPiayKeWRl(XNTWyx0bELszJG4uSeoZJUakETOjRX79NXT)SvQJaVU4Zhyl1POmysg7pBHCjjHr5Iet5E9WUcmSTgN5rxafVw0K149(Z4CwGwS0YEqs8rsEwgIBnziFbW1sELHRVJoUULzkcagjb86IF8zlm2fDGxPu2iioflHNAu7aT)SfsCBVa4AjVYW13rhx3YmfbadmPu)Jxl2(ZikLncItXs4mp6cO41IMSgV3Fg3Uc67OJRBXzE0fqXRfnznEV)mo)rsEwglw03rhx3IZ8OlGIxlAYA8E)zC(J(qr7pBL6iWRl(8b2sDkehmqgYxaCTKxz467OJRBzMIaGbMuQ)XRfB)zeLYgbXPyj8uJAhODaXW2ACGjL6F8AX2FgHZcCbW1sELHRVJoUULzkcagysP(hVwS9NrukBeeNILWpgAk47sELDfeNILW7Dbe(z1hnY9K4y5muCyNHT14ps6EdsrJj2nlbFolqlwaK4uSeEVlGWpR(OrUNehlNHIdYxaCTKxz467OJRBzMIaGzE0fqXRfnznEV)mUszJadBRXbMuQ)XRfB)zeolWfaxl5vgU(o646wMPia42FgPRIpjtSX(kQu2iWW2ACGjL6F8AX2FgH)ijpldX71d7mSTghysP(hVwS9Nr4SaTdiXPyj8JHMc(UKxTa4AjVYW13rhx3Ymfba3(ZiDv8jzIn2xrLYgbxl5emIfskrJYeS2UcmSTghysP(hVwS9Nr4SaTZW2ACGjL6F8AX2FgH)ijpldX71dlwEphrCcwc3hddh7yAeJ93ZreNGLW9XWWFKKNLH496HflTShKeFKKNLH496b5laUwYRmC9D0X1TmtraWT)msxfFsMyJ9vuPSrqCkwc)yOPGVl5v2bedBRXbMuQ)XRfB)zeolq7kOadBRXzlqhvXOrES6fqCwGwSaOb6cOi4v2ds4pBHT77rEZPuSI6N14d8j3UcdKHT14V3j3NAKBexdobIzXcGgOlGIGxzpiH)Sf2UVh5V3j3NAKCYxaCTKxz467OJRBzMIaGbPiWtaHpPuhb(OblnQu2iioflHZ8OlGIxlAYA8E)zC7pBL6iWRl(8b2sDkkdMKX(ZwOYeSTDg2wJdmPu)Jxl2(ZiCwGwSaiXPyjCMhDbu8ArtwJ37pJB)zRuhbEDXNpWwQtrzcwtSfaxl5vgU(o646wMPia43tdghOpukBeyyBnoWKs9pETy7pJWzbUa4AjVYW13rhx3YmfbaBC9NTuNonc01IszJGRLCcgXcjLOrzcwBxbGOW7bDSu(JK8SmeVxpSyr8VhfUKKWOCXrIeVxpiFbW1sELHRVJoUULzkcaEGUak61ioqTROszJGRLCcgXcjLOrzIzXYZwy7(EKdee6)r6k0SaSaqelSd3eS8swirNjPPKOzbW1sELHRVjy5LyimqxazIdwuPSr49CeXjyjCFmm8SuEgXSybqVNJioblH7JHHJDmnIXIfxl5emIfskrJYeSEbW1sELHRVjy5LyMIaGnD9Nuw9rsPrukBeCTKtWiwiPeneMz)zRuhbEDXNpWwQtrzBBxFhDCDloWKs9pETy7pJWFKKNLH422oGeNILWzE0fqXRfnznEV)mUDfa075iItWs4(yy4yhtJySy59CeXjyjCFmm8SuEgXiFbW1sELHRVjy5LyMIaGnD9Nuw9rsPrukBeCTKtWiwiPenktWA7asCkwcN5rxafVw0K149(Z4laUwYRmC9nblVeZueaSPR)KYQpsknIszJG4uSeoZJUakETOjRX79NXTRadBRXzE0fqXRfnznEV)moNfODfCTKtWiwiPeneMz)zRuhbEDXNpWwQtrzWKmwS4AjNGrSqsjAuMG12F2k1rGxx85dSL6uugmqgYTybqmSTgN5rxafVw0K149(Z4CwG213rhx3IZ8OlGIxlAYA8E)zC(JK8SmKVa4AjVYW13eS8smtraWoZrklxYRI0KeJszJGRLCcgXcjLOHWm767OJRBXbMuQ)XRfB)ze(JK8Sme322vaqVNJioblH7JHHJDmnIXIL3ZreNGLW9XWWZs5zeJ8faxl5vgU(MGLxIzkca2zosz5sEvKMKyukBeCTKtWiwiPenktW6faxl5vgU(MGLxIzkca2aY1GtXOacJSv37fqkQu2i4AjNGrSqsjAimZU(o646wCGjL6F8AX2FgH)ijpldXTTDfa075iItWs4(yy4yhtJySy59CeXjyjCFmm8SuEgXiFbW1sELHRVjy5LyMIaGnGCn4umkGWiB19EbKIkLncUwYjyelKuIgLjy9cWcarSqWigAk47sE1c)tCjVAbW1sELHFm0uW3L8kcps6EdsrJj2nlbFLYgbxl5emIfskrJYeSTDfeNILW7Dbe(z1hnY9KSyrF1Gnfoob)2FgXILNTW299iNjLS6J6JoiFbW1sELHFm0uW3L8QPiayqxxAw9rgQBeLYgbanoH3(ZiXgobFUKAWZQ3oGyyBno4jLMvFKKRbLfYzbUa4AjVYWpgAk47sE1ueaC7pJy0kkGqLYgbg2wJdEsPz1hj5AqzH8hDTy3aeP0O4FpkgE7pJy0kkGqLjyTDfyyBn(aDbKjoyrUrCn4eiYwSaOb6cOOxJ4a1UICj1GNvVflasFtWYlHxzpij2CK8faxl5vg(XqtbFxYRMIaGpgAk47cQKwrnfJI)9OyimtPSrGHT14GNuAw9rsUguwi)rxlwSaig2wJ)jjKZc0UbisPrX)EumCqxxAw9rgQBeLjy7faxl5vg(XqtbFxYRMIaG7PUoDA0ht8sJkLncgGiLgf)7rXW7PUoDA0ht8sJktWA7k8SvQJaVU4Zhyl1Pq8zKXILNTqUKKWOCrRvUxpi3IffgidBRXFVtUp1i3iUgCItmlwgidBRXFVtUp1i)rsEwgIpJyKVa4AjVYWpgAk47sE1ueaC7pJenYNGJkLnc6RgSPWX3hP2LS6Jm0RRDg2wJJVpsTlz1hzOxxUrCn4eS2URLCcgXcjLOHWSfaxl5vg(XqtbFxYRMIaGbDDPz1hzOUrukBeyyBn(NKqolq7gGiLgf)7rXWbDDPz1hzOUruMG1laUwYRm8JHMc(UKxnfba3tDD60OpM4LgvkBemarknk(3JIH3tDD60OpM4LgvMG1laUwYRm8JHMc(UKxnfba3(ZirJ8j4OsAf1umk(3JIHWmLYgbajoflH7tCQxAqODaXW2ACWtknR(ijxdklKZc0IfXPyjCFIt9sdcTdig2wJ)jjKZcCbW1sELHFm0uW3L8QPiayqxxAw9rgQBeLYgbg2wJ)jjKZcCbW1sELHFm0uW3L8QPia4JHMc(UGkPvutXO4FpkgcZwawaiIf2PVJMv)c7u3VqWigAk47sELTwOQ4Vyw4mYSqdQVAywid2UhxyNoPu)x41wyN6pJSq9rcnl8ATf2bY6laUwYRm8JHMc(UKxfbEhnREcps6EdsrJj2nlbFLYgbXPyj8ExaHFw9rJCpjlw0xnytHJtWV9NrSy5zlSDFpYzsjR(O(OdlwCTKtWiwiPenktW6faxl5vg(XqtbFxYRIaVJMv)ueamORlnR(id1nIszJadBRX)KeYzbUa4AjVYWpgAk47sEve4D0S6NIaGpgAk47cQKwrnfJI)9OyimtPSrGHT14GNuAw9rsUguwi)rxllaUwYRm8JHMc(UKxfbEhnR(Pia4EQRtNg9XeV0OszJGbisPrX)Eum8EQRtNg9XeV0OYeS2(ZwPoc86IpFGTuNcXbdKzbW1sELHFm0uW3L8QiW7Oz1pfba3(ZirJ8j4OsAf1umk(3JIHWmLYgHNTsDe41fF(aBPofIt2iZcGRL8kd)yOPGVl5vrG3rZQFkca(yOPGVlOsAf1umk(3JIHWmLYgHNTqLbZfaxl5vg(XqtbFxYRIaVJMv)ueaC7pJy0kkGqLYgbxl5emIfskrJYeat7kaOb6cOOxJ4a1UICj1GNvVD9nblVeEL9GKyZrlwaK(MGLxcVYEqsS5i5lalaeXcjlUoD6cj6mjnLenlaUwYRm831PtneyO3nIn2xrLYgbg2wJdmPu)Jxl2(ZiCwGlaUwYRm831PtntraWm4BWh8S6vkBeyyBnoWKs9pETy7pJWzbUa4AjVYWFxNo1mfba7V2lmcKLAqLYgbfaedBRXbMuQ)XRfB)zeolq7UwYjyelKuIgLjyn5wSaig2wJdmPu)Jxl2(ZiCwG2v4zlKpWwQtrzceZ(ZwPoc86IpFGTuNIYeadKH8faxl5vg(760PMPiayA2dsmrWyWo6jHLOu2iWW2ACGjL6F8AX2FgHZcCbW1sELH)UoDQzkca2lnAK3PrTtPkLncmSTghysP(hVwS9Nr4SaTZW2ACKeWRl(XNTWyx0bEfNf4cGRL8kd)DD6uZueaClFKHE3qPSrGHT14atk1)41IT)mc)rsEwgItGiBNHT14ijGxx8JpBHXUOd8kolWfaxl5vg(760PMPiaygVpETO8PgCJszJadBRXbMuQ)XRfB)zeolq7UwYjyelKuIgcZSRadBRXbMuQ)XRfB)ze(JK8SmeNy2fNILW1hDebH(lCSCgkoSybqItXs46JoIGq)fowodfh2zyBnoWKs9pETy7pJWFKKNLH42M8fGfaIyHQIxd)hl0KvpfbJl(3JYc)tCjVAbW1sELHBeVg(pi8iP7nifnMy3Se8vkBeeNILW7Dbe(z1hnY9KSyrF1Gnfoob)2FgXILNTW299iNjLS6J6JowaCTKxz4gXRH)JPia4EQRtNg9XeV0OszJaGgOlGIGxzpiH)Sf2UVh5V3j3NA0UcdKHT14V3j3NAKBexdoXjMfldKHT14V3j3NAK)ijpldXjBKVa4AjVYWnIxd)htraWT)ms0iFcoQu2iOVJoUUf)rs3BqkAmXUzj4ZFKKNLH4eSMO0Rh2fNILW7Dbe(z1hnY9KwaCTKxz4gXRH)JPia42FgjAKpbhvkBe0xnytHJVpsTlz1hzOxx7mSTghFFKAxYQpYqVUCJ4AWjyTfl6RgSPWzlk6gq4i2ES6efTZW2AC2IIUbeoIThRorr(JK8Sme322zyBnoBrr3achX2JvNOiNf4cGRL8kd3iEn8Fmfbad66sZQpYqDJOu2iWW2A8pjHCwGlaUwYRmCJ41W)Xuea8XqtbFxqLYgbaXW2A82FDcwrGSudYzbAxCkwcV9xNGveil1GwSWW2ACWtknR(ijxdklK)ORflwgOlGIEnIdu7kYLudEw9213eS8s4v2dsInhTZW2A8b6citCWICJ4AWvMiBXYZwixssyuUiysCc96XcGRL8kd3iEn8Fmfba3(ZirJ8j4OszJWZwPoc86IpFGTuNcXvygXMsCkwc)zRuhDrWI1L8kIITjFbW1sELHBeVg(pMIaGpgAk47cQu2i8SvQJaVU4Zhyl1POScwtSPeNILWF2k1rxeSyDjVIOyBYxaCTKxz4gXRH)JPia42FgjAKpbhxaCTKxz4gXRH)JPiayq3xXRf7MLG)cGRL8kd3iEn8Fmfba7V2lmk3)yjlalaeXcT5ZcCumlaUwYRmC5ZcCumeYYOFwXzOyKSZ6LWskoWjPgvkBeyyBnoWKs9pETy7pJWzbAXI4FpkCjjHr5Ia1s0AYqCIzXsl7bjXhj5zziU1ZwaCTKxz4YNf4OyMIaGznymfKKrPSrGHT14atk1)41IT)mcNfODfaK4uSeEQrTd0IfXPyj8uJAhODg2wJdmPu)Jxl2(Zi8hj5zzuMWmYq(carqel0gq4cLplWrzHDtb0cfq4cbL9GqJSq0ijjxWXcN4uwuPf2nP0fYGlK1GJf2Y3il0RXcb65JJf2nfqlStNuQ)l8AlSt9Nr4laebrSqxl5vgU8zbokMPiaywdgtbjPKHEcb5ZcCuMPu2iaOj(Nodf5gGOoBjoIYNf4OyNHT14atk1)41IT)mcNfODfaK4uSeEQrTd0IfXPyj8uJAhODg2wJdmPu)Jxl2(Zi8hj5zzuMWmYqUDfaK8zbokCR5GCtuFhDCDllwKplWrHBnxFhDCDl(JK8SmwSmX)0zOix(SahLiWpVpffjmJClwKplWrHpJd8pn3lfJdGg(G9DjVszcTShKeFKKNLzbGiiIf6AjVYWLplWrXmfbaZAWykijLm0tiiFwGJI1kLncaAI)PZqrUbiQZwIJO8zbok2zyBnoWKs9pETy7pJWzbAxbajoflHNAu7aTyrCkwcp1O2bANHT14atk1)41IT)mc)rsEwgLjmJmKBxbajFwGJcFghKBI67OJRBzXI8zbok8zC9D0X1T4psYZYyXYe)tNHIC5ZcCuIa)8(uuKG1KBXI8zbokCR5a)tZ9sX4aOHpyFxYRuMql7bjXhj5zzwaicIyHeT2cVIQ4cVcx4vlK1Glu(SahLfc8Vj5anl0xidBRP0czn4cfq4cpbe(l8QfQVJoUUfFHGr)cZ2clmfq4Vq5ZcCuwiW)MKd0SqFHmSTMslK1GlK5eql8QfQVJoUUfFbGiiIf6AjVYWLplWrXmfbaZAWykijLm0tiiFwGJYmLYgbajFwGJcFghKBISgmYW2A2vq(SahfU1C9D0X1T4psYZYyXcGKplWrHBnhKBISgmYW2AKBXI(o646wCGjL6F8AX2FgH)ijplJYwtMfaIGiwORL8kdx(SahfZueamRbJPGKuYqpHG8zbokwRu2iai5ZcCu4wZb5MiRbJmSTMDfKplWrHpJRVJoUUf)rsEwglwaK8zbok8zCqUjYAWidBRrUfl67OJRBXbMuQ)XRfB)ze(JK8SmkBnzcsqcba]] )

end
