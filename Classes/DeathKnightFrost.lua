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


    spec:RegisterPack( "Frost DK", 20190422.1018, [[dyupHbqivj9ivaTjjQrrs1PiPSkOk8ka1SKqDlvGQDr4xKqdtf0XufTmjKNPkX0uHY1KG2Mkq8nvG04GQiNtfQADQqLMNQW9ayFsGdQcqwijXdvHkmrOkkUOkqXgvbWjvbkTsa5Lqvu5MqvuYojj9tOkk1qvHkAPqvu1tbAQqv9vvak7fYFPYGj1HfwSQ6XiMSkDzuBMQ(SKmAs0Pf9AvPMnr3wfTBL(TIHlPwUuphPPt56qz7qv67qLXRcq15jbRxfY8Li7h0ONi8rG3WyKQfD4ZJ)WJvurINh(epv0bfbAkuZiW6G8oQye4gNmc8a0d1GA8m45qG1HcYjUi8rG0bRjmcuPz10JRIkwLMsSVGmNksZtmzy5SKo8MI08KOic8JLs7GDrFe4nmgPArh(84p8yfvK45HpXth(ccmWmLtJabZZJdeOY8E5f9rGxMsqGhiuFa6HAqnEgomLqnEUnRuAqGoqOwPz10JRIkwLMsSVGmNksZtmzy5SKo8MI08KOieOdeQpGQ7uc1fvuXqDrh(84H6dou)8WJ7ZdkeiiqhiuFCOm2kMECHaDGq9bhQpyxIe7YqnEw5EH6dqZ8rSac0bc1hCO(a6EHAFiL)G8gQ9td1y0CRG6dg88hWkgQpoNdauNEOUwgkWnuNBAzymfQvzaH6p7NMH66zK5wb1YPkjqDsHAYCwlzJVceOmPgfHpcKmYRtjhTHWhP6te(iqEJVKVivqGKonUZab(X8EbzKxNsoAtqTG8gQlaQleQld1w0vSjS8KD24Ujd1pG6kYfbgelNfbsug5sDJ3LegzivlcHpcK34l5lsfeiPtJ7mqGQd1FmVxuNsz0UX789qnrZNrUuO(baOUICHA8aQvhQFc1ad1KzK3b3k89qnCk0NuNhRvq0CCvaQvdQlvcQ)yEVOoLYODJ357HAIMpJCPq9dOUXwwy5j7SX9cuRguxgQ)yEVOoLYODJ357HAcSAeyqSCweirzKl1nExsyKHu9fe(iqEJVKVivqGKonUZab(X8ErDkLr7gVZ3d1enFg5sH6hqnEcQld1FmVxGTkhPcoQ18wzkfnFg5sH6hqDf5c14buRou)eQbgQjZiVdUv47HA4uOpPopwRGO54QauRguxgQ)yEVaBvosfCuR5TYukA(mYLc1LH6pM3lQtPmA34D(EOMaRgbgelNfbsug5sDJ3LegzidboFzAChwolcFKQpr4Ja5n(s(Iubbs604odeOfsEnrvyk5o3kh1M(uWB8L8fbgelNfb2850uwYuQdxUg3idPAri8rG8gFjFrQGajDACNbcuDO(YFmVx0XrtNewqTG8gQFa1fc1Lkb1x(J59IooA6KWIMpJCPq9dO(5HqTAqDzO(vO2cjVMW3d1OefmLSG34l5luxgQFfQ)yEVOZtwGvd1LHAAnlLol6k2OcLdozUvUVmOguxaaO(feyqSCwe48LPXDymYqQ(ccFeiVXxYxKkiqsNg3zGaFfQTqYRj89qnkrbtjl4n(s(c1LH6xH6pM3l68Kfy1qDzOMwZsPZIUInQq5GtMBL7ldQb1faaQFbbgelNfboFzAChgJmKQhdHpcK34l5lsfeiPtJ7mqGQd1FmVx8oLYCRCNbrzUSO5GyqDPsqT6q9hZ7fVtPm3k3zquMllWQH6YqT6qDDZ41vrUINcFpuZrToFZqDPsqDDZ41vrUINcLdozUvUVmOguxQeux3mEDvKR4POsgKmKU4I3yjmuRguRguRguxgQP1Su6SORyJk89qnkrbtjd1faaQlcbgelNfb67HAuIcMsgzivleHpcK34l5lsfeiPtJ7mqGQd1x(J59IooA6KWcQfK3q9dOUqOUujO(YFmVx0XrtNew08zKlfQFa1ppeQvdQld1FmVx8oLYCRCNbrzUSO5GyqDPsqT6q9hZ7fVtPm3k3zquMllWQH6YqT6qDDZ41vrUINcFpuZrToFZqDPsqDDZ41vrUINcLdozUvUVmOguxQeux3mEDvKR4POsgKmKU4I3yjmuRguRgcmiwolcC(Y04omgzivpii8rG8gFjFrQGajDACNbc8J59I3PuMBL7mikZLfnhedQlvcQvhQ)yEV4DkL5w5odIYCzbwnuxgQvhQRBgVUkYv8u47HAoQ15BgQlvcQRBgVUkYv8uOCWjZTY9Lb1G6sLG66MXRRICfpfvYGKH0fx8glHHA1GA1qGbXYzrGZxMg3HXidP6bfHpcK34l5lsfeiPtJ7mqGQd1Vc1FmVx05jlWQH6sLG6gBtIREWXT4Y(KKgu)aQFEiuxQeu3yllS8KD24kcQlaQRixOwnOUmutRzP0zrxXgvujdsgsxCXBSegQlaauxecmiwolcSsgKmKU4I3yjmYqQINq4Ja5n(s(Iubbs604ode4hZ7fDEYcSAOUmutRzP0zrxXgvOCWjZTY9Lb1G6caa1fHadILZIavo4K5w5(YGAidP6XJWhbYB8L8fPccK0PXDgiq1H6l)X8ErhhnDsyb1cYBO(buxiuxQeuF5pM3l64OPtclA(mYLc1pG6Nhc1Qb1LH6xH6pM3l68Kfy1qDPsqDJTjXvp44wCzFssdQFa1ppeQlvcQBSLfwEYoBCfb1fa1vKluxgQFfQTqYRj89qnkrbtjl4n(s(IadILZIa99qnh168nJmKQppeHpcK34l5lsfeiPtJ7mqGVc1FmVx05jlWQH6sLG6gBtIREWXT4Y(KKgu)aQFEiuxQeu3yllS8KD24kcQlaQRixeyqSCweOVhQ5OwNVzKHu95te(iqEJVKVivqGKonUZab(X8ErNNSaRgbgelNfbQCWjZTY9Lb1qgs1NfHWhbYB8L8fPccK0PXDgiq1H6l)X8ErhhnDsyb1cYBO(buxiuxQeuF5pM3l64OPtclA(mYLc1pG6Nhc1Qb1LH6xHAlK8AcFpuJsuWuYcEJVKViWGy5SiW5ltJ7WyKHu95li8rGbXYzrGZxMg3HXiqEJVKVivqgYqG)H6SK8o3ke(ivFIWhbYB8L8fPccK0PXDgiqYmY7GBf8z9GJBxJTSdhh1ZkA(mYLIadILZIaRtPmA34D(EOgYqQwecFeyqSCweiFwp4421yl7WXr9SiqEJVKVivqgs1xq4Ja5n(s(Iubbs604odeO6q9L)yEVOJJMojSGAb5nu)aQleQlvcQV8hZ7fDC00jHfnFg5sH6hq9ZdHA1G6YqDJTjXvp44gQFaaQF5qOUmu)kuBHKxt47HAuIcMswWB8L8fbgelNfboFzAChgJmKQhdHpcK34l5lsfeiPtJ7mqGn2Mex9GJBO(baO(LdrGbXYzrGZxMg3HXidPAHi8rG8gFjFrQGajDACNbc0cjVMOkmLCNBLJAtFk4n(s(IadILZIaB(CAklzk1HlxJBKHu9GGWhbYB8L8fPccK0PXDgiWpM3l68Kfy1iWGy5SiqLdozUvUVmOgYqQEqr4Ja5n(s(Iubbs604odeO6q9L)yEVOJJMojSGAb5nu)aQleQlvcQV8hZ7fDC00jHfnFg5sH6hq9ZdHA1G6YqDJTSWYt2zJRqO(buxrUqDPsqDJTjXvp44gQFaaQpwHqDzO(vO2cjVMW3d1OefmLSG34l5lcmiwolcC(Y04omgzivXti8rG8gFjFrQGajDACNbcSXwwy5j7SXviu)aQRixOUujOUX2K4QhCCd1paa1hRqeyqSCwe48LPXDymYqQE8i8rG8gFjFrQGajDACNbc8J59I3PuMBL7mikZLfy1qDzOMwZsPZIUInQW3d1OefmLmuxaaOUieyqSCweOVhQrjkykzKHu95Hi8rG8gFjFrQGajDACNbcSX2K4QhCClUSpjPb1faaQF5qOUmu3yllS8KD24EbQlaQRixeyqSCweOYPx34D4Y14gzivF(eHpcmiwolcS5ZPPSKPuhUCnUrG8gFjFrQGmKQplcHpcK34l5lsfeiPtJ7mqG0AwkDw0vSrf(EOgLOGPKH6caa1fHadILZIa99qnkrbtjJmKQpFbHpcK34l5lsfeiPtJ7mqGQd1x(J59IooA6KWcQfK3q9dOUqOUujO(YFmVx0XrtNew08zKlfQFa1ppeQvdQld1n2Mex9GJBXL9jjnOUaOUOcH6sLG6gBzOUaO(fOUmu)kuBHKxt47HAuIcMswWB8L8fbgelNfboFzAChgJmKQppgcFeiVXxYxKkiqsNg3zGaBSnjU6bh3Il7tsAqDbqDrfc1Lkb1n2YqDbq9liWGy5SiW5ltJ7WyKHu9zHi8rG8gFjFrQGajDACNbcSX2K4QhCClUSpjPb1fa1fDicmiwolcmAsSSZMU51qgYqG)H6QNrMBfcFKQpr4Ja5n(s(Iubbs604ode4hZ7fDEYcSAeyqSCweOYbNm3k3xgudzivlcHpcK34l5lsfeiPtJ7mqGQd1x(J59IooA6KWcQfK3q9dOUqOUujO(YFmVx0XrtNew08zKlfQFa1ppeQvdQld1n2YclpzNnUJb1pG6kYfQld1n2Mex9GJBXL9jjnOUaaqDrfc1LH6xHAlK8AcFpuJsuWuYcEJVKViWGy5SiW5ltJ7WyKHu9fe(iqEJVKVivqGKonUZab2yllS8KD24ogu)aQRixOUmu3yBsC1doUfx2NK0G6caa1fvicmiwolcC(Y04omgzivpgcFeiVXxYxKkiqsNg3zGaBSnjU6bh3Il7tsAq9dOUOdH6Yqnzg5DWTI6ukJ2nENVhQjA(mYLc1fa1n2YclpzNnUJb1LHAAnlLol6k2OIkzqYq6IlEJLWqDbaG6IqGbXYzrGvYGKH0fx8glHrgs1cr4Ja5n(s(Iubbs604odeO6q9L)yEVOJJMojSGAb5nu)aQleQlvcQV8hZ7fDC00jHfnFg5sH6hq9ZdHA1G6YqDJTjXvp44wCzFssdQFa1fDiuxgQjZiVdUvuNsz0UX789qnrZNrUuOUaOUXwwy5j7SXDmOUmu)kuBHKxt47HAuIcMswWB8L8fbgelNfb67HAoQ15Bgzivpii8rG8gFjFrQGajDACNbcSX2K4QhCClUSpjPb1pG6IoeQld1KzK3b3kQtPmA34D(EOMO5Zixkuxau3yllS8KD24ogcmiwolc03d1CuRZ3mYqQEqr4Ja5n(s(Iubbs604ode4hZ7fVtPm3k3zquMllWQH6YqDJTjXvp44wCzFssdQlaQvhQFwiudmuBHKxt0yBsCHz8IfwoRG34l5luJhq9lqTAqDzOMwZsPZIUInQW3d1OefmLmuxaaOUieyqSCweOVhQrjkykzKHufpHWhbYB8L8fPccK0PXDgiWgBtIREWXT4Y(KKguxaaOwDO(LcHAGHAlK8AIgBtIlmJxSWYzf8gFjFHA8aQFbQvdQld10AwkDw0vSrf(EOgLOGPKH6caa1fHadILZIa99qnkrbtjJmKQhpcFeiVXxYxKkiqsNg3zGavhQV8hZ7fDC00jHfuliVH6hqDHqDPsq9L)yEVOJJMojSO5Zixku)aQFEiuRguxgQBSnjU6bh3Il7tsAqDbaGA1H6xkeQbgQTqYRjASnjUWmEXclNvWB8L8fQXdO(fOwnOUmu)kuBHKxt47HAuIcMswWB8L8fbgelNfboFzAChgJmKQppeHpcK34l5lsfeiPtJ7mqGn2Mex9GJBXL9jjnOUaaqT6q9lfc1ad1wi51en2MexygVyHLZk4n(s(c14bu)cuRgcmiwolcC(Y04omgzivF(eHpcK34l5lsfeiPtJ7mqGKzK3b3kQtPmA34D(EOMO5Zixkuxau3yllS8KD24oguxgQBSnjU6bh3Il7tsAq9dO(yhc1LHAAnlLol6k2OIkzqYq6IlEJLWqDbaG6IqGbXYzrGvYGKH0fx8glHrgs1NfHWhbYB8L8fPccK0PXDgiq1H6l)X8ErhhnDsyb1cYBO(buxiuxQeuF5pM3l64OPtclA(mYLc1pG6Nhc1Qb1LHAYmY7GBf1PugTB8oFput08zKlfQlaQBSLfwEYoBChdQld1n2Mex9GJBXL9jjnO(buFSdH6Yq9RqTfsEnHVhQrjkykzbVXxYxeyqSCweOVhQ5OwNVzKHu95li8rG8gFjFrQGajDACNbcKmJ8o4wrDkLr7gVZ3d1enFg5sH6cG6gBzHLNSZg3XG6YqDJTjXvp44wCzFssdQFa1h7qeyqSCweOVhQ5OwNVzKHmeyDZK58hgcFKQpr4Ja5n(s(IubzivlcHpcK34l5lsfKHu9fe(iqEJVKVivqgs1JHWhbYB8L8fPcYqQwicFeyqSCwey9y5SiqEJVKVivqgYqGXWi8rQ(eHpcK34l5lsfeiPtJ7mqGwi51evHPK7CRCuB6tbVXxYxOUujOwDOooI70yHVNJ41z8zntnrh7BOUmutRzP0zrxXgv0850uwYuQdxUg3qDbaG6xG6Yq9Rq9hZ7fDEYcSAOwneyqSCweyZNttzjtPoC5ACJmKQfHWhbYB8L8fPccK0PXDgiqlK8AcFpuJsuWuYcEJVKViWGy5SiWkzqYq6IlEJLWidP6li8rG8gFjFrQGajDACNbcuDO(YFmVx0XrtNewqTG8gQFa1fc1Lkb1x(J59IooA6KWIMpJCPq9dO(5HqTAqDzOMmJ8o4wrZNttzjtPoC5AClA(mYLc1paa1fb14buxrUqDzO2cjVMOkmLCNBLJAtFk4n(s(c1LH6xHAlK8AcFpuJsuWuYcEJVKViWGy5SiqFpuZrToFZidP6Xq4Ja5n(s(Iubbs604odeizg5DWTIMpNMYsMsD4Y14w08zKlfQFaaQlcQXdOUICH6YqTfsEnrvyk5o3kh1M(uWB8L8fbgelNfb67HAoQ15BgzivleHpcK34l5lsfeiPtJ7mqGFmVx05jlWQrGbXYzrGkhCYCRCFzqnKHu9GGWhbYB8L8fPccK0PXDgiWpM3lENszUvUZGOmxwGvJadILZIa99qnkrbtjJmKQhue(iqEJVKVivqGKonUZab2yBsC1doUfx2NK0G6hqT6q9ZcHAGHAlK8AIgBtIlmJxSWYzf8gFjFHA8aQFbQvdbgelNfbwjdsgsxCXBSegzivXti8rG8gFjFrQGajDACNbcuDO(YFmVx0XrtNewqTG8gQFa1fc1Lkb1x(J59IooA6KWIMpJCPq9dO(5HqTAqDzOUX2K4QhCClUSpjPb1pGA1H6Nfc1ad1wi51en2MexygVyHLZk4n(s(c14bu)cuRguxgQFfQTqYRj89qnkrbtjl4n(s(IadILZIa99qnh168nJmKQhpcFeiVXxYxKkiqsNg3zGaBSnjU6bh3Il7tsAq9dOwDO(zHqnWqTfsEnrJTjXfMXlwy5ScEJVKVqnEa1Va1QHadILZIa99qnh168nJmKQppeHpcmiwolcS5ZPPSKPuhUCnUrG8gFjFrQGmKQpFIWhbgelNfb67HAuIcMsgbYB8L8fPcYqQ(Sie(iqEJVKVivqGKonUZabQouF5pM3l64OPtclOwqEd1pG6cH6sLG6l)X8ErhhnDsyrZNrUuO(bu)8qOwnOUmu3yBsC1doUfx2NK0G6cGA1H6IkeQbgQTqYRjASnjUWmEXclNvWB8L8fQXdO(fOwnOUmu)kuBHKxt47HAuIcMswWB8L8fbgelNfboFzAChgJmKQpFbHpcK34l5lsfeiPtJ7mqGn2Mex9GJBXL9jjnOUaOwDOUOcHAGHAlK8AIgBtIlmJxSWYzf8gFjFHA8aQFbQvdbgelNfboFzAChgJmKQppgcFeyqSCweyLmiziDXfVXsyeiVXxYxKkidP6Zcr4Ja5n(s(Iubbs604odeO6q9L)yEVOJJMojSGAb5nu)aQleQlvcQV8hZ7fDC00jHfnFg5sH6hq9ZdHA1G6Yq9RqTfsEnHVhQrjkykzbVXxYxeyqSCweOVhQ5OwNVzKHu95bbHpcmiwolc03d1CuRZ3mcK34l5lsfKHu95bfHpcmiwolcu50RB8oC5ACJa5n(s(IubzivFINq4JadILZIaJMel7SPBEneiVXxYxKkidziqQf7n6lcFKQpr4JadILZIaB(CAklzk1HlxJBeiVXxYxKkidPAri8rG8gFjFrQGajDACNbcKmJ8o4wrZNttzjtPoC5AClA(mYLc1paa1fb14buxrUqDzO2cjVMOkmLCNBLJAtFk4n(s(IadILZIa99qnh168nJmKQVGWhbYB8L8fPccK0PXDgiWpM3l68Kfy1iWGy5SiqLdozUvUVmOgYqQEme(iqEJVKVivqGKonUZab(ku)X8EHVNJ41vJjPSaRgQld1wi51e(EoIxxnMKYcEJVKViWGy5SiW5ltJ7WyKHuTqe(iqEJVKVivqGKonUZab2yBsC1doUfx2NK0G6hqT6q9ZcHAGHAlK8AIgBtIlmJxSWYzf8gFjFHA8aQFbQvdbgelNfb67HAoQ15Bgzivpii8rG8gFjFrQGajDACNbc8J59I3PuMBL7mikZLfy1qDzOUXwwy5j7SXDmOUaaqDf5IadILZIa99qnkrbtjJmKQhue(iqEJVKVivqGKonUZab2yBsC1doUfx2NK0G6cGA1H6IkeQbgQTqYRjASnjUWmEXclNvWB8L8fQXdO(fOwneyqSCwe48LPXDymYqQINq4JadILZIa99qnh168nJa5n(s(IubzivpEe(iWGy5SiqLtVUX7WLRXncK34l5lsfKHu95Hi8rGbXYzrGrtILD20nVgcK34l5lsfKHme4L9bM0q4Ju9jcFeyqSCwe4zUxNVz(igbYB8L8fPcYqQwecFeiVXxYxKkiqsNg3zGaFfQVJj89qnNNXl3cljVZTcQld1Qd1Vc1wi51e)MdtPB8oAU3oQgAi4n(s(c1Lkb1KzK3b3k(nhMs34D0CVDun0q08zKlfQlaQFwiuRgcmiwolcu5GtMBL7ldQHmKQVGWhbYB8L8fPccK0PXDgiWpM3lsIcolKZsfnFg5sH6haG6kYfQld1FmVxKefCwiNLkWQH6YqnTMLsNfDfBurLmiziDXfVXsyOUaaqDrqDzOwDO(vO2cjVM43CykDJ3rZ92r1qdbVXxYxOUujOMmJ8o4wXV5Wu6gVJM7TJQHgIMpJCPqDbq9ZcHA1qGbXYzrGvYGKH0fx8glHrgs1JHWhbYB8L8fPccK0PXDgiWpM3lsIcolKZsfnFg5sH6haG6kYfQld1FmVxKefCwiNLkWQH6YqT6q9RqTfsEnXV5Wu6gVJM7TJQHgcEJVKVqDPsqnzg5DWTIFZHP0nEhn3BhvdnenFg5sH6cG6Nfc1QHadILZIa99qnh168nJmKQfIWhbYB8L8fPccmiwolcKesPliwoRtMudbktQ524KrGKzK3b3srgs1dccFeiVXxYxKkiqsNg3zGaTqYRj(nhMs34D0CVDun0qWB8L8fQld1Qd1KzK3b3k(nhMs34D0CVDun0q08zKlfQFa1fc1Lkb1Qd1KzK3b3k(nhMs34D0CVDun0q08zKlfQFa1fDiuxgQTORyty5j7SXDtgQFa1VuiuRguRgcmiwolcSXwxqSCwNmPgcuMuZTXjJa)d1vpJm3kKHu9GIWhbYB8L8fPccK0PXDgiW7yIFZHP0nEhn3BhvdnewsENBfcmiwolcSXwxqSCwNmPgcuMuZTXjJa)d1zj5DUvidPkEcHpcK34l5lsfeiPtJ7mqGFmVxuNsz0UX789qnbwnuxgQTqYRjMVmnUdlNvWB8L8fbgelNfb2yRliwoRtMudbktQ524KrGZxMg3HLZImKQhpcFeiVXxYxKkiqsNg3zGadIL4LD8YNjtH6caa1fHadILZIaBS1felN1jtQHaLj1CBCYiWyyKHu95Hi8rG8gFjFrQGadILZIajHu6cILZ6Kj1qGYKAUnozei1I9g9fzidbsMrEhClfHps1Ni8rG8gFjFrQGajDACNbcuDOMmJ8o4wrDkLr7gVZ3d1enhxfG6sLGAYmY7GBf1PugTB8oFput08zKlfQlaQl6qOwnOUmuRou)kuBHKxt8BomLUX7O5E7OAOHG34l5luxQeutMrEhCRGpRhCC7ASLD44OEwrZNrUuOUaO(4leQvdbgelNfbIrzxA8jfzivlcHpcK34l5lsfeyqSCweyvpBf1v35ziDDuXiqsNg3zGaBSLH6haG6xG6Yq9Rq9hZ7f1PugTB8oFputGvd1LHA1H6xH67yIFZHP0nEhn3BhvdnewsENBfuxQeu)kuBHKxt8BomLUX7O5E7OAOHG34l5luRgcCJtgbw1ZwrD1DEgsxhvmYqQ(ccFeiVXxYxKkiWnozeyhhDX23u3pRCnFDFmZMfbgelNfb2XrxS9n19ZkxZx3hZSzrgs1JHWhbYB8L8fPccmiwolc8KB(TPmOoFSviqsNg3zGaFfQVJj(nhMs34D0CVDun0qyj5DUvqDzO(vO(J59I6ukJ2nENVhQjWQrGBCYiWtU53MYG68XwHmKQfIWhbYB8L8fPccK0PXDgiWpM3lQtPmA34D(EOMaRgQld1FmVxWN1doUDn2YoCCupRaRgbgelNfbwpwolYqQEqq4Ja5n(s(Iubbs604ode4hZ7f1PugTB8oFputGvd1LH6pM3l4Z6bh3UgBzhooQNvGvJadILZIa)YzUopwRaYqQEqr4Ja5n(s(Iubbs604ode4hZ7f1PugTB8oFputGvJadILZIa)Ct5(DUvidPkEcHpcK34l5lsfeiPtJ7mqGKzK3b3k4Z6bh3UgBzhooQNv08zKlfbgelNfbwNsz0UX789qnKHu94r4Ja5n(s(Iubbs604odeizg5DWTc(SEWXTRXw2HJJ6zfnFg5sH6Yqnzg5DWTI6ukJ2nENVhQjA(mYLIadILZIa)nhMs34D0CVDun0abIrz349UkYfb(ezivFEicFeiVXxYxKkiqsNg3zGajZiVdUvuNsz0UX789qnrZXvbOUmu)kuBHKxt8BomLUX7O5E7OAOHG34l5luxgQBSLfwEYoBCfc1fa1vKluxgQBSnjU6bh3Il7tsAqDbaG6NhIadILZIa5Z6bh3UgBzhooQNfzivF(eHpcK34l5lsfeiPtJ7mqGQd1KzK3b3kQtPmA34D(EOMO54QauxQeuBrxXMWYt2zJ7Mmu)aQl6qOwnOUmuBHKxt8BomLUX7O5E7OAOHG34l5luxgQBSLH6caa1Va1LH6gBtIREWXnuxauFqoebgelNfbYN1doUDn2YoCCuplYqQ(Sie(iqEJVKVivqGKonUZabAHKxtqg51PKJ2e8gFjFH6YqT6qT6q9hZ7fKrEDk5Onb1cYBOUaaq9ZdH6Yq9L)yEVOJJMojSGAb5nudaQleQvdQlvcQTORyty5j7SXDtgQFaaQRixOwneyqSCweijKsxqSCwNmPgcuMuZTXjJajJ86uYrBidP6Zxq4Ja5n(s(Iubbs604odeO6q9hZ7f1PugTB8oFput08zKlfQFaaQRixOUujOwDO(J59I6ukJ2nENVhQjA(mYLc1pGA8euxgQ)yEVaBvosfCuR5TYukA(mYLc1paa1vKluxgQ)yEVaBvosfCuR5TYukWQHA1GA1G6Yq9hZ7f1PugTB8oFputGvJadILZIa99qnCk0NuNhRvazivFEme(iqEJVKVivqGKonUZabArxXMWYt2zJ7Mmu)aQRixOUujOwDO2IUInHLNSZg3nzO(butMrEhCROoLYODJ357HAIMpJCPqDzO(J59cSv5ivWrTM3ktPaRgQvdbgelNfb67HA4uOpPopwRaYqgYqG4LBAols1Io85XFyrfDqef9YZcrG4IEZTIIapypRN24luF8qDqSCwOwMuJkGaHaP1mbPArf(ebw3JpLmc8aH6dqpudQXZWHPeQXZTzLsdc0bc1knRMECvuXQ0uI9fK5urAEIjdlNL0H3uKMNefHaDGq9buDNsOUOIkgQl6WNhpuFWH6NhECFEqHabb6aH6JdLXwX0JleOdeQp4q9b7sKyxgQXZk3luFaAMpIfqGoqO(Gd1hq3lu7dP8hK3qTFAOgJMBfuFWGN)awXq9X5CaG60d11YqbUH6CtldJPqTkdiu)z)0muxpJm3kOwovjbQtkutMZAjB8vabcc0bc1hmhWzcMXxO(Z(PzOMmN)WG6pxLlva1hqecxBuOEN9GRm6tpMeQdILZsH6zLkiGafelNLkQBMmN)Wa4Lb9neOGy5SurDZK58hgWau0pZfcuqSCwQOUzYC(ddyakgyvN8AHLZcb6aHAWnQPkhdQ7iVq9hZ75lutTWOq9N9tZqnzo)Hb1FUkxkuh7fQRB(GxpMLBfuNuO(ollGafelNLkQBMmN)WagGI0nQPkhZrTWOqGcILZsf1ntMZFyadqX6XYzHabb6aH6dMd4mbZ4luZ4LBfGAlpzO2uYqDqSPH6Kc1bEJugFjlGafelNLc4m3RZ3mFedb6aH6dO6APcq9bOhQb1hagVCd1XEH6ZixlYfQpyjka14hYzPqGcILZsbgGIkhCYCRCFzqTItpGxVJj89qnNNXl3cljVZTQS6VAHKxt8BomLUX7O5E7OAOHG34l5BPsKzK3b3k(nhMs34D0CVDun0q08zKlTGNfQgeOGy5SuGbOyLmiziDXfVXs4ItpGpM3lsIcolKZsfnFg5sFaOICl)X8ErsuWzHCwQaRUmTMLsNfDfBurLmiziDXfVXs4cauuz1F1cjVM43CykDJ3rZ92r1qdbVXxY3sLiZiVdUv8BomLUX7O5E7OAOHO5ZixAbpluniqbXYzPadqrFpuZrToFZfNEaFmVxKefCwiNLkA(mYL(aqf5w(J59IKOGZc5SubwDz1F1cjVM43CykDJ3rZ92r1qdbVXxY3sLiZiVdUv8BomLUX7O5E7OAOHO5ZixAbpluniqbXYzPadqrsiLUGy5SozsTI34KbqMrEhClfcuqSCwkWauSXwxqSCwNmPwXBCYa(d1vpJm3QItpalK8AIFZHP0nEhn3Bhvdne8gFjFlRozg5DWTIFZHP0nEhn3BhvdnenFg5sFuyPsQtMrEhCR43CykDJ3rZ92r1qdrZNrU0hfDyzl6k2ewEYoBC3KF8sHQPgeOGy5SuGbOyJTUGy5SozsTI34Kb8hQZsY7CRko9aUJj(nhMs34D0CVDun0qyj5DUvqGcILZsbgGIn26cILZ6Kj1kEJtgW8LPXDy5SfNEaFmVxuNsz0UX789qnbwDzlK8AI5ltJ7WYzf8gFjFHafelNLcmafBS1felN1jtQv8gNmGy4ItpGGyjEzhV8zY0caueeOGy5SuGbOijKsxqSCwNmPwXBCYaOwS3OVqGGafelNLkIHb0850uwYuQdxUg3fNEawi51evHPK7CRCuB6tbVXxY3sLupoI70yHVNJ41z8zntnrh77Y0AwkDw0vSrfnFonLLmL6WLRXDbaEP8RFmVx05jlWQvdcuqSCwQiggyakwjdsgsxCXBSeU40dWcjVMW3d1OefmLSG34l5leOGy5SurmmWau03d1CuRZ3CXw0vS5spa1V8hZ7fDC00jHfuliVFuyPsx(J59IooA6KWIMpJCPpEEOALjZiVdUv0850uwYuQdxUg3IMpJCPpaueEurULTqYRjQctj35w5O20NcEJVKVLF1cjVMW3d1OefmLSG34l5leOGy5SurmmWau03d1CuRZ3CXPhazg5DWTIMpNMYsMsD4Y14w08zKl9bGIWJkYTSfsEnrvyk5o3kh1M(uWB8L8fcuqSCwQiggyakQCWjZTY9Lb1ko9a(yEVOZtwGvdbkiwolveddmaf99qnkrbtjxC6b8X8EX7ukZTYDgeL5YcSAiqbXYzPIyyGbOyLmiziDXfVXs4ItpGgBtIREWXT4Y(KK2d1FwiWwi51en2MexygVyHLZk4n(s(IhVOgeOGy5SurmmWau03d1CuRZ3CXw0vS5spa1V8hZ7fDC00jHfuliVFuyPsx(J59IooA6KWIMpJCPpEEOALBSnjU6bh3Il7tsApu)zHaBHKxt0yBsCHz8IfwoRG34l5lE8IALF1cjVMW3d1OefmLSG34l5leOGy5SurmmWau03d1CuRZ3CXPhqJTjXvp44wCzFss7H6pleylK8AIgBtIlmJxSWYzf8gFjFXJxudcuqSCwQiggyak2850uwYuQdxUg3qGcILZsfXWadqrFpuJsuWuYqGcILZsfXWadqX5ltJ7W4ITORyZLEaQF5pM3l64OPtclOwqE)OWsLU8hZ7fDC00jHfnFg5sF88q1k3yBsC1doUfx2NK0kq9IkeylK8AIgBtIlmJxSWYzf8gFjFXJxuR8Rwi51e(EOgLOGPKf8gFjFHafelNLkIHbgGIZxMg3HXfNEan2Mex9GJBXL9jjTcuVOcb2cjVMOX2K4cZ4flSCwbVXxYx84f1GafelNLkIHbgGIvYGKH0fx8glHHafelNLkIHbgGI(EOMJAD(Ml2IUInx6bO(L)yEVOJJMojSGAb59Jclv6YFmVx0XrtNew08zKl9XZdvR8Rwi51e(EOgLOGPKf8gFjFHafelNLkIHbgGI(EOMJAD(MHafelNLkIHbgGIkNEDJ3HlxJBiqbXYzPIyyGbOy0KyzNnDZRbbcc0bc1Q0CykH6Xd1G5E7OAObuxpJm3kOUhlSCwO(4c1ulAJc1fDifQ)SFAgQpotPmAOE8q9bOhQb1ad1QmGqD0muh4nsz8LmeOGy5SuXFOU6zK5wbq5GtMBL7ldQvC6b8X8ErNNSaRgcuqSCwQ4pux9mYCRagGIZxMg3HXfBrxXMl9au)YFmVx0XrtNewqTG8(rHLkD5pM3l64OPtclA(mYL(45HQvUXwwy5j7SXDShvKB5gBtIREWXT4Y(KKwbakQWYVAHKxt47HAuIcMswWB8L8fcuqSCwQ4pux9mYCRagGIZxMg3HXfNEan2YclpzNnUJ9OICl3yBsC1doUfx2NK0kaqrfcbkiwolv8hQREgzUvadqXkzqYq6IlEJLWfNEan2Mex9GJBXL9jjThfDyzYmY7GBf1PugTB8oFput08zKlTGgBzHLNSZg3XktRzP0zrxXgvujdsgsxCXBSeUaafbbkiwolv8hQREgzUvadqrFpuZrToFZfBrxXMl9au)YFmVx0XrtNewqTG8(rHLkD5pM3l64OPtclA(mYL(45HQvUX2K4QhCClUSpjP9OOdltMrEhCROoLYODJ357HAIMpJCPf0yllS8KD24ow5xTqYRj89qnkrbtjl4n(s(cbkiwolv8hQREgzUvadqrFpuZrToFZfNEan2Mex9GJBXL9jjThfDyzYmY7GBf1PugTB8oFput08zKlTGgBzHLNSZg3XGafelNLk(d1vpJm3kGbOOVhQrjkyk5ItpGpM3lENszUvUZGOmxwGvxUX2K4QhCClUSpjPvG6pleylK8AIgBtIlmJxSWYzf8gFjFXJxuRmTMLsNfDfBuHVhQrjkyk5caueeOGy5SuXFOU6zK5wbmaf99qnkrbtjxC6b0yBsC1doUfx2NK0kaG6VuiWwi51en2MexygVyHLZk4n(s(IhVOwzAnlLol6k2OcFpuJsuWuYfaOiiqbXYzPI)qD1ZiZTcyakoFzAChgxSfDfBU0dq9l)X8ErhhnDsyb1cY7hfwQ0L)yEVOJJMojSO5Zix6JNhQw5gBtIREWXT4Y(KKwbau)Lcb2cjVMOX2K4cZ4flSCwbVXxYx84f1k)QfsEnHVhQrjkykzbVXxYxiqbXYzPI)qD1ZiZTcyakoFzAChgxC6b0yBsC1doUfx2NK0kaG6VuiWwi51en2MexygVyHLZk4n(s(IhVOgeOGy5SuXFOU6zK5wbmafRKbjdPlU4nwcxC6bqMrEhCROoLYODJ357HAIMpJCPf0yllS8KD24ow5gBtIREWXT4Y(KK2JJDyzAnlLol6k2OIkzqYq6IlEJLWfaOiiqbXYzPI)qD1ZiZTcyak67HAoQ15BUyl6k2CPhG6x(J59IooA6KWcQfK3pkSuPl)X8ErhhnDsyrZNrU0hppuTYKzK3b3kQtPmA34D(EOMO5ZixAbn2YclpzNnUJvUX2K4QhCClUSpjP94yhw(vlK8AcFpuJsuWuYcEJVKVqGcILZsf)H6QNrMBfWau03d1CuRZ3CXPhazg5DWTI6ukJ2nENVhQjA(mYLwqJTSWYt2zJ7yLBSnjU6bh3Il7tsApo2HqGGaDGq9biKYFqEd12a1yugQpoNdqXq9bdE(dyqnoL8c1yuUp45MwggtHAvgqOUU5ZWWAwQGacuqSCwQ4puNLK35wbOoLYODJ357HAfNEaKzK3b3k4Z6bh3UgBzhooQNv08zKlfcuqSCwQ4puNLK35wbmaf5Z6bh3UgBzhooQNfceeOdeQXZW(atAqnyEECa1)H6SK8o3kO2ps5GJkGafelNLk(d1zj5DUvadqX5ltJ7W4ITORyZLEaQF5pM3l64OPtclOwqE)OWsLU8hZ7fDC00jHfnFg5sF88q1k3yBsC1doUFa4Ldl)QfsEnHVhQrjkykzbVXxYxiqbXYzPI)qDwsENBfWauC(Y04omU40dOX2K4QhCC)aWlhcbkiwolv8hQZsY7CRagGInFonLLmL6WLRXDXPhGfsEnrvyk5o3kh1M(uWB8L8fcuqSCwQ4puNLK35wbmafvo4K5w5(YGAfNEaFmVx05jlWQHafelNLk(d1zj5DUvadqX5ltJ7W4ITORyZLEaQF5pM3l64OPtclOwqE)OWsLU8hZ7fDC00jHfnFg5sF88q1k3yllS8KD24k8rf5wQuJTjXvp44(bGJvy5xTqYRj89qnkrbtjl4n(s(cbkiwolv8hQZsY7CRagGIZxMg3HXfNEan2YclpzNnUcFurULk1yBsC1doUFa4yfcbkiwolv8hQZsY7CRagGI(EOgLOGPKlo9a(yEV4DkL5w5odIYCzbwDzAnlLol6k2OcFpuJsuWuYfaOiiqbXYzPI)qDwsENBfWauu50RB8oC5ACxC6b0yBsC1doUfx2NK0kaWlhwUXwwy5j7SX9sbvKleOGy5SuXFOoljVZTcyak2850uwYuQdxUg3qGcILZsf)H6SK8o3kGbOOVhQrjkyk5ItpaAnlLol6k2OcFpuJsuWuYfaOiiqbXYzPI)qDwsENBfWauC(Y04omUyl6k2CPhG6x(J59IooA6KWcQfK3pkSuPl)X8ErhhnDsyrZNrU0hppuTYn2Mex9GJBXL9jjTckQWsLASLl4LYVAHKxt47HAuIcMswWB8L8fcuqSCwQ4puNLK35wbmafNVmnUdJlo9aASnjU6bh3Il7tsAfuuHLk1ylxWlqGcILZsf)H6SK8o3kGbOy0KyzNnDZRvC6b0yBsC1doUfx2NK0kOOdHabb6aH6JJrEHALC0gutM9MwolfcuqSCwQGmYRtjhTbGOmYL6gVljCXPhWhZ7fKrEDk5Onb1cY7ckSSfDfBclpzNnUBYpQixiqbXYzPcYiVoLC0gWauKOmYL6gVljCXPhG6FmVxuNsz0UX789qnrZNrU0haQix8q9NatMrEhCRW3d1WPqFsDESwbrZXvb1kv6J59I6ukJ2nENVhQjA(mYL(OXwwy5j7SX9IAL)yEVOoLYODJ357HAcSAiqbXYzPcYiVoLC0gWauKOmYL6gVljCXPhWhZ7f1PugTB8oFput08zKl9bEQ8hZ7fyRYrQGJAnVvMsrZNrU0hvKlEO(tGjZiVdUv47HA4uOpPopwRGO54QGAL)yEVaBvosfCuR5TYukA(mYLw(J59I6ukJ2nENVhQjWQHabbkiwolvqMrEhClfagLDPXN0Itpa1jZiVdUvuNsz0UX789qnrZXvHsLiZiVdUvuNsz0UX789qnrZNrU0ck6q1kR(Rwi51e)MdtPB8oAU3oQgAi4n(s(wQezg5DWTc(SEWXTRXw2HJJ6zfnFg5sl44luniqbXYzPcYmY7GBPadqrmk7sJplEJtgqvpBf1v35ziDDuXfNEan2Ypa8s5x)yEVOoLYODJ357HAcS6YQ)6DmXV5Wu6gVJM7TJQHgcljVZTQuPxTqYRj(nhMs34D0CVDun0qWB8L8vniqbXYzPcYmY7GBPadqrmk7sJplEJtgqhhDX23u3pRCnFDFmZMfcuqSCwQGmJ8o4wkWaueJYU04ZI34KbCYn)2uguNp2QItpGxVJj(nhMs34D0CVDun0qyj5DUvLF9J59I6ukJ2nENVhQjWQHafelNLkiZiVdULcmafRhlNT40d4J59I6ukJ2nENVhQjWQl)X8EbFwp4421yl7WXr9ScSAiqbXYzPcYmY7GBPadqXVCMRZJ1kuC6b8X8ErDkLr7gVZ3d1ey1L)yEVGpRhCC7ASLD44OEwbwneOGy5Subzg5DWTuGbO4NBk3VZTQ40d4J59I6ukJ2nENVhQjWQHaDGq9bOhQb1KzK3b3sHafelNLkiZiVdULcmafRtPmA34D(EOwXPhazg5DWTc(SEWXTRXw2HJJ6zfnFg5sHafelNLkiZiVdULcmaf)nhMs34D0CVDun0Oymk7gV3vrUaEwC6bqMrEhCRGpRhCC7ASLD44OEwrZNrU0YKzK3b3kQtPmA34D(EOMO5ZixkeOGy5Subzg5DWTuGbOiFwp4421yl7WXr9SfNEaKzK3b3kQtPmA34D(EOMO54Qq5xTqYRj(nhMs34D0CVDun0qWB8L8TCJTSWYt2zJRWcQi3Yn2Mex9GJBXL9jjTca88qiqbXYzPcYmY7GBPadqr(SEWXTRXw2HJJ6zlo9auNmJ8o4wrDkLr7gVZ3d1enhxfkvYIUInHLNSZg3n5hfDOALTqYRj(nhMs34D0CVDun0qWB8L8TCJTCbaEPCJTjXvp44UGdYHqGcILZsfKzK3b3sbgGIKqkDbXYzDYKAfVXjdGmYRtjhTvC6byHKxtqg51PKJ2e8gFjFlRU6FmVxqg51PKJ2euliVlaWZdlF5pM3l64OPtclOwqEdOq1kvYIUInHLNSZg3n5haQix1GafelNLkiZiVdULcmaf99qnCk0NuNhRvO40dq9pM3lQtPmA34D(EOMO5Zix6davKBPsQ)X8ErDkLr7gVZ3d1enFg5sFGNk)X8Eb2QCKk4OwZBLPu08zKl9bGkYT8hZ7fyRYrQGJAnVvMsbwTAQv(J59I6ukJ2nENVhQjWQHafelNLkiZiVdULcmaf99qnCk0NuNhRvO40dWIUInHLNSZg3n5hvKBPsQBrxXMWYt2zJ7M8dYmY7GBf1PugTB8oFput08zKlT8hZ7fyRYrQGJAnVvMsbwTAqGGaDGqnE2FzAChwolu3JfwoleOGy5SuX8LPXDy5SaA(CAklzk1HlxJ7ItpalK8AIQWuYDUvoQn9PG34l5leOGy5SuX8LPXDy5SadqX5ltJ7W4ITORyZLEaQF5pM3l64OPtclOwqE)OWsLU8hZ7fDC00jHfnFg5sF88q1k)QfsEnHVhQrjkykzbVXxY3YV(X8ErNNSaRUmTMLsNfDfBuHYbNm3k3xguRaaVabkiwolvmFzAChwolWauC(Y04omU40d4vlK8AcFpuJsuWuYcEJVKVLF9J59IopzbwDzAnlLol6k2OcLdozUvUVmOwbaEbcuqSCwQy(Y04oSCwGbOOVhQrjkyk5Itpa1)yEV4DkL5w5odIYCzrZbXkvs9pM3lENszUvUZGOmxwGvxw96MXRRICfpf(EOMJAD(MlvQUz86QixXtHYbNm3k3xguRuP6MXRRICfpfvYGKH0fx8glHvtn1ktRzP0zrxXgv47HAuIcMsUaafbbkiwolvmFzAChwolWauC(Y04omUyl6k2CPhG6x(J59IooA6KWcQfK3pkSuPl)X8ErhhnDsyrZNrU0hppuTYFmVx8oLYCRCNbrzUSO5GyLkP(hZ7fVtPm3k3zquMllWQlREDZ41vrUINcFpuZrToFZLkv3mEDvKR4Pq5GtMBL7ldQvQuDZ41vrUINIkzqYq6IlEJLWQPgeOGy5SuX8LPXDy5SadqX5ltJ7W4ItpGpM3lENszUvUZGOmxw0CqSsLu)J59I3PuMBL7mikZLfy1LvVUz86QixXtHVhQ5OwNV5sLQBgVUkYv8uOCWjZTY9Lb1kvQUz86QixXtrLmiziDXfVXsy1udcuqSCwQy(Y04oSCwGbOyLmiziDXfVXs4Itpa1F9J59IopzbwDPsn2Mex9GJBXL9jjThppSuPgBzHLNSZgxrfurUQvMwZsPZIUInQOsgKmKU4I3yjCbakccuqSCwQy(Y04oSCwGbOOYbNm3k3xguR40d4J59IopzbwDzAnlLol6k2OcLdozUvUVmOwbakccuqSCwQy(Y04oSCwGbOOVhQ5OwNV5ITORyZLEaQF5pM3l64OPtclOwqE)OWsLU8hZ7fDC00jHfnFg5sF88q1k)6hZ7fDEYcS6sLASnjU6bh3Il7tsApEEyPsn2YclpzNnUIkOICl)QfsEnHVhQrjkykzbVXxYxiqbXYzPI5ltJ7WYzbgGI(EOMJAD(Mlo9aE9J59IopzbwDPsn2Mex9GJBXL9jjThppSuPgBzHLNSZgxrfurUqGcILZsfZxMg3HLZcmafvo4K5w5(YGAfNEaFmVx05jlWQHafelNLkMVmnUdlNfyakoFzAChgxSfDfBU0dq9l)X8ErhhnDsyb1cY7hfwQ0L)yEVOJJMojSO5Zix6JNhQw5xTqYRj89qnkrbtjl4n(s(cbkiwolvmFzAChwolWauC(Y04omgceeOdeQbTyVrFHAAUvs(GBrxXgu3JfwoleOGy5Sub1I9g9fqZNttzjtPoC5ACdbkiwolvqTyVrFbgGI(EOMJAD(Mlo9aiZiVdUv0850uwYuQdxUg3IMpJCPpaueEurULTqYRjQctj35w5O20NcEJVKVqGcILZsful2B0xGbOOYbNm3k3xguR40d4J59IopzbwneOGy5Sub1I9g9fyakoFzAChgxC6b86hZ7f(EoIxxnMKYcS6Ywi51e(EoIxxnMKYcEJVKVqGcILZsful2B0xGbOOVhQ5OwNV5ItpGgBtIREWXT4Y(KK2d1FwiWwi51en2MexygVyHLZk4n(s(IhVOgeOGy5Sub1I9g9fyak67HAuIcMsU40d4J59I3PuMBL7mikZLfy1LBSLfwEYoBChRaavKleOGy5Sub1I9g9fyakoFzAChgxC6b0yBsC1doUfx2NK0kq9IkeylK8AIgBtIlmJxSWYzf8gFjFXJxudcuqSCwQGAXEJ(cmaf99qnh168ndbkiwolvqTyVrFbgGIkNEDJ3HlxJBiqbXYzPcQf7n6lWaumAsSSZMU51qgYqia]] )


end
