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


    spec:RegisterPack( "Frost DK", 20190707.2245, [[dGuO3bqivbpsus2KiAuueNII0QGQuVcQQzrH6wajYUi6xuunmrLoMQOLjk6zaPMgqsxtuX2eLiFtucghuL05eLOwNOeY8aI7PkTprPoiuLiluu4HIsQAIajkUiuLqBuus5KajQwjq5LIsO6MajkTtkKFkkHsdfQsulvusLEkuMkfLVkkPI9IQ)sYGj1HfwSQ6XOmzL6YiBMsFwjgnu50swnuLGxdunBc3wjTBv(TIHlshhiHLl1ZHmDQUoGTdvX3PGXlkHIZlQA9QcnFry)GM)KBghBhoXnkZCFMLZnlKBwqMzMGAw6jELJ55tjowAWapwio2fRehlR1dYHAqzYIZXsJ8Ij2CZ4yObOzehdN7POSiZnFPCCaFjBwnhvRaIWR5yDyDZr1kZCo2hOeoO8J)5y7WjUrzM7ZSCUzHCZcYmZeuZspbnhlaCCtZXWQ1SEogUAVPJ)5yBcX4yzfuN16b5qnOmu44G6S4xTGZHGLvqno3trzrMB(s54a(s2SAoQwbeHxZX6W6MJQvM5qWYkOgmarEOolymuNzUpZYqnOeu)e0zrzMdemiyzfuN1JlUfcLfbblRGAqjOgu(XeaBcQbLTUnuN1AIEKKqWYkOgucQXlT3qTneIFWahQTtd1aO6wGA8IzDZ6ymuJxEYAqDzH6urKNAOUUYRWjeuNXGb1FYonb1PZiQBbQfZsXG6cb1SznvqoTLqWYkOgucQZ6Xf3cb1E0lKl9ALu(O2fb1(a1ETskFu7IGAFGAaeb10XgGZPgQf0T44G6oCCud1oU4G60XPZRqa1EhiCq9MchhsYXefYrCZ4ySrSv4OODUzCJEYnJJrx8f0MNbhJ1LtDfCSpG1kzJyRWrr7sKhmWH6SH6CG6KqTxRKYh1UiOgeOEHT5ybZR54ymCrDi1yvfJ4o3Om5MXXOl(cAZZGJX6YPUcoMjq9hWALPLqeTASkBpix20AuhcQb5fQxyBOgVHAtG6Nqn(qnBgXEmCsBpi3q(EfPSaDEztXopuBkuNibu)bSwzAjerRgRY2dYLnTg1HGAqG6g4iPxRKYhfOHAtH6Kq9hWALPLqeTASkBpixcKc1jH64rQlNKflVIvESjHSJdCOgKxOotowW8AoogdxuhsnwvXiUZnc0CZ4y0fFbT5zWXyD5uxbh7dyTY0siIwnwLThKlBAnQdb1Ga14vOoju)bSwjWHBe5viVPBXXjBAnQdb1Ga1lSnuJ3qTjq9tOgFOMnJypgoPThKBiFVIuwGoVSPyNhQnfQtc1FaRvcC4grEfYB6wCCYMwJ6qqDsO(dyTY0siIwnwLThKlbsH6KqD8i1LtYILxXkp2Kq2XboudYluNjhlyEnhhJHlQdPgRQye35gbQCZ4y0fFbT5zWXyD5uxbhZeO(dyTYILxXkp2Kq20AuhcQbbQbvOorcO(dyTYILxXkp2Kq20AuhcQbbQBGJKETskFuGgQnfQtc1FaRvwS8kw5XMesGuOojuhpsD5KSy5vSYJnjKDCGd1zd1zYXcMxZXXy4I6qQXQkgXDUr5WnJJrx8f0MNbhJ1LtDfCSpG1klwEfR8ytcjqkuNeQ)awRe4WnI8kK30T44KaPqDsOoEK6YjzXYRyLhBsi74ahQZgQZKJfmVMJJXWf1HuJvvmI7CNJnFr5uhEnh3mUrp5MXXOl(cAZZGJX6YPUcoMhc6C5s44OUUffYNEvsx8f0MJfmVMJJ1060isqiKYqDo1CNBuMCZ4y0fFbT5zWXcMxZXXMVOCQdN4ySUCQRGJzcuVPpG1k74XPlgjrEWahQbbQZbQtKaQ30hWALD840fJKnTg1HGAqG6N5c1Mc1jH6hGApe05sBpihXY74ijDXxqBOoju)au)bSwzxRKeifQtc1OusiuE0lKJK4gdI6wuFrGCOo7xOg0CmwEMGuE0lKJ4g9K7CJan3mogDXxqBEgCmwxo1vWXEaQ9qqNlT9GCelVJJK0fFbTH6Kq9dq9hWALDTssGuOojuJsjHq5rVqosIBmiQBr9fbYH6SFHAqZXcMxZXXMVOCQdN4o3iqLBghJU4lOnpdogRlN6k4yMa1FaRvcEje1TOwdgU6iztbZH6ejGAtG6pG1kbVeI6wuRbdxDKeifQtc1Ma1PnHh1cBlFkT9GCfY7cCcQtKaQtBcpQf2w(uIBmiQBr9fbYH6ejG60MWJAHTLpLlIGvHqfB8ehJGAtHAtHAtH6KqnkLecLh9c5iPThKJy5DCeuN9luNjhlyEnhhZ2dYrS8ooI7CJYHBghJU4lOnpdowW8Aoo28fLtD4ehJ1LtDfCmtG6n9bSwzhpoDXijYdg4qniqDoqDIeq9M(awRSJhNUyKSP1Ooeudcu)mxO2uOoju)bSwj4Lqu3IAny4QJKnfmhQtKaQnbQ)awRe8siQBrTgmC1rsGuOojuBcuN2eEulST8P02dYviVlWjOorcOoTj8OwyB5tjUXGOUf1xeihQtKaQtBcpQf2w(uUicwfcvSXtCmcQnfQnLJXYZeKYJEHCe3ONCNBuwIBghJU4lOnpdogRlN6k4yFaRvcEje1TOwdgU6iztbZH6ejGAtG6pG1kbVeI6wuRbdxDKeifQtc1Ma1PnHh1cBlFkT9GCfY7cCcQtKaQtBcpQf2w(uIBmiQBr9fbYH6ejG60MWJAHTLpLlIGvHqfB8ehJGAtHAt5ybZR54yZxuo1HtCNBuwGBghJU4lOnpdogRlN6k4yMa1pa1FaRv21kjbsH6ejG6g4kMkDmqTCt2Ivoudcu)mxOorcOUbos61kP8rLjuNnuVW2qTPqDsOgLscHYJEHCKCreSkeQyJN4yeuN9luNjhlyEnhhBreSkeQyJN4ye35gHx5MXXOl(cAZZGJX6YPUco2hWALDTssGuOojuJsjHq5rVqosIBmiQBr9fbYH6SFH6m5ybZR54y4gdI6wuFrGCUZnklZnJJrx8f0MNbhlyEnhhZ2dYviVlWjogRlN6k4yMa1B6dyTYoEC6IrsKhmWHAqG6CG6ejG6n9bSwzhpoDXiztRrDiOgeO(zUqTPqDsO(bO(dyTYUwjjqkuNibu3axXuPJbQLBYwSYHAqG6N5c1jsa1nWrsVwjLpQmH6SH6f2gQtc1pa1EiOZL2EqoIL3Xrs6IVG2CmwEMGuE0lKJ4g9K7CJEMl3mogDXxqBEgCmwxo1vWXEaQ)awRSRvscKc1jsa1nWvmv6yGA5MSfRCOgeO(zUqDIeqDdCK0Rvs5JktOoBOEHT5ybZR54y2EqUc5DboXDUrpFYnJJrx8f0MNbhJ1LtDfCSpG1k7ALKaPCSG51CCmCJbrDlQViqo35g9mtUzCm6IVG28m4ybZR54yZxuo1HtCmwxo1vWXmbQ30hWALD840fJKipyGd1Ga15a1jsa1B6dyTYoEC6IrYMwJ6qqniq9ZCHAtH6Kq9dqThc6CPThKJy5DCKKU4lOnhJLNjiLh9c5iUrp5o3ONGMBghlyEnhhB(IYPoCIJrx8f0MNb35oh7piLxmWRBHBg3ONCZ4y0fFbT5zWXyD5uxbhJnJypgojTMogOw1ahPmqr6CYMwJ6qCSG51CCS0siIwnwLThKZDUrzYnJJfmVMJJrRPJbQvnWrkduKohhJU4lOnpdUZnc0CZ4y0fFbT5zWXcMxZXXMVOCQdN4ySUCQRGJzcuVPpG1k74XPlgjrEWahQbbQZbQtKaQ30hWALD840fJKnTg1HGAqG6N5c1Mc1jH6g4kMkDmqnudYlud6CH6Kq9dqThc6CPThKJy5DCKKU4lOnhJLNjiLh9c5iUrp5o3iqLBghJU4lOnpdogRlN6k4ynWvmv6yGAOgKxOg0zYXcMxZXXMVOCQdN4o3OC4MXXOl(cAZZGJX6YPUcoMhc6C5s44OUUffYNEvsx8f0MJfmVMJJ1060isqiKYqDo1CNBuwIBghJU4lOnpdogRlN6k4yFaRv21kjbs5ybZR54y4gdI6wuFrGCUZnklWnJJrx8f0MNbhlyEnhhB(IYPoCIJX6YPUcoMjq9M(awRSJhNUyKe5bdCOgeOohOorcOEtFaRv2XJtxms20AuhcQbbQFMluBkuNeQBGJKETskFu5a1Ga1lSnuNibu3axXuPJbQHAqEHAqnhOoju)au7HGoxA7b5iwEhhjPl(cAZXy5zcs5rVqoIB0tUZncVYnJJrx8f0MNbhJ1LtDfCSg4iPxRKYhvoqniq9cBd1jsa1nWvmv6yGAOgKxOguZHJfmVMJJnFr5uhoXDUrzzUzCm6IVG28m4ySUCQRGJ9bSwj4Lqu3IAny4QJKaPqDsOgLscHYJEHCK02dYrS8oocQZ(fQZKJfmVMJJz7b5iwEhhXDUrpZLBghJU4lOnpdogRlN6k4ynWvmv6yGA5MSfRCOo7xOg0zc1jH6g4iPxRKYhfOH6SH6f2MJfmVMJJHB6tnwLH6CQ5o3ONp5MXXcMxZXXAADAejieszOoNAogDXxqBEgCNB0Zm5MXXOl(cAZZGJX6YPUcogkLecLh9c5iPThKJy5DCeuN9luNjhlyEnhhZ2dYrS8ooI7CJEcAUzCm6IVG28m4ybZR54yZxuo1HtCmwxo1vWXmbQ30hWALD840fJKipyGd1Ga15a1jsa1B6dyTYoEC6IrYMwJ6qqniq9ZCHAtH6KqDdCftLogOwUjBXkhQZgQZmhOorcOUbocQZgQbnuNeQFaQ9qqNlT9GCelVJJK0fFbT5yS8mbP8OxihXn6j35g9eu5MXXOl(cAZZGJX6YPUcowdCftLogOwUjBXkhQZgQZmhOorcOUbocQZgQbnhlyEnhhB(IYPoCI7CJEMd3mogDXxqBEgCmwxo1vWXAGRyQ0Xa1Ynzlw5qD2qDM5YXcMxZXXIMfhP8PB6CUZDogBgXEmCiUzCJEYnJJrx8f0MNbhlyEnhhta0GtnsvhQ21aGulL15ySUCQRGJ5HGox(BkCCQXQq1T7yzqHKU4lOnuNeQnbQnbQzZi2JHtMwcr0QXQS9GCztRrDiOgKxO(zUqDsOgprxXxqYXXrTAofaIueOaOstPnuBkuNibuBcu)bSwzAjerRgRY2dYLaPqDsO(bOgprxXxqYXXrTAofaIueOaOstPnuBkuBkuNibuBcu)bSwzAjerRgRY2dYLaPqDsO(bO2dbDU83u44uJvHQB3XYGcjDXxqBO2uo2fRehta0GtnsvhQ21aGulL15o3Om5MXXOl(cAZZGJX6YPUcoMjqnBgXEmCY0siIwnwLThKlBk25H6ejGA2mI9y4KPLqeTASkBpix20AuhcQZgQZmxO2uOojuBcu)au7HGox(BkCCQXQq1T7yzqHKU4lOnuNibuZMrShdNKwthduRAGJugOiDoztRrDiOoBOolNduBkhlyEnhhdarQYPve35gbAUzCm6IVG28m4ybZR54y4fiKc3yqqnhJ1LtDfCmtGAcuauPP0wkaAWPgPQdv7AaqQLY6qDsO(dyTY0siIwnwLThKlBAnQdb1Mc1jsa1Ma1pa1eOaOstPTua0GtnsvhQ21aGulL1H6Kq9hWALPLqeTASkBpix20AuhcQbbQFMjuNeQ)awRmTeIOvJvz7b5sGuO2uo2fRehdVaHu4gdcQ5o3iqLBghJU4lOnpdowW8Aoog434QXQIJv05klqNNJX6YPUcogBgXEmCsAnDmqTQboszGI05KnTg1HG6SHAqnxo2fRehd8BC1yvXXk6CLfOZZDUr5WnJJrx8f0MNbhlyEnhhBPNBbPs7AneQowiogRlN6k4ynWrqniVqnOH6Kq9dq9hWALPLqeTASkBpixcKc1jHAtG6hG6pG1k)nfoo1yvO62DSmOqcKc1jsa1pa1EiOZL)MchNASkuD7owguiPl(cAd1MYXUyL4yl9ClivAxRHq1XcXDUrzjUzCm6IVG28m4yxSsCSoECdCGJu)Ar10w9bCFoowW8AoowhpUboWrQFTOAAR(aUph35gLf4MXXOl(cAZZGJfmVMJJTsnbUJlqkBClCmwxo1vWXEaQ)awR83u44uJvHQB3XYGcjqkuNeQFaQ)awRmTeIOvJvz7b5sGuo2fRehBLAcChxGu24w4o3i8k3mogDXxqBEgCmwxo1vWX(awRmTeIOvJvz7b5sGuOoju)bSwjTMogOw1ahPmqr6CsGuowW8Aoow641CCNBuwMBghJU4lOnpdogRlN6k4yFaRvMwcr0QXQS9GCjqkuNeQ)awRKwthduRAGJugOiDojqkhlyEnhh7lMzRSaDEUZn6zUCZ4y0fFbT5zWXyD5uxbh7dyTY0siIwnwLThKlbs5ybZR54yFQrudEDlCNB0ZNCZ4y0fFbT5zWXyD5uxbhJnJypgojTMogOw1ahPmqr6CYMwJ6qCSG51CCS0siIwnwLThKZDUrpZKBghJU4lOnpdogRlN6k4ySze7XWjP10Xa1Qg4iLbksNt20AuhcQtc1Sze7XWjtlHiA1yv2EqUSP1OoehlyEnhh73u44uJvHQB3XYGcogaIuJ1QwyBo2tUZn6jO5MXXOl(cAZZGJX6YPUcogBgXEmCY0siIwnwLThKlBk25H6Kq9dqThc6C5VPWXPgRcv3UJLbfs6IVG2qDsOUbos61kP8rLduNnuVW2qDsOUbUIPshdul3KTyLd1z)c1pZfQtKaQ9ALu(O2fb1Ga1zMlhlyEnhhJwthduRAGJugOiDoUZn6jOYnJJrx8f0MNbhJ1LtDfCmtGA2mI9y4KPLqeTASkBpix2uSZd1jsa1ETskFu7IGAqG6mZfQnfQtc1EiOZL)MchNASkuD7owguiPl(cAd1jH6g4kMkDmqnuNnuNLYLJfmVMJJrRPJbQvnWrkduKoh35g9mhUzCm6IVG28m4ySUCQRGJ5HGoxYgXwHJI2L0fFbTH6KqTjqTjq9hWALSrSv4OODjYdg4qD2Vq9ZCH6Kq9M(awRSJhNUyKe5bdCO(fQZbQnfQtKaQ9ALu(O2fb1G8c1lSnuBkhlyEnhhJfcHkyEnNsuiNJjkKRUyL4ySrSv4OODUZn6zwIBghJU4lOnpdogRlN6k4yMa1FaRvMwcr0QXQS9GCztRrDiOgKxOEHTH6ejGAtG6pG1ktlHiA1yv2EqUSP1OoeudcuJxH6Kq9hWALahUrKxH8MUfhNSP1OoeudYluVW2qDsO(dyTsGd3iYRqEt3IJtcKc1Mc1Mc1jH6pG1ktlHiA1yv2EqUeifQtc1XJuxojlwEfR8ytczhh4qniVqDMCSG51CCmBpi3q(EfPSaDEUZn6zwGBghJU4lOnpdogRlN6k4yMa1FaRvwS8kw5XMeYMwJ6qqniVq9cBd1jsa1Ma1FaRvwS8kw5XMeYMwJ6qqniqnEfQtc1FaRvcC4grEfYB6wCCYMwJ6qqniVq9cBd1jH6pG1kboCJiVc5nDloojqkuBkuBkuNeQ)awRSy5vSYJnjKaPqDsOoEK6YjzXYRyLhBsi74ahQZgQZKJfmVMJJz7b5gY3RiLfOZZDUrpXRCZ4y0fFbT5zWXyD5uxbhZRvs5JAxeudcuVW2qDIeqTjqTxRKYh1UiOgeOMnJypgozAjerRgRY2dYLnTg1HG6Kq9hWALahUrKxH8MUfhNeifQnLJfmVMJJz7b5gY3RiLfOZZDUZX(dsLoJOUfUzCJEYnJJrx8f0MNbhJ1LtDfCSpG1k7ALKaPCSG51CCmCJbrDlQViqo35gLj3mogDXxqBEgCSG51CCS5lkN6WjogRlN6k4yMa1B6dyTYoEC6IrsKhmWHAqG6CG6ejG6n9bSwzhpoDXiztRrDiOgeO(zUqTPqDsOoju3axXuPJbQLBYwSYH6SFH6mZbQtc1pa1EiOZL2EqoIL3Xrs6IVG2CmwEMGuE0lKJ4g9K7CJan3mogDXxqBEgCmwxo1vWXAGRyQ0Xa1Ynzlw5qD2VqDM5WXcMxZXXMVOCQdN4o3iqLBghJU4lOnpdogRlN6k4ynWvmv6yGA5MSfRCOgeOoZCH6KqnkLecLh9c5i5IiyviuXgpXXiOo7xOotOojuZMrShdNmTeIOvJvz7b5YMwJ6qqD2qDoCSG51CCSfrWQqOInEIJrCNBuoCZ4y0fFbT5zWXcMxZXXS9GCfY7cCIJX6YPUcoMjq9M(awRSJhNUyKe5bdCOgeOohOorcOEtFaRv2XJtxms20AuhcQbbQFMluBkuNeQBGRyQ0Xa1Ynzlw5qniqDM5c1jH6hGApe05sBpihXY74ijDXxqBOojuZMrShdNmTeIOvJvz7b5YMwJ6qqD2qDoCmwEMGuE0lKJ4g9K7CJYsCZ4y0fFbT5zWXyD5uxbhRbUIPshdul3KTyLd1Ga1zMluNeQzZi2JHtMwcr0QXQS9GCztRrDiOoBOohowW8AooMThKRqExGtCNBuwGBghJU4lOnpdogRlN6k4yFaRvcEje1TOwdgU6ijqkuNeQBGRyQ0Xa1Ynzlw5qD2qTjq9ZCGA8HApe05Yg4kMkCNoGWR5K0fFbTHA8gQbnuBkuNeQrPKqO8OxihjT9GCelVJJG6SFH6m5ybZR54y2EqoIL3XrCNBeELBghJU4lOnpdogRlN6k4ynWvmv6yGA5MSfRCOo7xO2eOg05a14d1EiOZLnWvmv4oDaHxZjPl(cAd14nudAO2uOojuJsjHq5rVqosA7b5iwEhhb1z)c1zYXcMxZXXS9GCelVJJ4o3OSm3mogDXxqBEgCSG51CCS5lkN6WjogRlN6k4yMa1B6dyTYoEC6IrsKhmWHAqG6CG6ejG6n9bSwzhpoDXiztRrDiOgeO(zUqTPqDsOUbUIPshdul3KTyLd1z)c1Ma1GohOgFO2dbDUSbUIPc3Pdi8AojDXxqBOgVHAqd1Mc1jH6hGApe05sBpihXY74ijDXxqBoglptqkp6fYrCJEYDUrpZLBghJU4lOnpdogRlN6k4ynWvmv6yGA5MSfRCOo7xO2eOg05a14d1EiOZLnWvmv4oDaHxZjPl(cAd14nudAO2uowW8Aoo28fLtD4e35g98j3mogDXxqBEgCmwxo1vWXyZi2JHtMwcr0QXQS9GCztRrDiOoBOUbos61kP8rbQqDsOUbUIPshdul3KTyLd1Ga1GAUqDsOgLscHYJEHCKCreSkeQyJN4yeuN9luNjhlyEnhhBreSkeQyJN4ye35g9mtUzCm6IVG28m4ybZR54y2EqUc5DboXXyD5uxbhZeOEtFaRv2XJtxmsI8GboudcuNduNibuVPpG1k74XPlgjBAnQdb1Ga1pZfQnfQtc1Sze7XWjtlHiA1yv2EqUSP1OoeuNnu3ahj9ALu(OavOoju3axXuPJbQLBYwSYHAqGAqnxOoju)au7HGoxA7b5iwEhhjPl(cAZXy5zcs5rVqoIB0tUZn6jO5MXXOl(cAZZGJX6YPUcogBgXEmCY0siIwnwLThKlBAnQdb1zd1nWrsVwjLpkqfQtc1nWvmv6yGA5MSfRCOgeOguZLJfmVMJJz7b5kK3f4e35ohlTj2S(dNBg3ONCZ4ybZR54yPJxZXXOl(cAZZG7CJYKBghJU4lOnpdo2KYXqKZXcMxZXXWt0v8fehdpHaG4yMa1eOaOstPTC3uSvlIyxHpns9J9cb1jsa1eOaOstPTevxHCQvlIyxHpns9J9cb1jsa1eOaOstPTevxHCQvlIyxHpnsTs7qiQ5G6ejGAcuauPP0wINkeQXQIRwdN2QVyMnuNibutGcGknL2sB1ixTgoHuO08lIaHG6ejGAcuauPP0wIxGqkCJbb1qDIeqnbkaQ0uAl3nfBvGsRoohPwPDie1CqTPCm8eT6IvIJnooQvZPaqKIafavAkT5o35yXqCZ4g9KBghJU4lOnpdogRlN6k4yEiOZLlHJJ66wuiF6vjDXxqBOorcO2eOoEK6YjPTNhPt50AkHCzhh4qDsOgLscHYJEHCKSP1PrKGqiLH6CQH6SFHAqd1jH6hG6pG1k7ALKaPqTPCSG51CCSMwNgrccHugQZPM7CJYKBghJU4lOnpdogRlN6k4yEiOZL2EqoIL3Xrs6IVG2CSG51CCSfrWQqOInEIJrCNBeO5MXXOl(cAZZGJfmVMJJz7b5kK3f4ehJ1LtDfCmtG6n9bSwzhpoDXijYdg4qniqDoqDIeq9M(awRSJhNUyKSP1Ooeudcu)mxO2uOojuZMrShdNSP1PrKGqiLH6CQLnTg1HGAqEH6mHA8gQxyBOoju7HGoxUeooQRBrH8PxL0fFbTH6Kq9dqThc6CPThKJy5DCKKU4lOnhJLNjiLh9c5iUrp5o3iqLBghJU4lOnpdogRlN6k4ySze7XWjBADAejieszOoNAztRrDiOgKxOotOgVH6f2gQtc1EiOZLlHJJ66wuiF6vjDXxqBowW8AooMThKRqExGtCNBuoCZ4y0fFbT5zWXyD5uxbh7dyTYUwjjqkhlyEnhhd3yqu3I6lcKZDUrzjUzCm6IVG28m4ySUCQRGJ9bSwj4Lqu3IAny4QJKaPCSG51CCmBpihXY74iUZnklWnJJrx8f0MNbhJ1LtDfCSg4kMkDmqTCt2IvoudcuBcu)mhOgFO2dbDUSbUIPc3Pdi8AojDXxqBOgVHAqd1MYXcMxZXXwebRcHk24jogXDUr4vUzCm6IVG28m4ybZR54y2EqUc5DboXXyD5uxbhZeOEtFaRv2XJtxmsI8GboudcuNduNibuVPpG1k74XPlgjBAnQdb1Ga1pZfQnfQtc1nWvmv6yGA5MSfRCOgeO2eO(zoqn(qThc6CzdCftfUthq41Cs6IVG2qnEd1GgQnfQtc1pa1EiOZL2EqoIL3Xrs6IVG2CmwEMGuE0lKJ4g9K7CJYYCZ4y0fFbT5zWXyD5uxbhRbUIPshdul3KTyLd1Ga1Ma1pZbQXhQ9qqNlBGRyQWD6acVMtsx8f0gQXBOg0qTPCSG51CCmBpixH8UaN4o3ON5YnJJfmVMJJ1060isqiKYqDo1Cm6IVG28m4o3ONp5MXXcMxZXXS9GCelVJJ4y0fFbT5zWDUrpZKBghJU4lOnpdowW8Aoo28fLtD4ehJ1LtDfCmtG6n9bSwzhpoDXijYdg4qniqDoqDIeq9M(awRSJhNUyKSP1Ooeudcu)mxO2uOoju3axXuPJbQLBYwSYH6SHAtG6mZbQXhQ9qqNlBGRyQWD6acVMtsx8f0gQXBOg0qTPqDsO(bO2dbDU02dYrS8oossx8f0MJXYZeKYJEHCe3ONCNB0tqZnJJrx8f0MNbhJ1LtDfCSg4kMkDmqTCt2IvouNnuBcuNzoqn(qThc6CzdCftfUthq41Cs6IVG2qnEd1GgQnLJfmVMJJnFr5uhoXDUrpbvUzCSG51CCSfrWQqOInEIJrCm6IVG28m4o3ON5WnJJrx8f0MNbhlyEnhhZ2dYviVlWjogRlN6k4yMa1B6dyTYoEC6IrsKhmWHAqG6CG6ejG6n9bSwzhpoDXiztRrDiOgeO(zUqTPqDsO(bO2dbDU02dYrS8oossx8f0MJXYZeKYJEHCe3ONCNB0ZSe3mowW8AooMThKRqExGtCm6IVG28m4o3ONzbUzCSG51CCmCtFQXQmuNtnhJU4lOnpdUZn6jELBghlyEnhhlAwCKYNUPZ5y0fFbT5zWDUZX2Knaeo3mUrp5MXXcMxZXXwRBRSnrpsCm6IVG28m4o3Om5MXXOl(cAZZGJX6YPUco2dq9ECPThKRSeEOw6fd86wG6KqTjq9dqThc6C5VPWXPgRcv3UJLbfs6IVG2qDIeqnBgXEmCYFtHJtnwfQUDhldkKnTg1HG6SH6N5a1MYXcMxZXXWnge1TO(Ia5CNBeO5MXXOl(cAZZGJX6YPUco2hWALflVYdXCiztRrDiOgKxOEHTH6Kq9hWALflVYdXCijqkuNeQrPKqO8OxihjxebRcHk24jogb1z)c1zc1jHAtG6hGApe05YFtHJtnwfQUDhldkK0fFbTH6ejGA2mI9y4K)MchNASkuD7owguiBAnQdb1zd1pZbQnLJfmVMJJTicwfcvSXtCmI7CJavUzCm6IVG28m4ySUCQRGJ9bSwzXYR8qmhs20AuhcQb5fQxyBOoju)bSwzXYR8qmhscKc1jHAtG6hGApe05YFtHJtnwfQUDhldkK0fFbTH6ejGA2mI9y4K)MchNASkuD7owguiBAnQdb1zd1pZbQnLJfmVMJJz7b5kK3f4e35gLd3mogDXxqBEgCSG51CCmwieQG51CkrHCoMOqU6IvIJrieDmcXDUrzjUzCm6IVG28m4ybZR54ySqiubZR5uIc5CmrHC1fRehJnJypgoe35gLf4MXXOl(cAZZGJX6YPUcoMhc6C5VPWXPgRcv3UJLbfs6IVG2qDsO2eO2eOMnJypgo5VPWXPgRcv3UJLbfYMwJ6qq9luNluNeQzZi2JHtMwcr0QXQS9GCztRrDiOgeO(zUqTPqDIeqTjqnBgXEmCYFtHJtnwfQUDhldkKnTg1HGAqG6mZfQtc1ETskFu7IGAqGAqNduBkuBkhlyEnhhRbovW8AoLOqohtuixDXkXX(dsLoJOUfUZncVYnJJrx8f0MNbhJ1LtDfCSpG1k)nfoo1yvO62DSmOqcKYXcMxZXXAGtfmVMtjkKZXefYvxSsCS)GuEXaVUfUZnklZnJJrx8f0MNbhJ1LtDfCSpG1ktlHiA1yv2EqUeifQtc1EiOZLZxuo1HxZjPl(cAZXcMxZXXAGtfmVMtjkKZXefYvxSsCS5lkN6WR54o3ON5YnJJrx8f0MNbhJ1LtDfCSG5fEifD0AriOo7xOotowW8AoowdCQG51CkrHCoMOqU6IvIJfdXDUrpFYnJJrx8f0MNbhlyEnhhJfcHkyEnNsuiNJjkKRUyL4yipUD0BUZDogYJBh9MBg3ONCZ4ybZR54ynTonIeecPmuNtnhJU4lOnpdUZnktUzCm6IVG28m4ySUCQRGJXMrShdNSP1PrKGqiLH6CQLnTg1HGAqEH6mHA8gQxyBOoju7HGoxUeooQRBrH8PxL0fFbT5ybZR54y2EqUc5DboXDUrGMBghJU4lOnpdogRlN6k4yFaRv21kjbs5ybZR54y4gdI6wuFrGCUZncu5MXXOl(cAZZGJX6YPUco2dq9hWAL2EEKovkGarsGuOoju7HGoxA75r6uPacejPl(cAZXcMxZXXMVOCQdN4o3OC4MXXOl(cAZZGJX6YPUcowdCftLogOwUjBXkhQbbQnbQFMduJpu7HGox2axXuH70beEnNKU4lOnuJ3qnOHAt5ybZR54y2EqUc5DboXDUrzjUzCm6IVG28m4ySUCQRGJ9bSwj4Lqu3IAny4QJKaPqDsOUbos61kP8rbQqD2Vq9cBZXcMxZXXS9GCelVJJ4o3OSa3mogDXxqBEgCmwxo1vWXAGRyQ0Xa1Ynzlw5qD2qTjqDM5a14d1EiOZLnWvmv4oDaHxZjPl(cAd14nudAO2uowW8Aoo28fLtD4e35gHx5MXXcMxZXXS9GCfY7cCIJrx8f0MNb35gLL5MXXcMxZXXWn9PgRYqDo1Cm6IVG28m4o3ON5YnJJfmVMJJfnlos5t305Cm6IVG28m4o35yecrhJqCZ4g9KBghJU4lOnpdogRlN6k4yFaRvMwcr0QXQS9GCztRrDiOgeO(zUqDsOMnJypgo5VPWXPgRcv3UJLbfYMwJ6qqDIeq9hWALPLqeTASkBpix20AuhcQbbQFMluNeQFaQ9qqNl)nfoo1yvO62DSmOqsx8f0MJfmVMJJ9fZSvJv54ifD0AEUZnktUzCSG51CCSfGO3vCQXQIhPECCCm6IVG28m4o3iqZnJJrx8f0MNbhJ1LtDfCShG6pG1ktlHiA1yv2EqUeifQtc1pa1FaRv(BkCCQXQq1T7yzqHeiLJfmVMJJzhgaI2Q4rQlNuFkw5o3iqLBghJU4lOnpdogRlN6k4ypa1FaRvMwcr0QXQS9GCjqkuNeQFaQ)awR83u44uJvHQB3XYGcjqkuNeQ3JlzZXOZ7WPTYkIvs9b6t20AuhcQFH6C5ybZR54yS5y05D40wzfXkXDUr5WnJJrx8f0MNbhJ1LtDfCShG6pG1ktlHiA1yv2EqUeifQtc1pa1FaRv(BkCCQXQq1T7yzqHeiLJfmVMJJLc0LnFDlQViqo35gLL4MXXOl(cAZZGJX6YPUco2dq9hWALPLqeTASkBpixcKc1jH6hG6pG1k)nfoo1yvO62DSmOqcKYXcMxZXXmmTyJhQovtO5IJrCNBuwGBghJU4lOnpdogRlN6k4ypa1FaRvMwcr0QXQS9GCjqkuNeQFaQ)awR83u44uJvHQB3XYGcjqkhlyEnhhRR0ubPQtHsdgXDUr4vUzCm6IVG28m4ySUCQRGJ9bSwjTMogOw1ahPmqr6CYMwJ6qqniqDoqDsO(dyTYFtHJtnwfQUDhldkKaPqDIeqTjqDdCK0Rvs5JktOoBOEHTH6KqDdCftLogOgQbbQZjxO2uowW8Aoo2kToDE1yvcawTv7MIve35o35y4HAunh3OmZ9zwoxqnZmLpZf0GMJzi6RUfehdu(A60oTH6N5c1bZR5GArHCKecghlThBjiowwb1zTEqoudkdfooOol(vl4CiyzfuJZ9uuwK5MVuooGVKnRMJQvar41CSoSU5OALzoeSScQbdqKhQZcgd1zM7ZSmudkb1pbDwuM5abdcwwb1z94IBHqzrqWYkOgucQbLFmbWMGAqzRBd1zTMOhjjeSScQbLGA8s7nuBdH4hmWHA70qnaQUfOgVyw3Sogd14LNSguxwOove5PgQRR8kCcb1zmyq9NSttqD6mI6wGAXSumOUqqnBwtfKtBjeSScQbLG6SECXTqqTh9c5sVwjLpQDrqTpqTxRKYh1UiO2hOgarqnDSb4CQHAbDlooOUdhh1qTJloOoDC68keqT3bchuVPWXHKqWGGLvqnEXSyigGtBO(t2PjOMnR)WH6pTuhsc14Lymk1rq9nhOeUOxTacOoyEnhcQNtKxcblRG6G51CizAtSz9h(RveiWHGLvqDW8AoKmTj2S(dh)xZTZSHGLvqDW8AoKmTj2S(dh)xZdGLv68WR5GGLvqn2fPiCJd1DuBO(dyT0gQrE4iO(t2PjOMnR)WH6pTuhcQJBd1PnbkLoUx3cuxiOEphjHGLvqDW8AoKmTj2S(dh)xZrxKIWnUc5HJGGfmVMdjtBInR)WX)180XR5GGfmVMdjtBInR)WX)1C8eDfFbz8fR0744OwnNcarkcuauPP02y8eca61ecuauPP0wUBk2QfrSRWNgP(XEHsKGafavAkTLO6kKtTAre7k8PrQFSxOejiqbqLMsBjQUc5uRweXUcFAKAL2HquZLibbkaQ0uAlXtfc1yvXvRHtB1xmZorccuauPP0wARg5Q1WjKcLMFreiuIeeOaOstPTeVaHu4gdcQtKGafavAkTL7MITkqPvhNJuR0oeIAotHGbblRGA8IzXqmaN2qnHhQZd1ETsqTJJG6G5td1fcQd8eLi(cscblyEnh6DTUTY2e9ibblRGA8sPPI8qDwRhKd1zncpud1XTH61OopQdQbLZYd1MfI5qqWcMxZHW)1CCJbrDlQViqUXL99H94sBpixzj8qT0lg41TK0Kh8qqNl)nfoo1yvO62DSmOqsx8f0orc2mI9y4K)MchNASkuD7owguiBAnQdL9ZCmfcwW8Aoe(VMVicwfcvSXtCmY4Y((bSwzXYR8qmhs20AuhcK3f2o5hWALflVYdXCijqAsukjekp6fYrYfrWQqOInEIJrz)MzstEWdbDU83u44uJvHQB3XYGcjDXxq7ejyZi2JHt(BkCCQXQq1T7yzqHSP1Oou2pZXuiybZR5q4)AUThKRqExGtgx23pG1klwELhI5qYMwJ6qG8UW2j)awRSy5vEiMdjbstAYdEiOZL)MchNASkuD7owguiPl(cANibBgXEmCYFtHJtnwfQUDhldkKnTg1HY(zoMcblyEnhc)xZzHqOcMxZPefYn(Iv6Lqi6yeccwW8Aoe(VMZcHqfmVMtjkKB8fR0lBgXEmCiiybZR5q4)AEdCQG51CkrHCJVyLE)dsLoJOUfJl7Rhc6C5VPWXPgRcv3UJLbfs6IVG2jnXe2mI9y4K)MchNASkuD7owguiBAnQd9MBs2mI9y4KPLqeTASkBpix20AuhcKN5AAIeMWMrShdN83u44uJvHQB3XYGcztRrDiqYm3KETskFu7Iab05yQPqWcMxZHW)18g4ubZR5uIc5gFXk9(hKYlg41TyCzF)awR83u44uJvHQB3XYGcjqkeSG51Ci8FnVbovW8AoLOqUXxSsVZxuo1HxZzCzF)awRmTeIOvJvz7b5sG0KEiOZLZxuo1HxZjPl(cAdblyEnhc)xZBGtfmVMtjkKB8fR0BmKXL9nyEHhsrhTwek73mHGfmVMdH)R5SqiubZR5uIc5gFXk9I842rVHGbblyEnhsgd92060isqiKYqDo1gx2xpe05YLWXrDDlkKp9QKU4lODIeMepsD5K02ZJ0PCAnLqUSJd8KOusiuE0lKJKnTonIeecPmuNtD2VGo5dFaRv21kjbsnfcwW8AoKmgc)xZxebRcHk24jogzCzF9qqNlT9GCelVJJK0fFbTHGfmVMdjJHW)1CBpixH8UaNmMLNjiLh9c5O3Ngx2xt20hWALD840fJKipyGdsojsSPpG1k74XPlgjBAnQdbYZCnnjBgXEmCYMwNgrccHugQZPw20AuhcK3mX7f2oPhc6C5s44OUUffYNEvsx8f0o5dEiOZL2EqoIL3Xrs6IVG2qWcMxZHKXq4)AUThKRqExGtgx2x2mI9y4KnTonIeecPmuNtTSP1OoeiVzI3lSDspe05YLWXrDDlkKp9QKU4lOneSG51Cizme(VMJBmiQBr9fbYnUSVFaRv21kjbsHGfmVMdjJHW)1CBpihXY74iJl77hWALGxcrDlQ1GHRoscKcblyEnhsgdH)R5lIGvHqfB8ehJmUSVnWvmv6yGA5MSfRCqm5zo47HGox2axXuH70beEnNKU4lOnEdAtHGfmVMdjJHW)1CBpixH8UaNmMLNjiLh9c5O3Ngx2xt20hWALD840fJKipyGdsojsSPpG1k74XPlgjBAnQdbYZCnnzdCftLogOwUjBXkhetEMd(EiOZLnWvmv4oDaHxZjPl(cAJ3G20Kp4HGoxA7b5iwEhhjPl(cAdblyEnhsgdH)R52EqUc5DbozCzFBGRyQ0Xa1Ynzlw5GyYZCW3dbDUSbUIPc3Pdi8AojDXxqB8g0McblyEnhsgdH)R5nTonIeecPmuNtneSG51Cizme(VMB7b5iwEhhbblyEnhsgdH)R5Zxuo1HtgZYZeKYJEHC07tJl7RjB6dyTYoEC6IrsKhmWbjNej20hWALD840fJKnTg1Ha5zUMMSbUIPshdul3KTyLNTjzMd(EiOZLnWvmv4oDaHxZjPl(cAJ3G20Kp4HGoxA7b5iwEhhjPl(cAdblyEnhsgdH)R5Zxuo1Htgx23g4kMkDmqTCt2IvE2MKzo47HGox2axXuH70beEnNKU4lOnEdAtHGfmVMdjJHW)18frWQqOInEIJrqWcMxZHKXq4)AUThKRqExGtgZYZeKYJEHC07tJl7RjB6dyTYoEC6IrsKhmWbjNej20hWALD840fJKnTg1Ha5zUMM8bpe05sBpihXY74ijDXxqBiybZR5qYyi8Fn32dYviVlWjiybZR5qYyi8Fnh30NASkd15udblyEnhsgdH)R5rZIJu(0nDoemiyzfuNrtHJdQhluJv3UJLbfqD6mI6wG6E8WR5G6SiOg5r7iOoZCrq9NSttqnE5siIgQhluN16b5qn(qDgdguhnb1bEIseFbbblyEnhs(hKkDgrDlV4gdI6wuFrGCJl77hWALDTssGuiybZR5qY)GuPZiQBb)xZNVOCQdNmMLNjiLh9c5O3Ngx2xt20hWALD840fJKipyGdsojsSPpG1k74XPlgjBAnQdbYZCnnzYg4kMkDmqTCt2IvE2VzMtYh8qqNlT9GCelVJJK0fFbTHGfmVMdj)dsLoJOUf8FnF(IYPoCY4Y(2axXuPJbQLBYwSYZ(nZCGGfmVMdj)dsLoJOUf8FnFreSkeQyJN4yKXL9TbUIPshdul3KTyLdsM5MeLscHYJEHCKCreSkeQyJN4yu2VzMKnJypgozAjerRgRY2dYLnTg1HYohiybZR5qY)GuPZiQBb)xZT9GCfY7cCYywEMGuE0lKJEFACzFnztFaRv2XJtxmsI8Gboi5KiXM(awRSJhNUyKSP1OoeipZ10KnWvmv6yGA5MSfRCqYm3Kp4HGoxA7b5iwEhhjPl(cANKnJypgozAjerRgRY2dYLnTg1HYohiybZR5qY)GuPZiQBb)xZT9GCfY7cCY4Y(2axXuPJbQLBYwSYbjZCtYMrShdNmTeIOvJvz7b5YMwJ6qzNdeSG51Ci5FqQ0ze1TG)R52EqoIL3Xrgx23pG1kbVeI6wuRbdxDKeinzdCftLogOwUjBXkpBtEMd(EiOZLnWvmv4oDaHxZjPl(cAJ3G20KOusiuE0lKJK2EqoIL3Xrz)MjeSG51Ci5FqQ0ze1TG)R52EqoIL3Xrgx23g4kMkDmqTCt2IvE2VMa6CW3dbDUSbUIPc3Pdi8AojDXxqB8g0MMeLscHYJEHCK02dYrS8ook73mHGfmVMdj)dsLoJOUf8FnF(IYPoCYywEMGuE0lKJEFACzFnztFaRv2XJtxmsI8Gboi5KiXM(awRSJhNUyKSP1OoeipZ10KnWvmv6yGA5MSfR8SFnb05GVhc6CzdCftfUthq41Cs6IVG24nOnn5dEiOZL2EqoIL3Xrs6IVG2qWcMxZHK)bPsNru3c(VMpFr5uhozCzFBGRyQ0Xa1Ynzlw5z)AcOZbFpe05Yg4kMkCNoGWR5K0fFbTXBqBkeSG51Ci5FqQ0ze1TG)R5lIGvHqfB8ehJmUSVSze7XWjtlHiA1yv2EqUSP1Oou2nWrsVwjLpkqnzdCftLogOwUjBXkheqn3KOusiuE0lKJKlIGvHqfB8ehJY(ntiybZR5qY)GuPZiQBb)xZT9GCfY7cCYywEMGuE0lKJEFACzFnztFaRv2XJtxmsI8Gboi5KiXM(awRSJhNUyKSP1OoeipZ10KSze7XWjtlHiA1yv2EqUSP1Oou2nWrsVwjLpkqnzdCftLogOwUjBXkheqn3Kp4HGoxA7b5iwEhhjPl(cAdblyEnhs(hKkDgrDl4)AUThKRqExGtgx2x2mI9y4KPLqeTASkBpix20Auhk7g4iPxRKYhfOMSbUIPshdul3KTyLdcOMlemiyzfuN1cH4hmWHAFGAaeb14LNSMXqnEXSUzDGAd4OdQbqudkvx5v4ecQZyWG60MwdhOjrEjeSG51Ci5FqkVyGx3YBAjerRgRY2dYnUSVSze7XWjP10Xa1Qg4iLbksNt20AuhccwW8AoK8piLxmWRBb)xZP10Xa1Qg4iLbksNdcwW8AoK8piLxmWRBb)xZNVOCQdNmMLNjiLh9c5O3Ngx2xt20hWALD840fJKipyGdsojsSPpG1k74XPlgjBAnQdbYZCnnzdCftLogOgKxqNBYh8qqNlT9GCelVJJK0fFbTHGfmVMdj)ds5fd86wW)185lkN6WjJl7BdCftLogOgKxqNjeSG51Ci5FqkVyGx3c(VM3060isqiKYqDo1gx2xpe05YLWXrDDlkKp9QKU4lOneSG51Ci5FqkVyGx3c(VMJBmiQBr9fbYnUSVFaRv21kjbsHGfmVMdj)ds5fd86wW)185lkN6WjJz5zcs5rVqo69PXL91Kn9bSwzhpoDXijYdg4GKtIeB6dyTYoEC6IrYMwJ6qG8mxtt2ahj9ALu(OYbKf2orIg4kMkDmqniVGAojFWdbDU02dYrS8oossx8f0gcwW8AoK8piLxmWRBb)xZNVOCQdNmUSVnWrsVwjLpQCazHTtKObUIPshdudYlOMdeSG51Ci5FqkVyGx3c(VMB7b5iwEhhzCzF)awRe8siQBrTgmC1rsG0KOusiuE0lKJK2EqoIL3Xrz)MjeSG51Ci5FqkVyGx3c(VMJB6tnwLH6CQnUSVnWvmv6yGA5MSfR8SFbDMjBGJKETskFuGo7f2gcwW8AoK8piLxmWRBb)xZBADAejieszOoNAiybZR5qY)GuEXaVUf8Fn32dYrS8ooY4Y(IsjHq5rVqosA7b5iwEhhL9BMqWcMxZHK)bP8IbEDl4)A(8fLtD4KXS8mbP8Oxih9(04Y(AYM(awRSJhNUyKe5bdCqYjrIn9bSwzhpoDXiztRrDiqEMRPjBGRyQ0Xa1Ynzlw5zNzojs0ahLnOt(Ghc6CPThKJy5DCKKU4lOneSG51Ci5FqkVyGx3c(VMpFr5uhozCzFBGRyQ0Xa1Ynzlw5zNzojs0ahLnOHGfmVMdj)ds5fd86wW)18OzXrkF6Mo34Y(2axXuPJbQLBYwSYZoZCHGbblRG6S(rSHACu0ouZMBxEnhccwW8AoKKnITchfT)YWf1HuJvvmY4Y((bSwjBeBfokAxI8GbE25K0Rvs5JAxeilSneSG51CijBeBfokAh)xZz4I6qQXQkgzCzFn5dyTY0siIwnwLThKlBAnQdbY7cBJ3M8eF2mI9y4K2EqUH89kszb68YMIDEttK4dyTY0siIwnwLThKlBAnQdbsdCK0Rvs5Jc0MM8dyTY0siIwnwLThKlbstgpsD5KSy5vSYJnjKDCGdYBMqWcMxZHKSrSv4OOD8FnNHlQdPgRQyKXL99dyTY0siIwnwLThKlBAnQdbcEn5hWALahUrKxH8MUfhNSP1OoeilSnEBYt8zZi2JHtA7b5gY3RiLfOZlBk25nn5hWALahUrKxH8MUfhNSP1OouYpG1ktlHiA1yv2EqUeinz8i1LtYILxXkp2Kq2XboiVzcblyEnhsYgXwHJI2X)1CgUOoKASQIrgx2xt(awRSy5vSYJnjKnTg1HabutK4dyTYILxXkp2Kq20AuhcKg4iPxRKYhfOnn5hWALflVIvESjHeinz8i1LtYILxXkp2Kq2XbE2zcblyEnhsYgXwHJI2X)1CgUOoKASQIrgx23pG1klwEfR8ytcjqAYpG1kboCJiVc5nDloojqAY4rQlNKflVIvESjHSJd8SZecgeSG51CijBgXEmCOxaePkNwn(Iv6va0GtnsvhQ21aGulL1nUSVEiOZL)MchNASkuD7owguiPl(cAN0etyZi2JHtMwcr0QXQS9GCztRrDiqEFMBs8eDfFbjhhh1Q5uaisrGcGknL2MMiHjFaRvMwcr0QXQS9GCjqAYhWt0v8fKCCCuRMtbGifbkaQ0uABQPjsyYhWALPLqeTASkBpixcKM8bpe05YFtHJtnwfQUDhldkK0fFbTnfcwW8AoKKnJypgoe(VMdGiv50kY4Y(AcBgXEmCY0siIwnwLThKlBk25tKGnJypgozAjerRgRY2dYLnTg1HYoZCnnPjp4HGox(BkCCQXQq1T7yzqHKU4lODIeSze7XWjP10Xa1Qg4iLbksNt20Auhk7SCoMcblyEnhsYMrShdhc)xZbqKQCA14lwPx8cesHBmiO24Y(AcbkaQ0uAlfan4uJu1HQDnai1sz9KFaRvMwcr0QXQS9GCztRrDittKWKhiqbqLMsBPaObNAKQouTRbaPwkRN8dyTY0siIwnwLThKlBAnQdbYZmt(bSwzAjerRgRY2dYLaPMcblyEnhsYMrShdhc)xZbqKQCA14lwPxWVXvJvfhROZvwGoVXL9LnJypgojTMogOw1ahPmqr6CYMwJ6qzdQ5cblyEnhsYMrShdhc)xZbqKQCA14lwP3LEUfKkTR1qO6yHmUSVnWrG8c6Kp8bSwzAjerRgRY2dYLaPjn5HpG1k)nfoo1yvO62DSmOqcKMiXdEiOZL)MchNASkuD7owguiPl(cABkeSG51CijBgXEmCi8FnharQYPvJVyLE74XnWbos9RfvtB1hW95GGfmVMdjzZi2JHdH)R5aisvoTA8fR07k1e4oUaPSXTyCzFF4dyTYFtHJtnwfQUDhldkKaPjF4dyTY0siIwnwLThKlbsHGfmVMdjzZi2JHdH)R5PJxZzCzF)awRmTeIOvJvz7b5sG0KFaRvsRPJbQvnWrkduKoNeifcwW8AoKKnJypgoe(VM)fZSvwGoVXL99dyTY0siIwnwLThKlbst(bSwjTMogOw1ahPmqr6CsGuiybZR5qs2mI9y4q4)A(NAe1Gx3IXL99dyTY0siIwnwLThKlbsHGLvqDwRhKd1Sze7XWHGGfmVMdjzZi2JHdH)R5PLqeTASkBpi34Y(YMrShdNKwthduRAGJugOiDoztRrDiiybZR5qs2mI9y4q4)A(VPWXPgRcv3UJLbfgdGi1yTQf2(9PXL9LnJypgojTMogOw1ahPmqr6CYMwJ6qjzZi2JHtMwcr0QXQS9GCztRrDiiybZR5qs2mI9y4q4)AoTMogOw1ahPmqr6Cgx2x2mI9y4KPLqeTASkBpix2uSZN8bpe05YFtHJtnwfQUDhldkK0fFbTt2ahj9ALu(OYj7f2ozdCftLogOwUjBXkp73N5MiHxRKYh1UiqYmxiybZR5qs2mI9y4q4)AoTMogOw1ahPmqr6Cgx2xtyZi2JHtMwcr0QXQS9GCztXoFIeETskFu7IajZCnnPhc6C5VPWXPgRcv3UJLbfs6IVG2jBGRyQ0Xa1zNLYfcwW8AoKKnJypgoe(VMZcHqfmVMtjkKB8fR0lBeBfokA34Y(6HGoxYgXwHJI2L0fFbTtAIjFaRvYgXwHJI2LipyGN97ZCtUPpG1k74XPlgjrEWa)nhttKWRvs5JAxeiVlSTPqWcMxZHKSze7XWHW)1CBpi3q(EfPSaDEJl7RjFaRvMwcr0QXQS9GCztRrDiqExy7ejm5dyTY0siIwnwLThKlBAnQdbcEn5hWALahUrKxH8MUfhNSP1OoeiVlSDYpG1kboCJiVc5nDloojqQPMM8dyTY0siIwnwLThKlbstgpsD5KSy5vSYJnjKDCGdYBMqWcMxZHKSze7XWHW)1CBpi3q(EfPSaDEJl7RjFaRvwS8kw5XMeYMwJ6qG8UW2jsyYhWALflVIvESjHSP1Ooei41KFaRvcC4grEfYB6wCCYMwJ6qG8UW2j)awRe4WnI8kK30T44KaPMAAYpG1klwEfR8ytcjqAY4rQlNKflVIvESjHSJd8SZecwW8AoKKnJypgoe(VMB7b5gY3RiLfOZBCzF9ALu(O2fbYcBNiHjETskFu7IaHnJypgozAjerRgRY2dYLnTg1Hs(bSwjWHBe5viVPBXXjbsnfcgeSG51CijHq0Xi07xmZwnwLJJu0rR5nUSVFaRvMwcr0QXQS9GCztRrDiqEMBs2mI9y4K)MchNASkuD7owguiBAnQdLiXhWALPLqeTASkBpix20AuhcKN5M8bpe05YFtHJtnwfQUDhldkK0fFbTHGfmVMdjjeIogHW)18fGO3vCQXQIhPECCqWcMxZHKecrhJq4)AUDyaiARIhPUCs9Py14Y((WhWALPLqeTASkBpixcKM8HpG1k)nfoo1yvO62DSmOqcKcblyEnhssieDmcH)R5S5y05D40wzfXkzCzFF4dyTY0siIwnwLThKlbst(WhWAL)MchNASkuD7owguibstUhxYMJrN3HtBLveRK6d0NSP1Oo0BUqWcMxZHKecrhJq4)AEkqx281TO(Ia5gx23h(awRmTeIOvJvz7b5sG0Kp8bSw5VPWXPgRcv3UJLbfsGuiybZR5qscHOJri8Fn3W0InEO6unHMlogzCzFF4dyTY0siIwnwLThKlbst(WhWAL)MchNASkuD7owguibsHGfmVMdjjeIogHW)18UstfKQofknyKXL99HpG1ktlHiA1yv2EqUein5dFaRv(BkCCQXQq1T7yzqHeifcwW8AoKKqi6yec)xZxP1PZRgRsaWQTA3uSImUSVFaRvsRPJbQvnWrkduKoNSP1Ooei5K8dyTYFtHJtnwfQUDhldkKaPjsysdCK0Rvs5JkZSxy7KnWvmv6yGAqYjxtHGbblRG6Sy)IYPo8AoOUhp8AoiybZR5qY5lkN6WR5EBADAejieszOoNAJl7Rhc6C5s44OUUffYNEvsx8f0gcwW8AoKC(IYPo8Ao8FnF(IYPoCYywEMGuE0lKJEFACzFnztFaRv2XJtxmsI8Gboi5KiXM(awRSJhNUyKSP1OoeipZ10Kp4HGoxA7b5iwEhhjPl(cAN8HpG1k7ALKaPjrPKqO8OxihjXnge1TO(Ia5z)cAiybZR5qY5lkN6WR5W)185lkN6WjJl77dEiOZL2EqoIL3Xrs6IVG2jF4dyTYUwjjqAsukjekp6fYrsCJbrDlQViqE2VGgcwW8AoKC(IYPo8Ao8Fn32dYrS8ooY4Y(AYhWALGxcrDlQ1GHRos2uW8ejm5dyTsWlHOUf1AWWvhjbstAsAt4rTW2YNsBpixH8UaNsKiTj8OwyB5tjUXGOUf1xeiprI0MWJAHTLpLlIGvHqfB8ehJm1uttIsjHq5rVqosA7b5iwEhhL9BMqWcMxZHKZxuo1HxZH)R5Zxuo1HtgZYZeKYJEHC07tJl7RjB6dyTYoEC6IrsKhmWbjNej20hWALD840fJKnTg1Ha5zUMM8dyTsWlHOUf1AWWvhjBkyEIeM8bSwj4Lqu3IAny4QJKaPjnjTj8OwyB5tPThKRqExGtjsK2eEulST8Pe3yqu3I6lcKNirAt4rTW2YNYfrWQqOInEIJrMAkeSG51Ci58fLtD41C4)A(8fLtD4KXL99dyTsWlHOUf1AWWvhjBkyEIeM8bSwj4Lqu3IAny4QJKaPjnjTj8OwyB5tPThKRqExGtjsK2eEulST8Pe3yqu3I6lcKNirAt4rTW2YNYfrWQqOInEIJrMAkeSG51Ci58fLtD41C4)A(IiyviuXgpXXiJl7Rjp8bSwzxRKeinrIg4kMkDmqTCt2IvoipZnrIg4iPxRKYhvMzVW2MMeLscHYJEHCKCreSkeQyJN4yu2VzcblyEnhsoFr5uhEnh(VMJBmiQBr9fbYnUSVFaRv21kjbstIsjHq5rVqosIBmiQBr9fbYZ(ntiybZR5qY5lkN6WR5W)1CBpixH8UaNmMLNjiLh9c5O3Ngx2xt20hWALD840fJKipyGdsojsSPpG1k74XPlgjBAnQdbYZCnn5dFaRv21kjbstKObUIPshdul3KTyLdYZCtKObos61kP8rLz2lSDYh8qqNlT9GCelVJJK0fFbTHGfmVMdjNVOCQdVMd)xZT9GCfY7cCY4Y((WhWALDTssG0ejAGRyQ0Xa1Ynzlw5G8m3ejAGJKETskFuzM9cBdblyEnhsoFr5uhEnh(VMJBmiQBr9fbYnUSVFaRv21kjbsHGfmVMdjNVOCQdVMd)xZNVOCQdNmMLNjiLh9c5O3Ngx2xt20hWALD840fJKipyGdsojsSPpG1k74XPlgjBAnQdbYZCnn5dEiOZL2EqoIL3Xrs6IVG2qWcMxZHKZxuo1HxZH)R5Zxuo1HtqWGGLvqnMh3o6nuJQBrqGsE0lKd194HxZbblyEnhsI842rVFBADAejieszOoNAiybZR5qsKh3o6n(VMB7b5kK3f4KXL9LnJypgoztRtJibHqkd15ulBAnQdbYBM49cBN0dbDUCjCCux3Ic5tVkPl(cAdblyEnhsI842rVX)1CCJbrDlQViqUXL99dyTYUwjjqkeSG51CijYJBh9g)xZNVOCQdNmUSVp8bSwPTNhPtLciqKeinPhc6CPTNhPtLciqKKU4lOneSG51CijYJBh9g)xZT9GCfY7cCY4Y(2axXuPJbQLBYwSYbXKN5GVhc6CzdCftfUthq41Cs6IVG24nOnfcwW8AoKe5XTJEJ)R52EqoIL3Xrgx23pG1kbVeI6wuRbdxDKeinzdCK0Rvs5JcuZ(DHTHGfmVMdjrEC7O34)A(8fLtD4KXL9TbUIPshdul3KTyLNTjzMd(EiOZLnWvmv4oDaHxZjPl(cAJ3G2uiybZR5qsKh3o6n(VMB7b5kK3f4eeSG51CijYJBh9g)xZXn9PgRYqDo1qWcMxZHKipUD0B8FnpAwCKYNUPZ5yOuIXnkZCEYDUZ5a]] )


end
