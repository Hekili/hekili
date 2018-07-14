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

            fire = function( time, val )
                local r = state.runes 
                local v = r.actual

                if v == 6 then return end

                r.expiry[ v + 1 ] = 0
                table.sort( r.expiry )
            end,

            stop = function( x )
                return x == 6
            end,

            value = 1,    
        },

        empower_rune = {
            aura        = 'empower_rune_weapon',

            last = function ()
                return state.buff.empower_rune_weapon.applied + floor( state.query_time - state.buff.empower_rune_weapon.applied )
            end,

            fire = function ( time, val )
                local r = state.runes

                r.expiry[6] = 0
                table.sort( r.expiry )
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
                    amount = amount + ( t.expiry[i] <= state.query_time and 1 or 0 )
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

                if amount then
                    if amount > 6 then return 3600
                    elseif amount <= t.current then return 0 end

                    if t.forecast and t.fcount > 0 then
                        local q = state.query_time
                        local index, slice

                        if t.times[ amount ] then return max( 0, t.times[ amount ] - q ) end

                        if t.regen == 0 then
                            for i = 1, t.fcount do
                                local v = t.forecast[ i ]
                                if v.v >= amount then
                                    t.times[ amount ] = v.t
                                    return max( 0, t.times[ amount ] - q )
                                end
                            end
                            t.times[ amount ] = q + 3600
                            return max( 0, t.times[ amount ] - q )
                        end

                        for i = 1, t.fcount do
                            local slice = t.forecast[ i ]
                            local after = t.forecast[ i + 1 ]
                            
                            if slice.v >= amount then
                                t.times[ amount ] = slice.t
                                return max( 0, t.times[ amount ] - q )

                            elseif after and after.v >= amount then
                                -- Our next slice will have enough resources.  Check to see if we'd regen enough in-between.
                                local time_diff = after.t - slice.t
                                local deficit = amount - slice.v
                                local regen_time = deficit / t.regen

                                if regen_time < time_diff then
                                    t.times[ amount ] = ( slice.t + regen_time )
                                else
                                    t.times[ amount ] = after.t
                                end                        
                                return max( 0, t.times[ amount ] - q )
                            end
                        end
                        t.times[ amount ] = q + 3600
                        return max( 0, t.times[ amount ] - q )
                    end

                    return max( 0, t.expiry[ amount ] - state.query_time )
                end
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
            local r = state.runes
            r.actual = nil

            r.spend( amt )

           state.gain( amt * 10, "runic_power" )

            if state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
                state.buff.remorseless_winter.expires = state.buff.remorseless_winter.expires + ( 0.5 * amt )
            end
        
        elseif amt > 0 and resource == "runic_power" then
            if state.set_bonus.tier20_2pc == 1 and state.buff.pillar_of_frost.up then
                virtual_rp_spent_since_pof = virtual_rp_spent_since_pof + amt

                state.applyBuff( "pillar_of_frost", state.buff.pillar_of_frost.remains + floor( virtual_rp_spent_since_pof / 60 ) )
                virtual_rp_spent_since_pof = virtual_rp_spent_since_pof % 60
            end
        end
    end

    spec:RegisterHook( "spend", spendHook )

    local gainHook = function( amt, resource )
        if resource == 'runes' then
            local r = state.runes
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
        cold_heart = {
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
            duration = 31.199,
            type = "Disease",
            max_stack = 1,
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


    spec:RegisterStateExpr( "rune", function ()
        return runes.current
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
            -- ready = 50,
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
            
            recheck = function ()
                return buff.pillar_of_frost.remains - gcd, buff.pillar_of_frost.remains
            end,
            handler = function ()
                applyDebuff( "target", "chains_of_ice" )
                removeBuff( "cold_heart_item" )
                removeBuff( "cold_heart" )
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
            
            recheck = function () return gcd * 0.1, gcd * 0.2, gcd * 0.3, gcd * 0.4, gcd * 0.5, gcd * 0.6, gcd * 0.7, gcd * 0.8, gcd * 0.9, gcd end,
            handler = function ()
                stat.haste = state.haste + 0.15
                gain( 1, "runes" )
                gain( 5, "runic_power" )
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
            
            recheck = function () return buff.icy_talons.remains - gcd, buff.icy_talons.remains end,
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
    
        package = "Frost",
    } )


    spec:RegisterPack( "Frost", 20180713.1818, [[dO0SDbqisIweqPGhjbbAtavFsjmkssNIKQvbuk9kLOMLsKBjbbTlk(fuyyaKJbOwga1ZKannscxtcPTHIOVbusJdfPCoGsSojG5Hc19Gs7df1bLquluc1drrQ2OeeWhbkvnsGsrNucIwjaMPeu7KKYpbkfAOsqilvcHNIstffCvjiuFfOuzSOizVK6VegmOdRyXq1JjAYs6YiBwP(mLmAk1Pf9AOOzJQBlr7wLFlmCL0Xrry5s9CitNQRtITJc57az8sq68afRxcrMpGSFvTgyndA264KwnadiGzAacScCbnaZ0aMPbmyrZ6GzL0SRJeZXI0S3usA2cb6a5A21bm8yQAg0SOqPLKM129vubWadR0TvWnYOeduwQWhpJt2Z2XaLLsmW5bog47PqyLyeg0zLhHHKpiKOmQkCcHbskQ042cmV0Y2nY11cblmyTGacSOzXvsUxipnUMTooPvdWacyMgGaRaxqdWG1IY0ubtQzhf3oAnlytcZKNpu1DhLpKnlz6QRzResQzzWorpmrpCE46iXCSOhg7hospJ7H8e5OhUJ(HGnjmtEAEaEayWMEyrUquHFiOb9WYOM7KQpC3r5dDB6HfMSY4E4i9mUhYtKBE4dzWorpSKMd9q3E8hUvCLMEO0Eolc9qKDOWRpeNEivORK0F4GE4rGE4i9mUhYtKJE400dReJiESs1hUJ(HfVlYgnlprosZGMfpqI1i45zPzqRgWAg0S0n4CQQlwZk70PohnRpC6CJ142uNNLa5rxAOBW5uvZospJtZ2uz0iItiKauEo1AxRgG1mOzPBW5uvxSMv2PtDoAwCL920zjzuwFi4pSvocz8SKeEiuXdz8dv9HwY6dbBFiGFO6A2r6zCAw7aepplboFqU21QvqndAw6gCov1fRzLD6uNJMTvocz8SKeEiyYhY4hAjRpe8hQYh6dNo3ynUn15zjqE0Lg6gCov1SJ0Z40SbopDQhN0UwnvOzqZs3GZPQUynRStN6C0STYriJNLKWdHkEiJFOLS(qWFOQpugbVgGodEtJBlITaLxThRanMMkN8qpK5hcOhceqpSvUukwdquBQ0oLP)qMX(WccOhQUMDKEgNMnW5Pt94K21QvundAw6gCov1fRzLD6uNJMTvUukwdquBQ0oLP)qg)WI(qWFiICbECkiJNudmyrOIv5dz(Ha6HG)qze8Aa6m4nnUTi2cuE1ESc0yAQCYd9qMFiG0SJ0Z40S7oqUa5DIjPDTAmPMbnlDdoNQ6I1SYoDQZrZIRS3MoljJY6db)HetOKRRu1SsnIye1ZjjrSfUnji84eLt7GP1SJ0Z40SnvgnI4ecjaLNtT21Qbw1mOzPBW5uvxSMv2PtDoAwCL920zjzuwFi4pu1hIRS3MMkJgrCcHeGYZP2OS(qGa6HYi41a0zAQmAeXjesakpNAttLtEOhY8dTK1hceqpu1hQYhsmHsUUsvZk1iIrupNKeXw42KGWJtuoTdM(HG)qv(qF405gRXTPoplbYJU0q3GZP6dv)HQRzhPNXPzTdq88Se48b5AxRgttZGMLUbNtvDXAwzNo15Ozv5dXv2BtNLKrz9HG)qv(qvFOpC6CJ142uNNLa5rxAOBW5u9HG)qv(qvFOmcEnaDMMkJgrCcHeGYZP20u5Kh6Hm)qvFOLS(qW2hc4hQ(dbcOh2kh9qMFOkEO6pu9hc(dBLJEiZpSGA2r6zCA2aNNo1JtAxRgyrZGMLUbNtvDXAwzNo15OzBLlLI1ae1MkTtz6pKXpSGasZospJtZU7a5cK3jMK21QbmG0mOzPBW5uvxSMv2PtDoAwCL92GzY55zjkhPDEKPPr6pe8hQ6dv5djMqjxxPQbZG7zpiXrG2HYvfGso)Hab0drReNl8PTihz2DGCKemUn9qMX(qa)q11SJ0Z40S7oqoscg3M0UwnGbwZGMLUbNtvDXAwzNo15OzrReNl8PTihzS4JmhUyQmAoj9qMX(qaRzhPNXPzT4JmhUyQmAojPDTAadyndAw6gCov1fRzLD6uNJMfTsCUWN2ICKPPYOreNqibO8CQFiZyFiG1SJ0Z40SnvgnI4ecjaLNtT21QbCb1mOzPBW5uvxSMv2PtDoAw0kX5cFAlYrMDhihjbJBtpKzSpSGA2r6zCA2DhihjbJBtAxRgWQqZGMLUbNtvDXAwzNo15Ozv9HYi41a0zAQmAeXjesakpNAttLtEOhY4hQ6dTK1hc2(qa)q1Fiqa9qCL92ynUn15zjqE0LgKpsmFi2hcmGEO6pe8hkJGxdqNbVPXTfXwGYR2JvGgttLtEOhY8dBLJqgpljHhcv8qWFOpC6CJ142uNNLa5rxAOBW5uvZospJtZU7a5cK3jMK21QbCr1mOzPBW5uvxSMv2PtDoAwv(qCL920zjzuwFi4pu1hQYh6dNo3ynUn15zjqE0Lg6gCovFiqa9qze8Aa6mnvgnI4ecjaLNtTPPYjp0dz(HwY6dvxZospJtZg480PECs7A1aMj1mOzPBW5uvxSMv2PtDoAwze8Aa6m4nnUTi2cuE1ESc0yAQCYd9qMFyRCeY4zjj8qOcn7i9mon7UdKlqENysAx7AwzWRcBAAxZGwnG1mOzPBW5uvxSMv2PtDoAwCL92idEvytt7I0PsdYhjMpe7dbmGEi4pexzVnkNDWbJa5nDwUTPPr6pe8hkJGxdqNzn58PfXwS7a5MMkN8qpK5hYKA2r6zCAwP9KhseBrkjTRvdWAg0S0n4CQQlwZk70PohnlUYEBKbVkSPPDr6uPb5JeZhYm2hcmt(qWFiUYEBwtoFArSf7oqUrzvZospJtZkTN8qIylsjPDTAfuZGMLUbNtvDXAwzNo15OzXv2BZAY5tlITy3bYnkRpe8hIRS3M1KZNweBXUdKBAQCYd9qg)qlz9HG)qvFiUYEBKbVkSPPDr6uPb5JeZhYm2hcmWpeiGEOQpexzVnYGxf200UiDQ0G8rI5dzg7dbgqpe8hIixGhNcY4j1agqcvSkFiZpeqpu9hQUMDKEgNMvAp5HeXwKss7A1uHMbnlDdoNQ6I1SYoDQZrZIRS3gzWRcBAAxKovAq(iX8HmJ9HadwFi4pexzVnkNDWbJa5nDwUTPPr6pe8hIRS3gLZo4GrG8Mol320u5Kh6Hm(HwY6db)HYi41a0zwtoFArSf7oqUPPYjp0dz(HmPMDKEgNMvAp5HeXwKss7A1kQMbnlDdoNQ6I1SYoDQZrZIRS3gzWRcBAAxKovAq(iX8HmJ9HQ4HG)qFAlYnEwscpe1KEiJX(qlzvZospJtZkTN8qIylsjPDTRzR0Eu4UMbTAaRzqZospJtZokEig3hjMAw6gCov1fRDTAawZGMDKEgNMTmVQy3evKinlDdoNQ6I1UwTcQzqZs3GZPQUyn7i9monRC4CXi9mobprUMLNixCtjPzLrWRbOdPDTAQqZGMLUbNtvDXA2r6zCA2w5eJ0Z4e8e5AwzNo15Oz9HtNBWBACBrSfO8Q9yfOXq3GZP6db)HYi41a0zWBACBrSfO8Q9yfOX0u5Kh6Hm(HaxunlprU4MssZIhiXAe88S0UwTIQzqZs3GZPQUyn7i9monBRCIr6zCcEICnRStN6C0S1Wn4nnUTi2cuE1ESc0y8uIzEwAwEICXnLKMfpqcpLyMNL21QXKAg0S0n4CQQlwZospJtZ2kNyKEgNGNixZk70PohnlUYEBwtoFArSf7oqUrz9HG)qF405MaNNo1JNXzOBW5uvZYtKlUPK0SbopDQhpJt7A1aRAg0S0n4CQQlwZospJtZkhoxmspJtWtKRz5jYf3usAwKpxD6Q21UMDTjzuIpUMbTRzXdKWtjM5zPzqRgWAg0S0n4CQQlwZk70PohnBRCPuSgGO(HmJ9Hfeqpe8hQ6dv9H4k7TPZsYOS(qWFiXek56kvnRuJigr9CsseBHBtccpor50oy6hQ(dbcOhQ6d9HtNBSg3M68Seip6sdDdoNQpe8hQ6dXv2BttLrJioHqcq55uBAQCYd9qgJ9HwY6dbcOhQYhIRS3MMkJgrCcHeGYZP2OS(q1FO6puDn7i9monBtLrJioHqcq55uRDTAawZGMLUbNtvDXAwzNo15Ozv9HQ(Ww5sPynar9dzg7dbmGEi4perUapofKXtQbgSiuXQ8Hm)qa9q1Fiqa9Ww5sPynar9dzg7dliGEO6pe8hIRS3MoljJYQMDKEgNM1oaXZZsGZhKRDTAfuZGMLUbNtvDXAwzNo15OzrKlWJtbz8KAadibGxLpK5hcOhc(dBLlLI1ae1MkTtz6pKXyFiWf9HG)Ww5OhYySpSGpe8hIRS3M1KZNweBXUdKBuw1SJ0Z40S7oqUa5DIjPDTAQqZGMLUbNtvDXAwzNo15OzBLlLI1ae1pKXyFOkk6dbcOh2khHmEwscpef9Hm(HwYQMDKEgNMnW5Pt94K21QvundAw6gCov1fRzLD6uNJMTvUukwdquBQ0oLP)qMX(WccOhc(dBLJqgpljHhIc(qMFOLSQzhPNXPzTJ(eXwakpNATRvJj1mOzPBW5uvxSMv2PtDoAwCL92GzY55zjkhPDEKPPr6pe8hQ6dv5djMqjxxPQbZG7zpiXrG2HYvfGso)Hab0d9HtNBSg3M68Seip6sdDdoNQpeiGEiAL4CHpTf5iZUdKJKGXTPhYm2hc4hQUMDKEgNMD3bYrsW42K21Qbw1mOzPBW5uvxSMv2PtDoAw0kX5cFAlYrgl(iZHlMkJMtspKzSpeWA2r6zCAwl(iZHlMkJMtsAxRgttZGMLUbNtvDXAwzNo15OzrReNl8PTihzAQmAeXjesakpN6hYm2hcyn7i9monBtLrJioHqcq55uRDTAGfndAw6gCov1fRzLD6uNJMTvUukwdquBQ0oLP)qMFiGl6dbcOh2kh9qMFyb1SJ0Z40SbopDQhN0UwnGbKMbnlDdoNQ6I1SYoDQZrZ2kxkfRbiQFiJFybb0db)HTYriJNLKWdbGFiZp0sw1SJ0Z40Su5AaIArRCcq0SgN21UMvgbVgGoKMbTAaRzqZs3GZPQUynRStN6C0STYLsXAaIAtL2Pm9hYm2hcya9qWFOkFOpC6CdEtJBlITaLxThRang6gCov1SJ0Z40StlNJeE0nDU21QbyndAw6gCov1fRzLD6uNJMTgUbVPXTfXwGYR2JvGgJNsmZZ6HG)Ww5sPynarTPs7uM(dzg7dlkGEi4pSvo6Hm(HawZospJtZoTCos4r305AxRwb1mOzPBW5uvxSMv2PtDoAwCL92SMC(0Iyl2DGCJYQMDKEgNMfNhrvSvAWODTAQqZGMLUbNtvDXAwzNo15OzXv2BZAY5tlITy3bYnkRA2r6zCAwCQruJzEwAxRwr1mOzhPNXPzvqKiDQePzPBW5uvxS21QXKAg0S0n4CQQlwZospJtZ25zjITqgC(SIYZsSvCLMqAwzNo15Ozv9H4k7TXPYvF8modYhjMpe7db0db)H(0wKB8SKeEiQj9qMFitcOhQ(dbcOh6tBrUXZss4HOM0dz8dzsaPzVPK0SDEwIylKbNpRO8SeBfxPjK21Qbw1mOzPBW5uvxSMDKEgNM1o6teBbJgE0AwzNo15OzXv2BZAY5tlITy3bYnkRpe8hQ6dv5d9HtNBWBACBrSfO8Q9yfOXq3GZP6dbcOhQYhkJGxdqNbVPXTfXwGYR2JvGgttLtEOhY8db0dvxZEtjPzTJ(eXwWOHhT21QX00mOzPBW5uvxSMDKEgNMT2JILTlITafkCKMv2PtDoA2w5iKXZss4HOOpKXpSGpe8hQ6dv5dRHBWBACBrSfO8Q9yfOX4PeZ8SEiqa9Ww5sPynar9dz(HmjGEO6A2BkjnBThflBxeBbku4iTRvdSOzqZs3GZPQUynRStN6C0S4k7Tzn58PfXwS7a5gL1hc(dv9HQ8H(WPZn4nnUTi2cuE1ESc0yOBW5u9Hab0dRHBWBACBrSfO8Q9yfOX4PeZ8SEO6A2r6zCA21WZ40UwnGbKMbnlDdoNQ6I1SYoDQZrZQYh6dNo3G3042Iylq5v7XkqJHUbNtvn7i9mon7AY5tlITy3bY1UwnGbwZGMLUbNtvDXAwzNo15Oz9HtNBWBACBrSfO8Q9yfOXq3GZP6db)HYi41a0zWBACBrSfO8Q9yfOX00ubZdb)HTYLsXAaI6hY8dlkG0SJ0Z40SRjNpTi2IDhix7A1agWAg0S0n4CQQlwZk70PohnRpC6CdEtJBlITaLxThRang6gCovFi4pugbVgGodEtJBlITaLxThRanMMkN8qpK5hQcaPzhPNXPzxtoFArSf7oqU21QbCb1mOzPBW5uvxSMv2PtDoAwCL92SMC(0Iyl2DGCJYQMDKEgNMfVPXTfXwGYR2JvGgTRvdyvOzqZs3GZPQUyn7i9monRC4CXi9mobprUMv2PtDoAwIjuY1vQAKbVkSPP9hc(dv9HQ(qCL92idEvytt7I0PsdYhjMpKzSpeya9qWFyLWv2BtpfPOtjzq(iX8HyFyrFO6peiGEOpTf5gpljHhIAspKXyFOLS(q11S8e5IBkjnRm4vHnnTRDTRzdCE6upEgNMbTAaRzqZs3GZPQUynRStN6C0S(WPZnwJBtDEwcKhDPHUbNtvn7i9monBtLrJioHqcq55uRDTAawZGMLUbNtvDXAwzNo15Ozv9H4k7TbZKZZZsuos78iJY6db)HQ(qCL92GzY55zjkhPDEKPPr6peiGE4AtmsyjRgGn7oqUa5DIj9qGa6HRnXiHLSAa2yhG45zjW5dYFO6pu9hc(drReNl8PTihz2DGCKemUn9qMFiWA2r6zCA2DhihjbJBtAxRwb1mOzPBW5uvxSMv2PtDoAwvFiUYEBWm588SeLJ0opYOS(qWFOQpexzVnyMCEEwIYrANhzAAK(dbcOhU2eJewYQbyZUdKlqENyspeiGE4AtmsyjRgGn2biEEwcC(G8hQ(dv)Hab0dv9HOvIZf(0wKJm2biEEwcC(G8hYm2hwWhc(dv5dXv2BtNLKrz9HG)qv(qF405MDhihjbJBtg6gCovFO6A2r6zCA2aNNo1JtAxRMk0mOzPBW5uvxSMv2PtDoAwCL920zjzuwFi4peTsCUWN2ICKXoaXZZsGZhK)qMFiWA2r6zCAw7aepplboFqU21QvundAw6gCov1fRzLD6uNJMvLpexzVnDwsgL1hceqpSvocz8SKeEia(HmJ9HwY6dbcOh2kxkfRbiQnvANY0FiJFiGbKMDKEgNMD3bYfiVtmjTRvJj1mOzPBW5uvxSMv2PtDoAwCL920zjzuw1SJ0Z40S2biEEwcC(GCTRvdSQzqZospJtZg480PECsZs3GZPQUyTRDnlYNRoDvZGwnG1mOzPBW5uvxSMv2PtDoAwF405MucgHp84qg6gCovFi4pexzVnPemcF4XHmnvo5HEiJX(qlzvZospJtZU7a5cK3jMK21QbyndAw6gCov1fRzLD6uNJMv1hIRS3MoljJY6db)HetOKRRu1SsnIye1ZjjrSfUnji84eLt7GPFO6peiGEOpC6CJ142uNNLa5rxAOBW5uvZospJtZ2uz0iItiKauEo1AxRwb1mOzPBW5uvxSMv2PtDoAwvFiXek56kvnygCp7bjoc0ouUQauY5pe8h6dNo3S7OirNyvHJidDdoNQpe8hIixGhNcY4j1adweaEv(qSpe4hQ(dbcOh2khHmEwscpeQ4Hm(HwYQMDKEgNMnW5Pt94K21QPcndAw6gCov1fRzLD6uNJMTvUukwdquBQ0oLP)qg)qGbKMDKEgNMD3bYfiVtmjTRvROAg0S0n4CQQlwZk70PohnlUYEB6SKmkRA2r6zCAw7aepplboFqU21QXKAg0S0n4CQQlwZk70PohnRQpKycLCDLQgmdUN9GehbAhkxvak58hc(d9HtNB2DuKOtSQWrKHUbNt1hc(drKlWJtbz8KAGblcaVkFi2hc8dv)Hab0dBLJqgpljHhII(qg)qlzvZospJtZg480PECs7A1aRAg0S0n4CQQlwZk70PohnBRCPuSgGO2uPDkt)Hm(Hadin7i9mon7UdKlqENysAxRgttZGMLUbNtvDXAwzNo15OzXv2BdMjNNNLOCK25rMMgP)qWFOQpuLpKycLCDLQgmdUN9GehbAhkxvak58hceqpeTsCUWN2ICKz3bYrsW420dzg7db8dvxZospJtZU7a5ijyCBs7A1alAg0S0n4CQQlwZk70PohnlUYEBWm588SeLJ0opY00iDn7i9monBGZtN6XjTRvdyaPzqZs3GZPQUynRStN6C0STYLsXAaIAtL2Pm9hY4hcyaPzhPNXPz3DGCbY7ets7A1agyndAw6gCov1fRzLD6uNJMfTsCUWN2ICKPPYOreNqibO8CQFiZyFiG1SJ0Z40SnvgnI4ecjaLNtT21QbmG1mOzPBW5uvxSMv2PtDoAw0kX5cFAlYrgl(iZHlMkJMtspKzSpeWA2r6zCAwl(iZHlMkJMtsAxRgWfuZGMLUbNtvDXAwzNo15OzrReNl8PTihz2DGCKemUn9qMX(WcQzhPNXPz3DGCKemUnPDTAaRcndAw6gCov1fRzLD6uNJMvLp0hoDUXACBQZZsG8Oln0n4CQ(qGa6HYi41a0zAQmAeXjesakpNAttLtEOhY8dv9HwY6dbBFiGFO6A2r6zCA2aNNo1JtAxRgWfvZGMLUbNtvDXAwzNo15OzBLJqgpljHhca)qMFOLS(qGa6HQ8H(WPZn7oks0jwv4iYq3GZPQMDKEgNM1o6teBbO8CQ1UwnGzsndA2r6zCA2DhixG8oXK0S0n4CQQlw7A1agSQzqZs3GZPQUynRStN6C0SQ8H(WPZnwJBtDEwcKhDPHUbNt1hceqp0hoDUjLGr4dpoKHUbNtvn7i9monBGZtN6XjTRvdyMMMbnlDdoNQ6I1SYoDQZrZQYh6dNo3G3042Iylq5v7XkqJHUbNt1hceqp0N2ICJNLKWdrnPhY4hkJGxdqNbVPXTfXwGYR2JvGgttLtEin7i9monlvUgGOw0khjarZACAx7AxZcA6lplKMfSRixeQvivdSVap8HmytpmlxJ2F4o6hUa5ZvNUU4HnXekzt1hIIs6HJIhLJt1hkTNZIqMhGcNh9WcwGhwe0kFKu9HlALJmm1IhckD7hUOvoczyQfpuvGlu1npafop6HmzbEyrqR8rs1hUOvoYWulEiO0TF4Iw5iKHPw8qvbUqv38au48OhcSkkWdzWorpKoVbZdL2Ket0dDB6HYi41a09WD0pCHmcEnaDMMkJgrCcHeGYZP20u5KhAXdbzNs7hkN7H40dBcPW9hM3dJA9H4K9WOm6hM7hUqgbVgGottLrJioHqcq55uBAQCYdT4Hj6HEyzXP6dJ9gJAIgCovnpafop6Hax0c8WIGw5JKQpCrRCKHPw8qqPB)WfTYridtT4HQcCHQU5bOW5rpeyMwbEid2j6H05nyEO0MKyIEOBtpugbVgGUhUJ(HlKrWRbOZG3042Iylq5v7XkqJPPYjp0IhcYoL2puo3dXPh2esH7pmVhg16dXj7Hrz0pm3pCHmcEnaDg8Mg3weBbkVApwbAmnvo5Hw8We9qpSS4u9HXEJrnrdoNQMhGhaWUICrOwHunW(c8WhYGn9WSCnA)H7OF4czWRcBAAFXdBIjuYMQpefL0dhfpkhNQpuApNfHmpafop6HaxGhYGDIEiDEdMhkTjjMOh620dLrWRbO7H7OF4cze8Aa6mRjNpTi2IDhi30u5KhAXdbzNs7hkN7H40dBcPW9hM3dJA9H4K9WOm6hM7hUqgbVgGoZAY5tlITy3bYnnvo5Hw8We9qpSS4u9HXEJrnrdoNQMhGcNh9WcwGhY0JJru7u9HkNmUA6zCd)HlqKlWJtbz8KAadiHkwLlEOhpCbICbECkiJNudyajuXQelWlEOQaxOQBEakCE0dvrbEid2j6H05nyEO0MKyIEOBtpugbVgGUhUJ(HlKrWRbOZSMC(0Iyl2DGCttLtEOfpeKDkTFOCUhItpSjKc3FyEpmQ1hIt2dJYOFyUF4cze8Aa6mRjNpTi2IDhi30u5KhAXdt0d9WYIt1hg7ng1en4CQAEaEaa7kYfHAfs1a7lWdFid20dZY1O9hUJ(HlQ0Eu4(Ih2etOKnvFikkPhokEuoovFO0EolczEakCE0dbUapSq8HuwxJ2P6dhPNX9WfJIhIX9rI5cZdqHZJEOkkWdzWorpKoVbZdL2Ket0dDB6HYi41a09WD0pCHmcEnaDg8Mg3weBbkVApwbAmnvo5Hw8qq2P0(HY5Eio9WMqkC)H59WOwFiozpmkJ(H5(HlKrWRbOZG3042Iylq5v7XkqJPPYjp0IhMOh6HLfNQpm2BmQjAW5u18a8aa2vKlc1kKQb2xGh(qgSPhMLRr7pCh9dxGhiHNsmZZAXdBIjuYMQpefL0dhfpkhNQpuApNfHmpafop6HaxGhY0JJru7u9HkNmUA6zCd)HlWv2BttLrJioHqcq55uBAQCYdT4HE8Wf4k7TPPYOreNqibO8CQnkRlEOQaxOQBEakCE0dbCbEitpogrTt1hQCY4QPNXn8hUarUapofKXtQbgSiuXQCXd94HlqKlWJtbz8KAGblcvSkXc8IhQkWfQ6MhGcNh9WcwGhY0JJru7u9HkNmUA6zCd)HlqKlWJtbz8KAadibGxLlEOhpCbICbECkiJNudyaja8QelWlEOQaxOQBEakCE0dvrbEyrqR8rs1hUOvoYWulEiO0TF4Iw5iKHPw8qvbUqv38au48Ohw0c8WIGw5JKQpCrRCKHPw8qqPB)WfTYridtT4HQcCHQU5bOW5rpeyavGhwi(qkRRr7u9HJ0Z4E4cQCnarTOvobiAwJBH5bOW5rpeyavGhwe0kFKu9HlALJmm1IhckD7hUOvoczyQfpuvGlu1npapaGDf5IqTcPAG9f4HpKbB6Hz5A0(d3r)WfbopDQhpJBXdBIjuYMQpefL0dhfpkhNQpuApNfHmpafop6HfTapSiOv(iP6dx0khzyQfpeu62pCrRCeYWulEOQaxOQBEaEaa7kYfHAfs1a7lWdFid20dZY1O9hUJ(HlKrWRbOdT4HnXekzt1hIIs6HJIhLJt1hkTNZIqMhGcNh9qWAbEitpogrTt1hQCY4QPNXn8hUqgbVgGodEtJBlITaLxThRanMMkN8qlEOhpCHmcEnaDg8Mg3weBbkVApwbAmnvo5HygqlEOQaxOQBEakCE0dbRf4HmyNOhsN3G5HsBsIj6HUn9qze8Aa6E4o6hUqgbVgGodEtJBlITaLxThRanMMkN8qlEii7uA)q5CpeNEytifU)W8EyuRpeNShgLr)WC)WfYi41a0zWBACBrSfO8Q9yfOX0u5KhAXdt0d9WYIt1hg7ng1en4CQAEakCE0dzAf4HfbTYhjvF4Iw5idtT4HGs3(HlALJqgMAXdvf4cvDZdqHZJEiWaUapKb7e9q68gmpuAtsmrp0TPhkJGxdq3d3r)WfYi41a0zWBACBrSfO8Q9yfOX0u5KhAXdbzNs7hkN7H40dBcPW9hM3dJA9H4K9WOm6hM7hUqgbVgGodEtJBlITaLxThRanMMkN8qlEyIEOhwwCQ(WyVXOMObNtvZdWdayxrUiuRqQgyFbE4dzWMEywUgT)WD0pCbEGeRrWZZAXdBIjuYMQpefL0dhfpkhNQpuApNfHmpafop6HaUapSiOv(iP6dx0khzyQfpeu62pCrRCeYWulEOQaxOQBEakCE0dlybEyrqR8rs1hUOvoYWulEiO0TF4Iw5iKHPw8qvbUqv38au48OhQIc8WIGw5JKQpCrRCKHPw8qqPB)WfTYridtT4HQcCHQU5bOW5rpuff4Hm94ye1ovFOYjJRMEg3WF4cze8Aa6m4nnUTi2cuE1ESc0yAQCYdT4HE8WfYi41a0zWBACBrSfO8Q9yfOX0u5KhIzaT4HQcCHQU5bOW5rpuff4HmyNOhsN3G5HsBsIj6HUn9qze8Aa6E4o6hUqgbVgGodEtJBlITaLxThRanMMkN8qlEii7uA)q5CpeNEytifU)W8EyuRpeNShgLr)WC)WfYi41a0zWBACBrSfO8Q9yfOX0u5KhAXdt0d9WYIt1hg7ng1en4CQAEakCE0dlAbEitpogrTt1hQCY4QPNXn8hUarUapofKXtQbgSiuXQCXd94HlqKlWJtbz8KAGblcvSkXc8IhQkWfQ6MhGcNh9WIwGhY0JJru7u9HkNmUA6zCd)HlKrWRbOZG3042Iylq5v7XkqJPPYjp0Ih6XdxiJGxdqNbVPXTfXwGYR2JvGgttLtEiMb0IhQkWfQ6MhGcNh9WIwGhYGDIEiDEdMhkTjjMOh620dLrWRbO7H7OF4cze8Aa6m4nnUTi2cuE1ESc0yAQCYdT4HGStP9dLZ9qC6HnHu4(dZ7HrT(qCYEyug9dZ9dxiJGxdqNbVPXTfXwGYR2JvGgttLtEOfpmrp0dllovFyS3yut0GZPQ5bOW5rpeSwGhYGDIEiDEdMhkTjjMOh620dLrWRbO7H7OF4cze8Aa6mnvgnI4ecjaLNtTPPYjp0IhcYoL2puo3dXPh2esH7pmVhg16dXj7Hrz0pm3pCHmcEnaDMMkJgrCcHeGYZP20u5KhAXdt0d9WYIt1hg7ng1en4CQAEakCE0dzAf4HmyNOhsN3G5HsBsIj6HUn9qze8Aa6E4o6hUqgbVgGottLrJioHqcq55uBAQCYdT4HGStP9dLZ9qC6HnHu4(dZ7HrT(qCYEyug9dZ9dxiJGxdqNPPYOreNqibO8CQnnvo5Hw8We9qpSS4u9HXEJrnrdoNQMhGcNh9qGvrbEyrqR8rs1hUOvoYWulEiO0TF4Iw5iKHPw8qvbUqv38au48OhcSkkWdzWorpKoVbZdL2Ket0dDB6HYi41a09WD0pCHmcEnaDMMkJgrCcHeGYZP20u5KhAXdbzNs7hkN7H40dBcPW9hM3dJA9H4K9WOm6hM7hUqgbVgGottLrJioHqcq55uBAQCYdT4Hj6HEyzXP6dJ9gJAIgCovnpafop6HaRIc8qgSt0dPZBW8qPnjXe9q3MEOmcEnaDpCh9dxiJGxdqNbVPXTfXwGYR2JvGgttLtEOfpeKDkTFOCUhItpSjKc3FyEpmQ1hIt2dJYOFyUF4cze8Aa6m4nnUTi2cuE1ESc0yAQCYdT4Hj6HEyzXP6dJ9gJAIgCovnpafop6Hax0c8qgSt0dPZBW8qPnjXe9q3MEOmcEnaDpCh9dxiJGxdqNPPYOreNqibO8CQnnvo5Hw8qq2P0(HY5Eio9WMqkC)H59WOwFiozpmkJ(H5(HlKrWRbOZ0uz0iItiKauEo1MMkN8qlEyIEOhwwCQ(WyVXOMObNtvZdqHZJEiWmzbEyrqR8rs1hUOvoYWulEiO0TF4Iw5iKHPw8qvbUqv38au48OhcmtwGhYGDIEiDEdMhkTjjMOh620dLrWRbO7H7OF4cze8Aa6m4nnUTi2cuE1ESc0yAQCYdT4HGStP9dLZ9qC6HnHu4(dZ7HrT(qCYEyug9dZ9dxiJGxdqNbVPXTfXwGYR2JvGgttLtEOfpmrp0dllovFyS3yut0GZPQ5b4bOqwUgTt1hcwF4i9mUhYtKJmpaAw0kj1Qb4IcSMDTJDYjn7i9mo0YyXyu8qmUpsmFaEaWaJhwipN6wz1FagPNXHwglgL5vf7MOIe9a8aGbgpKPBhbIEyrUquHFagPNXHwglgYHZfJ0Z4e8e5lDtjHvgbVgGo0dWi9mo0YyXOvoXi9mobpr(s3usyXdKyncEEwlLBS(WPZn4nnUTi2cuE1ESc0yOBW5ufCze8Aa6m4nnUTi2cuE1ESc0yAQCYdXyGl6dWi9mo0YyXOvoXi9mobpr(s3usyXdKWtjM5zTuUXwd3G3042Iylq5v7XkqJXtjM5z9amspJdTmwmALtmspJtWtKV0nLe2aNNo1JNXTuUXIRS3M1KZNweBXUdKBuwb3hoDUjW5Pt94zCg6gCovFagPNXHwglgYHZfJ0Z4e8e5lDtjHf5ZvNU(a8aGbgpeSHIBAC7hg7hYMxThRanpCncEEwpSdF8mUhwGhI8PD0dbUOOhIt7OPh620dL1hItYOKqpCy0K8bNtGn8amspJdzWdKyncEEwlJfJMkJgrCcHeGYZPEPCJ1hoDUXACBQZZsG8Oln0n4CQ(amspJdzWdKyncEEwlJfd7aepplboFq(s5glUYEB6SKmkRG3khz8SKeEiubJv1swbBbS6paJ0Z4qg8ajwJGNN1YyXiW5Pt940s5gBRCKXZss4HGjzSLScUk9HtNBSg3M68Seip6sdDdoNQpaJ0Z4qg8ajwJGNN1YyXiW5Pt940s5gBRCKXZss4Hqfm2swbxvze8Aa6m4nnUTi2cuE1ESc0yAQCYdbeqTYLsXAaIAtL2PmDMXwqaP(dWi9moKbpqI1i45zTmwm2DGCbY7etAPCJTvUukwdquBQ0oLPZ4IcoICbECkiJNudmyrOIvj4Yi41a0zWBACBrSfO8Q9yfOX0u5Kh6byKEghYGhiXAe88SwglgnvgnI4ecjaLNt9s5glUYEB6SKmkRGtmHsUUsvZk1iIrupNKeXw42KGWJtuoTdM(byKEghYGhiXAe88Swglg2biEEwcC(G8LYnwCL920zjzuwbxvCL920uz0iItiKauEo1gLvGasgbVgGottLrJioHqcq55uBAQCYdXSLSceqQQsIjuY1vQAwPgrmI65KKi2c3MeeECIYPDW0GRsF405gRXTPoplbYJU0q3GZPQ6Q)amspJdzWdKyncEEwlJfJaNNo1JtlLBSQexzVnDwsgLvWvPQ(WPZnwJBtDEwcKhDPHUbNtvWvPQYi41a0zAQmAeXjesakpNAttLtEiMv1swbBbS6abuRCeZQqD1bVvoI5c(amspJdzWdKyncEEwlJfJDhixG8oXKwk3yBLlLI1ae1MkTtz6mUGa6byKEghYGhiXAe88Swglg7oqoscg3Mwk3yXv2BdMjNNNLOCK25rMMgPdUQQKycLCDLQgmdUN9GehbAhkxvak5CGacTsCUWN2ICKz3bYrsW42eZybS6paJ0Z4qg8ajwJGNN1YyXWIpYC4IPYO5K0s5glAL4CHpTf5iJfFK5WftLrZjjMXc4hGr6zCidEGeRrWZZAzSy0uz0iItiKauEo1lLBSOvIZf(0wKJmnvgnI4ecjaLNtnZyb8dWi9moKbpqI1i45zTmwm2DGCKemUnTuUXIwjox4tBroYS7a5ijyCBIzSf8byKEghYGhiXAe88Swglg7oqUa5DIjTuUXQQmcEnaDMMkJgrCcHeGYZP20u5KhIXQAjRGTawDGacxzVnwJBtDEwcKhDPb5JetSadi1bxgbVgGodEtJBlITaLxThRanMMkN8qm3khz8SKeEiub4(WPZnwJBtDEwcKhDPHUbNt1hGr6zCidEGeRrWZZAzSye480PECAPCJvL4k7TPZsYOScUQQ0hoDUXACBQZZsG8Oln0n4CQceqYi41a0zAQmAeXjesakpNAttLtEiMTKv1FagPNXHm4bsSgbppRLXIXUdKlqENyslLBSYi41a0zWBACBrSfO8Q9yfOX0u5KhI5w5iJNLKWdHkEaEaWaJhwCtJB)Wy)q28Q9yfO5HkREwspSdF8mUhGr6zCidEGeEkXmpRLXIrtLrJioHqcq55uVuUX2kxkfRbiQzgBbbe4QQkUYEB6SKmkRGtmHsUUsvZk1iIrupNKeXw42KGWJtuoTdMwDGasvF405gRXTPoplbYJU0q3GZPk4QIRS3MMkJgrCcHeGYZP20u5KhIXyTKvGasL4k7TPPYOreNqibO8CQnnvo5HuxD1FagPNXHm4bs4PeZ8Swglg2biEEwcC(G8LYnwvvTvUukwdquZmwadiWrKlWJtbz8KAGblcvSkvhiGALlLI1ae1mJTGasDWXv2BtNLKrz9byKEghYGhiHNsmZZAzSyS7a5cK3jM0s5glICbECkiJNudyaja8Qe8w5sPynarTPs7uMoJXcCrbVvoIXyli44k7Tzn58PfXwS7a5gL1hGr6zCidEGeEkXmpRLXIrGZtN6XPLYn2w5sPynarnJXQIIceqTYrgpljHhIIYylz9byKEghYGhiHNsmZZAzSyyh9jITauEo1lLBSTYLsXAaIAtL2PmDMXwqabERCKXZss4HOGmBjRpaJ0Z4qg8aj8uIzEwlJfJDhihjbJBtlLBS4k7TbZKZZZsuos78ittJ0bxvvsmHsUUsvdMb3ZEqIJaTdLRkaLCoqa5dNo3ynUn15zjqE0Lg6gCovbci0kX5cFAlYrMDhihjbJBtmJfWQ)amspJdzWdKWtjM5zTmwmS4JmhUyQmAojTuUXIwjox4tBroYyXhzoCXuz0CsIzSa(byKEghYGhiHNsmZZAzSy0uz0iItiKauEo1lLBSOvIZf(0wKJmnvgnI4ecjaLNtnZyb8dWi9moKbpqcpLyMN1YyXiW5Pt940s5gBRCPuSgGO2uPDktNzaxuGaQvoI5c(amspJdzWdKWtjM5zTmwmOY1ae1Iw5eGOznULYn2w5sPynarnJliGaVvoY4zjj8qayMTK1hGhamW4HfXiZHJEagPNXHmYi41a0HwglgtlNJeE0nD(s5gBRCPuSgGO2uPDktNzSagqGRsF405g8Mg3weBbkVApwbAm0n4CQ(amspJdzKrWRbOdTmwmMwohj8OB68LYn2A4g8Mg3weBbkVApwbAmEkXmplWBLlLI1ae1MkTtz6mJTOac8w5igd4hGr6zCiJmcEnaDOLXIbopIQyR0GzPCJfxzVnRjNpTi2IDhi3OS(amspJdzKrWRbOdTmwmWPgrnM5zTuUXIRS3M1KZNweBXUdKBuwFaEaWaJhc24viubrpmDQmqpaJ0Z4qgze8Aa6qlJfdfejsNkrpaJ0Z4qgze8Aa6qlJfdfejsNkx6MscBNNLi2czW5ZkkplXwXvAcTuUXQkUYEBCQC1hpJZG8rIjwabUpTf5gpljHhIAsmZKasDGaYN2ICJNLKWdrnjgZKa6byKEghYiJGxdqhAzSyOGir6u5s3usyTJ(eXwWOHh9s5glUYEBwtoFArSf7oqUrzfCvvPpC6CdEtJBlITaLxThRang6gCovbcivkJGxdqNbVPXTfXwGYR2JvGgttLtEi1FagPNXHmYi41a0HwglgkisKovU0nLe2Apkw2Ui2cuOWrlLBSTYrgpljHhIIY4ccUQQSgUbVPXTfXwGYR2JvGgJNsmZZciGALlLI1ae1mZKas9hGhamW4HfYRqOmkXh)HRHNX9amspJdzKrWRbOdTmwmwdpJBPCJfxzVnRjNpTi2IDhi3OScUQQ0hoDUbVPXTfXwGYR2JvGgdDdoNQabunCdEtJBlITaLxThRangpLyMNL6papayGXdleLC(0pm2pSqGoq(dWi9moKrgbVgGo0YyXyn58PfXwS7a5lLBSQ0hoDUbVPXTfXwGYR2JvGgdDdoNQpaJ0Z4qgze8Aa6qlJfJ1KZNweBXUdKVuUX6dNo3G3042Iylq5v7XkqJHUbNtvWLrWRbOZG3042Iylq5v7XkqJPPPcgWBLlLI1ae1mxua9amspJdzKrWRbOdTmwmwtoFArSf7oq(s5gRpC6CdEtJBlITaLxThRang6gCovbxgbVgGodEtJBlITaLxThRanMMkN8qmRca9a8aGbgpKHK6hcmGa0dLrWRbOd9WLFitp41hc2KM2FagPNXHmYi41a0Hwglg4nnUTi2cuE1ESc0SuUXIRS3M1KZNweBXUdKBuwFagPNXHmYi41a0HwglgYHZfJ0Z4e8e5lDtjHvg8QWMM2xk3yjMqjxxPQrg8QWMM2bxvvXv2BJm4vHnnTlsNkniFKyYmwGbe4vcxzVn9uKIoLKb5JetSfvDGaYN2ICJNLKWdrnjgJ1swv)b4badmEitp41hc2KM2FOmUA6zCdh9amspJdzKbVkSPP9LXIH0EYdjITiL0s5glUYEBKbVkSPPDr6uPb5JetSagqGJRS3gLZo4GrG8Mol3200iDWLrWRbOZSMC(0Iyl2DGCttLtEiMzYhGr6zCiJm4vHnnTVmwmK2tEirSfPKwk3yXv2BJm4vHnnTlsNkniFKyYmwGzsWXv2BZAY5tlITy3bYnkRpaJ0Z4qgzWRcBAAFzSyiTN8qIylsjTuUXIRS3M1KZNweBXUdKBuwbhxzVnRjNpTi2IDhi30u5KhIXwYk4QIRS3gzWRcBAAxKovAq(iXKzSadmqaPkUYEBKbVkSPPDr6uPb5JetMXcmGahrUapofKXtQbmGeQyvQU6paJ0Z4qgzWRcBAAFzSyiTN8qIylsjTuUXIRS3gzWRcBAAxKovAq(iXKzSadwbhxzVnkNDWbJa5nDwUTPPr6GJRS3gLZo4GrG8Mol320u5KhIXwYk4Yi41a0zwtoFArSf7oqUPPYjpeZm5dWi9moKrg8QWMM2xglgs7jpKi2IuslLBS4k7Trg8QWMM2fPtLgKpsmzgRka3N2ICJNLKWdrnjgJ1swFaEaWaJhc2iopDQhpJ7HD4JNX9amspJdzcCE6upEg3YyXOPYOreNqibO8CQxk3y9HtNBSg3M68Seip6sdDdoNQpaJ0Z4qMaNNo1JNXTmwm2DGCKemUnTuUXQkUYEBWm588SeLJ0opYOScUQ4k7TbZKZZZsuos78ittJ0bcO1MyKWswnaB2DGCbY7etciGwBIrclz1aSXoaXZZsGZhKRU6GJwjox4tBroYS7a5ijyCBIzGFagPNXHmbopDQhpJBzSye480PECAPCJvvCL92GzY55zjkhPDEKrzfCvXv2BdMjNNNLOCK25rMMgPdeqRnXiHLSAa2S7a5cK3jMeqaT2eJewYQbyJDaINNLaNpixD1bcivrReNl8PTihzSdq88Se48b5mJTGGRsCL920zjzuwbxL(WPZn7oqoscg3Mm0n4CQQ(dWi9moKjW5Pt94zClJfd7aepplboFq(s5glUYEB6SKmkRGJwjox4tBroYyhG45zjW5dYzg4hGr6zCitGZtN6XZ4wglg7oqUa5DIjTuUXQsCL920zjzuwbcOw5iJNLKWdbWmJ1swbcOw5sPynarTPs7uMoJbmGEagPNXHmbopDQhpJBzSyyhG45zjW5dYxk3yXv2BtNLKrz9byKEghYe480PE8mULXIrGZtN6XPhGhamW4HS(C1PRpSdF8mUhGr6zCidYNRoDDzSyS7a5cK3jM0s5gRpC6CtkbJWhECidDdoNQGJRS3MucgHp84qMMkN8qmgRLS(amspJdzq(C1PRlJfJMkJgrCcHeGYZPEPCJvvCL920zjzuwbNycLCDLQMvQreJOEojjITWTjbHhNOCAhmT6abKpC6CJ142uNNLa5rxAOBW5u9byKEghYG85QtxxglgbopDQhNwk3yvLycLCDLQgmdUN9GehbAhkxvak5CW9HtNB2DuKOtSQWrKHUbNtvWrKlWJtbz8KAGblcaVkXcS6abuRCKXZss4Hqfm2swFagPNXHmiFU601LXIXUdKlqENyslLBSTYLsXAaIAtL2PmDgdmGEagPNXHmiFU601LXIHDaINNLaNpiFPCJfxzVnDwsgL1hGr6zCidYNRoDDzSye480PECAPCJvvIjuY1vQAWm4E2dsCeODOCvbOKZb3hoDUz3rrIoXQchrg6gCovbhrUapofKXtQbgSia8QelWQdeqTYrgpljHhIIYylz9byKEghYG85Qtxxglg7oqUa5DIjTuUX2kxkfRbiQnvANY0zmWa6byKEghYG85Qtxxglg7oqoscg3Mwk3yXv2BdMjNNNLOCK25rMMgPdUQQKycLCDLQgmdUN9GehbAhkxvak5CGacTsCUWN2ICKz3bYrsW42eZybS6paJ0Z4qgKpxD66YyXiW5Pt940s5glUYEBWm588SeLJ0opY00i9hGr6zCidYNRoDDzSyS7a5cK3jM0s5gBRCPuSgGO2uPDktNXagqpaJ0Z4qgKpxD66YyXOPYOreNqibO8CQxk3yrReNl8PTihzAQmAeXjesakpNAMXc4hGr6zCidYNRoDDzSyyXhzoCXuz0CsAPCJfTsCUWN2ICKXIpYC4IPYO5KeZyb8dWi9moKb5ZvNUUmwm2DGCKemUnTuUXIwjox4tBroYS7a5ijyCBIzSf8byKEghYG85QtxxglgbopDQhNwk3yvPpC6CJ142uNNLa5rxAOBW5ufiGKrWRbOZ0uz0iItiKauEo1MMkN8qmRQLSc2cy1FagPNXHmiFU601LXIHD0Ni2cq55uVuUX2khz8SKeEiamZwYkqaPsF405MDhfj6eRkCezOBW5u9byKEghYG85Qtxxglg7oqUa5DIj9amspJdzq(C1PRlJfJaNNo1JtlLBSQ0hoDUXACBQZZsG8Oln0n4CQceq(WPZnPemcF4XHm0n4CQ(amspJdzq(C1PRlJfdQCnarTOvosaIM14wk3yvPpC6CdEtJBlITaLxThRang6gCovbciFAlYnEwscpe1KySmcEnaDg8Mg3weBbkVApwbAmnvo5H0U21A]] )

end
