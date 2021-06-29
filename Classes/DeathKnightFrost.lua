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


    spec:RegisterPack( "Frost DK", 20210628, [[d4u)ZcqiqWJKsvUevGSjQuFskAuqItbHwfkf8kqHzrL0TqPq1UG6xGsnmiOJPuzzqspdLstdc01qPY2Ksv9nQa14Ga4CqazDujmpqj3dsTpPuoivawiOOhsf0eLsfQlIsrAJOueFukvWiLsfYjrPOwji6LOuO0mPs0oLc(jeqnuiaTuQa6PKQPkf6QOuOWxrPqgli0Ef1FfzWQ6WuwmkEmvnzP6YiBwjFwPmAq1Pfwnkfk61kvnBuDBiA3s(TkdhKoUuQOLd8CsMoX1jLTtf9DPKXJsvNNk06LsLMpkz)koVl3ywVBcLBaveI6oe2(OIaGrLTiKDi0bN1fhHszDOMFVTrz9YqszD2eWPK5BhZgBwhQ5i)SEUXSU60aEkRdxeOkxaByVfcCngS)qcBvGuJBsCLhylb2QaPh2zDgTGlS5kZK17Mq5gqfHOUdHTpQiayuzlczhczxw30e4hiRRhiDywhE07uLzY6Ds5Z6TJjtGppBSvSbxMNnbCkzGesTIMhveaxNhveI6UbYbshc3QnsnqYgFEhiH8Cs955MsyJRi)v951u2gn)TM3HWTOuZFR5zZEAEtnFiZ3psvnL5HYnhNVfX5Zh18qbMxcpHZ68qjQCJz9JHhcbmjUkb9oEuB5gZnSl3ywNkJHt9mmZ6MxIRY6ac5bueNuQuROecK17KYdcOsCvwhb8oEuBZZMCG5rGz4HqatIRCX86Ibe187q48kYFvxnpdToanpcyW5gy(BnpBc4uY8(djPM)wR5Dy74SUhecbclRlgNkbVzcCce1wsjhajMkJHt95zXAE)vDTqWKtcSaNsWuzmCQpplwZd0kADGncZesuBj)X7yQmgo1NNfR5nVeoPeveYGuZ3g65rnl5gqn3ywNkJHt9mmZ6EqieiSSoJ2AHbbscRbnRBEjUkRd)AXJAlXWnLKLCdSn3ywNkJHt9mmZ6MxIRY6hdpecycL19GqiqyzDgT1cVp48O2sinp8OimGmVK19o65usmWgjQCd7YsUbem3ywNkJHt9mmZ6EqieiSSUckX5jXaBKOWBCZhgpzDNw5P5Bd98OoV75bAv4tqVwea3Pv4dzEynF7JWSU5L4QS(g38HXtw3PvEkl5gyxUXSovgdN6zyM1nVexL1xGtjjLaI9uw3dcHaHL1bAv4tqVwea3Pv4dzEynVdgHzDVJEoLedSrIk3WUSKBO9ZnM1PYy4updZSU5L4QS(XWdHaMqzDpiecewwhOv08THEE2M19o65usmWgjQCd7YsUbhCUXSovgdN6zyM19GqiqyzDZlHtkrfHmi18THEEeCE3ZJY8qy(ozc8Kv9uN8MJyj87JABE3Z7pNuzLGRydUKwgnplwZdH59NtQSsWvSbxslJMhXSU5L4QS(cCkr5DuGtzjlzD)X7j4KbKCJ5g2LBmRtLXWPEgMzDZlXvzDpClkv6wPWtz9oP8GaQexL1zJHIMVRbIABEeWGZnW8Tcb(8Szp5nOWgMaYe4zDpiecewwhcZlgNkbFm8qiGjXvyQmgo1N398mARfgAW5giDR0cCkbdiKwuQ5H18SDE3ZZOTwyObNBG0TslWPeSg05DppJ2AH9hVNGtgqWkX87NVn0ZVdHzj3aQ5gZ6uzmCQNHzw38sCvw3d3IsLUvk8uwVtkpiGkXvzDeynrfDA(BnpcyW5gyEnfzB08Tcb(8Szp5nOWgMaYe4zDpiecewwhcZlgNkbFm8qiGjXvyQmgo1N398DYe4P9vSbxWaTIwhyJWlJZPk5bAkRtG5DppeMNrBTWqdo3aPBLwGtjynOZ7EEuMNrBTW(J3tWjdiyLy(9Z3g6531(Z7EEgT1cRvWpUJjLaOAtGJ1GoplwZZOTwy)X7j4KbeSsm)(5Bd987qGM398(749RvHHgCUbs3kTaNsWacPfLA(2MFhcNhXSKBGT5gZ6uzmCQNHzw3dcHaHL1HW8IXPsWhdpecysCfMkJHt95DppeMVtMapTVIn4cgOv06aBeEzCovjpqtzDcmV75z0wlS)49eCYacwjMF)8THE(DiCE3ZdH5z0wlm0GZnq6wPf4ucwd68UN3FhVFTkm0GZnq6wPf4ucgqiTOuZ328OIWSU5L4QSUhUfLkDRu4PSKBabZnM1PYy4updZSU5L4QSUhUfLkDRu4PSENuEqavIRY6iGaYjvY8o8495BhrgqM)CsaVbfAuBZ31arTnp0GZnqw3dcHaHL1fJtLGpgEieWK4kmvgdN6Z7EEimpJ2AHHgCUbs3kTaNsWAqN398OmpJ2AH9hVNGtgqWkX87NVn0ZVR9N398mARfwRGFChtkbq1MahRbDEwSMNrBTW(J3tWjdiyLy(9Z3g653HanplwZ7VJ3VwfgAW5giDR0cCkbdiKwuQ5H18SDE3ZZOTwy)X7j4KbeSsm)(5Bd987qW5rmlzjRFm8qiGjXv5gZnSl3ywNkJHt9mmZ6MxIRY6ac5bueNuQuROecK17KYdcOsCvwhbMHhcbmjUAEWjMexL19GqiqyzDZlHtkrfHmi18THEE2oV75rzEX4uj4ntGtGO2sk5aiXuzmCQpplwZ7VQRfcMCsGf4ucMkJHt95zXAEGwrRdSryMqIAl5pEhtLXWP(8iMLCdOMBmRtLXWPEgMzDZlXvzD4xlEuBjgUPKSUhecbclRdH57NGxGtjPf5Kayj87JABE3ZdH5z0wl8(GZJAlH08WJIWAqN398aTIMVn0ZZ2SU3rpNsIb2irLByxwYnW2CJzDQmgo1ZWmR7bHqGWY6mARfEFW5rTLqAE4rryazEzE3ZRGsCEsmWgjk8cCkr5DuGtZ3g65rDE3ZJY8mARfUtMaxL6AewjMF)8ONhbNNfR5HW8DYe4jR6Po5nhXs43h128SynpeM3FoPYkbxXgCjTmAEeZ6MxIRY6lWPeL3rboLLCdiyUXSovgdN6zyM1nVexL1pgEieWekR7bHqGWY6mARfEFW5rTLqAE4rryazEzEwSMhcZZOTwyqGKWAqN398kOeNNedSrIcd)AXJAlXWnLmFBONNTzDVJEoLedSrIk3WUSKBGD5gZ6uzmCQNHzw3dcHaHL1vqjopjgyJefEJB(W4jR70kpnFBONh15DppkZd0QWNGETiaUtRWhY8WA(DiCEwSMhOvewcKusUeQZ328B((8ioplwZJY8DIrBTWaRDpq4jSsm)(5H18SBEwSMVtmARfgyT7bcpHbeslk18WA(DSBEeZ6MxIRY6BCZhgpzDNw5PSKBO9ZnM1PYy4updZSUhecbclR7VQRfcMawp8Me1wIHFTM398mARfMawp8Me1wIHFTWkX87Nh98OoV75nVeoPeveYGuZJE(DzDZlXvz9f4ussjGypLLCdo4CJzDQmgo1ZWmR7bHqGWY6mARfgeijSg05DpVckX5jXaBKOWWVw8O2smCtjZ3g65rnRBEjUkRd)AXJAlXWnLKLCdia5gZ6uzmCQNHzw3dcHaHL1vqjopjgyJefEJB(W4jR70kpnFBONh1SU5L4QS(g38HXtw3PvEkl5gqGYnM1PYy4updZSU5L4QS(cCkjPeqSNY6EqieiSSoeMxmovc2CACR8WjmvgdN6Z7EEimpJ2AH3hCEuBjKMhEuewd68SynVyCQeS504w5HtyQmgo1N398qyEgT1cdcKewd68SynpJ2AHbbscRbDE3Zd0kclbskjxc15Bd98B(Ew37ONtjXaBKOYnSll5g2HWCJzDQmgo1ZWmR7bHqGWY6mARfgeijSg0SU5L4QSo8RfpQTed3uswYnSBxUXSovgdN6zyM1nVexL1pgEieWekR7D0ZPKyGnsu5g2LLSK1zovsc)(O2YnMByxUXSovgdN6zyM1nVexL1pgEieWekR7D0ZPKyGnsu5g2L19GqiqyzDGwf(e0RfbWDAf(qMVn0Z3(imR3jLheqL4QSombKjWN)wZRhvhyBNYM3b4LWjnVd8etIRYsUbuZnM1PYy4updZSUhecbclRlgNkbVzcCce1wsjhajMkJHt95zXAE)vDTqWKtcSaNsWuzmCQpplwZd0kADGncZesuBj)X7yQmgo1NNfR5nVeoPeveYGuZ3g65rDEwSMhcZlgNkbVzcCce1wsjhajMkJHt95DppeM3Fvxlem5KalWPemvgdN6Z7EEimpqRO1b2imtirTL8hVJPYy4uFE3Zd0QWNGETiW8WAE2IAw38sCvwhqipGI4KsLAfLqGSKBGT5gZ6uzmCQNHzw3dcHaHL1bAv4tqVweyEynpBrnRBEjUkR3jtGNSQN6K3Cml5gqWCJzDQmgo1ZWmR7bHqGWY6mARfgeijSg05DppkZd0QWNGETiaUtRWhY8WAE2XU5zXAEGwryjqsj5sSDEyHE(nFFEwSMxbL48KyGnsuy4xlEuBjgUPK5Bd98OopIZZI18aTk8jOxlcmpSMNTOM1nVexL1HFT4rTLy4MsYsUb2LBmRtLXWPEgMzDpiecewwNrBTW7dopQTesZdpkcRbDE3ZRGsCEsmWgjk8cCkr5DuGtZ3g65rDE3ZJY8qy(ozc8Kv9uN8MJyj87JABE3Z7pNuzLGRydUKwgnplwZdH59NtQSsWvSbxslJMhXSU5L4QS(cCkr5DuGtzj3q7NBmRtLXWPEgMzDpiecewwhOvHpb9AraCNwHpK5Bd98iicN398aTIWsGKsYLy78Tn)MVN1nVexL1HFGkDRuROecKLCdo4CJzDQmgo1ZWmR7bHqGWY6kOeNNedSrIcVaNsuEhf408THEEuN398OmpJ2AH7KjWvPUgHvI53pp65rW5zXAEimFNmbEYQEQtEZrSe(9rTnplwZdH59NtQSsWvSbxslJMhXSU5L4QS(cCkr5DuGtzj3acqUXSovgdN6zyM1nVexL1pgEieWekR7bHqGWY6aTk8jOxlcG70k8HmFBZJk7MNfR5bAfHLajLKlX25H18B(Ew37ONtjXaBKOYnSll5gqGYnM1PYy4updZSUhecbclRZOTwyqGKWAqZ6MxIRY6WVw8O2smCtjzj3WoeMBmRtLXWPEgMzDpiecewwhOvHpb9AraCNwHpK5BBE2HWSU5L4QSUb8wrj5aaQKSKLSoW8HXv5gZnSl3ywNkJHt9mmZ6MxIRY6m876PLgWXSENuEqavIRY6oqZhgFEhatWdjivw3dcHaHL1z0wlm0GZnq6wPf4ucwdAwYnGAUXSovgdN6zyM19GqiqyzDgT1cdn4CdKUvAboLG1GM1nVexL1ziGIa7JAll5gyBUXSovgdN6zyM19GqiqyzDuMhcZZOTwyObNBG0TslWPeSg05DpV5LWjLOIqgKA(2qppQZJ48SynpeMNrBTWqdo3aPBLwGtjynOZ7EEuMhOveUtRWhY8THEE2nV75bAv4tqVwea3Pv4dz(2qpF7JW5rmRBEjUkRBaVvucQgxrzj3acMBmRtLXWPEgMzDpiecewwNrBTWqdo3aPBLwGtjynOzDZlXvzDESbxuj2yQ13qsLKLCdSl3ywNkJHt9mmZ6EqieiSSoJ2AHHgCUbs3kTaNsWAqN398mARfMqc9ArGeqROulYGEfwdAw38sCvw3kpPeGXtEJZZsUH2p3ywNkJHt9mmZ6EqieiSSoJ2AHHgCUbs3kTaNsWacPfLAEyHEEeG5DppJ2AHjKqVweib0kk1ImOxH1GM1nVexL1xbGy431ZsUbhCUXSovgdN6zyM19GqiqyzDgT1cdn4CdKUvAboLG1GoV75nVeoPeveYGuZJE(DZ7EEuMNrBTWqdo3aPBLwGtjyaH0IsnpSMNDZ7EEX4ujy)X7j4KbemvgdN6ZZI18qyEX4ujy)X7j4KbemvgdN6Z7EEgT1cdn4CdKUvAboLGbeslk18WAE2opIzDZlXvzDgBlDRKac)EvwYswVtltJl5gZnSl3yw38sCvwhzu90cqu7szDQmgo1ZWml5gqn3ywNkJHt9mmZ6h0SUIKSU5L4QSUtdegdNY6onUgL1rzEQDQfqHsDCukpqtmgoLANAwjAitDYz4P5DpV)oE)Av4OuEGMymCk1o1Ss0qM6KZWtyazDhNhXSENuEqavIRY6iGaYjvY8kOKpwb1NxarTNe18muuBZRPO(8Tcb(8MMCinj8ZZJIuzDNgivgskRRGs(yfupjGO2tswYnW2CJzDQmgo1ZWmRFqZ6ksY6MxIRY6onqymCkR704Auw38s4Ksuridsnp653nV75rzEGf9e5KkbB9Uch18Tn)o2nplwZdH5bw0tKtQeS17kmX(qjQ5rmR70aPYqszDLKGYTQIAll5gqWCJzDQmgo1ZWmRFqZ6ksY6MxIRY6onqymCkR704Auw38s4KsuridsnFBONh15DppkZdH5bw0tKtQeS17kmX(qjQ5zXAEGf9e5KkbB9UctSpuIAE3ZJY8al6jYjvc26DfgqiTOuZ328SBEwSMFfBWLeGqArPMVT53HW5rCEeZ6onqQmKuw36DvcqiTOYsUb2LBmRtLXWPEgMzDZlXvzDaH8akItkvQvucbY6Ds5bbujUkR7aGcL748SjGtjZZMqojGRZJ0IsSOMNn7DC(gn(vQ5TQp)EIGoVdKqEafXjLAE2OOecmp448O2Y6EqieiSSU)QUwiyYjbwGtjZ7EEX4uj4ntGtGO2sk5aiXuzmCQpV75HW8IXPsWhdpecysCfMkJHt95DpV)oE)AvyObNBG0TslWPemGqArPYsUH2p3ywNkJHt9mmZ6MxIRY6WVw8O2smCtjzDpiecewwVFcEboLKwKtcGb0cqk4gdNM398OmVyCQeC4jVbftLXWP(8SynpeMNrBTWmaYe4PBLur1b22PmSg05DpVyCQemdGmbE6wjvuDGTDkdtLXWP(8SynVyCQe8XWdHaMexHPYy4uFE3Z7VJ3VwfgAW5giDR0cCkbdiKwuQ5DppeMNrBTW7dopQTesZdpkcRbDEeZ6Eh9CkjgyJevUHDzj3Gdo3ywNkJHt9mmZ6EqieiSSoJ2AHdVJjX4xPWacPfLAEyHE(nFFE3ZZOTw4W7ysm(vkSg05DpVckX5jXaBKOWBCZhgpzDNw5P5Bd98OoV75rzEimVyCQemdGmbE6wjvuDGTDkdtLXWP(8SynV)oE)Avygazc80TsQO6aB7uggqiTOuZ3287y38iM1nVexL134MpmEY6oTYtzj3acqUXSovgdN6zyM19GqiqyzDgT1chEhtIXVsHbeslk18Wc98B((8UNNrBTWH3XKy8RuynOZ7EEuMhcZlgNkbZaitGNUvsfvhyBNYWuzmCQpplwZ7VJ3VwfMbqMapDRKkQoW2oLHbeslk18Tn)o2npIzDZlXvz9f4ussjGypLLCdiq5gZ6uzmCQNHzwVtkpiGkXvzDhc)ofnVdWlXvZZdLmVCZd0QSU5L4QSU348K5L4QepuswNhkjvgskR7pNuzLOYsUHDim3ywNkJHt9mmZ6MxIRY6EJZtMxIRs8qjzDEOKuziPSoW8HXvzj3WUD5gZ6uzmCQNHzw38sCvw3BCEY8sCvIhkjRZdLKkdjL1fqu7jrLLCd7qn3ywNkJHt9mmZ6MxIRY6EJZtMxIRs8qjzDEOKuziPSU)oE)AvQSKByhBZnM1PYy4updZSUhecbclRlgNkb7pEpbNmGGPYy4uFE3ZZOTwy)X7j4KbeSsm)(5Bd987q48UNhL57eJ2AHbw7EGWtyLy(9ZJEE2nplwZdH57KjWt7RydUGbAfToWgHbw7EGWtZJ48SynpZPuZ7E(vSbxsacPfLAEyHE(nFpRBEjUkR7nopzEjUkXdLK15HssLHKY6(J3tWjdizj3Woem3ywNkJHt9mmZ6EqieiSSoJ2AHzaKjWt3kPIQdSTtzynOzDZlXvzDGwLmVexL4HsY68qjPYqszDMtLKWVpQTSKByh7YnM1PYy4updZSUhecbclRlgNkbZaitGNUvsfvhyBNYWuzmCQpV75rzE)D8(1QWmaYe4PBLur1b22PmmGqArPMhwZVdHZJ48UNhL5bw0tKtQeS17kCuZ328OYU5zXAEimpWIEICsLGTExHj2hkrnplwZ7VJ3VwfgAW5giDR0cCkbdiKwuQ5H187q48UNhyrproPsWwVRWe7dLOM398al6jYjvc26DfoQ5H187q48iM1nVexL1bAvY8sCvIhkjRZdLKkdjL1zovc6D8O2YsUHDTFUXSovgdN6zyM19GqiqyzDgT1cdn4CdKUvAboLG1GoV75fJtLGpgEieWK4kmvgdN6zDZlXvzDGwLmVexL4HsY68qjPYqsz9JHhcbmjUkl5g25GZnM1PYy4updZSUhecbclRlgNkbFm8qiGjXvyQmgo1N398(749RvHHgCUbs3kTaNsWacPfLAEyn)oeoV75rzENgimgoHvsck3QkQT5zXAEGf9e5KkbB9UctSpuIAE3ZdSONiNujyR3v4OMhwZVdHZZI18qyEGf9e5KkbB9UctSpuIAEeZ6MxIRY6aTkzEjUkXdLK15HssLHKY6hdpecysCvc6D8O2YsUHDia5gZ6uzmCQNHzw3dcHaHL1nVeoPeveYGuZ3g65rnRBEjUkRd0QK5L4QepuswNhkjvgskRBhLLCd7qGYnM1PYy4updZSU5L4QSU348K5L4QepuswNhkjvgskRReR6gONLSK1TJYnMByxUXSovgdN6zyM17KYdcOsCvw3bCSPZ7apXK4QSU5L4QSoGqEafXjLk1kkHazj3aQ5gZ6uzmCQNHzw3dcHaHL1fJtLGxGtjkVJcCctLXWPEw38sCvwFJB(W4jR70kpLLCdSn3ywNkJHt9mmZ6MxIRY6lWPKKsaXEkR7bHqGWY6(749RvHbeYdOioPuPwrjeadiKwuQ5Hf65rDE2W8B((8UNxmovcEZe4eiQTKsoasmvgdN6zDVJEoLedSrIk3WUSKBabZnM1PYy4updZSUhecbclRZOTwyqGKWAqZ6MxIRY6WVw8O2smCtjzj3a7YnM1PYy4updZSUhecbclR3jtGNSQN6K3CelHFFuBZ7EE)5KkReCfBWL0YO5DppJ2AH7KjWvPUgHvI53ppSMhbZ6MxIRY6hdpecycLLCdTFUXSovgdN6zyM19GqiqyzDgT1cVp48O2sinp8OimGmVmV75rzEimFNmbEYQEQtEZrSe(9rTnV759NtQSsWvSbxslJMNfR5HW8(Zjvwj4k2GlPLrZJyw38sCvwFboLO8okWPSKBWbNBmRtLXWPEgMzDpiecewwhOvHpb9AraCNwHpK5H18Om)o2npmMxmovcgOvHpzIqLMjXvyQmgo1NNnmpBNhXSU5L4QS(g38HXtw3PvEkl5gqaYnM1PYy4updZSU5L4QS(cCkjPeqSNY6EqieiSSoqRcFc61Ia4oTcFiZdR5rz(DSBEymVyCQemqRcFYeHkntIRWuzmCQppByE2opIzDVJEoLedSrIk3WUSKBabk3ywNkJHt9mmZ6EqieiSSoeMVtMapzvp1jV5iwc)(O2M398(Zjvwj4k2GlPLrZZI18qyE)5KkReCfBWL0YOSU5L4QS(cCkr5DuGtzj3WoeMBmRtLXWPEgMzDZlXvz9JHhcbmHY6EqieiSSoqRcFc61Ia4oTcFiZ328OmpQSBEymVyCQemqRcFYeHkntIRWuzmCQppByE2opIzDVJEoLedSrIk3WUSKBy3UCJzDZlXvz9nU5dJNSUtR8uwNkJHt9mmZsUHDOMBmRtLXWPEgMzDZlXvz9f4ussjGypL19o65usmWgjQCd7YsUHDSn3yw38sCvwh(bQ0TsTIsiqwNkJHt9mmZsUHDiyUXSU5L4QSUb8wrj5aaQKSovgdN6zyMLSK19NtQSsu5gZnSl3ywNkJHt9mmZ6MxIRY6DYe4QuxJY6Ds5bbujUkR7WZjvwjZ7aycEibPY6EqieiSSUtdegdNWkjbLBvf128SynVtdegdNWwVRsacPfvwYnGAUXSovgdN6zyM19GqiqyzDGwf(e0RfbWDAf(qMVT5z78UN3FhVFTkm0GZnq6wPf4ucgqiTOuZdR5z78UNhcZlgNkbZaitGNUvsfvhyBNYWuzmCQpV75DAGWy4ewjjOCRQO2Y6MxIRY6QwgazuBjKHsYsUb2MBmRtLXWPEgMzDpiecewwhcZlgNkbZaitGNUvsfvhyBNYWuzmCQpV75DAGWy4e26DvcqiTOY6MxIRY6QwgazuBjKHsYsUbem3ywNkJHt9mmZ6EqieiSSUyCQemdGmbE6wjvuDGTDkdtLXWP(8UNhL5z0wlmdGmbE6wjvuDGTDkdRbDE3ZJY8onqymCcRKeuUvvuBZ7EEGwf(e0RfbWDAf(qMVT5rqeoplwZ70aHXWjS17QeGqArnV75bAv4tqVwea3Pv4dz(2MV9r48SynVtdegdNWwVRsacPf18UNhyrproPsWwVRWacPfLAEynpc08ioplwZdH5z0wlmdGmbE6wjvuDGTDkdRbDE3Z7VJ3VwfMbqMapDRKkQoW2oLHbeslk18iM1nVexL1vTmaYO2sidLKLCdSl3ywNkJHt9mmZ6EqieiSSU)oE)AvyObNBG0TslWPemGqArPMhwZZ25DpVtdegdNWkjbLBvf128UNhL5fJtLGzaKjWt3kPIQdSTtzyQmgo1N398aTk8jOxlcG70k8HmpSMV9r48UN3FhVFTkmdGmbE6wjvuDGTDkddiKwuQ5H18OoplwZdH5fJtLGzaKjWt3kPIQdSTtzyQmgo1NhXSU5L4QSUXCiJYK4QepqYKLCdTFUXSovgdN6zyM19GqiqyzDNgimgoHTExLaeslQSU5L4QSUXCiJYK4QepqYKLCdo4CJzDQmgo1ZWmR7bHqGWY6(749RvHHgCUbs3kTaNsWacPfLAEynpBN398onqymCcRKeuUvvuBzDZlXvzDfCZVNtjboL0QwhqG7ywYnGaKBmRtLXWPEgMzDpieceww3PbcJHtyR3vjaH0IkRBEjUkRRGB(9CkjWPKw16acChZswY6qbK)qYysUXCd7YnM1PYy4updZS(bnRRijwzDpiecewwxarTNeSSdd3ujnfLy0wR5DppkZdH5fJtLGzaKjWt3kPIQdSTtzyQmgo1N398OmVaIApjyzh2FhVFTkCxdysC18oO593X7xRcdn4CdKUvAboLG7AatIRMh98iCEeNNfR5fJtLGzaKjWt3kPIQdSTtzyQmgo1N398OmV)oE)Avygazc80TsQO6aB7ugURbmjUAEh08ciQ9KGLDy)D8(1QWDnGjXvZJEEeopIZZI18IXPsWHN8gumvgdN6ZJywVtkpiGkXvzD2uNgxZesnVnVaIApjQ593X7xRY157HZOt95zCCEObNBG5V18lWPK5pW8maYe4ZFR5vr1b22PSMQ593X7xRcppBEnFinvZ704A08Wn181npGqAr1jW8as0a187CDEIRO5bKObQ5riMD4SUtdKkdjL1fqu7jjTlPCS8zDZlXvzDNgimgoL1DACnkrCfL1riMDzDNgxJY67YsUbuZnM1PYy4updZS(bnRRijwzDZlXvzDNgimgoL1DAGuziPSUaIApjjutkhlFw3dcHaHL1fqu7jblOIHBQKMIsmAR18UNhL5HW8IXPsWmaYe4PBLur1b22PmmvgdN6Z7EEuMxarTNeSGk2FhVFTkCxdysC18oO593X7xRcdn4CdKUvAboLG7AatIRMh98iCEeNNfR5fJtLGzaKjWt3kPIQdSTtzyQmgo1N398OmV)oE)Avygazc80TsQO6aB7ugURbmjUAEh08ciQ9KGfuX(749RvH7AatIRMh98iCEeNNfR5fJtLGdp5nOyQmgo1NhXSUtJRrjIROSocXSlR704AuwFxwYnW2CJzDQmgo1ZWmRFqZ6ksIvw3dcHaHL1HW8ciQ9KGLDy4MkPPOeJ2AnV75fqu7jblOIHBQKMIsmAR18SynVaIApjybvmCtL0uuIrBTM398OmpkZlGO2tcwqf7VJ3VwfURbmjUAEypVaIApjybvmJ2AL6AatIRMhX5zdZJY87WSBEymVaIApjybvmCtLy0wlSsauTjWNhX5zdZJY8onqymCclGO2tsc1KYXYppIZJ48TnpkZJY8ciQ9KGLDy)D8(1QWDnGjXvZd75fqu7jbl7WmARvQRbmjUAEeNNnmpkZVdZU5HX8ciQ9KGLDy4MkXOTwyLaOAtGppIZZgMhL5DAGWy4ewarTNK0UKYXYppIZJywVtkpiGkXvzD2uLeinHuZBZlGO2tIAENgxJMNXX59hsOgiQT5f408(749Rvn)TMxGtZlGO2tIRZ3dNrN6ZZ448cCA(UgWK4Q5V18cCAEgT1A(qMhk4CgDsHNVDKPM3MxjaQ2e4ZJ86XkiW8Yn)w4KM3MhESbNaZdfehiehNxU5vcGQnb(8ciQ9KOCDEtnFlIZN3uZBZJ86XkiW8RdmFSM3MxarTNK5BfC(8hy(wbNpFDY8khl)8Tcb(8(749RvPWzDNgivgskRlGO2tsckioqioM1nVexL1DAGWy4uw3PX1OeXvuwFxw3PX1OSoQzjlzD)D8(1Qu5gZnSl3ywNkJHt9mmZ6EqieiSSoJ2AHHgCUbs3kTaNsWAqZ6Ds5bbujUkRJaEsCvw38sCvwh6jXvzj3aQ5gZ6uzmCQNHzw38sCvwNqc9ArGeqROulYGEvwVtkpiGkXvzDhEhVFTkvw3dcHaHL1fJtLGpgEieWK4kmvgdN6Z7EEGwrZdR5B)5DppkZ70aHXWjSssq5wvrTnplwZ70aHXWjS17QeGqArnpIZ7EEuM3FhVFTkm0GZnq6wPf4ucgqiTOuZdR5z38SynpJ2AHHgCUbs3kTaNsWAqNhX5zXA(vSbxsacPfLAEynpQiml5gyBUXSovgdN6zyM19GqiqyzDX4ujygazc80TsQO6aB7ugMkJHt95DppqRcFc61Ia4oTcFiZ328SfHZ7EEGwryjqsj5sSB(2MFZ3N398OmpJ2AHzaKjWt3kPIQdSTtzynOZZI18RydUKaeslk18WAEur48iM1nVexL1jKqVweib0kk1ImOxLLCdiyUXSovgdN6zyM19GqiqyzDX4uj4WtEdkMkJHt95DppqRO5H18SnRBEjUkRtiHETiqcOvuQfzqVkl5gyxUXSovgdN6zyM19GqiqyzDX4ujygazc80TsQO6aB7ugMkJHt95DppkZ70aHXWjSssq5wvrTnplwZ70aHXWjS17QeGqArnpIZ7EEuM3FhVFTkmdGmbE6wjvuDGTDkddiKwuQ5zXAE)D8(1QWmaYe4PBLur1b22PmmGSUJZ7EEGwf(e0RfbWDAf(qMhwZZoeopIzDZlXvzDObNBG0TslWPKSKBO9ZnM1PYy4updZSUhecbclRlgNkbhEYBqXuzmCQpV75HW8mARfgAW5giDR0cCkbRbnRBEjUkRdn4CdKUvAboLKLCdo4CJzDQmgo1ZWmR7bHqGWY6IXPsWhdpecysCfMkJHt95DppkZ70aHXWjSssq5wvrTnplwZ70aHXWjS17QeGqArnpIZ7EEuMxmovcEZe4eiQTKsoasmvgdN6Z7EEgT1cdiKhqrCsPsTIsiawd68SynpeMxmovcEZe4eiQTKsoasmvgdN6ZJyw38sCvwhAW5giDR0cCkjl5gqaYnM1PYy4updZSUhecbclRZOTwyObNBG0TslWPeSg0SU5L4QSodGmbE6wjvuDGTDkll5gqGYnM1PYy4updZSUhecbclRBEjCsjQiKbPMh987M398mARfgAW5giDR0cCkbdiKwuQ5H18B((8UNNrBTWqdo3aPBLwGtjynOZ7EEimVyCQe8XWdHaMexHPYy4uFE3ZJY8qyEGf9e5KkbB9UctSpuIAEwSMhyrproPsWwVRWrnFBZZweopIZZI18RydUKaeslk18WAE2M1nVexL1xGtjTCeGuLwAahZsUHDim3ywNkJHt9mmZ6EqieiSSU5LWjLOIqgKA(2qppQZ7EEuMNrBTWqdo3aPBLwGtjynOZZI18al6jYjvc26DfoQ5BBE)D8(1QWqdo3aPBLwGtjyaH0IsnpIZ7EEuMNrBTWqdo3aPBLwGtjyaH0IsnpSMFZ3NNfR5bw0tKtQeS17kmGqArPMhwZV57ZJyw38sCvwFboL0YrasvAPbCml5g2Tl3ywNkJHt9mmZ6EqieiSSUyCQe8XWdHaMexHPYy4uFE3ZZOTwyObNBG0TslWPeSg05DppkZJY8mARfgAW5giDR0cCkbdiKwuQ5H18B((8SynpJ2AH1k4h3XKsauTjWXAqN398mARfwRGFChtkbq1MahdiKwuQ5H18B((8ioV75rz(oXOTwyG1Uhi8ewjMF)8ONNDZZI18qy(ozc80(k2GlyGwrRdSryG1Uhi808iopIzDZlXvz9f4uslhbivPLgWXSKByhQ5gZ6uzmCQNHzw3dcHaHL1fJtLGzaKjWt3kPIQdSTtzyQmgo1N398aTk8jOxlcG70k8HmFBZJGiCE3Zd0kAEyHEE2oV75rzEgT1cZaitGNUvsfvhyBNYWAqNNfR593X7xRcZaitGNUvsfvhyBNYWacPfLA(2Mhbr48ioplwZdH5fJtLGzaKjWt3kPIQdSTtzyQmgo1N398aTk8jOxlcG70k8HmFBONhv2L1nVexL1H7i0tGtaKHpbfqkQ8uwYnSJT5gZ6uzmCQNHzw3dcHaHL1z0wlm0GZnq6wPf4ucwdAw38sCvwhyHIsDY6zj3Woem3ywNkJHt9mmZ6EqieiSSU5LWjLOIqgKA(2qppQZ7EEuMN5uQ5Dp)k2GljaH0IsnpSMNTZZI18qyEgT1cZaitGNUvsfvhyBNYWAqN398OmpusWBWpnogqiTOuZdR53895zXAEGf9e5KkbB9UcdiKwuQ5H18SDE3ZdSONiNujyR3v4OMVT5HscEd(PXXacPfLAEeNhXSU5L4QSUY8Gyf(W4jOMxYsUHDSl3ywNkJHt9mmZ6EqieiSSU5LWjLOIqgKA(2MNDZZI18aTIwhyJWqHtg4qEfPWuzmCQN1nVexL17KjWtw1tDYBoMLSK1fqu7jrLBm3WUCJzDQmgo1ZWmRBEjUkRhLYd0eJHtP2PMvIgYuNCgEkR3jLheqL4QSEJGO2tIkR7bHqGWY6mARfgAW5giDR0cCkbRbDEwSMxmWgjyjqsj5sq9scveopSMNDZZI18mNsnV75xXgCjbiKwuQ5H18OUll5gqn3ywNkJHt9mmZ6MxIRY6ciQ9KSlR3jLheqL4QSEJWP5fqu7jz(wHaFEbonp8ydoPK5jLeinH6Z704AKRZ3k485zO51uuF(vauY8w1NhQfaQpFRqGppcyW5gy(BnpBc4ucoR7bHqGWY6qyENgimgoHvqjFScQNequ7jzE3ZZOTwyObNBG0TslWPeSg05DppkZdH5fJtLGdp5nOyQmgo1NNfR5fJtLGdp5nOyQmgo1N398mARfgAW5giDR0cCkbdiKwuQ5Bd987q48ioV75rzEimVaIApjybvmCtL83X7xRAEwSMxarTNeSGk2FhVFTkmGqArPMNfR5DAGWy4ewarTNKeuqCGqCCE0ZVBEeNNfR5fqu7jbl7WmARvQRbmjUA(2qp)k2GljaH0IsLLCdSn3ywNkJHt9mmZ6EqieiSSoeM3PbcJHtyfuYhRG6jbe1EsM398mARfgAW5giDR0cCkbRbDE3ZJY8qyEX4uj4WtEdkMkJHt95zXAEX4uj4WtEdkMkJHt95DppJ2AHHgCUbs3kTaNsWacPfLA(2qp)oeopIZ7EEuMhcZlGO2tcw2HHBQK)oE)AvZZI18ciQ9KGLDy)D8(1QWacPfLAEwSM3PbcJHtybe1EssqbXbcXX5rppQZJ48SynVaIApjybvmJ2AL6AatIRMVn0ZVIn4scqiTOuzDZlXvzDbe1Esqnl5gqWCJzDQmgo1ZWmRBEjUkRlGO2tYUSENuEqavIRY6S518xXDC(RO5VAEnfnVaIApjZdfCoJoPM3MNrBTCDEnfnVaNM)e4ey(RM3FhVFTk88iWG5J18ffcCcmVaIApjZdfCoJoPM3MNrBTCDEnfnpZjWN)Q593X7xRcN19GqiqyzDimVaIApjyzhgUPsAkkXOTwZ7EEuMxarTNeSGk2FhVFTkmGqArPMNfR5HW8ciQ9KGfuXWnvstrjgT1AEeNNfR593X7xRcdn4CdKUvAboLGbeslk18TnpQiml5gyxUXSovgdN6zyM19GqiqyzDimVaIApjybvmCtL0uuIrBTM398OmVaIApjyzh2FhVFTkmGqArPMNfR5HW8ciQ9KGLDy4MkPPOeJ2AnpIZZI18(749RvHHgCUbs3kTaNsWacPfLA(2MhveM1nVexL1fqu7jb1SKLSoZPsqVJh1wUXCd7YnM1PYy4updZSU5L4QSo8RfpQTed3uswVtkpiGkXvzDycitGp)TMxpQoW2oLnp074rTnp4etIRM3fZRediQ53Hq18m06a08W80NpuZBoTGBmCkR7bHqGWY6mARfgeijSg0SKBa1CJzDQmgo1ZWmR7bHqGWY6MxcNuIkczqQ5Bd98OoplwZd0kclbskjxIDZdl0ZV57Z7EEuMxmovcEZe4eiQTKsoasmvgdN6ZZI18(R6AHGjNeyboLGPYy4uFEwSMhOv06aBeMjKO2s(J3XuzmCQppIzDZlXvzDaH8akItkvQvucbYsUb2MBmRtLXWPEgMzDZlXvz9JHhcbmHY6Eh9CkjgyJevUHDzDpiecewwhOvHpb9AraCNwHpK5Bd98OYUSENuEqavIRY6nfdSrskwOrAS3fO0jgT1cdS29aHNWkX87HXoeDqO0jgT1cdS29aHNWacPfLcg7qKn0jtGN2xXgCbd0kADGncdS29aHNAoVdKGsMOM3MNFIRZlWd18HA(OeQ6uFE5MxmWgjZlWP5HhBWjLmpuqCGqCCEQiKooFRqGpVvZBmbpehNxGBY8TcoFEdkuUJZdS29aHNMpwZd0kADGnQJNVr4Mmpdf128wnpveshNVviWNhHZReZVx568hyERMNkcPJZlWnzEbonFNy0wR5BfC(8Q7Q5j2dna08xHZsUbem3ywNkJHt9mmZ6EqieiSSoqRcFc61Ia4oTcFiZdR5rfHZ7EEfuIZtIb2irH34MpmEY6oTYtZ3g65rDE3Z7VJ3VwfgAW5giDR0cCkbdiKwuQ5BBE2L1nVexL134MpmEY6oTYtzj3a7YnM1PYy4updZSU5L4QS(cCkjPeqSNY6EqieiSSoqRcFc61Ia4oTcFiZdR5rfHZ7EE)D8(1QWqdo3aPBLwGtjyaH0IsnFBZZUSU3rpNsIb2irLByxwYn0(5gZ6uzmCQNHzw3dcHaHL1z0wl8(GZJAlH08WJIWaY8Y8UNhOvHpb9AraCNwHpK5BBEuMFh7MhgZlgNkbd0QWNmrOsZK4kmvgdN6ZZgMNTZJ48UNxbL48KyGnsu4f4uIY7OaNMVn0ZJ68UNhL5z0wlCNmbUk11iSsm)(5rppcoplwZdH57KjWtw1tDYBoILWVpQT5zXAEimV)CsLvcUIn4sAz08iM1nVexL1xGtjkVJcCkl5gCW5gZ6uzmCQNHzw3dcHaHL1bAv4tqVwea3Pv4dz(2qppkZZw2npmMxmovcgOvHpzIqLMjXvyQmgo1NNnmpBNhX5DpVckX5jXaBKOWlWPeL3rbonFBONh15DppkZZOTw4ozcCvQRryLy(9ZJEEeCEwSMhcZ3jtGNSQN6K3CelHFFuBZZI18qyE)5KkReCfBWL0YO5rmRBEjUkRVaNsuEhf4uwYnGaKBmRtLXWPEgMzDpieceww3FhVFTkm0GZnq6wPf4ucgqiTOuZ328aTIWsGKsYLqW5DppqRcFc61Ia4oTcFiZdR5rqeoV75vqjopjgyJefEJB(W4jR70kpnFBONh1SU5L4QS(g38HXtw3PvEkl5gqGYnM1PYy4updZSU5L4QS(cCkjPeqSNY6EqieiSSU)oE)AvyObNBG0TslWPemGqArPMVT5bAfHLajLKlHGZ7EEGwf(e0RfbWDAf(qMhwZJGimR7D0ZPKyGnsu5g2LLSK1vIvDd0ZnMByxUXSovgdN6zyM1nVexL1beYdOioPuPwrjeiR3jLheqL4QSUUyv3a95vrTXj24Ib2izEWjMexL19GqiqyzDX4uj4ntGtGO2sk5aiXuzmCQpplwZ7VQRfcMCsGf4ucMkJHt95zXAEGwrRdSryMqIAl5pEhtLXWPEwYnGAUXSovgdN6zyM19GqiqyzDimFNmbEAFfBWfmqRO1b2imWA3deEAE3ZJY8DIrBTWaRDpq4jSsm)(5H18SBEwSMVtmARfgyT7bcpHbeslk18WAEh88iM1nVexL134MpmEY6oTYtzj3aBZnM1PYy4updZSUhecbclR7VJ3VwfgqipGI4KsLAfLqamGqArPMhwONh15zdZV57Z7EEX4uj4ntGtGO2sk5aiXuzmCQN1nVexL1xGtjjLaI9uwYnGG5gZ6uzmCQNHzw3dcHaHL19x11cbtaRhEtIAlXWVwZ7EEgT1ctaRhEtIAlXWVwyLy(9ZJEEuNNfR59x11cbRvCYuWPEAbOQDDetLXWP(8UNNrBTWAfNmfCQNwaQAxhXacPfLAEynpBN398mARfwR4KPGt90cqv76iwdAw38sCvwFboLKuci2tzj3a7YnM1PYy4updZSUhecbclRZOTwyqGKWAqZ6MxIRY6WVw8O2smCtjzj3q7NBmRtLXWPEgMzDpiecewwhcZZOTw4f4AxQsq14kcRbDE3ZlgNkbVax7svcQgxryQmgo1NNfR5z0wl8(GZJAlH08WJIWaY8Y8SynFNmbEYQEQtEZrSe(9rTnV759NtQSsWvSbxslJM398mARfUtMaxL6AewjMF)8WAEeCEwSMhOvewcKusUecopSqp)MVN1nVexL1pgEieWekl5gCW5gZ6uzmCQNHzw3dcHaHL1bAv4tqVwea3Pv4dzEynpkZVJDZdJ5fJtLGbAv4tMiuPzsCfMkJHt95zdZZ25rmRBEjUkRVaNsskbe7PSKBabi3ywNkJHt9mmZ6EqieiSSoqRcFc61Ia4oTcFiZ328OmpQSBEymVyCQemqRcFYeHkntIRWuzmCQppByE2opIzDZlXvz9JHhcbmHYsUbeOCJzDZlXvz9f4ussjGypL1PYy4updZSKByhcZnM1nVexL1HFGkDRuROecK1PYy4updZSKBy3UCJzDZlXvzDd4TIsYbaujzDQmgo1ZWmlzjlzDNeqfxLBaveI6oe2(O6GZ6Tmqf1MkRZg5aCGnWMBODWfZpFJWP5dKqpGm)6aZ38y4HqatIRsqVJh1wZ5bu7ulauFE1HKM30KdPjuFEpCR2ifEG0LrrZVZfZ7WRCsaH6Z3umovcgInNxU5BkgNkbdrmvgdN6nNhLDShr8aPlJIMFNlM3Hx5Kac1NVjqRO1b2imeBoVCZ3eOv06aBegIyQmgo1Bopk7ypI4bsxgfn)oxmVdVYjbeQpFt)vDTqWqS58YnFt)vDTqWqetLXWPEZ5rzh7repqoqYg5aCGnWMBODWfZpFJWP5dKqpGm)6aZ30F8EcozaP58aQDQfaQpV6qsZBAYH0eQpVhUvBKcpq6YOO535I5D4vojGq95BkgNkbdXMZl38nfJtLGHiMkJHt9MZJYo2JiEG0LrrZJQlM3Hx5Kac1NVPyCQemeBoVCZ3umovcgIyQmgo1Bopk7ypI4bsxgfnpBDX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5rzh7repq6YOO5rqxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEu2XEeXdKdKSroahydS5gAhCX8Z3iCA(aj0diZVoW8npgEieWK4QMZdO2PwaO(8QdjnVPjhstO(8E4wTrk8aPlJIMFNlM3Hx5Kac1NVPyCQemeBoVCZ3umovcgIyQmgo1Bopk7ypI4bsxgfn)oxmVdVYjbeQpFtGwrRdSryi2CE5MVjqRO1b2imeXuzmCQ3CEu2XEeXdKUmkA(DUyEhELtciuF(M(R6AHGHyZ5LB(M(R6AHGHiMkJHt9MZJYo2JiEG0LrrZJa5I5D4vojGq95BkgNkbdXMZl38nfJtLGHiMkJHt9MZJcQShr8a5ajBKdWb2aBUH2bxm)8ncNMpqc9aY8RdmFtMtLKWVpQTMZdO2PwaO(8QdjnVPjhstO(8E4wTrk8aPlJIMhvxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEuqL9iIhiDzu08O6I5D4vojGq95Bc0kADGncdXMZl38nbAfToWgHHiMkJHt9MZJcQShr8aPlJIMhvxmVdVYjbeQpFt)vDTqWqS58YnFt)vDTqWqetLXWPEZ5rbv2JiEGCGKnYb4aBGn3q7GlMF(gHtZhiHEaz(1bMVP)CsLvIQ58aQDQfaQpV6qsZBAYH0eQpVhUvBKcpq6YOO5r1fZ7WRCsaH6Z3umovcgInNxU5BkgNkbdrmvgdN6nNhLDShr8aPlJIMNTUyEhELtciuF(MIXPsWqS58YnFtX4ujyiIPYy4uV58OSJ9iIhiDzu08iOlM3Hx5Kac1NVPyCQemeBoVCZ3umovcgIyQmgo1Bopk7ypI4bsxgfnp7CX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5rbv2JiEGCGKnYb4aBGn3q7GlMF(gHtZhiHEaz(1bMVPsSQBGEZ5bu7ulauFE1HKM30KdPjuFEpCR2ifEG0LrrZVZfZ7WRCsaH6Z3umovcgInNxU5BkgNkbdrmvgdN6nNhLDShr8aPlJIMFNlM3Hx5Kac1NVjqRO1b2imeBoVCZ3eOv06aBegIyQmgo1BoVjZZMIa7Y5rzh7repq6YOO535I5D4vojGq95B6VQRfcgInNxU5B6VQRfcgIyQmgo1Bopk7ypI4bsxgfnpBDX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5nzE2ueyxopk7ypI4bsxgfnpc6I5D4vojGq95B6VQRfcgInNxU5B6VQRfcgIyQmgo1Bopk7ypI4bsxgfnF77I5D4vojGq95BkgNkbdXMZl38nfJtLGHiMkJHt9MZJYo2JiEG0LrrZ7GDX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5rzh7repq6YOO5raCX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5rzh7repqoqYg5aCGnWMBODWfZpFJWP5dKqpGm)6aZ3K5ujO3XJAR58aQDQfaQpV6qsZBAYH0eQpVhUvBKcpq6YOO5r1fZ7WRCsaH6Z3umovcgInNxU5BkgNkbdrmvgdN6nNhLDShr8aPlJIMhvxmVdVYjbeQpFtGwrRdSryi2CE5MVjqRO1b2imeXuzmCQ3CEu2XEeXdKUmkAEuDX8o8kNeqO(8n9x11cbdXMZl38n9x11cbdrmvgdN6nNhLDShr8aPlJIMV9DX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5rzh7repq6YOO5DWUyEhELtciuF(MIXPsWqS58YnFtX4ujyiIPYy4uV58OSJ9iIhihizJCaoWgyZn0o4I5NVr408bsOhqMFDG5Bcfq(djJjnNhqTtTaq95vhsAEttoKMq959WTAJu4bsxgfn)oxmVdVYjbeQpVEG0HZRCSeJ9Z7GCqZl38UuZMh5114AQ5pOeWKdmpkoieNhfuzpI4bsxgfn)oxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEuyl7repq6YOO535I5D4vojGq95BkGO2tcEhgInNxU5BkGO2tcw2HHyZ5rHTShr8aPlJIMhvxmVdVYjbeQpVEG0HZRCSeJ9Z7GCqZl38UuZMh5114AQ5pOeWKdmpkoieNhfuzpI4bsxgfnpQUyEhELtciuF(MIXPsWqS58YnFtX4ujyiIPYy4uV58OWw2JiEG0LrrZJQlM3Hx5Kac1NVPaIApjyuXqS58YnFtbe1EsWcQyi2CEuyl7repq6YOO5zRlM3Hx5Kac1Nxpq6W5vowIX(5DqZl38UuZMVhodvC18hucyYbMhfyJ48OGk7repq6YOO5zRlM3Hx5Kac1NVPaIApj4Dyi2CE5MVPaIApjyzhgInNhfeK9iIhiDzu08S1fZ7WRCsaH6Z3uarTNemQyi2CE5MVPaIApjybvmeBopkSJ9iIhihizJCaoWgyZn0o4I5NVr408bsOhqMFDG5B6VJ3VwLQ58aQDQfaQpV6qsZBAYH0eQpVhUvBKcpq6YOO5r1fZ7WRCsaH6Z3umovcgInNxU5BkgNkbdrmvgdN6nNhLDShr8aPlJIMNTUyEhELtciuF(MIXPsWqS58YnFtX4ujyiIPYy4uV58OSJ9iIhiDzu08iOlM3Hx5Kac1NVPyCQemeBoVCZ3umovcgIyQmgo1Bopk7ypI4bsxgfnp7CX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5rzh7repq6YOO5BFxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEu2XEeXdKUmkAEhSlM3Hx5Kac1NVPyCQemeBoVCZ3umovcgIyQmgo1Bopk7ypI4bsxgfnpcKlM3Hx5Kac1NVPyCQemeBoVCZ3umovcgIyQmgo1Bopk7ypI4bsxgfn)UDUyEhELtciuF(MIXPsWqS58YnFtX4ujyiIPYy4uV58OSJ9iIhiDzu087q1fZ7WRCsaH6Z3umovcgInNxU5BkgNkbdrmvgdN6nNhfuzpI4bsxgfn)o25I5D4vojGq95Bc0kADGncdXMZl38nbAfToWgHHiMkJHt9MZBY8SPiWUCEu2XEeXdKdKSroahydS5gAhCX8Z3iCA(aj0diZVoW8nfqu7jr1CEa1o1ca1NxDiP5nn5qAc1N3d3QnsHhiDzu08O6I5D4vojGq95BkgNkbdXMZl38nfJtLGHiMkJHt9MZJcQShr8aPlJIMhvxmVdVYjbeQpFtbe1EsW7WqS58YnFtbe1EsWYomeBopk7ypI4bsxgfnpQUyEhELtciuF(MciQ9KGrfdXMZl38nfqu7jblOIHyZ5rbv2JiEG0LrrZZwxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEuqL9iIhiDzu08S1fZ7WRCsaH6Z3uarTNe8omeBoVCZ3uarTNeSSddXMZJcQShr8aPlJIMNTUyEhELtciuF(MciQ9KGrfdXMZl38nfqu7jblOIHyZ5rzh7repq6YOO5rqxmVdVYjbeQpFtbe1EsW7WqS58YnFtbe1EsWYomeBopk7ypI4bsxgfnpc6I5D4vojGq95BkGO2tcgvmeBoVCZ3uarTNeSGkgInNhfuzpI4bsxgfnp7CX8o8kNeqO(8nfqu7jbVddXMZl38nfqu7jbl7WqS58OGk7repq6YOO5zNlM3Hx5Kac1NVPaIApjyuXqS58YnFtbe1EsWcQyi2CEu2XEeXdKdKSroahydS5gAhCX8Z3iCA(aj0diZVoW8n70Y04sZ5bu7ulauFE1HKM30KdPjuFEpCR2ifEG0LrrZZoxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEuqL9iIhiDzu08TVlM3Hx5Kac1NVPyCQemeBoVCZ3umovcgIyQmgo1BopkSL9iIhiDzu08oyxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEu2XEeXdKUmkAEeaxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEu2XEeXdKUmkA(DS1fZ7WRCsaH6Z3umovcgInNxU5BkgNkbdrmvgdN6nNhLDShr8aPlJIMFh7CX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5rzh7repq6YOO531(UyEhELtciuF(MIXPsWqS58YnFtX4ujyiIPYy4uV58MmpBkcSlNhLDShr8aPlJIMFNd2fZ7WRCsaH6Z3umovcgInNxU5BkgNkbdrmvgdN6nNhLDShr8a5ajBKdWb2aBUH2bxm)8ncNMpqc9aY8RdmFt7OMZdO2PwaO(8QdjnVPjhstO(8E4wTrk8aPlJIMhvxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEtMNnfb2LZJYo2JiEG0LrrZZwxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEtMNnfb2LZJYo2JiEG0LrrZ7GDX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5rzh7repq6YOO5raCX8o8kNeqO(8nfJtLGHyZ5LB(MIXPsWqetLXWPEZ5rzh7repq6YOO53HqxmVdVYjbeQpFtX4ujyi2CE5MVPyCQemeXuzmCQ3CEu2XEeXdKdKncNMVPMIsHqivnN38sC18Tm181jZVoTQpFuZlWd18bsOhqWdKSzKqpGq953X25nVexnppuIcpqM1HcUvWPSE71EZ3oMmb(8SXwXgCzE2eWPKbY2R9MhsTIMhveaxNhveI6UbYbY2R9M3HWTAJudKTx7npB85DGeYZj1NNBkHnUI8x1NxtzB083AEhc3Isn)TMNn7P5n18HmF)iv1uMhk3CC(weNpFuZdfyEj8eEGCGS9MNn1PX1mHuZBZlGO2tIAE)D8(1QCD(E4m6uFEghNhAW5gy(Bn)cCkz(dmpdGmb(83AEvuDGTDkRPAE)D8(1QWZZMxZhst18onUgnpCtnFDZdiKwuDcmpGenqn)oxNN4kAEajAGAEeIzhEG08sCLcdfq(djJjWanSDAGWy4KRLHKqlGO2tsAxs5y5D9GIwrsSC1PX1i07C1PX1OeXveAeIzNR(R6HexHwarTNe8omCtL0uuIrBTCJceeJtLGzaKjWt3kPIQdSTtzUrrarTNe8oS)oE)Av4UgWK4khKdYFhVFTkm0GZnq6wPf4ucURbmjUcncrKflX4ujygazc80TsQO6aB7uMBu83X7xRcZaitGNUvsfvhyBNYWDnGjXvoihKaIApj4Dy)D8(1QWDnGjXvOriISyjgNkbhEYBqrCG08sCLcdfq(djJjWanSDAGWy4KRLHKqlGO2tsc1KYXY76bfTIKy5QtJRrO35QtJRrjIRi0ieZox9x1djUcTaIApjyuXWnvstrjgT1YnkqqmovcMbqMapDRKkQoW2oL5gfbe1EsWOI93X7xRc31aMex5GCq(749RvHHgCUbs3kTaNsWDnGjXvOriISyjgNkbZaitGNUvsfvhyBNYCJI)oE)Avygazc80TsQO6aB7ugURbmjUYb5Gequ7jbJk2FhVFTkCxdysCfAeIilwIXPsWHN8guehiBV5ztvsG0esnVnVaIApjQ5DACnAEghN3FiHAGO2MxGtZ7VJ3Vw183AEbonVaIApjUoFpCgDQppJJZlWP57AatIRM)wZlWP5z0wR5dzEOGZz0jfE(2rMAEBELaOAtGppYRhRGaZl38BHtAEBE4XgCcmpuqCGqCCE5MxjaQ2e4ZlGO2tIY15n18TioFEtnVnpYRhRGaZVoW8XAEBEbe1EsMVvW5ZFG5BfC(81jZRCS8Z3ke4Z7VJ3VwLcpqAEjUsHHci)HKXeyGg2onqymCY1YqsOfqu7jjbfehiehD9GIwrsSC1PX1i0O6QtJRrjIRi07C1FvpK4k0qqarTNe8omCtL0uuIrBTClGO2tcgvmCtL0uuIrBTyXsarTNemQy4MkPPOeJ2A5gfuequ7jbJk2FhVFTkCxdysCLdsarTNemQygT1k11aMexHiBaLDy2bdbe1EsWOIHBQeJ2AHvcGQnboISbuCAGWy4ewarTNKeQjLJLhreBdfuequ7jbVd7VJ3VwfURbmjUYbjGO2tcEhMrBTsDnGjXviYgqzhMDWqarTNe8omCtLy0wlSsauTjWrKnGItdegdNWciQ9KK2LuowEerCGCGCGS9AV5ztzp51eQpp5KaooVeiP5f408MxoW8HAEZPfCJHt4bsZlXvk0iJQNwaIAxAGS9MhbeqoPsMxbL8XkO(8ciQ9KOMNHIABEnf1NVviWN30KdPjHFEEuKAG08sCLcgOHTtdegdNCTmKeAfuYhRG6jbe1EsC1PX1i0OqTtTakuQJJs5bAIXWPu7uZkrdzQtodp52FhVFTkCukpqtmgoLANAwjAitDYz4jmGSUJioqAEjUsbd0W2PbcJHtUwgscTssq5wvrT5QtJRrOnVeoPeveYGuO35gfGf9e5KkbB9UchvB7yhlwqayrproPsWwVRWe7dLOqCG08sCLcgOHTtdegdNCTmKeAR3vjaH0IYvNgxJqBEjCsjQiKbPAdnQUrbcal6jYjvc26DfMyFOeflwal6jYjvc26DfMyFOeLBuaw0tKtQeS17kmGqArPAJDSyTIn4scqiTOuTTdHiI4az7nVdakuUJZZMaoLmpBc5KaUopslkXIAE2S3X5B04xPM3Q(87jc68oqc5bueNuQ5zJIsiW8GJZJABG08sCLcgOHnGqEafXjLk1kkHaUgl0(R6AHGjNeyboL4wmovcEZe4eiQTKsoas3qqmovc(y4HqatIRC7VJ3VwfgAW5giDR0cCkbdiKwuQbsZlXvkyGg2WVw8O2smCtjU6D0ZPKyGnsuO35ASq3pbVaNsslYjbWaAbifCJHtUrrmovco8K3GYIfey0wlmdGmbE6wjvuDGTDkdRb1TyCQemdGmbE6wjvuDGTDkJflX4uj4JHhcbmjUYT)oE)AvyObNBG0TslWPemGqArPCdbgT1cVp48O2sinp8OiSguehinVexPGbAyVXnFy8K1DALNCnwOz0wlC4Dmjg)kfgqiTOuWc9MV7MrBTWH3XKy8RuynOUvqjopjgyJefEJB(W4jR70kp1gAuDJceeJtLGzaKjWt3kPIQdSTtzSy5VJ3VwfMbqMapDRKkQoW2oLHbeslkvB7yhIdKMxIRuWanSxGtjjLaI9KRXcnJ2AHdVJjX4xPWacPfLcwO38D3mARfo8oMeJFLcRb1nkqqmovcMbqMapDRKkQoW2oLXIL)oE)Avygazc80TsQO6aB7uggqiTOuTTJDioq2EZ7q43PO5DaEjUAEEOK5LBEGwnqAEjUsbd0W2BCEY8sCvIhkX1YqsO9NtQSsudKMxIRuWanS9gNNmVexL4HsCTmKeAG5dJRginVexPGbAy7nopzEjUkXdL4Azij0ciQ9KOginVexPGbAy7nopzEjUkXdL4Azij0(749RvPginVexPGbAy7nopzEjUkXdL4Azij0(J3tWjdiUgl0IXPsW(J3tWjdiUz0wlS)49eCYacwjMFFBO3Hq3O0jgT1cdS29aHNWkX87rZowSGqNmbEAFfBWfmqRO1b2imWA3deEcrwSyoLY9k2GljaH0Isbl0B((aP5L4kfmqdBGwLmVexL4HsCTmKeAMtLKWVpQnxJfAgT1cZaitGNUvsfvhyBNYWAqhinVexPGbAyd0QK5L4QepuIRLHKqZCQe074rT5ASqlgNkbZaitGNUvsfvhyBNYCJI)oE)Avygazc80TsQO6aB7uggqiTOuWAhcr0nkal6jYjvc26DfoQ2qLDSybbGf9e5KkbB9UctSpuIIfl)D8(1QWqdo3aPBLwGtjyaH0IsbRDi0nWIEICsLGTExHj2hkr5gyrproPsWwVRWrbRDieXbsZlXvkyGg2aTkzEjUkXdL4Azij0hdpecysCLRXcnJ2AHHgCUbs3kTaNsWAqDlgNkbFm8qiGjXvdKMxIRuWanSbAvY8sCvIhkX1YqsOpgEieWK4Qe074rT5ASqlgNkbFm8qiGjXvU93X7xRcdn4CdKUvAboLGbeslkfS2Hq3O40aHXWjSssq5wvrTXIfWIEICsLGTExHj2hkr5gyrproPsWwVRWrbRDiKfliaSONiNujyR3vyI9HsuioqAEjUsbd0WgOvjZlXvjEOexldjH2oY1yH28s4Ksurids1gAuhinVexPGbAy7nopzEjUkXdL4Azij0kXQUb6dKdKT38oGJnDEh4jMexnqAEjUsHTJqdiKhqrCsPsTIsiWaP5L4kf2ocgOH9g38HXtw3PvEY1yHwmovcEboLO8okWPbsZlXvkSDemqd7f4ussjGyp5Q3rpNsIb2irHENRXcT)oE)AvyaH8akItkvQvucbWacPfLcwOrLnS57UfJtLG3mbobIAlPKdGCG08sCLcBhbd0Wg(1Ih1wIHBkX1yHMrBTWGajH1GoqAEjUsHTJGbAyFm8qiGjKRXcDNmbEYQEQtEZrSe(9rT52FoPYkbxXgCjTmYnJ2AH7KjWvPUgHvI53dleCG08sCLcBhbd0WEboLO8okWjxJfAgT1cVp48O2sinp8OimGmV4gfi0jtGNSQN6K3CelHFFuBU9NtQSsWvSbxslJyXcc(Zjvwj4k2GlPLrioqAEjUsHTJGbAyVXnFy8K1DALNCnwObAv4tqVwea3Pv4dbwOSJDWqmovcgOvHpzIqLMjXvSb2I4aP5L4kf2ocgOH9cCkjPeqSNC17ONtjXaBKOqVZ1yHgOvHpb9AraCNwHpeyHYo2bdX4ujyGwf(KjcvAMexXgylIdKMxIRuy7iyGg2lWPeL3rbo5ASqdHozc8Kv9uN8MJyj87JAZT)CsLvcUIn4sAzelwqWFoPYkbxXgCjTmAG08sCLcBhbd0W(y4Hqatix9o65usmWgjk07CnwObAv4tqVwea3Pv4dPnuqLDWqmovcgOvHpzIqLMjXvSb2I4aP5L4kf2ocgOH9g38HXtw3PvEAG08sCLcBhbd0WEboLKuci2tU6D0ZPKyGnsuO3nqAEjUsHTJGbAyd)av6wPwrjeyG08sCLcBhbd0W2aEROKCaavYa5az7npmbKjWN)wZRhvhyBNYMh6D8O2MhCIjXvZ7I5vIbe187qOAEgADaAEyE6ZhQ5nNwWngonqAEjUsHzovc6D8O2qd)AXJAlXWnL4ASqZOTwyqGKWAqhinVexPWmNkb9oEuBWanSbeYdOioPuPwrjeW1yH28s4Ksurids1gAuzXcOvewcKusUe7Gf6nF3nkIXPsWBMaNarTLuYbqYIL)QUwiyYjbwGtjSyb0kADGncZesuBj)X7ioq2EZ3umWgjPyHgPXExGsNy0wlmWA3deEcReZVhg7q0bHsNy0wlmWA3deEcdiKwukySdr2qNmbEAFfBWfmqRO1b2imWA3deEQ58oqckzIAEBE(jUoVapuZhQ5JsOQt95LBEXaBKmVaNMhESbNuY8qbXbcXX5PIq648Tcb(8wnVXe8qCCEbUjZ3k485nOq5oopWA3deEA(ynpqRO1b2OoE(gHBY8muuBZB18uriDC(wHaFEeoVsm)ELRZFG5TAEQiKooVa3K5f408DIrBTMVvW5ZRURMNyp0aqZFfEG08sCLcZCQe074rTbd0W(y4Hqatix9o65usmWgjk07CnwObAv4tqVwea3Pv4dPn0OYUbsZlXvkmZPsqVJh1gmqd7nU5dJNSUtR8KRXcnqRcFc61Ia4oTcFiWcve6wbL48KyGnsu4nU5dJNSUtR8uBOr1T)oE)AvyObNBG0TslWPemGqArPAJDdKMxIRuyMtLGEhpQnyGg2lWPKKsaXEYvVJEoLedSrIc9oxJfAGwf(e0RfbWDAf(qGfQi0T)oE)AvyObNBG0TslWPemGqArPAJDdKMxIRuyMtLGEhpQnyGg2lWPeL3rbo5ASqZOTw49bNh1wcP5HhfHbK5f3aTk8jOxlcG70k8H0gk7yhmeJtLGbAv4tMiuPzsCfBGTi6wbL48KyGnsu4f4uIY7OaNAdnQUrHrBTWDYe4QuxJWkX87rJGSybHozc8Kv9uN8MJyj87JAJfli4pNuzLGRydUKwgH4aP5L4kfM5ujO3XJAdgOH9cCkr5DuGtUgl0aTk8jOxlcG70k8H0gAuyl7GHyCQemqRcFYeHkntIRydSfr3kOeNNedSrIcVaNsuEhf4uBOr1nkmARfUtMaxL6AewjMFpAeKfli0jtGNSQN6K3CelHFFuBSybb)5KkReCfBWL0YiehinVexPWmNkb9oEuBWanS34MpmEY6oTYtUgl0(749RvHHgCUbs3kTaNsWacPfLQnGwryjqsj5siOBGwf(e0RfbWDAf(qGfcIq3kOeNNedSrIcVXnFy8K1DALNAdnQdKMxIRuyMtLGEhpQnyGg2lWPKKsaXEYvVJEoLedSrIc9oxJfA)D8(1QWqdo3aPBLwGtjyaH0Is1gqRiSeiPKCje0nqRcFc61Ia4oTcFiWcbr4a5az7npmbKjWN)wZRhvhyBNYM3b4LWjnVd8etIRginVexPWmNkjHFFuBOpgEieWeYvVJEoLedSrIc9oxJfAGwf(e0RfbWDAf(qAdD7JWbsZlXvkmZPss43h1gmqdBaH8akItkvQvucbCnwOfJtLG3mbobIAlPKdGKfl)vDTqWKtcSaNsyXcOv06aBeMjKO2s(J3zXY8s4Ksurids1gAuzXccIXPsWBMaNarTLuYbq6gc(R6AHGjNeyboL4gcaTIwhyJWmHe1wYF8UBGwf(e0RfbGfBrDG08sCLcZCQKe(9rTbd0WUtMapzvp1jV5ORXcnqRcFc61IaWITOoqAEjUsHzovsc)(O2GbAyd)AXJAlXWnL4ASqZOTwyqGKWAqDJcqRcFc61Ia4oTcFiWIDSJflGwryjqsj5sSfwO38DwSuqjopjgyJefg(1Ih1wIHBkPn0OIilwaTk8jOxlcal2I6aP5L4kfM5ujj87JAdgOH9cCkr5DuGtUgl0mARfEFW5rTLqAE4rrynOUvqjopjgyJefEboLO8okWP2qJQBuGqNmbEYQEQtEZrSe(9rT52FoPYkbxXgCjTmIfli4pNuzLGRydUKwgH4aP5L4kfM5ujj87JAdgOHn8duPBLAfLqaxJfAGwf(e0RfbWDAf(qAdncIq3aTIWsGKsYLyBBB((aP5L4kfM5ujj87JAdgOH9cCkr5DuGtUgl0kOeNNedSrIcVaNsuEhf4uBOr1nkmARfUtMaxL6AewjMFpAeKfli0jtGNSQN6K3CelHFFuBSybb)5KkReCfBWL0YiehinVexPWmNkjHFFuBWanSpgEieWeYvVJEoLedSrIc9oxJfAGwf(e0RfbWDAf(qAdv2XIfqRiSeiPKCj2cRnFFG08sCLcZCQKe(9rTbd0Wg(1Ih1wIHBkX1yHMrBTWGajH1GoqAEjUsHzovsc)(O2GbAyBaVvusoaGkX1yHgOvHpb9AraCNwHpK2yhchihiBV2BEhE8(8TJidiZ7WR6HexPgiBV2BEZlXvkS)49eCYacApClkv6wPWtUgl0RydUKaeslkfS289bY2BE2yOO57AGO2Mhbm4CdmFRqGppB2tEdkSHjGmb(aP5L4kf2F8EcozabgOHThUfLkDRu4jxJfAiigNkbFm8qiGjXvUz0wlm0GZnq6wPf4ucgqiTOuWITUz0wlm0GZnq6wPf4ucwdQBgT1c7pEpbNmGGvI533g6DiCGS9MhbwturNM)wZJagCUbMxtr2gnFRqGppB2tEdkSHjGmb(aP5L4kf2F8EcozabgOHThUfLkDRu4jxJfAiigNkbFm8qiGjXvU7KjWt7RydUGbAfToWgHxgNtvYd0uwNaUHaJ2AHHgCUbs3kTaNsWAqDJcJ2AH9hVNGtgqWkX87Bd9U23nJ2AH1k4h3XKsauTjWXAqzXIrBTW(J3tWjdiyLy(9THEhcKB)D8(1QWqdo3aPBLwGtjyaH0Is12oeI4aP5L4kf2F8EcozabgOHThUfLkDRu4jxJfAiigNkbFm8qiGjXvUHqNmbEAFfBWfmqRO1b2i8Y4CQsEGMY6eWnJ2AH9hVNGtgqWkX87Bd9oe6gcmARfgAW5giDR0cCkbRb1T)oE)AvyObNBG0TslWPemGqArPAdveoq2EZJaciNujZ7WJ3NVDezaz(Zjb8guOrTnFxde128qdo3adKMxIRuy)X7j4KbeyGg2E4wuQ0TsHNCnwOfJtLGpgEieWK4k3qGrBTWqdo3aPBLwGtjynOUrHrBTW(J3tWjdiyLy(9THEx77MrBTWAf8J7ysjaQ2e4ynOSyXOTwy)X7j4KbeSsm)(2qVdbIfl)D8(1QWqdo3aPBLwGtjyaH0Isbl26MrBTW(J3tWjdiyLy(9THEhcI4a5az7npc4jXvdKMxIRuy)D8(1QuOHEsCLRXcnJ2AHHgCUbs3kTaNsWAqhiBV5D4D8(1QudKMxIRuy)D8(1QuWanSjKqVweib0kk1ImOx5ASqlgNkbFm8qiGjXvUbAfbR23nkonqymCcRKeuUvvuBSy50aHXWjS17QeGqArHOBu83X7xRcdn4CdKUvAboLGbeslkfSyhlwmARfgAW5giDR0cCkbRbfrwSwXgCjbiKwukyHkchinVexPW(749RvPGbAytiHETiqcOvuQfzqVY1yHwmovcMbqMapDRKkQoW2oL5gOvHpb9AraCNwHpK2ylcDd0kclbskjxIDTT57UrHrBTWmaYe4PBLur1b22PmSguwSwXgCjbiKwukyHkcrCG08sCLc7VJ3VwLcgOHnHe61IajGwrPwKb9kxJfAX4uj4WtEdQBGwrWITdKMxIRuy)D8(1QuWanSHgCUbs3kTaNsCnwOfJtLGzaKjWt3kPIQdSTtzUrXPbcJHtyLKGYTQIAJflNgimgoHTExLaeslkeDJI)oE)Avygazc80TsQO6aB7uggqiTOuSy5VJ3VwfMbqMapDRKkQoW2oLHbK1D0nqRcFc61Ia4oTcFiWIDieXbsZlXvkS)oE)AvkyGg2qdo3aPBLwGtjUgl0IXPsWHN8gu3qGrBTWqdo3aPBLwGtjynOdKMxIRuy)D8(1QuWanSHgCUbs3kTaNsCnwOfJtLGpgEieWK4k3O40aHXWjSssq5wvrTXILtdegdNWwVRsacPffIUrrmovcEZe4eiQTKsoasmvgdN6Uz0wlmGqEafXjLk1kkHaynOSybbX4uj4ntGtGO2sk5aiXuzmCQJ4aP5L4kf2FhVFTkfmqdBgazc80TsQO6aB7uMRXcnJ2AHHgCUbs3kTaNsWAqhinVexPW(749RvPGbAyVaNsA5iaPkT0ao6ASqBEjCsjQiKbPqVZnJ2AHHgCUbs3kTaNsWacPfLcwB(UBgT1cdn4CdKUvAboLG1G6gcIXPsWhdpecysCLBuGaWIEICsLGTExHj2hkrXIfWIEICsLGTExHJQn2IqezXAfBWLeGqArPGfBhinVexPW(749RvPGbAyVaNsA5iaPkT0ao6ASqBEjCsjQiKbPAdnQUrHrBTWqdo3aPBLwGtjynOSybSONiNujyR3v4OAZFhVFTkm0GZnq6wPf4ucgqiTOui6gfgT1cdn4CdKUvAboLGbeslkfS28DwSaw0tKtQeS17kmGqArPG1MVJ4aP5L4kf2FhVFTkfmqd7f4uslhbivPLgWrxJfAX4uj4JHhcbmjUYnJ2AHHgCUbs3kTaNsWAqDJckmARfgAW5giDR0cCkbdiKwukyT57SyXOTwyTc(XDmPeavBcCSgu3mARfwRGFChtkbq1MahdiKwukyT57i6gLoXOTwyG1Uhi8ewjMFpA2XIfe6KjWt7RydUGbAfToWgHbw7EGWtiI4aP5L4kf2FhVFTkfmqdB4oc9e4eaz4tqbKIkp5ASqlgNkbZaitGNUvsfvhyBNYCd0QWNGETiaUtRWhsBiicDd0kcwOzRBuy0wlmdGmbE6wjvuDGTDkdRbLfl)D8(1QWmaYe4PBLur1b22PmmGqArPAdbriISybbX4ujygazc80TsQO6aB7uMBGwf(e0RfbWDAf(qAdnQSBG08sCLc7VJ3VwLcgOHnWcfL6K1DnwOz0wlm0GZnq6wPf4ucwd6aP5L4kf2FhVFTkfmqdBL5bXk8HXtqnV4ASqBEjCsjQiKbPAdnQUrH5uk3RydUKaeslkfSyllwqGrBTWmaYe4PBLur1b22PmSgu3OaLe8g8tJJbeslkfS28DwSaw0tKtQeS17kmGqArPGfBDdSONiNujyR3v4OAdkj4n4NghdiKwukerCG08sCLc7VJ3VwLcgOHDNmbEYQEQtEZrxJfAZlHtkrfHmivBSJflGwrRdSryOWjdCiVIudKdKT38o8CsLvY8oaMGhsqQbsZlXvkS)CsLvIcDNmbUk11ixJfANgimgoHvsck3QkQnwSCAGWy4e26DvcqiTOginVexPW(ZjvwjkyGg2QwgazuBjKHsCnwObAv4tqVwea3Pv4dPn262FhVFTkm0GZnq6wPf4ucgqiTOuWITUHGyCQemdGmbE6wjvuDGTDkZTtdegdNWkjbLBvf12aP5L4kf2FoPYkrbd0Ww1YaiJAlHmuIRXcneeJtLGzaKjWt3kPIQdSTtzUDAGWy4e26DvcqiTOginVexPW(ZjvwjkyGg2QwgazuBjKHsCnwOfJtLGzaKjWt3kPIQdSTtzUrHrBTWmaYe4PBLur1b22PmSgu3O40aHXWjSssq5wvrT5gOvHpb9AraCNwHpK2qqeYILtdegdNWwVRsacPfLBGwf(e0RfbWDAf(qAR9rilwonqymCcB9UkbiKwuUbw0tKtQeS17kmGqArPGfceISybbgT1cZaitGNUvsfvhyBNYWAqD7VJ3VwfMbqMapDRKkQoW2oLHbeslkfIdKMxIRuy)5KkRefmqdBJ5qgLjXvjEGKX1yH2FhVFTkm0GZnq6wPf4ucgqiTOuWITUDAGWy4ewjjOCRQO2CJIyCQemdGmbE6wjvuDGTDkZnqRcFc61Ia4oTcFiWQ9rOB)D8(1QWmaYe4PBLur1b22PmmGqArPGfQSybbX4ujygazc80TsQO6aB7ugIdKMxIRuy)5KkRefmqdBJ5qgLjXvjEGKX1yH2PbcJHtyR3vjaH0IAG08sCLc7pNuzLOGbAyRGB(9CkjWPKw16acChDnwO93X7xRcdn4CdKUvAboLGbeslkfSyRBNgimgoHvsck3QkQTbsZlXvkS)CsLvIcgOHTcU53ZPKaNsAvRdiWD01yH2PbcJHtyR3vjaH0IAGCGS9MhbMHhcbmjUAEWjMexnqAEjUsHpgEieWK4k0ac5bueNuQuROec4ASqBEjCsjQiKbPAdnBDJIyCQe8MjWjquBjLCaKSy5VQRfcMCsGf4uclwaTIwhyJWmHe1wYF8oIdKMxIRu4JHhcbmjUcgOHn8RfpQTed3uIREh9CkjgyJef6DUgl0qOFcEboLKwKtcGLWVpQn3qGrBTW7dopQTesZdpkcRb1nqRO2qZ2bsZlXvk8XWdHaMexbd0WEboLO8okWjxJfAgT1cVp48O2sinp8OimGmV4wbL48KyGnsu4f4uIY7OaNAdnQUrHrBTWDYe4QuxJWkX87rJGSybHozc8Kv9uN8MJyj87JAJfli4pNuzLGRydUKwgH4aP5L4kf(y4HqatIRGbAyFm8qiGjKREh9CkjgyJef6DUgl0mARfEFW5rTLqAE4rryazEHfliWOTwyqGKWAqDRGsCEsmWgjkm8RfpQTed3usBOz7aP5L4kf(y4HqatIRGbAyVXnFy8K1DALNCnwOvqjopjgyJefEJB(W4jR70kp1gAuDJcqRcFc61Ia4oTcFiWAhczXcOvewcKusUeQTT57iYIfkDIrBTWaRDpq4jSsm)EyXowS6eJ2AHbw7EGWtyaH0IsbRDSdXbsZlXvk8XWdHaMexbd0WEboLKuci2tUgl0(R6AHGjG1dVjrTLy4xl3mARfMawp8Me1wIHFTWkX87rJQBZlHtkrfHmif6DdKMxIRu4JHhcbmjUcgOHn8RfpQTed3uIRXcnJ2AHbbscRb1TckX5jXaBKOWWVw8O2smCtjTHg1bsZlXvk8XWdHaMexbd0WEJB(W4jR70kp5ASqRGsCEsmWgjk8g38HXtw3PvEQn0OoqAEjUsHpgEieWK4kyGg2lWPKKsaXEYvVJEoLedSrIc9oxJfAiigNkbBonUvE4KBiWOTw49bNh1wcP5HhfH1GYILyCQeS504w5HtUHaJ2AHbbscRbLflgT1cdcKewdQBGwryjqsj5sO2g6nFFG08sCLcFm8qiGjXvWanSHFT4rTLy4MsCnwOz0wlmiqsynOdKMxIRu4JHhcbmjUcgOH9XWdHaMqU6D0ZPKyGnsuO3nqoq2EZJaEhpQT5ztoW8iWm8qiGjXvUyEDXaIA(DiCEf5VQRMNHwhGMhbm4Cdm)TMNnbCkzE)HKuZFR18oSD8aP5L4kf(y4HqatIRsqVJh1gAaH8akItkvQvucbCnwOfJtLG3mbobIAlPKdGKfl)vDTqWKtcSaNsyXcOv06aBeMjKO2s(J3zXY8s4Ksurids1gAuhinVexPWhdpecysCvc6D8O2GbAyd)AXJAlXWnL4ASqZOTwyqGKWAqhinVexPWhdpecysCvc6D8O2GbAyFm8qiGjKREh9CkjgyJef6DUgl0mARfEFW5rTLqAE4rryazEzG08sCLcFm8qiGjXvjO3XJAdgOH9g38HXtw3PvEY1yHwbL48KyGnsu4nU5dJNSUtR8uBOr1nqRcFc61Ia4oTcFiWQ9r4aP5L4kf(y4HqatIRsqVJh1gmqd7f4ussjGyp5Q3rpNsIb2irHENRXcnqRcFc61Ia4oTcFiWYbJWbsZlXvk8XWdHaMexLGEhpQnyGg2hdpecyc5Q3rpNsIb2irHENRXcnqRO2qZ2bsZlXvk8XWdHaMexLGEhpQnyGg2lWPeL3rbo5ASqBEjCsjQiKbPAdnc6gfi0jtGNSQN6K3CelHFFuBU9NtQSsWvSbxslJyXcc(Zjvwj4k2GlPLrioqoq2EZ7anFy85DambpKGudKMxIRuyG5dJRqZWVRNwAahDnwOz0wlm0GZnq6wPf4ucwd6aP5L4kfgy(W4kyGg2meqrG9rT5ASqZOTwyObNBG0TslWPeSg0bsZlXvkmW8HXvWanSnG3kkbvJRixJfAuGaJ2AHHgCUbs3kTaNsWAqDBEjCsjQiKbPAdnQiYIfey0wlm0GZnq6wPf4ucwdQBuaAfH70k8H0gA25gOvHpb9AraCNwHpK2q3(ieXbsZlXvkmW8HXvWanS5XgCrLyJPwFdjvIRXcnJ2AHHgCUbs3kTaNsWAqhinVexPWaZhgxbd0W2kpPeGXtEJZDnwOz0wlm0GZnq6wPf4ucwdQBgT1ctiHETiqcOvuQfzqVcRbDG08sCLcdmFyCfmqd7vaig(DDxJfAgT1cdn4CdKUvAboLGbeslkfSqJa4MrBTWesOxlcKaAfLArg0RWAqhinVexPWaZhgxbd0WMX2s3kjGWVx5ASqZOTwyObNBG0TslWPeSgu3MxcNuIkczqk07CJcJ2AHHgCUbs3kTaNsWacPfLcwSZTyCQeS)49eCYacMkJHtDwSGGyCQeS)49eCYacMkJHtD3mARfgAW5giDR0cCkbdiKwukyXwehihiBV51fR6gOpVkQnoXgxmWgjZdoXK4QbsZlXvkSsSQBGoAaH8akItkvQvucbCnwOfJtLG3mbobIAlPKdGKfl)vDTqWKtcSaNsyXcOv06aBeMjKO2s(J3hinVexPWkXQUb6WanS34MpmEY6oTYtUgl0qOtMapTVIn4cgOv06aBegyT7bcp5gLoXOTwyG1Uhi8ewjMFpSyhlwDIrBTWaRDpq4jmGqArPGLdgXbsZlXvkSsSQBGomqd7f4ussjGyp5ASq7VJ3VwfgqipGI4KsLAfLqamGqArPGfAuzdB(UBX4uj4ntGtGO2sk5aihinVexPWkXQUb6WanSxGtjjLaI9KRXcT)QUwiycy9WBsuBjg(1YnJ2AHjG1dVjrTLy4xlSsm)E0OYIL)QUwiyTItMco1tlavTRJUz0wlSwXjtbN6PfGQ21rmGqArPGfBDZOTwyTItMco1tlavTRJynOdKMxIRuyLyv3aDyGg2WVw8O2smCtjUgl0mARfgeijSg0bsZlXvkSsSQBGomqd7JHhcbmHCnwOHaJ2AHxGRDPkbvJRiSgu3IXPsWlW1UuLGQXvelwmARfEFW5rTLqAE4rryazEHfRozc8Kv9uN8MJyj87JAZT)CsLvcUIn4sAzKBgT1c3jtGRsDncReZVhwiilwaTIWsGKsYLqqyHEZ3hinVexPWkXQUb6WanSxGtjjLaI9KRXcnqRcFc61Ia4oTcFiWcLDSdgIXPsWaTk8jteQ0mjUInWwehinVexPWkXQUb6WanSpgEieWeY1yHgOvHpb9AraCNwHpK2qbv2bdX4ujyGwf(KjcvAMexXgylIdKMxIRuyLyv3aDyGg2lWPKKsaXEAG08sCLcReR6gOdd0Wg(bQ0TsTIsiWaP5L4kfwjw1nqhgOHTb8wrj5aaQKbYbY2B(gbrTNe1aP5L4kfwarTNef6OuEGMymCk1o1Ss0qM6KZWtUgl0mARfgAW5giDR0cCkbRbLflXaBKGLajLKlb1ljuriSyhlwmNs5EfBWLeGqArPGfQ7giBV5BeonVaIApjZ3ke4ZlWP5HhBWjLmpPKaPjuFENgxJCD(wbNppdnVMI6ZVcGsM3Q(8qTaq95Bfc85rado3aZFR5ztaNsWdKMxIRuybe1EsuWanSfqu7jzNRXcneCAGWy4ewbL8XkOEsarTNe3mARfgAW5giDR0cCkbRb1nkqqmovco8K3GYILyCQeC4jVb1nJ2AHHgCUbs3kTaNsWacPfLQn07qiIUrbcciQ9KGrfd3uj)D8(1QyXsarTNemQy)D8(1QWacPfLIflNgimgoHfqu7jjbfehiehrVdrwSequ7jbVdZOTwPUgWK4Q2qVIn4scqiTOudKMxIRuybe1EsuWanSfqu7jbvxJfAi40aHXWjSck5Jvq9KaIApjUz0wlm0GZnq6wPf4ucwdQBuGGyCQeC4jVbLflX4uj4WtEdQBgT1cdn4CdKUvAboLGbeslkvBO3HqeDJceequ7jbVdd3uj)D8(1QyXsarTNe8oS)oE)AvyaH0IsXILtdegdNWciQ9KKGcIdeIJOrfrwSequ7jbJkMrBTsDnGjXvTHEfBWLeGqArPgiBV5zZR5VI748xrZF18AkAEbe1EsMhk4CgDsnVnpJ2A568AkAEbon)jWjW8xnV)oE)Av45rGbZhR5lke4eyEbe1EsMhk4CgDsnVnpJ2A568AkAEMtGp)vZ7VJ3VwfEG08sCLclGO2tIcgOHTaIApj7CnwOHGaIApj4Dy4MkPPOeJ2A5gfbe1EsWOI93X7xRcdiKwukwSGGaIApjyuXWnvstrjgT1crwS83X7xRcdn4CdKUvAboLGbeslkvBOIWbsZlXvkSaIApjkyGg2ciQ9KGQRXcneequ7jbJkgUPsAkkXOTwUrrarTNe8oS)oE)AvyaH0IsXIfeequ7jbVdd3ujnfLy0wlezXYFhVFTkm0GZnq6wPf4ucgqiTOuTHkcZ6kOKp3aQSBxwYsod]] )


end
