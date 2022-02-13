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


    spec:RegisterPack( "Frost DK", 20220212, [[d40RbdqiaLhjPuUKKIytujFsLQrHICkuuRcirVssLzHs1TqPqSlc)cq1WqP0XuPSmiQNrLktdiPRbrABOuKVjPuzCaj4CurQwNKcZdi19qj7ts0bPIKwOKQEivQAIurcUikfyJskv9rQirJKksOtIsrTsG4LOui1mLuYoPI6Naj0qrPGwkvKYtjYuLeUkkfs6ROuOgleXEf5VIAWGomLfdPhtvtwfxgzZs8zagnqDAHvJsHeVgqMnu3gc7wQFRQHRsoUKI0Yv65OA6KUorTDu47ssJNkIZtLY6LuuZNkSFfNULQijDmLsoJmBrgz2I8nKf3C6i9gsb1KK62fLKUmpqgakj1gckjv73NRd0PaB0jPlZn8BNufjj(lVEkjbw1lEnaoWbekyzuH)raCEGqgBA8TFTIcCEGWd8KeQCGv2CNqtshtPKZiZwKrMTiFdzXnNosVbQ1UKKjRG)njjfiCFscCCouNqtshI7tsofitbpq2O7aayDG1(956asTNqxzBDBG3qM9bImBrg5bKbe3d2AaeFaHnYaDAeINbDgi24kBeo5)(mqzUbGg4xgO7bBrZh4xgiB2td04dm0bEEI331bEHn3gyvcJhy0d8AnVgEsmGWgzGof((UoqpyRBcpWApM4G9Rv0bEK3ObmW6xYuWd8lduk6ZAaEUjss4GR8ufjPhfhkTMgFNV(hhnGufjNVLQijrTHIPtQ(KK5147K0si(LtyIZZvJwPnjDiUFJln(ojXg(poAadS2)7abfrXHsRPX31yGsQTkFG3y7a5K)7dFGOu5xAGSHbgB7a)YaR97Z1b6FeeFGFPmq37uij53qPnSKedBddftITAgvUu4d0HJbAEnyqzQjebXhyLSgiYjn5mYPkssuBOy6KQpj53qPnSKe)IW4SAlas5cayZhgoBhgw7PbwjRbI8aDnq1WuRIY(CL7DtbtcQnumDssMxJVtsaWMpmC2omS2tjn5S7svKKO2qX0jvFsYVHsByjju5srauGXrdiJW8GJMelzEDGUgO51GbLPMqeeFGvoqKhORbcSbYW2WqXK4qMcMNpYu28AWGssMxJVtsL95k37McMsAYzqnvrsIAdftNu9jjZRX3jPhfhkTMsjj)gkTHLKqLlfbqbghnGmcZdoAsSK51KK3npMYQTaiLNC(wstoJ0ufjjQnumDs1NK8BO0gwsY8AWGYuticIpqwd82aDnqg2ggkMeL95AMRBaeL9FFKdLNKmVgFNKk7Z1mx3aikPjNztPkssuBOy6KQpjzEn(oj9O4qP1ukj53qPnSKeQCPiakW4ObKryEWrtILmVMK8U5XuwTfaP8KZ3sAY5AxQIKe1gkMoP6ts(nuAdljXW2WqXKyFT4ZBGGssMxJVtsG)Q4ObKrXgxtAYzqHufjjQnumDs1NK8BO0gwsIFryCwTfaPCbaS5ddNTddR90aRK1arEGUg4k3HpF9vPvCOs4dDGGEGSj2MKmVgFNKaGnFy4SDyyTNsAYzNEQIKe1gkMoP6tsMxJVtsL95AMRBaeLK8BO0gwsAL7WNV(Q0kouj8HoqqpWAhBtsE38ykR2cGuEY5Bjn58n2MQijrTHIPtQ(KK5147K0JIdLwtPKKFdL2WssRCtdSswd0DjjVBEmLvBbqkp58TKMC(2TufjjQnumDs1NK8BO0gwsY8AWGYuticIpWkznqqDGUgiWgidBddftIdzkyE(itzZRbdkjzEn(ojv2NRCVBkykPjnj5F8jdMSvtvKC(wQIKe1gkMoP6tsMxJVtsEWw088xYHNsshI734sJVtsSrLtd8iVrdyGSHbgB7aRgk4bYM9K3UaE9lzk4KKFdL2WssaBGQHPwfpkouAnn(wqTHIPZaDnqu5srCfyST5VKl7ZvH81aDnqu5sr4F8jdMSvfC18anWkznWBSDGUgitdevUuexbgBB(l5Y(CvSeclA(ab9ab4pdeuoqMg4Tbw3a9)JpF1wu2NRvDBrWZf51nXs2XTbY8aD4yGOYLIqUb)y3YCDPgGcwSeclA(ab9ab4pd0HJbIkxkcpy75zuRjXsiSO5de0deG)mqMtAYzKtvKKO2qX0jvFsY8A8DsYd2IMN)so8us6qC)gxA8Dscuuw5XHg4xgiByGX2oqzozaObwnuWdKn7jVDb86xYuWjj)gkTHLKa2avdtTkEuCO0AA8TGAdftNb6AGhYuWzG6aayvSYnv(fajkggtD2VYC7q7aDnqGnqu5srCfyST5VKl7ZvH81aDnq))4ZxTfxbgBB(l5Y(CvSeclA(aRCG3q6aDnqMgiQCPi8p(Kbt2QcUAEGgyLSg4n2oqxdKPbIkxkc5g8JDlZ1LAakyH81aD4yGOYLIWd2EEg1AsiFnqMhOdhdevUue(hFYGjBvbxnpqdSswd8M7giZjn5S7svKKO2qX0jvFsYVHsByjjGnq1WuRIhfhkTMgFlO2qX0zGUgiWg4HmfCgOoaawfRCtLFbqIIHXuN9Rm3o0oqxdevUue(hFYGjBvbxnpqdSswd8gBhORbcSbIkxkIRaJTn)LCzFUkKVgORb6)hF(QT4kWyBZFjx2NRILqyrZhyLdez2MKmVgFNK8GTO55VKdpL0KZGAQIKe1gkMoP6tsMxJVtsEWw088xYHNsshI734sJVtsSHlXGADGU)XNb6uKSvh4ZGwVDDfnGbEK3ObmWRaJTnj53qPnSKKAyQvXJIdLwtJVfuBOy6mqxdeydevUuexbgBB(l5Y(CviFnqxdKPbIkxkc)JpzWKTQGRMhObwjRbEduhORbY0arLlfHCd(XUL56snafSq(AGoCmqu5sr4bBppJAnjKVgiZd0HJbIkxkc)JpzWKTQGRMhObwjRbEZPpqhogO)F85R2IRaJTn)LCzFUkwcHfnFGGEGUBGUgiQCPi8p(Kbt2QcUAEGgyLSg4nqDGmN0KMKEuCO0AA8DQIKZ3svKKO2qX0jvFsY8A8DsAje)YjmX55QrR0MKoe3VXLgFNKafrXHsRPX3dCF1047KKFdL2WssMxdguMAcrq8bwjRb6Ub6AGmSnmumj2Qzu5sHN0KZiNQijrTHIPtQ(KKFdL2WssaBGOYLIaOaJJgqgH5bhnjKVgORbUYnnWkznq3nqxdKPbIkxkInqqILqyrZhiOhO7gORbIkxkInqqc5Rb6WXanVgmO85vrzFUMledAhiOhO51GbLPMqeeFGmNKmVgFNKa)vXrdiJInUM0KZUlvrsIAdftNu9jj)gkTHLKa2arLlfbqbghnGmcZdoAsiFnqxdKFryCwTfaPCbaS5ddNTddR90aRK1arEGoCmqGnqu5srauGXrdiJW8GJMeYxd01azAGhcvUueRvZ)gEsWvZd0ab9ar6aD4yGhcvUueRvZ)gEsSeclA(ab9ab4pdeuoqqDGmNKmVgFNKaGnFy4SDyyTNsAYzqnvrsIAdftNu9jj)gkTHLKqLlfbqbghnGmcZdoAsSK51b6AG8lcJZQTaiLlk7ZvU3nfmnWkhiYd01ab2azyByOysCitbZZhzkBEnyqjjZRX3jPY(CL7Dtbtjn5mstvKKO2qX0jvFsY8A8Ds6rXHsRPusYVHsByjju5srauGXrdiJW8GJMelzEnj5DZJPSAlas5jNVL0KZSPufjjQnumDs1NK8BO0gwsY8AWGYuticIpqwd82aDnqg2ggkMeL95AMRBaeL9FFKdLNKmVgFNKk7Z1mx3aikPjNRDPkssuBOy6KQpj53qPnSKedBddftI91IpVbcAGUgi)IW4SAlas5cWFvC0aYOyJRdSswde5KK5147Ke4VkoAazuSX1KMCguivrsIAdftNu9jj)gkTHLK4xegNvBbqkxaaB(WWz7WWApnWkznqKtsMxJVtsaWMpmC2omS2tjn5StpvrsIAdftNu9jjZRX3jPY(CnZ1naIss(nuAdljbSbQgMAvymmS1EWKGAdftNb6AGaBGOYLIaOaJJgqgH5bhnjKVgOdhdunm1QWyyyR9Gjb1gkMod01ab2azyByOysSVw85nqqd0HJbYW2WqXKyFT4ZBGGgORbUYnj0abL1pJ8aRK1ab4pjjVBEmLvBbqkp58TKMC(gBtvKKO2qX0jvFsYVHsByjjg2ggkMe7RfFEdeusY8A8Dsc8xfhnGmk24AstoF7wQIKe1gkMoP6tsMxJVtspkouAnLssE38ykR2cGuEY5BjnPjj0NN1Wdu0asvKC(wQIKe1gkMoP6tsMxJVtspkouAnLssE38ykR2cGuEY5Bjj)gkTHLKw5o85RVkTIdvcFOdSswdKPbcQiDG1nq1WuRIvUdF2uLAztJVfuBOy6mqq5ar6azojDiUFJln(ojv)sMcEGFzGsrFwdWZTb6u9AWGgOt7vtJVtAYzKtvKKO2qX0jvFsYVHsByjjg2ggkMeB1mQCPWhOdhd08AWGYuticIpWkznqKhOdhdCL7WNV(Q0oqqpq3HCsY8A8DsAje)YjmX55QrR0M0KZUlvrsIAdftNu9jj)gkTHLKw5o85RVkTde0d0DiNKmVgFNKoKPGZwFYhYBUL0KZGAQIKe1gkMoP6ts(nuAdljXW2WqXKyFT4ZBGGgORbY0ax5o85RVkTIdvcFOde0dePiDGoCmWvUjHgiOS(z3nqqZAGa8Nb6WXax5Mk)cGeRbGYFjRGPCz)AM6ShSH4k(wqTHIPZaD4yG8lcJZQTaiLla)vXrdiJInUoWkznqKhOdhdevUueBGGelHWIMpqqpq3nqMhOdhdCL7WNV(Q0oqqpq3HCsY8A8Dsc8xfhnGmk24AstoJ0ufjjQnumDs1NK8BO0gwscvUueafyC0aYimp4OjH81aDnq(fHXz1waKYfL95k37McMgyLde5b6AGaBGmSnmumjoKPG55JmLnVgmOKK5147KuzFUY9UPGPKMCMnLQijrTHIPtQ(KK5147K0JIdLwtPKKFdL2WssOYLIaOaJJgqgH5bhnjwY8AsY7Mhtz1waKYtoFlPjNRDPkssuBOy6KQpj53qPnSK0k3HpF9vPvCOs4dDGvYAGGkBhORbUYnj0abL1p7Ubw5ab4pjjZRX3jjW)25VKRgTsBstodkKQijrTHIPtQ(KKFdL2Wss8lcJZQTaiLlk7ZvU3nfmnWkhiYd01ab2azyByOysCitbZZhzkBEnyqjjZRX3jPY(CL7Dtbtjn5StpvrsIAdftNu9jjZRX3jPhfhkTMsjj)gkTHLKw5o85RVkTIdvcFOdSYbImshOdhdCLBsObckRF2Dde0deG)KK8U5XuwTfaP8KZ3sAY5BSnvrsIAdftNu9jj)gkTHLKyyByOysSVw85nqqjjZRX3jjWFvC0aYOyJRjn58TBPkssuBOy6KQpj53qPnSK0k3HpF9vPvCOs4dDGvoqKY2KK5147KKTERPS(7sTM0KMKwZhgMNQi58TufjjQnumDs1NKmVgFNKqX)FYf51TK0H4(nU047KKtZ8HHhOtfnWHgepj53qPnSKeQCPiUcm228xYL95Qq(kPjNrovrsIAdftNu9jj)gkTHLKqLlfXvGX2M)sUSpxfYxjjZRX3jjuA50cu0asAYz3LQijrTHIPtQ(KKFdL2WssmnqGnqu5srCfyST5VKl7ZvH81aDnqZRbdktnHii(aRK1arEGmpqhogiWgiQCPiUcm228xYL95Qq(AGUgitdCLBsCOs4dDGvYAGiDGUg4k3HpF9vPvCOs4dDGvYAGSj2oqMtsMxJVts26TMYxYyoL0KZGAQIKe1gkMoP6ts(nuAdljHkxkIRaJTn)LCzFUkKVssMxJVts4aayLNzJI8bacQ1KMCgPPkssuBOy6KQpj53qPnSKeQCPiUcm228xYL95Qq(AGUgiQCPiiexFvAZRCt5QKD9Tq(kjzEn(ojzTN46A4S3W4KMCMnLQijrTHIPtQ(KKFdL2WssOYLI4kWyBZFjx2NRILqyrZhiOznqqHb6AGOYLI4kWyBZFjx2NRc5Rb6AGOYLIGqC9vPnVYnLRs213c5RKK5147Kujwcf))jPjNRDPkssuBOy6KQpj53qPnSKeQCPiUcm228xYL95Qq(AGUgO51GbLPMqeeFGSg4Tb6AGmnqu5srCfyST5VKl7ZvXsiSO5de0dePd01avdtTk8p(Kbt2QcQnumDgOdhdeydunm1QW)4tgmzRkO2qX0zGUgiQCPiUcm228xYL95Qyjew08bc6b6UbYCsY8A8Dsc1aK)sw3WdepPjnjDOIjJ1ufjNVLQijzEn(ojHi6tUSevZusIAdftNu9jn5mYPkssuBOy6KQpj9xjjoPjjZRX3jjg2ggkMssmmSmLKyAGunvoUUOJiAUFLvdft5AQS1QmI8HyeEAGUgO)F85R2IO5(vwnumLRPYwRYiYhIr4jXs2XTbYCs6qC)gxA8DsInCjguRdKFr(Oe0zG6gnqKYhikfnGbkZPZaRgk4bAY6JW0WpqC0epjXW2CBiOKe)I8rjOtw3ObI0KMC2DPkssuBOy6KQpj9xjjoPjjZRX3jjg2ggkMssmmSmLKmVgmOm1eIG4dK1aVnqxdKPbUwCYedQvHDoCr0dSYbEdPd0HJbcSbUwCYedQvHDoCb5KGR8bYCsIHT52qqjjUMVWw3rdiPjNb1ufjjQnumDs1NK(RKeN0KK5147KedBddftjjggwMssMxdguMAcrq8bwjRbI8aDnqMgiWg4AXjtmOwf25WfKtcUYhOdhdCT4KjguRc7C4cYjbx5d01azAGRfNmXGAvyNdxSeclA(aRCGiDGoCmWsaaSMxcHfnFGvoWBSDGmpqMtsmSn3gckjzNdpVecl6KMCgPPkssuBOy6KQpj9xjjoPjjZRX3jjg2ggkMssmmSmLKqLlfXgiiH81aDnqMgiWg4k3u5xaKynau(lzfmLl7xZuN9GnexX3cQnumDgOdhdCLBQ8lasSgak)LScMYL9RzQZEWgIR4Bb1gkMod01ax5o85RVkTIdvcFOdSYbckmqMtsmSn3gckjTVw85nqqjn5mBkvrsIAdftNu9jP)kjXjnjzEn(ojXW2WqXusIHHLPKK)7JCOcATt4nnAazu8xDGUgiQCPiO1oH30ObKrXFvbxnpqdK1arEGoCmq)3h5qfYnMmoy6Kll11SBcQnumDgORbIkxkc5gtghmDYLL6A2nXsiSO5de0dKPbcWFgiOCGipqMtsmSn3gckjv2NRzUUbqu2)9rouEstox7svKKO2qX0jvFs6VssCstsMxJVtsmSnmumLKyyyzkjDitbNT(KpK3CtOHhOObmqxd0)mO2Av0baWAUyusIHT52qqjPdzkyE(itzZRbdkPjNbfsvKKO2qX0jvFsY8A8DsAje)YjmX55QrR0MKoe3VXLgFNKCQxxy3gyTFFUoWApXGw2hiclA1IEGSzVBdScd)nFGwFgiqeDnqNgH4xoHjoFGSXrR0oW9X4ObKK8BO0gwsY)9roubXG2Y(CDGUgOAyQvbatbtB0aYC9xecQnumDgORbcSbQgMAv8O4qP104Bb1gkMod01a9)JpF1wCfyST5VKl7ZvXsiSO5jn5StpvrsIAdftNu9jjZRX3jjWFvC0aYOyJRjj)gkTHLKa2apVkk7Z1CHyqRyjew08b6AGmnq1WuRIWtE7sqTHIPZaD4yGaBGOYLIaDjtbN)sMh9znap3eYxd01avdtTkqxYuW5VK5rFwdWZnb1gkMod0HJbQgMAv8O4qP104Bb1gkMod01a9)JpF1wCfyST5VKl7ZvXsiSO5d01ab2arLlfbqbghnGmcZdoAsiFnqMtsE38ykR2cGuEY5Bjn58n2MQijrTHIPtQ(KKFdL2WssOYLIi8ULvd)nxSeclA(abnRbcWFgORbQgMAveE3YQH)MlO2qX0zGUgi)IW4SAlas5cayZhgoBhgw7PbwjRbI8aDnqMgOAyQvr4jVDjO2qX0zGoCmq1WuRc0LmfC(lzE0N1a8CtqTHIPZaDnq))4ZxTfOlzk48xY8OpRb45Myjew08bw5aVH0b6WXavdtTkEuCO0AA8TGAdftNb6AGaBGOYLI4kWyBZFjx2NRc5RbYCsY8A8Dsca28HHZ2HH1EkPjNVDlvrsIAdftNu9jj)gkTHLKqLlfr4DlRg(BUyjew08bcAwdeG)mqxdunm1Qi8ULvd)nxqTHIPZaDnqMgOAyQvr4jVDjO2qX0zGoCmq1WuRc0LmfC(lzE0N1a8CtqTHIPZaDnqGnqu5srGUKPGZFjZJ(SgGNBc5Rb6AG()XNVAlqxYuW5VK5rFwdWZnXsiSO5dSYbEJTd0HJbQgMAv8O4qP104Bb1gkMod01ab2arLlfXvGX2M)sUSpxfYxdK5KK5147KuzFUM56garjn58nKtvKKO2qX0jvFs6qC)gxA8DsY9G)Ntd0P6147bIdUoq9h4k3jjZRX3jjVHXzZRX3zCW1Keo4AUneusY)mO2ALN0KZ3CxQIKe1gkMoP6tsMxJVtsEdJZMxJVZ4GRjjCW1CBiOK0A(WW8KMC(gOMQijrTHIPtQ(KK5147KK3W4S5147mo4AschCn3gckjPB0arkpPjNVH0ufjjQnumDs1NKmVgFNK8ggNnVgFNXbxts4GR52qqjj))4ZxT5jn58n2uQIKe1gkMoP6ts(nuAdljPgMAv4F8jdMSvfuBOy6mqxdKPbcSbIkxkcGcmoAazeMhC0Kq(AGoCmq1WuRc0LmfC(lzE0N1a8CtqTHIPZazEGUgitd8qOYLIyTA(3WtcUAEGgiRbI0b6WXab2apKPGZa1baWQyLBQ8lasSwn)B4PbYCsIRB41KZ3ssMxJVtsEdJZMxJVZ4GRjjCW1CBiOKK)XNmyYwnPjNVv7svKKO2qX0jvFsYVHsByjju5srGUKPGZFjZJ(SgGNBc5RKex3WRjNVLKmVgFNKw5oBEn(oJdUMKWbxZTHGssOppRHhOObK0KZ3afsvKKO2qX0jvFsYVHsByjj1WuRc0LmfC(lzE0N1a8CtqTHIPZaDnqMgO)F85R2c0LmfC(lzE0N1a8CtSeclA(ab9aVX2bY8aDnqMg4AXjtmOwf25WfrpWkhiYiDGoCmqGnW1ItMyqTkSZHliNeCLpqhogO)F85R2IRaJTn)LCzFUkwcHfnFGGEG3y7aDnW1ItMyqTkSZHliNeCLpqxdCT4KjguRc7C4IOhiOh4n2oqMtsMxJVtsRCNnVgFNXbxts4GR52qqjj0NNV(hhnGKMC(MtpvrsIAdftNu9jj)gkTHLKqLlfXvGX2M)sUSpxfYxd01avdtTkEuCO0AA8TGAdftNKex3WRjNVLKmVgFNKw5oBEn(oJdUMKWbxZTHGsspkouAnn(oPjNrMTPkssuBOy6KQpj53qPnSKKAyQvXJIdLwtJVfuBOy6mqxd0)p(8vBXvGX2M)sUSpxflHWIMpqqpWBSDGUgitdKHTHHIjbxZxyR7Obmqhog4AXjtmOwf25WfKtcUYhORbUwCYedQvHDoCr0de0d8gBhOdhdeydCT4KjguRc7C4cYjbx5dK5KK5147K0k3zZRX3zCW1Keo4AUneus6rXHsRPX35R)XrdiPjNr(wQIKe1gkMoP6ts(nuAdljzEnyqzQjebXhyLSgiYjjUUHxtoFljzEn(ojTYD28A8DghCnjHdUMBdbLKSNsAYzKrovrsIAdftNu9jjZRX3jjVHXzZRX3zCW1Keo4AUneusIRwFS9K0KMKSNsvKC(wQIKe1gkMoP6tshI734sJVtso1NnyGoTxnn(ojzEn(ojTeIF5eM48C1OvAtAYzKtvKKO2qX0jvFsYVHsByjj1WuRIY(CL7DtbtcQnumDssMxJVtsaWMpmC2omS2tjn5S7svKKO2qX0jvFsYVHsByjju5srauGXrdiJW8GJMelzEDGUgiWgidBddftIdzkyE(itzZRbdkjzEn(ojv2NRCVBkykPjNb1ufjjQnumDs1NK8BO0gwsIHTHHIjX(AXN3abnqxdunm1QWyyyR9Gjb1gkMojjZRX3jjWFvC0aYOyJRjn5mstvKKO2qX0jvFsYVHsByjjGnqu5srSbcsiFnqxd08AWGYuticIpqqZAGUBGoCmqZRbdktnHii(aRCGUljzEn(ojbaB(WWz7WWApL0KZSPufjjQnumDs1NKmVgFNKk7Z1mx3aikj5DZJPSAlas5jNVLK8BO0gwsY)p(8vBXsi(LtyIZZvJwPvSeclA(abnRbI8abLdeG)mqxdunm1QaGPGPnAazU(lcb1gkMojPdX9BCPX3jPA)ViKXw4hODDTV5bpq9hOFjtPbAd8ItYNFGxB8BOUnq1waKoqCW1bw(DG21f2TObmW1Q5FdpnWOhO9ustox7svKKO2qX0jvFsYVHsByjjg2ggkMe7RfFEdeusY8A8Dsc8xfhnGmk24AstodkKQijrTHIPtQ(KKFdL2WssOYLIaGPGPnAazU(lcH81aDnqZRbdktnHii(aRCGipqxdeydKHTHHIjXHmfmpFKPS51GbLKmVgFNKk7ZvU3nfmL0KZo9ufjjQnumDs1NK8BO0gwsIHTHHIjXHmfmpFKPS51GbnqxdevUuehYuW88rMeC18anqqpqqDGoCmqu5sraWuW0gnGmx)fHq(kjzEn(oj9O4qP1ukPjNVX2ufjjQnumDs1NKmVgFNKk7Z1mx3aikj53qPnSK0k3HpF9vPvCOs4dDGGEGmnWBiDG1nq1WuRIvUdF2uLAztJVfuBOy6mqq5ar6azoj5DZJPSAlas5jNVL0KZ3ULQijrTHIPtQ(KKFdL2WssaBGmSnmumjoKPG55JmLnVgmOKK5147KuzFUY9UPGPKMC(gYPkssuBOy6KQpjzEn(oj9O4qP1ukj53qPnSK0k3HpF9vPvCOs4dDGvoqMgiYiDG1nq1WuRIvUdF2uLAztJVfuBOy6mqq5ar6azoj5DZJPSAlas5jNVL0KZ3CxQIKK5147KeaS5ddNTddR9usIAdftNu9jn58nqnvrsY8A8DsQSpx5E3uWusIAdftNu9jn58nKMQijrTHIPtQ(KK5147KuzFUM56garjjVBEmLvBbqkp58TKMC(gBkvrsY8A8Dsc8VD(l5QrR0MKO2qX0jvFstoFR2LQijzEn(ojzR3AkR)UuRjjQnumDs1N0KMK8pdQTw5PksoFlvrsIAdftNu9jjZRX3jPdzkyE(itjPdX9BCPX3jj3)mO2ADGov0ahAq8KKFdL2WssmSnmumj4A(cBDhnGb6WXazyByOysyNdpVecl6KMCg5ufjjQnumDs1NK8BO0gwsAL7WNV(Q0kouj8HoWkh4n3nqxd0)p(8vBXvGX2M)sUSpxflHWIMpqqpq3nqxdeydunm1QaDjtbN)sMh9znap3euBOy6mqxdKHTHHIjbxZxyR7ObKKmVgFNK4vTfr0aYicUM0KZUlvrsIAdftNu9jj)gkTHLKa2avdtTkqxYuW5VK5rFwdWZnb1gkMod01azyByOysyNdpVecl6KK5147KeVQTiIgqgrW1KMCgutvKKO2qX0jvFsYVHsByjj1WuRc0LmfC(lzE0N1a8CtqTHIPZaDnqMgiQCPiqxYuW5VK5rFwdWZnH81aDnqMgidBddftcUMVWw3rdyGUg4k3HpF9vPvCOs4dDGvoqqLTd0HJbYW2WqXKWohEEjew0d01ax5o85RVkTIdvcFOdSYbYMy7aD4yGmSnmumjSZHNxcHf9aDnW1ItMyqTkSZHlwcHfnFGGEGo9b6AGRfNmXGAvyNdxqoj4kFGmpqhogiWgiQCPiqxYuW5VK5rFwdWZnH81aDnq))4ZxTfOlzk48xY8OpRb45Myjew08bYCsY8A8DsIx1werdiJi4AstoJ0ufjjQnumDs1NK8BO0gwsY)p(8vBXvGX2M)sUSpxflHWIMpqqpq3nqxdKHTHHIjbxZxyR7ObmqxdKPbQgMAvGUKPGZFjZJ(SgGNBcQnumDgORbUYD4ZxFvAfhQe(qhiOhiBITd01a9)JpF1wGUKPGZFjZJ(SgGNBILqyrZhiOhiYd0HJbcSbQgMAvGUKPGZFjZJ(SgGNBcQnumDgiZjjZRX3jjd9reTPX3zCGanPjNztPkssuBOy6KQpj53qPnSKedBddftc7C45LqyrNKmVgFNKm0hr0MgFNXbc0KMCU2LQijrTHIPtQ(KKFdL2WssmSnmumj4A(cBDhnGb6AGmnq))4ZxTfxbgBB(l5Y(CvSeclA(ab9aD3aD4yGQHPwfHN82LGAdftNbYCsY8A8DsId28aHPScMYYD1FvWUL0KZGcPkssuBOy6KQpj53qPnSKedBddftc7C45LqyrNKmVgFNK4GnpqykRGPSCx9xfSBjn5StpvrsIAdftNu9jj)gkTHLKa2arLlfXvGX2M)sUSpxfYxd01ab2arLlfb6sMco)Lmp6ZAaEUjKVgORbY0a5Vmgn6J4sMRYyktR8LgFlO2qX0zGoCmq(lJrJ(iy8ytdmL5pMb1QGAdftNbYCskAL2v(sZrjjXFzmA0hbJhBAGPm)XmOwtsrR0UYxAoqGGoHPus6wsY8A8DsQGjoy)AfnjfTs7kFPza4h1WjPBjnPjPRL8pcuttvKC(wQIKe1gkMoP6ts)vsItAuss(nuAdljPB0arQqVjaB8SmNYOYLYaDnqMgiWgOAyQvb6sMco)Lmp6ZAaEUjO2qX0zGUgitdu3ObIuHEt4)hF(QT4iVMgFpWAYa9)JpF1wCfyST5VKl7ZvXrEnn(EGSgiBhiZd0HJbQgMAvGUKPGZFjZJ(SgGNBcQnumDgORbY0a9)JpF1wGUKPGZFjZJ(SgGNBIJ8AA89aRjdu3ObIuHEt4)hF(QT4iVMgFpqwdKTdK5b6WXavdtTkcp5Tlb1gkModK5K0H4(nU047KeBaddlBkXhOnqDJgis5d0)p(8vB2h4jyeh6mqu3g4vGX2oWVmWY(CDG)oq0Lmf8a)Ya5rFwdWZT78b6)hF(QTyGS5Yad9oFGmmSmnqWgFG9pWLqyrFODGlPYBpWBSpqcZPbUKkV9azRaPIKedBZTHGss6gnqKMVL5U1(KK5147KedBddftjjggwMYeMtjj2kqAsIHHLPK0TKMCg5ufjjQnumDs1NK(RKeN0OKKmVgFNKyyByOykjXW2CBiOKKUrdePzKZC3AFsYVHsByjjDJgisfkYcWgplZPmQCPmqxdKPbcSbQgMAvGUKPGZFjZJ(SgGNBcQnumDgORbY0a1nAGivOil8)JpF1wCKxtJVhynzG()XNVAlUcm228xYL95Q4iVMgFpqwdKTdK5b6WXavdtTkqxYuW5VK5rFwdWZnb1gkMod01azAG()XNVAlqxYuW5VK5rFwdWZnXrEnn(EG1KbQB0arQqrw4)hF(QT4iVMgFpqwdKTdK5b6WXavdtTkcp5Tlb1gkModK5KeddltzcZPKeBfinjXWWYus6wsto7UufjjQnumDs1NK(RKeN0OKK8BO0gwscydu3ObIuHEta24zzoLrLlLb6AG6gnqKkuKfGnEwMtzu5szGoCmqDJgisfkYcWgplZPmQCPmqxdKPbY0a1nAGivOil8)JpF1wCKxtJVhiWhOUrdePcfzbQCPKpYRPX3dK5bckhitd8MaPdSUbQB0arQqrwa24zu5srW1LAak4bY8abLdKPbYW2WqXKq3ObI0mYzUBTFGmpqMhyLdKPbY0a1nAGivO3e()XNVAloYRPX3de4du3ObIuHEtGkxk5J8AA89azEGGYbY0aVjq6aRBG6gnqKk0BcWgpJkxkcUUudqbpqMhiOCGmnqg2ggkMe6gnqKMVL5U1(bY8azojDiUFJln(ojXgW1aHPeFG2a1nAGiLpqggwMgiQBd0)iUSnAadubtd0)p(8v7b(LbQGPbQB0ark7d8emIdDgiQBdubtd8iVMgFpWVmqfmnqu5szGHoWR9zehIlgOtrJpqBGCDPgGcEGi(tucAhO(deqWGgOnqWbaW0oWRn(nu3gO(dKRl1auWdu3ObIuo7d04dSkHXd04d0giI)eLG2bw(DGrzG2a1nAGiDGvdmEG)oWQbgpW(1bYDR9dSAOGhO)F85R2CrsIHT52qqjjDJgisZxB8BOULKmVgFNKyyByOykjXWWYuMWCkjDljXWWYusc5KMCgutvKKO2qX0jvFs6VssCstsMxJVtsmSnmumLKyyyzkjPgMAvaWuW0gnGmx)fHGAdftNb6WXa9FFKdvqmOTSpxfuBOy6mqhog4k3u5xaKan0ObK9p(iO2qX0jjXW2CBiOK0wnJkxk8KMCgPPkssMxJVtsfmXb7xROjjQnumDs1N0KMK8)JpF1MNQi58TufjjQnumDs1NK8BO0gwscvUuexbgBB(l5Y(CviFLKoe3VXLgFNKydFn(ojzEn(ojD9A8DstoJCQIKe1gkMoP6tsMxJVtseIRVkT5vUPCvYU(ojDiUFJln(oj5()XNVAZts(nuAdljPgMAv8O4qP104Bb1gkMod01ax5MgiOhiBAGUgitdKHTHHIjbxZxyR7ObmqhogidBddftc7C45LqyrpqMhORbY0a9)JpF1wCfyST5VKl7ZvXsiSO5de0dePd01azAG()XNVAlkyId2VwrflHWIMpWkhishORbYFzmA0hXLmxLXuMw5ln(wqTHIPZaD4yGaBG8xgJg9rCjZvzmLPv(sJVfuBOy6mqMhOdhdevUuexbgBB(l5Y(CviFnqMhOdhde958b6AGLaaynVeclA(ab9arMTjn5S7svKKO2qX0jvFsYVHsByjj1WuRc0LmfC(lzE0N1a8CtqTHIPZaDnWvUdF(6RsR4qLWh6aRCGUJTd01ax5MeAGGY6Nr6aRCGa8Nb6AGmnqu5srGUKPGZFjZJ(SgGNBc5Rb6WXalbaWAEjew08bc6bImBhiZjjZRX3jjcX1xL28k3uUkzxFN0KZGAQIKe1gkMoP6ts(nuAdljPgMAveEYBxcQnumDssMxJVtseIRVkT5vUPCvYU(oPjNrAQIKe1gkMoP6ts(nuAdljPgMAvGUKPGZFjZJ(SgGNBcQnumDgORbY0azyByOysW18f26oAad0HJbYW2WqXKWohEEjew0dK5b6AGmnq))4ZxTfOlzk48xY8OpRb45Myjew08b6WXa9)JpF1wGUKPGZFjZJ(SgGNBILSJBd01ax5o85RVkTIdvcFOde0dePSDGmNKmVgFNKUcm228xYL95AstoZMsvKKO2qX0jvFsYVHsByjj1WuRIWtE7sqTHIPZaDnqGnqu5srCfyST5VKl7ZvH8vsY8A8Ds6kWyBZFjx2NRjn5CTlvrsIAdftNu9jj)gkTHLKudtTkEuCO0AA8TGAdftNb6AGRCh(81xL2bwjRbImshORbY0azyByOysW18f26oAad0HJbYW2WqXKWohEEjew0dK5b6AGmnq1WuRcaMcM2ObK56VieuBOy6mqxdevUuelH4xoHjopxnALwH81aD4yGaBGQHPwfamfmTrdiZ1FriO2qX0zGmNKmVgFNKUcm228xYL95AstodkKQijrTHIPtQ(KKFdL2WssOYLI4kWyBZFjx2NRc5RKK5147Ke6sMco)Lmp6ZAaEUL0KZo9ufjjQnumDs1NK8BO0gwsY8AWGYuticIpqwd82aDnqu5srCfyST5VKl7ZvXsiSO5de0deG)mqxdevUuexbgBB(l5Y(CviFnqxdeydunm1Q4rXHsRPX3cQnumDgORbY0ab2axlozIb1QWohUGCsWv(aD4yGRfNmXGAvyNdxe9aRCGUJTdK5b6WXalbaWAEjew08bc6b6UKK5147KuzFUw1TfbpxKx3sAY5BSnvrsIAdftNu9jj)gkTHLKmVgmOm1eIG4dSswde5b6AGmnqu5srCfyST5VKl7ZvH81aD4yGRfNmXGAvyNdxqoj4kFGUg4AXjtmOwf25WfrpWkhO)F85R2IRaJTn)LCzFUkwcHfnFG1nWA3azEGUgitdevUuexbgBB(l5Y(CvSeclA(ab9ab4pd0HJbUwCYedQvHDoCb5KGR8b6AGRfNmXGAvyNdxSeclA(ab9ab4pdK5KK5147KuzFUw1TfbpxKx3sAY5B3svKKO2qX0jvFsYVHsByjj1WuRIhfhkTMgFlO2qX0zGUgiQCPiUcm228xYL95Qq(AGUgitdKPbIkxkIRaJTn)LCzFUkwcHfnFGGEGa8Nb6WXarLlfHCd(XUL56snafSq(AGUgiQCPiKBWp2TmxxQbOGflHWIMpqqpqa(ZazEGUgitd8qOYLIyTA(3WtcUAEGgiRbI0b6WXab2apKPGZa1baWQyLBQ8lasSwn)B4PbY8azojzEn(ojv2NRvDBrWZf51TKMC(gYPkssuBOy6KQpj53qPnSKKAyQvb6sMco)Lmp6ZAaEUjO2qX0zGUg4k3HpF9vPvCOs4dDGvoqqLTd01ax5MgiOznq3nqxdKPbIkxkc0LmfC(lzE0N1a8CtiFnqhogO)F85R2c0LmfC(lzE0N1a8CtSeclA(aRCGGkBhiZd0HJbcSbQgMAvGUKPGZFjZJ(SgGNBcQnumDgORbUYD4ZxFvAfhQe(qhyLSgiYinjzEn(ojb2TRxbtlIWNVwItTNsAY5BUlvrsIAdftNu9jj)gkTHLK8)JpF1wCfyST5VKl7ZvXsiSO5de0SgistsMxJVtsRfCkFi7K0KZ3a1ufjjQnumDs1NK8BO0gwsY8AWGYuticIpWkznqKhORbY0albaWAEjew08bc6b6Ub6WXab2arLlfb6sMco)Lmp6ZAaEUjKVgORbY0aVivaa8lJflHWIMpqqpqa(ZaD4yGRfNmXGAvyNdxqoj4kFGUg4AXjtmOwf25WflHWIMpqqpq3nqxdCT4KjguRc7C4IOhyLd8IubaWVmwSeclA(azEGmNKmVgFNK4MFJs4ddNVmVM0KZ3qAQIKe1gkMoP6ts(nuAdljzEnyqzQjebXhyLdePd0HJbUYnv(fajUat2(i(M4cQnumDssMxJVtshYuWzRp5d5n3sAsts6gnqKYtvKC(wQIKe1gkMoP6tsMxJVtsrZ9RSAOykxtLTwLrKpeJWtjPdX9BCPX3jPk2ObIuEsYVHsByjju5srCfyST5VKl7ZvH81aD4yGQTaivObckRF(YRzKz7ab9ar6aD4yGOpNpqxdSeaaR5LqyrZhiOhiY3sAYzKtvKKO2qX0jvFsY8A8Dss3ObI0BjPdX9BCPX3jPkatdu3ObI0bwnuWdubtdeCaamX1bsCnqykDgiddltSpWQbgpquAGYC6mWsSCDGwFg4LflDgy1qbpq2WaJTDGFzG1(95Qij53qPnSKeWgidBddftc(f5JsqNSUrdePd01arLlfXvGX2M)sUSpxfYxd01azAGaBGQHPwfHN82LGAdftNb6WXavdtTkcp5Tlb1gkMod01arLlfXvGX2M)sUSpxflHWIMpWkznWBSDGmpqxdKPbcSbQB0arQqrwa24z))4ZxThOdhdu3ObIuHISW)p(8vBXsiSO5d0HJbYW2WqXKq3ObI081g)gQBdK1aVnqMhOdhdu3ObIuHEtGkxk5J8AA89aRK1albaWAEjew08KMC2DPkssuBOy6KQpj53qPnSKeWgidBddftc(f5JsqNSUrdePd01arLlfXvGX2M)sUSpxfYxd01azAGaBGQHPwfHN82LGAdftNb6WXavdtTkcp5Tlb1gkMod01arLlfXvGX2M)sUSpxflHWIMpWkznWBSDGmpqxdKPbcSbQB0arQqVjaB8S)F85R2d0HJbQB0arQqVj8)JpF1wSeclA(aD4yGmSnmumj0nAGinFTXVH62aznqKhiZd0HJbQB0arQqrwGkxk5J8AA89aRK1albaWAEjew08KK5147KKUrdePiN0KZGAQIKe1gkMoP6tsMxJVts6gnqKEljDiUFJln(ojXMld8BSBd8BAGFpqzonqDJgish41(mIdXhOnqu5sH9bkZPbQGPb(kyAh43d0)p(8vBXabf3bgLb2uOGPDG6gnqKoWR9zehIpqBGOYLc7duMtde9vWd87b6)hF(QTij53qPnSKeWgOUrdePc9MaSXZYCkJkxkd01azAG6gnqKkuKf()XNVAlwcHfnFGoCmqGnqDJgisfkYcWgplZPmQCPmqMhOdhd0)p(8vBXvGX2M)sUSpxflHWIMpWkhiYSnPjNrAQIKe1gkMoP6ts(nuAdljbSbQB0arQqrwa24zzoLrLlLb6AGmnqDJgisf6nH)F85R2ILqyrZhOdhdeydu3ObIuHEta24zzoLrLlLbY8aD4yG()XNVAlUcm228xYL95Qyjew08bw5arMTjjZRX3jjDJgisroPjnjH(881)4ObKQi58TufjjQnumDs1NKmVgFNKwcXVCctCEUA0kTjPdX9BCPX3jP6xYuWd8lduk6ZAaEUnWR)XrdyG7RMgFpWAmqUARYh4n2Yhikv(Lgy9V0ad(angwGnumLK8BO0gwsY8AWGYuticIpWkznqKhOdhdKHTHHIjXwnJkxk8KMCg5ufjjQnumDs1NKmVgFNKEuCO0AkLK8BO0gwscvUueafyC0aYimp4OjXsMxhORb6)hF(QT4kWyBZFjx2NRILqyrZhyLd0DjjVBEmLvBbqkp58TKMC2DPkssuBOy6KQpj53qPnSKedBddftI91IpVbckjzEn(ojb(RIJgqgfBCnPjNb1ufjjQnumDs1NK8BO0gwscvUueafyC0aYimp4OjXsMxhORbUYD4ZxFvAfhQe(qhyLdKPbEdPdSUbQgMAvSYD4ZMQulBA8TGAdftNbckhishiZd01a5xegNvBbqkxu2NRCVBkyAGvoqKhORbcSbYW2WqXK4qMcMNpYu28AWGssMxJVtsL95k37McMsAYzKMQijrTHIPtQ(KKFdL2WssRCh(81xLwXHkHp0bwjRbY0aDhshyDdunm1QyL7WNnvPw204Bb1gkModeuoqKoqMhORbYVimoR2cGuUOSpx5E3uW0aRCGipqxdeydKHTHHIjXHmfmpFKPS51GbLKmVgFNKk7ZvU3nfmL0KZSPufjjQnumDs1NKmVgFNKEuCO0AkLK8BO0gwsAL7WNV(Q0kouj8HoWkznqKrAsY7Mhtz1waKYtoFlPjNRDPkssuBOy6KQpj53qPnSK0k3HpF9vPvCOs4dDGGEGiZ2b6AG8lcJZQTaiLlaGnFy4SDyyTNgyLSgiYd01a9)JpF1wCfyST5VKl7ZvXsiSO5dSYbI0KK5147KeaS5ddNTddR9ustodkKQijrTHIPtQ(KK5147KuzFUM56garjj)gkTHLKw5o85RVkTIdvcFOde0dez2oqxd0)p(8vBXvGX2M)sUSpxflHWIMpWkhistsE38ykR2cGuEY5Bjn5StpvrsIAdftNu9jj)gkTHLK8)JpF1wCfyST5VKl7ZvXsiSO5dSYbUYnj0abL1pdQd01ax5o85RVkTIdvcFOde0deuz7aDnq(fHXz1waKYfaWMpmC2omS2tdSswde5KK5147KeaS5ddNTddR9ustoFJTPkssuBOy6KQpjzEn(ojv2NRzUUbqusYVHsByjj))4ZxTfxbgBB(l5Y(CvSeclA(aRCGRCtcnqqz9ZG6aDnWvUdF(6RsR4qLWh6ab9abv2MK8U5XuwTfaP8KZ3sAstsC16JTNufjNVLQijrTHIPtQ(KK5147K0si(LtyIZZvJwPnjDiUFJln(ojjPwFS9mqE0aWeBe1waKoW9vtJVts(nuAdljXW2WqXKyRMrLlfEstoJCQIKe1gkMoP6ts(nuAdljHkxkcGcmoAazeMhC0KyjZRjjZRX3jPhfhkTMsjn5S7svKKO2qX0jvFsYVHsByjjg2ggkMe7RfFEde0aDnqu5srSbcsSeclA(ab9aDxsY8A8Dsc8xfhnGmk24AstodQPkssuBOy6KQpj53qPnSKedBddftIY(CnZ1naIY(VpYHYtsMxJVtsL95AMRBaeL0KZinvrsIAdftNu9jj)gkTHLKa2apKPGZa1baWQyLBQ8lasSwn)B4Pb6AGmnWdHkxkI1Q5Fdpj4Q5bAGGEGiDGoCmWdHkxkI1Q5FdpjwcHfnFGGEGa8NbckhiOoqMtsMxJVtsaWMpmC2omS2tjn5mBkvrsIAdftNu9jj)gkTHLK8)JpF1wSeIF5eM48C1OvAflHWIMpqqZAGipqq5ab4pd01avdtTkaykyAJgqMR)IqqTHIPtsY8A8DsQSpxZCDdGOKMCU2LQijrTHIPtQ(KKFdL2WssmSnmumj2xl(8giOKK5147Ke4VkoAazuSX1KMCguivrsIAdftNu9jj)gkTHLKw5o85RVkTIdvcFOde0dKPbEdPdSUbQgMAvSYD4ZMQulBA8TGAdftNbckhishiZjjZRX3jPY(CnZ1naIsAYzNEQIKe1gkMoP6ts(nuAdljbSbIkxkIY(1m15lzmNeYxd01avdtTkk7xZuNVKXCsqTHIPZaD4yGmSnmumjoKPG55JmLnVgmOb6AGOYLI4qMcMNpYKGRMhObc6bcQd0HJbQgMAvaWuW0gnGmx)fHGAdftNb6AGOYLIyje)YjmX55QrR0kKVgOdhdCL7WNV(Q0kouj8HoWkhitdezKoW6gOAyQvXk3HpBQsTSPX3cQnumDgiOCGiDGmNKmVgFNKEuCO0AkL0KZ3yBQIKK5147KuzFUM56garjjQnumDs1N0KZ3ULQijzEn(ojb(3o)LC1OvAtsuBOy6KQpPjNVHCQIKK5147KKTERPS(7sTMKO2qX0jvFstAstsmOLhFNCgz2I8TB3q2DjPQ22rdGNKyJDQonNzZo7uwJboWkatdmqC9RoWYVd8(JIdLwtJVZx)JJgW9bUunvow6mq(JGgOjRpctPZa9GTgaXfdi1kAAGixJb6(VzqRsNbExnm1Qaj3hO(d8UAyQvbseuBOy6CFGMoq2aqXAnqMU5eMfdidiSXovNMZSzNDkRXahyfGPbgiU(vhy53bE3)4tgmzREFGlvtLJLodK)iObAY6JWu6mqpyRbqCXasTIMg4TAmq3)ndAv6mW7QHPwfi5(a1FG3vdtTkqIGAdftN7dKPBoHzXasTIMgiY1yGU)Bg0Q0zG3vdtTkqY9bQ)aVRgMAvGeb1gkMo3hit3CcZIbKAfnnq3vJb6(VzqRsNbExnm1Qaj3hO(d8UAyQvbseuBOy6CFGmDZjmlgqQv00ab1Amq3)ndAv6mW7QHPwfi5(a1FG3vdtTkqIGAdftN7dKPBoHzXaYacBSt1P5mB2zNYAmWbwbyAGbIRF1bw(DG3FuCO0AA899bUunvow6mq(JGgOjRpctPZa9GTgaXfdi1kAAGo9Amq3)ndAv6mW7QHPwfi5(a1FG3vdtTkqIGAdftN7dKjKDcZIbKbe2yNQtZz2SZoL1yGdScW0adex)QdS87aVJ(8SgEGIgW9bUunvow6mq(JGgOjRpctPZa9GTgaXfdi1kAAG3QXaD)3mOvPZaVRgMAvGK7du)bExnm1QajcQnumDUpqMU5eMfdi1kAAGGAngO7)MbTkDg49vUPYVaibsUpq9h49vUPYVaibseuBOy6CFGmDZjmlgqgqyJDQonNzZo7uwJboWkatdmqC9RoWYVd8U)zqT1k)(axQMkhlDgi)rqd0K1hHP0zGEWwdG4IbKAfnnqKRXaD)3mOvPZaVRgMAvGK7du)bExnm1QajcQnumDUpqMU5eMfdi1kAAGURgd09FZGwLod8UAyQvbsUpq9h4D1WuRcKiO2qX05(az6MtywmGuROPbcQ1yGU)Bg0Q0zG3vdtTkqY9bQ)aVRgMAvGeb1gkMo3hit3CcZIbKAfnnqKwJb6(VzqRsNbExnm1Qaj3hO(d8UAyQvbseuBOy6CFGmHStywmGuROPbw7QXaD)3mOvPZaVRgMAvGK7du)bExnm1QajcQnumDUpqMU5eMfdi1kAAGo9Amq3)ndAv6mW78xgJg9rGK7du)bEN)Yy0OpcKiO2qX05(azczNWSyazaHn2P60CMn7Stzng4aRamnWaX1V6al)oW7C16JTN7dCPAQCS0zG8hbnqtwFeMsNb6bBnaIlgqQv00azt1yGU)Bg0Q0zG3vdtTkqY9bQ)aVRgMAvGeb1gkMo3hOPdKnauSwdKPBoHzXasTIMgiOqngO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bY0nNWSyaPwrtd0PxJb6(VzqRsNbExnm1Qaj3hO(d8UAyQvbseuBOy6CFGm5oNWSyazaHn2P60CMn7Stzng4aRamnWaX1V6al)oW7OppF9poAa3h4s1u5yPZa5pcAGMS(imLod0d2AaexmGuROPbcQ1yGU)Bg0Q0zG3vdtTkqY9bQ)aVRgMAvGeb1gkMo3hit3CcZIbKAfnnqKwJb6(VzqRsNbExnm1Qaj3hO(d8UAyQvbseuBOy6CFGmDZjmlgqgqyJDQonNzZo7uwJboWkatdmqC9RoWYVd8(1s(hbQP3h4s1u5yPZa5pcAGMS(imLod0d2AaexmGuROPbERgd09FZGwLodukq4(bYDRvZjdSMutgO(dSwY2ar8hzSmFG)fTM(7azQMW8azczNWSyaPwrtd8wngO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bYK7CcZIbKAfnnWB1yGU)Bg0Q0zG31nAGivCtGK7du)bEx3ObIuHEtGK7dKj35eMfdi1kAAGixJb6(VzqRsNbkfiC)a5U1Q5KbwtQjdu)bwlzBGi(JmwMpW)Iwt)DGmvtyEGmHStywmGuROPbICngO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bYK7CcZIbKAfnnqKRXaD)3mOvPZaVRB0arQazbsUpq9h4DDJgisfkYcKCFGm5oNWSyaPwrtd0D1yGU)Bg0Q0zGsbc3pqUBTAozG1KbQ)aRLSnWtWi4X3d8VO10FhitaN5bYeYoHzXasTIMgO7QXaD)3mOvPZaVRB0arQ4Maj3hO(d8UUrdePc9Maj3hitGQtywmGuROPb6UAmq3)ndAv6mW76gnqKkqwGK7du)bEx3ObIuHISaj3hiti1jmlgqQv00ab1Amq3)ndAv6mW7QHPwfi5(a1FG3vdtTkqIGAdftN7dKPBoHzXasTIMgiOwJb6(VzqRsNbEFLBQ8lasGK7du)bEFLBQ8lasGeb1gkMo3hOPdKnauSwdKPBoHzXasTIMgiOwJb6(VzqRsNbE3)9roubsUpq9h4D)3h5qfirqTHIPZ9bY0nNWSyazaHn2P60CMn7Stzng4aRamnWaX1V6al)oW7()XNVAZVpWLQPYXsNbYFe0anz9rykDgOhS1aiUyaPwrtde5Amq3)ndAv6mW7QHPwfi5(a1FG3vdtTkqIGAdftN7dKPBoHzXasTIMgiY1yGU)Bg0Q0zG35Vmgn6Jaj3hO(d8o)LXOrFeirqTHIPZ9bYeYoHzXasTIMgO7QXaD)3mOvPZaVRgMAvGK7du)bExnm1QajcQnumDUpqMU5eMfdi1kAAGGAngO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bA6azdafR1az6MtywmGuROPbI0Amq3)ndAv6mW7QHPwfi5(a1FG3vdtTkqIGAdftN7dKPBoHzXasTIMgiBQgd09FZGwLod8UAyQvbsUpq9h4D1WuRcKiO2qX05(az6MtywmGuROPbw7QXaD)3mOvPZaVRgMAvGK7du)bExnm1QajcQnumDUpqMU5eMfdi1kAAGo9Amq3)ndAv6mW7QHPwfi5(a1FG3vdtTkqIGAdftN7dKPBoHzXasTIMg4TB1yGU)Bg0Q0zG3vdtTkqY9bQ)aVRgMAvGeb1gkMo3hit3CcZIbKAfnnWBixJb6(VzqRsNbExnm1Qaj3hO(d8UAyQvbseuBOy6CFGmHStywmGuROPbEdP1yGU)Bg0Q0zG3x5Mk)cGei5(a1FG3x5Mk)cGeirqTHIPZ9bA6azdafR1az6MtywmGmGWg7uDAoZMD2PSgdCGvaMgyG46xDGLFh4DDJgis53h4s1u5yPZa5pcAGMS(imLod0d2AaexmGuROPbICngO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bYeYoHzXasTIMgiY1yGU)Bg0Q0zG31nAGivCtGK7du)bEx3ObIuHEtGK7dKPBoHzXasTIMgiY1yGU)Bg0Q0zG31nAGivGSaj3hO(d8UUrdePcfzbsUpqMq2jmlgqQv00aDxngO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bYeYoHzXasTIMgO7QXaD)3mOvPZaVRB0arQ4Maj3hO(d8UUrdePc9Maj3hiti7eMfdi1kAAGURgd09FZGwLod8UUrdePcKfi5(a1FG31nAGivOilqY9bY0nNWSyaPwrtdeuRXaD)3mOvPZaVRB0arQ4Maj3hO(d8UUrdePc9Maj3hit3CcZIbKAfnnqqTgd09FZGwLod8UUrdePcKfi5(a1FG31nAGivOilqY9bYeYoHzXasTIMgisRXaD)3mOvPZaVRB0arQ4Maj3hO(d8UUrdePc9Maj3hiti7eMfdi1kAAGiTgd09FZGwLod8UUrdePcKfi5(a1FG31nAGivOilqY9bY0nNWSyazaHn2P60CMn7Stzng4aRamnWaX1V6al)oW7hQyYy9(axQMkhlDgi)rqd0K1hHP0zGEWwdG4IbKAfnnqKwJb6(VzqRsNbEFLBQ8lasGK7du)bEFLBQ8lasGeb1gkMo3hiti7eMfdi1kAAGSPAmq3)ndAv6mW7(VpYHkqY9bQ)aV7)(ihQajcQnumDUpqMU5eMfdi1kAAGGc1yGU)Bg0Q0zG3vdtTkqY9bQ)aVRgMAvGeb1gkMo3hiti7eMfdi1kAAGo9Amq3)ndAv6mW7QHPwfi5(a1FG3vdtTkqIGAdftN7dKj35eMfdi1kAAG3yBngO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bYeO6eMfdi1kAAG3UvJb6(VzqRsNbExnm1Qaj3hO(d8UAyQvbseuBOy6CFGmbQoHzXasTIMg4n2ungO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bYeYoHzXasTIMg4nqHAmq3)ndAv6mW7QHPwfi5(a1FG3vdtTkqIGAdftN7dKPBoHzXasTIMg4nNEngO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bA6azdafR1az6MtywmGuROPbImBRXaD)3mOvPZaVRgMAvGK7du)bExnm1QajcQnumDUpqMU5eMfdidiSXovNMZSzNDkRXahyfGPbgiU(vhy53bE3E6(axQMkhlDgi)rqd0K1hHP0zGEWwdG4IbKAfnnqKRXaD)3mOvPZaVRgMAvGK7du)bExnm1QajcQnumDUpqthiBaOyTgit3CcZIbKAfnnqqTgd09FZGwLod8UAyQvbsUpq9h4D1WuRcKiO2qX05(anDGSbGI1AGmDZjmlgqQv00azt1yGU)Bg0Q0zG3vdtTkqY9bQ)aVRgMAvGeb1gkMo3hOPdKnauSwdKPBoHzXasTIMg4n2wJb6(VzqRsNbExnm1Qaj3hO(d8UAyQvbseuBOy6CFGmDZjmlgqQv00aVHCngO7)MbTkDg4D1WuRcKCFG6pW7QHPwfirqTHIPZ9bY0nNWSyazaHnJ46xLod8M7gO5147bIdUYfdijPR9lbMss1wTnqNcKPGhiB0DaaSoWA)(CDaP2QTbw7j0v2w3g4nKzFGiZwKrEazaP2QTb6EWwdG4di1wTnq2id0PriEg0zGyJRSr4K)7ZaL5gaAGFzGUhSfnFGFzGSzpnqJpWqh45jEFxh4f2CBGvjmEGrpWR18A4jXasTvBdKnYaDk89DDGEWw3eEG1EmXb7xROd8iVrdyG1VKPGh4xgOu0N1a8CtmGmGuBdKnGHHLnL4d0gOUrdeP8b6)hF(Qn7d8emIdDgiQBd8kWyBh4xgyzFUoWFhi6sMcEGFzG8OpRb452D(a9)JpF1wmq2CzGHENpqggwMgiyJpW(h4siSOp0oWLu5Th4n2hiH50axsL3EGSvGuXaI514BU4Aj)Ja106ybCg2ggkMyVneelDJgisZ3YC3Ap7)floPrHDggwMyDJDggwMYeMtSyRaPS7)(eA8nlDJgisf3eGnEwMtzu5sXftatnm1QaDjtbN)sMh9znap3CXKUrdePIBc))4ZxTfh51047AsnX)p(8vBXvGX2M)sUSpxfh5104BwSLzhoudtTkqxYuW5VK5rFwdWZnxm5)hF(QTaDjtbN)sMh9znap3eh51047Asnr3ObIuXnH)F85R2IJ8AA8nl2YSdhQHPwfHN82fZdiMxJV5IRL8pcutRJfWzyByOyI92qqS0nAGinJCM7w7z)VyXjnkSZWWYeRBSZWWYuMWCIfBfiLD)3NqJVzPB0arQazbyJNL5ugvUuCXeWudtTkqxYuW5VK5rFwdWZnxmPB0arQazH)F85R2IJ8AA8DnPM4)hF(QT4kWyBZFjx2NRIJ8AA8nl2YSdhQHPwfOlzk48xY8OpRb45MlM8)JpF1wGUKPGZFjZJ(SgGNBIJ8AA8DnPMOB0arQazH)F85R2IJ8AA8nl2YSdhQHPwfHN82fZdi12azd4AGWuIpqBG6gnqKYhiddltde1Tb6Fex2gnGbQGPb6)hF(Q9a)YavW0a1nAGiL9bEcgXHode1TbQGPbEKxtJVh4xgOcMgiQCPmWqh41(mIdXfd0POXhOnqUUudqbpqe)jkbTdu)bciyqd0gi4aayAh41g)gQBdu)bY1LAak4bQB0arkN9bA8bwLW4bA8bAdeXFIsq7al)oWOmqBG6gnqKoWQbgpWFhy1aJhy)6a5U1(bwnuWd0)p(8vBUyaX8A8nxCTK)rGAADSaodBddftS3gcILUrdeP5Rn(nu3y)VyXjnkSZWWYelKzNHHLPmH5eRBS7)(eA8nlGPB0arQ4MaSXZYCkJkxkU0nAGivGSaSXZYCkJkxkoCOB0arQazbyJNL5ugvUuCXet6gnqKkqw4)hF(QT4iVMgFxt0nAGivGSavUuYh5104BMbLmDtG060nAGivGSaSXZOYLIGRl1auWmdkzIHTHHIjHUrdePzKZC3ApZmxjtmPB0arQ4MW)p(8vBXrEnn(UMOB0arQ4MavUuYh5104BMbLmDtG060nAGivCta24zu5srW1LAakyMbLmXW2WqXKq3ObI08Tm3T2ZmZdiMxJV5IRL8pcutRJfWzyByOyI92qqS2Qzu5sHZoddltSudtTkaykyAJgqMR)IWHd)3h5qfedAl7Zvhow5Mk)cGeOHgnGS)XNbeZRX3CX1s(hbQP1Xc4fmXb7xROdidi1wTnq2aNqEzLodKyqRBdude0avW0anV(7ad(angwGnumjgqmVgFZzHi6tUSevZ0asTnq2WLyqToq(f5JsqNbQB0arkFGOu0agOmNodSAOGhOjRpctd)aXrt8beZRX386ybCg2ggkMyVneel(f5JsqNSUrdePSZWWYelMOAQCCDrhr0C)kRgkMY1uzRvze5dXi8Kl))4ZxTfrZ9RSAOykxtLTwLrKpeJWtILSJBmpGyEn(MxhlGZW2WqXe7THGyX18f26oAaSZWWYelZRbdktnHiioRBUyAT4KjguRc7C4IOR8gsD4ayRfNmXGAvyNdxqoj4kN5beZRX386ybCg2ggkMyVneel7C45LqyrZoddltSmVgmOm1eIG4vYczxmbS1ItMyqTkSZHliNeCL7WXAXjtmOwf25WfKtcUYDX0AXjtmOwf25WflHWIMxjsD4OeaaR5LqyrZR8gBzM5beZRX386ybCg2ggkMyVneeR91IpVbcIDggwMyHkxkInqqc5lxmbSvUPYVaiXAaO8xYkykx2VMPo7bBiUIVD4yLBQ8lasSgak)LScMYL9RzQZEWgIR4BxRCh(81xLwXHkHp0kbfyEaX8A8nVowaNHTHHIj2BdbXQSpxZCDdGOS)7JCOC2zyyzIL)7JCOcATt4nnAazu8x1fQCPiO1oH30ObKrXFvbxnpqSq2Hd)3h5qfYnMmoy6Kll11SBUqLlfHCJjJdMo5YsDn7Myjew0CqZea)buImZdiMxJV51Xc4mSnmumXEBiiwhYuW88rMYMxdge7mmSmX6qMcoB9jFiV5MqdpqrdWL)zqT1QOdaG1CXObKABGo1RlSBdS2VpxhyTNyql7deHfTArpq2S3TbwHH)MpqRpdeiIUgOtJq8lNWeNpq24OvAh4(yC0agqmVgFZRJfWxcXVCctCEUA0kTShfw(VpYHkig0w2NRUudtTkaykyAJgqMR)IWfWudtTkEuCO0AA8Tl))4ZxTfxbgBB(l5Y(CvSeclA(aI514BEDSao4VkoAazuSXv29U5XuwTfaPCw3ypkSa25vrzFUMledAflHWIM7Ij1WuRIWtE7YHdGHkxkc0LmfC(lzE0N1a8CtiF5snm1QaDjtbN)sMh9znap3C4qnm1Q4rXHsRPX3U8)JpF1wCfyST5VKl7ZvXsiSO5UagQCPiakW4ObKryEWrtc5lMhqmVgFZRJfWbGnFy4SDyyTNypkSqLlfr4DlRg(BUyjew0CqZcG)4snm1Qi8ULvd)n3f)IW4SAlas5cayZhgoBhgw7PkzHSlMudtTkcp5TlhoudtTkqxYuW5VK5rFwdWZnx()XNVAlqxYuW5VK5rFwdWZnXsiSO5vEdPoCOgMAv8O4qP104BxadvUuexbgBB(l5Y(CviFX8aI514BEDSaEzFUM56garShfwOYLIi8ULvd)nxSeclAoOzbWFCPgMAveE3YQH)M7Ij1WuRIWtE7YHd1WuRc0LmfC(lzE0N1a8CZfWqLlfb6sMco)Lmp6ZAaEUjKVC5)hF(QTaDjtbN)sMh9znap3elHWIMx5n26WHAyQvXJIdLwtJVDbmu5srCfyST5VKl7ZvH8fZdi12aDp4)50aDQEn(EG4GRdu)bUY9aI514BEDSaU3W4S5147mo4k7THGy5FguBTYhqmVgFZRJfW9ggNnVgFNXbxzVneeR18HH5diMxJV51Xc4EdJZMxJVZ4GRS3gcILUrdeP8beZRX386ybCVHXzZRX3zCWv2BdbXY)p(8vB(aI514BEDSaU3W4S5147mo4k7THGy5F8jdMSvzNRB4vw3ypkSudtTk8p(Kbt2QUycyOYLIaOaJJgqgH5bhnjKVC4qnm1QaDjtbN)sMh9znap3y2fthcvUueRvZ)gEsWvZdelK6WbWoKPGZa1baWQyLBQ8lasSwn)B4jMhqmVgFZRJfWx5oBEn(oJdUYEBiiwOppRHhOObWox3WRSUXEuyHkxkc0LmfC(lzE0N1a8CtiFnGyEn(MxhlGVYD28A8DghCL92qqSqFE(6FC0aypkSudtTkqxYuW5VK5rFwdWZnxm5)hF(QTaDjtbN)sMh9znap3elHWIMd6BSLzxmTwCYedQvHDoCr0vImsD4ayRfNmXGAvyNdxqoj4k3Hd))4ZxTfxbgBB(l5Y(CvSeclAoOVXwxRfNmXGAvyNdxqoj4k31AXjtmOwf25Wfrd6BSL5beZRX386yb8vUZMxJVZ4GRS3gcI1JIdLwtJVzNRB4vw3ypkSqLlfXvGX2M)sUSpxfYxUudtTkEuCO0AA89aI514BEDSa(k3zZRX3zCWv2BdbX6rXHsRPX35R)XrdG9OWsnm1Q4rXHsRPX3U8)JpF1wCfyST5VKl7ZvXsiSO5G(gBDXedBddftcUMVWw3rdWHJ1ItMyqTkSZHliNeCL7AT4KjguRc7C4IOb9n26WbWwlozIb1QWohUGCsWvoZdiMxJV51Xc4RCNnVgFNXbxzVneel7j256gEL1n2JclZRbdktnHiiELSqEaX8A8nVowa3ByC28A8DghCL92qqS4Q1hBpdidi12aDQpBWaDAVAA89aI514BUWEI1si(LtyIZZvJwPDaX8A8nxypvhlGdaB(WWz7WWApXEuyPgMAvu2NRCVBkyAaX8A8nxypvhlGx2NRCVBkyI9OWcvUueafyC0aYimp4OjXsMxDbmg2ggkMehYuW88rMYMxdg0aI514BUWEQowah8xfhnGmk24k7rHfdBddftI91IpVbcYLAyQvHXWWw7btdiMxJV5c7P6ybCayZhgoBhgw7j2JclGHkxkInqqc5lxMxdguMAcrqCqZYDoCyEnyqzQjebXR0Ddi12aR9)IqgBHFG211(Mh8a1FG(LmLgOnWlojF(bETXVH62avBbq6aXbxhy53bAxxy3IgWaxRM)n80aJEG2tdiMxJV5c7P6yb8Y(CnZ1naIy37Mhtz1waKYzDJ9OWY)p(8vBXsi(LtyIZZvJwPvSeclAoOzHmOeG)4snm1QaGPGPnAazU(lIbeZRX3CH9uDSao4VkoAazuSXv2Jclg2ggkMe7RfFEde0aI514BUWEQowaVSpx5E3uWe7rHfQCPiaykyAJgqMR)IqiF5Y8AWGYuticIxjYUagdBddftIdzkyE(itzZRbdAaX8A8nxypvhlG)O4qP1uI9OWIHTHHIjXHmfmpFKPS51Gb5cvUuehYuW88rMeC18abAq1Hdu5sraWuW0gnGmx)fHq(AaX8A8nxypvhlGx2NRzUUbqe7E38ykR2cGuoRBShfwRCh(81xLwXHkHpuqZ0nKwNAyQvXk3HpBQsTSPX3GsKY8aI514BUWEQowaVSpx5E3uWe7rHfWyyByOysCitbZZhzkBEnyqdiMxJV5c7P6yb8hfhkTMsS7DZJPSAlas5SUXEuyTYD4ZxFvAfhQe(qRKjKrADQHPwfRCh(SPk1YMgFdkrkZdiMxJV5c7P6ybCayZhgoBhgw7PbeZRX3CH9uDSaEzFUY9UPGPbeZRX3CH9uDSaEzFUM56garS7DZJPSAlas5SUnGyEn(MlSNQJfWb)BN)sUA0kTdiMxJV5c7P6ybCB9wtz93LADazaP2gy9lzk4b(Lbkf9znap3g41)4ObmW9vtJVhyngixTv5d8gB5deLk)sdS(xAGbFGgdlWgkMgqmVgFZfOppF9poAaSwcXVCctCEUA0kTShfwMxdguMAcrq8kzHSdhmSnmumj2Qzu5sHpGyEn(MlqFE(6FC0aQJfWFuCO0AkXU3npMYQTaiLZ6g7rHfQCPiakW4ObKryEWrtILmV6Y)p(8vBXvGX2M)sUSpxflHWIMxP7gqmVgFZfOppF9poAa1Xc4G)Q4ObKrXgxzpkSyyByOysSVw85nqqdiMxJV5c0NNV(hhnG6yb8Y(CL7DtbtShfwOYLIaOaJJgqgH5bhnjwY8QRvUdF(6RsR4qLWhALmDdP1PgMAvSYD4ZMQulBA8nOePm7IFryCwTfaPCrzFUY9UPGPkr2fWyyByOysCitbZZhzkBEnyqdiMxJV5c0NNV(hhnG6yb8Y(CL7DtbtShfwRCh(81xLwXHkHp0kzXK7qADQHPwfRCh(SPk1YMgFdkrkZU4xegNvBbqkxu2NRCVBkyQsKDbmg2ggkMehYuW88rMYMxdg0asTvBd8UAlasZrHfcZj1GPdHkxkI1Q5Fdpj4Q5bQUBmxty6qOYLIyTA(3WtILqyrZR7gZGYdzk4mqDaaSkw5Mk)cGeRvZ)gE6(aDA0fzkFG2aXVY(avWbFGbFGrRuFOZa1FGQTaiDGkyAGGdaGjUoWRn(nu3gi1ec3gy1qbpqRhOHg4qDBGkythy1aJhODDHDBGRvZ)gEAGrzGRCtLFbqhXaRaSPdeLIgWaTEGutiCBGvdf8az7a5Q5bIZ(a)DGwpqQjeUnqfSPdubtd8qOYLYaRgy8a5)3dKCYvS0a)wmGyEn(MlqFE(6FC0aQJfWFuCO0AkXU3npMYQTaiLZ6g7rH1k3HpF9vPvCOs4dTswiJ0beZRX3Cb6ZZx)JJgqDSaoaS5ddNTddR9e7rH1k3HpF9vPvCOs4df0iZwx8lcJZQTaiLlaGnFy4SDyyTNQKfYU8)JpF1wCfyST5VKl7ZvXsiSO5vI0beZRX3Cb6ZZx)JJgqDSaEzFUM56garS7DZJPSAlas5SUXEuyTYD4ZxFvAfhQe(qbnYS1L)F85R2IRaJTn)LCzFUkwcHfnVsKoGyEn(MlqFE(6FC0aQJfWbGnFy4SDyyTNypkS8)JpF1wCfyST5VKl7ZvXsiSO5vUYnj0abL1pdQUw5o85RVkTIdvcFOGguzRl(fHXz1waKYfaWMpmC2omS2tvYc5beZRX3Cb6ZZx)JJgqDSaEzFUM56garS7DZJPSAlas5SUXEuy5)hF(QT4kWyBZFjx2NRILqyrZRCLBsObckRFguDTYD4ZxFvAfhQe(qbnOY2bKbKABG1VKPGh4xgOu0N1a8CBGovVgmOb60E1047beZRX3Cb6ZZA4bkAaSEuCO0AkXU3npMYQTaiLZ6g7rH1k3HpF9vPvCOs4dTswmbQiTo1WuRIvUdF2uLAztJVbLiL5beZRX3Cb6ZZA4bkAa1Xc4lH4xoHjopxnALw2Jclg2ggkMeB1mQCPWD4W8AWGYuticIxjlKD4yL7WNV(Q0cA3H8aI514BUa95zn8afnG6yb8dzk4S1N8H8MBShfwRCh(81xLwq7oKhqmVgFZfOppRHhOObuhlGd(RIJgqgfBCL9OWIHTHHIjX(AXN3ab5IPvUdF(6RsR4qLWhkOrksD4yLBsObckRF2DGMfa)XHJvUPYVaiXAaO8xYkykx2VMPo7bBiUIVD4GFryCwTfaPCb4VkoAazuSX1kzHSdhOYLIydeKyjew0Cq7oMD4yL7WNV(Q0cA3H8aI514BUa95zn8afnG6yb8Y(CL7DtbtShfwOYLIaOaJJgqgH5bhnjKVCXVimoR2cGuUOSpx5E3uWuLi7cymSnmumjoKPG55JmLnVgmObeZRX3Cb6ZZA4bkAa1Xc4pkouAnLy37Mhtz1waKYzDJ9OWcvUueafyC0aYimp4OjXsMxhqmVgFZfOppRHhOObuhlGd(3o)LC1OvAzpkSw5o85RVkTIdvcFOvYcuzRRvUjHgiOS(z3vja)zaX8A8nxG(8SgEGIgqDSaEzFUY9UPGj2Jcl(fHXz1waKYfL95k37McMQezxaJHTHHIjXHmfmpFKPS51GbnGyEn(MlqFEwdpqrdOowa)rXHsRPe7E38ykR2cGuoRBShfwRCh(81xLwXHkHp0krgPoCSYnj0abL1p7oqdWFgqmVgFZfOppRHhOObuhlGd(RIJgqgfBCL9OWIHTHHIjX(AXN3abnGyEn(MlqFEwdpqrdOowa3wV1uw)DPwzpkSw5o85RVkTIdvcFOvIu2oGmGuB12aD)Jpd0PizRoq3)9j04B(asTvBd08A8nx4F8jdMSvz5bBrZZFjhEI9OWQeaaR5LqyrZbna)XftRCtGgzhoagQCPiakW4ObKryEWrtc5lxmbmew0zWwFeid2fQCPi8p(Kbt2QcUAEGQKfOw3k3u5xaKaOhRXA8CXy8RdhiSOZGT(iqgSlu5sr4F8jdMSvfC18avjOqDRCtLFbqcGESgRXZfJXVm7WbQCPiakW4ObKryEWrtc5lxmbmew0zWwFeid2fQCPi8p(Kbt2QcUAEGQeuOUvUPYVaibqpwJ145IX4xhoqyrNbB9rGmyxOYLIW)4tgmzRk4Q5bQYBSTUvUPYVaibqpwJ145IX4xMzEaP2giBu50apYB0agiByGX2oWQHcEGSzp5TlGx)sMcEaX8A8nx4F8jdMSvRJfW9GTO55VKdpXEuybm1WuRIhfhkTMgF7cvUuexbgBB(l5Y(CviF5cvUue(hFYGjBvbxnpqvY6gBDXeQCPiUcm228xYL95Qyjew0CqdWFaLmDRo))4ZxTfL95Av3we8CrEDtSKDCJzhoqLlfHCd(XUL56snafSyjew0CqdWFC4avUueEW2ZZOwtILqyrZbna)H5bKABGGIYkpo0a)Yazddm22bkZjdanWQHcEGSzp5TlGx)sMcEaX8A8nx4F8jdMSvRJfW9GTO55VKdpXEuybm1WuRIhfhkTMgF76qMcoduhaaRIvUPYVairXWyQZ(vMBhADbmu5srCfyST5VKl7ZvH8Ll))4ZxTfxbgBB(l5Y(CvSeclAEL3qQlMqLlfH)XNmyYwvWvZduLSUXwxmHkxkc5g8JDlZ1LAakyH8LdhOYLIWd2EEg1AsiFXSdhOYLIW)4tgmzRk4Q5bQsw3ChZdiMxJV5c)JpzWKTADSaUhSfnp)LC4j2JclGPgMAv8O4qP104Bxa7qMcoduhaaRIvUPYVairXWyQZ(vMBhADHkxkc)JpzWKTQGRMhOkzDJTUagQCPiUcm228xYL95Qq(YL)F85R2IRaJTn)LCzFUkwcHfnVsKz7asTnq2WLyqToq3)4ZaDks2Qd8zqR3UUIgWapYB0ag4vGX2oGyEn(Ml8p(Kbt2Q1Xc4EWw088xYHNypkSudtTkEuCO0AA8TlGHkxkIRaJTn)LCzFUkKVCXeQCPi8p(Kbt2QcUAEGQK1nq1ftOYLIqUb)y3YCDPgGcwiF5WbQCPi8GTNNrTMeYxm7WbQCPi8p(Kbt2QcUAEGQK1nNUdh()XNVAlUcm228xYL95Qyjew0Cq7oxOYLIW)4tgmzRk4Q5bQsw3avMhqgqQTbYg(A89aI514BUW)p(8vBoRRxJVzpkSqLlfXvGX2M)sUSpxfYxdi12aD))4ZxT5diMxJV5c))4ZxT51Xc4eIRVkT5vUPCvYU(M9OWsnm1Q4rXHsRPX3Uw5ManBYftmSnmumj4A(cBDhnahoyyByOysyNdpVeclAMDXK)F85R2IRaJTn)LCzFUkwcHfnh0i1ft()XNVAlkyId2VwrflHWIMxjsDXFzmA0hXLmxLXuMw5ln(2HdGXFzmA0hXLmxLXuMw5ln(MzhoqLlfXvGX2M)sUSpxfYxm7Wb6Z5UkbaWAEjew0CqJmBhqmVgFZf()XNVAZRJfWjexFvAZRCt5QKD9n7rHLAyQvb6sMco)Lmp6ZAaEU5AL7WNV(Q0kouj8HwP7yRRvUjHgiOS(zKwja)XftOYLIaDjtbN)sMh9znap3eYxoCucaG18siSO5Ggz2Y8aI514BUW)p(8vBEDSaoH46RsBELBkxLSRVzpkSudtTkcp5TRbeZRX3CH)F85R286yb8RaJTn)LCzFUYEuyPgMAvGUKPGZFjZJ(SgGNBUyIHTHHIjbxZxyR7Ob4WbdBddftc7C45LqyrZSlM8)JpF1wGUKPGZFjZJ(SgGNBILqyrZD4W)p(8vBb6sMco)Lmp6ZAaEUjwYoU5AL7WNV(Q0kouj8HcAKYwMhqmVgFZf()XNVAZRJfWVcm228xYL95k7rHLAyQvr4jVD5cyOYLI4kWyBZFjx2NRc5RbeZRX3CH)F85R286yb8RaJTn)LCzFUYEuyPgMAv8O4qP104BxRCh(81xL2kzHmsDXedBddftcUMVWw3rdWHdg2ggkMe25WZlHWIMzxmPgMAvaWuW0gnGmx)fHGAdfthxOYLIyje)YjmX55QrR0kKVC4ayQHPwfamfmTrdiZ1FriO2qX0H5beZRX3CH)F85R286ybC0LmfC(lzE0N1a8CJ9OWcvUuexbgBB(l5Y(CviFnGyEn(Ml8)JpF1MxhlGx2NRvDBrWZf51n2JclZRbdktnHiioRBUqLlfXvGX2M)sUSpxflHWIMdAa(Jlu5srCfyST5VKl7ZvH8LlGPgMAv8O4qP104BxmbS1ItMyqTkSZHliNeCL7WXAXjtmOwf25WfrxP7ylZoCucaG18siSO5G2DdiMxJV5c))4ZxT51Xc4L95Av3we8CrEDJ9OWY8AWGYuticIxjlKDXeQCPiUcm228xYL95Qq(YHJ1ItMyqTkSZHliNeCL7AT4KjguRc7C4IOR0)p(8vBXvGX2M)sUSpxflHWIMxxTJzxmHkxkIRaJTn)LCzFUkwcHfnh0a8hhowlozIb1QWohUGCsWvUR1ItMyqTkSZHlwcHfnh0a8hMhqmVgFZf()XNVAZRJfWl7Z1QUTi45I86g7rHLAyQvXJIdLwtJVDHkxkIRaJTn)LCzFUkKVCXetOYLI4kWyBZFjx2NRILqyrZbna)XHdu5sri3GFSBzUUudqblKVCHkxkc5g8JDlZ1LAakyXsiSO5GgG)WSlMoeQCPiwRM)n8KGRMhiwi1HdGDitbNbQdaGvXk3u5xaKyTA(3WtmZ8aI514BUW)p(8vBEDSaoy3UEfmTicF(Ajo1EI9OWsnm1QaDjtbN)sMh9znap3CTYD4ZxFvAfhQe(qReuzRRvUjqZYDUycvUueOlzk48xY8OpRb45Mq(YHd))4ZxTfOlzk48xY8OpRb45Myjew08kbv2YSdhatnm1QaDjtbN)sMh9znap3CTYD4ZxFvAfhQe(qRKfYiDaX8A8nx4)hF(QnVowaFTGt5dzh2Jcl))4ZxTfxbgBB(l5Y(CvSeclAoOzH0beZRX3CH)F85R286ybCU53Oe(WW5lZRShfwMxdguMAcrq8kzHSlMkbaWAEjew0Cq7ohoagQCPiqxYuW5VK5rFwdWZnH8LlMUivaa8lJflHWIMdAa(JdhRfNmXGAvyNdxqoj4k31AXjtmOwf25WflHWIMdA35AT4KjguRc7C4IOR8IubaWVmwSeclAoZmpGyEn(Ml8)JpF1MxhlGFitbNT(KpK3CJ9OWY8AWGYuticIxjsD4yLBQ8lasCbMS9r8nXhqgqQTb6(Nb1wRd0PIg4qdIpGyEn(Ml8pdQTw5SoKPG55JmXEuyXW2WqXKGR5lS1D0aC4GHTHHIjHDo88siSOhqmVgFZf(Nb1wR86ybCEvBrenGmIGRShfwRCh(81xLwXHkHp0kV5ox()XNVAlUcm228xYL95Qyjew0Cq7oxatnm1QaDjtbN)sMh9znap3CXW2WqXKGR5lS1D0agqmVgFZf(Nb1wR86ybCEvBrenGmIGRShfwatnm1QaDjtbN)sMh9znap3CXW2WqXKWohEEjew0diMxJV5c)ZGARvEDSaoVQTiIgqgrWv2Jcl1WuRc0LmfC(lzE0N1a8CZftOYLIaDjtbN)sMh9znap3eYxUyIHTHHIjbxZxyR7Ob4AL7WNV(Q0kouj8HwjOYwhoyyByOysyNdpVeclAxRCh(81xLwXHkHp0kztS1Hdg2ggkMe25WZlHWI21AXjtmOwf25WflHWIMdANUR1ItMyqTkSZHliNeCLZSdhadvUueOlzk48xY8OpRb45Mq(YL)F85R2c0LmfC(lzE0N1a8CtSeclAoZdiMxJV5c)ZGARvEDSaUH(iI2047moqGYEuy5)hF(QT4kWyBZFjx2NRILqyrZbT7CXW2WqXKGR5lS1D0aCXKAyQvb6sMco)Lmp6ZAaEU5AL7WNV(Q0kouj8HcA2eBD5)hF(QTaDjtbN)sMh9znap3elHWIMdAKD4ayQHPwfOlzk48xY8OpRb45gZdiMxJV5c)ZGARvEDSaUH(iI2047moqGYEuyXW2WqXKWohEEjew0diMxJV5c)ZGARvEDSaohS5bctzfmLL7Q)QGDJ9OWIHTHHIjbxZxyR7Ob4Ij))4ZxTfxbgBB(l5Y(CvSeclAoODNdhQHPwfHN82fZdiMxJV5c)ZGARvEDSaohS5bctzfmLL7Q)QGDJ9OWIHTHHIjHDo88siSOhqmVgFZf(Nb1wR86yb8cM4G9Rvu2JclGHkxkIRaJTn)LCzFUkKVCbmu5srGUKPGZFjZJ(SgGNBc5lxmXFzmA0hXLmxLXuMw5ln(2Hd(lJrJ(iy8ytdmL5pMb1kZShTs7kFP5abc6eMsSUXE0kTR8LMbGFudZ6g7rR0UYxAokS4Vmgn6JGXJnnWuM)yguRdidi12abfrXHsRPX3dCF1047beZRX3CXJIdLwtJVzTeIF5eM48C1OvAzpkSmVgmOm1eIG4vYYDUyyByOysSvZOYLcFaX8A8nx8O4qP10476ybCWFvC0aYOyJRShfwadvUueafyC0aYimp4OjH8LRvUPkz5oxmHkxkInqqILqyrZbT7CHkxkInqqc5lhomVgmO85vrzFUMledAbT51GbLPMqeeN5beZRX3CXJIdLwtJVRJfWbGnFy4SDyyTNypkSagQCPiakW4ObKryEWrtc5lx8lcJZQTaiLlaGnFy4SDyyTNQKfYoCamu5srauGXrdiJW8GJMeYxUy6qOYLIyTA(3WtcUAEGansD44qOYLIyTA(3WtILqyrZbna)bucQmpGyEn(MlEuCO0AA8DDSaEzFUY9UPGj2Jclu5srauGXrdiJW8GJMelzE1f)IW4SAlas5IY(CL7DtbtvISlGXW2WqXK4qMcMNpYu28AWGgqmVgFZfpkouAnn(Uowa)rXHsRPe7E38ykR2cGuoRBShfwOYLIaOaJJgqgH5bhnjwY86aI514BU4rXHsRPX31Xc4L95AMRBaeXEuyzEnyqzQjebXzDZfdBddftIY(CnZ1naIY(VpYHYhqmVgFZfpkouAnn(Uowah8xfhnGmk24k7rHfdBddftI91IpVbcYf)IW4SAlas5cWFvC0aYOyJRvYc5beZRX3CXJIdLwtJVRJfWbGnFy4SDyyTNypkS4xegNvBbqkxaaB(WWz7WWApvjlKhqmVgFZfpkouAnn(UowaVSpxZCDdGi29U5XuwTfaPCw3ypkSaMAyQvHXWWw7btUagQCPiakW4ObKryEWrtc5lhoudtTkmgg2ApyYfWyyByOysSVw85nqqoCWW2WqXKyFT4ZBGGCTYnj0abL1pJCLSa4pdiMxJV5IhfhkTMgFxhlGd(RIJgqgfBCL9OWIHTHHIjX(AXN3abnGyEn(MlEuCO0AA8DDSa(JIdLwtj29U5XuwTfaPCw3gqgqQTbYg(poAadS2)7abfrXHsRPX31yGsQTkFG3y7a5K)7dFGOu5xAGSHbgB7a)YaR97Z1b6FeeFGFPmq37uyaX8A8nx8O4qP104781)4ObWAje)YjmX55QrR0YEuyXW2WqXKyRMrLlfUdhMxdguMAcrq8kzH8aI514BU4rXHsRPX35R)XrdOowaha28HHZ2HH1EI9OWIFryCwTfaPCbaS5ddNTddR9uLSq2LAyQvrzFUY9UPGPbeZRX3CXJIdLwtJVZx)JJgqDSaEzFUY9UPGj2Jclu5srauGXrdiJW8GJMelzE1L51GbLPMqeeVsKDbmg2ggkMehYuW88rMYMxdg0aI514BU4rXHsRPX35R)XrdOowa)rXHsRPe7E38ykR2cGuoRBShfwOYLIaOaJJgqgH5bhnjwY86aI514BU4rXHsRPX35R)XrdOowaVSpxZCDdGi2JclZRbdktnHiioRBUyyByOysu2NRzUUbqu2)9rou(aI514BU4rXHsRPX35R)XrdOowa)rXHsRPe7E38ykR2cGuoRBShfwOYLIaOaJJgqgH5bhnjwY86aI514BU4rXHsRPX35R)XrdOowah8xfhnGmk24k7rHfdBddftI91IpVbcAaX8A8nx8O4qP104781)4ObuhlGdaB(WWz7WWApXEuyXVimoR2cGuUaa28HHZ2HH1EQswi7AL7WNV(Q0kouj8HcA2eBhqmVgFZfpkouAnn(oF9poAa1Xc4L95AMRBaeXU3npMYQTaiLZ6g7rH1k3HpF9vPvCOs4df01o2oGyEn(MlEuCO0AA8D(6FC0aQJfWFuCO0AkXU3npMYQTaiLZ6g7rH1k3uLSC3aI514BU4rXHsRPX35R)XrdOowaVSpx5E3uWe7rHL51GbLPMqeeVswGQlGXW2WqXK4qMcMNpYu28AWGgqgqQTb60mFy4b6urdCObXhqmVgFZfR5ddZzHI))KlYRBShfwOYLI4kWyBZFjx2NRc5RbeZRX3CXA(WW86ybCuA50cu0aypkSqLlfXvGX2M)sUSpxfYxdiMxJV5I18HH51Xc426TMYxYyoXEuyXeWqLlfXvGX2M)sUSpxfYxUmVgmOm1eIG4vYczMD4ayOYLI4kWyBZFjx2NRc5lxmTYnjouj8HwjlK6AL7WNV(Q0kouj8Hwjl2eBzEaX8A8nxSMpmmVowahhaaR8mBuKpaqqTYEuyHkxkIRaJTn)LCzFUkKVgqmVgFZfR5ddZRJfWT2tCDnC2Bym7rHfQCPiUcm228xYL95Qq(YfQCPiiexFvAZRCt5QKD9Tq(AaX8A8nxSMpmmVowaVelHI))WEuyHkxkIRaJTn)LCzFUkwcHfnh0SafCHkxkIRaJTn)LCzFUkKVCHkxkccX1xL28k3uUkzxFlKVgqmVgFZfR5ddZRJfWrna5VK1n8aXzpkSqLlfXvGX2M)sUSpxfYxUmVgmOm1eIG4SU5Iju5srCfyST5VKl7ZvXsiSO5GgPUudtTk8p(Kbt2QcQnumDC4ayQHPwf(hFYGjBvb1gkMoUqLlfXvGX2M)sUSpxflHWIMdA3X8aYasTnqj16JTNbYJgaMyJO2cG0bUVAA89aI514BUGRwFS9WAje)YjmX55QrR0YEuyXW2WqXKyRMrLlf(aI514BUGRwFS9uhlG)O4qP1uI9OWcvUueafyC0aYimp4OjXsMxhqmVgFZfC16JTN6ybCWFvC0aYOyJRShfwmSnmumj2xl(8giixOYLIydeKyjew0Cq7UbeZRX3CbxT(y7PowaVSpxZCDdGi2Jclg2ggkMeL95AMRBaeL9FFKdLpGyEn(Ml4Q1hBp1Xc4aWMpmC2omS2tShfwa7qMcoduhaaRIvUPYVaiXA18VHNCX0HqLlfXA18VHNeC18abAK6WXHqLlfXA18VHNelHWIMdAa(dOeuzEaX8A8nxWvRp2EQJfWl7Z1mx3aiI9OWY)p(8vBXsi(LtyIZZvJwPvSeclAoOzHmOeG)4snm1QaGPGPnAazU(lIbeZRX3CbxT(y7Powah8xfhnGmk24k7rHfdBddftI91IpVbcAaX8A8nxWvRp2EQJfWl7Z1mx3aiI9OWAL7WNV(Q0kouj8HcAMUH06udtTkw5o8ztvQLnn(guIuMhqmVgFZfC16JTN6yb8hfhkTMsShfwadvUueL9RzQZxYyojKVCPgMAvu2VMPoFjJ5KdhmSnmumjoKPG55JmLnVgmixOYLI4qMcMNpYKGRMhiqdQoCOgMAvaWuW0gnGmx)fHlu5srSeIF5eM48C1OvAfYxoCSYD4ZxFvAfhQe(qRKjKrADQHPwfRCh(SPk1YMgFdkrkZdiMxJV5cUA9X2tDSaEzFUM56gardiMxJV5cUA9X2tDSao4F78xYvJwPDaX8A8nxWvRp2EQJfWT1BnL1FxQ1bKbKABGvSrdeP8beZRX3CHUrdePCwrZ9RSAOykxtLTwLrKpeJWtShfwOYLI4kWyBZFjx2NRc5lhouBbqQqdeuw)8LxZiZwqJuhoqFo3vjaawZlHWIMdAKVnGuBdScW0a1nAGiDGvdf8avW0abhaatCDGexdeMsNbYWWYe7dSAGXdeLgOmNodSelxhO1NbEzXsNbwnuWdKnmWyBh4xgyTFFUkgqmVgFZf6gnqKYRJfW1nAGi9g7rHfWyyByOysWViFuc6K1nAGi1fQCPiUcm228xYL95Qq(Yftatnm1Qi8K3UC4qnm1Qi8K3UCHkxkIRaJTn)LCzFUkwcHfnVsw3ylZUycy6gnqKkqwa24z))4ZxTD4q3ObIubYc))4ZxTflHWIM7WbdBddftcDJgisZxB8BOUX6gZoCOB0arQ4MavUuYh51047kzvcaG18siSO5diMxJV5cDJgis51Xc46gnqKIm7rHfWyyByOysWViFuc6K1nAGi1fQCPiUcm228xYL95Qq(Yftatnm1Qi8K3UC4qnm1Qi8K3UCHkxkIRaJTn)LCzFUkwcHfnVsw3ylZUycy6gnqKkUjaB8S)F85R2oCOB0arQ4MW)p(8vBXsiSO5oCWW2WqXKq3ObI081g)gQBSqMzho0nAGivGSavUuYh51047kzvcaG18siSO5di12azZLb(n2Tb(nnWVhOmNgOUrdePd8AFgXH4d0giQCPW(aL50avW0aFfmTd87b6)hF(QTyGGI7aJYaBkuW0oqDJgish41(mIdXhOnqu5sH9bkZPbI(k4b(9a9)JpF1wmGyEn(Ml0nAGiLxhlGRB0ar6n2JclGPB0arQ4MaSXZYCkJkxkUys3ObIubYc))4ZxTflHWIM7WbW0nAGivGSaSXZYCkJkxkm7WH)F85R2IRaJTn)LCzFUkwcHfnVsKz7aI514BUq3ObIuEDSaUUrdePiZEuybmDJgisfilaB8SmNYOYLIlM0nAGivCt4)hF(QTyjew0ChoaMUrdePIBcWgplZPmQCPWSdh()XNVAlUcm228xYL95Qyjew08krMTjj(f5toJmsVL0KMs]] )


end
