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
        damageExpiration = 8,
    
        package = "Frost DK",
    } )


    spec:RegisterPack( "Frost DK", 20180830.2122, [[dW02dbqiijEeKK2KQQ(KIGQrPO4ukIwfiv9kiywOQCliPYUO0VuvmmfvDmufldvPNPQKPPOKRPQuBtrq(MIqmofLY5aPsRdsQAEGuUNk1(GuoOIqAHqIhQiOmrqQOlcsf2iKu6JqsHCsfbyLksVurPQzQiG6MkkvyNqOFQOurdvrOAPkc0tvLPQQYvHKc1xHKI2lWFPyWICyQwmOEmutwfxMyZk8zr1OHOtlSAfbKxdPA2iUTkz3s9BjdxuoUIsLwUsphPPt66OY2vu57Gy8qsbNhvvRxrOmFqY(rzapGFG3XvbGiVZZZSn)S918wE)IxEMfpGNYFMaEzogDpxaV2VeWd1UfvzjOZzp4L58tk)a(bE0IBXc4Hu1mkQ)ZN8qrYbBX11hACXrCnQgV(q)qJl8hysb)bE4OUJm3NSTgbrOF(fYYlpF(XlpgOtXvKMzFh5ivdQDlQAPXfg8G5cIob0ayW74QaqK355z2MF2(AElVFX788cDbpNtrwl49IRjmW7ium4HQSeQDlQYsqNIRizPzFh5iv2uuLLqQAgf1)5tEOi5GT466dnU4iUgvJxFOFOXf(dmPG)apCu3rM7t2wJGi0pt8vMGECOFM4tqd0P4ksZSVJCKQb1UfvT04cZMIQS0eLlNJQS0xZZhlX788mBSeQJLGUO(5NNLM4ZoytztrvwAcdP35cf1ZMIQSeQJLMONjqCu9sALYsAXsqhtqutwslwYX4IRvwAullrKCPp(YplTrNBbpsqvk4h4HlYXGu8vb)aiYd4h4jTdtKdafWdVHkB4Ghm3yyXf5yqk(QwQ6y0zj0yPVzP)SK6BUOwnUeJwMtiSe0yPC8b8CSgvdEyKE0utnmbwakarEb)apPDyICaOaE4nuzdh8MHLG5gdBwqi(AQHzSfvTRC5rtzjODZs54dlb9S0mSepSecSeUkYPG02Xwufc)7f1m4w(TR4h(zPjzjOGILG5gdBwqi(AQHzSfvTRC5rtzjOXslxlwnUeJwMVyPjzP)Sem3yyZccXxtnmJTOQLld8CSgvdEyKE0utnmbwakqbVcMeQSUgvd(bqKhWpWtAhMihakGhEdv2Wbp1jsR2CxrkB05gQw7LvAhMihWZXAun4TYvTuHiuQbs0QSafGiVGFGN0omroauap8gQSHdEOclPorA1o2IQum)ksXkTdtKdl9NLqfwcMBmSBCjwUmw6plrZecXO(Mlk1ISGqIo3atCQYsODZsFbEowJQbVcMeQSUkafG4xGFGN0omroauap8gQSHdEZWsWCJHf9GqIo3C5yKrl2vCSYsqbflndlbZngw0dcj6CZLJrgTy5YyP)S0mSu2kZzYXhlp2Xwu1q1nqxyjOGILYwzoto(y5XISGqIo3atCQYsqbflLTYCMC8XYJnN44Wjg)mN3yHLMKLMKLMKL(Zs0mHqmQV5IsTJTOkfZVIuyj0UzjEbphRr1G3ylQsX8RifGcqCwGFGN0omroauap8gQSHdEWCJHf9GqIo3C5yKrl2vCSYsqbflndlbZngw0dcj6CZLJrgTy5YyP)S0mSu2kZzYXhlp2Xwu1q1nqxyjOGILYwzoto(y5XISGqIo3atCQYsqbflLTYCMC8XYJnN44Wjg)mN3yHLMKLMe8CSgvdEfmjuzDvakaXVb)apPDyICaOaE4nuzdh8MHLqfwcMBmSBCjwUmwckOyPLRdSjRGiR9iJahklbnwIN5zjOGILwUwSACjgTm8YsOXs54dlnjl9NLOzcHyuFZfLAZjooCIXpZ5nwyj0UzjEbphRr1GxoXXHtm(zoVXcqbioHa)apPDyICaOaE4nuzdh8G5gd7gxILlJL(Zs0mHqmQV5IsTiliKOZnWeNQSeA3SeVGNJ1OAWdzbHeDUbM4ufOaeNiGFGN0omroauap8gQSHdEOclbZng2nUelxglbfuS0Y1b2KvqK1EKrGdLLGglXZ8SeuqXslxlwnUeJwgEzj0yPC8b8CSgvdEJTOQHQBGUauaIZg4h4jTdtKdafWdVHkB4Ghm3yy34sSCzGNJ1OAWdzbHeDUbM4ufOaeHUGFGNJ1OAWRGjHkRRc4jTdtKdafGcuWJQEF89a(bqKhWpWZXAun4TYvTuHiuQbs0QSGN0omroauakarEb)apPDyICaOaE4nuzdh8WvrofK2UYvTuHiuQbs0QS2vU8OPSe0UzjEzjONLYXhw6plPorA1M7kszJo3q1AVSs7We5aEowJQbVXwu1q1nqxakaXVa)apPDyICaOaE4nuzdh8G5gd7gxILld8CSgvdEiliKOZnWeNQafG4Sa)apPDyICaOaE4nuzdh8qfwcMBmSJTMysBY4iuXYLXs)zj1jsR2XwtmPnzCeQyL2HjYb8CSgvdEfmjuzDvakaXVb)apPDyICaOaE4nuzdh8wUoWMScIS2JmcCOSe0yPzyjE(MLqGLuNiTAxUoWgxvP5CnQ2kTdtKdlb9S0xS0KGNJ1OAWBSfvnuDd0fGcqCcb(bEs7We5aqb8WBOYgo4bZngw0dcj6CZLJrgTy5YyP)S0Y1IvJlXOLzwSeA3Suo(aEowJQbVXwuLI5xrkafG4eb8d8K2HjYbGc4H3qLnCWB56aBYkiYApYiWHYsOXsZWs8(nlHalPorA1UCDGnUQsZ5AuTvAhMihwc6zPVyPjbphRr1GxbtcvwxfGcqC2a)aphRr1G3ylQAO6gOlGN0omroauakarOl4h45ynQg8qwBBQHbs0QSGN0omroauakarEMh8d8CSgvdE(I9wmATR0k4jTdtKdafGcuWdUOMSQirNd(bqKhWpWtAhMihakGhEdv2WbpyUXWUXLy5YaphRr1GhYccj6CdmXPkqbiYl4h4jTdtKdafWdVHkB4G3Y1IvJlXOLzwSe0yPC8HL(Zslxhytwbrw7rgbouwcTBwI3VbphRr1GxbtcvwxfGcq8lWpWtAhMihakGhEdv2WbVLRdSjRGiR9iJahklbnwI35zP)SeUkYPG02SGq81udZylQAx5YJMYsOXslxlwnUeJwMzXs)zjAMqig13CrP2CIJdNy8ZCEJfwcTBwIxWZXAun4LtCC4eJFMZBSauaIZc8d8K2HjYbGc4H3qLnCWB56aBYkiYApYiWHYsqJL4DEw6plHRICkiTnlieFn1Wm2IQ2vU8OPSeAS0Y1IvJlXOLzwGNJ1OAWBSfvnuDd0fGcq8BWpWtAhMihakGhEdv2WbpyUXWIEqirNBUCmYOflxgl9NLwUoWMScIS2JmcCOSeAS0mSepFZsiWsQtKwTlxhyJRQ0CUgvBL2HjYHLGEw6lwAsw6plrZecXO(Mlk1o2IQum)ksHLq7ML4f8CSgvdEJTOkfZVIuakaXje4h4jTdtKdafWdVHkB4G3Y1b2KvqK1EKrGdLLq7MLMHL(6BwcbwsDI0QD56aBCvLMZ1OAR0omroSe0ZsFXstYs)zjAMqig13CrP2XwuLI5xrkSeA3SeVGNJ1OAWBSfvPy(vKcqbiora)apPDyICaOaE4nuzdh8wUoWMScIS2JmcCOSeA3S0mS0xFZsiWsQtKwTlxhyJRQ0CUgvBL2HjYHLGEw6lwAsWZXAun4vWKqL1vbOaeNnWpWtAhMihakGhEdv2WbpCvKtbPTzbH4RPgMXwu1UYLhnLLqJLwUwSACjgTmZIL(Zslxhytwbrw7rgbouwcAS0SMNL(Zs0mHqmQV5IsT5ehhoX4N58glSeA3SeVGNJ1OAWlN44Wjg)mN3ybOaeHUGFGN0omroauap8gQSHdE4QiNcsBZccXxtnmJTOQDLlpAklHglTCTy14smAzMfl9NLwUoWMScIS2JmcCOSe0yPznp45ynQg8gBrvdv3aDbOaf8YwbxxWUc(bqKhWpWtAhMihakafGiVGFGN0omroauakaXVa)apPDyICaOauaIZc8d8K2HjYbGcqbi(n4h45ynQg8YknQg8K2HjYbGcqbk45La(bqKhWpWtAhMihakGhEdv2Wbp1jsR2CxrkB05gQw7LvAhMihWZXAun4TYvTuHiuQbs0QSafGiVGFGN0omroauap8gQSHdEQtKwTJTOkfZVIuSs7We5aEowJQbVCIJdNy8ZCEJfGcq8lWpWtAhMihakGhEdv2WbpCvKtbPTRCvlvicLAGeTkRDLlpAklbTBwIxwc6zPC8HL(ZsQtKwT5UIu2OZnuT2lR0omroGNJ1OAWBSfvnuDd0fGcqCwGFGN0omroauap8gQSHdEWCJHDJlXYLbEowJQbpKfes05gyItvGcq8BWpWtAhMihakGhEdv2WbpyUXWIEqirNBUCmYOflxg45ynQg8gBrvkMFfPauaItiWpWtAhMihakGhEdv2WbVLRdSjRGiR9iJahklbnwAgwINVzjeyj1jsR2LRdSXvvAoxJQTs7We5Wsqpl9flnj45ynQg8YjooCIXpZ5nwakaXjc4h4jTdtKdafWdVHkB4G3Y1b2KvqK1EKrGdLLGglndlXZ3SecSK6ePv7Y1b24QknNRr1wPDyICyjONL(ILMe8CSgvdEJTOQHQBGUauaIZg4h45ynQg8w5QwQqek1ajAvwWtAhMihakafGi0f8d8CSgvdEJTOkfZVIuapPDyICaOauaI8mp4h4jTdtKdafWdVHkB4G3Y1b2KvqK1EKrGdLLqJLMHL49BwcbwsDI0QD56aBCvLMZ1OAR0omroSe0ZsFXstcEowJQbVcMeQSUkafGip8a(bEowJQbVCIJdNy8ZCEJfWtAhMihakafGip8c(bEowJQbVXwu1q1nqxapPDyICaOauaI88f4h45ynQg8qwBBQHbs0QSGN0omroauakarEMf4h45ynQg88f7Ty0AxPvWtAhMihakafOGhCrnAGrp6CWpaI8a(bEs7We5aqb8WBOYgo4TCDGnzfezzjODZsFnp45ynQg8kysOY6QauaI8c(bEs7We5aqb8WBOYgo4PorA1M7kszJo3q1AVSs7We5aEowJQbVvUQLkeHsnqIwLfOae)c8d8K2HjYbGc4H3qLnCWdMBmSBCjwUmWZXAun4HSGqIo3atCQcuaIZc8d8K2HjYbGc4H3qLnCWB5AXQXLy0Y8nlbnwkhFyjOGILwUoWMScISSe0UzPz9n45ynQg8kysOY6QauaIFd(bEs7We5aqb8WBOYgo4bZngw0dcj6CZLJrgTy5YyP)SentieJ6BUOu7ylQsX8RifwcTBwIxWZXAun4n2IQum)ksbOaeNqGFGN0omroauap8gQSHdElxhytwbrw7rgbouwcTBw6R5zP)S0Y1IvJlXOL5lwcnwkhFaphRr1GhYABtnmqIwLfOaeNiGFGNJ1OAWBLRAPcrOudKOvzbpPDyICaOauaIZg4h4jTdtKdafWdVHkB4GhntieJ6BUOu7ylQsX8RifwcTBwIxWZXAun4n2IQum)ksbOaeHUGFGN0omroauap8gQSHdElxhytwbrw7rgbouwcnwI3VzjOGILwUwyj0yPVaphRr1GxbtcvwxfGcqKN5b)apPDyICaOaE4nuzdh8wUoWMScIS2JmcCOSeASeVZdEowJQbpFXElgT2vAfOaf8oYW5ik4harEa)aphRr1GNZPLXv1XOdEs7We5aqbOae5f8d8K2HjYbGc4H3qLnCWdvyPtP2Xwu1mK5K1Qbg9OZzP)S0mSeQWsQtKwTWR4kstnm0OpRNxu3kTdtKdlbfuSeUkYPG0w4vCfPPggA0N1ZlQBx5YJMYsOXs88nlnj45ynQg8qwqirNBGjovbkaXVa)apPDyICaOaE4nuzdh8G5gdBG53OoPAQDLlpAklbTBwkhFyP)Sem3yydm)g1jvtTCzS0FwIMjeIr9nxuQnN44Wjg)mN3yHLq7ML4LL(ZsZWsOclPorA1cVIRin1WqJ(SEErDR0omroSeuqXs4QiNcsBHxXvKMAyOrFwpVOUDLlpAklHglXZ3S0KGNJ1OAWlN44Wjg)mN3ybOaeNf4h4jTdtKdafWdVHkB4Ghm3yydm)g1jvtTRC5rtzjODZs54dl9NLG5gdBG53OoPAQLlJL(ZsZWsOclPorA1cVIRin1WqJ(SEErDR0omroSeuqXs4QiNcsBHxXvKMAyOrFwpVOUDLlpAklHglXZ3S0KGNJ1OAWBSfvnuDd0fGcq8BWpWtAhMihakGNJ1OAWd7eIXXAuTHeuf8ibvnTFjGhUkYPG0uGcqCcb(bEs7We5aqb8WBOYgo4PorA1cVIRin1WqJ(SEErDR0omroS0Fwcxf5uqAl8kUI0uddn6Z65f1TRC5rtzjOXsFdEowJQbVLRnowJQnKGQGhjOQP9lb8GlQjRks05afG4eb8d8K2HjYbGc4H3qLnCW7uQfEfxrAQHHg9z98I6wnWOhDo45ynQg8wU24ynQ2qcQcEKGQM2VeWdUOgnWOhDoqbioBGFGN0omroauap8gQSHdEWCJHnlieFn1Wm2IQwUmw6plPorA1wWKqL11OAR0omroGNJ1OAWB5AJJ1OAdjOk4rcQAA)saVcMeQSUgvduaIqxWpWtAhMihakGhEdv2WbphRXCIrA5keklH2nlXl45ynQg8wU24ynQ2qcQcEKGQM2VeWZlbOae5zEWpWtAhMihakGNJ1OAWd7eIXXAuTHeuf8ibvnTFjGhv9(47bOaf8WvrofKMc(bqKhWpWtAhMihakGhEdv2WbpCvKtbPTzbH4RPgMXwu1UIF4NL(ZsZWsOclPorA1cVIRin1WqJ(SEErDR0omroSeuqXsWCJHvUYkiYAwUwmqepRAlxglnj45ynQg84OIju5IcuaI8c(bEs7We5aqb8A)saV1NyhUgDQboYnRCmWCQwn45ynQg84OIju5cOae)c8d8K2HjYbGc41(LaExYkORiDQz4Do45ynQg84OIju5cOaeNf4h4jTdtKdafWdVHkB4Ghm3yyZccXxtnmJTOQLlJL(ZsWCJHvUYkiYAwUwmqepRAlxg45ynQg8YknQgOae)g8d8K2HjYbGc4H3qLnCWdMBmSzbH4RPgMXwu1YLXs)zjyUXWkxzfeznlxlgiINvTLld8CSgvdEWKQoMb3YpqbioHa)apPDyICaOaE4nuzdh8G5gdBwqi(AQHzSfvTCzGNJ1OAWdwwQSOhDoqbiora)apPDyICaOaE4nuzdh8G5gdRCLvqK1SCTyGiEw1wUmwckOyjCvKtbPTYvwbrwZY1IbI4zvBx5YJMcEowJQbVSGq81udZylQcuaIZg4h4jTdtKdafWdVHkB4G3mSem3yyLRScISMLRfdeXZQ2YLXsqbflHRICkiTvUYkiYAwUwmqepRA7kxE0uwAsw6plHRICkiTnlieFn1Wm2IQ2vU8OPGNJ1OAWdEfxrAQHHg9z98I6afGi0f8d8K2HjYbGc4H3qLnCWdxf5uqABwqi(AQHzSfvTR4h(zP)SeQWsQtKwTWR4kstnm0OpRNxu3kTdtKdl9NLwUwSACjgTmFZsOXs54dl9NLwUoWMScIS2JmcCOSeA3SepZdEowJQbp5kRGiRz5AXar8SQbkarEMh8d8K2HjYbGc4H3qLnCWdxf5uqABwqi(AQHzSfvTR4h(zP)SK6ePvl8kUI0uddn6Z65f1Ts7We5Ws)zPzyPzyjCvKtbPTWR4kstnm0OpRNxu3UYLhnLLqJLwbJ03CXOXLWstYsqbflndlHRICkiTfEfxrAQHHg9z98I62v8d)S0FwA5AHLq7ML(IL(ZslxhytwbrwwcnwAcnplnjlnj45ynQg8KRScISMLRfdeXZQgOae5HhWpWtAhMihakGhEdv2WbVzyjz2LlYYKJfxKJbP4RYsqbflPorA1IlYXGu8vTs7We5WstYs)zPzyPzyPzyjyUXWIlYXGu8vnHkxwQ6y0zj0UzjEMNLGckwcMBmS4ICmifFvJ6ePvlvDm6SeA3SepZZstYs)zPJaZng21Ny1gyXsvhJolDZsFZstYsqbflP(MlQvJlXOL5eclbTBwkhFyPjbphRr1Gh2jeJJ1OAdjOk4rcQAA)sapCrogKIVkqbiYdVGFGN0omroauap8gQSHdEWCJHnlieFn1Wm2IQ2vU8OPSe0UzPC8HL(ZsWCJHnlieFn1Wm2IQwUmWZXAun4n2IQq4FVOMb3YpqbkqbV5KLgvdqK355z2MFIW7Sz5D(V)g8G4BhDof8qnNOtqeNaqe1iuplXs)qkSuCLvRYsJAzPj8JmCoIoHZsRm7YfRCyjADjSKZP1LRYHLWi9oxOw20jWrlSepOEwc14MYLLvRkhwYXAunlnH7CAzCvDm6t4w2u20jGRSAv5WsqxwYXAunlrcQsTSPGhntWae59BEaVSTgbrapuLLqTBrvwc6uCfjln77ihPYMIQSesvZOO(pFYdfjhSfxxFOXfhX1OA86d9dnUWFGjf8h4HJ6oYCFY2AeeH(zIVYe0Jd9ZeFcAGofxrAM9DKJunO2TOQLgxy2uuLLMOC5CuLL(AE(yjENNNzJLqDSe0f1p)8S0eF2bBkBkQYstyi9oxOOE2uuLLqDS0e9mbIJQxsRuwslwc6ycIAYsAXsogxCTYsJAzjIKl9Xx(zPn6ClBkBkQYsqhOgemNkhwcwg1kSeUUGDLLGL8OPwwAIIXsMszPUAuhsFVgCewYXAunLLQMWVLn1XAun1MTcUUGD9EqCk6SPowJQP2SvW1fSRiC)zu1Hn1XAun1MTcUUGDfH7pox(L0QRr1SPOkl9ApJISuwA94WsWCJHCyjQ6kLLGLrTclHRlyxzjyjpAkl59HLYwb1LvQgDolfuw6uTyztDSgvtTzRGRlyxr4(dT9mkYsnu1vkBQJ1OAQnBfCDb7kc3FYknQMnLnfvzjOdudcMtLdljZjl)SKgxclPifwYXATSuqzjFopiomrSSPowJQP3oNwgxvhJoBkQYst0Smc)SeQDlQYsOwzozzjVpS0LhT6rZstay(zPFoPAkBQJ1OAkc3FqwqirNBGjov5lg3OYPu7ylQAgYCYA1aJE05)NbvuNiTAHxXvKMAyOrFwpVOUvAhMihOGcxf5uqAl8kUI0uddn6Z65f1TRC5rtrJNVNKn1XAunfH7p5ehhoX4N58gl8fJByUXWgy(nQtQMAx5YJMcT7C85pm3yydm)g1jvtTCz)PzcHyuFZfLAZjooCIXpZ5nwq7M3)ZGkQtKwTWR4kstnm0OpRNxu3kTdtKduqHRICkiTfEfxrAQHHg9z98I62vU8OPOXZ3tYM6ynQMIW9NXwu1q1nqx4lg3WCJHnW8BuNun1UYLhnfA354ZFyUXWgy(nQtQMA5Y(pdQOorA1cVIRin1WqJ(SEErDR0omroqbfUkYPG0w4vCfPPggA0N1ZlQBx5YJMIgpFpjBQJ1OAkc3FWoHyCSgvBibv5R9l5gxf5uqAkBQJ1OAkc3FwU24ynQ2qcQYx7xYnCrnzvrIoNVyCRorA1cVIRin1WqJ(SEErDR0omro)XvrofK2cVIRin1WqJ(SEErD7kxE0uO9nBQJ1OAkc3FwU24ynQ2qcQYx7xYnCrnAGrp6C(IX9Pul8kUI0uddn6Z65f1TAGrp6C2uhRr1ueU)SCTXXAuTHeuLV2VK7cMeQSUgvZxmUH5gdBwqi(AQHzSfvTCz)vNiTAlysOY6AuTvAhMih2uhRr1ueU)SCTXXAuTHeuLV2VKBVe(IXTJ1yoXiTCfcfTBEztDSgvtr4(d2jeJJ1OAdjOkFTFj3u17JVh2u2uhRr1uRxY9kx1sfIqPgirRYYxmUvNiTAZDfPSrNBOATxwPDyICytDSgvtTEjiC)jN44Wjg)mN3yHVyCRorA1o2IQum)ksXkTdtKdBQJ1OAQ1lbH7pJTOQHQBGUWxmUXvrofK2UYvTuHiuQbs0QS2vU8OPq7MxOphF(RorA1M7kszJo3q1AVSs7We5WM6ynQMA9sq4(dYccj6CdmXPkFX4gMBmSBCjwUm2uhRr1uRxcc3FgBrvkMFfPWxmUH5gdl6bHeDU5YXiJwSCzSPowJQPwVeeU)KtCC4eJFMZBSWxmUxUoWMScIS2JmcCOqBgE(gb1jsR2LRdSXvvAoxJQTs7We5a9FnjBQJ1OAQ1lbH7pJTOQHQBGUWxmUxUoWMScIS2JmcCOqBgE(gb1jsR2LRdSXvvAoxJQTs7We5a9FnjBQJ1OAQ1lbH7pRCvlvicLAGeTklBQJ1OAQ1lbH7pJTOkfZVIuytDSgvtTEjiC)PGjHkRRcFX4E56aBYkiYApYiWHI2m8(ncQtKwTlxhyJRQ0CUgvBL2HjYb6)As2uhRr1uRxcc3FYjooCIXpZ5nwytDSgvtTEjiC)zSfvnuDd0f2uhRr1uRxcc3FqwBBQHbs0QSSPowJQPwVeeU)4l2BXO1UsRSPSPOklHYkUIKLQbl9I(SEErDwkRks05S0wQRr1SeQNLOQVkLL4DEklblJAfwAIheIVSunyju7wuLLqGLqPESKVcl5Z5bXHjcBQJ1OAQfUOMSQirNFJSGqIo3atCQYxmUH5gd7gxILlJn1XAun1cxutwvKOZr4(tbtcvwxf(IX9Y1IvJlXOLzwqlhF(VCDGnzfezThze4qr7M3VztDSgvtTWf1Kvfj6CeU)KtCC4eJFMZBSWxmUxUoWMScIS2JmcCOqJ35)JRICkiTnlieFn1Wm2IQ2vU8OPOTCTy14smAzM1FAMqig13CrP2CIJdNy8ZCEJf0U5Ln1XAun1cxutwvKOZr4(ZylQAO6gOl8fJ7LRdSjRGiR9iJahk04D()4QiNcsBZccXxtnmJTOQDLlpAkAlxlwnUeJwMzXM6ynQMAHlQjRks05iC)zSfvPy(vKcFX4gMBmSOhes05MlhJmAXYL9F56aBYkiYApYiWHI2m88ncQtKwTlxhyJRQ0CUgvBL2HjYb6)AY)0mHqmQV5IsTJTOkfZVIuq7Mx2uhRr1ulCrnzvrIohH7pJTOkfZVIu4lg3lxhytwbrw7rgbou0UN5RVrqDI0QD56aBCvLMZ1OAR0omroq)xt(NMjeIr9nxuQDSfvPy(vKcA38YM6ynQMAHlQjRks05iC)PGjHkRRcFX4E56aBYkiYApYiWHI29mF9ncQtKwTlxhyJRQ0CUgvBL2HjYb6)As2uhRr1ulCrnzvrIohH7p5ehhoX4N58gl8fJBCvKtbPTzbH4RPgMXwu1UYLhnfTLRfRgxIrlZS(VCDGnzfezThze4qH2SM)pntieJ6BUOuBoXXHtm(zoVXcA38YM6ynQMAHlQjRks05iC)zSfvnuDd0f(IXnUkYPG02SGq81udZylQAx5YJMI2Y1IvJlXOLzw)xUoWMScIS2JmcCOqBwZZMYM6ynQMAHlQrdm6rNFxWKqL1vHVyCVCDGnzfezH29xZZM6ynQMAHlQrdm6rNJW9NvUQLkeHsnqIwLLVyCRorA1M7kszJo3q1AVSs7We5WM6ynQMAHlQrdm6rNJW9hKfes05gyItv(IXnm3yy34sSCzSPowJQPw4IA0aJE05iC)PGjHkRRcFX4E5AXQXLy0Y8n0YXhOGA56aBYkiYcT7z9nBQJ1OAQfUOgnWOhDoc3FgBrvkMFfPWxmUH5gdl6bHeDU5YXiJwSCz)PzcHyuFZfLAhBrvkMFfPG2nVSPowJQPw4IA0aJE05iC)bzTTPggirRYYxmUxUoWMScIS2JmcCOOD)18)xUwSACjgTmFHwo(WM6ynQMAHlQrdm6rNJW9NvUQLkeHsnqIwLLn1XAun1cxuJgy0JohH7pJTOkfZVIu4lg30mHqmQV5IsTJTOkfZVIuq7Mx2uhRr1ulCrnAGrp6CeU)uWKqL1vHVyCVCDGnzfezThze4qrJ3VHcQLRf0(In1XAun1cxuJgy0JohH7p(I9wmATR0kFX4E56aBYkiYApYiWHIgVZZMYMIQS0ewroSesXxLLWvFcnQMYM6ynQMAXf5yqk(Q3yKE0utnmbw4lg3WCJHfxKJbP4RAPQJrhTV)R(MlQvJlXOL5ec0YXh2uhRr1ulUihdsXxfH7pyKE0utnmbw4lg3ZaZng2SGq81udZylQAx5YJMcT7C8b6NHheWvrofK2o2IQq4FVOMb3YVDf)W)Kqbfm3yyZccXxtnmJTOQDLlpAk0wUwSACjgTmFn5FyUXWMfeIVMAygBrvlxgBkBQJ1OAQfxf5uqA6nhvmHkxu(IXnUkYPG02SGq81udZylQAxXp8)FgurDI0QfEfxrAQHHg9z98I6wPDyICGckyUXWkxzfeznlxlgiINvTLlBs2uhRr1ulUkYPG0ueU)WrftOYfFTFj3RpXoCn6udCKBw5yG5uTA2uhRr1ulUkYPG0ueU)WrftOYfFTFj3xYkORiDQz4DoBQJ1OAQfxf5uqAkc3FYknQMVyCdZng2SGq81udZylQA5Y(dZngw5kRGiRz5AXar8SQTCzSPowJQPwCvKtbPPiC)bMu1Xm4w(5lg3WCJHnlieFn1Wm2IQwUS)WCJHvUYkiYAwUwmqepRAlxgBQJ1OAQfxf5uqAkc3FGLLkl6rNZxmUH5gdBwqi(AQHzSfvTCzSPOklHA3IQSeUkYPG0u2uhRr1ulUkYPG0ueU)KfeIVMAygBrv(IXnm3yyLRScISMLRfdeXZQ2YLbfu4QiNcsBLRScISMLRfdeXZQ2UYLhnLnfvzPjkgxCTYsJAzjOJjiQjlrKCPp(YplTrNZsXGLcLLOAqiSKNLrcHAztDSgvtT4QiNcstr4(d8kUI0uddn6Z65f15lg3ZaZngw5kRGiRz5AXar8SQTCzqbfUkYPG0w5kRGiRz5AXar8SQTRC5rtN8pUkYPG02SGq81udZylQAx5YJMYM6ynQMAXvrofKMIW9h5kRGiRz5AXar8SQ5lg34QiNcsBZccXxtnmJTOQDf)W)FurDI0QfEfxrAQHHg9z98I6wPDyIC(VCTy14smAz(gTC85)Y1b2KvqK1EKrGdfTBEMNnfvzPjGblbryjS3SehvyjOJjiQjl59HLq6ZjSuOS0OwwQfudklHYkUIKpwkVyjhP4hllXstGLCPp(YplTrNZsifsg1YM6ynQMAXvrofKMIW9h5kRGiRz5AXar8SQ5lg34QiNcsBZccXxtnmJTOQDf)W)F1jsRw4vCfPPggA0N1ZlQBL2HjY5)mZGRICkiTfEfxrAQHHg9z98I62vU8OPOTcgPV5IrJlzsOGAgCvKtbPTWR4kstnm0OpRNxu3UIF4))Y1cA3F9F56aBYkiYI2eA(jNKn1XAun1IRICkinfH7pyNqmowJQnKGQ81(LCJlYXGu8v5lg3ZiZUCrwMCS4ICmifFvOGsDI0QfxKJbP4RAL2HjYzY)ZmZmWCJHfxKJbP4RAcvUSu1XOJ2npZdfuWCJHfxKJbP4RAuNiTAPQJrhTBEMFY)hbMBmSRpXQnWILQog97VNekOuFZf1QXLy0YCcbA354ZKSPowJQPwCvKtbPPiC)zSfvHW)ErndULF(IXnm3yyZccXxtnmJTOQDLlpAk0UZXN)WCJHnlieFn1Wm2IQwUm2u2uuLLMDctcvwxJQzPTuxJQztDSgvtTfmjuzDnQ(ELRAPcrOudKOvz5lg3QtKwT5UIu2OZnuT2lR0omroSPowJQP2cMeQSUgvJW9NcMeQSUk8fJBurDI0QDSfvPy(vKIvAhMiN)Ocm3yy34sSCz)PzcHyuFZfLArwqirNBGjovr7(l2uhRr1uBbtcvwxJQr4(ZylQsX8Rif(IX9mWCJHf9GqIo3C5yKrl2vCScfuZaZngw0dcj6CZLJrgTy5Y(pt2kZzYXhlp2Xwu1q1nqxGcQSvMZKJpwESiliKOZnWeNQqbv2kZzYXhlp2CIJdNy8ZCEJLjNCY)0mHqmQV5IsTJTOkfZVIuq7Mx2uhRr1uBbtcvwxJQr4(tbtcvwxf(IXnm3yyrpiKOZnxogz0IDfhRqb1mWCJHf9GqIo3C5yKrlwUS)ZKTYCMC8XYJDSfvnuDd0fOGkBL5m54JLhlYccj6CdmXPkuqLTYCMC8XYJnN44Wjg)mN3yzYjztDSgvtTfmjuzDnQgH7p5ehhoX4N58gl8fJ7zqfyUXWUXLy5YGcQLRdSjRGiR9iJahk04zEOGA5AXQXLy0YWlA54ZK)PzcHyuFZfLAZjooCIXpZ5nwq7Mx2uhRr1uBbtcvwxJQr4(dYccj6CdmXPkFX4gMBmSBCjwUS)0mHqmQV5IsTiliKOZnWeNQODZlBQJ1OAQTGjHkRRr1iC)zSfvnuDd0f(IXnQaZng2nUelxguqTCDGnzfezThze4qHgpZdfulxlwnUeJwgErlhFytDSgvtTfmjuzDnQgH7piliKOZnWeNQ8fJByUXWUXLy5YytDSgvtTfmjuzDnQgH7pfmjuzDvytztrvw6PEF89Ws0OZjcQt9nxuwAl11OA2uhRr1ulv9(475ELRAPcrOudKOvzztDSgvtTu17JVheU)m2IQgQUb6cFX4gxf5uqA7kx1sfIqPgirRYAx5YJMcTBEH(C85V6ePvBURiLn6CdvR9YkTdtKdBQJ1OAQLQEF89GW9hKfes05gyItv(IXnm3yy34sSCzSPowJQPwQ69X3dc3FkysOY6QWxmUrfyUXWo2AIjTjJJqflx2F1jsR2XwtmPnzCeQyL2HjYHn1XAun1svVp(Eq4(ZylQAO6gOl8fJ7LRdSjRGiR9iJahk0MHNVrqDI0QD56aBCvLMZ1OAR0omroq)xtYM6ynQMAPQ3hFpiC)zSfvPy(vKcFX4gMBmSOhes05MlhJmAXYL9F5AXQXLy0Yml0UZXh2uhRr1ulv9(47bH7pfmjuzDv4lg3lxhytwbrw7rgbou0MH3VrqDI0QD56aBCvLMZ1OAR0omroq)xtYM6ynQMAPQ3hFpiC)zSfvnuDd0f2uhRr1ulv9(47bH7piRTn1WajAvw2uhRr1ulv9(47bH7p(I9wmATR0kqbkaa]] )


end
