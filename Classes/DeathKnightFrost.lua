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
        end

        if amt > 0 and resource == "runes" and active_dot.shackle_the_unworthy > 0 then
            reduceCooldown( "shackle_the_unworthy", 4 * amt )
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
            cooldown = function () return legendary.absolute_zero.enabled and 90 or 180 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 341980,

            handler = function ()
                applyDebuff( "target", "frost_breath" )
                
                if legendary.absolute_zero.enabled then applyDebuff( "target", "absolute_zero" ) end                
            end,

            auras = {
                -- Legendary.
                absolute_zero = {
                    id = 334693,
                    duration = 3,
                    max_stack = 1,
                }
            }
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

                if legendary.rage_of_the_frozen_champion.enabled and buff.rime.up then
                    gain( 8, "runic_power" )
                end

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
                -- Koltira's Favor is not predictable.
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

                if active_enemies > 2 and legendary.biting_cold.enabled then
                    applyBuff( "rime" )
                end

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

    
    spec:RegisterPack( "Frost DK", 20200828.3, [[dKKxxcqirvEequ2ePYOejoLiPvjQqVsemlrKBbeP2fk)suYWev1XuQAzIu9mruMMiQCnrL2gqu9nGizCIkY5ervTorfLmpG09a0(efoiqe1cff9qrfftuurvUOiQI2iqegPiQsCsrufwjsvVeiI4MIkkLDkc9trfLQHkIQulvurv9uKmvrkFfiI0EP4VenykDyQwSQ6XiMSsUm0Mj5ZamAG60swTOIkVgPYSr1Tvk7wLFRy4KYXfvWYL65eMUW1vLTde(oPQXlIQKoVsL1lk18rk7h0M9M0mulpqtIPNF65NFoLEoXsp9CZPKdKBOIDAOHsZj05aqd15BOHcKOhraT58ajXqP574JVmPzOeZRjOHcCeAICwzLfGka)(mYSLLO2ECpQ5iTRISe1gjld1)v8i5Xz(gQLhOjX0Zp98ZpNspNyPNEU5uYLRHYFb4Pnuu1woJHcCTw4z(gQfkigkqg0cs0JiG2CEOhGHwqsUca4aspidAbj)a8eb0MEoLe0ME(PNpKEi9GmOnNbSFaqroli9GmOfKgAtECe(BHqBoB1TGwqIgXSrgKEqg0csdTGKxlOv5C(3j0bTQPH2NOoaqBYZC(GKMe0M8EajG2sbTACFh2qBDvuEGcOnZHcA)OAAeA1MHxhaOLpakc0wcOLmBACmWfdspidAbPH2CgW(baH2WBayWIAdLXixfcTXaTrTHYyKRcH2yG2NaHw8iZ7cSHwoEacWqB7bySH2aSFqR2e4fLZH2ODbyODHEawWG0dYGwqAOnNz4lOn5f07aA9BbTTtkNdTHE0PtWmu8sectAgkYWxsWO3HjntI7nPzOWZ)CCzY0qr6kWUCd1)PumYWxsWO3bteoHoOndOnxOvh0g1gkJrUkeAbfAbqwgkNe1CgkcyVoHCuYIGMWKy6M0mu45FoUmzAOiDfyxUHkfO9)ukMaXaCDaKTdaznU51jGwqHwaKf0Mk0QdA)pLIjqmaxhaz7aq2tZq5KOMZqra71jKJswe0eMetMjndfE(NJltMgksxb2LBOsbA)pLIPvCU3Yrjv9icwJBEDcOfuGqlaYcAZrOnfODp0Ma0sMHVg9ht1Ji0VR3es1R3XA0x7G2uHwA0G2)tPyAfN7TCusvpIG14MxNaAbfA73HSO2qzmYKbTPcT6G2)tPyAfN7TCusvpIG90GwDqBkqRNn2vGSIStsQWxiN1(rh0ckqODp0sJg0(Fkf73OhGLJskQB1oGr4SNg0Mk0QdAZdAdNJxWkcsCngE(NJldLtIAodfbSxNqokzrqtysm5mPzOWZ)CCzY0qr6kWUCd1)PumTIZ9wokPQhrWACZRtaTGcT5e0QdA)pLI9oWdFNuenEacWSg386eqlOqlaYcAZrOnfODp0Ma0sMHVg9ht1Ji0VR3es1R3XA0x7G2uHwDq7)PuS3bE47KIOXdqaM14MxNaA1bT)NsX0ko3B5OKQEeb7PbT6G2uGwpBSRazfzNKuHVqoR9JoOfuGq7EOLgnO9)uk2VrpalhLuu3QDaJWzpnOnvOvh0Mh0gohVGveK4Am88phxgkNe1CgkcyVoHCuYIGMWKyUM0mu45FoUmzAOiDfyxUHkfO9)ukwr2jjv4lKZACZRtaTGcTjh0sJg0(FkfRi7KKk8fYznU51jGwqH2(DilQnugJmzqBQqRoO9)ukwr2jjv4lKZEAqRoO1Zg7kqwr2jjv4lKZA)OdAZai0Mo0QdAZdA)pLI9B0dWYrjf1TAhWiC2tdA1bT5bTHZXlyfbjUgdp)ZXLHYjrnNHIa2RtihLSiOjmjcYnPzOWZ)CCzY0qr6kWUCd1)PuSIStsQWxiN90GwDq7)PuS3bE47KIOXdqaM90GwDqRNn2vGSIStsQWxiN1(rh0MbqOnDOvh0Mh0(Fkf73OhGLJskQB1oGr4SNg0QdAZdAdNJxWkcsCngE(NJldLtIAodfbSxNqokzrqtyseKYKMHcp)ZXLjtdfPRa7Ynu)NsX0ko3B5OKQEebRXnVob0ck0MCqRoO9)ukMwX5ElhLu1JiypnOvh0gohVGveK4Am88phxqRoO9)ukgz4ljy07GjcNqh0MbqODFobT6GwpBSRazfzNKuHVqoR9JoOfuGq7EdLtIAodfbSxNqokzrqtysmNmPzOWZ)CCzY0qr6kWUCd1)PumTIZ9wokPQhrWEAqRoOnCoEbRiiX1y45FoUGwDqRNn2vGSIStsQWxiN1(rh0MbqOnDOvh0Mc0(FkfJm8Lem6DWeHtOdAZai0Up5dT6G2)tPyfzNKuHVqoRXnVob0ck0cGSGwDq7)PuSIStsQWxiN90GwA0G2)tPyVd8W3jfrJhGam7PbT6G2)tPyKHVKGrVdMiCcDqBgaH295e0MQHYjrnNHIa2RtihLSiOjmHHA(8kW2JAotAMe3BsZqHN)54YKPHI0vGD5gQW54fmaEag76aifX0Bm88phxgkNe1CgQg3MwGCuiK6RlW2eMet3KMHcp)ZXLjtdLtIAod185vGThOHI0vGD5gQuG2f(FkfR9SNUiiteoHoOfuOnxOLgnODH)NsXAp7PlcYACZRtaTGcT7ZhAtfA1bT5bTHZXlyQEeHGSlaJm88phxqRoOnpO9)ukwxBi7PbT6GwHgY5YWBayiyGh986ai)CxeqBgaH2KzOi7iCugEdadHjX9MWKyYmPzOWZ)CCzY0qr6kWUCdvEqB4C8cMQhrii7cWidp)ZXf0QdAZdA)pLI11gYEAqRoOvOHCUm8gagcg4rpVoaYp3fb0MbqOnzgkNe1CgQ5ZRaBpqtysm5mPzOWZ)CCzY0qr6kWUCdvkq7)Pum6koVoaYnNaUoK1OtcOLgnOnfO9)ukgDfNxha5MtaxhYEAqRoOnfOvRrqibqwS9mvpIqkIUOdHwA0GwTgbHeazX2Zap651bq(5UiGwA0GwTgbHeazX2ZaWDs5CPVaHFeeAtfAtfAtfA1bTcnKZLH3aWqWu9icbzxagH2macTPBOCsuZzOu9icbzxagnHjXCnPzOWZ)CCzY0q5KOMZqnFEfy7bAOiDfyxUHkfODH)NsXAp7PlcYeHtOdAbfAZfAPrdAx4)PuS2ZE6IGSg386eqlOq7(8H2uHwDq7)Pum6koVoaYnNaUoK1OtcOLgnOnfO9)ukgDfNxha5MtaxhYEAqRoOnfOvRrqibqwS9mvpIqkIUOdHwA0GwTgbHeazX2Zap651bq(5UiGwA0GwTgbHeazX2ZaWDs5CPVaHFeeAtfAt1qr2r4Om8gagctI7nHjrqUjndfE(NJltMgksxb2LBO(pLIrxX51bqU5eW1HSgDsaT0ObTPaT)NsXOR486ai3Cc46q2tdA1bTPaTAnccjaYITNP6resr0fDi0sJg0Q1iiKail2Eg4rpVoaYp3fb0sJg0Q1iiKail2EgaUtkNl9fi8JGqBQqBQgkNe1CgQ5ZRaBpqtyseKYKMHcp)ZXLjtdfPRa7YnuojkqGs8WTcfqBgqB6gkNe1CgQf6byHC9qtysmNmPzOWZ)CCzY0qr6kWUCdLtIceOepCRqb0Mb0MUHYjrnNHAHEaw63sUqIVZeMet(M0mu45FoUmzAOiDfyxUHkfOnpO9)ukwxBi7PbT0ObT97kIuB0JnBHQIub0ck0UpFOLgnOTFhYIAdLXithAZaAbqwqBQqRoOvOHCUm8gagcgaUtkNl9fi8JGqBgaH20nuojQ5mua4oPCU0xGWpcActI7Z3KMHcp)ZXLjtdfPRa7Ynu)NsX6AdzpnOvh0k0qoxgEdadbd8ONxha5N7IaAZai0MUHYjrnNHc8ONxha5N7IWeMe3V3KMHcp)ZXLjtdLtIAodLQhrifrx0Hgksxb2LBOsbAx4)PuS2ZE6IGmr4e6GwqH2CHwA0G2f(FkfR9SNUiiRXnVob0ck0UpFOnvOvh0Mh0(FkfRRnK90GwA0G2(DfrQn6XMTqvrQaAbfA3Np0sJg02VdzrTHYyKPdTzaTailOvh0Mh0gohVGP6recYUamYWZ)CCzOi7iCugEdadHjX9MWK4(0nPzOWZ)CCzY0qr6kWUCdvEq7)PuSU2q2tdAPrdA73veP2OhB2cvfPcOfuODF(qlnAqB)oKf1gkJrMo0Mb0cGSmuojQ5muQEeHueDrhActI7tMjndfE(NJltMgksxb2LBO(pLI11gYEAgkNe1CgkWJEEDaKFUlctysCFYzsZqHN)54YKPHYjrnNHA(8kW2d0qr6kWUCdvkq7c)pLI1E2txeKjcNqh0ck0Ml0sJg0UW)tPyTN90fbznU51jGwqH295dTPcT6G28G2W54fmvpIqq2fGrgE(NJldfzhHJYWBayimjU3eMe3NRjndLtIAod185vGThOHcp)ZXLjttycd1FeYOi0vhatAMe3BsZqHN)54YKPHI0vGD5gkYm81O)y4M2OhBz)ouQhDT5ynU51jmuojQ5muAfN7TCusvpIWeMet3KMHYjrnNHc30g9yl73Hs9ORnNHcp)ZXLjttysmzM0mu45FoUmzAOCsuZzOMpVcS9anuKUcSl3qLc0UW)tPyTN90fbzIWj0bTGcT5cT0ObTl8)ukw7zpDrqwJBEDcOfuODF(qBQqRoOTFxrKAJESHwqbcTjlDOvh0Mh0gohVGP6recYUamYWZ)CCzOi7iCugEdadHjX9MWKyYzsZqHN)54YKPHI0vGD5gQ(DfrQn6XgAbfi0MS0nuojQ5muZNxb2EGMWKyUM0mu45FoUmzAOiDfyxUHkCoEbdGhGXUoasrm9gdp)ZXLHYjrnNHQXTPfihfcP(6cSnHjrqUjndfE(NJltMgksxb2LBO(pLI11gYEAgkNe1CgkWJEEDaKFUlctyseKYKMHcp)ZXLjtdLtIAod185vGThOHI0vGD5gQuG2f(FkfR9SNUiiteoHoOfuOnxOLgnODH)NsXAp7PlcYACZRtaTGcT7ZhAtfA1bT97qwuBOmgzUqlOqlaYcAPrdA73veP2OhBOfuGqBYLl0QdAZdAdNJxWu9icbzxagz45FoUmuKDeokdVbGHWK4EtysmNmPzOWZ)CCzY0qr6kWUCdv)oKf1gkJrMl0ck0cGSGwA0G2(DfrQn6XgAbfi0MC5AOCsuZzOMpVcS9anHjXKVjndfE(NJltMgksxb2LBO(pLIrxX51bqU5eW1HSNg0QdAfAiNldVbGHGP6recYUamcTzaeAt3q5KOMZqP6recYUamActI7Z3KMHcp)ZXLjtdfPRa7Ynu97kIuB0JnBHQIub0MbqOnzPdT6G2(DilQnugJmzqBgqlaYYq5KOMZqbE6tokP(6cSnHjX97nPzOCsuZzOACBAbYrHqQVUaBdfE(NJltMMWK4(0nPzOWZ)CCzY0qr6kWUCdLqd5Cz4namemvpIqq2fGrOndGqB6gkNe1CgkvpIqq2fGrtysCFYmPzOWZ)CCzY0q5KOMZqnFEfy7bAOiDfyxUHkfODH)NsXAp7PlcYeHtOdAbfAZfAPrdAx4)PuS2ZE6IGSg386eqlOq7(8H2uHwDqB)UIi1g9yZwOQivaTzaTPNl0sJg02VdH2mG2KbT6G28G2W54fmvpIqq2fGrgE(NJldfzhHJYWBayimjU3eMe3NCM0mu45FoUmzAOiDfyxUHQFxrKAJESzluvKkG2mG20ZfAPrdA73HqBgqBYmuojQ5muZNxb2EGMWK4(CnPzOWZ)CCzY0qr6kWUCdv)UIi1g9yZwOQivaTzaT5MVHYjrnNHYBIFOmMUXlmHjmuOqGhbfM0mjU3KMHcp)ZXLjtdfPRa7Ynu)NsX0ko3B5OKQEeb7PbT6G2uG2)tPyAfN7TCusvpIG14MxNaAbfA3Np0QdAtbA)pLI9B0dWYrjf1TAhWiC2tdAPrdAdNJxWMpVcS9OMJHN)54cAPrdAdNJxWkcsCngE(NJlOvh0Mh06zJDfiRi7KKk8fYz45FoUG2uHwA0G2)tPyfzNKuHVqo7PbT6G2W54fSIGexJHN)54cAtfA1bTPaTojkqGs8WTcfqlqODp0sJg0Mh0gohVGveK4Am88phxqBQqlnAqRtIceOepCRqb0MbqOnDOvh0gohVGveK4Am88phxqRoOLmdFn6pMwX5ElhLu1Jiyn6RDqRoOnfO1Zg7kqwr2jjv4lKZA)OdAZai0UhA1bT)NsXkYojPcFHC2tdAPrdAZdA9SXUcKvKDssf(c5m88phxqBQgkNe1CgQpFMLCuYamkXd32zctIPBsZqHN)54YKPHI0vGD5gQ8G2W54fSIGexJHN)54cAPrdAdNJxWkcsCngE(NJlOvh06zJDfiRi7KKk8fYz45FoUGwDq7)PumTIZ9wokPQhrWACZRtaTGcTGCOvh0(FkftR4CVLJsQ6reSNg0sJg0gohVGveK4Am88phxqRoOnpO1Zg7kqwr2jjv4lKZWZ)CCzOCsuZzOa88Ev(jhL0Zg7jaBctIjZKMHcp)ZXLjtdfPRa7Ynu)NsX0ko3B5OKQEebRXnVob0ck0Ml0QdA)pLIPvCU3Yrjv9ic2tdAPrdAJAdLXixfcTGcT5AOCsuZzOiGloxkIgD6mHjXKZKMHcp)ZXLjtdfPRa7Ynu)NsXAKqhhfcPAAcYEAqlnAq7)PuSgj0XrHqQMMGsY8UaBMiCcDqlOq7(9gkNe1CgQamkF3FE3sQMMGMWKyUM0mu45FoUmzAOiDfyxUHkpO9)ukMwX5ElhLu1JiypnOvh0Mh0(Fkf73OhGLJskQB1oGr4SNMHYjrnNHsnKNaxspBSRaLF03mHjrqUjndfE(NJltMgksxb2LBOYdA)pLIPvCU3Yrjv9ic2tdA1bT5bT)NsX(n6by5OKI6wTdyeo7PbT6G21emYCe8I2dCjvCFdL)xFSg386eqlqOnFdLtIAodfzocEr7bUKkUVHMWKiiLjndfE(NJltMgksxb2LBO(pLIPvCU3Yrjv9ic2tdAPrdA)pLIHBAJESL97qPE01MJ90GwA0GwYm81O)y)g9aSCusrDR2bmcN14MxNaAZaAb55dTjaT7ZfAPrdAjt3pTOMtWQdvk)Zrz0Vamdp)ZXLHYjrnNHs)08fiW6KnkMZpcActI5KjndfE(NJltMgksxb2LBOYdA)pLIPvCU3Yrjv9ic2tdA1bT5bT)NsX(n6by5OKI6wTdyeo7PzOCsuZzO6stJJY6KcnNGMWKyY3KMHcp)ZXLjtdfPRa7Ynu)NsXWnTrp2Y(DOup6AZXACZRtaTGcT5cT6G2)tPy)g9aSCusrDR2bmcN90GwA0G2uG2(DilQnugJmDOndOfazbT6G2(DfrQn6XgAbfAZnFOnvdLtIAod1gUn9o5OK8hPwYvJ(MWeMe3NVjndLtIAodvJUwDaKkUVHcdfE(NJltMMWegQ)iKAZWRdGjntI7nPzOWZ)CCzY0qr6kWUCd1)PuSU2q2tZq5KOMZqbE0ZRdG8ZDryctIPBsZqHN)54YKPHYjrnNHA(8kW2d0qr6kWUCdvkq7c)pLI1E2txeKjcNqh0ck0Ml0sJg0UW)tPyTN90fbznU51jGwqH295dTPcT6G2(DfrQn6XMTqvrQaAZai0MEUqRoOnpOnCoEbt1JieKDbyKHN)54Yqr2r4Om8gagctI7nHjXKzsZqHN)54YKPHI0vGD5gQ(DfrQn6XMTqvrQaAZai0MEUgkNe1CgQ5ZRaBpqtysm5mPzOWZ)CCzY0qr6kWUCdv)UIi1g9yZwOQivaTGcTPNp0QdAfAiNldVbGHGbG7KY5sFbc)ii0MbqOnDOvh0sMHVg9htR4CVLJsQ6reSg386eqBgqBUgkNe1CgkaCNuox6lq4hbnHjXCnPzOWZ)CCzY0q5KOMZqP6resr0fDOHI0vGD5gQuG2f(FkfR9SNUiiteoHoOfuOnxOLgnODH)NsXAp7PlcYACZRtaTGcT7ZhAtfA1bT97kIuB0JnBHQIub0ck0ME(qRoOnpOnCoEbt1JieKDbyKHN)54cA1bTKz4Rr)X0ko3B5OKQEebRXnVob0Mb0MRHISJWrz4nameMe3BctIGCtAgk88phxMmnuKUcSl3q1VRisTrp2SfQksfqlOqB65dT6GwYm81O)yAfN7TCusvpIG14MxNaAZaAZ1q5KOMZqP6resr0fDOjmjcszsZqHN)54YKPHI0vGD5gQ)tPy0vCEDaKBobCDi7PbT6G2(DfrQn6XMTqvrQaAZaAtbA3Nl0Ma0gohVG1VRispc8EEuZXWZ)CCbT5i0MmOnvOvh0k0qoxgEdadbt1JieKDbyeAZai0MUHYjrnNHs1JieKDby0eMeZjtAgk88phxMmnuKUcSl3q1VRisTrp2SfQksfqBgaH2uG2KLl0Ma0gohVG1VRispc8EEuZXWZ)CCbT5i0MmOnvOvh0k0qoxgEdadbt1JieKDbyeAZai0MUHYjrnNHs1JieKDby0eMet(M0mu45FoUmzAOCsuZzOMpVcS9anuKUcSl3qLc0UW)tPyTN90fbzIWj0bTGcT5cT0ObTl8)ukw7zpDrqwJBEDcOfuODF(qBQqRoOTFxrKAJESzluvKkG2macTPaTjlxOnbOnCoEbRFxrKEe498OMJHN)54cAZrOnzqBQqRoOnpOnCoEbt1JieKDbyKHN)54Yqr2r4Om8gagctI7nHjX95BsZqHN)54YKPHI0vGD5gQ(DfrQn6XMTqvrQaAZai0Mc0MSCH2eG2W54fS(Dfr6rG3ZJAogE(NJlOnhH2KbTPAOCsuZzOMpVcS9anHjX97nPzOWZ)CCzY0qr6kWUCdfzg(A0FmTIZ9wokPQhrWACZRtaTzaT97qwuBOmgzYbT6G2(DfrQn6XMTqvrQaAbfAtU8HwDqRqd5Cz4namemaCNuox6lq4hbH2macTPBOCsuZzOaWDs5CPVaHFe0eMe3NUjndfE(NJltMgkNe1CgkvpIqkIUOdnuKUcSl3qLc0UW)tPyTN90fbzIWj0bTGcT5cT0ObTl8)ukw7zpDrqwJBEDcOfuODF(qBQqRoOLmdFn6pMwX5ElhLu1JiynU51jG2mG2(DilQnugJm5GwDqB)UIi1g9yZwOQivaTGcTjx(qRoOnpOnCoEbt1JieKDbyKHN)54Yqr2r4Om8gagctI7nHjX9jZKMHcp)ZXLjtdfPRa7YnuKz4Rr)X0ko3B5OKQEebRXnVob0Mb02VdzrTHYyKjh0QdA73veP2OhB2cvfPcOfuOn5Y3q5KOMZqP6resr0fDOjmHHsRrYS99WKMjX9M0muojQ5muAtuZzOWZ)CCzY0eMet3KMHcp)ZXLjtd15BOHYZwa2BxivZfYrj1g9yBOCsuZzO8SfG92fs1CHCusTrp2MWKyYmPzOWZ)CCzY0qnAgkbggkNe1Cgkq4D5FoAOaHZFOHkfOfZHxPPHl2nX018esaCFvEmTq(9faeAPrdAXC4vAA4IrMUFAbUKa4(Q8yAH87lai0sJg0I5WR00WfJmD)0cCjbW9v5X0c5gUCoVMdAPrdAXC4vAA4IbIY5Yrj9R28axYpFMf0sJg0I5WR00WftvTiKBEGcPqBhaUleqlnAqlMdVstdxSCouibp65ydT0ObTyo8knnCXUjMUMNqcG7RYJPfYnC5CEnh0sJg0I5WR00WfZfGbHFOq2E2tljt7COnvdfi8wE(gAOMam2Y5KpbkXC4vAA4YeMWqrMHVg9NWKMjX9M0mu45FoUmzAOCsuZzO8SfG92fs1CHCusTrp2gksxb2LBOsbAjZWxJ(JHBAJESL97qPE01MJ1OV2bT6G28Gwq4D5FoYMam2Y5KpbkXC4vAA4cAtfAPrdAtbAjZWxJ(JPvCU3Yrjv9icwJBEDcOfuGq7(8HwDqli8U8phztagB5CYNaLyo8knnCbTPAOoFdnuE2cWE7cPAUqokP2OhBtysmDtAgk88phxMmnuojQ5mu8xth2czDIAvZtibuQWqr6kWUCdv4C8c2VrpalhLuu3QDaJWz45FoUGwDqBkqBkqlzg(A0FmTIZ9wokPQhrWACZRtaTGceA3Np0QdAbH3L)5iBcWylNt(eOeZHxPPHlOnvOLgnOnfO9)ukMwX5ElhLu1JiypnOvh0Mh0ccVl)Zr2eGXwoN8jqjMdVstdxqBQqBQqlnAqBkq7)PumTIZ9wokPQhrWEAqRoOnpOnCoEb73OhGLJskQB1oGr4m88phxqBQgQZ3qdf)10HTqwNOw18esaLkmHjXKzsZqHN)54YKPHYjrnNHISJWNONRiYp3fHHI0vGD5gQ8G2)tPyAfN7TCusvpIG90muNVHgkYocFIEUIi)CxeMWKyYzsZqHN)54YKPHI0vGD5gQuGwYm81O)yAfN7TCusvpIG1OV2bT0ObTKz4Rr)X0ko3B5OKQEebRXnVob0Mb0ME(qBQqRoOnfOnpOnCoEb73OhGLJskQB1oGr4m88phxqlnAqlzg(A0FmCtB0JTSFhk1JU2CSg386eqBgqBYpxOnvdLtIAod1tGYkWnHjmjMRjndfE(NJltMgkNe1Cgkxage(Hcz7zpTKmTZnuKUcSl3qTW)tPyTN90sY0oxUW)tPyRr)zOoFdnuUami8dfY2ZEAjzANBctIGCtAgk88phxMmnuojQ5muUami8dfY2ZEAjzANBOiDfyxUHImdFn6pgUPn6Xw2VdL6rxBowJBEDcOndOn5Np0QdAx4)PuS2ZEAjzANlx4)PuSNg0QdAbH3L)5iBcWylNt(eOeZHxPPHlOLgnO9)uk2VrpalhLuu3QDaJWzpnOvh0UW)tPyTN90sY0oxUW)tPypnOvh0Mh0ccVl)Zr2eGXwoN8jqjMdVstdxqlnAq7)PumCtB0JTSFhk1JU2CSNg0QdAx4)PuS2ZEAjzANlx4)PuSNg0QdAZdAdNJxW(n6by5OKI6wTdyeodp)ZXf0sJg0g1gkJrUkeAbfAtFVH68n0q5cWGWpuiBp7PLKPDUjmjcszsZqHN)54YKPHYjrnNHkNdfsWJEo2gksxb2LBOsbAXC4vAA4IXFnDylK1jQvnpHeqPcOvh0(FkftR4CVLJsQ6reSg386eqBQqlnAqBkqBEqlMdVstdxm(RPdBHSorTQ5jKakvaT6G2)tPyAfN7TCusvpIG14MxNaAbfA3No0QdA)pLIPvCU3Yrjv9ic2tdAt1qD(gAOY5qHe8ONJTjmjMtM0mu45FoUmzAOCsuZzOO7MqokPFKcVqQE9odfPRa7YnuKz4Rr)XWnTrp2Y(DOup6AZXACZRtaTzaTjx(gQZ3qdfD3eYrj9Ju4fs1R3zctIjFtAgk88phxMmnuojQ5mua65aiKADT5Cz7aqdfPRa7Ynu97qOfuGqBYGwDqBEq7)PumTIZ9wokPQhrWEAqRoOnfOnpO9)uk2VrpalhLuu3QDaJWzpnOLgnOnpOnCoEb73OhGLJskQB1oGr4m88phxqBQgQZ3qdfGEoacPwxBox2oa0eMe3NVjndfE(NJltMgQZ3qdv7zVEhDc5VaiBCj)ViMZq5KOMZq1E2R3rNq(laYgxY)lI5mHjX97nPzOWZ)CCzY0q5KOMZqTHnsxa2fsLFamuKUcSl3qLh0(Fkf73OhGLJskQB1oGr4SNg0QdAZdA)pLIPvCU3Yrjv9ic2tZqD(gAO2WgPla7cPYpaMWK4(0nPzOWZ)CCzY0qr6kWUCd1)PumTIZ9wokPQhrWEAqRoO9)ukgUPn6Xw2VdL6rxBo2tZq5KOMZqPnrnNjmjUpzM0mu45FoUmzAOiDfyxUH6)ukMwX5ElhLu1JiypnOvh0(Fkfd30g9yl73Hs9ORnh7PzOCsuZzO(8zws1R3zctI7totAgk88phxMmnuKUcSl3q9FkftR4CVLJsQ6reSNMHYjrnNH6JTaB6QdGjmjUpxtAgk88phxMmnuKUcSl3qLc0Mh0(FkftR4CVLJsQ6reSNg0QdADsuGaL4HBfkG2macTPdTPcT0ObT5bT)NsX0ko3B5OKQEeb7PbT6G2uG2(DiBHQIub0MbqOnxOvh02VRisTrp2SfQksfqBgaHwqE(qBQgkNe1CgkVj(HsThxGMWK4EqUjndfE(NJltMgksxb2LBO(pLIPvCU3Yrjv9ic2tZq5KOMZqXlaGdHmN7TaSHxyctI7bPmPzOWZ)CCzY0qr6kWUCdv4namyrTHYyKRcH2mG29jNHYjrnNHsa2j0XrzagLVt)0b4DMWK4(CYKMHcp)ZXLjtdfPRa7YnuojkqGs8WTcfqBgqB6qlnAq7FecdLtIAodL)NT68OMtYRTVjmjUp5BsZqHN)54YKPHI0vGD5gkNefiqjE4wHcOndOnDOLgnO9pcHHYjrnNHsO37T6ai3kryctIPNVjndLtIAodv7LaLl0xgk88phxMmnHjX03BsZqHN)54YKPHI0vGD5gQ)tPyAfN7TCusvpIG90GwDq7)PumCtB0JTSFhk1JU2CSNMHYjrnNHYpckI25sIZ5MWKy6PBsZqHN)54YKPHI0vGD5gQ)tPyAfN7TCusvpIG14MxNaAbfi0MtqRoO9)ukgUPn6Xw2VdL6rxBo2tZq5KOMZqPQg)8zwMWKy6jZKMHcp)ZXLjtdfPRa7Ynu)NsX0ko3B5OKQEeb7PbT6G2uG2)tPyAfN7TCusvpIG14MxNaAbfAZfA1bTHZXlyKHVKGrVdgE(NJlOLgnOnpOnCoEbJm8Lem6DWWZ)CCbT6G2)tPyAfN7TCusvpIG14MxNaAbfAtg0Mk0QdADsuGaL4HBfkGwGq7EOLgnO9)ukMaXaCDaKTdazpnOvh06KOabkXd3kuaTaH29gkNe1CgQVdqokz0fHoHjmjMEYzsZqHN)54YKPHI0vGD5gQuGwYm81O)y4M2OhBz)ouQhDT5ynU51jGwA0G2W54fSIGexJHN)54cAtfA1bT5bT)NsX0ko3B5OKQEeb7PbT0ObTHZXlyfbjUgdp)ZXf0QdA9SXUcKP6re6bJCnHSUvb48OMJHN)54cA1bT)NsX0ko3B5OKQEebRXnVob0ck0MUHYjrnNHsR4CVLJsQ6reMWKy65AsZqHN)54YKPHI0vGD5gkYm81O)y4M2OhBz)ouQhDT5ynU51jGwDqlzg(A0FmTIZ9wokPQhrWACZRtyOCsuZzO(n6by5OKI6wTdyeUH6jq5OusaKLjX9MWKy6GCtAgk88phxMmnuKUcSl3qrMHVg9htR4CVLJsQ6reSg91oOvh0gohVGnFEfy7rnhdp)ZXf0QdA73HSO2qzmYCH2mGwaKf0QdA73veP2OhB2cvfPcOndGq7(8HwA0G2O2qzmYvHqlOqB65BOCsuZzOWnTrp2Y(DOup6AZzctIPdszsZqHN)54YKPHI0vGD5gQuGwYm81O)yAfN7TCusvpIG1OV2bT0ObTrTHYyKRcHwqH20ZhAtfA1bTHZXly)g9aSCusrDR2bmcNHN)54cA1bT97kIuB0Jn0Mb0cYZ3q5KOMZqHBAJESL97qPE01MZeMetpNmPzOWZ)CCzY0qr6kWUCdv4C8cwrqIRXWZ)CCbT6G2(Di0ck0MmdLtIAodfUPn6Xw2VdL6rxBotysm9KVjndLtIAodf4DAtag7TIi1AuGhbnu45FoUmzActIjlFtAgk88phxMmnuKUcSl3qfohVGrg(scg9oy45FoUGwDqBkqBkq7)PumYWxsWO3bteoHoOndGq7(8HwDq7c)pLI1E2txeKjcNqh0ceAZfAtfAPrdAJAdLXixfcTGceAbqwqBQgkNe1CgkIZ5sNe1CsEjcdfVeH88n0qrg(scg9omHjXKT3KMHcp)ZXLjtdfPRa7YnuPaT)NsX0ko3B5OKQEeb7PbT6GwpBSRazfzNKuHVqoR9JoOfuGq7EOvh0Mc0(FkftR4CVLJsQ6reSg386eqlOaHwaKf0sJg0(Fkf7DGh(oPiA8aeGznU51jGwqbcTailOvh0(Fkf7DGh(oPiA8aeGzpnOnvOnvdLtIAodLQhrOFxVjKQxVZeMetw6M0mu45FoUmzAOiDfyxUHkfO9)ukwr2jjv4lKZEAqRoOnpOnCoEbRiiX1y45FoUGwDqBkq7)PuS3bE47KIOXdqaM90GwA0G2)tPyfzNKuHVqoRXnVob0ckqOfazbTPcTPcT0ObT)NsXkYojPcFHC2tdA1bT)NsXkYojPcFHCwJBEDcOfuGqlaYcA1bTHZXlyfbjUgdp)ZXf0QdA)pLIPvCU3Yrjv9ic2tZq5KOMZqP6re631BcP617mHjXKLmtAgk88phxMmnuKUcSl3qf1gkJrUkeAbfAbqwqlnAqBkqBuBOmg5QqOfuOLmdFn6pMwX5ElhLu1JiynU51jGwDq7)PuS3bE47KIOXdqaM90G2unuojQ5muQEeH(D9MqQE9otycdLi8B59YKMjX9M0muojQ5munUnTa5Oqi1xxGTHcp)ZXLjttysmDtAgk88phxMmnuKUcSl3qrMHVg9hRXTPfihfcP(6cSznU51jGwqbcTPdT5i0cGSGwDqB4C8cgapaJDDaKIy6ngE(NJldLtIAodLQhrifrx0HMWKyYmPzOWZ)CCzY0qr6kWUCd1)PuSU2q2tZq5KOMZqbE0ZRdG8ZDryctIjNjndfE(NJltMgksxb2LBOcNJxWkcsCngE(NJlOvh0(FkftR4CVLJsQ6reSNg0QdA9SXUcKvKDssf(c5S2p6G2macTPBOCsuZzOMpVcS9anHjXCnPzOWZ)CCzY0qr6kWUCdvEq7)PumvpzJNu7Xfi7PbT6G2W54fmvpzJNu7Xfidp)ZXLHYjrnNHA(8kW2d0eMeb5M0mu45FoUmzAOiDfyxUHQFxrKAJESzluvKkGwqH2uG295cTjaTHZXly97kI0JaVNh1Cm88phxqBocTjdAt1q5KOMZqP6resr0fDOjmjcszsZqHN)54YKPHI0vGD5gQ)tPy0vCEDaKBobCDi7PbT6G2(DilQnugJm5G2macTaildLtIAodLQhrii7cWOjmjMtM0mu45FoUmzAOiDfyxUHQFxrKAJESzluvKkG2mG2uG20ZfAtaAdNJxW63vePhbEppQ5y45FoUG2CeAtg0MQHYjrnNHA(8kW2d0eMet(M0muojQ5muQEeHueDrhAOWZ)CCzY0eMe3NVjndLtIAodf4Pp5OK6RlW2qHN)54YKPjmjUFVjndLtIAodL3e)qzmDJxyOWZ)CCzY0eMWqTqL)4HjntI7nPzOCsuZzO2QBjvnIzJgk88phxMmnHjX0nPzOWZ)CCzY0qr6kWUCdvEq7AcMQhriviiWMffHU6aaT6G2uG28G2W54fSFJEawokPOUv7agHZWZ)CCbT0ObTKz4Rr)X(n6by5OKI6wTdyeoRXnVob0Mb0UpxOnvdLtIAodf4rpVoaYp3fHjmjMmtAgk88phxMmnuKUcSl3q9FkfRi7KHZNtWACZRtaTGceAbqwqRoO9)ukwr2jdNpNG90GwDqRqd5Cz4namemaCNuox6lq4hbH2macTPdT6G2uG28G2W54fSFJEawokPOUv7agHZWZ)CCbT0ObTKz4Rr)X(n6by5OKI6wTdyeoRXnVob0Mb0UpxOnvdLtIAodfaUtkNl9fi8JGMWKyYzsZqHN)54YKPHI0vGD5gQ)tPyfzNmC(CcwJBEDcOfuGqlaYcA1bT)NsXkYoz485eSNg0QdAtbAZdAdNJxW(n6by5OKI6wTdyeodp)ZXf0sJg0sMHVg9h73OhGLJskQB1oGr4Sg386eqBgq7(CH2unuojQ5muQEeHueDrhActI5AsZqHN)54YKPHYjrnNHI4CU0jrnNKxIWqXlripFdnuOqGhbfMWKii3KMHcp)ZXLjtdLtIAodfX5CPtIAojVeHHIxIqE(gAOiZWxJ(tyctIGuM0mu45FoUmzAOiDfyxUH6)uk2VrpalhLuu3QDaJWzpndLtIAodv)oPtIAojVeHHIxIqE(gAO(JqgfHU6ayctI5KjndfE(NJltMgksxb2LBOcNJxW(n6by5OKI6wTdyeodp)ZXf0QdAtbAtbAjZWxJ(J9B0dWYrjf1TAhWiCwJBEDcOfi0Mp0QdAjZWxJ(JPvCU3Yrjv9icwJBEDcOfuODF(qBQqlnAqBkqlzg(A0FSFJEawokPOUv7agHZACZRtaTGcTPNp0QdAJAdLXixfcTGcTjlxOnvOnvdLtIAodv)oPtIAojVeHHIxIqE(gAO(JqQndVoaMWKyY3KMHcp)ZXLjtdfPRa7Ynu)NsX0ko3B5OKQEeb7PbT6G2W54fS5ZRaBpQ5y45FoUmuojQ5mu97KojQ5K8segkEjc55BOHA(8kW2JAotysCF(M0mu45FoUmzAOiDfyxUHYjrbcuIhUvOaAZai0MUHYjrnNHQFN0jrnNKxIWqXlripFdnu(GMWK4(9M0mu45FoUmzAOCsuZzOioNlDsuZj5Limu8seYZ3qdLi8B59YeMWq5dAsZK4EtAgk88phxMmnuKUcSl3qfohVGbWdWyxhaPiMEJHN)54cAPrdAtbA9SXUcKP6jB8KbUPHIG1(rh0QdAfAiNldVbGHG1420cKJcHuFDb2qBgaH2KbT6G28G2)tPyDTHSNg0MQHYjrnNHQXTPfihfcP(6cSnHjX0nPzOWZ)CCzY0qr6kWUCdv4C8cMQhrii7cWidp)ZXLHYjrnNHca3jLZL(ce(rqtysmzM0mu45FoUmzAOCsuZzOu9icPi6Io0qr6kWUCdvkq7c)pLI1E2txeKjcNqh0ck0Ml0sJg0UW)tPyTN90fbznU51jGwqH295dTPcT6GwYm81O)ynUnTa5Oqi1xxGnRXnVob0ckqOnDOnhHwaKf0QdAdNJxWa4bySRdGuetVXWZ)CCbT6G28G2W54fmvpIqq2fGrgE(NJldfzhHJYWBayimjU3eMetotAgk88phxMmnuKUcSl3qrMHVg9hRXTPfihfcP(6cSznU51jGwqbcTPdT5i0cGSGwDqB4C8cgapaJDDaKIy6ngE(NJldLtIAodLQhrifrx0HMWKyUM0mu45FoUmzAOiDfyxUH6)ukwxBi7PzOCsuZzOap651bq(5UimHjrqUjndfE(NJltMgksxb2LBO(pLIrxX51bqU5eW1HSNMHYjrnNHs1JieKDby0eMebPmPzOWZ)CCzY0qr6kWUCdv)UIi1g9yZwOQivaTGcTPaT7ZfAtaAdNJxW63vePhbEppQ5y45FoUG2CeAtg0MQHYjrnNHca3jLZL(ce(rqtysmNmPzOWZ)CCzY0q5KOMZqP6resr0fDOHI0vGD5gQuG2f(FkfR9SNUiiteoHoOfuOnxOLgnODH)NsXAp7PlcYACZRtaTGcT7ZhAtfA1bT97kIuB0JnBHQIub0ck0Mc0UpxOnbOnCoEbRFxrKEe498OMJHN)54cAZrOnzqBQqRoOnpOnCoEbt1JieKDbyKHN)54Yqr2r4Om8gagctI7nHjXKVjndfE(NJltMgksxb2LBO63veP2OhB2cvfPcOfuOnfODFUqBcqB4C8cw)UIi9iW75rnhdp)ZXf0MJqBYG2uHwDqBEqB4C8cMQhrii7cWidp)ZXLHYjrnNHs1JiKIOl6qtysCF(M0mu45FoUmzAOiDfyxUHYjrbcuIhUvOaAZaAt3q5KOMZqTqpalKRhActI73BsZqHN)54YKPHI0vGD5gkNefiqjE4wHcOndOnDdLtIAod1c9aS0VLCHeFNjmjUpDtAgkNe1CgQg3MwGCuiK6RlW2qHN)54YKPjmjUpzM0muojQ5muQEeHGSlaJgk88phxMmnHjX9jNjndfE(NJltMgkNe1CgQ5ZRaBpqdfPRa7YnuPaTl8)ukw7zpDrqMiCcDqlOqBUqlnAq7c)pLI1E2txeK14MxNaAbfA3Np0Mk0QdA73veP2OhB2cvfPcOndOnfOn9CH2eG2W54fS(Dfr6rG3ZJAogE(NJlOnhH2KbTPcT6G28G2W54fmvpIqq2fGrgE(NJldfzhHJYWBayimjU3eMe3NRjndfE(NJltMgksxb2LBO63veP2OhB2cvfPcOndOnfOn9CH2eG2W54fS(Dfr6rG3ZJAogE(NJlOnhH2KbTPAOCsuZzOMpVcS9anHjX9GCtAgkNe1CgkaCNuox6lq4hbnu45FoUmzActI7bPmPzOWZ)CCzY0q5KOMZqP6resr0fDOHI0vGD5gQuG2f(FkfR9SNUiiteoHoOfuOnxOLgnODH)NsXAp7PlcYACZRtaTGcT7ZhAtfA1bT5bTHZXlyQEeHGSlaJm88phxgkYochLH3aWqysCVjmjUpNmPzOCsuZzOu9icPi6Io0qHN)54YKPjmjUp5BsZq5KOMZqbE6tokP(6cSnu45FoUmzActIPNVjndLtIAodL3e)qzmDJxyOWZ)CCzY0eMWegkqGTOMZKy65NE(5NtPNtS0nu69(QdGWqL8ytB6axq7(8HwNe1CqlVeHGbP3qj0qIjX0ZDVHsRhvXrdfidAbj6reqBop0dWqlijxbaCaPhKbTGKFaEIaAtpNscAtp)0ZhspKEqg0MZa2paOiNfKEqg0csdTjpoc)TqOnNT6wqlirJy2idspidAbPHwqYRf0QCo)7e6Gw10q7tuhaOn5zoFqstcAtEpGeqBPGwnUVdBOTUkkpqb0M5qbTFunncTAZWRda0YhafbAlb0sMnnog4IbPhKbTG0qBody)aGqB4namyrTHYyKRcH2yG2O2qzmYvHqBmq7tGqlEK5Db2qlhpabyOT9am2qBa2pOvBc8IY5qB0Uam0Uqpalyq6bzqlin0MZm8f0M8c6DaT(TG22jLZH2qp60jyq6H0dYG2KNjVIKxGlO9JQPrOLmBFpG2pcOobdAbjtiOwiG2BoqAWEVPECO1jrnNaANJVJbP3jrnNGP1iz2(EKaWS0MOMdsVtIAobtRrYS99ibGz9eOScClPZ3qGE2cWE7cPAUqokP2OhBi9ojQ5emTgjZ23JeaMfi8U8pht68ne4eGXwoN8jqjMdVstdxjbcN)qGPG5WR00Wf7My6AEcjaUVkpMwi)(casJgMdVstdxmY09tlWLea3xLhtlKFFbaPrdZHxPPHlgz6(Pf4scG7RYJPfYnC5CEnhnAyo8knnCXar5C5OK(vBEGl5NpZIgnmhELMgUyQQfHCZduifA7aWDHGgnmhELMgUy5COqcE0ZXMgnmhELMgUy3etxZtibW9v5X0c5gUCoVMJgnmhELMgUyUami8dfY2ZEAjzANNkKEi9GmOn5zYRi5f4cArqG9oOnQneAdWi06KyAOTeqRdcV4(NJmi9ojQ5ea3QBjvnIzJq6bzqliznn(oOfKOhraTGeiiWgA9BbTBEDHxh0M8GSdAtZ5ZjG07KOMtKaWSap651bq(5UisQuaZBnbt1JiKkeeyZIIqxDa0LsEHZXly)g9aSCusrDR2bmcNHN)54IgnYm81O)y)g9aSCusrDR2bmcN14MxNiJ95MkKENe1CIeaMfaUtkNl9fi8JGjvkG)NsXkYoz485eSg386eGceazP7)ukwr2jdNpNG900j0qoxgEdadbda3jLZL(ce(rWmaMUUuYlCoEb73OhGLJskQB1oGr4m88phx0OrMHVg9h73OhGLJskQB1oGr4Sg386ezSp3uH07KOMtKaWSu9icPi6IomPsb8)ukwr2jdNpNG14MxNauGailD)NsXkYoz485eSNMUuYlCoEb73OhGLJskQB1oGr4m88phx0OrMHVg9h73OhGLJskQB1oGr4Sg386ezSp3uH07KOMtKaWSioNlDsuZj5Lis68neike4rqbKENe1CIeaMfX5CPtIAojVersNVHajZWxJ(taP3jrnNibGz1Vt6KOMtYlrK05BiW)iKrrORoajvkG)NsX(n6by5OKI6wTdyeo7PbP3jrnNibGz1Vt6KOMtYlrK05BiW)iKAZWRdqsLcy4C8c2VrpalhLuu3QDaJWz45FoU0LskKz4Rr)X(n6by5OKI6wTdyeoRXnVobW81rMHVg9htR4CVLJsQ6reSg386eGUp)uPrlfYm81O)y)g9aSCusrDR2bmcN14MxNa00ZxxuBOmg5QqqtwUPMkKENe1CIeaMv)oPtIAojVersNVHaNpVcS9OMlPsb8)ukMwX5ElhLu1JiypnDHZXlyZNxb2EuZXWZ)CCbP3jrnNibGz1Vt6KOMtYlrK05BiqFWKkfqNefiqjE4wHImaMoKENe1CIeaMfX5CPtIAojVersNVHafHFlVxq6H07KOMtW8bb2420cKJcHuFDb2jvkGHZXlya8am21bqkIP3y45FoUOrlfpBSRazQEYgpzGBAOiyTF0PtOHCUm8gagcwJBtlqokes91fyNbWKPlV)tPyDTHSNwQq6DsuZjy(GjamlaCNuox6lq4hbtQuadNJxWu9icbzxagz45FoUG07KOMtW8btaywQEeHueDrhMezhHJYWBayiaUpPsbmLf(FkfR9SNUiiteoHoqZLgTf(FkfR9SNUiiRXnVobO7ZpvDKz4Rr)XACBAbYrHqQVUaBwJBEDcqbMEocGS0fohVGbWdWyxhaPiMEJHN)54sxEHZXlyQEeHGSlaJm88phxq6DsuZjy(GjamlvpIqkIUOdtQuajZWxJ(J1420cKJcHuFDb2Sg386eGcm9CeazPlCoEbdGhGXUoasrm9gdp)ZXfKENe1CcMpycaZc8ONxha5N7IiPsb8)ukwxBi7PbP3jrnNG5dMaWSu9icbzxagtQua)pLIrxX51bqU5eW1HSNgKENe1CcMpycaZca3jLZL(ce(rWKkfW(DfrQn6XMTqvrQa0u2NBcHZXly97kI0JaVNh1Cm88phx5yYsfsVtIAobZhmbGzP6resr0fDysKDeokdVbGHa4(KkfWuw4)PuS2ZE6IGmr4e6anxA0w4)PuS2ZE6IGSg386eGUp)u11VRisTrp2SfQksfGMY(CtiCoEbRFxrKEe498OMJHN)54khtwQ6YlCoEbt1JieKDbyKHN)54csVtIAobZhmbGzP6resr0fDysLcy)UIi1g9yZwOQivaAk7ZnHW54fS(Dfr6rG3ZJAogE(NJRCmzPQlVW54fmvpIqq2fGrgE(NJli9ojQ5emFWeaM1c9aSqUEysLcOtIceOepCRqrgPdP3jrnNG5dMaWSwOhGL(TKlK47sQuaDsuGaL4HBfkYiDi9ojQ5emFWeaMvJBtlqokes91fydP3jrnNG5dMaWSu9icbzxagH07KOMtW8btaywZNxb2EGjr2r4Om8gagcG7tQuatzH)NsXAp7PlcYeHtOd0CPrBH)NsXAp7PlcYACZRta6(8tvx)UIi1g9yZwOQivKrkPNBcHZXly97kI0JaVNh1Cm88phx5yYsvxEHZXlyQEeHGSlaJm88phxq6DsuZjy(GjamR5ZRaBpWKkfW(DfrQn6XMTqvrQiJusp3ecNJxW63vePhbEppQ5y45FoUYXKLkKENe1CcMpycaZca3jLZL(ce(rqi9ojQ5emFWeaMLQhrifrx0Hjr2r4Om8gagcG7tQuatzH)NsXAp7PlcYeHtOd0CPrBH)NsXAp7PlcYACZRta6(8tvxEHZXlyQEeHGSlaJm88phxq6DsuZjy(GjamlvpIqkIUOdH07KOMtW8btaywGN(KJsQVUaBi9ojQ5emFWeaML3e)qzmDJxaPhspidAZSrpadTJcAPQB1oGr4qR2m86aaT9eEuZbT5SGwr4DiG20ZxaTFunncTjVlo3BODuqlirpIaAtaAZCOGwVrO1bHxC)Zri9ojQ5eS)iKAZWRdaqWJEEDaKFUlIKkfW)tPyDTHSNgKENe1Cc2FesTz41bibGznFEfy7bMezhHJYWBayiaUpPsbmLf(FkfR9SNUiiteoHoqZLgTf(FkfR9SNUiiRXnVobO7ZpvD97kIuB0JnBHQIurgatpxD5fohVGP6recYUamYWZ)CCbP3jrnNG9hHuBgEDasaywZNxb2EGjvkG97kIuB0JnBHQIurgatpxi9ojQ5eS)iKAZWRdqcaZca3jLZL(ce(rWKkfW(DfrQn6XMTqvrQa00ZxNqd5Cz4namemaCNuox6lq4hbZay66iZWxJ(JPvCU3Yrjv9icwJBEDImYfsVtIAob7pcP2m86aKaWSu9icPi6IomjYochLH3aWqaCFsLcykl8)ukw7zpDrqMiCcDGMlnAl8)ukw7zpDrqwJBEDcq3NFQ663veP2OhB2cvfPcqtpFD5fohVGP6recYUamYWZ)CCPJmdFn6pMwX5ElhLu1JiynU51jYixi9ojQ5eS)iKAZWRdqcaZs1JiKIOl6WKkfW(DfrQn6XMTqvrQa00Zxhzg(A0FmTIZ9wokPQhrWACZRtKrUq6DsuZjy)ri1MHxhGeaMLQhrii7cWysLc4)Pum6koVoaYnNaUoK9001VRisTrp2SfQksfzKY(CtiCoEbRFxrKEe498OMJHN)54khtwQ6eAiNldVbGHGP6recYUamMbW0H07KOMtW(JqQndVoajamlvpIqq2fGXKkfW(DfrQn6XMTqvrQidGPKSCtiCoEbRFxrKEe498OMJHN)54khtwQ6eAiNldVbGHGP6recYUamMbW0H07KOMtW(JqQndVoajamR5ZRaBpWKi7iCugEdadbW9jvkGPSW)tPyTN90fbzIWj0bAU0OTW)tPyTN90fbznU51jaDF(PQRFxrKAJESzluvKkYaykjl3ecNJxW63vePhbEppQ5y45FoUYXKLQU8cNJxWu9icbzxagz45FoUG07KOMtW(JqQndVoajamR5ZRaBpWKkfW(DfrQn6XMTqvrQidGPKSCtiCoEbRFxrKEe498OMJHN)54khtwQq6DsuZjy)ri1MHxhGeaMfaUtkNl9fi8JGjvkGKz4Rr)X0ko3B5OKQEebRXnVorg97qwuBOmgzYPRFxrKAJESzluvKkan5YxNqd5Cz4namemaCNuox6lq4hbZay6q6DsuZjy)ri1MHxhGeaMLQhrifrx0Hjr2r4Om8gagcG7tQuatzH)NsXAp7PlcYeHtOd0CPrBH)NsXAp7PlcYACZRta6(8tvhzg(A0FmTIZ9wokPQhrWACZRtKr)oKf1gkJrMC663veP2OhB2cvfPcqtU81Lx4C8cMQhrii7cWidp)ZXfKENe1Cc2FesTz41bibGzP6resr0fDysLcizg(A0FmTIZ9wokPQhrWACZRtKr)oKf1gkJrMC663veP2OhB2cvfPcqtU8H0dPhKbTGeoN)DcDqBmq7tGqBY7bKijOn5zoFqsHw9GXdAFcSbPRRIYduaTzouqRwJBE8AKVJbP3jrnNG9hHmkcD1baOwX5ElhLu1JisQuajZWxJ(JHBAJESL97qPE01MJ14MxNasVtIAob7pczue6QdqcaZc30g9yl73Hs9ORnhKENe1Cc2FeYOi0vhGeaM185vGThysKDeokdVbGHa4(KkfWuw4)PuS2ZE6IGmr4e6anxA0w4)PuS2ZE6IGSg386eGUp)u11VRisTrp2GcmzPRlVW54fmvpIqq2fGrgE(NJli9ojQ5eS)iKrrORoajamR5ZRaBpWKkfW(DfrQn6XguGjlDi9ojQ5eS)iKrrORoajamRg3MwGCuiK6RlWoPsbmCoEbdGhGXUoasrm9gdp)ZXfKENe1Cc2FeYOi0vhGeaMf4rpVoaYp3frsLc4)PuSU2q2tdsVtIAob7pczue6QdqcaZA(8kW2dmjYochLH3aWqaCFsLcykl8)ukw7zpDrqMiCcDGMlnAl8)ukw7zpDrqwJBEDcq3NFQ663HSO2qzmYCbfazrJw)UIi1g9ydkWKlxD5fohVGP6recYUamYWZ)CCbP3jrnNG9hHmkcD1bibGznFEfy7bMuPa2VdzrTHYyK5ckaYIgT(DfrQn6XguGjxUq6DsuZjy)riJIqxDasaywQEeHGSlaJjvkG)NsXOR486ai3Cc46q2ttNqd5Cz4namemvpIqq2fGXmaMoKENe1Cc2FeYOi0vhGeaMf4Pp5OK6RlWoPsbSFxrKAJESzluvKkYayYsxx)oKf1gkJrMSmaqwq6DsuZjy)riJIqxDasaywnUnTa5Oqi1xxGnKENe1Cc2FeYOi0vhGeaMLQhrii7cWysLcOqd5Cz4namemvpIqq2fGXmaMoKENe1Cc2FeYOi0vhGeaM185vGThysKDeokdVbGHa4(KkfWuw4)PuS2ZE6IGmr4e6anxA0w4)PuS2ZE6IGSg386eGUp)u11VRisTrp2SfQksfzKEU0O1VdZiz6YlCoEbt1JieKDbyKHN)54csVtIAob7pczue6QdqcaZA(8kW2dmPsbSFxrKAJESzluvKkYi9CPrRFhMrYG07KOMtW(JqgfHU6aKaWS8M4hkJPB8IKkfW(DfrQn6XMTqvrQiJCZhspKEqg0MZm8f0cg9oGwYCRkQ5eq6DsuZjyKHVKGrVdGeWEDc5OKfbtQua)pLIrg(scg9oyIWj0LrU6IAdLXixfckaYcsVtIAobJm8Lem6DKaWSiG96eYrjlcMuPaMY)PumbIb46aiBhaYACZRtakaYkvD)NsXeigGRdGSDai7PbP3jrnNGrg(scg9osayweWEDc5OKfbtQuat5)ukMwX5ElhLu1JiynU51jafiaYkhtzFcKz4Rr)Xu9ic976nHu96DSg91UuPr7)ukMwX5ElhLu1JiynU51jaTFhYIAdLXitwQ6(pLIPvCU3Yrjv9ic2ttxkE2yxbYkYojPcFHCw7hDGcCpnA)NsX(n6by5OKI6wTdyeo7PLQU8cNJxWkcsCngE(NJli9ojQ5emYWxsWO3rcaZIa2RtihLSiysLc4)PumTIZ9wokPQhrWACZRtaAoP7)uk27ap8Dsr04biaZACZRtakaYkhtzFcKz4Rr)Xu9ic976nHu96DSg91Uu19Fkf7DGh(oPiA8aeGznU51j09FkftR4CVLJsQ6reSNMUu8SXUcKvKDssf(c5S2p6af4EA0(pLI9B0dWYrjf1TAhWiC2tlvD5fohVGveK4Am88phxq6DsuZjyKHVKGrVJeaMfbSxNqokzrWKkfWu(pLIvKDssf(c5Sg386eGMC0O9FkfRi7KKk8fYznU51jaTFhYIAdLXitwQ6(pLIvKDssf(c5SNMopBSRazfzNKuHVqoR9JUmaMUU8(pLI9B0dWYrjf1TAhWiC2ttxEHZXlyfbjUgdp)ZXfKENe1Ccgz4ljy07ibGzra71jKJswemPsb8)ukwr2jjv4lKZEA6(pLI9oWdFNuenEacWSNMopBSRazfzNKuHVqoR9JUmaMUU8(pLI9B0dWYrjf1TAhWiC2ttxEHZXlyfbjUgdp)ZXfKENe1Ccgz4ljy07ibGzra71jKJswemPsb8)ukMwX5ElhLu1JiynU51jan509FkftR4CVLJsQ6reSNMUW54fSIGexJHN)54s3)PumYWxsWO3bteoHUmaUpN05zJDfiRi7KKk8fYzTF0bkW9q6DsuZjyKHVKGrVJeaMfbSxNqokzrWKkfW)tPyAfN7TCusvpIG900fohVGveK4Am88phx68SXUcKvKDssf(c5S2p6Yay66s5)ukgz4ljy07GjcNqxga3N819FkfRi7KKk8fYznU51jafazP7)ukwr2jjv4lKZEA0O9Fkf7DGh(oPiA8aeGzpnD)NsXidFjbJEhmr4e6Ya4(Ckvi9q6DsuZjyKz4Rr)ja(eOScClPZ3qGE2cWE7cPAUqokP2Oh7KkfWuiZWxJ(JHBAJESL97qPE01MJ1OV2Plpq4D5FoYMam2Y5KpbkXC4vAA4kvA0sHmdFn6pMwX5ElhLu1JiynU51jaf4(81bcVl)Zr2eGXwoN8jqjMdVstdxPcP3jrnNGrMHVg9NibGz9eOScClPZ3qG8xth2czDIAvZtibuQiPsbmCoEb73OhGLJskQB1oGr4m88phx6sjfYm81O)yAfN7TCusvpIG14MxNauG7Zxhi8U8phztagB5CYNaLyo8knnCLknAP8FkftR4CVLJsQ6reSNMU8aH3L)5iBcWylNt(eOeZHxPPHRutLgTu(pLIPvCU3Yrjv9ic2ttxEHZXly)g9aSCusrDR2bmcNHN)54kvi9ojQ5emYm81O)ejamRNaLvGBjD(gcKSJWNONRiYp3frsLcyE)NsX0ko3B5OKQEeb7PbP3jrnNGrMHVg9NibGz9eOScCtKuPaMczg(A0FmTIZ9wokPQhrWA0x7OrJmdFn6pMwX5ElhLu1JiynU51jYi98tvxk5fohVG9B0dWYrjf1TAhWiCgE(NJlA0iZWxJ(JHBAJESL97qPE01MJ14MxNiJKFUPcP3jrnNGrMHVg9NibGz9eOScClPZ3qGUami8dfY2ZEAjzANNuPaUW)tPyTN90sY0oxUW)tPyRr)bP3jrnNGrMHVg9NibGz9eOScClPZ3qGUami8dfY2ZEAjzANNuPasMHVg9hd30g9yl73Hs9ORnhRXnVorgj)81TW)tPyTN90sY0oxUW)tPypnDGW7Y)CKnbySLZjFcuI5WR00WfnA)NsX(n6by5OKI6wTdyeo7PPBH)NsXAp7PLKPDUCH)NsXEA6YdeEx(NJSjaJTCo5tGsmhELMgUOr7)ukgUPn6Xw2VdL6rxBo2tt3c)pLI1E2tljt7C5c)pLI900Lx4C8c2VrpalhLuu3QDaJWz45FoUOrlQnugJCviOPVhsVtIAobJmdFn6prcaZ6jqzf4wsNVHaZ5qHe8ONJDsLcykyo8knnCX4VMoSfY6e1QMNqcOuHU)tPyAfN7TCusvpIG14MxNivA0sjpmhELMgUy8xth2czDIAvZtibuQq3)PumTIZ9wokPQhrWACZRta6(019FkftR4CVLJsQ6reSNwQq6DsuZjyKz4Rr)jsaywpbkRa3s68neiD3eYrj9Ju4fs1R3LuPasMHVg9hd30g9yl73Hs9ORnhRXnVorgjx(q6DsuZjyKz4Rr)jsaywpbkRa3s68neiGEoacPwxBox2oamPsbSFhckWKPlV)tPyAfN7TCusvpIG900LsE)NsX(n6by5OKI6wTdyeo7PrJwEHZXly)g9aSCusrDR2bmcNHN)54kvi9ojQ5emYm81O)ejamRNaLvGBjD(gcS9SxVJoH8xaKnUK)xeZbP3jrnNGrMHVg9NibGz9eOScClPZ3qGByJ0fGDHu5hGKkfW8(pLI9B0dWYrjf1TAhWiC2ttxE)NsX0ko3B5OKQEeb7PbP3jrnNGrMHVg9NibGzPnrnxsLc4)PumTIZ9wokPQhrWEA6(pLIHBAJESL97qPE01MJ90G07KOMtWiZWxJ(tKaWS(8zws1R3LuPa(FkftR4CVLJsQ6reSNMU)tPy4M2OhBz)ouQhDT5ypni9ojQ5emYm81O)ejamRp2cSPRoajvkG)NsX0ko3B5OKQEeb7PbP3jrnNGrMHVg9NibGz5nXpuQ94cmPsbmL8(pLIPvCU3Yrjv9ic2ttNtIceOepCRqrgatpvA0Y7)ukMwX5ElhLu1JiypnDP0VdzluvKkYayU663veP2OhB2cvfPImacYZpvi9ojQ5emYm81O)ejamlEbaCiK5CVfGn8IKkfW)tPyAfN7TCusvpIG90G07KOMtWiZWxJ(tKaWSeGDcDCugGr570pDaExsLcy4namyrTHYyKRcZyFYbP3jrnNGrMHVg9NibGz5)zRopQ5K8A7NuPa6KOabkXd3kuKr60O9hHasVtIAobJmdFn6prcaZsO37T6ai3krKuPa6KOabkXd3kuKr60O9hHasVtIAobJmdFn6prcaZQ9sGYf6li9ojQ5emYm81O)ejaml)iOiANljoNNuPa(FkftR4CVLJsQ6reSNMU)tPy4M2OhBz)ouQhDT5ypni9ojQ5emYm81O)ejamlv14NpZkPsb8)ukMwX5ElhLu1JiynU51jafyoP7)ukgUPn6Xw2VdL6rxBo2tdsVtIAobJmdFn6prcaZ67aKJsgDrOtKuPa(FkftR4CVLJsQ6reSNMUu(pLIPvCU3Yrjv9icwJBEDcqZvx4C8cgz4ljy07GHN)54IgT8cNJxWidFjbJEhm88phx6(pLIPvCU3Yrjv9icwJBEDcqtwQ6CsuGaL4HBfkaUNgT)tPycedW1bq2oaK9005KOabkXd3kuaCpKEi9GmOfKOhraTKz4Rr)jG07KOMtWiZWxJ(tKaWS0ko3B5OKQEersLcykKz4Rr)XWnTrp2Y(DOup6AZXACZRtqJw4C8cwrqIRXWZ)CCLQU8(pLIPvCU3Yrjv9ic2tJgTW54fSIGexJHN)54sNNn2vGmvpIqpyKRjK1TkaNh1Cm88phx6(pLIPvCU3Yrjv9icwJBEDcqthsVtIAobJmdFn6prcaZ63OhGLJskQB1oGr4j9eOCukjaYc4(KkfqYm81O)y4M2OhBz)ouQhDT5ynU51j0rMHVg9htR4CVLJsQ6reSg386eq6DsuZjyKz4Rr)jsayw4M2OhBz)ouQhDT5sQuajZWxJ(JPvCU3Yrjv9icwJ(ANUW54fS5ZRaBpQ5y45FoU01VdzrTHYyK5MbaYsx)UIi1g9yZwOQivKbW95tJwuBOmg5QqqtpFi9ojQ5emYm81O)ejamlCtB0JTSFhk1JU2CjvkGPqMHVg9htR4CVLJsQ6reSg91oA0IAdLXixfcA65NQUW54fSFJEawokPOUv7agHZWZ)CCPRFxrKAJESZaKNpKENe1Ccgzg(A0FIeaMfUPn6Xw2VdL6rxBUKkfWW54fSIGexJHN)54sx)oe0KbP3jrnNGrMHVg9NibGzbEN2eGXERisTgf4rqi9ojQ5emYm81O)ejamlIZ5sNe1CsEjIKoFdbsg(scg9osQuadNJxWidFjbJEhm88phx6sjL)tPyKHVKGrVdMiCcDzaCF(6w4)PuS2ZE6IGmr4e6aMBQ0Of1gkJrUkeuGaiRuH07KOMtWiZWxJ(tKaWSu9ic976nHu96DjvkGP8FkftR4CVLJsQ6reSNMopBSRazfzNKuHVqoR9JoqbUxxk)NsX0ko3B5OKQEebRXnVobOabqw0O9Fkf7DGh(oPiA8aeGznU51jafiaYs3)PuS3bE47KIOXdqaM90snvi9ojQ5emYm81O)ejamlvpIq)UEtivVExsLcyk)NsXkYojPcFHC2ttxEHZXlyfbjUgdp)ZXLUu(pLI9oWdFNuenEacWSNgnA)NsXkYojPcFHCwJBEDcqbcGSsnvA0(pLIvKDssf(c5SNMU)tPyfzNKuHVqoRXnVobOabqw6cNJxWkcsCngE(NJlD)NsX0ko3B5OKQEeb7PbP3jrnNGrMHVg9NibGzP6re631BcP617sQuaJAdLXixfckaYIgTuIAdLXixfckzg(A0FmTIZ9wokPQhrWACZRtO7)uk27ap8Dsr04biaZEAPcPhsVtIAobdfc8iOa4NpZsokzagL4HB7sQua)pLIPvCU3Yrjv9ic2ttxk)NsX0ko3B5OKQEebRXnVobO7Zxxk)NsX(n6by5OKI6wTdyeo7PrJw4C8c285vGTh1Cm88phx0OfohVGveK4Am88phx6YZZg7kqwr2jjv4lKZWZ)CCLknA)NsXkYojPcFHC2ttx4C8cwrqIRXWZ)CCLQUuCsuGaL4HBfkaUNgT8cNJxWkcsCngE(NJRuPrZjrbcuIhUvOidGPRlCoEbRiiX1y45FoU0rMHVg9htR4CVLJsQ6reSg91oDP4zJDfiRi7KKk8fYzTF0LbW96(pLIvKDssf(c5SNgnA55zJDfiRi7KKk8fYz45FoUsfsVtIAobdfc8iOibGzb459Q8tokPNn2taoPsbmVW54fSIGexJHN)54IgTW54fSIGexJHN)54sNNn2vGSIStsQWxiNHN)54s3)PumTIZ9wokPQhrWACZRtakix3)PumTIZ9wokPQhrWEA0OfohVGveK4Am88phx6YZZg7kqwr2jjv4lKZWZ)CCbP3jrnNGHcbEeuKaWSiGloxkIgD6sQua)pLIPvCU3Yrjv9icwJBEDcqZv3)PumTIZ9wokPQhrWEA0Of1gkJrUke0CH07KOMtWqHapcksaywbyu(U)8ULunnbtQua)pLI1iHookes10eK90Or7)ukwJe64OqivttqjzExGnteoHoq3VhsVtIAobdfc8iOibGzPgYtGlPNn2vGYp6BjvkG59FkftR4CVLJsQ6reSNMU8(pLI9B0dWYrjf1TAhWiC2tdsVtIAobdfc8iOibGzrMJGx0EGlPI7BysLcyE)NsX0ko3B5OKQEeb7PPlV)tPy)g9aSCusrDR2bmcN900TMGrMJGx0EGlPI7BO8)6J14MxNay(q6DsuZjyOqGhbfjaml9tZxGaRt2Oyo)iysLc4)PumTIZ9wokPQhrWEA0O9Fkfd30g9yl73Hs9ORnh7PrJgzg(A0FSFJEawokPOUv7agHZACZRtKbip)e2NlnAKP7NwuZjy1HkL)5Om6xaMHN)54csVtIAobdfc8iOibGz1LMghL1jfAobtQuaZ7)ukMwX5ElhLu1JiypnD59Fkf73OhGLJskQB1oGr4SNgKENe1Ccgke4rqrcaZAd3MENCus(Jul5QrFtKuPa(Fkfd30g9yl73Hs9ORnhRXnVobO5Q7)uk2VrpalhLuu3QDaJWzpnA0sPFhYIAdLXitpdaKLU(DfrQn6Xg0CZpvi9ojQ5emuiWJGIeaMvJUwDaKkUVHci9q6bzqBo7FEfy7rnh02t4rnhKENe1Cc285vGTh1CaBCBAbYrHqQVUa7KkfWW54fmaEag76aifX0Bm88phxq6DsuZjyZNxb2EuZLaWSMpVcS9atISJWrz4namea3NuPaMYc)pLI1E2txeKjcNqhO5sJ2c)pLI1E2txeK14MxNa095NQU8cNJxWu9icbzxagz45FoU0L3)PuSU2q2ttNqd5Cz4namemWJEEDaKFUlImaMmi9ojQ5eS5ZRaBpQ5saywZNxb2EGjvkG5fohVGP6recYUamYWZ)CCPlV)tPyDTHSNMoHgY5YWBayiyGh986ai)Cxezamzq6DsuZjyZNxb2EuZLaWSu9icbzxagtQuat5)ukgDfNxha5MtaxhYA0jbnAP8FkfJUIZRdGCZjGRdzpnDPO1iiKail2EMQhrifrx0H0OP1iiKail2Eg4rpVoaYp3fbnAAnccjaYITNbG7KY5sFbc)iyQPMQoHgY5YWBayiyQEeHGSlaJzamDi9ojQ5eS5ZRaBpQ5saywZNxb2EGjr2r4Om8gagcG7tQuatzH)NsXAp7PlcYeHtOd0CPrBH)NsXAp7PlcYACZRta6(8tv3)Pum6koVoaYnNaUoK1OtcA0s5)ukgDfNxha5MtaxhYEA6srRrqibqwS9mvpIqkIUOdPrtRrqibqwS9mWJEEDaKFUlcA00AeesaKfBpda3jLZL(ce(rWutfsVtIAobB(8kW2JAUeaM185vGThysLc4)Pum6koVoaYnNaUoK1OtcA0s5)ukgDfNxha5MtaxhYEA6srRrqibqwS9mvpIqkIUOdPrtRrqibqwS9mWJEEDaKFUlcA00AeesaKfBpda3jLZL(ce(rWutfsVtIAobB(8kW2JAUeaM1c9aSqUEysLcOtIceOepCRqrgPdP3jrnNGnFEfy7rnxcaZAHEaw63sUqIVlPsb0jrbcuIhUvOiJ0H07KOMtWMpVcS9OMlbGzbG7KY5sFbc)iysLcyk59FkfRRnK90OrRFxrKAJESzluvKkaDF(0O1VdzrTHYyKPNbaYkvDcnKZLH3aWqWaWDs5CPVaHFemdGPdP3jrnNGnFEfy7rnxcaZc8ONxha5N7IiPsb8)ukwxBi7PPtOHCUm8gagcg4rpVoaYp3frgathsVtIAobB(8kW2JAUeaMLQhrifrx0Hjr2r4Om8gagcG7tQuatzH)NsXAp7PlcYeHtOd0CPrBH)NsXAp7PlcYACZRta6(8tvxE)NsX6AdzpnA063veP2OhB2cvfPcq3NpnA97qwuBOmgz6zaGS0Lx4C8cMQhrii7cWidp)ZXfKENe1Cc285vGTh1CjamlvpIqkIUOdtQuaZ7)ukwxBi7PrJw)UIi1g9yZwOQiva6(8PrRFhYIAdLXitpdaKfKENe1Cc285vGTh1CjamlWJEEDaKFUlIKkfW)tPyDTHSNgKENe1Cc285vGTh1CjamR5ZRaBpWKi7iCugEdadbW9jvkGPSW)tPyTN90fbzIWj0bAU0OTW)tPyTN90fbznU51jaDF(PQlVW54fmvpIqq2fGrgE(NJli9ojQ5eS5ZRaBpQ5saywZNxb2EGq6H0dYGwQWVL3lOvuhaocshEdadOTNWJAoi9ojQ5emr43Y7fWg3MwGCuiK6RlWgsVtIAobte(T8ELaWSu9icPi6IomPsbKmdFn6pwJBtlqokes91fyZACZRtakW0ZraKLUW54fmaEag76aifX0Bm88phxq6DsuZjyIWVL3ReaMf4rpVoaYp3frsLc4)PuSU2q2tdsVtIAobte(T8ELaWSMpVcS9atQuadNJxWkcsCngE(NJlD)NsX0ko3B5OKQEeb7PPZZg7kqwr2jjv4lKZA)OldGPdP3jrnNGjc)wEVsaywZNxb2EGjvkG59Fkft1t24j1ECbYEA6cNJxWu9KnEsThxGm88phxq6DsuZjyIWVL3ReaMLQhrifrx0HjvkG97kIuB0JnBHQIubOPSp3ecNJxW63vePhbEppQ5y45FoUYXKLkKENe1CcMi8B59kbGzP6recYUamMuPa(FkfJUIZRdGCZjGRdzpnD97qwuBOmgzYLbqaKfKENe1CcMi8B59kbGznFEfy7bMuPa2VRisTrp2SfQksfzKs65Mq4C8cw)UIi9iW75rnhdp)ZXvoMSuH07KOMtWeHFlVxjamlvpIqkIUOdH07KOMtWeHFlVxjamlWtFYrj1xxGnKENe1CcMi8B59kbGz5nXpugt34fMWegd]] )
    
end
