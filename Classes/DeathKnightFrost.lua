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


    spec:RegisterPack( "Frost DK", 20211123, [[d4KSbdqiaLhjPuUevkQnrL8jvQgfk0PqrwfqfELkfZcLQBHIIyxe(fGQHHIQJjPAzOuEgvunnGkDnuqBdfL8njLQgNKsLZjPiwNKcZdOQ7Hs2NKOdsLcTqvk9qQuAIuPaUikk0gbQO(ivkOrsLc0jrrPwjq5LOOi1mLuYoPI8tGkYqrrblLkf5PezQscxfffj9vuuuJffyVI8xrnyqhMYIH0JPQjRIlJSzj(maJgiNwy1OOiXRbKzd1THWUL63QA4QKJlPiTCLEoQMoPRtuBhI(UK04PIY5Ps16LuuZNkSFfNQNQijDmLsoXgZzRE96S5CbB1bxMfdb3KK6(fLKUmpqgakj1gckjboVpxhOBaMPtsxM743oPkss8xE9uscKQx8AaCGdiuqYOc)Ja48aHm204B)Aff48aHh4jju5aRm7oHMKoMsjNyJ5SvVED2CUGT6GlZIHjjtwb9Bsskq42KeO4COoHMKoe3NKCdqMcAGmt3baq6abN3NRdyo9ijeO0oW6oN9bYgZzR(a2aMBbznaIpGXmzGUjcXJKodeBCLzcN8FFgOm3aqd8ld0TGSO5d8ldKz7PbA8bg6appX776aVWM7dSkHXdm6bETMxdpjgWyMmq3aFFxhOhK1nHhi4mM4G8Rv0bEK3ObmWBxYuqd8lduk6ZAaEUjss4GR8ufjPhfhkTMgFNV(hhnGufjNQNQijrTHIPt62KK5147K0si(LtyIZZvJwPnjDiUFJln(ojXm8poAadeC(3bcoHIdLwtJVRXaLuBv(aRZ8bYj)3h(arPYV0azgcm22b(LbcoVpxhO)rq8b(LYaDRBGKKFdL2WssiTnmumj2Qzu5sHpqhogO51ajLPMqeeFGvYAGSL0KtSLQijrTHIPt62KKFdL2Wss8lcJZQTaiLlaGnFy4SDqATNgyLSgiBd01avdtTkk7ZvU3DfejO2qX0jjzEn(ojbaB(WWz7G0ApL0KtopvrsIAdftN0Tjj)gkTHLKqLlfbqbghnGmcZdkAsSK51b6AGMxdKuMAcrq8bw5azBGUgiWgisBddftIdzkiE(itzZRbskjzEn(ojv2NRCV7kikPjNa3ufjjQnumDs3MKmVgFNKEuCO0AkLK8BO0gwscvUueafyC0aYimpOOjXsMxtsE39ykR2cGuEYP6jn5edtvKKO2qX0jDBsYVHsByjjZRbsktnHii(aznW6d01arAByOysu2NRzUUbqu2)9rouEsY8A8DsQSpxZCDdGOKMCIzLQijrTHIPt62KK5147K0JIdLwtPKKFdL2WssOYLIaOaJJgqgH5bfnjwY8AsY7Uhtz1waKYtovpPjNQ9PkssuBOy6KUnj53qPnSKesBddftI91IpVbckjzEn(ojb6RIJgqgfBCnPjNQDPkssuBOy6KUnj53qPnSKe)IW4SAlas5cayZhgoBhKw7PbwjRbY2aDnWvUdF(6RsR4qLWh6ab)azwmpjzEn(ojbaB(WWz7G0ApL0Kt1KufjjQnumDs3MKmVgFNKk7Z1mx3aikj53qPnSK0k3HpF9vPvCOs4dDGGFG1EMNK8U7XuwTfaP8Kt1tAYP6mpvrsIAdftN0TjjZRX3jPhfhkTMsjj)gkTHLKw5MgyLSgOZtsE39ykR2cGuEYP6jn5u96PkssuBOy6KUnj53qPnSKK51ajLPMqeeFGvYAGG7aDnqGnqK2ggkMehYuq88rMYMxdKusY8A8DsQSpx5E3vqustAsY)4tgezRMQi5u9ufjjQnumDs3MKmVgFNK8GSO55VKdpLKoe3VXLgFNKyMkNg4rEJgWazgcm22bwnuqdKz7jVDb8BxYuqjj)gkTHLKa2avdtTkEuCO0AA8TGAdftNb6AGOYLI4kWyBZFjx2NRc5Rb6AGOYLIW)4tgezRk4Q5bAGvYAG1z(aDnqghiQCPiUcm228xYL95Qyjew08bc(bcWFgi4yGmoW6d8Mb6)hF(QTOSpxR6(IGNlYR7ILSJ7dKPb6WXarLlfHCd6XUN56snafKyjew08bc(bcWFgOdhdevUueEq2ZZOwtILqyrZhi4hia)zGmL0KtSLQijrTHIPt62KK5147KKhKfnp)LC4PK0H4(nU047Ke4KSYJdnWVmqMHaJTDGYCYaqdSAOGgiZ2tE7c43UKPGss(nuAdljbSbQgMAv8O4qP104Bb1gkMod01apKPGYa1baqQyLBQ8lasummM6SFL52H2b6AGaBGOYLI4kWyBZFjx2NRc5Rb6AG()XNVAlUcm228xYL95Qyjew08bw5aRZWb6AGmoqu5sr4F8jdISvfC18anWkznW6mFGUgiJdevUueYnOh7EMRl1auqc5Rb6WXarLlfHhK98mQ1Kq(AGmnqhogiQCPi8p(Kbr2QcUAEGgyLSgyDNpqMsAYjNNQijrTHIPt62KKFdL2WssaBGQHPwfpkouAnn(wqTHIPZaDnqGnWdzkOmqDaaKkw5Mk)cGefdJPo7xzUDODGUgiQCPi8p(Kbr2QcUAEGgyLSgyDMpqxdeydevUuexbgBB(l5Y(CviFnqxd0)p(8vBXvGX2M)sUSpxflHWIMpWkhiBmpjzEn(oj5bzrZZFjhEkPjNa3ufjjQnumDs3MKmVgFNK8GSO55VKdpLKoe3VXLgFNKygwcj16aD7Jpd0nizRoWhjTE76kAad8iVrdyGxbgBBsYVHsByjj1WuRIhfhkTMgFlO2qX0zGUgiWgiQCPiUcm228xYL95Qq(AGUgiJdevUue(hFYGiBvbxnpqdSswdSo4oqxdKXbIkxkc5g0JDpZ1LAakiH81aD4yGOYLIWdYEEg1AsiFnqMgOdhdevUue(hFYGiBvbxnpqdSswdSEnzGoCmq))4ZxTfxbgBB(l5Y(CvSeclA(ab)aD(aDnqu5sr4F8jdISvfC18anWkznW6G7azkPjnj9O4qP1047ufjNQNQijrTHIPt62KK5147K0si(LtyIZZvJwPnjDiUFJln(ojboHIdLwtJVh4(QPX3jj)gkTHLKmVgiPm1eIG4dSswd05d01arAByOysSvZOYLcpPjNylvrsIAdftN0Tjj)gkTHLKa2arLlfbqbghnGmcZdkAsiFnqxdCLBAGvYAGoFGUgiJdevUueBGGelHWIMpqWpqNpqxdevUueBGGeYxd0HJbAEnqs5ZRIY(CnxiK0oqWpqZRbsktnHii(azkjzEn(ojb6RIJgqgfBCnPjNCEQIKe1gkMoPBts(nuAdljbSbIkxkcGcmoAazeMhu0Kq(AGUgi)IW4SAlas5cayZhgoBhKw7PbwjRbY2aD4yGaBGOYLIaOaJJgqgH5bfnjKVgORbY4apeQCPiwRM)n8KGRMhObc(bYWb6WXapeQCPiwRM)n8Kyjew08bc(bcWFgi4yGG7azkjzEn(ojbaB(WWz7G0ApL0KtGBQIKe1gkMoPBts(nuAdljHkxkcGcmoAazeMhu0KyjZRd01a5xegNvBbqkxu2NRCV7kiAGvoq2gORbcSbI02WqXK4qMcINpYu28AGKssMxJVtsL95k37UcIsAYjgMQijrTHIPt62KK5147K0JIdLwtPKKFdL2WssOYLIaOaJJgqgH5bfnjwY8AsY7Uhtz1waKYtovpPjNywPkssuBOy6KUnj53qPnSKK51ajLPMqeeFGSgy9b6AGiTnmumjk7Z1mx3aik7)(ihkpjzEn(ojv2NRzUUbqustov7tvKKO2qX0jDBsYVHsByjjK2ggkMe7RfFEde0aDnq(fHXz1waKYfG(Q4ObKrXgxhyLSgiBjjZRX3jjqFvC0aYOyJRjn5uTlvrsIAdftN0Tjj)gkTHLK4xegNvBbqkxaaB(WWz7G0ApnWkznq2ssMxJVtsaWMpmC2oiT2tjn5unjvrsIAdftN0TjjZRX3jPY(CnZ1naIss(nuAdljbSbQgMAvyinS1EqKGAdftNb6AGaBGOYLIaOaJJgqgH5bfnjKVgOdhdunm1QWqAyR9Gib1gkMod01ab2arAByOysSVw85nqqd0HJbI02WqXKyFT4ZBGGgORbUYnj0abL1pZ2aRK1ab4pjjV7EmLvBbqkp5u9KMCQoZtvKKO2qX0jDBsYVHsByjjK2ggkMe7RfFEdeusY8A8Dsc0xfhnGmk24AstovVEQIKe1gkMoPBtsMxJVtspkouAnLssE39ykR2cGuEYP6jnPjj0NN1Wdu0asvKCQEQIKe1gkMoPBtsMxJVtspkouAnLssE39ykR2cGuEYP6jj)gkTHLKw5o85RVkTIdvcFOdSswdKXbcUmCG3mq1WuRIvUdF2uLAztJVfuBOy6mqWXaz4azkjDiUFJln(ojD7sMcAGFzGsrFwdWZTb6g9AGKgOB6vtJVtAYj2svKKO2qX0jDBsYVHsByjjK2ggkMeB1mQCPWhOdhd08AGKYuticIpWkznq2gOdhdCL7WNV(Q0oqWpqNZwsY8A8DsAje)YjmX55QrR0M0KtopvrsIAdftN0Tjj)gkTHLKw5o85RVkTde8d05SLKmVgFNKoKPGYwFYhYBUN0KtGBQIKe1gkMoPBts(nuAdljH02WqXKyFT4ZBGGgORbY4ax5o85RVkTIdvcFOde8dKHmCGoCmWvUjHgiOS(zNpqWZAGa8Nb6WXax5Mk)cGeRbGYFjRGOCz)AM6ShKH4k(wqTHIPZaD4yG8lcJZQTaiLla9vXrdiJInUoWkznq2gOdhdevUueBGGelHWIMpqWpqNpqMgOdhdCL7WNV(Q0oqWpqNZwsY8A8Dsc0xfhnGmk24AstoXWufjjQnumDs3MK8BO0gwscvUueafyC0aYimpOOjH81aDnq(fHXz1waKYfL95k37UcIgyLdKTb6AGaBGiTnmumjoKPG45JmLnVgiPKK5147KuzFUY9URGOKMCIzLQijrTHIPt62KK5147K0JIdLwtPKKFdL2WssOYLIaOaJJgqgH5bfnjwY8AsY7Uhtz1waKYtovpPjNQ9PkssuBOy6KUnj53qPnSK0k3HpF9vPvCOs4dDGvYAGGlZhORbUYnj0abL1p78bw5ab4pjjZRX3jjq)25VKRgTsBstov7svKKO2qX0jDBsYVHsByjj(fHXz1waKYfL95k37UcIgyLdKTb6AGaBGiTnmumjoKPG45JmLnVgiPKK5147KuzFUY9URGOKMCQMKQijrTHIPt62KK5147K0JIdLwtPKKFdL2WssRCh(81xLwXHkHp0bw5azJHd0HJbUYnj0abL1p78bc(bcWFssE39ykR2cGuEYP6jn5uDMNQijrTHIPt62KKFdL2WssiTnmumj2xl(8giOKK5147KeOVkoAazuSX1KMCQE9ufjjQnumDs3MK8BO0gwsAL7WNV(Q0kouj8HoWkhidzEsY8A8DsYwV1uw)DPwtAstsC16JTNufjNQNQijrTHIPt62KK5147K0si(LtyIZZvJwPnjDiUFJln(ojjPwFS9mqE0aWeZe1waKoW9vtJVts(nuAdljH02WqXKyRMrLlfEstoXwQIKe1gkMoPBts(nuAdljHkxkcGcmoAazeMhu0KyjZRjjZRX3jPhfhkTMsjn5KZtvKKO2qX0jDBsYVHsByjjK2ggkMe7RfFEde0aDnqu5srSbcsSeclA(ab)aDEsY8A8Dsc0xfhnGmk24AstobUPkssuBOy6KUnj53qPnSKesBddftIY(CnZ1naIY(VpYHYtsMxJVtsL95AMRBaeL0KtmmvrsIAdftN0Tjj)gkTHLKa2apKPGYa1baqQyLBQ8lasSwn)B4Pb6AGmoWdHkxkI1Q5Fdpj4Q5bAGGFGmCGoCmWdHkxkI1Q5FdpjwcHfnFGGFGa8Nbcogi4oqMssMxJVtsaWMpmC2oiT2tjn5eZkvrsIAdftN0Tjj)gkTHLK8)JpF1wSeIF5eM48C1OvAflHWIMpqWZAGSnqWXab4pd01avdtTkaykiAJgqMR)IqqTHIPtsY8A8DsQSpxZCDdGOKMCQ2NQijrTHIPt62KKFdL2WssiTnmumj2xl(8giOKK5147KeOVkoAazuSX1KMCQ2LQijrTHIPt62KKFdL2WssRCh(81xLwXHkHp0bc(bY4aRZWbEZavdtTkw5o8ztvQLnn(wqTHIPZabhdKHdKPKK5147KuzFUM56garjn5unjvrsIAdftN0Tjj)gkTHLKa2arLlfrz)AM68LmMtc5Rb6AGQHPwfL9RzQZxYyojO2qX0zGoCmqK2ggkMehYuq88rMYMxdK0aDnqu5srCitbXZhzsWvZd0ab)ab3b6WXavdtTkaykiAJgqMR)IqqTHIPZaDnqu5srSeIF5eM48C1OvAfYxd0HJbUYD4ZxFvAfhQe(qhyLdKXbYgdh4ndunm1QyL7WNnvPw204Bb1gkModeCmqgoqMssMxJVtspkouAnLsAYP6mpvrsY8A8DsQSpxZCDdGOKe1gkMoPBtAYP61tvKKmVgFNKa9BN)sUA0kTjjQnumDs3M0Kt1zlvrsY8A8DsYwV1uw)DPwtsuBOy6KUnPjnjDOIjJ1ufjNQNQijzEn(ojHi6tUSevZusIAdftN0Tjn5eBPkssuBOy6KUnj9xjjoPjjZRX3jjK2ggkMssinSmLKyCGunvoUUOJiAUFLvdft5AQS1QmI8HqgEAGUgO)F85R2IO5(vwnumLRPYwRYiYhcz4jXs2X9bYus6qC)gxA8DsIzyjKuRdKFr(Oe0zG6gnqKYhikfnGbkZPZaRgkObAY6JW0WpqC0epjH02CBiOKe)I8rjOtw3ObI0KMCY5PkssuBOy6KUnj9xjjoPjjZRX3jjK2ggkMssinSmLKmVgiPm1eIG4dK1aRpqxdKXbUwCYesQvHDoCr0dSYbwNHd0HJbcSbUwCYesQvHDoCb5SGR8bYuscPT52qqjjUMVWw3rdiPjNa3ufjjQnumDs3MK(RKeN0KK5147KesBddftjjKgwMssMxdKuMAcrq8bwjRbY2aDnqghiWg4AXjtiPwf25WfKZcUYhOdhdCT4KjKuRc7C4cYzbx5d01azCGRfNmHKAvyNdxSeclA(aRCGmCGoCmWsaaKMxcHfnFGvoW6mFGmnqMssiTn3gckjzNdpVecl6KMCIHPkssuBOy6KUnj9xjjoPjjZRX3jjK2ggkMssinSmLKqLlfXgiiH81aDnqghiWg4k3u5xaKynau(lzfeLl7xZuN9GmexX3cQnumDgOdhdCLBQ8lasSgak)LScIYL9RzQZEqgIR4Bb1gkMod01ax5o85RVkTIdvcFOdSYbw7gitjjK2MBdbLK2xl(8giOKMCIzLQijrTHIPt62K0FLK4KMKmVgFNKqAByOykjH0WYusY)9roubT2j8MgnGmk(RoqxdevUue0ANWBA0aYO4VQGRMhObYAGSnqhogO)7JCOc5gtgheDYLL6A2Db1gkMod01arLlfHCJjJdIo5YsDn7Uyjew08bc(bY4ab4pdeCmq2gitjjK2MBdbLKk7Z1mx3aik7)(ihkpPjNQ9PkssuBOy6KUnj9xjjoPjjZRX3jjK2ggkMssinSmLKoKPGYwFYhYBUl0Wdu0agORb6FKuBTk6aainxmkjH02CBiOK0HmfepFKPS51ajL0Kt1UufjjQnumDs3MKmVgFNKwcXVCctCEUA0kTjPdX9BCPX3jj341f29bcoVpxhi4mHKw2hiclA1IEGmBV7dScd)nFGwFgiqeDnq3eH4xoHjoFGmZrR0oW9X4ObKK8BO0gwsY)9roubHK2Y(CDGUgOAyQvbatbrB0aYC9xecQnumDgORbcSbQgMAv8O4qP104Bb1gkMod01a9)JpF1wCfyST5VKl7ZvXsiSO5jn5unjvrsIAdftN0TjjZRX3jjqFvC0aYOyJRjj)gkTHLKoVkk7Z1CHqsRyPYsCqgkMgORbY4avdtTkcp5Tlb1gkMod0HJbcSbIkxkc0Lmfu(lzE0N1a8CtiFnqxdunm1QaDjtbL)sMh9znap3euBOy6mqhogOAyQvXJIdLwtJVfuBOy6mqxd0)p(8vBXvGX2M)sUSpxflHWIMpqxdeydevUueafyC0aYimpOOjH81azkj5D3JPSAlas5jNQN0Kt1zEQIKe1gkMoPBts(nuAdljHkxkIW7Ewn83CXsiSO5de8Sgia)zGUgOAyQvr4DpRg(BUGAdftNb6AG8lcJZQTaiLlaGnFy4SDqATNgyLSgiBd01azCGQHPwfHN82LGAdftNb6WXavdtTkqxYuq5VK5rFwdWZnb1gkMod01a9)JpF1wGUKPGYFjZJ(SgGNBILqyrZhyLdSodhOdhdunm1Q4rXHsRPX3cQnumDgORbcSbIkxkIRaJTn)LCzFUkKVgitjjZRX3jjayZhgoBhKw7PKMCQE9ufjjQnumDs3MK8BO0gwscvUueH39SA4V5ILqyrZhi4znqa(ZaDnq1WuRIW7Ewn83Cb1gkMod01azCGQHPwfHN82LGAdftNb6WXavdtTkqxYuq5VK5rFwdWZnb1gkMod01ab2arLlfb6sMck)Lmp6ZAaEUjKVgORb6)hF(QTaDjtbL)sMh9znap3elHWIMpWkhyDMpqhogOAyQvXJIdLwtJVfuBOy6mqxdeydevUuexbgBB(l5Y(CviFnqMssMxJVtsL95AMRBaeL0Kt1zlvrsIAdftN0TjPdX9BCPX3jj3c6Fonq3OxJVhio46a1FGRCNKmVgFNK8ggNnVgFNXbxts4GR52qqjj)JKARvEstov35PkssuBOy6KUnjzEn(oj5nmoBEn(oJdUMKWbxZTHGssR5ddZtAYP6GBQIKe1gkMoPBtsMxJVtsEdJZMxJVZ4GRjjCW1CBiOKKUrdeP8KMCQodtvKKO2qX0jDBsY8A8DsYByC28A8DghCnjHdUMBdbLK8)JpF1MN0Kt1zwPkssuBOy6KUnj53qPnSKKAyQvH)XNmiYwvqTHIPZaDnqghiWgiQCPiakW4ObKryEqrtc5Rb6WXavdtTkqxYuq5VK5rFwdWZnb1gkModKPb6AGmoWdHkxkI1Q5Fdpj4Q5bAGSgidhOdhdeyd8qMckduhaaPIvUPYVaiXA18VHNgitjjUUHxtovpjzEn(oj5nmoBEn(oJdUMKWbxZTHGss(hFYGiB1KMCQETpvrsIAdftN0Tjj)gkTHLKqLlfb6sMck)Lmp6ZAaEUjKVssCDdVMCQEsY8A8DsAL7S5147mo4AschCn3gckjH(8SgEGIgqstovV2LQijrTHIPt62KKFdL2WssQHPwfOlzkO8xY8OpRb45MGAdftNb6AGmoq))4ZxTfOlzkO8xY8OpRb45Myjew08bc(bwN5dKPb6AGmoW1ItMqsTkSZHlIEGvoq2y4aD4yGaBGRfNmHKAvyNdxqol4kFGoCmq))4ZxTfxbgBB(l5Y(CvSeclA(ab)aRZ8b6AGRfNmHKAvyNdxqol4kFGUg4AXjtiPwf25WfrpqWpW6mFGmLKmVgFNKw5oBEn(oJdUMKWbxZTHGssOppF9poAajn5u9AsQIKe1gkMoPBts(nuAdljHkxkIRaJTn)LCzFUkKVgORbQgMAv8O4qP104Bb1gkMojjUUHxtovpjzEn(ojTYD28A8DghCnjHdUMBdbLKEuCO0AA8DstoXgZtvKKO2qX0jDBsYVHsByjj1WuRIhfhkTMgFlO2qX0zGUgO)F85R2IRaJTn)LCzFUkwcHfnFGGFG1z(aDnqghisBddftcUMVWw3rdyGoCmW1ItMqsTkSZHliNfCLpqxdCT4KjKuRc7C4IOhi4hyDMpqhogiWg4AXjtiPwf25WfKZcUYhitjjZRX3jPvUZMxJVZ4GRjjCW1CBiOK0JIdLwtJVZx)JJgqstoXw9ufjjQnumDs3MK8BO0gwsY8AGKYuticIpWkznq2ssCDdVMCQEsY8A8DsAL7S5147mo4AschCn3gckjzpL0KtSXwQIKe1gkMoPBtsMxJVtsEdJZMxJVZ4GRjjCW1CBiOKexT(y7jPjnj5)hF(QnpvrYP6PkssuBOy6KUnj53qPnSKeQCPiUcm228xYL95Qq(kjDiUFJln(ojXm8A8DsY8A8Ds66147KMCITufjjQnumDs3MKmVgFNKiexFvAZRCt5QKD9Ds6qC)gxA8DsYT)JpF1MNK8BO0gwssnm1Q4rXHsRPX3cQnumDgORbUYnnqWpqM1aDnqghisBddftcUMVWw3rdyGoCmqK2ggkMe25WZlHWIEGmnqxdKXb6)hF(QT4kWyBZFjx2NRILqyrZhi4hidhORbY4a9)JpF1wuWehKFTIkwcHfnFGvoqgoqxdK)Yy0OpIlzUkJPmTYxA8TGAdftNb6WXab2a5Vmgn6J4sMRYyktR8LgFlO2qX0zGmnqhogiQCPiUcm228xYL95Qq(AGmnqhogi6Z5d01albaqAEjew08bc(bYgZtAYjNNQijrTHIPt62KKFdL2WssQHPwfOlzkO8xY8OpRb45MGAdftNb6AGRCh(81xLwXHkHp0bw5aDoZhORbUYnj0abL1pZWbw5ab4pd01azCGOYLIaDjtbL)sMh9znap3eYxd0HJbwcaG08siSO5de8dKnMpqMssMxJVtseIRVkT5vUPCvYU(oPjNa3ufjjQnumDs3MK8BO0gwssnm1Qi8K3UeuBOy6KKmVgFNKiexFvAZRCt5QKD9DstoXWufjjQnumDs3MK8BO0gwssnm1QaDjtbL)sMh9znap3euBOy6mqxdKXbI02WqXKGR5lS1D0agOdhdePTHHIjHDo88siSOhitd01azCG()XNVAlqxYuq5VK5rFwdWZnXsiSO5d0HJb6)hF(QTaDjtbL)sMh9znap3elzh3hORbUYD4ZxFvAfhQe(qhi4hidz(azkjzEn(ojDfyST5VKl7Z1KMCIzLQijrTHIPt62KKFdL2WssQHPwfHN82LGAdftNb6AGaBGOYLI4kWyBZFjx2NRc5RKK5147K0vGX2M)sUSpxtAYPAFQIKe1gkMoPBts(nuAdljPgMAv8O4qP104Bb1gkMod01ax5o85RVkTdSswdKngoqxdKXbI02WqXKGR5lS1D0agOdhdePTHHIjHDo88siSOhitd01azCGQHPwfamfeTrdiZ1FriO2qX0zGUgiQCPiwcXVCctCEUA0kTc5Rb6WXab2avdtTkaykiAJgqMR)IqqTHIPZazkjzEn(ojDfyST5VKl7Z1KMCQ2LQijrTHIPt62KKFdL2WssOYLI4kWyBZFjx2NRc5RKK5147Ke6sMck)Lmp6ZAaEUL0Kt1KufjjQnumDs3MK8BO0gwsY8AGKYuticIpqwdS(aDnqu5srCfyST5VKl7ZvXsiSO5de8deG)mqxdevUuexbgBB(l5Y(CviFnqxdeydunm1Q4rXHsRPX3cQnumDgORbY4ab2axlozcj1QWohUGCwWv(aD4yGRfNmHKAvyNdxe9aRCGoN5dKPb6WXalbaqAEjew08bc(b68KK5147KuzFUw19fbpxKx3tAYP6mpvrsIAdftN0Tjj)gkTHLKmVgiPm1eIG4dSswdKTb6AGmoqu5srCfyST5VKl7ZvH81aD4yGRfNmHKAvyNdxqol4kFGUg4AXjtiPwf25WfrpWkhO)F85R2IRaJTn)LCzFUkwcHfnFG3mWA)azAGUgiJdevUuexbgBB(l5Y(CvSeclA(ab)ab4pd0HJbUwCYesQvHDoCb5SGR8b6AGRfNmHKAvyNdxSeclA(ab)ab4pdKPKK5147KuzFUw19fbpxKx3tAYP61tvKKO2qX0jDBsYVHsByjj1WuRIhfhkTMgFlO2qX0zGUgiQCPiUcm228xYL95Qq(AGUgiJdKXbIkxkIRaJTn)LCzFUkwcHfnFGGFGa8Nb6WXarLlfHCd6XUN56snafKq(AGUgiQCPiKBqp29mxxQbOGelHWIMpqWpqa(ZazAGUgiJd8qOYLIyTA(3WtcUAEGgiRbYWb6WXab2apKPGYa1baqQyLBQ8lasSwn)B4PbY0azkjzEn(ojv2NRvDFrWZf519KMCQoBPkssuBOy6KUnj53qPnSKKAyQvb6sMck)Lmp6ZAaEUjO2qX0zGUg4k3HpF9vPvCOs4dDGvoqWL5d01ax5Mgi4znqNpqxdKXbIkxkc0Lmfu(lzE0N1a8CtiFnqhogO)F85R2c0Lmfu(lzE0N1a8CtSeclA(aRCGGlZhitd0HJbcSbQgMAvGUKPGYFjZJ(SgGNBcQnumDgORbUYD4ZxFvAfhQe(qhyLSgiBmmjzEn(ojbY9RxbrlIWNVwItTNsAYP6opvrsIAdftN0Tjj)gkTHLK8)JpF1wCfyST5VKl7ZvXsiSO5de8SgidtsMxJVtsRfCkFi7K0Kt1b3ufjjQnumDs3MK8BO0gwsY8AGKYuticIpWkznq2gORbY4albaqAEjew08bc(b68b6WXab2arLlfb6sMck)Lmp6ZAaEUjKVgORbY4aVivaa0lJflHWIMpqWpqa(ZaD4yGRfNmHKAvyNdxqol4kFGUg4AXjtiPwf25WflHWIMpqWpqNpqxdCT4KjKuRc7C4IOhyLd8IubaqVmwSeclA(azAGmLKmVgFNK4MFJs4ddNVmVM0Kt1zyQIKe1gkMoPBts(nuAdljzEnqszQjebXhyLdKHd0HJbUYnv(fajUar2(i(M4cQnumDssMxJVtshYuqzRp5d5n3tAsts(hj1wR8ufjNQNQijrTHIPt62KK5147K0HmfepFKPK0H4(nU047KKBFKuBToq3iAGdniEsYVHsByjjK2ggkMeCnFHTUJgWaD4yGiTnmumjSZHNxcHfDstoXwQIKe1gkMoPBts(nuAdljTYD4ZxFvAfhQe(qhyLdSUZhORb6)hF(QT4kWyBZFjx2NRILqyrZhi4hOZhORbcSbQgMAvGUKPGYFjZJ(SgGNBcQnumDgORbI02WqXKGR5lS1D0assMxJVts8Q2IiAazebxtAYjNNQijrTHIPt62KKFdL2WssaBGQHPwfOlzkO8xY8OpRb45MGAdftNb6AGiTnmumjSZHNxcHfDsY8A8DsIx1werdiJi4AstobUPkssuBOy6KUnj53qPnSKKAyQvb6sMck)Lmp6ZAaEUjO2qX0zGUgiJdevUueOlzkO8xY8OpRb45Mq(AGUgiJdePTHHIjbxZxyR7ObmqxdCL7WNV(Q0kouj8HoWkhi4Y8b6WXarAByOysyNdpVecl6b6AGRCh(81xLwXHkHp0bw5azwmFGoCmqK2ggkMe25WZlHWIEGUg4AXjtiPwf25WflHWIMpqWpWAYaDnW1ItMqsTkSZHliNfCLpqMgOdhdeydevUueOlzkO8xY8OpRb45Mq(AGUgO)F85R2c0Lmfu(lzE0N1a8CtSeclA(azkjzEn(ojXRAlIObKreCnPjNyyQIKe1gkMoPBts(nuAdlj5)hF(QT4kWyBZFjx2NRILqyrZhi4hOZhORbI02WqXKGR5lS1D0agORbY4avdtTkqxYuq5VK5rFwdWZnb1gkMod01ax5o85RVkTIdvcFOde8dKzX8b6AG()XNVAlqxYuq5VK5rFwdWZnXsiSO5de8dKTb6WXab2avdtTkqxYuq5VK5rFwdWZnb1gkModKPKK5147KKH(iI2047moqGM0KtmRufjjQnumDs3MK8BO0gwscPTHHIjHDo88siSOtsMxJVtsg6JiAtJVZ4abAstov7tvKKO2qX0jDBsYVHsByjjK2ggkMeCnFHTUJgWaDnqghO)F85R2IRaJTn)LCzFUkwcHfnFGGFGoFGoCmq1WuRIWtE7sqTHIPZazkjzEn(ojXbzEGWuwbrz5U6Vki3tAYPAxQIKe1gkMoPBts(nuAdljH02WqXKWohEEjew0jjZRX3jjoiZdeMYkikl3v)vb5EstovtsvKKO2qX0jDBsYVHsByjjGnqu5srCfyST5VKl7ZvH81aDnqGnqu5srGUKPGYFjZJ(SgGNBc5Rb6AGmoq(lJrJ(iUK5QmMY0kFPX3cQnumDgOdhdK)Yy0OpcKp20atz(JrsTkO2qX0zGmLKIwPDLV0Cuss8xgJg9rG8XMgykZFmsQ1Ku0kTR8LMdeiOtykLKQNKmVgFNKkyIdYVwrtsrR0UYxAga(rnCsQEstAs6Aj)Ja10ufjNQNQijrTHIPt62K0FLK4KgLKKFdL2Wss6gnqKk06cqgplZPmQCPmqxdKXbcSbQgMAvGUKPGYFjZJ(SgGNBcQnumDgORbY4a1nAGivO1f()XNVAloYRPX3d0npq))4ZxTfxbgBB(l5Y(CvCKxtJVhiRbY8bY0aD4yGQHPwfOlzkO8xY8OpRb45MGAdftNb6AGmoq))4ZxTfOlzkO8xY8OpRb45M4iVMgFpq38a1nAGivO1f()XNVAloYRPX3dK1az(azAGoCmq1WuRIWtE7sqTHIPZazkjDiUFJln(ojXmI0WYMs8bAdu3ObIu(a9)JpF1M9bEcKXHode19bEfySTd8ldSSpxh4VdeDjtbnWVmqE0N1a8C7oFG()XNVAlgiZUmWqVZhisdltdeKXhy)dCjew0hAh4sQ82dSo7dKWCAGlPYBpqMlyOijH02CBiOKKUrdeP56zU7TpjzEn(ojH02WqXuscPHLPmH5usI5cgMKqAyzkjvpPjNylvrsIAdftN0TjP)kjXjnkjjZRX3jjK2ggkMssiTn3gckjPB0arAMTm392NK8BO0gwss3ObIuHYMaKXZYCkJkxkd01azCGaBGQHPwfOlzkO8xY8OpRb45MGAdftNb6AGmoqDJgisfkBc))4ZxTfh51047b6MhO)F85R2IRaJTn)LCzFUkoYRPX3dK1az(azAGoCmq1WuRc0Lmfu(lzE0N1a8CtqTHIPZaDnqghO)F85R2c0Lmfu(lzE0N1a8CtCKxtJVhOBEG6gnqKku2e()XNVAloYRPX3dK1az(azAGoCmq1WuRIWtE7sqTHIPZazkjH0WYuMWCkjXCbdtsinSmLKQN0KtopvrsIAdftN0TjP)kjXjnkjj)gkTHLKa2a1nAGivO1fGmEwMtzu5szGUgOUrdePcLnbiJNL5ugvUugOdhdu3ObIuHYMaKXZYCkJkxkd01azCGmoqDJgisfkBc))4ZxTfh51047bc8bQB0arQqztGkxk5J8AA89azAGGJbY4aRly4aVzG6gnqKku2eGmEgvUueCDPgGcAGmnqWXazCGiTnmumj0nAGinZwM7E7hitdKPbw5azCGmoqDJgisfADH)F85R2IJ8AA89ab(a1nAGivO1fOYLs(iVMgFpqMgi4yGmoW6cgoWBgOUrdePcTUaKXZOYLIGRl1auqdKPbcogiJdePTHHIjHUrdeP56zU7TFGmnqMsshI734sJVtsmJCnqykXhOnqDJgis5dePHLPbI6(a9pIlBJgWavq0a9)JpF1EGFzGkiAG6gnqKY(apbY4qNbI6(avq0apYRPX3d8ldubrdevUugyOd8AFKXH4Ib6g04d0gixxQbOGgiI)eLG2bQ)abeiPbAdeuaaeTd8AJFd19bQ)a56snaf0a1nAGiLZ(an(aRsy8an(aTbI4prjODGLFhyugOnqDJgishy1aJh4VdSAGXdSFDGC3B)aRgkOb6)hF(QnxKKqABUneuss3ObI081g)gQ7jjZRX3jjK2ggkMssinSmLjmNss1tsinSmLKylPjNa3ufjjQnumDs3MK(RKeN0KK5147KesBddftjjKgwMssQHPwfamfeTrdiZ1FriO2qX0zGoCmq)3h5qfesAl7Zvb1gkMod0HJbUYnv(fajqdnAaz)JpcQnumDssiTn3gckjTvZOYLcpPjNyyQIKK5147KubtCq(1kAsIAdftN0TjnPjP18HH5PksovpvrsIAdftN0TjjZRX3jju8)NCrEDpjDiUFJln(oj5MmFy4b6grdCObXts(nuAdljHkxkIRaJTn)LCzFUkKVsAYj2svKKO2qX0jDBsYVHsByjju5srCfyST5VKl7ZvH8vsY8A8DscLwoTafnGKMCY5PkssuBOy6KUnj53qPnSKeJdeydevUuexbgBB(l5Y(CviFnqxd08AGKYuticIpWkznq2gitd0HJbcSbIkxkIRaJTn)LCzFUkKVgORbY4ax5MehQe(qhyLSgidhORbUYD4ZxFvAfhQe(qhyLSgiZI5dKPKK5147KKTERP8LmMtjn5e4MQijrTHIPt62KKFdL2WssOYLI4kWyBZFjx2NRc5RKK5147Keoaas5zMPiFaGGAnPjNyyQIKe1gkMoPBts(nuAdljHkxkIRaJTn)LCzFUkKVgORbIkxkccX1xL28k3uUkzxFlKVssMxJVtsw7jUUgo7nmoPjNywPkssuBOy6KUnj53qPnSKeQCPiUcm228xYL95Qyjew08bcEwdS2nqxdevUuexbgBB(l5Y(CviFnqxdevUueeIRVkT5vUPCvYU(wiFLKmVgFNKkXsO4)pjn5uTpvrsIAdftN0Tjj)gkTHLKqLlfXvGX2M)sUSpxfYxd01anVgiPm1eIG4dK1aRpqxdKXbIkxkIRaJTn)LCzFUkwcHfnFGGFGmCGUgOAyQvH)XNmiYwvqTHIPZaD4yGaBGQHPwf(hFYGiBvb1gkMod01arLlfXvGX2M)sUSpxflHWIMpqWpqNpqMssMxJVtsOgG8xY6gEG4jnPjjDJgis5PksovpvrsIAdftN0TjjZRX3jPO5(vwnumLRPYwRYiYhcz4PK0H4(nU047KufB0arkpj53qPnSKeQCPiUcm228xYL95Qq(AGoCmq1waKk0abL1pF51mBmFGGFGmCGoCmq0NZhORbwcaG08siSO5de8dKT6jn5eBPkssuBOy6KUnjzEn(ojPB0arA9K0H4(nU047KufGObQB0ar6aRgkObQGObckaaI46ajUgimLodePHLj2hy1aJhiknqzoDgyjwUoqRpd8YILodSAOGgiZqGX2oWVmqW595Qij53qPnSKeWgisBddftc(f5JsqNSUrdePd01arLlfXvGX2M)sUSpxfYxd01azCGaBGQHPwfHN82LGAdftNb6WXavdtTkcp5Tlb1gkMod01arLlfXvGX2M)sUSpxflHWIMpWkznW6mFGmnqxdKXbcSbQB0arQqztaY4z))4ZxThOdhdu3ObIuHYMW)p(8vBXsiSO5d0HJbI02WqXKq3ObI081g)gQ7dK1aRpqMgOdhdu3ObIuHwxGkxk5J8AA89aRK1albaqAEjew08KMCY5PkssuBOy6KUnj53qPnSKeWgisBddftc(f5JsqNSUrdePd01arLlfXvGX2M)sUSpxfYxd01azCGaBGQHPwfHN82LGAdftNb6WXavdtTkcp5Tlb1gkMod01arLlfXvGX2M)sUSpxflHWIMpWkznW6mFGmnqxdKXbcSbQB0arQqRlaz8S)F85R2d0HJbQB0arQqRl8)JpF1wSeclA(aD4yGiTnmumj0nAGinFTXVH6(aznq2gitd0HJbQB0arQqztGkxk5J8AA89aRK1albaqAEjew08KK5147KKUrdePSL0KtGBQIKe1gkMoPBtsMxJVts6gnqKwpjDiUFJln(ojXSld8BS7d8BAGFpqzonqDJgish41(iJdXhOnqu5sH9bkZPbQGOb(kiAh43d0)p(8vBXabN2bgLb2uOGODG6gnqKoWR9rghIpqBGOYLc7duMtde9vqd87b6)hF(QTij53qPnSKeWgOUrdePcTUaKXZYCkJkxkd01azCG6gnqKku2e()XNVAlwcHfnFGoCmqGnqDJgisfkBcqgplZPmQCPmqMgOdhd0)p(8vBXvGX2M)sUSpxflHWIMpWkhiBmpPjNyyQIKe1gkMoPBts(nuAdljbSbQB0arQqztaY4zzoLrLlLb6AGmoqDJgisfADH)F85R2ILqyrZhOdhdeydu3ObIuHwxaY4zzoLrLlLbY0aD4yG()XNVAlUcm228xYL95Qyjew08bw5azJ5jjZRX3jjDJgiszlPjnjH(881)4ObKQi5u9ufjjQnumDs3MKmVgFNKwcXVCctCEUA0kTjPdX9BCPX3jPBxYuqd8lduk6ZAaEUnWR)XrdyG7RMgFpWAmqUARYhyDMZhikv(Lg4TV0ad(anKwGnumLK8BO0gwsY8AGKYuticIpWkznq2gOdhdePTHHIjXwnJkxk8KMCITufjjQnumDs3MKmVgFNKEuCO0AkLK8BO0gwscvUueafyC0aYimpOOjXsMxhORb6)hF(QT4kWyBZFjx2NRILqyrZhyLd05jjV7EmLvBbqkp5u9KMCY5PkssuBOy6KUnj53qPnSKesBddftI91IpVbckjzEn(ojb6RIJgqgfBCnPjNa3ufjjQnumDs3MK8BO0gwscvUueafyC0aYimpOOjXsMxhORbUYD4ZxFvAfhQe(qhyLdKXbwNHd8MbQgMAvSYD4ZMQulBA8TGAdftNbcogidhitd01a5xegNvBbqkxu2NRCV7kiAGvoq2gORbcSbI02WqXK4qMcINpYu28AGKssMxJVtsL95k37UcIsAYjgMQijrTHIPt62KKFdL2WssRCh(81xLwXHkHp0bwjRbY4aDodh4ndunm1QyL7WNnvPw204Bb1gkModeCmqgoqMgORbYVimoR2cGuUOSpx5E3vq0aRCGSnqxdeydePTHHIjXHmfepFKPS51ajLKmVgFNKk7ZvU3DfeL0KtmRufjjQnumDs3MKmVgFNKEuCO0AkLK8BO0gwsAL7WNV(Q0kouj8HoWkznq2yysY7Uhtz1waKYtovpPjNQ9PkssuBOy6KUnj53qPnSK0k3HpF9vPvCOs4dDGGFGSX8b6AG8lcJZQTaiLlaGnFy4SDqATNgyLSgiBd01a9)JpF1wCfyST5VKl7ZvXsiSO5dSYbYWKK5147KeaS5ddNTdsR9ustov7svKKO2qX0jDBsY8A8DsQSpxZCDdGOKKFdL2WssRCh(81xLwXHkHp0bc(bYgZhORb6)hF(QT4kWyBZFjx2NRILqyrZhyLdKHjjV7EmLvBbqkp5u9KMCQMKQijrTHIPt62KKFdL2Wss()XNVAlUcm228xYL95Qyjew08bw5ax5MeAGGY6Nb3b6AGRCh(81xLwXHkHp0bc(bcUmFGUgi)IW4SAlas5cayZhgoBhKw7PbwjRbYwsY8A8Dsca28HHZ2bP1EkPjNQZ8ufjjQnumDs3MKmVgFNKk7Z1mx3aikj53qPnSKK)F85R2IRaJTn)LCzFUkwcHfnFGvoWvUjHgiOS(zWDGUg4k3HpF9vPvCOs4dDGGFGGlZtsE39ykR2cGuEYP6jnPjj7PufjNQNQijrTHIPt62K0H4(nU047KKB8zghOB6vtJVtsMxJVtslH4xoHjopxnAL2KMCITufjjQnumDs3MK8BO0gwssnm1QOSpx5E3vqKGAdftNKK5147KeaS5ddNTdsR9usto58ufjjQnumDs3MK8BO0gwscvUueafyC0aYimpOOjXsMxhORbcSbI02WqXK4qMcINpYu28AGKssMxJVtsL95k37UcIsAYjWnvrsIAdftN0Tjj)gkTHLKqAByOysSVw85nqqd01avdtTkmKg2ApisqTHIPtsY8A8Dsc0xfhnGmk24AstoXWufjjQnumDs3MK8BO0gwscydevUueBGGeYxd01anVgiPm1eIG4de8SgOZhOdhd08AGKYuticIpWkhOZtsMxJVtsaWMpmC2oiT2tjn5eZkvrsIAdftN0TjjZRX3jPY(CnZ1naIssE39ykR2cGuEYP6jj)gkTHLK8)JpF1wSeIF5eM48C1OvAflHWIMpqWZAGSnqWXab4pd01avdtTkaykiAJgqMR)IqqTHIPts6qC)gxA8DscC(xeYyl8d0UU238GgO(d0VKP0aTbEXj5ZpWRn(nu3hOAlashio46al)oq76c7E0ag4A18VHNgy0d0EkPjNQ9PkssuBOy6KUnj53qPnSKesBddftI91IpVbckjzEn(ojb6RIJgqgfBCnPjNQDPkssuBOy6KUnj53qPnSKeQCPiaykiAJgqMR)IqiFnqxd08AGKYuticIpWkhiBd01ab2arAByOysCitbXZhzkBEnqsjjZRX3jPY(CL7Dxbrjn5unjvrsIAdftN0Tjj)gkTHLKqAByOysCitbXZhzkBEnqsd01arLlfXHmfepFKjbxnpqde8deChOdhdevUueamfeTrdiZ1FriKVssMxJVtspkouAnLsAYP6mpvrsIAdftN0TjjZRX3jPY(CnZ1naIss(nuAdljTYD4ZxFvAfhQe(qhi4hiJdSodh4ndunm1QyL7WNnvPw204Bb1gkModeCmqgoqMssE39ykR2cGuEYP6jn5u96PkssuBOy6KUnj53qPnSKeWgisBddftIdzkiE(itzZRbskjzEn(ojv2NRCV7kikPjNQZwQIKe1gkMoPBtsMxJVtspkouAnLss(nuAdljTYD4ZxFvAfhQe(qhyLdKXbYgdh4ndunm1QyL7WNnvPw204Bb1gkModeCmqgoqMssE39ykR2cGuEYP6jn5uDNNQijzEn(ojbaB(WWz7G0ApLKO2qX0jDBstovhCtvKKmVgFNKk7ZvU3DfeLKO2qX0jDBstovNHPkssuBOy6KUnjzEn(ojv2NRzUUbqusY7Uhtz1waKYtovpPjNQZSsvKKmVgFNKa9BN)sUA0kTjjQnumDs3M0Kt1R9PkssMxJVts26TMY6Vl1AsIAdftN0TjnPjnjHKwE8DYj2yoB1RxN51tsvTTJgapjXm7gDtoXSDYnSgdCGvaIgyG46xDGLFh49hfhkTMgFNV(hhnG7dCPAQCS0zG8hbnqtwFeMsNb6bznaIlgWQv00azRgd0TFJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(anDGmJGt1AGmw3zmjgWgWyMDJUjNy2o5gwJboWkardmqC9RoWYVd8U)XNmiYw9(axQMkhlDgi)rqd0K1hHP0zGEqwdG4IbSAfnnW61yGU9BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJ1DgtIbSAfnnq2QXaD73iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgR7mMedy1kAAGoVgd0TFJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(azSUZysmGvROPbcU1yGU9BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJ1DgtIbSbmMz3OBYjMTtUH1yGdScq0adex)QdS87aV)O4qP10477dCPAQCS0zG8hbnqtwFeMsNb6bznaIlgWQv00aRj1yGU9BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJS5mMedydymZUr3KtmBNCdRXahyfGObgiU(vhy53bEh95zn8afnG7dCPAQCS0zG8hbnqtwFeMsNb6bznaIlgWQv00aRxJb62VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGmw3zmjgWQv00ab3Amq3(nsAv6mW7RCtLFbqcgCFG6pW7RCtLFbqcgiO2qX05(azSUZysmGnGXm7gDtoXSDYnSgdCGvaIgyG46xDGLFh4D)JKARv(9bUunvow6mq(JGgOjRpctPZa9GSgaXfdy1kAAGSvJb62VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGmw3zmjgWQv00aDEngOB)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYyDNXKyaRwrtdeCRXaD73iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgR7mMedy1kAAGmSgd0TFJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(azKnNXKyaRwrtdS2xJb62VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGmw3zmjgWQv00aRj1yGU9BK0Q0zG35Vmgn6JGb3hO(d8o)LXOrFemqqTHIPZ9bYiBoJjXa2agZSB0n5eZ2j3WAmWbwbiAGbIRF1bw(DG35Q1hBp3h4s1u5yPZa5pcAGMS(imLod0dYAaexmGvROPbYSQXaD73iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqthiZi4uTgiJ1DgtIbSAfnnWAxngOB)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYyDNXKyaRwrtdSMuJb62VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGm6CNXKyaBaJz2n6MCIz7KByng4aRaenWaX1V6al)oW7OppF9poAa3h4s1u5yPZa5pcAGMS(imLod0dYAaexmGvROPbcU1yGU9BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJ1DgtIbSAfnnqgwJb62VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGmw3zmjgWgWyMDJUjNy2o5gwJboWkardmqC9RoWYVd8(1s(hbQP3h4s1u5yPZa5pcAGMS(imLod0dYAaexmGvROPbwVgd0TFJKwLodukq42bYDVvZzd0n7MhO(dSwY2ar8hzSmFG)fTM(7az0nZ0azKnNXKyaRwrtdSEngOB)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYOZDgtIbSAfnnW61yGU9BK0Q0zG31nAGivuxWG7du)bEx3ObIuHwxWG7dKrN7mMedy1kAAGSvJb62VrsRsNbkfiC7a5U3Q5Sb6MDZdu)bwlzBGi(JmwMpW)Iwt)DGm6MzAGmYMZysmGvROPbYwngOB)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYOZDgtIbSAfnnq2QXaD73iPvPZaVRB0arQGnbdUpq9h4DDJgisfkBcgCFGm6CNXKyaRwrtd051yGU9BK0Q0zGsbc3oqU7TAoBGU5bQ)aRLSnWtGm4X3d8VO10FhiJaNPbYiBoJjXawTIMgOZRXaD73iPvPZaVRB0arQOUGb3hO(d8UUrdePcTUGb3hiJGRZysmGvROPb68Amq3(nsAv6mW76gnqKkytWG7du)bEx3ObIuHYMGb3hiJm0zmjgWQv00ab3Amq3(nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKX6oJjXawTIMgi4wJb62VrsRsNbEFLBQ8lasWG7du)bEFLBQ8lasWab1gkMo3hOPdKzeCQwdKX6oJjXawTIMgi4wJb62VrsRsNbE3)9roubdUpq9h4D)3h5qfmqqTHIPZ9bYyDNXKyaBaJz2n6MCIz7KByng4aRaenWaX1V6al)oW7()XNVAZVpWLQPYXsNbYFe0anz9rykDgOhK1aiUyaRwrtdKTAmq3(nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKX6oJjXawTIMgiB1yGU9BK0Q0zG35Vmgn6JGb3hO(d8o)LXOrFemqqTHIPZ9bYiBoJjXawTIMgOZRXaD73iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgR7mMedy1kAAGGBngOB)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bA6azgbNQ1azSUZysmGvROPbYWAmq3(nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKX6oJjXawTIMgiZQgd0TFJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(azSUZysmGvROPbw7RXaD73iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgR7mMedy1kAAG1KAmq3(nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKX6oJjXawTIMgy961yGU9BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJ1DgtIbSAfnnW6SvJb62VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGmYMZysmGvROPbwNH1yGU9BK0Q0zG3x5Mk)cGem4(a1FG3x5Mk)cGemqqTHIPZ9bA6azgbNQ1azSUZysmGnGXm7gDtoXSDYnSgdCGvaIgyG46xDGLFh4DDJgis53h4s1u5yPZa5pcAGMS(imLod0dYAaexmGvROPbYwngOB)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYiBoJjXawTIMgiB1yGU9BK0Q0zG31nAGivuxWG7du)bEx3ObIuHwxWG7dKX6oJjXawTIMgiB1yGU9BK0Q0zG31nAGivWMGb3hO(d8UUrdePcLnbdUpqgzZzmjgWQv00aDEngOB)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYiBoJjXawTIMgOZRXaD73iPvPZaVRB0arQOUGb3hO(d8UUrdePcTUGb3hiJS5mMedy1kAAGoVgd0TFJKwLod8UUrdePc2em4(a1FG31nAGivOSjyW9bYyDNXKyaRwrtdeCRXaD73iPvPZaVRB0arQOUGb3hO(d8UUrdePcTUGb3hiJ1DgtIbSAfnnqWTgd0TFJKwLod8UUrdePc2em4(a1FG31nAGivOSjyW9bYiBoJjXawTIMgidRXaD73iPvPZaVRB0arQOUGb3hO(d8UUrdePcTUGb3hiJS5mMedy1kAAGmSgd0TFJKwLod8UUrdePc2em4(a1FG31nAGivOSjyW9bYyDNXKyaBaJz2n6MCIz7KByng4aRaenWaX1V6al)oW7hQyYy9(axQMkhlDgi)rqd0K1hHP0zGEqwdG4IbSAfnnqgwJb62VrsRsNbEFLBQ8lasWG7du)bEFLBQ8lasWab1gkMo3hiJS5mMedy1kAAGmRAmq3(nsAv6mW7(VpYHkyW9bQ)aV7)(ihQGbcQnumDUpqgR7mMedy1kAAG1UAmq3(nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKr2CgtIbSAfnnWAsngOB)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bYOZDgtIbSAfnnW6mVgd0TFJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(azeCDgtIbSAfnnW61RXaD73iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqgbxNXKyaRwrtdSoZQgd0TFJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(azKnNXKyaRwrtdSETRgd0TFJKwLod8UAyQvbdUpq9h4D1WuRcgiO2qX05(azSUZysmGvROPbwVMuJb62VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGMoqMrWPAnqgR7mMedy1kAAGSX8Amq3(nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7dKX6oJjXa2agZSB0n5eZ2j3WAmWbwbiAGbIRF1bw(DG3TNUpWLQPYXsNbYFe0anz9rykDgOhK1aiUyaRwrtdKTAmq3(nsAv6mW7QHPwfm4(a1FG3vdtTkyGGAdftN7d00bYmcovRbYyDNXKyaRwrtdeCRXaD73iPvPZaVRgMAvWG7du)bExnm1QGbcQnumDUpqthiZi4uTgiJ1DgtIbSAfnnqMvngOB)gjTkDg4D1WuRcgCFG6pW7QHPwfmqqTHIPZ9bA6azgbNQ1azSUZysmGvROPbwN51yGU9BK0Q0zG3vdtTkyW9bQ)aVRgMAvWab1gkMo3hiJ1DgtIbSAfnnW6SvJb62VrsRsNbExnm1QGb3hO(d8UAyQvbdeuBOy6CFGmw3zmjgWgWy2iU(vPZaR78bAEn(EG4GRCXawsIFr(KtSXW6jPR9lbMss1wTnq3aKPGgiZ0DaaKoqW5956awTvBd0PhjHaL2bw35Spq2yoB1hWgWQTABGUfK1ai(awTvBdKzYaDteIhjDgi24kZeo5)(mqzUbGg4xgOBbzrZh4xgiZ2td04dm0bEEI331bEHn3hyvcJhy0d8AnVgEsmGvB12azMmq3aFFxhOhK1nHhi4mM4G8Rv0bEK3ObmWBxYuqd8lduk6ZAaEUjgWgWQTbYmI0WYMs8bAdu3ObIu(a9)JpF1M9bEcKXHode19bEfySTd8ldSSpxh4VdeDjtbnWVmqE0N1a8C7oFG()XNVAlgiZUmWqVZhisdltdeKXhy)dCjew0hAh4sQ82dSo7dKWCAGlPYBpqMlyOyaZ8A8nxCTK)rGA6nSaosBddftS3gcILUrdeP56zU7TN9)IfN0OWosdltSQZosdltzcZjwmxWq29FFcn(MLUrdePI6cqgplZPmQCP4IrGPgMAvGUKPGYFjZJ(SgGNBUyu3ObIurDH)F85R2IJ8AA8TB2n7)hF(QT4kWyBZFjx2NRIJ8AA8nlMZKdhQHPwfOlzkO8xY8OpRb45Mlg9)JpF1wGUKPGYFjZJ(SgGNBIJ8AA8TB2nRB0arQOUW)p(8vBXrEnn(MfZzYHd1WuRIWtE7IPbmZRX3CX1s(hbQP3Wc4iTnmumXEBiiw6gnqKMzlZDV9S)xS4Kgf2rAyzIvD2rAyzktyoXI5cgYU)7tOX3S0nAGivWMaKXZYCkJkxkUyeyQHPwfOlzkO8xY8OpRb45Mlg1nAGivWMW)p(8vBXrEnn(2n7M9)JpF1wCfyST5VKl7ZvXrEnn(MfZzYHd1WuRc0Lmfu(lzE0N1a8CZfJ()XNVAlqxYuq5VK5rFwdWZnXrEnn(2n7M1nAGivWMW)p(8vBXrEnn(MfZzYHd1WuRIWtE7IPbSABGmJCnqykXhOnqDJgis5dePHLPbI6(a9pIlBJgWavq0a9)JpF1EGFzGkiAG6gnqKY(apbY4qNbI6(avq0apYRPX3d8ldubrdevUugyOd8AFKXH4Ib6g04d0gixxQbOGgiI)eLG2bQ)abeiPbAdeuaaeTd8AJFd19bQ)a56snaf0a1nAGiLZ(an(aRsy8an(aTbI4prjODGLFhyugOnqDJgishy1aJh4VdSAGXdSFDGC3B)aRgkOb6)hF(QnxmGzEn(MlUwY)iqn9gwahPTHHIj2BdbXs3ObI081g)gQ7S)xS4Kgf2rAyzIfBSJ0WYuMWCIvD29FFcn(MfW0nAGivuxaY4zzoLrLlfx6gnqKkytaY4zzoLrLlfho0nAGivWMaKXZYCkJkxkUyKrDJgisfSj8)JpF1wCKxtJVDZ6gnqKkytGkxk5J8AA8ntGdgRly4n6gnqKkytaY4zu5srW1LAakiMahmI02WqXKq3ObI0mBzU7TNjMQKrg1nAGivux4)hF(QT4iVMgF7M1nAGivuxGkxk5J8AA8ntGdgRly4n6gnqKkQlaz8mQCPi46snafetGdgrAByOysOB0arAUEM7E7zIPbmZRX3CX1s(hbQP3Wc4iTnmumXEBiiwB1mQCPWzhPHLjwQHPwfamfeTrdiZ1Fr4WH)7JCOccjTL95QdhRCtLFbqc0qJgq2)4ZaM514BU4Aj)Ja10Byb8cM4G8Rv0bSbSAR2giZOZiVSsNbsiP19bQbcAGkiAGMx)DGbFGgslWgkMedyMxJV5Sqe9jxwIQzAaR2giZWsiPwhi)I8rjOZa1nAGiLpqukAaduMtNbwnuqd0K1hHPHFG4Oj(aM514B(nSaosBddftS3gcIf)I8rjOtw3ObIu2rAyzIfJunvoUUOJiAUFLvdft5AQS1QmI8HqgEYL)F85R2IO5(vwnumLRPYwRYiYhcz4jXs2XDMgWmVgFZVHfWrAByOyI92qqS4A(cBDhna2rAyzIL51ajLPMqeeNvDxmUwCYesQvHDoCr0vwNHoCaS1ItMqsTkSZHliNfCLZ0aM514B(nSaosBddftS3gcILDo88siSOzhPHLjwMxdKuMAcrq8kzXMlgb2AXjtiPwf25WfKZcUYD4yT4KjKuRc7C4cYzbx5UyCT4KjKuRc7C4ILqyrZRKHoCucaG08siSO5vwN5mX0aM514B(nSaosBddftS3gcI1(AXN3abXosdltSqLlfXgiiH8Llgb2k3u5xaKynau(lzfeLl7xZuN9GmexX3oCSYnv(fajwdaL)swbr5Y(1m1zpidXv8TRvUdF(6RsR4qLWhAL1oMgWmVgFZVHfWrAByOyI92qqSk7Z1mx3aik7)(ihkNDKgwMy5)(ihQGw7eEtJgqgf)vDHkxkcATt4nnAazu8xvWvZdel2C4W)9rouHCJjJdIo5YsDn7Ulu5sri3yY4GOtUSuxZUlwcHfnh8mcWFahSX0aM514B(nSaosBddftS3gcI1HmfepFKPS51ajXosdltSoKPGYwFYhYBUl0Wdu0aC5FKuBTk6aainxmAaR2gOB86c7(abN3NRdeCMqsl7deHfTArpqMT39bwHH)MpqRpdeiIUgOBIq8lNWeNpqM5OvAh4(yC0agWmVgFZVHfWxcXVCctCEUA0kTShfw(VpYHkiK0w2NRUudtTkaykiAJgqMR)IWfWudtTkEuCO0AA8Tl))4ZxTfxbgBB(l5Y(CvSeclA(aM514B(nSaoOVkoAazuSXv29U7XuwTfaPCw1zpkSoVkk7Z1CHqsRyPYsCqgkMCXOAyQvr4jVD5WbWqLlfb6sMck)Lmp6ZAaEUjKVCPgMAvGUKPGYFjZJ(SgGNBoCOgMAv8O4qP104Bx()XNVAlUcm228xYL95Qyjew0CxadvUueafyC0aYimpOOjH8ftdyMxJV53Wc4aWMpmC2oiT2tShfwOYLIi8UNvd)nxSeclAo4zbWFCPgMAveE3ZQH)M7IFryCwTfaPCbaS5ddNTdsR9uLSyZfJQHPwfHN82LdhQHPwfOlzkO8xY8OpRb45Ml))4ZxTfOlzkO8xY8OpRb45Myjew08kRZqhoudtTkEuCO0AA8TlGHkxkIRaJTn)LCzFUkKVyAaZ8A8n)gwaVSpxZCDdGi2Jclu5sreE3ZQH)MlwcHfnh8Sa4pUudtTkcV7z1WFZDXOAyQvr4jVD5WHAyQvb6sMck)Lmp6ZAaEU5cyOYLIaDjtbL)sMh9znap3eYxU8)JpF1wGUKPGYFjZJ(SgGNBILqyrZRSoZD4qnm1Q4rXHsRPX3UagQCPiUcm228xYL95Qq(IPbSABGUf0)CAGUrVgFpqCW1bQ)ax5EaZ8A8n)gwa3ByC28A8DghCL92qqS8psQTw5dyMxJV53Wc4EdJZMxJVZ4GRS3gcI1A(WW8bmZRX38BybCVHXzZRX3zCWv2BdbXs3ObIu(aM514B(nSaU3W4S5147mo4k7THGy5)hF(QnFaZ8A8n)gwa3ByC28A8DghCL92qqS8p(Kbr2QSZ1n8kR6ShfwQHPwf(hFYGiBvxmcmu5srauGXrdiJW8GIMeYxoCOgMAvGUKPGYFjZJ(SgGNBm5IXdHkxkI1Q5Fdpj4Q5bIfdD4ayhYuqzG6aaivSYnv(fajwRM)n8etdyMxJV53Wc4RCNnVgFNXbxzVneel0NN1Wdu0ayNRB4vw1zpkSqLlfb6sMck)Lmp6ZAaEUjKVgWmVgFZVHfWx5oBEn(oJdUYEBiiwOppF9poAaShfwQHPwfOlzkO8xY8OpRb45Mlg9)JpF1wGUKPGYFjZJ(SgGNBILqyrZbFDMZKlgxlozcj1QWohUi6kzJHoCaS1ItMqsTkSZHliNfCL7WH)F85R2IRaJTn)LCzFUkwcHfnh81zUR1ItMqsTkSZHliNfCL7AT4KjKuRc7C4IObFDMZ0aM514B(nSa(k3zZRX3zCWv2BdbX6rXHsRPX3SZ1n8kR6ShfwOYLI4kWyBZFjx2NRc5lxQHPwfpkouAnn(EaZ8A8n)gwaFL7S5147mo4k7THGy9O4qP104781)4ObWEuyPgMAv8O4qP104Bx()XNVAlUcm228xYL95Qyjew0CWxN5UyePTHHIjbxZxyR7Ob4WXAXjtiPwf25WfKZcUYDTwCYesQvHDoCr0GVoZD4ayRfNmHKAvyNdxqol4kNPbmZRX38Byb8vUZMxJVZ4GRS3gcIL9e7CDdVYQo7rHL51ajLPMqeeVswSnGzEn(MFdlG7nmoBEn(oJdUYEBiiwC16JTNbSbSABGUXNzCGUPxnn(EaZ8A8nxypXAje)YjmX55QrR0oGzEn(MlSNUHfWbGnFy4SDqATNypkSudtTkk7ZvU3DfenGzEn(MlSNUHfWl7ZvU3DfeXEuyHkxkcGcmoAazeMhu0KyjZRUagsBddftIdzkiE(itzZRbsAaZ8A8nxypDdlGd6RIJgqgfBCL9OWcPTHHIjX(AXN3ab5snm1QWqAyR9GObmZRX3CH90nSaoaS5ddNTdsR9e7rHfWqLlfXgiiH8LlZRbsktnHiio4z5ChomVgiPm1eIG4v68bSABGGZ)IqgBHFG211(Mh0a1FG(LmLgOnWlojF(bETXVH6(avBbq6aXbxhy53bAxxy3JgWaxRM)n80aJEG2tdyMxJV5c7PByb8Y(CnZ1naIy37Uhtz1waKYzvN9OWY)p(8vBXsi(LtyIZZvJwPvSeclAo4zXg4aG)4snm1QaGPGOnAazU(lIbmZRX3CH90nSaoOVkoAazuSXv2JclK2ggkMe7RfFEde0aM514BUWE6gwaVSpx5E3vqe7rHfQCPiaykiAJgqMR)IqiF5Y8AGKYuticIxjBUagsBddftIdzkiE(itzZRbsAaZ8A8nxypDdlG)O4qP1uI9OWcPTHHIjXHmfepFKPS51aj5cvUuehYuq88rMeC18abEW1Hdu5sraWuq0gnGmx)fHq(AaZ8A8nxypDdlGx2NRzUUbqe7E39ykR2cGuoR6ShfwRCh(81xLwXHkHpuWZyDgEJAyQvXk3HpBQsTSPX3GdgY0aM514BUWE6gwaVSpx5E3vqe7rHfWqAByOysCitbXZhzkBEnqsdyMxJV5c7PByb8hfhkTMsS7D3JPSAlas5SQZEuyTYD4ZxFvAfhQe(qRKr2y4nQHPwfRCh(SPk1YMgFdoyitdyMxJV5c7PBybCayZhgoBhKw7PbmZRX3CH90nSaEzFUY9URGObmZRX3CH90nSaEzFUM56garS7D3JPSAlas5SQpGzEn(MlSNUHfWb9BN)sUA0kTdyMxJV5c7PBybCB9wtz93LADaBaR2g4TlzkOb(Lbkf9znap3g41)4ObmW9vtJVhyngixTv5dSoZ5deLk)sd82xAGbFGgslWgkMgWmVgFZfOppF9poAaSwcXVCctCEUA0kTShfwMxdKuMAcrq8kzXMdhiTnmumj2Qzu5sHpGzEn(MlqFE(6FC0aUHfWFuCO0AkXU3DpMYQTaiLZQo7rHfQCPiakW4ObKryEqrtILmV6Y)p(8vBXvGX2M)sUSpxflHWIMxPZhWmVgFZfOppF9poAa3Wc4G(Q4ObKrXgxzpkSqAByOysSVw85nqqdyMxJV5c0NNV(hhnGByb8Y(CL7DxbrShfwOYLIaOaJJgqgH5bfnjwY8QRvUdF(6RsR4qLWhALmwNH3OgMAvSYD4ZMQulBA8n4GHm5IFryCwTfaPCrzFUY9URGOkzZfWqAByOysCitbXZhzkBEnqsdyMxJV5c0NNV(hhnGByb8Y(CL7DxbrShfwRCh(81xLwXHkHp0kzXOZz4nQHPwfRCh(SPk1YMgFdoyitU4xegNvBbqkxu2NRCV7kiQs2CbmK2ggkMehYuq88rMYMxdK0awTvBd8UAlasZrHfcZz1GXdHkxkI1Q5Fdpj4Q5b6M6m5Mz8qOYLIyTA(3WtILqyrZVPotGJdzkOmqDaaKkw5Mk)cGeRvZ)gE6(aDt0fzkFG2aXVY(avqbFGbFGrRuFOZa1FGQTaiDGkiAGGcaGiUoWRn(nu3hi1ec3hy1qbnqRhOHg4qDFGkithy1aJhODDHDFGRvZ)gEAGrzGRCtLFbqhXaRaKPdeLIgWaTEGutiCFGvdf0az(a5Q5bIZ(a)DGwpqQjeUpqfKPdubrd8qOYLYaRgy8a5)3dKC2vS0a)wmGzEn(MlqFE(6FC0aUHfWFuCO0AkXU3DpMYQTaiLZQo7rH1k3HpF9vPvCOs4dTswSXWbmZRX3Cb6ZZx)JJgWnSaoaS5ddNTdsR9e7rH1k3HpF9vPvCOs4df8SXCx8lcJZQTaiLlaGnFy4SDqATNQKfBU8)JpF1wCfyST5VKl7ZvXsiSO5vYWbmZRX3Cb6ZZx)JJgWnSaEzFUM56garS7D3JPSAlas5SQZEuyTYD4ZxFvAfhQe(qbpBm3L)F85R2IRaJTn)LCzFUkwcHfnVsgoGzEn(MlqFE(6FC0aUHfWbGnFy4SDqATNypkS8)JpF1wCfyST5VKl7ZvXsiSO5vUYnj0abL1pdUUw5o85RVkTIdvcFOGhCzUl(fHXz1waKYfaWMpmC2oiT2tvYITbmZRX3Cb6ZZx)JJgWnSaEzFUM56garS7D3JPSAlas5SQZEuy5)hF(QT4kWyBZFjx2NRILqyrZRCLBsObckRFgCDTYD4ZxFvAfhQe(qbp4Y8bSbSABG3UKPGg4xgOu0N1a8CBGUrVgiPb6ME1047bmZRX3Cb6ZZA4bkAaSEuCO0AkXU3DpMYQTaiLZQo7rH1k3HpF9vPvCOs4dTswmcUm8g1WuRIvUdF2uLAztJVbhmKPbmZRX3Cb6ZZA4bkAa3Wc4lH4xoHjopxnALw2JclK2ggkMeB1mQCPWD4W8AGKYuticIxjl2C4yL7WNV(Q0cENZ2aM514BUa95zn8afnGByb8dzkOS1N8H8M7ShfwRCh(81xLwW7C2gWmVgFZfOppRHhOObCdlGd6RIJgqgfBCL9OWcPTHHIjX(AXN3ab5IXvUdF(6RsR4qLWhk4zidD4yLBsObckRF25GNfa)XHJvUPYVaiXAaO8xYkikx2VMPo7bziUIVD4GFryCwTfaPCbOVkoAazuSX1kzXMdhOYLIydeKyjew0CW7CMC4yL7WNV(Q0cENZ2aM514BUa95zn8afnGByb8Y(CL7DxbrShfwOYLIaOaJJgqgH5bfnjKVCXVimoR2cGuUOSpx5E3vquLS5cyiTnmumjoKPG45JmLnVgiPbmZRX3Cb6ZZA4bkAa3Wc4pkouAnLy37Uhtz1waKYzvN9OWcvUueafyC0aYimpOOjXsMxhWmVgFZfOppRHhOObCdlGd63o)LC1OvAzpkSw5o85RVkTIdvcFOvYcCzURvUjHgiOS(zNxja)zaZ8A8nxG(8SgEGIgWnSaEzFUY9URGi2Jcl(fHXz1waKYfL95k37UcIQKnxadPTHHIjXHmfepFKPS51ajnGzEn(MlqFEwdpqrd4gwa)rXHsRPe7E39ykR2cGuoR6ShfwRCh(81xLwXHkHp0kzJHoCSYnj0abL1p7CWdWFgWmVgFZfOppRHhOObCdlGd6RIJgqgfBCL9OWcPTHHIjX(AXN3abnGzEn(MlqFEwdpqrd4gwa3wV1uw)DPwzpkSw5o85RVkTIdvcFOvYqMpGnGvB12aD7Jpd0nizRoq3(9j04B(awTvBd08A8nx4F8jdISvz5bzrZZFjhEI9OWQeaaP5LqyrZbpa)XfJRCtGNnhoagQCPiakW4ObKryEqrtc5lxmcmew0zqwFeSbYfQCPi8p(Kbr2QcUAEGQKf4EZk3u5xaKaOhRXA8CXq(RdhiSOZGS(iydKlu5sr4F8jdISvfC18avzT7MvUPYVaibqpwJ145IH8xMC4avUueafyC0aYimpOOjH8Llgbgcl6miRpc2a5cvUue(hFYGiBvbxnpqvw7UzLBQ8lasa0J1ynEUyi)1Hdew0zqwFeSbYfQCPi8p(Kbr2QcUAEGQSoZVzLBQ8lasa0J1ynEUyi)LjMgWQTbYmvonWJ8gnGbYmeySTdSAOGgiZ2tE7c43UKPGgWmVgFZf(hFYGiB1BybCpilAE(l5WtShfwatnm1Q4rXHsRPX3UqLlfXvGX2M)sUSpxfYxUqLlfH)XNmiYwvWvZduLSQZCxmIkxkIRaJTn)LCzFUkwcHfnh8a8hWbJ1VX)p(8vBrzFUw19fbpxKx3flzh3zYHdu5sri3GES7zUUudqbjwcHfnh8a8hhoqLlfHhK98mQ1Kyjew0CWdWFyAaR2gi4KSYJdnWVmqMHaJTDGYCYaqdSAOGgiZ2tE7c43UKPGgWmVgFZf(hFYGiB1BybCpilAE(l5WtShfwatnm1Q4rXHsRPX3UoKPGYa1baqQyLBQ8lasummM6SFL52HwxadvUuexbgBB(l5Y(CviF5Y)p(8vBXvGX2M)sUSpxflHWIMxzDg6Iru5sr4F8jdISvfC18avjR6m3fJOYLIqUb9y3ZCDPgGcsiF5WbQCPi8GSNNrTMeYxm5WbQCPi8p(Kbr2QcUAEGQKvDNZ0aM514BUW)4tgezREdlG7bzrZZFjhEI9OWcyQHPwfpkouAnn(2fWoKPGYa1baqQyLBQ8lasummM6SFL52HwxOYLIW)4tgezRk4Q5bQsw1zUlGHkxkIRaJTn)LCzFUkKVC5)hF(QT4kWyBZFjx2NRILqyrZRKnMpGvBdKzyjKuRd0Tp(mq3GKT6aFK06TRRObmWJ8gnGbEfySTdyMxJV5c)JpzqKT6nSaUhKfnp)LC4j2Jcl1WuRIhfhkTMgF7cyOYLI4kWyBZFjx2NRc5lxmIkxkc)JpzqKTQGRMhOkzvhCDXiQCPiKBqp29mxxQbOGeYxoCGkxkcpi75zuRjH8ftoCGkxkc)JpzqKTQGRMhOkzvVM4WH)F85R2IRaJTn)LCzFUkwcHfnh8o3fQCPi8p(Kbr2QcUAEGQKvDWLPbSbSABGmdVgFpGzEn(Ml8)JpF1MZ6614B2Jclu5srCfyST5VKl7ZvH81awTnq3(p(8vB(aM514BUW)p(8vB(nSaoH46RsBELBkxLSRVzpkSudtTkEuCO0AA8TRvUjWZSCXisBddftcUMVWw3rdWHdK2ggkMe25WZlHWIMjxm6)hF(QT4kWyBZFjx2NRILqyrZbpdDXO)F85R2IcM4G8RvuXsiSO5vYqx8xgJg9rCjZvzmLPv(sJVD4ay8xgJg9rCjZvzmLPv(sJVzYHdu5srCfyST5VKl7ZvH8ftoCG(CURsaaKMxcHfnh8SX8bmZRX3CH)F85R28BybCcX1xL28k3uUkzxFZEuyPgMAvGUKPGYFjZJ(SgGNBUw5o85RVkTIdvcFOv6CM7ALBsObckRFMHvcWFCXiQCPiqxYuq5VK5rFwdWZnH8LdhLaainVeclAo4zJ5mnGzEn(Ml8)JpF1MFdlGtiU(Q0Mx5MYvj76B2Jcl1WuRIWtE7AaZ8A8nx4)hF(Qn)gwa)kWyBZFjx2NRShfwQHPwfOlzkO8xY8OpRb45MlgrAByOysW18f26oAaoCG02WqXKWohEEjew0m5Ir))4ZxTfOlzkO8xY8OpRb45Myjew0Cho8)JpF1wGUKPGYFjZJ(SgGNBILSJ7Uw5o85RVkTIdvcFOGNHmNPbmZRX3CH)F85R28Byb8RaJTn)LCzFUYEuyPgMAveEYBxUagQCPiUcm228xYL95Qq(AaZ8A8nx4)hF(Qn)gwa)kWyBZFjx2NRShfwQHPwfpkouAnn(21k3HpF9vPTswSXqxmI02WqXKGR5lS1D0aC4aPTHHIjHDo88siSOzYfJQHPwfamfeTrdiZ1FriO2qX0XfQCPiwcXVCctCEUA0kTc5lhoaMAyQvbatbrB0aYC9xecQnumDyAaZ8A8nx4)hF(Qn)gwahDjtbL)sMh9znap3ypkSqLlfXvGX2M)sUSpxfYxdyMxJV5c))4ZxT53Wc4L95Av3xe8CrEDN9OWY8AGKYuticIZQUlu5srCfyST5VKl7ZvXsiSO5GhG)4cvUuexbgBB(l5Y(CviF5cyQHPwfpkouAnn(2fJaBT4KjKuRc7C4cYzbx5oCSwCYesQvHDoCr0v6CMZKdhLaainVeclAo4D(aM514BUW)p(8vB(nSaEzFUw19fbpxKx3zpkSmVgiPm1eIG4vYInxmIkxkIRaJTn)LCzFUkKVC4yT4KjKuRc7C4cYzbx5Uwlozcj1QWohUi6k9)JpF1wCfyST5VKl7ZvXsiSO53u7zYfJOYLI4kWyBZFjx2NRILqyrZbpa)XHJ1ItMqsTkSZHliNfCL7AT4KjKuRc7C4ILqyrZbpa)HPbmZRX3CH)F85R28Byb8Y(CTQ7lcEUiVUZEuyPgMAv8O4qP104BxOYLI4kWyBZFjx2NRc5lxmYiQCPiUcm228xYL95Qyjew0CWdWFC4avUueYnOh7EMRl1auqc5lxOYLIqUb9y3ZCDPgGcsSeclAo4b4pm5IXdHkxkI1Q5Fdpj4Q5bIfdD4ayhYuqzG6aaivSYnv(fajwRM)n8etmnGzEn(Ml8)JpF1MFdlGdY9RxbrlIWNVwItTNypkSudtTkqxYuq5VK5rFwdWZnxRCh(81xLwXHkHp0kbxM7ALBc8SCUlgrLlfb6sMck)Lmp6ZAaEUjKVC4W)p(8vBb6sMck)Lmp6ZAaEUjwcHfnVsWL5m5WbWudtTkqxYuq5VK5rFwdWZnxRCh(81xLwXHkHp0kzXgdhWmVgFZf()XNVAZVHfWxl4u(q2H9OWY)p(8vBXvGX2M)sUSpxflHWIMdEwmCaZ8A8nx4)hF(Qn)gwaNB(nkHpmC(Y8k7rHL51ajLPMqeeVswS5IXsaaKMxcHfnh8o3HdGHkxkc0Lmfu(lzE0N1a8CtiF5IXlsfaa9YyXsiSO5GhG)4WXAXjtiPwf25WfKZcUYDTwCYesQvHDoCXsiSO5G35Uwlozcj1QWohUi6kVivaa0lJflHWIMZetdyMxJV5c))4ZxT53Wc4hYuqzRp5d5n3zpkSmVgiPm1eIG4vYqhow5Mk)cGexGiBFeFt8bSbSABGU9rsT16aDJObo0G4dyMxJV5c)JKARvoRdzkiE(itShfwiTnmumj4A(cBDhnahoqAByOysyNdpVecl6bmZRX3CH)rsT1k)gwaNx1werdiJi4k7rH1k3HpF9vPvCOs4dTY6o3L)F85R2IRaJTn)LCzFUkwcHfnh8o3fWudtTkqxYuq5VK5rFwdWZnxiTnmumj4A(cBDhnGbmZRX3CH)rsT1k)gwaNx1werdiJi4k7rHfWudtTkqxYuq5VK5rFwdWZnxiTnmumjSZHNxcHf9aM514BUW)iP2ALFdlGZRAlIObKreCL9OWsnm1QaDjtbL)sMh9znap3CXiQCPiqxYuq5VK5rFwdWZnH8LlgrAByOysW18f26oAaUw5o85RVkTIdvcFOvcUm3HdK2ggkMe25WZlHWI21k3HpF9vPvCOs4dTsMfZD4aPTHHIjHDo88siSODTwCYesQvHDoCXsiSO5GVM4AT4KjKuRc7C4cYzbx5m5WbWqLlfb6sMck)Lmp6ZAaEUjKVC5)hF(QTaDjtbL)sMh9znap3elHWIMZ0aM514BUW)iP2ALFdlGBOpIOnn(oJdeOShfw()XNVAlUcm228xYL95Qyjew0CW7CxiTnmumj4A(cBDhnaxmQgMAvGUKPGYFjZJ(SgGNBUw5o85RVkTIdvcFOGNzXCx()XNVAlqxYuq5VK5rFwdWZnXsiSO5GNnhoaMAyQvb6sMck)Lmp6ZAaEUX0aM514BUW)iP2ALFdlGBOpIOnn(oJdeOShfwiTnmumjSZHNxcHf9aM514BUW)iP2ALFdlGZbzEGWuwbrz5U6Vki3zpkSqAByOysW18f26oAaUy0)p(8vBXvGX2M)sUSpxflHWIMdEN7WHAyQvr4jVDX0aM514BUW)iP2ALFdlGZbzEGWuwbrz5U6Vki3zpkSqAByOysyNdpVecl6bmZRX3CH)rsT1k)gwaVGjoi)AfL9OWcyOYLI4kWyBZFjx2NRc5lxadvUueOlzkO8xY8OpRb45Mq(YfJ8xgJg9rCjZvzmLPv(sJVD4G)Yy0OpcKp20atz(JrsTYe7rR0UYxAoqGGoHPeR6ShTs7kFPza4h1WSQZE0kTR8LMJcl(lJrJ(iq(ytdmL5pgj16a2awTnqWjuCO0AA89a3xnn(EaZ8A8nx8O4qP104BwlH4xoHjopxnALw2JclZRbsktnHiiELSCUlK2ggkMeB1mQCPWhWmVgFZfpkouAnn((gwah0xfhnGmk24k7rHfWqLlfbqbghnGmcZdkAsiF5ALBQswo3fJOYLIydeKyjew0CW7CxOYLIydeKq(YHdZRbskFEvu2NR5cHKwWBEnqszQjebXzAaZ8A8nx8O4qP1047BybCayZhgoBhKw7j2JclGHkxkcGcmoAazeMhu0Kq(Yf)IW4SAlas5cayZhgoBhKw7PkzXMdhadvUueafyC0aYimpOOjH8LlgpeQCPiwRM)n8KGRMhiWZqhooeQCPiwRM)n8Kyjew0CWdWFahGltdyMxJV5IhfhkTMgFFdlGx2NRCV7kiI9OWcvUueafyC0aYimpOOjXsMxDXVimoR2cGuUOSpx5E3vquLS5cyiTnmumjoKPG45JmLnVgiPbmZRX3CXJIdLwtJVVHfWFuCO0AkXU3DpMYQTaiLZQo7rHfQCPiakW4ObKryEqrtILmVoGzEn(MlEuCO0AA89nSaEzFUM56garShfwMxdKuMAcrqCw1DH02WqXKOSpxZCDdGOS)7JCO8bmZRX3CXJIdLwtJVVHfWb9vXrdiJInUYEuyH02WqXKyFT4ZBGGCXVimoR2cGuUa0xfhnGmk24ALSyBaZ8A8nx8O4qP1047BybCayZhgoBhKw7j2Jcl(fHXz1waKYfaWMpmC2oiT2tvYITbmZRX3CXJIdLwtJVVHfWl7Z1mx3aiIDV7EmLvBbqkNvD2JclGPgMAvyinS1EqKlGHkxkcGcmoAazeMhu0Kq(YHd1WuRcdPHT2dICbmK2ggkMe7RfFEdeKdhiTnmumj2xl(8giixRCtcnqqz9ZSvjla(ZaM514BU4rXHsRPX33Wc4G(Q4ObKrXgxzpkSqAByOysSVw85nqqdyMxJV5IhfhkTMgFFdlG)O4qP1uIDV7EmLvBbqkNv9bSbSABGmd)JJgWabN)DGGtO4qP1047Amqj1wLpW6mFGCY)9HpquQ8lnqMHaJTDGFzGGZ7Z1b6FeeFGFPmq36gyaZ8A8nx8O4qP104781)4ObWAje)YjmX55QrR0YEuyH02WqXKyRMrLlfUdhMxdKuMAcrq8kzX2aM514BU4rXHsRPX35R)Xrd4gwaha28HHZ2bP1EI9OWIFryCwTfaPCbaS5ddNTdsR9uLSyZLAyQvrzFUY9URGObmZRX3CXJIdLwtJVZx)JJgWnSaEzFUY9URGi2Jclu5srauGXrdiJW8GIMelzE1L51ajLPMqeeVs2CbmK2ggkMehYuq88rMYMxdK0aM514BU4rXHsRPX35R)Xrd4gwa)rXHsRPe7E39ykR2cGuoR6ShfwOYLIaOaJJgqgH5bfnjwY86aM514BU4rXHsRPX35R)Xrd4gwaVSpxZCDdGi2JclZRbsktnHiioR6UqAByOysu2NRzUUbqu2)9rou(aM514BU4rXHsRPX35R)Xrd4gwa)rXHsRPe7E39ykR2cGuoR6ShfwOYLIaOaJJgqgH5bfnjwY86aM514BU4rXHsRPX35R)Xrd4gwah0xfhnGmk24k7rHfsBddftI91IpVbcAaZ8A8nx8O4qP104781)4ObCdlGdaB(WWz7G0ApXEuyXVimoR2cGuUaa28HHZ2bP1EQswS5AL7WNV(Q0kouj8HcEMfZhWmVgFZfpkouAnn(oF9poAa3Wc4L95AMRBaeXU3DpMYQTaiLZQo7rH1k3HpF9vPvCOs4df81EMpGzEn(MlEuCO0AA8D(6FC0aUHfWFuCO0AkXU3DpMYQTaiLZQo7rH1k3uLSC(aM514BU4rXHsRPX35R)Xrd4gwaVSpx5E3vqe7rHL51ajLPMqeeVswGRlGH02WqXK4qMcINpYu28AGKgWgWQTb6MmFy4b6grdCObXhWmVgFZfR5ddZzHI))KlYR7ShfwOYLI4kWyBZFjx2NRc5RbmZRX3CXA(WW8BybCuA50cu0aypkSqLlfXvGX2M)sUSpxfYxdyMxJV5I18HH53Wc426TMYxYyoXEuyXiWqLlfXvGX2M)sUSpxfYxUmVgiPm1eIG4vYInMC4ayOYLI4kWyBZFjx2NRc5lxmUYnjouj8Hwjlg6AL7WNV(Q0kouj8HwjlMfZzAaZ8A8nxSMpmm)gwahhaaP8mZuKpaqqTYEuyHkxkIRaJTn)LCzFUkKVgWmVgFZfR5ddZVHfWT2tCDnC2Bym7rHfQCPiUcm228xYL95Qq(YfQCPiiexFvAZRCt5QKD9Tq(AaZ8A8nxSMpmm)gwaVelHI))WEuyHkxkIRaJTn)LCzFUkwcHfnh8SQDUqLlfXvGX2M)sUSpxfYxUqLlfbH46RsBELBkxLSRVfYxdyMxJV5I18HH53Wc4OgG8xY6gEG4ShfwOYLI4kWyBZFjx2NRc5lxMxdKuMAcrqCw1DXiQCPiUcm228xYL95Qyjew0CWZqxQHPwf(hFYGiBvb1gkMooCam1WuRc)JpzqKTQGAdfthxOYLI4kWyBZFjx2NRILqyrZbVZzAaBaR2gOKA9X2Za5rdatmtuBbq6a3xnn(EaZ8A8nxWvRp2EyTeIF5eM48C1OvAzpkSqAByOysSvZOYLcFaZ8A8nxWvRp2EUHfWFuCO0AkXEuyHkxkcGcmoAazeMhu0KyjZRdyMxJV5cUA9X2ZnSaoOVkoAazuSXv2JclK2ggkMe7RfFEdeKlu5srSbcsSeclAo4D(aM514BUGRwFS9CdlGx2NRzUUbqe7rHfsBddftIY(CnZ1naIY(VpYHYhWmVgFZfC16JTNBybCayZhgoBhKw7j2JclGDitbLbQdaGuXk3u5xaKyTA(3WtUy8qOYLIyTA(3WtcUAEGapdD44qOYLIyTA(3WtILqyrZbpa)bCaUmnGzEn(Ml4Q1hBp3Wc4L95AMRBaeXEuy5)hF(QTyje)YjmX55QrR0kwcHfnh8SydCaWFCPgMAvaWuq0gnGmx)fXaM514BUGRwFS9CdlGd6RIJgqgfBCL9OWcPTHHIjX(AXN3abnGzEn(Ml4Q1hBp3Wc4L95AMRBaeXEuyTYD4ZxFvAfhQe(qbpJ1z4nQHPwfRCh(SPk1YMgFdoyitdyMxJV5cUA9X2ZnSa(JIdLwtj2JclGHkxkIY(1m15lzmNeYxUudtTkk7xZuNVKXCYHdK2ggkMehYuq88rMYMxdKKlu5srCitbXZhzsWvZde4bxhoudtTkaykiAJgqMR)IWfQCPiwcXVCctCEUA0kTc5lhow5o85RVkTIdvcFOvYiBm8g1WuRIvUdF2uLAztJVbhmKPbmZRX3CbxT(y75gwaVSpxZCDdGObmZRX3CbxT(y75gwah0VD(l5QrR0oGzEn(Ml4Q1hBp3Wc426TMY6Vl16a2awTnWk2ObIu(aM514BUq3ObIuoRO5(vwnumLRPYwRYiYhcz4j2Jclu5srCfyST5VKl7ZvH8LdhQTaivObckRF(YRz2yo4zOdhOpN7QeaaP5LqyrZbpB1hWQTbwbiAG6gnqKoWQHcAGkiAGGcaGiUoqIRbctPZarAyzI9bwnW4bIsduMtNbwILRd06ZaVSyPZaRgkObYmeySTd8ldeCEFUkgWmVgFZf6gnqKYVHfW1nAGiTo7rHfWqAByOysWViFuc6K1nAGi1fQCPiUcm228xYL95Qq(YfJatnm1Qi8K3UC4qnm1Qi8K3UCHkxkIRaJTn)LCzFUkwcHfnVsw1zotUyey6gnqKkytaY4z))4ZxTD4q3ObIubBc))4ZxTflHWIM7WbsBddftcDJgisZxB8BOUZQotoCOB0arQOUavUuYh51047kzvcaG08siSO5dyMxJV5cDJgis53Wc46gnqKYg7rHfWqAByOysWViFuc6K1nAGi1fQCPiUcm228xYL95Qq(YfJatnm1Qi8K3UC4qnm1Qi8K3UCHkxkIRaJTn)LCzFUkwcHfnVsw1zotUyey6gnqKkQlaz8S)F85R2oCOB0arQOUW)p(8vBXsiSO5oCG02WqXKq3ObI081g)gQ7SyJjho0nAGivWMavUuYh51047kzvcaG08siSO5dy12az2Lb(n29b(nnWVhOmNgOUrdePd8AFKXH4d0giQCPW(aL50avq0aFfeTd87b6)hF(QTyGGt7aJYaBkuq0oqDJgish41(iJdXhOnqu5sH9bkZPbI(kOb(9a9)JpF1wmGzEn(Ml0nAGiLFdlGRB0arAD2JclGPB0arQOUaKXZYCkJkxkUyu3ObIubBc))4ZxTflHWIM7WbW0nAGivWMaKXZYCkJkxkm5WH)F85R2IRaJTn)LCzFUkwcHfnVs2y(aM514BUq3ObIu(nSaUUrdePSXEuybmDJgisfSjaz8SmNYOYLIlg1nAGivux4)hF(QTyjew0ChoaMUrdePI6cqgplZPmQCPWKdh()XNVAlUcm228xYL95Qyjew08kzJ5jnPPe]] )


end
