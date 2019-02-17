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


    spec:RegisterPack( "Frost DK", 20190217.0053, [[du0KFbqivr9ijvPnjrnkIItruAvakEfuXSKiDljvHDr4xqLgMeXXuLSmjLEMQittsrxtcABsQI(MKczCskW5KuvwNKQQMNQW9ayFevDqjfkTqjWdLuvPjcOuDrjfkSraLCsjfQwjG8sjfKBkPQc7KOYpLuOOHcOuwQKcQNc0uHQSxi)LkdMuhwyXQQhJ0KvPlJAZu1NLKrteNw0RvLA2KCBv0Uv63kgUkSCPEoIPt56qz7aQ(orA8sQQOZdv16Luz(sO9dA0leEiWBymsUAl5v9vsTVQrIskPWNQz9Han8pye4rqFhvmcCJtgbcS6HyqnWEnec8iWxnXfHhcKmynLrGsm7Gu)Xf3Q0KG9f05exsEIPclNL2H3WLKNuC)Q5J73h1JldCCp6XNkMGlWwZ1WrEj4cSvd7a25WK4QH2SsI5aw9qmbjpPiWpwQSA8f9rG3WyKC1wYR6RKAFvJeLuYR67PAacmWmjtJabZZ6xeOK8E5f9rGxMqrG1ludS6HyqnWohMeOUgAZkjgeO6fQLy2bP(JlUvPjb7lOZjUK8etfwolTdVHljpP4(vZh3VpQhxg44E0JpvmbxGTMRHJ8sWfyRg2bSZHjXvdTzLeZbS6HycsEsHavVqnWI)nw04d1VQrLc11wYR6dQRhqDjLu)FvFqGGavVqD9RKyRys9hcu9c11dOUgFPkSld11pY9c1aRM56ybcuLeJGWdbsh11jHJ2q4HK7fcpeiVXxXxubiqANg3zGa)yEVGoQRtchTjiwqFd1Yd1fc1LHAl6k2ewEYoBC3KH6hqDf9IadQLZIaPsICjUX7skJmKC1IWdbYB8v8fvacK2PXDgiqzG6pM3losLkA34D(EiMO5Zixcu)aauxrVqnWa1Ya1VGACGA6mQ7iDf(EiMu87tIZJ14lAoU4d1Yc1flc1FmVxCKkv0UX789qmrZNrUeO(bu3yllS8KD24EcQLfQld1FmVxCKkv0UX789qmb2bcmOwolcKkjYL4gVlPmYqY9ecpeiVXxXxubiqANg3zGa)yEV4ivQODJ357HyIMpJCjq9dOUga1LH6pM3lWwjJcFhXAERmjIMpJCjq9dOUIEHAGbQLbQFb14a10zu3r6k89qmP43NeNhRXx0CCXhQLfQld1FmVxGTsgf(oI18wzsenFg5sG6Yq9hZ7fhPsfTB8oFpetGDGadQLZIaPsICjUX7skJmKHaNVknUdlNfHhsUxi8qG8gFfFrfGaPDACNbc0cfVMOkmjCNBLJytFk4n(k(IadQLZIaB(CAcRycXjnxJBKHKRweEiqEJVIVOcqG0onUZabkduF5pM3l6OUPtkliwqFd1pG6cH6IfH6l)X8Erh1nDszrZNrUeO(bu)QeOwwOUmu)muBHIxt47Hyek(MewWB8v8fQld1pd1FmVx05jlWoG6Yqn5GvkNfDfBeHKrQk3k3xfedQLhau)ecmOwolcC(Q04omgzi5EcHhcK34R4lQaeiTtJ7mqGpd1wO41e(EigHIVjHf8gFfFH6Yq9Zq9hZ7fDEYcSdOUmutoyLYzrxXgrizKQYTY9vbXGA5ba1pHadQLZIaNVknUdJrgsUAIWdbYB8v8fvacK2PXDgiqzG6pM3lENkvUvUZGkjxw0CqnOUyrOwgO(J59I3PsLBL7mOsYLfyhqDzOwgO(OzG7QOxXlHVhI5iwNVzOUyrO(OzG7QOxXlHKrQk3k3xfedQlweQpAg4Uk6v8suPcAgkxCbESugQLfQLfQLfQld1KdwPCw0vSre(EigHIVjHHA5ba11IadQLZIa99qmcfFtcJmKCfIWdbYB8v8fvacK2PXDgiqzG6l)X8Erh1nDszbXc6BO(buxiuxSiuF5pM3l6OUPtklA(mYLa1pG6xLa1Yc1LH6pM3lENkvUvUZGkjxw0CqnOUyrOwgO(J59I3PsLBL7mOsYLfyhqDzOwgO(OzG7QOxXlHVhI5iwNVzOUyrO(OzG7QOxXlHKrQk3k3xfedQlweQpAg4Uk6v8suPcAgkxCbESugQLfQLfbgulNfboFvAChgJmKC1teEiqEJVIVOcqG0onUZab(X8EX7uPYTYDguj5YIMdQb1flc1Ya1FmVx8ovQCRCNbvsUSa7aQld1Ya1hndCxf9kEj89qmhX68nd1flc1hndCxf9kEjKmsv5w5(QGyqDXIq9rZa3vrVIxIkvqZq5IlWJLYqTSqTSiWGA5SiW5RsJ7WyKHKRgHWdbYB8v8fvacK2PXDgiqzG6NH6pM3l68KfyhqDXIqDJTj1Dms5wCzFstdQFa1VkbQlweQBSLfwEYoBC1c1Yd1v0lulluxgQjhSs5SORyJiQubndLlUapwkd1YdaQRfbgulNfbwPcAgkxCbESugzi5Qbi8qG8gFfFrfGaPDACNbc8J59Iopzb2buxgQjhSs5SORyJiKmsv5w5(QGyqT8aG6ArGb1YzrGsgPQCRCFvqmKHKR(q4Ha5n(k(Ikabs704odeOmq9L)yEVOJ6MoPSGyb9nu)aQleQlweQV8hZ7fDu30jLfnFg5sG6hq9RsGAzH6Yq9Zq9hZ7fDEYcSdOUyrOUX2K6ogPClUSpPPb1pG6xLa1flc1n2YclpzNnUAHA5H6k6fQld1pd1wO41e(EigHIVjHf8gFfFrGb1YzrG(EiMJyD(MrgsUxLGWdbYB8v8fvacK2PXDgiWNH6pM3l68KfyhqDXIqDJTj1Dms5wCzFstdQFa1VkbQlweQBSLfwEYoBC1c1Yd1v0lcmOwolc03dXCeRZ3mYqY96fcpeiVXxXxubiqANg3zGa)yEVOZtwGDGadQLZIaLmsv5w5(QGyidj3RAr4Ha5n(k(Ikabs704odeOmq9L)yEVOJ6MoPSGyb9nu)aQleQlweQV8hZ7fDu30jLfnFg5sG6hq9RsGAzH6Yq9ZqTfkEnHVhIrO4BsybVXxXxeyqTCwe48vPXDymYqY96jeEiWGA5SiW5RsJ7WyeiVXxXxubidziW)qCwsFNBfcpKCVq4Ha5n(k(Ikabs704odeOmq9L)yEVOJ6MoPSGyb9nu)aQleQlweQV8hZ7fDu30jLfnFg5sG6hq9RsGAzH6YqDJTj1Dms5gQFaaQFQeOUmu)muBHIxt47Hyek(MewWB8v8fbgulNfboFvAChgJmKC1IWdbYB8v8fvacK2PXDgiWgBtQ7yKYnu)aau)ujiWGA5SiW5RsJ7WyKHK7jeEiqEJVIVOcqG0onUZabAHIxtufMeUZTYrSPpf8gFfFrGb1YzrGnFonHvmH4KMRXnYqYvteEiqEJVIVOcqG0onUZab(X8ErNNSa7abgulNfbkzKQYTY9vbXqgsUcr4Ha5n(k(Ikabs704odeOmq9L)yEVOJ6MoPSGyb9nu)aQleQlweQV8hZ7fDu30jLfnFg5sG6hq9RsGAzH6YqDJTSWYt2zJRqO(buxrVqDXIqDJTj1Dms5gQFaaQRzHqDzO(zO2cfVMW3dXiu8njSG34R4lcmOwolcC(Q04omgzi5QNi8qG8gFfFrfGaPDACNbcSXwwy5j7SXviu)aQROxOUyrOUX2K6ogPCd1paa11SqeyqTCwe48vPXDymYqYvJq4Ha5n(k(Ikabs704ode4hZ7fVtLk3k3zqLKllWoG6Yqn5GvkNfDfBeHVhIrO4BsyOwEaqDTiWGA5SiqFpeJqX3KWidjxnaHhcK34R4lQaeiTtJ7mqGn2Mu3XiLBXL9jnnOwEaq9tLa1LH6gBzHLNSZg3tqT8qDf9IadQLZIaLm96gVtAUg3idjx9HWdbgulNfb2850ewXeItAUg3iqEJVIVOcqgsUxLGWdbYB8v8fvacK2PXDgiqYbRuol6k2icFpeJqX3KWqT8aG6ArGb1YzrG(EigHIVjHrgsUxVq4Ha5n(k(Ikabs704odeOmq9L)yEVOJ6MoPSGyb9nu)aQleQlweQV8hZ7fDu30jLfnFg5sG6hq9RsGAzH6YqDJTj1Dms5wCzFstdQLhQRTqOUyrOUXwgQLhQFcQld1pd1wO41e(EigHIVjHf8gFfFrGb1YzrGZxLg3HXidj3RAr4Ha5n(k(Ikabs704odeyJTj1Dms5wCzFstdQLhQRTqOUyrOUXwgQLhQFcbgulNfboFvAChgJmKCVEcHhcK34R4lQaeiTtJ7mqGn2Mu3XiLBXL9jnnOwEOU2sqGb1YzrGrtJLD20nVgYqgc8pe3XmQCRq4HK7fcpeiVXxXxubiqANg3zGa)yEVOZtwGDGadQLZIaLmsv5w5(QGyidjxTi8qG8gFfFrfGaPDACNbcugO(YFmVx0rDtNuwqSG(gQFa1fc1flc1x(J59IoQB6KYIMpJCjq9dO(vjqTSqDzOUXwwy5j7SXvtO(buxrVqDzOUX2K6ogPClUSpPPb1YdaQRTqOUmu)muBHIxt47Hyek(MewWB8v8fbgulNfboFvAChgJmKCpHWdbYB8v8fvacK2PXDgiWgBzHLNSZgxnH6hqDf9c1LH6gBtQ7yKYT4Y(KMgulpaOU2crGb1YzrGZxLg3HXidjxnr4Ha5n(k(Ikabs704odeyJTj1Dms5wCzFstdQFa11wcuxgQPZOUJ0vCKkv0UX789qmrZNrUeOwEOUXwwy5j7SXvtOUmutoyLYzrxXgruPcAgkxCbESugQLhauxlcmOwolcSsf0muU4c8yPmYqYvicpeiVXxXxubiqANg3zGaLbQV8hZ7fDu30jLfelOVH6hqDHqDXIq9L)yEVOJ6MoPSO5Zixcu)aQFvculluxgQBSnPUJrk3Il7tAAq9dOU2sG6YqnDg1DKUIJuPI2nENVhIjA(mYLa1Yd1n2YclpzNnUAc1LH6NHAlu8AcFpeJqX3KWcEJVIViWGA5SiqFpeZrSoFZidjx9eHhcK34R4lQaeiTtJ7mqGn2Mu3XiLBXL9jnnO(buxBjqDzOMoJ6osxXrQur7gVZ3dXenFg5sGA5H6gBzHLNSZgxnrGb1YzrG(EiMJyD(MrgsUAecpeiVXxXxubiqANg3zGa)yEV4DQu5w5odQKCzb2buxgQBSnPUJrk3Il7tAAqT8qTmq9RcHACGAlu8AIgBtQlmJxSWYzf8gFfFHAGbQFcQLfQld1KdwPCw0vSre(EigHIVjHHA5ba11IadQLZIa99qmcfFtcJmKC1aeEiqEJVIVOcqG0onUZab2yBsDhJuUfx2N00GA5ba1Ya1pviuJduBHIxt0yBsDHz8IfwoRG34R4ludmq9tqTSqDzOMCWkLZIUInIW3dXiu8njmulpaOUweyqTCweOVhIrO4BsyKHKR(q4Ha5n(k(Ikabs704odeOmq9L)yEVOJ6MoPSGyb9nu)aQleQlweQV8hZ7fDu30jLfnFg5sG6hq9RsGAzH6YqDJTj1Dms5wCzFstdQLhauldu)uHqnoqTfkEnrJTj1fMXlwy5ScEJVIVqnWa1pb1Yc1LH6NHAlu8AcFpeJqX3KWcEJVIViWGA5SiW5RsJ7WyKHK7vji8qG8gFfFrfGaPDACNbcSX2K6ogPClUSpPPb1YdaQLbQFQqOghO2cfVMOX2K6cZ4flSCwbVXxXxOgyG6NGAzrGb1YzrGZxLg3HXidj3Rxi8qG8gFfFrfGaPDACNbcKoJ6osxXrQur7gVZ3dXenFg5sGA5H6gBzHLNSZgxnH6YqDJTj1Dms5wCzFstdQFa11SeOUmutoyLYzrxXgruPcAgkxCbESugQLhauxlcmOwolcSsf0muU4c8yPmYqY9QweEiqEJVIVOcqG0onUZabkduF5pM3l6OUPtkliwqFd1pG6cH6IfH6l)X8Erh1nDszrZNrUeO(bu)QeOwwOUmutNrDhPR4ivQODJ357HyIMpJCjqT8qDJTSWYt2zJRMqDzOUX2K6ogPClUSpPPb1pG6AwcuxgQFgQTqXRj89qmcfFtcl4n(k(IadQLZIa99qmhX68nJmKCVEcHhcK34R4lQaeiTtJ7mqG0zu3r6kosLkA34D(EiMO5Zixculpu3yllS8KD24QjuxgQBSnPUJrk3Il7tAAq9dOUMLGadQLZIa99qmhX68nJmKHapAMoN)Wq4HK7fcpeiVXxXxubidjxTi8qG8gFfFrfGmKCpHWdbYB8v8fvaYqYvteEiqEJVIVOcqgsUcr4HadQLZIapglNfbYB8v8fvaYqgcmggHhsUxi8qG8gFfFrfGaPDACNbc0cfVMOkmjCNBLJytFk4n(k(c1flc1Ya1rDCNgl89uhVoJppyIj6yFd1LHAYbRuol6k2iIMpNMWkMqCsZ14gQLhau)euxgQFgQ)yEVOZtwGDa1YIadQLZIaB(CAcRycXjnxJBKHKRweEiqEJVIVOcqG0onUZabAHIxt47Hyek(MewWB8v8fbgulNfbwPcAgkxCbESugzi5EcHhcK34R4lQaeiTtJ7mqGYa1x(J59IoQB6KYcIf03q9dOUqOUyrO(YFmVx0rDtNuw08zKlbQFa1VkbQLfQld10zu3r6kA(CAcRycXjnxJBrZNrUeO(baOUwOgyG6k6fQld1wO41evHjH7CRCeB6tbVXxXxOUmu)muBHIxt47Hyek(MewWB8v8fbgulNfb67HyoI15Bgzi5QjcpeiVXxXxubiqANg3zGaPZOUJ0v0850ewXeItAUg3IMpJCjq9daqDTqnWa1v0luxgQTqXRjQctc35w5i20NcEJVIViWGA5SiqFpeZrSoFZidjxHi8qG8gFfFrfGaPDACNbc8J59Iopzb2bcmOwolcuYivLBL7RcIHmKC1teEiqEJVIVOcqG0onUZab(X8EX7uPYTYDguj5YcSdeyqTCweOVhIrO4BsyKHKRgHWdbYB8v8fvacK2PXDgiWgBtQ7yKYT4Y(KMgu)aQLbQFviuJduBHIxt0yBsDHz8IfwoRG34R4ludmq9tqTSiWGA5SiWkvqZq5IlWJLYidjxnaHhcK34R4lQaeiTtJ7mqGYa1x(J59IoQB6KYcIf03q9dOUqOUyrO(YFmVx0rDtNuw08zKlbQFa1VkbQLfQld1n2Mu3XiLBXL9jnnO(buldu)QqOghO2cfVMOX2K6cZ4flSCwbVXxXxOgyG6NGAzH6Yq9ZqTfkEnHVhIrO4BsybVXxXxeyqTCweOVhI5iwNVzKHKR(q4Ha5n(k(Ikabs704odeyJTj1Dms5wCzFstdQFa1Ya1VkeQXbQTqXRjASnPUWmEXclNvWB8v8fQbgO(jOwweyqTCweOVhI5iwNVzKHK7vji8qGb1YzrGnFonHvmH4KMRXncK34R4lQaKHK71leEiWGA5SiqFpeJqX3KWiqEJVIVOcqgsUx1IWdbYB8v8fvacK2PXDgiqzG6l)X8Erh1nDszbXc6BO(buxiuxSiuF5pM3l6OUPtklA(mYLa1pG6xLa1Yc1LH6gBtQ7yKYT4Y(KMgulpulduxBHqnoqTfkEnrJTj1fMXlwy5ScEJVIVqnWa1pb1Yc1LH6NHAlu8AcFpeJqX3KWcEJVIViWGA5SiW5RsJ7WyKHK71ti8qG8gFfFrfGaPDACNbcSX2K6ogPClUSpPPb1Yd1Ya11wiuJduBHIxt0yBsDHz8IfwoRG34R4ludmq9tqTSiWGA5SiW5RsJ7WyKHK7vnr4HadQLZIaRubndLlUapwkJa5n(k(Ikazi5EvicpeiVXxXxubiqANg3zGaLbQV8hZ7fDu30jLfelOVH6hqDHqDXIq9L)yEVOJ6MoPSO5Zixcu)aQFvculluxgQFgQTqXRj89qmcfFtcl4n(k(IadQLZIa99qmhX68nJmKCVQNi8qGb1YzrG(EiMJyD(MrG8gFfFrfGmKCVQri8qGb1YzrGsMEDJ3jnxJBeiVXxXxubidj3RAacpeyqTCwey00yzNnDZRHa5n(k(IkazidbsNrDhPlbHhsUxi8qG8gFfFrfGaPDACNbcugOMoJ6osxXrQur7gVZ3dXenhx8H6IfHA6mQ7iDfhPsfTB8oFpet08zKlbQLhQRTeOwwOUmuldu)muBHIxt8BomjUX7i5E7OAiHG34R4luxSiutNrDhPRGppgPC7ASLDs54ywrZNrUeOwEOU(keQLfbgulNfbIryxA8jbzi5QfHhcK34R4lQaeyqTCweyvpBfXD05zOCDuXiqANg3zGaBSLH6haG6NG6Yq9Zq9hZ7fhPsfTB8oFpetGDa1LHAzG6NH67yIFZHjXnEhj3BhvdjewsFNBfuxSiu)muBHIxt8BomjUX7i5E7OAiHG34R4lullcCJtgbw1ZwrChDEgkxhvmYqY9ecpeiVXxXxubiWnozeyh1DX23e3pRCnFDFmZMfbgulNfb2rDxS9nX9ZkxZx3hZSzrgsUAIWdbYB8v8fvacmOwolc8KB(TjjioFSviqANg3zGaFgQVJj(nhMe34DKCVDunKqyj9DUvqDzO(zO(J59IJuPI2nENVhIjWoqGBCYiWtU53MKG48XwHmKCfIWdbYB8v8fvacK2PXDgiWpM3losLkA34D(EiMa7aQld1FmVxWNhJuUDn2YoPCCmRa7abgulNfbEmwolYqYvpr4Ha5n(k(Ikabs704ode4hZ7fhPsfTB8oFpetGDa1LH6pM3l4ZJrk3UgBzNuooMvGDGadQLZIa)QzUopwJpYqYvJq4Ha5n(k(Ikabs704ode4hZ7fhPsfTB8oFpetGDGadQLZIa)Ct4(DUvidjxnaHhcK34R4lQaeiTtJ7mqG0zu3r6k4ZJrk3UgBzNuooMv08zKlbbgulNfbEKkv0UX789qmKHKR(q4Ha5n(k(Ikabs704odeiDg1DKUc(8yKYTRXw2jLJJzfnFg5sG6YqnDg1DKUIJuPI2nENVhIjA(mYLGadQLZIa)nhMe34DKCVDunKabIry349Uk6fb(czi5EvccpeiVXxXxubiqANg3zGaPZOUJ0vCKkv0UX789qmrZXfFOUmu)muBHIxt8BomjUX7i5E7OAiHG34R4luxgQBSLfwEYoBCfc1Yd1v0luxgQBSnPUJrk3Il7tAAqT8aG6xLGadQLZIa5ZJrk3UgBzNuooMfzi5E9cHhcK34R4lQaeiTtJ7mqGYa10zu3r6kosLkA34D(EiMO54IpuxSiuBrxXMWYt2zJ7Mmu)aQRTeOwwOUmuBHIxt8BomjUX7i5E7OAiHG34R4luxgQBSLHA5ba1pb1LH6gBtQ7yKYnulpuxplbbgulNfbYNhJuUDn2YoPCCmlYqY9QweEiqEJVIVOcqG0onUZabAHIxtqh11jHJ2e8gFfFH6YqTmqTmq9hZ7f0rDDs4OnbXc6BOwEaq9RsG6Yq9L)yEVOJ6MoPSGyb9nudaQleQLfQlweQTORyty5j7SXDtgQFaaQROxOwweyqTCweinukxqTCwNkjgcuLeZTXjJaPJ66KWrBidj3RNq4Ha5n(k(Ikabs704odeOmq9hZ7fhPsfTB8oFpet08zKlbQFaaQROxOUyrOwgO(J59IJuPI2nENVhIjA(mYLa1pG6AauxgQ)yEVaBLmk8DeR5TYKiA(mYLa1paa1v0luxgQ)yEVaBLmk8DeR5TYKiWoGAzHAzH6Yq9hZ7fhPsfTB8oFpetGDGadQLZIa99qmP43NeNhRXhzi5EvteEiqEJVIVOcqG0onUZabArxXMWYt2zJ7Mmu)aQROxOUyrOwgO2IUInHLNSZg3nzO(butNrDhPR4ivQODJ357HyIMpJCjqDzO(J59cSvYOW3rSM3ktIa7aQLfbgulNfb67HysXVpjopwJpYqgc8Y(atzi8qY9cHhcmOwolc8m3RZ3mxhJa5n(k(Ikazi5QfHhcK34R4lQaeiTtJ7mqGpd13Xe(EiMZZaNBHL035wb1LHAzG6NHAlu8AIFZHjXnEhj3Bhvdje8gFfFH6IfHA6mQ7iDf)MdtIB8osU3oQgsiA(mYLa1Yd1VkeQLfbgulNfbkzKQYTY9vbXqgsUNq4Ha5n(k(Ikabs704ode4hZ7fjfFNfQzjIMpJCjq9daqDf9c1LH6pM3lsk(oluZseyhqDzOMCWkLZIUInIOsf0muU4c8yPmulpaOUwOUmuldu)muBHIxt8BomjUX7i5E7OAiHG34R4luxSiutNrDhPR43CysCJ3rY92r1qcrZNrUeOwEO(vHqTSiWGA5SiWkvqZq5IlWJLYidjxnr4Ha5n(k(Ikabs704ode4hZ7fjfFNfQzjIMpJCjq9daqDf9c1LH6pM3lsk(oluZseyhqDzOwgO(zO2cfVM43CysCJ3rY92r1qcbVXxXxOUyrOMoJ6osxXV5WK4gVJK7TJQHeIMpJCjqT8q9RcHAzrGb1YzrG(EiMJyD(MrgsUcr4Ha5n(k(IkabgulNfbsdLYfulN1PsIHavjXCBCYiq6mQ7iDjidjx9eHhcK34R4lQaeiTtJ7mqGwO41e)MdtIB8osU3oQgsi4n(k(c1LHAzGA6mQ7iDf)MdtIB8osU3oQgsiA(mYLa1pG6cH6IfHAzGA6mQ7iDf)MdtIB8osU3oQgsiA(mYLa1pG6AlbQld1w0vSjS8KD24Ujd1pG6NkeQLfQLfbgulNfb2yRlOwoRtLedbQsI524KrG)H4oMrLBfYqYvJq4Ha5n(k(Ikabs704ode4DmXV5WK4gVJK7TJQHeclPVZTcbgulNfb2yRlOwoRtLedbQsI524KrG)H4SK(o3kKHKRgGWdbYB8v8fvacK2PXDgiWpM3losLkA34D(EiMa7aQld1wO41eZxLg3HLZk4n(k(IadQLZIaBS1fulN1PsIHavjXCBCYiW5RsJ7WYzrgsU6dHhcK34R4lQaeiTtJ7mqGb1sGZoE5ZKjqT8aG6ArGb1YzrGn26cQLZ6ujXqGQKyUnozeymmYqY9QeeEiqEJVIVOcqGb1YzrG0qPCb1YzDQKyiqvsm3gNmcKyXEJ(ImKHajwS3OVi8qY9cHhcmOwolcS5ZPjSIjeN0CnUrG8gFfFrfGmKC1IWdbYB8v8fvacK2PXDgiq6mQ7iDfnFonHvmH4KMRXTO5Zixcu)aauxludmqDf9c1LHAlu8AIQWKWDUvoIn9PG34R4lcmOwolc03dXCeRZ3mYqY9ecpeiVXxXxubiqANg3zGa)yEVOZtwGDGadQLZIaLmsv5w5(QGyidjxnr4Ha5n(k(Ikabs704ode4Zq9hZ7f(EQJx3bMIWcSdOUmuBHIxt47PoEDhykcl4n(k(IadQLZIaNVknUdJrgsUcr4Ha5n(k(Ikabs704odeyJTj1Dms5wCzFstdQFa1Ya1VkeQXbQTqXRjASnPUWmEXclNvWB8v8fQbgO(jOwweyqTCweOVhI5iwNVzKHKREIWdbYB8v8fvacK2PXDgiWpM3lENkvUvUZGkjxwGDa1LH6gBzHLNSZgxnHA5ba1v0lcmOwolc03dXiu8njmYqYvJq4Ha5n(k(Ikabs704odeyJTj1Dms5wCzFstdQLhQLbQRTqOghO2cfVMOX2K6cZ4flSCwbVXxXxOgyG6NGAzrGb1YzrGZxLg3HXidjxnaHhcmOwolc03dXCeRZ3mcK34R4lQaKHKR(q4HadQLZIaLm96gVtAUg3iqEJVIVOcqgsUxLGWdbgulNfbgnnw2zt38AiqEJVIVOcqgYqgce4CtYzrYvBjVQVsQTKxIAFQWAIaLg9MBfbbwJFEmTXxOU(G6GA5SqTkjgrabcbE0JpvmcSEHAGvpedQb25WKa11qBwjXGavVqTeZoi1FCXTknjyFbDoXLKNyQWYzPD4nCj5jf3VA(4(9r94Yah3JE8PIj4cS1CnCKxcUaB1WoGDomjUAOnRKyoGvpetqYtkeO6fQbw8VXIgFO(vnQuOU2sEvFqD9aQlPK6)R6dceeO6fQRFLeBftQ)qGQxOUEa114lvHDzOU(rUxOgy1mxhlGabbQEH6AmQFYumJVq9N9tZqnDo)Hb1FUkxIaQRXsP8HrG6D26HKOp9ykOoOwolbQNvHVacuqTCwI4Oz6C(ddGxfK3qGcQLZsehntNZFy4aax)mxiqb1YzjIJMPZ5pmCaGBGvDYRfwoleO6fQb34GizmOUJ8c1FmVNVqnXcJa1F2pnd1058hgu)5QCjqDSxO(O56XXywUvqDsG67SSacuqTCwI4Oz6C(ddha4s24GizmhXcJabkOwolrC0mDo)HHdaCpglNfceeO6fQRXO(jtXm(c1mW5gFO2YtgQnjmuhuBAOojqDa8ivXxXciqb1YzjaoZ968nZ1XqGQxOUg7XHcFOgy1dXGAGfdCUH6yVq9zKRf5c114u8HA8c1Seiqb1Yzj4aaxjJuvUvUVkiwPPhWZ3Xe(EiMZZaNBHL035wvwMNTqXRj(nhMe34DKCVDunKqWB8v8Tyr6mQ7iDf)MdtIB8osU3oQgsiA(mYLi)RcLfcuqTCwcoaWTsf0muU4c8yPCPPhWhZ7fjfFNfQzjIMpJCjpaurVL)yEViP47SqnlrGDuMCWkLZIUInIOsf0muU4c8yPS8aQTSmpBHIxt8BomjUX7i5E7OAiHG34R4BXI0zu3r6k(nhMe34DKCVDunKq08zKlr(xfkleOGA5SeCaGRVhI5iwNV5stpGpM3lsk(oluZsenFg5sEaOIEl)X8ErsX3zHAwIa7OSmpBHIxt8BomjUX7i5E7OAiHG34R4BXI0zu3r6k(nhMe34DKCVDunKq08zKlr(xfkleOGA5SeCaGlnukxqTCwNkjwPBCYaOZOUJ0LabkOwolbha42yRlOwoRtLeR0noza)H4oMrLBvPPhGfkEnXV5WK4gVJK7TJQHecEJVIVLLHoJ6osxXV5WK4gVJK7TJQHeIMpJCjpkSyrzOZOUJ0v8BomjUX7i5E7OAiHO5ZixYJAlPSfDfBclpzNnUBYpEQqzLfcuqTCwcoaWTXwxqTCwNkjwPBCYa(dXzj9DUvLMEa3Xe)MdtIB8osU3oQgsiSK(o3kiqb1Yzj4aa3gBDb1YzDQKyLUXjdy(Q04oSC2stpGpM3losLkA34D(EiMa7OSfkEnX8vPXDy5ScEJVIVqGcQLZsWbaUn26cQLZ6ujXkDJtgqmCPPhqqTe4SJx(mzI8aQfcuqTCwcoaWLgkLlOwoRtLeR0nozael2B0xiqqGcQLZseXWaA(CAcRycXjnxJ7stpalu8AIQWKWDUvoIn9PG34R4BXIYe1XDASW3tD86m(8GjMOJ9DzYbRuol6k2iIMpNMWkMqCsZ14wEapv(5pM3l68KfyhYcbkOwolredJdaCRubndLlUapwkxA6byHIxt47Hyek(MewWB8v8fcuqTCwIiggha467HyoI15BUul6k2CPhGmx(J59IoQB6KYcIf03pkSyXl)X8Erh1nDszrZNrUKhVkr2Y0zu3r6kA(CAcRycXjnxJBrZNrUKhaQfyQO3YwO41evHjH7CRCeB6tbVXxX3YpBHIxt47Hyek(MewWB8v8fcuqTCwIiggha467HyoI15BU00dGoJ6osxrZNttyftioP5AClA(mYL8aqTatf9w2cfVMOkmjCNBLJytFk4n(k(cbkOwolredJdaCLmsv5w5(QGyLMEaFmVx05jlWoGafulNLiIHXbaU(EigHIVjHln9a(yEV4DQu5w5odQKCzb2beOGA5SermmoaWTsf0muU4c8yPCPPhqJTj1Dms5wCzFst7HmVkehlu8AIgBtQlmJxSWYzf8gFfFbMNKfcuqTCwIiggha467HyoI15BUul6k2CPhGmx(J59IoQB6KYcIf03pkSyXl)X8Erh1nDszrZNrUKhVkr2Yn2Mu3XiLBXL9jnThY8QqCSqXRjASnPUWmEXclNvWB8v8fyEs2YpBHIxt47Hyek(MewWB8v8fcuqTCwIiggha467HyoI15BU00dOX2K6ogPClUSpPP9qMxfIJfkEnrJTj1fMXlwy5ScEJVIVaZtYcbkOwolredJdaCB(CAcRycXjnxJBiqb1YzjIyyCaGRVhIrO4Bsyiqb1YzjIyyCaG78vPXDyCPw0vS5spazU8hZ7fDu30jLfelOVFuyXIx(J59IoQB6KYIMpJCjpEvISLBSnPUJrk3Il7tAAYltTfIJfkEnrJTj1fMXlwy5ScEJVIVaZtYw(zlu8AcFpeJqX3KWcEJVIVqGcQLZseXW4aa35RsJ7W4stpGgBtQ7yKYT4Y(KMM8YuBH4yHIxt0yBsDHz8IfwoRG34R4lW8KSqGcQLZseXW4aa3kvqZq5IlWJLYqGcQLZseXW4aaxFpeZrSoFZLArxXMl9aK5YFmVx0rDtNuwqSG((rHflE5pM3l6OUPtklA(mYL84vjYw(zlu8AcFpeJqX3KWcEJVIVqGcQLZseXW4aaxFpeZrSoFZqGcQLZseXW4aaxjtVUX7KMRXneOGA5SermmoaWnAASSZMU51GabbQEH6cAomjq94HAWCVDunKaQpMrLBfu3Jfwolux)HAIfTrG6AlHa1F2pnd1aBPsfnupEOgy1dXGACG6cgqOoAgQdGhPk(kgcuqTCwI4pe3XmQCRaizKQYTY9vbXkn9a(yEVOZtwGDabkOwolr8hI7ygvUv4aa35RsJ7W4sTORyZLEaYC5pM3l6OUPtkliwqF)OWIfV8hZ7fDu30jLfnFg5sE8Qezl3yllS8KD24Q5Jk6TCJTj1Dms5wCzFsttEa1wy5NTqXRj89qmcfFtcl4n(k(cbkOwolr8hI7ygvUv4aa35RsJ7W4stpGgBzHLNSZgxnFurVLBSnPUJrk3Il7tAAYdO2cHafulNLi(dXDmJk3kCaGBLkOzOCXf4Xs5stpGgBtQ7yKYT4Y(KM2JAlPmDg1DKUIJuPI2nENVhIjA(mYLiFJTSWYt2zJRMLjhSs5SORyJiQubndLlUapwklpGAHafulNLi(dXDmJk3kCaGRVhI5iwNV5sTORyZLEaYC5pM3l6OUPtkliwqF)OWIfV8hZ7fDu30jLfnFg5sE8Qezl3yBsDhJuUfx2N00EuBjLPZOUJ0vCKkv0UX789qmrZNrUe5BSLfwEYoBC1S8ZwO41e(EigHIVjHf8gFfFHafulNLi(dXDmJk3kCaGRVhI5iwNV5stpGgBtQ7yKYT4Y(KM2JAlPmDg1DKUIJuPI2nENVhIjA(mYLiFJTSWYt2zJRMqGcQLZse)H4oMrLBfoaW13dXiu8njCPPhWhZ7fVtLk3k3zqLKllWok3yBsDhJuUfx2N00KxMxfIJfkEnrJTj1fMXlwy5ScEJVIVaZtYwMCWkLZIUInIW3dXiu8njS8aQfcuqTCwI4pe3XmQCRWbaU(EigHIVjHln9aASnPUJrk3Il7tAAYdqMNkehlu8AIgBtQlmJxSWYzf8gFfFbMNKTm5GvkNfDfBeHVhIrO4Bsy5buleOGA5SeXFiUJzu5wHdaCNVknUdJl1IUInx6biZL)yEVOJ6MoPSGyb99Jclw8YFmVx0rDtNuw08zKl5XRsKTCJTj1Dms5wCzFsttEaY8uH4yHIxt0yBsDHz8IfwoRG34R4lW8KSLF2cfVMW3dXiu8njSG34R4leOGA5SeXFiUJzu5wHdaCNVknUdJln9aASnPUJrk3Il7tAAYdqMNkehlu8AIgBtQlmJxSWYzf8gFfFbMNKfcuqTCwI4pe3XmQCRWbaUvQGMHYfxGhlLln9aOZOUJ0vCKkv0UX789qmrZNrUe5BSLfwEYoBC1SCJTj1Dms5wCzFst7rnlPm5GvkNfDfBerLkOzOCXf4Xsz5buleOGA5SeXFiUJzu5wHdaC99qmhX68nxQfDfBU0dqMl)X8Erh1nDszbXc67hfwS4L)yEVOJ6MoPSO5ZixYJxLiBz6mQ7iDfhPsfTB8oFpet08zKlr(gBzHLNSZgxnl3yBsDhJuUfx2N00EuZsk)SfkEnHVhIrO4BsybVXxXxiqb1YzjI)qChZOYTcha467HyoI15BU00dGoJ6osxXrQur7gVZ3dXenFg5sKVXwwy5j7SXvZYn2Mu3XiLBXL9jnTh1SeiqqGcQLZse)H4SK(o3kaZxLg3HXLArxXMl9aK5YFmVx0rDtNuwqSG((rHflE5pM3l6OUPtklA(mYL84vjYwUX2K6ogPC)aWtLu(zlu8AcFpeJqX3KWcEJVIVqGcQLZse)H4SK(o3kCaG78vPXDyCPPhqJTj1Dms5(bGNkbcuqTCwI4peNL035wHdaCB(CAcRycXjnxJ7stpalu8AIQWKWDUvoIn9PG34R4leOGA5SeXFiolPVZTcha4kzKQYTY9vbXkn9a(yEVOZtwGDabkOwolr8hIZs67CRWbaUZxLg3HXLArxXMl9aK5YFmVx0rDtNuwqSG((rHflE5pM3l6OUPtklA(mYL84vjYwUXwwy5j7SXv4Jk6TyXgBtQ7yKY9da1SWYpBHIxt47Hyek(MewWB8v8fcuqTCwI4peNL035wHdaCNVknUdJln9aASLfwEYoBCf(OIElwSX2K6ogPC)aqnlecuqTCwI4peNL035wHdaC99qmcfFtcxA6b8X8EX7uPYTYDguj5YcSJYKdwPCw0vSre(EigHIVjHLhqTqGcQLZse)H4SK(o3kCaGRKPx34DsZ14U00dOX2K6ogPClUSpPPjpGNkPCJTSWYt2zJ7j5ROxiqb1YzjI)qCwsFNBfoaWT5ZPjSIjeN0CnUHafulNLi(dXzj9DUv4aaxFpeJqX3KWLMEaKdwPCw0vSre(EigHIVjHLhqTqGcQLZse)H4SK(o3kCaG78vPXDyCPw0vS5spazU8hZ7fDu30jLfelOVFuyXIx(J59IoQB6KYIMpJCjpEvISLBSnPUJrk3Il7tAAYxBHfl2yll)tLF2cfVMW3dXiu8njSG34R4leOGA5SeXFiolPVZTcha4oFvAChgxA6b0yBsDhJuUfx2N00KV2clwSXww(NGafulNLi(dXzj9DUv4aa3OPXYoB6MxR00dOX2K6ogPClUSpPPjFTLabccu9c11VJ6c1s4OnOMo7nTCwceOGA5SebDuxNeoAdavsKlXnExs5stpGpM3lOJ66KWrBcIf03Yxyzl6k2ewEYoBC3KFurVqGcQLZse0rDDs4OnCaGlvsKlXnExs5stpaz(yEV4ivQODJ357HyIMpJCjpaurVaJmVWHoJ6osxHVhIjf)(K48yn(IMJl(YwS4hZ7fhPsfTB8oFpet08zKl5rJTSWYt2zJ7jzl)X8EXrQur7gVZ3dXeyhqGcQLZse0rDDs4OnCaGlvsKlXnExs5stpGpM3losLkA34D(EiMO5ZixYJAq5pM3lWwjJcFhXAERmjIMpJCjpQOxGrMx4qNrDhPRW3dXKIFFsCESgFrZXfFzl)X8Eb2kzu47iwZBLjr08zKlP8hZ7fhPsfTB8oFpetGDabccuqTCwIGoJ6osxcamc7sJpjLMEaYqNrDhPR4ivQODJ357HyIMJl(flsNrDhPR4ivQODJ357HyIMpJCjYxBjYwwMNTqXRj(nhMe34DKCVDunKqWB8v8Tyr6mQ7iDf85XiLBxJTStkhhZkA(mYLiF9vOSqGcQLZse0zu3r6sWbaUye2LgFw6gNmGQE2kI7OZZq56OIln9aASLFa4PYp)X8EXrQur7gVZ3dXeyhLL557yIFZHjXnEhj3BhvdjewsFNBvXIpBHIxt8BomjUX7i5E7OAiHG34R4RSqGcQLZse0zu3r6sWbaUye2LgFw6gNmGoQ7ITVjUFw5A(6(yMnleOGA5SebDg1DKUeCaGlgHDPXNLUXjd4KB(TjjioFSvLMEapFht8BomjUX7i5E7OAiHWs67CRk)8hZ7fhPsfTB8oFpetGDabkOwolrqNrDhPlbha4EmwoBPPhWhZ7fhPsfTB8oFpetGDu(J59c(8yKYTRXw2jLJJzfyhqGcQLZse0zu3r6sWbaUF1mxNhRXV00d4J59IJuPI2nENVhIjWok)X8EbFEms521yl7KYXXScSdiqb1Yzjc6mQ7iDj4aa3p3eUFNBvPPhWhZ7fhPsfTB8oFpetGDabQEHAGvpedQPZOUJ0LabkOwolrqNrDhPlbha4EKkv0UX789qSstpa6mQ7iDf85XiLBxJTStkhhZkA(mYLabkOwolrqNrDhPlbha4(BomjUX7i5E7OAirPye2nEVRIEb8Q00dGoJ6osxbFEms521yl7KYXXSIMpJCjLPZOUJ0vCKkv0UX789qmrZNrUeiqb1Yzjc6mQ7iDj4aax(8yKYTRXw2jLJJzln9aOZOUJ0vCKkv0UX789qmrZXf)YpBHIxt8BomjUX7i5E7OAiHG34R4B5gBzHLNSZgxHYxrVLBSnPUJrk3Il7tAAYd4vjqGcQLZse0zu3r6sWbaU85XiLBxJTStkhhZwA6bidDg1DKUIJuPI2nENVhIjAoU4xSOfDfBclpzNnUBYpQTezlBHIxt8BomjUX7i5E7OAiHG34R4B5gBz5b8u5gBtQ7yKYT81ZsGafulNLiOZOUJ0LGdaCPHs5cQLZ6ujXkDJtgaDuxNeoAR00dWcfVMGoQRtchTj4n(k(wwgz(yEVGoQRtchTjiwqFlpGxLu(YFmVx0rDtNuwqSG(gqHYwSOfDfBclpzNnUBYpaurVYcbkOwolrqNrDhPlbha467HysXVpjopwJFPPhGmFmVxCKkv0UX789qmrZNrUKhaQO3IfL5J59IJuPI2nENVhIjA(mYL8Ogu(J59cSvYOW3rSM3ktIO5ZixYdav0B5pM3lWwjJcFhXAERmjcSdzLT8hZ7fhPsfTB8oFpetGDabkOwolrqNrDhPlbha467HysXVpjopwJFPPhGfDfBclpzNnUBYpQO3IfLXIUInHLNSZg3n5h0zu3r6kosLkA34D(EiMO5Zixs5pM3lWwjJcFhXAERmjcSdzHabbQEH6Am)Q04oSCwOUhlSCwiqb1YzjI5RsJ7WYzb0850ewXeItAUg3LMEawO41evHjH7CRCeB6tbVXxXxiqb1YzjI5RsJ7WYzXbaUZxLg3HXLArxXMl9aK5YFmVx0rDtNuwqSG((rHflE5pM3l6OUPtklA(mYL84vjYw(zlu8AcFpeJqX3KWcEJVIVLF(J59Iopzb2rzYbRuol6k2icjJuvUvUVkiM8aEccuqTCwIy(Q04oSCwCaG78vPXDyCPPhWZwO41e(EigHIVjHf8gFfFl)8hZ7fDEYcSJYKdwPCw0vSresgPQCRCFvqm5b8eeOGA5SeX8vPXDy5S4aaxFpeJqX3KWLMEaY8X8EX7uPYTYDguj5YIMdQvSOmFmVx8ovQCRCNbvsUSa7OSmhndCxf9kEj89qmhX68nxS4rZa3vrVIxcjJuvUvUVkiwXIhndCxf9kEjQubndLlUapwklRSYwMCWkLZIUInIW3dXiu8njS8aQfcuqTCwIy(Q04oSCwCaG78vPXDyCPw0vS5spazU8hZ7fDu30jLfelOVFuyXIx(J59IoQB6KYIMpJCjpEvISL)yEV4DQu5w5odQKCzrZb1kwuMpM3lENkvUvUZGkjxwGDuwMJMbURIEfVe(EiMJyD(Mlw8OzG7QOxXlHKrQk3k3xfeRyXJMbURIEfVevQGMHYfxGhlLLvwiqb1YzjI5RsJ7WYzXbaUZxLg3HXLMEaFmVx8ovQCRCNbvsUSO5GAflkZhZ7fVtLk3k3zqLKllWoklZrZa3vrVIxcFpeZrSoFZflE0mWDv0R4LqYivLBL7RcIvS4rZa3vrVIxIkvqZq5IlWJLYYkleOGA5SeX8vPXDy5S4aa3kvqZq5IlWJLYLMEaY88hZ7fDEYcSJIfBSnPUJrk3Il7tAApEvsXIn2YclpzNnUALVIELTm5GvkNfDfBerLkOzOCXf4Xsz5buleOGA5SeX8vPXDy5S4aaxjJuvUvUVkiwPPhWhZ7fDEYcSJYKdwPCw0vSresgPQCRCFvqm5buleOGA5SeX8vPXDy5S4aaxFpeZrSoFZLArxXMl9aK5YFmVx0rDtNuwqSG((rHflE5pM3l6OUPtklA(mYL84vjYw(5pM3l68Kfyhfl2yBsDhJuUfx2N00E8QKIfBSLfwEYoBC1kFf9w(zlu8AcFpeJqX3KWcEJVIVqGcQLZseZxLg3HLZIdaC99qmhX68nxA6b88hZ7fDEYcSJIfBSnPUJrk3Il7tAApEvsXIn2YclpzNnUALVIEHafulNLiMVknUdlNfha4kzKQYTY9vbXkn9a(yEVOZtwGDabkOwolrmFvAChwoloaWD(Q04omUul6k2CPhGmx(J59IoQB6KYcIf03pkSyXl)X8Erh1nDszrZNrUKhVkr2YpBHIxt47Hyek(MewWB8v8fcuqTCwIy(Q04oSCwCaG78vPXDymeiiq1ludAXEJ(c1KCRuC9WIUInOUhlSCwiqb1YzjcIf7n6lGMpNMWkMqCsZ14gcuqTCwIGyXEJ(IdaC99qmhX68nxA6bqNrDhPRO5ZPjSIjeN0CnUfnFg5sEaOwGPIElBHIxtufMeUZTYrSPpf8gFfFHafulNLiiwS3OV4aaxjJuvUvUVkiwPPhWhZ7fDEYcSdiqb1YzjcIf7n6loaWD(Q04omU00d45pM3l89uhVUdmfHfyhLTqXRj89uhVUdmfHf8gFfFHafulNLiiwS3OV4aaxFpeZrSoFZLMEan2Mu3XiLBXL9jnThY8QqCSqXRjASnPUWmEXclNvWB8v8fyEswiqb1YzjcIf7n6loaW13dXiu8njCPPhWhZ7fVtLk3k3zqLKllWok3yllS8KD24QP8aQOxiqb1YzjcIf7n6loaWD(Q04omU00dOX2K6ogPClUSpPPjVm1wiowO41en2MuxygVyHLZk4n(k(cmpjleOGA5SebXI9g9fha467HyoI15BgcuqTCwIGyXEJ(IdaCLm96gVtAUg3qGcQLZseel2B0xCaGB00yzNnDZRHajhmfjxTf(czidHa]] )

    
end
