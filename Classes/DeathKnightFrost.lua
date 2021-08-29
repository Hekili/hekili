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


    spec:RegisterPack( "Frost DK", 20210829, [[d40t3cqiqHhjrIlrvrSjQQ(KsPrbHofuyvqa9kjkZcQQBbbc7IOFbkzyqroMsXYGQ8mjOMguuUge02Ga13KijJJQe15GIQwNeK5bk6EqL9jrCqQsWcLO6HuvyIuLiCrOOIncbWhPkrAKuLi6KuLqRee9siquZuIu7KQu)ecKgkeGwkvfPNsOPkbUkeiIVcfvASGsTxH(RGbdCyklgspMktwjxgzZs6ZG0ObvNw0QHar61GWSr52q0UL63QA4kvhxIKA5Q8CunDsxNGTdL(UeA8uL05PQ06PQOMpvX(vCCtSGO4Yuk6nEycVnyYlJhMxUbbJqm)geCuu9DNII7MdcdkffBdjffraUNRdWlbcYrXDZx2BRybrr(lCokkcx1DEHGfSGMkCbuP7rclEIuGzA(T7SQclEI0bROiQqYuVyhrJIltPO34Hj82GjVmEyE5gemcX8Bqyu0eu4)ffftK(ikcpxlQJOrXfXDrrVeKPWhacYDcfUoaeG756aPxqaQaxhaEyE8haEycVndKdK(aU1qj(ajcIb4tjKpwAnaMXveeCY99AacCdknGVoaFa3YMpGVoaVOJgGXhqQdy9eV3QdyNz(oGIeJnGShW(zonDKCGebXa8s89wDao4w3eBaiamId3DwvhWs4Yg6ak)itHpGVoaXSxNb95MmkYsUYJfefFuwQ0zA(Dy)Fw2qJfe9EtSGOi1gkJwXYJIMtZVJIhH8poXiopumBLUO4I4Ul3187Oic4)SSHoaeG)gackklv6mn)UqdquTt5dydMgaNCFV4daLQ)rdabmzm7gWxhacW9CDaUhjXhWxRdWhEjIIUlv6slkI1U0qzK8kgqfQv(a84zaMttSuGAczs8bucUbGxuJEJxSGOi1gkJwXYJIUlv6slkAonXsbQjKjXhaUbSza(haw7sdLrY69CnW1lHGcUVxcPYJIMtZVJI175AGRxcbf1O3fowquKAdLrRy5rrZP53rXhLLkDMsrr3LkDPffrfQvjejJLn0asZbpBsEK50OOZxhJcQDqjLh9EtuJEJzXcIIuBOmAflpk6UuPlTOiw7sdLrY71QlCjskkAon)okc)lYYgAaLzCnQrVrySGOi1gkJwXYJIUlv6slkY3jglO2bLuUekZCPXc2cR1oAaLGBa4na)d4e60f2)I0jxunDPoayoaemMIIMtZVJIqzMlnwWwyT2rrn6ncowquKAdLrRy5rrZP53rX69CnW1lHGIIUlv6slkEcD6c7Fr6KlQMUuhamhqPctrrNVogfu7Gskp69MOg9UufliksTHYOvS8OO5087O4JYsLotPOO7sLU0IINqtdOeCdOWrrNVogfu7Gskp69MOg92lhliksTHYOvS8OO7sLU0IIMttSuGAczs8bucUbGzdW)aGXaWAxAOmsUitHZdlbkyonXsrrZP53rX69CL78vHtrnQrr3Zwb4KDASGO3BIfefP2qz0kwEu0CA(Du0b3YMh(AiDuuCrC3L7A(DuebjCAalHlBOdabmzm7gqXuHpaVOJC2oSk)itHhfDxQ0Lwuegdqng1Q8rzPsNP53sQnugTgG)bGkuRY9KXSl81q9EUkf2hG)bGkuRs3Zwb4KDQKRMdIbucUbSbtdW)aqCaOc1QCpzm7cFnuVNRYJqAzZhamhau3AaiWbG4a2mGYgG7F26l2Y69CTOVhsEOkC(kpYw(oamgGhpdavOwLcn8N5BGRh1qv4YJqAzZhamhau3AaE8mauHAv6GBppGAnjpcPLnFaWCaqDRbGruJEJxSGOi1gkJwXYJIMtZVJIo4w28WxdPJIIlI7UCxZVJIiOckpx0a(6aqatgZUbiWjdknGIPcFaErh5SDyv(rMcpk6UuPlTOimgGAmQv5JYsLotZVLuBOmAna)dyrMcparNqHRYtOP6Fqjz1ymQdUtGBl6gG)baJbGkuRY9KXSl81q9EUkf2hG)b4(NT(ITCpzm7cFnuVNRYJqAzZhqjdydchG)bG4aqfQvP7zRaCYovYvZbXakb3a2GPb4FaioauHAvk0WFMVbUEudvHlf2hGhpdavOwLo42ZdOwtsH9bGXa84zaOc1Q09SvaozNk5Q5GyaLGBaBk8aWiQrVlCSGOi1gkJwXYJIUlv6slkcJbOgJAv(OSuPZ08Bj1gkJwdW)aGXawKPWdq0ju4Q8eAQ(huswngJ6G7e42IUb4FaOc1Q09SvaozNk5Q5GyaLGBaBW0a8paymauHAvUNmMDHVgQ3ZvPW(a8pa3)S1xSL7jJzx4RH69CvEeslB(akza4HPOO5087OOdULnp81q6OOg9gZIfefP2qz0kwEu0CA(Du0b3YMh(AiDuuCrC3L7A(Dueb8iSuRdWhpBnaVKKD6aES05S99SHoGLWLn0bSNmMDrr3LkDPffvJrTkFuwQ0zA(TKAdLrRb4FaWyaOc1QCpzm7cFnuVNRsH9b4FaioauHAv6E2kaNStLC1CqmGsWnGny2a8paehaQqTkfA4pZ3axpQHQWLc7dWJNbGkuRshC75buRjPW(aWyaE8mauHAv6E2kaNStLC1CqmGsWnGny(b4XZaC)ZwFXwUNmMDHVgQ3Zv5riTS5daMdOWdW)aqfQvP7zRaCYovYvZbXakb3a2GzdaJOg1O4JYsLotZVJfe9EtSGOi1gkJwXYJIMtZVJIhH8poXiopumBLUO4I4Ul3187Oickklv6mn)Ea3RMMFhfDxQ0Lwu0CAILcutitIpGsWnGcpa)daRDPHYi5vmGkuR8Og9gVybrrQnugTILhfnNMFhfH)fzzdnGYmUgfDxQ0Lwuegdy9QSEpxdvclDsnDqKn0b4FaWyaOc1QeIKXYgAaP5GNnjf2hG)bCcnnGsWnGchfD(6yuqTdkP8O3BIA07chliksTHYOvS8OO7sLU0IIOc1QeIKXYgAaP5GNnjpYC6a8pa(oXyb1oOKYL175k35RcNgqj4gaEdW)aGXaWAxAOmsUitHZdlbkyonXsrrZP53rX69CL78vHtrn6nMfliksTHYOvS8OO5087O4JYsLotPOO7sLU0IIOc1QeIKXYgAaP5GNnjpYCAu05RJrb1oOKYJEVjQrVrySGOi1gkJwXYJIUlv6slkY3jglO2bLuUekZCPXc2cR1oAaLGBa4na)daXbCcD6c7Fr6KlQMUuhamhWgmnapEgWj0KutKuq)aEdOKba1TgagdWJNbG4aweQqTkpZN)lDKKRMdIbaZbGWb4XZaweQqTkpZN)lDK8iKw28baZbSbHdaJOO5087OiuM5sJfSfwRDuuJEJGJfefP2qz0kwEu0DPsxArrZPjwkqnHmj(aWnGndW)aWAxAOmswVNRbUEjeuW99sivEu0CA(DuSEpxdC9siOOg9UufliksTHYOvS8OO7sLU0IIyTlnugjVxRUWLiPb4Fa8DIXcQDqjLlH)fzzdnGYmUoGsWna8IIMtZVJIW)ISSHgqzgxJA0BVCSGOi1gkJwXYJIUlv6slkY3jglO2bLuUekZCPXc2cR1oAaLGBa4ffnNMFhfHYmxASGTWATJIA0BmFSGOi1gkJwXYJIMtZVJI175AGRxcbffDxQ0Lwuegdqng1Q0WAmRDWjj1gkJwdW)aGXaqfQvjejJLn0asZbpBskSpapEgGAmQvPH1yw7GtsQnugTgG)baJbG1U0qzK8ET6cxIKgGhpdaRDPHYi59A1fUejna)d4eAsQjskOFaVbucUba1TIIoFDmkO2bLuE07nrn69gmfliksTHYOvS8OO7sLU0IIyTlnugjVxRUWLiPOO5087Oi8VilBObuMX1Og9EZMybrrQnugTILhfnNMFhfFuwQ0zkffD(6yuqTdkP8O3BIAuJIOppOPdISHgli69MybrrQnugTILhfnNMFhfFuwQ0zkffD(6yuqTdkP8O3BIIUlv6slkEcD6c7Fr6KlQMUuhqj4gaIdaZq4akBaQXOwLNqNUGPk1cMMFlP2qz0AaiWbGWbGruCrC3L7A(DuS8Jmf(a(6aeZEDg0NBdWl40elnaF6RMMFh1O34fliksTHYOvS8OO7sLU0IIyTlnugjVIbuHALpapEgG50elfOMqMeFaLGBa4napEgWj0PlS)fPBaWCafgVOO5087O4ri)JtmIZdfZwPlQrVlCSGOi1gkJwXYJIUlv6slkEcD6c7Fr6gamhqHXlkAon)okUitHhSEfwKZ8nQrVXSybrrQnugTILhfDxQ0LwueRDPHYi59A1fUejna)daXbCcD6c7Fr6KlQMUuhamhacr4a84zaNqtsnrsb9dfEaWe3aG6wdWJNbCcnv)dkjpdkf(AqHtH69(m1bhCd5E(TKAdLrRb4XZa47eJfu7Gskxc)lYYgAaLzCDaLGBa4namgGhpd4e60f2)I0nayoGcJxu0CA(Due(xKLn0akZ4AuJEJWybrrQnugTILhfDxQ0LwuevOwLqKmw2qdinh8SjPW(a8pa(oXyb1oOKYL175k35RcNgqj4gaEdW)aGXaWAxAOmsUitHZdlbkyonXsrrZP53rX69CL78vHtrn6ncowquKAdLrRy5rr3LkDPffpHoDH9ViDYfvtxQdOeCdaZW0a8pGtOjPMiPG(HcpGsgau3kkAon)okc)Vo81qXSv6IA07svSGOi1gkJwXYJIUlv6slkY3jglO2bLuUSEpx5oFv40akb3aWBa(hamgaw7sdLrYfzkCEyjqbZPjwkkAon)okwVNRCNVkCkQrV9YXcIIuBOmAflpkAon)ok(OSuPZukk6UuPlTO4j0PlS)fPtUOA6sDaLma8q4a84zaNqtsnrsb9dfEaWCaqDROOZxhJcQDqjLh9EtuJEJ5JfefP2qz0kwEu0DPsxArrS2LgkJK3Rvx4sKuu0CA(Due(xKLn0akZ4AuJEVbtXcIIuBOmAflpk6UuPlTO4j0PlS)fPtUOA6sDaLmaeIPOO5087OODoRPG(3rTg1OgfTNIfe9EtSGOi1gkJwXYJIlI7UCxZVJIEHhZza(0xnn)okAon)okEeY)4eJ48qXSv6IA0B8IfefP2qz0kwEu0DPsxArr1yuRY69CL78vHtsQnugTIIMtZVJIqzMlnwWwyT2rrn6DHJfefP2qz0kwEu0CA(DuSEpxdC9siOOOZxhJcQDqjLh9Etu0DPsxArr3)S1xSLhH8poXiopumBLo5riTS5daM4gaEdaboaOU1a8pa1yuRsOMcNUSHg46FiLuBOmAffxe3D5UMFhfra(dPaZs3aS997nh8bO)aChzknaBa7Csy9dy)Y)s13bO2bL0bWsUoG6FdW23z(Mn0bCMp)x6ObK9aSNIA0BmlwquKAdLrRy5rr3LkDPffXAxAOmsEVwDHlrsrrZP53rr4Frw2qdOmJRrn6ncJfefP2qz0kwEu0DPsxArrS2LgkJKlYu48WsGcMttS0a8pauHAvUitHZdlbsYvZbXaG5aWSOO5087O4JYsLotPOg9gbhliksTHYOvS8OO7sLU0IIOc1QeIKXYgAaP5GNnjpYC6a8paymaS2LgkJKlYu48WsGcMttSuu0CA(DuSEpx5oFv4uuJExQIfefP2qz0kwEu0DPsxArXtOtxy)lsNCr10L6aG5aqCaBq4akBaQXOwLNqNUGPk1cMMFlP2qz0AaiWbu4bGru0CA(DuekZCPXc2cR1okQrV9YXcIIuBOmAflpkAon)okwVNRbUEjeuu0DPsxArXtOtxy)lsNCr10L6aG5aqCaBq4akBaQXOwLNqNUGPk1cMMFlP2qz0AaiWbGWbGru05RJrb1oOKYJEVjQrVX8XcIIuBOmAflpk6UuPlTOimgaw7sdLrYfzkCEyjqbZPjwkkAon)okwVNRCNVkCkQrV3GPybrrQnugTILhfnNMFhfFuwQ0zkffDxQ0Lwu8e60f2)I0jxunDPoGsgaIdapeoGYgGAmQv5j0PlyQsTGP53sQnugTgacCaiCayefD(6yuqTdkP8O3BIA07nBIfefnNMFhfHYmxASGTWATJIIuBOmAflpQrV3GxSGOi1gkJwXYJIMtZVJI175AGRxcbffD(6yuqTdkP8O3BIA07nfowqu0CA(Due(FD4RHIzR0ffP2qz0kwEuJEVbZIfefnNMFhfTZznf0)oQ1Oi1gkJwXYJAuJIlQAcmnwq07nXcIIMtZVJIiZEfQhr(mffP2qz0kwEuJEJxSGOi1gkJwXYJI)EuKtAu0CA(DueRDPHYOOiwJjqrrehavQfY9DAjZM7ob1qzuOulyTkGmSiSPJgG)b4(NT(ITmBU7eudLrHsTG1QaYWIWMosEKT8Dayefxe3D5UMFhfrapcl16a47KlRjTgGEzdbP8bGszdDacCAnGIPcFaMG(innDdGLnXJIyTl0gskkY3jxwtAf0lBiinQrVlCSGOi1gkJwXYJI)EuKtAu0CA(DueRDPHYOOiwJjqrrZPjwkqnHmj(aWnGndW)aqCaNLRaHLAvARfxM9akzaBq4a84zaWyaNLRaHLAvARfxsEn5kFayefXAxOnKuuKRHDM1D2qJA0BmlwquKAdLrRy5rXFpkYjnkAon)okI1U0qzuueRXeOOO50elfOMqMeFaLGBa4na)daXbaJbCwUcewQvPTwCj51KR8b4XZaolxbcl1Q0wlUK8AYv(a8paehWz5kqyPwL2AXLhH0YMpGsgachGhpdOMqHRHJqAzZhqjdydMgagdaJOiw7cTHKII2AXdhH0YoQrVrySGOi1gkJwXYJI)EuKtAu0CA(DueRDPHYOOiwJjqrruHAvEjsskSpa)daXbaJbCcnv)dkjpdkf(AqHtH69(m1bhCd5E(TKAdLrRb4XZaoHMQ)bLKNbLcFnOWPq9EFM6GdUHCp)wsTHYO1a8pGtOtxy)lsNCr10L6akzaE5bGrueRDH2qsrX71QlCjskQrVrWXcIIuBOmAflpk(7rroPrrZP53rrS2LgkJIIynMaffDFVesvsNTsNPzdnGY(IdW)aqfQvjD2kDMMn0ak7lk5Q5Gya4gaEdWJNb4(EjKQuOzKXHtRq9O2N9vsTHYO1a8pauHAvk0mY4WPvOEu7Z(kpcPLnFaWCaioaOU1aqGdaVbGrueRDH2qsrX69CnW1lHGcUVxcPYJA07svSGOi1gkJwXYJI)EuKtAu0CA(DueRDPHYOOiwJjqrXfzk8G1RWICMVsnDqKn0b4FaUhl1wRYoHcxdvJIIyTl0gskkUitHZdlbkyonXsrn6TxowquKAdLrRy5rrZP53rXJq(hNyeNhkMTsxuCrC3L7A(Du0lSVZ8Daia3Z1bGaqyPd)bG0YwTShGx057akWyFZhG1Rbabr7dWNsi)JtmIZhaMB2kDd4EglBOrr3LkDPffDFVesvsyPREpxhG)bOgJAvc1u40Ln0ax)dPKAdLrRb4FaWyaQXOwLpklv6mn)wsTHYO1a8pa3)S1xSL7jJzx4RH69CvEeslBEuJEJ5JfefP2qz0kwEu0CA(Due(xKLn0akZ4Au0DPsxArX1RY69CnujS0jpQEehUHYOb4Faioa1yuRY0roBxsTHYO1a84zaWyaOc1Qe9itHh(AGN96mOp3Kc7dW)auJrTkrpYu4HVg4zVod6Znj1gkJwdWJNbOgJAv(OSuPZ08Bj1gkJwdW)aC)ZwFXwUNmMDHVgQ3Zv5riTS5dW)aGXaqfQvjejJLn0asZbpBskSpamIIoFDmkO2bLuE07nrn69gmfliksTHYOvS8OO7sLU0IIOc1QmD(guJ9nxEeslB(aGjUba1TgG)bGkuRY05Bqn23CPW(a8pa(oXyb1oOKYLqzMlnwWwyT2rdOeCdaVb4Faioayma1yuRs0JmfE4RbE2RZG(CtsTHYO1a84zaU)zRVylrpYu4HVg4zVod6Zn5riTS5dOKbSbHdaJOO5087OiuM5sJfSfwRDuuJEVztSGOi1gkJwXYJIUlv6slkIkuRY05Bqn23C5riTS5daM4gau3Aa(haQqTktNVb1yFZLc7dW)aqCaWyaQXOwLOhzk8Wxd8SxNb95MKAdLrRb4XZaGXaqfQvj6rMcp81ap71zqFUjf2hG)b4(NT(ITe9itHh(AGN96mOp3KhH0YMpGsgWgmnamIIMtZVJI175AGRxcbf1O3BWlwquKAdLrRy5rXfXDxUR53rrFa)FonaVGtZVhal56a0FaNqhfnNMFhfDgJfmNMFhyjxJISKRH2qsrr3JLARvEuJEVPWXcIIuBOmAflpkAon)ok6mglyon)oWsUgfzjxdTHKIIN5sJXJA07nywSGOi1gkJwXYJIMtZVJIoJXcMtZVdSKRrrwY1qBiPOOEzdbP8Og9EdcJfefP2qz0kwEu0CA(Du0zmwWCA(DGLCnkYsUgAdjffD)ZwFXMh1O3BqWXcIIuBOmAflpk6UuPlTOOAmQvP7zRaCYovsTHYO1a8paehamgaQqTkHizSSHgqAo4ztsH9b4XZauJrTkrpYu4HVg4zVod6Znj1gkJwdaJb4FaioGfHkuRYZ85)shj5Q5Gya4gachGhpdagdyrMcparNqHRYtOP6Fqj5z(8FPJgagrrZP53rrNXybZP53bwY1Oil5AOnKuu09SvaozNg1O3BkvXcIIuBOmAflpk6UuPlTOiQqTkrpYu4HVg4zVod6ZnPWEu0CA(Du8e6G5087al5AuKLCn0gskkI(8GMoiYgAuJEVXlhliksTHYOvS8OO7sLU0IIQXOwLOhzk8Wxd8SxNb95MKAdLrRb4Faioa3)S1xSLOhzk8Wxd8SxNb95M8iKw28baZbSbtdaJb4FaioGZYvGWsTkT1IlZEaLma8q4a84zaWyaNLRaHLAvARfxsEn5kFaE8ma3)S1xSL7jJzx4RH69CvEeslB(aG5a2GPb4FaNLRaHLAvARfxsEn5kFa(hWz5kqyPwL2AXLzpayoGnyAayefnNMFhfpHoyon)oWsUgfzjxdTHKIIOppS)plBOrn69gmFSGOi1gkJwXYJIUlv6slkIkuRY9KXSl81q9EUkf2hG)bOgJAv(OSuPZ08Bj1gkJwrrZP53rXtOdMtZVdSKRrrwY1qBiPO4JYsLotZVJA0B8WuSGOi1gkJwXYJIUlv6slkQgJAv(OSuPZ08Bj1gkJwdW)aC)ZwFXwUNmMDHVgQ3Zv5riTS5daMdydMgG)bG4aWAxAOmsY1WoZ6oBOdWJNbCwUcewQvPTwCj51KR8b4FaNLRaHLAvARfxM9aG5a2GPb4XZaGXaolxbcl1Q0wlUK8AYv(aWikAon)okEcDWCA(DGLCnkYsUgAdjffFuwQ0zA(Dy)Fw2qJA0B82eliksTHYOvS8OO7sLU0IIMttSuGAczs8bucUbGxu0CA(Du8e6G5087al5AuKLCn0gskkApf1O34HxSGOi1gkJwXYJIMtZVJIoJXcMtZVdSKRrrwY1qBiPOixTEz3kQrnkEMlngpwq07nXcIIuBOmAflpkAon)okIY(FfQcNVrXfXDxUR53rrFQ5sJnaVaAYsnjEu0DPsxArruHAvUNmMDHVgQ3ZvPWEuJEJxSGOi1gkJwXYJIUlv6slkIkuRY9KXSl81q9EUkf2JIMtZVJIO0XPdISHg1O3fowquKAdLrRy5rr3LkDPffrCaWyaOc1QCpzm7cFnuVNRsH9b4FaMttSuGAczs8bucUbG3aWyaE8maymauHAvUNmMDHVgQ3ZvPW(a8paehWj0KCr10L6akb3aq4a8pGtOtxy)lsNCr10L6akb3aqWyAayefnNMFhfTZznf2fyCkQrVXSybrrQnugTILhfDxQ0LwuevOwL7jJzx4RH69CvkShfnNMFhfzju4kpGGuHfuKuRrn6ncJfefP2qz0kwEu0DPsxArruHAvUNmMDHVgQ3ZvPW(a8pauHAvsi3)I0foHMcfjB)BPWEu0CA(Du0AhX1ZybNXyrn6ncowquKAdLrRy5rr3LkDPffrfQv5EYy2f(AOEpxLhH0YMpayIBaE5b4FaOc1QKqU)fPlCcnfks2(3sH9OO5087OynpcL9)kQrVlvXcIIuBOmAflpk6UuPlTOiQqTk3tgZUWxd175QuyFa(hG50elfOMqMeFa4gWMb4FaioauHAvUNmMDHVgQ3Zv5riTS5daMdaHdW)auJrTkDpBfGt2PsQnugTgGhpdagdqng1Q09SvaozNkP2qz0Aa(haQqTk3tgZUWxd175Q8iKw28baZbu4bGru0CA(Due1Gg(AqV0bbpQrnk6ESuBTYJfe9EtSGOi1gkJwXYJIMtZVJIlYu48WsGIIlI7UCxZVJI(4XsT16a8cOjl1K4rr3LkDPffXAxAOmsY1WoZ6oBOdWJNbG1U0qzK0wlE4iKw2rn6nEXcIIuBOmAflpk6UuPlTO4j0PlS)fPtUOA6sDaLmGnfEa(hG7F26l2Y9KXSl81q9EUkpcPLnFaWCafEa(hamgGAmQvj6rMcp81ap71zqFUjP2qz0Aa(haw7sdLrsUg2zw3zdnkAon)okYlAhYSHgqMCnQrVlCSGOi1gkJwXYJIUlv6slkcJbOgJAvIEKPWdFnWZEDg0NBsQnugTgG)bG1U0qzK0wlE4iKw2rrZP53rrEr7qMn0aYKRrn6nMfliksTHYOvS8OO7sLU0IIQXOwLOhzk8Wxd8SxNb95MKAdLrRb4FaioauHAvIEKPWdFnWZEDg0NBsH9b4FaioaS2LgkJKCnSZSUZg6a8pGtOtxy)lsNCr10L6akzaygMgGhpdaRDPHYiPTw8WriTShG)bCcD6c7Fr6KlQMUuhqjdabJPb4XZaWAxAOmsARfpCesl7b4FaNLRaHLAvARfxEeslB(aG5aW8daJb4XZaGXaqfQvj6rMcp81ap71zqFUjf2hG)b4(NT(ITe9itHh(AGN96mOp3KhH0YMpamIIMtZVJI8I2HmBObKjxJA0BegliksTHYOvS8OO7sLU0IIU)zRVyl3tgZUWxd175Q8iKw28baZbu4b4FayTlnugj5AyNzDNn0b4Faioa1yuRs0JmfE4RbE2RZG(CtsTHYO1a8pGtOtxy)lsNCr10L6aG5aqWyAa(hG7F26l2s0JmfE4RbE2RZG(CtEeslB(aG5aWBaE8mayma1yuRs0JmfE4RbE2RZG(CtsTHYO1aWikAon)okAOpYSnn)oWsKOrn6ncowquKAdLrRy5rr3LkDPffXAxAOmsARfpCesl7OO5087OOH(iZ2087alrIg1O3LQybrrQnugTILhfDxQ0LwueRDPHYijxd7mR7SHoa)daXb4(NT(ITCpzm7cFnuVNRYJqAzZhamhqHhGhpdqng1QmDKZ2LuBOmAnamIIMtZVJIC4Mdcgfu4uqOl(Nc33Og92lhliksTHYOvS8OO7sLU0IIyTlnugjT1IhocPLDu0CA(DuKd3CqWOGcNccDX)u4(g1O3y(ybrrQnugTILhfDxQ0LwuegdavOwL7jJzx4RH69CvkSpa)dagdavOwLOhzk8Wxd8SxNb95MuyFa(haIdG)cm0SxYDbUkWOaDc7A(TKAdLrRb4XZa4Vadn7Le7ZmnzuG)mSuRsQnugTgagrXSv6oHDnK1Oi)fyOzVKyFMPjJc8NHLAnkMTs3jSRHejsALMsrXnrrZP53rXkJ4WDNv1Oy2kDNWUgGYEuJff3e1Ogf3pY9irnnwq07nXcIIuBOmAflpk(7rroPznk6UuPlTOOEzdbPsDJeUXdcCkGkuRdW)aqCaWyaQXOwLOhzk8Wxd8SxNb95MKAdLrRb4Faioa9YgcsL6gP7F26l2YLWzA(9a8jdW9pB9fB5EYy2f(AOEpxLlHZ087bGBayAaymapEgGAmQvj6rMcp81ap71zqFUjP2qz0Aa(haIdW9pB9fBj6rMcp81ap71zqFUjxcNP53dWNma9YgcsL6gP7F26l2YLWzA(9aWnamnamgGhpdqng1QmDKZ2LuBOmAnamIIlI7UCxZVJIyoynMGPeFa2a0lBiiLpa3)S1xSXFaReBUO1aq9Da7jJz3a(6aQ3Z1b83aqpYu4d4RdGN96mOp32YhG7F26l2Yb4fRdi1T8bG1yc0aGB8b0)aocPL9IUbCKkC9a2G)aigNgWrQW1datsekJIyTl0gskkQx2qqAytG7B7IIMtZVJIyTlnugffXAmbkqmoffXKeHrrSgtGIIBIA0B8IfefP2qz0kwEu83JICsZAu0CA(DueRDPHYOOiw7cTHKII6LneKgWlW9TDrr3LkDPff1lBiivQ4jHB8GaNcOc16a8paehamgGAmQvj6rMcp81ap71zqFUjP2qz0Aa(haIdqVSHGuPIN09pB9fB5s4mn)Ea(Kb4(NT(ITCpzm7cFnuVNRYLWzA(9aWnamnamgGhpdqng1Qe9itHh(AGN96mOp3KuBOmAna)daXb4(NT(ITe9itHh(AGN96mOp3KlHZ087b4tgGEzdbPsfpP7F26l2YLWzA(9aWnamnamgGhpdqng1QmDKZ2LuBOmAnamIIynMafigNIIysIWOiwJjqrXnrn6DHJfefP2qz0kwEu83JICsZAu0DPsxArryma9YgcsL6gjCJhe4uavOwhG)bOx2qqQuXtc34bbofqfQ1b4XZa0lBiivQ4jHB8GaNcOc16a8paehaIdqVSHGuPIN09pB9fB5s4mn)EaWAa6LneKkv8KOc1AyjCMMFpamgacCaioGnseoGYgGEzdbPsfpjCJhqfQvjxpQHQWhagdaboaehaw7sdLrs9Ygcsd4f4(2UbGXaWyaLmaehaIdqVSHGuPUr6(NT(ITCjCMMFpayna9YgcsL6gjQqTgwcNP53daJbGahaIdyJeHdOSbOx2qqQu3iHB8aQqTk56rnuf(aWyaiWbG4aWAxAOmsQx2qqAytG7B7gagdaJO4I4Ul3187OiMdxtKMs8bydqVSHGu(aWAmbAaO(oa3JC3USHoafona3)S1xShWxhGcNgGEzdbP4pGvInx0AaO(oafonGLWzA(9a(6au40aqfQ1bK6a2VhBUiUCaEjn(aSbW1JAOk8bG8xznPBa6paOjwAa2aGNqHt3a2V8Vu9Da6paUEudvHpa9Ygcs54paJpGIeJnaJpaBai)vwt6gq9VbK1bydqVSHG0bumzSb83akMm2a6xha332nGIPcFaU)zRVyZLrrS2fAdjff1lBiinSF5FP6Bu0CA(DueRDPHYOOiwJjqbIXPO4MOiwJjqrr8IA0BmlwquKAdLrRy5rXFpkYjnkAon)okI1U0qzuueRXeOOOAmQvjutHtx2qdC9pKsQnugTgGhpdW99sivjHLU69CvsTHYO1a84zaNqt1)Gss0uZgAW9SLKAdLrROiw7cTHKIIxXaQqTYJA0BeglikAon)okwzehU7SQgfP2qz0kwEuJAu09pB9fBESGO3BIfefP2qz0kwEu0DPsxArruHAvUNmMDHVgQ3ZvPWEuCrC3L7A(Dueb8187OO5087O4(R53rn6nEXcIIuBOmAflpkAon)oksi3)I0foHMcfjB)7O4I4Ul3187OOp(NT(Inpk6UuPlTOOAmQv5JYsLotZVLuBOmAna)d4eAAaWCai4b4FaioaS2LgkJKCnSZSUZg6a84zayTlnugjT1IhocPL9aWya(haIdW9pB9fB5EYy2f(AOEpxLhH0YMpayoaeoa)daXb4(NT(ITSYioC3zvvEeslB(akzaiCa(ha)fyOzVK7cCvGrb6e218Bj1gkJwdWJNbaJbWFbgA2l5UaxfyuGoHDn)wsTHYO1aWyaE8mauHAvUNmMDHVgQ3ZvPW(aWyaE8ma0NZhG)butOW1WriTS5daMdapmf1O3fowquKAdLrRy5rr3LkDPffvJrTkrpYu4HVg4zVod6Znj1gkJwdW)aoHoDH9ViDYfvtxQdOKbuymna)d4eAsQjskOFaHdOKba1TgG)bG4aqfQvj6rMcp81ap71zqFUjf2hGhpdOMqHRHJqAzZhamhaEyAayefnNMFhfjK7Fr6cNqtHIKT)DuJEJzXcIIuBOmAflpk6UuPlTOOAmQvz6iNTlP2qz0kkAon)oksi3)I0foHMcfjB)7Og9gHXcIIuBOmAflpk6UuPlTOOAmQvj6rMcp81ap71zqFUjP2qz0Aa(haIdaRDPHYijxd7mR7SHoapEgaw7sdLrsBT4HJqAzpamgG)bG4aC)ZwFXwIEKPWdFnWZEDg0NBYJqAzZhGhpdW9pB9fBj6rMcp81ap71zqFUjpYw(oa)d4e60f2)I0jxunDPoayoaeIPbGru0CA(DuCpzm7cFnuVNRrn6ncowquKAdLrRy5rr3LkDPffvJrTkth5SDj1gkJwdW)aGXaqfQv5EYy2f(AOEpxLc7rrZP53rX9KXSl81q9EUg1O3LQybrrQnugTILhfDxQ0Lwuung1Q8rzPsNP53sQnugTgG)bG4aWAxAOmsY1WoZ6oBOdWJNbG1U0qzK0wlE4iKw2daJb4Faioa1yuRsOMcNUSHg46FiLuBOmAna)davOwLhH8poXiopumBLoPW(a84zaWyaQXOwLqnfoDzdnW1)qkP2qz0AayefnNMFhf3tgZUWxd175AuJE7LJfefP2qz0kwEu0DPsxArruHAvUNmMDHVgQ3ZvPWEu0CA(Due9itHh(AGN96mOp3IA0BmFSGOi1gkJwXYJIUlv6slkAonXsbQjKjXhaUbSza(haQqTk3tgZUWxd175Q8iKw28baZba1TgG)bGkuRY9KXSl81q9EUkf2hG)baJbOgJAv(OSuPZ08Bj1gkJwdW)aqCaWyaNLRaHLAvARfxsEn5kFaE8mGZYvGWsTkT1IlZEaLmGcJPbGXa84za1ekCnCeslB(aG5akCu0CA(DuSEpxl67HKhQcNVrn69gmfliksTHYOvS8OO7sLU0IIMttSuGAczs8bucUbG3a8paehaQqTk3tgZUWxd175QuyFaE8mGZYvGWsTkT1IlZEaLma3)S1xSL7jJzx4RH69CvEeslB(aWya(haIdavOwL7jJzx4RH69CvEeslB(aG5aG6wdWJNbCwUcewQvPTwC5riTS5daMdaQBnamIIMtZVJI175ArFpK8qv48nQrV3SjwquKAdLrRy5rr3LkDPffvJrTkFuwQ0zA(TKAdLrRb4FaOc1QCpzm7cFnuVNRsH9b4FaioaehaQqTk3tgZUWxd175Q8iKw28baZba1TgGhpdavOwLcn8N5BGRh1qv4sH9b4FaOc1QuOH)mFdC9OgQcxEeslB(aG5aG6wdaJb4FaioGfHkuRYZ85)shj5Q5Gya4gachGhpdagdyrMcparNqHRYtOP6Fqj5z(8FPJgagdaJOO5087Oy9EUw03djpufoFJA07n4fliksTHYOvS8OO7sLU0IIQXOwLOhzk8Wxd8SxNb95MKAdLrRb4FaNqNUW(xKo5IQPl1buYaWmmna)d4eAAaWe3ak8a8paehaQqTkrpYu4HVg4zVod6ZnPW(a84zaU)zRVylrpYu4HVg4zVod6Zn5riTS5dOKbGzyAaymapEgamgGAmQvj6rMcp81ap71zqFUjP2qz0Aa(hWj0PlS)fPtUOA6sDaLGBa4HWOO5087OiCF3FfoDitxy)io1okQrV3u4ybrrQnugTILhfDxQ0Lwu09pB9fB5EYy2f(AOEpxLhH0YMpayIBaimkAon)okEwYPWISvuJEVbZIfefP2qz0kwEu0DPsxArrZPjwkqnHmj(akb3aWBa(haIda958b4Fa1ekCnCeslB(aG5ak8a84zaWyaOc1Qe9itHh(AGN96mOp3Kc7dW)aqCa7KkHc)fyYJqAzZhamhau3AaE8mGZYvGWsTkT1IlpcPLnFaWCafEa(hWz5kqyPwL2AXLzpGsgWoPsOWFbM8iKw28bGXaWikAon)okYn3L10LglSBonQrV3GWybrrQnugTILhfDxQ0Lwu0CAILcutitIpGsgachGhpd4eAQ(husUdNS7r(nXLuBOmAffnNMFhfxKPWdwVclYz(g1Ogf1lBiiLhli69MybrrQnugTILhfnNMFhfZM7ob1qzuOulyTkGmSiSPJIIlI7UCxZVJIfCzdbP8OO7sLU0IIOc1QCpzm7cFnuVNRsH9b4XZau7GsQutKuq)WUtd4HPbaZbGWb4XZaqFoFa(hqnHcxdhH0YMpayoa82e1O34fliksTHYOvS8OO5087OOEzdbPBIIlI7UCxZVJIfaNgGEzdbPdOyQWhGcNga8ekCIRdG4AI0uAnaSgtGWFaftgBaO0ae40Aa1846aSEnGDlpAnGIPcFaiGjJz3a(6aqaUNRYOO7sLU0IIWyayTlnugj57KlRjTc6LneKoa)davOwL7jJzx4RH69CvkSpa)daXbaJbOgJAvMoYz7sQnugTgGhpdqng1QmDKZ2LuBOmAna)davOwL7jJzx4RH69CvEeslB(akb3a2GPbGXa8paehamgGEzdbPsfpjCJhC)ZwFXEaE8ma9YgcsLkEs3)S1xSLhH0YMpapEgaw7sdLrs9Ygcsd7x(xQ(oaCdyZaWyaE8ma9YgcsL6gjQqTgwcNP53dOeCdOMqHRHJqAzZJA07chliksTHYOvS8OO7sLU0IIWyayTlnugj57KlRjTc6LneKoa)davOwL7jJzx4RH69CvkSpa)daXbaJbOgJAvMoYz7sQnugTgGhpdqng1QmDKZ2LuBOmAna)davOwL7jJzx4RH69CvEeslB(akb3a2GPbGXa8paehamgGEzdbPsDJeUXdU)zRVypapEgGEzdbPsDJ09pB9fB5riTS5dWJNbG1U0qzKuVSHG0W(L)LQVda3aWBaymapEgGEzdbPsfpjQqTgwcNP53dOeCdOMqHRHJqAzZJIMtZVJI6LneKIxuJEJzXcIIuBOmAflpkAon)okQx2qq6MO4I4Ul3187OOxSoGVz(oGVPb89ae40a0lBiiDa73JnxeFa2aqfQv8hGaNgGcNgWRWPBaFpa3)S1xSLdab9gqwhqtPcNUbOx2qq6a2VhBUi(aSbGkuR4pabona0xHpGVhG7F26l2YOO7sLU0IIWya6LneKk1ns4gpiWPaQqToa)daXbOx2qqQuXt6(NT(IT8iKw28b4XZaGXa0lBiivQ4jHB8GaNcOc16aWyaE8ma3)S1xSL7jJzx4RH69CvEeslB(akza4HPOg9gHXcIIuBOmAflpk6UuPlTOimgGEzdbPsfpjCJhe4uavOwhG)bG4a0lBiivQBKU)zRVylpcPLnFaE8mayma9YgcsL6gjCJhe4uavOwhagdWJNb4(NT(ITCpzm7cFnuVNRYJqAzZhqjdapmffnNMFhf1lBiifVOg1Oi6Zd7)ZYgASGO3BIfefP2qz0kwEu0CA(Due(xKLn0akZ4AuCrC3L7A(DuS8Jmf(a(6aeZEDg0NBdy)Fw2qhW9QP53dOqdGR2P8bSbt8bGs1)Obu(loGKpadRLmdLrrr3LkDPffXAxAOmsEVwDHlrsrn6nEXcIIuBOmAflpk6UuPlTOO50elfOMqMeFaLGBa4napEgWj0KutKuq)achamXnaOU1a8paS2LgkJKxXaQqTYJIMtZVJIhH8poXiopumBLUOg9UWXcIIuBOmAflpkAon)ok(OSuPZukk6UuPlTO4j0PlS)fPtUOA6sDaLGBa4HWOOZxhJcQDqjLh9EtuJEJzXcIIuBOmAflpk6UuPlTO4j0PlS)fPtUOA6sDaWCa4HPb4Fa8DIXcQDqjLlHYmxASGTWATJgqj4gaEdW)aC)ZwFXwUNmMDHVgQ3Zv5riTS5dOKbGWOO5087OiuM5sJfSfwRDuuJEJWybrrQnugTILhfnNMFhfR3Z1axVeckk6UuPlTO4j0PlS)fPtUOA6sDaWCa4HPb4FaU)zRVyl3tgZUWxd175Q8iKw28buYaqyu05RJrb1oOKYJEVjQrVrWXcIIuBOmAflpk6UuPlTOiQqTkHizSSHgqAo4ztYJmNoa)d4e60f2)I0jxunDPoGsgaIdydchqzdqng1Q8e60fmvPwW08Bj1gkJwdaboaeoamgG)bW3jglO2bLuUSEpx5oFv40akb3aWBa(hamgaw7sdLrYfzkCEyjqbZPjwkkAon)okwVNRCNVkCkQrVlvXcIIuBOmAflpk6UuPlTO4j0PlS)fPtUOA6sDaLGBaioGcJWbu2auJrTkpHoDbtvQfmn)wsTHYO1aqGdaHdaJb4Fa8DIXcQDqjLlR3ZvUZxfonGsWna8gG)baJbG1U0qzKCrMcNhwcuWCAILIIMtZVJI175k35RcNIA0BVCSGOi1gkJwXYJIUlv6slk6(NT(ITCpzm7cFnuVNRYJqAzZhqjd4eAsQjskOFaZgG)bCcD6c7Fr6KlQMUuhamhaMHPb4Fa8DIXcQDqjLlHYmxASGTWATJgqj4gaErrZP53rrOmZLglylSw7OOg9gZhliksTHYOvS8OO5087Oy9EUg46Lqqrr3LkDPffD)ZwFXwUNmMDHVgQ3Zv5riTS5dOKbCcnj1ejf0pGzdW)aoHoDH9ViDYfvtxQdaMdaZWuu05RJrb1oOKYJEVjQrnkYvRx2TIfe9EtSGOi1gkJwXYJIMtZVJIhH8poXiopumBLUO4I4Ul3187OOOA9YU1a4zdLriiu7Gs6aUxnn)ok6UuPlTOiw7sdLrYRyavOw5rn6nEXcIIuBOmAflpk6UuPlTOiQqTkHizSSHgqAo4ztYJmNgfnNMFhfFuwQ0zkf1O3fowquKAdLrRy5rr3LkDPffXAxAOmswVNRbUEjeuW99sivEu0CA(DuSEpxdC9siOOg9gZIfefP2qz0kwEu0DPsxArrymGfzk8aeDcfUkpHMQ)bLKN5Z)LoAa(haIdyrOc1Q8mF(V0rsUAoigamhachGhpdyrOc1Q8mF(V0rYJqAzZhamhqPAayefnNMFhfHYmxASGTWATJIA0BegliksTHYOvS8OO7sLU0IIU)zRVylpc5FCIrCEOy2kDYJqAzZhamXna8gacCaqDRb4FaQXOwLqnfoDzdnW1)qkP2qz0kkAon)okwVNRbUEjeuuJEJGJfefP2qz0kwEu0DPsxArrS2LgkJK3Rvx4sKuu0CA(Due(xKLn0akZ4AuJExQIfefP2qz0kwEu0DPsxArrymauHAvwV3NPoSlW4KuyFa(hGAmQvz9EFM6WUaJtsQnugTgGhpdaRDPHYi5ImfopSeOG50elna)davOwLlYu48WsGKC1CqmayoamBaE8mGtOjPMiPG(bmBaWe3aG6wrrZP53rXhLLkDMsrn6TxowquKAdLrRy5rr3LkDPffpHoDH9ViDYfvtxQdaMdaXbSbHdOSbOgJAvEcD6cMQulyA(TKAdLrRbGahachagrrZP53rX69CnW1lHGIA0BmFSGOi1gkJwXYJIUlv6slkEcD6c7Fr6KlQMUuhqjdaXbGhchqzdqng1Q8e60fmvPwW08Bj1gkJwdaboaeoamIIMtZVJIpklv6mLIA07nykwqu0CA(DuSEpxdC9siOOi1gkJwXYJA07nBIfefnNMFhfH)xh(AOy2kDrrQnugTILh1O3BWlwqu0CA(Du0oN1uq)7OwJIuBOmAflpQrnQrrS0XZVJEJhMWBdM8YyAtuSODD2q5rrmxVGp1BVO3EPfAadOa40asK7)PdO(3a26E2kaNSt3oGJk1c5rRbWFK0amb9rAkTgGdU1qjUCGS0ztdytHgGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bG4gVIHCGS0ztdaVcnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdaXnEfd5azPZMgqHl0a8X3yPtP1a2QgJAvc7Tdq)bSvng1Qe2sQnugT2oae34vmKdKLoBAaywHgGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bG4gVIHCGCGeZ1l4t92l6TxAHgWakaonGe5(F6aQ)nGTpklv6mn)E7aoQulKhTga)rsdWe0hPP0Aao4wdL4YbYsNnnamFHgGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGiEEfd5a5ajMRxWN6Tx0BV0cnGbuaCAajY9)0bu)BaBrFEqthezdD7aoQulKhTga)rsdWe0hPP0Aao4wdL4YbYsNnnGnfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaIB8kgYbYsNnnamRqdWhFJLoLwdy7j0u9pOKe2BhG(dy7j0u9pOKe2sQnugT2oae34vmKdKdKyUEbFQ3ErV9sl0agqbWPbKi3)thq9VbS19yP2ALVDahvQfYJwdG)iPbyc6J0uAnahCRHsC5azPZMgaEfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaIB8kgYbYsNnnGcxOb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaiUXRyihilD20aWScnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdaXnEfd5azPZMgacl0a8X3yPtP1a2QgJAvc7Tdq)bSvng1Qe2sQnugT2oaeXZRyihilD20akvfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaIB8kgYbYsNnnamFHgGp(glDkTgWw(lWqZEjH92bO)a2YFbgA2ljSLuBOmATDaiINxXqoqoqI56f8PE7f92lTqdyafaNgqIC)pDa1)gWwUA9YU12bCuPwipAna(JKgGjOpstP1aCWTgkXLdKLoBAaiSqdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7amDayoiOLEaiUXRyihilD20akvfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaIB8kgYbYsNnnaVCHgGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bG4gVIHCGS0ztdaZxOb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaiUXRyihihiXC9c(uV9IE7LwObmGcGtdirU)NoG6Fdyl6Zd7)ZYg62bCuPwipAna(JKgGjOpstP1aCWTgkXLdKLoBAai4cnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdaXnEfd5azPZMgqPQqdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqCJxXqoqoqI56f8PE7f92lTqdyafaNgqIC)pDa1)gW29JCpsut3oGJk1c5rRbWFK0amb9rAkTgGdU1qjUCGS0ztdytHgGp(glDkTgGyI0hdG7BRMxhGpXNma9hqPfSbG8xcmb(a(D6m9VbGOpbJbGiEEfd5azPZMgWMcnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdaXc7vmKdKLoBAaBk0a8X3yPtP1a2Qx2qqQCJe2BhG(dyREzdbPsDJe2BhaIf2RyihilD20aWRqdWhFJLoLwdqmr6JbW9TvZRdWN4tgG(dO0c2aq(lbMaFa)oDM(3aq0NGXaqepVIHCGS0ztdaVcnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdaXc7vmKdKLoBAa4vOb4JVXsNsRbSvVSHGujEsyVDa6pGT6LneKkv8KWE7aqSWEfd5azPZMgqHl0a8X3yPtP1aetK(yaCFB186a8jdq)buAbBaReBYZVhWVtNP)naeHfgdar88kgYbYsNnnGcxOb4JVXsNsRbSvVSHGu5gjS3oa9hWw9YgcsL6gjS3oaeXmVIHCGS0ztdOWfAa(4BS0P0AaB1lBiivINe2BhG(dyREzdbPsfpjS3oaerOxXqoqw6SPbGzfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaIB8kgYbYsNnnamRqdWhFJLoLwdy7j0u9pOKe2BhG(dy7j0u9pOKe2sQnugT2oathaMdcAPhaIB8kgYbYsNnnamRqdWhFJLoLwdyR77LqQsyVDa6pGTUVxcPkHTKAdLrRTdaXnEfd5a5ajMRxWN6Tx0BV0cnGbuaCAajY9)0bu)BaBD)ZwFXMVDahvQfYJwdG)iPbyc6J0uAnahCRHsC5azPZMgaEfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaIB8kgYbYsNnna8k0a8X3yPtP1a2YFbgA2ljS3oa9hWw(lWqZEjHTKAdLrRTdar88kgYbYsNnnGcxOb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaiUXRyihilD20aWScnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdW0bG5GGw6bG4gVIHCGS0ztdaHfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaIB8kgYbYsNnnaeCHgGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bG4gVIHCGS0ztdOuvOb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaiUXRyihilD20aW8fAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaIB8kgYbYsNnnGnBk0a8X3yPtP1a2QgJAvc7Tdq)bSvng1Qe2sQnugT2oae34vmKdKLoBAaBWRqdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqepVIHCGS0ztdydcl0a8X3yPtP1a2Ecnv)dkjH92bO)a2Ecnv)dkjHTKAdLrRTdW0bG5GGw6bG4gVIHCGCGeZ1l4t92l6TxAHgWakaonGe5(F6aQ)nGT6LneKY3oGJk1c5rRbWFK0amb9rAkTgGdU1qjUCGS0ztdaVcnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdar88kgYbYsNnna8k0a8X3yPtP1a2Qx2qqQCJe2BhG(dyREzdbPsDJe2BhaIB8kgYbYsNnna8k0a8X3yPtP1a2Qx2qqQepjS3oa9hWw9YgcsLkEsyVDaiINxXqoqw6SPbu4cnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdar88kgYbYsNnnGcxOb4JVXsNsRbSvVSHGu5gjS3oa9hWw9YgcsL6gjS3oaeXZRyihilD20akCHgGp(glDkTgWw9YgcsL4jH92bO)a2Qx2qqQuXtc7TdaXnEfd5azPZMgaMvOb4JVXsNsRbSvVSHGu5gjS3oa9hWw9YgcsL6gjS3oae34vmKdKLoBAaywHgGp(glDkTgWw9YgcsL4jH92bO)a2Qx2qqQuXtc7Tdar88kgYbYsNnnaewOb4JVXsNsRbSvVSHGu5gjS3oa9hWw9YgcsL6gjS3oaeXZRyihilD20aqyHgGp(glDkTgWw9YgcsL4jH92bO)a2Qx2qqQuXtc7TdaXnEfd5a5ajMRxWN6Tx0BV0cnGbuaCAajY9)0bu)BaBxu1ey62bCuPwipAna(JKgGjOpstP1aCWTgkXLdKLoBAaiSqdWhFJLoLwdy7j0u9pOKe2BhG(dy7j0u9pOKe2sQnugT2oaeXZRyihilD20aqWfAa(4BS0P0AaBDFVesvc7Tdq)bS199sivjSLuBOmATDaiUXRyihilD20a8YfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaI45vmKdKLoBAay(cnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdaXc7vmKdKLoBAaBWuHgGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bG4gVIHCGS0ztdyZMcnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdaXnEfd5azPZMgWgeCHgGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGiEEfd5azPZMgWgVCHgGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bG4gVIHCGS0ztdydMVqdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7amDayoiOLEaiUXRyihilD20aWdtfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaIB8kgYbYbsmxVGp1BVO3EPfAadOa40asK7)PdO(3a2ApTDahvQfYJwdG)iPbyc6J0uAnahCRHsC5azPZMgaEfAa(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhGPdaZbbT0daXnEfd5azPZMgqHl0a8X3yPtP1a2QgJAvc7Tdq)bSvng1Qe2sQnugT2oathaMdcAPhaIB8kgYbYsNnnGsvHgGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bG4gVIHCGS0ztdWlxOb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaiUXRyihilD20a2GPcnaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdaXnEfd5a5aPxe5(FkTgWMcpaZP53dGLCLlhiJI73xtgfflLszaEjitHpaeK7ekCDaia3Z1bYsPugGxqaQaxhaEyE8haEycVndKdKLsPmaFa3AOeFGSukLbGGya(uc5JLwdGzCfbbNCFVgGa3Gsd4RdWhWTS5d4RdWl6Oby8bK6awpX7T6a2zMVdOiXydi7bSFMtthjhilLszaiigGxIV3QdWb36MydabGrC4UZQ6awcx2qhq5hzk8b81biM96mOp3KdKdKLYaWCWAmbtj(aSbOx2qqkFaU)zRVyJ)awj2CrRbG67a2tgZUb81buVNRd4VbGEKPWhWxhap71zqFUTLpa3)S1xSLdWlwhqQB5daRXeOba34dO)bCesl7fDd4iv46bSb)bqmonGJuHRhaMKiuoqAon)Ml3pY9irnTmCWcRDPHYi8BdjHtVSHG0WMa332H)VJJtAwXhRXeiCBWhRXeOaX4eomjri(UVxPMFJtVSHGu5gjCJhe4uavOw9JimuJrTkrpYu4HVg4zVod6Zn)iQx2qqQCJ09pB9fB5s4mn)2N4tC)ZwFXwUNmMDHVgQ3Zv5s4mn)ghMWWJh1yuRs0JmfE4RbE2RZG(CZpIU)zRVylrpYu4HVg4zVod6Zn5s4mn)2N4t0lBiivUr6(NT(ITCjCMMFJdty4XJAmQvz6iNTJXaP508BUC)i3Je10YWblS2LgkJWVnKeo9Ygcsd4f4(2o8)DCCsZk(ynMaHBd(ynMafigNWHjjcX399k18BC6LneKkXtc34bbofqfQv)icd1yuRs0JmfE4RbE2RZG(CZpI6LneKkXt6(NT(ITCjCMMF7t8jU)zRVyl3tgZUWxd175QCjCMMFJdty4XJAmQvj6rMcp81ap71zqFU5hr3)S1xSLOhzk8Wxd8SxNb95MCjCMMF7t8j6LneKkXt6(NT(ITCjCMMFJdty4XJAmQvz6iNTJXazPmamhUMinL4dWgGEzdbP8bG1yc0aq9DaUh5UDzdDakCAaU)zRVypGVoafona9YgcsXFaReBUO1aq9DakCAalHZ087b81bOWPbGkuRdi1bSFp2CrC5a8sA8bydGRh1qv4da5VYAs3a0FaqtS0aSbapHcNUbSF5FP67a0FaC9OgQcFa6LneKYXFagFafjgBagFa2aq(RSM0nG6FdiRdWgGEzdbPdOyYyd4VbumzSb0VoaUVTBaftf(aC)ZwFXMlhinNMFZL7h5EKOMwgoyH1U0qze(THKWPx2qqAy)Y)s1x8)DCCsZk(ynMaHdp8XAmbkqmoHBd(UVxPMFJdg6LneKk3iHB8GaNcOc1QF9YgcsL4jHB8GaNcOc1Qhp6LneKkXtc34bbofqfQv)iIOEzdbPs8KU)zRVylxcNP53(e9YgcsL4jrfQ1Ws4mn)gdeiIBKiSm9YgcsL4jHB8aQqTk56rnufogiqeXAxAOmsQx2qqAaVa332HbgLGiI6LneKk3iD)ZwFXwUeotZV9j6LneKk3irfQ1Ws4mn)gdeiIBKiSm9YgcsLBKWnEavOwLC9OgQchdeiIyTlnugj1lBiinSjW9TDyGXaP508BUC)i3Je10YWblS2LgkJWVnKeURyavOw54J1yceo1yuRsOMcNUSHg46Fi94X99sivjHLU69C1JNtOP6FqjjAQzdn4E2AG0CA(nxUFK7rIAAz4GvLrC4UZQ6a5azPukdaZXRKtqP1aiS057a0ejnafonaZP)nGKpadRLmdLrYbsZP53CCiZEfQhr(mnqwkdab8iSuRdGVtUSM0Aa6LneKYhakLn0biWP1akMk8byc6J000naw2eFG0CA(nVmCWcRDPHYi8BdjHJVtUSM0kOx2qqk(ynMaHdrQulK770sMn3DcQHYOqPwWAvazyryth539pB9fBz2C3jOgkJcLAbRvbKHfHnDK8iB5lgdKMtZV5LHdwyTlnugHFBijCCnSZSUZgk(ynMaHZCAILcutitIJBJFeplxbcl1Q0wlUm7s2GqpEGXz5kqyPwL2AXLKxtUYXyG0CA(nVmCWcRDPHYi8BdjHZwlE4iKw24J1yceoZPjwkqnHmjEj4WZpIW4SCfiSuRsBT4sYRjx5E8CwUcewQvPTwCj51KRC)iEwUcewQvPTwC5riTS5LGqpEQju4A4iKw28s2GjmWyG0CA(nVmCWcRDPHYi8BdjH7ET6cxIKWhRXeiCOc1Q8sKKuy3pIW4eAQ(husEguk81GcNc179zQdo4gY98BpEoHMQ)bLKNbLcFnOWPq9EFM6GdUHCp)2)j0PlS)fPtUOA6sTeVmgdKMtZV5LHdwyTlnugHFBijC175AGRxcbfCFVesLJpwJjq4CFVesvsNTsNPzdnGY(I(rfQvjD2kDMMn0ak7lk5Q5GahEE84(EjKQuOzKXHtRq9O2N91pQqTkfAgzC40kupQ9zFLhH0YMdteH6wiq8WyG0CA(nVmCWcRDPHYi8BdjHBrMcNhwcuWCAILWhRXeiClYu4bRxHf5mFLA6GiBO(DpwQTwLDcfUgQgnqwkdWlSVZ8Daia3Z1bGaqyPd)bG0YwTShGx057akWyFZhG1Rbabr7dWNsi)JtmIZhaMB2kDd4EglBOdKMtZV5LHdwhH8poXiopumBLo8Zko33lHuLew6Q3Zv)QXOwLqnfoDzdnW1)q6hgQXOwLpklv6mn)2V7F26l2Y9KXSl81q9EUkpcPLnFG0CA(nVmCWc(xKLn0akZ4k(oFDmkO2bLuoUn4NvCRxL175AOsyPtEu9ioCdLr(rung1QmDKZ294bgOc1Qe9itHh(AGN96mOp3Kc7(vJrTkrpYu4HVg4zVod6ZnpEuJrTkFuwQ0zA(TF3)S1xSL7jJzx4RH69CvEeslBUFyGkuRsisglBObKMdE2KuyhJbsZP538YWblOmZLglylSw7i8ZkouHAvMoFdQX(MlpcPLnhM4G6w(rfQvz68nOg7BUuy3pFNySGAhus5sOmZLglylSw7OsWHNFeHHAmQvj6rMcp81ap71zqFU5XJ7F26l2s0JmfE4RbE2RZG(CtEeslBEjBqigdKMtZV5LHdw175AGRxcbHFwXHkuRY05Bqn23C5riTS5Wehu3YpQqTktNVb1yFZLc7(regQXOwLOhzk8Wxd8SxNb95MhpWavOwLOhzk8Wxd8SxNb95Muy3V7F26l2s0JmfE4RbE2RZG(CtEeslBEjBWegdKLYa8b8)50a8con)EaSKRdq)bCc9aP508BEz4GLZySG5087al5k(THKW5ESuBTYhinNMFZldhSCgJfmNMFhyjxXVnKeUZCPX4dKMtZV5LHdwoJXcMtZVdSKR43gscNEzdbP8bsZP538YWblNXybZP53bwYv8BdjHZ9pB9fB(aP508BEz4GLZySG5087al5k(THKW5E2kaNStXpR4uJrTkDpBfGt2P(regOc1QeIKXYgAaP5GNnjf294rng1Qe9itHh(AGN96mOp3WWpIlcvOwLN5Z)LosYvZbboe6XdmwKPWdq0ju4Q8eAQ(husEMp)x6imginNMFZldhSoHoyon)oWsUIFBijCOppOPdISHIFwXHkuRs0JmfE4RbE2RZG(CtkSpqAon)MxgoyDcDWCA(DGLCf)2qs4qFEy)Fw2qXpR4uJrTkrpYu4HVg4zVod6Zn)i6(NT(ITe9itHh(AGN96mOp3KhH0YMdZnycd)iEwUcewQvPTwCz2LGhc94bgNLRaHLAvARfxsEn5k3Jh3)S1xSL7jJzx4RH69CvEeslBom3Gj)NLRaHLAvARfxsEn5k3)z5kqyPwL2AXLzdZnycJbsZP538YWbRtOdMtZVdSKR43gsc3JYsLotZVXpR4qfQv5EYy2f(AOEpxLc7(vJrTkFuwQ0zA(9aP508BEz4G1j0bZP53bwYv8BdjH7rzPsNP53H9)zzdf)SItng1Q8rzPsNP53(D)ZwFXwUNmMDHVgQ3Zv5riTS5WCdM8Jiw7sdLrsUg2zw3zd1JNZYvGWsTkT1IljVMCL7)SCfiSuRsBT4YSH5gm5Xdmolxbcl1Q0wlUK8AYvogdKMtZV5LHdwNqhmNMFhyjxXVnKeo7j8ZkoZPjwkqnHmjEj4WBG0CA(nVmCWYzmwWCA(DGLCf)2qs44Q1l7wdKdKLYa8cpMZa8PVAA(9aP508BU0Ec3ri)JtmIZdfZwPBG0CA(nxApvgoybLzU0ybBH1AhHFwXPgJAvwVNRCNVkCAGSugacWFifyw6gGTVFV5Gpa9hG7itPbydyNtcRFa7x(xQ(oa1oOKoawY1bu)Ba2(oZ3SHoGZ85)shnGShG90aP508BU0EQmCWQEpxdC9sii8D(6yuqTdkPCCBWpR4C)ZwFXwEeY)4eJ48qXSv6KhH0YMdtC4HaH6w(vJrTkHAkC6YgAGR)HCG0CA(nxApvgoyb)lYYgAaLzCf)SIdRDPHYi59A1fUejnqAon)MlTNkdhSEuwQ0zkHFwXH1U0qzKCrMcNhwcuWCAIL8JkuRYfzkCEyjqsUAoiGjMnqAon)MlTNkdhSQ3ZvUZxfoHFwXHkuRsisglBObKMdE2K8iZP(Hbw7sdLrYfzkCEyjqbZPjwAG0CA(nxApvgoybLzU0ybBH1AhHFwXDcD6c7Fr6KlQMUuHjIBqyzQXOwLNqNUGPk1cMMFJalmgdKMtZV5s7PYWbR69CnW1lHGW35RJrb1oOKYXTb)SI7e60f2)I0jxunDPcte3GWYuJrTkpHoDbtvQfmn)gbIqmginNMFZL2tLHdw175k35RcNWpR4Gbw7sdLrYfzkCEyjqbZPjwAG0CA(nxApvgoy9OSuPZucFNVogfu7Gskh3g8ZkUtOtxy)lsNCr10LAjiIhcltng1Q8e60fmvPwW08BeicXyG0CA(nxApvgoybLzU0ybBH1AhnqAon)MlTNkdhSQ3Z1axVeccFNVogfu7Gskh3MbsZP53CP9uz4Gf8)6WxdfZwPBG0CA(nxApvgoyzNZAkO)DuRdKdKLYak)itHpGVoaXSxNb952a2)NLn0bCVAA(9ak0a4QDkFaBWeFaOu9pAaL)Idi5dWWAjZqz0aP508BUe95H9)zzdfh8VilBObuMXv8ZkoS2LgkJK3Rvx4sK0aP508BUe95H9)zzdTmCW6iK)XjgX5HIzR0HFwXzonXsbQjKjXlbhEE8Ccnj1ejf0pGqyIdQB5hRDPHYi5vmGkuR8bYsPugWw1oOKgYkoKMxleIlcvOwLN5Z)LosYvZbrzBWWNG4IqfQv5z(8FPJKhH0YMx2gmqGlYu4bi6ekCvEcnv)dkjpZN)lD02b4tPDYu(aSbWEf)bOWt(as(aYwPErRbO)au7Gs6au40aGNqHtCDa7x(xQ(oaQjK(oGIPcFawpadnzP67au4MoGIjJnaBFN57aoZN)lD0aY6aoHMQ)bLwYbuaCthakLn0by9aOMq67akMk8bGPbWvZbbh)b83aSEauti9DakCthGcNgWIqfQ1bumzSbW)Vha5198Ob8TCG0CA(nxI(8W()SSHwgoy9OSuPZucFNVogfu7Gskh3g8ZkUtOtxy)lsNCr10LAj4WdHdKMtZV5s0Nh2)NLn0YWblOmZLglylSw7i8ZkUtOtxy)lsNCr10LkmXdt(57eJfu7GskxcLzU0ybBH1Ahvco887(NT(ITCpzm7cFnuVNRYJqAzZlbHdKMtZV5s0Nh2)NLn0YWbR69CnW1lHGW35RJrb1oOKYXTb)SI7e60f2)I0jxunDPct8WKF3)S1xSL7jJzx4RH69CvEeslBEjiCG0CA(nxI(8W()SSHwgoyvVNRCNVkCc)SIdvOwLqKmw2qdinh8Sj5rMt9FcD6c7Fr6KlQMUulbXniSm1yuRYtOtxWuLAbtZVrGied)8DIXcQDqjLlR3ZvUZxfovco88ddS2LgkJKlYu48WsGcMttS0aP508BUe95H9)zzdTmCWQEpx5oFv4e(zf3j0PlS)fPtUOA6sTeCiwyewMAmQv5j0PlyQsTGP53iqeIHF(oXyb1oOKYL175k35RcNkbhE(Hbw7sdLrYfzkCEyjqbZPjwAG0CA(nxI(8W()SSHwgoybLzU0ybBH1AhHFwX5(NT(ITCpzm7cFnuVNRYJqAzZl5eAsQjskOFaZ8FcD6c7Fr6KlQMUuHjMHj)8DIXcQDqjLlHYmxASGTWATJkbhEdKMtZV5s0Nh2)NLn0YWbR69CnW1lHGW35RJrb1oOKYXTb)SIZ9pB9fB5EYy2f(AOEpxLhH0YMxYj0KutKuq)aM5)e60f2)I0jxunDPctmdtdKdKLYak)itHpGVoaXSxNb952a8conXsdWN(QP53dKMtZV5s0Nh00br2qX9OSuPZucFNVogfu7Gskh3g8ZkUtOtxy)lsNCr10LAj4qeZqyzQXOwLNqNUGPk1cMMFJarigdKMtZV5s0Nh00br2qldhSoc5FCIrCEOy2kD4NvCyTlnugjVIbuHAL7XJ50elfOMqMeVeC45XZj0PlS)fPdMfgVbsZP53Cj6ZdA6GiBOLHdwlYu4bRxHf5mFXpR4oHoDH9ViDWSW4nqAon)MlrFEqthezdTmCWc(xKLn0akZ4k(zfhw7sdLrY71QlCjsYpINqNUW(xKo5IQPlvyIqe6XZj0KutKuq)qHHjoOULhpNqt1)GsYZGsHVgu4uOEVptDWb3qUNF7XdFNySGAhus5s4Frw2qdOmJRLGdpm845e60f2)I0bZcJ3aP508BUe95bnDqKn0YWbR69CL78vHt4NvCOc1QeIKXYgAaP5GNnjf29Z3jglO2bLuUSEpx5oFv4uj4WZpmWAxAOmsUitHZdlbkyonXsdKMtZV5s0Nh00br2qldhSG)xh(AOy2kD4NvCNqNUW(xKo5IQPl1sWHzyY)j0KutKuq)qHlbQBnqAon)MlrFEqthezdTmCWQEpx5oFv4e(zfhFNySGAhus5Y69CL78vHtLGdp)WaRDPHYi5ImfopSeOG50elnqAon)MlrFEqthezdTmCW6rzPsNPe(oFDmkO2bLuoUn4NvCNqNUW(xKo5IQPl1sWdHE8Ccnj1ejf0puyyc1TginNMFZLOppOPdISHwgoyb)lYYgAaLzCf)SIdRDPHYi59A1fUejnqAon)MlrFEqthezdTmCWYoN1uq)7OwXpR4oHoDH9ViDYfvtxQLGqmnqoqwkLYa8XZwdWljzNoaF89k18B(azPukdWCA(nx6E2kaNStX5GBzZdFnKoc)SIRMqHRHJqAzZHju3YpINqtWeppEGbQqTkHizSSHgqAo4ztsHD)icdKw2b4wVK4b3pQqTkDpBfGt2PsUAoikbhMv2j0u9pOKeINP5z8q1W(NhpiTSdWTEjXdUFuHAv6E2kaNStLC1CquIxUStOP6FqjjeptZZ4HQH9pm84bvOwLqKmw2qdinh8SjPWUFeHbsl7aCRxs8G7hvOwLUNTcWj7ujxnheL4Ll7eAQ(huscXZ08mEOAy)ZJhKw2b4wVK4b3pQqTkDpBfGt2PsUAoikzdMk7eAQ(huscXZ08mEOAy)ddmgilLbGGeonGLWLn0bGaMmMDdOyQWhGx0roBhwLFKPWhinNMFZLUNTcWj70YWblhClBE4RH0r4NvCWqng1Q8rzPsNP53(rfQv5EYy2f(AOEpxLc7(rfQvP7zRaCYovYvZbrj42Gj)iIkuRY9KXSl81q9EUkpcPLnhMqDleiIBkZ9pB9fBz9EUw03djpufoFLhzlFXWJhuHAvk0WFMVbUEudvHlpcPLnhMqDlpEqfQvPdU98aQ1K8iKw2Cyc1TWyGSugacQGYZfnGVoaeWKXSBacCYGsdOyQWhGx0roBhwLFKPWhinNMFZLUNTcWj70YWblhClBE4RH0r4NvCWqng1Q8rzPsNP53(xKPWdq0ju4Q8eAQ(huswngJ6G7e42Io)WavOwL7jJzx4RH69CvkS739pB9fB5EYy2f(AOEpxLhH0YMxYge6hruHAv6E2kaNStLC1CqucUnyYpIOc1QuOH)mFdC9OgQcxkS7XdQqTkDWTNhqTMKc7y4XdQqTkDpBfGt2PsUAoikb3McJXaP508BU09SvaozNwgoy5GBzZdFnKoc)SIdgQXOwLpklv6mn)2pmwKPWdq0ju4Q8eAQ(huswngJ6G7e42Io)Oc1Q09SvaozNk5Q5GOeCBWKFyGkuRY9KXSl81q9EUkf297(NT(ITCpzm7cFnuVNRYJqAzZlbpmnqwkdab8iSuRdWhpBnaVKKD6aES05S99SHoGLWLn0bSNmMDdKMtZV5s3Zwb4KDAz4GLdULnp81q6i8Zko1yuRYhLLkDMMF7hgOc1QCpzm7cFnuVNRsHD)iIkuRs3Zwb4KDQKRMdIsWTbZ8JiQqTkfA4pZ3axpQHQWLc7E8GkuRshC75buRjPWogE8GkuRs3Zwb4KDQKRMdIsWTbZ7XJ7F26l2Y9KXSl81q9EUkpcPLnhMf2pQqTkDpBfGt2PsUAoikb3gmdJbYbYszaiGVMFpqAon)MlD)ZwFXMJB)18B8ZkouHAvUNmMDHVgQ3ZvPW(azPmaF8pB9fB(aP508BU09pB9fBEz4GfHC)lsx4eAkuKS9VXpR4uJrTkFuwQ0zA(T)tOjyIG9Jiw7sdLrsUg2zw3zd1JhS2LgkJK2AXdhH0Ygd)i6(NT(ITCpzm7cFnuVNRYJqAzZHjc9JO7F26l2YkJ4WDNvv5riTS5LGq)8xGHM9sUlWvbgfOtyxZV94bg8xGHM9sUlWvbgfOtyxZVXWJhuHAvUNmMDHVgQ3ZvPWogE8G(CU)AcfUgocPLnhM4HPbsZP53CP7F26l28YWblc5(xKUWj0uOiz7FJFwXPgJAvIEKPWdFnWZEDg0NB(pHoDH9ViDYfvtxQLuym5)eAsQjskOFaHLa1T8JiQqTkrpYu4HVg4zVod6ZnPWUhp1ekCnCeslBomXdtymqAon)MlD)ZwFXMxgoyri3)I0foHMcfjB)B8Zko1yuRY0roBFG0CA(nx6(NT(InVmCWApzm7cFnuVNR4NvCQXOwLOhzk8Wxd8SxNb95MFeXAxAOmsY1WoZ6oBOE8G1U0qzK0wlE4iKw2y4hr3)S1xSLOhzk8Wxd8SxNb95M8iKw2CpEC)ZwFXwIEKPWdFnWZEDg0NBYJSLV(pHoDH9ViDYfvtxQWeHycJbsZP53CP7F26l28YWbR9KXSl81q9EUIFwXPgJAvMoYz7(HbQqTk3tgZUWxd175QuyFG0CA(nx6(NT(InVmCWApzm7cFnuVNR4NvCQXOwLpklv6mn)2pIyTlnugj5AyNzDNnupEWAxAOmsARfpCeslBm8JOAmQvjutHtx2qdC9pKsQnugT8JkuRYJq(hNyeNhkMTsNuy3JhyOgJAvc1u40Ln0ax)dPKAdLrlmginNMFZLU)zRVyZldhSqpYu4HVg4zVod6Zn8ZkouHAvUNmMDHVgQ3ZvPW(aP508BU09pB9fBEz4Gv9EUw03djpufoFXpR4mNMyPa1eYK4424hvOwL7jJzx4RH69CvEeslBomH6w(rfQv5EYy2f(AOEpxLc7(HHAmQv5JYsLotZV9Jimolxbcl1Q0wlUK8AYvUhpNLRaHLAvARfxMDjfgty4XtnHcxdhH0YMdZcpqAon)MlD)ZwFXMxgoyvVNRf99qYdvHZx8ZkoZPjwkqnHmjEj4WZpIOc1QCpzm7cFnuVNRsHDpEolxbcl1Q0wlUm7sC)ZwFXwUNmMDHVgQ3Zv5riTS5y4hruHAvUNmMDHVgQ3Zv5riTS5WeQB5XZz5kqyPwL2AXLhH0YMdtOUfgdKMtZV5s3)S1xS5LHdw175ArFpK8qv48f)SItng1Q8rzPsNP53(rfQv5EYy2f(AOEpxLc7(reruHAvUNmMDHVgQ3Zv5riTS5WeQB5XdQqTkfA4pZ3axpQHQWLc7(rfQvPqd)z(g46rnufU8iKw2Cyc1TWWpIlcvOwLN5Z)LosYvZbboe6XdmwKPWdq0ju4Q8eAQ(husEMp)x6imWyG0CA(nx6(NT(InVmCWcUV7VcNoKPlSFeNAhHFwXPgJAvIEKPWdFnWZEDg0NB(pHoDH9ViDYfvtxQLGzyY)j0emXvy)iIkuRs0JmfE4RbE2RZG(CtkS7XJ7F26l2s0JmfE4RbE2RZG(CtEeslBEjygMWWJhyOgJAvIEKPWdFnWZEDg0NB(pHoDH9ViDYfvtxQLGdpeoqAon)MlD)ZwFXMxgoyDwYPWISf(zfN7F26l2Y9KXSl81q9EUkpcPLnhM4q4aP508BU09pB9fBEz4Gf3CxwtxASWU5u8ZkoZPjwkqnHmjEj4WZpIOpN7VMqHRHJqAzZHzH94bgOc1Qe9itHh(AGN96mOp3Kc7(rCNuju4VatEeslBomH6wE8CwUcewQvPTwC5riTS5WSW(plxbcl1Q0wlUm7s2jvcf(lWKhH0YMJbgdKMtZV5s3)S1xS5LHdwlYu4bRxHf5mFXpR4mNMyPa1eYK4LGqpEoHMQ)bLK7Wj7EKFt8bYbYsza(4XsT16a8cOjl1K4dKMtZV5s3JLARvoUfzkCEyjq4NvCyTlnugj5AyNzDNnupEWAxAOmsARfpCesl7bsZP53CP7XsT1kVmCWIx0oKzdnGm5k(zf3j0PlS)fPtUOA6sTKnf2V7F26l2Y9KXSl81q9EUkpcPLnhMf2pmuJrTkrpYu4HVg4zVod6Zn)yTlnugj5AyNzDNn0bsZP53CP7XsT1kVmCWIx0oKzdnGm5k(zfhmuJrTkrpYu4HVg4zVod6Zn)yTlnugjT1IhocPL9aP508BU09yP2ALxgoyXlAhYSHgqMCf)SItng1Qe9itHh(AGN96mOp38JiQqTkrpYu4HVg4zVod6ZnPWUFeXAxAOmsY1WoZ6oBO(pHoDH9ViDYfvtxQLGzyYJhS2LgkJK2AXdhH0Y2)j0PlS)fPtUOA6sTeemM84bRDPHYiPTw8WriTS9FwUcewQvPTwC5riTS5WeZJHhpWavOwLOhzk8Wxd8SxNb95Muy3V7F26l2s0JmfE4RbE2RZG(CtEeslBogdKMtZV5s3JLARvEz4GLH(iZ2087alrIIFwX5(NT(ITCpzm7cFnuVNRYJqAzZHzH9J1U0qzKKRHDM1D2q9JOAmQvj6rMcp81ap71zqFU5)e60f2)I0jxunDPctemM87(NT(ITe9itHh(AGN96mOp3KhH0YMdt884bgQXOwLOhzk8Wxd8SxNb95ggdKMtZV5s3JLARvEz4GLH(iZ2087alrIIFwXH1U0qzK0wlE4iKw2dKMtZV5s3JLARvEz4GfhU5GGrbfofe6I)PW9f)SIdRDPHYijxd7mR7SH6hr3)S1xSL7jJzx4RH69CvEeslBomlShpQXOwLPJC2ogdKMtZV5s3JLARvEz4GfhU5GGrbfofe6I)PW9f)SIdRDPHYiPTw8WriTShinNMFZLUhl1wR8YWbRkJ4WDNvv8ZkoyGkuRY9KXSl81q9EUkf29dduHAvIEKPWdFnWZEDg0NBsHD)iYFbgA2l5UaxfyuGoHDn)2Jh(lWqZEjX(mttgf4pdl1kg4NTs3jSRHejsALMs42GF2kDNWUgGYEuJHBd(zR0Dc7AiR44Vadn7Le7ZmnzuG)mSuRdKdKLYaqqrzPsNP53d4E1087bsZP53C5JYsLotZVXDeY)4eJ48qXSv6WpR4mNMyPa1eYK4LGRW(XAxAOmsEfdOc1kFG0CA(nx(OSuPZ087YWbl4Frw2qdOmJR4781XOGAhus542GFwXbJ1RY69CnujS0j10br2q9dduHAvcrYyzdnG0CWZMKc7(pHMkbxHhinNMFZLpklv6mn)UmCWQEpx5oFv4e(zfhQqTkHizSSHgqAo4ztYJmN6NVtmwqTdkPCz9EUYD(QWPsWHNFyG1U0qzKCrMcNhwcuWCAILginNMFZLpklv6mn)UmCW6rzPsNPe(oFDmkO2bLuoUn4NvCOc1QeIKXYgAaP5GNnjpYC6aP508BU8rzPsNP53LHdwqzMlnwWwyT2r4NvC8DIXcQDqjLlHYmxASGTWATJkbhE(r8e60f2)I0jxunDPcZnyYJNtOjPMiPG(b8kbQBHHhpiUiuHAvEMp)x6ijxnheWeHE8SiuHAvEMp)x6i5riTS5WCdcXyG0CA(nx(OSuPZ087YWbR69CnW1lHGWpR4mNMyPa1eYK4424hRDPHYiz9EUg46Lqqb33lHu5dKMtZV5YhLLkDMMFxgoyb)lYYgAaLzCf)SIdRDPHYi59A1fUej5NVtmwqTdkPCj8VilBObuMX1sWH3aP508BU8rzPsNP53LHdwqzMlnwWwyT2r4NvC8DIXcQDqjLlHYmxASGTWATJkbhEdKMtZV5YhLLkDMMFxgoyvVNRbUEjee(oFDmkO2bLuoUn4NvCWqng1Q0WAmRDWj)WavOwLqKmw2qdinh8SjPWUhpQXOwLgwJzTdo5hgyTlnugjVxRUWLijpEWAxAOmsEVwDHlrs(pHMKAIKc6hWReCqDRbsZP53C5JYsLotZVldhSG)fzzdnGYmUIFwXH1U0qzK8ET6cxIKginNMFZLpklv6mn)UmCW6rzPsNPe(oFDmkO2bLuoUndKdKLYaqa)NLn0bGa83aqqrzPsNP53fAaIQDkFaBW0a4K77fFaOu9pAaiGjJz3a(6aqaUNRdW9ij(a(ADa(WlXaP508BU8rzPsNP53H9)zzdf3ri)JtmIZdfZwPd)SIdRDPHYi5vmGkuRCpEmNMyPa1eYK4LGdVbsZP53C5JYsLotZVd7)ZYgAz4Gv9EUg46Lqq4NvCMttSuGAczsCCB8J1U0qzKSEpxdC9siOG77LqQ8bsZP53C5JYsLotZVd7)ZYgAz4G1JYsLotj8D(6yuqTdkPCCBWpR4qfQvjejJLn0asZbpBsEK50bsZP53C5JYsLotZVd7)ZYgAz4Gf8VilBObuMXv8ZkoS2LgkJK3Rvx4sK0aP508BU8rzPsNP53H9)zzdTmCWckZCPXc2cR1oc)SIJVtmwqTdkPCjuM5sJfSfwRDuj4WZ)j0PlS)fPtUOA6sfMiymnqAon)MlFuwQ0zA(Dy)Fw2qldhSQ3Z1axVeccFNVogfu7Gskh3g8ZkUtOtxy)lsNCr10LkmlvyAG0CA(nx(OSuPZ087W()SSHwgoy9OSuPZucFNVogfu7Gskh3g8ZkUtOPsWv4bsZP53C5JYsLotZVd7)ZYgAz4Gv9EUYD(QWj8ZkoZPjwkqnHmjEj4Wm)WaRDPHYi5ImfopSeOG50elnqoqwkdWNAU0ydWlGMSutIpqAon)MlpZLgJJdL9)kufoFXpR4qfQv5EYy2f(AOEpxLc7dKMtZV5YZCPX4LHdwO0XPdISHIFwXHkuRY9KXSl81q9EUkf2hinNMFZLN5sJXldhSSZznf2fyCc)SIdryGkuRY9KXSl81q9EUkf29BonXsbQjKjXlbhEy4XdmqfQv5EYy2f(AOEpxLc7(r8eAsUOA6sTeCi0)j0PlS)fPtUOA6sTeCiymHXaP508BU8mxAmEz4GflHcx5beKkSGIKAf)SIdvOwL7jJzx4RH69CvkSpqAon)MlpZLgJxgoyzTJ46zSGZym8ZkouHAvUNmMDHVgQ3ZvPWUFuHAvsi3)I0foHMcfjB)BPW(aP508BU8mxAmEz4GvnpcL9)c)SIdvOwL7jJzx4RH69CvEeslBomX5L9JkuRsc5(xKUWj0uOiz7Flf2hinNMFZLN5sJXldhSqnOHVg0lDqWXpR4qfQv5EYy2f(AOEpxLc7(nNMyPa1eYK4424hruHAvUNmMDHVgQ3Zv5riTS5WeH(vJrTkDpBfGt2PsQnugT84bgQXOwLUNTcWj7uj1gkJw(rfQv5EYy2f(AOEpxLhH0YMdZcJXa5azPmar16LDRbWZgkJqqO2bL0bCVAA(9aP508BUKRwVSBH7iK)XjgX5HIzR0HFwXH1U0qzK8kgqfQv(aP508BUKRwVSBvgoy9OSuPZuc)SIdvOwLqKmw2qdinh8Sj5rMthinNMFZLC16LDRYWbR69CnW1lHGWpR4WAxAOmswVNRbUEjeuW99siv(aP508BUKRwVSBvgoybLzU0ybBH1AhHFwXbJfzk8aeDcfUkpHMQ)bLKN5Z)LoYpIlcvOwLN5Z)LosYvZbbmrOhplcvOwLN5Z)LosEeslBomlvymqAon)Ml5Q1l7wLHdw175AGRxcbHFwX5(NT(IT8iK)XjgX5HIzR0jpcPLnhM4Wdbc1T8RgJAvc1u40Ln0ax)d5aP508BUKRwVSBvgoyb)lYYgAaLzCf)SIdRDPHYi59A1fUejnqAon)Ml5Q1l7wLHdwpklv6mLWpR4GbQqTkR37Zuh2fyCskS7xng1QSEVptDyxGXjpEWAxAOmsUitHZdlbkyonXs(rfQv5ImfopSeijxnheWeZ845eAsQjskOFaZGjoOU1aP508BUKRwVSBvgoyvVNRbUEjee(zf3j0PlS)fPtUOA6sfMiUbHLPgJAvEcD6cMQulyA(nceHymqAon)Ml5Q1l7wLHdwpklv6mLWpR4oHoDH9ViDYfvtxQLGiEiSm1yuRYtOtxWuLAbtZVrGieJbsZP53CjxTEz3QmCWQEpxdC9siObsZP53CjxTEz3QmCWc(FD4RHIzR0nqAon)Ml5Q1l7wLHdw25SMc6Fh16a5azPmGcUSHGu(aP508BUuVSHGuoUS5Utqnugfk1cwRcidlcB6i8ZkouHAvUNmMDHVgQ3ZvPWUhpQDqjvQjskOFy3Pb8WemrOhpOpN7VMqHRHJqAzZHjEBgilLbuaCAa6LneKoGIPcFakCAaWtOWjUoaIRjstP1aWAmbc)bumzSbGsdqGtRbuZJRdW61a2T8O1akMk8bGaMmMDd4Rdab4EUkhinNMFZL6LneKYldhS0lBiiDd(zfhmWAxAOmsY3jxwtAf0lBii1pQqTk3tgZUWxd175Quy3pIWqng1QmDKZ294rng1QmDKZ29JkuRY9KXSl81q9EUkpcPLnVeCBWeg(reg6LneKkXtc34b3)S1xS94rVSHGujEs3)S1xSLhH0YM7Xdw7sdLrs9Ygcsd7x(xQ(IBdgE8Ox2qqQCJevOwdlHZ087sWvtOW1WriTS5dKMtZV5s9Ygcs5LHdw6LneKIh(zfhmWAxAOmsY3jxwtAf0lBii1pQqTk3tgZUWxd175Quy3pIWqng1QmDKZ294rng1QmDKZ29JkuRY9KXSl81q9EUkpcPLnVeCBWeg(reg6LneKk3iHB8G7F26l2E8Ox2qqQCJ09pB9fB5riTS5E8G1U0qzKuVSHG0W(L)LQV4WddpE0lBiivINevOwdlHZ087sWvtOW1WriTS5dKLYa8I1b8nZ3b8nnGVhGaNgGEzdbPdy)ES5I4dWgaQqTI)ae40au40aEfoDd47b4(NT(ITCaiO3aY6aAkv40na9YgcshW(9yZfXhGnauHAf)biWPbG(k8b89aC)ZwFXwoqAon)Ml1lBiiLxgoyPx2qq6g8ZkoyOx2qqQCJeUXdcCkGkuR(ruVSHGujEs3)S1xSLhH0YM7Xdm0lBiivINeUXdcCkGkuRy4XJ7F26l2Y9KXSl81q9EUkpcPLnVe8W0aP508BUuVSHGuEz4GLEzdbP4HFwXbd9YgcsL4jHB8GaNcOc1QFe1lBiivUr6(NT(IT8iKw2CpEGHEzdbPYns4gpiWPaQqTIHhpU)zRVyl3tgZUWxd175Q8iKw28sWdtrr(o5IEJhc3e1OgJa]] )


end
