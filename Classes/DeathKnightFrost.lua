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


    spec:RegisterPack( "Frost DK", 20190816, [[dGuhacqirv9irrztIuJIIQtjsSkrr6vuqZIc1TasODr0VejnmrLoMQWYev5zuGMgfqxtuY2Oa03asuJJcGZbKuRtuuX8aI7PkTprfheibTqrHhcKiMiqIKlcKeTrrrvNeijSsGQxkkQu3uuuj2jfYpffvsdfij1sbsGEketLIYxbsa7LWFr1GP0HPAXaEmktwjxgzZK6ZkvJgsoTKvdKK8AGYSj52kLDRYVvmCrCCrrSCPEoOPlCDv12bs9Di14bsK68QIwVOuZNISFOw8qyMaz5bjmkVCFaQZ1a8WakFKvUgWSEiqINjKajXzG57Ka58nsGK57bgylOuzUfij(t14lHzce48BgjqqfrcmZj1u3Ra1hqYMTuH12x5rnhRDDKkS2yPkqa(LkavCcabYYdsyuE5(auNRb4Hbu(WaZcuBqqzbI)dutlqqQnqjceu1ArNaqGSiitGKzyBMVhyGTGsrEGcBZCF1oQadEMHTOIibM5KAQ7vG6dizZwQWA7R8OMJ1UosfwBSuXGNzylOW)(hgy7ddOXyBE5(auJTGIy7JSYCYnxm4yWZmSfuck)2jyMdg8mdBbfXwqfht9xe2M5sDlSnZ3eLnjXGNzylOi2ckCTWwTRuaodmSvpn2(H1TJTGkbfeuaJXwq1tMhBln2MO8NuJT1vr5bbX2mgeSfG0ttyBYmQ62Xw1SxmSTGylB2suuqljg8mdBbfXwqjO8BNW2W7DkKrTr8y4RIW2yW2O2iEm8vryBmy7hsylDS5Fb1yRIU9af22EGIASnq5h2MmbDr5kSnAhIcBxKhOGsbIQGbuyMaHnQfhf5Dimty0dHzce6CafTeziqyDfuxUab4R1s2OwCuK3HegodmSnhSnlSnn2g1gXJHVkcBbbB3zlbIZIAobcdLxhKpAEXirimkpHzce6CafTeziqyDfuxUaXCSf4R1YKsP8MpAUUhyiBAZRdITG8IT7Sf2MPyR5y7dS1qSLnJAnOpPUhyG(zVb56F)u2KVEITPGTMmHTaFTwMukL38rZ19adztBEDqSfeST)hjJAJ4XWni2Mc2MgBb(ATmPukV5JMR7bgYFc2MgB9SPUcswSNCwf(IuY2pWWwqEX28eiolQ5eimuEDq(O5fJeHWidkmtGqNdOOLidbcRRG6YfiaFTwMukL38rZ19adztBEDqSfeS1aGTPXwGVwl)hQr9KdJMU9aLSPnVoi2cc2UZwyBMITMJTpWwdXw2mQ1G(K6EGb6N9gKR)9tzt(6j2Mc2MgBb(AT8FOg1tomA62duYM286GyBASf4R1YKsP8MpAUUhyi)jyBAS1ZM6kizXEYzv4lsjB)adBb5fBZtG4SOMtGWq51b5JMxmsecJmqHzce6CafTeziqyDfuxUaXCSf4R1YI9KZQWxKs20MxheBbbBnqS1KjSf4R1YI9KZQWxKs20MxheBbbB7)rYO2iEmCdITPGTPXwGVwll2toRcFrk5pbBtJTE2uxbjl2toRcFrkz7hyyBoyBEceNf1CcegkVoiF08IrIqyuwcZei05akAjYqGW6kOUCbcWxRLf7jNvHViL8NGTPXwGVwl)hQr9KdJMU9aL8NGTPXwpBQRGKf7jNvHViLS9dmSnhSnpbIZIAobcdLxhKpAEXiricbYaOQGApQ5eMjm6HWmbcDoGIwImeiSUcQlxGeUIUqU7bkQRBNdJP3K05akAjqCwuZjqAABAiPiiKJUUGArimkpHzce6CafTeziqCwuZjqgavfu7bjqyDfuxUaXCSDraFTw2E2txmscdNbg2cc2Mf2AYe2UiGVwlBp7PlgjBAZRdITGGTpYfBtbBtJT5JTHROlK6EGbK9mqrs6CafTW20yB(ylWxRLDTrYFc2MgBHjKsXdV3PakrnOv1TZbuomW2CEXwdkqypzkIhEVtbuy0drimYGcZei05akAjYqGW6kOUCbs(yB4k6cPUhyazpduKKohqrlSnn2Mp2c81AzxBK8NGTPXwycPu8W7DkGsudAvD7CaLddSnNxS1GceNf1CcKbqvb1EqIqyKbkmtGqNdOOLidbcRRG6YfiMJTaFTwcwPu1TZ3CgQ6iztolWwtMWwZXwGVwlbRuQ625BodvDK8NGTPXwZX2KManFNTKpK6EGbhgDbgHTMmHTjnbA(oBjFirnOv1TZbuomWwtMW2KManFNTKpK7kNvUI7lq7hJW2uW2uW2uW20ylmHukE49ofqPUhyazpdue2MZl2MNaXzrnNar3dmGSNbksecJYsyMaHohqrlrgceNf1CcKbqvb1Eqcewxb1LlqmhBxeWxRLTN90fJKWWzGHTGGTzHTMmHTlc4R1Y2ZE6IrYM286Gyliy7JCX2uW20ylWxRLGvkvD78nNHQos2KZcS1KjS1CSf4R1sWkLQUD(MZqvhj)jyBAS1CSnPjqZ3zl5dPUhyWHrxGryRjtyBstGMVZwYhsudAvD7CaLddS1KjSnPjqZ3zl5d5UYzLR4(c0(XiSnfSnfbc7jtr8W7DkGcJEicHrgqHzce6CafTeziqyDfuxUab4R1sWkLQUD(MZqvhjBYzb2AYe2Ao2c81AjyLsv3oFZzOQJK)eSnn2Ao2M0eO57SL8Hu3dm4WOlWiS1KjSnPjqZ3zl5djQbTQUDoGYHb2AYe2M0eO57SL8HCx5SYvCFbA)ye2Mc2MIaXzrnNazauvqThKiegbklmtGqNdOOLidbcRRG6YfiMJT5JTaFTw21gj)jyRjtyB)VIXtg0ulxKUyvGTGGTpYfBnzcB7)rYO2iEm88W2CW2D2cBtbBtJTWesP4H37uaL7kNvUI7lq7hJW2CEX28eiolQ5ei7kNvUI7lq7hJeHWidGWmbcDoGIwImeiSUcQlxGa81AzxBK8NGTPXwycPu8W7DkGsudAvD7CaLddSnNxSnpbIZIAobcQbTQUDoGYHHiegbQfMjqOZbu0sKHaXzrnNar3dm4WOlWibcRRG6YfiMJTlc4R1Y2ZE6Irsy4mWWwqW2SWwtMW2fb81Az7zpDXiztBEDqSfeS9rUyBkyBASnFSf4R1YU2i5pbBnzcB7)vmEYGMA5I0fRcSfeS9rUyRjtyB)psg1gXJHNh2Md2UZwyBASnFSnCfDHu3dmGSNbkssNdOOLaH9KPiE49ofqHrpeHWOh5kmtGqNdOOLidbcRRG6Yfi5JTaFTw21gj)jyRjtyB)VIXtg0ulxKUyvGTGGTpYfBnzcB7)rYO2iEm88W2CW2D2sG4SOMtGO7bgCy0fyKieg94HWmbcDoGIwImeiSUcQlxGa81AzxBK8NiqCwuZjqqnOv1TZbuomeHWOh5jmtGqNdOOLidbIZIAobYaOQGApibcRRG6YfiMJTlc4R1Y2ZE6Irsy4mWWwqW2SWwtMW2fb81Az7zpDXiztBEDqSfeS9rUyBkyBASnFSnCfDHu3dmGSNbkssNdOOLaH9KPiE49ofqHrpeHWOhguyMaXzrnNazauvqThKaHohqrlrgIqeceGbYJIbwD7cZeg9qyMaHohqrlrgcewxb1LlqyZOwd6tsBjdAQ59)ioAYtMt20MxhuG4SOMtGKukL38rZ19adrimkpHzceNf1CceAlzqtnV)hXrtEYCce6CafTezicHrguyMaHohqrlrgceNf1CcKbqvb1Eqcewxb1LlqmhBxeWxRLTN90fJKWWzGHTGGTzHTMmHTlc4R1Y2ZE6IrYM286Gyliy7JCX2uW20yB)VIXtg0uJTG8ITgmxSnn2Mp2gUIUqQ7bgq2ZafjPZbu0sGWEYuep8ENcOWOhIqyKbkmtGqNdOOLidbcRRG6Yfi9)kgpzqtn2cYl2AW8eiolQ5eidGQcQ9GeHWOSeMjqOZbu0sKHaH1vqD5cKWv0fYDpqrDD7Cym9MKohqrlbIZIAobstBtdjfbHC01fulcHrgqHzce6CafTeziqyDfuxUab4R1YU2i5prG4SOMtGGAqRQBNdOCyicHrGYcZei05akAjYqG4SOMtGmaQkO2dsGW6kOUCbI5y7Ia(ATS9SNUyKegodmSfeSnlS1KjSDraFTw2E2txms20MxheBbbBFKl2Mc2MgB7)rYO2iEm8SWwqW2D2cBnzcB7)vmEYGMASfKxS1aZcBtJT5JTHROlK6EGbK9mqrs6CafTeiSNmfXdV3Pakm6HiegzaeMjqOZbu0sKHaH1vqD5cK(FKmQnIhdplSfeSDNTWwtMW2(FfJNmOPgBb5fBnWSeiolQ5eidGQcQ9GeHWiqTWmbcDoGIwImeiSUcQlxGa81AjyLsv3oFZzOQJK)eSnn2ctiLIhEVtbuQ7bgq2ZafHT58IT5jqCwuZjq09adi7zGIeHWOh5kmtGqNdOOLidbcRRG6Yfi9)kgpzqtTCr6Ivb2MZl2AW8W20yB)psg1gXJHBqSnhSDNTeiolQ5eiOM(4JMJUUGArim6XdHzceNf1CcKM2Mgskcc5ORlOwGqNdOOLidrim6rEcZei05akAjYqGW6kOUCbcmHukE49ofqPUhyazpdue2MZl2MNaXzrnNar3dmGSNbksecJEyqHzce6CafTeziqCwuZjqgavfu7bjqyDfuxUaXCSDraFTw2E2txmscdNbg2cc2Mf2AYe2UiGVwlBp7PlgjBAZRdITGGTpYfBtbBtJT9)kgpzqtTCr6Ivb2Md2MxwyRjtyB)pcBZbBni2MgBZhBdxrxi19adi7zGIK05akAjqypzkIhEVtbuy0drim6HbkmtGqNdOOLidbcRRG6Yfi9)kgpzqtTCr6Ivb2Md2MxwyRjtyB)pcBZbBnOaXzrnNazauvqThKieg9ilHzce6CafTeziqyDfuxUaP)xX4jdAQLlsxSkW2CW28YvG4SOMtG4nZpIht30fIqececcPJrqHzcJEimtGqNdOOLidbcRRG6YfiaFTwMukL38rZ19adztBEDqSfeS9rUyBASLnJAnOpjqtEGIpAoSUv77d0LnT51bXwtMWwGVwltkLYB(O56EGHSPnVoi2cc2(ixSnn2Mp2gUIUqc0KhO4JMdRB1((aDjDoGIwceNf1Ccea1ml(O5bkIthT9uecJYtyMaXzrnNaz)79Q8JpAUNn1tGsGqNdOOLidrimYGcZei05akAjYqGW6kOUCbcWxRLjLs5nF0CDpWq20MxheBbbBZcBnzcBJAJ4XWxfHTGGTzjqCwuZjqyOkLIdJMCWeHWiduyMaHohqrlrgcewxb1Llqa(ATSjgykcc56PzK8NGTMmHTaFTw2edmfbHC90mIZM)fulHHZadBbbBF8qG4SOMtGeOi()aM)T46PzKiegLLWmbcDoGIwImeiSUcQlxGKp2c81AzsPuEZhnx3dmK)eSnn2Mp2c81AjqtEGIpAoSUv77d0L)ebIZIAobIEyFiT4E2uxbXbiFtecJmGcZei05akAjYqGW6kOUCbs(ylWxRLjLs5nF0CDpWq(tW20yB(ylWxRLan5bk(O5W6wTVpqx(tW20y7AcjBogDr7bT4ALVrCGFFYM286Gy7l2MRaXzrnNaHnhJUO9GwCTY3irimcuwyMaHohqrlrgcewxb1LlqYhBb(ATmPukV5JMR7bgYFc2MgBZhBb(ATeOjpqXhnhw3Q99b6YFIaXzrnNaj53L(zD7CaLddrimYaimtGqNdOOLidbcRRG6Yfi5JTaFTwMukL38rZ19ad5pbBtJT5JTaFTwc0KhO4JMdRB1((aD5prG4SOMtGGEA1c0uD8MGZ5hJeHWiqTWmbcDoGIwImeiSUcQlxGKp2c81AzsPuEZhnx3dmK)eSnn2Mp2c81AjqtEGIpAoSUv77d0L)ebIZIAobsxjjkIxhhM4msecJEKRWmbcDoGIwImeiSUcQlxGa81AjTLmOPM3)J4OjpzoztBEDqSfeSnlSnn2c81AjqtEGIpAoSUv77d0L)eS1KjS1CST)hjJAJ4XWZdBZbB3zlSnn22)Ry8Kbn1yliyBw5ITPiqCwuZjq2OTPFYhnx9z1IVAY3GIqeceGbYtMrv3UWmHrpeMjqOZbu0sKHaH1vqD5ceGVwl7AJK)ebIZIAobcQbTQUDoGYHHiegLNWmbcDoGIwImeiolQ5eidGQcQ9GeiSUcQlxGyo2UiGVwlBp7PlgjHHZadBbbBZcBnzcBxeWxRLTN90fJKnT51bXwqW2h5ITPGTPX2(FfJNmOPwUiDXQaBZ5fBZllSnn2Mp2gUIUqQ7bgq2ZafjPZbu0sGWEYuep8ENcOWOhIqyKbfMjqOZbu0sKHaH1vqD5cK(FfJNmOPwUiDXQaBZ5fBZllbIZIAobYaOQGApirimYafMjqOZbu0sKHaH1vqD5cK(FfJNmOPwUiDXQaBbbBZlxSnn2ctiLIhEVtbuURCw5kUVaTFmcBZ5fBZdBtJTSzuRb9jtkLYB(O56EGHSPnVoi2Md2MLaXzrnNazx5SYvCFbA)yKiegLLWmbcDoGIwImeiolQ5ei6EGbhgDbgjqyDfuxUaXCSDraFTw2E2txmscdNbg2cc2Mf2AYe2UiGVwlBp7PlgjBAZRdITGGTpYfBtbBtJT9)kgpzqtTCr6Ivb2cc2MxUyBASnFSnCfDHu3dmGSNbkssNdOOf2MgBzZOwd6tMukL38rZ19adztBEDqSnhSnlbc7jtr8W7DkGcJEicHrgqHzce6CafTeziqyDfuxUaP)xX4jdAQLlsxSkWwqW28YfBtJTSzuRb9jtkLYB(O56EGHSPnVoi2Md2MLaXzrnNar3dm4WOlWirimcuwyMaHohqrlrgcewxb1Llqa(ATeSsPQBNV5mu1rYFc2MgB7)vmEYGMA5I0fRcSnhS1CS9rwyRHyB4k6cz)VIX9iO77rnNKohqrlSntXwdITPGTPXwycPu8W7DkGsDpWaYEgOiSnNxSnpbIZIAobIUhyazpduKiegzaeMjqOZbu0sKHaH1vqD5cK(FfJNmOPwUiDXQaBZ5fBnhBnywyRHyB4k6cz)VIX9iO77rnNKohqrlSntXwdITPGTPXwycPu8W7DkGsDpWaYEgOiSnNxSnpbIZIAobIUhyazpduKiegbQfMjqOZbu0sKHaXzrnNazauvqThKaH1vqD5ceZX2fb81Az7zpDXijmCgyyliyBwyRjty7Ia(ATS9SNUyKSPnVoi2cc2(ixSnfSnn22)Ry8Kbn1YfPlwfyBoVyR5yRbZcBneBdxrxi7)vmUhbDFpQ5K05akAHTzk2AqSnfSnn2Mp2gUIUqQ7bgq2ZafjPZbu0sGWEYuep8ENcOWOhIqy0JCfMjqOZbu0sKHaH1vqD5cK(FfJNmOPwUiDXQaBZ5fBnhBnywyRHyB4k6cz)VIX9iO77rnNKohqrlSntXwdITPiqCwuZjqgavfu7bjcHrpEimtGqNdOOLidbcRRG6YfiSzuRb9jtkLYB(O56EGHSPnVoi2Md22)JKrTr8y4gi2MgB7)vmEYGMA5I0fRcSfeS1aZfBtJTWesP4H37uaL7kNvUI7lq7hJW2CEX28eiolQ5ei7kNvUI7lq7hJeHWOh5jmtGqNdOOLidbIZIAobIUhyWHrxGrcewxb1LlqmhBxeWxRLTN90fJKWWzGHTGGTzHTMmHTlc4R1Y2ZE6IrYM286Gyliy7JCX2uW20ylBg1AqFYKsP8MpAUUhyiBAZRdIT5GT9)izuBepgUbITPX2(FfJNmOPwUiDXQaBbbBnWCX20yB(yB4k6cPUhyazpduKKohqrlbc7jtr8W7DkGcJEicHrpmOWmbcDoGIwImeiSUcQlxGWMrTg0NmPukV5JMR7bgYM286GyBoyB)psg1gXJHBGyBAST)xX4jdAQLlsxSkWwqWwdmxbIZIAobIUhyWHrxGrIqecKKMyZgGhcZeg9qyMaXzrnNajzIAobcDoGIwImeHWO8eMjqOZbu0sKHa58nsG4zdr5Td565c(O5jdAQfiolQ5eiE2quE7qUEUGpAEYGMArimYGcZei05akAjYqGmjceifceNf1Cceq7D5aksGaAx9jbI5ylLj)kjHwYBIPR5d57kFvEmnKd4RDcBnzcBPm5xjj0scRRGb18DLVkpMgYb81oHTMmHTuM8RKeAjH1vWGA(UYxLhtd5B0YvQAoS1KjSLYKFLKqljOlxXhn3VAZdAXbuZSWwtMWwkt(vscTK6QHbFZdcYHjp3voeITMmHTuM8RKeAjbvrqoQbTIAS1KjSLYKFLKql5nX018H8DLVkpMgY3OLRu1CyRjtylLj)kjHwshIc0(rqE7zpnNnTRW2ueiG2B(5BKazcuuZNJ)HeNYKFLKqlricbcBg1AqFqHzcJEimtGqNdOOLidbcRRG6YfiMJTSzuRb9jPTKbn18(Fehn5jZjBYxpX20yB(ylO9UCafjNaf1854FiXPm5xjj0cBtbBnzcBnhBzZOwd6tMukL38rZ19adztBEDqSfKxS9rUyBASf0ExoGIKtGIA(C8pK4uM8RKeAHTPiqoFJeiE2quE7qUEUGpAEYGMAbIZIAobINneL3oKRNl4JMNmOPwecJYtyMaHohqrlrgcewxb1LlqcxrxibAYdu8rZH1TAFFGUKohqrlSnn2Ao2Ao2YMrTg0NmPukV5JMR7bgYM286GyliVy7JCX20ylO9UCafjNaf1854FiXPm5xjj0cBtbBnzcBnhBb(ATmPukV5JMR7bgYFc2MgBZhBbT3LdOi5eOOMph)djoLj)kjHwyBkyBkyRjtyR5ylWxRLjLs5nF0CDpWq(tW20yB(yB4k6cjqtEGIpAoSUv77d0L05akAHTPiqoFJeiQFdg1qEDWAvZhY3lDiqCwuZjqu)gmQH86G1QMpKVx6qecJmOWmbcDoGIwImeiSUcQlxGyo2YMrTg0NmPukV5JMR7bgYM81tS1KjSLnJAnOpzsPuEZhnx3dmKnT51bX2CW28YfBtbBtJTMJT5JTHROlKan5bk(O5W6wTVpqxsNdOOf2AYe2YMrTg0NK2sg0uZ7)rC0KNmNSPnVoi2Md2cQZcBtrG4SOMtG8HeVcAdkcHrgOWmbcDoGIwImeiSUcQlxGSiGVwlBp7P5SPDfFraFTwUg0Na58nsG4quG2pcYBp7P5SPDLaXzrnNaXHOaTFeK3E2tZzt7krimklHzce6CafTeziqyDfuxUaHnJAnOpjTLmOPM3)J4OjpzoztBEDqSnhSfuNl2MgBxeWxRLTN90C20UIViGVwl)jyBASf0ExoGIKtGIA(C8pK4uM8RKeAHTMmHTaFTwc0KhO4JMdRB1((aD5pbBtJTlc4R1Y2ZEAoBAxXxeWxRL)eSnn2Mp2cAVlhqrYjqrnFo(hsCkt(vscTWwtMWwGVwlPTKbn18(Fehn5jZj)jyBASDraFTw2E2tZzt7k(Ia(AT8NGTPX28X2Wv0fsGM8afF0CyDR23hOlPZbu0cBnzcBJAJ4XWxfHTGGT59qGC(gjqCikq7hb5TN90C20UsG4SOMtG4quG2pcYBp7P5SPDLiegzafMjqOZbu0sKHaH1vqD5ceZXwkt(vscTKQFdg1qEDWAvZhY3lDGTPXwGVwltkLYB(O56EGHSPnVoi2Mc2AYe2Ao2Mp2szYVssOLu9BWOgYRdwRA(q(EPdSnn2c81AzsPuEZhnx3dmKnT51bXwqW2h5HTPXwGVwltkLYB(O56EGH8NGTPiqoFJeiGQiih1GwrTaXzrnNabufb5Og0kQfHWiqzHzce6CafTeziqyDfuxUaHnJAnOpjTLmOPM3)J4OjpzoztBEDqSnhS1aZvGC(gjqa7MGpAUFSIUGR)9tbIZIAobcy3e8rZ9Jv0fC9VFkcHrgaHzce6CafTeziqyDfuxUaP)hHTG8ITgeBtJT5JTaFTwMukL38rZ19ad5pbBtJTMJT5JTaFTwc0KhO4JMdRB1((aD5pbBnzcBZhBdxrxibAYdu8rZH1TAFFGUKohqrlSnfbY5BKazVNBhYt6AZv823jbIZIAobYEp3oKN01MR4TVtIqyeOwyMaHohqrlrgcKZ3ibs7zV(hyqoqTZBAXb(rmNaXzrnNaP9Sx)dmihO25nT4a)iMtecJEKRWmbcDoGIwImeiSUcQlxGKp2c81AjqtEGIpAoSUv77d0L)eSnn2Mp2c81AzsPuEZhnx3dmK)ebY5BKazJAcSaLd5A)2fiolQ5eiButGfOCix73Uieg94HWmbcDoGIwImeiSUcQlxGa81AzsPuEZhnx3dmK)eSnn2c81AjTLmOPM3)J4Ojpzo5prG4SOMtGKmrnNieg9ipHzce6CafTeziqyDfuxUab4R1YKsP8MpAUUhyi)jyBASf4R1sAlzqtnV)hXrtEYCYFIaXzrnNabqnZIR)9trim6HbfMjqOZbu0sKHaH1vqD5ceGVwltkLYB(O56EGH8NiqCwuZjqaOgsny1TlcHrpmqHzce6CafTeziqyDfuxUaHnJAnOpjTLmOPM3)J4OjpzoztBEDqbIZIAobssPuEZhnx3dmeHWOhzjmtGqNdOOLidbIZIAobcqtEGIpAoSUv77d0fiSUcQlxGWMrTg0NK2sg0uZ7)rC0KNmNSPnVoi2MgBzZOwd6tMukL38rZ19adztBEDqbYhs8rR57SLa5Hieg9WakmtGqNdOOLidbcRRG6YfiSzuRb9jtkLYB(O56EGHSjF9eBtJT5JTHROlKan5bk(O5W6wTVpqxsNdOOf2MgB7)rYO2iEm8SW2CW2D2cBtJT9)kgpzqtTCr6Ivb2MZl2(ixS1KjSnQnIhdFve2cc2MxUceNf1CceAlzqtnV)hXrtEYCIqy0dqzHzce6CafTeziqyDfuxUaXCSLnJAnOpzsPuEZhnx3dmKn5RNyRjtyBuBepg(QiSfeSnVCX2uW20yB4k6cjqtEGIpAoSUv77d0L05akAHTPX2(FfJNmOPgBZbBnG5kqCwuZjqOTKbn18(Fehn5jZjcHrpmacZei05akAjYqGW6kOUCbs4k6cjBulokY7qsNdOOf2MgBnhBnhBb(ATKnQfhf5DiHHZadBZ5fBFKl2MgBxeWxRLTN90fJKWWzGHTVyBwyBkyRjtyBuBepg(QiSfKxSDNTW2ueiolQ5eimxP4olQ54Qcgcevbd(5BKaHnQfhf5DicHrpa1cZei05akAjYqGW6kOUCbI5ylWxRLjLs5nF0CDpWq20MxheBb5fB3zlS1KjS1CSf4R1YKsP8MpAUUhyiBAZRdITGGTgaSnn2c81A5)qnQNCy00ThOKnT51bXwqEX2D2cBtJTaFTw(puJ6jhgnD7bk5pbBtbBtbBtJTaFTwMukL38rZ19ad5pbBtJTE2uxbjl2toRcFrkz7hyyliVyBEceNf1CceDpWa9ZEdY1)(PiegLxUcZei05akAjYqGW6kOUCbI5ylWxRLf7jNvHViLSPnVoi2cYl2UZwyRjtyR5ylWxRLf7jNvHViLSPnVoi2cc2AaW20ylWxRL)d1OEYHrt3EGs20MxheBb5fB3zlSnn2c81A5)qnQNCy00ThOK)eSnfSnfSnn2c81AzXEYzv4lsj)jyBAS1ZM6kizXEYzv4lsjB)adBZbBZtG4SOMtGO7bgOF2BqU(3pfHWO8EimtGqNdOOLidbcRRG6YfirTr8y4RIWwqW2D2cBnzcBnhBJAJ4XWxfHTGGTSzuRb9jtkLYB(O56EGHSPnVoi2MgBb(AT8FOg1tomA62duYFc2MIaXzrnNar3dmq)S3GC9VFkcriqGHFlVxcZeg9qyMaXzrnNaPPTPHKIGqo66cQfi05akAjYqecJYtyMaHohqrlrgcewxb1LlqyZOwd6t2020qsrqihDDb1YM286GyliVyBEyBMIT7Sf2MgBdxrxi39af11TZHX0Bs6CafTeiolQ5ei6EGbhgDbgjcHrguyMaHohqrlrgcewxb1Llqa(ATSRns(teiolQ5eiOg0Q625akhgIqyKbkmtGqNdOOLidbcRRG6Yfi5JTaFTwQ7jB64jFfKK)eSnn2gUIUqQ7jB64jFfKK05akAjqCwuZjqgavfu7bjcHrzjmtGqNdOOLidbcRRG6Yfi9)kgpzqtTCr6Ivb2cc2Ao2(ilS1qSnCfDHS)xX4Ee099OMtsNdOOf2MPyRbX2ueiolQ5ei6EGbhgDbgjcHrgqHzce6CafTeziqyDfuxUab4R1sWkLQUD(MZqvhj)jyBAST)hjJAJ4XWnqSnNxSDNTeiolQ5ei6EGbK9mqrIqyeOSWmbcDoGIwImeiSUcQlxG0)Ry8Kbn1YfPlwfyBoyR5yBEzHTgITHROlK9)kg3JGUVh1Cs6CafTW2mfBni2MIaXzrnNazauvqThKiegzaeMjqCwuZjq09adom6cmsGqNdOOLidrimculmtG4SOMtGGA6JpAo66cQfi05akAjYqecJEKRWmbIZIAobI3m)iEmDtxiqOZbu0sKHieHazrA)RcHzcJEimtG4SOMtGSv3IRBIYMei05akAjYqecJYtyMaHohqrlrgcewxb1LlqYhBxti19adUMan1YOyGv3o2MgBnhBZhBdxrxibAYdu8rZH1TAFFGUKohqrlS1KjSLnJAnOpjqtEGIpAoSUv77d0LnT51bX2CW2hzHTPiqCwuZjqqnOv1TZbuomeHWidkmtGqNdOOLidbcRRG6YfiaFTwwSN8WvZbLnT51bXwqEX2D2cBtJTaFTwwSN8WvZbL)eSnn2ctiLIhEVtbuURCw5kUVaTFmcBZ5fBZdBtJTMJT5JTHROlKan5bk(O5W6wTVpqxsNdOOf2AYe2YMrTg0NeOjpqXhnhw3Q99b6YM286GyBoy7JSW2ueiolQ5ei7kNvUI7lq7hJeHWiduyMaHohqrlrgcewxb1Llqa(ATSyp5HRMdkBAZRdITG8IT7Sf2MgBb(ATSyp5HRMdk)jyBAS1CSnFSnCfDHeOjpqXhnhw3Q99b6s6CafTWwtMWw2mQ1G(Kan5bk(O5W6wTVpqx20MxheBZbBFKf2MIaXzrnNar3dm4WOlWirimklHzce6CafTeziqCwuZjqyUsXDwuZXvfmeiQcg8Z3ibcbH0XiOiegzafMjqOZbu0sKHaXzrnNaH5kf3zrnhxvWqGOkyWpFJeiSzuRb9bfHWiqzHzce6CafTeziqyDfuxUajCfDHeOjpqXhnhw3Q99b6s6CafTW20yR5yR5ylBg1AqFsGM8afF0CyDR23hOlBAZRdITVyBUyBASLnJAnOpzsPuEZhnx3dmKnT51bXwqW2h5ITPGTMmHTMJTSzuRb9jbAYdu8rZH1TAFFGUSPnVoi2cc2MxUyBASnQnIhdFve2cc2AWSW2uW2ueiolQ5ei9)4olQ54Qcgcevbd(5BKabyG8Kzu1TlcHrgaHzce6CafTeziqyDfuxUab4R1sGM8afF0CyDR23hOl)jceNf1CcK(FCNf1CCvbdbIQGb)8nsGamqEumWQBxecJa1cZei05akAjYqGW6kOUCbcWxRLjLs5nF0CDpWq(tW20yB4k6c5aOQGApQ5K05akAjqCwuZjq6)XDwuZXvfmeiQcg8Z3ibYaOQGApQ5eHWOh5kmtGqNdOOLidbcRRG6YfiolkqtC6OTIGyBoVyBEceNf1CcK(FCNf1CCvbdbIQGb)8nsG4djcHrpEimtGqNdOOLidbIZIAobcZvkUZIAoUQGHarvWGF(gjqGHFlVxIqeceFiHzcJEimtGqNdOOLidbcRRG6YfiHROlK7EGI6625Wy6njDoGIwyRjtyR5yRNn1vqsDpzthpOTecgY2pWW20ylmHukE49ofqztBtdjfbHC01fuJT58ITgeBtJT5JTaFTw21gj)jyBkceNf1CcKM2Mgskcc5ORlOwecJYtyMaHohqrlrgcewxb1Llqcxrxi19adi7zGIK05akAjqCwuZjq2voRCf3xG2pgjcHrguyMaHohqrlrgceNf1CceDpWGdJUaJeiSUcQlxGyo2UiGVwlBp7PlgjHHZadBbbBZcBnzcBxeWxRLTN90fJKnT51bXwqW2h5ITPGTPXw2mQ1G(KnTnnKueeYrxxqTSPnVoi2cYl2Mh2MPy7oBHTPX2Wv0fYDpqrDD7Cym9MKohqrlSnn2Mp2gUIUqQ7bgq2ZafjPZbu0sGWEYuep8ENcOWOhIqyKbkmtGqNdOOLidbcRRG6YfiSzuRb9jBABAiPiiKJUUGAztBEDqSfKxSnpSntX2D2cBtJTHROlK7EGI6625Wy6njDoGIwceNf1CceDpWGdJUaJeHWOSeMjqOZbu0sKHaH1vqD5ceGVwl7AJK)ebIZIAobcQbTQUDoGYHHiegzafMjqOZbu0sKHaH1vqD5ceGVwlbRuQ625BodvDK8NiqCwuZjq09adi7zGIeHWiqzHzce6CafTeziqyDfuxUaP)xX4jdAQLlsxSkWwqWwZX2hzHTgITHROlK9)kg3JGUVh1Cs6CafTW2mfBni2MIaXzrnNazx5SYvCFbA)yKiegzaeMjqOZbu0sKHaXzrnNar3dm4WOlWibcRRG6YfiMJTlc4R1Y2ZE6Irsy4mWWwqW2SWwtMW2fb81Az7zpDXiztBEDqSfeS9rUyBkyBAST)xX4jdAQLlsxSkWwqWwZX2hzHTgITHROlK9)kg3JGUVh1Cs6CafTW2mfBni2Mc2MgBZhBdxrxi19adi7zGIK05akAjqypzkIhEVtbuy0drimculmtGqNdOOLidbcRRG6Yfi9)kgpzqtTCr6Ivb2cc2Ao2(ilS1qSnCfDHS)xX4Ee099OMtsNdOOf2MPyRbX2uW20yB(yB4k6cPUhyazpduKKohqrlbIZIAobIUhyWHrxGrIqy0JCfMjqCwuZjqAABAiPiiKJUUGAbcDoGIwImeHWOhpeMjqCwuZjq09adi7zGIei05akAjYqecJEKNWmbcDoGIwImeiolQ5eidGQcQ9GeiSUcQlxGyo2UiGVwlBp7PlgjHHZadBbbBZcBnzcBxeWxRLTN90fJKnT51bXwqW2h5ITPGTPX2(FfJNmOPwUiDXQaBZbBnhBZllS1qSnCfDHS)xX4Ee099OMtsNdOOf2MPyRbX2uW20yB(yB4k6cPUhyazpduKKohqrlbc7jtr8W7DkGcJEicHrpmOWmbcDoGIwImeiSUcQlxG0)Ry8Kbn1YfPlwfyBoyR5yBEzHTgITHROlK9)kg3JGUVh1Cs6CafTW2mfBni2MIaXzrnNazauvqThKieg9WafMjqCwuZjq2voRCf3xG2pgjqOZbu0sKHieg9ilHzce6CafTeziqCwuZjq09adom6cmsGW6kOUCbI5y7Ia(ATS9SNUyKegodmSfeSnlS1KjSDraFTw2E2txms20MxheBbbBFKl2Mc2MgBZhBdxrxi19adi7zGIK05akAjqypzkIhEVtbuy0drim6HbuyMaXzrnNar3dm4WOlWibcDoGIwImeHWOhGYcZeiolQ5eiOM(4JMJUUGAbcDoGIwImeHWOhgaHzceNf1CceVz(r8y6MUqGqNdOOLidricriqan1WAoHr5L7dqDUgGCnOmVhgywce0EF1TdfiGk2sMoOf2(ixS1zrnh2QkyaLyWfiWeIjmkVSEiqs6rxksGKzyBMVhyGTGsrEGcBZCF1oQadEMHTOIibM5KAQ7vG6dizZwQWA7R8OMJ1UosfwBSuXGNzylOW)(hgy7ddOXyBE5(auJTGIy7JSYCYnxm4yWZmSfuck)2jyMdg8mdBbfXwqfht9xe2M5sDlSnZ3eLnjXGNzylOi2ckCTWwTRuaodmSvpn2(H1TJTGkbfeuaJXwq1tMhBln2MO8NuJT1vr5bbX2mgeSfG0ttyBYmQ62Xw1SxmSTGylB2suuqljg8mdBbfXwqjO8BNW2W7DkKrTr8y4RIW2yW2O2iEm8vryBmy7hsylDS5Fb1yRIU9af22EGIASnq5h2MmbDr5kSnAhIcBxKhOGsm4yWZmSfujO0e7h0cBbi90e2YMnapWwaAVoOeBbfYyusaX2BoqruEVP)kS1zrnheBNt9uIbpZWwNf1CqzstSzdWJxTYHGHbpZWwNf1CqzstSzdWddFtvpZcdEMHTolQ5GYKMyZgGhg(MQ)33Ol8OMddEMHTiNNarnb22ETWwGVwtlSfgEaXwaspnHTSzdWdSfG2RdIT(TW2KMaftMiQBhBli2UMJKyWZmS1zrnhuM0eB2a8WW3uHNNarnbhgEaXG7SOMdktAInBaEy4BQjtuZHb3zrnhuM0eB2a8WW3u)qIxbTz85B0RNneL3oKRNl4JMNmOPgdUZIAoOmPj2Sb4HHVPcAVlhqrgF(g9obkQ5ZX)qItzYVssOLXG2vF61Ckt(vscTK3etxZhY3v(Q8yAihWx7KjtuM8RKeAjH1vWGA(UYxLhtd5a(ANmzIYKFLKqljSUcguZ3v(Q8yAiFJwUsvZzYeLj)kjHwsqxUIpAUF1Mh0IdOMzzYeLj)kjHwsD1WGV5bb5WKN7khcnzIYKFLKqljOkcYrnOvuBYeLj)kjHwYBIPR5d57kFvEmnKVrlxPQ5mzIYKFLKqlPdrbA)iiV9SNMZM2vPGbhdEMHTGkbLMy)GwylbAQFITrTryBGIWwNftJTfeBDq7LYbuKedUZIAo47wDlUUjkBcdEMHTGctsupX2mFpWaBZ8eOPgB9BHTBEDHxh2cQG9eBnZvZbXG7SOMdA4BQOg0Q625akhggx638xti19adUMan1YOyGv3EAZZpCfDHeOjpqXhnhw3Q99b6s6CafTmzInJAnOpjqtEGIpAoSUv77d0LnT51bZ5rwPGb3zrnh0W3u3voRCf3xG2pgzCPFb(ATSyp5HRMdkBAZRdcY7oBLg4R1YI9KhUAoO8NKgMqkfp8ENcOCx5SYvCFbA)yuoV5L288dxrxibAYdu8rZH1TAFFGUKohqrltMyZOwd6tc0KhO4JMdRB1((aDztBEDWCEKvkyWDwuZbn8nvDpWGdJUaJmU0VaFTwwSN8WvZbLnT51bb5DNTsd81AzXEYdxnhu(tsBE(HROlKan5bk(O5W6wTVpqxsNdOOLjtSzuRb9jbAYdu8rZH1TAFFGUSPnVoyopYkfm4olQ5Gg(MkZvkUZIAoUQGHXNVrVeeshJGyWDwuZbn8nvMRuCNf1CCvbdJpFJEzZOwd6dIb3zrnh0W3u7)XDwuZXvfmm(8n6fyG8Kzu1TBCPFdxrxibAYdu8rZH1TAFFGUKohqrR0MBoBg1AqFsGM8afF0CyDR23hOlBAZRd(MBA2mQ1G(KjLs5nF0CDpWq20MxheKh5MIjtMZMrTg0NeOjpqXhnhw3Q99b6YM286GGKxUPJAJ4XWxfbIbZkLuWG7SOMdA4BQ9)4olQ54QcggF(g9cmqEumWQB34s)c81AjqtEGIpAoSUv77d0L)em4olQ5Gg(MA)pUZIAoUQGHXNVrVdGQcQ9OMZ4s)c81AzsPuEZhnx3dmK)K0HROlKdGQcQ9OMtsNdOOfgCNf1CqdFtT)h3zrnhxvWW4Z3OxFiJl9RZIc0eNoARiyoV5Hb3zrnh0W3uzUsXDwuZXvfmm(8n6fg(T8EHbhdUZIAoO0h6TPTPHKIGqo66cQnU0VHROlK7EGI6625Wy6njDoGIwMmzUNn1vqsDpzthpOTecgY2pWsdtiLIhEVtbu2020qsrqihDDb158AW05d81AzxBK8NKcgCNf1CqPpKHVPURCw5kUVaTFmY4s)gUIUqQ7bgq2ZafjPZbu0cdUZIAoO0hYW3u19adom6cmYy2tMI4H37uaFFyCPFnFraFTw2E2txmscdNbgizzY0Ia(ATS9SNUyKSPnVoiipYnL0SzuRb9jBABAiPiiKJUUGAztBEDqqEZlt3zR0HROlK7EGI6625Wy6njDoGIwPZpCfDHu3dmGSNbkssNdOOfgCNf1CqPpKHVPQ7bgCy0fyKXL(LnJAnOpztBtdjfbHC01fulBAZRdcYBEz6oBLoCfDHC3duux3ohgtVjPZbu0cdUZIAoO0hYW3urnOv1TZbuommU0VaFTw21gj)jyWDwuZbL(qg(MQUhyazpduKXL(f4R1sWkLQUD(MZqvhj)jyWDwuZbL(qg(M6UYzLR4(c0(XiJl9B)VIXtg0ulxKUyvaI5pYYWWv0fY(FfJ7rq33JAojDoGIwzQbtbdUZIAoO0hYW3u19adom6cmYy2tMI4H37uaFFyCPFnFraFTw2E2txmscdNbgizzY0Ia(ATS9SNUyKSPnVoiipYnL09)kgpzqtTCr6IvbiM)ilddxrxi7)vmUhbDFpQ5K05akALPgmL05hUIUqQ7bgq2ZafjPZbu0cdUZIAoO0hYW3u19adom6cmY4s)2)Ry8Kbn1YfPlwfGy(JSmmCfDHS)xX4Ee099OMtsNdOOvMAWusNF4k6cPUhyazpduKKohqrlm4olQ5GsFidFtTPTPHKIGqo66cQXG7SOMdk9Hm8nvDpWaYEgOim4olQ5GsFidFtDauvqThKXSNmfXdV3Pa((W4s)A(Ia(ATS9SNUyKegodmqYYKPfb81Az7zpDXiztBEDqqEKBkP7)vmEYGMA5I0fRICmpVSmmCfDHS)xX4Ee099OMtsNdOOvMAWusNF4k6cPUhyazpduKKohqrlm4olQ5GsFidFtDauvqThKXL(T)xX4jdAQLlsxSkYX88YYWWv0fY(FfJ7rq33JAojDoGIwzQbtbdUZIAoO0hYW3u3voRCf3xG2pgHb3zrnhu6dz4BQ6EGbhgDbgzm7jtr8W7DkGVpmU0VMViGVwlBp7PlgjHHZadKSmzAraFTw2E2txms20MxheKh5Ms68dxrxi19adi7zGIK05akAHb3zrnhu6dz4BQ6EGbhgDbgHb3zrnhu6dz4BQOM(4JMJUUGAm4olQ5GsFidFt1BMFepMUPlWGJbpZW2mAYduy7OXwK6wTVpqhBtMrv3o22t4rnh2M5GTWW7aIT5LleBbi90e2cQUukVX2rJTz(EGb2Ai2MXGGTEtyRdAVuoGIWG7SOMdkbgipzgvD7VOg0Q625akhggx6xGVwl7AJK)em4olQ5GsGbYtMrv3UHVPoaQkO2dYy2tMI4H37uaFFyCPFnFraFTw2E2txmscdNbgizzY0Ia(ATS9SNUyKSPnVoiipYnL09)kgpzqtTCr6IvroV5Lv68dxrxi19adi7zGIK05akAHb3zrnhucmqEYmQ62n8n1bqvb1Eqgx63(FfJNmOPwUiDXQiN38YcdUZIAoOeyG8Kzu1TB4BQ7kNvUI7lq7hJmU0V9)kgpzqtTCr6Ivbi5LBAycPu8W7DkGYDLZkxX9fO9Jr58MxA2mQ1G(KjLs5nF0CDpWq20MxhmNSWG7SOMdkbgipzgvD7g(MQUhyWHrxGrgZEYuep8ENc47dJl9R5lc4R1Y2ZE6Irsy4mWajltMweWxRLTN90fJKnT51bb5rUPKU)xX4jdAQLlsxSkajVCtNF4k6cPUhyazpduKKohqrR0SzuRb9jtkLYB(O56EGHSPnVoyozHb3zrnhucmqEYmQ62n8nvDpWGdJUaJmU0V9)kgpzqtTCr6Ivbi5LBA2mQ1G(KjLs5nF0CDpWq20MxhmNSWG7SOMdkbgipzgvD7g(MQUhyazpduKXL(f4R1sWkLQUD(MZqvhj)jP7)vmEYGMA5I0fRICm)rwggUIUq2)RyCpc6(EuZjPZbu0ktnykPHjKsXdV3Pak19adi7zGIY5npm4olQ5GsGbYtMrv3UHVPQ7bgq2ZafzCPF7)vmEYGMA5I0fRICEn3Gzzy4k6cz)VIX9iO77rnNKohqrRm1GPKgMqkfp8ENcOu3dmGSNbkkN38WG7SOMdkbgipzgvD7g(M6aOQGApiJzpzkIhEVtb89HXL(18fb81Az7zpDXijmCgyGKLjtlc4R1Y2ZE6IrYM286GG8i3us3)Ry8Kbn1YfPlwf58AUbZYWWv0fY(FfJ7rq33JAojDoGIwzQbtjD(HROlK6EGbK9mqrs6CafTWG7SOMdkbgipzgvD7g(M6aOQGApiJl9B)VIXtg0ulxKUyvKZR5gmlddxrxi7)vmUhbDFpQ5K05akALPgmfm4olQ5GsGbYtMrv3UHVPURCw5kUVaTFmY4s)YMrTg0NmPukV5JMR7bgYM286G50)JKrTr8y4gy6(FfJNmOPwUiDXQaedm30WesP4H37uaL7kNvUI7lq7hJY5npm4olQ5GsGbYtMrv3UHVPQ7bgCy0fyKXSNmfXdV3Pa((W4s)A(Ia(ATS9SNUyKegodmqYYKPfb81Az7zpDXiztBEDqqEKBkPzZOwd6tMukL38rZ19adztBEDWC6)rYO2iEmCdmD)VIXtg0ulxKUyvaIbMB68dxrxi19adi7zGIK05akAHb3zrnhucmqEYmQ62n8nvDpWGdJUaJmU0VSzuRb9jtkLYB(O56EGHSPnVoyo9)izuBepgUbMU)xX4jdAQLlsxSkaXaZfdog8mdBZ8Usb4mWW2yW2pKWwq1tM3ySfujOGGcGTOrrh2(HudkwxfLheeBZyqW2KM2843K6PedUZIAoOeyG8OyGv3(BsPuEZhnx3dmmU0VSzuRb9jPTKbn18(Fehn5jZjBAZRdIb3zrnhucmqEumWQB3W3uPTKbn18(Fehn5jZHb3zrnhucmqEumWQB3W3uhavfu7bzm7jtr8W7DkGVpmU0VMViGVwlBp7PlgjHHZadKSmzAraFTw2E2txms20MxheKh5Ms6(FfJNmOPgKxdMB68dxrxi19adi7zGIK05akAHb3zrnhucmqEumWQB3W3uhavfu7bzCPF7)vmEYGMAqEnyEyWDwuZbLadKhfdS62n8n1M2Mgskcc5ORlO24s)gUIUqU7bkQRBNdJP3K05akAHb3zrnhucmqEumWQB3W3urnOv1TZbuommU0VaFTw21gj)jyWDwuZbLadKhfdS62n8n1bqvb1EqgZEYuep8ENc47dJl9R5lc4R1Y2ZE6Irsy4mWajltMweWxRLTN90fJKnT51bb5rUPKU)hjJAJ4XWZcKD2YKP(FfJNmOPgKxdmR05hUIUqQ7bgq2ZafjPZbu0cdUZIAoOeyG8OyGv3UHVPoaQkO2dY4s)2)JKrTr8y4zbYoBzYu)VIXtg0udYRbMfgCNf1CqjWa5rXaRUDdFtv3dmGSNbkY4s)c81AjyLsv3oFZzOQJK)K0WesP4H37uaL6EGbK9mqr58MhgCNf1CqjWa5rXaRUDdFtf10hF0C01fuBCPF7)vmEYGMA5I0fRICEnyEP7)rYO2iEmCdMZoBHb3zrnhucmqEumWQB3W3uBABAiPiiKJUUGAm4olQ5GsGbYJIbwD7g(MQUhyazpduKXL(fMqkfp8ENcOu3dmGSNbkkN38WG7SOMdkbgipkgy1TB4BQdGQcQ9GmM9KPiE49ofW3hgx6xZxeWxRLTN90fJKWWzGbswMmTiGVwlBp7PlgjBAZRdcYJCtjD)VIXtg0ulxKUyvKtEzzYu)pkhdMo)Wv0fsDpWaYEgOijDoGIwyWDwuZbLadKhfdS62n8n1bqvb1Eqgx63(FfJNmOPwUiDXQiN8YYKP(FuogedUZIAoOeyG8OyGv3UHVP6nZpIht30fgx63(FfJNmOPwUiDXQiN8Yfdog8mdBbLmQf2II8oWw2CRkQ5GyWDwuZbLSrT4OiVJxgkVoiF08Irgx6xGVwlzJAXrrEhsy4mWYjR0rTr8y4RIazNTWG7SOMdkzJAXrrEhg(MkdLxhKpAEXiJl9R5aFTwMukL38rZ19adztBEDqqE3zRm18hgYMrTg0Nu3dmq)S3GC9VFkBYxptXKjGVwltkLYB(O56EGHSPnVoii9)izuBepgUbtjnWxRLjLs5nF0CDpWq(ts7ztDfKSyp5Sk8fPKTFGbYBEyWDwuZbLSrT4OiVddFtLHYRdYhnVyKXL(f4R1YKsP8MpAUUhyiBAZRdcIbinWxRL)d1OEYHrt3EGs20MxheKD2ktn)HHSzuRb9j19ad0p7nix)7NYM81Zusd81A5)qnQNCy00ThOKnT51btd81AzsPuEZhnx3dmK)K0E2uxbjl2toRcFrkz7hyG8MhgCNf1CqjBulokY7WW3uzO86G8rZlgzCPFnh4R1YI9KZQWxKs20Mxheed0KjGVwll2toRcFrkztBEDqq6)rYO2iEmCdMsAGVwll2toRcFrk5pjTNn1vqYI9KZQWxKs2(bwo5Hb3zrnhuYg1IJI8om8nvgkVoiF08Irgx6xGVwll2toRcFrk5pjnWxRL)d1OEYHrt3EGs(ts7ztDfKSyp5Sk8fPKTFGLtEyWXG7SOMdkzZOwd6d((HeVcAZ4Z3OxpBikVDixpxWhnpzqtTXL(1C2mQ1G(K0wYGMAE)pIJM8K5Kn5RNPZh0ExoGIKtGIA(C8pK4uM8RKeALIjtMZMrTg0NmPukV5JMR7bgYM286GG8(i30G27YbuKCcuuZNJ)HeNYKFLKqRuWG7SOMdkzZOwd6dA4BQFiXRG2m(8n6v9BWOgYRdwRA(q(EPdJl9B4k6cjqtEGIpAoSUv77d0L05akAL2CZzZOwd6tMukL38rZ19adztBEDqqEFKBAq7D5aksobkQ5ZX)qItzYVssOvkMmzoWxRLjLs5nF0CDpWq(tsNpO9UCafjNaf1854FiXPm5xjj0kLumzYCGVwltkLYB(O56EGH8NKo)Wv0fsGM8afF0CyDR23hOlPZbu0kfm4olQ5Gs2mQ1G(Gg(M6hs8kOnOXL(1C2mQ1G(KjLs5nF0CDpWq2KVEAYeBg1AqFYKsP8MpAUUhyiBAZRdMtE5MsAZZpCfDHeOjpqXhnhw3Q99b6s6CafTmzInJAnOpjTLmOPM3)J4OjpzoztBEDWCa1zLcgCNf1CqjBg1AqFqdFt9djEf0MXNVrVoefO9JG82ZEAoBAxzCPFxeWxRLTN90C20UIViGVwlxd6ddUZIAoOKnJAnOpOHVP(HeVcAZ4Z3OxhIc0(rqE7zpnNnTRmU0VSzuRb9jPTKbn18(Fehn5jZjBAZRdMdOo30lc4R1Y2ZEAoBAxXxeWxRL)K0G27YbuKCcuuZNJ)HeNYKFLKqltMa(ATeOjpqXhnhw3Q99b6YFs6fb81Az7zpnNnTR4lc4R1YFs68bT3LdOi5eOOMph)djoLj)kjHwMmb81AjTLmOPM3)J4Ojpzo5pj9Ia(ATS9SNMZM2v8fb81A5pjD(HROlKan5bk(O5W6wTVpqxsNdOOLjtrTr8y4RIajVhyWDwuZbLSzuRb9bn8n1pK4vqBgF(g9cQIGCudAf1gx6xZPm5xjj0sQ(nyud51bRvnFiFV0rAGVwltkLYB(O56EGHSPnVoykMmzE(uM8RKeAjv)gmQH86G1QMpKVx6inWxRLjLs5nF0CDpWq20MxheKh5Lg4R1YKsP8MpAUUhyi)jPGb3zrnhuYMrTg0h0W3u)qIxbTz85B0ly3e8rZ9Jv0fC9VFACPFzZOwd6tsBjdAQ59)ioAYtMt20Mxhmhdmxm4olQ5Gs2mQ1G(Gg(M6hs8kOnJpFJE3752H8KU2CfV9DY4s)2)Ja51GPZh4R1YKsP8MpAUUhyi)jPnpFGVwlbAYdu8rZH1TAFFGU8NyYu(HROlKan5bk(O5W6wTVpqxsNdOOvkyWDwuZbLSzuRb9bn8n1pK4vqBgF(g92E2R)bgKdu78MwCGFeZHb3zrnhuYMrTg0h0W3u)qIxbTz85B07g1eybkhY1(TBCPFZh4R1sGM8afF0CyDR23hOl)jPZh4R1YKsP8MpAUUhyi)jyWDwuZbLSzuRb9bn8n1KjQ5mU0VaFTwMukL38rZ19ad5pjnWxRL0wYGMAE)pIJM8K5K)em4olQ5Gs2mQ1G(Gg(MkGAMfx)7Ngx6xGVwltkLYB(O56EGH8NKg4R1sAlzqtnV)hXrtEYCYFcgCNf1CqjBg1AqFqdFtfGAi1Gv3UXL(f4R1YKsP8MpAUUhyi)jyWZmSnZ3dmWw2mQ1G(GyWDwuZbLSzuRb9bn8n1KsP8MpAUUhyyCPFzZOwd6tsBjdAQ59)ioAYtMt20MxhedUZIAoOKnJAnOpOHVPc0KhO4JMdRB1((aDJ)qIpAnFNTEFyCPFzZOwd6tsBjdAQ59)ioAYtMt20MxhmnBg1AqFYKsP8MpAUUhyiBAZRdIb3zrnhuYMrTg0h0W3uPTKbn18(Fehn5jZzCPFzZOwd6tMukL38rZ19adzt(6z68dxrxibAYdu8rZH1TAFFGUKohqrR09)izuBepgEw5SZwP7)vmEYGMA5I0fRICEFKRjtrTr8y4RIajVCXG7SOMdkzZOwd6dA4BQ0wYGMAE)pIJM8K5mU0VMZMrTg0NmPukV5JMR7bgYM81ttMIAJ4XWxfbsE5Ms6Wv0fsGM8afF0CyDR23hOlPZbu0kD)VIXtg0uNJbmxm4olQ5Gs2mQ1G(Gg(MkZvkUZIAoUQGHXNVrVSrT4OiVdJl9B4k6cjBulokY7qsNdOOvAZnh4R1s2OwCuK3HegodSCEFKB6fb81Az7zpDXijmCgyVzLIjtrTr8y4RIa5DNTsbdUZIAoOKnJAnOpOHVPQ7bgOF2BqU(3pnU0VMd81AzsPuEZhnx3dmKnT51bb5DNTmzYCGVwltkLYB(O56EGHSPnVoiigG0aFTw(puJ6jhgnD7bkztBEDqqE3zR0aFTw(puJ6jhgnD7bk5pjLusd81AzsPuEZhnx3dmK)K0E2uxbjl2toRcFrkz7hyG8MhgCNf1CqjBg1AqFqdFtv3dmq)S3GC9VFACPFnh4R1YI9KZQWxKs20MxheK3D2YKjZb(ATSyp5Sk8fPKnT51bbXaKg4R1Y)HAup5WOPBpqjBAZRdcY7oBLg4R1Y)HAup5WOPBpqj)jPKsAGVwll2toRcFrk5pjTNn1vqYI9KZQWxKs2(bwo5Hb3zrnhuYMrTg0h0W3u19ad0p7nix)7Ngx63O2iEm8vrGSZwMmzEuBepg(QiqyZOwd6tMukL38rZ19adztBEDW0aFTw(puJ6jhgnD7bk5pjfm4yWDwuZbLeeshJGVaQzw8rZdueNoA7PXL(f4R1YKsP8MpAUUhyiBAZRdcYJCtZMrTg0NeOjpqXhnhw3Q99b6YM286GMmb81AzsPuEZhnx3dmKnT51bb5rUPZpCfDHeOjpqXhnhw3Q99b6s6CafTWG7SOMdkjiKogbn8n19V3RYp(O5E2upbkm4olQ5GsccPJrqdFtLHQukomAYbZ4s)c81AzsPuEZhnx3dmKnT51bbjltMIAJ4XWxfbswyWDwuZbLeeshJGg(MAGI4)dy(3IRNMrgx6xGVwlBIbMIGqUEAgj)jMmb81AztmWueeY1tZioB(xqTegodmqE8adUZIAoOKGq6ye0W3u1d7dPf3ZM6kioa5Bgx638b(ATmPukV5JMR7bgYFs68b(ATeOjpqXhnhw3Q99b6YFcgCNf1CqjbH0XiOHVPYMJrx0EqlUw5BKXL(nFGVwltkLYB(O56EGH8NKoFGVwlbAYdu8rZH1TAFFGU8NKEnHKnhJUO9GwCTY3ioWVpztBEDW3CXG7SOMdkjiKogbn8n1KFx6N1TZbuommU0V5d81AzsPuEZhnx3dmK)K05d81AjqtEGIpAoSUv77d0L)em4olQ5GsccPJrqdFtf90QfOP64nbNZpgzCPFZh4R1YKsP8MpAUUhyi)jPZh4R1sGM8afF0CyDR23hOl)jyWDwuZbLeeshJGg(MAxjjkIxhhM4mY4s)MpWxRLjLs5nF0CDpWq(tsNpWxRLan5bk(O5W6wTVpqx(tWG7SOMdkjiKogbn8n1nAB6N8rZvFwT4RM8nOXL(f4R1sAlzqtnV)hXrtEYCYM286GGKvAGVwlbAYdu8rZH1TAFFGU8NyYK59)izuBepgEE5SZwP7)vmEYGMAqYk3uWGJbpZW2mxbuvqTh1CyBpHh1CyWDwuZbLdGQcQ9OM7TPTPHKIGqo66cQnU0VHROlK7EGI6625Wy6njDoGIwyWDwuZbLdGQcQ9OMZW3uhavfu7bzm7jtr8W7DkGVpmU0VMViGVwlBp7PlgjHHZadKSmzAraFTw2E2txms20MxheKh5Ms68dxrxi19adi7zGIK05akALoFGVwl7AJK)K0WesP4H37uaLOg0Q625akhg58Aqm4olQ5GYbqvb1EuZz4BQdGQcQ9GmU0V5hUIUqQ7bgq2ZafjPZbu0kD(aFTw21gj)jPHjKsXdV3PakrnOv1TZbuomY51GyWDwuZbLdGQcQ9OMZW3u19adi7zGImU0VMd81AjyLsv3oFZzOQJKn5SWKjZb(ATeSsPQBNV5mu1rYFsAZtAc08D2s(qQ7bgCy0fyKjtjnbA(oBjFirnOv1TZbuommzkPjqZ3zl5d5UYzLR4(c0(XOusjL0WesP4H37uaL6EGbK9mqr58MhgCNf1Cq5aOQGApQ5m8n1bqvb1EqgZEYuep8ENc47dJl9R5lc4R1Y2ZE6Irsy4mWajltMweWxRLTN90fJKnT51bb5rUPKg4R1sWkLQUD(MZqvhjBYzHjtMd81AjyLsv3oFZzOQJK)K0MN0eO57SL8Hu3dm4WOlWitMsAc08D2s(qIAqRQBNdOCyyYustGMVZwYhYDLZkxX9fO9JrPKcgCNf1Cq5aOQGApQ5m8n1bqvb1Eqgx6xGVwlbRuQ625BodvDKSjNfMmzoWxRLGvkvD78nNHQos(tsBEstGMVZwYhsDpWGdJUaJmzkPjqZ3zl5djQbTQUDoGYHHjtjnbA(oBjFi3voRCf3xG2pgLskyWDwuZbLdGQcQ9OMZW3u3voRCf3xG2pgzCPFnpFGVwl7AJK)etM6)vmEYGMA5I0fRcqEKRjt9)izuBepgEE5SZwPKgMqkfp8ENcOCx5SYvCFbA)yuoV5Hb3zrnhuoaQkO2JAodFtf1Gwv3ohq5WW4s)c81AzxBK8NKgMqkfp8ENcOe1Gwv3ohq5WiN38WG7SOMdkhavfu7rnNHVPQ7bgCy0fyKXSNmfXdV3Pa((W4s)A(Ia(ATS9SNUyKegodmqYYKPfb81Az7zpDXiztBEDqqEKBkPZh4R1YU2i5pXKP(FfJNmOPwUiDXQaKh5AYu)psg1gXJHNxo7Sv68dxrxi19adi7zGIK05akAHb3zrnhuoaQkO2JAodFtv3dm4WOlWiJl9B(aFTw21gj)jMm1)Ry8Kbn1YfPlwfG8ixtM6)rYO2iEm88YzNTWG7SOMdkhavfu7rnNHVPIAqRQBNdOCyyCPFb(ATSRns(tWG7SOMdkhavfu7rnNHVPoaQkO2dYy2tMI4H37uaFFyCPFnFraFTw2E2txmscdNbgizzY0Ia(ATS9SNUyKSPnVoiipYnL05hUIUqQ7bgq2ZafjPZbu0cdUZIAoOCauvqTh1Cg(M6aOQGApim4yWZmSfj8B59cBH1TRiqXW7DkW2EcpQ5WG7SOMdkHHFlVxVnTnnKueeYrxxqngCNf1Cqjm8B59YW3u19adom6cmY4s)YMrTg0NSPTPHKIGqo66cQLnT51bb5nVmDNTshUIUqU7bkQRBNdJP3K05akAHb3zrnhucd)wEVm8nvudAvD7CaLddJl9lWxRLDTrYFcgCNf1Cqjm8B59YW3uhavfu7bzCPFZh4R1sDpzthp5RGK8NKoCfDHu3t20Xt(kijPZbu0cdUZIAoOeg(T8Ez4BQ6EGbhgDbgzCPF7)vmEYGMA5I0fRcqm)rwggUIUq2)RyCpc6(EuZjPZbu0ktnykyWDwuZbLWWVL3ldFtv3dmGSNbkY4s)c81AjyLsv3oFZzOQJK)K09)izuBepgUbMZ7oBHb3zrnhucd)wEVm8n1bqvb1Eqgx63(FfJNmOPwUiDXQihZZllddxrxi7)vmUhbDFpQ5K05akALPgmfm4olQ5Gsy43Y7LHVPQ7bgCy0fyegCNf1Cqjm8B59YW3urn9XhnhDDb1yWDwuZbLWWVL3ldFt1BMFepMUPleHiec]] )
    

end
