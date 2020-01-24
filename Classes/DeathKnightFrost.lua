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


    spec:RegisterPack( "Frost DK", 20200124, [[dK0ercqirfpciHnrQmkrItjIAvIQOxjcnlrKBbKO2fIFjs1Wev1XukTmrPEMiW0eb5AIkTnGK6BajY4asY5ebvRtuLQMhqCpaTprrhueuQfkk8qrvctuuLkUOiOWgfvPmsrqjDsrqrReL0lfvjv3uuLOStrs)uuLOAOIQezPIQuPNIIPks5RIQKYEP4VenykDyQwSQ6XinzLCzOntYNby0a1PLSArvsEnkXSjCBLQDRYVvmCs54IQWYL65OA6cxxv2oqQVtQA8IGsCELI1lkz(Ou7h0MTM0mmlpqtQzNF25N)2Stis(j8eaQsaO2WeB0qdJMtzXbGgMZ3rdtERhEaT5DYRBy08nIXxM0mm851u0WaocnEEF6PdOcWVpHo7PZR9NWJAoA7QiDETtt3W8FLisyEMVHz5bAsn78Zo)83MDcrYpHNaqvcY2W4Va80ggMApVWWaUwl8mFdZc5uddOaAZB9WdOnVd6byOnV(vaahqwbfql4i0459PNoGka)(e6SNoV2FcpQ5OTRI051onDiRGcOLv)EEVbAZEBsqB25ND(qwHSckG28cW(ba559qwbfqlOm0MW8OI3cH28YQBbT5TgXSqcKvqb0ckdTjSxlOv5cX3PSaTQPH2hVoaqBcJ8U51scAZln5nOTuqRMW3Gn0wxfLhihAZyyG2pQMgHwTze1baAfdGIcTfhAPZUMadCrGSckGwqzOnVaSFaqOn8gagKO2rzmYvHqBmqBu7Omg5QqOngO9XrOfp68UaBOvGhGam02EagBOna7h0QnbEr5cOnANdgAxOhG5eiRGcOfugAZlgXcAtyf9oGw)wqB70YfqBOhDw4edJO4b3KMHHoILem6DysZK6wtAgg88VaxMmmm0UcSl3W8FkfHoILem6Dq4HtzbAZeAZfA1bTrTJYyKRcHwqGwa0LHXPrnNHHc2RJlhLSOOjmPMTjnddE(xGltgggAxb2LBysbA)pLIWrmaxhaz7aqsJ7EDCOfeOfaDbTjdT6G2)tPiCedW1bq2oaK80mmonQ5mmuWEDC5OKffnHj1eysZWGN)f4YKHHH2vGD5gMuG2)tPiALq4TCusvp8G04UxhhAbbi0cGUG28eAtbA3cTjcT0zeRr)ru9Wd9B6DUu96nKg91gOnzOLnBO9)ukIwjeElhLu1dpinU71XHwqG2(DijQDugJmbqBYqRoO9)ukIwjeElhLu1dpipnOvh0Mc06zHDfiPOBK0k8fkiTFSaTGaeA3cTSzdT)Nsr(n6by5OK86wTdy4o5PbTjdT6G2CG2Wf4fKIIuxJGN)f4YW40OMZWqb71XLJswu0eMutitAgg88VaxMmmm0UcSl3W8FkfrRecVLJsQ6HhKg3964qliqlOcA1bT)NsrEh4rSrYJgpabysJ7EDCOfeOfaDbT5j0Mc0UfAteAPZiwJ(JO6Hh6307CP61Bin6RnqBYqRoO9)ukY7apInsE04biatAC3RJdT6G2)tPiALq4TCusvp8G80GwDqBkqRNf2vGKIUrsRWxOG0(Xc0ccqODl0YMn0(Fkf53OhGLJsYRB1oGH7KNg0Mm0QdAZbAdxGxqkksDncE(xGldJtJAoddfSxhxokzrrtysnxtAgg88VaxMmmm0UcSl3WKc0(FkfPOBK0k8fkinU71XHwqG2ecAzZgA)pLIu0nsAf(cfKg3964qliqB)oKe1okJrMaOnzOvh0(FkfPOBK0k8fkipnOvh06zHDfiPOBK0k8fkiTFSaTzceAZgA1bT5aT)Nsr(n6by5OK86wTdy4o5PbT6G2CG2Wf4fKIIuxJGN)f4YW40OMZWqb71XLJswu0eMub1M0mm45FbUmzyyODfyxUH5)uksr3iPv4luqEAqRoO9)ukY7apInsE04biatEAqRoO1Zc7kqsr3iPv4luqA)ybAZei0Mn0QdAZbA)pLI8B0dWYrj51TAhWWDYtdA1bT5aTHlWliffPUgbp)lWLHXPrnNHHc2RJlhLSOOjmPckzsZWGN)f4YKHHH2vGD5gM)tPiALq4TCusvp8G04UxhhAbbAtiOvh0(FkfrRecVLJsQ6HhKNg0QdAdxGxqkksDncE(xGlOvh0(FkfHoILem6Dq4HtzbAZei0UfubT6GwplSRajfDJKwHVqbP9JfOfeGq7wdJtJAoddfSxhxokzrrtysfuzsZWGN)f4YKHHH2vGD5gM)tPiALq4TCusvp8G80GwDqB4c8csrrQRrWZ)cCbT6GwplSRajfDJKwHVqbP9JfOntGqB2qRoOnfO9)ukcDeljy07GWdNYc0MjqODBchA1bT)Nsrk6gjTcFHcsJ7EDCOfeOfaDbT6G2)tPifDJKwHVqb5PbTSzdT)NsrEh4rSrYJgpabyYtdA1bT)NsrOJyjbJEheE4uwG2mbcTBbvqBYggNg1CggkyVoUCuYIIMWegM5lQaBpQ5mPzsDRjnddE(xGltgggAxb2LBycxGxqa4bySRdGKhtVtWZ)cCzyCAuZzyACFAokqoxQVUaBtysnBtAgg88VaxMmmmonQ5mmZxub2EGggAxb2LBysbAx4)PuK2ZA6IIeE4uwGwqG2CHw2SH2f(FkfP9SMUOiPXDVoo0cc0UnFOnzOvh0Md0gUaVGO6HhC6MamsWZ)cCbT6G2CG2)tPiDTJKNg0QdA5AOqidVbGbNaE0lQdG8lCEaTzceAtGHHUHkqz4nam4Mu3ActQjWKMHbp)lWLjdddTRa7Ynm5aTHlWliQE4bNUjaJe88VaxqRoOnhO9)uksx7i5PbT6GwUgkeYWBayWjGh9I6ai)cNhqBMaH2eyyCAuZzyMVOcS9anHj1eYKMHbp)lWLjdddTRa7YnmPaT)NsryPeI6ai3Dk46qsJonGw2SH2uG2)tPiSucrDaK7ofCDi5PbT6G2uGwTgbTeaDr2su9Wdjp6IfeAzZgA1Ae0sa0fzlb8Oxuha5x48aAzZgA1Ae0sa0fzlbGWPLlK(c0(rrOnzOnzOnzOvh0Y1qHqgEdador1dp40nbyeAZei0MTHXPrnNHr1dp40nby0eMuZ1KMHbp)lWLjddJtJAodZ8fvGThOHH2vGD5gMuG2f(FkfP9SMUOiHhoLfOfeOnxOLnBODH)NsrApRPlksAC3RJdTGaTBZhAtgA1bT)NsryPeI6ai3Dk46qsJonGw2SH2uG2)tPiSucrDaK7ofCDi5PbT6G2uGwTgbTeaDr2su9Wdjp6IfeAzZgA1Ae0sa0fzlb8Oxuha5x48aAzZgA1Ae0sa0fzlbGWPLlK(c0(rrOnzOnzddDdvGYWBayWnPU1eMub1M0mm45FbUmzyyODfyxUH5)ukclLquha5UtbxhsA0Pb0YMn0Mc0(FkfHLsiQdGC3PGRdjpnOvh0Mc0Q1iOLaOlYwIQhEi5rxSGqlB2qRwJGwcGUiBjGh9I6ai)cNhqlB2qRwJGwcGUiBjaeoTCH0xG2pkcTjdTjByCAuZzyMVOcS9anHjvqjtAgg88VaxMmmm0UcSl3WKc0Md0(FkfPRDK80Gw2SH2(DfvQn6XMSqvrRaAbbA3Mp0YMn02VdjrTJYyKzdTzcTaOlOnzOvh0Y1qHqgEdadobGWPLlK(c0(rrOntGqB2ggNg1CggacNwUq6lq7hfnHjvqLjnddE(xGltgggAxb2LBy(pLI01osEAqRoOLRHcHm8gagCc4rVOoaYVW5b0MjqOnBdJtJAodd4rVOoaYVW5HjmPMWnPzyWZ)cCzYWW40OMZWO6HhsE0flOHH2vGD5gMuG2f(FkfP9SMUOiHhoLfOfeOnxOLnBODH)NsrApRPlksAC3RJdTGaTBZhAtgA1bT5aT)Nsr6AhjpnOLnBOTFxrLAJESjluv0kGwqG2T5dTSzdT97qsu7Omgz2qBMqla6cA1bT5aTHlWliQE4bNUjaJe88Vaxgg6gQaLH3aWGBsDRjmPUnFtAgg88VaxMmmm0UcSl3WKd0(FkfPRDK80Gw2SH2(DfvQn6XMSqvrRaAbbA3Mp0YMn02VdjrTJYyKzdTzcTaOldJtJAodJQhEi5rxSGMWK62TM0mm45FbUmzyyODfyxUH5)uksx7i5PzyCAuZzyap6f1bq(fopmHj1TzBsZWGN)f4YKHHXPrnNHz(IkW2d0Wq7kWUCdtkq7c)pLI0EwtxuKWdNYc0cc0Ml0YMn0UW)tPiTN10ffjnU71XHwqG2T5dTjdT6G2CG2Wf4fevp8Gt3eGrcE(xGlddDdvGYWBayWnPU1eMu3MatAggNg1CgM5lQaBpqddE(xGltgMWegM)WLrrzPoaM0mPU1KMHbp)lWLjdddTRa7Ynm0zeRr)rWDTrp2Y(DOup6AZrAC3RJByCAuZzy0kHWB5OKQE4HjmPMTjndJtJAoddURn6Xw2VdL6rxBoddE(xGltgMWKAcmPzyWZ)cCzYWW40OMZWmFrfy7bAyODfyxUHjfODH)NsrApRPlks4HtzbAbbAZfAzZgAx4)PuK2ZA6IIKg3964qliq728H2KHwDqB)UIk1g9ydTGaeAtq2qRoOnhOnCbEbr1dp40nbyKGN)f4YWq3qfOm8gagCtQBnHj1eYKMHbp)lWLjdddTRa7Ynm97kQuB0Jn0ccqOnbzByCAuZzyMVOcS9anHj1CnPzyWZ)cCzYWWq7kWUCdt4c8ccapaJDDaK8y6DcE(xGldJtJAodtJ7tZrbY5s91fyBctQGAtAgg88VaxMmmm0UcSl3W8FkfPRDK80mmonQ5mmGh9I6ai)cNhMWKkOKjnddE(xGltgggNg1CgM5lQaBpqddTRa7YnmPaTl8)uks7znDrrcpCklqliqBUqlB2q7c)pLI0EwtxuK04UxhhAbbA3Mp0Mm0QdA73HKO2rzmYCHwqGwa0f0YMn02VROsTrp2qliaH2ekxOvh0Md0gUaVGO6HhC6MamsWZ)cCzyOBOcugEdadUj1TMWKkOYKMHbp)lWLjdddTRa7Ynm97qsu7OmgzUqliqla6cAzZgA73vuP2OhBOfeGqBcLRHXPrnNHz(IkW2d0eMut4M0mm45FbUmzyyODfyxUH5)ukclLquha5UtbxhsEAqRoOLRHcHm8gagCIQhEWPBcWi0MjqOnBdJtJAodJQhEWPBcWOjmPUnFtAgg88VaxMmmm0UcSl3W0VROsTrp2KfQkAfqBMaH2eKn0QdA73HKO2rzmYeaTzcTaOldJtJAodd4Pp5OK6RlW2eMu3U1KMHXPrnNHPX9P5Oa5CP(6cSnm45FbUmzyctQBZ2KMHbp)lWLjdddTRa7YnmCnuiKH3aWGtu9WdoDtagH2mbcTzByCAuZzyu9WdoDtagnHj1TjWKMHbp)lWLjddJtJAodZ8fvGThOHH2vGD5gMuG2f(FkfP9SMUOiHhoLfOfeOnxOLnBODH)NsrApRPlksAC3RJdTGaTBZhAtgA1bT97kQuB0JnzHQIwb0Mj0MDUqlB2qB)oeAZeAta0QdAZbAdxGxqu9WdoDtagj45FbUmm0nubkdVbGb3K6wtysDBczsZWGN)f4YKHHH2vGD5gM(DfvQn6XMSqvrRaAZeAZoxOLnBOTFhcTzcTjWW40OMZWmFrfy7bActQBZ1KMHbp)lWLjdddTRa7Ynm97kQuB0JnzHQIwb0Mj0MB(ggNg1CggVP(HYy6gVWeMWWGCoEuKBsZK6wtAgg88VaxMmmm0UcSl3W8FkfrRecVLJsQ6HhKNg0QdAtbA)pLIOvcH3Yrjv9WdsJ7EDCOfeODB(qRoOnfO9)ukYVrpalhLKx3QDad3jpnOLnBOnCbEbz(IkW2JAocE(xGlOLnBOnCbEbPOi11i45FbUGwDqBoqRNf2vGKIUrsRWxOGGN)f4cAtgAzZgA)pLIu0nsAf(cfKNg0QdAdxGxqkksDncE(xGlOnzdJtJAodZxmZsokzagL4H7BmHj1SnPzyWZ)cCzYWWq7kWUCdtoqB4c8csrrQRrWZ)cCbTSzdTHlWliffPUgbp)lWf0QdA9SWUcKu0nsAf(cfe88VaxqRoO9)ukIwjeElhLu1dpinU71XHwqGwqn0QdA)pLIOvcH3Yrjv9WdYtdAzZgAdxGxqkksDncE(xGlOvh0Md06zHDfiPOBK0k8fki45FbUmmonQ5mmaEEVk)KJs6zH9eGnHj1eysZWGN)f4YKHHH2vGD5gM)tPiALq4TCusvp8G04UxhhAbbAZfA1bT)Nsr0kHWB5OKQE4b5PbTSzdTrTJYyKRcHwqG2CnmonQ5mmuWLqi5rJolMWKAczsZWGN)f4YKHHH2vGD5gM)tPinszrGCUunnfjpnOLnBO9)uksJuweiNlvttrjDExGnHhoLfOfeOD7wdJtJAodtagLV7pVBjvttrtysnxtAgg88VaxMmmm0UcSl3WKd0(FkfrRecVLJsQ6HhKNg0QdAZbA)pLI8B0dWYrj51TAhWWDYtZW40OMZWOg6JJlPNf2vGYp67MWKkO2KMHbp)lWLjdddTRa7Ynm5aT)Nsr0kHWB5OKQE4b5PbT6G2CG2)tPi)g9aSCusEDR2bmCN80GwDq7AccDokEr7bUKkHVJY)RpsJ7EDCOfi0MVHXPrnNHHohfVO9axsLW3rtysfuYKMHbp)lWLjdddTRa7Ynm5aT)Nsr0kHWB5OKQE4b5PbT6G2CG2)tPi)g9aSCusEDR2bmCN80mmonQ5mmAVUuBQdG8lCEyctQGktAgg88VaxMmmm0UcSl3W8FkfrRecVLJsQ6HhKNg0YMn0(Fkfb31g9yl73Hs9ORnh5PbTSzdT0zeRr)r(n6by5OK86wTdy4oPXDVoo0Mj0cQZhAteA3MRHXPrnNHr)0IfOX6KnYNZpkActQjCtAgg88VaxMmmm0UcSl3WKd0(FkfrRecVLJsQ6HhKNg0QdAZbA)pLI8B0dWYrj51TAhWWDYtZW40OMZW0LMMaL1j5AofnHj1T5BsZWGN)f4YKHHH2vGD5gM)tPi4U2OhBz)ouQhDT5inU71XHwqG2CHwDq7)PuKFJEawokjVUv7agUtEAqlB2qBkqB)oKe1okJrMn0Mj0cGUGwDqB)UIk1g9ydTGaT5Mp0MSHXPrnNHzh3NEJCusXJwl5QrFNBctQB3AsZW40OMZW0ORvhaPs47i3WGN)f4YKHjmHH5pCP2mI6aysZK6wtAgg88VaxMmmm0UcSl3W8FkfPRDK80mmonQ5mmGh9I6ai)cNhMWKA2M0mm45FbUmzyyCAuZzyMVOcS9anm0UcSl3WKc0UW)tPiTN10ffj8WPSaTGaT5cTSzdTl8)uks7znDrrsJ7EDCOfeODB(qBYqRoOTFxrLAJESjluv0kG2mbcTzNl0QdAZbAdxGxqu9WdoDtagj45FbUmm0nubkdVbGb3K6wtysnbM0mm45FbUmzyyODfyxUHPFxrLAJESjluv0kG2mbcTzNRHXPrnNHz(IkW2d0eMutitAgg88VaxMmmm0UcSl3W0VROsTrp2KfQkAfqliqB25dT6GwUgkeYWBayWjaeoTCH0xG2pkcTzceAZgA1bT0zeRr)r0kHWB5OKQE4bPXDVoo0Mj0MRHXPrnNHbGWPLlK(c0(rrtysnxtAgg88VaxMmmmonQ5mmQE4HKhDXcAyODfyxUHjfODH)NsrApRPlks4HtzbAbbAZfAzZgAx4)PuK2ZA6IIKg3964qliq728H2KHwDqB)UIk1g9ytwOQOvaTGaTzNp0QdAZbAdxGxqu9WdoDtagj45FbUGwDqlDgXA0FeTsi8wokPQhEqAC3RJdTzcT5AyOBOcugEdadUj1TMWKkO2KMHbp)lWLjdddTRa7Ynm97kQuB0JnzHQIwb0cc0MD(qRoOLoJyn6pIwjeElhLu1dpinU71XH2mH2CnmonQ5mmQE4HKhDXcActQGsM0mm45FbUmzyyODfyxUH5)ukclLquha5UtbxhsEAqRoOTFxrLAJESjluv0kG2mH2uG2T5cTjcTHlWli97kQ0JaVNh1Ce88VaxqBEcTjaAtgA1bTCnuiKH3aWGtu9WdoDtagH2mbcTzByCAuZzyu9WdoDtagnHjvqLjnddE(xGltgggAxb2LBy63vuP2OhBYcvfTcOntGqBkqBcYfAteAdxGxq63vuPhbEppQ5i45FbUG28eAta0Mm0QdA5AOqidVbGbNO6HhC6MamcTzceAZ2W40OMZWO6HhC6MamActQjCtAgg88VaxMmmmonQ5mmZxub2EGggAxb2LBysbAx4)PuK2ZA6IIeE4uwGwqG2CHw2SH2f(FkfP9SMUOiPXDVoo0cc0UnFOnzOvh02VROsTrp2KfQkAfqBMaH2uG2eKl0Mi0gUaVG0VROspc8EEuZrWZ)cCbT5j0MaOnzOvh0Md0gUaVGO6HhC6MamsWZ)cCzyOBOcugEdadUj1TMWK628nPzyWZ)cCzYWWq7kWUCdt)UIk1g9ytwOQOvaTzceAtbAtqUqBIqB4c8cs)UIk9iW75rnhbp)lWf0MNqBcG2KnmonQ5mmZxub2EGMWK62TM0mm45FbUmzyyODfyxUHHoJyn6pIwjeElhLu1dpinU71XH2mH2(DijQDugJmHGwDqB)UIk1g9ytwOQOvaTGaTju(qRoOLRHcHm8gagCcaHtlxi9fO9JIqBMaH2SnmonQ5mmaeoTCH0xG2pkActQBZ2KMHbp)lWLjddJtJAodJQhEi5rxSGggAxb2LBysbAx4)PuK2ZA6IIeE4uwGwqG2CHw2SH2f(FkfP9SMUOiPXDVoo0cc0UnFOnzOvh0sNrSg9hrRecVLJsQ6HhKg3964qBMqB)oKe1okJrMqqRoOTFxrLAJESjluv0kGwqG2ekFOvh0Md0gUaVGO6HhC6MamsWZ)cCzyOBOcugEdadUj1TMWK62eysZWGN)f4YKHHH2vGD5gg6mI1O)iALq4TCusvp8G04UxhhAZeA73HKO2rzmYecA1bT97kQuB0JnzHQIwb0cc0Mq5ByCAuZzyu9Wdjp6If0eMWWO1iD2)EysZK6wtAggNg1CggTjQ5mm45FbUmzyctQzBsZWGN)f4YKHH58D0W4zXb7TZLQ5c5OKAJESnmonQ5mmEwCWE7CPAUqokP2OhBtysnbM0mm45FbUmzyygnddhddJtJAoddO9U8VanmG2fp0WKc0I5XR00Wf5My6AECjaHVkpMMl)(cacTSzdTyE8knnCr41v8aBjaHVkpMMl)(cacTSzdTyE8knnCr41v8aBjaHVkpMMl3XLle1CqlB2qlMhVstdxeqxUqokPF1Uh4s(fZSGw2SHwmpELMgUiQQ5HC3dKl5ABaiCohAzZgAX84vAA4IKxHCj4rVaBOLnBOfZJxPPHlYnX0184sacFvEmnxUJlxiQ5Gw2SHwmpELMgUiohmO9d5Y2ZAAjDAxaTjByaT3YZ3rdZeGXwoN8XrjMhVstdxMWegg6mI1O)4M0mPU1KMHbp)lWLjddJtJAodJNfhS3oxQMlKJsQn6X2Wq7kWUCdtkqlDgXA0FeCxB0JTSFhk1JU2CKg91gOvh0Md0cAVl)lqYeGXwoN8XrjMhVstdxqBYqlB2qBkqlDgXA0FeTsi8wokPQhEqAC3RJdTGaeA3Mp0QdAbT3L)fizcWylNt(4OeZJxPPHlOnzdZ57OHXZId2BNlvZfYrj1g9yBctQzBsZWGN)f4YKHHXPrnNHr8AwWMlRJxRAECjGsfggAxb2LBycxGxq(n6by5OK86wTdy4obp)lWf0QdAtbAtbAPZiwJ(JOvcH3Yrjv9WdsJ7EDCOfeGq728HwDqlO9U8VajtagB5CYhhLyE8knnCbTjdTSzdTPaT)Nsr0kHWB5OKQE4b5PbT6G2CGwq7D5FbsMam2Y5KpokX84vAA4cAtgAtgAzZgAtbA)pLIOvcH3Yrjv9WdYtdA1bT5aTHlWli)g9aSCusEDR2bmCNGN)f4cAt2WC(oAyeVMfS5Y641QMhxcOuHjmPMatAgg88VaxMmmmonQ5mm0nuXe9Cfv(fopmm0UcSl3WKd0(FkfrRecVLJsQ6HhKNMH58D0Wq3qft0Zvu5x48WeMutitAgg88VaxMmmm0UcSl3WKc0sNrSg9hrRecVLJsQ6HhKg91gOLnBOLoJyn6pIwjeElhLu1dpinU71XH2mH2SZhAtgA1bTPaT5aTHlWli)g9aSCusEDR2bmCNGN)f4cAzZgAPZiwJ(JG7AJESL97qPE01MJ04UxhhAZeAt45cTjByCAuZzyECuwbUZnHj1CnPzyWZ)cCzYWW40OMZW4CWG2pKlBpRPL0PDHHH2vGD5gMf(FkfP9SMwsN2fYf(Fkfzn6pdZ57OHX5GbTFix2EwtlPt7ctysfuBsZWGN)f4YKHHXPrnNHX5GbTFix2EwtlPt7cddTRa7Ynm0zeRr)rWDTrp2Y(DOup6AZrAC3RJdTzcTj88HwDq7c)pLI0EwtlPt7c5c)pLI80GwDqlO9U8VajtagB5CYhhLyE8knnCbTSzdT)Nsr(n6by5OK86wTdy4o5PbT6G2f(FkfP9SMwsN2fYf(Fkf5PbT6G2CGwq7D5FbsMam2Y5KpokX84vAA4cAzZgA)pLIG7AJESL97qPE01MJ80GwDq7c)pLI0EwtlPt7c5c)pLI80GwDqBoqB4c8cYVrpalhLKx3QDad3j45FbUGw2SH2O2rzmYvHqliqB2BnmNVJggNdg0(HCz7znTKoTlmHjvqjtAgg88VaxMmmmonQ5mm5vixcE0lW2Wq7kWUCdtkqlMhVstdxeXRzbBUSoETQ5XLakvaT6G2)tPiALq4TCusvp8G04UxhhAtgAzZgAtbAZbAX84vAA4IiEnlyZL1XRvnpUeqPcOvh0(FkfrRecVLJsQ6HhKg3964qliq72SHwDq7)PueTsi8wokPQhEqEAqBYgMZ3rdtEfYLGh9cSnHjvqLjnddE(xGltgggNg1CggwUjKJs6hTWlKQxVXWq7kWUCddDgXA0FeCxB0JTSFhk1JU2CKg3964qBMqBcLVH58D0WWYnHCus)OfEHu96nMWKAc3KMHbp)lWLjddJtJAoddGEoaCPwx7Uq2oa0Wq7kWUCdt)oeAbbi0MaOvh0Md0(FkfrRecVLJsQ6HhKNg0QdAtbAZbA)pLI8B0dWYrj51TAhWWDYtdAzZgAZbAdxGxq(n6by5OK86wTdy4obp)lWf0MSH58D0WaONdaxQ11UlKTdanHj1T5BsZWGN)f4YKHH58D0W0EwR3Xcx(laYgxY)lI5mmonQ5mmTN16DSWL)cGSXL8)IyotysD7wtAgg88VaxMmmmonQ5mm7yJSeGDUu5haddTRa7Ynm5aT)Nsr(n6by5OK86wTdy4o5PbT6G2CG2)tPiALq4TCusvp8G80mmNVJgMDSrwcWoxQ8dGjmPUnBtAgg88VaxMmmm0UcSl3W8FkfrRecVLJsQ6HhKNg0QdA)pLIG7AJESL97qPE01MJ80mmonQ5mmAtuZzctQBtGjnddE(xGltgggAxb2LBy(pLIOvcH3Yrjv9WdYtdA1bT)NsrWDTrp2Y(DOup6AZrEAggNg1CgMVyMLu96nMWK62eYKMHbp)lWLjdddTRa7Ynm)Nsr0kHWB5OKQE4b5PzyCAuZzy(yZXML6ayctQBZ1KMHbp)lWLjdddTRa7YnmPaT5aT)Nsr0kHWB5OKQE4b5PbT6GwNgfOrjE4EHCOntGqB2qBYqlB2qBoq7)PueTsi8wokPQhEqEAqRoOnfOTFhswOQOvaTzceAZfA1bT97kQuB0JnzHQIwb0MjqOfuNp0MSHXPrnNHXBQFOu7j4OjmPUfuBsZWGN)f4YKHHH2vGD5gM)tPiALq4TCusvp8G80mmonQ5mmIca4GlZREla74fMWK6wqjtAgg88VaxMmmm0UcSl3W8FkfrRecVLJsQ6HhKNg0QdA)pLIG7AJESL97qPE01MJ80mmonQ5mm(rrE0UqsDHWeMu3cQmPzyWZ)cCzYWWq7kWUCdZ)PueTsi8wokPQhEqAC3RJdTGaeAbvqRoO9)ukcURn6Xw2VdL6rxBoYtZW40OMZWOQg)IzwMWK62eUjnddE(xGltgggAxb2LBy(pLIOvcH3Yrjv9WdYtdA1bTPaT)Nsr0kHWB5OKQE4bPXDVoo0cc0Ml0QdAdxGxqOJyjbJEhe88VaxqlB2qBoqB4c8ccDeljy07GGN)f4cA1bT)Nsr0kHWB5OKQE4bPXDVoo0cc0MaOnzOvh060OankXd3lKdTaH2TqlB2q7)PueoIb46aiBhasEAqRoO1PrbAuIhUxihAbcTBnmonQ5mmFhGCuYOlklCtysn78nPzyWZ)cCzYWWq7kWUCddDgXA0FeCxB0JTSFhk1JU2CKg3964qlB2qB4c8csrrQRrWZ)cCzyCAuZzy0kHWB5OKQE4HjmPM9wtAgg88VaxMmmm0UcSl3WqNrSg9hb31g9yl73Hs9ORnhPXDVoo0QdAPZiwJ(JOvcH3Yrjv9WdsJ7EDCdJtJAodZVrpalhLKx3QDad3nmpokhLscGUmmBnHj1SZ2KMHbp)lWLjdddTRa7Ynm0zeRr)r0kHWB5OKQE4bPrFTbA1bTHlWliZxub2EuZrWZ)cCbT6G2(DijQDugJmxOntOfaDbT6G2(DfvQn6XMSqvrRaAZei0UnFOLnBOnQDugJCvi0cc0MD(ggNg1CggCxB0JTSFhk1JU2CMWKA2jWKMHbp)lWLjdddTRa7YnmPaT0zeRr)r0kHWB5OKQE4bPrFTbAzZgAJAhLXixfcTGaTzNp0Mm0QdAdxGxq(n6by5OK86wTdy4obp)lWf0QdA73vuP2OhBOntOfuNVHXPrnNHb31g9yl73Hs9ORnNjmPMDczsZWGN)f4YKHHH2vGD5gMWf4fKIIuxJGN)f4cA1bT97qOfeOnbggNg1CggCxB0JTSFhk1JU2CMWKA25AsZWGN)f4YKHHH2vGD5gMWf4fe6iwsWO3bbp)lWf0QdAtbAtbA)pLIqhXscg9oi8WPSaTzceA3Mp0QdAx4)PuK2ZA6IIeE4uwGwGqBUqBYqlB2qBu7Omg5QqOfeGqla6cAt2W40OMZWqDHq60OMtkkEyyefpKNVJgg6iwsWO3HjmPMnO2KMHbp)lWLjdddTRa7YnmPaT)Nsr0kHWB5OKQE4b5PbT6GwplSRajfDJKwHVqbP9JfOfeGq7wOvh0Mc0(FkfrRecVLJsQ6HhKg3964qliaHwa0f0YMn0(Fkf5DGhXgjpA8aeGjnU71XHwqacTaOlOvh0(Fkf5DGhXgjpA8aeGjpnOnzOnzdJtJAodJQhEOFtVZLQxVXeMuZguYKMHbp)lWLjdddTRa7YnmPaT)Nsrk6gjTcFHcYtdA1bT5aTHlWliffPUgbp)lWf0QdAtbA)pLI8oWJyJKhnEacWKNg0YMn0(FkfPOBK0k8fkinU71XHwqacTaOlOnzOnzOLnBO9)uksr3iPv4luqEAqRoO9)uksr3iPv4luqAC3RJdTGaeAbqxqRoOnCbEbPOi11i45FbUGwDq7)PueTsi8wokPQhEqEAggNg1Cggvp8q)MENlvVEJjmPMnOYKMHbp)lWLjdddTRa7YnmrTJYyKRcHwqGwa0f0YMn0Mc0g1okJrUkeAbbAPZiwJ(JOvcH3Yrjv9WdsJ7EDCOvh0(Fkf5DGhXgjpA8aeGjpnOnzdJtJAodJQhEOFtVZLQxVXeMWWWd)wEVmPzsDRjndJtJAodtJ7tZrbY5s91fyByWZ)cCzYWeMuZ2KMHbp)lWLjdddTRa7Ynm0zeRr)rACFAokqoxQVUaBsJ7EDCOfeGqB2qBEcTaOlOvh0gUaVGaWdWyxhajpMENGN)f4YW40OMZWO6HhsE0flOjmPMatAgg88VaxMmmm0UcSl3W8FkfPRDK80mmonQ5mmGh9I6ai)cNhMWKAczsZWGN)f4YKHHH2vGD5gMWf4fKIIuxJGN)f4cA1bT)Nsr0kHWB5OKQE4b5PbT6GwplSRajfDJKwHVqbP9JfOntGqB2ggNg1CgM5lQaBpqtysnxtAgg88VaxMmmm0UcSl3WKd0(Fkfr1tw4j1EcosEAqRoOnCbEbr1tw4j1EcosWZ)cCzyCAuZzyMVOcS9anHjvqTjnddE(xGltgggAxb2LBy63vuP2OhBYcvfTcOfeOnfODBUqBIqB4c8cs)UIk9iW75rnhbp)lWf0MNqBcG2KnmonQ5mmQE4HKhDXcActQGsM0mm45FbUmzyyODfyxUH5)ukclLquha5UtbxhsEAqRoOTFhsIAhLXitiOntGqla6YW40OMZWO6HhC6MamActQGktAgg88VaxMmmm0UcSl3W0VROsTrp2KfQkAfqBMqBkqB25cTjcTHlWli97kQ0JaVNh1Ce88VaxqBEcTjaAt2W40OMZWmFrfy7bActQjCtAggNg1Cggvp8qYJUybnm45FbUmzyctQBZ3KMHXPrnNHb80NCus91fyByWZ)cCzYWeMu3U1KMHXPrnNHXBQFOmMUXlmm45FbUmzyctyywOYFIWKMj1TM0mmonQ5mm71TKQgXSqddE(xGltgMWKA2M0mm45FbUmzyyODfyxUHjhODnbr1dpKke0ytIIYsDaGwDqBkqBoqB4c8cYVrpalhLKx3QDad3j45FbUGw2SHw6mI1O)i)g9aSCusEDR2bmCN04UxhhAZeA3Ml0MSHXPrnNHb8Oxuha5x48WeMutGjnddE(xGltgggAxb2LBy(pLIu0nYWfZXjnU71XHwqacTaOlOvh0(FkfPOBKHlMJtEAqRoOLRHcHm8gagCcaHtlxi9fO9JIqBMaH2SHwDqBkqBoqB4c8cYVrpalhLKx3QDad3j45FbUGw2SHw6mI1O)i)g9aSCusEDR2bmCN04UxhhAZeA3Ml0MSHXPrnNHbGWPLlK(c0(rrtysnHmPzyWZ)cCzYWWq7kWUCdZ)PuKIUrgUyooPXDVoo0ccqOfaDbT6G2)tPifDJmCXCCYtdA1bTPaT5aTHlWli)g9aSCusEDR2bmCNGN)f4cAzZgAPZiwJ(J8B0dWYrj51TAhWWDsJ7EDCOntODBUqBYggNg1Cggvp8qYJUybnHj1CnPzyWZ)cCzYWW40OMZWqDHq60OMtkkEyyefpKNVJggKZXJICtysfuBsZWGN)f4YKHHXPrnNHH6cH0PrnNuu8WWikEipFhnm0zeRr)XnHjvqjtAgg88VaxMmmm0UcSl3WeUaVG8B0dWYrj51TAhWWDcE(xGlOvh0Mc0Mc0sNrSg9h53OhGLJsYRB1oGH7Kg3964qlqOnFOvh0sNrSg9hrRecVLJsQ6HhKg3964qliq728H2KHw2SH2uGw6mI1O)i)g9aSCusEDR2bmCN04UxhhAbbAZoFOvh0g1okJrUkeAbbAtqUqBYqBYggNg1CgM(DsNg1CsrXddJO4H88D0W8hUuBgrDamHjvqLjnddE(xGltgggAxb2LBy(pLI8B0dWYrj51TAhWWDYtZW40OMZW0Vt60OMtkkEyyefpKNVJgM)WLrrzPoaMWKAc3KMHbp)lWLjdddTRa7Ynm)Nsr0kHWB5OKQE4b5PbT6G2Wf4fK5lQaBpQ5i45FbUmmonQ5mm97KonQ5KIIhggrXd557OHz(IkW2JAotysDB(M0mm45FbUmzyyODfyxUHXPrbAuIhUxihAZei0MTHXPrnNHPFN0PrnNuu8WWikEipFhnm(GMWK62TM0mm45FbUmzyyCAuZzyOUqiDAuZjffpmmIIhYZ3rddp8B59YeMWW4dAsZK6wtAgg88VaxMmmm0UcSl3WeUaVGaWdWyxhajpMENGN)f4cAzZgAtbA9SWUcKO6jl8KbURH8G0(Xc0QdA5AOqidVbGbN04(0CuGCUuFDb2qBMaH2eaT6G2CG2)tPiDTJKNg0MSHXPrnNHPX9P5Oa5CP(6cSnHj1SnPzyWZ)cCzYWWq7kWUCdt4c8cIQhEWPBcWibp)lWLHXPrnNHbGWPLlK(c0(rrtysnbM0mm45FbUmzyyCAuZzyu9Wdjp6If0Wq7kWUCdtkq7c)pLI0EwtxuKWdNYc0cc0Ml0YMn0UW)tPiTN10ffjnU71XHwqG2T5dTjdT6Gw6mI1O)inUpnhfiNl1xxGnPXDVoo0ccqOnBOnpHwa0f0QdAdxGxqa4bySRdGKhtVtWZ)cCbT6G2CG2Wf4fevp8Gt3eGrcE(xGlddDdvGYWBayWnPU1eMutitAgg88VaxMmmm0UcSl3WqNrSg9hPX9P5Oa5CP(6cSjnU71XHwqacTzdT5j0cGUGwDqB4c8ccapaJDDaK8y6DcE(xGldJtJAodJQhEi5rxSGMWKAUM0mm45FbUmzyyODfyxUH5)uksx7i5PzyCAuZzyap6f1bq(fopmHjvqTjnddE(xGltgggAxb2LBy(pLIWsje1bqU7uW1HKNMHXPrnNHr1dp40nby0eMubLmPzyWZ)cCzYWWq7kWUCdt)UIk1g9ytwOQOvaTGaTPaTBZfAteAdxGxq63vuPhbEppQ5i45FbUG28eAta0MSHXPrnNHbGWPLlK(c0(rrtysfuzsZWGN)f4YKHHXPrnNHr1dpK8OlwqddTRa7YnmPaTl8)uks7znDrrcpCklqliqBUqlB2q7c)pLI0EwtxuK04UxhhAbbA3Mp0Mm0QdA73vuP2OhBYcvfTcOfeOnfODBUqBIqB4c8cs)UIk9iW75rnhbp)lWf0MNqBcG2KHwDqBoqB4c8cIQhEWPBcWibp)lWLHHUHkqz4nam4Mu3ActQjCtAgg88VaxMmmm0UcSl3W0VROsTrp2KfQkAfqliqBkq72CH2eH2Wf4fK(Dfv6rG3ZJAocE(xGlOnpH2eaTjdT6G2CG2Wf4fevp8Gt3eGrcE(xGldJtJAodJQhEi5rxSGMWK628nPzyCAuZzyACFAokqoxQVUaBddE(xGltgMWK62TM0mmonQ5mmQE4bNUjaJgg88VaxMmmHj1TzBsZWGN)f4YKHHXPrnNHz(IkW2d0Wq7kWUCdtkq7c)pLI0EwtxuKWdNYc0cc0Ml0YMn0UW)tPiTN10ffjnU71XHwqG2T5dTjdT6G2(DfvQn6XMSqvrRaAZeAtbAZoxOnrOnCbEbPFxrLEe498OMJGN)f4cAZtOnbqBYqRoOnhOnCbEbr1dp40nbyKGN)f4YWq3qfOm8gagCtQBnHj1TjWKMHbp)lWLjdddTRa7Ynm97kQuB0JnzHQIwb0Mj0Mc0MDUqBIqB4c8cs)UIk9iW75rnhbp)lWf0MNqBcG2KnmonQ5mmZxub2EGMWK62eYKMHXPrnNHbGWPLlK(c0(rrddE(xGltgMWK62CnPzyWZ)cCzYWW40OMZWO6HhsE0flOHH2vGD5gMuG2f(FkfP9SMUOiHhoLfOfeOnxOLnBODH)NsrApRPlksAC3RJdTGaTBZhAtgA1bT5aTHlWliQE4bNUjaJe88Vaxgg6gQaLH3aWGBsDRjmPUfuBsZW40OMZWO6HhsE0flOHbp)lWLjdtysDlOKjndJtJAodd4Pp5OK6RlW2WGN)f4YKHjmPUfuzsZW40OMZW4n1pugt34fgg88VaxMmmHjmHHb0yZR5mPMD(Bt4B3UDRHrV3xDa4gMeM7Ath4cA3Mp060OMdAffp4eiRggUgsnPMDUBnmA9OkbAyafqBERhEaT5DqpadT51Vca4aYkOaAbhHgpVp90bub43NqN9051(t4rnhTDvKoV2PPdzfuaTS63Z7nqB2BtcAZo)SZhYkKvqb0Mxa2paipVhYkOaAbLH2eMhv8wi0MxwDlOnV1iMfsGSckGwqzOnH9AbTkxi(oLfOvnn0(41baAtyK3nVwsqBEPjVbTLcA1e(gSH26QO8a5qBgdd0(r10i0QnJOoaqRyauuOT4qlD21eyGlcKvqb0ckdT5fG9dacTH3aWGe1okJrUkeAJbAJAhLXixfcTXaTpocT4rN3fydTc8aeGH22dWydTby)GwTjWlkxaTr7CWq7c9amNazfuaTGYqBEXiwqBcRO3b063cABNwUaAd9OZcNazfYkOaAtyKWcsFbUG2pQMgHw6S)9aA)iG64eOnHnLIAbhAV5aLb79U6jGwNg1CCODoXgcKvNg1CCIwJ0z)7rIatxBIAoiRonQ54eTgPZ(3JebM(JJYkW9KoFhb6zXb7TZLQ5c5OKAJESHS60OMJt0AKo7Fpsey6G27Y)cmPZ3rGtagB5CYhhLyE8knnCLeODXdbMcMhVstdxKBIPR5XLae(Q8yAU87laiB2yE8knnCr41v8aBjaHVkpMMl)(caYMnMhVstdxeEDfpWwcq4RYJP5YDC5crnhB2yE8knnCraD5c5OK(v7EGl5xmZInBmpELMgUiQQ5HC3dKl5ABaiCoNnBmpELMgUi5vixcE0lWMnBmpELMgUi3etxZJlbi8v5X0C5oUCHOMJnBmpELMgUiohmO9d5Y2ZAAjDAxKmKviRGcOnHrcli9f4cArqJ9gOnQDeAdWi060yAOT4qRdAVe(xGeiRonQ54a3RBjvnIzHqwbfqBcBnnXgOnV1dpG28gcASHw)wq7Uxx41bTjmPBG20CXCCiRonQ54jcmDWJErDaKFHZJKkfWCwtqu9WdPcbn2KOOSuhaDPKt4c8cYVrpalhLKx3QDad3j45FbUyZMoJyn6pYVrpalhLKx3QDad3jnU71XZCBUjdz1PrnhprGPdq40YfsFbA)OysLc4)PuKIUrgUyooPXDVooiabqx6(pLIu0nYWfZXjpnDCnuiKH3aWGtaiCA5cPVaTFumtGzRlLCcxGxq(n6by5OK86wTdy4obp)lWfB20zeRr)r(n6by5OK86wTdy4oPXDVoEMBZnziRonQ54jcmDvp8qYJUybtQua)pLIu0nYWfZXjnU71Xbbia6s3)PuKIUrgUyoo5PPlLCcxGxq(n6by5OK86wTdy4obp)lWfB20zeRr)r(n6by5OK86wTdy4oPXDVoEMBZnziRonQ54jcmDQlesNg1CsrXJKoFhbICoEuKdz1PrnhprGPtDHq60OMtkkEK057iq6mI1O)4qwDAuZXtey697KonQ5KIIhjD(oc8pCP2mI6aKuPagUaVG8B0dWYrj51TAhWWDcE(xGlDPKcDgXA0FKFJEawokjVUv7agUtAC3RJdmFD0zeRr)r0kHWB5OKQE4bPXDVooiBZpz2StHoJyn6pYVrpalhLKx3QDad3jnU71Xbj781f1okJrUkeKeKBYjdz1PrnhprGP3Vt60OMtkkEK057iW)WLrrzPoajvkG)Nsr(n6by5OK86wTdy4o5Pbz1PrnhprGP3Vt60OMtkkEK057iW5lQaBpQ5sQua)pLIOvcH3Yrjv9WdYttx4c8cY8fvGTh1Ce88VaxqwDAuZXtey697KonQ5KIIhjD(oc0hmPsb0PrbAuIhUxiptGzdz1PrnhprGPtDHq60OMtkkEK057iqE43Y7fKviRonQ54eFqGnUpnhfiNl1xxGDsLcy4c8ccapaJDDaK8y6DcE(xGl2StXZc7kqIQNSWtg4UgYds7hl64AOqidVbGbN04(0CuGCUuFDb2zcmb6Y5)uksx7i5PLmKvNg1CCIpyIathGWPLlK(c0(rXKkfWWf4fevp8Gt3eGrcE(xGliRonQ54eFWebMUQhEi5rxSGjr3qfOm8gagCGBtQuatzH)NsrApRPlks4HtzbKCzZEH)NsrApRPlksAC3RJdY28twhDgXA0FKg3NMJcKZL6RlWM04UxhheGzNNaOlDHlWlia8am21bqYJP3j45FbU0Lt4c8cIQhEWPBcWibp)lWfKvNg1CCIpyIatx1dpK8OlwWKkfq6mI1O)inUpnhfiNl1xxGnPXDVooiaZopbqx6cxGxqa4bySRdGKhtVtWZ)cCbz1PrnhN4dMiW0bp6f1bq(fopsQua)pLI01osEAqwDAuZXj(GjcmDvp8Gt3eGXKkfW)tPiSucrDaK7ofCDi5Pbz1PrnhN4dMiW0biCA5cPVaTFumPsbSFxrLAJESjluv0kajLT5My4c8cs)UIk9iW75rnhbp)lWvEMGKHS60OMJt8btey6QE4HKhDXcMeDdvGYWBayWbUnPsbmLf(FkfP9SMUOiHhoLfqYLn7f(FkfP9SMUOiPXDVooiBZpzD97kQuB0JnzHQIwbiPSn3edxGxq63vuPhbEppQ5i45FbUYZeKSUCcxGxqu9WdoDtagj45FbUGS60OMJt8btey6QE4HKhDXcMuPa2VROsTrp2KfQkAfGKY2CtmCbEbPFxrLEe498OMJGN)f4kptqY6YjCbEbr1dp40nbyKGN)f4cYQtJAooXhmrGP34(0CuGCUuFDb2qwDAuZXj(GjcmDvp8Gt3eGriRonQ54eFWebM(8fvGThys0nubkdVbGbh42KkfWuw4)PuK2ZA6IIeE4uwajx2Sx4)PuK2ZA6IIKg3964GSn)K11VROsTrp2KfQkAfzMs25My4c8cs)UIk9iW75rnhbp)lWvEMGK1Lt4c8cIQhEWPBcWibp)lWfKvNg1CCIpyIatF(IkW2dmPsbSFxrLAJESjluv0kYmLSZnXWf4fK(Dfv6rG3ZJAocE(xGR8mbjdz1PrnhN4dMiW0biCA5cPVaTFueYQtJAooXhmrGPR6HhsE0flys0nubkdVbGbh42KkfWuw4)PuK2ZA6IIeE4uwajx2Sx4)PuK2ZA6IIKg3964GSn)K1Lt4c8cIQhEWPBcWibp)lWfKvNg1CCIpyIatx1dpK8OlwqiRonQ54eFWebMo4Pp5OK6RlWgYQtJAooXhmrGP7n1pugt34fqwHSckG2mA0dWq7OGwM6wTdy4o0QnJOoaqBpHh1CqBEp0YdVdo0MD(CO9JQPrOnVujeEdTJcAZB9WdOnrOnJHbA9gHwh0Ej8VaHS60OMJt(dxQnJOoaabp6f1bq(fopsQua)pLI01osEAqwDAuZXj)Hl1MruhGebM(8fvGThys0nubkdVbGbh42KkfWuw4)PuK2ZA6IIeE4uwajx2Sx4)PuK2ZA6IIKg3964GSn)K11VROsTrp2KfQkAfzcm7C1Lt4c8cIQhEWPBcWibp)lWfKvNg1CCYF4sTze1birGPpFrfy7bMuPa2VROsTrp2KfQkAfzcm7CHS60OMJt(dxQnJOoajcmDacNwUq6lq7hftQua73vuP2OhBYcvfTcqYoFDCnuiKH3aWGtaiCA5cPVaTFumtGzRJoJyn6pIwjeElhLu1dpinU71XZmxiRonQ54K)WLAZiQdqIatx1dpK8OlwWKOBOcugEdadoWTjvkGPSW)tPiTN10ffj8WPSasUSzVW)tPiTN10ffjnU71XbzB(jRRFxrLAJESjluv0kaj781Lt4c8cIQhEWPBcWibp)lWLo6mI1O)iALq4TCusvp8G04UxhpZCHS60OMJt(dxQnJOoajcmDvp8qYJUybtQua73vuP2OhBYcvfTcqYoFD0zeRr)r0kHWB5OKQE4bPXDVoEM5cz1PrnhN8hUuBgrDasey6QE4bNUjaJjvkG)NsryPeI6ai3Dk46qYttx)UIk1g9ytwOQOvKzkBZnXWf4fK(Dfv6rG3ZJAocE(xGR8mbjRJRHcHm8gagCIQhEWPBcWyMaZgYQtJAoo5pCP2mI6aKiW0v9WdoDtagtQua73vuP2OhBYcvfTImbMscYnXWf4fK(Dfv6rG3ZJAocE(xGR8mbjRJRHcHm8gagCIQhEWPBcWyMaZgYQtJAoo5pCP2mI6aKiW0NVOcS9atIUHkqz4nam4a3MuPaMYc)pLI0EwtxuKWdNYci5YM9c)pLI0EwtxuK04UxhhKT5NSU(DfvQn6XMSqvrRitGPKGCtmCbEbPFxrLEe498OMJGN)f4kptqY6YjCbEbr1dp40nbyKGN)f4cYQtJAoo5pCP2mI6aKiW0NVOcS9atQua73vuP2OhBYcvfTImbMscYnXWf4fK(Dfv6rG3ZJAocE(xGR8mbjdz1PrnhN8hUuBgrDasey6aeoTCH0xG2pkMuPasNrSg9hrRecVLJsQ6HhKg3964z2VdjrTJYyKjKU(DfvQn6XMSqvrRaKekFDCnuiKH3aWGtaiCA5cPVaTFumtGzdz1PrnhN8hUuBgrDasey6QE4HKhDXcMeDdvGYWBayWbUnPsbmLf(FkfP9SMUOiHhoLfqYLn7f(FkfP9SMUOiPXDVooiBZpzD0zeRr)r0kHWB5OKQE4bPXDVoEM97qsu7OmgzcPRFxrLAJESjluv0kajHYxxoHlWliQE4bNUjaJe88VaxqwDAuZXj)Hl1MruhGebMUQhEi5rxSGjvkG0zeRr)r0kHWB5OKQE4bPXDVoEM97qsu7OmgzcPRFxrLAJESjluv0kajHYhYkKvqb0M3CH47uwG2yG2hhH28stEljOnHrE38AqREW4bTpo2GY1vr5bYH2mggOvRXDpEnk2qGS60OMJt(dxgfLL6aauRecVLJsQ6HhjvkG0zeRr)rWDTrp2Y(DOup6AZrAC3RJdz1PrnhN8hUmkkl1birGPJ7AJESL97qPE01MdYQtJAoo5pCzuuwQdqIatF(IkW2dmj6gQaLH3aWGdCBsLcykl8)uks7znDrrcpCklGKlB2l8)uks7znDrrsJ7EDCq2MFY663vuP2OhBqaMGS1Lt4c8cIQhEWPBcWibp)lWfKvNg1CCYF4YOOSuhGebM(8fvGThysLcy)UIk1g9ydcWeKnKvNg1CCYF4YOOSuhGebMEJ7tZrbY5s91fyNuPagUaVGaWdWyxhajpMENGN)f4cYQtJAoo5pCzuuwQdqIath8Oxuha5x48iPsb8)uksx7i5Pbz1PrnhN8hUmkkl1birGPpFrfy7bMeDdvGYWBayWbUnPsbmLf(FkfP9SMUOiHhoLfqYLn7f(FkfP9SMUOiPXDVooiBZpzD97qsu7OmgzUGaGUyZUFxrLAJESbbycLRUCcxGxqu9WdoDtagj45FbUGS60OMJt(dxgfLL6aKiW0NVOcS9atQua73HKO2rzmYCbbaDXMD)UIk1g9ydcWekxiRonQ54K)WLrrzPoajcmDvp8Gt3eGXKkfW)tPiSucrDaK7ofCDi5PPJRHcHm8gagCIQhEWPBcWyMaZgYQtJAoo5pCzuuwQdqIath80NCus91fyNuPa2VROsTrp2KfQkAfzcmbzRRFhsIAhLXitqMaOliRonQ54K)WLrrzPoajcm9g3NMJcKZL6RlWgYQtJAoo5pCzuuwQdqIatx1dp40nbymPsbKRHcHm8gagCIQhEWPBcWyMaZgYQtJAoo5pCzuuwQdqIatF(IkW2dmj6gQaLH3aWGdCBsLcykl8)uks7znDrrcpCklGKlB2l8)uks7znDrrsJ7EDCq2MFY663vuP2OhBYcvfTImZox2S73HzMaD5eUaVGO6HhC6MamsWZ)cCbz1PrnhN8hUmkkl1birGPpFrfy7bMuPa2VROsTrp2KfQkAfzMDUSz3VdZmbqwDAuZXj)HlJIYsDasey6Et9dLX0nErsLcy)UIk1g9ytwOQOvKzU5dzfYkOaAZlgXcAbJEhqlDUvf1CCiRonQ54e6iwsWO3bqkyVoUCuYIIjvkG)NsrOJyjbJEheE4uwYmxDrTJYyKRcbbaDbz1PrnhNqhXscg9osey6uWEDC5OKfftQuat5)ukchXaCDaKTdajnU71XbbaDLSU)tPiCedW1bq2oaK80GS60OMJtOJyjbJEhjcmDkyVoUCuYIIjvkGP8FkfrRecVLJsQ6HhKg3964GaeaDLNPSnr6mI1O)iQE4H(n9oxQE9gsJ(AtYSz)FkfrRecVLJsQ6HhKg3964G0VdjrTJYyKjizD)Nsr0kHWB5OKQE4b5PPlfplSRajfDJKwHVqbP9JfqaULn7)tPi)g9aSCusEDR2bmCN80swxoHlWliffPUgbp)lWfKvNg1CCcDeljy07irGPtb71XLJswumPsb8)ukIwjeElhLu1dpinU71XbbuP7)ukY7apInsE04biatAC3RJdca6kptzBI0zeRr)ru9Wd9B6DUu96nKg91MK19Fkf5DGhXgjpA8aeGjnU71X19FkfrRecVLJsQ6HhKNMUu8SWUcKu0nsAf(cfK2pwab4w2S)pLI8B0dWYrj51TAhWWDYtlzD5eUaVGuuK6Ae88VaxqwDAuZXj0rSKGrVJebMofSxhxokzrXKkfWu(pLIu0nsAf(cfKg3964GKqSz)FkfPOBK0k8fkinU71XbPFhsIAhLXitqY6(pLIu0nsAf(cfKNMoplSRajfDJKwHVqbP9JLmbMTUC(pLI8B0dWYrj51TAhWWDYttxoHlWliffPUgbp)lWfKvNg1CCcDeljy07irGPtb71XLJswumPsb8)uksr3iPv4luqEA6(pLI8oWJyJKhnEacWKNMoplSRajfDJKwHVqbP9JLmbMTUC(pLI8B0dWYrj51TAhWWDYttxoHlWliffPUgbp)lWfKvNg1CCcDeljy07irGPtb71XLJswumPsb8)ukIwjeElhLu1dpinU71XbjH09FkfrRecVLJsQ6HhKNMUWf4fKIIuxJGN)f4s3)Pue6iwsWO3bHhoLLmbUfuPZZc7kqsr3iPv4luqA)ybeGBHS60OMJtOJyjbJEhjcmDkyVoUCuYIIjvkG)Nsr0kHWB5OKQE4b5PPlCbEbPOi11i45FbU05zHDfiPOBK0k8fkiTFSKjWS1LY)Pue6iwsWO3bHhoLLmbUnHR7)uksr3iPv4luqAC3RJdca6s3)PuKIUrsRWxOG80yZ()ukY7apInsE04biatEA6(pLIqhXscg9oi8WPSKjWTGQKHScz1PrnhNqNrSg9hh4JJYkW9KoFhb6zXb7TZLQ5c5OKAJEStQuatHoJyn6pcURn6Xw2VdL6rxBosJ(AJUCaT3L)fizcWylNt(4OeZJxPPHRKzZof6mI1O)iALq4TCusvp8G04UxhheGBZxhO9U8VajtagB5CYhhLyE8knnCLmKvNg1CCcDgXA0F8ebM(JJYkW9KoFhbkEnlyZL1XRvnpUeqPIKkfWWf4fKFJEawokjVUv7agUtWZ)cCPlLuOZiwJ(JOvcH3Yrjv9WdsJ7EDCqaUnFDG27Y)cKmbySLZjFCuI5XR00WvYSzNY)PueTsi8wokPQhEqEA6Yb0Ex(xGKjaJTCo5JJsmpELMgUsoz2St5)ukIwjeElhLu1dpipnD5eUaVG8B0dWYrj51TAhWWDcE(xGRKHS60OMJtOZiwJ(JNiW0FCuwbUN057iq6gQyIEUIk)cNhjvkG58FkfrRecVLJsQ6HhKNgKvNg1CCcDgXA0F8ebM(JJYkWDEsLcyk0zeRr)r0kHWB5OKQE4bPrFTHnB6mI1O)iALq4TCusvp8G04UxhpZSZpzDPKt4c8cYVrpalhLKx3QDad3j45FbUyZMoJyn6pcURn6Xw2VdL6rxBosJ7ED8mt45MmKvNg1CCcDgXA0F8ebM(JJYkW9KoFhb6CWG2pKlBpRPL0PDrsLc4c)pLI0EwtlPt7c5c)pLISg9hKvNg1CCcDgXA0F8ebM(JJYkW9KoFhb6CWG2pKlBpRPL0PDrsLciDgXA0FeCxB0JTSFhk1JU2CKg3964zMWZx3c)pLI0EwtlPt7c5c)pLI800bAVl)lqYeGXwoN8XrjMhVstdxSz)Fkf53OhGLJsYRB1oGH7KNMUf(FkfP9SMwsN2fYf(Fkf5PPlhq7D5FbsMam2Y5KpokX84vAA4In7)tPi4U2OhBz)ouQhDT5ipnDl8)uks7znTKoTlKl8)ukYttxoHlWli)g9aSCusEDR2bmCNGN)f4In7O2rzmYvHGK9wiRonQ54e6mI1O)4jcm9hhLvG7jD(ocmVc5sWJEb2jvkGPG5XR00Wfr8AwWMlRJxRAECjGsf6(pLIOvcH3Yrjv9WdsJ7ED8KzZoLCW84vAA4IiEnlyZL1XRvnpUeqPcD)Nsr0kHWB5OKQE4bPXDVooiBZw3)PueTsi8wokPQhEqEAjdz1PrnhNqNrSg9hprGP)4OScCpPZ3rGSCtihL0pAHxivVEtsLciDgXA0FeCxB0JTSFhk1JU2CKg3964zMq5dz1PrnhNqNrSg9hprGP)4OScCpPZ3rGa65aWLADT7cz7aWKkfW(DiiatGUC(pLIOvcH3Yrjv9WdYttxk58Fkf53OhGLJsYRB1oGH7KNgB25eUaVG8B0dWYrj51TAhWWDcE(xGRKHS60OMJtOZiwJ(JNiW0FCuwbUN057iW2ZA9ow4YFbq24s(FrmhKvNg1CCcDgXA0F8ebM(JJYkW9KoFhbUJnYsa25sLFasQuaZ5)ukYVrpalhLKx3QDad3jpnD58FkfrRecVLJsQ6HhKNgKvNg1CCcDgXA0F8ebMU2e1CjvkG)Nsr0kHWB5OKQE4b5PP7)ukcURn6Xw2VdL6rxBoYtdYQtJAooHoJyn6pEIat)lMzjvVEtsLc4)PueTsi8wokPQhEqEA6(pLIG7AJESL97qPE01MJ80GS60OMJtOZiwJ(JNiW0)yZXML6aKuPa(FkfrRecVLJsQ6HhKNgKvNg1CCcDgXA0F8ebMU3u)qP2tWXKkfWuY5)ukIwjeElhLu1dpipnDonkqJs8W9c5zcm7KzZoN)tPiALq4TCusvp8G800Ls)oKSqvrRitG5QRFxrLAJESjluv0kYeiOo)KHS60OMJtOZiwJ(JNiW0ffaWbxMx9wa2XlsQua)pLIOvcH3Yrjv9WdYtdYQtJAooHoJyn6pEIat3pkYJ2fsQlejvkG)Nsr0kHWB5OKQE4b5PP7)ukcURn6Xw2VdL6rxBoYtdYQtJAooHoJyn6pEIatxvn(fZSsQua)pLIOvcH3Yrjv9WdsJ7EDCqacQ09Fkfb31g9yl73Hs9ORnh5Pbz1PrnhNqNrSg9hprGP)DaYrjJUOSWtQua)pLIOvcH3Yrjv9WdYttxk)Nsr0kHWB5OKQE4bPXDVooi5QlCbEbHoILem6DqWZ)cCXMDoHlWli0rSKGrVdcE(xGlD)Nsr0kHWB5OKQE4bPXDVooijizDonkqJs8W9c5a3YM9)PueoIb46aiBhasEA6CAuGgL4H7fYbUfYkKvqb0M36HhqlDgXA0FCiRonQ54e6mI1O)4jcmDTsi8wokPQhEKuPasNrSg9hb31g9yl73Hs9ORnhPXDVooB2HlWliffPUgbp)lWfKvNg1CCcDgXA0F8ebM(VrpalhLKx3QDad3t6Xr5Ousa0fWTjvkG0zeRr)rWDTrp2Y(DOup6AZrAC3RJRJoJyn6pIwjeElhLu1dpinU71XHS60OMJtOZiwJ(JNiW0XDTrp2Y(DOup6AZLuPasNrSg9hrRecVLJsQ6HhKg91gDHlWliZxub2EuZrWZ)cCPRFhsIAhLXiZnta0LU(DfvQn6XMSqvrRitGBZNn7O2rzmYvHGKD(qwDAuZXj0zeRr)Xtey64U2OhBz)ouQhDT5sQuatHoJyn6pIwjeElhLu1dpin6RnSzh1okJrUkeKSZpzDHlWli)g9aSCusEDR2bmCNGN)f4sx)UIk1g9yNjOoFiRonQ54e6mI1O)4jcmDCxB0JTSFhk1JU2CjvkGHlWliffPUgbp)lWLU(DiijaYQtJAooHoJyn6pEIatN6cH0PrnNuu8iPZ3rG0rSKGrVJKkfWWf4fe6iwsWO3bbp)lWLUus5)ukcDeljy07GWdNYsMa3MVUf(FkfP9SMUOiHhoLfG5MmB2rTJYyKRcbbia6kziRonQ54e6mI1O)4jcmDvp8q)MENlvVEtsLcyk)Nsr0kHWB5OKQE4b5PPZZc7kqsr3iPv4luqA)ybeGB1LY)PueTsi8wokPQhEqAC3RJdcqa0fB2)NsrEh4rSrYJgpabysJ7EDCqacGU09Fkf5DGhXgjpA8aeGjpTKtgYQtJAooHoJyn6pEIatx1dp0VP35s1R3KuPaMY)PuKIUrsRWxOG800Lt4c8csrrQRrWZ)cCPlL)tPiVd8i2i5rJhGam5PXM9)PuKIUrsRWxOG04UxhheGaORKtMn7)tPifDJKwHVqb5PP7)uksr3iPv4luqAC3RJdcqa0LUWf4fKIIuxJGN)f4s3)PueTsi8wokPQhEqEAqwDAuZXj0zeRr)Xtey6QE4H(n9oxQE9MKkfWO2rzmYvHGaGUyZoLO2rzmYvHGqNrSg9hrRecVLJsQ6HhKg39646(pLI8oWJyJKhnEacWKNwYqwHS60OMJtqohpkYb(fZSKJsgGrjE4(MKkfW)tPiALq4TCusvp8G800LY)PueTsi8wokPQhEqAC3RJdY281LY)PuKFJEawokjVUv7agUtEASzhUaVGmFrfy7rnhbp)lWfB2HlWliffPUgbp)lWLUC8SWUcKu0nsAf(cfe88VaxjZM9)PuKIUrsRWxOG800fUaVGuuK6Ae88Vaxjdz1PrnhNGCoEuKNiW0b88Ev(jhL0Zc7jaNuPaMt4c8csrrQRrWZ)cCXMD4c8csrrQRrWZ)cCPZZc7kqsr3iPv4luqWZ)cCP7)ukIwjeElhLu1dpinU71XbbuR7)ukIwjeElhLu1dpipn2SdxGxqkksDncE(xGlD54zHDfiPOBK0k8fki45FbUGS60OMJtqohpkYtey6uWLqi5rJoljvkG)Nsr0kHWB5OKQE4bPXDVooi5Q7)ukIwjeElhLu1dpipn2SJAhLXixfcsUqwDAuZXjiNJhf5jcm9amkF3FE3sQMMIjvkG)NsrAKYIa5CPAAksEASz)FkfPrklcKZLQPPOKoVlWMWdNYciB3cz1PrnhNGCoEuKNiW0vd9XXL0Zc7kq5h99KkfWC(pLIOvcH3Yrjv9WdYttxo)Nsr(n6by5OK86wTdy4o5Pbz1PrnhNGCoEuKNiW0PZrXlApWLuj8DmPsbmN)tPiALq4TCusvp8G800LZ)PuKFJEawokjVUv7agUtEA6wtqOZrXlApWLuj8Du(F9rAC3RJdmFiRonQ54eKZXJI8ebMU2Rl1M6ai)cNhjvkG58FkfrRecVLJsQ6HhKNMUC(pLI8B0dWYrj51TAhWWDYtdYQtJAoob5C8OiprGPRFAXc0yDYg5Z5hftQua)pLIOvcH3Yrjv9WdYtJn7)tPi4U2OhBz)ouQhDT5ipn2SPZiwJ(J8B0dWYrj51TAhWWDsJ7ED8mb15N42CHS60OMJtqohpkYtey6DPPjqzDsUMtXKkfWC(pLIOvcH3Yrjv9WdYttxo)Nsr(n6by5OK86wTdy4o5Pbz1PrnhNGCoEuKNiW03X9P3ihLu8O1sUA035jvkG)NsrWDTrp2Y(DOup6AZrAC3RJdsU6(pLI8B0dWYrj51TAhWWDYtJn7u63HKO2rzmYSZeaDPRFxrLAJESbj38tgYQtJAoob5C8OiprGP3ORvhaPs47ihYkKvqb0Mx(xub2EuZbT9eEuZbz1PrnhNmFrfy7rnhWg3NMJcKZL6RlWoPsbmCbEbbGhGXUoasEm9obp)lWfKvNg1CCY8fvGTh1Cjcm95lQaBpWKOBOcugEdadoWTjvkGPSW)tPiTN10ffj8WPSasUSzVW)tPiTN10ffjnU71XbzB(jRlNWf4fevp8Gt3eGrcE(xGlD58FkfPRDK800X1qHqgEdadob8Oxuha5x48itGjaYQtJAooz(IkW2JAUebM(8fvGThysLcyoHlWliQE4bNUjaJe88Vax6Y5)uksx7i5PPJRHcHm8gagCc4rVOoaYVW5rMataKvNg1CCY8fvGTh1CjcmDvp8Gt3eGXKkfWu(pLIWsje1bqU7uW1HKgDAWMDk)NsryPeI6ai3Dk46qYttxkAncAja6ISLO6HhsE0fliB2AncAja6ISLaE0lQdG8lCEWMTwJGwcGUiBjaeoTCH0xG2pkMCYjRJRHcHm8gagCIQhEWPBcWyMaZgYQtJAooz(IkW2JAUebM(8fvGThys0nubkdVbGbh42KkfWuw4)PuK2ZA6IIeE4uwajx2Sx4)PuK2ZA6IIKg3964GSn)K19FkfHLsiQdGC3PGRdjn60Gn7u(pLIWsje1bqU7uW1HKNMUu0Ae0sa0fzlr1dpK8Olwq2S1Ae0sa0fzlb8Oxuha5x48GnBTgbTeaDr2saiCA5cPVaTFum5KHS60OMJtMVOcS9OMlrGPpFrfy7bMuPa(FkfHLsiQdGC3PGRdjn60Gn7u(pLIWsje1bqU7uW1HKNMUu0Ae0sa0fzlr1dpK8Olwq2S1Ae0sa0fzlb8Oxuha5x48GnBTgbTeaDr2saiCA5cPVaTFum5KHS60OMJtMVOcS9OMlrGPdq40YfsFbA)OysLcyk58FkfPRDK80yZUFxrLAJESjluv0kazB(Sz3VdjrTJYyKzNja6kzDCnuiKH3aWGtaiCA5cPVaTFumtGzdz1PrnhNmFrfy7rnxIath8Oxuha5x48iPsb8)uksx7i5PPJRHcHm8gagCc4rVOoaYVW5rMaZgYQtJAooz(IkW2JAUebMUQhEi5rxSGjr3qfOm8gagCGBtQuatzH)NsrApRPlks4HtzbKCzZEH)NsrApRPlksAC3RJdY28twxo)Nsr6Ahjpn2S73vuP2OhBYcvfTcq2MpB297qsu7Omgz2zcGU0Lt4c8cIQhEWPBcWibp)lWfKvNg1CCY8fvGTh1CjcmDvp8qYJUybtQuaZ5)uksx7i5PXMD)UIk1g9ytwOQOvaY28zZUFhsIAhLXiZota0fKvNg1CCY8fvGTh1CjcmDWJErDaKFHZJKkfW)tPiDTJKNgKvNg1CCY8fvGTh1Cjcm95lQaBpWKOBOcugEdadoWTjvkGPSW)tPiTN10ffj8WPSasUSzVW)tPiTN10ffjnU71XbzB(jRlNWf4fevp8Gt3eGrcE(xGliRonQ54K5lQaBpQ5sey6Zxub2EGqwHSckGwMWVL3lOLxhabckhEdadOTNWJAoiRonQ54eE43Y7fWg3NMJcKZL6RlWgYQtJAooHh(T8ELiW0v9Wdjp6IfmPsbKoJyn6psJ7tZrbY5s91fytAC3RJdcWSZta0LUWf4feaEag76ai5X07e88VaxqwDAuZXj8WVL3RebMo4rVOoaYVW5rsLc4)PuKU2rYtdYQtJAooHh(T8ELiW0NVOcS9atQuadxGxqkksDncE(xGlD)Nsr0kHWB5OKQE4b5PPZZc7kqsr3iPv4luqA)yjtGzdz1PrnhNWd)wEVsey6Zxub2EGjvkG58Fkfr1tw4j1EcosEA6cxGxqu9KfEsTNGJe88VaxqwDAuZXj8WVL3RebMUQhEi5rxSGjvkG97kQuB0JnzHQIwbiPSn3edxGxq63vuPhbEppQ5i45FbUYZeKmKvNg1CCcp8B59krGPR6HhC6MamMuPa(FkfHLsiQdGC3PGRdjpnD97qsu7OmgzcLjqa0fKvNg1CCcp8B59krGPpFrfy7bMuPa2VROsTrp2KfQkAfzMs25My4c8cs)UIk9iW75rnhbp)lWvEMGKHS60OMJt4HFlVxjcmDvp8qYJUybHS60OMJt4HFlVxjcmDWtFYrj1xxGnKvNg1CCcp8B59krGP7n1pugt34fMWegd]] )
    

end
