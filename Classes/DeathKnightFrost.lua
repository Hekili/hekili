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


    spec:RegisterPack( "Frost DK", 20190201.2354, [[du0CFbqivr9ivrytsKrru6uefRsvKEfGAwskULQiYUi8lOIHjP0XaWYKO6zsQAAsu6AsGTjrr(guPW4KOGZbvQSoOsrZtv4EQs7JOQdkrrPfkb9qvrunrOsvDrjkkSrOsPtkrr1kbKxkrHCtvruStIk)uIIIgkuPklvIc1tbAQqv2lK)sLbtQdlSyv1JrAYQ0LrTzQ6ZsYOjItl61a0Sj52QODR0VvmCvy5s9CetNY1HY2Hk57ePXRkIsNhQQ1lPY8Lq7h0iaq4HaVHXi5kVwaWD1wETaikV(ckBzlabA4FWiWJGcyuXiWnozeiUThIb14(LriWJaF1exeEiqYG1ugbkXSdcUjo4uLMeSVGoN4qYtmvy5S0o8goK8KIZxnFC((4jDzCHZrp(uXeCW9AUmoYlbhCVYyhUphMexz0MvsmhUThIji5jfb(XsLvMVOpc8ggJKR8Aba3vB51cGO86lOSLTEeyGzsMgbcMNp5iqj59Yl6JaVmHIaFcOg32dXGACFomjqDz0MvsmiqpbulXSdcUjo4uLMeSVGoN4qYtmvy5S0o8goK8KIZxnFC((4jDzCHZrp(uXeCW9AUmoYlbhCVYyhUphMexz0MvsmhUThIji5jfc0ta14w(3yrJpudqnqD51caUdQFsqD51JBwq9qGGa9eq9tUKyRycUjeONaQFsqDz(svyxgQFYK7fQXTnZ1XceOkjgbHhcKoQRtchTHWdjhai8qG8gFfFrfIaPDACNbc8J59c6OUojC0MGybfqOwEOUaOUeuBrxXMWYt2zJ7Mmu)aQROxeyqTCweivsKlXnExszKHKRCeEiqEJVIVOcrG0onUZabklu)X8EXrQur7gVZ3dXenFg5sG6hVqDf9c1pfQLfQbaQbgQPZOUJ0v47HysXVpjopwJVO54IpulduxSiu)X8EXrQur7gVZ3dXenFg5sG6hqDJTSWYt2zJREOwgOUeu)X8EXrQur7gVZ3dXeyhiWGA5SiqQKixIB8UKYidjx9i8qG8gFfFrfIaPDACNbc8J59IJuPI2nENVhIjA(mYLa1pG6YauxcQ)yEVaBLmk8DeR5TYKiA(mYLa1pG6k6fQFkulludaudmutNrDhPRW3dXKIFFsCESgFrZXfFOwgOUeu)X8Eb2kzu47iwZBLjr08zKlbQlb1FmVxCKkv0UX789qmb2bcmOwolcKkjYL4gVlPmYqgcC(Q04oSCweEi5aaHhcK34R4lQqeiTtJ7mqGwO41evHjH7CRCeB6tbVXxXxeyqTCweyZNttyftioP5ACJmKCLJWdbYB8v8fvicK2PXDgiqzH6l)X8Erh1nDszbXckGq9dOUaOUyrO(YFmVx0rDtNuw08zKlbQFa1aululduxcQFgQTqXRj89qmcfFtcl4n(k(c1LG6NH6pM3l68KfyhqDjOMCWkLZIUInIqYivLBL7RcIb1Y)c11JadQLZIaNVknUdJrgsU6r4Ha5n(k(Ikebs704ode4ZqTfkEnHVhIrO4BsybVXxXxOUeu)mu)X8ErNNSa7aQlb1KdwPCw0vSresgPQCRCFvqmOw(xOUEeyqTCwe48vPXDymYqYvweEiqEJVIVOcrG0onUZabklu)X8EbGPsLBL7mOsYLfnhudQlweQLfQ)yEVaWuPYTYDguj5YcSdOUeulluF0mUCv0RaaHVhI5iwNaYqDXIq9rZ4YvrVcaesgPQCRCFvqmOUyrO(OzC5QOxbaIkvqZq5IlUILYqTmqTmqTmqDjOMCWkLZIUInIW3dXiu8njmul)luxocmOwolc03dXiu8njmYqYvacpeiVXxXxuHiqANg3zGaLfQV8hZ7fDu30jLfelOac1pG6cG6IfH6l)X8Erh1nDszrZNrUeO(budqTqTmqDjO(J59catLk3k3zqLKllAoOguxSiullu)X8EbGPsLBL7mOsYLfyhqDjOwwO(OzC5QOxbacFpeZrSobKH6IfH6JMXLRIEfaiKmsv5w5(QGyqDXIq9rZ4YvrVcaevQGMHYfxCflLHAzGAzqGb1YzrGZxLg3HXidjxzcHhcK34R4lQqeiTtJ7mqGFmVxayQu5w5odQKCzrZb1G6IfHAzH6pM3lamvQCRCNbvsUSa7aQlb1Yc1hnJlxf9kaq47HyoI1jGmuxSiuF0mUCv0RaaHKrQk3k3xfedQlweQpAgxUk6vaGOsf0muU4IRyPmulduldcmOwolcC(Q04omgzi5Wnq4Ha5n(k(Ikebs704odeOSq9Zq9hZ7fDEYcSdOUyrOUX2K6ogPClUSpPPb1pGAaQfQlweQBSLfwEYoBCLd1Yd1v0lulduxcQjhSs5SORyJiQubndLlU4kwkd1Y)c1LJadQLZIaRubndLlU4kwkJmKCLbeEiqEJVIVOcrG0onUZab(X8ErNNSa7aQlb1KdwPCw0vSresgPQCRCFvqmOw(xOUCeyqTCweOKrQk3k3xfedzi5WDi8qG8gFfFrfIaPDACNbcuwO(YFmVx0rDtNuwqSGciu)aQlaQlweQV8hZ7fDu30jLfnFg5sG6hqna1c1Ya1LG6NH6pM3l68KfyhqDXIqDJTj1Dms5wCzFstdQFa1auluxSiu3yllS8KD24khQLhQROxOUeu)muBHIxt47Hyek(MewWB8v8fbgulNfb67HyoI1jGmYqYbqTi8qG8gFfFrfIaPDACNbc8zO(J59Iopzb2buxSiu3yBsDhJuUfx2N00G6hqna1c1flc1n2YclpzNnUYHA5H6k6fbgulNfb67HyoI1jGmYqYbaai8qG8gFfFrfIaPDACNbc8J59Iopzb2bcmOwolcuYivLBL7RcIHmKCauocpeiVXxXxuHiqANg3zGaLfQV8hZ7fDu30jLfelOac1pG6cG6IfH6l)X8Erh1nDszrZNrUeO(budqTqTmqDjO(zO2cfVMW3dXiu8njSG34R4lcmOwolcC(Q04omgzi5aOEeEiWGA5SiW5RsJ7WyeiVXxXxuHidziqIf7n6lcpKCaGWdbgulNfb2850ewXeItAUg3iqEJVIVOcrgsUYr4Ha5n(k(Ikebs704odeiDg1DKUIMpNMWkMqCsZ14w08zKlbQF8c1Ld1pfQROxOUeuBHIxtufMeUZTYrSPpf8gFfFrGb1YzrG(EiMJyDciJmKC1JWdbYB8v8fvicK2PXDgiWpM3l68KfyhiWGA5SiqjJuvUvUVkigYqYvweEiqEJVIVOcrG0onUZab(mu)X8EHVN641DGPiSa7aQlb1wO41e(EQJx3bMIWcEJVIViWGA5SiW5RsJ7WyKHKRaeEiqEJVIVOcrG0onUZab2yBsDhJuUfx2N00G6hqTSqnafa1ad1wO41en2MuxygVyHLZk4n(k(c1pfQRhQLbbgulNfb67HyoI1jGmYqYvMq4Ha5n(k(Ikebs704ode4hZ7faMkvUvUZGkjxwGDa1LG6gBzHLNSZgxzHA5FH6k6fbgulNfb67Hyek(Megzi5Wnq4Ha5n(k(Ikebs704odeyJTj1Dms5wCzFstdQLhQLfQlVaOgyO2cfVMOX2K6cZ4flSCwbVXxXxO(PqD9qTmiWGA5SiW5RsJ7WyKHKRmGWdbgulNfb67HyoI1jGmcK34R4lQqKHKd3HWdbgulNfbkz61nEN0CnUrG8gFfFrfImKCaulcpeyqTCwey00yzNnDZRHa5n(k(Ikezidb(hI7ygvUvi8qYbacpeiVXxXxuHiqANg3zGa)yEVOZtwGDGadQLZIaLmsv5w5(QGyidjx5i8qG8gFfFrfIaPDACNbcuwO(YFmVx0rDtNuwqSGciu)aQlaQlweQV8hZ7fDu30jLfnFg5sG6hqna1c1Ya1LG6gBzHLNSZgxzH6hqDf9c1LG6gBtQ7yKYT4Y(KMgul)luxEbqDjO(zO2cfVMW3dXiu8njSG34R4lcmOwolcC(Q04omgzi5QhHhcK34R4lQqeiTtJ7mqGn2YclpzNnUYc1pG6k6fQlb1n2Mu3XiLBXL9jnnOw(xOU8cqGb1YzrGZxLg3HXidjxzr4Ha5n(k(Ikebs704odeyJTj1Dms5wCzFstdQFa1LxluxcQPZOUJ0vCKkv0UX789qmrZNrUeOwEOUXwwy5j7SXvwOUeutoyLYzrxXgruPcAgkxCXvSugQL)fQlhbgulNfbwPcAgkxCXvSugzi5kaHhcK34R4lQqeiTtJ7mqGYc1x(J59IoQB6KYcIfuaH6hqDbqDXIq9L)yEVOJ6MoPSO5Zixcu)aQbOwOwgOUeu3yBsDhJuUfx2N00G6hqD51c1LGA6mQ7iDfhPsfTB8oFpet08zKlbQLhQBSLfwEYoBCLfQlb1pd1wO41e(EigHIVjHf8gFfFrGb1YzrG(EiMJyDciJmKCLjeEiqEJVIVOcrG0onUZab2yBsDhJuUfx2N00G6hqD51c1LGA6mQ7iDfhPsfTB8oFpet08zKlbQLhQBSLfwEYoBCLfbgulNfb67HyoI1jGmYqYHBGWdbYB8v8fvicK2PXDgiWpM3lamvQCRCNbvsUSa7aQlb1n2Mu3XiLBXL9jnnOwEOwwOgGcGAGHAlu8AIgBtQlmJxSWYzf8gFfFH6Nc11d1Ya1LGAYbRuol6k2icFpeJqX3KWqT8VqD5iWGA5SiqFpeJqX3KWidjxzaHhcK34R4lQqeiTtJ7mqGn2Mu3XiLBXL9jnnOw(xOwwOU(cGAGHAlu8AIgBtQlmJxSWYzf8gFfFH6Nc11d1Ya1LGAYbRuol6k2icFpeJqX3KWqT8VqD5iWGA5SiqFpeJqX3KWidjhUdHhcK34R4lQqeiTtJ7mqGYc1x(J59IoQB6KYcIfuaH6hqDbqDXIq9L)yEVOJ6MoPSO5Zixcu)aQbOwOwgOUeu3yBsDhJuUfx2N00GA5FHAzH66laQbgQTqXRjASnPUWmEXclNvWB8v8fQFkuxpulduxcQFgQTqXRj89qmcfFtcl4n(k(IadQLZIaNVknUdJrgsoaQfHhcK34R4lQqeiTtJ7mqGn2Mu3XiLBXL9jnnOw(xOwwOU(cGAGHAlu8AIgBtQlmJxSWYzf8gFfFH6Nc11d1YGadQLZIaNVknUdJrgsoaaaHhcK34R4lQqeiTtJ7mqG0zu3r6kosLkA34D(EiMO5Zixculpu3yllS8KD24kluxcQBSnPUJrk3Il7tAAq9dOUS1c1LGAYbRuol6k2iIkvqZq5IlUILYqT8VqD5iWGA5SiWkvqZq5IlUILYidjhaLJWdbYB8v8fvicK2PXDgiqzH6l)X8Erh1nDszbXckGq9dOUaOUyrO(YFmVx0rDtNuw08zKlbQFa1aululduxcQPZOUJ0vCKkv0UX789qmrZNrUeOwEOUXwwy5j7SXvwOUeu3yBsDhJuUfx2N00G6hqDzRfQlb1pd1wO41e(EigHIVjHf8gFfFrGb1YzrG(EiMJyDciJmKCaupcpeiVXxXxuHiqANg3zGaPZOUJ0vCKkv0UX789qmrZNrUeOwEOUXwwy5j7SXvwOUeu3yBsDhJuUfx2N00G6hqDzRfbgulNfb67HyoI1jGmYqgc8Oz6C(ddHhsoaq4Ha5n(k(Ikezi5khHhcK34R4lQqKHKREeEiqEJVIVOcrgsUYIWdbYB8v8fviYqYvacpeyqTCwe4Xy5SiqEJVIVOcrgYqGXWi8qYbacpeiVXxXxuHiqANg3zGaTqXRjQctc35w5i20NcEJVIVqDXIqTSqDuh3PXcFp1XRZ4ZdMyIowaH6sqn5GvkNfDfBerZNttyftioP5ACd1Y)c11d1LG6NH6pM3l68KfyhqTmiWGA5SiWMpNMWkMqCsZ14gzi5khHhcK34R4lQqeiTtJ7mqGwO41e(EigHIVjHf8gFfFrGb1YzrGvQGMHYfxCflLrgsU6r4Ha5n(k(Ikebs704odeOSq9L)yEVOJ6MoPSGybfqO(buxauxSiuF5pM3l6OUPtklA(mYLa1pGAaQfQLbQlb10zu3r6kA(CAcRycXjnxJBrZNrUeO(Xluxou)uOUIEH6sqTfkEnrvys4o3khXM(uWB8v8fQlb1pd1wO41e(EigHIVjHf8gFfFrGb1YzrG(EiMJyDciJmKCLfHhcK34R4lQqeiTtJ7mqG0zu3r6kA(CAcRycXjnxJBrZNrUeO(Xluxou)uOUIEH6sqTfkEnrvys4o3khXM(uWB8v8fbgulNfb67HyoI1jGmYqYvacpeiVXxXxuHiqANg3zGa)yEVOZtwGDGadQLZIaLmsv5w5(QGyidjxzcHhcK34R4lQqeiTtJ7mqGFmVxayQu5w5odQKCzb2bcmOwolc03dXiu8njmYqYHBGWdbYB8v8fvicK2PXDgiWgBtQ7yKYT4Y(KMgu)aQLfQbOaOgyO2cfVMOX2K6cZ4flSCwbVXxXxO(PqD9qTmiWGA5SiWkvqZq5IlUILYidjxzaHhcK34R4lQqeiTtJ7mqGYc1x(J59IoQB6KYcIfuaH6hqDbqDXIq9L)yEVOJ6MoPSO5Zixcu)aQbOwOwgOUeu3yBsDhJuUfx2N00G6hqTSqnafa1ad1wO41en2MuxygVyHLZk4n(k(c1pfQRhQLbQlb1pd1wO41e(EigHIVjHf8gFfFrGb1YzrG(EiMJyDciJmKC4oeEiqEJVIVOcrG0onUZab2yBsDhJuUfx2N00G6hqTSqnafa1ad1wO41en2MuxygVyHLZk4n(k(c1pfQRhQLbbgulNfb67HyoI1jGmYqYbqTi8qGb1YzrGnFonHvmH4KMRXncK34R4lQqKHKdaaq4HadQLZIa99qmcfFtcJa5n(k(Ikezi5aOCeEiqEJVIVOcrG0onUZabkluF5pM3l6OUPtkliwqbeQFa1fa1flc1x(J59IoQB6KYIMpJCjq9dOgGAHAzG6sqDJTj1Dms5wCzFstdQLhQLfQlVaOgyO2cfVMOX2K6cZ4flSCwbVXxXxO(PqD9qTmqDjO(zO2cfVMW3dXiu8njSG34R4lcmOwolcC(Q04omgzi5aOEeEiqEJVIVOcrG0onUZab2yBsDhJuUfx2N00GA5HAzH6YlaQbgQTqXRjASnPUWmEXclNvWB8v8fQFkuxpuldcmOwolcC(Q04omgzi5aOSi8qGb1YzrGvQGMHYfxCflLrG8gFfFrfImKCauacpeiVXxXxuHiqANg3zGaLfQV8hZ7fDu30jLfelOac1pG6cG6IfH6l)X8Erh1nDszrZNrUeO(budqTqTmqDjO(zO2cfVMW3dXiu8njSG34R4lcmOwolc03dXCeRtazKHKdGYecpeyqTCweOVhI5iwNaYiqEJVIVOcrgsoaWnq4HadQLZIaLm96gVtAUg3iqEJVIVOcrgsoakdi8qGb1YzrGrtJLD20nVgcK34R4lQqKHmeiDg1DKUeeEi5aaHhcK34R4lQqeiTtJ7mqGYc10zu3r6kosLkA34D(EiMO54IpuxSiutNrDhPR4ivQODJ357HyIMpJCjqT8qD51c1Ya1LGAzH6NHAlu8AIFZHjXnEhj3Bhvdje8gFfFH6IfHA6mQ7iDf85XiLBxJTStkhhZkA(mYLa1Yd14UcGAzqGb1YzrGye2LgFsqgsUYr4Ha5n(k(IkebgulNfbw1ZwrChDEgkxhvmcK2PXDgiWgBzO(XluxpuxcQFgQ)yEV4ivQODJ357HycSdOUeullu)muFht8BomjUX7i5E7OAiHWskG5wb1flc1pd1wO41e)MdtIB8osU3oQgsi4n(k(c1YGa34KrGv9Sve3rNNHY1rfJmKC1JWdbYB8v8fvicCJtgb2rDxSfqI7NvUMVUpMzZIadQLZIa7OUl2ciX9ZkxZx3hZSzrgsUYIWdbYB8v8fvicmOwolc8KBgqtsqC(yRqG0onUZab(muFht8BomjUX7i5E7OAiHWskG5wb1LG6NH6pM3losLkA34D(EiMa7abUXjJap5Mb0KeeNp2kKHKRaeEiqEJVIVOcrG0onUZab(X8EXrQur7gVZ3dXeyhqDjO(J59c(8yKYTRXw2jLJJzfyhiWGA5SiWJXYzrgsUYecpeiVXxXxuHiqANg3zGa)yEV4ivQODJ357HycSdOUeu)X8EbFEms521yl7KYXXScSdeyqTCwe4xnZ15XA8rgsoCdeEiqEJVIVOcrG0onUZab(X8EXrQur7gVZ3dXeyhiWGA5SiWp3eUbm3kKHKRmGWdbYB8v8fvicK2PXDgiq6mQ7iDf85XiLBxJTStkhhZkA(mYLGadQLZIapsLkA34D(EigYqYH7q4Ha5n(k(Ikebs704odeiDg1DKUc(8yKYTRXw2jLJJzfnFg5sG6sqnDg1DKUIJuPI2nENVhIjA(mYLGadQLZIa)nhMe34DKCVDunKazi5aOweEiqEJVIVOcrG0onUZabsNrDhPR4ivQODJ357HyIMJl(qDjO(zO2cfVM43CysCJ3rY92r1qcbVXxXxOUeu3yllS8KD24kaQLhQROxOUeu3yBsDhJuUfx2N00GA5FHAaQfbgulNfbYNhJuUDn2YoPCCmlYqYbaai8qG8gFfFrfIaPDACNbcuwOMoJ6osxXrQur7gVZ3dXenhx8H6IfHAl6k2ewEYoBC3KH6hqD51c1Ya1LGAlu8AIFZHjXnEhj3Bhvdje8gFfFH6sqDJTmul)luxpuxcQBSnPUJrk3qT8qDzQweyqTCweiFEms521yl7KYXXSidjhaLJWdbYB8v8fvicK2PXDgiqlu8Ac6OUojC0MG34R4luxcQLfQLfQ)yEVGoQRtchTjiwqbeQL)fQbOwOUeuF5pM3l6OUPtkliwqbeQFH6cGAzG6IfHAl6k2ewEYoBC3KH6hVqDf9c1YGadQLZIaPHs5cQLZ6ujXqGQKyUnozeiDuxNeoAdzi5aOEeEiqEJVIVOcrG0onUZabklu)X8EXrQur7gVZ3dXenFg5sG6hVqDf9c1flc1Yc1FmVxCKkv0UX789qmrZNrUeO(buxgG6sq9hZ7fyRKrHVJynVvMerZNrUeO(XluxrVqDjO(J59cSvYOW3rSM3ktIa7aQLbQLbQlb1FmVxCKkv0UX789qmb2bcmOwolc03dXKIFFsCESgFKHKdGYIWdbYB8v8fvicK2PXDgiql6k2ewEYoBC3KH6hqDf9c1flc1Yc1w0vSjS8KD24Ujd1pGA6mQ7iDfhPsfTB8oFpet08zKlbQlb1FmVxGTsgf(oI18wzseyhqTmiWGA5SiqFpetk(9jX5XA8rgYqGx2hykdHhsoaq4HadQLZIapZ968nZ1XiqEJVIVOcrgsUYr4Ha5n(k(Ikebs704ode4Zq9DmHVhI58mU4wyjfWCRG6sqTSq9ZqTfkEnXV5WK4gVJK7TJQHecEJVIVqDXIqnDg1DKUIFZHjXnEhj3BhvdjenFg5sGA5HAakaQLbbgulNfbkzKQYTY9vbXqgsU6r4Ha5n(k(Ikebs704ode4hZ7fjfFNfQzjIMpJCjq9JxOUIEH6sq9hZ7fjfFNfQzjcSdOUeutoyLYzrxXgruPcAgkxCXvSugQL)fQlhQlb1Yc1pd1wO41e)MdtIB8osU3oQgsi4n(k(c1flc10zu3r6k(nhMe34DKCVDunKq08zKlbQLhQbOaOwgeyqTCweyLkOzOCXfxXszKHKRSi8qG8gFfFrfIaPDACNbc8J59IKIVZc1SerZNrUeO(XluxrVqDjO(J59IKIVZc1Seb2buxcQLfQFgQTqXRj(nhMe34DKCVDunKqWB8v8fQlweQPZOUJ0v8BomjUX7i5E7OAiHO5ZixculpudqbqTmiWGA5SiqFpeZrSobKrgsUcq4Ha5n(k(IkebgulNfbsdLYfulN1PsIHavjXCBCYiq6mQ7iDjidjxzcHhcK34R4lQqeiTtJ7mqGwO41e)MdtIB8osU3oQgsi4n(k(c1LGAzHA6mQ7iDf)MdtIB8osU3oQgsiA(mYLa1pG6cG6IfHAzHA6mQ7iDf)MdtIB8osU3oQgsiA(mYLa1pG6YRfQlb1w0vSjS8KD24Ujd1pG66laQLbQLbbgulNfb2yRlOwoRtLedbQsI524KrG)H4oMrLBfYqYHBGWdbYB8v8fvicK2PXDgiW7yIFZHjXnEhj3Bhvdjewsbm3keyqTCweyJTUGA5SovsmeOkjMBJtgb(hIZskG5wHmKCLbeEiqEJVIVOcrG0onUZab(X8EXrQur7gVZ3dXeyhqDjO2cfVMy(Q04oSCwbVXxXxeyqTCweyJTUGA5SovsmeOkjMBJtgboFvAChwolYqYH7q4Ha5n(k(Ikebs704odeyqTexSJx(mzcul)luxocmOwolcSXwxqTCwNkjgcuLeZTXjJaJHrgsoaQfHhcK34R4lQqeyqTCweinukxqTCwNkjgcuLeZTXjJajwS3OVidziW)qCwsbm3keEi5aaHhcK34R4lQqeiTtJ7mqGYc1x(J59IoQB6KYcIfuaH6hqDbqDXIq9L)yEVOJ6MoPSO5Zixcu)aQbOwOwgOUeu3yBsDhJuUH6hVqD91c1LG6NHAlu8AcFpeJqX3KWcEJVIViWGA5SiW5RsJ7WyKHKRCeEiqEJVIVOcrG0onUZab2yBsDhJuUH6hVqD91IadQLZIaNVknUdJrgsU6r4Ha5n(k(Ikebs704odeOfkEnrvys4o3khXM(uWB8v8fbgulNfb2850ewXeItAUg3idjxzr4Ha5n(k(Ikebs704ode4hZ7fDEYcSdeyqTCweOKrQk3k3xfedzi5kaHhcK34R4lQqeiTtJ7mqGYc1x(J59IoQB6KYcIfuaH6hqDbqDXIq9L)yEVOJ6MoPSO5Zixcu)aQbOwOwgOUeu3yllS8KD24kaQFa1v0luxSiu3yBsDhJuUH6hVqDzlaQlb1pd1wO41e(EigHIVjHf8gFfFrGb1YzrGZxLg3HXidjxzcHhcK34R4lQqeiTtJ7mqGn2YclpzNnUcG6hqDf9c1flc1n2Mu3XiLBO(Xlux2cqGb1YzrGZxLg3HXidjhUbcpeiVXxXxuHiqANg3zGa)yEVaWuPYTYDguj5YcSdOUeutoyLYzrxXgr47Hyek(MegQL)fQlhbgulNfb67Hyek(Megzi5kdi8qG8gFfFrfIaPDACNbcSX2K6ogPClUSpPPb1Y)c11xluxcQBSLfwEYoBC1d1Yd1v0lcmOwolcuY0RB8oP5ACJmKC4oeEiWGA5SiWMpNMWkMqCsZ14gbYB8v8fviYqYbqTi8qG8gFfFrfIaPDACNbcKCWkLZIUInIW3dXiu8njmul)luxocmOwolc03dXiu8njmYqYbaai8qG8gFfFrfIaPDACNbcuwO(YFmVx0rDtNuwqSGciu)aQlaQlweQV8hZ7fDu30jLfnFg5sG6hqna1c1Ya1LG6gBtQ7yKYT4Y(KMgulpuxEbqDXIqDJTmulpuxpuxcQFgQTqXRj89qmcfFtcl4n(k(IadQLZIaNVknUdJrgsoakhHhcK34R4lQqeiTtJ7mqGn2Mu3XiLBXL9jnnOwEOU8cG6IfH6gBzOwEOUEeyqTCwe48vPXDymYqYbq9i8qG8gFfFrfIaPDACNbcSX2K6ogPClUSpPPb1Yd1LxlcmOwolcmAASSZMU51qgYqgcexCtYzrYvETaugaO2YltcakOSLfbkn6n3kccSm)8yAJVqnUdQdQLZc1QKyebeie4rp(uXiWNaQXT9qmOg3NdtcuxgTzLedc0ta1sm7GGBIdovPjb7lOZjoK8etfwolTdVHdjpP48vZhNVpEsxgx4C0JpvmbhCVMlJJ8sWb3Rm2H7ZHjXvgTzLeZHB7HycsEsHa9eqnUL)nw04d1auduxETaG7G6NeuxE94Mfupeiiqpbu)Klj2kMGBcb6jG6NeuxMVuf2LH6Nm5EHACBZCDSaceeONaQlZ4jltXm(c1F2pnd1058hgu)5QCjcOUmlLYhgbQ3zFssI(0JPG6GA5SeOEwf(ciqb1YzjIJMPZ5pSxVkiacbkOwolrC0mDo)Hb8lo(zUqGcQLZsehntNZFya)ItGvDYRfwoleONaQb34GizmOUJ8c1FmVNVqnXcJa1F2pnd1058hgu)5QCjqDSxO(O5N0XywUvqDsG67SSacuqTCwI4Oz6C(dd4xCiBCqKmMJyHrGafulNLioAMoN)Wa(fNJXYzHabb6jG6YmEYYumJVqnJlUXhQT8KHAtcd1b1MgQtcuh4ksv8vSacuqTCwY7zUxNVzUogc0ta1Lzpou4d142EiguJBzCXnuh7fQpJCTixOUmNIpuJxOMLabkOwolb4xCKmsv5w5(QGy1K(3NVJj89qmNNXf3clPaMBvjzF2cfVM43CysCJ3rY92r1qcbVXxX3IfPZOUJ0v8BomjUX7i5E7OAiHO5ZixI8auGmqGcQLZsa(fNkvqZq5IlUILY1K(3pM3lsk(oluZsenFg5sE8wrVL(yEViP47SqnlrGDuICWkLZIUInIOsf0muU4IRyPS8VLxs2NTqXRj(nhMe34DKCVDunKqWB8v8Tyr6mQ7iDf)MdtIB8osU3oQgsiA(mYLipafideOGA5SeGFXX3dXCeRta5As)7hZ7fjfFNfQzjIMpJCjpERO3sFmVxKu8DwOMLiWokj7ZwO41e)MdtIB8osU3oQgsi4n(k(wSiDg1DKUIFZHjXnEhj3BhvdjenFg5sKhGcKbcuqTCwcWV4qdLYfulN1PsIvZgN8lDg1DKUeiqb1Yzja)ItJTUGA5SovsSA24KF)dXDmJk3QAs)RfkEnXV5WK4gVJK7TJQHecEJVIVLKLoJ6osxXV5WK4gVJK7TJQHeIMpJCjpkOyrzPZOUJ0v8BomjUX7i5E7OAiHO5ZixYJYRTKfDfBclpzNnUBYpQVazKbcuqTCwcWV40yRlOwoRtLeRMno53)qCwsbm3QAs)7DmXV5WK4gVJK7TJQHeclPaMBfeOGA5SeGFXPXwxqTCwNkjwnBCYVZxLg3HLZwt6F)yEV4ivQODJ357HycSJswO41eZxLg3HLZk4n(k(cbkOwolb4xCAS1fulN1PsIvZgN8BmCnP)nOwIl2XlFMmr(3YHafulNLa8lo0qPCb1YzDQKy1SXj)sSyVrFHabbkOwolred)2850ewXeItAUg31K(xlu8AIQWKWDUvoIn9PG34R4BXIYg1XDASW3tD86m(8GjMOJfWsKdwPCw0vSrenFonHvmH4KMRXT8V1x65pM3l68KfyhYabkOwolredd8lovQGMHYfxCflLRj9VwO41e(EigHIVjHf8gFfFHafulNLiIHb(fhFpeZrSobKRXIUInx6FL9YFmVx0rDtNuwqSGc4Jckw8YFmVx0rDtNuw08zKl5ba1ktj6mQ7iDfnFonHvmH4KMRXTO5ZixYJ3YFAf9wYcfVMOkmjCNBLJytFk4n(k(w6zlu8AcFpeJqX3KWcEJVIVqGcQLZseXWa)IJVhI5iwNaY1K(x6mQ7iDfnFonHvmH4KMRXTO5ZixYJ3YFAf9wYcfVMOkmjCNBLJytFk4n(k(cbkOwolredd8losgPQCRCFvqSAs)7hZ7fDEYcSdiqb1YzjIyyGFXX3dXiu8njCnP)9J59catLk3k3zqLKllWoGafulNLiIHb(fNkvqZq5IlUILY1K(3gBtQ7yKYT4Y(KM2dzbOaGTqXRjASnPUWmEXclNvWB8v89P1ldeOGA5SermmWV447HyoI1jGCnw0vS5s)RSx(J59IoQB6KYcIfuaFuqXIx(J59IoQB6KYIMpJCjpaOwzk1yBsDhJuUfx2N00EilafaSfkEnrJTj1fMXlwy5ScEJVIVpTEzk9SfkEnHVhIrO4BsybVXxXxiqb1YzjIyyGFXX3dXCeRta5As)BJTj1Dms5wCzFst7HSauaWwO41en2MuxygVyHLZk4n(k((06LbcuqTCwIigg4xCA(CAcRycXjnxJBiqb1YzjIyyGFXX3dXiu8njmeOGA5SermmWV4mFvAChgxJfDfBU0)k7L)yEVOJ6MoPSGybfWhfuS4L)yEVOJ6MoPSO5ZixYdaQvMsn2Mu3XiLBXL9jnn5LT8ca2cfVMOX2K6cZ4flSCwbVXxX3NwVmLE2cfVMW3dXiu8njSG34R4leOGA5SermmWV4mFvAChgxt6FBSnPUJrk3Il7tAAYlB5faSfkEnrJTj1fMXlwy5ScEJVIVpTEzGafulNLiIHb(fNkvqZq5IlUILYqGcQLZseXWa)IJVhI5iwNaY1yrxXMl9VYE5pM3l6OUPtkliwqb8rbflE5pM3l6OUPtklA(mYL8aGALP0ZwO41e(EigHIVjHf8gFfFHafulNLiIHb(fhFpeZrSobKHafulNLiIHb(fhjtVUX7KMRXneOGA5SermmWV4ennw2zt38AqGGa9eqDHnhMeOE8qnyU3oQgsa1hZOYTcQ7XclNfQXnHAIfTrG6YRLa1F2pnd14EPsfnupEOg32dXGAGH6chqOoAgQdCfPk(kgcuqTCwI4pe3XmQCRELmsv5w5(QGy1K(3pM3l68KfyhqGcQLZse)H4oMrLBfWV4mFvAChgxJfDfBU0)k7L)yEVOJ6MoPSGybfWhfuS4L)yEVOJ6MoPSO5ZixYdaQvMsn2YclpzNnUY(OIEl1yBsDhJuUfx2N00K)T8ck9SfkEnHVhIrO4BsybVXxXxiqb1YzjI)qChZOYTc4xCMVknUdJRj9Vn2YclpzNnUY(OIEl1yBsDhJuUfx2N00K)T8cGafulNLi(dXDmJk3kGFXPsf0muU4IRyPCnP)TX2K6ogPClUSpPP9O8AlrNrDhPR4ivQODJ357HyIMpJCjY3yllS8KD24kBjYbRuol6k2iIkvqZq5IlUILYY)woeOGA5SeXFiUJzu5wb8lo(EiMJyDcixJfDfBU0)k7L)yEVOJ6MoPSGybfWhfuS4L)yEVOJ6MoPSO5ZixYdaQvMsn2Mu3XiLBXL9jnThLxBj6mQ7iDfhPsfTB8oFpet08zKlr(gBzHLNSZgxzl9SfkEnHVhIrO4BsybVXxXxiqb1YzjI)qChZOYTc4xC89qmhX6eqUM0)2yBsDhJuUfx2N00EuETLOZOUJ0vCKkv0UX789qmrZNrUe5BSLfwEYoBCLfcuqTCwI4pe3XmQCRa(fhFpeJqX3KW1K(3pM3lamvQCRCNbvsUSa7OuJTj1Dms5wCzFsttEzbOaGTqXRjASnPUWmEXclNvWB8v89P1ltjYbRuol6k2icFpeJqX3KWY)woeOGA5SeXFiUJzu5wb8lo(EigHIVjHRj9Vn2Mu3XiLBXL9jnn5FLT(ca2cfVMOX2K6cZ4flSCwbVXxX3NwVmLihSs5SORyJi89qmcfFtcl)B5qGcQLZse)H4oMrLBfWV4mFvAChgxJfDfBU0)k7L)yEVOJ6MoPSGybfWhfuS4L)yEVOJ6MoPSO5ZixYdaQvMsn2Mu3XiLBXL9jnn5FLT(ca2cfVMOX2K6cZ4flSCwbVXxX3NwVmLE2cfVMW3dXiu8njSG34R4leOGA5SeXFiUJzu5wb8loZxLg3HX1K(3gBtQ7yKYT4Y(KMM8VYwFbaBHIxt0yBsDHz8IfwoRG34R47tRxgiqb1YzjI)qChZOYTc4xCQubndLlU4kwkxt6FPZOUJ0vCKkv0UX789qmrZNrUe5BSLfwEYoBCLTuJTj1Dms5wCzFst7rzRTe5GvkNfDfBerLkOzOCXfxXsz5FlhcuqTCwI4pe3XmQCRa(fhFpeZrSobKRXIUInx6FL9YFmVx0rDtNuwqSGc4Jckw8YFmVx0rDtNuw08zKl5ba1ktj6mQ7iDfhPsfTB8oFpet08zKlr(gBzHLNSZgxzl1yBsDhJuUfx2N00Eu2Al9SfkEnHVhIrO4BsybVXxXxiqb1YzjI)qChZOYTc4xC89qmhX6eqUM0)sNrDhPR4ivQODJ357HyIMpJCjY3yllS8KD24kBPgBtQ7yKYT4Y(KM2JYwleiiqb1YzjI)qCwsbm3Q35RsJ7W4ASORyZL(xzV8hZ7fDu30jLfelOa(OGIfV8hZ7fDu30jLfnFg5sEaqTYuQX2K6ogPC)4T(Al9SfkEnHVhIrO4BsybVXxXxiqb1YzjI)qCwsbm3kGFXz(Q04omUM0)2yBsDhJuUF8wFTqGcQLZse)H4SKcyUva)ItZNttyftioP5ACxt6FTqXRjQctc35w5i20NcEJVIVqGcQLZse)H4SKcyUva)IJKrQk3k3xfeRM0)(X8ErNNSa7acuqTCwI4peNLuaZTc4xCMVknUdJRXIUInx6FL9YFmVx0rDtNuwqSGc4Jckw8YFmVx0rDtNuw08zKl5ba1ktPgBzHLNSZgxbpQO3IfBSnPUJrk3pElBbLE2cfVMW3dXiu8njSG34R4leOGA5SeXFiolPaMBfWV4mFvAChgxt6FBSLfwEYoBCf8OIElwSX2K6ogPC)4TSfabkOwolr8hIZskG5wb8lo(EigHIVjHRj9VFmVxayQu5w5odQKCzb2rjYbRuol6k2icFpeJqX3KWY)woeOGA5SeXFiolPaMBfWV4iz61nEN0CnURj9Vn2Mu3XiLBXL9jnn5FRV2sn2YclpzNnU6LVIEHafulNLi(dXzjfWCRa(fNMpNMWkMqCsZ14gcuqTCwI4peNLuaZTc4xC89qmcfFtcxt6FjhSs5SORyJi89qmcfFtcl)B5qGcQLZse)H4SKcyUva)IZ8vPXDyCnw0vS5s)RSx(J59IoQB6KYcIfuaFuqXIx(J59IoQB6KYIMpJCjpaOwzk1yBsDhJuUfx2N00KV8ckwSXww(6l9SfkEnHVhIrO4BsybVXxXxiqb1YzjI)qCwsbm3kGFXz(Q04omUM0)2yBsDhJuUfx2N00KV8ckwSXww(6HafulNLi(dXzjfWCRa(fNOPXYoB6MxRM0)2yBsDhJuUfx2N00KV8AHabb6jG6N8rDHAjC0gutN9MwolbcuqTCwIGoQRtchT9sLe5sCJ3LuUM0)(X8EbDuxNeoAtqSGcO8fuYIUInHLNSZg3n5hv0leOGA5SebDuxNeoAd4xCOsICjUX7skxt6FL9J59IJuPI2nENVhIjA(mYL84TIEFQSaamDg1DKUcFpetk(9jX5XA8fnhx8LPyXpM3losLkA34D(EiMO5ZixYJgBzHLNSZgx9Yu6J59IJuPI2nENVhIjWoGafulNLiOJ66KWrBa)IdvsKlXnExs5As)7hZ7fhPsfTB8oFpet08zKl5rzO0hZ7fyRKrHVJynVvMerZNrUKhv07tLfaGPZOUJ0v47HysXVpjopwJVO54IVmL(yEVaBLmk8DeR5TYKiA(mYLu6J59IJuPI2nENVhIjWoGabbkOwolrqNrDhPl5fJWU04tsnP)vw6mQ7iDfhPsfTB8oFpet0CCXVyr6mQ7iDfhPsfTB8oFpet08zKlr(YRvMsY(SfkEnXV5WK4gVJK7TJQHecEJVIVflsNrDhPRGppgPC7ASLDs54ywrZNrUe5XDfideOGA5SebDg1DKUeGFXbJWU04ZA24KFR6zRiUJopdLRJkUM0)2yl)4T(sp)X8EXrQur7gVZ3dXeyhLK957yIFZHjXnEhj3Bhvdjewsbm3QIfF2cfVM43CysCJ3rY92r1qcbVXxXxzGafulNLiOZOUJ0La8loye2LgFwZgN8Bh1DXwajUFw5A(6(yMnleOGA5SebDg1DKUeGFXbJWU04ZA24KFp5Mb0KeeNp2QAs)7Z3Xe)MdtIB8osU3oQgsiSKcyUvLE(J59IJuPI2nENVhIjWoGafulNLiOZOUJ0La8lohJLZwt6F)yEV4ivQODJ357HycSJsFmVxWNhJuUDn2YoPCCmRa7acuqTCwIGoJ6osxcWV48vZCDESg)As)7hZ7fhPsfTB8oFpetGDu6J59c(8yKYTRXw2jLJJzfyhqGcQLZse0zu3r6sa(fNp3eUbm3QAs)7hZ7fhPsfTB8oFpetGDab6jGACBpedQPZOUJ0LabkOwolrqNrDhPlb4xCosLkA34D(EiwnP)LoJ6osxbFEms521yl7KYXXSIMpJCjqGcQLZse0zu3r6sa(fNFZHjXnEhj3BhvdjQj9V0zu3r6k4ZJrk3UgBzNuooMv08zKlPeDg1DKUIJuPI2nENVhIjA(mYLabkOwolrqNrDhPlb4xC4ZJrk3UgBzNuooMTM0)sNrDhPR4ivQODJ357HyIMJl(LE2cfVM43CysCJ3rY92r1qcbVXxX3sn2YclpzNnUcKVIEl1yBsDhJuUfx2N00K)fGAHafulNLiOZOUJ0La8lo85XiLBxJTStkhhZwt6FLLoJ6osxXrQur7gVZ3dXenhx8lw0IUInHLNSZg3n5hLxRmLSqXRj(nhMe34DKCVDunKqWB8v8TuJTS8V1xQX2K6ogPClFzQwiqb1Yzjc6mQ7iDja)IdnukxqTCwNkjwnBCYV0rDDs4OTAs)RfkEnbDuxNeoAtWB8v8TKSY(X8EbDuxNeoAtqSGcO8VauBPl)X8Erh1nDszbXckGVfitXIw0vSjS8KD24Uj)4TIELbcuqTCwIGoJ6osxcWV447HysXVpjopwJFnP)v2pM3losLkA34D(EiMO5ZixYJ3k6Tyrz)yEV4ivQODJ357HyIMpJCjpkdL(yEVaBLmk8DeR5TYKiA(mYL84TIEl9X8Eb2kzu47iwZBLjrGDiJmL(yEV4ivQODJ357HycSdiqb1Yzjc6mQ7iDja)IJVhIjf)(K48yn(1K(xl6k2ewEYoBC3KFurVflkRfDfBclpzNnUBYpOZOUJ0vCKkv0UX789qmrZNrUKsFmVxGTsgf(oI18wzseyhYabcc0ta1Lz(vPXDy5SqDpwy5SqGcQLZseZxLg3HLZ(2850ewXeItAUg31K(xlu8AIQWKWDUvoIn9PG34R4leOGA5SeX8vPXDy5Sa)IZ8vPXDyCnw0vS5s)RSx(J59IoQB6KYcIfuaFuqXIx(J59IoQB6KYIMpJCjpaOwzk9SfkEnHVhIrO4BsybVXxX3sp)X8ErNNSa7Oe5GvkNfDfBeHKrQk3k3xfet(36HafulNLiMVknUdlNf4xCMVknUdJRj9VpBHIxt47Hyek(MewWB8v8T0ZFmVx05jlWokroyLYzrxXgrizKQYTY9vbXK)TEiqb1YzjI5RsJ7WYzb(fhFpeJqX3KW1K(xz)yEVaWuPYTYDguj5YIMdQvSOSFmVxayQu5w5odQKCzb2rjzpAgxUk6vaGW3dXCeRta5IfpAgxUk6vaGqYivLBL7RcIvS4rZ4YvrVcaevQGMHYfxCflLLrgzkroyLYzrxXgr47Hyek(Mew(3YHafulNLiMVknUdlNf4xCMVknUdJRXIUInx6FL9YFmVx0rDtNuwqSGc4Jckw8YFmVx0rDtNuw08zKl5ba1ktPpM3lamvQCRCNbvsUSO5GAflk7hZ7faMkvUvUZGkjxwGDus2JMXLRIEfai89qmhX6eqUyXJMXLRIEfaiKmsv5w5(QGyflE0mUCv0RaarLkOzOCXfxXszzKbcuqTCwIy(Q04oSCwGFXz(Q04omUM0)(X8EbGPsLBL7mOsYLfnhuRyrz)yEVaWuPYTYDguj5YcSJsYE0mUCv0RaaHVhI5iwNaYflE0mUCv0RaaHKrQk3k3xfeRyXJMXLRIEfaiQubndLlU4kwklJmqGcQLZseZxLg3HLZc8lovQGMHYfxCflLRj9VY(8hZ7fDEYcSJIfBSnPUJrk3Il7tAApaO2IfBSLfwEYoBCLlFf9ktjYbRuol6k2iIkvqZq5IlUILYY)woeOGA5SeX8vPXDy5Sa)IJKrQk3k3xfeRM0)(X8ErNNSa7Oe5GvkNfDfBeHKrQk3k3xfet(3YHafulNLiMVknUdlNf4xC89qmhX6eqUgl6k2CP)v2l)X8Erh1nDszbXckGpkOyXl)X8Erh1nDszrZNrUKhauRmLE(J59Iopzb2rXIn2Mu3XiLBXL9jnThauBXIn2YclpzNnUYLVIEl9SfkEnHVhIrO4BsybVXxXxiqb1YzjI5RsJ7WYzb(fhFpeZrSobKRj9Vp)X8ErNNSa7OyXgBtQ7yKYT4Y(KM2daQTyXgBzHLNSZgx5YxrVqGcQLZseZxLg3HLZc8losgPQCRCFvqSAs)7hZ7fDEYcSdiqb1YzjI5RsJ7WYzb(fN5RsJ7W4ASORyZL(xzV8hZ7fDu30jLfelOa(OGIfV8hZ7fDu30jLfnFg5sEaqTYu6zlu8AcFpeJqX3KWcEJVIVqGcQLZseZxLg3HLZc8loZxLg3HXqGGa9eqnOf7n6lutYTsXpjl6k2G6ESWYzHafulNLiiwS3OVVnFonHvmH4KMRXneOGA5SebXI9g9f4xC89qmhX6eqUM0)sNrDhPRO5ZPjSIjeN0CnUfnFg5sE8w(tRO3swO41evHjH7CRCeB6tbVXxXxiqb1YzjcIf7n6lWV4izKQYTY9vbXQj9VFmVx05jlWoGafulNLiiwS3OVa)IZ8vPXDyCnP)95pM3l89uhVUdmfHfyhLSqXRj89uhVUdmfHf8gFfFHafulNLiiwS3OVa)IJVhI5iwNaY1K(3gBtQ7yKYT4Y(KM2dzbOaGTqXRjASnPUWmEXclNvWB8v89P1ldeOGA5SebXI9g9f4xC89qmcfFtcxt6F)yEVaWuPYTYDguj5YcSJsn2YclpzNnUYk)Bf9cbkOwolrqSyVrFb(fN5RsJ7W4As)BJTj1Dms5wCzFsttEzlVaGTqXRjASnPUWmEXclNvWB8v89P1ldeOGA5SebXI9g9f4xC89qmhX6eqgcuqTCwIGyXEJ(c8losMEDJ3jnxJBiqb1YzjcIf7n6lWV4ennw2zt38AiqYbtrYvEbaGmKHqa]] )

    
end
