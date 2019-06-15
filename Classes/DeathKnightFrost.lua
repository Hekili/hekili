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
        if amt > 0 then
            if resource == "runes" then
                gain( amt * 10, "runic_power" )

                if talent.gathering_storm.enabled and buff.remorseless_winter.up then
                    buff.remorseless_winter.expires = buff.remorseless_winter.expires + ( 0.5 * amt )
                end

            elseif resource == "runic_power" and buff.breath_of_sindragosa.up then
                if runic_power.current < 16 then
                    removeBuff( "breath_of_sindragosa" )
                    gain( 2, "runes" )
                end
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

            pvptalent = "chill_streak",

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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 / ( ( level < 116 and equipped.seal_of_necrofantasia ) and 1.10 or 1 ) end,
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


    spec:RegisterPack( "Frost DK", 20190422.1033, [[dyu2Hbqivr9ijuAtskJIuvNIuLvPksVcqnljKBPkc2fHFrk1WKO6yQswMeLNjPQPjHQRjbTnvrOVrkcnoju4CKIO1rkcMNQW9ayFsGdkHIAHKkEiPiPjsks4IQIiTrsrQtQkIYkvL6LsOiUjPir2jPs)KuKOgQQiQwQekspfOPsk8vvre2lK)sLbt0HfwSQ6XiMSkDzuBMQ(SKmAOQtl61aYSj52QODR0VvmCvy5s9CKMoLRdLTtkQVdvgVQiIopPK1lPY8Li7h0OxinqG3WyKULv(lnz5fVSYeVkV(6lSqeOP1bJapccqrfJa34KrGA6EOguQPOycc8i0snXfPbcKoynHrG4n7GQjOT2vPHh7liZP208etfwolPdVPnnpjAJa)yPYEYw0hbEdJr6ww5V0KLx8Ykt8Q86RV4preyGz4NgbcMNAQiq859Yl6JaVmLGalwOut3d1GsnfCy4HYIjBwH3GVlwOeVzhunbT1Ukn8yFbzo1MMNyQWYzjD4nTP5jrB47IfklMp6ubLLvwrqzzL)stcLpbO8v5Ac1xp8n8DXcLAQ4JTIPAcW3flu(eGYNSLOWUmuQPuUxOut3mxhlGVlwO8jaLfZ3lu6dL6heGGs)0qjgn3kO8jTy6tIIGYN8rtdLPhkpuHwCdL5MwggtHsDgqO8Z(PzO8ygvUvqPAQscuMuOKmNhk24Ra(UyHYNauQPIp2kgkTORyty5j7SXDtgkTbkT8KD24UjdL2aLyugk5LmyRXnuQ4TYWdLDy45gkn8XcLhJXRLHckToO4HYlhgEQabQsQrrAGajJ66WZrBinq6(cPbcK34R4lsheiPtJ7mqGFmVxqg11HNJ2euliabLfaLfcL1GslpzNnUBYq5dOSICrGbXYzrGe8rUu34DjHrgs3YqAGa5n(k(I0bbs604odeO(q5hZ7fhPsfTB8oFput08zKlfkFaakRixO8PqP(q5lOeyOKmJ6o4wHVhQHtR(K68yTwIMJRwqPEqzPsq5hZ7fhPsfTB8oFput08zKlfkFaLn2YclpzNnU6Hs9GYAq5hZ7fhPsfTB8oFputGDGadILZIaj4JCPUX7scJmKU1J0abYB8v8fPdcK0PXDgiWpM3losLkA34D(EOMO5Zixku(aklgqznO8J59cSf)O0YrTM3kdVO5Zixku(akRixO8PqP(q5lOeyOKmJ6o4wHVhQHtR(K68yTwIMJRwqPEqznO8J59cSf)O0YrTM3kdVO5Zixkuwdk)yEV4ivQODJ357HAcSdeyqSCweibFKl1nExsyKHme48vPXDy5Sinq6(cPbcK34R4lsheiPtJ7mqGwO41evHHN7CRCuB6tbVXxXxeyqSCweyZNttzftPoC5ACJmKULH0abYB8v8fPdcK0PXDgiq9HYl)X8Erh1nDsyb1ccqq5dOSqOSujO8YFmVx0rDtNew08zKlfkFaLVkhk1dkRbLpdLwO41e(EOgLOLHNf8gFfFHYAq5Zq5hZ7fDEYcSdOSguspyLYzrxXgvGFWPYTY9vb1GYcaaL1JadILZIaNVknUdJrgs36rAGa5n(k(I0bbs604ode4ZqPfkEnHVhQrjAz4zbVXxXxOSgu(mu(X8ErNNSa7akRbL0dwPCw0vSrf4hCQCRCFvqnOSaaqz9iWGy5SiW5RsJ7WyKH0T4inqG8gFfFr6GajDACNbcuFO8J59cGsLk3k3zqWNllAoiguwQeuQpu(X8EbqPsLBL7mi4ZLfyhqznOuFO8Ozn7QixXlHVhQ5OwNaXqzPsq5rZA2vrUIxc8dovUvUVkOguwQeuE0SMDvKR4LOsfKmuU4Q5yjmuQhuQhuQhuwdkPhSs5SORyJk89qnkrldpdLfaakldbgelNfb67HAuIwgEgziDlePbcK34R4lsheiPtJ7mqG6dLx(J59IoQB6KWcQfeGGYhqzHqzPsq5L)yEVOJ6MojSO5Zixku(akFvouQhuwdk)yEVaOuPYTYDge85YIMdIbLLkbL6dLFmVxauQu5w5odc(Czb2buwdk1hkpAwZUkYv8s47HAoQ1jqmuwQeuE0SMDvKR4La)GtLBL7RcQbLLkbLhnRzxf5kEjQubjdLlUAowcdL6bL6HadILZIaNVknUdJrgs3NisdeiVXxXxKoiqsNg3zGa)yEVaOuPYTYDge85YIMdIbLLkbL6dLFmVxauQu5w5odc(Czb2buwdk1hkpAwZUkYv8s47HAoQ1jqmuwQeuE0SMDvKR4La)GtLBL7RcQbLLkbLhnRzxf5kEjQubjdLlUAowcdL6bL6HadILZIaNVknUdJrgsxnrKgiqEJVIViDqGKonUZabQpu(mu(X8ErNNSa7aklvckBSnjUJbh3Il7tsAq5dO8v5qzPsqzJTSWYt2zJRmOSaOSICHs9GYAqj9GvkNfDfBurLkizOCXvZXsyOSaaqzziWGy5SiWkvqYq5IRMJLWidPBXaPbcK34R4lsheiPtJ7mqGFmVx05jlWoGYAqj9GvkNfDfBub(bNk3k3xfudklaauwgcmiwolce)GtLBL7RcQHmKUAsKgiqEJVIViDqGKonUZabQpuE5pM3l6OUPtclOwqackFaLfcLLkbLx(J59IoQB6KWIMpJCPq5dO8v5qPEqznO8zO8J59Iopzb2buwQeu2yBsChdoUfx2NK0GYhq5RYHYsLGYgBzHLNSZgxzqzbqzf5cL1GYNHslu8AcFpuJs0YWZcEJVIViWGy5SiqFpuZrTobIrgs3xLJ0abYB8v8fPdcK0PXDgiWNHYpM3l68KfyhqzPsqzJTjXDm44wCzFssdkFaLVkhklvckBSLfwEYoBCLbLfaLvKlcmiwolc03d1CuRtGyKH091lKgiqEJVIViDqGKonUZab(X8ErNNSa7abgelNfbIFWPYTY9vb1qgs3xLH0abYB8v8fPdcK0PXDgiq9HYl)X8Erh1nDsyb1ccqq5dOSqOSujO8YFmVx0rDtNew08zKlfkFaLVkhk1dkRbLpdLwO41e(EOgLOLHNf8gFfFrGbXYzrGZxLg3HXidP7R6rAGadILZIaNVknUdJrG8gFfFr6GmKHaPwS3OVinq6(cPbcmiwolcS5ZPPSIPuhUCnUrG8gFfFr6GmKULH0abYB8v8fPdcK0PXDgiqYmQ7GBfnFonLvmL6WLRXTO5Zixku(aauwgu(uOSICHYAqPfkEnrvy45o3kh1M(uWB8v8fbgelNfb67HAoQ1jqmYq6wpsdeiVXxXxKoiqsNg3zGa)yEVOZtwGDGadILZIaXp4u5w5(QGAidPBXrAGa5n(k(I0bbs604ode4Zq5hZ7f(EQJx3bMIYcSdOSguAHIxt47PoEDhykkl4n(k(IadILZIaNVknUdJrgs3crAGa5n(k(I0bbs604odeyJTjXDm44wCzFssdkFaL6dLVkekbgkTqXRjASnjUWmEXclNvWB8v8fkFkuwpuQhcmiwolc03d1CuRtGyKH09jI0abYB8v8fPdcK0PXDgiWpM3lakvQCRCNbbFUSa7akRbLn2YclpzNnUIdLfaakRixeyqSCweOVhQrjAz4zKH0vtePbcK34R4lsheiPtJ7mqGn2Me3XGJBXL9jjnOSaOuFOSScHsGHslu8AIgBtIlmJxSWYzf8gFfFHYNcL1dL6HadILZIaNVknUdJrgs3IbsdeyqSCweOVhQ5OwNaXiqEJVIViDqgsxnjsdeyqSCwei(Px34D4Y14gbYB8v8fPdYq6(QCKgiWGy5SiWOjXYoB6MxdbYB8v8fPdYqgc8pu3XmQCRqAG09fsdeiVXxXxKoiqsNg3zGa)yEVOZtwGDGadILZIaXp4u5w5(QGAidPBzinqG8gFfFr6GajDACNbcuFO8YFmVx0rDtNewqTGaeu(akleklvckV8hZ7fDu30jHfnFg5sHYhq5RYHs9GYAqzJTSWYt2zJR4q5dOSICHYAqzJTjXDm44wCzFssdklaauwwHqznO8zO0cfVMW3d1OeTm8SG34R4lcmiwolcC(Q04omgziDRhPbcK34R4lsheiPtJ7mqGn2YclpzNnUIdLpGYkYfkRbLn2Me3XGJBXL9jjnOSaaqzzfIadILZIaNVknUdJrgs3IJ0abYB8v8fPdcK0PXDgiWgBtI7yWXT4Y(KKgu(aklRCOSgusMrDhCR4ivQODJ357HAIMpJCPqzbqzJTSWYt2zJR4qznOKEWkLZIUInQOsfKmuU4Q5yjmuwaaOSmeyqSCweyLkizOCXvZXsyKH0TqKgiqEJVIViDqGKonUZabQpuE5pM3l6OUPtclOwqackFaLfcLLkbLx(J59IoQB6KWIMpJCPq5dO8v5qPEqznOSX2K4ogCClUSpjPbLpGYYkhkRbLKzu3b3kosLkA34D(EOMO5Zixkuwau2yllS8KD24kouwdkFgkTqXRj89qnkrldpl4n(k(IadILZIa99qnh16eigziDFIinqG8gFfFr6GajDACNbcSX2K4ogCClUSpjPbLpGYYkhkRbLKzu3b3kosLkA34D(EOMO5Zixkuwau2yllS8KD24kocmiwolc03d1CuRtGyKH0vtePbcK34R4lsheiPtJ7mqGFmVxauQu5w5odc(Czb2buwdkBSnjUJbh3Il7tsAqzbqP(q5RcHsGHslu8AIgBtIlmJxSWYzf8gFfFHYNcL1dL6bL1Gs6bRuol6k2OcFpuJs0YWZqzbaGYYqGbXYzrG(EOgLOLHNrgs3IbsdeiVXxXxKoiqsNg3zGaBSnjUJbh3Il7tsAqzbaGs9HY6lekbgkTqXRjASnjUWmEXclNvWB8v8fkFkuwpuQhuwdkPhSs5SORyJk89qnkrldpdLfaakldbgelNfb67HAuIwgEgziD1KinqG8gFfFr6GajDACNbcuFO8YFmVx0rDtNewqTGaeu(akleklvckV8hZ7fDu30jHfnFg5sHYhq5RYHs9GYAqzJTjXDm44wCzFssdklaauQpuwFHqjWqPfkEnrJTjXfMXlwy5ScEJVIVq5tHY6Hs9GYAq5ZqPfkEnHVhQrjAz4zbVXxXxeyqSCwe48vPXDymYq6(QCKgiqEJVIViDqGKonUZab2yBsChdoUfx2NK0GYcaaL6dL1xiucmuAHIxt0yBsCHz8IfwoRG34R4lu(uOSEOupeyqSCwe48vPXDymYq6(6fsdeiVXxXxKoiqsNg3zGajZOUdUvCKkv0UX789qnrZNrUuOSaOSXwwy5j7SXvCOSgu2yBsChdoUfx2NK0GYhqzXlhkRbL0dwPCw0vSrfvQGKHYfxnhlHHYcaaLLHadILZIaRubjdLlUAowcJmKUVkdPbcK34R4lsheiPtJ7mqG6dLx(J59IoQB6KWcQfeGGYhqzHqzPsq5L)yEVOJ6MojSO5Zixku(akFvouQhuwdkjZOUdUvCKkv0UX789qnrZNrUuOSaOSXwwy5j7SXvCOSgu2yBsChdoUfx2NK0GYhqzXlhkRbLpdLwO41e(EOgLOLHNf8gFfFrGbXYzrG(EOMJADceJmKUVQhPbcK34R4lsheiPtJ7mqGKzu3b3kosLkA34D(EOMO5Zixkuwau2yllS8KD24kouwdkBSnjUJbh3Il7tsAq5dOS4LJadILZIa99qnh16eigzidbE0mzo)HH0aP7lKgiqEJVIViDqgs3YqAGa5n(k(I0bziDRhPbcK34R4lshKH0T4inqG8gFfFr6GmKUfI0abgelNfbEmwolcK34R4lshKHmeymmsdKUVqAGa5n(k(I0bbs604odeOfkEnrvy45o3kh1M(uWB8v8fklvck1hkJ64onw47PoEDgFEWut0XceuwdkPhSs5SORyJkA(CAkRyk1HlxJBOSaaqz9qznO8zO8J59Iopzb2buQhcmiwolcS5ZPPSIPuhUCnUrgs3YqAGa5n(k(I0bbs604odeOfkEnHVhQrjAz4zbVXxXxeyqSCweyLkizOCXvZXsyKH0TEKgiqEJVIViDqGKonUZabQpuE5pM3l6OUPtclOwqackFaLfcLLkbLx(J59IoQB6KWIMpJCPq5dO8v5qPEqznOKmJ6o4wrZNttzftPoC5AClA(mYLcLpaaLLbLpfkRixOSguAHIxtufgEUZTYrTPpf8gFfFHYAq5ZqPfkEnHVhQrjAz4zbVXxXxeyqSCweOVhQ5OwNaXidPBXrAGa5n(k(I0bbs604odeizg1DWTIMpNMYkMsD4Y14w08zKlfkFaakldkFkuwrUqznO0cfVMOkm8CNBLJAtFk4n(k(IadILZIa99qnh16eigziDlePbcK34R4lsheiPtJ7mqGFmVx05jlWoqGbXYzrG4hCQCRCFvqnKH09jI0abYB8v8fPdcK0PXDgiWpM3lakvQCRCNbbFUSa7abgelNfb67HAuIwgEgziD1erAGa5n(k(I0bbs604odeyJTjXDm44wCzFssdkFaL6dLVkekbgkTqXRjASnjUWmEXclNvWB8v8fkFkuwpuQhcmiwolcSsfKmuU4Q5yjmYq6wmqAGa5n(k(I0bbs604odeO(q5L)yEVOJ6MojSGAbbiO8buwiuwQeuE5pM3l6OUPtclA(mYLcLpGYxLdL6bL1GYgBtI7yWXT4Y(KKgu(ak1hkFviucmuAHIxt0yBsCHz8IfwoRG34R4lu(uOSEOupOSgu(muAHIxt47HAuIwgEwWB8v8fbgelNfb67HAoQ1jqmYq6QjrAGa5n(k(I0bbs604odeyJTjXDm44wCzFssdkFaL6dLVkekbgkTqXRjASnjUWmEXclNvWB8v8fkFkuwpuQhcmiwolc03d1CuRtGyKH09v5inqGbXYzrGnFonLvmL6WLRXncK34R4lshKH091lKgiWGy5SiqFpuJs0YWZiqEJVIViDqgs3xLH0abYB8v8fPdcK0PXDgiq9HYl)X8Erh1nDsyb1ccqq5dOSqOSujO8YFmVx0rDtNew08zKlfkFaLVkhk1dkRbLn2Me3XGJBXL9jjnOSaOuFOSScHsGHslu8AIgBtIlmJxSWYzf8gFfFHYNcL1dL6bL1GYNHslu8AcFpuJs0YWZcEJVIViWGy5SiW5RsJ7WyKH09v9inqG8gFfFr6GajDACNbcSX2K4ogCClUSpjPbLfaL6dLLviucmuAHIxt0yBsCHz8IfwoRG34R4lu(uOSEOupeyqSCwe48vPXDymYq6(Q4inqGbXYzrGvQGKHYfxnhlHrG8gFfFr6GmKUVkePbcK34R4lsheiPtJ7mqG6dLx(J59IoQB6KWcQfeGGYhqzHqzPsq5L)yEVOJ6MojSO5Zixku(akFvouQhuwdkFgkTqXRj89qnkrldpl4n(k(IadILZIa99qnh16eigziDF9erAGadILZIa99qnh16eigbYB8v8fPdYq6(stePbcmiwolce)0RB8oC5ACJa5n(k(I0bziDFvmqAGadILZIaJMel7SPBEneiVXxXxKoidziW)qDwsak3kKgiDFH0abYB8v8fPdcK0PXDgiqYmQ7GBf85XGJBxJTSdhhhZkA(mYLIadILZIapsLkA34D(EOgYq6wgsdeyqSCweiFEm4421yl7WXXXSiqEJVIViDqgs36rAGa5n(k(I0bbs604odeO(q5L)yEVOJ6MojSGAbbiO8buwiuwQeuE5pM3l6OUPtclA(mYLcLpGYxLdL6bL1GYgBtI7yWXnu(aauwF5qznO8zO0cfVMW3d1OeTm8SG34R4lcmiwolcC(Q04omgziDlosdeiVXxXxKoiqsNg3zGaBSnjUJbh3q5daqz9LJadILZIaNVknUdJrgs3crAGa5n(k(I0bbs604odeOfkEnrvy45o3kh1M(uWB8v8fbgelNfb2850uwXuQdxUg3idP7tePbcK34R4lsheiPtJ7mqGFmVx05jlWoqGbXYzrG4hCQCRCFvqnKH0vtePbcK34R4lsheiPtJ7mqG6dLx(J59IoQB6KWcQfeGGYhqzHqzPsq5L)yEVOJ6MojSO5Zixku(akFvouQhuwdkBSLfwEYoBCfcLpGYkYfklvckBSnjUJbh3q5daqzXlekRbLpdLwO41e(EOgLOLHNf8gFfFrGbXYzrGZxLg3HXidPBXaPbcK34R4lsheiPtJ7mqGn2YclpzNnUcHYhqzf5cLLkbLn2Me3XGJBO8baOS4fIadILZIaNVknUdJrgsxnjsdeiVXxXxKoiqsNg3zGa)yEVaOuPYTYDge85YcSdOSguspyLYzrxXgv47HAuIwgEgklaauwgcmiwolc03d1OeTm8mYq6(QCKgiqEJVIViDqGKonUZab2yBsChdoUfx2NK0GYcaaL1xouwdkBSLfwEYoBC1dLfaLvKlcmiwolce)0RB8oC5ACJmKUVEH0abgelNfb2850uwXuQdxUg3iqEJVIViDqgs3xLH0abYB8v8fPdcK0PXDgiq6bRuol6k2OcFpuJs0YWZqzbaGYYqGbXYzrG(EOgLOLHNrgs3x1J0abYB8v8fPdcK0PXDgiq9HYl)X8Erh1nDsyb1ccqq5dOSqOSujO8YFmVx0rDtNew08zKlfkFaLVkhk1dkRbLn2Me3XGJBXL9jjnOSaOSScHYsLGYgBzOSaOSEOSgu(muAHIxt47HAuIwgEwWB8v8fbgelNfboFvAChgJmKUVkosdeiVXxXxKoiqsNg3zGaBSnjUJbh3Il7tsAqzbqzzfcLLkbLn2Yqzbqz9iWGy5SiW5RsJ7WyKH09vHinqG8gFfFr6GajDACNbcSX2K4ogCClUSpjPbLfaLLvocmiwolcmAsSSZMU51qgYqGx2hykdPbs3xinqGbXYzrGN5ED(M56yeiVXxXxKoidPBzinqG8gFfFr6GajDACNbc8zO8oMW3d1CEwZClSKauUvqznOuFO8zO0cfVM43Cy4DJ3rZ92r1qdbVXxXxOSujOKmJ6o4wXV5WW7gVJM7TJQHgIMpJCPqzbq5RcHs9qGbXYzrG4hCQCRCFvqnKH0TEKgiqEJVIViDqGKonUZab(X8Ers0YzHAwQO5Zixku(aauwrUqznO8J59IKOLZc1Sub2buwdkPhSs5SORyJkQubjdLlUAowcdLfaakldkRbL6dLpdLwO41e)MddVB8oAU3oQgAi4n(k(cLLkbLKzu3b3k(nhgE34D0CVDun0q08zKlfklakFviuQhcmiwolcSsfKmuU4Q5yjmYq6wCKgiqEJVIViDqGKonUZab(X8Ers0YzHAwQO5Zixku(aauwrUqznO8J59IKOLZc1Sub2buwdk1hkFgkTqXRj(nhgE34D0CVDun0qWB8v8fklvckjZOUdUv8Bom8UX7O5E7OAOHO5Zixkuwau(QqOupeyqSCweOVhQ5OwNaXidPBHinqG8gFfFr6GadILZIajHs5cILZ6uj1qGQKAUnozeizg1DWTuKH09jI0abYB8v8fPdcK0PXDgiqlu8AIFZHH3nEhn3Bhvdne8gFfFHYAqP(qjzg1DWTIFZHH3nEhn3BhvdnenFg5sHYhqzHqzPsqP(qjzg1DWTIFZHH3nEhn3BhvdnenFg5sHYhqzzLdL1GslpzNnUBYq5dOS(cHs9Gs9qGbXYzrGn26cILZ6uj1qGQKAUnoze4FOUJzu5wHmKUAIinqG8gFfFr6GajDACNbc8oM43Cy4DJ3rZ92r1qdHLeGYTcbgelNfb2yRliwoRtLudbQsQ524KrG)H6SKauUvidPBXaPbcK34R4lsheiPtJ7mqGFmVxCKkv0UX789qnb2buwdkTqXRjMVknUdlNvWB8v8fbgelNfb2yRliwoRtLudbQsQ524KrGZxLg3HLZImKUAsKgiqEJVIViDqGKonUZabgel1m74LptMcLfaakldbgelNfb2yRliwoRtLudbQsQ524KrGXWidP7RYrAGa5n(k(I0bbgelNfbscLYfelN1PsQHavj1CBCYiqQf7n6lYqgcKmJ6o4wksdKUVqAGa5n(k(I0bbs604odeO(qjzg1DWTIJuPI2nENVhQjAoUAbLLkbLKzu3b3kosLkA34D(EOMO5Zixkuwauww5qPEqznOuFO8zO0cfVM43Cy4DJ3rZ92r1qdbVXxXxOSujOKmJ6o4wbFEm4421yl7WXXXSIMpJCPqzbqPMSqOupeyqSCweigLDPXNuKH0TmKgiqEJVIViDqGbXYzrGv9Svu3rNNHY1rfJajDACNbcSXwgkFaakRhkRbLpdLFmVxCKkv0UX789qnb2buwdk1hkFgkVJj(nhgE34D0CVDun0qyjbOCRGYsLGYNHslu8AIFZHH3nEhn3Bhvdne8gFfFHs9qGBCYiWQE2kQ7OZZq56OIrgs36rAGa5n(k(I0bbUXjJa7OUl2ce19ZkxZx3hZSzrGbXYzrGDu3fBbI6(zLR5R7Jz2SidPBXrAGa5n(k(I0bbgelNfbEYndKHpOoFSviqsNg3zGaFgkVJj(nhgE34D0CVDun0qyjbOCRGYAq5Zq5hZ7fhPsfTB8oFputGDGa34KrGNCZaz4dQZhBfYq6wisdeiVXxXxKoiqsNg3zGa)yEV4ivQODJ357HAcSdOSgu(X8EbFEm4421yl7WXXXScSdeyqSCwe4Xy5SidP7tePbcK34R4lsheiPtJ7mqGFmVxCKkv0UX789qnb2buwdk)yEVGppgCC7ASLD444ywb2bcmiwolc8RM568yTwidPRMisdeiVXxXxKoiqsNg3zGa)yEV4ivQODJ357HAcSdeyqSCwe4NBk3aLBfYq6wmqAGa5n(k(I0bbs604odeizg1DWTc(8yWXTRXw2HJJJzfnFg5srGbXYzrGhPsfTB8oFpudziD1KinqG8gFfFr6GajDACNbcKmJ6o4wbFEm4421yl7WXXXSIMpJCPqznOKmJ6o4wXrQur7gVZ3d1enFg5srGbXYzrG)MddVB8oAU3oQgAGaXOSB8Exf5IaFHmKUVkhPbcK34R4lsheiPtJ7mqGKzu3b3kosLkA34D(EOMO54QfuwdkFgkTqXRj(nhgE34D0CVDun0qWB8v8fkRbLn2YclpzNnUcHYcGYkYfkRbLn2Me3XGJBXL9jjnOSaaq5RYrGbXYzrG85XGJBxJTSdhhhZImKUVEH0abYB8v8fPdcK0PXDgiq9HsYmQ7GBfhPsfTB8oFput0CC1cklvckT8KD24UjdLpGYYkhk1dkRbLwO41e)MddVB8oAU3oQgAi4n(k(cL1GYgBzOSaaqz9qznOSX2K4ogCCdLfaLpXYrGbXYzrG85XGJBxJTSdhhhZImKUVkdPbcK34R4lsheiPtJ7mqGwO41eKrDD45OnbVXxXxOSguQpuQpu(X8EbzuxhEoAtqTGaeuwaaO8v5qznO8YFmVx0rDtNewqTGaeucaklek1dklvckT8KD24UjdLpaaLvKluQhcmiwolcKekLliwoRtLudbQsQ524KrGKrDD45OnKH09v9inqG8gFfFr6GajDACNbcuFO8J59IJuPI2nENVhQjA(mYLcLpaaLvKluwQeuQpu(X8EXrQur7gVZ3d1enFg5sHYhqzXakRbLFmVxGT4hLwoQ18wz4fnFg5sHYhaGYkYfkRbLFmVxGT4hLwoQ18wz4fyhqPEqPEqznO8J59IJuPI2nENVhQjWoqGbXYzrG(EOgoT6tQZJ1AHmKUVkosdeiVXxXxKoiqsNg3zGaT8KD24UjdLpGYkYfklvck1hkT8KD24UjdLpGsYmQ7GBfhPsfTB8oFput08zKlfkRbLFmVxGT4hLwoQ18wz4fyhqPEiWGy5SiqFpudNw9j15XATqgYqgcuZCtZzr6ww5V0KLx8Ykt8Q8xfdeiUO3CROiWNSZJPn(cLAsOmiwoluQsQrfW3iq6btq6wwHVqGh94tfJalwOut3d1GsnfCy4HYIjBwH3GVlwOeVzhunbT1Ukn8yFbzo1MMNyQWYzjD4nTP5jrB47IfklMp6ubLLvwrqzzL)stcLpbO8v5Ac1xp8n8DXcLAQ4JTIPAcW3flu(eGYNSLOWUmuQPuUxOut3mxhlGVlwO8jaLfZ3lu6dL6heGGs)0qjgn3kO8jTy6tIIGYN8rtdLPhkpuHwCdL5MwggtHsDgqO8Z(PzO8ygvUvqPAQscuMuOKmNhk24Ra(UyHYNauQPIp2kgkTORyty5j7SXDtgkTbkT8KD24UjdL2aLyugk5LmyRXnuQ4TYWdLDy45gkn8XcLhJXRLHckToO4HYlhgEQa(g(UyHYN0NKmbZ4lu(z)0musMZFyq5NRYLkGYIzcHpmkuUZ(eWh9PhtbLbXYzPq5SkTeW3bXYzPIJMjZ5pmaEvqbc(oiwolvC0mzo)HbmaT9ZCHVdILZsfhntMZFyadq7aR6KxlSCw47Ifkb34GIFmOSJ8cLFmVNVqj1cJcLF2pndLK58hgu(5QCPqzSxO8O5NWXywUvqzsHY7SSa(oiwolvC0mzo)HbmaTPBCqXpMJAHrHVdILZsfhntMZFyadq7JXYzHVHVlwO8j9jjtWm(cLSM5wlO0Ytgkn8mugeBAOmPqzO5ivXxXc47Gy5SuaN5ED(M56y47IfklMpouAbLA6EOguQPznZnug7fkpJCTixO8jJOfuQrOMLcFhelNLcmaTXp4u5w5(QGAfLEapFht47HAopRzUfwsak3QA6)SfkEnXV5WW7gVJM7TJQHgcEJVIVLkrMrDhCR43Cy4DJ3rZ92r1qdrZNrU0cEvOEW3bXYzPadq7kvqYq5IRMJLWfLEaFmVxKeTCwOMLkA(mYL(aqf5w7J59IKOLZc1Sub2rn6bRuol6k2OIkvqYq5IRMJLWfaOSA6)SfkEnXV5WW7gVJM7TJQHgcEJVIVLkrMrDhCR43Cy4DJ3rZ92r1qdrZNrU0cEvOEW3bXYzPadqBFpuZrTobIlk9a(yEVijA5Sqnlv08zKl9bGkYT2hZ7fjrlNfQzPcSJA6)SfkEnXV5WW7gVJM7TJQHgcEJVIVLkrMrDhCR43Cy4DJ3rZ92r1qdrZNrU0cEvOEW3bXYzPadqBsOuUGy5SovsTI24KbqMrDhClf(oiwolfyaA3yRliwoRtLuROnoza)H6oMrLBvrPhGfkEnXV5WW7gVJM7TJQHgcEJVIV10NmJ6o4wXV5WW7gVJM7TJQHgIMpJCPpkSuj9jZOUdUv8Bom8UX7O5E7OAOHO5Zix6JYkVMLNSZg3n5h1xOE6bFhelNLcmaTBS1felN1PsQv0gNmG)qDwsak3QIspG7yIFZHH3nEhn3Bhvdnewsak3k47Gy5SuGbODJTUGy5SovsTI24KbmFvAChwoBrPhWhZ7fhPsfTB8oFputGDuZcfVMy(Q04oSCwbVXxXx47Gy5SuGbODJTUGy5SovsTI24Kbedxu6beel1m74LptMwaGYGVdILZsbgG2KqPCbXYzDQKAfTXjdGAXEJ(cFdFhelNLkIHb0850uwXuQdxUg3fLEawO41evHHN7CRCuB6tbVXxX3sL0pQJ70yHVN641z85btnrhlq1OhSs5SORyJkA(CAkRyk1HlxJ7cauFTN)yEVOZtwGDOh8DqSCwQiggyaAxPcsgkxC1CSeUO0dWcfVMW3d1OeTm8SG34R4l8DqSCwQiggyaA77HAoQ1jqCrw0vS5spa9V8hZ7fDu30jHfulia9OWsLU8hZ7fDu30jHfnFg5sF8QC9QrMrDhCRO5ZPPSIPuhUCnUfnFg5sFaOSNwrU1SqXRjQcdp35w5O20NcEJVIV1E2cfVMW3d1OeTm8SG34R4l8DqSCwQiggyaA77HAoQ1jqCrPhazg1DWTIMpNMYkMsD4Y14w08zKl9bGYEAf5wZcfVMOkm8CNBLJAtFk4n(k(cFhelNLkIHbgG24hCQCRCFvqTIspGpM3l68KfyhW3bXYzPIyyGbOTVhQrjAz45IspGpM3lakvQCRCNbbFUSa7a(oiwolveddmaTRubjdLlUAowcxu6b0yBsChdoUfx2NK0EO)Rcb2cfVMOX2K4cZ4flSCwbVXxX3NwVEW3bXYzPIyyGbOTVhQ5OwNaXfzrxXMl9a0)YFmVx0rDtNewqTGa0Jclv6YFmVx0rDtNew08zKl9XRY1RwJTjXDm44wCzFss7H(Vkeylu8AIgBtIlmJxSWYzf8gFfFFA96v7zlu8AcFpuJs0YWZcEJVIVW3bXYzPIyyGbOTVhQ5OwNaXfLEan2Me3XGJBXL9jjTh6)QqGTqXRjASnjUWmEXclNvWB8v89P1Rh8DqSCwQiggyaA3850uwXuQdxUg3W3bXYzPIyyGbOTVhQrjAz4z47Gy5SurmmWa0E(Q04omUil6k2CPhG(x(J59IoQB6KWcQfeGEuyPsx(J59IoQB6KWIMpJCPpEvUE1ASnjUJbh3Il7tsAfOFzfcSfkEnrJTjXfMXlwy5ScEJVIVpTE9Q9SfkEnHVhQrjAz4zbVXxXx47Gy5SurmmWa0E(Q04omUO0dOX2K4ogCClUSpjPvG(LviWwO41en2MexygVyHLZk4n(k((061d(oiwolveddmaTRubjdLlUAowcdFhelNLkIHbgG2(EOMJADcexKfDfBU0dq)l)X8Erh1nDsyb1ccqpkSuPl)X8Erh1nDsyrZNrU0hVkxVApBHIxt47HAuIwgEwWB8v8f(oiwolveddmaT99qnh16eig(oiwolveddmaTXp96gVdxUg3W3bXYzPIyyGbOD0KyzNnDZRbFdFxSqPonhgEOC8qjyU3oQgAaLhZOYTck7XclNfk1eGsQfTrHYYkNcLF2pndLp5PsfnuoEOut3d1GsGHsDgqOmAgkdnhPk(kg(oiwolv8hQ7ygvUvaWp4u5w5(QGAfLEaFmVx05jlWoGVdILZsf)H6oMrLBfWa0E(Q04omUil6k2CPhG(x(J59IoQB6KWcQfeGEuyPsx(J59IoQB6KWIMpJCPpEvUE1ASLfwEYoBCf)rf5wRX2K4ogCClUSpjPvaGYkS2ZwO41e(EOgLOLHNf8gFfFHVdILZsf)H6oMrLBfWa0E(Q04omUO0dOXwwy5j7SXv8hvKBTgBtI7yWXT4Y(KKwbakRq47Gy5SuXFOUJzu5wbmaTRubjdLlUAowcxu6b0yBsChdoUfx2NK0Euw51iZOUdUvCKkv0UX789qnrZNrU0cASLfwEYoBCfVg9GvkNfDfBurLkizOCXvZXs4caug8DqSCwQ4pu3XmQCRagG2(EOMJADcexKfDfBU0dq)l)X8Erh1nDsyb1ccqpkSuPl)X8Erh1nDsyrZNrU0hVkxVAn2Me3XGJBXL9jjThLvEnYmQ7GBfhPsfTB8oFput08zKlTGgBzHLNSZgxXR9SfkEnHVhQrjAz4zbVXxXx47Gy5SuXFOUJzu5wbmaT99qnh16eiUO0dOX2K4ogCClUSpjP9OSYRrMrDhCR4ivQODJ357HAIMpJCPf0yllS8KD24ko8DqSCwQ4pu3XmQCRagG2(EOgLOLHNlk9a(yEVaOuPYTYDge85YcSJAn2Me3XGJBXL9jjTc0)vHaBHIxt0yBsCHz8IfwoRG34R47tRxVA0dwPCw0vSrf(EOgLOLHNlaqzW3bXYzPI)qDhZOYTcyaA77HAuIwgEUO0dOX2K4ogCClUSpjPvaa9RVqGTqXRjASnjUWmEXclNvWB8v89P1Rxn6bRuol6k2OcFpuJs0YWZfaOm47Gy5SuXFOUJzu5wbmaTNVknUdJlYIUInx6bO)L)yEVOJ6MojSGAbbOhfwQ0L)yEVOJ6MojSO5Zix6JxLRxTgBtI7yWXT4Y(KKwba0V(cb2cfVMOX2K4cZ4flSCwbVXxX3NwVE1E2cfVMW3d1OeTm8SG34R4l8DqSCwQ4pu3XmQCRagG2ZxLg3HXfLEan2Me3XGJBXL9jjTcaOF9fcSfkEnrJTjXfMXlwy5ScEJVIVpTE9GVdILZsf)H6oMrLBfWa0UsfKmuU4Q5yjCrPhazg1DWTIJuPI2nENVhQjA(mYLwqJTSWYt2zJR41ASnjUJbh3Il7tsApkE51OhSs5SORyJkQubjdLlUAowcxaGYGVdILZsf)H6oMrLBfWa023d1CuRtG4ISORyZLEa6F5pM3l6OUPtclOwqa6rHLkD5pM3l6OUPtclA(mYL(4v56vJmJ6o4wXrQur7gVZ3d1enFg5slOXwwy5j7SXv8An2Me3XGJBXL9jjThfV8ApBHIxt47HAuIwgEwWB8v8f(oiwolv8hQ7ygvUvadqBFpuZrTobIlk9aiZOUdUvCKkv0UX789qnrZNrU0cASLfwEYoBCfVwJTjXDm44wCzFss7rXlh(g(UyHsnDOu)GaeuAduIrzO8jF00fbLpPftFsaL4WZluIr5(jKBAzymfk1zaHYJMpddRzLwc47Gy5SuXFOoljaLBfGJuPI2nENVhQvu6bqMrDhCRGppgCC7ASLD444ywrZNrUu47Gy5SuXFOoljaLBfWa0MppgCC7ASLD444yw4B47Ifk1uW(atzqjyEQPcL)H6SKauUvqPFuQbhvaFhelNLk(d1zjbOCRagG2ZxLg3HXfzrxXMl9a0)YFmVx0rDtNewqTGa0Jclv6YFmVx0rDtNew08zKl9XRY1RwJTjXDm44(bG6lV2ZwO41e(EOgLOLHNf8gFfFHVdILZsf)H6SKauUvadq75RsJ7W4IspGgBtI7yWX9da1xo8DqSCwQ4puNLeGYTcyaA3850uwXuQdxUg3fLEawO41evHHN7CRCuB6tbVXxXx47Gy5SuXFOoljaLBfWa0g)GtLBL7RcQvu6b8X8ErNNSa7a(oiwolv8hQZscq5wbmaTNVknUdJlYIUInx6bO)L)yEVOJ6MojSGAbbOhfwQ0L)yEVOJ6MojSO5Zix6JxLRxTgBzHLNSZgxHpQi3sLASnjUJbh3pau8cR9SfkEnHVhQrjAz4zbVXxXx47Gy5SuXFOoljaLBfWa0E(Q04omUO0dOXwwy5j7SXv4JkYTuPgBtI7yWX9dafVq47Gy5SuXFOoljaLBfWa023d1OeTm8CrPhWhZ7faLkvUvUZGGpxwGDuJEWkLZIUInQW3d1OeTm8Cbakd(oiwolv8hQZscq5wbmaTXp96gVdxUg3fLEan2Me3XGJBXL9jjTcauF51ASLfwEYoBC1xqf5cFhelNLk(d1zjbOCRagG2nFonLvmL6WLRXn8DqSCwQ4puNLeGYTcyaA77HAuIwgEUO0dGEWkLZIUInQW3d1OeTm8Cbakd(oiwolv8hQZscq5wbmaTNVknUdJlYIUInx6bO)L)yEVOJ6MojSGAbbOhfwQ0L)yEVOJ6MojSO5Zix6JxLRxTgBtI7yWXT4Y(KKwbLvyPsn2YfuFTNTqXRj89qnkrldpl4n(k(cFhelNLk(d1zjbOCRagG2ZxLg3HXfLEan2Me3XGJBXL9jjTckRWsLASLlOE47Gy5SuXFOoljaLBfWa0oAsSSZMU51kk9aASnjUJbh3Il7tsAfuw5W3W3fluQPoQluINJ2GsYS30YzPW3bXYzPcYOUo8C0gac(ixQB8UKWfLEaFmVxqg11HNJ2euliavqH1S8KD24Uj)OICHVdILZsfKrDD45OnGbOnbFKl1nExs4Ispa9)yEV4ivQODJ357HAIMpJCPpaurUpv)xatMrDhCRW3d1WPvFsDESwlrZXvl9kv6J59IJuPI2nENVhQjA(mYL(OXwwy5j7SXvVE1(yEV4ivQODJ357HAcSd47Gy5SubzuxhEoAdyaAtWh5sDJ3LeUO0d4J59IJuPI2nENVhQjA(mYL(Oyu7J59cSf)O0YrTM3kdVO5Zix6JkY9P6)cyYmQ7GBf(EOgoT6tQZJ1AjAoUAPxTpM3lWw8Jslh1AERm8IMpJCP1(yEV4ivQODJ357HAcSd4B47Gy5Subzg1DWTuayu2LgFslk9a0NmJ6o4wXrQur7gVZ3d1enhxTkvImJ6o4wXrQur7gVZ3d1enFg5slOSY1RM(pBHIxt8Bom8UX7O5E7OAOHG34R4BPsKzu3b3k4ZJbh3UgBzhoooMv08zKlTanzH6bFhelNLkiZOUdULcmaTXOSln(SOnozav9Svu3rNNHY1rfxu6b0yl)aq91E(J59IJuPI2nENVhQjWoQP)Z3Xe)MddVB8oAU3oQgAiSKauUvLk9SfkEnXV5WW7gVJM7TJQHgcEJVIV6bFhelNLkiZOUdULcmaTXOSln(SOnozaDu3fBbI6(zLR5R7Jz2SW3bXYzPcYmQ7GBPadqBmk7sJplAJtgWj3mqg(G68Xwvu6b88DmXV5WW7gVJM7TJQHgcljaLBvTN)yEV4ivQODJ357HAcSd47Gy5Subzg1DWTuGbO9Xy5SfLEaFmVxCKkv0UX789qnb2rTpM3l4ZJbh3UgBzhoooMvGDaFhelNLkiZOUdULcmaT)QzUopwRvrPhWhZ7fhPsfTB8oFputGDu7J59c(8yWXTRXw2HJJJzfyhW3bXYzPcYmQ7GBPadq7p3uUbk3QIspGpM3losLkA34D(EOMa7a(UyHsnDpudkjZOUdULcFhelNLkiZOUdULcmaTpsLkA34D(EOwrPhazg1DWTc(8yWXTRXw2HJJJzfnFg5sHVdILZsfKzu3b3sbgG2)MddVB8oAU3oQgAuegLDJ37QixaVkk9aiZOUdUvWNhdoUDn2YoCCCmRO5ZixAnYmQ7GBfhPsfTB8oFput08zKlf(oiwolvqMrDhClfyaAZNhdoUDn2YoCCCmBrPhazg1DWTIJuPI2nENVhQjAoUAv7zlu8AIFZHH3nEhn3Bhvdne8gFfFR1yllS8KD24kSGkYTwJTjXDm44wCzFssRaaVkh(oiwolvqMrDhClfyaAZNhdoUDn2YoCCCmBrPhG(Kzu3b3kosLkA34D(EOMO54QvPswEYoBC3KFuw56vZcfVM43Cy4DJ3rZ92r1qdbVXxX3An2YfaO(An2Me3XGJ7cEILdFhelNLkiZOUdULcmaTjHs5cILZ6uj1kAJtgazuxhEoARO0dWcfVMGmQRdphTj4n(k(wtF9)yEVGmQRdphTjOwqaQaaVkV2L)yEVOJ6MojSGAbbiafQxPswEYoBC3KFaOIC1d(oiwolvqMrDhClfyaA77HA40QpPopwRvrPhG(FmVxCKkv0UX789qnrZNrU0haQi3sL0)J59IJuPI2nENVhQjA(mYL(Oyu7J59cSf)O0YrTM3kdVO5Zix6davKBTpM3lWw8Jslh1AERm8cSd90R2hZ7fhPsfTB8oFputGDaFhelNLkiZOUdULcmaT99qnCA1NuNhR1QO0dWYt2zJ7M8JkYTuj9T8KD24Uj)GmJ6o4wXrQur7gVZ3d1enFg5sR9X8Eb2IFuA5OwZBLHxGDOh8n8DXcLAk)vPXDy5Sqzpwy5SW3bXYzPI5RsJ7WYzb0850uwXuQdxUg3fLEawO41evHHN7CRCuB6tbVXxXx47Gy5SuX8vPXDy5Sadq75RsJ7W4ISORyZLEa6F5pM3l6OUPtclOwqa6rHLkD5pM3l6OUPtclA(mYL(4v56v7zlu8AcFpuJs0YWZcEJVIV1E(J59Iopzb2rn6bRuol6k2Oc8dovUvUVkOwbaQh(oiwolvmFvAChwolWa0E(Q04omUO0d4zlu8AcFpuJs0YWZcEJVIV1E(J59Iopzb2rn6bRuol6k2Oc8dovUvUVkOwbaQh(oiwolvmFvAChwolWa023d1OeTm8CrPhG(FmVxauQu5w5odc(CzrZbXkvs)pM3lakvQCRCNbbFUSa7OM(hnRzxf5kEj89qnh16eiUuPJM1SRICfVe4hCQCRCFvqTsLoAwZUkYv8suPcsgkxC1CSewp90Rg9GvkNfDfBuHVhQrjAz45caug8DqSCwQy(Q04oSCwGbO98vPXDyCrw0vS5spa9V8hZ7fDu30jHfulia9OWsLU8hZ7fDu30jHfnFg5sF8QC9Q9X8EbqPsLBL7mi4ZLfnheRuj9)yEVaOuPYTYDge85YcSJA6F0SMDvKR4LW3d1CuRtG4sLoAwZUkYv8sGFWPYTY9vb1kv6Ozn7QixXlrLkizOCXvZXsy90d(oiwolvmFvAChwolWa0E(Q04omUO0d4J59cGsLk3k3zqWNllAoiwPs6)X8EbqPsLBL7mi4ZLfyh10)Ozn7QixXlHVhQ5OwNaXLkD0SMDvKR4La)GtLBL7RcQvQ0rZA2vrUIxIkvqYq5IRMJLW6Ph8DqSCwQy(Q04oSCwGbODLkizOCXvZXs4Ispa9F(J59Iopzb2rPsn2Me3XGJBXL9jjThVkVuPgBzHLNSZgxzfurU6vJEWkLZIUInQOsfKmuU4Q5yjCbakd(oiwolvmFvAChwolWa0g)GtLBL7RcQvu6b8X8ErNNSa7Og9GvkNfDfBub(bNk3k3xfuRaaLbFhelNLkMVknUdlNfyaA77HAoQ1jqCrw0vS5spa9V8hZ7fDu30jHfulia9OWsLU8hZ7fDu30jHfnFg5sF8QC9Q98hZ7fDEYcSJsLASnjUJbh3Il7tsApEvEPsn2YclpzNnUYkOICR9SfkEnHVhQrjAz4zbVXxXx47Gy5SuX8vPXDy5SadqBFpuZrTobIlk9aE(J59Iopzb2rPsn2Me3XGJBXL9jjThVkVuPgBzHLNSZgxzfurUW3bXYzPI5RsJ7WYzbgG24hCQCRCFvqTIspGpM3l68KfyhW3bXYzPI5RsJ7WYzbgG2ZxLg3HXfzrxXMl9a0)YFmVx0rDtNewqTGa0Jclv6YFmVx0rDtNew08zKl9XRY1R2ZwO41e(EOgLOLHNf8gFfFHVdILZsfZxLg3HLZcmaTNVknUdJHVHVlwOe0I9g9fkP5wP4NGfDfBqzpwy5SW3bXYzPcQf7n6lGMpNMYkMsD4Y14g(oiwolvqTyVrFbgG2(EOMJADcexu6bqMrDhCRO5ZPPSIPuhUCnUfnFg5sFaOSNwrU1SqXRjQcdp35w5O20NcEJVIVW3bXYzPcQf7n6lWa0g)GtLBL7RcQvu6b8X8ErNNSa7a(oiwolvqTyVrFbgG2ZxLg3HXfLEap)X8EHVN641DGPOSa7OMfkEnHVN641DGPOSG34R4l8DqSCwQGAXEJ(cmaT99qnh16eiUO0dOX2K4ogCClUSpjP9q)xfcSfkEnrJTjXfMXlwy5ScEJVIVpTE9GVdILZsful2B0xGbOTVhQrjAz45IspGpM3lakvQCRCNbbFUSa7OwJTSWYt2zJR4faOICHVdILZsful2B0xGbO98vPXDyCrPhqJTjXDm44wCzFssRa9lRqGTqXRjASnjUWmEXclNvWB8v89P1Rh8DqSCwQGAXEJ(cmaT99qnh16eig(oiwolvqTyVrFbgG24NEDJ3HlxJB47Gy5Sub1I9g9fyaAhnjw2zt38Aidziea]] )


end
