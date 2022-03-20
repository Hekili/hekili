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


    spec:RegisterPack( "Frost DK", 20220319, [[d8eJwdqiPQ8iqf5seLsBIO6tQunkiQtbrwfvk1RKQQzrL4wqHQ2fQ(fOsdJOKJPszzqrptQqtdkKRruyBGk4BuPeJJOuCoPII1jvW8ab3Ji2NuLoivkPfcc9qQumrIsLCrOqLncQq9rqfIrcQqYjjkvTsqvVKOuPmtPICtqfs1oPs1pbvugkOIQLkvu6PuXuLQ4QGkKYxjkvmwOG9kQ)svdg4WuwmKESitwfxgzZs5ZGYObPtlSAIsLQxdIMnk3gc7wYVv1WvjhhkuwUspNW0jDDOA7qPVlvA8efDEQKwVur18js7xX5B5EYohtPS7yklmXuwD8wNHJPSUDtgULSJ66fLDUSeKgmk7ugck7ahVVqhGSlz3YoxMRS3o5EYoIhFtu2bQQxIoax4cluO4O80JaUIaboZ04R0AnfUIarcUzhu8GPY(kJMDoMsz3XuwyIPS64TodhtzD7gg5wYogUc93SJtGWnzhOX5qvgn7Cirk7i7Imf6aKDRcyq1bahVVqh4HJUTjOd4wNXLbGPSWeZb(bE3a1kyKyGhJFaDwcXJLodGzcfJxqPVodaxyWOb8Tb4gOwuIb8Tbi7t0amXacDaNNe1DDaxmZ1b0LySbe1aUwlPrI4d8y8dq21x31bKGAvrSbahZib00AnDah8nkydaIlzk0b8Tb4e1znyVW4zhwiurUNSZJYcLwtJV8x)ZIcwUNS73Y9KDOYqz0jdXSJL04RSZsi(vqmsi8DJsPn7CirAJln(k7aN)plkydao(3baNHYcLwtJV6WaCuBvXaUjRbiO0xhXaqP2V0aGZdgZ2b8TbahVVqhq6rqIb8T2aCJSRStAdL2WYoyTnmugX3UEu8wtmaPshGL0al5PIqeKya9kzayM1S7yM7j7qLHYOtgIzN0gkTHLDexeJ5vBHrQGdJzPWyE7G1QenGELmamhG8bOgJkL32xOIKRkuItLHYOt2XsA8v2bgZsHX82bRvjkRz37yUNSdvgkJoziMDsBO0gw2bfV14qgmwuW8iSe0Oi(swshG8byjnWsEQiebjgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZUJr5EYouzOm6KHy2XsA8v25rzHsRPu2jTHsByzhu8wJdzWyrbZJWsqJI4lzjn7KCnXiVAlmsfz3VL1S7Yi3t2HkdLrNmeZoPnuAdl7yjnWsEQiebjgGKbCBaYhawBddLr82(c1l0nGK8PVo4HkYowsJVYoT9fQxOBajL1S7WHCpzhQmugDYqm7yjn(k78OSqP1uk7K2qPnSSdkERXHmySOG5ryjOrr8LSKMDsUMyKxTfgPIS73YA2D3sUNSdvgkJoziMDsBO0gw2bRTHHYi((Al53abLDSKgFLDG(DzrbZJYmHM1S7YMCpzhQmugDYqm7K2qPnSSJ4IymVAlmsfCymlfgZBhSwLOb0RKbG5aKpGfVIK)67sl)qTif6aGWaGdYk7yjn(k7aJzPWyE7G1QeL1S7DMCpzhQmugDYqm7yjn(k702xOEHUbKu2jTHsByzNfVIK)67sl)qTif6aGWaClYk7KCnXiVAlmsfz3VL1S73KvUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2zXlAa9kzaDCaYhaYdOVbGWIYd1QdhtOdqQ0bKESuzLYlkTp73ZaKkDaPhlvwPCiDDdRgasdqQ0bS4fnGELmamAaYhaclkpuRoCmHMDsUMyKxTfgPIS73YA29B3Y9KDOYqz0jdXStAdL2WYowsdSKNkcrqIb0RKbGrdq(a6BayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUQqPSM1St6zhpuYwn3t29B5EYouzOm6KHy2jTHsByzh0xigG8b0cyqv)siSOedacdaw6ma5da5bS4fnaimamhGuPdOVbGI3ACidglkyEewcAueh)AaYhaYdOVbGWIYd1QdhtOdq(aqXBnE6zhpuYwLlulb5a6vYaWOb0)aw8IA)cJ4q(mnwt4Bg2F5uzOm6maPshaclkpuRoCmHoa5dafV14PND8qjBvUqTeKdO3biBgq)dyXlQ9lmId5Z0ynHVzy)LtLHYOZaqAasLoau8wJdzWyrbZJWsqJI44xdq(aqEa9naewuEOwD4ycDaYhakERXtp74Hs2QCHAjihqVdq2mG(hWIxu7xyehYNPXAcFZW(lNkdLrNbiv6aqyr5HA1HJj0biFaO4Tgp9SJhkzRYfQLGCa9oGBYAa9pGfVO2VWioKptJ1e(MH9xovgkJodaPbGu2XsA8v2jb1Is4)MpsuwZUJzUNSdvgkJoziMDSKgFLDsqTOe(V5JeLDoKiTXLgFLDGJMGgWbFJc2aGZdgZ2b0nuOdq2NOKDbxiUKPqZoPnuAdl703auJrLYFuwO0AA8fNkdLrNbiFaO4Tg)kymB9FZ32xOC8RbiFaO4Tgp9SJhkzRYfQLGCa9kza3K1aKpaKhakERXVcgZw)38T9fkFjewuIbaHbalDgGBpaKhWTb0)as)ZoF3I32xODDDri8n81v(s2X1bG0aKkDaO4TghVG(mx9cDPcMcLVeclkXaGWaGLodqQ0bGI3A8eu7fEuRi(siSOedacdaw6maKYA29oM7j7qLHYOtgIzhlPXxzNeulkH)B(irzNdjsBCPXxzh4mCvehAaFBaW5bJz7aWfKbJgq3qHoazFIs2fCH4sMcn7K2qPnSStFdqngvk)rzHsRPXxCQmugDgG8bCitH6HScyqv(Ixu7xyeVzmgv(0IlSdTdq(a6BaO4Tg)kymB9FZ32xOC8RbiFaP)zNVBXVcgZw)38T9fkFjewuIb07aUjJbiFaipau8wJNE2XdLSv5c1sqoGELmGBYAaYhaYdafV144f0N5QxOlvWuOC8Rbiv6aqXBnEcQ9cpQveh)AainaPshakERXtp74Hs2QCHAjihqVsgWTooaKYA2Dmk3t2HkdLrNmeZoPnuAdl703auJrLYFuwO0AA8fNkdLrNbiFa9nGdzkupKvadQYx8IA)cJ4nJXOYNwCHDODaYhakERXtp74Hs2QCHAjihqVsgWnzna5dOVbGI3A8RGXS1)nFBFHYXVgG8bK(ND(Uf)kymB9FZ32xO8LqyrjgqVdatzLDSKgFLDsqTOe(V5JeL1S7Yi3t2HkdLrNmeZowsJVYojOwuc)38rIYohsK24sJVYoW5lHLkDaU5zNbahfzRoGhlTj76kkyd4GVrbBaxbJzB2jTHsByzh1yuP8hLfkTMgFXPYqz0zaYhqFdafV14xbJzR)B(2(cLJFna5da5bGI3A80ZoEOKTkxOwcYb0RKbCdJgG8bG8aqXBnoEb9zU6f6sfmfkh)AasLoau8wJNGAVWJAfXXVgasdqQ0bGI3A80ZoEOKTkxOwcYb0RKbCRZmaPshq6F257w8RGXS1)nFBFHYxcHfLyaqyaDCaYhakERXtp74Hs2QCHAjihqVsgWnmAaiL1SMDEuwO0AA8vUNS73Y9KDOYqz0jdXSJL04RSZsi(vqmsi8DJsPn7CirAJln(k7aNHYcLwtJVgW(QPXxzN0gkTHLDSKgyjpveIGedOxjdOJdq(aWAByOmIVD9O4TMiRz3Xm3t2HkdLrNmeZoPnuAdl703aqXBnoKbJffmpclbnkIJFna5da5bS4fnaimamhGuPdqngvkpsU6vJ9LGtLHYOZaKpau8wJhjx9QX(sWxcHfLyaqyaWsNb42daZbiv6asFDWdLJxmYeqPJVTu15UYPYqz0zaYhaYdafV144fJmbu64BlvDUR8LqyrjgaegaS0zaU9aWCasLoau8wJJxmYeqPJVTu15UYfQLGCaqyaDCainaKYowsJVYoT9fQxOBajL1S7Dm3t2HkdLrNmeZoPnuAdl703aqXBnoKbJffmpclbnkIJFna5dyXlAa9kzaDCaYhaYdafV14BGG4lHWIsmaimGooa5dafV14BGG44xdqQ0byjnWs(ZR82(c13iS0oaimalPbwYtfHiiXaqk7yjn(k7a97YIcMhLzcnRz3XOCpzhQmugDYqm7K2qPnSStFdafV14qgmwuW8iSe0Oio(1aKpaXfXyE1wyKk4WywkmM3oyTkrdOxjdaZbiv6a6BaO4TghYGXIcMhHLGgfXXVgG8bG8aoekERXxRZ)nsexOwcYbaHbiJbiv6aoekERXxRZ)nseFjewuIbaHbalDgGBpamAaiLDSKgFLDGXSuymVDWAvIYA2DzK7j7qLHYOtgIzN0gkTHLDqXBnoKbJffmpclbnkIVKL0biFaIlIX8QTWivWB7lurYvfknGEhaMdq(a6BayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUQqPSMDhoK7j7qLHYOtgIzhlPXxzNhLfkTMszN0gkTHLDqXBnoKbJffmpclbnkIVKL0StY1eJ8QTWivKD)wwZU7wY9KDOYqz0jdXStAdL2WYowsdSKNkcrqIbiza3gG8bG12WqzeVTVq9cDdijF6RdEOISJL04RStBFH6f6gqszn7USj3t2HkdLrNmeZoPnuAdl7G12WqzeFFTL8BGGgG8biUigZR2cJubh63LffmpkZe6a6vYaWm7yjn(k7a97YIcMhLzcnRz37m5EYouzOm6KHy2jTHsByzhXfXyE1wyKk4WywkmM3oyTkrdOxjdaZSJL04RSdmMLcJ5TdwRsuwZUFtw5EYouzOm6KHy2XsA8v2PTVq9cDdiPStAdL2WYo9na1yuPCdRXSkbL4uzOm6ma5dOVbGI3ACidglkyEewcAueh)AasLoa1yuPCdRXSkbL4uzOm6ma5dOVbG12WqzeFFTL8BGGgGuPdaRTHHYi((Al53abna5dyXlIRbcYRVhZb0RKbalDYojxtmYR2cJur29Bzn7(TB5EYouzOm6KHy2jTHsByzhS2ggkJ47RTKFdeu2XsA8v2b63LffmpkZeAwZUFdZCpzhQmugDYqm7yjn(k78OSqP1uk7KCnXiVAlmsfz3VL1SMDqFHxJeKrbl3t29B5EYouzOm6KHy2XsA8v25rzHsRPu2j5AIrE1wyKkYUFl7K2qPnSSZIxrYF9DPDaqqYaqEayKmgq)dqngvkFXRi5nvPc304lovgkJodWThGmgaszNdjsBCPXxzhiUKPqhW3gGtuN1G9cBaU1KgyPb0zF104RSMDhZCpzhQmugDYqm7K2qPnSSdwBddLr8TRhfV1edqQ0byjnWsEQiebjgqVsgaMdqQ0bS4vK8xFxAhaegqhXCaYhWIxexdeKxFpMdacdyXRi5V(U0oa4oGBWHSJL04RSZsi(vqmsi8DJsPnRz37yUNSdvgkJoziMDsBO0gw2zXRi5V(U0oaimGoI5aKpGfViUgiiV(EmhaegWIxrYF9DPDaWDa3GdzhlPXxzNdzkuVvh)HsMRzn7ogL7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nqqdq(aqEalEfj)13L2b0RKbGrYyasLoGfViUgiiV((ooaiizaWsNbiv6aw8IA)cJ4RbJ8FZRqjFB)oNkFcQH4k(ItLHYOZaKkDaIlIX8QTWivWH(DzrbZJYmHoGELmamhGuPdafV14BGG4lHWIsmaimGooaKgGuPdyXRi5V(U0oaimGoI5aKpGfViUgiiV(EmhaegWIxrYF9DPDaWDa3GdzhlPXxzhOFxwuW8OmtOzn7UmY9KDOYqz0jdXStAdL2WYoO4TghYGXIcMhHLGgfXXVgG8biUigZR2cJubVTVqfjxvO0a6Dayoa5dOVbG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5QcLYA2D4qUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2bfV14qgmwuW8iSe0Oi(swsZojxtmYR2cJur29Bzn7UBj3t2HkdLrNmeZoPnuAdl7S4vK8xFxAhaeKma4GSgG8bS4fX1ab5133Xb07aGLozhlPXxzhO)w(V57gLsBwZUlBY9KDOYqz0jdXStAdL2WYoIlIX8QTWivWB7lurYvfknGEhaMdq(a6BayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUQqPSMDVZK7j7qLHYOtgIzhlPXxzNhLfkTMszN0gkTHLDw8ks(RVlT8d1IuOdO3bGPmgGuPdyXlIRbcYRVVJdacdaw6KDsUMyKxTfgPIS73YA29BYk3t2HkdLrNmeZoPnuAdl7G12WqzeFFTL8BGGYowsJVYoq)USOG5rzMqZA29B3Y9KDOYqz0jdXStAdL2WYolEfj)13L2baHbidzLDSKgFLDSnzf51FxQ0SM1SZAPWyICpz3VL7j7qLHYOtgIzhlPXxzhu2)hFdFDn7CirAJln(k70zTuySb4wrdwObjYoPnuAdl7GI3A8RGXS1)nFBFHYXVYA2DmZ9KDOYqz0jdXStAdL2WYoO4Tg)kymB9FZ32xOC8RSJL04RSdkTcAHmkyzn7EhZ9KDOYqz0jdXStAdL2WYoipG(gakERXVcgZw)38T9fkh)AaYhGL0al5PIqeKya9kzayoaKgGuPdOVbGI3A8RGXS1)nFBFHYXVgG8bG8aw8I4hQfPqhqVsgGmgG8bS4vK8xFxA5hQfPqhqVsgaCqwdaPSJL04RSJTjRi)fotqzn7ogL7j7qLHYOtgIzN0gkTHLDqXBn(vWy26)MVTVq54xzhlPXxzhwadQk8YUJFGHGknRz3LrUNSdvgkJoziMDsBO0gw2bfV14xbJzR)B(2(cLJFna5dafV14eIRVlT(fViFxYU(IJFLDSKgFLDSkrcDnMpzmwwZUdhY9KDOYqz0jdXStAdL2WYoO4Tg)kymB9FZ32xO8LqyrjgaeKmazZaKpau8wJFfmMT(V5B7luo(1aKpau8wJtiU(U06x8I8Dj76lo(v2XsA8v2PflHY()K1S7ULCpzhQmugDYqm7K2qPnSSdkERXVcgZw)38T9fkh)AaYhGL0al5PIqeKyasgWTbiFaipau8wJFfmMT(V5B7lu(siSOedacdqgdq(auJrLYtp74Hs2QCQmugDgGuPdOVbOgJkLNE2XdLSv5uzOm6ma5dafV14xbJzR)B(2(cLVeclkXaGWa64aqk7yjn(k7GAW8FZRBKGuK1SMDouZWzAUNS73Y9KDSKgFLDqe1X3wI6Ck7qLHYOtgIzn7oM5EYouzOm6KHy25VYocsZowsJVYoyTnmugLDWAmCk7G8aimgECDrhEuI0IRgkJ8ymCRuCe(dHns0aKkDaegdpUUOdxHs(wSc1lcybBaina5da5bK(ND(UfpkrAXvdLrEmgUvkoc)HWgjIVKDCDasLoG0)SZ3T4kuY3IvOEraly8LqyrjgasdqQ0bqym846IoCfk5BXkuViGfSbiFaegdpUUOdpkrAXvdLrEmgUvkoc)HWgjk7CirAJln(k7aNVewQ0biUOu0c6maDJcssfdaLIc2aWf0zaDdf6amC9ryAKgalksKDWARVmeu2rCrPOf0XRBuqsAwZU3XCpzhQmugDYqm78xzhbPzhlPXxzhS2ggkJYoyngoLDSKgyjpveIGedqYaUna5da5bSwC8ewQuUDocEudO3bCtgdqQ0b03awloEclvk3ohbNKziuXaqk7G1wFziOSJq9xmRQOGL1S7yuUNSdvgkJoziMD(RSJG0SJL04RSdwBddLrzhSgdNYowsdSKNkcrqIb0RKbG5aKpaKhqFdyT44jSuPC7CeCsMHqfdqQ0bSwC8ewQuUDocojZqOIbiFaipG1IJNWsLYTZrWxcHfLya9oazmaPshqlGbv9lHWIsmGEhWnznaKgaszhS26ldbLDSZr4xcHfvwZUlJCpzhQmugDYqm78xzhbPzhlPXxzhS2ggkJYoyngoLDqXBn(giio(1aKpaKhqFdyXlQ9lmIVgmY)nVcL8T97CQ8jOgIR4lovgkJodqQ0bS4f1(fgXxdg5)MxHs(2(Dov(eudXv8fNkdLrNbiFalEfj)13Lw(HArk0b07aKndaPSdwB9LHGYo7RTKFdeuwZUdhY9KDOYqz0jdXSZFLDeKMDSKgFLDWAByOmk7G1y4u2j91bpuoT2jsMgfmpk77oa5dafV140ANizAuW8OSVlxOwcYbizayoaPshq6RdEOC8IrMakD8TLQo3vovgkJodq(aqXBnoEXitaLo(2svN7kFjewuIbaHbG8aGLodWThaMdaPSdwB9LHGYoT9fQxOBaj5tFDWdvK1S7ULCpzhQmugDYqm78xzhbPzhlPXxzhS2ggkJYoyngoLDoKPq9wD8hkzUY1ibzuWgG8bKESuzLYRagu13mk7G1wFziOSZHmfQWFWjVL0alL1S7YMCpzhQmugDYqm7yjn(k7SeIFfeJecF3OuAZohsK24sJVYoU1RlMRdaoEFHoa4yclTUmaewuQf1aK9jxhqpg7lXaS6maij6AaDwcXVcIrcXaKDIsPDa7Zyrbl7K2qPnSSt6RdEOCclTT9f6aKpa1yuPCyMcL2OG5f6Vi4uzOm6ma5da5b03auJrLYFuwO0AA8fNkdLrNbiFaP)zNVBXVcgZw)38T9fkFjewuIbiv6aeK6r)cxW1GwmLnEm6kna5dqngvk)rzHsRPXxCQmugDgG8b03aqXBn(vWy26)MVTVq54xdaPSMDVZK7j7qLHYOtgIzhlPXxzhOFxwuW8OmtOzN0gkTHLD6BaNx5T9fQVryPLVeclkXaKpaKhGAmQuEKOKDXPYqz0zasLoG(gakERXrxYuO(V5frDwd2lmo(1aKpa1yuPC0LmfQ)BEruN1G9cJtLHYOZaKkDaQXOs5pkluAnn(ItLHYOZaKpG0)SZ3T4xbJzR)B(2(cLVeclkXaKpG(gakERXHmySOG5ryjOrrC8RbGu2j5AIrE1wyKkYUFlRz3VjRCpzhQmugDYqm7K2qPnSSdkERXJKRE1yFj4lHWIsmaiizaWsNb42daZbiFaQXOs5rYvVASVeCQmugDgG8biUigZR2cJubhgZsHX82bRvjAa9kzayoa5da5bOgJkLhjkzxCQmugDgGuPdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5di9p78Dlo6sMc1)nViQZAWEHXxcHfLya9oGBYyasLoa1yuP8hLfkTMgFXPYqz0zaYhqFdafV14xbJzR)B(2(cLJFnaKYowsJVYoWywkmM3oyTkrzn7(TB5EYouzOm6KHy2jTHsByzhu8wJhjx9QX(sWxcHfLyaqqYaGLodWThaMdq(auJrLYJKRE1yFj4uzOm6ma5da5bOgJkLhjkzxCQmugDgGuPdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5dOVbGI3AC0LmfQ)BEruN1G9cJJFna5di9p78Dlo6sMc1)nViQZAWEHXxcHfLya9oGBYAasLoa1yuP8hLfkTMgFXPYqz0zaYhqFdafV14xbJzR)B(2(cLJFnaKYowsJVYoT9fQxOBajL1S73Wm3t2HkdLrNmeZoPnuAdl7KESuzLYRagu13mAaYhWHmfQ3QJ)qjZvUgjiJc2aKpGdzkuVvh)HsMRClPbwYVeclkXaGWaqEaWsNb42d4gxgdaPbiFaipG(gGAmQu(JYcLwtJV4uzOm6maPshGAmQu(JYcLwtJV4uzOm6ma5dOVbGI3A8RGXS1)nFBFHYXVgaszhlPXxzNhLfkTMszn7(ToM7j7qLHYOtgIzNdjsBCPXxzh3a9Fbna3AsJVgale6a0FalELDSKgFLDsgJ5TKgF5zHqZoSqO(YqqzN0JLkRurwZUFdJY9KDOYqz0jdXSJL04RStYymVL04lpleA2Hfc1xgck7SwkmMiRz3VjJCpzhQmugDYqm7yjn(k7KmgZBjn(YZcHMDyHq9LHGYo6gfKKkYA29BWHCpzhQmugDYqm7yjn(k7KmgZBjn(YZcHMDyHq9LHGYoP)zNVBjYA29BULCpzhQmugDYqm7K2qPnSSJAmQuE6zhpuYwLtLHYOZaKpaKhqFdafV14qgmwuW8iSe0Oio(1aKkDaQXOs5Olzku)38IOoRb7fgNkdLrNbG0aKpaKhWHqXBn(AD(VrI4c1sqoajdqgdqQ0b03aoKPq9qwbmOkFXlQ9lmIVwN)BKObGu2rOBK0S73YowsJVYojJX8wsJV8SqOzhwiuFziOSt6zhpuYwnRz3VjBY9KDOYqz0jdXStAdL2WYoO4TghDjtH6)Mxe1znyVW44xzhHUrsZUFl7yjn(k7S4L3sA8LNfcn7WcH6ldbLDqFHxJeKrblRz3V1zY9KDOYqz0jdXStAdL2WYoQXOs5Olzku)38IOoRb7fgNkdLrNbiFaipG0)SZ3T4Olzku)38IOoRb7fgFjewuIbaHbCtwdaPbiFaipG1IJNWsLYTZrWJAa9oamLXaKkDa9nG1IJNWsLYTZrWjzgcvmaPshq6F257w8RGXS1)nFBFHYxcHfLyaqya3K1aKpG1IJNWsLYTZrWjzgcvma5dyT44jSuPC7Ce8OgaegWnznaKYowsJVYolE5TKgF5zHqZoSqO(Yqqzh0x4V(NffSSMDhtzL7j7qLHYOtgIzN0gkTHLDqXBn(vWy26)MVTVq54xdq(auJrLYFuwO0AA8fNkdLrNSJq3iPz3VLDSKgFLDw8YBjn(YZcHMDyHq9LHGYopkluAnn(kRz3X8wUNSdvgkJoziMDsBO0gw2PVbii1J(fUGRbTykB8y0vAaYhGAmQu(JYcLwtJV4uzOm6ma5di9p78Dl(vWy26)MVTVq5lHWIsmaimGBYAaYhaYdaRTHHYiUq9xmRQOGnaPshWAXXtyPs525i4KmdHkgG8bSwC8ewQuUDocEudacd4MSgGuPdOVbSwC8ewQuUDocojZqOIbGu2XsA8v2zXlVL04lpleA2Hfc1xgck78OSqP104l)1)SOGL1S7yIzUNSdvgkJoziMDsBO0gw2XsAGL8uricsmGELmamZocDJKMD)w2XsA8v2zXlVL04lpleA2Hfc1xgck7ypL1S7y2XCpzhQmugDYqm7yjn(k7KmgZBjn(YZcHMDyHq9LHGYoc1QJTNSM1SJ9uUNS73Y9KDOYqz0jdXSZHePnU04RSJB9X4gqN9vtJVYowsJVYolH4xbXiHW3nkL2SMDhZCpzhQmugDYqm7K2qPnSSJAmQuEBFHksUQqjovgkJozhlPXxzhymlfgZBhSwLOSMDVJ5EYouzOm6KHy2jTHsByzhu8wJdzWyrbZJWsqJI4lzjDaYhqFdaRTHHYi(HmfQWFWjVL0alLDSKgFLDA7lurYvfkL1S7yuUNSdvgkJoziMDsBO0gw2bRTHHYi((Al53abna5dqngvk3WAmRsqjovgkJozhlPXxzhOFxwuW8OmtOzn7UmY9KDOYqz0jdXStAdL2WYo9nau8wJVbcIJFna5dWsAGL8uricsmaiizaDCasLoalPbwYtfHiiXa6DaDm7yjn(k7aJzPWyE7G1QeL1S7WHCpzhQmugDYqm7yjn(k702xOEHUbKu2j5AIrE1wyKkYUFl7K2qPnSSt6F257w8Lq8RGyKq47gLslFjewuIbabjdaZb42daw6ma5dqngvkhMPqPnkyEH(lcovgkJozNdjsBCPXxzh44FrGZSina76AFlbDa6pG0sMsdWgWLGWp)aU243qDDaQTWiDaSqOdO97aSRlMRrbBaR15)gjAarna7PSMD3TK7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nqqzhlPXxzhOFxwuW8OmtOzn7USj3t2HkdLrNmeZoPnuAdl7OgJkLdZuO0gfmVq)fbNkdLrNbiFaO4TgFje)kigje(UrP0YXVgG8byjnWsEQiebjgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZU3zY9KDOYqz0jdXStAdL2WYoyTnmugXpKPqf(do5TKgyPbiFaO4Tg)qMcv4p4exOwcYbaHbGrdqQ0bOgJkLdZuO0gfmVq)fbNkdLrNbiFaO4TgFje)kigje(UrP0YXVYowsJVYopkluAnLYA29BYk3t2HkdLrNmeZowsJVYoT9fQxOBajLDsBO0gw2zXRi5V(U0YpulsHoaimaKhWnzmG(hGAmQu(IxrYBQsfUPXxCQmugDgGBpazmaKYojxtmYR2cJur29Bzn7(TB5EYouzOm6KHy2jTHsByzN(gawBddLr8dzkuH)GtElPbwk7yjn(k702xOIKRkukRz3VHzUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2zXRi5V(U0YpulsHoGEhaYdatzmG(hGAmQu(IxrYBQsfUPXxCQmugDgGBpazmaKYojxtmYR2cJur29Bzn7(ToM7j7yjn(k7aJzPWyE7G1QeLDOYqz0jdXSMD)ggL7j7yjn(k702xOIKRkuk7qLHYOtgIzn7(nzK7j7qLHYOtgIzhlPXxzN2(c1l0nGKYojxtmYR2cJur29Bzn7(n4qUNSJL04RSd0Fl)38DJsPn7qLHYOtgIzn7(n3sUNSJL04RSJTjRiV(7sLMDOYqz0jdXSM1St6XsLvQi3t29B5EYouzOm6KHy2XsA8v25qMcv4p4u25qI0gxA8v2XnpwQSshGBfnyHgKi7K2qPnSSdYdOVbOgJkL)OSqP104lovgkJodqQ0bOgJkL)OSqP104lovgkJodq(aSKgyjpveIGedOxjdaZbiFaP)zNVBXVcgZw)38T9fkFjewuIbiv6aSKgyjpveIGedqYaUnaKgG8bG8aWAByOmIlu)fZQkkydqQ0bG12Wqze3ohHFjewudaPSMDhZCpzhQmugDYqm7K2qPnSSZIxrYF9DPLFOwKcDa9oGBDCaYhq6F257w8RGXS1)nFBFHYxcHfLyaqyaDCaYhqFdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5daRTHHYiUq9xmRQOGLDSKgFLDeDTfruW8icHM1S7Dm3t2HkdLrNmeZoPnuAdl703auJrLYrxYuO(V5frDwd2lmovgkJodq(aWAByOmIBNJWVeclQSJL04RSJORTiIcMhri0SMDhJY9KDOYqz0jdXStAdL2WYoQXOs5Olzku)38IOoRb7fgNkdLrNbiFaipau8wJJUKPq9FZlI6SgSxyC8RbiFaipaS2ggkJ4c1FXSQIc2aKpGfVIK)67sl)qTif6a6DayKSgGuPdaRTHHYiUDoc)siSOgG8bS4vK8xFxA5hQfPqhqVdaoiRbiv6aWAByOmIBNJWVeclQbiFaRfhpHLkLBNJGVeclkXaGWa6mdq(awloEclvk3ohbNKziuXaqAasLoG(gakERXrxYuO(V5frDwd2lmo(1aKpG0)SZ3T4Olzku)38IOoRb7fgFjewuIbGu2XsA8v2r01werbZJieAwZUlJCpzhQmugDYqm7K2qPnSSt6F257w8RGXS1)nFBFHYxcHfLyaqyaDCaYhawBddLrCH6VywvrbBaYhaYdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5dyXRi5V(U0oGEhaCqgdq(as)ZoF3IJUKPq9FZlI6SgSxy8LqyrjgaegaMdqQ0b03auJrLYrxYuO(V5frDwd2lmovgkJodaPSJL04RSJH(iIY04lplqGM1S7WHCpzhQmugDYqm7K2qPnSSdwBddLrC7Ce(LqyrLDSKgFLDm0hruMgF5zbc0SMD3TK7j7qLHYOtgIzN0gkTHLDWAByOmIlu)fZQkkydq(aqEaP)zNVBXVcgZw)38T9fkFjewuIbaHb0Xbiv6auJrLYJeLSlovgkJodaPSJL04RSJaQLGKrEfk5XRU)QqDnRz3Ln5EYouzOm6KHy2jTHsByzhS2ggkJ425i8lHWIk7yjn(k7iGAjizKxHsE8Q7VkuxZA29otUNSdvgkJoziMDsBO0gw2PVbGI3A8RGXS1)nFBFHYXVgG8bG8aepodnQd)cxO4mYtl(LgFXPYqz0zasLoaXJZqJ6WX(mtdg5fpdlvkNkdLrNbiFa9nau8wJJ9zMgmYlEgwQuo(1aqk7eLs7IFP(OLDepodnQdh7ZmnyKx8mSuPzNOuAx8l1hiqqNWuk7Cl7yjn(k70yKaAATMMDIsPDXVupm2JASSZTSM1SZ1sPhbQP5EYUFl3t2HkdLrNmeZo)v2rqA0YoPnuAdl7OBuqskxVXHAcpUG8O4T2aKpaKhqFdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5da5bOBuqskxVXt)ZoF3IFWxtJVgGSDaP)zNVBXVcgZw)38T9fk)GVMgFnajdqwdaPbiv6auJrLYrxYuO(V5frDwd2lmovgkJodq(aqEaP)zNVBXrxYuO(V5frDwd2lm(bFnn(AaY2bOBuqskxVXt)ZoF3IFWxtJVgGKbiRbG0aKkDaQXOs5rIs2fNkdLrNbGu25qI0gxA8v2bJdRXWnLedWgGUrbjPIbK(ND(ULld4eyJdDgaQRd4kymBhW3gqBFHoGFha6sMcDaFBaIOoRb7f2DXas)ZoF3IpazFBaHExmaSgdNgautmG6hWsiSOo0oGLu8TgWnxgaXe0awsX3AaYIldE2bRT(YqqzhDJcss938cxRu2XsA8v2bRTHHYOSdwJHtEIjOSJS4Yi7G1y4u25wwZUJzUNSdvgkJoziMD(RSJG0OLDSKgFLDWAByOmk7G1wFziOSJUrbjPEm9cxRu2jTHsByzhDJcss5kMCOMWJlipkERna5da5b03auJrLYrxYuO(V5frDwd2lmovgkJodq(aqEa6gfKKYvm5P)zNVBXp4RPXxdq2oG0)SZ3T4xbJzR)B(2(cLFWxtJVgGKbiRbG0aKkDaQXOs5Olzku)38IOoRb7fgNkdLrNbiFaipG0)SZ3T4Olzku)38IOoRb7fg)GVMgFnaz7a0nkijLRyYt)ZoF3IFWxtJVgGKbiRbG0aKkDaQXOs5rIs2fNkdLrNbGu2bRXWjpXeu2rwCzKDWAmCk7ClRz37yUNSdvgkJoziMD(RSJG0OLDsBO0gw2PVbOBuqskxVXHAcpUG8O4T2aKpaDJcss5kMCOMWJlipkERnaPshGUrbjPCftout4XfKhfV1gG8bG8aqEa6gfKKYvm5P)zNVBXp4RPXxdaUdq3OGKuUIjhfV18h8104RbG0aC7bG8aUXLXa6Fa6gfKKYvm5qnHhfV14cDPcMcDaina3EaipaS2ggkJ46gfKK6X0lCTsdaPbG0a6DaipaKhGUrbjPC9gp9p78Dl(bFnn(AaWDa6gfKKY1BCu8wZFWxtJVgasdWThaYd4gxgdO)bOBuqskxVXHAcpkERXf6sfmf6aqAaU9aqEayTnmugX1nkij1FZlCTsdaPbGu25qI0gxA8v2bJtObctjXaSbOBuqsQyayngonauxhq6rCzBuWgGcLgq6F257wd4BdqHsdq3OGKuxgWjWgh6mauxhGcLgWbFnn(AaFBakuAaO4T2acDax7JnoKGpa4OmXaSbi0Lkyk0bG4prlODa6paybwAa2aGgWGs7aU243qDDa6paHUubtHoaDJcssfUmatmGUeJnatmaBai(t0cAhq73beTbydq3OGK0b0nySb87a6gm2aQxhGW1knGUHcDaP)zNVBj4zhS26ldbLD0nkij1FTXVH6A2XsA8v2bRTHHYOSdwJHtEIjOSZTSdwJHtzhmZA2Dmk3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzh1yuPCyMcL2OG5f6Vi4uzOm6maPshq6RdEOCclTT9fkNkdLrNbiv6aw8IA)cJ4OHgfmF6zhovgkJozhS26ldbLD2UEu8wtK1S7Yi3t2XsA8v2PXib00Ann7qLHYOtgIznRzN0)SZ3Te5EYUFl3t2HkdLrNmeZoPnuAdl7GI3A8RGXS1)nFBFHYXVYohsK24sJVYoW5VgFLDSKgFLDUEn(kRz3Xm3t2HkdLrNmeZowsJVYoeIRVlT(fViFxYU(k7CirAJln(k74M)zNVBjYoPnuAdl7OgJkL)OSqP104lovgkJodq(aw8IgaegaCyaYhaYdaRTHHYiUq9xmRQOGnaPshawBddLrC7Ce(LqyrnaKgG8bG8as)ZoF3IFfmMT(V5B7lu(siSOedacdqgdq(aqEaP)zNVBXBmsanTwt5lHWIsmGEhGmgG8biECgAuh(fUqXzKNw8ln(ItLHYOZaKkDa9naXJZqJ6WVWfkoJ80IFPXxCQmugDgasdqQ0bGI3A8RGXS1)nFBFHYXVgasdqQ0bG(cXaKpGwadQ6xcHfLyaqyaykRSMDVJ5EYouzOm6KHy2jTHsByzh1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpGfVObaHbiJbiFalEfj)13L2baHbG8aGdYAay8d4qMc1dzfWGQ8fVO2VWiouxfkTHna3EaYyay8dyXlQ9lmIVgIlRuVUwjA0svI4uzOm6ma3EaYyaina5da5bGI3AC0LmfQ)BEruN1G9cJJFnaPshqlGbv9lHWIsmaimamL1aqk7yjn(k7qiU(U06x8I8Dj76RSMDhJY9KDOYqz0jdXStAdL2WYoQXOs5rIs2fNkdLrNSJL04RSdH467sRFXlY3LSRVYA2DzK7j7qLHYOtgIzN0gkTHLDuJrLYrxYuO(V5frDwd2lmovgkJodq(aqEayTnmugXfQ)IzvffSbiv6aWAByOmIBNJWVeclQbG0aKpaKhq6F257wC0LmfQ)BEruN1G9cJVeclkXaKkDaP)zNVBXrxYuO(V5frDwd2lm(s2X1biFalEfj)13L2b07aGdYyaiLDSKgFLDUcgZw)38T9fAwZUdhY9KDOYqz0jdXStAdL2WYoQXOs5rIs2fNkdLrNbiFa9nau8wJFfmMT(V5B7luo(v2XsA8v25kymB9FZ32xOzn7UBj3t2HkdLrNmeZoPnuAdl7OgJkL)OSqP104lovgkJodq(aqEalEfj)13L2b0RKb0rzma5dOVbGI3ACd9reLPXxEwGaLJFnaPshakERXn0hruMgF5zbcuo(1aqAaYhaYdaRTHHYiUq9xmRQOGnaPshawBddLrC7Ce(LqyrnaKgG8bG8auJrLYHzkuAJcMxO)IGtLHYOZaKpau8wJVeIFfeJecF3OuA54xdqQ0b03auJrLYHzkuAJcMxO)IGtLHYOZaqk7yjn(k7CfmMT(V5B7l0SMDx2K7j7qLHYOtgIzN0gkTHLDqXBn(vWy26)MVTVq54xzhlPXxzh0LmfQ)BEruN1G9clRz37m5EYouzOm6KHy2jTHsByzhlPbwYtfHiiXaKmGBdq(aqXBn(vWy26)MVTVq5lHWIsmaimayPZaKpau8wJFfmMT(V5B7luo(1aKpG(gGAmQu(JYcLwtJV4uzOm6ma5da5b03awloEclvk3ohbNKziuXaKkDaRfhpHLkLBNJGh1a6DaDuwdaPbiv6aAbmOQFjewuIbaHb0XSJL04RStBFH211fHW3WxxZA29BYk3t2HkdLrNmeZoPnuAdl7yjnWsEQiebjgqVsgaMdq(aqEaO4Tg)kymB9FZ32xOC8Rbiv6awloEclvk3ohbNKziuXaKpG1IJNWsLYTZrWJAa9oG0)SZ3T4xbJzR)B(2(cLVeclkXa6FaULbG0aKpaKhakERXVcgZw)38T9fkFjewuIbaHbalDgGuPdyT44jSuPC7CeCsMHqfdq(awloEclvk3ohbFjewuIbaHbalDgaszhlPXxzN2(cTRRlcHVHVUM1S73UL7j7qLHYOtgIzN0gkTHLDuJrLYFuwO0AA8fNkdLrNbiFaipau8wJFfmMT(V5B7luo(1aKpG(gaclkpuRoCmHoaPshqFdafV14xbJzR)B(2(cLJFna5daHfLhQvhoMqhG8bK(ND(Uf)kymB9FZ32xO8Lqyrjgasdq(aqEaipau8wJFfmMT(V5B7lu(siSOedacdaw6maPshakERXXlOpZvVqxQGPq54xdq(aqXBnoEb9zU6f6sfmfkFjewuIbaHbalDgasdq(aqEahcfV14R15)gjIlulb5aKmazmaPshqFd4qMc1dzfWGQ8fVO2VWi(AD(VrIgasdaPSJL04RStBFH211fHW3WxxZA29ByM7j7qLHYOtgIzN0gkTHLDuJrLYrxYuO(V5frDwd2lmovgkJodq(aw8ks(RVlTdacdaoiRbiFalErdacsgqhhG8bG8aqXBno6sMc1)nViQZAWEHXXVgGuPdi9p78Dlo6sMc1)nViQZAWEHXxcHfLya9oamswdaPbiv6a6BaQXOs5Olzku)38IOoRb7fgNkdLrNbiFalEfj)13L2babjdWTiJSJL04RSduxVEfkTiIK)AjbvjkRz3V1XCpzhQmugDYqm7K2qPnSSt6F257w8RGXS1)nFBFHYxcHfLyaqqYaKr2XsA8v2zTqq(dzNSMD)ggL7j7qLHYOtgIzN0gkTHLDSKgyjpveIGedOxjdaZbiFaipGwadQ6xcHfLyaqyaDCasLoG(gakERXrxYuO(V5frDwd2lmo(1aKpaKhWfPCyqFCgFjewuIbaHbalDgGuPdyT44jSuPC7CeCsMHqfdq(awloEclvk3ohbFjewuIbaHb0XbiFaRfhpHLkLBNJGh1a6DaxKYHb9Xz8LqyrjgasdaPSJL04RSJWsB0Iuym)LL0SMD)MmY9KDOYqz0jdXStAdL2WYowsdSKNkcrqIb07aKXaKkDalErTFHr8lOKTpIVibNkdLrNSJL04RSZHmfQ3QJ)qjZ1SM1SJUrbjPICpz3VL7j7qLHYOtgIzNdjsBCPXxzNE2OGKur2Pmeu2jkrAXvdLrEmgUvkoc)HWgjk7K2qPnSStFdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5dafV14xbJzR)B(2(cLJFna5dafV14eIRVlT(fViFxYU(IJFnaPshGAmQuo6sMc1)nViQZAWEHXPYqz0zaYhaYda5bGI3A8RGXS1)nFBFHYXVgG8bK(ND(UfhDjtH6)Mxe1znyVW4lzhxhasdqQ0bG8aqXBn(vWy26)MVTVq54xdq(aqEaipGwadQ6xcHfLyay8di9p78Dlo6sMc1)nViQZAWEHXxcHfLyainaimamVnaKgasdaPbiv6aqFHyaYhqlGbv9lHWIsmaimamVnaPshWHmfQhYkGbv5NqyOmYhySJNKjLWvAasgGSgG8bO2cJuUgiiV((RK6XuwdacdqgzhlPXxzNOePfxnug5Xy4wP4i8hcBKOSMDhZCpzhQmugDYqm7ugck7aZWsm)38kuY3IvOEBrdL2SJL04RSdmdlX8FZRqjFlwH6TfnuAZA29oM7j7qLHYOtgIzNYqqzhrYwH)B(2AkTLX8cDJgLDSKgFLDejBf(V5BRP0wgZl0nAuwZUJr5EYouzOm6KHy2XsA8v2rHs(wSc1lcybl7K2qPnSSdkERXVcgZw)38T9fkh)AaYhakERXjexFxA9lEr(UKD9fh)k7ugck7OqjFlwH6fbSGL1S7Yi3t2HkdLrNmeZowsJVYo6gfKKEl7CirAJln(k70duAa6gfKKoGUHcDakuAaqdyqjHoasObctPZaWAmCYLb0nySbGsdaxqNb0IvOdWQZaUSyPZa6gk0baNhmMTd4BdaoEFHYZoPnuAdl703aWAByOmIlUOu0c641nkijDaYhakERXVcgZw)38T9fkh)AaYhaYdOVbOgJkLhjkzxCQmugDgGuPdqngvkpsuYU4uzOm6ma5dafV14xbJzR)B(2(cLVeclkXa6vYaUjRbG0aKpaKhqFdq3OGKuUIjhQj8P)zNVBnaPshGUrbjPCftE6F257w8LqyrjgGuPdaRTHHYiUUrbjP(Rn(nuxhGKbCBainaPshGUrbjPC9ghfV18h8104Rb0RKb0cyqv)siSOezn7oCi3t2HkdLrNmeZoPnuAdl703aWAByOmIlUOu0c641nkijDaYhakERXVcgZw)38T9fkh)AaYhaYdOVbOgJkLhjkzxCQmugDgGuPdqngvkpsuYU4uzOm6ma5dafV14xbJzR)B(2(cLVeclkXa6vYaUjRbG0aKpaKhqFdq3OGKuUEJd1e(0)SZ3TgGuPdq3OGKuUEJN(ND(UfFjewuIbiv6aWAByOmIRBuqsQ)AJFd11bizayoaKgGuPdq3OGKuUIjhfV18h8104Rb0RKb0cyqv)siSOezhlPXxzhDJcssXmRz3Dl5EYouzOm6KHy2XsA8v2r3OGK0Bzhb71SJUrbjP3YoPnuAdl703aWAByOmIlUOu0c641nkijDaYhaYdOVbOBuqskxVXHAcpUG8O4T2aKpaKhGUrbjPCftE6F257w8LqyrjgGuPdOVbOBuqskxXKd1eECb5rXBTbG0aKkDaP)zNVBXVcgZw)38T9fkFjewuIb07aWuwdaPSZHePnU04RSJSVnGVyUoGVOb81aWf0a0nkijDax7JnoKya2aqXBnxgaUGgGcLgWRqPDaFnG0)SZ3T4daoBhq0gqrHcL2bOBuqs6aU2hBCiXaSbGI3AUmaCbna0xHoGVgq6F257w8SMDx2K7j7qLHYOtgIzhlPXxzhDJcssXm7K2qPnSStFdaRTHHYiU4IsrlOJx3OGK0biFaipG(gGUrbjPCftout4XfKhfV1gG8bG8a0nkijLR34P)zNVBXxcHfLyasLoG(gGUrbjPC9ghQj84cYJI3AdaPbiv6as)ZoF3IFfmMT(V5B7lu(siSOedO3bGPSgaszhb71SJUrbjPyM1SMDqFH)6FwuWY9KD)wUNSdvgkJoziMDSKgFLDwcXVcIrcHVBukTzNdjsBCPXxzhiUKPqhW3gGtuN1G9cBax)ZIc2a2xnn(AaDyac1wvmGBYsmauQ9lnai(odiedWWAbZqzu2jTHsByzhlPbwYtfHiiXa6vYaWCasLoaS2ggkJ4BxpkERjYA2DmZ9KDOYqz0jdXSJL04RSZJYcLwtPStAdL2WYoO4TghYGXIcMhHLGgfXxYs6aKpG0)SZ3T4xbJzR)B(2(cLVeclkXa6DaDm7KCnXiVAlmsfz3VL1S7Dm3t2HkdLrNmeZoPnuAdl7G12WqzeFFTL8BGGYowsJVYoq)USOG5rzMqZA2Dmk3t2HkdLrNmeZoPnuAdl7GI3ACidglkyEewcAueFjlPdq(aw8ks(RVlT8d1IuOdO3bG8aUjJb0)auJrLYx8ksEtvQWnn(ItLHYOZaC7biJbG0aKpaXfXyE1wyKk4T9fQi5QcLgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZUlJCpzhQmugDYqm7K2qPnSSZIxrYF9DPLFOwKcDa9kzaipGokJb0)auJrLYx8ksEtvQWnn(ItLHYOZaC7biJbG0aKpaXfXyE1wyKk4T9fQi5QcLgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZUdhY9KDOYqz0jdXSJL04RSZJYcLwtPStAdL2WYolEfj)13Lw(HArk0b0RKbGPmYojxtmYR2cJur29Bzn7UBj3t2HkdLrNmeZoPnuAdl7S4vK8xFxA5hQfPqhaegaMYAaYhG4IymVAlmsfCymlfgZBhSwLOb0RKbG5aKpG0)SZ3T4xbJzR)B(2(cLVeclkXa6DaYi7yjn(k7aJzPWyE7G1QeL1S7YMCpzhQmugDYqm7yjn(k702xOEHUbKu2jTHsByzNfVIK)67sl)qTif6aGWaWuwdq(as)ZoF3IFfmMT(V5B7lu(siSOedO3biJStY1eJ8QTWivKD)wwZU3zY9KDOYqz0jdXStAdL2WYoP)zNVBXVcgZw)38T9fkFjewuIb07aw8I4AGG867XObiFalEfj)13Lw(HArk0baHbGrYAaYhG4IymVAlmsfCymlfgZBhSwLOb0RKbGz2XsA8v2bgZsHX82bRvjkRz3VjRCpzhQmugDYqm7yjn(k702xOEHUbKu2jTHsByzN0)SZ3T4xbJzR)B(2(cLVeclkXa6DalErCnqqE99y0aKpGfVIK)67sl)qTif6aGWaWizLDsUMyKxTfgPIS73YAwZoc1QJTNCpz3VL7j7qLHYOtgIzhlPXxzNLq8RGyKq47gLsB25qI0gxA8v2XrT6y7zaIOGXimE1wyKoG9vtJVYoPnuAdl7G12WqzeF76rXBnrwZUJzUNSdvgkJoziMDsBO0gw2bfV14qgmwuW8iSe0Oi(swsZowsJVYopkluAnLYA29oM7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nqqdq(aqXBn(gii(siSOedacdOJzhlPXxzhOFxwuW8OmtOzn7ogL7j7qLHYOtgIzN0gkTHLDWAByOmI32xOEHUbKKp91bpur2XsA8v2PTVq9cDdiPSMDxg5EYouzOm6KHy2jTHsByzN(gWHmfQhYkGbv5lErTFHr8168FJena5da5bCiu8wJVwN)BKiUqTeKdacdqgdqQ0bCiu8wJVwN)BKi(siSOedacdaw6ma3Eay0aqk7yjn(k7aJzPWyE7G1QeL1S7WHCpzhQmugDYqm7K2qPnSSt6F257w8Lq8RGyKq47gLslFjewuIbabjdaZb42daw6ma5dqngvkhMPqPnkyEH(lcovgkJozhlPXxzN2(c1l0nGKYA2D3sUNSdvgkJoziMDsBO0gw2bRTHHYi((Al53abLDSKgFLDG(DzrbZJYmHM1S7YMCpzhQmugDYqm7K2qPnSSZIxrYF9DPLFOwKcDaqyaipGBYya9pa1yuP8fVIK3uLkCtJV4uzOm6ma3EaYyaiLDSKgFLDA7luVq3askRz37m5EYouzOm6KHy2jTHsByzN(gakERXB735u5VWzcIJFna5dqngvkVTFNtL)cNjiovgkJodqQ0bG12Wqze)qMcv4p4K3sAGLgG8bGI3A8dzkuH)GtCHAjihaegagnaPshGAmQuomtHsBuW8c9xeCQmugDgG8bGI3A8Lq8RGyKq47gLslh)AasLoGfVIK)67sl)qTif6a6DaipamLXa6FaQXOs5lEfjVPkv4MgFXPYqz0zaU9aKXaqk7yjn(k78OSqP1ukRz3VjRCpzhlPXxzN2(c1l0nGKYouzOm6KHywZUF7wUNSJL04RSd0Fl)38DJsPn7qLHYOtgIzn7(nmZ9KDSKgFLDSnzf51FxQ0SdvgkJoziM1SM1SdwAfXxz3XuwyIPS6OSULD6ABffmr2r2XT2zDx27oCKomGb0duAabIRF1b0(Da3FuwO0AA8L)6FwuWUpGLWy4XsNbiEe0amC9rykDgqcQvWibFGVtrrdaZoma38fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7dW0bGXbN1PbG8nzIeFGFGx2XT2zDx27oCKomGb0duAabIRF1b0(Da3tp74Hs2Q3hWsym8yPZaepcAagU(imLodib1kyKGpW3POObCRddWnFHLwLod4(Ixu7xyehd3hG(d4(Ixu7xyehdCQmugDUpaKXizIeFGVtrrdaZoma38fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYej(aFNIIgqh7WaCZxyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKVjtK4d8DkkAayuhgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG8nzIeFGVtrrdqgDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haY3Kjs8b(bEzh3AN1DzV7Wr6WagqpqPbeiU(vhq73bC)rzHsRPXx3hWsym8yPZaepcAagU(imLodib1kyKGpW3POObGzhgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG8nzIeFGVtrrdaZoma38fwAv6mG7PVo4HYXW9bO)aUN(6GhkhdCQmugDUpaKVjtK4d8DkkAa3KvhgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bGmMYej(a)aVSJBTZ6US3D4iDyadOhO0acex)QdO97aUJ(cVgjiJc29bSegdpw6maXJGgGHRpctPZasqTcgj4d8DkkAa36WaCZxyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKVjtK4d8DkkAay2Hb4MVWsRsNb4eiCZaeUwQjZbiBhG(dOt42aob2qeFnG)Iwt)DaidxKgaY3Kjs8b(offnGo2Hb4MVWsRsNb4eiCZaeUwQjZbiBhG(dOt42aob2qeFnG)Iwt)DaidxKgaY3Kjs8b(offnamQddWnFHLwLodWjq4MbiCTutMdq2oa9hqNWTbCcSHi(Aa)fTM(7aqgUinaKVjtK4d8DkkAayuhgGB(clTkDgW9fVO2VWiogUpa9hW9fVO2VWiog4uzOm6CFaiFtMiXh4h4LDCRDw3L9UdhPddya9aLgqG46xDaTFhW90JLkRuX9bSegdpw6maXJGgGHRpctPZasqTcgj4d8DkkAa36WaCZxyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKXuMiXh47uu0aWSddWnFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MmrIpW3POOb0Xoma38fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYej(aFNIIgag1Hb4MVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiFtMiXh47uu0aKrhgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bGmMYej(aFNIIgGBPddWnFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MmrIpW3POOb0z6WaCZxyPvPZaUlECgAuhogUpa9hWDXJZqJ6WXaNkdLrN7dazmLjs8b(bEzh3AN1DzV7Wr6WagqpqPbeiU(vhq73bCxOwDS9CFalHXWJLodq8iOby46JWu6mGeuRGrc(aFNIIgaCOddWnFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(amDayCWzDAaiFtMiXh47uu0aKnDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haY3Kjs8b(offnGothgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bGChLjs8b(bEzh3AN1DzV7Wr6WagqpqPbeiU(vhq73bCh9f(R)zrb7(awcJHhlDgG4rqdWW1hHP0zajOwbJe8b(offnamQddWnFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MmrIpW3POObiJoma38fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYej(a)aVSJBTZ6US3D4iDyadOhO0acex)QdO97aUFTu6rGA69bSegdpw6maXJGgGHRpctPZasqTcgj4d8DkkAa36WaCZxyPvPZaCceUzacxl1K5aKTY2bO)a6eUnae)bNHlgWFrRP)oaKLTinaKXuMiXh47uu0aU1Hb4MVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFai3rzIeFGVtrrd4whgGB(clTkDgWDDJcss534y4(a0Fa31nkijLR34y4(aqUJYej(aFNIIgaMDyaU5lS0Q0zaobc3maHRLAYCaYwz7a0FaDc3gaI)GZWfd4VO10FhaYYwKgaYyktK4d8DkkAay2Hb4MVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFai3rzIeFGVtrrdaZoma38fwAv6mG76gfKKYXKJH7dq)bCx3OGKuUIjhd3haYDuMiXh47uu0a6yhgGB(clTkDgGtGWndq4APMmhGSDa6pGoHBd4eydr81a(lAn93bGmCrAaiJPmrIpW3POOb0Xoma38fwAv6mG76gfKKYVXXW9bO)aURBuqskxVXXW9bGmgjtK4d8DkkAaDSddWnFHLwLod4UUrbjPCm5y4(a0Fa31nkijLRyYXW9bGSmKjs8b(offnamQddWnFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MmrIpW3POObGrDyaU5lS0Q0za3x8IA)cJ4y4(a0Fa3x8IA)cJ4yGtLHYOZ9by6aW4GZ60aq(MmrIpW3POObGrDyaU5lS0Q0za3tFDWdLJH7dq)bCp91bpuog4uzOm6CFaiFtMiXh4h4LDCRDw3L9UdhPddya9aLgqG46xDaTFhW90)SZ3Te3hWsym8yPZaepcAagU(imLodib1kyKGpW3POObGzhgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG8nzIeFGVtrrdaZoma38fwAv6mG7IhNHg1HJH7dq)bCx84m0OoCmWPYqz05(aqgtzIeFGVtrrdOJDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haY3Kjs8b(offnGo2Hb4MVWsRsNbCFXlQ9lmIJH7dq)bCFXlQ9lmIJbovgkJo3haY3Kjs8b(offnamQddWnFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(amDayCWzDAaiFtMiXh47uu0aKrhgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG8nzIeFGVtrrdao0Hb4MVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiFtMiXh47uu0aClDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haY3Kjs8b(offnGothgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG8nzIeFGVtrrd42Toma38fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYej(aFNIIgWnm7WaCZxyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKXuMiXh47uu0aUjJoma38fwAv6mG7lErTFHrCmCFa6pG7lErTFHrCmWPYqz05(amDayCWzDAaiFtMiXh4h4LDCRDw3L9UdhPddya9aLgqG46xDaTFhWDDJcssf3hWsym8yPZaepcAagU(imLodib1kyKGpW3POObCRddWnFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aqgtzIeFGVtrrdqgDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haYyktK4d8DkkAaYOddWnFHLwLod4UUrbjP8BCmCFa6pG76gfKKY1BCmCFaiFtMiXh47uu0aKrhgGB(clTkDgWDDJcss5yYXW9bO)aURBuqskxXKJH7dazmLjs8b(offna4qhgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bGmMYej(aFNIIgaCOddWnFHLwLod4UUrbjP8BCmCFa6pG76gfKKY1BCmCFaiJPmrIpW3POObah6WaCZxyPvPZaURBuqskhtogUpa9hWDDJcss5kMCmCFaiFtMiXh47uu0aClDyaU5lS0Q0za31nkijLFJJH7dq)bCx3OGKuUEJJH7da5BYej(aFNIIgGBPddWnFHLwLod4UUrbjPCm5y4(a0Fa31nkijLRyYXW9bGmMYej(aFNIIgGSPddWnFHLwLod4UUrbjP8BCmCFa6pG76gfKKY1BCmCFaiJPmrIpW3POObiB6WaCZxyPvPZaURBuqskhtogUpa9hWDDJcss5kMCmCFaiFtMiXh4h4LDCRDw3L9UdhPddya9aLgqG46xDaTFhW9d1mCMEFalHXWJLodq8iOby46JWu6mGeuRGrc(aFNIIgGm6WaCZxyPvPZaUV4f1(fgXXW9bO)aUV4f1(fgXXaNkdLrN7dazmLjs8b(offna4qhgGB(clTkDgW90xh8q5y4(a0Fa3tFDWdLJbovgkJo3haY3Kjs8b(offnazthgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bGChLjs8b(offnGothgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bGChLjs8b(offnGBYQddWnFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aqgJKjs8b(offnGB36WaCZxyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaKXizIeFGVtrrd4gMDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haYyktK4d8DkkAa3ClDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haYyktK4d8DkkAa36mDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haY3Kjs8b(offnamLvhgGB(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9by6aW4GZ60aq(MmrIpW3POObG5Toma38fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYej(a)aVSJBTZ6US3D4iDyadOhO0acex)QdO97aUBpDFalHXWJLodq8iOby46JWu6mGeuRGrc(aFNIIgaMDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3hGPdaJdoRtda5BYej(aFNIIgag1Hb4MVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaMoamo4SonaKVjtK4d8DkkAaWHoma38fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7dW0bGXbN1PbG8nzIeFGVtrrdq20Hb4MVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiFtMiXh47uu0a6mDyaU5lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haY3Kjs8b(offnGBYQddWnFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq(MmrIpW3POObCdZoma38fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7da5BYej(a)aVShX1VkDgWTooalPXxdGfcvWh4Zox73cgLDGtWPbi7Imf6aKDRcyq1bahVVqh4HtWPbahDBtqhWToJldatzHjMd8d8Wj40aCduRGrIbE4eCAay8dOZsiES0zamtOy8ck91za4cdgnGVna3a1IsmGVnazFIgGjgqOd48KOURd4IzUoGUeJnGOgW1AjnseFGhobNgag)aKD91DDajOwveBaWXmsanTwthWbFJc2aG4sMcDaFBaorDwd2lm(a)apCAayCyngUPKya2a0nkijvmG0)SZ3TCzaNaBCOZaqDDaxbJz7a(2aA7l0b87aqxYuOd4Bdqe1znyVWUlgq6F257w8bi7Bdi07IbG1y40aGAIbu)awcHf1H2bSKIV1aU5YaiMGgWsk(wdqwCzWh4TKgFj4xlLEeOM2Ve4I12WqzKlLHGKOBuqsQ)Mx4ALC5VKiinAUG1y4KKBUG1y4KNycsIS4YWL0xNqJVKOBuqsk)ghQj84cYJI3AYrUp1yuPC0LmfQ)BEruN1G9ctoY6gfKKYVXt)ZoF3IFWxtJVKTY20)SZ3T4xbJzR)B(2(cLFWxtJVKilKKkvngvkhDjtH6)Mxe1znyVWKJC6F257wC0LmfQ)BEruN1G9cJFWxtJVKTYwDJcss534P)zNVBXp4RPXxsKfssLQgJkLhjkzxinWBjn(sWVwk9iqnTFjWfRTHHYixkdbjr3OGKupMEHRvYL)sIG0O5cwJHtsU5cwJHtEIjijYIldxsFDcn(sIUrbjPCm5qnHhxqEu8wtoY9PgJkLJUKPq9FZlI6SgSxyYrw3OGKuoM80)SZ3T4h8104lzRSn9p78Dl(vWy26)MVTVq5h8104ljYcjPsvJrLYrxYuO(V5frDwd2lm5iN(ND(UfhDjtH6)Mxe1znyVW4h8104lzRSv3OGKuoM80)SZ3T4h8104ljYcjPsvJrLYJeLSlKg4HtdaJtObctjXaSbOBuqsQyayngonauxhq6rCzBuWgGcLgq6F257wd4BdqHsdq3OGKuxgWjWgh6mauxhGcLgWbFnn(AaFBakuAaO4T2acDax7JnoKGpa4OmXaSbi0Lkyk0bG4prlODa6paybwAa2aGgWGs7aU243qDDa6paHUubtHoaDJcssfUmatmGUeJnatmaBai(t0cAhq73beTbydq3OGK0b0nySb87a6gm2aQxhGW1knGUHcDaP)zNVBj4d8wsJVe8RLspcut7xcCXAByOmYLYqqs0nkij1FTXVH6Ql)LebPrZfSgdNKGPlyngo5jMGKCZL0xNqJVK0NUrbjP8BCOMWJlipkERjx3OGKuoMCOMWJlipkERjvQUrbjPCm5qnHhxqEu8wtoYiRBuqskhtE6F257w8d(AA8LSv3OGKuoMCu8wZFWxtJVqYTr(gxg9RBuqskhtout4rXBnUqxQGPqrYTrgRTHHYiUUrbjPEm9cxResi1lYiRBuqsk)gp9p78Dl(bFnn(s2QBuqsk)ghfV18h8104lKCBKVXLr)6gfKKYVXHAcpkERXf6sfmfksUnYyTnmugX1nkij1FZlCTsiH0aVL04lb)AP0Ja10(LaxS2ggkJCPmeKKTRhfV1eUG1y4Ke1yuPCyMcL2OG5f6ViKkn91bpuoHL22(cvQ0fVO2VWioAOrbZNE2zG3sA8LGFTu6rGAA)sGBJrcOP1A6a)apCconamozsjCLodGWsRRdqde0auO0aSK(7acXamSwWmugXh4TKgFjKGiQJVTe150apCAaW5lHLkDaIlkfTGodq3OGKuXaqPOGnaCbDgq3qHoadxFeMgPbWIIed8wsJVe9lbUyTnmug5sziijIlkfTGoEDJcssDbRXWjjitym846Io8OePfxnug5Xy4wP4i8hcBKiPsjmgECDrhUcL8TyfQxeWcgsYro9p78DlEuI0IRgkJ8ymCRuCe(dHnseFj74QuPP)zNVBXvOKVfRq9IawW4lHWIsGKuPegdpUUOdxHs(wSc1lcybtoHXWJRl6WJsKwC1qzKhJHBLIJWFiSrIg4TKgFj6xcCXAByOmYLYqqseQ)IzvffmxWAmCsIL0al5PIqeKqYn5iVwC8ewQuUDocEu9EtgsL23AXXtyPs525i4KmdHkqAG3sA8LOFjWfRTHHYixkdbjXohHFjewuUG1y4KelPbwYtfHiirVsWuoY9TwC8ewQuUDocojZqOcPsxloEclvk3ohbNKziuHCKxloEclvk3ohbFjewuIELHuPTagu1VeclkrV3KfsinWBjn(s0Ve4I12WqzKlLHGKSV2s(nqqUG1y4Keu8wJVbcIJFjh5(w8IA)cJ4RbJ8FZRqjFB)oNkFcQH4k(sQ0fVO2VWi(AWi)38kuY32VZPYNGAiUIVKV4vK8xFxA5hQfPq7v2G0aVL04lr)sGlwBddLrUugcssBFH6f6gqs(0xh8qfUG1y4KK0xh8q50ANizAuW8OSVRCu8wJtRDIKPrbZJY(UCHAjiLGPuPPVo4HYXlgzcO0X3wQ6CxLJI3AC8IrMakD8TLQo3v(siSOeqazyPJBJjsd8wsJVe9lbUyTnmug5sziijhYuOc)bN8wsdSKlyngoj5qMc1B1XFOK5kxJeKrbtE6XsLvkVcyqvFZObE40aCRxxmxhaC8(cDaWXewADzaiSOulQbi7tUoGEm2xIby1zaqs01a6SeIFfeJeIbi7eLs7a2NXIc2aVL04lr)sG7si(vqmsi8DJsP1LOjj91bpuoHL22(cvUAmQuomtHsBuW8c9xeYrUp1yuP8hLfkTMgFjp9p78Dl(vWy26)MVTVq5lHWIsivQGup6x4cUg0IPSXJrxj5QXOs5pkluAnn(sEFO4Tg)kymB9FZ32xOC8lKg4TKgFj6xcCH(DzrbZJYmH6sY1eJ8QTWivi5MlrtsFNx5T9fQVryPLVeclkHCKvJrLYJeLSlPs7dfV14Olzku)38IOoRb7fgh)sUAmQuo6sMc1)nViQZAWEHjvQAmQu(JYcLwtJVKN(ND(Uf)kymB9FZ32xO8LqyrjK3hkERXHmySOG5ryjOrrC8lKg4TKgFj6xcCHXSuymVDWAvICjAsqXBnEKC1Rg7lbFjewuciibw642ykxngvkpsU6vJ9LqU4IymVAlmsfCymlfgZBhSwLOELGPCKvJrLYJeLSlPsvJrLYrxYuO(V5frDwd2lm5P)zNVBXrxYuO(V5frDwd2lm(siSOe9EtgsLQgJkL)OSqP104l59HI3A8RGXS1)nFBFHYXVqAG3sA8LOFjWTTVq9cDdijxIMeu8wJhjx9QX(sWxcHfLacsGLoUnMYvJrLYJKRE1yFjKJSAmQuEKOKDjvQAmQuo6sMc1)nViQZAWEHjVpu8wJJUKPq9FZlI6SgSxyC8l5P)zNVBXrxYuO(V5frDwd2lm(siSOe9EtwsLQgJkL)OSqP104l59HI3A8RGXS1)nFBFHYXVqAG3sA8LOFjW9rzHsRPKlrts6XsLvkVcyqvFZi5hYuOERo(dLmx5AKGmkyYpKPq9wD8hkzUYTKgyj)siSOeqazyPJBFJldKKJCFQXOs5pkluAnn(sQu1yuP8hLfkTMgFjVpu8wJFfmMT(V5B7luo(fsd8WPb4gO)lOb4wtA81ayHqhG(dyXRbElPXxI(La3KXyElPXxEwiuxkdbjj9yPYkvmWBjn(s0Ve4MmgZBjn(YZcH6sziijRLcJjg4TKgFj6xcCtgJ5TKgF5zHqDPmeKeDJcssfd8wsJVe9lbUjJX8wsJV8SqOUugcss6F257wIbElPXxI(La3KXyElPXxEwiuxkdbjj9SJhkzR6Iq3iPsU5s0KOgJkLNE2XdLSvLJCFO4TghYGXIcMhHLGgfXXVKkvngvkhDjtH6)Mxe1znyVWqsoYhcfV14R15)gjIlulbPezivAFhYuOEiRaguLV4f1(fgXxRZ)nsesd8wsJVe9lbUlE5TKgF5zHqDPmeKe0x41ibzuWCrOBKuj3CjAsqXBno6sMc1)nViQZAWEHXXVg4TKgFj6xcCx8YBjn(YZcH6sziijOVWF9plkyUenjQXOs5Olzku)38IOoRb7fMCKt)ZoF3IJUKPq9FZlI6SgSxy8LqyrjGWnzHKCKxloEclvk3ohbpQEXugsL23AXXtyPs525i4KmdHkKkn9p78Dl(vWy26)MVTVq5lHWIsaHBYs(AXXtyPs525i4KmdHkKVwC8ewQuUDocEuq4MSqAG3sA8LOFjWDXlVL04lpleQlLHGK8OSqP104lxe6gjvYnxIMeu8wJFfmMT(V5B7luo(LC1yuP8hLfkTMgFnWBjn(s0Ve4U4L3sA8LNfc1LYqqsEuwO0AA8L)6FwuWCjAs6tqQh9lCbxdAXu24XORKC1yuP8hLfkTMgFjp9p78Dl(vWy26)MVTVq5lHWIsaHBYsoYyTnmugXfQ)IzvffmPsxloEclvk3ohbNKziuH81IJNWsLYTZrWJcc3KLuP9TwC8ewQuUDocojZqOcKg4TKgFj6xcCx8YBjn(YZcH6sziij2tUi0nsQKBUenjwsdSKNkcrqIELG5aVL04lr)sGBYymVL04lpleQlLHGKiuRo2Eg4h4HtdWT(yCdOZ(QPXxd8wsJVeC7jjlH4xbXiHW3nkL2bElPXxcU9u)sGlmMLcJ5TdwRsKlrtIAmQuEBFHksUQqPbElPXxcU9u)sGBBFHksUQqjxIMeu8wJdzWyrbZJWsqJI4lzjvEFyTnmugXpKPqf(do5TKgyPbElPXxcU9u)sGl0VllkyEuMjuxIMeS2ggkJ47RTKFdeKC1yuPCdRXSkbLg4TKgFj42t9lbUWywkmM3oyTkrUenj9HI3A8nqqC8l5wsdSKNkcrqciiPJsLAjnWsEQiebj6TJd8WPbah)lcCMfPbyxx7BjOdq)bKwYuAa2aUee(5hW1g)gQRdqTfgPdGfcDaTFhGDDXCnkydyTo)3irdiQbypnWBjn(sWTN6xcCB7luVq3asYLKRjg5vBHrQqYnxIMK0)SZ3T4lH4xbXiHW3nkLw(siSOeqqcMUnS0rUAmQuomtHsBuW8c9xed8wsJVeC7P(LaxOFxwuW8OmtOUenjyTnmugX3xBj)giObElPXxcU9u)sGBBFHksUQqjxIMe1yuPCyMcL2OG5f6ViKJI3A8Lq8RGyKq47gLslh)sUL0al5PIqeKOxmL3hwBddLr8dzkuH)GtElPbwAG3sA8LGBp1Ve4(OSqP1uYLOjbRTHHYi(HmfQWFWjVL0aljhfV14hYuOc)bN4c1sqcbmsQu1yuPCyMcL2OG5f6ViKJI3A8Lq8RGyKq47gLslh)AG3sA8LGBp1Ve422xOEHUbKKljxtmYR2cJuHKBUenjlEfj)13Lw(HArkuiG8nz0VAmQu(IxrYBQsfUPXxUTmqAG3sA8LGBp1Ve422xOIKRkuYLOjPpS2ggkJ4hYuOc)bN8wsdS0aVL04lb3EQFjW9rzHsRPKljxtmYR2cJuHKBUenjlEfj)13Lw(HArk0Ergtz0VAmQu(IxrYBQsfUPXxUTmqAG3sA8LGBp1Ve4cJzPWyE7G1QenWBjn(sWTN6xcCB7lurYvfknWBjn(sWTN6xcCB7luVq3asYLKRjg5vBHrQqYTbElPXxcU9u)sGl0Fl)38DJsPDG3sA8LGBp1Ve4ABYkYR)UuPd8d8WPbaXLmf6a(2aCI6SgSxyd46FwuWgW(QPXxdOddqO2QIbCtwIbGsTFPbaX3zaHyagwlygkJg4TKgFj4OVWF9plkyswcXVcIrcHVBukTUenjwsdSKNkcrqIELGPuPyTnmugX3UEu8wtmWBjn(sWrFH)6FwuW6xcCFuwO0Ak5sY1eJ8QTWivi5MlrtckERXHmySOG5ryjOrr8LSKkp9p78Dl(vWy26)MVTVq5lHWIs0Bhh4TKgFj4OVWF9plky9lbUq)USOG5rzMqDjAsWAByOmIVV2s(nqqd8wsJVeC0x4V(NffS(La32(cvKCvHsUenjO4TghYGXIcMhHLGgfXxYsQ8fVIK)67sl)qTifAViFtg9RgJkLV4vK8MQuHBA8LBldKKlUigZR2cJubVTVqfjxvOuVykVpS2ggkJ4hYuOc)bN8wsdS0aVL04lbh9f(R)zrbRFjWTTVqfjxvOKlrtYIxrYF9DPLFOwKcTxji3rz0VAmQu(IxrYBQsfUPXxUTmqsU4IymVAlmsf82(cvKCvHs9IP8(WAByOmIFitHk8hCYBjnWsd8Wj40aUR2cJuF0KGWKzhq(qO4TgFTo)3irCHAji7)gsYwKpekERXxRZ)nseFjewuI(VHKBFitH6HScyqv(Ixu7xyeFTo)3ir3hqNLUitfdWga7vxgGcnediedikLQdDgG(dqTfgPdqHsdaAadkj0bCTXVH66aOIq46a6gk0by1am0GfQRdqHA6a6gm2aSRlMRdyTo)3irdiAdyXlQ9lm6WhqpqnDaOuuWgGvdGkcHRdOBOqhGSgGqTeKcxgWVdWQbqfHW1bOqnDakuAahcfV1gq3GXgG4)AaKmVILgWx8bElPXxco6l8x)ZIcw)sG7JYcLwtjxsUMyKxTfgPcj3CjAsw8ks(RVlT8d1IuO9kbtzmWBjn(sWrFH)6FwuW6xcCHXSuymVDWAvICjAsw8ks(RVlT8d1IuOqatzjxCrmMxTfgPcomMLcJ5TdwRsuVsWuE6F257w8RGXS1)nFBFHYxcHfLOxzmWBjn(sWrFH)6FwuW6xcCB7luVq3asYLKRjg5vBHrQqYnxIMKfVIK)67sl)qTifkeWuwYt)ZoF3IFfmMT(V5B7lu(siSOe9kJbElPXxco6l8x)ZIcw)sGlmMLcJ5TdwRsKlrts6F257w8RGXS1)nFBFHYxcHfLO3fViUgiiV(Ems(IxrYF9DPLFOwKcfcyKSKlUigZR2cJubhgZsHX82bRvjQxjyoWBjn(sWrFH)6FwuW6xcCB7luVq3asYLKRjg5vBHrQqYnxIMK0)SZ3T4xbJzR)B(2(cLVeclkrVlErCnqqE99yK8fVIK)67sl)qTifkeWiznWpWdNgaexYuOd4BdWjQZAWEHna3AsdS0a6SVAA81aVL04lbh9fEnsqgfmjpkluAnLCj5AIrE1wyKkKCZLOjzXRi5V(U0cbjiJrYOF1yuP8fVIK3uLkCtJVCBzG0aVL04lbh9fEnsqgfS(La3Lq8RGyKq47gLsRlrtcwBddLr8TRhfV1esLAjnWsEQiebj6vcMsLU4vK8xFxAHqhXu(IxexdeKxFpMqyXRi5V(U0kBVbhg4TKgFj4OVWRrcYOG1Ve4EitH6T64puYC1LOjzXRi5V(U0cHoIP8fViUgiiV(EmHWIxrYF9DPv2EdomWBjn(sWrFHxJeKrbRFjWf63LffmpkZeQlrtcwBddLr891wYVbcsoYlEfj)13L2ELGrYqQ0fViUgiiV((ocbjWshPsx8IA)cJ4RbJ8FZRqjFB)oNkFcQH4k(sQuXfXyE1wyKk4q)USOG5rzMq7vcMsLII3A8nqq8LqyrjGqhrsQ0fVIK)67sle6iMYx8I4AGG867XeclEfj)13Lwz7n4WaVL04lbh9fEnsqgfS(La32(cvKCvHsUenjO4TghYGXIcMhHLGgfXXVKlUigZR2cJubVTVqfjxvOuVykVpS2ggkJ4hYuOc)bN8wsdS0aVL04lbh9fEnsqgfS(La3hLfkTMsUKCnXiVAlmsfsU5s0KGI3ACidglkyEewcAueFjlPd8wsJVeC0x41ibzuW6xcCH(B5)MVBukTUenjlEfj)13Lwiiboil5lErCnqqE99DSxyPZaVL04lbh9fEnsqgfS(La32(cvKCvHsUenjIlIX8QTWivWB7lurYvfk1lMY7dRTHHYi(HmfQWFWjVL0alnWBjn(sWrFHxJeKrbRFjW9rzHsRPKljxtmYR2cJuHKBUenjlEfj)13Lw(HArk0EXugsLU4fX1ab5133rialDg4TKgFj4OVWRrcYOG1Ve4c97YIcMhLzc1LOjbRTHHYi((Al53abnWBjn(sWrFHxJeKrbRFjW12KvKx)DPsDjAsw8ks(RVlTqqgYAGFGFGhobNgGBE2zaWrr2QdWnFDcn(smWBjn(sWtp74Hs2QssqTOe(V5Je5s0KG(cH8wadQ6xcHfLacWsh5iV4fbbmLkTpu8wJdzWyrbZJWsqJI44xYrUpewuEOwD4ycvokERXtp74Hs2QCHAji7vcg1)Ixu7xyehYNPXAcFZW(RuPiSO8qT6WXeQCu8wJNE2XdLSv5c1sq2RSP)fVO2VWioKptJ1e(MH9xKKkffV14qgmwuW8iSe0Oio(LCK7dHfLhQvhoMqLJI3A80ZoEOKTkxOwcYELn9V4f1(fgXH8zASMW3mS)kvkclkpuRoCmHkhfV14PND8qjBvUqTeK9Etw9V4f1(fgXH8zASMW3mS)Iesd8WPbahnbnGd(gfSbaNhmMTdOBOqhGSprj7cUqCjtHoWBjn(sWtp74Hs2Q9lbUjOwuc)38rICjAs6tngvk)rzHsRPXxYrXBn(vWy26)MVTVq54xYrXBnE6zhpuYwLlulbzVsUjl5iJI3A8RGXS1)nFBFHYxcHfLacWsh3g5B9N(ND(UfVTVq766Iq4B4RR8LSJRijvkkERXXlOpZvVqxQGPq5lHWIsabyPJuPO4Tgpb1EHh1kIVeclkbeGLoinWdNgaCgUkIdnGVna48GXSDa4cYGrdOBOqhGSprj7cUqCjtHoWBjn(sWtp74Hs2Q9lbUjOwuc)38rICjAs6tngvk)rzHsRPXxYpKPq9qwbmOkFXlQ9lmI3mgJkFAXf2Hw59HI3A8RGXS1)nFBFHYXVKN(ND(Uf)kymB9FZ32xO8Lqyrj69MmKJmkERXtp74Hs2QCHAji7vYnzjhzu8wJJxqFMREHUubtHYXVKkffV14jO2l8OwrC8lKKkffV14PND8qjBvUqTeK9k5whrAG3sA8LGNE2XdLSv7xcCtqTOe(V5Je5s0K0NAmQu(JYcLwtJVK33HmfQhYkGbv5lErTFHr8MXyu5tlUWo0khfV14PND8qjBvUqTeK9k5MSK3hkERXVcgZw)38T9fkh)sE6F257w8RGXS1)nFBFHYxcHfLOxmL1apCAaW5lHLkDaU5zNbahfzRoGhlTj76kkyd4GVrbBaxbJz7aVL04lbp9SJhkzR2Ve4MGArj8FZhjYLOjrngvk)rzHsRPXxY7dfV14xbJzR)B(2(cLJFjhzu8wJNE2XdLSv5c1sq2RKByKCKrXBnoEb9zU6f6sfmfkh)sQuu8wJNGAVWJAfXXVqsQuu8wJNE2XdLSv5c1sq2RKBDgPst)ZoF3IFfmMT(V5B7lu(siSOeqOJYrXBnE6zhpuYwLlulbzVsUHrinWpWdNgaC(RXxd8wsJVe80)SZ3TesUEn(YLOjbfV14xbJzR)B(2(cLJFnWdNgGB(ND(ULyG3sA8LGN(ND(ULOFjWLqC9DP1V4f57s21xUenjQXOs5pkluAnn(s(IxeeGdYrgRTHHYiUq9xmRQOGjvkwBddLrC7Ce(LqyrHKCKt)ZoF3IFfmMT(V5B7lu(siSOeqqgYro9p78DlEJrcOP1AkFjewuIELHCXJZqJ6WVWfkoJ80IFPXxsL2N4XzOrD4x4cfNrEAXV04lKKkffV14xbJzR)B(2(cLJFHKuPOVqiVfWGQ(LqyrjGaMYAG3sA8LGN(ND(ULOFjWLqC9DP1V4f57s21xUenjQXOs5Olzku)38IOoRb7fM8fViiid5lEfj)13LwiGmCqwy8hYuOEiRaguLV4f1(fgXH6QqPnm3wgy8lErTFHr81qCzL611krJwQsKBldKKJmkERXrxYuO(V5frDwd2lmo(LuPTagu1VeclkbeWuwinWBjn(sWt)ZoF3s0Ve4siU(U06x8I8Dj76lxIMe1yuP8irj7AG3sA8LGN(ND(ULOFjW9kymB9FZ32xOUenjQXOs5Olzku)38IOoRb7fMCKXAByOmIlu)fZQkkysLI12Wqze3ohHFjewuijh50)SZ3T4Olzku)38IOoRb7fgFjewucPst)ZoF3IJUKPq9FZlI6SgSxy8LSJRYx8ks(RVlT9chKbsd8wsJVe80)SZ3Te9lbUxbJzR)B(2(c1LOjrngvkpsuYUK3hkERXVcgZw)38T9fkh)AG3sA8LGN(ND(ULOFjW9kymB9FZ32xOUenjQXOs5pkluAnn(soYlEfj)13L2EL0rziVpu8wJBOpIOmn(YZceOC8lPsrXBnUH(iIY04lplqGYXVqsoYyTnmugXfQ)IzvffmPsXAByOmIBNJWVeclkKKJSAmQuomtHsBuW8c9xeCQmugDKJI3A8Lq8RGyKq47gLslh)sQ0(uJrLYHzkuAJcMxO)IGtLHYOdsd8wsJVe80)SZ3Te9lbUOlzku)38IOoRb7fMlrtckERXVcgZw)38T9fkh)AG3sA8LGN(ND(ULOFjWTTVq766Iq4B4RRUenjwsdSKNkcrqcj3KJI3A8RGXS1)nFBFHYxcHfLacWsh5O4Tg)kymB9FZ32xOC8l59PgJkL)OSqP104l5i33AXXtyPs525i4KmdHkKkDT44jSuPC7Ce8O6TJYcjPsBbmOQFjewuci0XbElPXxcE6F257wI(La32(cTRRlcHVHVU6s0KyjnWsEQiebj6vcMYrgfV14xbJzR)B(2(cLJFjv6AXXtyPs525i4KmdHkKVwC8ewQuUDocEu9M(ND(Uf)kymB9FZ32xO8Lqyrj63TGKCKrXBn(vWy26)MVTVq5lHWIsabyPJuPRfhpHLkLBNJGtYmeQq(AXXtyPs525i4lHWIsabyPdsd8wsJVe80)SZ3Te9lbUT9fAxxxecFdFD1LOjrngvk)rzHsRPXxYrgfV14xbJzR)B(2(cLJFjVpewuEOwD4ycvQ0(qXBn(vWy26)MVTVq54xYryr5HA1HJju5P)zNVBXVcgZw)38T9fkFjewucKKJmYO4Tg)kymB9FZ32xO8LqyrjGaS0rQuu8wJJxqFMREHUubtHYXVKJI3AC8c6ZC1l0Lkyku(siSOeqaw6GKCKpekERXxRZ)nsexOwcsjYqQ0(oKPq9qwbmOkFXlQ9lmIVwN)BKiKqAG3sA8LGN(ND(ULOFjWfQRxVcLwerYFTKGQe5s0KOgJkLJUKPq9FZlI6SgSxyYx8ks(RVlTqaoil5lErqqshLJmkERXrxYuO(V5frDwd2lmo(LuPP)zNVBXrxYuO(V5frDwd2lm(siSOe9IrYcjPs7tngvkhDjtH6)Mxe1znyVWKV4vK8xFxAHGe3Img4TKgFj4P)zNVBj6xcCxleK)q2XLOjj9p78Dl(vWy26)MVTVq5lHWIsabjYyG3sA8LGN(ND(ULOFjWvyPnArkmM)YsQlrtIL0al5PIqeKOxjykh5wadQ6xcHfLacDuQ0(qXBno6sMc1)nViQZAWEHXXVKJ8fPCyqFCgFjewucialDKkDT44jSuPC7CeCsMHqfYxloEclvk3ohbFjewuci0r5RfhpHLkLBNJGhvVxKYHb9Xz8LqyrjqcPbElPXxcE6F257wI(La3dzkuVvh)HsMRUenjwsdSKNkcrqIELHuPlErTFHr8lOKTpIViXa)apCAaU5XsLv6aCRObl0Ged8wsJVe80JLkRuHKdzkuH)GtUenji3NAmQu(JYcLwtJVKkvngvk)rzHsRPXxYTKgyjpveIGe9kbt5P)zNVBXVcgZw)38T9fkFjewucPsTKgyjpveIGesUHKCKXAByOmIlu)fZQkkysLI12Wqze3ohHFjewuinWBjn(sWtpwQSsf9lbUIU2IikyEeHqDjAsw8ks(RVlT8d1IuO9ERJYt)ZoF3IFfmMT(V5B7lu(siSOeqOJY7tngvkhDjtH6)Mxe1znyVWKJ12WqzexO(lMvvuWg4TKgFj4PhlvwPI(LaxrxBrefmpIqOUenj9PgJkLJUKPq9FZlI6SgSxyYXAByOmIBNJWVeclQbElPXxcE6XsLvQOFjWv01werbZJieQlrtIAmQuo6sMc1)nViQZAWEHjhzu8wJJUKPq9FZlI6SgSxyC8l5iJ12WqzexO(lMvvuWKV4vK8xFxA5hQfPq7fJKLuPyTnmugXTZr4xcHfL8fVIK)67sl)qTifAVWbzjvkwBddLrC7Ce(LqyrjFT44jSuPC7Ce8LqyrjGqNr(AXXtyPs525i4KmdHkqsQ0(qXBno6sMc1)nViQZAWEHXXVKN(ND(UfhDjtH6)Mxe1znyVW4lHWIsG0aVL04lbp9yPYkv0Ve4AOpIOmn(YZceOUenjP)zNVBXVcgZw)38T9fkFjewuci0r5yTnmugXfQ)Izvffm5iRgJkLJUKPq9FZlI6SgSxyYx8ks(RVlT9chKH80)SZ3T4Olzku)38IOoRb7fgFjewuciGPuP9PgJkLJUKPq9FZlI6SgSxyinWBjn(sWtpwQSsf9lbUg6JiktJV8SabQlrtcwBddLrC7Ce(LqyrnWBjn(sWtpwQSsf9lbUcOwcsg5vOKhV6(Rc1vxIMeS2ggkJ4c1FXSQIcMCKt)ZoF3IFfmMT(V5B7lu(siSOeqOJsLQgJkLhjkzxinWBjn(sWtpwQSsf9lbUcOwcsg5vOKhV6(Rc1vxIMeS2ggkJ425i8lHWIAG3sA8LGNESuzLk6xcCBmsanTwtDjAs6dfV14xbJzR)B(2(cLJFjhzXJZqJ6WVWfkoJ80IFPXxsLkECgAuho2NzAWiV4zyPsL3hkERXX(mtdg5fpdlvkh)cjxIsPDXVuFGabDctjj3CjkL2f)s9WypQXKCZLOuAx8l1hnjIhNHg1HJ9zMgmYlEgwQ0b(bE40aGZqzHsRPXxdyF104RbElPXxc(JYcLwtJVKSeIFfeJecF3OuADjAsSKgyjpveIGe9kPJYXAByOmIVD9O4TMyG3sA8LG)OSqP104R(La32(c1l0nGKCjAs6dfV14qgmwuW8iSe0Oio(LCKx8IGaMsLQgJkLhjx9QX(sihfV14rYvVASVe8LqyrjGaS0XTXuQ00xh8q54fJmbu64BlvDURYrgfV144fJmbu64BlvDUR8LqyrjGaS0XTXuQuu8wJJxmYeqPJVTu15UYfQLGecDejKg4TKgFj4pkluAnn(QFjWf63LffmpkZeQlrtsFO4TghYGXIcMhHLGgfXXVKV4f1RKokhzu8wJVbcIVeclkbe6OCu8wJVbcIJFjvQL0al5pVYB7luFJWsleSKgyjpveIGeinWBjn(sWFuwO0AA8v)sGlmMLcJ5TdwRsKlrtsFO4TghYGXIcMhHLGgfXXVKlUigZR2cJubhgZsHX82bRvjQxjykvAFO4TghYGXIcMhHLGgfXXVKJ8HqXBn(AD(VrI4c1sqcbziv6HqXBn(AD(VrI4lHWIsabyPJBJrinWBjn(sWFuwO0AA8v)sGBBFHksUQqjxIMeu8wJdzWyrbZJWsqJI4lzjvU4IymVAlmsf82(cvKCvHs9IP8(WAByOmIFitHk8hCYBjnWsd8wsJVe8hLfkTMgF1Ve4(OSqP1uYLKRjg5vBHrQqYnxIMeu8wJdzWyrbZJWsqJI4lzjDG3sA8LG)OSqP104R(La32(c1l0nGKCjAsSKgyjpveIGesUjhRTHHYiEBFH6f6gqs(0xh8qfd8wsJVe8hLfkTMgF1Ve4c97YIcMhLzc1LOjbRTHHYi((Al53abjxCrmMxTfgPco0VllkyEuMj0ELG5aVL04lb)rzHsRPXx9lbUWywkmM3oyTkrUenjIlIX8QTWivWHXSuymVDWAvI6vcMd8wsJVe8hLfkTMgF1Ve422xOEHUbKKljxtmYR2cJuHKBUenj9PgJkLBynMvjOK8(qXBnoKbJffmpclbnkIJFjvQAmQuUH1ywLGsY7dRTHHYi((Al53abjvkwBddLr891wYVbcs(IxexdeKxFpM9kbw6mWBjn(sWFuwO0AA8v)sGl0VllkyEuMjuxIMeS2ggkJ47RTKFde0aVL04lb)rzHsRPXx9lbUpkluAnLCj5AIrE1wyKkKCBGFGhona48)zrbBaWX)oa4muwO0AA8vhgGJARkgWnznabL(6igak1(LgaCEWy2oGVna449f6aspcsmGV1gGBKDnWBjn(sWFuwO0AA8L)6FwuWKSeIFfeJecF3OuADjAsWAByOmIVD9O4TMqQulPbwYtfHiirVsWCG3sA8LG)OSqP104l)1)SOG1Ve4cJzPWyE7G1Qe5s0KiUigZR2cJubhgZsHX82bRvjQxjykxngvkVTVqfjxvO0aVL04lb)rzHsRPXx(R)zrbRFjWTTVqfjxvOKlrtckERXHmySOG5ryjOrr8LSKk3sAGL8urics0lMY7dRTHHYi(HmfQWFWjVL0alnWBjn(sWFuwO0AA8L)6FwuW6xcCFuwO0Ak5sY1eJ8QTWivi5MlrtckERXHmySOG5ryjOrr8LSKoWBjn(sWFuwO0AA8L)6FwuW6xcCB7luVq3asYLOjXsAGL8uricsi5MCS2ggkJ4T9fQxOBaj5tFDWdvmWBjn(sWFuwO0AA8L)6FwuW6xcCFuwO0Ak5sY1eJ8QTWivi5MlrtckERXHmySOG5ryjOrr8LSKoWBjn(sWFuwO0AA8L)6FwuW6xcCH(DzrbZJYmH6s0KG12WqzeFFTL8BGGg4TKgFj4pkluAnn(YF9plky9lbUWywkmM3oyTkrUenjIlIX8QTWivWHXSuymVDWAvI6vcMYx8ks(RVlT8d1IuOqaoiRbElPXxc(JYcLwtJV8x)ZIcw)sGBBFH6f6gqsUKCnXiVAlmsfsU5s0KS4vK8xFxA5hQfPqHGBrwd8wsJVe8hLfkTMgF5V(NffS(La3hLfkTMsUKCnXiVAlmsfsU5s0KS4f1RKokh5(qyr5HA1HJjuPstpwQSs5fL2N97rQ00JLkRuoKUUHvijv6IxuVsWi5iSO8qT6WXe6aVL04lb)rzHsRPXx(R)zrbRFjWTTVqfjxvOKlrtIL0al5PIqeKOxjyK8(WAByOmIFitHk8hCYBjnWsd8d8WPb0zTuySb4wrdwObjg4TKgFj4RLcJjKGY()4B4RRUenjO4Tg)kymB9FZ32xOC8RbElPXxc(APWyI(LaxuAf0czuWCjAsqXBn(vWy26)MVTVq54xd8wsJVe81sHXe9lbU2MSI8x4mb5s0KGCFO4Tg)kymB9FZ32xOC8l5wsdSKNkcrqIELGjssL2hkERXVcgZw)38T9fkh)soYlEr8d1IuO9krgYx8ks(RVlT8d1IuO9kboilKg4TKgFj4RLcJj6xcCzbmOQWl7o(bgcQuxIMeu8wJFfmMT(V5B7luo(1aVL04lbFTuymr)sGRvjsORX8jJXCjAsqXBn(vWy26)MVTVq54xYrXBnoH467sRFXlY3LSRV44xd8wsJVe81sHXe9lbUTyju2)hxIMeu8wJFfmMT(V5B7lu(siSOeqqISrokERXVcgZw)38T9fkh)sokERXjexFxA9lEr(UKD9fh)AG3sA8LGVwkmMOFjWf1G5)Mx3ibPWLOjbfV14xbJzR)B(2(cLJFj3sAGL8uricsi5MCKrXBn(vWy26)MVTVq5lHWIsabzixngvkp9SJhkzRYPYqz0rQ0(uJrLYtp74Hs2QCQmugDKJI3A8RGXS1)nFBFHYxcHfLacDePb(bE40aCuRo2EgGikymcJxTfgPdyF104RbElPXxcUqT6y7rYsi(vqmsi8DJsP1LOjbRTHHYi(21JI3AIbElPXxcUqT6y7PFjW9rzHsRPKlrtckERXHmySOG5ryjOrr8LSKoWBjn(sWfQvhBp9lbUq)USOG5rzMqDjAsWAByOmIVV2s(nqqYrXBn(gii(siSOeqOJd8wsJVeCHA1X2t)sGBBFH6f6gqsUenjyTnmugXB7luVq3asYN(6GhQyG3sA8LGluRo2E6xcCHXSuymVDWAvICjAs67qMc1dzfWGQ8fVO2VWi(AD(VrIKJ8HqXBn(AD(VrI4c1sqcbziv6HqXBn(AD(VrI4lHWIsabyPJBJrinWBjn(sWfQvhBp9lbUT9fQxOBaj5s0KK(ND(UfFje)kigje(UrP0YxcHfLacsW0THLoYvJrLYHzkuAJcMxO)IyG3sA8LGluRo2E6xcCH(DzrbZJYmH6s0KG12WqzeFFTL8BGGg4TKgFj4c1QJTN(La32(c1l0nGKCjAsw8ks(RVlT8d1IuOqa5BYOF1yuP8fVIK3uLkCtJVCBzG0aVL04lbxOwDS90Ve4(OSqP1uYLOjPpu8wJ32VZPYFHZeeh)sUAmQuEB)oNk)fotqsLI12Wqze)qMcv4p4K3sAGLKJI3A8dzkuH)GtCHAjiHagjvQAmQuomtHsBuW8c9xeYrXBn(si(vqmsi8DJsPLJFjv6IxrYF9DPLFOwKcTxKXug9RgJkLV4vK8MQuHBA8LBldKg4TKgFj4c1QJTN(La32(c1l0nGKg4TKgFj4c1QJTN(LaxO)w(V57gLs7aVL04lbxOwDS90Ve4ABYkYR)UuPd8d8WPb0ZgfKKkg4TKgFj46gfKKkKGliFOecxkdbjjkrAXvdLrEmgUvkoc)HWgjYLOjPp1yuPC0LmfQ)BEruN1G9ctokERXVcgZw)38T9fkh)sokERXjexFxA9lEr(UKD9fh)sQu1yuPC0LmfQ)BEruN1G9ctoYiJI3A8RGXS1)nFBFHYXVKN(ND(UfhDjtH6)Mxe1znyVW4lzhxrsQuKrXBn(vWy26)MVTVq54xYrg5wadQ6xcHfLaJp9p78Dlo6sMc1)nViQZAWEHXxcHfLajiG5nKqcjPsrFHqElGbv9lHWIsabmVjv6HmfQhYkGbv5NqyOmYhySJNKjLWvsISKR2cJuUgiiV((RK6Xuwqqgd8wsJVeCDJcssf9lbU4cYhkHWLYqqsGzyjM)BEfk5BXkuVTOHs7aVL04lbx3OGKur)sGlUG8HsiCPmeKerYwH)B(2AkTLX8cDJgnWBjn(sW1nkijv0Ve4IliFOecxkdbjrHs(wSc1lcybZLOjbfV14xbJzR)B(2(cLJFjhfV14eIRVlT(fViFxYU(IJFnWdNgqpqPbOBuqs6a6gk0bOqPbanGbLe6aiHgimLodaRXWjxgq3GXgaknaCbDgqlwHoaRod4YILodOBOqhaCEWy2oGVna449fkFG3sA8LGRBuqsQOFjWv3OGK0BUenj9H12WqzexCrPOf0XRBuqsQCu8wJFfmMT(V5B7luo(LCK7tngvkpsuYUKkvngvkpsuYUKJI3A8RGXS1)nFBFHYxcHfLOxj3KfsYrUpDJcss5yYHAcF6F257wsLQBuqskhtE6F257w8LqyrjKkfRTHHYiUUrbjP(Rn(nuxLCdjPs1nkijLFJJI3A(d(AA8vVsAbmOQFjewuIbElPXxcUUrbjPI(LaxDJcssX0LOjPpS2ggkJ4IlkfTGoEDJcssLJI3A8RGXS1)nFBFHYXVKJCFQXOs5rIs2LuPQXOs5rIs2LCu8wJFfmMT(V5B7lu(siSOe9k5MSqsoY9PBuqsk)ghQj8P)zNVBjvQUrbjP8B80)SZ3T4lHWIsivkwBddLrCDJcss9xB8BOUkbtKKkv3OGKuoMCu8wZFWxtJV6vslGbv9lHWIsmWdNgGSVnGVyUoGVOb81aWf0a0nkijDax7JnoKya2aqXBnxgaUGgGcLgWRqPDaFnG0)SZ3T4daoBhq0gqrHcL2bOBuqs6aU2hBCiXaSbGI3AUmaCbna0xHoGVgq6F257w8bElPXxcUUrbjPI(LaxCb5dLq4IG9QeDJcssV5s0K0hwBddLrCXfLIwqhVUrbjPYrUpDJcss534qnHhxqEu8wtoY6gfKKYXKN(ND(UfFjewucPs7t3OGKuoMCOMWJlipkERHKuPP)zNVBXVcgZw)38T9fkFjewuIEXuwinWBjn(sW1nkijv0Ve4IliFOecxeSxLOBuqskMUenj9H12WqzexCrPOf0XRBuqsQCK7t3OGKuoMCOMWJlipkERjhzDJcss534P)zNVBXxcHfLqQ0(0nkijLFJd1eECb5rXBnKKkn9p78Dl(vWy26)MVTVq5lHWIs0lMYcPSJ4Isz3Xug3YAwZz]] )


end
