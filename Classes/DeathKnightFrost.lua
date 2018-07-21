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


    spec:RegisterPack( "Frost DK", 20180720.2222, [[dW0yabqifP6rOQsTjqXNGkvLrPiCkfrRcQuELQQMfQIBPiLYUe5xqfdtvrhdQQLHQYZGkzAOQQRPQW2Gkv(MQkPXPQs5COQswhQQqVdQufMNQkUNQyFqvoOIuKfcf9qvvIMiQQGUOQkvTrfPKrQifLtIQkYkvuEjQQaZeQuL2jO0pvvPYqvvjyPOQI6PQyQkQUkuPk6RksP6Sksr1Eb(lfdMshMQfdYJrmzv6YeBwHplQgnu60cVgkmBKUTQ0UL63sgUOCCOsv1Yv65OmDsxhv2UIKVdQgVQkHopQsRxrkmFvL2pKb4dMdoxxfaS89j()2N)kFFM4Jp(47ZFfCuEZeWjZjy45c40(RaotRTykYYpKFa4K58sl)cMdoSIBjc4Gv1mg)io4KhkwoOePEXHfVCuxJQjRpuCyXlbhiAbHd0WN2UYu4KT1iOcdN5HS8HpoZ5dFd)qXvSg(bDKJvntRTyAIfVeWbIlOk)udGaNRRcaw((e)F7ZFLVpt8X3N46d8bhNtXwl4CI3Fj4CfgbCMJnyiBWqwhzZCcgEUGS1azDIgvJS0GPmKDulYontWiOrcndnBAEXHS(kiB2wqoeLxKnVIohz1czHeKLXTzBWKlYcXlYQyfKTYKwwCpqw(jKfUZsilY(7GOHYdY(7GOHYdY(7GOHYdY(7GOHYdY(75NN2r2HiugYw3lYcXPiBWqws1SGPsRil8qXISN49xIStahR0il)C8ki7TewJ7tr2STitMqwKDowP5bz5T4q2xNxKfRpLGSAHSW9qrwMmLSofzzcP6ldzh1ISlxlmKfsg1kilVfhYMvzi7VNFEApHMHMnJJYlYIp)IFezr2Pv8lkxK1r2FzrVi70mXxfzLwxErwfRRilCNHSDPiRkmn6CKnBRmzP8MqwKDo2GHSmSfh9ISeNJji7VeRhndzRbYYpreKvlK1ZYeFrwxrwfRGSsFr2AGSoY(leuQViBnq2P1wmfzHh9TGJSXaz5T4W9TcYYXIohzvScYsLCPV(YlYwlYQovAnHMHMnJJYlYY3N8JilYI7z21v5IStt)c4Er2XwVi7jE)L8GSV(vqwfRGSounLGSeSENlmK17lYQyLgzFRBmc5IStt)c4ErwALheKvlK1jKIRvKDulY(75NN2rwS(urNJSk8czjy9nxyil8qXISkwbzPsU0xF5fz3OZtGdnykdmhCif9AWk(QG5ayXhmhCK2HOYfGj4q2qLnCWzcKfIBmsKIEnyfFvtOYBIPobdKfpK9dK97xKfIBmsKIEnyfFvJ6uP1etDcgilEi7hi7KilmiR6BUOjnEfJwMBii7piBo5coorJQbhcwpAMPgMGiafalFG5GJ0oevUambhYgQSHdotGSqCJrklOuFn1Wm2IPPvE9Ozi7ppiBo5IS4gYobYIpY(hzNazjvrVf8on2IPW5DFzMb3YBAf)YlYcdYIpY(9lY(jYojYojY(9lYcXngPSGs91udZylMMw51JMHS)GSlxljnEfJwgCHStISWGSqCJrklOuFn1Wm2IPjUmWXjAun4qW6rZm1WeebOafCkiAOY6Aunyoaw8bZbhPDiQCbycoKnuzdhCuNkTMYDfRSrNByATVjPDiQCbhNOr1GZkV1YeQWyg4rRYcuaS8bMdos7qu5cWeCiBOYgo4mDKvDQ0AASftzeEvSssAhIkxKfgKD6ile3yK24vsCzilmilltOuJ6BUOSe2con6Cde1zkYI3dYIlWXjAun4uq0qL1vbOayXfyo4iTdrLlatWHSHkB4GZeile3yKWiO0OZnVobB0sAfNOi73Vi7eile3yKWiO0OZnVobB0sIldzHbzNazZwzkto5MWpn2IPgMUbgcY(9lYMTYuMCYnHFcBbNgDUbI6mfz)(fzZwzkto5MWpLtDs4uJFNYBIGStIStIStISWGStGSlxljnEfJwg(JS4HS5KlY(9lYYYek1O(Mlkln2IPmcVkwbzX7bz5dzNeCCIgvdoJTykJWRIvakaw(dMdos7qu5cWeCiBOYgo4aXngjmckn6CZRtWgTKwXjkY(9lYobYcXngjmckn6CZRtWgTK4Yqwyq2jq2SvMYKtUj8tJTyQHPBGHGSF)ISzRmLjNCt4NWwWPrNBGOotr2VFr2SvMYKtUj8t5uNeo143P8Mii7Ki7KGJt0OAWPGOHkRRcqbW(byo4iTdrLlatWHSHkB4GZei70rwiUXiTXRK4Yq2VFr2LRdIjRGlB6kJGekY(dYI)Ni73Vi7Y1ssJxXOLHpKfpKnNCr2jrwyqwwMqPg13CrzPCQtcNA87uEteKfVhKLpWXjAun4KtDs4uJFNYBIauaS4oWCWrAhIkxaMGdzdv2WbhiUXiTXRK4YqwyqwwMqPg13CrzjSfCA05giQZuKfVhKLpWXjAun4GTGtJo3arDMcuaS)kyo4iTdrLlatWHSHkB4GZ0rwiUXiTXRK4Yq2VFr2LRdIjRGlB6kJGekY(dYI)Ni73Vi7Y1ssJxXOLHpKfpKnNCbhNOr1GZylMAy6gyiafa7VbMdos7qu5cWeCiBOYgo4aXngPnELexg44enQgCWwWPrNBGOotbkaw(fyo44enQgCkiAOY6Qaos7qu5cWeOafCGkMrdcgrNdMdGfFWCWrAhIkxaMGdzdv2WbNLRdIjRGllY(ZdYIRpbhNOr1GtbrdvwxfGcGLpWCWrAhIkxaMGdzdv2Wbh1PsRPCxXkB05gMw7BsAhIkxWXjAun4SYBTmHkmMbE0QSafalUaZbhPDiQCbycoKnuzdhCG4gJ0gVsIldCCIgvdoyl40OZnquNPafal)bZbhPDiQCbycoKnuzdhCwUwsA8kgTmFGS)GS5KlY(9lYUCDqmzfCzr2FEqw()b44enQgCkiAOY6QauaSFaMdos7qu5cWeCiBOYgo4aXngjmckn6CZRtWgTK4YahNOr1GZylMYi8QyfGcGf3bMdos7qu5cWeCiBOYgo4SCDqmzfCztxzeKqrw8EqwC9jYcdYUCTK04vmAzWfYIhYMtUGJt0OAWbBTTPgg4rRYcuaS)kyo44enQgCw5TwMqfgZapAvwWrAhIkxaMafa7VbMdos7qu5cWeCiBOYgo4WYek1O(Mlkln2IPmcVkwbzX7bz5dCCIgvdoJTykJWRIvakaw(fyo4iTdrLlatWHSHkB4GZY1bXKvWLnDLrqcfzXdz57dK97xKD5AbzXdzXf44enQgCkiAOY6QauaS4)jyo4iTdrLlatWHSHkB4GZY1bXKvWLnDLrqcfzXdz57tWXjAun44lXBXO1UsRafOGduXmzvrJohmhal(G5GJ0oevUambhYgQSHdoqCJrAJxjXLboorJQbhSfCA05giQZuGcGLpWCWrAhIkxaMGdzdv2WbNLRLKgVIrld)r2Fq2CYfzHbzxUoiMScUSPRmcsOilEpilFFaoorJQbNcIgQSUkafalUaZbhPDiQCbycoKnuzdhCwUoiMScUSPRmcsOi7pilFFISWGSKQO3cENYck1xtnmJTyAALxpAgYIhYUCTK04vmAz4p44enQgCYPojCQXVt5nrakaw(dMdos7qu5cWeCiBOYgo4SCDqmzfCztxzeKqr2Fqw((ezHbzjvrVf8oLfuQVMAygBX00kVE0mKfpKD5AjPXRy0YWFWXjAun4m2IPgMUbgcqbW(byo4iTdrLlatWHSHkB4Gde3yKWiO0OZnVobB0sIldzHbzxUoiMScUSPRmcsOilEi7eil(FGS)rw1PsRPLRdIXvvAoxJQtR3yGS4gYIlKDsWXjAun4m2IPmcVkwbOayXDG5GJ0oevUambhYgQSHdolxhetwbx20vgbjuKfVhKDcKLVpq2)iR6uP10Y1bX4QknNRr1P1BmqwCdzXfYoj44enQgCkiAOY6QauaS)kyo4iTdrLlatWHSHkB4GdPk6TG3PSGs91udZylMMw51JMHS4HSlxljnEfJwg(JSWGSlxhetwbx20vgbjuK9hKL)FISWGSSmHsnQV5IYs5uNeo143P8MiilEpilFGJt0OAWjN6KWPg)oL3ebOay)nWCWrAhIkxaMGdzdv2Wbhsv0BbVtzbL6RPgMXwmnTYRhndzXdzxUwsA8kgTm8hzHbzxUoiMScUSPRmcsOi7pil))eCCIgvdoJTyQHPBGHauGcozRqQxixbZbWIpyo4iTdrLlatGcGLpWCWrAhIkxaMafalUaZbhPDiQCbycuaS8hmhCK2HOYfGjqbW(byo44enQgCYknQgCK2HOYfGjqbk44LaMdGfFWCWrAhIkxaMGdzdv2Wbh1PsRPCxXkB05gMw7BsAhIkxWXjAun4SYBTmHkmMbE0QSafalFG5GJ0oevUambhYgQSHdoQtLwtJTykJWRIvss7qu5coorJQbNCQtcNA87uEteGcGfxG5GJ0oevUambhYgQSHdoKQO3cENw5TwMqfgZapAv20kVE0mK9NhKLpKf3q2CYfzHbzvNkTMYDfRSrNByATVjPDiQCbhNOr1GZylMAy6gyiafal)bZbhPDiQCbycoKnuzdhCG4gJ0gVsIldCCIgvdoyl40OZnquNPafa7hG5GJ0oevUambhYgQSHdoqCJrcJGsJo386eSrljUmWXjAun4m2IPmcVkwbOayXDG5GJ0oevUambhYgQSHdolxhetwbx20vgbjuK9hKDcKf)pq2)iR6uP10Y1bX4QknNRr1P1BmqwCdzXfYoj44enQgCYPojCQXVt5nraka2FfmhCK2HOYfGj4q2qLnCWz56GyYk4YMUYiiHIS)GStGS4)bY(hzvNkTMwUoigxvP5CnQoTEJbYIBilUq2jbhNOr1GZylMAy6gyiafa7VbMdoorJQbNvERLjuHXmWJwLfCK2HOYfGjqbWYVaZbhNOr1GZylMYi8QyfWrAhIkxaMafal(FcMdos7qu5cWeCiBOYgo4SCDqmzfCztxzeKqrw8q2jqw((az)JSQtLwtlxheJRQ0CUgvNwVXazXnKfxi7KGJt0OAWPGOHkRRcqbWIp(G5GJt0OAWjN6KWPg)oL3ebCK2HOYfGjqbWIpFG5GJt0OAWzSftnmDdmeWrAhIkxaMafal(4cmhCCIgvdoyRTn1WapAvwWrAhIkxaMafal(8hmhCCIgvdo(s8wmATR0k4iTdrLlatGcuWHuf9wWBgyoaw8bZbhNOr1GdhtmHkVmWrAhIkxaMafalFG5GJ0oevUambhYgQSHdoqCJrklOuFn1Wm2IPjUmKfgKDcKD6iR6uP1e0kUI1uddl6765fZts7qu5ISF)ISthzjvrVf8obTIRyn1WWI(UEEX80kVE0mKfpK9tKDsWP9xbCWwBBQHzkNwl44enQgCWwBBQHzkNwlqbWIlWCWrAhIkxaMGdzdv2WbhiUXiLfuQVMAygBX0exgYcdYcXngj5nRGlRz5AXax8SQtCzGJt0OAWjR0OAGcGL)G5GJ0oevUambhYgQSHdoqCJrklOuFn1Wm2IPjUmKfgKfIBmsYBwbxwZY1IbU4zvN4YahNOr1GdeTQRzWT8cuaSFaMdos7qu5cWeCiBOYgo4aXngPSGs91udZylMM4YahNOr1GdKSmzXi6CGcGf3bMdos7qu5cWeCiBOYgo4aXngj5nRGlRz5AXax8SQtCzGJt0OAWjlOuFn1Wm2IPafa7VcMdos7qu5cWeCiBOYgo4qQIEl4DklOuFn1Wm2IPPv8lVilmi70rw1PsRjOvCfRPggw031ZlMNK2HOYfzHbzxUwsA8kgTmFGS4HS5KlYcdYUCDqmzfCztxzeKqrw8Eqw8)eCCIgvdoYBwbxwZY1IbU4zvduaS)gyo4iTdrLlatWHSHkB4GdPk6TG3PSGs91udZylMMwXV8ISWGSQtLwtqR4kwtnmSOVRNxmpjTdrLlYcdYUCTGS49GS4czHbzxUoiMScUSilEilU7tWXjAun4iVzfCznlxlg4INvnqbWYVaZbhPDiQCbycoKnuzdhCMazfC)CrwMCtKIEnyfFvK97xKvDQ0AIu0RbR4RMK2HOYfzNezHbzNazNazNazH4gJePOxdwXx1eQ8MyQtWazX7bzX)tK97xKfIBmsKIEnyfFvJ6uP1etDcgilEpil(FIStISWGSxbIBmsRpnQnisIPobdK9bz)azNez)(fzvFZfnPXRy0YCdbz)5bzZjxKDsWXjAun4qCk14enQ2qdMco0GPM2FfWHu0RbR4RcuaS4)jyo4iTdrLlatWHSHkB4GZeile3yKYck1xtnmJTyAALxpAgY(ZdYMtUilmile3yKYck1xtnmJTyAIldzNeCCIgvdoJTykCE3xMzWT8cuGcoxz4Cufmhal(G5GJt0OAWX50Y4Q6emahPDiQCbycuaS8bMdoorJQbN3OVMXkY0qahPDiQCbycuaS4cmhCK2HOYfGj4q2qLnCWz6i7T00ylMAgYuYM0GGr05ilmi7ei70rw1PsRjOvCfRPggw031ZlMNK2HOYfz)(fzjvrVf8obTIRyn1WWI(UEEX80kVE0mKfpKf)pq2jbhNOr1Gd2con6Cde1zkqbWYFWCWrAhIkxaMGdzdv2WbhiUXifeEnQtRMLw51JMHS)8GS5KlYcdYcXngPGWRrDA1SexgYcdYYYek1O(MlklLtDs4uJFNYBIGS49GS8HSWGStGSthzvNkTMGwXvSMAyyrFxpVyEsAhIkxK97xKLuf9wW7e0kUI1uddl6765fZtR86rZqw8qw8)azNeCCIgvdo5uNeo143P8Miafa7hG5GJ0oevUambhYgQSHdoqCJrki8AuNwnlTYRhndz)5bzZjxKfgKfIBmsbHxJ60QzjUmKfgKDcKD6iR6uP1e0kUI1uddl6765fZts7qu5ISF)ISKQO3cENGwXvSMAyyrFxpVyEALxpAgYIhYI)hi7KGJt0OAWzSftnmDdmeGcGf3bMdos7qu5cWeCiBOYgo4aXngj5nRGlRz5AXax8SQtCzilmilPk6TG3PSGs91udZylMMw51JMHS4HSFcoorJQbhOvCfRPggw031ZlMduaS)kyo4iTdrLlatWXjAun4qCk14enQ2qdMco0GPM2FfWHuf9wWBgqbW(BG5GJ0oevUambhYgQSHdoQtLwtqR4kwtnmSOVRNxmpjTdrLlYcdYsQIEl4DcAfxXAQHHf9D98I5PvE9Ozi7pi7hGJt0OAWz5AJt0OAdnyk4qdMAA)vahOIzYQIgDoqbWYVaZbhPDiQCbycoKnuzdhCULMGwXvSMAyyrFxpVyEsdcgrNdoorJQbNLRnorJQn0GPGdnyQP9xbCGkMrdcgrNduaS4)jyo4iTdrLlatWHSHkB4Gde3yKYck1xtnmJTyAIldzHbzvNkTMkiAOY6AuDsAhIkxWXjAun4SCTXjAuTHgmfCObtnT)kGtbrdvwxJQbkaw8XhmhCK2HOYfGj4q2qLnCWXjAmLyKwEdHHS49GS8boorJQbNLRnorJQn0GPGdnyQP9xbC8sakaw85dmhCK2HOYfGj44enQgCioLACIgvBObtbhAWut7Vc4WuVV(EbkqbhM6913lyoaw8bZbhNOr1GZkV1YeQWyg4rRYcos7qu5cWeOay5dmhCK2HOYfGj4q2qLnCWHuf9wW70kV1YeQWyg4rRYMw51JMHS)8GS8HS4gYMtUilmiR6uP1uURyLn6CdtR9njTdrLl44enQgCgBXudt3adbOayXfyo4iTdrLlatWHSHkB4Gde3yK24vsCzGJt0OAWbBbNgDUbI6mfOay5pyo4iTdrLlatWHSHkB4GZ0rwiUXin2AAiTjJJYKexgYcdYQovAnn2AAiTjJJYKK0oevUGJt0OAWPGOHkRRcqbW(byo4iTdrLlatWHSHkB4GZY1bXKvWLnDLrqcfz)bzNazX)dK9pYQovAnTCDqmUQsZ5AuDA9gdKf3qwCHStcoorJQbNXwm1W0nWqakawChyo4iTdrLlatWHSHkB4Gde3yKWiO0OZnVobB0sIldzHbzxUwsA8kgTm8hzX7bzZjxWXjAun4m2IPmcVkwbOay)vWCWrAhIkxaMGdzdv2WbNLRdIjRGlB6kJGekYIhYobYY3hi7FKvDQ0AA56GyCvLMZ1O606ngilUHS4czNeCCIgvdofenuzDvaka2FdmhCCIgvdoJTyQHPBGHaos7qu5cWeOay5xG5GJt0OAWbBTTPgg4rRYcos7qu5cWeOayX)tWCWXjAun44lXBXO1UsRGJ0oevUambkqbk4mLSSOAaS89j()2N)k(8R0N)gU(aCG7BhDodCaNSTgbvah(nY(7)ffcNkxKfsg1kilPEHCfzHK8OzjKDAIqKmLHSD1tBy99DWrrwNOr1mKTAkVj0mNOr1Su2kK6fY1Nb1zyGM5enQMLYwHuVqU()bNrvx0mNOr1Su2kK6fY1)p44C5VsRUgvJMXVr2t7zmSLISRhxKfIBmKlYYuxzilKmQvqws9c5kYcj5rZqwVViB2ktBzLQrNJSbdzVvlj0mNOr1Su2kK6fY1)p4WApJHTudtDLHM5enQMLYwHuVqU()bNSsJQrZqZ43i7V)xuiCQCrwzkz5fz14vqwfRGSorRfzdgY6t5b1HOscnZjAun7X50Y4Q6emqZCIgvZ()GZB0xZyfzAiOz8BKDAklJYlYoT2IPi70sMswK17lY(6rRE0il)eHxKDUtRMHM5enQM9)bhSfCA05giQZuEIXZ0VLMgBXuZqMs2KgemIohMjMU6uP1e0kUI1uddl6765fZts7qu5(9lPk6TG3jOvCfRPggw031ZlMNw51JMHh(FmjAMt0OA2)hCYPojCQXVt5nr4jgpqCJrki8AuNwnlTYRhn7NNCYfgiUXifeEnQtRML4YGHLjuQr9nxuwkN6KWPg)oL3ebVh(GzIPRovAnbTIRyn1WWI(UEEX8K0oevUF)sQIEl4DcAfxXAQHHf9D98I5PvE9Oz4H)htIM5enQM9)bNXwm1W0nWq4jgpqCJrki8AuNwnlTYRhn7NNCYfgiUXifeEnQtRML4YGzIPRovAnbTIRyn1WWI(UEEX8K0oevUF)sQIEl4DcAfxXAQHHf9D98I5PvE9Oz4H)htIM5enQM9)bhOvCfRPggw031ZlMZtmEG4gJK8MvWL1SCTyGlEw1jUmyivrVf8oLfuQVMAygBX00kVE0m0mNOr1S)p4qCk14enQ2qdMYt7VYdPk6TG3m0mNOr1S)p4SCTXjAuTHgmLN2FLhOIzYQIgDopX4rDQ0AcAfxXAQHHf9D98I5jPDiQCHHuf9wW7e0kUI1uddl6765fZtR86rZ(5d0mNOr1S)p4SCTXjAuTHgmLN2FLhOIz0GGr058eJNBPjOvCfRPggw031ZlMN0GGr05OzorJQz)FWz5AJt0OAdnykpT)kpfenuzDnQMNy8aXngPSGs91udZylMM4YGrDQ0AQGOHkRRr1jPDiQCrZCIgvZ()GZY1gNOr1gAWuEA)vE8s4jgporJPeJ0YBim8E4dnZjAun7)doeNsnorJQn0GP80(R8WuVV(ErZqZCIgvZsEjpR8wltOcJzGhTklpX4rDQ0Ak3vSYgDUHP1(MK2HOYfnZjAunl5L8)bNCQtcNA87uEteEIXJ6uP10ylMYi8QyLK0oevUOzorJQzjVK)p4m2IPgMUbgcpX4Huf9wW70kV1YeQWyg4rRYMw51JM9ZdF4wo5cJ6uP1uURyLn6CdtR9njTdrLlAMt0OAwYl5)doyl40OZnquNP8eJhiUXiTXRK4YqZCIgvZsEj)FWzSftzeEvScpX4bIBmsyeuA05MxNGnAjXLHM5enQML8s()Gto1jHtn(DkVjcpX4z56GyYk4YMUYiiH(Ze4)XF1PsRPLRdIXvvAoxJQts7qu5IB4As0mNOr1SKxY)hCgBXudt3adHNy8SCDqmzfCztxzeKq)zc8)4V6uP10Y1bX4QknNRr1jPDiQCXnCnjAMt0OAwYl5)doR8wltOcJzGhTklAMt0OAwYl5)doJTykJWRIvqZCIgvZsEj)FWPGOHkRRcpX4z56GyYk4YMUYiiHI3e89XF1PsRPLRdIXvvAoxJQts7qu5IB4As0mNOr1SKxY)hCYPojCQXVt5nrqZCIgvZsEj)FWzSftnmDdme0mNOr1SKxY)hCWwBBQHbE0QSOzorJQzjVK)p44lXBXO1UsROzOz8BKfZvCflYwdK9e9D98I5iBwv0OZr2TuxJQrw(rKLP(QmKf)pyilKmQvqwfRGSKlYcjK6vyiRpLhuhIkOzorJQzjOIzYQIgD(d2con6Cde1zkpX4bIBmsB8kjUm0mNOr1SeuXmzvrJo))dofenuzDv4jgplxljnEfJwg()to5cZY1bXKvWLnDLrqcfVh((anZjAunlbvmtwv0OZ))Gto1jHtn(DkVjcpX4z56GyYk4YMUYiiH(dFFcdPk6TG3PSGs91udZylMMw51JMH3Y1ssJxXOLH)OzorJQzjOIzYQIgD()hCgBXudt3adHNy8SCDqmzfCztxzeKq)HVpHHuf9wW7uwqP(AQHzSfttR86rZWB5AjPXRy0YWF0mNOr1SeuXmzvrJo))doJTykJWRIv4jgpqCJrcJGsJo386eSrljUmywUoiMScUSPRmcsO4nb(F8xDQ0AA56GyCvLMZ1O6K0oevU4gUMenZjAunlbvmtwv0OZ))GtbrdvwxfEIXZY1bXKvWLnDLrqcfVNj47J)QtLwtlxheJRQ0CUgvNK2HOYf3W1KOzorJQzjOIzYQIgD()hCYPojCQXVt5nr4jgpKQO3cENYck1xtnmJTyAALxpAgElxljnEfJwg(dZY1bXKvWLnDLrqc9h()jmSmHsnQV5IYs5uNeo143P8Mi49WhAMt0OAwcQyMSQOrN))bNXwm1W0nWq4jgpKQO3cENYck1xtnmJTyAALxpAgElxljnEfJwg(dZY1bXKvWLnDLrqc9h()jAgAMt0OAwcQygniyeD(tbrdvwxfEIXZY1bXKvWL9NhC9jAMt0OAwcQygniyeD()hCw5TwMqfgZapAvwEIXJ6uP1uURyLn6CdtR9njTdrLlAMt0OAwcQygniyeD()hCWwWPrNBGOot5jgpqCJrAJxjXLHM5enQMLGkMrdcgrN))bNcIgQSUk8eJNLRLKgVIrlZh)KtUF)UCDqmzfCz)5H)FGM5enQMLGkMrdcgrN))bNXwmLr4vXk8eJhiUXiHrqPrNBEDc2OLexgAMt0OAwcQygniyeD()hCWwBBQHbE0QS8eJNLRdIjRGlB6kJGekEp46tywUwsA8kgTm4cVCYfnZjAunlbvmJgemIo))doR8wltOcJzGhTklAMt0OAwcQygniyeD()hCgBXugHxfRWtmEyzcLAuFZfLLgBXugHxfRG3dFOzorJQzjOIz0GGr05)FWPGOHkRRcpX4z56GyYk4YMUYiiHIhFF897Y1cE4cnZjAunlbvmJgemIo))do(s8wmATR0kpX4z56GyYk4YMUYiiHIhFFIMHMXVr2FzrVilwXxfzjvFdnQMHM5enQMLif9AWk(QpeSE0mtnmbr4jgptaXngjsrVgSIVQju5nXuNGbEF89le3yKif9AWk(Qg1PsRjM6emW7JjHr9nx0KgVIrlZnKFYjx0mNOr1SePOxdwXx9)doeSE0mtnmbr4jgptaXngPSGs91udZylMMw51JM9Zto5IBtG))jivrVf8on2IPW5DFzMb3YBAf)Ylm4)97Nto53VqCJrklOuFn1Wm2IPPvE9Oz)SCTK04vmAzW1KWaXngPSGs91udZylMM4YqZqZCIgvZsKQO3cEZE4yIju5LHM5enQMLivrVf8M9)bhoMycvE5P9x5bBTTPgMPCAT8eJhiUXiLfuQVMAygBX0exgmtmD1PsRjOvCfRPggw031ZlMNK2HOY973PtQIEl4DcAfxXAQHHf9D98I5PvE9OztIM5enQMLivrVf8M9)bNSsJQ5jgpqCJrklOuFn1Wm2IPjUmyG4gJK8MvWL1SCTyGlEw1jUm0mNOr1SePk6TG3S)p4arR6AgClV8eJhiUXiLfuQVMAygBX0exgmqCJrsEZk4YAwUwmWfpR6exgAMt0OAwIuf9wWB2)hCGKLjlgrNZtmEG4gJuwqP(AQHzSfttCzOz8BKDATftrwsv0BbVzOzorJQzjsv0BbVz)FWjlOuFn1Wm2IP8eJhiUXijVzfCznlxlg4INvDIldnZjAunlrQIEl4n7)doYBwbxwZY1IbU4zvZtmEivrVf8oLfuQVMAygBX00k(LxyMU6uP1e0kUI1uddl6765fZts7qu5cZY1ssJxXOL5d8YjxywUoiMScUSPRmcsO49G)NOzorJQzjsv0BbVz)FWrEZk4YAwUwmWfpRAEIXdPk6TG3PSGs91udZylMMwXV8cJ6uP1e0kUI1uddl6765fZts7qu5cZY1cEp4cMLRdIjRGllE4UprZCIgvZsKQO3cEZ()GdXPuJt0OAdnykpT)kpKIEnyfFvEIXZecUFUiltUjsrVgSIV63VQtLwtKIEnyfF1K0oevUtcZetmbe3yKif9AWk(QMqL3etDcg49G)NF)cXngjsrVgSIVQrDQ0AIPobd8EW)ZjH5kqCJrA9PrTbrsm1jy88XKF)Q(MlAsJxXOL5gYpp5K7KOzorJQzjsv0BbVz)FWzSftHZ7(YmdULxEIXZeqCJrklOuFn1Wm2IPPvE9Oz)8KtUWaXngPSGs91udZylMM4YMendnJFJS)oiAOY6AunYUL6AunAMt0OAwQGOHkRRr1pR8wltOcJzGhTklpX4rDQ0Ak3vSYgDUHP1(MK2HOYfnZjAunlvq0qL11O6)p4uq0qL1vHNy8mD1PsRPXwmLr4vXkjPDiQCHz6qCJrAJxjXLbdltOuJ6BUOSe2con6Cde1zkEp4cnZjAunlvq0qL11O6)p4m2IPmcVkwHNy8mbe3yKWiO0OZnVobB0sAfNOF)obe3yKWiO0OZnVobB0sIldMjYwzkto5MWpn2IPgMUbgY3VzRmLjNCt4NWwWPrNBGOot)(nBLPm5KBc)uo1jHtn(DkVjYKtojmtSCTK04vmAz4pE5K73VSmHsnQV5IYsJTykJWRIvW7HVjrZCIgvZsfenuzDnQ()dofenuzDv4jgpqCJrcJGsJo386eSrlPvCI(97eqCJrcJGsJo386eSrljUmyMiBLPm5KBc)0ylMAy6gyiF)MTYuMCYnHFcBbNgDUbI6m973SvMYKtUj8t5uNeo143P8MitojAMt0OAwQGOHkRRr1)FWjN6KWPg)oL3eHNy8mX0H4gJ0gVsIl773LRdIjRGlB6kJGe6p4)53VlxljnEfJwg(WlNCNegwMqPg13CrzPCQtcNA87uEte8E4dnZjAunlvq0qL11O6)p4GTGtJo3arDMYtmEG4gJ0gVsIldgwMqPg13CrzjSfCA05giQZu8E4dnZjAunlvq0qL11O6)p4m2IPgMUbgcpX4z6qCJrAJxjXL997Y1bXKvWLnDLrqc9h8)873LRLKgVIrldF4LtUOzorJQzPcIgQSUgv))bhSfCA05giQZuEIXde3yK24vsCzOzorJQzPcIgQSUgv))bNcIgQSUkOzOzorJQzjM69137ZkV1YeQWyg4rRYIM5enQMLyQ3xFV)FWzSftnmDdmeEIXdPk6TG3PvERLjuHXmWJwLnTYRhn7Nh(WTCYfg1PsRPCxXkB05gMw7BsAhIkx0mNOr1Set9(679)doyl40OZnquNP8eJhiUXiTXRK4YqZCIgvZsm17RV3)p4uq0qL1vHNy8mDiUXin2AAiTjJJYKexgmQtLwtJTMgsBY4OmjjTdrLlAMt0OAwIPEF99()bNXwm1W0nWq4jgplxhetwbx20vgbj0FMa)p(RovAnTCDqmUQsZ5AuDsAhIkxCdxtIM5enQMLyQ3xFV)FWzSftzeEvScpX4bIBmsyeuA05MxNGnAjXLbZY1ssJxXOLH)49KtUOzorJQzjM69137)hCkiAOY6QWtmEwUoiMScUSPRmcsO4nbFF8xDQ0AA56GyCvLMZ1O6K0oevU4gUMenZjAunlXuVV(E))GZylMAy6gyiOzorJQzjM69137)hCWwBBQHbE0QSOzorJQzjM69137)hC8L4Ty0AxPvWHLjeaS89b(afOaa]] )


end
