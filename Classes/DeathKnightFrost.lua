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


    spec:RegisterPack( "Frost DK", 20220301, [[d4u)vdqiPQ8iOqCjIsXMiQ(KkLrbrofe1QKkWRKQQzrL4wqHQ2fQ(fOsdJOKJPs1YGIEgvknnqfDnIcBtQO6BsfuJJOu6CGkO1jvO5bcUhrSpPkDqPcYcbHEivkMirPsUiuOYgbvO(iOcXijkvQtsuQALGQEjOcPMPur2jvQ(juizOqHulfubEkvmvPkUkOcj(krPIXcfSxr9xQAWahMYIH0JfzYQ4YiBwkFgugniDAHvdQqsVgenBuUne2TKFRQHRsoouOSCLEoHPt66q12HsFxQ04jk68ujTEPIY8js7xX575EYohtPS7yklmXuwUvw35y6wzC3TDE2rD9IYoxwcsdgLDkdbLDGJ3xOdq2fC0zNlZv2BNCpzhXJVjk7av1lrhHlCHfkuCuE6raxrGaNzA8vATMcxrGib3SdkEWuzFLrZohtPS7yklmXuwUvw35y6wzC3TWz2XWvO)MDCceUj7anohQYOzNdjszhzxKPqhaC0vadQoa449f6apCmHU4266aWu26YaWuwyI5a)aVBGAfmsmWJXpa4acXJLodGzcfJxqPVodaxyWOb8Tb4gOwuIb8Tbi7t0amXacDaNNe1nDaxmZ1b0LySbe1aUwlPrI4d8y8dq21x30bKGAvrSbahZib00AnDah8nkydaIlzk0b8Tb4e1znyVW4zhwiurUNSZJYcLwtJV8x)ZIcwUNS73Z9KDOYqz0jdXSJL04RSZsi(vqmsi8DJsPn7CirAJln(k7Gr)plkydao(3bGrHYcLwtJV64aCuBvXaUlRbiO0xhXaqP2V0aWOdgZ2b8TbahVVqhq6rqIb8T2aCJSRStAdL2WYoyTnmugX3UEu8wtmaPshGL0al5PIqeKya9kzayM1S7yM7j7qLHYOtgIzN0gkTHLDexeJ5vBHrQGdJzPWyE7G1QenGELmamhG8bOgJkL32xOIKRkuItLHYOt2XsA8v2bgZsHX82bRvjkRz3DBUNSdvgkJoziMDsBO0gw2bfV14qgmwuW8iSe0Oi(swshG8byjnWsEQiebjgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZUdN5EYouzOm6KHy2XsA8v25rzHsRPu2jTHsByzhu8wJdzWyrbZJWsqJI4lzjn7KCnXiVAlmsfz3VN1S7Yi3t2HkdLrNmeZoPnuAdl7yjnWsEQiebjgGKbCFaYhawBddLr82(c1l0nGK8PVo4HkYowsJVYoT9fQxOBajL1S7DEUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2bfV14qgmwuW8iSe0Oi(swsZojxtmYR2cJur297zn7Eho3t2HkdLrNmeZoPnuAdl7G12WqzeFFTL8BGGYowsJVYoq)USOG5rzMqZA2DzBUNSdvgkJoziMDsBO0gw2rCrmMxTfgPcomMLcJ5TdwRs0a6vYaWCaYhWIxrYF9DPLFOwKcDaqyaDUSYowsJVYoWywkmM3oyTkrzn7oCyUNSdvgkJoziMDSKgFLDA7luVq3ask7K2qPnSSZIxrYF9DPLFOwKcDaqyaDyzLDsUMyKxTfgPIS73ZA297Yk3t2HkdLrNmeZowsJVYopkluAnLYoPnuAdl7S4fnGELma3oa5daPb03aqyr5HA1HJj0biv6aspwQSs5fL2N97zasLoG0JLkRuoKUUHvda5biv6aw8IgqVsgaCoa5daHfLhQvhoMqZojxtmYR2cJur297zn7(975EYouzOm6KHy2jTHsByzhlPbwYtfHiiXa6vYaGZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZA2j9SJhkzRM7j7(9CpzhQmugDYqm7K2qPnSSd6ledq(aAbmOQFjewuIbaHbalDgG8bG0aw8IgaegaMdqQ0b03aqXBnoKbJffmpclbnkIJFna5daPb03aqyr5HA1HJj0biFaO4Tgp9SJhkzRYfQLGCa9kzaW5a6FalErTFHrCiFMgRj8nd7VCQmugDgGuPdaHfLhQvhoMqhG8bGI3A80ZoEOKTkxOwcYb07aKTdO)bS4f1(fgXH8zASMW3mS)YPYqz0zaipaPshakERXHmySOG5ryjOrrC8RbiFainG(gaclkpuRoCmHoa5dafV14PND8qjBvUqTeKdO3biBhq)dyXlQ9lmId5Z0ynHVzy)LtLHYOZaKkDaiSO8qT6WXe6aKpau8wJNE2XdLSv5c1sqoGEhWDznG(hWIxu7xyehYNPXAcFZW(lNkdLrNbG8aqo7yjn(k7KGArj8FZhjkRz3Xm3t2HkdLrNmeZowsJVYojOwuc)38rIYohsK24sJVYoWrrqd4GVrbBay0bJz7a6gk0bi7tuYUGlexYuOzN0gkTHLD6BaQXOs5pkluAnn(ItLHYOZaKpau8wJFfmMT(V5B7luo(1aKpau8wJNE2XdLSv5c1sqoGELmG7YAaYhasdafV14xbJzR)B(2(cLVeclkXaGWaGLodOdgasd4(a6FaP)zNVBXB7l0UUUie(g(6kFj746aqEasLoau8wJJxqFMREHUubtHYxcHfLyaqyaWsNbiv6aqXBnEcQ9cpQveFjewuIbaHbalDgaYzn7UBZ9KDOYqz0jdXSJL04RStcQfLW)nFKOSZHePnU04RSdgfUkIdnGVnam6GXSDa4cYGrdOBOqhGSprj7cUqCjtHMDsBO0gw2PVbOgJkL)OSqP104lovgkJodq(aoKPq9qwbmOkFXlQ9lmI3mgJkFAXf2H2biFa9nau8wJFfmMT(V5B7luo(1aKpG0)SZ3T4xbJzR)B(2(cLVeclkXa6Da3LXaKpaKgakERXtp74Hs2QCHAjihqVsgWDzna5daPbGI3AC8c6ZC1l0Lkykuo(1aKkDaO4Tgpb1EHh1kIJFnaKhGuPdafV14PND8qjBvUqTeKdOxjd4UBhaYzn7oCM7j7qLHYOtgIzN0gkTHLD6BaQXOs5pkluAnn(ItLHYOZaKpG(gWHmfQhYkGbv5lErTFHr8MXyu5tlUWo0oa5dafV14PND8qjBvUqTeKdOxjd4USgG8b03aqXBn(vWy26)MVTVq54xdq(as)ZoF3IFfmMT(V5B7lu(siSOedO3bGPSYowsJVYojOwuc)38rIYA2DzK7j7qLHYOtgIzhlPXxzNeulkH)B(irzNdjsBCPXxzhm6LWsLoa38SZaKDt2Qd4XsBYUUIc2ao4BuWgWvWy2MDsBO0gw2rngvk)rzHsRPXxCQmugDgG8b03aqXBn(vWy26)MVTVq54xdq(aqAaO4Tgp9SJhkzRYfQLGCa9kza3HZbiFainau8wJJxqFMREHUubtHYXVgGuPdafV14jO2l8OwrC8RbG8aKkDaO4Tgp9SJhkzRYfQLGCa9kza3HdhGuPdi9p78Dl(vWy26)MVTVq5lHWIsmaima3oa5dafV14PND8qjBvUqTeKdOxjd4oCoaKZAwZopkluAnn(k3t2975EYouzOm6KHy2XsA8v2zje)kigje(UrP0MDoKiTXLgFLDWOqzHsRPXxdyF104RStAdL2WYowsdSKNkcrqIb0RKb42biFayTnmugX3UEu8wtK1S7yM7j7qLHYOtgIzN0gkTHLD6BaO4TghYGXIcMhHLGgfXXVgG8bG0aw8IgaegaMdqQ0bOgJkLhjx9QX(sWPYqz0zaYhakERXJKRE1yFj4lHWIsmaimayPZa6GbG5aKkDaPVo4HYXlgzcO0X3wQ6mx5uzOm6ma5daPbGI3AC8IrMakD8TLQoZv(siSOedacdaw6mGoyayoaPshakERXXlgzcO0X3wQ6mx5c1sqoaima3oaKhaYzhlPXxzN2(c1l0nGKYA2D3M7j7qLHYOtgIzN0gkTHLD6BaO4TghYGXIcMhHLGgfXXVgG8bS4fnGELma3oa5daPbGI3A8nqq8LqyrjgaegGBhG8bGI3A8nqqC8Rbiv6aSKgyj)5vEBFH6BewAhaegGL0al5PIqeKyaiNDSKgFLDG(DzrbZJYmHM1S7WzUNSdvgkJoziMDsBO0gw2PVbGI3ACidglkyEewcAueh)AaYhG4IymVAlmsfCymlfgZBhSwLOb0RKbG5aKkDa9nau8wJdzWyrbZJWsqJI44xdq(aqAahcfV14R1z)gjIlulb5aGWaKXaKkDahcfV14R1z)gjIVeclkXaGWaGLodOdgaCoaKZowsJVYoWywkmM3oyTkrzn7UmY9KDOYqz0jdXStAdL2WYoO4TghYGXIcMhHLGgfXxYs6aKpaXfXyE1wyKk4T9fQi5QcLgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZU355EYouzOm6KHy2XsA8v25rzHsRPu2jTHsByzhu8wJdzWyrbZJWsqJI4lzjn7KCnXiVAlmsfz3VN1S7D4CpzhQmugDYqm7K2qPnSSJL0al5PIqeKyasgW9biFayTnmugXB7luVq3asYN(6GhQi7yjn(k702xOEHUbKuwZUlBZ9KDOYqz0jdXStAdL2WYoyTnmugX3xBj)giObiFaIlIX8QTWivWH(DzrbZJYmHoGELmamZowsJVYoq)USOG5rzMqZA2D4WCpzhQmugDYqm7K2qPnSSJ4IymVAlmsfCymlfgZBhSwLOb0RKbGz2XsA8v2bgZsHX82bRvjkRz3VlRCpzhQmugDYqm7yjn(k702xOEHUbKu2jTHsByzN(gGAmQuUH1ywLGsCQmugDgG8b03aqXBnoKbJffmpclbnkIJFnaPshGAmQuUH1ywLGsCQmugDgG8b03aWAByOmIVV2s(nqqdqQ0bG12WqzeFFTL8BGGgG8bS4fX1ab513J5a6vYaGLozNKRjg5vBHrQi7(9SMD)(9CpzhQmugDYqm7K2qPnSSdwBddLr891wYVbck7yjn(k7a97YIcMhLzcnRz3VJzUNSdvgkJoziMDSKgFLDEuwO0AkLDsUMyKxTfgPIS73ZAwZoOVWRrcYOGL7j7(9CpzhQmugDYqm7yjn(k78OSqP1uk7KCnXiVAlmsfz3VNDsBO0gw2zXRi5V(U0oaiizaina4ugdO)bOgJkLV4vK8MQuHBA8fNkdLrNb0bdqgda5SZHePnU04RSdexYuOd4BdWjQZAWEHnGousdS0aGdE104RSMDhZCpzhQmugDYqm7K2qPnSSdwBddLr8TRhfV1edqQ0byjnWsEQiebjgqVsgaMdqQ0bS4vK8xFxAhaegGBXCaYhWIxexdeKxFpMdacdyXRi5V(U0oa4oG7DE2XsA8v2zje)kigje(UrP0M1S7Un3t2HkdLrNmeZoPnuAdl7S4vK8xFxAhaegGBXCaYhWIxexdeKxFpMdacdyXRi5V(U0oa4oG7DE2XsA8v25qMc1B1XFOK5AwZUdN5EYouzOm6KHy2jTHsByzhS2ggkJ47RTKFde0aKpaKgWIxrYF9DPDa9kzaWPmgGuPdyXlIRbcYRV3TdacsgaS0zasLoGfVO2VWi(AWi)38kuY32VZOYNGAiUIV4uzOm6maPshG4IymVAlmsfCOFxwuW8OmtOdOxjdaZbiv6aqXBn(gii(siSOedacdWTda5biv6aw8ks(RVlTdacdWTyoa5dyXlIRbcYRVhZbaHbS4vK8xFxAhaChW9op7yjn(k7a97YIcMhLzcnRz3LrUNSdvgkJoziMDsBO0gw2bfV14qgmwuW8iSe0Oio(1aKpaXfXyE1wyKk4T9fQi5QcLgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZU355EYouzOm6KHy2XsA8v25rzHsRPu2jTHsByzhu8wJdzWyrbZJWsqJI4lzjn7KCnXiVAlmsfz3VN1S7D4CpzhQmugDYqm7K2qPnSSZIxrYF9DPDaqqYa6Czna5dyXlIRbcYRV3TdO3balDYowsJVYoq)T8FZ3nkL2SMDx2M7j7qLHYOtgIzN0gkTHLDexeJ5vBHrQG32xOIKRkuAa9oamhG8b03aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCvHszn7oCyUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2zXRi5V(U0YpulsHoGEhaMYyasLoGfViUgiiV(E3oaimayPt2j5AIrE1wyKkYUFpRz3VlRCpzhQmugDYqm7K2qPnSSdwBddLr891wYVbck7yjn(k7a97YIcMhLzcnRz3VFp3t2HkdLrNmeZoPnuAdl7S4vK8xFxAhaegGmKv2XsA8v2X2KvKx)DPsZAwZoc1QJTNCpz3VN7j7qLHYOtgIzhlPXxzNLq8RGyKq47gLsB25qI0gxA8v2XrT6y7zaIOGXimE1wyKoG9vtJVYoPnuAdl7G12WqzeF76rXBnrwZUJzUNSdvgkJoziMDsBO0gw2bfV14qgmwuW8iSe0Oi(swsZowsJVYopkluAnLYA2D3M7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nqqdq(aqXBn(gii(siSOedacdWTzhlPXxzhOFxwuW8OmtOzn7oCM7j7qLHYOtgIzN0gkTHLDWAByOmI32xOEHUbKKp91bpur2XsA8v2PTVq9cDdiPSMDxg5EYouzOm6KHy2jTHsByzN(gWHmfQhYkGbv5lErTFHr816SFJena5daPbCiu8wJVwN9BKiUqTeKdacdqgdqQ0bCiu8wJVwN9BKi(siSOedacdaw6mGoyaW5aqo7yjn(k7aJzPWyE7G1QeL1S7DEUNSdvgkJoziMDsBO0gw2j9p78Dl(si(vqmsi8DJsPLVeclkXaGGKbG5a6GbalDgG8bOgJkLdZuO0gfmVq)fbNkdLrNSJL04RStBFH6f6gqszn7Eho3t2HkdLrNmeZoPnuAdl7G12WqzeFFTL8BGGYowsJVYoq)USOG5rzMqZA2DzBUNSdvgkJoziMDsBO0gw2zXRi5V(U0YpulsHoaimaKgWDzmG(hGAmQu(IxrYBQsfUPXxCQmugDgqhmazmaKZowsJVYoT9fQxOBajL1S7WH5EYouzOm6KHy2jTHsByzN(gakERXB73zu5VWzcIJFna5dqngvkVTFNrL)cNjiovgkJodqQ0bG12Wqze)qMcv4p4K3sAGLgG8bGI3A8dzkuH)GtCHAjihaegaCoaPshGAmQuomtHsBuW8c9xeCQmugDgG8bGI3A8Lq8RGyKq47gLslh)AasLoGfVIK)67sl)qTif6a6DainamLXa6FaQXOs5lEfjVPkv4MgFXPYqz0zaDWaKXaqo7yjn(k78OSqP1ukRz3VlRCpzhlPXxzN2(c1l0nGKYouzOm6KHywZUF)EUNSJL04RSd0Fl)38DJsPn7qLHYOtgIzn7(DmZ9KDSKgFLDSnzf51FxQ0SdvgkJoziM1SMDqFH)6FwuWY9KD)EUNSdvgkJoziMDSKgFLDwcXVcIrcHVBukTzNdjsBCPXxzhiUKPqhW3gGtuN1G9cBax)ZIc2a2xnn(AaDCac1wvmG7YsmauQ9lnai(odiedWWAbZqzu2jTHsByzhlPbwYtfHiiXa6vYaWCasLoaS2ggkJ4BxpkERjYA2DmZ9KDOYqz0jdXSJL04RSZJYcLwtPStAdL2WYoO4TghYGXIcMhHLGgfXxYs6aKpG0)SZ3T4xbJzR)B(2(cLVeclkXa6DaUn7KCnXiVAlmsfz3VN1S7Un3t2HkdLrNmeZoPnuAdl7G12WqzeFFTL8BGGYowsJVYoq)USOG5rzMqZA2D4m3t2HkdLrNmeZoPnuAdl7GI3ACidglkyEewcAueFjlPdq(aw8ks(RVlT8d1IuOdO3bG0aUlJb0)auJrLYx8ksEtvQWnn(ItLHYOZa6GbiJbG8aKpaXfXyE1wyKk4T9fQi5QcLgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZUlJCpzhQmugDYqm7K2qPnSSZIxrYF9DPLFOwKcDa9kzaina3kJb0)auJrLYx8ksEtvQWnn(ItLHYOZa6GbiJbG8aKpaXfXyE1wyKk4T9fQi5QcLgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZU355EYouzOm6KHy2XsA8v25rzHsRPu2jTHsByzNfVIK)67sl)qTif6a6vYaWugzNKRjg5vBHrQi7(9SMDVdN7j7qLHYOtgIzN0gkTHLDw8ks(RVlT8d1IuOdacdatzna5dqCrmMxTfgPcomMLcJ5TdwRs0a6vYaWCaYhq6F257w8RGXS1)nFBFHYxcHfLya9oazKDSKgFLDGXSuymVDWAvIYA2DzBUNSdvgkJoziMDSKgFLDA7luVq3ask7K2qPnSSZIxrYF9DPLFOwKcDaqyaykRbiFaP)zNVBXVcgZw)38T9fkFjewuIb07aKr2j5AIrE1wyKkYUFpRz3HdZ9KDOYqz0jdXStAdL2WYoP)zNVBXVcgZw)38T9fkFjewuIb07aw8I4AGG867HZbiFalEfj)13Lw(HArk0baHbaNYAaYhG4IymVAlmsfCymlfgZBhSwLOb0RKbGz2XsA8v2bgZsHX82bRvjkRz3VlRCpzhQmugDYqm7yjn(k702xOEHUbKu2jTHsByzN0)SZ3T4xbJzR)B(2(cLVeclkXa6DalErCnqqE99W5aKpGfVIK)67sl)qTif6aGWaGtzLDsUMyKxTfgPIS73ZAwZoP)zNVBjY9KD)EUNSdvgkJoziMDsBO0gw2bfV14xbJzR)B(2(cLJFLDoKiTXLgFLDWOFn(k7yjn(k7C9A8vwZUJzUNSdvgkJoziMDSKgFLDiexFxA9lEr(UKD9v25qI0gxA8v2Xn)ZoF3sKDsBO0gw2rngvk)rzHsRPXxCQmugDgG8bS4fnaimGoFaYhasdaRTHHYiUq9xmRQOGnaPshawBddLrC7Ce(LqyrnaKhG8bG0as)ZoF3IFfmMT(V5B7lu(siSOedacdqgdq(aqAaP)zNVBXBmsanTwt5lHWIsmGEhGmgG8biECgAuh(fUqXzKNw8ln(ItLHYOZaKkDa9naXJZqJ6WVWfkoJ80IFPXxCQmugDgaYdqQ0bGI3A8RGXS1)nFBFHYXVgaYdqQ0bG(cXaKpGwadQ6xcHfLyaqyaykRSMD3T5EYouzOm6KHy2jTHsByzh1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpGfVObaHbiJbiFalEfj)13L2baHbG0a6Cznam(bCitH6HScyqv(Ixu7xyehQRcL2Wgqhmazmam(bS4f1(fgXxdXLvQxxRenAPkrCQmugDgqhmazmaKhG8bG0aqXBno6sMc1)nViQZAWEHXXVgGuPdOfWGQ(LqyrjgaegaMYAaiNDSKgFLDiexFxA9lEr(UKD9vwZUdN5EYouzOm6KHy2jTHsByzh1yuP8irj7ItLHYOt2XsA8v2HqC9DP1V4f57s21xzn7UmY9KDOYqz0jdXStAdL2WYoQXOs5Olzku)38IOoRb7fgNkdLrNbiFainaS2ggkJ4c1FXSQIc2aKkDayTnmugXTZr4xcHf1aqEaYhasdi9p78Dlo6sMc1)nViQZAWEHXxcHfLyasLoG0)SZ3T4Olzku)38IOoRb7fgFj746aKpGfVIK)67s7a6DaDUmgaYzhlPXxzNRGXS1)nFBFHM1S7DEUNSdvgkJoziMDsBO0gw2rngvkpsuYU4uzOm6ma5dOVbGI3A8RGXS1)nFBFHYXVYowsJVYoxbJzR)B(2(cnRz37W5EYouzOm6KHy2jTHsByzh1yuP8hLfkTMgFXPYqz0zaYhasdyXRi5V(U0oGELma3kJbiFa9nau8wJBOpIOmn(YZceOC8Rbiv6aqXBnUH(iIY04lplqGYXVgaYdq(aqAayTnmugXfQ)IzvffSbiv6aWAByOmIBNJWVeclQbG8aKpaKgGAmQuomtHsBuW8c9xeCQmugDgG8bGI3A8Lq8RGyKq47gLslh)AasLoG(gGAmQuomtHsBuW8c9xeCQmugDgaYzhlPXxzNRGXS1)nFBFHM1S7Y2CpzhQmugDYqm7K2qPnSSdkERXVcgZw)38T9fkh)k7yjn(k7GUKPq9FZlI6SgSxyzn7oCyUNSdvgkJoziMDsBO0gw2XsAGL8uricsmajd4(aKpau8wJFfmMT(V5B7lu(siSOedacdaw6ma5dafV14xbJzR)B(2(cLJFna5dOVbOgJkL)OSqP104lovgkJodq(aqAa9nG1IJNWsLYTZrWjzgcvmaPshWAXXtyPs525i4rnGEhGBL1aqEasLoGwadQ6xcHfLyaqyaUn7yjn(k702xODDDri8n811SMD)USY9KDOYqz0jdXStAdL2WYowsdSKNkcrqIb0RKbG5aKpaKgakERXVcgZw)38T9fkh)AasLoG1IJNWsLYTZrWjzgcvma5dyT44jSuPC7Ce8OgqVdi9p78Dl(vWy26)MVTVq5lHWIsmG(hqhEaipa5daPbGI3A8RGXS1)nFBFHYxcHfLyaqyaWsNbiv6awloEclvk3ohbNKziuXaKpG1IJNWsLYTZrWxcHfLyaqyaWsNbGC2XsA8v2PTVq766Iq4B4RRzn7(975EYouzOm6KHy2jTHsByzh1yuP8hLfkTMgFXPYqz0zaYhasdafV14xbJzR)B(2(cLJFna5dOVbGWIYd1QdhtOdqQ0b03aqXBn(vWy26)MVTVq54xdq(aqyr5HA1HJj0biFaP)zNVBXVcgZw)38T9fkFjewuIbG8aKpaKgasdafV14xbJzR)B(2(cLVeclkXaGWaGLodqQ0bGI3AC8c6ZC1l0Lkykuo(1aKpau8wJJxqFMREHUubtHYxcHfLyaqyaWsNbG8aKpaKgWHqXBn(AD2VrI4c1sqoajdqgdqQ0b03aoKPq9qwbmOkFXlQ9lmIVwN9BKObG8aqo7yjn(k702xODDDri8n811SMD)oM5EYouzOm6KHy2jTHsByzh1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpGfVIK)67s7aGWa6Czna5dyXlAaqqYaC7aKpaKgakERXrxYuO(V5frDwd2lmo(1aKkDaP)zNVBXrxYuO(V5frDwd2lm(siSOedO3baNYAaipaPshqFdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5dyXRi5V(U0oaiizaDyzKDSKgFLDG661RqPfrK8xljOkrzn7(D3M7j7qLHYOtgIzN0gkTHLDs)ZoF3IFfmMT(V5B7lu(siSOedacsgGmYowsJVYoRfcYFi7K1S73HZCpzhQmugDYqm7K2qPnSSJL0al5PIqeKya9kzayoa5daPb0cyqv)siSOedacdWTdqQ0b03aqXBno6sMc1)nViQZAWEHXXVgG8bG0aUiLdd6JZ4lHWIsmaimayPZaKkDaRfhpHLkLBNJGtYmeQyaYhWAXXtyPs525i4lHWIsmaima3oa5dyT44jSuPC7Ce8OgqVd4IuomOpoJVeclkXaqEaiNDSKgFLDewAJwKcJ5VSKM1S73LrUNSdvgkJoziMDsBO0gw2XsAGL8uricsmGEhGmgGuPdyXlQ9lmIFbLS9r8fj4uzOm6KDSKgFLDoKPq9wD8hkzUM1SMDouZWzAUNS73Z9KDSKgFLDqe1X3wI6mk7qLHYOtgIzn7oM5EYouzOm6KHy25VYocsZowsJVYoyTnmugLDWAmCk7G0aimgECDrhEuI0IRgkJ8ymCRuCe(dHns0aKkDaegdpUUOdxHs(wSc1lcybBaipa5daPbK(ND(UfpkrAXvdLrEmgUvkoc)HWgjIVKDCDasLoG0)SZ3T4kuY3IvOEraly8LqyrjgaYdqQ0bqym846IoCfk5BXkuViGfSbiFaegdpUUOdpkrAXvdLrEmgUvkoc)HWgjk7CirAJln(k7GrVewQ0biUOu0c6maDJcssfdaLIc2aWf0zaDdf6amC9ryAKgalksKDWARVmeu2rCrPOf0XRBuqsAwZU72CpzhQmugDYqm78xzhbPzhlPXxzhS2ggkJYoyngoLDSKgyjpveIGedqYaUpa5daPbSwC8ewQuUDocEudO3bCxgdqQ0b03awloEclvk3ohbNKziuXaqo7G1wFziOSJq9xmRQOGL1S7WzUNSdvgkJoziMD(RSJG0SJL04RSdwBddLrzhSgdNYowsdSKNkcrqIb0RKbG5aKpaKgqFdyT44jSuPC7CeCsMHqfdqQ0bSwC8ewQuUDocojZqOIbiFainG1IJNWsLYTZrWxcHfLya9oazmaPshqlGbv9lHWIsmGEhWDznaKhaYzhS26ldbLDSZr4xcHfvwZUlJCpzhQmugDYqm78xzhbPzhlPXxzhS2ggkJYoyngoLDqXBn(giio(1aKpaKgqFdyXlQ9lmIVgmY)nVcL8T97mQ8jOgIR4lovgkJodqQ0bS4f1(fgXxdg5)MxHs(2(Dgv(eudXv8fNkdLrNbiFalEfj)13Lw(HArk0b07aKTda5SdwB9LHGYo7RTKFdeuwZU355EYouzOm6KHy25VYocsZowsJVYoyTnmugLDWAmCk7K(6GhkNw7ejtJcMhL9DhG8bGI3ACATtKmnkyEu23Llulb5aKmamhGuPdi91bpuoEXitaLo(2svN5kNkdLrNbiFaO4TghVyKjGshFBPQZCLVeclkXaGWaqAaWsNb0bdaZbGC2bRT(YqqzN2(c1l0nGK8PVo4HkYA29oCUNSdvgkJoziMD(RSJG0SJL04RSdwBddLrzhSgdNYohYuOERo(dLmx5AKGmkydq(aspwQSs5vadQ6BgLDWARVmeu25qMcv4p4K3sAGLYA2DzBUNSdvgkJoziMDSKgFLDwcXVcIrcHVBukTzNdjsBCPXxzNo01fZ1bahVVqhaCmHLwxgaclk1IAaY(KRdOhJ9LyawDgaKeDna4acXVcIrcXaKDIsPDa7Zyrbl7K2qPnSSt6RdEOCclTT9f6aKpa1yuPCyMcL2OG5f6Vi4uzOm6ma5daPb03auJrLYFuwO0AA8fNkdLrNbiFaP)zNVBXVcgZw)38T9fkFjewuIbiv6aeK6r)cxW1GwmLTE48kna5dqngvk)rzHsRPXxCQmugDgG8b03aqXBn(vWy26)MVTVq54xda5SMDhom3t2HkdLrNmeZowsJVYoq)USOG5rzMqZoPnuAdl703aoVYB7luFJWslFjewuIbiFaina1yuP8irj7ItLHYOZaKkDa9nau8wJJUKPq9FZlI6SgSxyC8RbiFaQXOs5Olzku)38IOoRb7fgNkdLrNbiv6auJrLYFuwO0AA8fNkdLrNbiFaP)zNVBXVcgZw)38T9fkFjewuIbiFa9nau8wJdzWyrbZJWsqJI44xda5StY1eJ8QTWivKD)EwZUFxw5EYouzOm6KHy2jTHsByzhu8wJhjx9QX(sWxcHfLyaqqYaGLodOdgaMdq(auJrLYJKRE1yFj4uzOm6ma5dqCrmMxTfgPcomMLcJ5TdwRs0a6vYaWCaYhasdqngvkpsuYU4uzOm6maPshGAmQuo6sMc1)nViQZAWEHXPYqz0zaYhq6F257wC0LmfQ)BEruN1G9cJVeclkXa6Da3LXaKkDaQXOs5pkluAnn(ItLHYOZaKpG(gakERXVcgZw)38T9fkh)AaiNDSKgFLDGXSuymVDWAvIYA2973Z9KDOYqz0jdXStAdL2WYoO4TgpsU6vJ9LGVeclkXaGGKbalDgqhmamhG8bOgJkLhjx9QX(sWPYqz0zaYhasdqngvkpsuYU4uzOm6maPshGAmQuo6sMc1)nViQZAWEHXPYqz0zaYhqFdafV14Olzku)38IOoRb7fgh)AaYhq6F257wC0LmfQ)BEruN1G9cJVeclkXa6Da3L1aKkDaQXOs5pkluAnn(ItLHYOZaKpG(gakERXVcgZw)38T9fkh)AaiNDSKgFLDA7luVq3askRz3VJzUNSdvgkJoziMDsBO0gw2j9yPYkLxbmOQVz0aKpGdzkuVvh)HsMRCnsqgfSbiFahYuOERo(dLmx5wsdSKFjewuIbaHbG0aGLodOdgWDUmgaYdq(aqAa9na1yuP8hLfkTMgFXPYqz0zasLoa1yuP8hLfkTMgFXPYqz0zaYhqFdafV14xbJzR)B(2(cLJFnaKZowsJVYopkluAnLYA297Un3t2HkdLrNmeZohsK24sJVYoUb6)cAaDOKgFnawi0bO)aw8k7yjn(k7KmgZBjn(YZcHMDyHq9LHGYoPhlvwPISMD)oCM7j7qLHYOtgIzhlPXxzNKXyElPXxEwi0SdleQVmeu2zTuymrwZUFxg5EYouzOm6KHy2XsA8v2jzmM3sA8LNfcn7WcH6ldbLD0nkijvK1S7378CpzhQmugDYqm7yjn(k7KmgZBjn(YZcHMDyHq9LHGYoP)zNVBjYA297D4CpzhQmugDYqm7K2qPnSSJAmQuE6zhpuYwLtLHYOZaKpaKgqFdafV14qgmwuW8iSe0Oio(1aKkDaQXOs5Olzku)38IOoRb7fgNkdLrNbG8aKpaKgWHqXBn(AD2VrI4c1sqoajdqgdqQ0b03aoKPq9qwbmOkFXlQ9lmIVwN9BKObGC2rOBK0S73ZowsJVYojJX8wsJV8SqOzhwiuFziOSt6zhpuYwnRz3VlBZ9KDOYqz0jdXStAdL2WYoO4TghDjtH6)Mxe1znyVW44xzhHUrsZUFp7yjn(k7S4L3sA8LNfcn7WcH6ldbLDqFHxJeKrblRz3VdhM7j7qLHYOtgIzN0gkTHLDuJrLYrxYuO(V5frDwd2lmovgkJodq(aqAaP)zNVBXrxYuO(V5frDwd2lm(siSOedacd4USgaYdq(aqAaRfhpHLkLBNJGh1a6DaykJbiv6a6BaRfhpHLkLBNJGtYmeQyasLoG0)SZ3T4xbJzR)B(2(cLVeclkXaGWaUlRbiFaRfhpHLkLBNJGtYmeQyaYhWAXXtyPs525i4rnaimG7YAaiNDSKgFLDw8YBjn(YZcHMDyHq9LHGYoOVWF9plkyzn7oMYk3t2HkdLrNmeZoPnuAdl7GI3A8RGXS1)nFBFHYXVgG8bOgJkL)OSqP104lovgkJozhHUrsZUFp7yjn(k7S4L3sA8LNfcn7WcH6ldbLDEuwO0AA8vwZUJ59CpzhQmugDYqm7K2qPnSStFdqqQh9lCbxdAXu26HZR0aKpa1yuP8hLfkTMgFXPYqz0zaYhq6F257w8RGXS1)nFBFHYxcHfLyaqya3L1aKpaKgawBddLrCH6VywvrbBasLoG1IJNWsLYTZrWjzgcvma5dyT44jSuPC7Ce8OgaegWDznaPshqFdyT44jSuPC7CeCsMHqfda5SJL04RSZIxElPXxEwi0SdleQVmeu25rzHsRPXx(R)zrblRz3XeZCpzhQmugDYqm7K2qPnSSJL0al5PIqeKya9kzayMDe6gjn7(9SJL04RSZIxElPXxEwi0SdleQVmeu2XEkRz3X0T5EYouzOm6KHy2XsA8v2jzmM3sA8LNfcn7WcH6ldbLDeQvhBpznRzNRLspcutZ9KD)EUNSdvgkJoziMD(RSJG0OLDsBO0gw2r3OGKuUENd1eECb5rXBTbiFainG(gGAmQuo6sMc1)nViQZAWEHXPYqz0zaYhasdq3OGKuUENN(ND(Uf)GVMgFnazZas)ZoF3IFfmMT(V5B7lu(bFnn(AasgGSgaYdqQ0bOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG0as)ZoF3IJUKPq9FZlI6SgSxy8d(AA81aKndq3OGKuUENN(ND(Uf)GVMgFnajdqwda5biv6auJrLYJeLSlovgkJoda5SZHePnU04RSdghwJHBkjgGnaDJcssfdi9p78DlxgWjWgh6mauxhWvWy2oGVnG2(cDa)oa0Lmf6a(2aerDwd2lSBIbK(ND(UfFaY(2ac9MyayngonaOMya1pGLqyrDODalP4BnG7UmaIjObSKIV1aKfxg8SdwB9LHGYo6gfKK6V7fUwPSJL04RSdwBddLrzhSgdN8etqzhzXLr2bRXWPSZ9SMDhZCpzhQmugDYqm78xzhbPrl7yjn(k7G12Wqzu2bRT(YqqzhDJcss9y6fUwPStAdL2WYo6gfKKYvm5qnHhxqEu8wBaYhasdOVbOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG0a0nkijLRyYt)ZoF3IFWxtJVgGSzaP)zNVBXVcgZw)38T9fk)GVMgFnajdqwda5biv6auJrLYrxYuO(V5frDwd2lmovgkJodq(aqAaP)zNVBXrxYuO(V5frDwd2lm(bFnn(AaYMbOBuqskxXKN(ND(Uf)GVMgFnajdqwda5biv6auJrLYJeLSlovgkJoda5SdwJHtEIjOSJS4Yi7G1y4u25EwZU72CpzhQmugDYqm78xzhbPrl7K2qPnSStFdq3OGKuUENd1eECb5rXBTbiFa6gfKKYvm5qnHhxqEu8wBasLoaDJcss5kMCOMWJlipkERna5daPbG0a0nkijLRyYt)ZoF3IFWxtJVgaChGUrbjPCftokER5p4RPXxda5b0bdaPbCNlJb0)a0nkijLRyYHAcpkERXf6sfmf6aqEaDWaqAayTnmugX1nkij1JPx4ALgaYda5b07aqAainaDJcss56DE6F257w8d(AA81aG7a0nkijLR35O4TM)GVMgFnaKhqhmaKgWDUmgq)dq3OGKuUENd1eEu8wJl0Lkyk0bG8a6GbG0aWAByOmIRBuqsQ)Ux4ALgaYda5SZHePnU04RSdgNqdeMsIbydq3OGKuXaWAmCAaOUoG0J4Y2OGnafknG0)SZ3TgW3gGcLgGUrbjPUmGtGno0zaOUoafknGd(AA81a(2auO0aqXBTbe6aU2hBCibFaYUnXaSbi0Lkyk0bG4prlODa6paybwAa2aGgWGs7aU243qDDa6paHUubtHoaDJcssfUmatmGUeJnatmaBai(t0cAhq73beTbydq3OGK0b0nySb87a6gm2aQxhGW1knGUHcDaP)zNVBj4zhS26ldbLD0nkij1FTXVH6A2XsA8v2bRTHHYOSdwJHtEIjOSZ9SdwJHtzhmZA2D4m3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzh1yuPCyMcL2OG5f6Vi4uzOm6maPshq6RdEOCclTT9fkNkdLrNbiv6aw8IA)cJ4OHgfmF6zhovgkJozhS26ldbLD2UEu8wtK1S7Yi3t2XsA8v2PXib00Ann7qLHYOtgIznRzN1sHXe5EYUFp3t2HkdLrNmeZowsJVYoOS)p(g(6A25qI0gxA8v2boWsHXgqhcnyHgKi7K2qPnSSdkERXVcgZw)38T9fkh)kRz3Xm3t2HkdLrNmeZoPnuAdl7GI3A8RGXS1)nFBFHYXVYowsJVYoO0kOfYOGL1S7Un3t2HkdLrNmeZoPnuAdl7G0a6BaO4Tg)kymB9FZ32xOC8RbiFawsdSKNkcrqIb0RKbG5aqEasLoG(gakERXVcgZw)38T9fkh)AaYhasdyXlIFOwKcDa9kzaYyaYhWIxrYF9DPLFOwKcDa9kzaDUSgaYzhlPXxzhBtwr(lCMGYA2D4m3t2HkdLrNmeZoPnuAdl7GI3A8RGXS1)nFBFHYXVYowsJVYoSaguv4HJk(bgcQ0SMDxg5EYouzOm6KHy2jTHsByzhu8wJFfmMT(V5B7luo(1aKpau8wJtiU(U06x8I8Dj76lo(v2XsA8v2XQej01y(KXyzn7ENN7j7qLHYOtgIzN0gkTHLDqXBn(vWy26)MVTVq5lHWIsmaiizaY2biFaO4Tg)kymB9FZ32xOC8RbiFaO4TgNqC9DP1V4f57s21xC8RSJL04RStlwcL9)jRz37W5EYouzOm6KHy2jTHsByzhu8wJFfmMT(V5B7luo(1aKpalPbwYtfHiiXaKmG7dq(aqAaO4Tg)kymB9FZ32xO8LqyrjgaegGmgG8bOgJkLNE2XdLSv5uzOm6maPshqFdqngvkp9SJhkzRYPYqz0zaYhakERXVcgZw)38T9fkFjewuIbaHb42bGC2XsA8v2b1G5)Mx3ibPiRzn7OBuqsQi3t2975EYouzOm6KHy25qI0gxA8v2PNnkijvKDkdbLDIsKwC1qzKhJHBLIJWFiSrIYoPnuAdl703auJrLYrxYuO(V5frDwd2lmovgkJodq(aqXBn(vWy26)MVTVq54xdq(aqXBnoH467sRFXlY3LSRV44xdqQ0bOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG0aqAaO4Tg)kymB9FZ32xOC8RbiFaP)zNVBXrxYuO(V5frDwd2lm(s2X1bG8aKkDainau8wJFfmMT(V5B7luo(1aKpaKgasdOfWGQ(Lqyrjgag)as)ZoF3IJUKPq9FZlI6SgSxy8LqyrjgaYdacdaZ7da5bG8aqEasLoa0xigG8b0cyqv)siSOedacdaZ7dqQ0bCitH6HScyqv(jegkJ8bg74jzsjCLgGKbiRbiFaQTWiLRbcYRV)kPEmL1aGWaKr2XsA8v2jkrAXvdLrEmgUvkoc)HWgjkRz3Xm3t2HkdLrNmeZoLHGYoIKTc)38T1uAlJ5f6gnk7yjn(k7is2k8FZ3wtPTmMxOB0OSMD3T5EYouzOm6KHy2XsA8v2rHs(wSc1lcybl7K2qPnSSdkERXVcgZw)38T9fkh)AaYhakERXjexFxA9lEr(UKD9fh)k7ugck7OqjFlwH6fbSGL1S7WzUNSdvgkJoziMDSKgFLD0nkij9E25qI0gxA8v2PhO0a0nkijDaDdf6auO0aGgWGscDaKqdeMsNbG1y4KldOBWydaLgaUGodOfRqhGvNbCzXsNb0nuOdaJoymBhW3gaC8(cLNDsBO0gw2PVbG12WqzexCrPOf0XRBuqs6aKpau8wJFfmMT(V5B7luo(1aKpaKgqFdqngvkpsuYU4uzOm6maPshGAmQuEKOKDXPYqz0zaYhakERXVcgZw)38T9fkFjewuIb0RKbCxwda5biFainG(gGUrbjPCftout4t)ZoF3AasLoaDJcss5kM80)SZ3T4lHWIsmaPshawBddLrCDJcss9xB8BOUoajd4(aqEasLoaDJcss56DokER5p4RPXxdOxjdOfWGQ(LqyrjYA2DzK7j7qLHYOtgIzN0gkTHLD6BayTnmugXfxukAbD86gfKKoa5dafV14xbJzR)B(2(cLJFna5daPb03auJrLYJeLSlovgkJodqQ0bOgJkLhjkzxCQmugDgG8bGI3A8RGXS1)nFBFHYxcHfLya9kza3L1aqEaYhasdOVbOBuqskxVZHAcF6F257wdqQ0bOBuqskxVZt)ZoF3IVeclkXaKkDayTnmugX1nkij1FTXVH66aKmamhaYdqQ0bOBuqskxXKJI3A(d(AA81a6vYaAbmOQFjewuISJL04RSJUrbjPyM1S7DEUNSdvgkJoziMDSKgFLD0nkij9E2rWEn7OBuqs69StAdL2WYo9naS2ggkJ4IlkfTGoEDJcsshG8bG0a6Ba6gfKKY17COMWJlipkERna5daPbOBuqskxXKN(ND(UfFjewuIbiv6a6Ba6gfKKYvm5qnHhxqEu8wBaipaPshq6F257w8RGXS1)nFBFHYxcHfLya9oamL1aqo7CirAJln(k7i7Bd4lMRd4lAaFnaCbnaDJcsshW1(yJdjgGnau8wZLbGlObOqPb8kuAhWxdi9p78Dl(aWO2beTbuuOqPDa6gfKKoGR9XghsmaBaO4TMldaxqda9vOd4RbK(ND(UfpRz37W5EYouzOm6KHy2XsA8v2r3OGKumZoPnuAdl703aWAByOmIlUOu0c641nkijDaYhasdOVbOBuqskxXKd1eECb5rXBTbiFainaDJcss56DE6F257w8LqyrjgGuPdOVbOBuqskxVZHAcpUG8O4T2aqEasLoG0)SZ3T4xbJzR)B(2(cLVeclkXa6DaykRbGC2rWEn7OBuqskMznRzN0JLkRurUNS73Z9KDOYqz0jdXSJL04RSZHmfQWFWPSZHePnU04RSJBESuzLoGoeAWcnir2jTHsByzhKgqFdqngvk)rzHsRPXxCQmugDgGuPdqngvk)rzHsRPXxCQmugDgG8byjnWsEQiebjgqVsgaMdq(as)ZoF3IFfmMT(V5B7lu(siSOedqQ0byjnWsEQiebjgGKbCFaipa5daPbG12WqzexO(lMvvuWgGuPdaRTHHYiUDoc)siSOgaYzn7oM5EYouzOm6KHy2jTHsByzNfVIK)67sl)qTif6a6Da3D7aKpG0)SZ3T4xbJzR)B(2(cLVeclkXaGWaC7aKpG(gGAmQuo6sMc1)nViQZAWEHXPYqz0zaYhawBddLrCH6Vywvrbl7yjn(k7i6AlIOG5recnRz3DBUNSdvgkJoziMDsBO0gw2PVbOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG12Wqze3ohHFjewuzhlPXxzhrxBrefmpIqOzn7oCM7j7qLHYOtgIzN0gkTHLDuJrLYrxYuO(V5frDwd2lmovgkJodq(aqAaO4TghDjtH6)Mxe1znyVW44xdq(aqAayTnmugXfQ)IzvffSbiFalEfj)13Lw(HArk0b07aGtznaPshawBddLrC7Ce(Lqyrna5dyXRi5V(U0YpulsHoGEhqNlRbiv6aWAByOmIBNJWVeclQbiFaRfhpHLkLBNJGVeclkXaGWaGdhG8bSwC8ewQuUDocojZqOIbG8aKkDa9nau8wJJUKPq9FZlI6SgSxyC8RbiFaP)zNVBXrxYuO(V5frDwd2lm(siSOeda5SJL04RSJORTiIcMhri0SMDxg5EYouzOm6KHy2jTHsByzN0)SZ3T4xbJzR)B(2(cLVeclkXaGWaC7aKpaS2ggkJ4c1FXSQIc2aKpaKgGAmQuo6sMc1)nViQZAWEHXPYqz0zaYhWIxrYF9DPDa9oGoxgdq(as)ZoF3IJUKPq9FZlI6SgSxy8LqyrjgaegaMdqQ0b03auJrLYrxYuO(V5frDwd2lmovgkJoda5SJL04RSJH(iIY04lplqGM1S7DEUNSdvgkJoziMDsBO0gw2bRTHHYiUDoc)siSOYowsJVYog6JiktJV8SabAwZU3HZ9KDOYqz0jdXStAdL2WYoyTnmugXfQ)IzvffSbiFainG0)SZ3T4xbJzR)B(2(cLVeclkXaGWaC7aKkDaQXOs5rIs2fNkdLrNbGC2XsA8v2ra1sqYiVcL84v3FvOUM1S7Y2CpzhQmugDYqm7K2qPnSSdwBddLrC7Ce(LqyrLDSKgFLDeqTeKmYRqjpE19xfQRzn7oCyUNSdvgkJoziMDsBO0gw2PVbGI3A8RGXS1)nFBFHYXVgG8bG0aepodnQd)cxO4mYtl(LgFXPYqz0zasLoaXJZqJ6WX(mtdg5fpdlvkNkdLrNbiFa9nau8wJJ9zMgmYlEgwQuo(1aqo7eLs7IFP(OLDepodnQdh7ZmnyKx8mSuPzNOuAx8l1hiqqNWuk7Cp7yjn(k70yKaAATMMDIsPDXVupm2JASSZ9SM1SJ9uUNS73Z9KDOYqz0jdXSZHePnU04RSth6X4gaCWRMgFLDSKgFLDwcXVcIrcHVBukTzn7oM5EYouzOm6KHy2jTHsByzh1yuP82(cvKCvHsCQmugDYowsJVYoWywkmM3oyTkrzn7UBZ9KDOYqz0jdXStAdL2WYoO4TghYGXIcMhHLGgfXxYs6aKpG(gawBddLr8dzkuH)GtElPbwk7yjn(k702xOIKRkukRz3HZCpzhQmugDYqm7K2qPnSSdwBddLr891wYVbcAaYhGAmQuUH1ywLGsCQmugDYowsJVYoq)USOG5rzMqZA2DzK7j7qLHYOtgIzN0gkTHLD6BaO4TgFdeeh)AaYhGL0al5PIqeKyaqqYaC7aKkDawsdSKNkcrqIb07aCB2XsA8v2bgZsHX82bRvjkRz378CpzhQmugDYqm7yjn(k702xOEHUbKu2j5AIrE1wyKkYUFp7K2qPnSSt6F257w8Lq8RGyKq47gLslFjewuIbabjdaZb0bdaw6ma5dqngvkhMPqPnkyEH(lcovgkJozNdjsBCPXxzh44FrGZSina76AFlbDa6pG0sMsdWgWLGWp)aU243qDDaQTWiDaSqOdO97aSRlMRrbBaR1z)gjAarna7PSMDVdN7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nqqzhlPXxzhOFxwuW8OmtOzn7USn3t2HkdLrNmeZoPnuAdl7OgJkLdZuO0gfmVq)fbNkdLrNbiFaO4TgFje)kigje(UrP0YXVgG8byjnWsEQiebjgqVdaZbiFa9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZUdhM7j7qLHYOtgIzN0gkTHLDWAByOmIFitHk8hCYBjnWsdq(aqXBn(HmfQWFWjUqTeKdacdaohGuPdqngvkhMPqPnkyEH(lcovgkJodq(aqXBn(si(vqmsi8DJsPLJFLDSKgFLDEuwO0AkL1S73LvUNSdvgkJoziMDSKgFLDA7luVq3ask7K2qPnSSZIxrYF9DPLFOwKcDaqyainG7Yya9pa1yuP8fVIK3uLkCtJV4uzOm6mGoyaYyaiNDsUMyKxTfgPIS73ZA2973Z9KDOYqz0jdXStAdL2WYo9naS2ggkJ4hYuOc)bN8wsdSu2XsA8v2PTVqfjxvOuwZUFhZCpzhQmugDYqm7yjn(k78OSqP1uk7K2qPnSSZIxrYF9DPLFOwKcDa9oaKgaMYya9pa1yuP8fVIK3uLkCtJV4uzOm6mGoyaYyaiNDsUMyKxTfgPIS73ZA297Un3t2XsA8v2bgZsHX82bRvjk7qLHYOtgIzn7(D4m3t2XsA8v2PTVqfjxvOu2HkdLrNmeZA297Yi3t2HkdLrNmeZowsJVYoT9fQxOBajLDsUMyKxTfgPIS73ZA297DEUNSJL04RSd0Fl)38DJsPn7qLHYOtgIzn7(9oCUNSJL04RSJTjRiV(7sLMDOYqz0jdXSM1SMDWsRi(k7oMYctmLfMy25zNU2wrbtKDKD6qWbUl7DhoshhWa6bknGaX1V6aA)oGBpkluAnn(YF9plky3gWsym8yPZaepcAagU(imLodib1kyKGpW3POObGzhhGB(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTby6aW4WO60aq6UmrMpWpWl70HGdCx27oCKooGb0duAabIRF1b0(Da3sp74Hs2Q3gWsym8yPZaepcAagU(imLodib1kyKGpW3POObCVJdWnFHLwLod42Ixu7xyehd3gG(d42Ixu7xyehdCQmugDUnaKGtzImFGVtrrdaZooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdaP7Yez(aFNIIgGB74aCZxyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnaKUltK5d8DkkAaWzhhGB(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFGVtrrdqgDCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8b(bEzNoeCG7YE3HJ0XbmGEGsdiqC9RoG2Vd42JYcLwtJVUnGLWy4XsNbiEe0amC9rykDgqcQvWibFGVtrrdaZooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdaP7Yez(aFNIIgaMDCaU5lS0Q0za3sFDWdLJHBdq)bCl91bpuog4uzOm6CBaiDxMiZh47uu0aUlRooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdajmLjY8b(bEzNoeCG7YE3HJ0XbmGEGsdiqC9RoG2Vd4g6l8AKGmky3gWsym8yPZaepcAagU(imLodib1kyKGpW3POObCVJdWnFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aq6UmrMpW3POObGzhhGB(clTkDgGtGWndq4APMmhGSza6pGoHBd4eydr81a(lAn93bGeCrEaiDxMiZh47uu0aCBhhGB(clTkDgGtGWndq4APMmhGSza6pGoHBd4eydr81a(lAn93bGeCrEaiDxMiZh47uu0aGZooa38fwAv6maNaHBgGW1snzoazZa0FaDc3gWjWgI4Rb8x0A6Vdaj4I8aq6UmrMpW3POObaNDCaU5lS0Q0za3w8IA)cJ4y42a0Fa3w8IA)cJ4yGtLHYOZTbG0DzImFGFGx2Pdbh4US3D4iDCadOhO0acex)QdO97aULESuzLkUnGLWy4XsNbiEe0amC9rykDgqcQvWibFGVtrrd4EhhGB(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbGeMYez(aFNIIgaMDCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8b(offna32Xb4MVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiDxMiZh47uu0aGZooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdaP7Yez(aFNIIgGm64aCZxyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnaKWuMiZh47uu0a6WDCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8b(offna4Wooa38fwAv6mGBIhNHg1HJHBdq)bCt84m0OoCmWPYqz052aqctzImFGFGx2Pdbh4US3D4iDCadOhO0acex)QdO97aUjuRo2EUnGLWy4XsNbiEe0amC9rykDgqcQvWibFGVtrrdOZ74aCZxyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnathaghgvNgas3LjY8b(offnazBhhGB(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFGVtrrdaoSJdWnFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aqYTYez(a)aVSthcoWDzV7Wr64agqpqPbeiU(vhq73bCd9f(R)zrb72awcJHhlDgG4rqdWW1hHP0zajOwbJe8b(offna4SJdWnFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aq6UmrMpW3POObiJooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdaP7Yez(a)aVSthcoWDzV7Wr64agqpqPbeiU(vhq73bC7AP0Ja10BdyjmgES0zaIhbnadxFeMsNbKGAfmsWh47uu0aU3Xb4MVWsRsNb4eiCZaeUwQjZbiBKndq)b0jCBai(dodxmG)Iwt)DaijBqEaiHPmrMpW3POObCVJdWnFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aqYTYez(aFNIIgW9ooa38fwAv6mGB6gfKKYVZXWTbO)aUPBuqskxVZXWTbGKBLjY8b(offnam74aCZxyPvPZaCceUzacxl1K5aKnYMbO)a6eUnae)bNHlgWFrRP)oaKKnipaKWuMiZh47uu0aWSJdWnFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aqYTYez(aFNIIgaMDCaU5lS0Q0za30nkijLJjhd3gG(d4MUrbjPCftogUnaKCRmrMpW3POOb42ooa38fwAv6maNaHBgGW1snzoazZa0FaDc3gWjWgI4Rb8x0A6Vdaj4I8aqctzImFGVtrrdWTDCaU5lS0Q0za30nkijLFNJHBdq)bCt3OGKuUENJHBdaj4uMiZh47uu0aCBhhGB(clTkDgWnDJcss5yYXWTbO)aUPBuqskxXKJHBdajzitK5d8DkkAaWzhhGB(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFGVtrrdao74aCZxyPvPZaUT4f1(fgXXWTbO)aUT4f1(fgXXaNkdLrNBdW0bGXHr1PbG0DzImFGVtrrdao74aCZxyPvPZaUL(6Ghkhd3gG(d4w6RdEOCmWPYqz052aq6UmrMpWpWl70HGdCx27oCKooGb0duAabIRF1b0(Da3s)ZoF3sCBalHXWJLodq8iOby46JWu6mGeuRGrc(aFNIIgaMDCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8b(offnam74aCZxyPvPZaUjECgAuhogUna9hWnXJZqJ6WXaNkdLrNBdajmLjY8b(offna32Xb4MVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiDxMiZh47uu0aCBhhGB(clTkDgWTfVO2VWiogUna9hWTfVO2VWiog4uzOm6CBaiDxMiZh47uu0aGZooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdW0bGXHr1PbG0DzImFGVtrrdqgDCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8b(offnGoVJdWnFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aq6UmrMpW3POOb0H74aCZxyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnaKUltK5d8DkkAaWHDCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8b(offnG7374aCZxyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnaKUltK5d8DkkAa3XSJdWnFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aqctzImFGVtrrd4Um64aCZxyPvPZaUT4f1(fgXXWTbO)aUT4f1(fgXXaNkdLrNBdW0bGXHr1PbG0DzImFGFGx2Pdbh4US3D4iDCadOhO0acex)QdO97aUPBuqsQ42awcJHhlDgG4rqdWW1hHP0zajOwbJe8b(offnG7DCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gasyktK5d8DkkAaWzhhGB(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbGeMYez(aFNIIgaC2Xb4MVWsRsNbCt3OGKu(DogUna9hWnDJcss56DogUnaKUltK5d8DkkAaWzhhGB(clTkDgWnDJcss5yYXWTbO)aUPBuqskxXKJHBdajmLjY8b(offnaz0Xb4MVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiHPmrMpW3POObiJooa38fwAv6mGB6gfKKYVZXWTbO)aUPBuqskxVZXWTbGeMYez(aFNIIgGm64aCZxyPvPZaUPBuqskhtogUna9hWnDJcss5kMCmCBaiDxMiZh47uu0a68ooa38fwAv6mGB6gfKKYVZXWTbO)aUPBuqskxVZXWTbG0DzImFGVtrrdOZ74aCZxyPvPZaUPBuqskhtogUna9hWnDJcss5kMCmCBaiHPmrMpW3POOb0H74aCZxyPvPZaUPBuqsk)ohd3gG(d4MUrbjPC9ohd3gasyktK5d8DkkAaD4ooa38fwAv6mGB6gfKKYXKJHBdq)bCt3OGKuUIjhd3gas3LjY8b(bEzNoeCG7YE3HJ0XbmGEGsdiqC9RoG2Vd42HAgotVnGLWy4XsNbiEe0amC9rykDgqcQvWibFGVtrrdqgDCaU5lS0Q0za3w8IA)cJ4y42a0Fa3w8IA)cJ4yGtLHYOZTbGeMYez(aFNIIgqN3Xb4MVWsRsNbCl91bpuogUna9hWT0xh8q5yGtLHYOZTbG0DzImFGVtrrdq22Xb4MVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBai5wzImFGVtrrdaoSJdWnFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052aqYTYez(aFNIIgWDz1Xb4MVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaibNYez(aFNIIgW97DCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gasWPmrMpW3POObChZooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdajmLjY8b(offnG7D4ooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdajmLjY8b(offnG7WHDCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8b(offnamLvhhGB(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTby6aW4WO60aq6UmrMpW3POObG59ooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdaP7Yez(a)aVSthcoWDzV7Wr64agqpqPbeiU(vhq73bCZE62awcJHhlDgG4rqdWW1hHP0zajOwbJe8b(offnam74aCZxyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnathaghgvNgas3LjY8b(offna4SJdWnFHLwLod4MAmQuogUna9hWn1yuPCmWPYqz052amDayCyuDAaiDxMiZh47uu0a68ooa38fwAv6mGBQXOs5y42a0Fa3uJrLYXaNkdLrNBdW0bGXHr1PbG0DzImFGVtrrdq22Xb4MVWsRsNbCtngvkhd3gG(d4MAmQuog4uzOm6CBaiDxMiZh47uu0aGd74aCZxyPvPZaUPgJkLJHBdq)bCtngvkhdCQmugDUnaKUltK5d8DkkAa3LvhhGB(clTkDgWn1yuPCmCBa6pGBQXOs5yGtLHYOZTbG0DzImFGVtrrd4oMDCaU5lS0Q0za3uJrLYXWTbO)aUPgJkLJbovgkJo3gas3LjY8b(bEzpIRFv6mG7UDawsJVgaleQGpWNDexuk7oMY4E25A)wWOSdgbJmazxKPqhaC0vadQoa449f6apgbJma4ycDXT11bGPS1LbGPSWeZb(bEmcgzaUbQvWiXapgbJmam(bahqiES0zamtOy8ck91za4cdgnGVna3a1IsmGVnazFIgGjgqOd48KOUPd4IzUoGUeJnGOgW1AjnseFGhJGrgag)aKD91nDajOwveBaWXmsanTwthWbFJc2aG4sMcDaFBaorDwd2lm(a)apgzayCyngUPKya2a0nkijvmG0)SZ3TCzaNaBCOZaqDDaxbJz7a(2aA7l0b87aqxYuOd4Bdqe1znyVWUjgq6F257w8bi7Bdi0BIbG1y40aGAIbu)awcHf1H2bSKIV1aU7YaiMGgWsk(wdqwCzWh4TKgFj4xlLEeOM2Ve4I12WqzKlLHGKOBuqsQ)Ux4ALC5VKiinAUG1y4KK7UG1y4KNycsIS4YWL0xNqJVKOBuqsk)ohQj84cYJI3AYrQp1yuPC0LmfQ)BEruN1G9ctos6gfKKYVZt)ZoF3IFWxtJVKnYM0)SZ3T4xbJzR)B(2(cLFWxtJVKilKLkvngvkhDjtH6)Mxe1znyVWKJu6F257wC0LmfQ)BEruN1G9cJFWxtJVKnYgDJcss535P)zNVBXp4RPXxsKfYsLQgJkLhjkzxipWBjn(sWVwk9iqnTFjWfRTHHYixkdbjr3OGKupMEHRvYL)sIG0O5cwJHtsU7cwJHtEIjijYIldxsFDcn(sIUrbjPCm5qnHhxqEu8wtos9PgJkLJUKPq9FZlI6SgSxyYrs3OGKuoM80)SZ3T4h8104lzJSj9p78Dl(vWy26)MVTVq5h8104ljYczPsvJrLYrxYuO(V5frDwd2lm5iL(ND(UfhDjtH6)Mxe1znyVW4h8104lzJSr3OGKuoM80)SZ3T4h8104ljYczPsvJrLYJeLSlKh4XidaJtObctjXaSbOBuqsQyayngonauxhq6rCzBuWgGcLgq6F257wd4BdqHsdq3OGKuxgWjWgh6mauxhGcLgWbFnn(AaFBakuAaO4T2acDax7JnoKGpaz3Mya2ae6sfmf6aq8NOf0oa9haSalnaBaqdyqPDaxB8BOUoa9hGqxQGPqhGUrbjPcxgGjgqxIXgGjgGnae)jAbTdO97aI2aSbOBuqs6a6gm2a(DaDdgBa1Rdq4ALgq3qHoG0)SZ3Te8bElPXxc(1sPhbQP9lbUyTnmug5sziij6gfKK6V243qD1L)sIG0O5cwJHtsW0fSgdN8etqsU7s6RtOXxs6t3OGKu(Dout4XfKhfV1KRBuqskhtout4XfKhfV1Kkv3OGKuoMCOMWJlipkERjhjK0nkijLJjp9p78Dl(bFnn(s2OBuqskhtokER5p4RPXxi3biDNlJ(1nkijLJjhQj8O4TgxOlvWuOi3biH12Wqzex3OGKupMEHRvczK7fjK0nkijLFNN(ND(Uf)GVMgFjB0nkijLFNJI3A(d(AA8fYDas35YOFDJcss535qnHhfV14cDPcMcf5oajS2ggkJ46gfKK6V7fUwjKrEG3sA8LGFTu6rGAA)sGlwBddLrUugcsY21JI3AcxWAmCsIAmQuomtHsBuW8c9xesLM(6GhkNWsBBFHkv6Ixu7xyehn0OG5tp7mWBjn(sWVwk9iqnTFjWTXib00AnDGFGhJGrgagNmPeUsNbqyP11bObcAakuAaws)DaHyagwlygkJ4d8wsJVesqe1X3wI6mAGhJmam6LWsLoaXfLIwqNbOBuqsQyaOuuWgaUGodOBOqhGHRpctJ0ayrrIbElPXxI(LaxS2ggkJCPmeKeXfLIwqhVUrbjPUG1y4KeKimgECDrhEuI0IRgkJ8ymCRuCe(dHnsKuPegdpUUOdxHs(wSc1lcybdz5iL(ND(UfpkrAXvdLrEmgUvkoc)HWgjIVKDCvQ00)SZ3T4kuY3IvOEraly8LqyrjqwQucJHhxx0HRqjFlwH6fbSGjNWy4X1fD4rjslUAOmYJXWTsXr4pe2ird8wsJVe9lbUyTnmug5sziijc1FXSQIcMlyngojXsAGL8uricsi5UCKwloEclvk3ohbpQEVldPs7BT44jSuPC7CeCsMHqfipWBjn(s0Ve4I12WqzKlLHGKyNJWVeclkxWAmCsIL0al5PIqeKOxjykhP(wloEclvk3ohbNKziuHuPRfhpHLkLBNJGtYmeQqosRfhpHLkLBNJGVeclkrVYqQ0wadQ6xcHfLO37YczKh4TKgFj6xcCXAByOmYLYqqs2xBj)giixWAmCsckERX3abXXVKJuFlErTFHr81Gr(V5vOKVTFNrLpb1qCfFjv6Ixu7xyeFnyK)BEfk5B73zu5tqnexXxYx8ks(RVlT8d1IuO9kBrEG3sA8LOFjWfRTHHYixkdbjPTVq9cDdijF6RdEOcxWAmCss6RdEOCATtKmnkyEu23vokERXP1orY0OG5rzFxUqTeKsWuQ00xh8q54fJmbu64BlvDMRYrXBnoEXitaLo(2svN5kFjewuciGeS0PdWe5bElPXxI(LaxS2ggkJCPmeKKdzkuH)GtElPbwYfSgdNKCitH6T64puYCLRrcYOGjp9yPYkLxbmOQVz0apgzaDORlMRdaoEFHoa4yclTUmaewuQf1aK9jxhqpg7lXaS6maij6AaWbeIFfeJeIbi7eLs7a2NXIc2aVL04lr)sG7si(vqmsi8DJsP1LOjj91bpuoHL22(cvUAmQuomtHsBuW8c9xeYrQp1yuP8hLfkTMgFjp9p78Dl(vWy26)MVTVq5lHWIsivQGup6x4cUg0IPS1dNxj5QXOs5pkluAnn(sEFO4Tg)kymB9FZ32xOC8lKh4TKgFj6xcCH(DzrbZJYmH6sY1eJ8QTWivi5UlrtsFNx5T9fQVryPLVeclkHCKuJrLYJeLSlPs7dfV14Olzku)38IOoRb7fgh)sUAmQuo6sMc1)nViQZAWEHjvQAmQu(JYcLwtJVKN(ND(Uf)kymB9FZ32xO8LqyrjK3hkERXHmySOG5ryjOrrC8lKh4TKgFj6xcCHXSuymVDWAvICjAsqXBnEKC1Rg7lbFjewuciibw60bykxngvkpsU6vJ9LqU4IymVAlmsfCymlfgZBhSwLOELGPCKuJrLYJeLSlPsvJrLYrxYuO(V5frDwd2lm5P)zNVBXrxYuO(V5frDwd2lm(siSOe9ExgsLQgJkL)OSqP104l59HI3A8RGXS1)nFBFHYXVqEG3sA8LOFjWTTVq9cDdijxIMeu8wJhjx9QX(sWxcHfLacsGLoDaMYvJrLYJKRE1yFjKJKAmQuEKOKDjvQAmQuo6sMc1)nViQZAWEHjVpu8wJJUKPq9FZlI6SgSxyC8l5P)zNVBXrxYuO(V5frDwd2lm(siSOe9ExwsLQgJkL)OSqP104l59HI3A8RGXS1)nFBFHYXVqEG3sA8LOFjW9rzHsRPKlrts6XsLvkVcyqvFZi5hYuOERo(dLmx5AKGmkyYpKPq9wD8hkzUYTKgyj)siSOeqajyPthCNldKLJuFQXOs5pkluAnn(sQu1yuP8hLfkTMgFjVpu8wJFfmMT(V5B7luo(fYd8yKb4gO)lOb0HsA81ayHqhG(dyXRbElPXxI(La3KXyElPXxEwiuxkdbjj9yPYkvmWBjn(s0Ve4MmgZBjn(YZcH6sziijRLcJjg4TKgFj6xcCtgJ5TKgF5zHqDPmeKeDJcssfd8wsJVe9lbUjJX8wsJV8SqOUugcss6F257wIbElPXxI(La3KXyElPXxEwiuxkdbjj9SJhkzR6Iq3iPsU7s0KOgJkLNE2XdLSvLJuFO4TghYGXIcMhHLGgfXXVKkvngvkhDjtH6)Mxe1znyVWqwoshcfV14R1z)gjIlulbPezivAFhYuOEiRaguLV4f1(fgXxRZ(nseYd8wsJVe9lbUlE5TKgF5zHqDPmeKe0x41ibzuWCrOBKuj3DjAsqXBno6sMc1)nViQZAWEHXXVg4TKgFj6xcCx8YBjn(YZcH6sziijOVWF9plkyUenjQXOs5Olzku)38IOoRb7fMCKs)ZoF3IJUKPq9FZlI6SgSxy8LqyrjGWDzHSCKwloEclvk3ohbpQEXugsL23AXXtyPs525i4KmdHkKkn9p78Dl(vWy26)MVTVq5lHWIsaH7Ys(AXXtyPs525i4KmdHkKVwC8ewQuUDocEuq4USqEG3sA8LOFjWDXlVL04lpleQlLHGK8OSqP104lxe6gjvYDxIMeu8wJFfmMT(V5B7luo(LC1yuP8hLfkTMgFnWBjn(s0Ve4U4L3sA8LNfc1LYqqsEuwO0AA8L)6FwuWCjAs6tqQh9lCbxdAXu26HZRKC1yuP8hLfkTMgFjp9p78Dl(vWy26)MVTVq5lHWIsaH7YsosyTnmugXfQ)IzvffmPsxloEclvk3ohbNKziuH81IJNWsLYTZrWJcc3LLuP9TwC8ewQuUDocojZqOcKh4TKgFj6xcCx8YBjn(YZcH6sziij2tUi0nsQK7UenjwsdSKNkcrqIELG5aVL04lr)sGBYymVL04lpleQlLHGKiuRo2Eg4h4XidOd9yCdao4vtJVg4TKgFj42tswcXVcIrcHVBukTd8wsJVeC7P(LaxymlfgZBhSwLixIMe1yuP82(cvKCvHsd8wsJVeC7P(La32(cvKCvHsUenjO4TghYGXIcMhHLGgfXxYsQ8(WAByOmIFitHk8hCYBjnWsd8wsJVeC7P(LaxOFxwuW8OmtOUenjyTnmugX3xBj)gii5QXOs5gwJzvcknWBjn(sWTN6xcCHXSuymVDWAvICjAs6dfV14BGG44xYTKgyjpveIGeqqIBLk1sAGL8urics0RBh4Xidao(xe4mlsdWUU23sqhG(diTKP0aSbCji8ZpGRn(nuxhGAlmshale6aA)oa76I5AuWgWAD2VrIgqudWEAG3sA8LGBp1Ve422xOEHUbKKljxtmYR2cJuHK7UenjP)zNVBXxcXVcIrcHVBukT8LqyrjGGem7ayPJC1yuPCyMcL2OG5f6Vig4TKgFj42t9lbUq)USOG5rzMqDjAsWAByOmIVV2s(nqqd8wsJVeC7P(La32(cvKCvHsUenjQXOs5WmfkTrbZl0FrihfV14lH4xbXiHW3nkLwo(LClPbwYtfHiirVykVpS2ggkJ4hYuOc)bN8wsdS0aVL04lb3EQFjW9rzHsRPKlrtcwBddLr8dzkuH)GtElPbwsokERXpKPqf(doXfQLGecWPuPQXOs5WmfkTrbZl0FrihfV14lH4xbXiHW3nkLwo(1aVL04lb3EQFjWTTVq9cDdijxsUMyKxTfgPcj3DjAsw8ks(RVlT8d1IuOqaP7YOF1yuP8fVIK3uLkCtJV6azG8aVL04lb3EQFjWTTVqfjxvOKlrtsFyTnmugXpKPqf(do5TKgyPbElPXxcU9u)sG7JYcLwtjxsUMyKxTfgPcj3DjAsw8ks(RVlT8d1IuO9IeMYOF1yuP8fVIK3uLkCtJV6azG8aVL04lb3EQFjWfgZsHX82bRvjAG3sA8LGBp1Ve422xOIKRkuAG3sA8LGBp1Ve422xOEHUbKKljxtmYR2cJuHK7d8wsJVeC7P(LaxO)w(V57gLs7aVL04lb3EQFjW12KvKx)DPsh4h4XidaIlzk0b8Tb4e1znyVWgW1)SOGnG9vtJVgqhhGqTvfd4USedaLA)sdaIVZacXamSwWmugnWBjn(sWrFH)6FwuWKSeIFfeJecF3OuADjAsSKgyjpveIGe9kbtPsXAByOmIVD9O4TMyG3sA8LGJ(c)1)SOG1Ve4(OSqP1uYLKRjg5vBHrQqYDxIMeu8wJdzWyrbZJWsqJI4lzjvE6F257w8RGXS1)nFBFHYxcHfLOx3oWBjn(sWrFH)6FwuW6xcCH(DzrbZJYmH6s0KG12WqzeFFTL8BGGg4TKgFj4OVWF9plky9lbUT9fQi5QcLCjAsqXBnoKbJffmpclbnkIVKLu5lEfj)13Lw(HArk0Er6Um6xngvkFXRi5nvPc304RoqgilxCrmMxTfgPcEBFHksUQqPEXuEFyTnmugXpKPqf(do5TKgyPbElPXxco6l8x)ZIcw)sGBBFHksUQqjxIMKfVIK)67sl)qTifAVsqYTYOF1yuP8fVIK3uLkCtJV6azGSCXfXyE1wyKk4T9fQi5QcL6ft59H12Wqze)qMcv4p4K3sAGLg4XiyKbCtTfgP(OjbHjZoI0HqXBn(AD2VrI4c1sq2)DKLniDiu8wJVwN9BKi(siSOe9Fh5o4qMc1dzfWGQ8fVO2VWi(AD2VrIUna4a6ImvmaBaSxDzak0qmGqmGOuQo0za6pa1wyKoafknaObmOKqhW1g)gQRdGkcHRdOBOqhGvdWqdwOUoafQPdOBWydWUUyUoG16SFJenGOnGfVO2VWOdFa9a10bGsrbBawnaQieUoGUHcDaYAac1sqkCza)oaRgavecxhGc10bOqPbCiu8wBaDdgBaI)RbqY8kwAaFXh4TKgFj4OVWF9plky9lbUpkluAnLCj5AIrE1wyKkKC3LOjzXRi5V(U0YpulsH2RemLXaVL04lbh9f(R)zrbRFjWfgZsHX82bRvjYLOjzXRi5V(U0YpulsHcbmLLCXfXyE1wyKk4WywkmM3oyTkr9kbt5P)zNVBXVcgZw)38T9fkFjewuIELXaVL04lbh9f(R)zrbRFjWTTVq9cDdijxsUMyKxTfgPcj3DjAsw8ks(RVlT8d1IuOqatzjp9p78Dl(vWy26)MVTVq5lHWIs0Rmg4TKgFj4OVWF9plky9lbUWywkmM3oyTkrUenjP)zNVBXVcgZw)38T9fkFjewuIEx8I4AGG867Ht5lEfj)13Lw(HArkuiaNYsU4IymVAlmsfCymlfgZBhSwLOELG5aVL04lbh9f(R)zrbRFjWTTVq9cDdijxsUMyKxTfgPcj3DjAss)ZoF3IFfmMT(V5B7lu(siSOe9U4fX1ab513dNYx8ks(RVlT8d1IuOqaoL1a)apgzaqCjtHoGVnaNOoRb7f2a6qjnWsdao4vtJVg4TKgFj4OVWRrcYOGj5rzHsRPKljxtmYR2cJuHK7UenjlEfj)13Lwiibj4ug9RgJkLV4vK8MQuHBA8vhidKh4TKgFj4OVWRrcYOG1Ve4UeIFfeJecF3OuADjAsWAByOmIVD9O4TMqQulPbwYtfHiirVsWuQ0fVIK)67sleClMYx8I4AGG867XeclEfj)13LwzZ9oFG3sA8LGJ(cVgjiJcw)sG7HmfQ3QJ)qjZvxIMKfVIK)67sleClMYx8I4AGG867XeclEfj)13LwzZ9oFG3sA8LGJ(cVgjiJcw)sGl0VllkyEuMjuxIMeS2ggkJ47RTKFdeKCKw8ks(RVlT9kboLHuPlErCnqqE99UfcsGLosLU4f1(fgXxdg5)MxHs(2(Dgv(eudXv8LuPIlIX8QTWivWH(DzrbZJYmH2RemLkffV14BGG4lHWIsab3ISuPlEfj)13Lwi4wmLV4fX1ab513Jjew8ks(RVlTYM7D(aVL04lbh9fEnsqgfS(La32(cvKCvHsUenjO4TghYGXIcMhHLGgfXXVKlUigZR2cJubVTVqfjxvOuVykVpS2ggkJ4hYuOc)bN8wsdS0aVL04lbh9fEnsqgfS(La3hLfkTMsUKCnXiVAlmsfsU7s0KGI3ACidglkyEewcAueFjlPd8wsJVeC0x41ibzuW6xcCH(B5)MVBukTUenjlEfj)13LwiiPZLL8fViUgiiV(E32lS0zG3sA8LGJ(cVgjiJcw)sGBBFHksUQqjxIMeXfXyE1wyKk4T9fQi5QcL6ft59H12Wqze)qMcv4p4K3sAGLg4TKgFj4OVWRrcYOG1Ve4(OSqP1uYLKRjg5vBHrQqYDxIMKfVIK)67sl)qTifAVykdPsx8I4AGG867DleGLod8wsJVeC0x41ibzuW6xcCH(DzrbZJYmH6s0KG12WqzeFFTL8BGGg4TKgFj4OVWRrcYOG1Ve4ABYkYR)UuPUenjlEfj)13LwiidznWpWpWJrWidWnp7maz3KT6aCZxNqJVed8wsJVe80ZoEOKTQKeulkH)B(irUenjOVqiVfWGQ(LqyrjGaS0roslErqatPs7dfV14qgmwuW8iSe0Oio(LCK6dHfLhQvhoMqLJI3A80ZoEOKTkxOwcYELaN9V4f1(fgXH8zASMW3mS)kvkclkpuRoCmHkhfV14PND8qjBvUqTeK9kB7FXlQ9lmId5Z0ynHVzy)fzPsrXBnoKbJffmpclbnkIJFjhP(qyr5HA1HJju5O4Tgp9SJhkzRYfQLGSxzB)lErTFHrCiFMgRj8nd7VsLIWIYd1QdhtOYrXBnE6zhpuYwLlulbzV3Lv)lErTFHrCiFMgRj8nd7ViJ8apgzaWrrqd4GVrbBay0bJz7a6gk0bi7tuYUGlexYuOd8wsJVe80ZoEOKTA)sGBcQfLW)nFKixIMK(uJrLYFuwO0AA8LCu8wJFfmMT(V5B7luo(LCu8wJNE2XdLSv5c1sq2RK7YsosO4Tg)kymB9FZ32xO8LqyrjGaS0Pdq6E)P)zNVBXB7l0UUUie(g(6kFj74kYsLII3AC8c6ZC1l0Lkyku(siSOeqaw6ivkkERXtqTx4rTI4lHWIsabyPdYd8yKbGrHRI4qd4BdaJoymBhaUGmy0a6gk0bi7tuYUGlexYuOd8wsJVe80ZoEOKTA)sGBcQfLW)nFKixIMK(uJrLYFuwO0AA8L8dzkupKvadQYx8IA)cJ4nJXOYNwCHDOvEFO4Tg)kymB9FZ32xOC8l5P)zNVBXVcgZw)38T9fkFjewuIEVld5iHI3A80ZoEOKTkxOwcYELCxwYrcfV144f0N5QxOlvWuOC8lPsrXBnEcQ9cpQveh)czPsrXBnE6zhpuYwLlulbzVsU7wKh4TKgFj4PND8qjB1(La3eulkH)B(irUenj9PgJkL)OSqP104l59DitH6HScyqv(Ixu7xyeVzmgv(0IlSdTYrXBnE6zhpuYwLlulbzVsUll59HI3A8RGXS1)nFBFHYXVKN(ND(Uf)kymB9FZ32xO8Lqyrj6ftznWJrgag9syPshGBE2zaYUjB1b8yPnzxxrbBah8nkyd4kymBh4TKgFj4PND8qjB1(La3eulkH)B(irUenjQXOs5pkluAnn(sEFO4Tg)kymB9FZ32xOC8l5iHI3A80ZoEOKTkxOwcYELChoLJekERXXlOpZvVqxQGPq54xsLII3A8eu7fEuRio(fYsLII3A80ZoEOKTkxOwcYELChouQ00)SZ3T4xbJzR)B(2(cLVeclkbeCRCu8wJNE2XdLSv5c1sq2RK7WjYd8d8yKbGr)A81aVL04lbp9p78DlHKRxJVCjAsqXBn(vWy26)MVTVq54xd8yKb4M)zNVBjg4TKgFj4P)zNVBj6xcCjexFxA9lEr(UKD9LlrtIAmQu(JYcLwtJVKV4fbHoxosyTnmugXfQ)IzvffmPsXAByOmIBNJWVeclkKLJu6F257w8RGXS1)nFBFHYxcHfLacYqosP)zNVBXBmsanTwt5lHWIs0RmKlECgAuh(fUqXzKNw8ln(sQ0(epodnQd)cxO4mYtl(LgFHSuPO4Tg)kymB9FZ32xOC8lKLkf9fc5Tagu1VeclkbeWuwd8wsJVe80)SZ3Te9lbUeIRVlT(fViFxYU(YLOjrngvkhDjtH6)Mxe1znyVWKV4fbbziFXRi5V(U0cbK6CzHXFitH6HScyqv(Ixu7xyehQRcL2W6azGXV4f1(fgXxdXLvQxxRenAPkrDGmqwosO4TghDjtH6)Mxe1znyVW44xsL2cyqv)siSOeqatzH8aVL04lbp9p78Dlr)sGlH467sRFXlY3LSRVCjAsuJrLYJeLSRbElPXxcE6F257wI(La3RGXS1)nFBFH6s0KOgJkLJUKPq9FZlI6SgSxyYrcRTHHYiUq9xmRQOGjvkwBddLrC7Ce(LqyrHSCKs)ZoF3IJUKPq9FZlI6SgSxy8LqyrjKkn9p78Dlo6sMc1)nViQZAWEHXxYoUkFXRi5V(U02BNldKh4TKgFj4P)zNVBj6xcCVcgZw)38T9fQlrtIAmQuEKOKDjVpu8wJFfmMT(V5B7luo(1aVL04lbp9p78Dlr)sG7vWy26)MVTVqDjAsuJrLYFuwO0AA8LCKw8ks(RVlT9kXTYqEFO4Tg3qFerzA8LNfiq54xsLII3ACd9reLPXxEwGaLJFHSCKWAByOmIlu)fZQkkysLI12Wqze3ohHFjewuilhj1yuPCyMcL2OG5f6Vi4uzOm6ihfV14lH4xbXiHW3nkLwo(LuP9PgJkLdZuO0gfmVq)fbNkdLrhKh4TKgFj4P)zNVBj6xcCrxYuO(V5frDwd2lmxIMeu8wJFfmMT(V5B7luo(1aVL04lbp9p78Dlr)sGBBFH211fHW3WxxDjAsSKgyjpveIGesUlhfV14xbJzR)B(2(cLVeclkbeGLoYrXBn(vWy26)MVTVq54xY7tngvk)rzHsRPXxYrQV1IJNWsLYTZrWjzgcviv6AXXtyPs525i4r1RBLfYsL2cyqv)siSOeqWTd8wsJVe80)SZ3Te9lbUT9fAxxxecFdFD1LOjXsAGL8urics0RemLJekERXVcgZw)38T9fkh)sQ01IJNWsLYTZrWjzgcviFT44jSuPC7Ce8O6n9p78Dl(vWy26)MVTVq5lHWIs0Fhgz5iHI3A8RGXS1)nFBFHYxcHfLacWshPsxloEclvk3ohbNKziuH81IJNWsLYTZrWxcHfLacWshKh4TKgFj4P)zNVBj6xcCB7l0UUUie(g(6QlrtIAmQu(JYcLwtJVKJekERXVcgZw)38T9fkh)sEFiSO8qT6WXeQuP9HI3A8RGXS1)nFBFHYXVKJWIYd1QdhtOYt)ZoF3IFfmMT(V5B7lu(siSOeilhjKqXBn(vWy26)MVTVq5lHWIsabyPJuPO4TghVG(mx9cDPcMcLJFjhfV144f0N5QxOlvWuO8LqyrjGaS0bz5iDiu8wJVwN9BKiUqTeKsKHuP9DitH6HScyqv(Ixu7xyeFTo73iriJ8aVL04lbp9p78Dlr)sGluxVEfkTiIK)AjbvjYLOjrngvkhDjtH6)Mxe1znyVWKV4vK8xFxAHqNll5lErqqIBLJekERXrxYuO(V5frDwd2lmo(LuPP)zNVBXrxYuO(V5frDwd2lm(siSOe9cNYczPs7tngvkhDjtH6)Mxe1znyVWKV4vK8xFxAHGKoSmg4TKgFj4P)zNVBj6xcCxleK)q2XLOjj9p78Dl(vWy26)MVTVq5lHWIsabjYyG3sA8LGN(ND(ULOFjWvyPnArkmM)YsQlrtIL0al5PIqeKOxjykhPwadQ6xcHfLacUvQ0(qXBno6sMc1)nViQZAWEHXXVKJ0fPCyqFCgFjewucialDKkDT44jSuPC7CeCsMHqfYxloEclvk3ohbFjewuci4w5RfhpHLkLBNJGhvVxKYHb9Xz8Lqyrjqg5bElPXxcE6F257wI(La3dzkuVvh)HsMRUenjwsdSKNkcrqIELHuPlErTFHr8lOKTpIViXa)apgzaU5XsLv6a6qObl0Ged8wsJVe80JLkRuHKdzkuH)GtUenji1NAmQu(JYcLwtJVKkvngvk)rzHsRPXxYTKgyjpveIGe9kbt5P)zNVBXVcgZw)38T9fkFjewucPsTKgyjpveIGesUJSCKWAByOmIlu)fZQkkysLI12Wqze3ohHFjewuipWBjn(sWtpwQSsf9lbUIU2IikyEeHqDjAsw8ks(RVlT8d1IuO9E3TYt)ZoF3IFfmMT(V5B7lu(siSOeqWTY7tngvkhDjtH6)Mxe1znyVWKJ12WqzexO(lMvvuWg4TKgFj4PhlvwPI(LaxrxBrefmpIqOUenj9PgJkLJUKPq9FZlI6SgSxyYXAByOmIBNJWVeclQbElPXxcE6XsLvQOFjWv01werbZJieQlrtIAmQuo6sMc1)nViQZAWEHjhju8wJJUKPq9FZlI6SgSxyC8l5iH12WqzexO(lMvvuWKV4vK8xFxA5hQfPq7foLLuPyTnmugXTZr4xcHfL8fVIK)67sl)qTifAVDUSKkfRTHHYiUDoc)siSOKVwC8ewQuUDoc(siSOeqaou(AXXtyPs525i4KmdHkqwQ0(qXBno6sMc1)nViQZAWEHXXVKN(ND(UfhDjtH6)Mxe1znyVW4lHWIsG8aVL04lbp9yPYkv0Ve4AOpIOmn(YZceOUenjP)zNVBXVcgZw)38T9fkFjewuci4w5yTnmugXfQ)Izvffm5iPgJkLJUKPq9FZlI6SgSxyYx8ks(RVlT925YqE6F257wC0LmfQ)BEruN1G9cJVeclkbeWuQ0(uJrLYrxYuO(V5frDwd2lmKh4TKgFj4PhlvwPI(Laxd9reLPXxEwGa1LOjbRTHHYiUDoc)siSOg4TKgFj4PhlvwPI(LaxbulbjJ8kuYJxD)vH6QlrtcwBddLrCH6VywvrbtosP)zNVBXVcgZw)38T9fkFjewuci4wPsvJrLYJeLSlKh4TKgFj4PhlvwPI(LaxbulbjJ8kuYJxD)vH6QlrtcwBddLrC7Ce(LqyrnWBjn(sWtpwQSsf9lbUngjGMwRPUenj9HI3A8RGXS1)nFBFHYXVKJK4XzOrD4x4cfNrEAXV04lPsfpodnQdh7ZmnyKx8mSuPY7dfV14yFMPbJ8INHLkLJFHSlrP0U4xQpqGGoHPKK7UeLs7IFPEySh1ysU7sukTl(L6JMeXJZqJ6WX(mtdg5fpdlv6a)apgzayuOSqP104RbSVAA81aVL04lb)rzHsRPXxswcXVcIrcHVBukTUenjwsdSKNkcrqIEL4w5yTnmugX3UEu8wtmWBjn(sWFuwO0AA8v)sGBBFH6f6gqsUenj9HI3ACidglkyEewcAueh)soslErqatPsvJrLYJKRE1yFjKJI3A8i5Qxn2xc(siSOeqaw60bykvA6RdEOC8IrMakD8TLQoZv5iHI3AC8IrMakD8TLQoZv(siSOeqaw60bykvkkERXXlgzcO0X3wQ6mx5c1sqcb3ImYd8wsJVe8hLfkTMgF1Ve4c97YIcMhLzc1LOjPpu8wJdzWyrbZJWsqJI44xYx8I6vIBLJekERX3abXxcHfLacUvokERX3abXXVKk1sAGL8Nx5T9fQVryPfcwsdSKNkcrqcKh4TKgFj4pkluAnn(QFjWfgZsHX82bRvjYLOjPpu8wJdzWyrbZJWsqJI44xYfxeJ5vBHrQGdJzPWyE7G1Qe1RemLkTpu8wJdzWyrbZJWsqJI44xYr6qO4TgFTo73irCHAjiHGmKk9qO4TgFTo73ir8LqyrjGaS0PdGtKh4TKgFj4pkluAnn(QFjWTTVqfjxvOKlrtckERXHmySOG5ryjOrr8LSKkxCrmMxTfgPcEBFHksUQqPEXuEFyTnmugXpKPqf(do5TKgyPbElPXxc(JYcLwtJV6xcCFuwO0Ak5sY1eJ8QTWivi5UlrtckERXHmySOG5ryjOrr8LSKoWBjn(sWFuwO0AA8v)sGBBFH6f6gqsUenjwsdSKNkcrqcj3LJ12WqzeVTVq9cDdijF6RdEOIbElPXxc(JYcLwtJV6xcCH(DzrbZJYmH6s0KG12WqzeFFTL8BGGKlUigZR2cJubh63LffmpkZeAVsWCG3sA8LG)OSqP104R(LaxymlfgZBhSwLixIMeXfXyE1wyKk4WywkmM3oyTkr9kbZbElPXxc(JYcLwtJV6xcCB7luVq3asYLKRjg5vBHrQqYDxIMK(uJrLYnSgZQeusEFO4TghYGXIcMhHLGgfXXVKkvngvk3WAmRsqj59H12WqzeFFTL8BGGKkfRTHHYi((Al53abjFXlIRbcYRVhZELalDg4TKgFj4pkluAnn(QFjWf63LffmpkZeQlrtcwBddLr891wYVbcAG3sA8LG)OSqP104R(La3hLfkTMsUKCnXiVAlmsfsUpWpWJrgag9)SOGna44FhagfkluAnn(QJdWrTvfd4USgGGsFDedaLA)sdaJoymBhW3gaC8(cDaPhbjgW3AdWnYUg4TKgFj4pkluAnn(YF9plkyswcXVcIrcHVBukTUenjyTnmugX3UEu8wtivQL0al5PIqeKOxjyoWBjn(sWFuwO0AA8L)6FwuW6xcCHXSuymVDWAvICjAsexeJ5vBHrQGdJzPWyE7G1Qe1RemLRgJkL32xOIKRkuAG3sA8LG)OSqP104l)1)SOG1Ve422xOIKRkuYLOjbfV14qgmwuW8iSe0Oi(swsLBjnWsEQiebj6ft59H12Wqze)qMcv4p4K3sAGLg4TKgFj4pkluAnn(YF9plky9lbUpkluAnLCj5AIrE1wyKkKC3LOjbfV14qgmwuW8iSe0Oi(swsh4TKgFj4pkluAnn(YF9plky9lbUT9fQxOBaj5s0KyjnWsEQiebjKCxowBddLr82(c1l0nGK8PVo4Hkg4TKgFj4pkluAnn(YF9plky9lbUpkluAnLCj5AIrE1wyKkKC3LOjbfV14qgmwuW8iSe0Oi(swsh4TKgFj4pkluAnn(YF9plky9lbUq)USOG5rzMqDjAsWAByOmIVV2s(nqqd8wsJVe8hLfkTMgF5V(NffS(LaxymlfgZBhSwLixIMeXfXyE1wyKk4WywkmM3oyTkr9kbt5lEfj)13Lw(HArkui05YAG3sA8LG)OSqP104l)1)SOG1Ve422xOEHUbKKljxtmYR2cJuHK7UenjlEfj)13Lw(HArkui0HL1aVL04lb)rzHsRPXx(R)zrbRFjW9rzHsRPKljxtmYR2cJuHK7UenjlEr9kXTYrQpewuEOwD4ycvQ00JLkRuErP9z)EKkn9yPYkLdPRByfYsLU4f1Re4uoclkpuRoCmHoWBjn(sWFuwO0AA8L)6FwuW6xcCB7lurYvfk5s0KyjnWsEQiebj6vcCkVpS2ggkJ4hYuOc)bN8wsdS0a)apgzaWbwkm2a6qObl0Ged8wsJVe81sHXesqz)F8n81vxIMeu8wJFfmMT(V5B7luo(1aVL04lbFTuymr)sGlkTcAHmkyUenjO4Tg)kymB9FZ32xOC8RbElPXxc(APWyI(LaxBtwr(lCMGCjAsqQpu8wJFfmMT(V5B7luo(LClPbwYtfHiirVsWezPs7dfV14xbJzR)B(2(cLJFjhPfVi(HArk0ELid5lEfj)13Lw(HArk0EL05Yc5bElPXxc(APWyI(LaxwadQk8Wrf)adbvQlrtckERXVcgZw)38T9fkh)AG3sA8LGVwkmMOFjW1Qej01y(KXyUenjO4Tg)kymB9FZ32xOC8l5O4TgNqC9DP1V4f57s21xC8RbElPXxc(APWyI(La3wSek7)JlrtckERXVcgZw)38T9fkFjewuciir2khfV14xbJzR)B(2(cLJFjhfV14eIRVlT(fViFxYU(IJFnWBjn(sWxlfgt0Ve4IAW8FZRBKGu4s0KGI3A8RGXS1)nFBFHYXVKBjnWsEQiebjKCxosO4Tg)kymB9FZ32xO8LqyrjGGmKRgJkLNE2XdLSv5uzOm6ivAFQXOs5PND8qjBvovgkJoYrXBn(vWy26)MVTVq5lHWIsab3I8a)apgzaoQvhBpdqefmgHXR2cJ0bSVAA81aVL04lbxOwDS9izje)kigje(UrP06s0KG12WqzeF76rXBnXaVL04lbxOwDS90Ve4(OSqP1uYLOjbfV14qgmwuW8iSe0Oi(swsh4TKgFj4c1QJTN(LaxOFxwuW8OmtOUenjyTnmugX3xBj)gii5O4TgFdeeFjewuci42bElPXxcUqT6y7PFjWTTVq9cDdijxIMeS2ggkJ4T9fQxOBaj5tFDWdvmWBjn(sWfQvhBp9lbUWywkmM3oyTkrUenj9DitH6HScyqv(Ixu7xyeFTo73irYr6qO4TgFTo73irCHAjiHGmKk9qO4TgFTo73ir8LqyrjGaS0PdGtKh4TKgFj4c1QJTN(La32(c1l0nGKCjAss)ZoF3IVeIFfeJecF3OuA5lHWIsabjy2bWsh5QXOs5WmfkTrbZl0FrmWBjn(sWfQvhBp9lbUq)USOG5rzMqDjAsWAByOmIVV2s(nqqd8wsJVeCHA1X2t)sGBBFH6f6gqsUenjlEfj)13Lw(HArkuiG0Dz0VAmQu(IxrYBQsfUPXxDGmqEG3sA8LGluRo2E6xcCFuwO0Ak5s0K0hkERXB73zu5VWzcIJFjxngvkVTFNrL)cNjiPsXAByOmIFitHk8hCYBjnWsYrXBn(HmfQWFWjUqTeKqaoLkvngvkhMPqPnkyEH(lc5O4TgFje)kigje(UrP0YXVKkDXRi5V(U0YpulsH2lsykJ(vJrLYx8ksEtvQWnn(QdKbYd8wsJVeCHA1X2t)sGBBFH6f6gqsd8wsJVeCHA1X2t)sGl0Fl)38DJsPDG3sA8LGluRo2E6xcCTnzf51FxQ0b(bEmYa6zJcssfd8wsJVeCDJcssfsWfKpucHlLHGKeLiT4QHYipgd3kfhH)qyJe5s0K0NAmQuo6sMc1)nViQZAWEHjhfV14xbJzR)B(2(cLJFjhfV14eIRVlT(fViFxYU(IJFjvQAmQuo6sMc1)nViQZAWEHjhjKqXBn(vWy26)MVTVq54xYt)ZoF3IJUKPq9FZlI6SgSxy8LSJRilvksO4Tg)kymB9FZ32xOC8l5iHulGbv9lHWIsGXN(ND(UfhDjtH6)Mxe1znyVW4lHWIsGmeW8oYiJSuPOVqiVfWGQ(LqyrjGaM3Lk9qMc1dzfWGQ8timug5dm2XtYKs4kjrwYvBHrkxdeKxF)vs9ykliiJbElPXxcUUrbjPI(LaxCb5dLq4sziijIKTc)38T1uAlJ5f6gnAG3sA8LGRBuqsQOFjWfxq(qjeUugcsIcL8TyfQxeWcMlrtckERXVcgZw)38T9fkh)sokERXjexFxA9lEr(UKD9fh)AGhJmGEGsdq3OGK0b0nuOdqHsdaAadkj0bqcnqykDgawJHtUmGUbJnauAa4c6mGwScDawDgWLflDgq3qHoam6GXSDaFBaWX7lu(aVL04lbx3OGKur)sGRUrbjP3DjAs6dRTHHYiU4IsrlOJx3OGKu5O4Tg)kymB9FZ32xOC8l5i1NAmQuEKOKDjvQAmQuEKOKDjhfV14xbJzR)B(2(cLVeclkrVsUllKLJuF6gfKKYXKd1e(0)SZ3TKkv3OGKuoM80)SZ3T4lHWIsivkwBddLrCDJcss9xB8BOUk5oYsLQBuqsk)ohfV18h8104REL0cyqv)siSOed8wsJVeCDJcssf9lbU6gfKKIPlrtsFyTnmugXfxukAbD86gfKKkhfV14xbJzR)B(2(cLJFjhP(uJrLYJeLSlPsvJrLYJeLSl5O4Tg)kymB9FZ32xO8Lqyrj6vYDzHSCK6t3OGKu(Dout4t)ZoF3sQuDJcss535P)zNVBXxcHfLqQuS2ggkJ46gfKK6V243qDvcMilvQUrbjPCm5O4TM)GVMgF1RKwadQ6xcHfLyGhJmazFBaFXCDaFrd4RbGlObOBuqs6aU2hBCiXaSbGI3AUmaCbnafknGxHs7a(AaP)zNVBXhag1oGOnGIcfkTdq3OGK0bCTp24qIbydafV1Cza4cAaOVcDaFnG0)SZ3T4d8wsJVeCDJcssf9lbU4cYhkHWfb7vj6gfKKE3LOjPpS2ggkJ4IlkfTGoEDJcssLJuF6gfKKYVZHAcpUG8O4TMCK0nkijLJjp9p78Dl(siSOesL2NUrbjPCm5qnHhxqEu8wdzPst)ZoF3IFfmMT(V5B7lu(siSOe9IPSqEG3sA8LGRBuqsQOFjWfxq(qjeUiyVkr3OGKumDjAs6dRTHHYiU4IsrlOJx3OGKu5i1NUrbjPCm5qnHhxqEu8wtos6gfKKYVZt)ZoF3IVeclkHuP9PBuqsk)ohQj84cYJI3AilvA6F257w8RGXS1)nFBFHYxcHfLOxmLfYznR5ma]] )


end
