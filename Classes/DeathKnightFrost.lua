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

            range = 7,

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

            range = 7,

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

    
    spec:RegisterPack( "Frost DK", 20200204, [[dK0frcqirLEeqk2ePYOejoLiPvjQIELi0SerUfqk1Uq8lrQgMOQoMQOLjk5zIatteKRjQyBaPY3asjJdivDorvsRtuLQMhqCpaTprrhuufkluu4HIQqMOOkLCrrvG2OOkXifvbXjfvbSsusVuuLsDtrvqANIO(POku1qfvb1sfvPINIIPks5RIQuP9sXFjAWu6WuTyv1JrAYk5YqBMKpdWObQtlz1IQu8AuIzJQBRkTBv(TIHtkhxeulxQNty6cxxP2oqY3jvnErvOY5vfwVOuZhLA)G280KMHz5bAsoR8Zk)8Zk)eI8mRCEMfOZWep0qdJMtzXbGgMZFrdtEPhraT5TYBBy08h8XxM0mmIz3u0WaocnrEF6PdOcW7pHoVPlQ3n3JAoA7QiDr9st3W83fpYdCMVHz5bAsoR8Zk)8Zk)eI8mRCEMvcmm(oapTHHPEZJmmGR1cpZ3WSqb1WaAG28spIaAZBHEagAZBFfaWbKvqd0cocnrEF6PdOcW7pHoVPlQ3n3JAoA7QiDr9sthYkObAZl4V3E)aAtqsqBw5Nv(qwHScAG28iW(baf59qwbnqlOn0Mh4O89cH28qRBbT5LgXSrcKvqd0cAdT5XwlOv5C(3PSaTQPH2TOoaqBEW8o5DtcAZdp5fOTuqRg3FGn0wxfLhOaAZyyG2pQMgHwTz41baA5dGIcTLaAPZRghdCrGScAGwqBOnpcSFaqOn8gagKOErzmYvHqBmqBuVOmg5QqOngODlqOfp6SVaBOLJhGam02EagBOna7h0QnbEr5COnAxagAxOhGfeiRGgOf0gAZJg(cAZdb9oGw)wqB70Y5qBOhDweeddVeHWKMHHo8Lem6DysZK8ttAgg88phxMmmm0UcSl3W83kfHo8Lem6DqeHtzbAZeAZbA1bTr9IYyKRcHwqGwa0LHXPrnNHHc2RtihLSOOjmjNLjnddE(NJltgggAxb2LBysbA)BLIiqmaxhaz7aqsJVEDcOfeOfaDbTPcT6G2)wPicedW1bq2oaKS1mmonQ5mmuWEDc5OKffnHj5eysZWGN)54YKHHH2vGD5gMuG2)wPiAfN7TCusvpIG04RxNaAbbi0cGUG28eAtbAFcTjcT0z4Rr)ru9ic9p6xHuT7hKg91dOnvOLnBO9VvkIwX5ElhLu1Jiin(61jGwqG2EFijQxugJmbqBQqRoO9VvkIwX5ElhLu1JiiBnOvh0Mc06zJDfiPOpK0k8fYjTFSaTGaeAFcTSzdT)Tsr(n6by5OKI6wTdyeozRbTPcT6G2CH2W54fKIIuxJGN)54YW40OMZWqb71jKJswu0eMKtitAgg88phxMmmm0UcSl3W83kfrR4CVLJsQ6reKgF96eqliqlOhA1bT)Tsr2h4H)qkIgpabysJVEDcOfeOfaDbT5j0Mc0(eAteAPZWxJ(JO6re6F0VcPA3pin6RhqBQqRoO9VvkY(ap8hsr04biatA81RtaT6G2)wPiAfN7TCusvpIGS1GwDqBkqRNn2vGKI(qsRWxiN0(Xc0ccqO9j0YMn0(3kf53OhGLJskQB1oGr4KTg0Mk0QdAZfAdNJxqkksDncE(NJldJtJAoddfSxNqokzrrtysohtAgg88phxMmmm0UcSl3WKc0(3kfPOpK0k8fYjn(61jGwqG2ecAzZgA)BLIu0hsAf(c5KgF96eqliqBVpKe1lkJrMaOnvOvh0(3kfPOpK0k8fYjBnOvh06zJDfiPOpK0k8fYjTFSaTzceAZcA1bT5cT)Tsr(n6by5OKI6wTdyeozRbT6G2CH2W54fKIIuxJGN)54YW40OMZWqb71jKJswu0eMKbDM0mm45FoUmzyyODfyxUH5VvksrFiPv4lKt2AqRoO9VvkY(ap8hsr04biat2AqRoO1Zg7kqsrFiPv4lKtA)ybAZei0Mf0QdAZfA)BLI8B0dWYrjf1TAhWiCYwdA1bT5cTHZXliffPUgbp)ZXLHXPrnNHHc2RtihLSOOjmjdAzsZWGN)54YKHHH2vGD5gM)wPiAfN7TCusvpIG04RxNaAbbAtiOvh0(3kfrR4CVLJsQ6reKTg0QdAdNJxqkksDncE(NJlOvh0(3kfHo8Lem6DqeHtzbAZei0(e0dT6GwpBSRajf9HKwHVqoP9JfOfeGq7tdJtJAoddfSxNqokzrrtysg0BsZWGN)54YKHHH2vGD5gM)wPiAfN7TCusvpIGS1GwDqB4C8csrrQRrWZ)CCbT6GwpBSRajf9HKwHVqoP9JfOntGqBwqRoOnfO9VvkcD4ljy07GicNYc0MjqO9zEfA1bT)Tsrk6djTcFHCsJVEDcOfeOfaDbT6G2)wPif9HKwHVqozRbTSzdT)Tsr2h4H)qkIgpabyYwdA1bT)TsrOdFjbJEher4uwG2mbcTpb9qBQggNg1CggkyVoHCuYIIMWegM5ZRaBpQ5mPzs(PjnddE(NJltgggAxb2LBycNJxqa4bySRdGuet)sWZ)CCzyCAuZzyA8DAbYrHqQVUaBtysoltAgg88phxMmmmonQ5mmZNxb2EGggAxb2LBysbAx4FRuK2ZE6IIer4uwGwqG2CGw2SH2f(3kfP9SNUOiPXxVob0cc0(mFOnvOvh0Ml0gohVGO6rec6JamsWZ)CCbT6G2CH2)wPiD9IKTg0QdAfAiNldVbGHGaE0ZRdG8ZDraTzceAtGHH(GYrz4nameMKFActYjWKMHbp)ZXLjdddTRa7Ynm5cTHZXliQEeHG(iaJe88phxqRoOnxO9VvksxVizRbT6GwHgY5YWBayiiGh986ai)CxeqBMaH2eyyCAuZzyMpVcS9anHj5eYKMHbp)ZXLjdddTRa7YnmPaT)TsryP486aiFDk46qsJonGw2SH2uG2)wPiSuCEDaKVofCDizRbT6G2uGwTgbLeaDrEsu9icPi6IfeAzZgA1Aeusa0f5jb8ONxha5N7IaAzZgA1Aeusa0f5jba3PLZL(cu(rrOnvOnvOnvOvh0k0qoxgEdadbr1Jie0hbyeAZei0MLHXPrnNHr1Jie0hby0eMKZXKMHbp)ZXLjddJtJAodZ85vGThOHH2vGD5gMuG2f(3kfP9SNUOireoLfOfeOnhOLnBODH)TsrAp7PlksA81RtaTGaTpZhAtfA1bT)TsryP486aiFDk46qsJonGw2SH2uG2)wPiSuCEDaKVofCDizRbT6G2uGwTgbLeaDrEsu9icPi6IfeAzZgA1Aeusa0f5jb8ONxha5N7IaAzZgA1Aeusa0f5jba3PLZL(cu(rrOnvOnvdd9bLJYWBayimj)0eMKbDM0mm45FoUmzyyODfyxUH5VvkclfNxha5RtbxhsA0Pb0YMn0Mc0(3kfHLIZRdG81PGRdjBnOvh0Mc0Q1iOKaOlYtIQhrifrxSGqlB2qRwJGscGUipjGh986ai)CxeqlB2qRwJGscGUipja4oTCU0xGYpkcTPcTPAyCAuZzyMpVcS9anHjzqltAgg88phxMmmm0UcSl3WKc0Ml0(3kfPRxKS1Gw2SH2EFfvQn6XMSqvrRaAbbAFMp0YMn027djr9IYyKzbTzcTaOlOnvOvh0k0qoxgEdadbba3PLZL(cu(rrOntGqBwggNg1CggaCNwox6lq5hfnHjzqVjnddE(NJltgggAxb2LBy(BLI01ls2AqRoOvOHCUm8gagcc4rpVoaYp3fb0MjqOnldJtJAodd4rpVoaYp3fHjmjNxnPzyWZ)CCzYWW40OMZWO6resr0flOHH2vGD5gMuG2f(3kfP9SNUOireoLfOfeOnhOLnBODH)TsrAp7PlksA81RtaTGaTpZhAtfA1bT5cT)Tsr66fjBnOLnBOT3xrLAJESjluv0kGwqG2N5dTSzdT9(qsuVOmgzwqBMqla6cA1bT5cTHZXliQEeHG(iaJe88phxgg6dkhLH3aWqys(Pjmj)mFtAgg88phxMmmm0UcSl3WKl0(3kfPRxKS1Gw2SH2EFfvQn6XMSqvrRaAbbAFMp0YMn027djr9IYyKzbTzcTaOldJtJAodJQhrifrxSGMWK8ZNM0mm45FoUmzyyODfyxUH5VvksxVizRzyCAuZzyap651bq(5UimHj5NzzsZWGN)54YKHHXPrnNHz(8kW2d0Wq7kWUCdtkq7c)BLI0E2txuKicNYc0cc0Md0YMn0UW)wPiTN90ffjn(61jGwqG2N5dTPcT6G2CH2W54fevpIqqFeGrcE(NJldd9bLJYWBayimj)0eMKFMatAggNg1CgM5ZRaBpqddE(NJltgMWegM)iKrrzPoaM0mj)0KMHbp)ZXLjdddTRa7Ynm0z4Rr)rWxTrp2YEFOup6AZrA81RtyyCAuZzy0ko3B5OKQEeHjmjNLjndJtJAodd(Qn6Xw27dL6rxBoddE(NJltgMWKCcmPzyWZ)CCzYWW40OMZWmFEfy7bAyODfyxUHjfODH)TsrAp7PlkseHtzbAbbAZbAzZgAx4FRuK2ZE6IIKgF96eqliq7Z8H2uHwDqBVVIk1g9ydTGaeAtqwqRoOnxOnCoEbr1Jie0hbyKGN)54YWqFq5Om8gagctYpnHj5eYKMHbp)ZXLjdddTRa7Ynm9(kQuB0Jn0ccqOnbzzyCAuZzyMpVcS9anHj5CmPzyWZ)CCzYWWq7kWUCdt4C8ccapaJDDaKIy6xcE(NJldJtJAodtJVtlqokes91fyBctYGotAgg88phxMmmm0UcSl3W83kfPRxKS1mmonQ5mmGh986ai)CxeMWKmOLjnddE(NJltgggNg1CgM5ZRaBpqddTRa7YnmPaTl8Vvks7zpDrrIiCklqliqBoqlB2q7c)BLI0E2txuK04RxNaAbbAFMp0Mk0QdA79HKOErzmYCGwqGwa0f0YMn027ROsTrp2qliaH2ekhOvh0Ml0gohVGO6rec6JamsWZ)CCzyOpOCugEdadHj5NMWKmO3KMHbp)ZXLjdddTRa7Ynm9(qsuVOmgzoqliqla6cAzZgA79vuP2OhBOfeGqBcLJHXPrnNHz(8kW2d0eMKZRM0mm45FoUmzyyODfyxUH5VvkclfNxha5Rtbxhs2AqRoOvOHCUm8gagcIQhriOpcWi0MjqOnldJtJAodJQhriOpcWOjmj)mFtAgg88phxMmmm0UcSl3W07ROsTrp2KfQkAfqBMaH2eKf0QdA79HKOErzmYeaTzcTaOldJtJAodd4Pp5OK6RlW2eMKF(0KMHXPrnNHPX3PfihfcP(6cSnm45FoUmzyctYpZYKMHbp)ZXLjdddTRa7YnmcnKZLH3aWqqu9icb9ragH2mbcTzzyCAuZzyu9icb9ragnHj5NjWKMHbp)ZXLjddJtJAodZ85vGThOHH2vGD5gMuG2f(3kfP9SNUOireoLfOfeOnhOLnBODH)TsrAp7PlksA81RtaTGaTpZhAtfA1bT9(kQuB0JnzHQIwb0Mj0MvoqlB2qBVpeAZeAta0QdAZfAdNJxqu9icb9ragj45FoUmm0huokdVbGHWK8ttys(zczsZWGN)54YKHHH2vGD5gMEFfvQn6XMSqvrRaAZeAZkhOLnBOT3hcTzcTjWW40OMZWmFEfy7bActYpZXKMHbp)ZXLjdddTRa7Ynm9(kQuB0JnzHQIwb0Mj0Mt(ggNg1CggVP(HYy6gVWeMWW4dAsZK8ttAgg88phxMmmm0UcSl3WeohVGaWdWyxhaPiM(LGN)54cAzZgAtbA9SXUcKO6jB8Kb(QHIG0(Xc0QdAfAiNldVbGHG0470cKJcHuFDb2qBMaH2eaT6G2CH2)wPiD9IKTg0MQHXPrnNHPX3PfihfcP(6cSnHj5SmPzyWZ)CCzYWWq7kWUCdt4C8cIQhriOpcWibp)ZXLHXPrnNHba3PLZL(cu(rrtysobM0mm45FoUmzyyCAuZzyu9icPi6If0Wq7kWUCdtkq7c)BLI0E2txuKicNYc0cc0Md0YMn0UW)wPiTN90ffjn(61jGwqG2N5dTPcT6Gw6m81O)in(oTa5Oqi1xxGnPXxVob0ccqOnlOnpHwa0f0QdAdNJxqa4bySRdGuet)sWZ)CCbT6G2CH2W54fevpIqqFeGrcE(NJldd9bLJYWBayimj)0eMKtitAgg88phxMmmm0UcSl3WqNHVg9hPX3PfihfcP(6cSjn(61jGwqacTzbT5j0cGUGwDqB4C8ccapaJDDaKIy6xcE(NJldJtJAodJQhrifrxSGMWKCoM0mm45FoUmzyyODfyxUH5VvksxVizRzyCAuZzyap651bq(5UimHjzqNjnddE(NJltgggAxb2LBy(BLIWsX51bq(6uW1HKTMHXPrnNHr1Jie0hby0eMKbTmPzyWZ)CCzYWWq7kWUCdtVVIk1g9ytwOQOvaTGaTPaTpZbAteAdNJxq69vuPhbEBpQ5i45FoUG28eAta0MQHXPrnNHba3PLZL(cu(rrtysg0BsZWGN)54YKHHXPrnNHr1JiKIOlwqddTRa7YnmPaTl8Vvks7zpDrrIiCklqliqBoqlB2q7c)BLI0E2txuK04RxNaAbbAFMp0Mk0QdA79vuP2OhBYcvfTcOfeOnfO9zoqBIqB4C8csVVIk9iWB7rnhbp)ZXf0MNqBcG2uHwDqBUqB4C8cIQhriOpcWibp)ZXLHH(GYrz4nameMKFActY5vtAgg88phxMmmm0UcSl3W07ROsTrp2KfQkAfqliqBkq7ZCG2eH2W54fKEFfv6rG32JAocE(NJlOnpH2eaTPcT6G2CH2W54fevpIqqFeGrcE(NJldJtJAodJQhrifrxSGMWK8Z8nPzyCAuZzyA8DAbYrHqQVUaBddE(NJltgMWK8ZNM0mmonQ5mmQEeHG(iaJgg88phxMmmHj5NzzsZWGN)54YKHHXPrnNHz(8kW2d0Wq7kWUCdtkq7c)BLI0E2txuKicNYc0cc0Md0YMn0UW)wPiTN90ffjn(61jGwqG2N5dTPcT6G2EFfvQn6XMSqvrRaAZeAtbAZkhOnrOnCoEbP3xrLEe4T9OMJGN)54cAZtOnbqBQqRoOnxOnCoEbr1Jie0hbyKGN)54YWqFq5Om8gagctYpnHj5NjWKMHbp)ZXLjdddTRa7Ynm9(kQuB0JnzHQIwb0Mj0Mc0MvoqBIqB4C8csVVIk9iWB7rnhbp)ZXf0MNqBcG2unmonQ5mmZNxb2EGMWK8ZeYKMHXPrnNHba3PLZL(cu(rrddE(NJltgMWK8ZCmPzyWZ)CCzYWW40OMZWO6resr0flOHH2vGD5gMuG2f(3kfP9SNUOireoLfOfeOnhOLnBODH)TsrAp7PlksA81RtaTGaTpZhAtfA1bT5cTHZXliQEeHG(iaJe88phxgg6dkhLH3aWqys(Pjmj)e0zsZW40OMZWO6resr0flOHbp)ZXLjdtys(jOLjndJtJAodd4Pp5OK6RlW2WGN)54YKHjmj)e0BsZW40OMZW4n1pugt34fgg88phxMmmHjmm)ri1MHxhatAMKFAsZWGN)54YKHHH2vGD5gM)wPiD9IKTMHXPrnNHb8ONxha5N7IWeMKZYKMHbp)ZXLjddJtJAodZ85vGThOHH2vGD5gMuG2f(3kfP9SNUOireoLfOfeOnhOLnBODH)TsrAp7PlksA81RtaTGaTpZhAtfA1bT9(kQuB0JnzHQIwb0MjqOnRCGwDqBUqB4C8cIQhriOpcWibp)ZXLHH(GYrz4nameMKFActYjWKMHbp)ZXLjdddTRa7Ynm9(kQuB0JnzHQIwb0MjqOnRCmmonQ5mmZNxb2EGMWKCczsZWGN)54YKHHH2vGD5gMEFfvQn6XMSqvrRaAbbAZkFOvh0k0qoxgEdadbba3PLZL(cu(rrOntGqBwqRoOLodFn6pIwX5ElhLu1Jiin(61jG2mH2CmmonQ5mma4oTCU0xGYpkActY5ysZWGN)54YKHHXPrnNHr1JiKIOlwqddTRa7YnmPaTl8Vvks7zpDrrIiCklqliqBoqlB2q7c)BLI0E2txuK04RxNaAbbAFMp0Mk0QdA79vuP2OhBYcvfTcOfeOnR8HwDqBUqB4C8cIQhriOpcWibp)ZXf0QdAPZWxJ(JOvCU3Yrjv9icsJVEDcOntOnhdd9bLJYWBayimj)0eMKbDM0mm45FoUmzyyODfyxUHP3xrLAJESjluv0kGwqG2SYhA1bT0z4Rr)r0ko3B5OKQEebPXxVob0Mj0MJHXPrnNHr1JiKIOlwqtysg0YKMHbp)ZXLjdddTRa7Ynm)TsryP486aiFDk46qYwdA1bT9(kQuB0JnzHQIwb0Mj0Mc0(mhOnrOnCoEbP3xrLEe4T9OMJGN)54cAZtOnbqBQqRoOvOHCUm8gagcIQhriOpcWi0MjqOnldJtJAodJQhriOpcWOjmjd6nPzyWZ)CCzYWWq7kWUCdtVVIk1g9ytwOQOvaTzceAtbAtqoqBIqB4C8csVVIk9iWB7rnhbp)ZXf0MNqBcG2uHwDqRqd5Cz4nameevpIqqFeGrOntGqBwggNg1CggvpIqqFeGrtysoVAsZWGN)54YKHHXPrnNHz(8kW2d0Wq7kWUCdtkq7c)BLI0E2txuKicNYc0cc0Md0YMn0UW)wPiTN90ffjn(61jGwqG2N5dTPcT6G2EFfvQn6XMSqvrRaAZei0Mc0MGCG2eH2W54fKEFfv6rG32JAocE(NJlOnpH2eaTPcT6G2CH2W54fevpIqqFeGrcE(NJldd9bLJYWBayimj)0eMKFMVjnddE(NJltgggAxb2LBy69vuP2OhBYcvfTcOntGqBkqBcYbAteAdNJxq69vuPhbEBpQ5i45FoUG28eAta0MQHXPrnNHz(8kW2d0eMKF(0KMHbp)ZXLjdddTRa7Ynm0z4Rr)r0ko3B5OKQEebPXxVob0Mj027djr9IYyKje0QdA79vuP2OhBYcvfTcOfeOnHYhA1bTcnKZLH3aWqqaWDA5CPVaLFueAZei0MLHXPrnNHba3PLZL(cu(rrtys(zwM0mm45FoUmzyyCAuZzyu9icPi6If0Wq7kWUCdtkq7c)BLI0E2txuKicNYc0cc0Md0YMn0UW)wPiTN90ffjn(61jGwqG2N5dTPcT6Gw6m81O)iAfN7TCusvpIG04RxNaAZeA79HKOErzmYecA1bT9(kQuB0JnzHQIwb0cc0Mq5dT6G2CH2W54fevpIqqFeGrcE(NJldd9bLJYWBayimj)0eMKFMatAgg88phxMmmm0UcSl3WqNHVg9hrR4CVLJsQ6reKgF96eqBMqBVpKe1lkJrMqqRoOT3xrLAJESjluv0kGwqG2ekFdJtJAodJQhrifrxSGMWeggTgPZ73dtAMKFAsZW40OMZWOnrnNHbp)ZXLjdtysoltAgg88phxMmmmN)IggpBbyVDHunxihLuB0JTHXPrnNHXZwa2BxivZfYrj1g9yBctYjWKMHbp)ZXLjddZOzyeyyyCAuZzyaL3L)5OHbuoFJgMuGwmH3LMgUi3etxZwibW9v5X0c53xaqOLnBOft4DPPHlcD6ERf4scG7RYJPfYVVaGqlB2qlMW7stdxe609wlWLea3xLhtlKV4Y58AoOLnBOft4DPPHlcOkNlhL0V61dCj)8zwqlB2qlMW7stdxev1Iq(6bkKcTha4UqaTSzdTycVlnnCrYBqHe8ONJn0YMn0Ij8U00Wf5My6A2cjaUVkpMwiFXLZ51CqlB2qlMW7stdxexagu(Hcz7zpTKoTZH2unmGYB55VOHzcWylNtUfOet4DPPHltycddDg(A0FctAMKFAsZWGN)54YKHHXPrnNHXZwa2BxivZfYrj1g9yByODfyxUHjfOLodFn6pc(Qn6Xw27dL6rxBosJ(6b0QdAZfAbL3L)5izcWylNtUfOet4DPPHlOnvOLnBOnfOLodFn6pIwX5ElhLu1Jiin(61jGwqacTpZhA1bTGY7Y)CKmbySLZj3cuIj8U00Wf0MQH58x0W4zla7TlKQ5c5OKAJESnHj5SmPzyWZ)CCzYWW40OMZWW3nlylK1jQvnBHeqPcddTRa7YnmHZXli)g9aSCusrDR2bmcNGN)54cA1bTPaTPaT0z4Rr)r0ko3B5OKQEebPXxVob0ccqO9z(qRoOfuEx(NJKjaJTCo5wGsmH3LMgUG2uHw2SH2uG2)wPiAfN7TCusvpIGS1GwDqBUqlO8U8phjtagB5CYTaLycVlnnCbTPcTPcTSzdTPaT)Tsr0ko3B5OKQEebzRbT6G2CH2W54fKFJEawokPOUv7agHtWZ)CCbTPAyo)fnm8DZc2czDIAvZwibuQWeMKtGjnddE(NJltgggNg1Cgg6dkFIEUIk)CxeggAxb2LByYfA)BLIOvCU3Yrjv9icYwZWC(lAyOpO8j65kQ8ZDryctYjKjnddE(NJltgggAxb2LBysbAPZWxJ(JOvCU3Yrjv9icsJ(6b0YMn0sNHVg9hrR4CVLJsQ6reKgF96eqBMqBw5dTPcT6G2uG2CH2W54fKFJEawokPOUv7agHtWZ)CCbTSzdT0z4Rr)rWxTrp2YEFOup6AZrA81RtaTzcT51CG2unmonQ5mmBbkRaFfMWKCoM0mm45FoUmzyyCAuZzyCbyq5hkKTN90s60o3Wq7kWUCdZc)BLI0E2tlPt7C5c)BLISg9NH58x0W4cWGYpuiBp7PL0PDUjmjd6mPzyWZ)CCzYWW40OMZW4cWGYpuiBp7PL0PDUHH2vGD5gg6m81O)i4R2OhBzVpuQhDT5in(61jG2mH28A(qRoODH)TsrAp7PL0PDUCH)Tsr2AqRoOfuEx(NJKjaJTCo5wGsmH3LMgUGw2SH2)wPi)g9aSCusrDR2bmcNS1GwDq7c)BLI0E2tlPt7C5c)BLIS1GwDqBUqlO8U8phjtagB5CYTaLycVlnnCbTSzdT)TsrWxTrp2YEFOup6AZr2AqRoODH)TsrAp7PL0PDUCH)Tsr2AqRoOnxOnCoEb53OhGLJskQB1oGr4e88phxqlB2qBuVOmg5QqOfeOnRNgMZFrdJladk)qHS9SNwsN25MWKmOLjnddE(NJltgggNg1CgM8guibp65yByODfyxUHjfOft4DPPHlcF3SGTqwNOw1SfsaLkGwDq7FRueTIZ9wokPQhrqA81RtaTPcTSzdTPaT5cTycVlnnCr47MfSfY6e1QMTqcOub0QdA)BLIOvCU3Yrjv9icsJVEDcOfeO9zwqRoO9VvkIwX5ElhLu1JiiBnOnvdZ5VOHjVbfsWJEo2MWKmO3KMHbp)ZXLjddJtJAoddl3eYrj9Jw4fs1UFyyODfyxUHHodFn6pc(Qn6Xw27dL6rxBosJVEDcOntOnHY3WC(lAyy5MqokPF0cVqQ29dtysoVAsZWGN)54YKHHXPrnNHbqphaHuRRxNlBhaAyODfyxUHP3hcTGaeAta0QdAZfA)BLIOvCU3Yrjv9icYwdA1bTPaT5cT)Tsr(n6by5OKI6wTdyeozRbTSzdT5cTHZXli)g9aSCusrDR2bmcNGN)54cAt1WC(lAya0Zbqi16615Y2bGMWK8Z8nPzyWZ)CCzYWWC(lAyAp71(yri)fazJl5FhXCggNg1CgM2ZETpweYFbq24s(3rmNjmj)8PjnddE(NJltgggNg1CgMxSrwcWUqQ8dGHH2vGD5gMCH2)wPi)g9aSCusrDR2bmcNS1GwDqBUq7FRueTIZ9wokPQhrq2AgMZFrdZl2ilbyxiv(bWeMKFMLjnddE(NJltgggAxb2LBy(BLIOvCU3Yrjv9icYwdA1bT)TsrWxTrp2YEFOup6AZr2AggNg1CggTjQ5mHj5NjWKMHbp)ZXLjdddTRa7Ynm)Tsr0ko3B5OKQEebzRbT6G2)wPi4R2OhBzVpuQhDT5iBndJtJAodZNpZsQ29dtys(zczsZWGN)54YKHHH2vGD5gM)wPiAfN7TCusvpIGS1mmonQ5mmFSfyZsDamHj5N5ysZWGN)54YKHHH2vGD5gMuG2CH2)wPiAfN7TCusvpIGS1GwDqRtJcuOep8Tqb0MjqOnlOnvOLnBOnxO9VvkIwX5ElhLu1JiiBnOvh0Mc027djluv0kG2mbcT5aT6G2EFfvQn6XMSqvrRaAZei0c6YhAt1W40OMZW4n1puQT5c0eMKFc6mPzyWZ)CCzYWWq7kWUCdZFRueTIZ9wokPQhrq2AggNg1CggEbaCiK5n7fGx8ctys(jOLjnddE(NJltgggAxb2LBy(BLIOvCU3Yrjv9icYwdA1bT)TsrWxTrp2YEFOup6AZr2AggNg1Cgg)OOiANlPoNBctYpb9M0mm45FoUmzyyODfyxUH5VvkIwX5ElhLu1Jiin(61jGwqacTGEOvh0(3kfbF1g9yl79Hs9ORnhzRzyCAuZzyuvJF(mltys(zE1KMHbp)ZXLjdddTRa7Ynm)Tsr0ko3B5OKQEebzRbT6G2uG2)wPiAfN7TCusvpIG04RxNaAbbAZbA1bTHZXli0HVKGrVdcE(NJlOLnBOnxOnCoEbHo8Lem6DqWZ)CCbT6G2)wPiAfN7TCusvpIG04RxNaAbbAta0Mk0QdADAuGcL4HVfkGwGq7tOLnBO9VvkIaXaCDaKTdajBnOvh060OafkXdFluaTaH2NggNg1CgMVdqokz0fLfHjmjNv(M0mm45FoUmzyyODfyxUHHodFn6pc(Qn6Xw27dL6rxBosJVEDcOLnBOnCoEbPOi11i45FoUmmonQ5mmAfN7TCusvpIWeMKZ6PjnddE(NJltgggAxb2LByOZWxJ(JGVAJESL9(qPE01MJ04RxNaA1bT0z4Rr)r0ko3B5OKQEebPXxVoHHXPrnNH53OhGLJskQB1oGr4gMTaLJsjbqxMKFActYzLLjnddE(NJltgggAxb2LByOZWxJ(JOvCU3Yrjv9icsJ(6b0QdAdNJxqMpVcS9OMJGN)54cA1bT9(qsuVOmgzoqBMqla6cA1bT9(kQuB0JnzHQIwb0MjqO9z(qlB2qBuVOmg5QqOfeOnR8nmonQ5mm4R2OhBzVpuQhDT5mHj5SsGjnddE(NJltgggAxb2LBysbAPZWxJ(JOvCU3Yrjv9icsJ(6b0YMn0g1lkJrUkeAbbAZkFOnvOvh0gohVG8B0dWYrjf1TAhWiCcE(NJlOvh027ROsTrp2qBMqlOlFdJtJAodd(Qn6Xw27dL6rxBotysoReYKMHbp)ZXLjdddTRa7YnmHZXliffPUgbp)ZXf0QdA79HqliqBcmmonQ5mm4R2OhBzVpuQhDT5mHj5SYXKMHbp)ZXLjdddTRa7YnmHZXli0HVKGrVdcE(NJlOvh0Mc0Mc0(3kfHo8Lem6DqeHtzbAZei0(mFOvh0UW)wPiTN90ffjIWPSaTaH2CG2uHw2SH2OErzmYvHqliaHwa0f0MQHXPrnNHH6CU0PrnNKxIWWWlrip)fnm0HVKGrVdtysolqNjnddE(NJltgggAxb2LBysbA)BLIOvCU3Yrjv9icYwdA1bTE2yxbsk6djTcFHCs7hlqliaH2NqRoOnfO9VvkIwX5ElhLu1Jiin(61jGwqacTaOlOLnBO9VvkY(ap8hsr04biatA81RtaTGaeAbqxqRoO9VvkY(ap8hsr04biat2AqBQqBQggNg1CggvpIq)J(viv7(HjmjNfOLjnddE(NJltgggAxb2LBysbA)BLIu0hsAf(c5KTg0QdAZfAdNJxqkksDncE(NJlOvh0Mc0(3kfzFGh(dPiA8aeGjBnOLnBO9VvksrFiPv4lKtA81RtaTGaeAbqxqBQqBQqlB2q7FRuKI(qsRWxiNS1GwDq7FRuKI(qsRWxiN04RxNaAbbi0cGUGwDqB4C8csrrQRrWZ)CCbT6G2)wPiAfN7TCusvpIGS1mmonQ5mmQEeH(h9RqQ29dtysolqVjnddE(NJltgggAxb2LByI6fLXixfcTGaTaOlOLnBOnfOnQxugJCvi0cc0sNHVg9hrR4CVLJsQ6reKgF96eqRoO9VvkY(ap8hsr04biat2AqBQggNg1CggvpIq)J(viv7(HjmHHzHkFZdtAMKFAsZW40OMZW8w3sQAeZgnm45FoUmzyctYzzsZWGN)54YKHHH2vGD5gMCH21eevpIqQqqHnjkkl1baA1bTPaT5cTHZXli)g9aSCusrDR2bmcNGN)54cAzZgAPZWxJ(J8B0dWYrjf1TAhWiCsJVEDcOntO9zoqBQggNg1CggWJEEDaKFUlctysobM0mm45FoUmzyyODfyxUH5VvksrFidNpNG04RxNaAbbi0cGUGwDq7FRuKI(qgoFobzRbT6GwHgY5YWBayiia4oTCU0xGYpkcTzceAZcA1bTPaT5cTHZXli)g9aSCusrDR2bmcNGN)54cAzZgAPZWxJ(J8B0dWYrjf1TAhWiCsJVEDcOntO9zoqBQggNg1CggaCNwox6lq5hfnHj5eYKMHbp)ZXLjdddTRa7Ynm)Tsrk6dz485eKgF96eqliaHwa0f0QdA)BLIu0hYW5ZjiBnOvh0Mc0Ml0gohVG8B0dWYrjf1TAhWiCcE(NJlOLnBOLodFn6pYVrpalhLuu3QDaJWjn(61jG2mH2N5aTPAyCAuZzyu9icPi6If0eMKZXKMHbp)ZXLjddJtJAodd15CPtJAojVeHHHxIqE(lAyqHapkkmHjzqNjnddE(NJltgggNg1CggQZ5sNg1CsEjcddVeH88x0WqNHVg9NWeMKbTmPzyWZ)CCzYWWq7kWUCdt4C8cYVrpalhLuu3QDaJWj45FoUGwDqBkqBkqlDg(A0FKFJEawokPOUv7agHtA81RtaTaH28HwDqlDg(A0FeTIZ9wokPQhrqA81RtaTGaTpZhAtfAzZgAtbAPZWxJ(J8B0dWYrjf1TAhWiCsJVEDcOfeOnR8HwDqBuVOmg5QqOfeOnb5aTPcTPAyCAuZzy69jDAuZj5Limm8seYZFrdZFesTz41bWeMKb9M0mm45FoUmzyyODfyxUH5VvkYVrpalhLuu3QDaJWjBndJtJAodtVpPtJAojVeHHHxIqE(lAy(JqgfLL6ayctY5vtAgg88phxMmmm0UcSl3W83kfrR4CVLJsQ6reKTg0QdAdNJxqMpVcS9OMJGN)54YW40OMZW07t60OMtYlryy4LiKN)IgM5ZRaBpQ5mHj5N5BsZWGN)54YKHHH2vGD5ggNgfOqjE4BHcOntGqBwggNg1CgMEFsNg1CsEjcddVeH88x0W4dActYpFAsZWGN)54YKHHXPrnNHH6CU0PrnNKxIWWWlrip)fnmIWVL3ltycdJi8B59YKMj5NM0mmonQ5mmn(oTa5Oqi1xxGTHbp)ZXLjdtysoltAgg88phxMmmm0UcSl3WqNHVg9hPX3PfihfcP(6cSjn(61jGwqacTzbT5j0cGUGwDqB4C8ccapaJDDaKIy6xcE(NJldJtJAodJQhrifrxSGMWKCcmPzyWZ)CCzYWWq7kWUCdZFRuKUErYwZW40OMZWaE0ZRdG8ZDryctYjKjnddE(NJltgggAxb2LBycNJxqkksDncE(NJlOvh0(3kfrR4CVLJsQ6reKTg0QdA9SXUcKu0hsAf(c5K2pwG2mbcTzzyCAuZzyMpVcS9anHj5CmPzyWZ)CCzYWWq7kWUCdtUq7FRuevpzJNuBZfizRbT6G2W54fevpzJNuBZfibp)ZXLHXPrnNHz(8kW2d0eMKbDM0mm45FoUmzyyODfyxUHP3xrLAJESjluv0kGwqG2uG2N5aTjcTHZXli9(kQ0JaVTh1Ce88phxqBEcTjaAt1W40OMZWO6resr0flOjmjdAzsZWGN)54YKHHH2vGD5gM)wPiSuCEDaKVofCDizRbT6G2EFijQxugJmHG2mbcTaOldJtJAodJQhriOpcWOjmjd6nPzyWZ)CCzYWWq7kWUCdtVVIk1g9ytwOQOvaTzcTPaTzLd0Mi0gohVG07ROspc82EuZrWZ)CCbT5j0MaOnvdJtJAodZ85vGThOjmjNxnPzyCAuZzyu9icPi6If0WGN)54YKHjmj)mFtAggNg1CggWtFYrj1xxGTHbp)ZXLjdtys(5ttAggNg1CggVP(HYy6gVWWGN)54YKHjmHHbfc8OOWKMj5NM0mm45FoUmzyyODfyxUH5VvkIwX5ElhLu1JiiBnOvh0Mc0(3kfrR4CVLJsQ6reKgF96eqliq7Z8HwDqBkq7FRuKFJEawokPOUv7agHt2AqlB2qB4C8cY85vGTh1Ce88phxqlB2qB4C8csrrQRrWZ)CCbT6G2CHwpBSRajf9HKwHVqobp)ZXf0Mk0YMn0(3kfPOpK0k8fYjBnOvh0gohVGuuK6Ae88phxqBQggNg1CgMpFMLCuYamkXdFFyctYzzsZWGN)54YKHHH2vGD5gMCH2W54fKIIuxJGN)54cAzZgAdNJxqkksDncE(NJlOvh06zJDfiPOpK0k8fYj45FoUGwDq7FRueTIZ9wokPQhrqA81RtaTGaTGoOvh0(3kfrR4CVLJsQ6reKTg0YMn0gohVGuuK6Ae88phxqRoOnxO1Zg7kqsrFiPv4lKtWZ)CCzyCAuZzyaS9Ev(jhL0Zg7jaBctYjWKMHbp)ZXLjdddTRa7Ynm)Tsr0ko3B5OKQEebPXxVob0cc0Md0QdA)BLIOvCU3Yrjv9icYwdAzZgAJ6fLXixfcTGaT5yyCAuZzyOGloxkIgDwmHj5eYKMHbp)ZXLjdddTRa7Ynm)TsrAKYchfcPAAks2AqlB2q7FRuKgPSWrHqQMMIs6SVaBIiCklqliq7ZNggNg1CgMamk33F23sQMMIMWKCoM0mm45FoUmzyyODfyxUHjxO9VvkIwX5ElhLu1JiiBnOvh0Ml0(3kf53OhGLJskQB1oGr4KTMHXPrnNHrn0TaxspBSRaLF0FnHjzqNjnddE(NJltgggAxb2LByYfA)BLIOvCU3Yrjv9icYwdA1bT5cT)Tsr(n6by5OKI6wTdyeozRbT6G21ee6Cu8I2dCjvC)fL)DFKgF96eqlqOnFdJtJAoddDokEr7bUKkU)IMWKmOLjnddE(NJltgggAxb2LByYfA)BLIOvCU3Yrjv9icYwdA1bT5cT)Tsr(n6by5OKI6wTdyeozRzyCAuZzy02DPEuha5N7IWeMKb9M0mm45FoUmzyyODfyxUH5VvkIwX5ElhLu1JiiBnOLnBO9Vvkc(Qn6Xw27dL6rxBoYwdAzZgAPZWxJ(J8B0dWYrjf1TAhWiCsJVEDcOntOf0Lp0Mi0(mhdJtJAodJ(P5lqH1jBumNFu0eMKZRM0mm45FoUmzyyODfyxUHjxO9VvkIwX5ElhLu1JiiBnOvh0Ml0(3kf53OhGLJskQB1oGr4KTMHXPrnNHPlnnokRtk0CkActYpZ3KMHbp)ZXLjdddTRa7Ynm)TsrWxTrp2YEFOup6AZrA81RtaTGaT5aT6G2)wPi)g9aSCusrDR2bmcNS1Gw2SH2uG2EFijQxugJmlOntOfaDbT6G2EFfvQn6XgAbbAZjFOnvdJtJAodZl(o9d5OK8nTwYvJ(RWeMKF(0KMHXPrnNHPrxRoasf3FrHHbp)ZXLjdtyctyyaf2IAotYzLFw5N)ZSsidJEVV6aimm5bE1MoWf0(mFO1Prnh0YlriiqwnmA9OkoAyanqBEPhraT5TqpadT5TVca4aYkObAbhHMiVp90bub49NqN30f17M7rnhTDvKUOEPPdzf0aT5f83BVFaTjijOnR8ZkFiRqwbnqBEey)aGI8EiRGgOf0gAZdCu(EHqBEO1TG28sJy2ibYkObAbTH28yRf0QCo)7uwGw10q7wuhaOnpyEN8UjbT5HN8c0wkOvJ7pWgARRIYduaTzmmq7hvtJqR2m86aaT8bqrH2saT05vJJbUiqwbnqlOn0Mhb2pai0gEdadsuVOmg5QqOngOnQxugJCvi0gd0Ufi0IhD2xGn0YXdqagABpaJn0gG9dA1MaVOCo0gTladTl0dWccKvqd0cAdT5rdFbT5HGEhqRFlOTDA5COn0JolccKviRGgOnpyECiDh4cA)OAAeAPZ73dO9JaQtqG28yukQfcO9Md0gS3VQnhADAuZjG254piqwDAuZjiAnsN3VhjcmDTjQ5GS60OMtq0AKoVFpsey6BbkRaFt68xeONTaS3UqQMlKJsQn6XgYQtJAobrRr68(9irGPdkVl)ZXKo)fbobySLZj3cuIj8U00WvsGY5BeykycVlnnCrUjMUMTqcG7RYJPfYVVaGSzJj8U00WfHoDV1cCjbW9v5X0c53xaq2SXeExAA4IqNU3AbUKa4(Q8yAH8fxoNxZXMnMW7stdxeqvoxokPF1Rh4s(5ZSyZgt4DPPHlIQAriF9afsH2daCxiyZgt4DPPHlsEdkKGh9CSzZgt4DPPHlYnX01SfsaCFvEmTq(IlNZR5yZgt4DPPHlIladk)qHS9SNwsN25PczfYkObAZdMhhs3bUGweuy)aAJ6fH2amcTonMgAlb06GYlU)5ibYQtJAobW36wsvJy2iKvqd0MhttJ)aAZl9icOnVGGcBO1Vf0(61fEDqBEa6dOnnNpNaYQtJAorIath8ONxha5N7IiPsbm31eevpIqQqqHnjkkl1bqxk5gohVG8B0dWYrjf1TAhWiCcE(NJl2SPZWxJ(J8B0dWYrjf1TAhWiCsJVEDImFMtQqwDAuZjsey6a4oTCU0xGYpkMuPa(3kfPOpKHZNtqA81Rtacqa0LU)wPif9HmC(CcYwtNqd5Cz4nameeaCNwox6lq5hfZeyw6sj3W54fKFJEawokPOUv7agHtWZ)CCXMnDg(A0FKFJEawokPOUv7agHtA81RtK5ZCsfYQtJAorIatx1JiKIOlwWKkfW)wPif9HmC(CcsJVEDcqacGU093kfPOpKHZNtq2A6sj3W54fKFJEawokPOUv7agHtWZ)CCXMnDg(A0FKFJEawokPOUv7agHtA81RtK5ZCsfYQtJAorIatN6CU0PrnNKxIiPZFrGOqGhffqwDAuZjsey6uNZLonQ5K8sejD(lcKodFn6pbKvNg1CIebMEVpPtJAojVersN)Ia)JqQndVoajvkGHZXli)g9aSCusrDR2bmcNGN)54sxkPqNHVg9h53OhGLJskQB1oGr4KgF96eaZxhDg(A0FeTIZ9wokPQhrqA81RtaYZ8tLn7uOZWxJ(J8B0dWYrjf1TAhWiCsJVEDcqYkFDr9IYyKRcbjb5KAQqwDAuZjsey69(KonQ5K8sejD(lc8pczuuwQdqsLc4FRuKFJEawokPOUv7agHt2AqwDAuZjsey69(KonQ5K8sejD(lcC(8kW2JAUKkfW)wPiAfN7TCusvpIGS10fohVGmFEfy7rnhbp)ZXfKvNg1CIebMEVpPtJAojVersN)Ia9btQuaDAuGcL4HVfkYeywqwDAuZjsey6uNZLonQ5K8sejD(lcue(T8EbzfYQtJAobXheyJVtlqokes91fyNuPagohVGaWdWyxhaPiM(LGN)54In7u8SXUcKO6jB8Kb(QHIG0(XIoHgY5YWBayiin(oTa5Oqi1xxGDMatGUC)BLI01ls2APcz1PrnNG4dMiW0bWDA5CPVaLFumPsbmCoEbr1Jie0hbyKGN)54cYQtJAobXhmrGPR6resr0flys0huokdVbGHa4ZKkfWuw4FRuK2ZE6IIer4uwajh2Sx4FRuK2ZE6IIKgF96eG8m)u1rNHVg9hPX3PfihfcP(6cSjn(61jabyw5ja6sx4C8ccapaJDDaKIy6xcE(NJlD5gohVGO6rec6JamsWZ)CCbz1PrnNG4dMiW0v9icPi6IfmPsbKodFn6psJVtlqokes91fytA81RtacWSYta0LUW54feaEag76aifX0Ve88phxqwDAuZji(GjcmDWJEEDaKFUlIKkfW)wPiD9IKTgKvNg1CcIpyIatx1Jie0hbymPsb8VvkclfNxha5Rtbxhs2AqwDAuZji(GjcmDaCNwox6lq5hftQua79vuP2OhBYcvfTcqs5zojgohVG07ROspc82EuZrWZ)CCLNjiviRonQ5eeFWebMUQhrifrxSGjrFq5Om8gagcGptQuatzH)TsrAp7PlkseHtzbKCyZEH)TsrAp7PlksA81RtaYZ8tvxVVIk1g9ytwOQOvaskpZjXW54fKEFfv6rG32JAocE(NJR8mbPQl3W54fevpIqqFeGrcE(NJliRonQ5eeFWebMUQhrifrxSGjvkG9(kQuB0JnzHQIwbiP8mNedNJxq69vuPhbEBpQ5i45FoUYZeKQUCdNJxqu9icb9ragj45FoUGS60OMtq8btey6n(oTa5Oqi1xxGnKvNg1CcIpyIatx1Jie0hbyeYQtJAobXhmrGPpFEfy7bMe9bLJYWBayia(mPsbmLf(3kfP9SNUOireoLfqYHn7f(3kfP9SNUOiPXxVobipZpvD9(kQuB0JnzHQIwrMPKvojgohVG07ROspc82EuZrWZ)CCLNjivD5gohVGO6rec6JamsWZ)CCbz1PrnNG4dMiW0NpVcS9atQua79vuP2OhBYcvfTImtjRCsmCoEbP3xrLEe4T9OMJGN)54kptqQqwDAuZji(GjcmDaCNwox6lq5hfHS60OMtq8btey6QEeHueDXcMe9bLJYWBayia(mPsbmLf(3kfP9SNUOireoLfqYHn7f(3kfP9SNUOiPXxVobipZpvD5gohVGO6rec6JamsWZ)CCbz1PrnNG4dMiW0v9icPi6IfeYQtJAobXhmrGPdE6tokP(6cSHS60OMtq8btey6Et9dLX0nEbKviRGgOnJg9am0okOLPUv7agHdTAZWRda02t4rnh0M3dTIW7qaTzLVaA)OAAeAZdxCU3q7OG28spIaAteAZyyGwVrO1bLxC)ZriRonQ5eK)iKAZWRdaqWJEEDaKFUlIKkfW)wPiD9IKTgKvNg1CcYFesTz41birGPpFEfy7bMe9bLJYWBayia(mPsbmLf(3kfP9SNUOireoLfqYHn7f(3kfP9SNUOiPXxVobipZpvD9(kQuB0JnzHQIwrMaZkhD5gohVGO6rec6JamsWZ)CCbz1PrnNG8hHuBgEDasey6ZNxb2EGjvkG9(kQuB0JnzHQIwrMaZkhiRonQ5eK)iKAZWRdqIatha3PLZL(cu(rXKkfWEFfvQn6XMSqvrRaKSYxNqd5Cz4nameeaCNwox6lq5hfZeyw6OZWxJ(JOvCU3Yrjv9icsJVEDImZbYQtJAob5pcP2m86aKiW0v9icPi6Ifmj6dkhLH3aWqa8zsLcykl8Vvks7zpDrrIiCklGKdB2l8Vvks7zpDrrsJVEDcqEMFQ669vuP2OhBYcvfTcqYkFD5gohVGO6rec6JamsWZ)CCPJodFn6pIwX5ElhLu1Jiin(61jYmhiRonQ5eK)iKAZWRdqIatx1JiKIOlwWKkfWEFfvQn6XMSqvrRaKSYxhDg(A0FeTIZ9wokPQhrqA81RtKzoqwDAuZji)ri1MHxhGebMUQhriOpcWysLc4FRuewkoVoaYxNcUoKS1017ROsTrp2KfQkAfzMYZCsmCoEbP3xrLEe4T9OMJGN)54kptqQ6eAiNldVbGHGO6rec6JamMjWSGS60OMtq(JqQndVoajcmDvpIqqFeGXKkfWEFfvQn6XMSqvrRitGPKGCsmCoEbP3xrLEe4T9OMJGN)54kptqQ6eAiNldVbGHGO6rec6JamMjWSGS60OMtq(JqQndVoajcm95ZRaBpWKOpOCugEdadbWNjvkGPSW)wPiTN90ffjIWPSasoSzVW)wPiTN90ffjn(61ja5z(PQR3xrLAJESjluv0kYeykjiNedNJxq69vuPhbEBpQ5i45FoUYZeKQUCdNJxqu9icb9ragj45FoUGS60OMtq(JqQndVoajcm95ZRaBpWKkfWEFfvQn6XMSqvrRitGPKGCsmCoEbP3xrLEe4T9OMJGN)54kptqQqwDAuZji)ri1MHxhGebMoaUtlNl9fO8JIjvkG0z4Rr)r0ko3B5OKQEebPXxVorM9(qsuVOmgzcPR3xrLAJESjluv0kajHYxNqd5Cz4nameeaCNwox6lq5hfZeywqwDAuZji)ri1MHxhGebMUQhrifrxSGjrFq5Om8gagcGptQuatzH)TsrAp7PlkseHtzbKCyZEH)TsrAp7PlksA81RtaYZ8tvhDg(A0FeTIZ9wokPQhrqA81RtKzVpKe1lkJrMq669vuP2OhBYcvfTcqsO81LB4C8cIQhriOpcWibp)ZXfKvNg1CcYFesTz41birGPR6resr0flysLciDg(A0FeTIZ9wokPQhrqA81RtKzVpKe1lkJrMq669vuP2OhBYcvfTcqsO8HSczf0aT5fNZ)oLfOngODlqOnp8KxscAZdM3jVl0QhmEq7wGnODDvuEGcOnJHbA1A81JDJ8heiRonQ5eK)iKrrzPoaa1ko3B5OKQEersLciDg(A0Fe8vB0JTS3hk1JU2CKgF96eqwDAuZji)riJIYsDasey64R2OhBzVpuQhDT5GS60OMtq(JqgfLL6aKiW0NpVcS9atI(GYrz4nameaFMuPaMYc)BLI0E2txuKicNYci5WM9c)BLI0E2txuK04RxNaKN5NQUEFfvQn6XgeGjilD5gohVGO6rec6JamsWZ)CCbz1PrnNG8hHmkkl1birGPpFEfy7bMuPa27ROsTrp2Gambzbz1PrnNG8hHmkkl1birGP3470cKJcHuFDb2jvkGHZXlia8am21bqkIPFj45FoUGS60OMtq(JqgfLL6aKiW0bp651bq(5UisQua)BLI01ls2AqwDAuZji)riJIYsDasey6ZNxb2EGjrFq5Om8gagcGptQuatzH)TsrAp7PlkseHtzbKCyZEH)TsrAp7PlksA81RtaYZ8tvxVpKe1lkJrMdiaOl2S79vuP2OhBqaMq5Ol3W54fevpIqqFeGrcE(NJliRonQ5eK)iKrrzPoajcm95ZRaBpWKkfWEFijQxugJmhqaqxSz37ROsTrp2GamHYbYQtJAob5pczuuwQdqIatx1Jie0hbymPsb8VvkclfNxha5Rtbxhs2A6eAiNldVbGHGO6rec6JamMjWSGS60OMtq(JqgfLL6aKiW0bp9jhLuFDb2jvkG9(kQuB0JnzHQIwrMatqw669HKOErzmYeKja6cYQtJAob5pczuuwQdqIatVX3PfihfcP(6cSHS60OMtq(JqgfLL6aKiW0v9icb9ragtQuafAiNldVbGHGO6rec6JamMjWSGS60OMtq(JqgfLL6aKiW0NpVcS9atI(GYrz4nameaFMuPaMYc)BLI0E2txuKicNYci5WM9c)BLI0E2txuK04RxNaKN5NQUEFfvQn6XMSqvrRiZSYHn7EFyMjqxUHZXliQEeHG(iaJe88phxqwDAuZji)riJIYsDasey6ZNxb2EGjvkG9(kQuB0JnzHQIwrMzLdB29(WmtaKvNg1CcYFeYOOSuhGebMU3u)qzmDJxKuPa27ROsTrp2KfQkAfzMt(qwHScAG28OHVGwWO3b0sNBvrnNaYQtJAobHo8Lem6DaKc2RtihLSOysLc4FRue6WxsWO3breoLLmZrxuVOmg5QqqaqxqwDAuZji0HVKGrVJebMofSxNqokzrXKkfWu(BLIiqmaxhaz7aqsJVEDcqaqxPQ7VvkIaXaCDaKTdajBniRonQ5ee6WxsWO3rIatNc2RtihLSOysLcyk)Tsr0ko3B5OKQEebPXxVobiabqx5zkptKodFn6pIQhrO)r)kKQD)G0OVEKkB2)Tsr0ko3B5OKQEebPXxVobi9(qsuVOmgzcsv3FRueTIZ9wokPQhrq2A6sXZg7kqsrFiPv4lKtA)ybeGpzZ(VvkYVrpalhLuu3QDaJWjBTu1LB4C8csrrQRrWZ)CCbz1PrnNGqh(scg9osey6uWEDc5OKfftQua)BLIOvCU3Yrjv9icsJVEDcqa96(BLISpWd)HuenEacWKgF96eGaGUYZuEMiDg(A0FevpIq)J(viv7(bPrF9ivD)Tsr2h4H)qkIgpabysJVEDcD)Tsr0ko3B5OKQEebzRPlfpBSRajf9HKwHVqoP9Jfqa(Kn7)wPi)g9aSCusrDR2bmcNS1svxUHZXliffPUgbp)ZXfKvNg1CccD4ljy07irGPtb71jKJswumPsbmL)wPif9HKwHVqoPXxVobijeB2)Tsrk6djTcFHCsJVEDcq69HKOErzmYeKQU)wPif9HKwHVqozRPZZg7kqsrFiPv4lKtA)yjtGzPl3)wPi)g9aSCusrDR2bmcNS10LB4C8csrrQRrWZ)CCbz1PrnNGqh(scg9osey6uWEDc5OKfftQua)BLIu0hsAf(c5KTMU)wPi7d8WFifrJhGamzRPZZg7kqsrFiPv4lKtA)yjtGzPl3)wPi)g9aSCusrDR2bmcNS10LB4C8csrrQRrWZ)CCbz1PrnNGqh(scg9osey6uWEDc5OKfftQua)BLIOvCU3Yrjv9icsJVEDcqsiD)Tsr0ko3B5OKQEebzRPlCoEbPOi11i45FoU093kfHo8Lem6DqeHtzjtGpb968SXUcKu0hsAf(c5K2pwab4tiRonQ5ee6WxsWO3rIatNc2RtihLSOysLc4FRueTIZ9wokPQhrq2A6cNJxqkksDncE(NJlDE2yxbsk6djTcFHCs7hlzcmlDP83kfHo8Lem6DqeHtzjtGpZR6(BLIu0hsAf(c5KgF96eGaGU093kfPOpK0k8fYjBn2S)BLISpWd)HuenEacWKTMU)wPi0HVKGrVdIiCklzc8jOpviRqwDAuZji0z4Rr)jaUfOSc8nPZFrGE2cWE7cPAUqokP2Oh7KkfWuOZWxJ(JGVAJESL9(qPE01MJ0OVEOlxq5D5FosMam2Y5KBbkXeExAA4kv2StHodFn6pIwX5ElhLu1Jiin(61jab4Z81bkVl)ZrYeGXwoNClqjMW7stdxPcz1PrnNGqNHVg9NirGPVfOSc8nPZFrG8DZc2czDIAvZwibuQiPsbmCoEb53OhGLJskQB1oGr4e88phx6sjf6m81O)iAfN7TCusvpIG04RxNaeGpZxhO8U8phjtagB5CYTaLycVlnnCLkB2P83kfrR4CVLJsQ6reKTMUCbL3L)5izcWylNtUfOet4DPPHRutLn7u(BLIOvCU3Yrjv9icYwtxUHZXli)g9aSCusrDR2bmcNGN)54kviRonQ5ee6m81O)ejcm9TaLvGVjD(lcK(GYNONROYp3frsLcyU)Tsr0ko3B5OKQEebzRbz1PrnNGqNHVg9NirGPVfOSc8vKuPaMcDg(A0FeTIZ9wokPQhrqA0xpyZModFn6pIwX5ElhLu1Jiin(61jYmR8tvxk5gohVG8B0dWYrjf1TAhWiCcE(NJl2SPZWxJ(JGVAJESL9(qPE01MJ04RxNiZ8AoPcz1PrnNGqNHVg9NirGPVfOSc8nPZFrGUamO8dfY2ZEAjDANNuPaUW)wPiTN90s60oxUW)wPiRr)bz1PrnNGqNHVg9NirGPVfOSc8nPZFrGUamO8dfY2ZEAjDANNuPasNHVg9hbF1g9yl79Hs9ORnhPXxVorM5181TW)wPiTN90s60oxUW)wPiBnDGY7Y)CKmbySLZj3cuIj8U00WfB2)Tsr(n6by5OKI6wTdyeozRPBH)TsrAp7PL0PDUCH)Tsr2A6YfuEx(NJKjaJTCo5wGsmH3LMgUyZ(Vvkc(Qn6Xw27dL6rxBoYwt3c)BLI0E2tlPt7C5c)BLIS10LB4C8cYVrpalhLuu3QDaJWj45FoUyZoQxugJCviiz9eYQtJAobHodFn6prIatFlqzf4BsN)IaZBqHe8ONJDsLcykycVlnnCr47MfSfY6e1QMTqcOuHU)wPiAfN7TCusvpIG04RxNiv2StjxmH3LMgUi8DZc2czDIAvZwibuQq3FRueTIZ9wokPQhrqA81RtaYZS093kfrR4CVLJsQ6reKTwQqwDAuZji0z4Rr)jsey6BbkRaFt68xeil3eYrj9Jw4fs1UFKuPasNHVg9hbF1g9yl79Hs9ORnhPXxVorMju(qwDAuZji0z4Rr)jsey6BbkRaFt68xeiGEoacPwxVox2oamPsbS3hccWeOl3)wPiAfN7TCusvpIGS10LsU)Tsr(n6by5OKI6wTdyeozRXMDUHZXli)g9aSCusrDR2bmcNGN)54kviRonQ5ee6m81O)ejcm9TaLvGVjD(lcS9Sx7JfH8xaKnUK)DeZbz1PrnNGqNHVg9NirGPVfOSc8nPZFrGVyJSeGDHu5hGKkfWC)BLI8B0dWYrjf1TAhWiCYwtxU)Tsr0ko3B5OKQEebzRbz1PrnNGqNHVg9NirGPRnrnxsLc4FRueTIZ9wokPQhrq2A6(BLIGVAJESL9(qPE01MJS1GS60OMtqOZWxJ(tKiW0)8zws1UFKuPa(3kfrR4CVLJsQ6reKTMU)wPi4R2OhBzVpuQhDT5iBniRonQ5ee6m81O)ejcm9p2cSzPoajvkG)Tsr0ko3B5OKQEebzRbz1PrnNGqNHVg9NirGP7n1puQT5cmPsbmLC)BLIOvCU3Yrjv9icYwtNtJcuOep8TqrMaZkv2SZ9VvkIwX5ElhLu1JiiBnDP07djluv0kYeyo669vuP2OhBYcvfTImbc6YpviRonQ5ee6m81O)ejcmDEbaCiK5n7fGx8IKkfW)wPiAfN7TCusvpIGS1GS60OMtqOZWxJ(tKiW09JIIODUK6CEsLc4FRueTIZ9wokPQhrq2A6(BLIGVAJESL9(qPE01MJS1GS60OMtqOZWxJ(tKiW0vvJF(mRKkfW)wPiAfN7TCusvpIG04RxNaeGGED)TsrWxTrp2YEFOup6AZr2AqwDAuZji0z4Rr)jsey6FhGCuYOlklIKkfW)wPiAfN7TCusvpIGS10LYFRueTIZ9wokPQhrqA81Rtaso6cNJxqOdFjbJEhe88phxSzNB4C8ccD4ljy07GGN)54s3FRueTIZ9wokPQhrqA81RtascsvNtJcuOep8TqbWNSz)3kfrGyaUoaY2bGKTMoNgfOqjE4BHcGpHSczf0aT5LEeb0sNHVg9NaYQtJAobHodFn6prIatxR4CVLJsQ6rejvkG0z4Rr)rWxTrp2YEFOup6AZrA81RtWMD4C8csrrQRrWZ)CCbz1PrnNGqNHVg9NirGP)B0dWYrjf1TAhWi8K2cuokLeaDb8zsLciDg(A0Fe8vB0JTS3hk1JU2CKgF96e6OZWxJ(JOvCU3Yrjv9icsJVEDciRonQ5ee6m81O)ejcmD8vB0JTS3hk1JU2CjvkG0z4Rr)r0ko3B5OKQEebPrF9qx4C8cY85vGTh1Ce88phx669HKOErzmYCYeaDPR3xrLAJESjluv0kYe4Z8zZoQxugJCviizLpKvNg1CccDg(A0FIebMo(Qn6Xw27dL6rxBUKkfWuOZWxJ(JOvCU3Yrjv9icsJ(6bB2r9IYyKRcbjR8tvx4C8cYVrpalhLuu3QDaJWj45FoU017ROsTrp2zc6YhYQtJAobHodFn6prIathF1g9yl79Hs9ORnxsLcy4C8csrrQRrWZ)CCPR3hcscGS60OMtqOZWxJ(tKiW0PoNlDAuZj5Lis68xeiD4ljy07iPsbmCoEbHo8Lem6DqWZ)CCPlLu(BLIqh(scg9oiIWPSKjWN5RBH)TsrAp7PlkseHtzbyoPYMDuVOmg5QqqacGUsfYQtJAobHodFn6prIatx1Ji0)OFfs1UFKuPaMYFRueTIZ9wokPQhrq2A68SXUcKu0hsAf(c5K2pwab4tDP83kfrR4CVLJsQ6reKgF96eGaeaDXM9FRuK9bE4pKIOXdqaM04RxNaeGaOlD)Tsr2h4H)qkIgpabyYwl1uHS60OMtqOZWxJ(tKiW0v9ic9p6xHuT7hjvkGP83kfPOpK0k8fYjBnD5gohVGuuK6Ae88phx6s5VvkY(ap8hsr04biat2ASz)3kfPOpK0k8fYjn(61jabia6k1uzZ(VvksrFiPv4lKt2A6(BLIu0hsAf(c5KgF96eGaeaDPlCoEbPOi11i45FoU093kfrR4CVLJsQ6reKTgKvNg1CccDg(A0FIebMUQhrO)r)kKQD)iPsbmQxugJCviiaOl2StjQxugJCvii0z4Rr)r0ko3B5OKQEebPXxVoHU)wPi7d8WFifrJhGamzRLkKviRonQ5eeuiWJIcGF(ml5OKbyuIh((iPsb8VvkIwX5ElhLu1JiiBnDP83kfrR4CVLJsQ6reKgF96eG8mFDP83kf53OhGLJskQB1oGr4KTgB2HZXliZNxb2EuZrWZ)CCXMD4C8csrrQRrWZ)CCPlxpBSRajf9HKwHVqobp)ZXvQSz)3kfPOpK0k8fYjBnDHZXliffPUgbp)ZXvQqwDAuZjiOqGhffjcmDaBVxLFYrj9SXEcWjvkG5gohVGuuK6Ae88phxSzhohVGuuK6Ae88phx68SXUcKu0hsAf(c5e88phx6(BLIOvCU3Yrjv9icsJVEDcqaD6(BLIOvCU3Yrjv9icYwJn7W54fKIIuxJGN)54sxUE2yxbsk6djTcFHCcE(NJliRonQ5eeuiWJIIebMofCX5sr0OZssLc4FRueTIZ9wokPQhrqA81Rtaso6(BLIOvCU3Yrjv9icYwJn7OErzmYvHGKdKvNg1Cccke4rrrIatpaJY99N9TKQPPysLc4FRuKgPSWrHqQMMIKTgB2)TsrAKYchfcPAAkkPZ(cSjIWPSaYZNqwDAuZjiOqGhffjcmD1q3cCj9SXUcu(r)nPsbm3)wPiAfN7TCusvpIGS10L7FRuKFJEawokPOUv7agHt2AqwDAuZjiOqGhffjcmD6Cu8I2dCjvC)ftQuaZ9VvkIwX5ElhLu1JiiBnD5(3kf53OhGLJskQB1oGr4KTMU1ee6Cu8I2dCjvC)fL)DFKgF96eaZhYQtJAobbfc8OOirGPRT7s9OoaYp3frsLcyU)Tsr0ko3B5OKQEebzRPl3)wPi)g9aSCusrDR2bmcNS1GS60OMtqqHapkksey66NMVafwNSrXC(rXKkfW)wPiAfN7TCusvpIGS1yZ(Vvkc(Qn6Xw27dL6rxBoYwJnB6m81O)i)g9aSCusrDR2bmcN04RxNitqx(j(mhiRonQ5eeuiWJIIebMExAACuwNuO5umPsbm3)wPiAfN7TCusvpIGS10L7FRuKFJEawokPOUv7agHt2AqwDAuZjiOqGhffjcm9x8D6hYrj5BATKRg9xrsLc4FRue8vB0JTS3hk1JU2CKgF96eGKJU)wPi)g9aSCusrDR2bmcNS1yZoLEFijQxugJmRmbqx669vuP2OhBqYj)uHS60OMtqqHapkksey6n6A1bqQ4(lkGSczf0aT5X)5vGTh1CqBpHh1CqwDAuZjiZNxb2EuZbSX3PfihfcP(6cStQuadNJxqa4bySRdGuet)sWZ)CCbz1PrnNGmFEfy7rnxIatF(8kW2dmj6dkhLH3aWqa8zsLcykl8Vvks7zpDrrIiCklGKdB2l8Vvks7zpDrrsJVEDcqEMFQ6YnCoEbr1Jie0hbyKGN)54sxU)Tsr66fjBnDcnKZLH3aWqqap651bq(5UiYeycGS60OMtqMpVcS9OMlrGPpFEfy7bMuPaMB4C8cIQhriOpcWibp)ZXLUC)BLI01ls2A6eAiNldVbGHGaE0ZRdG8ZDrKjWeaz1PrnNGmFEfy7rnxIatx1Jie0hbymPsbmL)wPiSuCEDaKVofCDiPrNgSzNYFRuewkoVoaYxNcUoKS10LIwJGscGUipjQEeHueDXcYMTwJGscGUipjGh986ai)CxeSzR1iOKaOlYtcaUtlNl9fO8JIPMAQ6eAiNldVbGHGO6rec6JamMjWSGS60OMtqMpVcS9OMlrGPpFEfy7bMe9bLJYWBayia(mPsbmLf(3kfP9SNUOireoLfqYHn7f(3kfP9SNUOiPXxVobipZpvD)TsryP486aiFDk46qsJonyZoL)wPiSuCEDaKVofCDizRPlfTgbLeaDrEsu9icPi6IfKnBTgbLeaDrEsap651bq(5UiyZwRrqjbqxKNeaCNwox6lq5hftnviRonQ5eK5ZRaBpQ5sey6ZNxb2EGjvkG)TsryP486aiFDk46qsJonyZoL)wPiSuCEDaKVofCDizRPlfTgbLeaDrEsu9icPi6IfKnBTgbLeaDrEsap651bq(5UiyZwRrqjbqxKNeaCNwox6lq5hftnviRonQ5eK5ZRaBpQ5sey6a4oTCU0xGYpkMuPaMsU)Tsr66fjBn2S79vuP2OhBYcvfTcqEMpB29(qsuVOmgzwzcGUsvNqd5Cz4nameeaCNwox6lq5hfZeywqwDAuZjiZNxb2EuZLiW0bp651bq(5UisQua)BLI01ls2A6eAiNldVbGHGaE0ZRdG8ZDrKjWSGS60OMtqMpVcS9OMlrGPR6resr0flys0huokdVbGHa4ZKkfWuw4FRuK2ZE6IIer4uwajh2Sx4FRuK2ZE6IIKgF96eG8m)u1L7FRuKUErYwJn7EFfvQn6XMSqvrRaKN5ZMDVpKe1lkJrMvMaOlD5gohVGO6rec6JamsWZ)CCbz1PrnNGmFEfy7rnxIatx1JiKIOlwWKkfWC)BLI01ls2ASz37ROsTrp2KfQkAfG8mF2S79HKOErzmYSYeaDbz1PrnNGmFEfy7rnxIath8ONxha5N7IiPsb8VvksxVizRbz1PrnNGmFEfy7rnxIatF(8kW2dmj6dkhLH3aWqa8zsLcykl8Vvks7zpDrrIiCklGKdB2l8Vvks7zpDrrsJVEDcqEMFQ6YnCoEbr1Jie0hbyKGN)54cYQtJAobz(8kW2JAUebM(85vGThiKviRGgOLj8B59cAf1bGJG2H3aWaA7j8OMdYQtJAobre(T8EbSX3PfihfcP(6cSHS60OMtqeHFlVxjcmDvpIqkIUybtQuaPZWxJ(J0470cKJcHuFDb2KgF96eGamR8eaDPlCoEbbGhGXUoasrm9lbp)ZXfKvNg1CcIi8B59krGPdE0ZRdG8ZDrKuPa(3kfPRxKS1GS60OMtqeHFlVxjcm95ZRaBpWKkfWW54fKIIuxJGN)54s3FRueTIZ9wokPQhrq2A68SXUcKu0hsAf(c5K2pwYeywqwDAuZjiIWVL3RebM(85vGThysLcyU)Tsru9KnEsTnxGKTMUW54fevpzJNuBZfibp)ZXfKvNg1CcIi8B59krGPR6resr0flysLcyVVIk1g9ytwOQOvaskpZjXW54fKEFfv6rG32JAocE(NJR8mbPcz1PrnNGic)wEVsey6QEeHG(iaJjvkG)TsryP486aiFDk46qYwtxVpKe1lkJrMqzceaDbz1PrnNGic)wEVsey6ZNxb2EGjvkG9(kQuB0JnzHQIwrMPKvojgohVG07ROspc82EuZrWZ)CCLNjiviRonQ5eer43Y7vIatx1JiKIOlwqiRonQ5eer43Y7vIath80NCus91fydz1PrnNGic)wEVsey6Et9dLX0nEHHrOHutYzLZttycJb]] )
    
end
