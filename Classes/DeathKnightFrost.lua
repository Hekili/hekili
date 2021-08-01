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


    spec:RegisterPack( "Frost DK", 20210801, [[d4Km3cqiqHhjrsxIQe1MOQ6tkLgfe1PGcRcIqVsPWSGQ6wqeHDr0VaLmmOihtIAzqvEMeOPbfLRbrABqrLVjbOXjbW5KaY6OQO5bk6EqL9jrCqQsWcvk6HuvyIuLqCriIYgHiWhPkHAKuLq6KqrvRee9siIOMPeP2jvP(jerAOqe0sPkrEkHMQe0vHiI4RqevJfuQ9k0FfmyGdtzXq6XuzYk5YiBwsFgKgnO60IwnerKEnimBuUne2Tu)wvdxP64sa1Yv55OA6KUobBhk9Dj04PkPZtvP1lrI5tvSFfhlhlmkUmLIEJhMWRmMkayQSSmMRC5cwWOO67off3nhegukk2gckkIeCpxhGxeKKJI7MVS3wXcJI8x4CuueUQ7CFclybnv4cOs3Jaw8eHaZ08B3zvfw8eHdwrruHKPy(oIgfxMsrVXdt4vgtfamvwwgZvUC5cuu0eu4)fffte(ikcpxlQJOrXfXDrrViKPWhasYDcfUoaKG756aPxqaQaxhqz8haEycVYdKdK(aU1qj(ajsIb4LiepwAnaMXvKeCY99AacCdknGVoaFa3YMpGVoamVJgGXhqQdy9eV3QdyNz(oGIeJnGShW(zonDKCGejXa8I89wDao4w3eBaibmId3DwvhWs4Yg6a28itHpGVoaXSxNb95MmkYsUYJfgfFuwQ0zA(Dy)Fw2qJfg9UCSWOi1gkJwXnJIMtZVJIhH4poXiopumBLUO4I4Ul3187Ois4)SSHoaKG)gaskklv6mn)2NdquTt5dOmMgaNCFV4daLQ)rdajmzm7gWxhasW9CDaUhbXhWxRdWhErIIUlv6slkI1U0qzK8kgqfQv(a84zaMttSuGAcrs8bucUbGxuJEJxSWOi1gkJwXnJIUlv6slkAonXsbQjejXhaUbuEa(haw7sdLrY69CnW1lHGcUVxcPYJIMtZVJI175AGRxcbf1O3fmwyuKAdLrR4MrrZP53rXhLLkDMsrr3LkDPffrfQvjejJLn0acZbpBsEK50OOZxhJcQDqjLh9UCuJEJzXcJIuBOmAf3mk6UuPlTOiw7sdLrY71QlCjckkAon)okc)lYYgAaLzCnQrVrASWOi1gkJwXnJIUlv6slkY3jglO2bLuUekZCPXc2cR1oAaLGBa4na)d4e60f2)I0jxunDPoayoamhMIIMtZVJIqzMlnwWwyT2rrn6nMlwyuKAdLrR4MrrZP53rX69CnW1lHGIIUlv6slkEcD6c7Fr6KlQMUuhamhqbetrrNVogfu7Gskp6D5Og9UaglmksTHYOvCZOO5087O4JYsLotPOO7sLU0IINqtdOeCdOGrrNVogfu7Gskp6D5Og9UaelmksTHYOvCZOO7sLU0IIMttSuGAcrs8bucUbGzdW)aGXaWAxAOmsUitHZdlbkyonXsrrZP53rX69CL78vHtrnQrr3Zwb4KDASWO3LJfgfP2qz0kUzu0CA(Du0b3YMh(AiDuuCrC3L7A(DuejjCAalHlBOdajmzm7gqXuHpamVJC2oS28itHhfDxQ0Lwuegdqng1Q8rzPsNP53sQnugTgG)bGkuRY9KXSl81q9EUkf2hG)bGkuRs3Zwb4KDQKRMdIbucUbugtdW)aqEaOc1QCpzm7cFnuVNRYJqyzZhamhau3AaiXbG8akpGngG7F26l2Y69CTOVhcEOkC(kpYw(oamgGhpdavOwLcn8N5BGRh1qv4YJqyzZhamhau3AaE8mauHAv6GBppGAnjpcHLnFaWCaqDRbGruJEJxSWOi1gkJwXnJIMtZVJIo4w28WxdPJIIlI7UCxZVJIiPckpx0a(6aqctgZUbiWjdknGIPcFayEh5SDyT5rMcpk6UuPlTOimgGAmQv5JYsLotZVLuBOmAna)dyrMcparNqHRYtOP6Fqjz1ymQdUtGBl6gG)baJbGkuRY9KXSl81q9EUkf2hG)b4(NT(ITCpzm7cFnuVNRYJqyzZhqjdOmshG)bG8aqfQvP7zRaCYovYvZbXakb3akJPb4FaipauHAvk0WFMVbUEudvHlf2hGhpdavOwLo42ZdOwtsH9bGXa84zaOc1Q09SvaozNk5Q5GyaLGBaLl4aWiQrVlySWOi1gkJwXnJIUlv6slkcJbOgJAv(OSuPZ08Bj1gkJwdW)aGXawKPWdq0ju4Q8eAQ(huswngJ6G7e42IUb4FaOc1Q09SvaozNk5Q5GyaLGBaLX0a8paymauHAvUNmMDHVgQ3ZvPW(a8pa3)S1xSL7jJzx4RH69CvEeclB(akza4HPOO5087OOdULnp81q6OOg9gZIfgfP2qz0kUzu0CA(Du0b3YMh(AiDuuCrC3L7A(Duej8iSuRdWhpBnaVOKD6aES05S99SHoGLWLn0bSNmMDrr3LkDPffvJrTkFuwQ0zA(TKAdLrRb4FaWyaOc1QCpzm7cFnuVNRsH9b4FaipauHAv6E2kaNStLC1CqmGsWnGYy2a8paKhaQqTkfA4pZ3axpQHQWLc7dWJNbGkuRshC75buRjPW(aWyaE8mauHAv6E2kaNStLC1CqmGsWnGYfOb4XZaC)ZwFXwUNmMDHVgQ3Zv5riSS5daMdOGdW)aqfQvP7zRaCYovYvZbXakb3akJzdaJOg1O4JYsLotZVJfg9UCSWOi1gkJwXnJIMtZVJIhH4poXiopumBLUO4I4Ul3187Oiskklv6mn)Ea3RMMFhfDxQ0Lwu0CAILcutisIpGsWnGcoa)daRDPHYi5vmGkuR8Og9gVyHrrQnugTIBgfDxQ0Lwuegdy9QSEpxdvclDsnDqKn0b4FaWyaOc1QeIKXYgAaH5GNnjf2hG)bCcnnGsWnGcgfnNMFhfH)fzzdnGYmUg1O3fmwyuKAdLrR4Mrr3LkDPffrfQvjejJLn0acZbpBsEK50b4Fa8DIXcQDqjLlR3ZvUZxfonGsWna8gG)baJbG1U0qzKCrMcNhwcuWCAILIIMtZVJI175k35RcNIA0BmlwyuKAdLrR4MrrZP53rXhLLkDMsrr3LkDPffrfQvjejJLn0acZbpBsEK50OOZxhJcQDqjLh9UCuJEJ0yHrrQnugTIBgfDxQ0LwuKVtmwqTdkPCjuM5sJfSfwRD0akb3aWBa(haYd4e60f2)I0jxunDPoayoGYyAaE8mGtOjPMiOG(b8gqjdaQBnamgGhpda5bSiuHAvEwP8x6ijxnhedaMdaPdWJNbSiuHAvEwP8x6i5riSS5daMdOmshagrrZP53rrOmZLglylSw7OOg9gZflmksTHYOvCZOO7sLU0IIMttSuGAcrs8bGBaLhG)bG1U0qzKSEpxdC9siOG77LqQ8OO5087Oy9EUg46Lqqrn6DbmwyuKAdLrR4Mrr3LkDPffXAxAOmsEVwDHlrqdW)a47eJfu7Gskxc)lYYgAaLzCDaLGBa4ffnNMFhfH)fzzdnGYmUg1O3fGyHrrQnugTIBgfDxQ0LwuKVtmwqTdkPCjuM5sJfSfwRD0akb3aWlkAon)okcLzU0ybBH1Ahf1O3fOyHrrQnugTIBgfnNMFhfR3Z1axVeckk6UuPlTOimgGAmQvPH1yw7GtsQnugTgG)baJbGkuRsisglBObeMdE2KuyFaE8ma1yuRsdRXS2bNKuBOmAna)dagdaRDPHYi59A1fUebnapEgaw7sdLrY71QlCjcAa(hWj0Kuteuq)aEdOeCdaQBffD(6yuqTdkP8O3LJA07YykwyuKAdLrR4Mrr3LkDPffXAxAOmsEVwDHlrqrrZP53rr4Frw2qdOmJRrn6D5YXcJIuBOmAf3mkAon)ok(OSuPZukk681XOGAhus5rVlh1Ogf5Q1l7wXcJExowyuKAdLrR4MrrZP53rXJq8hNyeNhkMTsxuCrC3L7A(DuuuTEz3Aa8SHYiKeQDqjDa3RMMFhfDxQ0LwueRDPHYi5vmGkuR8Og9gVyHrrQnugTIBgfDxQ0LwuevOwLqKmw2qdimh8Sj5rMtJIMtZVJIpklv6mLIA07cglmksTHYOvCZOO7sLU0IIyTlnugjR3Z1axVeck4(EjKkpkAon)okwVNRbUEjeuuJEJzXcJIuBOmAf3mk6UuPlTOimgWImfEaIoHcxLNqt1)GsYZkL)shna)da5bSiuHAvEwP8x6ijxnhedaMdaPdWJNbSiuHAvEwP8x6i5riSS5daMdOaoamIIMtZVJIqzMlnwWwyT2rrn6nsJfgfP2qz0kUzu0DPsxArr3)S1xSLhH4poXiopumBLo5riSS5daM4gaEdajoaOU1a8pa1yuRsOMcNUSHg46FiKuBOmAffnNMFhfR3Z1axVeckQrVXCXcJIuBOmAf3mk6UuPlTOiw7sdLrY71QlCjckkAon)okc)lYYgAaLzCnQrVlGXcJIuBOmAf3mk6UuPlTOimgaQqTkR3xkuh2fyCskSpa)dqng1QSEFPqDyxGXjj1gkJwdWJNbG1U0qzKCrMcNhwcuWCAILgG)bGkuRYfzkCEyjqsUAoigamhaMnapEgWj0Kuteuq)aMnayIBaqDROO5087O4JYsLotPOg9UaelmksTHYOvCZOO7sLU0IINqNUW(xKo5IQPl1baZbG8akJ0bSXauJrTkpHoDbtvQfmn)wsTHYO1aqIdaPdaJOO5087Oy9EUg46Lqqrn6DbkwyuKAdLrR4Mrr3LkDPffpHoDH9ViDYfvtxQdOKbG8aWdPdyJbOgJAvEcD6cMQulyA(TKAdLrRbGehashagrrZP53rXhLLkDMsrn6DzmflmkAon)okwVNRbUEjeuuKAdLrR4Mrn6D5YXcJIMtZVJIW)RdFnumBLUOi1gkJwXnJA07Y4flmkAon)okANZAkO)DuRrrQnugTIBg1OgfpZLgJhlm6D5yHrrQnugTIBgfnNMFhfrz)VcvHZ3O4I4Ul3187OOxYCPXgGxanzPMepk6UuPlTOiQqTk3tgZUWxd175QuypQrVXlwyuKAdLrR4Mrr3LkDPffrfQv5EYy2f(AOEpxLc7rrZP53rru640br2qJA07cglmksTHYOvCZOO7sLU0IIipaymauHAvUNmMDHVgQ3ZvPW(a8paZPjwkqnHij(akb3aWBaymapEgamgaQqTk3tgZUWxd175QuyFa(haYd4eAsUOA6sDaLGBaiDa(hWj0PlS)fPtUOA6sDaLGBayomnamIIMtZVJI25SMc7cmof1O3ywSWOi1gkJwXnJIUlv6slkIkuRY9KXSl81q9EUkf2JIMtZVJISekCLhqsQWckcQ1Og9gPXcJIuBOmAf3mk6UuPlTOiQqTk3tgZUWxd175QuyFa(haQqTkje7Fr6cNqtHIKT)TuypkAon)okATJ46zSGZySOg9gZflmksTHYOvCZOO7sLU0IIOc1QCpzm7cFnuVNRYJqyzZhamXnGcWa8pauHAvsi2)I0foHMcfjB)BPWEu0CA(DuSMhHY(Ff1O3fWyHrrQnugTIBgfDxQ0LwuevOwL7jJzx4RH69CvkSpa)dWCAILcutisIpaCdO8a8paKhaQqTk3tgZUWxd175Q8iew28baZbG0b4FaQXOwLUNTcWj7uj1gkJwdWJNbaJbOgJAv6E2kaNStLuBOmAna)davOwL7jJzx4RH69CvEeclB(aG5ak4aWikAon)okIAqdFnOx6GGh1OgfrFEy)Fw2qJfg9UCSWOi1gkJwXnJIMtZVJIW)ISSHgqzgxJIlI7UCxZVJIBEKPWhWxhGy2RZG(CBa7)ZYg6aUxnn)Ea(CaC1oLpGYyIpauQ(hnGnFXbK8byyTKzOmkk6UuPlTOiw7sdLrY71QlCjckQrVXlwyuKAdLrR4Mrr3LkDPffnNMyPa1eIK4dOeCdaVb4XZaoHMKAIGc6hq6aGjUba1TgG)bG1U0qzK8kgqfQvEu0CA(Du8ie)XjgX5HIzR0f1O3fmwyuKAdLrR4MrrZP53rXhLLkDMsrr3LkDPffpHoDH9ViDYfvtxQdOeCdapKgfD(6yuqTdkP8O3LJA0BmlwyuKAdLrR4Mrr3LkDPffpHoDH9ViDYfvtxQdaMdapmna)dGVtmwqTdkPCjuM5sJfSfwRD0akb3aWBa(hG7F26l2Y9KXSl81q9EUkpcHLnFaLmaKgfnNMFhfHYmxASGTWATJIA0BKglmksTHYOvCZOO5087Oy9EUg46Lqqrr3LkDPffpHoDH9ViDYfvtxQdaMdapmna)dW9pB9fB5EYy2f(AOEpxLhHWYMpGsgasJIoFDmkO2bLuE07Yrn6nMlwyuKAdLrR4Mrr3LkDPffrfQvjejJLn0acZbpBsEK50b4FaNqNUW(xKo5IQPl1buYaqEaLr6a2yaQXOwLNqNUGPk1cMMFlP2qz0AaiXbG0bGXa8pa(oXyb1oOKYL175k35RcNgqj4gaEdW)aGXaWAxAOmsUitHZdlbkyonXsrrZP53rX69CL78vHtrn6DbmwyuKAdLrR4Mrr3LkDPffpHoDH9ViDYfvtxQdOeCda5buqKoGngGAmQv5j0PlyQsTGP53sQnugTgasCaiDayma)dGVtmwqTdkPCz9EUYD(QWPbucUbG3a8paymaS2LgkJKlYu48WsGcMttSuu0CA(DuSEpx5oFv4uuJExaIfgfP2qz0kUzu0DPsxArr3)S1xSL7jJzx4RH69CvEeclB(akzaNqtsnrqb9dy2a8pGtOtxy)lsNCr10L6aG5aWmmna)dGVtmwqTdkPCjuM5sJfSfwRD0akb3aWlkAon)okcLzU0ybBH1Ahf1O3fOyHrrQnugTIBgfnNMFhfR3Z1axVeckk6UuPlTOO7F26l2Y9KXSl81q9EUkpcHLnFaLmGtOjPMiOG(bmBa(hWj0PlS)fPtUOA6sDaWCaygMIIoFDmkO2bLuE07YrnQrr7PyHrVlhlmksTHYOvCZO4I4Ul3187OOx4rYgGx6vtZVJIMtZVJIhH4poXiopumBLUOg9gVyHrrQnugTIBgfDxQ0Lwuung1QSEpx5oFv4KKAdLrROO5087OiuM5sJfSfwRDuuJExWyHrrQnugTIBgfnNMFhfR3Z1axVeckk681XOGAhus5rVlhfDxQ0Lwu09pB9fB5ri(JtmIZdfZwPtEeclB(aGjUbG3aqIdaQBna)dqng1QeQPWPlBObU(hcj1gkJwrXfXDxUR53rrKG)qiWS0naBF)EZbFa6pa3rMsdWgWoNew)a2V8Vu9DaQDqjDaSKRdO(3aS9DMVzdDaNvk)LoAazpa7POg9gZIfgfP2qz0kUzu0DPsxArrS2LgkJK3Rvx4seuu0CA(Due(xKLn0akZ4AuJEJ0yHrrQnugTIBgfDxQ0LwueRDPHYi5ImfopSeOG50elna)davOwLlYu48WsGKC1CqmayoamlkAon)ok(OSuPZukQrVXCXcJIuBOmAf3mk6UuPlTOiQqTkHizSSHgqyo4ztYJmNoa)dagdaRDPHYi5ImfopSeOG50elffnNMFhfR3ZvUZxfof1O3fWyHrrQnugTIBgfDxQ0Lwu8e60f2)I0jxunDPoayoaKhqzKoGngGAmQv5j0PlyQsTGP53sQnugTgasCafCayefnNMFhfHYmxASGTWATJIA07cqSWOi1gkJwXnJIMtZVJI175AGRxcbffDxQ0Lwu8e60f2)I0jxunDPoayoaKhqzKoGngGAmQv5j0PlyQsTGP53sQnugTgasCaiDayefD(6yuqTdkP8O3LJA07cuSWOi1gkJwXnJIUlv6slkcJbG1U0qzKCrMcNhwcuWCAILIIMtZVJI175k35RcNIA07YykwyuKAdLrR4MrrZP53rXhLLkDMsrr3LkDPffpHoDH9ViDYfvtxQdOKbG8aWdPdyJbOgJAvEcD6cMQulyA(TKAdLrRbGehashagrrNVogfu7Gskp6D5Og9UC5yHrrZP53rrOmZLglylSw7OOi1gkJwXnJA07Y4flmksTHYOvCZOO5087Oy9EUg46LqqrrNVogfu7Gskp6D5Og9UCbJfgfnNMFhfH)xh(AOy2kDrrQnugTIBg1O3LXSyHrrZP53rr7Cwtb9VJAnksTHYOvCZOg1O4IQMatJfg9UCSWOO5087OiISxH6ruPqrrQnugTIBg1O34flmksTHYOvCZO4Vhf5KgfnNMFhfXAxAOmkkI1ycuue5bqfyHCFNwYS5UtqnugfkWcwRciclcB6Ob4FaU)zRVylZM7ob1qzuOalyTkGiSiSPJKhzlFhagrXfXDxUR53rrKWJWsToa(o5YAsRbOx2qqkFaOu2qhGaNwdOyQWhGjOpctt3ayzt8Oiw7cTHGII8DYL1Kwb9YgcsJA07cglmksTHYOvCZO4Vhf5KgfnNMFhfXAxAOmkkI1ycuu0CAILcutisIpaCdO8a8paKhWz5kqyPwL2AXLzpGsgqzKoapEgamgWz5kqyPwL2AXLKxtUYhagrrS2fAdbff5AyNzDNn0Og9gZIfgfP2qz0kUzu83JICsJIMtZVJIyTlnugffXAmbkkAonXsbQjejXhqj4gaEdW)aqEaWyaNLRaHLAvARfxsEn5kFaE8mGZYvGWsTkT1IljVMCLpa)da5bCwUcewQvPTwC5riSS5dOKbG0b4XZaQju4A4iew28buYakJPbGXaWikI1UqBiOOOTw8WriSSJA0BKglmksTHYOvCZO4Vhf5KgfnNMFhfXAxAOmkkI1ycuuevOwLxIGKc7dW)aqEaWyaNqt1)GsYZGsHVgu4uOEFPqDWb3qSNFlP2qz0AaE8mGtOP6Fqj5zqPWxdkCkuVVuOo4GBi2ZVLuBOmAna)d4e60f2)I0jxunDPoGsgqbyayefXAxOneuu8ET6cxIGIA0BmxSWOi1gkJwXnJI)EuKtAu0CA(DueRDPHYOOiwJjqrr33lHuL0zR0zA2qdOSV4a8pauHAvsNTsNPzdnGY(IsUAoigaUbG3a84zaUVxcPkfAgzC40kupQlfFLuBOmAna)davOwLcnJmoCAfQh1LIVYJqyzZhamhaYdaQBnaK4aWBayefXAxOneuuSEpxdC9siOG77LqQ8Og9UaglmksTHYOvCZO4Vhf5KgfnNMFhfXAxAOmkkI1ycuuCrMcpy9kSiN5RuthezdDa(hG7XsT1QStOW1q1OOiw7cTHGIIlYu48WsGcMttSuuJExaIfgfP2qz0kUzu0CA(Du8ie)XjgX5HIzR0ffxe3D5UMFhf9c77mFhasW9CDaibew6WFaiSSvl7bG5D(oGcn238by9Aaqq0(a8seI)4eJ48bGKNTs3aUNXYgAu0DPsxArr33lHuLew6Q3Z1b4FaQXOwLqnfoDzdnW1)qiP2qz0Aa(hamgGAmQv5JYsLotZVLuBOmAna)dW9pB9fB5EYy2f(AOEpxLhHWYMh1O3fOyHrrQnugTIBgfnNMFhfH)fzzdnGYmUgfDxQ0LwuC9QSEpxdvclDYJQhXHBOmAa(haYdqng1QmDKZ2LuBOmAnapEgamgaQqTkrpYu4HVg4zVod6ZnPW(a8pa1yuRs0JmfE4RbE2RZG(CtsTHYO1a84zaQXOwLpklv6mn)wsTHYO1a8pa3)S1xSL7jJzx4RH69CvEeclB(a8paymauHAvcrYyzdnGWCWZMKc7daJOOZxhJcQDqjLh9UCuJExgtXcJIuBOmAf3mk6UuPlTOiQqTktNVb1yFZLhHWYMpayIBaqDRb4FaOc1QmD(guJ9nxkSpa)dGVtmwqTdkPCjuM5sJfSfwRD0akb3aWBa(haYdagdqng1Qe9itHh(AGN96mOp3KuBOmAnapEgG7F26l2s0JmfE4RbE2RZG(CtEeclB(akzaLr6aWikAon)okcLzU0ybBH1Ahf1O3LlhlmksTHYOvCZOO7sLU0IIOc1QmD(guJ9nxEeclB(aGjUba1TgG)bGkuRY05Bqn23CPW(a8paKhamgGAmQvj6rMcp81ap71zqFUjP2qz0AaE8maymauHAvIEKPWdFnWZEDg0NBsH9b4FaU)zRVylrpYu4HVg4zVod6Zn5riSS5dOKbugtdaJOO5087Oy9EUg46Lqqrn6Dz8IfgfP2qz0kUzuCrC3L7A(Du0hW)NtdWl4087bWsUoa9hWj0rrZP53rrNXybZP53bwY1Oil5AOneuu09yP2ALh1O3LlySWOi1gkJwXnJIMtZVJIoJXcMtZVdSKRrrwY1qBiOO4zU0y8Og9UmMflmksTHYOvCZOO5087OOZySG5087al5AuKLCn0gckkQx2qqkpQrVlJ0yHrrQnugTIBgfnNMFhfDgJfmNMFhyjxJISKRH2qqrr3)S1xS5rn6DzmxSWOi1gkJwXnJIUlv6slkQgJAv6E2kaNStLuBOmAna)da5baJbGkuRsisglBObeMdE2KuyFaE8ma1yuRs0JmfE4RbE2RZG(CtsTHYO1aWya(haYdyrOc1Q8Ss5V0rsUAoigaUbG0b4XZaGXawKPWdq0ju4Q8eAQ(husEwP8x6ObGru0CA(Du0zmwWCA(DGLCnkYsUgAdbffDpBfGt2Prn6D5cySWOi1gkJwXnJIUlv6slkIkuRs0JmfE4RbE2RZG(CtkShfnNMFhfpHoyon)oWsUgfzjxdTHGIIOppOPdISHg1O3LlaXcJIuBOmAf3mk6UuPlTOOAmQvj6rMcp81ap71zqFUjP2qz0Aa(haYdW9pB9fBj6rMcp81ap71zqFUjpcHLnFaWCaLX0aWya(haYd4SCfiSuRsBT4YShqjdapKoapEgamgWz5kqyPwL2AXLKxtUYhGhpdW9pB9fB5EYy2f(AOEpxLhHWYMpayoGYyAa(hWz5kqyPwL2AXLKxtUYhG)bCwUcewQvPTwCz2daMdOmMgagrrZP53rXtOdMtZVdSKRrrwY1qBiOOi6Zd7)ZYgAuJExUaflmksTHYOvCZOO7sLU0IIOc1QCpzm7cFnuVNRsH9b4FaQXOwLpklv6mn)wsTHYOvu0CA(Du8e6G5087al5AuKLCn0gckk(OSuPZ087Og9gpmflmksTHYOvCZOO7sLU0IIQXOwLpklv6mn)wsTHYO1a8pa3)S1xSL7jJzx4RH69CvEeclB(aG5akJPb4FaipaS2LgkJKCnSZSUZg6a84zaNLRaHLAvARfxsEn5kFa(hWz5kqyPwL2AXLzpayoGYyAaE8maymGZYvGWsTkT1IljVMCLpamIIMtZVJINqhmNMFhyjxJISKRH2qqrXhLLkDMMFh2)NLn0Og9gVYXcJIuBOmAf3mk6UuPlTOO50elfOMqKeFaLGBa4ffnNMFhfpHoyon)oWsUgfzjxdTHGII2trn6nE4flmksTHYOvCZOO5087OOZySG5087al5AuKLCn0gckkYvRx2TIAuJI7h5EeOMglm6D5yHrrQnugTIBgf)9OiN0SgfDxQ0LwuuVSHGuPwwc34bbofqfQ1b4Faipayma1yuRs0JmfE4RbE2RZG(CtsTHYO1a8paKhGEzdbPsTS09pB9fB5s4mn)EaE5b4(NT(ITCpzm7cFnuVNRYLWzA(9aWnamnamgGhpdqng1Qe9itHh(AGN96mOp3KuBOmAna)da5b4(NT(ITe9itHh(AGN96mOp3KlHZ087b4LhGEzdbPsTS09pB9fB5s4mn)Ea4gaMgagdWJNbOgJAvMoYz7sQnugTgagrXfXDxUR53rrKmSgtWuIpaBa6LneKYhG7F26l24pGvInx0AaO(oG9KXSBaFDa1756a(BaOhzk8b81bWZEDg0NBB5dW9pB9fB5aW81bK6w(aWAmbAaWn(a6FahHWYEr3aosfUEaLXFaeJtd4iv46bGjjsLrrS2fAdbff1lBiinuoW9TDrrZP53rrS2LgkJIIynMafigNIIysI0OiwJjqrXYrn6nEXcJIuBOmAf3mk(7rroPznkAon)okI1U0qzuueRDH2qqrr9Ygcsd4f4(2UOO7sLU0II6LneKkv8KWnEqGtbuHADa(haYdagdqng1Qe9itHh(AGN96mOp3KuBOmAna)da5bOx2qqQuXt6(NT(ITCjCMMFpaV8aC)ZwFXwUNmMDHVgQ3Zv5s4mn)Ea4gaMgagdWJNbOgJAvIEKPWdFnWZEDg0NBsQnugTgG)bG8aC)ZwFXwIEKPWdFnWZEDg0NBYLWzA(9a8YdqVSHGuPIN09pB9fB5s4mn)Ea4gaMgagdWJNbOgJAvMoYz7sQnugTgagrrSgtGceJtrrmjrAueRXeOOy5Og9UGXcJIuBOmAf3mk(7rroPznk6UuPlTOimgGEzdbPsTSeUXdcCkGkuRdW)a0lBiivQ4jHB8GaNcOc16a84za6LneKkv8KWnEqGtbuHADa(haYda5bOx2qqQuXt6(NT(ITCjCMMFpayna9YgcsLkEsuHAnSeotZVhagdajoaKhqzjshWgdqVSHGuPINeUXdOc1QKRh1qv4daJbGehaYdaRDPHYiPEzdbPb8cCFB3aWyaymGsgaYda5bOx2qqQullD)ZwFXwUeotZVhaSgGEzdbPsTSevOwdlHZ087bGXaqIda5buwI0bSXa0lBiivQLLWnEavOwLC9OgQcFaymaK4aqEayTlnugj1lBiinuoW9TDdaJbGruCrC3L7A(DuejJRjctj(aSbOx2qqkFaynManauFhG7rSBx2qhGcNgG7F26l2d4RdqHtdqVSHGu8hWkXMlAnauFhGcNgWs4mn)EaFDakCAaOc16asDa73JnxexoaVOgFa2a46rnuf(aq8RSM0na9ha0elnaBaWtOWPBa7x(xQ(oa9haxpQHQWhGEzdbPC8hGXhqrIXgGXhGnae)kRjDdO(3aY6aSbOx2qq6akMm2a(BaftgBa9RdG7B7gqXuHpa3)S1xS5YOiw7cTHGII6LneKg2V8Vu9nkAon)okI1U0qzuueRXeOaX4uuSCueRXeOOiErn6nMflmksTHYOvCZO4Vhf5KgfnNMFhfXAxAOmkkI1ycuuung1QeQPWPlBObU(hcj1gkJwdWJNb4(EjKQKWsx9EUkP2qz0AaE8mGtOP6FqjjAQzdn4E2ssTHYOvueRDH2qqrXRyavOw5rn6nsJfgfnNMFhfRmId3DwvJIuBOmAf3mQrnk6(NT(Inpwy07YXcJIuBOmAf3mk6UuPlTOiQqTk3tgZUWxd175QuypkUiU7YDn)okIe(A(Du0CA(DuC)187Og9gVyHrrQnugTIBgfnNMFhfje7Fr6cNqtHIKT)DuCrC3L7A(Du0h)ZwFXMhfDxQ0Lwuung1Q8rzPsNP53sQnugTgG)bCcnnayoam3a8paKhaw7sdLrsUg2zw3zdDaE8maS2LgkJK2AXdhHWYEayma)da5b4(NT(ITCpzm7cFnuVNRYJqyzZhamhashG)bG8aC)ZwFXwwzehU7SQkpcHLnFaLmaKoa)dG)cm0SxYDbUkWOaDc7A(TKAdLrRb4XZaGXa4Vadn7LCxGRcmkqNWUMFlP2qz0AaymapEgaQqTk3tgZUWxd175QuyFaymapEga6Z5dW)aQju4A4iew28baZbGhMIA07cglmksTHYOvCZOO7sLU0IIQXOwLOhzk8Wxd8SxNb95MKAdLrRb4FaNqNUW(xKo5IQPl1buYakiMgG)bCcnj1ebf0pG0buYaG6wdW)aqEaOc1Qe9itHh(AGN96mOp3Kc7dWJNbutOW1WriSS5daMdapmnamIIMtZVJIeI9ViDHtOPqrY2)oQrVXSyHrrQnugTIBgfDxQ0Lwuung1QmDKZ2LuBOmAffnNMFhfje7Fr6cNqtHIKT)DuJEJ0yHrrQnugTIBgfDxQ0Lwuung1Qe9itHh(AGN96mOp3KuBOmAna)da5bG1U0qzKKRHDM1D2qhGhpdaRDPHYiPTw8WriSShagdW)aqEaU)zRVylrpYu4HVg4zVod6Zn5riSS5dWJNb4(NT(ITe9itHh(AGN96mOp3KhzlFhG)bCcD6c7Fr6KlQMUuhamhasX0aWikAon)okUNmMDHVgQ3Z1Og9gZflmksTHYOvCZOO7sLU0IIQXOwLPJC2UKAdLrRb4FaWyaOc1QCpzm7cFnuVNRsH9OO5087O4EYy2f(AOEpxJA07cySWOi1gkJwXnJIUlv6slkQgJAv(OSuPZ08Bj1gkJwdW)aqEayTlnugj5AyNzDNn0b4XZaWAxAOmsARfpCecl7bGXa8paKhGAmQvjutHtx2qdC9pesQnugTgG)bGkuRYJq8hNyeNhkMTsNuyFaE8mayma1yuRsOMcNUSHg46FiKuBOmAnamIIMtZVJI7jJzx4RH69CnQrVlaXcJIuBOmAf3mk6UuPlTOiQqTk3tgZUWxd175QuypkAon)okIEKPWdFnWZEDg0NBrn6DbkwyuKAdLrR4Mrr3LkDPffnNMyPa1eIK4da3akpa)davOwL7jJzx4RH69CvEeclB(aG5aG6wdW)aqfQv5EYy2f(AOEpxLc7dW)aGXauJrTkFuwQ0zA(TKAdLrRb4FaipaymGZYvGWsTkT1IljVMCLpapEgWz5kqyPwL2AXLzpGsgqbX0aWyaE8mGAcfUgocHLnFaWCafmkAon)okwVNRf99qWdvHZ3Og9UmMIfgfP2qz0kUzu0DPsxArrZPjwkqnHij(akb3aWBa(haYdavOwL7jJzx4RH69CvkSpapEgWz5kqyPwL2AXLzpGsgG7F26l2Y9KXSl81q9EUkpcHLnFayma)da5bGkuRY9KXSl81q9EUkpcHLnFaWCaqDRb4XZaolxbcl1Q0wlU8iew28baZba1TgagrrZP53rX69CTOVhcEOkC(g1O3LlhlmksTHYOvCZOO7sLU0IIQXOwLpklv6mn)wsTHYO1a8pauHAvUNmMDHVgQ3ZvPW(a8paKhaYdavOwL7jJzx4RH69CvEeclB(aG5aG6wdWJNbGkuRsHg(Z8nW1JAOkCPW(a8pauHAvk0WFMVbUEudvHlpcHLnFaWCaqDRbGXa8paKhWIqfQv5zLYFPJKC1CqmaCdaPdWJNbaJbSitHhGOtOWv5j0u9pOK8Ss5V0rdaJbGru0CA(DuSEpxl67HGhQcNVrn6Dz8IfgfP2qz0kUzu0DPsxArr1yuRs0JmfE4RbE2RZG(CtsTHYO1a8pGtOtxy)lsNCr10L6akzaygMgG)bCcnnayIBafCa(haYdavOwLOhzk8Wxd8SxNb95MuyFaE8ma3)S1xSLOhzk8Wxd8SxNb95M8iew28buYaWmmnamgGhpdagdqng1Qe9itHh(AGN96mOp3KuBOmAna)d4e60f2)I0jxunDPoGsWna8qAu0CA(DueUV7VcNoePlSFeNAhf1O3LlySWOi1gkJwXnJIUlv6slk6(NT(ITCpzm7cFnuVNRYJqyzZhamXnaKgfnNMFhfpl5uyr2kQrVlJzXcJIuBOmAf3mk6UuPlTOO50elfOMqKeFaLGBa4na)da5bG(C(a8pGAcfUgocHLnFaWCafCaE8maymauHAvIEKPWdFnWZEDg0NBsH9b4FaipGDsLqH)cm5riSS5daMdaQBnapEgWz5kqyPwL2AXLhHWYMpayoGcoa)d4SCfiSuRsBT4YShqjdyNuju4VatEeclB(aWyayefnNMFhf5M7YA6sJf2nNg1O3LrASWOi1gkJwXnJIUlv6slkAonXsbQjejXhqjdaPdWJNbCcnv)dkj3Ht29i(M4sQnugTIIMtZVJIlYu4bRxHf5mFJAuJI6LneKYJfg9UCSWOi1gkJwXnJIMtZVJIzZDNGAOmkuGfSwfqewe20rrXfXDxUR53rXcVSHGuEu0DPsxArruHAvUNmMDHVgQ3ZvPW(a84zaQDqjvQjckOFy3Pb8W0aG5aq6a84zaOpNpa)dOMqHRHJqyzZhamhaELJA0B8IfgfP2qz0kUzu0CA(DuuVSHG0YrXfXDxUR53rXcHtdqVSHG0bumv4dqHtdaEcfoX1bqCnrykTgawJjq4pGIjJnauAacCAnGAECDawVgWULhTgqXuHpaKWKXSBaFDaib3Zvzu0DPsxArrymaS2LgkJK8DYL1Kwb9YgcshG)bGkuRY9KXSl81q9EUkf2hG)bG8aGXauJrTkth5SDj1gkJwdWJNbOgJAvMoYz7sQnugTgG)bGkuRY9KXSl81q9EUkpcHLnFaLGBaLX0aWya(haYdagdqVSHGuPINeUXdU)zRVypapEgGEzdbPsfpP7F26l2YJqyzZhGhpdaRDPHYiPEzdbPH9l)lvFhaUbuEaymapEgGEzdbPsTSevOwdlHZ087bucUbutOW1WriSS5rn6DbJfgfP2qz0kUzu0DPsxArrymaS2LgkJK8DYL1Kwb9YgcshG)bGkuRY9KXSl81q9EUkf2hG)bG8aGXauJrTkth5SDj1gkJwdWJNbOgJAvMoYz7sQnugTgG)bGkuRY9KXSl81q9EUkpcHLnFaLGBaLX0aWya(haYdagdqVSHGuPwwc34b3)S1xShGhpdqVSHGuPww6(NT(IT8iew28b4XZaWAxAOmsQx2qqAy)Y)s13bGBa4namgGhpdqVSHGuPINevOwdlHZ087bucUbutOW1WriSS5rrZP53rr9YgcsXlQrVXSyHrrQnugTIBgfnNMFhf1lBiiTCuCrC3L7A(DueZxhW3mFhW30a(EacCAa6LneKoG97XMlIpaBaOc1k(dqGtdqHtd4v40nGVhG7F26l2YbGKEdiRdOPuHt3a0lBiiDa73JnxeFa2aqfQv8hGaNga6RWhW3dW9pB9fBzu0DPsxArryma9YgcsLAzjCJhe4uavOwhG)bG8a0lBiivQ4jD)ZwFXwEeclB(a84zaWya6LneKkv8KWnEqGtbuHADaymapEgG7F26l2Y9KXSl81q9EUkpcHLnFaLma8WuuJEJ0yHrrQnugTIBgfDxQ0LwuegdqVSHGuPINeUXdcCkGkuRdW)aqEa6LneKk1Ys3)S1xSLhHWYMpapEgamgGEzdbPsTSeUXdcCkGkuRdaJb4XZaC)ZwFXwUNmMDHVgQ3Zv5riSS5dOKbGhMIIMtZVJI6LneKIxuJAu09yP2ALhlm6D5yHrrQnugTIBgfnNMFhfxKPW5HLaffxe3D5UMFhf9XJLAR1b4fqtwQjXJIUlv6slkI1U0qzKKRHDM1D2qhGhpdaRDPHYiPTw8WriSSJA0B8IfgfP2qz0kUzu0DPsxArXtOtxy)lsNCr10L6akzaLl4a8pa3)S1xSL7jJzx4RH69CvEeclB(aG5ak4a8payma1yuRs0JmfE4RbE2RZG(CtsTHYO1a8paS2LgkJKCnSZSUZgAu0CA(DuKx0oezdnGi5AuJExWyHrrQnugTIBgfDxQ0Lwuegdqng1Qe9itHh(AGN96mOp3KuBOmAna)daRDPHYiPTw8WriSSJIMtZVJI8I2HiBObejxJA0BmlwyuKAdLrR4Mrr3LkDPffvJrTkrpYu4HVg4zVod6Znj1gkJwdW)aqEaOc1Qe9itHh(AGN96mOp3Kc7dW)aqEayTlnugj5AyNzDNn0b4FaNqNUW(xKo5IQPl1buYaWmmnapEgaw7sdLrsBT4HJqyzpa)d4e60f2)I0jxunDPoGsgaMdtdWJNbG1U0qzK0wlE4iew2dW)aolxbcl1Q0wlU8iew28baZbuGgagdWJNbaJbGkuRs0JmfE4RbE2RZG(CtkSpa)dW9pB9fBj6rMcp81ap71zqFUjpcHLnFayefnNMFhf5fTdr2qdisUg1O3inwyuKAdLrR4Mrr3LkDPffD)ZwFXwUNmMDHVgQ3Zv5riSS5daMdOGdW)aWAxAOmsY1WoZ6oBOdW)aqEaQXOwLOhzk8Wxd8SxNb95MKAdLrRb4FaNqNUW(xKo5IQPl1baZbG5W0a8pa3)S1xSLOhzk8Wxd8SxNb95M8iew28baZbG3a84zaWyaQXOwLOhzk8Wxd8SxNb95MKAdLrRbGru0CA(Du0qFezBA(DGLiqJA0BmxSWOi1gkJwXnJIUlv6slkI1U0qzK0wlE4iew2rrZP53rrd9rKTP53bwIanQrVlGXcJIuBOmAf3mk6UuPlTOiw7sdLrsUg2zw3zdDa(haYdW9pB9fB5EYy2f(AOEpxLhHWYMpayoGcoapEgGAmQvz6iNTlP2qz0AayefnNMFhf5WnhemkOWPGqx8pfUVrn6DbiwyuKAdLrR4Mrr3LkDPffXAxAOmsARfpCecl7OO5087OihU5GGrbfofe6I)PW9nQrVlqXcJIuBOmAf3mk6UuPlTOimgaQqTk3tgZUWxd175QuyFa(hamgaQqTkrpYu4HVg4zVod6ZnPW(a8paKha)fyOzVK7cCvGrb6e218Bj1gkJwdWJNbWFbgA2lj2NzAYOa)zyPwLuBOmAnamIIzR0Dc7AiRrr(lWqZEjX(mttgf4pdl1AumBLUtyxdjce0knLIILJIMtZVJIvgXH7oRQrXSv6oHDnaL9OglkwoQrnkI(8GMoiYgASWO3LJfgfP2qz0kUzu0CA(Du8rzPsNPuu05RJrb1oOKYJExok6UuPlTO4j0PlS)fPtUOA6sDaLGBaipamdPdyJbOgJAvEcD6cMQulyA(TKAdLrRbGehashagrXfXDxUR53rXnpYu4d4Rdqm71zqFUnaVGttS0a8sVAA(DuJEJxSWOi1gkJwXnJIUlv6slkI1U0qzK8kgqfQv(a84zaMttSuGAcrs8bucUbG3a84zaNqNUW(xKUbaZbuq8IIMtZVJIhH4poXiopumBLUOg9UGXcJIuBOmAf3mk6UuPlTO4j0PlS)fPBaWCafeVOO5087O4ImfEW6vyroZ3Og9gZIfgfP2qz0kUzu0DPsxArrS2LgkJK3Rvx4se0a8paKhWj0PlS)fPtUOA6sDaWCaifPdWJNbCcnj1ebf0puWbatCdaQBnapEgWj0u9pOK8mOu4RbfofQ3xkuhCWne753sQnugTgGhpdGVtmwqTdkPCj8VilBObuMX1bucUbG3aWyaE8mGtOtxy)ls3aG5akiErrZP53rr4Frw2qdOmJRrn6nsJfgfP2qz0kUzu0DPsxArruHAvcrYyzdnGWCWZMKc7dW)a47eJfu7GskxwVNRCNVkCAaLGBa4na)dagdaRDPHYi5ImfopSeOG50elffnNMFhfR3ZvUZxfof1O3yUyHrrQnugTIBgfDxQ0Lwu8e60f2)I0jxunDPoGsWnamdtdW)aoHMKAIGc6hk4akzaqDROO5087Oi8)6WxdfZwPlQrVlGXcJIuBOmAf3mk6UuPlTOiFNySGAhus5Y69CL78vHtdOeCdaVb4FaWyayTlnugjxKPW5HLafmNMyPOO5087Oy9EUYD(QWPOg9UaelmksTHYOvCZOO5087O4JYsLotPOO7sLU0IINqNUW(xKo5IQPl1buYaWdPdWJNbCcnj1ebf0puWbaZba1TIIoFDmkO2bLuE07Yrn6DbkwyuKAdLrR4Mrr3LkDPffXAxAOmsEVwDHlrqrrZP53rr4Frw2qdOmJRrn6DzmflmksTHYOvCZOO7sLU0IINqNUW(xKo5IQPl1buYaqkMIIMtZVJI25SMc6Fh1AuJAuJIyPJNFh9gpmHxzmvaXRafflAxNnuEuej3l4L8gZ7TxSphWakeonGeX(F6aQ)nGTUNTcWj70Td4OcSqE0Aa8hbnatqFeMsRb4GBnuIlhilD20ak7Zb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaix2RyihilD20aWZNdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqUSxXqoqw6SPbuqFoaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTda5YEfd5azPZMgaM5Zb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaix2RyihihirY9cEjVX8E7f7ZbmGcHtdirS)NoG6Fdy7JYsLotZV3oGJkWc5rRbWFe0amb9rykTgGdU1qjUCGS0ztdOa5Zb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaiJNxXqoqoqIK7f8sEJ592l2NdyafcNgqIy)pDa1)gWw0Nh00br2q3oGJkWc5rRbWFe0amb9rykTgGdU1qjUCGS0ztdOSphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGCzVIHCGS0ztdaZ85a8X3yPtP1a2Ecnv)dkjH92bO)a2Ecnv)dkjHTKAdLrRTda5YEfd5a5ajsUxWl5nM3BVyFoGbuiCAajI9)0bu)BaBDpwQTw5BhWrfyH8O1a4pcAaMG(imLwdWb3AOexoqw6SPbGNphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGCzVIHCGS0ztdOG(Ca(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaYL9kgYbYsNnnamZNdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqUSxXqoqw6SPbGuFoaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdaz88kgYbYsNnnGcOphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGCzVIHCGS0ztdOa5Zb4JVXsNsRbSL)cm0SxsyVDa6pGT8xGHM9scBj1gkJwBhaY45vmKdKdKi5EbVK3yEV9I95agqHWPbKi2)thq9VbSLRwVSBTDahvGfYJwdG)iObyc6JWuAnahCRHsC5azPZMgas95a8X3yPtP1a2QgJAvc7Tdq)bSvng1Qe2sQnugT2oathasgsAPhaYL9kgYbYsNnnGcOphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGCzVIHCGS0ztdOa4Zb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaix2RyihilD20akq(Ca(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaYL9kgYbYbsKCVGxYBmV3EX(CadOq40ase7)PdO(3a2I(8W()SSHUDahvGfYJwdG)iObyc6JWuAnahCRHsC5azPZMgaMZNdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqUSxXqoqw6SPbua95a8X3yPtP1a2QgJAvc7Tdq)bSvng1Qe2sQnugT2oaKl7vmKdKdKi5EbVK3yEV9I95agqHWPbKi2)thq9VbSD)i3Ja10Td4OcSqE0Aa8hbnatqFeMsRb4GBnuIlhilD20ak7Zb4JVXsNsRbiMi8Xa4(2Q51b4L9Ydq)buAbBai(LatGpGFNot)Bai7LXyaiJNxXqoqw6SPbu2NdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqUGEfd5azPZMgqzFoaF8nw6uAnGT6LneKkllH92bO)a2Qx2qqQullH92bGCb9kgYbYsNnna885a8X3yPtP1aete(yaCFB186a8YE5bO)akTGnae)sGjWhWVtNP)naK9YymaKXZRyihilD20aWZNdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqUGEfd5azPZMgaE(Ca(4BS0P0AaB1lBiivINe2BhG(dyREzdbPsfpjS3oaKlOxXqoqw6SPbuqFoaF8nw6uAnaXeHpga33wnVoaV8a0FaLwWgWkXM887b870z6FdazyHXaqgpVIHCGS0ztdOG(Ca(4BS0P0AaB1lBiivwwc7Tdq)bSvVSHGuPwwc7TdazmZRyihilD20akOphGp(glDkTgWw9YgcsL4jH92bO)a2Qx2qqQuXtc7TdazK6vmKdKLoBAayMphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGCzVIHCGS0ztdaZ85a8X3yPtP1a2Ecnv)dkjH92bO)a2Ecnv)dkjHTKAdLrRTdW0bGKHKw6bGCzVIHCGS0ztdaZ85a8X3yPtP1a26(EjKQe2BhG(dyR77LqQsylP2qz0A7aqUSxXqoqoqIK7f8sEJ592l2NdyafcNgqIy)pDa1)gWw3)S1xS5BhWrfyH8O1a4pcAaMG(imLwdWb3AOexoqw6SPbGNphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGCzVIHCGS0ztdapFoaF8nw6uAnGT8xGHM9sc7Tdq)bSL)cm0SxsylP2qz0A7aqgpVIHCGS0ztdOG(Ca(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaYL9kgYbYsNnnamZNdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7amDaiziPLEaix2RyihilD20aqQphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGCzVIHCGS0ztdaZ5Zb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaix2RyihilD20akG(Ca(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaYL9kgYbYsNnnGcKphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGCzVIHCGS0ztdOCzFoaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTda5YEfd5azPZMgqz885a8X3yPtP1a2QgJAvc7Tdq)bSvng1Qe2sQnugT2oaKXZRyihilD20akJuFoaF8nw6uAnGTNqt1)GssyVDa6pGTNqt1)GssylP2qz0A7amDaiziPLEaix2RyihihirY9cEjVX8E7f7ZbmGcHtdirS)NoG6FdyREzdbP8Td4OcSqE0Aa8hbnatqFeMsRb4GBnuIlhilD20aWZNdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqgpVIHCGS0ztdapFoaF8nw6uAnGT6LneKkllH92bO)a2Qx2qqQullH92bGCzVIHCGS0ztdapFoaF8nw6uAnGT6LneKkXtc7Tdq)bSvVSHGuPINe2BhaY45vmKdKLoBAaf0NdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqgpVIHCGS0ztdOG(Ca(4BS0P0AaB1lBiivwwc7Tdq)bSvVSHGuPwwc7Tdaz88kgYbYsNnnGc6Zb4JVXsNsRbSvVSHGujEsyVDa6pGT6LneKkv8KWE7aqUSxXqoqw6SPbGz(Ca(4BS0P0AaB1lBiivwwc7Tdq)bSvVSHGuPwwc7Tda5YEfd5azPZMgaM5Zb4JVXsNsRbSvVSHGujEsyVDa6pGT6LneKkv8KWE7aqgpVIHCGS0ztdaP(Ca(4BS0P0AaB1lBiivwwc7Tdq)bSvVSHGuPwwc7Tdaz88kgYbYsNnnaK6Zb4JVXsNsRbSvVSHGujEsyVDa6pGT6LneKkv8KWE7aqUSxXqoqoqIK7f8sEJ592l2NdyafcNgqIy)pDa1)gW2fvnbMUDahvGfYJwdG)iObyc6JWuAnahCRHsC5azPZMgas95a8X3yPtP1a2Ecnv)dkjH92bO)a2Ecnv)dkjHTKAdLrRTdaz88kgYbYsNnnamNphGp(glDkTgWw33lHuLWE7a0FaBDFVesvcBj1gkJwBhaYL9kgYbYsNnnGcGphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGmEEfd5azPZMgqbYNdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqUGEfd5azPZMgqzm5Zb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaix2RyihilD20akx2NdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqUSxXqoqw6SPbugZ5Zb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaiJNxXqoqw6SPbuUa4Zb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaix2RyihilD20akxG85a8X3yPtP1a2QgJAvc7Tdq)bSvng1Qe2sQnugT2oathasgsAPhaYL9kgYbYsNnna8WKphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12bGCzVIHCGCGej3l4L8gZ7TxSphWakeonGeX(F6aQ)nGT2tBhWrfyH8O1a4pcAaMG(imLwdWb3AOexoqw6SPbGNphGp(glDkTgWw1yuRsyVDa6pGTQXOwLWwsTHYO12by6aqYqsl9aqUSxXqoqw6SPbuqFoaF8nw6uAnGTQXOwLWE7a0FaBvJrTkHTKAdLrRTdW0bGKHKw6bGCzVIHCGS0ztdOa6Zb4JVXsNsRbSvng1Qe2BhG(dyRAmQvjSLuBOmATDaix2RyihilD20aka(Ca(4BS0P0AaBvJrTkH92bO)a2QgJAvcBj1gkJwBhaYL9kgYbYsNnnGYyYNdWhFJLoLwdyRAmQvjS3oa9hWw1yuRsylP2qz0A7aqUSxXqoqoqI5rS)NsRbuUGdWCA(9ayjx5YbYO4(91KrrXsTuhGxeYu4daj5oHcxhasW9CDGSul1b4feGkW1bug)bGhMWR8a5azPwQdWhWTgkXhil1sDaijgGxIq8yP1aygxrsWj33RbiWnO0a(6a8bClB(a(6aW8oAagFaPoG1t8ERoGDM57aksm2aYEa7N500rYbYsTuhasIb4f57T6aCWTUj2aqcyehU7SQoGLWLn0bS5rMcFaFDaIzVod6Zn5a5azPoaKmSgtWuIpaBa6LneKYhG7F26l24pGvInx0AaO(oG9KXSBaFDa1756a(BaOhzk8b81bWZEDg0NBB5dW9pB9fB5aW81bK6w(aWAmbAaWn(a6FahHWYEr3aosfUEaLXFaeJtd4iv46bGjjsLdKMtZV5Y9JCpcut3ahSWAxAOmc)2qq40lBiinuoW9TD4)744KMv8XAmbcxz8XAmbkqmoHdtsKIV77vQ5340lBiivwwc34bbofqfQv)idd1yuRs0JmfE4RbE2RZG(CZpY6LneKkllD)ZwFXwUeotZV9YEz3)S1xSL7jJzx4RH69CvUeotZVXHjm84rng1Qe9itHh(AGN96mOp38JS7F26l2s0JmfE4RbE2RZG(CtUeotZV9YEz9YgcsLLLU)zRVylxcNP534WegE8OgJAvMoYz7ymqAon)Ml3pY9iqnDdCWcRDPHYi8BdbHtVSHG0aEbUVTd)FhhN0SIpwJjq4kJpwJjqbIXjCysIu8DFVsn)gNEzdbPs8KWnEqGtbuHA1pYWqng1Qe9itHh(AGN96mOp38JSEzdbPs8KU)zRVylxcNP53EzVS7F26l2Y9KXSl81q9EUkxcNP534WegE8OgJAvIEKPWdFnWZEDg0NB(r29pB9fBj6rMcp81ap71zqFUjxcNP53EzVSEzdbPs8KU)zRVylxcNP534WegE8OgJAvMoYz7ymqwQdajJRjctj(aSbOx2qqkFaynManauFhG7rSBx2qhGcNgG7F26l2d4RdqHtdqVSHGu8hWkXMlAnauFhGcNgWs4mn)EaFDakCAaOc16asDa73JnxexoaVOgFa2a46rnuf(aq8RSM0na9ha0elnaBaWtOWPBa7x(xQ(oa9haxpQHQWhGEzdbPC8hGXhqrIXgGXhGnae)kRjDdO(3aY6aSbOx2qq6akMm2a(BaftgBa9RdG7B7gqXuHpa3)S1xS5YbsZP53C5(rUhbQPBGdwyTlnugHFBiiC6LneKg2V8Vu9f)FhhN0SIpwJjq4WdFSgtGceJt4kJV77vQ534GHEzdbPYYs4gpiWPaQqT6xVSHGujEs4gpiWPaQqT6XJEzdbPs8KWnEqGtbuHA1pYiRx2qqQepP7F26l2YLWzA(TxwVSHGujEsuHAnSeotZVXajICzjs3qVSHGujEs4gpGkuRsUEudvHJbsezS2LgkJK6LneKgWlW9TDyGrjiJSEzdbPYYs3)S1xSLlHZ08BVSEzdbPYYsuHAnSeotZVXajICzjs3qVSHGuzzjCJhqfQvjxpQHQWXajImw7sdLrs9YgcsdLdCFBhgymqAon)Ml3pY9iqnDdCWcRDPHYi8BdbH7kgqfQvo(ynMaHtng1QeQPWPlBObU(hcpECFVesvsyPREpx945eAQ(husIMA2qdUNTginNMFZL7h5EeOMUboyvzehU7SQoqoqwQL6aqY8k5euAnaclD(oanrqdqHtdWC6Fdi5dWWAjZqzKCG0CA(nhhISxH6ruPqdKL6aqcpcl16a47KlRjTgGEzdbP8bGszdDacCAnGIPcFaMG(imnDdGLnXhinNMFZ3ahSWAxAOmc)2qq447KlRjTc6LneKIpwJjq4qMkWc5(oTKzZDNGAOmkuGfSwfqewe20r(D)ZwFXwMn3DcQHYOqbwWAvaryrythjpYw(IXaP508B(g4Gfw7sdLr43gcchxd7mR7SHIpwJjq4mNMyPa1eIK44k7h5ZYvGWsTkT1IlZUKYi1JhyCwUcewQvPTwCj51KRCmginNMFZ3ahSWAxAOmc)2qq4S1IhocHLn(ynMaHZCAILcutisIxco88Jmmolxbcl1Q0wlUK8AYvUhpNLRaHLAvARfxsEn5k3pYNLRaHLAvARfxEeclBEji1JNAcfUgocHLnVKYycdmginNMFZ3ahSWAxAOmc)2qq4UxRUWLii8XAmbchQqTkVebjf29JmmoHMQ)bLKNbLcFnOWPq9(sH6GdUHyp)2JNtOP6Fqj5zqPWxdkCkuVVuOo4GBi2ZV9FcD6c7Fr6KlQMUulPaGXaP508B(g4Gfw7sdLr43gccx9EUg46Lqqb33lHu54J1yceo33lHuL0zR0zA2qdOSVOFuHAvsNTsNPzdnGY(IsUAoiWHNhpUVxcPkfAgzC40kupQlfF9JkuRsHMrghoTc1J6sXx5riSS5WezOUfsepmginNMFZ3ahSWAxAOmc)2qq4wKPW5HLafmNMyj8XAmbc3ImfEW6vyroZxPMoiYgQF3JLARvzNqHRHQrdKL6a8c77mFhasW9CDaibew6WFaiSSvl7bG5D(oGcn238by9Aaqq0(a8seI)4eJ48bGKNTs3aUNXYg6aP508B(g4G1ri(JtmIZdfZwPd)SIZ99sivjHLU69C1VAmQvjutHtx2qdC9pe(HHAmQv5JYsLotZV97(NT(ITCpzm7cFnuVNRYJqyzZhinNMFZ3ahSG)fzzdnGYmUIVZxhJcQDqjLJRm(zf36vz9EUgQew6KhvpId3qzKFKvJrTkth5SDpEGbQqTkrpYu4HVg4zVod6ZnPWUF1yuRs0JmfE4RbE2RZG(CZJh1yuRYhLLkDMMF739pB9fB5EYy2f(AOEpxLhHWYM7hgOc1QeIKXYgAaH5GNnjf2XyG0CA(nFdCWckZCPXc2cR1oc)SIdvOwLPZ3GASV5YJqyzZHjoOULFuHAvMoFdQX(Mlf29Z3jglO2bLuUekZCPXc2cR1oQeC45hzyOgJAvIEKPWdFnWZEDg0NBE84(NT(ITe9itHh(AGN96mOp3KhHWYMxszKIXaP508B(g4Gv9EUg46Lqq4NvCOc1QmD(guJ9nxEeclBomXb1T8JkuRY05Bqn23CPWUFKHHAmQvj6rMcp81ap71zqFU5XdmqfQvj6rMcp81ap71zqFUjf297(NT(ITe9itHh(AGN96mOp3KhHWYMxszmHXazPoaFa)FonaVGtZVhal56a0FaNqpqAon)MVboy5mglyon)oWsUIFBiiCUhl1wR8bsZP538nWblNXybZP53bwYv8BdbH7mxAm(aP508B(g4GLZySG5087al5k(THGWPx2qqkFG0CA(nFdCWYzmwWCA(DGLCf)2qq4C)ZwFXMpqAon)MVboy5mglyon)oWsUIFBiiCUNTcWj7u8Zko1yuRs3Zwb4KDQFKHbQqTkHizSSHgqyo4ztsHDpEuJrTkrpYu4HVg4zVod6Znm8J8IqfQv5zLYFPJKC1CqGdPE8aJfzk8aeDcfUkpHMQ)bLKNvk)LocJbsZP538nWbRtOdMtZVdSKR43gcch6ZdA6GiBO4NvCOc1Qe9itHh(AGN96mOp3Kc7dKMtZV5BGdwNqhmNMFhyjxXVneeo0Nh2)NLnu8Zko1yuRs0JmfE4RbE2RZG(CZpYU)zRVylrpYu4HVg4zVod6Zn5riSS5WSmMWWpYNLRaHLAvARfxMDj4HupEGXz5kqyPwL2AXLKxtUY94X9pB9fB5EYy2f(AOEpxLhHWYMdZYyY)z5kqyPwL2AXLKxtUY9FwUcewQvPTwCz2WSmMWyG0CA(nFdCW6e6G5087al5k(THGW9OSuPZ08B8ZkouHAvUNmMDHVgQ3ZvPWUF1yuRYhLLkDMMFpqAon)MVboyDcDWCA(DGLCf)2qq4EuwQ0zA(Dy)Fw2qXpR4uJrTkFuwQ0zA(TF3)S1xSL7jJzx4RH69CvEeclBomlJj)iJ1U0qzKKRHDM1D2q945SCfiSuRsBT4sYRjx5(plxbcl1Q0wlUmBywgtE8aJZYvGWsTkT1IljVMCLJXaP508B(g4G1j0bZP53bwYv8BdbHZEc)SIZCAILcutisIxco8ginNMFZ3ahSCgJfmNMFhyjxXVneeoUA9YU1a5azPoaVWJKnaV0RMMFpqAon)MlTNWDeI)4eJ48qXSv6ginNMFZL2tBGdwqzMlnwWwyT2r4NvCQXOwL175k35RcNgil1bGe8hcbMLUby773Bo4dq)b4oYuAa2a25KW6hW(L)LQVdqTdkPdGLCDa1)gGTVZ8nBOd4Ss5V0rdi7bypnqAon)MlTN2ahSQ3Z1axVeccFNVogfu7Gskhxz8Zko3)S1xSLhH4poXiopumBLo5riSS5WehEirOULF1yuRsOMcNUSHg46FiginNMFZL2tBGdwW)ISSHgqzgxXpR4WAxAOmsEVwDHlrqdKMtZV5s7PnWbRhLLkDMs4NvCyTlnugjxKPW5HLafmNMyj)Oc1QCrMcNhwcKKRMdcyIzdKMtZV5s7PnWbR69CL78vHt4NvCOc1QeIKXYgAaH5GNnjpYCQFyG1U0qzKCrMcNhwcuWCAILginNMFZL2tBGdwqzMlnwWwyT2r4NvCNqNUW(xKo5IQPlvyICzKUHAmQv5j0PlyQsTGP53iXcIXaP508BU0EAdCWQEpxdC9sii8D(6yuqTdkPCCLXpR4oHoDH9ViDYfvtxQWe5YiDd1yuRYtOtxWuLAbtZVrIifJbsZP53CP90g4Gv9EUYD(QWj8ZkoyG1U0qzKCrMcNhwcuWCAILginNMFZL2tBGdwpklv6mLW35RJrb1oOKYXvg)SI7e60f2)I0jxunDPwcY4H0nuJrTkpHoDbtvQfmn)gjIumginNMFZL2tBGdwqzMlnwWwyT2rdKMtZV5s7PnWbR69CnW1lHGW35RJrb1oOKYXvEG0CA(nxApTboyb)Vo81qXSv6ginNMFZL2tBGdw25SMc6Fh16a5azPoGnpYu4d4Rdqm71zqFUnG9)zzdDa3RMMFpaFoaUANYhqzmXhakv)JgWMV4as(amSwYmugnqAon)MlrFEy)Fw2qXb)lYYgAaLzCf)SIdRDPHYi59A1fUebnqAon)MlrFEy)Fw2q3ahSocXFCIrCEOy2kD4NvCMttSuGAcrs8sWHNhpNqtsnrqb9difM4G6w(XAxAOmsEfdOc1kFGSul1bSvTdkPHSIdH5vFI8IqfQv5zLYFPJKC1CqSrzm8YiViuHAvEwP8x6i5riSS5BugdK4ImfEaIoHcxLNqt1)GsYZkL)shTDaEjANmLpaBaSxXFak8KpGKpGSvQx0Aa6pa1oOKoafona4ju4exhW(L)LQVdGAcHVdOyQWhG1dWqtwQ(oafUPdOyYydW23z(oGZkL)shnGSoGtOP6FqPLCafc30bGszdDawpaQje(oGIPcFayAaC1CqWXFa)naRha1ecFhGc30bOWPbSiuHADaftgBa8)7bqEDppAaFlhinNMFZLOppS)plBOBGdwpklv6mLW35RJrb1oOKYXvg)SI7e60f2)I0jxunDPwco8q6aP508BUe95H9)zzdDdCWckZCPXc2cR1oc)SI7e60f2)I0jxunDPct8WKF(oXyb1oOKYLqzMlnwWwyT2rLGdp)U)zRVyl3tgZUWxd175Q8iew28sq6aP508BUe95H9)zzdDdCWQEpxdC9sii8D(6yuqTdkPCCLXpR4oHoDH9ViDYfvtxQWepm539pB9fB5EYy2f(AOEpxLhHWYMxcshinNMFZLOppS)plBOBGdw175k35RcNWpR4qfQvjejJLn0acZbpBsEK5u)NqNUW(xKo5IQPl1sqUms3qng1Q8e60fmvPwW08BKisXWpFNySGAhus5Y69CL78vHtLGdp)WaRDPHYi5ImfopSeOG50elnqAon)MlrFEy)Fw2q3ahSQ3ZvUZxfoHFwXDcD6c7Fr6KlQMUulbhYfePBOgJAvEcD6cMQulyA(nsePy4NVtmwqTdkPCz9EUYD(QWPsWHNFyG1U0qzKCrMcNhwcuWCAILginNMFZLOppS)plBOBGdwqzMlnwWwyT2r4NvCU)zRVyl3tgZUWxd175Q8iew28soHMKAIGc6hWm)NqNUW(xKo5IQPlvyIzyYpFNySGAhus5sOmZLglylSw7OsWH3aP508BUe95H9)zzdDdCWQEpxdC9sii8D(6yuqTdkPCCLXpR4C)ZwFXwUNmMDHVgQ3Zv5riSS5LCcnj1ebf0pGz(pHoDH9ViDYfvtxQWeZW0a5azPoGnpYu4d4Rdqm71zqFUnaVGttS0a8sVAA(9aP508BUe95bnDqKnuCpklv6mLW35RJrb1oOKYXvg)SI7e60f2)I0jxunDPwcoKXmKUHAmQv5j0PlyQsTGP53irKIXaP508BUe95bnDqKn0nWbRJq8hNyeNhkMTsh(zfhw7sdLrYRyavOw5E8yonXsbQjejXlbhEE8CcD6c7Fr6GzbXBG0CA(nxI(8GMoiYg6g4G1ImfEW6vyroZx8ZkUtOtxy)lshmliEdKMtZV5s0Nh00br2q3ahSG)fzzdnGYmUIFwXH1U0qzK8ET6cxIG8J8j0PlS)fPtUOA6sfMifPE8Ccnj1ebf0puqyIdQB5XZj0u9pOK8mOu4RbfofQ3xkuhCWne753E8W3jglO2bLuUe(xKLn0akZ4Aj4WddpEoHoDH9ViDWSG4nqAon)MlrFEqthezdDdCWQEpx5oFv4e(zfhQqTkHizSSHgqyo4ztsHD)8DIXcQDqjLlR3ZvUZxfovco88ddS2LgkJKlYu48WsGcMttS0aP508BUe95bnDqKn0nWbl4)1HVgkMTsh(zf3j0PlS)fPtUOA6sTeCygM8Fcnj1ebf0puWsG6wdKMtZV5s0Nh00br2q3ahSQ3ZvUZxfoHFwXX3jglO2bLuUSEpx5oFv4uj4WZpmWAxAOmsUitHZdlbkyonXsdKMtZV5s0Nh00br2q3ahSEuwQ0zkHVZxhJcQDqjLJRm(zf3j0PlS)fPtUOA6sTe8qQhpNqtsnrqb9dfeMqDRbsZP53Cj6ZdA6GiBOBGdwW)ISSHgqzgxXpR4WAxAOmsEVwDHlrqdKMtZV5s0Nh00br2q3ahSSZznf0)oQv8ZkUtOtxy)lsNCr10LAjiftdKdKLAPoaF8S1a8Is2PdWhFVsn)MpqwQL6amNMFZLUNTcWj7uCo4w28WxdPJWpR4Qju4A4iew2Cyc1T8J8j0emXZJhyGkuRsisglBObeMdE2Kuy3pYWaHLDaU1ljEW9JkuRs3Zwb4KDQKRMdIsWHzBCcnv)dkjH4zAEgpunS)5Xdcl7aCRxs8G7hvOwLUNTcWj7ujxnheLua24eAQ(huscXZ08mEOAy)ddpEqfQvjejJLn0acZbpBskS7hzyGWYoa36Lep4(rfQvP7zRaCYovYvZbrjfGnoHMQ)bLKq8mnpJhQg2)84bHLDaU1ljEW9JkuRs3Zwb4KDQKRMdIskJPnoHMQ)bLKq8mnpJhQg2)WaJbYsDaijHtdyjCzdDaiHjJz3akMk8bG5DKZ2H1Mhzk8bsZP53CP7zRaCYoDdCWYb3YMh(AiDe(zfhmuJrTkFuwQ0zA(TFuHAvUNmMDHVgQ3ZvPWUFuHAv6E2kaNStLC1CqucUYyYpYOc1QCpzm7cFnuVNRYJqyzZHju3cjIC5nC)ZwFXwwVNRf99qWdvHZx5r2Yxm84bvOwLcn8N5BGRh1qv4YJqyzZHju3YJhuHAv6GBppGAnjpcHLnhMqDlmgil1bGKkO8Crd4Rdajmzm7gGaNmO0akMk8bG5DKZ2H1Mhzk8bsZP53CP7zRaCYoDdCWYb3YMh(AiDe(zfhmuJrTkFuwQ0zA(T)fzk8aeDcfUkpHMQ)bLKvJXOo4obUTOZpmqfQv5EYy2f(AOEpxLc7(D)ZwFXwUNmMDHVgQ3Zv5riSS5LugP(rgvOwLUNTcWj7ujxnheLGRmM8JmQqTkfA4pZ3axpQHQWLc7E8GkuRshC75buRjPWogE8GkuRs3Zwb4KDQKRMdIsWvUGymqAon)MlDpBfGt2PBGdwo4w28WxdPJWpR4GHAmQv5JYsLotZV9dJfzk8aeDcfUkpHMQ)bLKvJXOo4obUTOZpQqTkDpBfGt2PsUAoikbxzm5hgOc1QCpzm7cFnuVNRsHD)U)zRVyl3tgZUWxd175Q8iew28sWdtdKL6aqcpcl16a8XZwdWlkzNoGhlDoBFpBOdyjCzdDa7jJz3aP508BU09SvaozNUboy5GBzZdFnKoc)SItng1Q8rzPsNP53(HbQqTk3tgZUWxd175Quy3pYOc1Q09SvaozNk5Q5GOeCLXm)iJkuRsHg(Z8nW1JAOkCPWUhpOc1Q0b3EEa1AskSJHhpOc1Q09SvaozNk5Q5GOeCLlqE84(NT(ITCpzm7cFnuVNRYJqyzZHzb9JkuRs3Zwb4KDQKRMdIsWvgZWyGCGSuhas4R53dKMtZV5s3)S1xS542Fn)g)SIdvOwL7jJzx4RH69CvkSpqwQdWh)ZwFXMpqAon)MlD)ZwFXMVboyri2)I0foHMcfjB)B8Zko1yuRYhLLkDMMF7)eAcMyo)iJ1U0qzKKRHDM1D2q94bRDPHYiPTw8WriSSXWpYU)zRVyl3tgZUWxd175Q8iew2CyIu)i7(NT(ITSYioC3zvvEeclBEji1p)fyOzVK7cCvGrb6e218BpEGb)fyOzVK7cCvGrb6e218Bm84bvOwL7jJzx4RH69CvkSJHhpOpN7VMqHRHJqyzZHjEyAG0CA(nx6(NT(InFdCWIqS)fPlCcnfks2(34NvCQXOwLOhzk8Wxd8SxNb95M)tOtxy)lsNCr10LAjfet(pHMKAIGc6hqAjqDl)iJkuRs0JmfE4RbE2RZG(CtkS7XtnHcxdhHWYMdt8WegdKMtZV5s3)S1xS5BGdweI9ViDHtOPqrY2)g)SItng1QmDKZ2hinNMFZLU)zRVyZ3ahS2tgZUWxd175k(zfNAmQvj6rMcp81ap71zqFU5hzS2LgkJKCnSZSUZgQhpyTlnugjT1IhocHLng(r29pB9fBj6rMcp81ap71zqFUjpcHLn3Jh3)S1xSLOhzk8Wxd8SxNb95M8iB5R)tOtxy)lsNCr10LkmrkMWyG0CA(nx6(NT(InFdCWApzm7cFnuVNR4NvCQXOwLPJC2UFyGkuRY9KXSl81q9EUkf2hinNMFZLU)zRVyZ3ahS2tgZUWxd175k(zfNAmQv5JYsLotZV9Jmw7sdLrsUg2zw3zd1JhS2LgkJK2AXdhHWYgd)iRgJAvc1u40Ln0ax)dHKAdLrl)Oc1Q8ie)XjgX5HIzR0jf294bgQXOwLqnfoDzdnW1)qiP2qz0cJbsZP53CP7F26l28nWbl0JmfE4RbE2RZG(Cd)SIdvOwL7jJzx4RH69CvkSpqAon)MlD)ZwFXMVboyvVNRf99qWdvHZx8ZkoZPjwkqnHijoUY(rfQv5EYy2f(AOEpxLhHWYMdtOULFuHAvUNmMDHVgQ3ZvPWUFyOgJAv(OSuPZ08B)idJZYvGWsTkT1IljVMCL7XZz5kqyPwL2AXLzxsbXegE8utOW1WriSS5WSGdKMtZV5s3)S1xS5BGdw175ArFpe8qv48f)SIZCAILcutisIxco88JmQqTk3tgZUWxd175Quy3JNZYvGWsTkT1IlZUe3)S1xSL7jJzx4RH69CvEeclBog(rgvOwL7jJzx4RH69CvEeclBomH6wE8CwUcewQvPTwC5riSS5WeQBHXaP508BU09pB9fB(g4Gv9EUw03dbpufoFXpR4uJrTkFuwQ0zA(TFuHAvUNmMDHVgQ3ZvPWUFKrgvOwL7jJzx4RH69CvEeclBomH6wE8GkuRsHg(Z8nW1JAOkCPWUFuHAvk0WFMVbUEudvHlpcHLnhMqDlm8J8IqfQv5zLYFPJKC1CqGdPE8aJfzk8aeDcfUkpHMQ)bLKNvk)LocdmginNMFZLU)zRVyZ3ahSG77(RWPdr6c7hXP2r4NvCQXOwLOhzk8Wxd8SxNb95M)tOtxy)lsNCr10LAjygM8FcnbtCf0pYOc1Qe9itHh(AGN96mOp3Kc7E84(NT(ITe9itHh(AGN96mOp3KhHWYMxcMHjm84bgQXOwLOhzk8Wxd8SxNb95M)tOtxy)lsNCr10LAj4WdPdKMtZV5s3)S1xS5BGdwNLCkSiBHFwX5(NT(ITCpzm7cFnuVNRYJqyzZHjoKoqAon)MlD)ZwFXMVboyXn3L10LglSBof)SIZCAILcutisIxco88Jm6Z5(Rju4A4iew2CywqpEGbQqTkrpYu4HVg4zVod6ZnPWUFK3jvcf(lWKhHWYMdtOULhpNLRaHLAvARfxEeclBomlO)ZYvGWsTkT1IlZUKDsLqH)cm5riSS5yGXaP508BU09pB9fB(g4G1ImfEW6vyroZx8ZkoZPjwkqnHijEji1JNtOP6Fqj5oCYUhX3eFGCGSuhGpESuBToaVaAYsnj(aP508BU09yP2ALJBrMcNhwce(zfhw7sdLrsUg2zw3zd1JhS2LgkJK2AXdhHWYEG0CA(nx6ESuBTY3ahS4fTdr2qdisUIFwXDcD6c7Fr6KlQMUulPCb97(NT(ITCpzm7cFnuVNRYJqyzZHzb9dd1yuRs0JmfE4RbE2RZG(CZpw7sdLrsUg2zw3zdDG0CA(nx6ESuBTY3ahS4fTdr2qdisUIFwXbd1yuRs0JmfE4RbE2RZG(CZpw7sdLrsBT4HJqyzpqAon)MlDpwQTw5BGdw8I2HiBObejxXpR4uJrTkrpYu4HVg4zVod6Zn)iJkuRs0JmfE4RbE2RZG(CtkS7hzS2LgkJKCnSZSUZgQ)tOtxy)lsNCr10LAjygM84bRDPHYiPTw8WriSS9FcD6c7Fr6KlQMUulbZHjpEWAxAOmsARfpCeclB)NLRaHLAvARfxEeclBomlqy4XdmqfQvj6rMcp81ap71zqFUjf297(NT(ITe9itHh(AGN96mOp3KhHWYMJXaP508BU09yP2ALVboyzOpISnn)oWseO4NvCU)zRVyl3tgZUWxd175Q8iew2Cywq)yTlnugj5AyNzDNnu)iRgJAvIEKPWdFnWZEDg0NB(pHoDH9ViDYfvtxQWeZHj)U)zRVylrpYu4HVg4zVod6Zn5riSS5WeppEGHAmQvj6rMcp81ap71zqFUHXaP508BU09yP2ALVboyzOpISnn)oWseO4NvCyTlnugjT1IhocHL9aP508BU09yP2ALVboyXHBoiyuqHtbHU4FkCFXpR4WAxAOmsY1WoZ6oBO(r29pB9fB5EYy2f(AOEpxLhHWYMdZc6XJAmQvz6iNTJXaP508BU09yP2ALVboyXHBoiyuqHtbHU4FkCFXpR4WAxAOmsARfpCecl7bsZP53CP7XsT1kFdCWQYioC3zvf)SIdgOc1QCpzm7cFnuVNRsHD)WavOwLOhzk8Wxd8SxNb95Muy3pY8xGHM9sUlWvbgfOtyxZV94H)cm0SxsSpZ0Krb(ZWsTIb(zR0Dc7AirGGwPPeUY4NTs3jSRbOSh1y4kJF2kDNWUgYko(lWqZEjX(mttgf4pdl16a5azPoaKuuwQ0zA(9aUxnn)EG0CA(nx(OSuPZ08BChH4poXiopumBLo8ZkoZPjwkqnHijEj4kOFS2LgkJKxXaQqTYhinNMFZLpklv6mn)EdCWc(xKLn0akZ4k(QDqjnKvCWy9QSEpxdvclDsnDqKnu)WavOwLqKmw2qdimh8SjPWU)tOPsWvWbsZP53C5JYsLotZV3ahSQ3ZvUZxfoHFwXHkuRsisglBObeMdE2K8iZP(57eJfu7GskxwVNRCNVkCQeC45hgyTlnugjxKPW5HLafmNMyPbsZP53C5JYsLotZV3ahSEuwQ0zkHVZxhJcQDqjLJRm(zfhQqTkHizSSHgqyo4ztYJmNoqAon)MlFuwQ0zA(9g4GfuM5sJfSfwRDe(zfhFNySGAhus5sOmZLglylSw7OsWHNFKpHoDH9ViDYfvtxQWSmM845eAsQjckOFaVsG6wy4XdYlcvOwLNvk)LosYvZbbmrQhplcvOwLNvk)LosEeclBomlJumginNMFZLpklv6mn)EdCWQEpxdC9sii8ZkoZPjwkqnHijoUY(XAxAOmswVNRbUEjeuW99siv(aP508BU8rzPsNP53BGdwW)ISSHgqzgxXpR4WAxAOmsEVwDHlrq(57eJfu7Gskxc)lYYgAaLzCTeC4nqAon)MlFuwQ0zA(9g4GfuM5sJfSfwRDe(zfhFNySGAhus5sOmZLglylSw7OsWH3aP508BU8rzPsNP53BGdw175AGRxcbHVZxhJcQDqjLJRm(zfhmuJrTknSgZAhCYpmqfQvjejJLn0acZbpBskS7XJAmQvPH1yw7Gt(Hbw7sdLrY71QlCjcYJhS2LgkJK3Rvx4seK)tOjPMiOG(b8kbhu3AG0CA(nx(OSuPZ087nWbl4Frw2qdOmJR4NvCyTlnugjVxRUWLiObsZP53C5JYsLotZV3ahSEuwQ0zkHVZxhJcQDqjLJR8a5azPoaKW)zzdDaib)naKuuwQ0zA(TphGOANYhqzmnao5(EXhakv)JgasyYy2nGVoaKG756aCpcIpGVwhGp8ImqAon)MlFuwQ0zA(Dy)Fw2qXDeI)4eJ48qXSv6WpR4WAxAOmsEfdOc1k3JhZPjwkqnHijEj4WBG0CA(nx(OSuPZ087W()SSHUboyvVNRbUEjee(zfN50elfOMqKehxz)yTlnugjR3Z1axVeck4(EjKkFG0CA(nx(OSuPZ087W()SSHUboy9OSuPZucFNVogfu7Gskhxz8ZkouHAvcrYyzdnGWCWZMKhzoDG0CA(nx(OSuPZ087W()SSHUboyb)lYYgAaLzCf)SIdRDPHYi59A1fUebnqAon)MlFuwQ0zA(Dy)Fw2q3ahSGYmxASGTWATJWpR447eJfu7GskxcLzU0ybBH1Ahvco88FcD6c7Fr6KlQMUuHjMdtdKMtZV5YhLLkDMMFh2)NLn0nWbR69CnW1lHGW35RJrb1oOKYXvg)SI7e60f2)I0jxunDPcZciMginNMFZLpklv6mn)oS)plBOBGdwpklv6mLW35RJrb1oOKYXvg)SI7eAQeCfCG0CA(nx(OSuPZ087W()SSHUboyvVNRCNVkCc)SIZCAILcutisIxcomZpmWAxAOmsUitHZdlbkyonXsdKdKL6a8sMln2a8cOjl1K4dKMtZV5YZCPX44qz)VcvHZx8ZkouHAvUNmMDHVgQ3ZvPW(aP508BU8mxAm(g4GfkDC6GiBO4NvCOc1QCpzm7cFnuVNRsH9bsZP53C5zU0y8nWbl7CwtHDbgNWpR4qggOc1QCpzm7cFnuVNRsHD)MttSuGAcrs8sWHhgE8aduHAvUNmMDHVgQ3ZvPWUFKpHMKlQMUulbhs9FcD6c7Fr6KlQMUulbhMdtymqAon)MlpZLgJVboyXsOWvEajPclOiOwXpR4qfQv5EYy2f(AOEpxLc7dKMtZV5YZCPX4BGdww7iUEgl4mgd)SIdvOwL7jJzx4RH69CvkS7hvOwLeI9ViDHtOPqrY2)wkSpqAon)MlpZLgJVboyvZJqz)VWpR4qfQv5EYy2f(AOEpxLhHWYMdtCfa)Oc1QKqS)fPlCcnfks2(3sH9bsZP53C5zU0y8nWbludA4Rb9sheC8ZkouHAvUNmMDHVgQ3ZvPWUFZPjwkqnHijoUY(rgvOwL7jJzx4RH69CvEeclBomrQF1yuRs3Zwb4KDQKAdLrlpEGHAmQvP7zRaCYovsTHYOLFuHAvUNmMDHVgQ3Zv5riSS5WSGymqoqwQdquTEz3Aa8SHYiKeQDqjDa3RMMFpqAon)Ml5Q1l7w4ocXFCIrCEOy2kD4NvCyTlnugjVIbuHALpqAon)Ml5Q1l7wBGdwpklv6mLWpR4qfQvjejJLn0acZbpBsEK50bsZP53CjxTEz3AdCWQEpxdC9sii8ZkoS2LgkJK175AGRxcbfCFVesLpqAon)Ml5Q1l7wBGdwqzMlnwWwyT2r4NvCWyrMcparNqHRYtOP6Fqj5zLYFPJ8J8IqfQv5zLYFPJKC1CqatK6XZIqfQv5zLYFPJKhHWYMdZcigdKMtZV5sUA9YU1g4Gv9EUg46Lqq4NvCU)zRVylpcXFCIrCEOy2kDYJqyzZHjo8qIqDl)QXOwLqnfoDzdnW1)qmqAon)Ml5Q1l7wBGdwW)ISSHgqzgxXpR4WAxAOmsEVwDHlrqdKMtZV5sUA9YU1g4G1JYsLotj8ZkoyGkuRY69Lc1HDbgNKc7(vJrTkR3xkuh2fyCYJhS2LgkJKlYu48WsGcMttSKFuHAvUitHZdlbsYvZbbmXmpEoHMKAIGc6hWmyIdQBnqAon)Ml5Q1l7wBGdw175AGRxcbHFwXDcD6c7Fr6KlQMUuHjYLr6gQXOwLNqNUGPk1cMMFJerkgdKMtZV5sUA9YU1g4G1JYsLotj8ZkUtOtxy)lsNCr10LAjiJhs3qng1Q8e60fmvPwW08BKisXyG0CA(nxYvRx2T2ahSQ3Z1axVecAG0CA(nxYvRx2T2ahSG)xh(AOy2kDdKMtZV5sUA9YU1g4GLDoRPG(3rToqoqwQdOWlBiiLpqAon)Ml1lBiiLJlBU7eudLrHcSG1QaIWIWMoc)SIdvOwL7jJzx4RH69CvkS7XJAhusLAIGc6h2DAapmbtK6Xd6Z5(Rju4A4iew2CyIx5bYsDafcNgGEzdbPdOyQWhGcNga8ekCIRdG4AIWuAnaSgtGWFaftgBaO0ae40Aa1846aSEnGDlpAnGIPcFaiHjJz3a(6aqcUNRYbsZP53CPEzdbP8nWbl9YgcslJFwXbdS2LgkJK8DYL1Kwb9Ygcs9JkuRY9KXSl81q9EUkf29JmmuJrTkth5SDpEuJrTkth5SD)Oc1QCpzm7cFnuVNRYJqyzZlbxzmHHFKHHEzdbPs8KWnEW9pB9fBpE0lBiivIN09pB9fB5riSS5E8G1U0qzKuVSHG0W(L)LQV4kJHhp6LneKkllrfQ1Ws4mn)UeC1ekCnCeclB(aP508BUuVSHGu(g4GLEzdbP4HFwXbdS2LgkJK8DYL1Kwb9Ygcs9JkuRY9KXSl81q9EUkf29JmmuJrTkth5SDpEuJrTkth5SD)Oc1QCpzm7cFnuVNRYJqyzZlbxzmHHFKHHEzdbPYYs4gp4(NT(IThp6LneKkllD)ZwFXwEeclBUhpyTlnugj1lBiinSF5FP6lo8WWJh9YgcsL4jrfQ1Ws4mn)UeC1ekCnCeclB(azPoamFDaFZ8DaFtd47biWPbOx2qq6a2VhBUi(aSbGkuR4pabonafonGxHt3a(EaU)zRVylhas6nGSoGMsfoDdqVSHG0bSFp2Cr8bydavOwXFacCAaOVcFaFpa3)S1xSLdKMtZV5s9Ygcs5BGdw6LneKwg)SIdg6LneKkllHB8GaNcOc1QFK1lBiivIN09pB9fB5riSS5E8ad9YgcsL4jHB8GaNcOc1kgE84(NT(ITCpzm7cFnuVNRYJqyzZlbpmnqAon)Ml1lBiiLVboyPx2qqkE4NvCWqVSHGujEs4gpiWPaQqT6hz9YgcsLLLU)zRVylpcHLn3JhyOx2qqQSSeUXdcCkGkuRy4XJ7F26l2Y9KXSl81q9EUkpcHLnVe8WuuKVtUO34H0YrnQXi]] )


end
