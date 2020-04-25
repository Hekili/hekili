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
            charges = function () return ( level < 116 and equipped.seal_of_necrofantasia ) and 2 or nil end,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
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

    
    spec:RegisterPack( "Frost DK", 20200425, [[dKuJqcqirvEeqcBIuzuIiNse1QevsVseAwIe3sei2fs)sKQHjQQJbqltuQNjcAAIaUMOKTbKuFdirghqsoNiqTorLQAEaX9a0(efDqGeLfkk8qrLctuuPkUOiqYgfvQmsrGuDsGevReL0lfvkv3uuPOStrs)uuPOAOIkfzPIkvPNIIPks5RIkLYEP4VenykDyQwSQ6XiMSsUm0Mj5ZQsJgOoTKvlQuYRrjMnQUTQy3Q8BfdNuoUOsSCPEoHPlCDLA7aP(oPQXlcKY5bW6fvmFuQ9dAdGM0mmlpqtQzNF25NFcKDw08bvjaOgWeWWeaOHggnNWI)IgMZFqdtURhraT5EYTBy0Ca4JVmPzyeZUjOHbCeAIC)0t)TcW7pLmpPlQNn3JAos7QiDr9qs3W83fpaLFMVHz5bAsn78Zo)8tGSZIMpOkbYkReSHX3b4Pnmm1tUHHbCTw4z(gMfkiggqb0M76reqBUh0dWqBU9REbhqwbfql4i0e5(PN(BfG3FkzEsxupBUh1CK2vr6I6HKoKvqb0cktRlo0MDwPaTzNF25dzfYkOaAZna73lkY9HSckG2eeOfu(r47fcT5Mv3cAZDnI5GuiRGcOnbbAbLTwqRY58VtybAvtdTBrDVqBcQCV52sbAZnn5oOTuqRg3baBOTUkkpqb0MXWaTFunncTAZWR7fA5ZBrG2saTK5rJJbUOqwbfqBcc0MBa2VxeAdVFXGg1dkJrUkeAJbAJ6bLXixfcTXaTBbcT4rM9fydTC8EdWqB7bySH2aSFqR2e4fLZH2ODbyODHEawqHSckG2eeOn3y4lOnbD07aA9BbTTtkNdTHE0zrqnm8sectAggYWxsWO3HjntQaAsZWGN)54YKHHH0vGD5gM)wPOKHVKGrVdQiCclqBMqBwqRoOnQhugJCvi0cc0(swggNe1CggcyVoHCuYIGMWKA2M0mm45FoUmzyyiDfyxUHjjO9VvkQaXaCDVY2FrAJpEDcOfeO9LSG2KHwDq7FRuubIb46ELT)I0TMHXjrnNHHa2RtihLSiOjmPMqtAgg88phxMmmmKUcSl3WKe0(3kfvR4CVLJsQ6re0gF86eqliaH2xYcAZvOnjOfqOnrOLmdFn6pQQhrOhG(riv7gaAJ(caOnzOLnBO9VvkQwX5ElhLu1JiOn(41jGwqG2EFinQhugJmHqBYqRoO9VvkQwX5ElhLu1JiOBnOvh0Me065GDfiTiaijv4lKtB)ybAbbi0ci0YMn0(3kf93OhGLJskQB1(7iC6wdAtgA1bT5bTHZXlOfbjUgfp)ZXLHXjrnNHHa2RtihLSiOjmPMaM0mm45FoUmzyyiDfyxUH5VvkQwX5ElhLu1JiOn(41jGwqGwqf0QdA)BLIUpWdhaPiA8EdW0gF86eqliq7lzbT5k0Me0ci0Mi0sMHVg9hv1Ji0dq)iKQDdaTrFba0Mm0QdA)BLIUpWdhaPiA8EdW0gF86eqRoO9VvkQwX5ElhLu1JiOBnOvh0Me065GDfiTiaijv4lKtB)ybAbbi0ci0YMn0(3kf93OhGLJskQB1(7iC6wdAtgA1bT5bTHZXlOfbjUgfp)ZXLHXjrnNHHa2RtihLSiOjmPMLjnddE(NJltgggsxb2LByscA)BLIweaKKk8fYPn(41jGwqG2eaAzZgA)BLIweaKKk8fYPn(41jGwqG2EFinQhugJmHqBYqRoO9VvkAraqsQWxiNU1GwDqRNd2vG0IaGKuHVqoT9JfOntGqB2qRoOnpO9Vvk6VrpalhLuu3Q93r40Tg0QdAZdAdNJxqlcsCnkE(NJldJtIAoddbSxNqokzrqtysfuBsZWGN)54YKHHH0vGD5gM)wPOfbajPcFHC6wdA1bT)Tsr3h4HdGuenEVby6wdA1bTEoyxbslcassf(c502pwG2mbcTzdT6G28G2)wPO)g9aSCusrDR2FhHt3AqRoOnpOnCoEbTiiX1O45FoUmmojQ5mmeWEDc5OKfbnHjvqjtAgg88phxMmmmKUcSl3W83kfvR4CVLJsQ6re0gF86eqliqBcaT6G2)wPOAfN7TCusvpIGU1GwDqB4C8cArqIRrXZ)CCbT6G2)wPOKHVKGrVdQiCclqBMaHwabvqRoO1Zb7kqAraqsQWxiN2(Xc0ccqOfqdJtIAoddbSxNqokzrqtysfuzsZWGN)54YKHHH0vGD5gM)wPOAfN7TCusvpIGU1GwDqB4C8cArqIRrXZ)CCbT6GwphSRaPfbajPcFHCA7hlqBMaH2SHwDqBsq7FRuuYWxsWO3bveoHfOntGqlGjyOvh0(3kfTiaijv4lKtB8XRtaTGaTVKf0QdA)BLIweaKKk8fYPBnOLnBO9Vvk6(apCaKIOX7nat3AqRoO9Vvkkz4ljy07GkcNWc0MjqOfqqf0MSHXjrnNHHa2RtihLSiOjmHHz(8kW2JAotAMub0KMHbp)ZXLjdddPRa7YnmHZXlOVEag76ELIy6hkE(NJldJtIAodtJptlqokes91fyBctQzBsZWGN)54YKHHXjrnNHz(8kW2d0Wq6kWUCdtsq7c)BLI2EotxeKkcNWc0cc0Mf0YMn0UW)wPOTNZ0fbPn(41jGwqGwaZhAtgA1bT5bTHZXlOQEeHGaqagP45FoUGwDqBEq7FRu0UEq6wdA1bTcnKZLH3VyiOGh986ELFUlcOntGqBcnmeaiCugE)IHWKkGMWKAcnPzyWZ)CCzYWWq6kWUCdtEqB4C8cQQhriiaeGrkE(NJlOvh0Mh0(3kfTRhKU1GwDqRqd5Cz49lgck4rpVUx5N7IaAZei0MqdJtIAodZ85vGThOjmPMaM0mm45FoUmzyyiDfyxUHjjO9VvkklfNx3R8XjGRdPn6KaAzZgAtcA)BLIYsX519kFCc46q6wdA1bTjbTAncA5lzrbKQ6resr0fli0YMn0Q1iOLVKffqk4rpVUx5N7IaAzZgA1Ae0YxYIci9L7KY5sFbA)ii0Mm0Mm0Mm0QdAfAiNldVFXqqv9icbbGamcTzceAZ2W4KOMZWO6reccaby0eMuZYKMHbp)ZXLjddJtIAodZ85vGThOHH0vGD5gMKG2f(3kfT9CMUiiveoHfOfeOnlOLnBODH)TsrBpNPlcsB8XRtaTGaTaMp0Mm0QdA)BLIYsX519kFCc46qAJojGw2SH2KG2)wPOSuCEDVYhNaUoKU1GwDqBsqRwJGw(swuaPQEeHueDXccTSzdTAncA5lzrbKcE0ZR7v(5UiGw2SHwTgbT8LSOasF5oPCU0xG2pccTjdTjByiaq4Om8(fdHjvanHjvqTjnddE(NJltgggsxb2LBy(BLIYsX519kFCc46qAJojGw2SH2KG2)wPOSuCEDVYhNaUoKU1GwDqBsqRwJGw(swuaPQEeHueDXccTSzdTAncA5lzrbKcE0ZR7v(5UiGw2SHwTgbT8LSOasF5oPCU0xG2pccTjdTjByCsuZzyMpVcS9anHjvqjtAgg88phxMmmmKUcSl3WKe0Mh0(3kfTRhKU1Gw2SH2EFfrQn6XMUqvrQaAbbAbmFOLnBOT3hsJ6bLXiZgAZeAFjlOnzOvh0k0qoxgE)IHG(YDs5CPVaTFeeAZei0MTHXjrnNH5L7KY5sFbA)iOjmPcQmPzyWZ)CCzYWWq6kWUCdZFRu0UEq6wdA1bTcnKZLH3VyiOGh986ELFUlcOntGqB2ggNe1CggWJEEDVYp3fHjmPMGnPzyWZ)CCzYWW4KOMZWO6resr0flOHH0vGD5gMKG2f(3kfT9CMUiiveoHfOfeOnlOLnBODH)TsrBpNPlcsB8XRtaTGaTaMp0Mm0QdAZdA)BLI21ds3AqlB2qBVVIi1g9ytxOQivaTGaTaMp0YMn027dPr9GYyKzdTzcTVKf0QdAZdAdNJxqv9icbbGamsXZ)CCzyiaq4Om8(fdHjvanHjvaZ3KMHbp)ZXLjdddPRa7Ynm5bT)Tsr76bPBnOLnBOT3xrKAJESPluvKkGwqGwaZhAzZgA79H0OEqzmYSH2mH2xYYW4KOMZWO6resr0flOjmPciGM0mm45FoUmzyyiDfyxUH5VvkAxpiDRzyCsuZzyap6519k)CxeMWKkGzBsZWGN)54YKHHXjrnNHz(8kW2d0Wq6kWUCdtsq7c)BLI2EotxeKkcNWc0cc0Mf0YMn0UW)wPOTNZ0fbPn(41jGwqGwaZhAtgA1bT5bTHZXlOQEeHGaqagP45FoUmmeaiCugE)IHWKkGMWKkGj0KMHXjrnNHz(8kW2d0WGN)54YKHjmHH5pczuewQ71KMjvanPzyWZ)CCzYWWq6kWUCddzg(A0Fu8rB0JTS3hk1JU2C0gF86eggNe1CggTIZ9wokPQhryctQzBsZW4KOMZWGpAJESL9(qPE01MZWGN)54YKHjmPMqtAgg88phxMmmmojQ5mmZNxb2EGggsxb2LByscAx4FRu02Zz6IGur4ewGwqG2SGw2SH2f(3kfT9CMUiiTXhVob0cc0cy(qBYqRoOT3xrKAJESHwqacTjmBOvh0Mh0gohVGQ6reccabyKIN)54YWqaGWrz49lgctQaActQjGjnddE(NJltgggsxb2LBy69veP2OhBOfeGqBcZ2W4KOMZWmFEfy7bActQzzsZWGN)54YKHHH0vGD5gMW54f0xpaJDDVsrm9dfp)ZXLHXjrnNHPXNPfihfcP(6cSnHjvqTjnddE(NJltgggsxb2LBy(BLI21ds3AggNe1CggWJEEDVYp3fHjmPckzsZWGN)54YKHHXjrnNHz(8kW2d0Wq6kWUCdtsq7c)BLI2EotxeKkcNWc0cc0Mf0YMn0UW)wPOTNZ0fbPn(41jGwqGwaZhAtgA1bT9(qAupOmgzwqliq7lzbTSzdT9(kIuB0Jn0ccqOnbYcA1bT5bTHZXlOQEeHGaqagP45FoUmmeaiCugE)IHWKkGMWKkOYKMHbp)ZXLjdddPRa7Ynm9(qAupOmgzwqliq7lzbTSzdT9(kIuB0Jn0ccqOnbYYW4KOMZWmFEfy7bActQjytAgg88phxMmmmKUcSl3W83kfLLIZR7v(4eW1H0Tg0QdAfAiNldVFXqqv9icbbGamcTzceAZ2W4KOMZWO6reccaby0eMubmFtAgg88phxMmmmKUcSl3W07RisTrp20fQksfqBMaH2eMn0QdA79H0OEqzmYecTzcTVKLHXjrnNHb80NCus91fyBctQacOjndJtIAodtJptlqokes91fyByWZ)CCzYWeMubmBtAgg88phxMmmmKUcSl3Wi0qoxgE)IHGQ6reccabyeAZei0MTHXjrnNHr1JieeacWOjmPcycnPzyWZ)CCzYWW4KOMZWmFEfy7bAyiDfyxUHjjODH)TsrBpNPlcsfHtybAbbAZcAzZgAx4FRu02Zz6IG0gF86eqliqlG5dTjdT6G2EFfrQn6XMUqvrQaAZeAZolOLnBOT3hcTzcTjeA1bT5bTHZXlOQEeHGaqagP45FoUmmeaiCugE)IHWKkGMWKkGjGjnddE(NJltgggsxb2LBy69veP2OhB6cvfPcOntOn7SGw2SH2EFi0Mj0MqdJtIAodZ85vGThOjmPcywM0mm45FoUmzyyiDfyxUHP3xrKAJESPluvKkG2mH2SY3W4KOMZW4nXpugt34fMWegguiWJGctAMub0KMHbp)ZXLjdddPRa7Ynm)Tsr1ko3B5OKQEebDRbT6G2KG2)wPOAfN7TCusvpIG24JxNaAbbAbmFOvh0Me0(3kf93OhGLJskQB1(7iC6wdAzZgAdNJxqNpVcS9OMJIN)54cAzZgAdNJxqlcsCnkE(NJlOvh0Mh065GDfiTiaijv4lKtXZ)CCbTjdTSzdT)Tsrlcassf(c50Tg0QdAdNJxqlcsCnkE(NJlOnzdJtIAodZNpZsokzagL4HpayctQzBsZWGN)54YKHHH0vGD5gM8G2W54f0IGexJIN)54cAzZgAdNJxqlcsCnkE(NJlOvh065GDfiTiaijv4lKtXZ)CCbT6G2)wPOAfN7TCusvpIG24JxNaAbbAb1qRoO9VvkQwX5ElhLu1JiOBnOLnBOnCoEbTiiX1O45FoUGwDqBEqRNd2vG0IaGKuHVqofp)ZXLHXjrnNH5D79Q8tokPNd2ta2eMutOjnddE(NJltgggsxb2LBy(BLIQvCU3Yrjv9icAJpEDcOfeOnlOvh0(3kfvR4CVLJsQ6re0Tg0YMn0g1dkJrUkeAbbAZYW4KOMZWqaxCUuen6SyctQjGjnddE(NJltgggsxb2LBy(BLI2iHfokes10eKU1Gw2SH2)wPOnsyHJcHunnbLKzFb2ur4ewGwqGwab0W4KOMZWeGr5((Z(ws10e0eMuZYKMHbp)ZXLjdddPRa7Ynm5bT)Tsr1ko3B5OKQEebDRbT6G28G2)wPO)g9aSCusrDR2FhHt3AggNe1Cgg1q2cCj9CWUcu(r)XeMub1M0mm45FoUmzyyiDfyxUHjpO9VvkQwX5ElhLu1JiOBnOvh0Mh0(3kf93OhGLJskQB1(7iC6wdA1bTRjOK5i4fTh4sQ4(dk)7(On(41jGwGqB(ggNe1CggYCe8I2dCjvC)bnHjvqjtAgg88phxMmmmKUcSl3W83kfvR4CVLJsQ6re0Tg0YMn0(3kffF0g9yl79Hs9ORnhDRbTSzdTKz4Rr)r)n6by5OKI6wT)ocN24JxNaAZeAb15dTjcTaMf0YMn0sMU3ArnNGwhQu(NJYO3bykE(NJldJtIAodJ(P5lqJ1jBumNFe0eMubvM0mm45FoUmzyyiDfyxUHjpO9VvkQwX5ElhLu1JiOBnOvh0Mh0(3kf93OhGLJskQB1(7iC6wZW4KOMZW0LMghL1jfAobnHj1eSjnddE(NJltgggsxb2LBy(BLIIpAJESL9(qPE01MJ24JxNaAbbAZcA1bT)Tsr)n6by5OKI6wT)ocNU1Gw2SH2KG2EFinQhugJmBOntO9LSGwDqBVVIi1g9ydTGaTzLp0MSHXjrnNH5bFMga5OK8nPwYvJ(JWeMubmFtAggNe1CgMgDT6ELkU)GcddE(NJltgMWegM)iKAZWR71KMjvanPzyWZ)CCzYWWq6kWUCdZFRu0UEq6wZW4KOMZWaE0ZR7v(5UimHj1SnPzyWZ)CCzYWW4KOMZWmFEfy7bAyiDfyxUHjjODH)TsrBpNPlcsfHtybAbbAZcAzZgAx4FRu02Zz6IG0gF86eqliqlG5dTjdT6G2EFfrQn6XMUqvrQaAZei0MDwqRoOnpOnCoEbv1JieeacWifp)ZXLHHaaHJYW7xmeMub0eMutOjnddE(NJltgggsxb2LBy69veP2OhB6cvfPcOntGqB2zzyCsuZzyMpVcS9anHj1eWKMHbp)ZXLjdddPRa7Ynm9(kIuB0JnDHQIub0cc0MD(qRoOvOHCUm8(fdb9L7KY5sFbA)ii0MjqOnBOvh0sMHVg9hvR4CVLJsQ6re0gF86eqBMqBwggNe1CgMxUtkNl9fO9JGMWKAwM0mm45FoUmzyyCsuZzyu9icPi6If0Wq6kWUCdtsq7c)BLI2EotxeKkcNWc0cc0Mf0YMn0UW)wPOTNZ0fbPn(41jGwqGwaZhAtgA1bT9(kIuB0JnDHQIub0cc0MD(qRoOnpOnCoEbv1JieeacWifp)ZXf0QdAjZWxJ(JQvCU3Yrjv9icAJpEDcOntOnlddbachLH3VyimPcOjmPcQnPzyWZ)CCzYWWq6kWUCdtVVIi1g9ytxOQivaTGaTzNp0QdAjZWxJ(JQvCU3Yrjv9icAJpEDcOntOnldJtIAodJQhrifrxSGMWKkOKjnddE(NJltgggsxb2LBy(BLIYsX519kFCc46q6wdA1bT9(kIuB0JnDHQIub0Mj0Me0cywqBIqB4C8cAVVIi9iWB7rnhfp)ZXf0MRqBcH2KHwDqRqd5Cz49lgcQQhriiaeGrOntGqB2ggNe1CggvpIqqaiaJMWKkOYKMHbp)ZXLjdddPRa7Ynm9(kIuB0JnDHQIub0MjqOnjOnHzbTjcTHZXlO9(kI0JaVTh1Cu88phxqBUcTjeAtgA1bTcnKZLH3VyiOQEeHGaqagH2mbcTzByCsuZzyu9icbbGamActQjytAgg88phxMmmmojQ5mmZNxb2EGggsxb2LByscAx4FRu02Zz6IGur4ewGwqG2SGw2SH2f(3kfT9CMUiiTXhVob0cc0cy(qBYqRoOT3xrKAJESPluvKkG2mbcTjbTjmlOnrOnCoEbT3xrKEe4T9OMJIN)54cAZvOnHqBYqRoOnpOnCoEbv1JieeacWifp)ZXLHHaaHJYW7xmeMub0eMubmFtAgg88phxMmmmKUcSl3W07RisTrp20fQksfqBMaH2KG2eMf0Mi0gohVG27Rispc82EuZrXZ)CCbT5k0MqOnzdJtIAodZ85vGThOjmPciGM0mm45FoUmzyyiDfyxUHHmdFn6pQwX5ElhLu1JiOn(41jG2mH2EFinQhugJmbGwDqBVVIi1g9ytxOQivaTGaTjq(qRoOvOHCUm8(fdb9L7KY5sFbA)ii0MjqOnBdJtIAodZl3jLZL(c0(rqtysfWSnPzyWZ)CCzYWW4KOMZWO6resr0flOHH0vGD5gMKG2f(3kfT9CMUiiveoHfOfeOnlOLnBODH)TsrBpNPlcsB8XRtaTGaTaMp0Mm0QdAjZWxJ(JQvCU3Yrjv9icAJpEDcOntOT3hsJ6bLXitaOvh027RisTrp20fQksfqliqBcKp0QdAZdAdNJxqv9icbbGamsXZ)CCzyiaq4Om8(fdHjvanHjvatOjnddE(NJltgggsxb2LByiZWxJ(JQvCU3Yrjv9icAJpEDcOntOT3hsJ6bLXitaOvh027RisTrp20fQksfqliqBcKVHXjrnNHr1JiKIOlwqtycdJwJK557HjntQaAsZW4KOMZWOnrnNHbp)ZXLjdtysnBtAgg88phxMmmmN)GggphbyVDHunxihLuB0JTHXjrnNHXZra2BxivZfYrj1g9yBctQj0KMHbp)ZXLjddZOzyeyyyCsuZzyaT3L)5OHb0oFJgMKGwmx2LMgUO3etxZwiF5(Q8yAH87RxeAzZgAXCzxAA4IsMU3AbUKVCFvEmTq(91lcTSzdTyUSlnnCrjt3BTaxYxUVkpMwiFWLZ51CqlB2qlMl7stdxuqxoxokPF1Jh4s(5ZSGw2SHwmx2LMgUOQQfH8XduifAa8YDHaAzZgAXCzxAA4IMBHcj4rphBOLnBOfZLDPPHl6nX01SfYxUVkpMwiFWLZ51CqlB2qlMl7stdxuxag0(Hcz75mTKmTZH2KnmG2B55pOHzcWylNtUfOeZLDPPHltycdJpOjntQaAsZWGN)54YKHHH0vGD5gMW54f0xpaJDDVsrm9dfp)ZXf0YMn0Me065GDfiv1to4jd8rdfbT9JfOvh0k0qoxgE)IHG24Z0cKJcHuFDb2qBMaH2ecT6G28G2)wPOD9G0Tg0MSHXjrnNHPXNPfihfcP(6cSnHj1SnPzyWZ)CCzYWWq6kWUCdt4C8cQQhriiaeGrkE(NJldJtIAodZl3jLZL(c0(rqtysnHM0mm45FoUmzyyCsuZzyu9icPi6If0Wq6kWUCdtsq7c)BLI2EotxeKkcNWc0cc0Mf0YMn0UW)wPOTNZ0fbPn(41jGwqGwaZhAtgA1bTKz4Rr)rB8zAbYrHqQVUaBAJpEDcOfeGqB2qBUcTVKf0QdAdNJxqF9am219kfX0pu88phxqRoOnpOnCoEbv1JieeacWifp)ZXLHHaaHJYW7xmeMub0eMutatAgg88phxMmmmKUcSl3WqMHVg9hTXNPfihfcP(6cSPn(41jGwqacTzdT5k0(swqRoOnCoEb91dWyx3Ruet)qXZ)CCzyCsuZzyu9icPi6If0eMuZYKMHbp)ZXLjdddPRa7Ynm)Tsr76bPBndJtIAodd4rpVUx5N7IWeMub1M0mm45FoUmzyyiDfyxUH5VvkklfNx3R8XjGRdPBndJtIAodJQhriiaeGrtysfuYKMHbp)ZXLjdddPRa7Ynm9(kIuB0JnDHQIub0cc0Me0cywqBIqB4C8cAVVIi9iWB7rnhfp)ZXf0MRqBcH2KnmojQ5mmVCNuox6lq7hbnHjvqLjnddE(NJltgggNe1CggvpIqkIUybnmKUcSl3WKe0UW)wPOTNZ0fbPIWjSaTGaTzbTSzdTl8VvkA75mDrqAJpEDcOfeOfW8H2KHwDqBVVIi1g9ytxOQivaTGaTjbTaMf0Mi0gohVG27Rispc82EuZrXZ)CCbT5k0MqOnzOvh0Mh0gohVGQ6reccabyKIN)54YWqaGWrz49lgctQaActQjytAgg88phxMmmmKUcSl3W07RisTrp20fQksfqliqBsqlGzbTjcTHZXlO9(kI0JaVTh1Cu88phxqBUcTjeAtgA1bT5bTHZXlOQEeHGaqagP45FoUmmojQ5mmQEeHueDXcActQaMVjndJtIAodtJptlqokes91fyByWZ)CCzYWeMubeqtAggNe1CggvpIqqaiaJgg88phxMmmHjvaZ2KMHbp)ZXLjddJtIAodZ85vGThOHH0vGD5gMKG2f(3kfT9CMUiiveoHfOfeOnlOLnBODH)TsrBpNPlcsB8XRtaTGaTaMp0Mm0QdA79veP2OhB6cvfPcOntOnjOn7SG2eH2W54f0EFfr6rG32JAokE(NJlOnxH2ecTjdT6G28G2W54fuvpIqqaiaJu88phxggcaeokdVFXqysfqtysfWeAsZWGN)54YKHHH0vGD5gMEFfrQn6XMUqvrQaAZeAtcAZolOnrOnCoEbT3xrKEe4T9OMJIN)54cAZvOnHqBYggNe1CgM5ZRaBpqtysfWeWKMHXjrnNH5L7KY5sFbA)iOHbp)ZXLjdtysfWSmPzyWZ)CCzYWW4KOMZWO6resr0flOHH0vGD5gMKG2f(3kfT9CMUiiveoHfOfeOnlOLnBODH)TsrBpNPlcsB8XRtaTGaTaMp0Mm0QdAZdAdNJxqv9icbbGamsXZ)CCzyiaq4Om8(fdHjvanHjvab1M0mmojQ5mmQEeHueDXcAyWZ)CCzYWeMubeuYKMHXjrnNHb80NCus91fyByWZ)CCzYWeMubeuzsZW4KOMZW4nXpugt34fgg88phxMmmHjmmIWVL3ltAMub0KMHXjrnNHPXNPfihfcP(6cSnm45FoUmzyctQzBsZWGN)54YKHHH0vGD5ggYm81O)On(mTa5Oqi1xxGnTXhVob0ccqOnBOnxH2xYcA1bTHZXlOVEag76ELIy6hkE(NJldJtIAodJQhrifrxSGMWKAcnPzyWZ)CCzYWWq6kWUCdZFRu0UEq6wZW4KOMZWaE0ZR7v(5UimHj1eWKMHbp)ZXLjdddPRa7YnmHZXlOfbjUgfp)ZXf0QdA)BLIQvCU3Yrjv9ic6wdA1bTEoyxbslcassf(c502pwG2mbcTzByCsuZzyMpVcS9anHj1SmPzyWZ)CCzYWWq6kWUCdtEq7FRuuvp5GNuBZfiDRbT6G2W54fuvp5GNuBZfifp)ZXLHXjrnNHz(8kW2d0eMub1M0mm45FoUmzyyiDfyxUHP3xrKAJESPluvKkGwqG2KGwaZcAteAdNJxq79vePhbEBpQ5O45FoUG2CfAti0MSHXjrnNHr1JiKIOlwqtysfuYKMHbp)ZXLjdddPRa7Ynm)TsrzP486ELpobCDiDRbT6G2EFinQhugJmbG2mbcTVKLHXjrnNHr1JieeacWOjmPcQmPzyWZ)CCzYWWq6kWUCdtVVIi1g9ytxOQivaTzcTjbTzNf0Mi0gohVG27Rispc82EuZrXZ)CCbT5k0MqOnzdJtIAodZ85vGThOjmPMGnPzyCsuZzyu9icPi6If0WGN)54YKHjmPcy(M0mmojQ5mmGN(KJsQVUaBddE(NJltgMWKkGaAsZW4KOMZW4nXpugt34fgg88phxMmmHjmmlu5BEysZKkGM0mmojQ5mmp1TKQgXCqddE(NJltgMWKA2M0mm45FoUmzyyiDfyxUHjpODnbv1JiKke0ytJIWsDVqRoOnjOnpOnCoEb93OhGLJskQB1(7iCkE(NJlOLnBOLmdFn6p6VrpalhLuu3Q93r40gF86eqBMqlGzbTjByCsuZzyap6519k)CxeMWKAcnPzyWZ)CCzYWWq6kWUCdZFRu0IaGmC(CcAJpEDcOfeGq7lzbT6G2)wPOfbaz485e0Tg0QdAfAiNldVFXqqF5oPCU0xG2pccTzceAZgA1bTjbT5bTHZXlO)g9aSCusrDR2FhHtXZ)CCbTSzdTKz4Rr)r)n6by5OKI6wT)ocN24JxNaAZeAbmlOnzdJtIAodZl3jLZL(c0(rqtysnbmPzyWZ)CCzYWWq6kWUCdZFRu0IaGmC(CcAJpEDcOfeGq7lzbT6G2)wPOfbaz485e0Tg0QdAtcAZdAdNJxq)n6by5OKI6wT)ocNIN)54cAzZgAjZWxJ(J(B0dWYrjf1TA)DeoTXhVob0Mj0cywqBYggNe1CggvpIqkIUybnHj1SmPzyWZ)CCzYWW4KOMZWqCox6KOMtYlryy4LiKN)GgguiWJGctysfuBsZWGN)54YKHHXjrnNHH4CU0jrnNKxIWWWlrip)bnmKz4Rr)jmHjvqjtAgg88phxMmmmKUcSl3W83kf93OhGLJskQB1(7iC6wZW4KOMZW07t6KOMtYlryy4LiKN)GgM)iKrryPUxtysfuzsZWGN)54YKHHH0vGD5gMW54f0FJEawokPOUv7VJWP45FoUGwDqBsqBsqlzg(A0F0FJEawokPOUv7VJWPn(41jGwGqB(qRoOLmdFn6pQwX5ElhLu1JiOn(41jGwqGwaZhAtgAzZgAtcAjZWxJ(J(B0dWYrjf1TA)DeoTXhVob0cc0MD(qRoOnQhugJCvi0cc0MWSG2KH2KnmojQ5mm9(KojQ5K8seggEjc55pOH5pcP2m86EnHj1eSjnddE(NJltgggsxb2LBy(BLIQvCU3Yrjv9ic6wdA1bTHZXlOZNxb2EuZrXZ)CCzyCsuZzy69jDsuZj5Limm8seYZFqdZ85vGTh1CMWKkG5BsZWGN)54YKHHH0vGD5ggNefOrjE4tHcOntGqB2ggNe1CgMEFsNe1CsEjcddVeH88h0W4dActQacOjnddE(NJltgggNe1CggIZ5sNe1CsEjcddVeH88h0Wic)wEVmHjmmKz4Rr)jmPzsfqtAgg88phxMmmmojQ5mmEocWE7cPAUqokP2OhBddPRa7YnmjbTKz4Rr)rXhTrp2YEFOup6AZrB0xaaT6G28Gwq7D5FosNam2Y5KBbkXCzxAA4cAtgAzZgAtcAjZWxJ(JQvCU3Yrjv9icAJpEDcOfeGqlG5dT6Gwq7D5FosNam2Y5KBbkXCzxAA4cAt2WC(dAy8CeG92fs1CHCusTrp2MWKA2M0mm45FoUmzyyCsuZzy47MfSfY6e1QMTq(wQWWq6kWUCdt4C8c6VrpalhLuu3Q93r4u88phxqRoOnjOnjOLmdFn6pQwX5ElhLu1JiOn(41jGwqacTaMp0QdAbT3L)5iDcWylNtUfOeZLDPPHlOnzOLnBOnjO9VvkQwX5ElhLu1JiOBnOvh0Mh0cAVl)Zr6eGXwoNClqjMl7stdxqBYqBYqlB2qBsq7FRuuTIZ9wokPQhrq3AqRoOnpOnCoEb93OhGLJskQB1(7iCkE(NJlOnzdZ5pOHHVBwWwiRtuRA2c5BPctysnHM0mm45FoUmzyyCsuZzyiaq4t0Zve5N7IWWq6kWUCdtEq7FRuuTIZ9wokPQhrq3AgMZFqddbacFIEUIi)CxeMWKAcysZWGN)54YKHHH0vGD5gMKGwYm81O)OAfN7TCusvpIG2OVaaAzZgAjZWxJ(JQvCU3Yrjv9icAJpEDcOntOn78H2KHwDqBsqBEqB4C8c6VrpalhLuu3Q93r4u88phxqlB2qlzg(A0Fu8rB0JTS3hk1JU2C0gF86eqBMqBcolOnzdJtIAodZwGYkWhHjmPMLjnddE(NJltgggNe1Cggxag0(Hcz75mTKmTZnmKUcSl3WSW)wPOTNZ0sY0oxUW)wPORr)zyo)bnmUamO9dfY2ZzAjzANBctQGAtAgg88phxMmmmojQ5mmUamO9dfY2ZzAjzANByiDfyxUHHmdFn6pk(On6Xw27dL6rxBoAJpEDcOntOnbNp0QdAx4FRu02ZzAjzANlx4FRu0Tg0QdAbT3L)5iDcWylNtUfOeZLDPPHlOLnBO9Vvk6VrpalhLuu3Q93r40Tg0QdAx4FRu02ZzAjzANlx4FRu0Tg0QdAZdAbT3L)5iDcWylNtUfOeZLDPPHlOLnBO9Vvkk(On6Xw27dL6rxBo6wdA1bTl8VvkA75mTKmTZLl8Vvk6wdA1bT5bTHZXlO)g9aSCusrDR2FhHtXZ)CCbTSzdTr9GYyKRcHwqG2Sb0WC(dAyCbyq7hkKTNZ0sY0o3eMubLmPzyWZ)CCzYWW4KOMZWKBHcj4rphBddPRa7YnmjbTyUSlnnCr57MfSfY6e1QMTq(wQaA1bT)Tsr1ko3B5OKQEebTXhVob0Mm0YMn0Me0Mh0I5YU00WfLVBwWwiRtuRA2c5BPcOvh0(3kfvR4CVLJsQ6re0gF86eqliqlGzdT6G2)wPOAfN7TCusvpIGU1G2KnmN)GgMCluibp65yBctQGktAgg88phxMmmmojQ5mmSCtihL0psHxiv7gaddPRa7YnmKz4Rr)rXhTrp2YEFOup6AZrB8XRtaTzcTjq(gMZFqddl3eYrj9Ju4fs1UbWeMutWM0mm45FoUmzyyCsuZzyE75EfsTUECUS9x0Wq6kWUCdtVpeAbbi0MqOvh0Mh0(3kfvR4CVLJsQ6re0Tg0QdAtcAZdA)BLI(B0dWYrjf1TA)DeoDRbTSzdT5bTHZXlO)g9aSCusrDR2FhHtXZ)CCbTjByo)bnmV9CVcPwxpox2(lActQaMVjnddE(NJltggMZFqdt75S2hlc5VELnUK)DeZzyCsuZzyApN1(yri)1RSXL8VJyotysfqanPzyWZ)CCzYWW4KOMZW8GnYsa2fsLFVggsxb2LByYdA)BLI(B0dWYrjf1TA)DeoDRbT6G28G2)wPOAfN7TCusvpIGU1mmN)GgMhSrwcWUqQ871eMubmBtAgg88phxMmmmKUcSl3W83kfvR4CVLJsQ6re0Tg0QdA)BLIIpAJESL9(qPE01MJU1mmojQ5mmAtuZzctQaMqtAgg88phxMmmmKUcSl3W83kfvR4CVLJsQ6re0Tg0QdA)BLIIpAJESL9(qPE01MJU1mmojQ5mmF(mlPA3ayctQaMaM0mm45FoUmzyyiDfyxUH5VvkQwX5ElhLu1JiOBndJtIAodZhBb2Su3RjmPcywM0mm45FoUmzyyiDfyxUHjjOnpO9VvkQwX5ElhLu1JiOBnOvh06KOankXdFkuaTzceAZgAtgAzZgAZdA)BLIQvCU3Yrjv9ic6wdA1bTjbT9(q6cvfPcOntGqBwqRoOT3xrKAJESPluvKkG2mbcTG68H2KnmojQ5mmEt8dLABUanHjvab1M0mm45FoUmzyyiDfyxUH5VvkQwX5ElhLu1JiOBndJtIAoddVEbhczU1E9(GxyctQackzsZWGN)54YKHHH0vGD5gM)wPOAfN7TCusvpIGU1GwDq7FRuu8rB0JTS3hk1JU2C0TMHXjrnNHXpckI25sIZ5MWKkGGktAgg88phxMmmmKUcSl3W83kfvR4CVLJsQ6re0gF86eqliaHwqf0QdA)BLIIpAJESL9(qPE01MJU1mmojQ5mmQQXpFMLjmPcyc2KMHbp)ZXLjdddPRa7Ynm)Tsr1ko3B5OKQEebDRbT6G2KG2)wPOAfN7TCusvpIG24JxNaAbbAZcA1bTHZXlOKHVKGrVdkE(NJlOLnBOnpOnCoEbLm8Lem6DqXZ)CCbT6G2)wPOAfN7TCusvpIG24JxNaAbbAti0Mm0QdADsuGgL4HpfkGwGqlGqlB2q7FRuubIb46ELT)I0Tg0QdADsuGgL4HpfkGwGqlGggNe1CgMV)khLm6IWIWeMuZoFtAgg88phxMmmmKUcSl3WqMHVg9hfF0g9yl79Hs9ORnhTXhVob0YMn0gohVGweK4Au88phxggNe1CggTIZ9wokPQhryctQzdOjnddE(NJltgggsxb2LByiZWxJ(JIpAJESL9(qPE01MJ24JxNaA1bTKz4Rr)r1ko3B5OKQEebTXhVoHHXjrnNH53OhGLJskQB1(7iCdZwGYrPKVKLjvanHj1SZ2KMHbp)ZXLjdddPRa7YnmKz4Rr)r1ko3B5OKQEebTrFba0QdAdNJxqNpVcS9OMJIN)54cA1bT9(qAupOmgzwqBMq7lzbT6G2EFfrQn6XMUqvrQaAZei0cy(qlB2qBupOmg5QqOfeOn78nmojQ5mm4J2OhBzVpuQhDT5mHj1StOjnddE(NJltgggsxb2LByscAjZWxJ(JQvCU3Yrjv9icAJ(caOLnBOnQhugJCvi0cc0MD(qBYqRoOnCoEb93OhGLJskQB1(7iCkE(NJlOvh027RisTrp2qBMqlOoFdJtIAodd(On6Xw27dL6rxBotysn7eWKMHbp)ZXLjdddPRa7YnmHZXlOfbjUgfp)ZXf0QdA79HqliqBcnmojQ5mm4J2OhBzVpuQhDT5mHj1SZYKMHbp)ZXLjdddPRa7YnmHZXlOKHVKGrVdkE(NJlOvh0Me0Me0(3kfLm8Lem6DqfHtybAZei0cy(qRoODH)TsrBpNPlcsfHtybAbcTzbTjdTSzdTr9GYyKRcHwqacTVKf0MSHXjrnNHH4CU0jrnNKxIWWWlrip)bnmKHVKGrVdtysnBqTjnddE(NJltgggsxb2LByscA)BLIQvCU3Yrjv9ic6wdA1bTEoyxbslcassf(c502pwGwqacTacT6G2KG2)wPOAfN7TCusvpIG24JxNaAbbi0(swqlB2q7FRu09bE4aifrJ3BaM24JxNaAbbi0(swqRoO9Vvk6(apCaKIOX7nat3AqBYqBYggNe1CggvpIqpa9JqQ2naMWKA2GsM0mm45FoUmzyyiDfyxUHjjO9VvkAraqsQWxiNU1GwDqBEqB4C8cArqIRrXZ)CCbT6G2KG2)wPO7d8WbqkIgV3amDRbTSzdT)Tsrlcassf(c50gF86eqliaH2xYcAtgAtgAzZgA)BLIweaKKk8fYPBnOvh0(3kfTiaijv4lKtB8XRtaTGaeAFjlOvh0gohVGweK4Au88phxqRoO9VvkQwX5ElhLu1JiOBndJtIAodJQhrOhG(riv7gatysnBqLjnddE(NJltgggsxb2LByI6bLXixfcTGaTVKf0YMn0Me0g1dkJrUkeAbbAjZWxJ(JQvCU3Yrjv9icAJpEDcOvh0(3kfDFGhoasr049gGPBnOnzdJtIAodJQhrOhG(riv7gatyctyyan2IAotQzNF25NF25Nagg9EF19kmmGYF0MoWf0cy(qRtIAoOLxIqqHSAyeAiXKA2zbOHrRhvXrddOaAZD9icOn3d6byOn3(vVGdiRGcOfCeAIC)0t)TcW7pLmpPlQNn3JAos7QiDr9qshYkOaAbLP1fhAZoRuG2SZp78HSczfuaT5gG97ff5(qwbfqBcc0ck)i89cH2CZQBbT5UgXCqkKvqb0MGaTGYwlOv5C(3jSaTQPH2TOUxOnbvU3CBPaT5MMCh0wkOvJ7aGn0wxfLhOaAZyyG2pQMgHwTz419cT85TiqBjGwY8OXXaxuiRGcOnbbAZna73lcTH3VyqJ6bLXixfcTXaTr9GYyKRcH2yG2TaHw8iZ(cSHwoEVbyOT9am2qBa2pOvBc8IY5qB0Uam0UqpalOqwbfqBcc0MBm8f0MGo6DaT(TG22jLZH2qp6SiOqwHSckG2eujOHKDGlO9JQPrOLmpFpG2p(wNGcTGYieuleq7nxccyVFuBo06KOMtaTZXbGcz1jrnNGQ1izE(EKiW01MOMdYQtIAobvRrY889irGPVfOSc8jLZFqGEocWE7cPAUqokP2OhBiRojQ5euTgjZZ3JebMoO9U8pht58he4eGXwoNClqjMl7stdxPaANVrGjH5YU00Wf9My6A2c5l3xLhtlKFF9ISzJ5YU00WfLmDV1cCjF5(Q8yAH87RxKnBmx2LMgUOKP7TwGl5l3xLhtlKp4Y58Ao2SXCzxAA4Ic6Y5Yrj9RE8axYpFMfB2yUSlnnCrvvlc5JhOqk0a4L7cbB2yUSlnnCrZTqHe8ONJnB2yUSlnnCrVjMUMTq(Y9v5X0c5dUCoVMJnBmx2LMgUOUamO9dfY2ZzAjzANNmKviRGcOnbvcAizh4cArqJnaqBupi0gGrO1jX0qBjGwh0EX9phPqwDsuZja(u3sQAeZbHSckGwqzAACaG2CxpIaAZDiOXgA9BbTpEDHxh0ckNaa0MMZNtaz1jrnNirGPdE0ZR7v(5UisPuaZBnbv1JiKke0ytJIWsDV6skVW54f0FJEawokPOUv7VJWP45FoUyZMmdFn6p6VrpalhLuu3Q93r40gF86ezcywjdz1jrnNirGP)YDs5CPVaTFemLsb8VvkAraqgoFobTXhVobiaFjlD)TsrlcaYW5ZjOBnDcnKZLH3VyiOVCNuox6lq7hbZey26skVW54f0FJEawokPOUv7VJWP45FoUyZMmdFn6p6VrpalhLuu3Q93r40gF86ezcywjdz1jrnNirGPR6resr0flykLc4FRu0IaGmC(CcAJpEDcqa(sw6(BLIweaKHZNtq3A6skVW54f0FJEawokPOUv7VJWP45FoUyZMmdFn6p6VrpalhLuu3Q93r40gF86ezcywjdz1jrnNirGPtCox6KOMtYlrKY5piquiWJGciRojQ5ejcmDIZ5sNe1CsEjIuo)bbsMHVg9NaYQtIAorIatV3N0jrnNKxIiLZFqG)riJIWsDVPukG)Tsr)n6by5OKI6wT)ocNU1GS6KOMtKiW079jDsuZj5Lis58he4FesTz419MsPagohVG(B0dWYrjf1TA)Deofp)ZXLUKsImdFn6p6VrpalhLuu3Q93r40gF86eaZxhzg(A0FuTIZ9wokPQhrqB8XRtacG5NmB2jrMHVg9h93OhGLJskQB1(7iCAJpEDcqYoFDr9GYyKRcbjHzLCYqwDsuZjsey69(KojQ5K8sePC(dcC(8kW2JAUukfW)wPOAfN7TCusvpIGU10fohVGoFEfy7rnhfp)ZXfKvNe1CIebMEVpPtIAojVerkN)Ga9btPuaDsuGgL4HpfkYey2qwDsuZjsey6eNZLojQ5K8sePC(dcue(T8EbzfYQtIAob1heyJptlqokes91fyNsPagohVG(6bySR7vkIPFO45FoUyZojphSRaPQEYbpzGpAOiOTFSOtOHCUm8(fdbTXNPfihfcP(6cSZeyc1L3FRu0UEq6wlziRojQ5euFWebM(l3jLZL(c0(rWukfWW54fuvpIqqaiaJu88phxqwDsuZjO(GjcmDvpIqkIUybtHaaHJYW7xmeabmLsbmPf(3kfT9CMUiiveoHfqYIn7f(3kfT9CMUiiTXhVobiaMFY6iZWxJ(J24Z0cKJcHuFDb20gF86eGam7C9LS0fohVG(6bySR7vkIPFO45FoU0Lx4C8cQQhriiaeGrkE(NJliRojQ5euFWebMUQhrifrxSGPukGKz4Rr)rB8zAbYrHqQVUaBAJpEDcqaMDU(sw6cNJxqF9am219kfX0pu88phxqwDsuZjO(GjcmDWJEEDVYp3frkLc4FRu0UEq6wdYQtIAob1hmrGPR6reccabymLsb8VvkklfNx3R8XjGRdPBniRojQ5euFWebM(l3jLZL(c0(rWukfWEFfrQn6XMUqvrQaKKamRedNJxq79vePhbEBpQ5O45FoUY1eMmKvNe1CcQpyIatx1JiKIOlwWuiaq4Om8(fdbqatPuatAH)TsrBpNPlcsfHtybKSyZEH)TsrBpNPlcsB8XRtacG5NSUEFfrQn6XMUqvrQaKKamRedNJxq79vePhbEBpQ5O45FoUY1eMSU8cNJxqv9icbbGamsXZ)CCbz1jrnNG6dMiW0v9icPi6IfmLsbS3xrKAJESPluvKkajjaZkXW54f0EFfr6rG32JAokE(NJRCnHjRlVW54fuvpIqqaiaJu88phxqwDsuZjO(Gjcm9gFMwGCuiK6RlWgYQtIAob1hmrGPR6reccabyeYQtIAob1hmrGPpFEfy7bMcbachLH3VyiacykLcysl8VvkA75mDrqQiCclGKfB2l8VvkA75mDrqAJpEDcqam)K117RisTrp20fQksfzMu2zLy4C8cAVVIi9iWB7rnhfp)ZXvUMWK1Lx4C8cQQhriiaeGrkE(NJliRojQ5euFWebM(85vGThykLcyVVIi1g9ytxOQivKzszNvIHZXlO9(kI0JaVTh1Cu88phx5ActgYQtIAob1hmrGP)YDs5CPVaTFeeYQtIAob1hmrGPR6resr0flykeaiCugE)IHaiGPukGjTW)wPOTNZ0fbPIWjSaswSzVW)wPOTNZ0fbPn(41jabW8twxEHZXlOQEeHGaqagP45FoUGS6KOMtq9btey6QEeHueDXccz1jrnNG6dMiW0bp9jhLuFDb2qwDsuZjO(GjcmDVj(HYy6gVaYkKvqb0MrJEagAhf0Yu3Q93r4qR2m86EH2EcpQ5G2CFOveEhcOn78fq7hvtJqBUPIZ9gAhf0M76reqBIqBgdd06ncToO9I7Focz1jrnNG(hHuBgEDVabp6519k)CxePukG)Tsr76bPBniRojQ5e0)iKAZWR7nrGPpFEfy7bMcbachLH3VyiacykLcysl8VvkA75mDrqQiCclGKfB2l8VvkA75mDrqAJpEDcqam)K117RisTrp20fQksfzcm7S0Lx4C8cQQhriiaeGrkE(NJliRojQ5e0)iKAZWR7nrGPpFEfy7bMsPa27RisTrp20fQksfzcm7SGS6KOMtq)JqQndVU3ebM(l3jLZL(c0(rWukfWEFfrQn6XMUqvrQaKSZxNqd5Cz49lgc6l3jLZL(c0(rWmbMToYm81O)OAfN7TCusvpIG24JxNiZSGS6KOMtq)JqQndVU3ebMUQhrifrxSGPqaGWrz49lgcGaMsPaM0c)BLI2EotxeKkcNWcizXM9c)BLI2EotxeK24JxNaeaZpzD9(kIuB0JnDHQIubizNVU8cNJxqv9icbbGamsXZ)CCPJmdFn6pQwX5ElhLu1JiOn(41jYmliRojQ5e0)iKAZWR7nrGPR6resr0flykLcyVVIi1g9ytxOQivas25RJmdFn6pQwX5ElhLu1JiOn(41jYmliRojQ5e0)iKAZWR7nrGPR6reccabymLsb8VvkklfNx3R8XjGRdPBnD9(kIuB0JnDHQIurMjbywjgohVG27Rispc82EuZrXZ)CCLRjmzDcnKZLH3VyiOQEeHGaqagZey2qwDsuZjO)ri1MHx3BIatx1JieeacWykLcyVVIi1g9ytxOQivKjWKsywjgohVG27Rispc82EuZrXZ)CCLRjmzDcnKZLH3VyiOQEeHGaqagZey2qwDsuZjO)ri1MHx3BIatF(8kW2dmfcaeokdVFXqaeWukfWKw4FRu02Zz6IGur4ewajl2Sx4FRu02Zz6IG0gF86eGay(jRR3xrKAJESPluvKkYeysjmRedNJxq79vePhbEBpQ5O45FoUY1eMSU8cNJxqv9icbbGamsXZ)CCbz1jrnNG(hHuBgEDVjcm95ZRaBpWukfWEFfrQn6XMUqvrQitGjLWSsmCoEbT3xrKEe4T9OMJIN)54kxtyYqwDsuZjO)ri1MHx3BIat)L7KY5sFbA)iykLcizg(A0FuTIZ9wokPQhrqB8XRtKzVpKg1dkJrMa669veP2OhB6cvfPcqsG81j0qoxgE)IHG(YDs5CPVaTFemtGzdz1jrnNG(hHuBgEDVjcmDvpIqkIUybtHaaHJYW7xmeabmLsbmPf(3kfT9CMUiiveoHfqYIn7f(3kfT9CMUiiTXhVobiaMFY6iZWxJ(JQvCU3Yrjv9icAJpEDIm79H0OEqzmYeqxVVIi1g9ytxOQivascKVU8cNJxqv9icbbGamsXZ)CCbz1jrnNG(hHuBgEDVjcmDvpIqkIUybtPuajZWxJ(JQvCU3Yrjv9icAJpEDIm79H0OEqzmYeqxVVIi1g9ytxOQivascKpKviRGcOn35C(3jSaTXaTBbcT5MMCxkqBcQCV52Gw9GXdA3cStqQRIYduaTzmmqRwJpESBKdafYQtIAob9pczuewQ7fOwX5ElhLu1JisPuajZWxJ(JIpAJESL9(qPE01MJ24JxNaYQtIAob9pczuewQ7nrGPJpAJESL9(qPE01MdYQtIAob9pczuewQ7nrGPpFEfy7bMcbachLH3VyiacykLcysl8VvkA75mDrqQiCclGKfB2l8VvkA75mDrqAJpEDcqam)K117RisTrp2GamHzRlVW54fuvpIqqaiaJu88phxqwDsuZjO)riJIWsDVjcm95ZRaBpWukfWEFfrQn6XgeGjmBiRojQ5e0)iKrryPU3ebMEJptlqokes91fyNsPagohVG(6bySR7vkIPFO45FoUGS6KOMtq)JqgfHL6Etey6Gh986ELFUlIukfW)wPOD9G0TgKvNe1Cc6FeYOiSu3BIatF(8kW2dmfcaeokdVFXqaeWukfWKw4FRu02Zz6IGur4ewajl2Sx4FRu02Zz6IG0gF86eGay(jRR3hsJ6bLXiZcKxYIn7EFfrQn6XgeGjqw6YlCoEbv1JieeacWifp)ZXfKvNe1Cc6FeYOiSu3BIatF(8kW2dmLsbS3hsJ6bLXiZcKxYIn7EFfrQn6XgeGjqwqwDsuZjO)riJIWsDVjcmDvpIqqaiaJPukG)TsrzP486ELpobCDiDRPtOHCUm8(fdbv1JieeacWyMaZgYQtIAob9pczuewQ7nrGPdE6tokP(6cStPua79veP2OhB6cvfPImbMWS117dPr9GYyKjmZxYcYQtIAob9pczuewQ7nrGP34Z0cKJcHuFDb2qwDsuZjO)riJIWsDVjcmDvpIqqaiaJPukGcnKZLH3VyiOQEeHGaqagZey2qwDsuZjO)riJIWsDVjcm95ZRaBpWuiaq4Om8(fdbqatPuatAH)TsrBpNPlcsfHtybKSyZEH)TsrBpNPlcsB8XRtacG5NSUEFfrQn6XMUqvrQiZSZIn7EFyMjuxEHZXlOQEeHGaqagP45FoUGS6KOMtq)JqgfHL6Etey6ZNxb2EGPukG9(kIuB0JnDHQIurMzNfB29(WmtiKvNe1Cc6FeYOiSu3BIat3BIFOmMUXlsPua79veP2OhB6cvfPImZkFiRqwbfqBUXWxqly07aAjZTQOMtaz1jrnNGsg(scg9oasa71jKJswemLsb8Vvkkz4ljy07GkcNWsMzPlQhugJCviiVKfKvNe1Cckz4ljy07irGPta71jKJswemLsbmP)wPOcedW19kB)fPn(41ja5LSsw3FRuubIb46ELT)I0TgKvNe1Cckz4ljy07irGPta71jKJswemLsbmP)wPOAfN7TCusvpIG24JxNaeGVKvUMeGjsMHVg9hv1Ji0dq)iKQDdaTrFbqYSz)3kfvR4CVLJsQ6re0gF86eG07dPr9GYyKjmzD)Tsr1ko3B5OKQEebDRPljphSRaPfbajPcFHCA7hlGaeq2S)BLI(B0dWYrjf1TA)DeoDRLSU8cNJxqlcsCnkE(NJliRojQ5euYWxsWO3rIatNa2RtihLSiykLc4FRuuTIZ9wokPQhrqB8XRtacOs3FRu09bE4aifrJ3BaM24JxNaKxYkxtcWejZWxJ(JQ6re6bOFes1UbG2OVaizD)Tsr3h4HdGuenEVbyAJpEDcD)Tsr1ko3B5OKQEebDRPljphSRaPfbajPcFHCA7hlGaeq2S)BLI(B0dWYrjf1TA)DeoDRLSU8cNJxqlcsCnkE(NJliRojQ5euYWxsWO3rIatNa2RtihLSiykLcys)Tsrlcassf(c50gF86eGKaSz)3kfTiaijv4lKtB8XRtasVpKg1dkJrMWK193kfTiaijv4lKt3A68CWUcKweaKKk8fYPTFSKjWS1L3FRu0FJEawokPOUv7VJWPBnD5fohVGweK4Au88phxqwDsuZjOKHVKGrVJebMobSxNqokzrWukfW)wPOfbajPcFHC6wt3FRu09bE4aifrJ3BaMU1055GDfiTiaijv4lKtB)yjtGzRlV)wPO)g9aSCusrDR2FhHt3A6YlCoEbTiiX1O45FoUGS6KOMtqjdFjbJEhjcmDcyVoHCuYIGPukG)Tsr1ko3B5OKQEebTXhVobijGU)wPOAfN7TCusvpIGU10fohVGweK4Au88phx6(BLIsg(scg9oOIWjSKjqabv68CWUcKweaKKk8fYPTFSacqaHS6KOMtqjdFjbJEhjcmDcyVoHCuYIGPukG)Tsr1ko3B5OKQEebDRPlCoEbTiiX1O45FoU055GDfiTiaijv4lKtB)yjtGzRlP)wPOKHVKGrVdQiCclzceWeSU)wPOfbajPcFHCAJpEDcqEjlD)Tsrlcassf(c50TgB2)Tsr3h4HdGuenEVby6wt3FRuuYWxsWO3bveoHLmbciOkziRqwDsuZjOKz4Rr)jaUfOSc8jLZFqGEocWE7cPAUqokP2Oh7ukfWKiZWxJ(JIpAJESL9(qPE01MJ2OVaqxEG27Y)CKobySLZj3cuI5YU00WvYSzNezg(A0FuTIZ9wokPQhrqB8XRtacqaZxhO9U8phPtagB5CYTaLyUSlnnCLmKvNe1Cckzg(A0FIebM(wGYkWNuo)bbY3nlylK1jQvnBH8TurkLcy4C8c6VrpalhLuu3Q93r4u88phx6skjYm81O)OAfN7TCusvpIG24JxNaeGaMVoq7D5FosNam2Y5KBbkXCzxAA4kz2St6VvkQwX5ElhLu1JiOBnD5bAVl)Zr6eGXwoNClqjMl7stdxjNmB2j93kfvR4CVLJsQ6re0TMU8cNJxq)n6by5OKI6wT)ocNIN)54kziRojQ5euYm81O)ejcm9TaLvGpPC(dcKaaHprpxrKFUlIukfW8(BLIQvCU3Yrjv9ic6wdYQtIAobLmdFn6prIatFlqzf4JiLsbmjYm81O)OAfN7TCusvpIG2OVaGnBYm81O)OAfN7TCusvpIG24JxNiZSZpzDjLx4C8c6VrpalhLuu3Q93r4u88phxSztMHVg9hfF0g9yl79Hs9ORnhTXhVorMj4SsgYQtIAobLmdFn6prIatFlqzf4tkN)GaDbyq7hkKTNZ0sY0opLsbCH)TsrBpNPLKPDUCH)TsrxJ(dYQtIAobLmdFn6prIatFlqzf4tkN)GaDbyq7hkKTNZ0sY0opLsbKmdFn6pk(On6Xw27dL6rxBoAJpEDImtW5RBH)TsrBpNPLKPDUCH)Tsr3A6aT3L)5iDcWylNtUfOeZLDPPHl2S)BLI(B0dWYrjf1TA)DeoDRPBH)TsrBpNPLKPDUCH)Tsr3A6Yd0Ex(NJ0jaJTCo5wGsmx2LMgUyZ(Vvkk(On6Xw27dL6rxBo6wt3c)BLI2Eotljt7C5c)BLIU10Lx4C8c6VrpalhLuu3Q93r4u88phxSzh1dkJrUkeKSbeYQtIAobLmdFn6prIatFlqzf4tkN)GaZTqHe8ONJDkLcysyUSlnnCr57MfSfY6e1QMTq(wQq3FRuuTIZ9wokPQhrqB8XRtKmB2jLhMl7stdxu(UzbBHSorTQzlKVLk093kfvR4CVLJsQ6re0gF86eGay26(BLIQvCU3Yrjv9ic6wlziRojQ5euYm81O)ejcm9TaLvGpPC(dcKLBc5OK(rk8cPA3aKsPasMHVg9hfF0g9yl79Hs9ORnhTXhVorMjq(qwDsuZjOKz4Rr)jsey6BbkRaFs58he4Bp3RqQ11JZLT)IPukG9(qqaMqD593kfvR4CVLJsQ6re0TMUKY7Vvk6VrpalhLuu3Q93r40TgB25fohVG(B0dWYrjf1TA)Deofp)ZXvYqwDsuZjOKz4Rr)jsey6BbkRaFs58hey75S2hlc5VELnUK)DeZbz1jrnNGsMHVg9NirGPVfOSc8jLZFqGpyJSeGDHu53BkLcyE)Tsr)n6by5OKI6wT)ocNU10L3FRuuTIZ9wokPQhrq3AqwDsuZjOKz4Rr)jsey6AtuZLsPa(3kfvR4CVLJsQ6re0TMU)wPO4J2OhBzVpuQhDT5OBniRojQ5euYm81O)ejcm9pFMLuTBasPua)BLIQvCU3Yrjv9ic6wt3FRuu8rB0JTS3hk1JU2C0TgKvNe1Cckzg(A0FIebM(hBb2Su3BkLc4FRuuTIZ9wokPQhrq3AqwDsuZjOKz4Rr)jsey6Et8dLABUatPuatkV)wPOAfN7TCusvpIGU105KOankXdFkuKjWStMn78(BLIQvCU3Yrjv9ic6wtxs9(q6cvfPImbMLUEFfrQn6XMUqvrQitGG68tgYQtIAobLmdFn6prIatNxVGdHm3AVEFWlsPua)BLIQvCU3Yrjv9ic6wdYQtIAobLmdFn6prIat3pckI25sIZ5PukG)Tsr1ko3B5OKQEebDRP7Vvkk(On6Xw27dL6rxBo6wdYQtIAobLmdFn6prIatxvn(5ZSsPua)BLIQvCU3Yrjv9icAJpEDcqacQ093kffF0g9yl79Hs9ORnhDRbz1jrnNGsMHVg9NirGP)9x5OKrxewePukG)Tsr1ko3B5OKQEebDRPlP)wPOAfN7TCusvpIG24JxNaKS0fohVGsg(scg9oO45FoUyZoVW54fuYWxsWO3bfp)ZXLU)wPOAfN7TCusvpIG24JxNaKeMSoNefOrjE4tHcGaYM9FRuubIb46ELT)I0TMoNefOrjE4tHcGaczfYkOaAZD9icOLmdFn6pbKvNe1Cckzg(A0FIebMUwX5ElhLu1JisPuajZWxJ(JIpAJESL9(qPE01MJ24JxNGn7W54f0IGexJIN)54cYQtIAobLmdFn6prIat)3OhGLJskQB1(7i8u2cuokL8LSacykLcizg(A0Fu8rB0JTS3hk1JU2C0gF86e6iZWxJ(JQvCU3Yrjv9icAJpEDciRojQ5euYm81O)ejcmD8rB0JTS3hk1JU2CPukGKz4Rr)r1ko3B5OKQEebTrFbGUW54f05ZRaBpQ5O45FoU017dPr9GYyKzL5lzPR3xrKAJESPluvKkYeiG5ZMDupOmg5QqqYoFiRojQ5euYm81O)ejcmD8rB0JTS3hk1JU2CPukGjrMHVg9hvR4CVLJsQ6re0g9faSzh1dkJrUkeKSZpzDHZXlO)g9aSCusrDR2FhHtXZ)CCPR3xrKAJESZeuNpKvNe1Cckzg(A0FIebMo(On6Xw27dL6rxBUukfWW54f0IGexJIN)54sxVpeKecz1jrnNGsMHVg9NirGPtCox6KOMtYlrKY5piqYWxsWO3rkLcy4C8ckz4ljy07GIN)54sxsj93kfLm8Lem6DqfHtyjtGaMVUf(3kfT9CMUiiveoHfGzLmB2r9GYyKRcbb4lzLmKvNe1Cckzg(A0FIebMUQhrOhG(riv7gGukfWK(BLIQvCU3Yrjv9ic6wtNNd2vG0IaGKuHVqoT9JfqacOUK(BLIQvCU3Yrjv9icAJpEDcqa(swSz)3kfDFGhoasr049gGPn(41jab4lzP7Vvk6(apCaKIOX7nat3AjNmKvNe1Cckzg(A0FIebMUQhrOhG(riv7gGukfWK(BLIweaKKk8fYPBnD5fohVGweK4Au88phx6s6Vvk6(apCaKIOX7nat3ASz)3kfTiaijv4lKtB8XRtacWxYk5KzZ(VvkAraqsQWxiNU1093kfTiaijv4lKtB8XRtacWxYsx4C8cArqIRrXZ)CCP7VvkQwX5ElhLu1JiOBniRojQ5euYm81O)ejcmDvpIqpa9JqQ2naPukGr9GYyKRcb5LSyZoPOEqzmYvHGqMHVg9hvR4CVLJsQ6re0gF86e6(BLIUpWdhaPiA8EdW0TwYqwHS6KOMtqrHapcka(5ZSKJsgGrjE4daPukG)Tsr1ko3B5OKQEebDRPlP)wPOAfN7TCusvpIG24JxNaeaZxxs)Tsr)n6by5OKI6wT)ocNU1yZoCoEbD(8kW2JAokE(NJl2SdNJxqlcsCnkE(NJlD555GDfiTiaijv4lKtXZ)CCLmB2)Tsrlcassf(c50TMUW54f0IGexJIN)54kziRojQ5euuiWJGIebM(727v5NCusphSNaCkLcyEHZXlOfbjUgfp)ZXfB2HZXlOfbjUgfp)ZXLophSRaPfbajPcFHCkE(NJlD)Tsr1ko3B5OKQEebTXhVobiGAD)Tsr1ko3B5OKQEebDRXMD4C8cArqIRrXZ)CCPlpphSRaPfbajPcFHCkE(NJliRojQ5euuiWJGIebMobCX5sr0OZskLc4FRuuTIZ9wokPQhrqB8XRtasw6(BLIQvCU3Yrjv9ic6wJn7OEqzmYvHGKfKvNe1Cckke4rqrIatpaJY99N9TKQPjykLc4FRu0gjSWrHqQMMG0TgB2)TsrBKWchfcPAAckjZ(cSPIWjSacGacz1jrnNGIcbEeuKiW0vdzlWL0Zb7kq5h9NukfW8(BLIQvCU3Yrjv9ic6wtxE)Tsr)n6by5OKI6wT)ocNU1GS6KOMtqrHapcksey6K5i4fTh4sQ4(dMsPaM3FRuuTIZ9wokPQhrq3A6Y7Vvk6VrpalhLuu3Q93r40TMU1euYCe8I2dCjvC)bL)DF0gF86eaZhYQtIAobffc8iOirGPRFA(c0yDYgfZ5hbtPua)BLIQvCU3Yrjv9ic6wJn7)wPO4J2OhBzVpuQhDT5OBn2SjZWxJ(J(B0dWYrjf1TA)DeoTXhVorMG68teWSyZMmDV1IAobTouP8phLrVdWu88phxqwDsuZjOOqGhbfjcm9U004OSoPqZjykLcyE)Tsr1ko3B5OKQEebDRPlV)wPO)g9aSCusrDR2FhHt3AqwDsuZjOOqGhbfjcm9h8zAaKJsY3KAjxn6pIukfW)wPO4J2OhBzVpuQhDT5On(41jajlD)Tsr)n6by5OKI6wT)ocNU1yZoPEFinQhugJm7mFjlD9(kIuB0JnizLFYqwDsuZjOOqGhbfjcm9gDT6ELkU)GciRqwbfqBU5FEfy7rnh02t4rnhKvNe1Cc685vGTh1CaB8zAbYrHqQVUa7ukfWW54f0xpaJDDVsrm9dfp)ZXfKvNe1Cc685vGTh1Cjcm95ZRaBpWuiaq4Om8(fdbqatPuatAH)TsrBpNPlcsfHtybKSyZEH)TsrBpNPlcsB8XRtacG5NSU8cNJxqv9icbbGamsXZ)CCPlV)wPOD9G0TMoHgY5YW7xmeuWJEEDVYp3frMatiKvNe1Cc685vGTh1Cjcm95ZRaBpWukfW8cNJxqv9icbbGamsXZ)CCPlV)wPOD9G0TMoHgY5YW7xmeuWJEEDVYp3frMatiKvNe1Cc685vGTh1CjcmDvpIqqaiaJPukGj93kfLLIZR7v(4eW1H0gDsWMDs)TsrzP486ELpobCDiDRPljTgbT8LSOasv9icPi6IfKnBTgbT8LSOasbp6519k)CxeSzR1iOLVKffq6l3jLZL(c0(rWKtozDcnKZLH3VyiOQEeHGaqagZey2qwDsuZjOZNxb2EuZLiW0NpVcS9atHaaHJYW7xmeabmLsbmPf(3kfT9CMUiiveoHfqYIn7f(3kfT9CMUiiTXhVobiaMFY6(BLIYsX519kFCc46qAJojyZoP)wPOSuCEDVYhNaUoKU10LKwJGw(swuaPQEeHueDXcYMTwJGw(swuaPGh986ELFUlc2S1Ae0YxYIci9L7KY5sFbA)iyYjdz1jrnNGoFEfy7rnxIatF(8kW2dmLsb8VvkklfNx3R8XjGRdPn6KGn7K(BLIYsX519kFCc46q6wtxsAncA5lzrbKQ6resr0fliB2AncA5lzrbKcE0ZR7v(5UiyZwRrqlFjlkG0xUtkNl9fO9JGjNmKvNe1Cc685vGTh1Cjcm9xUtkNl9fO9JGPukGjL3FRu0UEq6wJn7EFfrQn6XMUqvrQaeaZNn7EFinQhugJm7mFjRK1j0qoxgE)IHG(YDs5CPVaTFemtGzdz1jrnNGoFEfy7rnxIath8ONx3R8ZDrKsPa(3kfTRhKU10j0qoxgE)IHGcE0ZR7v(5UiYey2qwDsuZjOZNxb2EuZLiW0v9icPi6IfmfcaeokdVFXqaeWukfWKw4FRu02Zz6IGur4ewajl2Sx4FRu02Zz6IG0gF86eGay(jRlV)wPOD9G0TgB29(kIuB0JnDHQIubiaMpB29(qAupOmgz2z(sw6YlCoEbv1JieeacWifp)ZXfKvNe1Cc685vGTh1CjcmDvpIqkIUybtPuaZ7VvkAxpiDRXMDVVIi1g9ytxOQivacG5ZMDVpKg1dkJrMDMVKfKvNe1Cc685vGTh1CjcmDWJEEDVYp3frkLc4FRu0UEq6wdYQtIAobD(8kW2JAUebM(85vGThykeaiCugE)IHaiGPukGjTW)wPOTNZ0fbPIWjSaswSzVW)wPOTNZ0fbPn(41jabW8twxEHZXlOQEeHGaqagP45FoUGS6KOMtqNpVcS9OMlrGPpFEfy7bczfYkOaAzc)wEVGwrDVCmbj8(fdOTNWJAoiRojQ5eur43Y7fWgFMwGCuiK6RlWgYQtIAobve(T8ELiW0v9icPi6IfmLsbKmdFn6pAJptlqokes91fytB8XRtacWSZ1xYsx4C8c6RhGXUUxPiM(HIN)54cYQtIAobve(T8ELiW0bp6519k)CxePukG)Tsr76bPBniRojQ5eur43Y7vIatF(8kW2dmLsbmCoEbTiiX1O45FoU093kfvR4CVLJsQ6re0TMophSRaPfbajPcFHCA7hlzcmBiRojQ5eur43Y7vIatF(8kW2dmLsbmV)wPOQEYbpP2Mlq6wtx4C8cQQNCWtQT5cKIN)54cYQtIAobve(T8ELiW0v9icPi6IfmLsbS3xrKAJESPluvKkajjaZkXW54f0EFfr6rG32JAokE(NJRCnHjdz1jrnNGkc)wEVsey6QEeHGaqagtPua)BLIYsX519kFCc46q6wtxVpKg1dkJrMazc8LSGS6KOMtqfHFlVxjcm95ZRaBpWukfWEFfrQn6XMUqvrQiZKYoRedNJxq79vePhbEBpQ5O45FoUY1eMmKvNe1CcQi8B59krGPR6resr0fliKvNe1CcQi8B59krGPdE6tokP(6cSHS6KOMtqfHFlVxjcmDVj(HYy6gVWeMWya]] )
    
end
