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


    spec:RegisterPack( "Frost DK", 20220221, [[d40hqdqiPk9iqL4sqrvBIO6tQunkiYPGOwfrQ6vGGzrL0TGIkTlu9lqfdJiPJPszzqHNrLstdkkxJiX2avkFtQOQXjvu5CsfkRtQG5jvv3Ji2NuvoOuHyHGqpKkftKivKlcfvSrqLuFeujXijsf1jjsLwjOQxcQKuZuQi7Kkv)euPYqbvQAPsfQEkvmvPkUkOss6RePcJfkYEf1FPQbdCyklgspwKjRIlJSzP8zqz0G0PfwnOss8Aq0Sr52qy3s(TQgUk54sfslxPNty6KUouTDO03LknEIuopvI1lvuMprz)koFl3t25ykLDhdPIbgsfdmUXV1XWadm6yzh1Llk7Czjinyu2Pmeu2bUEFHoaPtWvNDUmxyVDY9KDep(MOSduvVeDaoWbwOqXr5PhbCebcCMPXxP1AkCebIeCYoO4btLUvgn7CmLYUJHuXadPIbg3436y36yU1TzhdxH(B2Xjq4MSd04COkJMDoKiLDKorMcDaWvxbmO6aGR3xOd8W1e6IBRldaJBUoamKkgymWpW7gOwbJed8yUdOJtiES0zamtOyUck91za4cdgnGVna3a1IsmGVnaPBIgGjgqOd48KOURd4IzUmGUeJnGOgW1AjnseFGhZDasN(6UoGeuRkIna4AgjGMwRPd4GVrbBaqCjtHoGVnaNOoRb7fgp7WcHkY9KDEuwO0AA8L)6FwuWY9KD)wUNSdvgkJoziMDoKiTXLgFLDG7)NffSbax)7aG7qzHsRPXxDyaoQTQya3K6aeu6RJyaOu7xAaW9bJz7a(2aGR3xOdi9iiXa(wBaUr6u2jTHsByzhS2ggkJ4BxpkERjgGmzdWsAGL8uricsmG(KmamYowsJVYolH4xbXiHW3nkL2SMDhJCpzhQmugDYqm7K2qPnSSJ4IymVAlmsfCymlfgZBhSwLOb0NKbGXaKpa1yuP82(cvKCrHsCQmugDYowsJVYoWywkmM3oyTkrzn7UBZ9KDOYqz0jdXStAdL2WYoO4TghYGXIcMhHLGgfXxYs6aKpalPbwYtfHiiXa6Bayma5dO3bG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5IcLYA2Dml3t2HkdLrNmeZowsJVYopkluAnLYoPnuAdl7GI3ACidglkyEewcAueFjlPzNKljg5vBHrQi7(TSMDxk5EYouzOm6KHy2jTHsByzhlPbwYtfHiiXaKmGBdq(aWAByOmI32xOEHUbKKp91bpur2XsA8v2PTVq9cDdiPSMDhUL7j7qLHYOtgIzhlPXxzNhLfkTMszN0gkTHLDqXBnoKbJffmpclbnkIVKL0StYLeJ8QTWivKD)wwZU35Z9KDOYqz0jdXStAdL2WYoyTnmugX3xBj)giOSJL04RSd0VllkyEuMj0SMDVZL7j7qLHYOtgIzN0gkTHLDexeJ5vBHrQGdJzPWyE7G1QenG(KmamgG8bS4vK8xFxA5hQfPqhq)daUj1SJL04RSdmMLcJ5TdwRsuwZU3XY9KDOYqz0jdXSJL04RStBFH6f6gqszN0gkTHLDw8ks(RVlT8d1IuOdO)b05LA2j5sIrE1wyKkYUFlRz3Vj1CpzhQmugDYqm7yjn(k78OSqP1uk7K2qPnSSZIx0a6tYaC7aKpaKgqVdaHfLhQvhogqhGmzdi9yPYkLxuAF2VNbit2aspwQSs5q6YgwnaKhGmzdyXlAa9jzay2aKpaewuEOwD4yan7KCjXiVAlmsfz3VL1S73UL7j7qLHYOtgIzN0gkTHLDSKgyjpveIGedOpjdaZgG8b07aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCrHsznRzN0ZoEOKTAUNS73Y9KDOYqz0jdXSZHePnU04RSdCvf0ao4BuWgaCFWy2oGUHcDas3eLSl4aXLmfA2jTHsByzNEhGAmQu(JYcLwtJV4uzOm6ma5dafV14xbJzR)B(2(cLJFna5dafV14PND8qjBvUqTeKdOpjd4MuhG8bG0aqXBn(vWy26)MVTVq5lHWIsmG(haS0zas)aqAa3gaegq6F257w82(cTRllcHVHVUWxYoUmaKhGmzdafV144f0N5IxOlvWuO8Lqyrjgq)daw6mazYgakERXtqTx4rTI4lHWIsmG(haS0zaiNDSKgFLDsqTOe(V5JeL1S7yK7j7qLHYOtgIzNdjsBCPXxzh4oCvehAaFBaW9bJz7aWfKbJgq3qHoaPBIs2fCG4sMcn7K2qPnSStVdqngvk)rzHsRPXxCQmugDgG8bCitH6HScyqv(Ixu7xyeVzmgv(0IlSdTdq(a6DaO4Tg)kymB9FZ32xOC8RbiFaP)zNVBXVcgZw)38T9fkFjewuIb03aUjLbiFainau8wJNE2XdLSv5c1sqoG(KmGBsDaYhasdafV144f0N5IxOlvWuOC8Rbit2aqXBnEcQ9cpQveh)AaipazYgakERXtp74Hs2QCHAjihqFsgWn3oaKZowsJVYojOwuc)38rIYA2D3M7j7qLHYOtgIzN0gkTHLD6DaQXOs5pkluAnn(ItLHYOZaKpGEhWHmfQhYkGbv5lErTFHr8MXyu5tlUWo0oa5dafV14PND8qjBvUqTeKdOpjd4MuhG8b07aqXBn(vWy26)MVTVq54xdq(as)ZoF3IFfmMT(V5B7lu(siSOedOVbGHuZowsJVYojOwuc)38rIYA2Dml3t2HkdLrNmeZohsK24sJVYoW9lHLkDaU5zNbiDMSvhWJL2KDDffSbCW3OGnGRGXSn7K2qPnSSJAmQu(JYcLwtJV4uzOm6ma5dO3bGI3A8RGXS1)nFBFHYXVgG8bG0aqXBnE6zhpuYwLlulb5a6tYaUHzdq(aqAaO4TghVG(mx8cDPcMcLJFnazYgakERXtqTx4rTI44xda5bit2aqXBnE6zhpuYwLlulb5a6tYaU1XgGmzdi9p78Dl(vWy26)MVTVq5lHWIsmG(hGBhG8bGI3A80ZoEOKTkxOwcYb0NKbCdZgaYzhlPXxzNeulkH)B(irznRzNhLfkTMgFL7j7(TCpzhQmugDYqm7CirAJln(k7a3HYcLwtJVgW(QPXxzN0gkTHLDSKgyjpveIGedOpjdWTdq(aWAByOmIVD9O4TMi7yjn(k7SeIFfeJecF3OuAZA2DmY9KDOYqz0jdXStAdL2WYo9oau8wJdzWyrbZJWsqJI44xdq(aqAalErdO)bGXaKjBaQXOs5rYfVASVeCQmugDgG8bGI3A8i5Ixn2xc(siSOedO)balDgG0pamgGmzdi91bpuoEXitaLo(2svN5cNkdLrNbiFainau8wJJxmYeqPJVTu1zUWxcHfLya9payPZaK(bGXaKjBaO4TghVyKjGshFBPQZCHlulb5a6FaUDaipaKZowsJVYoT9fQxOBajL1S7Un3t2HkdLrNmeZoPnuAdl707aqXBnoKbJffmpclbnkIJFna5dyXlAa9jzaUDaYhasdafV14BGG4lHWIsmG(hGBhG8bGI3A8nqqC8Rbit2aSKgyj)5vEBFH6BewAhq)dWsAGL8uricsmaKZowsJVYoq)USOG5rzMqZA2Dml3t2HkdLrNmeZoPnuAdl707aqXBnoKbJffmpclbnkIJFna5dqCrmMxTfgPcomMLcJ5TdwRs0a6tYaWyaYKnGEhakERXHmySOG5ryjOrrC8RbiFainGdHI3A816SFJeXfQLGCa9paPmazYgWHqXBn(AD2VrI4lHWIsmG(haS0zas)aWSbGC2XsA8v2bgZsHX82bRvjkRz3LsUNSdvgkJoziMDsBO0gw2bfV14qgmwuW8iSe0Oi(swshG8biUigZR2cJubVTVqfjxuO0a6Bayma5dO3bG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5IcLYA2D4wUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2bfV14qgmwuW8iSe0Oi(swsZojxsmYR2cJur29Bzn7ENp3t2HkdLrNmeZoPnuAdl7yjnWsEQiebjgGKbCBaYhawBddLr82(c1l0nGK8PVo4HkYowsJVYoT9fQxOBajL1S7DUCpzhQmugDYqm7K2qPnSSdwBddLr891wYVbcAaYhG4IymVAlmsfCOFxwuW8OmtOdOpjdaJSJL04RSd0VllkyEuMj0SMDVJL7j7qLHYOtgIzN0gkTHLDexeJ5vBHrQGdJzPWyE7G1QenG(KmamYowsJVYoWywkmM3oyTkrzn7(nPM7j7qLHYOtgIzhlPXxzN2(c1l0nGKYoPnuAdl707auJrLYnSgZQeuItLHYOZaKpGEhakERXHmySOG5ryjOrrC8Rbit2auJrLYnSgZQeuItLHYOZaKpGEhawBddLr891wYVbcAaYKnaS2ggkJ47RTKFde0aKpGfViUgiiV(EmgqFsgaS0j7KCjXiVAlmsfz3VL1S73UL7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nqqzhlPXxzhOFxwuW8OmtOzn7(nmY9KDOYqz0jdXSJL04RSZJYcLwtPStYLeJ8QTWivKD)wwZA2b9fEnsqgfSCpz3VL7j7qLHYOtgIzhlPXxzNhLfkTMszNKljg5vBHrQi7(TStAdL2WYolEfj)13L2b0VKbG0aWmPmaima1yuP8fVIK3uLkCtJV4uzOm6maPFaszaiNDoKiTXLgFLDG4sMcDaFBaorDwd2lSb0rsAGLgqh)vtJVYA2DmY9KDOYqz0jdXStAdL2WYoyTnmugX3UEu8wtmazYgGL0al5PIqeKya9jzaymazYgWIxrYF9DPDa9pa3IXaKpGfViUgiiV(Emgq)dyXRi5V(U0oa4mGBWTSJL04RSZsi(vqmsi8DJsPnRz3DBUNSdvgkJoziMDsBO0gw2zXRi5V(U0oG(hGBXyaYhWIxexdeKxFpgdO)bS4vK8xFxAhaCgWn4w2XsA8v25qMc1B1XFOK5swZUJz5EYouzOm6KHy2jTHsByzhS2ggkJ47RTKFde0aKpaKgWIxrYF9DPDa9jzayMugGmzdyXlIRbcYRV3TdOFjdaw6mazYgWIxu7xyeFnyK)BEfk5B73zu5tqnexXxCQmugDgGmzdqCrmMxTfgPco0VllkyEuMj0b0NKbGXaKjBaO4TgFdeeFjewuIb0)aC7aqEaYKnGfVIK)67s7a6FaUfJbiFalErCnqqE99ymG(hWIxrYF9DPDaWza3GBzhlPXxzhOFxwuW8OmtOzn7UuY9KDOYqz0jdXStAdL2WYoO4TghYGXIcMhHLGgfXXVgG8biUigZR2cJubVTVqfjxuO0a6Bayma5dO3bG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5IcLYA2D4wUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2bfV14qgmwuW8iSe0Oi(swsZojxsmYR2cJur29Bzn7ENp3t2HkdLrNmeZoPnuAdl7S4vK8xFxAhq)sgaCtQdq(aw8I4AGG867D7a6BaWsNSJL04RSd0Fl)38DJsPnRz37C5EYouzOm6KHy2jTHsByzhXfXyE1wyKk4T9fQi5IcLgqFdaJbiFa9oaS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxuOuwZU3XY9KDOYqz0jdXSJL04RSZJYcLwtPStAdL2WYolEfj)13Lw(HArk0b03aWqkdqMSbS4fX1ab51372b0)aGLozNKljg5vBHrQi7(TSMD)MuZ9KDOYqz0jdXStAdL2WYoyTnmugX3xBj)giOSJL04RSd0VllkyEuMj0SMD)2TCpzhQmugDYqm7K2qPnSSZIxrYF9DPDa9paPi1SJL04RSJTjRiV(7sLM1SMDeQvhBp5EYUFl3t2HkdLrNmeZohsK24sJVYooQvhBpdqefmgH5Q2cJ0bSVAA8v2jTHsByzhS2ggkJ4BxpkERjYowsJVYolH4xbXiHW3nkL2SMDhJCpzhQmugDYqm7K2qPnSSdkERXHmySOG5ryjOrr8LSKMDSKgFLDEuwO0AkL1S7Un3t2HkdLrNmeZoPnuAdl7G12WqzeFFTL8BGGgG8bGI3A8nqq8Lqyrjgq)dWTzhlPXxzhOFxwuW8OmtOzn7oML7j7qLHYOtgIzN0gkTHLDWAByOmI32xOEHUbKKp91bpur2XsA8v2PTVq9cDdiPSMDxk5EYouzOm6KHy2jTHsByzNEhWHmfQhYkGbv5lErTFHr816SFJena5daPbCiu8wJVwN9BKiUqTeKdO)biLbit2aoekERXxRZ(nseFjewuIb0)aGLodq6haMnaKZowsJVYoWywkmM3oyTkrzn7oCl3t2HkdLrNmeZoPnuAdl7K(ND(UfFje)kigje(UrP0YxcHfLya9lzaymaPFaWsNbiFaQXOs5WmfkTrbZl0FrWPYqz0j7yjn(k702xOEHUbKuwZU35Z9KDOYqz0jdXStAdL2WYoyTnmugX3xBj)giOSJL04RSd0VllkyEuMj0SMDVZL7j7qLHYOtgIzN0gkTHLDw8ks(RVlT8d1IuOdO)bG0aUjLbaHbOgJkLV4vK8MQuHBA8fNkdLrNbi9dqkda5SJL04RStBFH6f6gqszn7Ehl3t2HkdLrNmeZoPnuAdl707aqXBnEB)oJk)fotqC8RbiFaQXOs5T97mQ8x4mbXPYqz0zaYKnaS2ggkJ4hYuOc)bN8wsdS0aKpau8wJFitHk8hCIlulb5a6Fay2aKjBaQXOs5WmfkTrbZl0FrWPYqz0zaYhakERXxcXVcIrcHVBukTC8Rbit2aw8ks(RVlT8d1IuOdOVbG0aWqkdacdqngvkFXRi5nvPc304lovgkJodq6hGugaYzhlPXxzNhLfkTMszn7(nPM7j7yjn(k702xOEHUbKu2HkdLrNmeZA29B3Y9KDSKgFLDG(B5)MVBukTzhQmugDYqmRz3VHrUNSJL04RSJTjRiV(7sLMDOYqz0jdXSM1SZHAgotZ9KD)wUNSJL04RSdIOo(2suNrzhQmugDYqmRz3Xi3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzhKga1rXJRl6WJsKwC1qzKVJIBLIJWFiSrIgG8bK(ND(UfpkrAXvdLr(okUvkoc)HWgjIVKDCzaiNDoKiTXLgFLDG7xclv6aexukAbDgGUrbjPIbGsrbBa4c6mGUHcDagU(imnsdGffjYoyT1xgck7iUOu0c641nkijnRz3DBUNSdvgkJoziMD(RSJG0SJL04RSdwBddLrzhSgdNYowsdSKNkcrqIbiza3gG8bG0awloEclvk3ohbpQb03aUjLbit2a6DaRfhpHLkLBNJGtsleQyaiNDWARVmeu2rO(lMvvuWYA2Dml3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzhlPbwYtfHiiXa6tYaWyaYhasdO3bSwC8ewQuUDocojTqOIbit2awloEclvk3ohbNKwiuXaKpaKgWAXXtyPs525i4lHWIsmG(gGugGmzdOfWGQ(LqyrjgqFd4MuhaYda5SdwB9LHGYo25i8lHWIkRz3LsUNSdvgkJoziMD(RSJG0SJL04RSdwBddLrzhSgdNYoO4TgFdeeh)AaYhasdO3bS4f1(fgXxdg5)MxHs(2(Dgv(eudXv8fNkdLrNbit2aw8IA)cJ4RbJ8FZRqjFB)oJkFcQH4k(ItLHYOZaKpGfVIK)67sl)qTif6a6BaDUbGC2bRT(YqqzN91wYVbckRz3HB5EYouzOm6KHy25VYocsZowsJVYoyTnmugLDWAmCk7K(6GhkNw7ejtJcMhL9DhG8bGI3ACATtKmnkyEu23Llulb5aKmamgGmzdi91bpuoEXitaLo(2svN5cNkdLrNbiFaO4TghVyKjGshFBPQZCHVeclkXa6FainayPZaK(bGXaqo7G1wFziOStBFH6f6gqs(0xh8qfzn7ENp3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzNdzkuVvh)HsMlCnsqgfSbiFaPhlvwP8kGbv9nJYoyT1xgck7CitHk8hCYBjnWszn7ENl3t2HkdLrNmeZohsK24sJVYoDKRlMldaUEFHoa4AclTUoaewuQf1aKUjxgqpg7lXaS6maij6AaDCcXVcIrcXaKoIsPDa7Zyrbl7K2qPnSSt6RdEOCclTT9f6aKpa1yuPCyMcL2OG5f6Vi4uzOm6ma5daPb07auJrLYFuwO0AA8fNkdLrNbiFaP)zNVBXVcgZw)38T9fkFjewuIbit2aeK6r)cxW1Gwm6CEm7kna5dqngvk)rzHsRPXxCQmugDgG8b07aqXBn(vWy26)MVTVq54xda5SJL04RSZsi(vqmsi8DJsPnRz37y5EYouzOm6KHy2XsA8v2b63LffmpkZeA2jTHsByzNEhW5vEBFH6BewA5lHWIsma5daPbOgJkLhjkzxCQmugDgGmzdO3bGI3AC0LmfQ)BEruN1G9cJJFna5dqngvkhDjtH6)Mxe1znyVW4uzOm6mazYgGAmQu(JYcLwtJV4uzOm6ma5di9p78Dl(vWy26)MVTVq5lHWIsma5dO3bGI3ACidglkyEewcAueh)AaiNDsUKyKxTfgPIS73YA29Bsn3t2HkdLrNmeZoPnuAdl7GI3A8i5Ixn2xc(siSOedOFjdaw6maPFayma5dqngvkpsU4vJ9LGtLHYOZaKpaXfXyE1wyKk4WywkmM3oyTkrdOpjdaJbiFaina1yuP8irj7ItLHYOZaKjBaQXOs5Olzku)38IOoRb7fgNkdLrNbiFaP)zNVBXrxYuO(V5frDwd2lm(siSOedOVbCtkdqMSbOgJkL)OSqP104lovgkJodq(a6DaO4Tg)kymB9FZ32xOC8RbGC2XsA8v2bgZsHX82bRvjkRz3VDl3t2HkdLrNmeZoPnuAdl7GI3A8i5Ixn2xc(siSOedOFjdaw6maPFayma5dqngvkpsU4vJ9LGtLHYOZaKpaKgGAmQuEKOKDXPYqz0zaYKna1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpGEhakERXrxYuO(V5frDwd2lmo(1aKpG0)SZ3T4Olzku)38IOoRb7fgFjewuIb03aUj1bit2auJrLYFuwO0AA8fNkdLrNbiFa9oau8wJFfmMT(V5B7luo(1aqo7yjn(k702xOEHUbKuwZUFdJCpzhQmugDYqm7K2qPnSSt6XsLvkVcyqvFZObiFahYuOERo(dLmx4AKGmkydq(aoKPq9wD8hkzUWTKgyj)siSOedO)bG0aGLodq6hWnUugaYdq(aqAa9oa1yuP8hLfkTMgFXPYqz0zaYKna1yuP8hLfkTMgFXPYqz0zaYhqVdafV14xbJzR)B(2(cLJFnaKZowsJVYopkluAnLYA29BUn3t2HkdLrNmeZohsK24sJVYoUb6)cAaDKKgFnawi0bO)aw8k7yjn(k7KmgZBjn(YZcHMDyHq9LHGYoPhlvwPISMD)gML7j7qLHYOtgIzhlPXxzNKXyElPXxEwi0SdleQVmeu2zTuymrwZUFtk5EYouzOm6KHy2XsA8v2jzmM3sA8LNfcn7WcH6ldbLD0nkijvK1S73GB5EYouzOm6KHy2XsA8v2jzmM3sA8LNfcn7WcH6ldbLDs)ZoF3sK1S73685EYouzOm6KHy2jTHsByzh1yuP80ZoEOKTkNkdLrNbiFainGEhakERXHmySOG5ryjOrrC8Rbit2auJrLYrxYuO(V5frDwd2lmovgkJoda5biFainGdHI3A816SFJeXfQLGCasgGugGmzdO3bCitH6HScyqv(Ixu7xyeFTo73irda5SJq3iPz3VLDSKgFLDsgJ5TKgF5zHqZoSqO(YqqzN0ZoEOKTAwZUFRZL7j7qLHYOtgIzN0gkTHLDqXBno6sMc1)nViQZAWEHXXVYocDJKMD)w2XsA8v2zXlVL04lpleA2Hfc1xgck7G(cVgjiJcwwZUFRJL7j7qLHYOtgIzN0gkTHLDuJrLYrxYuO(V5frDwd2lmovgkJodq(aqAaP)zNVBXrxYuO(V5frDwd2lm(siSOedO)bCtQda5biFainG1IJNWsLYTZrWJAa9namKYaKjBa9oG1IJNWsLYTZrWjPfcvmazYgq6F257w8RGXS1)nFBFHYxcHfLya9pGBsDaYhWAXXtyPs525i4K0cHkgG8bSwC8ewQuUDocEudO)bCtQda5SJL04RSZIxElPXxEwi0SdleQVmeu2b9f(R)zrblRz3XqQ5EYouzOm6KHy2jTHsByzhu8wJFfmMT(V5B7luo(1aKpa1yuP8hLfkTMgFXPYqz0j7i0nsA29BzhlPXxzNfV8wsJV8SqOzhwiuFziOSZJYcLwtJVYA2DmUL7j7qLHYOtgIzN0gkTHLD6Dacs9OFHl4AqlgDopMDLgG8bOgJkL)OSqP104lovgkJodq(as)ZoF3IFfmMT(V5B7lu(siSOedO)bCtQdq(aqAayTnmugXfQ)IzvffSbit2awloEclvk3ohbNKwiuXaKpG1IJNWsLYTZrWJAa9pGBsDaYKnGEhWAXXtyPs525i4K0cHkgaYzhlPXxzNfV8wsJV8SqOzhwiuFziOSZJYcLwtJV8x)ZIcwwZUJbg5EYouzOm6KHy2jTHsByzhlPbwYtfHiiXa6tYaWi7i0nsA29BzhlPXxzNfV8wsJV8SqOzhwiuFziOSJ9uwZUJHBZ9KDOYqz0jdXSJL04RStYymVL04lpleA2Hfc1xgck7iuRo2EYAwZoP)zNVBjY9KD)wUNSdvgkJoziMDoKiTXLgFLDG7Fn(k7yjn(k7C9A8v2jTHsByzhu8wJFfmMT(V5B7luo(vwZUJrUNSdvgkJoziMDoKiTXLgFLDCZ)SZ3TezN0gkTHLDuJrLYFuwO0AA8fNkdLrNbiFalErdO)ba3gG8bG0aWAByOmIlu)fZQkkydqMSbG12Wqze3ohHFjewuda5biFainG0)SZ3T4xbJzR)B(2(cLVeclkXa6FaszaYhasdi9p78DlEJrcOP1AkFjewuIb03aKYaKpaXJZqJ6WVWfkoJ80IFPXxCQmugDgGmzdO3biECgAuh(fUqXzKNw8ln(ItLHYOZaqEaYKnau8wJFfmMT(V5B7luo(1aqEaYKna0xigG8b0cyqv)siSOedO)bGHuZowsJVYoeIRVlT(fViFxYU(kRz3DBUNSdvgkJoziMDsBO0gw2rngvkhDjtH6)Mxe1znyVW4uzOm6ma5dyXlAa9paPma5dyXRi5V(U0oG(hasdaUj1bG5oGdzkupKvadQYx8IA)cJ4qDrO0g2aK(biLbG5oGfVO2VWi(AiUSs96ALOrlvjItLHYOZaK(biLbG8aKpaKgakERXrxYuO(V5frDwd2lmo(1aKjBaTagu1VeclkXa6Fayi1bGC2XsA8v2HqC9DP1V4f57s21xzn7oML7j7qLHYOtgIzN0gkTHLDuJrLYJeLSlovgkJozhlPXxzhcX13Lw)IxKVlzxFL1S7sj3t2HkdLrNmeZoPnuAdl7OgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG0aWAByOmIlu)fZQkkydqMSbG12Wqze3ohHFjewuda5biFainG0)SZ3T4Olzku)38IOoRb7fgFjewuIbit2as)ZoF3IJUKPq9FZlI6SgSxy8LSJldq(aw8ks(RVlTdOVbifPoaKZowsJVYoxbJzR)B(2(cnRz3HB5EYouzOm6KHy2jTHsByzh1yuP8irj7ItLHYOZaKpGEhakERXVcgZw)38T9fkh)k7yjn(k7CfmMT(V5B7l0SMDVZN7j7qLHYOtgIzN0gkTHLDuJrLYFuwO0AA8fNkdLrNbiFainGfVIK)67s7a6tYaCRugG8b07aqXBnUH(iIY04lplqGYXVgGmzdafV14g6JiktJV8Sabkh)Aaipa5daPbG12WqzexO(lMvvuWgGmzdaRTHHYiUDoc)siSOgaYdq(aqAaQXOs5WmfkTrbZl0FrWPYqz0zaYhakERXxcXVcIrcHVBukTC8Rbit2a6DaQXOs5WmfkTrbZl0FrWPYqz0zaiNDSKgFLDUcgZw)38T9fAwZU35Y9KDOYqz0jdXStAdL2WYoO4Tg)kymB9FZ32xOC8RSJL04RSd6sMc1)nViQZAWEHL1S7DSCpzhQmugDYqm7K2qPnSSJL0al5PIqeKyasgWTbiFaO4Tg)kymB9FZ32xO8Lqyrjgq)daw6ma5dafV14xbJzR)B(2(cLJFna5dO3bOgJkL)OSqP104lovgkJodq(aqAa9oG1IJNWsLYTZrWjPfcvmazYgWAXXtyPs525i4rnG(gGBL6aqEaYKnGwadQ6xcHfLya9pa3MDSKgFLDA7l0UUSie(g(6swZUFtQ5EYouzOm6KHy2jTHsByzhlPbwYtfHiiXa6tYaWyaYhasdafV14xbJzR)B(2(cLJFnazYgWAXXtyPs525i4K0cHkgG8bSwC8ewQuUDocEudOVbK(ND(Uf)kymB9FZ32xO8LqyrjgaegqNFaipa5daPbGI3A8RGXS1)nFBFHYxcHfLya9payPZaKjBaRfhpHLkLBNJGtsleQyaYhWAXXtyPs525i4lHWIsmG(haS0zaiNDSKgFLDA7l0UUSie(g(6swZUF7wUNSdvgkJoziMDsBO0gw2rngvk)rzHsRPXxCQmugDgG8bG0aqXBn(vWy26)MVTVq54xdq(a6DaiSO8qT6WXa6aKjBa9oau8wJFfmMT(V5B7luo(1aKpaewuEOwD4yaDaYhq6F257w8RGXS1)nFBFHYxcHfLyaipa5daPbG0aqXBn(vWy26)MVTVq5lHWIsmG(haS0zaYKnau8wJJxqFMlEHUubtHYXVgG8bGI3AC8c6ZCXl0Lkyku(siSOedO)balDgaYdq(aqAahcfV14R1z)gjIlulb5aKmaPmazYgqVd4qMc1dzfWGQ8fVO2VWi(AD2VrIgaYda5SJL04RStBFH21LfHW3WxxYA29ByK7j7qLHYOtgIzN0gkTHLDuJrLYrxYuO(V5frDwd2lmovgkJodq(aw8ks(RVlTdO)ba3K6aKpGfVOb0VKb42biFainau8wJJUKPq9FZlI6SgSxyC8Rbit2as)ZoF3IJUKPq9FZlI6SgSxy8LqyrjgqFdaZK6aqEaYKnGEhGAmQuo6sMc1)nViQZAWEHXPYqz0zaYhWIxrYF9DPDa9lzaDEPKDSKgFLDG6Y1RqPfrK8xljOkrzn7(n3M7j7qLHYOtgIzN0gkTHLDs)ZoF3IFfmMT(V5B7lu(siSOedOFjdqkzhlPXxzN1cb5pKDYA29BywUNSdvgkJoziMDsBO0gw2XsAGL8uricsmG(KmamgG8bG0aAbmOQFjewuIb0)aC7aKjBa9oau8wJJUKPq9FZlI6SgSxyC8RbiFainGls5WG(4m(siSOedO)balDgGmzdyT44jSuPC7CeCsAHqfdq(awloEclvk3ohbFjewuIb0)aC7aKpG1IJNWsLYTZrWJAa9nGls5WG(4m(siSOeda5bGC2XsA8v2ryPnArkmM)YsAwZUFtk5EYouzOm6KHy2jTHsByzhlPbwYtfHiiXa6BaszaYKnGfVO2VWi(fuY2hXxKGtLHYOt2XsA8v25qMc1B1XFOK5swZA2j9yPYkvK7j7(TCpzhQmugDYqm7CirAJln(k74MhlvwPdOJGgSqdsKDsBO0gw2bPb07auJrLYFuwO0AA8fNkdLrNbit2auJrLYFuwO0AA8fNkdLrNbiFawsdSKNkcrqIb0NKbGXaKpG0)SZ3T4xbJzR)B(2(cLVeclkXaKjBawsdSKNkcrqIbiza3gaYdq(aqAayTnmugXfQ)IzvffSbit2aWAByOmIBNJWVeclQbGC2XsA8v25qMcv4p4uwZUJrUNSdvgkJoziMDsBO0gw2zXRi5V(U0YpulsHoG(gWn3oa5di9p78Dl(vWy26)MVTVq5lHWIsmG(hGBhG8b07auJrLYrxYuO(V5frDwd2lmovgkJodq(aWAByOmIlu)fZQkkyzhlPXxzhrxBrefmpIqOzn7UBZ9KDOYqz0jdXStAdL2WYo9oa1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaS2ggkJ425i8lHWIk7yjn(k7i6AlIOG5recnRz3XSCpzhQmugDYqm7K2qPnSSJAmQuo6sMc1)nViQZAWEHXPYqz0zaYhasdafV14Olzku)38IOoRb7fgh)AaYhasdaRTHHYiUq9xmRQOGna5dyXRi5V(U0YpulsHoG(gaMj1bit2aWAByOmIBNJWVeclQbiFalEfj)13Lw(HArk0b03aGBsDaYKnaS2ggkJ425i8lHWIAaYhWAXXtyPs525i4lHWIsmG(hqhBaYhWAXXtyPs525i4K0cHkgaYdqMSb07aqXBno6sMc1)nViQZAWEHXXVgG8bK(ND(UfhDjtH6)Mxe1znyVW4lHWIsmaKZowsJVYoIU2IikyEeHqZA2DPK7j7qLHYOtgIzN0gkTHLDs)ZoF3IFfmMT(V5B7lu(siSOedO)b42biFayTnmugXfQ)IzvffSbiFaina1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpGfVIK)67s7a6BasrQdq(as)ZoF3IJUKPq9FZlI6SgSxy8Lqyrjgq)daJbit2a6DaQXOs5Olzku)38IOoRb7fgNkdLrNbGC2XsA8v2XqFerzA8LNfiqZA2D4wUNSdvgkJoziMDsBO0gw2bRTHHYiUDoc)siSOYowsJVYog6JiktJV8SabAwZU35Z9KDOYqz0jdXStAdL2WYoyTnmugXfQ)IzvffSbiFainG0)SZ3T4xbJzR)B(2(cLVeclkXa6FaUDaYKna1yuP8irj7ItLHYOZaqo7yjn(k7iGAjizKxHsE8Q7VkuxYA29oxUNSdvgkJoziMDsBO0gw2bRTHHYiUDoc)siSOYowsJVYocOwcsg5vOKhV6(Rc1LSMDVJL7j7qLHYOtgIzN0gkTHLD6DaO4Tg)kymB9FZ32xOC8RbiFa9oau8wJJUKPq9FZlI6SgSxyC8RbiFainaXJZqJ6WVWfkoJ80IFPXxCQmugDgGmzdq84m0OoCSpZ0GrEXZWsLYPYqz0zaiNDIsPDXVuF0YoIhNHg1HJ9zMgmYlEgwQ0StukTl(L6deiOtykLDULDSKgFLDAmsanTwtZorP0U4xQhg7rnw25wwZA25AP0Ja10Cpz3VL7j7qLHYOtgIzN)k7iinAzN0gkTHLD0nkijLR34qnHhxqEu8wBaYhasdO3bOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG0a0nkijLR34P)zNVBXp4RPXxdaZpG0)SZ3T4xbJzR)B(2(cLFWxtJVgGKbi1bG8aKjBaQXOs5Olzku)38IOoRb7fgNkdLrNbiFainG0)SZ3T4Olzku)38IOoRb7fg)GVMgFnam)a0nkijLR34P)zNVBXp4RPXxdqYaK6aqEaYKna1yuP8irj7ItLHYOZaqo7CirAJln(k7G5G1y4MsIbydq3OGKuXas)ZoF3Y1bCcSXHoda1LbCfmMTd4BdOTVqhWVdaDjtHoGVnaruN1G9c7UyaP)zNVBXhG0TnGqVlgawJHtdaQjgq9dyjewuhAhWsk(wd4MRdGycAalP4BnaPYLcp7G1y4u25w2XsA8v2bRTHHYOSdwJHtEIjOSJu5sj7G1wFziOSJUrbjP(BEHlvkRz3Xi3t2HkdLrNmeZo)v2rqA0YowsJVYoyTnmugLDWARVmeu2r3OGKupgEHlvk7K2qPnSSJUrbjPCfdout4XfKhfV1gG8bG0a6DaQXOs5Olzku)38IOoRb7fgNkdLrNbiFainaDJcss5kg80)SZ3T4h8104RbG5hq6F257w8RGXS1)nFBFHYp4RPXxdqYaK6aqEaYKna1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaKgq6F257wC0LmfQ)BEruN1G9cJFWxtJVgaMFa6gfKKYvm4P)zNVBXp4RPXxdqYaK6aqEaYKna1yuP8irj7ItLHYOZaqo7G1y4KNyck7ivUuYoyngoLDUL1S7Un3t2HkdLrNmeZo)v2rqA0YoPnuAdl707a0nkijLR34qnHhxqEu8wBaYhGUrbjPCfdout4XfKhfV1gGmzdq3OGKuUIbhQj84cYJI3Adq(aqAainaDJcss5kg80)SZ3T4h8104RbaNbOBuqskxXGJI3A(d(AA81aqEas)aqAa34szaqya6gfKKYvm4qnHhfV14cDPcMcDaipaPFainaS2ggkJ46gfKK6XWlCPsda5bG8a6BainaKgGUrbjPC9gp9p78Dl(bFnn(AaWza6gfKKY1BCu8wZFWxtJVgaYdq6hasd4gxkdacdq3OGKuUEJd1eEu8wJl0Lkyk0bG8aK(bG0aWAByOmIRBuqsQ)Mx4sLgaYda5SZHePnU04RSdMJqdeMsIbydq3OGKuXaWAmCAaOUmG0J4Y2OGnafknG0)SZ3TgW3gGcLgGUrbjPUoGtGno0zaOUmafknGd(AA81a(2auO0aqXBTbe6aU2hBCibFasNnXaSbi0Lkyk0bG4prlODa6paybwAa2aGgWGs7aU243qDza6paHUubtHoaDJcssfUoatmGUeJnatmaBai(t0cAhq73beTbydq3OGK0b0nySb87a6gm2aQxhGWLknGUHcDaP)zNVBj4zhSgdNYoyKDSKgFLDWAByOmk7G1y4KNyck7Cl7G1wFziOSJUrbjP(Rn(nuxYA2Dml3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzh1yuPCyMcL2OG5f6Vi4uzOm6mazYgq6RdEOCclTT9fkNkdLrNbit2aw8IA)cJ4OHgfmF6zhovgkJozhS26ldbLD2UEu8wtK1S7sj3t2XsA8v2PXib00Ann7qLHYOtgIznRzN1sHXe5EYUFl3t2HkdLrNmeZohsK24sJVYoDClfgBaDe0GfAqIStAdL2WYoO4Tg)kymB9FZ32xOC8RSJL04RSdk7)JVHVUK1S7yK7j7qLHYOtgIzN0gkTHLDqXBn(vWy26)MVTVq54xzhlPXxzhuAf0czuWYA2D3M7j7qLHYOtgIzN0gkTHLDqAa9oau8wJFfmMT(V5B7luo(1aKpalPbwYtfHiiXa6tYaWyaipazYgqVdafV14xbJzR)B(2(cLJFna5daPbS4fXpulsHoG(KmaPma5dyXRi5V(U0YpulsHoG(Kma4MuhaYzhlPXxzhBtwr(lCMGYA2Dml3t2HkdLrNmeZoPnuAdl7GI3A8RGXS1)nFBFHYXVYowsJVYoSaguv4HRc(bgcQ0SMDxk5EYouzOm6KHy2jTHsByzhu8wJFfmMT(V5B7luo(1aKpau8wJtiU(U06x8I8Dj76lo(v2XsA8v2XQej01y(KXyzn7oCl3t2HkdLrNmeZoPnuAdl7GI3A8RGXS1)nFBFHYxcHfLya9lzaDUbiFaO4Tg)kymB9FZ32xOC8RbiFaO4TgNqC9DP1V4f57s21xC8RSJL04RStlwcL9)jRz3785EYouzOm6KHy2jTHsByzhu8wJFfmMT(V5B7luo(1aKpalPbwYtfHiiXaKmGBdq(aqAaO4Tg)kymB9FZ32xO8Lqyrjgq)dqkdq(auJrLYtp74Hs2QCQmugDgGmzdO3bOgJkLNE2XdLSv5uzOm6ma5dafV14xbJzR)B(2(cLVeclkXa6FaUDaiNDSKgFLDqny(V51nsqkYAwZo6gfKKkY9KD)wUNSdvgkJoziMDoKiTXLgFLD6zJcssfzNYqqzNOePfxnug57O4wP4i8hcBKOStAdL2WYo9oa1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpau8wJFfmMT(V5B7luo(1aKpau8wJtiU(U06x8I8Dj76lo(1aKjBaQXOs5Olzku)38IOoRb7fgNkdLrNbiFainaKgakERXVcgZw)38T9fkh)AaYhq6F257wC0LmfQ)BEruN1G9cJVKDCzaipazYgasdafV14xbJzR)B(2(cLJFna5daPbG0aAbmOQFjewuIbG5oG0)SZ3T4Olzku)38IOoRb7fgFjewuIbG8a6FayCBaipaKhaYdqMSbG(cXaKpGwadQ6xcHfLya9pamUnazYgWHmfQhYkGbv5NqyOmYhD0JNKgLWvAasgGuhG8bO2cJuUgiiV((RK6XqQdO)biLSJL04RStuI0IRgkJ8DuCRuCe(dHnsuwZUJrUNSdvgkJoziMDoKiTXLgFLD6bknaDJcsshq3qHoafknaObmOKqhaj0aHP0zayngo56a6gm2aqPbGlOZaAXk0by1zaxwS0zaDdf6aG7dgZ2b8TbaxVVq5zN0gkTHLD6DayTnmugXfxukAbD86gfKKoa5dafV14xbJzR)B(2(cLJFna5daPb07auJrLYJeLSlovgkJodqMSbOgJkLhjkzxCQmugDgG8bGI3A8RGXS1)nFBFHYxcHfLya9jza3K6aqEaYhasdO3bOBuqskxXGd1e(0)SZ3TgGmzdq3OGKuUIbp9p78Dl(siSOedqMSbG12Wqzex3OGKu)1g)gQldqYaUnaKhGmzdq3OGKuUEJJI3A(d(AA81a6tYaAbmOQFjewuISJL04RSJUrbjP3YA2D3M7j7qLHYOtgIzN0gkTHLD6DayTnmugXfxukAbD86gfKKoa5dafV14xbJzR)B(2(cLJFna5daPb07auJrLYJeLSlovgkJodqMSbOgJkLhjkzxCQmugDgG8bGI3A8RGXS1)nFBFHYxcHfLya9jza3K6aqEaYhasdO3bOBuqskxVXHAcF6F257wdqMSbOBuqskxVXt)ZoF3IVeclkXaKjBayTnmugX1nkij1FTXVH6YaKmamgaYdqMSbOBuqskxXGJI3A(d(AA81a6tYaAbmOQFjewuISJL04RSJUrbjPyK1S7ywUNSdvgkJoziMDSKgFLD0nkij9w2rWEn7OBuqs6TStAdL2WYo9oaS2ggkJ4IlkfTGoEDJcsshG8bG0a6Da6gfKKY1BCOMWJlipkERna5daPbOBuqskxXGN(ND(UfFjewuIbit2a6Da6gfKKYvm4qnHhxqEu8wBaipazYgq6F257w8RGXS1)nFBFHYxcHfLya9namK6aqo7CirAJln(k7iDBd4lMld4lAaFnaCbnaDJcsshW1(yJdjgGnau8wZ1bGlObOqPb8kuAhWxdi9p78Dl(aG72beTbuuOqPDa6gfKKoGR9XghsmaBaO4TMRdaxqda9vOd4RbK(ND(UfpRz3LsUNSdvgkJoziMDSKgFLD0nkijfJStAdL2WYo9oaS2ggkJ4IlkfTGoEDJcsshG8bG0a6Da6gfKKYvm4qnHhxqEu8wBaYhasdq3OGKuUEJN(ND(UfFjewuIbit2a6Da6gfKKY1BCOMWJlipkERnaKhGmzdi9p78Dl(vWy26)MVTVq5lHWIsmG(gagsDaiNDeSxZo6gfKKIrwZA2b9f(R)zrbl3t29B5EYouzOm6KHy25qI0gxA8v2bIlzk0b8Tb4e1znyVWgW1)SOGnG9vtJVgqhgGqTvfd4MufdaLA)sdaIVZacXamSwWmugLDsBO0gw2XsAGL8uricsmG(KmamgGmzdaRTHHYi(21JI3AISJL04RSZsi(vqmsi8DJsPnRz3Xi3t2HkdLrNmeZowsJVYopkluAnLYoPnuAdl7GI3ACidglkyEewcAueFjlPdq(as)ZoF3IFfmMT(V5B7lu(siSOedOVb42StYLeJ8QTWivKD)wwZU72CpzhQmugDYqm7K2qPnSSdwBddLr891wYVbck7yjn(k7a97YIcMhLzcnRz3XSCpzhQmugDYqm7K2qPnSSdkERXHmySOG5ryjOrr8LSKoa5dyXRi5V(U0YpulsHoG(gasd4MugaegGAmQu(IxrYBQsfUPXxCQmugDgG0paPmaKhG8biUigZR2cJubVTVqfjxuO0a6Bayma5dO3bG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5IcLYA2DPK7j7qLHYOtgIzN0gkTHLDw8ks(RVlT8d1IuOdOpjdaPb4wPmaima1yuP8fVIK3uLkCtJV4uzOm6maPFaszaipa5dqCrmMxTfgPcEBFHksUOqPb03aWyaYhqVdaRTHHYi(HmfQWFWjVL0alLDSKgFLDA7lurYffkL1S7WTCpzhQmugDYqm7yjn(k78OSqP1uk7K2qPnSSZIxrYF9DPLFOwKcDa9jzayiLStYLeJ8QTWivKD)wwZU35Z9KDOYqz0jdXStAdL2WYolEfj)13Lw(HArk0b0)aWqQdq(aexeJ5vBHrQGdJzPWyE7G1QenG(KmamgG8bK(ND(Uf)kymB9FZ32xO8LqyrjgqFdqkzhlPXxzhymlfgZBhSwLOSMDVZL7j7qLHYOtgIzhlPXxzN2(c1l0nGKYoPnuAdl7S4vK8xFxA5hQfPqhq)dadPoa5di9p78Dl(vWy26)MVTVq5lHWIsmG(gGuYojxsmYR2cJur29Bzn7Ehl3t2HkdLrNmeZoPnuAdl7K(ND(Uf)kymB9FZ32xO8LqyrjgqFdyXlIRbcYRVhZgG8bS4vK8xFxA5hQfPqhq)daZK6aKpaXfXyE1wyKk4WywkmM3oyTkrdOpjdaJSJL04RSdmMLcJ5TdwRsuwZUFtQ5EYouzOm6KHy2XsA8v2PTVq9cDdiPStAdL2WYoP)zNVBXVcgZw)38T9fkFjewuIb03aw8I4AGG867XSbiFalEfj)13Lw(HArk0b0)aWmPMDsUKyKxTfgPIS73YAwZo2t5EYUFl3t2HkdLrNmeZohsK24sJVYoDKhZzaD8xnn(k7yjn(k7SeIFfeJecF3OuAZA2DmY9KDOYqz0jdXStAdL2WYoQXOs5T9fQi5IcL4uzOm6KDSKgFLDGXSuymVDWAvIYA2D3M7j7qLHYOtgIzN0gkTHLDqXBnoKbJffmpclbnkIVKL0biFa9oaS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxuOuwZUJz5EYouzOm6KHy2jTHsByzhS2ggkJ47RTKFde0aKpa1yuPCdRXSkbL4uzOm6KDSKgFLDG(DzrbZJYmHM1S7sj3t2HkdLrNmeZoPnuAdl707aqXBn(giio(1aKpalPbwYtfHiiXa6xYaC7aKjBawsdSKNkcrqIb03aCB2XsA8v2bgZsHX82bRvjkRz3HB5EYouzOm6KHy2XsA8v2PTVq9cDdiPStYLeJ8QTWivKD)w2jTHsByzN0)SZ3T4lH4xbXiHW3nkLw(siSOedOFjdaJbi9daw6ma5dqngvkhMPqPnkyEH(lcovgkJozNdjsBCPXxzh46FrGZSina76AFlbDa6pG0sMsdWgWLGWp)aU243qDzaQTWiDaSqOdO97aSRlMlrbBaR1z)gjAarna7PSMDVZN7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nqqzhlPXxzhOFxwuW8OmtOzn7ENl3t2HkdLrNmeZoPnuAdl7GI3ACyMcL2OG5f6Vi44xdq(aSKgyjpveIGedOVbGXaKpGEhawBddLr8dzkuH)GtElPbwk7yjn(k702xOIKlkukRz37y5EYouzOm6KHy2jTHsByzhS2ggkJ4hYuOc)bN8wsdS0aKpau8wJFitHk8hCIlulb5a6Fay2aKjBaO4TghMPqPnkyEH(lco(v2XsA8v25rzHsRPuwZUFtQ5EYouzOm6KHy2XsA8v2PTVq9cDdiPStAdL2WYolEfj)13Lw(HArk0b0)aqAa3KYaGWauJrLYx8ksEtvQWnn(ItLHYOZaK(biLbGC2j5sIrE1wyKkYUFlRz3VDl3t2HkdLrNmeZoPnuAdl707aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCrHszn7(nmY9KDOYqz0jdXSJL04RSZJYcLwtPStAdL2WYolEfj)13Lw(HArk0b03aqAayiLbaHbOgJkLV4vK8MQuHBA8fNkdLrNbi9dqkda5StYLeJ8QTWivKD)wwZUFZT5EYowsJVYoWywkmM3oyTkrzhQmugDYqmRz3VHz5EYowsJVYoT9fQi5IcLYouzOm6KHywZUFtk5EYouzOm6KHy2XsA8v2PTVq9cDdiPStYLeJ8QTWivKD)wwZUFdUL7j7yjn(k7a93Y)nF3OuAZouzOm6KHywZUFRZN7j7yjn(k7yBYkYR)UuPzhQmugDYqmRznRzhS0kIVYUJHuXadPIXnmYoDTTIcMi7iD0r64UlDDhUshgWa6bknGaX1V6aA)oG7pkluAnn(YF9plky3hWsDu8yPZaepcAagU(imLodib1kyKGpW3POObGrhgGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9by6aWCG760aq6M0qMpWpWlD0r64UlDDhUshgWa6bknGaX1V6aA)oG7PND8qjB17dyPokES0zaIhbnadxFeMsNbKGAfmsWh47uu0aU1Hb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtAiZh47uu0aWOddWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aq6M0qMpW3POOb42oma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBsdz(aFNIIgaM1Hb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtAiZh4h4Lo6iDC3LUUdxPddya9aLgqG46xDaTFhW9hLfkTMgFDFal1rXJLodq8iOby46JWu6mGeuRGrc(aFNIIgagDyaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KgY8b(offnam6WaCZxyPvPZaUN(6Ghkht3hG(d4E6RdEOCmXPYqz05(aq6M0qMpW3POObCtQDyaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3hasyinK5d8d8shDKoU7sx3HR0HbmGEGsdiqC9RoG2Vd4o6l8AKGmky3hWsDu8yPZaepcAagU(imLodib1kyKGpW3POObCRddWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aq6M0qMpW3POObGrhgGB(clTkDgGtGWndq4sPM0gaMFa6pGoHBd4eydr81a(lAn93bGeCqEaiDtAiZh47uu0aCBhgGB(clTkDgGtGWndq4sPM0gaMFa6pGoHBd4eydr81a(lAn93bGeCqEaiDtAiZh47uu0aWSoma38fwAv6maNaHBgGWLsnPnam)a0FaDc3gWjWgI4Rb8x0A6Vdaj4G8aq6M0qMpW3POObGzDyaU5lS0Q0za3x8IA)cJ4y6(a0Fa3x8IA)cJ4yItLHYOZ9bG0nPHmFGFGx6OJ0XDx66oCLomGb0duAabIRF1b0(Da3tpwQSsf3hWsDu8yPZaepcAagU(imLodib1kyKGpW3POObCRddWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aqcdPHmFGVtrrdaJoma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBsdz(aFNIIgGB7WaCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaKUjnK5d8DkkAaywhgGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bG0nPHmFGVtrrdqkDyaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3hasyinK5d8DkkAaD(oma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBsdz(aFNIIgqhRddWnFHLwLod4U4XzOrD4y6(a0Fa3fpodnQdhtCQmugDUpaKWqAiZh4h4Lo6iDC3LUUdxPddya9aLgqG46xDaTFhWDHA1X2Z9bSuhfpw6maXJGgGHRpctPZasqTcgj4d8DkkAaWToma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7dW0bG5a31PbG0nPHmFGVtrrdOZ1Hb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtAiZh47uu0a6yDyaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3hasUvAiZh4h4Lo6iDC3LUUdxPddya9aLgqG46xDaTFhWD0x4V(NffS7dyPokES0zaIhbnadxFeMsNbKGAfmsWh47uu0aWSoma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBsdz(aFNIIgGu6WaCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaKUjnK5d8d8shDKoU7sx3HR0HbmGEGsdiqC9RoG2Vd4(1sPhbQP3hWsDu8yPZaepcAagU(imLodib1kyKGpW3POObCRddWnFHLwLodWjq4MbiCPutAdaZJ5hG(dOt42aq8hCgUya)fTM(7aqcZJ8aqcdPHmFGVtrrd4whgGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bGKBLgY8b(offnGBDyaU5lS0Q0za31nkijLFJJP7dq)bCx3OGKuUEJJP7daj3knK5d8DkkAay0Hb4MVWsRsNb4eiCZaeUuQjTbG5X8dq)b0jCBai(dodxmG)Iwt)DaiH5rEaiHH0qMpW3POObGrhgGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bGKBLgY8b(offnam6WaCZxyPvPZaURBuqskhdoMUpa9hWDDJcss5kgCmDFai5wPHmFGVtrrdWTDyaU5lS0Q0zaobc3maHlLAsBay(bO)a6eUnGtGneXxd4VO10FhasWb5bGegsdz(aFNIIgGB7WaCZxyPvPZaURBuqsk)ght3hG(d4UUrbjPC9ght3hasyM0qMpW3POOb42oma38fwAv6mG76gfKKYXGJP7dq)bCx3OGKuUIbht3hassrAiZh47uu0aWSoma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBsdz(aFNIIgaM1Hb4MVWsRsNbCFXlQ9lmIJP7dq)bCFXlQ9lmIJjovgkJo3hGPdaZbURtdaPBsdz(aFNIIgaM1Hb4MVWsRsNbCp91bpuoMUpa9hW90xh8q5yItLHYOZ9bG0nPHmFGFGx6OJ0XDx66oCLomGb0duAabIRF1b0(Da3t)ZoF3sCFal1rXJLodq8iOby46JWu6mGeuRGrc(aFNIIgagDyaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KgY8b(offnam6WaCZxyPvPZaUlECgAuhoMUpa9hWDXJZqJ6WXeNkdLrN7dajmKgY8b(offna32Hb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtAiZh47uu0aCBhgGB(clTkDgW9fVO2VWioMUpa9hW9fVO2VWioM4uzOm6CFaiDtAiZh47uu0aWSoma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7dW0bG5a31PbG0nPHmFGVtrrdqkDyaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KgY8b(offna4whgGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bG0nPHmFGVtrrdOZ3Hb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtAiZh47uu0a6yDyaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KgY8b(offnGB36WaCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaKUjnK5d8DkkAa3WOddWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aqcdPHmFGVtrrd4Mu6WaCZxyPvPZaUV4f1(fgXX09bO)aUV4f1(fgXXeNkdLrN7dW0bG5a31PbG0nPHmFGFGx6OJ0XDx66oCLomGb0duAabIRF1b0(Da31nkijvCFal1rXJLodq8iOby46JWu6mGeuRGrc(aFNIIgWToma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7dajmKgY8b(offnam6WaCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaKWqAiZh47uu0aWOddWnFHLwLod4UUrbjP8BCmDFa6pG76gfKKY1BCmDFaiDtAiZh47uu0aWOddWnFHLwLod4UUrbjPCm4y6(a0Fa31nkijLRyWX09bGegsdz(aFNIIgGB7WaCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaKWqAiZh47uu0aCBhgGB(clTkDgWDDJcss534y6(a0Fa31nkijLR34y6(aqcdPHmFGVtrrdWTDyaU5lS0Q0za31nkijLJbht3hG(d4UUrbjPCfdoMUpaKUjnK5d8DkkAaywhgGB(clTkDgWDDJcss534y6(a0Fa31nkijLR34y6(aq6M0qMpW3POObGzDyaU5lS0Q0za31nkijLJbht3hG(d4UUrbjPCfdoMUpaKWqAiZh47uu0aKshgGB(clTkDgWDDJcss534y6(a0Fa31nkijLR34y6(aqcdPHmFGVtrrdqkDyaU5lS0Q0za31nkijLJbht3hG(d4UUrbjPCfdoMUpaKUjnK5d8d8shDKoU7sx3HR0HbmGEGsdiqC9RoG2Vd4(HAgotVpGL6O4XsNbiEe0amC9rykDgqcQvWibFGVtrrdqkDyaU5lS0Q0za3x8IA)cJ4y6(a0Fa3x8IA)cJ4yItLHYOZ9bGegsdz(aFNIIgaCRddWnFHLwLod4E6RdEOCmDFa6pG7PVo4HYXeNkdLrN7daPBsdz(aFNIIgqNRddWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aqYTsdz(aFNIIgqhRddWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aqYTsdz(aFNIIgWnP2Hb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiHzsdz(aFNIIgWTBDyaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3hasyM0qMpW3POObCdJoma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7dajmKgY8b(offnGBD(oma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7dajmKgY8b(offnGBDSoma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBsdz(aFNIIgagsTddWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(amDayoWDDAaiDtAiZh47uu0aW4whgGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bG0nPHmFGFGx6OJ0XDx66oCLomGb0duAabIRF1b0(Da3TNUpGL6O4XsNbiEe0amC9rykDgqcQvWibFGVtrrdaJoma38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7dW0bG5a31PbG0nPHmFGVtrrdaZ6WaCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpathaMdCxNgas3KgY8b(offna4whgGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9by6aWCG760aq6M0qMpW3POObCtQDyaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KgY8b(offnGBy0Hb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtAiZh4h4LUiU(vPZaU52byjn(AaSqOc(aF2rCrPS7yiLBzNR9BbJYoWf4YaKorMcDaWvxbmO6aGR3xOd8Wf4YaGRj0f3wxgag3CDayivmWyGFGhUaxgGBGAfmsmWdxGldaZDaDCcXJLodGzcfZvqPVodaxyWOb8Tb4gOwuIb8TbiDt0amXacDaNNe1DDaxmZLb0LySbe1aUwlPrI4d8Wf4YaWChG0PVURdib1QIydaUMrcOP1A6ao4BuWgaexYuOd4BdWjQZAWEHXh4h4HldaZbRXWnLedWgGUrbjPIbK(ND(ULRd4eyJdDgaQld4kymBhW3gqBFHoGFha6sMcDaFBaIOoRb7f2DXas)ZoF3IpaPBBaHExmaSgdNgautmG6hWsiSOo0oGLu8TgWnxhaXe0awsX3AasLlf(aVL04lb)AP0Ja1uiiboyTnmug5Aziij6gfKK6V5fUujx)ljcsJMRyngoj5MRyngo5jMGKivUuCn91j04lj6gfKKYVXHAcpUG8O4TMCK6vngvkhDjtH6)Mxe1znyVWKJKUrbjP8B80)SZ3T4h8104lmpMp9p78Dl(vWy26)MVTVq5h8104ljsfzzYuJrLYrxYuO(V5frDwd2lm5iL(ND(UfhDjtH6)Mxe1znyVW4h8104lmpMx3OGKu(nE6F257w8d(AA8LePISmzQXOs5rIs2fYd8wsJVe8RLspcutHGe4G12WqzKRLHGKOBuqsQhdVWLk56FjrqA0CfRXWjj3CfRXWjpXeKePYLIRPVoHgFjr3OGKuogCOMWJlipkERjhPEvJrLYrxYuO(V5frDwd2lm5iPBuqskhdE6F257w8d(AA8fMhZN(ND(Uf)kymB9FZ32xO8d(AA8LePISmzQXOs5Olzku)38IOoRb7fMCKs)ZoF3IJUKPq9FZlI6SgSxy8d(AA8fMhZRBuqskhdE6F257w8d(AA8LePISmzQXOs5rIs2fYd8WLbG5i0aHPKya2a0nkijvmaSgdNgaQldi9iUSnkydqHsdi9p78DRb8TbOqPbOBuqsQRd4eyJdDgaQldqHsd4GVMgFnGVnafknau8wBaHoGR9XghsWhG0ztmaBacDPcMcDai(t0cAhG(dawGLgGnaObmO0oGRn(nuxgG(dqOlvWuOdq3OGKuHRdWedOlXydWedWgaI)eTG2b0(DarBa2a0nkijDaDdgBa)oGUbJnG61biCPsdOBOqhq6F257wc(aVL04lb)AP0Ja1uiiboyTnmug5Aziij6gfKK6V243qDX1)sIG0O5kwJHtsWWvSgdN8etqsU5A6RtOXxs6v3OGKu(nout4XfKhfV1KRBuqskhdout4XfKhfV1Kjt3OGKuogCOMWJlipkERjhjK0nkijLJbp9p78Dl(bFnn(cZRBuqskhdokER5p4RPXxil9iDJlfiOBuqskhdout4rXBnUqxQGPqrw6rcRTHHYiUUrbjPEm8cxQeYi3hsiPBuqsk)gp9p78Dl(bFnn(cZRBuqsk)ghfV18h8104lKLEKUXLce0nkijLFJd1eEu8wJl0LkykuKLEKWAByOmIRBuqsQ)Mx4sLqg5bElPXxc(1sPhbQPqqcCWAByOmY1Yqqs2UEu8wt4kwJHtsuJrLYHzkuAJcMxO)IqMS0xh8q5ewAB7luzYw8IA)cJ4OHgfmF6zNbElPXxc(1sPhbQPqqcCAmsanTwth4h4HlWLbG5inkHR0zaewADzaAGGgGcLgGL0FhqigGH1cMHYi(aVL04lHeerD8TLOoJg4HldaUFjSuPdqCrPOf0za6gfKKkgakffSbGlOZa6gk0by46JW0inawuKyG3sA8LacsGdwBddLrUwgcsI4IsrlOJx3OGKuxXAmCscsuhfpUUOdpkrAXvdLr(okUvkoc)HWgjsE6F257w8OePfxnug57O4wP4i8hcBKi(s2XfKh4TKgFjGGe4G12WqzKRLHGKiu)fZQkkyUI1y4KelPbwYtfHiiHKBYrAT44jSuPC7Ce8O67MuKjR31IJNWsLYTZrWjPfcvG8aVL04lbeKahS2ggkJCTmeKe7Ce(Lqyr5kwJHtsSKgyjpveIGe9jbd5i17AXXtyPs525i4K0cHkKjBT44jSuPC7CeCsAHqfYrAT44jSuPC7Ce8Lqyrj6tkYK1cyqv)siSOe9DtQiJ8aVL04lbeKahS2ggkJCTmeKK91wYVbcYvSgdNKGI3A8nqqC8l5i17Ixu7xyeFnyK)BEfk5B73zu5tqnexXxYKT4f1(fgXxdg5)MxHs(2(Dgv(eudXv8L8fVIK)67sl)qTifAFDoKh4TKgFjGGe4G12WqzKRLHGK02xOEHUbKKp91bpuHRyngojj91bpuoT2jsMgfmpk77khfV140ANizAuW8OSVlxOwcsjyitw6RdEOC8IrMakD8TLQoZf5O4TghVyKjGshFBPQZCHVeclkr)iblDKEmqEG3sA8LacsGdwBddLrUwgcsYHmfQWFWjVL0al5kwJHtsoKPq9wD8hkzUW1ibzuWKNESuzLYRagu13mAGhUmGoY1fZLbaxVVqhaCnHLwxhaclk1IAas3KldOhJ9LyawDgaKeDnGooH4xbXiHyashrP0oG9zSOGnWBjn(sabjWzje)kigje(UrP06A0KK(6GhkNWsBBFHkxngvkhMPqPnkyEH(lc5i1RAmQu(JYcLwtJVKN(ND(Uf)kymB9FZ32xO8LqyrjKjtqQh9lCbxdAXOZ5XSRKC1yuP8hLfkTMgFjVxu8wJFfmMT(V5B7luo(fYd8wsJVeqqcCG(DzrbZJYmH6AYLeJ8QTWivi5MRrtsVNx5T9fQVryPLVeclkHCKuJrLYJeLSlzY6ffV14Olzku)38IOoRb7fgh)sUAmQuo6sMc1)nViQZAWEHjtMAmQu(JYcLwtJVKN(ND(Uf)kymB9FZ32xO8LqyrjK3lkERXHmySOG5ryjOrrC8lKh4TKgFjGGe4aJzPWyE7G1Qe5A0KGI3A8i5Ixn2xc(siSOe9lbw6i9yixngvkpsU4vJ9LqU4IymVAlmsfCymlfgZBhSwLO(KGHCKuJrLYJeLSlzYuJrLYrxYuO(V5frDwd2lm5P)zNVBXrxYuO(V5frDwd2lm(siSOe9DtkYKPgJkL)OSqP104l59II3A8RGXS1)nFBFHYXVqEG3sA8LacsGtBFH6f6gqsUgnjO4TgpsU4vJ9LGVeclkr)sGLospgYvJrLYJKlE1yFjKJKAmQuEKOKDjtMAmQuo6sMc1)nViQZAWEHjVxu8wJJUKPq9FZlI6SgSxyC8l5P)zNVBXrxYuO(V5frDwd2lm(siSOe9DtQYKPgJkL)OSqP104l59II3A8RGXS1)nFBFHYXVqEG3sA8LacsGZJYcLwtjxJMK0JLkRuEfWGQ(MrYpKPq9wD8hkzUW1ibzuWKFitH6T64puYCHBjnWs(Lqyrj6hjyPJ0FJlfKLJuVQXOs5pkluAnn(sMm1yuP8hLfkTMgFjVxu8wJFfmMT(V5B7luo(fYd8WLb4gO)lOb0rsA81ayHqhG(dyXRbElPXxciibojJX8wsJV8SqOUwgcss6XsLvQyG3sA8LacsGtYymVL04lpleQRLHGKSwkmMyG3sA8LacsGtYymVL04lpleQRLHGKOBuqsQyG3sA8LacsGtYymVL04lpleQRLHGKK(ND(ULyG3sA8LacsGtYymVL04lpleQRLHGKKE2XdLSvDvOBKuj3CnAsuJrLYtp74Hs2QYrQxu8wJdzWyrbZJWsqJI44xYKPgJkLJUKPq9FZlI6SgSxyilhPdHI3A816SFJeXfQLGuIuKjR3dzkupKvadQYx8IA)cJ4R1z)gjc5bElPXxciibolE5TKgF5zHqDTmeKe0x41ibzuWCvOBKuj3CnAsqXBno6sMc1)nViQZAWEHXXVg4TKgFjGGe4S4L3sA8LNfc11YqqsqFH)6FwuWCnAsuJrLYrxYuO(V5frDwd2lm5iL(ND(UfhDjtH6)Mxe1znyVW4lHWIs0)nPISCKwloEclvk3ohbpQ(WqkYK17AXXtyPs525i4K0cHkKjl9p78Dl(vWy26)MVTVq5lHWIs0)nPkFT44jSuPC7CeCsAHqfYxloEclvk3ohbpQ(VjvKh4TKgFjGGe4S4L3sA8LNfc11YqqsEuwO0AA8LRcDJKk5MRrtckERXVcgZw)38T9fkh)sUAmQu(JYcLwtJVg4TKgFjGGe4S4L3sA8LNfc11YqqsEuwO0AA8L)6FwuWCnAs6vqQh9lCbxdAXOZ5XSRKC1yuP8hLfkTMgFjp9p78Dl(vWy26)MVTVq5lHWIs0)nPkhjS2ggkJ4c1FXSQIcMmzRfhpHLkLBNJGtsleQq(AXXtyPs525i4r1)nPktwVRfhpHLkLBNJGtsleQa5bElPXxciibolE5TKgF5zHqDTmeKe7jxf6gjvYnxJMelPbwYtfHiirFsWyG3sA8LacsGtYymVL04lpleQRLHGKiuRo2Eg4h4HldOJ8yodOJ)QPXxd8wsJVeC7jjlH4xbXiHW3nkL2bElPXxcU9eeKahymlfgZBhSwLixJMe1yuP82(cvKCrHsd8wsJVeC7jiiboT9fQi5IcLCnAsqXBnoKbJffmpclbnkIVKLu59I12Wqze)qMcv4p4K3sAGLg4TKgFj42tqqcCG(DzrbZJYmH6A0KG12WqzeFFTL8BGGKRgJkLBynMvjO0aVL04lb3EccsGdmMLcJ5TdwRsKRrtsVO4TgFdeeh)sUL0al5PIqeKOFjUvMmlPbwYtfHiirFUDGhUma46FrGZSina76AFlbDa6pG0sMsdWgWLGWp)aU243qDzaQTWiDaSqOdO97aSRlMlrbBaR1z)gjAarna7PbElPXxcU9eeKaN2(c1l0nGKCn5sIrE1wyKkKCZ1Ojj9p78Dl(si(vqmsi8DJsPLVeclkr)sWq6HLoYvJrLYHzkuAJcMxO)IyG3sA8LGBpbbjWb63LffmpkZeQRrtcwBddLr891wYVbcAG3sA8LGBpbbjWPTVqfjxuOKRrtckERXHzkuAJcMxO)IGJFj3sAGL8urics0hgY7fRTHHYi(HmfQWFWjVL0alnWBjn(sWTNGGe48OSqP1uY1OjbRTHHYi(HmfQWFWjVL0aljhfV14hYuOc)bN4c1sq2pMjtgkERXHzkuAJcMxO)IGJFnWBjn(sWTNGGe402xOEHUbKKRjxsmYR2cJuHKBUgnjlEfj)13Lw(HArk0(r6MuGGAmQu(IxrYBQsfUPXxsVuqEG3sA8LGBpbbjWPTVqfjxuOKRrtsVyTnmugXpKPqf(do5TKgyPbElPXxcU9eeKaNhLfkTMsUMCjXiVAlmsfsU5A0KS4vK8xFxA5hQfPq7djmKceuJrLYx8ksEtvQWnn(s6LcYd8wsJVeC7jiiboWywkmM3oyTkrd8wsJVeC7jiiboT9fQi5IcLg4TKgFj42tqqcCA7luVq3asY1Kljg5vBHrQqYTbElPXxcU9eeKahO)w(V57gLs7aVL04lb3EccsGJTjRiV(7sLoWpWdxgaexYuOd4BdWjQZAWEHnGR)zrbBa7RMgFnGomaHARkgWnPkgak1(LgaeFNbeIbyyTGzOmAG3sA8LGJ(c)1)SOGjzje)kigje(UrP06A0KyjnWsEQiebj6tcgYKH12WqzeF76rXBnXaVL04lbh9f(R)zrbdcsGZJYcLwtjxtUKyKxTfgPcj3CnAsqXBnoKbJffmpclbnkIVKLu5P)zNVBXVcgZw)38T9fkFjewuI(C7aVL04lbh9f(R)zrbdcsGd0VllkyEuMjuxJMeS2ggkJ47RTKFde0aVL04lbh9f(R)zrbdcsGtBFHksUOqjxJMeu8wJdzWyrbZJWsqJI4lzjv(IxrYF9DPLFOwKcTpKUjfiOgJkLV4vK8MQuHBA8L0lfKLlUigZR2cJubVTVqfjxuOuFyiVxS2ggkJ4hYuOc)bN8wsdS0aVL04lbh9f(R)zrbdcsGtBFHksUOqjxJMKfVIK)67sl)qTifAFsqYTsbcQXOs5lEfjVPkv4MgFj9sbz5IlIX8QTWivWB7lurYffk1hgY7fRTHHYi(HmfQWFWjVL0alnWdxGld4UAlms9rtcctADaPdHI3A816SFJeXfQLGec3qgZJ0HqXBn(AD2VrI4lHWIsaHBil9hYuOEiRaguLV4f1(fgXxRZ(ns09b0XPlYuXaSbWE11bOqdXacXaIsP6qNbO)auBHr6auO0aGgWGscDaxB8BOUmaQieUmGUHcDawnadnyH6YauOMoGUbJna76I5YawRZ(ns0aI2aw8IA)cJo8b0duthakffSby1aOIq4Ya6gk0bi1biulbPW1b87aSAauriCzakuthGcLgWHqXBTb0nySbi(VgajTRyPb8fFG3sA8LGJ(c)1)SOGbbjW5rzHsRPKRjxsmYR2cJuHKBUgnjlEfj)13Lw(HArk0(KGHug4TKgFj4OVWF9plkyqqcCGXSuymVDWAvICnAsw8ks(RVlT8d1IuO9JHuLlUigZR2cJubhgZsHX82bRvjQpjyip9p78Dl(vWy26)MVTVq5lHWIs0Nug4TKgFj4OVWF9plkyqqcCA7luVq3asY1Kljg5vBHrQqYnxJMKfVIK)67sl)qTifA)yiv5P)zNVBXVcgZw)38T9fkFjewuI(KYaVL04lbh9f(R)zrbdcsGdmMLcJ5TdwRsKRrts6F257w8RGXS1)nFBFHYxcHfLOVfViUgiiV(Emt(IxrYF9DPLFOwKcTFmtQYfxeJ5vBHrQGdJzPWyE7G1Qe1Nemg4TKgFj4OVWF9plkyqqcCA7luVq3asY1Kljg5vBHrQqYnxJMK0)SZ3T4xbJzR)B(2(cLVeclkrFlErCnqqE99yM8fVIK)67sl)qTifA)yMuh4h4HldaIlzk0b8Tb4e1znyVWgqhjPbwAaD8xnn(AG3sA8LGJ(cVgjiJcMKhLfkTMsUMCjXiVAlmsfsU5A0KS4vK8xFxA7xcsyMuGGAmQu(IxrYBQsfUPXxsVuqEG3sA8LGJ(cVgjiJcgeKaNLq8RGyKq47gLsRRrtcwBddLr8TRhfV1eYKzjnWsEQiebj6tcgYKT4vK8xFxA73TyiFXlIRbcYRVhJ(x8ks(RVlTy(BWTbElPXxco6l8AKGmkyqqcCoKPq9wD8hkzU4A0KS4vK8xFxA73TyiFXlIRbcYRVhJ(x8ks(RVlTy(BWTbElPXxco6l8AKGmkyqqcCG(DzrbZJYmH6A0KG12WqzeFFTL8BGGKJ0IxrYF9DPTpjyMuKjBXlIRbcYRV3T9lbw6it2Ixu7xyeFnyK)BEfk5B73zu5tqnexXxYKjUigZR2cJubh63LffmpkZeAFsWqMmu8wJVbcIVeclkr)UfzzYw8ks(RVlT97wmKV4fX1ab513Jr)lEfj)13Lwm)n42aVL04lbh9fEnsqgfmiiboT9fQi5IcLCnAsqXBnoKbJffmpclbnkIJFjxCrmMxTfgPcEBFHksUOqP(WqEVyTnmugXpKPqf(do5TKgyPbElPXxco6l8AKGmkyqqcCEuwO0Ak5AYLeJ8QTWivi5MRrtckERXHmySOG5ryjOrr8LSKoWBjn(sWrFHxJeKrbdcsGd0Fl)38DJsP11OjzXRi5V(U02Ve4MuLV4fX1ab51372(GLod8wsJVeC0x41ibzuWGGe402xOIKlkuY1OjrCrmMxTfgPcEBFHksUOqP(WqEVyTnmugXpKPqf(do5TKgyPbElPXxco6l8AKGmkyqqcCEuwO0Ak5AYLeJ8QTWivi5MRrtYIxrYF9DPLFOwKcTpmKImzlErCnqqE99UTFyPZaVL04lbh9fEnsqgfmiiboq)USOG5rzMqDnAsWAByOmIVV2s(nqqd8wsJVeC0x41ibzuWGGe4yBYkYR)UuPUgnjlEfj)13L2(LIuh4h4h4HlWLb4MNDgG0zYwDaU5RtOXxIbE4cCzawsJVe80ZoEOKTQKeulkH)B(irUgnjTagu1Veclkr)Wsh5iT4f1pgYK1lkERXHmySOG5ryjOrrC8l5i1lclkpuRoCmGkhfV14PND8qjBvUqTeK9jbZGWIxu7xyehYNPXAcFZW(RmziSO8qT6WXaQCu8wJNE2XdLSv5c1sq2xNdclErTFHrCiFMgRj8nd7ViltgkERXHmySOG5ryjOrrC8l5i1lclkpuRoCmGkhfV14PND8qjBvUqTeK915GWIxu7xyehYNPXAcFZW(RmziSO8qT6WXaQCu8wJNE2XdLSv5c1sq23nPcHfVO2VWioKptJ1e(MH9xKrEGhUma4QkObCW3OGna4(GXSDaDdf6aKUjkzxWbIlzk0bElPXxcE6zhpuYwfcsGtcQfLW)nFKixJMKEvJrLYFuwO0AA8LCu8wJFfmMT(V5B7luo(LCu8wJNE2XdLSv5c1sq2NKBsvosO4Tg)kymB9FZ32xO8Lqyrj6hw6i9iDdcP)zNVBXB7l0UUSie(g(6cFj74cYYKHI3AC8c6ZCXl0Lkyku(siSOe9dlDKjdfV14jO2l8Owr8Lqyrj6hw6G8apCzaWD4Qio0a(2aG7dgZ2bGlidgnGUHcDas3eLSl4aXLmf6aVL04lbp9SJhkzRcbjWjb1Is4)MpsKRrtsVQXOs5pkluAnn(s(HmfQhYkGbv5lErTFHr8MXyu5tlUWo0kVxu8wJFfmMT(V5B7luo(L80)SZ3T4xbJzR)B(2(cLVeclkrF3KICKqXBnE6zhpuYwLlulbzFsUjv5iHI3AC8c6ZCXl0Lkykuo(LmzO4Tgpb1EHh1kIJFHSmzO4Tgp9SJhkzRYfQLGSpj3ClYd8wsJVe80ZoEOKTkeKaNeulkH)B(irUgnj9QgJkL)OSqP104l59EitH6HScyqv(Ixu7xyeVzmgv(0IlSdTYrXBnE6zhpuYwLlulbzFsUjv59II3A8RGXS1)nFBFHYXVKN(ND(Uf)kymB9FZ32xO8Lqyrj6ddPoWdxgaC)syPshGBE2zasNjB1b8yPnzxxrbBah8nkyd4kymBh4TKgFj4PND8qjBviibojOwuc)38rICnAsuJrLYFuwO0AA8L8ErXBn(vWy26)MVTVq54xYrcfV14PND8qjBvUqTeK9j5gMjhju8wJJxqFMlEHUubtHYXVKjdfV14jO2l8OwrC8lKLjdfV14PND8qjBvUqTeK9j5whtMS0)SZ3T4xbJzR)B(2(cLVeclkr)UvokERXtp74Hs2QCHAji7tYnmd5b(bE4YaG7Fn(AG3sA8LGN(ND(ULqY1RXxUgnjO4Tg)kymB9FZ32xOC8RbE4YaCZ)SZ3Ted8wsJVe80)SZ3TeqqcCiexFxA9lEr(UKD9LRrtIAmQu(JYcLwtJVKV4f1pCtosyTnmugXfQ)IzvffmzYWAByOmIBNJWVeclkKLJu6F257w8RGXS1)nFBFHYxcHfLOFPihP0)SZ3T4ngjGMwRP8Lqyrj6tkYfpodnQd)cxO4mYtl(LgFjtwVIhNHg1HFHluCg5Pf)sJVqwMmu8wJFfmMT(V5B7luo(fYYKH(cH8wadQ6xcHfLOFmK6aVL04lbp9p78DlbeKahcX13Lw)IxKVlzxF5A0KOgJkLJUKPq9FZlI6SgSxyYx8I6xkYx8ks(RVlT9JeCtQyUhYuOEiRaguLV4f1(fgXH6IqPnmPxkyUlErTFHr81qCzL611krJwQsK0lfKLJekERXrxYuO(V5frDwd2lmo(LmzTagu1Veclkr)yivKh4TKgFj4P)zNVBjGGe4qiU(U06x8I8Dj76lxJMe1yuP8irj7AG3sA8LGN(ND(ULacsGZvWy26)MVTVqDnAsuJrLYrxYuO(V5frDwd2lm5iH12WqzexO(lMvvuWKjdRTHHYiUDoc)siSOqwosP)zNVBXrxYuO(V5frDwd2lm(siSOeYKL(ND(UfhDjtH6)Mxe1znyVW4lzhxKV4vK8xFxA7tksf5bElPXxcE6F257wciiboxbJzR)B(2(c11OjrngvkpsuYUK3lkERXVcgZw)38T9fkh)AG3sA8LGN(ND(ULacsGZvWy26)MVTVqDnAsuJrLYFuwO0AA8LCKw8ks(RVlT9jXTsrEVO4Tg3qFerzA8LNfiq54xYKHI3ACd9reLPXxEwGaLJFHSCKWAByOmIlu)fZQkkyYKH12Wqze3ohHFjewuilhj1yuPCyMcL2OG5f6Vi4uzOm6ihfV14lH4xbXiHW3nkLwo(Lmz9QgJkLdZuO0gfmVq)fbNkdLrhKh4TKgFj4P)zNVBjGGe4GUKPq9FZlI6SgSxyUgnjO4Tg)kymB9FZ32xOC8RbElPXxcE6F257wciiboT9fAxxwecFdFDX1OjXsAGL8uricsi5MCu8wJFfmMT(V5B7lu(siSOe9dlDKJI3A8RGXS1)nFBFHYXVK3RAmQu(JYcLwtJVKJuVRfhpHLkLBNJGtsleQqMS1IJNWsLYTZrWJQp3kvKLjRfWGQ(Lqyrj63Td8wsJVe80)SZ3TeqqcCA7l0UUSie(g(6IRrtIL0al5PIqeKOpjyihju8wJFfmMT(V5B7luo(LmzRfhpHLkLBNJGtsleQq(AXXtyPs525i4r1x6F257w8RGXS1)nFBFHYxcHfLacDEKLJekERXVcgZw)38T9fkFjewuI(HLoYKTwC8ewQuUDocojTqOc5RfhpHLkLBNJGVeclkr)WshKh4TKgFj4P)zNVBjGGe402xODDzri8n81fxJMe1yuP8hLfkTMgFjhju8wJFfmMT(V5B7luo(L8Eryr5HA1HJbuzY6ffV14xbJzR)B(2(cLJFjhHfLhQvhogqLN(ND(Uf)kymB9FZ32xO8LqyrjqwosiHI3A8RGXS1)nFBFHYxcHfLOFyPJmzO4TghVG(mx8cDPcMcLJFjhfV144f0N5IxOlvWuO8Lqyrj6hw6GSCKoekERXxRZ(nsexOwcsjsrMSEpKPq9qwbmOkFXlQ9lmIVwN9BKiKrEG3sA8LGN(ND(ULacsGduxUEfkTiIK)AjbvjY1OjrngvkhDjtH6)Mxe1znyVWKV4vK8xFxA7hUjv5lEr9lXTYrcfV14Olzku)38IOoRb7fgh)sMS0)SZ3T4Olzku)38IOoRb7fgFjewuI(WmPISmz9QgJkLJUKPq9FZlI6SgSxyYx8ks(RVlT9lPZlLbElPXxcE6F257wciiboRfcYFi74A0KK(ND(Uf)kymB9FZ32xO8Lqyrj6xIug4TKgFj4P)zNVBjGGe4iS0gTifgZFzj11OjXsAGL8urics0NemKJulGbv9lHWIs0VBLjRxu8wJJUKPq9FZlI6SgSxyC8l5iDrkhg0hNXxcHfLOFyPJmzRfhpHLkLBNJGtsleQq(AXXtyPs525i4lHWIs0VBLVwC8ewQuUDocEu9Drkhg0hNXxcHfLazKh4TKgFj4P)zNVBjGGe4CitH6T64puYCX1OjXsAGL8urics0NuKjBXlQ9lmIFbLS9r8fjg4h4HldWnpwQSshqhbnyHgKyG3sA8LGNESuzLkKCitHk8hCY1OjbPEvJrLYFuwO0AA8LmzQXOs5pkluAnn(sUL0al5PIqeKOpjyip9p78Dl(vWy26)MVTVq5lHWIsitML0al5PIqeKqYnKLJewBddLrCH6VywvrbtMmS2ggkJ425i8lHWIc5bElPXxcE6XsLvQacsGJORTiIcMhriuxJMKfVIK)67sl)qTifAF3CR80)SZ3T4xbJzR)B(2(cLVeclkr)UvEVQXOs5Olzku)38IOoRb7fMCS2ggkJ4c1FXSQIc2aVL04lbp9yPYkvabjWr01werbZJieQRrtsVQXOs5Olzku)38IOoRb7fMCS2ggkJ425i8lHWIAG3sA8LGNESuzLkGGe4i6AlIOG5rec11OjrngvkhDjtH6)Mxe1znyVWKJekERXrxYuO(V5frDwd2lmo(LCKWAByOmIlu)fZQkkyYx8ks(RVlT8d1IuO9HzsvMmS2ggkJ425i8lHWIs(IxrYF9DPLFOwKcTp4MuLjdRTHHYiUDoc)siSOKVwC8ewQuUDoc(siSOe93XKVwC8ewQuUDocojTqOcKLjRxu8wJJUKPq9FZlI6SgSxyC8l5P)zNVBXrxYuO(V5frDwd2lm(siSOeipWBjn(sWtpwQSsfqqcCm0hruMgF5zbcuxJMK0)SZ3T4xbJzR)B(2(cLVeclkr)UvowBddLrCH6VywvrbtosQXOs5Olzku)38IOoRb7fM8fVIK)67sBFsrQYt)ZoF3IJUKPq9FZlI6SgSxy8Lqyrj6hdzY6vngvkhDjtH6)Mxe1znyVWqEG3sA8LGNESuzLkGGe4yOpIOmn(YZceOUgnjyTnmugXTZr4xcHf1aVL04lbp9yPYkvabjWra1sqYiVcL84v3FvOU4A0KG12WqzexO(lMvvuWKJu6F257w8RGXS1)nFBFHYxcHfLOF3ktMAmQuEKOKDH8aVL04lbp9yPYkvabjWra1sqYiVcL84v3FvOU4A0KG12Wqze3ohHFjewud8wsJVe80JLkRubeKaNgJeqtR1uxJMKErXBn(vWy26)MVTVq54xY7ffV14Olzku)38IOoRb7fgh)sosIhNHg1HFHluCg5Pf)sJVKjt84m0OoCSpZ0GrEXZWsLISRrP0U4xQpqGGoHPKKBUgLs7IFPEySh1ysU5AukTl(L6JMeXJZqJ6WX(mtdg5fpdlv6a)apCzaWDOSqP104RbSVAA81aVL04lb)rzHsRPXxswcXVcIrcHVBukTUgnjwsdSKNkcrqI(K4w5yTnmugX3UEu8wtmWBjn(sWFuwO0AA8feKaN2(c1l0nGKCnAs6ffV14qgmwuW8iSe0Oio(LCKw8I6hdzYuJrLYJKlE1yFjKJI3A8i5Ixn2xc(siSOe9dlDKEmKjl91bpuoEXitaLo(2svN5ICKqXBnoEXitaLo(2svN5cFjewuI(HLospgYKHI3AC8IrMakD8TLQoZfUqTeK97wKrEG3sA8LG)OSqP104liiboq)USOG5rzMqDnAs6ffV14qgmwuW8iSe0Oio(L8fVO(K4w5iHI3A8nqq8Lqyrj63TYrXBn(giio(LmzwsdSK)8kVTVq9nclT9BjnWsEQiebjqEG3sA8LG)OSqP104liiboWywkmM3oyTkrUgnj9II3ACidglkyEewcAueh)sU4IymVAlmsfCymlfgZBhSwLO(KGHmz9II3ACidglkyEewcAueh)soshcfV14R1z)gjIlulbz)srMSdHI3A816SFJeXxcHfLOFyPJ0JzipWBjn(sWFuwO0AA8feKaN2(cvKCrHsUgnjO4TghYGXIcMhHLGgfXxYsQCXfXyE1wyKk4T9fQi5IcL6dd59I12Wqze)qMcv4p4K3sAGLg4TKgFj4pkluAnn(ccsGZJYcLwtjxtUKyKxTfgPcj3CnAsqXBnoKbJffmpclbnkIVKL0bElPXxc(JYcLwtJVGGe402xOEHUbKKRrtIL0al5PIqeKqYn5yTnmugXB7luVq3asYN(6GhQyG3sA8LG)OSqP104liiboq)USOG5rzMqDnAsWAByOmIVV2s(nqqYfxeJ5vBHrQGd97YIcMhLzcTpjymWBjn(sWFuwO0AA8feKahymlfgZBhSwLixJMeXfXyE1wyKk4WywkmM3oyTkr9jbJbElPXxc(JYcLwtJVGGe402xOEHUbKKRjxsmYR2cJuHKBUgnj9QgJkLBynMvjOK8ErXBnoKbJffmpclbnkIJFjtMAmQuUH1ywLGsY7fRTHHYi((Al53abjtgwBddLr891wYVbcs(IxexdeKxFpg9jbw6mWBjn(sWFuwO0AA8feKahOFxwuW8OmtOUgnjyTnmugX3xBj)giObElPXxc(JYcLwtJVGGe48OSqP1uY1Kljg5vBHrQqYTb(bE4YaG7)NffSbax)7aG7qzHsRPXxDyaoQTQya3K6aeu6RJyaOu7xAaW9bJz7a(2aGR3xOdi9iiXa(wBaUr60aVL04lb)rzHsRPXx(R)zrbtYsi(vqmsi8DJsP11OjbRTHHYi(21JI3AczYSKgyjpveIGe9jbJbElPXxc(JYcLwtJV8x)ZIcgeKahymlfgZBhSwLixJMeXfXyE1wyKk4WywkmM3oyTkr9jbd5QXOs5T9fQi5IcLg4TKgFj4pkluAnn(YF9plkyqqcCA7lurYffk5A0KGI3ACidglkyEewcAueFjlPYTKgyjpveIGe9HH8EXAByOmIFitHk8hCYBjnWsd8wsJVe8hLfkTMgF5V(NffmiibopkluAnLCn5sIrE1wyKkKCZ1OjbfV14qgmwuW8iSe0Oi(swsh4TKgFj4pkluAnn(YF9plkyqqcCA7luVq3asY1OjXsAGL8uricsi5MCS2ggkJ4T9fQxOBaj5tFDWdvmWBjn(sWFuwO0AA8L)6FwuWGGe48OSqP1uY1Kljg5vBHrQqYnxJMeu8wJdzWyrbZJWsqJI4lzjDG3sA8LG)OSqP104l)1)SOGbbjWb63LffmpkZeQRrtcwBddLr891wYVbcAG3sA8LG)OSqP104l)1)SOGbbjWbgZsHX82bRvjY1OjrCrmMxTfgPcomMLcJ5TdwRsuFsWq(IxrYF9DPLFOwKcTF4Muh4TKgFj4pkluAnn(YF9plkyqqcCA7luVq3asY1Kljg5vBHrQqYnxJMKfVIK)67sl)qTifA)DEPoWBjn(sWFuwO0AA8L)6FwuWGGe48OSqP1uY1Kljg5vBHrQqYnxJMKfVO(K4w5i1lclkpuRoCmGktw6XsLvkVO0(SFpYKLESuzLYH0LnSczzYw8I6tcMjhHfLhQvhogqh4TKgFj4pkluAnn(YF9plkyqqcCA7lurYffk5A0KyjnWsEQiebj6tcMjVxS2ggkJ4hYuOc)bN8wsdS0a)apCzaDClfgBaDe0GfAqIbElPXxc(APWycjOS)p(g(6IRrtckERXVcgZw)38T9fkh)AG3sA8LGVwkmMacsGdkTcAHmkyUgnjO4Tg)kymB9FZ32xOC8RbElPXxc(APWyciibo2MSI8x4mb5A0KGuVO4Tg)kymB9FZ32xOC8l5wsdSKNkcrqI(KGbYYK1lkERXVcgZw)38T9fkh)soslEr8d1IuO9jrkYx8ks(RVlT8d1IuO9jbUjvKh4TKgFj4RLcJjGGe4WcyqvHhUk4hyiOsDnAsqXBn(vWy26)MVTVq54xd8wsJVe81sHXeqqcCSkrcDnMpzmMRrtckERXVcgZw)38T9fkh)sokERXjexFxA9lEr(UKD9fh)AG3sA8LGVwkmMacsGtlwcL9)X1OjbfV14xbJzR)B(2(cLVeclkr)s6CYrXBn(vWy26)MVTVq54xYrXBnoH467sRFXlY3LSRV44xd8wsJVe81sHXeqqcCqny(V51nsqkCnAsqXBn(vWy26)MVTVq54xYTKgyjpveIGesUjhju8wJFfmMT(V5B7lu(siSOe9lf5QXOs5PND8qjBvovgkJoYK1RAmQuE6zhpuYwLtLHYOJCu8wJFfmMT(V5B7lu(siSOe97wKh4h4HldWrT6y7zaIOGXimx1wyKoG9vtJVg4TKgFj4c1QJThjlH4xbXiHW3nkLwxJMeS2ggkJ4BxpkERjg4TKgFj4c1QJThiibopkluAnLCnAsqXBnoKbJffmpclbnkIVKL0bElPXxcUqT6y7bcsGd0VllkyEuMjuxJMeS2ggkJ47RTKFdeKCu8wJVbcIVeclkr)UDG3sA8LGluRo2EGGe402xOEHUbKKRrtcwBddLr82(c1l0nGK8PVo4Hkg4TKgFj4c1QJThiiboWywkmM3oyTkrUgnj9EitH6HScyqv(Ixu7xyeFTo73irYr6qO4TgFTo73irCHAji7xkYKDiu8wJVwN9BKi(siSOe9dlDKEmd5bElPXxcUqT6y7bcsGtBFH6f6gqsUgnjP)zNVBXxcXVcIrcHVBukT8Lqyrj6xcgspS0rUAmQuomtHsBuW8c9xed8wsJVeCHA1X2deKahOFxwuW8OmtOUgnjyTnmugX3xBj)giObElPXxcUqT6y7bcsGtBFH6f6gqsUgnjlEfj)13Lw(HArk0(r6MuGGAmQu(IxrYBQsfUPXxsVuqEG3sA8LGluRo2EGGe48OSqP1uY1OjPxu8wJ32VZOYFHZeeh)sUAmQuEB)oJk)fotqYKH12Wqze)qMcv4p4K3sAGLKJI3A8dzkuH)GtCHAji7hZKjtngvkhMPqPnkyEH(lc5O4TgFje)kigje(UrP0YXVKjBXRi5V(U0YpulsH2hsyifiOgJkLV4vK8MQuHBA8L0lfKh4TKgFj4c1QJThiiboT9fQxOBajnWBjn(sWfQvhBpqqcCG(B5)MVBukTd8wsJVeCHA1X2deKahBtwrE93LkDGFGhUmGE2OGKuXaVL04lbx3OGKuHeCb5dLq4AziijrjslUAOmY3rXTsXr4pe2irUgnj9QgJkLJUKPq9FZlI6SgSxyYrXBn(vWy26)MVTVq54xYrXBnoH467sRFXlY3LSRV44xYKPgJkLJUKPq9FZlI6SgSxyYrcju8wJFfmMT(V5B7luo(L80)SZ3T4Olzku)38IOoRb7fgFj74cYYKHekERXVcgZw)38T9fkh)sosi1cyqv)siSOeyUP)zNVBXrxYuO(V5frDwd2lm(siSOei3pg3qgzKLjd9fc5Tagu1Veclkr)yCtMSdzkupKvadQYpHWqzKp6OhpjnkHRKePkxTfgPCnqqE99xj1JHu7xkd8WLb0duAa6gfKKoGUHcDakuAaqdyqjHoasObctPZaWAmCY1b0nySbGsdaxqNb0IvOdWQZaUSyPZa6gk0ba3hmMTd4BdaUEFHYh4TKgFj46gfKKkGGe4OBuqs6nxJMKEXAByOmIlUOu0c641nkijvokERXVcgZw)38T9fkh)sos9QgJkLhjkzxYKPgJkLhjkzxYrXBn(vWy26)MVTVq5lHWIs0NKBsfz5i1RUrbjPCm4qnHp9p78DlzY0nkijLJbp9p78Dl(siSOeYKH12Wqzex3OGKu)1g)gQlsUHSmz6gfKKYVXrXBn)bFnn(QpjTagu1VeclkXaVL04lbx3OGKubeKahDJcssXW1OjPxS2ggkJ4IlkfTGoEDJcssLJI3A8RGXS1)nFBFHYXVKJuVQXOs5rIs2LmzQXOs5rIs2LCu8wJFfmMT(V5B7lu(siSOe9j5Murwos9QBuqsk)ghQj8P)zNVBjtMUrbjP8B80)SZ3T4lHWIsitgwBddLrCDJcss9xB8BOUibdKLjt3OGKuogCu8wZFWxtJV6tslGbv9lHWIsmWdxgG0TnGVyUmGVOb81aWf0a0nkijDax7JnoKya2aqXBnxhaUGgGcLgWRqPDaFnG0)SZ3T4daUBhq0gqrHcL2bOBuqs6aU2hBCiXaSbGI3AUoaCbna0xHoGVgq6F257w8bElPXxcUUrbjPciibo4cYhkHWvb7vj6gfKKEZ1OjPxS2ggkJ4IlkfTGoEDJcssLJuV6gfKKYVXHAcpUG8O4TMCK0nkijLJbp9p78Dl(siSOeYK1RUrbjPCm4qnHhxqEu8wdzzYs)ZoF3IFfmMT(V5B7lu(siSOe9HHurEG3sA8LGRBuqsQacsGdUG8HsiCvWEvIUrbjPy4A0K0lwBddLrCXfLIwqhVUrbjPYrQxDJcss5yWHAcpUG8O4TMCK0nkijLFJN(ND(UfFjewuczY6v3OGKu(nout4XfKhfV1qwMS0)SZ3T4xbJzR)B(2(cLVeclkrFyivKZAwZza]] )


end
