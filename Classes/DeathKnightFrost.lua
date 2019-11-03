-- DeathKnightFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DEATHKNIGHT' then
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
            aura        = 'empower_rune_weapon',

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
    }, {
        __index = function( t, k, v )
            if k == 'actual' then
                local amount = 0

                for i = 1, 6 do
                    amount = amount + ( t.expiry[ i ] <= state.query_time and 1 or 0 )
                end

                return amount

            elseif k == 'current' then
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

            elseif k == 'time_to_next' then
                return t[ 'time_to_' .. t.current + 1 ]

            elseif k == 'time_to_max' then
                return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

            elseif k == 'add' then
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
            talent      = 'breath_of_sindragosa',
            aura        = 'breath_of_sindragosa',

            last = function ()
                return state.buff.breath_of_sindragosa.applied + floor( state.query_time - state.buff.breath_of_sindragosa.applied )
            end,

            stop = function ( x ) return x < 16 end,

            interval = 1,
            value = -16
        },

        empower_rp = {
            aura        = 'empower_rune_weapon',

            last = function ()
                return state.buff.empower_rune_weapon.applied + floor( state.query_time - state.buff.empower_rune_weapon.applied )
            end,

            interval = 5,
            value = 5
        },
    } )


    local virtual_rp_spent_since_pof = 0

    local spendHook = function( amt, resource, noHook )
        if amt > 0 and resource == "runic_power" and buff.breath_of_sindragosa.up and runic_power.current < 16 then
            removeBuff( "breath_of_sindragosa" )
            gain( 2, "runes" )
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
        glacial_advance = 22533, -- 194913
        frostwyrms_fury = 22535, -- 279302

        icecap = 22023, -- 207126
        obliteration = 22109, -- 281238
        breath_of_sindragosa = 22537, -- 152279
    } )


    spec:RegisterPvpTalents( { 
        adaptation = 3540, -- 214027
        relentless = 3539, -- 196029
        gladiators_medallion = 3538, -- 208683

        antimagic_zone = 3435, -- 51052
        cadaverous_pallor = 3515, -- 201995
        chill_streak = 706, -- 305392
        dark_simulacrum = 3512, -- 77606
        dead_of_winter = 3743, -- 287250
        deathchill = 701, -- 204080
        delirium = 702, -- 233396
        heartstop_aura = 3439, -- 199719
        lichborne = 3742, -- 136187
        necrotic_aura = 43, -- 199642
        transfusion = 3749, -- 237515
    } )


    -- Auras
    spec:RegisterAuras( {
        antimagic_shell = {
            id = 48707,
            duration = function () return 5 + ( ( level < 116 and equipped.acherus_drapes ) and 5 or 0 ) end,
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
        death_pact = {
            id = 48743,
            duration = 15,
            max_stack = 1,
        },
        deaths_advance = {
            id = 48265,
            duration = 8,
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
            duration = 15,
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

        heartstop_aura = {
            id = 199719,
            duration = 3600,
            max_stack = 1,
        },

        lichborne = {
            id = 287081,
            duration = 10,
            max_stack = 1,
        },

        transfusion = {
            id = 288977,
            duration = 7,
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


    spec:RegisterHook( "reset_precast", function ()
        local control_expires = action.control_undead.lastCast + 300

        if control_expires > now and pet.up then
            summonPet( "controlled_undead", control_expires - now )
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


        asphyxiate = {
            id = 108194,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 538558,

            talent = "asphyxiate",

            handler = function ()
                applyDebuff( "target", "asphyxiate" )
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
                if talent.icy_talons.enabled then addStack( "icy_talons", 6, 1 ) end
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

                --[[ if pvptalent.deathchill.enabled and debuff.chains_of_ice.up then
                    applyDebuff( "target", "deathchill" )
                end ]]
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

            startsCombat = true,
            texture = 237273,

            usable = function () return target.is_undead and target.level <= level + 1 end,
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

            spend = 0,
            spendType = "runic_power",

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
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 237532,

            handler = function ()
                applyDebuff( "target", "death_grip" )
                setDistance( 5 )
            end,
        },


        death_pact = {
            id = 48743,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

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

            spend = function () return buff.dark_succor.up and 0 or ( ( buff.transfusion.up and 0.5 or 1 ) * 35 ) end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237517,

            handler = function ()
                gain( health.max * 0.10, "health" )
                if talent.icy_talons.enabled then addStack( "icy_talons", 6, 1 ) end
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
            end,
        },


        empower_rune_weapon = {
            id = 47568,
            cast = 0,
            charges = function () return ( level < 116 and equipped.seal_of_necrofantasia ) and 2 or nil end,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135372,

            usable = function () return not buff.empower_rune_weapon.up end,
            readyTime = function () return buff.empower_rune_weapon.remains end,
            handler = function ()
                stat.haste = state.haste + 0.15
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

            spend = 25,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237520,

            handler = function ()
                applyDebuff( "target", "razorice", 20, 2 )                
                if talent.icy_talons.enabled then addStack( "icy_talons", 6, 1 ) end
                if talent.obliteration.enabled and buff.pillar_of_frost.up then applyBuff( "killing_machine" ) end
                -- if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end
            end,
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

            handler = function ()
                removeBuff( "killing_machine" )
            end,
        },


        frostwyrms_fury = {
            id = 279302,
            cast = 0,
            cooldown = function () return 180 - ( ( level < 116 and equipped.consorts_cold_core ) and 90 or 0 ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 341980,

            talent = "frostwyrms_fury",

            recheck = function () return buff.pillar_of_frost.remains - gcd.remains end,
            handler = function ()
                applyDebuff( "target", "frost_breath" )
            end,
        },


        glacial_advance = {
            id = 194913,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",

            spend = 30,
            spendType = "runic_power",

            startsCombat = true,
            texture = 537514,

            handler = function ()
                applyDebuff( "target", "razorice", nil, 1 )
                if talent.icy_talons.enabled then addStack( "icy_talons", 6, 1 ) end
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

            recheck = function () return runic_power[ "time_to_" .. ( runic_power.max - 30 ) ] end,
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

            recheck = function () return dot.frost_fever.remains end,
            handler = function ()
                applyDebuff( "target", "frost_fever" )
                active_dot.frost_fever = max( active_dot.frost_fever, active_enemies )

                if talent.obliteration.enabled and buff.pillar_of_frost.up then applyBuff( "killing_machine" ) end
                -- if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end

                removeBuff( "rime" )
            end,
        },


        icebound_fortitude = {
            id = 48792,
            cast = 0,
            cooldown = function ()
                if azerite.cold_hearted.enabled then return 165 end
                return 180
            end,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 237525,

            handler = function ()
                applyBuff( "icebound_fortitude" )
            end,
        },


        lichborne = {
            id = 287081,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            pvptalent = "lichborne",

            startsCombat = false,
            texture = 136187,

            handler = function ()
                applyBuff( "lichborne" )
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

            handler = function ()
                removeStack( "inexorable_assault" )
                applyDebuff( "target", "razorice", nil, debuff.razorice.stack + 1 )
            end,
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
            cooldown = 45,
            gcd = "spell",

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


        remorseless_winter = {
            id = 196770,
            cast = 0,
            cooldown = function () return pvptalent.dead_of_winter.enabled and 45 or 20 end,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = false,
            texture = 538770,

            handler = function ()
                applyBuff( "remorseless_winter" )
                -- if pvptalent.deathchill.enabled then applyDebuff( "target", "deathchill" ) end
            end,
        },


        transfusion = {
            id = 288977,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = -20,
            spendType = "runic_power",

            startsCombat = false,
            texture = 237515,

            pvptalent = "transfusion",

            handler = function ()
                applyBuff( "transfusion" )
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

        potion = "potion_of_unbridled_fury",

        package = "Frost DK",
    } )


    spec:RegisterSetting( "bos_rp", 50, {
        name = "Runic Power for |T1029007:0|t Breath of Sindragosa",
        desc = "The addon will not recommend |T1029007:0|t Breath of Sindragosa only if you have this much Runic Power (or more).",
        icon = 1029007,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 16,
        max = 100,
        step = 1,
        width = 1.5
    } )


    spec:RegisterPack( "Frost DK", 20190920, [[dGu3ccqirv9irrztIuJIIYPOOAvII0ROGMffYTasv2fHFjsAyIQCmvfltuPNrbmnkqUMOuBtue9nGuPXjkcNdiLwhqkyEaX9uvTprfheivvluu4HaPqteifXfbsrTrrrLtcKkALqIxkkQs3uuuf2jfQFkkQIgkqQklvuuv9uiMQiXxffvL9s0FrzWu6WuTyapgvtwjxgzZK8zLYObQtlz1aPcVgsA2K62kv7wLFRy4I44uGA5s9Cqtx46QY2bs(oKA8aPiDEvLwVOK5tr2pul)itrIS8GKgNBEFaT5bAZnprEGwdyadktkrIVjKejX5O6BKe58DsIK56bgylOjzELij(x94lzkse48Aojrahrce0qQPUvb4hGGp7PcR9N2JAoE7QivyTZtvIa8kDa68KasKLhK04CZ7dOnpqBU5jYd0AadyqFKi(lapTebP2bnkraxRfDsajYIGCjsMHTzUEGb2cAc5bySnZ7vBGdmkzg2coIeiOHutDRcWpabF2tfw7pTh1C82vrQWANNkgLmdBrOKG2bOgBZnpJW2CZ7dOfJcgLmdBbnc2VnccAaJsMHTGEylOZJRFlcBZ8OUf2M5AIYIeyuYmSf0dBb9VwyRY1AaNJk2QMgBFW62WwqZz(Z8ze2c6BYCyBPW2eT)LASTUkkpii2MXGGTaKAAcBtMrx3g2QNTIJTfeB5ZEIMcAjWOKzylOh2cAeSFBe2gEVrHiQDIfdBve2gd2g1oXIHTkcBJbBFqcBPJpVlOgB10TfGX22dWuJTby)W2KjOlkxJTr7qWy7I8amuir0fmGYuKi8rVyGjVdzksJ)itrIqNdOPLmdjcVRG6YLiapLsWh9IbM8oeWW5OIT5GTzJTPX2O2jwmSvryliy7gFjrCEuZjr4G96GSrXkojdPX5ktrIqNdOPLmdjcVRG6YLiMHTapLsajkax3gR9ns00UxheBbbB34lS1CSnn2c8ukbKOaCDBS23iXlrI48OMtIWb71bzJIvCsgsJnGmfjcDoGMwYmKi8UcQlxIyg2c8ukrsP1EZgft1dmenT71bXwq(X2n(cBZuS1mS9d2Ai2YNrVg0Nq1dmq)T3Hm1R)kAYxFXwZXwtMWwGNsjskT2B2OyQEGHOPDVoi2cc22VJerTtSyygaBnhBtJTapLsKuAT3SrXu9adXlbBtJTMHTEwuxbjk(xgVcFrAr7hQyli)y7hS1KjSf4PucGM8amBumyDR23gOlEjyR5seNh1CseoyVoiBuSItYqASbjtrIqNdOPLmdjcVRG6YLiapLsKuAT3SrXu9adrt7EDqSfeSntGTPXwGNsjEh4r)LbJMUTaSOPDVoi2cc2UXxyBMITMHTFWwdXw(m61G(eQEGb6V9oKPE9xrt(6l2Ao2MgBbEkL4DGh9xgmA62cWIM296GyBASf4PuIKsR9MnkMQhyiEjyBAS1mS1ZI6kirX)Y4v4lslA)qfBb5hB)GTMmHTapLsa0KhGzJIbRB1(2aDXlbBnxI48OMtIWb71bzJIvCsgsJZwMIeHohqtlzgseExb1LlrmdBbEkLO4Fz8k8fPfnT71bXwqWwdcBnzcBbEkLO4Fz8k8fPfnT71bXwqW2(DKiQDIfdZayR5yBASf4PuII)LXRWxKw8sW20yRNf1vqII)LXRWxKw0(Hk2MZp2Ml2MgBZhBbEkLaOjpaZgfdw3Q9Tb6IxIeX5rnNeHd2RdYgfR4KmKgNjLPirOZb00sMHeH3vqD5seGNsjk(xgVcFrAXlbBtJTapLs8oWJ(ldgnDBbyXlbBtJTEwuxbjk(xgVcFrAr7hQyBo)yBUyBASnFSf4PucGM8amBumyDR23gOlEjseNh1CseoyVoiBuSItYqgsKbqxb1EuZjtrA8hzkse6CanTKzir4DfuxUejCnDHyZdWux3gdgtVlOZb00sI48OMtI00(0qstqidDDb1YqACUYuKi05aAAjZqI48OMtIma6kO2dsIW7kOUCjIzy7IaEkLO9SMU4KagohvSfeSnBS1KjSDrapLs0EwtxCs00UxheBbbB)Kh2Ao2MgBZhBdxtxiu9adi)BaMe05aAAHTPX28XwGNsj6ANeVeSnn2ctiTMfEVrbuaEqRRBJbODyGT58JTgqIW)Y1el8EJcO04pYqASbKPirOZb00sMHeH3vqD5sK8X2W10fcvpWaY)gGjbDoGMwyBASnFSf4PuIU2jXlbBtJTWesRzH3BuafGh0662yaAhgyBo)yRbKiopQ5KidGUcQ9GKH0ydsMIeHohqtlzgseExb1LlrmdBbEkLa1sRRBJT7CW1rIMCEGTMmHTMHTapLsGAP11TX2Do46iXlbBtJTMHTjnbk2gFj(iu9adgm6cvcBnzcBtAcuSn(s8raEqRRBJbODyGTMmHTjnbk2gFj(i20oVCnZxGYpoHTMJTMJTMJTPXwycP1SW7nkGcvpWaY)gGjSnNFSnxjIZJAojIQhya5FdWKmKgNTmfjcDoGMwYmKiopQ5KidGUcQ9GKi8UcQlxIyg2UiGNsjApRPlojGHZrfBbbBZgBnzcBxeWtPeTN10fNenT71bXwqW2p5HTMJTPXwGNsjqT0662y7ohCDKOjNhyRjtyRzylWtPeOwADDBSDNdUos8sW20yRzyBstGITXxIpcvpWGbJUqLWwtMW2KMafBJVeFeGh0662yaAhgyRjtyBstGITXxIpInTZlxZ8fO8JtyR5yR5se(xUMyH3BuaLg)rgsJZKYuKi05aAAjZqIW7kOUCjcWtPeOwADDBSDNdUos0KZdS1KjS1mSf4PuculTUUn2UZbxhjEjyBAS1mSnPjqX24lXhHQhyWGrxOsyRjtyBstGITXxIpcWdADDBmaTddS1KjSnPjqX24lXhXM25LRz(cu(XjS1CS1CjIZJAojYaORGApizing0vMIeHohqtlzgseExb1LlrmdBZhBbEkLORDs8sWwtMW2(DfNLmOPwSivXRaBbbB)Kh2AYe22VJerTtSyy5IT5GTB8f2Ao2MgBHjKwZcV3Oak20oVCnZxGYpoHT58JT5krCEuZjr20oVCnZxGYpojdPXzczkse6CanTKzir4DfuxUeb4PuIU2jXlbBtJTWesRzH3BuafGh0662yaAhgyBo)yBUseNh1CseWdADDBmaTddzing0ktrIqNdOPLmdjIZJAojIQhyWGrxOsseExb1LlrmdBxeWtPeTN10fNeWW5OITGGTzJTMmHTlc4PuI2ZA6ItIM296Gyliy7N8WwZX20yB(ylWtPeDTtIxc2AYe22VR4SKbn1IfPkEfyliy7N8WwtMW2(DKiQDIfdlxSnhSDJVW20yB(yB4A6cHQhya5FdWKGohqtljc)lxtSW7nkGsJ)idPXFYtMIeHohqtlzgseExb1LlrYhBbEkLORDs8sWwtMW2(DfNLmOPwSivXRaBbbB)Kh2AYe22VJerTtSyy5IT5GTB8LeX5rnNer1dmyWOlujzin(Zhzkse6CanTKzir4DfuxUeb4PuIU2jXlrI48OMtIaEqRRBJbODyidPXFYvMIeHohqtlzgseNh1CsKbqxb1EqseExb1LlrmdBxeWtPeTN10fNeWW5OITGGTzJTMmHTlc4PuI2ZA6ItIM296Gyliy7N8WwZX20yB(yB4A6cHQhya5FdWKGohqtljc)lxtSW7nkGsJ)idPXFmGmfjIZJAojYaORGApijcDoGMwYmKHmKiadKffh162KPin(JmfjcDoGMwYmKi8UcQlxIWNrVg0NG2tg0uZ63rm0KNmNOPDVoOeX5rnNejP0AVzJIP6bgYqACUYuKiopQ5Ki0EYGMAw)oIHM8K5Ki05aAAjZqgsJnGmfjcDoGMwYmKiopQ5KidGUcQ9GKi8UcQlxIyg2UiGNsjApRPlojGHZrfBbbBZgBnzcBxeWtPeTN10fNenT71bXwqW2p5HTMJTPX2(DfNLmOPgBb5hBnqEyBASnFSnCnDHq1dmG8VbysqNdOPLeH)LRjw49gfqPXFKH0ydsMIeHohqtlzgseExb1Llr63vCwYGMASfKFS1a5krCEuZjrgaDfu7bjdPXzltrIqNdOPLmdjcVRG6YLiHRPleBEaM662yWy6DbDoGMwseNh1CsKM2NgsAcczORlOwgsJZKYuKi05aAAjZqIW7kOUCjcWtPeDTtIxIeX5rnNeb8Gwx3gdq7WqgsJbDLPirOZb00sMHeX5rnNeza0vqThKeH3vqD5seZW2fb8ukr7znDXjbmCoQyliyB2yRjty7IaEkLO9SMU4KOPDVoi2cc2(jpS1CSnn22VJerTtSyyzJTGGTB8f2AYe22VR4SKbn1yli)yRbLn2MgBZhBdxtxiu9adi)BaMe05aAAjr4F5AIfEVrbuA8hzinotitrIqNdOPLmdjcVRG6YLi97iru7elgw2yliy7gFHTMmHT97kolzqtn2cYp2AqzlrCEuZjrgaDfu7bjdPXGwzkse6CanTKzir4DfuxUeb4PuculTUUn2UZbxhjEjyBASfMqAnl8EJcOq1dmG8VbycBZ5hBZvI48OMtIO6bgq(3amjdPXFYtMIeHohqtlzgseExb1Llr63vCwYGMAXIufVcSnNFS1a5ITPX2(DKiQDIfdZayBoy7gFjrCEuZjrap9XgfdDDb1YqA8NpYuKiopQ5KinTpnK0eeYqxxqTeHohqtlzgYqA8NCLPirOZb00sMHeH3vqD5seycP1SW7nkGcvpWaY)gGjSnNFSnxjIZJAojIQhya5FdWKmKg)XaYuKi05aAAjZqI48OMtIma6kO2dsIW7kOUCjIzy7IaEkLO9SMU4KagohvSfeSnBS1KjSDrapLs0EwtxCs00UxheBbbB)Kh2Ao2MgB73vCwYGMAXIufVcSnhSn3SXwtMW2(De2Md2AaSnn2Mp2gUMUqO6bgq(3amjOZb00sIW)Y1el8EJcO04pYqA8hdsMIeHohqtlzgseExb1Llr63vCwYGMAXIufVcSnhSn3SXwtMW2(De2Md2AajIZJAojYaORGApizin(t2YuKi05aAAjZqIW7kOUCjs)UIZsg0ulwKQ4vGT5GT5MNeX5rnNeXBUFelMUPlKHmKi8z0Rb9bLPin(JmfjcDoGMwYmKiopQ5KiEwqWE7qMAUGnkwYGMAjcVRG6YLiMHT8z0Rb9jO9Kbn1S(Dedn5jZjAYxFX20yB(ylO8UCanjMam1S5ypiXid(vjj0cBnhBnzcBndB5ZOxd6tKuAT3SrXu9adrt7EDqSfKFS9tEyBASfuExoGMetaMA2CShKyKb)QKeAHTMlroFNKiEwqWE7qMAUGnkwYGMAzinoxzkse6CanTKzirCEuZjr0VgvQHS6G1QMhKTvQqIW7kOUCjs4A6cbqtEaMnkgSUv7Bd0f05aAAHTPXwZWwZWw(m61G(ejLw7nBumvpWq00UxheBb5hB)Kh2MgBbL3LdOjXeGPMnh7bjgzWVkjHwyR5yRjtyRzylWtPejLw7nBumvpWq8sW20yB(ylO8UCanjMam1S5ypiXid(vjj0cBnhBnhBnzcBndBbEkLiP0AVzJIP6bgIxc2MgBZhBdxtxiaAYdWSrXG1TAFBGUGohqtlS1CjY57Ker)AuPgYQdwRAEq2wPczin2aYuKi05aAAjZqI48OMtIW)Y1t0ZvCgG2HHeH3vqD5sK8XwGNsjskT2B2OyQEGH4LiroFNKi8VC9e9CfNbODyidPXgKmfjcDoGMwYmKi8UcQlxIyg2YNrVg0NiP0AVzJIP6bgIM81xS1KjSLpJEnOprsP1EZgft1dmenT71bX2CW2CZdBnhBtJTMHT5JTHRPlean5by2OyW6wTVnqxqNdOPf2AYe2YNrVg0NG2tg0uZ63rm0KNmNOPDVoi2Md2cAZgBnxI48OMtI8GeRcAhkdPXzltrIqNdOPLmdjIZJAojIdbdk)iiR9SMMXN21seExb1LlrweWtPeTN10m(0UMTiGNsjwd6tIC(ojrCiyq5hbzTN10m(0UwgsJZKYuKi05aAAjZqI48OMtI4qWGYpcYApRPz8PDTeH3vqD5se(m61G(e0EYGMAw)oIHM8K5enT71bX2CWwqBEyBASDrapLs0EwtZ4t7A2IaEkL4LGTPXwq5D5aAsmbyQzZXEqIrg8RssOf2AYe2c8ukbqtEaMnkgSUv7Bd0fVeSnn2UiGNsjApRPz8PDnBrapLs8sW20yB(ylO8UCanjMam1S5ypiXid(vjj0cBnzcBbEkLG2tg0uZ63rm0KNmN4LGTPX2fb8ukr7znnJpTRzlc4PuIxc2MgBZhBdxtxiaAYdWSrXG1TAFBGUGohqtlS1KjSnQDIfdBve2cc2M7hjY57KeXHGbLFeK1EwtZ4t7Azing0vMIeHohqtlzgseNh1CseqheKbEqRPwIW7kOUCjIzylzWVkjHwc9RrLAiRoyTQ5bzBLkW20ylWtPejLw7nBumvpWq00UxheBnhBnzcBndBZhBjd(vjj0sOFnQudz1bRvnpiBRub2MgBbEkLiP0AVzJIP6bgIM296Gyliy7NCX20ylWtPejLw7nBumvpWq8sWwZLiNVtseqheKbEqRPwgsJZeYuKi05aAAjZqI48OMtIG6nbBum)4fDbt96VseExb1Llr4ZOxd6tq7jdAQz97igAYtMt00UxheBZbBnO8KiNVtseuVjyJI5hVOlyQx)vgsJbTYuKi05aAAjZqI48OMtIS1ZTbzjDT7Aw7BKeH3vqD5sK(De2cYp2AaSnn2Mp2c8ukrsP1EZgft1dmeVeSnn2Ag2Mp2c8ukbqtEaMnkgSUv7Bd0fVeS1KjSnFSnCnDHaOjpaZgfdw3Q9Tb6c6CanTWwZLiNVtsKTEUnilPRDxZAFJKH04p5jtrIqNdOPLmdjY57KeP9SwVdvidO2ynTyaViMtI48OMtI0EwR3HkKbuBSMwmGxeZjdPXF(itrIqNdOPLmdjIZJAojYo1eQbyhYu(Tjr4DfuxUejFSf4PucGM8amBumyDR23gOlEjyBASnFSf4PuIKsR9MnkMQhyiEjsKZ3jjYo1eQbyhYu(TjdPXFYvMIeHohqtlzgseExb1LlraEkLiP0AVzJIP6bgIxc2MgBbEkLG2tg0uZ63rm0KNmN4LirCEuZjrsMOMtgsJ)yazkse6CanTKzir4DfuxUeb4PuIKsR9MnkMQhyiEjyBASf4PucApzqtnRFhXqtEYCIxIeX5rnNebqpZIPE9xzin(JbjtrIqNdOPLmdjcVRG6YLiapLsKuAT3SrXu9adXlrI48OMtIaqnKAuRBtgsJ)KTmfjcDoGMwYmKi8UcQlxIWNrVg0NG2tg0uZ63rm0KNmNOPDVoOeX5rnNejP0AVzJIP6bgYqA8NmPmfjcDoGMwYmKi8UcQlxIWNrVg0NG2tg0uZ63rm0KNmNOPDVoi2MgB5ZOxd6tKuAT3SrXu9adrt7EDqjIZJAojcqtEaMnkgSUv7Bd0LipiXgLITXxsKpYqA8hqxzkse6CanTKzir4DfuxUeHpJEnOprsP1EZgft1dmen5RVyBASnFSnCnDHaOjpaZgfdw3Q9Tb6c6CanTW20yB)ose1oXIHLn2Md2UXxyBASTFxXzjdAQflsv8kW2C(X2p5HTMmHTrTtSyyRIWwqW2CZtI48OMtIq7jdAQz97igAYtMtgsJ)KjKPirOZb00sMHeH3vqD5seZWw(m61G(ejLw7nBumvpWq0KV(ITMmHTrTtSyyRIWwqW2CZdBnhBtJTHRPlean5by2OyW6wTVnqxqNdOPf2MgB73vCwYGMASnhSntMNeX5rnNeH2tg0uZ63rm0KNmNmKg)b0ktrIqNdOPLmdjcVRG6YLiHRPle8rVyGjVdbDoGMwyBAS1mS1mSf4Puc(OxmWK3HagohvSnNFS9tEyBASDrapLs0EwtxCsadNJk2(JTzJTMJTMmHTrTtSyyRIWwq(X2n(cBnxI48OMtIWDTM58OMJPlyir0fmyNVtse(OxmWK3HmKgNBEYuKi05aAAjZqIW7kOUCjIzylWtPejLw7nBumvpWq00UxheBb5hB34lS1KjS1mSf4PuIKsR9MnkMQhyiAA3RdITGGTzcSnn2c8ukX7ap6Vmy00TfGfnT71bXwq(X2n(cBtJTapLs8oWJ(ldgnDBbyXlbBnhBnhBtJTapLsKuAT3SrXu9adXlbBtJTEwuxbjk(xgVcFrAr7hQyli)y7hjIZJAojIQhyG(BVdzQx)vgsJZ9JmfjcDoGMwYmKi8UcQlxIyg2c8ukrX)Y4v4lslAA3RdITG8JTB8f2AYe2Ag2c8ukrX)Y4v4lslAA3RdITGGTzcSnn2c8ukX7ap6Vmy00TfGfnT71bXwq(X2n(cBtJTapLs8oWJ(ldgnDBbyXlbBnhBnhBtJTapLsu8VmEf(I0Ixc2MgB9SOUcsu8VmEf(I0I2puX2C(X2CLiopQ5KiQEGb6V9oKPE9xzino3CLPirOZb00sMHeH3vqD5sKO2jwmSvryliy7gFHTMmHTMHTrTtSyyRIWwqWw(m61G(ejLw7nBumvpWq00UxheBtJTapLs8oWJ(ldgnDBbyXlbBnxI48OMtIO6bgO)27qM61FLHmKiadKLmJUUnzksJ)itrIqNdOPLmdjcVRG6YLiapLs01ojEjseNh1CseWdADDBmaTddzinoxzkse6CanTKzirCEuZjrgaDfu7bjr4DfuxUeXmSDrapLs0EwtxCsadNJk2cc2Mn2AYe2UiGNsjApRPlojAA3RdITGGTFYdBnhBtJT97kolzqtTyrQIxb2MZp2MB2yBASnFSnCnDHq1dmG8VbysqNdOPLeH)LRjw49gfqPXFKH0yditrIqNdOPLmdjcVRG6YLi97kolzqtTyrQIxb2MZp2MB2seNh1CsKbqxb1EqYqASbjtrIqNdOPLmdjcVRG6YLi97kolzqtTyrQIxb2cc2MBEyBASfMqAnl8EJcOyt78Y1mFbk)4e2MZp2Ml2MgB5ZOxd6tKuAT3SrXu9adrt7EDqSnhSnBjIZJAojYM25LRz(cu(XjzinoBzkse6CanTKzirCEuZjru9adgm6cvsIW7kOUCjIzy7IaEkLO9SMU4KagohvSfeSnBS1KjSDrapLs0EwtxCs00UxheBbbB)Kh2Ao2MgB73vCwYGMAXIufVcSfeSn38W20yB(yB4A6cHQhya5FdWKGohqtlSnn2YNrVg0NiP0AVzJIP6bgIM296GyBoyB2se(xUMyH3BuaLg)rgsJZKYuKi05aAAjZqIW7kOUCjs)UIZsg0ulwKQ4vGTGGT5Mh2MgB5ZOxd6tKuAT3SrXu9adrt7EDqSnhSnBjIZJAojIQhyWGrxOsYqAmORmfjcDoGMwYmKi8UcQlxIa8ukbQLwx3gB35GRJeVeSnn22VR4SKbn1IfPkEfyBoyRzy7NSXwdX2W10fI(DfN5rq3ZJAobDoGMwyBMITgaBnhBtJTWesRzH3BuafQEGbK)natyBo)yBUseNh1CsevpWaY)gGjzinotitrIqNdOPLmdjcVRG6YLi97kolzqtTyrQIxb2MZp2Ag2AGSXwdX2W10fI(DfN5rq3ZJAobDoGMwyBMITgaBnhBtJTWesRzH3BuafQEGbK)natyBo)yBUseNh1CsevpWaY)gGjzing0ktrIqNdOPLmdjIZJAojYaORGApijcVRG6YLiMHTlc4PuI2ZA6Itcy4CuXwqW2SXwtMW2fb8ukr7znDXjrt7EDqSfeS9tEyR5yBASTFxXzjdAQflsv8kW2C(XwZWwdKn2Ai2gUMUq0VR4mpc6EEuZjOZb00cBZuS1ayR5yBASnFSnCnDHq1dmG8VbysqNdOPLeH)LRjw49gfqPXFKH04p5jtrIqNdOPLmdjcVRG6YLi97kolzqtTyrQIxb2MZp2Ag2AGSXwdX2W10fI(DfN5rq3ZJAobDoGMwyBMITgaBnxI48OMtIma6kO2dsgsJ)8rMIeHohqtlzgseExb1Llr4ZOxd6tKuAT3SrXu9adrt7EDqSnhSTFhjIANyXWmiSnn22VR4SKbn1IfPkEfyliyRbLh2MgBHjKwZcV3Oak20oVCnZxGYpoHT58JT5krCEuZjr20oVCnZxGYpojdPXFYvMIeHohqtlzgseNh1CsevpWGbJUqLKi8UcQlxIyg2UiGNsjApRPlojGHZrfBbbBZgBnzcBxeWtPeTN10fNenT71bXwqW2p5HTMJTPXw(m61G(ejLw7nBumvpWq00UxheBZbB73rIO2jwmmdcBtJT97kolzqtTyrQIxb2cc2Aq5HTPX28X2W10fcvpWaY)gGjbDoGMwse(xUMyH3BuaLg)rgsJ)yazkse6CanTKzir4DfuxUeHpJEnOprsP1EZgft1dmenT71bX2CW2(DKiQDIfdZGW20yB)UIZsg0ulwKQ4vGTGGTguEseNh1CsevpWGbJUqLKHmKijnXNDapKPin(JmfjIZJAojsYe1Cse6CanTKzidPX5ktrIqNdOPLmdjY57KeXZcc2BhYuZfSrXsg0ulrCEuZjr8SGG92Hm1CbBuSKbn1YqASbKPirOZb00sMHezsKiqkKiopQ5KiGY7Yb0KebuU(rseZWwYGFvscTe3etxZdY20(Q8yAidWxBe2AYe2sg8RssOLawxbdQzBAFvEmnKb4RncBnzcBjd(vjj0saRRGb1SnTVkpMgY2PLR11CyRjtylzWVkjHwcqvUMnkMF1Uh0IbONzHTMmHTKb)QKeAjuvdd2UheKbt(UPDieBnzcBjd(vjj0sa6GGmWdAn1yRjtylzWVkjHwIBIPR5bzBAFvEmnKTtlxRR5WwtMWwYGFvscTeoemO8JGS2ZAAgFAxJTMlraL3SZ3jjYeGPMnh7bjgzWVkjHwYqgseFizksJ)itrIqNdOPLmdjcVRG6YLiHRPleBEaM662yWy6DbDoGMwyRjtyRzyRNf1vqcvpzrhlO9ecgI2puX20ylmH0Aw49gfqrt7tdjnbHm01fuJT58JTgaBtJT5JTapLs01ojEjyR5seNh1CsKM2NgsAcczORlOwgsJZvMIeHohqtlzgseExb1Llrcxtxiu9adi)BaMe05aAAjrCEuZjr20oVCnZxGYpojdPXgqMIeHohqtlzgseNh1CsevpWGbJUqLKi8UcQlxIyg2UiGNsjApRPlojGHZrfBbbBZgBnzcBxeWtPeTN10fNenT71bXwqW2p5HTMJTPXw(m61G(enTpnK0eeYqxxqTOPDVoi2cYp2Ml2MPy7gFHTPX2W10fInpatDDBmym9UGohqtlSnn2Mp2gUMUqO6bgq(3amjOZb00sIW)Y1el8EJcO04pYqASbjtrIqNdOPLmdjcVRG6YLi8z0Rb9jAAFAiPjiKHUUGArt7EDqSfKFSnxSntX2n(cBtJTHRPleBEaM662yWy6DbDoGMwseNh1CsevpWGbJUqLKH04SLPirOZb00sMHeH3vqD5seGNsj6ANeVejIZJAojc4bTUUngG2HHmKgNjLPirOZb00sMHeH3vqD5seGNsjqT0662y7ohCDK4LirCEuZjru9adi)BaMKH0yqxzkse6CanTKzir4DfuxUePFxXzjdAQflsv8kWwqWwZW2pzJTgITHRPle97koZJGUNh1Cc6CanTW2mfBna2AUeX5rnNezt78Y1mFbk)4KmKgNjKPirOZb00sMHeX5rnNer1dmyWOlujjcVRG6YLiMHTlc4PuI2ZA6Itcy4CuXwqW2SXwtMW2fb8ukr7znDXjrt7EDqSfeS9tEyR5yBASTFxXzjdAQflsv8kWwqWwZW2pzJTgITHRPle97koZJGUNh1Cc6CanTW2mfBna2Ao2MgBZhBdxtxiu9adi)BaMe05aAAjr4F5AIfEVrbuA8hzing0ktrIqNdOPLmdjcVRG6YLi97kolzqtTyrQIxb2cc2Ag2(jBS1qSnCnDHOFxXzEe098OMtqNdOPf2MPyRbWwZX20yB(yB4A6cHQhya5FdWKGohqtljIZJAojIQhyWGrxOsYqA8N8KPirCEuZjrAAFAiPjiKHUUGAjcDoGMwYmKH04pFKPirCEuZjru9adi)BaMKi05aAAjZqgsJ)KRmfjcDoGMwYmKiopQ5KidGUcQ9GKi8UcQlxIyg2UiGNsjApRPlojGHZrfBbbBZgBnzcBxeWtPeTN10fNenT71bXwqW2p5HTMJTPX2(DfNLmOPwSivXRaBZbBndBZnBS1qSnCnDHOFxXzEe098OMtqNdOPf2MPyRbWwZX20yB(yB4A6cHQhya5FdWKGohqtljc)lxtSW7nkGsJ)idPXFmGmfjcDoGMwYmKi8UcQlxI0VR4SKbn1IfPkEfyBoyRzyBUzJTgITHRPle97koZJGUNh1Cc6CanTW2mfBna2AUeX5rnNeza0vqThKmKg)XGKPirCEuZjr20oVCnZxGYpojrOZb00sMHmKg)jBzkse6CanTKzirCEuZjru9adgm6cvsIW7kOUCjIzy7IaEkLO9SMU4KagohvSfeSnBS1KjSDrapLs0EwtxCs00UxheBbbB)Kh2Ao2MgBZhBdxtxiu9adi)BaMe05aAAjr4F5AIfEVrbuA8hzin(tMuMIeX5rnNer1dmyWOlujjcDoGMwYmKH04pGUYuKiopQ5KiGN(yJIHUUGAjcDoGMwYmKH04pzczkseNh1CseV5(rSy6MUqIqNdOPLmdzidjYIu(thYuKg)rMIeX5rnNezVUft1eLfjrOZb00sMHmKgNRmfjcDoGMwYmKi8UcQlxIKp2UMqO6bgmfbkQfrXrTUnSnn2Ag2Mp2gUMUqa0KhGzJIbRB1(2aDbDoGMwyRjtylFg9AqFcGM8amBumyDR23gOlAA3RdIT5GTFYgBnxI48OMtIaEqRRBJbODyidPXgqMIeHohqtlzgseExb1LlraEkLO4FzHRNdkAA3RdITG8JTB8f2MgBbEkLO4FzHRNdkEjyBASfMqAnl8EJcOyt78Y1mFbk)4e2MZp2Ml2MgBndBZhBdxtxiaAYdWSrXG1TAFBGUGohqtlS1KjSLpJEnOpbqtEaMnkgSUv7Bd0fnT71bX2CW2pzJTMlrCEuZjr20oVCnZxGYpojdPXgKmfjcDoGMwYmKi8UcQlxIa8ukrX)Ycxphu00UxheBb5hB34lSnn2c8ukrX)Ycxphu8sW20yRzyB(yB4A6cbqtEaMnkgSUv7Bd0f05aAAHTMmHT8z0Rb9jaAYdWSrXG1TAFBGUOPDVoi2Md2(jBS1CjIZJAojIQhyWGrxOsYqAC2YuKi05aAAjZqI48OMtIWDTM58OMJPlyir0fmyNVtseccPJtqzinotktrIqNdOPLmdjIZJAojc31AMZJAoMUGHerxWGD(ojr4ZOxd6dkdPXGUYuKi05aAAjZqIW7kOUCjs4A6cbqtEaMnkgSUv7Bd0f05aAAHTPXwZWwZWw(m61G(ean5by2OyW6wTVnqx00UxheB)X28W20ylFg9AqFIKsR9MnkMQhyiAA3RdITGGTFYdBnhBnzcBndB5ZOxd6ta0KhGzJIbRB1(2aDrt7EDqSfeSn38W20yBu7elg2QiSfeS1azJTMJTMlrCEuZjr63XCEuZX0fmKi6cgSZ3jjcWazjZORBtgsJZeYuKi05aAAjZqIW7kOUCjcWtPean5by2OyW6wTVnqx8sKiopQ5Ki97yopQ5y6cgseDbd257KebyGSO4Ow3MmKgdALPirOZb00sMHeH3vqD5seGNsjskT2B2OyQEGH4LGTPX2W10fIbqxb1EuZjOZb00sI48OMtI0VJ58OMJPlyir0fmyNVtsKbqxb1EuZjdPXFYtMIeHohqtlzgseExb1LlrCEuGIy0r7fbX2C(X2CLiopQ5Ki97yopQ5y6cgseDbd257KeXhsgsJ)8rMIeHohqtlzgseNh1CseUR1mNh1CmDbdjIUGb78DsIad)wEVKHmKiWWVL3lzksJ)itrI48OMtI00(0qstqidDDb1se6CanTKzidPX5ktrIqNdOPLmdjcVRG6YLi8z0Rb9jAAFAiPjiKHUUGArt7EDqSfKFSnxSntX2n(cBtJTHRPleBEaM662yWy6DbDoGMwseNh1CsevpWGbJUqLKH0yditrIqNdOPLmdjcVRG6YLiapLs01ojEjseNh1CseWdADDBmaTddzin2GKPirOZb00sMHeH3vqD5sK8XwGNsju9KfDSKNgsIxc2MgBdxtxiu9KfDSKNgsc6CanTKiopQ5KidGUcQ9GKH04SLPirOZb00sMHeH3vqD5sK(DfNLmOPwSivXRaBbbBndB)Kn2Ai2gUMUq0VR4mpc6EEuZjOZb00cBZuS1ayR5seNh1CsevpWGbJUqLKH04mPmfjcDoGMwYmKi8UcQlxIa8ukbQLwx3gB35GRJeVeSnn22VJerTtSyyge2MZp2UXxseNh1CsevpWaY)gGjzing0vMIeHohqtlzgseExb1Llr63vCwYGMAXIufVcSnhS1mSn3SXwdX2W10fI(DfN5rq3ZJAobDoGMwyBMITgaBnxI48OMtIma6kO2dsgsJZeYuKiopQ5KiQEGbdgDHkjrOZb00sMHmKgdALPirCEuZjrap9XgfdDDb1se6CanTKzidPXFYtMIeX5rnNeXBUFelMUPlKi05aAAjZqgYqIqqiDCcktrA8hzkse6CanTKzir4DfuxUeb4PuIKsR9MnkMQhyiAA3RdITGGTFYdBtJTapLsa0KhGzJIbRB1(2aDXlbBnzcBbEkLiP0AVzJIP6bgIM296Gyliy7N8W20yB(yB4A6cbqtEaMnkgSUv7Bd0f05aAAjrCEuZjra0ZSyJIfGjgD0(xzinoxzkseNh1CsKTN3RYp2OyEwupbyjcDoGMwYmKH0yditrIqNdOPLmdjcVRG6YLiapLsKuAT3SrXu9adrt7EDqSfeSnBSnn2c8ukrsP1EZgft1dmeVeS1KjSnQDIfdBve2cc2MTeX5rnNeHdU0AgmAYrvgsJnizkse6CanTKzir4DfuxUeb4PuIM4OQjiKPMMtIxc2AYe2c8ukrtCu1eeYutZjgFExqTagohvSfeS9ZhjIZJAojsaMyVdyE3IPMMtYqAC2YuKi05aAAjZqIW7kOUCjs(ylWtPejLw7nBumvpWq8sW20yB(ylWtPean5by2OyW6wTVnqx8sKiopQ5KiQH)G0I5zrDfedG8DzinotktrIqNdOPLmdjcVRG6YLi5JTapLsKuAT3SrXu9adXlbBtJT5JTapLsa0KhGzJIbRB1(2aDXlbBtJTRje8540fTh0IP0(oXaE9jAA3RdIT)yBEseNh1Cse(CC6I2dAXuAFNKH0yqxzkse6CanTKzir4DfuxUejFSf4PuIKsR9MnkMQhyiEjyBASnFSf4PucGM8amBumyDR23gOlEjseNh1CsKKxxQV1TXa0omKH04mHmfjcDoGMwYmKi8UcQlxIKp2c8ukrsP1EZgft1dmeVeSnn2Mp2c8ukbqtEaMnkgSUv7Bd0fVejIZJAojc6P1lqr1XAcoNFCsgsJbTYuKi05aAAjZqIW7kOUCjs(ylWtPejLw7nBumvpWq8sW20yB(ylWtPean5by2OyW6wTVnqx8sKiopQ5KiDLKOjwDmyIZjzin(tEYuKi05aAAjZqIW7kOUCjcWtPe0EYGMAw)oIHM8K5enT71bXwqW2SX20ylWtPean5by2OyW6wTVnqx8sWwtMWwZW2(DKiQDIfdlxSnhSDJVW20yB)UIZsg0uJTGGTzNh2AUeX5rnNezN2N(lBum9Jxl2QjFhkdzidjcOOgwZjno38(aAZlt8jti(KB2se0EF1TbLiGo3tMoOf2(jpS15rnh2QlyafyuKij9OknjrYmSnZ1dmWwqtipaJTzEVAdCGrjZWwWrKabnKAQBva(bi4ZEQWA)P9OMJ3Uksfw78uXOKzylcLe0oa1yBU5ze2MBEFaTyuWOKzylOrW(TrqqdyuYmSf0dBbDEC9BryBMh1TW2mxtuwKaJsMHTGEylO)1cBvUwd4CuXw10y7dw3g2cAoZFMpJWwqFtMdBlf2MO9VuJT1vr5bbX2mgeSfGuttyBYm662Ww9SvCSTGylF2t0uqlbgLmdBb9WwqJG9BJW2W7nkerTtSyyRIW2yW2O2jwmSvryBmy7dsylD85Db1yRMUTam22EaMASna7h2MmbDr5ASnAhcgBxKhGHcmkyuYmSf0mOPe)f0cBbi10e2YNDapWwaARoOaBb9Z5usaX2BoqpWEVREAS15rnheBNt)vGrjZWwNh1Cqrst8zhWJFL2HOIrjZWwNh1Cqrst8zhWdd)tvnZcJsMHTopQ5GIKM4ZoGhg(NQ)22Pl8OMdJsMHTiNNabpb22ETWwGNsrlSfgEaXwasnnHT8zhWdSfG2QdIT(TW2KMa9sMiQBdBli2UMJeyuYmS15rnhuK0eF2b8WW)uHNNabpbdgEaXO48OMdksAIp7aEy4FQjtuZHrX5rnhuK0eF2b8WW)uFqIvbTB0570VNfeS3oKPMlyJILmOPgJIZJAoOiPj(Sd4HH)PckVlhqtgD(o9pbyQzZXEqIrg8RssOLrGY1p63mYGFvscTe3etxZdY20(Q8yAidWxBKjtKb)QKeAjG1vWGA2M2xLhtdza(AJmzIm4xLKqlbSUcguZ20(Q8yAiBNwUwxZzYezWVkjHwcqvUMnkMF1Uh0IbONzzYezWVkjHwcv1WGT7bbzWKVBAhcnzIm4xLKqlbOdcYapO1uBYezWVkjHwIBIPR5bzBAFvEmnKTtlxRR5mzIm4xLKqlHdbdk)iiR9SMMXN21MJrbJsMHTGMbnL4VGwylbkQ)ITrTtyBaMWwNhtJTfeBDq5L2b0KaJIZJAo4)EDlMQjklcJsMHTG(ts0FX2mxpWaBZCeOOgB9BHT7EDHxh2c6K)fBtX1ZbXO48OMdA4FQGh0662yaAhggvQ)8xtiu9adMIaf1IO4Ow3wAZYpCnDHaOjpaZgfdw3Q9Tb6c6CanTmzIpJEnOpbqtEaMnkgSUv7Bd0fnT71bZ5t2MJrX5rnh0W)u30oVCnZxGYpozuP(bEkLO4FzHRNdkAA3RdcY)gFLg4PuII)LfUEoO4LKgMqAnl8EJcOyt78Y1mFbk)4uo)5M2S8dxtxiaAYdWSrXG1TAFBGUGohqtltM4ZOxd6ta0KhGzJIbRB1(2aDrt7EDWC(KT5yuCEuZbn8pvvpWGbJUqLmQu)apLsu8VSW1ZbfnT71bb5FJVsd8ukrX)Ycxphu8ssBw(HRPlean5by2OyW6wTVnqxqNdOPLjt8z0Rb9jaAYdWSrXG1TAFBGUOPDVoyoFY2CmkopQ5Gg(Nk31AMZJAoMUGHrNVt)eeshNGyuCEuZbn8pvUR1mNh1CmDbdJoFN(5ZOxd6dIrX5rnh0W)u73XCEuZX0fmm68D6hyGSKz01TzuP(dxtxiaAYdWSrXG1TAFBGUGohqtR0MzgFg9AqFcGM8amBumyDR23gOlAA3Rd(NxA(m61G(ejLw7nBumvpWq00UxheKp5zUjtMXNrVg0NaOjpaZgfdw3Q9Tb6IM296GGKBEPJANyXWwfbIbY2CZXO48OMdA4FQ97yopQ5y6cggD(o9dmqwuCuRBZOs9d8ukbqtEaMnkgSUv7Bd0fVemkopQ5Gg(NA)oMZJAoMUGHrNVt)dGUcQ9OMZOs9d8ukrsP1EZgft1dmeVK0HRPledGUcQ9OMtqNdOPfgfNh1Cqd)tTFhZ5rnhtxWWOZ3PFFiJk1VZJcueJoAViyo)5IrX5rnh0W)u5UwZCEuZX0fmm68D6hg(T8EHrbJIZJAoOWh6VP9PHKMGqg66cQnQu)HRPleBEaM662yWy6DbDoGMwMmzMNf1vqcvpzrhlO9ecgI2putdtiTMfEVrbu00(0qstqidDDb158BG05d8ukrx7K4LyogfNh1CqHpKH)PUPDE5AMVaLFCYOs9hUMUqO6bgq(3amjOZb00cJIZJAoOWhYW)uv9adgm6cvYi(xUMyH3Bua))yuP(nBrapLs0EwtxCsadNJkizBY0IaEkLO9SMU4KOPDVoiiFYZ808z0Rb9jAAFAiPjiKHUUGArt7EDqq(Znt34R0HRPleBEaM662yWy6DbDoGMwPZpCnDHq1dmG8VbysqNdOPfgfNh1CqHpKH)PQ6bgmy0fQKrL6NpJEnOprt7tdjnbHm01fulAA3RdcYFUz6gFLoCnDHyZdWux3gdgtVlOZb00cJIZJAoOWhYW)ubpO11TXa0ommQu)apLs01ojEjyuCEuZbf(qg(NQQhya5FdWKrL6h4PuculTUUn2UZbxhjEjyuCEuZbf(qg(N6M25LRz(cu(XjJk1F)UIZsg0ulwKQ4vaIzFY2WW10fI(DfN5rq3ZJAobDoGMwzQbmhJIZJAoOWhYW)uv9adgm6cvYi(xUMyH3Bua))yuP(nBrapLs0EwtxCsadNJkizBY0IaEkLO9SMU4KOPDVoiiFYZ8097kolzqtTyrQIxbiM9jBddxtxi63vCMhbDppQ5e05aAALPgW805hUMUqO6bgq(3amjOZb00cJIZJAoOWhYW)uv9adgm6cvYOs93VR4SKbn1IfPkEfGy2NSnmCnDHOFxXzEe098OMtqNdOPvMAaZtNF4A6cHQhya5FdWKGohqtlmkopQ5GcFid)tTP9PHKMGqg66cQXO48OMdk8Hm8pvvpWaY)gGjmkopQ5GcFid)tDa0vqThKr8VCnXcV3Oa()XOs9B2IaEkLO9SMU4KagohvqY2KPfb8ukr7znDXjrt7EDqq(KN5P73vCwYGMAXIufVICml3SnmCnDHOFxXzEe098OMtqNdOPvMAaZtNF4A6cHQhya5FdWKGohqtlmkopQ5GcFid)tDa0vqThKrL6VFxXzjdAQflsv8kYXSCZ2WW10fI(DfN5rq3ZJAobDoGMwzQbmhJIZJAoOWhYW)u30oVCnZxGYpoHrX5rnhu4dz4FQQEGbdgDHkze)lxtSW7nkG)FmQu)MTiGNsjApRPlojGHZrfKSnzArapLs0EwtxCs00UxheKp5zE68dxtxiu9adi)BaMe05aAAHrX5rnhu4dz4FQQEGbdgDHkHrX5rnhu4dz4FQGN(yJIHUUGAmkopQ5GcFid)t1BUFelMUPlWOGrjZW2mAYdWy7OWwK6wTVnqhBtMrx3g22t4rnh2cAaBHH3beBZnpi2cqQPjSf0xP1EJTJcBZC9adS1qSnJbbB9MWwhuEPDanHrX5rnhuamqwYm662(bpO11TXa0ommQu)apLs01ojEjyuCEuZbfadKLmJUUnd)tDa0vqThKr8VCnXcV3Oa()XOs9B2IaEkLO9SMU4KagohvqY2KPfb8ukr7znDXjrt7EDqq(KN5P73vCwYGMAXIufVIC(Zn705hUMUqO6bgq(3amjOZb00cJIZJAoOayGSKz01Tz4FQdGUcQ9GmQu)97kolzqtTyrQIxro)5MngfNh1CqbWazjZORBZW)u30oVCnZxGYpozuP(73vCwYGMAXIufVcqYnV0WesRzH3BuafBANxUM5lq5hNY5p308z0Rb9jskT2B2OyQEGHOPDVoyozJrX5rnhuamqwYm662m8pvvpWGbJUqLmI)LRjw49gfW)pgvQFZweWtPeTN10fNeWW5Ocs2MmTiGNsjApRPlojAA3RdcYN8mpD)UIZsg0ulwKQ4vasU5Lo)W10fcvpWaY)gGjbDoGMwP5ZOxd6tKuAT3SrXu9adrt7EDWCYgJIZJAoOayGSKz01Tz4FQQEGbdgDHkzuP(73vCwYGMAXIufVcqYnV08z0Rb9jskT2B2OyQEGHOPDVoyozJrX5rnhuamqwYm662m8pvvpWaY)gGjJk1pWtPeOwADDBSDNdUos8ss3VR4SKbn1IfPkEf5y2NSnmCnDHOFxXzEe098OMtqNdOPvMAaZtdtiTMfEVrbuO6bgq(3amLZFUyuCEuZbfadKLmJUUnd)tv1dmG8VbyYOs93VR4SKbn1IfPkEf58BMbY2WW10fI(DfN5rq3ZJAobDoGMwzQbmpnmH0Aw49gfqHQhya5FdWuo)5IrX5rnhuamqwYm662m8p1bqxb1EqgX)Y1el8EJc4)hJk1Vzlc4PuI2ZA6Itcy4CubjBtMweWtPeTN10fNenT71bb5tEMNUFxXzjdAQflsv8kY53mdKTHHRPle97koZJGUNh1Cc6CanTYudyE68dxtxiu9adi)BaMe05aAAHrX5rnhuamqwYm662m8p1bqxb1EqgvQ)(DfNLmOPwSivXRiNFZmq2ggUMUq0VR4mpc6EEuZjOZb00ktnG5yuCEuZbfadKLmJUUnd)tDt78Y1mFbk)4KrL6NpJEnOprsP1EZgft1dmenT71bZPFhjIANyXWmO097kolzqtTyrQIxbiguEPHjKwZcV3Oak20oVCnZxGYpoLZFUyuCEuZbfadKLmJUUnd)tv1dmyWOlujJ4F5AIfEVrb8)JrL63Sfb8ukr7znDXjbmCoQGKTjtlc4PuI2ZA6ItIM296GG8jpZtZNrVg0NiP0AVzJIP6bgIM296G50VJerTtSyygu6(DfNLmOPwSivXRaedkV05hUMUqO6bgq(3amjOZb00cJIZJAoOayGSKz01Tz4FQQEGbdgDHkzuP(5ZOxd6tKuAT3SrXu9adrt7EDWC63rIO2jwmmdkD)UIZsg0ulwKQ4vaIbLhgfmkzg2M5CTgW5OITXGTpiHTG(MmNrylO5m)z(Ww0GPdBFqQb9QRIYdcITzmiyBst7E8As)vGrX5rnhuamqwuCuRB7pP0AVzJIP6bggvQF(m61G(e0EYGMAw)oIHM8K5enT71bXO48OMdkagilkoQ1Tz4FQ0EYGMAw)oIHM8K5WO48OMdkagilkoQ1Tz4FQdGUcQ9GmI)LRjw49gfW)pgvQFZweWtPeTN10fNeWW5Ocs2MmTiGNsjApRPlojAA3RdcYN8mpD)UIZsg0udYVbYlD(HRPleQEGbK)natc6CanTWO48OMdkagilkoQ1Tz4FQdGUcQ9GmQu)97kolzqtni)gixmkopQ5GcGbYIIJADBg(NAt7tdjnbHm01fuBuP(dxtxi28am11TXGX07c6CanTWO48OMdkagilkoQ1Tz4FQGh0662yaAhggvQFGNsj6ANeVemkopQ5GcGbYIIJADBg(N6aORGApiJ4F5AIfEVrb8)JrL63Sfb8ukr7znDXjbmCoQGKTjtlc4PuI2ZA6ItIM296GG8jpZt3VJerTtSyyzdYgFzYu)UIZsg0udYVbLD68dxtxiu9adi)BaMe05aAAHrX5rnhuamqwuCuRBZW)uhaDfu7bzuP(73rIO2jwmSSbzJVmzQFxXzjdAQb53GYgJIZJAoOayGSO4Ow3MH)PQ6bgq(3amzuP(bEkLa1sRRBJT7CW1rIxsAycP1SW7nkGcvpWaY)gGPC(ZfJIZJAoOayGSO4Ow3MH)PcE6Jnkg66cQnQu)97kolzqtTyrQIxro)gi3097iru7elgMbYzJVWO48OMdkagilkoQ1Tz4FQnTpnK0eeYqxxqngfNh1CqbWazrXrTUnd)tv1dmG8VbyYOs9dtiTMfEVrbuO6bgq(3amLZFUyuCEuZbfadKffh162m8p1bqxb1EqgX)Y1el8EJc4)hJk1Vzlc4PuI2ZA6Itcy4CubjBtMweWtPeTN10fNenT71bb5tEMNUFxXzjdAQflsv8kYj3SnzQFhLJbsNF4A6cHQhya5FdWKGohqtlmkopQ5GcGbYIIJADBg(N6aORGApiJk1F)UIZsg0ulwKQ4vKtUzBYu)okhdGrX5rnhuamqwuCuRBZW)u9M7hXIPB6cJk1F)UIZsg0ulwKQ4vKtU5HrbJsMHTGgh9cBbtEhylFUvf1CqmkopQ5Gc(OxmWK3XphSxhKnkwXjJk1pWtPe8rVyGjVdbmCoQ5KD6O2jwmSvrGSXxyuCEuZbf8rVyGjVdd)tLd2RdYgfR4KrL63mGNsjGefGRBJ1(gjAA3RdcYgFzEAGNsjGefGRBJ1(gjEjyuCEuZbf8rVyGjVdd)tLd2RdYgfR4KrL63mGNsjskT2B2OyQEGHOPDVoii)B8vMA2hd5ZOxd6tO6bgO)27qM61Ffn5RVMBYeWtPejLw7nBumvpWq00UxheK(DKiQDIfdZaMNg4PuIKsR9MnkMQhyiEjPnZZI6kirX)Y4v4lslA)qfK)pMmb8ukbqtEaMnkgSUv7Bd0fVeZXO48OMdk4JEXatEhg(NkhSxhKnkwXjJk1pWtPejLw7nBumvpWq00UxheKmrAGNsjEh4r)LbJMUTaSOPDVoiiB8vMA2hd5ZOxd6tO6bgO)27qM61Ffn5RVMNg4PuI3bE0FzWOPBlalAA3RdMg4PuIKsR9MnkMQhyiEjPnZZI6kirX)Y4v4lslA)qfK)pMmb8ukbqtEaMnkgSUv7Bd0fVeZXO48OMdk4JEXatEhg(NkhSxhKnkwXjJk1VzapLsu8VmEf(I0IM296GGyqMmb8ukrX)Y4v4lslAA3Rdcs)ose1oXIHzaZtd8ukrX)Y4v4lslEjP9SOUcsu8VmEf(I0I2puZ5p305d8ukbqtEaMnkgSUv7Bd0fVemkopQ5Gc(OxmWK3HH)PYb71bzJIvCYOs9d8ukrX)Y4v4lslEjPbEkL4DGh9xgmA62cWIxsAplQRGef)lJxHViTO9d1C(ZnD(apLsa0KhGzJIbRB1(2aDXlbJcgfNh1CqbFg9AqFW)hKyvq7gD(o97zbb7TdzQ5c2OyjdAQnQu)MXNrVg0NG2tg0uZ63rm0KNmNOjF9nD(GY7Yb0KycWuZMJ9GeJm4xLKqlZnzYm(m61G(ejLw7nBumvpWq00UxheK)p5LguExoGMetaMA2CShKyKb)QKeAzogfNh1CqbFg9AqFqd)t9bjwf0UrNVt)6xJk1qwDWAvZdY2kvyuP(dxtxiaAYdWSrXG1TAFBGUGohqtR0MzgFg9AqFIKsR9MnkMQhyiAA3RdcY)N8sdkVlhqtIjatnBo2dsmYGFvscTm3KjZaEkLiP0AVzJIP6bgIxs68bL3LdOjXeGPMnh7bjgzWVkjHwMBUjtMb8ukrsP1EZgft1dmeVK05hUMUqa0KhGzJIbRB1(2aDbDoGMwMJrX5rnhuWNrVg0h0W)uFqIvbTB0570p)lxprpxXzaAhggvQ)8bEkLiP0AVzJIP6bgIxcgfNh1CqbFg9AqFqd)t9bjwf0o0Os9BgFg9AqFIKsR9MnkMQhyiAYxFnzIpJEnOprsP1EZgft1dmenT71bZj38mpTz5hUMUqa0KhGzJIbRB1(2aDbDoGMwMmXNrVg0NG2tg0uZ63rm0KNmNOPDVoyoG2SnhJIZJAoOGpJEnOpOH)P(GeRcA3OZ3PFhcgu(rqw7znnJpTRnQu)lc4PuI2ZAAgFAxZweWtPeRb9HrX5rnhuWNrVg0h0W)uFqIvbTB0570Vdbdk)iiR9SMMXN21gvQF(m61G(e0EYGMAw)oIHM8K5enT71bZb0Mx6fb8ukr7znnJpTRzlc4PuIxsAq5D5aAsmbyQzZXEqIrg8RssOLjtapLsa0KhGzJIbRB1(2aDXlj9IaEkLO9SMMXN21Sfb8ukXljD(GY7Yb0KycWuZMJ9GeJm4xLKqltMaEkLG2tg0uZ63rm0KNmN4LKErapLs0EwtZ4t7A2IaEkL4LKo)W10fcGM8amBumyDR23gOlOZb00YKPO2jwmSvrGK7hmkopQ5Gc(m61G(Gg(N6dsSkODJoFN(bDqqg4bTMAJk1VzKb)QKeAj0VgvQHS6G1QMhKTvQinWtPejLw7nBumvpWq00Uxh0CtMmlFYGFvscTe6xJk1qwDWAvZdY2kvKg4PuIKsR9MnkMQhyiAA3RdcYNCtd8ukrsP1EZgft1dmeVeZXO48OMdk4ZOxd6dA4FQpiXQG2n68D6h1Bc2Oy(Xl6cM61FnQu)8z0Rb9jO9Kbn1S(Dedn5jZjAA3RdMJbLhgfNh1CqbFg9AqFqd)t9bjwf0UrNVt)B9CBqwsx7UM1(gzuP(73rG8BG05d8ukrsP1EZgft1dmeVK0MLpWtPean5by2OyW6wTVnqx8smzk)W10fcGM8amBumyDR23gOlOZb00YCmkopQ5Gc(m61G(Gg(N6dsSkODJoFN(BpR17qfYaQnwtlgWlI5WO48OMdk4ZOxd6dA4FQpiXQG2n68D6FNAc1aSdzk)2mQu)5d8ukbqtEaMnkgSUv7Bd0fVK05d8ukrsP1EZgft1dmeVemkopQ5Gc(m61G(Gg(NAYe1CgvQFGNsjskT2B2OyQEGH4LKg4PucApzqtnRFhXqtEYCIxcgfNh1CqbFg9AqFqd)tfqpZIPE9xJk1pWtPejLw7nBumvpWq8ssd8ukbTNmOPM1VJyOjpzoXlbJIZJAoOGpJEnOpOH)PcqnKAuRBZOs9d8ukrsP1EZgft1dmeVemkzg2M56bgylFg9AqFqmkopQ5Gc(m61G(Gg(NAsP1EZgft1dmmQu)8z0Rb9jO9Kbn1S(Dedn5jZjAA3RdIrX5rnhuWNrVg0h0W)ubAYdWSrXG1TAFBGUrpiXgLITXx)FmQu)8z0Rb9jO9Kbn1S(Dedn5jZjAA3RdMMpJEnOprsP1EZgft1dmenT71bXO48OMdk4ZOxd6dA4FQ0EYGMAw)oIHM8K5mQu)8z0Rb9jskT2B2OyQEGHOjF9nD(HRPlean5by2OyW6wTVnqxqNdOPv6(DKiQDIfdl7C24R097kolzqtTyrQIxro)FYZKPO2jwmSvrGKBEyuCEuZbf8z0Rb9bn8pvApzqtnRFhXqtEYCgvQFZ4ZOxd6tKuAT3SrXu9adrt(6RjtrTtSyyRIaj38mpD4A6cbqtEaMnkgSUv7Bd0f05aAALUFxXzjdAQZjtMhgfNh1CqbFg9AqFqd)tL7AnZ5rnhtxWWOZ3PF(OxmWK3HrL6pCnDHGp6fdm5DiOZb00kTzMb8ukbF0lgyY7qadNJAo)FYl9IaEkLO9SMU4Kagoh1)Sn3KPO2jwmSvrG8VXxMJrX5rnhuWNrVg0h0W)uv9ad0F7Dit96VgvQFZaEkLiP0AVzJIP6bgIM296GG8VXxMmzgWtPejLw7nBumvpWq00UxheKmrAGNsjEh4r)LbJMUTaSOPDVoii)B8vAGNsjEh4r)LbJMUTaS4LyU5PbEkLiP0AVzJIP6bgIxsAplQRGef)lJxHViTO9dvq()GrX5rnhuWNrVg0h0W)uv9ad0F7Dit96VgvQFZaEkLO4Fz8k8fPfnT71bb5FJVmzYmGNsjk(xgVcFrArt7EDqqYePbEkL4DGh9xgmA62cWIM296GG8VXxPbEkL4DGh9xgmA62cWIxI5MNg4PuII)LXRWxKw8ss7zrDfKO4Fz8k8fPfTFOMZFUyuCEuZbf8z0Rb9bn8pvvpWa93EhYuV(RrL6pQDIfdBveiB8LjtMf1oXIHTkce(m61G(ejLw7nBumvpWq00UxhmnWtPeVd8O)YGrt3waw8smhJcgfNh1CqbbH0Xj4pGEMfBuSamXOJ2)AuP(bEkLiP0AVzJIP6bgIM296GG8jV0apLsa0KhGzJIbRB1(2aDXlXKjGNsjskT2B2OyQEGHOPDVoiiFYlD(HRPlean5by2OyW6wTVnqxqNdOPfgfNh1CqbbH0XjOH)PU98Ev(XgfZZI6jaJrX5rnhuqqiDCcA4FQCWLwZGrtoQgvQFGNsjskT2B2OyQEGHOPDVoiizNg4PuIKsR9MnkMQhyiEjMmf1oXIHTkcKSXO48OMdkiiKoobn8p1amXEhW8UftnnNmQu)apLs0ehvnbHm10Cs8smzc4PuIM4OQjiKPMMtm(8UGAbmCoQG85dgfNh1CqbbH0XjOH)PQg(dslMNf1vqmaY3nQu)5d8ukrsP1EZgft1dmeVK05d8ukbqtEaMnkgSUv7Bd0fVemkopQ5GcccPJtqd)tLphNUO9GwmL23jJk1F(apLsKuAT3SrXu9adXljD(apLsa0KhGzJIbRB1(2aDXlj9AcbFooDr7bTykTVtmGxFIM296G)5HrX5rnhuqqiDCcA4FQjVUuFRBJbODyyuP(Zh4PuIKsR9MnkMQhyiEjPZh4PucGM8amBumyDR23gOlEjyuCEuZbfeeshNGg(Nk6P1lqr1XAcoNFCYOs9NpWtPejLw7nBumvpWq8ssNpWtPean5by2OyW6wTVnqx8sWO48OMdkiiKoobn8p1Uss0eRogmX5KrL6pFGNsjskT2B2OyQEGH4LKoFGNsjaAYdWSrXG1TAFBGU4LGrX5rnhuqqiDCcA4FQ70(0FzJIPF8AXwn57qJk1pWtPe0EYGMAw)oIHM8K5enT71bbj70apLsa0KhGzJIbRB1(2aDXlXKjZ63rIO2jwmSCZzJVs3VR4SKbn1GKDEMJrbJsMHTzEcORGApQ5W2EcpQ5WO48OMdkgaDfu7rn3Ft7tdjnbHm01fuBuP(dxtxi28am11TXGX07c6CanTWO48OMdkgaDfu7rnNH)Poa6kO2dYi(xUMyH3Bua))yuP(nBrapLs0EwtxCsadNJkizBY0IaEkLO9SMU4KOPDVoiiFYZ805hUMUqO6bgq(3amjOZb00kD(apLs01ojEjPHjKwZcV3OakapO11TXa0omY53ayuCEuZbfdGUcQ9OMZW)uhaDfu7bzuP(ZpCnDHq1dmG8VbysqNdOPv68bEkLORDs8ssdtiTMfEVrbuaEqRRBJbODyKZVbWO48OMdkgaDfu7rnNH)PQ6bgq(3amzuP(nd4PuculTUUn2UZbxhjAY5HjtMb8ukbQLwx3gB35GRJeVK0ML0eOyB8L4Jq1dmyWOlujtMsAcuSn(s8raEqRRBJbODyyYustGITXxIpInTZlxZ8fO8JtMBU5PHjKwZcV3Oaku9adi)BaMY5pxmkopQ5GIbqxb1EuZz4FQdGUcQ9GmI)LRjw49gfW)pgvQFZweWtPeTN10fNeWW5Ocs2MmTiGNsjApRPlojAA3RdcYN8mpnWtPeOwADDBSDNdUos0KZdtMmd4PuculTUUn2UZbxhjEjPnlPjqX24lXhHQhyWGrxOsMmL0eOyB8L4Ja8Gwx3gdq7WWKPKMafBJVeFeBANxUM5lq5hNm3CmkopQ5GIbqxb1EuZz4FQdGUcQ9GmQu)apLsGAP11TX2Do46irtopmzYmGNsjqT0662y7ohCDK4LK2SKMafBJVeFeQEGbdgDHkzYustGITXxIpcWdADDBmaTddtMsAcuSn(s8rSPDE5AMVaLFCYCZXO48OMdkgaDfu7rnNH)PUPDE5AMVaLFCYOs9Bw(apLs01ojEjMm1VR4SKbn1IfPkEfG8jptM63rIO2jwmSCZzJVmpnmH0Aw49gfqXM25LRz(cu(XPC(ZfJIZJAoOya0vqTh1Cg(Nk4bTUUngG2HHrL6h4PuIU2jXljnmH0Aw49gfqb4bTUUngG2Hro)5IrX5rnhuma6kO2JAod)tv1dmyWOlujJ4F5AIfEVrb8)JrL63Sfb8ukr7znDXjbmCoQGKTjtlc4PuI2ZA6ItIM296GG8jpZtNpWtPeDTtIxIjt97kolzqtTyrQIxbiFYZKP(DKiQDIfdl3C24R05hUMUqO6bgq(3amjOZb00cJIZJAoOya0vqTh1Cg(NQQhyWGrxOsgvQ)8bEkLORDs8smzQFxXzjdAQflsv8ka5tEMm1VJerTtSyy5MZgFHrX5rnhuma6kO2JAod)tf8Gwx3gdq7WWOs9d8ukrx7K4LGrX5rnhuma6kO2JAod)tDa0vqThKr8VCnXcV3Oa()XOs9B2IaEkLO9SMU4KagohvqY2KPfb8ukr7znDXjrt7EDqq(KN5PZpCnDHq1dmG8VbysqNdOPfgfNh1CqXaORGApQ5m8p1bqxb1EqyuWOKzyls43Y7f2cRBttGEH3BuGT9eEuZHrX5rnhuad)wEV(BAFAiPjiKHUUGAmkopQ5Gcy43Y7LH)PQ6bgmy0fQKrL6NpJEnOprt7tdjnbHm01fulAA3RdcYFUz6gFLoCnDHyZdWux3gdgtVlOZb00cJIZJAoOag(T8Ez4FQGh0662yaAhggvQFGNsj6ANeVemkopQ5Gcy43Y7LH)Poa6kO2dYOs9NpWtPeQEYIowYtdjXljD4A6cHQNSOJL80qsqNdOPfgfNh1Cqbm8B59YW)uv9adgm6cvYOs93VR4SKbn1IfPkEfGy2NSnmCnDHOFxXzEe098OMtqNdOPvMAaZXO48OMdkGHFlVxg(NQQhya5FdWKrL6h4PuculTUUn2UZbxhjEjP73rIO2jwmmdkN)n(cJIZJAoOag(T8Ez4FQdGUcQ9GmQu)97kolzqtTyrQIxroMLB2ggUMUq0VR4mpc6EEuZjOZb00ktnG5yuCEuZbfWWVL3ld)tv1dmyWOlujmkopQ5Gcy43Y7LH)PcE6Jnkg66cQXO48OMdkGHFlVxg(NQ3C)iwmDtxirGjexACUz)rgYqkb]] )
    

end
