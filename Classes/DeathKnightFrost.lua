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


    spec:RegisterPack( "Frost DK", 20210629, [[d4u91cqiLQ6rsvvDjQGYMOs9jPsJcsCki0QqPGxbkmlQKUfkfQ2fu)cuQHbbDmLklds6zOuAAqGUgkvTniaFtQQOXbbKZrfuToQeMhOK7bP2NuvoivqSqqrpKkWeLQkuxeLI0grPi(OuvbJuQQqojkf1kbrVeLcLMjvI2PuHFcbudvQQslLki9us1uLk6QOuOWxrPqgRsv2RO(RidwvhMYIrXJPQjlLlJSzL8zLYObvNwy1OuOOxdcZgv3gI2TKFRYWbPJlvvXYbEojtN46KY2PI(UuLXJsLZtfA9svLMpkz)koVl3zwVzcL7aveI6oeIaq1HJ3Tdbric3L1fhHszDOMhcBJY6LHKY6SjGtjZ3pMn2SouZr(zTCNzD1Pb8uwhUiqvUa2WEle4Amy)He2QaPg3K4kpWwcSvbspSZ6mAbxyZvMjR3mHYDGkcrDhcraO6WX72Xwho7rWSUPjWpqwxpq6GSo8O1OkZK1BKYN17htMaFE2yRydUmpBc4uYajKAfnpQoCxNhveI6UbYbsha3QnsnqYgFEhkH8CsT55MsyJRi)vT51u2gn)TM3bWTOuZFR5zZEAEtnFiZ3osvDL5HYnhNVhX5Zh18qbMxcpHZ68qjQCNz9JHhcbmjUkb9oEuB5oZDSl3zwNkJHtTmmZ6MxIRY6ac5bueNuQuVOecK1BKYdcOsCvwV)EhpQT5ztoW8iWm8qiGjXvUyEDXaIA(DiCEf5VQPMNHwhGMV)gCUbM)wZZMaoLmV)qsQ5V1AEh0poR7bHqGWY6IXPsWBMaNarTLuYbqIPYy4uBEwSM3Fvtlem5KalWPemvgdNAZZI18aTIwhyJWmHe1wYF8gMkJHtT5zXAEZlHtkrfHmi189HEEuZsUduZDM1PYy4uldZSUhecbclRZOTwyqGKWAqZ6MxIRY6WVE8O2smCtjzj3bBZDM1PYy4uldZSU5L4QS(XWdHaMqzDpiecewwNrBTWqeCEuBjKMhEuegqMxY6Eh9CkjgyJevUJDzj3bcM7mRtLXWPwgMzDpiecewwxbL48KyGnsu4nU5dJNSMtR8089HEEuN398aTk8jOxpcGB0k8HmpSMhbGWSU5L4QS(g38HXtwZPvEkl5oyFUZSovgdNAzyM1nVexL1xGtjjLaciOSUhecbclRd0QWNGE9iaUrRWhY8WA((jcZ6Eh9CkjgyJevUJDzj3bci3zwNkJHtTmmZ6MxIRY6hdpecycL19GqiqyzDGwrZ3h65zBw37ONtjXaBKOYDSll5o6N5oZ6uzmCQLHzw3dcHaHL1nVeoPeveYGuZ3h65rW5DppkZV)8nYe4jRAPg5nhXs4HiQT5DpV)CsLvcUIn4sAz08Syn)(Z7pNuzLGRydUKwgnpIzDZlXvz9f4uIY7OaNYswY6(J3sWjdi5oZDSl3zwNkJHtTmmZ6MxIRY6E4wuQ0TsHNY6ns5bbujUkRZgdfnFtde12893GZnW89cb(8Szp5nOWgMaYe4zDpiecewwF)5fJtLGpgEieWK4kmvgdNAZ7EEgT1cdn4CdKUvAboLGbeslk18WAE2oV75z0wlm0GZnq6wPf4ucwd68UNNrBTW(J3sWjdiyLyEiMVp0ZVdHzj3bQ5oZ6uzmCQLHzw38sCvw3d3IsLUvk8uwVrkpiGkXvzDeynrfnA(BnF)n4CdmVMISnA(EHaFE2SN8guydtazc8SUhecbclRV)8IXPsWhdpecysCfMkJHtT5DpFJmbEcIk2GlyGwrRdSr4LX5uL8anL1iW8UNF)5z0wlm0GZnq6wPf4ucwd68UNhL5z0wlS)4TeCYacwjMhI57d987qaZ7EEgT1cRvWpUJjLaOAtGJ1GoplwZZOTwy)XBj4KbeSsmpeZ3h6535WN398(74TRxHHgCUbs3kTaNsWacPfLA((MFhcNhXSK7GT5oZ6uzmCQLHzw3dcHaHL13FEX4uj4JHhcbmjUctLXWP28UNF)5BKjWtquXgCbd0kADGncVmoNQKhOPSgbM398mARf2F8wcozabReZdX89HE(DiCE3ZV)8mARfgAW5giDR0cCkbRbDE3Z7VJ3UEfgAW5giDR0cCkbdiKwuQ57BEuryw38sCvw3d3IsLUvk8uwYDGG5oZ6uzmCQLHzw38sCvw3d3IsLUvk8uwVrkpiGkXvz9(lGCsLmVdoEB((rKbK5pNeWBqHg128nnquBZdn4CdK19GqiqyzDX4uj4JHhcbmjUctLXWP28UNF)5z0wlm0GZnq6wPf4ucwd68UNhL5z0wlS)4TeCYacwjMhI57d987qaZ7EEgT1cRvWpUJjLaOAtGJ1GoplwZZOTwy)XBj4KbeSsmpeZ3h6535WNNfR593XBxVcdn4CdKUvAboLGbeslk18WAE2oV75z0wlS)4TeCYacwjMhI57d987qW5rmlzjRFm8qiGjXv5oZDSl3zwNkJHtTmmZ6MxIRY6ac5bueNuQuVOecK1BKYdcOsCvwhbMHhcbmjUAEWjMexL19GqiqyzDZlHtkrfHmi189HEE2oV75rzEX4uj4ntGtGO2sk5aiXuzmCQnplwZ7VQPfcMCsGf4ucMkJHtT5zXAEGwrRdSryMqIAl5pEdtLXWP28iMLChOM7mRtLXWPwgMzDZlXvzD4xpEuBjgUPKSUhecbclRV)8TtWlWPK0ICsaSeEiIABE3ZV)8mARfgIGZJAlH08WJIWAqN398aTIMVp0ZZ2SU3rpNsIb2irL7yxwYDW2CNzDQmgo1YWmR7bHqGWY6mARfgIGZJAlH08WJIWaY8Y8UNxbL48KyGnsu4f4uIY7OaNMVp0ZJ68UNhL5z0wlCJmbUk10iSsmpeZJEEeCEwSMF)5BKjWtw1snYBoILWdruBZZI187pV)CsLvcUIn4sAz08iM1nVexL1xGtjkVJcCkl5oqWCNzDQmgo1YWmRBEjUkRFm8qiGjuw3dcHaHL1z0wlmebNh1wcP5HhfHbK5L5zXA(9NNrBTWGajH1GoV75vqjopjgyJefg(1Jh1wIHBkz((qppBZ6Eh9CkjgyJevUJDzj3b7ZDM1PYy4uldZSUhecbclRRGsCEsmWgjk8g38HXtwZPvEA((qppQZ7EEuMhOvHpb96raCJwHpK5H187q48SynpqRiSeiPKCjuNVV538T5rCEwSMhL5BeJ2AHbw)EGWtyLyEiMhwZZ(5zXA(gXOTwyG1Vhi8egqiTOuZdR53X(5rmRBEjUkRVXnFy8K1CALNYsUdeqUZSovgdNAzyM19GqiqyzDZlHtkrfHmi18ONF38UNhL59x10cbtaRfEtIAlXWVEyQmgo1M398mARfMawl8Me1wIHF9WkX8qmp65rDEwSM3FvtleSwXjtbNAPfGQ(1rmvgdNAZ7EEgT1cRvCYuWPwAbOQFDediKwuQ5H18B(28iM1nVexL1xGtjjLaciOSK7OFM7mRtLXWPwgMzDpiecewwNrBTWGajH1GoV75vqjopjgyJefg(1Jh1wIHBkz((qppQzDZlXvzD4xpEuBjgUPKSK7abk3zwNkJHtTmmZ6EqieiSSUckX5jXaBKOWBCZhgpznNw5P57d98OM1nVexL134MpmEYAoTYtzj3Hdp3zwNkJHtTmmZ6MxIRY6lWPKKsabeuw3dcHaHL13FEX4ujyZPXTYdNWuzmCQnV753FEgT1cdrW5rTLqAE4rrynOZZI18IXPsWMtJBLhoHPYy4uBE3ZV)8mARfgeijSg05zXAEgT1cdcKewd68UNhOvewcKusUeQZ3h6538TSU3rpNsIb2irL7yxwYDSdH5oZ6uzmCQLHzw3dcHaHL1z0wlmiqsynOzDZlXvzD4xpEuBjgUPKSK7y3UCNzDQmgo1YWmRBEjUkRFm8qiGjuw37ONtjXaBKOYDSllzjRReRAgOL7m3XUCNzDQmgo1YWmRBEjUkRdiKhqrCsPs9IsiqwVrkpiGkXvzDDXQMbAZRIAJtSXfdSrY8GtmjUkR7bHqGWY6IXPsWBMaNarTLuYbqIPYy4uBEwSM3Fvtlem5KalWPemvgdNAZZI18aTIwhyJWmHe1wYF8gMkJHtTSK7a1CNzDQmgo1YWmR7bHqGWY67pFJmbEcIk2GlyGwrRdSryG1Vhi808UNhL5BeJ2AHbw)EGWtyLyEiMhwZZ(5zXA(gXOTwyG1Vhi8egqiTOuZdR57NZJyw38sCvwFJB(W4jR50kpLLChSn3zwNkJHtTmmZ6EqieiSSU)oE76vyaH8akItkvQxucbWacPfLAEyHEEuNNnm)MVnV75fJtLG3mbobIAlPKdGetLXWPww38sCvwFboLKuciGGYsUdem3zwNkJHtTmmZ6EqieiSSU)QMwiycyTWBsuBjg(1BE3ZZOTwycyTWBsuBjg(1dReZdX8ONh15zXAE)vnTqWAfNmfCQLwaQ6xhXuzmCQnV75z0wlSwXjtbNAPfGQ(1rmGqArPMhwZZ2SU5L4QS(cCkjPeqabLLChSp3zwNkJHtTmmZ6EqieiSSoJ2AHbbscRbnRBEjUkRd)6XJAlXWnLKLChiGCNzDQmgo1YWmR7bHqGWY67ppJ2AHxGRFPkbvJRiSg05DpVyCQe8cC9lvjOACfHPYy4uBEwSMNrBTWqeCEuBjKMhEuegqMxMNfR5BKjWtw1snYBoILWdruBZ7EE)5KkReCfBWL0YO5DppJ2AHBKjWvPMgHvI5HyEynpcoplwZd0kclbskjxcbNhwONFZ3Y6MxIRY6hdpecycLLCh9ZCNzDQmgo1YWmR7bHqGWY6aTk8jOxpcGB0k8HmpSMhL53X(5HX8IXPsWaTk8jteQ0mjUctLXWP28SH5z78iM1nVexL1xGtjjLaciOSK7abk3zwNkJHtTmmZ6EqieiSSoqRcFc61Ja4gTcFiZ338OmpQSFEymVyCQemqRcFYeHkntIRWuzmCQnpByE2opIzDZlXvz9JHhcbmHYsUdhEUZSU5L4QS(cCkjPeqabL1PYy4uldZSK7yhcZDM1nVexL1HFGkDRuVOecK1PYy4uldZSK7y3UCNzDZlXvzDd4TIsYbaujzDQmgo1YWmlzjRBhL7m3XUCNzDQmgo1YWmR3iLheqL4QSUd5ytN3HEIjXvzDZlXvzDaH8akItkvQxucbYsUduZDM1PYy4uldZSUhecbclRlgNkbVaNsuEhf4eMkJHtTSU5L4QS(g38HXtwZPvEkl5oyBUZSovgdNAzyM1nVexL1xGtjjLaciOSUhecbclR7VJ3UEfgqipGI4KsL6fLqamGqArPMhwONh15zdZV5BZ7EEX4uj4ntGtGO2sk5aiXuzmCQL19o65usmWgjQCh7YsUdem3zwNkJHtTmmZ6EqieiSSoJ2AHbbscRbnRBEjUkRd)6XJAlXWnLKLChSp3zwNkJHtTmmZ6EqieiSSEJmbEYQwQrEZrSeEiIABE3Z7pNuzLGRydUKwgnV75z0wlCJmbUk10iSsmpeZdR5rWSU5L4QS(XWdHaMqzj3bci3zwNkJHtTmmZ6EqieiSSoJ2AHHi48O2sinp8OimGmVmV75rz(9NVrMapzvl1iV5iwcperTnV759NtQSsWvSbxslJMNfR53FE)5KkReCfBWL0YO5rmRBEjUkRVaNsuEhf4uwYD0pZDM1PYy4uldZSUhecbclRd0QWNGE9iaUrRWhY8WAEuMFh7NhgZlgNkbd0QWNmrOsZK4kmvgdNAZZgMNTZJyw38sCvwFJB(W4jR50kpLLChiq5oZ6uzmCQLHzw38sCvwFboLKuciGGY6EqieiSSoqRcFc61Ja4gTcFiZdR5rz(DSFEymVyCQemqRcFYeHkntIRWuzmCQnpByE2opIzDVJEoLedSrIk3XUSK7WHN7mRtLXWPwgMzDpiecewwF)5BKjWtw1snYBoILWdruBZ7EE)5KkReCfBWL0YO5zXA(9N3FoPYkbxXgCjTmkRBEjUkRVaNsuEhf4uwYDSdH5oZ6uzmCQLHzw38sCvw)y4HqatOSUhecbclRd0QWNGE9iaUrRWhY89npkZJk7NhgZlgNkbd0QWNmrOsZK4kmvgdNAZZgMNTZJyw37ONtjXaBKOYDSll5o2Tl3zw38sCvwFJB(W4jR50kpL1PYy4uldZSK7yhQ5oZ6uzmCQLHzw38sCvwFboLKuciGGY6Eh9CkjgyJevUJDzj3Xo2M7mRBEjUkRd)av6wPErjeiRtLXWPwgMzj3Xoem3zw38sCvw3aEROKCaavswNkJHtTmmZswY6(ZjvwjQCN5o2L7mRtLXWPwgMzDZlXvz9gzcCvQPrz9gP8GaQexL1DW5KkRK5DimbpKGuzDpieceww3PbcJHtyLKGYTQIABEwSM3PbcJHtyR1ujaH0Ikl5oqn3zwNkJHtTmmZ6EqieiSSoqRcFc61Ja4gTcFiZ338SDE3Z7VJ3UEfgAW5giDR0cCkbdiKwuQ5H18SDE3ZV)8IXPsWmaYe4PBLur1a22PmmvgdNAZ7EENgimgoHvsck3QkQTSU5L4QSUQNbqg1wczOKSK7GT5oZ6uzmCQLHzw3dcHaHL13FEX4ujygazc80TsQOAaB7ugMkJHtT5DpVtdegdNWwRPsacPfvw38sCvwx1ZaiJAlHmuswYDGG5oZ6uzmCQLHzw3dcHaHL1fJtLGzaKjWt3kPIQbSTtzyQmgo1M398OmpJ2AHzaKjWt3kPIQbSTtzynOZ7EEuM3PbcJHtyLKGYTQIABE3Zd0QWNGE9iaUrRWhY89npcIW5zXAENgimgoHTwtLaeslQ5DppqRcFc61Ja4gTcFiZ338iaeoplwZ70aHXWjS1AQeGqArnV75bw0sKtQeS1AkmGqArPMhwZ7WNhX5zXA(9NNrBTWmaYe4PBLur1a22PmSg05DpV)oE76vygazc80TsQOAaB7uggqiTOuZJyw38sCvwx1ZaiJAlHmuswYDW(CNzDQmgo1YWmR7bHqGWY6(74TRxHHgCUbs3kTaNsWacPfLAEynpBN398onqymCcRKeuUvvuBZ7EEuMxmovcMbqMapDRKkQgW2oLHPYy4uBE3Zd0QWNGE9iaUrRWhY8WAEeacN398(74TRxHzaKjWt3kPIQbSTtzyaH0IsnpSMh15zXA(9NxmovcMbqMapDRKkQgW2oLHPYy4uBEeZ6MxIRY6gZHmktIRs8ajtwYDGaYDM1PYy4uldZSUhecbclR70aHXWjS1AQeGqArL1nVexL1nMdzuMexL4bsMSK7OFM7mRtLXWPwgMzDpieceww3FhVD9km0GZnq6wPf4ucgqiTOuZdR5z78UN3PbcJHtyLKGYTQIAlRBEjUkRRGBEi4usGtjTQ3be4oMLChiq5oZ6uzmCQLHzw3dcHaHL1DAGWy4e2AnvcqiTOY6MxIRY6k4MhcoLe4usR6DabUJzj3Hdp3zwNkJHtTmmZ6EqieiSSU604mr1Wq1uIgNseqdQexHPYy4uBE3ZV)8mARfgAW5giDR0cCkbRbnRBEjUkRV4KcUhyljlzjRdmFyCvUZCh7YDM1PYy4uldZSU5L4QSod)UwAPbCmR3iLheqL4QSUd18HXN3HWe8qcsL19GqiqyzDgT1cdn4CdKUvAboLG1GMLChOM7mRtLXWPwgMzDpiecewwNrBTWqdo3aPBLwGtjynOzDZlXvzDgcOiaerTLLChSn3zwNkJHtTmmZ6EqieiSSokZV)8mARfgAW5giDR0cCkbRbDE3ZBEjCsjQiKbPMVp0ZJ68ioplwZV)8mARfgAW5giDR0cCkbRbDE3ZJY8aTIWnAf(qMVp0ZZ(5DppqRcFc61Ja4gTcFiZ3h65raiCEeZ6MxIRY6gWBfLGQXvuwYDGG5oZ6uzmCQLHzw3dcHaHL1z0wlm0GZnq6wPf4ucwdAw38sCvwNhBWfvInMATnKujzj3b7ZDM1PYy4uldZSUhecbclRZOTwyObNBG0TslWPeSg05DppJ2AHjKqVEeib0kk1JmOxH1GM1nVexL1TYtkby8K348SK7abK7mRtLXWPwgMzDpiecewwNrBTWqdo3aPBLwGtjyaH0IsnpSqppc08UNNrBTWesOxpcKaAfL6rg0RWAqZ6MxIRY6Raqm87Azj3r)m3zwNkJHtTmmZ6EqieiSSoJ2AHHgCUbs3kTaNsWAqN398MxcNuIkczqQ5rp)U5DppkZZOTwyObNBG0TslWPemGqArPMhwZZ(5DpVyCQeS)4TeCYacMkJHtT5zXA(9Nxmovc2F8wcozabtLXWP28UNNrBTWqdo3aPBLwGtjyaH0IsnpSMNTZJyw38sCvwNX2s3kjGWdHklzjRZCQe074rTL7m3XUCNzDQmgo1YWmRBEjUkRd)6XJAlXWnLK1BKYdcOsCvwhMaYe4ZFR51JQbSTtzZd9oEuBZdoXK4Q5DX8kXaIA(DiunpdToanpmp95d18Mtl4gdNY6EqieiSSoJ2AHbbscRbnl5oqn3zwNkJHtTmmZ6EqieiSSU5LWjLOIqgKA((qppQZZI18aTIWsGKsYLy)8Wc98B(28UNhL5fJtLG3mbobIAlPKdGetLXWP28SynV)QMwiyYjbwGtjyQmgo1MNfR5bAfToWgHzcjQTK)4nmvgdNAZJyw38sCvwhqipGI4KsL6fLqGSK7GT5oZ6uzmCQLHzw38sCvw)y4HqatOSU3rpNsIb2irL7yxw3dcHaHL1bAv4tqVEea3Ov4dz((qppQSpR3iLheqL4QSExXaBKKIfAKg7CbknIrBTWaRFpq4jSsmpeWyhIomuAeJ2AHbw)EGWtyaH0IsbJDiYgAKjWtquXgCbd0kADGncdS(9aHN6oVdLGsMOM3MNFIRZlWd18HA(OeQAuBE5MxmWgjZlWP5HhBWjLmpuqCGqCCEQiKooFVqGpVvZBmbpehNxGBY89coFEdkuUJZdS(9aHNMpwZd0kADGnQHNVt4Mmpdf128wnpveshNVxiWNhHZReZdHY15pW8wnpveshNxGBY8cCA(gXOTwZ3l485v3vZtSdAaO5VcNLChiyUZSovgdNAzyM19GqiqyzDGwf(e0RhbWnAf(qMhwZJkcN398kOeNNedSrIcVXnFy8K1CALNMVp0ZJ68UN3FhVD9km0GZnq6wPf4ucgqiTOuZ338SpRBEjUkRVXnFy8K1CALNYsUd2N7mRtLXWPwgMzDZlXvz9f4ussjGackR7bHqGWY6aTk8jOxpcGB0k8HmpSMhveoV7593XBxVcdn4CdKUvAboLGbeslk189np7Z6Eh9CkjgyJevUJDzj3bci3zwNkJHtTmmZ6EqieiSSoJ2AHHi48O2sinp8OimGmVmV75bAv4tqVEea3Ov4dz((MhL53X(5HX8IXPsWaTk8jteQ0mjUctLXWP28SH5z78ioV75vqjopjgyJefEboLO8okWP57d98OoV75rzEgT1c3itGRsnncReZdX8ONhbNNfR53F(gzc8KvTuJ8MJyj8qe128Syn)(Z7pNuzLGRydUKwgnpIzDZlXvz9f4uIY7OaNYsUJ(zUZSovgdNAzyM19GqiqyzDGwf(e0RhbWnAf(qMVp0ZJY8SL9ZdJ5fJtLGbAv4tMiuPzsCfMkJHtT5zdZZ25rCE3ZRGsCEsmWgjk8cCkr5DuGtZ3h65rDE3ZJY8mARfUrMaxLAAewjMhI5rppcoplwZV)8nYe4jRAPg5nhXs4HiQT5zXA(9N3FoPYkbxXgCjTmAEeZ6MxIRY6lWPeL3rboLLChiq5oZ6uzmCQLHzw3dcHaHL193XBxVcdn4CdKUvAboLGbeslk189npqRiSeiPKCjeCE3Zd0QWNGE9iaUrRWhY8WAEeeHZ7EEfuIZtIb2irH34MpmEYAoTYtZ3h65rnRBEjUkRVXnFy8K1CALNYsUdhEUZSovgdNAzyM1nVexL1xGtjjLaciOSUhecbclR7VJ3UEfgAW5giDR0cCkbdiKwuQ57BEGwryjqsj5si48UNhOvHpb96raCJwHpK5H18iicZ6Eh9CkjgyJevUJDzjlzDOaYFizmj3zUJD5oZ6uzmCQLHzw)GM1vKeRSUhecbclRlGOGGeSSdd3ujnfLy0wR5DppkZV)8IXPsWmaYe4PBLur1a22PmmvgdNAZ7EEuMxarbbjyzh2FhVD9kCtdysC18oS593XBxVcdn4CdKUvAboLGBAatIRMh98iCEeNNfR5fJtLGzaKjWt3kPIQbSTtzyQmgo1M398OmV)oE76vygazc80TsQOAaB7ugUPbmjUAEh28cikiibl7W(74TRxHBAatIRMh98iCEeNNfR5fJtLGdp5nOyQmgo1MhXSEJuEqavIRY6SPonUMjKAEBEbefeKOM3FhVD9kxNVfoJg1MNXX5HgCUbM)wZVaNsM)aZZaitGp)TMxfvdyBNY6QM3FhVD9k88S518H0vnVtJRrZd3uZx38acPfvJaZdirduZVZ15jUIMhqIgOMhHy2JZ6onqQmKuwxarbbjPDjLJLpRBEjUkR70aHXWPSUtJRrjIROSocXSpR704AuwFxwYDGAUZSovgdNAzyM1pOzDfjXkRBEjUkR70aHXWPSUtdKkdjL1fquqqsc1KYXYN19GqiqyzDbefeKGfuXWnvstrjgT1AE3ZJY87pVyCQemdGmbE6wjvunGTDkdtLXWP28UNhL5fquqqcwqf7VJ3UEfUPbmjUAEh28(74TRxHHgCUbs3kTaNsWnnGjXvZJEEeopIZZI18IXPsWmaYe4PBLur1a22PmmvgdNAZ7EEuM3FhVD9kmdGmbE6wjvunGTDkd30aMexnVdBEbefeKGfuX(74TRxHBAatIRMh98iCEeNNfR5fJtLGdp5nOyQmgo1MhXSUtJRrjIROSocXSpR704AuwFxwYDW2CNzDQmgo1YWmRFqZ6ksIvw3dcHaHL13FEbefeKGLDy4MkPPOeJ2AnV75fquqqcwqfd3ujnfLy0wR5zXAEbefeKGfuXWnvstrjgT1AE3ZJY8OmVaIccsWcQy)D821RWnnGjXvZd75fquqqcwqfZOTwPMgWK4Q5rCE2W8Om)om7NhgZlGOGGeSGkgUPsmARfwjaQ2e4ZJ48SH5rzENgimgoHfquqqsc1KYXYppIZJ489npkZJY8cikiibl7W(74TRxHBAatIRMh2ZlGOGGeSSdZOTwPMgWK4Q5rCE2W8Om)om7NhgZlGOGGeSSdd3ujgT1cReavBc85rCE2W8OmVtdegdNWcikiijTlPCS8ZJ48iM1BKYdcOsCvwNnvjbsti1828cikiirnVtJRrZZ448(djude128cCAE)D821RM)wZlWP5fquqqIRZ3cNrJAZZ448cCA(MgWK4Q5V18cCAEgT1A(qMhk4CgnsHNVFKPM3MxjaQ2e4ZJ8AXkiW8Yn)w4KM3MhESbNaZdfehiehNxU5vcGQnb(8cikiir568MA(EeNpVPM3Mh51IvqG5xhy(ynVnVaIccsMVxW5ZFG57fC(81jZRCS8Z3le4Z7VJ3UELcN1DAGuziPSUaIccssqbXbcXXSU5L4QSUtdegdNY6onUgLiUIY67Y6onUgL1rnl5oqWCNzDZlXvz9fNuW9aBjzDQmgo1YWmlzjR7VJ3UELk3zUJD5oZ6uzmCQLHzw3dcHaHL1z0wlm0GZnq6wPf4ucwdAwVrkpiGkXvz9(7jXvzDZlXvzDONexLLChOM7mRtLXWPwgMzDZlXvzDcj0RhbsaTIs9id6vz9gP8GaQexL1DWD821RuzDpiecewwxmovc(y4HqatIRWuzmCQnV75bAfnpSMhbmV75rzENgimgoHvsck3QkQT5zXAENgimgoHTwtLaeslQ5rCE3ZJY8(74TRxHHgCUbs3kTaNsWacPfLAEynp7NNfR5z0wlm0GZnq6wPf4ucwd68ioplwZVIn4scqiTOuZdR5rfHzj3bBZDM1PYy4uldZSUhecbclRlgNkbZaitGNUvsfvdyBNYWuzmCQnV75bAv4tqVEea3Ov4dz((MNTiCE3Zd0kclbskjxI9Z338B(28UNhL5z0wlmdGmbE6wjvunGTDkdRbDEwSMFfBWLeGqArPMhwZJkcNhXSU5L4QSoHe61JajGwrPEKb9QSK7abZDM1PYy4uldZSUhecbclRlgNkbhEYBqXuzmCQnV75bAfnpSMNTzDZlXvzDcj0RhbsaTIs9id6vzj3b7ZDM1PYy4uldZSUhecbclRlgNkbZaitGNUvsfvdyBNYWuzmCQnV75rzENgimgoHvsck3QkQT5zXAENgimgoHTwtLaeslQ5rCE3ZJY8(74TRxHzaKjWt3kPIQbSTtzyaH0IsnplwZ7VJ3UEfMbqMapDRKkQgW2oLHbK1CCE3Zd0QWNGE9iaUrRWhY8WAE2JW5rmRBEjUkRdn4CdKUvAboLKLChiGCNzDQmgo1YWmR7bHqGWY6IXPsWHN8gumvgdNAZ7E(9NNrBTWqdo3aPBLwGtjynOzDZlXvzDObNBG0TslWPKSK7OFM7mRtLXWPwgMzDpiecewwxmovc(y4HqatIRWuzmCQnV75rzENgimgoHvsck3QkQT5zXAENgimgoHTwtLaeslQ5rCE3ZJY8IXPsWBMaNarTLuYbqIPYy4uBE3ZZOTwyaH8akItkvQxucbWAqNNfR53FEX4uj4ntGtGO2sk5aiXuzmCQnpIzDZlXvzDObNBG0TslWPKSK7abk3zwNkJHtTmmZ6EqieiSSoJ2AHHgCUbs3kTaNsWAqZ6MxIRY6maYe4PBLur1a22PSSK7WHN7mRtLXWPwgMzDpieceww38s4Ksuridsnp653nV75z0wlm0GZnq6wPf4ucgqiTOuZdR538T5DppJ2AHHgCUbs3kTaNsWAqN3987pVyCQe8XWdHaMexHPYy4uBE3ZJY87ppWIwICsLGTwtHj2fkrnplwZdSOLiNujyR1u4OMVV5zlcNhX5zXA(vSbxsacPfLAEynpBZ6MxIRY6lWPKEocqQslnGJzj3XoeM7mRtLXWPwgMzDpieceww38s4KsuridsnFFONh15DppkZZOTwyObNBG0TslWPeSg05zXAEGfTe5KkbBTMch189nV)oE76vyObNBG0TslWPemGqArPMhX5DppkZZOTwyObNBG0TslWPemGqArPMhwZV5BZZI18alAjYjvc2AnfgqiTOuZdR538T5rmRBEjUkRVaNs65iaPkT0aoMLCh72L7mRtLXWPwgMzDpiecewwxmovc(y4HqatIRWuzmCQnV75z0wlm0GZnq6wPf4ucwd68UNhL5rzEgT1cdn4CdKUvAboLGbeslk18WA(nFBEwSMNrBTWAf8J7ysjaQ2e4ynOZ7EEgT1cRvWpUJjLaOAtGJbeslk18WA(nFBEeN398OmFJy0wlmW63deEcReZdX8ONN9ZZI187pFJmbEcIk2GlyGwrRdSryG1Vhi808iopIzDZlXvz9f4usphbivPLgWXSK7yhQ5oZ6uzmCQLHzw3dcHaHL1fJtLGzaKjWt3kPIQbSTtzyQmgo1M398aTk8jOxpcGB0k8HmFFZJGiCE3Zd0kAEyHEE2oV75rzEgT1cZaitGNUvsfvdyBNYWAqNNfR593XBxVcZaitGNUvsfvdyBNYWacPfLA((Mhbr48ioplwZV)8IXPsWmaYe4PBLur1a22PmmvgdNAZ7EEGwf(e0RhbWnAf(qMVp0ZJk7Z6MxIRY6WDe6jWjaYWNGcifvEkl5o2X2CNzDQmgo1YWmR7bHqGWY6mARfgAW5giDR0cCkbRbnRBEjUkRdSqrPgzTSK7yhcM7mRtLXWPwgMzDpieceww38s4KsuridsnFFONh15DppkZZCk18UNFfBWLeGqArPMhwZZ25zXA(9NNrBTWmaYe4PBLur1a22PmSg05DppkZdLe8g8tJJbeslk18WA(nFBEwSMhyrlroPsWwRPWacPfLAEynpBN398alAjYjvc2AnfoQ57BEOKG3GFACmGqArPMhX5rmRBEjUkRRmpiwHpmEcQ5LSK7yh7ZDM1PYy4uldZSUhecbclRBEjCsjQiKbPMVV5z)8SynpqRO1b2imu4KboKxrkmvgdNAzDZlXvz9gzc8KvTuJ8MJzjlzDbefeKOYDM7yxUZSovgdNAzyM1nVexL1Js5bAIXWPu)rZkrdzQrodpL1BKYdcOsCvwVtquqqIkR7bHqGWY6mARfgAW5giDR0cCkbRbDEwSMxmWgjyjqsj5sq9scveopSMN9ZZI18mNsnV75xXgCjbiKwuQ5H18OUll5oqn3zwNkJHtTmmZ6MxIRY6cikiizxwVrkpiGkXvz9oHtZlGOGGK57fc85f408WJn4KsMNusG0eQnVtJRrUoFVGZNNHMxtrT5xbqjZBvBEOwaO289cb(893GZnW83AE2eWPeCw3dcHaHL13FENgimgoHvqjFScQLequqqY8UNNrBTWqdo3aPBLwGtjynOZ7EEuMF)5fJtLGdp5nOyQmgo1MNfR5fJtLGdp5nOyQmgo1M398mARfgAW5giDR0cCkbdiKwuQ57d987q48ioV75rz(9NxarbbjybvmCtL83XBxVAEwSMxarbbjybvS)oE76vyaH0IsnplwZ70aHXWjSaIccssqbXbcXX5rp)U5rCEwSMxarbbjyzhMrBTsnnGjXvZ3h65xXgCjbiKwuQSK7GT5oZ6uzmCQLHzw3dcHaHL13FENgimgoHvqjFScQLequqqY8UNNrBTWqdo3aPBLwGtjynOZ7EEuMF)5fJtLGdp5nOyQmgo1MNfR5fJtLGdp5nOyQmgo1M398mARfgAW5giDR0cCkbdiKwuQ57d987q48ioV75rz(9NxarbbjyzhgUPs(74TRxnplwZlGOGGeSSd7VJ3UEfgqiTOuZZI18onqymCclGOGGKeuqCGqCCE0ZJ68ioplwZlGOGGeSGkMrBTsnnGjXvZ3h65xXgCjbiKwuQSU5L4QSUaIccsqnl5oqWCNzDQmgo1YWmRBEjUkRlGOGGKDz9gP8GaQexL1zZR5VI748xrZF18AkAEbefeKmpuW5mAKAEBEgT1Y151u08cCA(tGtG5VAE)D821RWZJadMpwZxuiWjW8cikiizEOGZz0i1828mARLRZRPO5zob(8xnV)oE76v4SUhecbclRV)8cikiibl7WWnvstrjgT1AE3ZJY8cikiiblOI93XBxVcdiKwuQ5zXA(9NxarbbjybvmCtL0uuIrBTMhX5zXAE)D821RWqdo3aPBLwGtjyaH0IsnFFZJkcZsUd2N7mRtLXWPwgMzDpiecewwF)5fquqqcwqfd3ujnfLy0wR5DppkZlGOGGeSSd7VJ3UEfgqiTOuZZI187pVaIccsWYomCtL0uuIrBTMhX5zXAE)D821RWqdo3aPBLwGtjyaH0IsnFFZJkcZ6MxIRY6cikiib1SKLSEJwMgxYDM7yxUZSU5L4QSoYOAPfGO(LY6uzmCQLHzwYDGAUZSovgdNAzyM1pOzDfjzDZlXvzDNgimgoL1DACnkRJY8u)rlGcLA4OuEGMymCk1F0Ss0qMAKZWtZ7EE)D821RWrP8anXy4uQ)OzLOHm1iNHNWaYAoopIz9gP8GaQexL17VaYjvY8kOKpwb1MxarbbjQ5zOO2MxtrT57fc85nn5qAs4NNhfPY6onqQmKuwxbL8XkOwsarbbjzj3bBZDM1PYy4uldZS(bnRRijRBEjUkR70aHXWPSUtJRrzDZlHtkrfHmi18ONF38UNhL5bw0sKtQeS1AkCuZ3387y)8Syn)(ZdSOLiNujyR1uyIDHsuZJyw3PbsLHKY6kjbLBvf1wwYDGG5oZ6uzmCQLHzw)GM1vKK1nVexL1DAGWy4uw3PX1OSU5LWjLOIqgKA((qppQZ7EEuMF)5bw0sKtQeS1AkmXUqjQ5zXAEGfTe5KkbBTMctSluIAE3ZJY8alAjYjvc2AnfgqiTOuZ338SFEwSMFfBWLeGqArPMVV53HW5rCEeZ6onqQmKuw3AnvcqiTOYsUd2N7mRtLXWPwgMzDZlXvzDaH8akItkvQxucbY6ns5bbujUkR7qGcL748SjGtjZZMqojGRZJ0IsSOMNn7DC(on(vQ5TQnpeebDEhkH8akItk18SrrjeyEWX5rTL19GqiqyzD)vnTqWKtcSaNsM398IXPsWBMaNarTLuYbqIPYy4uBE3ZV)8IXPsWhdpecysCfMkJHtT5DpV)oE76vyObNBG0TslWPemGqArPYsUdeqUZSovgdNAzyM1nVexL1HF94rTLy4MsY6EqieiSSE7e8cCkjTiNeadOfGuWngonV75rzEX4uj4WtEdkMkJHtT5zXA(9NNrBTWmaYe4PBLur1a22PmSg05DpVyCQemdGmbE6wjvunGTDkdtLXWP28SynVyCQe8XWdHaMexHPYy4uBE3Z7VJ3UEfgAW5giDR0cCkbdiKwuQ5Dp)(ZZOTwyicopQTesZdpkcRbDEeZ6Eh9CkjgyJevUJDzj3r)m3zwNkJHtTmmZ6EqieiSSoJ2AHdVJjX4xPWacPfLAEyHE(nFBE3ZZOTw4W7ysm(vkSg05DpVckX5jXaBKOWBCZhgpznNw5P57d98OoV75rz(9NxmovcMbqMapDRKkQgW2oLHPYy4uBEwSM3FhVD9kmdGmbE6wjvunGTDkddiKwuQ57B(DSFEeZ6MxIRY6BCZhgpznNw5PSK7abk3zwNkJHtTmmZ6EqieiSSoJ2AHdVJjX4xPWacPfLAEyHE(nFBE3ZZOTw4W7ysm(vkSg05DppkZV)8IXPsWmaYe4PBLur1a22PmmvgdNAZZI18(74TRxHzaKjWt3kPIQbSTtzyaH0IsnFFZVJ9ZJyw38sCvwFboLKuciGGYsUdhEUZSovgdNAzyM1BKYdcOsCvw3bWVtrZ7q8sC188qjZl38aTkRBEjUkR7nopzEjUkXdLK15HssLHKY6(ZjvwjQSK7yhcZDM1PYy4uldZSU5L4QSU348K5L4QepuswNhkjvgskRdmFyCvwYDSBxUZSovgdNAzyM1nVexL19gNNmVexL4HsY68qjPYqszDbefeKOYsUJDOM7mRtLXWPwgMzDZlXvzDVX5jZlXvjEOKSopusQmKuw3FhVD9kvwYDSJT5oZ6uzmCQLHzw3dcHaHL1fJtLG9hVLGtgqWuzmCQnV75z0wlS)4TeCYacwjMhI57d987q48UNhL5BeJ2AHbw)EGWtyLyEiMh98SFEwSMF)5BKjWtquXgCbd0kADGncdS(9aHNMhX5zXAEMtPM398RydUKaeslk18Wc98B(ww38sCvw3BCEY8sCvIhkjRZdLKkdjL19hVLGtgqYsUJDiyUZSovgdNAzyM19GqiqyzDgT1cZaitGNUvsfvdyBNYWAqZ6MxIRY6aTkzEjUkXdLK15HssLHKY6mNkjHhIO2YsUJDSp3zwNkJHtTmmZ6EqieiSSUyCQemdGmbE6wjvunGTDkdtLXWP28UNhL593XBxVcZaitGNUvsfvdyBNYWacPfLAEyn)oeopIZ7EEuMhyrlroPsWwRPWrnFFZJk7NNfR53FEGfTe5KkbBTMctSluIAEwSM3FhVD9km0GZnq6wPf4ucgqiTOuZdR53HW5DppWIwICsLGTwtHj2fkrnV75bw0sKtQeS1AkCuZdR53HW5rmRBEjUkRd0QK5L4QepuswNhkjvgskRZCQe074rTLLCh7qa5oZ6uzmCQLHzw3dcHaHL1z0wlm0GZnq6wPf4ucwd68UNxmovc(y4HqatIRWuzmCQL1nVexL1bAvY8sCvIhkjRZdLKkdjL1pgEieWK4QSK7yx)m3zwNkJHtTmmZ6EqieiSSUyCQe8XWdHaMexHPYy4uBE3Z7VJ3UEfgAW5giDR0cCkbdiKwuQ5H187q48UNhL5DAGWy4ewjjOCRQO2MNfR5bw0sKtQeS1AkmXUqjQ5DppWIwICsLGTwtHJAEyn)oeoplwZV)8alAjYjvc2AnfMyxOe18iM1nVexL1bAvY8sCvIhkjRZdLKkdjL1pgEieWK4Qe074rTLLCh7qGYDM1PYy4uldZSUhecbclRBEjCsjQiKbPMVp0ZJAw38sCvwhOvjZlXvjEOKSopusQmKuw3okl5o25WZDM1PYy4uldZSU5L4QSU348K5L4QepuswNhkjvgskRReRAgOLLSK1zovscperTL7m3XUCNzDQmgo1YWmRBEjUkRFm8qiGjuw37ONtjXaBKOYDSlR7bHqGWY6aTk8jOxpcGB0k8HmFFONhbGWSEJuEqavIRY6WeqMaF(BnVEunGTDkBEhIxcN08o0tmjUkl5oqn3zwNkJHtTmmZ6EqieiSSUyCQe8MjWjquBjLCaKyQmgo1MNfR59x10cbtojWcCkbtLXWP28SynpqRO1b2imtirTL8hVHPYy4uBEwSM38s4KsuridsnFFONh15zXA(9NxmovcEZe4eiQTKsoasmvgdNAZ7E(9N3Fvtlem5KalWPemvgdNAZ7E(9NhOv06aBeMjKO2s(J3WuzmCQnV75bAv4tqVEeyEynpBrnRBEjUkRdiKhqrCsPs9IsiqwYDW2CNzDQmgo1YWmR7bHqGWY6aTk8jOxpcmpSMNTOM1nVexL1BKjWtw1snYBoMLChiyUZSovgdNAzyM19GqiqyzDgT1cdcKewd68UNhL5bAv4tqVEea3Ov4dzEynp7z)8SynpqRiSeiPKCj2opSqp)MVnplwZRGsCEsmWgjkm8RhpQTed3uY89HEEuNhX5zXAEGwf(e0RhbMhwZZwuZ6MxIRY6WVE8O2smCtjzj3b7ZDM1PYy4uldZSUhecbclRZOTwyicopQTesZdpkcRbDE3ZRGsCEsmWgjk8cCkr5DuGtZ3h65rDE3ZJY87pFJmbEYQwQrEZrSeEiIABE3Z7pNuzLGRydUKwgnplwZV)8(Zjvwj4k2GlPLrZJyw38sCvwFboLO8okWPSK7abK7mRtLXWPwgMzDpiecewwhOvHpb96raCJwHpK57d98iicN398aTIWsGKsYLy789n)MVL1nVexL1HFGkDRuVOecKLCh9ZCNzDQmgo1YWmR7bHqGWY6kOeNNedSrIcVaNsuEhf4089HEEuN398OmpJ2AHBKjWvPMgHvI5HyE0ZJGZZI187pFJmbEYQwQrEZrSeEiIABEwSMF)59NtQSsWvSbxslJMhXSU5L4QS(cCkr5DuGtzj3bcuUZSovgdNAzyM1nVexL1pgEieWekR7bHqGWY6aTk8jOxpcGB0k8HmFFZJk7NNfR5bAfHLajLKlX25H18B(ww37ONtjXaBKOYDSll5oC45oZ6uzmCQLHzw3dcHaHL1z0wlmiqsynOzDZlXvzD4xpEuBjgUPKSK7yhcZDM1PYy4uldZSUhecbclRd0QWNGE9iaUrRWhY89np7ryw38sCvw3aEROKCaavswYswY6ojGkUk3bQie1DiebGkcuwVNbQO2uzD2ihIdTd2Ch9dUy(57eonFGe6bK5xhy(UhdpecysCvc6D8O26opG6pAbGAZRoK08MMCinHAZ7HB1gPWdKUmkA(DUyEhCLtciuB(UIXPsW71DE5MVRyCQe8EyQmgo16opk7yhI4bsxgfn)oxmVdUYjbeQnFxGwrRdSr496oVCZ3fOv06aBeEpmvgdNADNhLDSdr8aPlJIMFNlM3bx5Kac1MVR)QMwi496oVCZ31Fvtle8EyQmgo16opk7yhI4bYbs2ihIdTd2Ch9dUy(57eonFGe6bK5xhy(U(J3sWjdiDNhq9hTaqT5vhsAEttoKMqT59WTAJu4bsxgfn)oxmVdUYjbeQnFxX4uj496oVCZ3vmovcEpmvgdNADNhLDSdr8aPlJIMhvxmVdUYjbeQnFxX4uj496oVCZ3vmovcEpmvgdNADNhLDSdr8aPlJIMNTUyEhCLtciuB(UIXPsW71DE5MVRyCQe8EyQmgo16opk7yhI4bsxgfnpc6I5DWvojGqT57kgNkbVx35LB(UIXPsW7HPYy4uR78OSJDiIhihizJCio0oyZD0p4I5NVt408bsOhqMFDG57Em8qiGjXvDNhq9hTaqT5vhsAEttoKMqT59WTAJu4bsxgfn)oxmVdUYjbeQnFxX4uj496oVCZ3vmovcEpmvgdNADNhLDSdr8aPlJIMFNlM3bx5Kac1MVlqRO1b2i8EDNxU57c0kADGncVhMkJHtTUZJYo2HiEG0LrrZVZfZ7GRCsaHAZ31Fvtle8EDNxU576VQPfcEpmvgdNADNhLDSdr8aPlJIMhb4I5DWvojGqT576VQPfcEVUZl38D9x10cbVhMkJHtTUZJcQSdr8aPlJIM3H7I5DWvojGqT57kgNkbVx35LB(UIXPsW7HPYy4uR78OGk7qepqoqYg5qCODWM7OFWfZpFNWP5dKqpGm)6aZ3L5ujj8qe1w35bu)rlauBE1HKM30KdPjuBEpCR2ifEG0LrrZJQlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZJcQSdr8aPlJIMhvxmVdUYjbeQnFxGwrRdSr496oVCZ3fOv06aBeEpmvgdNADNhfuzhI4bsxgfnpQUyEhCLtciuB(U(RAAHG3R78YnFx)vnTqW7HPYy4uR78OGk7qepqoqYg5qCODWM7OFWfZpFNWP5dKqpGm)6aZ31FoPYkr1DEa1F0ca1MxDiP5nn5qAc1M3d3QnsHhiDzu08O6I5DWvojGqT57kgNkbVx35LB(UIXPsW7HPYy4uR78OSJDiIhiDzu08S1fZ7GRCsaHAZ3vmovcEVUZl38DfJtLG3dtLXWPw35rzh7qepq6YOO5rqxmVdUYjbeQnFxX4uj496oVCZ3vmovcEpmvgdNADNhLDSdr8aPlJIMN9UyEhCLtciuB(UIXPsW71DE5MVRyCQe8EyQmgo16opkOYoeXdKUmkAEhUlM3bx5Kac1MVR604mr1W71DE5MVR604mr1W7HPYy4uR78OSJDiIhihizJCio0oyZD0p4I5NVt408bsOhqMFDG57QeRAgO1DEa1F0ca1MxDiP5nn5qAc1M3d3QnsHhiDzu087CX8o4kNeqO28DfJtLG3R78YnFxX4uj49WuzmCQ1DEu2XoeXdKUmkA(DUyEhCLtciuB(UaTIwhyJW71DE5MVlqRO1b2i8EyQmgo16oVjZZMIa7Y5rzh7qepq6YOO535I5DWvojGqT576VQPfcEVUZl38D9x10cbVhMkJHtTUZJYo2HiEG0LrrZZwxmVdUYjbeQnFxX4uj496oVCZ3vmovcEpmvgdNADN3K5ztrGD58OSJDiIhiDzu08iOlM3bx5Kac1MVR)QMwi496oVCZ31Fvtle8EyQmgo16opk7yhI4bsxgfnpcWfZ7GRCsaHAZ3vmovcEVUZl38DfJtLG3dtLXWPw35rzh7qepq6YOO57NUyEhCLtciuB(UIXPsW71DE5MVRyCQe8EyQmgo16opk7yhI4bsxgfnpcKlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZJYo2HiEGCGKnYH4q7Gn3r)GlMF(oHtZhiHEaz(1bMVlZPsqVJh1w35bu)rlauBE1HKM30KdPjuBEpCR2ifEG0LrrZJQlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZJYo2HiEG0LrrZJQlM3bx5Kac1MVlqRO1b2i8EDNxU57c0kADGncVhMkJHtTUZJYo2HiEG0LrrZJQlM3bx5Kac1MVR)QMwi496oVCZ31Fvtle8EyQmgo16opk7yhI4bsxgfnpcWfZ7GRCsaHAZ3vmovcEVUZl38DfJtLG3dtLXWPw35rzh7qepq6YOO57NUyEhCLtciuB(UIXPsW71DE5MVRyCQe8EyQmgo16opk7yhI4bYbs2ihIdTd2Ch9dUy(57eonFGe6bK5xhy(UqbK)qYys35bu)rlauBE1HKM30KdPjuBEpCR2ifEG0LrrZVZfZ7GRCsaHAZRhiDW8khlXy38omh28YnVl1S5rEnnUMA(dkbm5aZJIddX5rbv2HiEG0LrrZVZfZ7GRCsaHAZ3vmovcEVUZl38DfJtLG3dtLXWPw35rHTSdr8aPlJIMFNlM3bx5Kac1MVRaIccsW7W71DE5MVRaIccsWYo8EDNhf2YoeXdKUmkAEuDX8o4kNeqO286bshmVYXsm2nVdZHnVCZ7snBEKxtJRPM)GsatoW8O4WqCEuqLDiIhiDzu08O6I5DWvojGqT57kgNkbVx35LB(UIXPsW7HPYy4uR78OWw2HiEG0LrrZJQlM3bx5Kac1MVRaIccsWOI3R78YnFxbefeKGfuX71DEuyl7qepq6YOO5zRlM3bx5Kac1Mxpq6G5vowIXU5DyZl38UuZMVfodvC18hucyYbMhfyJ48OGk7qepq6YOO5zRlM3bx5Kac1MVRaIccsW7W71DE5MVRaIccsWYo8EDNhfeKDiIhiDzu08S1fZ7GRCsaHAZ3varbbjyuX71DE5MVRaIccsWcQ496opkSNDiIhihizJCio0oyZD0p4I5NVt408bsOhqMFDG576VJ3UELQ78aQ)OfaQnV6qsZBAYH0eQnVhUvBKcpq6YOO5r1fZ7GRCsaHAZ3vmovcEVUZl38DfJtLG3dtLXWPw35rzh7qepq6YOO5zRlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZJYo2HiEG0LrrZJGUyEhCLtciuB(UIXPsW71DE5MVRyCQe8EyQmgo16opk7yhI4bsxgfnp7DX8o4kNeqO28DfJtLG3R78YnFxX4uj49WuzmCQ1DEu2XoeXdKUmkAEeGlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZJYo2HiEG0LrrZ3pDX8o4kNeqO28DfJtLG3R78YnFxX4uj49WuzmCQ1DEu2XoeXdKUmkAEhUlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZJYo2HiEG0LrrZVBNlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZJYo2HiEG0LrrZVdvxmVdUYjbeQnFxX4uj496oVCZ3vmovcEpmvgdNADNhfuzhI4bsxgfn)o27I5DWvojGqT57c0kADGncVx35LB(UaTIwhyJW7HPYy4uR78MmpBkcSlNhLDSdr8a5ajBKdXH2bBUJ(bxm)8DcNMpqc9aY8RdmFxbefeKO6opG6pAbGAZRoK08MMCinHAZ7HB1gPWdKUmkAEuDX8o4kNeqO28DfJtLG3R78YnFxX4uj49WuzmCQ1DEuqLDiIhiDzu08O6I5DWvojGqT57kGOGGe8o8EDNxU57kGOGGeSSdVx35rzh7qepq6YOO5r1fZ7GRCsaHAZ3varbbjyuX71DE5MVRaIccsWcQ496opkOYoeXdKUmkAE26I5DWvojGqT57kgNkbVx35LB(UIXPsW7HPYy4uR78OGk7qepq6YOO5zRlM3bx5Kac1MVRaIccsW7W71DE5MVRaIccsWYo8EDNhfuzhI4bsxgfnpBDX8o4kNeqO28Dfquqqcgv8EDNxU57kGOGGeSGkEVUZJYo2HiEG0LrrZJGUyEhCLtciuB(UcikiibVdVx35LB(Ucikiibl7W71DEu2XoeXdKUmkAEe0fZ7GRCsaHAZ3varbbjyuX71DE5MVRaIccsWcQ496opkOYoeXdKUmkAE27I5DWvojGqT57kGOGGe8o8EDNxU57kGOGGeSSdVx35rbv2HiEG0LrrZZExmVdUYjbeQnFxbefeKGrfVx35LB(UcikiiblOI3R78OSJDiIhihizJCio0oyZD0p4I5NVt408bsOhqMFDG572OLPXLUZdO(JwaO28QdjnVPjhstO28E4wTrk8aPlJIMN9UyEhCLtciuB(UIXPsW71DE5MVRyCQe8EyQmgo16opkOYoeXdKUmkAEeGlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZJcBzhI4bsxgfnF)0fZ7GRCsaHAZ3vmovcEVUZl38DfJtLG3dtLXWPw35rzh7qepq6YOO5rGCX8o4kNeqO28DfJtLG3R78YnFxX4uj49WuzmCQ1DEu2XoeXdKUmkA(DS1fZ7GRCsaHAZ3vmovcEVUZl38DfJtLG3dtLXWPw35rzh7qepq6YOO53XExmVdUYjbeQnFxX4uj496oVCZ3vmovcEpmvgdNADNhLDSdr8aPlJIMFhcWfZ7GRCsaHAZ3vmovcEVUZl38DfJtLG3dtLXWPw35nzE2ueyxopk7yhI4bsxgfn)U(PlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZJYo2HiEGCGKnYH4q7Gn3r)GlMF(oHtZhiHEaz(1bMVRDu35bu)rlauBE1HKM30KdPjuBEpCR2ifEG0LrrZJQlM3bx5Kac1MVRyCQe8EDNxU57kgNkbVhMkJHtTUZBY8SPiWUCEu2XoeXdKUmkAE26I5DWvojGqT57kgNkbVx35LB(UIXPsW7HPYy4uR78MmpBkcSlNhLDSdr8aPlJIMVF6I5DWvojGqT57kgNkbVx35LB(UIXPsW7HPYy4uR78OSJDiIhiDzu08iqUyEhCLtciuB(UIXPsW71DE5MVRyCQe8EyQmgo16opk7yhI4bsxgfn)oe6I5DWvojGqT57kgNkbVx35LB(UIXPsW7HPYy4uR78OSJDiIhihi7eonFxnfLcHqQ6oV5L4Q57zQ5RtMFDAvB(OMxGhQ5dKqpGGhizZiHEaHAZVJTZBEjUAEEOefEGmRdfCRGtz9(V)NVFmzc85zJTIn4Y8SjGtjdK9F)ppKAfnpQoCxNhveI6UbYbY(V)N3bWTAJudK9F)ppB85DOeYZj1MNBkHnUI8x1MxtzB083AEha3Isn)TMNn7P5n18HmF7iv1vMhk3CC(EeNpFuZdfyEj8eEGCGS)NNn1PX1mHuZBZlGOGGe18(74TRx568TWz0O28moop0GZnW83A(f4uY8hyEgazc85V18QOAaB7uwx18(74TRxHNNnVMpKUQ5DACnAE4MA(6MhqiTOAeyEajAGA(DUopXv08as0a18ieZE8aP5L4kfgkG8hsgtGbAy70aHXWjxldjHwarbbjPDjLJL31dkAfjXYvNgxJqVZvNgxJsexrOriM9U6VQfsCfAbefeKG3HHBQKMIsmARLBu2xmovcMbqMapDRKkQgW2oL5gfbefeKG3H93XBxVc30aMex5WCy(74TRxHHgCUbs3kTaNsWnnGjXvOriISyjgNkbZaitGNUvsfvdyBNYCJI)oE76vygazc80TsQOAaB7ugUPbmjUYH5WequqqcEh2FhVD9kCtdysCfAeIilwIXPsWHN8guehinVexPWqbK)qYycmqdBNgimgo5Azij0cikiijHAs5y5D9GIwrsSC1PX1i07C1PX1OeXveAeIzVR(RAHexHwarbbjyuXWnvstrjgT1Ynk7lgNkbZaitGNUvsfvdyBNYCJIaIccsWOI93XBxVc30aMex5WCy(74TRxHHgCUbs3kTaNsWnnGjXvOriISyjgNkbZaitGNUvsfvdyBNYCJI)oE76vygazc80TsQOAaB7ugUPbmjUYH5WequqqcgvS)oE76v4MgWK4k0ierwSeJtLGdp5nOioq2)ZZMQKaPjKAEBEbefeKOM3PX1O5zCCE)HeQbIABEbonV)oE76vZFR5f408cikiiX15BHZOrT5zCCEbonFtdysC183AEbonpJ2AnFiZdfCoJgPWZ3pYuZBZReavBc85rETyfeyE5MFlCsZBZdp2GtG5HcIdeIJZl38kbq1MaFEbefeKOCDEtnFpIZN3uZBZJ8AXkiW8RdmFSM3MxarbbjZ3l485pW89coF(6K5vow(57fc8593XBxVsHhinVexPWqbK)qYycmqdBNgimgo5Azij0cikiijbfehiehD9GIwrsSC1PX1i0O6QtJRrjIRi07C1FvlK4k07lGOGGe8omCtL0uuIrBTClGOGGemQy4MkPPOeJ2AXILaIccsWOIHBQKMIsmARLBuqrarbbjyuX(74TRxHBAatIRCycikiibJkMrBTsnnGjXviYgqzhM9WqarbbjyuXWnvIrBTWkbq1Mahr2akonqymCclGOGGKeQjLJLhre7dfuequqqcEh2FhVD9kCtdysCLdtarbbj4DygT1k10aMexHiBaLDy2ddbefeKG3HHBQeJ2AHvcGQnboISbuCAGWy4ewarbbjPDjLJLhrehinVexPWqbK)qYycmqd7fNuW9aBjdKdK9F)ppBk7iVMqT5jNeWX5LajnVaNM38YbMpuZBoTGBmCcpqAEjUsHgzuT0cqu)sdK9)89xa5KkzEfuYhRGAZlGOGGe18muuBZRPO289cb(8MMCinj8ZZJIudKMxIRuWanSDAGWy4KRLHKqRGs(yfuljGOGGexDACncnku)rlGcLA4OuEGMymCk1F0Ss0qMAKZWtU93XBxVchLYd0eJHtP(JMvIgYuJCgEcdiR5iIdKMxIRuWanSDAGWy4KRLHKqRKeuUvvuBU604AeAZlHtkrfHmif6DUrbyrlroPsWwRPWr13o2ZI1(alAjYjvc2AnfMyxOefIdKMxIRuWanSDAGWy4KRLHKqBTMkbiKwuU604AeAZlHtkrfHmivFOr1nk7dSOLiNujyR1uyIDHsuSybSOLiNujyR1uyIDHsuUrbyrlroPsWwRPWacPfLQp2ZI1k2GljaH0Is13oeIiIdK9)8oeOq5oopBc4uY8SjKtc468iTOelQ5zZEhNVtJFLAERAZdbrqN3HsipGI4KsnpBuucbMhCCEuBdKMxIRuWanSbeYdOioPuPErjeW1yH2Fvtlem5KalWPe3IXPsWBMaNarTLuYbq6EFX4uj4JHhcbmjUYT)oE76vyObNBG0TslWPemGqArPginVexPGbAyd)6XJAlXWnL4Q3rpNsIb2irHENRXcD7e8cCkjTiNeadOfGuWngo5gfX4uj4WtEdklw7ZOTwygazc80TsQOAaB7ugwdQBX4ujygazc80TsQOAaB7uglwIXPsWhdpecysCLB)D821RWqdo3aPBLwGtjyaH0Is5EFgT1cdrW5rTLqAE4rrynOioqAEjUsbd0WEJB(W4jR50kp5ASqZOTw4W7ysm(vkmGqArPGf6nFZnJ2AHdVJjX4xPWAqDRGsCEsmWgjk8g38HXtwZPvEQp0O6gL9fJtLGzaKjWt3kPIQbSTtzSy5VJ3UEfMbqMapDRKkQgW2oLHbeslkvF7ypIdKMxIRuWanSxGtjjLaciixJfAgT1chEhtIXVsHbeslkfSqV5BUz0wlC4Dmjg)kfwdQBu2xmovcMbqMapDRKkQgW2oLXIL)oE76vygazc80TsQOAaB7uggqiTOu9TJ9ioq2)Z7a43PO5DiEjUAEEOK5LBEGwnqAEjUsbd0W2BCEY8sCvIhkX1YqsO9NtQSsudKMxIRuWanS9gNNmVexL4HsCTmKeAG5dJRginVexPGbAy7nopzEjUkXdL4Azij0cikiirnqAEjUsbd0W2BCEY8sCvIhkX1YqsO93XBxVsnqAEjUsbd0W2BCEY8sCvIhkX1YqsO9hVLGtgqCnwOfJtLG9hVLGtgqCZOTwy)XBj4KbeSsmpe9HEhcDJsJy0wlmW63deEcReZdbA2ZI1(nYe4jiQydUGbAfToWgHbw)EGWtiYIfZPuUxXgCjbiKwukyHEZ3ginVexPGbAyd0QK5L4QepuIRLHKqZCQKeEiIAZ1yHMrBTWmaYe4PBLur1a22PmSg0bsZlXvkyGg2aTkzEjUkXdL4Azij0mNkb9oEuBUgl0IXPsWmaYe4PBLur1a22Pm3O4VJ3UEfMbqMapDRKkQgW2oLHbeslkfS2HqeDJcWIwICsLGTwtHJQpuzplw7dSOLiNujyR1uyIDHsuSy5VJ3UEfgAW5giDR0cCkbdiKwukyTdHUbw0sKtQeS1AkmXUqjk3alAjYjvc2AnfokyTdHioqAEjUsbd0WgOvjZlXvjEOexldjH(y4HqatIRCnwOz0wlm0GZnq6wPf4ucwdQBX4uj4JHhcbmjUAG08sCLcgOHnqRsMxIRs8qjUwgsc9XWdHaMexLGEhpQnxJfAX4uj4JHhcbmjUYT)oE76vyObNBG0TslWPemGqArPG1oe6gfNgimgoHvsck3QkQnwSaw0sKtQeS1AkmXUqjk3alAjYjvc2AnfokyTdHSyTpWIwICsLGTwtHj2fkrH4aP5L4kfmqdBGwLmVexL4HsCTmKeA7ixJfAZlHtkrfHmivFOrDG08sCLcgOHT348K5L4QepuIRLHKqReRAgOnqoq2)Z7qo205DONysC1aP5L4kf2ocnGqEafXjLk1lkHadKMxIRuy7iyGg2BCZhgpznNw5jxJfAX4uj4f4uIY7OaNginVexPW2rWanSxGtjjLaciix9o65usmWgjk07CnwO93XBxVcdiKhqrCsPs9IsiagqiTOuWcnQSHnFZTyCQe8MjWjquBjLCaKdKMxIRuy7iyGg2WVE8O2smCtjUgl0mARfgeijSg0bsZlXvkSDemqd7JHhcbmHCnwOBKjWtw1snYBoILWdruBU9NtQSsWvSbxslJCZOTw4gzcCvQPryLyEiGfcoqAEjUsHTJGbAyVaNsuEhf4KRXcnJ2AHHi48O2sinp8OimGmV4gL9BKjWtw1snYBoILWdruBU9NtQSsWvSbxslJyXAF)5KkReCfBWL0YiehinVexPW2rWanS34MpmEYAoTYtUgl0aTk8jOxpcGB0k8Halu2XEyigNkbd0QWNmrOsZK4k2aBrCG08sCLcBhbd0WEboLKuciGGC17ONtjXaBKOqVZ1yHgOvHpb96raCJwHpeyHYo2ddX4ujyGwf(KjcvAMexXgylIdKMxIRuy7iyGg2lWPeL3rbo5ASqVFJmbEYQwQrEZrSeEiIAZT)CsLvcUIn4sAzelw77pNuzLGRydUKwgnqAEjUsHTJGbAyFm8qiGjKREh9CkjgyJef6DUgl0aTk8jOxpcGB0k8H0hkOYEyigNkbd0QWNmrOsZK4k2aBrCG08sCLcBhbd0WEJB(W4jR50kpnqAEjUsHTJGbAyVaNsskbeqqU6D0ZPKyGnsuO3nqAEjUsHTJGbAyd)av6wPErjeyG08sCLcBhbd0W2aEROKCaavYa5az)ppmbKjWN)wZRhvdyBNYMh6D8O2MhCIjXvZ7I5vIbe187qOAEgADaAEyE6ZhQ5nNwWngonqAEjUsHzovc6D8O2qd)6XJAlXWnL4ASqZOTwyqGKWAqhinVexPWmNkb9oEuBWanSbeYdOioPuPErjeW1yH28s4Ksurids1hAuzXcOvewcKusUe7Hf6nFZnkIXPsWBMaNarTLuYbqYIL)QMwiyYjbwGtjSyb0kADGncZesuBj)XBioq2)Z3vmWgjPyHgPXoxGsJy0wlmW63deEcReZdbm2HOddLgXOTwyG1Vhi8egqiTOuWyhISHgzc8eevSbxWaTIwhyJWaRFpq4PUZ7qjOKjQ5T55N468c8qnFOMpkHQg1MxU5fdSrY8cCAE4XgCsjZdfehiehNNkcPJZ3le4ZB18gtWdXX5f4MmFVGZN3GcL748aRFpq4P5J18aTIwhyJA457eUjZZqrTnVvZtfH0X57fc85r48kX8qOCD(dmVvZtfH0X5f4MmVaNMVrmAR189coFE1D18e7GgaA(RWdKMxIRuyMtLGEhpQnyGg2hdpecyc5Q3rpNsIb2irHENRXcnqRcFc61Ja4gTcFi9Hgv2pqAEjUsHzovc6D8O2GbAyVXnFy8K1CALNCnwObAv4tqVEea3Ov4dbwOIq3kOeNNedSrIcVXnFy8K1CALN6dnQU93XBxVcdn4CdKUvAboLGbeslkvFSFG08sCLcZCQe074rTbd0WEboLKuciGGC17ONtjXaBKOqVZ1yHgOvHpb96raCJwHpeyHkcD7VJ3UEfgAW5giDR0cCkbdiKwuQ(y)aP5L4kfM5ujO3XJAdgOH9cCkr5DuGtUgl0mARfgIGZJAlH08WJIWaY8IBGwf(e0RhbWnAf(q6dLDShgIXPsWaTk8jteQ0mjUInWweDRGsCEsmWgjk8cCkr5DuGt9Hgv3OWOTw4gzcCvQPryLyEiqJGSyTFJmbEYQwQrEZrSeEiIAJfR99NtQSsWvSbxslJqCG08sCLcZCQe074rTbd0WEboLO8okWjxJfAGwf(e0RhbWnAf(q6dnkSL9WqmovcgOvHpzIqLMjXvSb2IOBfuIZtIb2irHxGtjkVJcCQp0O6gfgT1c3itGRsnncReZdbAeKfR9BKjWtw1snYBoILWdruBSyTV)CsLvcUIn4sAzeIdKMxIRuyMtLGEhpQnyGg2BCZhgpznNw5jxJfA)D821RWqdo3aPBLwGtjyaH0Is1hqRiSeiPKCje0nqRcFc61Ja4gTcFiWcbrOBfuIZtIb2irH34MpmEYAoTYt9Hg1bsZlXvkmZPsqVJh1gmqd7f4ussjGacYvVJEoLedSrIc9oxJfA)D821RWqdo3aPBLwGtjyaH0Is1hqRiSeiPKCje0nqRcFc61Ja4gTcFiWcbr4a5az)ppmbKjWN)wZRhvdyBNYM3H4LWjnVd9etIRginVexPWmNkjHhIO2qFm8qiGjKREh9CkjgyJef6DUgl0aTk8jOxpcGB0k8H0hAeachinVexPWmNkjHhIO2GbAydiKhqrCsPs9IsiGRXcTyCQe8MjWjquBjLCaKSy5VQPfcMCsGf4uclwaTIwhyJWmHe1wYF8glwMxcNuIkczqQ(qJklw7lgNkbVzcCce1wsjhaP799x10cbtojWcCkX9(aTIwhyJWmHe1wYF8MBGwf(e0RhbGfBrDG08sCLcZCQKeEiIAdgOHDJmbEYQwQrEZrxJfAGwf(e0RhbGfBrDG08sCLcZCQKeEiIAdgOHn8RhpQTed3uIRXcnJ2AHbbscRb1nkaTk8jOxpcGB0k8Hal2ZEwSaAfHLajLKlXwyHEZ3yXsbL48KyGnsuy4xpEuBjgUPK(qJkISyb0QWNGE9iaSylQdKMxIRuyMtLKWdruBWanSxGtjkVJcCY1yHMrBTWqeCEuBjKMhEuewdQBfuIZtIb2irHxGtjkVJcCQp0O6gL9BKjWtw1snYBoILWdruBU9NtQSsWvSbxslJyXAF)5KkReCfBWL0YiehinVexPWmNkjHhIO2GbAyd)av6wPErjeW1yHgOvHpb96raCJwHpK(qJGi0nqRiSeiPKCj223MVnqAEjUsHzovscperTbd0WEboLO8okWjxJfAfuIZtIb2irHxGtjkVJcCQp0O6gfgT1c3itGRsnncReZdbAeKfR9BKjWtw1snYBoILWdruBSyTV)CsLvcUIn4sAzeIdKMxIRuyMtLKWdruBWanSpgEieWeYvVJEoLedSrIc9oxJfAGwf(e0RhbWnAf(q6dv2ZIfqRiSeiPKCj2cRnFBG08sCLcZCQKeEiIAdgOHn8RhpQTed3uIRXcnJ2AHbbscRbDG08sCLcZCQKeEiIAdgOHTb8wrj5aaQexJfAGwf(e0RhbWnAf(q6J9iCGCGS)7)5DWXBZ3pImGmVdUQfsCLAGS)7)5nVexPW(J3sWjdiO9WTOuPBLcp5ASqVIn4scqiTOuWAZ3gi7)5zJHIMVPbIAB((BW5gy(EHaFE2SN8guydtazc8bsZlXvkS)4TeCYacmqdBpClkv6wPWtUgl07lgNkbFm8qiGjXvUz0wlm0GZnq6wPf4ucgqiTOuWITUz0wlm0GZnq6wPf4ucwdQBgT1c7pElbNmGGvI5HOp07q4az)ppcSMOIgn)TMV)gCUbMxtr2gnFVqGppB2tEdkSHjGmb(aP5L4kf2F8wcozabgOHThUfLkDRu4jxJf69fJtLGpgEieWK4k3nYe4jiQydUGbAfToWgHxgNtvYd0uwJaU3NrBTWqdo3aPBLwGtjynOUrHrBTW(J3sWjdiyLyEi6d9oeGBgT1cRvWpUJjLaOAtGJ1GYIfJ2AH9hVLGtgqWkX8q0h6DoC3(74TRxHHgCUbs3kTaNsWacPfLQVDieXbsZlXvkS)4TeCYacmqdBpClkv6wPWtUgl07lgNkbFm8qiGjXvU3VrMapbrfBWfmqRO1b2i8Y4CQsEGMYAeWnJ2AH9hVLGtgqWkX8q0h6Di09(mARfgAW5giDR0cCkbRb1T)oE76vyObNBG0TslWPemGqArP6dveoq2)Z3FbKtQK5DWXBZ3pImGm)5KaEdk0O2MVPbIABEObNBGbsZlXvkS)4TeCYacmqdBpClkv6wPWtUgl0IXPsWhdpecysCL79z0wlm0GZnq6wPf4ucwdQBuy0wlS)4TeCYacwjMhI(qVdb4MrBTWAf8J7ysjaQ2e4ynOSyXOTwy)XBj4KbeSsmpe9HENdNfl)D821RWqdo3aPBLwGtjyaH0Isbl26MrBTW(J3sWjdiyLyEi6d9oeeXbYbY(F((7jXvdKMxIRuy)D821RuOHEsCLRXcnJ2AHHgCUbs3kTaNsWAqhi7)5DWD821RudKMxIRuy)D821RuWanSjKqVEeib0kk1JmOx5ASqlgNkbFm8qiGjXvUbAfbleGBuCAGWy4ewjjOCRQO2yXYPbcJHtyR1ujaH0Icr3O4VJ3UEfgAW5giDR0cCkbdiKwukyXEwSy0wlm0GZnq6wPf4ucwdkISyTIn4scqiTOuWcveoqAEjUsH93XBxVsbd0WMqc96rGeqROupYGELRXcTyCQemdGmbE6wjvunGTDkZnqRcFc61Ja4gTcFi9Xwe6gOvewcKusUe77BZ3CJcJ2AHzaKjWt3kPIQbSTtzynOSyTIn4scqiTOuWcveI4aP5L4kf2FhVD9kfmqdBcj0RhbsaTIs9id6vUgl0IXPsWHN8gu3aTIGfBhinVexPW(74TRxPGbAydn4CdKUvAboL4ASqlgNkbZaitGNUvsfvdyBNYCJItdegdNWkjbLBvf1glwonqymCcBTMkbiKwui6gf)D821RWmaYe4PBLur1a22PmmGqArPyXYFhVD9kmdGmbE6wjvunGTDkddiR5OBGwf(e0RhbWnAf(qGf7riIdKMxIRuy)D821RuWanSHgCUbs3kTaNsCnwOfJtLGdp5nOU3NrBTWqdo3aPBLwGtjynOdKMxIRuy)D821RuWanSHgCUbs3kTaNsCnwOfJtLGpgEieWK4k3O40aHXWjSssq5wvrTXILtdegdNWwRPsacPffIUrrmovcEZe4eiQTKsoasmvgdNAUz0wlmGqEafXjLk1lkHaynOSyTVyCQe8MjWjquBjLCaKyQmgo1qCG08sCLc7VJ3UELcgOHndGmbE6wjvunGTDkZ1yHMrBTWqdo3aPBLwGtjynOdKMxIRuy)D821RuWanSxGtj9CeGuLwAahDnwOnVeoPeveYGuO35MrBTWqdo3aPBLwGtjyaH0IsbRnFZnJ2AHHgCUbs3kTaNsWAqDVVyCQe8XWdHaMex5gL9bw0sKtQeS1AkmXUqjkwSaw0sKtQeS1AkCu9XweIilwRydUKaeslkfSy7aP5L4kf2FhVD9kfmqd7f4usphbivPLgWrxJfAZlHtkrfHmivFOr1nkmARfgAW5giDR0cCkbRbLflGfTe5KkbBTMchvF(74TRxHHgCUbs3kTaNsWacPfLcr3OWOTwyObNBG0TslWPemGqArPG1MVXIfWIwICsLGTwtHbeslkfS28nehinVexPW(74TRxPGbAyVaNs65iaPkT0ao6ASqlgNkbFm8qiGjXvUz0wlm0GZnq6wPf4ucwdQBuqHrBTWqdo3aPBLwGtjyaH0IsbRnFJflgT1cRvWpUJjLaOAtGJ1G6MrBTWAf8J7ysjaQ2e4yaH0IsbRnFdr3O0igT1cdS(9aHNWkX8qGM9SyTFJmbEcIk2GlyGwrRdSryG1Vhi8eIioqAEjUsH93XBxVsbd0WgUJqpbobqg(euaPOYtUgl0IXPsWmaYe4PBLur1a22Pm3aTk8jOxpcGB0k8H0hcIq3aTIGfA26gfgT1cZaitGNUvsfvdyBNYWAqzXYFhVD9kmdGmbE6wjvunGTDkddiKwuQ(qqeIilw7lgNkbZaitGNUvsfvdyBNYCd0QWNGE9iaUrRWhsFOrL9dKMxIRuy)D821RuWanSbwOOuJSMRXcnJ2AHHgCUbs3kTaNsWAqhinVexPW(74TRxPGbAyRmpiwHpmEcQ5fxJfAZlHtkrfHmivFOr1nkmNs5EfBWLeGqArPGfBzXAFgT1cZaitGNUvsfvdyBNYWAqDJcusWBWpnogqiTOuWAZ3yXcyrlroPsWwRPWacPfLcwS1nWIwICsLGTwtHJQpOKG3GFACmGqArPqeXbsZlXvkS)oE76vkyGg2nYe4jRAPg5nhDnwOnVeoPeveYGu9XEwSaAfToWgHHcNmWH8ksnqoq2)Z7GZjvwjZ7qycEibPginVexPW(Zjvwjk0nYe4QutJCnwODAGWy4ewjjOCRQO2yXYPbcJHtyR1ujaH0IAG08sCLc7pNuzLOGbAyR6zaKrTLqgkX1yHgOvHpb96raCJwHpK(yRB)D821RWqdo3aPBLwGtjyaH0Isbl26EFX4ujygazc80TsQOAaB7uMBNgimgoHvsck3QkQTbsZlXvkS)CsLvIcgOHTQNbqg1wczOexJf69fJtLGzaKjWt3kPIQbSTtzUDAGWy4e2AnvcqiTOginVexPW(ZjvwjkyGg2QEgazuBjKHsCnwOfJtLGzaKjWt3kPIQbSTtzUrHrBTWmaYe4PBLur1a22PmSgu3O40aHXWjSssq5wvrT5gOvHpb96raCJwHpK(qqeYILtdegdNWwRPsacPfLBGwf(e0RhbWnAf(q6dbGqwSCAGWy4e2AnvcqiTOCdSOLiNujyR1uyaH0IsblhoISyTpJ2AHzaKjWt3kPIQbSTtzynOU93XBxVcZaitGNUvsfvdyBNYWacPfLcXbsZlXvkS)CsLvIcgOHTXCiJYK4QepqY4ASq7VJ3UEfgAW5giDR0cCkbdiKwukyXw3onqymCcRKeuUvvuBUrrmovcMbqMapDRKkQgW2oL5gOvHpb96raCJwHpeyHaqOB)D821RWmaYe4PBLur1a22PmmGqArPGfQSyTVyCQemdGmbE6wjvunGTDkdXbsZlXvkS)CsLvIcgOHTXCiJYK4QepqY4ASq70aHXWjS1AQeGqArnqAEjUsH9NtQSsuWanSvWnpeCkjWPKw17acChDnwO93XBxVcdn4CdKUvAboLGbeslkfSyRBNgimgoHvsck3QkQTbsZlXvkS)CsLvIcgOHTcU5HGtjboL0QEhqG7ORXcTtdegdNWwRPsacPf1aP5L4kf2FoPYkrbd0WEXjfCpWwIRXcT604mr1Wq1uIgNseqdQex5EFgT1cdn4CdKUvAboLG1Goqoq2)ZJaZWdHaMexnp4etIRginVexPWhdpecysCfAaH8akItkvQxucbCnwOnVeoPeveYGu9HMTUrrmovcEZe4eiQTKsoaswS8x10cbtojWcCkHflGwrRdSryMqIAl5pEdXbsZlXvk8XWdHaMexbd0Wg(1Jh1wIHBkXvVJEoLedSrIc9oxJf69BNGxGtjPf5Kayj8qe1M79z0wlmebNh1wcP5HhfH1G6gOvuFOz7aP5L4kf(y4HqatIRGbAyVaNsuEhf4KRXcnJ2AHHi48O2sinp8OimGmV4wbL48KyGnsu4f4uIY7OaN6dnQUrHrBTWnYe4QutJWkX8qGgbzXA)gzc8KvTuJ8MJyj8qe1glw77pNuzLGRydUKwgH4aP5L4kf(y4HqatIRGbAyFm8qiGjKREh9CkjgyJef6DUgl0mARfgIGZJAlH08WJIWaY8clw7ZOTwyqGKWAqDRGsCEsmWgjkm8RhpQTed3usFOz7aP5L4kf(y4HqatIRGbAyVXnFy8K1CALNCnwOvqjopjgyJefEJB(W4jR50kp1hAuDJcqRcFc61Ja4gTcFiWAhczXcOvewcKusUeQ9T5BiYIfknIrBTWaRFpq4jSsmpeWI9Sy1igT1cdS(9aHNWacPfLcw7ypIdKMxIRu4JHhcbmjUcgOH9cCkjPeqab5ASqBEjCsjQiKbPqVZnk(RAAHGjG1cVjrTLy4xp3mARfMawl8Me1wIHF9WkX8qGgvwS8x10cbRvCYuWPwAbOQFD0nJ2AH1kozk4ulTau1VoIbeslkfS28nehinVexPWhdpecysCfmqdB4xpEuBjgUPexJfAgT1cdcKewdQBfuIZtIb2irHHF94rTLy4Ms6dnQdKMxIRu4JHhcbmjUcgOH9g38HXtwZPvEY1yHwbL48KyGnsu4nU5dJNSMtR8uFOrDG08sCLcFm8qiGjXvWanSxGtjjLaciix9o65usmWgjk07CnwO3xmovc2CACR8Wj37ZOTwyicopQTesZdpkcRbLflX4ujyZPXTYdNCVpJ2AHbbscRbLflgT1cdcKewdQBGwryjqsj5sO2h6nFBG08sCLcFm8qiGjXvWanSHF94rTLy4MsCnwOz0wlmiqsynOdKMxIRu4JHhcbmjUcgOH9XWdHaMqU6D0ZPKyGnsuO3nqoq2)Z3FVJh128SjhyEeygEieWK4kxmVUyarn)oeoVI8x1uZZqRdqZ3Fdo3aZFR5ztaNsM3Fij183AnVd6hpqAEjUsHpgEieWK4Qe074rTHgqipGI4KsL6fLqaxJfAX4uj4ntGtGO2sk5aizXYFvtlem5KalWPewSaAfToWgHzcjQTK)4nwSmVeoPeveYGu9Hg1bsZlXvk8XWdHaMexLGEhpQnyGg2WVE8O2smCtjUgl0mARfgeijSg0bsZlXvk8XWdHaMexLGEhpQnyGg2hdpecyc5Q3rpNsIb2irHENRXcnJ2AHHi48O2sinp8OimGmVmqAEjUsHpgEieWK4Qe074rTbd0WEJB(W4jR50kp5ASqRGsCEsmWgjk8g38HXtwZPvEQp0O6gOvHpb96raCJwHpeyHaq4aP5L4kf(y4HqatIRsqVJh1gmqd7f4ussjGacYvVJEoLedSrIc9oxJfAGwf(e0RhbWnAf(qGv)eHdKMxIRu4JHhcbmjUkb9oEuBWanSpgEieWeYvVJEoLedSrIc9oxJfAGwr9HMTdKMxIRu4JHhcbmjUkb9oEuBWanSxGtjkVJcCY1yH28s4Ksurids1hAe0nk73itGNSQLAK3CelHhIO2C7pNuzLGRydUKwgXI1((Zjvwj4k2GlPLrioqoq2)Z7qnFy85DimbpKGudKMxIRuyG5dJRqZWVRLwAahDnwOz0wlm0GZnq6wPf4ucwd6aP5L4kfgy(W4kyGg2meqraiIAZ1yHMrBTWqdo3aPBLwGtjynOdKMxIRuyG5dJRGbAyBaVvucQgxrUgl0OSpJ2AHHgCUbs3kTaNsWAqDBEjCsjQiKbP6dnQiYI1(mARfgAW5giDR0cCkbRb1nkaTIWnAf(q6dn7Dd0QWNGE9iaUrRWhsFOraieXbsZlXvkmW8HXvWanS5XgCrLyJPwBdjvIRXcnJ2AHHgCUbs3kTaNsWAqhinVexPWaZhgxbd0W2kpPeGXtEJZDnwOz0wlm0GZnq6wPf4ucwdQBgT1ctiHE9iqcOvuQhzqVcRbDG08sCLcdmFyCfmqd7vaig(DnxJfAgT1cdn4CdKUvAboLGbeslkfSqJa5MrBTWesOxpcKaAfL6rg0RWAqhinVexPWaZhgxbd0WMX2s3kjGWdHY1yHMrBTWqdo3aPBLwGtjynOUnVeoPeveYGuO35gfgT1cdn4CdKUvAboLGbeslkfSyVBX4ujy)XBj4KbemvgdNASyTVyCQeS)4TeCYacMkJHtn3mARfgAW5giDR0cCkbdiKwukyXwehihi7)51fRAgOnVkQnoXgxmWgjZdoXK4QbsZlXvkSsSQzGgAaH8akItkvQxucbCnwOfJtLG3mbobIAlPKdGKfl)vnTqWKtcSaNsyXcOv06aBeMjKO2s(J3ginVexPWkXQMbAWanS34MpmEYAoTYtUgl073itGNGOIn4cgOv06aBegy97bcp5gLgXOTwyG1Vhi8ewjMhcyXEwSAeJ2AHbw)EGWtyaH0IsbR(jIdKMxIRuyLyvZanyGg2lWPKKsabeKRXcT)oE76vyaH8akItkvQxucbWacPfLcwOrLnS5BUfJtLG3mbobIAlPKdGCG08sCLcReRAgObd0WEboLKuciGGCnwO9x10cbtaRfEtIAlXWVEUz0wlmbSw4njQTed)6HvI5HanQSy5VQPfcwR4KPGtT0cqv)6OBgT1cRvCYuWPwAbOQFDediKwukyX2bsZlXvkSsSQzGgmqdB4xpEuBjgUPexJfAgT1cdcKewd6aP5L4kfwjw1mqdgOH9XWdHaMqUgl07ZOTw4f46xQsq14kcRb1TyCQe8cC9lvjOACfXIfJ2AHHi48O2sinp8OimGmVWIvJmbEYQwQrEZrSeEiIAZT)CsLvcUIn4sAzKBgT1c3itGRsnncReZdbSqqwSaAfHLajLKlHGWc9MVnqAEjUsHvIvnd0GbAyVaNsskbeqqUgl0aTk8jOxpcGB0k8Halu2XEyigNkbd0QWNmrOsZK4k2aBrCG08sCLcReRAgObd0W(y4HqatixJfAGwf(e0RhbWnAf(q6dfuzpmeJtLGbAv4tMiuPzsCfBGTioqAEjUsHvIvnd0GbAyVaNsskbeqqdKMxIRuyLyvZanyGg2WpqLUvQxucbginVexPWkXQMbAWanSnG3kkjhaqLmqoq2)Z3jikiirnqAEjUsHfquqqIcDukpqtmgoL6pAwjAitnYz4jxJfAgT1cdn4CdKUvAboLG1GYILyGnsWsGKsYLG6LeQiewSNflMtPCVIn4scqiTOuWc1DdK9)8DcNMxarbbjZ3le4ZlWP5HhBWjLmpPKaPjuBENgxJCD(EbNppdnVMIAZVcGsM3Q28qTaqT57fc857VbNBG5V18SjGtj4bsZlXvkSaIccsuWanSfquqqYoxJf69DAGWy4ewbL8XkOwsarbbjUz0wlm0GZnq6wPf4ucwdQBu2xmovco8K3GYILyCQeC4jVb1nJ2AHHgCUbs3kTaNsWacPfLQp07qiIUrzFbefeKGrfd3uj)D821RyXsarbbjyuX(74TRxHbeslkflwonqymCclGOGGKeuqCGqCe9oezXsarbbj4DygT1k10aMex1h6vSbxsacPfLAG08sCLclGOGGefmqdBbefeKGQRXc9(onqymCcRGs(yfuljGOGGe3mARfgAW5giDR0cCkbRb1nk7lgNkbhEYBqzXsmovco8K3G6MrBTWqdo3aPBLwGtjyaH0Is1h6Dier3OSVaIccsW7WWnvYFhVD9kwSequqqcEh2FhVD9kmGqArPyXYPbcJHtybefeKKGcIdeIJOrfrwSequqqcgvmJ2ALAAatIR6d9k2GljaH0Isnq2)ZZMxZFf3X5VIM)Q51u08cikiizEOGZz0i1828mARLRZRPO5f408NaNaZF18(74TRxHNhbgmFSMVOqGtG5fquqqY8qbNZOrQ5T5z0wlxNxtrZZCc85VAE)D821RWdKMxIRuybefeKOGbAylGOGGKDUgl07lGOGGe8omCtL0uuIrBTCJIaIccsWOI93XBxVcdiKwukwS2xarbbjyuXWnvstrjgT1crwS83XBxVcdn4CdKUvAboLGbeslkvFOIWbsZlXvkSaIccsuWanSfquqqcQUgl07lGOGGemQy4MkPPOeJ2A5gfbefeKG3H93XBxVcdiKwukwS2xarbbj4Dy4MkPPOeJ2AHilw(74TRxHHgCUbs3kTaNsWacPfLQpurywxbL85oqL97YswYza]] )


end
