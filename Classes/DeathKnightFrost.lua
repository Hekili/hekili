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
            
            recheck = function () return target.time_to_die - gcd, buff.pillar_of_frost.remains - ( gcd * ( 1 + ( cooldown.frostwyrms_fury.remains == 0 and 1 or 0 ) ) ), buff.pillar_of_frost.remains - runes.time_to_3 end,
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


    spec:RegisterPack( "Frost DK", 20180717.1215, [[dKunbbqivI6rQePnbf(euvfgLkHtPiAvQQsVsvLzrrClkkv2Li)ckzyQQQJbvzzkcpdQktJIIRPQW2GQk9nvvHXPseNJIszDqvvP3bvvuMNQIUNk1(GsDqOQk1cHIEifLKjcvvKUiuvvTrvvrgjuvvCsOQcRur6Lqvfv7eu1pvvf1sPOK6PQYuvj9vkkvDwOQIyVa)fvdMshMQfdYJrAYQ4YeBwHplQgnu50cVguz2iUTIA3s9BjdxuoouvLSCLEoktN01PW2PO67GY4HQQOZtrA9uuI5RQ0(HmapWvW74QaGFI)X7s()pW7ps4nbEFG3LaEQPzc4L5u48Cb8AFwaV)0wmf8YCtjLFaxbpwzSub8WPAgd)lwyLhkodOeTMXIfZgexJQPRpuSyXmflisbHf0Wn7oI5yLT1iicdRRHStGhwxNapo(PIR444N3rooL)N2IPjwmtbpiJGO4hnac8oUka4N4F8UK))d8(JeE)BMpWNzd8CdfxTGh(hbUGei7fJTMr2xmBwnj4Degf8UIlyiBWqwhzZCkCEUGS1azDQgvJSKGPmKDulYI)rGlircnfnf)KYaz9vq2STGCiIPiBEfDoYQfYcjilZyZ2GjhKfYuKvXjiBLjTS4NHS4hilmNLqwK9pdrc1eK9pdrc1eK9pdrc1eK9pdrc1eKf)3S2ShzhIqyiBDoilKHISbdzPvZcMkTISWcfhY(IzZkK9cy4KgznRJzbzpLWA8hkYMTfDYeYISxXjTjiRPLbYo7MIS4CZfKvlKfMhkYYeZL1jiltOvFyi7OwKDnAHHSqYOwbznTmq2SkdzX)nRn7tOPOPM9c(dcbzzIGSXazvCcY6unQgzjbtziRyErmxq2YCzrwnMLe4rcMYaxbpAroCCIVk4kaE8axbpPDiICaycE0nuzdh8UazHmgJeTihooXxLhQmNyQtHdzXgz)az)(fzHmgJeTihooXxLRorAnXuNchYInY(bYojYIbYQ(MlAsJzHRf)ecY(jYMtpGNt1OAWJIZJMXRbpOcqbWpb4k4jTdrKdatWJUHkB4G3filKXyKYccXxEn4JTyAALzpAgY(5nYMtpi7Fr2lqw8q2FilTkYPG1PXwmfMP7mJpmwttR4htr2jr2VFrwiJXiLfeIV8AWhBX00kZE0mK9tKDnAjPXSW1IJpKDsKfdKfYymszbH4lVg8XwmnzKbEovJQbpkopAgVg8GkafOGxbrcvwxJQbxbWJh4k4jTdrKdatWJUHkB4GN6eP1uUR4Kn6CotRDojTdrKd45unQg8wzUwMqegJdlAvwGcGFcWvWtAhIihaMGhDdv2WbVlJSQtKwtJTykJAQItss7qe5GSyGSxgzHmgJ0gZsYidzXazzzcHWvFZfLLWvWirNZHiotrwSVrw8bEovJQbVcIeQSUkafap(axbpPDiICaycE0nuzdh8UazHmgJeCbHeDoF2P4IwsR4ufz)(fzVazHmgJeCbHeDoF2P4Iwsgzilgi7fiB2kMZZPNeEPXwmLZ0nGtq2VFr2SvmNNtpj8s4kyKOZ5qeNPi73ViB2kMZZPNeEPCItdNW9J5EtfKDsKDsKDsKfdK9cKDnAjPXSW1IBgKfBKnNEq2VFrwwMqiC13CrzPXwmLrnvXjil23i7ei7KGNt1OAWBSftzutvCcqbWBgWvWtAhIihaMGhDdv2WbpiJXibxqirNZNDkUOL0kovr2VFr2lqwiJXibxqirNZNDkUOLKrgYIbYEbYMTI58C6jHxASft5mDd4eK97xKnBfZ550tcVeUcgj6CoeXzkY(9lYMTI58C6jHxkN40WjC)yU3ubzNezNe8CQgvdEfejuzDvaka(paxbpPDiICaycE0nuzdh8UazVmYczmgPnMLKrgY(9lYUgDq5zfmzthze0qr2prw8(hz)(fzxJwsAmlCT4tGSyJS50dYojYIbYYYecHR(MlklLtCA4eUFm3BQGSyFJStaEovJQbVCItdNW9J5EtfGcGh)cUcEs7qe5aWe8OBOYgo4bzmgPnMLKrgYIbYYYecHR(MlklHRGrIoNdrCMISyFJStaEovJQbpCfms05CiIZuGcG)paxbpPDiICaycE0nuzdh8UmYczmgPnMLKrgY(9lYUgDq5zfmzthze0qr2prw8(hz)(fzxJwsAmlCT4tGSyJS50d45unQg8gBXuot3aobOa4VeWvWtAhIihaMGhDdv2WbpiJXiTXSKmYapNQr1GhUcgj6CoeXzkqbWB2axbpNQr1GxbrcvwxfWtAhIihaMafOGhuX4AqHl6CWva84bUcEs7qe5aWe8OBOYgo4TgDq5zfmzr2pVrw89p45unQg8kisOY6Qaua8taUcEs7qe5aWe8OBOYgo4PorAnL7kozJoNZ0ANts7qe5aEovJQbVvMRLjeHX4WIwLfOa4Xh4k4jTdrKdatWJUHkB4GhKXyK2ywsgzGNt1OAWdxbJeDohI4mfOa4nd4k4jTdrKdatWJUHkB4G3A0ssJzHRf)dK9tKnNEq2VFr21OdkpRGjlY(5nYAMpapNQr1GxbrcvwxfGcG)dWvWtAhIihaMGhDdv2WbpiJXibxqirNZNDkUOLKrg45unQg8gBXug1ufNaua84xWvWtAhIihaMGhDdv2WbV1OdkpRGjB6iJGgkYI9nYIV)rwmq21OLKgZcxlo(qwSr2C6b8CQgvdE4QT51GdlAvwGcG)paxbpNQr1G3kZ1YeIWyCyrRYcEs7qe5aWeOa4VeWvWtAhIihaMGhDdv2WbpwMqiC13CrzPXwmLrnvXjil23i7eGNt1OAWBSftzutvCcqbWB2axbpPDiICaycE0nuzdh8wJoO8ScMSPJmcAOil2i7eFGSF)ISRrlil2il(apNQr1GxbrcvwxfGcGhV)bxbpPDiICaycE0nuzdh8wJoO8ScMSPJmcAOil2i7e)dEovJQbpFPElCT2vAfOaf8GkgpRks05GRa4XdCf8K2HiYbGj4r3qLnCWdYymsBmljJmWZPAun4HRGrIoNdrCMcua8taUcEs7qe5aWe8OBOYgo4TgTK0yw4AXndY(jYMtpilgi7A0bLNvWKnDKrqdfzX(gzN4dWZPAun4vqKqL1vbOa4Xh4k4jTdrKdatWJUHkB4G3A0bLNvWKnDKrqdfz)ezN4FKfdKLwf5uW6uwqi(YRbFSfttRm7rZqwSr21OLKgZcxlUzapNQr1GxoXPHt4(XCVPcqbWBgWvWtAhIihaMGhDdv2WbV1OdkpRGjB6iJGgkY(jYoX)ilgilTkYPG1PSGq8Lxd(ylMMwz2JMHSyJSRrljnMfUwCZaEovJQbVXwmLZ0nGtaka(paxbpPDiICaycE0nuzdh8GmgJeCbHeDoF2P4Iwsgzilgi7A0bLNvWKnDKrqdfzXgzVazX7dK9hYQorAnTgDq5UQsB4AuDA9goK9Vil(q2jbpNQr1G3ylMYOMQ4eGcGh)cUcEs7qe5aWe8OBOYgo4TgDq5zfmzthze0qrwSVr2lq2j(az)HSQtKwtRrhuURQ0gUgvNwVHdz)lYIpKDsWZPAun4vqKqL1vbOa4)dWvWtAhIihaMGhDdv2WbpAvKtbRtzbH4lVg8XwmnTYShndzXgzxJwsAmlCT4MbzXazxJoO8ScMSPJmcAOi7NiRz(hzXazzzcHWvFZfLLYjonCc3pM7nvqwSVr2japNQr1GxoXPHt4(XCVPcqbWFjGRGN0oeroambp6gQSHdE0QiNcwNYccXxEn4JTyAALzpAgYInYUgTK0yw4AXndYIbYUgDq5zfmzthze0qr2prwZ8p45unQg8gBXuot3aobOaf8YwHwZqUcUcGhpWvWtAhIihaMafa)eGRGN0oeroambkaE8bUcEs7qe5aWeOa4nd4k4jTdrKdatGcG)dWvWZPAun4LvAun4jTdrKdatGcuWZlbCfapEGRGN0oeroambp6gQSHdEQtKwt5UIt2OZ5mT25K0oeroGNt1OAWBL5AzcrymoSOvzbka(jaxbpPDiICaycE0nuzdh8uNiTMgBXug1ufNKK2HiYb8CQgvdE5eNgoH7hZ9Mkafap(axbpPDiICaycE0nuzdh8OvrofSoTYCTmHimghw0QSPvM9Ozi7N3i7ei7Fr2C6bzXazvNiTMYDfNSrNZzATZjPDiICapNQr1G3ylMYz6gWjafaVzaxbpPDiICaycE0nuzdh8GmgJ0gZsYid8CQgvdE4kyKOZ5qeNPafa)hGRGN0oeroambp6gQSHdEqgJrcUGqIoNp7uCrljJmWZPAun4n2IPmQPkobOa4XVGRGN0oeroambp6gQSHdERrhuEwbt20rgbnuK9tK9cKfVpq2FiR6eP10A0bL7QkTHRr1P1B4q2)IS4dzNe8CQgvdE5eNgoH7hZ9Mkafa)FaUcEs7qe5aWe8OBOYgo4TgDq5zfmzthze0qr2pr2lqw8(az)HSQtKwtRrhuURQ0gUgvNwVHdz)lYIpKDsWZPAun4n2IPCMUbCcqbWFjGRGNt1OAWBL5AzcrymoSOvzbpPDiICaycua8MnWvWZPAun4n2IPmQPkob8K2HiYbGjqbWJ3)GRGN0oeroambp6gQSHdERrhuEwbt20rgbnuKfBK9cKDIpq2FiR6eP10A0bL7QkTHRr1P1B4q2)IS4dzNe8CQgvdEfejuzDvakaE8WdCf8CQgvdE5eNgoH7hZ9MkGN0oeroambkaE8MaCf8CQgvdEJTykNPBaNaEs7qe5aWeOa4XdFGRGNt1OAWdxTnVgCyrRYcEs7qe5aWeOa4XZmGRGNt1OAWZxQ3cxRDLwbpPDiICaycuGcE0QiNcwZaxbWJh4k45unQg8mycpuzMbEs7qe5aWeOa4NaCf8K2HiYbGj41(SaE4QT51GBUtQf8CQgvdE4QT51GBUtQf8OBOYgo4bzmgPSGq8Lxd(ylMMmYqwmq2lq2lJSQtKwtqR4koEn4SOpRNxmpjTdrKdY(9lYEzKLwf5uW6e0kUIJxdol6Z65fZtRm7rZqwSr2)r2jbkaE8bUcEs7qe5aWe8OBOYgo4bzmgPSGq8Lxd(ylMMmYqwmqwiJXijZzfmz5RrlCyINvDYid8CQgvdEzLgvdua8MbCf8K2HiYbGj4r3qLnCWdYymszbH4lVg8XwmnzKHSyGSqgJrsMZkyYYxJw4WepR6Krg45unQg8GivD4dJ1uGcG)dWvWtAhIihaMGhDdv2WbpiJXiLfeIV8AWhBX0Krg45unQg8GKLjlCrNdua84xWvWtAhIihaMGhDdv2WbpAvKtbRtYCwbtw(A0chM4zvNwz2JMHSyJS)dEovJQbVSGq8Lxd(ylMcua8)b4k4jTdrKdatWJUHkB4GhTkYPG1PSGq8Lxd(ylMMwXpMISyGSxgzvNiTMGwXvC8AWzrFwpVyEsAhIihKfdKDnAjPXSW1I)bYInYMtpilgi7A0bLNvWKnDKrqdfzX(gzX7FWZPAun4jZzfmz5RrlCyINvnqbWFjGRGN0oeroambp6gQSHdE0QiNcwNYccXxEn4JTyAAf)ykYIbYQorAnbTIR441GZI(SEEX8K0oeroilgi7A0cYI9nYIpKfdKDn6GYZkyYISyJS43)bpNQr1GNmNvWKLVgTWHjEw1afaVzdCf8K2HiYbGj4r3qLnCW7cKvWFzezzYjrlYHJt8vr2VFrw1jsRjAroCCIVAsAhIihKDsKfdK9cK9cK9cKfYyms0IC44eFvEOYCIPofoKf7BKfV)r2VFrwiJXirlYHJt8v5QtKwtm1PWHSyFJS49pYojYIbYEeiJXiTUzP2GkjM6u4q2BK9dKDsK97xKv9nx0KgZcxl(jeK9ZBKnNEq2jbpNQr1Gh1jeUt1OAojyk4rcMYBFwapAroCCIVkqbWJ3)GRGN0oeroambp6gQSHdExGSqgJrklieF51Gp2IPPvM9Ozi7N3iBo9GSyGSqgJrklieF51Gp2IPjJmKDsWZPAun4n2IPWmDNz8HXAkqbk4DKHBquWva84bUcEovJQbp3qlURQtHd8K2HiYbGjqbWpb4k45unQg8MJ(WhRiMfb8K2HiYbGjqbWJpWvWtAhIihaMGhDdv2WbVlJSNstJTykFiMlBsdkCrNJSyGSxGSxgzvNiTMGwXvC8AWzrFwpVyEsAhIihK97xKLwf5uW6e0kUIJxdol6Z65fZtRm7rZqwSrw8(azNe8CQgvdE4kyKOZ5qeNPafaVzaxbpPDiICaycE0nuzdh8GmgJuqnLRoPAwALzpAgY(5nYMtpilgilKXyKcQPC1jvZsgzilgilltieU6BUOSuoXPHt4(XCVPcYI9nYobYIbYEbYEzKvDI0AcAfxXXRbNf9z98I5jPDiICq2VFrwAvKtbRtqR4koEn4SOpRNxmpTYShndzXgzX7dKDsWZPAun4LtCA4eUFm3BQaua8FaUcEs7qe5aWe8OBOYgo4bzmgPGAkxDs1S0kZE0mK9ZBKnNEqwmqwiJXifut5QtQMLmYqwmq2lq2lJSQtKwtqR4koEn4SOpRNxmpjTdrKdY(9lYsRICkyDcAfxXXRbNf9z98I5PvM9Ozil2ilEFGStcEovJQbVXwmLZ0nGtakaE8l4k4jTdrKdatWJUHkB4GhTkYPG1jzoRGjlFnAHdt8SQtRm7rZqwSr2)rwmqwAvKtbRtzbH4lVg8XwmnTYShndzXgz)h8CQgvdEqR4koEn4SOpRNxmhOa4)dWvWtAhIihaMGNt1OAWJ6ec3PAunNemf8ibt5TplGhTkYPG1mGcG)saxbpPDiICaycE0nuzdh8uNiTMGwXvC8AWzrFwpVyEsAhIihKfdKLwf5uW6e0kUIJxdol6Z65fZtRm7rZq2pr2papNQr1G3A0CNQr1CsWuWJemL3(SaEqfJNvfj6CGcG3SbUcEs7qe5aWe8OBOYgo4DknbTIR441GZI(SEEX8Kgu4Ioh8CQgvdERrZDQgvZjbtbpsWuE7Zc4bvmUgu4IohOa4X7FWvWtAhIihaMGhDdv2WbpiJXiLfeIV8AWhBX0KrgYIbYQorAnvqKqL11O6K0oeroGNt1OAWBnAUt1OAojyk4rcMYBFwaVcIeQSUgvdua84Hh4k4jTdrKdatWJUHkB4GNt1WCHlTmhcdzX(gzNa8CQgvdERrZDQgvZjbtbpsWuE7Zc45Laua84nb4k4jTdrKdatWZPAun4rDcH7unQMtcMcEKGP82NfWJPEF89auGcEm17JVhWva84bUcEovJQbVvMRLjeHX4WIwLf8K2HiYbGjqbWpb4k4jTdrKdatWJUHkB4GhTkYPG1PvMRLjeHX4WIwLnTYShndz)8gzNaz)lYMtpilgiR6eP1uUR4Kn6CotRDojTdrKd45unQg8gBXuot3aobOa4Xh4k4jTdrKdatWJUHkB4GhKXyK2ywsgzGNt1OAWdxbJeDohI4mfOa4nd4k4jTdrKdatWJUHkB4G3LrwiJXin2YSinpZGWKKrgYIbYQorAnn2YSinpZGWKK0oeroGNt1OAWRGiHkRRcqbW)b4k4jTdrKdatWJUHkB4G3A0bLNvWKnDKrqdfz)ezVazX7dK9hYQorAnTgDq5UQsB4AuDA9goK9Vil(q2jbpNQr1G3ylMYz6gWjafap(fCf8K2HiYbGj4r3qLnCWdYymsWfes058zNIlAjzKHSyGSRrljnMfUwCZGSyFJS50d45unQg8gBXug1ufNaua8)b4k4jTdrKdatWJUHkB4G3A0bLNvWKnDKrqdfzXgzVazN4dK9hYQorAnTgDq5UQsB4AuDA9goK9Vil(q2jbpNQr1GxbrcvwxfGcG)saxbpNQr1G3ylMYz6gWjGN0oeroambkaEZg4k45unQg8WvBZRbhw0QSGN0oeroambkaE8(hCf8CQgvdE(s9w4ATR0k4jTdrKdatGcuGcEMlllQga)e)J3L8)FGh(s4Dj4DjGhmF7OZzGh4LT1iic4DPi7vCbdzpYWnikY6unQgzZ2O2qnfzjbtr2GHSUHwZUguNqmfzPR4QCqwiNjhKTAK10YyrwkoFDQkBcn9srw8dfzdgY6iRRQmNPiRwiB2wMhhbznTmqwyHIdzDK1PAunYscMISkoxr2GHSqLIdzzXCgrqwVpiB26unOoermbn9srwy4cIGSRWmiA05iB0iRJSZI3rNpmiiR3hKnVQdYYIzdIRr1jKf)qr2z3uKTlfzxHzquKnAKvXjiRdXkIHketrwCrooHPiBwXyberq2tglHMEPi7FsecYowrqwTqw5eQjiRF8mfz9(GSXC2wMliBOiRwiRPLXISfSgzBroSeA6LISVy2G4AuTz16dfzdgY6eyUPmKLufCrNJSJArwJSJRcdz9(GSXC2wMlZsRmKvlKvXji7rgUbrrwNQr1iljyklHMIMEPil(p(tHAOYbzHKrTcYsRzixrwijpAwczXFtPsMYq2UAZoC(opmiiRt1OAgYwnX0eAQt1OAwkBfAnd569G4m4qtDQgvZszRqRzix)DJ1OQdAQt1OAwkBfAnd56VBSCJ8zPvxJQrtVuK91EgdxPi76XbzHmgd5GSm1vgYcjJAfKLwZqUISqsE0mK17dYMTIzxwPA05iBWq2t1scn1PAunlLTcTMHC93nwS2Zy4kLZuxzOPovJQzPSvO1mKR)UXkR0OA0u00lfzX)XFkudvoiRyUSMISAmliRItqwNQ1ISbdzDZ9G4qejHM6unQMD7gAXDvDkCOPovJQz)UXAo6dFSIywe00lfzXFNLrmfz)tBXuK9pjMllY69bzN9OvpAKf)GAkYE1jvZqtDQgvZ(DJfUcgj6CoeXzQjX4(YNstJTykFiMlBsdkCrNJXfxwDI0AcAfxXXRbNf9z98I5jPDiIC((Lwf5uW6e0kUIJxdol6Z65fZtRm7rZWgVpMen1PAun73nw5eNgoH7hZ9MkMeJBiJXifut5QtQMLwz2JM95Do9GbKXyKcQPC1jvZsgzyWYecHR(MlklLtCA4eUFm3BQG99eyCXLvNiTMGwXvC8AWzrFwpVyEsAhIiNVFPvrofSobTIR441GZI(SEEX80kZE0mSX7JjrtDQgvZ(DJ1ylMYz6gWjMeJBiJXifut5QtQMLwz2JM95Do9GbKXyKcQPC1jvZsgzyCXLvNiTMGwXvC8AWzrFwpVyEsAhIiNVFPvrofSobTIR441GZI(SEEX80kZE0mSX7JjrtDQgvZ(DJf0kUIJxdol6Z65fZnjg30QiNcwNK5ScMS81OfomXZQoTYShnddAvKtbRtzbH4lVg8XwmnTYShndn1PAun73nwuNq4ovJQ5KGPM0(SCtRICkyndn1PAun73nwRrZDQgvZjbtnP9z5gQy8SQirNBsmUvNiTMGwXvC8AWzrFwpVyEsAhIihmOvrofSobTIR441GZI(SEEX80kZE0Sp)an1PAun73nwRrZDQgvZjbtnP9z5gQyCnOWfDUjX4(uAcAfxXXRbNf9z98I5jnOWfDoAQt1OA2VBSwJM7unQMtcMAs7ZYDbrcvwxJQnjg3qgJrklieF51Gp2IPjJmmuNiTMkisOY6AuDsAhIih0uNQr1SF3yTgn3PAunNem1K2NLBVetIXTt1WCHlTmhcd77jqtDQgvZ(DJf1jeUt1OAojyQjTpl3m17JVh0u0uNQr1SKxY9kZ1YeIWyCyrRYAsmUvNiTMYDfNSrNZzATZjPDiICqtDQgvZsEj)UXkN40WjC)yU3uXKyCRorAnn2IPmQPkojjTdrKdAQt1OAwYl53nwJTykNPBaNysmUPvrofSoTYCTmHimghw0QSPvM9OzFEpXFZPhmuNiTMYDfNSrNZzATZjPDiICqtDQgvZsEj)UXcxbJeDohI4m1KyCdzmgPnMLKrgAQt1OAwYl53nwJTykJAQItmjg3qgJrcUGqIoNp7uCrljJm0uNQr1SKxYVBSYjonCc3pM7nvmjg3RrhuEwbt20rgbn0pVaVp(PorAnTgDq5UQsB4AuDsAhIiN)IVjrtDQgvZsEj)UXASft5mDd4etIX9A0bLNvWKnDKrqd9ZlW7JFQtKwtRrhuURQ0gUgvNK2HiY5V4Bs0uNQr1SKxYVBSwzUwMqegJdlAvw0uNQr1SKxYVBSgBXug1ufNGM6unQML8s(DJvbrcvwxftIX9A0bLNvWKnDKrqdf7lM4JFQtKwtRrhuURQ0gUgvNK2HiY5V4Bs0uNQr1SKxYVBSYjonCc3pM7nvqtDQgvZsEj)UXASft5mDd4e0uNQr1SKxYVBSWvBZRbhw0QSOPovJQzjVKF3y5l1BHR1UsROPOPxkYI5kUIdzRbY(I(SEEXCKnRks05i7wQRr1il(xKLP(QmKfVpyilKmQvqwfNGS0dYcj0AwyiRBUhehIiOPovJQzjOIXZQIeD(nUcgj6CoeXzQjX4gYymsBmljJm0uNQr1SeuX4zvrIo)3nwfejuzDvmjg3RrljnMfUwCZ8zo9GXA0bLNvWKnDKrqdf77j(an1PAunlbvmEwvKOZ)DJvoXPHt4(XCVPIjX4En6GYZkyYMoYiOH(5e)JbTkYPG1PSGq8Lxd(ylMMwz2JMH9A0ssJzHRf3mOPovJQzjOIXZQIeD(VBSgBXuot3aoXKyCVgDq5zfmzthze0q)CI)XGwf5uW6uwqi(YRbFSfttRm7rZWEnAjPXSW1IBg0uNQr1SeuX4zvrIo)3nwJTykJAQItmjg3qgJrcUGqIoNp7uCrljJmmwJoO8ScMSPJmcAOyFbEF8tDI0AAn6GYDvL2W1O6K0oero)fFtIM6unQMLGkgpRks05)UXQGiHkRRIjX4En6GYZkyYMoYiOHI99ft8Xp1jsRP1Odk3vvAdxJQts7qe58x8njAQt1OAwcQy8SQirN)7gRCItdNW9J5EtftIXnTkYPG1PSGq8Lxd(ylMMwz2JMH9A0ssJzHRf3mySgDq5zfmzthze0q)0m)JbltieU6BUOSuoXPHt4(XCVPc23tGM6unQMLGkgpRks05)UXASft5mDd4etIXnTkYPG1PSGq8Lxd(ylMMwz2JMH9A0ssJzHRf3mySgDq5zfmzthze0q)0m)JMIM6unQMLGkgxdkCrNFxqKqL1vXKyCVgDq5zfmz)8gF)JM6unQMLGkgxdkCrN)7gRvMRLjeHX4WIwL1KyCRorAnL7kozJoNZ0ANts7qe5GM6unQMLGkgxdkCrN)7glCfms05CiIZutIXnKXyK2ywsgzOPovJQzjOIX1Gcx05)UXQGiHkRRIjX4EnAjPXSW1I)XN50Z3VRrhuEwbt2pVnZhOPovJQzjOIX1Gcx05)UXASftzutvCIjX4gYymsWfes058zNIlAjzKHM6unQMLGkgxdkCrN)7glC128AWHfTkRjX4En6GYZkyYMoYiOHI9n((hJ1OLKgZcxlo(WoNEqtDQgvZsqfJRbfUOZ)DJ1kZ1YeIWyCyrRYIM6unQMLGkgxdkCrN)7gRXwmLrnvXjMeJBwMqiC13CrzPXwmLrnvXjyFpbAQt1OAwcQyCnOWfD(VBSkisOY6QysmUxJoO8ScMSPJmcAOypXhF)UgTGn(qtDQgvZsqfJRbfUOZ)DJLVuVfUw7kTAsmUxJoO8ScMSPJmcAOypX)OPOPxkYAwvKdYIt8vrwA1NqJQzOPovJQzjAroCCIV6nfNhnJxdEqftIX9fqgJrIwKdhN4RYdvMtm1PWH9hF)czmgjAroCCIVkxDI0AIPofoS)ysmuFZfnPXSW1IFc5ZC6bn1PAunlrlYHJt8v)DJffNhnJxdEqftIX9fqgJrklieF51Gp2IPPvM9OzFENtp)9c8(rRICkyDASftHz6oZ4dJ100k(X0j)(fYymszbH4lVg8XwmnTYShn7Z1OLKgZcxlo(MediJXiLfeIV8AWhBX0KrgAkAQt1OAwIwf5uWA2Tbt4HkZm0uNQr1SeTkYPG1SF3yzWeEOYSjTpl34QT51GBUtQ1KyCdzmgPSGq8Lxd(ylMMmYW4IlRorAnbTIR441GZI(SEEX8K0oeroF)EzAvKtbRtqR4koEn4SOpRNxmpTYShnBs0uNQr1SeTkYPG1SF3yLvAuTjX4gYymszbH4lVg8XwmnzKHbKXyKK5ScMS81OfomXZQozKHM6unQMLOvrofSM97glisvh(Wyn1KyCdzmgPSGq8Lxd(ylMMmYWaYymsYCwbtw(A0chM4zvNmYqtDQgvZs0QiNcwZ(DJfKSmzHl6CtIXnKXyKYccXxEn4JTyAYidn9sr2)0wmfzPvrofSMHM6unQMLOvrofSM97gRSGq8Lxd(ylMAsmUPvrofSojZzfmz5RrlCyINvDALzpAgAQt1OAwIwf5uWA2VBSK5ScMS81OfomXZQ2KyCtRICkyDklieF51Gp2IPPv8JPyCz1jsRjOvCfhVgCw0N1ZlMNK2HiYbJ1OLKgZcxl(hyNtpySgDq5zfmzthze0qX(gV)rtDQgvZs0QiNcwZ(DJLmNvWKLVgTWHjEw1MeJBAvKtbRtzbH4lVg8XwmnTIFmfd1jsRjOvCfhVgCw0N1ZlMNK2HiYbJ1OfSVXhgRrhuEwbtwSXV)JM6unQMLOvrofSM97glQtiCNQr1CsWutAFwUPf5WXj(QMeJ7le8xgrwMCs0IC44eF1VFvNiTMOf5WXj(QjPDiICMeJlU4ciJXirlYHJt8v5HkZjM6u4W(gV))(fYyms0IC44eFvU6eP1etDkCyFJ3)tIXrGmgJ06MLAdQKyQtH7(Jj)(v9nx0KgZcxl(jKpVZPNjrtDQgvZs0QiNcwZ(DJ1ylMcZ0DMXhgRPMeJ7lGmgJuwqi(YRbFSfttRm7rZ(8oNEWaYymszbH4lVg8XwmnzKnjAkA6LIS)zisOY6AunYUL6AunAQt1OAwQGiHkRRr13RmxlticJXHfTkRjX4wDI0Ak3vCYgDoNP1oNK2HiYbn1PAunlvqKqL11O6F3yvqKqL1vXKyCFz1jsRPXwmLrnvXjjPDiICW4YqgJrAJzjzKHbltieU6BUOSeUcgj6CoeXzk234dn1PAunlvqKqL11O6F3yn2IPmQPkoXKyCFbKXyKGliKOZ5Zofx0sAfNQF)EbKXyKGliKOZ5Zofx0sYidJlYwXCEo9KWln2IPCMUbCY3VzRyopNEs4LWvWirNZHiot)(nBfZ550tcVuoXPHt4(XCVPYKtojgxSgTK0yw4AXnd250Z3VSmHq4QV5IYsJTykJAQItW(EIjrtDQgvZsfejuzDnQ(3nwfejuzDvmjg3qgJrcUGqIoNp7uCrlPvCQ(97fqgJrcUGqIoNp7uCrljJmmUiBfZ550tcV0ylMYz6gWjF)MTI58C6jHxcxbJeDohI4m973SvmNNtpj8s5eNgoH7hZ9MktojAQt1OAwQGiHkRRr1)UXkN40WjC)yU3uXKyCFXLHmgJ0gZsYi7731OdkpRGjB6iJGg6N49)3VRrljnMfUw8jWoNEMedwMqiC13CrzPCItdNW9J5EtfSVNan1PAunlvqKqL11O6F3yHRGrIoNdrCMAsmUHmgJ0gZsYiddwMqiC13CrzjCfms05CiIZuSVNan1PAunlvqKqL11O6F3yn2IPCMUbCIjX4(YqgJrAJzjzK997A0bLNvWKnDKrqd9t8()731OLKgZcxl(eyNtpOPovJQzPcIeQSUgv)7glCfms05CiIZutIXnKXyK2ywsgzOPovJQzPcIeQSUgv)7gRcIeQSUkOPOPovJQzjM69X3Z9kZ1YeIWyCyrRYIM6unQMLyQ3hFp)UXASft5mDd4etIXnTkYPG1PvMRLjeHX4WIwLnTYShn7Z7j(Bo9GH6eP1uUR4Kn6CotRDojTdrKdAQt1OAwIPEF8987glCfms05CiIZutIXnKXyK2ywsgzOPovJQzjM69X3ZVBSkisOY6QysmUVmKXyKgBzwKMNzqysYidd1jsRPXwMfP5zgeMKK2HiYbn1PAunlXuVp(E(DJ1ylMYz6gWjMeJ71OdkpRGjB6iJGg6NxG3h)uNiTMwJoOCxvPnCnQojTdrKZFX3KOPovJQzjM69X3ZVBSgBXug1ufNysmUHmgJeCbHeDoF2P4IwsgzySgTK0yw4AXnd2350dAQt1OAwIPEF8987gRcIeQSUkMeJ71OdkpRGjB6iJGgk2xmXh)uNiTMwJoOCxvPnCnQojTdrKZFX3KOPovJQzjM69X3ZVBSgBXuot3aobn1PAunlXuVp(E(DJfUABEn4WIwLfn1PAunlXuVp(E(DJLVuVfUw7kTcESmHcGFIpWdOafaa]] )


end
