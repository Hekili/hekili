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


    spec:RegisterPack( "Frost DK", 20210627, [[d4uZZcqiqOhjLQ6sOKQ2evQpjfnkiXPGqRcscVcuywujDlijQ2fu)cuQHbbDmLkldL4zujmnqjUgKuBtkv5BOKIXbkPCoqjP1rf08Ga3dsTpPqheLuzHGIEivGjkLkKlcjj2iKK0hLsfmsPuH6KqsQvcIEjKeLMjvI2PuWpbLunuqjXsrjLEkjnvPuUkKef9vijYybb7vu)vKbRQdtzXO4Xu1KLQlJSzL8zLYObvNwy1qsu41kvnBuDBiA3s(TkdhKoUuQOLd8CsnDIRtITtf9DPKXJsY5PcTEPuP5JsTFfN3LBlR2nHYnWcczzhcBpwyn4DThliewAVSQ4iukRc187TnkRwgskRIQcoTmF7iuzZQqnh5N1ZTLv1NcWtzv4Iav7qyd7TqGRWG9hsyRdKkCtIR8aBjWwhi9WoRYOeCbvxzMSA3ek3aliKLDiS9yH1G31ESGqxaRLvnfb(bYQQbshKvHh9ovzMSAN0(SA7iYe4ZJkBfBWL5rvbNwgiHuPO5zH1468SGqw2nqoq6a4wTr6bsu5ZZAjKNtQpp30cQCn5VQpVI22O5V18oaUfLE(BnpQ2tZB65dz((r6QPmpuU548TioF(OMhkW8s4jCwLhArNBlREm8qiGjXvjO3XJAl3wUHD52YQuzmCQNHzw18sCvwfqipGM4KwNAfLqGSAN0EqavIRYQWk3XJABEu1dmpSodpecysCLdNxvmGONFhcNxt(R665zO1bO5Hvco3aZFR5rvbNwM3Fij983AnVdAhLv9GqiqyzvX4uj4ntGtGO2sA5aiXuzmCQppB2Z7VQRecMCsGf40cMkJHt95zZEEGsrRdSryMqIAl5pEhtLXWP(8SzpV5LWjLOIqgKE(grpplzj3al52YQuzmCQNHzw1dcHaHLvzuwlmiqsyfOzvZlXvzv4xlEuBjgUPLSKBWf52YQuzmCQNHzw18sCvw9y4HqatOSQhecbclRYOSw49bNh1wcP5HhfHbK5LSQ3rpNsIb2irNByxwYnal52YQuzmCQNHzw1dcHaHLv1qjopjgyJenEJB(W4jR70kpnFJONNL5DppqPcFc61Ia4oTcFiZJG5BpeMvnVexLv34MpmEY6oTYtzj3aQZTLvPYy4updZSQ5L4QS6cCAjPfqSNYQEqieiSSkqPcFc61Ia4oTcFiZJG5znimR6D0ZPKyGns05g2LLCdTxUTSkvgdN6zyMvnVexLvpgEieWekR6bHqGWYQaLIMVr0Z7ISQ3rpNsIb2irNByxwYnWAYTLvPYy4updZSQhecbclRAEjCsjQiKbPNVr0ZdlZ7EEuMhIZ3jtGNSQN6K3CelHFFuBZ7EE)5KkReCfBWL0YO5zZEEioV)CsLvcUIn4sAz08iMvnVexLvxGtlAVJcCklzjR6pEpbNmGKBl3WUCBzvQmgo1ZWmRAEjUkR6HBrPt3kfEkR2jTheqL4QSkQm108DfquBZdReCUbMVviWNhv7jVbf2WeqMapR6bHqGWYQqCEX4uj4JHhcbmjUctLXWP(8UNNrzTWqdo3aPBLwGtlyaH0IsppcM3fZ7EEgL1cdn4CdKUvAboTGvGoV75zuwlS)49eCYacwlMF)8nIE(Diml5gyj3wwLkJHt9mmZQMxIRYQE4wu60TsHNYQDs7bbujUkRcRRi6OtZFR5Hvco3aZROjBJMVviWNhv7jVbf2WeqMapR6bHqGWYQqCEX4uj4JHhcbmjUctLXWP(8UNVtMapTVIn4cgOu06aBeEzCovjpqrBDcmV75H48mkRfgAW5giDR0cCAbRaDE3ZJY8mkRf2F8EcozabRfZVF(grp)U2BE3ZZOSwyLc(XDmPfavBcCSc05zZEEgL1c7pEpbNmGG1I53pFJONFhS68UN3FhVFTkm0GZnq6wPf40cgqiTO0Z3487q48iMLCdUi3wwLkJHt9mmZQEqieiSSkeNxmovc(y4HqatIRWuzmCQpV75H48DYe4P9vSbxWaLIwhyJWlJZPk5bkARtG5DppJYAH9hVNGtgqWAX87NVr0ZVdHZ7EEiopJYAHHgCUbs3kTaNwWkqN398(749RvHHgCUbs3kTaNwWacPfLE(gNNfeMvnVexLv9WTO0PBLcpLLCdWsUTSkvgdN6zyMvnVexLv9WTO0PBLcpLv7K2dcOsCvwfwbqoPsM3bhVpF7yYaY8Ntc4nOqJAB(UciQT5HgCUbYQEqieiSSQyCQe8XWdHaMexHPYy4uFE3ZdX5zuwlm0GZnq6wPf40cwb68UNhL5zuwlS)49eCYacwlMF)8nIE(DT38UNNrzTWkf8J7yslaQ2e4yfOZZM98mkRf2F8EcozabRfZVF(grp)oy15zZEE)D8(1QWqdo3aPBLwGtlyaH0IsppcM3fZ7EEgL1c7pEpbNmGG1I53pFJONFhSmpIzjlz1JHhcbmjUk3wUHD52YQuzmCQNHzw18sCvwfqipGM4KwNAfLqGSAN0EqavIRYQW6m8qiGjXvZdoXK4QSQhecbclRAEjCsjQiKbPNVr0Z7I5DppkZlgNkbVzcCce1wslhajMkJHt95zZEE)vDLqWKtcSaNwWuzmCQppB2ZdukADGncZesuBj)X7yQmgo1NhXSKBGLCBzvQmgo1ZWmRAEjUkRc)AXJAlXWnTKv9GqiqyzvioF)e8cCAjTiNealHFFuBZ7EEiopJYAH3hCEuBjKMhEuewb68UNhOu08nIEExKv9o65usmWgj6Cd7YsUbxKBlRsLXWPEgMzvpiecewwLrzTW7dopQTesZdpkcdiZlZ7EEnuIZtIb2irJxGtlAVJcCA(grpplZ7EEuMNrzTWDYe46uxHWAX87Nh98WY8SzppeNVtMapzvp1jV5iwc)(O2MNn75H48(Zjvwj4k2GlPLrZJyw18sCvwDboTO9okWPSKBawYTLvPYy4updZSQ5L4QS6XWdHaMqzvpiecewwLrzTW7dopQTesZdpkcdiZlZZM98qCEgL1cdcKewb68UNxdL48KyGns0y4xlEuBjgUPL5Be98UiR6D0ZPKyGns05g2LLCdOo3wwLkJHt9mmZQEqieiSSQgkX5jXaBKOXBCZhgpzDNw5P5Be98SmV75rzEGsf(e0RfbWDAf(qMhbZVdHZZM98aLIWsGKsYLyz(gNFZ3NhX5zZEEuMVtmkRfgyT7bcpH1I53ppcMh1ZZM98DIrzTWaRDpq4jmGqArPNhbZVd1ZJyw18sCvwDJB(W4jR70kpLLCdTxUTSkvgdN6zyMv9Gqiqyzv)vDLqWeW6H3KO2sm8RfMkJHt95DppJYAHjG1dVjrTLy4xlSwm)(5rpplZ7EEZlHtkrfHmi98ONFxw18sCvwDboTK0ci2tzj3aRj3wwLkJHt9mmZQEqieiSSkJYAHbbscRaDE3ZRHsCEsmWgjAm8RfpQTed30Y8nIEEwYQMxIRYQWVw8O2smCtlzj3aSwUTSkvgdN6zyMv9GqiqyzvnuIZtIb2irJ34MpmEY6oTYtZ3i65zjRAEjUkRUXnFy8K1DALNYsUby1CBzvQmgo1ZWmRAEjUkRUaNwsAbe7PSQhecbclRcX5fJtLGnNg3kpCctLXWP(8UNhIZZOSw49bNh1wcP5HhfHvGopB2ZlgNkbBonUvE4eMkJHt95DppeNNrzTWGajHvGopB2ZZOSwyqGKWkqN398aLIWsGKsYLyz(grp)MVNv9o65usmWgj6Cd7YsUHDim3wwLkJHt9mmZQEqieiSSkJYAHbbscRanRAEjUkRc)AXJAlXWnTKLCd72LBlRsLXWPEgMzvZlXvz1JHhcbmHYQEh9CkjgyJeDUHDzjlzvTyv3a9CB5g2LBlRsLXWPEgMzvZlXvzvaH8aAItADQvucbYQDs7bbujUkRQkw1nqFEDuBCcvUyGnsMhCIjXvzvpiecewwvmovcEZe4eiQTKwoasmvgdN6ZZM98(R6kHGjNeyboTGPYy4uFE2SNhOu06aBeMjKO2s(J3XuzmCQNLCdSKBlRsLXWPEgMzvpiecewwfIZ3jtGN2xXgCbdukADGncdS29aHNM398OmFNyuwlmWA3deEcRfZVFEempQNNn757eJYAHbw7EGWtyaH0IsppcMN1mpIzvZlXvz1nU5dJNSUtR8uwYn4ICBzvQmgo1ZWmR6bHqGWYQ(749RvHbeYdOjoP1PwrjeadiKwu65ra65zzEuX8B((8UNxmovcEZe4eiQTKwoasmvgdN6zvZlXvz1f40sslGypLLCdWsUTSkvgdN6zyMv9Gqiqyzv)vDLqWeW6H3KO2sm8RfMkJHt95DppJYAHjG1dVjrTLy4xlSwm)(5rpplZZM98(R6kHGvkozA4upTau1UoIPYy4uFE3ZZOSwyLItMgo1tlavTRJyaH0IsppcM3fZ7EEgL1cRuCY0WPEAbOQDDeRanRAEjUkRUaNwsAbe7PSKBa152YQuzmCQNHzw1dcHaHLvzuwlmiqsyfOzvZlXvzv4xlEuBjgUPLSKBO9YTLvPYy4updZSQhecbclRcX5zuwl8cCTlvjOkCnHvGoV75fJtLGxGRDPkbvHRjmvgdN6ZZM98mkRfEFW5rTLqAE4rryazEzE2SNVtMapzvp1jV5iwc)(O2M398(Zjvwj4k2GlPLrZ7EEgL1c3jtGRtDfcRfZVFEempSmpB2ZdukclbskjxcwMhbONFZ3ZQMxIRYQhdpecycLLCdSMCBzvQmgo1ZWmR6bHqGWYQaLk8jOxlcG70k8HmpcMhL53H65HX8IXPsWaLk8jteQumjUctLXWP(8OI5DX8iMvnVexLvxGtljTaI9uwYnaRLBlRsLXWPEgMzvpiecewwfOuHpb9AraCNwHpK5BCEuMNfuppmMxmovcgOuHpzIqLIjXvyQmgo1NhvmVlMhXSQ5L4QS6XWdHaMqzj3aSAUTSQ5L4QS6cCAjPfqSNYQuzmCQNHzwYnSdH52YQMxIRYQWpqLUvQvucbYQuzmCQNHzwYnSBxUTSQ5L4QSQb8wrj5aaQKSkvgdN6zyMLSKvbMpmUo3wUHD52YQuzmCQNHzw18sCvwLHFxpTuaoMv7K2dcOsCvwL1A(W4ZZ6ycEibPZQEqieiSSkJYAHHgCUbs3kTaNwWkqZsUbwYTLvPYy4updZSQhecbclRYOSwyObNBG0TslWPfSc0SQ5L4QSkdb0eyFuBzj3GlYTLvPYy4updZSQhecbclRIY8qCEgL1cdn4CdKUvAboTGvGoV75nVeoPeveYG0Z3i65zzEeNNn75H48mkRfgAW5giDR0cCAbRaDE3ZJY8aLIWDAf(qMVr0ZJ65DppqPcFc61Ia4oTcFiZ3i65BpeopIzvZlXvzvd4TIsqv4Akl5gGLCBzvQmgo1ZWmR6bHqGWYQmkRfgAW5giDR0cCAbRanRAEjUkRYJn4IoHkdL(gsQKSKBa152YQuzmCQNHzw1dcHaHLvzuwlm0GZnq6wPf40cwb68UNNrzTWesOxlcKakfLArg0RWkqZQMxIRYQw5jTamEYBCEwYn0E52YQuzmCQNHzw1dcHaHLvzuwlm0GZnq6wPf40cgqiTO0ZJa0ZdRnV75zuwlmHe61IajGsrPwKb9kSc0SQ5L4QS6kaed)UEwYnWAYTLvPYy4updZSQhecbclRYOSwyObNBG0TslWPfSc05DpV5LWjLOIqgKEE0ZVBE3ZJY8mkRfgAW5giDR0cCAbdiKwu65rW8OEE3ZlgNkb7pEpbNmGGPYy4uFE2SNhIZlgNkb7pEpbNmGGPYy4uFE3ZZOSwyObNBG0TslWPfmGqArPNhbZ7I5rmRAEjUkRYyBPBLeq43RZswYQ(Zjvwj6CB5g2LBlRsLXWPEgMzvZlXvz1ozcCDQRqz1oP9GaQexLvDW5KkRK5zDmbpKG0zvpieceww1PbcJHtyTKGYTQIABE2SN3PbcJHtyR31jaH0Ikl5gyj3wwLkJHt9mmZQEqieiSSkqPcFc61Ia4oTcFiZ348UyE3Z7VJ3VwfgAW5giDR0cCAbdiKwu65rW8UyE3ZdX5fJtLGzaKjWt3kPJQdSTtByQmgo1N398onqymCcRLeuUvvuBzvZlXvzvDldGmQTeYqlzj3GlYTLvPYy4updZSQhecbclRcX5fJtLGzaKjWt3kPJQdSTtByQmgo1N398onqymCcB9UobiKwuzvZlXvzvDldGmQTeYqlzj3aSKBlRsLXWPEgMzvpiecewwvmovcMbqMapDRKoQoW2oTHPYy4uFE3ZJY8mkRfMbqMapDRKoQoW2oTHvGoV75rzENgimgoH1sck3QkQT5DppqPcFc61Ia4oTcFiZ348WccNNn75DAGWy4e26DDcqiTOM398aLk8jOxlcG70k8HmFJZ3EiCE2SN3PbcJHtyR31jaH0IAE3ZdSONiNujyR31yaH0IsppcMhwDEeNNn75H48mkRfMbqMapDRKoQoW2oTHvGoV7593X7xRcZaitGNUvshvhyBN2WacPfLEEeZQMxIRYQ6wgazuBjKHwYsUbuNBlRsLXWPEgMzvpieceww1FhVFTkm0GZnq6wPf40cgqiTO0ZJG5DX8UN3PbcJHtyTKGYTQIABE3ZJY8IXPsWmaYe4PBL0r1b22PnmvgdN6Z7EEGsf(e0RfbWDAf(qMhbZ3EiCE3Z7VJ3VwfMbqMapDRKoQoW2oTHbeslk98iyEwMNn75H48IXPsWmaYe4PBL0r1b22PnmvgdN6ZJyw18sCvw1yoKrzsCvIhizYsUH2l3wwLkJHt9mmZQEqieiSSQtdegdNWwVRtacPfvw18sCvw1yoKrzsCvIhizYsUbwtUTSkvgdN6zyMv9Gqiqyzv)D8(1QWqdo3aPBLwGtlyaH0IsppcM3fZ7EENgimgoH1sck3QkQTSQ5L4QSQgU53ZPKaNskvRdiWDml5gG1YTLvPYy4updZSQhecbclR60aHXWjS176eGqArLvnVexLv1Wn)EoLe4usPADabUJzjlzv7OCB5g2LBlRsLXWPEgMz1oP9GaQexLvzDhQY8S2tmjUkRAEjUkRciKhqtCsRtTIsiqwYnWsUTSkvgdN6zyMv9GqiqyzvX4uj4f40I27OaNWuzmCQNvnVexLv34MpmEY6oTYtzj3GlYTLvPYy4updZSQ5L4QS6cCAjPfqSNYQEqieiSSQ)oE)AvyaH8aAItADQvucbWacPfLEEeGEEwMhvm)MVpV75fJtLG3mbobIAlPLdGetLXWPEw17ONtjXaBKOZnSll5gGLCBzvQmgo1ZWmR6bHqGWYQmkRfgeijSc0SQ5L4QSk8RfpQTed30swYnG6CBzvQmgo1ZWmR6bHqGWYQDYe4jR6Po5nhXs43h128UN3FoPYkbxXgCjTmAE3ZZOSw4ozcCDQRqyTy(9ZJG5HLSQ5L4QS6XWdHaMqzj3q7LBlRsLXWPEgMzvpiecewwLrzTW7dopQTesZdpkcdiZlZ7EEuMhIZ3jtGNSQN6K3CelHFFuBZ7EE)5KkReCfBWL0YO5zZEEioV)CsLvcUIn4sAz08iMvnVexLvxGtlAVJcCkl5gyn52YQuzmCQNHzw1dcHaHLvbkv4tqVwea3Pv4dzEempkZVd1ZdJ5fJtLGbkv4tMiuPysCfMkJHt95rfZ7I5rmRAEjUkRUXnFy8K1DALNYsUbyTCBzvQmgo1ZWmRAEjUkRUaNwsAbe7PSQhecbclRcuQWNGETiaUtRWhY8iyEuMFhQNhgZlgNkbduQWNmrOsXK4kmvgdN6ZJkM3fZJyw17ONtjXaBKOZnSll5gGvZTLvPYy4updZSQhecbclRcX57KjWtw1tDYBoILWVpQT5DpV)CsLvcUIn4sAz08SzppeN3FoPYkbxXgCjTmkRAEjUkRUaNw0Ehf4uwYnSdH52YQuzmCQNHzw18sCvw9y4HqatOSQhecbclRcuQWNGETiaUtRWhY8nopkZZcQNhgZlgNkbduQWNmrOsXK4kmvgdN6ZJkM3fZJyw17ONtjXaBKOZnSll5g2Tl3ww18sCvwDJB(W4jR70kpLvPYy4updZSKByhl52YQuzmCQNHzw18sCvwDboTK0ci2tzvVJEoLedSrIo3WUSKByNlYTLvnVexLvHFGkDRuROecKvPYy4updZSKByhSKBlRAEjUkRAaVvusoaGkjRsLXWPEgMzjlzvMtNGEhpQTCB5g2LBlRsLXWPEgMzvZlXvzv4xlEuBjgUPLSAN0EqavIRYQWeqMaF(BnVAuDGTDABEO3XJABEWjMexnVdNxlgq0ZVdH65zO1bO5H5PoFON3CAb3y4uw1dcHaHLvzuwlmiqsyfOzj3al52YQuzmCQNHzw1dcHaHLvnVeoPeveYG0Z3i65zzE2SNhOuewcKusUeQNhbONFZ3N398OmVyCQe8MjWjquBjTCaKyQmgo1NNn759x1vcbtojWcCAbtLXWP(8SzppqPO1b2imtirTL8hVJPYy4uFEeZQMxIRYQac5b0eN06uROecKLCdUi3wwLkJHt9mmZQMxIRYQhdpecycLv9o65usmWgj6Cd7YQEqieiSSkqPcFc61Ia4oTcFiZ3i65zb1z1oP9GaQexLvBkgyJKuSqJ0yLdrPtmkRfgyT7bcpH1I53dJDiY6rPtmkRfgyT7bcpHbeslknm2HiQOtMapTVIn4cgOu06aBegyT7bcp1CEwlbLmrpVnp)exNxGh65d98rju1P(8YnVyGnsMxGtZdp2GtAzEOG4aH448uriDC(wHaFERM3ycEiooVa3K5BfC(8guOChNhyT7bcpnFSMhOu06aBuhpFBWnzEgkQT5TAEQiKooFRqGppcNxlMFV215pW8wnpveshNxGBY8cCA(oXOSwZ3k48513vZtScAaO5VcNLCdWsUTSkvgdN6zyMv9GqiqyzvGsf(e0RfbWDAf(qMhbZZccN398AOeNNedSrIgVXnFy8K1DALNMVr0ZZY8UN3FhVFTkm0GZnq6wPf40cgqiTO0Z348OoRAEjUkRUXnFy8K1DALNYsUbuNBlRsLXWPEgMzvZlXvz1f40sslGypLv9GqiqyzvGsf(e0RfbWDAf(qMhbZZccN398(749RvHHgCUbs3kTaNwWacPfLE(gNh1zvVJEoLedSrIo3WUSKBO9YTLvPYy4updZSQhecbclRYOSw49bNh1wcP5HhfHbK5L5DppqPcFc61Ia4oTcFiZ348Om)ouppmMxmovcgOuHpzIqLIjXvyQmgo1NhvmVlMhX5DpVgkX5jXaBKOXlWPfT3rbonFJONNL5DppkZZOSw4ozcCDQRqyTy(9ZJEEyzE2SNhIZ3jtGNSQN6K3CelHFFuBZZM98qCE)5KkReCfBWL0YO5rmRAEjUkRUaNw0Ehf4uwYnWAYTLvPYy4updZSQhecbclRcuQWNGETiaUtRWhY8nIEEuM3fOEEymVyCQemqPcFYeHkftIRWuzmCQppQyExmpIZ7EEnuIZtIb2irJxGtlAVJcCA(grpplZ7EEuMNrzTWDYe46uxHWAX87Nh98WY8SzppeNVtMapzvp1jV5iwc)(O2MNn75H48(Zjvwj4k2GlPLrZJyw18sCvwDboTO9okWPSKBawl3wwLkJHt9mmZQEqieiSSQ)oE)AvyObNBG0TslWPfmGqArPNVX5bkfHLajLKlblZ7EEGsf(e0RfbWDAf(qMhbZdliCE3ZRHsCEsmWgjA8g38HXtw3PvEA(grpplzvZlXvz1nU5dJNSUtR8uwYnaRMBlRsLXWPEgMzvZlXvz1f40sslGypLv9Gqiqyzv)D8(1QWqdo3aPBLwGtlyaH0IspFJZdukclbskjxcwM398aLk8jOxlcG70k8HmpcMhwqyw17ONtjXaBKOZnSllzjRcfq(djJj52YnSl3wwLkJHt9mmZQh0SQMKyLv9Gqiqyzvbe1EsWYomCtNu0uIrzTM398OmpeNxmovcMbqMapDRKoQoW2oTHPYy4uFE3ZJY8ciQ9KGLDy)D8(1QWDfGjXvZZ6N3FhVFTkm0GZnq6wPf40cURamjUAE0ZJW5rCE2SNxmovcMbqMapDRKoQoW2oTHPYy4uFE3ZJY8(749RvHzaKjWt3kPJQdSTtB4UcWK4Q5z9ZlGO2tcw2H93X7xRc3vaMexnp65r48iopB2ZlgNkbhEYBqXuzmCQppIz1oP9GaQexLvrvCACfti9828ciQ9KON3FhVFTkxNVhoJo1NNXX5HgCUbM)wZVaNwM)aZZaitGp)TMxhvhyBN2AQN3FhVFTk88O618H0upVtJRqZd30Zx38acPfvNaZdirbuZVZ15jUMMhqIcOMhHyuJZQonqQmKuwvarTNK0UK2XYNvnVexLvDAGWy4uw1PXvOeX1uwfHyuNvDACfkRUll5gyj3wwLkJHt9mmZQh0SQMKyLvnVexLvDAGWy4uw1PbsLHKYQciQ9KKyjPDS8zvpiecewwvarTNeSWcgUPtkAkXOSwZ7EEuMhIZlgNkbZaitGNUvshvhyBN2WuzmCQpV75rzEbe1EsWcly)D8(1QWDfGjXvZZ6N3FhVFTkm0GZnq6wPf40cURamjUAE0ZJW5rCE2SNxmovcMbqMapDRKoQoW2oTHPYy4uFE3ZJY8(749RvHzaKjWt3kPJQdSTtB4UcWK4Q5z9ZlGO2tcwyb7VJ3VwfURamjUAE0ZJW5rCE2SNxmovco8K3GIPYy4uFEeZQonUcLiUMYQieJ6SQtJRqz1Dzj3GlYTLvPYy4updZS6bnRQjjwzvpiecewwfIZlGO2tcw2HHB6KIMsmkR18UNxarTNeSWcgUPtkAkXOSwZZM98ciQ9KGfwWWnDsrtjgL1AE3ZJY8OmVaIApjyHfS)oE)Av4UcWK4Q5H98ciQ9KGfwWmkRvQRamjUAEeNhvmpkZVdJ65HX8ciQ9KGfwWWnDIrzTWAbq1MaFEeNhvmpkZ70aHXWjSaIApjjwsAhl)8iopIZ348OmpkZlGO2tcw2H93X7xRc3vaMexnpSNxarTNeSSdZOSwPUcWK4Q5rCEuX8Om)omQNhgZlGO2tcw2HHB6eJYAH1cGQnb(8iopQyEuM3PbcJHtybe1Ess7sAhl)8iopIz1oP9GaQexLvrv0sG0espVnVaIApj65DACfAEghN3FiHAGO2MxGtZ7VJ3Vw183AEbonVaIApjUoFpCgDQppJJZlWP57katIRM)wZlWP5zuwR5dzEOGZz0jnE(2XMEEBETaOAtGppYRhRGaZl38BHtAEBE4XgCcmpuqCGqCCE5MxlaQ2e4ZlGO2tI215n98TioFEtpVnpYRhRGaZVoW8XAEBEbe1EsMVvW5ZFG5BfC(81jZRDS8Z3ke4Z7VJ3VwLgNvDAGuziPSQaIApjjOG4aH4yw18sCvw1PbcJHtzvNgxHsextz1DzvNgxHYQSKLSKv93X7xRsNBl3WUCBzvQmgo1ZWmR6bHqGWYQmkRfgAW5giDR0cCAbRaDE3ZZOSwycj0RfbsaLIsTid6vyfOz1oP9GaQexLvHvojUkRAEjUkRc9K4QSKBGLCBzvQmgo1ZWmRAEjUkRsiHETiqcOuuQfzqVkR2jTheqL4QSQdUJ3VwLoR6bHqGWYQIXPsWhdpecysCfMkJHt95DppqPO5rW8T38UNhL5DAGWy4ewljOCRQO2MNn75DAGWy4e26DDcqiTOMhX5DppkZ7VJ3VwfgAW5giDR0cCAbdiKwu65rW8OEE2SNNrzTWqdo3aPBLwGtlyfOZJ48Szp)k2GljaH0IsppcMNfeMLCdUi3wwLkJHt9mmZQEqieiSSQyCQemdGmbE6wjDuDGTDAdtLXWP(8UNhOuHpb9AraCNwHpK5BCEybHZ7EEGsryjqsj5sOE(gNFZ3N398OmpJYAHzaKjWt3kPJQdSTtByfOZZM98RydUKaeslk98iyEwq48iMvnVexLvjKqVweibukk1ImOxLLCdWsUTSkvgdN6zyMv9GqiqyzvX4uj4WtEdkMkJHt95DppqPO5rW8UiRAEjUkRsiHETiqcOuuQfzqVkl5gqDUTSkvgdN6zyMv9GqiqyzvX4ujygazc80Ts6O6aB70gMkJHt95DppkZ70aHXWjSwsq5wvrTnpB2Z70aHXWjS176eGqArnpIZ7EEuM3FhVFTkmdGmbE6wjDuDGTDAddiKwu65zZEE)D8(1QWmaYe4PBL0r1b22PnmGSUJZ7EEGsf(e0RfbWDAf(qMhbZJAeopIzvZlXvzvObNBG0TslWPLSKBO9YTLvPYy4updZSQhecbclRkgNkbhEYBqXuzmCQpV75H48mkRfgAW5giDR0cCAbRanRAEjUkRcn4CdKUvAboTKLCdSMCBzvQmgo1ZWmR6bHqGWYQIXPsWhdpecysCfMkJHt95DppkZ70aHXWjSwsq5wvrTnpB2Z70aHXWjS176eGqArnpIZ7EEuMxmovcEZe4eiQTKwoasmvgdN6Z7EEgL1cdiKhqtCsRtTIsiawb68SzppeNxmovcEZe4eiQTKwoasmvgdN6ZJyw18sCvwfAW5giDR0cCAjl5gG1YTLvPYy4updZSQhecbclRYOSwyObNBG0TslWPfSc0SQ5L4QSkdGmbE6wjDuDGTDAll5gGvZTLvPYy4updZSQhecbclRAEjCsjQiKbPNh987M398mkRfgAW5giDR0cCAbdiKwu65rW8B((8UNNrzTWqdo3aPBLwGtlyfOZ7EEioVyCQe8XWdHaMexHPYy4uFE3ZJY8qCEGf9e5KkbB9UgtSk0IEE2SNhyrproPsWwVRXrnFJZ7ceopIZZM98RydUKaeslk98iyExKvnVexLvxGtlTCeGuNwkahZsUHDim3wwLkJHt9mmZQEqieiSSQ5LWjLOIqgKE(grpplZ7EEuMNrzTWqdo3aPBLwGtlyfOZZM98al6jYjvc26DnoQ5BCE)D8(1QWqdo3aPBLwGtlyaH0IsppIZ7EEuMNrzTWqdo3aPBLwGtlyaH0IsppcMFZ3NNn75bw0tKtQeS17AmGqArPNhbZV57ZJyw18sCvwDboT0YrasDAPaCml5g2Tl3wwLkJHt9mmZQEqieiSSQyCQe8XWdHaMexHPYy4uFE3ZZOSwyObNBG0TslWPfSc05DppkZJY8mkRfgAW5giDR0cCAbdiKwu65rW8B((8SzppJYAHvk4h3XKwauTjWXkqN398mkRfwPGFChtAbq1MahdiKwu65rW8B((8ioV75rz(oXOSwyG1Uhi8ewlMF)8ONh1ZZM98qC(ozc80(k2GlyGsrRdSryG1Uhi808iopIzvZlXvz1f40slhbi1PLcWXSKByhl52YQuzmCQNHzw1dcHaHLvfJtLGzaKjWt3kPJQdSTtByQmgo1N398aLk8jOxlcG70k8HmFJZdliCE3ZdukAEeGEExmV75rzEgL1cZaitGNUvshvhyBN2WkqNNn7593X7xRcZaitGNUvshvhyBN2WacPfLE(gNhwq48iopB2ZdX5fJtLGzaKjWt3kPJQdSTtByQmgo1N398aLk8jOxlcG70k8HmFJONNfuNvnVexLvH7i0tGtaKHpbfqAQ8uwYnSZf52YQuzmCQNHzw1dcHaHLvzuwlm0GZnq6wPf40cwbAw18sCvwfyHMsDY6zj3Woyj3wwLkJHt9mmZQEqieiSSQ5LWjLOIqgKE(grpplZ7EEuMN5065Dp)k2GljaH0IsppcM3fZZM98qCEgL1cZaitGNUvshvhyBN2WkqN398OmpusWBWpfogqiTO0ZJG53895zZEEGf9e5KkbB9UgdiKwu65rW8UyE3ZdSONiNujyR314OMVX5HscEd(PWXacPfLEEeNhXSQ5L4QSQ28Gyf(W4jOMxYsUHDOo3wwLkJHt9mmZQEqieiSSQ5LWjLOIqgKE(gNh1ZZM98aLIwhyJWqHtg4qEfPXuzmCQNvnVexLv7KjWtw1tDYBoMLSKvfqu7jrNBl3WUCBzvQmgo1ZWmRAEjUkRgL2dueJHtP2PIvIcYuNCgEkR2jTheqL4QSABGO2tIoR6bHqGWYQmkRfgAW5giDR0cCAbRaDE2SNxmWgjyjqsj5sq9sIfeopcMh1ZZM98RydUKaeslk98iyEw2LLCdSKBlRsLXWPEgMzvZlXvzvbe1Es2Lv7K2dcOsCvwTn408ciQ9KmFRqGpVaNMhESbN0Y8KwcKMq95DACfY15BfC(8m08kAQp)kaAzER6Zd1ca1NVviWNhwj4Cdm)TMhvfCAbNv9GqiqyzvioVtdegdNWAOKpwb1tciQ9KmV75zuwlm0GZnq6wPf40cwb68UNhL5H48IXPsWHN8gumvgdN6ZZM98IXPsWHN8gumvgdN6Z7EEgL1cdn4CdKUvAboTGbeslk98nIE(DiCEeN398OmpeNxarTNeSWcgUPt(749RvnpB2ZlGO2tcwyb7VJ3VwfgqiTO0ZZM98onqymCclGO2tsckioqioop653npIZZM98ciQ9KGLDygL1k1vaMexnFJONFfBWLeGqArPZsUbxKBlRsLXWPEgMzvpiecewwfIZ70aHXWjSgk5Jvq9KaIApjZ7EEgL1cdn4CdKUvAboTGvGoV75rzEioVyCQeC4jVbftLXWP(8SzpVyCQeC4jVbftLXWP(8UNNrzTWqdo3aPBLwGtlyaH0IspFJONFhcNhX5DppkZdX5fqu7jbl7WWnDYFhVFTQ5zZEEbe1EsWYoS)oE)AvyaH0IsppB2Z70aHXWjSaIApjjOG4aH448ONNL5rCE2SNxarTNeSWcMrzTsDfGjXvZ3i65xXgCjbiKwu6SQ5L4QSQaIApjSKLCdWsUTSkvgdN6zyMvnVexLvfqu7jzxwTtApiGkXvzvu9A(R4oo)v08xnVIMMxarTNK5HcoNrN0ZBZZOSwUoVIMMxGtZFcCcm)vZ7VJ3VwfEEyDW8XA(IcbobMxarTNK5HcoNrN0ZBZZOSwUoVIMMN5e4ZF18(749RvHZQEqieiSSkeNxarTNeSSdd30jfnLyuwR5DppkZlGO2tcwyb7VJ3VwfgqiTO0ZZM98qCEbe1EsWcly4MoPOPeJYAnpIZZM98(749RvHHgCUbs3kTaNwWacPfLE(gNNfeMLCdOo3wwLkJHt9mmZQEqieiSSkeNxarTNeSWcgUPtkAkXOSwZ7EEuMxarTNeSSd7VJ3VwfgqiTO0ZZM98qCEbe1EsWYomCtNu0uIrzTMhX5zZEE)D8(1QWqdo3aPBLwGtlyaH0IspFJZZccZQMxIRYQciQ9KWswYswTtltHl52YnSl3ww18sCvwfzu90cqu7szvQmgo1ZWml5gyj3wwLkJHt9mmZQh0SQMKSQ5L4QSQtdegdNYQonUcLvrzEQDQeqHsDCuApqrmgoLANkwjkitDYz4P5DpV)oE)Av4O0EGIymCk1ovSsuqM6KZWtyazDhNhXSAN0EqavIRYQWkaYjvY8AOKpwb1NxarTNe98muuBZROP(8Tcb(8MICinj8ZZJI0zvNgivgskRQHs(yfupjGO2tswYn4ICBzvQmgo1ZWmREqZQAsYQMxIRYQonqymCkR604kuw18s4Ksuridspp653nV75rzEGf9e5KkbB9Ugh18no)ouppB2ZdX5bw0tKtQeS17AmXQql65rmR60aPYqszvTKGYTQIAll5gGLCBzvQmgo1ZWmREqZQAsYQMxIRYQonqymCkR604kuw18s4KsuridspFJONNL5DppkZdX5bw0tKtQeS17AmXQql65zZEEGf9e5KkbB9UgtSk0IEE3ZJY8al6jYjvc26DngqiTO0Z348OEE2SNFfBWLeGqArPNVX53HW5rCEeZQonqQmKuw16DDcqiTOYsUbuNBlRsLXWPEgMzvZlXvzvaH8aAItADQvucbYQDs7bbujUkRY6GcL748OQGtlZJQsojGRZJ0IsSOMhv7DC(2m(v65TQp)EIGopRLqEanXjTEEuPOecmp448O2YQEqieiSSQ)QUsiyYjbwGtlyQmgo1N398IXPsWBMaNarTL0YbqIPYy4uFE3ZdX5fJtLGpgEieWK4kmvgdN6Z7EE)D8(1QWqdo3aPBLwGtlyaH0IsNLCdTxUTSkvgdN6zyMvnVexLvHFT4rTLy4MwYQEqieiSSA)e8cCAjTiNeadOfG0WngonV75rzEX4uj4WtEdkMkJHt95zZEEiopJYAHzaKjWt3kPJQdSTtByfOZ7EEX4ujygazc80Ts6O6aB70gMkJHt95zZEEX4uj4JHhcbmjUctLXWP(8UN3FhVFTkm0GZnq6wPf40cgqiTO0Z7EEiopJYAH3hCEuBjKMhEuewb68iMv9o65usmWgj6Cd7YsUbwtUTSkvgdN6zyMv9GqiqyzvgL1chEhtIXVsJbeslk98ia98B((8UNNrzTWH3XKy8R0yfOZ7EEnuIZtIb2irJ34MpmEY6oTYtZ3i65zzE3ZJY8qCEX4ujygazc80Ts6O6aB70gMkJHt95zZEE)D8(1QWmaYe4PBL0r1b22PnmGqArPNVX53H65rmRAEjUkRUXnFy8K1DALNYsUbyTCBzvQmgo1ZWmR6bHqGWYQmkRfo8oMeJFLgdiKwu65ra653895DppJYAHdVJjX4xPXkqN398OmpeNxmovcMbqMapDRKoQoW2oTHPYy4uFE2SN3FhVFTkmdGmbE6wjDuDGTDAddiKwu65BC(DOEEeZQMxIRYQlWPLKwaXEkl5gGvZTLvPYy4updZSAN0EqavIRYQoa(DAAEwNxIRMNhAzE5MhOuzvZlXvzvVX5jZlXvjEOLSkp0sQmKuw1FoPYkrNLCd7qyUTSkvgdN6zyMvnVexLv9gNNmVexL4HwYQ8qlPYqszvG5dJRZsUHD7YTLvPYy4updZSQ5L4QSQ348K5L4Qep0swLhAjvgskRkGO2tIol5g2XsUTSkvgdN6zyMvnVexLv9gNNmVexL4HwYQ8qlPYqszv)D8(1Q0zj3WoxKBlRsLXWPEgMzvpiecewwvmovc2F8EcozabtLXWP(8UNNrzTW(J3tWjdiyTy(9Z3i653HW5DppkZ3jgL1cdS29aHNWAX87Nh98OEE2SNhIZ3jtGN2xXgCbdukADGncdS29aHNMhXSQ5L4QSQ348K5L4Qep0swLhAjvgskR6pEpbNmGKLCd7GLCBzvQmgo1ZWmR6bHqGWYQmkRfMbqMapDRKoQoW2oTHvGMvnVexLvbkvY8sCvIhAjRYdTKkdjLvzoDsc)(O2YsUHDOo3wwLkJHt9mmZQEqieiSSQyCQemdGmbE6wjDuDGTDAdtLXWP(8UNhL593X7xRcZaitGNUvshvhyBN2WacPfLEEem)oeopIZ7EEuMhyrproPsWwVRXrnFJZZcQNNn75H48al6jYjvc26DnMyvOf98SzpV)oE)AvyObNBG0TslWPfmGqArPNhbZVdHZ7EEGf9e5KkbB9UgtSk0IEE3ZdSONiNujyR314OMhbZVdHZJyw18sCvwfOujZlXvjEOLSkp0sQmKuwL50jO3XJAll5g21E52YQuzmCQNHzw1dcHaHLvzuwlm0GZnq6wPf40cwb68UNxmovc(y4HqatIRWuzmCQNvnVexLvbkvY8sCvIhAjRYdTKkdjLvpgEieWK4QSKByhRj3wwLkJHt9mmZQEqieiSSQyCQe8XWdHaMexHPYy4uFE3Z7VJ3VwfgAW5giDR0cCAbdiKwu65rW87q48UNhL5DAGWy4ewljOCRQO2MNn75bw0tKtQeS17AmXQql65DppWIEICsLGTExJJAEem)oeopB2ZdX5bw0tKtQeS17AmXQql65rmRAEjUkRcuQK5L4Qep0swLhAjvgskREm8qiGjXvjO3XJAll5g2bRLBlRsLXWPEgMzvpieceww18s4KsuridspFJONNLSQ5L4QSkqPsMxIRs8qlzvEOLuziPSQDuwYnSdwn3wwLkJHt9mmZQMxIRYQEJZtMxIRs8qlzvEOLuziPSQwSQBGEwYswL50jj87JAl3wUHD52YQuzmCQNHzw18sCvw9y4HqatOSQ3rpNsIb2irNByxw1dcHaHLvbkv4tqVwea3Pv4dz(grpF7HWSAN0EqavIRYQWeqMaF(BnVAuDGTDABEwNxcN08S2tmjUkl5gyj3wwLkJHt9mmZQEqieiSSQyCQe8MjWjquBjTCaKyQmgo1NNn759x1vcbtojWcCAbtLXWP(8SzppqPO1b2imtirTL8hVJPYy4uFE2SN38s4KsuridspFJONNLSQ5L4QSkGqEanXjTo1kkHazj3GlYTLvPYy4updZSQhecbclRYOSwyqGKWkqN398OmpqPcFc61Ia4oTcFiZJG5rnQNNn75bkfHLajLKl5I5ra653895zZEEnuIZtIb2irJHFT4rTLy4MwMVr0ZZY8iMvnVexLvHFT4rTLy4MwYsUbyj3wwLkJHt9mmZQMxIRYQhdpecycLv9GqiqyzvGsryjqsj5sWY8iy(nFFE2SNhOuHpb9AraCNwHpK5Be98WcQZQEh9CkjgyJeDUHDzj3aQZTLvPYy4updZSQhecbclRYOSw49bNh1wcP5HhfHvGoV751qjopjgyJenEboTO9okWP5Be98SmV75rzEioFNmbEYQEQtEZrSe(9rTnV759NtQSsWvSbxslJMNn75H48(Zjvwj4k2GlPLrZJyw18sCvwDboTO9okWPSKBO9YTLvPYy4updZSQhecbclRcuQWNGETiaUtRWhY8nIEEybHZ7EEGsryjqsj5sUy(gNFZ3ZQMxIRYQWpqLUvQvucbYsUbwtUTSkvgdN6zyMv9GqiqyzvnuIZtIb2irJxGtlAVJcCA(grpplZ7EEuMNrzTWDYe46uxHWAX87Nh98WY8SzppeNVtMapzvp1jV5iwc)(O2MNn75H48(Zjvwj4k2GlPLrZJyw18sCvwDboTO9okWPSKBawl3wwLkJHt9mmZQMxIRYQhdpecycLv9GqiqyzvGsf(e0RfbWDAf(qMVX5zb1Z7EEGsrZ348UiR6D0ZPKyGns05g2LLCdWQ52YQuzmCQNHzw1dcHaHLvzuwlmiqsyfOzvZlXvzv4xlEuBjgUPLSKByhcZTLvPYy4updZSQhecbclRcuQWNGETiaUtRWhY8nopQryw18sCvw1aEROKCaavswYswYQojGoUk3aliKLDiewqOlYQTmqf1MoRIkX6yTnGQBODWHZpFBWP5dKqpGm)6aZ38y4HqatIRsqVJh1wZ5bu7ujauFE9HKM3uKdPjuFEpCR2inEG0LrrZVZHZ7GRCsaH6Z3umovcgcnNxU5BkgNkbdbmvgdN6nNhLDScr8aPlJIMFNdN3bx5Kac1NVjqPO1b2imeAoVCZ3eOu06aBegcyQmgo1Bopk7yfI4bsxgfn)ohoVdUYjbeQpFt)vDLqWqO58YnFt)vDLqWqatLXWPEZ5rzhRqepqoqIkX6yTnGQBODWHZpFBWP5dKqpGm)6aZ30F8EcozaP58aQDQeaQpV(qsZBkYH0eQpVhUvBKgpq6YOO535W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZJYowHiEG0LrrZZIdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1Bopk7yfI4bsxgfnVlC48o4kNeqO(8nfJtLGHqZ5LB(MIXPsWqatLXWPEZ5rzhRqepq6YOO5HfhoVdUYjbeQpFtX4ujyi0CE5MVPyCQemeWuzmCQ3CEu2XkeXdKdKOsSowBdO6gAhC48Z3gCA(aj0diZVoW8npgEieWK4QMZdO2PsaO(86djnVPihstO(8E4wTrA8aPlJIMFNdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1Bopk7yfI4bsxgfn)ohoVdUYjbeQpFtGsrRdSryi0CE5MVjqPO1b2imeWuzmCQ3CEu2XkeXdKUmkA(DoCEhCLtciuF(M(R6kHGHqZ5LB(M(R6kHGHaMkJHt9MZJYowHiEG0LrrZ3EoCEhCLtciuF(M(R6kHGHqZ5LB(M(R6kHGHaMkJHt9MZJYowHiEG0LrrZdR6W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZJclScr8a5ajQeRJ12aQUH2bho)8TbNMpqc9aY8RdmFtMtNKWVpQTMZdO2PsaO(86djnVPihstO(8E4wTrA8aPlJIMNfhoVdUYjbeQpFtX4ujyi0CE5MVPyCQemeWuzmCQ3CEu2XkeXdKUmkAEwC48o4kNeqO(8nbkfToWgHHqZ5LB(MaLIwhyJWqatLXWPEZ5rzhRqepq6YOO5zXHZ7GRCsaH6Z30FvxjemeAoVCZ30FvxjemeWuzmCQ3CEu2XkeXdKdKOsSowBdO6gAhC48Z3gCA(aj0diZVoW8n9NtQSs0nNhqTtLaq951hsAEtroKMq959WTAJ04bsxgfnploCEhCLtciuF(MIXPsWqO58YnFtX4ujyiGPYy4uV58OSJviIhiDzu08UWHZ7GRCsaH6Z3umovcgcnNxU5BkgNkbdbmvgdN6nNhLDScr8aPlJIMhwC48o4kNeqO(8nfJtLGHqZ5LB(MIXPsWqatLXWPEZ5rzhRqepq6YOO5rTdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1BopkSWkeXdKdKOsSowBdO6gAhC48Z3gCA(aj0diZVoW8n1IvDd0BopGANkbG6ZRpK08MICinH6Z7HB1gPXdKUmkA(DoCEhCLtciuF(MIXPsWqO58YnFtX4ujyiGPYy4uV58OSJviIhiDzu087C48o4kNeqO(8nbkfToWgHHqZ5LB(MaLIwhyJWqatLXWPEZ5nzEufyDxopk7yfI4bsxgfn)ohoVdUYjbeQpFt)vDLqWqO58YnFt)vDLqWqatLXWPEZ5rzhRqepq6YOO5DHdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1BoVjZJQaR7Y5rzhRqepq6YOO5HfhoVdUYjbeQpFt)vDLqWqO58YnFt)vDLqWqatLXWPEZ5rHfwHiEG0LrrZ3EoCEhCLtciuF(MIXPsWqO58YnFtX4ujyiGPYy4uV58OSJviIhiDzu08SghoVdUYjbeQpFtX4ujyi0CE5MVPyCQemeWuzmCQ3CEu2XkeXdKUmkAEynhoVdUYjbeQpFtX4ujyi0CE5MVPyCQemeWuzmCQ3CEu2XkeXdKdKOsSowBdO6gAhC48Z3gCA(aj0diZVoW8nzoDc6D8O2AopGANkbG6ZRpK08MICinH6Z7HB1gPXdKUmkAEwC48o4kNeqO(8nfJtLGHqZ5LB(MIXPsWqatLXWPEZ5rzhRqepq6YOO5zXHZ7GRCsaH6Z3eOu06aBegcnNxU5BcukADGncdbmvgdN6nNhLDScr8aPlJIMNfhoVdUYjbeQpFt)vDLqWqO58YnFt)vDLqWqatLXWPEZ5rzhRqepq6YOO5BphoVdUYjbeQpFtX4ujyi0CE5MVPyCQemeWuzmCQ3CEu2XkeXdKUmkAEwJdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1Bopk7yfI4bYbsujwhRTbuDdTdoC(5BdonFGe6bK5xhy(MqbK)qYysZ5bu7ujauFE9HKM3uKdPjuFEpCR2inEG0LrrZVZHZ7GRCsaH6ZRgiDW8AhlXy18SEw)8YnVlvS5rEDfUIE(dkbm5aZJcRhX5rHfwHiEG0LrrZVZHZ7GRCsaH6Z3umovcgcnNxU5BkgNkbdbmvgdN6nNhfxWkeXdKUmkA(DoCEhCLtciuF(MciQ9KG3HHqZ5LB(MciQ9KGLDyi0CEuCbRqepq6YOO5zXHZ7GRCsaH6ZRgiDW8AhlXy18SEw)8YnVlvS5rEDfUIE(dkbm5aZJcRhX5rHfwHiEG0LrrZZIdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1BopkUGviIhiDzu08S4W5DWvojGq95BkGO2tcMfmeAoVCZ3uarTNeSWcgcnNhfxWkeXdKUmkAEx4W5DWvojGq95vdKoyETJLySAEw)8YnVlvS57HZqhxn)bLaMCG5rb2iopkSWkeXdKUmkAEx4W5DWvojGq95BkGO2tcEhgcnNxU5BkGO2tcw2HHqZ5rbwyfI4bsxgfnVlC48o4kNeqO(8nfqu7jbZcgcnNxU5BkGO2tcwybdHMZJcQzfI4bYbsujwhRTbuDdTdoC(5BdonFGe6bK5xhy(M(749RvPBopGANkbG6ZRpK08MICinH6Z7HB1gPXdKUmkAEwC48o4kNeqO(8nfJtLGHqZ5LB(MIXPsWqatLXWPEZ5rzhRqepq6YOO5DHdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1Bopk7yfI4bsxgfnpS4W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZJYowHiEG0LrrZJAhoVdUYjbeQpFtX4ujyi0CE5MVPyCQemeWuzmCQ3CEu2XkeXdKUmkA(2ZHZ7GRCsaH6Z3umovcgcnNxU5BkgNkbdbmvgdN6nNhLDScr8aPlJIMN14W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZJYowHiEG0LrrZdR6W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZJYowHiEG0LrrZVBNdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1Bopk7yfI4bsxgfn)owC48o4kNeqO(8nfJtLGHqZ5LB(MIXPsWqatLXWPEZ5rHfwHiEG0LrrZVd1oCEhCLtciuF(MaLIwhyJWqO58YnFtGsrRdSryiGPYy4uV58MmpQcSUlNhLDScr8a5ajQeRJ12aQUH2bho)8TbNMpqc9aY8RdmFtbe1Es0nNhqTtLaq951hsAEtroKMq959WTAJ04bsxgfnploCEhCLtciuF(MIXPsWqO58YnFtX4ujyiGPYy4uV58OWcRqepq6YOO5zXHZ7GRCsaH6Z3uarTNe8omeAoVCZ3uarTNeSSddHMZJYowHiEG0LrrZZIdN3bx5Kac1NVPaIApjywWqO58YnFtbe1EsWclyi0CEuyHviIhiDzu08UWHZ7GRCsaH6Z3umovcgcnNxU5BkgNkbdbmvgdN6nNhfwyfI4bsxgfnVlC48o4kNeqO(8nfqu7jbVddHMZl38nfqu7jbl7WqO58OWcRqepq6YOO5DHdN3bx5Kac1NVPaIApjywWqO58YnFtbe1EsWclyi0CEu2XkeXdKUmkAEyXHZ7GRCsaH6Z3uarTNe8omeAoVCZ3uarTNeSSddHMZJYowHiEG0LrrZdloCEhCLtciuF(MciQ9KGzbdHMZl38nfqu7jblSGHqZ5rHfwHiEG0LrrZJAhoVdUYjbeQpFtbe1EsW7WqO58YnFtbe1EsWYomeAopkSWkeXdKUmkAEu7W5DWvojGq95BkGO2tcMfmeAoVCZ3uarTNeSWcgcnNhLDScr8a5ajQeRJ12aQUH2bho)8TbNMpqc9aY8RdmFZoTmfU0CEa1ovca1NxFiP5nf5qAc1N3d3QnsJhiDzu08O2HZ7GRCsaH6Z3umovcgcnNxU5BkgNkbdbmvgdN6nNhfwyfI4bsxgfnpQD48o4kNeqO(8n9x1vcbdHMZl38n9x1vcbdbmvgdN6nNhLDScr8aPlJIMV9C48o4kNeqO(8nfJtLGHqZ5LB(MIXPsWqatLXWPEZ5rXfScr8aPlJIMN14W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZJYowHiEG0LrrZdR5W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZJYowHiEG0LrrZVZfoCEhCLtciuF(MIXPsWqO58YnFtX4ujyiGPYy4uV58OSJviIhiDzu087qTdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1Bopk7yfI4bsxgfn)U2ZHZ7GRCsaH6Z3umovcgcnNxU5BkgNkbdbmvgdN6nN3K5rvG1D58OSJviIhiDzu087ynoCEhCLtciuF(MIXPsWqO58YnFtX4ujyiGPYy4uV58OSJviIhihirLyDS2gq1n0o4W5NVn408bsOhqMFDG5BAh1CEa1ovca1NxFiP5nf5qAc1N3d3QnsJhiDzu08S4W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZBY8OkW6UCEu2XkeXdKUmkAEx4W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZBY8OkW6UCEu2XkeXdKUmkAEwJdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1Bopk7yfI4bsxgfnpSMdN3bx5Kac1NVPyCQemeAoVCZ3umovcgcyQmgo1Bopk7yfI4bsxgfn)oe6W5DWvojGq95BkgNkbdHMZl38nfJtLGHaMkJHt9MZJYowHiEGCGSn408nv0ukecPU58MxIRMVLPNVoz(1Pu95JAEbEONpqc9acEGevJe6beQp)oxmV5L4Q55Hw04bYSkuWTcoLvB)2F(2rKjWNhv2k2GlZJQcoTmq2(T)8qQu08SWACDEwqil7gihiB)2FEha3Qnspq2(T)8OYNN1sipNuFEUPfu5AYFvFEfTTrZFR5DaClk983AEuTNM30ZhY89J0vtzEOCZX5BrC(8rnpuG5LWt4bYbY2FEufNgxXespVnVaIApj6593X7xRY157HZOt95zCCEObNBG5V18lWPL5pW8maYe4ZFR51r1b22PTM6593X7xRcppQEnFin1Z704k08Wn981npGqAr1jW8asua187CDEIRP5bKOaQ5rig14bsZlXvAmua5pKmMad0W2PbcJHtUwgscTaIApjPDjTJL31dkAnjXYvNgxHqVZvNgxHsextOrig1U6VQhsCfAbe1EsW7WWnDsrtjgL1YnkqumovcMbqMapDRKoQoW2oT5gfbe1EsW7W(749RvH7katIRy9SE)D8(1QWqdo3aPBLwGtl4UcWK4k0ier2SfJtLGzaKjWt3kPJQdSTtBUrXFhVFTkmdGmbE6wjDuDGTDAd3vaMexX6z9ciQ9KG3H93X7xRc3vaMexHgHiYMTyCQeC4jVbfXbsZlXvAmua5pKmMad0W2PbcJHtUwgscTaIApjjwsAhlVRhu0AsILRonUcHENRonUcLiUMqJqmQD1FvpK4k0ciQ9KGzbd30jfnLyuwl3OarX4ujygazc80Ts6O6aB70MBuequ7jbZc2FhVFTkCxbysCfRN17VJ3VwfgAW5giDR0cCAb3vaMexHgHiYMTyCQemdGmbE6wjDuDGTDAZnk(749RvHzaKjWt3kPJQdSTtB4UcWK4kwpRxarTNemly)D8(1QWDfGjXvOriISzlgNkbhEYBqrCGS9Nhvrlbsti9828ciQ9KON3PXvO5zCCE)HeQbIABEbonV)oE)AvZFR5f408ciQ9K4689Wz0P(8mooVaNMVRamjUA(BnVaNMNrzTMpK5HcoNrN045BhB65T51cGQnb(8iVESccmVCZVfoP5T5HhBWjW8qbXbcXX5LBETaOAtGpVaIApjAxN30Z3I485n9828iVESccm)6aZhR5T5fqu7jz(wbNp)bMVvW5ZxNmV2XYpFRqGpV)oE)AvA8aP5L4kngkG8hsgtGbAy70aHXWjxldjHwarTNKeuqCGqC01dkAnjXYvNgxHqZIRonUcLiUMqVZv)v9qIRqdrbe1EsW7WWnDsrtjgL1YTaIApjywWWnDsrtjgL1InBbe1EsWSGHB6KIMsmkRLBuqrarTNemly)D8(1QWDfGjXvSEbe1EsWSGzuwRuxbysCfIOcu2Hrnmequ7jbZcgUPtmkRfwlaQ2e4iIkqXPbcJHtybe1EssSK0owEerSruqrarTNe8oS)oE)Av4UcWK4kwVaIApj4DygL1k1vaMexHiQaLDyuddbe1EsW7WWnDIrzTWAbq1MahrubkonqymCclGO2tsAxs7y5reXbYbYbY2V9NhvHvKxrO(8Ktc448sGKMxGtZBE5aZh65nNwWngoHhinVexPrJmQEAbiQDPbY2FEyfa5KkzEnuYhRG6ZlGO2tIEEgkQT5v0uF(wHaFEtroKMe(55rr6bsZlXvAyGg2onqymCY1YqsO1qjFScQNequ7jXvNgxHqJc1ovcOqPookThOigdNsTtfRefKPo5m8KB)D8(1QWrP9afXy4uQDQyLOGm1jNHNWaY6oI4aP5L4knmqdBNgimgo5Azij0AjbLBvf1MRonUcH28s4KsuridsJENBuaw0tKtQeS17ACunUd1SzdrGf9e5KkbB9UgtSk0IgXbsZlXvAyGg2onqymCY1YqsOTExNaeslkxDACfcT5LWjLOIqgKUr0S4gficSONiNujyR31yIvHw0SzdSONiNujyR31yIvHw0UrbyrproPsWwVRXacPfLUruZM9k2GljaH0Is34oeIiIdKT)8SoOq5oopQk40Y8OQKtc468iTOelQ5r1EhNVnJFLEER6ZVNiOZZAjKhqtCsRNhvkkHaZdoopQTbsZlXvAyGg2ac5b0eN06uROec4ASq7VQRecMCsGf40IBX4uj4ntGtGO2sA5aiDdrX4uj4JHhcbmjUYT)oE)AvyObNBG0TslWPfmGqArPhinVexPHbAyd)AXJAlXWnT4Q3rpNsIb2irJENRXcD)e8cCAjTiNeadOfG0Wngo5gfX4uj4WtEdkB2qKrzTWmaYe4PBL0r1b22PnScu3IXPsWmaYe4PBL0r1b22Pn2SfJtLGpgEieWK4k3(749RvHHgCUbs3kTaNwWacPfL2nezuwl8(GZJAlH08WJIWkqrCG08sCLggOH9g38HXtw3PvEY1yHMrzTWH3XKy8R0yaH0IsJa0B(UBgL1chEhtIXVsJvG6wdL48KyGns04nU5dJNSUtR8uJOzXnkqumovcMbqMapDRKoQoW2oTXMT)oE)Avygazc80Ts6O6aB70ggqiTO0nUd1ioqAEjUsdd0WEboTK0ci2tUgl0mkRfo8oMeJFLgdiKwuAeGEZ3DZOSw4W7ysm(vAScu3OarX4ujygazc80Ts6O6aB70gB2(749RvHzaKjWt3kPJQdSTtByaH0Is34ouJ4az7pVdGFNMMN15L4Q55HwMxU5bk1aP5L4knmqdBVX5jZlXvjEOfxldjH2FoPYkrpqAEjUsdd0W2BCEY8sCvIhAX1YqsObMpmUEG08sCLggOHT348K5L4Qep0IRLHKqlGO2tIEG08sCLggOHT348K5L4Qep0IRLHKq7VJ3VwLEG08sCLggOHT348K5L4Qep0IRLHKq7pEpbNmG4ASqlgNkb7pEpbNmG4MrzTW(J3tWjdiyTy(9nIEhcDJsNyuwlmWA3deEcRfZVhnQzZgIDYe4P9vSbxWaLIwhyJWaRDpq4jehinVexPHbAyduQK5L4Qep0IRLHKqZC6Ke(9rT5ASqZOSwygazc80Ts6O6aB70gwb6aP5L4knmqdBGsLmVexL4HwCTmKeAMtNGEhpQnxJfAX4ujygazc80Ts6O6aB70MBu83X7xRcZaitGNUvshvhyBN2WacPfLgb7qiIUrbyrproPsWwVRXr1ilOMnBicSONiNujyR31yIvHw0Sz7VJ3VwfgAW5giDR0cCAbdiKwuAeSdHUbw0tKtQeS17AmXQqlA3al6jYjvc26DnokeSdHioqAEjUsdd0WgOujZlXvjEOfxldjH(y4HqatIRCnwOzuwlm0GZnq6wPf40cwbQBX4uj4JHhcbmjUAG08sCLggOHnqPsMxIRs8qlUwgsc9XWdHaMexLGEhpQnxJfAX4uj4JHhcbmjUYT)oE)AvyObNBG0TslWPfmGqArPrWoe6gfNgimgoH1sck3QkQn2Sbw0tKtQeS17AmXQqlA3al6jYjvc26DnokeSdHSzdrGf9e5KkbB9UgtSk0IgXbsZlXvAyGg2aLkzEjUkXdT4Azij02rUgl0MxcNuIkczq6grZYaP5L4knmqdBVX5jZlXvjEOfxldjHwlw1nqFGCGS9NN1DOkZZApXK4QbsZlXvASDeAaH8aAItADQvucbginVexPX2rWanS34MpmEY6oTYtUgl0IXPsWlWPfT3rbonqAEjUsJTJGbAyVaNwsAbe7jx9o65usmWgjA07CnwO93X7xRcdiKhqtCsRtTIsiagqiTO0ianlOInF3TyCQe8MjWjquBjTCaKdKMxIR0y7iyGg2WVw8O2smCtlUgl0mkRfgeijSc0bsZlXvASDemqd7JHhcbmHCnwO7KjWtw1tDYBoILWVpQn3(Zjvwj4k2GlPLrUzuwlCNmbUo1viSwm)EealdKMxIR0y7iyGg2lWPfT3rbo5ASqZOSw49bNh1wcP5HhfHbK5f3OaXozc8Kv9uN8MJyj87JAZT)CsLvcUIn4sAzeB2q0FoPYkbxXgCjTmcXbsZlXvASDemqd7nU5dJNSUtR8KRXcnqPcFc61Ia4oTcFiiaLDOggIXPsWaLk8jteQumjUcv4cehinVexPX2rWanSxGtljTaI9KREh9CkjgyJen6DUgl0aLk8jOxlcG70k8HGau2HAyigNkbduQWNmrOsXK4kuHlqCG08sCLgBhbd0WEboTO9okWjxJfAi2jtGNSQN6K3CelHFFuBU9NtQSsWvSbxslJyZgI(Zjvwj4k2GlPLrdKMxIR0y7iyGg2hdpecyc5Q3rpNsIb2irJENRXcnqPcFc61Ia4oTcFinIclOggIXPsWaLk8jteQumjUcv4cehinVexPX2rWanS34MpmEY6oTYtdKMxIR0y7iyGg2lWPLKwaXEYvVJEoLedSrIg9UbsZlXvASDemqdB4hOs3k1kkHadKMxIR0y7iyGg2gWBfLKdaOsgihiB)5HjGmb(83AE1O6aB7028qVJh128GtmjUAEhoVwmGONFhc1ZZqRdqZdZtD(qpV50cUXWPbsZlXvAmZPtqVJh1gA4xlEuBjgUPfxJfAgL1cdcKewb6aP5L4knM50jO3XJAdgOHnGqEanXjTo1kkHaUgl0MxcNuIkczq6grZcB2aLIWsGKsYLqncqV57UrrmovcEZe4eiQTKwoas2S9x1vcbtojWcCAHnBGsrRdSryMqIAl5pEhXbY2F(MIb2ijfl0inw5qu6eJYAHbw7EGWtyTy(9WyhISEu6eJYAHbw7EGWtyaH0IsdJDiIk6KjWt7RydUGbkfToWgHbw7EGWtnNN1sqjt0ZBZZpX15f4HE(qpFucvDQpVCZlgyJK5f408WJn4KwMhkioqioopveshNVviWN3Q5nMGhIJZlWnz(wbNpVbfk3X5bw7EGWtZhR5bkfToWg1XZ3gCtMNHIABERMNkcPJZ3ke4ZJW51I53RDD(dmVvZtfH0X5f4MmVaNMVtmkR18TcoFE9D18eRGgaA(RWdKMxIR0yMtNGEhpQnyGg2hdpecyc5Q3rpNsIb2irJENRXcnqPcFc61Ia4oTcFinIMfupqAEjUsJzoDc6D8O2GbAyVXnFy8K1DALNCnwObkv4tqVwea3Pv4dbbSGq3AOeNNedSrIgVXnFy8K1DALNAenlU93X7xRcdn4CdKUvAboTGbeslkDJOEG08sCLgZC6e074rTbd0WEboTK0ci2tU6D0ZPKyGns0O35ASqduQWNGETiaUtRWhccybHU93X7xRcdn4CdKUvAboTGbeslkDJOEG08sCLgZC6e074rTbd0WEboTO9okWjxJfAgL1cVp48O2sinp8OimGmV4gOuHpb9AraCNwHpKgrzhQHHyCQemqPcFYeHkftIRqfUar3AOeNNedSrIgVaNw0Ehf4uJOzXnkmkRfUtMaxN6kewlMFpAyHnBi2jtGNSQN6K3CelHFFuBSzdr)5KkReCfBWL0YiehinVexPXmNob9oEuBWanSxGtlAVJcCY1yHgOuHpb9AraCNwHpKgrJIlqnmeJtLGbkv4tMiuPysCfQWfi6wdL48KyGns04f40I27OaNAenlUrHrzTWDYe46uxHWAX87rdlSzdXozc8Kv9uN8MJyj87JAJnBi6pNuzLGRydUKwgH4aP5L4knM50jO3XJAdgOH9g38HXtw3PvEY1yH2FhVFTkm0GZnq6wPf40cgqiTO0ncukclbskjxcwCduQWNGETiaUtRWhccGfe6wdL48KyGns04nU5dJNSUtR8uJOzzG08sCLgZC6e074rTbd0WEboTK0ci2tU6D0ZPKyGns0O35ASq7VJ3VwfgAW5giDR0cCAbdiKwu6gbkfHLajLKlblUbkv4tqVwea3Pv4dbbWcchihiB)5HjGmb(83AE1O6aB7028SoVeoP5zTNysC1aP5L4knM50jj87JAd9XWdHaMqU6D0ZPKyGns0O35ASqduQWNGETiaUtRWhsJOBpeoqAEjUsJzoDsc)(O2GbAydiKhqtCsRtTIsiGRXcTyCQe8MjWjquBjTCaKSz7VQRecMCsGf40cB2aLIwhyJWmHe1wYF8oB2MxcNuIkczq6grZYaP5L4knM50jj87JAdgOHn8RfpQTed30IRXcnJYAHbbscRa1nkaLk8jOxlcG70k8HGauJA2SbkfHLajLKl5ceGEZ3zZwdL48KyGns0y4xlEuBjgUPLgrZcIdKMxIR0yMtNKWVpQnyGg2hdpecyc5Q3rpNsIb2irJENRXcnqPiSeiPKCjybbB(oB2aLk8jOxlcG70k8H0iAyb1dKMxIR0yMtNKWVpQnyGg2lWPfT3rbo5ASqZOSw49bNh1wcP5HhfHvG6wdL48KyGns04f40I27OaNAenlUrbIDYe4jR6Po5nhXs43h1MB)5KkReCfBWL0Yi2SHO)CsLvcUIn4sAzeIdKMxIR0yMtNKWVpQnyGg2WpqLUvQvucbCnwObkv4tqVwea3Pv4dPr0WccDdukclbskjxYfnU57dKMxIR0yMtNKWVpQnyGg2lWPfT3rbo5ASqRHsCEsmWgjA8cCAr7DuGtnIMf3OWOSw4ozcCDQRqyTy(9OHf2SHyNmbEYQEQtEZrSe(9rTXMne9NtQSsWvSbxslJqCG08sCLgZC6Ke(9rTbd0W(y4Hqatix9o65usmWgjA07CnwObkv4tqVwea3Pv4dPrwqTBGsrn6IbsZlXvAmZPts43h1gmqdB4xlEuBjgUPfxJfAgL1cdcKewb6aP5L4knM50jj87JAdgOHTb8wrj5aaQexJfAGsf(e0RfbWDAf(qAe1iCGCGS9B)5DWX7Z3oMmGmVdUQhsCLEGS9B)5nVexPX(J3tWjdiO9WTO0PBLcp5ASqVIn4scqiTO0iyZ3hiB)5rLPMMVRaIABEyLGZnW8Tcb(8OAp5nOWgMaYe4dKMxIR0y)X7j4KbeyGg2E4wu60TsHNCnwOHOyCQe8XWdHaMex5MrzTWqdo3aPBLwGtlyaH0IsJax4MrzTWqdo3aPBLwGtlyfOUzuwlS)49eCYacwlMFFJO3HWbY2FEyDfrhDA(BnpSsW5gyEfnzB08Tcb(8OAp5nOWgMaYe4dKMxIR0y)X7j4KbeyGg2E4wu60TsHNCnwOHOyCQe8XWdHaMex5UtMapTVIn4cgOu06aBeEzCovjpqrBDc4gImkRfgAW5giDR0cCAbRa1nkmkRf2F8EcozabRfZVVr07Ap3mkRfwPGFChtAbq1MahRaLnBgL1c7pEpbNmGG1I533i6DWQU93X7xRcdn4CdKUvAboTGbeslkDJ7qiIdKMxIR0y)X7j4KbeyGg2E4wu60TsHNCnwOHOyCQe8XWdHaMex5gIDYe4P9vSbxWaLIwhyJWlJZPk5bkARta3mkRf2F8EcozabRfZVVr07qOBiYOSwyObNBG0TslWPfScu3(749RvHHgCUbs3kTaNwWacPfLUrwq4az7ppScGCsLmVdoEF(2XKbK5pNeWBqHg128DfquBZdn4CdmqAEjUsJ9hVNGtgqGbAy7HBrPt3kfEY1yHwmovc(y4HqatIRCdrgL1cdn4CdKUvAboTGvG6gfgL1c7pEpbNmGG1I533i6DTNBgL1cRuWpUJjTaOAtGJvGYMnJYAH9hVNGtgqWAX87Be9oyv2S93X7xRcdn4CdKUvAboTGbeslkncCHBgL1c7pEpbNmGG1I533i6DWcIdKdKT)8WkNexnqAEjUsJ93X7xRsdd0Wg6jXvUgl0mkRfgAW5giDR0cCAbRa1nJYAHjKqVweibukk1ImOxHvGoq2(Z7G749RvPhinVexPX(749RvPHbAytiHETiqcOuuQfzqVY1yHwmovc(y4HqatIRCdukcbTNBuCAGWy4ewljOCRQO2yZ2PbcJHtyR31jaH0Icr3O4VJ3VwfgAW5giDR0cCAbdiKwuAeGA2Szuwlm0GZnq6wPf40cwbkISzVIn4scqiTO0iGfeoqAEjUsJ93X7xRsdd0WMqc9ArGeqPOulYGELRXcTyCQemdGmbE6wjDuDGTDAZnqPcFc61Ia4oTcFincli0nqPiSeiPKCju34MV7gfgL1cZaitGNUvshvhyBN2WkqzZEfBWLeGqArPralieXbsZlXvAS)oE)AvAyGg2esOxlcKakfLArg0RCnwOfJtLGdp5nOUbkfHaxmqAEjUsJ93X7xRsdd0WgAW5giDR0cCAX1yHwmovcMbqMapDRKoQoW2oT5gfNgimgoH1sck3QkQn2SDAGWy4e26DDcqiTOq0nk(749RvHzaKjWt3kPJQdSTtByaH0IsZMT)oE)Avygazc80Ts6O6aB70ggqw3r3aLk8jOxlcG70k8HGauJqehinVexPX(749RvPHbAydn4CdKUvAboT4ASqlgNkbhEYBqDdrgL1cdn4CdKUvAboTGvGoqAEjUsJ93X7xRsdd0WgAW5giDR0cCAX1yHwmovc(y4HqatIRCJItdegdNWAjbLBvf1gB2onqymCcB9UobiKwui6gfX4uj4ntGtGO2sA5aiXuzmCQ7MrzTWac5b0eN06uROecGvGYMnefJtLG3mbobIAlPLdGetLXWPoIdKMxIR0y)D8(1Q0WanSzaKjWt3kPJQdSTtBUgl0mkRfgAW5giDR0cCAbRaDG08sCLg7VJ3VwLggOH9cCAPLJaK60sb4ORXcT5LWjLOIqgKg9o3mkRfgAW5giDR0cCAbdiKwuAeS57Uzuwlm0GZnq6wPf40cwbQBikgNkbFm8qiGjXvUrbIal6jYjvc26DnMyvOfnB2al6jYjvc26DnoQgDbcrKn7vSbxsacPfLgbUyG08sCLg7VJ3VwLggOH9cCAPLJaK60sb4ORXcT5LWjLOIqgKUr0S4gfgL1cdn4CdKUvAboTGvGYMnWIEICsLGTExJJQr)D8(1QWqdo3aPBLwGtlyaH0IsJOBuyuwlm0GZnq6wPf40cgqiTO0iyZ3zZgyrproPsWwVRXacPfLgbB(oIdKMxIR0y)D8(1Q0WanSxGtlTCeGuNwkahDnwOfJtLGpgEieWK4k3mkRfgAW5giDR0cCAbRa1nkOWOSwyObNBG0TslWPfmGqArPrWMVZMnJYAHvk4h3XKwauTjWXkqDZOSwyLc(XDmPfavBcCmGqArPrWMVJOBu6eJYAHbw7EGWtyTy(9OrnB2qStMapTVIn4cgOu06aBegyT7bcpHiIdKMxIR0y)D8(1Q0WanSH7i0tGtaKHpbfqAQ8KRXcTyCQemdGmbE6wjDuDGTDAZnqPcFc61Ia4oTcFincli0nqPieG2fUrHrzTWmaYe4PBL0r1b22PnScu2S93X7xRcZaitGNUvshvhyBN2WacPfLUrybHiYMnefJtLGzaKjWt3kPJQdSTtBUbkv4tqVwea3Pv4dPr0SG6bsZlXvAS)oE)AvAyGg2al0uQtw31yHMrzTWqdo3aPBLwGtlyfOdKMxIR0y)D8(1Q0WanS1MheRWhgpb18IRXcT5LWjLOIqgKUr0S4gfMtRDVIn4scqiTO0iWfSzdrgL1cZaitGNUvshvhyBN2WkqDJcusWBWpfogqiTO0iyZ3zZgyrproPsWwVRXacPfLgbUWnWIEICsLGTExJJQrOKG3GFkCmGqArPreXbsZlXvAS)oE)AvAyGg2DYe4jR6Po5nhDnwOnVeoPeveYG0nIA2SbkfToWgHHcNmWH8kspqoq2(Z7GZjvwjZZ6ycEibPhinVexPX(ZjvwjA0DYe46uxHCnwODAGWy4ewljOCRQO2yZ2PbcJHtyR31jaH0IAG08sCLg7pNuzLOHbAyRBzaKrTLqgAX1yHgOuHpb9AraCNwHpKgDHB)D8(1QWqdo3aPBLwGtlyaH0IsJax4gIIXPsWmaYe4PBL0r1b22Pn3onqymCcRLeuUvvuBdKMxIR0y)5KkRenmqdBDldGmQTeYqlUgl0qumovcMbqMapDRKoQoW2oT52PbcJHtyR31jaH0IAG08sCLg7pNuzLOHbAyRBzaKrTLqgAX1yHwmovcMbqMapDRKoQoW2oT5gfgL1cZaitGNUvshvhyBN2WkqDJItdegdNWAjbLBvf1MBGsf(e0RfbWDAf(qAewqiB2onqymCcB9UobiKwuUbkv4tqVwea3Pv4dPX2dHSz70aHXWjS176eGqAr5gyrproPsWwVRXacPfLgbWQiYMnezuwlmdGmbE6wjDuDGTDAdRa1T)oE)Avygazc80Ts6O6aB70ggqiTO0ioqAEjUsJ9NtQSs0WanSnMdzuMexL4bsgxJfA)D8(1QWqdo3aPBLwGtlyaH0IsJax42PbcJHtyTKGYTQIAZnkIXPsWmaYe4PBL0r1b22Pn3aLk8jOxlcG70k8HGG2dHU93X7xRcZaitGNUvshvhyBN2WacPfLgbSWMnefJtLGzaKjWt3kPJQdSTtBioqAEjUsJ9NtQSs0WanSnMdzuMexL4bsgxJfANgimgoHTExNaeslQbsZlXvAS)CsLvIggOHTgU53ZPKaNskvRdiWD01yH2FhVFTkm0GZnq6wPf40cgqiTO0iWfUDAGWy4ewljOCRQO2ginVexPX(ZjvwjAyGg2A4MFpNscCkPuToGa3rxJfANgimgoHTExNaeslQbYbY2FEyDgEieWK4Q5bNysC1aP5L4kn(y4HqatIRqdiKhqtCsRtTIsiGRXcT5LWjLOIqgKUr0UWnkIXPsWBMaNarTL0YbqYMT)QUsiyYjbwGtlSzdukADGncZesuBj)X7ioqAEjUsJpgEieWK4kyGg2WVw8O2smCtlU6D0ZPKyGns0O35ASqdX(j4f40sArojawc)(O2CdrgL1cVp48O2sinp8OiScu3aLIAeTlginVexPXhdpecysCfmqd7f40I27OaNCnwOzuwl8(GZJAlH08WJIWaY8IBnuIZtIb2irJxGtlAVJcCQr0S4gfgL1c3jtGRtDfcRfZVhnSWMne7KjWtw1tDYBoILWVpQn2SHO)CsLvcUIn4sAzeIdKMxIR04JHhcbmjUcgOH9XWdHaMqU6D0ZPKyGns0O35ASqZOSw49bNh1wcP5HhfHbK5f2SHiJYAHbbscRa1TgkX5jXaBKOXWVw8O2smCtlnI2fdKMxIR04JHhcbmjUcgOH9g38HXtw3PvEY1yHwdL48KyGns04nU5dJNSUtR8uJOzXnkaLk8jOxlcG70k8HGGDiKnBGsryjqsj5sS04MVJiB2O0jgL1cdS29aHNWAX87raQzZUtmkRfgyT7bcpHbeslknc2HAehinVexPXhdpecysCfmqd7f40sslGyp5ASq7VQRecMawp8Me1wIHFTCZOSwycy9WBsuBjg(1cRfZVhnlUnVeoPeveYG0O3nqAEjUsJpgEieWK4kyGg2WVw8O2smCtlUgl0mkRfgeijScu3AOeNNedSrIgd)AXJAlXWnT0iAwginVexPXhdpecysCfmqd7nU5dJNSUtR8KRXcTgkX5jXaBKOXBCZhgpzDNw5PgrZYaP5L4kn(y4HqatIRGbAyVaNwsAbe7jx9o65usmWgjA07CnwOHOyCQeS504w5HtUHiJYAH3hCEuBjKMhEuewbkB2IXPsWMtJBLho5gImkRfgeijScu2SzuwlmiqsyfOUbkfHLajLKlXsJO389bsZlXvA8XWdHaMexbd0Wg(1Ih1wIHBAX1yHMrzTWGajHvGoqAEjUsJpgEieWK4kyGg2hdpecyc5Q3rpNsIb2irJE3a5az7ppSYD8O2Mhv9aZdRZWdHaMex5W5vfdi653HW51K)QUEEgADaAEyLGZnW83AEuvWPL59hssp)TwZ7G2rdKMxIR04JHhcbmjUkb9oEuBObeYdOjoP1PwrjeW1yHwmovcEZe4eiQTKwoas2S9x1vcbtojWcCAHnBGsrRdSryMqIAl5pENnBZlHtkrfHmiDJOzzG08sCLgFm8qiGjXvjO3XJAdgOHn8RfpQTed30IRXcnJYAHbbscRaDG08sCLgFm8qiGjXvjO3XJAdgOH9XWdHaMqU6D0ZPKyGns0O35ASqZOSw49bNh1wcP5HhfHbK5LbsZlXvA8XWdHaMexLGEhpQnyGg2BCZhgpzDNw5jxJfAnuIZtIb2irJ34MpmEY6oTYtnIMf3aLk8jOxlcG70k8HGG2dHdKMxIR04JHhcbmjUkb9oEuBWanSxGtljTaI9KREh9CkjgyJen6DUgl0aLk8jOxlcG70k8HGawdchinVexPXhdpecysCvc6D8O2GbAyFm8qiGjKREh9CkjgyJen6DUgl0aLIAeTlginVexPXhdpecysCvc6D8O2GbAyVaNw0Ehf4KRXcT5LWjLOIqgKUr0WIBuGyNmbEYQEQtEZrSe(9rT52FoPYkbxXgCjTmInBi6pNuzLGRydUKwgH4a5az7ppR18HXNN1Xe8qcspqAEjUsJbMpmUgnd)UEAPaC01yHMrzTWqdo3aPBLwGtlyfOdKMxIR0yG5dJRHbAyZqanb2h1MRXcnJYAHHgCUbs3kTaNwWkqhinVexPXaZhgxdd0W2aEROeufUMCnwOrbImkRfgAW5giDR0cCAbRa1T5LWjLOIqgKUr0SGiB2qKrzTWqdo3aPBLwGtlyfOUrbOueUtRWhsJOrTBGsf(e0RfbWDAf(qAeD7HqehinVexPXaZhgxdd0WMhBWfDcvgk9nKujUgl0mkRfgAW5giDR0cCAbRaDG08sCLgdmFyCnmqdBR8Kwagp5no31yHMrzTWqdo3aPBLwGtlyfOUzuwlmHe61IajGsrPwKb9kSc0bsZlXvAmW8HX1WanSxbGy431DnwOzuwlm0GZnq6wPf40cgqiTO0ianSMBgL1ctiHETiqcOuuQfzqVcRaDG08sCLgdmFyCnmqdBgBlDRKac)ETRXcnJYAHHgCUbs3kTaNwWkqDBEjCsjQiKbPrVZnkmkRfgAW5giDR0cCAbdiKwuAeGA3IXPsW(J3tWjdiyQmgo1zZgIIXPsW(J3tWjdiyQmgo1DZOSwyObNBG0TslWPfmGqArPrGlqCGCGS9NxvSQBG(86O24eQCXaBKmp4etIRginVexPXAXQUb6ObeYdOjoP1PwrjeW1yHwmovcEZe4eiQTKwoas2S9x1vcbtojWcCAHnBGsrRdSryMqIAl5pEFG08sCLgRfR6gOdd0WEJB(W4jR70kp5ASqdXozc80(k2GlyGsrRdSryG1Uhi8KBu6eJYAHbw7EGWtyTy(9ia1Sz3jgL1cdS29aHNWacPfLgbSgehinVexPXAXQUb6WanSxGtljTaI9KRXcT)oE)AvyaH8aAItADQvucbWacPfLgbOzbvS57UfJtLG3mbobIAlPLdGCG08sCLgRfR6gOdd0WEboTK0ci2tUgl0(R6kHGjG1dVjrTLy4xl3mkRfMawp8Me1wIHFTWAX87rZcB2(R6kHGvkozA4upTau1Uo6MrzTWkfNmnCQNwaQAxhXacPfLgbUWnJYAHvkozA4upTau1UoIvGoqAEjUsJ1IvDd0HbAyd)AXJAlXWnT4ASqZOSwyqGKWkqhinVexPXAXQUb6WanSpgEieWeY1yHgImkRfEbU2LQeufUMWkqDlgNkbVax7svcQcxtSzZOSw49bNh1wcP5HhfHbK5f2S7KjWtw1tDYBoILWVpQn3(Zjvwj4k2GlPLrUzuwlCNmbUo1viSwm)EealSzdukclbskjxcwqa6nFFG08sCLgRfR6gOdd0WEboTK0ci2tUgl0aLk8jOxlcG70k8HGau2HAyigNkbduQWNmrOsXK4kuHlqCG08sCLgRfR6gOdd0W(y4HqatixJfAGsf(e0RfbWDAf(qAefwqnmeJtLGbkv4tMiuPysCfQWfioqAEjUsJ1IvDd0HbAyVaNwsAbe7PbsZlXvASwSQBGomqdB4hOs3k1kkHadKMxIR0yTyv3aDyGg2gWBfLKdaOsgihiB)5Bde1Es0dKMxIR0ybe1Es0OJs7bkIXWPu7uXkrbzQtodp5ASqZOSwyObNBG0TslWPfScu2SfdSrcwcKusUeuVKybHia1SzVIn4scqiTO0iGLDdKT)8TbNMxarTNK5Bfc85f408WJn4KwMN0sG0eQpVtJRqUoFRGZNNHMxrt95xbqlZBvFEOwaO(8Tcb(8WkbNBG5V18OQGtl4bsZlXvASaIApjAyGg2ciQ9KSZ1yHgIonqymCcRHs(yfupjGO2tIBgL1cdn4CdKUvAboTGvG6gfikgNkbhEYBqzZwmovco8K3G6MrzTWqdo3aPBLwGtlyaH0Is3i6Dier3Oarbe1EsWSGHB6K)oE)AvSzlGO2tcMfS)oE)AvyaH0IsZMTtdegdNWciQ9KKGcIdeIJO3HiB2ciQ9KG3HzuwRuxbysCvJOxXgCjbiKwu6bsZlXvASaIApjAyGg2ciQ9KWIRXcneDAGWy4ewdL8XkOEsarTNe3mkRfgAW5giDR0cCAbRa1nkqumovco8K3GYMTyCQeC4jVb1nJYAHHgCUbs3kTaNwWacPfLUr07qiIUrbIciQ9KG3HHB6K)oE)AvSzlGO2tcEh2FhVFTkmGqArPzZ2PbcJHtybe1EssqbXbcXr0SGiB2ciQ9KGzbZOSwPUcWK4QgrVIn4scqiTO0dKT)8O618xXDC(RO5VAEfnnVaIApjZdfCoJoPN3MNrzTCDEfnnVaNM)e4ey(RM3FhVFTk88W6G5J18ffcCcmVaIApjZdfCoJoPN3MNrzTCDEfnnpZjWN)Q593X7xRcpqAEjUsJfqu7jrdd0WwarTNKDUgl0quarTNe8omCtNu0uIrzTCJIaIApjywW(749RvHbeslknB2quarTNemly4MoPOPeJYAHiB2(749RvHHgCUbs3kTaNwWacPfLUrwq4aP5L4knwarTNenmqdBbe1EsyX1yHgIciQ9KGzbd30jfnLyuwl3OiGO2tcEh2FhVFTkmGqArPzZgIciQ9KG3HHB6KIMsmkRfISz7VJ3VwfgAW5giDR0cCAbdiKwu6gzbHzvnuYNBGfuVllzjNb]] )


end
