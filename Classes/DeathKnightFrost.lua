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
        resource = "runes",

        reset = function()
            local t = state.runes

            for i = 1, 6 do
                local start, duration, ready = GetRuneCooldown( i )

                start = start or 0
                duration = duration or ( 10 * state.haste )
                
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

            state.gain( amount * 10, "runic_power" )

            if state.talent.gathering_storm.enabled and state.buff.remorseless_winter.up then
                state.buff.remorseless_winter.expires = state.buff.remorseless_winter.expires + ( 0.5 * amount )
            end

            t.actual = nil
        end,

        timeTo = function( x )
            return state:TimeToResource( state.runes, x )
        end,
    }, {
        __index = function( t, k, v )
            if k == 'actual' then
                local amount = 0

                for i = 1, 6 do
                    if t.expiry[ i ] <= state.query_time then
                        amount = amount + 1
                    end
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

            elseif k == 'deficit' then
                return t.max - t.current
            
            elseif k == 'time_to_next' then
                return t[ 'time_to_' .. t.current + 1 ]

            elseif k == 'time_to_max' then
                return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

            elseif k == 'add' then
                return t.gain

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

            stop = function ( x ) return x < 16 end,

            interval = 1,
            value = -16
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

    local spendHook = function( amt, resource, noHook )
        if amt > 0 and resource == "runic_power" and buff.breath_of_sindragosa.up and runic_power.current < 16 then
            removeBuff( "breath_of_sindragosa" )
            gain( 2, "runes" )
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
        hypothermic_presence = 22533, -- 321995
        glacial_advance = 22535, -- 194913

        icecap = 22023, -- 207126
        obliteration = 22109, -- 281238
        breath_of_sindragosa = 22537, -- 152279
    } )


    spec:RegisterPvpTalents( { 
        cadaverous_pallor = 3515, -- 201995
        chill_streak = 706, -- 305392
        dark_simulacrum = 3512, -- 77606
        dead_of_winter = 3743, -- 287250
        deathchill = 701, -- 204080
        delirium = 702, -- 233396
        dome_of_ancient_shadow = 5369, -- 328718
        heartstop_aura = 3439, -- 199719
        necrotic_aura = 43, -- 199642
        transfusion = 3749, -- 288977
    } )


    -- Auras
    spec:RegisterAuras( {
        antimagic_shell = {
            id = 48707,
            duration = 5,
            max_stack = 1,
        },
        antimagic_zone = {
            id = 145629,
            duration = 3600,
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
        death_and_decay = {
            id = 43265,
            duration = 10,
            max_stack = 1,
        },
        death_pact = {
            id = 48743,
            duration = 15,
            max_stack = 1,
        },
        deaths_advance = {
            id = 48265,
            duration = 10,
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
        frost_shield = {
            id = 207203,
            duration = 10,
            max_stack = 1,
        },
        frostwyrms_fury = {
            id = 279303,
            duration = 10,
            type = "Magic",
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
        hypothermic_presence = {
            id = 321995,
            duration = 8,
            max_stack = 1,
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
        lichborne = {
            id = 49039,
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
        wraith_walk = {
            id = 212552,
            duration = 4,
            type = "Magic",
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


        antimagic_zone = {
            id = 51052,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,
            texture = 237510,
            
            handler = function ()
                applyBuff( "antimagic_zone" )
            end,
        },


        asphyxiate = {
            id = 108194,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 538558,

            toggle = "interrupts",

            talent = "asphyxiate",

            debuff = "casting",
            readyTime = state.timeToInterrupt,            

            handler = function ()
                applyDebuff( "target", "asphyxiate" )
                interrupt()
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

            spend = 16,
            readySpend = function () return settings.bos_rp end,
            spendType = "runic_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1029007,

            handler = function ()
                gain( 2, "runes" )
                applyBuff( "breath_of_sindragosa" )
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


        chill_streak = {
            id = 305392,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "chill_streak"
            end,

            handler = function ()
                applyDebuff( "target", "chilled" )
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

            startsCombat = false,
            texture = 237273,

            usable = function () return target.is_undead and target.level <= level + 1, "requires undead target up to 1 level above player" end,
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


        death_and_decay = {
            id = 43265,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = true,
            texture = 136144,
            
            handler = function ()
                -- applies death_and_decay (188290)
            end,
        },
        

        death_coil = {
            id = 47541,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return ( buff.hypothermic_presence.up and 0.65 or 1 ) * 40 end,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 136145,
            
            handler = function ()
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
            cooldown = 25,
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

            toggle = "defensives",

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

            spend = function () return buff.dark_succor.up and 0 or ( ( ( buff.transfusion.up and 0.5 or 1 ) * 35 ) * ( buff.hypothermic_presence.up and 0.65 and 1 ) ) end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237517,

            handler = function ()
                gain( health.max * 0.10, "health" )
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
            charges = 1,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 55 and 105 or 120 ) end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( level > 55 and 105 or 120 ) end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135372,

            nobuff = "empower_rune_weapon",

            handler = function ()
                stat.haste = state.haste + 0.15
                gain( 1, "runes" )
                gain( 5, "runic_power" )
                applyBuff( "empower_rune_weapon" )
            end,

            copy = "empowered_rune_weapon" -- typo often in SimC APL.
        },


        frost_strike = {
            id = 49143,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.hypothermic_presence.up and 0.65 or 1 ) * 25 end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237520,

            handler = function ()
                applyDebuff( "target", "razorice", 20, 2 )                
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

            range = 7,

            handler = function ()
                removeBuff( "killing_machine" )
                removeStack( "inexorable_assault" )
            end,
        },


        frostwyrms_fury = {
            id = 279302,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 341980,

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

            spend = function () return ( buff.hypothermic_presence.up and 0.65 or 1 ) * 30 end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 537514,

            handler = function ()
                applyDebuff( "target", "razorice", nil, 1 )
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
                -- if pvptalent.delirium.enabled then applyDebuff( "target", "delirium" ) end

                removeBuff( "rime" )
            end,
        },


        hypothermic_presence = {
            id = 321995,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236224,
            
            handler = function ()
                applyBuff( "hypothermic_presence" )
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
            id = 49039,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 136187,

            toggle = "defensives",

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


        raise_dead = {
            id = 46585,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1100170,
            
            handler = function ()
                summonPet( "ghoul" )
            end,
        },


        remorseless_winter = {
            id = 196770,
            cast = 0,
            cooldown = function () return pvptalent.dead_of_winter.enabled and 45 or 20 end,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = false,
            texture = 538770,

            range = 7,

            handler = function ()
                applyBuff( "remorseless_winter" )
                -- if pvptalent.deathchill.enabled then applyDebuff( "target", "deathchill" ) end
            end,
        },


        sacrificial_pact = {
            id = 327574,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = 20,
            spendType = "runic_power",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136133,
            
            handler = function ()
                -- applies unholy_strength (53365)
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


        wraith_walk = {
            id = 212552,
            cast = 4,
            channeled = true,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1100041,
            
            start = function ()
                applyBuff( "wraith_walk" )
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

        potion = "potion_of_unbridled_fury",

        package = "Frost DK",
    } )


    spec:RegisterSetting( "bos_rp", 50, {
        name = "Runic Power for |T1029007:0|t Breath of Sindragosa",
        desc = "The addon will recommend |T1029007:0|t Breath of Sindragosa only if you have this much Runic Power (or more).",
        icon = 1029007,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 16,
        max = 100,
        step = 1,
        width = 1.5
    } )

    
    spec:RegisterPack( "Frost DK", 20200828, [[dKKQtcqirfpciv2ePYOebNseAvIkPxjImlrIBbKsTle)suQHjQQJPuAzIcptKKPjskxtuLTbKQ(gqkzCIkvNtKu16evkY8aI7bO9jk6GaPOwOivpuuPWebsr6IIKkSrGuyKIkfLtksQOvIQQxkQuk3uKuj2PiQFkQuunursLAPIkLQNIktvKYxbsrSxk(lrdMshMQfRQEmstwjxgAZK8zagnqDAjRwuPKxJQYSr52kv7wLFRy4KYXfvILl1ZjmDHRRkBhi57KQgViPs68kfRxuY8rv2pOnBnPz4wEGMKZi)mYp)CpJCNSnvzK7zK7gUyJgA40CkFoa0WD(oA4an6reqlOP52mCA(g24ltAgoX8AkA4ahHMi3u2zdOcWVpHo7zlQ9hZJAoA7QiBrTtZ2W9FflsDEMVHB5bAsoJ8Zi)8Z9mYDY2uLrUVf0B48xaEAdhxTNBy4axRfEMVHBHcQHd0bTGg9icOf0u0dWqBUTRaaoG8d6GwqZpapraTzK7PaTzKFg5d5hYpOdAZna7hauKBcYpOdAbTH2uNhL9wi0M6sDlOf0OrmlKa5h0bTG2qlO51cAvoJ9DkFqRAAO9jQda0M6i3oOjPaTPUhqdOTuqRgZ3Gn0wxfLhOaAtF4G2pQMgHwTzy1baAzdGIcTLaAPZUgddCrG8d6GwqBOn3aSFaqOn8gagKO2rzmYvHqBmqBu7Omg5QqOngO9jqOfp68UaBOLHhGam02EagBOna7h0QnbEr5mOnAxagAxOhGfei)GoOf0gAZng2cAZnd9oGw)wqB70YzqBOhD(eedhReHWKMHJoSLem6DysZK8wtAgo88pdxM0nC0UcSl3W9FkfHoSLem6DqeHt5dAZeAZdA1bTrTJYyKRcHwqGwa0LHZPrnNHJc2RtihLSOOjmjNHjndhE(NHlt6goAxb2LB4saA)pLIiqmaxhaz7aqsJ7EDcOfeOfaDbTjcT6G2)tPicedW1bq2oaK80mConQ5mCuWEDc5OKffnHj5uzsZWHN)z4YKUHJ2vGD5gUeG2)tPiAfJ5TCusvpIG04UxNaAbbi0cGUG2CfAtaA3cTjbT0zyRr)ru9ic9B6DHu96nKg91gOnrOLhpO9)ukIwXyElhLu1JiinU71jGwqG2(DijQDugJmvqBIqRoO9)ukIwXyElhLu1JiipnOvh0Ma06zHDfiPOBK0k8fYiTF8bTGaeA3cT84bT)Nsr(n6by5OKI6wTdyeo5PbTjcT6G2CG2Wz4fKIIuxJGN)z4YW50OMZWrb71jKJswu0eMKtntAgo88pdxM0nC0UcSl3W9FkfrRymVLJsQ6reKg396eqliqBUdT6G2)tPiVd8W2ifrJhGamPXDVob0cc0cGUG2CfAtaA3cTjbT0zyRr)ru9ic9B6DHu96nKg91gOnrOvh0(Fkf5DGh2gPiA8aeGjnU71jGwDq7)PueTIX8wokPQhrqEAqRoOnbO1Zc7kqsr3iPv4lKrA)4dAbbi0UfA5XdA)pLI8B0dWYrjf1TAhWiCYtdAteA1bT5aTHZWliffPUgbp)ZWLHZPrnNHJc2RtihLSOOjmjNNjndhE(NHlt6goAxb2LB4saA)pLIu0nsAf(czKg396eqliqBQbT84bT)Nsrk6gjTcFHmsJ7EDcOfeOTFhsIAhLXitf0Mi0QdA)pLIu0nsAf(czKNg0QdA9SWUcKu0nsAf(czK2p(G2mbcTzaT6G2CG2)tPi)g9aSCusrDR2bmcN80GwDqBoqB4m8csrrQRrWZ)mCz4CAuZz4OG96eYrjlkActYGEtAgo88pdxM0nC0UcSl3W9FkfPOBK0k8fYipnOvh0(Fkf5DGh2gPiA8aeGjpnOvh06zHDfiPOBK0k8fYiTF8bTzceAZaA1bT5aT)Nsr(n6by5OKI6wTdyeo5PbT6G2CG2Wz4fKIIuxJGN)z4YW50OMZWrb71jKJswu0eMKbTmPz4WZ)mCzs3Wr7kWUCd3)PueTIX8wokPQhrqAC3RtaTGaTPg0QdA)pLIOvmM3Yrjv9icYtdA1bTHZWliffPUgbp)ZWf0QdA)pLIqh2scg9oiIWP8bTzceA3M7qRoO1Zc7kqsr3iPv4lKrA)4dAbbi0U1W50OMZWrb71jKJswu0eMKZDtAgo88pdxM0nC0UcSl3W9FkfrRymVLJsQ6reKNg0QdAdNHxqkksDncE(NHlOvh06zHDfiPOBK0k8fYiTF8bTzceAZaA1bTjaT)NsrOdBjbJEher4u(G2mbcTBt9qRoO9)uksr3iPv4lKrAC3RtaTGaTaOlOvh0(FkfPOBK0k8fYipnOLhpO9)ukY7apSnsr04biatEAqRoO9)ukcDyljy07GicNYh0MjqODBUdTjA4CAuZz4OG96eYrjlkActy4MpRcS9OMZKMj5TM0mC45FgUmPB4ODfyxUHlCgEbbGhGXUoasrm9obp)ZWLHZPrnNHRX9PfidfcP(6cSnHj5mmPz4WZ)mCzs3W50OMZWnFwfy7bA4ODfyxUHlbODH)NsrApRPlkseHt5dAbbAZdA5XdAx4)PuK2ZA6IIKg396eqliq728H2eHwDqBoqB4m8cIQhriOBcWibp)ZWf0QdAZbA)pLI01osEAqRoOvOHmMm8gagcc4rpRoaYpZfb0MjqOnvgo6gkdLH3aWqysERjmjNktAgo88pdxM0nC0UcSl3WLd0godVGO6rec6MamsWZ)mCbT6G2CG2)tPiDTJKNg0QdAfAiJjdVbGHGaE0ZQdG8ZCraTzceAtLHZPrnNHB(SkW2d0eMKtntAgo88pdxM0nC0UcSl3WLa0(FkfHVIXQdGC3PGRdjn60aA5XdAtaA)pLIWxXy1bqU7uW1HKNg0QdAtaA1Aeusa0fzlr1JiKIOl(qOLhpOvRrqjbqxKTeWJEwDaKFMlcOLhpOvRrqjbqxKTeamNwot6lq5hfH2eH2eH2eHwDqRqdzmz4nameevpIqq3eGrOntGqBggoNg1CgovpIqq3eGrtysoptAgo88pdxM0nConQ5mCZNvb2EGgoAxb2LB4saAx4)PuK2ZA6IIer4u(GwqG28GwE8G2f(FkfP9SMUOiPXDVob0cc0UnFOnrOvh0(FkfHVIXQdGC3PGRdjn60aA5XdAtaA)pLIWxXy1bqU7uW1HKNg0QdAtaA1Aeusa0fzlr1JiKIOl(qOLhpOvRrqjbqxKTeWJEwDaKFMlcOLhpOvRrqjbqxKTeamNwot6lq5hfH2eH2enC0nugkdVbGHWK8wtysg0BsZWHN)z4YKUHJ2vGD5gU)tPi8vmwDaK7ofCDiPrNgqlpEqBcq7)Pue(kgRoaYDNcUoK80GwDqBcqRwJGscGUiBjQEeHueDXhcT84bTAnckja6ISLaE0ZQdG8ZCraT84bTAnckja6ISLaG50YzsFbk)Oi0Mi0MOHZPrnNHB(SkW2d0eMKbTmPz4WZ)mCzs3Wr7kWUCdxcqBoq7)PuKU2rYtdA5XdA73vuP2OhBYcvfTcOfeODB(qlpEqB)oKe1okJrMb0Mj0cGUG2eHwDqRqdzmz4nameeamNwot6lq5hfH2mbcTzy4CAuZz4aWCA5mPVaLFu0eMKZDtAgo88pdxM0nC0UcSl3W9FkfPRDK80GwDqRqdzmz4nameeWJEwDaKFMlcOntGqBggoNg1CgoWJEwDaKFMlctyso1BsZWHN)z4YKUHZPrnNHt1JiKIOl(qdhTRa7YnCjaTl8)uks7znDrrIiCkFqliqBEqlpEq7c)pLI0EwtxuK04UxNaAbbA3Mp0Mi0QdAZbA)pLI01osEAqlpEqB)UIk1g9ytwOQOvaTGaTBZhA5XdA73HKO2rzmYmG2mHwa0f0QdAZbAdNHxqu9icbDtagj45FgUmC0nugkdVbGHWK8wtysEB(M0mC45FgUmPB4ODfyxUHlhO9)uksx7i5PbT84bT97kQuB0JnzHQIwb0cc0UnFOLhpOTFhsIAhLXiZaAZeAbqxgoNg1CgovpIqkIU4dnHj5TBnPz4WZ)mCzs3Wr7kWUCd3)PuKU2rYtZW50OMZWbE0ZQdG8ZCryctYBZWKMHdp)ZWLjDdNtJAod38zvGThOHJ2vGD5gUeG2f(FkfP9SMUOireoLpOfeOnpOLhpODH)NsrApRPlksAC3RtaTGaTBZhAteA1bT5aTHZWliQEeHGUjaJe88pdxgo6gkdLH3aWqysERjmjVnvM0mConQ5mCZNvb2EGgo88pdxM0nHjmC)riJIYxDamPzsERjndhE(NHlt6goAxb2LB4OZWwJ(JG7AJESL97qPE01MJ04UxNWW50OMZWPvmM3Yrjv9ictysodtAgoNg1CgoCxB0JTSFhk1JU2Cgo88pdxM0nHj5uzsZWHN)z4YKUHZPrnNHB(SkW2d0Wr7kWUCdxcq7c)pLI0EwtxuKicNYh0cc0Mh0YJh0UW)tPiTN10ffjnU71jGwqG2T5dTjcT6G2(DfvQn6XgAbbi0MQmGwDqBoqB4m8cIQhriOBcWibp)ZWLHJUHYqz4nameMK3ActYPMjndhE(NHlt6goAxb2LB463vuP2OhBOfeGqBQYWW50OMZWnFwfy7bActY5zsZWHN)z4YKUHJ2vGD5gUWz4feaEag76aifX07e88pdxgoNg1CgUg3NwGmuiK6RlW2eMKb9M0mC45FgUmPB4ODfyxUH7)uksx7i5Pz4CAuZz4ap6z1bq(zUimHjzqltAgo88pdxM0nConQ5mCZNvb2EGgoAxb2LB4saAx4)PuK2ZA6IIer4u(GwqG28GwE8G2f(FkfP9SMUOiPXDVob0cc0UnFOnrOvh02VdjrTJYyK5bTGaTaOlOLhpOTFxrLAJESHwqacTPwEqRoOnhOnCgEbr1Jie0nbyKGN)z4YWr3qzOm8gagctYBnHj5C3KMHdp)ZWLjDdhTRa7YnC97qsu7OmgzEqliqla6cA5XdA73vuP2OhBOfeGqBQLNHZPrnNHB(SkW2d0eMKt9M0mC45FgUmPB4ODfyxUH7)ukcFfJvha5UtbxhsEAqRoOvOHmMm8gagcIQhriOBcWi0MjqOnddNtJAodNQhriOBcWOjmjVnFtAgo88pdxM0nC0UcSl3W1VROsTrp2KfQkAfqBMaH2uLb0QdA73HKO2rzmYubTzcTaOldNtJAodh4Pp5OK6RlW2eMK3U1KMHZPrnNHRX9PfidfcP(6cSnC45FgUmPBctYBZWKMHdp)ZWLjDdhTRa7YnCcnKXKH3aWqqu9icbDtagH2mbcTzy4CAuZz4u9icbDtagnHj5TPYKMHdp)ZWLjDdNtJAod38zvGThOHJ2vGD5gUeG2f(FkfP9SMUOireoLpOfeOnpOLhpODH)NsrApRPlksAC3RtaTGaTBZhAteA1bT97kQuB0JnzHQIwb0Mj0MrEqlpEqB)oeAZeAtf0QdAZbAdNHxqu9icbDtagj45FgUmC0nugkdVbGHWK8wtysEBQzsZWHN)z4YKUHJ2vGD5gU(DfvQn6XMSqvrRaAZeAZipOLhpOTFhcTzcTPYW50OMZWnFwfy7bActYBZZKMHdp)ZWLjDdhTRa7YnC97kQuB0JnzHQIwb0Mj0Mx(goNg1CgoVP(HYy6gVWeMWWHcbEuuysZK8wtAgo88pdxM0nC0UcSl3W9FkfrRymVLJsQ6reKNg0QdAtaA)pLIOvmM3Yrjv9icsJ7EDcOfeODB(qRoOnbO9)ukYVrpalhLuu3QDaJWjpnOLhpOnCgEbz(SkW2JAocE(NHlOLhpOnCgEbPOi11i45FgUGwDqBoqRNf2vGKIUrsRWxiJGN)z4cAteA5XdA)pLIu0nsAf(czKNg0QdAdNHxqkksDncE(NHlOnrOvh0Ma060OafkXd3luaTaH2TqlpEqBoqB4m8csrrQRrWZ)mCbTjcT84bTonkqHs8W9cfqBMaH2mGwDqB4m8csrrQRrWZ)mCbT6Gw6mS1O)iAfJ5TCusvpIG0OV2aT6G2eGwplSRajfDJKwHVqgP9JpOntGq7wOvh0(FkfPOBK0k8fYipnOLhpOnhO1Zc7kqsr3iPv4lKrWZ)mCbTjA4CAuZz4(SzwYrjdWOepCFJjmjNHjndhE(NHlt6goAxb2LB4YbAdNHxqkksDncE(NHlOLhpOnCgEbPOi11i45FgUGwDqRNf2vGKIUrsRWxiJGN)z4cA1bT)Nsr0kgZB5OKQEebPXDVob0cc0c6HwDq7)PueTIX8wokPQhrqEAqlpEqB4m8csrrQRrWZ)mCbT6G2CGwplSRajfDJKwHVqgbp)ZWLHZPrnNHdWZ7v5NCusplSNaSjmjNktAgo88pdxM0nC0UcSl3W9FkfrRymVLJsQ6reKg396eqliqBEqRoO9)ukIwXyElhLu1JiipnOLhpOnQDugJCvi0cc0MNHZPrnNHJcUymPiA05ZeMKtntAgo88pdxM0nC0UcSl3W9FkfPrkFmuiKQPPi5PbT84bT)NsrAKYhdfcPAAkkPZ7cSjIWP8bTGaTB3A4CAuZz4cWO8D)5DlPAAkActY5zsZWHN)z4YKUHJ2vGD5gUCG2)tPiAfJ5TCusvpIG80GwDqBoq7)PuKFJEawokPOUv7agHtEAgoNg1Cgo1qFcCj9SWUcu(rF3eMKb9M0mC45FgUmPB4ODfyxUHlhO9)ukIwXyElhLu1JiipnOvh0Md0(Fkf53OhGLJskQB1oGr4KNg0QdAxtqOZrXlApWLuX8Du(F9rAC3RtaTaH28nConQ5mC05O4fTh4sQy(oActYGwM0mC45FgUmPB4ODfyxUH7)ukIwXyElhLu1JiipnOLhpO9)ukcURn6Xw2VdL6rxBoYtdA5XdAPZWwJ(J8B0dWYrjf1TAhWiCsJ7EDcOntOf0Np0Me0UnpOLhpOLoD)0IAobPouP8pdLr)cWe88pdxgoNg1Cgo9tZwGcRt2Oyo)OOjmjN7M0mC45FgUmPB4ODfyxUHlhO9)ukIwXyElhLu1JiipnOvh0Md0(Fkf53OhGLJskQB1oGr4KNMHZPrnNHRlnngkRtk0CkActYPEtAgo88pdxM0nC0UcSl3W9Fkfb31g9yl73Hs9ORnhPXDVob0cc0Mh0QdA)pLI8B0dWYrjf1TAhWiCYtdA5XdAtaA73HKO2rzmYmG2mHwa0f0QdA73vuP2OhBOfeOnV8H2enConQ5mC74(0BKJsYE0Ajxn67ctysEB(M0mConQ5mCn6A1bqQy(okmC45FgUmPBcty4(JqQndRoaM0mjV1KMHdp)ZWLjDdhTRa7YnC)Nsr6AhjpndNtJAodh4rpRoaYpZfHjmjNHjndhE(NHlt6goNg1CgU5ZQaBpqdhTRa7YnCjaTl8)uks7znDrrIiCkFqliqBEqlpEq7c)pLI0EwtxuK04UxNaAbbA3Mp0Mi0QdA73vuP2OhBYcvfTcOntGqBg5bT6G2CG2Wz4fevpIqq3eGrcE(NHldhDdLHYWBayimjV1eMKtLjndhE(NHlt6goAxb2LB463vuP2OhBYcvfTcOntGqBg5z4CAuZz4MpRcS9anHj5uZKMHdp)ZWLjDdhTRa7YnC97kQuB0JnzHQIwb0cc0Mr(qRoOvOHmMm8gagccaMtlNj9fO8JIqBMaH2mGwDqlDg2A0FeTIX8wokPQhrqAC3RtaTzcT5z4CAuZz4aWCA5mPVaLFu0eMKZZKMHdp)ZWLjDdNtJAodNQhrifrx8HgoAxb2LB4saAx4)PuK2ZA6IIer4u(GwqG28GwE8G2f(FkfP9SMUOiPXDVob0cc0UnFOnrOvh02VROsTrp2KfQkAfqliqBg5dT6G2CG2Wz4fevpIqq3eGrcE(NHlOvh0sNHTg9hrRymVLJsQ6reKg396eqBMqBEgo6gkdLH3aWqysERjmjd6nPz4WZ)mCzs3Wr7kWUCdx)UIk1g9ytwOQOvaTGaTzKp0QdAPZWwJ(JOvmM3Yrjv9icsJ7EDcOntOnpdNtJAodNQhrifrx8HMWKmOLjndhE(NHlt6goAxb2LB4(pLIWxXy1bqU7uW1HKNg0QdA73vuP2OhBYcvfTcOntOnbODBEqBsqB4m8cs)UIk9iW75rnhbp)ZWf0MRqBQG2eHwDqRqdzmz4nameevpIqq3eGrOntGqBggoNg1CgovpIqq3eGrtyso3nPz4WZ)mCzs3Wr7kWUCdx)UIk1g9ytwOQOvaTzceAtaAtvEqBsqB4m8cs)UIk9iW75rnhbp)ZWf0MRqBQG2eHwDqRqdzmz4nameevpIqq3eGrOntGqBggoNg1CgovpIqq3eGrtyso1BsZWHN)z4YKUHZPrnNHB(SkW2d0Wr7kWUCdxcq7c)pLI0EwtxuKicNYh0cc0Mh0YJh0UW)tPiTN10ffjnU71jGwqG2T5dTjcT6G2(DfvQn6XMSqvrRaAZei0Ma0MQ8G2KG2Wz4fK(Dfv6rG3ZJAocE(NHlOnxH2ubTjcT6G2CG2Wz4fevpIqq3eGrcE(NHldhDdLHYWBayimjV1eMK3MVjndhE(NHlt6goAxb2LB463vuP2OhBYcvfTcOntGqBcqBQYdAtcAdNHxq63vuPhbEppQ5i45FgUG2CfAtf0MOHZPrnNHB(SkW2d0eMK3U1KMHdp)ZWLjDdhTRa7YnC0zyRr)r0kgZB5OKQEebPXDVob0Mj02VdjrTJYyKPg0QdA73vuP2OhBYcvfTcOfeOn1YhA1bTcnKXKH3aWqqaWCA5mPVaLFueAZei0MHHZPrnNHdaZPLZK(cu(rrtysEBgM0mC45FgUmPB4CAuZz4u9icPi6Ip0Wr7kWUCdxcq7c)pLI0EwtxuKicNYh0cc0Mh0YJh0UW)tPiTN10ffjnU71jGwqG2T5dTjcT6Gw6mS1O)iAfJ5TCusvpIG04UxNaAZeA73HKO2rzmYudA1bT97kQuB0JnzHQIwb0cc0MA5dT6G2CG2Wz4fevpIqq3eGrcE(NHldhDdLHYWBayimjV1eMK3MktAgo88pdxM0nC0UcSl3WrNHTg9hrRymVLJsQ6reKg396eqBMqB)oKe1okJrMAqRoOTFxrLAJESjluv0kGwqG2ulFdNtJAodNQhrifrx8HMWegoTgPZ(3dtAMK3AsZW50OMZWPnrnNHdp)ZWLjDtysodtAgo88pdxM0nCNVJgoplbyVDHunxihLuB0JTHZPrnNHZZsa2BxivZfYrj1g9yBctYPYKMHdp)ZWLjDd3Oz4eyy4CAuZz4aL3L)zOHduo7HgUeGwmxELMgUi3etxZtibW8v5X0c53xaqOLhpOfZLxPPHlcD6(Pf4scG5RYJPfYVVaGqlpEqlMlVstdxe609tlWLeaZxLhtlK74YzSAoOLhpOfZLxPPHlcOkNjhL0VA3dCj)SzwqlpEqlMlVstdxev1IqU7bkKcTnayUqaT84bTyU8knnCrYTqHe8ONHn0YJh0I5YR00Wf5My6AEcjaMVkpMwi3XLZy1CqlpEqlMlVstdxexagu(Hcz7znTKoTZG2enCGYB557OHBcWylNt(eOeZLxPPHltycdhDg2A0FctAMK3AsZWHN)z4YKUHZPrnNHZZsa2BxivZfYrj1g9yB4ODfyxUHlbOLodBn6pcURn6Xw2VdL6rxBosJ(Ad0QdAZbAbL3L)zizcWylNt(eOeZLxPPHlOnrOLhpOnbOLodBn6pIwXyElhLu1JiinU71jGwqacTBZhA1bTGY7Y)mKmbySLZjFcuI5YR00Wf0MOH78D0W5zja7TlKQ5c5OKAJESnHj5mmPz4WZ)mCzs3W50OMZWXEnFylK1jQvnpHeqPcdhTRa7YnCHZWli)g9aSCusrDR2bmcNGN)z4cA1bTjaTjaT0zyRr)r0kgZB5OKQEebPXDVob0ccqODB(qRoOfuEx(NHKjaJTCo5tGsmxELMgUG2eHwE8G2eG2)tPiAfJ5TCusvpIG80GwDqBoqlO8U8pdjtagB5CYNaLyU8knnCbTjcTjcT84bTjaT)Nsr0kgZB5OKQEeb5PbT6G2CG2Wz4fKFJEawokPOUv7agHtWZ)mCbTjA4oFhnCSxZh2czDIAvZtibuQWeMKtLjndhE(NHlt6goNg1Cgo6gkBIEUIk)mxegoAxb2LB4YbA)pLIOvmM3Yrjv9icYtZWD(oA4OBOSj65kQ8ZCryctYPMjndhE(NHlt6goAxb2LB4saAPZWwJ(JOvmM3Yrjv9icsJ(Ad0YJh0sNHTg9hrRymVLJsQ6reKg396eqBMqBg5dTjcT6G2eG2CG2Wz4fKFJEawokPOUv7agHtWZ)mCbT84bT0zyRr)rWDTrp2Y(DOup6AZrAC3RtaTzcTP(8G2enConQ5mCpbkRa3fMWKCEM0mC45FgUmPB4CAuZz4Cbyq5hkKTN10s60oZWr7kWUCd3c)pLI0EwtlPt7m5c)pLISg9NH78D0W5cWGYpuiBpRPL0PDMjmjd6nPz4WZ)mCzs3W50OMZW5cWGYpuiBpRPL0PDMHJ2vGD5go6mS1O)i4U2OhBz)ouQhDT5inU71jG2mH2uF(qRoODH)NsrApRPL0PDMCH)NsrEAqRoOfuEx(NHKjaJTCo5tGsmxELMgUGwE8G2)tPi)g9aSCusrDR2bmcN80GwDq7c)pLI0EwtlPt7m5c)pLI80GwDqBoqlO8U8pdjtagB5CYNaLyU8knnCbT84bT)NsrWDTrp2Y(DOup6AZrEAqRoODH)NsrApRPL0PDMCH)NsrEAqRoOnhOnCgEb53OhGLJskQB1oGr4e88pdxqlpEqBu7Omg5QqOfeOnJTgUZ3rdNladk)qHS9SMwsN2zMWKmOLjndhE(NHlt6goNg1CgUCluibp6zyB4ODfyxUHlbOfZLxPPHlc718HTqwNOw18esaLkGwDq7)PueTIX8wokPQhrqAC3RtaTjcT84bTjaT5aTyU8knnCryVMpSfY6e1QMNqcOub0QdA)pLIOvmM3Yrjv9icsJ7EDcOfeODBgqRoO9)ukIwXyElhLu1JiipnOnrd357OHl3cfsWJEg2MWKCUBsZWHN)z4YKUHZPrnNHJVBc5OK(rl8cP61BmC0UcSl3WrNHTg9hb31g9yl73Hs9ORnhPXDVob0Mj0MA5B4oFhnC8DtihL0pAHxivVEJjmjN6nPz4WZ)mCzs3W50OMZWbONdGqQ11UZKTdanC0UcSl3W1VdHwqacTPcA1bT5aT)Nsr0kgZB5OKQEeb5PbT6G2eG2CG2)tPi)g9aSCusrDR2bmcN80GwE8G2CG2Wz4fKFJEawokPOUv7agHtWZ)mCbTjA4oFhnCa65aiKADT7mz7aqtysEB(M0mC45FgUmPB4oFhnCTN16D8jK)cGSXL8)IyodNtJAodx7zTEhFc5VaiBCj)ViMZeMK3U1KMHdp)ZWLjDdNtJAod3o2iFbyxiv(bWWr7kWUCdxoq7)PuKFJEawokPOUv7agHtEAqRoOnhO9)ukIwXyElhLu1Jiipnd357OHBhBKVaSlKk)ayctYBZWKMHdp)ZWLjDdhTRa7YnC)Nsr0kgZB5OKQEeb5PbT6G2)tPi4U2OhBz)ouQhDT5ipndNtJAodN2e1CMWK82uzsZWHN)z4YKUHJ2vGD5gU)tPiAfJ5TCusvpIG80GwDq7)PueCxB0JTSFhk1JU2CKNMHZPrnNH7ZMzjvVEJjmjVn1mPz4WZ)mCzs3Wr7kWUCd3)PueTIX8wokPQhrqEAgoNg1CgUp2cS5RoaMWK828mPz4WZ)mCzs3Wr7kWUCdxcqBoq7)PueTIX8wokPQhrqEAqRoO1PrbkuIhUxOaAZei0Mb0Mi0YJh0Md0(FkfrRymVLJsQ6reKNg0QdAtaA73HKfQkAfqBMaH28GwDqB)UIk1g9ytwOQOvaTzceAb95dTjA4CAuZz48M6hk1EmbActYBb9M0mC45FgUmPB4ODfyxUH7)ukIwXyElhLu1JiipndNtJAodhRaaoeYCR3cWoEHjmjVf0YKMHdp)ZWLjDdhTRa7YnC)Nsr0kgZB5OKQEeb5PbT6G2)tPi4U2OhBz)ouQhDT5ipndNtJAodNFuueTZKuNXmHj5T5UjndhE(NHlt6goAxb2LB4(pLIOvmM3Yrjv9icsJ7EDcOfeGqBUdT6G2)tPi4U2OhBz)ouQhDT5ipndNtJAodNQA8ZMzzctYBt9M0mC45FgUmPB4ODfyxUH7)ukIwXyElhLu1JiipnOvh0Ma0(FkfrRymVLJsQ6reKg396eqliqBEqRoOnCgEbHoSLem6DqWZ)mCbT84bT5aTHZWli0HTKGrVdcE(NHlOvh0(FkfrRymVLJsQ6reKg396eqliqBQG2eHwDqRtJcuOepCVqb0ceA3cT84bT)NsreigGRdGSDai5PbT6GwNgfOqjE4EHcOfi0U1W50OMZW9DaYrjJUO8jmHj5mY3KMHdp)ZWLjDdhTRa7YnCjaT0zyRr)rWDTrp2Y(DOup6AZrAC3RtaT84bTHZWliffPUgbp)ZWf0Mi0QdAZbA)pLIOvmM3Yrjv9icYtdA5XdAdNHxqkksDncE(NHlOvh06zHDfir1Ji0dgzAczDRcW5rnhbp)ZWf0QdA)pLIOvmM3Yrjv9icsJ7EDcOfeOnddNtJAodNwXyElhLu1JimHj5m2AsZWHN)z4YKUHJ2vGD5go6mS1O)i4U2OhBz)ouQhDT5inU71jGwDqlDg2A0FeTIX8wokPQhrqAC3Rty4CAuZz4(n6by5OKI6wTdyeUH7jq5Ousa0Lj5TMWKCgzysZWHN)z4YKUHJ2vGD5go6mS1O)iAfJ5TCusvpIG0OV2aT6G2Wz4fK5ZQaBpQ5i45FgUGwDqB)oKe1okJrMh0Mj0cGUGwDqB)UIk1g9ytwOQOvaTzceA3Mp0YJh0g1okJrUkeAbbAZiFdNtJAodhURn6Xw2VdL6rxBotysoJuzsZWHN)z4YKUHJ2vGD5gUeGw6mS1O)iAfJ5TCusvpIG0OV2aT84bTrTJYyKRcHwqG2mYhAteA1bTHZWli)g9aSCusrDR2bmcNGN)z4cA1bT97kQuB0Jn0Mj0c6Z3W50OMZWH7AJESL97qPE01MZeMKZi1mPz4WZ)mCzs3Wr7kWUCdx4m8csrrQRrWZ)mCbT6G2(Di0cc0MkdNtJAodhURn6Xw2VdL6rxBotysoJ8mPz4CAuZz4aVrBcWyVxuPwJc8OOHdp)ZWLjDtysodqVjndhE(NHlt6goAxb2LB4cNHxqOdBjbJEhe88pdxqRoOnbOnbO9)ukcDyljy07GicNYh0MjqODB(qRoODH)NsrApRPlkseHt5dAbcT5bTjcT84bTrTJYyKRcHwqacTaOlOnrdNtJAodh1zmPtJAojReHHJvIqE(oA4OdBjbJEhMWKCgGwM0mC45FgUmPB4ODfyxUHlbO9)ukIwXyElhLu1JiipnOvh06zHDfiPOBK0k8fYiTF8bTGaeA3cT6G2eG2)tPiAfJ5TCusvpIG04UxNaAbbi0cGUGwE8G2)tPiVd8W2ifrJhGamPXDVob0ccqOfaDbT6G2)tPiVd8W2ifrJhGam5PbTjcTjA4CAuZz4u9ic9B6DHu96nMWKCg5UjndhE(NHlt6goAxb2LB4saA)pLIu0nsAf(czKNg0QdAZbAdNHxqkksDncE(NHlOvh0Ma0(Fkf5DGh2gPiA8aeGjpnOLhpO9)uksr3iPv4lKrAC3RtaTGaeAbqxqBIqBIqlpEq7)PuKIUrsRWxiJ80GwDq7)PuKIUrsRWxiJ04UxNaAbbi0cGUGwDqB4m8csrrQRrWZ)mCbT6G2)tPiAfJ5TCusvpIG80mConQ5mCQEeH(n9UqQE9gtysoJuVjndhE(NHlt6goAxb2LB4IAhLXixfcTGaTaOlOLhpOnbOnQDugJCvi0cc0sNHTg9hrRymVLJsQ6reKg396eqRoO9)ukY7apSnsr04biatEAqBIgoNg1CgovpIq)MExivVEJjmHHte(T8EzsZK8wtAgoNg1CgUg3NwGmuiK6RlW2WHN)z4YKUjmjNHjndhE(NHlt6goAxb2LB4OZWwJ(J04(0cKHcHuFDb2Kg396eqliaH2mG2CfAbqxqRoOnCgEbbGhGXUoasrm9obp)ZWLHZPrnNHt1JiKIOl(qtysovM0mC45FgUmPB4ODfyxUH7)uksx7i5Pz4CAuZz4ap6z1bq(zUimHj5uZKMHdp)ZWLjDdhTRa7YnCHZWliffPUgbp)ZWf0QdA)pLIOvmM3Yrjv9icYtdA1bTEwyxbsk6gjTcFHms7hFqBMaH2mmConQ5mCZNvb2EGMWKCEM0mC45FgUmPB4ODfyxUHlhO9)ukIQNSWtQ9ycK80GwDqB4m8cIQNSWtQ9ycKGN)z4YW50OMZWnFwfy7bActYGEtAgoNg1CgUf6byPFl5cP(gdhE(NHlt6MWKmOLjndhE(NHlt6goAxb2LB463vuP2OhBYcvfTcOfeOnbODBEqBsqB4m8cs)UIk9iW75rnhbp)ZWf0MRqBQG2enConQ5mCQEeHueDXhActY5UjndhE(NHlt6goAxb2LB4(pLIWxXy1bqU7uW1HKNg0QdA73HKO2rzmYudAZei0cGUmConQ5mCQEeHGUjaJMWKCQ3KMHdp)ZWLjDdhTRa7YnC97kQuB0JnzHQIwb0Mj0Ma0MrEqBsqB4m8cs)UIk9iW75rnhbp)ZWf0MRqBQG2enConQ5mCZNvb2EGMWK828nPz4CAuZz4u9icPi6Ip0WHN)z4YKUjmjVDRjndNtJAodh4Pp5OK6RlW2WHN)z4YKUjmjVndtAgoNg1CgoVP(HYy6gVWWHN)z4YKUjmHHBHk)XctAMK3AsZW50OMZWTx3sQAeZcnC45FgUmPBctYzysZWHN)z4YKUHJ2vGD5gUCG21eevpIqQqqHnjkkF1baA1bTjaT5aTHZWli)g9aSCusrDR2bmcNGN)z4cA5XdAPZWwJ(J8B0dWYrjf1TAhWiCsJ7EDcOntODBEqBIgoNg1CgoWJEwDaKFMlctysovM0mC45FgUmPB4ODfyxUH7)uksr3idNnNG04UxNaAbbi0cGUGwDq7)PuKIUrgoBob5PbT6GwHgYyYWBayiiayoTCM0xGYpkcTzceAZaA1bTjaT5aTHZWli)g9aSCusrDR2bmcNGN)z4cA5XdAPZWwJ(J8B0dWYrjf1TAhWiCsJ7EDcOntODBEqBIgoNg1CgoamNwot6lq5hfnHj5uZKMHdp)ZWLjDdhTRa7YnC)Nsrk6gz4S5eKg396eqliaHwa0f0QdA)pLIu0nYWzZjipnOvh0Ma0Md0godVG8B0dWYrjf1TAhWiCcE(NHlOLhpOLodBn6pYVrpalhLuu3QDaJWjnU71jG2mH2T5bTjA4CAuZz4u9icPi6Ip0eMKZZKMHdp)ZWLjDdNtJAodh1zmPtJAojReHHJvIqE(oA4qHapkkmHjzqVjndhE(NHlt6goNg1CgoQZysNg1CswjcdhReH88D0WrNHTg9NWeMKbTmPz4WZ)mCzs3Wr7kWUCd3)PuKFJEawokPOUv7agHtEAgoNg1CgU(DsNg1CswjcdhReH88D0W9hHmkkF1bWeMKZDtAgo88pdxM0nC0UcSl3WfodVG8B0dWYrjf1TAhWiCcE(NHlOvh0Ma0Ma0sNHTg9h53OhGLJskQB1oGr4Kg396eqlqOnFOvh0sNHTg9hrRymVLJsQ6reKg396eqliq728H2eHwE8G2eGw6mS1O)i)g9aSCusrDR2bmcN04UxNaAbbAZiFOvh0g1okJrUkeAbbAtvEqBIqBIgoNg1CgU(DsNg1CswjcdhReH88D0W9hHuBgwDamHj5uVjndhE(NHlt6goAxb2LB4(pLIOvmM3Yrjv9icYtdA1bTHZWliZNvb2EuZrWZ)mCz4CAuZz463jDAuZjzLimCSseYZ3rd38zvGTh1CMWK828nPz4WZ)mCzs3Wr7kWUCdNtJcuOepCVqb0MjqOnddNtJAodx)oPtJAojReHHJvIqE(oA48bnHj5TBnPz4WZ)mCzs3W50OMZWrDgt60OMtYkry4yLiKNVJgor43Y7LjmHHZh0KMj5TM0mC45FgUmPB4ODfyxUHlCgEbbGhGXUoasrm9obp)ZWf0YJh0Ma06zHDfir1tw4jdCxdfbP9JpOvh0k0qgtgEdadbPX9PfidfcP(6cSH2mbcTPcA1bT5aT)Nsr6AhjpnOnrdNtJAodxJ7tlqgkes91fyBctYzysZWHN)z4YKUHJ2vGD5gUWz4fevpIqq3eGrcE(NHldNtJAodhaMtlNj9fO8JIMWKCQmPz4WZ)mCzs3W50OMZWP6resr0fFOHJ2vGD5gUeG2f(FkfP9SMUOireoLpOfeOnpOLhpODH)NsrApRPlksAC3RtaTGaTBZhAteA1bT0zyRr)rACFAbYqHqQVUaBsJ7EDcOfeGqBgqBUcTaOlOvh0godVGaWdWyxhaPiMENGN)z4cA1bT5aTHZWliQEeHGUjaJe88pdxgo6gkdLH3aWqysERjmjNAM0mC45FgUmPB4ODfyxUHJodBn6psJ7tlqgkes91fytAC3RtaTGaeAZaAZvOfaDbT6G2Wz4feaEag76aifX07e88pdxgoNg1CgovpIqkIU4dnHj58mPz4WZ)mCzs3Wr7kWUCd3)PuKU2rYtZW50OMZWbE0ZQdG8ZCryctYGEtAgo88pdxM0nC0UcSl3W9FkfHVIXQdGC3PGRdjpndNtJAodNQhriOBcWOjmjdAzsZWHN)z4YKUHJ2vGD5gU(DfvQn6XMSqvrRaAbbAtaA3Mh0Me0godVG0VROspc8EEuZrWZ)mCbT5k0MkOnrdNtJAodhaMtlNj9fO8JIMWKCUBsZWHN)z4YKUHZPrnNHt1JiKIOl(qdhTRa7YnCjaTl8)uks7znDrrIiCkFqliqBEqlpEq7c)pLI0EwtxuK04UxNaAbbA3Mp0Mi0QdA73vuP2OhBYcvfTcOfeOnbODBEqBsqB4m8cs)UIk9iW75rnhbp)ZWf0MRqBQG2eHwDqBoqB4m8cIQhriOBcWibp)ZWLHJUHYqz4nameMK3ActYPEtAgo88pdxM0nC0UcSl3W1VROsTrp2KfQkAfqliqBcq728G2KG2Wz4fK(Dfv6rG3ZJAocE(NHlOnxH2ubTjcT6G2CG2Wz4fevpIqq3eGrcE(NHldNtJAodNQhrifrx8HMWK828nPz4CAuZz4ACFAbYqHqQVUaBdhE(NHlt6MWK82TM0mConQ5mCQEeHGUjaJgo88pdxM0nHj5TzysZWHN)z4YKUHZPrnNHB(SkW2d0Wr7kWUCdxcq7c)pLI0EwtxuKicNYh0cc0Mh0YJh0UW)tPiTN10ffjnU71jGwqG2T5dTjcT6G2(DfvQn6XMSqvrRaAZeAtaAZipOnjOnCgEbPFxrLEe498OMJGN)z4cAZvOnvqBIqRoOnhOnCgEbr1Jie0nbyKGN)z4YWr3qzOm8gagctYBnHj5TPYKMHdp)ZWLjDdhTRa7YnC97kQuB0JnzHQIwb0Mj0Ma0MrEqBsqB4m8cs)UIk9iW75rnhbp)ZWf0MRqBQG2enConQ5mCZNvb2EGMWK82uZKMHZPrnNHdaZPLZK(cu(rrdhE(NHlt6MWK828mPz4WZ)mCzs3W50OMZWP6resr0fFOHJ2vGD5gUeG2f(FkfP9SMUOireoLpOfeOnpOLhpODH)NsrApRPlksAC3RtaTGaTBZhAteA1bT5aTHZWliQEeHGUjaJe88pdxgo6gkdLH3aWqysERjmjVf0BsZW50OMZWP6resr0fFOHdp)ZWLjDtysElOLjndNtJAodh4Pp5OK6RlW2WHN)z4YKUjmjVn3nPz4CAuZz48M6hkJPB8cdhE(NHlt6MWeMWWbkSf1CMKZi)mYpFq)2uVHtV3xDaegUuN7Ath4cA3Mp060OMdAzLieei)goHgsnjNrEBnCA9OkgA4aDqlOrpIaAbnf9am0MB7kaGdi)GoOf08dWteqBg5Nc0Mr(zKpKFi)GoOn3aSFaqrUji)GoOf0gAtDEu2BHqBQl1TGwqJgXSqcKFqh0cAdTGMxlOv5m23P8bTQPH2NOoaqBQJC7GMKc0M6EanG2sbTAmFd2qBDvuEGcOn9HdA)OAAeA1MHvhaOLnakk0wcOLo7AmmWfbYpOdAbTH2CdW(baH2WBayqIAhLXixfcTXaTrTJYyKRcH2yG2NaHw8OZ7cSHwgEacWqB7bySH2aSFqR2e4fLZG2ODbyODHEawqG8d6GwqBOn3yylOn3m07aA9BbTTtlNbTHE05tqG8d5h0bTPosDfPVaxq7hvtJqlD2)EaTFeqDcc0cAMsrTqaT3CG2G9Ex9yqRtJAob0ohBdbYVtJAobrRr6S)9ijGzRnrnhKFNg1CcIwJ0z)7rsaZ(jqzf4EkNVJa9SeG92fs1CHCusTrp2q(DAuZjiAnsN9VhjbmBq5D5FgMY57iWjaJTCo5tGsmxELMgUsbuo7HataZLxPPHlYnX018esamFvEmTq(9faKhpmxELMgUi0P7NwGljaMVkpMwi)(caYJhMlVstdxe609tlWLeaZxLhtlK74YzSAoE8WC5vAA4IaQYzYrj9R29axYpBMfpEyU8knnCruvlc5UhOqk02aG5cbpEyU8knnCrYTqHe8ONHnpEyU8knnCrUjMUMNqcG5RYJPfYDC5mwnhpEyU8knnCrCbyq5hkKTN10s60olri)q(bDqBQJuxr6lWf0IGc7nqBu7i0gGrO1PX0qBjGwhuEX8pdjq(DAuZjaUx3sQAeZcH8d6GwqZAASnqlOrpIaAbnqqHn063cA396cVoOn1jDd0MMZMta53PrnNijGzdE0ZQdG8ZCrKsPaMZAcIQhriviOWMefLV6aOlHCcNHxq(n6by5OKI6wTdyeobp)ZWfpE0zyRr)r(n6by5OKI6wTdyeoPXDVorMBZlri)onQ5ejbmBamNwot6lq5hftPua)pLIu0nYWzZjinU71jabia6s3)PuKIUrgoBob5PPtOHmMm8gagccaMtlNj9fO8JIzcmdDjKt4m8cYVrpalhLuu3QDaJWj45FgU4XJodBn6pYVrpalhLuu3QDaJWjnU71jYCBEjc53PrnNijGzR6resr0fFykLc4)PuKIUrgoBobPXDVobiabqx6(pLIu0nYWzZjipnDjKt4m8cYVrpalhLuu3QDaJWj45FgU4XJodBn6pYVrpalhLuu3QDaJWjnU71jYCBEjc53PrnNijGztDgt60OMtYkrKY57iquiWJIci)onQ5ejbmBQZysNg1CswjIuoFhbsNHTg9NaYVtJAorsaZUFN0PrnNKvIiLZ3rG)riJIYxDasPua)pLI8B0dWYrjf1TAhWiCYtdYVtJAorsaZUFN0PrnNKvIiLZ3rG)ri1MHvhGukfWWz4fKFJEawokPOUv7agHtWZ)mCPlHeOZWwJ(J8B0dWYrjf1TAhWiCsJ7EDcG5RJodBn6pIwXyElhLu1JiinU71jazB(jYJxc0zyRr)r(n6by5OKI6wTdyeoPXDVobizKVUO2rzmYvHGKQ8smri)onQ5ejbm7(DsNg1CswjIuoFhboFwfy7rnxkLc4)PueTIX8wokPQhrqEA6cNHxqMpRcS9OMJGN)z4cYVtJAorsaZUFN0PrnNKvIiLZ3rG(GPukGonkqHs8W9cfzcmdi)onQ5ejbmBQZysNg1CswjIuoFhbkc)wEVG8d53PrnNG4dcSX9PfidfcP(6cStPuadNHxqa4bySRdGuetVtWZ)mCXJxcEwyxbsu9KfEYa31qrqA)4tNqdzmz4nameKg3NwGmuiK6RlWotGPsxo)Nsr6AhjpTeH870OMtq8btcy2ayoTCM0xGYpkMsPagodVGO6rec6MamsWZ)mCb53PrnNG4dMeWSv9icPi6Ipmf6gkdLH3aWqaCBkLcycl8)uks7znDrrIiCkFGKhpEl8)uks7znDrrsJ7EDcq2MFI6OZWwJ(J04(0cKHcHuFDb2Kg396eGamJCfaDPlCgEbbGhGXUoasrm9obp)ZWLUCcNHxqu9icbDtagj45FgUG870OMtq8btcy2QEeHueDXhMsPasNHTg9hPX9PfidfcP(6cSjnU71jabyg5ka6sx4m8ccapaJDDaKIy6DcE(NHli)onQ5eeFWKaMn4rpRoaYpZfrkLc4)PuKU2rYtdYVtJAobXhmjGzR6rec6MamMsPa(FkfHVIXQdGC3PGRdjpni)onQ5eeFWKaMnaMtlNj9fO8JIPukG97kQuB0JnzHQIwbijSnVKcNHxq63vuPhbEppQ5i45FgUY1uLiKFNg1CcIpysaZw1JiKIOl(WuOBOmugEdadbWTPukGjSW)tPiTN10ffjIWP8bsE84TW)tPiTN10ffjnU71jazB(jQRFxrLAJESjluv0kajHT5Lu4m8cs)UIk9iW75rnhbp)ZWvUMQe1Lt4m8cIQhriOBcWibp)ZWfKFNg1CcIpysaZw1JiKIOl(WukfW(DfvQn6XMSqvrRaKe2MxsHZWli97kQ0JaVNh1Ce88pdx5AQsuxoHZWliQEeHGUjaJe88pdxq(DAuZji(Gjbm7g3NwGmuiK6RlWgYVtJAobXhmjGzR6rec6Mamc53PrnNG4dMeWSNpRcS9atHUHYqz4namea3MsPaMWc)pLI0EwtxuKicNYhi5XJ3c)pLI0EwtxuK04UxNaKT5NOU(DfvQn6XMSqvrRiZeYiVKcNHxq63vuPhbEppQ5i45FgUY1uLOUCcNHxqu9icbDtagj45FgUG870OMtq8btcy2ZNvb2EGPukG97kQuB0JnzHQIwrMjKrEjfodVG0VROspc8EEuZrWZ)mCLRPkri)onQ5eeFWKaMnaMtlNj9fO8JIq(DAuZji(GjbmBvpIqkIU4dtHUHYqz4namea3MsPaMWc)pLI0EwtxuKicNYhi5XJ3c)pLI0EwtxuK04UxNaKT5NOUCcNHxqu9icbDtagj45FgUG870OMtq8btcy2QEeHueDXhc53PrnNG4dMeWSbp9jhLuFDb2q(DAuZji(GjbmBVP(HYy6gVaYpKFqh0MEJEagAhf0Yv3QDaJWHwTzy1baA7j8OMdAZnbTIW7qaTzKVaA)OAAeAtDxmM3q7OGwqJEeb0Me0M(WbTEJqRdkVy(NHq(DAuZji)ri1MHvhaGGh9S6ai)mxePukG)Nsr6Ahjpni)onQ5eK)iKAZWQdqsaZE(SkW2dmf6gkdLH3aWqaCBkLcycl8)uks7znDrrIiCkFGKhpEl8)uks7znDrrsJ7EDcq2MFI663vuP2OhBYcvfTImbMrE6YjCgEbr1Jie0nbyKGN)z4cYVtJAob5pcP2mS6aKeWSNpRcS9atPua73vuP2OhBYcvfTImbMrEq(DAuZji)ri1MHvhGKaMnaMtlNj9fO8JIPukG97kQuB0JnzHQIwbizKVoHgYyYWBayiiayoTCM0xGYpkMjWm0rNHTg9hrRymVLJsQ6reKg396ezMhKFNg1CcYFesTzy1bijGzR6resr0fFyk0nugkdVbGHa42ukfWew4)PuK2ZA6IIer4u(ajpE8w4)PuK2ZA6IIKg396eGSn)e11VROsTrp2KfQkAfGKr(6YjCgEbr1Jie0nbyKGN)z4shDg2A0FeTIX8wokPQhrqAC3RtKzEq(DAuZji)ri1MHvhGKaMTQhrifrx8HPukG97kQuB0JnzHQIwbizKVo6mS1O)iAfJ5TCusvpIG04UxNiZ8G870OMtq(JqQndRoajbmBvpIqq3eGXukfW)tPi8vmwDaK7ofCDi5PPRFxrLAJESjluv0kYmHT5Lu4m8cs)UIk9iW75rnhbp)ZWvUMQe1j0qgtgEdadbr1Jie0nbymtGza53PrnNG8hHuBgwDascy2QEeHGUjaJPukG97kQuB0JnzHQIwrMativ5Lu4m8cs)UIk9iW75rnhbp)ZWvUMQe1j0qgtgEdadbr1Jie0nbymtGza53PrnNG8hHuBgwDascy2ZNvb2EGPq3qzOm8gagcGBtPuatyH)NsrApRPlkseHt5dK84XBH)NsrApRPlksAC3RtaY28tux)UIk1g9ytwOQOvKjWesvEjfodVG0VROspc8EEuZrWZ)mCLRPkrD5eodVGO6rec6MamsWZ)mCb53PrnNG8hHuBgwDascy2ZNvb2EGPukG97kQuB0JnzHQIwrMativ5Lu4m8cs)UIk9iW75rnhbp)ZWvUMQeH870OMtq(JqQndRoajbmBamNwot6lq5hftPuaPZWwJ(JOvmM3Yrjv9icsJ7EDIm73HKO2rzmYutx)UIk1g9ytwOQOvasQLVoHgYyYWBayiiayoTCM0xGYpkMjWmG870OMtq(JqQndRoajbmBvpIqkIU4dtHUHYqz4namea3MsPaMWc)pLI0EwtxuKicNYhi5XJ3c)pLI0EwtxuK04UxNaKT5NOo6mS1O)iAfJ5TCusvpIG04UxNiZ(DijQDugJm101VROsTrp2KfQkAfGKA5RlNWz4fevpIqq3eGrcE(NHli)onQ5eK)iKAZWQdqsaZw1JiKIOl(Wukfq6mS1O)iAfJ5TCusvpIG04UxNiZ(DijQDugJm101VROsTrp2KfQkAfGKA5d5hYpOdAbnCg77u(G2yG2NaH2u3dOrkqBQJC7GMaT6bJh0(eydAxxfLhOaAtF4GwTg3941iBdbYVtJAob5pczuu(QdaqTIX8wokPQhrKsPasNHTg9hb31g9yl73Hs9ORnhPXDVobKFNg1CcYFeYOO8vhGKaMnURn6Xw2VdL6rxBoi)onQ5eK)iKrr5Roajbm75ZQaBpWuOBOmugEdadbWTPukGjSW)tPiTN10ffjIWP8bsE84TW)tPiTN10ffjnU71jazB(jQRFxrLAJESbbyQYqxoHZWliQEeHGUjaJe88pdxq(DAuZji)riJIYxDascy2ZNvb2EGPukG97kQuB0Jniatvgq(DAuZji)riJIYxDascy2nUpTazOqi1xxGDkLcy4m8ccapaJDDaKIy6DcE(NHli)onQ5eK)iKrr5RoajbmBWJEwDaKFMlIukfW)tPiDTJKNgKFNg1CcYFeYOO8vhGKaM98zvGThyk0nugkdVbGHa42ukfWew4)PuK2ZA6IIer4u(ajpE8w4)PuK2ZA6IIKg396eGSn)e11VdjrTJYyK5bca6IhV(DfvQn6XgeGPwE6YjCgEbr1Jie0nbyKGN)z4cYVtJAob5pczuu(QdqsaZE(SkW2dmLsbSFhsIAhLXiZdea0fpE97kQuB0JniatT8G870OMtq(JqgfLV6aKeWSv9icbDtagtPua)pLIWxXy1bqU7uW1HKNMoHgYyYWBayiiQEeHGUjaJzcmdi)onQ5eK)iKrr5RoajbmBWtFYrj1xxGDkLcy)UIk1g9ytwOQOvKjWuLHU(DijQDugJmvzcGUG870OMtq(JqgfLV6aKeWSBCFAbYqHqQVUaBi)onQ5eK)iKrr5RoajbmBvpIqq3eGXukfqHgYyYWBayiiQEeHGUjaJzcmdi)onQ5eK)iKrr5Roajbm75ZQaBpWuOBOmugEdadbWTPukGjSW)tPiTN10ffjIWP8bsE84TW)tPiTN10ffjnU71jazB(jQRFxrLAJESjluv0kYmJ84XRFhMzQ0Lt4m8cIQhriOBcWibp)ZWfKFNg1CcYFeYOO8vhGKaM98zvGThykLcy)UIk1g9ytwOQOvKzg5XJx)omZub53PrnNG8hHmkkF1bijGz7n1pugt34fPukG97kQuB0JnzHQIwrM5LpKFi)GoOn3yylOfm6DaT05wvuZjG870OMtqOdBjbJEhaPG96eYrjlkMsPa(FkfHoSLem6DqeHt5lZ80f1okJrUkeea0fKFNg1CccDyljy07ijGztb71jKJswumLsbmH)tPicedW1bq2oaK04UxNaea0vI6(pLIiqmaxhaz7aqYtdYVtJAobHoSLem6DKeWSPG96eYrjlkMsPaMW)PueTIX8wokPQhrqAC3Rtacqa0vUMW2KOZWwJ(JO6re6307cP61Bin6RnjYJ3)PueTIX8wokPQhrqAC3Rtas)oKe1okJrMQe19FkfrRymVLJsQ6reKNMUe8SWUcKu0nsAf(czK2p(ab4wE8(pLI8B0dWYrjf1TAhWiCYtlrD5eodVGuuK6Ae88pdxq(DAuZji0HTKGrVJKaMnfSxNqokzrXukfW)tPiAfJ5TCusvpIG04UxNaKCx3)PuK3bEyBKIOXdqaM04UxNaea0vUMW2KOZWwJ(JO6re6307cP61Bin6RnjQ7)ukY7apSnsr04biatAC3RtO7)ukIwXyElhLu1JiipnDj4zHDfiPOBK0k8fYiTF8bcWT849Fkf53OhGLJskQB1oGr4KNwI6YjCgEbPOi11i45FgUG870OMtqOdBjbJEhjbmBkyVoHCuYIIPukGj8FkfPOBK0k8fYinU71jaj14X7)uksr3iPv4lKrAC3Rtas)oKe1okJrMQe19FkfPOBK0k8fYipnDEwyxbsk6gjTcFHms7hFzcmdD58Fkf53OhGLJskQB1oGr4KNMUCcNHxqkksDncE(NHli)onQ5ee6WwsWO3rsaZMc2RtihLSOykLc4)PuKIUrsRWxiJ8009Fkf5DGh2gPiA8aeGjpnDEwyxbsk6gjTcFHms7hFzcmdD58Fkf53OhGLJskQB1oGr4KNMUCcNHxqkksDncE(NHli)onQ5ee6WwsWO3rsaZMc2RtihLSOykLc4)PueTIX8wokPQhrqAC3RtasQP7)ukIwXyElhLu1JiipnDHZWliffPUgbp)ZWLU)tPi0HTKGrVdIiCkFzcCBURZZc7kqsr3iPv4lKrA)4deGBH870OMtqOdBjbJEhjbmBkyVoHCuYIIPukG)Nsr0kgZB5OKQEeb5PPlCgEbPOi11i45FgU05zHDfiPOBK0k8fYiTF8LjWm0LW)Pue6WwsWO3breoLVmbUn1R7)uksr3iPv4lKrAC3Rtaca6s3)PuKIUrsRWxiJ804X7)ukY7apSnsr04biatEA6(pLIqh2scg9oiIWP8LjWT5EIq(H870OMtqOZWwJ(ta8jqzf4EkNVJa9SeG92fs1CHCusTrp2PukGjqNHTg9hb31g9yl73Hs9ORnhPrFTrxoGY7Y)mKmbySLZjFcuI5YR00WvI84LaDg2A0FeTIX8wokPQhrqAC3RtacWT5RduEx(NHKjaJTCo5tGsmxELMgUseYVtJAobHodBn6prsaZ(jqzf4EkNVJazVMpSfY6e1QMNqcOurkLcy4m8cYVrpalhLuu3QDaJWj45FgU0Lqc0zyRr)r0kgZB5OKQEebPXDVobia3MVoq5D5FgsMam2Y5KpbkXC5vAA4krE8s4)ukIwXyElhLu1JiipnD5akVl)ZqYeGXwoN8jqjMlVstdxjMipEj8FkfrRymVLJsQ6reKNMUCcNHxq(n6by5OKI6wTdyeobp)ZWvIq(DAuZji0zyRr)jscy2pbkRa3t58DeiDdLnrpxrLFMlIukfWC(pLIOvmM3Yrjv9icYtdYVtJAobHodBn6prsaZ(jqzf4UiLsbmb6mS1O)iAfJ5TCusvpIG0OV2WJhDg2A0FeTIX8wokPQhrqAC3RtKzg5NOUeYjCgEb53OhGLJskQB1oGr4e88pdx84rNHTg9hb31g9yl73Hs9ORnhPXDVorMP(8seYVtJAobHodBn6prsaZ(jqzf4EkNVJaDbyq5hkKTN10s60olLsbCH)NsrApRPL0PDMCH)NsrwJ(dYVtJAobHodBn6prsaZ(jqzf4EkNVJaDbyq5hkKTN10s60olLsbKodBn6pcURn6Xw2VdL6rxBosJ7EDImt95RBH)NsrApRPL0PDMCH)NsrEA6aL3L)zizcWylNt(eOeZLxPPHlE8(pLI8B0dWYrjf1TAhWiCYtt3c)pLI0EwtlPt7m5c)pLI800LdO8U8pdjtagB5CYNaLyU8knnCXJ3)PueCxB0JTSFhk1JU2CKNMUf(FkfP9SMwsN2zYf(Fkf5PPlNWz4fKFJEawokPOUv7agHtWZ)mCXJxu7Omg5QqqYylKFNg1CccDg2A0FIKaM9tGYkW9uoFhbMBHcj4rpd7ukfWeWC5vAA4IWEnFylK1jQvnpHeqPcD)Nsr0kgZB5OKQEebPXDVorI84LqoyU8knnCryVMpSfY6e1QMNqcOuHU)tPiAfJ5TCusvpIG04UxNaKTzO7)ukIwXyElhLu1JiipTeH870OMtqOZWwJ(tKeWSFcuwbUNY57iq(UjKJs6hTWlKQxVjLsbKodBn6pcURn6Xw2VdL6rxBosJ7EDImtT8H870OMtqOZWwJ(tKeWSFcuwbUNY57iqa9CaesTU2DMSDaykLcy)oeeGPsxo)Nsr0kgZB5OKQEeb5PPlHC(pLI8B0dWYrjf1TAhWiCYtJhVCcNHxq(n6by5OKI6wTdyeobp)ZWvIq(DAuZji0zyRr)jscy2pbkRa3t58Dey7zTEhFc5VaiBCj)ViMdYVtJAobHodBn6prsaZ(jqzf4EkNVJa3Xg5la7cPYpaPukG58Fkf53OhGLJskQB1oGr4KNMUC(pLIOvmM3Yrjv9icYtdYVtJAobHodBn6prsaZwBIAUukfW)tPiAfJ5TCusvpIG8009Fkfb31g9yl73Hs9ORnh5Pb53PrnNGqNHTg9NijGz)zZSKQxVjLsb8)ukIwXyElhLu1JiipnD)NsrWDTrp2Y(DOup6AZrEAq(DAuZji0zyRr)jscy2FSfyZxDasPua)pLIOvmM3Yrjv9icYtdYVtJAobHodBn6prsaZ2BQFOu7XeykLcyc58FkfrRymVLJsQ6reKNMoNgfOqjE4EHImbMrI84LZ)PueTIX8wokPQhrqEA6sOFhswOQOvKjW801VROsTrp2KfQkAfzce0NFIq(DAuZji0zyRr)jscy2Sca4qiZTEla74fPukG)Nsr0kgZB5OKQEeb5Pb53PrnNGqNHTg9NijGz7hffr7mj1zSukfW)tPiAfJ5TCusvpIG8009Fkfb31g9yl73Hs9ORnh5Pb53PrnNGqNHTg9NijGzRQg)SzwPukG)Nsr0kgZB5OKQEebPXDVobiaZDD)NsrWDTrp2Y(DOup6AZrEAq(DAuZji0zyRr)jscy2FhGCuYOlkFIukfW)tPiAfJ5TCusvpIG800LW)PueTIX8wokPQhrqAC3RtasE6cNHxqOdBjbJEhe88pdx84Lt4m8ccDyljy07GGN)z4s3)PueTIX8wokPQhrqAC3RtasQsuNtJcuOepCVqbWT849FkfrGyaUoaY2bGKNMoNgfOqjE4EHcGBH8d5h0bTGg9icOLodBn6pbKFNg1CccDg2A0FIKaMTwXyElhLu1JisPuatGodBn6pcURn6Xw2VdL6rxBosJ7EDcE8cNHxqkksDncE(NHRe1LZ)PueTIX8wokPQhrqEA84fodVGuuK6Ae88pdx68SWUcKO6re6bJmnHSUvb48OMJGN)z4s3)PueTIX8wokPQhrqAC3Rtasgq(DAuZji0zyRr)jscy2)g9aSCusrDR2bmcpLNaLJsjbqxa3MsPasNHTg9hb31g9yl73Hs9ORnhPXDVoHo6mS1O)iAfJ5TCusvpIG04UxNaYVtJAobHodBn6prsaZg31g9yl73Hs9ORnxkLciDg2A0FeTIX8wokPQhrqA0xB0fodVGmFwfy7rnhbp)ZWLU(DijQDugJmVmbqx663vuP2OhBYcvfTImbUnFE8IAhLXixfcsg5d53PrnNGqNHTg9NijGzJ7AJESL97qPE01MlLsbmb6mS1O)iAfJ5TCusvpIG0OV2WJxu7Omg5QqqYi)e1fodVG8B0dWYrjf1TAhWiCcE(NHlD97kQuB0JDMG(8H870OMtqOZWwJ(tKeWSXDTrp2Y(DOup6AZLsPagodVGuuK6Ae88pdx663HGKki)onQ5ee6mS1O)ejbmBWB0Mam27fvQ1Oapkc53PrnNGqNHTg9NijGztDgt60OMtYkrKY57iq6WwsWO3rkLcy4m8ccDyljy07GGN)z4sxcj8FkfHoSLem6DqeHt5ltGBZx3c)pLI0EwtxuKicNYhW8sKhVO2rzmYvHGaeaDLiKFNg1CccDg2A0FIKaMTQhrOFtVlKQxVjLsbmH)tPiAfJ5TCusvpIG8005zHDfiPOBK0k8fYiTF8bcWT6s4)ukIwXyElhLu1JiinU71jabia6IhV)tPiVd8W2ifrJhGamPXDVobiabqx6(pLI8oWdBJuenEacWKNwIjc53PrnNGqNHTg9NijGzR6re6307cP61BsPuat4)uksr3iPv4lKrEA6YjCgEbPOi11i45FgU0LW)PuK3bEyBKIOXdqaM804X7)uksr3iPv4lKrAC3Rtacqa0vIjYJ3)PuKIUrsRWxiJ8009FkfPOBK0k8fYinU71jabia6sx4m8csrrQRrWZ)mCP7)ukIwXyElhLu1Jiipni)onQ5ee6mS1O)ejbmBvpIq)MExivVEtkLcyu7Omg5Qqqaqx84Lqu7Omg5QqqOZWwJ(JOvmM3Yrjv9icsJ7EDcD)NsrEh4HTrkIgpabyYtlri)q(DAuZjiOqGhffa)SzwYrjdWOepCFtkLc4)PueTIX8wokPQhrqEA6s4)ukIwXyElhLu1JiinU71jazB(6s4)ukYVrpalhLuu3QDaJWjpnE8cNHxqMpRcS9OMJGN)z4IhVWz4fKIIuxJGN)z4sxoEwyxbsk6gjTcFHmcE(NHRe5X7)uksr3iPv4lKrEA6cNHxqkksDncE(NHRe1LGtJcuOepCVqbWT84Lt4m8csrrQRrWZ)mCLipEonkqHs8W9cfzcmdDHZWliffPUgbp)ZWLo6mS1O)iAfJ5TCusvpIG0OV2OlbplSRajfDJKwHVqgP9JVmbUv3)PuKIUrsRWxiJ804XlhplSRajfDJKwHVqgbp)ZWvIq(DAuZjiOqGhffjbmBapVxLFYrj9SWEcWPukG5eodVGuuK6Ae88pdx84fodVGuuK6Ae88pdx68SWUcKu0nsAf(cze88pdx6(pLIOvmM3Yrjv9icsJ7EDcqa96(pLIOvmM3Yrjv9icYtJhVWz4fKIIuxJGN)z4sxoEwyxbsk6gjTcFHmcE(NHli)onQ5eeuiWJIIKaMnfCXysr0OZxkLc4)PueTIX8wokPQhrqAC3RtasE6(pLIOvmM3Yrjv9icYtJhVO2rzmYvHGKhKFNg1Cccke4rrrsaZoaJY39N3TKQPPykLc4)PuKgP8XqHqQMMIKNgpE)NsrAKYhdfcPAAkkPZ7cSjIWP8bY2Tq(DAuZjiOqGhffjbmB1qFcCj9SWUcu(rFpLsbmN)tPiAfJ5TCusvpIG800LZ)PuKFJEawokPOUv7agHtEAq(DAuZjiOqGhffjbmB6Cu8I2dCjvmFhtPuaZ5)ukIwXyElhLu1JiipnD58Fkf53OhGLJskQB1oGr4KNMU1ee6Cu8I2dCjvmFhL)xFKg396eaZhYVtJAobbfc8OOijGzRFA2cuyDYgfZ5hftPua)pLIOvmM3Yrjv9icYtJhV)tPi4U2OhBz)ouQhDT5ipnE8OZWwJ(J8B0dWYrjf1TAhWiCsJ7EDImb95N0284XJoD)0IAobPouP8pdLr)cWe88pdxq(DAuZjiOqGhffjbm7U00yOSoPqZPykLcyo)Nsr0kgZB5OKQEeb5PPlN)tPi)g9aSCusrDR2bmcN80G870OMtqqHapkkscy274(0BKJsYE0Ajxn67IukfW)tPi4U2OhBz)ouQhDT5inU71jajpD)Nsr(n6by5OKI6wTdyeo5PXJxc97qsu7OmgzgzcGU01VROsTrp2GKx(jc53PrnNGGcbEuuKeWSB01QdGuX8Dua5hYpOdAZn)ZQaBpQ5G2EcpQ5G870OMtqMpRcS9OMdyJ7tlqgkes91fyNsPagodVGaWdWyxhaPiMENGN)z4cYVtJAobz(SkW2JAUKaM98zvGThyk0nugkdVbGHa42ukfWew4)PuK2ZA6IIer4u(ajpE8w4)PuK2ZA6IIKg396eGSn)e1Lt4m8cIQhriOBcWibp)ZWLUC(pLI01osEA6eAiJjdVbGHGaE0ZQdG8ZCrKjWub53PrnNGmFwfy7rnxsaZE(SkW2dmLsbmNWz4fevpIqq3eGrcE(NHlD58FkfPRDK800j0qgtgEdadbb8ONvha5N5IitGPcYVtJAobz(SkW2JAUKaMTQhriOBcWykLcyc)Nsr4RyS6ai3Dk46qsJon4XlH)tPi8vmwDaK7ofCDi5PPlbTgbLeaDr2su9icPi6IpKhpTgbLeaDr2sap6z1bq(zUi4XtRrqjbqxKTeamNwot6lq5hftmXe1j0qgtgEdadbr1Jie0nbymtGza53PrnNGmFwfy7rnxsaZE(SkW2dmf6gkdLH3aWqaCBkLcycl8)uks7znDrrIiCkFGKhpEl8)uks7znDrrsJ7EDcq2MFI6(pLIWxXy1bqU7uW1HKgDAWJxc)Nsr4RyS6ai3Dk46qYttxcAnckja6ISLO6resr0fFipEAnckja6ISLaE0ZQdG8ZCrWJNwJGscGUiBjayoTCM0xGYpkMyIq(DAuZjiZNvb2EuZLeWSNpRcS9atPua)pLIWxXy1bqU7uW1HKgDAWJxc)Nsr4RyS6ai3Dk46qYttxcAnckja6ISLO6resr0fFipEAnckja6ISLaE0ZQdG8ZCrWJNwJGscGUiBjayoTCM0xGYpkMyIq(DAuZjiZNvb2EuZLeWSbWCA5mPVaLFumLsbmHC(pLI01osEA841VROsTrp2KfQkAfGSnFE863HKO2rzmYmYeaDLOoHgYyYWBayiiayoTCM0xGYpkMjWmG870OMtqMpRcS9OMljGzdE0ZQdG8ZCrKsPa(FkfPRDK800j0qgtgEdadbb8ONvha5N5IitGza53PrnNGmFwfy7rnxsaZw1JiKIOl(WuOBOmugEdadbWTPukGjSW)tPiTN10ffjIWP8bsE84TW)tPiTN10ffjnU71jazB(jQlN)tPiDTJKNgpE97kQuB0JnzHQIwbiBZNhV(DijQDugJmJmbqx6YjCgEbr1Jie0nbyKGN)z4cYVtJAobz(SkW2JAUKaMTQhrifrx8HPukG58FkfPRDK804XRFxrLAJESjluv0kazB(841VdjrTJYyKzKja6cYVtJAobz(SkW2JAUKaMn4rpRoaYpZfrkLc4)PuKU2rYtdYVtJAobz(SkW2JAUKaM98zvGThyk0nugkdVbGHa42ukfWew4)PuK2ZA6IIer4u(ajpE8w4)PuK2ZA6IIKg396eGSn)e1Lt4m8cIQhriOBcWibp)ZWfKFNg1CcY8zvGTh1Cjbm75ZQaBpqi)q(bDqlx43Y7f0kQdadbTdVbGb02t4rnhKFNg1CcIi8B59cyJ7tlqgkes91fyd53PrnNGic)wEVscy2QEeHueDXhMsPasNHTg9hPX9PfidfcP(6cSjnU71jabyg5ka6sx4m8ccapaJDDaKIy6DcE(NHli)onQ5eer43Y7vsaZg8ONvha5N5IiLsb8)uksx7i5Pb53PrnNGic)wEVscy2ZNvb2EGPukGHZWliffPUgbp)ZWLU)tPiAfJ5TCusvpIG8005zHDfiPOBK0k8fYiTF8LjWmG870OMtqeHFlVxjbm75ZQaBpWukfWC(pLIO6jl8KApMajpnDHZWliQEYcpP2JjqcE(NHli)onQ5eer43Y7vsaZEHEaw63sUqQVbYVtJAobre(T8ELeWSv9icPi6IpmLsbSFxrLAJESjluv0kajHT5Lu4m8cs)UIk9iW75rnhbp)ZWvUMQeH870OMtqeHFlVxjbmBvpIqq3eGXukfW)tPi8vmwDaK7ofCDi5PPRFhsIAhLXitTmbcGUG870OMtqeHFlVxjbm75ZQaBpWukfW(DfvQn6XMSqvrRiZeYiVKcNHxq63vuPhbEppQ5i45FgUY1uLiKFNg1CcIi8B59kjGzR6resr0fFiKFNg1CcIi8B59kjGzdE6tokP(6cSH870OMtqeHFlVxjbmBVP(HYy6gVWeMWya]] )
    
end
