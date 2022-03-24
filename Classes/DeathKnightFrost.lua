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


    spec:RegisterPack( "Frost DK", 20220323, [[d802xdqiPk9iiqUerP0MiQ(KkLrbrofe1QOsfVsQQMfvIBbfQAxO6xqqdJOKJPs1YGIEgvsnnOqUgrHTbb4BeLQghrP4CqazDuPQ5bcUhrSpPQCqQuPwii0dPsYejkvYfHavBecu(OurvgPurv5KuPswje6LeLkLzkvKBkvuv1oLk8tiGAOqHklvQOYtPIPkvXvLkQQ8vIsfJfkyVI6Vu1GbomLfdPhlYKvXLr2Su(mOmAq60cRMOuP61GOzJYTbv7wYVv1WvjhhkuwUspNW0jDDOA7qPVlvA8efDEQuwVurz(eP9R489CpzNJPuUdmLfMyklxJPR5y6Axllms2NDu3UOSZLLG0GrzNYGtzheS9f6aKDj7w25YCJ92j3t2r84BIYoqv9s4EeIqyHcfhLNE4iueWXzMgFLwRPiueWtim7GIhm1Dvz0SZXuk3bMYctmLLRX01CmDTRLLSKnzhdxH(B2XjG7QSd04COkJMDoKiLDKDrMcDaYUvbmO6aqW2xOdID(BBc6aW01UmamLfMyoioi6kOwbJedIy8dOZrWFS0zamtOy8ck91za4cdgnGVnaxb1IsmGVna3vIgGjgqOd48KOUPd4IzUnGUeJnGOgW1AjnseFqeJFaYU(6MoGeuRkInaemgjGMwRPd4GVrbBaqCjtHoGVnaNOoRb7fgp7WcHkY9KDEuwO0AA8L)6FwuWY9K74EUNSdvgkJoziMDSKgFLDwc(VcIrcHVBukTzNdjsBCPXxzhmU)zrbBaiy)oaeyuwO0AA8L7hGJARkgWDznabL(6igak1(LgagxWy2oGVnaeS9f6aspCsmGV1gGRKDLDsBO0gw2bRTHHYi(21JI3AIbiv6aSKgyjpve8GedOpjdaZSM7aZCpzhQmugDYqm7K2qPnSSJ4IymVAlmsfCymlfgZBhSwLOb0NKbG5aKpa1yuP82(cvKCtHsCQmugDYowsJVYoWywkmM3oyTkrzn3HRZ9KDOYqz0jdXStAdL2WYoO4TghYGXIcMhULGgfXxYs6aKpalPbwYtfbpiXa6Bayoa5dO3bG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5McLYAUdmk3t2HkdLrNmeZowsJVYopkluAnLYoPnuAdl7GI3ACidglkyE4wcAueFjlPzNKBjg5vBHrQi3X9SM7qg5EYouzOm6KHy2jTHsByzhlPbwYtfbpiXaKmG7dq(aWAByOmI32xOEHUbKKp91bpur2XsA8v2PTVq9cDdiPSM7abK7j7qLHYOtgIzhlPXxzNhLfkTMszN0gkTHLDqXBnoKbJffmpClbnkIVKL0StYTeJ8QTWivK74EwZDi7Z9KDOYqz0jdXStAdL2WYoyTnmugX3xBj)gWPSJL04RSd0VllkyEuMj0SM7q2K7j7qLHYOtgIzN0gkTHLDexeJ5vBHrQGdJzPWyE7G1QenG(KmamhG8bS4vK8xFxA5hQfPqhaegacqwzhlPXxzhymlfgZBhSwLOSM7abk3t2HkdLrNmeZowsJVYoT9fQxOBajLDsBO0gw2zXRi5V(U0YpulsHoaimazVSYoj3smYR2cJurUJ7zn3XDzL7j7qLHYOtgIzhlPXxzNhLfkTMszN0gkTHLDw8IgqFsgGRhG8bG0a6DaWTO8qT6WXe6aKkDaPhlvwP8Is7Z(9maPshq6XsLvkhs32WQbG8aKkDalErdOpjdaJgG8ba3IYd1QdhtOzNKBjg5vBHrQi3X9SM74(9CpzhQmugDYqm7K2qPnSSJL0al5PIGhKya9jzay0aKpGEhawBddLr8dzkuH)GtElPbwk7yjn(k702xOIKBkukRzn7KE2XdLSvZ9K74EUNSdvgkJoziMDsBO0gw2b9fIbiFaTagu1VeClkXaGWaGLodq(aqAalErdacdaZbiv6a6DaO4TghYGXIcMhULGgfXXVgG8bG0a6DaWTO8qT6WXe6aKpau8wJNE2XdLSv5c1sqoG(KmamAa9pGfVO2VWioKptJ1e(MH9xovgkJodqQ0ba3IYd1QdhtOdq(aqXBnE6zhpuYwLlulb5a6BaYMb0)aw8IA)cJ4q(mnwt4Bg2F5uzOm6maKhGuPdafV14qgmwuW8WTe0Oio(1aKpaKgqVdaUfLhQvhoMqhG8bGI3A80ZoEOKTkxOwcYb03aKndO)bS4f1(fgXH8zASMW3mS)YPYqz0zasLoa4wuEOwD4ycDaYhakERXtp74Hs2QCHAjihqFd4USgq)dyXlQ9lmId5Z0ynHVzy)LtLHYOZaqEaiNDSKgFLDsqTOe(V5JeL1ChyM7j7qLHYOtgIzhlPXxzNeulkH)B(irzNdjsBCPXxzNo)e0ao4BuWgagxWy2oGUHcDaUReLSlecXLmfA2jTHsByzNEhGAmQu(JYcLwtJV4uzOm6ma5dafV14xbJzR)B(2(cLJFna5dafV14PND8qjBvUqTeKdOpjd4USgG8bG0aqXBn(vWy26)MVTVq5lb3IsmaimayPZaCNbG0aUpG(hq6F257w82(cTRBlCHVHVUXxYoUnaKhGuPdafV144f0N5MxOlvWuO8LGBrjgaegaS0zasLoau8wJNGAVWJAfXxcUfLyaqyaWsNbGCwZD46CpzhQmugDYqm7yjn(k7KGArj8FZhjk7CirAJln(k7GaJRI4qd4BdaJlymBhaUGmy0a6gk0b4UsuYUqiexYuOzN0gkTHLD6DaQXOs5pkluAnn(ItLHYOZaKpGdzkupKvadQYx8IA)cJ4nJXOYNwCHDODaYhqVdafV14xbJzR)B(2(cLJFna5di9p78Dl(vWy26)MVTVq5lb3IsmG(gWDzma5daPbGI3A80ZoEOKTkxOwcYb0NKbCxwdq(aqAaO4TghVG(m38cDPcMcLJFnaPshakERXtqTx4rTI44xda5biv6aqXBnE6zhpuYwLlulb5a6tYaU76bGCwZDGr5EYouzOm6KHy2jTHsByzNEhGAmQu(JYcLwtJV4uzOm6ma5dO3bCitH6HScyqv(Ixu7xyeVzmgv(0IlSdTdq(aqXBnE6zhpuYwLlulb5a6tYaUlRbiFa9oau8wJFfmMT(V5B7luo(1aKpG0)SZ3T4xbJzR)B(2(cLVeClkXa6BaykRSJL04RStcQfLW)nFKOSM7qg5EYouzOm6KHy2XsA8v2jb1Is4)Mpsu25qI0gxA8v2bJBjSuPdWvp7mGoFKT6aES0MSRROGnGd(gfSbCfmMTzN0gkTHLDuJrLYFuwO0AA8fNkdLrNbiFa9oau8wJFfmMT(V5B7luo(1aKpaKgakERXtp74Hs2QCHAjihqFsgWDmAaYhasdafV144f0N5MxOlvWuOC8Rbiv6aqXBnEcQ9cpQveh)AaipaPshakERXtp74Hs2QCHAjihqFsgWDeObiv6as)ZoF3IFfmMT(V5B7lu(sWTOedacdW1dq(aqXBnE6zhpuYwLlulb5a6tYaUJrda5SM1SZJYcLwtJVY9K74EUNSdvgkJoziMDSKgFLDwc(VcIrcHVBukTzNdjsBCPXxzheyuwO0AA81a2xnn(k7K2qPnSSJL0al5PIGhKya9jzaUEaYhawBddLr8TRhfV1ezn3bM5EYouzOm6KHy2jTHsByzNEhakERXHmySOG5HBjOrrC8RbiFainGfVObaHbG5aKkDaQXOs5rYnVASVeCQmugDgG8bGI3A8i5Mxn2xc(sWTOedacdaw6ma3zayoaPshq6RdEOC8IrMakD8TLQoZnovgkJodq(aqAaO4TghVyKjGshFBPQZCJVeClkXaGWaGLodWDgaMdqQ0bGI3AC8IrMakD8TLQoZnUqTeKdacdW1da5bGC2XsA8v2PTVq9cDdiPSM7W15EYouzOm6KHy2jTHsByzNEhakERXHmySOG5HBjOrrC8RbiFalErdOpjdW1dq(aqAaO4TgFd4eFj4wuIbaHb46biFaO4TgFd4eh)AasLoalPbwYFEL32xO(gHL2baHbyjnWsEQi4bjgaYzhlPXxzhOFxwuW8OmtOzn3bgL7j7qLHYOtgIzN0gkTHLD6DaO4TghYGXIcMhULGgfXXVgG8biUigZR2cJubhgZsHX82bRvjAa9jzayoaPshqVdafV14qgmwuW8WTe0Oio(1aKpaKgWHqXBn(AD2VrI4c1sqoaimazmaPshWHqXBn(AD2VrI4lb3IsmaimayPZaCNbGrda5SJL04RSdmMLcJ5TdwRsuwZDiJCpzhQmugDYqm7K2qPnSSdkERXHmySOG5HBjOrr8LSKoa5dqCrmMxTfgPcEBFHksUPqPb03aWCaYhqVdaRTHHYi(HmfQWFWjVL0alLDSKgFLDA7lurYnfkL1ChiGCpzhQmugDYqm7yjn(k78OSqP1uk7K2qPnSSdkERXHmySOG5HBjOrr8LSKMDsULyKxTfgPICh3ZAUdzFUNSdvgkJoziMDsBO0gw2XsAGL8urWdsmajd4(aKpaS2ggkJ4T9fQxOBaj5tFDWdvKDSKgFLDA7luVq3askR5oKn5EYouzOm6KHy2jTHsByzhS2ggkJ47RTKFd40aKpaXfXyE1wyKk4q)USOG5rzMqhqFsgaMzhlPXxzhOFxwuW8OmtOzn3bcuUNSdvgkJoziMDsBO0gw2rCrmMxTfgPcomMLcJ5TdwRs0a6tYaWm7yjn(k7aJzPWyE7G1QeL1Ch3LvUNSdvgkJoziMDSKgFLDA7luVq3ask7K2qPnSStVdqngvk3WAmRsqjovgkJodq(a6DaO4TghYGXIcMhULGgfXXVgGuPdqngvk3WAmRsqjovgkJodq(a6DayTnmugX3xBj)gWPbiv6aWAByOmIVV2s(nGtdq(aw8I4AaN867XCa9jzaWsNStYTeJ8QTWivK74EwZDC)EUNSdvgkJoziMDsBO0gw2bRTHHYi((Al53aoLDSKgFLDG(DzrbZJYmHM1Ch3Xm3t2HkdLrNmeZowsJVYopkluAnLYoj3smYR2cJurUJ7znRzh0x41ibzuWY9K74EUNSdvgkJoziMDSKgFLDEuwO0AkLDsULyKxTfgPICh3ZoPnuAdl7S4vK8xFxAhaeKmaKgagjJb0)auJrLYx8ksEtvQWnn(ItLHYOZaCNbiJbGC25qI0gxA8v2bIlzk0b8Tb4e1znyVWgG7oPbwAaDUxnn(kR5oWm3t2HkdLrNmeZoPnuAdl7G12WqzeF76rXBnXaKkDawsdSKNkcEqIb0NKbG5aKkDalEfj)13L2baHb4AmhG8bS4fX1ao513J5aGWaw8ks(RVlTdaHd4oci7yjn(k7Se8FfeJecF3OuAZAUdxN7j7qLHYOtgIzN0gkTHLDw8ks(RVlTdacdW1yoa5dyXlIRbCYRVhZbaHbS4vK8xFxAhachWDeq2XsA8v25qMc1B1XFOK5wwZDGr5EYouzOm6KHy2jTHsByzhS2ggkJ47RTKFd40aKpaKgWIxrYF9DPDa9jzayKmgGuPdyXlIRbCYRV31dacsgaS0zasLoGfVO2VWi(AWi)38kuY32VZOYNGAWVIV4uzOm6maPshG4IymVAlmsfCOFxwuW8OmtOdOpjdaZbiv6aqXBn(gWj(sWTOedacdW1da5biv6aw8ks(RVlTdacdW1yoa5dyXlIRbCYRVhZbaHbS4vK8xFxAhachWDeq2XsA8v2b63LffmpkZeAwZDiJCpzhQmugDYqm7K2qPnSSdkERXHmySOG5HBjOrrC8RbiFaIlIX8QTWivWB7lurYnfknG(gaMdq(a6DayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUPqPSM7abK7j7qLHYOtgIzhlPXxzNhLfkTMszN0gkTHLDqXBnoKbJffmpClbnkIVKL0StYTeJ8QTWivK74EwZDi7Z9KDOYqz0jdXStAdL2WYolEfj)13L2babjdabiRbiFalErCnGtE99UEa9nayPt2XsA8v2b6VL)B(UrP0M1ChYMCpzhQmugDYqm7K2qPnSSJ4IymVAlmsf82(cvKCtHsdOVbG5aKpGEhawBddLr8dzkuH)GtElPbwk7yjn(k702xOIKBkukR5oqGY9KDOYqz0jdXSJL04RSZJYcLwtPStAdL2WYolEfj)13Lw(HArk0b03aWugdqQ0bS4fX1ao51376baHbalDYoj3smYR2cJurUJ7zn3XDzL7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nGtzhlPXxzhOFxwuW8OmtOzn3X975EYouzOm6KHy2jTHsByzNfVIK)67s7aGWaKHSYowsJVYo2MSI86VlvAwZA2rOwDS9K7j3X9CpzhQmugDYqm7yjn(k7Se8FfeJecF3OuAZohsK24sJVYooQvhBpdqefmgHXR2cJ0bSVAA8v2jTHsByzhS2ggkJ4BxpkERjYAUdmZ9KDOYqz0jdXStAdL2WYoO4TghYGXIcMhULGgfXxYsA2XsA8v25rzHsRPuwZD46CpzhQmugDYqm7K2qPnSSdwBddLr891wYVbCAaYhakERX3aoXxcUfLyaqyaUo7yjn(k7a97YIcMhLzcnR5oWOCpzhQmugDYqm7K2qPnSSdwBddLr82(c1l0nGK8PVo4HkYowsJVYoT9fQxOBajL1ChYi3t2HkdLrNmeZoPnuAdl707aoKPq9qwbmOkFXlQ9lmIVwN9BKObiFainGdHI3A816SFJeXfQLGCaqyaYyasLoGdHI3A816SFJeXxcUfLyaqyaWsNb4odaJgaYzhlPXxzhymlfgZBhSwLOSM7abK7j7qLHYOtgIzN0gkTHLDs)ZoF3IVe8FfeJecF3OuA5lb3Ismaiizayoa3zaWsNbiFaQXOs5WmfkTrbZl0FHZPYqz0j7yjn(k702xOEHUbKuwZDi7Z9KDOYqz0jdXStAdL2WYoyTnmugX3xBj)gWPSJL04RSd0VllkyEuMj0SM7q2K7j7qLHYOtgIzN0gkTHLDw8ks(RVlT8d1IuOdacdaPbCxgdO)bOgJkLV4vK8MQuHBA8fNkdLrNb4odqgda5SJL04RStBFH6f6gqszn3bcuUNSdvgkJoziMDsBO0gw2P3bGI3A82(Dgv(lCMG44xdq(auJrLYB73zu5VWzcItLHYOZaKkDayTnmugXpKPqf(do5TKgyPbiFaO4Tg)qMcv4p4exOwcYbaHbGrdqQ0bOgJkLdZuO0gfmVq)foNkdLrNbiFaO4TgFj4)kigje(UrP0YXVgGuPdyXRi5V(U0YpulsHoG(gasdatzmG(hGAmQu(IxrYBQsfUPXxCQmugDgG7mazmaKZowsJVYopkluAnLYAUJ7Yk3t2XsA8v2PTVq9cDdiPSdvgkJoziM1Ch3VN7j7yjn(k7a93Y)nF3OuAZouzOm6KHywZDChZCpzhlPXxzhBtwrE93Lkn7qLHYOtgIznRzNd1mCMM7j3X9CpzhlPXxzh4rD8TLOoJYouzOm6KHywZDGzUNSdvgkJoziMD(RSJG0SJL04RSdwBddLrzhSgdNYoinacJHhxx0HhLiT4QHYipgd3kfhU)qyJenaPshaHXWJRl6WvOKVfRq9IawWgaYdq(aqAaP)zNVBXJsKwC1qzKhJHBLId3FiSrI4lzh3gGuPdi9p78DlUcL8TyfQxeWcgFj4wuIbG8aKkDaegdpUUOdxHs(wSc1lcybBaYhaHXWJRl6WJsKwC1qzKhJHBLId3FiSrIYohsK24sJVYoyClHLkDaIlkfTGodq3OGKuXaqPOGnaCbDgq3qHoadxF4MgPbWIIezhS26ldoLDexukAbD86gfKKM1ChUo3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzhlPbwYtfbpiXaKmG7dq(aqAaRfhpHLkLBNJGh1a6Ba3LXaKkDa9oG1IJNWsLYTZrWjzgcvmaKZoyT1xgCk7iu)fZQkkyzn3bgL7j7qLHYOtgIzN)k7iin7yjn(k7G12Wqzu2bRXWPSJL0al5PIGhKya9jzayoa5daPb07awloEclvk3ohbNKziuXaKkDaRfhpHLkLBNJGtYmeQyaYhasdyT44jSuPC7Ce8LGBrjgqFdqgdqQ0b0cyqv)sWTOedOVbCxwda5bGC2bRT(YGtzh7Ce(LGBrL1ChYi3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzhu8wJVbCIJFna5daPb07aw8IA)cJ4RbJ8FZRqjFB)oJkFcQb)k(ItLHYOZaKkDalErTFHr81Gr(V5vOKVTFNrLpb1GFfFXPYqz0zaYhWIxrYF9DPLFOwKcDa9nazZaqo7G1wFzWPSZ(Al53aoL1ChiGCpzhQmugDYqm78xzhbPzhlPXxzhS2ggkJYoyngoLDsFDWdLtRDIKPrbZJY(Udq(aqXBnoT2jsMgfmpk77YfQLGCasgaMdqQ0bK(6GhkhVyKjGshFBPQZCJtLHYOZaKpau8wJJxmYeqPJVTu1zUXxcUfLyaqyainayPZaCNbG5aqo7G1wFzWPStBFH6f6gqs(0xh8qfzn3HSp3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzNdzkuVvh)HsMBCnsqgfSbiFaPhlvwP8kGbv9nJYoyT1xgCk7CitHk8hCYBjnWszn3HSj3t2HkdLrNmeZowsJVYolb)xbXiHW3nkL2SZHePnU04RSJ7(6I52aqW2xOdabJWsRldaUfLArna3vYTb0JX(smaRodasIUgqNJG)RGyKqmazNOuAhW(mwuWYoPnuAdl7K(6GhkNWsBBFHoa5dqngvkhMPqPnkyEH(lCovgkJodq(aqAa9oa1yuP8hLfkTMgFXPYqz0zaYhq6F257w8RGXS1)nFBFHYxcUfLyasLoabPE0VWfCnOftzJhJUsdq(auJrLYFuwO0AA8fNkdLrNbiFa9oau8wJFfmMT(V5B7luo(1aqoR5oqGY9KDOYqz0jdXSJL04RSd0VllkyEuMj0StAdL2WYo9oGZR82(c13iS0YxcUfLyaYhasdqngvkpsuYU4uzOm6maPshqVdafV14Olzku)38IOoRb7fgh)AaYhGAmQuo6sMc1)nViQZAWEHXPYqz0zasLoa1yuP8hLfkTMgFXPYqz0zaYhq6F257w8RGXS1)nFBFHYxcUfLyaYhqVdafV14qgmwuW8WTe0Oio(1aqo7KClXiVAlmsf5oUN1Ch3LvUNSdvgkJoziMDsBO0gw2bfV14rYnVASVe8LGBrjgaeKmayPZaCNbG5aKpa1yuP8i5Mxn2xcovgkJodq(aexeJ5vBHrQGdJzPWyE7G1QenG(KmamhG8bG0auJrLYJeLSlovgkJodqQ0bOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bK(ND(UfhDjtH6)Mxe1znyVW4lb3IsmG(gWDzmaPshGAmQu(JYcLwtJV4uzOm6ma5dO3bGI3A8RGXS1)nFBFHYXVgaYzhlPXxzhymlfgZBhSwLOSM74(9CpzhQmugDYqm7K2qPnSSdkERXJKBE1yFj4lb3IsmaiizaWsNb4odaZbiFaQXOs5rYnVASVeCQmugDgG8bG0auJrLYJeLSlovgkJodqQ0bOgJkLJUKPq9FZlI6SgSxyCQmugDgG8b07aqXBno6sMc1)nViQZAWEHXXVgG8bK(ND(UfhDjtH6)Mxe1znyVW4lb3IsmG(gWDznaPshGAmQu(JYcLwtJV4uzOm6ma5dO3bGI3A8RGXS1)nFBFHYXVgaYzhlPXxzN2(c1l0nGKYAUJ7yM7j7qLHYOtgIzN0gkTHLDspwQSs5vadQ6Bgna5d4qMc1B1XFOK5gxJeKrbBaYhWHmfQ3QJ)qjZnUL0al5xcUfLyaqyainayPZaCNbCNlJbG8aKpaKgqVdqngvk)rzHsRPXxCQmugDgGuPdqngvk)rzHsRPXxCQmugDgG8b07aqXBn(vWy26)MVTVq54xda5SJL04RSZJYcLwtPSM74URZ9KDOYqz0jdXSZHePnU04RSJRG(VGgG7oPXxdGfcDa6pGfVYowsJVYojJX8wsJV8SqOzhwiuFzWPSt6XsLvQiR5oUJr5EYouzOm6KHy2XsA8v2jzmM3sA8LNfcn7WcH6ldoLDwlfgtK1Ch3LrUNSdvgkJoziMDSKgFLDsgJ5TKgF5zHqZoSqO(YGtzhDJcssfzn3XDeqUNSdvgkJoziMDSKgFLDsgJ5TKgF5zHqZoSqO(YGtzN0)SZ3Tezn3XDzFUNSdvgkJoziMDsBO0gw2rngvkp9SJhkzRYPYqz0zaYhasdO3bGI3ACidglkyE4wcAueh)AasLoa1yuPC0LmfQ)BEruN1G9cJtLHYOZaqEaYhasd4qO4TgFTo73irCHAjihGKbiJbiv6a6DahYuOEiRaguLV4f1(fgXxRZ(ns0aqo7i0nsAUJ7zhlPXxzNKXyElPXxEwi0SdleQVm4u2j9SJhkzRM1Ch3Ln5EYouzOm6KHy2jTHsByzhu8wJJUKPq9FZlI6SgSxyC8RSJq3iP5oUNDSKgFLDw8YBjn(YZcHMDyHq9LbNYoOVWRrcYOGL1Ch3rGY9KDOYqz0jdXStAdL2WYoQXOs5Olzku)38IOoRb7fgNkdLrNbiFainG0)SZ3T4Olzku)38IOoRb7fgFj4wuIbaHbCxwda5biFainG1IJNWsLYTZrWJAa9namLXaKkDa9oG1IJNWsLYTZrWjzgcvmaPshq6F257w8RGXS1)nFBFHYxcUfLyaqya3L1aKpG1IJNWsLYTZrWjzgcvma5dyT44jSuPC7Ce8OgaegWDznaKZowsJVYolE5TKgF5zHqZoSqO(YGtzh0x4V(NffSSM7atzL7j7qLHYOtgIzN0gkTHLDqXBn(vWy26)MVTVq54xdq(auJrLYFuwO0AA8fNkdLrNSJq3iP5oUNDSKgFLDw8YBjn(YZcHMDyHq9LbNYopkluAnn(kR5oW8EUNSdvgkJoziMDsBO0gw2P3bii1J(fUGRbTykB8y0vAaYhqVdyXlQ9lmIVgmY)nVcL8T97mQ8jOg8R4lovgkJodq(auJrLYFuwO0AA8fNkdLrNbiFaP)zNVBXVcgZw)38T9fkFj4wuIbaHbCxwdq(aqAayTnmugXfQ)IzvffSbiv6awloEclvk3ohbNKziuXaKpG1IJNWsLYTZrWJAaqya3L1aKkDa9oG1IJNWsLYTZrWjzgcvmaKZowsJVYolE5TKgF5zHqZoSqO(YGtzNhLfkTMgF5V(NffSSM7atmZ9KDOYqz0jdXStAdL2WYowsdSKNkcEqIb0NKbGz2rOBK0Ch3ZowsJVYolE5TKgF5zHqZoSqO(YGtzh7PSM7atxN7j7qLHYOtgIzhlPXxzNKXyElPXxEwi0SdleQVm4u2rOwDS9K1SMDs)ZoF3sK7j3X9CpzhQmugDYqm7K2qPnSSdkERXVcgZw)38T9fkh)k7CirAJln(k7GX9A8v2XsA8v25614RSM7aZCpzhQmugDYqm7yjn(k7qWV(U06x8I8Dj76RSZHePnU04RSJR(ND(ULi7K2qPnSSJAmQu(JYcLwtJV4uzOm6ma5dyXlAaqyaiGbiFainaS2ggkJ4c1FXSQIc2aKkDayTnmugXTZr4xcUf1aqEaYhasdi9p78Dl(vWy26)MVTVq5lb3Ismaimazma5daPbK(ND(UfVXib00AnLVeClkXa6BaYyaYhG4XzOrD4x4cfNrEAXV04lovgkJodqQ0b07aepodnQd)cxO4mYtl(LgFXPYqz0zaipaPshakERXVcgZw)38T9fkh)AaipaPsha6ledq(aAbmOQFj4wuIbaHbGPSYAUdxN7j7qLHYOtgIzN0gkTHLDuJrLYrxYuO(V5frDwd2lmovgkJodq(aw8IgaegGmgG8bS4vK8xFxAhaegasdabiRbGXpGdzkupKvadQYx8IA)cJ4qDtO0g2aCNbiJbGXpGfVO2VWi(AWVSs96ALOrlvjItLHYOZaCNbiJbG8aKpaKgakERXrxYuO(V5frDwd2lmo(1aKkDaTagu1VeClkXaGWaWuwda5SJL04RSdb)67sRFXlY3LSRVYAUdmk3t2HkdLrNmeZoPnuAdl7OgJkLhjkzxCQmugDYowsJVYoe8RVlT(fViFxYU(kR5oKrUNSdvgkJoziMDsBO0gw2rngvkhDjtH6)Mxe1znyVW4uzOm6ma5daPbG12WqzexO(lMvvuWgGuPdaRTHHYiUDoc)sWTOgaYdq(aqAaP)zNVBXrxYuO(V5frDwd2lm(sWTOedqQ0bK(ND(UfhDjtH6)Mxe1znyVW4lzh3gG8bS4vK8xFxAhqFdabiJbGC2XsA8v25kymB9FZ32xOzn3bci3t2HkdLrNmeZoPnuAdl7OgJkLhjkzxCQmugDgG8b07aqXBn(vWy26)MVTVq54xzhlPXxzNRGXS1)nFBFHM1ChY(CpzhQmugDYqm7K2qPnSSJAmQu(JYcLwtJV4uzOm6ma5daPbS4vK8xFxAhqFsgGRLXaKpGEhakERXn0hEuMgF5zbCuo(1aKkDaO4Tg3qF4rzA8LNfWr54xdqQ0bS4f1(fgXxdg5)MxHs(2(Dgv(eud(v8fNkdLrNbG8aKpaKgawBddLrCH6VywvrbBasLoaS2ggkJ425i8lb3IAaipa5daPbOgJkLdZuO0gfmVq)foNkdLrNbiFaO4TgFj4)kigje(UrP0YXVgGuPdO3bOgJkLdZuO0gfmVq)foNkdLrNbGC2XsA8v25kymB9FZ32xOzn3HSj3t2HkdLrNmeZoPnuAdl7GI3A8RGXS1)nFBFHYXVYowsJVYoOlzku)38IOoRb7fwwZDGaL7j7qLHYOtgIzN0gkTHLDSKgyjpve8GedqYaUpa5dafV14xbJzR)B(2(cLVeClkXaGWaGLodq(aqXBn(vWy26)MVTVq54xdq(a6DaQXOs5pkluAnn(ItLHYOZaKpaKgqVdyT44jSuPC7CeCsMHqfdqQ0bSwC8ewQuUDocEudOVb4AznaKhGuPdOfWGQ(LGBrjgaegGRZowsJVYoT9fAx3w4cFdFDlR5oUlRCpzhQmugDYqm7K2qPnSSJL0al5PIGhKya9jzayoa5daPbGI3A8RGXS1)nFBFHYXVgGuPdyT44jSuPC7CeCsMHqfdq(awloEclvk3ohbpQb03as)ZoF3IFfmMT(V5B7lu(sWTOedO)bi7haYdq(aqAaO4Tg)kymB9FZ32xO8LGBrjgaegaS0zasLoG1IJNWsLYTZrWjzgcvma5dyT44jSuPC7Ce8LGBrjgaegaS0zaiNDSKgFLDA7l0UUTWf(g(6wwZDC)EUNSdvgkJoziMDsBO0gw2rngvk)rzHsRPXxCQmugDgG8bG0aqXBn(vWy26)MVTVq54xdq(a6DaWTO8qT6WXe6aKkDa9oau8wJFfmMT(V5B7luo(1aKpa4wuEOwD4ycDaYhq6F257w8RGXS1)nFBFHYxcUfLyaipa5daPbG0aqXBn(vWy26)MVTVq5lb3IsmaimayPZaKkDaO4TghVG(m38cDPcMcLJFna5dafV144f0N5MxOlvWuO8LGBrjgaegaS0zaipa5daPbCiu8wJVwN9BKiUqTeKdqYaKXaKkDa9oGdzkupKvadQYx8IA)cJ4R1z)gjAaipaKZowsJVYoT9fAx3w4cFdFDlR5oUJzUNSdvgkJoziMDsBO0gw2rngvkhDjtH6)Mxe1znyVW4uzOm6ma5dyXRi5V(U0oaimaeGSgG8bS4fnaiizaUEaYhasdafV14Olzku)38IOoRb7fgh)AasLoG0)SZ3T4Olzku)38IOoRb7fgFj4wuIb03aWiznaKhGuPdO3bOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bS4vK8xFxAhaeKmazVmYowsJVYoqD76vO0cps(RLeuLOSM74URZ9KDOYqz0jdXStAdL2WYoP)zNVBXVcgZw)38T9fkFj4wuIbabjdqgzhlPXxzN1cb5pKDYAUJ7yuUNSdvgkJoziMDsBO0gw2XsAGL8urWdsmG(KmamhG8bG0aAbmOQFj4wuIbaHb46biv6a6DaO4TghDjtH6)Mxe1znyVW44xdq(aqAaxKYHb9Xz8LGBrjgaegaS0zasLoG1IJNWsLYTZrWjzgcvma5dyT44jSuPC7Ce8LGBrjgaegGRhG8bSwC8ewQuUDocEudOVbCrkhg0hNXxcUfLyaipaKZowsJVYoclTrlsHX8xwsZAUJ7Yi3t2HkdLrNmeZoPnuAdl7yjnWsEQi4bjgqFdqgdqQ0bS4f1(fgXVGs2(W)IeCQmugDYowsJVYohYuOERo(dLm3YAwZoPhlvwPICp5oUN7j7qLHYOtgIzhlPXxzNdzkuH)GtzNdjsBCPXxzhx9yPYkDaUB0GfAqIStAdL2WYoinGEhGAmQu(JYcLwtJV4uzOm6maPshGAmQu(JYcLwtJV4uzOm6ma5dWsAGL8urWdsmG(KmamhG8bK(ND(Uf)kymB9FZ32xO8LGBrjgGuPdWsAGL8urWdsmajd4(aqEaYhasdaRTHHYiUq9xmRQOGnaPshawBddLrC7Ce(LGBrnaKZAUdmZ9KDOYqz0jdXStAdL2WYolEfj)13Lw(HArk0b03aU76biFaP)zNVBXVcgZw)38T9fkFj4wuIbaHb46biFa9oa1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaS2ggkJ4c1FXSQIcw2XsA8v2r01w4rbZdpeAwZD46CpzhQmugDYqm7K2qPnSStVdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5daRTHHYiUDoc)sWTOYowsJVYoIU2cpkyE4HqZAUdmk3t2HkdLrNmeZoPnuAdl7OgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG0aqXBno6sMc1)nViQZAWEHXXVgG8bG0aWAByOmIlu)fZQkkydq(aw8ks(RVlT8d1IuOdOVbGrYAasLoaS2ggkJ425i8lb3IAaYhWIxrYF9DPLFOwKcDa9naeGSgGuPdaRTHHYiUDoc)sWTOgG8bSwC8ewQuUDoc(sWTOedacdabAaYhWAXXtyPs525i4KmdHkgaYdqQ0b07aqXBno6sMc1)nViQZAWEHXXVgG8bK(ND(UfhDjtH6)Mxe1znyVW4lb3IsmaKZowsJVYoIU2cpkyE4HqZAUdzK7j7qLHYOtgIzN0gkTHLDs)ZoF3IFfmMT(V5B7lu(sWTOedacdaw6ma3zayoa5daRTHHYiUq9xmRQOGna5daPbOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bS4vK8xFxAhqFdabiJbiFaP)zNVBXrxYuO(V5frDwd2lm(sWTOedacdaZbiv6a6DaQXOs5Olzku)38IOoRb7fgNkdLrNbGC2XsA8v2XqF4rzA8LNfWrZAUdeqUNSdvgkJoziMDsBO0gw2bRTHHYiUDoc)sWTOYowsJVYog6dpktJV8SaoAwZDi7Z9KDOYqz0jdXStAdL2WYoyTnmugXfQ)IzvffSbiFainG0)SZ3T4xbJzR)B(2(cLVeClkXaGWaC9aKkDaQXOs5rIs2fNkdLrNbGC2XsA8v2ra1sqYiVcL84v3FvOUL1ChYMCpzhQmugDYqm7K2qPnSSdwBddLrC7Ce(LGBrLDSKgFLDeqTeKmYRqjpE19xfQBzn3bcuUNSdvgkJoziMDsBO0gw2P3bGI3A8RGXS1)nFBFHYXVgG8bG0aepodnQd)cxO4mYtl(LgFXPYqz0zasLoaXJZqJ6WX(mtdg5fpdlvkNkdLrNbiFa9oau8wJJ9zMgmYlEgwQuo(1aqo7eLs7IFP(OLDepodnQdh7ZmnyKx8mSuPzNOuAx8l1hWHtNWuk7Cp7yjn(k70yKaAATMMDIsPDXVupm2JASSZ9SM1SZ1sPhoQP5EYDCp3t2HkdLrNmeZo)v2rqA0YoPnuAdl7OBuqskxVZHAcpUG8O4T2aKpaKgqVdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5daPbOBuqskxVZt)ZoF3IFWxtJVgGSDaP)zNVBXVcgZw)38T9fk)GVMgFnajdqwda5biv6auJrLYrxYuO(V5frDwd2lmovgkJodq(aqAaP)zNVBXrxYuO(V5frDwd2lm(bFnn(AaY2bOBuqskxVZt)ZoF3IFWxtJVgGKbiRbG8aKkDaQXOs5rIs2fNkdLrNbGC25qI0gxA8v2bbhRXWnLedWgGUrbjPIbK(ND(ULld4eyJdDgaQBd4kymBhW3gqBFHoGFha6sMcDaFBaIOoRb7f2nXas)ZoF3Ipa3vBaHEtmaSgdNgautmG6hWsWTOo0oGLu8TgWDxgaXe0awsX3AaYIldE2bRT(YGtzhDJcss939c3Qu2XsA8v2bRTHHYOSdwJHtEIjOSJS4Yi7G1y4u25EwZDGzUNSdvgkJoziMD(RSJG0OLDSKgFLDWAByOmk7G1wFzWPSJUrbjPEm9c3Qu2jTHsByzhDJcss5kMCOMWJlipkERna5daPb07auJrLYrxYuO(V5frDwd2lmovgkJodq(aqAa6gfKKYvm5P)zNVBXp4RPXxdq2oG0)SZ3T4xbJzR)B(2(cLFWxtJVgGKbiRbG8aKkDaQXOs5Olzku)38IOoRb7fgNkdLrNbiFainG0)SZ3T4Olzku)38IOoRb7fg)GVMgFnaz7a0nkijLRyYt)ZoF3IFWxtJVgGKbiRbG8aKkDaQXOs5rIs2fNkdLrNbGC2bRXWjpXeu2rwCzKDWAmCk7CpR5oCDUNSdvgkJoziMD(RSJG0OLDsBO0gw2P3bOBuqskxVZHAcpUG8O4T2aKpaDJcss5kMCOMWJlipkERnaPshGUrbjPCftout4XfKhfV1gG8bG0aqAa6gfKKYvm5P)zNVBXp4RPXxdaHdq3OGKuUIjhfV18h8104RbG8aCNbG0aUZLXa6Fa6gfKKYvm5qnHhfV14cDPcMcDaipa3zainaS2ggkJ46gfKK6X0lCRsda5bG8a6BainaKgGUrbjPC9op9p78Dl(bFnn(AaiCa6gfKKY17Cu8wZFWxtJVgaYdWDgasd4oxgdO)bOBuqskxVZHAcpkERXf6sfmf6aqEaUZaqAayTnmugX1nkij1F3lCRsda5bGC25qI0gxA8v2bbxObCtjXaSbOBuqsQyayngonau3gq6HFzBuWgGcLgq6F257wd4BdqHsdq3OGKuxgWjWgh6mau3gGcLgWbFnn(AaFBakuAaO4T2acDax7JnoKGpGoFMya2ae6sfmf6aG)NOf0oa9haSalnaBaqdyqPDaxB8BOUna9hGqxQGPqhGUrbjPcxgGjgqxIXgGjgGna4)jAbTdO97aI2aSbOBuqs6a6gm2a(DaDdgBa1Rdq4wLgq3qHoG0)SZ3Te8SdwB9LbNYo6gfKK6V243qDl7yjn(k7G12Wqzu2bRXWjpXeu25E2bRXWPSdMzn3bgL7j7qLHYOtgIzN)k7iin7yjn(k7G12Wqzu2bRXWPSJAmQuomtHsBuW8c9x4CQmugDgGuPdi91bpuoHL22(cLtLHYOZaKkDalErTFHrC0qJcMp9SdNkdLrNSdwB9LbNYoBxpkERjYAUdzK7j7yjn(k70yKaAATMMDOYqz0jdXSM1SZAPWyICp5oUN7j7qLHYOtgIzhlPXxzhu2)hFdFDl7CirAJln(k705SuySb4UrdwObjYoPnuAdl7GI3A8RGXS1)nFBFHYXVYAUdmZ9KDOYqz0jdXStAdL2WYoO4Tg)kymB9FZ32xOC8RSJL04RSdkTcAHmkyzn3HRZ9KDOYqz0jdXStAdL2WYoinGEhakERXVcgZw)38T9fkh)AaYhGL0al5PIGhKya9jzayoaKhGuPdO3bGI3A8RGXS1)nFBFHYXVgG8bG0aw8I4hQfPqhqFsgGmgG8bS4vK8xFxA5hQfPqhqFsgacqwda5SJL04RSJTjRi)fotqzn3bgL7j7qLHYOtgIzN0gkTHLDqXBn(vWy26)MVTVq54xzhlPXxzhwadQk8YUJFGbNknR5oKrUNSdvgkJoziMDsBO0gw2bfV14xbJzR)B(2(cLJFna5dafV14e8RVlT(fViFxYU(IJFLDSKgFLDSkrcDnMpzmwwZDGaY9KDOYqz0jdXStAdL2WYoO4Tg)kymB9FZ32xO8LGBrjgaeKmazZaKpau8wJFfmMT(V5B7luo(1aKpau8wJtWV(U06x8I8Dj76lo(v2XsA8v2PflHY()K1ChY(CpzhQmugDYqm7K2qPnSSdkERXVcgZw)38T9fkh)AaYhGL0al5PIGhKyasgW9biFainau8wJFfmMT(V5B7lu(sWTOedacdqgdq(auJrLYtp74Hs2QCQmugDgGuPdO3bOgJkLNE2XdLSv5uzOm6ma5dafV14xbJzR)B(2(cLVeClkXaGWaC9aqo7yjn(k7GAW8FZRBKGuK1SMD0nkijvK7j3X9CpzhQmugDYqm7CirAJln(k70ZgfKKkYoLbNYorjslUAOmYJXWTsXH7pe2irzN0gkTHLD6DaQXOs5Olzku)38IOoRb7fgNkdLrNbiFaO4Tg)kymB9FZ32xOC8RbiFaO4TgNGF9DP1V4f57s21xC8Rbiv6auJrLYrxYuO(V5frDwd2lmovgkJodq(aqAainau8wJFfmMT(V5B7luo(1aKpG0)SZ3T4Olzku)38IOoRb7fgFj742aqEasLoaKgakERXVcgZw)38T9fkh)AaYhasdaPb0cyqv)sWTOedaJFaP)zNVBXrxYuO(V5frDwd2lm(sWTOeda5baHbG59bG8aqEaipaPsha6ledq(aAbmOQFj4wuIbaHbG59biv6aoKPq9qwbmOk)ecdLr(aJD8KmPeUsdqYaK1aKpa1wyKY1ao513FLupMYAaqyaYi7yjn(k7eLiT4QHYipgd3kfhU)qyJeL1ChyM7j7qLHYOtgIzNYGtzhygwI5)MxHs(wSc1BlAO0MDSKgFLDGzyjM)BEfk5BXkuVTOHsBwZD46CpzhQmugDYqm7ugCk7is2k8FZ3wtPTmMxOB0OSJL04RSJizRW)nFBnL2YyEHUrJYAUdmk3t2HkdLrNmeZowsJVYokuY3IvOEralyzN0gkTHLDqXBn(vWy26)MVTVq54xdq(aqXBnob)67sRFXlY3LSRV44xzNYGtzhfk5BXkuViGfSSM7qg5EYouzOm6KHy2XsA8v2r3OGK07zNdjsBCPXxzNEGsdq3OGK0b0nuOdqHsdaAadkj0bqcnGBkDgawJHtUmGUbJnauAa4c6mGwScDawDgWLflDgq3qHoamUGXSDaFBaiy7luE2jTHsByzNEhawBddLrCXfLIwqhVUrbjPdq(aqXBn(vWy26)MVTVq54xdq(aqAa9oa1yuP8irj7ItLHYOZaKkDaQXOs5rIs2fNkdLrNbiFaO4Tg)kymB9FZ32xO8LGBrjgqFsgWDznaKhG8bG0a6Da6gfKKYvm5qnHp9p78DRbiv6a0nkijLRyYt)ZoF3IVeClkXaKkDayTnmugX1nkij1FTXVH62aKmG7da5biv6a0nkijLR35O4TM)GVMgFnG(KmGwadQ6xcUfLiR5oqa5EYouzOm6KHy2jTHsByzNEhawBddLrCXfLIwqhVUrbjPdq(aqXBn(vWy26)MVTVq54xdq(aqAa9oa1yuP8irj7ItLHYOZaKkDaQXOs5rIs2fNkdLrNbiFaO4Tg)kymB9FZ32xO8LGBrjgqFsgWDznaKhG8bG0a6Da6gfKKY17COMWN(ND(U1aKkDa6gfKKY1780)SZ3T4lb3IsmaPshawBddLrCDJcss9xB8BOUnajdaZbG8aKkDa6gfKKYvm5O4TM)GVMgFnG(KmGwadQ6xcUfLi7yjn(k7OBuqskMzn3HSp3t2HkdLrNmeZowsJVYo6gfKKEp7iyVMD0nkij9E2jTHsByzNEhawBddLrCXfLIwqhVUrbjPdq(aqAa9oaDJcss56Dout4XfKhfV1gG8bG0a0nkijLRyYt)ZoF3IVeClkXaKkDa9oaDJcss5kMCOMWJlipkERnaKhGuPdi9p78Dl(vWy26)MVTVq5lb3IsmG(gaMYAaiNDoKiTXLgFLDCxTb8fZTb8fnGVgaUGgGUrbjPd4AFSXHedWgakER5YaWf0auO0aEfkTd4RbK(ND(UfFaiW7aI2akkuO0oaDJcsshW1(yJdjgGnau8wZLbGlObG(k0b81as)ZoF3IN1ChYMCpzhQmugDYqm7yjn(k7OBuqskMzN0gkTHLD6DayTnmugXfxukAbD86gfKKoa5daPb07a0nkijLRyYHAcpUG8O4T2aKpaKgGUrbjPC9op9p78Dl(sWTOedqQ0b07a0nkijLR35qnHhxqEu8wBaipaPshq6F257w8RGXS1)nFBFHYxcUfLya9namL1aqo7iyVMD0nkijfZSM1Sd6l8x)ZIcwUNCh3Z9KDOYqz0jdXSJL04RSZsW)vqmsi8DJsPn7CirAJln(k7aXLmf6a(2aCI6SgSxyd46FwuWgW(QPXxdW9dqO2QIbCxwIbGsTFPbaX3zaHyagwlygkJYoPnuAdl7yjnWsEQi4bjgqFsgaMdqQ0bG12WqzeF76rXBnrwZDGzUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2bfV14qgmwuW8WTe0Oi(swshG8bK(ND(Uf)kymB9FZ32xO8LGBrjgqFdW1zNKBjg5vBHrQi3X9SM7W15EYouzOm6KHy2jTHsByzhS2ggkJ47RTKFd4u2XsA8v2b63LffmpkZeAwZDGr5EYouzOm6KHy2jTHsByzhu8wJdzWyrbZd3sqJI4lzjDaYhWIxrYF9DPLFOwKcDa9naKgWDzmG(hGAmQu(IxrYBQsfUPXxCQmugDgG7mazmaKhG8biUigZR2cJubVTVqfj3uO0a6Bayoa5dO3bG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5McLYAUdzK7j7qLHYOtgIzN0gkTHLDw8ks(RVlT8d1IuOdOpjdaPb4AzmG(hGAmQu(IxrYBQsfUPXxCQmugDgG7mazmaKhG8biUigZR2cJubVTVqfj3uO0a6Bayoa5dO3bG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5McLYAUdeqUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2zXRi5V(U0YpulsHoG(KmamLr2j5wIrE1wyKkYDCpR5oK95EYouzOm6KHy2jTHsByzNfVIK)67sl)qTif6aGWaWuwdq(aexeJ5vBHrQGdJzPWyE7G1QenG(KmamhG8bK(ND(Uf)kymB9FZ32xO8LGBrjgqFdqgzhlPXxzhymlfgZBhSwLOSM7q2K7j7qLHYOtgIzhlPXxzN2(c1l0nGKYoPnuAdl7S4vK8xFxA5hQfPqhaegaMYAaYhq6F257w8RGXS1)nFBFHYxcUfLya9nazKDsULyKxTfgPICh3ZAUdeOCpzhQmugDYqm7K2qPnSSt6F257w8RGXS1)nFBFHYxcUfLya9nGfViUgWjV(EmAaYhWIxrYF9DPLFOwKcDaqyayKSgG8biUigZR2cJubhgZsHX82bRvjAa9jzayMDSKgFLDGXSuymVDWAvIYAUJ7Yk3t2HkdLrNmeZowsJVYoT9fQxOBajLDsBO0gw2j9p78Dl(vWy26)MVTVq5lb3IsmG(gWIxexd4KxFpgna5dyXRi5V(U0YpulsHoaimamswzNKBjg5vBHrQi3X9SM1SJ9uUNCh3Z9KDOYqz0jdXSZHePnU04RSJ7(rWhqN7vtJVYowsJVYolb)xbXiHW3nkL2SM7aZCpzhQmugDYqm7K2qPnSSJAmQuEBFHksUPqjovgkJozhlPXxzhymlfgZBhSwLOSM7W15EYouzOm6KHy2jTHsByzhu8wJdzWyrbZd3sqJI4lzjDaYhqVdaRTHHYi(HmfQWFWjVL0alLDSKgFLDA7lurYnfkL1ChyuUNSdvgkJoziMDsBO0gw2bRTHHYi((Al53aona5dqngvk3WAmRsqjovgkJozhlPXxzhOFxwuW8OmtOzn3HmY9KDOYqz0jdXStAdL2WYo9oau8wJVbCIJFna5dWsAGL8urWdsmaiizaUEasLoalPbwYtfbpiXa6BaUo7yjn(k7aJzPWyE7G1QeL1ChiGCpzhQmugDYqm7yjn(k702xOEHUbKu2j5wIrE1wyKkYDCp7K2qPnSSt6F257w8LG)RGyKq47gLslFj4wuIbabjdaZb4odaw6ma5dqngvkhMPqPnkyEH(lCovgkJozNdjsBCPXxzheSFHJZSina76AFlbDa6pG0sMsdWgWLGWp)aU243qDBaQTWiDaSqOdO97aSRlMBrbBaR1z)gjAarna7PSM7q2N7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nGtzhlPXxzhOFxwuW8OmtOzn3HSj3t2HkdLrNmeZoPnuAdl7OgJkLdZuO0gfmVq)foNkdLrNbiFaO4TgFj4)kigje(UrP0YXVgG8byjnWsEQi4bjgqFdaZbiFa9oaS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfj3uOuwZDGaL7j7qLHYOtgIzN0gkTHLDWAByOmIFitHk8hCYBjnWsdq(aqXBn(HmfQWFWjUqTeKdacdaJgGuPdqngvkhMPqPnkyEH(lCovgkJodq(aqXBn(sW)vqmsi8DJsPLJFLDSKgFLDEuwO0AkL1Ch3LvUNSdvgkJoziMDSKgFLDA7luVq3ask7K2qPnSSZIxrYF9DPLFOwKcDaqyainG7Yya9pa1yuP8fVIK3uLkCtJV4uzOm6ma3zaYyaiNDsULyKxTfgPICh3ZAUJ73Z9KDOYqz0jdXStAdL2WYo9oaS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfj3uOuwZDChZCpzhQmugDYqm7yjn(k78OSqP1uk7K2qPnSSZIxrYF9DPLFOwKcDa9naKgaMYya9pa1yuP8fVIK3uLkCtJV4uzOm6ma3zaYyaiNDsULyKxTfgPICh3ZAUJ7Uo3t2XsA8v2bgZsHX82bRvjk7qLHYOtgIzn3XDmk3t2XsA8v2PTVqfj3uOu2HkdLrNmeZAUJ7Yi3t2HkdLrNmeZowsJVYoT9fQxOBajLDsULyKxTfgPICh3ZAUJ7iGCpzhlPXxzhO)w(V57gLsB2HkdLrNmeZAUJ7Y(CpzhlPXxzhBtwrE93Lkn7qLHYOtgIznRzn7GLwr8vUdmLfMyklxFhbk7012kkyISJSJ7UZ1H7QJop3pGb0duAab8RF1b0(Da3EuwO0AA8L)6FwuWUnGLWy4XsNbiE40amC9HBkDgqcQvWibFqStrrdat3pax9fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdW0bGGJa3PbG0DzImFqCqu2XD356WD1rNN7hWa6bknGa(1V6aA)oGBPND8qjB1BdyjmgES0zaIhonadxF4MsNbKGAfmsWhe7uu0aU7(b4QVWsRsNbCBXlQ9lmIJHBdq)bCBXlQ9lmIJbovgkJo3gasyKmrMpi2POObGP7hGR(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFqStrrdW1UFaU6lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8bXoffnamY9dWvFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aq6UmrMpi2POObid3pax9fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdaP7Yez(G4GOSJ7UZ1H7QJop3pGb0duAab8RF1b0(Da3EuwO0AA81TbSegdpw6maXdNgGHRpCtPZasqTcgj4dIDkkAay6(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiDxMiZhe7uu0aW09dWvFHLwLod4w6RdEOCmCBa6pGBPVo4HYXaNkdLrNBdaP7Yez(GyNIIgWDz5(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiHPmrMpioik74U7CD4U6OZZ9dya9aLgqa)6xDaTFhWn0x41ibzuWUnGLWy4XsNbiE40amC9HBkDgqcQvWibFqStrrd4U7hGR(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFqStrrdat3pax9fwAv6maNaURgGWTsnzoaz7a0FaDc3gWjWgI4Rb8x0A6VdajeI8aq6UmrMpi2POOb4A3pax9fwAv6maNaURgGWTsnzoaz7a0FaDc3gWjWgI4Rb8x0A6VdajeI8aq6UmrMpi2POObGrUFaU6lS0Q0zaobCxnaHBLAYCaY2bO)a6eUnGtGneXxd4VO10Fhasie5bG0DzImFqStrrdaJC)aC1xyPvPZaUT4f1(fgXXWTbO)aUT4f1(fgXXaNkdLrNBdaP7Yez(G4GOSJ7UZ1H7QJop3pGb0duAab8RF1b0(Da3spwQSsf3gWsym8yPZaepCAagU(WnLodib1kyKGpi2POObC39dWvFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aqctzImFqStrrdat3pax9fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdaP7Yez(GyNIIgGRD)aC1xyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnaKUltK5dIDkkAayK7hGR(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFqStrrdqgUFaU6lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gasyktK5dIDkkAaYE3pax9fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdaP7Yez(GyNIIgacK7hGR(clTkDgWnXJZqJ6WXWTbO)aUjECgAuhog4uzOm6CBaiHPmrMpioik74U7CD4U6OZZ9dya9aLgqa)6xDaTFhWnHA1X2ZTbSegdpw6maXdNgGHRpCtPZasqTcgj4dIDkkAaia3pax9fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdW0bGGJa3PbG0DzImFqStrrdq24(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiDxMiZhe7uu0aqGC)aC1xyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnaKCTmrMpioik74U7CD4U6OZZ9dya9aLgqa)6xDaTFhWn0x4V(NffSBdyjmgES0zaIhonadxF4MsNbKGAfmsWhe7uu0aWi3pax9fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdaP7Yez(GyNIIgGmC)aC1xyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnaKUltK5dIdIYoU7oxhURo68C)agqpqPbeWV(vhq73bC7AP0dh10BdyjmgES0zaIhonadxF4MsNbKGAfmsWhe7uu0aU7(b4QVWsRsNb4eWD1aeUvQjZbiBLTdq)b0jCBaW)dodxmG)Iwt)DaijBrEaiHPmrMpi2POObC39dWvFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aqY1Yez(GyNIIgWD3pax9fwAv6mGB6gfKKYVZXWTbO)aUPBuqskxVZXWTbGKRLjY8bXoffnamD)aC1xyPvPZaCc4UAac3k1K5aKTY2bO)a6eUna4)bNHlgWFrRP)oaKKTipaKWuMiZhe7uu0aW09dWvFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aqY1Yez(GyNIIgaMUFaU6lS0Q0za30nkijLJjhd3gG(d4MUrbjPCftogUnaKCTmrMpi2POOb4A3pax9fwAv6maNaURgGWTsnzoaz7a0FaDc3gWjWgI4Rb8x0A6VdajeI8aqctzImFqStrrdW1UFaU6lS0Q0za30nkijLFNJHBdq)bCt3OGKuUENJHBdajmsMiZhe7uu0aCT7hGR(clTkDgWnDJcss5yYXWTbO)aUPBuqskxXKJHBdajzitK5dIDkkAayK7hGR(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFqStrrdaJC)aC1xyPvPZaUT4f1(fgXXWTbO)aUT4f1(fgXXaNkdLrNBdW0bGGJa3PbG0DzImFqStrrdaJC)aC1xyPvPZaUL(6Ghkhd3gG(d4w6RdEOCmWPYqz052aq6UmrMpioik74U7CD4U6OZZ9dya9aLgqa)6xDaTFhWT0)SZ3Te3gWsym8yPZaepCAagU(WnLodib1kyKGpi2POObGP7hGR(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFqStrrdat3pax9fwAv6mGBIhNHg1HJHBdq)bCt84m0OoCmWPYqz052aqctzImFqStrrdW1UFaU6lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8bXoffnax7(b4QVWsRsNbCBXlQ9lmIJHBdq)bCBXlQ9lmIJbovgkJo3gas3LjY8bXoffnamY9dWvFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052amDai4iWDAaiDxMiZhe7uu0aKH7hGR(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFqStrrdab4(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiDxMiZhe7uu0aK9UFaU6lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8bXoffnazV7hGR(clTkDgWTfVO2VWiogUna9hWTfVO2VWiog4uzOm6CBaiDxMiZhe7uu0aqGC)aC1xyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnaKUltK5dIDkkAa3V7(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiDxMiZhe7uu0aUJP7hGR(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbGeMYez(GyNIIgWDz4(b4QVWsRsNbCBXlQ9lmIJHBdq)bCBXlQ9lmIJbovgkJo3gGPdabhbUtdaP7Yez(G4GOSJ7UZ1H7QJop3pGb0duAab8RF1b0(Da30nkijvCBalHXWJLodq8WPby46d3u6mGeuRGrc(GyNIIgWD3pax9fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdajmLjY8bXoffnaz4(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiHPmrMpi2POObid3pax9fwAv6mGB6gfKKYVZXWTbO)aUPBuqskxVZXWTbG0DzImFqStrrdqgUFaU6lS0Q0za30nkijLJjhd3gG(d4MUrbjPCftogUnaKWuMiZhe7uu0aqaUFaU6lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gasyktK5dIDkkAaia3pax9fwAv6mGB6gfKKYVZXWTbO)aUPBuqskxVZXWTbGeMYez(GyNIIgacW9dWvFHLwLod4MUrbjPCm5y42a0Fa30nkijLRyYXWTbG0DzImFqStrrdq27(b4QVWsRsNbCt3OGKu(DogUna9hWnDJcss56DogUnaKUltK5dIDkkAaYE3pax9fwAv6mGB6gfKKYXKJHBdq)bCt3OGKuUIjhd3gasyktK5dIDkkAaYg3pax9fwAv6mGB6gfKKYVZXWTbO)aUPBuqskxVZXWTbGeMYez(GyNIIgGSX9dWvFHLwLod4MUrbjPCm5y42a0Fa30nkijLRyYXWTbG0DzImFqCqu2XD356WD1rNN7hWa6bknGa(1V6aA)oGBhQz4m92awcJHhlDgG4HtdWW1hUP0zajOwbJe8bXoffnaz4(b4QVWsRsNbCBXlQ9lmIJHBdq)bCBXlQ9lmIJbovgkJo3gasyktK5dIDkkAaia3pax9fwAv6mGBPVo4HYXWTbO)aUL(6GhkhdCQmugDUnaKUltK5dIDkkAaYg3pax9fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdajxltK5dIDkkAaiqUFaU6lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gasUwMiZhe7uu0aUll3pax9fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdajmsMiZhe7uu0aUF39dWvFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aqcJKjY8bXoffnG7y6(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiHPmrMpi2POObCx27(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiHPmrMpi2POObChbY9dWvFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aq6UmrMpi2POObGPSC)aC1xyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnathacocCNgas3LjY8bXoffnamV7(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiDxMiZhe7uu0aW8U7hGR(clTkDgWTfVO2VWiogUna9hWTfVO2VWiog4uzOm6CBaiDxMiZheheLDC3DUoCxD055(bmGEGsdiGF9RoG2Vd4M90TbSegdpw6maXdNgGHRpCtPZasqTcgj4dIDkkAay6(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaMoaeCe4onaKUltK5dIDkkAayK7hGR(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTby6aqWrG70aq6UmrMpi2POObGaC)aC1xyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnathacocCNgas3LjY8bXoffnazJ7hGR(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFqStrrdabY9dWvFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aq6UmrMpi2POObCxwUFaU6lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8bXoffnG7y6(b4QVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiDxMiZheheDxWV(vPZaU76byjn(AaSqOc(Gy2rCrPChykJ7zNR9BbJYoiie0aKDrMcDaYUvbmO6aqW2xOdIiie0a6832e0bGPRDzayklmXCqCqebHGgGRGAfmsmiIGqqdaJFaDoc(JLodGzcfJxqPVodaxyWOb8Tb4kOwuIb8Tb4Us0amXacDaNNe1nDaxmZTb0LySbe1aUwlPrI4dIiie0aW4hGSRVUPdib1QIydabJrcOP1A6ao4BuWgaexYuOd4BdWjQZAWEHXheherqdabhRXWnLedWgGUrbjPIbK(ND(ULld4eyJdDgaQBd4kymBhW3gqBFHoGFha6sMcDaFBaIOoRb7f2nXas)ZoF3Ipa3vBaHEtmaSgdNgautmG6hWsWTOo0oGLu8TgWDxgaXe0awsX3AaYIld(GOL04lb)AP0dh10(LGqS2ggkJCPm4KeDJcss939c3QKl)LebPrZfSgdNKC3fSgdN8etqsKfxgUK(6eA8LeDJcss535qnHhxqEu8wtos9QgJkLJUKPq9FZlI6SgSxyYrs3OGKu(DE6F257w8d(AA8LSv2M(ND(Uf)kymB9FZ32xO8d(AA8LezHSuPQXOs5Olzku)38IOoRb7fMCKs)ZoF3IJUKPq9FZlI6SgSxy8d(AA8LSv2QBuqsk)op9p78Dl(bFnn(sISqwQu1yuP8irj7c5brlPXxc(1sPhoQP9lbHyTnmug5szWjj6gfKK6X0lCRsU8xseKgnxWAmCsYDxWAmCYtmbjrwCz4s6RtOXxs0nkijLJjhQj84cYJI3AYrQx1yuPC0LmfQ)BEruN1G9ctos6gfKKYXKN(ND(Uf)GVMgFjBLTP)zNVBXVcgZw)38T9fk)GVMgFjrwilvQAmQuo6sMc1)nViQZAWEHjhP0)SZ3T4Olzku)38IOoRb7fg)GVMgFjBLT6gfKKYXKN(ND(Uf)GVMgFjrwilvQAmQuEKOKDH8GicAai4cnGBkjgGnaDJcssfdaRXWPbG62asp8lBJc2auO0as)ZoF3AaFBakuAa6gfKK6Yaob24qNbG62auO0ao4RPXxd4BdqHsdafV1gqOd4AFSXHe8b05ZedWgGqxQGPqha8)eTG2bO)aGfyPbydaAadkTd4AJFd1TbO)ae6sfmf6a0nkijv4YamXa6sm2amXaSba)prlODaTFhq0gGnaDJcsshq3GXgWVdOBWydOEDac3Q0a6gk0bK(ND(ULGpiAjn(sWVwk9WrnTFjieRTHHYixkdojr3OGKu)1g)gQBU8xseKgnxWAmCscMUG1y4KNycsYDxsFDcn(ssV6gfKKYVZHAcpUG8O4TMCDJcss5yYHAcpUG8O4TMuP6gfKKYXKd1eECb5rXBn5iHKUrbjPCm5P)zNVBXp4RPXxYwDJcss5yYrXBn)bFnn(cz3bP7Cz0VUrbjPCm5qnHhfV14cDPcMcfz3bjS2ggkJ46gfKK6X0lCRsiJCFiHKUrbjP8780)SZ3T4h8104lzRUrbjP87Cu8wZFWxtJVq2Dq6oxg9RBuqsk)ohQj8O4TgxOlvWuOi7oiH12Wqzex3OGKu)DVWTkHmYdIwsJVe8RLspCut7xccXAByOmYLYGts2UEu8wt4cwJHtsuJrLYHzkuAJcMxO)cxQ00xh8q5ewAB7luPsx8IA)cJ4OHgfmF6zNbrlPXxc(1sPhoQP9lbHngjGMwRPdIdIiie0aqWLjLWv6maclTUnanGtdqHsdWs6VdiedWWAbZqzeFq0sA8Lqc8Oo(2suNrdIiObGXTewQ0biUOu0c6maDJcssfdaLIc2aWf0zaDdf6amC9HBAKgalksmiAjn(s0VeeI12WqzKlLbNKiUOu0c641nkij1fSgdNKGeHXWJRl6WJsKwC1qzKhJHBLId3FiSrIKkLWy4X1fD4kuY3IvOEralyilhP0)SZ3T4rjslUAOmYJXWTsXH7pe2ir8LSJBsLM(ND(UfxHs(wSc1lcybJVeClkbYsLsym846IoCfk5BXkuViGfm5egdpUUOdpkrAXvdLrEmgUvkoC)HWgjAq0sA8LOFjieRTHHYixkdojrO(lMvvuWCbRXWjjwsdSKNkcEqcj3LJ0AXXtyPs525i4r13DzivAVRfhpHLkLBNJGtYmeQa5brlPXxI(LGqS2ggkJCPm4Ke7Ce(LGBr5cwJHtsSKgyjpve8Ge9jbt5i17AXXtyPs525i4KmdHkKkDT44jSuPC7CeCsMHqfYrAT44jSuPC7Ce8LGBrj6tgsL2cyqv)sWTOe9DxwiJ8GOL04lr)sqiwBddLrUugCsY(Al53ao5cwJHtsqXBn(gWjo(LCK6DXlQ9lmIVgmY)nVcL8T97mQ8jOg8R4lPsx8IA)cJ4RbJ8FZRqjFB)oJkFcQb)k(s(IxrYF9DPLFOwKcTpzdYdIwsJVe9lbHyTnmug5szWjjT9fQxOBaj5tFDWdv4cwJHtssFDWdLtRDIKPrbZJY(UYrXBnoT2jsMgfmpk77YfQLGucMsLM(6GhkhVyKjGshFBPQZCtokERXXlgzcO0X3wQ6m34lb3IsabKGLoUdMipiAjn(s0VeeI12WqzKlLbNKCitHk8hCYBjnWsUG1y4KKdzkuVvh)HsMBCnsqgfm5PhlvwP8kGbv9nJgerqdWDFDXCBaiy7l0bGGryP1Lba3IsTOgG7k52a6XyFjgGvNbajrxdOZrW)vqmsigGStukTdyFglkydIwsJVe9lbHlb)xbXiHW3nkLwxIMK0xh8q5ewAB7lu5QXOs5WmfkTrbZl0FHlhPEvJrLYFuwO0AA8L80)SZ3T4xbJzR)B(2(cLVeClkHuPcs9OFHl4AqlMYgpgDLKRgJkL)OSqP104l59II3A8RGXS1)nFBFHYXVqEq0sA8LOFjie63LffmpkZeQlj3smYR2cJuHK7Uenj9EEL32xO(gHLw(sWTOeYrsngvkpsuYUKkTxu8wJJUKPq9FZlI6SgSxyC8l5QXOs5Olzku)38IOoRb7fMuPQXOs5pkluAnn(sE6F257w8RGXS1)nFBFHYxcUfLqEVO4TghYGXIcMhULGgfXXVqEq0sA8LOFjiegZsHX82bRvjYLOjbfV14rYnVASVe8LGBrjGGeyPJ7GPC1yuP8i5Mxn2xc5IlIX8QTWivWHXSuymVDWAvI6tcMYrsngvkpsuYUKkvngvkhDjtH6)Mxe1znyVWKN(ND(UfhDjtH6)Mxe1znyVW4lb3Is03DzivQAmQu(JYcLwtJVK3lkERXVcgZw)38T9fkh)c5brlPXxI(LGW2(c1l0nGKCjAsqXBnEKCZRg7lbFj4wuciibw64oykxngvkpsU5vJ9LqosQXOs5rIs2LuPQXOs5Olzku)38IOoRb7fM8ErXBno6sMc1)nViQZAWEHXXVKN(ND(UfhDjtH6)Mxe1znyVW4lb3Is03DzjvQAmQu(JYcLwtJVK3lkERXVcgZw)38T9fkh)c5brlPXxI(LGWhLfkTMsUenjPhlvwP8kGbv9nJKFitH6T64puYCJRrcYOGj)qMc1B1XFOK5g3sAGL8lb3IsabKGLoUZDUmqwos9QgJkL)OSqP104lPsvJrLYFuwO0AA8L8ErXBn(vWy26)MVTVq54xipiIGgGRG(VGgG7oPXxdGfcDa6pGfVgeTKgFj6xcctgJ5TKgF5zHqDPm4KK0JLkRuXGOL04lr)sqyYymVL04lpleQlLbNKSwkmMyq0sA8LOFjimzmM3sA8LNfc1LYGts0nkijvmiAjn(s0VeeMmgZBjn(YZcH6szWjjP)zNVBjgeTKgFj6xcctgJ5TKgF5zHqDPm4KK0ZoEOKTQlcDJKk5UlrtIAmQuE6zhpuYwvos9II3ACidglkyE4wcAueh)sQu1yuPC0LmfQ)BEruN1G9cdz5iDiu8wJVwN9BKiUqTeKsKHuP9EitH6HScyqv(Ixu7xyeFTo73iripiAjn(s0VeeU4L3sA8LNfc1LYGtsqFHxJeKrbZfHUrsLC3LOjbfV14Olzku)38IOoRb7fgh)Aq0sA8LOFjiCXlVL04lpleQlLbNKG(c)1)SOG5s0KOgJkLJUKPq9FZlI6SgSxyYrk9p78Dlo6sMc1)nViQZAWEHXxcUfLac3LfYYrAT44jSuPC7Ce8O6dtzivAVRfhpHLkLBNJGtYmeQqQ00)SZ3T4xbJzR)B(2(cLVeClkbeUll5RfhpHLkLBNJGtYmeQq(AXXtyPs525i4rbH7Yc5brlPXxI(LGWfV8wsJV8SqOUugCsYJYcLwtJVCrOBKuj3DjAsqXBn(vWy26)MVTVq54xYvJrLYFuwO0AA81GOL04lr)sq4IxElPXxEwiuxkdoj5rzHsRPXx(R)zrbZLOjPxbPE0VWfCnOftzJhJUsY7DXlQ9lmIVgmY)nVcL8T97mQ8jOg8R4l5QXOs5pkluAnn(sE6F257w8RGXS1)nFBFHYxcUfLac3LLCKWAByOmIlu)fZQkkysLUwC8ewQuUDocojZqOc5RfhpHLkLBNJGhfeUllPs7DT44jSuPC7CeCsMHqfipiAjn(s0VeeU4L3sA8LNfc1LYGtsSNCrOBKuj3DjAsSKgyjpve8Ge9jbZbrlPXxI(LGWKXyElPXxEwiuxkdojrOwDS9mioiIGgG7(rWhqN7vtJVgeTKgFj42tswc(VcIrcHVBukTdIwsJVeC7P(LGqymlfgZBhSwLixIMe1yuP82(cvKCtHsdIwsJVeC7P(LGW2(cvKCtHsUenjO4TghYGXIcMhULGgfXxYsQ8EXAByOmIFitHk8hCYBjnWsdIwsJVeC7P(LGqOFxwuW8OmtOUenjyTnmugX3xBj)gWj5QXOs5gwJzvckniAjn(sWTN6xccHXSuymVDWAvICjAs6ffV14BaN44xYTKgyjpve8GeqqIRLk1sAGL8urWds0NRherqdab7x44mlsdWUU23sqhG(diTKP0aSbCji8ZpGRn(nu3gGAlmshale6aA)oa76I5wuWgWAD2VrIgqudWEAq0sA8LGBp1Vee22xOEHUbKKlj3smYR2cJuHK7UenjP)zNVBXxc(VcIrcHVBukT8LGBrjGGemDhyPJC1yuPCyMcL2OG5f6VWheTKgFj42t9lbHq)USOG5rzMqDjAsWAByOmIVV2s(nGtdIwsJVeC7P(LGW2(cvKCtHsUenjQXOs5WmfkTrbZl0FHlhfV14lb)xbXiHW3nkLwo(LClPbwYtfbpirFykVxS2ggkJ4hYuOc)bN8wsdS0GOL04lb3EQFji8rzHsRPKlrtcwBddLr8dzkuH)GtElPbwsokERXpKPqf(doXfQLGecyKuPQXOs5WmfkTrbZl0FHlhfV14lb)xbXiHW3nkLwo(1GOL04lb3EQFjiSTVq9cDdijxsULyKxTfgPcj3DjAsw8ks(RVlT8d1IuOqaP7YOF1yuP8fVIK3uLkCtJVChzG8GOL04lb3EQFjiSTVqfj3uOKlrtsVyTnmugXpKPqf(do5TKgyPbrlPXxcU9u)sq4JYcLwtjxsULyKxTfgPcj3DjAsw8ks(RVlT8d1IuO9HeMYOF1yuP8fVIK3uLkCtJVChzG8GOL04lb3EQFjiegZsHX82bRvjAq0sA8LGBp1Vee22xOIKBkuAq0sA8LGBp1Vee22xOEHUbKKlj3smYR2cJuHK7dIwsJVeC7P(LGqO)w(V57gLs7GOL04lb3EQFji02KvKx)DPsheherqdaIlzk0b8Tb4e1znyVWgW1)SOGnG9vtJVgG7hGqTvfd4USedaLA)sdaIVZacXamSwWmugniAjn(sWrFH)6FwuWKSe8FfeJecF3OuADjAsSKgyjpve8Ge9jbtPsXAByOmIVD9O4TMyq0sA8LGJ(c)1)SOG1Vee(OSqP1uYLKBjg5vBHrQqYDxIMeu8wJdzWyrbZd3sqJI4lzjvE6F257w8RGXS1)nFBFHYxcUfLOpxpiAjn(sWrFH)6FwuW6xccH(DzrbZJYmH6s0KG12WqzeFFTL8BaNgeTKgFj4OVWF9plky9lbHT9fQi5McLCjAsqXBnoKbJffmpClbnkIVKLu5lEfj)13Lw(HArk0(q6Um6xngvkFXRi5nvPc304l3rgilxCrmMxTfgPcEBFHksUPqP(WuEVyTnmugXpKPqf(do5TKgyPbrlPXxco6l8x)ZIcw)sqyBFHksUPqjxIMKfVIK)67sl)qTifAFsqY1YOF1yuP8fVIK3uLkCtJVChzGSCXfXyE1wyKk4T9fQi5McL6dt59I12Wqze)qMcv4p4K3sAGLgerqiObCtTfgP(OjbUjt3J0HqXBn(AD2VrI4c1sq2)DKLTiDiu8wJVwN9BKi(sWTOe9Fhz35qMc1dzfWGQ8fVO2VWi(AD2VrIUnGohDrMkgGna2RUmafAigqigqukvh6ma9hGAlmshGcLga0agusOd4AJFd1Tbqfb3Tb0nuOdWQbyOblu3gGc10b0nySbyxxm3gWAD2VrIgq0gWIxu7xy0HpGEGA6aqPOGnaRgaveC3gq3qHoaznaHAjifUmGFhGvdGkcUBdqHA6auO0aoekERnGUbJnaX)1aizEflnGV4dIwsJVeC0x4V(NffS(LGWhLfkTMsUKClXiVAlmsfsU7s0KS4vK8xFxA5hQfPq7tcMYyq0sA8LGJ(c)1)SOG1VeecJzPWyE7G1Qe5s0KS4vK8xFxA5hQfPqHaMYsU4IymVAlmsfCymlfgZBhSwLO(KGP80)SZ3T4xbJzR)B(2(cLVeClkrFYyq0sA8LGJ(c)1)SOG1Vee22xOEHUbKKlj3smYR2cJuHK7UenjlEfj)13Lw(HArkuiGPSKN(ND(Uf)kymB9FZ32xO8LGBrj6tgdIwsJVeC0x4V(NffS(LGqymlfgZBhSwLixIMK0)SZ3T4xbJzR)B(2(cLVeClkrFlErCnGtE99yK8fVIK)67sl)qTifkeWizjxCrmMxTfgPcomMLcJ5TdwRsuFsWCq0sA8LGJ(c)1)SOG1Vee22xOEHUbKKlj3smYR2cJuHK7UenjP)zNVBXVcgZw)38T9fkFj4wuI(w8I4AaN867Xi5lEfj)13Lw(HArkuiGrYAqCqebnaiUKPqhW3gGtuN1G9cBaU7KgyPb05E104RbrlPXxco6l8AKGmkysEuwO0Ak5sYTeJ8QTWivi5UlrtYIxrYF9DPfcsqcJKr)QXOs5lEfjVPkv4MgF5oYa5brlPXxco6l8AKGmky9lbHlb)xbXiHW3nkLwxIMeS2ggkJ4BxpkERjKk1sAGL8urWds0NemLkDXRi5V(U0cbxJP8fViUgWjV(EmHWIxrYF9DPv2EhbmiAjn(sWrFHxJeKrbRFji8qMc1B1XFOK5MlrtYIxrYF9DPfcUgt5lErCnGtE99ycHfVIK)67sRS9ocyq0sA8LGJ(cVgjiJcw)sqi0VllkyEuMjuxIMeS2ggkJ47RTKFd4KCKw8ks(RVlT9jbJKHuPlErCnGtE99UgcsGLosLU4f1(fgXxdg5)MxHs(2(Dgv(eud(v8LuPIlIX8QTWivWH(DzrbZJYmH2NemLkffV14BaN4lb3IsabxJSuPlEfj)13Lwi4AmLV4fX1ao513Jjew8ks(RVlTY27iGbrlPXxco6l8AKGmky9lbHT9fQi5McLCjAsqXBnoKbJffmpClbnkIJFjxCrmMxTfgPcEBFHksUPqP(WuEVyTnmugXpKPqf(do5TKgyPbrlPXxco6l8AKGmky9lbHpkluAnLCj5wIrE1wyKkKC3LOjbfV14qgmwuW8WTe0Oi(swsheTKgFj4OVWRrcYOG1Veec93Y)nF3OuADjAsw8ks(RVlTqqccqwYx8I4AaN867DDFWsNbrlPXxco6l8AKGmky9lbHT9fQi5McLCjAsexeJ5vBHrQG32xOIKBkuQpmL3lwBddLr8dzkuH)GtElPbwAq0sA8LGJ(cVgjiJcw)sq4JYcLwtjxsULyKxTfgPcj3DjAsw8ks(RVlT8d1IuO9HPmKkDXlIRbCYRV31qaw6miAjn(sWrFHxJeKrbRFjie63LffmpkZeQlrtcwBddLr891wYVbCAq0sA8LGJ(cVgjiJcw)sqOTjRiV(7sL6s0KS4vK8xFxAHGmK1G4G4Giccbnax9SZa68r2QdWvFDcn(smiAjn(sWtp74Hs2QssqTOe(V5Je5s0KG(cH8wadQ6xcUfLacWsh5iT4fbbmLkTxu8wJdzWyrbZd3sqJI44xYrQx4wuEOwD4ycvokERXtp74Hs2QCHAji7tcg1)Ixu7xyehYNPXAcFZW(RuPWTO8qT6WXeQCu8wJNE2XdLSv5c1sq2NSP)fVO2VWioKptJ1e(MH9xKLkffV14qgmwuW8WTe0Oio(LCK6fUfLhQvhoMqLJI3A80ZoEOKTkxOwcY(Kn9V4f1(fgXH8zASMW3mS)kvkClkpuRoCmHkhfV14PND8qjBvUqTeK9Dxw9V4f1(fgXH8zASMW3mS)ImYdIiOb05NGgWbFJc2aW4cgZ2b0nuOdWDLOKDHqiUKPqheTKgFj4PND8qjB1(LGWeulkH)B(irUenj9QgJkL)OSqP104l5O4Tg)kymB9FZ32xOC8l5O4Tgp9SJhkzRYfQLGSpj3LLCKqXBn(vWy26)MVTVq5lb3IsabyPJ7G09(t)ZoF3I32xODDBHl8n81n(s2XnKLkffV144f0N5MxOlvWuO8LGBrjGaS0rQuu8wJNGAVWJAfXxcUfLacWshKherqdabgxfXHgW3gagxWy2oaCbzWOb0nuOdWDLOKDHqiUKPqheTKgFj4PND8qjB1(LGWeulkH)B(irUenj9QgJkL)OSqP104l5hYuOEiRaguLV4f1(fgXBgJrLpT4c7qR8ErXBn(vWy26)MVTVq54xYt)ZoF3IFfmMT(V5B7lu(sWTOe9DxgYrcfV14PND8qjBvUqTeK9j5USKJekERXXlOpZnVqxQGPq54xsLII3A8eu7fEuRio(fYsLII3A80ZoEOKTkxOwcY(KC31ipiAjn(sWtp74Hs2Q9lbHjOwuc)38rICjAs6vngvk)rzHsRPXxY79qMc1dzfWGQ8fVO2VWiEZymQ8PfxyhALJI3A80ZoEOKTkxOwcY(KCxwY7ffV14xbJzR)B(2(cLJFjp9p78Dl(vWy26)MVTVq5lb3Is0hMYAqebnamULWsLoax9SZa68r2Qd4XsBYUUIc2ao4BuWgWvWy2oiAjn(sWtp74Hs2Q9lbHjOwuc)38rICjAsuJrLYFuwO0AA8L8ErXBn(vWy26)MVTVq54xYrcfV14PND8qjBvUqTeK9j5ogjhju8wJJxqFMBEHUubtHYXVKkffV14jO2l8OwrC8lKLkffV14PND8qjBvUqTeK9j5ocKuPP)zNVBXVcgZw)38T9fkFj4wuci4A5O4Tgp9SJhkzRYfQLGSpj3XiKheherqdaJ714RbrlPXxcE6F257wcjxVgF5s0KGI3A8RGXS1)nFBFHYXVgerqdWv)ZoF3smiAjn(sWt)ZoF3s0VeesWV(U06x8I8Dj76lxIMe1yuP8hLfkTMgFjFXlccia5iH12WqzexO(lMvvuWKkfRTHHYiUDoc)sWTOqwosP)zNVBXVcgZw)38T9fkFj4wuciid5iL(ND(UfVXib00AnLVeClkrFYqU4XzOrD4x4cfNrEAXV04lPs7v84m0Oo8lCHIZipT4xA8fYsLII3A8RGXS1)nFBFHYXVqwQu0xiK3cyqv)sWTOeqatzniAjn(sWt)ZoF3s0VeesWV(U06x8I8Dj76lxIMe1yuPC0LmfQ)BEruN1G9ct(IxeeKH8fVIK)67sleqcbilm(dzkupKvadQYx8IA)cJ4qDtO0gM7idm(fVO2VWi(AWVSs96ALOrlvjYDKbYYrcfV14Olzku)38IOoRb7fgh)sQ0wadQ6xcUfLacyklKheTKgFj4P)zNVBj6xccj4xFxA9lEr(UKD9LlrtIAmQuEKOKDniAjn(sWt)ZoF3s0VeeEfmMT(V5B7luxIMe1yuPC0LmfQ)BEruN1G9ctosyTnmugXfQ)IzvffmPsXAByOmIBNJWVeClkKLJu6F257wC0LmfQ)BEruN1G9cJVeClkHuPP)zNVBXrxYuO(V5frDwd2lm(s2Xn5lEfj)13L2(qaYa5brlPXxcE6F257wI(LGWRGXS1)nFBFH6s0KOgJkLhjkzxY7ffV14xbJzR)B(2(cLJFniAjn(sWt)ZoF3s0VeeEfmMT(V5B7luxIMe1yuP8hLfkTMgFjhPfVIK)67sBFsCTmK3lkERXn0hEuMgF5zbCuo(LuPO4Tg3qF4rzA8LNfWr54xsLU4f1(fgXxdg5)MxHs(2(Dgv(eud(v8fYYrcRTHHYiUq9xmRQOGjvkwBddLrC7Ce(LGBrHSCKuJrLYHzkuAJcMxO)cNtLHYOJCu8wJVe8FfeJecF3OuA54xsL2RAmQuomtHsBuW8c9x4CQmugDqEq0sA8LGN(ND(ULOFjieDjtH6)Mxe1znyVWCjAsqXBn(vWy26)MVTVq54xdIwsJVe80)SZ3Te9lbHT9fAx3w4cFdFDZLOjXsAGL8urWdsi5UCu8wJFfmMT(V5B7lu(sWTOeqaw6ihfV14xbJzR)B(2(cLJFjVx1yuP8hLfkTMgFjhPExloEclvk3ohbNKziuHuPRfhpHLkLBNJGhvFUwwilvAlGbv9lb3IsabxpiAjn(sWt)ZoF3s0Vee22xODDBHl8n81nxIMelPbwYtfbpirFsWuosO4Tg)kymB9FZ32xOC8lPsxloEclvk3ohbNKziuH81IJNWsLYTZrWJQV0)SZ3T4xbJzR)B(2(cLVeClkr)YEKLJekERXVcgZw)38T9fkFj4wucialDKkDT44jSuPC7CeCsMHqfYxloEclvk3ohbFj4wucialDqEq0sA8LGN(ND(ULOFjiSTVq762cx4B4RBUenjQXOs5pkluAnn(sosO4Tg)kymB9FZ32xOC8l59c3IYd1QdhtOsL2lkERXVcgZw)38T9fkh)soClkpuRoCmHkp9p78Dl(vWy26)MVTVq5lb3IsGSCKqcfV14xbJzR)B(2(cLVeClkbeGLosLII3AC8c6ZCZl0Lkykuo(LCu8wJJxqFMBEHUubtHYxcUfLacWshKLJ0HqXBn(AD2VrI4c1sqkrgsL27HmfQhYkGbv5lErTFHr816SFJeHmYdIwsJVe80)SZ3Te9lbHqD76vO0cps(RLeuLixIMe1yuPC0LmfQ)BEruN1G9ct(IxrYF9DPfciazjFXlccsCTCKqXBno6sMc1)nViQZAWEHXXVKkn9p78Dlo6sMc1)nViQZAWEHXxcUfLOpmswilvAVQXOs5Olzku)38IOoRb7fM8fVIK)67sleKi7LXGOL04lbp9p78Dlr)sq4AHG8hYoUenjP)zNVBXVcgZw)38T9fkFj4wuciirgdIwsJVe80)SZ3Te9lbHclTrlsHX8xwsDjAsSKgyjpve8Ge9jbt5i1cyqv)sWTOeqW1sL2lkERXrxYuO(V5frDwd2lmo(LCKUiLdd6JZ4lb3IsabyPJuPRfhpHLkLBNJGtYmeQq(AXXtyPs525i4lb3IsabxlFT44jSuPC7Ce8O67IuomOpoJVeClkbYipiAjn(sWt)ZoF3s0VeeEitH6T64puYCZLOjXsAGL8urWds0NmKkDXlQ9lmIFbLS9H)fjgeherqdWvpwQSshG7gnyHgKyq0sA8LGNESuzLkKCitHk8hCYLOjbPEvJrLYFuwO0AA8LuPQXOs5pkluAnn(sUL0al5PIGhKOpjykp9p78Dl(vWy26)MVTVq5lb3IsivQL0al5PIGhKqYDKLJewBddLrCH6VywvrbtQuS2ggkJ425i8lb3Ic5brlPXxcE6XsLvQOFjiu01w4rbZdpeQlrtYIxrYF9DPLFOwKcTV7UwE6F257w8RGXS1)nFBFHYxcUfLacUwEVQXOs5Olzku)38IOoRb7fMCS2ggkJ4c1FXSQIc2GOL04lbp9yPYkv0Veek6Al8OG5Hhc1LOjPx1yuPC0LmfQ)BEruN1G9ctowBddLrC7Ce(LGBrniAjn(sWtpwQSsf9lbHIU2cpkyE4HqDjAsuJrLYrxYuO(V5frDwd2lm5iHI3AC0LmfQ)BEruN1G9cJJFjhjS2ggkJ4c1FXSQIcM8fVIK)67sl)qTifAFyKSKkfRTHHYiUDoc)sWTOKV4vK8xFxA5hQfPq7dbilPsXAByOmIBNJWVeClk5RfhpHLkLBNJGVeClkbeqGKVwC8ewQuUDocojZqOcKLkTxu8wJJUKPq9FZlI6SgSxyC8l5P)zNVBXrxYuO(V5frDwd2lm(sWTOeipiAjn(sWtpwQSsf9lbHg6dpktJV8SaoQlrts6F257w8RGXS1)nFBFHYxcUfLacWsh3bt5yTnmugXfQ)Izvffm5iPgJkLJUKPq9FZlI6SgSxyYx8ks(RVlT9HaKH80)SZ3T4Olzku)38IOoRb7fgFj4wuciGPuP9QgJkLJUKPq9FZlI6SgSxyipiAjn(sWtpwQSsf9lbHg6dpktJV8SaoQlrtcwBddLrC7Ce(LGBrniAjn(sWtpwQSsf9lbHcOwcsg5vOKhV6(Rc1nxIMeS2ggkJ4c1FXSQIcMCKs)ZoF3IFfmMT(V5B7lu(sWTOeqW1sLQgJkLhjkzxipiAjn(sWtpwQSsf9lbHcOwcsg5vOKhV6(Rc1nxIMeS2ggkJ425i8lb3IAq0sA8LGNESuzLk6xccBmsanTwtDjAs6ffV14xbJzR)B(2(cLJFjhjXJZqJ6WVWfkoJ80IFPXxsLkECgAuho2NzAWiV4zyPsL3lkERXX(mtdg5fpdlvkh)czxIsPDXVuFahoDctjj3DjkL2f)s9WypQXKC3LOuAx8l1hnjIhNHg1HJ9zMgmYlEgwQ0bXbre0aqGrzHsRPXxdyF104RbrlPXxc(JYcLwtJVKSe8FfeJecF3OuADjAsSKgyjpve8Ge9jX1YXAByOmIVD9O4TMyq0sA8LG)OSqP104R(LGW2(c1l0nGKCjAs6ffV14qgmwuW8WTe0Oio(LCKw8IGaMsLQgJkLhj38QX(sihfV14rYnVASVe8LGBrjGaS0XDWuQ00xh8q54fJmbu64BlvDMBYrcfV144fJmbu64BlvDMB8LGBrjGaS0XDWuQuu8wJJxmYeqPJVTu1zUXfQLGecUgzKheTKgFj4pkluAnn(QFjie63LffmpkZeQlrtsVO4TghYGXIcMhULGgfXXVKV4f1Nexlhju8wJVbCIVeClkbeCTCu8wJVbCIJFjvQL0al5pVYB7luFJWsleSKgyjpve8GeipiAjn(sWFuwO0AA8v)sqimMLcJ5TdwRsKlrtsVO4TghYGXIcMhULGgfXXVKlUigZR2cJubhgZsHX82bRvjQpjykvAVO4TghYGXIcMhULGgfXXVKJ0HqXBn(AD2VrI4c1sqcbziv6HqXBn(AD2VrI4lb3IsabyPJ7GripiAjn(sWFuwO0AA8v)sqyBFHksUPqjxIMeu8wJdzWyrbZd3sqJI4lzjvU4IymVAlmsf82(cvKCtHs9HP8EXAByOmIFitHk8hCYBjnWsdIwsJVe8hLfkTMgF1Vee(OSqP1uYLKBjg5vBHrQqYDxIMeu8wJdzWyrbZd3sqJI4lzjDq0sA8LG)OSqP104R(LGW2(c1l0nGKCjAsSKgyjpve8GesUlhRTHHYiEBFH6f6gqs(0xh8qfdIwsJVe8hLfkTMgF1Veec97YIcMhLzc1LOjbRTHHYi((Al53aojxCrmMxTfgPco0VllkyEuMj0(KG5GOL04lb)rzHsRPXx9lbHWywkmM3oyTkrUenjIlIX8QTWivWHXSuymVDWAvI6tcMdIwsJVe8hLfkTMgF1Vee22xOEHUbKKlj3smYR2cJuHK7Uenj9QgJkLBynMvjOK8ErXBnoKbJffmpClbnkIJFjvQAmQuUH1ywLGsY7fRTHHYi((Al53aojvkwBddLr891wYVbCs(Ixexd4KxFpM9jbw6miAjn(sWFuwO0AA8v)sqi0VllkyEuMjuxIMeS2ggkJ47RTKFd40GOL04lb)rzHsRPXx9lbHpkluAnLCj5wIrE1wyKkKCFqCqebnamU)zrbBaiy)oaeyuwO0AA8L7hGJARkgWDznabL(6igak1(LgagxWy2oGVnaeS9f6aspCsmGV1gGRKDniAjn(sWFuwO0AA8L)6FwuWKSe8FfeJecF3OuADjAsWAByOmIVD9O4TMqQulPbwYtfbpirFsWCq0sA8LG)OSqP104l)1)SOG1VeecJzPWyE7G1Qe5s0KiUigZR2cJubhgZsHX82bRvjQpjykxngvkVTVqfj3uO0GOL04lb)rzHsRPXx(R)zrbRFjiSTVqfj3uOKlrtckERXHmySOG5HBjOrr8LSKk3sAGL8urWds0hMY7fRTHHYi(HmfQWFWjVL0alniAjn(sWFuwO0AA8L)6FwuW6xccFuwO0Ak5sYTeJ8QTWivi5UlrtckERXHmySOG5HBjOrr8LSKoiAjn(sWFuwO0AA8L)6FwuW6xccB7luVq3asYLOjXsAGL8urWdsi5UCS2ggkJ4T9fQxOBaj5tFDWdvmiAjn(sWFuwO0AA8L)6FwuW6xccFuwO0Ak5sYTeJ8QTWivi5UlrtckERXHmySOG5HBjOrr8LSKoiAjn(sWFuwO0AA8L)6FwuW6xccH(DzrbZJYmH6s0KG12WqzeFFTL8BaNgeTKgFj4pkluAnn(YF9plky9lbHWywkmM3oyTkrUenjIlIX8QTWivWHXSuymVDWAvI6tcMYx8ks(RVlT8d1IuOqabiRbrlPXxc(JYcLwtJV8x)ZIcw)sqyBFH6f6gqsUKClXiVAlmsfsU7s0KS4vK8xFxA5hQfPqHGSxwdIwsJVe8hLfkTMgF5V(NffS(LGWhLfkTMsUKClXiVAlmsfsU7s0KS4f1NexlhPEHBr5HA1HJjuPstpwQSs5fL2N97rQ00JLkRuoKUTHvilv6IxuFsWi5WTO8qT6WXe6GOL04lb)rzHsRPXx(R)zrbRFjiSTVqfj3uOKlrtIL0al5PIGhKOpjyK8EXAByOmIFitHk8hCYBjnWsdIdIiOb05SuySb4UrdwObjgeTKgFj4RLcJjKGY()4B4RBUenjO4Tg)kymB9FZ32xOC8RbrlPXxc(APWyI(LGquAf0czuWCjAsqXBn(vWy26)MVTVq54xdIwsJVe81sHXe9lbH2MSI8x4mb5s0KGuVO4Tg)kymB9FZ32xOC8l5wsdSKNkcEqI(KGjYsL2lkERXVcgZw)38T9fkh)soslEr8d1IuO9jrgYx8ks(RVlT8d1IuO9jbbilKheTKgFj4RLcJj6xcczbmOQWl7o(bgCQuxIMeu8wJFfmMT(V5B7luo(1GOL04lbFTuymr)sqOvjsORX8jJXCjAsqXBn(vWy26)MVTVq54xYrXBnob)67sRFXlY3LSRV44xdIwsJVe81sHXe9lbHTyju2)hxIMeu8wJFfmMT(V5B7lu(sWTOeqqISrokERXVcgZw)38T9fkh)sokERXj4xFxA9lEr(UKD9fh)Aq0sA8LGVwkmMOFjie1G5)Mx3ibPWLOjbfV14xbJzR)B(2(cLJFj3sAGL8urWdsi5UCKqXBn(vWy26)MVTVq5lb3Isabzixngvkp9SJhkzRYPYqz0rQ0EvJrLYtp74Hs2QCQmugDKJI3A8RGXS1)nFBFHYxcUfLacUg5bXbre0aCuRo2EgGikymcJxTfgPdyF104RbrlPXxcUqT6y7rYsW)vqmsi8DJsP1LOjbRTHHYi(21JI3AIbrlPXxcUqT6y7PFji8rzHsRPKlrtckERXHmySOG5HBjOrr8LSKoiAjn(sWfQvhBp9lbHq)USOG5rzMqDjAsWAByOmIVV2s(nGtYrXBn(gWj(sWTOeqW1dIwsJVeCHA1X2t)sqyBFH6f6gqsUenjyTnmugXB7luVq3asYN(6GhQyq0sA8LGluRo2E6xccHXSuymVDWAvICjAs69qMc1dzfWGQ8fVO2VWi(AD2VrIKJ0HqXBn(AD2VrI4c1sqcbziv6HqXBn(AD2VrI4lb3IsabyPJ7GripiAjn(sWfQvhBp9lbHT9fQxOBaj5s0KK(ND(UfFj4)kigje(UrP0YxcUfLacsW0DGLoYvJrLYHzkuAJcMxO)cFq0sA8LGluRo2E6xccH(DzrbZJYmH6s0KG12WqzeFFTL8BaNgeTKgFj4c1QJTN(LGW2(c1l0nGKCjAsw8ks(RVlT8d1IuOqaP7YOF1yuP8fVIK3uLkCtJVChzG8GOL04lbxOwDS90Vee(OSqP1uYLOjPxu8wJ32VZOYFHZeeh)sUAmQuEB)oJk)fotqsLI12Wqze)qMcv4p4K3sAGLKJI3A8dzkuH)GtCHAjiHagjvQAmQuomtHsBuW8c9x4YrXBn(sW)vqmsi8DJsPLJFjv6IxrYF9DPLFOwKcTpKWug9RgJkLV4vK8MQuHBA8L7idKheTKgFj4c1QJTN(LGW2(c1l0nGKgeTKgFj4c1QJTN(LGqO)w(V57gLs7GOL04lbxOwDS90VeeABYkYR)UuPdIdIiOb0ZgfKKkgeTKgFj46gfKKkKGliFOeCxkdojjkrAXvdLrEmgUvkoC)HWgjYLOjPx1yuPC0LmfQ)BEruN1G9ctokERXVcgZw)38T9fkh)sokERXj4xFxA9lEr(UKD9fh)sQu1yuPC0LmfQ)BEruN1G9ctosiHI3A8RGXS1)nFBFHYXVKN(ND(UfhDjtH6)Mxe1znyVW4lzh3qwQuKqXBn(vWy26)MVTVq54xYrcPwadQ6xcUfLaJp9p78Dlo6sMc1)nViQZAWEHXxcUfLaziG5DKrgzPsrFHqElGbv9lb3IsabmVlv6HmfQhYkGbv5NqyOmYhySJNKjLWvsISKR2cJuUgWjV((RK6XuwqqgdIwsJVeCDJcssf9lbH4cYhkb3LYGtsGzyjM)BEfk5BXkuVTOHs7GOL04lbx3OGKur)sqiUG8HsWDPm4KerYwH)B(2AkTLX8cDJgniAjn(sW1nkijv0VeeIliFOeCxkdojrHs(wSc1lcybZLOjbfV14xbJzR)B(2(cLJFjhfV14e8RVlT(fViFxYU(IJFniIGgqpqPbOBuqs6a6gk0bOqPbanGbLe6aiHgWnLodaRXWjxgq3GXgaknaCbDgqlwHoaRod4YILodOBOqhagxWy2oGVnaeS9fkFq0sA8LGRBuqsQOFjiu3OGK07Uenj9I12WqzexCrPOf0XRBuqsQCu8wJFfmMT(V5B7luo(LCK6vngvkpsuYUKkvngvkpsuYUKJI3A8RGXS1)nFBFHYxcUfLOpj3LfYYrQxDJcss5yYHAcF6F257wsLQBuqskhtE6F257w8LGBrjKkfRTHHYiUUrbjP(Rn(nu3KChzPs1nkijLFNJI3A(d(AA8vFsAbmOQFj4wuIbrlPXxcUUrbjPI(LGqDJcssX0LOjPxS2ggkJ4IlkfTGoEDJcssLJI3A8RGXS1)nFBFHYXVKJuVQXOs5rIs2LuPQXOs5rIs2LCu8wJFfmMT(V5B7lu(sWTOe9j5USqwos9QBuqsk)ohQj8P)zNVBjvQUrbjP8780)SZ3T4lb3IsivkwBddLrCDJcss9xB8BOUjbtKLkv3OGKuoMCu8wZFWxtJV6tslGbv9lb3IsmiIGgG7QnGVyUnGVOb81aWf0a0nkijDax7JnoKya2aqXBnxgaUGgGcLgWRqPDaFnG0)SZ3T4dabEhq0gqrHcL2bOBuqs6aU2hBCiXaSbGI3AUmaCbna0xHoGVgq6F257w8brlPXxcUUrbjPI(LGqCb5dLG7IG9QeDJcssV7s0K0lwBddLrCXfLIwqhVUrbjPYrQxDJcss535qnHhxqEu8wtos6gfKKYXKN(ND(UfFj4wucPs7v3OGKuoMCOMWJlipkERHSuPP)zNVBXVcgZw)38T9fkFj4wuI(WuwipiAjn(sW1nkijv0VeeIliFOeCxeSxLOBuqskMUenj9I12WqzexCrPOf0XRBuqsQCK6v3OGKuoMCOMWJlipkERjhjDJcss535P)zNVBXxcUfLqQ0E1nkijLFNd1eECb5rXBnKLkn9p78Dl(vWy26)MVTVq5lb3Is0hMYc5SM1Cga]] )


end
