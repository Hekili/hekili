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


    spec:RegisterPack( "Frost DK", 20220428, [[d4K3ydqiPsEKkv0LikL2er1NuPmkiQtbfwfvs1RKQQzrL4weLQSlu9lqLggrjhdewgu0ZKkQPPsLUgrHTPsf(grPY4GiX5KksToPcMNkvDpI0(KQYbPskwiOIhsLKjsuQkxeIuAJqKIpcrsmsIsv1jPskTsqvVeIKuZuQq7Kkv)eIKAOeLclvQi5PuXuLk1vHijXxjkfnwiI9kQ)svdg4WuwmKESitwfxgzZs5ZGYObPtlSAiss61GOzJYTHWUL8BvnCvYXHivlxPNty6KUouTDO03LQmEIIopvkRxQiMprSFfNHi3D25ykLDhtzHjMY6UyIu4q0PLLmWm7OUDrzNllbPbJYoLHGYoin7l0bi7dP6SZL5g7TtU7SJ4X3eLDGQ6LOdWfUWcfkokp9iGRiqGZmn(kTwtHRiqKGB2bfpyQRTYOzNJPu2DmLfMykR7IjsHdrNww39UiLSJHRq)n74eiCv2bACouLrZohsKYoY(itHoaKQRaguDain7l0bExZ1gSbGPSZLbGPSWeZb(bExb1kyKyGx2BaDkcXJLodGzcv2tqPVodaxyWOb8Tb4kOwuIb8Tb4At0amXacDaNNe1nDaxmZTb0JySbe1aUwlPrI4d8YEdq23x30bKGAvrSbG0Wib00AnDah8nkydaolzk0b8Tb4e1znyVW4zhwiurU7SZJYcLwtJV8x)ZIcwU7S7qK7o7qLHYOtgozhlPXxzNLq8RGyKq47fLsB25qI0gxA8v2r24FwuWgasZVdaPgLfkTMgF1Hb4O2QIbaHSgGGsFDedaLA)sdq2iymBhW3gasZ(cDaPhbjgW3AdWvY(YoPnuAdl7G12WqzeF75rXBnXaKizawsdSKNkcrqIb0N0bGzwZUJzU7SdvgkJoz4KDsBO0gw2rCrmMxTfgPcomMLcJ5TdwRs0a6t6aWCaYhGAmQuEBFHksUPqjovgkJozhlPXxzhymlfgZBhSwLOSMDVZ5UZouzOm6KHt2jTHsByzhu8wJdzWyrbZJWsqJI4lzjDaYhGL0al5PIqeKya9namhG8b01aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCtHszn7(DZDNDOYqz0jdNSJL04RSZJYcLwtPStAdL2WYoO4TghYGXIcMhHLGgfXxYsA2j5wIrE1wyKkYUdrwZUlJC3zhQmugDYWj7K2qPnSSJL0al5PIqeKyashaedq(aWAByOmI32xOEHUbKKp91bpur2XsA8v2PTVq9cDdiPSMD)oYDNDOYqz0jdNSJL04RSZJYcLwtPStAdL2WYoO4TghYGXIcMhHLGgfXxYsA2j5wIrE1wyKkYUdrwZUl7YDNDOYqz0jdNStAdL2WYoyTnmugX3xBj)giOSJL04RSd0VhlkyEuMj0SMDhPK7o7qLHYOtgozN0gkTHLDexeJ5vBHrQGdJzPWyE7G1QenG(KoamhG8bS4vK8xFpA5hQfPqhW9d4oKv2XsA8v2bgZsHX82bRvjkRz3705UZouzOm6KHt2XsA8v2PTVq9cDdiPStAdL2WYolEfj)13Jw(HArk0bC)aKDYk7KClXiVAlmsfz3HiRz3Hqw5UZouzOm6KHt2XsA8v25rzHsRPu2jTHsByzNfVOb0N0b05biFaipGUgaclkpuRoCmHoajsgq6XsLvkVO0(SFpdqIKbKESuzLYH0TnSAaymajsgWIx0a6t6aU7aKpaewuEOwD4ycn7KClXiVAlmsfz3HiRz3HaIC3zhQmugDYWj7K2qPnSSJL0al5PIqeKya9jDa3DaYhqxdaRTHHYi(HmfQWFWjVL0alLDSKgFLDA7lurYnfkL1SMDsp74Hs2Q5UZUdrU7SdvgkJoz4KDsBO0gw2b9fIbiFaTagu1VeclkXaUFaWsNbiFaipGfVObC)aWCasKmGUgakERXHmySOG5ryjOrrC8RbiFaipGUgaclkpuRoCmHoa5dafV14PND8qjBvUqTeKdOpPd4UdO)bS4f1(fgXH8zASMW3mS)YPYqz0zasKmaewuEOwD4ycDaYhakERXtp74Hs2QCHAjihqFdaPmG(hWIxu7xyehYNPXAcFZW(lNkdLrNbGXaKizaO4TghYGXIcMhHLGgfXXVgG8bG8a6AaiSO8qT6WXe6aKpau8wJNE2XdLSv5c1sqoG(gasza9pGfVO2VWioKptJ1e(MH9xovgkJodqIKbGWIYd1QdhtOdq(aqXBnE6zhpuYwLlulb5a6BaqiRb0)aw8IA)cJ4q(mnwt4Bg2F5uzOm6mamgagzhlPXxzNeulkH)B(irzn7oM5UZouzOm6KHt2XsA8v2jb1Is4)Mpsu25qI0gxA8v2bPkcAah8nkydq2iymBhqVqHoaxBIs2fCHZsMcn7K2qPnSStxdqngvk)rzHsRPXxCQmugDgG8bGI3A8RGXS1)nFBFHYXVgG8bGI3A80ZoEOKTkxOwcYb0N0baHSgG8bG8aqXBn(vWy26)MVTVq5lHWIsmG7haS0zaU(aqEaqmG(hq6F257v82(cTNBlcHVHVUXxYoUnamgGejdafV144f0N5MxOlvWuO8LqyrjgW9daw6majsgakERXtqTx4rTI4lHWIsmG7haS0zayK1S7Do3D2HkdLrNmCYowsJVYojOwuc)38rIYohsK24sJVYoi14Qio0a(2aKncgZ2bGlidgnGEHcDaU2eLSl4cNLmfA2jTHsByzNUgGAmQu(JYcLwtJV4uzOm6ma5d4qMc1dzfWGQ8fVO2VWiEZymQ8PfxyhAhG8b01aqXBn(vWy26)MVTVq54xdq(as)ZoFVIFfmMT(V5B7lu(siSOedOVbaHmgG8bG8aqXBnE6zhpuYwLlulb5a6t6aGqwdq(aqEaO4TghVG(m38cDPcMcLJFnajsgakERXtqTx4rTI44xdaJbirYaqXBnE6zhpuYwLlulb5a6t6aGOZdaJSMD)U5UZouzOm6KHt2jTHsByzNUgGAmQu(JYcLwtJV4uzOm6ma5dORbCitH6HScyqv(Ixu7xyeVzmgv(0IlSdTdq(aqXBnE6zhpuYwLlulb5a6t6aGqwdq(a6AaO4Tg)kymB9FZ32xOC8RbiFaP)zNVxXVcgZw)38T9fkFjewuIb03aWuwzhlPXxzNeulkH)B(irzn7UmYDNDOYqz0jdNSJL04RStcQfLW)nFKOSZHePnU04RSJSXsyPshGRE2zaY(jB1b8yPnzxxrbBah8nkyd4kymBZoPnuAdl7OgJkL)OSqP104lovgkJodq(a6AaO4Tg)kymB9FZ32xOC8RbiFaipau8wJNE2XdLSv5c1sqoG(KoaiU7aKpaKhakERXXlOpZnVqxQGPq54xdqIKbGI3A8eu7fEuRio(1aWyasKmau8wJNE2XdLSv5c1sqoG(Koai60dqIKbK(ND(Ef)kymB9FZ32xO8LqyrjgW9dOZdq(aqXBnE6zhpuYwLlulb5a6t6aG4UdaJSM1SZJYcLwtJVYDNDhIC3zhQmugDYWj7yjn(k7SeIFfeJecFVOuAZohsK24sJVYoi1OSqP104RbSVAA8v2jTHsByzhlPbwYtfHiiXa6t6a68aKpaS2ggkJ4BppkERjYA2DmZDNDOYqz0jdNStAdL2WYoDnau8wJdzWyrbZJWsqJI44xdq(aqEalErd4(bG5aKizaQXOs5rYnVASVeCQmugDgG8bGI3A8i5Mxn2xc(siSOed4(balDgGRpamhGejdi91bpuoEXitaLo(2svN4gNkdLrNbiFaipau8wJJxmYeqPJVTu1jUXxcHfLya3payPZaC9bG5aKizaO4TghVyKjGshFBPQtCJlulb5aUFaDEaymamYowsJVYoT9fQxOBajL1S7Do3D2HkdLrNmCYoPnuAdl701aqXBnoKbJffmpclbnkIJFna5dyXlAa9jDaDEaYhaYdafV14BGG4lHWIsmG7hqNhG8bGI3A8nqqC8RbirYaSKgyj)5vEBFH6BewAhW9dWsAGL8uricsmamYowsJVYoq)ESOG5rzMqZA297M7o7qLHYOtgozN0gkTHLD6AaO4TghYGXIcMhHLGgfXXVgG8biUigZR2cJubhgZsHX82bRvjAa9jDayoajsgqxdafV14qgmwuW8iSe0Oio(1aKpaKhWHqXBn(ADYVrI4c1sqoG7hGmgGejd4qO4TgFTo53ir8LqyrjgW9daw6maxFa3DayKDSKgFLDGXSuymVDWAvIYA2DzK7o7qLHYOtgozN0gkTHLDqXBnoKbJffmpclbnkIVKL0biFaIlIX8QTWivWB7lurYnfknG(gaMdq(a6AayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUPqPSMD)oYDNDOYqz0jdNSJL04RSZJYcLwtPStAdL2WYoO4TghYGXIcMhHLGgfXxYsA2j5wIrE1wyKkYUdrwZUl7YDNDOYqz0jdNStAdL2WYowsdSKNkcrqIbiDaqma5daRTHHYiEBFH6f6gqs(0xh8qfzhlPXxzN2(c1l0nGKYA2DKsU7SdvgkJoz4KDsBO0gw2bRTHHYi((Al53abna5dqCrmMxTfgPco0VhlkyEuMj0b0N0bGz2XsA8v2b63JffmpkZeAwZU3PZDNDOYqz0jdNStAdL2WYoIlIX8QTWivWHXSuymVDWAvIgqFshaMzhlPXxzhymlfgZBhSwLOSMDhczL7o7qLHYOtgozhlPXxzN2(c1l0nGKYoPnuAdl701auJrLYnSgZQeuItLHYOZaKpGUgakERXHmySOG5ryjOrrC8RbirYauJrLYnSgZQeuItLHYOZaKpGUgawBddLr891wYVbcAasKmaS2ggkJ47RTKFde0aKpGfViUgiiV(EmhqFshaS0j7KClXiVAlmsfz3HiRz3HaIC3zhQmugDYWj7K2qPnSSdwBddLr891wYVbck7yjn(k7a97XIcMhLzcnRz3HaZC3zhQmugDYWj7yjn(k78OSqP1uk7KClXiVAlmsfz3HiRzn7iuRo2EYDNDhIC3zhQmugDYWj7yjn(k7SeIFfeJecFVOuAZohsK24sJVYooQvhBpdqefmgj7P2cJ0bSVAA8v2jTHsByzhS2ggkJ4BppkERjYA2DmZDNDOYqz0jdNStAdL2WYoO4TghYGXIcMhHLGgfXxYsA2XsA8v25rzHsRPuwZU35C3zhQmugDYWj7K2qPnSSdwBddLr891wYVbcAaYhakERX3abXxcHfLya3pGoNDSKgFLDG(9yrbZJYmHM1S73n3D2HkdLrNmCYoPnuAdl7G12WqzeVTVq9cDdijF6RdEOISJL04RStBFH6f6gqszn7UmYDNDOYqz0jdNStAdL2WYoDnGdzkupKvadQYx8IA)cJ4R1j)gjAaYhaYd4qO4TgFTo53irCHAjihW9dqgdqIKbCiu8wJVwN8BKi(siSOed4(balDgGRpG7oamYowsJVYoWywkmM3oyTkrzn7(DK7o7qLHYOtgozN0gkTHLDs)ZoFVIVeIFfeJecFVOuA5lHWIsmG7LoamhGRpayPZaKpa1yuPCyMcL2OG5f6Vi4uzOm6KDSKgFLDA7luVq3askRz3LD5UZouzOm6KHt2jTHsByzhS2ggkJ47RTKFdeu2XsA8v2b63JffmpkZeAwZUJuYDNDOYqz0jdNStAdL2WYolEfj)13Jw(HArk0bC)aqEaqiJb0)auJrLYx8ksEtvQWnn(ItLHYOZaC9biJbGr2XsA8v2PTVq9cDdiPSMDVtN7o7qLHYOtgozN0gkTHLD6AaO4TgVTFNqL)cNjio(1aKpa1yuP82(Dcv(lCMG4uzOm6majsgawBddLr8dzkuH)GtElPbwAaYhakERXpKPqf(doXfQLGCa3pG7oajsgWIx0a6t6aU7aKpabPE0VWfCnOftKI)UxPbirYaqEaiSO8qT6WXe6aKizaDnG0JLkRuEfWGQ(MrdqIKb01aeK6r)cxW1Gwmrk(7ELgagdq(auJrLYHzkuAJcMxO)IGtLHYOZaKpau8wJVeIFfeJecFVOuA54xdqIKb01aeK6r)cxW1Gwmrk(7ELgG8bS4vK8xFpA5hQfPqhqFda5bGPmgq)dqngvkFXRi5nvPc304lovgkJodW1hGmgagzhlPXxzNhLfkTMszn7oeYk3D2XsA8v2PTVq9cDdiPSdvgkJoz4K1S7qarU7SJL04RSd0Fl)389IsPn7qLHYOtgozn7oeyM7o7yjn(k7yBYkYR)UuPzhQmugDYWjRzn7G(cVgjiJcwU7S7qK7o7qLHYOtgozhlPXxzNhLfkTMszNKBjg5vBHrQi7oezN0gkTHLDw8ks(RVhTd4EPda5bCxzmG(hGAmQu(IxrYBQsfUPXxCQmugDgGRpazmamYohsK24sJVYoWzjtHoGVnaNOoRb7f2aCnjnWsdOt9QPXxzn7oM5UZouzOm6KHt2jTHsByzhS2ggkJ4BppkERjgGejdWsAGL8uricsmG(KoamhGejdyXRi5V(E0oG7hqNXCaYhWIxexdeKxFpMd4(bS4vK8xFpAhaChae3r2XsA8v2zje)kigje(ErP0M1S7Do3D2HkdLrNmCYoPnuAdl7S4vK8xFpAhW9dOZyoa5dyXlIRbcYRVhZbC)aw8ks(RVhTdaUdaI7i7yjn(k7CitH6T64puYClRz3VBU7SdvgkJoz4KDsBO0gw2bRTHHYi((Al53abna5da5bS4vK8xFpAhqFshWDLXaKizalErCnqqE99DEa3lDaWsNbirYaw8IA)cJ4RbJ8FZRqjFB)oHkFcQH4k(ItLHYOZaKizaIlIX8QTWivWH(9yrbZJYmHoG(KoamhGejdafV14BGG4lHWIsmG7hqNhagdqIKbS4vK8xFpAhW9dOZyoa5dyXlIRbcYRVhZbC)aw8ks(RVhTdaUdaI7i7yjn(k7a97XIcMhLzcnRz3LrU7SdvgkJoz4KDsBO0gw2bfV14qgmwuW8iSe0Oio(1aKpaXfXyE1wyKk4T9fQi5McLgqFdaZbiFaDnaS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfj3uOuwZUFh5UZouzOm6KHt2XsA8v25rzHsRPu2jTHsByzhu8wJdzWyrbZJWsqJI4lzjn7KClXiVAlmsfz3HiRz3LD5UZouzOm6KHt2jTHsByzNfVIK)67r7aUx6aUdzna5dyXlIRbcYRVVZdOVbalDYowsJVYoq)T8FZ3lkL2SMDhPK7o7qLHYOtgozN0gkTHLDexeJ5vBHrQG32xOIKBkuAa9namhG8b01aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCtHszn7ENo3D2HkdLrNmCYowsJVYopkluAnLYoPnuAdl7S4vK8xFpA5hQfPqhqFdatzmajsgWIxexdeKxFFNhW9daw6KDsULyKxTfgPIS7qK1S7qiRC3zhQmugDYWj7K2qPnSSdwBddLr891wYVbck7yjn(k7a97XIcMhLzcnRz3HaIC3zhQmugDYWj7K2qPnSSZIxrYF99ODa3paziRSJL04RSJTjRiV(7sLM1SMDspwQSsf5UZUdrU7SdvgkJoz4KDSKgFLDoKPqf(doLDoKiTXLgFLDC1JLkR0b4AqdwObjYoPnuAdl7G8a6AaQXOs5pkluAnn(ItLHYOZaKizaQXOs5pkluAnn(ItLHYOZaKpalPbwYtfHiiXa6t6aWCaYhq6F257v8RGXS1)nFBFHYxcHfLyasKmalPbwYtfHiiXaKoaigagdq(aqEayTnmugXfQ)IzvffSbirYaWAByOmIBNJWVeclQbGrwZUJzU7SdvgkJoz4KDsBO0gw2zXRi5V(E0YpulsHoG(gaeDEaYhq6F257v8RGXS1)nFBFHYxcHfLya3pGopa5dORbOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG12WqzexO(lMvvuWYowsJVYoIE2IikyEeHqZA29oN7o7qLHYOtgozN0gkTHLD6AaQXOs5Olzku)38IOoRb7fgNkdLrNbiFayTnmugXTZr4xcHfv2XsA8v2r0ZwerbZJieAwZUF3C3zhQmugDYWj7K2qPnSSJAmQuo6sMc1)nViQZAWEHXPYqz0zaYhaYdafV14Olzku)38IOoRb7fgh)AaYhaYdaRTHHYiUq9xmRQOGna5dyXRi5V(E0YpulsHoG(gWDL1aKizayTnmugXTZr4xcHf1aKpGfVIK)67rl)qTif6a6Ba3HSgGejdaRTHHYiUDoc)siSOgG8bSwC8ewQuUDoc(siSOed4(b0PhG8bSwC8ewQuUDocojZqOIbGXaKizaDnau8wJJUKPq9FZlI6SgSxyC8RbiFaP)zNVxXrxYuO(V5frDwd2lm(siSOedaJSJL04RSJONTiIcMhri0SMDxg5UZouzOm6KHt2jTHsByzN0)SZ3R4xbJzR)B(2(cLVeclkXaUFaWsNb46daZbiFayTnmugXfQ)IzvffSbiFaipa1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpGfVIK)67r7a6Ba3HmgG8bK(ND(EfhDjtH6)Mxe1znyVW4lHWIsmG7haMdqIKb01auJrLYrxYuO(V5frDwd2lmovgkJodaJSJL04RSJH(iIY04lplqGM1S73rU7SdvgkJoz4KDsBO0gw2bRTHHYiUDoc)siSOYowsJVYog6JiktJV8SabAwZUl7YDNDOYqz0jdNStAdL2WYoyTnmugXfQ)IzvffSbiFaipG0)SZ3R4xbJzR)B(2(cLVeclkXaUFaDEasKma1yuP8irj7ItLHYOZaWi7yjn(k7iGAjizKxHsE8Q3Vku3YA2DKsU7SdvgkJoz4KDsBO0gw2bRTHHYiUDoc)siSOYowsJVYocOwcsg5vOKhV69Rc1TSMDVtN7o7qLHYOtgozN0gkTHLD6AaO4Tg)kymB9FZ32xOC8RbiFaipaXJZqJ6WVWfkoJ80IFPXxCQmugDgGejdq84m0OoCSpZ0GrEXZWsLYPYqz0zaYhqxdafV14yFMPbJ8INHLkLJFnamYorP0U4xQpAzhXJZqJ6WX(mtdg5fpdlvA2jkL2f)s9bce0jmLYoqKDSKgFLDAmsanTwtZorP0U4xQhg7rnw2bISM1St6F257vIC3z3Hi3D2HkdLrNmCYoPnuAdl7GI3A8RGXS1)nFBFHYXVYohsK24sJVYoYgVgFLDSKgFLDUEn(kRz3Xm3D2HkdLrNmCYowsJVYoeIRVhT(fViFpYU(k7CirAJln(k74Q)zNVxjYoPnuAdl7OgJkL)OSqP104lovgkJodq(aw8IgW9d4ogG8bG8aWAByOmIlu)fZQkkydqIKbG12Wqze3ohHFjewudaJbiFaipG0)SZ3R4xbJzR)B(2(cLVeclkXaUFaYyaYhaYdi9p789kEJrcOP1AkFjewuIb03aKXaKpaXJZqJ6WVWfkoJ80IFPXxCQmugDgGejdORbiECgAuh(fUqXzKNw8ln(ItLHYOZaWyasKmau8wJFfmMT(V5B7luo(1aWyasKma0xigG8b0cyqv)siSOed4(bGPSYA29oN7o7qLHYOtgozN0gkTHLDuJrLYrxYuO(V5frDwd2lmovgkJodq(aw8IgW9dqgdq(aw8ks(RVhTd4(bG8aUdznazVbCitH6HScyqv(Ixu7xyehQBcL2WgGRpazmazVbS4f1(fgXxdXLvQxxRenAPkrCQmugDgGRpazmamgG8bG8aqXBno6sMc1)nViQZAWEHXXVgGejdOfWGQ(LqyrjgW9datznamYowsJVYoeIRVhT(fViFpYU(kRz3VBU7SdvgkJoz4KDsBO0gw2rngvkpsuYU4uzOm6KDSKgFLDiexFpA9lEr(EKD9vwZUlJC3zhQmugDYWj7K2qPnSSJAmQuo6sMc1)nViQZAWEHXPYqz0zaYhaYdaRTHHYiUq9xmRQOGnajsgawBddLrC7Ce(LqyrnamgG8bG8as)ZoFVIJUKPq9FZlI6SgSxy8LqyrjgGejdi9p789ko6sMc1)nViQZAWEHXxYoUna5dyXRi5V(E0oG(gWDiJbGr2XsA8v25kymB9FZ32xOzn7(DK7o7qLHYOtgozN0gkTHLDuJrLYJeLSlovgkJodq(a6AaO4Tg)kymB9FZ32xOC8RSJL04RSZvWy26)MVTVqZA2DzxU7SdvgkJoz4KDsBO0gw2rngvk)rzHsRPXxCQmugDgG8bG8aw8ks(RVhTdOpPdOZYyaYhqxdafV14g6JiktJV8Sabkh)AasKmau8wJBOpIOmn(YZceOC8RbirYaw8IA)cJ4RbJ8FZRqjFB)oHkFcQH4k(ItLHYOZaWyaYhaYdaRTHHYiUq9xmRQOGnajsgawBddLrC7Ce(LqyrnamgG8bG8auJrLYHzkuAJcMxO)IGtLHYOZaKpau8wJVeIFfeJecFVOuA54xdqIKb01auJrLYHzkuAJcMxO)IGtLHYOZaWi7yjn(k7CfmMT(V5B7l0SMDhPK7o7qLHYOtgozN0gkTHLDqXBn(vWy26)MVTVq54xzhlPXxzh0LmfQ)BEruN1G9clRz3705UZouzOm6KHt2jTHsByzhlPbwYtfHiiXaKoaigG8bGI3A8RGXS1)nFBFHYxcHfLya3payPZaKpau8wJFfmMT(V5B7luo(1aKpGUgGAmQu(JYcLwtJV4uzOm6ma5da5b01awloEclvk3ohbNKziuXaKizaRfhpHLkLBNJGh1a6BaDwwdaJbirYaAbmOQFjewuIbC)a6C2XsA8v2PTVq752Iq4B4RBzn7oeYk3D2HkdLrNmCYoPnuAdl7yjnWsEQiebjgqFshaMdq(aqEaO4Tg)kymB9FZ32xOC8RbirYawloEclvk3ohbNKziuXaKpG1IJNWsLYTZrWJAa9nG0)SZ3R4xbJzR)B(2(cLVeclkXa6FaYUbGXaKpaKhakERXVcgZw)38T9fkFjewuIbC)aGLodqIKbSwC8ewQuUDocojZqOIbiFaRfhpHLkLBNJGVeclkXaUFaWsNbGr2XsA8v2PTVq752Iq4B4RBzn7oeqK7o7qLHYOtgozN0gkTHLDuJrLYFuwO0AA8fNkdLrNbiFaipau8wJFfmMT(V5B7luo(1aKpGUgaclkpuRoCmHoajsgqxdafV14xbJzR)B(2(cLJFna5daHfLhQvhoMqhG8bK(ND(Ef)kymB9FZ32xO8Lqyrjgagdq(aqEaipau8wJFfmMT(V5B7lu(siSOed4(balDgGejdafV144f0N5MxOlvWuOC8RbiFaO4TghVG(m38cDPcMcLVeclkXaUFaWsNbGXaKpaKhWHqXBn(ADYVrI4c1sqoaPdqgdqIKb01aoKPq9qwbmOkFXlQ9lmIVwN8BKObGXaWi7yjn(k702xO9CBri8n81TSMDhcmZDNDOYqz0jdNStAdL2WYoQXOs5Olzku)38IOoRb7fgNkdLrNbiFalEfj)13J2bC)aUdzna5dyXlAa3lDaDEaYhaYdafV14Olzku)38IOoRb7fgh)AasKmG0)SZ3R4Olzku)38IOoRb7fgFjewuIb03aURSgagdqIKb01auJrLYrxYuO(V5frDwd2lmovgkJodq(aw8ks(RVhTd4EPdq2jJSJL04RSdu3UEfkTiIK)AjbvjkRz3HOZ5UZouzOm6KHt2jTHsByzN0)SZ3R4xbJzR)B(2(cLVeclkXaUx6aKr2XsA8v2zTqq(dzNSMDhI7M7o7qLHYOtgozN0gkTHLDSKgyjpveIGedOpPdaZbiFaipGwadQ6xcHfLya3pGopajsgqxdafV14Olzku)38IOoRb7fgh)AaYhaYd4IuomOpoJVeclkXaUFaWsNbirYawloEclvk3ohbNKziuXaKpG1IJNWsLYTZrWxcHfLya3pGopa5dyT44jSuPC7Ce8OgqFd4IuomOpoJVeclkXaWyayKDSKgFLDewAJwKcJ5VSKM1S7qiJC3zhQmugDYWj7K2qPnSSJL0al5PIqeKya9nazmajsgWIxu7xye)ckz7J4lsWPYqz0j7yjn(k7CitH6T64puYClRzn7G(c)1)SOGL7o7oe5UZouzOm6KHt2XsA8v2zje)kigje(ErP0MDoKiTXLgFLDGZsMcDaFBaorDwd2lSbC9plkydyF104Rb0HbiuBvXaGqwIbGsTFPbaN3zaHyagwlygkJYoPnuAdl7yjnWsEQiebjgqFshaMdqIKbG12WqzeF75rXBnrwZUJzU7SdvgkJoz4KDSKgFLDEuwO0AkLDsBO0gw2bfV14qgmwuW8iSe0Oi(swshG8bK(ND(Ef)kymB9FZ32xO8LqyrjgqFdOZzNKBjg5vBHrQi7oezn7ENZDNDOYqz0jdNStAdL2WYoyTnmugX3xBj)giOSJL04RSd0VhlkyEuMj0SMD)U5UZouzOm6KHt2jTHsByzhu8wJdzWyrbZJWsqJI4lzjDaYhWIxrYF99OLFOwKcDa9naKhaeYya9pa1yuP8fVIK3uLkCtJV4uzOm6maxFaYyayma5dqCrmMxTfgPcEBFHksUPqPb03aWCaYhqxdaRTHHYi(HmfQWFWjVL0alLDSKgFLDA7lurYnfkL1S7Yi3D2HkdLrNmCYoPnuAdl7S4vK8xFpA5hQfPqhqFshaYdOZYya9pa1yuP8fVIK3uLkCtJV4uzOm6maxFaYyayma5dqCrmMxTfgPcEBFHksUPqPb03aWCaYhqxdaRTHHYi(HmfQWFWjVL0alLDSKgFLDA7lurYnfkL1S73rU7SdvgkJoz4KDSKgFLDEuwO0AkLDsBO0gw2zXRi5V(E0YpulsHoG(KoamLr2j5wIrE1wyKkYUdrwZUl7YDNDOYqz0jdNStAdL2WYolEfj)13Jw(HArk0bC)aWuwdq(aexeJ5vBHrQGdJzPWyE7G1QenG(KoamhG8bK(ND(Ef)kymB9FZ32xO8LqyrjgqFdqgzhlPXxzhymlfgZBhSwLOSMDhPK7o7qLHYOtgozhlPXxzN2(c1l0nGKYoPnuAdl7S4vK8xFpA5hQfPqhW9datzna5di9p789k(vWy26)MVTVq5lHWIsmG(gGmYoj3smYR2cJur2DiYA29oDU7SdvgkJoz4KDsBO0gw2j9p789k(vWy26)MVTVq5lHWIsmG(gWIxexdeKxF)DhG8bS4vK8xFpA5hQfPqhW9d4UYAaYhG4IymVAlmsfCymlfgZBhSwLOb0N0bGz2XsA8v2bgZsHX82bRvjkRz3Hqw5UZouzOm6KHt2XsA8v2PTVq9cDdiPStAdL2WYoP)zNVxXVcgZw)38T9fkFjewuIb03aw8I4AGG867V7aKpGfVIK)67rl)qTif6aUFa3vwzNKBjg5vBHrQi7oeznRzNRLspcutZDNDhIC3zhQmugDYWj78xzhbPrl7K2qPnSSJUrbjPCfcout4XfKhfV1gG8bG8a6AaQXOs5Olzku)38IOoRb7fgNkdLrNbiFaipaDJcss5ke80)SZ3R4h8104RbiBhq6F257v8RGXS1)nFBFHYp4RPXxdq6aK1aWyasKma1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaKhq6F257vC0LmfQ)BEruN1G9cJFWxtJVgGSDa6gfKKYvi4P)zNVxXp4RPXxdq6aK1aWyasKma1yuP8irj7ItLHYOZaWi7CirAJln(k7G0I1y4MsIbydq3OGKuXas)ZoFVYLbCcSXHoda1TbCfmMTd4BdOTVqhWVdaDjtHoGVnaruN1G9c7MyaP)zNVxXhGRTnGqVjgawJHtdaQjgq9dyjewuhAhWsk(wdacxgaXe0awsX3AaYIldE2bRT(YqqzhDJcss9q4fUvPSJL04RSdwBddLrzhSgdN8etqzhzXLr2bRXWPSdezn7oM5UZouzOm6KHt25VYocsJw2XsA8v2bRTHHYOSdwB9LHGYo6gfKK6X0lCRszN0gkTHLD0nkijLRyYHAcpUG8O4T2aKpaKhqxdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5da5bOBuqskxXKN(ND(Ef)GVMgFnaz7as)ZoFVIFfmMT(V5B7lu(bFnn(AashGSgagdqIKbOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG8as)ZoFVIJUKPq9FZlI6SgSxy8d(AA81aKTdq3OGKuUIjp9p789k(bFnn(AashGSgagdqIKbOgJkLhjkzxCQmugDgagzhSgdN8etqzhzXLr2bRXWPSdezn7ENZDNDOYqz0jdNSZFLDeKgTStAdL2WYoDnaDJcss5keCOMWJlipkERna5dq3OGKuUIjhQj84cYJI3AdqIKbOBuqskxXKd1eECb5rXBTbiFaipaKhGUrbjPCftE6F257v8d(AA81aG7a0nkijLRyYrXBn)bFnn(AaymaxFaipai4Yya9paDJcss5kMCOMWJI3ACHUubtHoamgGRpaKhawBddLrCDJcss9y6fUvPbGXaWya9naKhaYdq3OGKuUcbp9p789k(bFnn(AaWDa6gfKKYvi4O4TM)GVMgFnamgGRpaKhaeCzmG(hGUrbjPCfcout4rXBnUqxQGPqhagdW1haYdaRTHHYiUUrbjPEi8c3Q0aWyayKDoKiTXLgFLDqAfAGWusmaBa6gfKKkgawJHtda1TbKEex2gfSbOqPbK(ND(E1a(2auO0a0nkij1LbCcSXHoda1TbOqPbCWxtJVgW3gGcLgakERnGqhW1(yJdj4dq2VjgGnaHUubtHoae)jAbTdq)balWsdWga0aguAhW1g)gQBdq)bi0Lkyk0bOBuqsQWLbyIb0JySbyIbydaXFIwq7aA)oGOnaBa6gfKKoGEbJnGFhqVGXgq96aeUvPb0luOdi9p789kbp7G1wFziOSJUrbjP(Rn(nu3YowsJVYoyTnmugLDWAmCYtmbLDGi7G1y4u2bZSMD)U5UZouzOm6KHt25VYocsZowsJVYoyTnmugLDWAmCk7OgJkLdZuO0gfmVq)fbNkdLrNbirYasFDWdLtyPTTVq5uzOm6majsgWIxu7xyehn0OG5tp7WPYqz0j7G1wFziOSZ2ZJI3AISMDxg5UZowsJVYongjGMwRPzhQmugDYWjRzn7ypL7o7oe5UZouzOm6KHt25qI0gxA8v2X18iTdOt9QPXxzhlPXxzNLq8RGyKq47fLsBwZUJzU7SdvgkJoz4KDsBO0gw2rngvkVTVqfj3uOeNkdLrNSJL04RSdmMLcJ5TdwRsuwZU35C3zhQmugDYWj7K2qPnSSdkERXHmySOG5ryjOrr8LSKoa5dORbG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5McLYA297M7o7qLHYOtgozN0gkTHLDWAByOmIVV2s(nqqdq(auJrLYnSgZQeuItLHYOt2XsA8v2b63JffmpkZeAwZUlJC3zhQmugDYWj7K2qPnSStxdafV14BGG44xdq(aSKgyjpveIGed4EPdOZdqIKbyjnWsEQiebjgqFdOZzhlPXxzhymlfgZBhSwLOSMD)oYDNDOYqz0jdNSJL04RStBFH6f6gqszNKBjg5vBHrQi7oezN0gkTHLDs)ZoFVIVeIFfeJecFVOuA5lHWIsmG7LoamhGRpayPZaKpa1yuPCyMcL2OG5f6Vi4uzOm6KDoKiTXLgFLDqA(fboZI0aSRR9Te0bO)aslzknaBaxcc)8d4AJFd1TbO2cJ0bWcHoG2VdWUUyUffSbSwN8BKObe1aSNYA2DzxU7SdvgkJoz4KDsBO0gw2bRTHHYi((Al53abLDSKgFLDG(9yrbZJYmHM1S7iLC3zhQmugDYWj7K2qPnSSJAmQuomtHsBuW8c9xeCQmugDgG8bGI3A8Lq8RGyKq47fLslh)AaYhGL0al5PIqeKya9namhG8b01aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCtHszn7ENo3D2HkdLrNmCYoPnuAdl7G12Wqze)qMcv4p4K3sAGLgG8bGI3A8dzkuH)GtCHAjihW9d4UdqIKbOgJkLdZuO0gfmVq)fbNkdLrNbiFaO4TgFje)kigje(ErP0YXVYowsJVYopkluAnLYA2DiKvU7SdvgkJoz4KDSKgFLDA7luVq3ask7K2qPnSSZIxrYF99OLFOwKcDa3paKhaeYya9pa1yuP8fVIK3uLkCtJV4uzOm6maxFaYyayKDsULyKxTfgPIS7qK1S7qarU7SdvgkJoz4KDsBO0gw2PRbG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5McLYA2DiWm3D2HkdLrNmCYowsJVYopkluAnLYoPnuAdl7S4vK8xFpA5hQfPqhqFda5bGPmgq)dqngvkFXRi5nvPc304lovgkJodW1hGmgagzNKBjg5vBHrQi7oezn7oeDo3D2XsA8v2bgZsHX82bRvjk7qLHYOtgozn7oe3n3D2XsA8v2PTVqfj3uOu2HkdLrNmCYA2DiKrU7SdvgkJoz4KDSKgFLDA7luVq3ask7KClXiVAlmsfz3HiRz3H4oYDNDSKgFLDG(B5)MVxukTzhQmugDYWjRz3Hq2L7o7yjn(k7yBYkYR)UuPzhQmugDYWjRzn7OBuqsQi3D2DiYDNDOYqz0jdNSZHePnU04RSt3BuqsQi7ugck7eLiT4QHYipsh3kfhH)qyJeLDsBO0gw2PRbOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bGI3A8RGXS1)nFBFHYXVgG8bGI3ACcX13Jw)IxKVhzxFXXVgGejdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5da5bG8aqXBn(vWy26)MVTVq54xdq(as)ZoFVIJUKPq9FZlI6SgSxy8LSJBdaJbirYaqEaO4Tg)kymB9FZ32xOC8RbiFaipaKhqlGbv9lHWIsmazVbK(ND(EfhDjtH6)Mxe1znyVW4lHWIsmamgW9datigagdaJbGXaKizaOVqma5dOfWGQ(LqyrjgW9datigGejd4qMc1dzfWGQ8timug5dK(XtYKs4knaPdqwdq(auBHrkxdeKxF)vs9ykRbC)aKr2XsA8v2jkrAXvdLrEKoUvkoc)HWgjkRz3Xm3D2HkdLrNmCYoLHGYoWmSeZ)nVcL8TyfQ3w0qPn7yjn(k7aZWsm)38kuY3IvOEBrdL2SMDVZ5UZouzOm6KHt2Pmeu2rKSv4)MVTMsBzmVq3OrzhlPXxzhrYwH)B(2AkTLX8cDJgL1S73n3D2HkdLrNmCYowsJVYokuY3IvOEralyzN0gkTHLDqXBn(vWy26)MVTVq54xdq(aqXBnoH467rRFXlY3JSRV44xzNYqqzhfk5BXkuViGfSSMDxg5UZouzOm6KHt2XsA8v2r3OGKuiYohsK24sJVYoDdLgGUrbjPdOxOqhGcLga0agusOdGeAGWu6maSgdNCza9cgBaO0aWf0zaTyf6aS6mGllw6mGEHcDaYgbJz7a(2aqA2xO8StAdL2WYoDnaS2ggkJ4IlkfTGoEDJcsshG8bGI3A8RGXS1)nFBFHYXVgG8bG8a6AaQXOs5rIs2fNkdLrNbirYauJrLYJeLSlovgkJodq(aqXBn(vWy26)MVTVq5lHWIsmG(KoaiK1aWyaYhaYdORbOBuqskxXKd1e(0)SZ3RgGejdq3OGKuUIjp9p789k(siSOedqIKbG12Wqzex3OGKu)1g)gQBdq6aGyaymajsgGUrbjPCfcokER5p4RPXxdOpPdOfWGQ(LqyrjYA297i3D2HkdLrNmCYoPnuAdl701aWAByOmIlUOu0c641nkijDaYhakERXVcgZw)38T9fkh)AaYhaYdORbOgJkLhjkzxCQmugDgGejdqngvkpsuYU4uzOm6ma5dafV14xbJzR)B(2(cLVeclkXa6t6aGqwdaJbiFaipGUgGUrbjPCfcout4t)ZoFVAasKmaDJcss5ke80)SZ3R4lHWIsmajsgawBddLrCDJcss9xB8BOUnaPdaZbGXaKiza6gfKKYvm5O4TM)GVMgFnG(KoGwadQ6xcHfLi7yjn(k7OBuqskMzn7USl3D2HkdLrNmCYowsJVYo6gfKKcr2rWEn7OBuqskezN0gkTHLD6AayTnmugXfxukAbD86gfKKoa5da5b01a0nkijLRqWHAcpUG8O4T2aKpaKhGUrbjPCftE6F257v8LqyrjgGejdORbOBuqskxXKd1eECb5rXBTbGXaKizaP)zNVxXVcgZw)38T9fkFjewuIb03aWuwdaJSZHePnU04RSJRTnGVyUnGVOb81aWf0a0nkijDax7JnoKya2aqXBnxgaUGgGcLgWRqPDaFnG0)SZ3R4daPEhq0gqrHcL2bOBuqs6aU2hBCiXaSbGI3AUmaCbna0xHoGVgq6F257v8SMDhPK7o7qLHYOtgozhlPXxzhDJcssXm7K2qPnSStxdaRTHHYiU4IsrlOJx3OGK0biFaipGUgGUrbjPCftout4XfKhfV1gG8bG8a0nkijLRqWt)ZoFVIVeclkXaKizaDnaDJcss5keCOMWJlipkERnamgGejdi9p789k(vWy26)MVTVq5lHWIsmG(gaMYAayKDeSxZo6gfKKIzwZA25qndNP5UZUdrU7SJL04RSdIOo(2suNqzhQmugDYWjRz3Xm3D2HkdLrNmCYo)v2rqA2XsA8v2bRTHHYOSdwJHtzhKhaH0XJRl6WJsKwC1qzKhPJBLIJWFiSrIgGejdGq64X1fD4kuY3IvOEralydaJbiFaipG0)SZ3R4rjslUAOmYJ0XTsXr4pe2ir8LSJBdqIKbK(ND(EfxHs(wSc1lcybJVeclkXaWyasKmacPJhxx0HRqjFlwH6fbSGna5dGq64X1fD4rjslUAOmYJ0XTsXr4pe2irzNdjsBCPXxzhzJLWsLoaXfLIwqNbOBuqsQyaOuuWgaUGodOxOqhGHRpctJ0ayrrISdwB9LHGYoIlkfTGoEDJcssZA29oN7o7qLHYOtgozN)k7iin7yjn(k7G12Wqzu2bRXWPSJL0al5PIqeKyashaedq(aqEaRfhpHLkLBNJGh1a6BaqiJbirYa6AaRfhpHLkLBNJGtYmeQyayKDWARVmeu2rO(lMvvuWYA297M7o7qLHYOtgozN)k7iin7yjn(k7G12Wqzu2bRXWPSJL0al5PIqeKya9jDayoa5da5b01awloEclvk3ohbNKziuXaKizaRfhpHLkLBNJGtYmeQyaYhaYdyT44jSuPC7Ce8LqyrjgqFdqgdqIKb0cyqv)siSOedOVbaHSgagdaJSdwB9LHGYo25i8lHWIkRz3LrU7SdvgkJoz4KD(RSJG0SJL04RSdwBddLrzhSgdNYoO4TgFdeeh)AaYhaYdORbS4f1(fgXxdg5)MxHs(2(Dcv(eudXv8fNkdLrNbirYaw8IA)cJ4RbJ8FZRqjFB)oHkFcQH4k(ItLHYOZaKpGfVIK)67rl)qTif6a6BaiLbGr2bRT(YqqzN91wYVbckRz3VJC3zhQmugDYWj78xzhbPzhlPXxzhS2ggkJYoyngoLDsFDWdLtRDIKPrbZJY(Edq(aqXBnoT2jsMgfmpk77XfQLGCashaMdqIKbK(6GhkhVyKjGshFBPQtCJtLHYOZaKpau8wJJxmYeqPJVTu1jUXxcHfLya3paKhaS0zaU(aWCayKDWARVmeu2PTVq9cDdijF6RdEOISMDx2L7o7qLHYOtgozN)k7iin7yjn(k7G12Wqzu2bRXWPSZHmfQ3QJ)qjZnUgjiJc2aKpG0JLkRuEfWGQ(MrzhS26ldbLDoKPqf(do5TKgyPSMDhPK7o7qLHYOtgozhlPXxzNLq8RGyKq47fLsB25qI0gxA8v2X1CDXCBain7l0bG0qyP1LbGWIsTOgGRn52a62yFjgGvNbajrxdOtri(vqmsigGSzukTdyFglkyzN0gkTHLDsFDWdLtyPTTVqhG8bOgJkLdZuO0gfmVq)fbNkdLrNbiFaipGUgGAmQu(JYcLwtJV4uzOm6ma5di9p789k(vWy26)MVTVq5lHWIsmajsgGGup6x4cUg0IjsXF3R0aKpa1yuP8hLfkTMgFXPYqz0zaYhqxdafV14xbJzR)B(2(cLJFnamYA29oDU7SdvgkJoz4KDSKgFLDG(9yrbZJYmHMDsBO0gw2PRbCEL32xO(gHLw(siSOedq(aqEaQXOs5rIs2fNkdLrNbirYa6AaO4TghDjtH6)Mxe1znyVW44xdq(auJrLYrxYuO(V5frDwd2lmovgkJodqIKbOgJkL)OSqP104lovgkJodq(as)ZoFVIFfmMT(V5B7lu(siSOedq(a6AaO4TghYGXIcMhHLGgfXXVgagzNKBjg5vBHrQi7oezn7oeYk3D2HkdLrNmCYoPnuAdl7GI3A8i5Mxn2xc(siSOed4EPdaw6maxFayoa5dqngvkpsU5vJ9LGtLHYOZaKpaXfXyE1wyKk4WywkmM3oyTkrdOpPdaZbiFaipa1yuP8irj7ItLHYOZaKizaQXOs5Olzku)38IOoRb7fgNkdLrNbiFaP)zNVxXrxYuO(V5frDwd2lm(siSOedOVbaHmgGejdqngvk)rzHsRPXxCQmugDgG8b01aqXBn(vWy26)MVTVq54xdaJSJL04RSdmMLcJ5TdwRsuwZUdbe5UZouzOm6KHt2jTHsByzhu8wJhj38QX(sWxcHfLya3lDaWsNb46daZbiFaQXOs5rYnVASVeCQmugDgG8bG8auJrLYJeLSlovgkJodqIKbOgJkLJUKPq9FZlI6SgSxyCQmugDgG8b01aqXBno6sMc1)nViQZAWEHXXVgG8bK(ND(EfhDjtH6)Mxe1znyVW4lHWIsmG(gaeYAasKma1yuP8hLfkTMgFXPYqz0zaYhqxdafV14xbJzR)B(2(cLJFnamYowsJVYoT9fQxOBajL1S7qGzU7SdvgkJoz4KDsBO0gw2j9yPYkLxbmOQVz0aKpGdzkuVvh)HsMBCnsqgfSbiFahYuOERo(dLm34wsdSKFjewuIbC)aqEaWsNb46dacUmgagdq(aqEaDna1yuP8hLfkTMgFXPYqz0zasKma1yuP8hLfkTMgFXPYqz0zaYhqxdafV14xbJzR)B(2(cLJFnamYowsJVYopkluAnLYA2Di6CU7SdvgkJoz4KDoKiTXLgFLDCf0)f0aCnjn(AaSqOdq)bS4v2XsA8v2jzmM3sA8LNfcn7WcH6ldbLDspwQSsfzn7oe3n3D2HkdLrNmCYowsJVYojJX8wsJV8SqOzhwiuFziOSZAPWyISMDhczK7o7qLHYOtgozhlPXxzNKXyElPXxEwi0SdleQVmeu2r3OGKurwZUdXDK7o7qLHYOtgozhlPXxzNKXyElPXxEwi0SdleQVmeu2j9p789krwZUdHSl3D2HkdLrNmCYoPnuAdl7OgJkLNE2XdLSv5uzOm6ma5da5b01aqXBnoKbJffmpclbnkIJFnajsgGAmQuo6sMc1)nViQZAWEHXPYqz0zayma5da5bCiu8wJVwN8BKiUqTeKdq6aKXaKizaDnGdzkupKvadQYx8IA)cJ4R1j)gjAayKDe6gjn7oezhlPXxzNKXyElPXxEwi0SdleQVmeu2j9SJhkzRM1S7qGuYDNDOYqz0jdNStAdL2WYoO4TghDjtH6)Mxe1znyVW44xzhHUrsZUdr2XsA8v2zXlVL04lpleA2Hfc1xgck7G(cVgjiJcwwZUdrNo3D2HkdLrNmCYoPnuAdl7OgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG8as)ZoFVIJUKPq9FZlI6SgSxy8LqyrjgW9dacznamgG8bG8awloEclvk3ohbpQb03aWugdqIKb01awloEclvk3ohbNKziuXaKizaP)zNVxXVcgZw)38T9fkFjewuIbC)aGqwdq(awloEclvk3ohbNKziuXaKpG1IJNWsLYTZrWJAa3paiK1aWi7yjn(k7S4L3sA8LNfcn7WcH6ldbLDqFH)6FwuWYA2DmLvU7SdvgkJoz4KDsBO0gw2bfV14xbJzR)B(2(cLJFna5dqngvk)rzHsRPXxCQmugDYocDJKMDhISJL04RSZIxElPXxEwi0SdleQVmeu25rzHsRPXxzn7oMqK7o7qLHYOtgozN0gkTHLD6Aacs9OFHl4AqlMif)DVsdq(a6AalErTFHr81Gr(V5vOKVTFNqLpb1qCfFXPYqz0zaYhGAmQu(JYcLwtJV4uzOm6ma5di9p789k(vWy26)MVTVq5lHWIsmG7haeYAaYhaYdaRTHHYiUq9xmRQOGnajsgWAXXtyPs525i4KmdHkgG8bSwC8ewQuUDocEud4(baHSgGejdORbSwC8ewQuUDocojZqOIbGr2XsA8v2zXlVL04lpleA2Hfc1xgck78OSqP104l)1)SOGL1S7yIzU7SdvgkJoz4KDsBO0gw2XsAGL8uricsmG(KoamZocDJKMDhISJL04RSZIxElPXxEwi0SdleQVmeu2XEkRz3XSZ5UZouzOm6KHt2XsA8v2jzmM3sA8LNfcn7WcH6ldbLDeQvhBpznRzN1sHXe5UZUdrU7SdvgkJoz4KDSKgFLDqz)F8n81TSZHePnU04RStNYsHXgGRbnyHgKi7K2qPnSSdkERXVcgZw)38T9fkh)kRz3Xm3D2HkdLrNmCYoPnuAdl7GI3A8RGXS1)nFBFHYXVYowsJVYoO0kOfYOGL1S7Do3D2HkdLrNmCYoPnuAdl7G8a6AaO4Tg)kymB9FZ32xOC8RbiFawsdSKNkcrqIb0N0bG5aWyasKmGUgakERXVcgZw)38T9fkh)AaYhaYdyXlIFOwKcDa9jDaYyaYhWIxrYF99OLFOwKcDa9jDa3HSgagzhlPXxzhBtwr(lCMGYA297M7o7qLHYOtgozN0gkTHLDqXBn(vWy26)MVTVq54xzhlPXxzhwadQk8ivf)adbvAwZUlJC3zhQmugDYWj7K2qPnSSdkERXVcgZw)38T9fkh)AaYhakERXjexFpA9lEr(EKD9fh)k7yjn(k7yvIe6AmFYySSMD)oYDNDOYqz0jdNStAdL2WYoO4Tg)kymB9FZ32xO8LqyrjgW9shaszaYhakERXVcgZw)38T9fkh)AaYhakERXjexFpA9lEr(EKD9fh)k7yjn(k70ILqz)FYA2DzxU7SdvgkJoz4KDsBO0gw2bfV14xbJzR)B(2(cLJFna5dWsAGL8uricsmaPdaIbiFaipau8wJFfmMT(V5B7lu(siSOed4(biJbiFaQXOs5PND8qjBvovgkJodqIKb01auJrLYtp74Hs2QCQmugDgG8bGI3A8RGXS1)nFBFHYxcHfLya3pGopamYowsJVYoOgm)386gjifznRzn7GLwr8v2DmLfMykRoJzNZo9STIcMi7iB6A6uU7ADhPshgWa6gknGaX1V6aA)oGBpkluAnn(YF9plky3gWsiD8yPZaepcAagU(imLodib1kyKGpW3XOObGzhgGR(clTkDgWn1yuPCKCBa6pGBQXOs5iHtLHYOZTby6aqArQ74aqgczIbFGFGx2010PC316osLomGb0nuAabIRF1b0(Da3sp74Hs2Q3gWsiD8yPZaepcAagU(imLodib1kyKGpW3XOObarhgGR(clTkDgWTfVO2VWiosUna9hWTfVO2VWios4uzOm6CBaiFxzIbFGVJrrdaZomax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdaziKjg8b(ogfnGo3Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpW3XOObC3omax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdaziKjg8b(ogfnaz0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpWpWlB6A6uU7ADhPshgWa6gknGaX1V6aA)oGBpkluAnn(62awcPJhlDgG4rqdWW1hHP0zajOwbJe8b(ogfnam7WaC1xyPvPZaUPgJkLJKBdq)bCtngvkhjCQmugDUnaKHqMyWh47yu0aWSddWvFHLwLod4w6RdEOCKCBa6pGBPVo4HYrcNkdLrNBdaziKjg8b(ogfnaiKvhgGR(clTkDgWn1yuPCKCBa6pGBQXOs5iHtLHYOZTbGmMYed(a)aVSPRPt5UR1DKkDyadOBO0acex)QdO97aUH(cVgjiJc2TbSeshpw6maXJGgGHRpctPZasqTcgj4d8DmkAaq0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpW3XOObGzhgGR(clTkDgGtGWvdq4wPMmhGSDa6pGoIBd4eydr81a(lAn93bGmCXyaidHmXGpW3XOOb05omax9fwAv6maNaHRgGWTsnzoaz7a0FaDe3gWjWgI4Rb8x0A6Vdaz4IXaqgczIbFGVJrrd4UDyaU6lS0Q0zaobcxnaHBLAYCaY2bO)a6iUnGtGneXxd4VO10FhaYWfJbGmeYed(aFhJIgWD7WaC1xyPvPZaUT4f1(fgXrYTbO)aUT4f1(fgXrcNkdLrNBdaziKjg8b(bEztxtNYDxR7iv6Wagq3qPbeiU(vhq73bCl9yPYkvCBalH0XJLodq8iOby46JWu6mGeuRGrc(aFhJIgaeDyaU6lS0Q0za3uJrLYrYTbO)aUPgJkLJeovgkJo3gaYyktm4d8DmkAay2Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpW3XOOb05omax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdaziKjg8b(ogfnG72Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpW3XOObiJomax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdazmLjg8b(ogfnazxhgGR(clTkDgWn1yuPCKCBa6pGBQXOs5iHtLHYOZTbGmeYed(aFhJIgqNUddWvFHLwLod4M4XzOrD4i52a0Fa3epodnQdhjCQmugDUnaKXuMyWh4h4LnDnDk3DTUJuPddyaDdLgqG46xDaTFhWnHA1X2ZTbSeshpw6maXJGgGHRpctPZasqTcgj4d8DmkAa3rhgGR(clTkDgWn1yuPCKCBa6pGBQXOs5iHtLHYOZTby6aqArQ74aqgczIbFGVJrrdaP0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpW3XOOb0P7WaC1xyPvPZaUPgJkLJKBdq)bCtngvkhjCQmugDUnaK7SmXGpWpWlB6A6uU7ADhPshgWa6gknGaX1V6aA)oGBOVWF9plky3gWsiD8yPZaepcAagU(imLodib1kyKGpW3XOObC3omax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdaziKjg8b(ogfnaz0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpWpWlB6A6uU7ADhPshgWa6gknGaX1V6aA)oGBxlLEeOMEBalH0XJLodq8iOby46JWu6mGeuRGrc(aFhJIgaeDyaU6lS0Q0zaobcxnaHBLAYCaYwz7a0FaDe3gaI)GZWfd4VO10FhaYYwmgaYyktm4d8DmkAaq0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBai3zzIbFGVJrrdaIomax9fwAv6mGB6gfKKYHGJKBdq)bCt3OGKuUcbhj3gaYDwMyWh47yu0aWSddWvFHLwLodWjq4QbiCRutMdq2kBhG(dOJ42aq8hCgUya)fTM(7aqw2IXaqgtzIbFGVJrrdaZomax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBda5oltm4d8DmkAay2Hb4QVWsRsNbCt3OGKuoMCKCBa6pGB6gfKKYvm5i52aqUZYed(aFhJIgqN7WaC1xyPvPZaCceUAac3k1K5aKTdq)b0rCBaNaBiIVgWFrRP)oaKHlgdazmLjg8b(ogfnGo3Hb4QVWsRsNbCt3OGKuoeCKCBa6pGB6gfKKYvi4i52aq(UYed(aFhJIgqN7WaC1xyPvPZaUPBuqskhtosUna9hWnDJcss5kMCKCBaildzIbFGVJrrd4UDyaU6lS0Q0za3uJrLYrYTbO)aUPgJkLJeovgkJo3gaYqitm4d8DmkAa3TddWvFHLwLod42Ixu7xyehj3gG(d42Ixu7xyehjCQmugDUnathaslsDhhaYqitm4d8DmkAa3TddWvFHLwLod4w6RdEOCKCBa6pGBPVo4HYrcNkdLrNBdaziKjg8b(bEztxtNYDxR7iv6Wagq3qPbeiU(vhq73bCl9p789kXTbSeshpw6maXJGgGHRpctPZasqTcgj4d8DmkAay2Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpW3XOObGzhgGR(clTkDgWnXJZqJ6WrYTbO)aUjECgAuhos4uzOm6CBaiJPmXGpW3XOOb05omax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdaziKjg8b(ogfnGo3Hb4QVWsRsNbCBXlQ9lmIJKBdq)bCBXlQ9lmIJeovgkJo3gaYqitm4d8DmkAa3TddWvFHLwLod4MAmQuosUna9hWn1yuPCKWPYqz052amDaiTi1DCaidHmXGpW3XOObiJomax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdaziKjg8b(ogfnG7OddWvFHLwLod4MAmQuosUna9hWn1yuPCKWPYqz052aqgczIbFGVJrrdq21Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpW3XOObi76WaC1xyPvPZaUT4f1(fgXrYTbO)aUT4f1(fgXrcNkdLrNBdaziKjg8b(ogfnGoDhgGR(clTkDgWn1yuPCKCBa6pGBQXOs5iHtLHYOZTbGmeYed(aFhJIgaeq0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpW3XOObabMDyaU6lS0Q0za3uJrLYrYTbO)aUPgJkLJeovgkJo3gaYyktm4d8DmkAaqiJomax9fwAv6mGBlErTFHrCKCBa6pGBlErTFHrCKWPYqz052amDaiTi1DCaidHmXGpWpWlB6A6uU7ADhPshgWa6gknGaX1V6aA)oGB6gfKKkUnGLq64XsNbiEe0amC9rykDgqcQvWibFGVJrrdaIomax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdazmLjg8b(ogfnaz0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaiJPmXGpW3XOObiJomax9fwAv6mGB6gfKKYHGJKBdq)bCt3OGKuUcbhj3gaYqitm4d8DmkAaYOddWvFHLwLod4MUrbjPCm5i52a0Fa30nkijLRyYrYTbGmMYed(aFhJIgWD0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaiJPmXGpW3XOObChDyaU6lS0Q0za30nkijLdbhj3gG(d4MUrbjPCfcosUnaKXuMyWh47yu0aUJomax9fwAv6mGB6gfKKYXKJKBdq)bCt3OGKuUIjhj3gaYqitm4d8DmkAaYUomax9fwAv6mGB6gfKKYHGJKBdq)bCt3OGKuUcbhj3gaYqitm4d8DmkAaYUomax9fwAv6mGB6gfKKYXKJKBdq)bCt3OGKuUIjhj3gaYyktm4d8DmkAaiLomax9fwAv6mGB6gfKKYHGJKBdq)bCt3OGKuUcbhj3gaYyktm4d8DmkAaiLomax9fwAv6mGB6gfKKYXKJKBdq)bCt3OGKuUIjhj3gaYqitm4d8d8YMUMoL7Uw3rQ0HbmGUHsdiqC9RoG2Vd42HAgotVnGLq64XsNbiEe0amC9rykDgqcQvWibFGVJrrdqgDyaU6lS0Q0za3w8IA)cJ4i52a0Fa3w8IA)cJ4iHtLHYOZTbGmMYed(aFhJIgWD0Hb4QVWsRsNbCl91bpuosUna9hWT0xh8q5iHtLHYOZTbGmeYed(aFhJIgasPddWvFHLwLod4MAmQuosUna9hWn1yuPCKWPYqz052aqUZYed(aFhJIgqNUddWvFHLwLod4MAmQuosUna9hWn1yuPCKWPYqz052aqUZYed(aFhJIgaeYQddWvFHLwLod4MAmQuosUna9hWn1yuPCKWPYqz052aq(UYed(aFhJIgaeq0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaiFxzIbFGVJrrdacm7WaC1xyPvPZaUPgJkLJKBdq)bCtngvkhjCQmugDUnaKXuMyWh47yu0aGq21Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaiJPmXGpW3XOObarNUddWvFHLwLod4MAmQuosUna9hWn1yuPCKWPYqz052aqgczIbFGVJrrdatz1Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaMoaKwK6ooaKHqMyWh47yu0aWeIomax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdaziKjg8b(ogfnamHOddWvFHLwLod42Ixu7xyehj3gG(d42Ixu7xyehjCQmugDUnaKHqMyWh4h4LnDnDk3DTUJuPddyaDdLgqG46xDaTFhWn7PBdyjKoES0zaIhbnadxFeMsNbKGAfmsWh47yu0aWSddWvFHLwLod4MAmQuosUna9hWn1yuPCKWPYqz052amDaiTi1DCaidHmXGpW3XOObC3omax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdW0bG0Iu3XbGmeYed(aFhJIgWD0Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaMoaKwK6ooaKHqMyWh47yu0aqkDyaU6lS0Q0za3uJrLYrYTbO)aUPgJkLJeovgkJo3gaYqitm4d8DmkAaD6omax9fwAv6mGBQXOs5i52a0Fa3uJrLYrcNkdLrNBdaziKjg8b(ogfnaiKvhgGR(clTkDgWn1yuPCKCBa6pGBQXOs5iHtLHYOZTbGmeYed(aFhJIgaey2Hb4QVWsRsNbCtngvkhj3gG(d4MAmQuos4uzOm6CBaidHmXGpWpW7ArC9RsNbarNhGL04RbWcHk4d8zhXfLYUJPmGi7CTFlyu25oVZbi7Jmf6aqQUcyq1bG0SVqh4VZ7CaUMRnydatzNldatzHjMd8d835Doaxb1kyKyG)oVZbi7nGofH4XsNbWmHk7jO0xNbGlmy0a(2aCfulkXa(2aCTjAaMyaHoGZtI6MoGlM52a6rm2aIAaxRL0ir8b(78ohGS3aK991nDajOwveBainmsanTwthWbFJc2aGZsMcDaFBaorDwd2lm(a)a)DoaKwSgd3usmaBa6gfKKkgq6F257vUmGtGno0zaOUnGRGXSDaFBaT9f6a(DaOlzk0b8TbiI6SgSxy3edi9p789k(aCTTbe6nXaWAmCAaqnXaQFalHWI6q7awsX3Aaq4YaiMGgWsk(wdqwCzWh4TKgFj4xlLEeOM2Vu4I12WqzKlLHGKQBuqsQhcVWTk5YFjvqA0CbRXWjPq4cwJHtEIjiPYIldxsFDcn(sQUrbjPCi4qnHhxqEu8wtoYDPgJkLJUKPq9FZlI6SgSxyYrw3OGKuoe80)SZ3R4h8104lzRSn9p789k(vWy26)MVTVq5h8104lPYcdjsuJrLYrxYuO(V5frDwd2lm5iN(ND(EfhDjtH6)Mxe1znyVW4h8104lzRSv3OGKuoe80)SZ3R4h8104lPYcdjsuJrLYJeLSlmg4TKgFj4xlLEeOM2Vu4I12WqzKlLHGKQBuqsQhtVWTk5YFjvqA0CbRXWjPq4cwJHtEIjiPYIldxsFDcn(sQUrbjPCm5qnHhxqEu8wtoYDPgJkLJUKPq9FZlI6SgSxyYrw3OGKuoM80)SZ3R4h8104lzRSn9p789k(vWy26)MVTVq5h8104lPYcdjsuJrLYrxYuO(V5frDwd2lm5iN(ND(EfhDjtH6)Mxe1znyVW4h8104lzRSv3OGKuoM80)SZ3R4h8104lPYcdjsuJrLYJeLSlmg4VZbG0k0aHPKya2a0nkijvmaSgdNgaQBdi9iUSnkydqHsdi9p789Qb8TbOqPbOBuqsQld4eyJdDgaQBdqHsd4GVMgFnGVnafknau8wBaHoGR9XghsWhGSFtmaBacDPcMcDai(t0cAhG(dawGLgGnaObmO0oGRn(nu3gG(dqOlvWuOdq3OGKuHldWedOhXydWedWgaI)eTG2b0(DarBa2a0nkijDa9cgBa)oGEbJnG61biCRsdOxOqhq6F257vc(aVL04lb)AP0Ja10(LcxS2ggkJCPmeKuDJcss9xB8BOU5YFjvqA0CbRXWjPy6cwJHtEIjiPq4s6RtOXxs7s3OGKuoeCOMWJlipkERjx3OGKuoMCOMWJlipkERjrIUrbjPCm5qnHhxqEu8wtoYiRBuqskhtE6F257v8d(AA8LSv3OGKuoMCu8wZFWxtJVWW1rgcUm6x3OGKuoMCOMWJI3ACHUubtHIHRJmwBddLrCDJcss9y6fUvjmWOpKrw3OGKuoe80)SZ3R4h8104lzRUrbjPCi4O4TM)GVMgFHHRJmeCz0VUrbjPCi4qnHhfV14cDPcMcfdxhzS2ggkJ46gfKK6HWlCRsyGXaVL04lb)AP0Ja10(LcxS2ggkJCPmeK0TNhfV1eUG1y4Ku1yuPCyMcL2OG5f6ViKij91bpuoHL22(cvIKfVO2VWioAOrbZNE2zG3sA8LGFTu6rGAA)sHBJrcOP1A6a)a)DENdaPvMucxPZaiS062a0abnafknalP)oGqmadRfmdLr8bElPXxcPiI64BlrDcnWFNdq2yjSuPdqCrPOf0za6gfKKkgakffSbGlOZa6fk0by46JW0inawuKyG3sA8LOFPWfRTHHYixkdbjvCrPOf0XRBuqsQlyngojfzcPJhxx0HhLiT4QHYipsh3kfhH)qyJejrcH0XJRl6WvOKVfRq9IawWWqoYP)zNVxXJsKwC1qzKhPJBLIJWFiSrI4lzh3Kij9p789kUcL8TyfQxeWcgFjewucmKiHq64X1fD4kuY3IvOEralyYjKoECDrhEuI0IRgkJ8iDCRuCe(dHns0aVL04lr)sHlwBddLrUugcsQq9xmRQOG5cwJHtsTKgyjpveIGesHqoYRfhpHLkLBNJGhvFqidjs6AT44jSuPC7CeCsMHqfymWBjn(s0Vu4I12WqzKlLHGKANJWVeclkxWAmCsQL0al5PIqeKOpPykh5UwloEclvk3ohbNKziuHejRfhpHLkLBNJGtYmeQqoYRfhpHLkLBNJGVeclkrFYqIKwadQ6xcHfLOpiKfgymWBjn(s0Vu4I12WqzKlLHGKUV2s(nqqUG1y4Kuu8wJVbcIJFjh5Uw8IA)cJ4RbJ8FZRqjFB)oHkFcQH4k(sIKfVO2VWi(AWi)38kuY32VtOYNGAiUIVKV4vK8xFpA5hQfPq7dPGXaVL04lr)sHlwBddLrUugcsABFH6f6gqs(0xh8qfUG1y4K00xh8q50ANizAuW8OSVNCu8wJtRDIKPrbZJY(ECHAjiLIPejPVo4HYXlgzcO0X3wQ6e3KJI3AC8IrMakD8TLQoXn(siSOe3JmS0X1XeJbElPXxI(LcxS2ggkJCPmeK0dzkuH)GtElPbwYfSgdNKEitH6T64puYCJRrcYOGjp9yPYkLxbmOQVz0a)DoaxZ1fZTbG0SVqhasdHLwxgaclk1IAaU2KBdOBJ9LyawDgaKeDnGofH4xbXiHyaYMrP0oG9zSOGnWBjn(s0Vu4UeIFfeJecFVOuADjAstFDWdLtyPTTVqLRgJkLdZuO0gfmVq)fHCK7sngvk)rzHsRPXxYt)ZoFVIFfmMT(V5B7lu(siSOesKii1J(fUGRbTyIu839kjxngvk)rzHsRPXxY7cfV14xbJzR)B(2(cLJFHXaVL04lr)sHl0VhlkyEuMjuxsULyKxTfgPcPq4s0K215vEBFH6BewA5lHWIsihz1yuP8irj7sIKUqXBno6sMc1)nViQZAWEHXXVKRgJkLJUKPq9FZlI6SgSxysKOgJkL)OSqP104l5P)zNVxXVcgZw)38T9fkFjewuc5DHI3ACidglkyEewcAueh)cJbElPXxI(LcxymlfgZBhSwLixIMuu8wJhj38QX(sWxcHfL4EPWshxht5QXOs5rYnVASVeYfxeJ5vBHrQGdJzPWyE7G1Qe1NumLJSAmQuEKOKDjrIAmQuo6sMc1)nViQZAWEHjp9p789ko6sMc1)nViQZAWEHXxcHfLOpiKHejQXOs5pkluAnn(sExO4Tg)kymB9FZ32xOC8lmg4TKgFj6xkCB7luVq3asYLOjffV14rYnVASVe8LqyrjUxkS0X1XuUAmQuEKCZRg7lHCKvJrLYJeLSljsuJrLYrxYuO(V5frDwd2lm5DHI3AC0LmfQ)BEruN1G9cJJFjp9p789ko6sMc1)nViQZAWEHXxcHfLOpiKLejQXOs5pkluAnn(sExO4Tg)kymB9FZ32xOC8lmg4TKgFj6xkCFuwO0Ak5s0KMESuzLYRagu13ms(HmfQ3QJ)qjZnUgjiJcM8dzkuVvh)HsMBClPbwYVeclkX9idlDCDi4Yad5i3LAmQu(JYcLwtJVKirngvk)rzHsRPXxY7cfV14xbJzR)B(2(cLJFHXa)Doaxb9FbnaxtsJVgale6a0FalEnWBjn(s0Vu4MmgZBjn(YZcH6sziiPPhlvwPIbElPXxI(Lc3KXyElPXxEwiuxkdbjDTuymXaVL04lr)sHBYymVL04lpleQlLHGKQBuqsQyG3sA8LOFPWnzmM3sA8LNfc1LYqqst)ZoFVsmWBjn(s0Vu4MmgZBjn(YZcH6sziiPPND8qjBvxe6gjvkeUenPQXOs5PND8qjBv5i3fkERXHmySOG5ryjOrrC8ljsuJrLYrxYuO(V5frDwd2lmmKJ8HqXBn(ADYVrI4c1sqkvgsK01HmfQhYkGbv5lErTFHr816KFJeHXaVL04lr)sH7IxElPXxEwiuxkdbjf9fEnsqgfmxe6gjvkeUenPO4TghDjtH6)Mxe1znyVW44xd8wsJVe9lfUlE5TKgF5zHqDPmeKu0x4V(NffmxIMu1yuPC0LmfQ)BEruN1G9ctoYP)zNVxXrxYuO(V5frDwd2lm(siSOe3dHSWqoYRfhpHLkLBNJGhvFykdjs6AT44jSuPC7CeCsMHqfsKK(ND(Ef)kymB9FZ32xO8LqyrjUhczjFT44jSuPC7CeCsMHqfYxloEclvk3ohbpQ7HqwymWBjn(s0Vu4U4L3sA8LNfc1LYqqsFuwO0AA8LlcDJKkfcxIMuu8wJFfmMT(V5B7luo(LC1yuP8hLfkTMgFnWBjn(s0Vu4U4L3sA8LNfc1LYqqsFuwO0AA8L)6FwuWCjAs7sqQh9lCbxdAXeP4V7vsExlErTFHr81Gr(V5vOKVTFNqLpb1qCfFjxngvk)rzHsRPXxYt)ZoFVIFfmMT(V5B7lu(siSOe3dHSKJmwBddLrCH6VywvrbtIK1IJNWsLYTZrWjzgcviFT44jSuPC7Ce8OUhczjrsxRfhpHLkLBNJGtYmeQaJbElPXxI(Lc3fV8wsJV8SqOUugcsQ9KlcDJKkfcxIMulPbwYtfHiirFsXCG3sA8LOFPWnzmM3sA8LNfc1LYqqsfQvhBpd8d835aCnps7a6uVAA81aVL04lb3Es6si(vqmsi89IsPDG3sA8LGBp1Vu4cJzPWyE7G1Qe5s0KQgJkL32xOIKBkuAG3sA8LGBp1Vu422xOIKBkuYLOjffV14qgmwuW8iSe0Oi(swsL3fwBddLr8dzkuH)GtElPbwAG3sA8LGBp1Vu4c97XIcMhLzc1LOjfRTHHYi((Al53abjxngvk3WAmRsqPbElPXxcU9u)sHlmMLcJ5TdwRsKlrtAxO4TgFdeeh)sUL0al5PIqeK4EPDwIelPbwYtfHiirFDEG)ohasZViWzwKgGDDTVLGoa9hqAjtPbyd4sq4NFaxB8BOUna1wyKoawi0b0(Da21fZTOGnG16KFJenGOgG90aVL04lb3EQFPWTTVq9cDdijxsULyKxTfgPcPq4s0KM(ND(EfFje)kigje(ErP0YxcHfL4EPy66Wsh5QXOs5WmfkTrbZl0FrmWBjn(sWTN6xkCH(9yrbZJYmH6s0KI12WqzeFFTL8BGGg4TKgFj42t9lfUT9fQi5McLCjAsvJrLYHzkuAJcMxO)IqokERXxcXVcIrcHVxukTC8l5wsdSKNkcrqI(WuExyTnmugXpKPqf(do5TKgyPbElPXxcU9u)sH7JYcLwtjxIMuS2ggkJ4hYuOc)bN8wsdSKCu8wJFitHk8hCIlulb593vIe1yuPCyMcL2OG5f6ViKJI3A8Lq8RGyKq47fLslh)AG3sA8LGBp1Vu422xOEHUbKKlj3smYR2cJuHuiCjAsx8ks(RVhT8d1IuO3JmeYOF1yuP8fVIK3uLkCtJVCDzGXaVL04lb3EQFPWTTVqfj3uOKlrtAxyTnmugXpKPqf(do5TKgyPbElPXxcU9u)sH7JYcLwtjxsULyKxTfgPcPq4s0KU4vK8xFpA5hQfPq7dzmLr)QXOs5lEfjVPkv4MgF56YaJbElPXxcU9u)sHlmMLcJ5TdwRs0aVL04lb3EQFPWTTVqfj3uO0aVL04lb3EQFPWTTVq9cDdijxsULyKxTfgPcPqmWBjn(sWTN6xkCH(B5)MVxukTd8wsJVeC7P(LcxBtwrE93LkDGFG)ohaCwYuOd4BdWjQZAWEHnGR)zrbBa7RMgFnGomaHARkgaeYsmauQ9lna48odiedWWAbZqz0aVL04lbh9f(R)zrbt6si(vqmsi89IsP1LOj1sAGL8urics0NumLibRTHHYi(2ZJI3AIbElPXxco6l8x)ZIcw)sH7JYcLwtjxsULyKxTfgPcPq4s0KII3ACidglkyEewcAueFjlPYt)ZoFVIFfmMT(V5B7lu(siSOe915bElPXxco6l8x)ZIcw)sHl0VhlkyEuMjuxIMuS2ggkJ47RTKFde0aVL04lbh9f(R)zrbRFPWTTVqfj3uOKlrtkkERXHmySOG5ryjOrr8LSKkFXRi5V(E0YpulsH2hYqiJ(vJrLYx8ksEtvQWnn(Y1LbgYfxeJ5vBHrQG32xOIKBkuQpmL3fwBddLr8dzkuH)GtElPbwAG3sA8LGJ(c)1)SOG1Vu422xOIKBkuYLOjDXRi5V(E0YpulsH2NuK7Sm6xngvkFXRi5nvPc304lxxgyixCrmMxTfgPcEBFHksUPqP(WuExyTnmugXpKPqf(do5TKgyPb(78ohWn1wyK6JMueMm7aYhcfV14R1j)gjIlulbz)qGHSf5dHI3A816KFJeXxcHfLOFiWW1pKPq9qwbmOkFXlQ9lmIVwN8BKOBdOtrxKPIbydG9QldqHgIbeIbeLs1Hodq)bO2cJ0bOqPbanGbLe6aU243qDBauriCBa9cf6aSAagAWc1TbOqnDa9cgBa21fZTbSwN8BKObeTbS4f1(fgD4dOBOMoaukkydWQbqfHWTb0luOdqwdqOwcsHld43by1aOIq42auOMoafknGdHI3AdOxWydq8FnasMxXsd4l(aVL04lbh9f(R)zrbRFPW9rzHsRPKlj3smYR2cJuHuiCjAsx8ks(RVhT8d1IuO9jftzmWBjn(sWrFH)6FwuW6xkCHXSuymVDWAvICjAsx8ks(RVhT8d1IuO3JPSKlUigZR2cJubhgZsHX82bRvjQpPykp9p789k(vWy26)MVTVq5lHWIs0Nmg4TKgFj4OVWF9plky9lfUT9fQxOBaj5sYTeJ8QTWivifcxIM0fVIK)67rl)qTif69ykl5P)zNVxXVcgZw)38T9fkFjewuI(KXaVL04lbh9f(R)zrbRFPWfgZsHX82bRvjYLOjn9p789k(vWy26)MVTVq5lHWIs03IxexdeKxF)DLV4vK8xFpA5hQfPqV)UYsU4IymVAlmsfCymlfgZBhSwLO(KI5aVL04lbh9f(R)zrbRFPWTTVq9cDdijxsULyKxTfgPcPq4s0KM(ND(Ef)kymB9FZ32xO8Lqyrj6BXlIRbcYRV)UYx8ks(RVhT8d1IuO3FxznWpWFNdaolzk0b8Tb4e1znyVWgGRjPbwAaDQxnn(AG3sA8LGJ(cVgjiJcM0hLfkTMsUKClXiVAlmsfsHWLOjDXRi5V(E0EVuKVRm6xngvkFXRi5nvPc304lxxgymWBjn(sWrFHxJeKrbRFPWDje)kigje(ErP06s0KI12WqzeF75rXBnHejwsdSKNkcrqI(KIPejlEfj)13J277mMYx8I4AGG867X8(fVIK)67rRSfI7yG3sA8LGJ(cVgjiJcw)sH7HmfQ3QJ)qjZnxIM0fVIK)67r79Dgt5lErCnqqE99yE)IxrYF99Ov2cXDmWBjn(sWrFHxJeKrbRFPWf63JffmpkZeQlrtkwBddLr891wYVbcsoYlEfj)13J2(KExzirYIxexdeKxFFNVxkS0rIKfVO2VWi(AWi)38kuY32VtOYNGAiUIVKirCrmMxTfgPco0VhlkyEuMj0(KIPejO4TgFdeeFjewuI77mgsKS4vK8xFpAVVZykFXlIRbcYRVhZ7x8ks(RVhTYwiUJbElPXxco6l8AKGmky9lfUT9fQi5McLCjAsrXBnoKbJffmpclbnkIJFjxCrmMxTfgPcEBFHksUPqP(WuExyTnmugXpKPqf(do5TKgyPbElPXxco6l8AKGmky9lfUpkluAnLCj5wIrE1wyKkKcHlrtkkERXHmySOG5ryjOrr8LSKoWBjn(sWrFHxJeKrbRFPWf6VL)B(ErP06s0KU4vK8xFpAVx6Dil5lErCnqqE99DUpyPZaVL04lbh9fEnsqgfS(Lc32(cvKCtHsUenPIlIX8QTWivWB7lurYnfk1hMY7cRTHHYi(HmfQWFWjVL0alnWBjn(sWrFHxJeKrbRFPW9rzHsRPKlj3smYR2cJuHuiCjAsx8ks(RVhT8d1IuO9HPmKizXlIRbcYRVVZ3dlDg4TKgFj4OVWRrcYOG1Vu4c97XIcMhLzc1LOjfRTHHYi((Al53abnWBjn(sWrFHxJeKrbRFPW12KvKx)DPsDjAsx8ks(RVhT3ldznWpWpWFN35aC1Zodq2pzRoax91j04lXaVL04lbp9SJhkzRknb1Is4)MpsKlrtk6leYBbmOQFjewuI7HLoYrEXl6EmLiPlu8wJdzWyrbZJWsqJI44xYrUlewuEOwD4ycvokERXtp74Hs2QCHAji7t6D7FXlQ9lmId5Z0ynHVzy)vIeewuEOwD4ycvokERXtp74Hs2QCHAji7dP0)Ixu7xyehYNPXAcFZW(lgsKGI3ACidglkyEewcAueh)soYDHWIYd1QdhtOYrXBnE6zhpuYwLlulbzFiL(x8IA)cJ4q(mnwt4Bg2FLibHfLhQvhoMqLJI3A80ZoEOKTkxOwcY(Gqw9V4f1(fgXH8zASMW3mS)Ibgd835aqQIGgWbFJc2aKncgZ2b0luOdW1MOKDbx4SKPqh4TKgFj4PND8qjB1(Lc3eulkH)B(irUenPDPgJkL)OSqP104l5O4Tg)kymB9FZ32xOC8l5O4Tgp9SJhkzRYfQLGSpPqil5iJI3A8RGXS1)nFBFHYxcHfL4EyPJRJme9N(ND(EfVTVq752Iq4B4RB8LSJByirckERXXlOpZnVqxQGPq5lHWIsCpS0rIeu8wJNGAVWJAfXxcHfL4EyPdgd835aqQXvrCOb8TbiBemMTdaxqgmAa9cf6aCTjkzxWfolzk0bElPXxcE6zhpuYwTFPWnb1Is4)MpsKlrtAxQXOs5pkluAnn(s(HmfQhYkGbv5lErTFHr8MXyu5tlUWo0kVlu8wJFfmMT(V5B7luo(L80)SZ3R4xbJzR)B(2(cLVeclkrFqid5iJI3A80ZoEOKTkxOwcY(KcHSKJmkERXXlOpZnVqxQGPq54xsKGI3A8eu7fEuRio(fgsKGI3A80ZoEOKTkxOwcY(KcrNXyG3sA8LGNE2XdLSv7xkCtqTOe(V5Je5s0K2LAmQu(JYcLwtJVK31HmfQhYkGbv5lErTFHr8MXyu5tlUWo0khfV14PND8qjBvUqTeK9jfczjVlu8wJFfmMT(V5B7luo(L80)SZ3R4xbJzR)B(2(cLVeclkrFykRb(7CaYglHLkDaU6zNbi7NSvhWJL2KDDffSbCW3OGnGRGXSDG3sA8LGNE2XdLSv7xkCtqTOe(V5Je5s0KQgJkL)OSqP104l5DHI3A8RGXS1)nFBFHYXVKJmkERXtp74Hs2QCHAji7tke3voYO4TghVG(m38cDPcMcLJFjrckERXtqTx4rTI44xyirckERXtp74Hs2QCHAji7tkeDAjss)ZoFVIFfmMT(V5B7lu(siSOe33z5O4Tgp9SJhkzRYfQLGSpPqCxmg4h4VZbiB8A81aVL04lbp9p789kH0RxJVCjAsrXBn(vWy26)MVTVq54xd835aC1)SZ3Red8wsJVe80)SZ3Re9lfUeIRVhT(fViFpYU(YLOjvngvk)rzHsRPXxYx8IU)oKJmwBddLrCH6VywvrbtIeS2ggkJ425i8lHWIcd5iN(ND(Ef)kymB9FZ32xO8LqyrjUxgYro9p789kEJrcOP1AkFjewuI(KHCXJZqJ6WVWfkoJ80IFPXxsK0L4XzOrD4x4cfNrEAXV04lmKibfV14xbJzR)B(2(cLJFHHejOVqiVfWGQ(LqyrjUhtznWBjn(sWt)ZoFVs0Vu4siU(E06x8I89i76lxIMu1yuPC0LmfQ)BEruN1G9ct(Ix09Yq(IxrYF99O9EKVdzj7DitH6HScyqv(Ixu7xyehQBcL2WCDzi7T4f1(fgXxdXLvQxxRenAPkrUUmWqoYO4TghDjtH6)Mxe1znyVW44xsK0cyqv)siSOe3JPSWyG3sA8LGN(ND(ELOFPWLqC99O1V4f57r21xUenPQXOs5rIs21aVL04lbp9p789kr)sH7vWy26)MVTVqDjAsvJrLYrxYuO(V5frDwd2lm5iJ12WqzexO(lMvvuWKibRTHHYiUDoc)siSOWqoYP)zNVxXrxYuO(V5frDwd2lm(siSOesKK(ND(EfhDjtH6)Mxe1znyVW4lzh3KV4vK8xFpA77oKbgd8wsJVe80)SZ3Re9lfUxbJzR)B(2(c1LOjvngvkpsuYUK3fkERXVcgZw)38T9fkh)AG3sA8LGN(ND(ELOFPW9kymB9FZ32xOUenPQXOs5pkluAnn(soYlEfj)13J2(K2zziVlu8wJBOpIOmn(YZceOC8ljsqXBnUH(iIY04lplqGYXVKizXlQ9lmIVgmY)nVcL8T97eQ8jOgIR4lmKJmwBddLrCH6VywvrbtIeS2ggkJ425i8lHWIcd5iRgJkLdZuO0gfmVq)fbNkdLrh5O4TgFje)kigje(ErP0YXVKiPl1yuPCyMcL2OG5f6Vi4uzOm6GXaVL04lbp9p789kr)sHl6sMc1)nViQZAWEH5s0KII3A8RGXS1)nFBFHYXVg4TKgFj4P)zNVxj6xkCB7l0EUTie(g(6MlrtQL0al5PIqeKqkeYrXBn(vWy26)MVTVq5lHWIsCpS0rokERXVcgZw)38T9fkh)sExQXOs5pkluAnn(soYDTwC8ewQuUDocojZqOcjswloEclvk3ohbpQ(6SSWqIKwadQ6xcHfL4(opWBjn(sWt)ZoFVs0Vu422xO9CBri8n81nxIMulPbwYtfHiirFsXuoYO4Tg)kymB9FZ32xOC8ljswloEclvk3ohbNKziuH81IJNWsLYTZrWJQV0)SZ3R4xbJzR)B(2(cLVeclkr)YomKJmkERXVcgZw)38T9fkFjewuI7HLosKSwC8ewQuUDocojZqOc5RfhpHLkLBNJGVeclkX9Wshmg4TKgFj4P)zNVxj6xkCB7l0EUTie(g(6MlrtQAmQu(JYcLwtJVKJmkERXVcgZw)38T9fkh)sExiSO8qT6WXeQejDHI3A8RGXS1)nFBFHYXVKJWIYd1QdhtOYt)ZoFVIFfmMT(V5B7lu(siSOeyihzKrXBn(vWy26)MVTVq5lHWIsCpS0rIeu8wJJxqFMBEHUubtHYXVKJI3AC8c6ZCZl0Lkyku(siSOe3dlDWqoYhcfV14R1j)gjIlulbPuzirsxhYuOEiRaguLV4f1(fgXxRt(nsegymWBjn(sWt)ZoFVs0Vu4c1TRxHslIi5VwsqvICjAsvJrLYrxYuO(V5frDwd2lm5lEfj)13J27VdzjFXl6EPDwoYO4TghDjtH6)Mxe1znyVW44xsKK(ND(EfhDjtH6)Mxe1znyVW4lHWIs03DLfgsK0LAmQuo6sMc1)nViQZAWEHjFXRi5V(E0EVuzNmg4TKgFj4P)zNVxj6xkCxleK)q2XLOjn9p789k(vWy26)MVTVq5lHWIsCVuzmWBjn(sWt)ZoFVs0Vu4kS0gTifgZFzj1LOj1sAGL8urics0NumLJClGbv9lHWIsCFNLiPlu8wJJUKPq9FZlI6SgSxyC8l5iFrkhg0hNXxcHfL4EyPJejRfhpHLkLBNJGtYmeQq(AXXtyPs525i4lHWIsCFNLVwC8ewQuUDocEu9Drkhg0hNXxcHfLadmg4TKgFj4P)zNVxj6xkCpKPq9wD8hkzU5s0KAjnWsEQiebj6tgsKS4f1(fgXVGs2(i(Ied8d835aC1JLkR0b4AqdwObjg4TKgFj4PhlvwPcPhYuOc)bNCjAsrUl1yuP8hLfkTMgFjrIAmQu(JYcLwtJVKBjnWsEQiebj6tkMYt)ZoFVIFfmMT(V5B7lu(siSOesKyjnWsEQiebjKcbgYrgRTHHYiUq9xmRQOGjrcwBddLrC7Ce(LqyrHXaVL04lbp9yPYkv0Vu4k6zlIOG5rec1LOjDXRi5V(E0YpulsH2heDwE6F257v8RGXS1)nFBFHYxcHfL4(olVl1yuPC0LmfQ)BEruN1G9ctowBddLrCH6VywvrbBG3sA8LGNESuzLk6xkCf9SfruW8icH6s0K2LAmQuo6sMc1)nViQZAWEHjhRTHHYiUDoc)siSOg4TKgFj4PhlvwPI(LcxrpBrefmpIqOUenPQXOs5Olzku)38IOoRb7fMCKrXBno6sMc1)nViQZAWEHXXVKJmwBddLrCH6Vywvrbt(IxrYF99OLFOwKcTV7kljsWAByOmIBNJWVeclk5lEfj)13Jw(HArk0(UdzjrcwBddLrC7Ce(LqyrjFT44jSuPC7Ce8LqyrjUVtlFT44jSuPC7CeCsMHqfyirsxO4TghDjtH6)Mxe1znyVW44xYt)ZoFVIJUKPq9FZlI6SgSxy8LqyrjWyG3sA8LGNESuzLk6xkCn0hruMgF5zbcuxIM00)SZ3R4xbJzR)B(2(cLVeclkX9Wshxht5yTnmugXfQ)Izvffm5iRgJkLJUKPq9FZlI6SgSxyYx8ks(RVhT9DhYqE6F257vC0LmfQ)BEruN1G9cJVeclkX9ykrsxQXOs5Olzku)38IOoRb7fggd8wsJVe80JLkRur)sHRH(iIY04lplqG6s0KI12Wqze3ohHFjewud8wsJVe80JLkRur)sHRaQLGKrEfk5XRE)QqDZLOjfRTHHYiUq9xmRQOGjh50)SZ3R4xbJzR)B(2(cLVeclkX9DwIe1yuP8irj7cJbElPXxcE6XsLvQOFPWva1sqYiVcL84vVFvOU5s0KI12Wqze3ohHFjewud8wsJVe80JLkRur)sHBJrcOP1AQlrtAxO4Tg)kymB9FZ32xOC8l5ilECgAuh(fUqXzKNw8ln(sIeXJZqJ6WX(mtdg5fpdlvQ8UqXBno2NzAWiV4zyPs54xy4sukTl(L6deiOtykjfcxIsPDXVupm2JAmPq4sukTl(L6JMuXJZqJ6WX(mtdg5fpdlv6a)a)DoaKAuwO0AA81a2xnn(AG3sA8LG)OSqP104lPlH4xbXiHW3lkLwxIMulPbwYtfHiirFs7SCS2ggkJ4BppkERjg4TKgFj4pkluAnn(QFPWTTVq9cDdijxIM0UqXBnoKbJffmpclbnkIJFjh5fVO7XuIe1yuP8i5Mxn2xc5O4TgpsU5vJ9LGVeclkX9WshxhtjssFDWdLJxmYeqPJVTu1jUjhzu8wJJxmYeqPJVTu1jUXxcHfL4EyPJRJPejO4TghVyKjGshFBPQtCJlulb59Dgdmg4TKgFj4pkluAnn(QFPWf63JffmpkZeQlrtAxO4TghYGXIcMhHLGgfXXVKV4f1N0olhzu8wJVbcIVeclkX9DwokERX3abXXVKiXsAGL8Nx5T9fQVryP9ElPbwYtfHiibgd8wsJVe8hLfkTMgF1Vu4cJzPWyE7G1Qe5s0K2fkERXHmySOG5ryjOrrC8l5IlIX8QTWivWHXSuymVDWAvI6tkMsK0fkERXHmySOG5ryjOrrC8l5iFiu8wJVwN8BKiUqTeK3ldjsoekERXxRt(nseFjewuI7HLoU(DXyG3sA8LG)OSqP104R(Lc32(cvKCtHsUenPO4TghYGXIcMhHLGgfXxYsQCXfXyE1wyKk4T9fQi5McL6dt5DH12Wqze)qMcv4p4K3sAGLg4TKgFj4pkluAnn(QFPW9rzHsRPKlj3smYR2cJuHuiCjAsrXBnoKbJffmpclbnkIVKL0bElPXxc(JYcLwtJV6xkCB7luVq3asYLOj1sAGL8uricsifc5yTnmugXB7luVq3asYN(6GhQyG3sA8LG)OSqP104R(LcxOFpwuW8OmtOUenPyTnmugX3xBj)gii5IlIX8QTWivWH(9yrbZJYmH2Numh4TKgFj4pkluAnn(QFPWfgZsHX82bRvjYLOjvCrmMxTfgPcomMLcJ5TdwRsuFsXCG3sA8LG)OSqP104R(Lc32(c1l0nGKCj5wIrE1wyKkKcHlrtAxQXOs5gwJzvckjVlu8wJdzWyrbZJWsqJI44xsKOgJkLBynMvjOK8UWAByOmIVV2s(nqqsKG12WqzeFFTL8BGGKV4fX1ab513JzFsHLod8wsJVe8hLfkTMgF1Vu4c97XIcMhLzc1LOjfRTHHYi((Al53abnWBjn(sWFuwO0AA8v)sH7JYcLwtjxsULyKxTfgPcPqmWpWFNdq24FwuWgasZVdaPgLfkTMgF1Hb4O2QIbaHSgGGsFDedaLA)sdq2iymBhW3gasZ(cDaPhbjgW3AdWvY(g4TKgFj4pkluAnn(YF9plkysxcXVcIrcHVxukTUenPyTnmugX3EEu8wtirIL0al5PIqeKOpPyoWBjn(sWFuwO0AA8L)6FwuW6xkCHXSuymVDWAvICjAsfxeJ5vBHrQGdJzPWyE7G1Qe1NumLRgJkL32xOIKBkuAG3sA8LG)OSqP104l)1)SOG1Vu422xOIKBkuYLOjffV14qgmwuW8iSe0Oi(swsLBjnWsEQiebj6dt5DH12Wqze)qMcv4p4K3sAGLg4TKgFj4pkluAnn(YF9plky9lfUpkluAnLCj5wIrE1wyKkKcHlrtkkERXHmySOG5ryjOrr8LSKoWBjn(sWFuwO0AA8L)6FwuW6xkCB7luVq3asYLOj1sAGL8uricsifc5yTnmugXB7luVq3asYN(6GhQyG3sA8LG)OSqP104l)1)SOG1Vu4(OSqP1uYLKBjg5vBHrQqkeUenPO4TghYGXIcMhHLGgfXxYs6aVL04lb)rzHsRPXx(R)zrbRFPWf63JffmpkZeQlrtkwBddLr891wYVbcAG3sA8LG)OSqP104l)1)SOG1Vu4cJzPWyE7G1Qe5s0KkUigZR2cJubhgZsHX82bRvjQpPykFXRi5V(E0YpulsHE)DiRbElPXxc(JYcLwtJV8x)ZIcw)sHBBFH6f6gqsUKClXiVAlmsfsHWLOjDXRi5V(E0YpulsHEVStwd8wsJVe8hLfkTMgF5V(NffS(Lc3hLfkTMsUKClXiVAlmsfsHWLOjDXlQpPDwoYDHWIYd1QdhtOsKKESuzLYlkTp73JejPhlvwPCiDBdRWqIKfVO(KEx5iSO8qT6WXe6aVL04lb)rzHsRPXx(R)zrbRFPWTTVqfj3uOKlrtQL0al5PIqeKOpP3vExyTnmugXpKPqf(do5TKgyPb(b(7CaDklfgBaUg0GfAqIbElPXxc(APWycPOS)p(g(6MlrtkkERXVcgZw)38T9fkh)AG3sA8LGVwkmMOFPWfLwbTqgfmxIMuu8wJFfmMT(V5B7luo(1aVL04lbFTuymr)sHRTjRi)fotqUenPi3fkERXVcgZw)38T9fkh)sUL0al5PIqeKOpPyIHejDHI3A8RGXS1)nFBFHYXVKJ8Ixe)qTifAFsLH8fVIK)67rl)qTifAFsVdzHXaVL04lbFTuymr)sHllGbvfEKQIFGHGk1LOjffV14xbJzR)B(2(cLJFnWBjn(sWxlfgt0Vu4AvIe6AmFYymxIMuu8wJFfmMT(V5B7luo(LCu8wJtiU(E06x8I89i76lo(1aVL04lbFTuymr)sHBlwcL9)XLOjffV14xbJzR)B(2(cLVeclkX9srkYrXBn(vWy26)MVTVq54xYrXBnoH467rRFXlY3JSRV44xd8wsJVe81sHXe9lfUOgm)386gjifUenPO4Tg)kymB9FZ32xOC8l5wsdSKNkcrqcPqihzu8wJFfmMT(V5B7lu(siSOe3ld5QXOs5PND8qjBvovgkJosK0LAmQuE6zhpuYwLtLHYOJCu8wJFfmMT(V5B7lu(siSOe33zmg4h4VZb4OwDS9maruWyKSNAlmshW(QPXxd8wsJVeCHA1X2J0Lq8RGyKq47fLsRlrtkwBddLr8TNhfV1ed8wsJVeCHA1X2t)sH7JYcLwtjxIMuu8wJdzWyrbZJWsqJI4lzjDG3sA8LGluRo2E6xkCH(9yrbZJYmH6s0KI12WqzeFFTL8BGGKJI3A8nqq8LqyrjUVZd8wsJVeCHA1X2t)sHBBFH6f6gqsUenPyTnmugXB7luVq3asYN(6GhQyG3sA8LGluRo2E6xkCHXSuymVDWAvICjAs76qMc1dzfWGQ8fVO2VWi(ADYVrIKJ8HqXBn(ADYVrI4c1sqEVmKi5qO4TgFTo53ir8LqyrjUhw6463fJbElPXxcUqT6y7PFPWTTVq9cDdijxIM00)SZ3R4lH4xbXiHW3lkLw(siSOe3lftxhw6ixngvkhMPqPnkyEH(lIbElPXxcUqT6y7PFPWf63JffmpkZeQlrtkwBddLr891wYVbcAG3sA8LGluRo2E6xkCB7luVq3asYLOjDXRi5V(E0YpulsHEpYqiJ(vJrLYx8ksEtvQWnn(Y1Lbgd8wsJVeCHA1X2t)sH7JYcLwtjxIM0UqXBnEB)oHk)fotqC8l5QXOs5T97eQ8x4mbjrcwBddLr8dzkuH)GtElPbwsokERXpKPqf(doXfQLG8(7krYIxuFsVRCbPE0VWfCnOftKI)UxjjsqgHfLhQvhoMqLiPR0JLkRuEfWGQ(MrsK0LGup6x4cUg0IjsXF3RegYvJrLYHzkuAJcMxO)IqokERXxcXVcIrcHVxukTC8ljs6sqQh9lCbxdAXeP4V7vs(IxrYF99OLFOwKcTpKXug9RgJkLV4vK8MQuHBA8LRldmg4TKgFj4c1QJTN(Lc32(c1l0nGKg4TKgFj4c1QJTN(LcxO)w(V57fLs7aVL04lbxOwDS90Vu4ABYkYR)UuPd8d835a6EJcssfd8wsJVeCDJcssfsXfKpucHlLHGKgLiT4QHYipsh3kfhH)qyJe5s0K2LAmQuo6sMc1)nViQZAWEHjhfV14xbJzR)B(2(cLJFjhfV14eIRVhT(fViFpYU(IJFjrIAmQuo6sMc1)nViQZAWEHjhzKrXBn(vWy26)MVTVq54xYt)ZoFVIJUKPq9FZlI6SgSxy8LSJByircYO4Tg)kymB9FZ32xOC8l5iJClGbv9lHWIsi7L(ND(EfhDjtH6)Mxe1znyVW4lHWIsGX9ycbgyGHejOVqiVfWGQ(LqyrjUhtiKi5qMc1dzfWGQ8timug5dK(XtYKs4kjvwYvBHrkxdeKxF)vs9ykR7LXaVL04lbx3OGKur)sHlUG8HsiCPmeKuygwI5)MxHs(wSc1BlAO0oWBjn(sW1nkijv0Vu4IliFOecxkdbjvKSv4)MVTMsBzmVq3Ord8wsJVeCDJcssf9lfU4cYhkHWLYqqsvOKVfRq9IawWCjAsrXBn(vWy26)MVTVq54xYrXBnoH467rRFXlY3JSRV44xd835a6gknaDJcsshqVqHoafknaObmOKqhaj0aHP0zayngo5Ya6fm2aqPbGlOZaAXk0by1zaxwS0za9cf6aKncgZ2b8TbG0SVq5d8wsJVeCDJcssf9lfU6gfKKcHlrtAxyTnmugXfxukAbD86gfKKkhfV14xbJzR)B(2(cLJFjh5UuJrLYJeLSljsuJrLYJeLSl5O4Tg)kymB9FZ32xO8Lqyrj6tkeYcd5i3LUrbjPCm5qnHp9p789kjs0nkijLJjp9p789k(siSOesKG12Wqzex3OGKu)1g)gQBsHadjs0nkijLdbhfV18h8104R(K2cyqv)siSOed8wsJVeCDJcssf9lfU6gfKKIPlrtAxyTnmugXfxukAbD86gfKKkhfV14xbJzR)B(2(cLJFjh5UuJrLYJeLSljsuJrLYJeLSl5O4Tg)kymB9FZ32xO8Lqyrj6tkeYcd5i3LUrbjPCi4qnHp9p789kjs0nkijLdbp9p789k(siSOesKG12Wqzex3OGKu)1g)gQBsXedjs0nkijLJjhfV18h8104R(K2cyqv)siSOed835aCTTb8fZTb8fnGVgaUGgGUrbjPd4AFSXHedWgakER5YaWf0auO0aEfkTd4RbK(ND(EfFai17aI2akkuO0oaDJcsshW1(yJdjgGnau8wZLbGlObG(k0b81as)ZoFVIpWBjn(sW1nkijv0Vu4IliFOecxeSxLQBuqskeUenPDH12WqzexCrPOf0XRBuqsQCK7s3OGKuoeCOMWJlipkERjhzDJcss5yYt)ZoFVIVeclkHejDPBuqskhtout4XfKhfV1WqIK0)SZ3R4xbJzR)B(2(cLVeclkrFyklmg4TKgFj46gfKKk6xkCXfKpucHlc2Rs1nkijftxIM0UWAByOmIlUOu0c641nkijvoYDPBuqskhtout4XfKhfV1KJSUrbjPCi4P)zNVxXxcHfLqIKU0nkijLdbhQj84cYJI3Ayirs6F257v8RGXS1)nFBFHYxcHfLOpmLfgznR5ma]] )


end
