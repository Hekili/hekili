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


    spec:RegisterPack( "Frost DK", 20220821, [[Hekili:T3tAZTTrY(Br1wMM0h08qu(Oe1woxV1z3kjvu2AFFsKqKGs4zscUaG2rPuXF7VUN7zWCbq6KS179HetbmhD3tFp9m4MH38l3C9YKQ0B(HrdgnAWBgnS)W3oC8Oj3CD1d7sV56Djl(yYDWp2MSb()FxrEz1H5FZFhFZdRZtwIJqz((IfWBVVQAx57E1RUlR6(932Fr(MxvMTz)6KQS8TlkswvH)9IxDZ13UpBD1h2EZTwN(H3CDY(Q7ZlU56RZ281WaNTCzkT1PLlU56VjnP6(dZ)7BZU7EaCOq13)(93ThHUrdEb()gn6W3F47)67t2ExA5HV)LhM)ZPBY)u6YdZxNuw9YY0f5BH)yFjGGhMNV6WCOXzBlP)(dlGhMa)rgmKlZtl3(u4h7wN8WH5FoD9A4fBH)Uizrv2I0(Kj4BYjnAbmNBtHw8DRtlVNG4WqSViB7DhM)vfuGhNJRZ2USi5U8YK(3C96SYQsKCMF76SQ0ccvB2U881q)GN)dKvR0Tj3UoD5nFfqJwGT4MRla0QOmfMRYzFoBl0vkDQiBhTb)eDma4jV4W8Fuz4FhadvjfvaAoCWH5usc8h3MUkVaW)FkB96KckWYw7Hv1ucjcPxFZnxdtdmAzj3C9NsG)baU(fFE2T7xTcA1Jpc0qam)u6S0TPBYWEE1uy15Mkyn3aFKJu5oGapdaS7sRk7F36KfzjRNLS8tjBXvfYiCyENdZRswNUTQ)ke0kx8q19P95dOG8y0DCMh7CMr4U)hbSgOxZ2KS4(STa(KcJfz(QHlCa5SdZfO)sCbUC2Y9PZOTxclkakchN7yfvWbKghSbT6HfRt5umKvbg9joXst0aONdjOHahia6SYQISpModzk2NbJRoEWEnovx8ffrETterYYLxTAXSISnke77Z)mzgUff3XX5nhpdxX(TzlaHYpNwaRZRYwGAhU8W8lg4LH7ToOpA0rf4X1086b2Pqdh0Ofay4zy1ycw1LWaVbu(nduDTS)O7PIUla1LBtabSTPlkYxNxS045F8by8a1G9OpxoUNtgx1r0bGBQuZntQCyBLWgYBLVE5S7tb9D2uNQWFMxwsMOvO9LzG(vQzbyb4Ufl5umkYEjHZarEaQSYyVFNtAChwxKaw)YkWIRazFoDAaLX3L2)J5RRYkskNTk5t5fCfD0jp6X9W83e5WYwtpH4u8ZDdrj02vuJlGt9KmiliM7NLVAwgvm10IK9gQBC9FwMknUZTx(5m0ep4cXIKDVIAXxLb7mHLlvB9sWKJS7idhoVeEzoz3dpdsjOlmwhGASYpJ02HeY3cWnHL5FElv5)NFOydq)2x8aQAE5d6me73EF(6hqnxPBVR6(6dSOLaTlVC2Tjev8gnQNnJXXq0)X9vLzlzETXj67ltjEYD8eFIsLzFK4EzFjx1QK1q)MTOaCzCzAbxxKVLkbn15kbY(orBrlQvwZfaC(SrZXNRUW5yWhZwmm9iPrKTZAeLlmUEkOTJg4rE30dPyy9(PIuW4hyo(RHz)W8)gc7aF4Nsla2TDeTaCTbu4sLigbf0hghGd58VKCiVLB6per)sUxfba1EuJYQ0IJkkh14AaBb5vjSftVEumw3VxEOl(JpjSPEtNdyl8zlEaCaAD(2Y6k7vENn10J40FIV4WQ760KY7txcK)0T)2dAJNKfWOrEgy7DGTMrxt1TEAgdG7GQcqUS4nkP5O38UyRiVJZrZwxxMZIeC2kqeTG0fZL8EEcpWRUpFiqCrpeNpIltP4xYVLxG5vqUamHoeMnW2s65AiQL4rChAOvWtgaSoQQ4H9rhl8FuHqEYJf2DuMwIw1crvJVKNUe3CTMHw2SGA9YL4mQsxHTk9ri5tjRHHrMpgnZB2y)v0s6SZwjGyhDrzrvl9RG)Awv(SruCgesACSOnlpddDfhHgVCDiOIe65SQSfFmqk)8oq2ZJaOGykrdZ5tiE7ZO10wKuvLUDVH)ipJOZPNHzw75V8W83tKJom)N5gE9AbTj5kuKBbfubmgmY(kSrlFfioFHxVi8ecYPr3JB7kNgCI6ZneO8SLqipp4x)UljLUgZbjbetKP1rapJPmsIG8cR8sX)cBM07DkxFRjlAAwjWYOvl6NsZCUnevtw9Ib1PaJjaarfMeLl2IUHlzNJnpNNs8YvgoDMaY653eHaBCCNZ9TXHABtRuTwTTB9)MmNtuIQmbc8BlcOfGlZvu14GxBBxMuS8OcO5A2GaSJaCUo9Lu82ESnnmcgF6WSS0519ExQuCiX3kpWBRZyUve6ozfCxR)91LC3kQeHCxNJrzQOAAFMmf1md83b4ykMpcGQKxSP((JzsY(YVBlU2DJU0uH1mNtCHgU9lM7fk0JFlD7SD7xxku8l3qr5ReZPMNM1unk55LVsHx5C7BrszA1SBZ3UVeu3Lwm6nZoF3cAl7ABhzotDtzi7oXQKuXRSpy9IGDqrGTotg39CNZqhhBm2veSyuRxt11arv0Bpge5cTqrUd7JgnDKAtnuLR1uMZ5NI9J3Ll0747tpxb)H5Vdi5InOxzJ5)Q8RpmpdEaeRu2Aee8ftRIByrzNOT()s4ecNHWRiwbSzl)pkhXBMMTwN9epcjnvX3xy3uDBnYooqdTC8FUqctlzTXNuuYzID2PMBGB0GgKVqvrPBjAmqrPszjdPkpPfrWxWcqGHbneWAOB7Xp6MXj4sgdT)gpT3lLSwucHiLFHWgRu1k50vAZeLHMQ6BZKHLQVwmyc0Cxo5F9gDrOT5QGV7ixW9XwiDdKWDRt2ULyhuZGvYYLLSAXGR6OBmwBO(PB06vIkZtBfG2WY89RVfwI6VBFz1EGgNwSFNosWDhkClv3AnBBRh)9UR5e1TWmDdHxygsbN950KD0Lc3bNXwkSY7zDjzIjFh31CmDeVKfqK14MU)HsYKQOE)LIndJhA1MDGRRZQks2wUkf8YArQfRcIvxcvZkSl2ntF0nnNjDq6C7uGyp7WcjOECtogp3ohe7sXjrCWVYgbhPtARjpWvY0bgAoiflIL(FHUZ9gcd(96W6Ab31aN6Y8mvUJYnKYlBzkD8enyj528nzBPfW76Sn3QV37oFRQCYDPi4coYmJfl6I7bzhtnlhj3YPjMWqJI)1C3ErDwl4rVWF9pXH6WwnyLLJcSBdm8NObZWWeBTOvyRwwJC1qgQhrb5qRpVIKSLZifTcHnOF6VIvAoJLZ4Di7bgE2aHHP66vhB4ZJSsXc4xNJWsJy9Yfk0XjgeEfgcu51MMAcUM0qGPw)ntyLbTZT)ArSuhGzXAYK81h9o0jgAQGA2ickPL2kxPooExDYkFEDKR2PIC1gtAFTuNlgRtbD9nOrEthSu2ShAYChhVpqHmilvPDUuUwQ(OHWkaBVEIs2rEaIiau8VbBsrAzkpoPXQzwdemktNbu(LMjGZT)xEvxyrTKotTpRgq)3LcwSUhCF)KkJp2NkjltPoNwzcG8ymEqeN7WSyH0N4pfhxjyYLm17WsVlFt(20Y6EWwFJJRWhUkz)AzfYZBm4YcPQWs)nZ0TAkmKdEEvMQSrsCVqWFTEp8pa9p9FVpB3U0LaXbI3CFf((z)79qWb73aGZNicIiUiAiXxOScmg7S7YwBZPx3Jf3TunXfJruBzX)u3jkeWvLJwUlDbSoJsxvGdtFmf5SUnL412(s8X0syozFv(gqv)IdZxNbRGek5m6jXtmgZydHTWadVs40fLUozJhk1K6skPNgKkDk1w8wnhg10d0q)BuKJTGHgPcWI7pSdBqpdCuX9ABXagghL7vQuf1znoIGweerhh5y6kQ3rQiPsUXTeRwyCKx6QG7llZwa81KCQN)zPDEZ3Oy(UjL)kZNbp1(AxTYFvdlvtJNCdMTeXyye2q)AFwHDX8LYCx8ubI6542sKscBRH2VP3VB36hehGZVdlo2xqDVRIep4hwaV9xiLEmO0bptSFmnDh98YYg4dZ)xKrg4wYj7UHEgozlSWaVIojDchwOGjpKRTHD7e5mCUZKHgEFEb3ZxUZ13xiJslqVwKLGAh1aVntNrS(VeLJB4Gfc3dtA74VQn714K7tgkR16(unHYoHkA(yYKFe07OOLDAIt2CdKHi((z8A0Eq8fG8EAOAXWnhpL9ItkHvvtFGO6SvZfD4rsAxbV57yEX4Wk0W(tuCOnKsXtirWOelm9GuF3GUpphpTJVN0x0PuuvFvoXfc5qUibKlP)XmSj0R2aMLnoLS0AWFrnefe5HsRrhf1aWD6MmcUo3bbWc((IHdrWCjRCiOQB(ZPU1OLZoXz)aDzh(jIzrtoehSASxUtPRpDbwNwaaDoRQ1kp2l3jInkQ4PvB1LQNythrsnkCKuXLSA5K1G8wGabRJ9INGZR)jmU)ag5DKwrpkUAmlG2Hhebj3gg9v8AnpsRi8RSjlBE3eN2TMgoe9MsG1w7DBR0A46nELnjNEI8DE6W9Ppsu(1KmATRiDr(MBtSERpWIIlBLM(cQbI(vd7FFs5S9LPKALRU55GAu6ksXdoycwIL75Nt1N4Hrr2kGekZCBdMB)kR0GIiG1R(RKSd1Zo8y6MO5bh6BXOIb)mWymvt8fFIGqsxM9PSLyFV9b(PNMwLKSOkXRVikMqFSexEQYa1hIODfEVnHpKek(H53J3KtBrpvicFKZGErA1(caTgcZC6A0Xg(tg0FsF1WXza7SHZkFy7cNr8pdhLBUg6Tifad9KGuKNZ2izoRJyZQf(ZrNs(Zr)he)PvyTX8NEx1CKmvDnfNPjZuBXW5cfbU8VkgeDFLzBWEptNCmO)akfPN4U(OpRin1NDIfB(gSP0CHzjDUr(yEvnq1QMJxz2M2bQdBgOoubunvgvwLTXIYiM6cu)dyZyxc9ICGumQC0IQ6H8iw)m1CrENe5enNU6IzxDxro2(sqv1FlHcdseAt(smZ(f0qRUJC0cGgCp4Xo(WDfzGN6vpqFTSBCK4f0RTo6DuhBWLd5kuhA2kv0g3UbST5f8FTnh3LccTJUteI4DSQwKdrHumouiGnQD7eqOukQMHyrYiDLE8BZi5zgJDr6)Ps2UvQp(jQBeMS0b13hSkQtlw8XqpzS5FRYHK1xsCTy5Owinem83JB(UZAvfy3OkUx1R6AhbCxPD1YUTuVcIu3yft3tz71oYBuZZvTADjIZSLgvqwkWEoG2cDL1x)1tDxZoBxACCFh8Q9RtWTrmzhO5bwBP6owGgDPkx2vMUFzUMYf2HnKMKhIAJeCFeOhqfr2cWioy(Q)L)GJfs(VJ)6vZYQ)rEcdCNYb3dMem9DoXoku1z69A6f6GRYpVBZpWkwKd8Nj72TIe3DVGFeSThBnRiOwzWyQdrZaclDO2qmJ25kRNb07is3Pu0Z3rJ71QnnWrJJ78rqZF)cVHSBuyFvpHUB2rgvHVuprENL62UzPBv4EUVPkuAcvVr9cmu0jZOqeEz4PqwmlyXWl8TMnP(kC(H0MOLQ4LzLKfPS)9YzP)A6I9OLdACwD4wlehELDlGafgqppbsEipR1w81HYFCxYNsxlshhPgCskUnJWUkKQC3glU8Wsr0IKIskPgujuSfekr5MvkAwC3elE2W7KrPcfBsrBwu7Nm(y)z7UhNyzIuwC6sG)u57HMI9kHlXdQGetejQg0dJuwezlzbH9cEWi3MYRkkciWQqHDjzf4ZOdvT7P6(USKuRUPcQ0qBPXZEHA5SjyDyLBO5urXejNg9OYLXCAKWav)gL1arTiGLUZnLNAeTbQEG4tnuiyZn3)ZMYo0hLDyROSJQtzRNnMAuwtzMr2CIoGCfMOZ8Ty19KJfomor7lvf14zAG4LpcsVG3cu6Ju5U0UPK90FKLIGTPz03hE0UnNKtw1XPz8jwxKmtjwqbG6sqYHOxS7M2v8JoM3yrAmkzplFb588rvAokzLNZmkgdn341mqjw3Ylzl2jBFqW6qldwSRyUOOCeGzKfcEcbfPCDoMHTe86liznZdOKflY3VLO1hcXSVe(qKei1BkVHDQw5LnGNlEbzuc1ogR0EFy(7VndcdidRLw5sz3ttfxul2Y6NJBVvWMz)fQS7ONEZypLx(tGKRiFgoosqwuU7nWXfB4GIdxFoPydj9tzLwRN5wfqGnQJN5m45bn4e2nKFv(wp74UECpFGVLBpD8IGD0ZrA4TwBHyBKfkPcIYXgUIN1g3z6lk2v9YFZj9VB88w2oIRXJQxEq5EHnQPuH4yEks97OMFHaBJvezZZcHlQ1HXH2xobdW9jl(iMddi(J9B)CEr19p43QCaHDhJx47kk3EWgXvaaISIM9PC87He0UY81e5jv(j(0vRrSWXi5Pbh)z42q6Cm1A4MnPlZiP9sP0lu3edzBVBD(TjRP7)zLSq78yY92155lPNloDtU)mRVHJ)1VzkxDscbPfLPf8IaZTfJU(ljs32VnuX5Mtadex)MJP2DPG(RVq3Lmwk2ix6y(TefKOSgd0OC2)Z(L3TjDBmxArUrRqU9emzeH8TsLeaoowwvKSEgwFp(vP5peqCptEJ7qf)Jb9wLvKsKy8RGTjmPQhyRaueo)idATvuQ64JJYwn40mwdPVn5oSzqCal(i1BEq1YNaPw8TSp8BdE7nxdg7rljGkJ)17)5F4d)W)17WI(GK4OmG8xW3fQNARM0Ekw8oqOiKCcvMJBMi70ZHpyb9Jax)dF))iddtE07WpFdBbGG86NYW3)ByuW9ft83C0gEEcm9F7p(pa68WFTxF8llxaOus8AgSn0a2KByTa8uEKce29CcG1AmKHy0(p(i7)5hz)N06(hCHrL9Pzlnhlr1S)8svqmaIh4AegoOfGWO4OlkLtDZilMCSXatEil4N8rs1NuL8RKk)chK)X(eAr2GAnompFhUaIGD3x1ZpR3XoCtovdxWfaroo(Yt(h9)XvvOI)VUf9xD(FRr)fELlgb5tAHyjVwMBgtXfnhPmTWrhO308bYl1jM(pookdl8KMryowULwqyJDLw54v8LhNgEK4uK60e1EFZWOHEv6QQ1Dt(Y9R3xQP09j9mw0AJkYX(6plH8dvgczo6)Vn7UFdCngBAJcBpGJa0hzbBgvhBgF8geh5Z8ryA75r0DpiZKtOXhZ(hT36212AoCnXdXGYIII4TzYITHDZNxVnZ(4PXhdZ(h9Y0X6PI9L5)4uyFAC5XS)TJC2gxd0cgQnQ11gG2WARzxXCHmAcrJtNatjwdLDBdfA0XXXR1)2WO7T)Hno4volSXHtJVEo6FyOpMU7b69kKhE2JP7rs7Qf3q4zpMUhe3dkiXUFZAMCuRLZ9UG2eR7oilrWro(iv5Q5iCBY)05hRo7ZpP6SBJXpTbOnernhIAbr0UFeJAd107aepJDKIBj5PntuRfRVX5lDRhOwyg4pp5sz4Xk9E0omXzu(aHVa7gwIr0DhIE8IWfF6nA4n)WOjdXtSF(Qm8C)9x(lhM)n0Z79FNug68BXSVhFZ73F3ESGGhn4f4)B0iCAWx81uEk6F8s6fz2NWzgpIrVSmf1ZI1Yg5ZfpwZWF990nVc)9hWAxdp3K420UmpTC7tHFSBDYd8dvjw1m7kqmyrAFXK8n5KgI8ZBtHw9DITyx(fb3(x(hc5bgK)d7eYF47PlIL9fz555tFfVcmEbw64tzib7O4(I8DtjhH6xqM0PdFH84HofgYxGlmz4yov6VGAjp2P7zmwmB1jtNUYEv7qi)KNe8CSpDqVhF074h35v)jpXhGC1FDyp1zIw)l9Ac1CuBPMJAf10YPp)pgQPfaXj1eLN()pK3hA1H8Uj8ICi1KBCKk34qfEXZCiABNhfwyDW76L9u5LA1H)v)v8AgOxVN1Dy)jpxFOj11aNudTWXvFqVEx11RIgLxgXCB5onW2CpKn3XS0Wp66SvcMKHXrj9XhRDs5F8rRNoE7tPScY4wD)w6PcdKpWrezDjhQBIubmceEsKtL)fRtYMnv5YLMi5E0xvYIHUgXPwT6ZOsDJ4cD(XhDDLq3trBM7(tp3FiLN10k73a19CprDIam9G8Yk2KH261t00HD6w)oL6QHtE8XZSxcW9CpzkLGP1j7QPJalq2hwGv06ZRdEms2vaiQD8AUA4GEEao5jrNbBejq2ffacwXCFGPkW4PzDSubGx9ApahrA08oiMbNUUfL7qlunR3GYthjL2nVxKP9Z1TL8LDVBXYNnYdSw7OzZGth3nMDSCvAIs8FjUJIvb6IANt(xKTAAnvGDSRSu6PKA1d1ju1o)4J2UY56yBOoZrr)Pr51UQeEH257gmXc4ZzoU3HbF5uDpcKM9vU(D841MWrRgriyOx9B5sn0Z40XJiePB1VoBVCkHTSJaR4nOJ3BfyIghdkHppuJQo(jAhB9sQQOERq4MGp(x1JdBV4iqw5DWav4Zutqhxkn8Fz6svsbov1ZUCAJHyske8Cx3QItMxeHuTIIA5kCtzLXs4gkCakylfEYhtt5LP6lO3qJufjmcM8TaL1HiSxwoyfX6Ls7u0JIaxfTASof63vKuGxPKf1GEFS5rnOSYWrHs8LsE6YHdS6Y1i3UCP4)Od1T4G6W)P6tf04WuAvjN6K66cr2SX1OjrDj4mRwrJZfnRgBJH(112XCYPBPwjRX50SvsrsEQgzUMNZHLS5foil5IA37yYq6GjAADFJ0EVDlZm6kHUX(EnB0jLxj4uSEbJ15mp3wsgdQUlqWWk6Q0JE(AU4selc05mn))1j3xoD8JpAScmMqu)94Q1YkzL7XGfFafm31xwLEtm6zGjtho72gsEG1EhEvtP52UbRmwbUAut4r0DZWD)OZV5TW1LNlSOfp820fjlreEz3HtEoBIlmVTPE2KEbiXTJ(ehODv3rnc0m)yC4gYBcDRoFP6TxL5B1VWQykbTV)lGSj1ydg5itb583HPDfC8Pe33mssNabvqQ8RYV2ipwYzwX1blkvTQh)XhLstS02zD8cUS5r9AiZDOYSt7u6A8AMQe9(gV5eRCW(fUmIBuzUIv1JxG1genT74VqGeMm2Ns73myY3K8RVZUx4pFyVNu7nmMc4DplGd6pft)YoOn09FyDoUjjvK7leY)bm9Bj7xcArKB0t)wFsAuefjEqKox00h5Q6GStljITViHMMifJKRuUtxx2hRbbS1SueJJJ2apGivV4J4gOqS7kBaDAOBRdHKWNZYCuFq6VUldL)Z32VDslw5bgnX1GzXhfBgngniCkpIkqKRWBhbFCZn0Agayh98AHge3yICeIlJUZTPq4YZdt4Al54ecJbSB9EQeVf)6vcnEA08LxoT75rAOxz8FURSRwZYwnVOr7FQZ)4rD0ilJUs5Tpz4fUM)tJDk54zKVjtYuBbZym)1PRYyD10ZNq3KbXCnMKkWhFuN5vBKjKvz8mCN(h370qSJXqm4bFRnF5I2P6Txng3lgOJmJRRxXjgCIH0Of3eMbgzUiF(LEG(y4IC1xDVInPItgiQGkCFFN)3Wm)rQ4l6E3R4AQmZGtxqkEkCTjJL0(8YYoABghIoeg70lhX38blSmDpdBn)BoonClLlHaILBqK45sxr(y(6QSIKYzRs(uEXJpgr)FJZU3Jj10wiZ9ihfGnCGBiJMu6)zzQSwY435LuhB(aj9)VIzOWYYeS4xBHY6MA5kJEownWuLzTlkl9pR7WNlmksER87PoDpX5KEhFP3VKOYJcb3NaC03MSnv9Lu6ZpUVQmBjRM(40N9LPK687utNC4C8QK1RX8pwSVmzzAHZTziCuzdNWOSEi61)Q5xNmTFhN6AzGg37OicUYHVjvWnE0E6ZOb61kIMoR8pLcQ62TJiQWfzyfmzKiCt20i3RuNFQwPEBe59FStc959yUs(112BirjmvoDxo(eHvDl3bn17eq6SC944IasSbCHRSRB767sT0ACH3tuAJSWKeCkt648w6cSg58D8fdl7ri8M6g5qgYMtESUZseY0e1GcUS7fdEzxhIB3)qzfE3bbUO)YUfkbQVzxY2QzvfjBlxLcCElsHM0JXs6yJRCGB9AdYr3vA790GSgIK0swgFXGXwFDTbEQoIJ(HhAmb7yA95IjoOzUXCk9YPAMMoCAIE6bwmEcBwmV8)KAMS(MIy21TEnC1YE(25NIap5DheF93xhRa2wbjg5IMH4cx(9GavifwGTDhaMH3rimPhZ80H29qt1tBxgPSAcp(sWlB7vJXsTwxZW4wIiKIXXjfm69z9Qq06N)6EH9qn6ju3NZirCRKDNlsQHkWdwYs70IOieraibrqdC4OshRpxLsCmv5HdY49pSJCftVbL4kslt133zxwnfMlzje4YPJdzTlKADQe75iNV3ZlHw(iE9e7OfWpvModOjlT)(YKffzywbswpBh0ahYngIGHkOVU7sbnK4D49rX0p2M8xTH21kQLKQzGztunVSdDGnFtoPAUzUUslQkLRXB1zIvXvkvKkofnOIWQtNdjwzMqZPdBMLplGpYdOEVh7kNrdhhe6G1lVmS2a0iHO4gx17z64gxVoa6Nf3g2yDRapFG9vdRn(cNn2HmYBDu5v9cjJgLAihCmMEQHKYGCh0kk1kzRBK65axCJdUjP9ZZG2a8QbCxwUUN1gbnuoi9AS7JSxJM1GWTmcwPlP2s5GNGADE1qZC63YfmDVxy5sJgZzTX1dT2JWSN7AQyAT)r1sauwGfcmxvfCKvnX4oEkAc1X751lWA3jFMNEAXISOgRjDXsrztKG8C0k4z(XXzRG1D7nIwlsJvnMAGz12haNOgIzxjCesFtH6iFg6meJuBCocUuFfWnm5SY6cUbr13(vFBuGv3nVe8FWr1mqO1N7gUj4AufxYrVzrgZ8XV1Lby4n9qrk7O2sXXmkE2nBBEP)DLSjSnH4oId)TDgzyY3IQd15HtrOkqPPwqA1s4ssjk03A1PABOxliTTGbIPa(NYzf323Hv8IQ643Dy(1IAC7WC6fJGsTUv7ZQg5atNsUOeWBnHVXoqnZFnWftzb4FGBhhdVCxvKzdonXRxWafAHYGzXwjrnvPGRsx5uPC43daV9IihjtJLGcU8IbbNQqAHSnSVo8W6N(kSZBKdj5jTkDrr(68ILkp7JpaeYT0Adb695AjwkiaziGykiFUFXaI(PF24aq1NDIOMk)4IiyE8LsCw3aGs(nbPHDu9tWb21UoD(UMgREEsvhX1szr)nXAKMtVqDlwKWKX3YJMIrAFrn80zrmFAPeH0y7F9lKb0P2dROG47EHZ5N7M2034m51FbHpTprf(Or1ux6pPQt4MCQ)L0qcD1FN)e8pMVtUxZpGp4T8ZDRtFjVeBRhJf)SafRf56985MhRIy0LR05y0F3Xs4jwhmtRyXA0sziSfOsGmvFcI6Wdois)q9LiP0rChBNgs2Jc8SzVk6dSItMiQgZv0npKO1TV8SdQ(yfFSBWX4HBrZ25h8Xh7QBK8S6NhzS4aS01EUULaOmbo2NsRhIrBgcI(W24y5YbJG9dlJstSEIz(fZdDm)gPPCk)t0j94gM586irnOlRju0L2wVk39MPyNBUwOKvslfnNDVR(gV8YqdhnNTxoAyVEokzKHOYdf1ow(mRpDqhQMDJpV6xoP(IcSmQVS4(BJEeD25xa9i6BL(9wJxppcZD0gUashDKTDA9c(7(xLCR0n2pPjNqMBAZ7Pi3ogDMwAPnYsTxNjWkWJCPjODryX5QvV7Tunpr35lbKYAK4MaB6WEYEAEhynvJ)3h9y0FcOhdDqpQ)XA2h9yupvkPF6XFHE1m(N0VP3hf)RjzvEvU5JnZG3K3PEruKnA1SwlyWmLlQdW24dCGLrdWe9s)o(n32RUC6hSVB(Fp]] )


end
