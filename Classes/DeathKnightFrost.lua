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
        chill_streak = 706, -- 305392
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
            duration = 5,
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

            toggle = "interrupts",

            talent = "asphyxiate",

            debuff = "casting",
            readyTime = state.timeToInterrupt,            

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

            spend = 16,
            readySpend = function () return settings.bos_rp end,
            spendType = "runic_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 1029007,

            handler = function ()
                gain( 2, "runes" )
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

            startsCombat = true,
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

            range = 7,

            handler = function ()
                removeBuff( "killing_machine" )
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

            range = 7,

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

        potion = "potion_of_unbridled_fury",

        package = "Frost DK",
    } )


    spec:RegisterSetting( "bos_rp", 50, {
        name = "Runic Power for |T1029007:0|t Breath of Sindragosa",
        desc = "The addon will not recommend |T1029007:0|t Breath of Sindragosa only if you have this much Runic Power (or more).",
        icon = 1029007,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 16,
        max = 100,
        step = 1,
        width = 1.5
    } )

    
    spec:RegisterPack( "Frost DK", 20200619, [[dKuvtcqirfpciHnrQmkrWPeHwLOk6vIOMLiXTass7cXVePAyIQ6ykLwMOupteX0erQRjQ02asQVbKeJdirNtejwNOkvnpG4EaAFIIoOisQwOOWdfvjmrrvQ4IIij2OOkLrkIKsNuejPvIQQxkQsQUPOkrzNIK(POkr1qfvjYsfvPspfvMQiLVkQsk7Ls)LObtXHPAXQQhJ0KvYLH2mjFgGrJQCAjRwuLKxJQYSr52kv7wLFRy4KYXfvHLl1ZjmDHRRkBhi13jvnErKuCELI1lkz(a1(bTDRnnl3Yd0MA25ND(5dQ3MuiBbLBbLBZ2YfB0qlNMt5ZbGwUZ3rlxERhran5DYRB508nSXx20SCI51u0YXlcnrEF6PdOcEVpHo7PlQ9hZJAoA7QiDrTtt3Y9FflsQE2VLB5bAtn78Zo)8b1BtkKTGYTGY8tILZFbVPTCC1EEHLJxTw4z)wUfkOwoqb0K36reqtEh0dEqtE9RaWlG8dkGgErOjY7tpDavW79j0zpDrT)yEuZrBxfPlQDA6q(bfqd)VdHMTjLuGMSZp78H8d5huan5f88dakY7H8dkGgqvOjP6rzVfcn5Lv3cAYBnIzHei)GcObufAsQVwqJYzSVt5dAutdnprDaGMKk5DZRLc0KxAYBqtPGgnMVbBOPUkkpqb0KXWbnFunncnAZWQda0WgaffAkb0qNDngg4Ia5huanGQqtEbp)aGqt4namirTJYyKRcHMyGMO2rzmYvHqtmqZtGqdE05Db2qddpabpOP9Gh2qtWZpOrBc8IYzqt0UGh0Sqp4jiq(bfqdOk0KxmSf0Kul6Dan(TGM2PLZGMqp68jiwowjcHnnlhDyljp07WMMn1T20SC45FgUSzy5ODfyxUL7)ukcDyljp07GicNYh0Kj0Kl0OdAIAhLXixfcnGanaOllNtJAolhLNxNqokzrrBytnBBAwo88pdx2mSC0UcSl3YLa08FkfrGyWRoaY2bGKg396eqdiqda6cAseA0bn)Nsreig8QdGSDai5Pz5CAuZz5O886eYrjlkAdBQjXMMLdp)ZWLndlhTRa7YTCjan)Nsr0kgZB5OKQEebPXDVob0acqObaDbn5j0Ka0SfAsgAOZWwJ(JO6re6307cP61Bin6RnqtIqdyWqZ)PueTIX8wokPQhrqAC3RtanGan97qsu7OmgzsGMeHgDqZ)PueTIX8wokPQhrqEAqJoOjbOXZc7kqsr3iPv4lKrA)4dAabi0SfAadgA(pLI8B0dEYrjf1TAhWiCYtdAseA0bn5anHZWliffPUgbp)ZWLLZPrnNLJYZRtihLSOOnSPM020SC45FgUSzy5ODfyxUL7)ukIwXyElhLu1JiinU71jGgqGgqj0OdA(pLI8oEdBJuenEacEKg396eqdiqda6cAYtOjbOzl0Km0qNHTg9hr1Ji0VP3fs1R3qA0xBGMeHgDqZ)PuK3XByBKIOXdqWJ04UxNaA0bn)Nsr0kgZB5OKQEeb5Pbn6GMeGgplSRajfDJKwHVqgP9JpObeGqZwObmyO5)ukYVrp4jhLuu3QDaJWjpnOjrOrh0Kd0eodVGuuK6Ae88pdxwoNg1CwokpVoHCuYII2WMAU20SC45FgUSzy5ODfyxULlbO5)uksr3iPv4lKrAC3RtanGanjn0agm08FkfPOBK0k8fYinU71jGgqGM(DijQDugJmjqtIqJoO5)uksr3iPv4lKrEAqJoOXZc7kqsr3iPv4lKrA)4dAYei0Kn0OdAYbA(pLI8B0dEYrjf1TAhWiCYtdA0bn5anHZWliffPUgbp)ZWLLZPrnNLJYZRtihLSOOnSPcQTPz5WZ)mCzZWYr7kWUCl3)PuKIUrsRWxiJ80GgDqZ)PuK3XByBKIOXdqWJ80GgDqJNf2vGKIUrsRWxiJ0(Xh0KjqOjBOrh0Kd08Fkf53Oh8KJskQB1oGr4KNg0OdAYbAcNHxqkksDncE(NHllNtJAolhLNxNqokzrrBytfuXMMLdp)ZWLndlhTRa7YTC)Nsr0kgZB5OKQEebPXDVob0ac0K0qJoO5)ukIwXyElhLu1JiipnOrh0eodVGuuK6Ae88pdxqJoO5)ukcDyljp07GicNYh0KjqOzlOeA0bnEwyxbsk6gjTcFHms7hFqdiaHMTwoNg1CwokpVoHCuYII2WMkO0MMLdp)ZWLndlhTRa7YTC)Nsr0kgZB5OKQEeb5Pbn6GMWz4fKIIuxJGN)z4cA0bnEwyxbsk6gjTcFHms7hFqtMaHMSHgDqtcqZ)Pue6WwsEO3breoLpOjtGqZ2Kc0OdA(pLIu0nsAf(czKg396eqdiqda6cA0bn)Nsrk6gjTcFHmYtdAadgA(pLI8oEdBJuenEacEKNg0OdA(pLIqh2sYd9oiIWP8bnzceA2ckHMeTConQ5SCuEEDc5OKffTHnSCZNvb2EuZztZM6wBAwo88pdx2mSC0UcSl3YfodVGaWdEyxhaPiMENGN)z4YY50OMZY14(0cKHcHuFDb22WMA220SC45FgUSzy5CAuZz5MpRcS9aTC0UcSl3YLa0SW)tPiTN10ffjIWP8bnGan5cnGbdnl8)uks7znDrrsJ7EDcObeOzB(qtIqJoOjhOjCgEbr1Jie0nbpKGN)z4cA0bn5an)Nsr6AhjpnOrh0i0qgtgEdadbH3ONvha5N5IaAYei0KelhDdLHYWBayiSPU1g2utInnlhE(NHlBgwoAxb2LB5YbAcNHxqu9icbDtWdj45FgUGgDqtoqZ)PuKU2rYtdA0bncnKXKH3aWqq4n6z1bq(zUiGMmbcnjXY50OMZYnFwfy7bAdBQjTnnlhE(NHlBgwoAxb2LB5saA(pLIWxXy1bqU7uE1HKgDAanGbdnjan)Nsr4RyS6ai3DkV6qYtdA0bnjanAncAja6ISLO6resr0fFi0agm0O1iOLaOlYwcVrpRoaYpZfb0agm0O1iOLaOlYwcaMtlNj9fO9JIqtIqtIqtIqJoOrOHmMm8gagcIQhriOBcEi0KjqOjBlNtJAolNQhriOBcEOnSPMRnnlhE(NHlBgwoNg1CwU5ZQaBpqlhTRa7YTCjanl8)uks7znDrrIiCkFqdiqtUqdyWqZc)pLI0EwtxuK04UxNaAabA2Mp0Ki0OdA(pLIWxXy1bqU7uE1HKgDAanGbdnjan)Nsr4RyS6ai3DkV6qYtdA0bnjanAncAja6ISLO6resr0fFi0agm0O1iOLaOlYwcVrpRoaYpZfb0agm0O1iOLaOlYwcaMtlNj9fO9JIqtIqtIwo6gkdLH3aWqytDRnSPcQTPz5WZ)mCzZWYr7kWUCl3)Pue(kgRoaYDNYRoK0OtdObmyOjbO5)ukcFfJvha5Ut5vhsEAqJoOjbOrRrqlbqxKTevpIqkIU4dHgWGHgTgbTeaDr2s4n6z1bq(zUiGgWGHgTgbTeaDr2saWCA5mPVaTFueAseAs0Y50OMZYnFwfy7bAdBQGk20SC45FgUSzy5ODfyxULlbOjhO5)uksx7i5PbnGbdn97kQuB0JnzHQIwb0ac0SnFObmyOPFhsIAhLXiZgAYeAaqxqtIqJoOrOHmMm8gagccaMtlNj9fO9JIqtMaHMSTConQ5SCayoTCM0xG2pkAdBQGsBAwo88pdx2mSC0UcSl3Y9FkfPRDK80GgDqJqdzmz4nameeEJEwDaKFMlcOjtGqt2woNg1CwoEJEwDaKFMlcBytnPytZYHN)z4YMHLZPrnNLt1JiKIOl(qlhTRa7YTCjanl8)uks7znDrrIiCkFqdiqtUqdyWqZc)pLI0EwtxuK04UxNaAabA2Mp0Ki0OdAYbA(pLI01osEAqdyWqt)UIk1g9ytwOQOvanGanBZhAadgA63HKO2rzmYSHMmHga0f0OdAYbAcNHxqu9icbDtWdj45FgUSC0nugkdVbGHWM6wBytDB(20SC45FgUSzy5ODfyxULlhO5)uksx7i5PbnGbdn97kQuB0JnzHQIwb0ac0SnFObmyOPFhsIAhLXiZgAYeAaqxwoNg1CwovpIqkIU4dTHn1TBTPz5WZ)mCzZWYr7kWUCl3)PuKU2rYtZY50OMZYXB0ZQdG8ZCrydBQBZ2MMLdp)ZWLndlNtJAol38zvGThOLJ2vGD5wUeGMf(FkfP9SMUOireoLpObeOjxObmyOzH)NsrApRPlksAC3RtanGanBZhAseA0bn5anHZWliQEeHGUj4He88pdxwo6gkdLH3aWqytDRnSPUnj20SConQ5SCZNvb2EGwo88pdx2mSHnSC)riJIYxDaSPztDRnnlhE(NHlBgwoAxb2LB5OZWwJ(JG7AJESL97qPE01MJ04UxNWY50OMZYPvmM3Yrjv9icBytnBBAwoNg1CwoCxB0JTSFhk1JU2Cwo88pdx2mSHn1KytZYHN)z4YMHLZPrnNLB(SkW2d0Yr7kWUClxcqZc)pLI0EwtxuKicNYh0ac0Kl0agm0SW)tPiTN10ffjnU71jGgqGMT5dnjcn6GM(DfvQn6XgAabi0KKSHgDqtoqt4m8cIQhriOBcEibp)ZWLLJUHYqz4name2u3AdBQjTnnlhE(NHlBgwoAxb2LB563vuP2OhBObeGqtsY2Y50OMZYnFwfy7bAdBQ5AtZYHN)z4YMHLJ2vGD5wUWz4feaEWd76aifX07e88pdxwoNg1CwUg3NwGmuiK6RlW2g2ub120SC45FgUSzy5ODfyxUL7)uksx7i5Pz5CAuZz54n6z1bq(zUiSHnvqfBAwo88pdx2mSConQ5SCZNvb2EGwoAxb2LB5saAw4)PuK2ZA6IIer4u(GgqGMCHgWGHMf(FkfP9SMUOiPXDVob0ac0SnFOjrOrh00VdjrTJYyK5cnGanaOlObmyOPFxrLAJESHgqacnjDUqJoOjhOjCgEbr1Jie0nbpKGN)z4YYr3qzOm8gagcBQBTHnvqPnnlhE(NHlBgwoAxb2LB563HKO2rzmYCHgqGga0f0agm00VROsTrp2qdiaHMKoxlNtJAol38zvGThOnSPMuSPz5WZ)mCzZWYr7kWUCl3)Pue(kgRoaYDNYRoK80GgDqJqdzmz4nameevpIqq3e8qOjtGqt2woNg1CwovpIqq3e8qBytDB(20SC45FgUSzy5ODfyxULRFxrLAJESjluv0kGMmbcnjjBOrh00VdjrTJYyKjbAYeAaqxwoNg1CwoEtFYrj1xxGTnSPUDRnnlNtJAolxJ7tlqgkes91fyB5WZ)mCzZWg2u3MTnnlhE(NHlBgwoAxb2LB5eAiJjdVbGHGO6rec6MGhcnzceAY2Y50OMZYP6rec6MGhAdBQBtInnlhE(NHlBgwoNg1CwU5ZQaBpqlhTRa7YTCjanl8)uks7znDrrIiCkFqdiqtUqdyWqZc)pLI0EwtxuK04UxNaAabA2Mp0Ki0OdA63vuP2OhBYcvfTcOjtOj7CHgWGHM(Di0Kj0KeOrh0Kd0eodVGO6rec6MGhsWZ)mCz5OBOmugEdadHn1T2WM62K2MMLdp)ZWLndlhTRa7YTC97kQuB0JnzHQIwb0Kj0KDUqdyWqt)oeAYeAsILZPrnNLB(SkW2d0g2u3MRnnlhE(NHlBgwoAxb2LB563vuP2OhBYcvfTcOjtOj38TConQ5SCEt9dLX0nEHnSHLdfc8OOWMMn1T20SC45FgUSzy5ODfyxUL7)ukIwXyElhLu1JiipnOrh0Ka08FkfrRymVLJsQ6reKg396eqdiqZ28HgDqtcqZ)PuKFJEWtokPOUv7agHtEAqdyWqt4m8cY8zvGTh1Ce88pdxqdyWqt4m8csrrQRrWZ)mCbn6GMCGgplSRajfDJKwHVqgbp)ZWf0Ki0agm08FkfPOBK0k8fYipnOrh0eodVGuuK6Ae88pdxqtIqJoOjbOXPrbAuIhUxOaAacnBHgWGHMCGMWz4fKIIuxJGN)z4cAseAadgACAuGgL4H7fkGMmbcnzdn6GMWz4fKIIuxJGN)z4cA0bn0zyRr)r0kgZB5OKQEebPrFTbA0bnjanEwyxbsk6gjTcFHms7hFqtMaHMTqJoO5)uksr3iPv4lKrEAqdyWqtoqJNf2vGKIUrsRWxiJGN)z4cAs0Y50OMZY9zZSKJsg8qjE4(gBytnBBAwo88pdx2mSC0UcSl3YLd0eodVGuuK6Ae88pdxqdyWqt4m8csrrQRrWZ)mCbn6GgplSRajfDJKwHVqgbp)ZWf0OdA(pLIOvmM3Yrjv9icsJ7EDcObeObudn6GM)tPiAfJ5TCusvpIG80GgWGHMWz4fKIIuxJGN)z4cA0bn5anEwyxbsk6gjTcFHmcE(NHllNtJAolhGN3RYp5OKEwypbpBytnj20SC45FgUSzy5ODfyxUL7)ukIwXyElhLu1JiinU71jGgqGMCHgDqZ)PueTIX8wokPQhrqEAqdyWqtu7Omg5QqObeOjxlNtJAolhLxXysr0OZNnSPM020SC45FgUSzy5ODfyxUL7)uksJu(yOqivttrYtdAadgA(pLI0iLpgkes10uusN3fyteHt5dAabA2U1Y50OMZYf8q57(Z7ws10u0g2uZ1MMLdp)ZWLndlhTRa7YTC5an)Nsr0kgZB5OKQEeb5Pbn6GMCGM)tPi)g9GNCusrDR2bmcN80SConQ5SCQH(e4s6zHDfO8J(UnSPcQTPz5WZ)mCzZWYr7kWUClxoqZ)PueTIX8wokPQhrqEAqJoOjhO5)ukYVrp4jhLuu3QDaJWjpnOrh0SMGqNJIx0EGlPI57O8)6J04UxNaAacn5B5CAuZz5OZrXlApWLuX8D0g2ubvSPz5WZ)mCzZWYr7kWUCl3)PueTIX8wokPQhrqEAqdyWqZ)PueCxB0JTSFhk1JU2CKNg0agm0qNHTg9h53Oh8KJskQB1oGr4Kg396eqtMqdOoFOjzOzBUqdyWqdD6(Pf1CcsDOs5FgkJ(f8i45FgUSConQ5SC6NMTanwNSrXC(rrBytfuAtZYHN)z4YMHLJ2vGD5wUCGM)tPiAfJ5TCusvpIG80GgDqtoqZ)PuKFJEWtokPOUv7agHtEAwoNg1CwUU00yOSoPqZPOnSPMuSPz5WZ)mCzZWYr7kWUCl3)PueCxB0JTSFhk1JU2CKg396eqdiqtUqJoO5)ukYVrp4jhLuu3QDaJWjpnObmyOjbOPFhsIAhLXiZgAYeAaqxqJoOPFxrLAJESHgqGMCZhAs0Y50OMZYTJ7tVrokj7rRLC1OVlSHn1T5BtZY50OMZY1ORvhaPI57OWYHN)z4YMHnSHL7pcP2mS6aytZM6wBAwo88pdx2mSC0UcSl3Y9FkfPRDK80SConQ5SC8g9S6ai)mxe2WMA220SC45FgUSzy5CAuZz5MpRcS9aTC0UcSl3YLa0SW)tPiTN10ffjIWP8bnGan5cnGbdnl8)uks7znDrrsJ7EDcObeOzB(qtIqJoOPFxrLAJESjluv0kGMmbcnzNl0OdAYbAcNHxqu9icbDtWdj45FgUSC0nugkdVbGHWM6wBytnj20SC45FgUSzy5ODfyxULRFxrLAJESjluv0kGMmbcnzNRLZPrnNLB(SkW2d0g2utABAwo88pdx2mSC0UcSl3Y1VROsTrp2KfQkAfqdiqt25dn6GgHgYyYWBayiiayoTCM0xG2pkcnzceAYgA0bn0zyRr)r0kgZB5OKQEebPXDVob0Kj0KRLZPrnNLdaZPLZK(c0(rrBytnxBAwo88pdx2mSConQ5SCQEeHueDXhA5ODfyxULlbOzH)NsrApRPlkseHt5dAabAYfAadgAw4)PuK2ZA6IIKg396eqdiqZ28HMeHgDqt)UIk1g9ytwOQOvanGanzNp0OdAYbAcNHxqu9icbDtWdj45FgUGgDqdDg2A0FeTIX8wokPQhrqAC3Rtanzcn5A5OBOmugEdadHn1T2WMkO2MMLdp)ZWLndlhTRa7YTC97kQuB0JnzHQIwb0ac0KD(qJoOHodBn6pIwXyElhLu1JiinU71jGMmHMCTConQ5SCQEeHueDXhAdBQGk20SC45FgUSzy5ODfyxUL7)ukcFfJvha5Ut5vhsEAqJoOPFxrLAJESjluv0kGMmHMeGMT5cnjdnHZWli97kQ0JaVNh1Ce88pdxqtEcnjbAseA0bncnKXKH3aWqqu9icbDtWdHMmbcnzB5CAuZz5u9icbDtWdTHnvqPnnlhE(NHlBgwoAxb2LB563vuP2OhBYcvfTcOjtGqtcqtsYfAsgAcNHxq63vuPhbEppQ5i45FgUGM8eAsc0Ki0OdAeAiJjdVbGHGO6rec6MGhcnzceAY2Y50OMZYP6rec6MGhAdBQjfBAwo88pdx2mSConQ5SCZNvb2EGwoAxb2LB5saAw4)PuK2ZA6IIer4u(GgqGMCHgWGHMf(FkfP9SMUOiPXDVob0ac0SnFOjrOrh00VROsTrp2KfQkAfqtMaHMeGMKKl0Km0eodVG0VROspc8EEuZrWZ)mCbn5j0KeOjrOrh0Kd0eodVGO6rec6MGhsWZ)mCz5OBOmugEdadHn1T2WM628TPz5WZ)mCzZWYr7kWUClx)UIk1g9ytwOQOvanzceAsaAssUqtYqt4m8cs)UIk9iW75rnhbp)ZWf0KNqtsGMeTConQ5SCZNvb2EG2WM62T20SC45FgUSzy5ODfyxULJodBn6pIwXyElhLu1JiinU71jGMmHM(DijQDugJmPHgDqt)UIk1g9ytwOQOvanGanjD(qJoOrOHmMm8gagccaMtlNj9fO9JIqtMaHMSTConQ5SCayoTCM0xG2pkAdBQBZ2MMLdp)ZWLndlNtJAolNQhrifrx8HwoAxb2LB5saAw4)PuK2ZA6IIer4u(GgqGMCHgWGHMf(FkfP9SMUOiPXDVob0ac0SnFOjrOrh0qNHTg9hrRymVLJsQ6reKg396eqtMqt)oKe1okJrM0qJoOPFxrLAJESjluv0kGgqGMKoFOrh0Kd0eodVGO6rec6MGhsWZ)mCz5OBOmugEdadHn1T2WM62KytZYHN)z4YMHLJ2vGD5wo6mS1O)iAfJ5TCusvpIG04UxNaAYeA63HKO2rzmYKgA0bn97kQuB0JnzHQIwb0ac0K05B5CAuZz5u9icPi6Ip0g2WYP1iD2)EytZM6wBAwoNg1CwoTjQ5SC45FgUSzydBQzBtZYHN)z4YMHL78D0Y5zj45TlKQ5c5OKAJESTConQ5SCEwcEE7cPAUqokP2OhBBytnj20SC45FgUSzy5gnlNadlNtJAolhO9U8pdTCG2zp0YLa0G5XR00Wf5My6AEcjaMVkpMwi)(cacnGbdnyE8knnCrOt3pTaxsamFvEmTq(9faeAadgAW84vAA4IqNUFAbUKay(Q8yAHChxoJvZbnGbdnyE8knnCraD5m5OK(v7EGl5NnZcAadgAW84vAA4IOQweYDpqHuOTbaZfcObmyObZJxPPHlsEfkK8g9mSHgWGHgmpELMgUi3etxZtibW8v5X0c5oUCgRMdAadgAW84vAA4I4cEG2puiBpRPL0PDg0KOLd0ElpFhTCtWdB5CYNaLyE8knnCzdBy5OZWwJ(tytZM6wBAwo88pdx2mSConQ5SCEwcEE7cPAUqokP2OhBlhTRa7YTCjan0zyRr)rWDTrp2Y(DOup6AZrA0xBGgDqtoqdO9U8pdjtWdB5CYNaLyE8knnCbnjcnGbdnjan0zyRr)r0kgZB5OKQEebPXDVob0acqOzB(qJoOb0Ex(NHKj4HTCo5tGsmpELMgUGMeTCNVJwoplbpVDHunxihLuB0JTnSPMTnnlhE(NHlBgwoNg1Cwo2R5dBHSorTQ5jKakvy5ODfyxULlCgEb53Oh8KJskQB1oGr4e88pdxqJoOjbOjbOHodBn6pIwXyElhLu1JiinU71jGgqacnBZhA0bnG27Y)mKmbpSLZjFcuI5XR00Wf0Ki0agm0Ka08FkfrRymVLJsQ6reKNg0OdAYbAaT3L)zizcEylNt(eOeZJxPPHlOjrOjrObmyOjbO5)ukIwXyElhLu1JiipnOrh0Kd0eodVG8B0dEYrjf1TAhWiCcE(NHlOjrl357OLJ9A(WwiRtuRAEcjGsf2WMAsSPz5WZ)mCzZWY50OMZYr3qzt0Zvu5N5IWYr7kWUClxoqZ)PueTIX8wokPQhrqEAwUZ3rlhDdLnrpxrLFMlcBytnPTPz5WZ)mCzZWYr7kWUClxcqdDg2A0FeTIX8wokPQhrqA0xBGgWGHg6mS1O)iAfJ5TCusvpIG04UxNaAYeAYoFOjrOrh0Ka0Kd0eodVG8B0dEYrjf1TAhWiCcE(NHlObmyOHodBn6pcURn6Xw2VdL6rxBosJ7EDcOjtOjPKl0KOLZPrnNL7jqzf4UWg2uZ1MMLdp)ZWLndlNtJAolNl4bA)qHS9SMwsN2zwoAxb2LB5w4)PuK2ZAAjDANjx4)PuK1O)SCNVJwoxWd0(Hcz7znTKoTZSHnvqTnnlhE(NHlBgwoNg1CwoxWd0(Hcz7znTKoTZSC0UcSl3YrNHTg9hb31g9yl73Hs9ORnhPXDVob0Kj0KuYhA0bnl8)uks7znTKoTZKl8)ukYtdA0bnG27Y)mKmbpSLZjFcuI5XR00Wf0agm08Fkf53Oh8KJskQB1oGr4KNg0OdAw4)PuK2ZAAjDANjx4)PuKNg0OdAYbAaT3L)zizcEylNt(eOeZJxPPHlObmyO5)ukcURn6Xw2VdL6rxBoYtdA0bnl8)uks7znTKoTZKl8)ukYtdA0bn5anHZWli)g9GNCusrDR2bmcNGN)z4cAadgAIAhLXixfcnGanzV1YD(oA5Cbpq7hkKTN10s60oZg2ubvSPz5WZ)mCzZWY50OMZYLxHcjVrpdBlhTRa7YTCjanyE8knnCryVMpSfY6e1QMNqcOub0OdA(pLIOvmM3Yrjv9icsJ7EDcOjrObmyOjbOjhObZJxPPHlc718HTqwNOw18esaLkGgDqZ)PueTIX8wokPQhrqAC3RtanGanBZgA0bn)Nsr0kgZB5OKQEeb5PbnjA5oFhTC5vOqYB0ZW2g2ubL20SC45FgUSzy5CAuZz547MqokPF0cVqQE9glhTRa7YTC0zyRr)rWDTrp2Y(DOup6AZrAC3RtanzcnjD(wUZ3rlhF3eYrj9Jw4fs1R3ydBQjfBAwo88pdx2mSConQ5SCa65aiKADT7mz7aqlhTRa7YTC97qObeGqtsGgDqtoqZ)PueTIX8wokPQhrqEAqJoOjbOjhO5)ukYVrp4jhLuu3QDaJWjpnObmyOjhOjCgEb53Oh8KJskQB1oGr4e88pdxqtIwUZ3rlhGEoacPwx7ot2oa0g2u3MVnnlhE(NHlBgwUZ3rlx7zTEhFc5VaiBCj)ViMZY50OMZY1EwR3XNq(laYgxY)lI5SHn1TBTPz5WZ)mCzZWY50OMZYTJnYxWZfsLFaSC0UcSl3YLd08Fkf53Oh8KJskQB1oGr4KNg0OdAYbA(pLIOvmM3Yrjv9icYtZYD(oA52Xg5l45cPYpa2WM62STPz5WZ)mCzZWYr7kWUCl3)PueTIX8wokPQhrqEAqJoO5)ukcURn6Xw2VdL6rxBoYtZY50OMZYPnrnNnSPUnj20SC45FgUSzy5ODfyxUL7)ukIwXyElhLu1JiipnOrh08Fkfb31g9yl73Hs9ORnh5Pz5CAuZz5(Szws1R3ydBQBtABAwo88pdx2mSC0UcSl3Y9FkfrRymVLJsQ6reKNMLZPrnNL7JTaB(QdGnSPUnxBAwo88pdx2mSC0UcSl3YLa0Kd08FkfrRymVLJsQ6reKNg0OdACAuGgL4H7fkGMmbcnzdnjcnGbdn5an)Nsr0kgZB5OKQEeb5Pbn6GMeGM(DizHQIwb0KjqOjxOrh00VROsTrp2KfQkAfqtMaHgqD(qtIwoNg1CwoVP(HsThtG2WM6wqTnnlhE(NHlBgwoAxb2LB5(pLIOvmM3Yrjv9icYtZY50OMZYXka8cHmV6TaSJxydBQBbvSPz5WZ)mCzZWYr7kWUCl3)PueTIX8wokPQhrqEAqJoO5)ukcURn6Xw2VdL6rxBoYtZY50OMZY5hffr7mj1zmBytDlO0MMLdp)ZWLndlhTRa7YTC)Nsr0kgZB5OKQEebPXDVob0acqObucn6GM)tPi4U2OhBz)ouQhDT5ipnlNtJAolNQA8ZMzzdBQBtk20SC45FgUSzy5ODfyxUL7)ukIwXyElhLu1JiipnOrh0Ka08FkfrRymVLJsQ6reKg396eqdiqtUqJoOjCgEbHoSLKh6DqWZ)mCbnGbdn5anHZWli0HTK8qVdcE(NHlOrh08FkfrRymVLJsQ6reKg396eqdiqtsGMeHgDqJtJc0OepCVqb0aeA2cnGbdn)Nsreig8QdGSDai5Pbn6GgNgfOrjE4EHcObi0S1Y50OMZY9DaYrjJUO8jSHn1SZ3MMLdp)ZWLndlhTRa7YTCjan0zyRr)rWDTrp2Y(DOup6AZrAC3RtanGbdnHZWliffPUgbp)ZWf0Ki0OdAYbA(pLIOvmM3Yrjv9icYtdAadgAcNHxqkksDncE(NHlOrh04zHDfir1Ji0ZdzAczDRcW5rnhbp)ZWf0OdA(pLIOvmM3Yrjv9icsJ7EDcObeOjBlNtJAolNwXyElhLu1JiSHn1S3AtZYHN)z4YMHLJ2vGD5wo6mS1O)i4U2OhBz)ouQhDT5inU71jGgDqdDg2A0FeTIX8wokPQhrqAC3Rty5CAuZz5(n6bp5OKI6wTdyeUL7jq5Ousa0Ln1T2WMA2zBtZYHN)z4YMHLJ2vGD5wo6mS1O)iAfJ5TCusvpIG0OV2an6GMWz4fK5ZQaBpQ5i45FgUGgDqt)oKe1okJrMl0Kj0aGUGgDqt)UIk1g9ytwOQOvanzceA2Mp0agm0e1okJrUkeAabAYoFlNtJAolhURn6Xw2VdL6rxBoBytn7KytZYHN)z4YMHLJ2vGD5wUeGg6mS1O)iAfJ5TCusvpIG0OV2anGbdnrTJYyKRcHgqGMSZhAseA0bnHZWli)g9GNCusrDR2bmcNGN)z4cA0bn97kQuB0Jn0Kj0aQZ3Y50OMZYH7AJESL97qPE01MZg2uZoPTPz5WZ)mCzZWYr7kWUClx4m8csrrQRrWZ)mCbn6GM(Di0ac0KelNtJAolhURn6Xw2VdL6rxBoBytn7CTPz5WZ)mCzZWYr7kWUClx4m8ccDyljp07GGN)z4cA0bnjanjan)NsrOdBj5HEher4u(GMmbcnBZhA0bnl8)uks7znDrrIiCkFqdqOjxOjrObmyOjQDugJCvi0acqObaDbnjA5CAuZz5OoJjDAuZjzLiSCSseYZ3rlhDyljp07Wg2uZguBtZYHN)z4YMHLJ2vGD5wUeGM)tPiAfJ5TCusvpIG80GgDqJNf2vGKIUrsRWxiJ0(Xh0acqOzl0OdAsaA(pLIOvmM3Yrjv9icsJ7EDcObeGqda6cAadgA(pLI8oEdBJuenEacEKg396eqdiaHga0f0OdA(pLI8oEdBJuenEacEKNg0Ki0KOLZPrnNLt1Ji0VP3fs1R3ydBQzdQytZYHN)z4YMHLJ2vGD5wUeGM)tPifDJKwHVqg5Pbn6GMCGMWz4fKIIuxJGN)z4cA0bnjan)NsrEhVHTrkIgpabpYtdAadgA(pLIu0nsAf(czKg396eqdiaHga0f0Ki0Ki0agm08FkfPOBK0k8fYipnOrh08FkfPOBK0k8fYinU71jGgqacnaOlOrh0eodVGuuK6Ae88pdxqJoO5)ukIwXyElhLu1JiipnlNtJAolNQhrOFtVlKQxVXg2uZguAtZYHN)z4YMHLJ2vGD5wUO2rzmYvHqdiqda6cAadgAsaAIAhLXixfcnGan0zyRr)r0kgZB5OKQEebPXDVob0OdA(pLI8oEdBJuenEacEKNg0KOLZPrnNLt1Ji0VP3fs1R3ydBy5eHFlVx20SPU1MMLZPrnNLRX9PfidfcP(6cSTC45FgUSzydBQzBtZYHN)z4YMHLJ2vGD5wo6mS1O)inUpTazOqi1xxGnPXDVob0acqOjBOjpHga0f0OdAcNHxqa4bpSRdGuetVtWZ)mCz5CAuZz5u9icPi6Ip0g2utInnlhE(NHlBgwoAxb2LB5(pLI01osEAwoNg1CwoEJEwDaKFMlcBytnPTPz5WZ)mCzZWYr7kWUClx4m8csrrQRrWZ)mCbn6GM)tPiAfJ5TCusvpIG80GgDqJNf2vGKIUrsRWxiJ0(Xh0KjqOjBlNtJAol38zvGThOnSPMRnnlhE(NHlBgwoAxb2LB5YbA(pLIO6jl8KApMajpnOrh0eodVGO6jl8KApMaj45FgUSConQ5SCZNvb2EG2WMkO2MMLdp)ZWLndlhTRa7YTC97kQuB0JnzHQIwb0ac0Ka0SnxOjzOjCgEbPFxrLEe498OMJGN)z4cAYtOjjqtIwoNg1CwovpIqkIU4dTHnvqfBAwo88pdx2mSC0UcSl3Y9FkfHVIXQdGC3P8QdjpnOrh00VdjrTJYyKjn0KjqObaDz5CAuZz5u9icbDtWdTHnvqPnnlhE(NHlBgwoAxb2LB563vuP2OhBYcvfTcOjtOjbOj7CHMKHMWz4fK(Dfv6rG3ZJAocE(NHlOjpHMKanjA5CAuZz5MpRcS9aTHn1KInnlNtJAolNQhrifrx8Hwo88pdx2mSHn1T5BtZY50OMZYXB6tokP(6cSTC45FgUSzydBQB3AtZY50OMZY5n1pugt34fwo88pdx2mSHnSClu5pwytZM6wBAwoNg1CwU96wsvJywOLdp)ZWLndBytnBBAwo88pdx2mSC0UcSl3YLd0SMGO6resfcASjrr5RoaqJoOjbOjhOjCgEb53Oh8KJskQB1oGr4e88pdxqdyWqdDg2A0FKFJEWtokPOUv7agHtAC3RtanzcnBZfAs0Y50OMZYXB0ZQdG8ZCrydBQjXMMLdp)ZWLndlhTRa7YTC)Nsrk6gz4S5eKg396eqdiaHga0f0OdA(pLIu0nYWzZjipnOrh0i0qgtgEdadbbaZPLZK(c0(rrOjtGqt2qJoOjbOjhOjCgEb53Oh8KJskQB1oGr4e88pdxqdyWqdDg2A0FKFJEWtokPOUv7agHtAC3RtanzcnBZfAs0Y50OMZYbG50YzsFbA)OOnSPM020SC45FgUSzy5ODfyxUL7)uksr3idNnNG04UxNaAabi0aGUGgDqZ)PuKIUrgoBob5Pbn6GMeGMCGMWz4fKFJEWtokPOUv7agHtWZ)mCbnGbdn0zyRr)r(n6bp5OKI6wTdyeoPXDVob0Kj0SnxOjrlNtJAolNQhrifrx8H2WMAU20SC45FgUSzy5CAuZz5OoJjDAuZjzLiSCSseYZ3rlhke4rrHnSPcQTPz5WZ)mCzZWY50OMZYrDgt60OMtYkry5yLiKNVJwo6mS1O)e2WMkOInnlhE(NHlBgwoAxb2LB5(pLI8B0dEYrjf1TAhWiCYtZY50OMZY1Vt60OMtYkry5yLiKNVJwU)iKrr5Roa2WMkO0MMLdp)ZWLndlhTRa7YTCHZWli)g9GNCusrDR2bmcNGN)z4cA0bnjanjan0zyRr)r(n6bp5OKI6wTdyeoPXDVob0aeAYhA0bn0zyRr)r0kgZB5OKQEebPXDVob0ac0SnFOjrObmyOjbOHodBn6pYVrp4jhLuu3QDaJWjnU71jGgqGMSZhA0bnrTJYyKRcHgqGMKKl0Ki0KOLZPrnNLRFN0PrnNKvIWYXkripFhTC)ri1MHvhaBytnPytZYHN)z4YMHLJ2vGD5wU)tPiAfJ5TCusvpIG80GgDqt4m8cY8zvGTh1Ce88pdxwoNg1CwU(DsNg1CswjclhReH88D0YnFwfy7rnNnSPUnFBAwo88pdx2mSC0UcSl3Y50OankXd3luanzceAY2Y50OMZY1Vt60OMtYkry5yLiKNVJwoFqBytD7wBAwo88pdx2mSConQ5SCuNXKonQ5KSsewowjc557OLte(T8EzdBy58bTPztDRnnlhE(NHlBgwoAxb2LB5cNHxqa4bpSRdGuetVtWZ)mCbnGbdnjanEwyxbsu9KfEYa31qrqA)4dA0bncnKXKH3aWqqACFAbYqHqQVUaBOjtGqtsGgDqtoqZ)PuKU2rYtdAs0Y50OMZY14(0cKHcHuFDb22WMA220SC45FgUSzy5ODfyxULlCgEbr1Jie0nbpKGN)z4YY50OMZYbG50YzsFbA)OOnSPMeBAwo88pdx2mSConQ5SCQEeHueDXhA5ODfyxULlbOzH)NsrApRPlkseHt5dAabAYfAadgAw4)PuK2ZA6IIKg396eqdiqZ28HMeHgDqdDg2A0FKg3NwGmuiK6RlWM04UxNaAabi0Kn0KNqda6cA0bnHZWlia8Gh21bqkIP3j45FgUGgDqtoqt4m8cIQhriOBcEibp)ZWLLJUHYqz4name2u3AdBQjTnnlhE(NHlBgwoAxb2LB5OZWwJ(J04(0cKHcHuFDb2Kg396eqdiaHMSHM8eAaqxqJoOjCgEbbGh8WUoasrm9obp)ZWLLZPrnNLt1JiKIOl(qBytnxBAwo88pdx2mSC0UcSl3Y9FkfPRDK80SConQ5SC8g9S6ai)mxe2WMkO2MMLdp)ZWLndlhTRa7YTC)Nsr4RyS6ai3DkV6qYtZY50OMZYP6rec6MGhAdBQGk20SC45FgUSzy5ODfyxULRFxrLAJESjluv0kGgqGMeGMT5cnjdnHZWli97kQ0JaVNh1Ce88pdxqtEcnjbAs0Y50OMZYbG50YzsFbA)OOnSPckTPz5WZ)mCzZWY50OMZYP6resr0fFOLJ2vGD5wUeGMf(FkfP9SMUOireoLpObeOjxObmyOzH)NsrApRPlksAC3RtanGanBZhAseA0bn97kQuB0JnzHQIwb0ac0Ka0SnxOjzOjCgEbPFxrLEe498OMJGN)z4cAYtOjjqtIqJoOjhOjCgEbr1Jie0nbpKGN)z4YYr3qzOm8gagcBQBTHn1KInnlhE(NHlBgwoAxb2LB563vuP2OhBYcvfTcObeOjbOzBUqtYqt4m8cs)UIk9iW75rnhbp)ZWf0KNqtsGMeHgDqtoqt4m8cIQhriOBcEibp)ZWLLZPrnNLt1JiKIOl(qBytDB(20SConQ5SCnUpTazOqi1xxGTLdp)ZWLndBytD7wBAwoNg1CwovpIqq3e8qlhE(NHlBg2WM62STPz5WZ)mCzZWY50OMZYnFwfy7bA5ODfyxULlbOzH)NsrApRPlkseHt5dAabAYfAadgAw4)PuK2ZA6IIKg396eqdiqZ28HMeHgDqt)UIk1g9ytwOQOvanzcnjanzNl0Km0eodVG0VROspc8EEuZrWZ)mCbn5j0KeOjrOrh0Kd0eodVGO6rec6MGhsWZ)mCz5OBOmugEdadHn1T2WM62KytZYHN)z4YMHLJ2vGD5wU(DfvQn6XMSqvrRaAYeAsaAYoxOjzOjCgEbPFxrLEe498OMJGN)z4cAYtOjjqtIwoNg1CwU5ZQaBpqBytDBsBtZY50OMZYbG50YzsFbA)OOLdp)ZWLndBytDBU20SC45FgUSzy5CAuZz5u9icPi6Ip0Yr7kWUClxcqZc)pLI0EwtxuKicNYh0ac0Kl0agm0SW)tPiTN10ffjnU71jGgqGMT5dnjcn6GMCGMWz4fevpIqq3e8qcE(NHllhDdLHYWBayiSPU1g2u3cQTPz5CAuZz5u9icPi6Ip0YHN)z4YMHnSPUfuXMMLZPrnNLJ30NCus91fyB5WZ)mCzZWg2u3ckTPz5CAuZz58M6hkJPB8clhE(NHlBg2Wg2WYbASf1C2uZo)SZp)CtYwlNEVV6aiSCjv31MoWf0SnFOXPrnh0Wkriiq(TCcnKAtn7C3A506rvm0YbkGM8wpIaAY7GEWdAYRFfaEbKFqb0WlcnrEF6PdOcEVpHo7PlQ9hZJAoA7QiDrTtthYpOaA4)Di0SnPKc0KD(zNpKFi)GcOjVGNFaqrEpKFqb0aQcnjvpk7TqOjVS6wqtERrmlKa5huanGQqts91cAuoJ9DkFqJAAO5jQda0KujVBETuGM8stEdAkf0OX8nydn1vr5bkGMmgoO5JQPrOrBgwDaGg2aOOqtjGg6SRXWaxei)GcObufAYl45haeAcVbGbjQDugJCvi0ed0e1okJrUkeAIbAEceAWJoVlWgAy4bi4bnTh8WgAcE(bnAtGxuodAI2f8GMf6bpbbYpOaAavHM8IHTGMKArVdOXVf00oTCg0e6rNpbbYpKFqb0KujPgK(cCbnFunncn0z)7b08ra1jiqtsDkf1cb0CZbQYZ7D1JbnonQ5eqZCSnei)onQ5eeTgPZ(3JKbMU2e1Cq(DAuZjiAnsN9Vhjdm9NaLvG7PC(oc0ZsWZBxivZfYrj1g9yd53PrnNGO1iD2)EKmW0bT3L)zykNVJaNGh2Y5KpbkX84vAA4kfq7ShcmbmpELMgUi3etxZtibW8v5X0c53xaqWGX84vAA4IqNUFAbUKay(Q8yAH87laiyWyE8knnCrOt3pTaxsamFvEmTqUJlNXQ5adgZJxPPHlcOlNjhL0VA3dCj)SzwGbJ5XR00WfrvTiK7EGcPqBdaMleGbJ5XR00WfjVcfsEJEg2GbJ5XR00Wf5My6AEcjaMVkpMwi3XLZy1CGbJ5XR00WfXf8aTFOq2EwtlPt7SeH8d5huanjvsQbPVaxqdcAS3anrTJqtWdHgNgtdnLaACq7fZ)mKa53PrnNa4EDlPQrmleYpOaAsQRPX2an5TEeb0K3qqJn043cA296cVoOjPkDd0KMZMta53PrnNizGPZB0ZQdG8ZCrKsPaMZAcIQhriviOXMefLV6aOlHCcNHxq(n6bp5OKI6wTdyeobp)ZWfyW0zyRr)r(n6bp5OKI6wTdyeoPXDVorMBZnri)onQ5ejdmDamNwot6lq7hftPua)pLIu0nYWzZjinU71jabia6s3)PuKIUrgoBob5PPtOHmMm8gagccaMtlNj9fO9JIzcmBDjKt4m8cYVrp4jhLuu3QDaJWj45FgUadModBn6pYVrp4jhLuu3QDaJWjnU71jYCBUjc53PrnNizGPR6resr0fFykLc4)PuKIUrgoBobPXDVobiabqx6(pLIu0nYWzZjipnDjKt4m8cYVrp4jhLuu3QDaJWj45FgUadModBn6pYVrp4jhLuu3QDaJWjnU71jYCBUjc53PrnNizGPtDgt60OMtYkrKY57iquiWJIci)onQ5ejdmDQZysNg1CswjIuoFhbsNHTg9NaYVtJAorYatVFN0PrnNKvIiLZ3rG)riJIYxDasPua)pLI8B0dEYrjf1TAhWiCYtdYVtJAorYatVFN0PrnNKvIiLZ3rG)ri1MHvhGukfWWz4fKFJEWtokPOUv7agHtWZ)mCPlHeOZWwJ(J8B0dEYrjf1TAhWiCsJ7EDcG5RJodBn6pIwXyElhLu1JiinU71jazB(jcgCc0zyRr)r(n6bp5OKI6wTdyeoPXDVobizNVUO2rzmYvHGKKCtmri)onQ5ejdm9(DsNg1CswjIuoFhboFwfy7rnxkLc4)PueTIX8wokPQhrqEA6cNHxqMpRcS9OMJGN)z4cYVtJAorYatVFN0PrnNKvIiLZ3rG(GPukGonkqJs8W9cfzcmBi)onQ5ejdmDQZysNg1CswjIuoFhbkc)wEVG8d53PrnNG4dcSX9PfidfcP(6cStPuadNHxqa4bpSRdGuetVtWZ)mCbgCcEwyxbsu9KfEYa31qrqA)4tNqdzmz4nameKg3NwGmuiK6RlWotGjrxo)Nsr6AhjpTeH870OMtq8btgy6ayoTCM0xG2pkMsPagodVGO6rec6MGhsWZ)mCb53PrnNG4dMmW0v9icPi6Ipmf6gkdLH3aWqaCBkLcycl8)uks7znDrrIiCkFGKlyWl8)uks7znDrrsJ7EDcq2MFI6OZWwJ(J04(0cKHcHuFDb2Kg396eGam78eaDPlCgEbbGh8WUoasrm9obp)ZWLUCcNHxqu9icbDtWdj45FgUG870OMtq8btgy6QEeHueDXhMsPasNHTg9hPX9PfidfcP(6cSjnU71jaby25ja6sx4m8ccap4HDDaKIy6DcE(NHli)onQ5eeFWKbMoVrpRoaYpZfrkLc4)PuKU2rYtdYVtJAobXhmzGPR6rec6MGhMsPa(FkfHVIXQdGC3P8Qdjpni)onQ5eeFWKbMoaMtlNj9fO9JIPukG97kQuB0JnzHQIwbijSn3KdNHxq63vuPhbEppQ5i45FgUYZKKiKFNg1CcIpyYatx1JiKIOl(WuOBOmugEdadbWTPukGjSW)tPiTN10ffjIWP8bsUGbVW)tPiTN10ffjnU71jazB(jQRFxrLAJESjluv0kajHT5MC4m8cs)UIk9iW75rnhbp)ZWvEMKe1Lt4m8cIQhriOBcEibp)ZWfKFNg1CcIpyYatx1JiKIOl(WukfW(DfvQn6XMSqvrRaKe2MBYHZWli97kQ0JaVNh1Ce88pdx5zssuxoHZWliQEeHGUj4He88pdxq(DAuZji(Gjdm9g3NwGmuiK6RlWgYVtJAobXhmzGPR6rec6MGhc53PrnNG4dMmW0NpRcS9atHUHYqz4namea3MsPaMWc)pLI0EwtxuKicNYhi5cg8c)pLI0EwtxuK04UxNaKT5NOU(DfvQn6XMSqvrRiZeYo3KdNHxq63vuPhbEppQ5i45FgUYZKKOUCcNHxqu9icbDtWdj45FgUG870OMtq8btgy6ZNvb2EGPukG97kQuB0JnzHQIwrMjKDUjhodVG0VROspc8EEuZrWZ)mCLNjjri)onQ5eeFWKbMoaMtlNj9fO9JIq(DAuZji(GjdmDvpIqkIU4dtHUHYqz4namea3MsPaMWc)pLI0EwtxuKicNYhi5cg8c)pLI0EwtxuK04UxNaKT5NOUCcNHxqu9icbDtWdj45FgUG870OMtq8btgy6QEeHueDXhc53PrnNG4dMmW05n9jhLuFDb2q(DAuZji(GjdmDVP(HYy6gVaYpKFqb0KrJEWdAgf0Wv3QDaJWHgTzy1baA6j8OMdAY7Hgr4DiGMSZxanFunncn5LkgZBOzuqtERhranjdnzmCqJ3i04G2lM)ziKFNg1CcYFesTzy1baiVrpRoaYpZfrkLc4)PuKU2rYtdYVtJAob5pcP2mS6aKmW0NpRcS9atHUHYqz4namea3MsPaMWc)pLI0EwtxuKicNYhi5cg8c)pLI0EwtxuK04UxNaKT5NOU(DfvQn6XMSqvrRitGzNRUCcNHxqu9icbDtWdj45FgUG870OMtq(JqQndRoajdm95ZQaBpWukfW(DfvQn6XMSqvrRitGzNlKFNg1CcYFesTzy1bizGPdG50YzsFbA)OykLcy)UIk1g9ytwOQOvas25RtOHmMm8gagccaMtlNj9fO9JIzcmBD0zyRr)r0kgZB5OKQEebPXDVorM5c53PrnNG8hHuBgwDasgy6QEeHueDXhMcDdLHYWBayiaUnLsbmHf(FkfP9SMUOireoLpqYfm4f(FkfP9SMUOiPXDVobiBZprD97kQuB0JnzHQIwbizNVUCcNHxqu9icbDtWdj45FgU0rNHTg9hrRymVLJsQ6reKg396ezMlKFNg1CcYFesTzy1bizGPR6resr0fFykLcy)UIk1g9ytwOQOvas25RJodBn6pIwXyElhLu1JiinU71jYmxi)onQ5eK)iKAZWQdqYatx1Jie0nbpmLsb8)ukcFfJvha5Ut5vhsEA663vuP2OhBYcvfTImtyBUjhodVG0VROspc8EEuZrWZ)mCLNjjrDcnKXKH3aWqqu9icbDtWdZey2q(DAuZji)ri1MHvhGKbMUQhriOBcEykLcy)UIk1g9ytwOQOvKjWessUjhodVG0VROspc8EEuZrWZ)mCLNjjrDcnKXKH3aWqqu9icbDtWdZey2q(DAuZji)ri1MHvhGKbM(8zvGThyk0nugkdVbGHa42ukfWew4)PuK2ZA6IIer4u(ajxWGx4)PuK2ZA6IIKg396eGSn)e11VROsTrp2KfQkAfzcmHKKBYHZWli97kQ0JaVNh1Ce88pdx5zssuxoHZWliQEeHGUj4He88pdxq(DAuZji)ri1MHvhGKbM(8zvGThykLcy)UIk1g9ytwOQOvKjWessUjhodVG0VROspc8EEuZrWZ)mCLNjjri)onQ5eK)iKAZWQdqYathaZPLZK(c0(rXukfq6mS1O)iAfJ5TCusvpIG04UxNiZ(DijQDugJmP11VROsTrp2KfQkAfGK05RtOHmMm8gagccaMtlNj9fO9JIzcmBi)onQ5eK)iKAZWQdqYatx1JiKIOl(WuOBOmugEdadbWTPukGjSW)tPiTN10ffjIWP8bsUGbVW)tPiTN10ffjnU71jazB(jQJodBn6pIwXyElhLu1JiinU71jYSFhsIAhLXitAD97kQuB0JnzHQIwbijD(6YjCgEbr1Jie0nbpKGN)z4cYVtJAob5pcP2mS6aKmW0v9icPi6IpmLsbKodBn6pIwXyElhLu1JiinU71jYSFhsIAhLXitAD97kQuB0JnzHQIwbijD(q(H8dkGM8MZyFNYh0ed08ei0KxAYBPanjvY7MxdA0ZdpO5jWguTUkkpqb0KXWbnAnU7XRr2gcKFNg1CcYFeYOO8vhaGAfJ5TCusvpIiLsbKodBn6pcURn6Xw2VdL6rxBosJ7EDci)onQ5eK)iKrr5RoajdmDCxB0JTSFhk1JU2Cq(DAuZji)riJIYxDasgy6ZNvb2EGPq3qzOm8gagcGBtPuatyH)NsrApRPlkseHt5dKCbdEH)NsrApRPlksAC3RtaY28tux)UIk1g9ydcWKKTUCcNHxqu9icbDtWdj45FgUG870OMtq(JqgfLV6aKmW0NpRcS9atPua73vuP2OhBqaMKSH870OMtq(JqgfLV6aKmW0BCFAbYqHqQVUa7ukfWWz4feaEWd76aifX07e88pdxq(DAuZji)riJIYxDasgy68g9S6ai)mxePukG)Nsr6Ahjpni)onQ5eK)iKrr5Roajdm95ZQaBpWuOBOmugEdadbWTPukGjSW)tPiTN10ffjIWP8bsUGbVW)tPiTN10ffjnU71jazB(jQRFhsIAhLXiZfea0fyW97kQuB0Jniat6C1Lt4m8cIQhriOBcEibp)ZWfKFNg1CcYFeYOO8vhGKbM(8zvGThykLcy)oKe1okJrMliaOlWG73vuP2OhBqaM05c53PrnNG8hHmkkF1bizGPR6rec6MGhMsPa(FkfHVIXQdGC3P8QdjpnDcnKXKH3aWqqu9icbDtWdZey2q(DAuZji)riJIYxDasgy68M(KJsQVUa7ukfW(DfvQn6XMSqvrRitGjjBD97qsu7OmgzsYeaDb53PrnNG8hHmkkF1bizGP34(0cKHcHuFDb2q(DAuZji)riJIYxDasgy6QEeHGUj4HPukGcnKXKH3aWqqu9icbDtWdZey2q(DAuZji)riJIYxDasgy6ZNvb2EGPq3qzOm8gagcGBtPuatyH)NsrApRPlkseHt5dKCbdEH)NsrApRPlksAC3RtaY28tux)UIk1g9ytwOQOvKz25cgC)omZKOlNWz4fevpIqq3e8qcE(NHli)onQ5eK)iKrr5Roajdm95ZQaBpWukfW(DfvQn6XMSqvrRiZSZfm4(DyMjbYVtJAob5pczuu(QdqYat3BQFOmMUXlsPua73vuP2OhBYcvfTImZnFi)q(bfqtEXWwqdp07aAOZTQOMta53PrnNGqh2sYd9oas551jKJswumLsb8)ukcDyljp07GicNYxM5QlQDugJCviiaOli)onQ5ee6WwsEO3rYatNYZRtihLSOykLcyc)Nsreig8QdGSDaiPXDVobiaORe19FkfrGyWRoaY2bGKNgKFNg1CccDyljp07izGPt551jKJswumLsbmH)tPiAfJ5TCusvpIG04UxNaeGaOR8mHTjtNHTg9hr1Ji0VP3fs1R3qA0xBsem4)tPiAfJ5TCusvpIG04UxNaK(DijQDugJmjjQ7)ukIwXyElhLu1JiipnDj4zHDfiPOBK0k8fYiTF8bcWTGb)Fkf53Oh8KJskQB1oGr4KNwI6YjCgEbPOi11i45FgUG870OMtqOdBj5HEhjdmDkpVoHCuYIIPukG)Nsr0kgZB5OKQEebPXDVobiGsD)NsrEhVHTrkIgpabpsJ7EDcqaqx5zcBtModBn6pIQhrOFtVlKQxVH0OV2KOU)tPiVJ3W2ifrJhGGhPXDVoHU)tPiAfJ5TCusvpIG800LGNf2vGKIUrsRWxiJ0(Xhia3cg8)PuKFJEWtokPOUv7agHtEAjQlNWz4fKIIuxJGN)z4cYVtJAobHoSLKh6DKmW0P886eYrjlkMsPaMW)PuKIUrsRWxiJ04UxNaKKgm4)tPifDJKwHVqgPXDVobi97qsu7Omgzssu3)PuKIUrsRWxiJ8005zHDfiPOBK0k8fYiTF8LjWS1LZ)PuKFJEWtokPOUv7agHtEA6YjCgEbPOi11i45FgUG870OMtqOdBj5HEhjdmDkpVoHCuYIIPukG)Nsrk6gjTcFHmYtt3)PuK3XByBKIOXdqWJ8005zHDfiPOBK0k8fYiTF8LjWS1LZ)PuKFJEWtokPOUv7agHtEA6YjCgEbPOi11i45FgUG870OMtqOdBj5HEhjdmDkpVoHCuYIIPukG)Nsr0kgZB5OKQEebPXDVobijTU)tPiAfJ5TCusvpIG800fodVGuuK6Ae88pdx6(pLIqh2sYd9oiIWP8LjWTGsDEwyxbsk6gjTcFHms7hFGaClKFNg1CccDyljp07izGPt551jKJswumLsb8)ukIwXyElhLu1JiipnDHZWliffPUgbp)ZWLoplSRajfDJKwHVqgP9JVmbMTUe(pLIqh2sYd9oiIWP8LjWTjfD)Nsrk6gjTcFHmsJ7EDcqaqx6(pLIu0nsAf(czKNgyW)NsrEhVHTrkIgpabpYtt3)Pue6WwsEO3breoLVmbUfuMiKFi)onQ5ee6mS1O)eaFcuwbUNY57iqplbpVDHunxihLuB0JDkLcyc0zyRr)rWDTrp2Y(DOup6AZrA0xB0LdO9U8pdjtWdB5CYNaLyE8knnCLiyWjqNHTg9hrRymVLJsQ6reKg396eGaCB(6aT3L)zizcEylNt(eOeZJxPPHReH870OMtqOZWwJ(tKmW0FcuwbUNY57iq2R5dBHSorTQ5jKakvKsPagodVG8B0dEYrjf1TAhWiCcE(NHlDjKaDg2A0FeTIX8wokPQhrqAC3RtacWT5Rd0Ex(NHKj4HTCo5tGsmpELMgUsem4e(pLIOvmM3Yrjv9icYttxoG27Y)mKmbpSLZjFcuI5XR00WvIjcgCc)Nsr0kgZB5OKQEeb5PPlNWz4fKFJEWtokPOUv7agHtWZ)mCLiKFNg1CccDg2A0FIKbM(tGYkW9uoFhbs3qzt0Zvu5N5IiLsbmN)tPiAfJ5TCusvpIG80G870OMtqOZWwJ(tKmW0FcuwbUlsPuatGodBn6pIwXyElhLu1Jiin6RnGbtNHTg9hrRymVLJsQ6reKg396ezMD(jQlHCcNHxq(n6bp5OKI6wTdyeobp)ZWfyW0zyRr)rWDTrp2Y(DOup6AZrAC3RtKzsj3eH870OMtqOZWwJ(tKmW0FcuwbUNY57iqxWd0(Hcz7znTKoTZsPuax4)PuK2ZAAjDANjx4)PuK1O)G870OMtqOZWwJ(tKmW0FcuwbUNY57iqxWd0(Hcz7znTKoTZsPuaPZWwJ(JG7AJESL97qPE01MJ04UxNiZKs(6w4)PuK2ZAAjDANjx4)PuKNMoq7D5FgsMGh2Y5KpbkX84vAA4cm4)tPi)g9GNCusrDR2bmcN800TW)tPiTN10s60otUW)tPipnD5aAVl)ZqYe8WwoN8jqjMhVstdxGb)Fkfb31g9yl73Hs9ORnh5PPBH)NsrApRPL0PDMCH)NsrEA6YjCgEb53Oh8KJskQB1oGr4e88pdxGbh1okJrUkeKS3c53PrnNGqNHTg9NizGP)eOScCpLZ3rG5vOqYB0ZWoLsbmbmpELMgUiSxZh2czDIAvZtibuQq3)PueTIX8wokPQhrqAC3RtKiyWjKdMhVstdxe2R5dBHSorTQ5jKakvO7)ukIwXyElhLu1JiinU71jazB26(pLIOvmM3Yrjv9icYtlri)onQ5ee6mS1O)ejdm9NaLvG7PC(ocKVBc5OK(rl8cP61BsPuaPZWwJ(JG7AJESL97qPE01MJ04UxNiZKoFi)onQ5ee6mS1O)ejdm9NaLvG7PC(oceqphaHuRRDNjBhaMsPa2Vdbbys0LZ)PueTIX8wokPQhrqEA6siN)tPi)g9GNCusrDR2bmcN80adoNWz4fKFJEWtokPOUv7agHtWZ)mCLiKFNg1CccDg2A0FIKbM(tGYkW9uoFhb2EwR3XNq(laYgxY)lI5G870OMtqOZWwJ(tKmW0FcuwbUNY57iWDSr(cEUqQ8dqkLcyo)Nsr(n6bp5OKI6wTdyeo5PPlN)tPiAfJ5TCusvpIG80G870OMtqOZWwJ(tKmW01MOMlLsb8)ukIwXyElhLu1JiipnD)NsrWDTrp2Y(DOup6AZrEAq(DAuZji0zyRr)jsgy6F2mlP61BsPua)pLIOvmM3Yrjv9icYtt3)PueCxB0JTSFhk1JU2CKNgKFNg1CccDg2A0FIKbM(hBb28vhGukfW)tPiAfJ5TCusvpIG80G870OMtqOZWwJ(tKmW09M6hk1EmbMsPaMqo)Nsr0kgZB5OKQEeb5PPZPrbAuIhUxOitGzNiyW58FkfrRymVLJsQ6reKNMUe63HKfQkAfzcmxD97kQuB0JnzHQIwrMab15NiKFNg1CccDg2A0FIKbMoRaWleY8Q3cWoErkLc4)PueTIX8wokPQhrqEAq(DAuZji0zyRr)jsgy6(rrr0otsDglLsb8)ukIwXyElhLu1JiipnD)NsrWDTrp2Y(DOup6AZrEAq(DAuZji0zyRr)jsgy6QQXpBMvkLc4)PueTIX8wokPQhrqAC3RtacqqPU)tPi4U2OhBz)ouQhDT5ipni)onQ5ee6mS1O)ejdm9Vdqokz0fLprkLc4)PueTIX8wokPQhrqEA6s4)ukIwXyElhLu1JiinU71jajxDHZWli0HTK8qVdcE(NHlWGZjCgEbHoSLKh6DqWZ)mCP7)ukIwXyElhLu1JiinU71jajjjQZPrbAuIhUxOa4wWG)pLIiqm4vhaz7aqYttNtJc0OepCVqbWTq(H8dkGM8wpIaAOZWwJ(ta53PrnNGqNHTg9NizGPRvmM3Yrjv9iIukfWeOZWwJ(JG7AJESL97qPE01MJ04UxNam4Wz4fKIIuxJGN)z4krD58FkfrRymVLJsQ6reKNgyWHZWliffPUgbp)ZWLoplSRajQEeHEEittiRBvaopQ5i45FgU09FkfrRymVLJsQ6reKg396eGKnKFNg1CccDg2A0FIKbM(Vrp4jhLuu3QDaJWt5jq5Ousa0fWTPukG0zyRr)rWDTrp2Y(DOup6AZrAC3RtOJodBn6pIwXyElhLu1JiinU71jG870OMtqOZWwJ(tKmW0XDTrp2Y(DOup6AZLsPasNHTg9hrRymVLJsQ6reKg91gDHZWliZNvb2EuZrWZ)mCPRFhsIAhLXiZnta0LU(DfvQn6XMSqvrRitGBZhm4O2rzmYvHGKD(q(DAuZji0zyRr)jsgy64U2OhBz)ouQhDT5sPuatGodBn6pIwXyElhLu1Jiin6RnGbh1okJrUkeKSZprDHZWli)g9GNCusrDR2bmcNGN)z4sx)UIk1g9yNjOoFi)onQ5ee6mS1O)ejdmDCxB0JTSFhk1JU2CPukGHZWliffPUgbp)ZWLU(DiijbYVtJAobHodBn6prYatN6mM0PrnNKvIiLZ3rG0HTK8qVJukfWWz4fe6WwsEO3bbp)ZWLUes4)ukcDyljp07GicNYxMa3MVUf(FkfP9SMUOireoLpG5MiyWrTJYyKRcbbia6kri)onQ5ee6mS1O)ejdmDvpIq)MExivVEtkLcyc)Nsr0kgZB5OKQEeb5PPZZc7kqsr3iPv4lKrA)4deGB1LW)PueTIX8wokPQhrqAC3Rtacqa0fyW)NsrEhVHTrkIgpabpsJ7EDcqacGU09Fkf5D8g2gPiA8ae8ipTeteYVtJAobHodBn6prYatx1Ji0VP3fs1R3KsPaMW)PuKIUrsRWxiJ800Lt4m8csrrQRrWZ)mCPlH)tPiVJ3W2ifrJhGGh5Pbg8)PuKIUrsRWxiJ04UxNaeGaORetem4)tPifDJKwHVqg5PP7)uksr3iPv4lKrAC3Rtacqa0LUWz4fKIIuxJGN)z4s3)PueTIX8wokPQhrqEAq(DAuZji0zyRr)jsgy6QEeH(n9UqQE9MukfWO2rzmYvHGaGUadoHO2rzmYvHGqNHTg9hrRymVLJsQ6reKg396e6(pLI8oEdBJuenEacEKNwIq(H870OMtqqHapkka(zZSKJsg8qjE4(MukfW)tPiAfJ5TCusvpIG800LW)PueTIX8wokPQhrqAC3RtaY281LW)PuKFJEWtokPOUv7agHtEAGbhodVGmFwfy7rnhbp)ZWfyWHZWliffPUgbp)ZWLUC8SWUcKu0nsAf(cze88pdxjcg8)PuKIUrsRWxiJ800fodVGuuK6Ae88pdxjQlbNgfOrjE4EHcGBbdoNWz4fKIIuxJGN)z4krWGDAuGgL4H7fkYey26cNHxqkksDncE(NHlD0zyRr)r0kgZB5OKQEebPrFTrxcEwyxbsk6gjTcFHms7hFzcCRU)tPifDJKwHVqg5PbgCoEwyxbsk6gjTcFHmcE(NHReH870OMtqqHapkksgy6aEEVk)KJs6zH9e8sPuaZjCgEbPOi11i45FgUadoCgEbPOi11i45FgU05zHDfiPOBK0k8fYi45FgU09FkfrRymVLJsQ6reKg396eGaQ19FkfrRymVLJsQ6reKNgyWHZWliffPUgbp)ZWLUC8SWUcKu0nsAf(cze88pdxq(DAuZjiOqGhffjdmDkVIXKIOrNVukfW)tPiAfJ5TCusvpIG04UxNaKC19FkfrRymVLJsQ6reKNgyWrTJYyKRcbjxi)onQ5eeuiWJIIKbMEWdLV7pVBjvttXukfW)tPins5JHcHunnfjpnWG)pLI0iLpgkes10uusN3fyteHt5dKTBH870OMtqqHapkksgy6QH(e4s6zHDfO8J(EkLcyo)Nsr0kgZB5OKQEeb5PPlN)tPi)g9GNCusrDR2bmcN80G870OMtqqHapkksgy605O4fTh4sQy(oMsPaMZ)PueTIX8wokPQhrqEA6Y5)ukYVrp4jhLuu3QDaJWjpnDRji05O4fTh4sQy(ok)V(inU71jaMpKFNg1Cccke4rrrYatx)0SfOX6KnkMZpkMsPa(FkfrRymVLJsQ6reKNgyW)NsrWDTrp2Y(DOup6AZrEAGbtNHTg9h53Oh8KJskQB1oGr4Kg396ezcQZp5T5cgmD6(Pf1CcsDOs5FgkJ(f8i45FgUG870OMtqqHapkksgy6DPPXqzDsHMtXukfWC(pLIOvmM3Yrjv9icYttxo)Nsr(n6bp5OKI6wTdyeo5Pb53PrnNGGcbEuuKmW03X9P3ihLK9O1sUA03fPukG)NsrWDTrp2Y(DOup6AZrAC3RtasU6(pLI8B0dEYrjf1TAhWiCYtdm4e63HKO2rzmYSZeaDPRFxrLAJESbj38teYVtJAobbfc8OOizGP3ORvhaPI57OaYpKFqb0Kx(Nvb2EuZbn9eEuZb53PrnNGmFwfy7rnhWg3NwGmuiK6RlWoLsbmCgEbbGh8WUoasrm9obp)ZWfKFNg1CcY8zvGTh1Cjdm95ZQaBpWuOBOmugEdadbWTPukGjSW)tPiTN10ffjIWP8bsUGbVW)tPiTN10ffjnU71jazB(jQlNWz4fevpIqq3e8qcE(NHlD58FkfPRDK800j0qgtgEdadbH3ONvha5N5IitGjbYVtJAobz(SkW2JAUKbM(8zvGThykLcyoHZWliQEeHGUj4He88pdx6Y5)uksx7i5PPtOHmMm8gagccVrpRoaYpZfrMatcKFNg1CcY8zvGTh1CjdmDvpIqq3e8WukfWe(pLIWxXy1bqU7uE1HKgDAagCc)Nsr4RyS6ai3DkV6qYttxcAncAja6ISLO6resr0fFiyWAncAja6ISLWB0ZQdG8ZCragSwJGwcGUiBjayoTCM0xG2pkMyIjQtOHmMm8gagcIQhriOBcEyMaZgYVtJAobz(SkW2JAUKbM(8zvGThyk0nugkdVbGHa42ukfWew4)PuK2ZA6IIer4u(ajxWGx4)PuK2ZA6IIKg396eGSn)e19FkfHVIXQdGC3P8Qdjn60am4e(pLIWxXy1bqU7uE1HKNMUe0Ae0sa0fzlr1JiKIOl(qWG1Ae0sa0fzlH3ONvha5N5IamyTgbTeaDr2saWCA5mPVaTFumXeH870OMtqMpRcS9OMlzGPpFwfy7bMsPa(FkfHVIXQdGC3P8Qdjn60am4e(pLIWxXy1bqU7uE1HKNMUe0Ae0sa0fzlr1JiKIOl(qWG1Ae0sa0fzlH3ONvha5N5IamyTgbTeaDr2saWCA5mPVaTFumXeH870OMtqMpRcS9OMlzGPdG50YzsFbA)OykLcyc58FkfPRDK80adUFxrLAJESjluv0kazB(Gb3VdjrTJYyKzNja6krDcnKXKH3aWqqaWCA5mPVaTFumtGzd53PrnNGmFwfy7rnxYatN3ONvha5N5IiLsb8)uksx7i5PPtOHmMm8gagccVrpRoaYpZfrMaZgYVtJAobz(SkW2JAUKbMUQhrifrx8HPq3qzOm8gagcGBtPuatyH)NsrApRPlkseHt5dKCbdEH)NsrApRPlksAC3RtaY28tuxo)Nsr6AhjpnWG73vuP2OhBYcvfTcq2MpyW97qsu7Omgz2zcGU0Lt4m8cIQhriOBcEibp)ZWfKFNg1CcY8zvGTh1CjdmDvpIqkIU4dtPuaZ5)uksx7i5PbgC)UIk1g9ytwOQOvaY28bdUFhsIAhLXiZota0fKFNg1CcY8zvGTh1CjdmDEJEwDaKFMlIukfW)tPiDTJKNgKFNg1CcY8zvGTh1Cjdm95ZQaBpWuOBOmugEdadbWTPukGjSW)tPiTN10ffjIWP8bsUGbVW)tPiTN10ffjnU71jazB(jQlNWz4fevpIqq3e8qcE(NHli)onQ5eK5ZQaBpQ5sgy6ZNvb2EGq(H8dkGgUWVL3lOruhagcQgEdadOPNWJAoi)onQ5eer43Y7fWg3NwGmuiK6RlWgYVtJAobre(T8ELmW0v9icPi6IpmLsbKodBn6psJ7tlqgkes91fytAC3RtacWSZta0LUWz4feaEWd76aifX07e88pdxq(DAuZjiIWVL3RKbMoVrpRoaYpZfrkLc4)PuKU2rYtdYVtJAobre(T8ELmW0NpRcS9atPuadNHxqkksDncE(NHlD)Nsr0kgZB5OKQEeb5PPZZc7kqsr3iPv4lKrA)4ltGzd53PrnNGic)wEVsgy6ZNvb2EGPukG58Fkfr1tw4j1EmbsEA6cNHxqu9KfEsThtGe88pdxq(DAuZjiIWVL3RKbMUQhrifrx8HPukG97kQuB0JnzHQIwbijSn3KdNHxq63vuPhbEppQ5i45FgUYZKKiKFNg1CcIi8B59kzGPR6rec6MGhMsPa(FkfHVIXQdGC3P8QdjpnD97qsu7OmgzsNjqa0fKFNg1CcIi8B59kzGPpFwfy7bMsPa2VROsTrp2KfQkAfzMq25MC4m8cs)UIk9iW75rnhbp)ZWvEMKeH870OMtqeHFlVxjdmDvpIqkIU4dH870OMtqeHFlVxjdmDEtFYrj1xxGnKFNg1CcIi8B59kzGP7n1pugt34f2Wgwla]] )
    
end
