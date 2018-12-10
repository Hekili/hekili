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
        dead_of_winter = PTR and 3743 or nil, -- 287250 -- ADDED 8.1
        deathchill = 701, -- 204080
        decomposing_aura = not PTR and 45 or nil, -- 199720 -- DELETE 8.1
        delirium = 702, -- 233396
        frozen_center = not PTR and 704 or nil, -- 204135 -- DELETE 8.1
        heartstop_aura = 3439, -- 199719
        lichborne = PTR and 3742 or nil, -- 136187 -- ADDED 8.1
        necrotic_aura = 43, -- 199642
        overpowered_rune_weapon = not PTR and 705 or nil, -- 233394
        transfusion = PTR and 3749 or nil, -- 237515/
        tundra_stalker = not PTR and 703 or nil, -- 279941 -- DELETE 8.1  
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

        dead_of_winter = PTR and {
            id = 289959,
            duration = 4,
            max_stack = 5,
        } or nil,

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

        decomposing_aura = not PTR and {
            id = 199720,
            duration = 6,
            max_stack = 5
        } or nil,

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
        cold_hearted = PTR and {
            id = 288426,
            duration = 8,
            max_stack = 1
        } or nil,
        
        frostwhelps_indignation = PTR and {
            id = 287338,
            duration = 6,
            max_stack = 1,
        } or nil,

        glacial_contagion = not PTR and {
            id = 274074,
            duration = 14,
            max_stack = 1,
        } or nil,
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
            cooldown = function () return PTR and 20 or 25 end,
            gcd = "spell",
            
            spend = function () return PTR and 0 or 20 end,
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
            
            spend = function () return buff.dark_succor.up and 0 or ( ( buff.transfusion.up and 0.5 or 1 ) * ( PTR and 35 or 45 ) ) end, -- CHANGE 8.1
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
        

        lichborne = PTR and {
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
        } or nil,
        

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
            cooldown = PTR and function () return pvptalent.dead_of_winter.enabled and 45 or 20 end or 20, -- CHANGED 8.1
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


    spec:RegisterPack( "Frost DK", 20181026.1544, [[due)DbqiaLhjjL2Ke1OiQCkIIvbG8kOWSKeULKuyxe(fu0WKeDmvrltI4zaW0Ki11KG2gaQ(gakgNKu15KiPwhaknpvH7PkTpIshuskkluc8qjPsnrjsOlkrsQnkrIoPKuKvciVuIeCtjPs2jrv)uIKKHkjvSujsINc0uHs2lK)sLbtQdlSyv1Jrmzv6YO2mv9zj1OjsNw0RbOztYTvr7wPFRy4QWYL65inDkxhQ2oGQVteJxskQopuQ1ljz(sO9dA0tewiWByms(sQ8z1)SYsa4INfw6s)8jc0W(GrGhbbWOMrGBCYiWszpudQlflfqGhb2QjUiSqG0bVjmcuQzhuawmXSonP4FbzoXKMN4QWYzjD4nmP5jbZVA(y(9r14YahZJE8PIPywDAUujYlfZQtPIRuKdtQRuyZAPMRu2d1e08KGa)4PYQMw0hbEdJrYxsLpR(Nvwcax8SWsxsjLGadCt60iqW8S6gbknVxErFe4LPeey1c1LYEOguxkYHjfQlf2SwQbbQAHAPMDqbyXeZ60KI)fK5etAEIRclNL0H3WKMNem)Q5J53hvJldCmp6XNkMIz1P5sLiVumRoLkUsromPUsHnRLAUszputqZtceOQfQlvrS5ZnuxcaVcOUKkFw9qD1aQbaaBPReQRovxqGGavTqD1T0yRzkaleOQfQRgqD10su4xgQRUY9c1LYM5QybcuLuJIWcbsg11jLJ2qyHK)jcleiVXxXxubiqsNg3zGa)4EVGmQRtkhTjOwqaeQLfQleQld1w01SjS8KD24Ujd1pG6AYfbgelNfbsKg5sDJ3Legzi5lbHfcK34R4lQaeiPtJ7mqGYb1FCVxCKkv0UX789qnrZNrUuO(XluxtUqnab1Yb1pHAmGAYmQ7izf(EOMeS7tQZJ3ylAoUyd1Ya1flc1FCVxCKkv0UX789qnrZNrUuO(bu34llS8KD24aaulduxgQ)4EV4ivQODJ357HAc8deyqSCweirAKl1nExsyKHKhaiSqG8gFfFrfGajDACNbc8J79IJuPI2nENVhQjA(mYLc1pG6QhQld1FCVxGVshf2oQ18wBsfnFg5sH6hqDn5c1aeulhu)eQXaQjZOUJKv47HAsWUpPopEJTO54InulduxgQ)4EVaFLokSDuR5T2KkA(mYLc1LH6pU3losLkA34D(EOMa)abgelNfbsKg5sDJ3LegzidboFvAChwolclK8pryHa5n(k(Ikabs604odeOfkEnrDys5o3Ah1M(uWB8v8fbgelNfb2850uwXuQtsUg3idjFjiSqG8gFfFrfGajDACNbcuoO(YFCVx0rvtNewqTGaiu)aQleQlweQV8h37fDu10jHfnFg5sH6hq9ZkHAzG6YqnWGAlu8AcFpuJsW2KYcEJVIVqDzOgyq9h37fDEYc8dOUmutpyLYzrxZgviDKOYT29vb1GAzFHAaGadILZIaNVknUdJrgsEaGWcbYB8v8fvacK0PXDgiqGb1wO41e(EOgLGTjLf8gFfFH6YqnWG6pU3l68Kf4hqDzOMEWkLZIUMnQq6irLBT7RcQb1Y(c1aabgelNfboFvAChgJmK8LgHfcK34R4lQaeiPtJ7mqGYb1FCVxayQu5w7odI0CzrZbXG6IfHA5G6pU3lamvQCRDNbrAUSa)aQld1Yb1hndCxn5kEk89qnh16eqgQlweQpAg4UAYv8uiDKOYT29vb1G6IfH6JMbURMCfpf1QGKHYfxGhlHHAzGAzGAzG6Yqn9GvkNfDnBuHVhQrjyBszOw2xOUeeyqSCweOVhQrjyBszKHKVqewiqEJVIVOcqGKonUZabkhuF5pU3l6OQPtclOwqaeQFa1fc1flc1x(J79IoQA6KWIMpJCPq9dO(zLqTmqDzO(J79catLk3A3zqKMllAoiguxSiulhu)X9EbGPsLBT7misZLf4hqDzOwoO(OzG7QjxXtHVhQ5OwNaYqDXIq9rZa3vtUINcPJevU1UVkOguxSiuF0mWD1KR4POwfKmuU4c8yjmulduldcmiwolcC(Q04omgzi5b4iSqG8gFfFrfGajDACNbc8J79catLk3A3zqKMllAoiguxSiulhu)X9EbGPsLBT7misZLf4hqDzOwoO(OzG7QjxXtHVhQ5OwNaYqDXIq9rZa3vtUINcPJevU1UVkOguxSiuF0mWD1KR4POwfKmuU4c8yjmulduldcmiwolcC(Q04omgzi5byqyHa5n(k(Ikabs604odeOCqnWG6pU3l68Kf4hqDXIqDJVjXDms4wCzFssdQFa1pReQlweQB8LfwEYoBCLa1Yc11KlulduxgQPhSs5SORzJkQvbjdLlUapwcd1Y(c1LGadILZIaRvbjdLlUapwcJmK8vpcleiVXxXxubiqsNg3zGa)4EVOZtwGFa1LHA6bRuol6A2OcPJevU1UVkOgul7luxccmiwolcu6irLBT7RcQHmK8LAewiqEJVIVOcqGKonUZabkhuF5pU3l6OQPtclOwqaeQFa1fc1flc1x(J79IoQA6KWIMpJCPq9dO(zLqTmqDzOgyq9h37fDEYc8dOUyrOUX3K4ogjClUSpjPb1pG6Nvc1flc1n(YclpzNnUsGAzH6AYfQld1adQTqXRj89qnkbBtkl4n(k(IadILZIa99qnh16eqgzi5FwjcleiVXxXxubiqsNg3zGabgu)X9ErNNSa)aQlweQB8njUJrc3Il7tsAq9dO(zLqDXIqDJVSWYt2zJReOwwOUMCrGbXYzrG(EOMJADciJmK8pFIWcbYB8v8fvacK0PXDgiWpU3l68Kf4hiWGy5SiqPJevU1UVkOgYqY)SeewiqEJVIVOcqGKonUZabkhuF5pU3l6OQPtclOwqaeQFa1fc1flc1x(J79IoQA6KWIMpJCPq9dO(zLqTmqDzOgyqTfkEnHVhQrjyBszbVXxXxeyqSCwe48vPXDymYqY)eaiSqGbXYzrGZxLg3HXiqEJVIVOcqgYqGul2B0xewi5FIWcbgelNfb2850uwXuQtsUg3iqEJVIVOcqgs(sqyHa5n(k(Ikabs604odeizg1DKSIMpNMYkMsDsY14w08zKlfQF8c1La1aeuxtUqDzO2cfVMOomPCNBTJAtFk4n(k(IadILZIa99qnh16eqgzi5bacleiVXxXxubiqsNg3zGa)4EVOZtwGFGadILZIaLosu5w7(QGAidjFPryHa5n(k(Ikabs604odeiWG6pU3l89ufVUdCfLf4hqDzO2cfVMW3tv86oWvuwWB8v8fbgelNfboFvAChgJmK8fIWcbYB8v8fvacK0PXDgiWgFtI7yKWT4Y(KKgu)aQLdQFwiuJbuBHIxt04BsCHz8IhwoRG34R4ludqqnaGAzqGbXYzrG(EOMJADciJmK8aCewiqEJVIVOcqGKonUZab(X9EbGPsLBT7misZLf4hqDzOUXxwy5j7SXvAOw2xOUMCrGbXYzrG(EOgLGTjLrgsEagewiqEJVIVOcqGKonUZab24BsChJeUfx2NK0GAzHA5G6skeQXaQTqXRjA8njUWmEXdlNvWB8v8fQbiOgaqTmiWGy5SiW5RsJ7WyKHKV6ryHadILZIa99qnh16eqgbYB8v8fvaYqYxQryHadILZIaLo96gVtsUg3iqEJVIVOcqgs(NvIWcbgelNfbgnjw2zt38AiqEJVIVOcqgYqG)H6oMrLBnclK8pryHa5n(k(Ikabs604ode4h37fDEYc8deyqSCweO0rIk3A3xfudzi5lbHfcK34R4lQaeiPtJ7mqGYb1x(J79IoQA6KWcQfeaH6hqDHqDXIq9L)4EVOJQMojSO5Zixku)aQFwjulduxgQB8LfwEYoBCLgQFa11KluxgQB8njUJrc3Il7tsAqTSVqDjfc1LHAGb1wO41e(EOgLGTjLf8gFfFrGbXYzrGZxLg3HXidjpaqyHa5n(k(Ikabs604odeyJVSWYt2zJR0q9dOUMCH6YqDJVjXDms4wCzFssdQL9fQlPqeyqSCwe48vPXDymYqYxAewiqEJVIVOcqGKonUZab24BsChJeUfx2NK0G6hqDjvc1LHAYmQ7izfhPsfTB8oFput08zKlfQLfQB8LfwEYoBCLgQld10dwPCw01Srf1QGKHYfxGhlHHAzFH6sqGbXYzrG1QGKHYfxGhlHrgs(cryHa5n(k(Ikabs604odeOCq9L)4EVOJQMojSGAbbqO(buxiuxSiuF5pU3l6OQPtclA(mYLc1pG6Nvc1Ya1LH6gFtI7yKWT4Y(KKgu)aQlPsOUmutMrDhjR4ivQODJ357HAIMpJCPqTSqDJVSWYt2zJR0qDzOgyqTfkEnHVhQrjyBszbVXxXxeyqSCweOVhQ5OwNaYidjpahHfcK34R4lQaeiPtJ7mqGn(Me3XiHBXL9jjnO(buxsLqDzOMmJ6oswXrQur7gVZ3d1enFg5sHAzH6gFzHLNSZgxPrGbXYzrG(EOMJADciJmK8amiSqG8gFfFrfGajDACNbc8J79catLk3A3zqKMllWpG6YqDJVjXDms4wCzFssdQLfQLdQFwiuJbuBHIxt04BsCHz8IhwoRG34R4ludqqnaGAzG6Yqn9GvkNfDnBuHVhQrjyBszOw2xOUeeyqSCweOVhQrjyBszKHKV6ryHa5n(k(Ikabs604odeyJVjXDms4wCzFssdQL9fQLdQbqHqngqTfkEnrJVjXfMXlEy5ScEJVIVqnab1aaQLbQld10dwPCw01Srf(EOgLGTjLHAzFH6sqGbXYzrG(EOgLGTjLrgs(sncleiVXxXxubiqsNg3zGaLdQV8h37fDu10jHfuliac1pG6cH6IfH6l)X9ErhvnDsyrZNrUuO(bu)SsOwgOUmu34BsChJeUfx2NK0GAzFHA5GAauiuJbuBHIxt04BsCHz8IhwoRG34R4ludqqnaGAzG6YqnWGAlu8AcFpuJsW2KYcEJVIViWGy5SiW5RsJ7WyKHK)zLiSqG8gFfFrfGajDACNbcSX3K4ogjClUSpjPb1Y(c1Yb1aOqOgdO2cfVMOX3K4cZ4fpSCwbVXxXxOgGGAaa1YGadILZIaNVknUdJrgs(NpryHa5n(k(Ikabs604odeizg1DKSIJuPI2nENVhQjA(mYLc1Yc1n(YclpzNnUsd1LH6gFtI7yKWT4Y(KKgu)aQlDLqDzOMEWkLZIUMnQOwfKmuU4c8yjmul7luxccmiwolcSwfKmuU4c8yjmYqY)SeewiqEJVIVOcqGKonUZabkhuF5pU3l6OQPtclOwqaeQFa1fc1flc1x(J79IoQA6KWIMpJCPq9dO(zLqTmqDzOMmJ6oswXrQur7gVZ3d1enFg5sHAzH6gFzHLNSZgxPH6YqDJVjXDms4wCzFssdQFa1LUsOUmudmO2cfVMW3d1OeSnPSG34R4lcmiwolc03d1CuRtazKHK)jaqyHa5n(k(Ikabs604odeizg1DKSIJuPI2nENVhQjA(mYLc1Yc1n(YclpzNnUsd1LH6gFtI7yKWT4Y(KKgu)aQlDLiWGy5SiqFpuZrTobKrgYqGhntMZFyiSqY)eHfcK34R4lQaKHKVeewiqEJVIVOcqgsEaGWcbYB8v8fvaYqYxAewiqEJVIVOcqgs(cryHadILZIapglNfbYB8v8fvaYqgcmggHfs(NiSqG8gFfFrfGajDACNbc0cfVMOomPCNBTJAtFk4n(k(c1flc1Yb1rvCNgl89ufVoJppyQj6ybeQld10dwPCw01SrfnFonLvmL6KKRXnul7ludaOUmudmO(J79Iopzb(buldcmiwolcS5ZPPSIPuNKCnUrgs(sqyHa5n(k(Ikabs604odeOfkEnHVhQrjyBszbVXxXxeyqSCweyTkizOCXf4XsyKHKhaiSqG8gFfFrfGajDACNbcuoO(YFCVx0rvtNewqTGaiu)aQleQlweQV8h37fDu10jHfnFg5sH6hq9ZkHAzG6Yqnzg1DKSIMpNMYkMsDsY14w08zKlfQF8c1La1aeuxtUqDzO2cfVMOomPCNBTJAtFk4n(k(c1LHAGb1wO41e(EOgLGTjLf8gFfFrGbXYzrG(EOMJADciJmK8LgHfcK34R4lQaeiPtJ7mqGKzu3rYkA(CAkRyk1jjxJBrZNrUuO(XluxcudqqDn5c1LHAlu8AI6WKYDU1oQn9PG34R4lcmiwolc03d1CuRtazKHKVqewiqEJVIVOcqGKonUZab(X9ErNNSa)abgelNfbkDKOYT29vb1qgsEaocleiVXxXxubiqsNg3zGa)4EVaWuPYT2DgeP5Yc8deyqSCweOVhQrjyBszKHKhGbHfcK34R4lQaeiPtJ7mqGn(Me3XiHBXL9jjnO(bulhu)SqOgdO2cfVMOX3K4cZ4fpSCwbVXxXxOgGGAaa1YGadILZIaRvbjdLlUapwcJmK8vpcleiVXxXxubiqsNg3zGaLdQV8h37fDu10jHfuliac1pG6cH6IfH6l)X9ErhvnDsyrZNrUuO(bu)SsOwgOUmu34BsChJeUfx2NK0G6hqTCq9ZcHAmGAlu8AIgFtIlmJx8WYzf8gFfFHAacQbaulduxgQbguBHIxt47HAuc2MuwWB8v8fbgelNfb67HAoQ1jGmYqYxQryHa5n(k(Ikabs604odeyJVjXDms4wCzFssdQFa1Yb1pleQXaQTqXRjA8njUWmEXdlNvWB8v8fQbiOgaqTmiWGy5SiqFpuZrTobKrgs(NvIWcbgelNfb2850uwXuQtsUg3iqEJVIVOcqgs(NpryHadILZIa99qnkbBtkJa5n(k(Ikazi5FwccleiVXxXxubiqsNg3zGaLdQV8h37fDu10jHfuliac1pG6cH6IfH6l)X9ErhvnDsyrZNrUuO(bu)SsOwgOUmu34BsChJeUfx2NK0GAzHA5G6skeQXaQTqXRjA8njUWmEXdlNvWB8v8fQbiOgaqTmqDzOgyqTfkEnHVhQrjyBszbVXxXxeyqSCwe48vPXDymYqY)eaiSqG8gFfFrfGajDACNbcSX3K4ogjClUSpjPb1Yc1Yb1LuiuJbuBHIxt04BsCHz8IhwoRG34R4ludqqnaGAzqGbXYzrGZxLg3HXidj)ZsJWcbgelNfbwRcsgkxCbESegbYB8v8fvaYqY)SqewiqEJVIVOcqGKonUZabkhuF5pU3l6OQPtclOwqaeQFa1fc1flc1x(J79IoQA6KWIMpJCPq9dO(zLqTmqDzOgyqTfkEnHVhQrjyBszbVXxXxeyqSCweOVhQ5OwNaYidj)taocleyqSCweOVhQ5OwNaYiqEJVIVOcqgs(NamiSqGbXYzrGsNEDJ3jjxJBeiVXxXxubidj)ZQhHfcmiwolcmAsSSZMU51qG8gFfFrfGmKHa)d1zjbWCRryHK)jcleiVXxXxubiqsNg3zGaLdQV8h37fDu10jHfuliac1pG6cH6IfH6l)X9ErhvnDsyrZNrUuO(bu)SsOwgOUmu34BsChJeUH6hVqnaQeQld1adQTqXRj89qnkbBtkl4n(k(IadILZIaNVknUdJrgs(sqyHa5n(k(Ikabs604odeyJVjXDms4gQF8c1aOseyqSCwe48vPXDymYqYdaewiqEJVIVOcqGKonUZabAHIxtuhMuUZT2rTPpf8gFfFrGbXYzrGnFonLvmL6KKRXnYqYxAewiqEJVIVOcqGKonUZab(X9ErNNSa)abgelNfbkDKOYT29vb1qgs(cryHa5n(k(Ikabs604odeOCq9L)4EVOJQMojSGAbbqO(buxiuxSiuF5pU3l6OQPtclA(mYLc1pG6Nvc1Ya1LH6gFzHLNSZgxHq9dOUMCH6IfH6gFtI7yKWnu)4fQlDHqDzOgyqTfkEnHVhQrjyBszbVXxXxeyqSCwe48vPXDymYqYdWryHa5n(k(Ikabs604odeyJVSWYt2zJRqO(buxtUqDXIqDJVjXDms4gQF8c1LUqeyqSCwe48vPXDymYqYdWGWcbYB8v8fvacK0PXDgiWpU3lamvQCRDNbrAUSa)aQld10dwPCw01Srf(EOgLGTjLHAzFH6sqGbXYzrG(EOgLGTjLrgs(QhHfcK34R4lQaeiPtJ7mqGn(Me3XiHBXL9jjnOw2xOgavc1LH6gFzHLNSZghaGAzH6AYfbgelNfbkD61nENKCnUrgs(sncleyqSCweyZNttzftPoj5ACJa5n(k(Ikazi5FwjcleiVXxXxubiqsNg3zGaPhSs5SORzJk89qnkbBtkd1Y(c1LGadILZIa99qnkbBtkJmK8pFIWcbYB8v8fvacK0PXDgiq5G6l)X9ErhvnDsyb1ccGq9dOUqOUyrO(YFCVx0rvtNew08zKlfQFa1pReQLbQld1n(Me3XiHBXL9jjnOwwOUKcH6IfH6gFzOwwOgaqDzOgyqTfkEnHVhQrjyBszbVXxXxeyqSCwe48vPXDymYqY)SeewiqEJVIVOcqGKonUZab24BsChJeUfx2NK0GAzH6skeQlweQB8LHAzHAaGadILZIaNVknUdJrgs(NaaHfcK34R4lQaeiPtJ7mqGn(Me3XiHBXL9jjnOwwOUKkrGbXYzrGrtILD20nVgYqgc8Y(axziSqY)eHfcmiwolc8m3RZ3mxfJa5n(k(Ikazi5lbHfcK34R4lQaeiPtJ7mqGadQVJj89qnNNbo3cljaMBnuxgQLdQbguBHIxt8BomPUX7O5E7OEOHG34R4luxSiutMrDhjR43CysDJ3rZ92r9qdrZNrUuOwwO(zHqTmiWGy5SiqPJevU1UVkOgYqYdaewiqEJVIVOcqGKonUZab(X9ErsW2zHAwQO5Zixku)4fQRjxOUmu)X9ErsW2zHAwQa)aQld10dwPCw01Srf1QGKHYfxGhlHHAzFH6sG6YqTCqnWGAlu8AIFZHj1nEhn3Bh1dne8gFfFH6IfHAYmQ7izf)MdtQB8oAU3oQhAiA(mYLc1Yc1pleQLbbgelNfbwRcsgkxCbESegzi5lncleiVXxXxubiqsNg3zGa)4EVijy7Sqnlv08zKlfQF8c11KluxgQ)4EVijy7SqnlvGFa1LHA5GAGb1wO41e)MdtQB8oAU3oQhAi4n(k(c1flc1Kzu3rYk(nhMu34D0CVDup0q08zKlfQLfQFwiuldcmiwolc03d1CuRtazKHKVqewiqEJVIVOcqGbXYzrGKqPCbXYzDQKAiqvsn3gNmcKmJ6oswkYqYdWryHa5n(k(Ikabs604odeOfkEnXV5WK6gVJM7TJ6HgcEJVIVqDzOwoOMmJ6oswXV5WK6gVJM7TJ6HgIMpJCPq9dOUqOUyrOwoOMmJ6oswXV5WK6gVJM7TJ6HgIMpJCPq9dOUKkH6YqTfDnBclpzNnUBYq9dOgafc1Ya1YGadILZIaB81felN1PsQHavj1CBCYiW)qDhZOYTgzi5byqyHa5n(k(Ikabs604ode4DmXV5WK6gVJM7TJ6HgcljaMBncmiwolcSXxxqSCwNkPgcuLuZTXjJa)d1zjbWCRrgs(QhHfcK34R4lQaeiPtJ7mqGFCVxCKkv0UX789qnb(buxgQTqXRjMVknUdlNvWB8v8fbgelNfb24RliwoRtLudbQsQ524KrGZxLg3HLZImK8LAewiqEJVIVOcqGKonUZabgelbo74LptMc1Y(c1LGadILZIaB81felN1PsQHavj1CBCYiWyyKHK)zLiSqG8gFfFrfGadILZIajHs5cILZ6uj1qGQKAUnozei1I9g9fzidbsMrDhjlfHfs(NiSqG8gFfFrfGajDACNbcuoOMmJ6oswXrQur7gVZ3d1enhxSH6IfHAYmQ7izfhPsfTB8oFput08zKlfQLfQlPsOwgOUmulhudmO2cfVM43CysDJ3rZ92r9qdbVXxXxOUyrOMmJ6oswbFEms4214l7KWXXSIMpJCPqTSqDPUqOwgeyqSCweioLDPXNuKHKVeewiqEJVIVOcqGBCYiWoQ6IVasD)S21819XnBweyqSCweyhvDXxaPUFw7A(6(4MnlYqYdaewiqEJVIVOcqGbXYzrGNCZaAsdQZhBncK0PXDgiqGb13Xe)MdtQB8oAU3oQhAiSKayU1qDzOgyq9h37fhPsfTB8oFputGFGa34KrGNCZaAsdQZhBnYqYxAewiqEJVIVOcqGKonUZab(X9EXrQur7gVZ3d1e4hqDzO(J79c(8yKWTRXx2jHJJzf4hiWGy5SiWJXYzrgs(cryHa5n(k(Ikabs604ode4h37fhPsfTB8oFputGFa1LH6pU3l4ZJrc3UgFzNeooMvGFGadILZIa)QzUopEJnYqYdWryHa5n(k(Ikabs604ode4h37fhPsfTB8oFputGFGadILZIa)Ct5gWCRrgsEagewiqEJVIVOcqGKonUZabsMrDhjRGppgjC7A8LDs44ywrZNrUueyqSCwe4rQur7gVZ3d1qgs(QhHfcK34R4lQaeiPtJ7mqGKzu3rYk4ZJrc3UgFzNeooMv08zKlfQld1Kzu3rYkosLkA34D(EOMO5Zixkcmiwolc83CysDJ3rZ92r9qdKHKVuJWcbYB8v8fvacK0PXDgiqYmQ7izfhPsfTB8oFput0CCXgQld1adQTqXRj(nhMu34D0CVDup0qWB8v8fQld1n(YclpzNnUcHAzH6AYfQld1n(Me3XiHBXL9jjnOw2xO(zLiWGy5Siq(8yKWTRXx2jHJJzrgs(NvIWcbYB8v8fvacK0PXDgiq5GAYmQ7izfhPsfTB8oFput0CCXgQlweQTORzty5j7SXDtgQFa1LujulduxgQTqXRj(nhMu34D0CVDup0qWB8v8fQld1n(YqTSVqnaG6YqDJVjXDms4gQLfQb4vIadILZIa5ZJrc3UgFzNeooMfzi5F(eHfcK34R4lQaeiPtJ7mqGwO41eKrDDs5OnbVXxXxOUmulhulhu)X9EbzuxNuoAtqTGaiul7lu)SsOUmuF5pU3l6OQPtclOwqaeQFH6cHAzG6IfHAl6A2ewEYoBC3KH6hVqDn5c1YGadILZIajHs5cILZ6uj1qGQKAUnozeizuxNuoAdzi5FwccleiVXxXxubiqsNg3zGaLdQ)4EV4ivQODJ357HAIMpJCPq9JxOUMCH6IfHA5G6pU3losLkA34D(EOMO5Zixku)aQREOUmu)X9Eb(kDuy7OwZBTjv08zKlfQF8c11KluxgQ)4EVaFLokSDuR5T2KkWpGAzGAzG6Yq9h37fhPsfTB8oFputGFGadILZIa99qnjy3NuNhVXgzi5FcaewiqEJVIVOcqGKonUZabArxZMWYt2zJ7Mmu)aQRjxOUyrOwoO2IUMnHLNSZg3nzO(butMrDhjR4ivQODJ357HAIMpJCPqDzO(J79c8v6OW2rTM3AtQa)aQLbbgelNfb67HAsWUpPopEJnYqgYqGaNBAols(sQ8z1)SYsEkEwQl9teOKO3CRPiWQPZJPn(c1LAOoiwoluRsQrfqGqG0dMGKVKcFIap6XNkgbwTqDPShQb1LICysH6sHnRLAqGQwOwQzhuawmXSonP4FbzoXKMN4QWYzjD4nmP5jbZVA(y(9r14YahZJE8PIPywDAUujYlfZQtPIRuKdtQRuyZAPMRu2d1e08KabQAH6sveB(Cd1LaWRaQlPYNvpuxnGAaaWw6kH6Qt1feiiqvluxDln2AMcWcbQAH6QbuxnTef(LH6QRCVqDPSzUkwabccu1c1LQRMZeCJVq9N9tZqnzo)Hb1FUoxQaQRMri8HrH6D2QH0Op94kOoiwolfQNvHTacuqSCwQ4OzYC(d71RckGqGcILZsfhntMZFyy8IPFMleOGy5SuXrZK58hggVyg41N8AHLZcbQAHAWnoOshdQ7iVq9h375lutTWOq9N9tZqnzo)Hb1FUoxkuh7fQpAUACmMLBnuNuO(ollGafelNLkoAMmN)WW4ft6ghuPJ5OwyuiqbXYzPIJMjZ5pmmEX8ySCwiqqGQwOUuD1CMGB8fQzGZn2qTLNmuBszOoi20qDsH6a4rQIVIfqGcILZsFpZ968nZvXqGQwOUA2XHcBOUu2d1G6sjdCUH6yVq9zKRf5c1vteSHASc1SuiqbXYzPy8IP0rIk3A3xfuRI0)cS7ycFpuZ5zGZTWscG5wxwoGzHIxt8BomPUX7O5E7OEOHG34R4BXIKzu3rYk(nhMu34D0CVDup0q08zKlv2NfkdeOGy5SumEXSwfKmuU4c8yjCfP)9J79IKGTZc1SurZNrU0hV1KB5pU3lsc2oluZsf4hLPhSs5SORzJkQvbjdLlUapwcl7BjLLdywO41e)MdtQB8oAU3oQhAi4n(k(wSizg1DKSIFZHj1nEhn3Bh1dnenFg5sL9zHYabkiwolfJxm99qnh16eqUI0)(X9ErsW2zHAwQO5Zix6J3AYT8h37fjbBNfQzPc8JYYbmlu8AIFZHj1nEhn3Bh1dne8gFfFlwKmJ6oswXV5WK6gVJM7TJ6HgIMpJCPY(SqzGafelNLIXlMKqPCbXYzDQKAvSXj)sMrDhjlfcuqSCwkgVy24RliwoRtLuRIno53)qDhZOYTUI0)AHIxt8BomPUX7O5E7OEOHG34R4Bz5iZOUJKv8BomPUX7O5E7OEOHO5Zix6JclwuoYmQ7izf)MdtQB8oAU3oQhAiA(mYL(OKklBrxZMWYt2zJ7M8dauOmYabkiwolfJxmB81felN1PsQvXgN87FOoljaMBDfP)9oM43CysDJ3rZ92r9qdHLeaZTgcuqSCwkgVy24RliwoRtLuRIno535RsJ7WYzRi9VFCVxCKkv0UX789qnb(rzlu8AI5RsJ7WYzf8gFfFHafelNLIXlMn(6cILZ6uj1QyJt(ngUI0)gelbo74LptMk7BjqGcILZsX4ftsOuUGy5SovsTk24KFPwS3OVqGGafelNLkIHFB(CAkRyk1jjxJ7ks)RfkEnrDys5o3Ah1M(uWB8v8Tyr5IQ4onw47PkEDgFEWut0Xcyz6bRuol6A2OIMpNMYkMsDsY14w2xaugyFCVx05jlWpKbcuqSCwQiggJxmRvbjdLlUapwcxr6FTqXRj89qnkbBtkl4n(k(cbkiwolvedJXlM(EOMJADcixHfDnBU0)k3L)4EVOJQMojSGAbbWhfwS4L)4EVOJQMojSO5Zix6JNvktzYmQ7izfnFonLvmL6KKRXTO5Zix6J3saOAYTSfkEnrDys5o3Ah1M(uWB8v8TmWSqXRj89qnkbBtkl4n(k(cbkiwolvedJXlM(EOMJADcixr6FjZOUJKv0850uwXuQtsUg3IMpJCPpElbGQj3YwO41e1HjL7CRDuB6tbVXxXxiqbXYzPIyymEXu6irLBT7RcQvr6F)4EVOZtwGFabkiwolvedJXlM(EOgLGTjLRi9VFCVxayQu5w7odI0Czb(beOGy5SurmmgVywRcsgkxCbESeUI0)24BsChJeUfx2NK0Ei3ZcXWcfVMOX3K4cZ4fpSCwbVXxXxacaYabkiwolvedJXlM(EOMJADcixHfDnBU0)k3L)4EVOJQMojSGAbbWhfwS4L)4EVOJQMojSO5Zix6JNvkt5gFtI7yKWT4Y(KK2d5EwigwO41en(MexygV4HLZk4n(k(cqaqMYaZcfVMW3d1OeSnPSG34R4leOGy5SurmmgVy67HAoQ1jGCfP)TX3K4ogjClUSpjP9qUNfIHfkEnrJVjXfMXlEy5ScEJVIVaeaKbcuqSCwQiggJxmB(CAkRyk1jjxJBiqbXYzPIyymEX03d1OeSnPmeOGy5SurmmgVyoFvAChgxHfDnBU0)k3L)4EVOJQMojSGAbbWhfwS4L)4EVOJQMojSO5Zix6JNvkt5gFtI7yKWT4Y(KKMSYvsHyyHIxt04BsCHz8IhwoRG34R4labazkdmlu8AcFpuJsW2KYcEJVIVqGcILZsfXWy8I58vPXDyCfP)TX3K4ogjClUSpjPjRCLuigwO41en(MexygV4HLZk4n(k(cqaqgiqbXYzPIyymEXSwfKmuU4c8yjmeOGy5SurmmgVy67HAoQ1jGCfw01S5s)RCx(J79IoQA6KWcQfeaFuyXIx(J79IoQA6KWIMpJCPpEwPmLbMfkEnHVhQrjyBszbVXxXxiqbXYzPIyymEX03d1CuRtaziqbXYzPIyymEXu60RB8oj5ACdbkiwolvedJXlMrtILD20nVgeiiqvluxqZHjfQhpudM7TJ6Hgq9XmQCRH6ESWYzHAawOMArBuOUKkPq9N9tZqD1jvQOH6Xd1LYEOguJbuxWac1rZqDa8ivXxXqGcILZsf)H6oMrLB9R0rIk3A3xfuRI0)(X9ErNNSa)acuqSCwQ4pu3XmQCRX4fZ5RsJ7W4kSORzZL(x5U8h37fDu10jHfulia(OWIfV8h37fDu10jHfnFg5sF8Sszk34llS8KD24k9JAYTCJVjXDms4wCzFsst23skSmWSqXRj89qnkbBtkl4n(k(cbkiwolv8hQ7ygvU1y8I58vPXDyCfP)TXxwy5j7SXv6h1KB5gFtI7yKWT4Y(KKMSVLuieOGy5SuXFOUJzu5wJXlM1QGKHYfxGhlHRi9Vn(Me3XiHBXL9jjThLuzzYmQ7izfhPsfTB8oFput08zKlv2gFzHLNSZgxPltpyLYzrxZgvuRcsgkxCbESew23sGafelNLk(d1DmJk3AmEX03d1CuRta5kSORzZL(x5U8h37fDu10jHfulia(OWIfV8h37fDu10jHfnFg5sF8Sszk34BsChJeUfx2NK0EusLLjZOUJKvCKkv0UX789qnrZNrUuzB8LfwEYoBCLUmWSqXRj89qnkbBtkl4n(k(cbkiwolv8hQ7ygvU1y8IPVhQ5OwNaYvK(3gFtI7yKWT4Y(KK2JsQSmzg1DKSIJuPI2nENVhQjA(mYLkBJVSWYt2zJR0qGcILZsf)H6oMrLBngVy67HAuc2MuUI0)(X9EbGPsLBT7misZLf4hLB8njUJrc3Il7tsAYk3ZcXWcfVMOX3K4cZ4fpSCwbVXxXxacaYuMEWkLZIUMnQW3d1OeSnPSSVLabkiwolv8hQ7ygvU1y8IPVhQrjyBs5ks)BJVjXDms4wCzFsst2x5aqHyyHIxt04BsCHz8IhwoRG34R4labazktpyLYzrxZgv47HAuc2Muw23sGafelNLk(d1DmJk3AmEXC(Q04omUcl6A2CP)vUl)X9ErhvnDsyb1ccGpkSyXl)X9ErhvnDsyrZNrU0hpRuMYn(Me3XiHBXL9jjnzFLdafIHfkEnrJVjXfMXlEy5ScEJVIVaeaKPmWSqXRj89qnkbBtkl4n(k(cbkiwolv8hQ7ygvU1y8I58vPXDyCfP)TX3K4ogjClUSpjPj7RCaOqmSqXRjA8njUWmEXdlNvWB8v8fGaGmqGcILZsf)H6oMrLBngVywRcsgkxCbESeUI0)sMrDhjR4ivQODJ357HAIMpJCPY24llS8KD24kD5gFtI7yKWT4Y(KK2Jsxzz6bRuol6A2OIAvqYq5IlWJLWY(wceOGy5SuXFOUJzu5wJXlM(EOMJADcixHfDnBU0)k3L)4EVOJQMojSGAbbWhfwS4L)4EVOJQMojSO5Zix6JNvktzYmQ7izfhPsfTB8oFput08zKlv2gFzHLNSZgxPl34BsChJeUfx2NK0Eu6kldmlu8AcFpuJsW2KYcEJVIVqGcILZsf)H6oMrLBngVy67HAoQ1jGCfP)LmJ6oswXrQur7gVZ3d1enFg5sLTXxwy5j7SXv6Yn(Me3XiHBXL9jjThLUsiqqGcILZsf)H6SKayU1VZxLg3HXvyrxZMl9VYD5pU3l6OQPtclOwqa8rHflE5pU3l6OQPtclA(mYL(4zLYuUX3K4ogjC)4favwgywO41e(EOgLGTjLf8gFfFHafelNLk(d1zjbWCRX4fZ5RsJ7W4ks)BJVjXDms4(XlaQecuqSCwQ4puNLeaZTgJxmB(CAkRyk1jjxJ7ks)RfkEnrDys5o3Ah1M(uWB8v8fcuqSCwQ4puNLeaZTgJxmLosu5w7(QGAvK(3pU3l68Kf4hqGcILZsf)H6SKayU1y8I58vPXDyCfw01S5s)RCx(J79IoQA6KWcQfeaFuyXIx(J79IoQA6KWIMpJCPpEwPmLB8LfwEYoBCf(OMClwSX3K4ogjC)4T0fwgywO41e(EOgLGTjLf8gFfFHafelNLk(d1zjbWCRX4fZ5RsJ7W4ks)BJVSWYt2zJRWh1KBXIn(Me3XiH7hVLUqiqbXYzPI)qDwsam3AmEX03d1OeSnPCfP)9J79catLk3A3zqKMllWpktpyLYzrxZgv47HAuc2Muw23sGafelNLk(d1zjbWCRX4ftPtVUX7KKRXDfP)TX3K4ogjClUSpjPj7laQSCJVSWYt2zJdaYwtUqGcILZsf)H6SKayU1y8IzZNttzftPoj5ACdbkiwolv8hQZscG5wJXlM(EOgLGTjLRi9V0dwPCw01Srf(EOgLGTjLL9TeiqbXYzPI)qDwsam3AmEXC(Q04omUcl6A2CP)vUl)X9ErhvnDsyb1ccGpkSyXl)X9ErhvnDsyrZNrU0hpRuMYn(Me3XiHBXL9jjnzlPWIfB8LLfaLbMfkEnHVhQrjyBszbVXxXxiqbXYzPI)qDwsam3AmEXC(Q04omUI0)24BsChJeUfx2NK0KTKclwSXxwwaabkiwolv8hQZscG5wJXlMrtILD20nVwfP)TX3K4ogjClUSpjPjBjvcbccu1c1v3J6c1s5OnOMm7nTCwkeOGy5SubzuxNuoA7LinYL6gVljCfP)9J79cYOUoPC0MGAbbqzlSSfDnBclpzNnUBYpQjxiqbXYzPcYOUoPC0ggVysKg5sDJ3LeUI0)k3h37fhPsfTB8oFput08zKl9XBn5cqY9edYmQ7izf(EOMeS7tQZJ3ylAoUyltXIFCVxCKkv0UX789qnrZNrU0hn(YclpzNnoait5pU3losLkA34D(EOMa)acuqSCwQGmQRtkhTHXlMePrUu34DjHRi9VFCVxCKkv0UX789qnrZNrU0hvF5pU3lWxPJcBh1AERnPIMpJCPpQjxasUNyqMrDhjRW3d1KGDFsDE8gBrZXfBzk)X9Eb(kDuy7OwZBTjv08zKlT8h37fhPsfTB8oFputGFabccuqSCwQGmJ6osw6loLDPXN0ks)RCKzu3rYkosLkA34D(EOMO54IDXIKzu3rYkosLkA34D(EOMO5ZixQSLuPmLLdywO41e)MdtQB8oAU3oQhAi4n(k(wSizg1DKSc(8yKWTRXx2jHJJzfnFg5sLTuxOmqGcILZsfKzu3rYsX4ftCk7sJpRyJt(TJQU4lGu3pRDnFDFCZMfcuqSCwQGmJ6oswkgVyItzxA8zfBCYVNCZaAsdQZhBDfP)fy3Xe)MdtQB8oAU3oQhAiSKayU1Lb2h37fhPsfTB8oFputGFabkiwolvqMrDhjlfJxmpglNTI0)(X9EXrQur7gVZ3d1e4hL)4EVGppgjC7A8LDs44ywb(beOGy5Subzg1DKSumEX8RM5684n2vK(3pU3losLkA34D(EOMa)O8h37f85XiHBxJVStchhZkWpGafelNLkiZOUJKLIXlMFUPCdyU1vK(3pU3losLkA34D(EOMa)acu1c1LYEOgutMrDhjlfcuqSCwQGmJ6oswkgVyEKkv0UX789qTks)lzg1DKSc(8yKWTRXx2jHJJzfnFg5sHafelNLkiZOUJKLIXlM)MdtQB8oAU3oQhAur6FjZOUJKvWNhJeUDn(YojCCmRO5ZixAzYmQ7izfhPsfTB8oFput08zKlfcuqSCwQGmJ6oswkgVyYNhJeUDn(YojCCmBfP)LmJ6oswXrQur7gVZ3d1enhxSldmlu8AIFZHj1nEhn3Bh1dne8gFfFl34llS8KD24ku2AYTCJVjXDms4wCzFsst23NvcbkiwolvqMrDhjlfJxm5ZJrc3UgFzNeooMTI0)khzg1DKSIJuPI2nENVhQjAoUyxSOfDnBclpzNnUBYpkPszkBHIxt8BomPUX7O5E7OEOHG34R4B5gFzzFbq5gFtI7yKWTSa8kHafelNLkiZOUJKLIXlMKqPCbXYzDQKAvSXj)sg11jLJ2Qi9VwO41eKrDDs5OnbVXxX3YYj3h37fKrDDs5Onb1ccGY((SYYx(J79IoQA6KWcQfeaFluMIfTORzty5j7SXDt(XBn5kdeOGy5Subzg1DKSumEX03d1KGDFsDE8g7ks)RCFCVxCKkv0UX789qnrZNrU0hV1KBXIY9X9EXrQur7gVZ3d1enFg5sFu9L)4EVaFLokSDuR5T2KkA(mYL(4TMCl)X9Eb(kDuy7OwZBTjvGFiJmL)4EV4ivQODJ357HAc8diqbXYzPcYmQ7izPy8IPVhQjb7(K684n2vK(xl6A2ewEYoBC3KFutUflkNfDnBclpzNnUBYpiZOUJKvCKkv0UX789qnrZNrU0YFCVxGVshf2oQ18wBsf4hYabccu1c1LQ(Q04oSCwOUhlSCwiqbXYzPI5RsJ7WYzFB(CAkRyk1jjxJ7ks)RfkEnrDys5o3Ah1M(uWB8v8fcuqSCwQy(Q04oSCwmEXC(Q04omUcl6A2CP)vUl)X9ErhvnDsyb1ccGpkSyXl)X9ErhvnDsyrZNrU0hpRuMYaZcfVMW3d1OeSnPSG34R4BzG9X9ErNNSa)Om9GvkNfDnBuH0rIk3A3xfut2xaabkiwolvmFvAChwolgVyoFvAChgxr6FbMfkEnHVhQrjyBszbVXxX3Ya7J79Iopzb(rz6bRuol6A2OcPJevU1UVkOMSVaacuqSCwQy(Q04oSCwmEX03d1OeSnPCfP)vUpU3lamvQCRDNbrAUSO5Gyflk3h37faMkvU1UZGinxwGFuwUJMbURMCfpf(EOMJADcixS4rZa3vtUINcPJevU1UVkOwXIhndCxn5kEkQvbjdLlUapwclJmYuMEWkLZIUMnQW3d1OeSnPSSVLabkiwolvmFvAChwolgVyoFvAChgxHfDnBU0)k3L)4EVOJQMojSGAbbWhfwS4L)4EVOJQMojSO5Zix6JNvkt5pU3lamvQCRDNbrAUSO5Gyflk3h37faMkvU1UZGinxwGFuwUJMbURMCfpf(EOMJADcixS4rZa3vtUINcPJevU1UVkOwXIhndCxn5kEkQvbjdLlUapwclJmqGcILZsfZxLg3HLZIXlMZxLg3HXvK(3pU3lamvQCRDNbrAUSO5Gyflk3h37faMkvU1UZGinxwGFuwUJMbURMCfpf(EOMJADcixS4rZa3vtUINcPJevU1UVkOwXIhndCxn5kEkQvbjdLlUapwclJmqGcILZsfZxLg3HLZIXlM1QGKHYfxGhlHRi9VYbSpU3l68Kf4hfl24BsChJeUfx2NK0E8SYIfB8LfwEYoBCLiBn5ktz6bRuol6A2OIAvqYq5IlWJLWY(wceOGy5SuX8vPXDy5Sy8IP0rIk3A3xfuRI0)(X9ErNNSa)Om9GvkNfDnBuH0rIk3A3xfut23sGafelNLkMVknUdlNfJxm99qnh16eqUcl6A2CP)vUl)X9ErhvnDsyb1ccGpkSyXl)X9ErhvnDsyrZNrU0hpRuMYa7J79Iopzb(rXIn(Me3XiHBXL9jjThpRSyXgFzHLNSZgxjYwtULbMfkEnHVhQrjyBszbVXxXxiqbXYzPI5RsJ7WYzX4ftFpuZrTobKRi9Va7J79Iopzb(rXIn(Me3XiHBXL9jjThpRSyXgFzHLNSZgxjYwtUqGcILZsfZxLg3HLZIXlMshjQCRDFvqTks)7h37fDEYc8diqbXYzPI5RsJ7WYzX4fZ5RsJ7W4kSORzZL(x5U8h37fDu10jHfulia(OWIfV8h37fDu10jHfnFg5sF8Sszkdmlu8AcFpuJsW2KYcEJVIVqGcILZsfZxLg3HLZIXlMZxLg3HXqGGavTqnOf7n6lutZTwXvdl6A2G6ESWYzHafelNLkOwS3OVVnFonLvmL6KKRXneOGy5Sub1I9g9fJxm99qnh16eqUI0)sMrDhjRO5ZPPSIPuNKCnUfnFg5sF8wcavtULTqXRjQdtk35w7O20NcEJVIVqGcILZsful2B0xmEXu6irLBT7RcQvr6F)4EVOZtwGFabkiwolvqTyVrFX4fZ5RsJ7W4ks)lW(4EVW3tv86oWvuwGFu2cfVMW3tv86oWvuwWB8v8fcuqSCwQGAXEJ(IXlM(EOMJADcixr6FB8njUJrc3Il7tsApK7zHyyHIxt04BsCHz8IhwoRG34R4labazGafelNLkOwS3OVy8IPVhQrjyBs5ks)7h37faMkvU1UZGinxwGFuUXxwy5j7SXvAzFRjxiqbXYzPcQf7n6lgVyoFvAChgxr6FB8njUJrc3Il7tsAYkxjfIHfkEnrJVjXfMXlEy5ScEJVIVaeaKbcuqSCwQGAXEJ(IXlM(EOMJADcidbkiwolvqTyVrFX4ftPtVUX7KKRXneOGy5Sub1I9g9fJxmJMel7SPBEnKHmec]] )

    
end
