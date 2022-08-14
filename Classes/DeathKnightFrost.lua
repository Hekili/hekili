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


    spec:RegisterPack( "Frost DK", 20220809, [[Hekili:T3ZAZTTX1(BrtNqtyltZNYpgr1X1o5w72jjtu60(jrcsckIAqcwaqPOmA4V975S7cSpW(cq0jPZ9(H2yrSpoV2ZR9S7EZGB(5BUEvyr0nF)W(dh2)ndg3BWB63F0GBUU4H9r3C9(WLFj8w4FSlCl8))DzP5fhN)X)g(LhssdxHJqE6HSLWx3uuSp)DV6v3gxS5WIElt3(Q84ThsclIt3TmlCDb(3lF1nxV4qCsXN2DZcTt)W3EZ1Hhk2KMDZ1xhV9dWihVAveT5r5lV56pgfwS548)2U4B3aWdfS(87pC7be8E75hNJd4XpF8ZFyt4UBJYp(5xEC(pfTn9UOvhNNeMx8Y8OLP7G)4qoGGhNNU(4COXX7YP)7pTe(Xq4pIHrCvAu(UNb)J9jHpCC(9rjjWh2b)Dw4YI4Lr9itWhtjnAjmN7IGw8Djr5BiiomehYI3D7X5)LmkSJZX1X7wLfEBAEyVBUojoVihjNPlsIlIYiuTz7tttG(b)(3t4wr7cxKeT6M)cqIwIT4MRZa0klpcMR8z3hVd6kLmLfVN2GFKoga8KMDC(pim8VdGHIWScanh0)4Ckjb(JfrRtZa8)hJtscZOalJ3dC1icjcPxF8MRHPbgT4WBU(Uq4)aaxVS7NT4W61qRE8rGgcG5DrZI2fTng75vtbUZnfapxbF4Ju(EGapdaSBJkY7DBs4Y4WKzHRUlChYviJWX5DooVimjAxrV1iOLV8HInr9khWkYJs3XzEKXzgH7EFbWAGEnBB4YnX7a8jcglY8vdxkbKZooVc9xHm48zRoenJ2EoSiaOiCm2ahTsciYpydA1dltIkPyOOcm6tmILQObqphqqJkCGaOZYlYI)s0muO4qmmUY4b7Z4uDXxve51greUixAX6LZYI3kqS3KEpzgwGl3XX5npDbUSd7IxclkVpkd4ZRJxIAhU848l6BvG7TgOps0rb4X0086(6Pqd63igam8mSAebR6seG3ck)MbQUw1B4g6s3LG6YDHWcSDrlZstsZwP87F5by8a1Gb0FNpUJjJR4iAaWvvQzwiLpSTAXgkBLMSA2MiqFNo1PcYNP55KjAnAEzgOFLAwaya3UCvjfJISxsKmqKhGkTc2h2BKg3H1foG1lVaS4wHSVGonGY4BJ69L0KI4SW8zRdVlnRurhDY9ECpo)nEoSmE6jeN8FUBikH2U8ACbCkGlGSKyUFw66zX0LPQwK03qzJR)J8iUX9s7L3hJM4bxiwgU)vul(IcyNvz5s0wphmlr29KHdNxISCjz3ImdsjOmgTdqnr5NtA7ac5Bj4MWQ073rv(F)dzBb63HShqvZREqwG4WUnPjpGAUI2DBXM6dCvlbAxA(SfHev8knkqNXyFi6)WHI84vmV2kj6hYJiEY90j(eLkZ(cX7YECPQ1Hjq)MTmdCzCvuwPUiBSQkAQrobk(orIP5fNvLbGZNoAo(7Imodd(igZq1JKgr2oRruo346PG2oSVL17QEi5JO3pMfbg)aZXFaM9JZ)RiSdYH3fLbIB7jAbk1gqHlrIOhuqBySdjKXFnLqEBPPFxe9ll9QWbOgqnklslEsr5igxdyliTiKXmT6rXiz)EldDXE8jUn1R6CaJXhV8bWbOK0D51v2l8nDQPhws)j(IdC3KOW8nrRaYF0UF9bPXJlcO0ildS(oW4zuEQS1t1yamhuLdYLgVrjnh9M3Kyf5BLs0m(6QuwKGZwdlrZiDrLLhyj8aR6(SHa(f9GF(iUkIIFH)AAgMxbodycDiuBGow6yjevt8iMdnul4Xdawgvf8W(jhl8VxHqEYJf2CuMAIwvdrvsUSmDjMLAvdTSzb1AvkXyuLMcBL7Jq4DHjWWWZhJK5nDI)cAjn2zTeqSJMOSOQLEfWFnRiD2qkodlsACSOnlpddmfhHKSCDiOGe65SI4LFXrk)Soq6ZJaOGykrdZ4jeV9z0AAlclkI2DqXFKNt05eOyMvF(lpo)9K1rhN)tLgETAbTj5kSk3ccOcymyOEoSslFfSC(cREryjeKtJUhZ2von4e1NBiq5zRGqEEWU(DtRu6QmhKeqmHNwNk4zevqQkip3kVe8VqNj9Gtj)T2ArvZkoyJATOFknZz2quT1Qx0VofyebaiQW4OC2o0nCU4SV558uIxMYWPXeqwp)MieOtIBCPVnguBRALQ1QTnR)xv4CIquLHqGF7qandCzUGQgpJyln3Mk8fjPPRi5xrrb7pX6RQOA9ycTRI1uN4qqeOjmJyQXQ77DDgxQb12bYo9AoOwc7MlhmLy4PJHSTFfBPrqnwW(dj5A3xLgqusWmxKp7FFy1TBPStxolBgTCfTpP7rBj43mKgm7(OW9qJk9hYvoxejbGpBGdzGdCldts8qZN543NsYtBhNCTFlrV1XzrKvm21H2eH0kh99jzPu5rg0kKtJkyvgF01cteuvZHclqdVfBg4M9YVKtvSaRccpKW3)IYMUf8edJzp6xJejnAuqKcc75rf8UwQKe)xjhIiR3J(phI3VpAvpaWwMDOa)(S)ZHWDfh2cEzCx8sMJ3vnemdmdysyybX3gNqw8tPTvzmY8yvMHzPemPmIC6uGRPUJxiGP86b2ixgVogzzaLF3xIkiBiojJEhYXFMMG5WdfPBbj2LhNd2rIYjuYz06KOAmMXgcDAyDZjSjYMfgVAgbK7fUAvEpSAey5sMjlQ2IOFbRWaIeMaKwmBpeS1oMvavnNnhg57vAxRqbXmVHVPhdftRldlv2Go2wbfOGJyVznsN(C34OCkN4Owv(THGGIilvrrXS0FfZ19MWT7LuNv6ytd6IrBGhN)AfKuWfhnk)DJJLjwe0cVkEjixtCnk9Ebv5kFPm3utBwYjDNzYUsjNucl1Nlgn2eCJWkHn1Jf2nbg5B8nraBDyKiqu3RynoDBjItzfpVF)(KhQkVMVdtD550D)Siexu)PLWx)zsIHbLoyfl9LOO90QzInWhN)pjJmM2Bs8mI2eRySWaVMojCtz3cyseUBfannnBRAwKDzHUJpBiajkXOIzls3DihiZrzdFZSX7xkchTAhrcSf4HS79YjPsjtXCqvYXMyYoiwZepbCwqYccco58A4IPCG1DTnrAWCH7UjTDSNtTGghXezO0UtetLwu2X1wA4tYh9GE7fTuKuPTLQB2QpeF7cEvIz6sBQLkl5urEpnunFKM9NYEXjLWQMw9AjvvudNQ2AYeztbV63yEXyWk0GEteCO1LsXtirqi7jijq1dsj7iFytAkwlkVN0x0PuuvFrkXfc(qIHhoJ(hZWMql8uMLTskjXK6atLNO1HOm1h4ayC)1TnaLoDtgbt7kKdSGkYshcZrlApyTUEVFf2xNvj3yyR9Mw5nR56NOSpeHdCnXYcsM(9KCuv2ByVmNDqB6c0oTaaACwf3jdSxM3NkVOINwTvxkwpngIKAO7iPKIx1wC9SjZs8o6acwhd8NGxwT4yC)omYBiljwuC1yraPs7abjZggpZIlInpslp8RSjSTUczexiEzNXWAHN6oe9MsGL49MTvQnC9gZzdtP1lPXA3ZM(iqV3UvHzROz0chknPjxoeP0VvyJfTfAL1mIZKje25cUOTf)5A9PfOD7KI5KxBAV7kmST5McgYAoTptTcB6up1PxsRvhuiUM8e8fRuttw0xlxtbw2u7QLU15)YoupK48wzjBBpIxfjUVd(0HKqm5EH73NLc8wQVulr7k4jd64895rhwLINbOyW4CXd4uGWBPRxRXtBtigDprzb3goQhGTc6R)rBWJa9P876ett7UZPDNc1GY1gmoyY)KqPrnwYDS2HQgD6UPfbJ2e2rJNyqJl9IgwNkTJJ4x9Q4CZB7s9z6eGGenUM0HiaOvbPOdXuANPyrCO3Pkie(spPTBxzwETytv2zyPMwigSLLTjMZfvd3J1BiGVfXaBkosAlJprXPQ1DbpDGsN5b6oye42TQQViK8Ewg)mBG3KK5GrEcYvfz6zEgCxh94aN)LFFy2wI7bX5A3fiPfVnEof3AdZZPzxk8Dc76rSxg5NDmVlgJ7BJDBPJx4SJM29iGh)wRrJf4FQE9mCZal8gZEI5L4QCsdns)76VSLCzGbu6jnbvVuSwN9AkflIHfPaTjKf2W2f68xuJ7cAxeOBS8WBlneoV4dJK0NQMuwrbGnGxlOngia2d7UpnRyZd29GZXIDdJNz3SSL7rkgNNEizbWQ6T)qEXbyWJYoSVUXJQMDxkEg)H2LNMqwpjkpvoD1AelxNe7O44plEn5Ueq)yk1WTBJwftClriG11vN2EX2EBs6IWeSHeJU7ZIwMUDrO2JakBtdr4qqfjnFK9kg0Bty(Sd5rKkwTKw5RyoBriFWQeRwDO8qR8nwe24TcSH2VslvdMB7RGLGcpG1R(ZLMY1bpAwai59Y3IBclWaZjrsXRZIYj68JZxfFx8kSVlEO8OurR6y2MyIrxTqOyK54YZegOEhN)P14L4a(JKD(948n416WomX4K1sKdKwwuXHmaTgaZCucMh9YFPFVj9e39xgWoBWS8h2TKl(PSbZZWr5MRHExTJZd059IGmNUrsDwhYMvnYNdpLYNd)Vi5tTWAJLpTY1mu7oYAkotAntnMHrgfbUSZfDIUVsTnyVNjto63RpLIeuDWF7XcytE2j6Rlp4GcnVYsKS0y5yEvnqvRMJxP2M2bQdAgOoqauvvgLxeVvJYiM6cu)dyZyFi9uDsQw6s0IQ6H8tS(PQ5I8noYv1Ck3f9MDFwk2(Cqv1FnKcdCeAB6kSqYanuy2NULKleObBIVDd(Jc5EkvSBLiX507Wg6fwdBW5djjdvXRfrBS62W2MMv(V2LIffhH2rl8TQTxtRAXsiYLIXbvlWgQlef31VJRS9iwqsv1(I8N5BRWIysznHBvgpJGcfxLWXcDIuche85Gd9SW7l3fs7x2e6DfRw0(Ldw1uVpL8F9jJ3gdVpR8yQErRJiVrEjpPwR5eq167RJ3(HEMxTu8moRDB3zF38L)H4zjxtDnBp6EFnewXsQvc8Lzred99LK)LHDlEZd5KjTknBLTxCB0a9z7kMvKfUlFDeO2yzuTSZjWDThjSt6MueqgiDotsHSnBNJN5aR9LvCswoypC5kjsBzzqnI8YZLLR5Gut1gIOxGFOSyWEq3g8FQJTsAX6u5S8mmQ8QRkMH7k1ejyrnjaCPvRFTHB3C7tNPsUzA3oxOMUfJJIDEU5eq4tMWQjJz)IOPeQDB1GvYEIhlcnGH9mEOpl0DmaB1sVMPgYqDx5zVkoSMuk8SIqzepYL66vhPSlg8RSNB0TXvMPhsvJPv(vdR2HR8Hd)cAXSBD(RXtAiWuR)QvAOcTZS)AEWQDiSGqI89SMJmYj3Ho(qtROMnIGsAPU7nMog(wDYA58EAk2nN8jNU(60iVQdwcN62QcDWxFGCzqMRsBmFDDdsqtM6re(1te2yYhGicaf)BXMKfLhvwoYs7MkSWipAgq5xPU1LM9)YQ6cnQLKfQDSLr7Hy5VDd4((jDn(iBQK0mLYsA5HaYJ71uyYS9WpEJUnq2c9PsiNluVhlaZ0TP7IYR7bB9tWFHqDW6Q6O(5YgYUKEJTCK3A1UnAt3e5B2oKN(ojw0v55MTjEj15yO6Qt09LUNcU0cgwtvgQ8i0Xb0MiPYBvCoHjf)FaP0FjA5bSWIOzRSZrwXevDk43VSyggifgzixYXcVwtIbOYh3gExusLtTKdozy2cuUGpUwAJMOCz113YWSCkPoeA4oyXdwwfRfk8eZnrtaGLDs58D6rYte85YxXVtMCSDDEbLelvKstaRv4pD99a1L9cjDSm1CKmlsYniUdjrS8AUILkZZltP3IOYJYkbeyhRS9HXz4VrhQAx9Z9UXqHgv7WU6uPHeRXYbyrtuM2DMP8YdmqCAKZTnpZTKjsts1LcoVwEK5zCTQwwKgO6PZEQIcb7by)FJu2b2OSdAfLDyDkB990OgLvDnZqDzyO(6Q8K0cX)UjCdTKc1TVXPywD5u(qe0GqLzPAtsrbU)NP7WZyAk6tls5oKlQ7OCdii7daoNNx2cuDcXPsA3e2u1FGTZb7IIPF39OTiLSvTIJJU8ouJf(uyh63nnNYM24OTGDijFn8MQB6RtXL7VP7Jl2yFS6MW8483H7qu5T9F(XQB5))s61aZezy3fgNGGGhE)lTe221MzjM00ltlzF(SrLhDJ26283RB1lovXNk3U1xfJwkd3MwNXKX7R3DdLzJD6XHPeKy0FSqctwrAsnsJRCMOxCYC2x1ouSDvPggB5Gw7zSnxPC9I9v81mGHbneWA4jA3)rpt5shZ0ASlPPVXtAVvkzT8m6Iu(vcB0svleoQwpfluxZgesjADBs0llpMm6UJM9YKIp6i1Uc16o0QrVn3X463CHw0P7HTbrgShxQSwpVwoZJAhBPK9Yt7vlSzL9IUADcp3wMizEuSVEzGU5AMBHfyZOH764DnDFjj3(D9KpgVsFskoqZwa5Y82oRvzhKFQx0F6DzPIt7oEO7wBG9j9dwGhIdclyTUvPgpSXw8QQ5hUj9AGOgR0RPNZORSoWfmTDWJgk2u7h8i4hUlklhBj7DxRpeZ79Hz42vd6G(NV)N((p99)pVdlZsssMI3UpnR8an(mDh64Nbeo8kxJK)O8uuXj76rd)HL03GTEh)8FpgLAg(o81tyhaeKp)mgf9FbJcwfBv)Djff(9qy6)2F4Vd8Hb)sqp8HDZbuYV0dAgSnqb24QtRapHFsac7oMayTgdzigT)JEI9F8tS)tAD)DYyefFAgR5Psuv7FzXbwnav)GPryq)wacd9JUiCFz0mYIQeRpWKfYc(GlsQ3ZIWFHuR14G83peslR1CsIes3JmqeS7(Qa7IEp1HBYPA4CYaQooMF9j)d))4QkeX)x3I(lo)VvP)vvcA1iW)LwSSSmcOMjuCrZrkvlC0b6nnFGSsD8P)J8JYWUONAgH5PkT0ccRVCAHeY(1hNg8eXjp1PvDA3AggnWQsxrTUBtxDi5qUKs3VjqHP1gvKJS1FwQ5hime8S1)Vu7UDdCngBAJcBlGtfOpud2mSo2m6PBqCOnZhUPTJ9O7wqMjNqJpQ93BV11RTvD4AIhIoxlwDEqA2AX2iUzZR3MzF804JHA)9Mn9u9urpB(3pf2NgxEu7F7iNTX1aPGHAJADPbOnI2s2vuzKEtiAC6eykXA4A32qHg(0K4L6FBe0T2F3ghSUoZTXHtJVEg6VBO3NUBb6TUi39S7t39K2vlUb3ZUpD3jU7CHe7bSOzRJA96CRm0MyD3azXdjYrprvUsoc3M8pn(PQZE8jvNDBm(jnaTHik5quliI69JyyBOMwha)fS9C5wyAuZwQ1c(RF(s36bQfMb(JtUug8ux9(KDyQuq5te5cSB4THgDNIO3uLiZhVyCsxhJv(1F6pDC(hP1u2FJS1CLVnfFg)Y7pC7bSIHF754kPHdXHg)9pqLJO)XlPVof3HZgUnQVmpc1TI1bi5fAhRvTpSHUHV4)(t4MuJ3ob4MTTknkF3ZG)X(KWhkV6cWtUX(meQxg1RAs(ykPHOm8UiOvFx1HjN)iCRV(4iKeyq(VS7HMJFMY4Y7vLzNxm9vL7L75yPLpLHeSl8IZt3pLCrLCozsNo4C(LWWuyiphzmX4yoL7JGybp2P7zmXkDLCsNU8EvHQLvO738nglFVYMmTFWJpAD8TxXl8PYgGC1FEqG4mrR(5GMqnh2wQ5Wwrn1ChV87d1udGyKAIRN()Vkvo2QRsLMilwcPQsJdfLghiilEMHL26LrbgRbzxRINcFuQo9V6pJxMpbbpV7GEtEH8qtQuJssn0cdxWqbbx11QIgHp6XCR5Mds3CpGn3(WAkRwngNGTYqPivE8XA3hnp(yMU7Gg9tj)UsP0Q73sp1yW6dCerrxsrRrwvaJarMuSUU5IztfEXajRCFYV)DvdDnItTk1NrL66XR03JpA6D(lqqBM5(tpxGiLN10c9pRGbMNOoEaMwqE(vbbdTPLzvzb1pDqNU1pNQxnyYJpEM(d)AG5jt42Lq7KD10HGfi9dlikQ93RdEms2vaikD8BUAq)alahVA7yWgVWkpShblFU1nexWyPzD0uhxx9AlaN26XKbNMEA86qqa1FLwRCthYxTR(y3r7NPNaVl7E7YvpFOfyTwj7XGtdp4rD0uPD4k(Vgp8CIaD9kW7841tRPcSJELLCpLeRyOoUoqip(OUs7RJUH6mcBO(bPtIYlvoONlvL0GjwaFoZWJjh4lNO7rWQzY0z4KH2XIxBvoA1icbd9Q)0fjHEkfWlIqKUv)nk7YPeXYovyvzd6yTk4jACuOe28q1RcCNODS1SuXL6TcHBc(yNR7h2EXtaz5LEkDXNQMGoMuAy)fsJQKcCQkq)60gdXKuiy5bmteNuFDzOAfRQFl3nLv6kUByLdqoBzLN8(00Yst9C6ZUdvrcJGX)kqznSe2QihWr0wP)trpkCCubKeDYKFaGOaVqzkkb92eZ9AqzLEJaL4R16Plh0xRlxdn7YLG)Jgu3IdQb)NQpvqJDtPfx5uNuxFrKoBCnAsezbNP1kQFUOP1yRp0VU6U)0m6wQwYQFonRLueMgjrMR55S7v2Lflil5IspBv8q6GjAADFJK(UElZm6Q4PAuPtcFQssr7PJQZzwoaikdQSlqWWQ58ZuYZREdQ8aDotY)FzY9Lth94JkCGreI6VfVmtAjRLEmOXhqpoztxoD4ZbtMgC2TnKCh8EdEvB(SXOWbUAytKrKDZWC)OZV6bl6YXvw08hEBktsteHx2DWKxWM4ANNNNpjWbjUD0h)aTR6oSrGM6Hp1mK3e6wD5sXZGK6xLp2rmLGFvUFc4ZSGRdAuQQvp(Jpw7qMQD8CY2SOE1L5ouz2PDknnEntvICF93CIwjy7lU6y8S67RQhRaRoiAA3rFLajmzSpJ2VzWKVn8xENEVWFXGGVP2xycfW3EUdh0FgM(L9qBO7)qskUjjfBWfhK)hi0VJSFjOfXsJEfs3kuCJI4sIhQsNlA6J8sIr2PLWQTViKMMibJKRfUy7w1dR7aS1SueJJJ0a3NSQE5xWnqHy3L3a60q3whcjPCoZtr9br)Y(yC9F6UETB1IwzGHtmnyA8rrNrJH9DNYdVce5k8ioBtAUHwZaa7jpVAOb(nMzs33a6uiC5y3eU2sooHWOd7wVNUIxJF9cHgp1B5YlN2DSNg6fg)xyk7Q1SSvZlA0(N48pAyhjYYWRe(63m4ctZ)PXofF8uY3KkzQTGPpM)60vySUA64j0nzOAUgrsf4Jpkl8knYeYkpEMsN(hfCAi2(yig8GV1MVmr7e92RMG7f9LrMr11RyedoXqQ3l3QmdmuLjp(slqVpsrM6RSxXQuXj9RQGkCFFN)xXm)rQYl6E3l4AkpZGtxskEkK3eZsAFAEEhPnJdrhIGD0Ldl38bnImDpt8YzGgUfFIO(SaljEb3vKVKMueNfMpBD4DPzp(Oh9)ng7EaBvtBHmZJSxa2G(MHmAsP)h5r8AjR8oXK6yZNiP))vmdfAytaZVgJs7MAzkJEg4gyQY02fbw)Z7o4fvgfjFLFZzt3t8ssVH707ljQ8OqWMqqIEr4UiXpsPp)WHI84vSA6RK(CipIuNFNA6KbNJxhMKG5Fm7qE4QOmJBZG7OYgmHrzTq0RF)OxNmDyFj1vZank4jremLdFvQGz8O90NH9LRvejDwP3fbQ62VNSuPCjdRGj9eHBYMgzMtn(uXPERh59FKrc94aMRKFO2Edvvct5tPpJtvw11CVUwVtaPtZvvSjciXgWfMYUE1Vku7iILwJj8EIqBQ)ioD1KogFsMaRrg)wjZqZEecFPUrouGS5KhT7SeHmnrmOGl7Er)x21XJSe4I(l7MjeOE9hwjOjbmrsdBCLbClOnihDxP13tfYQlsslfzSfdgJ)AAd8eDeh9d31yc2XK6ZftmqZmJ5u6Lr1mnD4Kw6jhyXOjSzrZdpeJUO9lz(SRBbnKBPpF7LNCal5Dhw(AVVg4a64GeJCElqCHj)EqGYLclW2UbatX7ieMKJzE6a9EOj6PTjJuAnH7Fj4fV7QryPwlRzyulresX4yKc69(SELlA9lEDGBpu9EcL950texlz3itsmuHYGL00oPikCreasGh0adoQ0r7VlsjEkv5HbYOUxqgxMienxYsiWLth5YANl160vSJrjFRNxcP8r86j6rl(tEJ(VR(AVyyDJYsqxf0x3AVYmTsOFKU1F1gAtCunjvtbZMiAEr4rQPY1vArvDC(7j7nqCKKtSSkUsOIuXPObvewD6SRLvQj0C6GMz5td4JYa3hcI9yciIZvZrtvoJgmYj0b8lRcS6aupHi)gxbu1ZX1QdG2fX1HnA3kWX91Zn024lm2ydRrERHkVkW1AuVudzqIr1tnKu6u6GwrPAjBD9uph4IRFWnjTFwg0gGxnq6AdydcZ)k4G6HD3NMvS5bPrqcLDsVgz(i71Oz1jCZJGL7sQUuoyjO2QpDxAcq(GVLNMGIKmN(v)zmM2ZjovJdXS4TBJwfhwGNCl(VEBs6IWePFcZEUPPIP1(helbqEbwuH5IQG9SQjg1XsrtioEVOEbwBo5ZLPNUIjxvJ1KUOPOSjRGSC0kkZ8JHZwbR76BeTwKgjAmvbZQTpagrneZUQYri5nfQd)3qNHyKALZrWLYCaZWKXkRZ5gevF7xTTrbAD38sW)bdvZaHwp2mCtWvVkUKN8MfPmZp9TU0HaVQhk81oITS6yg5V4MUnV0(Us2eXgxsh(H)6oJmS13vvhQXdNsLQaHMQbPflHloLitERvNkTHETG02cbiMc4FmLvCBFhwXlIQJF3X5xxvJB49qokeiuRB1E21ihy6iYfLaERj8r9a1m71aNpLfG9bUDsmLL7QWAwNtJ)6fuqHwOmyMVvsutvkyQ0vovkh(TaWB)sKNOqJMGcU8I(oNkxAH0nSV29WAN(wzNxjhs8tAv0YS0K0Svc)2xEaiK7O1gc07XsjwYjaPSarDH8y7ldi6N(jLdavp2jIA6IK00vvjrZGBW16gaulIaTozKJfuZ6iR8iiprfyx7A057AAScSKQoIRL8I(BI2inNEH4wSWHPemvp5Z(3hwD72iAnB0emceJbPqqMgpLiw6CvmFsPeH0y9VeP8a6e7HwuyDCweHzAC(lDtB6BmM86VIW3IWBXPcpVnFj3gnQM6s7jvDsPjhHnKLTVeCOR(3SNG)rL7KRZNYioQwEwG81IC9E(c1JvHp6Yf6Sp6V7Oj8eTdMQvmFnAjme6cuXrMQpbrDybhQs)qDweF1HFhBNgs29c80zVY7dSIrHiQgZ1YVzqc(Pv9Zc(y3GJXtPfnDNFWhFSRSrYZQFEKXIdqtxdmDlbqfcmSpLApeJ6me49HTXa7YGGG(dlJqt0EIz(z1dDC5nst(u8Q4b4LBPh3WyJxhjIbDPnHIM02Av5U1mfBCZ1CLSsAPOzS7DL34Lx6A4O5S9YHdccmuYidqLhcQD08mSpTFhQMDLNF9lNuNPaSrz2I53oDp6SXxiDp6BH89wJvppClD0gPashnKTDA9c(B(RwUw6g7Fstobp30Q3trMDm6mP0sRKLARotGvGh5stq6IWQuQw8U3s08eDNVQGuwJQUjWMoiG3t17aRPsY)2Ohd)da9yGb6r9NQzB0JHbIus70J)e9Qz8pOpr22x3JVS0t9vAwLiZVy3Sj0PiPw2Papk5gPkyZf47u4tDntDWxNmIbC2tW)MRr44MVF4e6lI6n)Vd]] )


end
