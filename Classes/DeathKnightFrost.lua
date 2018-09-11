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


    spec:RegisterPack( "Frost DK", 20180902.2101, [[dW0EebqiiepcuOnPQQpHQQIrPsXPueTkiKEfemluvUfOa7Is)svXWuvXXqvSmuLEgeQPPsjxtvL2gQQW3qvv14uPuDovQI1HQkAEGIUNkzFqkhuLQuleI6HOQk1evPQ0fvPQyJQuv9ruvjXjbfuRur6LGcYmrvvj3evvj7eI8tuvvQHIQk1srvv8uvzQQkDvuvjPVIQkXEb(lfdwWHPAXG8yOMSkUmXMv4Zc1OHKtlA1OQsQxdPA2iDBf1UL63sgUqoUkvjwUsphLPt66OY2vPY3bvJxLQKoVIW6vPuMpO0(rmGhWxW74QaqI3F452)5E(HxlV8Wl)GhEapDIib8ICm6ESaETplG39VftjH7lme4f5tql)a(cESIBXc4Hs1ig)8ZN4urXbzX18hwoZrDnRgV(q)WYz8hiAb9bA4WGJC3NOTgjvyF(MYYlpF(YlpM7R4kkdmuNXOuZ9VftTSCgdEqCjvHHBae4DCvaiX7p8C7)Cp)WRLxE4LF8Z9aEoNIQwW7LZ83G3ryyWdgjH7FlMsc3xXvuKamuNXOuYuyKeqPAeJF(5tCQO4GS4A(dlN5OUMvJxFOFy5m(deTG(anCyWrU7t0wJKkSp87v4pEEyF438hZ9vCfLbgQZyuQ5(3IPwwoJjtHrs4jrQmdjljWlFKaV)WZTtcWas4E4N)8djWV5VitjtHrsG)gL3XcJFsMcJKamGeU3h(1CmDwALrcArc3h(d)cjOfj4yCX1kjmQLeOsS0hFNGe2SJTKPWijadib(nNsc8xzFiH7Ff52esaYXOtczBbpAYug4l4Hl6XGs8vbFbiXd4l4jTdrLdazWdVPkB6Ghe3yyXf9yqj(QwM6y0jb0iHFjH)KG6BSOwnNfJwMtkKamjHy8b8CSMvdEyuE2mtnmjwakajEbFbpPDiQCaidE4nvzth8UHeG4gdBusP(AQHzSftTRm7zZibyErcX4djGOKWnKapKacKaUk6PG32Xwmf(e7mZm42jSR4NjiHjjbyHLeG4gdBusP(AQHzSftTRm7zZibysclxlwnNfJwgetctsc)jbiUXWgLuQVMAygBXulxe45ynRg8WO8SzMAysSauGcEfenvzDnRg8fGepGVGN0oevoaKbp8MQSPdEQtLwTXUIs2SJnmT2zR0oevoGNJ1SAWBL5Azcvymd8SvzbkajEbFbpPDiQCaidE4nvzth8qesqDQ0QDSftz4juuIvAhIkhs4pjGiKae3yy3CwSCrKWFsGfjuQr9nwuMfvbNMDSbI6mLeq7Ieqm45ynRg8kiAQY6Qauasig8f8K2HOYbGm4H3uLnDW7gsaIBmSONuA2XMzhJkBXUIJvsawyjHBibiUXWIEsPzhBMDmQSflxej8NeUHeIw5otm(y5Xo2IPgMUj6cjalSKq0k3zIXhlpwufCA2XgiQZusawyjHOvUZeJpwESXuhNo14N78glKWKKWKKWKKWFsGfjuQr9nwuMDSftz4juucjG2fjWl45ynRg8gBXugEcfLauas3c8f8K2HOYbGm4H3uLnDWdIBmSONuA2XMzhJkBXUIJvsawyjHBibiUXWIEsPzhBMDmQSflxej8NeUHeIw5otm(y5Xo2IPgMUj6cjalSKq0k3zIXhlpwufCA2XgiQZusawyjHOvUZeJpwESXuhNo14N78glKWKKWKGNJ1SAWRGOPkRRcqbi9l4l4jTdrLdazWdVPkB6G3nKaIqcqCJHDZzXYfrcWcljSCDInrfCzThzK4ujbysc88djalSKWY1IvZzXOLHxsansigFiHjjH)KalsOuJ6BSOmBm1XPtn(5oVXcjG2fjWl45ynRg8IPooDQXp35nwakaj(b4l4jTdrLdazWdVPkB6Ghe3yy3CwSCrKWFsGfjuQr9nwuMfvbNMDSbI6mLeq7Ie4f8CSMvdEOk40SJnquNPafGe)h8f8K2HOYbGm4H3uLnDWdribiUXWU5Sy5IibyHLewUoXMOcUS2JmsCQKamjbE(HeGfwsy5AXQ5Sy0YWljGgjeJpGNJ1SAWBSftnmDt0fGcq62bFbpPDiQCaidE4nvzth8G4gd7MZILlc8CSMvdEOk40SJnquNPafG09a(cEowZQbVcIMQSUkGN0oevoaKbkqbpOIz0eJE2XGVaK4b8f8K2HOYbGm4H3uLnDWB56eBIk4YscW8Ieq8pGNJ1SAWRGOPkRRcqbiXl4l4jTdrLdazWdVPkB6GN6uPvBSROKn7ydtRD2kTdrLd45ynRg8wzUwMqfgZapBvwGcqcXGVGN0oevoaKbp8MQSPdEqCJHDZzXYfbEowZQbpufCA2XgiQZuGcq6wGVGN0oevoaKbp8MQSPdElxlwnNfJwMFjbyscX4djalSKWY1j2evWLLeG5fjCRFbphRz1GxbrtvwxfGcq6xWxWtAhIkhaYGhEtv20bpiUXWIEsPzhBMDmQSflxej8NeyrcLAuFJfLzhBXugEcfLqcODrc8cEowZQbVXwmLHNqrjafGe)a8f8K2HOYbGm4H3uLnDWB56eBIk4YApYiXPscODrci(hs4pjSCTy1CwmAzqmjGgjeJpGNJ1SAWdvTTPgg4zRYcuas8FWxWZXAwn4TYCTmHkmMbE2QSGN0oevoaKbkaPBh8f8K2HOYbGm4H3uLnDWJfjuQr9nwuMDSftz4juucjG2fjWl45ynRg8gBXugEcfLauas3d4l4jTdrLdazWdVPkB6G3Y1j2evWL1EKrItLeqJe49xsawyjHLRfsansaXGNJ1SAWRGOPkRRcqbiXZpGVGN0oevoaKbp8MQSPdElxNytubxw7rgjovsansG3FaphRz1GNVyVfJw7kTcuGcEqfZevfn7yWxas8a(cEs7qu5aqg8WBQYMo4bXng2nNflxe45ynRg8qvWPzhBGOotbkajEbFbpPDiQCaidE4nvzth8wUwSAolgTm3IeGjjeJpKWFsy56eBIk4YApYiXPscODrc8(l45ynRg8kiAQY6Qauasig8f8K2HOYbGm4H3uLnDWB56eBIk4YApYiXPscWKe49hs4pjGRIEk4TnkPuFn1Wm2IP2vM9SzKaAKWY1IvZzXOL5wKWFsGfjuQr9nwuMnM640Pg)CN3yHeq7Ie4f8CSMvdEXuhNo14N78glafG0TaFbpPDiQCaidE4nvzth8wUoXMOcUS2JmsCQKamjbE)He(tc4QONcEBJsk1xtnmJTyQDLzpBgjGgjSCTy1CwmAzUf45ynRg8gBXudt3eDbOaK(f8f8K2HOYbGm4H3uLnDWdIBmSONuA2XMzhJkBXYfrc)jHLRtSjQGlR9iJeNkjGgjCdjWZVKacKG6uPv7Y1j24QknNRz1wPDiQCibeLeqmjmjj8NeyrcLAuFJfLzhBXugEcfLqcODrc8cEowZQbVXwmLHNqrjafGe)a8f8K2HOYbGm4H3uLnDWB56eBIk4YApYiXPscODrc3qci(xsabsqDQ0QD56eBCvLMZ1SAR0oevoKaIsciMeMKe(tcSiHsnQVXIYSJTykdpHIsib0UibEbphRz1G3ylMYWtOOeGcqI)d(cEs7qu5aqg8WBQYMo4TCDInrfCzThzK4ujb0UiHBibe)ljGajOovA1UCDInUQsZ5AwTvAhIkhsarjbetctcEowZQbVcIMQSUkafG0Td(cEs7qu5aqg8WBQYMo4HRIEk4TnkPuFn1Wm2IP2vM9SzKaAKWY1IvZzXOL5wKWFsy56eBIk4YApYiXPscWKeU1pKWFsGfjuQr9nwuMnM640Pg)CN3yHeq7Ie4f8CSMvdEXuhNo14N78glafG09a(cEs7qu5aqg8WBQYMo4HRIEk4TnkPuFn1Wm2IP2vM9SzKaAKWY1IvZzXOL5wKWFsy56eBIk4YApYiXPscWKeU1pGNJ1SAWBSftnmDt0fGcuWlAfCnd5k4lajEaFbpPDiQCaiduas8c(cEs7qu5aqgOaKqm4l4jTdrLdazGcq6wGVGN0oevoaKbkaPFbFbphRz1GxuPz1GN0oevoaKbkqbpVeWxas8a(cEs7qu5aqg8WBQYMo4PovA1g7kkzZo2W0ANTs7qu5aEowZQbVvMRLjuHXmWZwLfOaK4f8f8K2HOYbGm4H3uLnDWtDQ0QDSftz4juuIvAhIkhWZXAwn4ftDC6uJFUZBSauasig8f8K2HOYbGm4H3uLnDWdxf9uWB7kZ1YeQWyg4zRYAxz2ZMrcW8Ie4LequsigFiH)KG6uPvBSROKn7ydtRD2kTdrLd45ynRg8gBXudt3eDbOaKUf4l4jTdrLdazWdVPkB6Ghe3yy3CwSCrGNJ1SAWdvbNMDSbI6mfOaK(f8f8K2HOYbGm4H3uLnDWdIBmSONuA2XMzhJkBXYfbEowZQbVXwmLHNqrjafGe)a8f8K2HOYbGm4H3uLnDWB56eBIk4YApYiXPscWKeUHe45xsabsqDQ0QD56eBCvLMZ1SAR0oevoKaIsciMeMe8CSMvdEXuhNo14N78glafGe)h8f8K2HOYbGm4H3uLnDWB56eBIk4YApYiXPscWKeUHe45xsabsqDQ0QD56eBCvLMZ1SAR0oevoKaIsciMeMe8CSMvdEJTyQHPBIUauas3o4l45ynRg8wzUwMqfgZapBvwWtAhIkhaYafG09a(cEowZQbVXwmLHNqrjGN0oevoaKbkajE(b8f8K2HOYbGm4H3uLnDWB56eBIk4YApYiXPscOrc3qc8(ljGajOovA1UCDInUQsZ5AwTvAhIkhsarjbetctcEowZQbVcIMQSUkafGep8a(cEowZQbVyQJtNA8ZDEJfWtAhIkhaYafGep8c(cEowZQbVXwm1W0nrxapPDiQCaiduas8GyWxWZXAwn4HQ22udd8SvzbpPDiQCaiduas8ClWxWZXAwn45l2BXO1UsRGN0oevoaKbkqbpM69X3d4lajEaFbphRz1G3kZ1YeQWyg4zRYcEs7qu5aqgOaK4f8f8K2HOYbGm4H3uLnDWdxf9uWB7kZ1YeQWyg4zRYAxz2ZMrcW8Ie4LequsigFiH)KG6uPvBSROKn7ydtRD2kTdrLd45ynRg8gBXudt3eDbOaKqm4l4jTdrLdazWdVPkB6Ghe3yy3CwSCrGNJ1SAWdvbNMDSbI6mfOaKUf4l4jTdrLdazWdVPkB6GhIqcqCJHDS1TjTjIJYelxej8NeuNkTAhBDBsBI4OmXkTdrLd45ynRg8kiAQY6Qauas)c(cEs7qu5aqg8WBQYMo4TCDInrfCzThzK4ujbysc3qc88ljGajOovA1UCDInUQsZ5AwTvAhIkhsarjbetctcEowZQbVXwm1W0nrxakaj(b4l4jTdrLdazWdVPkB6Ghe3yyrpP0SJnZogv2ILlIe(tclxlwnNfJwMBrcODrcX4d45ynRg8gBXugEcfLauas8FWxWtAhIkhaYGhEtv20bVLRtSjQGlR9iJeNkjGgjCdjW7VKacKG6uPv7Y1j24QknNRz1wPDiQCibeLeqmjmj45ynRg8kiAQY6Qauas3o4l45ynRg8gBXudt3eDb8K2HOYbGmqbiDpGVGNJ1SAWdvTTPgg4zRYcEs7qu5aqgOaK45hWxWZXAwn45l2BXO1UsRGN0oevoaKbkqbVJmCoQc(cqIhWxWZXAwn45CAzCvDm6GN0oevoaKbkajEbFbphRz1G3C2hZyf52eWtAhIkhaYafGeIbFbpPDiQCaidE4nvzth8qes4uQDSftnd5ozTAIrp7ys4pjCdjGiKG6uPvl0kUIYuddl7Z6XfZTs7qu5qcWcljGRIEk4TfAfxrzQHHL9z94I52vM9SzKaAKap)sctcEowZQbpufCA2XgiQZuGcq6wGVGN0oevoaKbp8MQSPdEqCJHnXtyuNwnZUYSNnJeG5fjeJpKWFsaIBmSjEcJ60QzwUis4pjWIek1O(glkZgtDC6uJFUZBSqcODrc8sc)jHBibeHeuNkTAHwXvuMAyyzFwpUyUvAhIkhsawyjbCv0tbVTqR4kktnmSSpRhxm3UYSNnJeqJe45xsysWZXAwn4ftDC6uJFUZBSauas)c(cEs7qu5aqg8WBQYMo4bXng2epHrDA1m7kZE2msaMxKqm(qc)jbiUXWM4jmQtRMz5IiH)KWnKaIqcQtLwTqR4kktnmSSpRhxm3kTdrLdjalSKaUk6PG3wOvCfLPggw2N1JlMBxz2ZMrcOrc88ljmj45ynRg8gBXudt3eDbOaK4hGVGN0oevoaKbphRz1Gh2PuJJ1SAdnzk4rtMAAFwapCv0tbVzafGe)h8f8K2HOYbGm4H3uLnDWtDQ0QfAfxrzQHHL9z94I5wPDiQCiH)KaUk6PG3wOvCfLPggw2N1JlMBxz2ZMrcWKe(f8CSMvdElxBCSMvBOjtbpAYut7Zc4bvmtuv0SJbkaPBh8f8K2HOYbGm4H3uLnDW7uQfAfxrzQHHL9z94I5wnXONDm45ynRg8wU24ynR2qtMcE0KPM2NfWdQygnXONDmqbiDpGVGN0oevoaKbp8MQSPdEqCJHnkPuFn1Wm2IPwUis4pjOovA1wq0uL11SAR0oevoGNJ1SAWB5AJJ1SAdnzk4rtMAAFwaVcIMQSUMvduas88d4l4jTdrLdazWdVPkB6GNJ18oXiTmNcJeq7Ie4f8CSMvdElxBCSMvBOjtbpAYut7Zc45Lauas8Wd4l4jTdrLdazWZXAwn4HDk14ynR2qtMcE0KPM2NfWJPEF89auGcE4QONcEZaFbiXd4l4jTdrLdazWdVPkB6GhUk6PG32OKs91udZylMAxXptqc)jHBibeHeuNkTAHwXvuMAyyzFwpUyUvAhIkhsawyjbiUXWkZrfCznlxlg4IhvTLlIeMe8CSMvdECmXKQmZakajEbFbpPDiQCaidETplG3632HRrNzGYyZkhdeNQvdEowZQbV1VTdxJoZaLXMvogiovRgOaKqm4l4jTdrLdazWR9zb8MLvqxr5mZW7yWZXAwn4nlRGUIYzMH3XafG0TaFbpPDiQCaidE4nvzth8G4gdBusP(AQHzSftTCrKWFsaIBmSYCubxwZY1IbU4rvB5IaphRz1GxuPz1afG0VGVGN0oevoaKbp8MQSPdEqCJHnkPuFn1Wm2IPwUis4pjaXngwzoQGlRz5AXax8OQTCrGNJ1SAWdIw1Xm42jakaj(b4l4jTdrLdazWdVPkB6Ghe3yyJsk1xtnmJTyQLlc8CSMvdEqYYKf9SJbkaj(p4l4jTdrLdazWdVPkB6Ghe3yyL5OcUSMLRfdCXJQ2YfrcWcljGRIEk4TvMJk4YAwUwmWfpQA7kZE2mWZXAwn4fLuQVMAygBXuGcq62bFbpPDiQCaidE4nvzth8UHeG4gdRmhvWL1SCTyGlEu1wUisawyjbCv0tbVTYCubxwZY1IbU4rvBxz2ZMrctsc)jbCv0tbVTrjL6RPgMXwm1UYSNnd8CSMvdEqR4kktnmSSpRhxmhOaKUhWxWtAhIkhaYGhEtv20bpCv0tbVTrjL6RPgMXwm1UIFMGe(tcicjOovA1cTIROm1WWY(SECXCR0oevoKWFsy5AXQ5Sy0Y8ljGgjeJpKWFsy56eBIk4YApYiXPscODrc88d45ynRg8K5OcUSMLRfdCXJQgOaK45hWxWtAhIkhaYGhEtv20bpCv0tbVTrjL6RPgMXwm1UIFMGe(tcQtLwTqR4kktnmSSpRhxm3kTdrLdj8NeUHeUHeWvrpf82cTIROm1WWY(SECXC7kZE2msansyfmkFJfJMZcjmjjalSKWnKaUk6PG3wOvCfLPggw2N1JlMBxXptqc)jHLRfsaTlsaXKWFsy56eBIk4YscOrc8JFiHjjHjbphRz1GNmhvWL1SCTyGlEu1afGep8a(cEs7qu5aqg8WBQYMo4Ddji3lCzuKCS4IEmOeFvsawyjb1PsRwCrpguIVQvAhIkhsyss4pjCdjCdjCdjaXngwCrpguIVQjvz2YuhJojG2fjWZpKaSWscqCJHfx0JbL4RAuNkTAzQJrNeq7Ie45hsyss4pjCeiUXWU(TvBIfltDm6KWfj8ljmjjalSKG6BSOwnNfJwMtkKamViHy8HeMe8CSMvdEyNsnowZQn0KPGhnzQP9zb8Wf9yqj(QafGep8c(cEs7qu5aqg8WBQYMo4bXng2OKs91udZylMAxz2ZMrcW8IeIXhs4pjaXng2OKs91udZylMA5IaphRz1G3ylMcFIDMzgC7eafOaf8UtwwwnajE)HNB)NBhX)y5LhE5f8G7BNDmd84xU38hKGHrIFf(jjqcFrjKqohvRscJAjb(NJmCoQY)qcRCVWLRCibwnlKGZP1SRYHeWO8owywYu(xzlKap8tsGF1MXffvRkhsWXAwnjW)4CAzCvDm68pwYuYuy45OAv5qc3dj4ynRMeOjtzwYuWJfjyas8(lpGx0wJKkGhmsc3)wmLeUVIROibyOoJrPKPWijGs1ig)8ZN4urXbzX18hwoZrDnRgV(q)WYz8hiAb9bA4WGJC3NOTgjvyF43RWF88W(WV5pM7R4kkdmuNXOuZ9VftTSCgtMcJKWtIuzgswsGx(ibE)HNBNeGbKW9Wp)5hsGFZFrMsMcJKa)nkVJfg)KmfgjbyajCVp8R5y6S0kJe0IeUp8h(fsqlsWX4IRvsyuljqLyPp(objSzhBjtHrsagqc8BoLe4VY(qc3)kYTjKaKJrNeY2sMsMcJKW95EvWCQCibizuRqc4AgYvsasIZMzjH7nglrkJe6QHbO8DEWrjbhRz1msOA6ewYuhRz1mB0k4AgY1Rb1zOtM6ynRMzJwbxZqUIW1NrvhYuhRz1mB0k4AgYveU(4CXZsRUMvtMcJKWR9igQsjH1ZdjaXngYHeyQRmsasg1kKaUMHCLeGK4SzKG3hsiAfyquPA2XKqYiHt1ILm1XAwnZgTcUMHCfHRpS2JyOk1WuxzKPowZQz2OvW1mKRiC9jQ0SAYuYuyKeUp3RcMtLdji3j7eKGMZcjOOesWXATKqYib)opPoevSKPowZQzxoNwgxvhJozQJ1SAgcxFMZ(ygRi3MqMcJKW9okIobjC)BXus4(L7KLe8(qcZE2QNnjadJNGe(60QzKPowZQziC9bvbNMDSbI6mLVCCHiNsTJTyQzi3jRvtm6zh))gerDQ0QfAfxrzQHHL9z94I5wPDiQCGfwCv0tbVTqR4kktnmSSpRhxm3UYSNndnE(DsYuhRz1meU(etDC6uJFUZBSWxoUG4gdBINWOoTAMDLzpBgmVIXN)qCJHnXtyuNwnZYf9NfjuQr9nwuMnM640Pg)CN3ybTlE)FdIOovA1cTIROm1WWY(SECXCR0oevoWclUk6PG3wOvCfLPggw2N1JlMBxz2ZMHgp)ojzQJ1SAgcxFgBXudt3eDHVCCbXng2epHrDA1m7kZE2myEfJp)H4gdBINWOoTAMLl6)niI6uPvl0kUIYuddl7Z6XfZTs7qu5alS4QONcEBHwXvuMAyyzFwpUyUDLzpBgA887KKPowZQziC9b7uQXXAwTHMmLV2NLlCv0tbVzKPowZQziC9z5AJJ1SAdnzkFTplxqfZevfn7y(YXL6uPvl0kUIYuddl7Z6XfZTs7qu58hxf9uWBl0kUIYuddl7Z6XfZTRm7zZG5VKPowZQziC9z5AJJ1SAdnzkFTplxqfZOjg9SJ5lhxNsTqR4kktnmSSpRhxm3Qjg9SJjtDSMvZq46ZY1ghRz1gAYu(AFwUkiAQY6AwnF54cIBmSrjL6RPgMXwm1Yf9xDQ0QTGOPkRRz1wPDiQCitDSMvZq46ZY1ghRz1gAYu(AFwU8s4lhxowZ7eJ0YCkm0U4Lm1XAwndHRpyNsnowZQn0KP81(SCXuVp(EitjtDSMvZSEjxRmxltOcJzGNTklF54sDQ0Qn2vuYMDSHP1oBL2HOYHm1XAwnZ6LGW1NyQJtNA8ZDEJf(YXL6uPv7ylMYWtOOeR0oevoKPowZQzwVeeU(m2IPgMUj6cF54cxf9uWB7kZ1YeQWyg4zRYAxz2ZMbZlEr0y85V6uPvBSROKn7ydtRD2kTdrLdzQJ1SAM1lbHRpOk40SJnquNP8LJliUXWU5Sy5IitDSMvZSEjiC9zSftz4juucF54cIBmSONuA2XMzhJkBXYfrM6ynRMz9sq46tm1XPtn(5oVXcF54A56eBIk4YApYiXPcZB45xeuNkTAxUoXgxvP5CnR2kTdrLdII4jjtDSMvZSEjiC9zSftnmDt0f(YX1Y1j2evWL1EKrItfM3WZViOovA1UCDInUQsZ5AwTvAhIkhefXtsM6ynRMz9sq46ZkZ1YeQWyg4zRYsM6ynRMz9sq46ZylMYWtOOeYuhRz1mRxccxFkiAQY6QWxoUwUoXMOcUS2JmsCQODdV)IG6uPv7Y1j24QknNRz1wPDiQCquepjzQJ1SAM1lbHRpXuhNo14N78glKPowZQzwVeeU(m2IPgMUj6czQJ1SAM1lbHRpOQTn1WapBvwYuhRz1mRxccxF8f7Ty0AxPvYuYuyKeqEfxrrc1GeEzFwpUyojevfn7ysyl11SAsGFscm1xLrc8(dJeGKrTcjWVtk1xsOgKW9VftjbeibKRhj4Rqc(DEsDiQqM6ynRMzHkMjQkA2XxOk40SJnquNP8LJliUXWU5Sy5IitDSMvZSqfZevfn7yeU(uq0uL1vHVCCTCTy1CwmAzUfmJXN)lxNytubxw7rgjov0U49xYuhRz1mluXmrvrZogHRpXuhNo14N78gl8LJRLRtSjQGlR9iJeNkm59N)4QONcEBJsk1xtnmJTyQDLzpBgAlxlwnNfJwMB9NfjuQr9nwuMnM640Pg)CN3ybTlEjtDSMvZSqfZevfn7yeU(m2IPgMUj6cF54A56eBIk4YApYiXPctE)5pUk6PG32OKs91udZylMAxz2ZMH2Y1IvZzXOL5wKPowZQzwOIzIQIMDmcxFgBXugEcfLWxoUG4gdl6jLMDSz2XOYwSCr)xUoXMOcUS2JmsCQODdp)IG6uPv7Y1j24QknNRz1wPDiQCquep5FwKqPg13yrz2XwmLHNqrjODXlzQJ1SAMfQyMOQOzhJW1NXwmLHNqrj8LJRLRtSjQGlR9iJeNkAx3G4FrqDQ0QD56eBCvLMZ1SAR0oevoikIN8plsOuJ6BSOm7ylMYWtOOe0U4Lm1XAwnZcvmtuv0SJr46tbrtvwxf(YX1Y1j2evWL1EKrItfTRBq8ViOovA1UCDInUQsZ5AwTvAhIkhefXtsM6ynRMzHkMjQkA2XiC9jM640Pg)CN3yHVCCHRIEk4TnkPuFn1Wm2IP2vM9SzOTCTy1CwmAzU1)LRtSjQGlR9iJeNkmV1p)zrcLAuFJfLzJPooDQXp35nwq7IxYuhRz1mluXmrvrZogHRpJTyQHPBIUWxoUWvrpf82gLuQVMAygBXu7kZE2m0wUwSAolgTm36)Y1j2evWL1EKrItfM36hYuYuhRz1mluXmAIrp74RcIMQSUk8LJRLRtSjQGllmVq8pKPowZQzwOIz0eJE2XiC9zL5Azcvymd8Svz5lhxQtLwTXUIs2SJnmT2zR0oevoKPowZQzwOIz0eJE2XiC9bvbNMDSbI6mLVCCbXng2nNflxezQJ1SAMfQygnXONDmcxFkiAQY6QWxoUwUwSAolgTm)cZy8bwyxUoXMOcUSW86w)sM6ynRMzHkMrtm6zhJW1NXwmLHNqrj8LJliUXWIEsPzhBMDmQSflx0FwKqPg13yrz2XwmLHNqrjODXlzQJ1SAMfQygnXONDmcxFqvBBQHbE2QS8LJRLRtSjQGlR9iJeNkAxi(N)lxlwnNfJwgeJwm(qM6ynRMzHkMrtm6zhJW1NvMRLjuHXmWZwLLm1XAwnZcvmJMy0ZogHRpJTykdpHIs4lhxSiHsnQVXIYSJTykdpHIsq7IxYuhRz1mluXmAIrp7yeU(uq0uL1vHVCCTCDInrfCzThzK4urJ3FHf2LRf0qmzQJ1SAMfQygnXONDmcxF8f7Ty0AxPv(YX1Y1j2evWL1EKrItfnE)HmLmfgjb(7IEibuIVkjGR(KAwnJm1XAwnZIl6XGs8vVWO8SzMAysSWxoUG4gdlUOhdkXx1YuhJoA)(x9nwuRMZIrlZjfygJpKPowZQzwCrpguIVkcxFWO8SzMAysSWxoUUbIBmSrjL6RPgMXwm1UYSNndMxX4dIEdpiGRIEk4TDSftHpXoZmdUDc7k(zIjHfwiUXWgLuQVMAygBXu7kZE2myUCTy1CwmAzq8K)H4gdBusP(AQHzSftTCrKPKPowZQzwCv0tbVzxCmXKQmZ4lhx4QONcEBJsk1xtnmJTyQDf)mX)Bqe1PsRwOvCfLPggw2N1JlMBL2HOYbwyH4gdRmhvWL1SCTyGlEu1wUOjjtDSMvZS4QONcEZq46dhtmPkZ81(SCT(TD4A0zgOm2SYXaXPA1KPowZQzwCv0tbVziC9HJjMuLz(AFwUMLvqxr5mZW7yYuhRz1mlUk6PG3meU(evAwnF54cIBmSrjL6RPgMXwm1Yf9hIBmSYCubxwZY1IbU4rvB5IitDSMvZS4QONcEZq46deTQJzWTtWxoUG4gdBusP(AQHzSftTCr)H4gdRmhvWL1SCTyGlEu1wUiYuhRz1mlUk6PG3meU(ajltw0ZoMVCCbXng2OKs91udZylMA5IitHrs4(3IPKaUk6PG3mYuhRz1mlUk6PG3meU(eLuQVMAygBXu(YXfe3yyL5OcUSMLRfdCXJQ2YfblS4QONcEBL5OcUSMLRfdCXJQ2UYSNnJmfgjH7ngxCTscJAjH7d)HFHeOsS0hFNGe2SJjHCqcPscmnPusWJIOPWSKPowZQzwCv0tbVziC9bAfxrzQHHL9z94I58LJRBG4gdRmhvWL1SCTyGlEu1wUiyHfxf9uWBRmhvWL1SCTyGlEu12vM9Szt(hxf9uWBBusP(AQHzSftTRm7zZitDSMvZS4QONcEZq46JmhvWL1SCTyGlEu18LJlCv0tbVTrjL6RPgMXwm1UIFM4pIOovA1cTIROm1WWY(SECXCR0oevo)xUwSAolgTm)Iwm(8F56eBIk4YApYiXPI2fp)qMcJKam8GeGlKa2BsGJjKW9H)WVqcEFibu(DcjKkjmQLeA5EvjbKxXvu8rcXfj4Oe)yjbsG)Lel9X3jiHn7ysaLqJywYuhRz1mlUk6PG3meU(iZrfCznlxlg4IhvnF54cxf9uWBBusP(AQHzSftTR4Nj(RovA1cTIROm1WWY(SECXCR0oevo)V5gCv0tbVTqR4kktnmSSpRhxm3UYSNndTvWO8nwmAoltclS3GRIEk4TfAfxrzQHHL9z94I52v8Ze)xUwq7cX)xUoXMOcUSOXp(zYjjtDSMvZS4QONcEZq46d2PuJJ1SAdnzkFTplx4IEmOeFv(YX1nY9cxgfjhlUOhdkXxfwyvNkTAXf9yqj(QwPDiQCM8)n3Cde3yyXf9yqj(QMuLzltDm6ODXZpWcle3yyXf9yqj(Qg1PsRwM6y0r7INFM8)rG4gd763wTjwSm1XOF97KWcR6BSOwnNfJwMtkW8kgFMKm1XAwnZIRIEk4ndHRpJTyk8j2zMzWTtWxoUG4gdBusP(AQHzSftTRm7zZG5vm(8hIBmSrjL6RPgMXwm1YfrMsMcJKa)BiAQY6AwnjSL6AwnzQJ1SAMTGOPkRRz1xRmxltOcJzGNTklF54sDQ0Qn2vuYMDSHP1oBL2HOYHm1XAwnZwq0uL11SAeU(uq0uL1vHVCCHiQtLwTJTykdpHIsSs7qu58hrG4gd7MZILl6plsOuJ6BSOmlQcon7yde1zkAxiMm1XAwnZwq0uL11SAeU(m2IPm8ekkHVCCDde3yyrpP0SJnZogv2IDfhRWc7nqCJHf9KsZo2m7yuzlwUO)3eTYDMy8XYJDSftnmDt0fyHnAL7mX4JLhlQcon7yde1zkSWgTYDMy8XYJnM640Pg)CN3yzYjN8plsOuJ6BSOm7ylMYWtOOe0U4Lm1XAwnZwq0uL11SAeU(uq0uL1vHVCCbXngw0tkn7yZSJrLTyxXXkSWEde3yyrpP0SJnZogv2ILl6)nrRCNjgFS8yhBXudt3eDbwyJw5otm(y5XIQGtZo2arDMclSrRCNjgFS8yJPooDQXp35nwMCsYuhRz1mBbrtvwxZQr46tm1XPtn(5oVXcF546gebIBmSBolwUiyHD56eBIk4YApYiXPctE(bwyxUwSAolgTm8Iwm(m5FwKqPg13yrz2yQJtNA8ZDEJf0U4Lm1XAwnZwq0uL11SAeU(GQGtZo2arDMYxoUG4gd7MZILl6plsOuJ6BSOmlQcon7yde1zkAx8sM6ynRMzliAQY6AwncxFgBXudt3eDHVCCHiqCJHDZzXYfblSlxNytubxw7rgjovyYZpWc7Y1IvZzXOLHx0IXhYuhRz1mBbrtvwxZQr46dQcon7yde1zkF54cIBmSBolwUiYuhRz1mBbrtvwxZQr46tbrtvwxfYuYuyKeEQ3hFpKal7yQaduFJfLe2sDnRMm1XAwnZYuVp(EUwzUwMqfgZapBvwYuhRz1mlt9(47bHRpJTyQHPBIUWxoUWvrpf82UYCTmHkmMbE2QS2vM9SzW8IxengF(RovA1g7kkzZo2W0ANTs7qu5qM6ynRMzzQ3hFpiC9bvbNMDSbI6mLVCCbXng2nNflxezQJ1SAMLPEF89GW1NcIMQSUk8LJlebIBmSJTUnPnrCuMy5I(RovA1o262K2eXrzIvAhIkhYuhRz1mlt9(47bHRpJTyQHPBIUWxoUwUoXMOcUS2JmsCQW8gE(fb1PsR2LRtSXvvAoxZQTs7qu5GOiEsYuhRz1mlt9(47bHRpJTykdpHIs4lhxqCJHf9KsZo2m7yuzlwUO)lxlwnNfJwMBH2vm(qM6ynRMzzQ3hFpiC9PGOPkRRcF54A56eBIk4YApYiXPI2n8(lcQtLwTlxNyJRQ0CUMvBL2HOYbrr8KKPowZQzwM69X3dcxFgBXudt3eDHm1XAwnZYuVp(Eq46dQABtnmWZwLLm1XAwnZYuVp(Eq46JVyVfJw7kTcuGcaa]] )


end
