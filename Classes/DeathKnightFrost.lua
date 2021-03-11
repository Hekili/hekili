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


    spec:RegisterPack( "Frost DK", 20210310, [[d80tAcqiaYJak1LqiQ2KuXNuKgfj4uiQwfcrEfLQMfjQBPOsv7cLFbqnmeQoMIyzuIEgLctdHuxdHY2akX3uujghqjDoec16Ou08quCpeSpsKdIqslurvpKsfterjvxeHG2OIkPpIOKmsfvQ0jriXkbWlrusXmvuXnvuPI2jLWpvuPmueIYsruINsstLsPRIOKsFfHqglqXEf8xHgmOdt1IrLhtQjRWLH2Su(Su1ObYPfTAfvQWRbQMns3gr2TKFR0Wb0XriWYv1ZPy6exhvTDfLVlvA8uQ05jHwpIsnFkP9RYHjbBdQdxWGfwsClNqCBmH4SjG1j2WYjbvrrGyqfORb37XGA5KWG6C9xJCqY6K1eub6ksxFeSnOAw(xJbvqIa0ytad4(uaXZX0ljaBss8uxYT0V3eaBssAahu54tQquQaxqD4cgSWsIB5eIBJjeNnbSoXgtaRbvNxaTFqvnjzNGkOCmWkWfuhOrhujRJUa6GK1uzpi5GZ1FnYbWCN(RbDWjex5dAjXTCYbWbGDa5vpAoaM7pizbjTZWXbPUrM7nOERXb5nEpEWTDq7aYZYCWTDqIIgpOBoykhCSOPMkhei1v8GDrk9GzDqGVRLuJSGknnIjyBqD5OPGVl5wrG7sZQpyBWIjbBdQy5CuCeMpO6Aj3kO(iP9nifnMy3Se8dQd0O)eOKBfujY2LMv)bNR7FW5ghnf8Dj3YMhuv8xmhCcXpOb1BnmhKdB7JhKilPu)p42o4C9xJCq9scnhCBTdAhY6bv9Nc(PhufNILW6Dbe(z1hnY(Kyy5CuCCqRwpOERbFkmCg(TFncdlNJIJdA16bF(cB73JmUuYQpQx6GHLZrXXbTA9GUwYzyelKuIMdQeHdAzqcwyzW2GkwohfhH5dQ6pf8tpOYX3ASpjHmEGbvxl5wbvqBxAw9roQBKGeSWgbBdQy5CuCeMpO6Aj3kOUC0uW3fmOQ)uWp9GkhFRXapP0S6JKCnOSq2JUwcQAf1umk(3JIjyXKGeSGOd2guXY5O4imFqv)PGF6bvdqKsJI)9Oyy9uxNon6JzEPXdQeHdA5b7CWNVsDe42fF2aBPoLdsMdcwiEq11sUvqTN660PrFmZlngKGfelyBqflNJIJW8bvxl5wb12VgjAKpbhdQ6pf8tpO(8vQJa3U4Zgyl1PCqYCW5cXdQAf1umk(3JIjyXKGeSaSeSnOILZrXry(GQRLCRG6YrtbFxWGQ(tb)0dQpFHhuPds0bvTIAkgf)7rXeSysqcwmxc2guXY5O4imFqv)PGF6bvxl5mmIfskrZbvIWbj6d25GkCqaDWb6cOOxJ4a1UImj1GNv)b7Cq9odlVewL9GKyZXdA16bb0b17mS8syv2dsInhpi5bvxl5wb12VgXOvuaHbjibv9shrqO)sW2Gftc2guXY5O4imFq11sUvqvdYZYe3wm1yqDGg9NaLCRGkzTg8Gd(pR(dsKLuQ)hSBkGoirrJAhiGN)rxafu1Fk4NEqfqhuCkwcB5OPGVl5wmSCokooyNdYX3AmGjL6FCBX2VgH9ijplZbjZbTXb7Cqo(wJbmPu)JBl2(1imEGhSZb54BnMEPJii0FHzexd(bvIWbNq8GeSWYGTbvSCokocZhuDTKBfu1G8SmXTftnguhOr)jqj3kOo34ftoWdUTdsKLuQ)hK3GEpEWUPa6GefnQDGaE(hDbuqv)PGF6bvaDqXPyjSLJMc(UKBXWY5O44GDo4aDbue8k7bjSNVW2(9iR5ukwr9ZB8b(hSZbb0b54BngWKs9pUTy7xJW4bEWohuHdYX3Am9shrqO)cZiUg8dQeHdobSCWohKJV1y8fOLQy0ipw9cigpWdA16b54BnMEPJii0FHzexd(bvIWbNqeFWohuVlDSDlgWKs9pUTy7xJWEKKNL5GkDWje)GKhKGf2iyBqflNJIJW8bv9Nc(Phub0bfNILWwoAk47sUfdlNJIJd25Ga6Gd0fqrWRShKWE(cB73JSMtPyf1pVXh4FWohKJV1y6LoIGq)fMrCn4hujchCcXpyNdcOdYX3AmGjL6FCBX2VgHXd8GDoOEx6y7wmGjL6FCBX2VgH9ijplZbv6Gws8GQRLCRGQgKNLjUTyQXGeSGOd2guXY5O4imFq11sUvqvdYZYe3wm1yqDGg9NaLCRGkr2JZWsoODw64GZDr)LdUZWx7abMv)bh8Fw9heysP(hu1Fk4NEqvCkwcB5OPGVl5wmSCokooyNdcOdYX3AmGjL6FCBX2VgHXd8GDoOchKJV1y6LoIGq)fMrCn4hujchCcy5GDoihFRX4lqlvXOrES6fqmEGh0Q1dYX3Am9shrqO)cZiUg8dQeHdoHi(GwTEq9U0X2Tyatk1)42ITFnc7rsEwMdsMdAJd25GC8TgtV0ree6VWmIRb)Gkr4Gti6dsEqcsqD5OPGVl5wbBdwmjyBqflNJIJW8bvxl5wb1hjTVbPOXe7MLGFqDGg9NaLCRG6CJJMc(UKBDWFfxYTcQ6pf8tpO6AjNHrSqsjAoOseoOnoyNdQWbfNILW6Dbe(z1hnY(Kyy5CuCCqRwpOERbFkmCg(TFncdlNJIJdA16bF(cB73JmUuYQpQx6GHLZrXXbjpiblSmyBqflNJIJW8bv9Nc(Phub0bhRWA)AKydNHptsn4z1FWoheqhKJV1yGNuAw9rsUguwiJhyq11sUvqf02LMvFKJ6gjiblSrW2GkwohfhH5dQ6pf8tpOYX3AmWtknR(ijxdklK9ORLd25GgGiLgf)7rXWA)AeJwrbeEqLiCqlpyNdQWb54Bn2aDbKjo4rMrCn4hKWbbRh0Q1dcOdoqxaf9AehO2vKjPg8S6pOvRheqhuVZWYlHvzpij2C8GKhuDTKBfuB)AeJwrbegKGfeDW2GkwohfhH5dQUwYTcQlhnf8DbdQ6pf8tpOYX3AmWtknR(ijxdklK9ORLdA16bb0b54Bn2NKqgpWd25GgGiLgf)7rXWaTDPz1h5OUroOseoOncQAf1umk(3JIjyXKGeSGybBdQy5CuCeMpOQ)uWp9GQbisPrX)EumSEQRtNg9XmV04bvIWbT8GDoOch85RuhbUDXNnWwQt5GK5Gti(bTA9GpFHmjjHrzJwEqLoyVECqYpOvRhuHdoqo(wJ9ozVFQrMrCn4hKmhKyh0Q1doqo(wJ9ozVFQr2JK8SmhKmhCcXoi5bvxl5wb1EQRtNg9XmV0yqcwawc2guXY5O4imFqv)PGF6bv9wd(uy47Ju7sw9ro62LHLZrXXb7Cqo(wJHVpsTlz1h5OBxMrCn4hKWbT8GDoORLCggXcjLO5Geo4KGQRLCRGA7xJenYNGJbjyXCjyBqflNJIJW8bv9Nc(Phu54Bn2NKqgpWd25GgGiLgf)7rXWaTDPz1h5OUroOseoOLbvxl5wbvqBxAw9roQBKGeSaSgSnOILZrXry(GQ(tb)0dQgGiLgf)7rXW6PUoDA0hZ8sJhujch0YGQRLCRGAp11PtJ(yMxAmibliId2guXY5O4imFq11sUvqT9RrIg5tWXGQ(tb)0dQa6GItXsy(mN6LgeYWY5O44GDoiGoihFRXapP0S6JKCnOSqgpWdA16bfNILW8zo1lniKHLZrXXb7CqaDqo(wJ9jjKXdmOQvutXO4FpkMGftcsWIjepyBqflNJIJW8bv9Nc(Phu54Bn2NKqgpWGQRLCRGkOTlnR(ih1nsqcwmzsW2GkwohfhH5dQUwYTcQlhnf8DbdQAf1umk(3JIjyXKGeKGQr8A4)iyBWIjbBdQy5CuCeMpO6Aj3kO(iP9nifnMy3Se8dQd0O)eOKBfuvfVg(poOjREko3l(3JYb)vCj3kOQ)uWp9GQ4uSewVlGWpR(Or2NedlNJIJdA16b1Bn4tHHZWV9Rryy5CuCCqRwp4ZxyB)EKXLsw9r9shmSCokocsWcld2guXY5O4imFqv)PGF6bvaDWb6cOi4v2dsypFHT97r27K9(PgpyNdQWbhihFRXENS3p1iZiUg8dsMdsSdA16bhihFRXENS3p1i7rsEwMdsMdoxoi5bvxl5wb1EQRtNg9XmV0yqcwyJGTbvSCokocZhu1Fk4NEqvVlDSDl2JK23Gu0yIDZsWN9ijplZbjdHdA5bjshSxpoyNdkoflH17ci8ZQpAK9jXWY5O4iO6Aj3kO2(1irJ8j4yqcwq0bBdQy5CuCeMpOQ)uWp9GQERbFkm89rQDjR(ihD7YWY5O44GDoihFRXW3hP2LS6JC0TlZiUg8ds4GwEqRwpOERbFkm(IIUbeoIThlYwrgwohfhhSZb54BngFrr3achX2JfzRi7rsEwMdsMdAJd25GC8TgJVOOBaHJy7XISvKXdmO6Aj3kO2(1irJ8j4yqcwqSGTbvSCokocZhu1Fk4NEqLJV1yFscz8adQUwYTcQG2U0S6JCu3ibjybyjyBqflNJIJW8bv9Nc(Phub0b54Bnw7xYgRiqEQbz8apyNdkoflH1(LSXkcKNAqgwohfhh0Q1dYX3AmWtknR(ijxdklK9ORLdA16bhOlGIEnIdu7kYKudEw9hSZb17mS8syv2dsInhpyNdYX3ASb6citCWJmJ4AWpOsheSEqRwp4Zxitssyu2irFqYq4G96rq11sUvqD5OPGVlyqcwmxc2guXY5O4imFqv)PGF6b1NVsDe42fF2aBPoLdsMdQWbNqSdA)bfNILWE(k1rxeS4Dj3IHLZrXXbjsh0ghK8GQRLCRGA7xJenYNGJbjybynyBqflNJIJW8bv9Nc(PhuF(k1rGBx8zdSL6uoOshuHdAjXoO9huCkwc75RuhDrWI3LClgwohfhhKiDqBCqYdQUwYTcQlhnf8DbdsWcI4GTbvxl5wb12VgjAKpbhdQy5CuCeMpiblMq8GTbvxl5wbvq7xXTf7MLGFqflNJIJW8bjyXKjbBdQUwYTcQ(R9cJY(pwsqflNJIJW8bjibvU1ebUlnR(GTblMeSnOILZrXry(GQRLCRGkOTlnR(ih1nsqDGg9NaLCRG68p6cOdUTdQM149(14he4U0S6p4VIl5wh0Mh0i(lMdoH4MdYHT9Xdo)QEW0CqFMNuNJIbv9Nc(Phu54Bn2NKqgpWGeSWYGTbvSCokocZhu1Fk4NEq11sodJyHKs0CqLiCqlpOvRh85lKjjjmkBKyhKmeoyVECWohuHdkoflH17ci8ZQpAK9jXWY5O44GwTEq9wd(uy4m8B)Aegwohfhh0Q1d(8f22VhzCPKvFuV0bdlNJIJdsEq11sUvq9rs7BqkAmXUzj4hKGf2iyBqflNJIJW8bvxl5wb1LJMc(UGbvTIAkgf)7rXeSysqv)PGF6b1NVsDe42fF2aBPoLdQeHdAjXcQd0O)eOKBfuNk(3JsmBei521Mkmqo(wJ9ozVFQrMrCn42pHCICfgihFRXENS3p1i7rsEwg7NqorAGUakcEL9Ge2ZxyB)EK9ozVFQXPhKSGarxmh0piDfLpOaknhmnhmlbRbooOShu8VhLdkGWdck7bHg5Ga)C)uu8GyHKu8GDtb0b96GoxstrXdkGC5GDtk9GoqGufp47K9(Pgpy2o4ZxyB)ECWoOTGC5GCyw9h0RdIfssXd2nfqhK4h0iUgCJYhC)d61bXcjP4bfqUCqbeEWbYX3AhSBsPh0SBDq0UaZhp4wSGeSGOd2guXY5O4imFqv)PGF6b1NVsDe42fF2aBPoLdsMdAjXpyNdAaIuAu8VhfdRN660PrFmZlnEqLiCqlpyNdQ3Lo2UfdysP(h3wS9RrypsYZYCqLoiXcQUwYTcQ9uxNon6JzEPXGeSGybBdQy5CuCeMpO6Aj3kO2(1irJ8j4yqv)PGF6b1NVsDe42fF2aBPoLdsMdAjXpyNdQ3Lo2UfdysP(h3wS9RrypsYZYCqLoiXcQAf1umk(3JIjyXKGeSaSeSnOILZrXry(GQ(tb)0dQC8Tgd8KsZQpsY1GYczp6A5GDo4ZxPocC7IpBGTuNYbv6GkCWje7G2FqXPyjSNVsD0fblExYTyy5CuCCqI0bTXbj)GDoObisPrX)EumS2VgXOvuaHhujch0Yd25GkCqo(wJnqxazIdEKzexd(bjCqW6bTA9Ga6Gd0fqrVgXbQDfzsQbpR(dA16bb0b17mS8syv2dsInhpi5bvxl5wb12VgXOvuaHbjyXCjyBqflNJIJW8bv9Nc(PhuF(k1rGBx8zdSL6uoOseoOch0ge7G2FqXPyjSNVsD0fblExYTyy5CuCCqI0bTXbj)GDoObisPrX)EumS2VgXOvuaHhujch0Yd25GkCqo(wJnqxazIdEKzexd(bjCqW6bTA9Ga6Gd0fqrVgXbQDfzsQbpR(dA16bb0b17mS8syv2dsInhpi5bvxl5wb12VgXOvuaHbjybynyBqflNJIJW8bvxl5wb1LJMc(UGbv9Nc(PhuF(k1rGBx8zdSL6uoOseoOch0ge7G2FqXPyjSNVsD0fblExYTyy5CuCCqI0bTXbjpOQvutXO4FpkMGftcsWcI4GTbvSCokocZhu1Fk4NEqvVlDSDlgWKs9pUTy7xJWEKKNL5GkDWNVqMKKWOSrI(GDo4ZxPocC7IpBGTuNYbjZbjAIFWoh0aeP0O4Fpkgwp11PtJ(yMxA8Gkr4GwguDTKBfu7PUoDA0hZ8sJbjyXeIhSnOILZrXry(GQRLCRGA7xJenYNGJbv9Nc(Phu17shB3IbmPu)JBl2(1iShj5zzoOsh85lKjjjmkBKOpyNd(8vQJa3U4Zgyl1PCqYCqIM4bvTIAkgf)7rXeSysqcsqLBnrj1GNvFW2Gftc2guXY5O4imFq11sUvqD5OPGVlyqvROMIrX)EumblMeu1Fk4NEq95RuhbUDXNnWwQt5Gkr4GGfIhuhOr)jqj3kOo)JUa6GB7GQznEVFn(bjQAjNHhKSSIl5wbjyHLbBdQy5CuCeMpOQ)uWp9GQ4uSewVlGWpR(Or2NedlNJIJdA16b1Bn4tHHZWV9Rryy5CuCCqRwp4ZxyB)EKXLsw9r9shmSCokooOvRh01sodJyHKs0CqLiCqldQUwYTcQpsAFdsrJj2nlb)GeSWgbBdQy5CuCeMpOQ)uWp9GkhFRX(KeY4bEWohuHd(8vQJa3U4Zgyl1PCqYCqIrSdA16bF(czsscJYgTXbjdHd2Rhh0Q1dAaIuAu8Vhfdd02LMvFKJ6g5Gkr4GwEqYdQUwYTcQG2U0S6JCu3ibjybrhSnOILZrXry(GQRLCRG6YrtbFxWGQ(tb)0dQpFHmjjHrzJe9bjZb71JdA16bF(k1rGBx8zdSL6uoOseoirtSGQwrnfJI)9OycwmjibliwW2GkwohfhH5dQ6pf8tpOYX3AmWtknR(ijxdklKXd8GDoObisPrX)EumS2VgXOvuaHhujch0Yd25GkCqaDWb6cOOxJ4a1UImj1GNv)b7Cq9odlVewL9GKyZXdA16bb0b17mS8syv2dsInhpi5bvxl5wb12VgXOvuaHbjybyjyBqflNJIJW8bv9Nc(PhuF(k1rGBx8zdSL6uoOseoirt8d25GpFHmjjHrzJ24GkDWE9iO6Aj3kOcA)kUTy3Se8dsWI5sW2GkwohfhH5dQ6pf8tpOAaIuAu8VhfdR9RrmAffq4bvIWbT8GDoOchKJV1yd0fqM4GhzgX1GFqcheSEqRwpiGo4aDbu0RrCGAxrMKAWZQ)GwTEqaDq9odlVewL9GKyZXdsEq11sUvqT9RrmAffqyqcwawd2guXY5O4imFq11sUvqD5OPGVlyqv)PGF6b1NVsDe42fF2aBPoLdQ0bTKyhSZbF(cpOsh0gbvTIAkgf)7rXeSysqcwqehSnOILZrXry(GQ(tb)0dQC8Tg7tsiJhyq11sUvqf02LMvFKJ6gjiblMq8GTbvSCokocZhu1Fk4NEq95RuhbUDXNnWwQt5GkDqIr8GQRLCRGQ)AVWOS)JLeKGeu17shB3YeSnyXKGTbvSCokocZhu1Fk4NEqLJV1yatk1)42ITFncJh4b7Cqo(wJHKaUDXp(8fg7IoWTy8adQd0O)eOKBfujYwj3kO6Aj3kOcCLCRGeSWYGTbvSCokocZhuDTKBfursa3U4hF(cJDrh4wb1bA0FcuYTcQ2zx6y7wMGQ(tb)0dQItXsylhnf8Dj3IHLZrXXb7CqfoOEx6y7wmGjL6FCBX2VgH9Opu8GDo4Zxitssyu2iXoOshSxpoyNd(8vQJa3U4Zgyl1PCqLiCWje)GwTEqo(wJbmPu)JBl2(1imEGhSZbF(czsscJYgj2bv6G96Xbj)GwTEWw2dsIpsYZYCqYCqljEqcwyJGTbvSCokocZhu1Fk4NEqvCkwcJ7rxaf3w0K149(14mSCokooyNd(8vQJa3U4Zgyl1PCqLoirt8d25GpFHmjjHrzJe7GkDWE94GDoOchKJV1yCp6cO42IMSgV3VgNXd8GwTEWw2dsIpsYZYCqYCqlj(bjpO6Aj3kOIKaUDXp(8fg7IoWTcsWcIoyBqflNJIJW8bv9Nc(PhufNILWsnQDGmSCokooyNd(8fEqYCqBeuDTKBfursa3U4hF(cJDrh4wbjybXc2guXY5O4imFqv)PGF6bvXPyjmUhDbuCBrtwJ37xJZWY5O44GDoOchuVlDSDlg3JUakUTOjRX79RXzpsYZYCqRwpOEx6y7wmUhDbuCBrtwJ37xJZE0hkEWoh85RuhbUDXNnWwQt5GK5GGfIFqYdQUwYTcQatk1)42ITFnsqcwawc2guXY5O4imFqv)PGF6bvXPyjSuJAhidlNJIJd25Ga6GC8TgdysP(h3wS9Rry8adQUwYTcQatk1)42ITFnsqcwmxc2guXY5O4imFqv)PGF6bvXPyjSLJMc(UKBXWY5O44GDoOchuCkwcR3fq4NvF0i7tIHLZrXXb7Cqo(wJ9iP9nifnMy3Se8z8apOvRheqhuCkwcR3fq4NvF0i7tIHLZrXXbjpO6Aj3kOcmPu)JBl2(1ibjybynyBqflNJIJW8bv9Nc(Phu54BngWKs9pUTy7xJW4bguDTKBfu5E0fqXTfnznEVFnEqcwqehSnOILZrXry(GQ(tb)0dQC8TgdysP(h3wS9RrypsYZYCqYCWE94GDoihFRXaMuQ)XTfB)AegpWd25Ga6GItXsylhnf8Dj3IHLZrXrq11sUvqT9Rr6Q4tYeB8VIbjyXeIhSnOILZrXry(GQ(tb)0dQUwYzyelKuIMdQeHdA5b7CqfoihFRXaMuQ)XTfB)AegpWd25GC8TgdysP(h3wS9RrypsYZYCqYCWE94GwTEW3ZreNHLW8XWWq7MgXCWoh89CeXzyjmFmmShj5zzoizoyVECqRwpyl7bjXhj5zzoizoyVECqYdQUwYTcQTFnsxfFsMyJ)vmiblMmjyBqflNJIJW8bv9Nc(PhufNILWwoAk47sUfdlNJIJd25Ga6GC8TgdysP(h3wS9Rry8apyNdQWbv4GC8TgJVaTufJg5XQxaX4bEqRwpiGo4aDbue8k7bjSNVW2(9iR5ukwr9ZB8b(hK8d25GkCWbYX3AS3j79tnYmIRb)GeoiXoOvRheqhCGUakcEL9Ge2ZxyB)EK9ozVFQXds(bjpO6Aj3kO2(1iDv8jzIn(xXGeSyILbBdQy5CuCeMpOQ)uWp9GQ4uSeg3JUakUTOjRX79RXzy5CuCCWoh85RuhbUDXNnWwQt5GkDqIM4hSZbF(cpOseoOnoyNdYX3AmGjL6FCBX2VgHXd8GwTEqaDqXPyjmUhDbuCBrtwJ37xJZWY5O44GDo4ZxPocC7IpBGTuNYbvIWbTKybvxl5wbvqkcCfq4tk1rGpAWsJbjyXeBeSnOILZrXry(GQ(tb)0dQC8TgdysP(h3wS9Rry8adQUwYTcQVNgmoqFeKGfti6GTbvSCokocZhu1Fk4NEq11sodJyHKs0CqLiCqlpyNdQWbbIcRh0YtzpsYZYCqYCWE94GwTEqX)EuysscJYghjEqYCWE94GKhuDTKBfunU(ZwQtNgb6AjiblMqSGTbvSCokocZhu1Fk4NEq11sodJyHKs0CqLoiXoOvRh85lSTFpYacc9FjTfAyy5CuCeuDTKBfuhOlGIEnIdu7kgKGeuhyZ5PsW2Gftc2guDTKBfujL1i2EejBmOILZrXry(GeSWYGTbvSCokocZhuDTKBfuFK0(gKIgtSBwc(b1bA0FcuYTcQevGaPkEW56Vg5GZvCg(kFqsEwIN1bjkAfpOToDlZb9ACqWre4bjliP9nifnMdseLLG)b)LsZQpOQ)uWp9GQERbFkmCg(TFncdlNJIJd25GItXsy9Uac)S6JgzFsmSCokooyNdcOdkoflHTC0uW3LClgwohfhhSZb17shB3IbmPu)JBl2(1iShj5zzcsWcBeSnOILZrXry(GQRLCRGkOTlnR(ih1nsqDGg9NaLCRGkrfiqQIhCU(Rro4CfNH)b9ACqsEwIN1bjkAfpOToDltqv)PGF6bvaDWXkS2Vgj2Wz4ZKudEw9hSZbv4GItXsyPg1oqgwohfhh0Q1dQ3Lo2UfJ7rxaf3w0K149(14Shj5zzoOshCcXoOvRhuCkwcB5OPGVl5wmSCokooyNdQ3Lo2UfdysP(h3wS9RrypsYZYCWoheqhKJV1yGNuAw9rsUguwiJh4bjpibli6GTbvSCokocZhu1Fk4NEqLJV1yPwXO40TmShj5zzoiziCWE94GDoihFRXsTIrXPBzy8apyNdAaIuAu8VhfdRN660PrFmZlnEqLiCqlpyNdQWbb0bfNILW4E0fqXTfnznEVFnodlNJIJdA16b17shB3IX9OlGIBlAYA8E)AC2JK8SmhuPdoHyhK8GQRLCRGAp11PtJ(yMxAmibliwW2GkwohfhH5dQ6pf8tpOYX3ASuRyuC6wg2JK8SmhKmeoyVECWohKJV1yPwXO40TmmEGhSZbv4Ga6GItXsyCp6cO42IMSgV3VgNHLZrXXbTA9G6DPJTBX4E0fqXTfnznEVFno7rsEwMdQ0bNqSdsEq11sUvqT9RrIg5tWXGeSaSeSnOILZrXry(G6an6pbk5wbv7aAxdEqIQwYToinnYbL9GpFfuDTKBfu1oLgDTKBfPPrcQ00iXYjHbv9odlVetqcwmxc2guXY5O4imFq11sUvqv7uA01sUvKMgjOstJelNeguFxNo1eKGfG1GTbvSCokocZhuDTKBfu1oLgDTKBfPPrcQ00iXYjHbv5ZcCumbjybrCW2GkwohfhH5dQUwYTcQANsJUwYTI00ibvAAKy5KWGQEx6y7wMGeSycXd2guXY5O4imFqv)PGF6bvXPyjm9shrqO)cdlNJIJd25GC8TgtV0ree6VWmIRb)Gkr4Gti(b7Cqfo4a54Bn27K9(PgzgX1GFqchKyh0Q1dcOdoqxafbVYEqc75lSTFpYENS3p14bjpO6Aj3kOQDkn6Aj3kstJeuPPrILtcdQ6LoIGq)LGeSyYKGTbvSCokocZhu1Fk4NEqLJV1yCp6cO42IMSgV3VgNXdmO6Aj3kO(8v01sUvKMgjOstJelNegu5wtusn4z1hKGftSmyBqflNJIJW8bv9Nc(PhufNILW4E0fqXTfnznEVFnodlNJIJd25GkCq9U0X2TyCp6cO42IMSgV3VgN9ijplZbjZbNq8dsEq11sUvq95RORLCRinnsqLMgjwojmOYTMiWDPz1hKGftSrW2GkwohfhH5dQ6pf8tpOYX3AmGjL6FCBX2VgHXd8GDoO4uSe2YrtbFxYTyy5CuCeuDTKBfuF(k6Aj3kstJeuPPrILtcdQlhnf8Dj3kiblMq0bBdQy5CuCeMpOQ)uWp9GQ4uSe2YrtbFxYTyy5CuCCWohuVlDSDlgWKs9pUTy7xJWEKKNL5GK5GtiEq11sUvq95RORLCRinnsqLMgjwojmOUC0uW3LCRiWDPz1hKGftiwW2GkwohfhH5dQ6pf8tpO6AjNHrSqsjAoOseoOLbvxl5wb1NVIUwYTI00ibvAAKy5KWGQVyqcwmbSeSnOILZrXry(GQRLCRGQ2P0ORLCRinnsqLMgjwojmOAeVg(pcsqcQaFuVK4CjyBqcQVRtNAc2gSysW2GkwohfhH5dQUwYTcQC0DhXg)RyqDGg9NaLCRGkzX1PtpirLlPPKOjOQ)uWp9GkhFRXaMuQ)XTfB)AegpWGeSWYGTbvSCokocZhu1Fk4NEqLJV1yatk1)42ITFncJhyq11sUvqLdFd(GNvFqcwyJGTbvSCokocZhu1Fk4NEqvHdcOdYX3AmGjL6FCBX2VgHXd8GDoORLCggXcjLO5Gkr4GwEqYpOvRheqhKJV1yatk1)42ITFncJh4b7Cqfo4ZxiBGTuNYbvIWbj2b7CWNVsDe42fF2aBPoLdQeHdcwi(bjpO6Aj3kO6V2lmcKNAWGeSGOd2guXY5O4imFqv)PGF6bvo(wJbmPu)JBl2(1imEGbvxl5wbvA2dsmX5o4h9KWscsWcIfSnOILZrXry(GQ(tb)0dQC8TgdysP(h3wS9Rry8apyNdYX3AmKeWTl(XNVWyx0bUfJhyq11sUvq1lnAK3PrTtPbjybyjyBqflNJIJW8bv9Nc(Phu54BngWKs9pUTy7xJWEKKNL5GKHWbbRhSZb54Bngsc42f)4ZxySl6a3IXdmO6Aj3kO2Yh5O7ocsWI5sW2GkwohfhH5dQ6pf8tpOYX3AmGjL6FCBX2VgHXd8GDoORLCggXcjLO5Geo4Kd25GkCqo(wJbmPu)JBl2(1iShj5zzoizoiXoyNdkoflHPx6icc9xyy5CuCCqRwpiGoO4uSeMEPJii0FHHLZrXXb7Cqo(wJbmPu)JBl2(1iShj5zzoizoOnoi5bvxl5wbvoVpUTO8PgCtqcsqv(SahftW2Gftc2guXY5O4imFq11sUvqnlJ(5fNJIrIaEVeEsXbol1yqDGg9NaLCRGQTFwGJIjOQ)uWp9GkhFRXaMuQ)XTfB)AegpWdA16bf)7rHjjjmkBeOwIws8dsMdsSdA16bBzpij(ijplZbjZbTCsqcwyzW2GkwohfhH5dQ6pf8tpOYX3AmGjL6FCBX2VgHXd8GDoOcheqhuCkwcl1O2bYWY5O44GwTEqXPyjSuJAhidlNJIJd25GC8TgdysP(h3wS9RrypsYZYCqLiCWje)GKhuDTKBfu5nymfKKjibjOQ3zy5Lyc2gSysW2GkwohfhH5dQUwYTcQd0fqM4GhdQd0O)eOKBfuTZodlVKdsu5sAkjAcQ6pf8tpO(EoI4mSeMpggwwhuPdoHyh0Q1dcOd(EoI4mSeMpgggA30iMdA16bDTKZWiwiPenhujch0YGeSWYGTbvSCokocZhu1Fk4NEq11sodJyHKs0CqchCYb7CWNVsDe42fF2aBPoLdQ0bTXb7Cq9U0X2Tyatk1)42ITFnc7rsEwMdsMdAJd25Ga6GItXsyCp6cO42IMSgV3VgNHLZrXXb7CqfoiGo475iIZWsy(yyyODtJyoOvRh89CeXzyjmFmmSSoOshCcXoi5bvxl5wbvtx)jLvFKuAKGeSWgbBdQy5CuCeMpOQ)uWp9GQRLCggXcjLO5Gkr4GwEWoheqhuCkwcJ7rxaf3w0K149(14mSCokocQUwYTcQMU(tkR(iP0ibjybrhSnOILZrXry(GQ(tb)0dQItXsyCp6cO42IMSgV3VgNHLZrXXb7CqfoihFRX4E0fqXTfnznEVFnoJh4b7CqfoORLCggXcjLO5Geo4Kd25GpFL6iWTl(Sb2sDkhuPds0e)GwTEqxl5mmIfskrZbvIWbT8GDo4ZxPocC7IpBGTuNYbv6GGfIFqYpOvRheqhKJV1yCp6cO42IMSgV3VgNXd8GDoOEx6y7wmUhDbuCBrtwJ37xJZEKKNL5GKhuDTKBfunD9Nuw9rsPrcsWcIfSnOILZrXry(GQ(tb)0dQUwYzyelKuIMds4GtoyNdQ3Lo2UfdysP(h3wS9RrypsYZYCqYCqBCWohuHdcOd(EoI4mSeMpgggA30iMdA16bFphrCgwcZhddlRdQ0bNqSdsEq11sUvq15wsz5sUvKMK4csWcWsW2GkwohfhH5dQ6pf8tpO6AjNHrSqsjAoOseoOLbvxl5wbvNBjLLl5wrAsIliblMlbBdQy5CuCeMpOQ)uWp9GQRLCggXcjLO5Geo4Kd25G6DPJTBXaMuQ)XTfB)Ae2JK8SmhKmh0ghSZbv4Ga6GVNJiodlH5JHHH2nnI5GwTEW3ZreNHLW8XWWY6GkDWje7GKhuDTKBfunGCn4umkGWiF1DFbKIbjybynyBqflNJIJW8bv9Nc(PhuDTKZWiwiPenhujch0YGQRLCRGQbKRbNIrbeg5RU7lGumibjO6lgSnyXKGTbvSCokocZhuhOr)jqj3kOsuxIWdswwXLCRGQRLCRG6JK23Gu0yIDZsWpiblSmyBqflNJIJW8bv9Nc(PhufNILWA)AeJwrbeYWY5O4iO6Aj3kO2tDD60OpM5LgdsWcBeSnOILZrXry(GQRLCRGA7xJenYNGJbv9Nc(Phu17shB3I9iP9nifnMy3Se8zpsYZYCqYq4GwEqI0b71Jd25GItXsy9Uac)S6JgzFsmSCokocQAf1umk(3JIjyXKGeSGOd2guXY5O4imFqv)PGF6bvo(wJ9jjKXdmO6Aj3kOcA7sZQpYrDJeKGfelyBqflNJIJW8bv9Nc(PhuhOlGIEnIdu7kYKudEw9hSZb17mS8syv2dsInhpyNdYX3ASb6citCWJmJ4AWpOsheSguDTKBfuxoAk47cgKGfGLGTbvSCokocZhu1Fk4NEqLJV1yGNuAw9rsUguwi7rxlhSZbv4Ga6Gd0fqrVgXbQDfzsQbpR(d25G6DgwEjSk7bjXMJh0Q1dcOdQ3zy5LWQShKeBoEqYdQUwYTcQTFnIrROacdsWI5sW2GkwohfhH5dQ6pf8tpO(8vQJa3U4Zgyl1PCqYCqfo4eIDq7pO4uSe2ZxPo6IGfVl5wmSCokooir6G24GKhuDTKBfu7PUoDA0hZ8sJbjybynyBqflNJIJW8bvxl5wb12VgjAKpbhdQ6pf8tpO(8vQJa3U4Zgyl1PCqYCqfo4eIDq7pO4uSe2ZxPo6IGfVl5wmSCokooir6G24GKhu1kQPyu8VhftWIjbjybrCW2GkwohfhH5dQ6pf8tpOcOdoqxaf9AehO2vKjPg8S6pyNdQ3zy5LWQShKeBoEqRwpiGoOENHLxcRYEqsS5yq11sUvqT9RrmAffqyqcwmH4bBdQy5CuCeMpO6Aj3kOUC0uW3fmOQ)uWp9G6ZxPocC7IpBGTuNYbv6GkCqlj2bT)GItXsypFL6Olcw8UKBXWY5O44GePdAJdsEqvROMIrX)EumblMeKGftMeSnO6Aj3kO2tDD60OpM5LgdQy5CuCeMpiblMyzW2GkwohfhH5dQUwYTcQTFns0iFcogu1kQPyu8VhftWIjbjyXeBeSnO6Aj3kOcA)kUTy3Se8dQy5CuCeMpiblMq0bBdQUwYTcQ(R9cJY(pwsqflNJIJW8bjibjOodFtUvWcljULtiULtSrqTR)vw9MGkrerLSybrXcYkBEWdAli8GjjG7lhST)bNUC0uW3LCRiWDPz1p9GpseWNpooOzjHh05LLKl44GAqE1Jg2bWCYcp4eBEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPhuHj2LC2bWCYcp4eBEq7S1m8fCCWPpFHT97rgyMEqzp40NVW2(9idmmSCokoMEqfMyxYzhaZjl8GtS5bTZwZWxWXbNQ3AWNcdmtpOShCQERbFkmWWWY5O4y6bvyIDjNDaCaqerujlwquSGSYMh8G2ccpysc4(YbB7FWP6LoIGq)LPh8rIa(8XXbnlj8GoVSKCbhhudYRE0WoaMtw4bNyZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GkmXUKZoaMtw4bT0Mh0oBndFbhhCQ4uSegyMEqzp4uXPyjmWWWY5O4y6bvyIDjNDamNSWdAdBEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPhuHj2LC2bWCYcpirBZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GkmXUKZoaoaiIiQKflikwqwzZdEqBbHhmjbCF5GT9p40LJMc(UKBn9GpseWNpooOzjHh05LLKl44GAqE1Jg2bWCYcp4eBEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPhuHj2LC2bWCYcp4eBEq7S1m8fCCWPpFHT97rgyMEqzp40NVW2(9idmmSCokoMEqfMyxYzhaZjl8GtS5bTZwZWxWXbNQ3AWNcdmtpOShCQERbFkmWWWY5O4y6bvyIDjNDamNSWdcwS5bTZwZWxWXbNQ3AWNcdmtpOShCQERbFkmWWWY5O4y6bvyIDjNDamNSWdseBZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GkyPDjNDaCaqerujlwquSGSYMh8G2ccpysc4(YbB7FWPCRjkPg8S6NEWhjc4Zhhh0SKWd68YsYfCCqniV6rd7ayozHh0sBEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPhuHj2LC2bWCYcpOL28G2zRz4l44GtF(cB73JmWm9GYEWPpFHT97rgyyy5CuCm9GkmXUKZoaMtw4bT0Mh0oBndFbhhCQERbFkmWm9GYEWP6Tg8PWaddlNJIJPhuHj2LC2bWbarerLSybrXcYkBEWdAli8GjjG7lhST)bNQ3zy5LyMEWhjc4Zhhh0SKWd68YsYfCCqniV6rd7ayozHh0sBEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPhuHj2LC2bWCYcpOnS5bTZwZWxWXbNkoflHbMPhu2dovCkwcdmmSCokoMEqxoir4CBohuHj2LC2bWCYcpirBZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GkmXUKZoaoaiIiQKflikwqwzZdEqBbHhmjbCF5GT9p4uJ41W)X0d(iraF(44GMLeEqNxwsUGJdQb5vpAyhaZjl8GtS5bTZwZWxWXbNkoflHbMPhu2dovCkwcdmmSCokoMEqfMyxYzhaZjl8GtS5bTZwZWxWXbN(8f22VhzGz6bL9GtF(cB73JmWWWY5O4y6bD5GeHZT5CqfMyxYzhaZjl8GtS5bTZwZWxWXbNQ3AWNcdmtpOShCQERbFkmWWWY5O4y6bvyIDjNDamNSWdAdBEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPh0Ldseo3MZbvyIDjNDamNSWds028G2zRz4l44Gt1Bn4tHbMPhu2dovV1Gpfgyyy5CuCm9GkyPDjNDamNSWdcwS5bTZwZWxWXbNkoflHbMPhu2dovCkwcdmmSCokoMEqfMyxYzhaZjl8GZfBEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPhuHj2LC2bWCYcpiy1Mh0oBndFbhhCQ4uSegyMEqzp4uXPyjmWWWY5O4y6bvyIDjNDaCaqerujlwquSGSYMh8G2ccpysc4(YbB7FWPCRjcCxAw9tp4Jeb85JJdAws4bDEzj5cooOgKx9OHDamNSWdAPnpOD2Ag(coo4uXPyjmWm9GYEWPItXsyGHHLZrXX0dQWe7so7ayozHh0sBEq7S1m8fCCWPpFHT97rgyMEqzp40NVW2(9idmmSCokoMEqfMyxYzhaZjl8GwAZdANTMHVGJdovV1GpfgyMEqzp4u9wd(uyGHHLZrXX0dQWe7so7ayozHheSyZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GkmXUKZoaMtw4bNl28G2zRz4l44GtfNILWaZ0dk7bNkoflHbggwohfhtpOctSl5SdG5KfEqWQnpOD2Ag(coo4uXPyjmWm9GYEWPItXsyGHHLZrXX0dQWe7so7a4aGiIOswSGOybzLnp4bTfeEWKeW9Ld22)Gt17shB3Ym9GpseWNpooOzjHh05LLKl44GAqE1Jg2bWCYcpOL28G2zRz4l44GtfNILWaZ0dk7bNkoflHbggwohfhtpOctSl5SdG5KfEqByZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GkmXUKZoaMtw4bjABEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPhuHj2LC2bWCYcpiXS5bTZwZWxWXbNkoflHbMPhu2dovCkwcdmmSCokoMEqfMyxYzhaZjl8GGfBEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPhuHj2LC2bWCYcp4CXMh0oBndFbhhCQ4uSegyMEqzp4uXPyjmWWWY5O4y6bvyIDjNDamNSWdseBZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GUCqIW52CoOctSl5SdG5KfEWjtS5bTZwZWxWXbNkoflHbMPhu2dovCkwcdmmSCokoMEqfMyxYzhaZjl8GtS0Mh0oBndFbhhCQ4uSegyMEqzp4uXPyjmWWWY5O4y6bvWs7so7ayozHhCcXS5bTZwZWxWXbN(8f22VhzGz6bL9GtF(cB73JmWWWY5O4y6bD5GeHZT5CqfMyxYzhahaerevYIfefliRS5bpOTGWdMKaUVCW2(hCQ8zbokMPh8rIa(8XXbnlj8GoVSKCbhhudYRE0WoaMtw4bT0Mh0oBndFbhhCQ4uSegyMEqzp4uXPyjmWWWY5O4y6bvWs7so7a4aGiIOswSGOybzLnp4bTfeEWKeW9Ld22)GthyZ5PY0d(iraF(44GMLeEqNxwsUGJdQb5vpAyhaZjl8GwAZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GkyPDjNDamNSWdAPnpOD2Ag(coo4u9wd(uyGz6bL9Gt1Bn4tHbggwohfhtpOctSl5SdG5KfEqByZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GkyPDjNDamNSWds028G2zRz4l44GtfNILWaZ0dk7bNkoflHbggwohfhtpOctSl5SdG5KfEqIzZdANTMHVGJdovCkwcdmtpOShCQ4uSegyyy5CuCm9GkmXUKZoaMtw4bNqCBEq7S1m8fCCWPItXsyGz6bL9GtfNILWaddlNJIJPhuHj2LC2bWCYcp4elT5bTZwZWxWXbNkoflHbMPhu2dovCkwcdmmSCokoMEqfMyxYzhaZjl8GtSHnpOD2Ag(coo4uXPyjmWm9GYEWPItXsyGHHLZrXX0d6YbjcNBZ5GkmXUKZoaMtw4bNq028G2zRz4l44GtfNILWaZ0dk7bNkoflHbggwohfhtpOctSl5SdGdaIiIkzXcIIfKv28Gh0wq4btsa3xoyB)do1xC6bFKiGpFCCqZscpOZlljxWXb1G8QhnSdG5KfEqlT5bTZwZWxWXbNkoflHbMPhu2dovCkwcdmmSCokoMEqxoir4CBohuHj2LC2bWCYcpOnS5bTZwZWxWXbNkoflHbMPhu2dovCkwcdmmSCokoMEqxoir4CBohuHj2LC2bWCYcp4CXMh0oBndFbhhCQ4uSegyMEqzp4uXPyjmWWWY5O4y6bvyIDjNDamNSWdcwT5bTZwZWxWXbNkoflHbMPhu2dovCkwcdmmSCokoMEqfMyxYzhaZjl8GtiUnpOD2Ag(coo4uXPyjmWm9GYEWPItXsyGHHLZrXX0dQWe7so7a4aGOqc4(coo4elpORLCRdstJyyhabvdquhSWsInjOc83wsXGkyd2hKSo6cOdswtL9GKdox)1ihaGnyFW5o9xd6GtiUYh0sIB5KdGdaWgSpODa5vpAoaaBW(GZ9hKSGK2z44Gu3iZ9guV14G8gVhp42oODa5zzo42oirrJh0nhmLdow0utLdcK6kEWUiLEWSoiW31sQr2bWbayd2hKiCMt5Dbnh0pO8zbokMdQ3Lo2ULYhCKZYbooiNIheysP(FWTDW2Vg5G7FqUhDb0b32bnznEVFn(uZb17shB3IDqIs7GPm1CWzoLhpii3CWAp4JK8Sg4FWhf(Vo4eLpisn4bFu4)6GeNrm2bayd2h01sULHb8r9sIZfcZ8pDokQC5KqcYNf4OeNenkwALxGemOKnLN5uEKWeLN5uEmIudsG4mIPSERrk5weKplWrHnHbYnrEdg54BTokaiXPyjmUhDbuCBrtwJ37xJ3rb5ZcCuyty6DPJTBXg8Vl5we5e56DPJTBXaMuQ)XTfB)Ae2G)Dj3IaXj3QvXPyjmUhDbuCBrtwJ37xJ3rb9U0X2TyCp6cO42IMSgV3VgNn4FxYTiYjYLplWrHnHP3Lo2UfBW)UKBrG4KB1Q4uSewQrTdK8daWgSpORLCldd4J6LeNl2taWZ8pDokQC5KqcYNf4OeTmAuS0kVajyqjBkpZP8iHjkpZP8yePgKaXzetz9wJuYTiiFwGJcZsgi3e5nyKJV16OaGeNILW4E0fqXTfnznEVFnEhfKplWrHzjtVlDSDl2G)Dj3IiNixVlDSDlgWKs9pUTy7xJWg8Vl5weio5wTkoflHX9OlGIBlAYA8E)A8okO3Lo2UfJ7rxaf3w0K149(14Sb)7sUfrorU8zbokmlz6DPJTBXg8Vl5weio5wTkoflHLAu7aj)aaSb7dseAKKKlO5G(bLplWrXCWzoLhpiNIhuVKa6Fw9huaHhuVlDSDRdUTdkGWdkFwGJIYhCKZYbooiNIhuaHhCW)UKBDWTDqbeEqo(w7GPCqG)olhOHDW5UU5G(bnYJvVa6GK2r2s8pOShSpNHh0piOShe(he4N7NIIhu2dAKhREb0bLplWrXO8bDZb7Iu6bDZb9dsAhzlX)GT9py2oOFq5ZcCuoy3Ksp4(hSBsPhSw5Ggfl9b7McOdQ3Lo2ULHDaa2G9bDTKBzyaFuVK4CXEcaEM)PZrrLlNesq(SahLiWp3pffvEbsWGs2uEMt5rcwQ8mNYJrKAqctuwV1iLClcas(Sahf2egi3e5nyKJV16iFwGJcZsgi3e5nyKJV1SAv(SahfMLmqUjYBWihFR1rbfKplWrHzjtVlDSDl2G)Dj3Iix(SahfMLmG)QzEPyCa0Wg8Vl5wKtKuycJy2lFwGJcZsgi3e54BnMrES6fqKtKuyM)PZrrM8zbokrlJgfln5KRKckiFwGJcBctVlDSDl2G)Dj3Iix(Sahf2egWF1mVumoaAyd(3LClYjskmHrm7LplWrHnHbYnro(wJzKhREbe5ejfM5F6CuKjFwGJsCs0OyPjN8dGdaWgSpirODrnVGJdIZWxXdkjj8Gci8GUw2)GP5G(mpPohfzhaUwYTmeiL1i2EejB8aaSpirfiqQIhCU(Rro4CfNHVYhKKNL4zDqIIwXdARt3YCqVgheCebEqYcsAFdsrJ5Gerzj4FWFP0S6paCTKBzSNaGFK0(gKIgtSBwc(kNnc6Tg8PWWz43(1iDeNILW6Dbe(z1hnY(K6aiXPyjSLJMc(UKB1rVlDSDlgWKs9pUTy7xJWEKKNL5aaSpirfiqQIhCU(Rro4CfNH)b9ACqsEwIN1bjkAfpOToDlZbGRLClJ9eamOTlnR(ih1nIYzJaGgRWA)AKydNHptsn4z13rbXPyjSuJAhOvR6DPJTBX4E0fqXTfnznEVFno7rsEwgLMqmRwfNILWwoAk47sUvh9U0X2Tyatk1)42ITFnc7rsEwMoaIJV1yGNuAw9rsUguwiJhi5haUwYTm2taW9uxNon6JzEPrLZgbo(wJLAfJIt3YWEKKNLHme61JoC8Tgl1kgfNULHXdSJbisPrX)EumSEQRtNg9XmV0OseSSJcasCkwcJ7rxaf3w0K149(14wTQ3Lo2UfJ7rxaf3w0K149(14Shj5zzuAcXi)aW1sULXEcaU9RrIg5tWrLZgbo(wJLAfJIt3YWEKKNLHme61JoC8Tgl1kgfNULHXdSJcasCkwcJ7rxaf3w0K149(14wTQ3Lo2UfJ7rxaf3w0K149(14Shj5zzuAcXi)aaSpODaTRbpirvl5whKMg5GYEWNVoaCTKBzSNaG1oLgDTKBfPPruUCsib9odlVeZbGRLClJ9eaS2P0ORLCRinnIYLtcj8UoDQ5aW1sULXEcaw7uA01sUvKMgr5YjHeKplWrXCa4Aj3YypbaRDkn6Aj3kstJOC5Kqc6DPJTBzoaCTKBzSNaG1oLgDTKBfPPruUCsib9shrqO)IYzJG4uSeMEPJii0FPdhFRX0lDebH(lmJ4AWvIWeI3rHbYX3AS3j79tnYmIRbNaXSAfqd0fqrWRShKWE(cB73JS3j79tns(bGRLClJ9ea8Zxrxl5wrAAeLlNesGBnrj1GNvVYzJahFRX4E0fqXTfnznEVFnoJh4bGRLClJ9ea8Zxrxl5wrAAeLlNesGBnrG7sZQx5SrqCkwcJ7rxaf3w0K149(14DuqVlDSDlg3JUakUTOjRX79RXzpsYZYqMjeN8daxl5wg7ja4NVIUwYTI00ikxojKWYrtbFxYTuoBe44BngWKs9pUTy7xJW4b2rCkwcB5OPGVl5whaUwYTm2taWpFfDTKBfPPruUCsiHLJMc(UKBfbUlnRELZgbXPyjSLJMc(UKB1rVlDSDlgWKs9pUTy7xJWEKKNLHmti(bGRLClJ9ea8Zxrxl5wrAAeLlNesWxu5SrW1sodJyHKs0OeblpaCTKBzSNaG1oLgDTKBfPPruUCsibJ41W)XbWbayFqI6seEqYYkUKBDa4Aj3YW8fj8iP9nifnMy3Se8paCTKBzy(I2taW9uxNon6JzEPrLZgbXPyjS2VgXOvuaHhaUwYTmmFr7ja42VgjAKpbhvwROMIrX)EumeMOC2iO3Lo2Uf7rs7BqkAmXUzj4ZEKKNLHmeSKi1RhDeNILW6Dbe(z1hnY(KoaCTKBzy(I2taWG2U0S6JCu3ikNncC8Tg7tsiJh4bGRLCldZx0EcaE5OPGVlOYzJWaDbu0RrCGAxrMKAWZQVJENHLxcRYEqsS5yho(wJnqxazIdEKzexdUsG1daxl5wgMVO9eaC7xJy0kkGqLZgbo(wJbEsPz1hj5AqzHShDT0rbanqxaf9AehO2vKjPg8S67O3zy5LWQShKeBoA1kG07mS8syv2dsInhj)aW1sULH5lApba3tDD60OpM5LgvoBeE(k1rGBx8zdSL6uiJctiM9ItXsypFL6Olcw8UKBrKSb5haUwYTmmFr7ja42VgjAKpbhvwROMIrX)EumeMOC2i88vQJa3U4Zgyl1PqgfMqm7fNILWE(k1rxeS4Dj3IizdYpaCTKBzy(I2taWTFnIrROacvoBea0aDbu0RrCGAxrMKAWZQVJENHLxcRYEqsS5OvRasVZWYlHvzpij2C8aW1sULH5lApbaVC0uW3fuzTIAkgf)7rXqyIYzJWZxPocC7IpBGTuNIskyjXSxCkwc75RuhDrWI3LClIKni)aW1sULH5lApba3tDD60OpM5LgpaCTKBzy(I2taWTFns0iFcoQSwrnfJI)9Oyim5aW1sULH5lApbadA)kUTy3Se8paCTKBzy(I2taW(R9cJY(pwYbWbayFW5F0fqhCBhunRX79RXpiWDPz1FWFfxYToOnpOr8xmhCcXnhKdB7JhC(v9GP5G(mpPohfpaCTKBzyCRjcCxAw9eaTDPz1h5OUruoBe44Bn2NKqgpWdaxl5wgg3AIa3LMvV9ea8JK23Gu0yIDZsWx5SrW1sodJyHKs0OeblTA95lKjjjmkBKyKHqVE0rbXPyjSExaHFw9rJSpjRw1Bn4tHHZWV9RrSA95lSTFpY4sjR(OEPdYpaa7dov8VhLy2iqYTRnvyGC8Tg7DYE)uJmJ4AWTFc5e5kmqo(wJ9ozVFQr2JK8Sm2pHCI0aDbue8k7bjSNVW2(9i7DYE)uJtpizbbIUyoOFq6kkFqbuAoyAoywcwdCCqzpO4FpkhuaHheu2dcnYbb(5(PO4bXcjP4b7McOd61bDUKMIIhua5Yb7Mu6bDGaPkEW3j79tnEWSDWNVW2(94GDqBb5Yb5WS6pOxhelKKIhSBkGoiXpOrCn4gLp4(h0RdIfssXdkGC5Gci8GdKJV1oy3KspOz36GODbMpEWTyhaUwYTmmU1ebUlnRE7ja4LJMc(UGkRvutXO4FpkgctuoBeE(k1rGBx8zdSL6uuIGLe7aW1sULHXTMiWDPz1Bpba3tDD60OpM5LgvoBeE(k1rGBx8zdSL6uiJLeVJbisPrX)EumSEQRtNg9XmV0OseSSJEx6y7wmGjL6FCBX2VgH9ijplJse7aW1sULHXTMiWDPz1Bpba3(1irJ8j4OYAf1umk(3JIHWeLZgHNVsDe42fF2aBPofYyjX7O3Lo2UfdysP(h3wS9RrypsYZYOeXoaCTKBzyCRjcCxAw92taWTFnIrROacvoBe44Bng4jLMvFKKRbLfYE01sNNVsDe42fF2aBPofLuycXSxCkwc75RuhDrWI3LClIKniVJbisPrX)EumS2VgXOvuaHkrWYokWX3ASb6citCWJmJ4AWjawTAfqd0fqrVgXbQDfzsQbpRERwbKENHLxcRYEqsS5i5haUwYTmmU1ebUlnRE7ja42VgXOvuaHkNncpFL6iWTl(Sb2sDkkrqbBqm7fNILWE(k1rxeS4Dj3IizdY7yaIuAu8VhfdR9RrmAffqOseSSJcC8TgBGUaYeh8iZiUgCcGvRwb0aDbu0RrCGAxrMKAWZQ3QvaP3zy5LWQShKeBos(bGRLCldJBnrG7sZQ3EcaE5OPGVlOYAf1umk(3JIHWeLZgHNVsDe42fF2aBPofLiOGniM9ItXsypFL6Olcw8UKBrKSb5haUwYTmmU1ebUlnRE7ja4EQRtNg9XmV0OYzJGEx6y7wmGjL6FCBX2VgH9ijplJspFHmjjHrzJeDNNVsDe42fF2aBPofYq0eVJbisPrX)EumSEQRtNg9XmV0OseS8aW1sULHXTMiWDPz1Bpba3(1irJ8j4OYAf1umk(3JIHWeLZgb9U0X2Tyatk1)42ITFnc7rsEwgLE(czsscJYgj6opFL6iWTl(Sb2sDkKHOj(bWbayFW5F0fqhCBhunRX79RXpirvl5m8GKLvCj36aW1sULHXTMOKAWZQNWYrtbFxqL1kQPyu8VhfdHjkNncpFL6iWTl(Sb2sDkkraSq8daxl5wgg3AIsQbpRE7ja4hjTVbPOXe7MLGVYzJG4uSewVlGWpR(Or2NKvR6Tg8PWWz43(1iwT(8f22VhzCPKvFuV0HvRUwYzyelKuIgLiy5bGRLCldJBnrj1GNvV9eamOTlnR(ih1nIYzJahFRX(KeY4b2rHNVsDe42fF2aBPofYqmIz16Zxitssyu2OnidHE9WQvdqKsJI)9OyyG2U0S6JCu3ikrWsYpaCTKBzyCRjkPg8S6TNaGxoAk47cQSwrnfJI)9Oyimr5Sr45lKjjjmkBKOjtVEy16ZxPocC7IpBGTuNIseiAIDa4Aj3YW4wtusn4z1Bpba3(1igTIciu5SrGJV1yGNuAw9rsUguwiJhyhdqKsJI)9OyyTFnIrROacvIGLDuaqd0fqrVgXbQDfzsQbpR(o6DgwEjSk7bjXMJwTci9odlVewL9GKyZrYpaCTKBzyCRjkPg8S6TNaGbTFf3wSBwc(kNncpFL6iWTl(Sb2sDkkrGOjENNVqMKKWOSrBOuVECa4Aj3YW4wtusn4z1Bpba3(1igTIciu5SrWaeP0O4Fpkgw7xJy0kkGqLiyzhf44Bn2aDbKjo4rMrCn4eaRwTcOb6cOOxJ4a1UImj1GNvVvRasVZWYlHvzpij2CK8daxl5wgg3AIsQbpRE7ja4LJMc(UGkRvutXO4FpkgctuoBeE(k1rGBx8zdSL6uuYsI155lujBCa4Aj3YW4wtusn4z1BpbadA7sZQpYrDJOC2iWX3ASpjHmEGhaUwYTmmU1eLudEw92taW(R9cJY(pwIYzJWZxPocC7IpBGTuNIseJ4hahaGnyFq7S0XbN7I(lh0oBnsj3YCaa2G9bDTKBzy6LoIGq)fcAqEwM42IPgvoBeAzpij(ijpldz61JdaW(GK1AWdo4)S6pirwsP(FWUPa6GefnQDGaE(hDb0bGRLCldtV0ree6VypbaRb5zzIBlMAu5SraqItXsylhnf8Dj3QdhFRXaMuQ)XTfB)Ae2JK8SmKXgD44BngWKs9pUTy7xJW4b2HJV1y6LoIGq)fMrCn4krycXpaa7do34ftoWdUTdsKLuQ)hK3GEpEWUPa6GefnQDGaE(hDb0bGRLCldtV0ree6VypbaRb5zzIBlMAu5SraqItXsylhnf8Dj3QZaDbue8k7bjSNVW2(9iR5ukwr9ZB8b(DaehFRXaMuQ)XTfB)AegpWokWX3Am9shrqO)cZiUgCLimbS0HJV1y8fOLQy0ipw9cigpqRw54BnMEPJii0FHzexdUseMqe3rVlDSDlgWKs9pUTy7xJWEKKNLrPjeN8daxl5wgMEPJii0FXEcawdYZYe3wm1OYzJaGeNILWwoAk47sUvhanqxafbVYEqc75lSTFpYAoLIvu)8gFGFho(wJPx6icc9xygX1GReHjeVdG44BngWKs9pUTy7xJW4b2rVlDSDlgWKs9pUTy7xJWEKKNLrjlj(bayFqIShNHLCq7S0XbN7I(lhCNHV2bcmR(do4)S6piWKs9)aW1sULHPx6icc9xSNaG1G8SmXTftnQC2iioflHTC0uW3LCRoaIJV1yatk1)42ITFncJhyhf44BnMEPJii0FHzexdUseMaw6WX3Am(c0svmAKhREbeJhOvRC8TgtV0ree6VWmIRbxjctiITAvVlDSDlgWKs9pUTy7xJWEKKNLHm2OdhFRX0lDebH(lmJ4AWvIWeIM8dGdaW(GezRKBDa4Aj3YW07shB3YypbadCLClLZgbo(wJbmPu)JBl2(1imEGD44Bngsc42f)4ZxySl6a3IXd8aaSpOD2Lo2UL5aW1sULHP3Lo2ULXEcagjbC7IF85lm2fDGBPC2iioflHTC0uW3LCRokO3Lo2UfdysP(h3wS9Rryp6df788fYKKegLnsmL61JopFL6iWTl(Sb2sDkkrycXTALJV1yatk1)42ITFncJhyNNVqMKKWOSrIPuVEqUvRTShKeFKKNLHmws8daxl5wgMEx6y7wg7jayKeWTl(XNVWyx0bULYzJG4uSeg3JUakUTOjRX79RX788vQJa3U4Zgyl1POert8opFHmjjHrzJetPE9OJcC8TgJ7rxaf3w0K149(14mEGwT2YEqs8rsEwgYyjXj)aW1sULHP3Lo2ULXEcagjbC7IF85lm2fDGBPC2iioflHLAu7a788fsgBCa4Aj3YW07shB3YypbadmPu)JBl2(1ikNncItXsyCp6cO42IMSgV3VgVJc6DPJTBX4E0fqXTfnznEVFno7rsEwgRw17shB3IX9OlGIBlAYA8E)AC2J(qXopFL6iWTl(Sb2sDkKbSqCYpaCTKBzy6DPJTBzSNaGbMuQ)XTfB)AeLZgbXPyjSuJAhyhaXX3AmGjL6FCBX2VgHXd8aW1sULHP3Lo2ULXEcagysP(h3wS9RruoBeeNILWwoAk47sUvhfeNILW6Dbe(z1hnY(Kyy5CuC0HJV1ypsAFdsrJj2nlbFgpqRwbK4uSewVlGWpR(Or2NedlNJIdYpaCTKBzy6DPJTBzSNaG5E0fqXTfnznEVFnUYzJahFRXaMuQ)XTfB)AegpWdaxl5wgMEx6y7wg7ja42VgPRIpjtSX)kQC2iWX3AmGjL6FCBX2VgH9ijpldz61JoC8TgdysP(h3wS9Rry8a7aiXPyjSLJMc(UKBDa4Aj3YW07shB3Yypba3(1iDv8jzIn(xrLZgbxl5mmIfskrJseSSJcC8TgdysP(h3wS9Rry8a7WX3AmGjL6FCBX2VgH9ijpldz61dRwFphrCgwcZhdddTBAetN3ZreNHLW8XWWEKKNLHm96HvRTShKeFKKNLHm96b5haUwYTmm9U0X2Tm2taWTFnsxfFsMyJ)vu5SrqCkwcB5OPGVl5wDaehFRXaMuQ)XTfB)AegpWokOahFRX4lqlvXOrES6fqmEGwTcOb6cOi4v2dsypFHT97rwZPuSI6N34d8jVJcdKJV1yVt27NAKzexdobIz1kGgOlGIGxzpiH98f22VhzVt27NAKCYpaCTKBzy6DPJTBzSNaGbPiWvaHpPuhb(OblnQC2iioflHX9OlGIBlAYA8E)A8opFL6iWTl(Sb2sDkkr0eVZZxOseSrho(wJbmPu)JBl2(1imEGwTciXPyjmUhDbuCBrtwJ37xJ355RuhbUDXNnWwQtrjcwsSdaxl5wgMEx6y7wg7ja43tdghOpuoBe44BngWKs9pUTy7xJW4bEa4Aj3YW07shB3YypbaBC9NTuNonc01IYzJGRLCggXcjLOrjcw2rbGOW6bT8u2JK8SmKPxpSAv8VhfMKKWOSXrIKPxpi)aW1sULHP3Lo2ULXEcaEGUak61ioqTROYzJGRLCggXcjLOrjIz16ZxyB)EKbee6)sAl0CaCaa2h0o7mS8soirLlPPKO5aW1sULHP3zy5LyimqxazIdEu5Sr49CeXzyjmFmmSSuAcXSAfqVNJiodlH5JHHH2nnIXQvxl5mmIfskrJseS8aW1sULHP3zy5LySNaGnD9Nuw9rsPruoBeCTKZWiwiPeneM055RuhbUDXNnWwQtrjB0rVlDSDlgWKs9pUTy7xJWEKKNLHm2OdGeNILW4E0fqXTfnznEVFnEhfa075iIZWsy(yyyODtJySA99CeXzyjmFmmSSuAcXi)aW1sULHP3zy5LySNaGnD9Nuw9rsPruoBeCTKZWiwiPenkrWYoasCkwcJ7rxaf3w0K149(14haUwYTmm9odlVeJ9eaSPR)KYQpsknIYzJG4uSeg3JUakUTOjRX79RX7OahFRX4E0fqXTfnznEVFnoJhyhfCTKZWiwiPeneM055RuhbUDXNnWwQtrjIM4wT6AjNHrSqsjAuIGLDE(k1rGBx8zdSL6uucSqCYTAfqC8TgJ7rxaf3w0K149(14mEGD07shB3IX9OlGIBlAYA8E)AC2JK8SmKFa4Aj3YW07mS8sm2taWo3sklxYTI0KeNYzJGRLCggXcjLOHWKo6DPJTBXaMuQ)XTfB)Ae2JK8SmKXgDuaqVNJiodlH5JHHH2nnIXQ13ZreNHLW8XWWYsPjeJ8daxl5wgMENHLxIXEca25wsz5sUvKMK4uoBeCTKZWiwiPenkrWYdaxl5wgMENHLxIXEca2aY1GtXOacJ8v39fqkQC2i4AjNHrSqsjAimPJEx6y7wmGjL6FCBX2VgH9ijpldzSrhfa075iIZWsy(yyyODtJySA99CeXzyjmFmmSSuAcXi)aW1sULHP3zy5LySNaGnGCn4umkGWiF1DFbKIkNncUwYzyelKuIgLiy5bWbayFW5ghnf8Dj36G)kUKBDa4Aj3YWwoAk47sUfHhjTVbPOXe7MLGVYzJGRLCggXcjLOrjc2OJcItXsy9Uac)S6JgzFswTQ3AWNcdNHF7xJy16ZxyB)EKXLsw9r9shKFa4Aj3YWwoAk47sUL9eamOTlnR(ih1nIYzJaGgRWA)AKydNHptsn4z13bqC8Tgd8KsZQpsY1GYcz8apaCTKBzylhnf8Dj3YEcaU9RrmAffqOYzJahFRXapP0S6JKCnOSq2JUw6yaIuAu8VhfdR9RrmAffqOseSSJcC8TgBGUaYeh8iZiUgCcGvRwb0aDbu0RrCGAxrMKAWZQ3QvaP3zy5LWQShKeBos(bGRLCldB5OPGVl5w2taWlhnf8DbvwROMIrX)EumeMOC2iWX3AmWtknR(ijxdklK9ORfRwbehFRX(KeY4b2XaeP0O4FpkggOTlnR(ih1nIseSXbGRLCldB5OPGVl5w2taW9uxNon6JzEPrLZgbdqKsJI)9Oyy9uxNon6JzEPrLiyzhfE(k1rGBx8zdSL6uiZeIB16Zxitssyu2OLk1RhKB1QcdKJV1yVt27NAKzexdoziMvRdKJV1yVt27NAK9ijpldzMqmYpaCTKBzylhnf8Dj3YEcaU9RrIg5tWrLZgb9wd(uy47Ju7sw9ro62TdhFRXW3hP2LS6JC0TlZiUgCcw2X1sodJyHKs0qyYbGRLCldB5OPGVl5w2taWG2U0S6JCu3ikNncC8Tg7tsiJhyhdqKsJI)9OyyG2U0S6JCu3ikrWYdaxl5wg2YrtbFxYTSNaG7PUoDA0hZ8sJkNncgGiLgf)7rXW6PUoDA0hZ8sJkrWYdaxl5wg2YrtbFxYTSNaGB)AKOr(eCuzTIAkgf)7rXqyIYzJaGeNILW8zo1lniSdG44Bng4jLMvFKKRbLfY4bA1Q4uSeMpZPEPbHDaehFRX(KeY4bEa4Aj3YWwoAk47sUL9eamOTlnR(ih1nIYzJahFRX(KeY4bEa4Aj3YWwoAk47sUL9ea8YrtbFxqL1kQPyu8VhfdHjhahaG9bjY2LMv)bNR7FW5ghnf8Dj3YMhuv8xmhCcXpOb1BnmhKdB7JhKilPu)p42o4C9xJCq9scnhCBTdAhY6haUwYTmSLJMc(UKBfbUlnREcpsAFdsrJj2nlbFLZgbXPyjSExaHFw9rJSpjRw1Bn4tHHZWV9RrSA95lSTFpY4sjR(OEPdRwDTKZWiwiPenkrWYdaxl5wg2YrtbFxYTIa3LMvV9eamOTlnR(ih1nIYzJahFRX(KeY4bEa4Aj3YWwoAk47sUve4U0S6TNaGxoAk47cQSwrnfJI)9Oyimr5SrGJV1yGNuAw9rsUguwi7rxlhaUwYTmSLJMc(UKBfbUlnRE7ja4EQRtNg9XmV0OYzJGbisPrX)EumSEQRtNg9XmV0OseSSZZxPocC7IpBGTuNczale)aW1sULHTC0uW3LCRiWDPz1Bpba3(1irJ8j4OYAf1umk(3JIHWeLZgHNVsDe42fF2aBPofYmxi(bGRLCldB5OPGVl5wrG7sZQ3EcaE5OPGVlOYAf1umk(3JIHWeLZgHNVqLi6daxl5wg2YrtbFxYTIa3LMvV9eaC7xJy0kkGqLZgbxl5mmIfskrJsei6okaOb6cOOxJ4a1UImj1GNvFh9odlVewL9GKyZrRwbKENHLxcRYEqsS5i5hahaG9bjlUoD6bjQCjnLenhaUwYTmS31Ptne4O7oIn(xrLZgbo(wJbmPu)JBl2(1imEGhaUwYTmS31Ptn2taWC4BWh8S6voBe44BngWKs9pUTy7xJW4bEa4Aj3YWExNo1ypba7V2lmcKNAqLZgbfaehFRXaMuQ)XTfB)AegpWoUwYzyelKuIgLiyj5wTcio(wJbmPu)JBl2(1imEGDu45lKnWwQtrjceRZZxPocC7IpBGTuNIsealeN8daxl5wg2760Pg7jayA2dsmX5o4h9KWsuoBe44BngWKs9pUTy7xJW4bEa4Aj3YWExNo1ypba7LgnY70O2PuLZgbo(wJbmPu)JBl2(1imEGD44Bngsc42f)4ZxySl6a3IXd8aW1sULH9UoDQXEcaULpYr3DOC2iWX3AmGjL6FCBX2VgH9ijpldziaw7WX3AmKeWTl(XNVWyx0bUfJh4bGRLCld7DD6uJ9eamN3h3wu(udUr5SrGJV1yatk1)42ITFncJhyhxl5mmIfskrdHjDuGJV1yatk1)42ITFnc7rsEwgYqSoItXsy6LoIGq)fgwohfhwTciXPyjm9shrqO)cdlNJIJoC8TgdysP(h3wS9RrypsYZYqgBq(bWbayFqvXRH)JdAYQNIZ9I)9OCWFfxYToaCTKBzygXRH)dcpsAFdsrJj2nlbFLZgbXPyjSExaHFw9rJSpjRw1Bn4tHHZWV9RrSA95lSTFpY4sjR(OEPJdaxl5wgMr8A4)WEcaUN660PrFmZlnQC2iaOb6cOi4v2dsypFHT97r27K9(Pg7OWa54Bn27K9(PgzgX1GtgIz16a54Bn27K9(PgzpsYZYqM5c5haUwYTmmJ41W)H9eaC7xJenYNGJkNnc6DPJTBXEK0(gKIgtSBwc(Shj5zzidbljs96rhXPyjSExaHFw9rJSpPdaxl5wgMr8A4)WEcaU9RrIg5tWrLZgb9wd(uy47Ju7sw9ro62TdhFRXW3hP2LS6JC0TlZiUgCcwA1QERbFkm(IIUbeoIThlYwXoC8TgJVOOBaHJy7XISvK9ijpldzSrho(wJXxu0nGWrS9yr2kY4bEa4Aj3YWmIxd)h2taWG2U0S6JCu3ikNncC8Tg7tsiJh4bGRLCldZiEn8FypbaVC0uW3fu5SraqC8TgR9lzJveip1GmEGDeNILWA)s2yfbYtnOvRC8Tgd8KsZQpsY1GYczp6AXQ1b6cOOxJ4a1UImj1GNvFh9odlVewL9GKyZXoC8TgBGUaYeh8iZiUgCLaRwT(8fYKKegLns0KHqVECa4Aj3YWmIxd)h2taWTFns0iFcoQC2i88vQJa3U4Zgyl1PqgfMqm7fNILWE(k1rxeS4Dj3IizdYpaCTKBzygXRH)d7ja4LJMc(UGkNncpFL6iWTl(Sb2sDkkPGLeZEXPyjSNVsD0fblExYTis2G8daxl5wgMr8A4)WEcaU9RrIg5tWXdaxl5wgMr8A4)WEcag0(vCBXUzj4Fa4Aj3YWmIxd)h2taW(R9cJY(pwYbWbayFqB)SahfZbGRLCldt(SahfdHSm6NxCokgjc49s4jfh4SuJkNncC8TgdysP(h3wS9Rry8aTAv8VhfMKKWOSrGAjAjXjdXSATL9GK4JK8SmKXYjhaUwYTmm5ZcCum2taW8gmMcsYOC2iWX3AmGjL6FCBX2VgHXdSJcasCkwcl1O2bA1Q4uSewQrTdSdhFRXaMuQ)XTfB)Ae2JK8SmkrycXj)aaSb7dAli8GYNf4OCWUPa6Gci8GGYEqOroiAKKKl44GZCkpQ8b7Mu6b5WdYBWXbB5BKd614Ga98XXb7McOdsKLuQ)hCBhCU(RryhaGnyFqxl5wgM8zbokg7jayEdgtbjPSHUcb5ZcCuMOC2iWX3AmGjL6FCBX2VgHXdSJcasCkwcl1O2bA1Q4uSewQrTdSdhFRXaMuQ)XTfB)Ae2JK8SmkrycXjVJcas(SahfMLmqUjQ3Lo2ULvRYNf4OWSKP3Lo2Uf7rsEwgRwN5F6CuKjFwGJse4N7NIIeMqUvRYNf4OWMWa(RM5LIXbqdBW)UKBPeHw2dsIpsYZYCaa2G9bDTKBzyYNf4OySNaG5nymfKKYg6keKplWrXsLZgbo(wJbmPu)JBl2(1imEGDuaqItXsyPg1oqRwfNILWsnQDGD44BngWKs9pUTy7xJWEKKNLrjctio5DuaqYNf4OWMWa5MOEx6y7wwTkFwGJcBctVlDSDl2JK8SmwToZ)05Oit(SahLiWp3pffjyj5wTkFwGJcZsgWF1mVumoaAyd(3LClLi0YEqs8rsEwMdaWgSpirPDWTOkEWTWdU1b5n4bLplWr5Ga)DwoqZb9dYX3AkFqEdEqbeEWvaH)b36G6DPJTBXo4C7py2oyHPac)dkFwGJYbb(7SCGMd6hKJV1u(G8g8GCRa6GBDq9U0X2TyhaGnyFqxl5wgM8zbokg7jayEdgtbjPSHUcb5ZcCuMOC2iai5ZcCuytyGCtK3Gro(wRJcYNf4OWSKP3Lo2Uf7rsEwgRwbK8zbokmlzGCtK3Gro(wJCRw17shB3IbmPu)JBl2(1iShj5zzuYsIFaa2G9bDTKBzyYNf4OySNaG5nymfKKYg6keKplWrXsLZgbajFwGJcZsgi3e5nyKJV16OG8zbokSjm9U0X2TypsYZYy1kGKplWrHnHbYnrEdg54BnYTAvVlDSDlgWKs9pUTy7xJWEKKNLrjljEqcsia]] )

end
