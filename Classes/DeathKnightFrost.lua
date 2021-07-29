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


    spec:RegisterPack( "Frost DK", 20210729, [[d4K80cqiqrpsIexsOiTjHQpPsmkOWPGIwfeHELeLzbv1TGOc2fr)cuyyquoMkPLbv5zsGMgerxdI02GOkFtiiJtOioNqaRtcyEGsUhuzFsehuiOwOevpuOWefcexeIkzJqe4JcbQrkeiDsiQQvcIEjevOMPeP2Pq0pHOIgkebTuHIYtjyQsqxfIkK(kevQXck1EPQ)kyWahMYIH0JPYKvXLr2SK(minAq1PfTAiQq8Aqy2OCBiSBP(TQgUk1XfkQwUsphvtN01j02HsFxcnEHqNxO06LiP5lK2VI9x9f6foMs(iXdz4Dfzri8IasKftqsKHuKNxqJ9M8c3Mdcdk5fAdb5fqc2NRdiccYXEHBlw2BhFHEb(lUoYlax1BEbGbmGMkCruP7radEIqKzA(TBTQcdEIWbdVaQyYuKF7r9chtjFK4Hm8UISieErajYIjfmcGuK6fmrf(VEbHerm8cWZZHApQx4qCNxicczk8bGCCNqHRdajyFUoqcPil2bGxea)bGhYW76a5azmGBnuIpqICyaXmcXJLodGzCf5aNCFFgGi3Gsd4RdigWTS5d4Rda57Oby8bK6aopX7l6aUzwSdOiXydi7bCVMtthjhiromGiiFFrhGdU1nXgasaJ4WDRv1bCe3SHoGYxYu4d4Rdqi7ZAqFUj9cSKRCFHEHhLLkTMMFhU)NLnuFH(iV6l0lqTHYOJVCVG508BVWsi(LtmIZdfZwP1lCiUBZBn)2lGe(plBOdaj43bGCIYsLwtZVlWaeuBv(aUISbWj33h(aqP6V0aqctgZ2b81bGeSpxhG7rq8b816aIreeVGBtL208cyTnnugj3IbuXALpGOrhG50elfOMqKeFaLGBa45vFK45l0lqTHYOJVCVGBtL208cMttSuGAcrs8bGBaxhq8bG120qzKSUpxdCDtiOG77JyQCVG508BVqDFUg46MqqE1hzb9f6fO2qz0XxUxWCA(Tx4rzPsRPKxWTPsBAEbuXAvcrYyzdnGWCWZMKlzo1l4I1XOGAlus5(iV6vFKiPVqVa1gkJo(Y9cUnvAtZlG120qzKCFT6cBIG8cMtZV9cW)ISSHgqzgx9QpsK6l0lqTHYOJVCVGBtL208c8BIXcQTqjLlHYmxASGDWATJgqj4gaEdi(awXoDH7ViTYdvtxQdawda5HmVG508BVauM5sJfSdwRDKx9rI88f6fO2qz0XxUxWCA(TxOUpxdCDtiiVGBtL208cRyNUW9xKw5HQPl1baRbeHqMxWfRJrb1wOKY9rE1R(iJq(c9cuBOm64l3lyon)2l8OSuP1uYl42uPnnVWk20akb3akOxWfRJrb1wOKY9rE1R(iJj(c9cuBOm64l3l42uPnnVG50elfOMqKeFaLGBai5aIpayoaS2MgkJKhYu48WrKcMttSKxWCA(TxOUpx5Uyv4Kx9QxW9StaozR6l0h5vFHEbQnugD8L7fmNMF7fCWTS5HVgsh5foe3T5TMF7fqokNgWrCZg6aqctgZ2bumv4da57iNDdJYxYu4Eb3MkTP5fG5auJrTkFuwQ0AA(TKAdLrNbeFaOI1Q8ozmBdFnu3NRsX7beFaOI1Q09StaozRk5Q5GyaLGBaxr2aIpauXAvENmMTHVgQ7Zv5siSS5dawdaQ7maK4aWyaxhqzdW9p78fBzDFUwm2fbpuf3yLlzNyhaME1hjE(c9cuBOm64l3lyon)2l4GBzZdFnKoYlCiUBZBn)2lGCkQ88qd4RdajmzmBhGiNmO0akMk8bG8DKZUHr5lzkCVGBtL208cWCaQXOwLpklvAnn)wsTHYOZaIpGdzk8aeDcfUkxXMQ)cLKvJXOo4wrUDODaXhamhaQyTkVtgZ2Wxd195Qu8EaXhG7F25l2Y7KXSn81qDFUkxcHLnFaLmGRiDaXhagdavSwLUNDcWjBvjxnhedOeCd4kYgq8bGkwRsXg(ZInW1LAOkCP49aIgDaOI1Q09StaozRk5Q5GyaLGBaxl4aW0R(ilOVqVa1gkJo(Y9cUnvAtZlaZbOgJAv(OSuP108Bj1gkJodi(aG5aoKPWdq0ju4QCfBQ(luswngJ6GBf52H2beFaOI1Q09StaozRk5Q5GyaLGBaxr2aIpayoauXAvENmMTHVgQ7ZvP49aIpa3)SZxSL3jJzB4RH6(CvUeclB(akza4HmVG508BVGdULnp81q6iV6Jej9f6fO2qz0XxUxWCA(TxWb3YMh(AiDKx4qC3M3A(TxajCjSuRdigp7mGiOKT6aES06S77SHoGJ4Mn0bCNmMTEb3MkTP5fuJrTkFuwQ0AA(TKAdLrNbeFaWCaOI1Q8ozmBdFnu3NRsX7beFaymauXAv6E2jaNSvLC1CqmGsWnGRi5aIpauXAvk2WFwSbUUudvHlfVhq0OdavSwLUNDcWjBvjxnhedOeCd4AeyarJoa3)SZxSL3jJzB4RH6(CvUeclB(aG1ak4aIpauXAv6E2jaNSvLC1CqmGsWnGRi5aW0RE1l8OSuP108BFH(iV6l0lqTHYOJVCVG508BVWsi(LtmIZdfZwP1lCiUBZBn)2lGCIYsLwtZVhW(QP53Eb3MkTP5fmNMyPa1eIK4dOeCdOGdi(aWABAOmsUfdOI1k3R(iXZxOxGAdLrhF5Eb3MkTP5fG5aoVkR7Z1qLWsRuthezdDaXhamhaQyTkHizSSHgqyo4ztsX7beFaRytdOeCdOGEbZP53Eb4Frw2qdOmJRE1hzb9f6fO2qz0XxUxWTPsBAEbuXAvcrYyzdnGWCWZMKlzoDaXha)MySGAlus5Y6(CL7IvHtdOeCdaVbeFaWCayTnnugjpKPW5HJifmNMyjVG508BVqDFUYDXQWjV6Jej9f6fO2qz0XxUxWCA(Tx4rzPsRPKxWTPsBAEbuXAvcrYyzdnGWCWZMKlzo1l4I1XOGAlus5(iV6vFKi1xOxGAdLrhF5Eb3MkTP5f43eJfuBHskxcLzU0yb7G1AhnGsWna8gq8bGXawXoDH7ViTYdvtxQdawd4kYgq0OdyfBsQjckOFaVbuYaG6odaZben6aWyahcvSwLRvQ)MosYvZbXaG1aq6aIgDahcvSwLRvQ)MosUeclB(aG1aUI0bGPxWCA(TxakZCPXc2bR1oYR(irE(c9cuBOm64l3l42uPnnVG50elfOMqKeFa4gW1beFayTnnugjR7Z1ax3eck4((iMk3lyon)2lu3NRbUUjeKx9rgH8f6fO2qz0XxUxWTPsBAEbS2MgkJK7Rvxyte0aIpa(nXyb1wOKYLW)ISSHgqzgxhqj4gaEEbZP53Eb4Frw2qdOmJRE1hzmXxOxGAdLrhF5Eb3MkTP5f43eJfuBHskxcLzU0yb7G1AhnGsWna88cMtZV9cqzMlnwWoyT2rE1hzeWxOxGAdLrhF5EbZP53EH6(CnW1nHG8cUnvAtZlaZbOgJAvAynM1o4KKAdLrNbeFaWCaOI1QeIKXYgAaH5GNnjfVhq0Odqng1Q0WAmRDWjj1gkJodi(aG5aWABAOmsUVwDHnrqdiA0bG120qzKCFT6cBIGgq8bSInj1ebf0pG3akb3aG6oEbxSogfuBHsk3h5vV6J8kY8f6fO2qz0XxUxWTPsBAEbS2MgkJK7RvxyteKxWCA(Txa(xKLn0akZ4Qx9rE9QVqVa1gkJo(Y9cMtZV9cpklvAnL8cUyDmkO2cLuUpYRE1REb0Nh00br2q9f6J8QVqVa1gkJo(Y9cMtZV9cpklvAnL8cUyDmkO2cLuUpYREb3MkTP5fwXoDH7ViTYdvtxQdOeCdaJbGKiDaLna1yuRYvStxWuLArtZVLuBOm6maK4aq6aW0lCiUBZBn)2lu(sMcFaFDaczFwd6ZTbeHDAILgqm7vtZV9Qps88f6fO2qz0XxUxWTPsBAEbS2MgkJKBXaQyTYhq0OdWCAILcutisIpGsWna8gq0Odyf70fU)I0oaynGcINxWCA(Txyje)YjgX5HIzR06vFKf0xOxGAdLrhF5Eb3MkTP5fwXoDH7ViTdawdOG45fmNMF7foKPWdwFchYzX6vFKiPVqVa1gkJo(Y9cUnvAtZlG120qzKCFT6cBIGgq8bGXawXoDH7ViTYdvtxQdawdaPiDarJoGvSjPMiOG(HcoayHBaqDNben6awXMQ)cLKRbLcFnOWPqD)sL6GdUH4o)wsTHYOZaIgDa8BIXcQTqjLlH)fzzdnGYmUoGsWna8gaMdiA0bSID6c3FrAhaSgqbXZlyon)2la)lYYgAaLzC1R(irQVqVa1gkJo(Y9cUnvAtZlGkwRsisglBObeMdE2Ku8EaXha)MySGAlus5Y6(CL7IvHtdOeCdaVbeFaWCayTnnugjpKPW5HJifmNMyjVG508BVqDFUYDXQWjV6Je55l0lqTHYOJVCVGBtL208cRyNUW9xKw5HQPl1bucUbGKiBaXhWk2Kuteuq)qbhqjdaQ74fmNMF7fG)Bh(AOy2kTE1hzeYxOxGAdLrhF5Eb3MkTP5f43eJfuBHskxw3NRCxSkCAaLGBa4nG4daMdaRTPHYi5HmfopCePG50el5fmNMF7fQ7ZvUlwfo5vFKXeFHEbQnugD8L7fmNMF7fEuwQ0Ak5fCBQ0MMxyf70fU)I0kpunDPoGsgaEiDarJoGvSjPMiOG(HcoaynaOUJxWfRJrb1wOKY9rE1R(iJa(c9cuBOm64l3l42uPnnVawBtdLrY91QlSjcYlyon)2la)lYYgAaLzC1R(iVImFHEbQnugD8L7fCBQ0MMxyf70fU)I0kpunDPoGsgasrMxWCA(TxWwN1uq)DPw9Qx9c2t(c9rE1xOxGAdLrhF5EHdXDBER53EHi8JCnGy2RMMF7fmNMF7fwcXVCIrCEOy2kTE1hjE(c9cuBOm64l3l42uPnnVGAmQvzDFUYDXQWjj1gkJoEbZP53EbOmZLglyhSw7iV6JSG(c9cuBOm64l3lyon)2lu3NRbUUjeKxWfRJrb1wOKY9rE1l42uPnnVG7F25l2YLq8lNyeNhkMTsRCjew28balCdaVbGehau3zaXhGAmQvjutHtB2qdC9xesQnugD8chI728wZV9cib)IqKzPBa299(Md(a0FaULmLgGnGBojE(bCV5VPg7auBHs6ayjxhq93by33SyZg6awRu)nD0aYEa2tE1hjs6l0lqTHYOJVCVGBtL208cyTnnugj3xRUWMiiVG508BVa8VilBObuMXvV6JeP(c9cuBOm64l3l42uPnnVawBtdLrYdzkCE4isbZPjwAaXhaQyTkpKPW5HJij5Q5GyaWAaiPxWCA(Tx4rzPsRPKx9rI88f6fO2qz0XxUxWTPsBAEbuXAvcrYyzdnGWCWZMKlzoDaXhamhawBtdLrYdzkCE4isbZPjwYlyon)2lu3NRCxSkCYR(iJq(c9cuBOm64l3l42uPnnVWk2PlC)fPvEOA6sDaWAaymGRiDaLna1yuRYvStxWuLArtZVLuBOm6maK4ak4aW0lyon)2laLzU0yb7G1Ah5vFKXeFHEbQnugD8L7fmNMF7fQ7Z1ax3ecYl42uPnnVWk2PlC)fPvEOA6sDaWAaymGRiDaLna1yuRYvStxWuLArtZVLuBOm6maK4aq6aW0l4I1XOGAlus5(iV6vFKraFHEbQnugD8L7fCBQ0MMxaMdaRTPHYi5HmfopCePG50el5fmNMF7fQ7ZvUlwfo5vFKxrMVqVa1gkJo(Y9cMtZV9cpklvAnL8cUnvAtZlSID6c3FrALhQMUuhqjdaJbGhshqzdqng1QCf70fmvPw008Bj1gkJodajoaKoam9cUyDmkO2cLuUpYRE1h51R(c9cMtZV9cqzMlnwWoyT2rEbQnugD8L7vFKxXZxOxGAdLrhF5EbZP53EH6(CnW1nHG8cUyDmkO2cLuUpYRE1h51c6l0lyon)2la)3o81qXSvA9cuBOm64l3R(iVIK(c9cMtZV9c26SMc6Vl1QxGAdLrhF5E1REb3JLARvUVqFKx9f6fO2qz0XxUxWCA(Tx4qMcNhoIKx4qC3M3A(TxigpwQTwhqegnzPMe3l42uPnnVawBtdLrsUgUzw3zdDarJoaS2MgkJK25WdlHWY2R(iXZxOxGAdLrhF5Eb3MkTP5fwXoDH7ViTYdvtxQdOKbCTGdi(aC)ZoFXwENmMTHVgQ7Zv5siSS5dawdOGdi(aG5auJrTkrxYu4HVg4zFwd6Znj1gkJodi(aWABAOmsY1WnZ6oBOEbZP53EbErBrKn0aIKRE1hzb9f6fO2qz0XxUxWTPsBAEbyoa1yuRs0LmfE4RbE2N1G(CtsTHYOZaIpaS2MgkJK25WdlHWY2lyon)2lWlAlISHgqKC1R(irsFHEbQnugD8L7fCBQ0MMxqng1QeDjtHh(AGN9znOp3KuBOm6mG4daJbGkwRs0LmfE4RbE2N1G(CtkEpG4daJbG120qzKKRHBM1D2qhq8bSID6c3FrALhQMUuhqjdajr2aIgDayTnnugjTZHhwcHL9aIpGvStx4(lsR8q10L6akzaipKnGOrhawBtdLrs7C4HLqyzpG4dyT8eiSuRs7C4YLqyzZhaSgqeyayoGOrhamhaQyTkrxYu4HVg4zFwd6ZnP49aIpa3)SZxSLOlzk8Wxd8SpRb95MCjew28bGPxWCA(TxGx0wezdnGi5Qx9rIuFHEbQnugD8L7fCBQ0MMxW9p78fB5DYy2g(AOUpxLlHWYMpaynGcoG4daRTPHYijxd3mR7SHoG4daJbOgJAvIUKPWdFnWZ(Sg0NBsQnugDgq8bSID6c3FrALhQMUuhaSgaYdzdi(aC)ZoFXwIUKPWdFnWZ(Sg0NBYLqyzZhaSgaEdiA0baZbOgJAvIUKPWdFnWZ(Sg0NBsQnugDgaMEbZP53Ebd9rKTP53bwIa1R(irE(c9cuBOm64l3l42uPnnVawBtdLrs7C4HLqyz7fmNMF7fm0hr2MMFhyjcuV6Jmc5l0lqTHYOJVCVGBtL208cyTnnugj5A4MzDNn0beFayma3)SZxSL3jJzB4RH6(CvUeclB(aG1ak4aIgDaQXOwLPJC2TKAdLrNbGPxWCA(TxGd3CqWOGcNcIDXFv4X6vFKXeFHEbQnugD8L7fCBQ0MMxaRTPHYiPDo8WsiSS9cMtZV9cC4Mdcgfu4uqSl(RcpwV6Jmc4l0lqTHYOJVCVGBtL208cWCaOI1Q8ozmBdFnu3NRsX7beFaWCaOI1QeDjtHh(AGN9znOp3KI3di(aWya8xKHM9rElYvrgfOv8wZVLuBOm6mGOrha)fzOzFKyFMPjJc8NHLAvsTHYOZaW0lKTs7kERHS6f4Vidn7Je7ZmnzuG)mSuREHSvAxXBnKiqqN0uYlC1lyon)2luzehUBTQ6fYwPDfV1au2JAmVWvV6vVWAU0yCFH(iV6l0lqTHYOJVCVG508BVak7)tOkUX6foe3T5TMF7fIzMln2aIWOjl1K4Eb3MkTP5fqfRv5DYy2g(AOUpxLI3E1hjE(c9cuBOm64l3l42uPnnVaQyTkVtgZ2Wxd195Qu82lyon)2lGslNwiYgQx9rwqFHEbQnugD8L7fCBQ0MMxaJbaZbGkwRY7KXSn81qDFUkfVhq8byonXsbQjejXhqj4gaEdaZben6aG5aqfRv5DYy2g(AOUpxLI3di(aWyaRytYdvtxQdOeCdaPdi(awXoDH7ViTYdvtxQdOeCda5HSbGPxWCA(TxWwN1u4wKXjV6Jej9f6fO2qz0XxUxWTPsBAEbuXAvENmMTHVgQ7ZvP4TxWCA(TxGLqHR8aYrepqrqT6vFKi1xOxGAdLrhF5Eb3MkTP5fqfRv5DYy2g(AOUpxLI3di(aqfRvjH4(lsByfBkuKS7VLI3EbZP53EbRDexxJfCgJ5vFKipFHEbQnugD8L7fCBQ0MMxavSwL3jJzB4RH6(CvUeclB(aGfUbetgq8bGkwRscX9xK2Wk2uOiz3FlfV9cMtZV9c1Cju2)hV6Jmc5l0lqTHYOJVCVGBtL208cOI1Q8ozmBdFnu3NRsX7beFaMttSuGAcrs8bGBaxhq8bGXaqfRv5DYy2g(AOUpxLlHWYMpaynaKoG4dqng1Q09StaozRkP2qz0zarJoayoa1yuRs3Zob4KTQKAdLrNbeFaOI1Q8ozmBdFnu3NRYLqyzZhaSgqbhaMEbZP53EbudA4RbDtheCV6vVa6Zd3)ZYgQVqFKx9f6fO2qz0XxUxWCA(Txa(xKLn0akZ4Qx4qC3M3A(TxO8Lmf(a(6aeY(Sg0NBd4(Fw2qhW(QP53dOadGR2Q8bCfz8bGs1FPbu(lmGKpadRLmdLrEb3MkTP5fWABAOmsUVwDHnrqE1hjE(c9cuBOm64l3l42uPnnVG50elfOMqKeFaLGBa4nGOrhWk2Kuteuq)ashaSWnaOUZaIpaS2MgkJKBXaQyTY9cMtZV9clH4xoXiopumBLwV6JSG(c9cuBOm64l3lyon)2l8OSuP1uYl42uPnnVWk2PlC)fPvEOA6sDaLGBa4HuVGlwhJcQTqjL7J8Qx9rIK(c9cuBOm64l3l42uPnnVWk2PlC)fPvEOA6sDaWAa4HSbeFa8BIXcQTqjLlHYmxASGDWATJgqj4gaEdi(aC)ZoFXwENmMTHVgQ7Zv5siSS5dOKbGuVG508BVauM5sJfSdwRDKx9rIuFHEbQnugD8L7fmNMF7fQ7Z1ax3ecYl42uPnnVWk2PlC)fPvEOA6sDaWAa4HSbeFaU)zNVylVtgZ2Wxd195QCjew28buYaqQxWfRJrb1wOKY9rE1R(irE(c9cuBOm64l3l42uPnnVaQyTkHizSSHgqyo4ztYLmNoG4dyf70fU)I0kpunDPoGsgagd4kshqzdqng1QCf70fmvPw008Bj1gkJodajoaKoamhq8bWVjglO2cLuUSUpx5Uyv40akb3aWBaXhamhawBtdLrYdzkCE4isbZPjwYlyon)2lu3NRCxSkCYR(iJq(c9cuBOm64l3l42uPnnVWk2PlC)fPvEOA6sDaLGBaymGcI0bu2auJrTkxXoDbtvQfnn)wsTHYOZaqIdaPdaZbeFa8BIXcQTqjLlR7ZvUlwfonGsWna8gq8baZbG120qzK8qMcNhoIuWCAIL8cMtZV9c195k3fRcN8QpYyIVqVa1gkJo(Y9cUnvAtZl4(ND(IT8ozmBdFnu3NRYLqyzZhqjdyfBsQjckOFajhq8bSID6c3FrALhQMUuhaSgasISbeFa8BIXcQTqjLlHYmxASGDWATJgqj4gaEEbZP53EbOmZLglyhSw7iV6Jmc4l0lqTHYOJVCVG508BVqDFUg46MqqEb3MkTP5fC)ZoFXwENmMTHVgQ7Zv5siSS5dOKbSInj1ebf0pGKdi(awXoDH7ViTYdvtxQdawdajrMxWfRJrb1wOKY9rE1RE1lCVK7rGAQVqFKx9f6fO2qz0XxUx4V9cCsZQxWTPsBAEbDZgcsL6vjCJhe5uavSwhq8bGXaG5auJrTkrxYu4HVg4zFwd6Znj1gkJodi(aWya6MneKk1Rs3)SZxSLhX1087bethG7F25l2Y7KXSn81qDFUkpIRP53da3aq2aWCarJoa1yuRs0LmfE4RbE2N1G(CtsTHYOZaIpamgG7F25l2s0LmfE4RbE2N1G(CtEextZVhqmDa6MneKk1Rs3)SZxSLhX1087bGBaiBayoGOrhGAmQvz6iNDlP2qz0zay6foe3T5TMF7fqUWAmrtj(aSbOB2qqkFaU)zNVyJ)aoj28qNbGg7aUtgZ2b81bu3NRd43bGUKPWhWxhap7ZAqFUDHpa3)SZxSLda5xhqQx4daRXePba34dO)bSecl7dTdyjvC7bCf)bqmonGLuXThaYKiv6fWABOneKxq3SHG0W1ap225fmNMF7fWABAOmYlG1yIuGyCYlGmjs9cynMi5fU6vFK45l0lqTHYOJVCVWF7f4KMvVG508BVawBtdLrEbS2gAdb5f0nBiinGxGhB78cUnvAtZlOB2qqQuXtc34brofqfR1beFaymayoa1yuRs0LmfE4RbE2N1G(CtsTHYOZaIpamgGUzdbPsfpP7F25l2YJ4AA(9aIPdW9p78fB5DYy2g(AOUpxLhX1087bGBaiBayoGOrhGAmQvj6sMcp81ap7ZAqFUjP2qz0zaXhagdW9p78fBj6sMcp81ap7ZAqFUjpIRP53diMoaDZgcsLkEs3)SZxSLhX1087bGBaiBayoGOrhGAmQvz6iNDlP2qz0zay6fWAmrkqmo5fqMePEbSgtK8cx9QpYc6l0lqTHYOJVCVWF7f4KMvVGBtL208cWCa6MneKk1Rs4gpiYPaQyToG4dq3SHGuPINeUXdICkGkwRdiA0bOB2qqQuXtc34brofqfR1beFaymamgGUzdbPsfpP7F25l2YJ4AA(9aGXa0nBiivQ4jrfR1WrCnn)EayoaK4aWyaxLiDaLnaDZgcsLkEs4gpGkwRsUUudvHpamhasCaymaS2MgkJK6MneKgWlWJTDdaZbG5akzaymamgGUzdbPs9Q09p78fB5rCnn)EaWya6MneKk1RsuXAnCextZVhaMdajoamgWvjshqzdq3SHGuPEvc34buXAvY1LAOk8bG5aqIdaJbG120qzKu3SHG0W1ap22namhaMEHdXDBER53EbKlUMimL4dWgGUzdbP8bG1yI0aqJDaUhXTTzdDakCAaU)zNVypGVoafonaDZgcsXFaNeBEOZaqJDakCAahX1087b81bOWPbGkwRdi1bCVp28qC5aIGA8bydGRl1qv4daXFYAs7a0FaqtS0aSbapHcN2bCV5VPg7a0FaCDPgQcFa6MneKYXFagFafjgBagFa2aq8NSM0oG6VdiRdWgGUzdbPdOyYyd43bumzSb0VoaESTBaftf(aC)ZoFXMl9cyTn0gcYlOB2qqA4EZFtnwVG508BVawBtdLrEbSgtKceJtEHREbSgtK8c45vFKiPVqVa1gkJo(Y9c)TxGtQxWCA(TxaRTPHYiVawJjsEb1yuRsOMcN2SHg46ViKuBOm6mGOrhG77JyQsclT195QKAdLrNben6awXMQ)cLKOPMn0G7zhj1gkJoEbS2gAdb5f2IbuXAL7vFKi1xOxWCA(TxOYioC3Av1lqTHYOJVCV6vVG7F25l2CFH(iV6l0lqTHYOJVCVGBtL208cOI1Q8ozmBdFnu3NRsXBVWH4UnV18BVas4R53EbZP53EH7xZV9Qps88f6fO2qz0XxUxWCA(TxGqC)fPnSInfks293EHdXDBER53EHy8p78fBUxWTPsBAEb1yuRYhLLkTMMFlP2qz0zaXhWk20aG1aqEdi(aWyayTnnugj5A4MzDNn0ben6aWABAOmsANdpSecl7bG5aIpamgG7F25l2Y7KXSn81qDFUkxcHLnFaWAaiDarJoauXAvENmMTHVgQ7ZvP49aWCarJoGAcfUgwcHLnFaWAa4HmV6JSG(c9cuBOm64l3l42uPnnVGAmQvj6sMcp81ap7ZAqFUjP2qz0zaXhWk2PlC)fPvEOA6sDaLmGcISbeFaRytsnrqb9diDaLmaOUZaIpamgaQyTkrxYu4HVg4zFwd6ZnP49aIgDa1ekCnSeclB(aG1aWdzdatVG508BVaH4(lsByfBkuKS7V9QpsK0xOxGAdLrhF5Eb3MkTP5fuJrTkth5SBj1gkJoEbZP53EbcX9xK2Wk2uOiz3F7vFKi1xOxGAdLrhF5Eb3MkTP5fuJrTkrxYu4HVg4zFwd6Znj1gkJodi(aWyayTnnugj5A4MzDNn0ben6aWABAOmsANdpSecl7bG5aIpamgG7F25l2s0LmfE4RbE2N1G(CtUeclB(aIgDaU)zNVylrxYu4HVg4zFwd6Zn5s2j2beFaRyNUW9xKw5HQPl1baRbGuKnam9cMtZV9c3jJzB4RH6(C1R(irE(c9cuBOm64l3l42uPnnVGAmQvz6iNDlP2qz0zaXhamhaQyTkVtgZ2Wxd195Qu82lyon)2lCNmMTHVgQ7ZvV6Jmc5l0lqTHYOJVCVGBtL208cQXOwLpklvAnn)wsTHYOZaIpamgawBtdLrsUgUzw3zdDarJoaS2MgkJK25WdlHWYEayoG4daJbOgJAvc1u40Mn0ax)fHKAdLrNbeFaOI1QCje)YjgX5HIzR0kfVhq0OdaMdqng1QeQPWPnBObU(lcj1gkJodatVG508BVWDYy2g(AOUpx9QpYyIVqVa1gkJo(Y9cUnvAtZlGkwRY7KXSn81qDFUkfV9cMtZV9cOlzk8Wxd8SpRb95Mx9rgb8f6fO2qz0XxUxWTPsBAEbZPjwkqnHij(aWnGRdi(aqfRv5DYy2g(AOUpxLlHWYMpaynaOUZaIpauXAvENmMTHVgQ7ZvP49aIpayoa1yuRYhLLkTMMFlP2qz0zaXhagdaMdyT8eiSuRs7C4skIjx5diA0bSwEcewQvPDoCz2dOKbuqKnamhq0OdOMqHRHLqyzZhaSgqb9cMtZV9c195AXyxe8qvCJ1R(iVImFHEbQnugD8L7fCBQ0MMxWCAILcutisIpGsWna8gq8bGXaqfRv5DYy2g(AOUpxLI3diA0bSwEcewQvPDoCz2dOKb4(ND(IT8ozmBdFnu3NRYLqyzZhaMdi(aWyaOI1Q8ozmBdFnu3NRYLqyzZhaSgau3zarJoG1YtGWsTkTZHlxcHLnFaWAaqDNbGPxWCA(TxOUpxlg7IGhQIBSE1h51R(c9cuBOm64l3l42uPnnVGAmQv5JYsLwtZVLuBOm6mG4davSwL3jJzB4RH6(CvkEpG4daJbGXaqfRv5DYy2g(AOUpxLlHWYMpaynaOUZaIgDaOI1QuSH)SydCDPgQcxkEpG4davSwLIn8NfBGRl1qv4YLqyzZhaSgau3zayoG4daJbCiuXAvUwP(B6ijxnheda3aq6aIgDaWCahYu4bi6ekCvUInv)fkjxRu)nD0aWCay6fmNMF7fQ7Z1IXUi4HQ4gRx9rEfpFHEbQnugD8L7fCBQ0MMxqng1QeDjtHh(AGN9znOp3KuBOm6mG4dyf70fU)I0kpunDPoGsgasISbeFaRytdaw4gqbhq8bGXaqfRvj6sMcp81ap7ZAqFUjfVhq0OdW9p78fBj6sMcp81ap7ZAqFUjxcHLnFaLmaKezdaZben6aG5auJrTkrxYu4HVg4zFwd6Znj1gkJodi(awXoDH7ViTYdvtxQdOeCdapK6fmNMF7fGh79RWPfr6c3lXP2rE1h51c6l0lqTHYOJVCVGBtL208cOI1Q8ozmBdFnu3NRsXBVG508BVWAjNchYoE1h5vK0xOxGAdLrhF5Eb3MkTP5fmNMyPa1eIK4dOeCdaVbeFayma0NZhq8butOW1WsiSS5dawdOGdiA0baZbGkwRs0LmfE4RbE2N1G(CtkEpG4daJbCtQek8xKjxcHLnFaWAaqDNben6awlpbcl1Q0ohUCjew28baRbuWbeFaRLNaHLAvANdxM9akza3KkHc)fzYLqyzZhaMdatVG508BVa3CBwtxASWT5uV6J8ks9f6fO2qz0XxUxWTPsBAEbZPjwkqnHij(akzaiDarJoGvSP6Vqj5nCY2hX3exsTHYOJxWCA(Tx4qMcpy9jCiNfRx9Qxq3SHGuUVqFKx9f6fO2qz0XxUxWCA(TxiBUBfvdLrHyUO1QiIWHWMoYlCiUBZBn)2lu4MneKY9cUnvAtZlGkwRY7KXSn81qDFUkfVhq0OdqTfkPsnrqb9d3onGhYgaSgashq0Oda958beFa1ekCnSeclB(aG1aW7Qx9rINVqVa1gkJo(Y9cMtZV9c6MneKE1lCiUBZBn)2luiCAa6MneKoGIPcFakCAaWtOWjUoaIRjctPZaWAmrc)bumzSbGsdqKtNbuZLRdW6ZaUTCPZakMk8bGeMmMTd4RdajyFUk9cUnvAtZlaZbG120qzKKFtUSM0jOB2qq6aIpauXAvENmMTHVgQ7ZvP49aIpamgamhGAmQvz6iNDlP2qz0zarJoa1yuRY0ro7wsTHYOZaIpauXAvENmMTHVgQ7Zv5siSS5dOeCd4kYgaMdi(aWyaWCa6MneKkv8KWnEW9p78f7ben6a0nBiivQ4jD)ZoFXwUeclB(aIgDayTnnugj1nBiinCV5VPg7aWnGRdaZben6a0nBiivQxLOI1A4iUMMFpGsWnGAcfUgwcHLn3R(ilOVqVa1gkJo(Y9cUnvAtZlaZbG120qzKKFtUSM0jOB2qq6aIpauXAvENmMTHVgQ7ZvP49aIpamgamhGAmQvz6iNDlP2qz0zarJoa1yuRY0ro7wsTHYOZaIpauXAvENmMTHVgQ7Zv5siSS5dOeCd4kYgaMdi(aWyaWCa6MneKk1Rs4gp4(ND(I9aIgDa6MneKk1Rs3)SZxSLlHWYMpGOrhawBtdLrsDZgcsd3B(BQXoaCdaVbG5aIgDa6MneKkv8KOI1A4iUMMFpGsWnGAcfUgwcHLn3lyon)2lOB2qqkEE1hjs6l0lqTHYOJVCVG508BVGUzdbPx9chI728wZV9ci)6a(Mf7a(MgW3dqKtdq3SHG0bCVp28q8bydavSwXFaICAakCAaVcN2b89aC)ZoFXwoaKZDazDanLkCAhGUzdbPd4EFS5H4dWgaQyTI)ae50aqFf(a(EaU)zNVyl9cUnvAtZlaZbOB2qqQuVkHB8GiNcOI16aIpamgGUzdbPsfpP7F25l2YLqyzZhq0OdaMdq3SHGuPINeUXdICkGkwRdaZben6aC)ZoFXwENmMTHVgQ7Zv5siSS5dOKbGhY8QpsK6l0lqTHYOJVCVGBtL208cWCa6MneKkv8KWnEqKtbuXADaXhagdq3SHGuPEv6(ND(ITCjew28ben6aG5a0nBiivQxLWnEqKtbuXADayoGOrhG7F25l2Y7KXSn81qDFUkxcHLnFaLma8qMxWCA(Txq3SHGu88Qx9chQAIm1xOpYR(c9cMtZV9ciY(eQlrLk5fO2qz0XxUx9rINVqVa1gkJo(Y9c)TxGtQxWCA(TxaRTPHYiVawJjsEbmgafZfZ7B6iZM7wr1qzuiMlATkIiCiSPJgq8b4(ND(ITmBUBfvdLrHyUO1QiIWHWMosUKDIDay6foe3T5TMF7fqcxcl16a43KlRjDgGUzdbP8bGszdDaIC6mGIPcFaMO(imnDdGLnX9cyTn0gcYlWVjxwt6e0nBii1R(ilOVqVa1gkJo(Y9c)TxGtQxWCA(TxaRTPHYiVawJjsEbZPjwkqnHij(aWnGRdi(aWyaRLNaHLAvANdxM9akzaxr6aIgDaWCaRLNaHLAvANdxsrm5kFay6fWABOneKxGRHBM1D2q9QpsK0xOxGAdLrhF5EH)2lWj1lyon)2lG120qzKxaRXejVG50elfOMqKeFaLGBa4nG4daJbaZbSwEcewQvPDoCjfXKR8ben6awlpbcl1Q0ohUKIyYv(aIpamgWA5jqyPwL25WLlHWYMpGsgashq0OdOMqHRHLqyzZhqjd4kYgaMdatVawBdTHG8c25WdlHWY2R(irQVqVa1gkJo(Y9c)TxGtQxWCA(TxaRTPHYiVawJjsEbuXAvUjcskEpG4daJbaZbSInv)fkjxdkf(AqHtH6(Lk1bhCdXD(TKAdLrNben6awXMQ)cLKRbLcFnOWPqD)sL6GdUH4o)wsTHYOZaIpGvStx4(lsR8q10L6akzaXKbGPxaRTH2qqEH91QlSjcYR(irE(c9cuBOm64l3l83EboPEbZP53EbS2MgkJ8cynMi5fCFFetvsRDsNPzdnGY(Idi(aqfRvjT2jDMMn0ak7lk5Q5Gya4gaEdiA0b4((iMQuSzKXHtNqDPUuJvsTHYOZaIpauXAvk2mY4WPtOUuxQXkxcHLnFaWAaymaOUZaqIdaVbGPxaRTH2qqEH6(CnW1nHGcUVpIPY9QpYiKVqVa1gkJo(Y9c)TxGtQxWCA(TxaRTPHYiVawJjsEHdzk8G1NWHCwSsnDqKn0beFaUhl1wRYoHcxdvJ8cyTn0gcYlCitHZdhrkyonXsE1hzmXxOxGAdLrhF5EbZP53EHLq8lNyeNhkMTsRx4qC3M3A(TxicFFZIDaib7Z1bGeqyPf)bGWYwTShaY3f7ak0yFZhG1Nbabr3diMri(LtmIZhaYD2kTdyFglBOEb3MkTP5fCFFetvsyPTUpxhq8bOgJAvc1u40Mn0ax)fHKAdLrNbeFaWCaQXOwLpklvAnn)wsTHYOZaIpa3)SZxSL3jJzB4RH6(CvUeclBUx9rgb8f6fO2qz0XxUxWCA(Txa(xKLn0akZ4QxWTPsBAEHZRY6(CnujS0kxQUehUHYObeFayma1yuRY0ro7wsTHYOZaIgDaWCaOI1QeDjtHh(AGN9znOp3KI3di(auJrTkrxYu4HVg4zFwd6Znj1gkJodiA0bOgJAv(OSuP108Bj1gkJodi(aC)ZoFXwENmMTHVgQ7Zv5siSS5di(aG5aqfRvjejJLn0acZbpBskEpam9cUyDmkO2cLuUpYRE1h5vK5l0lqTHYOJVCVGBtL208cOI1QmDXguJ9nxUeclB(aGfUba1Dgq8bGkwRY0fBqn23CP49aIpa(nXyb1wOKYLqzMlnwWoyT2rdOeCdaVbeFaymayoa1yuRs0LmfE4RbE2N1G(CtsTHYOZaIgDaU)zNVylrxYu4HVg4zFwd6Zn5siSS5dOKbCfPdatVG508BVauM5sJfSdwRDKx9rE9QVqVa1gkJo(Y9cUnvAtZlGkwRY0fBqn23C5siSS5daw4gau3zaXhaQyTktxSb1yFZLI3di(aWyaWCaQXOwLOlzk8Wxd8SpRb95MKAdLrNben6aG5aqfRvj6sMcp81ap7ZAqFUjfVhq8b4(ND(ITeDjtHh(AGN9znOp3KlHWYMpGsgWvKnam9cMtZV9c195AGRBcb5vFKxXZxOxGAdLrhF5EHdXDBER53EHya)FonGiStZVhal56a0FaRy7fmNMF7fCgJfmNMFhyjx9cSKRH2qqEb3JLARvUx9rETG(c9cuBOm64l3lyon)2l4mglyon)oWsU6fyjxdTHG8cR5sJX9QpYRiPVqVa1gkJo(Y9cMtZV9coJXcMtZVdSKREbwY1qBiiVGUzdbPCV6J8ks9f6fO2qz0XxUxWCA(TxWzmwWCA(DGLC1lWsUgAdb5fC)ZoFXM7vFKxrE(c9cuBOm64l3l42uPnnVGAmQvP7zNaCYwvsTHYOZaIpamgamhaQyTkHizSSHgqyo4ztsX7ben6auJrTkrxYu4HVg4zFwd6Znj1gkJodaZbeFaymGdHkwRY1k1Fthj5Q5Gya4gashq0OdaMd4qMcparNqHRYvSP6Vqj5AL6VPJgaMEbZP53EbNXybZP53bwYvVal5AOneKxW9StaozR6vFKxJq(c9cuBOm64l3l42uPnnVaQyTkrxYu4HVg4zFwd6ZnP4TxWCA(Txyf7G5087al5QxGLCn0gcYlG(8GMoiYgQx9rEnM4l0lqTHYOJVCVGBtL208cQXOwLOlzk8Wxd8SpRb95MKAdLrNbeFayma3)SZxSLOlzk8Wxd8SpRb95MCjew28baRbCfzdaZbeFaymG1YtGWsTkTZHlZEaLma8q6aIgDaWCaRLNaHLAvANdxsrm5kFarJoa3)SZxSL3jJzB4RH6(CvUeclB(aG1aUISbeFaRLNaHLAvANdxsrm5kFaXhWA5jqyPwL25WLzpaynGRiBay6fmNMF7fwXoyon)oWsU6fyjxdTHG8cOppC)plBOE1h51iGVqVa1gkJo(Y9cUnvAtZlGkwRY7KXSn81qDFUkfVhq8bOgJAv(OSuP108Bj1gkJoEbZP53EHvSdMtZVdSKREbwY1qBiiVWJYsLwtZV9Qps8qMVqVa1gkJo(Y9cUnvAtZlOgJAv(OSuP108Bj1gkJodi(aC)ZoFXwENmMTHVgQ7Zv5siSS5dawd4kYgq8bGXaWABAOmsY1WnZ6oBOdiA0bSwEcewQvPDoCjfXKR8beFaRLNaHLAvANdxM9aG1aUISben6aG5awlpbcl1Q0ohUKIyYv(aW0lyon)2lSIDWCA(DGLC1lWsUgAdb5fEuwQ0AA(D4(Fw2q9Qps8U6l0lqTHYOJVCVGBtL208cMttSuGAcrs8bucUbGNxWCA(Txyf7G5087al5QxGLCn0gcYlyp5vFK4HNVqVa1gkJo(Y9cMtZV9coJXcMtZVdSKREbwY1qBiiVaxT(y7XRE1lWvRp2E8f6J8QVqVa1gkJo(Y9cMtZV9clH4xoXiopumBLwVWH4UnV18BVGGA9X2Za4zdLrihuBHs6a2xnn)2l42uPnnVawBtdLrYTyavSw5E1hjE(c9cuBOm64l3l42uPnnVaQyTkHizSSHgqyo4ztYLmN6fmNMF7fEuwQ0Ak5vFKf0xOxGAdLrhF5Eb3MkTP5fWABAOmsw3NRbUUjeuW99rmvUxWCA(TxOUpxdCDtiiV6Jej9f6fO2qz0XxUxWTPsBAEbyoGdzk8aeDcfUkxXMQ)cLKRvQ)MoAaXhagd4qOI1QCTs930rsUAoigaSgashq0Od4qOI1QCTs930rYLqyzZhaSgqeAay6fmNMF7fGYmxASGDWATJ8QpsK6l0lqTHYOJVCVGBtL208cU)zNVylxcXVCIrCEOy2kTYLqyzZhaSWna8gasCaqDNbeFaQXOwLqnfoTzdnW1FriP2qz0Xlyon)2lu3NRbUUjeKx9rI88f6fO2qz0XxUxWTPsBAEbS2MgkJK7RvxyteKxWCA(Txa(xKLn0akZ4Qx9rgH8f6fO2qz0XxUxWTPsBAEbyoauXAvw3VuPoClY4Ku8EaXhGAmQvzD)sL6WTiJtsQnugDgq0OdaRTPHYi5HmfopCePG50elnG4davSwLhYu48WrKKC1CqmaynaKCarJoGvSjPMiOG(bKCaWc3aG6oEbZP53EHhLLkTMsE1hzmXxOxGAdLrhF5Eb3MkTP5fwXoDH7ViTYdvtxQdawdaJbCfPdOSbOgJAvUID6cMQulAA(TKAdLrNbGehashaMEbZP53EH6(CnW1nHG8QpYiGVqVa1gkJo(Y9cUnvAtZlSID6c3FrALhQMUuhqjdaJbGhshqzdqng1QCf70fmvPw008Bj1gkJodajoaKoam9cMtZV9cpklvAnL8QpYRiZxOxWCA(TxOUpxdCDtiiVa1gkJo(Y9QpYRx9f6fmNMF7fG)Bh(AOy2kTEbQnugD8L7vFKxXZxOxWCA(TxWwN1uq)DPw9cuBOm64l3RE1REbS0YZV9rIhYW7kYIq4vqVqrB7SHY9ci3r4ywKi)iJGlWagqHWPbKiU)vhq93bCX9StaozREzalfZfZLodG)iObyI6JWu6mahCRHsC5azPZMgW1cmGy8nwAv6mGlQXOwLW(Ya0FaxuJrTkHTKAdLrNldaJRret5azPZMgaEfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgagxJiMYbYsNnnGcwGbeJVXsRsNbCrng1Qe2xgG(d4IAmQvjSLuBOm6CzayCnIykhilD20aqYcmGy8nwAv6mGlQXOwLW(Ya0FaxuJrTkHTKAdLrNldaJRret5a5ajYDeoMfjYpYi4cmGbuiCAajI7F1bu)DaxEuwQ0AA(9LbSumxmx6ma(JGgGjQpctPZaCWTgkXLdKLoBAarGcmGy8nwAv6mGlQXOwLW(Ya0FaxuJrTkHTKAdLrNldad8IiMYbYbsK7iCmlsKFKrWfyadOq40ase3)QdO(7aUG(8GMoiYg6LbSumxmx6ma(JGgGjQpctPZaCWTgkXLdKLoBAaxlWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamUgrmLdKLoBAaizbgqm(glTkDgWLvSP6VqjjSVma9hWLvSP6VqjjSLuBOm6CzayCnIykhihirUJWXSir(rgbxGbmGcHtdirC)RoG6Vd4I7XsT1k)YawkMlMlDga)rqdWe1hHP0zao4wdL4YbYsNnna8kWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamUgrmLdKLoBAafSadigFJLwLod4IAmQvjSVma9hWf1yuRsylP2qz05YaW4AeXuoqw6SPbGKfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgagxJiMYbYsNnnaKwGbeJVXsRsNbCrng1Qe2xgG(d4IAmQvjSLuBOm6CzayGxeXuoqw6SPbeHkWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamUgrmLdKLoBAarGcmGy8nwAv6mGl8xKHM9rc7ldq)bCH)Im0SpsylP2qz05YaWaViIPCGCGe5ochZIe5hzeCbgWakeonGeX9V6aQ)oGlC16JTNldyPyUyU0za8hbnatuFeMsNb4GBnuIlhilD20aqAbgqm(glTkDgWf1yuRsyFza6pGlQXOwLWwsTHYOZLby6aqUqol9aW4AeXuoqw6SPbeHkWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamUgrmLdKLoBAaXKcmGy8nwAv6mGlQXOwLW(Ya0FaxuJrTkHTKAdLrNldaJRret5azPZMgqeOadigFJLwLod4IAmQvjSVma9hWf1yuRsylP2qz05YaW4AeXuoqoqIChHJzrI8JmcUadyafcNgqI4(xDa1FhWf0NhU)NLn0ldyPyUyU0za8hbnatuFeMsNb4GBnuIlhilD20aqEfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgagxJiMYbYsNnnGiubgqm(glTkDgWf1yuRsyFza6pGlQXOwLWwsTHYOZLbGX1iIPCGCGe5ochZIe5hzeCbgWakeonGeX9V6aQ)oGl3l5EeOMEzalfZfZLodG)iObyI6JWu6mahCRHsC5azPZMgW1cmGy8nwAv6maHermgap2wTioGyAmDa6pGslAdaXFezI8b830A6VdaJykMdad8IiMYbYsNnnGRfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgagfmIykhilD20aUwGbeJVXsRsNbCr3SHGu5vjSVma9hWfDZgcsL6vjSVmamkyeXuoqw6SPbGxbgqm(glTkDgGqIigdGhBRwehqmnMoa9hqPfTbG4pImr(a(BAn93bGrmfZbGbEret5azPZMgaEfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgagfmIykhilD20aWRadigFJLwLod4IUzdbPs8KW(Ya0Fax0nBiivQ4jH9LbGrbJiMYbYsNnnGcwGbeJVXsRsNbiKiIXa4X2QfXbethG(dO0I2aoj2KNFpG)Mwt)Dayadmhag4frmLdKLoBAafSadigFJLwLod4IUzdbPYRsyFza6pGl6MneKk1RsyFzayGKret5azPZMgqblWaIX3yPvPZaUOB2qqQepjSVma9hWfDZgcsLkEsyFzayG0iIPCGS0ztdajlWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamUgrmLdKLoBAaizbgqm(glTkDgWLvSP6VqjjSVma9hWLvSP6VqjjSLuBOm6CzaMoaKlKZspamUgrmLdKLoBAaizbgqm(glTkDgWf33hXuLW(Ya0FaxCFFetvcBj1gkJoxgagxJiMYbYbsK7iCmlsKFKrWfyadOq40ase3)QdO(7aU4(ND(In)YawkMlMlDga)rqdWe1hHP0zao4wdL4YbYsNnna8kWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamUgrmLdKLoBAafSadigFJLwLod4IAmQvjSVma9hWf1yuRsylP2qz05YaW4AeXuoqw6SPbGKfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgGPda5c5S0daJRret5azPZMgaslWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamUgrmLdKLoBAaiVcmGy8nwAv6mGlQXOwLW(Ya0FaxuJrTkHTKAdLrNldaJRret5azPZMgqeQadigFJLwLod4IAmQvjSVma9hWf1yuRsylP2qz05YaW4AeXuoqw6SPbebkWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamUgrmLdKLoBAaxVwGbeJVXsRsNbCrng1Qe2xgG(d4IAmQvjSLuBOm6CzayCnIykhilD20aUIxbgqm(glTkDgWf1yuRsyFza6pGlQXOwLWwsTHYOZLbGbEret5azPZMgWvKwGbeJVXsRsNbCzfBQ(lusc7ldq)bCzfBQ(luscBj1gkJoxgGPda5c5S0daJRret5a5ajYDeoMfjYpYi4cmGbuiCAajI7F1bu)Dax0nBiiLFzalfZfZLodG)iObyI6JWu6mahCRHsC5azPZMgaEfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgag4frmLdKLoBAa4vGbeJVXsRsNbCr3SHGu5vjSVma9hWfDZgcsL6vjSVmamUgrmLdKLoBAa4vGbeJVXsRsNbCr3SHGujEsyFza6pGl6MneKkv8KW(YaWaViIPCGS0ztdOGfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgag4frmLdKLoBAafSadigFJLwLod4IUzdbPYRsyFza6pGl6MneKk1RsyFzayGxeXuoqw6SPbuWcmGy8nwAv6mGl6MneKkXtc7ldq)bCr3SHGuPINe2xgagxJiMYbYsNnnaKSadigFJLwLod4IUzdbPYRsyFza6pGl6MneKk1RsyFzayCnIykhilD20aqYcmGy8nwAv6mGl6MneKkXtc7ldq)bCr3SHGuPINe2xgag4frmLdKLoBAaiTadigFJLwLod4IUzdbPYRsyFza6pGl6MneKk1RsyFzayGxeXuoqw6SPbG0cmGy8nwAv6mGl6MneKkXtc7ldq)bCr3SHGuPINe2xgagxJiMYbYbsK7iCmlsKFKrWfyadOq40ase3)QdO(7aUCOQjY0ldyPyUyU0za8hbnatuFeMsNb4GBnuIlhilD20aqAbgqm(glTkDgWLvSP6VqjjSVma9hWLvSP6VqjjSLuBOm6CzayGxeXuoqw6SPbG8kWaIX3yPvPZaU4((iMQe2xgG(d4I77JyQsylP2qz05YaW4AeXuoqw6SPbetkWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamWlIykhilD20aIafyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgagfmIykhilD20aUIScmGy8nwAv6mGlQXOwLW(Ya0FaxuJrTkHTKAdLrNldaJRret5azPZMgW1RfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgagxJiMYbYsNnnGRiVcmGy8nwAv6mGlQXOwLW(Ya0FaxuJrTkHTKAdLrNldad8IiMYbYsNnnGRXKcmGy8nwAv6mGlQXOwLW(Ya0FaxuJrTkHTKAdLrNldaJRret5azPZMgW1iqbgqm(glTkDgWf1yuRsyFza6pGlQXOwLWwsTHYOZLby6aqUqol9aW4AeXuoqw6SPbGhYkWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmamUgrmLdKdKi3r4ywKi)iJGlWagqHWPbKiU)vhq93bCXE6YawkMlMlDga)rqdWe1hHP0zao4wdL4YbYsNnna8kWaIX3yPvPZaUOgJAvc7ldq)bCrng1Qe2sQnugDUmathaYfYzPhagxJiMYbYsNnnGcwGbeJVXsRsNbCrng1Qe2xgG(d4IAmQvjSLuBOm6CzaMoaKlKZspamUgrmLdKLoBAarOcmGy8nwAv6mGlQXOwLW(Ya0FaxuJrTkHTKAdLrNldaJRret5azPZMgqmPadigFJLwLod4IAmQvjSVma9hWf1yuRsylP2qz05YaW4AeXuoqw6SPbCfzfyaX4BS0Q0zaxuJrTkH9LbO)aUOgJAvcBj1gkJoxgagxJiMYbYbsKpI7Fv6mGRfCaMtZVhal5kxoq6fU3VMmYlukLYaIGqMcFaih3ju46aqc2NRdKLsPmaifzXoa8Ia4pa8qgExhihilLszaXaU1qj(azPukda5WaIzeIhlDgaZ4kYbo5((marUbLgWxhqmGBzZhWxhaY3rdW4di1bCEI3x0bCZSyhqrIXgq2d4EnNMosoqwkLYaqomGiiFFrhGdU1nXgasaJ4WDRv1bCe3SHoGYxYu4d4Rdqi7ZAqFUjhihilLbGCH1yIMs8bydq3SHGu(aC)ZoFXg)bCsS5Hodan2bCNmMTd4RdOUpxhWVdaDjtHpGVoaE2N1G(C7cFaU)zNVylhaYVoGuVWhawJjsdaUXhq)dyjew2hAhWsQ42d4k(dGyCAalPIBpaKjrQCG0CA(nxEVK7rGAAz4GbwBtdLr43gccNUzdbPHRbESTd))ghN0SIpwJjs4UIpwJjsbIXjCitIu8DFFsn)gNUzdbPYRs4gpiYPaQyTghdyQgJAvIUKPWdFnWZ(Sg0NBXXq3SHGu5vP7F25l2YJ4AA(DmnM6(ND(IT8ozmBdFnu3NRYJ4AA(noKHz0OQXOwLOlzk8Wxd8SpRb95wCmC)ZoFXwIUKPWdFnWZ(Sg0NBYJ4AA(DmnMQB2qqQ8Q09p78fB5rCnn)ghYWmAu1yuRY0ro7gZbsZP53C59sUhbQPLHdgyTnnugHFBiiC6MneKgWlWJTD4)344KMv8XAmrc3v8XAmrkqmoHdzsKIV77tQ5340nBiivINeUXdICkGkwRXXaMQXOwLOlzk8Wxd8SpRb95wCm0nBiivIN09p78fB5rCnn)oMgtD)ZoFXwENmMTHVgQ7Zv5rCnn)ghYWmAu1yuRs0LmfE4RbE2N1G(ClogU)zNVylrxYu4HVg4zFwd6Zn5rCnn)oMgt1nBiivIN09p78fB5rCnn)ghYWmAu1yuRY0ro7gZbYszaixCnrykXhGnaDZgcs5daRXePbGg7aCpIBBZg6au40aC)ZoFXEaFDakCAa6MneKI)aoj28qNbGg7au40aoIRP53d4RdqHtdavSwhqQd4EFS5H4Ybeb14dWgaxxQHQWhaI)K1K2bO)aGMyPbydaEcfoTd4EZFtn2bO)a46snuf(a0nBiiLJ)am(aksm2am(aSbG4pznPDa1FhqwhGnaDZgcshqXKXgWVdOyYydOFDa8yB3akMk8b4(ND(InxoqAon)MlVxY9iqnTmCWaRTPHYi8BdbHt3SHG0W9M)MAS4)344KMv8XAmrchE4J1yIuGyCc3v8DFFsn)ghm1nBiivEvc34brofqfR146MneKkXtc34brofqfR1Or1nBiivINeUXdICkGkwRXXadDZgcsL4jD)ZoFXwEextZVJP6MneKkXtIkwRHJ4AA(nMirmUkrAz6MneKkXtc34buXAvY1LAOkCmrIyG120qzKu3SHG0aEbESTdtmlbdm0nBiivEv6(ND(IT8iUMMFht1nBiivEvIkwRHJ4AA(nMirmUkrAz6MneKkVkHB8aQyTk56snufoMirmWABAOmsQB2qqA4AGhB7WeZbsZP53C59sUhbQPLHdgyTnnugHFBiiCBXaQyTYXhRXejCQXOwLqnfoTzdnW1FrenQ77JyQsclT195A0ORyt1FHss0uZgAW9SZaP508BU8Ej3Ja10YWbJkJ4WDRv1bYbYsPugaYvejNOsNbqyPn2bOjcAakCAaMt)DajFagwlzgkJKdKMtZV54qK9juxIkvAGSugas4syPwha)MCznPZa0nBiiLpaukBOdqKtNbumv4dWe1hHPPBaSSj(aP508BEz4GbwBtdLr43gcch)MCznPtq3SHGu8XAmrchgumxmVVPJmBUBfvdLrHyUO1QiIWHWMokU7F25l2YS5UvunugfI5IwRIichcB6i5s2jwmhinNMFZldhmWABAOmc)2qq44A4MzDNnu8XAmrcN50elfOMqKeh314ySwEcewQvPDoCz2LCfPrJcZ1YtGWsTkTZHlPiMCLJ5aP508BEz4GbwBtdLr43gccNDo8WsiSSXhRXejCMttSuGAcrs8sWHxCmG5A5jqyPwL25WLuetUYJgDT8eiSuRs7C4skIjx5XXyT8eiSuRs7C4YLqyzZlbPrJwtOW1WsiSS5LCfzyI5aP508BEz4GbwBtdLr43gcc3(A1f2ebHpwJjs4qfRv5MiiP4DCmG5k2u9xOKCnOu4RbfofQ7xQuhCWne353rJUInv)fkjxdkf(AqHtH6(Lk1bhCdXD(D8vStx4(lsR8q10LAjXemhinNMFZldhmWABAOmc)2qq4Q7Z1ax3eck4((iMkhFSgtKW5((iMQKw7KotZgAaL9fJJkwRsATt6mnBObu2xuYvZbbo8Ig199rmvPyZiJdNoH6sDPgBCuXAvk2mY4WPtOUuxQXkxcHLnhwya1DqI4H5aP508BEz4GbwBtdLr43gcc3HmfopCePG50elHpwJjs4oKPWdwFchYzXk10br2qJ7ESuBTk7ekCnunAGSugqe((Mf7aqc2NRdajGWsl(daHLTAzpaKVl2buOX(MpaRpdacIUhqmJq8lNyeNpaK7SvAhW(mw2qhinNMFZldhmwcXVCIrCEOy2kT4NvCUVpIPkjS0w3NRXvJrTkHAkCAZgAGR)IiomvJrTkFuwQ0AA(DC3)SZxSL3jJzB4RH6(CvUeclB(aP508BEz4Gb8VilBObuMXv8DX6yuqTfkPCCxXpR4oVkR7Z1qLWsRCP6sC4gkJIJHAmQvz6iNDhnkmrfRvj6sMcp81ap7ZAqFUjfVJRgJAvIUKPWdFnWZ(Sg0NBrJQgJAv(OSuP10874U)zNVylVtgZ2Wxd195QCjew284WevSwLqKmw2qdimh8SjP4nMdKMtZV5LHdgqzMlnwWoyT2r4NvCOI1QmDXguJ9nxUeclBoSWb1DIJkwRY0fBqn23CP4DC(nXyb1wOKYLqzMlnwWoyT2rLGdV4yat1yuRs0LmfE4RbE2N1G(ClAu3)SZxSLOlzk8Wxd8SpRb95MCjew28sUIumhinNMFZldhmQ7Z1ax3ecc)SIdvSwLPl2GASV5YLqyzZHfoOUtCuXAvMUydQX(MlfVJJbmvJrTkrxYu4HVg4zFwd6ZTOrHjQyTkrxYu4HVg4zFwd6ZnP4DC3)SZxSLOlzk8Wxd8SpRb95MCjew28sUImmhilLbed4)ZPbeHDA(9ayjxhG(dyf7bsZP538YWbdNXybZP53bwYv8BdbHZ9yP2ALpqAon)Mxgoy4mglyon)oWsUIFBiiCR5sJXhinNMFZldhmCgJfmNMFhyjxXVneeoDZgcs5dKMtZV5LHdgoJXcMtZVdSKR43gccN7F25l28bsZP538YWbdNXybZP53bwYv8BdbHZ9StaozRIFwXPgJAv6E2jaNSvJJbmrfRvjejJLn0acZbpBskEhnQAmQvj6sMcp81ap7ZAqFUHzCmoeQyTkxRu)nDKKRMdcCinAuyEitHhGOtOWv5k2u9xOKCTs930ryoqAon)MxgoySIDWCA(DGLCf)2qq4qFEqthezdf)SIdvSwLOlzk8Wxd8SpRb95Mu8EG0CA(nVmCWyf7G5087al5k(THGWH(8W9)SSHIFwXPgJAvIUKPWdFnWZ(Sg0NBXXW9p78fBj6sMcp81ap7ZAqFUjxcHLnhwxrgMXXyT8eiSuRs7C4YSlbpKgnkmxlpbcl1Q0ohUKIyYvE0OU)zNVylVtgZ2Wxd195QCjew2CyDfzXxlpbcl1Q0ohUKIyYvE81YtGWsTkTZHlZgwxrgMdKMtZV5LHdgRyhmNMFhyjxXVneeUhLLkTMMFJFwXHkwRY7KXSn81qDFUkfVJRgJAv(OSuP1087bsZP538YWbJvSdMtZVdSKR43gcc3JYsLwtZVd3)ZYgk(zfNAmQv5JYsLwtZVJ7(ND(IT8ozmBdFnu3NRYLqyzZH1vKfhdS2MgkJKCnCZSUZgA0ORLNaHLAvANdxsrm5kp(A5jqyPwL25WLzdRRilAuyUwEcewQvPDoCjfXKRCmhinNMFZldhmwXoyon)oWsUIFBiiC2t4NvCMttSuGAcrs8sWH3aP508BEz4GHZySG5087al5k(THGWXvRp2EgihilLbeHFKRbeZE1087bsZP53CP9eULq8lNyeNhkMTs7aP508BU0EQmCWakZCPXc2bR1oc)SItng1QSUpx5Uyv40azPmaKGFriYS0na7(EFZbFa6pa3sMsdWgWnNep)aU383uJDaQTqjDaSKRdO(7aS7BwSzdDaRvQ)MoAazpa7PbsZP53CP9uz4GrDFUg46Mqq47I1XOGAlus54UIFwX5(ND(ITCje)YjgX5HIzR0kxcHLnhw4Wdjc1DIRgJAvc1u40Mn0ax)fXaP508BU0EQmCWa(xKLn0akZ4k(zfhwBtdLrY91QlSjcAG0CA(nxApvgoy8OSuP1uc)SIdRTPHYi5HmfopCePG50elfhvSwLhYu48WrKKC1CqalKCG0CA(nxApvgoyu3NRCxSkCc)SIdvSwLqKmw2qdimh8Sj5sMtJdtS2MgkJKhYu48WrKcMttS0aP508BU0EQmCWakZCPXc2bR1oc)SIBf70fU)I0kpunDPclmUI0YuJrTkxXoDbtvQfnn)gjwqmhinNMFZL2tLHdg195AGRBcbHVlwhJcQTqjLJ7k(zf3k2PlC)fPvEOA6sfwyCfPLPgJAvUID6cMQulAA(nsePyoqAon)MlTNkdhmQ7ZvUlwfoHFwXbtS2MgkJKhYu48WrKcMttS0aP508BU0EQmCW4rzPsRPe(UyDmkO2cLuoUR4NvCRyNUW9xKw5HQPl1sWapKwMAmQv5k2PlyQsTOP53irKI5aP508BU0EQmCWakZCPXc2bR1oAG0CA(nxApvgoyu3NRbUUjee(UyDmkO2cLuoURdKMtZV5s7PYWbd4)2HVgkMTs7aP508BU0EQmCWWwN1uq)DPwhihilLbu(sMcFaFDaczFwd6ZTbC)plBOdyF1087buGbWvBv(aUIm(aqP6V0ak)fgqYhGH1sMHYObsZP53Cj6Zd3)ZYgko4Frw2qdOmJR4NvCyTnnugj3xRUWMiObsZP53Cj6Zd3)ZYgAz4GXsi(LtmIZdfZwPf)SIZCAILcutisIxco8IgDfBsQjckOFaPWchu3jowBtdLrYTyavSw5dKLsPmGlQTqjnKvCiSiwamoeQyTkxRu)nDKKRMdIYUIzmfJdHkwRY1k1FthjxcHLnVSRyIepKPWdq0ju4QCfBQ(lusUwP(B6OldiMr3KP8bydG9k(dqHN8bK8bKTs9Hodq)bO2cL0bOWPbapHcN46aU383uJDautiIDaftf(aSEagAYsn2bOWnDaftgBa29nl2bSwP(B6ObK1bSInv)fkDKdOq4MoaukBOdW6bqnHi2bumv4dazdGRMdco(d43by9aOMqe7au4MoafonGdHkwRdOyYydG)FpakI35sd4B5aP508BUe95H7)zzdTmCW4rzPsRPe(UyDmkO2cLuoUR4NvCRyNUW9xKw5HQPl1sWHhshinNMFZLOppC)plBOLHdgqzMlnwWoyT2r4NvCRyNUW9xKw5HQPlvyHhYIZVjglO2cLuUekZCPXc2bR1oQeC4f39p78fB5DYy2g(AOUpxLlHWYMxcshinNMFZLOppC)plBOLHdg195AGRBcbHVlwhJcQTqjLJ7k(zf3k2PlC)fPvEOA6sfw4HS4U)zNVylVtgZ2Wxd195QCjew28sq6aP508BUe95H7)zzdTmCWOUpx5Uyv4e(zfhQyTkHizSSHgqyo4ztYLmNgFf70fU)I0kpunDPwcgxrAzQXOwLRyNUGPk1IMMFJerkMX53eJfuBHskxw3NRCxSkCQeC4fhMyTnnugjpKPW5HJifmNMyPbsZP53Cj6Zd3)ZYgAz4GrDFUYDXQWj8ZkUvStx4(lsR8q10LAj4WOGiTm1yuRYvStxWuLArtZVrIifZ48BIXcQTqjLlR7ZvUlwfovco8IdtS2MgkJKhYu48WrKcMttS0aP508BUe95H7)zzdTmCWakZCPXc2bR1oc)SIZ9p78fB5DYy2g(AOUpxLlHWYMxYk2Kuteuq)asgFf70fU)I0kpunDPclKezX53eJfuBHskxcLzU0yb7G1Ahvco8ginNMFZLOppC)plBOLHdg195AGRBcbHVlwhJcQTqjLJ7k(zfN7F25l2Y7KXSn81qDFUkxcHLnVKvSjPMiOG(bKm(k2PlC)fPvEOA6sfwijYgihilLbu(sMcFaFDaczFwd6ZTbeHDAILgqm7vtZVhinNMFZLOppOPdISHI7rzPsRPe(UyDmkO2cLuoUR4NvCRyNUW9xKw5HQPl1sWHbsI0YuJrTkxXoDbtvQfnn)gjIumhinNMFZLOppOPdISHwgoySeIF5eJ48qXSvAXpR4WABAOmsUfdOI1kpAuZPjwkqnHijEj4WlA0vStx4(lslSkiEdKMtZV5s0Nh00br2qldhmoKPWdwFchYzXIFwXTID6c3FrAHvbXBG0CA(nxI(8GMoiYgAz4Gb8VilBObuMXv8ZkoS2MgkJK7RvxyteuCmwXoDH7ViTYdvtxQWcPinA0vSjPMiOG(HcclCqDNOrxXMQ)cLKRbLcFnOWPqD)sL6GdUH4o)oAu(nXyb1wOKYLW)ISSHgqzgxlbhEygn6k2PlC)fPfwfeVbsZP53Cj6ZdA6GiBOLHdg195k3fRcNWpR4qfRvjejJLn0acZbpBskEhNFtmwqTfkPCzDFUYDXQWPsWHxCyI120qzK8qMcNhoIuWCAILginNMFZLOppOPdISHwgoya)3o81qXSvAXpR4wXoDH7ViTYdvtxQLGdjrw8vSjPMiOG(Hcwcu3zG0CA(nxI(8GMoiYgAz4GrDFUYDXQWj8Zko(nXyb1wOKYL195k3fRcNkbhEXHjwBtdLrYdzkCE4isbZPjwAG0CA(nxI(8GMoiYgAz4GXJYsLwtj8DX6yuqTfkPCCxXpR4wXoDH7ViTYdvtxQLGhsJgDfBsQjckOFOGWcQ7mqAon)MlrFEqthezdTmCWa(xKLn0akZ4k(zfhwBtdLrY91QlSjcAG0CA(nxI(8GMoiYgAz4GHToRPG(7sTIFwXTID6c3FrALhQMUulbPiBGCGSukLbeJNDgqeuYwDaX47tQ538bYsPugG508BU09StaozRIZb3YMh(AiDe(zfxnHcxdlHWYMdlOUtCmwXMGfErJctuXAvcrYyzdnGWCWZMKI3XXaMiSSdWT(iXdECuXAv6E2jaNSvLC1CqucoKSSvSP6VqjjeptZ14HQH93OrryzhGB9rIh84OI1Q09StaozRk5Q5GOKyszRyt1FHssiEMMRXdvd7VygnkQyTkHizSSHgqyo4ztsX74yatew2b4wFK4bpoQyTkDp7eGt2QsUAoikjMu2k2u9xOKeINP5A8q1W(B0OiSSdWT(iXdECuXAv6E2jaNSvLC1CquYvKv2k2u9xOKeINP5A8q1W(lMyoqwkda5OCAahXnBOdajmzmBhqXuHpaKVJC2nmkFjtHpqAon)MlDp7eGt2QLHdgo4w28WxdPJWpR4GPAmQv5JYsLwtZVJJkwRY7KXSn81qDFUkfVJJkwRs3Zob4KTQKRMdIsWDfzXrfRv5DYy2g(AOUpxLlHWYMdlOUdseJRL5(ND(ITSUpxlg7IGhQIBSYLStSyoqwkda5uu55HgWxhasyYy2oarozqPbumv4da57iNDdJYxYu4dKMtZV5s3Zob4KTAz4GHdULnp81q6i8ZkoyQgJAv(OSuP10874hYu4bi6ekCvUInv)fkjRgJrDWTIC7qBCyIkwRY7KXSn81qDFUkfVJ7(ND(IT8ozmBdFnu3NRYLqyzZl5ksJJbQyTkDp7eGt2QsUAoikb3vKfhvSwLIn8NfBGRl1qv4sX7OrrfRvP7zNaCYwvYvZbrj4UwqmhinNMFZLUNDcWjB1YWbdhClBE4RH0r4NvCWung1Q8rzPsRP53XH5HmfEaIoHcxLRyt1FHsYQXyuhCRi3o0ghvSwLUNDcWjBvjxnheLG7kYIdtuXAvENmMTHVgQ7ZvP4DC3)SZxSL3jJzB4RH6(CvUeclBEj4HSbYszaiHlHLADaX4zNbebLSvhWJLwNDFNn0bCe3SHoG7KXSDG0CA(nx6E2jaNSvldhmCWTS5HVgshHFwXPgJAv(OSuP10874WevSwL3jJzB4RH6(CvkEhhduXAv6E2jaNSvLC1CqucURizCuXAvk2WFwSbUUudvHlfVJgfvSwLUNDcWjBvjxnheLG7AeiAu3)SZxSL3jJzB4RH6(CvUeclBoSkyCuXAv6E2jaNSvLC1CqucURijMdKdKLYaqcFn)EG0CA(nx6(ND(Inh39R534NvCOI1Q8ozmBdFnu3NRsX7bYszaX4F25l28bsZP53CP7F25l28YWbdcX9xK2Wk2uOiz3FJFwXPgJAv(OSuP10874RytWc5fhdS2MgkJKCnCZSUZgA0OyTnnugjTZHhwcHLnMXXW9p78fB5DYy2g(AOUpxLlHWYMdlKgnkQyTkVtgZ2Wxd195Qu8gZOrRju4Ayjew2CyHhYginNMFZLU)zNVyZldhmie3FrAdRytHIKD)n(zfNAmQvj6sMcp81ap7ZAqFUfFf70fU)I0kpunDPwsbrw8vSjPMiOG(bKwcu3jogOI1QeDjtHh(AGN9znOp3KI3rJwtOW1WsiSS5WcpKH5aP508BU09p78fBEz4GbH4(lsByfBkuKS7VXpR4uJrTkth5S7bsZP53CP7F25l28YWbJ7KXSn81qDFUIFwXPgJAvIUKPWdFnWZ(Sg0NBXXaRTPHYijxd3mR7SHgnkwBtdLrs7C4HLqyzJzCmC)ZoFXwIUKPWdFnWZ(Sg0NBYLqyzZJg19p78fBj6sMcp81ap7ZAqFUjxYoXgFf70fU)I0kpunDPclKImmhinNMFZLU)zNVyZldhmUtgZ2Wxd195k(zfNAmQvz6iNDhhMOI1Q8ozmBdFnu3NRsX7bsZP53CP7F25l28YWbJ7KXSn81qDFUIFwXPgJAv(OSuP10874yG120qzKKRHBM1D2qJgfRTPHYiPDo8WsiSSXmogQXOwLqnfoTzdnW1FriP2qz0joQyTkxcXVCIrCEOy2kTsX7OrHPAmQvjutHtB2qdC9xesQnugDWCG0CA(nx6(ND(InVmCWaDjtHh(AGN9znOp3WpR4qfRv5DYy2g(AOUpxLI3dKMtZV5s3)SZxS5LHdg195AXyxe8qvCJf)SIZCAILcutisIJ7ACuXAvENmMTHVgQ7Zv5siSS5WcQ7ehvSwL3jJzB4RH6(CvkEhhMQXOwLpklvAnn)oogWCT8eiSuRs7C4skIjx5rJUwEcewQvPDoCz2LuqKHz0O1ekCnSeclBoSk4aP508BU09p78fBEz4GrDFUwm2fbpuf3yXpR4mNMyPa1eIK4LGdV4yGkwRY7KXSn81qDFUkfVJgDT8eiSuRs7C4YSlX9p78fB5DYy2g(AOUpxLlHWYMJzCmqfRv5DYy2g(AOUpxLlHWYMdlOUt0ORLNaHLAvANdxUeclBoSG6oyoqAon)MlD)ZoFXMxgoyu3NRfJDrWdvXnw8Zko1yuRYhLLkTMMFhhvSwL3jJzB4RH6(CvkEhhdmqfRv5DYy2g(AOUpxLlHWYMdlOUt0OOI1QuSH)SydCDPgQcxkEhhvSwLIn8NfBGRl1qv4YLqyzZHfu3bZ4yCiuXAvUwP(B6ijxnhe4qA0OW8qMcparNqHRYvSP6Vqj5AL6VPJWeZbsZP53CP7F25l28YWbd4XE)kCArKUW9sCQDe(zfNAmQvj6sMcp81ap7ZAqFUfFf70fU)I0kpunDPwcsIS4RytWcxbJJbQyTkrxYu4HVg4zFwd6ZnP4D0OU)zNVylrxYu4HVg4zFwd6Zn5siSS5LGKidZOrHPAmQvj6sMcp81ap7ZAqFUfFf70fU)I0kpunDPwco8q6aP508BU09p78fBEz4GXAjNchYo4NvCOI1Q8ozmBdFnu3NRsX7bsZP53CP7F25l28YWbdU52SMU0yHBZP4NvCMttSuGAcrs8sWHxCmqFopEnHcxdlHWYMdRcgnkmrfRvj6sMcp81ap7ZAqFUjfVJJXnPsOWFrMCjew2Cyb1DIgDT8eiSuRs7C4YLqyzZHvbJVwEcewQvPDoCz2LCtQek8xKjxcHLnhtmhinNMFZLU)zNVyZldhmoKPWdwFchYzXIFwXzonXsbQjejXlbPrJUInv)fkjVHt2(i(M4dKdKLYaIXJLAR1beHrtwQjXhinNMFZLUhl1wRCChYu48WrKWpR4WABAOmsY1WnZ6oBOrJI120qzK0ohEyjew2dKMtZV5s3JLARvEz4GbVOTiYgAarYv8ZkUvStx4(lsR8q10LAjxlyC3)SZxSL3jJzB4RH6(CvUeclBoSkyCyQgJAvIUKPWdFnWZ(Sg0NBXXABAOmsY1WnZ6oBOdKMtZV5s3JLARvEz4GbVOTiYgAarYv8ZkoyQgJAvIUKPWdFnWZ(Sg0NBXXABAOmsANdpSecl7bsZP53CP7XsT1kVmCWGx0wezdnGi5k(zfNAmQvj6sMcp81ap7ZAqFUfhduXAvIUKPWdFnWZ(Sg0NBsX74yG120qzKKRHBM1D2qJVID6c3FrALhQMUulbjrw0OyTnnugjTZHhwcHLD8vStx4(lsR8q10LAjipKfnkwBtdLrs7C4HLqyzhFT8eiSuRs7C4YLqyzZHveaZOrHjQyTkrxYu4HVg4zFwd6ZnP4DC3)SZxSLOlzk8Wxd8SpRb95MCjew2CmhinNMFZLUhl1wR8YWbdd9rKTP53bwIaf)SIZ9p78fB5DYy2g(AOUpxLlHWYMdRcghRTPHYijxd3mR7SHghd1yuRs0LmfE4RbE2N1G(Cl(k2PlC)fPvEOA6sfwipKf39p78fBj6sMcp81ap7ZAqFUjxcHLnhw4fnkmvJrTkrxYu4HVg4zFwd6ZnmhinNMFZLUhl1wR8YWbdd9rKTP53bwIaf)SIdRTPHYiPDo8WsiSShinNMFZLUhl1wR8YWbdoCZbbJckCki2f)vHhl(zfhwBtdLrsUgUzw3zdnogU)zNVylVtgZ2Wxd195QCjew2CyvWOrvJrTkth5SBmhinNMFZLUhl1wR8YWbdoCZbbJckCki2f)vHhl(zfhwBtdLrs7C4HLqyzpqAon)MlDpwQTw5LHdgvgXH7wRQ4NvCWevSwL3jJzB4RH6(CvkEhhMOI1QeDjtHh(AGN9znOp3KI3XXG)Im0SpYBrUkYOaTI3A(D0O8xKHM9rI9zMMmkWFgwQvmXpBL2v8wdjce0jnLWDf)SvAxXBnaL9Ogd3v8ZwPDfV1qwXXFrgA2hj2NzAYOa)zyPwhihilLbGCIYsLwtZVhW(QP53dKMtZV5YhLLkTMMFJBje)YjgX5HIzR0IFwXzonXsbQjejXlbxbJJ120qzKClgqfRv(aP508BU8rzPsRP53LHdgW)ISSHgqzgxXxTfkPHSIdMNxL195AOsyPvQPdISHghMOI1QeIKXYgAaH5GNnjfVJVInvcUcoqAon)MlFuwQ0AA(Dz4GrDFUYDXQWj8ZkouXAvcrYyzdnGWCWZMKlzono)MySGAlus5Y6(CL7IvHtLGdV4WeRTPHYi5HmfopCePG50elnqAon)MlFuwQ0AA(Dz4GXJYsLwtj8DX6yuqTfkPCCxXpR4qfRvjejJLn0acZbpBsUK50bsZP53C5JYsLwtZVldhmGYmxASGDWATJWpR443eJfuBHskxcLzU0yb7G1Ahvco8IJXk2PlC)fPvEOA6sfwxrw0ORytsnrqb9d4vcu3bZOrX4qOI1QCTs930rsUAoiGfsJg9qOI1QCTs930rYLqyzZH1vKI5aP508BU8rzPsRP53LHdg195AGRBcbHFwXzonXsbQjejXXDnowBtdLrY6(CnW1nHGcUVpIPYhinNMFZLpklvAnn)UmCWa(xKLn0akZ4k(zfhwBtdLrY91QlSjcko)MySGAlus5s4Frw2qdOmJRLGdVbsZP53C5JYsLwtZVldhmGYmxASGDWATJWpR443eJfuBHskxcLzU0yb7G1Ahvco8ginNMFZLpklvAnn)UmCWOUpxdCDtii8DX6yuqTfkPCCxXpR4GPAmQvPH1yw7GtXHjQyTkHizSSHgqyo4ztsX7OrvJrTknSgZAhCkomXABAOmsUVwDHnrqrJI120qzKCFT6cBIGIVInj1ebf0pGxj4G6odKMtZV5YhLLkTMMFxgoya)lYYgAaLzCf)SIdRTPHYi5(A1f2ebnqAon)MlFuwQ0AA(Dz4GXJYsLwtj8DX6yuqTfkPCCxhihilLbGe(plBOdaj43bGCIYsLwtZVlWaeuBv(aUISbWj33h(aqP6V0aqctgZ2b81bGeSpxhG7rq8b816aIreKbsZP53C5JYsLwtZVd3)ZYgkULq8lNyeNhkMTsl(zfhwBtdLrYTyavSw5rJAonXsbQjejXlbhEdKMtZV5YhLLkTMMFhU)NLn0YWbJ6(CnW1nHGWpR4mNMyPa1eIK44UghRTPHYizDFUg46Mqqb33hXu5dKMtZV5YhLLkTMMFhU)NLn0YWbJhLLkTMs47I1XOGAlus54UIFwXHkwRsisglBObeMdE2KCjZPdKMtZV5YhLLkTMMFhU)NLn0YWbd4Frw2qdOmJR4NvCyTnnugj3xRUWMiObsZP53C5JYsLwtZVd3)ZYgAz4GbuM5sJfSdwRDe(zfh)MySGAlus5sOmZLglyhSw7OsWHx8vStx4(lsR8q10LkSqEiBG0CA(nx(OSuP1087W9)SSHwgoyu3NRbUUjee(UyDmkO2cLuoUR4NvCRyNUW9xKw5HQPlvyfHq2aP508BU8rzPsRP53H7)zzdTmCW4rzPsRPe(UyDmkO2cLuoUR4NvCRytLGRGdKMtZV5YhLLkTMMFhU)NLn0YWbJ6(CL7IvHt4NvCMttSuGAcrs8sWHKXHjwBtdLrYdzkCE4isbZPjwAGCGSugqmZCPXgqegnzPMeFG0CA(nxUMlnghhk7)tOkUXIFwXHkwRY7KXSn81qDFUkfVhinNMFZLR5sJXldhmqPLtlezdf)SIdvSwL3jJzB4RH6(CvkEpqAon)MlxZLgJxgoyyRZAkClY4e(zfhgWevSwL3jJzB4RH6(CvkEh3CAILcutisIxco8WmAuyIkwRY7KXSn81qDFUkfVJJXk2K8q10LAj4qA8vStx4(lsR8q10LAj4qEidZbsZP53C5AU0y8YWbdwcfUYdihr8afb1k(zfhQyTkVtgZ2Wxd195Qu8EG0CA(nxUMlngVmCWWAhX11ybNXy4NvCOI1Q8ozmBdFnu3NRsX74OI1QKqC)fPnSInfks293sX7bsZP53C5AU0y8YWbJAUek7)d(zfhQyTkVtgZ2Wxd195QCjew2CyHlMehvSwLeI7ViTHvSPqrYU)wkEpqAon)MlxZLgJxgoyGAqdFnOB6GGJFwXHkwRY7KXSn81qDFUkfVJBonXsbQjejXXDnogOI1Q8ozmBdFnu3NRYLqyzZHfsJRgJAv6E2jaNSvLuBOm6enkmvJrTkDp7eGt2QsQnugDIJkwRY7KXSn81qDFUkxcHLnhwfeZbYbYszacQ1hBpdGNnugHCqTfkPdyF1087bsZP53CjxT(y7b3si(LtmIZdfZwPf)SIdRTPHYi5wmGkwR8bsZP53CjxT(y7PmCW4rzPsRPe(zfhQyTkHizSSHgqyo4ztYLmNoqAon)Ml5Q1hBpLHdg195AGRBcbHFwXH120qzKSUpxdCDtiOG77JyQ8bsZP53CjxT(y7PmCWakZCPXc2bR1oc)SIdMhYu4bi6ekCvUInv)fkjxRu)nDuCmoeQyTkxRu)nDKKRMdcyH0OrpeQyTkxRu)nDKCjew2CyfHWCG0CA(nxYvRp2EkdhmQ7Z1ax3ecc)SIZ9p78fB5si(LtmIZdfZwPvUeclBoSWHhseQ7exng1QeQPWPnBObU(lIbsZP53CjxT(y7PmCWa(xKLn0akZ4k(zfhwBtdLrY91QlSjcAG0CA(nxYvRp2EkdhmEuwQ0AkHFwXbtuXAvw3VuPoClY4Ku8oUAmQvzD)sL6WTiJtrJI120qzK8qMcNhoIuWCAILIJkwRYdzkCE4issUAoiGfsgn6k2Kuteuq)asclCqDNbsZP53CjxT(y7PmCWOUpxdCDtii8ZkUvStx4(lsR8q10LkSW4ksltng1QCf70fmvPw008BKisXCG0CA(nxYvRp2EkdhmEuwQ0AkHFwXTID6c3FrALhQMUulbd8qAzQXOwLRyNUGPk1IMMFJerkMdKMtZV5sUA9X2tz4GrDFUg46MqqdKMtZV5sUA9X2tz4Gb8F7WxdfZwPDG0CA(nxYvRp2EkdhmS1znf0FxQ1bYbYszafUzdbP8bsZP53CPUzdbPCCzZDROAOmkeZfTwfreoe20r4NvCOI1Q8ozmBdFnu3NRsX7OrvBHsQuteuq)WTtd4HmyH0OrrFopEnHcxdlHWYMdl8UoqwkdOq40a0nBiiDaftf(au40aGNqHtCDaexteMsNbG1yIe(dOyYydaLgGiNodOMlxhG1NbCB5sNbumv4dajmzmBhWxhasW(CvoqAon)Ml1nBiiLxgoyOB2qq6v8ZkoyI120qzKKFtUSM0jOB2qqACuXAvENmMTHVgQ7ZvP4DCmGPAmQvz6iNDhnQAmQvz6iNDhhvSwL3jJzB4RH6(CvUeclBEj4UImmJJbm1nBiivINeUXdU)zNVyhnQUzdbPs8KU)zNVylxcHLnpAuS2MgkJK6MneKgU383uJf3vmJgv3SHGu5vjQyTgoIRP53LGRMqHRHLqyzZhinNMFZL6MneKYldhm0nBiifp8ZkoyI120qzKKFtUSM0jOB2qqACuXAvENmMTHVgQ7ZvP4DCmGPAmQvz6iNDhnQAmQvz6iNDhhvSwL3jJzB4RH6(CvUeclBEj4UImmJJbm1nBiivEvc34b3)SZxSJgv3SHGu5vP7F25l2YLqyzZJgfRTPHYiPUzdbPH7n)n1yXHhMrJQB2qqQepjQyTgoIRP53LGRMqHRHLqyzZhilLbG8Rd4BwSd4BAaFparonaDZgcshW9(yZdXhGnauXAf)biYPbOWPb8kCAhW3dW9p78fB5aqo3bK1b0uQWPDa6MneKoG79XMhIpaBaOI1k(dqKtda9v4d47b4(ND(ITCG0CA(nxQB2qqkVmCWq3SHG0R4NvCWu3SHGu5vjCJhe5uavSwJJHUzdbPs8KU)zNVylxcHLnpAuyQB2qqQepjCJhe5uavSwXmAu3)SZxSL3jJzB4RH6(CvUeclBEj4HSbsZP53CPUzdbP8YWbdDZgcsXd)SIdM6MneKkXtc34brofqfR14yOB2qqQ8Q09p78fB5siSS5rJctDZgcsLxLWnEqKtbuXAfZOrD)ZoFXwENmMTHVgQ7Zv5siSS5LGhY8c8BY5JepKE1RE17b]] )


end
