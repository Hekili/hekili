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
            resource = 'runes',

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
            local r = runes
            r.actual = nil

            r.spend( amt )

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

    local gainHook = function( amt, resource )
        if resource == 'runes' then
            local r = runes
            r.actual = nil

            r.gain( amt )
        end
    end

    spec:RegisterHook( "gain", gainHook )

    
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


    --[[ spec:RegisterStateExpr( "runes", function ()
        return rune
    end ) ]]


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
            
            recheck = function () return target.time_to_die - gcd, buff.pillar_of_frost.remains - 1.5 * gcd, buff.pillar_of_frost.remains - gcd, buff.pillar_of_frost.remains - ( gcd * ( 1 + ( cooldown.frostwyrms_fury.remains == 0 and 1 or 0 ) ) ) end,
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
            charges = function () return 1 + ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1 or 0 ) end,
            cooldown = function () return 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
            recharge = function () return 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 135372,
            
            recheck = function () return cooldown.pillar_of_frost.remains, gcd - runes.time_to_5, runic_power[ "time_to_" .. ( runic_power.max - 10 ) ], runes.time_to_3, runic_power.time_to_61 end,
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
            
            recheck = function () return buff.rime.remains, runic_power[ "time_to_" .. ( runic_power.max - 9 ) ], gcd - runes.time_to_2, buff.icy_talons.remains - gcd, runic_power[ "time_to_" .. ( runic_power.max - 39 ) ], cooldown.remorseless_winter.remains - 2 * gcd, runic_power[ "time_to_" .. ( runic_power.max - ( 15 + talent.runic_attenuation.rank * 3 ) ) ], runic_power[ "time_to_" .. ( runic_power.max - 19 ) ] end,
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
            
            recheck = function () return buff.pillar_of_frost.remains - gcd end,
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
            
            recheck = function () return buff.rime.remains, runic_power[ "time_to_" .. ( runic_power.max - 9 ) ], buff.icy_talons.remains - gcd, runic_power[ "time_to_" .. ( runic_power.max - 39 ) ], runic_power[ "time_to_" .. ( 15 + talent.runic_attenuation.rank * 3 ) ], runic_power[ "time_to_" .. ( runic_power.max - 20 ) ] end,
            handler = function ()
                applyDebuff( "target", "razorice" )
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
                applyDebuff( "target", "razorice", 20, debuff.razorice.stack + 2 )
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
        damageExpiration = 8,
    
        package = "Frost DK",
    } )


    spec:RegisterPack( "Frost DK", 20180719.0835, [[dOeocbqivf1JuusBcu5tkkfnkffNsr0QGQIxPQQzrrClfLk2Li)cQyyQQ0XGQSmkQEguvnnkkDnvf2guvQVPOeJtvr6CuuW6uuQ07GQsI5PQI7PsTpOshKIcXcHIEOQIOjQOuWfPOqTrkkQrQOuLtQQiSsfPxcvLu7eu1pHQsmufLcTufLsEQQmvfvFvrPuNfQkjTxG)sPbJQdt1Ib5XinzvCzInRWNfvJgkDAHxdfMnIBRs2Tu)wYWfLJtrH0Yv65OmDsxNcBxr47GY4vuQQZtrA9uuK5RQ0(HmapWCW74QaG38FX7t)DwWZmK(9tX)SywZbp10mb8YCkgEUaETFjGNzElMI4ZgWxdEzUPKYpG5GhRmwQaEyvnJn7Ido5HI1akrRlCyXLbX1OA66dfhwCrXbIuq4an8zNJmbozBncIWWzEiR54HZCZXZoBqCfRfFDh5yvRzElMMyXff8GmcI(jAae4DCvaWB(V49P)ol4zgs)(PMpl49b45gk2AbVzpbJGei(mJTUq8xC9jNe8ocJcEZXgmepyiUJ4zofdpxq8AG4ovJQrCsWugIpQfXN9emcsKqtrtXxTmqCFfepBlihIykINxrNJ4AH4qcIZm2SnyYbXHmfXvScIxzsll(ki(NaXH5SeIJ44lqKqnbXXxGiHAcIJVarc1eehFbIeQjiUz8S1SnIpeHWq86CqCidfXdgItRMfmvAfXHfkwe)fxFseFgyyLgXNTIlbXpLW6ztfXZ2IozcXr85yL2ee30YaXVCtrCS(ecIRfIdZdfXzYeY6eeNj0QpmeFulIVgTWqCizuRG4MwgiEwLH4MXZwZ2j0u00PgetrC8mdZUioIBMJzF5G4oI)jlYbXN9eFvexADnfXvSUI4WCgI3LI4QW0OZr8STYKLyAcXr85ydgIZWwgKdItDdMG4FsSE0meVgi(NGkiUwiUNLj(I4UI4kwbXL(G41aXDeF2yqi(I41aXnZBXuehw0NcgIhde30Yy2Cfe3GfDoIRyfeNi5sF81ueVwexDI0AcnfnD2wMnjeeNjcIhdexXkiUt1OAeNemLH4YefzcbXRjKfX14ssGhjykdmh8Of5yXk(QG5a4Xdmh8K2HiYbGj4r3qLnCWBgehYyms0ICSyfFvBOYvIPofdehxe)de)7xehYyms0ICSyfFvR6eP1etDkgioUi(hi(KioCiU6BUOjnUeRw2tii(piEo9aEovJQbpkwpAMTg2GkafaV5G5GN0oeroambp6gQSHdEZG4qgJrklieFT1Wo2IPPvU8Ozi(p3iEo9G44dIpdIJhI)hXNbXPvrofSon2IPWmDVy2HXAAAf)ykIdhIJhI)9lI)lIpjIpjI)9lIdzmgPSGq81wd7ylMMw5YJMH4)G4RrljnUeRww8J4tI4WH4qgJrklieFT1Wo2IPjJmWZPAun4rX6rZS1WgubOaf8kisOY6AunyoaE8aZbpPDiICaycE0nuzdh8uNiTMYDfRSrNBzATxjPDiICapNQr1G3kx1YeIWywyrRYcua8MdMdEs7qe5aWe8OBOYgo49zexDI0AASftzutvSssAhIihehoe)ZioKXyK24ssgzioCioltieR6BUOSe2cgj6CleXzkIJ7nIJFWZPAun4vqKqL1vbOa4Xpyo4jTdrKdatWJUHkB4G3mioKXyKWiiKOZTxofB0sAfNQi(3Vi(mioKXyKWiiKOZTxofB0sYidXHdXNbXZwzcBo9KWln2IPwMUbgcI)9lINTYe2C6jHxcBbJeDUfI4mfX)(fXZwzcBo9KWlLtCA4eRFMWBQG4tI4tI4tI4WH4ZG4RrljnUeRwwZI44I450dI)9lIZYecXQ(Mlkln2IPmQPkwbXX9gXnhXNe8CQgvdEJTykJAQIvakaEZcMdEs7qe5aWe8OBOYgo4bzmgjmccj6C7LtXgTKwXPkI)9lIpdIdzmgjmccj6C7LtXgTKmYqC4q8zq8SvMWMtpj8sJTyQLPBGHG4F)I4zRmHnNEs4LWwWirNBHiotr8VFr8SvMWMtpj8s5eNgoX6Nj8Mki(Ki(KGNt1OAWRGiHkRRcqbW)byo4jTdrKdatWJUHkB4G3mi(NrCiJXiTXLKmYq8VFr81OdQnRGjB6iJGgkI)dIJ3Vi(3Vi(A0ssJlXQL1CehxepNEq8jrC4qCwMqiw13CrzPCItdNy9ZeEtfeh3Be3CWZPAun4LtCA4eRFMWBQaua84BWCWtAhIihaMGhDdv2WbpiJXiTXLKmYqC4qCwMqiw13CrzjSfms05wiIZueh3Be3CWZPAun4HTGrIo3crCMcua8Zcyo4jTdrKdatWJUHkB4G3NrCiJXiTXLKmYq8VFr81OdQnRGjB6iJGgkI)dIJ3Vi(3Vi(A0ssJlXQL1CehxepNEapNQr1G3ylMAz6gyiafa)NcMdEs7qe5aWe8OBOYgo4bzmgPnUKKrg45unQg8WwWirNBHiotbkaEZayo45unQg8kisOY6QaEs7qe5aWeOaf8GkMvdkgrNdMdGhpWCWtAhIihaMGhDdv2WbV1OdQnRGjlI)ZnIJ)FbpNQr1GxbrcvwxfGcG3CWCWtAhIihaMGhDdv2Wbp1jsRPCxXkB05wMw7vsAhIihWZPAun4TYvTmHimMfw0QSafap(bZbpPDiICaycE0nuzdh8GmgJ0gxsYid8CQgvdEylyKOZTqeNPafaVzbZbpPDiICaycE0nuzdh8wJwsACjwTSFG4)G450dI)9lIVgDqTzfmzr8FUrCZ(b45unQg8kisOY6Qaua8FaMdEs7qe5aWe8OBOYgo4bzmgjmccj6C7LtXgTKmYapNQr1G3ylMYOMQyfGcGhFdMdEs7qe5aWe8OBOYgo4TgDqTzfmzthze0qrCCVrC8)lIdhIVgTK04sSAzXpIJlINtpGNt1OAWdBTTTgwyrRYcua8Zcyo45unQg8w5QwMqegZclAvwWtAhIihaMafa)NcMdEs7qe5aWe8OBOYgo4XYecXQ(Mlkln2IPmQPkwbXX9gXnh8CQgvdEJTykJAQIvakaEZayo4jTdrKdatWJUHkB4G3A0b1MvWKnDKrqdfXXfXn)de)7xeFnAbXXfXXp45unQg8kisOY6Qaua849lyo4jTdrKdatWJUHkB4G3A0b1MvWKnDKrqdfXXfXn)xWZPAun45l1BXQ1UsRafOGhuXSzvrIohmhapEG5GN0oeroambp6gQSHdEqgJrAJljzKbEovJQbpSfms05wiIZuGcG3CWCWtAhIihaMGhDdv2WbV1OLKgxIvlRzr8Fq8C6bXHdXxJoO2ScMSPJmcAOioU3iU5FaEovJQbVcIeQSUkafap(bZbpPDiICaycE0nuzdh8wJoO2ScMSPJmcAOi(piU5)I4WH40QiNcwNYccXxBnSJTyAALlpAgIJlIVgTK04sSAznl45unQg8YjonCI1pt4nvakaEZcMdEs7qe5aWe8OBOYgo4TgDqTzfmzthze0qr8FqCZ)fXHdXPvrofSoLfeIV2AyhBX00kxE0mehxeFnAjPXLy1YAwWZPAun4n2IPwMUbgcqbW)byo4jTdrKdatWJUHkB4GhKXyKWiiKOZTxofB0sYidXHdXxJoO2ScMSPJmcAOioUi(mioEFG4)rC1jsRP1OdQ1vvAdxJQtR3yG44dIJFeFsWZPAun4n2IPmQPkwbOa4X3G5GN0oeroambp6gQSHdERrhuBwbt20rgbnueh3BeFge38pq8)iU6eP10A0b16QkTHRr1P1BmqC8bXXpIpj45unQg8kisOY6Qaua8Zcyo4jTdrKdatWJUHkB4GhTkYPG1PSGq81wd7ylMMw5YJMH44I4RrljnUeRwwZI4WH4RrhuBwbt20rgbnue)he3S)I4WH4SmHqSQV5IYs5eNgoX6Nj8MkioU3iU5GNt1OAWlN40Wjw)mH3ubOa4)uWCWtAhIihaMGhDdv2WbpAvKtbRtzbH4RTg2XwmnTYLhndXXfXxJwsACjwTSMfXHdXxJoO2ScMSPJmcAOi(piUz)f8CQgvdEJTyQLPBGHauGcEzRqRlixbZbWJhyo4jTdrKdatGcG3CWCWtAhIihaMafap(bZbpPDiICaycua8Mfmh8K2HiYbGjqbW)byo45unQg8YknQg8K2HiYbGjqbk45LaMdGhpWCWtAhIihaMGhDdv2Wbp1jsRPCxXkB05wMw7vsAhIihWZPAun4TYvTmHimMfw0QSafaV5G5GN0oeroambp6gQSHdEQtKwtJTykJAQIvss7qe5aEovJQbVCItdNy9ZeEtfGcGh)G5GN0oeroambp6gQSHdE0QiNcwNw5QwMqegZclAv20kxE0me)NBe3CehFq8C6bXHdXvNiTMYDfRSrNBzATxjPDiICapNQr1G3ylMAz6gyiafaVzbZbpPDiICaycE0nuzdh8GmgJ0gxsYid8CQgvdEylyKOZTqeNPafa)hG5GN0oeroambp6gQSHdEqgJrcJGqIo3E5uSrljJmWZPAun4n2IPmQPkwbOa4X3G5GN0oeroambp6gQSHdERrhuBwbt20rgbnue)heFgehVpq8)iU6eP10A0b16QkTHRr1P1BmqC8bXXpIpj45unQg8YjonCI1pt4nvaka(zbmh8K2HiYbGj4r3qLnCWBn6GAZkyYMoYiOHI4)G4ZG449bI)hXvNiTMwJoOwxvPnCnQoTEJbIJpio(r8jbpNQr1G3ylMAz6gyiafa)NcMdEovJQbVvUQLjeHXSWIwLf8K2HiYbGjqbWBgaZbpNQr1G3ylMYOMQyfWtAhIihaMafapE)cMdEs7qe5aWe8OBOYgo4TgDqTzfmzthze0qrCCr8zqCZ)aX)J4QtKwtRrhuRRQ0gUgvNwVXaXXheh)i(KGNt1OAWRGiHkRRcqbWJhEG5GNt1OAWlN40Wjw)mH3ub8K2HiYbGjqbWJN5G5GNt1OAWBSftTmDdmeWtAhIihaMafapE4hmh8CQgvdEyRTT1WclAvwWtAhIihaMafapEMfmh8CQgvdE(s9wSATR0k4jTdrKdatGcuWJPEF89aMdGhpWCWZPAun4TYvTmHimMfw0QSGN0oeroambkaEZbZbpPDiICaycE0nuzdh8OvrofSoTYvTmHimMfw0QSPvU8Ozi(p3iU5io(G450dIdhIRorAnL7kwzJo3Y0AVss7qe5aEovJQbVXwm1Y0nWqakaE8dMdEs7qe5aWe8OBOYgo4bzmgPnUKKrg45unQg8WwWirNBHiotbkaEZcMdEs7qe5aWe8OBOYgo49zehYymsJTmtsBZmimjzKH4WH4QtKwtJTmtsBZmimjjTdrKd45unQg8kisOY6Qaua8FaMdEs7qe5aWe8OBOYgo4TgDqTzfmzthze0qr8Fq8zqC8(aX)J4QtKwtRrhuRRQ0gUgvNwVXaXXheh)i(KGNt1OAWBSftTmDdmeGcGhFdMdEs7qe5aWe8OBOYgo4bzmgjmccj6C7LtXgTKmYqC4q81OLKgxIvlRzrCCVr8C6b8CQgvdEJTykJAQIvaka(zbmh8K2HiYbGj4r3qLnCWBn6GAZkyYMoYiOHI44I4ZG4M)bI)hXvNiTMwJoOwxvPnCnQoTEJbIJpio(r8jbpNQr1GxbrcvwxfGcG)tbZbpNQr1G3ylMAz6gyiGN0oeroambkaEZayo45unQg8WwBBRHfw0QSGN0oeroambkaE8(fmh8CQgvdE(s9wSATR0k4jTdrKdatGcuW7id3GOG5a4Xdmh8CQgvdEUHwwxvNIb4jTdrKdatGcG3CWCWZPAun4Df9Xowrmtc4jTdrKdatGcGh)G5GN0oeroambp6gQSHdEFgXpLMgBXu7qMq2KgumIohXHdXNbX)mIRorAnbTIRyT1WYI(SEEX8K0oeroi(3VioTkYPG1jOvCfRTgww0N1ZlMNw5YJMH44I449bIpj45unQg8WwWirNBHiotbkaEZcMdEs7qe5aWe8OBOYgo4bzmgPGAQvDs1S0kxE0me)NBepNEqC4qCiJXifutTQtQMLmYqC4qCwMqiw13CrzPCItdNy9ZeEtfeh3Be3CehoeFge)ZiU6eP1e0kUI1wdll6Z65fZts7qe5G4F)I40QiNcwNGwXvS2AyzrFwpVyEALlpAgIJlIJ3hi(KGNt1OAWlN40Wjw)mH3ubOa4)amh8K2HiYbGj4r3qLnCWdYymsb1uR6KQzPvU8Ozi(p3iEo9G4WH4qgJrkOMAvNunlzKH4WH4ZG4FgXvNiTMGwXvS2AyzrFwpVyEsAhIihe)7xeNwf5uW6e0kUI1wdll6Z65fZtRC5rZqCCrC8(aXNe8CQgvdEJTyQLPBGHaua84BWCWtAhIihaMGhDdv2WbpAvKtbRtYvwbtw7A0IfM4zvNw5YJMH44I4)I4WH40QiNcwNYccXxBnSJTyAALlpAgIJlI)l45unQg8GwXvS2AyzrFwpVyoqbWplG5GN0oeroambpNQr1Gh1jeRt1OAljyk4rcMAB)sapAvKtbRzafa)NcMdEs7qe5aWe8OBOYgo4PorAnbTIRyT1WYI(SEEX8K0oeroioCioTkYPG1jOvCfRTgww0N1ZlMNw5YJMH4)G4FaEovJQbV1OTovJQTKGPGhjyQT9lb8GkMnRks05afaVzamh8K2HiYbGj4r3qLnCW7uAcAfxXARHLf9z98I5jnOyeDo45unQg8wJ26unQ2scMcEKGP22VeWdQywnOyeDoqbWJ3VG5GN0oeroambp6gQSHdEqgJrklieFT1Wo2IPjJmehoexDI0AQGiHkRRr1jPDiICapNQr1G3A0wNQr1wsWuWJem12(LaEfejuzDnQgOa4XdpWCWtAhIihaMGhDdv2WbpNQXeIvA5kegIJ7nIBo45unQg8wJ26unQ2scMcEKGP22VeWZlbOa4XZCWCWtAhIihaMGNt1OAWJ6eI1PAuTLemf8ibtTTFjGht9(47bOaf8OvrofSMbMdGhpWCWZPAun4zWeBOYfd8K2HiYbGjqbWBoyo4jTdrKdatWZPAun4HT22wd7eoPwWJUHkB4GhKXyKYccXxBnSJTyAYidXHdXNbX)mIRorAnbTIRyT1WYI(SEEX8K0oeroi(3Vi(NrCAvKtbRtqR4kwBnSSOpRNxmpTYLhndXXfX)fXNe8A)sapS122AyNWj1cua84hmh8K2HiYbGj4r3qLnCWdYymszbH4RTg2XwmnzKH4WH4qgJrsUYkyYAxJwSWepR6Krg45unQg8YknQgOa4nlyo4jTdrKdatWJUHkB4GhKXyKYccXxBnSJTyAYidXHdXHmgJKCLvWK1UgTyHjEw1jJmWZPAun4brQ6yhgRPafa)hG5GN0oeroambp6gQSHdEqgJrklieFT1Wo2IPjJmWZPAun4bjltwmIohOa4X3G5GN0oeroambp6gQSHdE0QiNcwNKRScMS21OflmXZQoTYLhndXXfX)f8CQgvdEzbH4RTg2XwmfOa4NfWCWtAhIihaMGhDdv2WbpAvKtbRtzbH4RTg2XwmnTIFmfXHdX)mIRorAnbTIRyT1WYI(SEEX8K0oeroioCi(A0ssJlXQL9dehxepNEqC4q81OdQnRGjB6iJGgkIJ7nIJ3VGNt1OAWtUYkyYAxJwSWepRAGcG)tbZbpPDiICaycE0nuzdh8OvrofSoLfeIV2AyhBX00k(XuehoexDI0AcAfxXARHLf9z98I5jPDiICqC4q81Ofeh3Beh)ioCi(A0b1MvWKfXXfXX3)cEovJQbp5kRGjRDnAXct8SQbkaEZayo4jTdrKdatWJUHkB4G3miUyg1iYYKtIwKJfR4RI4F)I4QtKwt0ICSyfF1K0oeroi(KioCi(mi(mi(mioKXyKOf5yXk(Q2qLRetDkgioU3ioE)I4F)I4qgJrIwKJfR4RAvNiTMyQtXaXX9gXX7xeFsehoe)iqgJrADZuTbvsm1PyG43i(hi(Ki(3ViU6BUOjnUeRw2tii(p3iEo9G4tcEovJQbpQtiwNQr1wsWuWJem12(LaE0ICSyfFvGcGhVFbZbpPDiICaycE0nuzdh8MbXHmgJuwqi(ARHDSfttRC5rZq8FUr8C6bXHdXHmgJuwqi(ARHDSfttgzi(KGNt1OAWBSftHz6EXSdJ1uGcuGcEtillQgaV5)I3N(7SG3SKWZC8(a8G5BhDod8apwMqbWB(h4bEzBncIaEZkIphBWq8JmCdII4ovJQr8SnQnutrCsWuepyiUBO1LRb1jetrC6kUkhehYzYbXRgXnTmweNI1xNQYMqtNve)tOiEWqChXDvLRmfX1cXZ2AI4iiUPLbIdluSiUJ4ovJQrCsWuexX6kIhmehQuSiolUYicI79bXZwNQb1HiIjOPZkIddBqeeFfMbrJohXJgXDe)s8o68HbbX9(G45vDqCwCzqCnQoH4FcfXVCtr8UueFfMbrr8OrCfRG4oeRigQqmfXXg5yfMI4zfJfqebXpzSeA6SI4Mzrii(yfbX1cXLtOMG4(XZue37dIhxzBnHG4HI4AH4MwglIxWAeVf5WsOPZkI)IldIRr1FY1hkIhme3jWCtzioPkmIohXh1I4gzhxfgI79bXJRSTMqUKwziUwiUIvq8JmCdII4ovJQrCsWuwcnfnDwrCZ4zFHAOYbXHKrTcItRlixrCijpAwcXnJqPsMYq8U6zhS(EnmiiUt1OAgIxnX0eAQt1OAwkBfADb569G4mmqtDQgvZszRqRlix)FJZOQdAQt1OAwkBfADb56)BCCJ8lPvxJQrtNve)1EgdBPi(6XbXHmgd5G4m1vgIdjJAfeNwxqUI4qsE0me37dINTYStwPA05iEWq8t1scn1PAunlLTcTUGC9)noS2Zyyl1YuxzOPovJQzPSvO1fKR)VXjR0OA0u00zfXnJN9fQHkhexMqwtrCnUeexXkiUt1Ar8GH4(eEqCiIKqtDQgvZUDdTSUQofd0uNQr1S)34Cf9XowrmtcA6SI4MrYYiMI4M5TykIBMLjKfX9(G4xE0QhnI)jOMI4ZDs1m0uNQr1S)34GTGrIo3crCMAsmU)8P00ylMAhYeYM0GIr05WnZNvNiTMGwXvS2AyzrFwpVyEsAhIiNVFPvrofSobTIRyT1WYI(SEEX80kxE0mCX7JjrtDQgvZ(FJtoXPHtS(zcVPIjX4gYymsb1uR6KQzPvU8Oz)CNtpWbzmgPGAQvDs1SKrgCSmHqSQV5IYs5eNgoX6Nj8Mk4EBoCZ8z1jsRjOvCfRTgww0N1ZlMNK2HiY57xAvKtbRtqR4kwBnSSOpRNxmpTYLhndx8(ys0uNQr1S)34m2IPwMUbgIjX4gYymsb1uR6KQzPvU8Oz)CNtpWbzmgPGAQvDs1SKrgCZ8z1jsRjOvCfRTgww0N1ZlMNK2HiY57xAvKtbRtqR4kwBnSSOpRNxmpTYLhndx8(ys0uNQr1S)34aTIRyT1WYI(SEEXCtIXnTkYPG1j5kRGjRDnAXct8SQtRC5rZGJwf5uW6uwqi(ARHDSfttRC5rZqtDQgvZ(FJd1jeRt1OAljyQjTFj30QiNcwZqtDQgvZ(FJZA0wNQr1wsWutA)sUHkMnRks05MeJB1jsRjOvCfRTgww0N1ZlMNK2HiYboAvKtbRtqR4kwBnSSOpRNxmpTYLhn7NpqtDQgvZ(FJZA0wNQr1wsWutA)sUHkMvdkgrNBsmUpLMGwXvS2AyzrFwpVyEsdkgrNJM6unQM9)gN1OTovJQTKGPM0(LCxqKqL11OAtIXnKXyKYccXxBnSJTyAYido1jsRPcIeQSUgvNK2HiYbn1PAun7)noRrBDQgvBjbtnP9l52lXKyC7unMqSslxHWW92C0uNQr1S)34qDcX6unQ2scMAs7xYnt9(47bnfn1PAunl5LCVYvTmHimMfw0QSMeJB1jsRPCxXkB05wMw7vsAhIih0uNQr1SKxY)BCYjonCI1pt4nvmjg3QtKwtJTykJAQIvss7qe5GM6unQML8s(FJZylMAz6gyiMeJBAvKtbRtRCvlticJzHfTkBALlpA2p3MJp50dCQtKwt5UIv2OZTmT2RK0oeroOPovJQzjVK)34GTGrIo3crCMAsmUHmgJ0gxsYidn1PAunl5L8)gNXwmLrnvXkMeJBiJXiHrqirNBVCk2OLKrgAQt1OAwYl5)no5eNgoX6Nj8MkMeJ71OdQnRGjB6iJGg6pZG3h)vNiTMwJoOwxvPnCnQojTdrKd(G)jrtDQgvZsEj)VXzSftTmDdmetIX9A0b1MvWKnDKrqd9NzW7J)QtKwtRrhuRRQ0gUgvNK2HiYbFW)KOPovJQzjVK)34SYvTmHimMfw0QSOPovJQzjVK)34m2IPmQPkwbn1PAunl5L8)gNcIeQSUkMeJ71OdQnRGjB6iJGgkUZy(h)vNiTMwJoOwxvPnCnQojTdrKd(G)jrtDQgvZsEj)VXjN40Wjw)mH3ubn1PAunl5L8)gNXwm1Y0nWqqtDQgvZsEj)VXbBTTTgwyrRYIM6unQML8s(FJJVuVfRw7kTIMIMoRioMR4kweVgi(l6Z65fZr8SQirNJ4BPUgvJ4ZUiot9vzioEFWqCizuRG4kwbXPhehsO1LWqCFcpioerqtDQgvZsqfZMvfj68BSfms05wiIZutIXnKXyK24ssgzOPovJQzjOIzZQIeD()BCkisOY6QysmUxJwsACjwTSM9NC6bU1OdQnRGjB6iJGgkU3M)bAQt1OAwcQy2SQirN))gNCItdNy9ZeEtftIX9A0b1MvWKnDKrqd9hZ)foAvKtbRtzbH4RTg2XwmnTYLhnd31OLKgxIvlRzrtDQgvZsqfZMvfj68)34m2IPwMUbgIjX4En6GAZkyYMoYiOH(J5)chTkYPG1PSGq81wd7ylMMw5YJMH7A0ssJlXQL1SOPovJQzjOIzZQIeD()BCgBXug1ufRysmUHmgJegbHeDU9YPyJwsgzWTgDqTzfmzthze0qXDg8(4V6eP10A0b16QkTHRr1jPDiICWh8pjAQt1OAwcQy2SQirN))gNcIeQSUkMeJ71OdQnRGjB6iJGgkU3Zy(h)vNiTMwJoOwxvPnCnQojTdrKd(G)jrtDQgvZsqfZMvfj68)34KtCA4eRFMWBQysmUPvrofSoLfeIV2AyhBX00kxE0mCxJwsACjwTSMfU1OdQnRGjB6iJGg6pM9x4yzcHyvFZfLLYjonCI1pt4nvW92C0uNQr1SeuXSzvrIo))noJTyQLPBGHysmUPvrofSoLfeIV2AyhBX00kxE0mCxJwsACjwTSMfU1OdQnRGjB6iJGg6pM9x0u0uNQr1SeuXSAqXi687cIeQSUkMeJ71OdQnRGj7p34)x0uNQr1SeuXSAqXi68)34SYvTmHimMfw0QSMeJB1jsRPCxXkB05wMw7vsAhIih0uNQr1SeuXSAqXi68)34GTGrIo3crCMAsmUHmgJ0gxsYidn1PAunlbvmRgumIo))nofejuzDvmjg3RrljnUeRw2p(jNE((Dn6GAZkyY(ZTz)an1PAunlbvmRgumIo))noJTykJAQIvmjg3qgJrcJGqIo3E5uSrljJm0uNQr1SeuXSAqXi68)34GT22wdlSOvznjg3RrhuBwbt20rgbnuCVX)VWTgTK04sSAzXpU50dAQt1OAwcQywnOyeD()BCw5QwMqegZclAvw0uNQr1SeuXSAqXi68)34m2IPmQPkwXKyCZYecXQ(Mlkln2IPmQPkwb3BZrtDQgvZsqfZQbfJOZ)FJtbrcvwxftIX9A0b1MvWKnDKrqdfxZ)4731OfCXpAQt1OAwcQywnOyeD()BC8L6Ty1AxPvtIX9A0b1MvWKnDKrqdfxZ)fnfnDwr8pzroiowXxfXPvFcnQMHM6unQMLOf5yXk(Q3uSE0mBnSbvmjg3ZazmgjArowSIVQnu5kXuNIbUF89lKXyKOf5yXk(Qw1jsRjM6umW9JjHt9nx0KgxIvl7jKFYPh0uNQr1SeTihlwXx9)nouSE0mBnSbvmjg3ZazmgPSGq81wd7ylMMw5YJM9ZDo9GpZG3)zOvrofSon2IPWmDVy2HXAAAf)ykC4997Vto53VqgJrklieFT1Wo2IPPvU8Oz)SgTK04sSAzX)KWbzmgPSGq81wd7ylMMmYqtrtDQgvZs0QiNcwZUnyInu5IHM6unQMLOvrofSM9)ghdMydvUmP9l5gBTTTg2jCsTMeJBiJXiLfeIV2AyhBX0KrgCZ8z1jsRjOvCfRTgww0N1ZlMNK2HiY573ptRICkyDcAfxXARHLf9z98I5PvU8OztIM6unQMLOvrofSM9)gNSsJQnjg3qgJrklieFT1Wo2IPjJm4GmgJKCLvWK1UgTyHjEw1jJm0uNQr1SeTkYPG1S)34arQ6yhgRPMeJBiJXiLfeIV2AyhBX0KrgCqgJrsUYkyYAxJwSWepR6KrgAQt1OAwIwf5uWA2)BCGKLjlgrNBsmUHmgJuwqi(ARHDSfttgzOPZkIBM3IPioTkYPG1m0uNQr1SeTkYPG1S)34KfeIV2AyhBXutIXnTkYPG1j5kRGjRDnAXct8SQtRC5rZqtDQgvZs0QiNcwZ(FJJCLvWK1UgTyHjEw1MeJBAvKtbRtzbH4RTg2XwmnTIFmfUpRorAnbTIRyT1WYI(SEEX8K0oeroWTgTK04sSAz)a3C6bU1OdQnRGjB6iJGgkU349lAQt1OAwIwf5uWA2)BCKRScMS21OflmXZQ2KyCtRICkyDklieFT1Wo2IPPv8JPWPorAnbTIRyT1WYI(SEEX8K0oeroWTgTG7n(HBn6GAZkyYIl((x0uNQr1SeTkYPG1S)34qDcX6unQ2scMAs7xYnTihlwXx1KyCpJyg1iYYKtIwKJfR4R(9R6eP1eTihlwXxnjTdrKZKWnZmZazmgjArowSIVQnu5kXuNIbU34973VqgJrIwKJfR4RAvNiTMyQtXa3B8(Ds4ocKXyKw3mvBqLetDkg3Fm53VQV5IM04sSAzpH8ZDo9mjAQt1OAwIwf5uWA2)BCgBXuyMUxm7Wyn1KyCpdKXyKYccXxBnSJTyAALlpA2p350dCqgJrklieFT1Wo2IPjJSjrtrtNvehFbIeQSUgvJ4BPUgvJM6unQMLkisOY6Au99kx1YeIWywyrRYAsmUvNiTMYDfRSrNBzATxjPDiICqtDQgvZsfejuzDnQ()nofejuzDvmjg3FwDI0AASftzutvSssAhIih4(mKXyK24ssgzWXYecXQ(MlklHTGrIo3crCMI7n(rtDQgvZsfejuzDnQ()noJTykJAQIvmjg3Zazmgjmccj6C7LtXgTKwXP63VZazmgjmccj6C7LtXgTKmYGBMSvMWMtpj8sJTyQLPBGH89B2ktyZPNeEjSfms05wiIZ0VFZwzcBo9KWlLtCA4eRFMWBQm5Ktc3mRrljnUeRwwZIBo989lltieR6BUOS0ylMYOMQyfCVnFs0uNQr1SubrcvwxJQ)FJtbrcvwxftIXnKXyKWiiKOZTxofB0sAfNQF)odKXyKWiiKOZTxofB0sYidUzYwzcBo9KWln2IPwMUbgY3VzRmHnNEs4LWwWirNBHiot)(nBLjS50tcVuoXPHtS(zcVPYKtIM6unQMLkisOY6Au9)BCYjonCI1pt4nvmjg3Z8ziJXiTXLKmY((Dn6GAZkyYMoYiOH(dE)(97A0ssJlXQL1CCZPNjHJLjeIv9nxuwkN40Wjw)mH3ub3BZrtDQgvZsfejuzDnQ()noylyKOZTqeNPMeJBiJXiTXLKmYGJLjeIv9nxuwcBbJeDUfI4mf3BZrtDQgvZsfejuzDnQ()noJTyQLPBGHysmU)mKXyK24ssgzF)UgDqTzfmzthze0q)bVF)(DnAjPXLy1YAoU50dAQt1OAwQGiHkRRr1)VXbBbJeDUfI4m1KyCdzmgPnUKKrgAQt1OAwQGiHkRRr1)VXPGiHkRRcAkAQt1OAwIPEF89CVYvTmHimMfw0QSOPovJQzjM69X3Z)BCgBXult3adXKyCtRICkyDALRAzcrymlSOvztRC5rZ(52C8jNEGtDI0Ak3vSYgDULP1ELK2HiYbn1PAunlXuVp(E(FJd2cgj6CleXzQjX4gYymsBCjjJm0uNQr1Set9(475)nofejuzDvmjg3FgYymsJTmtsBZmimjzKbN6eP10ylZK02mdctss7qe5GM6unQMLyQ3hFp)VXzSftTmDdmetIX9A0b1MvWKnDKrqd9NzW7J)QtKwtRrhuRRQ0gUgvNK2HiYbFW)KOPovJQzjM69X3Z)BCgBXug1ufRysmUHmgJegbHeDU9YPyJwsgzWTgTK04sSAznlU350dAQt1OAwIPEF898)gNcIeQSUkMeJ71OdQnRGjB6iJGgkUZy(h)vNiTMwJoOwxvPnCnQojTdrKd(G)jrtDQgvZsm17JVN)34m2IPwMUbgcAQt1OAwIPEF898)ghS122AyHfTklAQt1OAwIPEF898)ghFPElwT2vAfOafaaa]] )


end
