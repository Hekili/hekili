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


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        bitter_chill = 5435, -- 356470
        chill_streak = 706, -- 305392
        dark_simulacrum = 3512, -- 77606
        dead_of_winter = 3743, -- 287250
        deathchill = 701, -- 204080
        deaths_echo = 5427, -- 356367
        delirium = 702, -- 233396
        dome_of_ancient_shadow = 5369, -- 328718
        shroud_of_winter = 3439, -- 199719
        spellwarden = 5424, -- 356332
        strangulate = 5429, -- 47476
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
            duration = 8,
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

        shroud_of_winter = {
            id = 199719,
            duration = 3600,
            max_stack = 1,
        },

        lichborne = {
            id = 287081,
            duration = 10,
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
            cooldown = 180,
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
                return 35 * ( buff.hypothermic_presence.up and 0.65 or 1 )
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
                if pvptalent.bitter_chill.enabled and debuff.chains_of_ice.up then
                    applyDebuff( "target", "chains_of_ice" )
                end
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
                if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end

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


    spec:RegisterPack( "Frost DK", 20210723, [[d4KA0cqiqrpsIKUKqqTjj4tQKgfe1PGcRcIGxjrzwqvDlOOI2fr)cuyyqroMkXYGQ8mHIMguuUgePTbruFtiGXjuv6CsKO1juL5bk5EqL9jrCqHaTqjQEOqHjkuvuxeIiTric1hfQkmsHQICsOOQvcIEjuuHMPeP2Pq0pHiIHcrilviipLGPku5Qqrf4RqrLglOu7LQ(RGbdCyklgspMktwfxgzZs6ZG0ObvNw0QHIkOxdcZgLBdHDl1Vv1WvPoUejSCLEoQMoPRtOTdL(UeA8cHoVqP1luvnFH0(vS)IpoVWXuYhjEycVlykcGxmLxqYinM4fb8cAS3Kx42CqyqjVqBiiVas8(CDaXNXC0lCBXYE74JZlWFX1rEb4QEZJhmGb0uHlIkDpcyWteImtZVDRvvyWteoy4fqftMI5BpQx4yk5JepmH3fmfbWlMYlizKgt8qYEbtuH)RxqiredVa88CO2J6foe35fIptMcFayo2ju46aqI3NRdKqkYIDa4Db)bGhMW7Ya5azmGBnuIpqI5CaricXJLodGzCfZjNCFFgGi3Gsd4RdigWTS5d4RdaZ7Oby8bK6aopX7R6aUzwSdOiXydi7bCVMtthj9cSKRCFCEHhLLkTMMFhU)NLnuFC(iV4JZlqTHYOJVCVG508BVWsi(LtmIZdfZwP1lCiUBZBn)2lGe9plBOdaj(3bGKGYsLwtZVJ3aeuBv(aUGPbWj33h(aqP6V0aqIsgZ2b81bGeVpxhG7rq8b816aIr8zVGBtL208cyTnnugj3IbuXALpGOrhG50elfOMqKeFaLGBa45vFK45JZlqTHYOJVCVGBtL208cMttSuGAcrs8bGBaxgqHbG120qzKSUpxdCDtiOG77JyQCVG508BVqDFUg46MqqE1hzm9X5fO2qz0XxUxWCA(Tx4rzPsRPKxWTPsBAEbuXAvcrYyzdnGWCWZMKlzo1l4I1XOGAlus5(iV4vFKyMpoVa1gkJo(Y9cUnvAtZlG120qzKCFT6cBIG8cMtZV9cW)ISSHgqzgx9QpsK6JZlqTHYOJVCVGBtL208c8BIXcQTqjLlHYmxASGDWATJgqj4gaEdOWawXoDH7ViTYdvtxQdawdajJjVG508BVauM5sJfSdwRDKx9rIK9X5fO2qz0XxUxWCA(TxOUpxdCDtiiVGBtL208cRyNUW9xKw5HQPl1baRbebWKxWfRJrb1wOKY9rEXR(iJa(48cuBOm64l3lyon)2l8OSuP1uYl42uPnnVWk20akb3aIPxWfRJrb1wOKY9rEXR(iJV(48cuBOm64l3l42uPnnVG50elfOMqKeFaLGBay2akmayoaS2MgkJKhYu48WrKcMttSKxWCA(TxOUpx5Uyv4Kx9QxW9StaozR6JZh5fFCEbQnugD8L7fmNMF7fCWTS5HVgsh5foe3T5TMF7fWCaNgWrCZg6aqIsgZ2bumv4daZ7iNDdJYxYu4Eb3MkTP5fG5auJrTkFuwQ0AA(TKAdLrNbuyaOI1Q8ozmBdFnu3NRsX7buyaOI1Q09StaozRk5Q5GyaLGBaxW0akmauXAvENmMTHVgQ7Zv5siSS5dawdaQ7maKWaqEaxgqzdW9p78fBzDFUwm2fbpuf3yLlzNyhagE1hjE(48cuBOm64l3lyon)2l4GBzZdFnKoYlCiUBZBn)2lGKiQ88qd4RdajkzmBhGiNmO0akMk8bG5DKZUHr5lzkCVGBtL208cWCaQXOwLpklvAnn)wsTHYOZakmGdzk8aeDcfUkxXMQ)cLKvJXOo4wrUDODafgamhaQyTkVtgZ2Wxd195Qu8EafgG7F25l2Y7KXSn81qDFUkxcHLnFaLmGliDafgaYdavSwLUNDcWjBvjxnhedOeCd4cMgqHbGkwRsXg(ZInW1LAOkCP49aIgDaOI1Q09StaozRk5Q5GyaLGBaxI5aWWR(iJPpoVa1gkJo(Y9cUnvAtZlaZbOgJAv(OSuP108Bj1gkJodOWaG5aoKPWdq0ju4QCfBQ(luswngJ6GBf52H2buyaOI1Q09StaozRk5Q5GyaLGBaxW0akmayoauXAvENmMTHVgQ7ZvP49akma3)SZxSL3jJzB4RH6(CvUeclB(akza4HjVG508BVGdULnp81q6iV6JeZ8X5fO2qz0XxUxWCA(TxWb3YMh(AiDKx4qC3M3A(TxajAjSuRdigp7mG4tKT6aES06S77SHoGJ4Mn0bCNmMTEb3MkTP5fuJrTkFuwQ0AA(TKAdLrNbuyaWCaOI1Q8ozmBdFnu3NRsX7buyaipauXAv6E2jaNSvLC1CqmGsWnGly2akmauXAvk2WFwSbUUudvHlfVhq0OdavSwLUNDcWjBvjxnhedOeCd4sPCarJoa3)SZxSL3jJzB4RH6(CvUeclB(aG1aI5akmauXAv6E2jaNSvLC1CqmGsWnGly2aWWRE1l8OSuP108BFC(iV4JZlqTHYOJVCVG508BVWsi(LtmIZdfZwP1lCiUBZBn)2lGKGYsLwtZVhW(QP53Eb3MkTP5fmNMyPa1eIK4dOeCdiMdOWaWABAOmsUfdOI1k3R(iXZhNxGAdLrhF5Eb3MkTP5fG5aoVkR7Z1qLWsRuthezdDafgamhaQyTkHizSSHgqyo4ztsX7buyaRytdOeCdiMEbZP53Eb4Frw2qdOmJRE1hzm9X5fO2qz0XxUxWTPsBAEbuXAvcrYyzdnGWCWZMKlzoDafga)MySGAlus5Y6(CL7IvHtdOeCdaVbuyaWCayTnnugjpKPW5HJifmNMyjVG508BVqDFUYDXQWjV6JeZ8X5fO2qz0XxUxWCA(Tx4rzPsRPKxWTPsBAEbuXAvcrYyzdnGWCWZMKlzo1l4I1XOGAlus5(iV4vFKi1hNxGAdLrhF5Eb3MkTP5f43eJfuBHskxcLzU0yb7G1AhnGsWna8gqHbG8awXoDH7ViTYdvtxQdawd4cMgq0OdyfBsQjckOFaVbuYaG6odaJben6aqEahcvSwLRf))MosYvZbXaG1aq6aIgDahcvSwLRf))MosUeclB(aG1aUG0bGHxWCA(TxakZCPXc2bR1oYR(irY(48cuBOm64l3l42uPnnVG50elfOMqKeFa4gWLbuyayTnnugjR7Z1ax3eck4((iMk3lyon)2lu3NRbUUjeKx9rgb8X5fO2qz0XxUxWTPsBAEbS2MgkJK7Rvxyte0akma(nXyb1wOKYLW)ISSHgqzgxhqj4gaEEbZP53Eb4Frw2qdOmJRE1hz81hNxGAdLrhF5Eb3MkTP5f43eJfuBHskxcLzU0yb7G1AhnGsWna88cMtZV9cqzMlnwWoyT2rE1hzP0hNxGAdLrhF5EbZP53EH6(CnW1nHG8cUnvAtZlaZbOgJAvAynM1o4KKAdLrNbuyaWCaOI1QeIKXYgAaH5GNnjfVhq0Odqng1Q0WAmRDWjj1gkJodOWaG5aWABAOmsUVwDHnrqdiA0bG120qzKCFT6cBIGgqHbSInj1ebf0pG3akb3aG6oEbxSogfuBHsk3h5fV6J8cM8X5fO2qz0XxUxWTPsBAEbS2MgkJK7RvxyteKxWCA(Txa(xKLn0akZ4Qx9rE5IpoVa1gkJo(Y9cMtZV9cpklvAnL8cUyDmkO2cLuUpYlE1REbUA9X2JpoFKx8X5fO2qz0XxUxWCA(Txyje)YjgX5HIzR06foe3T5TMF7feuRp2EgapBOmcZPAlushW(QP53Eb3MkTP5fWABAOmsUfdOI1k3R(iXZhNxGAdLrhF5Eb3MkTP5fqfRvjejJLn0acZbpBsUK5uVG508BVWJYsLwtjV6JmM(48cuBOm64l3l42uPnnVawBtdLrY6(CnW1nHGcUVpIPY9cMtZV9c195AGRBcb5vFKyMpoVa1gkJo(Y9cUnvAtZlaZbCitHhGOtOWv5k2u9xOKCT4)30rdOWaqEahcvSwLRf))MosYvZbXaG1aq6aIgDahcvSwLRf))MosUeclB(aG1aIadadVG508BVauM5sJfSdwRDKx9rIuFCEbQnugD8L7fCBQ0MMxW9p78fB5si(LtmIZdfZwPvUeclB(aGfUbG3aqcdaQ7mGcdqng1QeQPWPnBObU(lcj1gkJoEbZP53EH6(CnW1nHG8QpsKSpoVa1gkJo(Y9cUnvAtZlG120qzKCFT6cBIG8cMtZV9cW)ISSHgqzgx9QpYiGpoVa1gkJo(Y9cUnvAtZlaZbGkwRY6(Xp1HBrgNKI3dOWauJrTkR7h)uhUfzCssTHYOZaIgDayTnnugjpKPW5HJifmNMyPbuyaOI1Q8qMcNhoIKKRMdIbaRbGzdiA0bSInj1ebf0pGzdaw4gau3Xlyon)2l8OSuP1uYR(iJV(48cuBOm64l3l42uPnnVWk2PlC)fPvEOA6sDaWAaipGliDaLna1yuRYvStxWuLArtZVLuBOm6maKWaq6aWWlyon)2lu3NRbUUjeKx9rwk9X5fO2qz0XxUxWTPsBAEHvStx4(lsR8q10L6akzaipa8q6akBaQXOwLRyNUGPk1IMMFlP2qz0zaiHbG0bGHxWCA(Tx4rzPsRPKx9rEbt(48cMtZV9c195AGRBcb5fO2qz0XxUx9rE5IpoVG508BVa8F7WxdfZwP1lqTHYOJVCV6J8cE(48cMtZV9c26SMc6Vl1QxGAdLrhF5E1REH1CPX4(48rEXhNxGAdLrhF5EbZP53Ebu2)NqvCJ1lCiUBZBn)2leHmxASbebrtwQjX9cUnvAtZlGkwRY7KXSn81qDFUkfV9Qps88X5fO2qz0XxUxWTPsBAEbuXAvENmMTHVgQ7ZvP4TxWCA(TxaLwoTqKnuV6JmM(48cuBOm64l3l42uPnnVaYdaMdavSwL3jJzB4RH6(CvkEpGcdWCAILcutisIpGsWna8gagdiA0baZbGkwRY7KXSn81qDFUkfVhqHbG8awXMKhQMUuhqj4gashqHbSID6c3FrALhQMUuhqj4gasgtdadVG508BVGToRPWTiJtE1hjM5JZlqTHYOJVCVGBtL208cOI1Q8ozmBdFnu3NRsXBVG508BValHcx5bmhkEGIGA1R(irQpoVa1gkJo(Y9cUnvAtZlGkwRY7KXSn81qDFUkfVhqHbGkwRscX9xK2Wk2uOiz3FlfV9cMtZV9cw7iUUgl4mgZR(irY(48cuBOm64l3l42uPnnVaQyTkVtgZ2Wxd195QCjew28balCdi(oGcdavSwLeI7ViTHvSPqrYU)wkE7fmNMF7fQ5sOS)pE1hzeWhNxGAdLrhF5Eb3MkTP5fqfRv5DYy2g(AOUpxLI3dOWamNMyPa1eIK4da3aUmGcda5bGkwRY7KXSn81qDFUkxcHLnFaWAaiDafgGAmQvP7zNaCYwvsTHYOZaIgDaWCaQXOwLUNDcWjBvj1gkJodOWaqfRv5DYy2g(AOUpxLlHWYMpaynGyoam8cMtZV9cOg0Wxd6Moi4E1REHdvnrM6JZh5fFCEbZP53EbezFc1LO4N8cuBOm64l3R(iXZhNxGAdLrhF5EH)2lWj1lyon)2lG120qzKxaRXejVaYdGkfI59nDKzZDROAOmkukeTwfreoe20rdOWaC)ZoFXwMn3TIQHYOqPq0Aver4qythjxYoXoam8chI728wZV9cirlHLADa8BYL1Kodq3SHGu(aqPSHoaroDgqXuHpatuFeMMUbWYM4EbS2gAdb5f43KlRjDc6MneK6vFKX0hNxGAdLrhF5EH)2lWj1lyon)2lG120qzKxaRXejVG50elfOMqKeFa4gWLbuyaipG1YtGWsTkTZHlZEaLmGliDarJoayoG1YtGWsTkTZHlPiMCLpam8cyTn0gcYlW1WnZ6oBOE1hjM5JZlqTHYOJVCVWF7f4K6fmNMF7fWABAOmYlG1yIKxWCAILcutisIpGsWna8gqHbG8aG5awlpbcl1Q0ohUKIyYv(aIgDaRLNaHLAvANdxsrm5kFafgaYdyT8eiSuRs7C4YLqyzZhqjdaPdiA0butOW1WsiSS5dOKbCbtdaJbGHxaRTH2qqEb7C4HLqyz7vFKi1hNxGAdLrhF5EH)2lWj1lyon)2lG120qzKxaRXejVaQyTk3ebjfVhqHbG8aG5awXMQ)cLKRbLcFnOWPqD)4N6GdUH4o)wsTHYOZaIgDaRyt1FHsY1GsHVgu4uOUF8tDWb3qCNFlP2qz0zafgWk2PlC)fPvEOA6sDaLmG47aWWlG12qBiiVW(A1f2eb5vFKizFCEbQnugD8L7f(BVaNuVG508BVawBtdLrEbSgtK8cUVpIPkP1oPZ0SHgqzFXbuyaOI1QKw7KotZgAaL9fLC1CqmaCdaVben6aCFFetvk2mY4WPtOUuh)XkP2qz0zafgaQyTkfBgzC40juxQJ)yLlHWYMpaynaKhau3zaiHbG3aWWlG12qBiiVqDFUg46Mqqb33hXu5E1hzeWhNxGAdLrhF5EH)2lWj1lyon)2lG120qzKxaRXejVWHmfEW6t4qolwPMoiYg6akma3JLARvzNqHRHQrEbS2gAdb5foKPW5HJifmNMyjV6Jm(6JZlqTHYOJVCVG508BVWsi(LtmIZdfZwP1lCiUBZBn)2lebVVzXoaK4956aqIjS0I)aqyzRw2daZ7IDaXzSV5dW6ZaGGO7beHie)YjgX5daZnBL2bSpJLnuVGBtL208cUVpIPkjS0w3NRdOWauJrTkHAkCAZgAGR)IqsTHYOZakmayoa1yuRYhLLkTMMFlP2qz0zafgG7F25l2Y7KXSn81qDFUkxcHLn3R(ilL(48cuBOm64l3lyon)2la)lYYgAaLzC1l42uPnnVW5vzDFUgQewALlvxId3qz0akmaKhGAmQvz6iNDlP2qz0zarJoayoauXAvIUKPWdFnWZ(Sg0NBsX7buyaQXOwLOlzk8Wxd8SpRb95MKAdLrNben6auJrTkFuwQ0AA(TKAdLrNbuyaU)zNVylVtgZ2Wxd195QCjew28buyaWCaOI1QeIKXYgAaH5GNnjfVhagEbxSogfuBHsk3h5fV6J8cM8X5fO2qz0XxUxWTPsBAEbuXAvMUydQX(MlxcHLnFaWc3aG6odOWaqfRvz6InOg7BUu8Eafga)MySGAlus5sOmZLglyhSw7ObucUbG3akmaKhamhGAmQvj6sMcp81ap7ZAqFUjP2qz0zarJoa3)SZxSLOlzk8Wxd8SpRb95MCjew28buYaUG0bGHxWCA(TxakZCPXc2bR1oYR(iVCXhNxGAdLrhF5Eb3MkTP5fqfRvz6InOg7BUCjew28balCdaQ7mGcdavSwLPl2GASV5sX7buyaipayoa1yuRs0LmfE4RbE2N1G(CtsTHYOZaIgDaWCaOI1QeDjtHh(AGN9znOp3KI3dOWaC)ZoFXwIUKPWdFnWZ(Sg0NBYLqyzZhqjd4cMgagEbZP53EH6(CnW1nHG8QpYl45JZlqTHYOJVCVWH4UnV18BVqmG)pNgqe0P53dGLCDa6pGvS9cMtZV9coJXcMtZVdSKREbwY1qBiiVG7XsT1k3R(iVetFCEbQnugD8L7fmNMF7fCgJfmNMFhyjx9cSKRH2qqEH1CPX4E1h5fmZhNxGAdLrhF5EbZP53EbNXybZP53bwYvVal5AOneKxq3SHGuUx9rEbP(48cuBOm64l3lyon)2l4mglyon)oWsU6fyjxdTHG8cU)zNVyZ9QpYlizFCEbQnugD8L7fCBQ0MMxqng1Q09StaozRkP2qz0zafgaYdaMdavSwLqKmw2qdimh8SjP49aIgDaQXOwLOlzk8Wxd8SpRb95MKAdLrNbGXakmaKhWHqfRv5AX)VPJKC1CqmaCdaPdiA0baZbCitHhGOtOWv5k2u9xOKCT4)30rdadVG508BVGZySG5087al5QxGLCn0gcYl4E2jaNSv9QpYlraFCEbQnugD8L7fCBQ0MMxavSwLOlzk8Wxd8SpRb95Mu82lyon)2lSIDWCA(DGLC1lWsUgAdb5fqFEqthezd1R(iVeF9X5fO2qz0XxUxWTPsBAEb1yuRs0LmfE4RbE2N1G(CtsTHYOZakmaKhG7F25l2s0LmfE4RbE2N1G(CtUeclB(aG1aUGPbGXakmaKhWA5jqyPwL25WLzpGsgaEiDarJoayoG1YtGWsTkTZHlPiMCLpGOrhG7F25l2Y7KXSn81qDFUkxcHLnFaWAaxW0akmG1YtGWsTkTZHlPiMCLpGcdyT8eiSuRs7C4YShaSgWfmnam8cMtZV9cRyhmNMFhyjx9cSKRH2qqEb0NhU)NLnuV6J8sP0hNxGAdLrhF5Eb3MkTP5fqfRv5DYy2g(AOUpxLI3dOWauJrTkFuwQ0AA(TKAdLrhVG508BVWk2bZP53bwYvVal5AOneKx4rzPsRP53E1hjEyYhNxGAdLrhF5Eb3MkTP5fuJrTkFuwQ0AA(TKAdLrNbuyaU)zNVylVtgZ2Wxd195QCjew28baRbCbtdOWaqEayTnnugj5A4MzDNn0ben6awlpbcl1Q0ohUKIyYv(akmG1YtGWsTkTZHlZEaWAaxW0aIgDaWCaRLNaHLAvANdxsrm5kFay4fmNMF7fwXoyon)oWsU6fyjxdTHG8cpklvAnn)oC)plBOE1hjEx8X5fO2qz0XxUxWTPsBAEbZPjwkqnHij(akb3aWZlyon)2lSIDWCA(DGLC1lWsUgAdb5fSN8Qps8WZhNxGAdLrhF5EbZP53EbNXybZP53bwYvVal5AOneKxGRwFS94vV6fSN8X5J8IpoVa1gkJo(Y9chI728wZV9crWhjDarOxnn)2lyon)2lSeIF5eJ48qXSvA9Qps88X5fO2qz0XxUxWTPsBAEb1yuRY6(CL7IvHtsQnugD8cMtZV9cqzMlnwWoyT2rE1hzm9X5fO2qz0XxUxWCA(TxOUpxdCDtiiVGlwhJcQTqjL7J8IxWTPsBAEb3)SZxSLlH4xoXiopumBLw5siSS5daw4gaEdajmaOUZakma1yuRsOMcN2SHg46ViKuBOm64foe3T5TMF7fqI)fHiZs3aS779nh8bO)aClzknaBa3Cs88d4EZFtn2bO2cL0bWsUoG6VdWUVzXMn0bSw8)B6ObK9aSN8QpsmZhNxGAdLrhF5Eb3MkTP5fWABAOmsUVwDHnrqEbZP53Eb4Frw2qdOmJRE1hjs9X5fO2qz0XxUxWTPsBAEbS2MgkJKhYu48WrKcMttS0akmauXAvEitHZdhrsYvZbXaG1aWmVG508BVWJYsLwtjV6Jej7JZlqTHYOJVCVGBtL208cOI1QeIKXYgAaH5GNnjxYC6akmayoaS2MgkJKhYu48WrKcMttSKxWCA(TxOUpx5Uyv4Kx9rgb8X5fO2qz0XxUxWTPsBAEHvStx4(lsR8q10L6aG1aqEaxq6akBaQXOwLRyNUGPk1IMMFlP2qz0zaiHbeZbGHxWCA(TxakZCPXc2bR1oYR(iJV(48cuBOm64l3lyon)2lu3NRbUUjeKxWTPsBAEHvStx4(lsR8q10L6aG1aqEaxq6akBaQXOwLRyNUGPk1IMMFlP2qz0zaiHbG0bGHxWfRJrb1wOKY9rEXR(ilL(48cuBOm64l3l42uPnnVamhawBtdLrYdzkCE4isbZPjwYlyon)2lu3NRCxSkCYR(iVGjFCEbQnugD8L7fmNMF7fEuwQ0Ak5fCBQ0MMxyf70fU)I0kpunDPoGsgaYdapKoGYgGAmQv5k2PlyQsTOP53sQnugDgasyaiDay4fCX6yuqTfkPCFKx8QpYlx8X5fmNMF7fGYmxASGDWATJ8cuBOm64l3R(iVGNpoVa1gkJo(Y9cMtZV9c195AGRBcb5fCX6yuqTfkPCFKx8QpYlX0hNxWCA(Txa(VD4RHIzR06fO2qz0XxUx9rEbZ8X5fmNMF7fS1znf0FxQvVa1gkJo(Y9Qx9cUhl1wRCFC(iV4JZlqTHYOJVCVG508BVWHmfopCejVWH4UnV18BVqmESuBToGiiAYsnjUxWTPsBAEbS2MgkJKCnCZSUZg6aIgDayTnnugjTZHhwcHLTx9rINpoVa1gkJo(Y9cUnvAtZlSID6c3FrALhQMUuhqjd4smhqHb4(ND(IT8ozmBdFnu3NRYLqyzZhaSgqmhqHbaZbOgJAvIUKPWdFnWZ(Sg0NBsQnugDgqHbG120qzKKRHBM1D2q9cMtZV9c8I2IiBObejx9QpYy6JZlqTHYOJVCVGBtL208cWCaQXOwLOlzk8Wxd8SpRb95MKAdLrNbuyayTnnugjTZHhwcHLTxWCA(TxGx0wezdnGi5Qx9rIz(48cuBOm64l3l42uPnnVGAmQvj6sMcp81ap7ZAqFUjP2qz0zafgaYdavSwLOlzk8Wxd8SpRb95Mu8EafgaYdaRTPHYijxd3mR7SHoGcdyf70fU)I0kpunDPoGsgaMHPben6aWABAOmsANdpSecl7buyaRyNUW9xKw5HQPl1buYaqYyAarJoaS2MgkJK25WdlHWYEafgWA5jqyPwL25WLlHWYMpaynGs5aWyarJoayoauXAvIUKPWdFnWZ(Sg0NBsX7buyaU)zNVylrxYu4HVg4zFwd6Zn5siSS5dadVG508BVaVOTiYgAarYvV6JeP(48cuBOm64l3l42uPnnVG7F25l2Y7KXSn81qDFUkxcHLnFaWAaXCafgawBtdLrsUgUzw3zdDafgaYdqng1QeDjtHh(AGN9znOp3KuBOm6mGcdyf70fU)I0kpunDPoaynaKmMgqHb4(ND(ITeDjtHh(AGN9znOp3KlHWYMpayna8gq0OdaMdqng1QeDjtHh(AGN9znOp3KuBOm6mam8cMtZV9cg6JiBtZVdSebQx9rIK9X5fO2qz0XxUxWTPsBAEbS2MgkJK25WdlHWY2lyon)2lyOpISnn)oWseOE1hzeWhNxGAdLrhF5Eb3MkTP5fWABAOmsY1WnZ6oBOdOWaqEaU)zNVylVtgZ2Wxd195QCjew28baRbeZben6auJrTkth5SBj1gkJodadVG508BVahU5GGrbfofe7I)QWJ1R(iJV(48cuBOm64l3l42uPnnVawBtdLrs7C4HLqyz7fmNMF7f4WnhemkOWPGyx8xfESE1hzP0hNxGAdLrhF5Eb3MkTP5fG5aqfRv5DYy2g(AOUpxLI3dOWaqEa8xKHM9rElYvrgfOv8wZVLuBOm6mGOrha)fzOzFKyFMPjJc8NHLAvsTHYOZaWWlKTs7kERHS6f4Vidn7Je7ZmnzuG)mSuREHSvAxXBnKiqqN0uYlCXlyon)2luzehUBTQ6fYwPDfV1au2JAmVWfV6vVW9sUhbQP(48rEXhNxGAdLrhF5EH)2lWjnREb3MkTP5f0nBiivQxKWnEqKtbuXADafgaYdaMdqng1QeDjtHh(AGN9znOp3KuBOm6mGcda5bOB2qqQuViD)ZoFXwEextZVhqeEaU)zNVylVtgZ2Wxd195Q8iUMMFpaCdatdaJben6auJrTkrxYu4HVg4zFwd6Znj1gkJodOWaqEaU)zNVylrxYu4HVg4zFwd6Zn5rCnn)Ear4bOB2qqQuViD)ZoFXwEextZVhaUbGPbGXaIgDaQXOwLPJC2TKAdLrNbGHx4qC3M3A(TxajfRXenL4dWgGUzdbP8b4(ND(In(d4KyZdDgaASd4ozmBhWxhqDFUoGFha6sMcFaFDa8SpRb952v(aC)ZoFXwoamFDaPELpaSgtKgaCJpG(hWsiSSp0oGLuXThWf8haX40awsf3EaysIuPxaRTH2qqEbDZgcsdxc8yBNxWCA(TxaRTPHYiVawJjsbIXjVaMKi1lG1yIKx4Ix9rINpoVa1gkJo(Y9c)TxGtAw9cMtZV9cyTnnug5fWABOneKxq3SHG0aEbESTZl42uPnnVGUzdbPsfpjCJhe5uavSwhqHbG8aG5auJrTkrxYu4HVg4zFwd6Znj1gkJodOWaqEa6MneKkv8KU)zNVylpIRP53dicpa3)SZxSL3jJzB4RH6(CvEextZVhaUbGPbGXaIgDaQXOwLOlzk8Wxd8SpRb95MKAdLrNbuyaipa3)SZxSLOlzk8Wxd8SpRb95M8iUMMFpGi8a0nBiivQ4jD)ZoFXwEextZVhaUbGPbGXaIgDaQXOwLPJC2TKAdLrNbGHxaRXePaX4KxatsK6fWAmrYlCXR(iJPpoVa1gkJo(Y9c)TxGtAw9cUnvAtZlaZbOB2qqQuViHB8GiNcOI16akmaDZgcsLkEs4gpiYPaQyToGOrhGUzdbPsfpjCJhe5uavSwhqHbG8aqEa6MneKkv8KU)zNVylpIRP53dagdq3SHGuPINevSwdhX1087bGXaqcda5bCrI0bu2a0nBiivQ4jHB8aQyTk56snuf(aWyaiHbG8aWABAOmsQB2qqAaVap22namgagdOKbG8aqEa6MneKk1ls3)SZxSLhX1087baJbOB2qqQuVirfR1WrCnn)EaymaKWaqEaxKiDaLnaDZgcsL6fjCJhqfRvjxxQHQWhagdajmaKhawBtdLrsDZgcsdxc8yB3aWyay4foe3T5TMF7fqs5AIWuIpaBa6MneKYhawJjsdan2b4Ee32Mn0bOWPb4(ND(I9a(6au40a0nBiif)bCsS5Hodan2bOWPbCextZVhWxhGcNgaQyToGuhW9(yZdXLdi(KXhGnaUUudvHpae)jRjTdq)banXsdWga8ekCAhW9M)MASdq)bW1LAOk8bOB2qqkh)by8buKySby8bydaXFYAs7aQ)oGSoaBa6MneKoGIjJnGFhqXKXgq)6a4X2Ubumv4dW9p78fBU0lG12qBiiVGUzdbPH7n)n1y9cMtZV9cyTnnug5fWAmrkqmo5fU4fWAmrYlGNx9rIz(48cuBOm64l3l83EboPEbZP53EbS2MgkJ8cynMi5fuJrTkHAkCAZgAGR)IqsTHYOZaIgDaUVpIPkjS0w3NRsQnugDgq0OdyfBQ(lusIMA2qdUNDKuBOm64fWABOneKxylgqfRvUx9rIuFCEbZP53EHkJ4WDRvvVa1gkJo(Y9Qx9cU)zNVyZ9X5J8IpoVa1gkJo(Y9cUnvAtZlGkwRY7KXSn81qDFUkfV9chI728wZV9cirVMF7fmNMF7fUFn)2R(iXZhNxGAdLrhF5EbZP53EbcX9xK2Wk2uOiz3F7foe3T5TMF7fIX)SZxS5Eb3MkTP5fuJrTkFuwQ0AA(TKAdLrNbuyaRytdawdajpGcda5bG120qzKKRHBM1D2qhq0OdaRTPHYiPDo8WsiSShagdOWaqEaU)zNVylVtgZ2Wxd195QCjew28baRbG0ben6aqfRv5DYy2g(AOUpxLI3daJben6aQju4Ayjew28baRbGhM8QpYy6JZlqTHYOJVCVGBtL208cQXOwLOlzk8Wxd8SpRb95MKAdLrNbuyaRyNUW9xKw5HQPl1buYaIjMgqHbSInj1ebf0pG0buYaG6odOWaqEaOI1QeDjtHh(AGN9znOp3KI3diA0butOW1WsiSS5dawdapmnam8cMtZV9ceI7ViTHvSPqrYU)2R(iXmFCEbQnugD8L7fCBQ0MMxqng1QmDKZULuBOm64fmNMF7fie3FrAdRytHIKD)Tx9rIuFCEbQnugD8L7fCBQ0MMxqng1QeDjtHh(AGN9znOp3KuBOm6mGcda5bG120qzKKRHBM1D2qhq0OdaRTPHYiPDo8WsiSShagdOWaqEaU)zNVylrxYu4HVg4zFwd6Zn5siSS5diA0b4(ND(ITeDjtHh(AGN9znOp3KlzNyhqHbSID6c3FrALhQMUuhaSgasX0aWWlyon)2lCNmMTHVgQ7ZvV6Jej7JZlqTHYOJVCVGBtL208cQXOwLPJC2TKAdLrNbuyaWCaOI1Q8ozmBdFnu3NRsXBVG508BVWDYy2g(AOUpx9QpYiGpoVa1gkJo(Y9cUnvAtZlOgJAv(OSuP108Bj1gkJodOWaqEayTnnugj5A4MzDNn0ben6aWABAOmsANdpSecl7bGXakmaKhGAmQvjutHtB2qdC9xesQnugDgqHbGkwRYLq8lNyeNhkMTsRu8EarJoayoa1yuRsOMcN2SHg46ViKuBOm6mam8cMtZV9c3jJzB4RH6(C1R(iJV(48cuBOm64l3l42uPnnVaQyTkVtgZ2Wxd195Qu82lyon)2lGUKPWdFnWZ(Sg0NBE1hzP0hNxGAdLrhF5Eb3MkTP5fmNMyPa1eIK4da3aUmGcdavSwL3jJzB4RH6(CvUeclB(aG1aG6odOWaqfRv5DYy2g(AOUpxLI3dOWaG5auJrTkFuwQ0AA(TKAdLrNbuyaipayoG1YtGWsTkTZHlPiMCLpGOrhWA5jqyPwL25WLzpGsgqmX0aWyarJoGAcfUgwcHLnFaWAaX0lyon)2lu3NRfJDrWdvXnwV6J8cM8X5fO2qz0XxUxWTPsBAEbZPjwkqnHij(akb3aWBafgaYdavSwL3jJzB4RH6(CvkEpGOrhWA5jqyPwL25WLzpGsgG7F25l2Y7KXSn81qDFUkxcHLnFaymGcda5bGkwRY7KXSn81qDFUkxcHLnFaWAaqDNben6awlpbcl1Q0ohUCjew28baRba1DgagEbZP53EH6(CTySlcEOkUX6vFKxU4JZlqTHYOJVCVGBtL208cQXOwLpklvAnn)wsTHYOZakmauXAvENmMTHVgQ7ZvP49akmaKhaYdavSwL3jJzB4RH6(CvUeclB(aG1aG6odiA0bGkwRsXg(ZInW1LAOkCP49akmauXAvk2WFwSbUUudvHlxcHLnFaWAaqDNbGXakmaKhWHqfRv5AX)VPJKC1CqmaCdaPdiA0baZbCitHhGOtOWv5k2u9xOKCT4)30rdaJbGHxWCA(TxOUpxlg7IGhQIBSE1h5f88X5fO2qz0XxUxWTPsBAEb1yuRs0LmfE4RbE2N1G(CtsTHYOZakmGvStx4(lsR8q10L6akzaygMgqHbSInnayHBaXCafgaYdavSwLOlzk8Wxd8SpRb95Mu8EarJoa3)SZxSLOlzk8Wxd8SpRb95MCjew28buYaWmmnamgq0OdaMdqng1QeDjtHh(AGN9znOp3KuBOm6mGcdyf70fU)I0kpunDPoGsWna8qQxWCA(TxaES3VcNwePlCVeNAh5vFKxIPpoVa1gkJo(Y9cUnvAtZlGkwRY7KXSn81qDFUkfV9cMtZV9cRLCkCi74vFKxWmFCEbQnugD8L7fCBQ0MMxWCAILcutisIpGsWna8gqHbG8aqFoFafgqnHcxdlHWYMpaynGyoGOrhamhaQyTkrxYu4HVg4zFwd6ZnP49akmaKhWnPsOWFrMCjew28baRba1Dgq0OdyT8eiSuRs7C4YLqyzZhaSgqmhqHbSwEcewQvPDoCz2dOKbCtQek8xKjxcHLnFaymam8cMtZV9cCZTznDPXc3Mt9QpYli1hNxGAdLrhF5Eb3MkTP5fmNMyPa1eIK4dOKbG0ben6awXMQ)cLK3WjBFeFtCj1gkJoEbZP53EHdzk8G1NWHCwSE1REbDZgcs5(48rEXhNxGAdLrhF5EbZP53EHS5UvunugfkfIwRIichcB6iVWH4UnV18BVqCB2qqk3l42uPnnVaQyTkVtgZ2Wxd195Qu8EarJoa1wOKk1ebf0pC70aEyAaWAaiDarJoa0NZhqHbutOW1WsiSS5dawdaVlE1hjE(48cuBOm64l3lyon)2lOB2qq6fVWH4UnV18BVqCWPbOB2qq6akMk8bOWPbapHcN46aiUMimLodaRXej8hqXKXgaknaroDgqnxUoaRpd42YLodOyQWhasuYy2oGVoaK495Q0l42uPnnVamhawBtdLrs(n5YAsNGUzdbPdOWaqfRv5DYy2g(AOUpxLI3dOWaqEaWCaQXOwLPJC2TKAdLrNben6auJrTkth5SBj1gkJodOWaqfRv5DYy2g(AOUpxLlHWYMpGsWnGlyAaymGcda5baZbOB2qqQuXtc34b3)SZxShq0Odq3SHGuPIN09p78fB5siSS5diA0bG120qzKu3SHG0W9M)MASda3aUmamgq0Odq3SHGuPErIkwRHJ4AA(9akb3aQju4Ayjew2CV6JmM(48cuBOm64l3l42uPnnVamhawBtdLrs(n5YAsNGUzdbPdOWaqfRv5DYy2g(AOUpxLI3dOWaqEaWCaQXOwLPJC2TKAdLrNben6auJrTkth5SBj1gkJodOWaqfRv5DYy2g(AOUpxLlHWYMpGsWnGlyAaymGcda5baZbOB2qqQuViHB8G7F25l2diA0bOB2qqQuViD)ZoFXwUeclB(aIgDayTnnugj1nBiinCV5VPg7aWna8gagdiA0bOB2qqQuXtIkwRHJ4AA(9akb3aQju4Ayjew2CVG508BVGUzdbP45vFKyMpoVa1gkJo(Y9cMtZV9c6MneKEXlCiUBZBn)2lG5Rd4BwSd4BAaFparonaDZgcshW9(yZdXhGnauXAf)biYPbOWPb8kCAhW3dW9p78fB5aqs2bK1b0uQWPDa6MneKoG79XMhIpaBaOI1k(dqKtda9v4d47b4(ND(IT0l42uPnnVamhGUzdbPs9IeUXdICkGkwRdOWaqEa6MneKkv8KU)zNVylxcHLnFarJoayoaDZgcsLkEs4gpiYPaQyToamgq0OdW9p78fB5DYy2g(AOUpxLlHWYMpGsgaEyYR(irQpoVa1gkJo(Y9cUnvAtZlaZbOB2qqQuXtc34brofqfR1buyaipaDZgcsL6fP7F25l2YLqyzZhq0OdaMdq3SHGuPErc34brofqfR1bGXaIgDaU)zNVylVtgZ2Wxd195QCjew28buYaWdtEbZP53EbDZgcsXZRE1lG(8W9)SSH6JZh5fFCEbQnugD8L7fmNMF7fG)fzzdnGYmU6foe3T5TMF7fkFjtHpGVoaHSpRb952aU)NLn0bSVAA(9aI3a4QTkFaxWeFaOu9xAaL)cdi5dWWAjZqzKxWTPsBAEbS2MgkJK7RvxyteKx9rINpoVa1gkJo(Y9cUnvAtZlyonXsbQjejXhqj4gaEdiA0bSInj1ebf0pG0balCdaQ7mGcdaRTPHYi5wmGkwRCVG508BVWsi(LtmIZdfZwP1R(iJPpoVa1gkJo(Y9cMtZV9cpklvAnL8cUnvAtZlSID6c3FrALhQMUuhqj4gaEi1l4I1XOGAlus5(iV4vFKyMpoVa1gkJo(Y9cUnvAtZlSID6c3FrALhQMUuhaSgaEyAafga)MySGAlus5sOmZLglyhSw7ObucUbG3akma3)SZxSL3jJzB4RH6(CvUeclB(akzai1lyon)2laLzU0yb7G1Ah5vFKi1hNxGAdLrhF5EbZP53EH6(CnW1nHG8cUnvAtZlSID6c3FrALhQMUuhaSgaEyAafgG7F25l2Y7KXSn81qDFUkxcHLnFaLmaK6fCX6yuqTfkPCFKx8QpsKSpoVa1gkJo(Y9cUnvAtZlGkwRsisglBObeMdE2KCjZPdOWawXoDH7ViTYdvtxQdOKbG8aUG0bu2auJrTkxXoDbtvQfnn)wsTHYOZaqcdaPdaJbuya8BIXcQTqjLlR7ZvUlwfonGsWna8gqHbaZbG120qzK8qMcNhoIuWCAIL8cMtZV9c195k3fRcN8QpYiGpoVa1gkJo(Y9cUnvAtZlSID6c3FrALhQMUuhqj4gaYdiMiDaLna1yuRYvStxWuLArtZVLuBOm6maKWaq6aWyafga)MySGAlus5Y6(CL7IvHtdOeCdaVbuyaWCayTnnugjpKPW5HJifmNMyjVG508BVqDFUYDXQWjV6Jm(6JZlqTHYOJVCVGBtL208cU)zNVylVtgZ2Wxd195QCjew28buYawXMKAIGc6hWSbuyaRyNUW9xKw5HQPl1baRbGzyAafga)MySGAlus5sOmZLglyhSw7ObucUbGNxWCA(TxakZCPXc2bR1oYR(ilL(48cuBOm64l3lyon)2lu3NRbUUjeKxWTPsBAEb3)SZxSL3jJzB4RH6(CvUeclB(akzaRytsnrqb9dy2akmGvStx4(lsR8q10L6aG1aWmm5fCX6yuqTfkPCFKx8Qx9cOppOPdISH6JZh5fFCEbQnugD8L7fmNMF7fEuwQ0Ak5fCX6yuqTfkPCFKx8cUnvAtZlSID6c3FrALhQMUuhqj4gaYdaZq6akBaQXOwLRyNUGPk1IMMFlP2qz0zaiHbG0bGHx4qC3M3A(TxO8Lmf(a(6aeY(Sg0NBdic60elnGi0RMMF7vFK45JZlqTHYOJVCVGBtL208cyTnnugj3IbuXALpGOrhG50elfOMqKeFaLGBa4nGOrhWk2PlC)fPDaWAaXepVG508BVWsi(LtmIZdfZwP1R(iJPpoVa1gkJo(Y9cUnvAtZlSID6c3FrAhaSgqmXZlyon)2lCitHhS(eoKZI1R(iXmFCEbQnugD8L7fCBQ0MMxaRTPHYi5(A1f2ebnGcda5bSID6c3FrALhQMUuhaSgasr6aIgDaRytsnrqb9dXCaWc3aG6odiA0bSInv)fkjxdkf(AqHtH6(Xp1bhCdXD(TKAdLrNben6a43eJfuBHskxc)lYYgAaLzCDaLGBa4namgq0Odyf70fU)I0oaynGyINxWCA(Txa(xKLn0akZ4Qx9rIuFCEbQnugD8L7fCBQ0MMxavSwLqKmw2qdimh8SjP49akma(nXyb1wOKYL195k3fRcNgqj4gaEdOWaG5aWABAOmsEitHZdhrkyonXsEbZP53EH6(CL7IvHtE1hjs2hNxGAdLrhF5Eb3MkTP5fwXoDH7ViTYdvtxQdOeCdaZW0akmGvSjPMiOG(HyoGsgau3Xlyon)2la)3o81qXSvA9QpYiGpoVa1gkJo(Y9cUnvAtZlWVjglO2cLuUSUpx5Uyv40akb3aWBafgamhawBtdLrYdzkCE4isbZPjwYlyon)2lu3NRCxSkCYR(iJV(48cuBOm64l3lyon)2l8OSuP1uYl42uPnnVWk2PlC)fPvEOA6sDaLma8q6aIgDaRytsnrqb9dXCaWAaqDhVGlwhJcQTqjL7J8Ix9rwk9X5fO2qz0XxUxWTPsBAEbS2MgkJK7RvxyteKxWCA(Txa(xKLn0akZ4Qx9rEbt(48cuBOm64l3l42uPnnVWk2PlC)fPvEOA6sDaLmaKIjVG508BVGToRPG(7sT6vV6vVawA553(iXdt4DbtramHuVqrB7SHY9cyUrWiuKy(iJpI3agqCWPbKiU)vhq93bC19StaozREDalvkeZLodG)iObyI6JWu6mahCRHsC5azPZMgWL4nGy8nwAv6mGRQXOwLW(6a0FaxvJrTkHTKAdLrNRda5lred5azPZMgaEXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaYxIigYbYsNnnGygVbeJVXsRsNbCvng1Qe2xhG(d4QAmQvjSLuBOm6CDaiFjIyihilD20aWS4nGy8nwAv6mGRQXOwLW(6a0FaxvJrTkHTKAdLrNRda5lred5a5ajMBemcfjMpY4J4nGbehCAajI7F1bu)DaxFuwQ0AA(91bSuPqmx6ma(JGgGjQpctPZaCWTgkXLdKLoBAaLY4nGy8nwAv6mGRQXOwLW(6a0FaxvJrTkHTKAdLrNRdaz8IigYbYbsm3iyeksmFKXhXBadio40ase3)QdO(7aUI(8GMoiYg61bSuPqmx6ma(JGgGjQpctPZaCWTgkXLdKLoBAaxI3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKVermKdKLoBAayw8gqm(glTkDgW1vSP6VqjjSVoa9hW1vSP6VqjjSLuBOm6CDaiFjIyihihiXCJGrOiX8rgFeVbmG4GtdirC)RoG6Vd4Q7XsT1k)6awQuiMlDga)rqdWe1hHP0zao4wdL4YbYsNnna8I3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKVermKdKLoBAaXmEdigFJLwLod4QAmQvjSVoa9hWv1yuRsylP2qz056aq(seXqoqw6SPbGzXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaYxIigYbYsNnnaKgVbeJVXsRsNbCvng1Qe2xhG(d4QAmQvjSLuBOm6CDaiJxeXqoqw6SPbebI3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKVermKdKLoBAaLY4nGy8nwAv6mGR8xKHM9rc7Rdq)bCL)Im0SpsylP2qz056aqgViIHCGCGeZncgHIeZhz8r8gWaIdonGeX9V6aQ)oGRC16JTNRdyPsHyU0za8hbnatuFeMsNb4GBnuIlhilD20aqA8gqm(glTkDgWv1yuRsyFDa6pGRQXOwLWwsTHYOZ1by6aqsrsk9aq(seXqoqw6SPbebI3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKVermKdKLoBAaX34nGy8nwAv6mGRQXOwLW(6a0FaxvJrTkHTKAdLrNRda5lred5azPZMgqPmEdigFJLwLod4QAmQvjSVoa9hWv1yuRsylP2qz056aq(seXqoqoqI5gbJqrI5Jm(iEdyaXbNgqI4(xDa1FhWv0NhU)NLn0RdyPsHyU0za8hbnatuFeMsNb4GBnuIlhilD20aqYXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaYxIigYbYsNnnGiq8gqm(glTkDgWv1yuRsyFDa6pGRQXOwLWwsTHYOZ1bG8LiIHCGCGeZncgHIeZhz8r8gWaIdonGeX9V6aQ)oGR3l5EeOMEDalvkeZLodG)iObyI6JWu6mahCRHsC5azPZMgWL4nGy8nwAv6maHermgap2wTioGiCeEa6pGslAdaXFezI8b830A6Vda5imgdaz8IigYbYsNnnGlXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaYXmIyihilD20aUeVbeJVXsRsNbCv3SHGu5fjSVoa9hWvDZgcsL6fjSVoaKJzeXqoqw6SPbGx8gqm(glTkDgGqIigdGhBRwehqeocpa9hqPfTbG4pImr(a(BAn93bGCegJbGmEred5azPZMgaEXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaYXmIyihilD20aWlEdigFJLwLod4QUzdbPs8KW(6a0Fax1nBiivQ4jH91bGCmJigYbYsNnnGygVbeJVXsRsNbiKiIXa4X2QfXbeHhG(dO0I2aoj2KNFpG)Mwt)DaiddmgaY4frmKdKLoBAaXmEdigFJLwLod4QUzdbPYlsyFDa6pGR6MneKk1lsyFDaiJzred5azPZMgqmJ3aIX3yPvPZaUQB2qqQepjSVoa9hWvDZgcsLkEsyFDaiJ0iIHCGS0ztdaZI3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKVermKdKLoBAayw8gqm(glTkDgW1vSP6VqjjSVoa9hW1vSP6VqjjSLuBOm6CDaMoaKuKKspaKVermKdKLoBAayw8gqm(glTkDgWv33hXuLW(6a0FaxDFFetvcBj1gkJoxhaYxIigYbYbsm3iyeksmFKXhXBadio40ase3)QdO(7aU6(ND(In)6awQuiMlDga)rqdWe1hHP0zao4wdL4YbYsNnna8I3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKVermKdKLoBAaXmEdigFJLwLod4QAmQvjSVoa9hWv1yuRsylP2qz056aq(seXqoqw6SPbGzXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhGPdajfjP0da5lred5azPZMgasJ3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKVermKdKLoBAai54nGy8nwAv6mGRQXOwLW(6a0FaxvJrTkHTKAdLrNRda5lred5azPZMgqeiEdigFJLwLod4QAmQvjSVoa9hWv1yuRsylP2qz056aq(seXqoqw6SPbukJ3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKVermKdKLoBAaxUeVbeJVXsRsNbCvng1Qe2xhG(d4QAmQvjSLuBOm6CDaiFjIyihilD20aUGx8gqm(glTkDgWv1yuRsyFDa6pGRQXOwLWwsTHYOZ1bGmEred5azPZMgWfKgVbeJVXsRsNbCDfBQ(lusc7Rdq)bCDfBQ(luscBj1gkJoxhGPdajfjP0da5lred5a5ajMBemcfjMpY4J4nGbehCAajI7F1bu)Dax1nBiiLFDalvkeZLodG)iObyI6JWu6mahCRHsC5azPZMgaEXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaY4frmKdKLoBAa4fVbeJVXsRsNbCv3SHGu5fjSVoa9hWvDZgcsL6fjSVoaKVermKdKLoBAa4fVbeJVXsRsNbCv3SHGujEsyFDa6pGR6MneKkv8KW(6aqgViIHCGS0ztdiMXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaY4frmKdKLoBAaXmEdigFJLwLod4QUzdbPYlsyFDa6pGR6MneKk1lsyFDaiJxeXqoqw6SPbeZ4nGy8nwAv6mGR6MneKkXtc7Rdq)bCv3SHGuPINe2xhaYxIigYbYsNnnamlEdigFJLwLod4QUzdbPYlsyFDa6pGR6MneKk1lsyFDaiFjIyihilD20aWS4nGy8nwAv6mGR6MneKkXtc7Rdq)bCv3SHGuPINe2xhaY4frmKdKLoBAainEdigFJLwLod4QUzdbPYlsyFDa6pGR6MneKk1lsyFDaiJxeXqoqw6SPbG04nGy8nwAv6mGR6MneKkXtc7Rdq)bCv3SHGuPINe2xhaYxIigYbYbsm3iyeksmFKXhXBadio40ase3)QdO(7aUEOQjY0RdyPsHyU0za8hbnatuFeMsNb4GBnuIlhilD20aqA8gqm(glTkDgW1vSP6VqjjSVoa9hW1vSP6VqjjSLuBOm6CDaiJxeXqoqw6SPbGKJ3aIX3yPvPZaU6((iMQe2xhG(d4Q77JyQsylP2qz056aq(seXqoqw6SPbeFJ3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKXlIyihilD20akLXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaYXmIyihilD20aUGP4nGy8nwAv6mGRQXOwLW(6a0FaxvJrTkHTKAdLrNRda5lred5azPZMgWLlXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaYxIigYbYsNnnGli54nGy8nwAv6mGRQXOwLW(6a0FaxvJrTkHTKAdLrNRdaz8IigYbYsNnnGlX34nGy8nwAv6mGRQXOwLW(6a0FaxvJrTkHTKAdLrNRda5lred5azPZMgWLsz8gqm(glTkDgWv1yuRsyFDa6pGRQXOwLWwsTHYOZ1by6aqsrsk9aq(seXqoqw6SPbGhMI3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoaKVermKdKdKyUrWiuKy(iJpI3agqCWPbKiU)vhq93bC1E66awQuiMlDga)rqdWe1hHP0zao4wdL4YbYsNnna8I3aIX3yPvPZaUQgJAvc7Rdq)bCvng1Qe2sQnugDUoathaskssPhaYxIigYbYsNnnGygVbeJVXsRsNbCvng1Qe2xhG(d4QAmQvjSLuBOm6CDaMoaKuKKspaKVermKdKLoBAarG4nGy8nwAv6mGRQXOwLW(6a0FaxvJrTkHTKAdLrNRda5lred5azPZMgq8nEdigFJLwLod4QAmQvjSVoa9hWv1yuRsylP2qz056aq(seXqoqw6SPbCbtXBaX4BS0Q0zaxvJrTkH91bO)aUQgJAvcBj1gkJoxhaYxIigYbYbY4Gtd4QiNcPsi4xhG5087bu04dOFDa1xSpdi7bOWt(ase3)QYbsmpI7Fv6mGlXCaMtZVhal5kxoq6fU3VMmYluQL6aIptMcFayo2ju46aqI3NRdKLAPoaifzXoa8UG)aWdt4DzGCGSul1bed4wdL4dKLAPoamNdicriES0zamJRyo5K77Zae5guAaFDaXaULnFaFDayEhnaJpGuhW5jEFvhWnZIDafjgBazpG71CA6i5a5azPoaKuSgt0uIpaBa6MneKYhG7F25l24pGtInp0zaOXoG7KXSDaFDa1956a(DaOlzk8b81bWZ(Sg0NBx5dW9p78fB5aW81bK6v(aWAmrAaWn(a6FalHWY(q7awsf3EaxWFaeJtdyjvC7bGjjsLdKMtZV5Y7LCpcutldhmWABAOmc)2qq40nBiinCjWJTD4)344KMv8XAmrc3f8XAmrkqmoHdtsKIV77tQ5340nBiivErc34brofqfR1cidt1yuRs0LmfE4RbE2N1G(CRaY6MneKkViD)ZoFXwEextZVJWry3)SZxSL3jJzB4RH6(CvEextZVXHjmIgvng1QeDjtHh(AGN9znOp3kGS7F25l2s0LmfE4RbE2N1G(CtEextZVJWryDZgcsLxKU)zNVylpIRP534WegrJQgJAvMoYz3ymqAon)MlVxY9iqnTmCWaRTPHYi8BdbHt3SHG0aEbESTd))ghN0SIpwJjs4UGpwJjsbIXjCysIu8DFFsn)gNUzdbPs8KWnEqKtbuXATaYWung1QeDjtHh(AGN9znOp3kGSUzdbPs8KU)zNVylpIRP53r4iS7F25l2Y7KXSn81qDFUkpIRP534WegrJQgJAvIUKPWdFnWZ(Sg0NBfq29p78fBj6sMcp81ap7ZAqFUjpIRP53r4iSUzdbPs8KU)zNVylpIRP534WegrJQgJAvMoYz3ymqwQdajLRjctj(aSbOB2qqkFaynMina0yhG7rCBB2qhGcNgG7F25l2d4RdqHtdq3SHGu8hWjXMh6ma0yhGcNgWrCnn)EaFDakCAaOI16asDa37JnpexoG4tgFa2a46snuf(aq8NSM0oa9ha0elnaBaWtOWPDa3B(BQXoa9haxxQHQWhGUzdbPC8hGXhqrIXgGXhGnae)jRjTdO(7aY6aSbOB2qq6akMm2a(DaftgBa9RdGhB7gqXuHpa3)SZxS5YbsZP53C59sUhbQPLHdgyTnnugHFBiiC6MneKgU383uJf))ghN0SIpwJjs4WdFSgtKceJt4UGV77tQ534GPUzdbPYls4gpiYPaQyTwq3SHGujEs4gpiYPaQyTgnQUzdbPs8KWnEqKtbuXATaYiRB2qqQepP7F25l2YJ4AA(Dew3SHGujEsuXAnCextZVXajG8fjslt3SHGujEs4gpGkwRsUUudvHJbsazS2MgkJK6MneKgWlWJTDyGrjiJSUzdbPYls3)SZxSLhX1087iSUzdbPYlsuXAnCextZVXajG8fjslt3SHGu5fjCJhqfRvjxxQHQWXajGmwBtdLrsDZgcsdxc8yBhgymqAon)MlVxY9iqnTmCWaRTPHYi8BdbHBlgqfRvo(ynMiHtng1QeQPWPnBObU(lIOrDFFetvsyPTUpxJgDfBQ(lusIMA2qdUNDginNMFZL3l5EeOMwgoyuzehUBTQoqoqwQL6aqsJi5ev6maclTXoanrqdqHtdWC6Vdi5dWWAjZqzKCG0CA(nhhISpH6su8tdKL6aqIwcl16a43KlRjDgGUzdbP8bGszdDaIC6mGIPcFaMO(imnDdGLnXhinNMFZldhmWABAOmc)2qq443KlRjDc6MneKIpwJjs4qMkfI59nDKzZDROAOmkukeTwfreoe20rfC)ZoFXwMn3TIQHYOqPq0Aver4qythjxYoXIXaP508BEz4GbwBtdLr43gcchxd3mR7SHIpwJjs4mNMyPa1eIK44Uua51YtGWsTkTZHlZUKlinAuyUwEcewQvPDoCjfXKRCmginNMFZldhmWABAOmc)2qq4SZHhwcHLn(ynMiHZCAILcutisIxco8kGmmxlpbcl1Q0ohUKIyYvE0ORLNaHLAvANdxsrm5kVaYRLNaHLAvANdxUeclBEjinA0AcfUgwcHLnVKlycdmginNMFZldhmWABAOmc)2qq42xRUWMii8XAmrchQyTk3ebjfVlGmmxXMQ)cLKRbLcFnOWPqD)4N6GdUH4o)oA0vSP6Vqj5AqPWxdkCku3p(Po4GBiUZVlSID6c3FrALhQMUulj(IXaP508BEz4GbwBtdLr43gccxDFUg46Mqqb33hXu54J1yIeo33hXuL0AN0zA2qdOSVybuXAvsRDsNPzdnGY(IsUAoiWHx0OUVpIPkfBgzC40juxQJ)ylGkwRsXMrghoDc1L64pw5siSS5WczOUdsapmginNMFZldhmWABAOmc)2qq4oKPW5HJifmNMyj8XAmrc3HmfEW6t4qolwPMoiYgAb3JLARvzNqHRHQrdKL6aIG33Syhas8(CDaiXewAXFaiSSvl7bG5DXoG4m238by9zaqq09aIqeIF5eJ48bG5MTs7a2NXYg6aP508BEz4GXsi(LtmIZdfZwPf)SIZ99rmvjHL26(CTGAmQvjutHtB2qdC9xefGPAmQv5JYsLwtZVl4(ND(IT8ozmBdFnu3NRYLqyzZhinNMFZldhmG)fzzdnGYmUIVlwhJcQTqjLJ7c(zf35vzDFUgQewALlvxId3qzubKvJrTkth5S7OrHjQyTkrxYu4HVg4zFwd6ZnP4Db1yuRs0LmfE4RbE2N1G(ClAu1yuRYhLLkTMMFxW9p78fB5DYy2g(AOUpxLlHWYMxaMOI1QeIKXYgAaH5GNnjfVXyG0CA(nVmCWakZCPXc2bR1oc)SIdvSwLPl2GASV5YLqyzZHfoOUtbuXAvMUydQX(MlfVlWVjglO2cLuUekZCPXc2bR1oQeC4vazyQgJAvIUKPWdFnWZ(Sg0NBrJ6(ND(ITeDjtHh(AGN9znOp3KlHWYMxYfKIXaP508BEz4GrDFUg46Mqq4NvCOI1QmDXguJ9nxUeclBoSWb1DkGkwRY0fBqn23CP4DbKHPAmQvj6sMcp81ap7ZAqFUfnkmrfRvj6sMcp81ap7ZAqFUjfVl4(ND(ITeDjtHh(AGN9znOp3KlHWYMxYfmHXazPoGya)FonGiOtZVhal56a0FaRypqAon)Mxgoy4mglyon)oWsUIFBiiCUhl1wR8bsZP538YWbdNXybZP53bwYv8BdbHBnxAm(aP508BEz4GHZySG5087al5k(THGWPB2qqkFG0CA(nVmCWWzmwWCA(DGLCf)2qq4C)ZoFXMpqAon)Mxgoy4mglyon)oWsUIFBiiCUNDcWjBv8Zko1yuRs3Zob4KTAbKHjQyTkHizSSHgqyo4ztsX7OrvJrTkrxYu4HVg4zFwd6ZnmkG8HqfRv5AX)VPJKC1CqGdPrJcZdzk8aeDcfUkxXMQ)cLKRf))MocJbsZP538YWbJvSdMtZVdSKR43gcch6ZdA6GiBO4NvCOI1QeDjtHh(AGN9znOp3KI3dKMtZV5LHdgRyhmNMFhyjxXVneeo0NhU)NLnu8Zko1yuRs0LmfE4RbE2N1G(CRaYU)zNVylrxYu4HVg4zFwd6Zn5siSS5W6cMWOaYRLNaHLAvANdxMDj4H0OrH5A5jqyPwL25WLuetUYJg19p78fB5DYy2g(AOUpxLlHWYMdRlyQWA5jqyPwL25WLuetUYlSwEcewQvPDoCz2W6cMWyG0CA(nVmCWyf7G5087al5k(THGW9OSuP108B8ZkouXAvENmMTHVgQ7ZvP4Db1yuRYhLLkTMMFpqAon)MxgoySIDWCA(DGLCf)2qq4EuwQ0AA(D4(Fw2qXpR4uJrTkFuwQ0AA(Db3)SZxSL3jJzB4RH6(CvUeclBoSUGPciJ120qzKKRHBM1D2qJgDT8eiSuRs7C4skIjx5fwlpbcl1Q0ohUmByDbtrJcZ1YtGWsTkTZHlPiMCLJXaP508BEz4GXk2bZP53bwYv8BdbHZEc)SIZCAILcutisIxco8ginNMFZldhmCgJfmNMFhyjxXVneeoUA9X2Za5azPoGi4JKoGi0RMMFpqAon)MlTNWTeIF5eJ48qXSvAhinNMFZL2tLHdgqzMlnwWoyT2r4NvCQXOwL195k3fRcNgil1bGe)lcrMLUby337Bo4dq)b4wYuAa2aU5K45hW9M)MASdqTfkPdGLCDa1FhGDFZInBOdyT4)30rdi7bypnqAon)MlTNkdhmQ7Z1ax3eccFxSogfuBHskh3f8Zko3)SZxSLlH4xoXiopumBLw5siSS5WchEibOUtb1yuRsOMcN2SHg46ViginNMFZL2tLHdgW)ISSHgqzgxXpR4WABAOmsUVwDHnrqdKMtZV5s7PYWbJhLLkTMs4NvCyTnnugjpKPW5HJifmNMyPcOI1Q8qMcNhoIKKRMdcyHzdKMtZV5s7PYWbJ6(CL7IvHt4NvCOI1QeIKXYgAaH5GNnjxYCAbyI120qzK8qMcNhoIuWCAILginNMFZL2tLHdgqzMlnwWoyT2r4NvCRyNUW9xKw5HQPlvyH8fKwMAmQv5k2PlyQsTOP53iHyIXaP508BU0EQmCWOUpxdCDtii8DX6yuqTfkPCCxWpR4wXoDH7ViTYdvtxQWc5liTm1yuRYvStxWuLArtZVrcifJbsZP53CP9uz4GrDFUYDXQWj8ZkoyI120qzK8qMcNhoIuWCAILginNMFZL2tLHdgpklvAnLW3fRJrb1wOKYXDb)SIBf70fU)I0kpunDPwcY4H0YuJrTkxXoDbtvQfnn)gjGumginNMFZL2tLHdgqzMlnwWoyT2rdKMtZV5s7PYWbJ6(CnW1nHGW3fRJrb1wOKYXDzG0CA(nxApvgoya)3o81qXSvAhinNMFZL2tLHdg26SMc6Vl16a5azPoGYxYu4d4Rdqi7ZAqFUnG7)zzdDa7RMMFpG4naUARYhWfmXhakv)Lgq5VWas(amSwYmugnqAon)MlrFE4(Fw2qXb)lYYgAaLzCf)SIdRTPHYi5(A1f2ebnqAon)MlrFE4(Fw2qldhmwcXVCIrCEOy2kT4NvCMttSuGAcrs8sWHx0ORytsnrqb9difw4G6ofWABAOmsUfdOI1kFGSul1bCvTfkPHSIdHfX4H8HqfRv5AX)VPJKC1Cqu2fmIWiFiuXAvUw8)B6i5siSS5LDbdKWHmfEaIoHcxLRyt1FHsY1I)FthDDari6MmLpaBaSxXFak8KpGKpGSvQp0za6pa1wOKoafona4ju4exhW9M)MASdGAcrSdOyQWhG1dWqtwQXoafUPdOyYydWUVzXoG1I)FthnGSoGvSP6VqPJCaXb30bGszdDawpaQjeXoGIPcFayAaC1CqWXFa)oaRha1eIyhGc30bOWPbCiuXADaftgBa8)7bqr8oxAaFlhinNMFZLOppC)plBOLHdgpklvAnLW3fRJrb1wOKYXDb)SIBf70fU)I0kpunDPwco8q6aP508BUe95H7)zzdTmCWakZCPXc2bR1oc)SIBf70fU)I0kpunDPcl8Wub(nXyb1wOKYLqzMlnwWoyT2rLGdVcU)zNVylVtgZ2Wxd195QCjew28sq6aP508BUe95H7)zzdTmCWOUpxdCDtii8DX6yuqTfkPCCxWpR4wXoDH7ViTYdvtxQWcpmvW9p78fB5DYy2g(AOUpxLlHWYMxcshinNMFZLOppC)plBOLHdg195k3fRcNWpR4qfRvjejJLn0acZbpBsUK50cRyNUW9xKw5HQPl1sq(csltng1QCf70fmvPw008BKasXOa)MySGAlus5Y6(CL7IvHtLGdVcWeRTPHYi5HmfopCePG50elnqAon)MlrFE4(Fw2qldhmQ7ZvUlwfoHFwXTID6c3FrALhQMUulbhYXePLPgJAvUID6cMQulAA(nsaPyuGFtmwqTfkPCzDFUYDXQWPsWHxbyI120qzK8qMcNhoIuWCAILginNMFZLOppC)plBOLHdgqzMlnwWoyT2r4NvCU)zNVylVtgZ2Wxd195QCjew28swXMKAIGc6hWScRyNUW9xKw5HQPlvyHzyQa)MySGAlus5sOmZLglyhSw7OsWH3aP508BUe95H7)zzdTmCWOUpxdCDtii8DX6yuqTfkPCCxWpR4C)ZoFXwENmMTHVgQ7Zv5siSS5LSInj1ebf0pGzfwXoDH7ViTYdvtxQWcZW0a5azPoGYxYu4d4Rdqi7ZAqFUnGiOttS0aIqVAA(9aP508BUe95bnDqKnuCpklvAnLW3fRJrb1wOKYXDb)SIBf70fU)I0kpunDPwcoKXmKwMAmQv5k2PlyQsTOP53ibKIXaP508BUe95bnDqKn0YWbJLq8lNyeNhkMTsl(zfhwBtdLrYTyavSw5rJAonXsbQjejXlbhErJUID6c3FrAHvmXBG0CA(nxI(8GMoiYgAz4GXHmfEW6t4qolw8ZkUvStx4(lslSIjEdKMtZV5s0Nh00br2qldhmG)fzzdnGYmUIFwXH120qzKCFT6cBIGkG8k2PlC)fPvEOA6sfwifPrJUInj1ebf0petyHdQ7en6k2u9xOKCnOu4RbfofQ7h)uhCWne353rJYVjglO2cLuUe(xKLn0akZ4Aj4WdJOrxXoDH7ViTWkM4nqAon)MlrFEqthezdTmCWOUpx5Uyv4e(zfhQyTkHizSSHgqyo4ztsX7c8BIXcQTqjLlR7ZvUlwfovco8katS2MgkJKhYu48WrKcMttS0aP508BUe95bnDqKn0YWbd4)2HVgkMTsl(zf3k2PlC)fPvEOA6sTeCygMkSInj1ebf0peZsG6odKMtZV5s0Nh00br2qldhmQ7ZvUlwfoHFwXXVjglO2cLuUSUpx5Uyv4uj4WRamXABAOmsEitHZdhrkyonXsdKMtZV5s0Nh00br2qldhmEuwQ0AkHVlwhJcQTqjLJ7c(zf3k2PlC)fPvEOA6sTe8qA0ORytsnrqb9dXewqDNbsZP53Cj6ZdA6GiBOLHdgW)ISSHgqzgxXpR4WABAOmsUVwDHnrqdKMtZV5s0Nh00br2qldhmS1znf0FxQv8ZkUvStx4(lsR8q10LAjiftdKdKLAPoGy8SZaIpr2QdigFFsn)MpqwQL6amNMFZLUNDcWjBvCo4w28WxdPJWpR4Qju4Ayjew2Cyb1DkG8k2eSWlAuyIkwRsisglBObeMdE2Ku8UaYWeHLDaU1hjEWlGkwRs3Zob4KTQKRMdIsWHzLTInv)fkjH4zAUgpunS)gnkcl7aCRps8GxavSwLUNDcWjBvjxnheLeFlBfBQ(luscXZ0CnEOAy)fJOrrfRvjejJLn0acZbpBskExazyIWYoa36Jep4fqfRvP7zNaCYwvYvZbrjX3YwXMQ)cLKq8mnxJhQg2FJgfHLDaU1hjEWlGkwRs3Zob4KTQKRMdIsUGPYwXMQ)cLKq8mnxJhQg2FXaJbYsDayoGtd4iUzdDairjJz7akMk8bG5DKZUHr5lzk8bsZP53CP7zNaCYwTmCWWb3YMh(AiDe(zfhmvJrTkFuwQ0AA(DbuXAvENmMTHVgQ7ZvP4DbuXAv6E2jaNSvLC1CqucUlyQaQyTkVtgZ2Wxd195QCjew2Cyb1DqciFPm3)SZxSL195AXyxe8qvCJvUKDIfJbYsDaijIkpp0a(6aqIsgZ2biYjdknGIPcFayEh5SByu(sMcFG0CA(nx6E2jaNSvldhmCWTS5HVgshHFwXbt1yuRYhLLkTMMFx4qMcparNqHRYvSP6Vqjz1ymQdUvKBhAlatuXAvENmMTHVgQ7ZvP4Db3)SZxSL3jJzB4RH6(CvUeclBEjxqAbKrfRvP7zNaCYwvYvZbrj4UGPcOI1QuSH)SydCDPgQcxkEhnkQyTkDp7eGt2QsUAoikb3LyIXaP508BU09StaozRwgoy4GBzZdFnKoc)SIdMQXOwLpklvAnn)UampKPWdq0ju4QCfBQ(luswngJ6GBf52H2cOI1Q09StaozRk5Q5GOeCxWubyIkwRY7KXSn81qDFUkfVl4(ND(IT8ozmBdFnu3NRYLqyzZlbpmnqwQdajAjSuRdigp7mG4tKT6aES06S77SHoGJ4Mn0bCNmMTdKMtZV5s3Zob4KTAz4GHdULnp81q6i8Zko1yuRYhLLkTMMFxaMOI1Q8ozmBdFnu3NRsX7ciJkwRs3Zob4KTQKRMdIsWDbZkGkwRsXg(ZInW1LAOkCP4D0OOI1Q09StaozRk5Q5GOeCxkLrJ6(ND(IT8ozmBdFnu3NRYLqyzZHvmlGkwRs3Zob4KTQKRMdIsWDbZWyGCGSuhas0R53dKMtZV5s3)SZxS54UFn)g)SIdvSwL3jJzB4RH6(CvkEpqwQdig)ZoFXMpqAon)MlD)ZoFXMxgoyqiU)I0gwXMcfj7(B8Zko1yuRYhLLkTMMFxyfBcwi5ciJ120qzKKRHBM1D2qJgfRTPHYiPDo8WsiSSXOaYU)zNVylVtgZ2Wxd195QCjew2CyH0OrrfRv5DYy2g(AOUpxLI3yenAnHcxdlHWYMdl8W0aP508BU09p78fBEz4GbH4(lsByfBkuKS7VXpR4uJrTkrxYu4HVg4zFwd6ZTcRyNUW9xKw5HQPl1sIjMkSInj1ebf0pG0sG6ofqgvSwLOlzk8Wxd8SpRb95Mu8oA0AcfUgwcHLnhw4HjmginNMFZLU)zNVyZldhmie3FrAdRytHIKD)n(zfNAmQvz6iNDpqAon)MlD)ZoFXMxgoyCNmMTHVgQ7Zv8Zko1yuRs0LmfE4RbE2N1G(CRaYyTnnugj5A4MzDNn0OrXABAOmsANdpSeclBmkGS7F25l2s0LmfE4RbE2N1G(CtUeclBE0OU)zNVylrxYu4HVg4zFwd6Zn5s2j2cRyNUW9xKw5HQPlvyHumHXaP508BU09p78fBEz4GXDYy2g(AOUpxXpR4uJrTkth5S7cWevSwL3jJzB4RH6(CvkEpqAon)MlD)ZoFXMxgoyCNmMTHVgQ7Zv8Zko1yuRYhLLkTMMFxazS2MgkJKCnCZSUZgA0OyTnnugjTZHhwcHLngfqwng1QeQPWPnBObU(lcj1gkJofqfRv5si(LtmIZdfZwPvkEhnkmvJrTkHAkCAZgAGR)IqsTHYOdgdKMtZV5s3)SZxS5LHdgOlzk8Wxd8SpRb95g(zfhQyTkVtgZ2Wxd195Qu8EG0CA(nx6(ND(InVmCWOUpxlg7IGhQIBS4NvCMttSuGAcrsCCxkGkwRY7KXSn81qDFUkxcHLnhwqDNcOI1Q8ozmBdFnu3NRsX7cWung1Q8rzPsRP53fqgMRLNaHLAvANdxsrm5kpA01YtGWsTkTZHlZUKyIjmIgTMqHRHLqyzZHvmhinNMFZLU)zNVyZldhmQ7Z1IXUi4HQ4gl(zfN50elfOMqKeVeC4vazuXAvENmMTHVgQ7ZvP4D0ORLNaHLAvANdxMDjU)zNVylVtgZ2Wxd195QCjew2CmkGmQyTkVtgZ2Wxd195QCjew2Cyb1DIgDT8eiSuRs7C4YLqyzZHfu3bJbsZP53CP7F25l28YWbJ6(CTySlcEOkUXIFwXPgJAv(OSuP1087cOI1Q8ozmBdFnu3NRsX7ciJmQyTkVtgZ2Wxd195QCjew2Cyb1DIgfvSwLIn8NfBGRl1qv4sX7cOI1QuSH)SydCDPgQcxUeclBoSG6oyua5dHkwRY1I)Fthj5Q5GahsJgfMhYu4bi6ekCvUInv)fkjxl()nDegymqAon)MlD)ZoFXMxgoyap27xHtlI0fUxItTJWpR4uJrTkrxYu4HVg4zFwd6ZTcRyNUW9xKw5HQPl1sWmmvyfBcw4IzbKrfRvj6sMcp81ap7ZAqFUjfVJg19p78fBj6sMcp81ap7ZAqFUjxcHLnVemdtyenkmvJrTkrxYu4HVg4zFwd6ZTcRyNUW9xKw5HQPl1sWHhshinNMFZLU)zNVyZldhmwl5u4q2b)SIdvSwL3jJzB4RH6(CvkEpqAon)MlD)ZoFXMxgoyWn3M10LglCBof)SIZCAILcutisIxco8kGm6Z5fQju4Ayjew2CyfZOrHjQyTkrxYu4HVg4zFwd6ZnP4DbKVjvcf(lYKlHWYMdlOUt0ORLNaHLAvANdxUeclBoSIzH1YtGWsTkTZHlZUKBsLqH)Im5siSS5yGXaP508BU09p78fBEz4GXHmfEW6t4qolw8ZkoZPjwkqnHijEjinA0vSP6Vqj5nCY2hX3eFGCGSuhqmESuBToGiiAYsnj(aP508BU09yP2ALJ7qMcNhoIe(zfhwBtdLrsUgUzw3zdnAuS2MgkJK25WdlHWYEG0CA(nx6ESuBTYldhm4fTfr2qdisUIFwXTID6c3FrALhQMUul5sml4(ND(IT8ozmBdFnu3NRYLqyzZHvmlat1yuRs0LmfE4RbE2N1G(CRawBtdLrsUgUzw3zdDG0CA(nx6ESuBTYldhm4fTfr2qdisUIFwXbt1yuRs0LmfE4RbE2N1G(CRawBtdLrs7C4HLqyzpqAon)MlDpwQTw5LHdg8I2IiBObejxXpR4uJrTkrxYu4HVg4zFwd6ZTciJkwRs0LmfE4RbE2N1G(CtkExazS2MgkJKCnCZSUZgAHvStx4(lsR8q10LAjygMIgfRTPHYiPDo8WsiSSlSID6c3FrALhQMUulbjJPOrXABAOmsANdpSecl7cRLNaHLAvANdxUeclBoSkLyenkmrfRvj6sMcp81ap7ZAqFUjfVl4(ND(ITeDjtHh(AGN9znOp3KlHWYMJXaP508BU09yP2ALxgoyyOpISnn)oWseO4NvCU)zNVylVtgZ2Wxd195QCjew2CyfZcyTnnugj5A4MzDNn0ciRgJAvIUKPWdFnWZ(Sg0NBfwXoDH7ViTYdvtxQWcjJPcU)zNVylrxYu4HVg4zFwd6Zn5siSS5WcVOrHPAmQvj6sMcp81ap7ZAqFUHXaP508BU09yP2ALxgoyyOpISnn)oWseO4NvCyTnnugjTZHhwcHL9aP508BU09yP2ALxgoyWHBoiyuqHtbXU4Vk8yXpR4WABAOmsY1WnZ6oBOfq29p78fB5DYy2g(AOUpxLlHWYMdRygnQAmQvz6iNDJXaP508BU09yP2ALxgoyWHBoiyuqHtbXU4Vk8yXpR4WABAOmsANdpSecl7bsZP53CP7XsT1kVmCWOYioC3Avf)SIdMOI1Q8ozmBdFnu3NRsX7ciZFrgA2h5TixfzuGwXBn)oAu(lYqZ(iX(mttgf4pdl1kg4NTs7kERHebc6KMs4UGF2kTR4TgGYEuJH7c(zR0UI3AiR44Vidn7Je7ZmnzuG)mSuRdKdKL6aqsqzPsRP53dyF1087bsZP53C5JYsLwtZVXTeIF5eJ48qXSvAXpR4mNMyPa1eIK4LGlMfWABAOmsUfdOI1kFG0CA(nx(OSuP1087YWbd4Frw2qdOmJR4R2cL0qwXbZZRY6(CnujS0k10br2qlatuXAvcrYyzdnGWCWZMKI3fwXMkbxmhinNMFZLpklvAnn)UmCWOUpx5Uyv4e(zfhQyTkHizSSHgqyo4ztYLmNwGFtmwqTfkPCzDFUYDXQWPsWHxbyI120qzK8qMcNhoIuWCAILginNMFZLpklvAnn)UmCW4rzPsRPe(UyDmkO2cLuoUl4NvCOI1QeIKXYgAaH5GNnjxYC6aP508BU8rzPsRP53LHdgqzMlnwWoyT2r4NvC8BIXcQTqjLlHYmxASGDWATJkbhEfqEf70fU)I0kpunDPcRlykA0vSjPMiOG(b8kbQ7Gr0OiFiuXAvUw8)B6ijxnheWcPrJEiuXAvUw8)B6i5siSS5W6csXyG0CA(nx(OSuP1087YWbJ6(CnW1nHGWpR4mNMyPa1eIK44UuaRTPHYizDFUg46Mqqb33hXu5dKMtZV5YhLLkTMMFxgoya)lYYgAaLzCf)SIdRTPHYi5(A1f2ebvGFtmwqTfkPCj8VilBObuMX1sWH3aP508BU8rzPsRP53LHdgqzMlnwWoyT2r4NvC8BIXcQTqjLlHYmxASGDWATJkbhEdKMtZV5YhLLkTMMFxgoyu3NRbUUjee(UyDmkO2cLuoUl4NvCWung1Q0WAmRDWPcWevSwLqKmw2qdimh8SjP4D0OQXOwLgwJzTdovaMyTnnugj3xRUWMiOOrXABAOmsUVwDHnrqfwXMKAIGc6hWReCqDNbsZP53C5JYsLwtZVldhmG)fzzdnGYmUIFwXH120qzKCFT6cBIGginNMFZLpklvAnn)UmCW4rzPsRPe(UyDmkO2cLuoUldKdKL6aqI(NLn0bGe)7aqsqzPsRP53XBacQTkFaxW0a4K77dFaOu9xAairjJz7a(6aqI3NRdW9ii(a(ADaXi(8aP508BU8rzPsRP53H7)zzdf3si(LtmIZdfZwPf)SIdRTPHYi5wmGkwR8OrnNMyPa1eIK4LGdVbsZP53C5JYsLwtZVd3)ZYgAz4GrDFUg46Mqq4NvCMttSuGAcrsCCxkG120qzKSUpxdCDtiOG77JyQ8bsZP53C5JYsLwtZVd3)ZYgAz4GXJYsLwtj8DX6yuqTfkPCCxWpR4qfRvjejJLn0acZbpBsUK50bsZP53C5JYsLwtZVd3)ZYgAz4Gb8VilBObuMXv8ZkoS2MgkJK7Rvxyte0aP508BU8rzPsRP53H7)zzdTmCWakZCPXc2bR1oc)SIJFtmwqTfkPCjuM5sJfSdwRDuj4WRWk2PlC)fPvEOA6sfwizmnqAon)MlFuwQ0AA(D4(Fw2qldhmQ7Z1ax3eccFxSogfuBHskh3f8ZkUvStx4(lsR8q10LkSIayAG0CA(nx(OSuP1087W9)SSHwgoy8OSuP1ucFxSogfuBHskh3f8ZkUvSPsWfZbsZP53C5JYsLwtZVd3)ZYgAz4GrDFUYDXQWj8ZkoZPjwkqnHijEj4WScWeRTPHYi5HmfopCePG50elnqoqwQdiczU0ydicIMSutIpqAon)MlxZLgJJdL9)juf3yXpR4qfRv5DYy2g(AOUpxLI3dKMtZV5Y1CPX4LHdgO0YPfISHIFwXHkwRY7KXSn81qDFUkfVhinNMFZLR5sJXldhmS1znfUfzCc)SIdzyIkwRY7KXSn81qDFUkfVlyonXsbQjejXlbhEyenkmrfRv5DYy2g(AOUpxLI3fqEfBsEOA6sTeCiTWk2PlC)fPvEOA6sTeCizmHXaP508BUCnxAmEz4GblHcx5bmhkEGIGAf)SIdvSwL3jJzB4RH6(CvkEpqAon)MlxZLgJxgoyyTJ46ASGZym8ZkouXAvENmMTHVgQ7ZvP4DbuXAvsiU)I0gwXMcfj7(BP49aP508BUCnxAmEz4GrnxcL9)b)SIdvSwL3jJzB4RH6(CvUeclBoSWfFlGkwRscX9xK2Wk2uOiz3FlfVhinNMFZLR5sJXldhmqnOHVg0nDqWXpR4qfRv5DYy2g(AOUpxLI3fmNMyPa1eIK44UuazuXAvENmMTHVgQ7Zv5siSS5WcPfuJrTkDp7eGt2QsQnugDIgfMQXOwLUNDcWjBvj1gkJofqfRv5DYy2g(AOUpxLlHWYMdRyIXa5azPoab16JTNbWZgkJWCQ2cL0bSVAA(9aP508BUKRwFS9GBje)YjgX5HIzR0IFwXH120qzKClgqfRv(aP508BUKRwFS9ugoy8OSuP1uc)SIdvSwLqKmw2qdimh8Sj5sMthinNMFZLC16JTNYWbJ6(CnW1nHGWpR4WABAOmsw3NRbUUjeuW99rmv(aP508BUKRwFS9ugoyaLzU0yb7G1AhHFwXbZdzk8aeDcfUkxXMQ)cLKRf))MoQaYhcvSwLRf))MosYvZbbSqA0OhcvSwLRf))MosUeclBoSIaymqAon)Ml5Q1hBpLHdg195AGRBcbHFwX5(ND(ITCje)YjgX5HIzR0kxcHLnhw4Wdja1DkOgJAvc1u40Mn0ax)fXaP508BUKRwFS9ugoya)lYYgAaLzCf)SIdRTPHYi5(A1f2ebnqAon)Ml5Q1hBpLHdgpklvAnLWpR4GjQyTkR7h)uhUfzCskExqng1QSUF8tD4wKXPOrXABAOmsEitHZdhrkyonXsfqfRv5HmfopCejjxnheWcZIgDfBsQjckOFaZGfoOUZaP508BUKRwFS9ugoyu3NRbUUjee(zf3k2PlC)fPvEOA6sfwiFbPLPgJAvUID6cMQulAA(nsaPymqAon)Ml5Q1hBpLHdgpklvAnLWpR4wXoDH7ViTYdvtxQLGmEiTm1yuRYvStxWuLArtZVrcifJbsZP53CjxT(y7PmCWOUpxdCDtiObsZP53CjxT(y7PmCWa(VD4RHIzR0oqAon)Ml5Q1hBpLHdg26SMc6Vl16a5azPoG42SHGu(aP508BUu3SHGuoUS5UvunugfkfIwRIichcB6i8ZkouXAvENmMTHVgQ7ZvP4D0OQTqjvQjckOF42Pb8WeSqA0OOpNxOMqHRHLqyzZHfExgil1behCAa6MneKoGIPcFakCAaWtOWjUoaIRjctPZaWAmrc)bumzSbGsdqKtNbuZLRdW6ZaUTCPZakMk8bGeLmMTd4RdajEFUkhinNMFZL6MneKYldhm0nBii9c(zfhmXABAOmsYVjxwt6e0nBiiTaQyTkVtgZ2Wxd195Qu8UaYWung1QmDKZUJgvng1QmDKZUlGkwRY7KXSn81qDFUkxcHLnVeCxWegfqgM6MneKkXtc34b3)SZxSJgv3SHGujEs3)SZxSLlHWYMhnkwBtdLrsDZgcsd3B(BQXI7cgrJQB2qqQ8IevSwdhX1087sWvtOW1WsiSS5dKMtZV5sDZgcs5LHdg6MneKIh(zfhmXABAOmsYVjxwt6e0nBiiTaQyTkVtgZ2Wxd195Qu8UaYWung1QmDKZUJgvng1QmDKZUlGkwRY7KXSn81qDFUkxcHLnVeCxWegfqgM6MneKkViHB8G7F25l2rJQB2qqQ8I09p78fB5siSS5rJI120qzKu3SHG0W9M)MAS4WdJOr1nBiivINevSwdhX1087sWvtOW1WsiSS5dKL6aW81b8nl2b8nnGVhGiNgGUzdbPd4EFS5H4dWgaQyTI)ae50au40aEfoTd47b4(ND(ITCaij7aY6aAkv40oaDZgcshW9(yZdXhGnauXAf)biYPbG(k8b89aC)ZoFXwoqAon)Ml1nBiiLxgoyOB2qq6f8ZkoyQB2qqQ8IeUXdICkGkwRfqw3SHGujEs3)SZxSLlHWYMhnkm1nBiivINeUXdICkGkwRyenQ7F25l2Y7KXSn81qDFUkxcHLnVe8W0aP508BUu3SHGuEz4GHUzdbP4HFwXbtDZgcsL4jHB8GiNcOI1AbK1nBiivEr6(ND(ITCjew28OrHPUzdbPYls4gpiYPaQyTIr0OU)zNVylVtgZ2Wxd195QCjew28sWdtEb(n58rIhsV4vV69a]] )


end
