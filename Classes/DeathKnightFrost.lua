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


    spec:RegisterPack( "Frost DK", 20220801, [[Hekili:T3ZAZTTrs(BrvkttAltZhIYoPe1wEJ3CR9UvsQOS1EFsuqKGs4mjbdaOCukv83(19mdW8a98aG0jzR7(WUXIyE0VM(10Zmxp86F(6RweveF93pAWOrdE7GH9h(MjNpy41xv8424RVAB08pfDh8p2eTg())US08I938()b(LhxLgTahH80DzZHVEFrX28V51V(UKI73DB)5PRFDEY6DRIkss3mplAzb(3ZF91xD7UKvfFyZ13sn9tM82RVkAxX9PzxF1vjR)wyKtwSiM38485xF17JJkUF)n)Jnj3DpapCW6JVB3D7qWB4P7VbhW9FC)h)27J2CxC((p(Q938tXRtFiEX(BwfLx8Q845PBG)yxoGG7VjD5(BGgNSjN)V)WC4hJG)ibgXfPX5BEo8p2Uk6X93854vRGpSb(7SO5fjZJ7ZMG3NYA0Cyo3edT47wfNFpdXHHyxwYM72FZFnJd74CCvYMfzr3LMh1)6RwLKxKJKZ0BxLueNXOAZ2MMUc6h87FpJBfVj62vXlU(VcKO5ylU(QmaTYYJH5kF2Nt2aDLtMYs2YBWpYhdaEsZ2FZpOm8FdadfrzfaAoCW(B4Ke4pUnEzAgG))yYQvrzCGvW7bUAmJeH0R3F9vW0aJws01x9qe8FaGRF2NND7ULlHw90taneaZhINfVjEDc2ZlNcCNRlaEUb(ihP8TabEgay3fxK3)UvrZtIwnlAXdrBqUcBe2FtN93ueTkEtr)LiOLp)XI7J7xoGvKhJUJZ8yRZmc39)eG1a9A26O53NSbWNyySyZxnCPeqoz)nvO)cKbNpBXU4z82lHffafHJZSWrRKaIdd2Gw948vXLumuubg9jwXst0aONdzOrfoWa0z5fzjFkEgkuSlbgxD8q8zCQo)lkI8gRiIuKlTy58zzjRvi23N(z2mClUChhN3E4cCz72Kmhwu(54mGpVmzoQD4I93C(aNcCFTf6JgDubESnnVzanfA4GgXaGHxGvJzyvxMa8Aq53mq11I(JUNV0DoOUCteSaBt88S0vPzlm(9p9imEGAWE8FxoUNXgx1r0cGBQuZUqQCyB1Inu2kD1Iz3hd67OuNQiFMMNZMOLO5LzG(vUzbGbC38fLumoYEbtYarEaQifS3T1knUJOlsaRFEbyXTczFjFAaLX3f3)tPRksYIYNTm6H0SsfD8jp4XD)nVnWHvWtpI4u4ZDdrj02vqJlGt9KciZzM7NLUCwcFzQPfj6gQBC9FLhlnUxAV8ZjOjEWfI5rBFn3IVQa2jvwUuT1lbZsKDlB4W5Ljlxs2DiZGucoJHCaQjk)cwBhYiFZb3ewK(5nCL)F(XS1a9Bx2JOQ5fpQlqSBZ9PREe1CfV5UI7RpWvTeODP5ZUnIPI3Or9Omghcr)h2vKNSq41wjrFxEmZtUdN4ZuQm7tmVl7lLQwgTc63S5zGlJlIZk1f5IvvrtTYjqX3jAmTG4SMmaC(OO54VRY4Sm4JfmdtpsAez7Kgr58JRhdA7ObowVB6HuiIE)ywmy8dmh)TWSV)M)oc7GC4dXzG42wMwGsTbC4sLigaf0fg7rc5SVKsiFDPPFFe9lk9QWdO2JBuwLwCqr5OgxdyliTisWmD6rXyD)EldDXD8j(n1B6CGGXNm)rWbOvPBYRRSx5BuQPhvs)z(IdC3vXr53hVai)XB(Th1gpPiGrJCmW0DqWZ48uDRNMXaypOkpKlcVrznh9M3Myf7BLs0c(6IurKGZwclrZyDXKL3Zr4bo195cbcl6HW8rCrmh)I(T0mmVcsgWe(qy2akw6zAikr8i2dnKe8KbaRJQkEyFWXc)hviKh9yHThLjr0Qeevn5YY0LyxQ1m0YMfuRtPeRrvAlSvPpcrpeTcggz(y0mVrj(ROL0ANjjGyhTrzrvl9lG)Awr6SrCCgwK04yrBwEggAlocnz56qqbl0ZzfjZ)KNu(5CGOZJaOGyktdZztyE7lO18wevueVzNH)iVGPZPNHzw68xU)M3XwhT)MFQ0WRtlOnjxHv5wqbvaJbJi5Wxy0YxdlNp3Pxeocb54O7XUDLJdoX95gcuE2ciKNhDRF32kLUgZblbetKP1PcEgZfKQcYZVYlf)lOmP37yYFRTw00SIh2iPf9JPzo7gIQTw98b1PaJzaatfMeLZ2GUHlfNdnpNht8YwgoTMaY653eHakjUZk9TXIABtRuTwTTD9)McNtuIQmcc8BdcOzGlZfC14GxBBweLT4GcO5kXGaIJaCUk(vC8Mo2MggbJlDyeSoNU3BtLILv8TYd826mMDfH2twrPR1)(6sUDfvvHCxxIrzQ4AAFHmf1cd83b4ymMpcGQKMTU((JzsY(YVBl22DJU8uH1mNtSHg29lU0luOh)w8MzB3TkVsXVCdfLFQAo180SMQrPmV8tkYkNrVfj5XfZUnDZUCqDxC2O3o7STZ5TSl1oYCI6MYW2DILrXvFIEW6fG4GYc26czLUNBDg6yzJXUKHfJAnpvxdexrpDmisgDLICl2hnA6i1MAOkxRPfO25Lr7wj38OYUTgCdgtys8VzcjMkGt3c2gIv0XwkoH)Rv7G)dqVI)LDjB3gVOpSWEE2Uc87Z(LDalF3AWfVhyQMq(rvdbw6SLjzi9i5UKvLS8UkPRZ(yvMEFTS7zmIs9m98n1DccbSLuvWbL5jltqPbGZU5tXfSQrGLo1D54pZZUF0UI01G4di8bADIZzuYz8IuPAmMjgckZx(5eMXIuLya0v5OKfZyGC)OflY7JLcIir(IfkMTi(xXY7GjDRaPfZ2cr6UbJ2JW8xZHr5gv31juW0ez5B0yOAo1fyPXUJk2hUEg4i2BrJOmi7hh1Z3Ne1uSxFxmUaNjkYvCp)(O1B10TuQ7TbDXHwT3yGKkgejmL7hhlZQlORBrYCqUMzin9Zs1YMFP0YY0MLzy)PfURwMH1WsAFViCzWpcBeZAFropyWyDdCQar9qsi81iyFSF32TRESQ2M(omVXNYT7weHlQ)WC4R)mlR8GshSCX(uC8wEPKjg4938VzJm6xoZFADF3emwyGxYNKWSfZfY9TFr(3ngwi62mA7B4DTDu9Cf1NUZGgEDRNMEjOYX6QDkb3(w91VLGZTSuqHGtUSa60DGJSjAdMpC3pPTJ7eA2RXHRAFBGMQTOSJV9tkKm)ga9oiAPkPISLM70DieF3cEUcJYrq8hnY7XHQfI0C4u2ZpQewZGPQLrBvnC1dhPtzS10k4n)MWlglwHg2FIIdT(ukEejcgrFy6bPMDKV9(0uSqGEhRVOtPOQ(IuMleYHCEeSUK)hZWMWR6xHLTskjZK6qB1gQZHiJTEGpawlUbxdqPt3SrW2wY5bl4IS8HWEYeemjL6dOU5Vq2Si3RZQKBSKeNPvEZgs(G6HUSd)Zc22Sei5OQMdXEzpPiU0fqoTaaADwv3gjSx2tgsquXJR2QlulMjlrsnYFKuAXR6QAuetMJ4DOacrh7fobVSu9X4(9yK3s994qXvJfb0QRgeKSBy0vEDAEKwb4xztyBDvY5Ms8YEJH1bp1Fi6nLaRX7TBRKmC9gZzJs5fRQ1cN0L(OQDMqur0LkRDxq00YSM2aRgSkqzBAL4NpnqwfwYklLQZ9lpu9fLSoqLnmxYDtQ16LvhJhZ0GG(ANUB1TGwU(B3LxSdC3poB3wDKOm3P(BPAD4r6DI472lqD16DmEnlZfZqk4SphhTLZkSVtoHAmOILmP8p12DSU89U8vcdVKgvV)XC2KwL13Y2RQTz9wWDOzfzrBYxgNfdU4xlzXkCx32N8s30w4BH0zFdQidiW74zF7PcLvCuwo42EDLePlB)AYaxkRDaFZbl1Ze9)C9DcWyXavw28Wl845VZPYRxSwvErvwfJNOblr3MUoztKqD96B1luxRFTHwL7DWslbK0Qa2ajFJIBEUD3NdX)0AYyUpSeLqTFRgImBOa7uGbvcZS7Bq12nqcB12IzBnuG6(cBUtB2XaHV6JhuzyQUE1XgjvqESs8KmmsFLcIF1qNcVmeo8l558358xJN0qGPw)ntiJbTZU)AbWQ9iSqUZZU6JEh6ecnTIA2icQyhmQF2g6y5B1jRLZ7XjNaE5tED91RrEthSuQmmE2lhhUpq(milvPDMCD9jbMULAWkaBVzIY(c8ieraO4Fn2KS484YS2Y8jTk4NOK84zaLFHkDJkPybQUGqTKUqTlRgq)3gdwSUhCF)OUgFSlvsetPUKwEeG84osgTA2w4hjZ5Nd6tLqUuOElMNQ01PBIZR7bB9QmTqnLLok0n5o2vlGrEV3FZ7UnbuvLG7JVeKpsz71UKHFvu44tByU9(t5oAyB748WXbcYvcwnynlfoOiP95iyblMb2KCYAPqZlSgpNQfiG950BKxENqVAhDXp1vSPXzoBGl2TJoEU3o6q5Xxt2IQuyfU6TaTh0ZbVXUwNGex136nR0)UHlBrfmz4O6fQhxRGMsfIJz8AUJu19IaQXkGQZKGWfeFySM(uZONvfaUh8tc3yBiGZDB(CAwX9p6o6mpl2TmE(lHtloJ2nOKTHiBvZEifVMIG2LNUITEsvEQC6Q1iXogYIYfh)zjlzxhs0JPwdxVoErcRS4vs7RmtJQT9UvP3gTcBiZOl4408013grElwik9geouurY3vV(fd7FFu(SDG3vi(usRcvmxSiuoyvIvl2vEUBFMdHnzRaBOsNlBWC7EfSgueaSE5FP0uof8qSaqZ7L)gwktadew8eTxPAflNOtHGhsEizb23BFS80GZp4um6b8pH)KJj8FwIlpxzG6V)MpSeVhQWFKv)u7V5E8MPAdU9YS1sSZuFwCXUmaTWR)Q4v4Urx(ld6pPVAnuja2zdNL)4M5sXpJY0AgokxFf07Q62AiL3lkYCuJK5SosmReYNJoMYNJ(pi5tsyTXYNo5AwQawDnfNOTMPgZWkJIbxU5IEr3xB2gS3Z0jhd6pGtr6vD3L0xuE56ZotFDzoauAELLiDPXYX8YAGkPMJxB2M2bQdBgOoubunvgLxKSMqzKqDbQ)bSzSnIFXuWoWxLOfx1d7Ne9ZuZf7BsKRQ5CUl6n72SuS95GQQ)EehgKi060fy5ydAOW6H5o2rLaAW9qq54pUnljfK)EK)zz3krIt5xdF87CpXGlhYLOo0KLQOnwJ4yBtZk)xBsXslNr74LpE1(EsQwSeI8PyCy1cSruHO4Vky9LmCE(AmQGu9plJE)2ewXbJfCIm6DLsuw5CHnrnBlQ(CiHEMNg4ont4JHEf0M(3uo0VYC4qEqB9Mkmgg(7Xn53jT6uogWbuZ4qWjWRAhPDLCIzEWPCEM14zSuPA4ntpHiDGuzU4sT0XhWzqtJkipV)ooW5v6kj2fizSgn(SQPjX9DWN2Tkcp7hrBbnpaVLR7yoA0LRCzBE8UfPAkxehEsEL5XuBeHf)ntHOmDUyO3IcSiGqToWdcNV1)DCVLAeC)J8P4LaLB55E7Gqvj8sDIW8lW6o7AT9Kh2W7qI2Xrc7UKWB6d72MJHhjcQLPEtDiuPRNcXmANTsv1JENIYAuvU0Z1r97nQn1Zr9R05dVM)(5YgkUHKtCCK3AvEsDLNd23ikTKMvJSDCUjCbMMq1BiqpdvxQ9K5v(Nc52GGzORY3AXK6Q2EgYBI2E5TijNXKs(LfZI)1457qlh84S6uATO6kiy7CiqHb8sEskd5Gxt4Rdx(4UOhIxHOM8GtgLDBctCTAvL92q4YJOU(MhLLZj1GkHSnWIsCDZsfnl2BcHNnLDY48DwZdRMlzwcXMJmHNpvabFr2qZ1EkXSu6zplWewOfOz(yryrlercDAzeb3gxEEszGG4SDTnkjd)n(qv7YVUVn151oXPEx5QLvdhNIeIAyICyL7B70QJHPCA0dnwg4Nru7QoVj3)RAHHk9PQARW0gO6rdp1yvjLVM)NnLDOlk7WwrzhvNYwpLi1OSMRzgr5jB91v5Rslu)7MWnijfMz)XRywD5u5q0RmuyF7IXLvfYPMIcm9PPBWd6zkwXeiLBxUQUJY8xWIDaNZtlBbQoHvYc8UPKt2FqK4HnXj8V7F0UnLLPx1XHkaHASWdHDqNmoVYMU4OTGDOjFn66Q76SJXZBGTBKmXyVV6(Yz)nFdMGPY37G89vVZb)10RaMjYWEikzfccx7V2s0wc76A3XTl7Esurqu5X0Eh)h19AwZIpU1xgLoc2PPrZXgVVC3ow2n2rJdtziX4)CHe2SI0KirXvotOfNA(9f0ObeySJt7CGbyCPXfS2xW3Zbbg0qaRHhR8Wh9mJRDnBRXUGx1lbs7DsjRLWeFKYVqydjvTqEIADyG62vPPl4L7PUHPFs0x)Xmrz1WFNKqqmyGmR80EApN4D9wgVwm1zupr2D9MrZ1wUx7icP)5Z1p3nI0YWU4TCBJXlrzf6xC(S)NDlUBD8MqS00MyzRaCqEgewbHB8435wNV74mWSJ)wVH5eeqbX2gZKoPuFhgYBkqmv5wqYdEuY7f2VOoP36fzLLZcU3PzSMi0Tr3XYDswY8pLFT4cz8byfc(v(dn2KrGdtFokdlrky55)(D)03)HV))6BWnLNLtHeGUMvUlbpN6GE(CS4k(LD80fKNIB2J4kPc)H58hDS(7)4)mbd4y03GpxaBaGG95NlW3)ByuW9TO6VlrB43JGP)V9d)tGop8x71hFjZ8aLsIxZGTHgWMCdfRapLFsbc7EgdWAngkqmE)hFG9)SdS)tAD)9YyufFAgR5qjQM9VCRKRgGQFW2imCqlaHrHrxuUJcAgzXuIneyYbzbFHbzvhqr0VYQmhCq(N7I4fbrolUX0Tideb7UVUNBrVdD4MCSgoVmGQI3)lp5F0)hxvHk()Mw0F15)Rn6Fv5MwncYFPflllVGaAMqX5nhPmTWXhO328bYj1jK(pomkJs(QAgXPnsmQ4uliUHQdOQwIBggn0PskvTuRtxSB1UCnLupRNXsI2OszSR(lYC5qLHqMmZ)BZU72GqJXM2OGZb4ub6JiWMr1XMXhUbKrUu36N2EwaD3bYm5iQS2S)b7DlT2jZHRjEu5DTyvrj2S1ITrCZLxInZEYXXMSz)dMnDOw2PzZ)XPW(44IGz)Bh5SnMs1cEOnQ11gG2iARzxXKrgmHOXHFluI1W1UTHcn6afuD2F)k3DUoXVY9rh4YeN93p0hs3Da9oxK6F2dP7bs7Q5NS)zpKU7f39UqqCj53S1bTEDQtgAtSoBHSeGe54duLPMJSTjFlNDO6Cp7OQZTngV0gG2qe1COPferA)ag1gQPZbiCb7axUfLg3SLATG)gMVWTEGAHzG)8K7GHh6Q3d2HNsbLpWKlWUH3ve8DdHFChqMp)zX46VF0KH4jioDzcwJlF1xT)M3ZREM)bRSylVk8)i(L3T7UDyTrIhOuCFtWzb)9VLlsX)JxXVm8FaNySIoEvEmQMfR4j2RXnwvoF7989Qb)3Fa3xy8yCH7a4I048nph(hBxf9y5z8cpcgBZqeyEC)Qj59PSgIIZBIHw9DvhBj5dUmDLaXOoWG8Fyhy39FKZdZ7xLKMxo91L1TXPyr0ovGeItg4PPBNYorNNYM0PdpvEA1Mcd5PiJjbhZPs3fulTRoDpriHrT56D6k7vTZe5ZEM3Jv70b9E6jNJFyhF2N9mxaYL)LH9uNjEDE2RjuZrTLAoQvutIdd7FmutcaXk1exp9)FMt33QZCAtKflHutPXrQsJdvKfpXYsBAzuGXAr21P4PYh1Qi5l)l4PEUxVx0Dy)jVuFOzBJFjPgAHLtIDVEx21PIgLpgWCtCeRPM7HI5oewtzPEk4eIvggNSTNEQ2b39PNYOoSU0tP8u5wA19VXpKkW6dCerrx2zmLTQagbMmPAfSkfZMQ8aLXw5EWp3wvdDnItTAswqL6gWJc2tpz7zfRNI2m79NFmKqkVOPf0VIz9SprDcamDG8YBEhbARx(mth2PB977Tlho5PNoH(QCQN9jt5Q0HCYUC6iWce9WcIIK)EDWtqYUearTdAWLdh0ZbWjl8xbSXwbko3YiyfYTxR6cghnRdrXLD5BCaCQLwy17yLaoT9sC1HxWvKVcxthjxTB(2AX7NTxCRl6E38fVyKdyTw55kGtlVVkDiEowWv8FjENRub66fP)PjlNwtfyhALLspLulwMo(k99NEI6zlOd1qDILACtJYRvz6NQvpOGjwaFoXYBxf4lNQ7rWQz20z5AxRJdV2QC0Qrecb6v)Lsrd9mQ(weHyDR(tI0ftzILDQWQYg0Xz9(Y04yqjC5HAqLYlt7yRzPQl1Bfc3e8XnxpmS98dazLfIpFXNPMGo2uA4(bzIRKcCQQh960gdXSui449ssfNmFml4AfRkDj)nvua3(ByLdqEBzLN8H00YQY8u(R8bxrIGGj)kqzTSe2PihWriVeJNIEu45Qlwt0jt)9gHd8kvONg07smpObvufnkuIVuRNUy4asxUgz3Llf)hTOUfhul(pvFQGg7NsRUYPoPU(IikBCnAsuzbNqAfnmx0in2gc9tgcMItZwDlLKSgMtZKKIO0ynYCnpN9VYUSo5ejxu7AqsgshmrtR7BK23PTmlORm6M48Bz0jLpvjPqEw56CIJlVfJbv3fiyyjokFL88Q70OaqNt08)xNCFX0Xp9KbhymJO(7Xn9djzT0JbcFavpUSwUHJUy6OxaMmT4SBBi5E49w8QMtZPUqDm4axoQjYi6UzyVF8538sb6IZQSOfo82uMereHx0D4KxkM4mZJs5lM0ZdjUD0NWaTl7oQrGM5XSZoK3e6wD5s1lthZVQF)5iuc(f5KylNzfxhiuQsQh)PNQDcTjhpVSnhQx9zUdvMDCNsBJxZuLO33WnNqkb7EXvhRNk5qv94eyPGOPDh)fcKWKX(CE)Mbt(6OF9BO9c)Ld79SAFriuaF7fECq)5y6x2cTHV)dRsXnjP4ECXb7)bc9By7xcArS0OxH29FJ0OiUK4XQ05IM(yp5cSDAjQA7lI4PjsXi5sLRyYf9XsqaBTifX44OnWdyRQN)jCduy2DLnGpn8T1HrskNZ8uuFq8VUnbx)NUPF7wTqkdmAITbJWhfkJgJg4pLhbfiYL4vDOlP5gAndaSdEEjObHnMzANSAkfcxCMFcxBjhhry0JDR3XxXt4xVsOXtdwU8IPDplqd9kJ)lTLD1Aw2Q5fnA)tD(hpQJgzz0fkF9zdp328FCStjhpJ8nzsMAlygI5VoDvgRlNE2e(MmunxJzPc8PN0fE1gzgzvgptPt)J7DCi2Hyig8GV1MVSr7u92RMG75d0rMX11RyfdoYqAWl3QmdmYKjF2foG(qKIS1xDVInPItguvbv4((EZFhZ8hRGV47DVIRPYmdoDoR4PqEtIiP9P55D02moeDyc2XxmQCZhiez6Ec26YxPnE4wkN5EMLByjXlLUI8P0vfjzr5Zwg9qA2tpfq)FR1U3tSQPTqM9roiaB4a7qgpP0)R8yzTKvE7)XDS5dS0))AHHcc2eW8RXOi3ulBz0Zc3atvgzxuy9VO7WxwzuK9v5lqhFpXlj9wEB8UGPYJdb3hbs03gTjw9JC6ZpSRipzHOM(kPp7YJz153XMozX54LrRwH5FmBxE0I4mRBZG)OYgorqzDq0R)odwNmTBBj1LyGg37Gic2YHVjvWoE0E6ZOb61kIMoR0hIbvDB3YwQuUKruWKbIWnztJSZPo7yXP(6aY7)yRe6Z6jCL8BRT3qvLWu(u(ZHELvDIRCL6DciDexZl2iGmBaNBl76v)QsTJOwAn2W7jkTP(JH(Lt6y91wcSgz9BLmdI9ie(sDJCOazZjpK7SeJmnrnOGl6E(Gx11ZJvo4I(R6MPeOE9hOCOj9eIKw24kl4wV2GC8DLMUNgKvFKKwkY4kgmb)12g4P6io6hUVXeSJP1NZNyHMzhZ50lRQzA6WPT0tpWIXteZcXd4TGUq(LSq21TEnKBrNV9YdrGJ8UdlFD3xlCakoiZixWceNBZVheO8PWcSTBbWm8ocHj9yMNoK2dnvpTTzKI0eE4LGxYMlhJLATUMHXTeryfJJvkyW7Z6L(O1V8n987HAWtOUpNbI4KKDRmj1qfkdwIODAru4JiaKGaObwCuPd5VRsjoKQ8WczK6Ly2NjcvZLIecCX0X(S25tToFf7zOKVZZlHw(iEZeA0s(0rt)DZxnzlRBmwc6RG(6w71AUvc9JPw)vBOTXrjsQMbMnr18IYJ9CLRR8IQs55ywDMevCLsfPItrdQiS60zFlRmtO50HnZYhb4JYaQVFT2Yz0WXEHoGF5uGLcqdeIcBCvFVGdBCD6aOBrCkSHCRapBan3GSXNBTXwwJ81wQ8QE(wJgKAilsmMEQHKsVsh8kkLKS1nq9CGlUHb3S0(5yqBaE1aPlINTxTrqdL9sVgB)i71Oz1lClJGv6skvkhCeuR1N4xHt)epuW9oL4X)fZzTXZ8R2pHzp32uj0A)dQLaOSalQWCvvWbw1eJ74OOjuhVxwVaRTN85Y0txXKRQXAwxikkB2kihhTIYm)y5Svi6oDJ41I0yvJPgywT9bWkQHy2LvocPVPqDK)g6mKGuBCocUqNdyhMSwzDE3GO6B)QRnkG0DZla)hSundmA9z2HBgUguXLCWBwKXmF4BDPhbEtpuKRDuBz1XmkCXnQnV09Us2eXgFshHH)uNrgX67QQd16HtPsvGstjqA1s4ssjY02A1lNQTHETG02cbiHc4FmvuCBFhwXlQQJ)M93CvvnUT)g(fJGsTUv7bMIDGPJzxuc4TMW7PbQzURbUqkla3dC7Kykl3vL1SENMW1lyGcTqzWSqRKOMQuWwPRCSuo87bG3(LihOqdrqbxC(aVtLpTqud7B8pSUPVv25nYHK8KwfpplDvA2cLF7tpceYn8Adb69zAjwYlazSaXCH8zUxgW0p9tghaQ(Ite1u57wrLWJRuIl6gauYNBIg2r1x3bSRDT68Dnnw9CKQoMRLYI(BczKMtpxDlwKWKXZertXiTN9bhDwC(HPFRojg4QNUbRJzPRxtFR7Aki85u7LtWfUutTM7KFoP00q9h4bzyR1)M7eXpUChxVQ8G4G3gp3Tk(vLLcB9yHkpZoHA5SEpFP5XFieDUkDoe9SDicJGCWmT2eQXfLHGkGcpzu(ieDGdCOknb1zrsj(WoEnnKShe4rzxj4dwIvHiUMTL8n5JPDSV8m(P(Zk(c3GJBtPLhQZ53tp1v3y2j1p3W4M4t01E2on)CHal7Ni5HnKsHDWhkglSllcc0hQfLMqEYw(zZdhC5nht(u8kZb4LR5hlWeRxBiQbhrM4VwOf3ZnaL1nbZxsf5LmM1U3vFdsELVHJNB1lgnSxplL2Xqu5HIAhIxN5Pd6W1SB8QmFXK6mfGnQZwS)KkhqNT(WjhqFl0VFzAThcFL42FSqEFt9f)5oMe9e)tES(Yu9AET)yvAUAdJmUrfeLMHlB(ybTXUdc0UxPkf(uVkRuTIW3iPkiv0OQlwRPd7j7P5vk1u9htCh0Jr)jGEm0c9O(B8Ql6XOEQus30JVIFth(N03wx3lpXNK2PHknBsKL3tAUe6mKul7uVaQGfTccZh47v4ZCntDWNsgXcohi4ZE41U()9d]] )


end
