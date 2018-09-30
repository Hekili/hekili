-- DeathKnightFrost.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


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
        
        elseif amt > 0 and resource == "runic_power" then
            if set_bonus.tier20_2pc == 1 and buff.pillar_of_frost.up then
                virtual_rp_spent_since_pof = virtual_rp_spent_since_pof + amt

                applyBuff( "pillar_of_frost", buff.pillar_of_frost.remains + floor( virtual_rp_spent_since_pof / 60 ) )
                virtual_rp_spent_since_pof = virtual_rp_spent_since_pof % 60
            end
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

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3540, -- 214027
        relentless = 3539, -- 196029
        gladiators_medallion = 3538, -- 208683

        antimagic_zone = 3435, -- 51052
        heartstop_aura = 3439, -- 199719
        deathchill = 701, -- 204080
        delirium = 702, -- 233396
        tundra_stalker = 703, -- 279941
        frozen_center = 704, -- 204135
        overpowered_rune_weapon = 705, -- 233394
        chill_streak = 706, -- 204160
        cadaverous_pallor = 3515, -- 201995
        dark_simulacrum = 3512, -- 77606
        decomposing_aura = 45, -- 199720
        necrotic_aura = 43, -- 199642
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
            id = 178819,
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
            duration = 12.5,
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

        -- Azerite Powers
        glacial_contagion = {
            id = 274074,
            duration = 14,
            max_stack = 1,
        }
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
            
            spend = 45,
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

                removeBuff( "rime" )
            end,
        },
        

        icebound_fortitude = {
            id = 48792,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,
            texture = 237525,
            
            handler = function ()
                applyBuff( "icebound_fortitude" )
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
            
            usable = function () return target.casting end,
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
            
            recheck = function () return buff.frozen_pulse.remains, buff.rime.remains, runes.time_to_4 - gcd, runes.time_to_5 - gcd, runic_power[ "time_to_" .. ( runic_power.max - 25 ) ], runic_power[ "time_to_" .. ( runic_power.max - ( 25 + talent.runic_attenuation.rank * 3 ) ) ] end,
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
            cooldown = 20,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = false,
            texture = 538770,
            
            recheck = function ()
                return buff.remorseless_winter.remains - gcd, buff.remorseless_winter.remains
            end,
            handler = function ()
                applyBuff( "remorseless_winter" )
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


    spec:RegisterPack( "Frost DK", 20180929.2041, [[du0QabqiqHEeIK2KQsJcuYPafTkqbVsvvZIK4wis0UO0VuLmmqPogjPLrs5zQQ00ue6AQs12qKsFdrQACkcCofrSofbzEQQ4EkQ9HioiIurleb9qfbLjQikDrfbv2OIO6KisOvQi9sej4MisL2jc8tfbvnuePyPkIINQIPQQyVa)LudwHdt1Ib5Xqnzv6YO2SO(SinAe60cVgrz2qUTQy3s9BjdxelxPNJ00jUoj2UQu(oOA8isfopjvRxrKMpIQ9tXavbFaNRlmGa1GTQtaSNe1MeRAWEIQQk4iQNWGtIJjZtzWP9hgCM8TOIzmzjfaNexDu5xWhWHwklMbhIIKqNqVELgcrfilUEErJhfKlr141ZYlA8GFbHkOxqzNuE53ELSvoqm9fPz5jJhx6lsZKrpzzxiQjf6iLOON8TOILgpyWbsjqcPydGaNRlmGa1GTQtaSNe1MeRAWEIQcBsp44kcXAbNt8mHboeJ7LBae4CzkgCivZyY3IkMXKLDHOzqk0rkrXmLundIIKqNqVELgcrfilUEErJhfKlr141ZYlA8GFbHkOxqzNuE53ELSvoqm9fPz5jJhx6lsZKrpzzxiQjf6iLOON8TOILgpyZus1moCIWpq8AgQnjQygQbBvNaZGuAgtWe63jWminKUMPMPKQzmHr07uMoHmtjvZGuAgKIngPCzZG0n6Rzm5lZtkBbhuqfk4d4Gl0vtK9vaFaeOk4d4WTdH4lGqWbVHWB4GdKsoBXf6QjY(kwQ4yYmdsmJ3nJVMH4BklwjEyTu6BWMXpMrk(coowIQbhmrpAQUY6aZabqGAGpGd3oeIVacbh8gcVHdoWYmGuYzBsGq(QRSoVfvSl)4rtnJFMnJu81mGbZawMHQMXFZaxf6wWBBElQax99HQZkR62L9R6MbmndYj3mGuYzBsGq(QRSoVfvSl)4rtnJFmJvPzRepSwk9VMbmnJVMbKsoBtceYxDL15TOIvjbCCSevdoyIE0uDL1bMbcqaNccfcVUevd(aiqvWhWHBhcXxaHGdEdH3WbhXrCl2uxiYB0PAQu7JLBhcXxWXXsun4S8tTugXuQgE0cVabqGAGpGd3oeIVacbh8gcVHdoWOzioIBXM3IkuS6cr2YTdH4Rz81mGrZasjNTB8WwLeZ4Rzqtyesl(MYc1sSGJIovdHCQygKmBg)coowIQbNccfcVUWabqWVGpGd3oeIVacbh8gcVHdoWYmGuYzlzbcfDQ(XXeJMTl7yXmiNCZawMbKsoBjlqOOt1poMy0SvjXm(AgWYmsw(nDk(Av1M3IkAQSbzSzqo5MrYYVPtXxRQwIfCu0PAiKtfZGCYnJKLFtNIVwvTPihhos7338gZMbmndyAgW0m(Ag0egH0IVPSqT5TOcfRUqKndsMnd1ahhlr1GtElQqXQlezGaiyIGpGd3oeIVacbh8gcVHdoqk5SLSaHIov)4yIrZ2LDSygKtUzalZasjNTKfiu0P6hhtmA2QKygFndyzgjl)MofFTQAZBrfnv2Gm2miNCZiz530P4RvvlXcok6uneYPIzqo5MrYYVPtXxRQ2uKJdhP97BEJzZaMMbmbhhlr1GtbHcHxxyGai4DWhWHBhcXxaHGdEdH3WbhyzgWOzaPKZ2nEyRsIzqo5MXQ0bwNuW51E5CGdXm(Xmuf2Mb5KBgRsZwjEyTuA1mdsmJu81mGPz81mOjmcPfFtzHAtrooCK2VV5nMndsMnd1ahhlr1GtkYXHJ0(9nVXmqaeqAbFahUDieFbeco4neEdhCGuYz7gpSvjXm(Ag0egH0IVPSqTel4OOt1qiNkMbjZMHAGJJLOAWHybhfDQgc5ubiaci9GpGd3oeIVacbh8gcVHdoWOzaPKZ2nEyRsIzqo5MXQ0bwNuW51E5CGdXm(Xmuf2Mb5KBgRsZwjEyTuA1mdsmJu8fCCSevdo5TOIMkBqgdeabta4d4WTdH4lGqWbVHWB4GdKsoB34HTkjGJJLOAWHybhfDQgc5ubiacMeWhWXXsun4uqOq41fgC42Hq8fqiqac4qfVV(EbFaeOk4d44yjQgCw(PwkJykvdpAHxWHBhcXxaHabqGAGpGd3oeIVacbh8gcVHdo4Qq3cEBx(PwkJykvdpAHx7YpE0uZ4NzZqnZagmJu81m(AgIJ4wSPUqK3Ot1uP2hl3oeIVGJJLOAWjVfv0uzdYyGai4xWhWHBhcXxaHGdEdH3WbhiLC2UXdBvsahhlr1GdXcok6uneYPcqaemrWhWHBhcXxaHGdEdH3Wbhy0mGuYzBERjLBDIcIYwLeZ4RzioIBXM3As5wNOGOSLBhcXxWXXsun4uqOq41fgiacEh8bC42Hq8fqi4G3q4nCWzv6aRtk48AVCoWHyg)ygWYmu9DZ4VzioIBXUkDG1UiCR4suTLBhcXxZagmJFndycoowIQbN8wurtLniJbcGasl4d4WTdH4lGqWbVHWB4GdKsoBjlqOOt1poMy0SvjXm(AgRsZwjEyTu6jAgKmBgP4l44yjQgCYBrfkwDHideabKEWhWHBhcXxaHGdEdH3WbNvPdSoPGZR9Y5ahIzqIzalZqT3nJ)MH4iUf7Q0bw7IWTIlr1wUDieFndyWm(1mGj44yjQgCkiui86cdeabta4d44yjQgCYBrfnv2GmgC42Hq8fqiqaemjGpGJJLOAWHyTTUYA4rl8coC7qi(cieiacuf2GpGJJLOAWXxS3SwQD5wahUDieFbeceGaoqfvNufk6uWhabQc(aoC7qi(cieCWBi8go4aPKZ2nEyRsc44yjQgCiwWrrNQHqovacGa1aFahUDieFbeco4neEdhCwLMTs8WAP0t0m(XmsXxZ4RzSkDG1jfCETxoh4qmdsMnd1EhCCSevdofekeEDHbcGGFbFahUDieFbeco4neEdhCwLoW6KcoV2lNdCiMXpMHAW2m(Ag4Qq3cEBtceYxDL15TOID5hpAQzqIzSknBL4H1sPNOz81mOjmcPfFtzHAtrooCK2VV5nMndsMnd1ahhlr1GtkYXHJ0(9nVXmqaemrWhWHBhcXxaHGdEdH3WbNvPdSoPGZR9Y5ahIz8JzOgSnJVMbUk0TG32KaH8vxzDElQyx(XJMAgKygRsZwjEyTu6jcoowIQbN8wurtLniJbcGG3bFahUDieFbeco4neEdhCGuYzlzbcfDQ(XXeJMTkjMXxZyv6aRtk48AVCoWHygKygWYmu9DZ4VzioIBXUkDG1UiCR4suTLBhcXxZagmJFndyAgFndAcJqAX3uwO28wuHIvxiYMbjZMHAGJJLOAWjVfvOy1fImqaeqAbFahUDieFbeco4neEdhCwLoW6KcoV2lNdCiMbjZMbSmJFF3m(BgIJ4wSRshyTlc3kUevB52Hq81mGbZ4xZaMMXxZGMWiKw8nLfQnVfvOy1fISzqYSzOg44yjQgCYBrfkwDHideabKEWhWHBhcXxaHGdEdH3WbNvPdSoPGZR9Y5ahIzqYSzalZ433nJ)MH4iUf7Q0bw7IWTIlr1wUDieFndyWm(1mGj44yjQgCkiui86cdeabta4d4WTdH4lGqWbVHWB4GdUk0TG32KaH8vxzDElQyx(XJMAgKygRsZwjEyTu6jAgFnJvPdSoPGZR9Y5ahIz8JzmryBgFndAcJqAX3uwO2uKJdhP97BEJzZGKzZqnWXXsun4KICC4iTFFZBmdeabtc4d4WTdH4lGqWbVHWB4GdUk0TG32KaH8vxzDElQyx(XJMAgKygRsZwjEyTu6jAgFnJvPdSoPGZR9Y5ahIz8JzmrydoowIQbN8wurtLniJbcqaNKLX1dKlGpacuf8bC42Hq8fqiqaeOg4d4WTdH4lGqGai4xWhWHBhcXxaHabqWebFahUDieFbeceabVd(aoowIQbNKsIQbhUDieFbeceGaoEXGpacuf8bC42Hq8fqi4G3q4nCWrCe3In1fI8gDQMk1(y52Hq8fCCSevdol)ulLrmLQHhTWlqaeOg4d4WTdH4lGqWbVHWB4GJ4iUfBElQqXQlezl3oeIVGJJLOAWjf54WrA)(M3ygiac(f8bC42Hq8fqi4G3q4nCWbxf6wWB7Yp1szetPA4rl8Ax(XJMAg)mBgQzgWGzKIVMXxZqCe3In1fI8gDQMk1(y52Hq8fCCSevdo5TOIMkBqgdeabte8bC42Hq8fqi4G3q4nCWbsjNTB8WwLeWXXsun4qSGJIovdHCQaeabVd(aoC7qi(cieCWBi8go4aPKZwYcek6u9JJjgnBvsahhlr1GtElQqXQlezGaiG0c(aoC7qi(cieCWBi8go4SkDG1jfCETxoh4qmJFmdyzgQ(Uz83mehXTyxLoWAxeUvCjQ2YTdH4RzadMXVMbmbhhlr1GtkYXHJ0(9nVXmqaeq6bFahUDieFbeco4neEdhCwLoW6KcoV2lNdCiMXpMbSmdvF3m(BgIJ4wSRshyTlc3kUevB52Hq81mGbZ4xZaMGJJLOAWjVfv0uzdYyGaiycaFahhlr1GZYp1szetPA4rl8coC7qi(cieiacMeWhWXXsun4K3IkuS6crgC42Hq8fqiqaeOkSbFahUDieFbeco4neEdhCwLoW6KcoV2lNdCiMbjMbSmd1E3m(BgIJ4wSRshyTlc3kUevB52Hq81mGbZ4xZaMGJJLOAWPGqHWRlmqaeOQQGpGJJLOAWjf54WrA)(M3ygC42Hq8fqiqaeOQAGpGJJLOAWjVfv0uzdYyWHBhcXxaHabqGQ)c(aoowIQbhI126kRHhTWl4WTdH4lGqGaiq1jc(aoowIQbhFXEZAP2LBbC42Hq8fqiqac4avuTeyYIof8bqGQGpGd3oeIVacbh8gcVHdoRshyDsbNxZ4NzZ4xydoowIQbNccfcVUWabqGAGpGd3oeIVacbh8gcVHdoIJ4wSPUqK3Ot1uP2hl3oeIVGJJLOAWz5NAPmIPun8OfEbcGGFbFahUDieFbeco4neEdhCGuYz7gpSvjbCCSevdoel4OOt1qiNkabqWebFahUDieFbeco4neEdhCwLMTs8WAP0VBg)ygP4Rzqo5MXQ0bwNuW51m(z2mM47GJJLOAWPGqHWRlmqae8o4d4WTdH4lGqWbVHWB4GdKsoBjlqOOt1poMy0SvjXm(Ag0egH0IVPSqT5TOcfRUqKndsMnd1ahhlr1GtElQqXQlezGaiG0c(aoC7qi(cieCWBi8go4SkDG1jfCETxoh4qmdsMnJFHTz81mwLMTs8WAP0)AgKygP4l44yjQgCiwBRRSgE0cVabqaPh8bCCSevdol)ulLrmLQHhTWl4WTdH4lGqGaiycaFahUDieFbeco4neEdhCOjmcPfFtzHAZBrfkwDHiBgKmBgQboowIQbN8wuHIvxiYabqWKa(aoC7qi(cieCWBi8go4SkDG1jfCETxoh4qmdsmd1E3miNCZyvA2miXm(fCCSevdofekeEDHbcGavHn4d4WTdH4lGqWbVHWB4GZQ0bwNuW51E5CGdXmiXmud2GJJLOAWXxS3SwQD5wacqaNlNDfKa(aiqvWhWXXsun48e9vNxMNugC42Hq8fqiqaeOg4d4WTdH4lGqWbVHWB4GdmAg3sS5TOIoZVXRvcmzrNAgFndyzgWOzioIBXcTSle1vwtJ(UEArDl3oeIVMb5KBg4Qq3cEBHw2fI6kRPrFxpTOUD5hpAQzqIzO67Mbmbhhlr1GdXcok6uneYPcqae8l4d4WTdH4lGqWbVHWB4GdKsoBdS6AXrvtTl)4rtnJFMnJu81m(Agqk5SnWQRfhvn1QKygFndAcJqAX3uwO2uKJdhP97BEJzZGKzZqnZ4RzalZagndXrClwOLDHOUYAA031tlQB52Hq81miNCZaxf6wWBl0YUquxznn676Pf1Tl)4rtndsmdvF3mGj44yjQgCsrooCK2VV5nMbcGGjc(aoC7qi(cieCWBi8go4aPKZ2aRUwCu1u7YpE0uZ4NzZifFnJVMbKsoBdS6AXrvtTkjMXxZawMbmAgIJ4wSql7crDL10OVRNwu3YTdH4Rzqo5MbUk0TG3wOLDHOUYAA031tlQBx(XJMAgKygQ(UzatWXXsun4K3IkAQSbzmqae8o4d4WTdH4lGqWXXsun4GDes7yjQwJcQaoOGk62FyWbxf6wWBkqaeqAbFahUDieFbeco4neEdhCehXTyHw2fI6kRPrFxpTOULBhcXxZ4RzGRcDl4TfAzxiQRSMg9D90I62LF8OPMXpMX7GJJLOAWzvATJLOAnkOc4GcQOB)HbhOIQtQcfDkqaeq6bFahUDieFbeco4neEdhCULyHw2fI6kRPrFxpTOUvcmzrNcoowIQbNvP1owIQ1OGkGdkOIU9hgCGkQwcmzrNceabta4d4WTdH4lGqWbVHWB4GdKsoBtceYxDL15TOIvjXm(AgIJ4wSfekeEDjQ2YTdH4l44yjQgCwLw7yjQwJcQaoOGk62FyWPGqHWRlr1abqWKa(aoC7qi(cieCWBi8go44yjEJ1CZpbtndsMnd1ahhlr1GZQ0Ahlr1AuqfWbfur3(ddoEXabqGQWg8bC42Hq8fqi44yjQgCWocPDSevRrbvahuqfD7pm4qfVV(EbcqahCvOBbVPGpacuf8bC42Hq8fqi4G3q4nCWbxf6wWBBsGq(QRSoVfvSl7x1nJVMbSmdy0mehXTyHw2fI6kRPrFxpTOULBhcXxZGCYndiLC2YpjfCE1RsZA4SNuTvjXmGj44yjQgCuOSoe(HceabQb(aoC7qi(cieCA)HbN1N0RstgvdfP6LVAifrQgCCSevdoRpPxLMmQgks1lF1qkIunqae8l4d4WTdH4lGqWP9hgCE4Ljti6uD27uWXXsun48WltMq0P6S3PabqWebFahUDieFbeco4neEdhCGuYzBsGq(QRSoVfvSkjMXxZasjNT8tsbNx9Q0Sgo7jvBvsahhlr1Gtsjr1abqW7GpGd3oeIVacbh8gcVHdoqk5SnjqiF1vwN3IkwLeZ4RzaPKZw(jPGZREvAwdN9KQTkjGJJLOAWbcv1vNvw1bcGasl4d4WTdH4lGqWbVHWB4GdKsoBtceYxDL15TOIvjbCCSevdoq8s5LSOtbcGasp4d4WTdH4lGqWbVHWB4GdUk0TG3w(jPGZREvAwdN9KQTl)4rtbhhlr1GtsGq(QRSoVfvacGGja8bC42Hq8fqi4G3q4nCWbxf6wWBl)KuW5vVknRHZEs12LF8OPMXxZaxf6wWBBsGq(QRSoVfvSl)4rtbhhlr1Gd0YUquxznn676Pf1bcGGjb8bC42Hq8fqi4G3q4nCWbxf6wWBBsGq(QRSoVfvSl7x1nJVMbmAgIJ4wSql7crDL10OVRNwu3YTdH4Rz81mwLMTs8WAP0VBgKygP4Rz81mwLoW6KcoV2lNdCiMbjZMHQWgCCSevdo8tsbNx9Q0Sgo7jvdeabQcBWhWHBhcXxaHGdEdH3WbhCvOBbVTjbc5RUY68wuXUSFv3m(AgIJ4wSql7crDL10OVRNwu3YTdH4Rz81mwLMndsMnJFnJVMXQ0bwNuW51miXmiTWgCCSevdo8tsbNx9Q0Sgo7jvdeabQQk4d4WTdH4lGqWbVHWB4GJ4iUflUqxnr2xXYTdH4Rz81mGLzalZasjNT4cD1ezFflvCmzMbjZMHQW2m(AgxgsjNTRpP1gy2sfhtMzmBgVBgW0miNCZq8nLfRepSwk9nyZ4NzZifFndycoowIQbhSJqAhlr1AuqfWbfur3(ddo4cD1ezFfGaiqv1aFahUDieFbeco4neEdhCGuYzBsGq(QRSoVfvSl)4rtnJFMnJu81m(Agqk5SnjqiF1vwN3IkwLeWXXsun4K3IkWvFFO6SYQoqacqaN34LgvdiqnyR6ea7jb2QzvtvyRk4a33o6uk4qk(KuRWxZysmdhlr1MbkOc1AMco0egdiqT3vfCs2khigCivZyY3IkMXKLDHOzqk0rkrXmLundIIKqNqVELgcrfilUEErJhfKlr141ZYlA8GFbHkOxqzNuE53ELSvoqm9fPz5jJhx6lsZKrpzzxiQjf6iLOON8TOILgpyZus1moCIWpq8AgQnjQygQbBvNaZGuAgtWe63jWminKUMPMPKQzmHr07uMoHmtjvZGuAgKIngPCzZG0n6Rzm5lZtkBntntjvZychPdgRi81mG4CTSzGRhixmdionAQ1miDIXCIqnJUAsjrFFYkiZWXsun1mQgPU1m1Xsun1MSmUEGCzoJCkzMPowIQP2KLX1dKl)NFLR6AM6yjQMAtwgxpqU8F(LRK(WT4suTzkPAgN2tOelXmwpUMbKsoZxZGkUqndioxlBg46bYfZaItJMAgEFnJKLjLjLirNAgb1mUvZwZuhlr1uBYY46bYL)ZVOTNqjwIMkUqntDSevtTjlJRhix(p)kPKOAZuZus1mMWr6GXkcFnd(nEv3mK4HndHiBgowQ1mcQz4V5bYHqS1m1XsunD(j6RoVmpPSzkPAgKotsqQBgt(wuXmMC(nEndVVMXJhT4rBgKIy1nJpoQAQzQJLOA6)5xel4OOt1qiNkQe5zy8wInVfv0z(nETsGjl60VWcgfhXTyHw2fI6kRPrFxpTOULBhcXxYjhxf6wWBl0YUquxznn676Pf1Tl)4rtjr13HPzQJLOA6)5xPihhos7338gZQe5ziLC2gy11IJQMAx(XJM(ZCk((fsjNTbwDT4OQPwLKV0egH0IVPSqTPihhos7338gZKmR2xybJIJ4wSql7crDL10OVRNwu3YTdH4l5KJRcDl4TfAzxiQRSMg9D90I62LF8OPKO67W0m1Xsun9)8R8wurtLniJvjYZqk5SnWQRfhvn1U8Jhn9N5u89lKsoBdS6AXrvtTkjFHfmkoIBXcTSle1vwtJ(UEArDl3oeIVKtoUk0TG3wOLDHOUYAA031tlQBx(XJMsIQVdtZuhlr10)ZVWocPDSevRrbvuP9hEgxf6wWBQzQJLOA6)5xRsRDSevRrbvuP9hEgQO6KQqrNQsKNfhXTyHw2fI6kRPrFxpTOULBhcX3V4Qq3cEBHw2fI6kRPrFxpTOUD5hpA6pVBM6yjQM(F(1Q0Ahlr1AuqfvA)HNHkQwcmzrNQsKNVLyHw2fI6kRPrFxpTOUvcmzrNAM6yjQM(F(1Q0Ahlr1AuqfvA)HNliui86suTkrEgsjNTjbc5RUY68wuXQK8vCe3ITGqHWRlr1wUDieFntDSevt)p)AvATJLOAnkOIkT)WZEXQe5zhlXBSMB(jykjZQzM6yjQM(F(f2riTJLOAnkOIkT)WZuX7RVxZuZuhlr1uRx88Yp1szetPA4rl8QsKNfhXTytDHiVrNQPsTpwUDieFntDSevtTEX)NFLICC4iTFFZBmRsKNfhXTyZBrfkwDHiB52Hq81m1Xsun16f)F(vElQOPYgKXQe5zCvOBbVTl)ulLrmLQHhTWRD5hpA6pZQbdP47xXrCl2uxiYB0PAQu7JLBhcXxZuhlr1uRx8)5xel4OOt1qiNkQe5ziLC2UXdBvsmtDSevtTEX)NFL3IkuS6crwLipdPKZwYcek6u9JJjgnBvsmtDSevtTEX)NFLICC4iTFFZBmRsKNxLoW6KcoV2lNdCi)alvF)V4iUf7Q0bw7IWTIlr1wUDieFHHFHPzQJLOAQ1l()8R8wurtLniJvjYZRshyDsbNx7LZboKFGLQV)xCe3IDv6aRDr4wXLOAl3oeIVWWVW0m1Xsun16f)F(1Yp1szetPA4rl8AM6yjQMA9I)p)kVfvOy1fISzQJLOAQ1l()8RccfcVUWQe55vPdSoPGZR9Y5ahcjWsT3)loIBXUkDG1UiCR4suTLBhcXxy4xyAM6yjQMA9I)p)kf54WrA)(M3y2m1Xsun16f)F(vElQOPYgKXMPowIQPwV4)ZViwBRRSgE0cVMPowIQPwV4)ZV8f7nRLAxUfZuZus1miCzxiAgv2morFxpTOUzKufk6uZylXLOAZyczguXxHAgQbBQzaX5AzZG0eiKVMrLnJjFlQyg)ndcRJz4lBg(BEGCieBM6yjQMAHkQoPku0PZel4OOt1qiNkQe5ziLC2UXdBvsmtDSevtTqfvNufk60)ZVkiui86cRsKNxLMTs8WAP0t8Nu897Q0bwNuW51E5CGdHKz1E3m1Xsun1cvuDsvOOt)p)kf54WrA)(M3ywLipVkDG1jfCETxoh4q(rny)fxf6wWBBsGq(QRSoVfvSl)4rtjzvA2kXdRLspXV0egH0IVPSqTPihhos7338gZKmRMzQJLOAQfQO6KQqrN(F(vElQOPYgKXQe55vPdSoPGZR9Y5ahYpQb7V4Qq3cEBtceYxDL15TOID5hpAkjRsZwjEyTu6jAM6yjQMAHkQoPku0P)NFL3IkuS6crwLipdPKZwYcek6u9JJjgnBvs(UkDG1jfCETxoh4qibwQ((FXrCl2vPdS2fHBfxIQTC7qi(cd)cZV0egH0IVPSqT5TOcfRUqKjzwnZuhlr1ulur1jvHIo9)8R8wuHIvxiYQe55vPdSoPGZR9Y5ahcjZW633)loIBXUkDG1UiCR4suTLBhcXxy4xy(LMWiKw8nLfQnVfvOy1fImjZQzM6yjQMAHkQoPku0P)NFvqOq41fwLipVkDG1jfCETxoh4qizgw)((FXrCl2vPdS2fHBfxIQTC7qi(cd)ctZuhlr1ulur1jvHIo9)8RuKJdhP97BEJzvI8mUk0TG32KaH8vxzDElQyx(XJMsYQ0SvIhwlLEIFxLoW6KcoV2lNdCi)mry)LMWiKw8nLfQnf54WrA)(M3yMKz1mtDSevtTqfvNufk60)ZVYBrfnv2GmwLipJRcDl4TnjqiF1vwN3Ik2LF8OPKSknBL4H1sPN43vPdSoPGZR9Y5ahYpte2MPMPowIQPwOIQLatw0PZfekeEDHvjYZRshyDsbN3FM)f2MPowIQPwOIQLatw0P)NFT8tTugXuQgE0cVQe5zXrCl2uxiYB0PAQu7JLBhcXxZuhlr1ulur1sGjl60)ZViwWrrNQHqovujYZqk5SDJh2QKyM6yjQMAHkQwcmzrN(F(vbHcHxxyvI88Q0SvIhwlL(9FsXxYjFv6aRtk48(Z8eF3m1Xsun1cvuTeyYIo9)8R8wuHIvxiYQe5ziLC2swGqrNQFCmXOzRsYxAcJqAX3uwO28wuHIvxiYKmRMzQJLOAQfQOAjWKfD6)5xeRT1vwdpAHxvI88Q0bwNuW51E5CGdHK5FH93vPzRepSwk9VKKIVMPowIQPwOIQLatw0P)NFT8tTugXuQgE0cVMPowIQPwOIQLatw0P)NFL3IkuS6crwLipttyesl(MYc1M3IkuS6crMKz1mtDSevtTqfvlbMSOt)p)QGqHWRlSkrEEv6aRtk48AVCoWHqIAVto5RsZK8RzQJLOAQfQOAjWKfD6)5x(I9M1sTl3IkrEEv6aRtk48AVCoWHqIAW2m1mLunJjScDndISVIzGR(gsun1m1Xsun1Il0vtK9vMXe9OP6kRdmRsKNHuYzlUqxnr2xXsfhtgjV)v8nLfRepSwk9n4FsXxZuhlr1ulUqxnr2x5)8lmrpAQUY6aZQe5zybPKZ2KaH8vxzDElQyx(XJM(ZCk(cdWs1)4Qq3cEBZBrf4QVpuDwzv3USFvhMKtoKsoBtceYxDL15TOID5hpA6pRsZwjEyTu6FH5xiLC2MeiKV6kRZBrfRsIzQzQJLOAQfxf6wWB6ScL1HWpuvI8mUk0TG32KaH8vxzDElQyx2VQ)fwWO4iUfl0YUquxznn676Pf1TC7qi(so5qk5SLFsk48QxLM1WzpPARscmntDSevtT4Qq3cEt)p)sHY6q4hvA)HNxFsVknzunuKQx(QHuePAZuhlr1ulUk0TG30)ZVuOSoe(rL2F45hEzYeIovN9o1m1Xsun1IRcDl4n9)8RKsIQvjYZqk5SnjqiF1vwN3IkwLKVqk5SLFsk48QxLM1WzpPARsIzQJLOAQfxf6wWB6)5xqOQU6SYQUkrEgsjNTjbc5RUY68wuXQK8fsjNT8tsbNx9Q0Sgo7jvBvsmtDSevtT4Qq3cEt)p)cIxkVKfDQkrEgsjNTjbc5RUY68wuXQKyMsQMXKVfvmdCvOBbVPMPowIQPwCvOBbVP)NFLeiKV6kRZBrfvI8mUk0TG3w(jPGZREvAwdN9KQTl)4rtntDSevtT4Qq3cEt)p)cAzxiQRSMg9D90I6Qe5zCvOBbVT8tsbNx9Q0Sgo7jvBx(XJM(fxf6wWBBsGq(QRSoVfvSl)4rtntDSevtT4Qq3cEt)p)IFsk48QxLM1WzpPAvI8mUk0TG32KaH8vxzDElQyx2VQ)fgfhXTyHw2fI6kRPrFxpTOULBhcX3VRsZwjEyTu63jjfF)UkDG1jfCETxoh4qizwvyBM6yjQMAXvHUf8M(F(f)KuW5vVknRHZEs1Qe5zCvOBbVTjbc5RUY68wuXUSFv)R4iUfl0YUquxznn676Pf1TC7qi((DvAMK5F)UkDG1jfCEjH0cBZuhlr1ulUk0TG30)ZVWocPDSevRrbvuP9hEgxORMi7ROsKNfhXTyXf6QjY(kwUDieF)clybPKZwCHUAISVILkoMmsMvf2FVmKsoBxFsRnWSLkoMS53Hj5Kl(MYIvIhwlL(g8pZP4lmntDSevtT4Qq3cEt)p)kVfvGR((q1zLvDvI8mKsoBtceYxDL15TOID5hpA6pZP47xiLC2MeiKV6kRZBrfRsIzQzkPAgt4HqHWRlr1MXwIlr1MPowIQP2ccfcVUevpV8tTugXuQgE0cVQe5zXrCl2uxiYB0PAQu7JLBhcXxZuhlr1uBbHcHxxIQ)p)QGqHWRlSkrEggfhXTyZBrfkwDHiB52Hq89lmcPKZ2nEyRsYxAcJqAX3uwOwIfCu0PAiKtfsM)1m1Xsun1wqOq41LO6)ZVYBrfkwDHiRsKNHfKsoBjlqOOt1poMy0SDzhlKtoSGuYzlzbcfDQ(XXeJMTkjFHvYYVPtXxRQ28wurtLniJjN8KLFtNIVwvTel4OOt1qiNkKtEYYVPtXxRQ2uKJdhP97BEJzycty(LMWiKw8nLfQnVfvOy1fImjZQzM6yjQMAliui86su9)5xfekeEDHvjYZqk5SLSaHIov)4yIrZ2LDSqo5WcsjNTKfiu0P6hhtmA2QK8fwjl)MofFTQAZBrfnv2GmMCYtw(nDk(Av1sSGJIovdHCQqo5jl)MofFTQAtrooCK2VV5nMHjmntDSevtTfekeEDjQ()8RuKJdhP97BEJzvI8mSGriLC2UXdBvsiN8vPdSoPGZR9Y5ahYpQcBYjFvA2kXdRLsRgjP4lm)styesl(MYc1MICC4iTFFZBmtYSAMPowIQP2ccfcVUev)F(fXcok6uneYPIkrEgsjNTB8WwLKV0egH0IVPSqTel4OOt1qiNkKmRMzQJLOAQTGqHWRlr1)NFL3IkAQSbzSkrEggHuYz7gpSvjHCYxLoW6KcoV2lNdCi)OkSjN8vPzRepSwkTAKKIVMPowIQP2ccfcVUev)F(fXcok6uneYPIkrEgsjNTB8WwLeZuhlr1uBbHcHxxIQ)p)QGqHWRlSzQzkPAghX7RVxZGgDkIjLIVPSygBjUevBM6yjQMAPI3xFVZl)ulLrmLQHhTWRzQJLOAQLkEF99(F(vElQOPYgKXQe5zCvOBbVTl)ulLrmLQHhTWRD5hpA6pZQbdP47xXrCl2uxiYB0PAQu7JLBhcXxZuhlr1ulv8(679)8lIfCu0PAiKtfvI8mKsoB34HTkjMPowIQPwQ49137)5xfekeEDHvjYZWiKsoBZBnPCRtuqu2QK8vCe3InV1KYTorbrzl3oeIVMPowIQPwQ49137)5x5TOIMkBqgRsKNxLoW6KcoV2lNdCi)alvF)V4iUf7Q0bw7IWTIlr1wUDieFHHFHPzQJLOAQLkEF99(F(vElQqXQlezvI8mKsoBjlqOOt1poMy0Svj57Q0SvIhwlLEIKmNIVMPowIQPwQ49137)5xfekeEDHvjYZRshyDsbNx7LZboesGLAV)xCe3IDv6aRDr4wXLOAl3oeIVWWVW0m1Xsun1sfVV(E)p)kVfv0uzdYyZuhlr1ulv8(679)8lI126kRHhTWRzQJLOAQLkEF99(F(LVyVzTu7YTaeGaaa]] )


end
