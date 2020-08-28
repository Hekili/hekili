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
            noOverride = 324128,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = true,
            texture = 136144,
            
            handler = function ()
                applyBuff( "death_and_decay" )
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

    
    spec:RegisterPack( "Frost DK", 20200828.2, [[dKufxcqirfpcikBIuzuIOoLiXQevsVsemlrKBbeP2fk)suYWev1XuQAzIu9mrsMMiPCnrv2gqu9nGiACIkLZjsQADIkvY8as3dq7tu4Garsluu0dfvQyIIkvLlksQOnceHrksQeNuKuHvIu1lbIeUPOsLYofH(POsLQHksQulvuPQ6PizQIu(kqKO9sXFjAWu6WuTyv1JrmzLCzOntYNby0a1PLSArLQ8AKkZgv3wPSBv(TIHtkhxujwUupNW0fUUQSDGW3jvnErsL05vQSErPMpsz)G2S3KMHA5bAsm98tp)8ZT0Zn2(Cl9uLhiPHk2PHgknNqNdanuNVHgkqIEeb0M7dKcdLMVJp(YKMHsmVMGgkWrOjYDLvwaQa87ZiZwwIA7X9OMJ0UkYsuBKSmu)xXJuhN5BOwEGMetp)0Zp)Cl9CJTp3spvPNUHYFb4Pnuu1wUJHcCTw4z(gQfkigkqg0cs0JiG2CFOhGHwqkUca4aspidAbP(a8eb0MEULe0ME(PNpKEi9GmOn3bSFaqrUli9GmOfKgAtDCe(BHqBUB1TGwqIgXSrgKEqg0csdTGuxlOv5C(3j0bTQPH2NOoaqBQZC)GuMe0M6EajG2sbTACFh2qBDvuEGcOnZHcA)OAAeA1MHxhaOLpakc0wcOLmBACmWfdspidAbPH2ChW(baH2WBayWIAdLXixfcTXaTrTHYyKRcH2yG2NaHw8iZ7cSHwoEacWqB7bySH2aSFqR2e4fLZH2ODbyODHEawWG0dYGwqAOn3z4lOn1f07aA9BbTTtkNdTHE0PtWmu8sectAgkYWxsWO3HjntI7nPzOWZ)CCzY0qr6kWUCd1)PumYWxsWO3bteoHoOndOnpOvh0g1gkJrUkeAbfAbqwgkNe1CgkcyVoHCuYIGMWKy6M0mu45FoUmzAOiDfyxUHkzO9)ukMaXaCDaKTdaznU51jGwqHwaKf0Mc0QdA)pLIjqmaxhaz7aq2tZq5KOMZqra71jKJswe0eMetLjndfE(NJltMgksxb2LBOsgA)pLIPvCU3Yrjv9icwJBEDcOfuGqlaYcAZvOnzODp0Ma0sMHVg9ht1Ji0VR3es1R3XA0x7G2uGwA0G2)tPyAfN7TCusvpIG14MxNaAbfA73HSO2qzmYubTPaT6G2)tPyAfN7TCusvpIG90GwDqBYqRNn2vGSIStsQWxiN1(rh0ckqODp0sJg0(Fkf73OhGLJskQB1oGr4SNg0Mc0QdAZbAdNJxWkcsCngE(NJldLtIAodfbSxNqokzrqtysm1mPzOWZ)CCzY0qr6kWUCd1)PumTIZ9wokPQhrWACZRtaTGcT5g0QdA)pLI9oWdFNuenEacWSg386eqlOqlaYcAZvOnzODp0Ma0sMHVg9ht1Ji0VR3es1R3XA0x7G2uGwDq7)PuS3bE47KIOXdqaM14MxNaA1bT)NsX0ko3B5OKQEeb7PbT6G2KHwpBSRazfzNKuHVqoR9JoOfuGq7EOLgnO9)uk2VrpalhLuu3QDaJWzpnOnfOvh0Md0gohVGveK4Am88phxgkNe1CgkcyVoHCuYIGMWKyEM0mu45FoUmzAOiDfyxUHkzO9)ukwr2jjv4lKZACZRtaTGcTPg0sJg0(FkfRi7KKk8fYznU51jGwqH2(DilQnugJmvqBkqRoO9)ukwr2jjv4lKZEAqRoO1Zg7kqwr2jjv4lKZA)OdAZai0Mo0QdAZbA)pLI9B0dWYrjf1TAhWiC2tdA1bT5aTHZXlyfbjUgdp)ZXLHYjrnNHIa2RtihLSiOjmjcYnPzOWZ)CCzY0qr6kWUCd1)PuSIStsQWxiN90GwDq7)PuS3bE47KIOXdqaM90GwDqRNn2vGSIStsQWxiN1(rh0MbqOnDOvh0Md0(Fkf73OhGLJskQB1oGr4SNg0QdAZbAdNJxWkcsCngE(NJldLtIAodfbSxNqokzrqtyseK0KMHcp)ZXLjtdfPRa7Ynu)NsX0ko3B5OKQEebRXnVob0ck0MAqRoO9)ukMwX5ElhLu1JiypnOvh0gohVGveK4Am88phxqRoO9)ukgz4ljy07GjcNqh0MbqODFUbT6GwpBSRazfzNKuHVqoR9JoOfuGq7EdLtIAodfbSxNqokzrqtysm3mPzOWZ)CCzY0qr6kWUCd1)PumTIZ9wokPQhrWEAqRoOnCoEbRiiX1y45FoUGwDqRNn2vGSIStsQWxiN1(rh0MbqOnDOvh0Mm0(FkfJm8Lem6DWeHtOdAZai0Up1dT6G2)tPyfzNKuHVqoRXnVob0ck0cGSGwDq7)PuSIStsQWxiN90GwA0G2)tPyVd8W3jfrJhGam7PbT6G2)tPyKHVKGrVdMiCcDqBgaH295g0MIHYjrnNHIa2RtihLSiOjmHHA(8kW2JAotAMe3BsZqHN)54YKPHI0vGD5gQW54fmaEag76aifX0Bm88phxgkNe1CgQg3MwGCuiK6RlW2eMet3KMHcp)ZXLjtdLtIAod185vGThOHI0vGD5gQKH2f(FkfR9SNUiiteoHoOfuOnpOLgnODH)NsXAp7PlcYACZRtaTGcT7ZhAtbA1bT5aTHZXlyQEeHGSlaJm88phxqRoOnhO9)ukwxBi7PbT6GwHgY5YWBayiyGh986ai)CxeqBgaH2uzOi7iCugEdadHjX9MWKyQmPzOWZ)CCzY0qr6kWUCdvoqB4C8cMQhrii7cWidp)ZXf0QdAZbA)pLI11gYEAqRoOvOHCUm8gagcg4rpVoaYp3fb0MbqOnvgkNe1CgQ5ZRaBpqtysm1mPzOWZ)CCzY0qr6kWUCdvYq7)Pum6koVoaYnNaUoK1OtcOLgnOnzO9)ukgDfNxha5MtaxhYEAqRoOnzOvRrqibqwS9mvpIqkIUOdHwA0GwTgbHeazX2Zap651bq(5UiGwA0GwTgbHeazX2ZaWDs5CPVaHFeeAtbAtbAtbA1bTcnKZLH3aWqWu9icbzxagH2macTPBOCsuZzOu9icbzxagnHjX8mPzOWZ)CCzY0q5KOMZqnFEfy7bAOiDfyxUHkzODH)NsXAp7PlcYeHtOdAbfAZdAPrdAx4)PuS2ZE6IGSg386eqlOq7(8H2uGwDq7)Pum6koVoaYnNaUoK1OtcOLgnOnzO9)ukgDfNxha5MtaxhYEAqRoOnzOvRrqibqwS9mvpIqkIUOdHwA0GwTgbHeazX2Zap651bq(5UiGwA0GwTgbHeazX2ZaWDs5CPVaHFeeAtbAtXqr2r4Om8gagctI7nHjrqUjndfE(NJltMgksxb2LBO(pLIrxX51bqU5eW1HSgDsaT0ObTjdT)NsXOR486ai3Cc46q2tdA1bTjdTAnccjaYITNP6resr0fDi0sJg0Q1iiKail2Eg4rpVoaYp3fb0sJg0Q1iiKail2EgaUtkNl9fi8JGqBkqBkgkNe1CgQ5ZRaBpqtyseK0KMHcp)ZXLjtdfPRa7YnuojkqGs8WTcfqBgqB6gkNe1CgQf6byHC9qtysm3mPzOWZ)CCzY0qr6kWUCdLtIceOepCRqb0Mb0MUHYjrnNHAHEaw63sUqIVZeMet9M0mu45FoUmzAOiDfyxUHkzOnhO9)ukwxBi7PbT0ObT97kIuB0JnBHQIub0ck0UpFOLgnOTFhYIAdLXithAZaAbqwqBkqRoOvOHCUm8gagcgaUtkNl9fi8JGqBgaH20nuojQ5mua4oPCU0xGWpcActI7Z3KMHcp)ZXLjtdfPRa7Ynu)NsX6AdzpnOvh0k0qoxgEdadbd8ONxha5N7IaAZai0MUHYjrnNHc8ONxha5N7IWeMe3V3KMHcp)ZXLjtdLtIAodLQhrifrx0Hgksxb2LBOsgAx4)PuS2ZE6IGmr4e6GwqH28GwA0G2f(FkfR9SNUiiRXnVob0ck0UpFOnfOvh0Md0(FkfRRnK90GwA0G2(DfrQn6XMTqvrQaAbfA3Np0sJg02VdzrTHYyKPdTzaTailOvh0Md0gohVGP6recYUamYWZ)CCzOi7iCugEdadHjX9MWK4(0nPzOWZ)CCzY0qr6kWUCdvoq7)PuSU2q2tdAPrdA73veP2OhB2cvfPcOfuODF(qlnAqB)oKf1gkJrMo0Mb0cGSmuojQ5muQEeHueDrhActI7tLjndfE(NJltMgksxb2LBO(pLI11gYEAgkNe1CgkWJEEDaKFUlctysCFQzsZqHN)54YKPHYjrnNHA(8kW2d0qr6kWUCdvYq7c)pLI1E2txeKjcNqh0ck0Mh0sJg0UW)tPyTN90fbznU51jGwqH295dTPaT6G2CG2W54fmvpIqq2fGrgE(NJldfzhHJYWBayimjU3eMe3NNjndLtIAod185vGThOHcp)ZXLjttycd1FeYOi0vhatAMe3BsZqHN)54YKPHI0vGD5gkYm81O)y4M2OhBz)ouQhDT5ynU51jmuojQ5muAfN7TCusvpIWeMet3KMHYjrnNHc30g9yl73Hs9ORnNHcp)ZXLjttysmvM0mu45FoUmzAOCsuZzOMpVcS9anuKUcSl3qLm0UW)tPyTN90fbzIWj0bTGcT5bT0ObTl8)ukw7zpDrqwJBEDcOfuODF(qBkqRoOTFxrKAJESHwqbcTPkDOvh0Md0gohVGP6recYUamYWZ)CCzOi7iCugEdadHjX9MWKyQzsZqHN)54YKPHI0vGD5gQ(DfrQn6XgAbfi0MQ0nuojQ5muZNxb2EGMWKyEM0mu45FoUmzAOiDfyxUHkCoEbdGhGXUoasrm9gdp)ZXLHYjrnNHQXTPfihfcP(6cSnHjrqUjndfE(NJltMgksxb2LBO(pLI11gYEAgkNe1CgkWJEEDaKFUlctyseK0KMHcp)ZXLjtdLtIAod185vGThOHI0vGD5gQKH2f(FkfR9SNUiiteoHoOfuOnpOLgnODH)NsXAp7PlcYACZRtaTGcT7ZhAtbA1bT97qwuBOmgzEqlOqlaYcAPrdA73veP2OhBOfuGqBQLh0QdAZbAdNJxWu9icbzxagz45FoUmuKDeokdVbGHWK4Etysm3mPzOWZ)CCzY0qr6kWUCdv)oKf1gkJrMh0ck0cGSGwA0G2(DfrQn6XgAbfi0MA5zOCsuZzOMpVcS9anHjXuVjndfE(NJltMgksxb2LBO(pLIrxX51bqU5eW1HSNg0QdAfAiNldVbGHGP6recYUamcTzaeAt3q5KOMZqP6recYUamActI7Z3KMHcp)ZXLjtdfPRa7Ynu97kIuB0JnBHQIub0MbqOnvPdT6G2(DilQnugJmvqBgqlaYYq5KOMZqbE6tokP(6cSnHjX97nPzOCsuZzOACBAbYrHqQVUaBdfE(NJltMMWK4(0nPzOWZ)CCzY0qr6kWUCdLqd5Cz4namemvpIqq2fGrOndGqB6gkNe1CgkvpIqq2fGrtysCFQmPzOWZ)CCzY0q5KOMZqnFEfy7bAOiDfyxUHkzODH)NsXAp7PlcYeHtOdAbfAZdAPrdAx4)PuS2ZE6IGSg386eqlOq7(8H2uGwDqB)UIi1g9yZwOQivaTzaTPNh0sJg02VdH2mG2ubT6G2CG2W54fmvpIqq2fGrgE(NJldfzhHJYWBayimjU3eMe3NAM0mu45FoUmzAOiDfyxUHQFxrKAJESzluvKkG2mG20ZdAPrdA73HqBgqBQmuojQ5muZNxb2EGMWK4(8mPzOWZ)CCzY0qr6kWUCdv)UIi1g9yZwOQivaTzaT5LVHYjrnNHYBIFOmMUXlmHjmu(GM0mjU3KMHcp)ZXLjtdfPRa7YnuHZXlya8am21bqkIP3y45FoUGwA0G2KHwpBSRazQEYgpzGBAOiyTF0bT6GwHgY5YWBayiynUnTa5Oqi1xxGn0MbqOnvqRoOnhO9)ukwxBi7PbTPyOCsuZzOACBAbYrHqQVUaBtysmDtAgk88phxMmnuKUcSl3qfohVGP6recYUamYWZ)CCzOCsuZzOaWDs5CPVaHFe0eMetLjndfE(NJltMgkNe1CgkvpIqkIUOdnuKUcSl3qLm0UW)tPyTN90fbzIWj0bTGcT5bT0ObTl8)ukw7zpDrqwJBEDcOfuODF(qBkqRoOLmdFn6pwJBtlqokes91fyZACZRtaTGceAthAZvOfazbT6G2W54fmaEag76aifX0Bm88phxqRoOnhOnCoEbt1JieKDbyKHN)54Yqr2r4Om8gagctI7nHjXuZKMHcp)ZXLjtdfPRa7YnuKz4Rr)XACBAbYrHqQVUaBwJBEDcOfuGqB6qBUcTailOvh0gohVGbWdWyxhaPiMEJHN)54Yq5KOMZqP6resr0fDOjmjMNjndfE(NJltMgksxb2LBO(pLI11gYEAgkNe1CgkWJEEDaKFUlctyseKBsZqHN)54YKPHI0vGD5gQ)tPy0vCEDaKBobCDi7PzOCsuZzOu9icbzxagnHjrqstAgk88phxMmnuKUcSl3q1VRisTrp2SfQksfqlOqBYq7(8G2eG2W54fS(Dfr6rG3ZJAogE(NJlOnxH2ubTPyOCsuZzOaWDs5CPVaHFe0eMeZntAgk88phxMmnuojQ5muQEeHueDrhAOiDfyxUHkzODH)NsXAp7PlcYeHtOdAbfAZdAPrdAx4)PuS2ZE6IGSg386eqlOq7(8H2uGwDqB)UIi1g9yZwOQivaTGcTjdT7ZdAtaAdNJxW63vePhbEppQ5y45FoUG2CfAtf0Mc0QdAZbAdNJxWu9icbzxagz45FoUmuKDeokdVbGHWK4Etysm1BsZqHN)54YKPHI0vGD5gQ(DfrQn6XMTqvrQaAbfAtgA3Nh0Ma0gohVG1VRispc8EEuZXWZ)CCbT5k0MkOnfOvh0Md0gohVGP6recYUamYWZ)CCzOCsuZzOu9icPi6Io0eMe3NVjndfE(NJltMgksxb2LBOCsuGaL4HBfkG2mG20nuojQ5mul0dWc56HMWK4(9M0mu45FoUmzAOiDfyxUHYjrbcuIhUvOaAZaAt3q5KOMZqTqpal9BjxiX3zctI7t3KMHYjrnNHQXTPfihfcP(6cSnu45FoUmzActI7tLjndLtIAodLQhrii7cWOHcp)ZXLjttysCFQzsZqHN)54YKPHYjrnNHA(8kW2d0qr6kWUCdvYq7c)pLI1E2txeKjcNqh0ck0Mh0sJg0UW)tPyTN90fbznU51jGwqH295dTPaT6G2(DfrQn6XMTqvrQaAZaAtgAtppOnbOnCoEbRFxrKEe498OMJHN)54cAZvOnvqBkqRoOnhOnCoEbt1JieKDbyKHN)54Yqr2r4Om8gagctI7nHjX95zsZqHN)54YKPHI0vGD5gQ(DfrQn6XMTqvrQaAZaAtgAtppOnbOnCoEbRFxrKEe498OMJHN)54cAZvOnvqBkgkNe1CgQ5ZRaBpqtysCpi3KMHYjrnNHca3jLZL(ce(rqdfE(NJltMMWK4EqstAgk88phxMmnuojQ5muQEeHueDrhAOiDfyxUHkzODH)NsXAp7PlcYeHtOdAbfAZdAPrdAx4)PuS2ZE6IGSg386eqlOq7(8H2uGwDqBoqB4C8cMQhrii7cWidp)ZXLHISJWrz4nameMe3BctI7ZntAgkNe1CgkvpIqkIUOdnu45FoUmzActI7t9M0muojQ5muGN(KJsQVUaBdfE(NJltMMWKy65BsZq5KOMZq5nXpugt34fgk88phxMmnHjmu)ri1MHxhatAMe3BsZqHN)54YKPHI0vGD5gQ)tPyDTHSNMHYjrnNHc8ONxha5N7IWeMet3KMHcp)ZXLjtdLtIAod185vGThOHI0vGD5gQKH2f(FkfR9SNUiiteoHoOfuOnpOLgnODH)NsXAp7PlcYACZRtaTGcT7ZhAtbA1bT97kIuB0JnBHQIub0MbqOn98GwDqBoqB4C8cMQhrii7cWidp)ZXLHISJWrz4nameMe3BctIPYKMHcp)ZXLjtdfPRa7Ynu97kIuB0JnBHQIub0MbqOn98muojQ5muZNxb2EGMWKyQzsZqHN)54YKPHI0vGD5gQ(DfrQn6XMTqvrQaAbfAtpFOvh0k0qoxgEdadbda3jLZL(ce(rqOndGqB6qRoOLmdFn6pMwX5ElhLu1JiynU51jG2mG28muojQ5mua4oPCU0xGWpcActI5zsZqHN)54YKPHYjrnNHs1JiKIOl6qdfPRa7YnujdTl8)ukw7zpDrqMiCcDqlOqBEqlnAq7c)pLI1E2txeK14MxNaAbfA3Np0Mc0QdA73veP2OhB2cvfPcOfuOn98HwDqBoqB4C8cMQhrii7cWidp)ZXf0QdAjZWxJ(JPvCU3Yrjv9icwJBEDcOndOnpdfzhHJYWBayimjU3eMeb5M0mu45FoUmzAOiDfyxUHQFxrKAJESzluvKkGwqH20ZhA1bTKz4Rr)X0ko3B5OKQEebRXnVob0Mb0MNHYjrnNHs1JiKIOl6qtyseK0KMHcp)ZXLjtdfPRa7Ynu)NsXOR486ai3Cc46q2tdA1bT97kIuB0JnBHQIub0Mb0Mm0UppOnbOnCoEbRFxrKEe498OMJHN)54cAZvOnvqBkqRoOvOHCUm8gagcMQhrii7cWi0MbqOnDdLtIAodLQhrii7cWOjmjMBM0mu45FoUmzAOiDfyxUHQFxrKAJESzluvKkG2macTjdTPkpOnbOnCoEbRFxrKEe498OMJHN)54cAZvOnvqBkqRoOvOHCUm8gagcMQhrii7cWi0MbqOnDdLtIAodLQhrii7cWOjmjM6nPzOWZ)CCzY0q5KOMZqnFEfy7bAOiDfyxUHkzODH)NsXAp7PlcYeHtOdAbfAZdAPrdAx4)PuS2ZE6IGSg386eqlOq7(8H2uGwDqB)UIi1g9yZwOQivaTzaeAtgAtvEqBcqB4C8cw)UIi9iW75rnhdp)ZXf0MRqBQG2uGwDqBoqB4C8cMQhrii7cWidp)ZXLHISJWrz4nameMe3BctI7Z3KMHcp)ZXLjtdfPRa7Ynu97kIuB0JnBHQIub0MbqOnzOnv5bTjaTHZXly97kI0JaVNh1Cm88phxqBUcTPcAtXq5KOMZqnFEfy7bActI73BsZqHN)54YKPHI0vGD5gkYm81O)yAfN7TCusvpIG14MxNaAZaA73HSO2qzmYudA1bT97kIuB0JnBHQIub0ck0MA5dT6GwHgY5YWBayiya4oPCU0xGWpccTzaeAt3q5KOMZqbG7KY5sFbc)iOjmjUpDtAgk88phxMmnuojQ5muQEeHueDrhAOiDfyxUHkzODH)NsXAp7PlcYeHtOdAbfAZdAPrdAx4)PuS2ZE6IGSg386eqlOq7(8H2uGwDqlzg(A0FmTIZ9wokPQhrWACZRtaTzaT97qwuBOmgzQbT6G2(DfrQn6XMTqvrQaAbfAtT8HwDqBoqB4C8cMQhrii7cWidp)ZXLHISJWrz4nameMe3BctI7tLjndfE(NJltMgksxb2LBOiZWxJ(JPvCU3Yrjv9icwJBEDcOndOTFhYIAdLXitnOvh02VRisTrp2SfQksfqlOqBQLVHYjrnNHs1JiKIOl6qtycdLwJKz77HjntI7nPzOCsuZzO0MOMZqHN)54YKPjmjMUjndfE(NJltMgQZ3qdLNTaS3UqQMlKJsQn6X2q5KOMZq5zla7TlKQ5c5OKAJESnHjXuzsZqHN)54YKPHA0mucmmuojQ5muGW7Y)C0qbcN)qdvYqlMlVstdxSBIPR5jKa4(Q8yAH87lai0sJg0I5YR00WfJmD)0cCjbW9v5X0c53xaqOLgnOfZLxPPHlgz6(Pf4scG7RYJPfYnC5CEnh0sJg0I5YR00WfdeLZLJs6xT5bUKF(mlOLgnOfZLxPPHlMQAri38afsH2oaCxiGwA0GwmxELMgUy5EOqcE0ZXgAPrdAXC5vAA4IDtmDnpHea3xLhtlKB4Y58AoOLgnOfZLxPPHlMladc)qHS9SNwsM25qBkgkq4T88n0qnbySLZjFcuI5YR00WLjmHHImdFn6pHjntI7nPzOWZ)CCzY0q5KOMZq5zla7TlKQ5c5OKAJESnuKUcSl3qLm0sMHVg9hd30g9yl73Hs9ORnhRrFTdA1bT5aTGW7Y)CKnbySLZjFcuI5YR00Wf0Mc0sJg0Mm0sMHVg9htR4CVLJsQ6reSg386eqlOaH295dT6Gwq4D5FoYMam2Y5KpbkXC5vAA4cAtXqD(gAO8SfG92fs1CHCusTrp2MWKy6M0mu45FoUmzAOCsuZzO4VMoSfY6e1QMNqcOuHHI0vGD5gQW54fSFJEawokPOUv7agHZWZ)CCbT6G2KH2KHwYm81O)yAfN7TCusvpIG14MxNaAbfi0UpFOvh0ccVl)Zr2eGXwoN8jqjMlVstdxqBkqlnAqBYq7)PumTIZ9wokPQhrWEAqRoOnhOfeEx(NJSjaJTCo5tGsmxELMgUG2uG2uGwA0G2KH2)tPyAfN7TCusvpIG90GwDqBoqB4C8c2VrpalhLuu3QDaJWz45FoUG2umuNVHgk(RPdBHSorTQ5jKakvyctIPYKMHcp)ZXLjtdLtIAodfzhHprpxrKFUlcdfPRa7Ynu5aT)NsX0ko3B5OKQEeb7PzOoFdnuKDe(e9Cfr(5UimHjXuZKMHcp)ZXLjtdfPRa7YnujdTKz4Rr)X0ko3B5OKQEebRrFTdAPrdAjZWxJ(JPvCU3Yrjv9icwJBEDcOndOn98H2uGwDqBYqBoqB4C8c2VrpalhLuu3QDaJWz45FoUGwA0GwYm81O)y4M2OhBz)ouQhDT5ynU51jG2mG2uFEqBkgkNe1CgQNaLvGBctysmptAgk88phxMmnuojQ5muUami8dfY2ZEAjzANBOiDfyxUHAH)NsXAp7PLKPDUCH)NsXwJ(ZqD(gAOCbyq4hkKTN90sY0o3eMeb5M0mu45FoUmzAOCsuZzOCbyq4hkKTN90sY0o3qr6kWUCdfzg(A0FmCtB0JTSFhk1JU2CSg386eqBgqBQpFOvh0UW)tPyTN90sY0oxUW)tPypnOvh0ccVl)Zr2eGXwoN8jqjMlVstdxqlnAq7)PuSFJEawokPOUv7agHZEAqRoODH)NsXAp7PLKPDUCH)NsXEAqRoOnhOfeEx(NJSjaJTCo5tGsmxELMgUGwA0G2)tPy4M2OhBz)ouQhDT5ypnOvh0UW)tPyTN90sY0oxUW)tPypnOvh0Md0gohVG9B0dWYrjf1TAhWiCgE(NJlOLgnOnQnugJCvi0ck0M(Ed15BOHYfGbHFOq2E2tljt7CtyseK0KMHcp)ZXLjtdLtIAodvUhkKGh9CSnuKUcSl3qLm0I5YR00WfJ)A6WwiRtuRAEcjGsfqRoO9)ukMwX5ElhLu1JiynU51jG2uGwA0G2KH2CGwmxELMgUy8xth2czDIAvZtibuQaA1bT)NsX0ko3B5OKQEebRXnVob0ck0UpDOvh0(FkftR4CVLJsQ6reSNg0MIH68n0qL7Hcj4rphBtysm3mPzOWZ)CCzY0q5KOMZqr3nHCus)ifEHu96Dgksxb2LBOiZWxJ(JHBAJESL97qPE01MJ14MxNaAZaAtT8nuNVHgk6UjKJs6hPWlKQxVZeMet9M0mu45FoUmzAOCsuZzOa0Zbqi16AZ5Y2bGgksxb2LBO63HqlOaH2ubT6G2CG2)tPyAfN7TCusvpIG90GwDqBYqBoq7)PuSFJEawokPOUv7agHZEAqlnAqBoqB4C8c2VrpalhLuu3QDaJWz45FoUG2umuNVHgka9CaesTU2CUSDaOjmjUpFtAgk88phxMmnuNVHgQ2ZE9o6eYFbq24s(FrmNHYjrnNHQ9SxVJoH8xaKnUK)xeZzctI73BsZqHN)54YKPHYjrnNHAdBKUaSlKk)ayOiDfyxUHkhO9)uk2VrpalhLuu3QDaJWzpnOvh0Md0(FkftR4CVLJsQ6reSNMH68n0qTHnsxa2fsLFamHjX9PBsZqHN)54YKPHI0vGD5gQ)tPyAfN7TCusvpIG90GwDq7)PumCtB0JTSFhk1JU2CSNMHYjrnNHsBIAotysCFQmPzOWZ)CCzY0qr6kWUCd1)PumTIZ9wokPQhrWEAqRoO9)ukgUPn6Xw2VdL6rxBo2tZq5KOMZq95ZSKQxVZeMe3NAM0mu45FoUmzAOiDfyxUH6)ukMwX5ElhLu1JiypndLtIAod1hBb20vhatysCFEM0mu45FoUmzAOiDfyxUHkzOnhO9)ukMwX5ElhLu1JiypnOvh06KOabkXd3kuaTzaeAthAtbAPrdAZbA)pLIPvCU3Yrjv9ic2tdA1bTjdT97q2cvfPcOndGqBEqRoOTFxrKAJESzluvKkG2macTG88H2umuojQ5muEt8dLApUanHjX9GCtAgk88phxMmnuKUcSl3q9FkftR4CVLJsQ6reSNMHYjrnNHIxaahczU3BbydVWeMe3dsAsZqHN)54YKPHI0vGD5gQWBayWIAdLXixfcTzaT7tndLtIAodLaStOJJYamkFN(PdW7mHjX95MjndfE(NJltMgksxb2LBOCsuGaL4HBfkG2mG20HwA0G2)iegkNe1Cgk)pB15rnNKxBFtysCFQ3KMHcp)ZXLjtdfPRa7YnuojkqGs8WTcfqBgqB6qlnAq7FecdLtIAodLqV3B1bqUvIWeMetpFtAgk88phxMmnuKUcSl3q9FkftR4CVLJsQ6reSNg0QdA)pLIHBAJESL97qPE01MJ90muojQ5mu(rqr0oxsCo3eMetFVjndfE(NJltMgksxb2LBO(pLIPvCU3Yrjv9icwJBEDcOfuGqBUbT6G2)tPy4M2OhBz)ouQhDT5ypndLtIAodLQA8ZNzzctIPNUjndfE(NJltMgksxb2LBO(pLIPvCU3Yrjv9ic2tdA1bTjdT)NsX0ko3B5OKQEebRXnVob0ck0Mh0QdAdNJxWidFjbJEhm88phxqlnAqBoqB4C8cgz4ljy07GHN)54cA1bT)NsX0ko3B5OKQEebRXnVob0ck0MkOnfOvh06KOabkXd3kuaTaH29qlnAq7)PumbIb46aiBhaYEAqRoO1jrbcuIhUvOaAbcT7nuojQ5muFhGCuYOlcDctysm9uzsZqHN)54YKPHI0vGD5gQKHwYm81O)y4M2OhBz)ouQhDT5ynU51jGwA0G2W54fSIGexJHN)54cAtbA1bT5aT)NsX0ko3B5OKQEeb7PbT0ObTHZXlyfbjUgdp)ZXf0QdA9SXUcKP6re6bJCnHSUvb48OMJHN)54cA1bT)NsX0ko3B5OKQEebRXnVob0ck0MUHYjrnNHsR4CVLJsQ6reMWKy6PMjndfE(NJltMgksxb2LBOiZWxJ(JHBAJESL97qPE01MJ14MxNaA1bTKz4Rr)X0ko3B5OKQEebRXnVoHHYjrnNH63OhGLJskQB1oGr4gQNaLJsjbqwMe3BctIPNNjndfE(NJltMgksxb2LBOiZWxJ(JPvCU3Yrjv9icwJ(Ah0QdAdNJxWMpVcS9OMJHN)54cA1bT97qwuBOmgzEqBgqlaYcA1bT97kIuB0JnBHQIub0MbqODF(qlnAqBuBOmg5QqOfuOn98nuojQ5mu4M2OhBz)ouQhDT5mHjX0b5M0mu45FoUmzAOiDfyxUHkzOLmdFn6pMwX5ElhLu1Jiyn6RDqlnAqBuBOmg5QqOfuOn98H2uGwDqB4C8c2VrpalhLuu3QDaJWz45FoUGwDqB)UIi1g9ydTzaTG88nuojQ5mu4M2OhBz)ouQhDT5mHjX0bjnPzOWZ)CCzY0qr6kWUCdv4C8cwrqIRXWZ)CCbT6G2(Di0ck0MkdLtIAodfUPn6Xw2VdL6rxBotysm9CZKMHYjrnNHc8oTjaJ9wrKAnkWJGgk88phxMmnHjX0t9M0mu45FoUmzAOiDfyxUHkCoEbJm8Lem6DWWZ)CCbT6G2KH2KH2)tPyKHVKGrVdMiCcDqBgaH295dT6G2f(FkfR9SNUiiteoHoOfi0Mh0Mc0sJg0g1gkJrUkeAbfi0cGSG2umuojQ5mueNZLojQ5K8segkEjc55BOHIm8Lem6DyctIPkFtAgk88phxMmnuKUcSl3qLm0(FkftR4CVLJsQ6reSNg0QdA9SXUcKvKDssf(c5S2p6GwqbcT7HwDqBYq7)PumTIZ9wokPQhrWACZRtaTGceAbqwqlnAq7)PuS3bE47KIOXdqaM14MxNaAbfi0cGSGwDq7)PuS3bE47KIOXdqaM90G2uG2umuojQ5muQEeH(D9MqQE9otysmv7nPzOWZ)CCzY0qr6kWUCdvYq7)PuSIStsQWxiN90GwDqBoqB4C8cwrqIRXWZ)CCbT6G2KH2)tPyVd8W3jfrJhGam7PbT0ObT)NsXkYojPcFHCwJBEDcOfuGqlaYcAtbAtbAPrdA)pLIvKDssf(c5SNg0QdA)pLIvKDssf(c5Sg386eqlOaHwaKf0QdAdNJxWkcsCngE(NJlOvh0(FkftR4CVLJsQ6reSNMHYjrnNHs1Ji0VR3es1R3zctIPkDtAgk88phxMmnuKUcSl3qf1gkJrUkeAbfAbqwqlnAqBYqBuBOmg5QqOfuOLmdFn6pMwX5ElhLu1JiynU51jGwDq7)PuS3bE47KIOXdqaM90G2umuojQ5muQEeH(D9MqQE9otycd1cv(JhM0mjU3KMHYjrnNHARULu1iMnAOWZ)CCzY0eMet3KMHcp)ZXLjtdfPRa7Ynu5aTRjyQEeHuHGaBwue6Qda0QdAtgAZbAdNJxW(n6by5OKI6wTdyeodp)ZXf0sJg0sMHVg9h73OhGLJskQB1oGr4Sg386eqBgq7(8G2umuojQ5muGh986ai)CxeMWKyQmPzOWZ)CCzY0qr6kWUCd1)PuSIStgoFobRXnVob0ckqOfazbT6G2)tPyfzNmC(Cc2tdA1bTcnKZLH3aWqWaWDs5CPVaHFeeAZai0Mo0QdAtgAZbAdNJxW(n6by5OKI6wTdyeodp)ZXf0sJg0sMHVg9h73OhGLJskQB1oGr4Sg386eqBgq7(8G2umuojQ5mua4oPCU0xGWpcActIPMjndfE(NJltMgksxb2LBO(pLIvKDYW5ZjynU51jGwqbcTailOvh0(FkfRi7KHZNtWEAqRoOnzOnhOnCoEb73OhGLJskQB1oGr4m88phxqlnAqlzg(A0FSFJEawokPOUv7agHZACZRtaTzaT7ZdAtXq5KOMZqP6resr0fDOjmjMNjndfE(NJltMgkNe1CgkIZ5sNe1CsEjcdfVeH88n0qHcbEeuyctIGCtAgk88phxMmnuojQ5mueNZLojQ5K8segkEjc55BOHImdFn6pHjmjcsAsZqHN)54YKPHI0vGD5gQ)tPy)g9aSCusrDR2bmcN90muojQ5mu97KojQ5K8segkEjc55BOH6pczue6QdGjmjMBM0mu45FoUmzAOiDfyxUHkCoEb73OhGLJskQB1oGr4m88phxqRoOnzOnzOLmdFn6p2VrpalhLuu3QDaJWznU51jGwGqB(qRoOLmdFn6pMwX5ElhLu1JiynU51jGwqH295dTPaT0ObTjdTKz4Rr)X(n6by5OKI6wTdyeoRXnVob0ck0ME(qRoOnQnugJCvi0ck0MQ8G2uG2umuojQ5mu97KojQ5K8segkEjc55BOH6pcP2m86ayctIPEtAgk88phxMmnuKUcSl3q9FkftR4CVLJsQ6reSNg0QdAdNJxWMpVcS9OMJHN)54Yq5KOMZq1Vt6KOMtYlryO4LiKNVHgQ5ZRaBpQ5mHjX95BsZqHN)54YKPHI0vGD5gkNefiqjE4wHcOndGqB6gkNe1CgQ(DsNe1CsEjcdfVeH88n0q5dActI73BsZqHN)54YKPHYjrnNHI4CU0jrnNKxIWqXlripFdnuIWVL3ltycdLi8B59YKMjX9M0muojQ5munUnTa5Oqi1xxGTHcp)ZXLjttysmDtAgk88phxMmnuKUcSl3qrMHVg9hRXTPfihfcP(6cSznU51jGwqbcTPdT5k0cGSGwDqB4C8cgapaJDDaKIy6ngE(NJldLtIAodLQhrifrx0HMWKyQmPzOWZ)CCzY0qr6kWUCd1)PuSU2q2tZq5KOMZqbE0ZRdG8ZDryctIPMjndfE(NJltMgksxb2LBOcNJxWkcsCngE(NJlOvh0(FkftR4CVLJsQ6reSNg0QdA9SXUcKvKDssf(c5S2p6G2macTPBOCsuZzOMpVcS9anHjX8mPzOWZ)CCzY0qr6kWUCdvoq7)PumvpzJNu7Xfi7PbT6G2W54fmvpzJNu7Xfidp)ZXLHYjrnNHA(8kW2d0eMeb5M0mu45FoUmzAOiDfyxUHQFxrKAJESzluvKkGwqH2KH295bTjaTHZXly97kI0JaVNh1Cm88phxqBUcTPcAtXq5KOMZqP6resr0fDOjmjcsAsZqHN)54YKPHI0vGD5gQ)tPy0vCEDaKBobCDi7PbT6G2(DilQnugJm1G2macTaildLtIAodLQhrii7cWOjmjMBM0mu45FoUmzAOiDfyxUHQFxrKAJESzluvKkG2mG2KH20ZdAtaAdNJxW63vePhbEppQ5y45FoUG2CfAtf0MIHYjrnNHA(8kW2d0eMet9M0muojQ5muQEeHueDrhAOWZ)CCzY0eMe3NVjndLtIAodf4Pp5OK6RlW2qHN)54YKPjmjUFVjndLtIAodL3e)qzmDJxyOWZ)CCzY0eMWqHcbEeuysZK4EtAgk88phxMmnuKUcSl3q9FkftR4CVLJsQ6reSNg0QdAtgA)pLIPvCU3Yrjv9icwJBEDcOfuODF(qRoOnzO9)uk2VrpalhLuu3QDaJWzpnOLgnOnCoEbB(8kW2JAogE(NJlOLgnOnCoEbRiiX1y45FoUGwDqBoqRNn2vGSIStsQWxiNHN)54cAtbAPrdA)pLIvKDssf(c5SNg0QdAdNJxWkcsCngE(NJlOnfOvh0Mm06KOabkXd3kuaTaH29qlnAqBoqB4C8cwrqIRXWZ)CCbTPaT0ObTojkqGs8WTcfqBgaH20HwDqB4C8cwrqIRXWZ)CCbT6GwYm81O)yAfN7TCusvpIG1OV2bT6G2KHwpBSRazfzNKuHVqoR9JoOndGq7EOvh0(FkfRi7KKk8fYzpnOLgnOnhO1Zg7kqwr2jjv4lKZWZ)CCbTPyOCsuZzO(8zwYrjdWOepCBNjmjMUjndfE(NJltMgksxb2LBOYbAdNJxWkcsCngE(NJlOLgnOnCoEbRiiX1y45FoUGwDqRNn2vGSIStsQWxiNHN)54cA1bT)NsX0ko3B5OKQEebRXnVob0ck0cYHwDq7)PumTIZ9wokPQhrWEAqlnAqB4C8cwrqIRXWZ)CCbT6G2CGwpBSRazfzNKuHVqodp)ZXLHYjrnNHcWZ7v5NCuspBSNaSjmjMktAgk88phxMmnuKUcSl3q9FkftR4CVLJsQ6reSg386eqlOqBEqRoO9)ukMwX5ElhLu1JiypnOLgnOnQnugJCvi0ck0MNHYjrnNHIaU4CPiA0PZeMetntAgk88phxMmnuKUcSl3q9FkfRrcDCuiKQPji7PbT0ObT)NsXAKqhhfcPAAckjZ7cSzIWj0bTGcT73BOCsuZzOcWO8D)5DlPAAcActI5zsZqHN)54YKPHI0vGD5gQCG2)tPyAfN7TCusvpIG90GwDqBoq7)PuSFJEawokPOUv7agHZEAgkNe1Cgk1qEcCj9SXUcu(rFZeMeb5M0mu45FoUmzAOiDfyxUHkhO9)ukMwX5ElhLu1JiypnOvh0Md0(Fkf73OhGLJskQB1oGr4SNg0QdAxtWiZrWlApWLuX9nu(F9XACZRtaTaH28nuojQ5muK5i4fTh4sQ4(gActIGKM0mu45FoUmzAOiDfyxUH6)ukMwX5ElhLu1JiypnOLgnO9)ukgUPn6Xw2VdL6rxBo2tdAPrdAjZWxJ(J9B0dWYrjf1TAhWiCwJBEDcOndOfKNp0Ma0UppOLgnOLmD)0IAobRouP8phLr)cWm88phxgkNe1Cgk9tZxGaRt2Oyo)iOjmjMBM0mu45FoUmzAOiDfyxUHkhO9)ukMwX5ElhLu1JiypnOvh0Md0(Fkf73OhGLJskQB1oGr4SNMHYjrnNHQlnnokRtk0CcActIPEtAgk88phxMmnuKUcSl3q9Fkfd30g9yl73Hs9ORnhRXnVob0ck0Mh0QdA)pLI9B0dWYrjf1TAhWiC2tdAPrdAtgA73HSO2qzmY0H2mGwaKf0QdA73veP2OhBOfuOnV8H2umuojQ5muB4207KJsYFKAjxn6BctysCF(M0muojQ5mun6A1bqQ4(gkmu45FoUmzActycdfiWwuZzsm98tp)8ZT0ZndLEVV6aimuPo20MoWf0UpFO1jrnh0Ylriyq6nuA9OkoAOazqlirpIaAZ9HEagAbP4kaGdi9GmOfK6dWteqB65Ne0ME(PNpKEi9GmOn3bSFaqrUli9GmOfKgAtDCe(BHqBUB1TGwqIgXSrgKEqg0csdTGuxlOv5C(3j0bTQPH2NOoaqBQZC)GuMe0M6EajG2sbTACFh2qBDvuEGcOnZHcA)OAAeA1MHxhaOLpakc0wcOLmBACmWfdspidAbPH2ChW(baH2WBayWIAdLXixfcTXaTrTHYyKRcH2yG2NaHw8iZ7cSHwoEacWqB7bySH2aSFqR2e4fLZH2ODbyODHEawWG0dYGwqAOn3z4lOn1f07aA9BbTTtkNdTHE0PtWG0dPhKbTPotDfjVaxq7hvtJqlz2(EaTFeqDcg0csLqqTqaT3CG0G9Et94qRtIAob0ohFhdsVtIAobtRrYS99ibGzPnrnhKENe1CcMwJKz77rcaZ6jqzf4wsNVHa9SfG92fs1CHCusTrp2q6DsuZjyAnsMTVhjamlq4D5FoM05BiWjaJTCo5tGsmxELMgUsceo)HatgZLxPPHl2nX018esaCFvEmTq(9faKgnmxELMgUyKP7NwGljaUVkpMwi)(casJgMlVstdxmY09tlWLea3xLhtlKB4Y58AoA0WC5vAA4IbIY5Yrj9R28axYpFMfnAyU8knnCXuvlc5MhOqk02bG7cbnAyU8knnCXY9qHe8ONJnnAyU8knnCXUjMUMNqcG7RYJPfYnC5CEnhnAyU8knnCXCbyq4hkKTN90sY0opfi9q6bzqBQZuxrYlWf0IGa7DqBuBi0gGrO1jX0qBjGwheEX9phzq6DsuZjaUv3sQAeZgH0dYGwqQAA8DqlirpIaAbjqqGn063cA386cVoOn1bzh0MMZNtaP3jrnNibGzbE0ZRdG8ZDrKuPaMZAcMQhriviiWMffHU6aOl5CcNJxW(n6by5OKI6wTdyeodp)ZXfnAKz4Rr)X(n6by5OKI6wTdyeoRXnVorg7Zlfi9ojQ5ejamlaCNuox6lq4hbtQua)pLIvKDYW5ZjynU51jafiaYs3)PuSIStgoFob7PPtOHCUm8gagcgaUtkNl9fi8JGzamDDjNt4C8c2VrpalhLuu3QDaJWz45FoUOrJmdFn6p2VrpalhLuu3QDaJWznU51jYyFEPaP3jrnNibGzP6resr0fDysLc4)PuSIStgoFobRXnVobOabqw6(pLIvKDYW5ZjypnDjNt4C8c2VrpalhLuu3QDaJWz45FoUOrJmdFn6p2VrpalhLuu3QDaJWznU51jYyFEPaP3jrnNibGzrCox6KOMtYlrK05BiquiWJGci9ojQ5ejamlIZ5sNe1CsEjIKoFdbsMHVg9NasVtIAorcaZQFN0jrnNKxIiPZ3qG)riJIqxDasQua)pLI9B0dWYrjf1TAhWiC2tdsVtIAorcaZQFN0jrnNKxIiPZ3qG)ri1MHxhGKkfWW54fSFJEawokPOUv7agHZWZ)CCPl5KjZWxJ(J9B0dWYrjf1TAhWiCwJBEDcG5RJmdFn6pMwX5ElhLu1JiynU51jaDF(PqJwYKz4Rr)X(n6by5OKI6wTdyeoRXnVobOPNVUO2qzmYvHGMQ8sjfi9ojQ5ejamR(DsNe1CsEjIKoFdboFEfy7rnxsLc4)PumTIZ9wokPQhrWEA6cNJxWMpVcS9OMJHN)54csVtIAorcaZQFN0jrnNKxIiPZ3qG(GjvkGojkqGs8WTcfzamDi9ojQ5ejamlIZ5sNe1CsEjIKoFdbkc)wEVG0dP3jrnNG5dcSXTPfihfcP(6cStQuadNJxWa4bySRdGuetVXWZ)CCrJwYE2yxbYu9KnEYa30qrWA)OtNqd5Cz4nameSg3MwGCuiK6RlWodGPsxo)NsX6AdzpTuG07KOMtW8btaywa4oPCU0xGWpcMuPagohVGP6recYUamYWZ)CCbP3jrnNG5dMaWSu9icPi6IomjYochLH3aWqaCFsLcyYl8)ukw7zpDrqMiCcDGMhnAl8)ukw7zpDrqwJBEDcq3NFk6iZWxJ(J1420cKJcHuFDb2Sg386eGcm9CfazPlCoEbdGhGXUoasrm9gdp)ZXLUCcNJxWu9icbzxagz45FoUG07KOMtW8btaywQEeHueDrhMuPasMHVg9hRXTPfihfcP(6cSznU51jafy65kaYsx4C8cgapaJDDaKIy6ngE(NJli9ojQ5emFWeaMf4rpVoaYp3frsLc4)PuSU2q2tdsVtIAobZhmbGzP6recYUamMuPa(FkfJUIZRdGCZjGRdzpni9ojQ5emFWeaMfaUtkNl9fi8JGjvkG97kIuB0JnBHQIubOjVpVecNJxW63vePhbEppQ5y45FoUY1uLcKENe1CcMpycaZs1JiKIOl6WKi7iCugEdadbW9jvkGjVW)tPyTN90fbzIWj0bAE0OTW)tPyTN90fbznU51jaDF(PORFxrKAJESzluvKkan595Lq4C8cw)UIi9iW75rnhdp)ZXvUMQu0Lt4C8cMQhrii7cWidp)ZXfKENe1CcMpycaZs1JiKIOl6WKkfW(DfrQn6XMTqvrQa0K3NxcHZXly97kI0JaVNh1Cm88phx5AQsrxoHZXlyQEeHGSlaJm88phxq6DsuZjy(GjamRf6byHC9WKkfqNefiqjE4wHImshsVtIAobZhmbGzTqpal9BjxiX3LuPa6KOabkXd3kuKr6q6DsuZjy(GjamRg3MwGCuiK6RlWgsVtIAobZhmbGzP6recYUamcP3jrnNG5dMaWSMpVcS9atISJWrz4namea3NuPaM8c)pLI1E2txeKjcNqhO5rJ2c)pLI1E2txeK14MxNa095NIU(DfrQn6XMTqvrQiJKtpVecNJxW63vePhbEppQ5y45FoUY1uLIUCcNJxWu9icbzxagz45FoUG07KOMtW8btaywZNxb2EGjvkG97kIuB0JnBHQIurgjNEEjeohVG1VRispc8EEuZXWZ)CCLRPkfi9ojQ5emFWeaMfaUtkNl9fi8JGq6DsuZjy(GjamlvpIqkIUOdtISJWrz4namea3NuPaM8c)pLI1E2txeKjcNqhO5rJ2c)pLI1E2txeK14MxNa095NIUCcNJxWu9icbzxagz45FoUG07KOMtW8btaywQEeHueDrhcP3jrnNG5dMaWSap9jhLuFDb2q6DsuZjy(GjamlVj(HYy6gVaspKEqg0MzJEagAhf0sv3QDaJWHwTz41baA7j8OMdAZDbTIW7qaTPNVaA)OAAeAtDxCU3q7OGwqIEeb0Ma0M5qbTEJqRdcV4(NJq6DsuZjy)ri1MHxhaGGh986ai)CxejvkG)NsX6Adzpni9ojQ5eS)iKAZWRdqcaZA(8kW2dmjYochLH3aWqaCFsLcyYl8)ukw7zpDrqMiCcDGMhnAl8)ukw7zpDrqwJBEDcq3NFk663veP2OhB2cvfPImaMEE6YjCoEbt1JieKDbyKHN)54csVtIAob7pcP2m86aKaWSMpVcS9atQua73veP2OhB2cvfPImaMEEq6DsuZjy)ri1MHxhGeaMfaUtkNl9fi8JGjvkG97kIuB0JnBHQIubOPNVoHgY5YWBayiya4oPCU0xGWpcMbW01rMHVg9htR4CVLJsQ6reSg386ezKhKENe1Cc2FesTz41bibGzP6resr0fDysKDeokdVbGHa4(KkfWKx4)PuS2ZE6IGmr4e6anpA0w4)PuS2ZE6IGSg386eGUp)u01VRisTrp2SfQksfGME(6YjCoEbt1JieKDbyKHN)54shzg(A0FmTIZ9wokPQhrWACZRtKrEq6DsuZjy)ri1MHxhGeaMLQhrifrx0HjvkG97kIuB0JnBHQIubOPNVoYm81O)yAfN7TCusvpIG14MxNiJ8G07KOMtW(JqQndVoajamlvpIqq2fGXKkfW)tPy0vCEDaKBobCDi7PPRFxrKAJESzluvKkYi595Lq4C8cw)UIi9iW75rnhdp)ZXvUMQu0j0qoxgEdadbt1JieKDbymdGPdP3jrnNG9hHuBgEDasaywQEeHGSlaJjvkG97kIuB0JnBHQIurgatov5Lq4C8cw)UIi9iW75rnhdp)ZXvUMQu0j0qoxgEdadbt1JieKDbymdGPdP3jrnNG9hHuBgEDasaywZNxb2EGjr2r4Om8gagcG7tQuatEH)NsXAp7PlcYeHtOd08OrBH)NsXAp7PlcYACZRta6(8trx)UIi1g9yZwOQivKbWKtvEjeohVG1VRispc8EEuZXWZ)CCLRPkfD5eohVGP6recYUamYWZ)CCbP3jrnNG9hHuBgEDasaywZNxb2EGjvkG97kIuB0JnBHQIurgatov5Lq4C8cw)UIi9iW75rnhdp)ZXvUMQuG07KOMtW(JqQndVoajamlaCNuox6lq4hbtQuajZWxJ(JPvCU3Yrjv9icwJBEDIm63HSO2qzmYutx)UIi1g9yZwOQivaAQLVoHgY5YWBayiya4oPCU0xGWpcMbW0H07KOMtW(JqQndVoajamlvpIqkIUOdtISJWrz4namea3NuPaM8c)pLI1E2txeKjcNqhO5rJ2c)pLI1E2txeK14MxNa095NIoYm81O)yAfN7TCusvpIG14MxNiJ(DilQnugJm101VRisTrp2SfQksfGMA5RlNW54fmvpIqq2fGrgE(NJli9ojQ5eS)iKAZWRdqcaZs1JiKIOl6WKkfqYm81O)yAfN7TCusvpIG14MxNiJ(DilQnugJm101VRisTrp2SfQksfGMA5dPhspidAbjCo)7e6G2yG2NaH2u3dirsqBQZC)GucT6bJh0(eydsxxfLhOaAZCOGwTg3841iFhdsVtIAob7pczue6QdaqTIZ9wokPQhrKuPasMHVg9hd30g9yl73Hs9ORnhRXnVobKENe1Cc2FeYOi0vhGeaMfUPn6Xw2VdL6rxBoi9ojQ5eS)iKrrORoajamR5ZRaBpWKi7iCugEdadbW9jvkGjVW)tPyTN90fbzIWj0bAE0OTW)tPyTN90fbznU51jaDF(PORFxrKAJESbfyQsxxoHZXlyQEeHGSlaJm88phxq6DsuZjy)riJIqxDasaywZNxb2EGjvkG97kIuB0JnOatv6q6DsuZjy)riJIqxDasaywnUnTa5Oqi1xxGDsLcy4C8cgapaJDDaKIy6ngE(NJli9ojQ5eS)iKrrORoajamlWJEEDaKFUlIKkfW)tPyDTHSNgKENe1Cc2FeYOi0vhGeaM185vGThysKDeokdVbGHa4(KkfWKx4)PuS2ZE6IGmr4e6anpA0w4)PuS2ZE6IGSg386eGUp)u01VdzrTHYyK5bkaYIgT(DfrQn6XguGPwE6YjCoEbt1JieKDbyKHN)54csVtIAob7pczue6QdqcaZA(8kW2dmPsbSFhYIAdLXiZduaKfnA97kIuB0JnOatT8G07KOMtW(JqgfHU6aKaWSu9icbzxagtQua)pLIrxX51bqU5eW1HSNMoHgY5YWBayiyQEeHGSlaJzamDi9ojQ5eS)iKrrORoajamlWtFYrj1xxGDsLcy)UIi1g9yZwOQivKbWuLUU(DilQnugJmvzaGSG07KOMtW(JqgfHU6aKaWSACBAbYrHqQVUaBi9ojQ5eS)iKrrORoajamlvpIqq2fGXKkfqHgY5YWBayiyQEeHGSlaJzamDi9ojQ5eS)iKrrORoajamR5ZRaBpWKi7iCugEdadbW9jvkGjVW)tPyTN90fbzIWj0bAE0OTW)tPyTN90fbznU51jaDF(PORFxrKAJESzluvKkYi98OrRFhMrQ0Lt4C8cMQhrii7cWidp)ZXfKENe1Cc2FeYOi0vhGeaM185vGThysLcy)UIi1g9yZwOQivKr65rJw)omJubP3jrnNG9hHmkcD1bibGz5nXpugt34fjvkG97kIuB0JnBHQIurg5LpKEi9GmOn3z4lOfm6DaTK5wvuZjG07KOMtWidFjbJEhajG96eYrjlcMuPa(FkfJm8Lem6DWeHtOlJ80f1gkJrUkeuaKfKENe1Ccgz4ljy07ibGzra71jKJswemPsbm5)tPycedW1bq2oaK14MxNauaKvk6(pLIjqmaxhaz7aq2tdsVtIAobJm8Lem6DKaWSiG96eYrjlcMuPaM8)PumTIZ9wokPQhrWACZRtakqaKvUM8(eiZWxJ(JP6re631BcP617yn6RDPqJ2)PumTIZ9wokPQhrWACZRtaA)oKf1gkJrMQu09FkftR4CVLJsQ6reSNMUK9SXUcKvKDssf(c5S2p6af4EA0(pLI9B0dWYrjf1TAhWiC2tlfD5eohVGveK4Am88phxq6DsuZjyKHVKGrVJeaMfbSxNqokzrWKkfW)tPyAfN7TCusvpIG14MxNa0Ct3)PuS3bE47KIOXdqaM14MxNauaKvUM8(eiZWxJ(JP6re631BcP617yn6RDPO7)uk27ap8Dsr04biaZACZRtO7)ukMwX5ElhLu1JiypnDj7zJDfiRi7KKk8fYzTF0bkW90O9Fkf73OhGLJskQB1oGr4SNwk6YjCoEbRiiX1y45FoUG07KOMtWidFjbJEhjamlcyVoHCuYIGjvkGj)FkfRi7KKk8fYznU51jan1Or7)ukwr2jjv4lKZACZRtaA)oKf1gkJrMQu09FkfRi7KKk8fYzpnDE2yxbYkYojPcFHCw7hDzamDD58Fkf73OhGLJskQB1oGr4SNMUCcNJxWkcsCngE(NJli9ojQ5emYWxsWO3rcaZIa2RtihLSiysLc4)PuSIStsQWxiN9009Fkf7DGh(oPiA8aeGzpnDE2yxbYkYojPcFHCw7hDzamDD58Fkf73OhGLJskQB1oGr4SNMUCcNJxWkcsCngE(NJli9ojQ5emYWxsWO3rcaZIa2RtihLSiysLc4)PumTIZ9wokPQhrWACZRtaAQP7)ukMwX5ElhLu1JiypnDHZXlyfbjUgdp)ZXLU)tPyKHVKGrVdMiCcDzaCFUPZZg7kqwr2jjv4lKZA)OduG7H07KOMtWidFjbJEhjamlcyVoHCuYIGjvkG)NsX0ko3B5OKQEeb7PPlCoEbRiiX1y45FoU05zJDfiRi7KKk8fYzTF0LbW01L8)PumYWxsWO3bteoHUmaUp1R7)ukwr2jjv4lKZACZRtakaYs3)PuSIStsQWxiN90Or7)uk27ap8Dsr04biaZEA6(pLIrg(scg9oyIWj0LbW95wkq6H07KOMtWiZWxJ(ta8jqzf4wsNVHa9SfG92fs1CHCusTrp2jvkGjtMHVg9hd30g9yl73Hs9ORnhRrFTtxoGW7Y)CKnbySLZjFcuI5YR00Wvk0OLmzg(A0FmTIZ9wokPQhrWACZRtakW95RdeEx(NJSjaJTCo5tGsmxELMgUsbsVtIAobJmdFn6prcaZ6jqzf4wsNVHa5VMoSfY6e1QMNqcOursLcy4C8c2VrpalhLuu3QDaJWz45FoU0LCYKz4Rr)X0ko3B5OKQEebRXnVobOa3NVoq4D5FoYMam2Y5KpbkXC5vAA4kfA0s()ukMwX5ElhLu1JiypnD5acVl)Zr2eGXwoN8jqjMlVstdxPKcnAj)FkftR4CVLJsQ6reSNMUCcNJxW(n6by5OKI6wTdyeodp)ZXvkq6DsuZjyKz4Rr)jsaywpbkRa3s68neizhHprpxrKFUlIKkfWC(pLIPvCU3Yrjv9ic2tdsVtIAobJmdFn6prcaZ6jqzf4MiPsbmzYm81O)yAfN7TCusvpIG1OV2rJgzg(A0FmTIZ9wokPQhrWACZRtKr65NIUKZjCoEb73OhGLJskQB1oGr4m88phx0OrMHVg9hd30g9yl73Hs9ORnhRXnVorgP(8sbsVtIAobJmdFn6prcaZ6jqzf4wsNVHaDbyq4hkKTN90sY0opPsbCH)NsXAp7PLKPDUCH)NsXwJ(dsVtIAobJmdFn6prcaZ6jqzf4wsNVHaDbyq4hkKTN90sY0opPsbKmdFn6pgUPn6Xw2VdL6rxBowJBEDIms95RBH)NsXAp7PLKPDUCH)NsXEA6aH3L)5iBcWylNt(eOeZLxPPHlA0(pLI9B0dWYrjf1TAhWiC2tt3c)pLI1E2tljt7C5c)pLI900Ldi8U8phztagB5CYNaLyU8knnCrJ2)PumCtB0JTSFhk1JU2CSNMUf(FkfR9SNwsM25Yf(Fkf7PPlNW54fSFJEawokPOUv7agHZWZ)CCrJwuBOmg5QqqtFpKENe1Ccgzg(A0FIeaM1tGYkWTKoFdbM7Hcj4rph7KkfWKXC5vAA4IXFnDylK1jQvnpHeqPcD)NsX0ko3B5OKQEebRXnVork0OLCoyU8knnCX4VMoSfY6e1QMNqcOuHU)tPyAfN7TCusvpIG14MxNa09PR7)ukMwX5ElhLu1JiypTuG07KOMtWiZWxJ(tKaWSEcuwbUL05Biq6UjKJs6hPWlKQxVlPsbKmdFn6pgUPn6Xw2VdL6rxBowJBEDImsT8H07KOMtWiZWxJ(tKaWSEcuwbUL05Biqa9CaesTU2CUSDaysLcy)oeuGPsxo)NsX0ko3B5OKQEeb7PPl5C(pLI9B0dWYrjf1TAhWiC2tJgTCcNJxW(n6by5OKI6wTdyeodp)ZXvkq6DsuZjyKz4Rr)jsaywpbkRa3s68ney7zVEhDc5VaiBCj)ViMdsVtIAobJmdFn6prcaZ6jqzf4wsNVHa3WgPla7cPYpajvkG58Fkf73OhGLJskQB1oGr4SNMUC(pLIPvCU3Yrjv9ic2tdsVtIAobJmdFn6prcaZsBIAUKkfW)tPyAfN7TCusvpIG9009Fkfd30g9yl73Hs9ORnh7PbP3jrnNGrMHVg9NibGz95ZSKQxVlPsb8)ukMwX5ElhLu1JiypnD)NsXWnTrp2Y(DOup6AZXEAq6DsuZjyKz4Rr)jsaywFSfytxDasQua)pLIPvCU3Yrjv9ic2tdsVtIAobJmdFn6prcaZYBIFOu7XfysLcyY58FkftR4CVLJsQ6reSNMoNefiqjE4wHImaMEk0OLZ)PumTIZ9wokPQhrWEA6sUFhYwOQivKbW801VRisTrp2SfQksfzaeKNFkq6DsuZjyKz4Rr)jsayw8ca4qiZ9ElaB4fjvkG)NsX0ko3B5OKQEeb7PbP3jrnNGrMHVg9NibGzja7e64OmaJY3PF6a8UKkfWWBayWIAdLXixfMX(udsVtIAobJmdFn6prcaZY)ZwDEuZj512pPsb0jrbcuIhUvOiJ0Pr7pcbKENe1Ccgzg(A0FIeaMLqV3B1bqUvIiPsb0jrbcuIhUvOiJ0Pr7pcbKENe1Ccgzg(A0FIeaMLFeueTZLeNZtQua)pLIPvCU3Yrjv9ic2tt3)PumCtB0JTSFhk1JU2CSNgKENe1Ccgzg(A0FIeaMLQA8ZNzLuPa(FkftR4CVLJsQ6reSg386eGcm309Fkfd30g9yl73Hs9ORnh7PbP3jrnNGrMHVg9NibGz9DaYrjJUi0jsQua)pLIPvCU3Yrjv9ic2ttxY)NsX0ko3B5OKQEebRXnVobO5PlCoEbJm8Lem6DWWZ)CCrJwoHZXlyKHVKGrVdgE(NJlD)NsX0ko3B5OKQEebRXnVobOPkfDojkqGs8WTcfa3tJ2)PumbIb46aiBhaYEA6CsuGaL4HBfkaUhspKEqg0cs0JiGwYm81O)eq6DsuZjyKz4Rr)jsaywAfN7TCusvpIiPsbmzYm81O)y4M2OhBz)ouQhDT5ynU51jOrlCoEbRiiX1y45FoUsrxo)NsX0ko3B5OKQEeb7PrJw4C8cwrqIRXWZ)CCPZZg7kqMQhrOhmY1eY6wfGZJAogE(NJlD)NsX0ko3B5OKQEebRXnVobOPdP3jrnNGrMHVg9NibGz9B0dWYrjf1TAhWi8KEcuokLeazbCFsLcizg(A0FmCtB0JTSFhk1JU2CSg386e6iZWxJ(JPvCU3Yrjv9icwJBEDci9ojQ5emYm81O)ejamlCtB0JTSFhk1JU2CjvkGKz4Rr)X0ko3B5OKQEebRrFTtx4C8c285vGTh1Cm88phx663HSO2qzmY8YaazPRFxrKAJESzluvKkYa4(8PrlQnugJCviOPNpKENe1Ccgzg(A0FIeaMfUPn6Xw2VdL6rxBUKkfWKjZWxJ(JPvCU3Yrjv9icwJ(AhnArTHYyKRcbn98trx4C8c2VrpalhLuu3QDaJWz45FoU01VRisTrp2zaYZhsVtIAobJmdFn6prcaZc30g9yl73Hs9ORnxsLcy4C8cwrqIRXWZ)CCPRFhcAQG07KOMtWiZWxJ(tKaWSaVtBcWyVvePwJc8iiKENe1Ccgzg(A0FIeaMfX5CPtIAojVersNVHajdFjbJEhjvkGHZXlyKHVKGrVdgE(NJlDjN8)PumYWxsWO3bteoHUmaUpFDl8)ukw7zpDrqMiCcDaZlfA0IAdLXixfckqaKvkq6DsuZjyKz4Rr)jsaywQEeH(D9MqQE9UKkfWK)pLIPvCU3Yrjv9ic2ttNNn2vGSIStsQWxiN1(rhOa3Rl5)tPyAfN7TCusvpIG14MxNauGailA0(pLI9oWdFNuenEacWSg386eGceazP7)uk27ap8Dsr04biaZEAPKcKENe1Ccgzg(A0FIeaMLQhrOFxVjKQxVlPsbm5)tPyfzNKuHVqo7PPlNW54fSIGexJHN)54sxY)NsXEh4HVtkIgpaby2tJgT)tPyfzNKuHVqoRXnVobOabqwPKcnA)NsXkYojPcFHC2tt3)PuSIStsQWxiN14MxNauGailDHZXlyfbjUgdp)ZXLU)tPyAfN7TCusvpIG90G07KOMtWiZWxJ(tKaWSu9ic976nHu96DjvkGrTHYyKRcbfazrJwYrTHYyKRcbLmdFn6pMwX5ElhLu1JiynU51j09Fkf7DGh(oPiA8aeGzpTuG0dP3jrnNGHcbEeua8ZNzjhLmaJs8WTDjvkG)NsX0ko3B5OKQEeb7PPl5)tPyAfN7TCusvpIG14MxNa095Rl5)tPy)g9aSCusrDR2bmcN90OrlCoEbB(8kW2JAogE(NJlA0cNJxWkcsCngE(NJlD54zJDfiRi7KKk8fYz45FoUsHgT)tPyfzNKuHVqo7PPlCoEbRiiX1y45FoUsrxYojkqGs8WTcfa3tJwoHZXlyfbjUgdp)ZXvk0O5KOabkXd3kuKbW01fohVGveK4Am88phx6iZWxJ(JPvCU3Yrjv9icwJ(ANUK9SXUcKvKDssf(c5S2p6Ya4ED)NsXkYojPcFHC2tJgTC8SXUcKvKDssf(c5m88phxPaP3jrnNGHcbEeuKaWSa88Ev(jhL0Zg7jaNuPaMt4C8cwrqIRXWZ)CCrJw4C8cwrqIRXWZ)CCPZZg7kqwr2jjv4lKZWZ)CCP7)ukMwX5ElhLu1JiynU51jafKR7)ukMwX5ElhLu1JiypnA0cNJxWkcsCngE(NJlD54zJDfiRi7KKk8fYz45FoUG07KOMtWqHapcksayweWfNlfrJoDjvkG)NsX0ko3B5OKQEebRXnVobO5P7)ukMwX5ElhLu1JiypnA0IAdLXixfcAEq6DsuZjyOqGhbfjamRamkF3FE3sQMMGjvkG)NsXAKqhhfcPAAcYEA0O9FkfRrcDCuiKQPjOKmVlWMjcNqhO73dP3jrnNGHcbEeuKaWSud5jWL0Zg7kq5h9TKkfWC(pLIPvCU3Yrjv9ic2ttxo)NsX(n6by5OKI6wTdyeo7PbP3jrnNGHcbEeuKaWSiZrWlApWLuX9nmPsbmN)tPyAfN7TCusvpIG900LZ)PuSFJEawokPOUv7agHZEA6wtWiZrWlApWLuX9nu(F9XACZRtamFi9ojQ5emuiWJGIeaML(P5lqG1jBumNFemPsb8)ukMwX5ElhLu1JiypnA0(pLIHBAJESL97qPE01MJ90OrJmdFn6p2VrpalhLuu3QDaJWznU51jYaKNFc7ZJgnY09tlQ5eS6qLY)Cug9laZWZ)CCbP3jrnNGHcbEeuKaWS6stJJY6KcnNGjvkG58FkftR4CVLJsQ6reSNMUC(pLI9B0dWYrjf1TAhWiC2tdsVtIAobdfc8iOibGzTHBtVtokj)rQLC1OVjsQua)pLIHBAJESL97qPE01MJ14MxNa0809Fkf73OhGLJskQB1oGr4SNgnAj3VdzrTHYyKPNbaYsx)UIi1g9ydAE5NcKENe1Ccgke4rqrcaZQrxRoasf33qbKEi9GmOn39pVcS9OMdA7j8OMdsVtIAobB(8kW2JAoGnUnTa5Oqi1xxGDsLcy4C8cgapaJDDaKIy6ngE(NJli9ojQ5eS5ZRaBpQ5saywZNxb2EGjr2r4Om8gagcG7tQuatEH)NsXAp7PlcYeHtOd08OrBH)NsXAp7PlcYACZRta6(8trxoHZXlyQEeHGSlaJm88phx6Y5)ukwxBi7PPtOHCUm8gagcg4rpVoaYp3frgatfKENe1Cc285vGTh1CjamR5ZRaBpWKkfWCcNJxWu9icbzxagz45FoU0LZ)PuSU2q2ttNqd5Cz4namemWJEEDaKFUlImaMki9ojQ5eS5ZRaBpQ5saywQEeHGSlaJjvkGj)FkfJUIZRdGCZjGRdzn6KGgTK)pLIrxX51bqU5eW1HSNMUK1AeesaKfBpt1JiKIOl6qA00AeesaKfBpd8ONxha5N7IGgnTgbHeazX2ZaWDs5CPVaHFemLusrNqd5Cz4namemvpIqq2fGXmaMoKENe1Cc285vGTh1CjamR5ZRaBpWKi7iCugEdadbW9jvkGjVW)tPyTN90fbzIWj0bAE0OTW)tPyTN90fbznU51jaDF(PO7)ukgDfNxha5MtaxhYA0jbnAj)FkfJUIZRdGCZjGRdzpnDjR1iiKail2EMQhrifrx0H0OP1iiKail2Eg4rpVoaYp3fbnAAnccjaYITNbG7KY5sFbc)iykPaP3jrnNGnFEfy7rnxcaZA(8kW2dmPsb8)ukgDfNxha5MtaxhYA0jbnAj)FkfJUIZRdGCZjGRdzpnDjR1iiKail2EMQhrifrx0H0OP1iiKail2Eg4rpVoaYp3fbnAAnccjaYITNbG7KY5sFbc)iykPaP3jrnNGnFEfy7rnxcaZAHEawixpmPsb0jrbcuIhUvOiJ0H07KOMtWMpVcS9OMlbGzTqpal9BjxiX3LuPa6KOabkXd3kuKr6q6DsuZjyZNxb2EuZLaWSaWDs5CPVaHFemPsbm5C(pLI11gYEA0O1VRisTrp2SfQksfGUpFA063HSO2qzmY0ZaazLIoHgY5YWBayiya4oPCU0xGWpcMbW0H07KOMtWMpVcS9OMlbGzbE0ZRdG8ZDrKuPa(FkfRRnK900j0qoxgEdadbd8ONxha5N7IidGPdP3jrnNGnFEfy7rnxcaZs1JiKIOl6WKi7iCugEdadbW9jvkGjVW)tPyTN90fbzIWj0bAE0OTW)tPyTN90fbznU51jaDF(POlN)tPyDTHSNgnA97kIuB0JnBHQIubO7ZNgT(DilQnugJm9maqw6YjCoEbt1JieKDbyKHN)54csVtIAobB(8kW2JAUeaMLQhrifrx0HjvkG58FkfRRnK90OrRFxrKAJESzluvKkaDF(0O1VdzrTHYyKPNbaYcsVtIAobB(8kW2JAUeaMf4rpVoaYp3frsLc4)PuSU2q2tdsVtIAobB(8kW2JAUeaM185vGThysKDeokdVbGHa4(KkfWKx4)PuS2ZE6IGmr4e6anpA0w4)PuS2ZE6IGSg386eGUp)u0Lt4C8cMQhrii7cWidp)ZXfKENe1Cc285vGTh1CjamR5ZRaBpqi9q6bzqlv43Y7f0kQdahbPdVbGb02t4rnhKENe1CcMi8B59cyJBtlqokes91fydP3jrnNGjc)wEVsaywQEeHueDrhMuPasMHVg9hRXTPfihfcP(6cSznU51jafy65kaYsx4C8cgapaJDDaKIy6ngE(NJli9ojQ5emr43Y7vcaZc8ONxha5N7IiPsb8)ukwxBi7PbP3jrnNGjc)wEVsaywZNxb2EGjvkGHZXlyfbjUgdp)ZXLU)tPyAfN7TCusvpIG9005zJDfiRi7KKk8fYzTF0LbW0H07KOMtWeHFlVxjamR5ZRaBpWKkfWC(pLIP6jB8KApUazpnDHZXlyQEYgpP2JlqgE(NJli9ojQ5emr43Y7vcaZs1JiKIOl6WKkfW(DfrQn6XMTqvrQa0K3NxcHZXly97kI0JaVNh1Cm88phx5AQsbsVtIAobte(T8ELaWSu9icbzxagtQua)pLIrxX51bqU5eW1HSNMU(DilQnugJm1YaiaYcsVtIAobte(T8ELaWSMpVcS9atQua73veP2OhB2cvfPImso98siCoEbRFxrKEe498OMJHN)54kxtvkq6DsuZjyIWVL3ReaMLQhrifrx0Hq6DsuZjyIWVL3ReaMf4Pp5OK6RlWgsVtIAobte(T8ELaWS8M4hkJPB8cdLqdjMetpV9MWegda]] )
    
end
