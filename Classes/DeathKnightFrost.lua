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


    spec:RegisterPack( "Frost DK", 20220226, [[d40AudqiPQ8iOO4seLInru9jvQgfe5uquRIkL8kPQAwujUfuuv7cv)cuPHru0XuPSmOWZKkyAGk6Aef2Mur13avqJJkLY5avG1jvO5bcUhrSpPkDqIsvlee6HuPyIeLs5Iqrv2iOc1hbvigjrPuDsIsLvcQ6LGkKAMsfzNuP6Nqrjdfkk1sPsP6PuXuLQ4QGkK4ReLsgluK9kQ)svdg4WuwmKESitwfxgzZs5ZGYObPtlSAqfs61GOzJYTHWUL8BvnCvYXHIklxPNty6KUouTDO03LknEIsopvsRxQOmFI0(vC(wUNSZXuk7ogYedmKjgy05CmUbNWbyCl7OUErzNllbPbJYoLHGYoWX7l0biBdo6SZL5k7TtUNSJ4X3eLDGQ6LOJWfUWcfkokp9iGRiqGZmn(kTwtHRiqKGB2bfpyQSRYOzNJPu2DmKjgyitmWOZ5yCdoHdKPmYogUc93SJtGWnzhOX5qvgn7Cirk7iBJmf6aGJUcyq1bahVVqh4HJj0f3wxhagDUldadzIbgd8d8UbQvWiXapM)aC7eIhlDgaZekMVGsFDgaUWGrd4BdWnqTOed4Bdq2LObyIbe6aopjQ76aUyMRdOlXydiQbCTwsJeXh4X8hGSTVURdib1QIydaoMrcOP1A6ao4BuWgaexYuOd4BdWjQZAWEHXZoSqOICpzNhLfkTMgF5V(NffSCpz3VL7j7qLHYOtgIzhlPXxzNLq8RGyKq47gLsB25qI0gxA8v2bZ(FwuWgaC8VdaZcLfkTMgF1Xb4O2QIbCtMdqqPVoIbGsTFPbGzhmMTd4BdaoEFHoG0JGed4BTb4gzBzN0gkTHLDWAByOmIVD9O4TMyasLoalPbwYtfHiiXa6vYaWiRz3Xi3t2HkdLrNmeZoPnuAdl7iUigZR2cJubhgZsHX82bRvjAa9kzayma5dqngvkVTVqfjxvOeNkdLrNSJL04RSdmMLcJ5TdwRsuwZU3HCpzhQmugDYqm7K2qPnSSdkERXHmySOG5ryjOrr8LSKoa5dWsAGL8uricsmGEhagdq(a6BayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUQqPSMDhoZ9KDOYqz0jdXSJL04RSZJYcLwtPStAdL2WYoO4TghYGXIcMhHLGgfXxYsA2j5AIrE1wyKkYUFlRz3LrUNSdvgkJoziMDsBO0gw2XsAGL8uricsmajd42aKpaS2ggkJ4T9fQxOBaj5tFDWdvKDSKgFLDA7luVq3askRz378CpzhQmugDYqm7yjn(k78OSqP1uk7K2qPnSSdkERXHmySOG5ryjOrr8LSKMDsUMyKxTfgPIS73YA2D4WCpzhQmugDYqm7K2qPnSSdwBddLr891wYVbck7yjn(k7a97YIcMhLzcnRz3DB5EYouzOm6KHy2jTHsByzhXfXyE1wyKk4WywkmM3oyTkrdOxjdaJbiFalEfj)13Lw(HArk0baHb05Ym7yjn(k7aJzPWyE7G1QeL1S7Wb5EYouzOm6KHy2XsA8v2PTVq9cDdiPStAdL2WYolEfj)13Lw(HArk0baHbahkZStY1eJ8QTWivKD)wwZUFtM5EYouzOm6KHy2XsA8v25rzHsRPu2jTHsByzNfVOb0RKb0HbiFainG(gaclkpuRoCmGoaPshq6XsLvkVO0(SFpdqQ0bKESuzLYH01nSAaipaPshWIx0a6vYaGZbiFaiSO8qT6WXaA2j5AIrE1wyKkYUFlRz3VDl3t2HkdLrNmeZoPnuAdl7yjnWsEQiebjgqVsgaCoa5dOVbG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5QcLYAwZoPND8qjB1Cpz3VL7j7qLHYOtgIzN0gkTHLDqFHyaYhqlGbv9lHWIsmaimayPZaKpaKgWIx0aGWaWyasLoG(gakERXHmySOG5ryjOrrC8RbiFainG(gaclkpuRoCmGoa5dafV14PND8qjBvUqTeKdOxjdaohq)dyXlQ9lmId5Z0ynHVzy)LtLHYOZaKkDaiSO8qT6WXa6aKpau8wJNE2XdLSv5c1sqoGEhGBBa9pGfVO2VWioKptJ1e(MH9xovgkJoda5biv6aqXBnoKbJffmpclbnkIJFna5daPb03aqyr5HA1HJb0biFaO4Tgp9SJhkzRYfQLGCa9oa32a6FalErTFHrCiFMgRj8nd7VCQmugDgGuPdaHfLhQvhogqhG8bGI3A80ZoEOKTkxOwcYb07aUjZb0)aw8IA)cJ4q(mnwt4Bg2F5uzOm6maKhaYzhlPXxzNeulkH)B(irzn7og5EYouzOm6KHy2XsA8v2jb1Is4)Mpsu25qI0gxA8v2bokcAah8nkydaZoymBhq3qHoazxIs2fCH4sMcn7K2qPnSStFdqngvk)rzHsRPXxCQmugDgG8bGI3A8RGXS1)nFBFHYXVgG8bGI3A80ZoEOKTkxOwcYb0RKbCtMdq(aqAaO4Tg)kymB9FZ32xO8LqyrjgaegaS0zaU1aqAa3gq)di9p78DlEBFH211fHW3Wxx5lzhxhaYdqQ0bGI3AC8c6ZC1l0Lkyku(siSOedacdaw6maPshakERXtqTx4rTI4lHWIsmaimayPZaqoRz37qUNSdvgkJoziMDSKgFLDsqTOe(V5JeLDoKiTXLgFLDWSWvrCOb8TbGzhmMTdaxqgmAaDdf6aKDjkzxWfIlzk0StAdL2WYo9na1yuP8hLfkTMgFXPYqz0zaYhWHmfQhYkGbv5lErTFHr8MXyu5tlUWo0oa5dOVbGI3A8RGXS1)nFBFHYXVgG8bK(ND(Uf)kymB9FZ32xO8LqyrjgqVd4MmgG8bG0aqXBnE6zhpuYwLlulb5a6vYaUjZbiFainau8wJJxqFMREHUubtHYXVgGuPdafV14jO2l8OwrC8RbG8aKkDaO4Tgp9SJhkzRYfQLGCa9kza36WaqoRz3HZCpzhQmugDYqm7K2qPnSStFdqngvk)rzHsRPXxCQmugDgG8b03aoKPq9qwbmOkFXlQ9lmI3mgJkFAXf2H2biFaO4Tgp9SJhkzRYfQLGCa9kza3K5aKpG(gakERXVcgZw)38T9fkh)AaYhq6F257w8RGXS1)nFBFHYxcHfLya9oamKz2XsA8v2jb1Is4)MpsuwZUlJCpzhQmugDYqm7yjn(k7KGArj8FZhjk7CirAJln(k7GzVewQ0b4MNDgGSDYwDapwAt21vuWgWbFJc2aUcgZ2StAdL2WYoQXOs5pkluAnn(ItLHYOZaKpG(gakERXVcgZw)38T9fkh)AaYhasdafV14PND8qjBvUqTeKdOxjd4gCoa5daPbGI3AC8c6ZC1l0Lkykuo(1aKkDaO4Tgpb1EHh1kIJFnaKhGuPdafV14PND8qjBvUqTeKdOxjd4gCWaKkDaP)zNVBXVcgZw)38T9fkFjewuIbaHb0HbiFaO4Tgp9SJhkzRYfQLGCa9kza3GZbGCwZA25rzHsRPXx5EYUFl3t2HkdLrNmeZowsJVYolH4xbXiHW3nkL2SZHePnU04RSdMfkluAnn(Aa7RMgFLDsBO0gw2XsAGL8uricsmGELmGoma5daRTHHYi(21JI3AISMDhJCpzhQmugDYqm7K2qPnSStFdafV14qgmwuW8iSe0Oio(1aKpaKgWIx0aGWaWyasLoa1yuP8i5Qxn2xcovgkJodq(aqXBnEKC1Rg7lbFjewuIbaHbalDgGBnamgGuPdi91bpuoEXitaLo(2svN5kNkdLrNbiFainau8wJJxmYeqPJVTu1zUYxcHfLyaqyaWsNb4wdaJbiv6aqXBnoEXitaLo(2svN5kxOwcYbaHb0HbG8aqo7yjn(k702xOEHUbKuwZU3HCpzhQmugDYqm7K2qPnSStFdafV14qgmwuW8iSe0Oio(1aKpGfVOb0RKb0HbiFainau8wJVbcIVeclkXaGWa6WaKpau8wJVbcIJFnaPshGL0al5pVYB7luFJWs7aGWaSKgyjpveIGeda5SJL04RSd0VllkyEuMj0SMDhoZ9KDOYqz0jdXStAdL2WYo9nau8wJdzWyrbZJWsqJI44xdq(aexeJ5vBHrQGdJzPWyE7G1QenGELmamgGuPdOVbGI3ACidglkyEewcAueh)AaYhasd4qO4TgFTo73irCHAjihaegGmgGuPd4qO4TgFTo73ir8LqyrjgaegaS0zaU1aGZbGC2XsA8v2bgZsHX82bRvjkRz3LrUNSdvgkJoziMDsBO0gw2bfV14qgmwuW8iSe0Oi(swshG8biUigZR2cJubVTVqfjxvO0a6Dayma5dOVbG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5QcLYA29op3t2HkdLrNmeZowsJVYopkluAnLYoPnuAdl7GI3ACidglkyEewcAueFjlPzNKRjg5vBHrQi7(TSMDhom3t2HkdLrNmeZoPnuAdl7yjnWsEQiebjgGKbCBaYhawBddLr82(c1l0nGK8PVo4HkYowsJVYoT9fQxOBajL1S7UTCpzhQmugDYqm7K2qPnSSdwBddLr891wYVbcAaYhG4IymVAlmsfCOFxwuW8OmtOdOxjdaJSJL04RSd0VllkyEuMj0SMDhoi3t2HkdLrNmeZoPnuAdl7iUigZR2cJubhgZsHX82bRvjAa9kzayKDSKgFLDGXSuymVDWAvIYA29BYm3t2HkdLrNmeZowsJVYoT9fQxOBajLDsBO0gw2PVbOgJkLBynMvjOeNkdLrNbiFa9nau8wJdzWyrbZJWsqJI44xdqQ0bOgJkLBynMvjOeNkdLrNbiFa9naS2ggkJ47RTKFde0aKkDayTnmugX3xBj)giObiFalErCnqqE99ymGELmayPt2j5AIrE1wyKkYUFlRz3VDl3t2HkdLrNmeZoPnuAdl7G12WqzeFFTL8BGGYowsJVYoq)USOG5rzMqZA29ByK7j7qLHYOtgIzhlPXxzNhLfkTMszNKRjg5vBHrQi7(TSM1SJqT6y7j3t29B5EYouzOm6KHy2XsA8v2zje)kigje(UrP0MDoKiTXLgFLDCuRo2EgGikymcZxTfgPdyF104RStAdL2WYoyTnmugX3UEu8wtK1S7yK7j7qLHYOtgIzN0gkTHLDqXBnoKbJffmpclbnkIVKL0SJL04RSZJYcLwtPSMDVd5EYouzOm6KHy2jTHsByzhS2ggkJ47RTKFde0aKpau8wJVbcIVeclkXaGWa6q2XsA8v2b63LffmpkZeAwZUdN5EYouzOm6KHy2jTHsByzhS2ggkJ4T9fQxOBaj5tFDWdvKDSKgFLDA7luVq3askRz3LrUNSdvgkJoziMDsBO0gw2PVbCitH6HScyqv(Ixu7xyeFTo73irdq(aqAahcfV14R1z)gjIlulb5aGWaKXaKkDahcfV14R1z)gjIVeclkXaGWaGLodWTgaCoaKZowsJVYoWywkmM3oyTkrzn7ENN7j7qLHYOtgIzN0gkTHLDs)ZoF3IVeIFfeJecF3OuA5lHWIsmaiizayma3AaWsNbiFaQXOs5WmfkTrbZl0FrWPYqz0j7yjn(k702xOEHUbKuwZUdhM7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nqqzhlPXxzhOFxwuW8OmtOzn7UBl3t2HkdLrNmeZoPnuAdl7S4vK8xFxA5hQfPqhaegasd4Mmgq)dqngvkFXRi5nvPc304lovgkJodWTgGmgaYzhlPXxzN2(c1l0nGKYA2D4GCpzhQmugDYqm7K2qPnSStFdafV14T97mQ8x4mbXXVgG8bOgJkL32VZOYFHZeeNkdLrNbiv6aWAByOmIFitHk8hCYBjnWsdq(aqXBn(HmfQWFWjUqTeKdacdaohGuPdqngvkhMPqPnkyEH(lcovgkJodq(aqXBn(si(vqmsi8DJsPLJFnaPshWIxrYF9DPLFOwKcDa9oaKgagYya9pa1yuP8fVIK3uLkCtJV4uzOm6ma3AaYyaiNDSKgFLDEuwO0AkL1S73KzUNSJL04RStBFH6f6gqszhQmugDYqmRz3VDl3t2XsA8v2b6VL)B(UrP0MDOYqz0jdXSMD)gg5EYowsJVYo2MSI86VlvA2HkdLrNmeZAwZoOVWRrcYOGL7j7(TCpzhQmugDYqm7yjn(k78OSqP1uk7KCnXiVAlmsfz3VLDsBO0gw2zXRi5V(U0oaiizaina4ugdO)bOgJkLV4vK8MQuHBA8fNkdLrNb4wdqgda5SZHePnU04RSdexYuOd4BdWjQZAWEHnazFsdS0aC7VAA8vwZUJrUNSdvgkJoziMDsBO0gw2bRTHHYi(21JI3AIbiv6aSKgyjpveIGedOxjdaJbiv6aw8ks(RVlTdacdOdyma5dyXlIRbcYRVhJbaHbS4vK8xFxAhaChWTop7yjn(k7SeIFfeJecF3OuAZA29oK7j7qLHYOtgIzN0gkTHLDw8ks(RVlTdacdOdyma5dyXlIRbcYRVhJbaHbS4vK8xFxAhaChWTop7yjn(k7CitH6T64puYCnRz3HZCpzhQmugDYqm7K2qPnSSdwBddLr891wYVbcAaYhasdyXRi5V(U0oGELma4ugdqQ0bS4fX1ab5133Hbabjdaw6maPshWIxu7xyeFnyK)BEfk5B73zu5tqnexXxCQmugDgGuPdqCrmMxTfgPco0VllkyEuMj0b0RKbGXaKkDaO4TgFdeeFjewuIbaHb0HbG8aKkDalEfj)13L2baHb0bmgG8bS4fX1ab513JXaGWaw8ks(RVlTdaUd4wNNDSKgFLDG(DzrbZJYmHM1S7Yi3t2HkdLrNmeZoPnuAdl7GI3ACidglkyEewcAueh)AaYhG4IymVAlmsf82(cvKCvHsdO3bGXaKpG(gawBddLr8dzkuH)GtElPbwk7yjn(k702xOIKRkukRz378CpzhQmugDYqm7yjn(k78OSqP1uk7K2qPnSSdkERXHmySOG5ryjOrr8LSKMDsUMyKxTfgPIS73YA2D4WCpzhQmugDYqm7K2qPnSSZIxrYF9DPDaqqYa6Czoa5dyXlIRbcYRVVddO3balDYowsJVYoq)T8FZ3nkL2SMD3TL7j7qLHYOtgIzN0gkTHLDexeJ5vBHrQG32xOIKRkuAa9oamgG8b03aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCvHszn7oCqUNSdvgkJoziMDSKgFLDEuwO0AkLDsBO0gw2zXRi5V(U0YpulsHoGEhagYyasLoGfViUgiiV((omaimayPt2j5AIrE1wyKkYUFlRz3VjZCpzhQmugDYqm7K2qPnSSdwBddLr891wYVbck7yjn(k7a97YIcMhLzcnRz3VDl3t2HkdLrNmeZoPnuAdl7S4vK8xFxAhaegGmKz2XsA8v2X2KvKx)DPsZAwZoPhlvwPICpz3VL7j7qLHYOtgIzhlPXxzNdzkuH)GtzNdjsBCPXxzh38yPYkDaYE0GfAqIStAdL2WYoinG(gGAmQu(JYcLwtJV4uzOm6maPshGAmQu(JYcLwtJV4uzOm6ma5dWsAGL8uricsmGELmamgG8bK(ND(Uf)kymB9FZ32xO8LqyrjgGuPdWsAGL8uricsmajd42aqEaYhasdaRTHHYiUq9xmRQOGnaPshawBddLrC7Ce(LqyrnaKZA2DmY9KDOYqz0jdXStAdL2WYolEfj)13Lw(HArk0b07aU1HbiFaP)zNVBXVcgZw)38T9fkFjewuIbaHb0HbiFa9na1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaS2ggkJ4c1FXSQIcw2XsA8v2r01werbZJieAwZU3HCpzhQmugDYqm7K2qPnSStFdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5daRTHHYiUDoc)siSOYowsJVYoIU2IikyEeHqZA2D4m3t2HkdLrNmeZoPnuAdl7OgJkLJUKPq9FZlI6SgSxyCQmugDgG8bG0aqXBno6sMc1)nViQZAWEHXXVgG8bG0aWAByOmIlu)fZQkkydq(aw8ks(RVlT8d1IuOdO3baNYCasLoaS2ggkJ425i8lHWIAaYhWIxrYF9DPLFOwKcDa9oGoxMdqQ0bG12Wqze3ohHFjewudq(awloEclvk3ohbFjewuIbaHbahma5dyT44jSuPC7CeCswHqfda5biv6a6BaO4TghDjtH6)Mxe1znyVW44xdq(as)ZoF3IJUKPq9FZlI6SgSxy8LqyrjgaYzhlPXxzhrxBrefmpIqOzn7UmY9KDOYqz0jdXStAdL2WYoP)zNVBXVcgZw)38T9fkFjewuIbaHb0HbiFayTnmugXfQ)IzvffSbiFaina1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpGfVIK)67s7a6DaYqMdq(as)ZoF3IJUKPq9FZlI6SgSxy8LqyrjgaegagdqQ0b03auJrLYrxYuO(V5frDwd2lmovgkJoda5SJL04RSJH(iIY04lplqGM1S7DEUNSdvgkJoziMDsBO0gw2bRTHHYiUDoc)siSOYowsJVYog6JiktJV8SabAwZUdhM7j7qLHYOtgIzN0gkTHLDWAByOmIlu)fZQkkydq(aqAaP)zNVBXVcgZw)38T9fkFjewuIbaHb0Hbiv6auJrLYJeLSlovgkJoda5SJL04RSJaQLGKrEfk5XRU)QqDnRz3DB5EYouzOm6KHy2jTHsByzhS2ggkJ425i8lHWIk7yjn(k7iGAjizKxHsE8Q7VkuxZA2D4GCpzhQmugDYqm7K2qPnSStFdafV14xbJzR)B(2(cLJFna5daPbiECgAuh(fUqXzKNw8ln(ItLHYOZaKkDaIhNHg1HJ9zMgmYlEgwQuovgkJodq(a6BaO4Tgh7ZmnyKx8mSuPC8RbGC2jkL2f)s9rl7iECgAuho2NzAWiV4zyPsZorP0U4xQpqGGoHPu25w2XsA8v2PXib00Ann7eLs7IFPEySh1yzNBznRzN0)SZ3Te5EYUFl3t2HkdLrNmeZoPnuAdl7GI3A8RGXS1)nFBFHYXVYohsK24sJVYoy2VgFLDSKgFLDUEn(kRz3Xi3t2HkdLrNmeZowsJVYoeIRVlT(fViFxYU(k7CirAJln(k74M)zNVBjYoPnuAdl7OgJkL)OSqP104lovgkJodq(aw8IgaegqNpa5daPbG12WqzexO(lMvvuWgGuPdaRTHHYiUDoc)siSOgaYdq(aqAaP)zNVBXVcgZw)38T9fkFjewuIbaHbiJbiFainG0)SZ3T4ngjGMwRP8LqyrjgqVdqgdq(aepodnQd)cxO4mYtl(LgFXPYqz0zasLoG(gG4XzOrD4x4cfNrEAXV04lovgkJoda5biv6aqXBn(vWy26)MVTVq54xda5biv6aqFHyaYhqlGbv9lHWIsmaimamKzwZU3HCpzhQmugDYqm7K2qPnSSJAmQuo6sMc1)nViQZAWEHXPYqz0zaYhWIx0aGWaKXaKpGfVIK)67s7aGWaqAaDUmhaM)aoKPq9qwbmOkFXlQ9lmId1vHsBydWTgGmgaM)aw8IA)cJ4RH4Yk1RRvIgTuLiovgkJodWTgGmgaYdq(aqAaO4TghDjtH6)Mxe1znyVW44xdqQ0b0cyqv)siSOedacdadzoaKZowsJVYoeIRVlT(fViFxYU(kRz3HZCpzhQmugDYqm7K2qPnSSJAmQuEKOKDXPYqz0j7yjn(k7qiU(U06x8I8Dj76RSMDxg5EYouzOm6KHy2jTHsByzh1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaKgawBddLrCH6VywvrbBasLoaS2ggkJ425i8lHWIAaipa5daPbK(ND(UfhDjtH6)Mxe1znyVW4lHWIsmaPshq6F257wC0LmfQ)BEruN1G9cJVKDCDaYhWIxrYF9DPDa9oaziZbGC2XsA8v25kymB9FZ32xOzn7ENN7j7qLHYOtgIzN0gkTHLDuJrLYJeLSlovgkJodq(a6BaO4Tg)kymB9FZ32xOC8RSJL04RSZvWy26)MVTVqZA2D4WCpzhQmugDYqm7K2qPnSSJAmQu(JYcLwtJV4uzOm6ma5daPbS4vK8xFxAhqVsgqhKXaKpG(gakERXn0hruMgF5zbcuo(1aKkDaO4Tg3qFerzA8LNfiq54xda5biFainaS2ggkJ4c1FXSQIc2aKkDayTnmugXTZr4xcHf1aqEaYhasdqngvkhMPqPnkyEH(lcovgkJodq(aqXBn(si(vqmsi8DJsPLJFnaPshqFdqngvkhMPqPnkyEH(lcovgkJoda5SJL04RSZvWy26)MVTVqZA2D3wUNSdvgkJoziMDsBO0gw2bfV14xbJzR)B(2(cLJFLDSKgFLDqxYuO(V5frDwd2lSSMDhoi3t2HkdLrNmeZoPnuAdl7yjnWsEQiebjgGKbCBaYhakERXVcgZw)38T9fkFjewuIbaHbalDgG8bGI3A8RGXS1)nFBFHYXVgG8b03auJrLYFuwO0AA8fNkdLrNbiFainG(gWAXXtyPs525i4KScHkgGuPdyT44jSuPC7Ce8OgqVdOdYCaipaPshqlGbv9lHWIsmaimGoKDSKgFLDA7l0UUUie(g(6AwZUFtM5EYouzOm6KHy2jTHsByzhlPbwYtfHiiXa6vYaWyaYhasdafV14xbJzR)B(2(cLJFnaPshWAXXtyPs525i4KScHkgG8bSwC8ewQuUDocEudO3bK(ND(Uf)kymB9FZ32xO8Lqyrjgq)daoCaipa5daPbGI3A8RGXS1)nFBFHYxcHfLyaqyaWsNbiv6awloEclvk3ohbNKviuXaKpG1IJNWsLYTZrWxcHfLyaqyaWsNbGC2XsA8v2PTVq766Iq4B4RRzn7(TB5EYouzOm6KHy2jTHsByzh1yuP8hLfkTMgFXPYqz0zaYhasdafV14xbJzR)B(2(cLJFna5dOVbGWIYd1QdhdOdqQ0b03aqXBn(vWy26)MVTVq54xdq(aqyr5HA1HJb0biFaP)zNVBXVcgZw)38T9fkFjewuIbG8aKpaKgasdafV14xbJzR)B(2(cLVeclkXaGWaGLodqQ0bGI3AC8c6ZC1l0Lkykuo(1aKpau8wJJxqFMREHUubtHYxcHfLyaqyaWsNbG8aKpaKgWHqXBn(AD2VrI4c1sqoajdqgdqQ0b03aoKPq9qwbmOkFXlQ9lmIVwN9BKObG8aqo7yjn(k702xODDDri8n811SMD)gg5EYouzOm6KHy2jTHsByzh1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpGfVIK)67s7aGWa6Czoa5dyXlAaqqYa6WaKpaKgakERXrxYuO(V5frDwd2lmo(1aKkDaP)zNVBXrxYuO(V5frDwd2lm(siSOedO3baNYCaipaPshqFdqngvkhDjtH6)Mxe1znyVW4uzOm6ma5dyXRi5V(U0oaiizaWHYi7yjn(k7a11RxHslIi5VwsqvIYA29BDi3t2HkdLrNmeZoPnuAdl7K(ND(Uf)kymB9FZ32xO8LqyrjgaeKmazKDSKgFLDwleK)q2jRz3VbN5EYouzOm6KHy2jTHsByzhlPbwYtfHiiXa6vYaWyaYhasdOfWGQ(LqyrjgaegqhgGuPdOVbGI3AC0LmfQ)BEruN1G9cJJFna5daPbCrkhg0hNXxcHfLyaqyaWsNbiv6awloEclvk3ohbNKviuXaKpG1IJNWsLYTZrWxcHfLyaqyaDyaYhWAXXtyPs525i4rnGEhWfPCyqFCgFjewuIbG8aqo7yjn(k7iS0gTifgZFzjnRz3VjJCpzhQmugDYqm7K2qPnSSJL0al5PIqeKya9oazmaPshWIxu7xye)ckz7J4lsWPYqz0j7yjn(k7CitH6T64puYCnRzn7G(c)1)SOGL7j7(TCpzhQmugDYqm7yjn(k7SeIFfeJecF3OuAZohsK24sJVYoqCjtHoGVnaNOoRb7f2aU(NffSbSVAA81a64aeQTQya3KPyaOu7xAaq8DgqigGH1cMHYOStAdL2WYowsdSKNkcrqIb0RKbGXaKkDayTnmugX3UEu8wtK1S7yK7j7qLHYOtgIzhlPXxzNhLfkTMszN0gkTHLDqXBnoKbJffmpclbnkIVKL0biFaP)zNVBXVcgZw)38T9fkFjewuIb07a6q2j5AIrE1wyKkYUFlRz37qUNSdvgkJoziMDsBO0gw2bRTHHYi((Al53abLDSKgFLDG(DzrbZJYmHM1S7WzUNSdvgkJoziMDsBO0gw2bfV14qgmwuW8iSe0Oi(swshG8bS4vK8xFxA5hQfPqhqVdaPbCtgdO)bOgJkLV4vK8MQuHBA8fNkdLrNb4wdqgda5biFaIlIX8QTWivWB7lurYvfknGEhagdq(a6BayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUQqPSMDxg5EYouzOm6KHy2jTHsByzNfVIK)67sl)qTif6a6vYaqAaDqgdO)bOgJkLV4vK8MQuHBA8fNkdLrNb4wdqgda5biFaIlIX8QTWivWB7lurYvfknGEhagdq(a6BayTnmugXpKPqf(do5TKgyPSJL04RStBFHksUQqPSMDVZZ9KDOYqz0jdXSJL04RSZJYcLwtPStAdL2WYolEfj)13Lw(HArk0b0RKbGHmYojxtmYR2cJur29Bzn7oCyUNSdvgkJoziMDsBO0gw2zXRi5V(U0YpulsHoaimamK5aKpaXfXyE1wyKk4WywkmM3oyTkrdOxjdaJbiFaP)zNVBXVcgZw)38T9fkFjewuIb07aKr2XsA8v2bgZsHX82bRvjkRz3DB5EYouzOm6KHy2XsA8v2PTVq9cDdiPStAdL2WYolEfj)13Lw(HArk0baHbGHmhG8bK(ND(Uf)kymB9FZ32xO8LqyrjgqVdqgzNKRjg5vBHrQi7(TSMDhoi3t2HkdLrNmeZoPnuAdl7K(ND(Uf)kymB9FZ32xO8LqyrjgqVdyXlIRbcYRVhohG8bS4vK8xFxA5hQfPqhaegaCkZbiFaIlIX8QTWivWHXSuymVDWAvIgqVsgagzhlPXxzhymlfgZBhSwLOSMD)MmZ9KDOYqz0jdXSJL04RStBFH6f6gqszN0gkTHLDs)ZoF3IFfmMT(V5B7lu(siSOedO3bS4fX1ab513dNdq(aw8ks(RVlT8d1IuOdacdaoLz2j5AIrE1wyKkYUFlRzn7CTu6rGAAUNS73Y9KDOYqz0jdXSZFLDeKgTStAdL2WYo6gfKKY1BCOMWJlipkERna5daPb03auJrLYrxYuO(V5frDwd2lmovgkJodq(aqAa6gfKKY1B80)SZ3T4h8104RbiBgq6F257w8RGXS1)nFBFHYp4RPXxdqYaK5aqEasLoa1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaKgq6F257wC0LmfQ)BEruN1G9cJFWxtJVgGSza6gfKKY1B80)SZ3T4h8104RbizaYCaipaPshGAmQuEKOKDXPYqz0zaiNDoKiTXLgFLDW8WAmCtjXaSbOBuqsQyaP)zNVB5Yaob24qNbG66aUcgZ2b8Tb02xOd43bGUKPqhW3gGiQZAWEHDxmG0)SZ3T4dq21gqO3fdaRXWPba1edO(bSeclQdTdyjfFRbCZLbqmbnGLu8TgGm5YGNDWARVmeu2r3OGKu)nVW1kLDSKgFLDWAByOmk7G1y4KNyck7itUmYoyngoLDUL1S7yK7j7qLHYOtgIzN)k7iinAzhlPXxzhS2ggkJYoyT1xgck7OBuqsQhdVW1kLDsBO0gw2r3OGKuUIbhQj84cYJI3Adq(aqAa9na1yuPC0LmfQ)BEruN1G9cJtLHYOZaKpaKgGUrbjPCfdE6F257w8d(AA81aKndi9p78Dl(vWy26)MVTVq5h8104RbizaYCaipaPshGAmQuo6sMc1)nViQZAWEHXPYqz0zaYhasdi9p78Dlo6sMc1)nViQZAWEHXp4RPXxdq2maDJcss5kg80)SZ3T4h8104RbizaYCaipaPshGAmQuEKOKDXPYqz0zaiNDWAmCYtmbLDKjxgzhSgdNYo3YA29oK7j7qLHYOtgIzN)k7iinAzN0gkTHLD6Ba6gfKKY1BCOMWJlipkERna5dq3OGKuUIbhQj84cYJI3AdqQ0bOBuqskxXGd1eECb5rXBTbiFainaKgGUrbjPCfdE6F257w8d(AA81aG7a0nkijLRyWrXBn)bFnn(Aaipa3AainGBCzmG(hGUrbjPCfdout4rXBnUqxQGPqhaYdWTgasdaRTHHYiUUrbjPEm8cxR0aqEaipGEhasdaPbOBuqskxVXt)ZoF3IFWxtJVgaChGUrbjPC9ghfV18h8104RbG8aCRbG0aUXLXa6Fa6gfKKY1BCOMWJI3ACHUubtHoaKhGBnaKgawBddLrCDJcss938cxR0aqEaiNDoKiTXLgFLDW8eAGWusmaBa6gfKKkgawJHtda11bKEex2gfSbOqPbK(ND(U1a(2auO0a0nkij1LbCcSXHoda11bOqPbCWxtJVgW3gGcLgakERnGqhW1(yJdj4dq2UjgGnaHUubtHoae)jAbTdq)balWsdWga0aguAhW1g)gQRdq)bi0Lkyk0bOBuqsQWLbyIb0LySbyIbydaXFIwq7aA)oGOnaBa6gfKKoGUbJnGFhq3GXgq96aeUwPb0nuOdi9p78Dlbp7G1wFziOSJUrbjP(Rn(nuxZowsJVYoyTnmugLDWAmCYtmbLDULDWAmCk7GrwZUdN5EYouzOm6KHy25VYocsZowsJVYoyTnmugLDWAmCk7OgJkLdZuO0gfmVq)fbNkdLrNbiv6asFDWdLtyPTTVq5uzOm6maPshWIxu7xyehn0OG5tp7WPYqz0j7G1wFziOSZ21JI3AISMDxg5EYowsJVYongjGMwRPzhQmugDYqmRzn7ypL7j7(TCpzhQmugDYqm7CirAJln(k7i7FmVb42F104RSJL04RSZsi(vqmsi8DJsPnRz3Xi3t2HkdLrNmeZoPnuAdl7OgJkL32xOIKRkuItLHYOt2XsA8v2bgZsHX82bRvjkRz37qUNSdvgkJoziMDsBO0gw2bfV14qgmwuW8iSe0Oi(swshG8b03aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCvHszn7oCM7j7qLHYOtgIzN0gkTHLDWAByOmIVV2s(nqqdq(auJrLYnSgZQeuItLHYOt2XsA8v2b63LffmpkZeAwZUlJCpzhQmugDYqm7K2qPnSStFdafV14BGG44xdq(aSKgyjpveIGedacsgqhgGuPdWsAGL8uricsmGEhqhYowsJVYoWywkmM3oyTkrzn7ENN7j7qLHYOtgIzhlPXxzN2(c1l0nGKYojxtmYR2cJur29BzN0gkTHLDs)ZoF3IVeIFfeJecF3OuA5lHWIsmaiizayma3AaWsNbiFaQXOs5WmfkTrbZl0FrWPYqz0j7CirAJln(k7ah)lcCMfPbyxx7BjOdq)bKwYuAa2aUee(5hW1g)gQRdqTfgPdGfcDaTFhGDDXCnkydyTo73irdiQbypL1S7WH5EYouzOm6KHy2jTHsByzhS2ggkJ47RTKFdeu2XsA8v2b63LffmpkZeAwZU72Y9KDOYqz0jdXStAdL2WYoO4TghMPqPnkyEH(lco(1aKpalPbwYtfHiiXa6Dayma5dOVbG12Wqze)qMcv4p4K3sAGLYowsJVYoT9fQi5QcLYA2D4GCpzhQmugDYqm7K2qPnSSdwBddLr8dzkuH)GtElPbwAaYhakERXpKPqf(doXfQLGCaqyaW5aKkDaO4TghMPqPnkyEH(lco(v2XsA8v25rzHsRPuwZUFtM5EYouzOm6KHy2XsA8v2PTVq9cDdiPStAdL2WYolEfj)13Lw(HArk0baHbG0aUjJb0)auJrLYx8ksEtvQWnn(ItLHYOZaCRbiJbGC2j5AIrE1wyKkYUFlRz3VDl3t2HkdLrNmeZoPnuAdl703aWAByOmIFitHk8hCYBjnWszhlPXxzN2(cvKCvHszn7(nmY9KDOYqz0jdXSJL04RSZJYcLwtPStAdL2WYolEfj)13Lw(HArk0b07aqAayiJb0)auJrLYx8ksEtvQWnn(ItLHYOZaCRbiJbGC2j5AIrE1wyKkYUFlRz3V1HCpzhlPXxzhymlfgZBhSwLOSdvgkJoziM1S73GZCpzhlPXxzN2(cvKCvHszhQmugDYqmRz3VjJCpzhQmugDYqm7yjn(k702xOEHUbKu2j5AIrE1wyKkYUFlRz3V155EYowsJVYoq)T8FZ3nkL2SdvgkJoziM1S73GdZ9KDSKgFLDSnzf51FxQ0SdvgkJoziM1SMD0nkijvK7j7(TCpzhQmugDYqm7CirAJln(k70ZgfKKkYoLHGYorjslUAOmYJ5WTsXr4pe2irzN0gkTHLD6BaQXOs5Olzku)38IOoRb7fgNkdLrNbiFaO4Tg)kymB9FZ32xOC8RbiFaO4TgNqC9DP1V4f57s21xC8Rbiv6auJrLYrxYuO(V5frDwd2lmovgkJodq(aqAainau8wJFfmMT(V5B7luo(1aKpG0)SZ3T4Olzku)38IOoRb7fgFj746aqEasLoaKgakERXVcgZw)38T9fkh)AaYhasdaPb0cyqv)siSOedaZFaP)zNVBXrxYuO(V5frDwd2lm(siSOeda5baHbGXTbG8aqEaipaPsha6ledq(aAbmOQFjewuIbaHbGXTbiv6aoKPq9qwbmOk)ecdLr(aZD8KSOeUsdqYaK5aKpa1wyKY1ab513FLupgYCaqyaYi7yjn(k7eLiT4QHYipMd3kfhH)qyJeL1S7yK7j7qLHYOtgIzhlPXxzhfk5BXkuViGfSStAdL2WYoO4Tg)kymB9FZ32xOC8RbiFaO4TgNqC9DP1V4f57s21xC8RStziOSJcL8TyfQxeWcwwZU3HCpzhQmugDYqm7yjn(k7OBuqs6TSZHePnU04RStpqPbOBuqs6a6gk0bOqPbanGbLe6aiHgimLodaRXWjxgq3GXgaknaCbDgqlwHoaRod4YILodOBOqhaMDWy2oGVna449fkp7K2qPnSStFdaRTHHYiU4IsrlOJx3OGK0biFaO4Tg)kymB9FZ32xOC8RbiFainG(gGAmQuEKOKDXPYqz0zasLoa1yuP8irj7ItLHYOZaKpau8wJFfmMT(V5B7lu(siSOedOxjd4MmhaYdq(aqAa9naDJcss5kgCOMWN(ND(U1aKkDa6gfKKYvm4P)zNVBXxcHfLyasLoaS2ggkJ46gfKK6V243qDDasgWTbG8aKkDa6gfKKY1BCu8wZFWxtJVgqVsgqlGbv9lHWIsK1S7WzUNSdvgkJoziMDsBO0gw2PVbG12WqzexCrPOf0XRBuqs6aKpau8wJFfmMT(V5B7luo(1aKpaKgqFdqngvkpsuYU4uzOm6maPshGAmQuEKOKDXPYqz0zaYhakERXVcgZw)38T9fkFjewuIb0RKbCtMda5biFainG(gGUrbjPC9ghQj8P)zNVBnaPshGUrbjPC9gp9p78Dl(siSOedqQ0bG12Wqzex3OGKu)1g)gQRdqYaWyaipaPshGUrbjPCfdokER5p4RPXxdOxjdOfWGQ(LqyrjYowsJVYo6gfKKIrwZUlJCpzhQmugDYqm7yjn(k7OBuqs6TSJG9A2r3OGK0BzN0gkTHLD6BayTnmugXfxukAbD86gfKKoa5daPb03a0nkijLR34qnHhxqEu8wBaYhasdq3OGKuUIbp9p78Dl(siSOedqQ0b03a0nkijLRyWHAcpUG8O4T2aqEasLoG0)SZ3T4xbJzR)B(2(cLVeclkXa6DayiZbGC25qI0gxA8v2r21gWxmxhWx0a(Aa4cAa6gfKKoGR9XghsmaBaO4TMldaxqdqHsd4vO0oGVgq6F257w8bGzTdiAdOOqHs7a0nkijDax7JnoKya2aqXBnxgaUGga6RqhWxdi9p78DlEwZU355EYouzOm6KHy2XsA8v2r3OGKumYoPnuAdl703aWAByOmIlUOu0c641nkijDaYhasdOVbOBuqskxXGd1eECb5rXBTbiFainaDJcss56nE6F257w8LqyrjgGuPdOVbOBuqskxVXHAcpUG8O4T2aqEasLoG0)SZ3T4xbJzR)B(2(cLVeclkXa6DayiZbGC2rWEn7OBuqskgznRzNd1mCMM7j7(TCpzhlPXxzherD8TLOoJYouzOm6KHywZUJrUNSdvgkJoziMD(RSJG0SJL04RSdwBddLrzhSgdNYoinacZHhxx0HhLiT4QHYipMd3kfhH)qyJenaPshaH5WJRl6WvOKVfRq9IawWgaYdq(aqAaP)zNVBXJsKwC1qzKhZHBLIJWFiSrI4lzhxhGuPdi9p78DlUcL8TyfQxeWcgFjewuIbG8aKkDaeMdpUUOdxHs(wSc1lcybBaYhaH5WJRl6WJsKwC1qzKhZHBLIJWFiSrIYohsK24sJVYoy2lHLkDaIlkfTGodq3OGKuXaqPOGnaCbDgq3qHoadxFeMgPbWIIezhS26ldbLDexukAbD86gfKKM1S7Di3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzhlPbwYtfHiiXaKmGBdq(aqAaRfhpHLkLBNJGh1a6Da3KXaKkDa9nG1IJNWsLYTZrWjzfcvmaKZoyT1xgck7iu)fZQkkyzn7oCM7j7qLHYOtgIzN)k7iin7yjn(k7G12Wqzu2bRXWPSJL0al5PIqeKya9kzayma5daPb03awloEclvk3ohbNKviuXaKkDaRfhpHLkLBNJGtYkeQyaYhasdyT44jSuPC7Ce8LqyrjgqVdqgdqQ0b0cyqv)siSOedO3bCtMda5bGC2bRT(Yqqzh7Ce(LqyrL1S7Yi3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzhu8wJVbcIJFna5daPb03aw8IA)cJ4RbJ8FZRqjFB)oJkFcQH4k(ItLHYOZaKkDalErTFHr81Gr(V5vOKVTFNrLpb1qCfFXPYqz0zaYhWIxrYF9DPLFOwKcDa9oa32aqo7G1wFziOSZ(Al53abL1S7DEUNSdvgkJoziMD(RSJG0SJL04RSdwBddLrzhSgdNYoPVo4HYP1orY0OG5rzF3biFaO4TgNw7ejtJcMhL9D5c1sqoajdaJbiv6asFDWdLJxmYeqPJVTu1zUYPYqz0zaYhakERXXlgzcO0X3wQ6mx5lHWIsmaimaKgaS0zaU1aWyaiNDWARVmeu2PTVq9cDdijF6RdEOISMDhom3t2HkdLrNmeZo)v2rqA2XsA8v2bRTHHYOSdwJHtzNdzkuVvh)HsMRCnsqgfSbiFaPhlvwP8kGbv9nJYoyT1xgck7CitHk8hCYBjnWszn7UBl3t2HkdLrNmeZowsJVYolH4xbXiHW3nkL2SZHePnU04RSJS)6I56aGJ3xOdaoMWsRldaHfLArnazxY1b0JX(smaRodasIUgGBNq8RGyKqmazROuAhW(mwuWYoPnuAdl7K(6GhkNWsBBFHoa5dqngvkhMPqPnkyEH(lcovgkJodq(aqAa9na1yuP8hLfkTMgFXPYqz0zaYhq6F257w8RGXS1)nFBFHYxcHfLyasLoabPE0VWfCnOfd3MhoVsdq(auJrLYFuwO0AA8fNkdLrNbiFa9nau8wJFfmMT(V5B7luo(1aqoRz3HdY9KDOYqz0jdXSJL04RSd0VllkyEuMj0StAdL2WYo9nGZR82(c13iS0YxcHfLyaYhasdqngvkpsuYU4uzOm6maPshqFdafV14Olzku)38IOoRb7fgh)AaYhGAmQuo6sMc1)nViQZAWEHXPYqz0zasLoa1yuP8hLfkTMgFXPYqz0zaYhq6F257w8RGXS1)nFBFHYxcHfLyaYhqFdafV14qgmwuW8iSe0Oio(1aqo7KCnXiVAlmsfz3VL1S73KzUNSdvgkJoziMDsBO0gw2bfV14rYvVASVe8LqyrjgaeKmayPZaCRbGXaKpa1yuP8i5Qxn2xcovgkJodq(aexeJ5vBHrQGdJzPWyE7G1QenGELmamgG8bG0auJrLYJeLSlovgkJodqQ0bOgJkLJUKPq9FZlI6SgSxyCQmugDgG8bK(ND(UfhDjtH6)Mxe1znyVW4lHWIsmGEhWnzmaPshGAmQu(JYcLwtJV4uzOm6ma5dOVbGI3A8RGXS1)nFBFHYXVgaYzhlPXxzhymlfgZBhSwLOSMD)2TCpzhQmugDYqm7K2qPnSSdkERXJKRE1yFj4lHWIsmaiizaWsNb4wdaJbiFaQXOs5rYvVASVeCQmugDgG8bG0auJrLYJeLSlovgkJodqQ0bOgJkLJUKPq9FZlI6SgSxyCQmugDgG8b03aqXBno6sMc1)nViQZAWEHXXVgG8bK(ND(UfhDjtH6)Mxe1znyVW4lHWIsmGEhWnzoaPshGAmQu(JYcLwtJV4uzOm6ma5dOVbGI3A8RGXS1)nFBFHYXVgaYzhlPXxzN2(c1l0nGKYA29ByK7j7qLHYOtgIzN0gkTHLDspwQSs5vadQ6Bgna5d4qMc1B1XFOK5kxJeKrbBaYhWHmfQ3QJ)qjZvUL0al5xcHfLyaqyainayPZaCRbCJlJbG8aKpaKgqFdqngvk)rzHsRPXxCQmugDgGuPdqngvk)rzHsRPXxCQmugDgG8b03aqXBn(vWy26)MVTVq54xda5SJL04RSZJYcLwtPSMD)whY9KDOYqz0jdXSZHePnU04RSJBG(VGgGSpPXxdGfcDa6pGfVYowsJVYojJX8wsJV8SqOzhwiuFziOSt6XsLvQiRz3VbN5EYouzOm6KHy2XsA8v2jzmM3sA8LNfcn7WcH6ldbLDwlfgtK1S73KrUNSdvgkJoziMDSKgFLDsgJ5TKgF5zHqZoSqO(YqqzhDJcssfzn7(Top3t2HkdLrNmeZowsJVYojJX8wsJV8SqOzhwiuFziOSt6F257wISMD)gCyUNSdvgkJoziMDsBO0gw2rngvkp9SJhkzRYPYqz0zaYhasdOVbGI3ACidglkyEewcAueh)AasLoa1yuPC0LmfQ)BEruN1G9cJtLHYOZaqEaYhasd4qO4TgFTo73irCHAjihGKbiJbiv6a6BahYuOEiRaguLV4f1(fgXxRZ(ns0aqo7i0nsA29BzhlPXxzNKXyElPXxEwi0SdleQVmeu2j9SJhkzRM1S73CB5EYouzOm6KHy2jTHsByzhu8wJJUKPq9FZlI6SgSxyC8RSJq3iPz3VLDSKgFLDw8YBjn(YZcHMDyHq9LHGYoOVWRrcYOGL1S73GdY9KDOYqz0jdXStAdL2WYoQXOs5Olzku)38IOoRb7fgNkdLrNbiFainG0)SZ3T4Olzku)38IOoRb7fgFjewuIbaHbCtMda5biFainG1IJNWsLYTZrWJAa9oamKXaKkDa9nG1IJNWsLYTZrWjzfcvmaPshq6F257w8RGXS1)nFBFHYxcHfLyaqya3K5aKpG1IJNWsLYTZrWjzfcvma5dyT44jSuPC7Ce8OgaegWnzoaKZowsJVYolE5TKgF5zHqZoSqO(Yqqzh0x4V(NffSSMDhdzM7j7qLHYOtgIzN0gkTHLDqXBn(vWy26)MVTVq54xdq(auJrLYFuwO0AA8fNkdLrNSJq3iPz3VLDSKgFLDw8YBjn(YZcHMDyHq9LHGYopkluAnn(kRz3X4wUNSdvgkJoziMDsBO0gw2PVbii1J(fUGRbTy428W5vAaYhGAmQu(JYcLwtJV4uzOm6ma5di9p78Dl(vWy26)MVTVq5lHWIsmaimGBYCaYhasdaRTHHYiUq9xmRQOGnaPshWAXXtyPs525i4KScHkgG8bSwC8ewQuUDocEudacd4MmhGuPdOVbSwC8ewQuUDocojRqOIbGC2XsA8v2zXlVL04lpleA2Hfc1xgck78OSqP104l)1)SOGL1S7yGrUNSdvgkJoziMDsBO0gw2XsAGL8uricsmGELmamYocDJKMD)w2XsA8v2zXlVL04lpleA2Hfc1xgck7ypL1S7y0HCpzhQmugDYqm7yjn(k7KmgZBjn(YZcHMDyHq9LHGYoc1QJTNSM1SZAPWyICpz3VL7j7qLHYOtgIzhlPXxzhu2)hFdFDn7CirAJln(k742TuySbi7rdwObjYoPnuAdl7GI3A8RGXS1)nFBFHYXVYA2DmY9KDOYqz0jdXStAdL2WYoO4Tg)kymB9FZ32xOC8RSJL04RSdkTcAHmkyzn7EhY9KDOYqz0jdXStAdL2WYoinG(gakERXVcgZw)38T9fkh)AaYhGL0al5PIqeKya9kzaymaKhGuPdOVbGI3A8RGXS1)nFBFHYXVgG8bG0aw8I4hQfPqhqVsgGmgG8bS4vK8xFxA5hQfPqhqVsgqNlZbGC2XsA8v2X2KvK)cNjOSMDhoZ9KDOYqz0jdXStAdL2WYoO4Tg)kymB9FZ32xOC8RSJL04RSdlGbvfE4OIFGHGknRz3LrUNSdvgkJoziMDsBO0gw2bfV14xbJzR)B(2(cLJFna5dafV14eIRVlT(fViFxYU(IJFLDSKgFLDSkrcDnMpzmwwZU355EYouzOm6KHy2jTHsByzhu8wJFfmMT(V5B7lu(siSOedacsgGBBaYhakERXVcgZw)38T9fkh)AaYhakERXjexFxA9lEr(UKD9fh)k7yjn(k70ILqz)FYA2D4WCpzhQmugDYqm7K2qPnSSdkERXVcgZw)38T9fkh)AaYhGL0al5PIqeKyasgWTbiFainau8wJFfmMT(V5B7lu(siSOedacdqgdq(auJrLYtp74Hs2QCQmugDgGuPdOVbOgJkLNE2XdLSv5uzOm6ma5dafV14xbJzR)B(2(cLVeclkXaGWa6Waqo7yjn(k7GAW8FZRBKGuK1SM1SdwAfXxz3XqMyGHmXaJBzNU2wrbtKDKTK9UD3LDUdhPJdya9aLgqG46xDaTFhW9hLfkTMgF5V(NffS7dyjmhES0zaIhbnadxFeMsNbKGAfmsWh47uu0aWOJdWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(amDayEywDAaiDtwiZh4h4LTK9UD3LDUdhPJdya9aLgqG46xDaTFhW90ZoEOKT69bSeMdpw6maXJGgGHRpctPZasqTcgj4d8DkkAa364aCZxyPvPZaUV4f1(fgXX09bO)aUV4f1(fgXXeNkdLrN7daj4uwiZh47uu0aWOJdWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aq6MSqMpW3POOb0Hooa38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBYcz(aFNIIgaC2Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtwiZh47uu0aKrhhGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bG0nzHmFGFGx2s272Dx25oCKooGb0duAabIRF1b0(Da3FuwO0AA819bSeMdpw6maXJGgGHRpctPZasqTcgj4d8DkkAay0Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtwiZh47uu0aWOJdWnFHLwLod4E6RdEOCmDFa6pG7PVo4HYXeNkdLrN7daPBYcz(aFNIIgWnz2Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiHHSqMpWpWlBj7D7Ul7ChoshhWa6bknGaX1V6aA)oG7OVWRrcYOGDFalH5WJLodq8iOby46JWu6mGeuRGrc(aFNIIgWTooa38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBYcz(aFNIIgagDCaU5lS0Q0zaobc3maHRLAYAaYMbO)a6eUnGtGneXxd4VO10FhasWf5bG0nzHmFGVtrrdOdDCaU5lS0Q0zaobc3maHRLAYAaYMbO)a6eUnGtGneXxd4VO10FhasWf5bG0nzHmFGVtrrdao74aCZxyPvPZaCceUzacxl1K1aKndq)b0jCBaNaBiIVgWFrRP)oaKGlYdaPBYcz(aFNIIgaC2Xb4MVWsRsNbCFXlQ9lmIJP7dq)bCFXlQ9lmIJjovgkJo3has3KfY8b(bEzlzVB3DzN7Wr64agqpqPbeiU(vhq73bCp9yPYkvCFalH5WJLodq8iOby46JWu6mGeuRGrc(aFNIIgWTooa38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7dajmKfY8b(offnam64aCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaKUjlK5d8DkkAaDOJdWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aq6MSqMpW3POObaNDCaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KfY8b(offnaz0Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiHHSqMpW3POObah2Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtwiZh47uu0aGd64aCZxyPvPZaUlECgAuhoMUpa9hWDXJZqJ6WXeNkdLrN7dajmKfY8b(bEzlzVB3DzN7Wr64agqpqPbeiU(vhq73bCxOwDS9CFalH5WJLodq8iOby46JWu6mGeuRGrc(aFNIIgqN3Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaMoampmRonaKUjlK5d8DkkAaUTooa38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBYcz(aFNIIgaCqhhGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bGuhKfY8b(bEzlzVB3DzN7Wr64agqpqPbeiU(vhq73bCh9f(R)zrb7(awcZHhlDgG4rqdWW1hHP0zajOwbJe8b(offna4SJdWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aq6MSqMpW3POObiJooa38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBYcz(a)aVSLS3T7USZD4iDCadOhO0acex)QdO97aUFTu6rGA69bSeMdpw6maXJGgGHRpctPZasqTcgj4d8DkkAa364aCZxyPvPZaCceUzacxl1K1aKnYMbO)a6eUnae)bNHlgWFrRP)oaKKnipaKWqwiZh47uu0aU1Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFai1bzHmFGVtrrd4whhGB(clTkDgWDDJcss534y6(a0Fa31nkijLR34y6(aqQdYcz(aFNIIgagDCaU5lS0Q0zaobc3maHRLAYAaYgzZa0FaDc3gaI)GZWfd4VO10FhasYgKhasyilK5d8DkkAay0Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFai1bzHmFGVtrrdaJooa38fwAv6mG76gfKKYXGJP7dq)bCx3OGKuUIbht3hasDqwiZh47uu0a6qhhGB(clTkDgGtGWndq4APMSgGSza6pGoHBd4eydr81a(lAn93bGeCrEaiHHSqMpW3POOb0Hooa38fwAv6mG76gfKKYVXX09bO)aURBuqskxVXX09bGeCklK5d8DkkAaDOJdWnFHLwLod4UUrbjPCm4y6(a0Fa31nkijLRyWX09bGKmKfY8b(offna4SJdWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(aq6MSqMpW3POObaNDCaU5lS0Q0za3x8IA)cJ4y6(a0Fa3x8IA)cJ4yItLHYOZ9by6aW8WS60aq6MSqMpW3POObaNDCaU5lS0Q0za3tFDWdLJP7dq)bCp91bpuoM4uzOm6CFaiDtwiZh4h4LTK9UD3LDUdhPJdya9aLgqG46xDaTFhW90)SZ3Te3hWsyo8yPZaepcAagU(imLodib1kyKGpW3POObGrhhGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bG0nzHmFGVtrrdaJooa38fwAv6mG7IhNHg1HJP7dq)bCx84m0OoCmXPYqz05(aqcdzHmFGVtrrdOdDCaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KfY8b(offnGo0Xb4MVWsRsNbCFXlQ9lmIJP7dq)bCFXlQ9lmIJjovgkJo3has3KfY8b(offna4SJdWnFHLwLod4UAmQuoMUpa9hWD1yuPCmXPYqz05(amDayEywDAaiDtwiZh47uu0aKrhhGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bG0nzHmFGVtrrdOZ74aCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaKUjlK5d8DkkAaWHDCaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KfY8b(offna4Gooa38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBYcz(aFNIIgWTBDCaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KfY8b(offnGBy0Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiHHSqMpW3POObCtgDCaU5lS0Q0za3x8IA)cJ4y6(a0Fa3x8IA)cJ4yItLHYOZ9by6aW8WS60aq6MSqMpWpWlBj7D7Ul7ChoshhWa6bknGaX1V6aA)oG76gfKKkUpGLWC4XsNbiEe0amC9rykDgqcQvWibFGVtrrd4whhGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bGegYcz(aFNIIgqh64aCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaKWqwiZh47uu0a6qhhGB(clTkDgWDDJcss534y6(a0Fa31nkijLR34y6(aq6MSqMpW3POOb0Hooa38fwAv6mG76gfKKYXGJP7dq)bCx3OGKuUIbht3hasyilK5d8DkkAaWzhhGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bGegYcz(aFNIIgaC2Xb4MVWsRsNbCx3OGKu(noMUpa9hWDDJcss56noMUpaKWqwiZh47uu0aGZooa38fwAv6mG76gfKKYXGJP7dq)bCx3OGKuUIbht3has3KfY8b(offnaz0Xb4MVWsRsNbCx3OGKu(noMUpa9hWDDJcss56noMUpaKUjlK5d8DkkAaYOJdWnFHLwLod4UUrbjPCm4y6(a0Fa31nkijLRyWX09bGegYcz(aFNIIgqN3Xb4MVWsRsNbCx3OGKu(noMUpa9hWDDJcss56noMUpaKWqwiZh47uu0a68ooa38fwAv6mG76gfKKYXGJP7dq)bCx3OGKuUIbht3has3KfY8b(bEzlzVB3DzN7Wr64agqpqPbeiU(vhq73bC)qndNP3hWsyo8yPZaepcAagU(imLodib1kyKGpW3POObiJooa38fwAv6mG7lErTFHrCmDFa6pG7lErTFHrCmXPYqz05(aqcdzHmFGVtrrdOZ74aCZxyPvPZaUN(6Ghkht3hG(d4E6RdEOCmXPYqz05(aq6MSqMpW3POOb4264aCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaK6GSqMpW3POObah0Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFai1bzHmFGVtrrd4Mm74aCZxyPvPZaURgJkLJP7dq)bCxngvkhtCQmugDUpaKGtzHmFGVtrrd42Tooa38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daj4uwiZh47uu0aUHrhhGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9bGegYcz(aFNIIgWn4Wooa38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7dajmKfY8b(offnGBWbDCaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KfY8b(offnamKzhhGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9by6aW8WS60aq6MSqMpW3POObGXTooa38fwAv6mG7QXOs5y6(a0Fa3vJrLYXeNkdLrN7daPBYcz(a)aVSLS3T7USZD4iDCadOhO0acex)QdO97aUBpDFalH5WJLodq8iOby46JWu6mGeuRGrc(aFNIIgagDCaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3hGPdaZdZQtdaPBYcz(aFNIIgaC2Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaMoampmRonaKUjlK5d8DkkAaDEhhGB(clTkDgWD1yuPCmDFa6pG7QXOs5yItLHYOZ9by6aW8WS60aq6MSqMpW3POObCtMDCaU5lS0Q0za3vJrLYX09bO)aURgJkLJjovgkJo3has3KfY8b(offnGBy0Xb4MVWsRsNbCxngvkht3hG(d4UAmQuoM4uzOm6CFaiDtwiZh4h4LDiU(vPZaU1Hbyjn(AaSqOc(aF2rCrPS7yiJBzNR9BbJYoygmZaKTrMcDaWrxbmO6aGJ3xOd8ygmZaGJj0f3wxhagDUldadzIbgd8d8ygmZaCduRGrIbEmdMzay(dWTtiES0zamtOy(ck91za4cdgnGVna3a1IsmGVnazxIgGjgqOd48KOURd4IzUoGUeJnGOgW1AjnseFGhZGzgaM)aKT91DDajOwveBaWXmsanTwthWbFJc2aG4sMcDaFBaorDwd2lm(a)apMzayEyngUPKya2a0nkijvmG0)SZ3TCzaNaBCOZaqDDaxbJz7a(2aA7l0b87aqxYuOd4Bdqe1znyVWUlgq6F257w8bi7Adi07IbG1y40aGAIbu)awcHf1H2bSKIV1aU5YaiMGgWsk(wdqMCzWh4TKgFj4xlLEeOM2Ve4I12WqzKlLHGKOBuqsQ)Mx4ALC5VKiinAUG1y4KKBUG1y4KNycsIm5YWL0xNqJVKOBuqsk)ghQj84cYJI3AYrQp1yuPC0LmfQ)BEruN1G9ctos6gfKKYVXt)ZoF3IFWxtJVKnYM0)SZ3T4xbJzR)B(2(cLFWxtJVKitKLkvngvkhDjtH6)Mxe1znyVWKJu6F257wC0LmfQ)BEruN1G9cJFWxtJVKnYgDJcss534P)zNVBXp4RPXxsKjYsLQgJkLhjkzxipWBjn(sWVwk9iqnTFjWfRTHHYixkdbjr3OGKupgEHRvYL)sIG0O5cwJHtsU5cwJHtEIjijYKldxsFDcn(sIUrbjPCm4qnHhxqEu8wtos9PgJkLJUKPq9FZlI6SgSxyYrs3OGKuog80)SZ3T4h8104lzJSj9p78Dl(vWy26)MVTVq5h8104ljYezPsvJrLYrxYuO(V5frDwd2lm5iL(ND(UfhDjtH6)Mxe1znyVW4h8104lzJSr3OGKuog80)SZ3T4h8104ljYezPsvJrLYJeLSlKh4XmdaZtObctjXaSbOBuqsQyayngonauxhq6rCzBuWgGcLgq6F257wd4BdqHsdq3OGKuxgWjWgh6mauxhGcLgWbFnn(AaFBakuAaO4T2acDax7JnoKGpaz7Mya2ae6sfmf6aq8NOf0oa9haSalnaBaqdyqPDaxB8BOUoa9hGqxQGPqhGUrbjPcxgGjgqxIXgGjgGnae)jAbTdO97aI2aSbOBuqs6a6gm2a(DaDdgBa1Rdq4ALgq3qHoG0)SZ3Te8bElPXxc(1sPhbQP9lbUyTnmug5sziij6gfKK6V243qD1L)sIG0O5cwJHtsWWfSgdN8etqsU5s6RtOXxs6t3OGKu(nout4XfKhfV1KRBuqskhdout4XfKhfV1Kkv3OGKuogCOMWJlipkERjhjK0nkijLJbp9p78Dl(bFnn(s2OBuqskhdokER5p4RPXxi7wiDJlJ(1nkijLJbhQj8O4TgxOlvWuOi7wiH12Wqzex3OGKupgEHRvczK7fjK0nkijLFJN(ND(Uf)GVMgFjB0nkijLFJJI3A(d(AA8fYUfs34YOFDJcss534qnHhfV14cDPcMcfz3cjS2ggkJ46gfKK6V5fUwjKrEG3sA8LGFTu6rGAA)sGlwBddLrUugcsY21JI3AcxWAmCsIAmQuomtHsBuW8c9xesLM(6GhkNWsBBFHkv6Ixu7xyehn0OG5tp7mWBjn(sWVwk9iqnTFjWTXib00AnDGFGhZGzgaMNSOeUsNbqyP11bObcAakuAaws)DaHyagwlygkJ4d8wsJVesqe1X3wI6mAGhZmam7LWsLoaXfLIwqNbOBuqsQyaOuuWgaUGodOBOqhGHRpctJ0ayrrIbElPXxI(LaxS2ggkJCPmeKeXfLIwqhVUrbjPUG1y4KeKimhECDrhEuI0IRgkJ8yoCRuCe(dHnsKuPeMdpUUOdxHs(wSc1lcybdz5iL(ND(UfpkrAXvdLrEmhUvkoc)HWgjIVKDCvQ00)SZ3T4kuY3IvOEraly8LqyrjqwQucZHhxx0HRqjFlwH6fbSGjNWC4X1fD4rjslUAOmYJ5WTsXr4pe2ird8wsJVe9lbUyTnmug5sziijc1FXSQIcMlyngojXsAGL8uricsi5MCKwloEclvk3ohbpQEVjdPs7BT44jSuPC7CeCswHqfipWBjn(s0Ve4I12WqzKlLHGKyNJWVeclkxWAmCsIL0al5PIqeKOxjyihP(wloEclvk3ohbNKviuHuPRfhpHLkLBNJGtYkeQqosRfhpHLkLBNJGVeclkrVYqQ0wadQ6xcHfLO3BYezKh4TKgFj6xcCXAByOmYLYqqs2xBj)giixWAmCsckERX3abXXVKJuFlErTFHr81Gr(V5vOKVTFNrLpb1qCfFjv6Ixu7xyeFnyK)BEfk5B73zu5tqnexXxYx8ks(RVlT8d1IuO962qEG3sA8LOFjWfRTHHYixkdbjPTVq9cDdijF6RdEOcxWAmCss6RdEOCATtKmnkyEu23vokERXP1orY0OG5rzFxUqTeKsWqQ00xh8q54fJmbu64BlvDMRYrXBnoEXitaLo(2svN5kFjewuciGeS0XTWa5bElPXxI(LaxS2ggkJCPmeKKdzkuH)GtElPbwYfSgdNKCitH6T64puYCLRrcYOGjp9yPYkLxbmOQVz0apMzaY(RlMRdaoEFHoa4yclTUmaewuQf1aKDjxhqpg7lXaS6maij6AaUDcXVcIrcXaKTIsPDa7ZyrbBG3sA8LOFjWDje)kigje(UrP06s0KK(6GhkNWsBBFHkxngvkhMPqPnkyEH(lc5i1NAmQu(JYcLwtJVKN(ND(Uf)kymB9FZ32xO8LqyrjKkvqQh9lCbxdAXWT5HZRKC1yuP8hLfkTMgFjVpu8wJFfmMT(V5B7luo(fYd8wsJVe9lbUq)USOG5rzMqDj5AIrE1wyKkKCZLOjPVZR82(c13iS0YxcHfLqosQXOs5rIs2LuP9HI3AC0LmfQ)BEruN1G9cJJFjxngvkhDjtH6)Mxe1znyVWKkvngvk)rzHsRPXxYt)ZoF3IFfmMT(V5B7lu(siSOeY7dfV14qgmwuW8iSe0Oio(fYd8wsJVe9lbUWywkmM3oyTkrUenjO4TgpsU6vJ9LGVeclkbeKalDClmKRgJkLhjx9QX(sixCrmMxTfgPcomMLcJ5TdwRsuVsWqosQXOs5rIs2LuPQXOs5Olzku)38IOoRb7fM80)SZ3T4Olzku)38IOoRb7fgFjewuIEVjdPsvJrLYFuwO0AA8L8(qXBn(vWy26)MVTVq54xipWBjn(s0Ve422xOEHUbKKlrtckERXJKRE1yFj4lHWIsabjWsh3cd5QXOs5rYvVASVeYrsngvkpsuYUKkvngvkhDjtH6)Mxe1znyVWK3hkERXrxYuO(V5frDwd2lmo(L80)SZ3T4Olzku)38IOoRb7fgFjewuIEVjtPsvJrLYFuwO0AA8L8(qXBn(vWy26)MVTVq54xipWBjn(s0Ve4(OSqP1uYLOjj9yPYkLxbmOQVzK8dzkuVvh)HsMRCnsqgfm5hYuOERo(dLmx5wsdSKFjewuciGeS0XTUXLbYYrQp1yuP8hLfkTMgFjvQAmQu(JYcLwtJVK3hkERXVcgZw)38T9fkh)c5bEmZaCd0)f0aK9jn(AaSqOdq)bS41aVL04lr)sGBYymVL04lpleQlLHGKKESuzLkg4TKgFj6xcCtgJ5TKgF5zHqDPmeKK1sHXed8wsJVe9lbUjJX8wsJV8SqOUugcsIUrbjPIbElPXxI(La3KXyElPXxEwiuxkdbjj9p78DlXaVL04lr)sGBYymVL04lpleQlLHGKKE2XdLSvDrOBKuj3CjAsuJrLYtp74Hs2QYrQpu8wJdzWyrbZJWsqJI44xsLQgJkLJUKPq9FZlI6SgSxyilhPdHI3A816SFJeXfQLGuImKkTVdzkupKvadQYx8IA)cJ4R1z)gjc5bElPXxI(La3fV8wsJV8SqOUugcsc6l8AKGmkyUi0nsQKBUenjO4TghDjtH6)Mxe1znyVW44xd8wsJVe9lbUlE5TKgF5zHqDPmeKe0x4V(NffmxIMe1yuPC0LmfQ)BEruN1G9ctosP)zNVBXrxYuO(V5frDwd2lm(siSOeq4MmrwosRfhpHLkLBNJGhvVyidPs7BT44jSuPC7CeCswHqfsLM(ND(Uf)kymB9FZ32xO8LqyrjGWnzkFT44jSuPC7CeCswHqfYxloEclvk3ohbpkiCtMipWBjn(s0Ve4U4L3sA8LNfc1LYqqsEuwO0AA8LlcDJKk5MlrtckERXVcgZw)38T9fkh)sUAmQu(JYcLwtJVg4TKgFj6xcCx8YBjn(YZcH6sziijpkluAnn(YF9plkyUenj9ji1J(fUGRbTy428W5vsUAmQu(JYcLwtJVKN(ND(Uf)kymB9FZ32xO8LqyrjGWnzkhjS2ggkJ4c1FXSQIcMuPRfhpHLkLBNJGtYkeQq(AXXtyPs525i4rbHBYuQ0(wloEclvk3ohbNKviubYd8wsJVe9lbUlE5TKgF5zHqDPmeKe7jxe6gjvYnxIMelPbwYtfHiirVsWyG3sA8LOFjWnzmM3sA8LNfc1LYqqseQvhBpd8d8yMbi7FmVb42F104RbElPXxcU9KKLq8RGyKq47gLs7aVL04lb3EQFjWfgZsHX82bRvjYLOjrngvkVTVqfjxvO0aVL04lb3EQFjWTTVqfjxvOKlrtckERXHmySOG5ryjOrr8LSKkVpS2ggkJ4hYuOc)bN8wsdS0aVL04lb3EQFjWf63LffmpkZeQlrtcwBddLr891wYVbcsUAmQuUH1ywLGsd8wsJVeC7P(LaxymlfgZBhSwLixIMK(qXBn(giio(LClPbwYtfHiibeK0bPsTKgyjpveIGe92HbEmZaGJ)fboZI0aSRR9Te0bO)aslzknaBaxcc)8d4AJFd11bO2cJ0bWcHoG2VdWUUyUgfSbSwN9BKObe1aSNg4TKgFj42t9lbUT9fQxOBaj5sY1eJ8QTWivi5Mlrts6F257w8Lq8RGyKq47gLslFjewuciibd3cw6ixngvkhMPqPnkyEH(lIbElPXxcU9u)sGl0VllkyEuMjuxIMeS2ggkJ47RTKFde0aVL04lb3EQFjWTTVqfjxvOKlrtckERXHzkuAJcMxO)IGJFj3sAGL8urics0lgY7dRTHHYi(HmfQWFWjVL0alnWBjn(sWTN6xcCFuwO0Ak5s0KG12Wqze)qMcv4p4K3sAGLKJI3A8dzkuH)GtCHAjiHaCkvkkERXHzkuAJcMxO)IGJFnWBjn(sWTN6xcCB7luVq3asYLKRjg5vBHrQqYnxIMKfVIK)67sl)qTifkeq6Mm6xngvkFXRi5nvPc304l3sgipWBjn(sWTN6xcCB7lurYvfk5s0K0hwBddLr8dzkuH)GtElPbwAG3sA8LGBp1Ve4(OSqP1uYLKRjg5vBHrQqYnxIMKfVIK)67sl)qTifAViHHm6xngvkFXRi5nvPc304l3sgipWBjn(sWTN6xcCHXSuymVDWAvIg4TKgFj42t9lbUT9fQi5QcLg4TKgFj42t9lbUT9fQxOBaj5sY1eJ8QTWivi52aVL04lb3EQFjWf6VL)B(UrP0oWBjn(sWTN6xcCTnzf51FxQ0b(bEmZaG4sMcDaFBaorDwd2lSbC9plkydyF104Rb0XbiuBvXaUjtXaqP2V0aG47mGqmadRfmdLrd8wsJVeC0x4V(NffmjlH4xbXiHW3nkLwxIMelPbwYtfHiirVsWqQuS2ggkJ4BxpkERjg4TKgFj4OVWF9plky9lbUpkluAnLCj5AIrE1wyKkKCZLOjbfV14qgmwuW8iSe0Oi(swsLN(ND(Uf)kymB9FZ32xO8Lqyrj6Tdd8wsJVeC0x4V(NffS(LaxOFxwuW8OmtOUenjyTnmugX3xBj)giObElPXxco6l8x)ZIcw)sGBBFHksUQqjxIMeu8wJdzWyrbZJWsqJI4lzjv(IxrYF9DPLFOwKcTxKUjJ(vJrLYx8ksEtvQWnn(YTKbYYfxeJ5vBHrQG32xOIKRkuQxmK3hwBddLr8dzkuH)GtElPbwAG3sA8LGJ(c)1)SOG1Ve422xOIKRkuYLOjzXRi5V(U0YpulsH2ReK6Gm6xngvkFXRi5nvPc304l3sgilxCrmMxTfgPcEBFHksUQqPEXqEFyTnmugXpKPqf(do5TKgyPbEmdMza3vBHrQpAsqyYQJiDiu8wJVwN9BKiUqTeK9FdzzdshcfV14R1z)gjIVeclkr)3q2ToKPq9qwbmOkFXlQ9lmIVwN9BKO7dWTtxKPIbydG9QldqHgIbeIbeLs1Hodq)bO2cJ0bOqPbanGbLe6aU243qDDauriCDaDdf6aSAagAWc11bOqnDaDdgBa21fZ1bSwN9BKObeTbS4f1(fgD4dOhOMoaukkydWQbqfHW1b0nuOdqMdqOwcsHld43by1aOIq46auOMoafknGdHI3AdOBWydq8FnaswxXsd4l(aVL04lbh9f(R)zrbRFjW9rzHsRPKljxtmYR2cJuHKBUenjlEfj)13Lw(HArk0ELGHmg4TKgFj4OVWF9plky9lbUWywkmM3oyTkrUenjlEfj)13Lw(HArkuiGHmLlUigZR2cJubhgZsHX82bRvjQxjyip9p78Dl(vWy26)MVTVq5lHWIs0Rmg4TKgFj4OVWF9plky9lbUT9fQxOBaj5sY1eJ8QTWivi5MlrtYIxrYF9DPLFOwKcfcyit5P)zNVBXVcgZw)38T9fkFjewuIELXaVL04lbh9f(R)zrbRFjWfgZsHX82bRvjYLOjj9p78Dl(vWy26)MVTVq5lHWIs07IxexdeKxFpCkFXRi5V(U0YpulsHcb4uMYfxeJ5vBHrQGdJzPWyE7G1Qe1Remg4TKgFj4OVWF9plky9lbUT9fQxOBaj5sY1eJ8QTWivi5Mlrts6F257w8RGXS1)nFBFHYxcHfLO3fViUgiiV(E4u(IxrYF9DPLFOwKcfcWPmh4h4XmdaIlzk0b8Tb4e1znyVWgGSpPbwAaU9xnn(AG3sA8LGJ(cVgjiJcMKhLfkTMsUKCnXiVAlmsfsU5s0KS4vK8xFxAHGeKGtz0VAmQu(IxrYBQsfUPXxULmqEG3sA8LGJ(cVgjiJcw)sG7si(vqmsi8DJsP1LOjbRTHHYi(21JI3AcPsTKgyjpveIGe9kbdPsx8ks(RVlTqOdyiFXlIRbcYRVhdiS4vK8xFxALn368bElPXxco6l8AKGmky9lbUhYuOERo(dLmxDjAsw8ks(RVlTqOdyiFXlIRbcYRVhdiS4vK8xFxALn368bElPXxco6l8AKGmky9lbUq)USOG5rzMqDjAsWAByOmIVV2s(nqqYrAXRi5V(U02Re4ugsLU4fX1ab5133biibw6iv6Ixu7xyeFnyK)BEfk5B73zu5tqnexXxsLkUigZR2cJubh63LffmpkZeAVsWqQuu8wJVbcIVeclkbe6aYsLU4vK8xFxAHqhWq(IxexdeKxFpgqyXRi5V(U0kBU15d8wsJVeC0x41ibzuW6xcCB7lurYvfk5s0KGI3ACidglkyEewcAueh)sU4IymVAlmsf82(cvKCvHs9IH8(WAByOmIFitHk8hCYBjnWsd8wsJVeC0x41ibzuW6xcCFuwO0Ak5sY1eJ8QTWivi5MlrtckERXHmySOG5ryjOrr8LSKoWBjn(sWrFHxJeKrbRFjWf6VL)B(UrP06s0KS4vK8xFxAHGKoxMYx8I4AGG8677qVWsNbElPXxco6l8AKGmky9lbUT9fQi5QcLCjAsexeJ5vBHrQG32xOIKRkuQxmK3hwBddLr8dzkuH)GtElPbwAG3sA8LGJ(cVgjiJcw)sG7JYcLwtjxsUMyKxTfgPcj3CjAsw8ks(RVlT8d1IuO9IHmKkDXlIRbcYRVVdqaw6mWBjn(sWrFHxJeKrbRFjWf63LffmpkZeQlrtcwBddLr891wYVbcAG3sA8LGJ(cVgjiJcw)sGRTjRiV(7sL6s0KS4vK8xFxAHGmK5a)a)apMbZma38SZaKTt2QdWnFDcn(smWBjn(sWtp74Hs2QssqTOe(V5Je5s0KG(cH8wadQ6xcHfLacWsh5iT4fbbmKkTpu8wJdzWyrbZJWsqJI44xYrQpewuEOwD4yavokERXtp74Hs2QCHAji7vcC2)Ixu7xyehYNPXAcFZW(RuPiSO8qT6WXaQCu8wJNE2XdLSv5c1sq2RBR)fVO2VWioKptJ1e(MH9xKLkffV14qgmwuW8iSe0Oio(LCK6dHfLhQvhogqLJI3A80ZoEOKTkxOwcYEDB9V4f1(fgXH8zASMW3mS)kvkclkpuRoCmGkhfV14PND8qjBvUqTeK9EtM9V4f1(fgXH8zASMW3mS)ImYd8yMbahfbnGd(gfSbGzhmMTdOBOqhGSlrj7cUqCjtHoWBjn(sWtp74Hs2Q9lbUjOwuc)38rICjAs6tngvk)rzHsRPXxYrXBn(vWy26)MVTVq54xYrXBnE6zhpuYwLlulbzVsUjt5iHI3A8RGXS1)nFBFHYxcHfLacWsh3cPB9N(ND(UfVTVq766Iq4B4RR8LSJRilvkkERXXlOpZvVqxQGPq5lHWIsabyPJuPO4Tgpb1EHh1kIVeclkbeGLoipWJzgaMfUkIdnGVnam7GXSDa4cYGrdOBOqhGSlrj7cUqCjtHoWBjn(sWtp74Hs2Q9lbUjOwuc)38rICjAs6tngvk)rzHsRPXxYpKPq9qwbmOkFXlQ9lmI3mgJkFAXf2Hw59HI3A8RGXS1)nFBFHYXVKN(ND(Uf)kymB9FZ32xO8Lqyrj69MmKJekERXtp74Hs2QCHAji7vYnzkhju8wJJxqFMREHUubtHYXVKkffV14jO2l8OwrC8lKLkffV14PND8qjBvUqTeK9k5whqEG3sA8LGNE2XdLSv7xcCtqTOe(V5Je5s0K0NAmQu(JYcLwtJVK33HmfQhYkGbv5lErTFHr8MXyu5tlUWo0khfV14PND8qjBvUqTeK9k5MmL3hkERXVcgZw)38T9fkh)sE6F257w8RGXS1)nFBFHYxcHfLOxmK5apMzay2lHLkDaU5zNbiBNSvhWJL2KDDffSbCW3OGnGRGXSDG3sA8LGNE2XdLSv7xcCtqTOe(V5Je5s0KOgJkL)OSqP104l59HI3A8RGXS1)nFBFHYXVKJekERXtp74Hs2QCHAji7vYn4uosO4TghVG(mx9cDPcMcLJFjvkkERXtqTx4rTI44xilvkkERXtp74Hs2QCHAji7vYn4aPst)ZoF3IFfmMT(V5B7lu(siSOeqOdYrXBnE6zhpuYwLlulbzVsUbNipWpWJzgaM9RXxd8wsJVe80)SZ3TesUEn(YLOjbfV14xbJzR)B(2(cLJFnWJzgGB(ND(ULyG3sA8LGN(ND(ULOFjWLqC9DP1V4f57s21xUenjQXOs5pkluAnn(s(Ixee6C5iH12WqzexO(lMvvuWKkfRTHHYiUDoc)siSOqwosP)zNVBXVcgZw)38T9fkFjewuciid5iL(ND(UfVXib00AnLVeclkrVYqU4XzOrD4x4cfNrEAXV04lPs7t84m0Oo8lCHIZipT4xA8fYsLII3A8RGXS1)nFBFHYXVqwQu0xiK3cyqv)siSOeqadzoWBjn(sWt)ZoF3s0Ve4siU(U06x8I8Dj76lxIMe1yuPC0LmfQ)BEruN1G9ct(IxeeKH8fVIK)67sleqQZLjM)HmfQhYkGbv5lErTFHrCOUkuAdZTKbM)Ixu7xyeFnexwPEDTs0OLQe5wYaz5iHI3AC0LmfQ)BEruN1G9cJJFjvAlGbv9lHWIsabmKjYd8wsJVe80)SZ3Te9lbUeIRVlT(fViFxYU(YLOjrngvkpsuYUg4TKgFj4P)zNVBj6xcCVcgZw)38T9fQlrtIAmQuo6sMc1)nViQZAWEHjhjS2ggkJ4c1FXSQIcMuPyTnmugXTZr4xcHffYYrk9p78Dlo6sMc1)nViQZAWEHXxcHfLqQ00)SZ3T4Olzku)38IOoRb7fgFj74Q8fVIK)67sBVYqMipWBjn(sWt)ZoF3s0Ve4EfmMT(V5B7luxIMe1yuP8irj7sEFO4Tg)kymB9FZ32xOC8RbElPXxcE6F257wI(La3RGXS1)nFBFH6s0KOgJkL)OSqP104l5iT4vK8xFxA7vshKH8(qXBnUH(iIY04lplqGYXVKkffV14g6JiktJV8Sabkh)cz5iH12WqzexO(lMvvuWKkfRTHHYiUDoc)siSOqwosQXOs5WmfkTrbZl0FrWPYqz0rokERXxcXVcIrcHVBukTC8lPs7tngvkhMPqPnkyEH(lcovgkJoipWBjn(sWt)ZoF3s0Ve4IUKPq9FZlI6SgSxyUenjO4Tg)kymB9FZ32xOC8RbElPXxcE6F257wI(La32(cTRRlcHVHVU6s0KyjnWsEQiebjKCtokERXVcgZw)38T9fkFjewucialDKJI3A8RGXS1)nFBFHYXVK3NAmQu(JYcLwtJVKJuFRfhpHLkLBNJGtYkeQqQ01IJNWsLYTZrWJQ3oitKLkTfWGQ(LqyrjGqhg4TKgFj4P)zNVBj6xcCB7l0UUUie(g(6QlrtIL0al5PIqeKOxjyihju8wJFfmMT(V5B7luo(LuPRfhpHLkLBNJGtYkeQq(AXXtyPs525i4r1B6F257w8RGXS1)nFBFHYxcHfLOF4qKLJekERXVcgZw)38T9fkFjewucialDKkDT44jSuPC7CeCswHqfYxloEclvk3ohbFjewucialDqEG3sA8LGN(ND(ULOFjWTTVq766Iq4B4RRUenjQXOs5pkluAnn(sosO4Tg)kymB9FZ32xOC8l59HWIYd1QdhdOsL2hkERXVcgZw)38T9fkh)soclkpuRoCmGkp9p78Dl(vWy26)MVTVq5lHWIsGSCKqcfV14xbJzR)B(2(cLVeclkbeGLosLII3AC8c6ZC1l0Lkykuo(LCu8wJJxqFMREHUubtHYxcHfLacWshKLJ0HqXBn(AD2VrI4c1sqkrgsL23HmfQhYkGbv5lErTFHr816SFJeHmYd8wsJVe80)SZ3Te9lbUqD96vO0Iis(RLeuLixIMe1yuPC0LmfQ)BEruN1G9ct(IxrYF9DPfcDUmLV4fbbjDqosO4TghDjtH6)Mxe1znyVW44xsLM(ND(UfhDjtH6)Mxe1znyVW4lHWIs0lCktKLkTp1yuPC0LmfQ)BEruN1G9ct(IxrYF9DPfcsGdLXaVL04lbp9p78Dlr)sG7AHG8hYoUenjP)zNVBXVcgZw)38T9fkFjewuciirgd8wsJVe80)SZ3Te9lbUclTrlsHX8xwsDjAsSKgyjpveIGe9kbd5i1cyqv)siSOeqOdsL2hkERXrxYuO(V5frDwd2lmo(LCKUiLdd6JZ4lHWIsabyPJuPRfhpHLkLBNJGtYkeQq(AXXtyPs525i4lHWIsaHoiFT44jSuPC7Ce8O69IuomOpoJVeclkbYipWBjn(sWt)ZoF3s0Ve4EitH6T64puYC1LOjXsAGL8urics0RmKkDXlQ9lmIFbLS9r8fjg4h4XmdWnpwQSshGShnyHgKyG3sA8LGNESuzLkKCitHk8hCYLOjbP(uJrLYFuwO0AA8LuPQXOs5pkluAnn(sUL0al5PIqeKOxjyip9p78Dl(vWy26)MVTVq5lHWIsivQL0al5PIqeKqYnKLJewBddLrCH6VywvrbtQuS2ggkJ425i8lHWIc5bElPXxcE6XsLvQOFjWv01werbZJieQlrtYIxrYF9DPLFOwKcT3BDqE6F257w8RGXS1)nFBFHYxcHfLacDqEFQXOs5Olzku)38IOoRb7fMCS2ggkJ4c1FXSQIc2aVL04lbp9yPYkv0Ve4k6AlIOG5rec1LOjPp1yuPC0LmfQ)BEruN1G9ctowBddLrC7Ce(LqyrnWBjn(sWtpwQSsf9lbUIU2IikyEeHqDjAsuJrLYrxYuO(V5frDwd2lm5iHI3AC0LmfQ)BEruN1G9cJJFjhjS2ggkJ4c1FXSQIcM8fVIK)67sl)qTifAVWPmLkfRTHHYiUDoc)siSOKV4vK8xFxA5hQfPq7TZLPuPyTnmugXTZr4xcHfL81IJNWsLYTZrWxcHfLacWbYxloEclvk3ohbNKviubYsL2hkERXrxYuO(V5frDwd2lmo(L80)SZ3T4Olzku)38IOoRb7fgFjewucKh4TKgFj4PhlvwPI(Laxd9reLPXxEwGa1LOjj9p78Dl(vWy26)MVTVq5lHWIsaHoihRTHHYiUq9xmRQOGjhj1yuPC0LmfQ)BEruN1G9ct(IxrYF9DPTxzit5P)zNVBXrxYuO(V5frDwd2lm(siSOeqadPs7tngvkhDjtH6)Mxe1znyVWqEG3sA8LGNESuzLk6xcCn0hruMgF5zbcuxIMeS2ggkJ425i8lHWIAG3sA8LGNESuzLk6xcCfqTeKmYRqjpE19xfQRUenjyTnmugXfQ)Izvffm5iL(ND(Uf)kymB9FZ32xO8LqyrjGqhKkvngvkpsuYUqEG3sA8LGNESuzLk6xcCfqTeKmYRqjpE19xfQRUenjyTnmugXTZr4xcHf1aVL04lbp9yPYkv0Ve42yKaAATM6s0K0hkERXVcgZw)38T9fkh)sosIhNHg1HFHluCg5Pf)sJVKkv84m0OoCSpZ0GrEXZWsLkVpu8wJJ9zMgmYlEgwQuo(fYUeLs7IFP(abc6eMssU5sukTl(L6HXEuJj5MlrP0U4xQpAsepodnQdh7ZmnyKx8mSuPd8d8yMbGzHYcLwtJVgW(QPXxd8wsJVe8hLfkTMgFjzje)kigje(UrP06s0KyjnWsEQiebj6vshKJ12WqzeF76rXBnXaVL04lb)rzHsRPXx9lbUT9fQxOBaj5s0K0hkERXHmySOG5ryjOrrC8l5iT4fbbmKkvngvkpsU6vJ9LqokERXJKRE1yFj4lHWIsabyPJBHHuPPVo4HYXlgzcO0X3wQ6mxLJekERXXlgzcO0X3wQ6mx5lHWIsabyPJBHHuPO4TghVyKjGshFBPQZCLlulbje6aYipWBjn(sWFuwO0AA8v)sGl0VllkyEuMjuxIMK(qXBnoKbJffmpclbnkIJFjFXlQxjDqosO4TgFdeeFjewuci0b5O4TgFdeeh)sQulPbwYFEL32xO(gHLwiyjnWsEQiebjqEG3sA8LG)OSqP104R(LaxymlfgZBhSwLixIMK(qXBnoKbJffmpclbnkIJFjxCrmMxTfgPcomMLcJ5TdwRsuVsWqQ0(qXBnoKbJffmpclbnkIJFjhPdHI3A816SFJeXfQLGecYqQ0dHI3A816SFJeXxcHfLacWsh3corEG3sA8LG)OSqP104R(La32(cvKCvHsUenjO4TghYGXIcMhHLGgfXxYsQCXfXyE1wyKk4T9fQi5QcL6fd59H12Wqze)qMcv4p4K3sAGLg4TKgFj4pkluAnn(QFjW9rzHsRPKljxtmYR2cJuHKBUenjO4TghYGXIcMhHLGgfXxYs6aVL04lb)rzHsRPXx9lbUT9fQxOBaj5s0KyjnWsEQiebjKCtowBddLr82(c1l0nGK8PVo4Hkg4TKgFj4pkluAnn(QFjWf63LffmpkZeQlrtcwBddLr891wYVbcsU4IymVAlmsfCOFxwuW8OmtO9kbJbElPXxc(JYcLwtJV6xcCHXSuymVDWAvICjAsexeJ5vBHrQGdJzPWyE7G1Qe1Remg4TKgFj4pkluAnn(QFjWTTVq9cDdijxsUMyKxTfgPcj3CjAs6tngvk3WAmRsqj59HI3ACidglkyEewcAueh)sQu1yuPCdRXSkbLK3hwBddLr891wYVbcsQuS2ggkJ47RTKFdeK8fViUgiiV(Em6vcS0zG3sA8LG)OSqP104R(LaxOFxwuW8OmtOUenjyTnmugX3xBj)giObElPXxc(JYcLwtJV6xcCFuwO0Ak5sY1eJ8QTWivi52a)apMzay2)ZIc2aGJ)DaywOSqP104Rooah1wvmGBYCack91rmauQ9lnam7GXSDaFBaWX7l0bKEeKyaFRna3iBBG3sA8LG)OSqP104l)1)SOGjzje)kigje(UrP06s0KG12WqzeF76rXBnHuPwsdSKNkcrqIELGXaVL04lb)rzHsRPXx(R)zrbRFjWfgZsHX82bRvjYLOjrCrmMxTfgPcomMLcJ5TdwRsuVsWqUAmQuEBFHksUQqPbElPXxc(JYcLwtJV8x)ZIcw)sGBBFHksUQqjxIMeu8wJdzWyrbZJWsqJI4lzjvUL0al5PIqeKOxmK3hwBddLr8dzkuH)GtElPbwAG3sA8LG)OSqP104l)1)SOG1Ve4(OSqP1uYLKRjg5vBHrQqYnxIMeu8wJdzWyrbZJWsqJI4lzjDG3sA8LG)OSqP104l)1)SOG1Ve422xOEHUbKKlrtIL0al5PIqeKqYn5yTnmugXB7luVq3asYN(6GhQyG3sA8LG)OSqP104l)1)SOG1Ve4(OSqP1uYLKRjg5vBHrQqYnxIMeu8wJdzWyrbZJWsqJI4lzjDG3sA8LG)OSqP104l)1)SOG1Ve4c97YIcMhLzc1LOjbRTHHYi((Al53abnWBjn(sWFuwO0AA8L)6FwuW6xcCHXSuymVDWAvICjAsexeJ5vBHrQGdJzPWyE7G1Qe1RemKV4vK8xFxA5hQfPqHqNlZbElPXxc(JYcLwtJV8x)ZIcw)sGBBFH6f6gqsUKCnXiVAlmsfsU5s0KS4vK8xFxA5hQfPqHaCOmh4TKgFj4pkluAnn(YF9plky9lbUpkluAnLCj5AIrE1wyKkKCZLOjzXlQxjDqos9HWIYd1QdhdOsLMESuzLYlkTp73JuPPhlvwPCiDDdRqwQ0fVOELaNYryr5HA1HJb0bElPXxc(JYcLwtJV8x)ZIcw)sGBBFHksUQqjxIMelPbwYtfHiirVsGt59H12Wqze)qMcv4p4K3sAGLg4h4XmdWTBPWydq2JgSqdsmWBjn(sWxlfgtibL9)X3WxxDjAsqXBn(vWy26)MVTVq54xd8wsJVe81sHXe9lbUO0kOfYOG5s0KGI3A8RGXS1)nFBFHYXVg4TKgFj4RLcJj6xcCTnzf5VWzcYLOjbP(qXBn(vWy26)MVTVq54xYTKgyjpveIGe9kbdKLkTpu8wJFfmMT(V5B7luo(LCKw8I4hQfPq7vImKV4vK8xFxA5hQfPq7vsNltKh4TKgFj4RLcJj6xcCzbmOQWdhv8dmeuPUenjO4Tg)kymB9FZ32xOC8RbElPXxc(APWyI(LaxRsKqxJ5tgJ5s0KGI3A8RGXS1)nFBFHYXVKJI3ACcX13Lw)IxKVlzxFXXVg4TKgFj4RLcJj6xcCBXsOS)pUenjO4Tg)kymB9FZ32xO8LqyrjGGe3MCu8wJFfmMT(V5B7luo(LCu8wJtiU(U06x8I8Dj76lo(1aVL04lbFTuymr)sGlQbZ)nVUrcsHlrtckERXVcgZw)38T9fkh)sUL0al5PIqeKqYn5iHI3A8RGXS1)nFBFHYxcHfLacYqUAmQuE6zhpuYwLtLHYOJuP9PgJkLNE2XdLSv5uzOm6ihfV14xbJzR)B(2(cLVeclkbe6aYd8d8yMb4OwDS9maruWyeMVAlmshW(QPXxd8wsJVeCHA1X2JKLq8RGyKq47gLsRlrtcwBddLr8TRhfV1ed8wsJVeCHA1X2t)sG7JYcLwtjxIMeu8wJdzWyrbZJWsqJI4lzjDG3sA8LGluRo2E6xcCH(DzrbZJYmH6s0KG12WqzeFFTL8BGGKJI3A8nqq8LqyrjGqhg4TKgFj4c1QJTN(La32(c1l0nGKCjAsWAByOmI32xOEHUbKKp91bpuXaVL04lbxOwDS90Ve4cJzPWyE7G1Qe5s0K03HmfQhYkGbv5lErTFHr816SFJejhPdHI3A816SFJeXfQLGecYqQ0dHI3A816SFJeXxcHfLacWsh3corEG3sA8LGluRo2E6xcCB7luVq3asYLOjj9p78Dl(si(vqmsi8DJsPLVeclkbeKGHBblDKRgJkLdZuO0gfmVq)fXaVL04lbxOwDS90Ve4c97YIcMhLzc1LOjbRTHHYi((Al53abnWBjn(sWfQvhBp9lbUT9fQxOBaj5s0KS4vK8xFxA5hQfPqHas3Kr)QXOs5lEfjVPkv4MgF5wYa5bElPXxcUqT6y7PFjW9rzHsRPKlrtsFO4TgVTFNrL)cNjio(LC1yuP82(Dgv(lCMGKkfRTHHYi(HmfQWFWjVL0aljhfV14hYuOc)bN4c1sqcb4uQu1yuPCyMcL2OG5f6ViKJI3A8Lq8RGyKq47gLslh)sQ0fVIK)67sl)qTifAViHHm6xngvkFXRi5nvPc304l3sgipWBjn(sWfQvhBp9lbUT9fQxOBajnWBjn(sWfQvhBp9lbUq)T8FZ3nkL2bElPXxcUqT6y7PFjW12KvKx)DPsh4h4XmdONnkijvmWBjn(sW1nkijvibxq(qjeUugcssuI0IRgkJ8yoCRuCe(dHnsKlrtsFQXOs5Olzku)38IOoRb7fMCu8wJFfmMT(V5B7luo(LCu8wJtiU(U06x8I8Dj76lo(LuPQXOs5Olzku)38IOoRb7fMCKqcfV14xbJzR)B(2(cLJFjp9p78Dlo6sMc1)nViQZAWEHXxYoUISuPiHI3A8RGXS1)nFBFHYXVKJesTagu1VeclkbMF6F257wC0LmfQ)BEruN1G9cJVeclkbYqaJBiJmYsLI(cH8wadQ6xcHfLacyCtQ0dzkupKvadQYpHWqzKpWChpjlkHRKezkxTfgPCnqqE99xj1JHmHGmg4TKgFj46gfKKk6xcCXfKpucHlLHGKOqjFlwH6fbSG5s0KGI3A8RGXS1)nFBFHYXVKJI3ACcX13Lw)IxKVlzxFXXVg4XmdOhO0a0nkijDaDdf6auO0aGgWGscDaKqdeMsNbG1y4KldOBWydaLgaUGodOfRqhGvNbCzXsNb0nuOdaZoymBhW3gaC8(cLpWBjn(sW1nkijv0Ve4QBuqs6nxIMK(WAByOmIlUOu0c641nkijvokERXVcgZw)38T9fkh)sos9PgJkLhjkzxsLQgJkLhjkzxYrXBn(vWy26)MVTVq5lHWIs0RKBYez5i1NUrbjPCm4qnHp9p78DlPs1nkijLJbp9p78Dl(siSOesLI12Wqzex3OGKu)1g)gQRsUHSuP6gfKKYVXrXBn)bFnn(QxjTagu1VeclkXaVL04lbx3OGKur)sGRUrbjPy4s0K0hwBddLrCXfLIwqhVUrbjPYrXBn(vWy26)MVTVq54xYrQp1yuP8irj7sQu1yuP8irj7sokERXVcgZw)38T9fkFjewuIELCtMilhP(0nkijLFJd1e(0)SZ3TKkv3OGKu(nE6F257w8LqyrjKkfRTHHYiUUrbjP(Rn(nuxLGbYsLQBuqskhdokER5p4RPXx9kPfWGQ(Lqyrjg4Xmdq21gWxmxhWx0a(Aa4cAa6gfKKoGR9XghsmaBaO4TMldaxqdqHsd4vO0oGVgq6F257w8bGzTdiAdOOqHs7a0nkijDax7JnoKya2aqXBnxgaUGga6RqhWxdi9p78Dl(aVL04lbx3OGKur)sGlUG8HsiCrWEvIUrbjP3CjAs6dRTHHYiU4IsrlOJx3OGKu5i1NUrbjP8BCOMWJlipkERjhjDJcss5yWt)ZoF3IVeclkHuP9PBuqskhdout4XfKhfV1qwQ00)SZ3T4xbJzR)B(2(cLVeclkrVyitKh4TKgFj46gfKKk6xcCXfKpucHlc2Rs0nkijfdxIMK(WAByOmIlUOu0c641nkijvos9PBuqskhdout4XfKhfV1KJKUrbjP8B80)SZ3T4lHWIsivAF6gfKKYVXHAcpUG8O4TgYsLM(ND(Uf)kymB9FZ32xO8Lqyrj6fdzICwZAod]] )


end
