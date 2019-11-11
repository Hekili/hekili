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


    spec:RegisterPack( "Frost DK", 20191111, [[dGK(ccqirvEKOOSjrQrrr5uuuTkrr6vuGzrbDlGuLDr4xIKgMOQoMQWYev6zuKmnks11eLSnrr03asrJtueohqQSoGuO5be3tvAFIkoiqQQwOOWdbsbteiLWfbsjTrrrLtcKszLqIxkkQs3uuuf2jfXpffvrdfivLLkkQQEketvK4RIIQYEj6VOmykDyQwmGhJQjRKlJSzs(Ssz0a1PLSAGuQEnK0Sj1TvQ2Tk)wXWfXXPiLLl1ZbnDHRRQ2oqY3HuJhiLOZRkA9IsnFk0(HA5dzksKLhK0KCZ)bO7XJhpepEKvMWuzsjs8mHKijohvFJKiNVtsKmxpWaBbTiZRejXFQhFjtrIaNFZjjc4isGGgtn1Tka)be8zpvyT)1EuZXBxfPcRDEQseGFPdqBNeqIS8GKMKB(paDpE84H4XJSanZ)HeX)b4PLii1oObjc4ATOtcirweKlrYmSnZ1dmWwqlipaJTzEVAdCGrjZWwWrKabnMAQBva(di4ZEQWA)R9OMJ3Uksfw78uXOKzylcLe0oa1yBU5Bi2MB(paDyuWOKzylObW(TrqqJyuYmSf0dBbTDC9FryBMh1TW2mxtu2KaJsMHTGEylO)1cBvUwd4CuXw10y7hw3g2cAnZFMpdXwqFtMdBlf2MO9NuJT1vr5bbX2mgeSfGuttyBYm662Ww9SvCSTGylF2t0uqlbgLmdBb9WwqdG9BJW2W7nkerTtSyyRIW2yW2O2jwmSvryBmy7hsylD85Fb1yRMUTam22EaMASna7h2MmbDr5ASnAhcgBxKhGHcjIUGbuMIeHp6fdm5DitrAYdzkse6CanTKzir4DfuxUeb4Ruc(OxmWK3HagohvSnhSnlSnn2g1oXIHTkcBbbB34ljIZJAojchSxhKnkwXjzinjxzkse6CanTKzir4DfuxUeXmSf4Rucirb462yTVrIM296Gyliy7gFHTMJTPXwGVsjGefGRBJ1(gj(jseNh1CseoyVoiBuSItYqAIPKPirOZb00sMHeH3vqD5seZWwGVsjskT2B2OyQEGHOPDVoi2cYl2UXxyBMITMHTpWwdWw(m61G(eQEGb6N9oKP(9trt(6j2Ao2A0i2c8vkrsP1EZgft1dmenT71bXwqW2(FKiQDIfdZuyR5yBASf4RuIKsR9MnkMQhyi(jyBAS1mS1ZM6kirXFY4v4lslA)qfBb5fBFGTgnITaFLsa0KhGzJIbRB1(2aDXpbBnxI48OMtIWb71bzJIvCsgstmDzkse6CanTKzir4DfuxUeb4RuIKsR9MnkMQhyiAA3RdITGGTzcSnn2c8vkX)ap6Nmy00TfGfnT71bXwqW2n(cBZuS1mS9b2Aa2YNrVg0Nq1dmq)S3Hm1VFkAYxpXwZX20ylWxPe)d8OFYGrt3waw00UxheBtJTaFLsKuAT3SrXu9adXpbBtJTMHTE2uxbjk(tgVcFrAr7hQyliVy7dS1OrSf4RucGM8amBumyDR23gOl(jyR5seNh1CseoyVoiBuSItYqAswYuKi05aAAjZqIW7kOUCjIzylWxPef)jJxHViTOPDVoi2cc2A6yRrJylWxPef)jJxHViTOPDVoi2cc22)JerTtSyyMcBnhBtJTaFLsu8NmEf(I0IFc2MgB9SPUcsu8NmEf(I0I2puX2CEX2CX20yBEylWxPean5by2OyW6wTVnqx8tKiopQ5KiCWEDq2OyfNKH0KmPmfjcDoGMwYmKi8UcQlxIa8vkrXFY4v4lsl(jyBASf4RuI)bE0pzWOPBlal(jyBAS1ZM6kirXFY4v4lslA)qfBZ5fBZfBtJT5HTaFLsa0KhGzJIbRB1(2aDXprI48OMtIWb71bzJIvCsgYqIma6kO2JAozkstEitrIqNdOPLmdjcVRG6YLiHRPleBEaM662yWy6DbDoGMwseNh1CsKM2NgsAcczORlOwgstYvMIeHohqtlzgseNh1CsKbqxb1EqseExb1LlrmdBxeWxPeTN90fNeWW5OITGGTzHTgnITlc4RuI2ZE6ItIM296Gyliy7J8XwZX20yBEyB4A6cHQhya5pdWKGohqtlSnn2Mh2c8vkrx7K4NGTPXwycP1SW7nkGcWdADDBmaTddSnNxS1use(tUMyH3BuaLM8qgstmLmfjcDoGMwYmKi8UcQlxIKh2gUMUqO6bgq(ZamjOZb00cBtJT5HTaFLs01oj(jyBASfMqAnl8EJcOa8Gwx3gdq7WaBZ5fBnLeX5rnNeza0vqThKmKMy6YuKi05aAAjZqIW7kOUCjIzylWxPeOwADDBSDNdUos0KZdS1OrS1mSf4RuculTUUn2UZbxhj(jyBAS1mSnPjqX24lXdHQhyWGrxOsyRrJyBstGITXxIhcWdADDBmaTddS1OrSnPjqX24lXdXM25LRz(cu(XjS1CS1CS1CSnn2ctiTMfEVrbuO6bgq(ZamHT58IT5krCEuZjru9adi)zaMKH0KSKPirOZb00sMHeX5rnNeza0vqThKeH3vqD5seZW2fb8vkr7zpDXjbmCoQyliyBwyRrJy7Ia(kLO9SNU4KOPDVoi2cc2(iFS1CSnn2c8vkbQLwx3gB35GRJen58aBnAeBndBb(kLa1sRRBJT7CW1rIFc2MgBndBtAcuSn(s8qO6bgmy0fQe2A0i2M0eOyB8L4Ha8Gwx3gdq7WaBnAeBtAcuSn(s8qSPDE5AMVaLFCcBnhBnxIWFY1el8EJcO0KhYqAsMuMIeHohqtlzgseExb1Llra(kLa1sRRBJT7CW1rIMCEGTgnITMHTaFLsGAP11TX2Do46iXpbBtJTMHTjnbk2gFjEiu9adgm6cvcBnAeBtAcuSn(s8qaEqRRBJbODyGTgnITjnbk2gFjEi20oVCnZxGYpoHTMJTMlrCEuZjrgaDfu7bjdPjGMYuKi05aAAjZqIW7kOUCjIzyBEylWxPeDTtIFc2A0i22)R4SKbn1IfPkEfyliy7J8XwJgX2(FKiQDIfdlxSnhSDJVWwZX20ylmH0Aw49gfqXM25LRz(cu(XjSnNxSnxjIZJAojYM25LRz(cu(XjzinjtitrIqNdOPLmdjcVRG6YLiaFLs01oj(jyBASfMqAnl8EJcOa8Gwx3gdq7WaBZ5fBZvI48OMtIaEqRRBJbODyidPjGozkse6CanTKzirCEuZjru9adgm6cvsIW7kOUCjIzy7Ia(kLO9SNU4KagohvSfeSnlS1OrSDraFLs0E2txCs00UxheBbbBFKp2Ao2MgBZdBb(kLORDs8tWwJgX2(FfNLmOPwSivXRaBbbBFKp2A0i22)JerTtSyy5IT5GTB8f2MgBZdBdxtxiu9adi)zaMe05aAAjr4p5AIfEVrbuAYdzin5r(YuKi05aAAjZqIW7kOUCjsEylWxPeDTtIFc2A0i22)R4SKbn1IfPkEfyliy7J8XwJgX2(FKiQDIfdlxSnhSDJVKiopQ5KiQEGbdgDHkjdPjpEitrIqNdOPLmdjcVRG6YLiaFLs01oj(jseNh1CseWdADDBmaTddzin5rUYuKi05aAAjZqI48OMtIma6kO2dsIW7kOUCjIzy7Ia(kLO9SNU4KagohvSfeSnlS1OrSDraFLs0E2txCs00UxheBbbBFKp2Ao2MgBZdBdxtxiu9adi)zaMe05aAAjr4p5AIfEVrbuAYdzin5HPKPirCEuZjrgaDfu7bjrOZb00sMHmKHebyGSO4Ow3MmfPjpKPirOZb00sMHeH3vqD5se(m61G(e0EYGMAw)pIHM8K5enT71bLiopQ5KijLw7nBumvpWqgstYvMIeHohqtlzgseExb1Llr6)rqSfeSntkrCEuZjrO9Kbn1S(Fedn5jZjdPjMsMIeHohqtlzgseNh1CsKbqxb1EqseExb1LlrmdBxeWxPeTN90fNeWW5OITGGTzHTgnITlc4RuI2ZE6ItIM296Gyliy7J8XwZX20yB)VIZsg0uJTG8ITMkxSnn2Mh2gUMUqO6bgq(ZamjOZb00sIWFY1el8EJcO0KhYqAIPltrIqNdOPLmdjcVRG6YLi9)kolzqtn2cYl2AQCLiopQ5KidGUcQ9GKH0KSKPirOZb00sMHeH3vqD5sKW10fInpatDDBmym9UGohqtljIZJAojst7tdjnbHm01fuldPjzszkse6CanTKzir4DfuxUeb4RuIU2jXprI48OMtIaEqRRBJbODyidPjGMYuKi05aAAjZqI48OMtIma6kO2dsIW7kOUCjIzy7Ia(kLO9SNU4KagohvSfeSnlS1OrSDraFLs0E2txCs00UxheBbbBFKp2Ao2MgB7)rIO2jwmSSWwqW2n(cBnAeB7)vCwYGMASfKxS10ZcBtJT5HTHRPleQEGbK)matc6CanTKi8NCnXcV3Oakn5HmKMKjKPirOZb00sMHeH3vqD5sK(FKiQDIfdllSfeSDJVWwJgX2(FfNLmOPgBb5fBn9SKiopQ5KidGUcQ9GKH0eqNmfjcDoGMwYmKi8UcQlxIa8vkbQLwx3gB35GRJe)eSnn2ctiTMfEVrbuO6bgq(ZamHT58IT5krCEuZjru9adi)zaMKH0Kh5ltrIqNdOPLmdjcVRG6YLi9)kolzqtTyrQIxb2MZl2AQCX20yB)pse1oXIHzkSnhSDJVKiopQ5KiGN(yJIHUUGAzin5XdzkseNh1CsKM2NgsAcczORlOwIqNdOPLmdzin5rUYuKi05aAAjZqIW7kOUCjcmH0Aw49gfqHQhya5pdWe2MZl2MReX5rnNer1dmG8NbysgstEykzkse6CanTKzirCEuZjrgaDfu7bjr4DfuxUeXmSDraFLs0E2txCsadNJk2cc2Mf2A0i2UiGVsjAp7PlojAA3RdITGGTpYhBnhBtJT9)kolzqtTyrQIxb2Md2MBwyRrJyB)pcBZbBnf2MgBZdBdxtxiu9adi)zaMe05aAAjr4p5AIfEVrbuAYdzin5HPltrIqNdOPLmdjcVRG6YLi9)kolzqtTyrQIxb2Md2MBwyRrJyB)pcBZbBnLeX5rnNeza0vqThKmKM8ilzkse6CanTKzir4DfuxUeP)xXzjdAQflsv8kW2CW2SYxI48OMtI4n3pIft30fYqgseccPJtqzkstEitrIqNdOPLmdjcVRG6YLiaFLsKuAT3SrXu9adrt7EDqSfeS9r(yBASf4RucGM8amBumyDR23gOl(jyRrJylWxPejLw7nBumvpWq00UxheBbbBFKp2MgBZdBdxtxiaAYdWSrXG1TAFBGUGohqtljIZJAojcGEMfBuSamXOJ2FkdPj5ktrI48OMtIS99Ev(XgfZZM6jalrOZb00sMHmKMykzkse6CanTKzir4DfuxUeb4RuIKsR9MnkMQhyiAA3RdITGGTzHTPXwGVsjskT2B2OyQEGH4NGTgnITrTtSyyRIWwqW2SKiopQ5KiCWLwZGrtoQYqAIPltrIqNdOPLmdjcVRG6YLiaFLs0ehvnbHm10Cs8tWwJgXwGVsjAIJQMGqMAAoX4Z)cQfWW5OITGGTpEirCEuZjrcWe7FaZ)wm10CsgstYsMIeHohqtlzgseExb1LlrYdBb(kLiP0AVzJIP6bgIFc2MgBZdBb(kLaOjpaZgfdw3Q9Tb6IFIeX5rnNern8pKwmpBQRGyaKVldPjzszkse6CanTKzir4DfuxUejpSf4RuIKsR9MnkMQhyi(jyBASnpSf4RucGM8amBumyDR23gOl(jyBASDnHGphNUO9GwmL23jgWVprt7EDqS9fBZxI48OMtIWNJtx0EqlMs77KmKMaAktrIqNdOPLmdjcVRG6YLi5HTaFLsKuAT3SrXu9adXpbBtJT5HTaFLsa0KhGzJIbRB1(2aDXprI48OMtIK87s9SUngG2HHmKMKjKPirOZb00sMHeH3vqD5sK8WwGVsjskT2B2OyQEGH4NGTPX28WwGVsjaAYdWSrXG1TAFBGU4NirCEuZjrqpTEbkQowtW58JtYqAcOtMIeHohqtlzgseExb1LlrYdBb(kLiP0AVzJIP6bgIFc2MgBZdBb(kLaOjpaZgfdw3Q9Tb6IFIeX5rnNePRKenXQJbtCojdPjpYxMIeHohqtlzgseExb1Llra(kLG2tg0uZ6)rm0KNmNOPDVoi2cc2Mf2MgBb(kLaOjpaZgfdw3Q9Tb6IFc2A0i2Ag22)JerTtSyy5IT5GTB8f2MgB7)vCwYGMASfeSnR8XwZLiopQ5Ki70(0pzJIP)8AXwn57qzidjcWazjZORBtMI0KhYuKi05aAAjZqIW7kOUCjcWxPeDTtIFIeX5rnNeb8Gwx3gdq7WqgstYvMIeHohqtlzgseNh1CsKbqxb1EqseExb1LlrmdBxeWxPeTN90fNeWW5OITGGTzHTgnITlc4RuI2ZE6ItIM296Gyliy7J8XwZX20yB)VIZsg0ulwKQ4vGT58IT5Mf2MgBZdBdxtxiu9adi)zaMe05aAAjr4p5AIfEVrbuAYdzinXuYuKi05aAAjZqIW7kOUCjs)VIZsg0ulwKQ4vGT58IT5MLeX5rnNeza0vqThKmKMy6YuKi05aAAjZqIW7kOUCjs)VIZsg0ulwKQ4vGTGGT5Mp2MgBHjKwZcV3Oak20oVCnZxGYpoHT58IT5ITPXw(m61G(ejLw7nBumvpWq00UxheBZbBZsI48OMtISPDE5AMVaLFCsgstYsMIeHohqtlzgseNh1CsevpWGbJUqLKi8UcQlxIyg2UiGVsjAp7PlojGHZrfBbbBZcBnAeBxeWxPeTN90fNenT71bXwqW2h5JTMJTPX2(FfNLmOPwSivXRaBbbBZnFSnn2Mh2gUMUqO6bgq(ZamjOZb00cBtJT8z0Rb9jskT2B2OyQEGHOPDVoi2Md2MLeH)KRjw49gfqPjpKH0KmPmfjcDoGMwYmKi8UcQlxI0)R4SKbn1IfPkEfyliyBU5JTPXw(m61G(ejLw7nBumvpWq00UxheBZbBZsI48OMtIO6bgmy0fQKmKMaAktrIqNdOPLmdjcVRG6YLiaFLsGAP11TX2Do46iXpbBtJT9)kolzqtTyrQIxb2Md2Ag2(ilS1aSnCnDHO)xXzEe099OMtqNdOPf2MPyRPWwZX20ylmH0Aw49gfqHQhya5pdWe2MZl2MReX5rnNer1dmG8NbysgstYeYuKi05aAAjZqIW7kOUCjs)VIZsg0ulwKQ4vGT58ITMHTMklS1aSnCnDHO)xXzEe099OMtqNdOPf2MPyRPWwZX20ylmH0Aw49gfqHQhya5pdWe2MZl2MReX5rnNer1dmG8NbysgstaDYuKi05aAAjZqI48OMtIma6kO2dsIW7kOUCjIzy7Ia(kLO9SNU4KagohvSfeSnlS1OrSDraFLs0E2txCs00UxheBbbBFKp2Ao2MgB7)vCwYGMAXIufVcSnNxS1mS1uzHTgGTHRPle9)koZJGUVh1Cc6CanTW2mfBnf2Ao2MgBZdBdxtxiu9adi)zaMe05aAAjr4p5AIfEVrbuAYdzin5r(YuKi05aAAjZqIW7kOUCjs)VIZsg0ulwKQ4vGT58ITMHTMklS1aSnCnDHO)xXzEe099OMtqNdOPf2MPyRPWwZLiopQ5KidGUcQ9GKH0KhpKPirOZb00sMHeH3vqD5se(m61G(ejLw7nBumvpWq00UxheBZbB7)rIO2jwmmthBtJT9)kolzqtTyrQIxb2cc2A65JTPXwycP1SW7nkGInTZlxZ8fO8JtyBoVyBUseNh1CsKnTZlxZ8fO8JtYqAYJCLPirOZb00sMHeX5rnNer1dmyWOlujjcVRG6YLiMHTlc4RuI2ZE6Itcy4CuXwqW2SWwJgX2fb8vkr7zpDXjrt7EDqSfeS9r(yR5yBASLpJEnOprsP1EZgft1dmenT71bX2CW2(FKiQDIfdZ0X20yB)VIZsg0ulwKQ4vGTGGTME(yBASnpSnCnDHq1dmG8NbysqNdOPLeH)KRjw49gfqPjpKH0KhMsMIeHohqtlzgseExb1Llr4ZOxd6tKuAT3SrXu9adrt7EDqSnhST)hjIANyXWmDSnn22)R4SKbn1IfPkEfyliyRPNVeX5rnNer1dmyWOlujzidjsst8zhWdzkstEitrI48OMtIKmrnNeHohqtlzgYqAsUYuKi05aAAjZqIC(ojr8SHG92Hm1CbBuSKbn1seNh1CsepBiyVDitnxWgflzqtTmKMykzkse6CanTKzirMejcKcjIZJAojcO8UCanjraLR)KeXmSLmTFLKqlXnX018HSnTVkpMgYa81gHTgnITKP9RKeAjG1vWGA2M2xLhtdza(AJWwJgXwY0(vscTeW6kyqnBt7RYJPHSDA5ADnh2A0i2sM2VssOLauLRzJI5xT7bTya6zwyRrJylzA)kjHwcv1WGT7bbzWKNBAhcXwJgXwY0(vscTeG2jid8Gwtn2A0i2sM2VssOL4My6A(q2M2xLhtdz70Y16AoS1OrSLmTFLKqlHdbdk)iiR9SNMXN21yR5seq5n78DsImbyQzZX(qIrM2VssOLmKHeXhsMI0KhYuKi05aAAjZqIW7kOUCjs4A6cXMhGPUUngmMExqNdOPf2A0i2Ag26ztDfKq1t20XcApHGHO9dvSnn2ctiTMfEVrbu00(0qstqidDDb1yBoVyRPW20yBEylWxPeDTtIFc2AUeX5rnNePP9PHKMGqg66cQLH0KCLPirOZb00sMHeH3vqD5sKW10fcvpWaYFgGjbDoGMwseNh1CsKnTZlxZ8fO8JtYqAIPKPirOZb00sMHeX5rnNer1dmyWOlujjcVRG6YLiMHTlc4RuI2ZE6Itcy4CuXwqW2SWwJgX2fb8vkr7zpDXjrt7EDqSfeS9r(yR5yBASLpJEnOprt7tdjnbHm01fulAA3RdITG8IT5ITzk2UXxyBASnCnDHyZdWux3gdgtVlOZb00cBtJT5HTHRPleQEGbK)matc6CanTKi8NCnXcV3Oakn5HmKMy6YuKi05aAAjZqIW7kOUCjcFg9AqFIM2NgsAcczORlOw00UxheBb5fBZfBZuSDJVW20yB4A6cXMhGPUUngmMExqNdOPLeX5rnNer1dmyWOlujzinjlzkse6CanTKzir4DfuxUeb4RuIU2jXprI48OMtIaEqRRBJbODyidPjzszkse6CanTKzir4DfuxUeb4RuculTUUn2UZbxhj(jseNh1CsevpWaYFgGjzinb0uMIeHohqtlzgseExb1Llr6)vCwYGMAXIufVcSfeS1mS9rwyRbyB4A6cr)VIZ8iO77rnNGohqtlSntXwtHTMlrCEuZjr20oVCnZxGYpojdPjzczkse6CanTKzirCEuZjru9adgm6cvsIW7kOUCjIzy7Ia(kLO9SNU4KagohvSfeSnlS1OrSDraFLs0E2txCs00UxheBbbBFKp2Ao2MgB7)vCwYGMAXIufVcSfeS1mS9rwyRbyB4A6cr)VIZ8iO77rnNGohqtlSntXwtHTMJTPX28W2W10fcvpWaYFgGjbDoGMwse(tUMyH3BuaLM8qgstaDYuKi05aAAjZqIW7kOUCjs)VIZsg0ulwKQ4vGTGGTMHTpYcBnaBdxtxi6)vCMhbDFpQ5e05aAAHTzk2AkS1CSnn2Mh2gUMUqO6bgq(ZamjOZb00sI48OMtIO6bgmy0fQKmKM8iFzkseNh1CsKM2NgsAcczORlOwIqNdOPLmdzin5XdzkseNh1CsevpWaYFgGjjcDoGMwYmKH0Kh5ktrIqNdOPLmdjIZJAojYaORGApijcVRG6YLiMHTlc4RuI2ZE6Itcy4CuXwqW2SWwJgX2fb8vkr7zpDXjrt7EDqSfeS9r(yR5yBAST)xXzjdAQflsv8kW2CWwZW2CZcBnaBdxtxi6)vCMhbDFpQ5e05aAAHTzk2AkS1CSnn2Mh2gUMUqO6bgq(ZamjOZb00sIWFY1el8EJcO0KhYqAYdtjtrIqNdOPLmdjcVRG6YLi9)kolzqtTyrQIxb2Md2Ag2MBwyRbyB4A6cr)VIZ8iO77rnNGohqtlSntXwtHTMlrCEuZjrgaDfu7bjdPjpmDzkseNh1CsKnTZlxZ8fO8Jtse6CanTKzidPjpYsMIeHohqtlzgseNh1CsevpWGbJUqLKi8UcQlxIyg2UiGVsjAp7PlojGHZrfBbbBZcBnAeBxeWxPeTN90fNenT71bXwqW2h5JTMJTPX28W2W10fcvpWaYFgGjbDoGMwse(tUMyH3BuaLM8qgstEKjLPirCEuZjru9adgm6cvsIqNdOPLmdzin5bOPmfjIZJAojc4Pp2OyORlOwIqNdOPLmdzin5rMqMIeX5rnNeXBUFelMUPlKi05aAAjZqgYqIad)wEVKPin5HmfjIZJAojst7tdjnbHm01fulrOZb00sMHmKMKRmfjcDoGMwYmKi8UcQlxIWNrVg0NOP9PHKMGqg66cQfnT71bXwqEX2CX2mfB34lSnn2gUMUqS5byQRBJbJP3f05aAAjrCEuZjru9adgm6cvsgstmLmfjcDoGMwYmKi8UcQlxIa8vkrx7K4NirCEuZjrapO11TXa0omKH0etxMIeHohqtlzgseExb1LlrYdBb(kLq1t20Xs(Aij(jyBASnCnDHq1t20Xs(AijOZb00sI48OMtIma6kO2dsgstYsMIeHohqtlzgseExb1Llr6)vCwYGMAXIufVcSfeS1mS9rwyRbyB4A6cr)VIZ8iO77rnNGohqtlSntXwtHTMlrCEuZjru9adgm6cvsgstYKYuKi05aAAjZqIW7kOUCjcWxPeOwADDBSDNdUos8tW20yB)pse1oXIHz6yBoVy7gFjrCEuZjru9adi)zaMKH0eqtzkse6CanTKzir4DfuxUeP)xXzjdAQflsv8kW2CWwZW2CZcBnaBdxtxi6)vCMhbDFpQ5e05aAAHTzk2AkS1CjIZJAojYaORGApizinjtitrI48OMtIO6bgmy0fQKeHohqtlzgYqAcOtMIeX5rnNeb80hBum01fulrOZb00sMHmKM8iFzkseNh1CseV5(rSy6MUqIqNdOPLmdzidjYIu(xhYuKM8qMIeX5rnNezVUft1eLnjrOZb00sMHmKMKRmfjcDoGMwYmKi8UcQlxIKh2UMqO6bgmfbkQfrXrTUnSnn2Ag2Mh2gUMUqa0KhGzJIbRB1(2aDbDoGMwyRrJylFg9AqFcGM8amBumyDR23gOlAA3RdIT5GTpYcBnxI48OMtIaEqRRBJbODyidPjMsMIeHohqtlzgseExb1Llra(kLO4pzHRNdkAA3RdITG8ITB8f2MgBb(kLO4pzHRNdk(jyBASfMqAnl8EJcOyt78Y1mFbk)4e2MZl2Ml2MgBndBZdBdxtxiaAYdWSrXG1TAFBGUGohqtlS1OrSLpJEnOpbqtEaMnkgSUv7Bd0fnT71bX2CW2hzHTMlrCEuZjr20oVCnZxGYpojdPjMUmfjcDoGMwYmKi8UcQlxIa8vkrXFYcxphu00UxheBb5fB34lSnn2c8vkrXFYcxphu8tW20yRzyBEyB4A6cbqtEaMnkgSUv7Bd0f05aAAHTgnIT8z0Rb9jaAYdWSrXG1TAFBGUOPDVoi2Md2(ilS1CjIZJAojIQhyWGrxOsYqAswYuKi05aAAjZqI48OMtIWDTM58OMJPlyir0fmyNVtseccPJtqzinjtktrIqNdOPLmdjIZJAojc31AMZJAoMUGHerxWGD(ojr4ZOxd6dkdPjGMYuKi05aAAjZqIW7kOUCjs4A6cbqtEaMnkgSUv7Bd0f05aAAHTPXwZWwZWw(m61G(ean5by2OyW6wTVnqx00UxheBFX28X20ylFg9AqFIKsR9MnkMQhyiAA3RdITGGTpYhBnhBnAeBndB5ZOxd6ta0KhGzJIbRB1(2aDrt7EDqSfeSn38X20yBu7elg2QiSfeS1uzHTMJTMlrCEuZjr6)XCEuZX0fmKi6cgSZ3jjcWazjZORBtgstYeYuKi05aAAjZqIW7kOUCjcWxPean5by2OyW6wTVnqx8tKiopQ5Ki9)yopQ5y6cgseDbd257KebyGSO4Ow3MmKMa6KPirOZb00sMHeH3vqD5seGVsjskT2B2OyQEGH4NGTPX2W10fIbqxb1EuZjOZb00sI48OMtI0)J58OMJPlyir0fmyNVtsKbqxb1EuZjdPjpYxMIeHohqtlzgseExb1LlrCEuGIy0r7fbX2CEX2CLiopQ5Ki9)yopQ5y6cgseDbd257KeXhsgstE8qMIeHohqtlzgseNh1CseUR1mNh1CmDbdjIUGb78DsIad)wEVKHmKi8z0Rb9bLPin5HmfjcDoGMwYmKiopQ5KiE2qWE7qMAUGnkwYGMAjcVRG6YLiMHT8z0Rb9jO9Kbn1S(Fedn5jZjAYxpX20yBEylO8UCanjMam1S5yFiXit7xjj0cBnhBnAeBndB5ZOxd6tKuAT3SrXu9adrt7EDqSfKxS9r(yBASfuExoGMetaMA2CSpKyKP9RKeAHTMlroFNKiE2qWE7qMAUGnkwYGMAzinjxzkse6CanTKzirCEuZjr0)gvQHS6G1QMpKTvQqIW7kOUCjs4A6cbqtEaMnkgSUv7Bd0f05aAAHTPXwZWwZWw(m61G(ejLw7nBumvpWq00UxheBb5fBFKp2MgBbL3LdOjXeGPMnh7djgzA)kjHwyR5yRrJyRzylWxPejLw7nBumvpWq8tW20yBEylO8UCanjMam1S5yFiXit7xjj0cBnhBnhBnAeBndBb(kLiP0AVzJIP6bgIFc2MgBZdBdxtxiaAYdWSrXG1TAFBGUGohqtlS1CjY57Ker)BuPgYQdwRA(q2wPczinXuYuKi05aAAjZqI48OMtIWFY1t0ZvCgG2HHeH3vqD5sK8WwGVsjskT2B2OyQEGH4NiroFNKi8NC9e9CfNbODyidPjMUmfjcDoGMwYmKi8UcQlxIyg2YNrVg0NiP0AVzJIP6bgIM81tS1OrSLpJEnOprsP1EZgft1dmenT71bX2CW2CZhBnhBtJTMHT5HTHRPlean5by2OyW6wTVnqxqNdOPf2A0i2YNrVg0NG2tg0uZ6)rm0KNmNOPDVoi2Md2c6YcBnxI48OMtI8HeRcAhkdPjzjtrIqNdOPLmdjIZJAojIdbdk)iiR9SNMXN21seExb1LlrweWxPeTN90m(0UMTiGVsjwd6tIC(ojrCiyq5hbzTN90m(0UwgstYKYuKi05aAAjZqI48OMtI4qWGYpcYAp7Pz8PDTeH3vqD5se(m61G(e0EYGMAw)pIHM8K5enT71bX2CWwqx(yBASDraFLs0E2tZ4t7A2Ia(kL4NGTPXwq5D5aAsmbyQzZX(qIrM2VssOf2A0i2c8vkbqtEaMnkgSUv7Bd0f)eSnn2UiGVsjAp7Pz8PDnBraFLs8tW20yBEylO8UCanjMam1S5yFiXit7xjj0cBnAeBb(kLG2tg0uZ6)rm0KNmN4NGTPX2fb8vkr7zpnJpTRzlc4RuIFc2MgBZdBdxtxiaAYdWSrXG1TAFBGUGohqtlS1OrSnQDIfdBve2cc2M7djY57KeXHGbLFeK1E2tZ4t7Azinb0uMIeHohqtlzgseNh1Cseq7eKbEqRPwIW7kOUCjIzylzA)kjHwc9VrLAiRoyTQ5dzBLkW20ylWxPejLw7nBumvpWq00UxheBnhBnAeBndBZdBjt7xjj0sO)nQudz1bRvnFiBRub2MgBb(kLiP0AVzJIP6bgIM296Gyliy7JCX20ylWxPejLw7nBumvpWq8tWwZLiNVtseq7eKbEqRPwgstYeYuKi05aAAjZqI48OMtIG6nbBum)4fDbt97NseExb1Llr4ZOxd6tq7jdAQz9)igAYtMt00UxheBZbBn98LiNVtseuVjyJI5hVOlyQF)ugstaDYuKi05aAAjZqI48OMtIS1ZTbzjDT7Aw7BKeH3vqD5sK(Fe2cYl2AkSnn2Mh2c8vkrsP1EZgft1dme)eSnn2Ag2Mh2c8vkbqtEaMnkgSUv7Bd0f)eS1OrSnpSnCnDHaOjpaZgfdw3Q9Tb6c6CanTWwZLiNVtsKTEUnilPRDxZAFJKH0Kh5ltrIqNdOPLmdjY57KeP9Sx)dvidO2ynTya)iMtI48OMtI0E2R)HkKbuBSMwmGFeZjdPjpEitrIqNdOPLmdjIZJAojYo1eQbyhYu(Tjr4DfuxUejpSf4RucGM8amBumyDR23gOl(jyBASnpSf4RuIKsR9MnkMQhyi(jsKZ3jjYo1eQbyhYu(TjdPjpYvMIeHohqtlzgseExb1Llra(kLiP0AVzJIP6bgIFc2MgBb(kLG2tg0uZ6)rm0KNmN4NirCEuZjrsMOMtgstEykzkse6CanTKzir4DfuxUeb4RuIKsR9MnkMQhyi(jyBASf4RucApzqtnR)hXqtEYCIFIeX5rnNebqpZIP(9tzin5HPltrIqNdOPLmdjcVRG6YLiaFLsKuAT3SrXu9adXprI48OMtIaqnKAuRBtgstEKLmfjcDoGMwYmKi8UcQlxIWNrVg0NG2tg0uZ6)rm0KNmNOPDVoOeX5rnNejP0AVzJIP6bgYqAYJmPmfjcDoGMwYmKi8UcQlxIWNrVg0NG2tg0uZ6)rm0KNmNOPDVoi2MgB5ZOxd6tKuAT3SrXu9adrt7EDqjIZJAojcqtEaMnkgSUv7Bd0LiFiXgLITXxsKhYqAYdqtzkse6CanTKzir4DfuxUeHpJEnOprsP1EZgft1dmen5RNyBASnpSnCnDHaOjpaZgfdw3Q9Tb6c6CanTW20yB)pse1oXIHLf2Md2UXxyBAST)xXzjdAQflsv8kW2CEX2h5JTgnITrTtSyyRIWwqW2CZxI48OMtIq7jdAQz9)igAYtMtgstEKjKPirOZb00sMHeH3vqD5seZWw(m61G(ejLw7nBumvpWq0KVEITgnITrTtSyyRIWwqW2CZhBnhBtJTHRPlean5by2OyW6wTVnqxqNdOPf2MgB7)vCwYGMASnhSntMVeX5rnNeH2tg0uZ6)rm0KNmNmKM8a0jtrIqNdOPLmdjcVRG6YLiHRPle8rVyGjVdbDoGMwyBAS1mS1mSf4Ruc(OxmWK3HagohvSnNxS9r(yBASDraFLs0E2txCsadNJk2(ITzHTMJTgnITrTtSyyRIWwqEX2n(cBnxI48OMtIWDTM58OMJPlyir0fmyNVtse(OxmWK3HmKMKB(YuKi05aAAjZqIW7kOUCjIzylWxPejLw7nBumvpWq00UxheBb5fB34lS1OrS1mSf4RuIKsR9MnkMQhyiAA3RdITGGTzcSnn2c8vkX)ap6Nmy00TfGfnT71bXwqEX2n(cBtJTaFLs8pWJ(jdgnDBbyXpbBnhBnhBtJTaFLsKuAT3SrXu9adXpbBtJTE2uxbjk(tgVcFrAr7hQyliVy7djIZJAojIQhyG(zVdzQF)ugstY9HmfjcDoGMwYmKi8UcQlxIyg2c8vkrXFY4v4lslAA3RdITG8ITB8f2A0i2Ag2c8vkrXFY4v4lslAA3RdITGGTzcSnn2c8vkX)ap6Nmy00TfGfnT71bXwqEX2n(cBtJTaFLs8pWJ(jdgnDBbyXpbBnhBnhBtJTaFLsu8NmEf(I0IFc2MgB9SPUcsu8NmEf(I0I2puX2CEX2CLiopQ5KiQEGb6N9oKP(9tzinj3CLPirOZb00sMHeH3vqD5sKO2jwmSvryliy7gFHTgnITMHTrTtSyyRIWwqWw(m61G(ejLw7nBumvpWq00UxheBtJTaFLs8pWJ(jdgnDBbyXpbBnxI48OMtIO6bgOF27qM63pLHmKHebuudR5KMKB(paD5d6YnFjcAVV62GseqB7jth0cBFKp268OMdB1fmGcmkseycXLMKBwpKij9OknjrYmSnZ1dmWwqlipaJTzEVAdCGrjZWwWrKabnMAQBva(di4ZEQWA)R9OMJ3Uksfw78uXOKzyRjdOODaQX2hpmeBZn)hGomkyuYmSf0ay)2iiOrmkzg2c6HTG2oU(ViSnZJ6wyBMRjkBsGrjZWwqpSf0)AHTkxRbCoQyRAAS9dRBdBbTM5pZNHylOVjZHTLcBt0(tQX26QO8GGyBgdc2cqQPjSnzgDDByRE2ko2wqSLp7jAkOLaJsMHTGEylObW(TryB49gfIO2jwmSvryBmyBu7elg2QiSngS9djSLo(8VGASvt3wagBBpatn2gG9dBtMGUOCn2gTdbJTlYdWqbgfmkzg2cAf0sI)dAHTaKAAcB5ZoGhylaTvhuGTG(5CkjGy7nhOhyV3vFn268OMdITZPFkWOKzyRZJAoOiPj(Sd4XRs7quXOKzyRZJAoOiPj(Sd4HbVPQMzHrjZWwNh1Cqrst8zhWddEt1)B70fEuZHrjZWwKZtGGNaBBVwylWxPOf2cdpGylaPMMWw(Sd4b2cqB1bXw)wyBstGEjte1THTfeBxZrcmkzg268OMdksAIp7aEyWBQWZtGGNGbdpGyuCEuZbfjnXNDapm4n1KjQ5WO48OMdksAIp7aEyWBQFiXQG2n88D61Zgc2BhYuZfSrXsg0uJrX5rnhuK0eF2b8WG3ubL3LdOjdpFNENam1S5yFiXit7xjj0Yqq56p9AgzA)kjHwIBIPR5dzBAFvEmnKb4RnYOrY0(vscTeW6kyqnBt7RYJPHmaFTrgnsM2VssOLawxbdQzBAFvEmnKTtlxRR5mAKmTFLKqlbOkxZgfZVA3dAXa0ZSmAKmTFLKqlHQAyW29GGmyYZnTdHgnsM2VssOLa0obzGh0AQnAKmTFLKqlXnX018HSnTVkpMgY2PLR11CgnsM2VssOLWHGbLFeK1E2tZ4t7AZXOGrjZWwqRGws8FqlSLaf1pX2O2jSnatyRZJPX2cIToO8s7aAsGrX5rnh8DVUft1eLnHrjZWwq)jj6NyBMRhyGTzocuuJT(TW2DVUWRdBbTXFITP465GyuCEuZbn4nvWdADDBmaTdddl1BERjeQEGbtrGIAruCuRBlTz5fUMUqa0KhGzJIbRB1(2aDbDoGMwgnYNrVg0NaOjpaZgfdw3Q9Tb6IM296G58ilZXO48OMdAWBQBANxUM5lq5hNmSuVaFLsu8NSW1ZbfnT71bb5DJVsd8vkrXFYcxphu8tsdtiTMfEVrbuSPDE5AMVaLFCkN3CtBwEHRPlean5by2OyW6wTVnqxqNdOPLrJ8z0Rb9jaAYdWSrXG1TAFBGUOPDVoyopYYCmkopQ5Gg8MQQhyWGrxOsgwQxGVsjk(tw465GIM296GG8UXxPb(kLO4pzHRNdk(jPnlVW10fcGM8amBumyDR23gOlOZb00YOr(m61G(ean5by2OyW6wTVnqx00UxhmNhzzogfNh1CqdEtL7AnZ5rnhtxWWWZ3PxccPJtqmkopQ5Gg8Mk31AMZJAoMUGHHNVtV8z0Rb9bXO48OMdAWBQ9)yopQ5y6cggE(o9cmqwYm662mSuVHRPlean5by2OyW6wTVnqxqNdOPvAZmJpJEnOpbqtEaMnkgSUv7Bd0fnT71bFZpnFg9AqFIKsR9MnkMQhyiAA3RdcYJ8n3OrZ4ZOxd6ta0KhGzJIbRB1(2aDrt7EDqqYn)0rTtSyyRIaXuzzU5yuCEuZbn4n1(FmNh1CmDbddpFNEbgilkoQ1TzyPEb(kLaOjpaZgfdw3Q9Tb6IFcgfNh1CqdEtT)hZ5rnhtxWWWZ3P3bqxb1EuZzyPEb(kLiP0AVzJIP6bgIFs6W10fIbqxb1EuZjOZb00cJIZJAoObVP2)J58OMJPlyy4570RpKHL615rbkIrhTxemN3CXO48OMdAWBQCxRzopQ5y6cggE(o9cd)wEVWOGrX5rnhu4d920(0qstqidDDb1gwQ3W10fInpatDDBmym9UGohqtlJgnZZM6kiHQNSPJf0Ecbdr7hQPHjKwZcV3OakAAFAiPjiKHUUG6CEnv68a(kLORDs8tmhJIZJAoOWhYG3u30oVCnZxGYpozyPEdxtxiu9adi)zaMe05aAAHrX5rnhu4dzWBQQEGbdgDHkzi)jxtSW7nkGVpmSuVMTiGVsjAp7PlojGHZrfKSmACraFLs0E2txCs00UxheKh5BEA(m61G(enTpnK0eeYqxxqTOPDVoiiV5MPB8v6W10fInpatDDBmym9UGohqtR05fUMUqO6bgq(ZamjOZb00cJIZJAoOWhYG3uv9adgm6cvYWs9YNrVg0NOP9PHKMGqg66cQfnT71bb5n3mDJVshUMUqS5byQRBJbJP3f05aAAHrX5rnhu4dzWBQGh0662yaAhggwQxGVsj6ANe)emkopQ5GcFidEtv1dmG8NbyYWs9c8vkbQLwx3gB35GRJe)emkopQ5GcFidEtDt78Y1mFbk)4KHL6T)xXzjdAQflsv8kaXShzzq4A6cr)VIZ8iO77rnNGohqtRm1uMJrX5rnhu4dzWBQQEGbdgDHkzi)jxtSW7nkGVpmSuVMTiGVsjAp7PlojGHZrfKSmACraFLs0E2txCs00UxheKh5BE6(FfNLmOPwSivXRaeZEKLbHRPle9)koZJGUVh1Cc6CanTYutzE68cxtxiu9adi)zaMe05aAAHrX5rnhu4dzWBQQEGbdgDHkzyPE7)vCwYGMAXIufVcqm7rwgeUMUq0)R4mpc6(EuZjOZb00ktnL5PZlCnDHq1dmG8NbysqNdOPfgfNh1CqHpKbVP20(0qstqidDDb1yuCEuZbf(qg8MQQhya5pdWegfNh1CqHpKbVPoa6kO2dYq(tUMyH3BuaFFyyPEnBraFLs0E2txCsadNJkizz04Ia(kLO9SNU4KOPDVoiipY3809)kolzqtTyrQIxroMLBwgeUMUq0)R4mpc6(EuZjOZb00ktnL5PZlCnDHq1dmG8NbysqNdOPfgfNh1CqHpKbVPoa6kO2dYWs92)R4SKbn1IfPkEf5ywUzzq4A6cr)VIZ8iO77rnNGohqtRm1uMJrX5rnhu4dzWBQBANxUM5lq5hNWO48OMdk8Hm4nvvpWGbJUqLmK)KRjw49gfW3hgwQxZweWxPeTN90fNeWW5OcswgnUiGVsjAp7PlojAA3RdcYJ8npDEHRPleQEGbK)matc6CanTWO48OMdk8Hm4nvvpWGbJUqLWO48OMdk8Hm4nvWtFSrXqxxqngfNh1CqHpKbVP6n3pIft30fyuWOKzyBgn5bySDuylsDR23gOJTjZORBdB7j8OMdBbnITWW7aIT5MpeBbi10e2c6R0AVX2rHTzUEGb2Aa2MXGGTEtyRdkV0oGMWO48OMdkagilzgDDBVGh0662yaAhggwQxGVsj6ANe)emkopQ5GcGbYsMrx3MbVPoa6kO2dYq(tUMyH3BuaFFyyPEnBraFLs0E2txCsadNJkizz04Ia(kLO9SNU4KOPDVoiipY3809)kolzqtTyrQIxroV5Mv68cxtxiu9adi)zaMe05aAAHrX5rnhuamqwYm662m4n1bqxb1EqgwQ3(FfNLmOPwSivXRiN3CZcJIZJAoOayGSKz01TzWBQBANxUM5lq5hNmSuV9)kolzqtTyrQIxbi5MFAycP1SW7nkGInTZlxZ8fO8Jt58MBA(m61G(ejLw7nBumvpWq00UxhmNSWO48OMdkagilzgDDBg8MQQhyWGrxOsgYFY1el8EJc47ddl1Rzlc4RuI2ZE6Itcy4CubjlJgxeWxPeTN90fNenT71bb5r(MNU)xXzjdAQflsv8kaj38tNx4A6cHQhya5pdWKGohqtR08z0Rb9jskT2B2OyQEGHOPDVoyozHrX5rnhuamqwYm662m4nvvpWGbJUqLmSuV9)kolzqtTyrQIxbi5MFA(m61G(ejLw7nBumvpWq00UxhmNSWO48OMdkagilzgDDBg8MQQhya5pdWKHL6f4RuculTUUn2UZbxhj(jP7)vCwYGMAXIufVICm7rwgeUMUq0)R4mpc6(EuZjOZb00ktnL5PHjKwZcV3Oaku9adi)zaMY5nxmkopQ5GcGbYsMrx3MbVPQ6bgq(ZamzyPE7)vCwYGMAXIufVICEnZuzzq4A6cr)VIZ8iO77rnNGohqtRm1uMNgMqAnl8EJcOq1dmG8NbykN3CXO48OMdkagilzgDDBg8M6aORGApid5p5AIfEVrb89HHL61Sfb8vkr7zpDXjbmCoQGKLrJlc4RuI2ZE6ItIM296GG8iFZt3)R4SKbn1IfPkEf58AMPYYGW10fI(FfN5rq33JAobDoGMwzQPmpDEHRPleQEGbK)matc6CanTWO48OMdkagilzgDDBg8M6aORGApidl1B)VIZsg0ulwKQ4vKZRzMkldcxtxi6)vCMhbDFpQ5e05aAALPMYCmkopQ5GcGbYsMrx3MbVPUPDE5AMVaLFCYWs9YNrVg0NiP0AVzJIP6bgIM296G50)JerTtSyyME6(FfNLmOPwSivXRaetp)0WesRzH3BuafBANxUM5lq5hNY5nxmkopQ5GcGbYsMrx3MbVPQ6bgmy0fQKH8NCnXcV3Oa((WWs9A2Ia(kLO9SNU4KagohvqYYOXfb8vkr7zpDXjrt7EDqqEKV5P5ZOxd6tKuAT3SrXu9adrt7EDWC6)rIO2jwmmtpD)VIZsg0ulwKQ4vaIPNF68cxtxiu9adi)zaMe05aAAHrX5rnhuamqwYm662m4nvvpWGbJUqLmSuV8z0Rb9jskT2B2OyQEGHOPDVoyo9)iru7elgMPNU)xXzjdAQflsv8kaX0ZhJcgLmdBZCUwd4CuX2yW2pKWwqFtMZqSf0AM)mFylAW0HTFi1GE1vr5bbX2mgeSnPPDp(nPFkWO48OMdkagilkoQ1T9MuAT3SrXu9addl1lFg9AqFcApzqtnR)hXqtEYCIM296GyuCEuZbfadKffh162m4nvApzqtnR)hXqtEYCgwQ3(FeeKmjgfNh1CqbWazrXrTUndEtDa0vqThKH8NCnXcV3Oa((WWs9A2Ia(kLO9SNU4KagohvqYYOXfb8vkr7zpDXjrt7EDqqEKV5P7)vCwYGMAqEnvUPZlCnDHq1dmG8NbysqNdOPfgfNh1CqbWazrXrTUndEtDa0vqThKHL6T)xXzjdAQb51u5IrX5rnhuamqwuCuRBZG3uBAFAiPjiKHUUGAdl1B4A6cXMhGPUUngmMExqNdOPfgfNh1CqbWazrXrTUndEtf8Gwx3gdq7WWWs9c8vkrx7K4NGrX5rnhuamqwuCuRBZG3uhaDfu7bzi)jxtSW7nkGVpmSuVMTiGVsjAp7PlojGHZrfKSmACraFLs0E2txCs00UxheKh5BE6(FKiQDIfdllq24lJg7)vCwYGMAqEn9SsNx4A6cHQhya5pdWKGohqtlmkopQ5GcGbYIIJADBg8M6aORGApidl1B)pse1oXIHLfiB8LrJ9)kolzqtniVMEwyuCEuZbfadKffh162m4nvvpWaYFgGjdl1lWxPeOwADDBSDNdUos8tsdtiTMfEVrbuO6bgq(ZamLZBUyuCEuZbfadKffh162m4nvWtFSrXqxxqTHL6T)xXzjdAQflsv8kY51u5MU)hjIANyXWmvoB8fgfNh1CqbWazrXrTUndEtTP9PHKMGqg66cQXO48OMdkagilkoQ1TzWBQQEGbK)matgwQxycP1SW7nkGcvpWaYFgGPCEZfJIZJAoOayGSO4Ow3MbVPoa6kO2dYq(tUMyH3BuaFFyyPEnBraFLs0E2txCsadNJkizz04Ia(kLO9SNU4KOPDVoiipY3809)kolzqtTyrQIxro5MLrJ9)OCmv68cxtxiu9adi)zaMe05aAAHrX5rnhuamqwuCuRBZG3uhaDfu7bzyPE7)vCwYGMAXIufVICYnlJg7)r5ykmkopQ5GcGbYIIJADBg8MQ3C)iwmDtxyyPE7)vCwYGMAXIufVICYkFmkyuYmSf0WOxylyY7aB5ZTQOMdIrX5rnhuWh9IbM8oE5G96GSrXkozyPEb(kLGp6fdm5DiGHZrnNSsh1oXIHTkcKn(cJIZJAoOGp6fdm5DyWBQCWEDq2OyfNmSuVMb8vkbKOaCDBS23irt7EDqq24lZtd8vkbKOaCDBS23iXpbJIZJAoOGp6fdm5DyWBQCWEDq2OyfNmSuVMb8vkrsP1EZgft1dmenT71bb5DJVYuZEyaFg9AqFcvpWa9ZEhYu)(POjF90CJgb(kLiP0AVzJIP6bgIM296GG0)JerTtSyyMY80aFLsKuAT3SrXu9adXpjTzE2uxbjk(tgVcFrAr7hQG8(WOrGVsjaAYdWSrXG1TAFBGU4NyogfNh1CqbF0lgyY7WG3u5G96GSrXkozyPEb(kLiP0AVzJIP6bgIM296GGKjsd8vkX)ap6Nmy00TfGfnT71bbzJVYuZEyaFg9AqFcvpWa9ZEhYu)(POjF9080aFLs8pWJ(jdgnDBbyrt7EDW0aFLsKuAT3SrXu9adXpjTzE2uxbjk(tgVcFrAr7hQG8(WOrGVsjaAYdWSrXG1TAFBGU4NyogfNh1CqbF0lgyY7WG3u5G96GSrXkozyPEnd4RuII)KXRWxKw00Uxheet3OrGVsjk(tgVcFrArt7EDqq6)rIO2jwmmtzEAGVsjk(tgVcFrAXpjTNn1vqII)KXRWxKw0(HAoV5MopGVsjaAYdWSrXG1TAFBGU4NGrX5rnhuWh9IbM8om4nvoyVoiBuSItgwQxGVsjk(tgVcFrAXpjnWxPe)d8OFYGrt3waw8ts7ztDfKO4pz8k8fPfTFOMZBUPZd4RucGM8amBumyDR23gOl(jyuWO48OMdk4ZOxd6d((HeRcA3WZ3PxpBiyVDitnxWgflzqtTHL61m(m61G(e0EYGMAw)pIHM8K5en5RNPZduExoGMetaMA2CSpKyKP9RKeAzUrJMXNrVg0NiP0AVzJIP6bgIM296GG8(i)0GY7Yb0KycWuZMJ9HeJmTFLKqlZXO48OMdk4ZOxd6dAWBQFiXQG2n88D6v)BuPgYQdwRA(q2wPcdl1B4A6cbqtEaMnkgSUv7Bd0f05aAAL2mZ4ZOxd6tKuAT3SrXu9adrt7EDqqEFKFAq5D5aAsmbyQzZX(qIrM2VssOL5gnAgWxPejLw7nBumvpWq8tsNhO8UCanjMam1S5yFiXit7xjj0YCZnA0mGVsjskT2B2OyQEGH4NKoVW10fcGM8amBumyDR23gOlOZb00YCmkopQ5Gc(m61G(Gg8M6hsSkODdpFNE5p56j65kodq7WWWs9MhWxPejLw7nBumvpWq8tWO48OMdk4ZOxd6dAWBQFiXQG2HgwQxZ4ZOxd6tKuAT3SrXu9adrt(6PrJ8z0Rb9jskT2B2OyQEGHOPDVoyo5MV5PnlVW10fcGM8amBumyDR23gOlOZb00YOr(m61G(e0EYGMAw)pIHM8K5enT71bZb0LL5yuCEuZbf8z0Rb9bn4n1pKyvq7gE(o96qWGYpcYAp7Pz8PDTHL6DraFLs0E2tZ4t7A2Ia(kLynOpmkopQ5Gc(m61G(Gg8M6hsSkODdpFNEDiyq5hbzTN90m(0U2Ws9YNrVg0NG2tg0uZ6)rm0KNmNOPDVoyoGU8tViGVsjAp7Pz8PDnBraFLs8tsdkVlhqtIjatnBo2hsmY0(vscTmAe4RucGM8amBumyDR23gOl(jPxeWxPeTN90m(0UMTiGVsj(jPZduExoGMetaMA2CSpKyKP9RKeAz0iWxPe0EYGMAw)pIHM8K5e)K0lc4RuI2ZEAgFAxZweWxPe)K05fUMUqa0KhGzJIbRB1(2aDbDoGMwgng1oXIHTkcKCFGrX5rnhuWNrVg0h0G3u)qIvbTB4570lODcYapO1uByPEnJmTFLKqlH(3OsnKvhSw18HSTsfPb(kLiP0AVzJIP6bgIM296GMB0Oz5rM2VssOLq)BuPgYQdwRA(q2wPI0aFLsKuAT3SrXu9adrt7EDqqEKBAGVsjskT2B2OyQEGH4NyogfNh1CqbFg9AqFqdEt9djwf0UHNVtVOEtWgfZpErxWu)(PHL6LpJEnOpbTNmOPM1)JyOjpzort7EDWCm98XO48OMdk4ZOxd6dAWBQFiXQG2n88D6DRNBdYs6A31S23idl1B)pcKxtLopGVsjskT2B2OyQEGH4NK2S8a(kLaOjpaZgfdw3Q9Tb6IFIrJ5fUMUqa0KhGzJIbRB1(2aDbDoGMwMJrX5rnhuWNrVg0h0G3u)qIvbTB4570B7zV(hQqgqTXAAXa(rmhgfNh1CqbFg9AqFqdEt9djwf0UHNVtV7utOgGDit53MHL6npGVsjaAYdWSrXG1TAFBGU4NKopGVsjskT2B2OyQEGH4NGrX5rnhuWNrVg0h0G3utMOMZWs9c8vkrsP1EZgft1dme)K0aFLsq7jdAQz9)igAYtMt8tWO48OMdk4ZOxd6dAWBQa6zwm1VFAyPEb(kLiP0AVzJIP6bgIFsAGVsjO9Kbn1S(Fedn5jZj(jyuCEuZbf8z0Rb9bn4nvaQHuJADBgwQxGVsjskT2B2OyQEGH4NGrjZW2mxpWaB5ZOxd6dIrX5rnhuWNrVg0h0G3utkT2B2OyQEGHHL6LpJEnOpbTNmOPM1)JyOjpzort7EDqmkopQ5Gc(m61G(Gg8MkqtEaMnkgSUv7Bd0n8dj2OuSn(69HHL6LpJEnOpbTNmOPM1)JyOjpzort7EDW08z0Rb9jskT2B2OyQEGHOPDVoigfNh1CqbFg9AqFqdEtL2tg0uZ6)rm0KNmNHL6LpJEnOprsP1EZgft1dmen5RNPZlCnDHaOjpaZgfdw3Q9Tb6c6CanTs3)JerTtSyyzLZgFLU)xXzjdAQflsv8kY59r(gng1oXIHTkcKCZhJIZJAoOGpJEnOpObVPs7jdAQz9)igAYtMZWs9AgFg9AqFIKsR9MnkMQhyiAYxpnAmQDIfdBvei5MV5PdxtxiaAYdWSrXG1TAFBGUGohqtR09)kolzqtDozY8XO48OMdk4ZOxd6dAWBQCxRzopQ5y6cggE(o9Yh9IbM8omSuVHRPle8rVyGjVdbDoGMwPnZmGVsj4JEXatEhcy4CuZ59r(PxeWxPeTN90fNeWW5O(ML5gng1oXIHTkcK3n(YCmkopQ5Gc(m61G(Gg8MQQhyG(zVdzQF)0Ws9AgWxPejLw7nBumvpWq00UxheK3n(YOrZa(kLiP0AVzJIP6bgIM296GGKjsd8vkX)ap6Nmy00TfGfnT71bb5DJVsd8vkX)ap6Nmy00TfGf)eZnpnWxPejLw7nBumvpWq8ts7ztDfKO4pz8k8fPfTFOcY7dmkopQ5Gc(m61G(Gg8MQQhyG(zVdzQF)0Ws9AgWxPef)jJxHViTOPDVoiiVB8LrJMb8vkrXFY4v4lslAA3RdcsMinWxPe)d8OFYGrt3waw00UxheK3n(knWxPe)d8OFYGrt3waw8tm380aFLsu8NmEf(I0IFsApBQRGef)jJxHViTO9d1CEZfJIZJAoOGpJEnOpObVPQ6bgOF27qM63pnSuVrTtSyyRIazJVmA0SO2jwmSvrGWNrVg0NiP0AVzJIP6bgIM296GPb(kL4FGh9tgmA62cWIFI5yuWO48OMdkiiKoobFb0ZSyJIfGjgD0(tdl1lWxPejLw7nBumvpWq00UxheKh5Ng4RucGM8amBumyDR23gOl(jgnc8vkrsP1EZgft1dmenT71bb5r(PZlCnDHaOjpaZgfdw3Q9Tb6c6CanTWO48OMdkiiKoobn4n1TV3RYp2OyE2upbymkopQ5GcccPJtqdEtLdU0AgmAYr1Ws9c8vkrsP1EZgft1dmenT71bbjR0aFLsKuAT3SrXu9adXpXOXO2jwmSvrGKfgfNh1CqbbH0XjObVPgGj2)aM)TyQP5KHL6f4RuIM4OQjiKPMMtIFIrJaFLs0ehvnbHm10CIXN)fulGHZrfKhpWO48OMdkiiKoobn4nv1W)qAX8SPUcIbq(UHL6npGVsjskT2B2OyQEGH4NKopGVsjaAYdWSrXG1TAFBGU4NGrX5rnhuqqiDCcAWBQ8540fTh0IP0(ozyPEZd4RuIKsR9MnkMQhyi(jPZd4RucGM8amBumyDR23gOl(jPxti4ZXPlApOftP9DIb87t00Uxh8nFmkopQ5GcccPJtqdEtn53L6zDBmaTdddl1BEaFLsKuAT3SrXu9adXpjDEaFLsa0KhGzJIbRB1(2aDXpbJIZJAoOGGq64e0G3urpTEbkQowtW58JtgwQ38a(kLiP0AVzJIP6bgIFs68a(kLaOjpaZgfdw3Q9Tb6IFcgfNh1CqbbH0XjObVP2vsIMy1XGjoNmSuV5b8vkrsP1EZgft1dme)K05b8vkbqtEaMnkgSUv7Bd0f)emkopQ5GcccPJtqdEtDN2N(jBum9Nxl2QjFhAyPEb(kLG2tg0uZ6)rm0KNmNOPDVoiizLg4RucGM8amBumyDR23gOl(jgnAw)pse1oXIHLBoB8v6(FfNLmOPgKSY3CmkyuYmSnZtaDfu7rnh22t4rnhgfNh1CqXaORGApQ5EBAFAiPjiKHUUGAdl1B4A6cXMhGPUUngmMExqNdOPfgfNh1CqXaORGApQ5m4n1bqxb1EqgYFY1el8EJc47ddl1Rzlc4RuI2ZE6Itcy4CubjlJgxeWxPeTN90fNenT71bb5r(MNoVW10fcvpWaYFgGjbDoGMwPZd4RuIU2jXpjnmH0Aw49gfqb4bTUUngG2HroVMcJIZJAoOya0vqTh1Cg8M6aORGApidl1BEHRPleQEGbK)matc6CanTsNhWxPeDTtIFsAycP1SW7nkGcWdADDBmaTdJCEnfgfNh1CqXaORGApQ5m4nvvpWaYFgGjdl1RzaFLsGAP11TX2Do46irtopmA0mGVsjqT0662y7ohCDK4NK2SKMafBJVepeQEGbdgDHkz0ystGITXxIhcWdADDBmaTddJgtAcuSn(s8qSPDE5AMVaLFCYCZnpnmH0Aw49gfqHQhya5pdWuoV5IrX5rnhuma6kO2JAodEtDa0vqThKH8NCnXcV3Oa((WWs9A2Ia(kLO9SNU4KagohvqYYOXfb8vkr7zpDXjrt7EDqqEKV5Pb(kLa1sRRBJT7CW1rIMCEy0OzaFLsGAP11TX2Do46iXpjTzjnbk2gFjEiu9adgm6cvYOXKMafBJVepeGh0662yaAhggnM0eOyB8L4Hyt78Y1mFbk)4K5MJrX5rnhuma6kO2JAodEtDa0vqThKHL6f4RuculTUUn2UZbxhjAY5HrJMb8vkbQLwx3gB35GRJe)K0ML0eOyB8L4Hq1dmyWOlujJgtAcuSn(s8qaEqRRBJbODyy0ystGITXxIhInTZlxZ8fO8JtMBogfNh1CqXaORGApQ5m4n1nTZlxZ8fO8JtgwQxZYd4RuIU2jXpXOX(FfNLmOPwSivXRaKh5B0y)pse1oXIHLBoB8L5PHjKwZcV3Oak20oVCnZxGYpoLZBUyuCEuZbfdGUcQ9OMZG3ubpO11TXa0ommSuVaFLs01oj(jPHjKwZcV3OakapO11TXa0omY5nxmkopQ5GIbqxb1EuZzWBQQEGbdgDHkzi)jxtSW7nkGVpmSuVMTiGVsjAp7PlojGHZrfKSmACraFLs0E2txCs00UxheKh5BE68a(kLORDs8tmAS)xXzjdAQflsv8ka5r(gn2)JerTtSyy5MZgFLoVW10fcvpWaYFgGjbDoGMwyuCEuZbfdGUcQ9OMZG3uv9adgm6cvYWs9MhWxPeDTtIFIrJ9)kolzqtTyrQIxbipY3OX(FKiQDIfdl3C24lmkopQ5GIbqxb1EuZzWBQGh0662yaAhggwQxGVsj6ANe)emkopQ5GIbqxb1EuZzWBQdGUcQ9GmK)KRjw49gfW3hgwQxZweWxPeTN90fNeWW5OcswgnUiGVsjAp7PlojAA3RdcYJ8npDEHRPleQEGbK)matc6CanTWO48OMdkgaDfu7rnNbVPoa6kO2dcJcgLmdBrc)wEVWwyDBAc0l8EJcSTNWJAomkopQ5Gcy43Y71Bt7tdjnbHm01fuJrX5rnhuad)wEVm4nvvpWGbJUqLmSuV8z0Rb9jAAFAiPjiKHUUGArt7EDqqEZnt34R0HRPleBEaM662yWy6DbDoGMwyuCEuZbfWWVL3ldEtf8Gwx3gdq7WWWs9c8vkrx7K4NGrX5rnhuad)wEVm4n1bqxb1EqgwQ38a(kLq1t20Xs(Aij(jPdxtxiu9KnDSKVgsc6CanTWO48OMdkGHFlVxg8MQQhyWGrxOsgwQ3(FfNLmOPwSivXRaeZEKLbHRPle9)koZJGUVh1Cc6CanTYutzogfNh1Cqbm8B59YG3uv9adi)zaMmSuVaFLsGAP11TX2Do46iXpjD)pse1oXIHz658UXxyuCEuZbfWWVL3ldEtDa0vqThKHL6T)xXzjdAQflsv8kYXSCZYGW10fI(FfN5rq33JAobDoGMwzQPmhJIZJAoOag(T8EzWBQQEGbdgDHkHrX5rnhuad)wEVm4nvWtFSrXqxxqngfNh1Cqbm8B59YG3u9M7hXIPB6czidPea]] )
    

end
