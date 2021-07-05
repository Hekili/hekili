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


    spec:RegisterPack( "Frost DK", 20210705, [[d4042cqiLQ6rsvvUevKYMOs9jPsJcsCki0QqPGxbkmlQKUfkfQ2fu)cuQHbbDmLklds6zOuzAqGUgkL2geGVrfPACqa5CsvvzDujmpqj3dsTpPQCqQiXcbf9qQiMOuvH6IOuK2ikfXhLQkyKsvfYjrPOwji6LOuO0mPs0oLk8tiGAOsvv1sPIKEkjnvPIUkkfk8vukKXQuL9kQ)kYGbomLfJIhtvtwkxgzZk5ZkLrdQoTWQrPqrVgeMnQUneTBj)wLHdshxQQOLRQNtQPtCDsSDQW3LQmEuQ68urTEPQsZhLSFfN3L7mR2mHYDGkcrDhcD6iKTyeIaHGOYweqwvCgkLvHAEiSnkRwgskRYM8Nwgq)y2yZQqnN5N1YDMv1NY7PSkCrGQDbSH9wiWvyW(djS1bsfUjXv(3wcS1bspSZQmkbxyZvMjR2mHYDGkcrDhcD6iKTyeIaHGOIkQzvtrGFFwvnq6KSk8O1OkZKvBK2Nv7htMaFaSXwXgCzaSj)PLbsiv4opa266aqfHOUBGCG0jWTAJ0dKSXhGtLqEoO2a4MwyJRj)vTbOOTnAa3AaobUfLEa3AaSzpnatpGqgq7iD1vgauU58a6rC(aIAaqFZlHNWzvEOfDUZS6XWdHEtIRsqVJh1wUZCh7YDMvPYy4uldZSQ5L4QS6tiVxtCsRt9IsOpR2iT)dOsCvwT)FhpQTbWMC)aqGz4HqVjXvUyaQI9IEa7q4a0K)QMEam06EAa9)GZTFa3AaSj)PLb4pKKEa3AnaN0poR6)qOpSSQyCQe8MjWPpQTKwUhjMkJHtTbWI1a8x1ucbtoOF9NwWuzmCQnawSgWRu06(ncZesuBj)XByQmgo1galwdW8s4GsuridspG(qpauZsUduZDMvPYy4uldZSQ)dH(WYQmkRf(dKewbAw18sCvwf(1Jh1wIHBAjl5oyxUZSkvgdNAzyMvnVexLvpgEi0BcLv9Fi0hwwLrzTWqeCEuBjKMhEue(jZlzvVZEoLe73irN7yxwYDGG5oZQuzmCQLHzw1)HqFyzvnuIZtI9BKOXBCZhgpznhw5Pb0h6bG6aCpGxPcFc61JECJwHpKbaRbGaqyw18sCvwDJB(W4jR5WkpLLChSn3zwLkJHtTmmZQMxIRYQR)0sslFabLv9Fi0hww9vQWNGE9Oh3Ov4dzaWAaoDeMv9o75usSFJeDUJDzj3bci3zwLkJHtTmmZQMxIRYQhdpe6nHYQ(pe6dlR(kfnG(qpa2Lv9o75usSFJeDUJDzj3Htp3zwLkJHtTmmZQ(pe6dlRAEjCqjQiKbPhqFOhacoa3daLbS)aAKjWtw1snYBoJLWdruBdW9a8NdQSsWvSbxslJgalwdy)b4phuzLGRydUKwgnaeZQMxIRYQR)0I27SaNYswYQ(J3sWj7LCN5o2L7mRsLXWPwgMzvZlXvzvpClkD6wPWtz1gP9FavIRYQSXqtdOP8rTnG(FW52pGEHaFaSzp5nOWgMpzc8SQ)dH(WYQ7paX4uj4JHhc9MexHPYy4uBaUhaJYAHHgCU9PBLw)Pf8tiTO0dawdGDdW9ayuwlm0GZTpDR06pTGvGoa3dGrzTW(J3sWj7fSwmpedOp0dyhcZsUduZDMvPYy4uldZSQ5L4QSQhUfLoDRu4PSAJ0(pGkXvzveyfrhnAa3Aa9)GZTFakAY2Ob0le4dGn7jVbf2W8jtGNv9Fi0hwwD)bigNkbFm8qO3K4kmvgdNAdW9aAKjWtquXgCb)kfTUFJWlJZPk5FfT1OFaUhW(dGrzTWqdo3(0TsR)0cwb6aCpaugaJYAH9hVLGt2lyTyEigqFOhWoeWaCpagL1cRuWpUZjT8uTjWXkqhalwdGrzTW(J3sWj7fSwmpedOp0dyx)BaUhG)oE76vyObNBF6wP1FAb)eslk9a6Ba7q4aqml5oyxUZSkvgdNAzyMv9Fi0hwwD)bigNkbFm8qO3K4kmvgdNAdW9a2FanYe4jiQydUGFLIw3Vr4LX5uL8VI2A0pa3dGrzTW(J3sWj7fSwmpedOp0dyhchG7bS)ayuwlm0GZTpDR06pTGvGoa3dWFhVD9km0GZTpDR06pTGFcPfLEa9nauryw18sCvw1d3IsNUvk8uwYDGG5oZQuzmCQLHzw18sCvw1d3IsNUvk8uwTrA)hqL4QSA))jhujdWjhVnG(rK9Yaoh07nOqJABanLpQTban4C7ZQ(pe6dlRkgNkbFm8qO3K4kmvgdNAdW9a2FamkRfgAW52NUvA9NwWkqhG7bGYayuwlS)4TeCYEbRfZdXa6d9a2HagG7bWOSwyLc(XDoPLNQnbowb6ayXAamkRf2F8wcozVG1I5Hya9HEa76FdGfRb4VJ3UEfgAW52NUvA9NwWpH0Ispayna2na3dGrzTW(J3sWj7fSwmpedOp0dyhcoaeZswYQhdpe6njUk3zUJD5oZQuzmCQLHzw18sCvw9jK3RjoP1PErj0NvBK2)bujUkRIaZWdHEtIRgWFIjXvzv)hc9HLvnVeoOeveYG0dOp0dGDdW9aqzaIXPsWBMaN(O2sA5EKyQmgo1galwdWFvtjem5G(1FAbtLXWP2ayXAaVsrR73imtirTL8hVHPYy4uBaiMLChOM7mRsLXWPwgMzvZlXvzv4xpEuBjgUPLSQ)dH(WYQ7pG2j41FAjTih0JLWdruBdW9a2FamkRfgIGZJAlH08WJIWkqhG7b8kfnG(qpa2Lv9o75usSFJeDUJDzj3b7YDMvPYy4uldZSQ)dH(WYQmkRfgIGZJAlH08WJIWpzEzaUhGgkX5jX(ns041FAr7DwGtdOp0da1b4EaOmagL1c3itGRtnfcRfZdXaqpaeCaSynG9hqJmbEYQwQrEZzSeEiIABaSynG9hG)CqLvcUIn4sAz0aqmRAEjUkRU(tlAVZcCkl5oqWCNzvQmgo1YWmRAEjUkREm8qO3ekR6)qOpSSkJYAHHi48O2sinp8Oi8tMxgalwdy)bWOSw4pqsyfOdW9a0qjopj2VrIgd)6XJAlXWnTmG(qpa2Lv9o75usSFJeDUJDzj3bBZDMvPYy4uldZSQ)dH(WYQAOeNNe73irJ34MpmEYAoSYtdOp0da1b4EaOmGxPcFc61JECJwHpKbaRbSdHdGfRb8kfHLajLKlH6a6BaB(2aqCaSynaugqJyuwl8B979HNWAX8qmayna2oawSgqJyuwl8B979HNWpH0IspaynGDSDaiMvnVexLv34MpmEYAoSYtzj3bci3zwLkJHtTmmZQ(pe6dlRAEjCqjQiKbPha6bSBaUhakdWFvtjem9wl8Me1wIHF9WuzmCQna3dGrzTW0BTWBsuBjg(1dRfZdXaqpauhalwdWFvtjeSsXjtdNAP1tv)6mMkJHtTb4EamkRfwP4KPHtT06PQFDg)eslk9aG1a28TbGyw18sCvwD9NwsA5diOSK7WPN7mRsLXWPwgMzv)hc9HLvzuwl8hijSc0b4EaAOeNNe73irJHF94rTLy4MwgqFOhaQzvZlXvzv4xpEuBjgUPLSK7abk3zwLkJHtTmmZQ(pe6dlRQHsCEsSFJenEJB(W4jR5WkpnG(qpauZQMxIRYQBCZhgpznhw5PSK7O)L7mRsLXWPwgMzvZlXvz11FAjPLpGGYQ(pe6dlRU)aeJtLGnhg3kpCctLXWP2aCpG9haJYAHHi48O2sinp8OiSc0bWI1aeJtLGnhg3kpCctLXWP2aCpG9haJYAH)ajHvGoawSgaJYAH)ajHvGoa3d4vkclbskjxc1b0h6bS5BzvVZEoLe73irN7yxwYDSdH5oZQuzmCQLHzw1)HqFyzvgL1c)bscRanRAEjUkRc)6XJAlXWnTKLCh72L7mRsLXWPwgMzvZlXvz1JHhc9MqzvVZEoLe73irN7yxwYswL50jj8qe1wUZCh7YDMvPYy4uldZSQ5L4QS6XWdHEtOSQ3zpNsI9BKOZDSlR6)qOpSS6RuHpb96rpUrRWhYa6d9aqaimR2iT)dOsCvwfMpzc8bCRbOgv7TTtBdWP4LWbnaN6jMexLLChOM7mRsLXWPwgMzv)hc9HLvfJtLG3mbo9rTL0Y9iXuzmCQnawSgG)QMsiyYb9R)0cMkJHtTbWI1aELIw3VryMqIAl5pEdtLXWP2ayXAaMxchuIkczq6b0h6bG6ayXAa7paX4uj4ntGtFuBjTCpsmvgdNAdW9a2Fa(RAkHGjh0V(tlyQmgo1gG7bS)aELIw3VryMqIAl5pEdtLXWP2aCpGxPcFc61J(baRbWouZQMxIRYQpH8EnXjTo1lkH(SK7GD5oZQuzmCQLHzw1)HqFyz1xPcFc61J(baRbWouZQMxIRYQnYe4jRAPg5nNZsUdem3zwLkJHtTmmZQ(pe6dlRYOSw4pqsyfOdW9aqzaVsf(e0Rh94gTcFidawdGTSDaSynGxPiSeiPKCj2nayHEaB(2ayXAaAOeNNe73irJHF94rTLy4MwgqFOhaQdaXbWI1aELk8jOxp6haSga7qnRAEjUkRc)6XJAlXWnTKLChSn3zwLkJHtTmmZQ(pe6dlRYOSwyicopQTesZdpkcRaDaUhGgkX5jX(ns041FAr7DwGtdOp0da1b4EaOmG9hqJmbEYQwQrEZzSeEiIABaUhG)CqLvcUIn4sAz0ayXAa7pa)5GkReCfBWL0YObGyw18sCvwD9Nw0ENf4uwYDGaYDMvPYy4uldZSQ)dH(WYQVsf(e0Rh94gTcFidOp0dabr4aCpGxPiSeiPKCj2nG(gWMVLvnVexLvHFFLUvQxuc9zj3Htp3zwLkJHtTmmZQ(pe6dlRQHsCEsSFJenE9Nw0ENf40a6d9aqDaUhakdGrzTWnYe46utHWAX8qma0dabhalwdy)b0itGNSQLAK3CglHhIO2galwdy)b4phuzLGRydUKwgnaeZQMxIRYQR)0I27SaNYsUdeOCNzvQmgo1YWmRAEjUkREm8qO3ekR6)qOpSS6RuHpb96rpUrRWhYa6BaOY2bWI1aELIWsGKsYLy3aG1a28TSQ3zpNsI9BKOZDSll5o6F5oZQuzmCQLHzw1)HqFyzvgL1c)bscRanRAEjUkRc)6XJAlXWnTKLCh7qyUZSkvgdNAzyMv9Fi0hww9vQWNGE9Oh3Ov4dza9na2IWSQ5L4QSQ9EROKC)tLKLSKvFZhgxN7m3XUCNzvQmgo1YWmRAEjUkRYWVRLwkVZz1gP9FavIRYQovZhgFaofMGhsq6SQ)dH(WYQmkRfgAW52NUvA9NwWkqZsUduZDMvPYy4uldZSQ)dH(WYQmkRfgAW52NUvA9NwWkqZQMxIRYQm0RPhIO2YsUd2L7mRsLXWPwgMzv)hc9HLvrza7pagL1cdn4C7t3kT(tlyfOdW9amVeoOeveYG0dOp0da1bG4ayXAa7pagL1cdn4C7t3kT(tlyfOdW9aqzaVsr4gTcFidOp0dGTdW9aELk8jOxp6XnAf(qgqFOhacaHdaXSQ5L4QSQ9EROeufUMYsUdem3zwLkJHtTmmZQ(pe6dlRYOSwyObNBF6wP1FAbRanRAEjUkRYJn4IoXgtL2gsQKSK7GT5oZQuzmCQLHzw1)HqFyzvgL1cdn4C7t3kT(tlyfOdW9ayuwlmHe61J(0RuuQhzqVcRanRAEjUkRALN0YB8K348SK7abK7mRsLXWPwgMzv)hc9HLvzuwlm0GZTpDR06pTGFcPfLEaWc9aqGgG7bWOSwycj0Rh9PxPOupYGEfwbAw18sCvwDfpXWVRLLCho9CNzvQmgo1YWmR6)qOpSSkJYAHHgCU9PBLw)PfSc0b4EaMxchuIkczq6bGEa7gG7bGYayuwlm0GZTpDR06pTGFcPfLEaWAaSDaUhGyCQeS)4TeCYEbtLXWP2ayXAa7paX4ujy)XBj4K9cMkJHtTb4EamkRfgAW52NUvA9NwWpH0Ispayna2naeZQMxIRYQm2w6wj5dpe6SKLSkZPtqVJh1wUZCh7YDMvPYy4uldZSQ5L4QSk8RhpQTed30swTrA)hqL4QSkmFYe4d4wdqnQ2BBN2ga074rTnG)etIRgGlgGwSx0dyhc1dGHw3tdaMN6ac9amhwWngoLv9Fi0hwwLrzTWFGKWkqZsUduZDMvPYy4uldZSQ)dH(WYQMxchuIkczq6b0h6bG6ayXAaVsryjqsj5sSDaWc9a28Tb4EaOmaX4uj4ntGtFuBjTCpsmvgdNAdGfRb4VQPecMCq)6pTGPYy4uBaSynGxPO19BeMjKO2s(J3WuzmCQnaeZQMxIRYQpH8EnXjTo1lkH(SK7GD5oZQuzmCQLHzw18sCvw9y4HqVjuw17SNtjX(ns05o2Lv9Fi0hww9vQWNGE9Oh3Ov4dza9HEaOY2SAJ0(pGkXvz1UI9BKKIfAKg7DbknIrzTWV1V3hEcRfZdbm2HOtdLgXOSw43637dpHFcPfLgg7qKn0itGNGOIn4c(vkAD)gHFRFVp8u3b4ujOKj6bydGFIRdqGh6be6beLqvJAdqUbi2VrYae40aGhBWjTmaOFCFiopaQiKopGEHaFawnaJj4H48ae4MmGEbNpadkuUZd4T(9(Wtdiwd4vkAD)g1WdOt4MmagkQTby1aOIq68a6fc8bGWbOfZdH21bC)aSAauriDEacCtgGaNgqJyuwRb0l48bOVRgaXEOXtd4kCwYDGG5oZQuzmCQLHzw1)HqFyz1xPcFc61JECJwHpKbaRbGkchG7bOHsCEsSFJenEJB(W4jR5WkpnG(qpauhG7b4VJ3UEfgAW52NUvA9NwWpH0IspG(gaBZQMxIRYQBCZhgpznhw5PSK7GT5oZQuzmCQLHzw18sCvwD9NwsA5diOSQ)dH(WYQVsf(e0Rh94gTcFidawdaveoa3dWFhVD9km0GZTpDR06pTGFcPfLEa9na2Mv9o75usSFJeDUJDzj3bci3zwLkJHtTmmZQ(pe6dlRYOSwyicopQTesZdpkc)K5Lb4EaVsf(e0Rh94gTcFidOVbGYa2X2baJbigNkb)kv4tMiuPysCfMkJHtTbWgga7gaIdW9a0qjopj2VrIgV(tlAVZcCAa9HEaOoa3daLbWOSw4gzcCDQPqyTyEiga6bGGdGfRbS)aAKjWtw1snYBoJLWdruBdGfRbS)a8NdQSsWvSbxslJgaIzvZlXvz11FAr7DwGtzj3Htp3zwLkJHtTmmZQ(pe6dlR(kv4tqVE0JB0k8HmG(qpauga7y7aGXaeJtLGFLk8jteQumjUctLXWP2ayddGDdaXb4EaAOeNNe73irJx)PfT3zbonG(qpauhG7bGYayuwlCJmbUo1uiSwmpeda9aqWbWI1a2FanYe4jRAPg5nNXs4HiQTbWI1a2Fa(Zbvwj4k2GlPLrdaXSQ5L4QS66pTO9olWPSK7abk3zwLkJHtTmmZQ(pe6dlR6VJ3UEfgAW52NUvA9NwWpH0IspG(gWRuewcKusUecoa3d4vQWNGE9Oh3Ov4dzaWAaiichG7bOHsCEsSFJenEJB(W4jR5WkpnG(qpauZQMxIRYQBCZhgpznhw5PSK7O)L7mRsLXWPwgMzvZlXvz11FAjPLpGGYQ(pe6dlR6VJ3UEfgAW52NUvA9NwWpH0IspG(gWRuewcKusUecoa3d4vQWNGE9Oh3Ov4dzaWAaiicZQEN9Ckj2VrIo3XUSKLSQDuUZCh7YDMvPYy4uldZSAJ0(pGkXvzvNYXMoaN6jMexLvnVexLvFc59AItADQxuc9zj3bQ5oZQuzmCQLHzw1)HqFyzvX4uj41FAr7DwGtyQmgo1YQMxIRYQBCZhgpznhw5PSK7GD5oZQuzmCQLHzw18sCvwD9NwsA5diOSQ)dH(WYQ(74TRxHFc59AItADQxuc94NqArPhaSqpauhaByaB(2aCpaX4uj4ntGtFuBjTCpsmvgdNAzvVZEoLe73irN7yxwYDGG5oZQuzmCQLHzw1)HqFyzvgL1c)bscRanRAEjUkRc)6XJAlXWnTKLChSn3zwLkJHtTmmZQ(pe6dlR2itGNSQLAK3CglHhIO2gG7b4phuzLGRydUKwgna3dGrzTWnYe46utHWAX8qmaynaemRAEjUkREm8qO3ekl5oqa5oZQuzmCQLHzw1)HqFyzvgL1cdrW5rTLqAE4rr4NmVma3daLbS)aAKjWtw1snYBoJLWdruBdW9a8NdQSsWvSbxslJgalwdy)b4phuzLGRydUKwgnaeZQMxIRYQR)0I27SaNYsUdNEUZSkvgdNAzyMv9Fi0hww9vQWNGE9Oh3Ov4dzaWAaOmGDSDaWyaIXPsWVsf(KjcvkMexHPYy4uBaSHbWUbGyw18sCvwDJB(W4jR5WkpLLChiq5oZQuzmCQLHzw18sCvwD9NwsA5diOSQ)dH(WYQVsf(e0Rh94gTcFidawdaLbSJTdagdqmovc(vQWNmrOsXK4kmvgdNAdGnma2naeZQEN9Ckj2VrIo3XUSK7O)L7mRsLXWPwgMzv)hc9HLv3FanYe4jRAPg5nNXs4HiQTb4Ea(Zbvwj4k2GlPLrdGfRbS)a8NdQSsWvSbxslJYQMxIRYQR)0I27SaNYsUJDim3zwLkJHtTmmZQMxIRYQhdpe6nHYQ(pe6dlR(kv4tqVE0JB0k8HmG(gakdav2oaymaX4uj4xPcFYeHkftIRWuzmCQna2Way3aqmR6D2ZPKy)gj6Ch7YsUJD7YDMvnVexLv34MpmEYAoSYtzvQmgo1YWml5o2HAUZSkvgdNAzyMvnVexLvx)PLKw(ackR6D2ZPKy)gj6Ch7YsUJDSl3zw18sCvwf(9v6wPErj0NvPYy4uldZSK7yhcM7mRAEjUkRAV3kkj3)ujzvQmgo1YWmlzjR2OLPWLCN5o2L7mRAEjUkRImQwA9e1VuwLkJHtTmmZsUduZDMvPYy4uldZS6bnRQjjRAEjUkR6W(Wy4uw1HXvOSkkdG6NkbuOudhL2)kIXWPu)uXkrbzQrocpna3dWFhVD9kCuA)RigdNs9tfRefKPg5i8e(jR58aqmR2iT)dOsCvwT))KdQKbOHs(yfuBaYhfeKOhadf12au0uBa9cb(amf5qAs4hapksNvDyFQmKuwvdL8XkOws(OGGKSK7GD5oZQuzmCQLHzw9GMv1KKvnVexLvDyFymCkR6W4kuw18s4Gsuridspa0dy3aCpaugWBrlroOsWwRPXrnG(gWo2oawSgW(d4TOLihujyR10yI9Hw0daXSQd7tLHKYQAjbLBvf1wwYDGG5oZQuzmCQLHzw9GMv1KKvnVexLvDyFymCkR6W4kuw18s4GsuridspG(qpauhG7bGYa2FaVfTe5GkbBTMgtSp0IEaSynG3IwICqLGTwtJj2hArpa3daLb8w0sKdQeS1AA8tiTO0dOVbW2bWI1awXgCj9eslk9a6Ba7q4aqCaiMvDyFQmKuw1AnD6jKwuzj3bBZDMvPYy4uldZSQ5L4QS6tiVxtCsRt9IsOpR2iT)dOsCvw1Pafk35bWM8NwgaBc5GExhaslkXIAaSzVZdOtJFLEaw1gaeebDaovc59AItA9ayJIsOFa)X5rTLv9Fi0hww1Fvtjem5G(1FAzaUhGyCQe8MjWPpQTKwUhjMkJHtTb4Ea7paX4uj4JHhc9MexHPYy4uBaUhG)oE76vyObNBF6wP1FAb)eslkDwYDGaYDMvPYy4uldZSQ5L4QSk8RhpQTed30sw1)HqFyz12j41FAjTih0JFA9KgUXWPb4EaOmaX4uj4WtEdkMkJHtTbWI1a2FamkRfM5jtGNUvshv7TTtByfOdW9aeJtLGzEYe4PBL0r1EB70gMkJHtTbWI1aeJtLGpgEi0BsCfMkJHtTb4Ea(74TRxHHgCU9PBLw)Pf8tiTO0dW9a2FamkRfgIGZJAlH08WJIWkqhaIzvVZEoLe73irN7yxwYD40ZDMvPYy4uldZSQ)dH(WYQmkRfo8oNeJFLg)eslk9aGf6bS5BdW9ayuwlC4Dojg)knwb6aCpanuIZtI9BKOXBCZhgpznhw5Pb0h6bG6aCpaugW(dqmovcM5jtGNUvshv7TTtByQmgo1galwdWFhVD9kmZtMapDRKoQ2BBN2WpH0IspG(gWo2oaeZQMxIRYQBCZhgpznhw5PSK7abk3zwLkJHtTmmZQ(pe6dlRYOSw4W7Csm(vA8tiTO0dawOhWMVna3dGrzTWH35Ky8R0yfOdW9aqza7paX4ujyMNmbE6wjDuT32oTHPYy4uBaSyna)D821RWmpzc80Ts6OAVTDAd)eslk9a6Ba7y7aqmRAEjUkRU(tljT8beuwYD0)YDMvPYy4uldZSAJ0(pGkXvzvNa)onnaNIxIRgap0YaKBaVsLvnVexLv9gNNmVexL4HwYQ8qlPYqszv)5GkReDwYDSdH5oZQuzmCQLHzw18sCvw1BCEY8sCvIhAjRYdTKkdjLvFZhgxNLCh72L7mRsLXWPwgMzvZlXvzvVX5jZlXvjEOLSkp0sQmKuwv(OGGeDwYDSd1CNzvQmgo1YWmRAEjUkR6nopzEjUkXdTKv5HwsLHKYQ(74TRxPZsUJDSl3zwLkJHtTmmZQ(pe6dlRkgNkb7pElbNSxWuzmCQna3dGrzTW(J3sWj7fSwmpedOp0dyhchG7bGYaAeJYAHFRFVp8ewlMhIbGEaSDaSynG9hqJmbEcIk2Gl4xPO19Be(T(9(WtdaXbWI1ayoTEaUhWk2GlPNqArPhaSqpGnFlRAEjUkR6nopzEjUkXdTKv5HwsLHKYQ(J3sWj7LSK7yhcM7mRsLXWPwgMzv)hc9HLvzuwlmZtMapDRKoQ2BBN2WkqZQMxIRYQVsLmVexL4HwYQ8qlPYqszvMtNKWdruBzj3Xo2M7mRsLXWPwgMzv)hc9HLvfJtLGzEYe4PBL0r1EB70gMkJHtTb4EaOma)D821RWmpzc80Ts6OAVTDAd)eslk9aG1a2HWbG4aCpaugWBrlroOsWwRPXrnG(gaQSDaSynG9hWBrlroOsWwRPXe7dTOhalwdWFhVD9km0GZTpDR06pTGFcPfLEaWAa7q4aCpG3IwICqLGTwtJj2hArpa3d4TOLihujyR104OgaSgWoeoaeZQMxIRYQVsLmVexL4HwYQ8qlPYqszvMtNGEhpQTSK7yhci3zwLkJHtTmmZQ(pe6dlRYOSwyObNBF6wP1FAbRaDaUhGyCQe8XWdHEtIRWuzmCQLvnVexLvFLkzEjUkXdTKv5HwsLHKYQhdpe6njUkl5o250ZDMvPYy4uldZSQ)dH(WYQIXPsWhdpe6njUctLXWP2aCpa)D821RWqdo3(0TsR)0c(jKwu6baRbSdHdW9aqzaoSpmgoH1sck3QkQTbWI1aElAjYbvc2AnnMyFOf9aCpG3IwICqLGTwtJJAaWAa7q4ayXAa7pG3IwICqLGTwtJj2hArpaeZQMxIRYQVsLmVexL4HwYQ8qlPYqsz1JHhc9MexLGEhpQTSK7yhcuUZSkvgdNAzyMv9Fi0hww18s4GsuridspG(qpauZQMxIRYQVsLmVexL4HwYQ8qlPYqszv7OSK7yx)l3zwLkJHtTmmZQMxIRYQEJZtMxIRs8qlzvEOLuziPSQwSQzFllzjRc9j)HKXKCN5o2L7mRsLXWPwgMz1dAwvtsSYQ(pe6dlRkFuqqcw2HHB6KIMsmkR1aCpaugW(dqmovcM5jtGNUvshv7TTtByQmgo1gG7bGYaKpkiibl7W(74TRxHBkVjXvdWPna)D821RWqdo3(0TsR)0cUP8Mexna0daHdaXbWI1aeJtLGzEYe4PBL0r1EB70gMkJHtTb4EaOma)D821RWmpzc80Ts6OAVTDAd3uEtIRgGtBaYhfeKGLDy)D821RWnL3K4QbGEaiCaioawSgGyCQeC4jVbftLXWP2aqmR2iT)dOsCvwLn1HXvmH0dWgG8rbbj6b4VJ3UELRdOfoIg1gaJZdaAW52pGBnG1FAza3paMNmb(aU1a0r1EB70wx9a83XBxVcpa28AaH0vpahgxHgaCtpG6gWtiTOA0pGNeLVgWoxhaX10aEsu(AaieZwCw1H9PYqszv5Jccss7sANlFw18sCvw1H9HXWPSQdJRqjIRPSkcXSnR6W4kuwDxwYDGAUZSkvgdNAzyMvpOzvnjXkRAEjUkR6W(Wy4uw1H9PYqszv5JccssOM0ox(SQ)dH(WYQYhfeKGfuXWnDsrtjgL1AaUhakdy)bigNkbZ8KjWt3kPJQ922PnmvgdNAdW9aqzaYhfeKGfuX(74TRxHBkVjXvdWPna)D821RWqdo3(0TsR)0cUP8Mexna0daHdaXbWI1aeJtLGzEYe4PBL0r1EB70gMkJHtTb4EaOma)D821RWmpzc80Ts6OAVTDAd3uEtIRgGtBaYhfeKGfuX(74TRxHBkVjXvda9aq4aqCaSynaX4uj4WtEdkMkJHtTbGyw1HXvOeX1uwfHy2MvDyCfkRUll5oyxUZSkvgdNAzyMvpOzvnjXkR6)qOpSS6(dq(OGGeSSdd30jfnLyuwRb4EaYhfeKGfuXWnDsrtjgL1AaSyna5JccsWcQy4MoPOPeJYAna3daLbGYaKpkiiblOI93XBxVc3uEtIRgaShG8rbbjybvmJYALAkVjXvdaXbWggakdyhMTdagdq(OGGeSGkgUPtmkRfwlpvBc8bG4ayddaLb4W(Wy4ew(OGGKeQjTZLFaioaehqFdaLbGYaKpkiibl7W(74TRxHBkVjXvda2dq(OGGeSSdZOSwPMYBsC1aqCaSHbGYa2Hz7aGXaKpkiibl7WWnDIrzTWA5PAtGpaehaByaOmah2hgdNWYhfeKK2L0ox(bG4aqmR2iT)dOsCvwLnvlbsti9aSbiFuqqIEaomUcnagNhG)qc1(O2gGaNgG)oE76vd4wdqGtdq(OGGexhqlCenQnagNhGaNgqt5njUAa3AacCAamkR1aczaq)Zr0inEa9Jm9aSbOLNQnb(aqETyf0pa5gWw4GgGna4XgC6ha0pUpeNhGCdqlpvBc8biFuqqI21by6b0J48by6byda51Ivq)aw3pGynaBaYhfeKmGEbNpG7hqVGZhqDYa0ox(b0le4dWFhVD9knoR6W(uziPSQ8rbbjjOFCFioNvnVexLvDyFymCkR6W4kuI4AkRUlR6W4kuwf1SK7abZDMvnVexLvxCsd3)2sYQuzmCQLHzwYsw1FhVD9kDUZCh7YDMvPYy4uldZSQ)dH(WYQmkRfgAW52NUvA9NwWkqZQns7)aQexLv7)NexLvnVexLvHEsCvwYDGAUZSkvgdNAzyMvnVexLvjKqVE0NELIs9id6vz1gP9FavIRYQo5oE76v6SQ)dH(WYQIXPsWhdpe6njUctLXWP2aCpGxPObaRbGagG7bGYaCyFymCcRLeuUvvuBdGfRb4W(Wy4e2AnD6jKwudaXb4EaOma)D821RWqdo3(0TsR)0c(jKwu6baRbW2bWI1ayuwlm0GZTpDR06pTGvGoaehalwdyfBWL0tiTO0dawdaveMLChSl3zwLkJHtTmmZQ(pe6dlRkgNkbZ8KjWt3kPJQ922PnmvgdNAdW9aELk8jOxp6XnAf(qgqFdGDiCaUhWRuewcKusUeBhqFdyZ3gG7bGYayuwlmZtMapDRKoQ2BBN2WkqhalwdyfBWL0tiTO0dawdaveoaeZQMxIRYQesOxp6tVsrPEKb9QSK7abZDMvPYy4uldZSQ)dH(WYQIXPsWHN8gumvgdNAdW9aELIgaSga7YQMxIRYQesOxp6tVsrPEKb9QSK7GT5oZQuzmCQLHzw1)HqFyzvX4ujyMNmbE6wjDuT32oTHPYy4uBaUhakdWH9HXWjSwsq5wvrTnawSgGd7dJHtyR10PNqArnaehG7bGYa83XBxVcZ8KjWt3kPJQ922Pn8tiTO0dGfRb4VJ3UEfM5jtGNUvshv7TTtB4NSMZdW9aELk8jOxp6XnAf(qgaSgaBr4aqmRAEjUkRcn4C7t3kT(tlzj3bci3zwLkJHtTmmZQ(pe6dlRkgNkbhEYBqXuzmCQna3dy)bWOSwyObNBF6wP1FAbRanRAEjUkRcn4C7t3kT(tlzj3Htp3zwLkJHtTmmZQ(pe6dlRkgNkbFm8qO3K4kmvgdNAdW9aqzaoSpmgoH1sck3QkQTbWI1aCyFymCcBTMo9eslQbG4aCpaugGyCQe8MjWPpQTKwUhjMkJHtTb4EamkRf(jK3RjoP1PErj0JvGoawSgW(dqmovcEZe40h1wsl3JetLXWP2aqmRAEjUkRcn4C7t3kT(tlzj3bcuUZSkvgdNAzyMv9Fi0hwwLrzTWqdo3(0TsR)0cwbAw18sCvwL5jtGNUvshv7TTtBzj3r)l3zwLkJHtTmmZQ(pe6dlRAEjCqjQiKbPha6bSBaUhaJYAHHgCU9PBLw)Pf8tiTO0dawdyZ3gG7bWOSwyObNBF6wP1FAbRaDaUhW(dqmovc(y4HqVjXvyQmgo1gG7bGYa2FaVfTe5GkbBTMgtSp0IEaSynG3IwICqLGTwtJJAa9na2HWbG4ayXAaRydUKEcPfLEaWAaSlRAEjUkRU(tl9C(rQtlL35SK7yhcZDMvPYy4uldZSQ)dH(WYQMxchuIkczq6b0h6bG6aCpaugaJYAHHgCU9PBLw)PfSc0bWI1aElAjYbvc2AnnoQb03a83XBxVcdn4C7t3kT(tl4NqArPhaIdW9aqzamkRfgAW52NUvA9NwWpH0IspaynGnFBaSynG3IwICqLGTwtJFcPfLEaWAaB(2aqmRAEjUkRU(tl9C(rQtlL35SK7y3UCNzvQmgo1YWmR6)qOpSSQyCQe8XWdHEtIRWuzmCQna3dGrzTWqdo3(0TsR)0cwb6aCpaugakdGrzTWqdo3(0TsR)0c(jKwu6baRbS5BdGfRbWOSwyLc(XDoPLNQnbowb6aCpagL1cRuWpUZjT8uTjWXpH0IspaynGnFBaioa3daLb0igL1c)w)EF4jSwmpeda9ay7ayXAa7pGgzc8eevSbxWVsrR73i8B979HNgaIdaXSQ5L4QS66pT0Z5hPoTuENZsUJDOM7mRsLXWPwgMzv)hc9HLvfJtLGzEYe4PBL0r1EB70gMkJHtTb4EaVsf(e0Rh94gTcFidOVbGGiCaUhWRu0aGf6bWUb4EaOmagL1cZ8KjWt3kPJQ922PnSc0bWI1a83XBxVcZ8KjWt3kPJQ922Pn8tiTO0dOVbGGiCaioawSgW(dqmovcM5jtGNUvshv7TTtByQmgo1gG7b8kv4tqVE0JB0k8HmG(qpauzBw18sCvwfUZqpbo9idFc6tAQ8uwYDSJD5oZQuzmCQLHzw1)HqFyzvgL1cdn4C7t3kT(tlyfOzvZlXvz13cnLAK1YsUJDiyUZSkvgdNAzyMv9Fi0hww18s4GsuridspG(qpauhG7bGYayoTEaUhWk2GlPNqArPhaSga7galwdy)bWOSwyMNmbE6wjDuT32oTHvGoa3daLbaLe8g8tHJFcPfLEaWAaB(2ayXAaVfTe5GkbBTMg)eslk9aG1ay3aCpG3IwICqLGTwtJJAa9naOKG3GFkC8tiTO0daXbGyw18sCvwvB(pwHpmEcQ5LSK7yhBZDMvPYy4uldZSQ)dH(WYQMxchuIkczq6b03ay7ayXAaVsrR73imu4K9hYRinMkJHtTSQ5L4QSAJmbEYQwQrEZ5SKLSQ8rbbj6CN5o2L7mRsLXWPwgMzvZlXvz1O0(xrmgoL6NkwjkitnYr4PSAJ0(pGkXvz1o)OGGeDw1)HqFyzvgL1cdn4C7t3kT(tlyfOdGfRbi2VrcwcKusUeuVKqfHdawdGTdGfRbWCA9aCpGvSbxspH0Ispaynau3LLChOM7mRsLXWPwgMzvZlXvzv5Jccs2LvBK2)bujUkR2jCAaYhfeKmGEHaFacCAaWJn4KwgaPLaPjuBaomUc56a6fC(ayObOOP2awXRLbyvBaqT4P2a6fc8b0)do3(bCRbWM8NwWzv)hc9HLv3FaoSpmgoH1qjFScQLKpkiizaUhaJYAHHgCU9PBLw)PfSc0b4EaOmG9hGyCQeC4jVbftLXWP2ayXAaIXPsWHN8gumvgdNAdW9ayuwlm0GZTpDR06pTGFcPfLEa9HEa7q4aqCaUhakdy)biFuqqcwqfd30j)D821Rgalwdq(OGGeSGk2FhVD9k8tiTO0dGfRb4W(Wy4ew(OGGKe0pUpeNha6bSBaioawSgG8rbbjyzhMrzTsnL3K4Qb0h6bSIn4s6jKwu6SK7GD5oZQuzmCQLHzw1)HqFyz19hGd7dJHtynuYhRGAj5JccsgG7bWOSwyObNBF6wP1FAbRaDaUhakdy)bigNkbhEYBqXuzmCQnawSgGyCQeC4jVbftLXWP2aCpagL1cdn4C7t3kT(tl4NqArPhqFOhWoeoaehG7bGYa2FaYhfeKGLDy4Mo5VJ3UE1ayXAaYhfeKGLDy)D821RWpH0IspawSgGd7dJHty5Jccssq)4(qCEaOhaQdaXbWI1aKpkiiblOIzuwRut5njUAa9HEaRydUKEcPfLoRAEjUkRkFuqqcQzj3bcM7mRsLXWPwgMzvZlXvzv5Jccs2LvBK2)bujUkRYMxd4kUZd4kAaxnafnna5Jccsga0)CenspaBamkRLRdqrtdqGtd4e40pGRgG)oE76v4bGa)diwdOOqGt)aKpkiizaq)Zr0i9aSbWOSwUoafnnaMtGpGRgG)oE76v4SQ)dH(WYQ7pa5JccsWYomCtNu0uIrzTgG7bGYaKpkiiblOI93XBxVc)eslk9ayXAa7pa5JccsWcQy4MoPOPeJYAnaehalwdWFhVD9km0GZTpDR06pTGFcPfLEa9naurywYDW2CNzvQmgo1YWmR6)qOpSS6(dq(OGGeSGkgUPtkAkXOSwdW9aqzaYhfeKGLDy)D821RWpH0IspawSgW(dq(OGGeSSdd30jfnLyuwRbG4ayXAa(74TRxHHgCU9PBLw)Pf8tiTO0dOVbGkcZQMxIRYQYhfeKGAwYsw1FoOYkrN7m3XUCNzvQmgo1YWmRAEjUkR2itGRtnfkR2iT)dOsCvw1jNdQSsgGtHj4HeKoR6)qOpSSQd7dJHtyTKGYTQIABaSynah2hgdNWwRPtpH0Ikl5oqn3zwLkJHtTmmZQ(pe6dlR(kv4tqVE0JB0k8HmG(ga7gG7b4VJ3UEfgAW52NUvA9NwWpH0Ispayna2na3dy)bigNkbZ8KjWt3kPJQ922PnmvgdNAdW9aCyFymCcRLeuUvvuBzvZlXvzvDp7rg1wczOLSK7GD5oZQuzmCQLHzw1)HqFyz19hGyCQemZtMapDRKoQ2BBN2WuzmCQna3dWH9HXWjS1A60tiTOYQMxIRYQ6E2JmQTeYqlzj3bcM7mRsLXWPwgMzv)hc9HLvfJtLGzEYe4PBL0r1EB70gMkJHtTb4EaOmagL1cZ8KjWt3kPJQ922PnSc0b4EaOmah2hgdNWAjbLBvf12aCpGxPcFc61JECJwHpKb03aqqeoawSgGd7dJHtyR10PNqArna3d4vQWNGE9Oh3Ov4dza9naeachalwdWH9HXWjS1A60tiTOgG7b8w0sKdQeS1AA8tiTO0dawdO)naehalwdy)bWOSwyMNmbE6wjDuT32oTHvGoa3dWFhVD9kmZtMapDRKoQ2BBN2WpH0IspaeZQMxIRYQ6E2JmQTeYqlzj3bBZDMvPYy4uldZSQ)dH(WYQ(74TRxHHgCU9PBLw)Pf8tiTO0dawdGDdW9aCyFymCcRLeuUvvuBdW9aqzaIXPsWmpzc80Ts6OAVTDAdtLXWP2aCpGxPcFc61JECJwHpKbaRbGaq4aCpa)D821RWmpzc80Ts6OAVTDAd)eslk9aG1aqDaSynG9hGyCQemZtMapDRKoQ2BBN2WuzmCQnaeZQMxIRYQgZHmktIRs8ajtwYDGaYDMvPYy4uldZSQ)dH(WYQoSpmgoHTwtNEcPfvw18sCvw1yoKrzsCvIhizYsUdNEUZSkvgdNAzyMv9Fi0hww1FhVD9km0GZTpDR06pTGFcPfLEaWAaSBaUhGd7dJHtyTKGYTQIAlRAEjUkRQHBEi4usGtjLQ39cCNZsUdeOCNzvQmgo1YWmR6)qOpSSQd7dJHtyR10PNqArLvnVexLv1WnpeCkjWPKs17EbUZzj3r)l3zwLkJHtTmmZQ(pe6dlRU)ayuwlm0GZTpDR06pTGvGoa3daLbOpfotunmufTOWPe9kqL4kmvgdNAdGfRbOpfotunSJJBsWPK(4oOsWuzmCQnaeZQrj0)kqLuSYQ6tHZevd744MeCkPpUdQKSAuc9VcujfirsTWekRUlRAEjUkRU4KgU)TLKvJsO)vGkPn(Xy8S6USKLSQwSQzFl3zUJD5oZQuzmCQLHzw18sCvw9jK3RjoP1PErj0NvBK2)bujUkRQkw1SVnaDuBCInUy)gjd4pXK4QSQ)dH(WYQIXPsWBMaN(O2sA5EKyQmgo1galwdWFvtjem5G(1FAbtLXWP2ayXAaVsrR73imtirTL8hVHPYy4ull5oqn3zwLkJHtTmmZQ(pe6dlRU)aAKjWtquXgCb)kfTUFJWV1V3hEAaUhakdOrmkRf(T(9(WtyTyEigaSgaBhalwdOrmkRf(T(9(Wt4NqArPhaSgGtFaiMvnVexLv34MpmEYAoSYtzj3b7YDMvPYy4uldZSQ)dH(WYQ(74TRxHFc59AItADQxuc94NqArPhaSqpauhaByaB(2aCpaX4uj4ntGtFuBjTCpsmvgdNAzvZlXvz11FAjPLpGGYsUdem3zwLkJHtTmmZQ(pe6dlR6VQPecMERfEtIAlXWVEdW9ayuwlm9wl8Me1wIHF9WAX8qma0da1bWI1a8x1ucbRuCY0WPwA9u1VoJPYy4uBaUhaJYAHvkozA4ulTEQ6xNXpH0Ispayna2LvnVexLvx)PLKw(ackl5oyBUZSkvgdNAzyMv9Fi0hwwLrzTWFGKWkqZQMxIRYQWVE8O2smCtlzj3bci3zwLkJHtTmmZQ(pe6dlRU)ayuwl86V(LQeufUMWkqhG7bigNkbV(RFPkbvHRjmvgdNAdGfRbWOSwyicopQTesZdpkc)K5LbWI1aAKjWtw1snYBoJLWdruBdW9a8NdQSsWvSbxslJgG7bWOSw4gzcCDQPqyTyEigaSgacoawSgWRuewcKusUecoayHEaB(ww18sCvw9y4HqVjuwYD40ZDMvPYy4uldZSQ)dH(WYQVsf(e0Rh94gTcFidawdaLbSJTdagdqmovc(vQWNmrOsXK4kmvgdNAdGnma2naeZQMxIRYQR)0sslFabLLChiq5oZQuzmCQLHzw1)HqFyz1xPcFc61JECJwHpKb03aqzaOY2baJbigNkb)kv4tMiuPysCfMkJHtTbWgga7gaIzvZlXvz1JHhc9Mqzj3r)l3zw18sCvwD9NwsA5diOSkvgdNAzyMLCh7qyUZSQ5L4QSk87R0Ts9IsOpRsLXWPwgMzj3XUD5oZQMxIRYQ27TIsY9pvswLkJHtTmmZswYsw1b964QChOIqu3HqeaQ9VSAp7RO20zv2iNItTd2Ch9dUyadOt40acKqVxgW6(b09y4HqVjXvjO3XJAR7aEQFQep1gG(qsdWuKdPjuBaE4wTrA8aPlJIgWoxmaNCLd6fQnGUIXPsW71DaYnGUIXPsW7HPYy4uR7aqzh7repq6YOObSZfdWjx5GEHAdO7Ru06(ncVx3bi3a6(kfTUFJW7HPYy4uR7aqzh7repq6YOObSZfdWjx5GEHAdOR)QMsi496oa5gqx)vnLqW7HPYy4uR7aqzh7repqoqYg5uCQDWM7OFWfdyaDcNgqGe69Yaw3pGU(J3sWj7LUd4P(Ps8uBa6djnatroKMqTb4HB1gPXdKUmkAa7CXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdaLDShr8aPlJIgaQUyao5kh0luBaDfJtLG3R7aKBaDfJtLG3dtLXWPw3bGYo2JiEG0LrrdGDUyao5kh0luBaDfJtLG3R7aKBaDfJtLG3dtLXWPw3bGYo2JiEG0LrrdabDXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdaLDShr8a5ajBKtXP2bBUJ(bxmGb0jCAabsO3ldyD)a6Em8qO3K4QUd4P(Ps8uBa6djnatroKMqTb4HB1gPXdKUmkAa7CXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdaLDShr8aPlJIgWoxmaNCLd6fQnGUVsrR73i8EDhGCdO7Ru06(ncVhMkJHtTUdaLDShr8aPlJIgWoxmaNCLd6fQnGU(RAkHG3R7aKBaD9x1ucbVhMkJHtTUdaLDShr8aPlJIgacWfdWjx5GEHAdOR)QMsi496oa5gqx)vnLqW7HPYy4uR7aqbv2JiEG0LrrdO)5Ib4KRCqVqTb0vmovcEVUdqUb0vmovcEpmvgdNADhakOYEeXdKdKSrofNAhS5o6hCXagqNWPbeiHEVmG19dOlZPts4HiQTUd4P(Ps8uBa6djnatroKMqTb4HB1gPXdKUmkAaO6Ib4KRCqVqTb0vmovcEVUdqUb0vmovcEpmvgdNADhakOYEeXdKUmkAaO6Ib4KRCqVqTb09vkAD)gH3R7aKBaDFLIw3Vr49WuzmCQ1DaOGk7repq6YOObGQlgGtUYb9c1gqx)vnLqW71DaYnGU(RAkHG3dtLXWPw3bGcQShr8a5ajBKtXP2bBUJ(bxmGb0jCAabsO3ldyD)a66phuzLO7oGN6NkXtTbOpK0amf5qAc1gGhUvBKgpq6YOObGQlgGtUYb9c1gqxX4uj496oa5gqxX4uj49WuzmCQ1DaOSJ9iIhiDzu0ayNlgGtUYb9c1gqxX4uj496oa5gqxX4uj49WuzmCQ1DaOSJ9iIhiDzu0aqqxmaNCLd6fQnGUIXPsW71DaYnGUIXPsW7HPYy4uR7aqzh7repq6YOObWwxmaNCLd6fQnGUIXPsW71DaYnGUIXPsW7HPYy4uR7aqbv2JiEG0LrrdO)5Ib4KRCqVqTb0vFkCMOA496oa5gqx9PWzIQH3dtLXWPw3bGcQShr8a5ajBKtXP2bBUJ(bxmGb0jCAabsO3ldyD)a6QfRA236oGN6NkXtTbOpK0amf5qAc1gGhUvBKgpq6YOObSZfdWjx5GEHAdORyCQe8EDhGCdORyCQe8EyQmgo16oau2XEeXdKUmkAa7CXaCYvoOxO2a6(kfTUFJW71DaYnGUVsrR73i8EyQmgo16oatgaBkcSlhak7ypI4bsxgfnGDUyao5kh0luBaD9x1ucbVx3bi3a66VQPecEpmvgdNADhak7ypI4bsxgfna25Ib4KRCqVqTb0vmovcEVUdqUb0vmovcEpmvgdNADhGjdGnfb2LdaLDShr8aPlJIgac6Ib4KRCqVqTb01Fvtje8EDhGCdOR)QMsi49WuzmCQ1DaOSJ9iIhiDzu0aqaUyao5kh0luBaDfJtLG3R7aKBaDfJtLG3dtLXWPw3bGYo2JiEG0LrrdWP7Ib4KRCqVqTb0vmovcEVUdqUb0vmovcEpmvgdNADhak7ypI4bsxgfnaeixmaNCLd6fQnGUIXPsW71DaYnGUIXPsW7HPYy4uR7aqzh7repqoqYg5uCQDWM7OFWfdyaDcNgqGe69Yaw3pGUmNob9oEuBDhWt9tL4P2a0hsAaMICinHAdWd3QnsJhiDzu0aq1fdWjx5GEHAdORyCQe8EDhGCdORyCQe8EyQmgo16oau2XEeXdKUmkAaO6Ib4KRCqVqTb09vkAD)gH3R7aKBaDFLIw3Vr49WuzmCQ1DaOSJ9iIhiDzu0aq1fdWjx5GEHAdOR)QMsi496oa5gqx)vnLqW7HPYy4uR7aqzh7repq6YOObGaCXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdaLDShr8aPlJIgGt3fdWjx5GEHAdORyCQe8EDhGCdORyCQe8EyQmgo16oau2XEeXdKdKSrofNAhS5o6hCXagqNWPbeiHEVmG19dOl0N8hsgt6oGN6NkXtTbOpK0amf5qAc1gGhUvBKgpq6YOObSZfdWjx5GEHAdqnq6KbODUeJ9dWP50gGCdWLk2aqEnfUIEahu6n5(bGItdXbGcQShr8aPlJIgWoxmaNCLd6fQnGUIXPsW71DaYnGUIXPsW7HPYy4uR7aqHDShr8aPlJIgWoxmaNCLd6fQnGUYhfeKG3H3R7aKBaDLpkiibl7W71DaOWo2JiEG0LrrdavxmaNCLd6fQna1aPtgG25sm2paNMtBaYnaxQyda51u4k6bCqP3K7hakonehakOYEeXdKUmkAaO6Ib4KRCqVqTb0vmovcEVUdqUb0vmovcEpmvgdNADhakSJ9iIhiDzu0aq1fdWjx5GEHAdOR8rbbjyuX71DaYnGUYhfeKGfuX71DaOWo2JiEG0LrrdGDUyao5kh0luBaQbsNmaTZLySFaoTbi3aCPInGw4i0Xvd4GsVj3pauGnIdafuzpI4bsxgfna25Ib4KRCqVqTb0v(OGGe8o8EDhGCdOR8rbbjyzhEVUdafeK9iIhiDzu0ayNlgGtUYb9c1gqx5JccsWOI3R7aKBaDLpkiiblOI3R7aqHTShr8a5ajBKtXP2bBUJ(bxmGb0jCAabsO3ldyD)a66VJ3UELU7aEQFQep1gG(qsdWuKdPjuBaE4wTrA8aPlJIgaQUyao5kh0luBaDfJtLG3R7aKBaDfJtLG3dtLXWPw3bGYo2JiEG0LrrdGDUyao5kh0luBaDfJtLG3R7aKBaDfJtLG3dtLXWPw3bGYo2JiEG0LrrdabDXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdaLDShr8aPlJIgaBDXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdaLDShr8aPlJIgacWfdWjx5GEHAdORyCQe8EDhGCdORyCQe8EyQmgo16oau2XEeXdKUmkAaoDxmaNCLd6fQnGUIXPsW71DaYnGUIXPsW7HPYy4uR7aqzh7repq6YOOb0)CXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdaLDShr8aPlJIgWUDUyao5kh0luBaDfJtLG3R7aKBaDfJtLG3dtLXWPw3bGYo2JiEG0LrrdyhQUyao5kh0luBaDfJtLG3R7aKBaDfJtLG3dtLXWPw3bGcQShr8aPlJIgWo26Ib4KRCqVqTb09vkAD)gH3R7aKBaDFLIw3Vr49WuzmCQ1DaMma2ueyxoau2XEeXdKdKSrofNAhS5o6hCXagqNWPbeiHEVmG19dOR8rbbj6Ud4P(Ps8uBa6djnatroKMqTb4HB1gPXdKUmkAaO6Ib4KRCqVqTb0vmovcEVUdqUb0vmovcEpmvgdNADhakOYEeXdKUmkAaO6Ib4KRCqVqTb0v(OGGe8o8EDhGCdOR8rbbjyzhEVUdaLDShr8aPlJIgaQUyao5kh0luBaDLpkiibJkEVUdqUb0v(OGGeSGkEVUdafuzpI4bsxgfna25Ib4KRCqVqTb0vmovcEVUdqUb0vmovcEpmvgdNADhakOYEeXdKUmkAaSZfdWjx5GEHAdOR8rbbj4D496oa5gqx5JccsWYo8EDhakOYEeXdKUmkAaSZfdWjx5GEHAdOR8rbbjyuX71DaYnGUYhfeKGfuX71DaOSJ9iIhiDzu0aqqxmaNCLd6fQnGUYhfeKG3H3R7aKBaDLpkiibl7W71DaOSJ9iIhiDzu0aqqxmaNCLd6fQnGUYhfeKGrfVx3bi3a6kFuqqcwqfVx3bGcQShr8aPlJIgaBDXaCYvoOxO2a6kFuqqcEhEVUdqUb0v(OGGeSSdVx3bGcQShr8aPlJIgaBDXaCYvoOxO2a6kFuqqcgv8EDhGCdOR8rbbjybv8EDhak7ypI4bYbs2iNItTd2Ch9dUyadOt40acKqVxgW6(b0TrltHlDhWt9tL4P2a0hsAaMICinHAdWd3QnsJhiDzu0ayRlgGtUYb9c1gqxX4uj496oa5gqxX4uj49WuzmCQ1DaOGk7repq6YOObGaCXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdaf2XEeXdKUmkAaoDxmaNCLd6fQnGUIXPsW71DaYnGUIXPsW7HPYy4uR7aqzh7repq6YOObGa5Ib4KRCqVqTb0vmovcEVUdqUb0vmovcEpmvgdNADhak7ypI4bsxgfnGDSZfdWjx5GEHAdORyCQe8EDhGCdORyCQe8EyQmgo16oau2XEeXdKUmkAa7yRlgGtUYb9c1gqxX4uj496oa5gqxX4uj49WuzmCQ1DaOSJ9iIhiDzu0a2HaCXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdWKbWMIa7YbGYo2JiEG0LrrdyNt3fdWjx5GEHAdORyCQe8EDhGCdORyCQe8EyQmgo16oau2XEeXdKdKSrofNAhS5o6hCXagqNWPbeiHEVmG19dORDu3b8u)ujEQna9HKgGPihstO2a8WTAJ04bsxgfnauDXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdWKbWMIa7YbGYo2JiEG0LrrdGDUyao5kh0luBaDfJtLG3R7aKBaDfJtLG3dtLXWPw3byYaytrGD5aqzh7repq6YOOb40DXaCYvoOxO2a6kgNkbVx3bi3a6kgNkbVhMkJHtTUdaLDShr8aPlJIgacKlgGtUYb9c1gqxX4uj496oa5gqxX4uj49WuzmCQ1DaOSJ9iIhiDzu0a2HqxmaNCLd6fQnGUIXPsW71DaYnGUIXPsW7HPYy4uR7aqzh7repqoq2jCAaDv0ukecPU7amVexnGEMEa1jdyDkvBarnabEOhqGe69cEGKnJe69c1gWo2naZlXvdGhArJhiZQq)BfCkR2F93a6htMaFaSXwXgCzaSj)PLbY(R)gaKkCNhaBDDaOIqu3nqoq2F93aCcCR2i9az)1FdGn(aCQeYZb1ga30cBCn5VQnafTTrd4wdWjWTO0d4wdGn7Pby6beYaAhPRUYaGYnNhqpIZhquda6BEj8eEGCGS)gaBQdJRycPhGna5Jccs0dWFhVD9kxhqlCenQnagNha0GZTFa3AaR)0YaUFampzc8bCRbOJQ922PTU6b4VJ3UEfEaS51acPREaomUcna4MEa1nGNqAr1OFapjkFnGDUoaIRPb8KO81aqiMT4bsZlXvAm0N8hsgtGbAy7W(Wy4KRLHKqlFuqqsAxs7C5D9GIwtsSC1HXvi07C1HXvOeX1eAeIzRR(RAHexHw(OGGe8omCtNu0uIrzTCJY(IXPsWmpzc80Ts6OAVTDAZnkYhfeKG3H93XBxVc3uEtIRCAon)D821RWqdo3(0TsR)0cUP8MexHgHiYILyCQemZtMapDRKoQ2BBN2CJI)oE76vyMNmbE6wjDuT32oTHBkVjXvonNM8rbbj4Dy)D821RWnL3K4k0ierwSeJtLGdp5nOioqAEjUsJH(K)qYycmqdBh2hgdNCTmKeA5JccssOM0oxExpOO1KelxDyCfc9oxDyCfkrCnHgHy26Q)QwiXvOLpkiibJkgUPtkAkXOSwUrzFX4ujyMNmbE6wjDuT32oT5gf5JccsWOI93XBxVc3uEtIRCAon)D821RWqdo3(0TsR)0cUP8MexHgHiYILyCQemZtMapDRKoQ2BBN2CJI)oE76vyMNmbE6wjDuT32oTHBkVjXvonNM8rbbjyuX(74TRxHBkVjXvOriISyjgNkbhEYBqrCGS)gaBQwcKMq6bydq(OGGe9aCyCfAamopa)HeQ9rTnabona)D821RgWTgGaNgG8rbbjUoGw4iAuBamopabonGMYBsC1aU1ae40ayuwRbeYaG(NJOrA8a6hz6bydqlpvBc8bG8AXkOFaYnGTWbnaBaWJn40paOFCFiopa5gGwEQ2e4dq(OGGeTRdW0dOhX5dW0dWgaYRfRG(bSUFaXAa2aKpkiiza9coFa3pGEbNpG6KbODU8dOxiWhG)oE76vA8aP5L4kng6t(djJjWanSDyFymCY1YqsOLpkiijb9J7dXzxpOO1KelxDyCfcnQU6W4kuI4Ac9ox9x1cjUc9(YhfeKG3HHB6KIMsmkRLB5JccsWOIHB6KIMsmkRflwYhfeKGrfd30jfnLyuwl3OGI8rbbjyuX(74TRxHBkVjXvon5JccsWOIzuwRut5njUcr2ak7WSfgYhfeKGrfd30jgL1cRLNQnboISbuCyFymCclFuqqsc1K25YJiI9HckYhfeKG3H93XBxVc3uEtIRCAYhfeKG3HzuwRut5njUcr2ak7WSfgYhfeKG3HHB6eJYAH1Yt1Mahr2akoSpmgoHLpkiijTlPDU8iI4aP5L4kng6t(djJjWanSxCsd3)2sgihi7V(BaSPSN8kc1ga5GENhGeiPbiWPbyE5(be6byoSGBmCcpqAEjUsJgzuT06jQFPbY(Ba9)NCqLmanuYhRGAdq(OGGe9ayOO2gGIMAdOxiWhGPihstc)a4rr6bsZlXvAyGg2oSpmgo5Azij0AOKpwb1sYhfeK4QdJRqOrH6NkbuOudhL2)kIXWPu)uXkrbzQrocp52FhVD9kCuA)RigdNs9tfRefKPg5i8e(jR5mIdKMxIR0WanSDyFymCY1YqsO1sck3QkQnxDyCfcT5LWbLOIqgKg9o3O8w0sKdQeS1AACu9TJTSyT)BrlroOsWwRPXe7dTOrCG08sCLggOHTd7dJHtUwgscT1A60tiTOC1HXvi0MxchuIkczq6(qJQBu2)TOLihujyR10yI9Hw0Sy9w0sKdQeS1AAmX(qlA3O8w0sKdQeS1AA8tiTO09XwwSwXgCj9eslkDF7qiIioq2FdWPafk35bWM8NwgaBc5GExhaslkXIAaSzVZdOtJFLEaw1gaeebDaovc59AItA9ayJIsOFa)X5rTnqAEjUsdd0W(jK3RjoP1PErj07ASq7VQPecMCq)6pT4wmovcEZe40h1wsl3J09(IXPsWhdpe6njUYT)oE76vyObNBF6wP1FAb)eslk9aP5L4knmqdB4xpEuBjgUPfx9o75usSFJen6DUgl0TtWR)0sAroOh)06jnCJHtUrrmovco8K3GYI1(mkRfM5jtGNUvshv7TTtByfOUfJtLGzEYe4PBL0r1EB70glwIXPsWhdpe6njUYT)oE76vyObNBF6wP1FAb)eslkT79zuwlmebNh1wcP5HhfHvGI4aP5L4knmqd7nU5dJNSMdR8KRXcnJYAHdVZjX4xPXpH0Isdl0B(MBgL1chENtIXVsJvG6wdL48Ky)gjA8g38HXtwZHvEQp0O6gL9fJtLGzEYe4PBL0r1EB70glw(74TRxHzEYe4PBL0r1EB70g(jKwu6(2XwehinVexPHbAyV(tljT8beKRXcnJYAHdVZjX4xPXpH0Isdl0B(MBgL1chENtIXVsJvG6gL9fJtLGzEYe4PBL0r1EB70glw(74TRxHzEYe4PBL0r1EB70g(jKwu6(2Xwehi7Vb4e43PPb4u8sC1a4HwgGCd4vQbsZlXvAyGg2EJZtMxIRs8qlUwgscT)CqLvIEG08sCLggOHT348K5L4Qep0IRLHKq)MpmUEG08sCLggOHT348K5L4Qep0IRLHKqlFuqqIEG08sCLggOHT348K5L4Qep0IRLHKq7VJ3UELEG08sCLggOHT348K5L4Qep0IRLHKq7pElbNSxCnwOfJtLG9hVLGt2lUzuwlS)4TeCYEbRfZdrFO3Hq3O0igL1c)w)EF4jSwmpeOzllw73itGNGOIn4c(vkAD)gHFRFVp8eISyXCAT7vSbxspH0Isdl0B(2aP5L4knmqd7xPsMxIRs8qlUwgscnZPts4HiQnxJfAgL1cZ8KjWt3kPJQ922PnSc0bsZlXvAyGg2VsLmVexL4HwCTmKeAMtNGEhpQnxJfAX4ujyMNmbE6wjDuT32oT5gf)D821RWmpzc80Ts6OAVTDAd)eslknS2HqeDJYBrlroOsWwRPXr1hQSLfR9FlAjYbvc2AnnMyFOfnlw(74TRxHHgCU9PBLw)Pf8tiTO0WAhcD)w0sKdQeS1AAmX(qlA3VfTe5GkbBTMghfS2HqehinVexPHbAy)kvY8sCvIhAX1YqsOpgEi0BsCLRXcnJYAHHgCU9PBLw)PfScu3IXPsWhdpe6njUAG08sCLggOH9RujZlXvjEOfxldjH(y4HqVjXvjO3XJAZ1yHwmovc(y4HqVjXvU93XBxVcdn4C7t3kT(tl4NqArPH1oe6gfh2hgdNWAjbLBvf1glwVfTe5GkbBTMgtSp0I29BrlroOsWwRPXrbRDiKfR9FlAjYbvc2AnnMyFOfnIdKMxIR0WanSFLkzEjUkXdT4Azij02rUgl0MxchuIkczq6(qJ6aP5L4knmqdBVX5jZlXvjEOfxldjHwlw1SVnqoq2FdWPCSPdWPEIjXvdKMxIR0y7i0pH8EnXjTo1lkH(bsZlXvASDemqd7nU5dJNSMdR8KRXcTyCQe86pTO9olWPbsZlXvASDemqd71FAjPLpGGC17SNtjX(ns0O35ASq7VJ3UEf(jK3RjoP1PErj0JFcPfLgwOrLnS5BUfJtLG3mbo9rTL0Y9ihinVexPX2rWanSHF94rTLy4MwCnwOzuwl8hijSc0bsZlXvASDemqd7JHhc9MqUgl0nYe4jRAPg5nNXs4HiQn3(Zbvwj4k2GlPLrUzuwlCJmbUo1uiSwmpeWcbhinVexPX2rWanSx)PfT3zbo5ASqZOSwyicopQTesZdpkc)K5f3OSFJmbEYQwQrEZzSeEiIAZT)CqLvcUIn4sAzelw77phuzLGRydUKwgH4aP5L4kn2ocgOH9g38HXtwZHvEY1yH(vQWNGE9Oh3Ov4dbwOSJTWqmovc(vQWNmrOsXK4k2a7qCG08sCLgBhbd0WE9NwsA5diix9o75usSFJen6DUgl0Vsf(e0Rh94gTcFiWcLDSfgIXPsWVsf(KjcvkMexXgyhIdKMxIR0y7iyGg2R)0I27SaNCnwO3VrMapzvl1iV5mwcperT52FoOYkbxXgCjTmIfR99NdQSsWvSbxslJginVexPX2rWanSpgEi0Bc5Q3zpNsI9BKOrVZ1yH(vQWNGE9Oh3Ov4dPpuqLTWqmovc(vQWNmrOsXK4k2a7qCG08sCLgBhbd0WEJB(W4jR5WkpnqAEjUsJTJGbAyV(tljT8beKREN9Ckj2VrIg9UbsZlXvASDemqdB43xPBL6fLq)aP5L4kn2ocgOHT9EROKC)tLmqoq2FdaMpzc8bCRbOgv7TTtBda6D8O2gWFIjXvdWfdql2l6bSdH6bWqR7PbaZtDaHEaMdl4gdNginVexPXmNob9oEuBOHF94rTLy4MwCnwOzuwl8hijSc0bsZlXvAmZPtqVJh1gmqd7NqEVM4KwN6fLqVRXcT5LWbLOIqgKUp0OYI1RuewcKusUeBHf6nFZnkIXPsWBMaN(O2sA5EKSy5VQPecMCq)6pTWI1Ru06(ncZesuBj)XBioq2FdORy)gjPyHgPXExGsJyuwl8B979HNWAX8qaJDi60qPrmkRf(T(9(Wt4NqArPHXoezdnYe4jiQydUGFLIw3Vr43637dp1DaovckzIEa2a4N46ae4HEaHEarju1O2aKBaI9BKmabona4XgCslda6h3hIZdGkcPZdOxiWhGvdWycEiopabUjdOxW5dWGcL78aERFVp80aI1aELIw3Vrn8a6eUjdGHIABawnaQiKopGEHaFaiCaAX8qODDa3paRgavesNhGa3KbiWPb0igL1Aa9coFa67QbqShA80aUcpqAEjUsJzoDc6D8O2GbAyFm8qO3eYvVZEoLe73irJENRXc9RuHpb96rpUrRWhsFOrLTdKMxIR0yMtNGEhpQnyGg2BCZhgpznhw5jxJf6xPcFc61JECJwHpeyHkcDRHsCEsSFJenEJB(W4jR5Wkp1hAuD7VJ3UEfgAW52NUvA9NwWpH0Is3hBhinVexPXmNob9oEuBWanSx)PLKw(acYvVZEoLe73irJENRXc9RuHpb96rpUrRWhcSqfHU93XBxVcdn4C7t3kT(tl4NqArP7JTdKMxIR0yMtNGEhpQnyGg2R)0I27SaNCnwOzuwlmebNh1wcP5HhfHFY8I7xPcFc61JECJwHpK(qzhBHHyCQe8RuHpzIqLIjXvSb2HOBnuIZtI9BKOXR)0I27SaN6dnQUrHrzTWnYe46utHWAX8qGgbzXA)gzc8KvTuJ8MZyj8qe1glw77phuzLGRydUKwgH4aP5L4knM50jO3XJAdgOH96pTO9olWjxJf6xPcFc61JECJwHpK(qJc7ylmeJtLGFLk8jteQumjUInWoeDRHsCEsSFJenE9Nw0ENf4uFOr1nkmkRfUrMaxNAkewlMhc0iilw73itGNSQLAK3CglHhIO2yXAF)5GkReCfBWL0YiehinVexPXmNob9oEuBWanS34MpmEYAoSYtUgl0(74TRxHHgCU9PBLw)Pf8tiTO099kfHLajLKlHGUFLk8jOxp6XnAf(qGfcIq3AOeNNe73irJ34MpmEYAoSYt9Hg1bsZlXvAmZPtqVJh1gmqd71FAjPLpGGC17SNtjX(ns0O35ASq7VJ3UEfgAW52NUvA9NwWpH0Is33RuewcKusUec6(vQWNGE9Oh3Ov4dbwiichihi7VbaZNmb(aU1auJQ922PTb4u8s4GgGt9etIRginVexPXmNojHhIO2qFm8qO3eYvVZEoLe73irJENRXc9RuHpb96rpUrRWhsFOraiCG08sCLgZC6KeEiIAdgOH9tiVxtCsRt9IsO31yHwmovcEZe40h1wsl3JKfl)vnLqWKd6x)PfwSELIw3VryMqIAl5pEJflZlHdkrfHmiDFOrLfR9fJtLG3mbo9rTL0Y9iDVV)QMsiyYb9R)0I79FLIw3VryMqIAl5pEZ9RuHpb96rpSyhQdKMxIR0yMtNKWdruBWanSBKjWtw1snYBo7ASq)kv4tqVE0dl2H6aP5L4knM50jj8qe1gmqdB4xpEuBjgUPfxJfAgL1c)bscRa1nkVsf(e0Rh94gTcFiWITSLfRxPiSeiPKCj2bl0B(glwAOeNNe73irJHF94rTLy4Mw6dnQiYI1RuHpb96rpSyhQdKMxIR0yMtNKWdruBWanSx)PfT3zbo5ASqZOSwyicopQTesZdpkcRa1TgkX5jX(ns041FAr7DwGt9Hgv3OSFJmbEYQwQrEZzSeEiIAZT)CqLvcUIn4sAzelw77phuzLGRydUKwgH4aP5L4knM50jj8qe1gmqdB43xPBL6fLqVRXc9RuHpb96rpUrRWhsFOrqe6(vkclbskjxID9T5BdKMxIR0yMtNKWdruBWanSx)PfT3zbo5ASqRHsCEsSFJenE9Nw0ENf4uFOr1nkmkRfUrMaxNAkewlMhc0iilw73itGNSQLAK3CglHhIO2yXAF)5GkReCfBWL0YiehinVexPXmNojHhIO2GbAyFm8qO3eYvVZEoLe73irJENRXc9RuHpb96rpUrRWhsFOYwwSELIWsGKsYLyhS28TbsZlXvAmZPts4HiQnyGg2WVE8O2smCtlUgl0mkRf(dKewb6aP5L4knM50jj8qe1gmqdB79wrj5(NkX1yH(vQWNGE9Oh3Ov4dPp2IWbYbY(R)gGtoEBa9Ji7Lb4KRAHexPhi7V(BaMxIR0y)XBj4K9cApClkD6wPWtUgl0RydUKEcPfLgwB(2az)na2yOPb0u(O2gq)p4C7hqVqGpa2SN8guydZNmb(aP5L4kn2F8wcozVad0W2d3IsNUvk8KRXc9(IXPsWhdpe6njUYnJYAHHgCU9PBLw)Pf8tiTO0WIDUzuwlm0GZTpDR06pTGvG6MrzTW(J3sWj7fSwmpe9HEhchi7VbGaRi6Ord4wdO)hCU9dqrt2gnGEHaFaSzp5nOWgMpzc8bsZlXvAS)4TeCYEbgOHThUfLoDRu4jxJf69fJtLGpgEi0BsCL7gzc8eevSbxWVsrR73i8Y4CQs(xrBn6DVpJYAHHgCU9PBLw)PfScu3OWOSwy)XBj4K9cwlMhI(qVdb4MrzTWkf8J7CslpvBcCScuwSyuwlS)4TeCYEbRfZdrFO31)C7VJ3UEfgAW52NUvA9NwWpH0Is33oeI4aP5L4kn2F8wcozVad0W2d3IsNUvk8KRXc9(IXPsWhdpe6njUY9(nYe4jiQydUGFLIw3Vr4LX5uL8VI2A07MrzTW(J3sWj7fSwmpe9HEhcDVpJYAHHgCU9PBLw)PfScu3(74TRxHHgCU9PBLw)Pf8tiTO09Hkchi7Vb0)FYbvYaCYXBdOFezVmGZb9Edk0O2gqt5JABaqdo3(bsZlXvAS)4TeCYEbgOHThUfLoDRu4jxJfAX4uj4JHhc9Mex5EFgL1cdn4C7t3kT(tlyfOUrHrzTW(J3sWj7fSwmpe9HEhcWnJYAHvk4h35KwEQ2e4yfOSyXOSwy)XBj4K9cwlMhI(qVR)XIL)oE76vyObNBF6wP1FAb)eslknSyNBgL1c7pElbNSxWAX8q0h6DiiIdKdK93a6)NexnqAEjUsJ93XBxVsJg6jXvUgl0mkRfgAW52NUvA9NwWkqhi7Vb4K74TRxPhinVexPX(74TRxPHbAytiHE9Op9kfL6rg0RCnwOfJtLGpgEi0BsCL7xPiyHaCJId7dJHtyTKGYTQIAJflh2hgdNWwRPtpH0Icr3O4VJ3UEfgAW52NUvA9NwWpH0Isdl2YIfJYAHHgCU9PBLw)PfScuezXAfBWL0tiTO0WcveoqAEjUsJ93XBxVsdd0WMqc96rF6vkk1JmOx5ASqlgNkbZ8KjWt3kPJQ922Pn3Vsf(e0Rh94gTcFi9Xoe6(vkclbskjxIT9T5BUrHrzTWmpzc80Ts6OAVTDAdRaLfRvSbxspH0IsdluriIdKMxIR0y)D821R0WanSjKqVE0NELIs9id6vUgl0IXPsWHN8gu3VsrWIDdKMxIR0y)D821R0WanSHgCU9PBLw)PfxJfAX4ujyMNmbE6wjDuT32oT5gfh2hgdNWAjbLBvf1glwoSpmgoHTwtNEcPffIUrXFhVD9kmZtMapDRKoQ2BBN2WpH0IsZIL)oE76vyMNmbE6wjDuT32oTHFYAo7(vQWNGE9Oh3Ov4dbwSfHioqAEjUsJ93XBxVsdd0WgAW52NUvA9NwCnwOfJtLGdp5nOU3NrzTWqdo3(0TsR)0cwb6aP5L4kn2FhVD9knmqdBObNBF6wP1FAX1yHwmovc(y4HqVjXvUrXH9HXWjSwsq5wvrTXILd7dJHtyR10PNqArHOBueJtLG3mbo9rTL0Y9iXuzmCQ5MrzTWpH8EnXjTo1lkHEScuwS2xmovcEZe40h1wsl3JetLXWPgIdKMxIR0y)D821R0WanSzEYe4PBL0r1EB70MRXcnJYAHHgCU9PBLw)PfSc0bsZlXvAS)oE76vAyGg2R)0spNFK60s5D21yH28s4GsuridsJENBgL1cdn4C7t3kT(tl4NqArPH1MV5MrzTWqdo3(0TsR)0cwbQ79fJtLGpgEi0BsCLBu2)TOLihujyR10yI9Hw0Sy9w0sKdQeS1AACu9XoeIilwRydUKEcPfLgwSBG08sCLg7VJ3UELggOH96pT0Z5hPoTuENDnwOnVeoOeveYG09Hgv3OWOSwyObNBF6wP1FAbRaLfR3IwICqLGTwtJJQp)D821RWqdo3(0TsR)0c(jKwuAeDJcJYAHHgCU9PBLw)Pf8tiTO0WAZ3yX6TOLihujyR104NqArPH1MVH4aP5L4kn2FhVD9knmqd71FAPNZpsDAP8o7ASqlgNkbFm8qO3K4k3mkRfgAW52NUvA9NwWkqDJckmkRfgAW52NUvA9NwWpH0IsdRnFJflgL1cRuWpUZjT8uTjWXkqDZOSwyLc(XDoPLNQnbo(jKwuAyT5Bi6gLgXOSw43637dpH1I5HanBzXA)gzc8eevSbxWVsrR73i8B979HNqeXbsZlXvAS)oE76vAyGg2WDg6jWPhz4tqFstLNCnwOfJtLGzEYe4PBL0r1EB70M7xPcFc61JECJwHpK(qqe6(vkcwOzNBuyuwlmZtMapDRKoQ2BBN2WkqzXYFhVD9kmZtMapDRKoQ2BBN2WpH0Is3hcIqezXAFX4ujyMNmbE6wjDuT32oT5(vQWNGE9Oh3Ov4dPp0OY2bsZlXvAS)oE76vAyGg2VfAk1iR5ASqZOSwyObNBF6wP1FAbRaDG08sCLg7VJ3UELggOHT28FScFy8euZlUgl0MxchuIkczq6(qJQBuyoT29k2GlPNqArPHf7yXAFgL1cZ8KjWt3kPJQ922PnScu3OaLe8g8tHJFcPfLgwB(glwVfTe5GkbBTMg)eslknSyN73IwICqLGTwtJJQpOKG3GFkC8tiTO0iI4aP5L4kn2FhVD9knmqd7gzc8KvTuJ8MZUgl0MxchuIkczq6(yllwVsrR73imu4K9hYRi9a5az)naNCoOYkzaofMGhsq6bsZlXvAS)CqLvIgDJmbUo1uixJfAh2hgdNWAjbLBvf1glwoSpmgoHTwtNEcPf1aP5L4kn2FoOYkrdd0Ww3ZEKrTLqgAX1yH(vQWNGE9Oh3Ov4dPp252FhVD9km0GZTpDR06pTGFcPfLgwSZ9(IXPsWmpzc80Ts6OAVTDAZTd7dJHtyTKGYTQIABG08sCLg7phuzLOHbAyR7zpYO2sidT4ASqVVyCQemZtMapDRKoQ2BBN2C7W(Wy4e2AnD6jKwudKMxIR0y)5GkRenmqdBDp7rg1wczOfxJfAX4ujyMNmbE6wjDuT32oT5gfgL1cZ8KjWt3kPJQ922PnScu3O4W(Wy4ewljOCRQO2C)kv4tqVE0JB0k8H0hcIqwSCyFymCcBTMo9eslk3Vsf(e0Rh94gTcFi9HaqilwoSpmgoHTwtNEcPfL73IwICqLGTwtJFcPfLgw9pezXAFgL1cZ8KjWt3kPJQ922PnScu3(74TRxHzEYe4PBL0r1EB70g(jKwuAehinVexPX(ZbvwjAyGg2gZHmktIRs8ajJRXcT)oE76vyObNBF6wP1FAb)eslknSyNBh2hgdNWAjbLBvf1MBueJtLGzEYe4PBL0r1EB70M7xPcFc61JECJwHpeyHaqOB)D821RWmpzc80Ts6OAVTDAd)eslknSqLfR9fJtLGzEYe4PBL0r1EB70gIdKMxIR0y)5GkRenmqdBJ5qgLjXvjEGKX1yH2H9HXWjS1A60tiTOginVexPX(ZbvwjAyGg2A4MhcoLe4usP6DVa3zxJfA)D821RWqdo3(0TsR)0c(jKwuAyXo3oSpmgoH1sck3QkQTbsZlXvAS)CqLvIggOHTgU5HGtjboLuQE3lWD21yH2H9HXWjS1A60tiTOginVexPX(ZbvwjAyGg2loPH7FBjUgl07ZOSwyObNBF6wP1FAbRa1nk6tHZevddvrlkCkrVcujUIfl9PWzIQHDCCtcoL0h3bvcIUgLq)RavsbsKulmHqVZ1Oe6FfOsAJFmgh9oxJsO)vGkPyHwFkCMOAyhh3KGtj9XDqLmqoq2FdabMHhc9MexnG)etIRginVexPXhdpe6njUc9tiVxtCsRt9IsO31yH28s4Gsurids3hA25gfX4uj4ntGtFuBjTCpswS8x1ucbtoOF9NwyX6vkAD)gHzcjQTK)4nehinVexPXhdpe6njUcgOHn8RhpQTed30IREN9Ckj2VrIg9oxJf69BNGx)PL0ICqpwcperT5EFgL1cdrW5rTLqAE4rryfOUFLI6dn7ginVexPXhdpe6njUcgOH96pTO9olWjxJfAgL1cdrW5rTLqAE4rr4NmV4wdL48Ky)gjA86pTO9olWP(qJQBuyuwlCJmbUo1uiSwmpeOrqwS2VrMapzvl1iV5mwcperTXI1((Zbvwj4k2GlPLrioqAEjUsJpgEi0BsCfmqd7JHhc9MqU6D2ZPKy)gjA07CnwOzuwlmebNh1wcP5HhfHFY8clw7ZOSw4pqsyfOU1qjopj2VrIgd)6XJAlXWnT0hA2nqAEjUsJpgEi0BsCfmqd7nU5dJNSMdR8KRXcTgkX5jX(ns04nU5dJNSMdR8uFOr1nkVsf(e0Rh94gTcFiWAhczX6vkclbskjxc1(28nezXcLgXOSw43637dpH1I5HawSLfRgXOSw43637dpHFcPfLgw7ylIdKMxIR04JHhc9Mexbd0WE9NwsA5diixJfAZlHdkrfHmin6DUrXFvtjem9wl8Me1wIHF9CZOSwy6Tw4njQTed)6H1I5HanQSy5VQPecwP4KPHtT06PQFD2nJYAHvkozA4ulTEQ6xNXpH0IsdRnFdXbsZlXvA8XWdHEtIRGbAyd)6XJAlXWnT4ASqZOSw4pqsyfOU1qjopj2VrIgd)6XJAlXWnT0hAuhinVexPXhdpe6njUcgOH9g38HXtwZHvEY1yHwdL48Ky)gjA8g38HXtwZHvEQp0OoqAEjUsJpgEi0BsCfmqd71FAjPLpGGC17SNtjX(ns0O35ASqVVyCQeS5W4w5HtU3NrzTWqeCEuBjKMhEuewbklwIXPsWMdJBLho5EFgL1c)bscRaLflgL1c)bscRa19RuewcKusUeQ9HEZ3ginVexPXhdpe6njUcgOHn8RhpQTed30IRXcnJYAH)ajHvGoqAEjUsJpgEi0BsCfmqd7JHhc9MqU6D2ZPKy)gjA07gihi7Vb0)VJh12aytUFaiWm8qO3K4kxmavXErpGDiCaAYFvtpagADpnG(FW52pGBna2K)0Ya8hsspGBTgGt6hpqAEjUsJpgEi0BsCvc6D8O2q)eY71eN06uVOe6DnwOfJtLG3mbo9rTL0Y9izXYFvtjem5G(1FAHfRxPO19BeMjKO2s(J3yXY8s4Gsurids3hAuhinVexPXhdpe6njUkb9oEuBWanSHF94rTLy4MwCnwOzuwl8hijSc0bsZlXvA8XWdHEtIRsqVJh1gmqd7JHhc9MqU6D2ZPKy)gjA07CnwOzuwlmebNh1wcP5HhfHFY8YaP5L4kn(y4HqVjXvjO3XJAdgOH9g38HXtwZHvEY1yHwdL48Ky)gjA8g38HXtwZHvEQp0O6(vQWNGE9Oh3Ov4dbwiaeoqAEjUsJpgEi0BsCvc6D8O2GbAyV(tljT8beKREN9Ckj2VrIg9oxJf6xPcFc61JECJwHpey50r4aP5L4kn(y4HqVjXvjO3XJAdgOH9XWdHEtix9o75usSFJen6DUgl0Vsr9HMDdKMxIR04JHhc9MexLGEhpQnyGg2R)0I27SaNCnwOnVeoOeveYG09HgbDJY(nYe4jRAPg5nNXs4HiQn3(Zbvwj4k2GlPLrSyTV)CqLvcUIn4sAzeIdKdK93aCQMpm(aCkmbpKG0dKMxIR0438HX1Oz431slL3zxJfAgL1cdn4C7t3kT(tlyfOdKMxIR0438HX1WanSzOxtperT5ASqZOSwyObNBF6wP1FAbRaDG08sCLg)MpmUggOHT9EROeufUMCnwOrzFgL1cdn4C7t3kT(tlyfOUnVeoOeveYG09HgvezXAFgL1cdn4C7t3kT(tlyfOUr5vkc3Ov4dPp0S19RuHpb96rpUrRWhsFOraieXbsZlXvA8B(W4AyGg28ydUOtSXuPTHKkX1yHMrzTWqdo3(0TsR)0cwb6aP5L4kn(nFyCnmqdBR8KwEJN8gN7ASqZOSwyObNBF6wP1FAbRa1nJYAHjKqVE0NELIs9id6vyfOdKMxIR0438HX1WanSxXtm87AUgl0mkRfgAW52NUvA9NwWpH0Isdl0iqUzuwlmHe61J(0RuuQhzqVcRaDG08sCLg)MpmUggOHnJTLUvs(WdH21yHMrzTWqdo3(0TsR)0cwbQBZlHdkrfHmin6DUrHrzTWqdo3(0TsR)0c(jKwuAyXw3IXPsW(J3sWj7fmvgdNASyTVyCQeS)4TeCYEbtLXWPMBgL1cdn4C7t3kT(tl4NqArPHf7qCGCGS)gGQyvZ(2a0rTXj24I9BKmG)etIRginVexPXAXQM9n0pH8EnXjTo1lkHExJfAX4uj4ntGtFuBjTCpswS8x1ucbtoOF9NwyX6vkAD)gHzcjQTK)4TbsZlXvASwSQzFdgOH9g38HXtwZHvEY1yHE)gzc8eevSbxWVsrR73i8B979HNCJsJyuwl8B979HNWAX8qal2YIvJyuwl8B979HNWpH0IsdlNoIdKMxIR0yTyvZ(gmqd71FAjPLpGGCnwO93XBxVc)eY71eN06uVOe6XpH0Isdl0OYg28n3IXPsWBMaN(O2sA5EKdKMxIR0yTyvZ(gmqd71FAjPLpGGCnwO9x1ucbtV1cVjrTLy4xp3mkRfMERfEtIAlXWVEyTyEiqJklw(RAkHGvkozA4ulTEQ6xNDZOSwyLItMgo1sRNQ(1z8tiTO0WIDdKMxIR0yTyvZ(gmqdB4xpEuBjgUPfxJfAgL1c)bscRaDG08sCLgRfRA23GbAyFm8qO3eY1yHEFgL1cV(RFPkbvHRjScu3IXPsWR)6xQsqv4AIflgL1cdrW5rTLqAE4rr4NmVWIvJmbEYQwQrEZzSeEiIAZT)CqLvcUIn4sAzKBgL1c3itGRtnfcRfZdbSqqwSELIWsGKsYLqqyHEZ3ginVexPXAXQM9nyGg2R)0sslFab5ASq)kv4tqVE0JB0k8Halu2XwyigNkb)kv4tMiuPysCfBGDioqAEjUsJ1Ivn7BWanSpgEi0Bc5ASq)kv4tqVE0JB0k8H0hkOYwyigNkb)kv4tMiuPysCfBGDioqAEjUsJ1Ivn7BWanSx)PLKw(acAG08sCLgRfRA23GbAyd)(kDRuVOe6hinVexPXAXQM9nyGg227TIsY9pvYa5az)nGo)OGGe9aP5L4knw(OGGen6O0(xrmgoL6NkwjkitnYr4jxJfAgL1cdn4C7t3kT(tlyfOSyj2VrcwcKusUeuVKqfHWITSyXCAT7vSbxspH0Isdlu3nq2FdOt40aKpkiiza9cb(ae40aGhBWjTmaslbstO2aCyCfY1b0l48bWqdqrtTbSIxldWQ2aGAXtTb0le4dO)hCU9d4wdGn5pTGhinVexPXYhfeKOHbAylFuqqYoxJf69DyFymCcRHs(yfuljFuqqIBgL1cdn4C7t3kT(tlyfOUrzFX4uj4WtEdklwIXPsWHN8gu3mkRfgAW52NUvA9NwWpH0Is3h6Dier3OSV8rbbjyuXWnDYFhVD9kwSKpkiibJk2FhVD9k8tiTO0Sy5W(Wy4ew(OGGKe0pUpeNrVdrwSKpkiibVdZOSwPMYBsCvFOxXgCj9eslk9aP5L4knw(OGGenmqdB5Jccsq11yHEFh2hgdNWAOKpwb1sYhfeK4MrzTWqdo3(0TsR)0cwbQBu2xmovco8K3GYILyCQeC4jVb1nJYAHHgCU9PBLw)Pf8tiTO09HEhcr0nk7lFuqqcEhgUPt(74TRxXIL8rbbj4Dy)D821RWpH0IsZILd7dJHty5Jccssq)4(qCgnQiYIL8rbbjyuXmkRvQP8Mex1h6vSbxspH0Ispq2FdGnVgWvCNhWv0aUAakAAaYhfeKmaO)5iAKEa2ayuwlxhGIMgGaNgWjWPFaxna)D821RWdab(hqSgqrHaN(biFuqqYaG(NJOr6bydGrzTCDakAAamNaFaxna)D821RWdKMxIR0y5Jccs0WanSLpkiizNRXc9(YhfeKG3HHB6KIMsmkRLBuKpkiibJk2FhVD9k8tiTO0SyTV8rbbjyuXWnDsrtjgL1crwS83XBxVcdn4C7t3kT(tl4NqArP7dveoqAEjUsJLpkiirdd0Ww(OGGeuDnwO3x(OGGemQy4MoPOPeJYA5gf5JccsW7W(74TRxHFcPfLMfR9LpkiibVdd30jfnLyuwlezXYFhVD9km0GZTpDR06pTGFcPfLUpurywvdL85oqLT7YswYza]] )


end
