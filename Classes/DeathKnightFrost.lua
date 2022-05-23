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


    spec:RegisterPack( "Frost DK", 20220523, [[da1UAdqiPs9iPQsxIivztevFsLQrbHofezvuvkVcKywuvClIuP2fQ(fe0Wis6yQuwgu0ZKkQPjvvDnIeBtQQ4BsfIXbfsNdkewNubZdK09ik7tQK)bfI6Gsfklec8qQkzIsfsCrOqLncfk9rPcPgjuiItsKQALquVuQqsMPurUjuisTtQQ6NqHIHcfQAPsfQEkvzQsv5QqHi5RePsgluWELYFPYGbomLfdPhlYKvXLr2SO(mOmAqCAHvlviPEni1Sr52GQDl53QA4QKJtKkwUspNW0jDDOA7qPVlvz8ePCEQQSEQkvZNi2VIB3A918oMsn)XuQyIPuLcMDMFtQsP)9)wZt97IAExwcAdg18kdo18Wy3xOdOJshvnVlZp2BNwFnpXJVjQ5br1lrhqicHfkeCuE6HJqrahNzA8vATSIqrapHWMhkEWuPF1qBEhtPM)ykvmXuQsbZoZVjvP0)oJrBEgUc53MNxa3xnpiX5qvdT5DirQ51rHmfYa6OQcyq0bGXUVqhKXiT53aWSZ(mamLkMyoipi7liwbJedYs3dOJtWFS0zamtOs3ck91za4cdgnGppaFbXIsmGppaPFIgGjgqOd48KOURd4Iz(nGEeJnGOgW1AjnseFqw6EaDu(6UoGeeRkInamwgjGKwlRd4GVrbBaiyjtHmGppaVOoRb7fgV5XcHkA918EuwO0AA8L76FwuWA918)wRVMhvgkJone08SKgF18wc(VcIrcHRxukTnVdjsBCPXxnpm()zrbBayS)oamguwO0AA8vhgGNARkgWnPoabL(6igakL)LgagFWy2oGppam29f6aspCsmGpNhGV6O08sBO0gwZdRTHHYi(2ZHINZIbirYaSKgyjhve8GedOlzdaZM28hZwFnpQmugDAiO5L2qPnSMN4IymNAlmsfCymlfgZzhSwLOb0LSbG5aKpa1yuP88(cvK8tHqCQmugDAEwsJVAEWywkmMZoyTkrnT5FNB918OYqz0PHGMxAdL2WAEO45mh6GXIcMdULGefXxYs6aKpalPbwYrfbpiXa6Aayoa5dO7bG12Wqze)qMcr4o4KZsAGLAEwsJVAE59fQi5NcHAAZ)(36R5rLHYOtdbnplPXxnVhLfkTMsnV0gkTH18qXZzo0bJffmhClbjkIVKL0MxYVeJCQTWiv08)wtB(lLwFnpQmugDAiO5L2qPnSMNL0al5OIGhKyaYgWTbiFayTnmugXZ7luNq3aAYL(6GhQO5zjn(Q5L3xOoHUb0utB(3pT(AEuzOm60qqZZsA8vZ7rzHsRPuZlTHsBynpu8CMdDWyrbZb3sqII4lzjT5L8lXiNAlmsfn)V10M)DKwFnpQmugDAiO5L2qPnSMhwBddLr891CYTbCQ5zjn(Q5b57XIcMdLzcTPn)XOT(AEuzOm60qqZlTHsBynpXfXyo1wyKk4WywkmMZoyTkrdOlzdaZbiFalEfj313Jw(HYrk0ba1b0psT5zjn(Q5bJzPWyo7G1Qe10M)yeT(AEuzOm60qqZZsA8vZlVVqDcDdOPMxAdL2WAElEfj313Jw(HYrk0ba1b0rKAZl5xIro1wyKkA(FRPn)Vj1wFnpQmugDAiO5zjn(Q59OSqP1uQ5L2qPnSM3Ix0a6s2a68aKpaehq3daUfLdIvhoMqgGejdi9yPYkLxuAF2VNbirYaspwQSs5q73gwnaKgGejdyXlAaDjBa9FaYhaClkheRoCmH08s(LyKtTfgPIM)3AAZ)B3A918OYqz0PHGMxAdL2WAEwsdSKJkcEqIb0LSb0)biFaDpaS2ggkJ4hYuic3bNCwsdSuZZsA8vZlVVqfj)uiutBAZl9SJdczR26R5)TwFnpQmugDAiO5L2qPnSMh6ledq(aYbmiQBj4wuIba1balDgG8bG4aw8IgauhaMdqIKb09aqXZzo0bJffmhClbjkIJFna5daXb09aGBr5Gy1HJjKbiFaO45mp9SJdczRYfQLGEaDjBa9FaqzalEr5FHrCOFMgRjCzd7VCQmugDgGejdaUfLdIvhoMqgG8bGINZ80ZooiKTkxOwc6b01aWOdakdyXlk)lmId9Z0ynHlBy)LtLHYOZaqAasKmau8CMdDWyrbZb3sqII44xdq(aqCaDpa4wuoiwD4yczaYhakEoZtp74Gq2QCHAjOhqxdaJoaOmGfVO8VWio0ptJ1eUSH9xovgkJodqIKba3IYbXQdhtidq(aqXZzE6zhheYwLlulb9a6Aa3K6aGYaw8IY)cJ4q)mnwt4Yg2F5uzOm6maKgasnplPXxnVeelkH7ZUirnT5pMT(AEuzOm60qqZZsA8vZlbXIs4(SlsuZ7qI0gxA8vZdJucAah8nkydaJpymBhqVqHmaPFIs2fcrWsMcP5L2qPnSMx3dqngvk)rzHsRPXxCQmugDgG8bGINZ8RGXS19zxEFHYXVgG8bGINZ80ZooiKTkxOwc6b0LSbCtQdq(aqCaO45m)kymBDF2L3xO8LGBrjgauhaS0za(2aqCa3gaugq6F257v88(cTNFlCHlJV(XxYo(naKgGejdafpN54fKN5NtOlvWui8LGBrjgauhaS0zasKmau8CMNGyVWHAfXxcUfLyaqDaWsNbGutB(35wFnpQmugDAiO5zjn(Q5LGyrjCF2fjQ5DirAJln(Q5HXGRI4qd4ZdaJpymBhaUGmy0a6fkKbi9tuYUqicwYuinV0gkTH186EaQXOs5pkluAnn(ItLHYOZaKpGdzkeh0vadIYx8IY)cJ4zJXOYLwCHDODaYhq3dafpN5xbJzR7ZU8(cLJFna5di9p789k(vWy26(SlVVq5lb3IsmGUgWnPma5daXbGINZ80ZooiKTkxOwc6b0LSbCtQdq(aqCaO45mhVG8m)CcDPcMcHJFnajsgakEoZtqSx4qTI44xdaPbirYaqXZzE6zhheYwLlulb9a6s2aU15bGutB(3)wFnpQmugDAiO5L2qPnSMx3dqngvk)rzHsRPXxCQmugDgG8b09aoKPqCqxbmikFXlk)lmINngJkxAXf2H2biFaO45mp9SJdczRYfQLGEaDjBa3K6aKpGUhakEoZVcgZw3ND59fkh)AaYhq6F257v8RGXS19zxEFHYxcUfLyaDnamLAZZsA8vZlbXIs4(SlsutB(lLwFnpQmugDAiO5zjn(Q5LGyrjCF2fjQ5DirAJln(Q5HXVewQ0b4RNDgagjKT6aES0MSRROGnGd(gfSbCfmMTnV0gkTH18uJrLYFuwO0AA8fNkdLrNbiFaDpau8CMFfmMTUp7Y7luo(1aKpaehakEoZtp74Gq2QCHAjOhqxYgWT(pa5daXbGINZC8cYZ8Zj0Lkykeo(1aKizaO45mpbXEHd1kIJFnaKgGejdafpN5PNDCqiBvUqTe0dOlzd4ggXaKizaP)zNVxXVcgZw3ND59fkFj4wuIba1b05biFaO45mp9SJdczRYfQLGEaDjBa36)aqQPnT59OSqP104RwFn)V16R5rLHYOtdbnplPXxnVLG)RGyKq46fLsBZ7qI0gxA8vZdJbLfkTMgFnG9vtJVAEPnuAdR5zjnWsoQi4bjgqxYgqNhG8bG12WqzeF75qXZzrtB(JzRVMhvgkJone08sBO0gwZR7bGINZCOdglkyo4wcsueh)AaYhaIdyXlAaqDayoajsgGAmQuEK8ZPg7lbNkdLrNbiFaO45mps(5uJ9LGVeClkXaG6aGLodW3gaMdqIKbK(6GhkhVyKjGqhxEPY39JtLHYOZaKpaehakEoZXlgzci0XLxQ8D)4lb3IsmaOoayPZa8TbG5aKizaO45mhVyKjGqhxEPY39Jlulb9aG6a68aqAai18SKgF18Y7luNq3aAQPn)7CRVMhvgkJone08sBO0gwZR7bGINZCOdglkyo4wcsueh)AaYhWIx0a6s2a68aKpaehakEoZ3aoXxcUfLyaqDaDEaYhakEoZ3aoXXVgGejdWsAGLCNx559fQltyPDaqDawsdSKJkcEqIbGuZZsA8vZdY3JffmhkZeAtB(3)wFnpQmugDAiO5L2qPnSMx3dafpN5qhmwuWCWTeKOio(1aKpaXfXyo1wyKk4WywkmMZoyTkrdOlzdaZbirYa6EaO45mh6GXIcMdULGefXXVgG8bG4aoekEoZxZ3)nsexOwc6ba1biLbirYaoekEoZxZ3)nseFj4wuIba1balDgGVnG(paKAEwsJVAEWywkmMZoyTkrnT5VuA918OYqz0PHGMxAdL2WAEO45mh6GXIcMdULGefXxYs6aKpaXfXyo1wyKk459fQi5NcHgqxdaZbiFaDpaS2ggkJ4hYuic3bNCwsdSuZZsA8vZlVVqfj)uiutB(3pT(AEuzOm60qqZZsA8vZ7rzHsRPuZlTHsBynpu8CMdDWyrbZb3sqII4lzjT5L8lXiNAlmsfn)V10M)DKwFnpQmugDAiO5L2qPnSMNL0al5OIGhKyaYgWTbiFayTnmugXZ7luNq3aAYL(6GhQO5zjn(Q5L3xOoHUb0utB(JrB918OYqz0PHGMxAdL2WAEyTnmugX3xZj3gWPbiFaIlIXCQTWivWH89yrbZHYmHoGUKnamBEwsJVAEq(ESOG5qzMqBAZFmIwFnpQmugDAiO5L2qPnSMN4IymNAlmsfCymlfgZzhSwLOb0LSbGzZZsA8vZdgZsHXC2bRvjQPn)Vj1wFnpQmugDAiO5zjn(Q5L3xOoHUb0uZlTHsBynVUhGAmQuUH1ywLGqCQmugDgG8b09aqXZzo0bJffmhClbjkIJFnajsgGAmQuUH1ywLGqCQmugDgG8b09aWAByOmIVVMtUnGtdqIKbG12WqzeFFnNCBaNgG8bS4fX1ao503H5a6s2aGLonVKFjg5uBHrQO5)TM28)2TwFnpQmugDAiO5L2qPnSMhwBddLr891CYTbCQ5zjn(Q5b57XIcMdLzcTPn)VHzRVMhvgkJone08SKgF18EuwO0Ak18s(LyKtTfgPIM)3AAtBEc1QJTNwFn)V16R5rLHYOtdbnplPXxnVLG)RGyKq46fLsBZ7qI0gxA8vZZtT6y7zaIOGXiPB1wyKoG9vtJVAEPnuAdR5H12WqzeF75qXZzrtB(JzRVMhvgkJone08sBO0gwZdfpN5qhmwuWCWTeKOi(swsBEwsJVAEpkluAnLAAZ)o36R5rLHYOtdbnV0gkTH18WAByOmIVVMtUnGtdq(aqXZz(gWj(sWTOedaQdOZnplPXxnpiFpwuWCOmtOnT5F)B918OYqz0PHGMxAdL2WAEyTnmugXZ7luNq3aAYL(6GhQO5zjn(Q5L3xOoHUb0utB(lLwFnpQmugDAiO5L2qPnSMx3d4qMcXbDfWGO8fVO8VWi(A((VrIgG8bG4aoekEoZxZ3)nsexOwc6ba1biLbirYaoekEoZxZ3)nseFj4wuIba1balDgGVnG(paKAEwsJVAEWywkmMZoyTkrnT5F)06R5rLHYOtdbnV0gkTH18s)ZoFVIVe8FfeJecxVOuA5lb3IsmaOkBayoaFBaWsNbiFaQXOs5WmfcTrbZj0FHZPYqz0P5zjn(Q5L3xOoHUb0utB(3rA918OYqz0PHGMxAdL2WAEyTnmugX3xZj3gWPMNL04RMhKVhlkyouMj0M28hJ26R5rLHYOtdbnV0gkTH18w8ksURVhT8dLJuOdaQdaXbCtkdakdqngvkFXRi5mvPc304lovgkJodW3gGugasnplPXxnV8(c1j0nGMAAZFmIwFnpQmugDAiO5L2qPnSMx3dafpN5599DQCx4mbXXVgG8bOgJkLN333PYDHZeeNkdLrNbirYaWAByOmIFitHiChCYzjnWsdq(aqXZz(HmfIWDWjUqTe0daQdO)dqIKbS4fnGUKnG(pa5dqqQd9lCbxdAXeJ66)vAasKmaehaClkheRoCmHmajsgq3di9yPYkLxbmiQlB0aKizaDpabPo0VWfCnOftmQR)xPbG0aKpa1yuPCyMcH2OG5e6VW5uzOm6ma5dafpN5lb)xbXiHW1lkLwo(1aKizaDpabPo0VWfCnOftmQR)xPbiFalEfj313Jw(HYrk0b01aqCaykLbaLbOgJkLV4vKCMQuHBA8fNkdLrNb4BdqkdaPMNL04RM3JYcLwtPM28)MuB918SKgF18Y7luNq3aAQ5rLHYOtdbnT5)TBT(AEwsJVAEq(TCF21lkL2MhvgkJone00M)3WS1xZZsA8vZZ2KvKt)DPsBEuzOm60qqtBAZd9fonsqhfSwFn)V16R5rLHYOtdbnplPXxnVhLfkTMsnVKFjg5uBHrQO5)TMxAdL2WAElEfj313J2bavzdaXb0FPmaOma1yuP8fVIKZuLkCtJV4uzOm6maFBaszai18oKiTXLgF18qWsMczaFEaErDwd2lSb0XsAGLgqh)vtJVAAZFmB918OYqz0PHGMxAdL2WAEyTnmugX3Eou8CwmajsgGL0al5OIGhKyaDjBayoajsgWIxrYD99ODaqDaDgZbiFalErCnGto9DyoaOoGfVIK767r7aq4aU1pnplPXxnVLG)RGyKq46fLsBtB(35wFnpQmugDAiO5L2qPnSM3IxrYD99ODaqDaDgZbiFalErCnGto9DyoaOoGfVIK767r7aq4aU1pnplPXxnVdzkeNvh3HsMFnT5F)B918OYqz0PHGMxAdL2WAEyTnmugX3xZj3gWPbiFaioGfVIK767r7a6s2a6VugGejdyXlIRbCYPVRZdaQYgaS0zasKmGfVO8VWi(AWi3NDkeYL333PYLGyWVIV4uzOm6majsgG4IymNAlmsfCiFpwuWCOmtOdOlzdaZbirYaqXZz(gWj(sWTOedaQdOZdaPbirYaw8ksURVhTdaQdOZyoa5dyXlIRbCYPVdZba1bS4vKCxFpAhachWT(P5zjn(Q5b57XIcMdLzcTPn)LsRVMhvgkJone08sBO0gwZdfpN5qhmwuWCWTeKOio(1aKpaXfXyo1wyKk459fQi5NcHgqxdaZbiFaDpaS2ggkJ4hYuic3bNCwsdSuZZsA8vZlVVqfj)uiutB(3pT(AEuzOm60qqZZsA8vZ7rzHsRPuZlTHsBynpu8CMdDWyrbZb3sqII4lzjT5L8lXiNAlmsfn)V10M)DKwFnpQmugDAiO5L2qPnSM3IxrYD99ODaqv2a6hPoa5dyXlIRbCYPVRZdORbalDAEwsJVAEq(TCF21lkL2M28hJ26R5rLHYOtdbnV0gkTH18exeJ5uBHrQGN3xOIKFkeAaDnamhG8b09aWAByOmIFitHiChCYzjnWsnplPXxnV8(cvK8tHqnT5pgrRVMhvgkJone08SKgF18EuwO0Ak18sBO0gwZBXRi5U(E0YpuosHoGUgaMszasKmGfViUgWjN(U(paOoayPtZl5xIro1wyKkA(FRPn)Vj1wFnpQmugDAiO5L2qPnSMhwBddLr891CYTbCQ5zjn(Q5b57XIcMdLzcTPn)VDR1xZJkdLrNgcAEPnuAdR5T4vKCxFpAhauhGuKAZZsA8vZZ2KvKt)DPsBAtBEOVWD9plkyT(A(FR1xZJkdLrNgcAEwsJVAElb)xbXiHW1lkL2M3HePnU04RMhcwYuid4ZdWlQZAWEHnGR)zrbBa7RMgFnGomaHARkgWnPkgakL)LgacEVbeIbyyTGzOmQ5L2qPnSMNL0al5OIGhKyaDjBayoajsgawBddLr8TNdfpNfnT5pMT(AEuzOm60qqZZsA8vZ7rzHsRPuZlTHsBynpu8CMdDWyrbZb3sqII4lzjDaYhq6F257v8RGXS19zxEFHYxcUfLyaDnGo38s(LyKtTfgPIM)3AAZ)o36R5rLHYOtdbnV0gkTH18WAByOmIVVMtUnGtnplPXxnpiFpwuWCOmtOnT5F)B918OYqz0PHGMxAdL2WAEO45mh6GXIcMdULGefXxYs6aKpGfVIK767rl)q5if6a6AaioGBszaqzaQXOs5lEfjNPkv4MgFXPYqz0za(2aKYaqAaYhG4IymNAlmsf88(cvK8tHqdORbG5aKpGUhawBddLr8dzkeH7GtolPbwQ5zjn(Q5L3xOIKFkeQPn)LsRVMhvgkJone08sBO0gwZBXRi5U(E0YpuosHoGUKnaehqNLYaGYauJrLYx8ksotvQWnn(ItLHYOZa8TbiLbG0aKpaXfXyo1wyKk459fQi5NcHgqxdaZbiFaDpaS2ggkJ4hYuic3bNCwsdSuZZsA8vZlVVqfj)uiutB(3pT(AEuzOm60qqZZsA8vZ7rzHsRPuZlTHsBynVfVIK767rl)q5if6a6s2aWuknVKFjg5uBHrQO5)TM28VJ06R5rLHYOtdbnV0gkTH18w8ksURVhT8dLJuOdaQdatPoa5dqCrmMtTfgPcomMLcJ5SdwRs0a6s2aWCaYhq6F257v8RGXS19zxEFHYxcUfLyaDnaP08SKgF18GXSuymNDWAvIAAZFmARVMhvgkJone08SKgF18Y7luNq3aAQ5L2qPnSM3IxrYD99OLFOCKcDaqDayk1biFaP)zNVxXVcgZw3ND59fkFj4wuIb01aKsZl5xIro1wyKkA(FRPn)XiA918OYqz0PHGMxAdL2WAEP)zNVxXVcgZw3ND59fkFj4wuIb01aw8I4AaNC676)aKpGfVIK767rl)q5if6aG6a6VuhG8biUigZP2cJubhgZsHXC2bRvjAaDjBay28SKgF18GXSuymNDWAvIAAZ)BsT1xZJkdLrNgcAEwsJVAE59fQtOBan18sBO0gwZl9p789k(vWy26(SlVVq5lb3IsmGUgWIxexd4KtFx)hG8bS4vKCxFpA5hkhPqhauhq)LAZl5xIro1wyKkA(FRPnT5L(ND(ELO1xZ)BT(AEuzOm60qqZlTHsBynpu8CMFfmMTUp7Y7luo(vZ7qI0gxA8vZdJ)14RMNL04RM31RXxnT5pMT(AEuzOm60qqZZsA8vZJGF99O1T4f56r21xnVdjsBCPXxnpF9p789krZlTHsBynp1yuP8hLfkTMgFXPYqz0zaYhWIx0aG6a6NbiFaioaS2ggkJ4c1DXSQIc2aKizayTnmugXTZr4wcUf1aqAaYhaIdi9p789k(vWy26(SlVVq5lb3IsmaOoaPma5daXbK(ND(EfpZibK0AzLVeClkXa6AaszaYhG4XzOrD4x4cfNroAXV04lovgkJodqIKb09aepodnQd)cxO4mYrl(LgFXPYqz0zainajsgakEoZVcgZw3ND59fkh)Aainajsga6ledq(aYbmiQBj4wuIba1bGPuBAZ)o36R5rLHYOtdbnV0gkTH18uJrLYrxYuiUp7erDwd2lmovgkJodq(aw8IgauhGugG8bS4vKCxFpAhauhaIdOFK6aKUhaId4qMcXbDfWGO8fVO8VWioe)ekTHnaFBaszainaP7bG4aw8IY)cJ4Rb)Yk1PRvImTuLiovgkJodW3gGugasdaPbiFaioau8CMJUKPqCF2jI6SgSxyC8RbirYaqFHyaYhqoGbrDlb3IsmaOoamL6aqQ5zjn(Q5rWV(E06w8IC9i76RM28V)T(AEuzOm60qqZlTHsBynp1yuP8irj7ItLHYOtZZsA8vZJGF99O1T4f56r21xnT5VuA918OYqz0PHGMxAdL2WAEQXOs5Olzke3NDIOoRb7fgNkdLrNbiFaioaS2ggkJ4c1DXSQIc2aKizayTnmugXTZr4wcUf1aqAaYhaIdi9p789ko6sMcX9zNiQZAWEHXxcUfLyasKmau8CMJUKPqCF2jI6SgSxyC8RbiFalEfj313J2b01a6VugGejdi9p789ko6sMcX9zNiQZAWEHXxYo(na5dyXRi5U(E0oGUgq)iLbGuZZsA8vZ7kymBDF2L3xOnT5F)06R5rLHYOtdbnV0gkTH18uJrLYJeLSlovgkJodq(a6EaO45m)kymBDF2L3xOC8RMNL04RM3vWy26(SlVVqBAZ)osRVMhvgkJone08sBO0gwZtngvk)rzHsRPXxCQmugDgG8bG4aw8ksURVhTdOlzdOZszaYhq3dafpN5g6dpktJVCSaokh)AasKmau8CMBOp8Omn(YXc4OC8RbirYaw8IY)cJ4RbJCF2PqixEFFNkxcIb)k(ItLHYOZaqAaYhaIdaRTHHYiUqDxmRQOGnajsgawBddLrC7CeULGBrnaKgG8bG4auJrLYHzkeAJcMtO)cNtLHYOZaKpau8CMVe8FfeJecxVOuA54xdqIKb09auJrLYHzkeAJcMtO)cNtLHYOZaqQ5zjn(Q5DfmMTUp7Y7l0M28hJ26R5rLHYOtdbnV0gkTH186EaO45mhDjtH4(Ste1znyVW44xdq(aw8ksURVhTdORb0psDaYhaIdafpN5xbJzR7ZU8(cLJFnajsgq6F257v8RGXS19zxEFHYxcUfLyaDnGBszai18SKgF18qxYuiUp7erDwd2lSM28hJO1xZJkdLrNgcAEPnuAdR5zjnWsoQi4bjgGSbCBaYhakEoZVcgZw3ND59fkFj4wuIba1balDgG8bGINZ8RGXS19zxEFHYXVgG8b09auJrLYFuwO0AA8fNkdLrNbiFaioGUhWAXXryPs525i4K0cHkgGejdyT44iSuPC7Ce8OgqxdOZsDainajsgqoGbrDlb3IsmaOoGo38SKgF18Y7l0E(TWfUm(6xtB(FtQT(AEuzOm60qqZlTHsBynplPbwYrfbpiXa6s2aWCaYhaIdafpN5xbJzR7ZU8(cLJFnajsgWAXXryPs525i4K0cHkgG8bSwCCewQuUDocEudORbK(ND(Ef)kymBDF2L3xO8LGBrjgaugqhzaina5daXbGINZ8RGXS19zxEFHYxcUfLyaqDaWsNbirYawlooclvk3ohbNKwiuXaKpG1IJJWsLYTZrWxcUfLyaqDaWsNbGuZZsA8vZlVVq753cx4Y4RFnT5)TBT(AEuzOm60qqZlTHsBynp1yuP8hLfkTMgFXPYqz0zaYhaIdafpN5xbJzR7ZU8(cLJFna5dO7ba3IYbXQdhtidqIKb09aqXZz(vWy26(SlVVq54xdq(aGBr5Gy1HJjKbiFaP)zNVxXVcgZw3ND59fkFj4wuIbG0aKpaehaIdafpN5xbJzR7ZU8(cLVeClkXaG6aGLodqIKbGINZC8cYZ8Zj0Lkykeo(1aKpau8CMJxqEMFoHUubtHWxcUfLyaqDaWsNbG0aKpaehWHqXZz(A((VrI4c1sqpazdqkdqIKb09aoKPqCqxbmikFXlk)lmIVMV)BKObG0aqQ5zjn(Q5L3xO98BHlCz81VM28)gMT(AEuzOm60qqZlTHsBynp1yuPC0LmfI7ZoruN1G9cJtLHYOZaKpGfVIK767r7aG6a6hPoa5dyXlAaqv2a68aKpaehakEoZrxYuiUp7erDwd2lmo(1aKizaP)zNVxXrxYuiUp7erDwd2lm(sWTOedORb0FPoaKgGejdO7bOgJkLJUKPqCF2jI6SgSxyCQmugDgG8bS4vKCxFpAhauLnGoIuAEwsJVAEq876vi0cpsURLeuLOM28)wNB918OYqz0PHGMxAdL2WAEP)zNVxXVcgZw3ND59fkFj4wuIbavzdqknplPXxnV1cb5oKDAAZ)B9V1xZJkdLrNgcAEPnuAdR5zjnWsoQi4bjgqxYgaMdq(aqCa5age1TeClkXaG6a68aKizaDpau8CMJUKPqCF2jI6SgSxyC8RbiFaioGls5WG84m(sWTOedaQdaw6majsgWAXXryPs525i4K0cHkgG8bSwCCewQuUDoc(sWTOedaQdOZdq(awlooclvk3ohbpQb01aUiLddYJZ4lb3IsmaKgasnplPXxnpHL2ihPWyUllPnT5)nP06R5rLHYOtdbnV0gkTH18SKgyjhve8GedORbiLbirYaw8IY)cJ4xqiBF4FrcovgkJonplPXxnVdzkeNvh3HsMFnTPnVdLnCM26R5)TwFnplPXxnp4rDC5LiFNAEuzOm60qqtB(JzRVMhvgkJone08(RMNG0MNL04RMhwBddLrnpSgdNAEioas6Ghxx0HhLiT4QHYiN0b3kfhU7qyJenajsgajDWJRl6WviKlhRqDIawWgasdq(aqCaP)zNVxXJsKwC1qzKt6GBLId3DiSrI4lzh)gGejdi9p789kUcHC5yfQteWcgFj4wuIbG0aKizaK0bpUUOdxHqUCSc1jcybBaYhajDWJRl6WJsKwC1qzKt6GBLId3DiSrIAEhsK24sJVAEy8lHLkDaIlkf5Godq3OGMuXaqPOGnaCbDgqVqHmadxF4MgPbWIIenpS26kdo18exukYbDC6gf0K20M)DU1xZJkdLrNgcAE)vZtqAZZsA8vZdRTHHYOMhwJHtnplPbwYrfbpiXaKnGBdq(aqCaRfhhHLkLBNJGh1a6Aa3KYaKizaDpG1IJJWsLYTZrWjPfcvmaKAEyT1vgCQ5ju3fZQkkynT5F)B918OYqz0PHGM3F18eK28SKgF18WAByOmQ5H1y4uZZsAGLCurWdsmGUKnamhG8bG4a6EaRfhhHLkLBNJGtsleQyasKmG1IJJWsLYTZrWjPfcvma5daXbSwCCewQuUDoc(sWTOedORbiLbirYaYbmiQBj4wuIb01aUj1bG0aqQ5H1wxzWPMNDoc3sWTOAAZFP06R5rLHYOtdbnV)Q5jiT5zjn(Q5H12WqzuZdRXWPMhkEoZ3aoXXVgG8bG4a6EalEr5FHr81GrUp7uiKlVVVtLlbXGFfFXPYqz0zasKmGfVO8VWi(AWi3NDkeYL333PYLGyWVIV4uzOm6ma5dyXRi5U(E0YpuosHoGUgagDai18WARRm4uZBFnNCBaNAAZ)(P1xZJkdLrNgcAE)vZtqAZZsA8vZdRTHHYOMhwJHtnV0xh8q50ANizAuWCOSV3aKpau8CMtRDIKPrbZHY(ECHAjOhGSbG5aKizaPVo4HYXlgzci0XLxQ8D)4uzOm6ma5dafpN54fJmbe64Ylv(UF8LGBrjgauhaIdaw6maFBayoaKAEyT1vgCQ5L3xOoHUb0Kl91bpurtB(3rA918OYqz0PHGM3F18eK28SKgF18WAByOmQ5H1y4uZ7qMcXz1XDOK5hxJe0rbBaYhq6XsLvkVcyqux2OMhwBDLbNAEhYuic3bNCwsdSutB(JrB918OYqz0PHGMNL04RM3sW)vqmsiC9IsPT5DirAJln(Q51XUUy(nam29f6aWyjS06ZaGBrPwudq6N8Ba9zSVedWQZaGMORb0Xj4)kigjedq6kkL2bSpJffSMxAdL2WAEPVo4HYjS0M3xOdq(auJrLYHzkeAJcMtO)cNtLHYOZaKpaehq3dqngvk)rzHsRPXxCQmugDgG8bK(ND(Ef)kymBDF2L3xO8LGBrjgGejdqqQd9lCbxdAXeJ66)vAaYhGAmQu(JYcLwtJV4uzOm6ma5dO7bGINZ8RGXS19zxEFHYXVgasnT5pgrRVMhvgkJone08SKgF18G89yrbZHYmH28sBO0gwZR7bCELN3xOUmHLw(sWTOedq(aqCaQXOs5rIs2fNkdLrNbirYa6EaO45mhDjtH4(Ste1znyVW44xdq(auJrLYrxYuiUp7erDwd2lmovgkJodqIKbOgJkL)OSqP104lovgkJodq(as)ZoFVIFfmMTUp7Y7lu(sWTOedq(a6EaO45mh6GXIcMdULGefXXVgasnVKFjg5uBHrQO5)TM28)MuB918OYqz0PHGMxAdL2WAEO45mps(5uJ9LGVeClkXaGQSbalDgGVnamhG8bOgJkLhj)CQX(sWPYqz0zaYhG4IymNAlmsfCymlfgZzhSwLOb0LSbG5aKpaehGAmQuEKOKDXPYqz0zasKma1yuPC0LmfI7ZoruN1G9cJtLHYOZaKpG0)SZ3R4Olzke3NDIOoRb7fgFj4wuIb01aUjLbirYauJrLYFuwO0AA8fNkdLrNbiFaDpau8CMFfmMTUp7Y7luo(1aqQ5zjn(Q5bJzPWyo7G1Qe10M)3U16R5rLHYOtdbnV0gkTH18qXZzEK8ZPg7lbFj4wuIbavzdaw6maFBayoa5dqngvkps(5uJ9LGtLHYOZaKpaehGAmQuEKOKDXPYqz0zasKma1yuPC0LmfI7ZoruN1G9cJtLHYOZaKpGUhakEoZrxYuiUp7erDwd2lmo(1aKpG0)SZ3R4Olzke3NDIOoRb7fgFj4wuIb01aUj1birYauJrLYFuwO0AA8fNkdLrNbiFaDpau8CMFfmMTUp7Y7luo(1aqQ5zjn(Q5L3xOoHUb0utB(FdZwFnpQmugDAiO5L2qPnSMx6XsLvkVcyqux2ObiFahYuioRoUdLm)4AKGokydq(aoKPqCwDChkz(XTKgyj3sWTOedaQdaXbalDgGVnGBCPmaKgG8bG4a6EaQXOs5pkluAnn(ItLHYOZaKizaQXOs5pkluAnn(ItLHYOZaKpGUhakEoZVcgZw3ND59fkh)Aai18SKgF18EuwO0Ak10M)36CRVMhvgkJone08oKiTXLgF188fK)f0a6yjn(AaSqOdq)bS4vZZsA8vZlzmMZsA8LJfcT5XcH6kdo18spwQSsfnT5)T(36R5rLHYOtdbnplPXxnVKXyolPXxowi0MhleQRm4uZBTuymrtB(FtkT(AEuzOm60qqZZsA8vZlzmMZsA8LJfcT5XcH6kdo180nkOjv00M)36NwFnpQmugDAiO5zjn(Q5LmgZzjn(YXcH28yHqDLbNAEP)zNVxjAAZ)BDKwFnpQmugDAiO5L2qPnSMNAmQuE6zhheYwLtLHYOZaKpaehq3dafpN5qhmwuWCWTeKOio(1aKizaQXOs5Olzke3NDIOoRb7fgNkdLrNbG0aKpaehWHqXZz(A((VrI4c1sqpazdqkdqIKb09aoKPqCqxbmikFXlk)lmIVMV)BKObGuZtOBK0M)3AEwsJVAEjJXCwsJVCSqOnpwiuxzWPMx6zhheYwTPn)VHrB918OYqz0PHGMxAdL2WAEO45mhDjtH4(Ste1znyVW44xnpHUrsB(FR5zjn(Q5T4LZsA8LJfcT5XcH6kdo18qFHtJe0rbRPn)VHr06R5rLHYOtdbnV0gkTH18uJrLYrxYuiUp7erDwd2lmovgkJodq(a6EaO45mhDjtH4(Ste1znyVW44xdq(aqCaP)zNVxXrxYuiUp7erDwd2lm(sWTOedaQd4Muhasdq(aqCaRfhhHLkLBNJGh1a6AaykLbirYa6EaRfhhHLkLBNJGtsleQyasKmG0)SZ3R4xbJzR7ZU8(cLVeClkXaG6aUj1biFaRfhhHLkLBNJGtsleQyaYhWAXXryPs525i4rnaOoGBsDai18SKgF18w8Yzjn(YXcH28yHqDLbNAEOVWD9plkynT5pMsT1xZJkdLrNgcAEPnuAdR5HINZ8RGXS19zxEFHYXVgG8bOgJkL)OSqP104lovgkJonpHUrsB(FR5zjn(Q5T4LZsA8LJfcT5XcH6kdo18EuwO0AA8vtB(J5TwFnpQmugDAiO5L2qPnSMx3dqqQd9lCbxdAXeJ66)vAaYhq3dyXlk)lmIVgmY9zNcHC599DQCjig8R4lovgkJodq(auJrLYFuwO0AA8fNkdLrNbiFaP)zNVxXVcgZw3ND59fkFj4wuIba1bCtQdq(aqCayTnmugXfQ7IzvffSbirYawlooclvk3ohbNKwiuXaKpG1IJJWsLYTZrWJAaqDa3K6aKizaDpG1IJJWsLYTZrWjPfcvmaKAEwsJVAElE5SKgF5yHqBESqOUYGtnVhLfkTMgF5U(NffSM28htmB918OYqz0PHGMxAdL2WAEwsdSKJkcEqIb0LSbGzZtOBK0M)3AEwsJVAElE5SKgF5yHqBESqOUYGtnp7PM28hZo36R5rLHYOtdbnplPXxnVKXyolPXxowi0MhleQRm4uZtOwDS900M28Uwk9WrnT1xZ)BT(AEuzOm60qqZ7VAEcsJCZlTHsBynpDJcAs56noet4WfKdfpNhG8bG4a6EaQXOs5Olzke3NDIOoRb7fgNkdLrNbiFaioaDJcAs56nE6F257v8d(AA81aKEdi9p789k(vWy26(SlVVq5h8104RbiBasDainajsgGAmQuo6sMcX9zNiQZAWEHXPYqz0zaYhaIdi9p789ko6sMcX9zNiQZAWEHXp4RPXxdq6nGbG4a0nkOjLR34P)zNVxXp4RPXxdOlmYd42aqAaYgGuhasdqIKbOgJkLhjkzxCQmugDgasnVdjsBCPXxnpmoSgd3usmaBa6gf0Kkgq6F257v(mGtGno0zaO(nGRGXSDaFEa59f6a(DaOlzkKb85biI6SgSxy3fdi9p789k(aK(5be6DXaWAmCAaqmXaQFalb3I6q7awsX3Aa38zaetqdyjfFRbivUu4npS26kdo180nkOj1DZj8RsnplPXxnpS2ggkJAEyngo5iMGAEsLlLMhwJHtnVBnT5pMT(AEuzOm60qqZ7VAEcsJCZZsA8vZdRTHHYOMhwBDLbNAE6gf0K6W0j8RsnV0gkTH180nkOjLRyYHychUGCO458aKpaehq3dqngvkhDjtH4(Ste1znyVW4uzOm6ma5daXbOBuqtkxXKN(ND(Ef)GVMgFnaP3as)ZoFVIFfmMTUp7Y7lu(bFnn(AaYgGuhasdqIKbOgJkLJUKPqCF2jI6SgSxyCQmugDgG8bG4as)ZoFVIJUKPqCF2jI6SgSxy8d(AA81aKEdyaioaDJcAs5kM80)SZ3R4h8104Rb0fg5bCBainazdqQdaPbirYauJrLYJeLSlovgkJodaPMhwJHtoIjOMNu5sP5H1y4uZ7wtB(35wFnpQmugDAiO59xnpbPrU5L2qPnSMx3dq3OGMuUEJdXeoCb5qXZ5biFa6gf0KYvm5qmHdxqou8CEasKmaDJcAs5kMCiMWHlihkEopa5daXbG4a0nkOjLRyYt)ZoFVIFWxtJVgachaIdq3OGMuUIjhfpNDh8104Rb0fg5bivUuVnaKgasdW3gaId4gxkdakdq3OGMuUIjhIjCO45mxOlvWuidaPb4BdaXbG12Wqzex3OGMuhMoHFvAainaKgqxdaXbG4a0nkOjLR34P)zNVxXp4RPXxdaHdaXbOBuqtkxVXrXZz3bFnn(AaDHrEasLl1BdaPbG0a8TbG4aUXLYaGYa0nkOjLR34qmHdfpN5cDPcMczainaFBaioaS2ggkJ46gf0K6U5e(vPbG0aqQ5DirAJln(Q5HXj0aUPKya2a0nkOjvmaSgdNgaQFdi9WVSnkydqHqdi9p789Qb85bOqObOBuqtQpd4eyJdDgaQFdqHqd4GVMgFnGppafcnau8CEaHoGR9XghsWhagjMya2ae6sfmfYaG)Nih0oa9haSalnaBaqcyqODaxB8BO(na9hGqxQGPqgGUrbnPcFgGjgqpIXgGjgGna4)jYbTdi)7aI8aSbOBuqt6a6fm2a(Da9cgBa1Rdq4xLgqVqHmG0)SZ3Re8MhwBDLbNAE6gf0K6U243q9R5zjn(Q5H12WqzuZdRXWjhXeuZ7wZdRXWPMhMnT5F)B918OYqz0PHGM3F18eK28SKgF18WAByOmQ5H1y4uZtngvkhMPqOnkyoH(lCovgkJodqIKbK(6GhkNWsBEFHYPYqz0zasKmGfVO8VWioAOrbZLE2HtLHYOtZdRTUYGtnVTNdfpNfnT5VuA918SKgF18YmsajTwwBEuzOm60qqtBAZZEQ1xZ)BT(AEuzOm60qqZ7qI0gxA8vZRJ9yCdOJ)QPXxnplPXxnVLG)RGyKq46fLsBtB(JzRVMhvgkJone08sBO0gwZtngvkpVVqfj)uieNkdLrNMNL04RMhmMLcJ5SdwRsutB(35wFnpQmugDAiO5L2qPnSMhkEoZHoySOG5GBjirr8LSKoa5dO7bG12Wqze)qMcr4o4KZsAGLAEwsJVAE59fQi5NcHAAZ)(36R5rLHYOtdbnV0gkTH18WAByOmIVVMtUnGtdq(auJrLYnSgZQeeItLHYOtZZsA8vZdY3JffmhkZeAtB(lLwFnpQmugDAiO5L2qPnSMx3dafpN5BaN44xdq(aSKgyjhve8GedaQYgqNhGejdWsAGLCurWdsmGUgqNBEwsJVAEWywkmMZoyTkrnT5F)06R5rLHYOtdbnplPXxnV8(c1j0nGMAEj)smYP2cJurZ)BnV0gkTH18s)ZoFVIVe8FfeJecxVOuA5lb3IsmaOkBayoaFBaWsNbiFaQXOs5WmfcTrbZj0FHZPYqz0P5DirAJln(Q5HX(lCCMfPbyxx7Bjidq)bKwYuAa2aUee(5hW1g)gQFdqTfgPdGfcDa5FhGDDX8lkydynF)3irdiQbyp10M)DKwFnpQmugDAiO5L2qPnSMhwBddLr891CYTbCQ5zjn(Q5b57XIcMdLzcTPn)XOT(AEuzOm60qqZlTHsBynp1yuPCyMcH2OG5e6VW5uzOm6ma5dafpN5lb)xbXiHW1lkLwo(1aKpalPbwYrfbpiXa6Aayoa5dO7bG12Wqze)qMcr4o4KZsAGLAEwsJVAE59fQi5NcHAAZFmIwFnpQmugDAiO5L2qPnSMhwBddLr8dzkeH7GtolPbwAaYhakEoZpKPqeUdoXfQLGEaqDa9FasKma1yuPCyMcH2OG5e6VW5uzOm6ma5dafpN5lb)xbXiHW1lkLwo(vZZsA8vZ7rzHsRPutB(FtQT(AEuzOm60qqZZsA8vZlVVqDcDdOPMxAdL2WAElEfj313Jw(HYrk0ba1bG4aUjLbaLbOgJkLV4vKCMQuHBA8fNkdLrNb4BdqkdaPMxYVeJCQTWiv08)wtB(F7wRVMhvgkJone08sBO0gwZR7bG12Wqze)qMcr4o4KZsAGLAEwsJVAE59fQi5NcHAAZ)By26R5rLHYOtdbnplPXxnVhLfkTMsnV0gkTH18w8ksURVhT8dLJuOdORbG4aWukdakdqngvkFXRi5mvPc304lovgkJodW3gGugasnVKFjg5uBHrQO5)TM28)wNB918SKgF18GXSuymNDWAvIAEuzOm60qqtB(FR)T(AEwsJVAE59fQi5NcHAEuzOm60qqtB(FtkT(AEuzOm60qqZZsA8vZlVVqDcDdOPMxYVeJCQTWiv08)wtB(FRFA918SKgF18G8B5(SRxukTnpQmugDAiOPn)V1rA918SKgF18Snzf50FxQ0MhvgkJone00M280nkOjv06R5)TwFnpQmugDAiO5DirAJln(Q513gf0KkAELbNAErjslUAOmYjDWTsXH7oe2irnV0gkTH186EaQXOs5Olzke3NDIOoRb7fgNkdLrNbiFaO45m)kymBDF2L3xOC8RbiFaO45mNGF99O1T4f56r21xC8RbirYauJrLYrxYuiUp7erDwd2lmovgkJodq(aqCaioau8CMFfmMTUp7Y7luo(1aKpG0)SZ3R4Olzke3NDIOoRb7fgFj743aqAasKmaehakEoZVcgZw3ND59fkh)AaYhaIdaXbKdyqu3sWTOedq6EaP)zNVxXrxYuiUp7erDwd2lm(sWTOedaPba1bG5TbG0aqAainajsga6ledq(aYbmiQBj4wuIba1bG5TbirYaoKPqCqxbmik)ecdLrUq6CCK0OeUsdq2aK6aKpa1wyKY1ao503DLuhMsDaqDasP5zjn(Q5fLiT4QHYiN0b3kfhU7qyJe10M)y26R5rLHYOtdbnVYGtnpygwI5(StHqUCSc1zlAO028SKgF18GzyjM7Zofc5YXkuNTOHsBtB(35wFnpQmugDAiO5vgCQ5js2kCF2LxtPTmMtOBKPMNL04RMNizRW9zxEnL2YyoHUrMAAZ)(36R5rLHYOtdbnplPXxnpfc5YXkuNiGfSMxAdL2WAEO45m)kymBDF2L3xOC8RbiFaO45mNGF99O1T4f56r21xC8RMxzWPMNcHC5yfQteWcwtB(lLwFnpQmugDAiO5zjn(Q5PBuqt6TM3HePnU04RMxFqObOBuqt6a6fkKbOqObajGbHe6aiHgWnLodaRXWjFgqVGXgaknaCbDgqowHoaRod4YILodOxOqgagFWy2oGppam29fkV5L2qPnSMx3daRTHHYiU4IsroOJt3OGM0biFaO45m)kymBDF2L3xOC8RbiFaioGUhGAmQuEKOKDXPYqz0zasKma1yuP8irj7ItLHYOZaKpau8CMFfmMTUp7Y7lu(sWTOedOlzd4Muhasdq(aqCaDpaDJcAs5kMCiMWL(ND(E1aKiza6gf0KYvm5P)zNVxXxcUfLyasKmaS2ggkJ46gf0K6U243q9BaYgWTbG0aKiza6gf0KY1BCu8C2DWxtJVgqxYgqoGbrDlb3Is00M)9tRVMhvgkJone08sBO0gwZR7bG12WqzexCrPih0XPBuqt6aKpau8CMFfmMTUp7Y7luo(1aKpaehq3dqngvkpsuYU4uzOm6majsgGAmQuEKOKDXPYqz0zaYhakEoZVcgZw3ND59fkFj4wuIb0LSbCtQdaPbiFaioGUhGUrbnPC9ghIjCP)zNVxnajsgGUrbnPC9gp9p789k(sWTOedqIKbG12Wqzex3OGMu31g)gQFdq2aWCainajsgGUrbnPCftokEo7o4RPXxdOlzdihWGOULGBrjAEwsJVAE6gf0KIztB(3rA918OYqz0PHGMNL04RMNUrbnP3AEc2RnpDJcAsV18sBO0gwZR7bG12WqzexCrPih0XPBuqt6aKpaehq3dq3OGMuUEJdXeoCb5qXZ5biFaioaDJcAs5kM80)SZ3R4lb3Ismajsgq3dq3OGMuUIjhIjC4cYHINZdaPbirYas)ZoFVIFfmMTUp7Y7lu(sWTOedORbGPuhasnVdjsBCPXxnpPFEaFX8BaFrd4RbGlObOBuqt6aU2hBCiXaSbGINZ(maCbnafcnGxHq7a(AaP)zNVxXhagZoGipGIcfcTdq3OGM0bCTp24qIbydafpN9za4cAaOVczaFnG0)SZ3R4nT5pgT1xZJkdLrNgcAEwsJVAE6gf0KIzZlTHsBynVUhawBddLrCXfLICqhNUrbnPdq(aqCaDpaDJcAs5kMCiMWHlihkEopa5daXbOBuqtkxVXt)ZoFVIVeClkXaKizaDpaDJcAs56noet4WfKdfpNhasdqIKbK(ND(Ef)kymBDF2L3xO8LGBrjgqxdatPoaKAEc2RnpDJcAsXSPnT5LESuzLkA918)wRVMhvgkJone08SKgF18oKPqeUdo18oKiTXLgF1881JLkR0b0XqdwObjAEPnuAdR5H4a6EaQXOs5pkluAnn(ItLHYOZaKizaQXOs5pkluAnn(ItLHYOZaKpalPbwYrfbpiXa6s2aWCaYhq6F257v8RGXS19zxEFHYxcUfLyasKmalPbwYrfbpiXaKnGBdaPbiFaioaS2ggkJ4c1DXSQIc2aKizayTnmugXTZr4wcUf1aqQPn)XS1xZJkdLrNgcAEPnuAdR5T4vKCxFpA5hkhPqhqxd4wNhG8bK(ND(Ef)kymBDF2L3xO8LGBrjgauhqNhG8b09auJrLYrxYuiUp7erDwd2lmovgkJodq(aWAByOmIlu3fZQkkynplPXxnprpBHhfmh8qOnT5FNB918OYqz0PHGMxAdL2WAEDpa1yuPC0LmfI7ZoruN1G9cJtLHYOZaKpaS2ggkJ425iClb3IQ5zjn(Q5j6zl8OG5GhcTPn)7FRVMhvgkJone08sBO0gwZtngvkhDjtH4(Ste1znyVW4uzOm6ma5daXbGINZC0LmfI7ZoruN1G9cJJFna5daXbG12WqzexOUlMvvuWgG8bS4vKCxFpA5hkhPqhqxdO)sDasKmaS2ggkJ425iClb3IAaYhWIxrYD99OLFOCKcDaDnG(rQdqIKbG12Wqze3ohHBj4wudq(awlooclvk3ohbFj4wuIba1bGrma5dyT44iSuPC7CeCsAHqfdaPbirYa6EaO45mhDjtH4(Ste1znyVW44xdq(as)ZoFVIJUKPqCF2jI6SgSxy8LGBrjgasnplPXxnprpBHhfmh8qOnT5VuA918OYqz0PHGMxAdL2WAEP)zNVxXVcgZw3ND59fkFj4wuIba1balDgGVnamhG8bG12WqzexOUlMvvuWgG8bG4auJrLYrxYuiUp7erDwd2lmovgkJodq(aw8ksURVhTdORb0pszaYhq6F257vC0LmfI7ZoruN1G9cJVeClkXaG6aWCasKmGUhGAmQuo6sMcX9zNiQZAWEHXPYqz0zai18SKgF18m0hEuMgF5ybC0M28VFA918OYqz0PHGMxAdL2WAEyTnmugXTZr4wcUfvZZsA8vZZqF4rzA8LJfWrBAZ)osRVMhvgkJone08sBO0gwZdRTHHYiUqDxmRQOGna5daXbK(ND(Ef)kymBDF2L3xO8LGBrjgauhqNhGejdqngvkpsuYU4uzOm6maKAEwsJVAEciwcAg5uiKdV69RcXVM28hJ26R5rLHYOtdbnV0gkTH18WAByOmIBNJWTeClQMNL04RMNaILGMrofc5WRE)Qq8RPn)XiA918OYqz0PHGMxAdL2WAEDpau8CMFfmMTUp7Y7luo(1aKpaehG4XzOrD4x4cfNroAXV04lovgkJodqIKbiECgAuho2NzAWiN4zyPs5uzOm6ma5dO7bGINZCSpZ0GroXZWsLYXVgasnVOuAx8l1f5MN4XzOrD4yFMPbJCINHLkT5fLs7IFPUaoC6eMsnVBnplPXxnVmJeqsRL1MxukTl(L6GXEuJ18U10M28wlfgt06R5)TwFnpQmugDAiO5zjn(Q5HY()4Y4RFnVdjsBCPXxnVoULcJnGogAWcnirZlTHsBynpu8CMFfmMTUp7Y7luo(vtB(JzRVMhvgkJone08sBO0gwZdfpN5xbJzR7ZU8(cLJF18SKgF18qPvql0rbRPn)7CRVMhvgkJone08sBO0gwZdXb09aqXZz(vWy26(SlVVq54xdq(aSKgyjhve8GedOlzdaZbG0aKizaDpau8CMFfmMTUp7Y7luo(1aKpaehWIxe)q5if6a6s2aKYaKpGfVIK767rl)q5if6a6s2a6hPoaKAEwsJVAE2MSICx4mb10M)9V1xZJkdLrNgcAEPnuAdR5HINZ8RGXS19zxEFHYXVAEwsJVAESagev46Og)adovAtB(lLwFnpQmugDAiO5L2qPnSMhkEoZVcgZw3ND59fkh)AaYhakEoZj4xFpADlErUEKD9fh)Q5zjn(Q5zvIe6AmxYySM28VFA918OYqz0PHGMxAdL2WAEO45m)kymBDF2L3xO8LGBrjgauLnam6aKpau8CMFfmMTUp7Y7luo(1aKpau8CMtWV(E06w8IC9i76lo(vZZsA8vZlhlHY()00M)DKwFnpQmugDAiO5L2qPnSMhkEoZVcgZw3ND59fkh)AaYhGL0al5OIGhKyaYgWTbiFaioau8CMFfmMTUp7Y7lu(sWTOedaQdqkdq(auJrLYtp74Gq2QCQmugDgGejdO7bOgJkLNE2XbHSv5uzOm6ma5dafpN5xbJzR7ZU8(cLVeClkXaG6a68aqQ5zjn(Q5HAWCF2PBKGw00M20MhwAfXxn)XuQyIPuLYT(386zBffmrZt6QJ1X9x67FhDhgWa6dcnGa(1V6aY)oG7pkluAnn(YD9plky3hWssh8yPZaepCAagU(WnLodibXkyKGpi3POObGzhgGV(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9by6aW4Wy60aq8M0qIpipilD1X64(l99VJUddya9bHgqa)6xDa5FhW90ZooiKT69bSK0bpw6maXdNgGHRpCtPZasqScgj4dYDkkAa36Wa81xyPvPZaUV4fL)fgXXW9bO)aUV4fL)fgXXaNkdLrN7daX(lnK4dYDkkAay2Hb4RVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiEtAiXhK7uu0a6ChgGV(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG4nPHeFqUtrrdO)Dya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haI3Kgs8b5offnaP0Hb4RVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiEtAiXhKhKLU6yDC)L((3r3HbmG(GqdiGF9RoG8Vd4(JYcLwtJVUpGLKo4XsNbiE40amC9HBkDgqcIvWibFqUtrrdaZomaF9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7daXBsdj(GCNIIgaMDya(6lS0Q0za3tFDWdLJH7dq)bCp91bpuog4uzOm6CFaiEtAiXhK7uu0aUj1omaF9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7darmLgs8b5bzPRowh3FPV)D0DyadOpi0ac4x)Qdi)7aUJ(cNgjOJc29bSK0bpw6maXdNgGHRpCtPZasqScgj4dYDkkAa36Wa81xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaeVjnK4dYDkkAay2Hb4RVWsRsNb4fW91ae(vQjTbi9gG(dOt42aob2qeFnG)Iwt)DaiIqKgaI3Kgs8b5offnGo3Hb4RVWsRsNb4fW91ae(vQjTbi9gG(dOt42aob2qeFnG)Iwt)DaiIqKgaI3Kgs8b5offnG(3Hb4RVWsRsNb4fW91ae(vQjTbi9gG(dOt42aob2qeFnG)Iwt)DaiIqKgaI3Kgs8b5offnG(3Hb4RVWsRsNbCFXlk)lmIJH7dq)bCFXlk)lmIJbovgkJo3haI3Kgs8b5bzPRowh3FPV)D0DyadOpi0ac4x)Qdi)7aUNESuzLkUpGLKo4XsNbiE40amC9HBkDgqcIvWibFqUtrrd4whgGV(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bGiMsdj(GCNIIgaMDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haI3Kgs8b5offnGo3Hb4RVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiEtAiXhK7uu0a6FhgGV(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG4nPHeFqUtrrdqkDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haIyknK4dYDkkAaDKomaF9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7daXBsdj(GCNIIgagrhgGV(clTkDgWDXJZqJ6WXW9bO)aUlECgAuhog4uzOm6CFaiIP0qIpipilD1X64(l99VJUddya9bHgqa)6xDa5FhWDHA1X2Z9bSK0bpw6maXdNgGHRpCtPZasqScgj4dYDkkAa9thgGV(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9by6aW4Wy60aq8M0qIpi3POObGr7Wa81xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaeVjnK4dYDkkAayeDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haIDwAiXhKhKLU6yDC)L((3r3HbmG(GqdiGF9RoG8Vd4o6lCx)ZIc29bSK0bpw6maXdNgGHRpCtPZasqScgj4dYDkkAa9VddWxFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq8M0qIpi3POObiLomaF9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7daXBsdj(G8GS0vhRJ7V03)o6omGb0heAab8RF1bK)Da3Vwk9Wrn9(aws6GhlDgG4HtdWW1hUP0zajiwbJe8b5offnGBDya(6lS0Q0zaEbCFnaHFLAsBaspP3a0FaDc3ga8)GZWfd4VO10FhaIspKgaIyknK4dYDkkAa36Wa81xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpae7S0qIpi3POObCRddWxFHLwLod4UUrbnP8BCmCFa6pG76gf0KY1BCmCFai2zPHeFqUtrrdaZomaF9fwAv6maVaUVgGWVsnPnaPN0Ba6pGoHBda(FWz4Ib8x0A6VdarPhsdarmLgs8b5offnam7Wa81xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpae7S0qIpi3POObGzhgGV(clTkDgWDDJcAs5yYXW9bO)aURBuqtkxXKJH7daXolnK4dYDkkAaDUddWxFHLwLodWlG7Rbi8RutAdq6na9hqNWTbCcSHi(Aa)fTM(7aqeHinaeXuAiXhK7uu0a6ChgGV(clTkDgWDDJcAs534y4(a0Fa31nkOjLR34y4(aqS)sdj(GCNIIgqN7Wa81xyPvPZaURBuqtkhtogUpa9hWDDJcAs5kMCmCFaikfPHeFqUtrrdO)Dya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haI3Kgs8b5offnG(3Hb4RVWsRsNbCFXlk)lmIJH7dq)bCFXlk)lmIJbovgkJo3hGPdaJdJPtdaXBsdj(GCNIIgq)7Wa81xyPvPZaUN(6Ghkhd3hG(d4E6RdEOCmWPYqz05(aq8M0qIpipilD1X64(l99VJUddya9bHgqa)6xDa5FhW90)SZ3Re3hWssh8yPZaepCAagU(WnLodibXkyKGpi3POObGzhgGV(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG4nPHeFqUtrrdaZomaF9fwAv6mG7IhNHg1HJH7dq)bCx84m0OoCmWPYqz05(aqetPHeFqUtrrdOZDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haI3Kgs8b5offnGo3Hb4RVWsRsNbCFXlk)lmIJH7dq)bCFXlk)lmIJbovgkJo3haI3Kgs8b5offnG(3Hb4RVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaMoamomMonaeVjnK4dYDkkAasPddWxFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aq8M0qIpi3POOb0pDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haI3Kgs8b5offnGoshgGV(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG4nPHeFqUtrrdOJ0Hb4RVWsRsNbCFXlk)lmIJH7dq)bCFXlk)lmIJbovgkJo3haI3Kgs8b5offnamIomaF9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7daXBsdj(GCNIIgWTBDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haI3Kgs8b5offnGBy2Hb4RVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiIP0qIpi3POObCtkDya(6lS0Q0za3x8IY)cJ4y4(a0Fa3x8IY)cJ4yGtLHYOZ9by6aW4Wy60aq8M0qIpipilD1X64(l99VJUddya9bHgqa)6xDa5FhWDDJcAsf3hWssh8yPZaepCAagU(WnLodibXkyKGpi3POObCRddWxFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aqetPHeFqUtrrdqkDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haIyknK4dYDkkAasPddWxFHLwLod4UUrbnP8BCmCFa6pG76gf0KY1BCmCFaiEtAiXhK7uu0aKshgGV(clTkDgWDDJcAs5yYXW9bO)aURBuqtkxXKJH7darmLgs8b5offnG(PddWxFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(aqetPHeFqUtrrdOF6Wa81xyPvPZaURBuqtk)ghd3hG(d4UUrbnPC9ghd3haIyknK4dYDkkAa9thgGV(clTkDgWDDJcAs5yYXW9bO)aURBuqtkxXKJH7daXBsdj(GCNIIgqhPddWxFHLwLod4UUrbnP8BCmCFa6pG76gf0KY1BCmCFaiEtAiXhK7uu0a6iDya(6lS0Q0za31nkOjLJjhd3hG(d4UUrbnPCftogUpaeXuAiXhK7uu0aWODya(6lS0Q0za31nkOjLFJJH7dq)bCx3OGMuUEJJH7darmLgs8b5offnamAhgGV(clTkDgWDDJcAs5yYXW9bO)aURBuqtkxXKJH7daXBsdj(G8GS0vhRJ7V03)o6omGb0heAab8RF1bK)Da3pu2Wz69bSK0bpw6maXdNgGHRpCtPZasqScgj4dYDkkAasPddWxFHLwLod4(Ixu(xyehd3hG(d4(Ixu(xyehdCQmugDUpaeXuAiXhK7uu0a6NomaF9fwAv6mG7PVo4HYXW9bO)aUN(6GhkhdCQmugDUpaeVjnK4dYDkkAay0omaF9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7daXolnK4dYDkkAayeDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haIDwAiXhK7uu0aUj1omaF9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7daX(lnK4dYDkkAa3U1Hb4RVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFai2FPHeFqUtrrd4gMDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haIyknK4dYDkkAa36iDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haIyknK4dYDkkAa3Wi6Wa81xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpaeVjnK4dYDkkAayk1omaF9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7dW0bGXHX0PbG4nPHeFqUtrrdaZBDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haI3Kgs8b5offnamV1Hb4RVWsRsNbCFXlk)lmIJH7dq)bCFXlk)lmIJbovgkJo3haI3Kgs8b5bzPRowh3FPV)D0DyadOpi0ac4x)Qdi)7aUBpDFaljDWJLodq8WPby46d3u6mGeeRGrc(GCNIIgaMDya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3hGPdaJdJPtdaXBsdj(GCNIIgq)7Wa81xyPvPZaURgJkLJH7dq)bCxngvkhdCQmugDUpathaghgtNgaI3Kgs8b5offnG(PddWxFHLwLod4UAmQuogUpa9hWD1yuPCmWPYqz05(amDayCymDAaiEtAiXhK7uu0aWODya(6lS0Q0za3vJrLYXW9bO)aURgJkLJbovgkJo3haI3Kgs8b5offnamIomaF9fwAv6mG7QXOs5y4(a0Fa3vJrLYXaNkdLrN7daXBsdj(GCNIIgWnP2Hb4RVWsRsNbCxngvkhd3hG(d4UAmQuog4uzOm6CFaiEtAiXhK7uu0aUHzhgGV(clTkDgWD1yuPCmCFa6pG7QXOs5yGtLHYOZ9bG4nPHeFqEqw6d)6xLod4wNhGL04RbWcHk4dYnpXfLA(JPuU18U2phmQ51V97a6OqMczaDuvbmi6aWy3xOdY9B)oamsB(nam7SpdatPIjMdYdY9B)oaFbXkyKyqUF73biDpGoob)XsNbWmHkDlO0xNbGlmy0a(8a8felkXa(8aK(jAaMyaHoGZtI6UoGlM53a6rm2aIAaxRL0ir8b5(TFhG09a6O81DDajiwveBaySmsajTwwhWbFJc2aqWsMczaFEaErDwd2lm(G8GC)oamoSgd3usmaBa6gf0Kkgq6F257v(mGtGno0zaO(nGRGXSDaFEa59f6a(DaOlzkKb85biI6SgSxy3fdi9p789k(aK(5be6DXaWAmCAaqmXaQFalb3I6q7awsX3Aa38zaetqdyjfFRbivUu4dYwsJVe8RLspCutHImeI12WqzKpLbNKPBuqtQ7Mt4xL85VKjinY(G1y4KSB(G1y4KJycsMu5sXN0xNqJVKPBuqtk)ghIjC4cYHINZYrSB1yuPC0LmfI7ZoruN1G9ctoI6gf0KYVXt)ZoFVIFWxtJVKEsV0)SZ3R4xbJzR7ZU8(cLFWxtJVKjvKKirngvkhDjtH4(Ste1znyVWKJy6F257vC0LmfI7ZoruN1G9cJFWxtJVKEspe1nkOjLFJN(ND(Ef)GVMgF1fg5BijtQijrIAmQuEKOKDH0GSL04lb)AP0dh1uOidHyTnmug5tzWjz6gf0K6W0j8Rs(8xYeKgzFWAmCs2nFWAmCYrmbjtQCP4t6RtOXxY0nkOjLJjhIjC4cYHINZYrSB1yuPC0LmfI7ZoruN1G9ctoI6gf0KYXKN(ND(Ef)GVMgFj9KEP)zNVxXVcgZw3ND59fk)GVMgFjtQijrIAmQuo6sMcX9zNiQZAWEHjhX0)SZ3R4Olzke3NDIOoRb7fg)GVMgFj9KEiQBuqtkhtE6F257v8d(AA8vxyKVHKmPIKejQXOs5rIs2fsdY97aW4eAa3usmaBa6gf0KkgawJHtda1VbKE4x2gfSbOqObK(ND(E1a(8aui0a0nkOj1NbCcSXHoda1VbOqObCWxtJVgWNhGcHgakEopGqhW1(yJdj4daJetmaBacDPcMczaW)tKdAhG(dawGLgGnaibmi0oGRn(nu)gG(dqOlvWuidq3OGMuHpdWedOhXydWedWga8)e5G2bK)DarEa2a0nkOjDa9cgBa)oGEbJnG61bi8RsdOxOqgq6F257vc(GSL04lb)AP0dh1uOidHyTnmug5tzWjz6gf0K6U243q9ZN)sMG0i7dwJHtYW0hSgdNCetqYU5t6RtOXxY6w3OGMu(noet4WfKdfpNLRBuqtkhtoet4WfKdfpNLir3OGMuoMCiMWHlihkEolhre1nkOjLJjp9p789k(bFnn(s6HOUrbnPCm5O45S7GVMgF1fgzPYL6nKqY3q8gxkqr3OGMuoMCiMWHINZCHUubtHGKVHiwBddLrCDJcAsDy6e(vjKqQleru3OGMu(nE6F257v8d(AA8L0drDJcAs534O45S7GVMgF1fgzPYL6nKqY3q8gxkqr3OGMu(noet4qXZzUqxQGPqqY3qeRTHHYiUUrbnPUBoHFvcjKgKTKgFj4xlLE4OMcfzieRTHHYiFkdojB75qXZzHpyngojtngvkhMPqOnkyoH(lCjssFDWdLtyPnVVqLizXlk)lmIJgAuWCPNDgKTKgFj4xlLE4OMcfzimZibK0AzDqEqUF73bGXjnkHR0zaewA9BaAaNgGcHgGL0FhqigGH1cMHYi(GSL04lHm4rDC5LiFNgK73bGXVewQ0biUOuKd6maDJcAsfdaLIc2aWf0za9cfYamC9HBAKgalksmiBjn(safzieRTHHYiFkdojtCrPih0XPBuqtQpyngojdrs6Ghxx0HhLiT4QHYiN0b3kfhU7qyJejrcjDWJRl6WviKlhRqDIawWqsoIP)zNVxXJsKwC1qzKt6GBLId3DiSrI4lzh)Kij9p789kUcHC5yfQteWcgFj4wucKKiHKo4X1fD4keYLJvOoralyYjPdECDrhEuI0IRgkJCshCRuC4UdHns0GSL04lbuKHqS2ggkJ8Pm4KmH6UywvrbZhSgdNKzjnWsoQi4bjKDtoIRfhhHLkLBNJGhvx3KIejDVwCCewQuUDocojTqOcKgKTKgFjGImeI12WqzKpLbNKzNJWTeClkFWAmCsML0al5OIGhKOlzykhXUxlooclvk3ohbNKwiuHejRfhhHLkLBNJGtsleQqoIRfhhHLkLBNJGVeClkrxsrIKCadI6wcUfLORBsfjKgKTKgFjGImeI12WqzKpLbNKTVMtUnGt(G1y4Kmu8CMVbCIJFjhXUx8IY)cJ4RbJCF2PqixEFFNkxcIb)k(sIKfVO8VWi(AWi3NDkeYL333PYLGyWVIVKV4vKCxFpA5hkhPq7cJI0GSL04lbuKHqS2ggkJ8Pm4KS8(c1j0nGMCPVo4Hk8bRXWjzPVo4HYP1orY0OG5qzFp5O45mNw7ejtJcMdL994c1sqldtjssFDWdLJxmYeqOJlVu57(jhfpN54fJmbe64Ylv(UF8LGBrjGkIWshFdtKgKTKgFjGImeI12WqzKpLbNKDitHiChCYzjnWs(G1y4KSdzkeNvh3HsMFCnsqhfm5PhlvwP8kGbrDzJgK73b0XUUy(nam29f6aWyjS06ZaGBrPwudq6N8Ba9zSVedWQZaGMORb0Xj4)kigjedq6kkL2bSpJffSbzlPXxcOidHlb)xbXiHW1lkLwFISS0xh8q5ewAZ7lu5QXOs5WmfcTrbZj0FHlhXUvJrLYFuwO0AA8L80)SZ3R4xbJzR7ZU8(cLVeClkHejcsDOFHl4AqlMyux)VsYvJrLYFuwO0AA8L8UrXZz(vWy26(SlVVq54xiniBjn(safzieY3JffmhkZeQpj)smYP2cJuHSB(ezzDFELN3xOUmHLw(sWTOeYrungvkpsuYUKiPBu8CMJUKPqCF2jI6SgSxyC8l5QXOs5Olzke3NDIOoRb7fMejQXOs5pkluAnn(sE6F257v8RGXS19zxEFHYxcUfLqE3O45mh6GXIcMdULGefXXVqAq2sA8LakYqimMLcJ5SdwRsKprwgkEoZJKFo1yFj4lb3IsavzWshFdt5QXOs5rYpNASVeYfxeJ5uBHrQGdJzPWyo7G1Qe1LmmLJOAmQuEKOKDjrIAmQuo6sMcX9zNiQZAWEHjp9p789ko6sMcX9zNiQZAWEHXxcUfLORBsrIe1yuP8hLfkTMgFjVBu8CMFfmMTUp7Y7luo(fsdYwsJVeqrgcZ7luNq3aAYNildfpN5rYpNASVe8LGBrjGQmyPJVHPC1yuP8i5Ntn2xc5iQgJkLhjkzxsKOgJkLJUKPqCF2jI6SgSxyY7gfpN5Olzke3NDIOoRb7fgh)sE6F257vC0LmfI7ZoruN1G9cJVeClkrx3KQejQXOs5pkluAnn(sE3O45m)kymBDF2L3xOC8lKgKTKgFjGIme(OSqP1uYNill9yPYkLxbmiQlBK8dzkeNvh3HsMFCnsqhfm5hYuioRoUdLm)4wsdSKBj4wucOIiS0X3UXLcsYrSB1yuP8hLfkTMgFjrIAmQu(JYcLwtJVK3nkEoZVcgZw3ND59fkh)cPb5(Da(cY)cAaDSKgFnawi0bO)aw8Aq2sA8LakYqyYymNL04lhleQpLbNKLESuzLkgKTKgFjGImeMmgZzjn(YXcH6tzWjzRLcJjgKTKgFjGImeMmgZzjn(YXcH6tzWjz6gf0KkgKTKgFjGImeMmgZzjn(YXcH6tzWjzP)zNVxjgKTKgFjGImeMmgZzjn(YXcH6tzWjzPNDCqiBvFe6gjv2nFISm1yuP80ZooiKTQCe7gfpN5qhmwuWCWTeKOio(LejQXOs5Olzke3NDIOoRb7fgsYr8qO45mFnF)3irCHAjOLjfjs6(qMcXbDfWGO8fVO8VWi(A((VrIqAq2sA8LakYq4IxolPXxowiuFkdojd9fonsqhfmFe6gjv2nFISmu8CMJUKPqCF2jI6SgSxyC8RbzlPXxcOidHlE5SKgF5yHq9Pm4Km0x4U(NffmFISm1yuPC0LmfI7ZoruN1G9ctE3O45mhDjtH4(Ste1znyVW44xYrm9p789ko6sMcX9zNiQZAWEHXxcUfLaQ3KksYrCT44iSuPC7Ce8O6ctPirs3RfhhHLkLBNJGtsleQqIK0)SZ3R4xbJzR7ZU8(cLVeClkbuVjv5RfhhHLkLBNJGtsleQq(AXXryPs525i4rb1BsfPbzlPXxcOidHlE5SKgF5yHq9Pm4KShLfkTMgF5Jq3iPYU5tKLHINZ8RGXS19zxEFHYXVKRgJkL)OSqP104RbzlPXxcOidHlE5SKgF5yHq9Pm4KShLfkTMgF5U(NffmFISSUfK6q)cxW1GwmXOU(FLK39Ixu(xyeFnyK7Zofc5Y777u5sqm4xXxYvJrLYFuwO0AA8L80)SZ3R4xbJzR7ZU8(cLVeClkbuVjv5iI12WqzexOUlMvvuWKizT44iSuPC7CeCsAHqfYxlooclvk3ohbpkOEtQsK09AXXryPs525i4K0cHkqAq2sA8LakYq4IxolPXxowiuFkdojZEYhHUrsLDZNilZsAGLCurWds0LmmhKTKgFjGImeMmgZzjn(YXcH6tzWjzc1QJTNb5b5(DaDShJBaD8xnn(Aq2sA8LGBpjBj4)kigjeUErP0oiBjn(sWTNGImecJzPWyo7G1Qe5tKLPgJkLN3xOIKFkeAq2sA8LGBpbfzimVVqfj)uiKprwgkEoZHoySOG5GBjirr8LSKkVBS2ggkJ4hYuic3bNCwsdS0GSL04lb3EckYqiKVhlkyouMjuFISmS2ggkJ47R5KBd4KC1yuPCdRXSkbHgKTKgFj42tqrgcHXSuymNDWAvI8jYY6gfpN5BaN44xYTKgyjhve8GeqvwNLiXsAGLCurWds0vNhK73bGX(lCCMfPbyxx7Bjidq)bKwYuAa2aUee(5hW1g)gQFdqTfgPdGfcDa5FhGDDX8lkydynF)3irdiQbypniBjn(sWTNGImeM3xOoHUb0Kpj)smYP2cJuHSB(ezzP)zNVxXxc(VcIrcHRxukT8LGBrjGQmm9nyPJC1yuPCyMcH2OG5e6VWhKTKgFj42tqrgcH89yrbZHYmH6tKLH12WqzeFFnNCBaNgKTKgFj42tqrgcZ7lurYpfc5tKLPgJkLdZui0gfmNq)fUCu8CMVe8FfeJecxVOuA54xYTKgyjhve8GeDHP8UXAByOmIFitHiChCYzjnWsdYwsJVeC7jOidHpkluAnL8jYYWAByOmIFitHiChCYzjnWsYrXZz(HmfIWDWjUqTe0qT)sKOgJkLdZui0gfmNq)fUCu8CMVe8FfeJecxVOuA54xdYwsJVeC7jOidH59fQtOBan5tYVeJCQTWivi7Mprw2IxrYD99OLFOCKcfQiEtkqrngvkFXRi5mvPc304lFtkiniBjn(sWTNGImeM3xOIKFkeYNilRBS2ggkJ4hYuic3bNCwsdS0GSL04lb3EckYq4JYcLwtjFs(LyKtTfgPcz38jYYw8ksURVhT8dLJuODHiMsbkQXOs5lEfjNPkv4MgF5BsbPbzlPXxcU9euKHqymlfgZzhSwLObzlPXxcU9euKHW8(cvK8tHqdYwsJVeC7jOidH59fQtOBan5tYVeJCQTWivi72GSL04lb3EckYqiKFl3ND9IsPDq2sA8LGBpbfzi02KvKt)DPshKhK73bGGLmfYa(8a8I6SgSxyd46FwuWgW(QPXxdOddqO2QIbCtQIbGs5FPbGG3BaHyagwlygkJgKTKgFj4OVWD9plkyYwc(VcIrcHRxukT(ezzwsdSKJkcEqIUKHPejyTnmugX3Eou8CwmiBjn(sWrFH76FwuWGIme(OSqP1uYNKFjg5uBHrQq2nFISmu8CMdDWyrbZb3sqII4lzjvE6F257v8RGXS19zxEFHYxcUfLORopiBjn(sWrFH76FwuWGImec57XIcMdLzc1NildRTHHYi((Ao52aoniBjn(sWrFH76FwuWGImeM3xOIKFkeYNildfpN5qhmwuWCWTeKOi(swsLV4vKCxFpA5hkhPq7cXBsbkQXOs5lEfjNPkv4MgF5Bsbj5IlIXCQTWivWZ7lurYpfc1fMY7gRTHHYi(HmfIWDWjNL0alniBjn(sWrFH76FwuWGImeM3xOIKFkeYNilBXRi5U(E0YpuosH2Lme7SuGIAmQu(IxrYzQsfUPXx(MuqsU4IymNAlmsf88(cvK8tHqDHP8UXAByOmIFitHiChCYzjnWsdY9B)oG7QTWi1fzzWnP1bepekEoZxZ3)nsexOwcAOCdjPhIhcfpN5R57)gjIVeClkbuUHKVDitH4GUcyqu(Ixu(xyeFnF)3ir3hqhNUitfdWga7vFgGcjediedikLQdDgG(dqTfgPdqHqdasadcj0bCTXVH63aOIG73a6fkKby1am0GfQFdqHy6a6fm2aSRlMFdynF)3irdiYdyXlk)lm6WhqFqmDaOuuWgGvdGkcUFdOxOqgGuhGqTe0cFgWVdWQbqfb3VbOqmDakeAahcfpNhqVGXgG4)AaK0UILgWx8bzlPXxco6lCx)ZIcguKHWhLfkTMs(K8lXiNAlmsfYU5tKLT4vKCxFpA5hkhPq7sgMszq2sA8LGJ(c31)SOGbfziegZsHXC2bRvjYNilBXRi5U(E0YpuosHcvmLQCXfXyo1wyKk4WywkmMZoyTkrDjdt5P)zNVxXVcgZw3ND59fkFj4wuIUKYGSL04lbh9fUR)zrbdkYqyEFH6e6gqt(K8lXiNAlmsfYU5tKLT4vKCxFpA5hkhPqHkMsvE6F257v8RGXS19zxEFHYxcUfLOlPmiBjn(sWrFH76FwuWGImecJzPWyo7G1Qe5tKLL(ND(Ef)kymBDF2L3xO8LGBrj6AXlIRbCYPVR)Yx8ksURVhT8dLJuOqT)svU4IymNAlmsfCymlfgZzhSwLOUKH5GSL04lbh9fUR)zrbdkYqyEFH6e6gqt(K8lXiNAlmsfYU5tKLL(ND(Ef)kymBDF2L3xO8LGBrj6AXlIRbCYPVR)Yx8ksURVhT8dLJuOqT)sDqEqUFhacwYuid4ZdWlQZAWEHnGowsdS0a64VAA81GSL04lbh9fonsqhfmzpkluAnL8j5xIro1wyKkKDZNilBXRi5U(E0cvzi2FPaf1yuP8fVIKZuLkCtJV8nPG0GSL04lbh9fonsqhfmOidHlb)xbXiHW1lkLwFISmS2ggkJ4BphkEolKiXsAGLCurWds0LmmLizXRi5U(E0c1oJP8fViUgWjN(omH6IxrYD99Ov6DRFgKTKgFj4OVWPrc6OGbfzi8qMcXz1XDOK5Nprw2IxrYD99OfQDgt5lErCnGto9Dyc1fVIK767rR07w)miBjn(sWrFHtJe0rbdkYqiKVhlkyouMjuFISmS2ggkJ47R5KBd4KCex8ksURVhTDjR)srIKfViUgWjN(UodvzWshjsw8IY)cJ4RbJCF2PqixEFFNkxcIb)k(sIeXfXyo1wyKk4q(ESOG5qzMq7sgMsKGINZ8nGt8LGBrjGANrsIKfVIK767rlu7mMYx8I4AaNC67WeQlEfj313JwP3T(zq2sA8LGJ(cNgjOJcguKHW8(cvK8tHq(ezzO45mh6GXIcMdULGefXXVKlUigZP2cJubpVVqfj)uiuxykVBS2ggkJ4hYuic3bNCwsdS0GSL04lbh9fonsqhfmOidHpkluAnL8j5xIro1wyKkKDZNildfpN5qhmwuWCWTeKOi(swshKTKgFj4OVWPrc6OGbfzieYVL7ZUErP06tKLT4vKCxFpAHQS(rQYx8I4AaNC676CxWsNbzlPXxco6lCAKGokyqrgcZ7lurYpfc5tKLjUigZP2cJubpVVqfj)uiuxykVBS2ggkJ4hYuic3bNCwsdS0GSL04lbh9fonsqhfmOidHpkluAnL8j5xIro1wyKkKDZNilBXRi5U(E0YpuosH2fMsrIKfViUgWjN(U(dvyPZGSL04lbh9fonsqhfmOidHq(ESOG5qzMq9jYYWAByOmIVVMtUnGtdYwsJVeC0x40ibDuWGImeABYkYP)UuP(ezzlEfj313JwOkfPoipipi3V97a81ZodaJeYwDa(6RtOXxIbzlPXxcE6zhheYwvwcIfLW9zxKiFISm0xiKNdyqu3sWTOeqfw6ihXfViOIPejDJINZCOdglkyo4wcsueh)soIDd3IYbXQdhtiYrXZzE6zhheYwLlulbDxY6puw8IY)cJ4q)mnwt4Yg2FLibUfLdIvhoMqKJINZ80ZooiKTkxOwc6UWOqzXlk)lmId9Z0ynHlBy)fjjsqXZzo0bJffmhClbjkIJFjhXUHBr5Gy1HJje5O45mp9SJdczRYfQLGUlmkuw8IY)cJ4q)mnwt4Yg2FLibUfLdIvhoMqKJINZ80ZooiKTkxOwc6UUjvOS4fL)fgXH(zASMWLnS)IesdY97aWiLGgWbFJc2aW4dgZ2b0luidq6NOKDHqeSKPqgKTKgFj4PNDCqiBvOidHjiwuc3NDrI8jYY6wngvk)rzHsRPXxYrXZz(vWy26(SlVVq54xYrXZzE6zhheYwLlulbDxYUjv5iIINZ8RGXS19zxEFHYxcUfLaQWshFdXBqj9p789kEEFH2ZVfUWLXx)4lzh)qsIeu8CMJxqEMFoHUubtHWxcUfLaQWshjsqXZzEcI9chQveFj4wucOclDqAqUFhagdUkIdnGppam(GXSDa4cYGrdOxOqgG0prj7cHiyjtHmiBjn(sWtp74Gq2QqrgctqSOeUp7Ie5tKL1TAmQu(JYcLwtJVKFitH4GUcyqu(Ixu(xyepBmgvU0IlSdTY7gfpN5xbJzR7ZU8(cLJFjp9p789k(vWy26(SlVVq5lb3Is01nPihru8CMNE2XbHSv5c1sq3LSBsvoIO45mhVG8m)CcDPcMcHJFjrckEoZtqSx4qTI44xijrckEoZtp74Gq2QCHAjO7s2ToJ0GSL04lbp9SJdczRcfzimbXIs4(SlsKprww3QXOs5pkluAnn(sE3hYuioORageLV4fL)fgXZgJrLlT4c7qRCu8CMNE2XbHSv5c1sq3LSBsvE3O45m)kymBDF2L3xOC8l5P)zNVxXVcgZw3ND59fkFj4wuIUWuQdY97aW4xclv6a81ZodaJeYwDapwAt21vuWgWbFJc2aUcgZ2bzlPXxcE6zhheYwfkYqycIfLW9zxKiFISm1yuP8hLfkTMgFjVBu8CMFfmMTUp7Y7luo(LCerXZzE6zhheYwLlulbDxYU1F5iIINZC8cYZ8Zj0Lkykeo(LejO45mpbXEHd1kIJFHKejO45mp9SJdczRYfQLGUlz3WiKij9p789k(vWy26(SlVVq5lb3Isa1olhfpN5PNDCqiBvUqTe0Dj7w)rAqEqUFhag)RXxdYwsJVe80)SZ3ReYUEn(YNildfpN5xbJzR7ZU8(cLJFni3VdWx)ZoFVsmiBjn(sWt)ZoFVsafziKGF99O1T4f56r21x(ezzQXOs5pkluAnn(s(Ixeu7h5iI12WqzexOUlMvvuWKibRTHHYiUDoc3sWTOqsoIP)zNVxXVcgZw3ND59fkFj4wucOkf5iM(ND(EfpZibK0AzLVeClkrxsrU4XzOrD4x4cfNroAXV04ljs6w84m0Oo8lCHIZihT4xA8fssKGINZ8RGXS19zxEFHYXVqsIe0xiKNdyqu3sWTOeqftPoiBjn(sWt)ZoFVsafziKGF99O1T4f56r21x(ezzQXOs5Olzke3NDIOoRb7fM8fViOkf5lEfj313JwOIy)ivPBepKPqCqxbmikFXlk)lmIdXpHsBy(Muqs6gXfVO8VWi(AWVSsD6ALitlvjY3Kcsijhru8CMJUKPqCF2jI6SgSxyC8ljsqFHqEoGbrDlb3IsavmLksdYwsJVe80)SZ3Reqrgcj4xFpADlErUEKD9LprwMAmQuEKOKDniBjn(sWt)ZoFVsafzi8kymBDF2L3xO(ezzQXOs5Olzke3NDIOoRb7fMCeXAByOmIlu3fZQkkysKG12Wqze3ohHBj4wuijhX0)SZ3R4Olzke3NDIOoRb7fgFj4wucjsqXZzo6sMcX9zNiQZAWEHXXVKV4vKCxFpA7Q)srIK0)SZ3R4Olzke3NDIOoRb7fgFj74N8fVIK767rBx9JuqAq2sA8LGN(ND(ELakYq4vWy26(SlVVq9jYYuJrLYJeLSl5DJINZ8RGXS19zxEFHYXVgKTKgFj4P)zNVxjGImeEfmMTUp7Y7luFISm1yuP8hLfkTMgFjhXfVIK767rBxY6SuK3nkEoZn0hEuMgF5ybCuo(LejO45m3qF4rzA8LJfWr54xsKS4fL)fgXxdg5(StHqU8((ovUeed(v8fsYreRTHHYiUqDxmRQOGjrcwBddLrC7CeULGBrHKCevJrLYHzkeAJcMtO)cNtLHYOJCu8CMVe8FfeJecxVOuA54xsK0TAmQuomtHqBuWCc9x4CQmugDqAq2sA8LGN(ND(ELakYqi6sMcX9zNiQZAWEH5tKL1nkEoZrxYuiUp7erDwd2lmo(L8fVIK767rBx9JuLJikEoZVcgZw3ND59fkh)sIK0)SZ3R4xbJzR7ZU8(cLVeClkrx3KcsdYwsJVe80)SZ3ReqrgcZ7l0E(TWfUm(6NprwML0al5OIGhKq2n5O45m)kymBDF2L3xO8LGBrjGkS0rokEoZVcgZw3ND59fkh)sE3QXOs5pkluAnn(soIDVwCCewQuUDocojTqOcjswlooclvk3ohbpQU6SursIKCadI6wcUfLaQDEq2sA8LGN(ND(ELakYqyEFH2ZVfUWLXx)8jYYSKgyjhve8GeDjdt5iIINZ8RGXS19zxEFHYXVKizT44iSuPC7CeCsAHqfYxlooclvk3ohbpQUs)ZoFVIFfmMTUp7Y7lu(sWTOeqPJGKCerXZz(vWy26(SlVVq5lb3IsavyPJejRfhhHLkLBNJGtsleQq(AXXryPs525i4lb3IsavyPdsdYwsJVe80)SZ3ReqrgcZ7l0E(TWfUm(6NprwMAmQu(JYcLwtJVKJikEoZVcgZw3ND59fkh)sE3WTOCqS6WXeIejDJINZ8RGXS19zxEFHYXVKd3IYbXQdhtiYt)ZoFVIFfmMTUp7Y7lu(sWTOeijhrerXZz(vWy26(SlVVq5lb3IsavyPJejO45mhVG8m)CcDPcMcHJFjhfpN54fKN5NtOlvWui8LGBrjGkS0bj5iEiu8CMVMV)BKiUqTe0YKIejDFitH4GUcyqu(Ixu(xyeFnF)3iriH0GSL04lbp9p789kbuKHqi(D9keAHhj31scQsKprwMAmQuo6sMcX9zNiQZAWEHjFXRi5U(E0c1(rQYx8IGQSolhru8CMJUKPqCF2jI6SgSxyC8ljss)ZoFVIJUKPqCF2jI6SgSxy8LGBrj6Q)sfjjs6wngvkhDjtH4(Ste1znyVWKV4vKCxFpAHQSoIugKTKgFj4P)zNVxjGImeUwii3HSJprww6F257v8RGXS19zxEFHYxcUfLaQYKYGSL04lbp9p789kbuKHqHL2ihPWyUllP(ezzwsdSKJkcEqIUKHPCeZbmiQBj4wucO2zjs6gfpN5Olzke3NDIOoRb7fgh)soIxKYHb5Xz8LGBrjGkS0rIK1IJJWsLYTZrWjPfcviFT44iSuPC7Ce8LGBrjGANLVwCCewQuUDocEuDDrkhgKhNXxcUfLajKgKTKgFj4P)zNVxjGImeEitH4S64ouY8ZNilZsAGLCurWds0LuKizXlk)lmIFbHS9H)fjgKhK73b4RhlvwPdOJHgSqdsmiBjn(sWtpwQSsfYoKPqeUdo5tKLHy3QXOs5pkluAnn(sIe1yuP8hLfkTMgFj3sAGLCurWds0LmmLN(ND(Ef)kymBDF2L3xO8LGBrjKiXsAGLCurWdsi7gsYreRTHHYiUqDxmRQOGjrcwBddLrC7CeULGBrH0GSL04lbp9yPYkvafziu0Zw4rbZbpeQprw2IxrYD99OLFOCKcTRBDwE6F257v8RGXS19zxEFHYxcUfLaQDwE3QXOs5Olzke3NDIOoRb7fMCS2ggkJ4c1DXSQIc2GSL04lbp9yPYkvafziu0Zw4rbZbpeQprww3QXOs5Olzke3NDIOoRb7fMCS2ggkJ425iClb3IAq2sA8LGNESuzLkGImek6zl8OG5Ghc1NiltngvkhDjtH4(Ste1znyVWKJikEoZrxYuiUp7erDwd2lmo(LCeXAByOmIlu3fZQkkyYx8ksURVhT8dLJuOD1FPkrcwBddLrC7CeULGBrjFXRi5U(E0YpuosH2v)ivjsWAByOmIBNJWTeClk5RfhhHLkLBNJGVeClkbuXiKVwCCewQuUDocojTqOcKKiPBu8CMJUKPqCF2jI6SgSxyC8l5P)zNVxXrxYuiUp7erDwd2lm(sWTOeiniBjn(sWtpwQSsfqrgcn0hEuMgF5ybCuFISS0)SZ3R4xbJzR7ZU8(cLVeClkbuHLo(gMYXAByOmIlu3fZQkkyYrungvkhDjtH4(Ste1znyVWKV4vKCxFpA7QFKI80)SZ3R4Olzke3NDIOoRb7fgFj4wucOIPejDRgJkLJUKPqCF2jI6SgSxyiniBjn(sWtpwQSsfqrgcn0hEuMgF5ybCuFISmS2ggkJ425iClb3IAq2sA8LGNESuzLkGImekGyjOzKtHqo8Q3Vke)8jYYWAByOmIlu3fZQkkyYrm9p789k(vWy26(SlVVq5lb3Isa1olrIAmQuEKOKDH0GSL04lbp9yPYkvafziuaXsqZiNcHC4vVFvi(5tKLH12Wqze3ohHBj4wudYwsJVe80JLkRubuKHWmJeqsRLvFISSUrXZz(vWy26(SlVVq54xYru84m0Oo8lCHIZihT4xA8LejIhNHg1HJ9zMgmYjEgwQu5DJINZCSpZ0GroXZWsLYXVqYNOuAx8l1fWHtNWus2nFIsPDXVuhm2JAmz38jkL2f)sDrwM4XzOrD4yFMPbJCINHLkDqEqUFhagdkluAnn(Aa7RMgFniBjn(sWFuwO0AA8LSLG)RGyKq46fLsRprwML0al5OIGhKOlzDwowBddLr8TNdfpNfdYwsJVe8hLfkTMgFbfzimVVqDcDdOjFISSUrXZzo0bJffmhClbjkIJFjhXfViOIPejQXOs5rYpNASVeYrXZzEK8ZPg7lbFj4wucOclD8nmLij91bpuoEXitaHoU8sLV7NCerXZzoEXitaHoU8sLV7hFj4wucOclD8nmLibfpN54fJmbe64Ylv(UFCHAjOHANrcPbzlPXxc(JYcLwtJVGImec57XIcMdLzc1NilRBu8CMdDWyrbZb3sqII44xYx8I6swNLJikEoZ3aoXxcUfLaQDwokEoZ3aoXXVKiXsAGLCNx559fQltyPfQwsdSKJkcEqcKgKTKgFj4pkluAnn(ckYqimMLcJ5SdwRsKprww3O45mh6GXIcMdULGefXXVKlUigZP2cJubhgZsHXC2bRvjQlzykrs3O45mh6GXIcMdULGefXXVKJ4HqXZz(A((VrI4c1sqdvPirYHqXZz(A((VrI4lb3IsavyPJV1FKgKTKgFj4pkluAnn(ckYqyEFHks(PqiFISmu8CMdDWyrbZb3sqII4lzjvU4IymNAlmsf88(cvK8tHqDHP8UXAByOmIFitHiChCYzjnWsdYwsJVe8hLfkTMgFbfzi8rzHsRPKpj)smYP2cJuHSB(ezzO45mh6GXIcMdULGefXxYs6GSL04lb)rzHsRPXxqrgcZ7luNq3aAYNilZsAGLCurWdsi7MCS2ggkJ459fQtOBan5sFDWdvmiBjn(sWFuwO0AA8fuKHqiFpwuWCOmtO(ezzyTnmugX3xZj3gWj5IlIXCQTWivWH89yrbZHYmH2LmmhKTKgFj4pkluAnn(ckYqimMLcJ5SdwRsKprwM4IymNAlmsfCymlfgZzhSwLOUKH5GSL04lb)rzHsRPXxqrgcZ7luNq3aAYNKFjg5uBHrQq2nFISSUvJrLYnSgZQeesE3O45mh6GXIcMdULGefXXVKirngvk3WAmRsqi5DJ12WqzeFFnNCBaNKibRTHHYi((Ao52aojFXlIRbCYPVdZUKblDgKTKgFj4pkluAnn(ckYqiKVhlkyouMjuFISmS2ggkJ47R5KBd40GSL04lb)rzHsRPXxqrgcFuwO0Ak5tYVeJCQTWivi72G8GC)oam()zrbBayS)oamguwO0AA8vhgGNARkgWnPoabL(6igakL)LgagFWy2oGppam29f6aspCsmGpNhGV6OmiBjn(sWFuwO0AA8L76FwuWKTe8FfeJecxVOuA9jYYWAByOmIV9CO45SqIelPbwYrfbpirxYWCq2sA8LG)OSqP104l31)SOGbfziegZsHXC2bRvjYNiltCrmMtTfgPcomMLcJ5SdwRsuxYWuUAmQuEEFHks(PqObzlPXxc(JYcLwtJVCx)ZIcguKHW8(cvK8tHq(ezzO45mh6GXIcMdULGefXxYsQClPbwYrfbpirxykVBS2ggkJ4hYuic3bNCwsdS0GSL04lb)rzHsRPXxUR)zrbdkYq4JYcLwtjFs(LyKtTfgPcz38jYYqXZzo0bJffmhClbjkIVKL0bzlPXxc(JYcLwtJVCx)ZIcguKHW8(c1j0nGM8jYYSKgyjhve8GeYUjhRTHHYiEEFH6e6gqtU0xh8qfdYwsJVe8hLfkTMgF5U(NffmOidHpkluAnL8j5xIro1wyKkKDZNildfpN5qhmwuWCWTeKOi(swshKTKgFj4pkluAnn(YD9plkyqrgcH89yrbZHYmH6tKLH12WqzeFFnNCBaNgKTKgFj4pkluAnn(YD9plkyqrgcHXSuymNDWAvI8jYYexeJ5uBHrQGdJzPWyo7G1Qe1LmmLV4vKCxFpA5hkhPqHA)i1bzlPXxc(JYcLwtJVCx)ZIcguKHW8(c1j0nGM8j5xIro1wyKkKDZNilBXRi5U(E0YpuosHc1oIuhKTKgFj4pkluAnn(YD9plkyqrgcFuwO0Ak5tYVeJCQTWivi7Mprw2IxuxY6SCe7gUfLdIvhoMqKij9yPYkLxuAF2VhjsspwQSs5q73gwHKejlErDjR)YHBr5Gy1HJjKbzlPXxc(JYcLwtJVCx)ZIcguKHW8(cvK8tHq(ezzwsdSKJkcEqIUK1F5DJ12Wqze)qMcr4o4KZsAGLgKhK73b0XTuySb0XqdwObjgKTKgFj4RLcJjKHY()4Y4RF(ezzO45m)kymBDF2L3xOC8RbzlPXxc(APWycOidHO0kOf6OG5tKLHINZ8RGXS19zxEFHYXVgKTKgFj4RLcJjGImeABYkYDHZeKprwgIDJINZ8RGXS19zxEFHYXVKBjnWsoQi4bj6sgMijrs3O45m)kymBDF2L3xOC8l5iU4fXpuosH2LmPiFXRi5U(E0YpuosH2LS(rQiniBjn(sWxlfgtafziKfWGOcxh14hyWPs9jYYqXZz(vWy26(SlVVq54xdYwsJVe81sHXeqrgcTkrcDnMlzmMprwgkEoZVcgZw3ND59fkh)sokEoZj4xFpADlErUEKD9fh)Aq2sA8LGVwkmMakYqyowcL9)XNildfpN5xbJzR7ZU8(cLVeClkbuLHrLJINZ8RGXS19zxEFHYXVKJINZCc(13Jw3IxKRhzxFXXVgKTKgFj4RLcJjGImeIAWCF2PBKGw4tKLHINZ8RGXS19zxEFHYXVKBjnWsoQi4bjKDtoIO45m)kymBDF2L3xO8LGBrjGQuKRgJkLNE2XbHSv5uzOm6irs3QXOs5PNDCqiBvovgkJoYrXZz(vWy26(SlVVq5lb3Isa1oJ0G8GC)oap1QJTNbiIcgJKUvBHr6a2xnn(Aq2sA8LGluRo2EKTe8FfeJecxVOuA9jYYWAByOmIV9CO45Syq2sA8LGluRo2EGIme(OSqP1uYNildfpN5qhmwuWCWTeKOi(swshKTKgFj4c1QJThOidHq(ESOG5qzMq9jYYWAByOmIVVMtUnGtYrXZz(gWj(sWTOeqTZdYwsJVeCHA1X2duKHW8(c1j0nGM8jYYWAByOmIN3xOoHUb0Kl91bpuXGSL04lbxOwDS9afziegZsHXC2bRvjYNilR7dzkeh0vadIYx8IY)cJ4R57)gjsoIhcfpN5R57)gjIlulbnuLIejhcfpN5R57)gjIVeClkbuHLo(w)rAq2sA8LGluRo2EGImeM3xOoHUb0Kprww6F257v8LG)RGyKq46fLslFj4wucOkdtFdw6ixngvkhMPqOnkyoH(l8bzlPXxcUqT6y7bkYqiKVhlkyouMjuFISmS2ggkJ47R5KBd40GSL04lbxOwDS9afzimVVqDcDdOjFISSfVIK767rl)q5ifkur8MuGIAmQu(IxrYzQsfUPXx(MuqAq2sA8LGluRo2EGIme(OSqP1uYNilRBu8CMN333PYDHZeeh)sUAmQuEEFFNk3fotqsKG12Wqze)qMcr4o4KZsAGLKJINZ8dzkeH7GtCHAjOHA)LizXlQlz9xUGuh6x4cUg0Ijg11)RKejic3IYbXQdhtisK0D6XsLvkVcyqux2ijs6wqQd9lCbxdAXeJ66)vcj5QXOs5WmfcTrbZj0FHlhfpN5lb)xbXiHW1lkLwo(LejDli1H(fUGRbTyIrD9)kjFXRi5U(E0YpuosH2fIykfOOgJkLV4vKCMQuHBA8LVjfKgKTKgFj4c1QJThOidH59fQtOBanniBjn(sWfQvhBpqrgcH8B5(SRxukTdYwsJVeCHA1X2duKHqBtwro93LkDqEqUFhqFBuqtQyq2sA8LGRBuqtQqgUGCHsW9Pm4KSOePfxnug5Ko4wP4WDhcBKiFISSUvJrLYrxYuiUp7erDwd2lm5O45m)kymBDF2L3xOC8l5O45mNGF99O1T4f56r21xC8ljsuJrLYrxYuiUp7erDwd2lm5iIikEoZVcgZw3ND59fkh)sE6F257vC0LmfI7ZoruN1G9cJVKD8djjsqefpN5xbJzR7ZU8(cLJFjhreZbmiQBj4wucP70)SZ3R4Olzke3NDIOoRb7fgFj4wucKGkM3qcjKKib9fc55age1TeClkbuX8MejhYuioORageLFcHHYixiDoosAucxjzsvUAlms5AaNC67UsQdtPcvPmiBjn(sW1nkOjvafziexqUqj4(ugCsgmdlXCF2PqixowH6SfnuAhKTKgFj46gf0KkGImeIlixOeCFkdojtKSv4(SlVMsBzmNq3itdYwsJVeCDJcAsfqrgcXfKlucUpLbNKPqixowH6ebSG5tKLHINZ8RGXS19zxEFHYXVKJINZCc(13Jw3IxKRhzxFXXVgK73b0heAa6gf0KoGEHczakeAaqcyqiHoasObCtPZaWAmCYNb0lySbGsdaxqNbKJvOdWQZaUSyPZa6fkKbGXhmMTd4ZdaJDFHYhKTKgFj46gf0KkGImeQBuqt6nFISSUXAByOmIlUOuKd640nkOjvokEoZVcgZw3ND59fkh)soIDRgJkLhjkzxsKOgJkLhjkzxYrXZz(vWy26(SlVVq5lb3Is0LSBsfj5i2TUrbnPCm5qmHl9p789kjs0nkOjLJjp9p789k(sWTOesKG12Wqzex3OGMu31g)gQFYUHKej6gf0KYVXrXZz3bFnn(Qlz5age1TeClkXGSL04lbx3OGMubuKHqDJcAsX0NilRBS2ggkJ4Ilkf5GooDJcAsLJINZ8RGXS19zxEFHYXVKJy3QXOs5rIs2LejQXOs5rIs2LCu8CMFfmMTUp7Y7lu(sWTOeDj7MursoIDRBuqtk)ghIjCP)zNVxjrIUrbnP8B80)SZ3R4lb3IsircwBddLrCDJcAsDxB8BO(jdtKKir3OGMuoMCu8C2DWxtJV6swoGbrDlb3Ismi3Vdq6NhWxm)gWx0a(Aa4cAa6gf0KoGR9XghsmaBaO45SpdaxqdqHqd4vi0oGVgq6F257v8bGXSdiYdOOqHq7a0nkOjDax7JnoKya2aqXZzFgaUGga6RqgWxdi9p789k(GSL04lbx3OGMubuKHqCb5cLG7JG9QmDJcAsV5tKL1nwBddLrCXfLICqhNUrbnPYrSBDJcAs534qmHdxqou8CwoI6gf0KYXKN(ND(EfFj4wucjs6w3OGMuoMCiMWHlihkEoJKejP)zNVxXVcgZw3ND59fkFj4wuIUWuQiniBjn(sW1nkOjvafziexqUqj4(iyVkt3OGMum9jYY6gRTHHYiU4IsroOJt3OGMu5i2TUrbnPCm5qmHdxqou8CwoI6gf0KYVXt)ZoFVIVeClkHejDRBuqtk)ghIjC4cYHINZijrs6F257v8RGXS19zxEFHYxcUfLOlmLksnTPTga]] )


end
