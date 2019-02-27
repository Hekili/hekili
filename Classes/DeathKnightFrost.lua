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

            stop = function ( x ) return x < 15 end,

            interval = 1,
            value = -15
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

    local spendHook = function( amt, resource )
        if amt > 0 and resource == "runes" then
            gain( amt * 10, "runic_power" )

            if talent.gathering_storm.enabled and buff.remorseless_winter.up then
                buff.remorseless_winter.expires = buff.remorseless_winter.expires + ( 0.5 * amt )
            end

        --[[ elseif amt > 0 and resource == "runic_power" then
            if set_bonus.tier20_2pc == 1 and buff.pillar_of_frost.up then
                virtual_rp_spent_since_pof = virtual_rp_spent_since_pof + amt

                applyBuff( "pillar_of_frost", buff.pillar_of_frost.remains + floor( virtual_rp_spent_since_pof / 60 ) )
                virtual_rp_spent_since_pof = virtual_rp_spent_since_pof % 60
            end ]]
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
        chill_streak = 706, -- 204160
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

            spend = 15,
            readySpend = 50,
            spendType = "runic_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1029007,

            handler = function ()
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
            cooldown = function () return 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
            recharge = function () return 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
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

        potion = "battle_potion_of_strength",

        package = "Frost DK",
    } )


    spec:RegisterPack( "Frost DK", 20190226.2315, [[due0HbqiaYJKKuBscnkIItruzvau9kiXSKiDlak1Uq6xerdts4yQIwMe4zssnnjjUMeX2GKOVbqHXbjPohKewhKKyEQc3tvAFeLoOKKuwOe0dbOeteGs6IauK2OKK4KssswjG8sakQBcjjXojQ6NqssAOqssTuakINc0ujc7fQ)svdMuhwyXQQhJyYQ0LrTzQ8zj1OHuNw0RbWSj52QODR0VvmCvy5s9CctNY1Hy7qs9DI04LKKQZdOwVKO5lrTFqJFILadEdJXYxqfprfvuqbOsAbvxqfLGbnGpym4rqaiQzm4gNmgSQ0JWGAaRaMXGhbWQjUyjWGIbPjmgeTzhcufjLSon0iFkzoLuKNiQWYzjD4mjf5jrYVA(s(DbG9LrTKh94sflKevDZaMe5vijQAat8aw5Wq7bmVznAZxv6ryurEsWGFKuzvvl(JbVHXy5lOINOIkkOaujTGQFIkQgWadgig6PXGG5jGfmi68E5f)XGxwqWGvnuxv6ryqnGvom0qnG5nRrBqGQAOgTzhcufjLSon0iFkzoLuKNiQWYzjD4mjf5jrsiqvnuxv4FJenWqDbOYsH6cQ4jQaQbSH6cQgv5zjqGGav1qnGf0XwZcufiqvnudyd1vvlrHCzOgvLCVqDvPzUsMIbvPWeyjWGKrD9O5OnSey5FILadYB8v8fxigK0PXDgyWpIZrjJ66rZrBuHfeaGAzH6sG6IqTfDnBulpzVn(BYq9dOUMCXGbXYzXGe0rUc)48jHXgw(cWsGb5n(k(Ileds604odmOmq9hX5OhPsfTFCExpcJ28zKRaQF8c11Klud4qTmq9tOgfOMmJ6osxQRhHjf4(u4DinW0MJlWqTCqD5Yq9hX5OhPsfTFCExpcJ28zKRaQFa1nYYulpzVn(QHA5G6Iq9hX5OhPsfTFCExpcJICa1fH6OsUtJPjbypjT4YkAhlaq9JxOUamyqSCwmibDKRWpoFsySHLVASeyqEJVIV4cXGKonUZad(rCo6rQur7hN31JWOnFg5kG6hqnQgQlc1FeNJISOhfWEH18wBOPnFg5kG6hqDn5c1aouldu)eQrbQjZOUJ0L66rysbUpfEhsdmT54cmulhuxeQ)iohfzrpkG9cR5T2qtB(mYva1fH6pIZrpsLkA)48UEegf5aQlc1rLCNgttcWEsAXLv0owaG6hVqDbyWGy5Syqc6ixHFC(KWydlFvWsGb5n(k(Ileds604odmOmq9hX5OjbypjT4YkAZNrUcO(buxfOUCzO(J4C0KaSNKwCzfT5Zixbu)aQBKLPwEYEB8vd1Yb1fH6pIZrtcWEsAXLvuKdOUiuhvYDAmnja7jPfxwr7ybaQLfQladgelNfdsqh5k8JZNegBy5lblbgK34R4lUqmiPtJ7mWGFeNJMeG9K0IlROihqDrO(J4CuKf9Oa2lSM3Adnf5aQlc1rLCNgttcWEsAXLv0owaGAzH6cWGbXYzXGe0rUc)48jHXg2WGZxLg3HLZILal)tSeyqEJVIV4cXGKonUZadAHIxJwhgAUZT2lSPpP8gFfFXGbXYzXGnFoTGvSq4LMRXn2WYxawcmiVXxXxCHyqsNg3zGbLbQV8hX5ODu50jHPcliaa1pG6sG6YLH6l)rCoAhvoDsyAZNrUcO(bu)ScOwoOUiudiO2cfVg11JWeeGn0mL34R4luxeQbeu)rCoANNmf5aQlc1IdwP8w01SjOOhPQCR9FvimOw2xOUAmyqSCwm48vPXDym2WYxnwcmiVXxXxCHyqsNg3zGbbeuBHIxJ66ryccWgAMYB8v8fQlc1acQ)iohTZtMICa1fHAXbRuEl6A2eu0JuvU1(Vkegul7luxngmiwolgC(Q04omgBy5RcwcmiVXxXxCHyqsNg3zGbLbQ)iohfGuPYT2Fge05Y0MdIb1Lld1Ya1FeNJcqQu5w7pdc6CzkYbuxeQLbQpAg1(AYL(K66ryEH1jamuxUmuF0mQ91Kl9jf9ivLBT)RcHb1Lld1hnJAFn5sFsRvbjdLpUOowcd1Yb1Yb1Yb1fHAXbRuEl6A2euxpctqa2qZqTSVqDbyWGy5Syqxpctqa2qZydlFjyjWG8gFfFXfIbjDACNbgugO(YFeNJ2rLtNeMkSGaau)aQlbQlxgQV8hX5ODu50jHPnFg5kG6hq9ZkGA5G6Iq9hX5OaKkvU1(ZGGoxM2CqmOUCzOwgO(J4CuasLk3A)zqqNltroG6IqTmq9rZO2xtU0NuxpcZlSobGH6YLH6JMrTVMCPpPOhPQCR9FvimOUCzO(Ozu7Rjx6tATkizO8Xf1XsyOwoOwomyqSCwm48vPXDym2WYJkXsGb5n(k(Ileds604odm4hX5OaKkvU1(ZGGoxM2CqmOUCzOwgO(J4CuasLk3A)zqqNltroG6IqTmq9rZO2xtU0NuxpcZlSobGH6YLH6JMrTVMCPpPOhPQCR9FvimOUCzO(Ozu7Rjx6tATkizO8Xf1XsyOwoOwomyqSCwm48vPXDym2WYdyGLadYB8v8fxigK0PXDgyqzGAab1FeNJ25jtroG6YLH6gztI)yKYn9YUKKgu)aQFwbuxUmu3iltT8K924laQLfQRjxOwoOUiuloyLYBrxZMGwRcsgkFCrDSegQL9fQladgelNfdwRcsgkFCrDSegBy5r1yjWG8gFfFXfIbjDACNbg8J4C0opzkYbuxeQfhSs5TORztqrpsv5w7)QqyqTSVqDbyWGy5Syq0JuvU1(Vkeg2WYJkWsGb5n(k(Ileds604odmOmq9L)iohTJkNojmvybbaO(buxcuxUmuF5pIZr7OYPtctB(mYva1pG6Nva1Yb1fHAab1FeNJ25jtroG6YLH6gztI)yKYn9YUKKgu)aQFwbuxUmu3iltT8K924laQLfQRjxOUiudiO2cfVg11JWeeGn0mL34R4lgmiwolg01JW8cRtaySHL)zfyjWG8gFfFXfIbjDACNbgeqq9hX5ODEYuKdOUCzOUr2K4pgPCtVSljPb1pG6Nva1Lld1nYYulpzVn(cGAzH6AYfdgelNfd66ryEH1jam2WY)8jwcmiVXxXxCHyqsNg3zGb)iohTZtMICGbdILZIbrpsv5w7)Qqyydl)ZcWsGb5n(k(Ileds604odmOmq9L)iohTJkNojmvybbaO(buxcuxUmuF5pIZr7OYPtctB(mYva1pG6Nva1Yb1fHAab1wO41OUEeMGaSHMP8gFfFXGbXYzXGZxLg3HXydl)ZQXsGbdILZIbNVknUdJXG8gFfFXfInSHbfwS3OVyjWY)elbgmiwolgS5ZPfSIfcV0CnUXG8gFfFXfInS8fGLadYB8v8fxigK0PXDgyqYmQ7iDPnFoTGvSq4LMRXnT5Zixbu)4fQlaQbCOUMCH6IqTfkEnADyO5o3AVWM(KYB8v8fdgelNfd66ryEH1jam2WYxnwcmiVXxXxCHyqsNg3zGb)iohTZtMICGbdILZIbrpsv5w7)QqyydlFvWsGb5n(k(Ileds604odmiGG6pIZrD9ujV(deLGPihqDrO2cfVg11tL86pqucMYB8v8fdgelNfdoFvAChgJnS8LGLadYB8v8fxigK0PXDgyWgztI)yKYn9YUKKgu)aQLbQFwcuJcuBHIxJ2iBs8Hz8IewolL34R4lud4qD1qTCyWGy5SyqxpcZlSobGXgwEujwcmiVXxXxCHyqsNg3zGb)iohfGuPYT2Fge05YuKdOUiu3iltT8K924Rcul7luxtUyWGy5Syqxpctqa2qZydlpGbwcmiVXxXxCHyqsNg3zGbBKnj(Jrk30l7ssAqTSqTmqDbLa1Oa1wO41OnYMeFygViHLZs5n(k(c1aouxnulhgmiwolgC(Q04omgBy5r1yjWGbXYzXGUEeMxyDcaJb5n(k(IleBy5rfyjWGbXYzXGONE9JZlnxJBmiVXxXxCHydl)ZkWsGbdILZIbJMel7TPBEnmiVXxXxCHydByW)i8hZOYTglbw(NyjWG8gFfFXfIbjDACNbg8J4C0opzkYbgmiwolge9ivLBT)RcHHnS8fGLadYB8v8fxigK0PXDgyqzG6l)rCoAhvoDsyQWccaq9dOUeOUCzO(YFeNJ2rLtNeM28zKRaQFa1pRaQLdQlc1nYYulpzVn(Qa1pG6AYfQlc1nYMe)XiLB6LDjjnOw2xOUGsG6IqnGGAlu8Auxpctqa2qZuEJVIVyWGy5SyW5RsJ7WySHLVASeyqEJVIV4cXGKonUZad2iltT8K924Rcu)aQRjxOUiu3iBs8hJuUPx2LK0GAzFH6ckbdgelNfdoFvAChgJnS8vblbgK34R4lUqmiPtJ7mWGnYMe)XiLB6LDjjnO(buxqfqDrOMmJ6osx6rQur7hN31JWOnFg5kGAzH6gzzQLNS3gFvG6IqT4GvkVfDnBcATkizO8Xf1XsyOw2xOUamyqSCwmyTkizO8Xf1XsySHLVeSeyqEJVIV4cXGKonUZadkduF5pIZr7OYPtctfwqaaQFa1La1Lld1x(J4C0oQC6KW0MpJCfq9dO(zfqTCqDrOUr2K4pgPCtVSljPb1pG6cQaQlc1Kzu3r6spsLkA)48UEegT5Zixbullu3iltT8K924RcuxeQbeuBHIxJ66ryccWgAMYB8v8fdgelNfd66ryEH1jam2WYJkXsGb5n(k(Ileds604odmyJSjXFms5MEzxssdQFa1fubuxeQjZOUJ0LEKkv0(X5D9imAZNrUcOwwOUrwMA5j7TXxfmyqSCwmORhH5fwNaWydlpGbwcmiVXxXxCHyqsNg3zGb)iohfGuPYT2Fge05YuKdOUiu3iBs8hJuUPx2LK0GAzHAzG6NLa1Oa1wO41OnYMeFygViHLZs5n(k(c1aouxnulhuxeQfhSs5TORztqD9imbbydnd1Y(c1fGbdILZIbD9imbbydnJnS8OASeyqEJVIV4cXGKonUZad2iBs8hJuUPx2LK0GAzFHAzG6QlbQrbQTqXRrBKnj(WmErclNLYB8v8fQbCOUAOwoOUiuloyLYBrxZMG66ryccWgAgQL9fQladgelNfd66ryccWgAgBy5rfyjWG8gFfFXfIbjDACNbgugO(YFeNJ2rLtNeMkSGaau)aQlbQlxgQV8hX5ODu50jHPnFg5kG6hq9ZkGA5G6IqDJSjXFms5MEzxssdQL9fQLbQRUeOgfO2cfVgTr2K4dZ4fjSCwkVXxXxOgWH6QHA5G6IqnGGAlu8Auxpctqa2qZuEJVIVyWGy5SyW5RsJ7WySHL)zfyjWG8gFfFXfIbjDACNbgSr2K4pgPCtVSljPb1Y(c1Ya1vxcuJcuBHIxJ2iBs8Hz8IewolL34R4lud4qD1qTCyWGy5SyW5RsJ7WySHL)5tSeyqEJVIV4cXGKonUZadsMrDhPl9ivQO9JZ76ry0MpJCfqTSqDJSm1Yt2BJVkqDrOUr2K4pgPCtVSljPb1pG6QubuxeQfhSs5TORztqRvbjdLpUOowcd1Y(c1fGbdILZIbRvbjdLpUOowcJnS8plalbgK34R4lUqmiPtJ7mWGYa1x(J4C0oQC6KWuHfeaG6hqDjqD5Yq9L)iohTJkNojmT5Zixbu)aQFwbulhuxeQjZOUJ0LEKkv0(X5D9imAZNrUcOwwOUrwMA5j7TXxfOUiu3iBs8hJuUPx2LK0G6hqDvQaQlc1acQTqXRrD9imbbydnt5n(k(IbdILZIbD9imVW6eagBy5FwnwcmiVXxXxCHyqsNg3zGbjZOUJ0LEKkv0(X5D9imAZNrUcOwwOUrwMA5j7TXxfOUiu3iBs8hJuUPx2LK0G6hqDvQadgelNfd66ryEH1jam2Wgg8OzYC(ddlbw(NyjWG8gFfFXfInS8fGLadYB8v8fxi2WYxnwcmiVXxXxCHydlFvWsGb5n(k(IleBy5lblbgmiwolg8ySCwmiVXxXxCHydByWyySey5FILadYB8v8fxigK0PXDgyqlu8A06WqZDU1EHn9jL34R4luxUmulduhvYDAm11tL86n(8GfgTJfaOUiuloyLYBrxZMG2850cwXcHxAUg3qTSVqD1qDrOgqq9hX5ODEYuKdOwomyqSCwmyZNtlyfleEP5ACJnS8fGLadYB8v8fxigK0PXDgyqlu8Auxpctqa2qZuEJVIVyWGy5SyWAvqYq5JlQJLWydlF1yjWG8gFfFXfIbjDACNbgugO(YFeNJ2rLtNeMkSGaau)aQlbQlxgQV8hX5ODu50jHPnFg5kG6hq9ZkGA5G6Iqnzg1DKU0MpNwWkwi8sZ14M28zKRaQF8c1fa1aouxtUqDrO2cfVgTom0CNBTxytFs5n(k(c1fHAab1wO41OUEeMGaSHMP8gFfFXGbXYzXGUEeMxyDcaJnS8vblbgK34R4lUqmiPtJ7mWGKzu3r6sB(CAbRyHWlnxJBAZNrUcO(Xluxaud4qDn5c1fHAlu8A06WqZDU1EHn9jL34R4lgmiwolg01JW8cRtaySHLVeSeyqEJVIV4cXGKonUZad(rCoANNmf5adgelNfdIEKQYT2)vHWWgwEujwcmiVXxXxCHyqsNg3zGb)iohfGuPYT2Fge05YuKdmyqSCwmORhHjiaBOzSHLhWalbgK34R4lUqmiPtJ7mWGnYMe)XiLB6LDjjnO(buldu)SeOgfO2cfVgTr2K4dZ4fjSCwkVXxXxOgWH6QHA5WGbXYzXG1QGKHYhxuhlHXgwEunwcmiVXxXxCHyqsNg3zGbLbQV8hX5ODu50jHPcliaa1pG6sG6YLH6l)rCoAhvoDsyAZNrUcO(bu)ScOwoOUiu3iBs8hJuUPx2LK0G6hqTmq9ZsGAuGAlu8A0gztIpmJxKWYzP8gFfFHAahQRgQLdQlc1acQTqXRrD9imbbydnt5n(k(IbdILZIbD9imVW6eagBy5rfyjWG8gFfFXfIbjDACNbgSr2K4pgPCtVSljPb1pGAzG6NLa1Oa1wO41OnYMeFygViHLZs5n(k(c1aouxnulhgmiwolg01JW8cRtaySHL)zfyjWGbXYzXGnFoTGvSq4LMRXngK34R4lUqSHL)5tSeyWGy5Syqxpctqa2qZyqEJVIV4cXgw(NfGLadYB8v8fxigK0PXDgyqzG6l)rCoAhvoDsyQWccaq9dOUeOUCzO(YFeNJ2rLtNeM28zKRaQFa1pRaQLdQlc1nYMe)XiLB6LDjjnOwwOwgOUGsGAuGAlu8A0gztIpmJxKWYzP8gFfFHAahQRgQLdQlc1acQTqXRrD9imbbydnt5n(k(IbdILZIbNVknUdJXgw(NvJLadYB8v8fxigK0PXDgyWgztI)yKYn9YUKKgullulduxqjqnkqTfkEnAJSjXhMXlsy5SuEJVIVqnGd1vd1YHbdILZIbNVknUdJXgw(NvblbgmiwolgSwfKmu(4I6yjmgK34R4lUqSHL)zjyjWG8gFfFXfIbjDACNbgugO(YFeNJ2rLtNeMkSGaau)aQlbQlxgQV8hX5ODu50jHPnFg5kG6hq9ZkGA5G6IqnGGAlu8Auxpctqa2qZuEJVIVyWGy5SyqxpcZlSobGXgw(NOsSeyWGy5SyqxpcZlSobGXG8gFfFXfInS8pbmWsGbdILZIbrp96hNxAUg3yqEJVIV4cXgw(NOASeyWGy5SyWOjXYEB6MxddYB8v8fxi2Wgg8pcVLeaYTglbw(NyjWG8gFfFXfIbjDACNbgugO(YFeNJ2rLtNeMkSGaau)aQlbQlxgQV8hX5ODu50jHPnFg5kG6hq9ZkGA5G6IqDJSjXFms5gQF8c1vxbuxeQbeuBHIxJ66ryccWgAMYB8v8fdgelNfdoFvAChgJnS8fGLadYB8v8fxigK0PXDgyWgztI)yKYnu)4fQRUcmyqSCwm48vPXDym2WYxnwcmiVXxXxCHyqsNg3zGbTqXRrRddn35w7f20NuEJVIVyWGy5SyWMpNwWkwi8sZ14gBy5RcwcmiVXxXxCHyqsNg3zGb)iohTZtMICGbdILZIbrpsv5w7)QqyydlFjyjWG8gFfFXfIbjDACNbgugO(YFeNJ2rLtNeMkSGaau)aQlbQlxgQV8hX5ODu50jHPnFg5kG6hq9ZkGA5G6IqDJSm1Yt2BJVeO(buxtUqD5YqDJSjXFms5gQF8c1vPeOUiudiO2cfVg11JWeeGn0mL34R4lgmiwolgC(Q04omgBy5rLyjWG8gFfFXfIbjDACNbgSrwMA5j7TXxcu)aQRjxOUCzOUr2K4pgPCd1pEH6QucgmiwolgC(Q04omgBy5bmWsGb5n(k(Ileds604odm4hX5OaKkvU1(ZGGoxMICa1fHAXbRuEl6A2euxpctqa2qZqTSVqDbyWGy5Syqxpctqa2qZydlpQglbgK34R4lUqmiPtJ7mWGnYMe)XiLB6LDjjnOw2xOU6kG6IqDJSm1Yt2BJVAOwwOUMCXGbXYzXGONE9JZlnxJBSHLhvGLadgelNfd2850cwXcHxAUg3yqEJVIV4cXgw(NvGLadYB8v8fxigK0PXDgyqXbRuEl6A2euxpctqa2qZqTSVqDbyWGy5Syqxpctqa2qZydl)ZNyjWG8gFfFXfIbjDACNbgugO(YFeNJ2rLtNeMkSGaau)aQlbQlxgQV8hX5ODu50jHPnFg5kG6hq9ZkGA5G6IqDJSjXFms5MEzxssdQLfQlOeOUCzOUrwgQLfQRgQlc1acQTqXRrD9imbbydnt5n(k(IbdILZIbNVknUdJXgw(NfGLadYB8v8fxigK0PXDgyWgztI)yKYn9YUKKgulluxqjqD5YqDJSmulluxngmiwolgC(Q04omgBy5FwnwcmiVXxXxCHyqsNg3zGbBKnj(Jrk30l7ssAqTSqDbvGbdILZIbJMel7TPBEnSHnm4LDbIYWsGL)jwcmyqSCwm4zUxVRzUsgdYB8v8fxi2WYxawcmiVXxXxCHyqsNg3zGbbeuFhJ66ryEhJAUPwsai3AOUiuldudiO2cfVg93CyO9JZlY92r9ickVXxXxOUCzOMmJ6osx6V5Wq7hNxK7TJ6re0MpJCfqTSq9ZsGA5WGbXYzXGOhPQCR9FvimSHLVASeyqEJVIV4cXGKonUZad(rCoAsa2BHAwbT5Zixbu)4fQRjxOUiu)rCoAsa2BHAwbf5aQlc1IdwP8w01SjO1QGKHYhxuhlHHAzFH6cG6IqTmqnGGAlu8A0FZHH2poVi3Bh1JiO8gFfFH6YLHAYmQ7iDP)MddTFCErU3oQhrqB(mYva1Yc1plbQLddgelNfdwRcsgkFCrDSegBy5RcwcmiVXxXxCHyqsNg3zGb)iohnja7TqnRG28zKRaQF8c11KluxeQ)iohnja7TqnRGICa1fHAzGAab1wO41O)MddTFCErU3oQhrq5n(k(c1Lld1Kzu3r6s)nhgA)48ICVDupIG28zKRaQLfQFwculhgmiwolg01JW8cRtaySHLVeSeyqEJVIV4cXGbXYzXGKqP8bXYz9Quyyqvkm)gNmgKmJ6osxb2WYJkXsGb5n(k(Ileds604odmOfkEn6V5Wq7hNxK7TJ6reuEJVIVqDrOwgOMmJ6osx6V5Wq7hNxK7TJ6re0MpJCfq9dOUeOUCzOwgOMmJ6osx6V5Wq7hNxK7TJ6re0MpJCfq9dOUGkG6IqTLNS3g)nzO(buxDjqTCqTCyWGy5SyWgz9bXYz9Quyyqvkm)gNmg8pc)XmQCRXgwEadSeyqEJVIV4cXGKonUZad(rCo6V5Wq7hNxK7TJ6reuKdmyqSCwmyJS(Gy5SEvkmmOkfMFJtgd(hH3sca5wJnS8OASeyqEJVIV4cXGKonUZad(rCo6rQur7hN31JWOihqDrO2cfVgD(Q04oSCwkVXxXxmyqSCwmyJS(Gy5SEvkmmOkfMFJtgdoFvAChwol2WYJkWsGb5n(k(Ileds604odmyqSe1SNx(mzbul7luxagmiwolgSrwFqSCwVkfgguLcZVXjJbJHXgw(NvGLadYB8v8fxigmiwolgKekLpiwoRxLcddQsH534KXGcl2B0xSHnmizg1DKUcSey5FILadYB8v8fxigK0PXDgyqzGAYmQ7iDPhPsfTFCExpcJ2CCbgQlxgQjZOUJ0LEKkv0(X5D9imAZNrUcOwwOUGkGA5G6IqTmqnGGAlu8A0FZHH2poVi3Bh1JiO8gFfFH6YLHAYmQ7iDP85XiLBFJSSxkhhZsB(mYva1Yc1OIsGA5WGbXYzXGic2NgFkWgw(cWsGb5n(k(IledgelNfdw3Zwl8hDEgkFh1mgK0PXDgyWgzzO(XluxnuxeQbeu)rCo6rQur7hN31JWOihqDrOwgOgqq9hX5O)MddTFCErU3oQhrqroG6YLHAab1wO41O)MddTFCErU3oQhrq5n(k(c1YHb34KXG19S1c)rNNHY3rnJnS8vJLadYB8v8fxigCJtgd2rLxKfaH)N1(MV(pIzZIbdILZIb7OYlYcGW)ZAFZx)hXSzXgw(QGLadYB8v8fxigmiwolg8KBgadDi8UyRXGKonUZadciO(J4C0FZHH2poVi3Bh1JiOihqDrOgqq9hX5OhPsfTFCExpcJICGb34KXGNCZayOdH3fBn2WYxcwcmiVXxXxCHyqsNg3zGb)ioh9ivQO9JZ76ryuKdOUiu)rCokFEms523il7LYXXSuKdmyqSCwm4Xy5SydlpQelbgK34R4lUqmiPtJ7mWGFeNJEKkv0(X5D9imkYbuxeQ)iohLppgPC7BKL9s54ywkYbgmiwolg8RM56DinWydlpGbwcmiVXxXxCHyqsNg3zGb)ioh9ivQO9JZ76ryuKdmyqSCwm4NBb3aKBn2WYJQXsGb5n(k(Ileds604odmizg1DKUu(8yKYTVrw2lLJJzPnFg5kWGbXYzXGhPsfTFCExpcdBy5rfyjWG8gFfFXfIbjDACNbgKmJ6osxkFEms523il7LYXXS0MpJCfqDrOMmJ6osx6rQur7hN31JWOnFg5kWGbXYzXG)MddTFCErU3oQhrGbreSFCoFn5IbFInS8pRalbgK34R4lUqmiPtJ7mWGKzu3r6spsLkA)48UEegT54cmuxeQbeuBHIxJ(Bom0(X5f5E7OEebL34R4luxeQBKLPwEYEB8La1Yc11KluxeQBKnj(Jrk30l7ssAqTSVq9ZkWGbXYzXG85XiLBFJSSxkhhZInS8pFILadYB8v8fxigK0PXDgyqzGAYmQ7iDPhPsfTFCExpcJ2CCbgQlxgQTORzJA5j7TXFtgQFa1fubulhuxeQTqXRr)nhgA)48ICVDupIGYB8v8fQlc1nYYqTSVqD1qDrOUr2K4pgPCd1Yc1OYkWGbXYzXG85XiLBFJSSxkhhZInS8plalbgK34R4lUqmiPtJ7mWGwO41OKrD9O5OnkVXxXxOUiulduldu)rCokzuxpAoAJkSGaaul7lu)ScOUiuF5pIZr7OYPtctfwqaaQFH6sGA5G6YLHAl6A2OwEYEB83KH6hVqDn5c1YHbdILZIbjHs5dILZ6vPWWGQuy(nozmizuxpAoAdBy5FwnwcmiVXxXxCHyqsNg3zGbLbQ)ioh9ivQO9JZ76ry0MpJCfq9JxOUMCH6YLHAzG6pIZrpsLkA)48UEegT5Zixbu)aQr1qDrO(J4CuKf9Oa2lSM3AdnT5Zixbu)4fQRjxOUiu)rCokYIEua7fwZBTHMICa1Yb1Yb1fH6pIZrpsLkA)48UEegf5adgelNfd66rysbUpfEhsdm2WY)SkyjWG8gFfFXfIbjDACNbg0IUMnQLNS3g)nzO(buxtUqD5YqTmqTfDnBulpzVn(BYq9dOMmJ6osx6rQur7hN31JWOnFg5kG6Iq9hX5Oil6rbSxynV1gAkYbulhgmiwolg01JWKcCFk8oKgySHnSHbrn3ICwS8fuXturffuaQKwq1vGQXGsJEZTwGbRQopM24luJkG6Gy5SqTkfMGcbcdkoycw(ck5jg8OhxQymyvd1vLEegudyLddnudyEZA0geOQgQrB2HavrsjRtdnYNsMtjf5jIkSCwshotsrEsKecuvd1vf(3irdmuxaQSuOUGkEIkGAaBOUGQrvEwceiiqvnudybDS1Savbcuvd1a2qDv1suixgQrvj3luxvAMRKPqGGav1qnGPv1zcIXxO(ZUPzOMmN)WG6pxNRGc1v1ie(Weq9olGn6OpDikOoiwoRaQNvbmfcuqSCwb9OzYC(d71PcbaqGcILZkOhntMZFyO8kPBMleOGy5Sc6rZK58hgkVsgi1N8AHLZcbQQHAWnoeOhdQ7iVq9hX54lulSWeq9NDtZqnzo)Hb1FUoxbuh7fQpAgW(yml3AOofq9DwMcbkiwoRGE0mzo)HHYRKInoeOhZlSWeqGcILZkOhntMZFyO8k5Xy5SqGGav1qnGPv1zcIXxOMrn3ad1wEYqTHMH6Gytd1PaQduhPk(kMcbkiwoR49m3R31mxjdbQQH6QAhhkGH6QspcdQRkmQ5gQJ9c1NrUwKluxvragQLiuZkGafelNvGYRKOhPQCR9FviSst3lGUJrD9imVJrn3uljaKBDrzaKfkEn6V5Wq7hNxK7TJ6reuEJVIVLltMrDhPl93CyO9JZlY92r9icAZNrUczFwICqGcILZkq5vYAvqYq5JlQJLWLMU3pIZrtcWEluZkOnFg5kE8wtUf)iohnja7TqnRGICuuCWkL3IUMnbTwfKmu(4I6yjSSVfuugazHIxJ(Bom0(X5f5E7OEebL34R4B5YKzu3r6s)nhgA)48ICVDupIG28zKRq2NLiheOGy5ScuEL01JW8cRta4st37hX5OjbyVfQzf0MpJCfpERj3IFeNJMeG9wOMvqrokkdGSqXRr)nhgA)48ICVDupIGYB8v8TCzYmQ7iDP)MddTFCErU3oQhrqB(mYvi7ZsKdcuqSCwbkVsscLYhelN1RsHv6gN8lzg1DKUciqbXYzfO8kzJS(Gy5SEvkSs34KF)JWFmJk36st3RfkEn6V5Wq7hNxK7TJ6reuEJVIVfLHmJ6osx6V5Wq7hNxK7TJ6re0MpJCfpkPCzziZOUJ0L(Bom0(X5f5E7OEebT5ZixXJcQOOLNS3g)n5hvxICYbbkiwoRaLxjBK1helN1RsHv6gN87FeEljaKBDPP79J4C0FZHH2poVi3Bh1JiOihqGcILZkq5vYgz9bXYz9QuyLUXj)oFvAChwoBPP79J4C0JuPI2poVRhHrrokAHIxJoFvAChwolL34R4leOGy5ScuELSrwFqSCwVkfwPBCYVXWLMU3GyjQzpV8zYczFlacuqSCwbkVsscLYhelN1RsHv6gN8RWI9g9fceeOGy5ScAm8BZNtlyfleEP5ACxA6ETqXRrRddn35w7f20NuEJVIVLlltuj3PXuxpvYR34Zdwy0owakkoyLYBrxZMG2850cwXcHxAUg3Y(wDra9rCoANNmf5qoiqbXYzf0yyuELSwfKmu(4I6yjCPP71cfVg11JWeeGn0mL34R4leOGy5ScAmmkVs66ryEH1jaCPw01S5t3Rmx(J4C0oQC6KWuHfeaEus5Yx(J4C0oQC6KW0MpJCfpEwHCfjZOUJ0L2850cwXcHxAUg30MpJCfpElaWRj3IwO41O1HHM7CR9cB6tkVXxX3IaYcfVg11JWeeGn0mL34R4leOGy5ScAmmkVs66ryEH1jaCPP7LmJ6osxAZNtlyfleEP5ACtB(mYv84TaaVMClAHIxJwhgAUZT2lSPpP8gFfFHafelNvqJHr5vs0JuvU1(VkewPP79J4C0opzkYbeOGy5ScAmmkVs66ryccWgAU009(rCokaPsLBT)miOZLPihqGcILZkOXWO8kzTkizO8Xf1Xs4st3BJSjXFms5MEzxss7Hmplbflu8A0gztIpmJxKWYzP8gFfFb8QLdcuqSCwbnggLxjD9imVW6eaUul6A28P7vMl)rCoAhvoDsyQWccapkPC5l)rCoAhvoDsyAZNrUIhpRqUInYMe)XiLB6LDjjThY8SeuSqXRrBKnj(WmErclNLYB8v8fWRwUIaYcfVg11JWeeGn0mL34R4leOGy5ScAmmkVs66ryEH1jaCPP7Tr2K4pgPCtVSljP9qMNLGIfkEnAJSjXhMXlsy5SuEJVIVaE1YbbkiwoRGgdJYRKnFoTGvSq4LMRXneOGy5ScAmmkVs66ryccWgAgcuqSCwbnggLxjNVknUdJl1IUMnF6EL5YFeNJ2rLtNeMkSGaWJskx(YFeNJ2rLtNeM28zKR4XZkKRyJSjXFms5MEzxsstwzkOeuSqXRrBKnj(WmErclNLYB8v8fWRwUIaYcfVg11JWeeGn0mL34R4leOGy5ScAmmkVsoFvAChgxA6EBKnj(Jrk30l7ssAYktbLGIfkEnAJSjXhMXlsy5SuEJVIVaE1YbbkiwoRGgdJYRK1QGKHYhxuhlHHafelNvqJHr5vsxpcZlSobGl1IUMnF6EL5YFeNJ2rLtNeMkSGaWJskx(YFeNJ2rLtNeM28zKR4XZkKRiGSqXRrD9imbbydnt5n(k(cbkiwoRGgdJYRKUEeMxyDcadbkiwoRGgdJYRKONE9JZlnxJBiqbXYzf0yyuELmAsSS3MU51GabbQQH6cBom0q94GAWCVDupIaQpMrLBnu3JfwoluJQa1clAta1fuHaQ)SBAgQrvNkv0q94G6QspcdQrbQlCaH6OzOoqDKQ4RyiqbXYzf0)i8hZOYT(f9ivLBT)RcHvA6E)iohTZtMICabkiwoRG(hH)ygvU1O8k58vPXDyCPw01S5t3Rmx(J4C0oQC6KWuHfeaEus5Yx(J4C0oQC6KW0MpJCfpEwHCfBKLPwEYEB8v5rn5wSr2K4pgPCtVSljPj7BbLueqwO41OUEeMGaSHMP8gFfFHafelNvq)JWFmJk3AuELC(Q04omU0092iltT8K924RYJAYTyJSjXFms5MEzxsst23ckbcuqSCwb9pc)XmQCRr5vYAvqYq5JlQJLWLMU3gztI)yKYn9YUKK2JcQOizg1DKU0JuPI2poVRhHrB(mYviBJSm1Yt2BJVkffhSs5TORztqRvbjdLpUOowcl7BbqGcILZkO)r4pMrLBnkVs66ryEH1jaCPw01S5t3Rmx(J4C0oQC6KWuHfeaEus5Yx(J4C0oQC6KW0MpJCfpEwHCfBKnj(Jrk30l7ssApkOIIKzu3r6spsLkA)48UEegT5ZixHSnYYulpzVn(QueqwO41OUEeMGaSHMP8gFfFHafelNvq)JWFmJk3AuEL01JW8cRta4st3BJSjXFms5MEzxss7rbvuKmJ6osx6rQur7hN31JWOnFg5kKTrwMA5j7TXxfiqbXYzf0)i8hZOYTgLxjD9imbbydnxA6E)iohfGuPYT2Fge05YuKJInYMe)XiLB6LDjjnzL5zjOyHIxJ2iBs8Hz8IewolL34R4lGxTCffhSs5TORztqD9imbbydnl7BbqGcILZkO)r4pMrLBnkVs66ryccWgAU0092iBs8hJuUPx2LK0K9vMQlbflu8A0gztIpmJxKWYzP8gFfFb8QLRO4GvkVfDnBcQRhHjiaBOzzFlacuqSCwb9pc)XmQCRr5vY5RsJ7W4sTORzZNUxzU8hX5ODu50jHPclia8OKYLV8hX5ODu50jHPnFg5kE8Sc5k2iBs8hJuUPx2LK0K9vMQlbflu8A0gztIpmJxKWYzP8gFfFb8QLRiGSqXRrD9imbbydnt5n(k(cbkiwoRG(hH)ygvU1O8k58vPXDyCPP7Tr2K4pgPCtVSljPj7RmvxckwO41OnYMeFygViHLZs5n(k(c4vlheOGy5Sc6Fe(Jzu5wJYRK1QGKHYhxuhlHlnDVKzu3r6spsLkA)48UEegT5ZixHSnYYulpzVn(QuSr2K4pgPCtVSljP9OkvuuCWkL3IUMnbTwfKmu(4I6yjSSVfabkiwoRG(hH)ygvU1O8kPRhH5fwNaWLArxZMpDVYC5pIZr7OYPtctfwqa4rjLlF5pIZr7OYPtctB(mYv84zfYvKmJ6osx6rQur7hN31JWOnFg5kKTrwMA5j7TXxLInYMe)XiLB6LDjjThvPIIaYcfVg11JWeeGn0mL34R4leOGy5Sc6Fe(Jzu5wJYRKUEeMxyDcaxA6EjZOUJ0LEKkv0(X5D9imAZNrUczBKLPwEYEB8vPyJSjXFms5MEzxss7rvQaceeOGy5Sc6FeEljaKB978vPXDyCPw01S5t3Rmx(J4C0oQC6KWuHfeaEus5Yx(J4C0oQC6KW0MpJCfpEwHCfBKnj(Jrk3pERUIIaYcfVg11JWeeGn0mL34R4leOGy5Sc6FeEljaKBnkVsoFvAChgxA6EBKnj(Jrk3pERUciqbXYzf0)i8wsai3AuELS5ZPfSIfcV0CnUlnDVwO41O1HHM7CR9cB6tkVXxXxiqbXYzf0)i8wsai3AuELe9ivLBT)RcHvA6E)iohTZtMICabkiwoRG(hH3sca5wJYRKZxLg3HXLArxZMpDVYC5pIZr7OYPtctfwqa4rjLlF5pIZr7OYPtctB(mYv84zfYvSrwMA5j7TXxYJAYTC5gztI)yKY9J3QusrazHIxJ66ryccWgAMYB8v8fcuqSCwb9pcVLeaYTgLxjNVknUdJlnDVnYYulpzVn(sEutULl3iBs8hJuUF8wLsGafelNvq)JWBjbGCRr5vsxpctqa2qZLMU3pIZrbivQCR9NbbDUmf5OO4GvkVfDnBcQRhHjiaBOzzFlacuqSCwb9pcVLeaYTgLxjrp96hNxAUg3LMU3gztI)yKYn9YUKKMSVvxrXgzzQLNS3gF1YwtUqGcILZkO)r4TKaqU1O8kzZNtlyfleEP5ACdbkiwoRG(hH3sca5wJYRKUEeMGaSHMlnDVIdwP8w01SjOUEeMGaSHML9TaiqbXYzf0)i8wsai3AuELC(Q04omUul6A28P7vMl)rCoAhvoDsyQWccapkPC5l)rCoAhvoDsyAZNrUIhpRqUInYMe)XiLB6LDjjnzlOKYLBKLLT6IaYcfVg11JWeeGn0mL34R4leOGy5Sc6FeEljaKBnkVsoFvAChgxA6EBKnj(Jrk30l7ssAYwqjLl3illB1qGcILZkO)r4TKaqU1O8kz0KyzVnDZRvA6EBKnj(Jrk30l7ssAYwqfqGGav1qnGLrDHA0C0gutM9MwoRacuqSCwbLmQRhnhT9sqh5k8JZNeU009(rCokzuxpAoAJkSGaGSLu0IUMnQLNS3g)n5h1KleOGy5SckzuxpAoAdLxjjOJCf(X5tcxA6EL5J4C0JuPI2poVRhHrB(mYv84TMCbCzEIczg1DKUuxpctkW9PW7qAGPnhxGLRC5pIZrpsLkA)48UEegT5ZixXJgzzQLNS3gF1Yv8J4C0JuPI2poVRhHrrokgvYDAmnja7jPfxwr7yb4XBbqGcILZkOKrD9O5OnuELKGoYv4hNpjCPP79J4C0JuPI2poVRhHrB(mYv8avx8J4CuKf9Oa2lSM3AdnT5ZixXJAYfWL5jkKzu3r6sD9imPa3NcVdPbM2CCbwUIFeNJISOhfWEH18wBOPnFg5kk(rCo6rQur7hN31JWOihfJk5onMMeG9K0IlRODSa84TaiqbXYzfuYOUE0C0gkVssqh5k8JZNeU009kZhX5OjbypjT4YkAZNrUIhvPC5pIZrtcWEsAXLv0MpJCfpAKLPwEYEB8vlxXpIZrtcWEsAXLvuKJIrLCNgttcWEsAXLv0owaKTaiqbXYzfuYOUE0C0gkVssqh5k8JZNeU009(rCoAsa2tslUSIICu8J4CuKf9Oa2lSM3Adnf5Oyuj3PX0KaSNKwCzfTJfazlaceeOGy5Sckzg1DKUIxeb7tJpfLMUxziZOUJ0LEKkv0(X5D9imAZXf4YLjZOUJ0LEKkv0(X5D9imAZNrUczlOc5kkdGSqXRr)nhgA)48ICVDupIGYB8v8TCzYmQ7iDP85XiLBFJSSxkhhZsB(mYvilQOe5GafelNvqjZOUJ0vGYRKic2NgFw6gN8BDpBTWF05zO8DuZLMU3gz5hVvxeqFeNJEKkv0(X5D9imkYrrza0hX5O)MddTFCErU3oQhrqrokxgqwO41O)MddTFCErU3oQhrq5n(k(kheOGy5Sckzg1DKUcuELerW(04Zs34KF7OYlYcGW)ZAFZx)hXSzHafelNvqjZOUJ0vGYRKic2NgFw6gN87j3mag6q4DXwxA6Eb0hX5O)MddTFCErU3oQhrqrokcOpIZrpsLkA)48UEegf5acuqSCwbLmJ6osxbkVsEmwoBPP79J4C0JuPI2poVRhHrrok(rCokFEms523il7LYXXSuKdiqbXYzfuYmQ7iDfO8k5xnZ17qAGlnDVFeNJEKkv0(X5D9imkYrXpIZr5ZJrk3(gzzVuooMLICabkiwoRGsMrDhPRaLxj)Cl4gGCRlnDVFeNJEKkv0(X5D9imkYbeOQgQRk9imOMmJ6osxbeOGy5Sckzg1DKUcuEL8ivQO9JZ76ryLMUxYmQ7iDP85XiLBFJSSxkhhZsB(mYvabkiwoRGsMrDhPRaLxj)nhgA)48ICVDupIOueb7hNZxtUVplnDVKzu3r6s5ZJrk3(gzzVuooML28zKROizg1DKU0JuPI2poVRhHrB(mYvabkiwoRGsMrDhPRaLxj5ZJrk3(gzzVuooMT009sMrDhPl9ivQO9JZ76ry0MJlWfbKfkEn6V5Wq7hNxK7TJ6reuEJVIVfBKLPwEYEB8LiBn5wSr2K4pgPCtVSljPj77ZkGafelNvqjZOUJ0vGYRK85XiLBFJSSxkhhZwA6ELHmJ6osx6rQur7hN31JWOnhxGlx2IUMnQLNS3g)n5hfuHCfTqXRr)nhgA)48ICVDupIGYB8v8TyJSSSVvxSr2K4pgPCllQSciqbXYzfuYmQ7iDfO8kjjukFqSCwVkfwPBCYVKrD9O5OTst3RfkEnkzuxpAoAJYB8v8TOmY8rCokzuxpAoAJkSGaGSVpRO4L)iohTJkNojmvybbG3sKRCzl6A2OwEYEB83KF8wtUYbbkiwoRGsMrDhPRaLxjD9imPa3NcVdPbU009kZhX5OhPsfTFCExpcJ28zKR4XBn5wUSmFeNJEKkv0(X5D9imAZNrUIhO6IFeNJISOhfWEH18wBOPnFg5kE8wtUf)iohfzrpkG9cR5T2qtroKtUIFeNJEKkv0(X5D9imkYbeOGy5Sckzg1DKUcuEL01JWKcCFk8oKg4st3RfDnBulpzVn(BYpQj3YLLXIUMnQLNS3g)n5hKzu3r6spsLkA)48UEegT5ZixrXpIZrrw0JcyVWAERn0uKd5GabbQQHAuv)Q04oSCwOUhlSCwiqbXYzf05RsJ7WYzFB(CAbRyHWlnxJ7st3RfkEnADyO5o3AVWM(KYB8v8fcuqSCwbD(Q04oSCwuELC(Q04omUul6A28P7vMl)rCoAhvoDsyQWccapkPC5l)rCoAhvoDsyAZNrUIhpRqUIaYcfVg11JWeeGn0mL34R4Bra9rCoANNmf5OO4GvkVfDnBck6rQk3A)xfct23QHafelNvqNVknUdlNfLxjNVknUdJlnDVaYcfVg11JWeeGn0mL34R4Bra9rCoANNmf5OO4GvkVfDnBck6rQk3A)xfct23QHafelNvqNVknUdlNfLxjD9imbbydnxA6EL5J4CuasLk3A)zqqNltBoiw5YY8rCokaPsLBT)miOZLPihfL5Ozu7Rjx6tQRhH5fwNaWLlF0mQ91Kl9jf9ivLBT)RcHvU8rZO2xtU0N0AvqYq5JlQJLWYjNCffhSs5TORztqD9imbbydnl7BbqGcILZkOZxLg3HLZIYRKZxLg3HXLArxZMpDVYC5pIZr7OYPtctfwqa4rjLlF5pIZr7OYPtctB(mYv84zfYv8J4CuasLk3A)zqqNltBoiw5YY8rCokaPsLBT)miOZLPihfL5Ozu7Rjx6tQRhH5fwNaWLlF0mQ91Kl9jf9ivLBT)RcHvU8rZO2xtU0N0AvqYq5JlQJLWYjheOGy5Sc68vPXDy5SO8k58vPXDyCPP79J4CuasLk3A)zqqNltBoiw5YY8rCokaPsLBT)miOZLPihfL5Ozu7Rjx6tQRhH5fwNaWLlF0mQ91Kl9jf9ivLBT)RcHvU8rZO2xtU0N0AvqYq5JlQJLWYjheOGy5Sc68vPXDy5SO8kzTkizO8Xf1Xs4st3Rma6J4C0opzkYr5YnYMe)XiLB6LDjjThpROC5gzzQLNS3gFbYwtUYvuCWkL3IUMnbTwfKmu(4I6yjSSVfabkiwoRGoFvAChwolkVsIEKQYT2)vHWknDVFeNJ25jtrokkoyLYBrxZMGIEKQYT2)vHWK9TaiqbXYzf05RsJ7WYzr5vsxpcZlSobGl1IUMnF6EL5YFeNJ2rLtNeMkSGaWJskx(YFeNJ2rLtNeM28zKR4XZkKRiG(iohTZtMICuUCJSjXFms5MEzxss7XZkkxUrwMA5j7TXxGS1KBrazHIxJ66ryccWgAMYB8v8fcuqSCwbD(Q04oSCwuEL01JW8cRta4st3lG(iohTZtMICuUCJSjXFms5MEzxss7XZkkxUrwMA5j7TXxGS1KleOGy5Sc68vPXDy5SO8kj6rQk3A)xfcR009(rCoANNmf5acuqSCwbD(Q04oSCwuELC(Q04omUul6A28P7vMl)rCoAhvoDsyQWccapkPC5l)rCoAhvoDsyAZNrUIhpRqUIaYcfVg11JWeeGn0mL34R4leOGy5Sc68vPXDy5SO8k58vPXDymeiiqvnudAXEJ(c1ICRvmGTfDnBqDpwy5SqGcILZkOcl2B033MpNwWkwi8sZ14gcuqSCwbvyXEJ(IYRKUEeMxyDcaxA6EjZOUJ0L2850cwXcHxAUg30MpJCfpElaWRj3IwO41O1HHM7CR9cB6tkVXxXxiqbXYzfuHf7n6lkVsIEKQYT2)vHWknDVFeNJ25jtroGafelNvqfwS3OVO8k58vPXDyCPP7fqFeNJ66PsE9hikbtrokAHIxJ66PsE9hikbt5n(k(cbkiwoRGkSyVrFr5vsxpcZlSobGlnDVnYMe)XiLB6LDjjThY8SeuSqXRrBKnj(WmErclNLYB8v8fWRwoiqbXYzfuHf7n6lkVs66ryccWgAU009(rCokaPsLBT)miOZLPihfBKLPwEYEB8vr23AYfcuqSCwbvyXEJ(IYRKZxLg3HXLMU3gztI)yKYn9YUKKMSYuqjOyHIxJ2iBs8Hz8IewolL34R4lGxTCqGcILZkOcl2B0xuEL01JW8cRtayiqbXYzfuHf7n6lkVsIE61poV0CnUHafelNvqfwS3OVO8kz0KyzVnDZRHnSHXa]] )


end
