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
                return state.buff.empower_rune_weapon.applied + floor( ( state.query_time - state.buff.empower_rune_weapon.applied ) / 5 ) * 5
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
                return state.buff.empower_rune_weapon.applied + floor( ( state.query_time - state.buff.empower_rune_weapon.applied ) / 5 ) * 5
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

    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364383, "tier28_4pc", 363411 )
    -- 2-Set - Arctic Assault - Remorseless Winter grants 8% Critical Strike while active.
    -- 4-Set - Arctic Assault - Consuming Killing Machine fires a Glacial Advance through your target.

    spec:RegisterAura( "arctic_assault", {
        id = 364384,
        duration = 8,
        max_stack = 1,
    } )


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

                removeBuff( "killing_machine" )
                -- Tier 28:  Decide if modeling the Glacial Advance on multiple targets is worthwhile.
                if set_bonus.tier28_4pc > 0 then applyDebuff( "target", "razorice", nil, debuff.razorice.stack + 1 ) end

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
                if set_bonus.tier28_2pc > 0 then applyBuff( "arctic_assault" ) end

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


    spec:RegisterPack( "Frost DK", 20220514, [[daLmzdqiPs9iOqCjIsLnru9jvQgfe1PGiRIkP8kqWSOsClIsP2fQ(fOsdJOOJPszzqrptQOMMuv5Aef2MuvLVruQACqH05KQQY6OsL5bcDpI0(Kk5FsvvvhKkvLfcQ4HujzIujvXfHcv2iuO0hPsQQrkvvvCsQKkReu1lPsQsMPurUPuvvP2PuHFcfkgkuOQLsLQQNsftvQkxvQQQKVsukzSqb7vu)LQgmWHPSyi9yrMSkUmYMLYNbLrdsNwy1ujvPEniA2OCBiSBj)wvdxLCCIsXYv65eMoPRdvBhk9DPkJNOKZtLY6PsvMprSFfNVL7l7CmLYDGPmXetzkJB9JFt235(15(x2rD7IYoxwcsdgLDkdbLDWy3xOdW1JRxzNlZn2BNCFzhXJVjk7av1lH7GlCHfkuCuE6raxrGaNzA8vATMcxrGib3SdkEWuxxLrZohtPChyktmXuMY4w)43K9D(w)YogUc93SJtGWvzhOX5qvgn7Cirk746Hmf6aC9Qcyq1bGXUVqh47)2CBa36NldatzIjMd8d8UcQvWiXaVS9aC)eIhlDgaZeQSTGsFDgaUWGrd4BdWvqTOed4BdW1LObyIbe6aopjQ76aUyMBdOhXydiQbCTwsJeXh4LThGRNVURdib1QIydaJLrcOP1A6ao4BuWgaCwYuOd4BdWjQZAWEHXZoSqOICFzNhLfkTMgF5V(NffSCF5oUL7l7qLHYOtgozNdjsBCPXxzhm()zrbBayS)oamguwO0AA8L7gGJARkgWnzoabL(6igak1(LgagFWy2oGVnam29f6aspcsmGV1gGRC9KDsBO0gw2bRTHHYi(2ZJI3AIbirYaSKgyjpveIGedOlPdaZSJL04RSZsi(vqmsi89IsPnR5oWm3x2HkdLrNmCYoPnuAdl7iUigZR2cJubhgZsHX82bRvjAaDjDayoa5dqngvkVTVqfj3uOeNkdLrNSJL04RSdmMLcJ5TdwRsuwZD05CFzhQmugDYWj7K2qPnSSdkERXHmySOG5ryjOrr8LSKoa5dWsAGL8uricsmGUgaMdq(a6EayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUPqPSM7OF5(YouzOm6KHt2XsA8v25rzHsRPu2jTHsByzhu8wJdzWyrbZJWsqJI4lzjn7KClXiVAlmsf5oUL1ChYi3x2HkdLrNmCYoPnuAdl7yjnWsEQiebjgG0bCBaYhawBddLr82(c1l0nGK8PVo4HkYowsJVYoT9fQxOBajL1Ch9xUVSdvgkJoz4KDSKgFLDEuwO0AkLDsBO0gw2bfV14qgmwuW8iSe0Oi(swsZoj3smYR2cJurUJBzn3HSp3x2HkdLrNmCYoPnuAdl7G12WqzeFFTL8BGGYowsJVYoq)ESOG5rzMqZAUdmAUVSdvgkJoz4KDsBO0gw2rCrmMxTfgPcomMLcJ5TdwRs0a6s6aWCaYhWIxrYF99OLFOwKcDaqCa9NmZowsJVYoWywkmM3oyTkrzn3r)l3x2HkdLrNmCYowsJVYoT9fQxOBajLDsBO0gw2zXRi5V(E0YpulsHoaioazVmZoj3smYR2cJurUJBzn3XnzM7l7qLHYOtgozhlPXxzNhLfkTMszN0gkTHLDw8IgqxshqNhG8bG8a6EaiSO8qT6WXe6aKizaPhlvwP8Is7Z(9majsgq6XsLvkhs32WQbG0aKizalErdOlPdOFdq(aqyr5HA1HJj0StYTeJ8QTWivK74wwZDC7wUVSdvgkJoz4KDsBO0gw2XsAGL8uricsmGUKoG(na5dO7bG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5McLYAwZoPND8qjB1CF5oUL7l7qLHYOtgozN0gkTHLDqFHyaYhqlGbv9lHWIsmaioayPZaKpaKhWIx0aG4aWCasKmGUhakERXHmySOG5ryjOrrC8RbiFaipGUhaclkpuRoCmHoa5dafV14PND8qjBvUqTeKdOlPdOFdacdyXlQ9lmId5Z0ynHVzy)LtLHYOZaKizaiSO8qT6WXe6aKpau8wJNE2XdLSv5c1sqoGUgagDaqyalErTFHrCiFMgRj8nd7VCQmugDgasdqIKbGI3ACidglkyEewcAueh)AaYhaYdO7bGWIYd1QdhtOdq(aqXBnE6zhpuYwLlulb5a6Aay0baHbS4f1(fgXH8zASMW3mS)YPYqz0zasKmaewuEOwD4ycDaYhakERXtp74Hs2QCHAjihqxd4MmhaegWIxu7xyehYNPXAcFZW(lNkdLrNbG0aqk7yjn(k7KGArj8FZhjkR5oWm3x2HkdLrNmCYohsK24sJVYo9FjObCW3OGnam(GXSDa9cf6aCDjkzxWfolzk0StAdL2WYoDpa1yuP8hLfkTMgFXPYqz0zaYhakERXVcgZw)38T9fkh)AaYhakERXtp74Hs2QCHAjihqxshWnzoa5da5bGI3A8RGXS1)nFBFHYxcHfLyaqCaWsNb4Ada5bCBaqyaP)zNVxXB7l0EUTie(g(6gFj742aqAasKmau8wJJxqFMBEHUubtHYxcHfLyaqCaWsNbirYaqXBnEcQ9cpQveFjewuIbaXbalDgaszhlPXxzNeulkH)B(irzn3rNZ9LDOYqz0jdNSZHePnU04RSdgdUkIdnGVnam(GXSDa4cYGrdOxOqhGRlrj7cUWzjtHMDsBO0gw2P7bOgJkL)OSqP104lovgkJodq(aoKPq9qwbmOkFXlQ9lmI3mgJkFAXf2H2biFaDpau8wJFfmMT(V5B7luo(1aKpG0)SZ3R4xbJzR)B(2(cLVeclkXa6Aa3KXaKpaKhakERXtp74Hs2QCHAjihqxshWnzoa5da5bGI3AC8c6ZCZl0Lkykuo(1aKizaO4Tgpb1EHh1kIJFnaKgGejdafV14PND8qjBvUqTeKdOlPd4wNhaszhlPXxzNeulkH)B(irzn3r)Y9LDOYqz0jdNStAdL2WYoDpa1yuP8hLfkTMgFXPYqz0zaYhq3d4qMc1dzfWGQ8fVO2VWiEZymQ8PfxyhAhG8bGI3A80ZoEOKTkxOwcYb0L0bCtMdq(a6EaO4Tg)kymB9FZ32xOC8RbiFaP)zNVxXVcgZw)38T9fkFjewuIb01aWuMzhlPXxzNeulkH)B(irzn3HmY9LDOYqz0jdNSZHePnU04RSdg)syPshGRE2za9FiB1b8yPnzxxrbBah8nkyd4kymBZoPnuAdl7OgJkL)OSqP104lovgkJodq(a6EaO4Tg)kymB9FZ32xOC8RbiFaipau8wJNE2XdLSv5c1sqoGUKoGB9BaYhaYdafV144f0N5MxOlvWuOC8RbirYaqXBnEcQ9cpQveh)AainajsgakERXtp74Hs2QCHAjihqxshWT(3aKizaP)zNVxXVcgZw)38T9fkFjewuIbaXb05biFaO4Tgp9SJhkzRYfQLGCaDjDa363aqk7yjn(k7KGArj8FZhjkRzn78OSqP104RCF5oUL7l7qLHYOtgozNdjsBCPXxzhmguwO0AA81a2xnn(k7K2qPnSSJL0al5PIqeKyaDjDaDEaYhawBddLr8TNhfV1ezhlPXxzNLq8RGyKq47fLsBwZDGzUVSdvgkJoz4KDsBO0gw2P7bGI3ACidglkyEewcAueh)AaYhaYdyXlAaqCayoajsgGAmQuEKCZRg7lbNkdLrNbiFaO4TgpsU5vJ9LGVeclkXaG4aGLodW1gaMdqIKbK(6GhkhVyKjGshFBPY9CJtLHYOZaKpaKhakERXXlgzcO0X3wQCp34lHWIsmaioayPZaCTbG5aKizaO4TghVyKjGshFBPY9CJlulb5aG4a68aqAaiLDSKgFLDA7luVq3askR5o6CUVSdvgkJoz4KDsBO0gw2P7bGI3ACidglkyEewcAueh)AaYhWIx0a6s6a68aKpaKhakERX3abXxcHfLyaqCaDEaYhakERX3abXXVgGejdWsAGL8Nx5T9fQVryPDaqCawsdSKNkcrqIbGu2XsA8v2b63JffmpkZeAwZD0VCFzhQmugDYWj7K2qPnSSt3dafV14qgmwuW8iSe0Oio(1aKpaXfXyE1wyKk4WywkmM3oyTkrdOlPdaZbirYa6EaO4TghYGXIcMhHLGgfXXVgG8bG8aoekERXxZ9(nsexOwcYbaXbiJbirYaoekERXxZ9(nseFjewuIbaXbalDgGRnG(naKYowsJVYoWywkmM3oyTkrzn3HmY9LDOYqz0jdNStAdL2WYoO4TghYGXIcMhHLGgfXxYs6aKpaXfXyE1wyKk4T9fQi5McLgqxdaZbiFaDpaS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfj3uOuwZD0F5(YouzOm6KHt2XsA8v25rzHsRPu2jTHsByzhu8wJdzWyrbZJWsqJI4lzjn7KClXiVAlmsf5oUL1ChY(CFzhQmugDYWj7K2qPnSSJL0al5PIqeKyashWTbiFayTnmugXB7luVq3asYN(6GhQi7yjn(k702xOEHUbKuwZDGrZ9LDOYqz0jdNStAdL2WYoyTnmugX3xBj)giObiFaIlIX8QTWivWH(9yrbZJYmHoGUKoamZowsJVYoq)ESOG5rzMqZAUJ(xUVSdvgkJoz4KDsBO0gw2rCrmMxTfgPcomMLcJ5TdwRs0a6s6aWm7yjn(k7aJzPWyE7G1QeL1Ch3KzUVSdvgkJoz4KDSKgFLDA7luVq3ask7K2qPnSSt3dqngvk3WAmRsqjovgkJodq(a6EaO4TghYGXIcMhHLGgfXXVgGejdqngvk3WAmRsqjovgkJodq(a6EayTnmugX3xBj)giObirYaWAByOmIVV2s(nqqdq(aw8I4AGG867XCaDjDaWsNStYTeJ8QTWivK74wwZDC7wUVSdvgkJoz4KDsBO0gw2bRTHHYi((Al53abLDSKgFLDG(9yrbZJYmHM1Ch3Wm3x2HkdLrNmCYowsJVYopkluAnLYoj3smYR2cJurUJBznRzh0x41ibzuWY9L74wUVSdvgkJoz4KDSKgFLDEuwO0AkLDsULyKxTfgPICh3YoPnuAdl7S4vK8xFpAhaeLoaKhq)KXaGWauJrLYx8ksEtvQWnn(ItLHYOZaCTbiJbGu25qI0gxA8v2bolzk0b8Tb4e1znyVWgG7lPbwAaU)xnn(kR5oWm3x2HkdLrNmCYoPnuAdl7G12WqzeF75rXBnXaKizawsdSKNkcrqIb0L0bG5aKizalEfj)13J2baXb0zmhG8bS4fX1ab513J5aG4aw8ks(RVhTdaUd4w)LDSKgFLDwcXVcIrcHVxukTzn3rNZ9LDOYqz0jdNStAdL2WYolEfj)13J2baXb0zmhG8bS4fX1ab513J5aG4aw8ks(RVhTdaUd4w)LDSKgFLDoKPq9wD8hkzUL1Ch9l3x2HkdLrNmCYoPnuAdl7G12WqzeFFTL8BGGgG8bG8aw8ks(RVhTdOlPdOFYyasKmGfViUgiiV((opaikDaWsNbirYaw8IA)cJ4RbJ8FZRqjFBF3JkFcQH4k(ItLHYOZaKizaIlIX8QTWivWH(9yrbZJYmHoGUKoamhGejdafV14BGG4lHWIsmaioGopaKgGejdyXRi5V(E0oaioGoJ5aKpGfViUgiiV(EmhaehWIxrYF99ODaWDa36VSJL04RSd0VhlkyEuMj0SM7qg5(YouzOm6KHt2jTHsByzhu8wJdzWyrbZJWsqJI44xdq(aexeJ5vBHrQG32xOIKBkuAaDnamhG8b09aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCtHszn3r)L7l7qLHYOtgozhlPXxzNhLfkTMszN0gkTHLDqXBnoKbJffmpclbnkIVKL0StYTeJ8QTWivK74wwZDi7Z9LDOYqz0jdNStAdL2WYolEfj)13J2barPdO)K5aKpGfViUgiiV((opGUgaS0j7yjn(k7a93Y)nFVOuAZAUdmAUVSdvgkJoz4KDsBO0gw2rCrmMxTfgPcEBFHksUPqPb01aWCaYhq3daRTHHYi(HmfQWFWjVL0alLDSKgFLDA7lurYnfkL1Ch9VCFzhQmugDYWj7yjn(k78OSqP1uk7K2qPnSSZIxrYF99OLFOwKcDaDnamLXaKizalErCnqqE99DEaqCaWsNStYTeJ8QTWivK74wwZDCtM5(YouzOm6KHt2jTHsByzhS2ggkJ47RTKFdeu2XsA8v2b63JffmpkZeAwZDC7wUVSdvgkJoz4KDsBO0gw2zXRi5V(E0oaioaziZSJL04RSJTjRiV(7sLM1SMDeQvhBp5(YDCl3x2HkdLrNmCYohsK24sJVYooQvhBpdqefmgjBR2cJ0bSVAA8v2jTHsByzhS2ggkJ4BppkERjYowsJVYolH4xbXiHW3lkL2SM7aZCFzhQmugDYWj7K2qPnSSdkERXHmySOG5ryjOrr8LSKMDSKgFLDEuwO0AkL1ChDo3x2HkdLrNmCYoPnuAdl7G12WqzeFFTL8BGGgG8bGI3A8nqq8LqyrjgaehqNZowsJVYoq)ESOG5rzMqZAUJ(L7l7qLHYOtgozN0gkTHLDWAByOmI32xOEHUbKKp91bpur2XsA8v2PTVq9cDdiPSM7qg5(YouzOm6KHt2jTHsByzNUhWHmfQhYkGbv5lErTFHr81CVFJena5da5bCiu8wJVM79BKiUqTeKdaIdqgdqIKbCiu8wJVM79BKi(siSOedaIdaw6maxBa9BaiLDSKgFLDGXSuymVDWAvIYAUJ(l3x2HkdLrNmCYoPnuAdl7K(ND(EfFje)kigje(ErP0YxcHfLyaqu6aWCaU2aGLodq(auJrLYHzkuAJcMxO)IGtLHYOt2XsA8v2PTVq9cDdiPSM7q2N7l7qLHYOtgozN0gkTHLDWAByOmIVV2s(nqqzhlPXxzhOFpwuW8OmtOzn3bgn3x2HkdLrNmCYoPnuAdl7S4vK8xFpA5hQfPqhaehaYd4MmgaegGAmQu(IxrYBQsfUPXxCQmugDgGRnazmaKYowsJVYoT9fQxOBajL1Ch9VCFzhQmugDYWj7K2qPnSSt3dafV14T9DpQ8x4mbXXVgG8bOgJkL3239OYFHZeeNkdLrNbirYaWAByOmIFitHk8hCYBjnWsdq(aqXBn(HmfQWFWjUqTeKdaIdOFdqIKbS4fnGUKoG(na5dqqQh9lCbxdAXeJ673vAasKmaKhaclkpuRoCmHoajsgq3di9yPYkLxbmOQVz0aKizaDpabPE0VWfCnOftmQVFxPbG0aKpa1yuPCyMcL2OG5f6Vi4uzOm6ma5dafV14lH4xbXiHW3lkLwo(1aKizaDpabPE0VWfCnOftmQVFxPbiFalEfj)13Jw(HArk0b01aqEaykJbaHbOgJkLV4vK8MQuHBA8fNkdLrNb4AdqgdaPSJL04RSZJYcLwtPSM74MmZ9LDSKgFLDA7luVq3ask7qLHYOtgozn3XTB5(YowsJVYoq)T8FZ3lkL2SdvgkJoz4K1Ch3Wm3x2XsA8v2X2KvKx)DPsZouzOm6KHtwZA2j9yPYkvK7l3XTCFzhQmugDYWj7CirAJln(k74QhlvwPdW9HgSqdsKDsBO0gw2b5b09auJrLYFuwO0AA8fNkdLrNbirYauJrLYFuwO0AA8fNkdLrNbiFawsdSKNkcrqIb0L0bG5aKpG0)SZ3R4xbJzR)B(2(cLVeclkXaKizawsdSKNkcrqIbiDa3gasdq(aqEayTnmugXfQ)IzvffSbirYaWAByOmIBNJWVeclQbGu2XsA8v25qMcv4p4uwZDGzUVSdvgkJoz4KDsBO0gw2zXRi5V(E0YpulsHoGUgWTopa5di9p789k(vWy26)MVTVq5lHWIsmaioGopa5dO7bOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG12WqzexO(lMvvuWYowsJVYoIE2IikyEeHqZAUJoN7l7qLHYOtgozN0gkTHLD6EaQXOs5Olzku)38IOoRb7fgNkdLrNbiFayTnmugXTZr4xcHfv2XsA8v2r0ZwerbZJieAwZD0VCFzhQmugDYWj7K2qPnSSJAmQuo6sMc1)nViQZAWEHXPYqz0zaYhaYdafV14Olzku)38IOoRb7fgh)AaYhaYdaRTHHYiUq9xmRQOGna5dyXRi5V(E0YpulsHoGUgq)K5aKizayTnmugXTZr4xcHf1aKpGfVIK)67rl)qTif6a6Aa9NmhGejdaRTHHYiUDoc)siSOgG8bSwC8ewQuUDoc(siSOedaIdO)na5dyT44jSuPC7CeCswHqfdaPbirYa6EaO4TghDjtH6)Mxe1znyVW44xdq(as)ZoFVIJUKPq9FZlI6SgSxy8LqyrjgaszhlPXxzhrpBrefmpIqOzn3HmY9LDOYqz0jdNStAdL2WYoP)zNVxXVcgZw)38T9fkFjewuIbaXbalDgGRnamhG8bG12WqzexO(lMvvuWgG8bG8auJrLYrxYuO(V5frDwd2lmovgkJodq(aw8ks(RVhTdORb0FYyaYhq6F257vC0LmfQ)BEruN1G9cJVeclkXaG4aWCasKmGUhGAmQuo6sMc1)nViQZAWEHXPYqz0zaiLDSKgFLDm0hruMgF5zbc0SM7O)Y9LDOYqz0jdNStAdL2WYoyTnmugXTZr4xcHfv2XsA8v2XqFerzA8LNfiqZAUdzFUVSdvgkJoz4KDsBO0gw2bRTHHYiUq9xmRQOGna5da5bK(ND(Ef)kymB9FZ32xO8LqyrjgaehqNhGejdqngvkpsuYU4uzOm6maKYowsJVYocOwcsg5vOKhV69Rc1TSM7aJM7l7qLHYOtgozN0gkTHLDWAByOmIBNJWVeclQSJL04RSJaQLGKrEfk5XRE)QqDlR5o6F5(YouzOm6KHt2jTHsByzNUhakERXVcgZw)38T9fkh)AaYhaYdq84m0Oo8lCHIZipT4xA8fNkdLrNbirYaepodnQdh7ZmnyKx8mSuPCQmugDgG8b09aqXBno2NzAWiV4zyPs54xdaPStukTl(L6Jw2r84m0OoCSpZ0GrEXZWsLMDIsPDXVuFGabDctPSZTSJL04RStJrcOP1AA2jkL2f)s9WypQXYo3YAwZoP)zNVxjY9L74wUVSdvgkJoz4KDoKiTXLgFLDW4Fn(k7yjn(k7C9A8v2jTHsByzhu8wJFfmMT(V5B7luo(vwZDGzUVSdvgkJoz4KDoKiTXLgFLDC1)SZ3RezN0gkTHLDuJrLYFuwO0AA8fNkdLrNbiFalErdaIdO)gG8bG8aWAByOmIlu)fZQkkydqIKbG12Wqze3ohHFjewudaPbiFaipG0)SZ3R4xbJzR)B(2(cLVeclkXaG4aKXaKpaKhq6F257v8gJeqtR1u(siSOedORbiJbiFaIhNHg1HFHluCg5Pf)sJV4uzOm6majsgq3dq84m0Oo8lCHIZipT4xA8fNkdLrNbG0aKizaO4Tg)kymB9FZ32xOC8RbG0aKizaOVqma5dOfWGQ(LqyrjgaehaMYm7yjn(k7qiU(E06x8I89i76RSM7OZ5(YouzOm6KHt2jTHsByzh1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpGfVObaXbiJbiFalEfj)13J2baXbG8a6pzoaz7bCitH6HScyqv(Ixu7xyehQBcL2WgGRnazmaz7bS4f1(fgXxdXLvQxxRenAPkrCQmugDgGRnazmaKgG8bG8aqXBno6sMc1)nViQZAWEHXXVgGejdOfWGQ(LqyrjgaehaMYCaiLDSKgFLDiexFpA9lEr(EKD9vwZD0VCFzhQmugDYWj7K2qPnSSJAmQuEKOKDXPYqz0j7yjn(k7qiU(E06x8I89i76RSM7qg5(YouzOm6KHt2jTHsByzh1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaKhawBddLrCH6VywvrbBasKmaS2ggkJ425i8lHWIAaina5da5bK(ND(EfhDjtH6)Mxe1znyVW4lHWIsmajsgq6F257vC0LmfQ)BEruN1G9cJVKDCBaYhWIxrYF99ODaDnG(tgdaPSJL04RSZvWy26)MVTVqZAUJ(l3x2HkdLrNmCYoPnuAdl7OgJkLhjkzxCQmugDgG8b09aqXBn(vWy26)MVTVq54xzhlPXxzNRGXS1)nFBFHM1ChY(CFzhQmugDYWj7K2qPnSSJAmQu(JYcLwtJV4uzOm6ma5da5bS4vK8xFpAhqxshqNLXaKpGUhakERXn0hruMgF5zbcuo(1aKizaO4Tg3qFerzA8LNfiq54xdqIKbS4f1(fgXxdg5)MxHs(2(Uhv(eudXv8fNkdLrNbG0aKpaKhawBddLrCH6VywvrbBasKmaS2ggkJ425i8lHWIAaina5da5bOgJkLdZuO0gfmVq)fbNkdLrNbiFaO4TgFje)kigje(ErP0YXVgGejdO7bOgJkLdZuO0gfmVq)fbNkdLrNbGu2XsA8v25kymB9FZ32xOzn3bgn3x2HkdLrNmCYoPnuAdl7GI3A8RGXS1)nFBFHYXVYowsJVYoOlzku)38IOoRb7fwwZD0)Y9LDOYqz0jdNStAdL2WYowsdSKNkcrqIbiDa3gG8bGI3A8RGXS1)nFBFHYxcHfLyaqCaWsNbiFaO4Tg)kymB9FZ32xOC8RbiFaDpa1yuP8hLfkTMgFXPYqz0zaYhaYdO7bSwC8ewQuUDocojRqOIbirYawloEclvk3ohbpQb01a6SmhasdqIKb0cyqv)siSOedaIdOZzhlPXxzN2(cTNBlcHVHVUL1Ch3KzUVSdvgkJoz4KDsBO0gw2XsAGL8uricsmGUKoamhG8bG8aqXBn(vWy26)MVTVq54xdqIKbSwC8ewQuUDocojRqOIbiFaRfhpHLkLBNJGh1a6AaP)zNVxXVcgZw)38T9fkFjewuIbaHbi7hasdq(aqEaO4Tg)kymB9FZ32xO8LqyrjgaehaS0zasKmG1IJNWsLYTZrWjzfcvma5dyT44jSuPC7Ce8LqyrjgaehaS0zaiLDSKgFLDA7l0EUTie(g(6wwZDC7wUVSdvgkJoz4KDsBO0gw2rngvk)rzHsRPXxCQmugDgG8bG8aqXBn(vWy26)MVTVq54xdq(a6EaiSO8qT6WXe6aKizaDpau8wJFfmMT(V5B7luo(1aKpaewuEOwD4ycDaYhq6F257v8RGXS1)nFBFHYxcHfLyaina5da5bG8aqXBn(vWy26)MVTVq5lHWIsmaioayPZaKizaO4TghVG(m38cDPcMcLJFna5dafV144f0N5MxOlvWuO8LqyrjgaehaS0zaina5da5bCiu8wJVM79BKiUqTeKdq6aKXaKizaDpGdzkupKvadQYx8IA)cJ4R5E)gjAainaKYowsJVYoT9fAp3wecFdFDlR5oUHzUVSdvgkJoz4KDsBO0gw2rngvkhDjtH6)Mxe1znyVW4uzOm6ma5dyXRi5V(E0oaioG(tMdq(aw8IgaeLoGopa5da5bGI3AC0LmfQ)BEruN1G9cJJFnajsgq6F257vC0LmfQ)BEruN1G9cJVeclkXa6Aa9tMdaPbirYa6EaQXOs5Olzku)38IOoRb7fgNkdLrNbiFalEfj)13J2barPdq2lJSJL04RSdu3UEfkTiIK)AjbvjkR5oU15CFzhQmugDYWj7K2qPnSSt6F257v8RGXS1)nFBFHYxcHfLyaqu6aKr2XsA8v2zTqq(dzNSM74w)Y9LDOYqz0jdNStAdL2WYowsdSKNkcrqIb0L0bG5aKpaKhqlGbv9lHWIsmaioGopajsgq3dafV14Olzku)38IOoRb7fgh)AaYhaYd4IuomOpoJVeclkXaG4aGLodqIKbSwC8ewQuUDocojRqOIbiFaRfhpHLkLBNJGVeclkXaG4a68aKpG1IJNWsLYTZrWJAaDnGls5WG(4m(siSOedaPbGu2XsA8v2ryPnArkmM)YsAwZDCtg5(YouzOm6KHt2jTHsByzhlPbwYtfHiiXa6AaYyasKmGfVO2VWi(fuY2hXxKGtLHYOt2XsA8v25qMc1B1XFOK5wwZA2b9f(R)zrbl3xUJB5(YouzOm6KHt25qI0gxA8v2bolzk0b8Tb4e1znyVWgW1)SOGnG9vtJVgG7gGqTvfd4MmfdaLA)sdaoVZacXamSwWmugLDsBO0gw2XsAGL8uricsmGUKoamhGejdaRTHHYi(2ZJI3AISJL04RSZsi(vqmsi89IsPnR5oWm3x2HkdLrNmCYowsJVYopkluAnLYoPnuAdl7GI3ACidglkyEewcAueFjlPdq(as)ZoFVIFfmMT(V5B7lu(siSOedORb05StYTeJ8QTWivK74wwZD05CFzhQmugDYWj7K2qPnSSdwBddLr891wYVbck7yjn(k7a97XIcMhLzcnR5o6xUVSdvgkJoz4KDsBO0gw2bfV14qgmwuW8iSe0Oi(swshG8bS4vK8xFpA5hQfPqhqxda5bCtgdacdqngvkFXRi5nvPc304lovgkJodW1gGmgasdq(aexeJ5vBHrQG32xOIKBkuAaDnamhG8b09aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCtHszn3HmY9LDOYqz0jdNStAdL2WYolEfj)13Jw(HArk0b0L0bG8a6SmgaegGAmQu(IxrYBQsfUPXxCQmugDgGRnazmaKgG8biUigZR2cJubVTVqfj3uO0a6Aayoa5dO7bG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5McLYAUJ(l3x2HkdLrNmCYowsJVYopkluAnLYoPnuAdl7S4vK8xFpA5hQfPqhqxshaMYi7KClXiVAlmsf5oUL1ChY(CFzhQmugDYWj7K2qPnSSZIxrYF99OLFOwKcDaqCaykZbiFaIlIX8QTWivWHXSuymVDWAvIgqxshaMdq(as)ZoFVIFfmMT(V5B7lu(siSOedORbiJSJL04RSdmMLcJ5TdwRsuwZDGrZ9LDOYqz0jdNSJL04RStBFH6f6gqszN0gkTHLDw8ks(RVhT8d1IuOdaIdatzoa5di9p789k(vWy26)MVTVq5lHWIsmGUgGmYoj3smYR2cJurUJBzn3r)l3x2HkdLrNmCYoPnuAdl7K(ND(Ef)kymB9FZ32xO8LqyrjgqxdyXlIRbcYRVVFdq(aw8ks(RVhT8d1IuOdaIdOFYCaYhG4IymVAlmsfCymlfgZBhSwLOb0L0bGz2XsA8v2bgZsHX82bRvjkR5oUjZCFzhQmugDYWj7yjn(k702xOEHUbKu2jTHsByzN0)SZ3R4xbJzR)B(2(cLVeclkXa6AalErCnqqE999BaYhWIxrYF99OLFOwKcDaqCa9tMzNKBjg5vBHrQi3XTSM1SZ1sPhbQP5(YDCl3x2HkdLrNmCYo)v2rqA0YoPnuAdl7OBuqskxVXHAcpUG8O4T2aKpaKhq3dqngvkhDjtH6)Mxe1znyVW4uzOm6ma5da5bOBuqskxVXt)ZoFVIFWxtJVgGSBaP)zNVxXVcgZw)38T9fk)GVMgFnaPdqMdaPbirYauJrLYrxYuO(V5frDwd2lmovgkJodq(aqEaP)zNVxXrxYuO(V5frDwd2lm(bFnn(AaYUbmaKhGUrbjPC9gp9p789k(bFnn(AaD1)pGBdaPbiDaYCainajsgGAmQuEKOKDXPYqz0zaiLDoKiTXLgFLDW4WAmCtjXaSbOBuqsQyaP)zNVx5Yaob24qNbG62aUcgZ2b8Tb02xOd43bGUKPqhW3gGiQZAWEHDxmG0)SZ3R4dW11gqO3fdaRXWPba1edO(bSeclQdTdyjfFRbCZLbqmbnGLu8TgGm5YGNDWAmCk7Cl7yjn(k7G12Wqzu2bRXWjpXeu2rMCzKDWARVmeu2r3OGKu)nVWTkL1ChyM7l7qLHYOtgozN)k7iinAzhlPXxzhS2ggkJYoyT1xgck7OBuqsQhtVWTkLDsBO0gw2r3OGKuUIjhQj84cYJI3Adq(aqEaDpa1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaKhGUrbjPCftE6F257v8d(AA81aKDdi9p789k(vWy26)MVTVq5h8104RbiDaYCainajsgGAmQuo6sMc1)nViQZAWEHXPYqz0zaYhaYdi9p789ko6sMc1)nViQZAWEHXp4RPXxdq2nGbG8a0nkijLRyYt)ZoFVIFWxtJVgqx9)d42aqAashGmhasdqIKbOgJkLhjkzxCQmugDgaszhSgdN8etqzhzYLr2bRXWPSZTSM7OZ5(YouzOm6KHt25VYocsJw2jTHsByzNUhGUrbjPC9ghQj84cYJI3Adq(a0nkijLRyYHAcpUG8O4T2aKiza6gfKKYvm5qnHhxqEu8wBaYhaYda5bOBuqskxXKN(ND(Ef)GVMgFna4oaKhGUrbjPCftokER5p4RPXxdOR()bitUmVnaKgasdW1gaYd4gxgdacdq3OGKuUIjhQj8O4TgxOlvWuOdaPb4Ada5bG12Wqzex3OGKupMEHBvAainaKgqxda5bG8a0nkijLR34P)zNVxXp4RPXxdaUda5bOBuqskxVXrXBn)bFnn(AaD1)pazYL5TbG0aqAaU2aqEa34Yyaqya6gfKKY1BCOMWJI3ACHUubtHoaKgGRnaKhawBddLrCDJcss938c3Q0aqAaiLDoKiTXLgFLDW4eAGWusmaBa6gfKKkgawJHtda1TbKEex2gfSbOqPbK(ND(E1a(2auO0a0nkij1LbCcSXHoda1TbOqPbCWxtJVgW3gGcLgakERnGqhW1(yJdj4dO)JjgGnaHUubtHoae)jAbTdq)balWsdWga0aguAhW1g)gQBdq)bi0Lkyk0bOBuqsQWLbyIb0JySbyIbydaXFIwq7aA)oGOnaBa6gfKKoGEbJnGFhqVGXgq96aeUvPb0luOdi9p789kbp7G1y4u2bZSJL04RSdwBddLrzhSgdN8etqzNBzhS26ldbLD0nkij1FTXVH6wwZD0VCFzhQmugDYWj78xzhbPzhlPXxzhS2ggkJYoyngoLDuJrLYHzkuAJcMxO)IGtLHYOZaKizaPVo4HYjS022xOCQmugDgGejdyXlQ9lmIJgAuW8PND4uzOm6KDWARVmeu2z75rXBnrwZDiJCFzhlPXxzNgJeqtR10SdvgkJoz4K1SMDwlfgtK7l3XTCFzhQmugDYWj7CirAJln(k74(TuySb4(qdwObjYoPnuAdl7GI3A8RGXS1)nFBFHYXVYowsJVYoOS)p(g(6wwZDGzUVSdvgkJoz4KDsBO0gw2bfV14xbJzR)B(2(cLJFLDSKgFLDqPvqlKrblR5o6CUVSdvgkJoz4KDsBO0gw2b5b09aqXBn(vWy26)MVTVq54xdq(aSKgyjpveIGedOlPdaZbG0aKizaDpau8wJFfmMT(V5B7luo(1aKpaKhWIxe)qTif6a6s6aKXaKpGfVIK)67rl)qTif6a6s6a6pzoaKYowsJVYo2MSI8x4mbL1Ch9l3x2HkdLrNmCYoPnuAdl7GI3A8RGXS1)nFBFHYXVYowsJVYoSaguv4D9g)adbvAwZDiJCFzhQmugDYWj7K2qPnSSdkERXVcgZw)38T9fkh)AaYhakERXjexFpA9lEr(EKD9fh)k7yjn(k7yvIe6AmFYySSM7O)Y9LDOYqz0jdNStAdL2WYoO4Tg)kymB9FZ32xO8LqyrjgaeLoam6aKpau8wJFfmMT(V5B7luo(1aKpau8wJtiU(E06x8I89i76lo(v2XsA8v2PflHY()K1ChY(CFzhQmugDYWj7K2qPnSSdkERXVcgZw)38T9fkh)AaYhGL0al5PIqeKyashWTbiFaipau8wJFfmMT(V5B7lu(siSOedaIdqgdq(auJrLYtp74Hs2QCQmugDgGejdO7bOgJkLNE2XdLSv5uzOm6ma5dafV14xbJzR)B(2(cLVeclkXaG4a68aqk7yjn(k7GAW8FZRBKGuK1SMD0nkijvK7l3XTCFzhQmugDYWj7CirAJln(k703gfKKkYoLHGYorjslUAOmYlBWTsXr4pe2irzN0gkTHLD6EaQXOs5Olzku)38IOoRb7fgNkdLrNbiFaO4Tg)kymB9FZ32xOC8RbiFaO4TgNqC99O1V4f57r21xC8RbirYauJrLYrxYuO(V5frDwd2lmovgkJodq(aqEaipau8wJFfmMT(V5B7luo(1aKpG0)SZ3R4Olzku)38IOoRb7fgFj742aqAasKmaKhakERXVcgZw)38T9fkh)AaYhaYda5b0cyqv)siSOedq2EaP)zNVxXrxYuO(V5frDwd2lm(siSOedaPbaXbG5TbG0aqAainajsga6ledq(aAbmOQFjewuIbaXbG5TbirYaoKPq9qwbmOk)ecdLr(q2C8KSOeUsdq6aK5aKpa1wyKY1ab513FLupMYCaqCaYi7yjn(k7eLiT4QHYiVSb3kfhH)qyJeL1ChyM7l7qLHYOtgozNYqqzhygwI5)MxHs(wSc1BlAO0MDSKgFLDGzyjM)BEfk5BXkuVTOHsBwZD05CFzhQmugDYWj7ugck7is2k8FZ3wtPTmMxOB0OSJL04RSJizRW)nFBnL2YyEHUrJYAUJ(L7l7qLHYOtgozN0gkTHLDqXBn(vWy26)MVTVq54xdq(aqXBnoH467rRFXlY3JSRV44xzNYqqzhfk5BXkuViGfSSJL04RSJcL8TyfQxeWcwwZDiJCFzhQmugDYWj7CirAJln(k70huAa6gfKKoGEHcDakuAaqdyqjHoasObctPZaWAmCYLb0lySbGsdaxqNb0IvOdWQZaUSyPZa6fk0bGXhmMTd4BdaJDFHYZoPnuAdl709aWAByOmIlUOu0c641nkijDaYhakERXVcgZw)38T9fkh)AaYhaYdO7bOgJkLhjkzxCQmugDgGejdqngvkpsuYU4uzOm6ma5dafV14xbJzR)B(2(cLVeclkXa6s6aUjZbG0aKpaKhq3dq3OGKuUIjhQj8P)zNVxnajsgGUrbjPCftE6F257v8LqyrjgGejdaRTHHYiUUrbjP(Rn(nu3gG0bCBainajsgGUrbjPC9ghfV18h8104Rb0L0b0cyqv)siSOezhlPXxzhDJcssVL1Ch9xUVSdvgkJoz4KDsBO0gw2P7bG12WqzexCrPOf0XRBuqs6aKpau8wJFfmMT(V5B7luo(1aKpaKhq3dqngvkpsuYU4uzOm6majsgGAmQuEKOKDXPYqz0zaYhakERXVcgZw)38T9fkFjewuIb0L0bCtMdaPbiFaipGUhGUrbjPC9ghQj8P)zNVxnajsgGUrbjPC9gp9p789k(siSOedqIKbG12Wqzex3OGKu)1g)gQBdq6aWCainajsgGUrbjPCftokER5p4RPXxdOlPdOfWGQ(LqyrjYowsJVYo6gfKKIzwZDi7Z9LDOYqz0jdNSJL04RSJUrbjP3Yoc2RzhDJcssVLDsBO0gw2P7bG12WqzexCrPOf0XRBuqs6aKpaKhq3dq3OGKuUEJd1eECb5rXBTbiFaipaDJcss5kM80)SZ3R4lHWIsmajsgq3dq3OGKuUIjhQj84cYJI3AdaPbirYas)ZoFVIFfmMT(V5B7lu(siSOedORbGPmhaszNdjsBCPXxzhxxBaFXCBaFrd4RbGlObOBuqs6aU2hBCiXaSbGI3AUmaCbnafknGxHs7a(AaP)zNVxXhagZoGOnGIcfkTdq3OGK0bCTp24qIbydafV1Cza4cAaOVcDaFnG0)SZ3R4zn3bgn3x2HkdLrNmCYowsJVYo6gfKKIz2jTHsByzNUhawBddLrCXfLIwqhVUrbjPdq(aqEaDpaDJcss5kMCOMWJlipkERna5da5bOBuqskxVXt)ZoFVIVeclkXaKizaDpaDJcss56nout4XfKhfV1gasdqIKbK(ND(Ef)kymB9FZ32xO8LqyrjgqxdatzoaKYoc2RzhDJcssXmRzn7COMHZ0CF5oUL7l7yjn(k7GiQJVTe5Eu2HkdLrNmCYAUdmZ9LDOYqz0jdNSZFLDeKMDSKgFLDWAByOmk7G1y4u2b5bqYg846Io8OePfxnug5Ln4wP4i8hcBKObirYaizdECDrhUcL8TyfQxeWc2aqAaYhaYdi9p789kEuI0IRgkJ8YgCRuCe(dHnseFj742aKizaP)zNVxXvOKVfRq9IawW4lHWIsmaKgGejdGKn4X1fD4kuY3IvOEralydq(aizdECDrhEuI0IRgkJ8YgCRuCe(dHnsu25qI0gxA8v2bJFjSuPdqCrPOf0za6gfKKkgakffSbGlOZa6fk0by46JW0inawuKi7G1wFziOSJ4IsrlOJx3OGK0SM7OZ5(YouzOm6KHt25VYocsZowsJVYoyTnmugLDWAmCk7yjnWsEQiebjgG0bCBaYhaYdyT44jSuPC7Ce8Ogqxd4MmgGejdO7bSwC8ewQuUDocojRqOIbGu2bRT(YqqzhH6VywvrblR5o6xUVSdvgkJoz4KD(RSJG0SJL04RSdwBddLrzhSgdNYowsdSKNkcrqIb0L0bG5aKpaKhq3dyT44jSuPC7CeCswHqfdqIKbSwC8ewQuUDocojRqOIbiFaipG1IJNWsLYTZrWxcHfLyaDnazmajsgqlGbv9lHWIsmGUgWnzoaKgaszhS26ldbLDSZr4xcHfvwZDiJCFzhQmugDYWj78xzhbPzhlPXxzhS2ggkJYoyngoLDqXBn(giio(1aKpaKhq3dyXlQ9lmIVgmY)nVcL8T9DpQ8jOgIR4lovgkJodqIKbS4f1(fgXxdg5)MxHs(2(Uhv(eudXv8fNkdLrNbiFalEfj)13Jw(HArk0b01aWOdaPSdwB9LHGYo7RTKFdeuwZD0F5(YouzOm6KHt25VYocsZowsJVYoyTnmugLDWAmCk7K(6GhkNw7ejtJcMhL99gG8bGI3ACATtKmnkyEu23Jlulb5aKoamhGejdi91bpuoEXitaLo(2sL75gNkdLrNbiFaO4TghVyKjGshFBPY9CJVeclkXaG4aqEaWsNb4AdaZbGu2bRT(YqqzN2(c1l0nGK8PVo4HkYAUdzFUVSdvgkJoz4KD(RSJG0SJL04RSdwBddLrzhSgdNYohYuOERo(dLm34AKGmkydq(aspwQSs5vadQ6BgLDWARVmeu25qMcv4p4K3sAGLYAUdmAUVSdvgkJoz4KDoKiTXLgFLDCFxxm3gag7(cDaySewADzaiSOulQb46sUnG(m2xIby1zaqs01aC)eIFfeJeIbiBfLs7a2NXIcw2jTHsByzN0xh8q5ewAB7l0biFaQXOs5WmfkTrbZl0FrWPYqz0zaYhaYdO7bOgJkL)OSqP104lovgkJodq(as)ZoFVIFfmMT(V5B7lu(siSOedqIKbii1J(fUGRbTyIr997kna5dqngvk)rzHsRPXxCQmugDgG8b09aqXBn(vWy26)MVTVq54xdaPSJL04RSZsi(vqmsi89IsPnR5o6F5(YouzOm6KHt2XsA8v2b63JffmpkZeA2jTHsByzNUhW5vEBFH6BewA5lHWIsma5da5bOgJkLhjkzxCQmugDgGejdO7bGI3AC0LmfQ)BEruN1G9cJJFna5dqngvkhDjtH6)Mxe1znyVW4uzOm6majsgGAmQu(JYcLwtJV4uzOm6ma5di9p789k(vWy26)MVTVq5lHWIsma5dO7bGI3ACidglkyEewcAueh)AaiLDsULyKxTfgPICh3YAUJBYm3x2HkdLrNmCYoPnuAdl7GI3A8i5Mxn2xc(siSOedaIshaS0zaU2aWCaYhGAmQuEKCZRg7lbNkdLrNbiFaIlIX8QTWivWHXSuymVDWAvIgqxshaMdq(aqEaQXOs5rIs2fNkdLrNbirYauJrLYrxYuO(V5frDwd2lmovgkJodq(as)ZoFVIJUKPq9FZlI6SgSxy8Lqyrjgqxd4MmgGejdqngvk)rzHsRPXxCQmugDgG8b09aqXBn(vWy26)MVTVq54xdaPSJL04RSdmMLcJ5TdwRsuwZDC7wUVSdvgkJoz4KDsBO0gw2bfV14rYnVASVe8LqyrjgaeLoayPZaCTbG5aKpa1yuP8i5Mxn2xcovgkJodq(aqEaQXOs5rIs2fNkdLrNbirYauJrLYrxYuO(V5frDwd2lmovgkJodq(a6EaO4TghDjtH6)Mxe1znyVW44xdq(as)ZoFVIJUKPq9FZlI6SgSxy8Lqyrjgqxd4MmhGejdqngvk)rzHsRPXxCQmugDgG8b09aqXBn(vWy26)MVTVq54xdaPSJL04RStBFH6f6gqszn3XnmZ9LDOYqz0jdNStAdL2WYoPhlvwP8kGbv9nJgG8bCitH6T64puYCJRrcYOGna5d4qMc1B1XFOK5g3sAGL8lHWIsmaioaKhaS0zaU2aUXLXaqAaYhaYdO7bOgJkL)OSqP104lovgkJodqIKbOgJkL)OSqP104lovgkJodq(a6EaO4Tg)kymB9FZ32xOC8RbGu2XsA8v25rzHsRPuwZDCRZ5(YouzOm6KHt25qI0gxA8v2Xvq)xqdW9L04RbWcHoa9hWIxzhlPXxzNKXyElPXxEwi0SdleQVmeu2j9yPYkvK1Ch36xUVSdvgkJoz4KDSKgFLDsgJ5TKgF5zHqZoSqO(YqqzN1sHXezn3XnzK7l7qLHYOtgozhlPXxzNKXyElPXxEwi0SdleQVmeu2r3OGKurwZDCR)Y9LDOYqz0jdNSJL04RStYymVL04lpleA2Hfc1xgck7K(ND(ELiR5oUj7Z9LDOYqz0jdNStAdL2WYoQXOs5PND8qjBvovgkJodq(aqEaDpau8wJdzWyrbZJWsqJI44xdqIKbOgJkLJUKPq9FZlI6SgSxyCQmugDgasdq(aqEahcfV14R5E)gjIlulb5aKoazmajsgq3d4qMc1dzfWGQ8fVO2VWi(AU3VrIgaszhHUrsZDCl7yjn(k7KmgZBjn(YZcHMDyHq9LHGYoPND8qjB1SM74ggn3x2HkdLrNmCYoPnuAdl7GI3AC0LmfQ)BEruN1G9cJJFLDe6gjn3XTSJL04RSZIxElPXxEwi0SdleQVmeu2b9fEnsqgfSSM74w)l3x2HkdLrNmCYoPnuAdl7OgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG8as)ZoFVIJUKPq9FZlI6SgSxy8LqyrjgaehWnzoaKgG8bG8awloEclvk3ohbpQb01aWugdqIKb09awloEclvk3ohbNKviuXaKizaP)zNVxXVcgZw)38T9fkFjewuIbaXbCtMdq(awloEclvk3ohbNKviuXaKpG1IJNWsLYTZrWJAaqCa3K5aqk7yjn(k7S4L3sA8LNfcn7WcH6ldbLDqFH)6FwuWYAUdmLzUVSdvgkJoz4KDsBO0gw2bfV14xbJzR)B(2(cLJFna5dqngvk)rzHsRPXxCQmugDYocDJKM74w2XsA8v2zXlVL04lpleA2Hfc1xgck78OSqP104RSM7aZB5(YouzOm6KHt2jTHsByzNUhGGup6x4cUg0Ijg13VR0aKpGUhWIxu7xyeFnyK)BEfk5B77Eu5tqnexXxCQmugDgG8bOgJkL)OSqP104lovgkJodq(as)ZoFVIFfmMT(V5B7lu(siSOedaId4MmhG8bG8aWAByOmIlu)fZQkkydqIKbSwC8ewQuUDocojRqOIbiFaRfhpHLkLBNJGh1aG4aUjZbirYa6EaRfhpHLkLBNJGtYkeQyaiLDSKgFLDw8YBjn(YZcHMDyHq9LHGYopkluAnn(YF9plkyzn3bMyM7l7qLHYOtgozN0gkTHLDSKgyjpveIGedOlPdaZSJq3iP5oULDSKgFLDw8YBjn(YZcHMDyHq9LHGYo2tzn3bMDo3x2HkdLrNmCYowsJVYojJX8wsJV8SqOzhwiuFziOSJqT6y7jRzn7ypL7l3XTCFzhQmugDYWj7CirAJln(k74(EmUb4(F104RSJL04RSZsi(vqmsi89IsPnR5oWm3x2HkdLrNmCYoPnuAdl7OgJkL32xOIKBkuItLHYOt2XsA8v2bgZsHX82bRvjkR5o6CUVSdvgkJoz4KDsBO0gw2bfV14qgmwuW8iSe0Oi(swshG8b09aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCtHszn3r)Y9LDOYqz0jdNStAdL2WYoyTnmugX3xBj)giObiFaQXOs5gwJzvckXPYqz0j7yjn(k7a97XIcMhLzcnR5oKrUVSdvgkJoz4KDsBO0gw2P7bGI3A8nqqC8RbiFawsdSKNkcrqIbarPdOZdqIKbyjnWsEQiebjgqxdOZzhlPXxzhymlfgZBhSwLOSM7O)Y9LDOYqz0jdNSJL04RStBFH6f6gqszNKBjg5vBHrQi3XTStAdL2WYoP)zNVxXxcXVcIrcHVxukT8LqyrjgaeLoamhGRnayPZaKpa1yuPCyMcL2OG5f6Vi4uzOm6KDoKiTXLgFLDWy)fboZI0aSRR9Te0bO)aslzknaBaxcc)8d4AJFd1TbO2cJ0bWcHoG2VdWUUyUffSbSM79BKObe1aSNYAUdzFUVSdvgkJoz4KDsBO0gw2bRTHHYi((Al53abLDSKgFLDG(9yrbZJYmHM1Chy0CFzhQmugDYWj7K2qPnSSJAmQuomtHsBuW8c9xeCQmugDgG8bGI3A8Lq8RGyKq47fLslh)AaYhGL0al5PIqeKyaDnamhG8b09aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCtHszn3r)l3x2HkdLrNmCYoPnuAdl7G12Wqze)qMcv4p4K3sAGLgG8bGI3A8dzkuH)GtCHAjihaehq)gGejdqngvkhMPqPnkyEH(lcovgkJodq(aqXBn(si(vqmsi89IsPLJFLDSKgFLDEuwO0AkL1Ch3KzUVSdvgkJoz4KDSKgFLDA7luVq3ask7K2qPnSSZIxrYF99OLFOwKcDaqCaipGBYyaqyaQXOs5lEfjVPkv4MgFXPYqz0zaU2aKXaqk7KClXiVAlmsf5oUL1Ch3UL7l7qLHYOtgozN0gkTHLD6EayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUPqPSM74gM5(YouzOm6KHt2XsA8v25rzHsRPu2jTHsByzNfVIK)67rl)qTif6a6AaipamLXaGWauJrLYx8ksEtvQWnn(ItLHYOZaCTbiJbGu2j5wIrE1wyKkYDClR5oU15CFzhlPXxzhymlfgZBhSwLOSdvgkJoz4K1Ch36xUVSJL04RStBFHksUPqPSdvgkJoz4K1Ch3KrUVSdvgkJoz4KDSKgFLDA7luVq3ask7KClXiVAlmsf5oUL1Ch36VCFzhlPXxzhO)w(V57fLsB2HkdLrNmCYAUJBY(CFzhlPXxzhBtwrE93Lkn7qLHYOtgoznRzn7GLwr8vUdmLjMykZ(Hjgn70Z2kkyISJSL7Z93HRRdxF3nGb0huAabIRF1b0(Da3FuwO0AA8L)6FwuWUpGLKn4XsNbiEe0amC9rykDgqcQvWibFGVtrrdat3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7dW0bGXHX0PbG8nzHeFGFGx2Y95(7W11HRV7gWa6dknGaX1V6aA)oG7PND8qjB17dyjzdES0zaIhbnadxFeMsNbKGAfmsWh47uu0aU5Ub4QVWsRsNbCFXlQ9lmIJH7dq)bCFXlQ9lmIJbovgkJo3haY9twiXh47uu0aW0DdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MSqIpW3POOb0z3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYcj(aFNIIgq)C3aC1xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKVjlK4d8DkkAaYWDdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MSqIpWpWlB5(C)D466W13Ddya9bLgqG46xDaTFhW9hLfkTMgFDFaljBWJLodq8iOby46JWu6mGeuRGrc(aFNIIgaMUBaU6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haY3Kfs8b(offnamD3aC1xyPvPZaUN(6Ghkhd3hG(d4E6RdEOCmWPYqz05(aq(MSqIpW3POObCtMUBaU6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haYyklK4d8d8YwUp3FhUUoC9D3agqFqPbeiU(vhq73bCh9fEnsqgfS7dyjzdES0zaIhbnadxFeMsNbKGAfmsWh47uu0aU5Ub4QVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiFtwiXh47uu0aW0DdWvFHLwLodWjq4QbiCRutwdq2na9hqNWTbCcSHi(Aa)fTM(7aqgUinaKVjlK4d8DkkAaD2DdWvFHLwLodWjq4QbiCRutwdq2na9hqNWTbCcSHi(Aa)fTM(7aqgUinaKVjlK4d8DkkAa9ZDdWvFHLwLodWjq4QbiCRutwdq2na9hqNWTbCcSHi(Aa)fTM(7aqgUinaKVjlK4d8DkkAa9ZDdWvFHLwLod4(Ixu7xyehd3hG(d4(Ixu7xyehdCQmugDUpaKVjlK4d8d8YwUp3FhUUoC9D3agqFqPbeiU(vhq73bCp9yPYkvCFaljBWJLodq8iOby46JWu6mGeuRGrc(aFNIIgWn3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7dazmLfs8b(offnamD3aC1xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKVjlK4d8DkkAaD2DdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MSqIpW3POOb0p3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYcj(aFNIIgGmC3aC1xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKXuwiXh47uu0aK9UBaU6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haY3Kfs8b(offnG(N7gGR(clTkDgWDXJZqJ6WXW9bO)aUlECgAuhog4uzOm6CFaiJPSqIpWpWlB5(C)D466W13Ddya9bLgqG46xDaTFhWDHA1X2Z9bSKSbpw6maXJGgGHRpctPZasqTcgj4d8DkkAa9N7gGR(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9by6aW4Wy60aq(MSqIpW3POObGrD3aC1xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKVjlK4d8DkkAa9p3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5ollK4d8d8YwUp3FhUUoC9D3agqFqPbeiU(vhq73bCh9f(R)zrb7(aws2GhlDgG4rqdWW1hHP0zajOwbJe8b(offnG(5Ub4QVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiFtwiXh47uu0aKH7gGR(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG8nzHeFGFGx2Y95(7W11HRV7gWa6dknGaX1V6aA)oG7xlLEeOMEFaljBWJLodq8iOby46JWu6mGeuRGrc(aFNIIgWn3nax9fwAv6maNaHRgGWTsnznazNSBa6pGoHBdaXFWz4Ib8x0A6VdazzhsdazmLfs8b(offnGBUBaU6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haYDwwiXh47uu0aU5Ub4QVWsRsNbCx3OGKu(nogUpa9hWDDJcss56nogUpaK7SSqIpW3POObGP7gGR(clTkDgGtGWvdq4wPMSgGSt2na9hqNWTbG4p4mCXa(lAn93bGSSdPbGmMYcj(aFNIIgaMUBaU6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haYDwwiXh47uu0aW0DdWvFHLwLod4UUrbjPCm5y4(a0Fa31nkijLRyYXW9bGCNLfs8b(offnGo7Ub4QVWsRsNb4eiC1aeUvQjRbi7gG(dOt42aob2qeFnG)Iwt)DaidxKgaYyklK4d8DkkAaD2DdWvFHLwLod4UUrbjP8BCmCFa6pG76gfKKY1BCmCFai3pzHeFGVtrrdOZUBaU6lS0Q0za31nkijLJjhd3hG(d4UUrbjPCftogUpaKLHSqIpW3POOb0p3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYcj(aFNIIgq)C3aC1xyPvPZaUV4f1(fgXXW9bO)aUV4f1(fgXXaNkdLrN7dW0bGXHX0PbG8nzHeFGVtrrdOFUBaU6lS0Q0za3tFDWdLJH7dq)bCp91bpuog4uzOm6CFaiFtwiXh4h4LTCFU)oCDD467UbmG(GsdiqC9RoG2Vd4E6F257vI7dyjzdES0zaIhbnadxFeMsNbKGAfmsWh47uu0aW0DdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MSqIpW3POObGP7gGR(clTkDgWDXJZqJ6WXW9bO)aUlECgAuhog4uzOm6CFaiJPSqIpW3POOb0z3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYcj(aFNIIgqND3aC1xyPvPZaUV4f1(fgXXW9bO)aUV4f1(fgXXaNkdLrN7da5BYcj(aFNIIgq)C3aC1xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpathaghgtNgaY3Kfs8b(offnaz4Ub4QVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiFtwiXh47uu0a6p3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYcj(aFNIIgGS3DdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MSqIpW3POObi7D3aC1xyPvPZaUV4f1(fgXXW9bO)aUV4f1(fgXXaNkdLrN7da5BYcj(aFNIIgq)ZDdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MSqIpW3POObC7M7gGR(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG8nzHeFGVtrrd4gMUBaU6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haYyklK4d8DkkAa3KH7gGR(clTkDgW9fVO2VWiogUpa9hW9fVO2VWiog4uzOm6CFaMoamomMonaKVjlK4d8d8YwUp3FhUUoC9D3agqFqPbeiU(vhq73bCx3OGKuX9bSKSbpw6maXJGgGHRpctPZasqTcgj4d8DkkAa3C3aC1xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKXuwiXh47uu0aKH7gGR(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bGmMYcj(aFNIIgGmC3aC1xyPvPZaURBuqsk)ghd3hG(d4UUrbjPC9ghd3haY3Kfs8b(offnaz4Ub4QVWsRsNbCx3OGKuoMCmCFa6pG76gfKKYvm5y4(aqgtzHeFGVtrrdO)C3aC1xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKXuwiXh47uu0a6p3nax9fwAv6mG76gfKKYVXXW9bO)aURBuqskxVXXW9bGmMYcj(aFNIIgq)5Ub4QVWsRsNbCx3OGKuoMCmCFa6pG76gfKKYvm5y4(aq(MSqIpW3POObi7D3aC1xyPvPZaURBuqsk)ghd3hG(d4UUrbjPC9ghd3haY3Kfs8b(offnazV7gGR(clTkDgWDDJcss5yYXW9bO)aURBuqskxXKJH7dazmLfs8b(offnamQ7gGR(clTkDgWDDJcss534y4(a0Fa31nkijLR34y4(aqgtzHeFGVtrrdaJ6Ub4QVWsRsNbCx3OGKuoMCmCFa6pG76gfKKYvm5y4(aq(MSqIpWpWlB5(C)D466W13Ddya9bLgqG46xDaTFhW9d1mCMEFaljBWJLodq8iOby46JWu6mGeuRGrc(aFNIIgGmC3aC1xyPvPZaUV4f1(fgXXW9bO)aUV4f1(fgXXaNkdLrN7dazmLfs8b(offnG(ZDdWvFHLwLod4E6RdEOCmCFa6pG7PVo4HYXaNkdLrN7da5BYcj(aFNIIgag1DdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aqUZYcj(aFNIIgq)ZDdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aqUZYcj(aFNIIgWnz6Ub4QVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFai3pzHeFGVtrrd42n3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5(jlK4d8DkkAa3W0DdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aqgtzHeFGVtrrd4MS3DdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aqgtzHeFGVtrrd4w)ZDdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MSqIpW3POObGPmD3aC1xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpathaghgtNgaY3Kfs8b(offnamV5Ub4QVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiFtwiXh47uu0aW8M7gGR(clTkDgW9fVO2VWiogUpa9hW9fVO2VWiog4uzOm6CFaiFtwiXh4h4LTCFU)oCDD467UbmG(GsdiqC9RoG2Vd4U909bSKSbpw6maXJGgGHRpctPZasqTcgj4d8DkkAay6Ub4QVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaMoamomMonaKVjlK4d8DkkAa9ZDdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(amDayCymDAaiFtwiXh47uu0a6p3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7dW0bGXHX0PbG8nzHeFGVtrrdaJ6Ub4QVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiFtwiXh47uu0a6FUBaU6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haY3Kfs8b(offnGBY0DdWvFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MSqIpW3POObCdt3nax9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYcj(a)aVRdX1VkDgWTopalPXxdGfcvWh4ZoIlkL7atzCl7CTFlyu2bJGrgGRhYuOdW1RkGbvhag7(cDGhJGrgq)3MBd4w)CzayktmXCGFGhJGrgGRGAfmsmWJrWidq2EaUFcXJLodGzcv2wqPVodaxyWOb8Tb4kOwuIb8Tb46s0amXacDaNNe1DDaxmZTb0JySbe1aUwlPrI4d8yemYaKThGRNVURdib1QIydaJLrcOP1A6ao4BuWgaCwYuOd4BdWjQZAWEHXh4h4XidaJdRXWnLedWgGUrbjPIbK(ND(ELld4eyJdDgaQBd4kymBhW3gqBFHoGFha6sMcDaFBaIOoRb7f2DXas)ZoFVIpaxxBaHExmaSgdNgautmG6hWsiSOo0oGLu8TgWnxgaXe0awsX3AaYKld(aVL04lb)AP0Ja1uiifUyTnmug5sziiP6gfKK6V5fUvjx(lPcsJMlyngoj9Mlyngo5jMGKktUmCj91j04lP6gfKKYVXHAcpUG8O4TMCK7wngvkhDjtH6)Mxe1znyVWKJSUrbjP8B80)SZ3R4h8104lzNSl9p789k(vWy26)MVTVq5h8104lPYejjsuJrLYrxYuO(V5frDwd2lm5iN(ND(EfhDjtH6)Mxe1znyVW4h8104lzNSdzDJcss534P)zNVxXp4RPXxD1)FdjPYejjsuJrLYJeLSlKg4TKgFj4xlLEeOMcbPWfRTHHYixkdbjv3OGKupMEHBvYL)sQG0O5cwJHtsV5cwJHtEIjiPYKldxsFDcn(sQUrbjPCm5qnHhxqEu8wtoYDRgJkLJUKPq9FZlI6SgSxyYrw3OGKuoM80)SZ3R4h8104lzNSl9p789k(vWy26)MVTVq5h8104lPYejjsuJrLYrxYuO(V5frDwd2lm5iN(ND(EfhDjtH6)Mxe1znyVW4h8104lzNSdzDJcss5yYt)ZoFVIFWxtJV6Q))gssLjssKOgJkLhjkzxinWJrgagNqdeMsIbydq3OGKuXaWAmCAaOUnG0J4Y2OGnafknG0)SZ3RgW3gGcLgGUrbjPUmGtGno0zaOUnafknGd(AA81a(2auO0aqXBTbe6aU2hBCibFa9FmXaSbi0Lkyk0bG4prlODa6paybwAa2aGgWGs7aU243qDBa6paHUubtHoaDJcssfUmatmGEeJnatmaBai(t0cAhq73beTbydq3OGK0b0lySb87a6fm2aQxhGWTknGEHcDaP)zNVxj4d8wsJVe8RLspcutHGu4I12WqzKlLHGKQBuqsQ)AJFd1nx(lPcsJMlyngojftxWAmCYtmbj9MlPVoHgFjTBDJcss534qnHhxqEu8wtUUrbjPCm5qnHhxqEu8wtIeDJcss5yYHAcpUG8O4TMCKrw3OGKuoM80)SZ3R4h8104lzhY6gfKKYXKJI3A(d(AA8vx9)YKlZBiHKRH8nUmGGUrbjPCm5qnHhfV14cDPcMcfjxdzS2ggkJ46gfKK6X0lCRsiHuxiJSUrbjP8B80)SZ3R4h8104lzhY6gfKKYVXrXBn)bFnn(QR(FzYL5nKqY1q(gxgqq3OGKu(nout4rXBnUqxQGPqrY1qgRTHHYiUUrbjP(BEHBvcjKg4TKgFj4xlLEeOMcbPWfRTHHYixkdbjD75rXBnHlyngojvngvkhMPqPnkyEH(lcjssFDWdLtyPTTVqLizXlQ9lmIJgAuW8PNDg4TKgFj4xlLEeOMcbPWTXib00AnDGFGhJGrgagNSOeUsNbqyP1TbObcAakuAaws)DaHyagwlygkJ4d8wsJVesre1X3wICpAGhJmam(LWsLoaXfLIwqNbOBuqsQyaOuuWgaUGodOxOqhGHRpctJ0ayrrIbElPXxciifUyTnmug5sziiPIlkfTGoEDJcssDbRXWjPitYg846Io8OePfxnug5Ln4wP4i8hcBKijsizdECDrhUcL8TyfQxeWcgsYro9p789kEuI0IRgkJ8YgCRuCe(dHnseFj74MejP)zNVxXvOKVfRq9IawW4lHWIsGKejKSbpUUOdxHs(wSc1lcybtojBWJRl6WJsKwC1qzKx2GBLIJWFiSrIg4TKgFjGGu4I12WqzKlLHGKku)fZQkkyUG1y4KulPbwYtfHiiH0BYrET44jSuPC7Ce8O66MmKiP71IJNWsLYTZrWjzfcvG0aVL04lbeKcxS2ggkJCPmeKu7Ce(Lqyr5cwJHtsTKgyjpveIGeDjft5i39AXXtyPs525i4KScHkKizT44jSuPC7CeCswHqfYrET44jSuPC7Ce8Lqyrj6sgsK0cyqv)siSOeDDtMiH0aVL04lbeKcxS2ggkJCPmeK091wYVbcYfSgdNKII3A8nqqC8l5i39Ixu7xyeFnyK)BEfk5B77Eu5tqnexXxsKS4f1(fgXxdg5)MxHs(2(Uhv(eudXv8L8fVIK)67rl)qTifAxyuKg4TKgFjGGu4I12WqzKlLHGK22xOEHUbKKp91bpuHlyngojn91bpuoT2jsMgfmpk77jhfV140ANizAuW8OSVhxOwcsPykrs6RdEOC8IrMakD8TLk3Zn5O4TghVyKjGshFBPY9CJVeclkbergw64AyI0aVL04lbeKcxS2ggkJCPmeK0dzkuH)GtElPbwYfSgdNKEitH6T64puYCJRrcYOGjp9yPYkLxbmOQVz0apgzaUVRlMBdaJDFHoamwclTUmaewuQf1aCDj3gqFg7lXaS6maij6AaUFcXVcIrcXaKTIsPDa7ZyrbBG3sA8LacsH7si(vqmsi89IsP1LOjn91bpuoHL22(cvUAmQuomtHsBuW8c9xeYrUB1yuP8hLfkTMgFjp9p789k(vWy26)MVTVq5lHWIsirIGup6x4cUg0Ijg13VRKC1yuP8hLfkTMgFjVBu8wJFfmMT(V5B7luo(fsd8wsJVeqqkCH(9yrbZJYmH6sYTeJ8QTWivi9MlrtA3Nx5T9fQVryPLVeclkHCKvJrLYJeLSljs6gfV14Olzku)38IOoRb7fgh)sUAmQuo6sMc1)nViQZAWEHjrIAmQu(JYcLwtJVKN(ND(Ef)kymB9FZ32xO8LqyrjK3nkERXHmySOG5ryjOrrC8lKg4TKgFjGGu4cJzPWyE7G1Qe5s0KII3A8i5Mxn2xc(siSOequkS0X1WuUAmQuEKCZRg7lHCXfXyE1wyKk4WywkmM3oyTkrDjft5iRgJkLhjkzxsKOgJkLJUKPq9FZlI6SgSxyYt)ZoFVIJUKPq9FZlI6SgSxy8Lqyrj66MmKirngvk)rzHsRPXxY7gfV14xbJzR)B(2(cLJFH0aVL04lbeKc32(c1l0nGKCjAsrXBnEKCZRg7lbFjewucikfw64AykxngvkpsU5vJ9LqoYQXOs5rIs2LejQXOs5Olzku)38IOoRb7fM8UrXBno6sMc1)nViQZAWEHXXVKN(ND(EfhDjtH6)Mxe1znyVW4lHWIs01nzkrIAmQu(JYcLwtJVK3nkERXVcgZw)38T9fkh)cPbElPXxciifUpkluAnLCjAstpwQSs5vadQ6Bgj)qMc1B1XFOK5gxJeKrbt(HmfQ3QJ)qjZnUL0al5xcHfLaIidlDCTBCzGKCK7wngvk)rzHsRPXxsKOgJkL)OSqP104l5DJI3A8RGXS1)nFBFHYXVqAGhJmaxb9Fbna3xsJVgale6a0FalEnWBjn(sabPWnzmM3sA8LNfc1LYqqstpwQSsfd8wsJVeqqkCtgJ5TKgF5zHqDPmeK01sHXed8wsJVeqqkCtgJ5TKgF5zHqDPmeKuDJcssfd8wsJVeqqkCtgJ5TKgF5zHqDPmeK00)SZ3Red8wsJVeqqkCtgJ5TKgF5zHqDPmeK00ZoEOKTQlcDJKk9MlrtQAmQuE6zhpuYwvoYDJI3ACidglkyEewcAueh)sIe1yuPC0LmfQ)BEruN1G9cdj5iFiu8wJVM79BKiUqTeKsLHejDFitH6HScyqv(Ixu7xyeFn373irinWBjn(sabPWDXlVL04lpleQlLHGKI(cVgjiJcMlcDJKk9MlrtkkERXrxYuO(V5frDwd2lmo(1aVL04lbeKc3fV8wsJV8SqOUugcsk6l8x)ZIcMlrtQAmQuo6sMc1)nViQZAWEHjh50)SZ3R4Olzku)38IOoRb7fgFjewuciEtMijh51IJNWsLYTZrWJQlmLHejDVwC8ewQuUDocojRqOcjss)ZoFVIFfmMT(V5B7lu(siSOeq8MmLVwC8ewQuUDocojRqOc5RfhpHLkLBNJGhfeVjtKg4TKgFjGGu4U4L3sA8LNfc1LYqqsFuwO0AA8LlcDJKk9MlrtkkERXVcgZw)38T9fkh)sUAmQu(JYcLwtJVg4TKgFjGGu4U4L3sA8LNfc1LYqqsFuwO0AA8L)6FwuWCjAs7wqQh9lCbxdAXeJ673vsE3lErTFHr81Gr(V5vOKVTV7rLpb1qCfFjxngvk)rzHsRPXxYt)ZoFVIFfmMT(V5B7lu(siSOeq8MmLJmwBddLrCH6VywvrbtIK1IJNWsLYTZrWjzfcviFT44jSuPC7Ce8OG4nzkrs3RfhpHLkLBNJGtYkeQaPbElPXxciifUlE5TKgF5zHqDPmeKu7jxe6gjv6nxIMulPbwYtfHiirxsXCG3sA8LacsHBYymVL04lpleQlLHGKkuRo2Eg4h4XidW99yCdW9)QPXxd8wsJVeC7jPlH4xbXiHW3lkL2bElPXxcU9eeKcxymlfgZBhSwLixIMu1yuP82(cvKCtHsd8wsJVeC7jiifUT9fQi5McLCjAsrXBnoKbJffmpclbnkIVKLu5DJ12Wqze)qMcv4p4K3sAGLg4TKgFj42tqqkCH(9yrbZJYmH6s0KI12WqzeFFTL8BGGKRgJkLBynMvjO0aVL04lb3EccsHlmMLcJ5TdwRsKlrtA3O4TgFdeeh)sUL0al5PIqeKaIs7SejwsdSKNkcrqIU68apgzayS)IaNzrAa211(wc6a0FaPLmLgGnGlbHF(bCTXVH62auBHr6ayHqhq73byxxm3Ic2awZ9(ns0aIAa2td8wsJVeC7jiifUT9fQxOBaj5sYTeJ8QTWivi9MlrtA6F257v8Lq8RGyKq47fLslFjewucikftxdw6ixngvkhMPqPnkyEH(lIbElPXxcU9eeKcxOFpwuW8OmtOUenPyTnmugX3xBj)giObElPXxcU9eeKc32(cvKCtHsUenPQXOs5WmfkTrbZl0FrihfV14lH4xbXiHW3lkLwo(LClPbwYtfHiirxykVBS2ggkJ4hYuOc)bN8wsdS0aVL04lb3EccsH7JYcLwtjxIMuS2ggkJ4hYuOc)bN8wsdSKCu8wJFitHk8hCIlulbje7NejQXOs5WmfkTrbZl0FrihfV14lH4xbXiHW3lkLwo(1aVL04lb3EccsHBBFH6f6gqsUKClXiVAlmsfsV5s0KU4vK8xFpA5hQfPqHiY3KbeuJrLYx8ksEtvQWnn(Y1Kbsd8wsJVeC7jiifUT9fQi5McLCjAs7gRTHHYi(HmfQWFWjVL0alnWBjn(sWTNGGu4(OSqP1uYLKBjg5vBHrQq6nxIM0fVIK)67rl)qTifAxiJPmGGAmQu(IxrYBQsfUPXxUMmqAG3sA8LGBpbbPWfgZsHX82bRvjAG3sA8LGBpbbPWTTVqfj3uO0aVL04lb3EccsHBBFH6f6gqsUKClXiVAlmsfsVnWBjn(sWTNGGu4c93Y)nFVOuAh4TKgFj42tqqkCTnzf51FxQ0b(bEmYaGZsMcDaFBaorDwd2lSbC9plkydyF104Rb4UbiuBvXaUjtXaqP2V0aGZ7mGqmadRfmdLrd8wsJVeC0x4V(NffmPlH4xbXiHW3lkLwxIMulPbwYtfHiirxsXuIeS2ggkJ4BppkERjg4TKgFj4OVWF9plkyqqkCFuwO0Ak5sYTeJ8QTWivi9MlrtkkERXHmySOG5ryjOrr8LSKkp9p789k(vWy26)MVTVq5lHWIs0vNh4TKgFj4OVWF9plkyqqkCH(9yrbZJYmH6s0KI12WqzeFFTL8BGGg4TKgFj4OVWF9plkyqqkCB7lurYnfk5s0KII3ACidglkyEewcAueFjlPYx8ks(RVhT8d1IuODH8nzab1yuP8fVIK3uLkCtJVCnzGKCXfXyE1wyKk4T9fQi5McL6ct5DJ12Wqze)qMcv4p4K3sAGLg4TKgFj4OVWF9plkyqqkCB7lurYnfk5s0KU4vK8xFpA5hQfPq7skYDwgqqngvkFXRi5nvPc304lxtgijxCrmMxTfgPcEBFHksUPqPUWuE3yTnmugXpKPqf(do5TKgyPbEmcgza3vBHrQpAsryYYDiFiu8wJVM79BKiUqTeKq4gsYoKpekERXxZ9(nseFjewuciCdjx7qMc1dzfWGQ8fVO2VWi(AU3VrIUpa3pDrMkgGna2RUmafAigqigqukvh6ma9hGAlmshGcLga0agusOd4AJFd1TbqfHWTb0luOdWQbyOblu3gGc10b0lySbyxxm3gWAU3VrIgq0gWIxu7xy0HpG(GA6aqPOGnaRgavec3gqVqHoazoaHAjifUmGFhGvdGkcHBdqHA6auO0aoekERnGEbJnaX)1aizDflnGV4d8wsJVeC0x4V(NffmiifUpkluAnLCj5wIrE1wyKkKEZLOjDXRi5V(E0YpulsH2LumLXaVL04lbh9f(R)zrbdcsHlmMLcJ5TdwRsKlrt6IxrYF99OLFOwKcfIykt5IlIX8QTWivWHXSuymVDWAvI6skMYt)ZoFVIFfmMT(V5B7lu(siSOeDjJbElPXxco6l8x)ZIcgeKc32(c1l0nGKCj5wIrE1wyKkKEZLOjDXRi5V(E0YpulsHcrmLP80)SZ3R4xbJzR)B(2(cLVeclkrxYyG3sA8LGJ(c)1)SOGbbPWfgZsHX82bRvjYLOjn9p789k(vWy26)MVTVq5lHWIs01IxexdeKxFF)KV4vK8xFpA5hQfPqHy)KPCXfXyE1wyKk4WywkmM3oyTkrDjfZbElPXxco6l8x)ZIcgeKc32(c1l0nGKCj5wIrE1wyKkKEZLOjn9p789k(vWy26)MVTVq5lHWIs01IxexdeKxFF)KV4vK8xFpA5hQfPqHy)K5a)apgzaWzjtHoGVnaNOoRb7f2aCFjnWsdW9)QPXxd8wsJVeC0x41ibzuWK(OSqP1uYLKBjg5vBHrQq6nxIM0fVIK)67rleLIC)KbeuJrLYx8ksEtvQWnn(Y1Kbsd8wsJVeC0x41ibzuWGGu4UeIFfeJecFVOuADjAsXAByOmIV98O4TMqIelPbwYtfHiirxsXuIKfVIK)67rle7mMYx8I4AGG867XeIlEfj)13Jwz3T(BG3sA8LGJ(cVgjiJcgeKc3dzkuVvh)HsMBUenPlEfj)13Jwi2zmLV4fX1ab513Jjex8ks(RVhTYUB93aVL04lbh9fEnsqgfmiifUq)ESOG5rzMqDjAsXAByOmIVV2s(nqqYrEXRi5V(E02L0(jdjsw8I4AGG8677meLclDKizXlQ9lmIVgmY)nVcL8T9DpQ8jOgIR4ljsexeJ5vBHrQGd97XIcMhLzcTlPykrckERX3abXxcHfLaIDgjjsw8ks(RVhTqSZykFXlIRbcYRVhtiU4vK8xFpALD36VbElPXxco6l8AKGmkyqqkCB7lurYnfk5s0KII3ACidglkyEewcAueh)sU4IymVAlmsf82(cvKCtHsDHP8UXAByOmIFitHk8hCYBjnWsd8wsJVeC0x41ibzuWGGu4(OSqP1uYLKBjg5vBHrQq6nxIMuu8wJdzWyrbZJWsqJI4lzjDG3sA8LGJ(cVgjiJcgeKcxO)w(V57fLsRlrt6IxrYF99OfIs7pzkFXlIRbcYRVVZDblDg4TKgFj4OVWRrcYOGbbPWTTVqfj3uOKlrtQ4IymVAlmsf82(cvKCtHsDHP8UXAByOmIFitHk8hCYBjnWsd8wsJVeC0x41ibzuWGGu4(OSqP1uYLKBjg5vBHrQq6nxIM0fVIK)67rl)qTifAxykdjsw8I4AGG8677meHLod8wsJVeC0x41ibzuWGGu4c97XIcMhLzc1LOjfRTHHYi((Al53abnWBjn(sWrFHxJeKrbdcsHRTjRiV(7sL6s0KU4vK8xFpAHOmK5a)a)apgbJmax9SZa6)q2QdWvFDcn(smWBjn(sWtp74Hs2QstqTOe(V5Je5s0KI(cH8wadQ6xcHfLaIWsh5iV4fbrmLiPBu8wJdzWyrbZJWsqJI44xYrUBewuEOwD4ycvokERXtp74Hs2QCHAji7sA)GWIxu7xyehYNPXAcFZW(RejiSO8qT6WXeQCu8wJNE2XdLSv5c1sq2fgfclErTFHrCiFMgRj8nd7VijrckERXHmySOG5ryjOrrC8l5i3nclkpuRoCmHkhfV14PND8qjBvUqTeKDHrHWIxu7xyehYNPXAcFZW(RejiSO8qT6WXeQCu8wJNE2XdLSv5c1sq21nzcHfVO2VWioKptJ1e(MH9xKqAGhJmG(Ve0ao4BuWgagFWy2oGEHcDaUUeLSl4cNLmf6aVL04lbp9SJhkzRcbPWnb1Is4)MpsKlrtA3QXOs5pkluAnn(sokERXVcgZw)38T9fkh)sokERXtp74Hs2QCHAji7s6nzkhzu8wJFfmMT(V5B7lu(siSOeqew64AiFdcP)zNVxXB7l0EUTie(g(6gFj74gssKGI3AC8c6ZCZl0Lkyku(siSOeqew6irckERXtqTx4rTI4lHWIsaryPdsd8yKbGXGRI4qd4BdaJpymBhaUGmy0a6fk0b46suYUGlCwYuOd8wsJVe80ZoEOKTkeKc3eulkH)B(irUenPDRgJkL)OSqP104l5hYuOEiRaguLV4f1(fgXBgJrLpT4c7qR8UrXBn(vWy26)MVTVq54xYt)ZoFVIFfmMT(V5B7lu(siSOeDDtgYrgfV14PND8qjBvUqTeKDj9MmLJmkERXXlOpZnVqxQGPq54xsKGI3A8eu7fEuRio(fssKGI3A80ZoEOKTkxOwcYUKERZinWBjn(sWtp74Hs2QqqkCtqTOe(V5Je5s0K2TAmQu(JYcLwtJVK39HmfQhYkGbv5lErTFHr8MXyu5tlUWo0khfV14PND8qjBvUqTeKDj9MmL3nkERXVcgZw)38T9fkh)sE6F257v8RGXS1)nFBFHYxcHfLOlmL5apgzay8lHLkDaU6zNb0)HSvhWJL2KDDffSbCW3OGnGRGXSDG3sA8LGNE2XdLSvHGu4MGArj8FZhjYLOjvngvk)rzHsRPXxY7gfV14xbJzR)B(2(cLJFjhzu8wJNE2XdLSv5c1sq2L0B9toYO4TghVG(m38cDPcMcLJFjrckERXtqTx4rTI44xijrckERXtp74Hs2QCHAji7s6T(NejP)zNVxXVcgZw)38T9fkFjewuci2z5O4Tgp9SJhkzRYfQLGSlP36hsd8d8yKbGX)A81aVL04lbp9p789kH0RxJVCjAsrXBn(vWy26)MVTVq54xd8yKb4Q)zNVxjg4TKgFj4P)zNVxjGGu4siU(E06x8I89i76lxIMu1yuP8hLfkTMgFjFXlcI9NCKXAByOmIlu)fZQkkysKG12Wqze3ohHFjewuijh50)SZ3R4xbJzR)B(2(cLVeclkbeLHCKt)ZoFVI3yKaAATMYxcHfLOlzix84m0Oo8lCHIZipT4xA8LejDlECgAuh(fUqXzKNw8ln(cjjsqXBn(vWy26)MVTVq54xijrc6leYBbmOQFjewuciIPmh4TKgFj4P)zNVxjGGu4siU(E06x8I89i76lxIMu1yuPC0LmfQ)BEruN1G9ct(IxeeLH8fVIK)67rlerU)KPS9HmfQhYkGbv5lErTFHrCOUjuAdZ1KHS9Ixu7xyeFnexwPEDTs0OLQe5AYaj5iJI3AC0LmfQ)BEruN1G9cJJFjrslGbv9lHWIsarmLjsd8wsJVe80)SZ3ReqqkCjexFpA9lEr(EKD9LlrtQAmQuEKOKDnWBjn(sWt)ZoFVsabPW9kymB9FZ32xOUenPQXOs5Olzku)38IOoRb7fMCKXAByOmIlu)fZQkkysKG12Wqze3ohHFjewuijh50)SZ3R4Olzku)38IOoRb7fgFjewucjss)ZoFVIJUKPq9FZlI6SgSxy8LSJBYx8ks(RVhTD1FYaPbElPXxcE6F257vciifUxbJzR)B(2(c1LOjvngvkpsuYUK3nkERXVcgZw)38T9fkh)AG3sA8LGN(ND(ELacsH7vWy26)MVTVqDjAsvJrLYFuwO0AA8LCKx8ks(RVhTDjTZYqE3O4Tg3qFerzA8LNfiq54xsKGI3ACd9reLPXxEwGaLJFjrYIxu7xyeFnyK)BEfk5B77Eu5tqnexXxijhzS2ggkJ4c1FXSQIcMejyTnmugXTZr4xcHffsYrwngvkhMPqPnkyEH(lcovgkJoYrXBn(si(vqmsi89IsPLJFjrs3QXOs5WmfkTrbZl0FrWPYqz0bPbElPXxcE6F257vciifUOlzku)38IOoRb7fMlrtkkERXVcgZw)38T9fkh)AG3sA8LGN(ND(ELacsHBBFH2ZTfHW3Wx3CjAsTKgyjpveIGesVjhfV14xbJzR)B(2(cLVeclkbeHLoYrXBn(vWy26)MVTVq54xY7wngvk)rzHsRPXxYrU71IJNWsLYTZrWjzfcvirYAXXtyPs525i4r1vNLjssK0cyqv)siSOeqSZd8wsJVe80)SZ3ReqqkCB7l0EUTie(g(6MlrtQL0al5PIqeKOlPykhzu8wJFfmMT(V5B7luo(LejRfhpHLkLBNJGtYkeQq(AXXtyPs525i4r1v6F257v8RGXS1)nFBFHYxcHfLacYEKKJmkERXVcgZw)38T9fkFjewuciclDKizT44jSuPC7CeCswHqfYxloEclvk3ohbFjewuciclDqAG3sA8LGN(ND(ELacsHBBFH2ZTfHW3Wx3CjAsvJrLYFuwO0AA8LCKrXBn(vWy26)MVTVq54xY7gHfLhQvhoMqLiPBu8wJFfmMT(V5B7luo(LCewuEOwD4ycvE6F257v8RGXS1)nFBFHYxcHfLaj5iJmkERXVcgZw)38T9fkFjewuciclDKibfV144f0N5MxOlvWuOC8l5O4TghVG(m38cDPcMcLVeclkbeHLoijh5dHI3A81CVFJeXfQLGuQmKiP7dzkupKvadQYx8IA)cJ4R5E)gjcjKg4TKgFj4P)zNVxjGGu4c1TRxHslIi5VwsqvICjAsvJrLYrxYuO(V5frDwd2lm5lEfj)13Jwi2FYu(IxeeL2z5iJI3AC0LmfQ)BEruN1G9cJJFjrs6F257vC0LmfQ)BEruN1G9cJVeclkrx9tMijrs3QXOs5Olzku)38IOoRb7fM8fVIK)67rleLk7LXaVL04lbp9p789kbeKc31cb5pKDCjAst)ZoFVIFfmMT(V5B7lu(siSOequQmg4TKgFj4P)zNVxjGGu4kS0gTifgZFzj1LOj1sAGL8urics0LumLJClGbv9lHWIsaXolrs3O4TghDjtH6)Mxe1znyVW44xYr(IuomOpoJVeclkbeHLosKSwC8ewQuUDocojRqOc5RfhpHLkLBNJGVeclkbe7S81IJNWsLYTZrWJQRls5WG(4m(siSOeiH0aVL04lbp9p789kbeKc3dzkuVvh)HsMBUenPwsdSKNkcrqIUKHejlErTFHr8lOKTpIViXa)apgzaU6XsLv6aCFObl0Ged8wsJVe80JLkRuH0dzkuH)GtUenPi3TAmQu(JYcLwtJVKirngvk)rzHsRPXxYTKgyjpveIGeDjft5P)zNVxXVcgZw)38T9fkFjewucjsSKgyjpveIGesVHKCKXAByOmIlu)fZQkkysKG12Wqze3ohHFjewuinWBjn(sWtpwQSsfqqkCf9SfruW8icH6s0KU4vK8xFpA5hQfPq76wNLN(ND(Ef)kymB9FZ32xO8LqyrjGyNL3TAmQuo6sMc1)nViQZAWEHjhRTHHYiUq9xmRQOGnWBjn(sWtpwQSsfqqkCf9SfruW8icH6s0K2TAmQuo6sMc1)nViQZAWEHjhRTHHYiUDoc)siSOg4TKgFj4PhlvwPciifUIE2IikyEeHqDjAsvJrLYrxYuO(V5frDwd2lm5iJI3AC0LmfQ)BEruN1G9cJJFjhzS2ggkJ4c1FXSQIcM8fVIK)67rl)qTifAx9tMsKG12Wqze3ohHFjewuYx8ks(RVhT8d1IuOD1FYuIeS2ggkJ425i8lHWIs(AXXtyPs525i4lHWIsaX(N81IJNWsLYTZrWjzfcvGKejDJI3AC0LmfQ)BEruN1G9cJJFjp9p789ko6sMc1)nViQZAWEHXxcHfLaPbElPXxcE6XsLvQacsHRH(iIY04lplqG6s0KM(ND(Ef)kymB9FZ32xO8LqyrjGiS0X1WuowBddLrCH6VywvrbtoYQXOs5Olzku)38IOoRb7fM8fVIK)67rBx9NmKN(ND(EfhDjtH6)Mxe1znyVW4lHWIsarmLiPB1yuPC0LmfQ)BEruN1G9cdPbElPXxcE6XsLvQacsHRH(iIY04lplqG6s0KI12Wqze3ohHFjewud8wsJVe80JLkRubeKcxbulbjJ8kuYJx9(vH6MlrtkwBddLrCH6VywvrbtoYP)zNVxXVcgZw)38T9fkFjewuci2zjsuJrLYJeLSlKg4TKgFj4PhlvwPciifUcOwcsg5vOKhV69Rc1nxIMuS2ggkJ425i8lHWIAG3sA8LGNESuzLkGGu42yKaAATM6s0K2nkERXVcgZw)38T9fkh)soYIhNHg1HFHluCg5Pf)sJVKir84m0OoCSpZ0GrEXZWsLkVBu8wJJ9zMgmYlEgwQuo(fsUeLs7IFP(abc6eMssV5sukTl(L6HXEuJj9MlrP0U4xQpAsfpodnQdh7ZmnyKx8mSuPd8d8yKbGXGYcLwtJVgW(QPXxd8wsJVe8hLfkTMgFjDje)kigje(ErP06s0KAjnWsEQiebj6sANLJ12WqzeF75rXBnXaVL04lb)rzHsRPXxqqkCB7luVq3asYLOjTBu8wJdzWyrbZJWsqJI44xYrEXlcIykrIAmQuEKCZRg7lHCu8wJhj38QX(sWxcHfLaIWshxdtjssFDWdLJxmYeqPJVTu5EUjhzu8wJJxmYeqPJVTu5EUXxcHfLaIWshxdtjsqXBnoEXitaLo(2sL75gxOwcsi2zKqAG3sA8LG)OSqP104liifUq)ESOG5rzMqDjAs7gfV14qgmwuW8iSe0Oio(L8fVOUK2z5iJI3A8nqq8LqyrjGyNLJI3A8nqqC8ljsSKgyj)5vEBFH6BewAHOL0al5PIqeKaPbElPXxc(JYcLwtJVGGu4cJzPWyE7G1Qe5s0K2nkERXHmySOG5ryjOrrC8l5IlIX8QTWivWHXSuymVDWAvI6skMsK0nkERXHmySOG5ryjOrrC8l5iFiu8wJVM79BKiUqTeKqugsKCiu8wJVM79BKi(siSOeqew64A9dPbElPXxc(JYcLwtJVGGu422xOIKBkuYLOjffV14qgmwuW8iSe0Oi(swsLlUigZR2cJubVTVqfj3uOuxykVBS2ggkJ4hYuOc)bN8wsdS0aVL04lb)rzHsRPXxqqkCFuwO0Ak5sYTeJ8QTWivi9MlrtkkERXHmySOG5ryjOrr8LSKoWBjn(sWFuwO0AA8feKc32(c1l0nGKCjAsTKgyjpveIGesVjhRTHHYiEBFH6f6gqs(0xh8qfd8wsJVe8hLfkTMgFbbPWf63JffmpkZeQlrtkwBddLr891wYVbcsU4IymVAlmsfCOFpwuW8OmtODjfZbElPXxc(JYcLwtJVGGu4cJzPWyE7G1Qe5s0KkUigZR2cJubhgZsHX82bRvjQlPyoWBjn(sWFuwO0AA8feKc32(c1l0nGKCj5wIrE1wyKkKEZLOjTB1yuPCdRXSkbLK3nkERXHmySOG5ryjOrrC8ljsuJrLYnSgZQeusE3yTnmugX3xBj)giijsWAByOmIVV2s(nqqYx8I4AGG867XSlPWsNbElPXxc(JYcLwtJVGGu4c97XIcMhLzc1LOjfRTHHYi((Al53abnWBjn(sWFuwO0AA8feKc3hLfkTMsUKClXiVAlmsfsVnWpWJrgag))SOGnam2FhagdkluAnn(YDdWrTvfd4MmhGGsFDedaLA)sdaJpymBhW3gag7(cDaPhbjgW3AdWvUEg4TKgFj4pkluAnn(YF9plkysxcXVcIrcHVxukTUenPyTnmugX3EEu8wtirIL0al5PIqeKOlPyoWBjn(sWFuwO0AA8L)6FwuWGGu4cJzPWyE7G1Qe5s0KkUigZR2cJubhgZsHX82bRvjQlPykxngvkVTVqfj3uO0aVL04lb)rzHsRPXx(R)zrbdcsHBBFHksUPqjxIMuu8wJdzWyrbZJWsqJI4lzjvUL0al5PIqeKOlmL3nwBddLr8dzkuH)GtElPbwAG3sA8LG)OSqP104l)1)SOGbbPW9rzHsRPKlj3smYR2cJuH0BUenPO4TghYGXIcMhHLGgfXxYs6aVL04lb)rzHsRPXx(R)zrbdcsHBBFH6f6gqsUenPwsdSKNkcrqcP3KJ12WqzeVTVq9cDdijF6RdEOIbElPXxc(JYcLwtJV8x)ZIcgeKc3hLfkTMsUKClXiVAlmsfsV5s0KII3ACidglkyEewcAueFjlPd8wsJVe8hLfkTMgF5V(NffmiifUq)ESOG5rzMqDjAsXAByOmIVV2s(nqqd8wsJVe8hLfkTMgF5V(NffmiifUWywkmM3oyTkrUenPIlIX8QTWivWHXSuymVDWAvI6skMYx8ks(RVhT8d1IuOqS)K5aVL04lb)rzHsRPXx(R)zrbdcsHBBFH6f6gqsUKClXiVAlmsfsV5s0KU4vK8xFpA5hQfPqHOSxMd8wsJVe8hLfkTMgF5V(NffmiifUpkluAnLCj5wIrE1wyKkKEZLOjDXlQlPDwoYDJWIYd1QdhtOsKKESuzLYlkTp73JejPhlvwPCiDBdRqsIKfVOUK2p5iSO8qT6WXe6aVL04lb)rzHsRPXx(R)zrbdcsHBBFHksUPqjxIMulPbwYtfHiirxs7N8UXAByOmIFitHk8hCYBjnWsd8d8yKb4(TuySb4(qdwObjg4TKgFj4RLcJjKIY()4B4RBUenPO4Tg)kymB9FZ32xOC8RbElPXxc(APWyciifUO0kOfYOG5s0KII3A8RGXS1)nFBFHYXVg4TKgFj4RLcJjGGu4ABYkYFHZeKlrtkYDJI3A8RGXS1)nFBFHYXVKBjnWsEQiebj6skMijrs3O4Tg)kymB9FZ32xOC8l5iV4fXpulsH2LuziFXRi5V(E0YpulsH2L0(tMinWBjn(sWxlfgtabPWLfWGQcVR34hyiOsDjAsrXBn(vWy26)MVTVq54xd8wsJVe81sHXeqqkCTkrcDnMpzmMlrtkkERXVcgZw)38T9fkh)sokERXjexFpA9lEr(EKD9fh)AG3sA8LGVwkmMacsHBlwcL9)XLOjffV14xbJzR)B(2(cLVeclkbeLIrLJI3A8RGXS1)nFBFHYXVKJI3ACcX13Jw)IxKVhzxFXXVg4TKgFj4RLcJjGGu4IAW8FZRBKGu4s0KII3A8RGXS1)nFBFHYXVKBjnWsEQiebjKEtoYO4Tg)kymB9FZ32xO8LqyrjGOmKRgJkLNE2XdLSv5uzOm6irs3QXOs5PND8qjBvovgkJoYrXBn(vWy26)MVTVq5lHWIsaXoJ0a)apgzaoQvhBpdqefmgjBR2cJ0bSVAA81aVL04lbxOwDS9iDje)kigje(ErP06s0KI12WqzeF75rXBnXaVL04lbxOwDS9abPW9rzHsRPKlrtkkERXHmySOG5ryjOrr8LSKoWBjn(sWfQvhBpqqkCH(9yrbZJYmH6s0KI12WqzeFFTL8BGGKJI3A8nqq8LqyrjGyNh4TKgFj4c1QJThiifUT9fQxOBaj5s0KI12WqzeVTVq9cDdijF6RdEOIbElPXxcUqT6y7bcsHlmMLcJ5TdwRsKlrtA3hYuOEiRaguLV4f1(fgXxZ9(nsKCKpekERXxZ9(nsexOwcsikdjsoekERXxZ9(nseFjewuciclDCT(H0aVL04lbxOwDS9abPWTTVq9cDdijxIM00)SZ3R4lH4xbXiHW3lkLw(siSOequkMUgS0rUAmQuomtHsBuW8c9xed8wsJVeCHA1X2deKcxOFpwuW8OmtOUenPyTnmugX3xBj)giObElPXxcUqT6y7bcsHBBFH6f6gqsUenPlEfj)13Jw(HArkuiI8nzab1yuP8fVIK3uLkCtJVCnzG0aVL04lbxOwDS9abPW9rzHsRPKlrtA3O4TgVTV7rL)cNjio(LC1yuP82(Uhv(lCMGKibRTHHYi(HmfQWFWjVL0aljhfV14hYuOc)bN4c1sqcX(jrYIxuxs7NCbPE0VWfCnOftmQVFxjjsqgHfLhQvhoMqLiP70JLkRuEfWGQ(MrsK0TGup6x4cUg0Ijg13VResYvJrLYHzkuAJcMxO)IqokERXxcXVcIrcHVxukTC8ljs6wqQh9lCbxdAXeJ673vs(IxrYF99OLFOwKcTlKXugqqngvkFXRi5nvPc304lxtginWBjn(sWfQvhBpqqkCB7luVq3asAG3sA8LGluRo2EGGu4c93Y)nFVOuAh4TKgFj4c1QJThiifU2MSI86Vlv6a)apgza9TrbjPIbElPXxcUUrbjPcP4cYhkHWLYqqsJsKwC1qzKx2GBLIJWFiSrICjAs7wngvkhDjtH6)Mxe1znyVWKJI3A8RGXS1)nFBFHYXVKJI3ACcX13Jw)IxKVhzxFXXVKirngvkhDjtH6)Mxe1znyVWKJmYO4Tg)kymB9FZ32xOC8l5P)zNVxXrxYuO(V5frDwd2lm(s2XnKKibzu8wJFfmMT(V5B7luo(LCKrUfWGQ(LqyrjKTt)ZoFVIJUKPq9FZlI6SgSxy8LqyrjqcIyEdjKqsIe0xiK3cyqv)siSOeqeZBsKCitH6HScyqv(jegkJ8HS54jzrjCLKkt5QTWiLRbcYRV)kPEmLjeLXaVL04lbx3OGKubeKcxCb5dLq4sziiPWmSeZ)nVcL8TyfQ3w0qPDG3sA8LGRBuqsQacsHlUG8HsiCPmeKurYwH)B(2AkTLX8cDJgnWBjn(sW1nkijvabPWfxq(qjeUugcsQcL8TyfQxeWcMlrtkkERXVcgZw)38T9fkh)sokERXjexFpA9lEr(EKD9fh)AGhJmG(Gsdq3OGK0b0luOdqHsdaAadkj0bqcnqykDgawJHtUmGEbJnauAa4c6mGwScDawDgWLflDgqVqHoam(GXSDaFBayS7lu(aVL04lbx3OGKubeKcxDJcssV5s0K2nwBddLrCXfLIwqhVUrbjPYrXBn(vWy26)MVTVq54xYrUB1yuP8irj7sIe1yuP8irj7sokERXVcgZw)38T9fkFjewuIUKEtMijh5U1nkijLJjhQj8P)zNVxjrIUrbjPCm5P)zNVxXxcHfLqIeS2ggkJ46gfKK6V243qDt6nKKir3OGKu(nokER5p4RPXxDjTfWGQ(Lqyrjg4TKgFj46gfKKkGGu4QBuqskMUenPDJ12WqzexCrPOf0XRBuqsQCu8wJFfmMT(V5B7luo(LCK7wngvkpsuYUKirngvkpsuYUKJI3A8RGXS1)nFBFHYxcHfLOlP3KjsYrUBDJcss534qnHp9p789kjs0nkijLFJN(ND(EfFjewucjsWAByOmIRBuqsQ)AJFd1nPyIKej6gfKKYXKJI3A(d(AA8vxsBbmOQFjewuIbEmYaCDTb8fZTb8fnGVgaUGgGUrbjPd4AFSXHedWgakER5YaWf0auO0aEfkTd4RbK(ND(EfFaym7aI2akkuO0oaDJcsshW1(yJdjgGnau8wZLbGlObG(k0b81as)ZoFVIpWBjn(sW1nkijvabPWfxq(qjeUiyVkv3OGK0BUenPDJ12WqzexCrPOf0XRBuqsQCK7w3OGKu(nout4XfKhfV1KJSUrbjPCm5P)zNVxXxcHfLqIKU1nkijLJjhQj84cYJI3Aijrs6F257v8RGXS1)nFBFHYxcHfLOlmLjsd8wsJVeCDJcssfqqkCXfKpucHlc2Rs1nkijftxIM0UXAByOmIlUOu0c641nkijvoYDRBuqskhtout4XfKhfV1KJSUrbjP8B80)SZ3R4lHWIsirs36gfKKYVXHAcpUG8O4TgssKK(ND(Ef)kymB9FZ32xO8Lqyrj6ctzIuwZAod]] )


end
