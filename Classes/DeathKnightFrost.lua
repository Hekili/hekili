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


    spec:RegisterPack( "Frost DK", 20181021.1941, [[duKmEbqiaLhjjL2Ke1OiQCkIIvbG8kOWSKeULKu0Ui8lOOHjr6yQIwMeXZaGPjjQRjbTnjrQVjjfgNKu15aq16aqP5PkCpvP9ru6GssfzHsGhcGIMOKi0fLej1gLerNusQWkbKxkjcUjakStIQ(PKijdvsQ0sLejEkqtfkzVq(lvgmPoSWIvvpgXKvPlJAZu1NLuJMiDArVgGMnj3wfTBL(TIHRclxQNJ00PCDOA7aQ(ormEjPI68qPwVKK5lH2pOrpryHaVHXi5lP0Nv)Zsl5P4jaVYplbGJanSpye4rqamQze4gNmcSs2d1G6kXkbe4rGTAIlcleiDWBcJaLA2bfGftmRttk(xqMtmP5jUkSCwshEdtAEsW8RMpMFFunVmWX8OhFQykMv3MRuI8sXS6wP4Qe5WK6Qe2SwQ5QK9qnbnpjiWpEQSQJf9rG3WyK8Lu6ZQ)zPL8u8eGx5sbWteyGBsNgbcMNamrGsZ7Lx0hbEzkbbwTqDLShQb1vICysH6kHnRLAqGQwOwQzhuawmXSonP4FbzoXKMN4QWYzjD4nmP5jbZVA(y(9r18YahZJE8PIPywDBUsjYlfZQBLIRsKdtQRsyZAPMRs2d1e08KabQAH6kveB(Cd1L8ScOUKsFw9qD1eQRgaSvUuOU6cWaceeOQfQbykn2AMcWcbQAH6QjuxDSef(LHAag5EH6kzZCvSabQsQrryHajJ66KYrBiSqY)eHfcK34R4lQaeiPtJ7mqGFCVxqg11jLJ2euliac1Yc1fc1LHAl6A2ewEYoBC3KH6hqDn5IadILZIajsJCPUX7scJmK8LGWcbYB8v8fvacK0PXDgiq5G6pU3losLkA34D(EOMO5Zixku)4fQRjxOgGGA5G6Nqngqnzg1DKScFputc29j15XBSfnhxSHAzG6IfH6pU3losLkA34D(EOMO5Zixku)aQB8LfwEYoBCaaQLbQld1FCVxCKkv0UX789qnb(bcmiwolcKinYL6gVljmYqYdaewiqEJVIVOcqGKonUZab(X9EXrQur7gVZ3d1enFg5sH6hqD1d1LH6pU3lWxPJcBh1AERnPIMpJCPq9dOUMCHAacQLdQFc1ya1Kzu3rYk89qnjy3NuNhVXw0CCXgQLbQld1FCVxGVshf2oQ18wBsfnFg5sH6Yq9h37fhPsfTB8oFputGFGadILZIajsJCPUX7scJmKHaNVknUdlNfHfs(NiSqG8gFfFrfGajDACNbc0cfVMOomPCNBTJAtFk4n(k(IadILZIaB(CAkRyk1jjxJBKHKVeewiqEJVIVOcqGKonUZabkhuF5pU3l6OQPtclOwqaeQFa1fc1flc1x(J79IoQA6KWIMpJCPq9dO(zPqTmqDzOgyqTfkEnHVhQrjyBszbVXxXxOUmudmO(J79Iopzb(buxgQPhSs5SORzJkKosu5w7(QGAqTSVqnaqGbXYzrGZxLg3HXidjpaqyHa5n(k(Ikabs604odeiWGAlu8AcFpuJsW2KYcEJVIVqDzOgyq9h37fDEYc8dOUmutpyLYzrxZgviDKOYT29vb1GAzFHAaGadILZIaNVknUdJrgs(kJWcbYB8v8fvacK0PXDgiq5G6pU3lamvQCRDNbrAUSO5GyqDXIqTCq9h37faMkvU1UZGinxwGFa1LHA5G6JMbURMCfpf(EOMJADcid1flc1hndCxn5kEkKosu5w7(QGAqDXIq9rZa3vtUINIAvqYq5IlWJLWqTmqTmqTmqDzOMEWkLZIUMnQW3d1OeSnPmul7luxccmiwolc03d1OeSnPmYqYxicleiVXxXxubiqsNg3zGaLdQV8h37fDu10jHfuliac1pG6cH6IfH6l)X9ErhvnDsyrZNrUuO(bu)SuOwgOUmu)X9EbGPsLBT7misZLfnhedQlweQLdQ)4EVaWuPYT2DgeP5Yc8dOUmulhuF0mWD1KR4PW3d1CuRtazOUyrO(OzG7QjxXtH0rIk3A3xfudQlweQpAg4UAYv8uuRcsgkxCbESegQLbQLbbgelNfboFvAChgJmK8vAewiqEJVIVOcqGKonUZab(X9EbGPsLBT7misZLfnhedQlweQLdQ)4EVaWuPYT2DgeP5Yc8dOUmulhuF0mWD1KR4PW3d1CuRtazOUyrO(OzG7QjxXtH0rIk3A3xfudQlweQpAg4UAYv8uuRcsgkxCbESegQLbQLbbgelNfboFvAChgJmK8vdewiqEJVIVOcqGKonUZabkhudmO(J79Iopzb(buxSiu34BsChJeUfx2NK0G6hq9ZsH6IfH6gFzHLNSZgxjqTSqDn5c1Ya1LHA6bRuol6A2OIAvqYq5IlWJLWqTSVqDjiWGy5SiWAvqYq5IlWJLWidjF1JWcbYB8v8fvacK0PXDgiWpU3l68Kf4hqDzOMEWkLZIUMnQq6irLBT7RcQb1Y(c1LGadILZIaLosu5w7(QGAidjpahHfcK34R4lQaeiPtJ7mqGYb1x(J79IoQA6KWcQfeaH6hqDHqDXIq9L)4EVOJQMojSO5Zixku)aQFwkulduxgQbgu)X9ErNNSa)aQlweQB8njUJrc3Il7tsAq9dO(zPqDXIqDJVSWYt2zJReOwwOUMCH6YqnWGAlu8AcFpuJsW2KYcEJVIViWGy5SiqFpuZrTobKrgs(NLIWcbYB8v8fvacK0PXDgiqGb1FCVx05jlWpG6IfH6gFtI7yKWT4Y(KKgu)aQFwkuxSiu34llS8KD24kbQLfQRjxeyqSCweOVhQ5OwNaYidj)ZNiSqG8gFfFrfGajDACNbc8J79Iopzb(bcmiwolcu6irLBT7RcQHmK8plbHfcK34R4lQaeiPtJ7mqGYb1x(J79IoQA6KWcQfeaH6hqDHqDXIq9L)4EVOJQMojSO5Zixku)aQFwkulduxgQbguBHIxt47HAuc2MuwWB8v8fbgelNfboFvAChgJmK8pbacleyqSCwe48vPXDymcK34R4lQaKHmei1I9g9fHfs(NiSqGbXYzrGnFonLvmL6KKRXncK34R4lQaKHKVeewiqEJVIVOcqGKonUZabsMrDhjRO5ZPPSIPuNKCnUfnFg5sH6hVqDjqnab11KluxgQTqXRjQdtk35w7O20NcEJVIViWGy5SiqFpuZrTobKrgsEaGWcbYB8v8fvacK0PXDgiWpU3l68Kf4hiWGy5SiqPJevU1UVkOgYqYxzewiqEJVIVOcqGKonUZabcmO(J79cFpvXR7axrzb(buxgQTqXRj89ufVUdCfLf8gFfFrGbXYzrGZxLg3HXidjFHiSqG8gFfFrfGajDACNbcSX3K4ogjClUSpjPb1pGA5G6Nfc1ya1wO41en(MexygV4HLZk4n(k(c1aeudaOwgeyqSCweOVhQ5OwNaYidjFLgHfcK34R4lQaeiPtJ7mqGFCVxayQu5w7odI0Czb(buxgQB8LfwEYoBCvgQL9fQRjxeyqSCweOVhQrjyBszKHKVAGWcbYB8v8fvacK0PXDgiWgFtI7yKWT4Y(KKgullulhuxsHqngqTfkEnrJVjXfMXlEy5ScEJVIVqnab1aaQLbbgelNfboFvAChgJmK8vpcleyqSCweOVhQ5OwNaYiqEJVIVOcqgsEaocleyqSCweO0Px34DsY14gbYB8v8fvaYqY)SuewiWGy5SiWOjXYoB6MxdbYB8v8fvaYqgc8pu3XmQCRryHK)jcleiVXxXxubiqsNg3zGa)4EVOZtwGFGadILZIaLosu5w7(QGAidjFjiSqG8gFfFrfGajDACNbcuoO(YFCVx0rvtNewqTGaiu)aQleQlweQV8h37fDu10jHfnFg5sH6hq9ZsHAzG6YqDJVSWYt2zJRYq9dOUMCH6YqDJVjXDms4wCzFssdQL9fQlPqOUmudmO2cfVMW3d1OeSnPSG34R4lcmiwolcC(Q04omgzi5bacleiVXxXxubiqsNg3zGaB8LfwEYoBCvgQFa11KluxgQB8njUJrc3Il7tsAqTSVqDjfIadILZIaNVknUdJrgs(kJWcbYB8v8fvacK0PXDgiWgFtI7yKWT4Y(KKgu)aQlPuOUmutMrDhjR4ivQODJ357HAIMpJCPqTSqDJVSWYt2zJRYqDzOMEWkLZIUMnQOwfKmuU4c8yjmul7luxccmiwolcSwfKmuU4c8yjmYqYxicleiVXxXxubiqsNg3zGaLdQV8h37fDu10jHfuliac1pG6cH6IfH6l)X9ErhvnDsyrZNrUuO(bu)SuOwgOUmu34BsChJeUfx2NK0G6hqDjLc1LHAYmQ7izfhPsfTB8oFput08zKlfQLfQB8LfwEYoBCvgQld1adQTqXRj89qnkbBtkl4n(k(IadILZIa99qnh16eqgzi5R0iSqG8gFfFrfGajDACNbcSX3K4ogjClUSpjPb1pG6skfQld1Kzu3rYkosLkA34D(EOMO5Zixkullu34llS8KD24Qmcmiwolc03d1CuRtazKHKVAGWcbYB8v8fvacK0PXDgiWpU3lamvQCRDNbrAUSa)aQld1n(Me3XiHBXL9jjnOwwOwoO(zHqngqTfkEnrJVjXfMXlEy5ScEJVIVqnab1aaQLbQld10dwPCw01Srf(EOgLGTjLHAzFH6sqGbXYzrG(EOgLGTjLrgs(QhHfcK34R4lQaeiPtJ7mqGn(Me3XiHBXL9jjnOw2xOwoOgafc1ya1wO41en(MexygV4HLZk4n(k(c1aeudaOwgOUmutpyLYzrxZgv47HAuc2MugQL9fQlbbgelNfb67HAuc2Mugzi5b4iSqG8gFfFrfGajDACNbcuoO(YFCVx0rvtNewqTGaiu)aQleQlweQV8h37fDu10jHfnFg5sH6hq9ZsHAzG6YqDJVjXDms4wCzFssdQL9fQLdQbqHqngqTfkEnrJVjXfMXlEy5ScEJVIVqnab1aaQLbQld1adQTqXRj89qnkbBtkl4n(k(IadILZIaNVknUdJrgs(NLIWcbYB8v8fvacK0PXDgiWgFtI7yKWT4Y(KKgul7lulhudGcHAmGAlu8AIgFtIlmJx8WYzf8gFfFHAacQbauldcmiwolcC(Q04omgzi5F(eHfcK34R4lQaeiPtJ7mqGKzu3rYkosLkA34D(EOMO5Zixkullu34llS8KD24QmuxgQB8njUJrc3Il7tsAq9dOUYLc1LHA6bRuol6A2OIAvqYq5IlWJLWqTSVqDjiWGy5SiWAvqYq5IlWJLWidj)ZsqyHa5n(k(Ikabs604odeOCq9L)4EVOJQMojSGAbbqO(buxiuxSiuF5pU3l6OQPtclA(mYLc1pG6NLc1Ya1LHAYmQ7izfhPsfTB8oFput08zKlfQLfQB8LfwEYoBCvgQld1n(Me3XiHBXL9jjnO(bux5sH6YqnWGAlu8AcFpuJsW2KYcEJVIViWGy5SiqFpuZrTobKrgs(NaaHfcK34R4lQaeiPtJ7mqGKzu3rYkosLkA34D(EOMO5Zixkullu34llS8KD24QmuxgQB8njUJrc3Il7tsAq9dOUYLIadILZIa99qnh16eqgzidbE0mzo)HHWcj)tewiqEJVIVOcqgs(sqyHa5n(k(Ikazi5bacleiVXxXxubidjFLryHa5n(k(Ikazi5leHfcmiwolc8ySCweiVXxXxubidziWyyewi5FIWcbYB8v8fvacK0PXDgiqlu8AI6WKYDU1oQn9PG34R4luxSiulhuhvXDASW3tv86m(8GPMOJfqOUmutpyLYzrxZgv0850uwXuQtsUg3qTSVqnaG6YqnWG6pU3l68Kf4hqTmiWGy5SiWMpNMYkMsDsY14gzi5lbHfcK34R4lQaeiPtJ7mqGwO41e(EOgLGTjLf8gFfFrGbXYzrG1QGKHYfxGhlHrgsEaGWcbYB8v8fvacK0PXDgiq5G6l)X9ErhvnDsyb1ccGq9dOUqOUyrO(YFCVx0rvtNew08zKlfQFa1plfQLbQld1Kzu3rYkA(CAkRyk1jjxJBrZNrUuO(XluxcudqqDn5c1LHAlu8AI6WKYDU1oQn9PG34R4luxgQbguBHIxt47HAuc2MuwWB8v8fbgelNfb67HAoQ1jGmYqYxzewiqEJVIVOcqGKonUZabsMrDhjRO5ZPPSIPuNKCnUfnFg5sH6hVqDjqnab11KluxgQTqXRjQdtk35w7O20NcEJVIViWGy5SiqFpuZrTobKrgs(cryHa5n(k(Ikabs604ode4h37fDEYc8deyqSCweO0rIk3A3xfudzi5R0iSqG8gFfFrfGajDACNbc8J79catLk3A3zqKMllWpqGbXYzrG(EOgLGTjLrgs(QbcleiVXxXxubiqsNg3zGaB8njUJrc3Il7tsAq9dOwoO(zHqngqTfkEnrJVjXfMXlEy5ScEJVIVqnab1aaQLbbgelNfbwRcsgkxCbESegzi5REewiqEJVIVOcqGKonUZabkhuF5pU3l6OQPtclOwqaeQFa1fc1flc1x(J79IoQA6KWIMpJCPq9dO(zPqTmqDzOUX3K4ogjClUSpjPb1pGA5G6Nfc1ya1wO41en(MexygV4HLZk4n(k(c1aeudaOwgOUmudmO2cfVMW3d1OeSnPSG34R4lcmiwolc03d1CuRtazKHKhGJWcbYB8v8fvacK0PXDgiWgFtI7yKWT4Y(KKgu)aQLdQFwiuJbuBHIxt04BsCHz8IhwoRG34R4ludqqnaGAzqGbXYzrG(EOMJADciJmK8plfHfcmiwolcS5ZPPSIPuNKCnUrG8gFfFrfGmK8pFIWcbgelNfb67HAuc2MugbYB8v8fvaYqY)SeewiqEJVIVOcqGKonUZabkhuF5pU3l6OQPtclOwqaeQFa1fc1flc1x(J79IoQA6KWIMpJCPq9dO(zPqTmqDzOUX3K4ogjClUSpjPb1Yc1Yb1LuiuJbuBHIxt04BsCHz8IhwoRG34R4ludqqnaGAzG6YqnWGAlu8AcFpuJsW2KYcEJVIViWGy5SiW5RsJ7WyKHK)jaqyHa5n(k(Ikabs604odeyJVjXDms4wCzFssdQLfQLdQlPqOgdO2cfVMOX3K4cZ4fpSCwbVXxXxOgGGAaa1YGadILZIaNVknUdJrgs(NvgHfcmiwolcSwfKmuU4c8yjmcK34R4lQaKHK)zHiSqG8gFfFrfGajDACNbcuoO(YFCVx0rvtNewqTGaiu)aQleQlweQV8h37fDu10jHfnFg5sH6hq9ZsHAzG6YqnWGAlu8AcFpuJsW2KYcEJVIViWGy5SiqFpuZrTobKrgs(NvAewiWGy5SiqFpuZrTobKrG8gFfFrfGmK8pRgiSqGbXYzrGsNEDJ3jjxJBeiVXxXxubidj)ZQhHfcmiwolcmAsSSZMU51qG8gFfFrfGmKHajZOUJKLIWcj)tewiqEJVIVOcqGKonUZabkhutMrDhjR4ivQODJ357HAIMJl2qDXIqnzg1DKSIJuPI2nENVhQjA(mYLc1Yc1LukulduxgQLdQbguBHIxt8BomPUX7O5E7OEOHG34R4luxSiutMrDhjRGppgjC7A8LDs44ywrZNrUuOwwOgGxiuldcmiwolceNYU04tkYqYxccleiVXxXxubiWnozeyhvDXxaPUFw7A(6(4MnlcmiwolcSJQU4lGu3pRDnFDFCZMfzi5bacleiVXxXxubiWGy5SiWtUzanPb15JTgbs604odeiWG67yIFZHj1nEhn3Bh1dnewsam3AOUmudmO(J79IJuPI2nENVhQjWpqGBCYiWtUzanPb15JTgzi5RmcleiVXxXxubiqsNg3zGa)4EV4ivQODJ357HAc8dOUmu)X9EbFEms4214l7KWXXSc8deyqSCwe4Xy5SidjFHiSqG8gFfFrfGajDACNbc8J79IJuPI2nENVhQjWpG6Yq9h37f85XiHBxJVStchhZkWpqGbXYzrGF1mxNhVXgzi5R0iSqG8gFfFrfGajDACNbc8J79IJuPI2nENVhQjWpqGbXYzrGFUPCdyU1idjF1aHfcK34R4lQaeiPtJ7mqGKzu3rYk4ZJrc3UgFzNeooMv08zKlfbgelNfbEKkv0UX789qnKHKV6ryHa5n(k(Ikabs604odeizg1DKSc(8yKWTRXx2jHJJzfnFg5sH6Yqnzg1DKSIJuPI2nENVhQjA(mYLIadILZIa)nhMu34D0CVDup0azi5b4iSqG8gFfFrfGajDACNbcKmJ6oswXrQur7gVZ3d1enhxSH6YqnWGAlu8AIFZHj1nEhn3Bh1dne8gFfFH6YqDJVSWYt2zJRqOwwOUMCH6YqDJVjXDms4wCzFssdQL9fQFwkuxSiuBrxZMWYt2zJ7Mmu)aQlPueyqSCweiFEms4214l7KWXXSidj)ZsryHa5n(k(Ikabs604odeOCqnzg1DKSIJuPI2nENVhQjAoUyd1flc1w01SjS8KD24Ujd1pG6skfQLbQld1wO41e)MdtQB8oAU3oQhAi4n(k(c1LH6gFzOw2xOgaqDzOUX3K4ogjCd1Yc1v6srGbXYzrG85XiHBxJVStchhZImK8pFIWcbYB8v8fvacK0PXDgiqlu8AcYOUoPC0MG34R4luxgQLdQLdQ)4EVGmQRtkhTjOwqaeQL9fQFwkuxgQV8h37fDu10jHfuliac1VqDHqTmqDXIqTfDnBclpzNnUBYq9JxOUMCHAzqGbXYzrGKqPCbXYzDQKAiqvsn3gNmcKmQRtkhTHmK8plbHfcK34R4lQaeiPtJ7mqGYb1FCVxCKkv0UX789qnrZNrUuO(XluxtUqDXIqTCq9h37fhPsfTB8oFput08zKlfQFa1vpuxgQ)4EVaFLokSDuR5T2KkA(mYLc1pEH6AYfQld1FCVxGVshf2oQ18wBsf4hqTmqTmqDzO(J79IJuPI2nENVhQjWpqGbXYzrG(EOMeS7tQZJ3yJmK8pbacleiVXxXxubiqsNg3zGaTORzty5j7SXDtgQFa11KluxSiulhuBrxZMWYt2zJ7Mmu)aQjZOUJKvCKkv0UX789qnrZNrUuOUmu)X9Eb(kDuy7OwZBTjvGFa1YGadILZIa99qnjy3NuNhVXgzidbEzFGRmewi5FIWcbgelNfbEM715BMRIrG8gFfFrfGmK8LGWcbYB8v8fvacK0PXDgiqGb13Xe(EOMZZaNBHLeaZTgQld1Yb1adQTqXRj(nhMu34D0CVDup0qWB8v8fQlweQjZOUJKv8BomPUX7O5E7OEOHO5Zixkullu)SqOwgeyqSCweO0rIk3A3xfudzi5bacleiVXxXxubiqsNg3zGa)4EVijy7Sqnlv08zKlfQF8c11KluxgQ)4EVijy7SqnlvGFa1LHA6bRuol6A2OIAvqYq5IlWJLWqTSVqDjqDzOwoOgyqTfkEnXV5WK6gVJM7TJ6HgcEJVIVqDXIqnzg1DKSIFZHj1nEhn3Bh1dnenFg5sHAzH6Nfc1YGadILZIaRvbjdLlUapwcJmK8vgHfcK34R4lQaeiPtJ7mqGFCVxKeSDwOMLkA(mYLc1pEH6AYfQld1FCVxKeSDwOMLkWpG6YqTCqnWGAlu8AIFZHj1nEhn3Bh1dne8gFfFH6IfHAYmQ7izf)MdtQB8oAU3oQhAiA(mYLc1Yc1pleQLbbgelNfb67HAoQ1jGmYqYxicleiVXxXxubiWGy5SiqsOuUGy5SovsneOkPMBJtgbsMrDhjlfzi5R0iSqG8gFfFrfGajDACNbc0cfVM43CysDJ3rZ92r9qdbVXxXxOUmulhutMrDhjR43CysDJ3rZ92r9qdrZNrUuO(buxiuxSiulhutMrDhjR43CysDJ3rZ92r9qdrZNrUuO(buxsPqDzO2IUMnHLNSZg3nzO(budGcHAzGAzqGbXYzrGn(6cILZ6uj1qGQKAUnoze4FOUJzu5wJmK8vdewiqEJVIVOcqGKonUZabEht8BomPUX7O5E7OEOHWscG5wJadILZIaB81felN1PsQHavj1CBCYiW)qDwsam3AKHKV6ryHa5n(k(Ikabs604ode4h37fhPsfTB8oFputGFa1LHAlu8AI5RsJ7WYzf8gFfFrGbXYzrGn(6cILZ6uj1qGQKAUnoze48vPXDy5SidjpahHfcK34R4lQaeiPtJ7mqGbXsGZoE5ZKPqTSVqDjiWGy5SiWgFDbXYzDQKAiqvsn3gNmcmggzi5FwkcleiVXxXxubiWGy5SiqsOuUGy5SovsneOkPMBJtgbsTyVrFrgYqG)H6SKayU1iSqY)eHfcK34R4lQaeiPtJ7mqGYb1x(J79IoQA6KWcQfeaH6hqDHqDXIq9L)4EVOJQMojSO5Zixku)aQFwkulduxgQB8njUJrc3q9JxOgaLc1LHAGb1wO41e(EOgLGTjLf8gFfFrGbXYzrGZxLg3HXidjFjiSqG8gFfFrfGajDACNbcSX3K4ogjCd1pEHAaukcmiwolcC(Q04omgzi5bacleiVXxXxubiqsNg3zGaTqXRjQdtk35w7O20NcEJVIViWGy5SiWMpNMYkMsDsY14gzi5RmcleiVXxXxubiqsNg3zGa)4EVOZtwGFGadILZIaLosu5w7(QGAidjFHiSqG8gFfFrfGajDACNbcuoO(YFCVx0rvtNewqTGaiu)aQleQlweQV8h37fDu10jHfnFg5sH6hq9ZsHAzG6YqDJVSWYt2zJRqO(buxtUqDXIqDJVjXDms4gQF8c1vUqOUmudmO2cfVMW3d1OeSnPSG34R4lcmiwolcC(Q04omgzi5R0iSqG8gFfFrfGajDACNbcSXxwy5j7SXviu)aQRjxOUyrOUX3K4ogjCd1pEH6kxicmiwolcC(Q04omgzi5RgiSqG8gFfFrfGajDACNbc8J79catLk3A3zqKMllWpG6Yqn9GvkNfDnBuHVhQrjyBszOw2xOUeeyqSCweOVhQrjyBszKHKV6ryHa5n(k(Ikabs604odeyJVjXDms4wCzFssdQL9fQbqPqDzOUXxwy5j7SXbaOwwOUMCrGbXYzrGsNEDJ3jjxJBKHKhGJWcbgelNfb2850uwXuQtsUg3iqEJVIVOcqgs(NLIWcbYB8v8fvacK0PXDgiq6bRuol6A2OcFpuJsW2KYqTSVqDjiWGy5SiqFpuJsW2KYidj)ZNiSqG8gFfFrfGajDACNbcuoO(YFCVx0rvtNewqTGaiu)aQleQlweQV8h37fDu10jHfnFg5sH6hq9ZsHAzG6YqDJVjXDms4wCzFssdQLfQlPqOUyrOUXxgQLfQbauxgQbguBHIxt47HAuc2MuwWB8v8fbgelNfboFvAChgJmK8plbHfcK34R4lQaeiPtJ7mqGn(Me3XiHBXL9jjnOwwOUKcH6IfH6gFzOwwOgaiWGy5SiW5RsJ7WyKHK)jaqyHa5n(k(Ikabs604odeyJVjXDms4wCzFssdQLfQlPueyqSCwey0KyzNnDZRHmKHmeiW5MMZIKVKsFw9LcWlbGlkP0k)ebkj6n3AkcS648yAJVqnahQdILZc1QKAubeie4rp(uXiWQfQRK9qnOUsKdtkuxjSzTudcu1c1sn7GcWIjM1Pjf)liZjM08exfwolPdVHjnpjy(vZhZVpQMxg4yE0JpvmfZQBZvkrEPywDRuCvICysDvcBwl1CvYEOMGMNeiqvluxPIyZNBOUKNva1Lu6ZQhQRMqD1aGTYLc1vxagqGGavTqnatPXwZuawiqvluxnH6QJLOWVmudWi3luxjBMRIfqGGavTqDL6QZmb34lu)z)0mutMZFyq9NRZLkG6QtecFyuOENTAkn6tpUcQdILZsH6zvylGafelNLkoAMmN)WE9QGcieOGy5SuXrZK58hggVy6N5cbkiwolvC0mzo)HHXlMbE9jVwy5SqGQwOgCJdQ0XG6oYlu)X9E(c1ulmku)z)0mutMZFyq9NRZLc1XEH6JMRMhJz5wd1jfQVZYciqbXYzPIJMjZ5pmmEXKUXbv6yoQfgfcuqSCwQ4OzYC(ddJxmpglNfceeOQfQRuxDMj4gFHAg4CJnuB5jd1MugQdInnuNuOoaEKQ4RybeOGy5S03ZCVoFZCvmeOQfQRoDCOWgQRK9qnOUsYaNBOo2luFg5ArUqD1bbBOgRqnlfcuqSCwkgVykDKOYT29vb1Qi9Va7oMW3d1CEg4ClSKayU1LLdywO41e)MdtQB8oAU3oQhAi4n(k(wSizg1DKSIFZHj1nEhn3Bh1dnenFg5sL9zHYabkiwolfJxmRvbjdLlUapwcxr6F)4EVijy7Sqnlv08zKl9XBn5w(J79IKGTZc1Sub(rz6bRuol6A2OIAvqYq5IlWJLWY(wsz5aMfkEnXV5WK6gVJM7TJ6HgcEJVIVflsMrDhjR43CysDJ3rZ92r9qdrZNrUuzFwOmqGcILZsX4ftFpuZrTobKRi9VFCVxKeSDwOMLkA(mYL(4TMCl)X9ErsW2zHAwQa)OSCaZcfVM43CysDJ3rZ92r9qdbVXxX3IfjZOUJKv8BomPUX7O5E7OEOHO5ZixQSplugiqbXYzPy8IjjukxqSCwNkPwfBCYVKzu3rYsHafelNLIXlMn(6cILZ6uj1QyJt(9pu3XmQCRRi9VwO41e)MdtQB8oAU3oQhAi4n(k(wwoYmQ7izf)MdtQB8oAU3oQhAiA(mYL(OWIfLJmJ6oswXV5WK6gVJM7TJ6HgIMpJCPpkP0Yw01SjS8KD24Uj)aafkJmqGcILZsX4fZgFDbXYzDQKAvSXj)(hQZscG5wxr6FVJj(nhMu34D0CVDup0qyjbWCRHafelNLIXlMn(6cILZ6uj1QyJt(D(Q04oSC2ks)7h37fhPsfTB8oFputGFu2cfVMy(Q04oSCwbVXxXxiqbXYzPy8IzJVUGy5SovsTk24KFJHRi9VbXsGZoE5ZKPY(wceOGy5SumEXKekLliwoRtLuRIno5xQf7n6leiiqbXYzPIy43MpNMYkMsDsY14UI0)AHIxtuhMuUZT2rTPpf8gFfFlwuUOkUtJf(EQIxNXNhm1eDSawMEWkLZIUMnQO5ZPPSIPuNKCnUL9faLb2h37fDEYc8dzGafelNLkIHX4fZAvqYq5IlWJLWvK(xlu8AcFpuJsW2KYcEJVIVqGcILZsfXWy8IPVhQ5OwNaYvyrxZMl9VYD5pU3l6OQPtclOwqa8rHflE5pU3l6OQPtclA(mYL(4zPYuMmJ6oswrZNttzftPoj5AClA(mYL(4TeaQMClBHIxtuhMuUZT2rTPpf8gFfFldmlu8AcFpuJsW2KYcEJVIVqGcILZsfXWy8IPVhQ5OwNaYvK(xYmQ7izfnFonLvmL6KKRXTO5Zix6J3saOAYTSfkEnrDys5o3Ah1M(uWB8v8fcuqSCwQiggJxmLosu5w7(QGAvK(3pU3l68Kf4hqGcILZsfXWy8IPVhQrjyBs5ks)7h37faMkvU1UZGinxwGFabkiwolvedJXlM1QGKHYfxGhlHRi9Vn(Me3XiHBXL9jjThY9SqmSqXRjA8njUWmEXdlNvWB8v8fGaGmqGcILZsfXWy8IPVhQ5OwNaYvyrxZMl9VYD5pU3l6OQPtclOwqa8rHflE5pU3l6OQPtclA(mYL(4zPYuUX3K4ogjClUSpjP9qUNfIHfkEnrJVjXfMXlEy5ScEJVIVaeaKPmWSqXRj89qnkbBtkl4n(k(cbkiwolvedJXlM(EOMJADcixr6FB8njUJrc3Il7tsApK7zHyyHIxt04BsCHz8IhwoRG34R4labazGafelNLkIHX4fZMpNMYkMsDsY14gcuqSCwQiggJxm99qnkbBtkdbkiwolvedJXlMZxLg3HXvyrxZMl9VYD5pU3l6OQPtclOwqa8rHflE5pU3l6OQPtclA(mYL(4zPYuUX3K4ogjClUSpjPjRCLuigwO41en(MexygV4HLZk4n(k(cqaqMYaZcfVMW3d1OeSnPSG34R4leOGy5SurmmgVyoFvAChgxr6FB8njUJrc3Il7tsAYkxjfIHfkEnrJVjXfMXlEy5ScEJVIVaeaKbcuqSCwQiggJxmRvbjdLlUapwcdbkiwolvedJXlM(EOMJADcixHfDnBU0)k3L)4EVOJQMojSGAbbWhfwS4L)4EVOJQMojSO5Zix6JNLktzGzHIxt47HAuc2MuwWB8v8fcuqSCwQiggJxm99qnh16eqgcuqSCwQiggJxmLo96gVtsUg3qGcILZsfXWy8Iz0KyzNnDZRbbccu1c1f0CysH6Xd1G5E7OEObuFmJk3AOUhlSCwOgGfQPw0gfQlPuku)z)0muxDtLkAOE8qDLShQb1ya1fmGqD0muhapsv8vmeOGy5SuXFOUJzu5w)kDKOYT29vb1Qi9VFCVx05jlWpGafelNLk(d1DmJk3AmEXC(Q04omUcl6A2CP)vUl)X9ErhvnDsyb1ccGpkSyXl)X9ErhvnDsyrZNrU0hplvMYn(YclpzNnUk)OMCl34BsChJeUfx2NK0K9TKcldmlu8AcFpuJsW2KYcEJVIVqGcILZsf)H6oMrLBngVyoFvAChgxr6FB8LfwEYoBCv(rn5wUX3K4ogjClUSpjPj7Bjfcbkiwolv8hQ7ygvU1y8IzTkizOCXf4Xs4ks)BJVjXDms4wCzFss7rjLwMmJ6oswXrQur7gVZ3d1enFg5sLTXxwy5j7SXv5Y0dwPCw01Srf1QGKHYfxGhlHL9TeiqbXYzPI)qDhZOYTgJxm99qnh16eqUcl6A2CP)vUl)X9ErhvnDsyb1ccGpkSyXl)X9ErhvnDsyrZNrU0hplvMYn(Me3XiHBXL9jjThLuAzYmQ7izfhPsfTB8oFput08zKlv2gFzHLNSZgxLldmlu8AcFpuJsW2KYcEJVIVqGcILZsf)H6oMrLBngVy67HAoQ1jGCfP)TX3K4ogjClUSpjP9OKsltMrDhjR4ivQODJ357HAIMpJCPY24llS8KD24QmeOGy5SuXFOUJzu5wJXlM(EOgLGTjLRi9VFCVxayQu5w7odI0Czb(r5gFtI7yKWT4Y(KKMSY9SqmSqXRjA8njUWmEXdlNvWB8v8fGaGmLPhSs5SORzJk89qnkbBtkl7BjqGcILZsf)H6oMrLBngVy67HAuc2MuUI0)24BsChJeUfx2NK0K9voauigwO41en(MexygV4HLZk4n(k(cqaqMY0dwPCw01Srf(EOgLGTjLL9TeiqbXYzPI)qDhZOYTgJxmNVknUdJRWIUMnx6FL7YFCVx0rvtNewqTGa4Jclw8YFCVx0rvtNew08zKl9XZsLPCJVjXDms4wCzFsst2x5aqHyyHIxt04BsCHz8IhwoRG34R4labazkdmlu8AcFpuJsW2KYcEJVIVqGcILZsf)H6oMrLBngVyoFvAChgxr6FB8njUJrc3Il7tsAY(khakedlu8AIgFtIlmJx8WYzf8gFfFbiaideOGy5SuXFOUJzu5wJXlM1QGKHYfxGhlHRi9VKzu3rYkosLkA34D(EOMO5ZixQSn(YclpzNnUkxUX3K4ogjClUSpjP9OYLwMEWkLZIUMnQOwfKmuU4c8yjSSVLabkiwolv8hQ7ygvU1y8IPVhQ5OwNaYvyrxZMl9VYD5pU3l6OQPtclOwqa8rHflE5pU3l6OQPtclA(mYL(4zPYuMmJ6oswXrQur7gVZ3d1enFg5sLTXxwy5j7SXv5Yn(Me3XiHBXL9jjThvU0YaZcfVMW3d1OeSnPSG34R4leOGy5SuXFOUJzu5wJXlM(EOMJADcixr6FjZOUJKvCKkv0UX789qnrZNrUuzB8LfwEYoBCvUCJVjXDms4wCzFss7rLlfceeOGy5SuXFOoljaMB978vPXDyCfw01S5s)RCx(J79IoQA6KWcQfeaFuyXIx(J79IoQA6KWIMpJCPpEwQmLB8njUJrc3pEbqPLbMfkEnHVhQrjyBszbVXxXxiqbXYzPI)qDwsam3AmEXC(Q04omUI0)24BsChJeUF8cGsHafelNLk(d1zjbWCRX4fZMpNMYkMsDsY14UI0)AHIxtuhMuUZT2rTPpf8gFfFHafelNLk(d1zjbWCRX4ftPJevU1UVkOwfP)9J79Iopzb(beOGy5SuXFOoljaMBngVyoFvAChgxHfDnBU0)k3L)4EVOJQMojSGAbbWhfwS4L)4EVOJQMojSO5Zix6JNLkt5gFzHLNSZgxHpQj3IfB8njUJrc3pERCHLbMfkEnHVhQrjyBszbVXxXxiqbXYzPI)qDwsam3AmEXC(Q04omUI0)24llS8KD24k8rn5wSyJVjXDms4(XBLlecuqSCwQ4puNLeaZTgJxm99qnkbBtkxr6F)4EVaWuPYT2DgeP5Yc8JY0dwPCw01Srf(EOgLGTjLL9TeiqbXYzPI)qDwsam3AmEXu60RB8oj5ACxr6FB8njUJrc3Il7tsAY(cGsl34llS8KD24aGS1KleOGy5SuXFOoljaMBngVy2850uwXuQtsUg3qGcILZsf)H6SKayU1y8IPVhQrjyBs5ks)l9GvkNfDnBuHVhQrjyBszzFlbcuqSCwQ4puNLeaZTgJxmNVknUdJRWIUMnx6FL7YFCVx0rvtNewqTGa4Jclw8YFCVx0rvtNew08zKl9XZsLPCJVjXDms4wCzFsst2skSyXgFzzbqzGzHIxt47HAuc2MuwWB8v8fcuqSCwQ4puNLeaZTgJxmNVknUdJRi9Vn(Me3XiHBXL9jjnzlPWIfB8LLfaqGcILZsf)H6SKayU1y8Iz0KyzNnDZRvr6FB8njUJrc3Il7tsAYwsPqGGavTqnaZrDHAPC0gutM9MwolfcuqSCwQGmQRtkhT9sKg5sDJ3LeUI0)(X9EbzuxNuoAtqTGaOSfw2IUMnHLNSZg3n5h1KleOGy5SubzuxNuoAdJxmjsJCPUX7scxr6FL7J79IJuPI2nENVhQjA(mYL(4TMCbi5EIbzg1DKScFputc29j15XBSfnhxSLPyXpU3losLkA34D(EOMO5Zix6JgFzHLNSZghaKP8h37fhPsfTB8oFputGFabkiwolvqg11jLJ2W4ftI0ixQB8UKWvK(3pU3losLkA34D(EOMO5Zix6JQV8h37f4R0rHTJAnV1MurZNrU0h1Klaj3tmiZOUJKv47HAsWUpPopEJTO54ITmL)4EVaFLokSDuR5T2KkA(mYLw(J79IJuPI2nENVhQjWpGabbkiwolvqMrDhjl9fNYU04tAfP)voYmQ7izfhPsfTB8oFput0CCXUyrYmQ7izfhPsfTB8oFput08zKlv2skvMYYbmlu8AIFZHj1nEhn3Bh1dne8gFfFlwKmJ6oswbFEms4214l7KWXXSIMpJCPYcWlugiqbXYzPcYmQ7izPy8IjoLDPXNvSXj)2rvx8fqQ7N1UMVUpUzZcbkiwolvqMrDhjlfJxmXPSln(SIno53tUzanPb15JTUI0)cS7yIFZHj1nEhn3Bh1dnewsam36Ya7J79IJuPI2nENVhQjWpGafelNLkiZOUJKLIXlMhJLZwr6F)4EV4ivQODJ357HAc8JYFCVxWNhJeUDn(YojCCmRa)acuqSCwQGmJ6oswkgVy(vZCDE8g7ks)7h37fhPsfTB8oFputGFu(J79c(8yKWTRXx2jHJJzf4hqGcILZsfKzu3rYsX4fZp3uUbm36ks)7h37fhPsfTB8oFputGFabQAH6kzpudQjZOUJKLcbkiwolvqMrDhjlfJxmpsLkA34D(EOwfP)LmJ6oswbFEms4214l7KWXXSIMpJCPqGcILZsfKzu3rYsX4fZFZHj1nEhn3Bh1dnQi9VKzu3rYk4ZJrc3UgFzNeooMv08zKlTmzg1DKSIJuPI2nENVhQjA(mYLcbkiwolvqMrDhjlfJxm5ZJrc3UgFzNeooMTI0)sMrDhjR4ivQODJ357HAIMJl2LbMfkEnXV5WK6gVJM7TJ6HgcEJVIVLB8LfwEYoBCfkBn5wUX3K4ogjClUSpjPj77Zslw0IUMnHLNSZg3n5hLukeOGy5Subzg1DKSumEXKppgjC7A8LDs44y2ks)RCKzu3rYkosLkA34D(EOMO54IDXIw01SjS8KD24Uj)OKsLPSfkEnXV5WK6gVJM7TJ6HgcEJVIVLB8LL9faLB8njUJrc3YwPlfcuqSCwQGmJ6oswkgVyscLYfelN1PsQvXgN8lzuxNuoARI0)AHIxtqg11jLJ2e8gFfFllNCFCVxqg11jLJ2euliak77ZslF5pU3l6OQPtclOwqa8Tqzkw0IUMnHLNSZg3n5hV1KRmqGcILZsfKzu3rYsX4ftFputc29j15XBSRi9VY9X9EXrQur7gVZ3d1enFg5sF8wtUflk3h37fhPsfTB8oFput08zKl9r1x(J79c8v6OW2rTM3AtQO5Zix6J3AYT8h37f4R0rHTJAnV1Mub(HmYu(J79IJuPI2nENVhQjWpGafelNLkiZOUJKLIXlM(EOMeS7tQZJ3yxr6FTORzty5j7SXDt(rn5wSOCw01SjS8KD24Uj)GmJ6oswXrQur7gVZ3d1enFg5sl)X9Eb(kDuy7OwZBTjvGFideiiqvluxP6RsJ7WYzH6ESWYzHafelNLkMVknUdlN9T5ZPPSIPuNKCnURi9VwO41e1HjL7CRDuB6tbVXxXxiqbXYzPI5RsJ7WYzX4fZ5RsJ7W4kSORzZL(x5U8h37fDu10jHfulia(OWIfV8h37fDu10jHfnFg5sF8Suzkdmlu8AcFpuJsW2KYcEJVIVLb2h37fDEYc8JY0dwPCw01SrfshjQCRDFvqnzFbaeOGy5SuX8vPXDy5Sy8I58vPXDyCfP)fywO41e(EOgLGTjLf8gFfFldSpU3l68Kf4hLPhSs5SORzJkKosu5w7(QGAY(caiqbXYzPI5RsJ7WYzX4ftFpuJsW2KYvK(x5(4EVaWuPYT2DgeP5YIMdIvSOCFCVxayQu5w7odI0Czb(rz5oAg4UAYv8u47HAoQ1jGCXIhndCxn5kEkKosu5w7(QGAflE0mWD1KR4POwfKmuU4c8yjSmYitz6bRuol6A2OcFpuJsW2KYY(wceOGy5SuX8vPXDy5Sy8I58vPXDyCfw01S5s)RCx(J79IoQA6KWcQfeaFuyXIx(J79IoQA6KWIMpJCPpEwQmL)4EVaWuPYT2DgeP5YIMdIvSOCFCVxayQu5w7odI0Czb(rz5oAg4UAYv8u47HAoQ1jGCXIhndCxn5kEkKosu5w7(QGAflE0mWD1KR4POwfKmuU4c8yjSmYabkiwolvmFvAChwolgVyoFvAChgxr6F)4EVaWuPYT2DgeP5YIMdIvSOCFCVxayQu5w7odI0Czb(rz5oAg4UAYv8u47HAoQ1jGCXIhndCxn5kEkKosu5w7(QGAflE0mWD1KR4POwfKmuU4c8yjSmYabkiwolvmFvAChwolgVywRcsgkxCbESeUI0)khW(4EVOZtwGFuSyJVjXDms4wCzFss7XZslwSXxwy5j7SXvIS1KRmLPhSs5SORzJkQvbjdLlUapwcl7BjqGcILZsfZxLg3HLZIXlMshjQCRDFvqTks)7h37fDEYc8JY0dwPCw01SrfshjQCRDFvqnzFlbcuqSCwQy(Q04oSCwmEX03d1CuRta5kSORzZL(x5U8h37fDu10jHfulia(OWIfV8h37fDu10jHfnFg5sF8SuzkdSpU3l68Kf4hfl24BsChJeUfx2NK0E8S0IfB8LfwEYoBCLiBn5wgywO41e(EOgLGTjLf8gFfFHafelNLkMVknUdlNfJxm99qnh16eqUI0)cSpU3l68Kf4hfl24BsChJeUfx2NK0E8S0IfB8LfwEYoBCLiBn5cbkiwolvmFvAChwolgVykDKOYT29vb1Qi9VFCVx05jlWpGafelNLkMVknUdlNfJxmNVknUdJRWIUMnx6FL7YFCVx0rvtNewqTGa4Jclw8YFCVx0rvtNew08zKl9XZsLPmWSqXRj89qnkbBtkl4n(k(cbkiwolvmFvAChwolgVyoFvAChgdbccu1c1GwS3OVqnn3AfxnTORzdQ7XclNfcuqSCwQGAXEJ((2850uwXuQtsUg3qGcILZsful2B0xmEX03d1CuRta5ks)lzg1DKSIMpNMYkMsDsY14w08zKl9XBjaun5w2cfVMOomPCNBTJAtFk4n(k(cbkiwolvqTyVrFX4ftPJevU1UVkOwfP)9J79Iopzb(beOGy5Sub1I9g9fJxmNVknUdJRi9Va7J79cFpvXR7axrzb(rzlu8AcFpvXR7axrzbVXxXxiqbXYzPcQf7n6lgVy67HAoQ1jGCfP)TX3K4ogjClUSpjP9qUNfIHfkEnrJVjXfMXlEy5ScEJVIVaeaKbcuqSCwQGAXEJ(IXlM(EOgLGTjLRi9VFCVxayQu5w7odI0Czb(r5gFzHLNSZgxLL9TMCHafelNLkOwS3OVy8I58vPXDyCfP)TX3K4ogjClUSpjPjRCLuigwO41en(MexygV4HLZk4n(k(cqaqgiqbXYzPcQf7n6lgVy67HAoQ1jGmeOGy5Sub1I9g9fJxmLo96gVtsUg3qGcILZsful2B0xmEXmAsSSZMU51qG0dMGKVKcFImKHqa]] )

    
end
