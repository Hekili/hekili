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
            charges = function () return 1 + ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1 or 0 ) end,
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


    spec:RegisterPack( "Frost DK", 20180728.2055, [[d0e8cbqivv4rQQO2eOQpPOQYOuKCkfrRckv9kvvnluf3cvQk7sKFHkmmOuogQsldvvpdvkttrORPOY2qLk(guQ04uufNtrGwNQkI3Hkvknpvv6EQu7dv0bvuvSqOKhQOQ0evuL0fvuv1grLQ8rfvjAKOsLQtQiOwPIYlvuLQzcLkStqLFIkvYqHsfTufb5PQYuvvCvfvj8vvvKolQuPyVa)LudMKdt1Ib5XinzvCzInRWNfvJgkoTWRrLmBe3wLSBP(TKHlkhxrvklxPNJY0PCDOA7ks9Dqz8Osv15rvz9kcy(QkTFid4f8b8oUja44hB8opyd7Y)8K4hBZXDMBEapJVmb8YCkxEUaETFjGh3BlMHuZRZ7GxMZhP8d4d4Xk8LkGhgZYy)eo4ipmm4qjADXblUWjUfvtxFyCWIlkhqKcIdOHZ9DKP5iBRrqeghFcz5Nxo(WpV65vXnm659oYXyAU3wmlXIlk4bHheBc3aiW74MaGJFSX78GnSl)ZtIFSnh34g)GNJByQf8EX18f8ocJcEFWemKkyiLJuzoLlpxqQAGuo1IQrksWmgsnQfP4UlCfKiHMHMXDtHJu(kiv2wqoeHpKkVIohPScPGeKIHVzBWKdsbXhszyeKQYKwwUBrQjmsbZzjKcP4UGiHXdsXDbrcJhKI7cIegpif3fejmEqQ5)e6NIudrimKQohKcc3qQGHu0QzbZK2qkyHHbPEX18fPMcggPrQjuCji1Pewp)mKkBl6KjKcP(GrAEqk(kCK6Y5dPW4tliLvifmpmKIjtlRtqkMqR(WqQrTi1I3cdPGKrTcsXxHJuzvgsn)Nq)0eAgA2mCcFifVtWFcsHuCVG7xoiLJuZ3ICqkU7IVgsjTT8Hugg3qkyodP6Yqktyw05iv2wzYs4lHui1hmbdPyykCYbPOootqQ5lgpAgsvdKActfKYkKYZYeFrk3qkdJGusFqQAGuosHDgeIVivnqkU3wmdPGf9PGHuXaP4RWNFRGu4SOZrkdJGuejx6JV8Hu1IuMtK2sOzOzZWj8Hu8JTFcsHuZlYoUjhKA(GDIDGuJTUqQxCnF5bPU8JGuggbPCOAAbPOy8oxyiL3hKYWinsDvNyeYbPMpyNyhifPYdkszfs5uAH3gsnQfPM)tOFksHXNo6CKYGviffJV5cdPGfggKYWiifrYL(4lFi1gDEc8ibZyGpGhTihngXxd8bahVGpGN0oeroaSap6gMSHdEtHuq4JrIwKJgJ4RPdtUsmZPCHuCIuZHuF)Iuq4JrIwKJgJ4RPnNiTLyMt5cP4ePMdPMePGhPmFZflzXLOTsFcbP(fPYPhWZPwun4rX4rZ01qhubya44h8b8K2HiYbGf4r3WKnCWBkKccFmszbH4RUg6XwmlTYLhndP(9gPYPhKc7rQPqkErQ)ifTkYPG1PXwmdgF7ftpWx(sR4h(qQjrQVFrki8XiLfeIV6AOhBXS0kxE0mK6xKAXBjzXLOTsZnKAsKcEKccFmszbH4RUg6XwmlHNbEo1IQbpkgpAMUg6GkadyGxbrctw3IQbFaWXl4d4jTdrKdalWJUHjB4GN5ePTuUByKn6CnZQ9kjTdrKd45ulQg8w5QwMqegtdlAtwGbGJFWhWtAhIihawGhDdt2WbVFGuMtK2sJTygJYNHrss7qe5GuWJu)aPGWhJ0gxscpdPGhPyzcHOnFZfJLWuWirNRHioZqkoVrkUbEo1IQbVcIeMSUjadah3aFapPDiICaybE0nmzdh8McPGWhJexbHeDU(YPyIwsR4udP((fPMcPGWhJexbHeDU(YPyIws4zif8i1uiv2ktRZPNeVPXwmtZSn4sqQVFrQSvMwNtpjEtykyKOZ1qeNzi13Viv2ktRZPNeVPCItdNO9Z0EtfKAsKAsKAsKcEKAkKAXBjzXLOTsprKItKkNEqQVFrkwMqiAZ3CXyPXwmJr5ZWiifN3if)i1KGNtTOAWBSfZyu(mmcWaWnrWhWtAhIihawGhDdt2Wbpi8XiXvqirNRVCkMOL0ko1qQVFrQPqki8XiXvqirNRVCkMOLeEgsbpsnfsLTY06C6jXBASfZ0mBdUeK67xKkBLP150tI3eMcgj6CneXzgs99lsLTY06C6jXBkN40WjA)mT3ubPMePMe8CQfvdEfejmzDtagaU5aFapPDiICaybE0nmzdh8McP(bsbHpgPnUKeEgs99lsT4Dq1zfmzthze0WqQFrkEXgs99lsT4TKS4s0wP5hP4ePYPhKAsKcEKILjeI28nxmwkN40WjA)mT3ubP48gP4h8CQfvdE5eNgor7NP9Mkadah3b8b8K2HiYbGf4r3WKnCWdcFmsBCjj8mKcEKILjeI28nxmwctbJeDUgI4mdP48gP4h8CQfvdEykyKOZ1qeNzadah2f8b8K2HiYbGf4r3WKnCW7hife(yK24ss4zi13Vi1I3bvNvWKnDKrqddP(fP4fBi13Vi1I3sYIlrBLMFKItKkNEapNAr1G3ylMPz2gCjada38a(aEs7qe5aWc8OByYgo4bHpgPnUKeEg45ulQg8WuWirNRHioZagaUji4d45ulQg8kisyY6MaEs7qe5aWcyad8GkM2ckxrNd(aGJxWhWtAhIihawGhDdt2WbVfVdQoRGjls97nsXnSbEo1IQbVcIeMSUjadah)GpGN0oeroaSap6gMSHdEMtK2s5UHr2OZ1mR2RK0oeroGNtTOAWBLRAzcrymnSOnzbgaoUb(aEs7qe5aWc8OByYgo4bHpgPnUKeEg45ulQg8WuWirNRHioZagaUjc(aEs7qe5aWc8OByYgo4T4TKS4s0wPNdP(fPYPhK67xKAX7GQZkyYIu)EJutCoWZPwun4vqKWK1nbya4Md8b8K2HiYbGf4r3WKnCWdcFmsCfes056lNIjAjHNbEo1IQbVXwmJr5ZWiadah3b8b8K2HiYbGf4r3WKnCWBX7GQZkyYMoYiOHHuCEJuCdBif8i1I3sYIlrBLMBifNivo9aEo1IQbpm126AOHfTjlWaWHDbFapNAr1G3kx1YeIWyAyrBYcEs7qe5aWcya4MhWhWtAhIihawGhDdt2WbpwMqiAZ3CXyPXwmJr5ZWiifN3if)GNtTOAWBSfZyu(mmcWaWnbbFapPDiICaybE0nmzdh8w8oO6ScMSPJmcAyifNif)ZHuF)IulElifNif3apNAr1Gxbrctw3eGbGJxSb(aEs7qe5aWc8OByYgo4T4Dq1zfmzthze0Wqkork(Xg45ulQg88L6TOTAxPnGbmWdQy6SQirNd(aGJxWhWtAhIihawGhDdt2Wbpi8XiTXLKWZapNAr1GhMcgj6CneXzgWaWXp4d4jTdrKdalWJUHjB4G3I3sYIlrBLEIi1Vivo9GuWJulEhuDwbt20rgbnmKIZBKI)5apNAr1Gxbrctw3eGbGJBGpGN0oeroaSap6gMSHdElEhuDwbt20rgbnmK6xKIFSHuWJu0QiNcwNYccXxDn0JTywALlpAgsXjsT4TKS4s0wPNi45ulQg8YjonCI2pt7nvagaUjc(aEs7qe5aWc8OByYgo4T4Dq1zfmzthze0WqQFrk(XgsbpsrRICkyDklieF11qp2IzPvU8OzifNi1I3sYIlrBLEIGNtTOAWBSfZ0mBdUeGbGBoWhWtAhIihawGhDdt2Wbpi8XiXvqirNRVCkMOLeEgsbpsT4Dq1zfmzthze0WqkorQPqkENdP(JuMtK2slEhuTBM04UfvNK2HiYbPWEKIBi1KGNtTOAWBSfZyu(mmcWaWXDaFapPDiICaybE0nmzdh8w8oO6ScMSPJmcAyifN3i1uif)ZHu)rkZjsBPfVdQ2ntAC3IQts7qe5GuypsXnKAsWZPwun4vqKWK1nbya4WUGpGN0oeroaSap6gMSHdE0QiNcwNYccXxDn0JTywALlpAgsXjsT4TKS4s0wPNisbpsT4Dq1zfmzthze0WqQFrQjInKcEKILjeI28nxmwkN40WjA)mT3ubP48gP4h8CQfvdE5eNgor7NP9Mkada38a(aEs7qe5aWc8OByYgo4rRICkyDklieF11qp2IzPvU8OzifNi1I3sYIlrBLEIif8i1I3bvNvWKnDKrqddP(fPMi2apNAr1G3ylMPz2gCjadyGx2k06cYnWhaC8c(aEs7qe5aWcya44h8b8K2HiYbGfWaWXnWhWtAhIihawada3ebFapPDiICaybmaCZb(aEo1IQbVSYIQbpPDiICaybmGbEEjGpa44f8b8K2HiYbGf4r3WKnCWZCI0wk3nmYgDUMz1ELK2HiYb8CQfvdERCvlticJPHfTjlWaWXp4d4jTdrKdalWJUHjB4GN5ePT0ylMXO8zyKK0oeroGNtTOAWlN40WjA)mT3ubya44g4d4jTdrKdalWJUHjB4GhTkYPG1PvUQLjeHX0WI2KnTYLhndP(9gP4hPWEKkNEqk4rkZjsBPC3WiB05AMv7vsAhIihWZPwun4n2IzAMTbxcWaWnrWhWtAhIihawGhDdt2Wbpi8XiTXLKWZapNAr1GhMcgj6CneXzgWaWnh4d4jTdrKdalWJUHjB4Ghe(yK4kiKOZ1xoft0scpd8CQfvdEJTygJYNHragaoUd4d4jTdrKdalWJUHjB4G3I3bvNvWKnDKrqddP(fPMcP4DoK6pszorAlT4Dq1UzsJ7wuDsAhIihKc7rkUHutcEo1IQbVCItdNO9Z0EtfGbGd7c(aEs7qe5aWc8OByYgo4T4Dq1zfmzthze0WqQFrQPqkENdP(JuMtK2slEhuTBM04UfvNK2HiYbPWEKIBi1KGNtTOAWBSfZ0mBdUeGbGBEaFapNAr1G3kx1YeIWyAyrBYcEs7qe5aWcya4MGGpGNtTOAWBSfZyu(mmc4jTdrKdalGbGJxSb(aEs7qe5aWc8OByYgo4T4Dq1zfmzthze0WqkorQPqk(NdP(JuMtK2slEhuTBM04UfvNK2HiYbPWEKIBi1KGNtTOAWRGiHjRBcWaWXlVGpGNtTOAWlN40WjA)mT3ub8K2HiYbGfWaWXl)GpGNtTOAWBSfZ0mBdUeWtAhIihawadahVCd8b8CQfvdEyQT11qdlAtwWtAhIihawadahVte8b8CQfvdE(s9w0wTR0g4jTdrKdalGbmWJzEF89a(aGJxWhWZPwun4TYvTmHimMgw0MSGN0oeroaSagao(bFapPDiICaybE0nmzdh8OvrofSoTYvTmHimMgw0MSPvU8Ozi1V3if)if2Ju50dsbpszorAlL7ggzJoxZSAVss7qe5aEo1IQbVXwmtZSn4sagaoUb(aEs7qe5aWc8OByYgo4bHpgPnUKeEg45ulQg8WuWirNRHioZagaUjc(aEs7qe5aWc8OByYgo49dKccFmsJTMasRZWjmjHNHuWJuMtK2sJTMasRZWjmjjTdrKd45ulQg8kisyY6MamaCZb(aEs7qe5aWc8OByYgo4T4Dq1zfmzthze0WqQFrQPqkENdP(JuMtK2slEhuTBM04UfvNK2HiYbPWEKIBi1KGNtTOAWBSfZ0mBdUeGbGJ7a(aEs7qe5aWc8OByYgo4bHpgjUccj6C9LtXeTKWZqk4rQfVLKfxI2k9erkoVrQC6b8CQfvdEJTygJYNHragaoSl4d4jTdrKdalWJUHjB4G3I3bvNvWKnDKrqddP4ePMcP4FoK6pszorAlT4Dq1UzsJ7wuDsAhIihKc7rkUHutcEo1IQbVcIeMSUjada38a(aEo1IQbVXwmtZSn4sapPDiICaybmaCtqWhWZPwun4HP2wxdnSOnzbpPDiICaybmaC8InWhWZPwun45l1BrB1UsBGN0oeroaSagWaVJmCCIb(aGJxWhWZPwun454wPDZCkxGN0oeroaSagao(bFapNAr1G3v0h9yfzciGN0oeroaSagaoUb(aEs7qe5aWc8OByYgo49dK6uwASfZ0dzAztwq5k6CKcEKAkK6hiL5ePTe0kUHrxdnl6Z65fZts7qe5GuF)Iu0QiNcwNGwXnm6AOzrFwpVyEALlpAgsXjsX7Ci1KGNtTOAWdtbJeDUgI4mdya4Mi4d4jTdrKdalWJUHjB4Ghe(yKckFAZjvZsRC5rZqQFVrQC6bPGhPGWhJuq5tBoPAwcpdPGhPyzcHOnFZfJLYjonCI2pt7nvqkoVrk(rk4rQPqQFGuMtK2sqR4ggDn0SOpRNxmpjTdrKds99lsrRICkyDcAf3WORHMf9z98I5PvU8OzifNifVZHutcEo1IQbVCItdNO9Z0EtfGbGBoWhWtAhIihawGhDdt2Wbpi8Xifu(0MtQMLw5YJMHu)EJu50dsbpsbHpgPGYN2Cs1SeEgsbpsnfs9dKYCI0wcAf3WORHMf9z98I5jPDiICqQVFrkAvKtbRtqR4ggDn0SOpRNxmpTYLhndP4eP4DoKAsWZPwun4n2IzAMTbxcWaWXDaFapPDiICaybE0nmzdh8GWhJKCLvWKvV4TOHjEw1j8mKcEKIwf5uW6uwqi(QRHESfZsRC5rZapNAr1Gh0kUHrxdnl6Z65fZbgaoSl4d4jTdrKdalWZPwun4rDcr7ulQwtcMbEKGz62VeWJwf5uWAgWaWnpGpGN0oeroaSap6gMSHdEMtK2sqR4ggDn0SOpRNxmpjTdrKdsbpsrRICkyDcAf3WORHMf9z98I5PvU8Ozi1Vi1CGNtTOAWBXBTtTOAnjyg4rcMPB)sapOIPZQIeDoWaWnbbFapPDiICaybE0nmzdh8oLLGwXnm6AOzrFwpVyEYckxrNdEo1IQbVfV1o1IQ1KGzGhjyMU9lb8GkM2ckxrNdmaC8InWhWtAhIihawGhDdt2Wbpi8XiLfeIV6AOhBXSeEgsbpszorAlvqKWK1TO6K0oeroGNtTOAWBXBTtTOAnjyg4rcMPB)saVcIeMSUfvdmaC8Yl4d4jTdrKdalWJUHjB4GNtTyArlTCfcdP48gP4h8CQfvdElERDQfvRjbZapsWmD7xc45LamaC8Yp4d4jTdrKdalWZPwun4rDcr7ulQwtcMbEKGz62VeWJzEF89amGbE0QiNcwZaFaWXl4d45ulQg8WzIom5IbEs7qe5aWcya44h8b8K2HiYbGf45ulQg8WuBRRHEANul4r3WKnCWdcFmszbH4RUg6XwmlHNHuWJutHu)aPmNiTLGwXnm6AOzrFwpVyEsAhIihK67xK6hifTkYPG1jOvCdJUgAw0N1ZlMNw5YJMHutcETFjGhMABDn0t7KAbgaoUb(aEs7qe5aWc8OByYgo4bHpgPSGq8vxd9ylMLWZqk4rki8Xijxzfmz1lElAyINvDcpd8CQfvdEzLfvdmaCte8b8K2HiYbGf4r3WKnCWdcFmszbH4RUg6XwmlHNHuWJuq4JrsUYkyYQx8w0WepR6eEg45ulQg8GivD0d8LpGbGBoWhWtAhIihawGhDdt2Wbpi8XiLfeIV6AOhBXSeEg45ulQg8GKLjlxrNdmaCChWhWtAhIihawGhDdt2Wbpi8Xijxzfmz1lElAyINvDcpdP((fPOvrofSojxzfmz1lElAyINvDALlpAg45ulQg8YccXxDn0JTygWaWHDbFapPDiICaybE0nmzdh8OvrofSoLfeIV6AOhBXS0k(HpKcEK6hiL5ePTe0kUHrxdnl6Z65fZts7qe5GuWJulEljlUeTv65qkorQC6bPGhPw8oO6ScMSPJmcAyifN3ifVyd8CQfvdEYvwbtw9I3IgM4zvdmaCZd4d4jTdrKdalWJUHjB4GhTkYPG1PSGq8vxd9ylMLwXp8HuWJuMtK2sqR4ggDn0SOpRNxmpjTdrKdsbpsnfsnfsrRICkyDcAf3WORHMf9z98I5PvU8OzifNi1kum(MlAlUeKAsK67xKAkKIwf5uW6e0kUHrxdnl6Z65fZtR4h(qk4rQfVfKIZBKIBif8i1I3bvNvWKfP4eP4oydPMePMe8CQfvdEYvwbtw9I3IgM4zvdmaCtqWhWtAhIihawGhDdt2WbVPqkzEdpYYKtIwKJgJ4RHuF)IuMtK2s0IC0yeFTK0oeroi1Kif8i1ui1ui1uife(yKOf5OXi(A6WKReZCkxifN3ifVydP((fPGWhJeTihngXxtBorAlXmNYfsX5nsXl2qQjrk4rQJaHpgP1Na1gujXmNYfsDJuZHutIuF)IuMV5ILS4s0wPpHGu)EJu50dsnj45ulQg8OoHODQfvRjbZapsWmD7xc4rlYrJr81agaoEXg4d4jTdrKdalWJUHjB4G3uife(yKYccXxDn0JTywALlpAgs97nsLtpif8ife(yKYccXxDn0JTywcpdPMe8CQfvdEJTygm(2lMEGV8bmGbmWBAzzr1a44hB8opyd7Yp2s8Zp)8dEW8TJoNbE)05ZecUjmCZl)jifs9bJGuXvwTgsnQfPMFhz44eB(HuRmVHhRCqkwDjiLJB1LBYbPOy8oxyj0mSJOfKI3FcsnVOz4zz1AYbPCQfvJuZph3kTBMt5A(LqZqZMWxz1AYbPMGiLtTOAKIemJLqZapwMqbWX)C8cEzBncIaE)msnHKPdMCqkU3wmdPMxN3rQ5d2j2bszfs5uAH3gsnQfPisU0hF5dP2OZtPeAgA2pJuZFUFHIBYbPGKrTcsrRli3qkijpAwcPMpuQKzmKQRM7dJVxdCcs5ulQMHuvt4lHM5ulQMLYwHwxqUDpioJl0mNAr1Su2k06cYT)3CmQ6GM5ulQMLYwHwxqU9)Mdhp)sAZTOA0SFgPETNXWugsTECqki8XqoifZCJHuqYOwbPO1fKBifKKhndP8(GuzRW9LvMfDosfmK6uTKqZCQfvZszRqRli3(FZbR9mgMY0mZngAMtTOAwkBfADb52)BoYklQgndn7NrQ5p3VqXn5GuY0YYhszXLGuggbPCQvlsfmKYN2dIdrKeAMtTOA2TJBL2nZPCHM5ulQM9)MJROp6XkYeqqZ(zKA(KLr4dP4EBXmKI7jtlls59bPU8OnpAKAct5dP(4KQzOzo1IQz)V5atbJeDUgI4mJNyC)JtzPXwmtpKPLnzbLROZHFQFyorAlbTIBy01qZI(SEEX8K0oeroF)sRICkyDcAf3WORHMf9z98I5PvU8OzCY7CtIM5ulQM9)MJCItdNO9Z0EtfEIXne(yKckFAZjvZsRC5rZ(9oNEGhcFmsbLpT5KQzj8m4zzcHOnFZfJLYjonCI2pt7nv48MF4N6hMtK2sqR4ggDn0SOpRNxmpjTdrKZ3V0QiNcwNGwXnm6AOzrFwpVyEALlpAgN8o3KOzo1IQz)V5ySfZ0mBdUeEIXne(yKckFAZjvZsRC5rZ(9oNEGhcFmsbLpT5KQzj8m4N6hMtK2sqR4ggDn0SOpRNxmpjTdrKZ3V0QiNcwNGwXnm6AOzrFwpVyEALlpAgN8o3KOzo1IQz)V5aAf3WORHMf9z98I58eJBi8Xijxzfmz1lElAyINvDcpdEAvKtbRtzbH4RUg6XwmlTYLhndnZPwun7)nhuNq0o1IQ1KGz80(LCtRICkyndnZPwun7)nhlERDQfvRjbZ4P9l5gQy6SQirNZtmUnNiTLGwXnm6AOzrFwpVyEsAhIih4PvrofSobTIBy01qZI(SEEX80kxE0SFNdnZPwun7)nhlERDQfvRjbZ4P9l5gQyAlOCfDopX4(uwcAf3WORHMf9z98I5jlOCfDoAMtTOA2)Bow8w7ulQwtcMXt7xYDbrctw3IQ5jg3q4JrklieF11qp2Izj8m4nNiTLkisyY6wuDsAhIih0mNAr1S)3CS4T2PwuTMemJN2VKBVeEIXTtTyArlTCfcJZB(rZCQfvZ(FZb1jeTtTOAnjygpTFj3mZ7JVh0m0mNAr1SKxY9kx1YeIWyAyrBYYtmUnNiTLYDdJSrNRzwTxjPDiICqZCQfvZsEj)V5iN40WjA)mT3uHNyCBorAln2IzmkFggjjTdrKdAMtTOAwYl5)nhJTyMMzBWLWtmUPvrofSoTYvTmHimMgw0MSPvU8Oz)EZp2NtpWBorAlL7ggzJoxZSAVss7qe5GM5ulQML8s(FZbMcgj6CneXzgpX4gcFmsBCjj8m0mNAr1SKxY)BogBXmgLpdJWtmUHWhJexbHeDU(YPyIws4zOzo1IQzjVK)3CKtCA4eTFM2BQWtmUx8oO6ScMSPJmcAy)ofVZ93CI0wAX7GQDZKg3TO6K0oeroyp3MenZPwunl5L8)MJXwmtZSn4s4jg3lEhuDwbt20rgbnSFNI35(BorAlT4Dq1UzsJ7wuDsAhIihSNBtIM5ulQML8s(FZXkx1YeIWyAyrBYIM5ulQML8s(FZXylMXO8zye0mNAr1SKxY)BokisyY6MWtmUx8oO6ScMSPJmcAyCof)Z93CI0wAX7GQDZKg3TO6K0oeroyp3MenZPwunl5L8)MJCItdNO9Z0Etf0mNAr1SKxY)BogBXmnZ2GlbnZPwunl5L8)Mdm126AOHfTjlAMtTOAwYl5)nh(s9w0wTR0gAgA2pJuyTIByqQAGuVOpRNxmhPYQIeDosTL5wuns9tqkM5RXqk(XgdPGKrTcsHDgeIVivnqkU3wmdP(JuyvpKYxbP8P9G4qebnZPwunlbvmDwvKOZVXuWirNRHioZ4jg3q4JrAJljHNHM5ulQMLGkMoRks05)V5OGiHjRBcpX4EXBjzXLOTspXFZPh4x8oO6ScMSPJmcAyCEZ)COzo1IQzjOIPZQIeD()BoYjonCI2pt7nv4jg3lEhuDwbt20rgbnSF5hBWtRICkyDklieF11qp2IzPvU8OzCU4TKS4s0wPNiAMtTOAwcQy6SQirN))MJXwmtZSn4s4jg3lEhuDwbt20rgbnSF5hBWtRICkyDklieF11qp2IzPvU8OzCU4TKS4s0wPNiAMtTOAwcQy6SQirN))MJXwmJr5ZWi8eJBi8XiXvqirNRVCkMOLeEg8lEhuDwbt20rgbnmoNI35(BorAlT4Dq1UzsJ7wuDsAhIihSNBtIM5ulQMLGkMoRks05)V5OGiHjRBcpX4EX7GQZkyYMoYiOHX59u8p3FZjsBPfVdQ2ntAC3IQts7qe5G9CBs0mNAr1SeuX0zvrIo))nh5eNgor7NP9Mk8eJBAvKtbRtzbH4RUg6XwmlTYLhnJZfVLKfxI2k9eHFX7GQZkyYMoYiOH97eXg8SmHq0MV5IXs5eNgor7NP9MkCEZpAMtTOAwcQy6SQirN))MJXwmtZSn4s4jg30QiNcwNYccXxDn0JTywALlpAgNlEljlUeTv6jc)I3bvNvWKnDKrqd73jIn0m0mNAr1SeuX0wq5k687cIeMSUj8eJ7fVdQoRGj7V3CdBOzo1IQzjOIPTGYv05)V5yLRAzcrymnSOnz5jg3MtK2s5UHr2OZ1mR2RK0oeroOzo1IQzjOIPTGYv05)V5atbJeDUgI4mJNyCdHpgPnUKeEgAMtTOAwcQyAlOCfD()BokisyY6MWtmUx8wswCjAR0Z9Bo9897I3bvNvWK937johAMtTOAwcQyAlOCfD()BogBXmgLpdJWtmUHWhJexbHeDU(YPyIws4zOzo1IQzjOIPTGYv05)V5atTTUgAyrBYYtmUx8oO6ScMSPJmcAyCEZnSb)I3sYIlrBLMBCMtpOzo1IQzjOIPTGYv05)V5yLRAzcrymnSOnzrZCQfvZsqftBbLROZ)FZXylMXO8zyeEIXnltieT5BUyS0ylMXO8zyeoV5hnZPwunlbvmTfuUIo))nhfejmzDt4jg3lEhuDwbt20rgbnmo5FUVFx8w4KBOzo1IQzjOIPTGYv05)V5WxQ3I2QDL24jg3lEhuDwbt20rgbnmo5hBOzOz)msnFlYbPWi(AifT6tyr1m0mNAr1SeTihngXx7MIXJMPRHoOcpX4Eki8XirlYrJr810HjxjM5uU4CUVFHWhJeTihngXxtBorAlXmNYfNZnj8MV5ILS4s0wPpH8Bo9GM5ulQMLOf5OXi(A)V5GIXJMPRHoOcpX4Eki8XiLfeIV6AOhBXS0kxE0SFVZPhSFkE)tRICkyDASfZGX3EX0d8LV0k(HVj)(fcFmszbH4RUg6XwmlTYLhn73fVLKfxI2kn3MeEi8XiLfeIV6AOhBXSeEgAgAMtTOAwIwf5uWA2not0Hjxm0mNAr1SeTkYPG1S)3CGZeDyYfpTFj3yQT11qpTtQLNyCdHpgPSGq8vxd9ylMLWZGFQFyorAlbTIBy01qZI(SEEX8K0oeroF)(dAvKtbRtqR4ggDn0SOpRNxmpTYLhnBs0mNAr1SeTkYPG1S)3CKvwunpX4gcFmszbH4RUg6XwmlHNbpe(yKKRScMS6fVfnmXZQoHNHM5ulQMLOvrofSM9)Mdisvh9aF5JNyCdHpgPSGq8vxd9ylMLWZGhcFmsYvwbtw9I3IgM4zvNWZqZCQfvZs0QiNcwZ(FZbKSmz5k6CEIXne(yKYccXxDn0JTywcpdn7NrkU3wmdPOvrofSMHM5ulQMLOvrofSM9)MJSGq8vxd9ylMXtmUHWhJKCLvWKvV4TOHjEw1j8SVFPvrofSojxzfmz1lElAyINvDALlpAgAMtTOAwIwf5uWA2)BoKRScMS6fVfnmXZQMNyCtRICkyDklieF11qp2IzPv8dFW)dZjsBjOvCdJUgAw0N1ZlMNK2HiYb(fVLKfxI2k9CCMtpWV4Dq1zfmzthze0W48MxSHM9Zi1eEGuWeKI6nsHZeKA(pH(PiL3hKcJpTGuHHuJArQw4(nKcRvCddpivEHuogXpjKcPWoKCPp(YhsTrNJuyesglHM5ulQMLOvrofSM9)Md5kRGjREXBrdt8SQ5jg30QiNcwNYccXxDn0JTywAf)Wh8MtK2sqR4ggDn0SOpRNxmpjTdrKd8tnfTkYPG1jOvCdJUgAw0N1ZlMNw5YJMX5kum(MlAlUKj)(DkAvKtbRtqR4ggDn0SOpRNxmpTIF4d(fVfoV5g8lEhuDwbtwo5oyBYjrZCQfvZs0QiNcwZ(FZb1jeTtTOAnjygpTFj30IC0yeFnEIX9uY8gEKLjNeTihngXx77xZjsBjAroAmIVwsAhIiNjHFQPMccFms0IC0yeFnDyYvIzoLloV5fBF)cHpgjAroAmIVM2CI0wIzoLloV5fBtc)rGWhJ06tGAdQKyMt56EUj)(18nxSKfxI2k9jKFVZPNjrZCQfvZs0QiNcwZ(FZXylMbJV9IPh4lF8eJ7PGWhJuwqi(QRHESfZsRC5rZ(9oNEGhcFmszbH4RUg6XwmlHNnjAgA2pJuCxqKWK1TOAKAlZTOA0mNAr1Subrctw3IQVx5QwMqegtdlAtwEIXT5ePTuUByKn6CnZQ9kjTdrKdAMtTOAwQGiHjRBr1)V5OGiHjRBcpX4(hMtK2sJTygJYNHrss7qe5a)pGWhJ0gxscpdEwMqiAZ3CXyjmfms05AiIZmoV5gAMtTOAwQGiHjRBr1)V5ySfZyu(mmcpX4Eki8XiXvqirNRVCkMOL0ko1((Dki8XiXvqirNRVCkMOLeEg8tLTY06C6jXBASfZ0mBdUKVFZwzADo9K4nHPGrIoxdrCM99B2ktRZPNeVPCItdNO9Z0EtLjNCs4NAXBjzXLOTsproZPNVFzzcHOnFZfJLgBXmgLpdJW5n)tIM5ulQMLkisyY6wu9)BokisyY6MWtmUHWhJexbHeDU(YPyIwsR4u773PGWhJexbHeDU(YPyIws4zWpv2ktRZPNeVPXwmtZSn4s((nBLP150tI3eMcgj6CneXz23VzRmToNEs8MYjonCI2pt7nvMCs0mNAr1Subrctw3IQ)FZroXPHt0(zAVPcpX4EQFaHpgPnUKeE23VlEhuDwbt20rgbnSF5fBF)U4TKS4s0wP5NZC6zs4zzcHOnFZfJLYjonCI2pt7nv48MF0mNAr1Subrctw3IQ)FZbMcgj6CneXzgpX4gcFmsBCjj8m4zzcHOnFZfJLWuWirNRHioZ48MF0mNAr1Subrctw3IQ)FZXylMPz2gCj8eJ7FaHpgPnUKeE23VlEhuDwbt20rgbnSF5fBF)U4TKS4s0wP5NZC6bnZPwunlvqKWK1TO6)3CGPGrIoxdrCMXtmUHWhJ0gxscpdnZPwunlvqKWK1TO6)3CuqKWK1nbndn7NrQN59X3dsXIoNiCFMV5IHuBzUfvJM5ulQMLyM3hFp3RCvlticJPHfTjlAMtTOAwIzEF898)MJXwmtZSn4s4jg30QiNcwNw5QwMqegtdlAt20kxE0SFV5h7ZPh4nNiTLYDdJSrNRzwTxjPDiICqZCQfvZsmZ7JVN)3CGPGrIoxdrCMXtmUHWhJ0gxscpdnZPwunlXmVp(E(FZrbrctw3eEIX9pGWhJ0yRjG06mCcts4zWBorAln2AciTodNWKK0oeroOzo1IQzjM59X3Z)BogBXmnZ2GlHNyCV4Dq1zfmzthze0W(DkEN7V5ePT0I3bv7MjnUBr1jPDiICWEUnjAMtTOAwIzEF898)MJXwmJr5ZWi8eJBi8XiXvqirNRVCkMOLeEg8lEljlUeTv6jY5Do9GM5ulQMLyM3hFp)V5OGiHjRBcpX4EX7GQZkyYMoYiOHX5u8p3FZjsBPfVdQ2ntAC3IQts7qe5G9CBs0mNAr1SeZ8(475)nhJTyMMzBWLGM5ulQMLyM3hFp)V5atTTUgAyrBYIM5ulQMLyM3hFp)V5WxQ3I2QDL2agWaa]] )


end
