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

        potion = "superior_battle_potion_of_strength",

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


    spec:RegisterPack( "Frost DK", 20190722.0030, [[dGeZ7bqivbpsuI2KiAuueNII0QGQuVcQQzrHClGkYUi6xuunmrLoMQOLjk6zqvmnGkDnrP2gqf8nrj04GQKoNOeSorjfZdiUNQ0(evCqOkrwOOWdbQqnrGkkUiuLqBuus1jbQOALaLxkkPu3eOIs7Kc1pfLusdfQsulfOcPNcLPsr5Ravi2lQ(ljdMshwyXQQhJYKvQlJSzs9zLy0qLtlz1qvcEnqA2eUTsA3Q8BfdxKoUOKSCPEoOPt11bSDGQ(ofmErjL48IQwVQqZxe2pK5p5MXX2HtCJZm3NzHCZIzMPm3CXtwepzroMNpL4yPbd0yH4yxSsCSSEpqhzbNjRnhlnYlMyZnJJbhGMrCmCUNcZAm38LYXb8LSz1CyTcicVMJ1H2nhwRmZ5yFGs4GZp(NJTdN4gNzUpZc5MfZmtzU5IhWbWfpCSaWXnnhdRwbhZXWv7nD8phBtqghllr2SEpqhzbNHchhYM1(QfCocSSezX5EkmRXCZxkhhWxYMvZH1kGi8AowhA3CyTYmhbwwISGbiYJSz(0iKnZCFMfqwWjKnZNznGBUiWqGLLil4yCXTqWSgeyzjYcoHSGZpMaytil4S1Tr2SEt0JKebwwISGtilEP9gz1Hq8dgOiREAKfaw3cYIxeCuWrmczXlpzDKT0iBQiYtnYwx5v4eezZyWq2pPNMq20ze1TGSIzPyiBbrw2SMkiN2seyzjYcoHSGJXf3cHSE0lKl9ALu(O2fHS(GSETskFu7IqwFqwaiHS0XgGZPgzf0T44q2oCCuJSoU4q20XPZRqGSEhqCi7MchhuYXef0HCZ4ySrSv4OODUzCJFYnJJrx8f0MNbhJ1LtDfCSpGwlzJyRWrr7sOhmqr2Cq2Sr2KiRxRKYh1UiKfeKDHT5ybZR54ymCrDq1OvfJ4o34m5MXXOl(cAZZGJX6YPUcoMji7hqRLPLqeTA0kDpqx20Auhezb5fzxyBKfVrwtq2Nil(ilBgXEmCsDpq3q(EfQ0aDEztXopYAkYMibY(b0AzAjerRgTs3d0LnTg1brwqq2g4iPxRKYhfEqwtr2Ki7hqRLPLqeTA0kDpqxcKISjr24rQlNKflVIvESjHSJduKfKxKntowW8AoogdxuhunAvXiUZngpCZ4y0fFbT5zWXyD5uxbh7dO1Y0siIwnALUhOlBAnQdISGGS4vKnjY(b0AjWHBe5vqVPBXXjBAnQdISGGSlSnYI3iRji7tKfFKLnJypgoPUhOBiFVcvAGoVSPyNhznfztISFaTwcC4grEf0B6wCCYMwJ6GiBsK9dO1Y0siIwnALUhOlbsr2KiB8i1LtYILxXkp2Kq2XbkYcYlYMjhlyEnhhJHlQdQgTQye35gdUCZ4y0fFbT5zWXyD5uxbhZeK9dO1YILxXkp2Kq20AuhezbbzbxKnrcK9dO1YILxXkp2Kq20AuhezbbzBGJKETskFu4bznfztISFaTwwS8kw5XMesGuKnjYgpsD5KSy5vSYJnjKDCGIS5GSzYXcMxZXXy4I6GQrRkgXDUXzZnJJrx8f0MNbhJ1LtDfCSpGwllwEfR8ytcjqkYMez)aATe4WnI8kO30T44KaPiBsKnEK6YjzXYRyLhBsi74afzZbzZKJfmVMJJXWf1bvJwvmI7CNJnFr5uhEnh3mUXp5MXXOl(cAZZGJX6YPUcoMhc6C5s44OUUff0NEvsx8f0MJfmVMJJ1060qsqqOYqDo1CNBCMCZ4y0fFbT5zWXyD5uxbhZeKDtFaTw2XJtxmsc9GbkYccYMnYMibYUPpGwl74XPlgjBAnQdISGGSpZfznfztISpGSEiOZL6EGoKL3Xrs6IVG2iBsK9bK9dO1YUwjjqkYMezHPKqO8OxihkXnge1TO(Ia6iBoVilE4ybZR54yZxuo1HtCmwEMGuE0lKd5g)K7CJXd3mogDXxqBEgCmwxo1vWXEaz9qqNl19aDilVJJK0fFbTr2Ki7di7hqRLDTssGuKnjYctjHq5rVqouIBmiQBr9fb0r2CErw8WXcMxZXXMVOCQdN4o3yWLBghJU4lOnpdogRlN6k4yMGSFaTwcAje1TOwdgU6iztbZr2ejqwtq2pGwlbTeI6wuRbdxDKeifztISMGSPnbE1cBlFk19aDf07cucztKaztBc8Qf2w(uIBmiQBr9fb0r2ejq20MaVAHTLpLlIGvHqfBWhhJqwtrwtrwtr2KilmLecLh9c5qPUhOdz5DCeYMZlYMjhlyEnhht3d0HS8ooI7CJZMBghJU4lOnpdogRlN6k4yMGSB6dO1YoEC6IrsOhmqrwqq2Sr2ejq2n9b0AzhpoDXiztRrDqKfeK9zUiRPiBsK9dO1sqlHOUf1AWWvhjBkyoYMibYAcY(b0AjOLqu3IAny4QJKaPiBsK1eKnTjWRwyB5tPUhORGExGsiBIeiBAtGxTW2YNsCJbrDlQViGoYMibYM2e4vlST8PCreSkeQyd(4yeYAkYAkhlyEnhhB(IYPoCIJXYZeKYJEHCi34NCNBm4a3mogDXxqBEgCmwxo1vWX(aATe0siQBrTgmC1rYMcMJSjsGSMGSFaTwcAje1TOwdgU6ijqkYMeznbztBc8Qf2w(uQ7b6kO3fOeYMibYM2e4vlST8Pe3yqu3I6lcOJSjsGSPnbE1cBlFkxebRcHk2GpogHSMISMYXcMxZXXMVOCQdN4o34Si3mogDXxqBEgCmwxo1vWXmbzFaz)aATSRvscKISjsGSnWvmv6yGA5M0fRCKfeK9zUiBIeiBdCK0Rvs5JktKnhKDHTrwtr2KilmLecLh9c5q5IiyviuXg8XXiKnNxKntowW8Aoo2IiyviuXg8XXiUZngVYnJJrx8f0MNbhJ1LtDfCSpGwl7ALKaPiBsKfMscHYJEHCOe3yqu3I6lcOJS58ISzYXcMxZXXWnge1TO(Ia6CNBCwGBghJU4lOnpdogRlN6k4yMGSB6dO1YoEC6IrsOhmqrwqq2Sr2ejq2n9b0AzhpoDXiztRrDqKfeK9zUiRPiBsK9bK9dO1YUwjjqkYMibY2axXuPJbQLBsxSYrwqq2N5ISjsGSnWrsVwjLpQmr2Cq2f2gztISpGSEiOZL6EGoKL3Xrs6IVG2CSG51CCmDpqxb9UaL4yS8mbP8OxihYn(j35g)mxUzCm6IVG28m4ySUCQRGJ9aY(b0AzxRKeifztKazBGRyQ0Xa1YnPlw5ilii7ZCr2ejq2g4iPxRKYhvMiBoi7cBZXcMxZXX09aDf07cuI7CJF(KBghJU4lOnpdogRlN6k4yFaTw21kjbs5ybZR54y4gdI6wuFraDUZn(zMCZ4y0fFbT5zWXyD5uxbhZeKDtFaTw2XJtxmsc9GbkYccYMnYMibYUPpGwl74XPlgjBAnQdISGGSpZfznfztISpGSEiOZL6EGoKL3Xrs6IVG2CSG51CCS5lkN6Wjoglptqkp6fYHCJFYDUXpXd3mowW8Aoo28fLtD4ehJU4lOnpdUZDo2FGkVyGw3c3mUXp5MXXOl(cAZZGJX6YPUcogBgXEmCsAnDmqTQboszGI05KnTg1b5ybZR54yPLqeTA0kDpqN7CJZKBghlyEnhhJwthduRAGJugOiDoogDXxqBEgCNBmE4MXXOl(cAZZGJX6YPUcoMji7M(aATSJhNUyKe6bduKfeKnBKnrcKDtFaTw2XJtxms20AuhezbbzFMlYAkYMezBGRyQ0Xa1iliVilEYfztISpGSEiOZL6EGoKL3Xrs6IVG2CSG51CCS5lkN6Wjoglptqkp6fYHCJFYDUXGl3mogDXxqBEgCmwxo1vWXAGRyQ0Xa1iliVilEYKJfmVMJJnFr5uhoXDUXzZnJJrx8f0MNbhJ1LtDfCmpe05YLWXrDDlkOp9QKU4lOnhlyEnhhRP1PHKGGqLH6CQ5o3yWbUzCm6IVG28m4ySUCQRGJ9b0AzxRKeiLJfmVMJJHBmiQBr9fb05o34Si3mogDXxqBEgCmwxo1vWXmbz30hqRLD840fJKqpyGISGGSzJSjsGSB6dO1YoEC6IrYMwJ6Gilii7ZCrwtr2KiBdCK0Rvs5JkBKfeKDHTr2ejq2g4kMkDmqnYcYlYcUzJSjr2hqwpe05sDpqhYY74ijDXxqBowW8Aoo28fLtD4ehJLNjiLh9c5qUXp5o3y8k3mogDXxqBEgCmwxo1vWXAGJKETskFuzJSGGSlSnYMibY2axXuPJbQrwqErwWnBowW8Aoo28fLtD4e35gNf4MXXOl(cAZZGJX6YPUco2hqRLGwcrDlQ1GHRoscKISjrwykjekp6fYHsDpqhYY74iKnNxKntowW8AooMUhOdz5DCe35g)mxUzCm6IVG28m4ySUCQRGJ1axXuPJbQLBsxSYr2CErw8KjYMezBGJKETskFu4bzZbzxyBowW8AoogUPp1OvgQZPM7CJF(KBghlyEnhhRP1PHKGGqLH6CQ5y0fFbT5zWDUXpZKBghJU4lOnpdogRlN6k4yWusiuE0lKdL6EGoKL3XriBoViBMCSG51CCmDpqhYY74iUZn(jE4MXXOl(cAZZGJX6YPUcoMji7M(aATSJhNUyKe6bduKfeKnBKnrcKDtFaTw2XJtxms20AuhezbbzFMlYAkYMezBGRyQ0Xa1YnPlw5iBoiBMzJSjsGSnWriBoilEq2Ki7diRhc6CPUhOdz5DCKKU4lOnhlyEnhhB(IYPoCIJXYZeKYJEHCi34NCNB8tWLBghJU4lOnpdogRlN6k4ynWvmv6yGA5M0fRCKnhKnZSr2ejq2g4iKnhKfpCSG51CCS5lkN6WjUZn(z2CZ4y0fFbT5zWXyD5uxbhRbUIPshdul3KUyLJS5GSzMlhlyEnhhlAwCKYNUPZ5o35yeeshJGCZ4g)KBghJU4lOnpdogRlN6k4yFaTwMwcr0QrR09aDztRrDqKfeK9zUiBsKLnJypgo5VPWXPgTcw3UJLbgYMwJ6GiBIei7hqRLPLqeTA0kDpqx20AuhezbbzFMlYMezFaz9qqNl)nfoo1OvW62DSmWqsx8f0MJfmVMJJ9fZSvJw54ifD0AEUZnotUzCSG51CCSfGO3vCQrRIhPECCCm6IVG28m4o3y8WnJJrx8f0MNbhJ1LtDfCSpGwltlHiA1Ov6EGUSP1OoiYccYMnYMibY61kP8rTlczbbzZMJfmVMJJXWvcHc6nfGYDUXGl3mogDXxqBEgCmwxo1vWX(aATSjgOcccv6PzKeifztKaz)aATSjgOcccv6PzKInaNtTe6bduKfeK95towW8AooMJJua3FaUTspnJ4o34S5MXXOl(cAZZGJX6YPUco2di7hqRLPLqeTA0kDpqxcKISjr2hq2pGwl)nfoo1OvW62DSmWqcKYXcMxZXX0ddasBv8i1LtQpfRCNBm4a3mogDXxqBEgCmwxo1vWXEaz)aATmTeIOvJwP7b6sGuKnjY(aY(b0A5VPWXPgTcw3UJLbgsGuKnjYUhxYMJrN3HtBLweRK6d0NSP1OoiY(IS5YXcMxZXXyZXOZ7WPTslIvI7CJZICZ4y0fFbT5zWXyD5uxbh7bK9dO1Y0siIwnALUhOlbsr2Ki7di7hqRL)MchNA0kyD7owgyibs5ybZR54yPaDPZx3I6lcOZDUX4vUzCm6IVG28m4ySUCQRGJ9aY(b0AzAjerRgTs3d0LaPiBsK9bK9dO1YFtHJtnAfSUDhldmKaPCSG51CCmdtl2GNQt1eCU4ye35gNf4MXXOl(cAZZGJX6YPUco2di7hqRLPLqeTA0kDpqxcKISjr2hq2pGwl)nfoo1OvW62DSmWqcKYXcMxZXX6knvqQ6uW0GrCNB8ZC5MXXOl(cAZZGJX6YPUco2hqRL0A6yGAvdCKYafPZjBAnQdISGGSzJSjr2pGwl)nfoo1OvW62DSmWqcKISjsGSMGSnWrsVwjLpQmr2Cq2f2gztISnWvmv6yGAKfeKn7Crwt5ybZR54yR0605vJwjay1wTBkwHCN7CS)avPZiQBHBg34NCZ4y0fFbT5zWXyD5uxbh7dO1YUwjjqkhlyEnhhd3yqu3I6lcOZDUXzYnJJrx8f0MNbhJ1LtDfCmtq2n9b0AzhpoDXij0dgOiliiB2iBIei7M(aATSJhNUyKSP1OoiYccY(mxK1uKnjYMezBGRyQ0Xa1YnPlw5iBoViBMzJSjr2hqwpe05sDpqhYY74ijDXxqBowW8Aoo28fLtD4ehJLNjiLh9c5qUXp5o3y8WnJJrx8f0MNbhJ1LtDfCSg4kMkDmqTCt6IvoYMZlYMz2CSG51CCS5lkN6WjUZngC5MXXOl(cAZZGJX6YPUcowdCftLogOwUjDXkhzbbzZmxKnjYctjHq5rVqouUicwfcvSbFCmczZ5fzZeztISSze7XWjtlHiA1Ov6EGUSP1OoiYMdYMnhlyEnhhBreSkeQyd(4ye35gNn3mogDXxqBEgCmwxo1vWXmbz30hqRLD840fJKqpyGISGGSzJSjsGSB6dO1YoEC6IrYMwJ6Gilii7ZCrwtr2KiBdCftLogOwUjDXkhzbbzZmxKnjY(aY6HGoxQ7b6qwEhhjPl(cAJSjrw2mI9y4KPLqeTA0kDpqx20AuhezZbzZMJfmVMJJP7b6kO3fOehJLNjiLh9c5qUXp5o3yWbUzCm6IVG28m4ySUCQRGJ1axXuPJbQLBsxSYrwqq2mZfztISSze7XWjtlHiA1Ov6EGUSP1OoiYMdYMnhlyEnhht3d0vqVlqjUZnolYnJJrx8f0MNbhJ1LtDfCSpGwlbTeI6wuRbdxDKeifztISnWvmv6yGA5M0fRCKnhK1eK9z2il(iRhc6CzdCftfUthq41Cs6IVG2ilEJS4bznfztISWusiuE0lKdL6EGoKL3XriBoViBMCSG51CCmDpqhYY74iUZngVYnJJrx8f0MNbhJ1LtDfCSg4kMkDmqTCt6IvoYMZlYAcYINSrw8rwpe05Yg4kMkCNoGWR5K0fFbTrw8gzXdYAkYMezHPKqO8Oxihk19aDilVJJq2CEr2m5ybZR54y6EGoKL3XrCNBCwGBghJU4lOnpdogRlN6k4yMGSB6dO1YoEC6IrsOhmqrwqq2Sr2ejq2n9b0AzhpoDXiztRrDqKfeK9zUiRPiBsKTbUIPshdul3KUyLJS58ISMGS4jBKfFK1dbDUSbUIPc3Pdi8AojDXxqBKfVrw8GSMISjr2hqwpe05sDpqhYY74ijDXxqBowW8Aoo28fLtD4ehJLNjiLh9c5qUXp5o34N5YnJJrx8f0MNbhJ1LtDfCSg4kMkDmqTCt6IvoYMZlYAcYINSrw8rwpe05Yg4kMkCNoGWR5K0fFbTrw8gzXdYAkhlyEnhhB(IYPoCI7CJF(KBghJU4lOnpdogRlN6k4ySze7XWjtlHiA1Ov6EGUSP1OoiYMdY2ahj9ALu(OaxKnjY2axXuPJbQLBsxSYrwqqwWnxKnjYctjHq5rVqouUicwfcvSbFCmczZ5fzZKJfmVMJJTicwfcvSbFCmI7CJFMj3mogDXxqBEgCmwxo1vWXmbz30hqRLD840fJKqpyGISGGSzJSjsGSB6dO1YoEC6IrYMwJ6Gilii7ZCrwtr2KilBgXEmCY0siIwnALUhOlBAnQdIS5GSnWrsVwjLpkWfztISnWvmv6yGA5M0fRCKfeKfCZfztISpGSEiOZL6EGoKL3Xrs6IVG2CSG51CCmDpqxb9UaL4yS8mbP8OxihYn(j35g)epCZ4y0fFbT5zWXyD5uxbhJnJypgozAjerRgTs3d0LnTg1br2Cq2g4iPxRKYhf4ISjr2g4kMkDmqTCt6IvoYccYcU5YXcMxZXX09aDf07cuI7CNJL2eBw)HZnJB8tUzCSG51CCS0XR54y0fFbT5zWDUXzYnJJrx8f0MNbhBs5yqY5ybZR54yGp6k(cIJb(qaqCmtqwkRaQ0uAlVXNUgaOAre7k8PHQFSxiKnrcKLYkGknL2syDf0PwTiIDf(0q1p2leYMibYszfqLMsBjSUc6uRweXUcFAOAL2HquZHSjsGSuwbuPP0wc(keQrRIRwdN2QVyMnYMibYszfqLMsBPUAORwdNGkyA(fraHiBIeilLvavAkTL4fiOc3yqqnYMibYszfqLMsB5n(01aavlIyxHpnuTs7qiQ5qwt5yGpA1fRehBCCuRMtbajfLvavAkT5o35ySze7XWb5MXn(j3mogDXxqBEgCSlwjow8iex0buPNZvJwLogOMJfmVMJJfpcXfDav65C1OvPJbQ5ySUCQRGJzcYYMrShdNKwthduRAGJugOiDoztXopYMezFazbF0v8fKCCCuRMtbajfLvavAkTrwtr2ejqwtqw2mI9y4KPLqeTA0kDpqx20Auhezb5fzFMlYMezbF0v8fKCCCuRMtbajfLvavAkTrwt5o34m5MXXOl(cAZZGJDXkXXeanOudv1bRDnaq1sPDowW8AooMaObLAOQoyTRbaQwkTZXyD5uxbhZdbDU83u44uJwbRB3XYadjDXxqBKnjYAcYAcYYMrShdNmTeIOvJwP7b6YMwJ6GiliVi7ZCr2Kil4JUIVGKJJJA1CkaiPOScOstPnYAkYMibYAcY(b0AzAjerRgTs3d0LaPiBsK9bKf8rxXxqYXXrTAofaKuuwbuPP0gznfznfztKaznbz)aATmTeIOvJwP7b6sGuKnjY(aY6HGox(BkCCQrRG1T7yzGHKU4lOnYAk35gJhUzCm6IVG28m4yxSsCmwEMy8EUIP(Ia6CSG51CCmwEMy8EUIP(Ia6Cmwxo1vWXmbzzZi2JHtMwcr0QrR09aDztXopYMibYYMrShdNmTeIOvJwP7b6YMwJ6GiBoiBM5ISMISjrwtq2hqwpe05YFtHJtnAfSUDhldmK0fFbTr2ejqw2mI9y4K0A6yGAvdCKYafPZjBAnQdIS5GSzHSrwt5o3yWLBghJU4lOnpdo2fRehdVabv4gdcQ5ybZR54y4fiOc3yqqnhJ1LtDfCmtqwkRaQ0uAlfanOudv1bRDnaq1sPDKnjY(b0AzAjerRgTs3d0LnTg1brwtr2ejqwtq2hqwkRaQ0uAlfanOudv1bRDnaq1sPDKnjY(b0AzAjerRgTs3d0LnTg1brwqq2NzISjr2pGwltlHiA1Ov6EGUeifznL7CJZMBghJU4lOnpdo2fRehd0BC1OvXXk6CLgOZZXcMxZXXa9gxnAvCSIoxPb68Cmwxo1vWXyZi2JHtsRPJbQvnWrkduKoNSP1OoiYMdYcU5YDUXGdCZ4y0fFbT5zWXUyL4yl9ClqvAxRHq1XcXXcMxZXXw65wGQ0UwdHQJfIJX6YPUcowdCeYcYlYIhKnjY(aY(b0AzAjerRgTs3d0LaPiBsK1eK9bK9dO1YFtHJtnAfSUDhldmKaPiBIei7diRhc6C5VPWXPgTcw3UJLbgs6IVG2iRPCNBCwKBghJU4lOnpdo2fRehRJh3ahOq1VwunTvFa3NJJfmVMJJ1XJBGduO6xlQM2QpG7ZXDUX4vUzCm6IVG28m4yxSsCSvQjqDCbuPJBHJfmVMJJTsnbQJlGkDClCmwxo1vWXEaz)aAT83u44uJwbRB3XYadjqkYMezFaz)aATmTeIOvJwP7b6sGuUZnolWnJJrx8f0MNbhJ1LtDfCSpGwltlHiA1Ov6EGUeifztISFaTwsRPJbQvnWrkduKoNeiLJfmVMJJLoEnh35g)mxUzCm6IVG28m4ySUCQRGJ9b0AzAjerRgTs3d0LaPiBsK9dO1sAnDmqTQboszGI05KaPCSG51CCSVyMTsd055o34Np5MXXOl(cAZZGJX6YPUco2hqRLPLqeTA0kDpqxcKYXcMxZXX(udPg06w4o34NzYnJJrx8f0MNbhJ1LtDfCm2mI9y4K0A6yGAvdCKYafPZjBAnQdYXcMxZXXslHiA1Ov6EGo35g)epCZ4yaqsnATAHT5yp5y0fFbT5zWXyD5uxbhJnJypgojTMogOw1ahPmqr6CYMwJ6GiBsKLnJypgozAjerRgTs3d0LnTg1b5ybZR54y)MchNA0kyD7owgyWDUXpbxUzCm6IVG28m4ySUCQRGJXMrShdNmTeIOvJwP7b6YMIDEKnjY(aY6HGox(BkCCQrRG1T7yzGHKU4lOnYMezBGJKETskFuzJS5GSlSnYMezBGRyQ0Xa1YnPlw5iBoVi7ZCr2ejqwVwjLpQDriliiBM5YXcMxZXXO10Xa1Qg4iLbksNJ7CJFMn3mogDXxqBEgCmwxo1vWXmbzzZi2JHtMwcr0QrR09aDztXopYMibY61kP8rTlczbbzZmxK1uKnjY6HGox(BkCCQrRG1T7yzGHKU4lOnYMezBGRyQ0Xa1iBoil4qUCSG51CCmAnDmqTQboszGI054o34NGdCZ4y0fFbT5zWXcMxZXXyHqOcMxZPef05ySUCQRGJ5HGoxYgXwHJI2L0fFbTr2KiRjiRji7hqRLSrSv4OODj0dgOiBoVi7ZCr2Ki7M(aATSJhNUyKe6bduK9fzZgznfztKaz9ALu(O2fHSG8ISlSnYAkhtuqxDXkXXyJyRWrr7CNB8ZSi3mogDXxqBEgCmwxo1vWXmbz)aATmTeIOvJwP7b6YMwJ6GiliVi7cBJSjsGSMGSFaTwMwcr0QrR09aDztRrDqKfeKfVISjr2pGwlboCJiVc6nDlooztRrDqKfKxKDHTr2Ki7hqRLahUrKxb9MUfhNeifznfznfztISFaTwMwcr0QrR09aDjqkYMezJhPUCswS8kw5XMeYooqrwqEr2m5ybZR54y6EGUH89kuPb68CNB8t8k3mogDXxqBEgCmwxo1vWXmbz)aATSy5vSYJnjKnTg1brwqEr2f2gztKaznbz)aATSy5vSYJnjKnTg1brwqqw8kYMez)aATe4WnI8kO30T44KnTg1brwqEr2f2gztISFaTwcC4grEf0B6wCCsGuK1uK1uKnjY(b0AzXYRyLhBsibsr2KiB8i1LtYILxXkp2Kq2XbkYMdYMjhlyEnhht3d0nKVxHknqNN7CJFMf4MXXOl(cAZZGJX6YPUcoMxRKYh1UiKfeKDHTr2ejqwtqwVwjLpQDriliilBgXEmCY0siIwnALUhOlBAnQdISjr2pGwlboCJiVc6nDloojqkYAkhlyEnhht3d0nKVxHknqNN7CNJb942rV5MXn(j3mowW8AoowtRtdjbbHkd15uZXOl(cAZZG7CJZKBghJU4lOnpdogRlN6k4ySze7XWjBADAijiiuzOoNAztRrDqKfKxKntKfVr2f2gztISEiOZLlHJJ66wuqF6vjDXxqBowW8AooMUhORGExGsCNBmE4MXXOl(cAZZGJX6YPUco2hqRLDTssGuowW8AoogUXGOUf1xeqN7CJbxUzCm6IVG28m4ySUCQRGJ9aY(b0APUNhPtLciGKeifztISEiOZL6EEKovkGass6IVG2CSG51CCS5lkN6WjUZnoBUzCm6IVG28m4ySUCQRGJ1axXuPJbQLBsxSYrwqqwtq2NzJS4JSEiOZLnWvmv4oDaHxZjPl(cAJS4nYIhK1uowW8AooMUhORGExGsCNBm4a3mogDXxqBEgCmwxo1vWX(aATe0siQBrTgmC1rsGuKnjY2ahj9ALu(OaxKnNxKDHT5ybZR54y6EGoKL3XrCNBCwKBghJU4lOnpdogRlN6k4ynWvmv6yGA5M0fRCKnhK1eKnZSrw8rwpe05Yg4kMkCNoGWR5K0fFbTrw8gzXdYAkhlyEnhhB(IYPoCI7CJXRCZ4ybZR54y6EGUc6DbkXXOl(cAZZG7CJZcCZ4ybZR54y4M(uJwzOoNAogDXxqBEgCNB8ZC5MXXcMxZXXIMfhP8PB6CogDXxqBEgCN7CSnPdaHZnJB8tUzCSG51CCS162kDt0JehJU4lOnpdUZnotUzCm6IVG28m4ySUCQRGJ9aYUhxQ7b6knbEQLEXaTUfKnjYAcY(aY6HGox(BkCCQrRG1T7yzGHKU4lOnYMibYYMrShdN83u44uJwbRB3XYadztRrDqKnhK9z2iRPCSG51CCmCJbrDlQViGo35gJhUzCm6IVG28m4ySUCQRGJ9b0AzXYR8qmhu20Auhezb5fzxyBKnjY(b0AzXYR8qmhucKISjrwykjekp6fYHYfrWQqOIn4JJriBoViBMiBsK1eK9bK1dbDU83u44uJwbRB3XYadjDXxqBKnrcKLnJypgo5VPWXPgTcw3UJLbgYMwJ6GiBoi7ZSrwt5ybZR54ylIGvHqfBWhhJ4o3yWLBghJU4lOnpdogRlN6k4yFaTwwS8kpeZbLnTg1brwqEr2f2gztISFaTwwS8kpeZbLaPiBsK1eK9bK1dbDU83u44uJwbRB3XYadjDXxqBKnrcKLnJypgo5VPWXPgTcw3UJLbgYMwJ6GiBoi7ZSrwt5ybZR54y6EGUc6DbkXDUXzZnJJrx8f0MNbhlyEnhhJfcHkyEnNsuqNJjkORUyL4yeeshJGCNBm4a3mogDXxqBEgCSG51CCmwieQG51CkrbDoMOGU6IvIJXMrShdhK7CJZICZ4y0fFbT5zWXcMxZXXAGtfmVMtjkOZXyD5uxbhZdbDU83u44uJwbRB3XYadjDXxqBKnjYAcYAcYYMrShdN83u44uJwbRB3XYadztRrDqK9fzZfztISSze7XWjtlHiA1Ov6EGUSP1OoiYccY(mxK1uKnrcK1eKLnJypgo5VPWXPgTcw3UJLbgYMwJ6GiliiBM5ISjrwVwjLpQDriliilEYgznfznLJjkORUyL4y)bQsNru3c35gJx5MXXOl(cAZZGJfmVMJJ1aNkyEnNsuqNJX6YPUco2hqRL)MchNA0kyD7owgyibs5yIc6Qlwjo2FGkVyGw3c35gNf4MXXOl(cAZZGJfmVMJJ1aNkyEnNsuqNJX6YPUco2hqRLPLqeTA0kDpqxcKISjrwpe05Y5lkN6WR5K0fFbT5yIc6Qlwjo28fLtD41CCNB8ZC5MXXOl(cAZZGJfmVMJJ1aNkyEnNsuqNJX6YPUcowW8c8KIoATiiYMZlYMjhtuqxDXkXXIH4o34Np5MXXOl(cAZZGJfmVMJJXcHqfmVMtjkOZXef0vxSsCmOh3o6n35ohlgIBg34NCZ4y0fFbT5zWXyD5uxbhZdbDUCjCCux3Ic6tVkPl(cAJSjsGSMGSXJuxoj198iDkNwtjOl74afztISWusiuE0lKdLnTonKeeeQmuNtnYMZlYIhKnjY(aY(b0AzxRKeifznLJfmVMJJ1060qsqqOYqDo1CNBCMCZ4y0fFbT5zWXyD5uxbhZdbDUu3d0HS8oossx8f0MJfmVMJJTicwfcvSbFCmI7CJXd3mogDXxqBEgCmwxo1vWXmbz30hqRLD840fJKqpyGISGGSzJSjsGSB6dO1YoEC6IrYMwJ6Gilii7ZCrwtr2KilBgXEmCYMwNgscccvgQZPw20Auhezb5fzZezXBKDHTr2KiRhc6C5s44OUUff0NEvsx8f0gztISpGSEiOZL6EGoKL3Xrs6IVG2CSG51CCmDpqxb9UaL4yS8mbP8OxihYn(j35gdUCZ4y0fFbT5zWXyD5uxbhJnJypgoztRtdjbbHkd15ulBAnQdISG8ISzIS4nYUW2iBsK1dbDUCjCCux3Ic6tVkPl(cAZXcMxZXX09aDf07cuI7CJZMBghJU4lOnpdogRlN6k4yFaTw21kjbs5ybZR54y4gdI6wuFraDUZngCGBghJU4lOnpdogRlN6k4yFaTwcAje1TOwdgU6ijqkhlyEnhht3d0HS8ooI7CJZICZ4y0fFbT5zWXyD5uxbhRbUIPshdul3KUyLJSGGSMGSpZgzXhz9qqNlBGRyQWD6acVMtsx8f0gzXBKfpiRPCSG51CCSfrWQqOIn4JJrCNBmELBghJU4lOnpdogRlN6k4yMGSB6dO1YoEC6IrsOhmqrwqq2Sr2ejq2n9b0AzhpoDXiztRrDqKfeK9zUiRPiBsKTbUIPshdul3KUyLJSGGSMGSpZgzXhz9qqNlBGRyQWD6acVMtsx8f0gzXBKfpiRPiBsK9bK1dbDUu3d0HS8oossx8f0MJfmVMJJP7b6kO3fOehJLNjiLh9c5qUXp5o34Sa3mogDXxqBEgCmwxo1vWXAGRyQ0Xa1YnPlw5iliiRji7ZSrw8rwpe05Yg4kMkCNoGWR5K0fFbTrw8gzXdYAkYMezFaz9qqNl19aDilVJJK0fFbT5ybZR54y6EGUc6DbkXDUXpZLBghlyEnhhRP1PHKGGqLH6CQ5y0fFbT5zWDUXpFYnJJfmVMJJP7b6qwEhhXXOl(cAZZG7CJFMj3mogDXxqBEgCmwxo1vWXmbz30hqRLD840fJKqpyGISGGSzJSjsGSB6dO1YoEC6IrYMwJ6Gilii7ZCrwtr2KiBdCftLogOwUjDXkhzZbznbzZmBKfFK1dbDUSbUIPc3Pdi8AojDXxqBKfVrw8GSMISjr2hqwpe05sDpqhYY74ijDXxqBowW8Aoo28fLtD4ehJLNjiLh9c5qUXp5o34N4HBghJU4lOnpdogRlN6k4ynWvmv6yGA5M0fRCKnhK1eKnZSrw8rwpe05Yg4kMkCNoGWR5K0fFbTrw8gzXdYAkhlyEnhhB(IYPoCI7CJFcUCZ4ybZR54ylIGvHqfBWhhJ4y0fFbT5zWDUXpZMBghJU4lOnpdogRlN6k4yMGSB6dO1YoEC6IrsOhmqrwqq2Sr2ejq2n9b0AzhpoDXiztRrDqKfeK9zUiRPiBsK9bK1dbDUu3d0HS8oossx8f0MJfmVMJJP7b6kO3fOehJLNjiLh9c5qUXp5o34NGdCZ4ybZR54y6EGUc6DbkXXOl(cAZZG7CJFMf5MXXcMxZXXWn9PgTYqDo1Cm6IVG28m4o34N4vUzCSG51CCSOzXrkF6MoNJrx8f0MNb35o35yGNAynh34mZ9zwi3SyMzYXme9v3cKJboFnDAN2i7ZCr2G51CiROGouIaJJbtjg34mZ(jhlThDjiowwISz9EGoYcodfooKnR9vl4CeyzjYIZ9uywJ5MVuooGVKnRMdRvar41CSo0U5WALzocSSezbdqKhzZ8PriBM5(mlGSGtiBMpZAa3CrGHallrwWX4IBHGzniWYsKfCczbNFmbWMqwWzRBJSz9MOhjjcSSezbNqw8s7nYQdH4hmqrw90ilaSUfKfVi4OGJyeYIxEY6iBPr2urKNAKTUYRWjiYMXGHSFspnHSPZiQBbzfZsXq2cISSznvqoTLiWYsKfCczbhJlUfcz9Oxix61kP8rTlcz9bz9ALu(O2fHS(GSaqczPJnaNtnYkOBXXHSD44OgzDCXHSPJtNxHaz9oG4q2nfooOebgcSSezXlM1cXaCAJSFspnHSSz9hoY(PL6GsKfVeJrPoezV5aNWf9QgqGSbZR5Gi7CI8seyzjYgmVMdktBInR)WF1IackcSSezdMxZbLPnXM1F44)AUEMncSSezdMxZbLPnXM1F44)AEaSSsNhEnhcSSezXUifIBCKTJAJSFaTM2il0dhISFspnHSSz9hoY(PL6GiBCBKnTjWP0X96wq2cIS75ijcSSezdMxZbLPnXM1F44)Ao8IuiUXvqpCicSG51CqzAtSz9ho(VMNoEnhcSG51CqzAtSz9ho(VMd(OR4liJUyLEhhh1Q5uaqsrzfqLMsBJaFiaOxtOScOstPT8gF6AaGQfrSRWNgQ(XEHsKGYkGknL2syDf0PwTiIDf(0q1p2luIeuwbuPP0wcRRGo1QfrSRWNgQwPDie1CjsqzfqLMsBj4RqOgTkUAnCAR(Iz2jsqzfqLMsBPUAORwdNGkyA(fraHjsqzfqLMsBjEbcQWngeuNibLvavAkTL34txdauTiIDf(0q1kTdHOMZueyiWYsKfVywledWPnYsGN68iRxReY64iKny(0iBbr2a8rjIVGKiWcMxZbFxRBR0nrpsiWYsKfVuAQipYM17b6iBwNap1iBCBKDnQZJ6qwW5S8iRzHyoicSG51Cq8Fnh3yqu3I6lcOBuPFFypUu3d0vAc8ul9IbADljn5bpe05YFtHJtnAfSUDhldmK0fFbTtKGnJypgo5VPWXPgTcw3UJLbgYMwJ6G58mBtrGfmVMdI)R5lIGvHqfBWhhJmQ0VFaTwwS8kpeZbLnTg1bb5DHTt(b0AzXYR8qmhucKMeMscHYJEHCOCreSkeQyd(4yuoVzM0Kh8qqNl)nfoo1OvW62DSmWqsx8f0orc2mI9y4K)MchNA0kyD7owgyiBAnQdMZZSnfbwW8Aoi(VMR7b6kO3fOKrL(9dO1YILx5HyoOSP1OoiiVlSDYpGwllwELhI5GsG0KM8Ghc6C5VPWXPgTcw3UJLbgs6IVG2jsWMrShdN83u44uJwbRB3XYadztRrDWCEMTPiWcMxZbX)1CwieQG51CkrbDJUyLEjiKogbrGfmVMdI)R5SqiubZR5uIc6gDXk9YMrShdhebwW8Aoi(VM3aNkyEnNsuq3OlwP3)avPZiQBXOs)6HGox(BkCCQrRG1T7yzGHKU4lODstmHnJypgo5VPWXPgTcw3UJLbgYMwJ6GV5MKnJypgozAjerRgTs3d0LnTg1bb5zUMMiHjSze7XWj)nfoo1OvW62DSmWq20AuheKmZnPxRKYh1UiqWt2MAkcSG51Cq8FnVbovW8AoLOGUrxSsV)bQ8IbADlgv63pGwl)nfoo1OvW62DSmWqcKIalyEnhe)xZBGtfmVMtjkOB0fR078fLtD41Cgv63pGwltlHiA1Ov6EGUeinPhc6C58fLtD41Cs6IVG2iWcMxZbX)18g4ubZR5uIc6gDXk9gdzuPFdMxGNu0rRfbZ5nteybZR5G4)AolecvW8AoLOGUrxSsVqpUD0BeyiWcMxZbLXqVnTonKeeeQmuNtTrL(1dbDUCjCCux3Ic6tVkPl(cANiHjXJuxoj198iDkNwtjOl74anjmLecLh9c5qztRtdjbbHkd15uNZlEs(WhqRLDTssGutrGfmVMdkJHW)18frWQqOIn4JJrgv6xpe05sDpqhYY74ijDXxqBeybZR5GYyi8Fnx3d0vqVlqjJy5zcs5rVqo89PrL(1Kn9b0AzhpoDXij0dgOGKDIeB6dO1YoEC6IrYMwJ6GG8mxttYMrShdNSP1PHKGGqLH6CQLnTg1bb5nt8EHTt6HGoxUeooQRBrb9PxL0fFbTt(Ghc6CPUhOdz5DCKKU4lOncSG51Cqzme(VMR7b6kO3fOKrL(LnJypgoztRtdjbbHkd15ulBAnQdcYBM49cBN0dbDUCjCCux3Ic6tVkPl(cAJalyEnhugdH)R54gdI6wuFraDJk97hqRLDTssGueybZR5GYyi8Fnx3d0HS8ooYOs)(b0AjOLqu3IAny4QJKaPiWcMxZbLXq4)A(IiyviuXg8XXiJk9BdCftLogOwUjDXkhetEMn(EiOZLnWvmv4oDaHxZjPl(cAJ34XueybZR5GYyi8Fnx3d0vqVlqjJy5zcs5rVqo89PrL(1Kn9b0AzhpoDXij0dgOGKDIeB6dO1YoEC6IrYMwJ6GG8mxtt2axXuPJbQLBsxSYbXKNzJVhc6CzdCftfUthq41Cs6IVG24nEmn5dEiOZL6EGoKL3Xrs6IVG2iWcMxZbLXq4)AUUhORGExGsgv63g4kMkDmqTCt6IvoiM8mB89qqNlBGRyQWD6acVMtsx8f0gVXJPjFWdbDUu3d0HS8oossx8f0gbwW8AoOmgc)xZBADAijiiuzOoNAeybZR5GYyi8Fnx3d0HS8oocbwW8AoOmgc)xZNVOCQdNmILNjiLh9c5W3Ngv6xt20hqRLD840fJKqpyGcs2jsSPpGwl74XPlgjBAnQdcYZCnnzdCftLogOwUjDXkphtYmB89qqNlBGRyQWD6acVMtsx8f0gVXJPjFWdbDUu3d0HS8oossx8f0gbwW8AoOmgc)xZNVOCQdNmQ0VnWvmv6yGA5M0fR8CmjZSX3dbDUSbUIPc3Pdi8AojDXxqB8gpMIalyEnhugdH)R5lIGvHqfBWhhJqGfmVMdkJHW)1CDpqxb9UaLmILNjiLh9c5W3Ngv6xt20hqRLD840fJKqpyGcs2jsSPpGwl74XPlgjBAnQdcYZCnn5dEiOZL6EGoKL3Xrs6IVG2iWcMxZbLXq4)AUUhORGExGsiWcMxZbLXq4)AoUPp1OvgQZPgbwW8AoOmgc)xZJMfhP8PB6CeyiWYsKnJMchhYoAKfRUDhldmq20ze1TGS94HxZHSznil0J2HiBM5cr2pPNMqw8YLqenYoAKnR3d0rw8r2mgmKnAczdWhLi(ccbwW8AoO8pqv6mI6wEXnge1TO(Ia6gv63pGwl7ALKaPiWcMxZbL)bQsNru3c(VMpFr5uhozelptqkp6fYHVpnQ0VMSPpGwl74XPlgjHEWafKStKytFaTw2XJtxms20AuheKN5AAYKnWvmv6yGA5M0fR8CEZm7Kp4HGoxQ7b6qwEhhjPl(cAJalyEnhu(hOkDgrDl4)A(8fLtD4KrL(TbUIPshdul3KUyLNZBMzJalyEnhu(hOkDgrDl4)A(IiyviuXg8XXiJk9BdCftLogOwUjDXkhKmZnjmLecLh9c5q5IiyviuXg8XXOCEZmjBgXEmCY0siIwnALUhOlBAnQdMt2iWcMxZbL)bQsNru3c(VMR7b6kO3fOKrS8mbP8Oxih((0Os)AYM(aATSJhNUyKe6bduqYorIn9b0AzhpoDXiztRrDqqEMRPjBGRyQ0Xa1YnPlw5GKzUjFWdbDUu3d0HS8oossx8f0ojBgXEmCY0siIwnALUhOlBAnQdMt2iWcMxZbL)bQsNru3c(VMR7b6kO3fOKrL(TbUIPshdul3KUyLdsM5MKnJypgozAjerRgTs3d0LnTg1bZjBeybZR5GY)avPZiQBb)xZ19aDilVJJmQ0VFaTwcAje1TOwdgU6ijqAYg4kMkDmqTCt6IvEoM8mB89qqNlBGRyQWD6acVMtsx8f0gVXJPjHPKqO8Oxihk19aDilVJJY5nteybZR5GY)avPZiQBb)xZ19aDilVJJmQ0VnWvmv6yGA5M0fR8CEnbpzJVhc6CzdCftfUthq41Cs6IVG24nEmnjmLecLh9c5qPUhOdz5DCuoVzIalyEnhu(hOkDgrDl4)A(8fLtD4KrS8mbP8Oxih((0Os)AYM(aATSJhNUyKe6bduqYorIn9b0AzhpoDXiztRrDqqEMRPjBGRyQ0Xa1YnPlw558AcEYgFpe05Yg4kMkCNoGWR5K0fFbTXB8yAYh8qqNl19aDilVJJK0fFbTrGfmVMdk)duLoJOUf8FnF(IYPoCYOs)2axXuPJbQLBsxSYZ51e8Kn(EiOZLnWvmv4oDaHxZjPl(cAJ34XueybZR5GY)avPZiQBb)xZxebRcHk2GpogzuPFzZi2JHtMwcr0QrR09aDztRrDWCAGJKETskFuGBYg4kMkDmqTCt6IvoiGBUjHPKqO8OxihkxebRcHk2GpogLZBMiWcMxZbL)bQsNru3c(VMR7b6kO3fOKrS8mbP8Oxih((0Os)AYM(aATSJhNUyKe6bduqYorIn9b0AzhpoDXiztRrDqqEMRPjzZi2JHtMwcr0QrR09aDztRrDWCAGJKETskFuGBYg4kMkDmqTCt6IvoiGBUjFWdbDUu3d0HS8oossx8f0gbwW8AoO8pqv6mI6wW)1CDpqxb9UaLmQ0VSze7XWjtlHiA1Ov6EGUSP1OoyonWrsVwjLpkWnzdCftLogOwUjDXkheWnxeyiWYsKnRhcXpyGIS(GSaqczXlpzDJqw8IGJcocYAahDilaKAWP6kVcNGiBgdgYM20A4anjYlrGfmVMdk)du5fd06wEtlHiA1Ov6EGUrL(LnJypgojTMogOw1ahPmqr6CYMwJ6GiWcMxZbL)bQ8IbADl4)AoTMogOw1ahPmqr6CiWcMxZbL)bQ8IbADl4)A(8fLtD4KrS8mbP8Oxih((0Os)AYM(aATSJhNUyKe6bduqYorIn9b0AzhpoDXiztRrDqqEMRPjBGRyQ0Xa1G8INCt(Ghc6CPUhOdz5DCKKU4lOncSG51Cq5FGkVyGw3c(VMpFr5uhozuPFBGRyQ0Xa1G8INmrGfmVMdk)du5fd06wW)18MwNgscccvgQZP2Os)6HGoxUeooQRBrb9PxL0fFbTrGfmVMdk)du5fd06wW)1CCJbrDlQViGUrL(9dO1YUwjjqkcSG51Cq5FGkVyGw3c(VMpFr5uhozelptqkp6fYHVpnQ0VMSPpGwl74XPlgjHEWafKStKytFaTw2XJtxms20AuheKN5AAYg4iPxRKYhv2GSW2js0axXuPJbQb5fCZo5dEiOZL6EGoKL3Xrs6IVG2iWcMxZbL)bQ8IbADl4)A(8fLtD4KrL(Tbos61kP8rLnilSDIenWvmv6yGAqEb3SrGfmVMdk)du5fd06wW)1CDpqhYY74iJk97hqRLGwcrDlQ1GHRoscKMeMscHYJEHCOu3d0HS8ookN3mrGfmVMdk)du5fd06wW)1CCtFQrRmuNtTrL(TbUIPshdul3KUyLNZlEYmzdCK0Rvs5Jcp5SW2iWcMxZbL)bQ8IbADl4)AEtRtdjbbHkd15uJalyEnhu(hOYlgO1TG)R56EGoKL3Xrgv6xykjekp6fYHsDpqhYY74OCEZebwW8AoO8pqLxmqRBb)xZNVOCQdNmILNjiLh9c5W3Ngv6xt20hqRLD840fJKqpyGcs2jsSPpGwl74XPlgjBAnQdcYZCnnzdCftLogOwUjDXkpNmZorIg4OCWtYh8qqNl19aDilVJJK0fFbTrGfmVMdk)du5fd06wW)185lkN6WjJk9BdCftLogOwUjDXkpNmZorIg4OCWdcSG51Cq5FGkVyGw3c(VMhnlos5t305gv63g4kMkDmqTCt6IvEozMlcmeyzjYcoEeBKfhfTJSS52LxZbrGfmVMdkzJyRWrr7VmCrDq1OvfJmQ0VFaTwYgXwHJI2LqpyGMt2j9ALu(O2fbYcBJalyEnhuYgXwHJI2X)1CgUOoOA0QIrgv6xt(aATmTeIOvJwP7b6YMwJ6GG8UW24TjpXNnJypgoPUhOBiFVcvAGoVSPyN30ej(aATmTeIOvJwP7b6YMwJ6GG0ahj9ALu(OWJPj)aATmTeIOvJwP7b6sG0KXJuxojlwEfR8ytczhhOG8MjcSG51CqjBeBfokAh)xZz4I6GQrRkgzuPF)aATmTeIOvJwP7b6YMwJ6GGGxt(b0AjWHBe5vqVPBXXjBAnQdcYcBJ3M8eF2mI9y4K6EGUH89kuPb68YMIDEtt(b0AjWHBe5vqVPBXXjBAnQdM8dO1Y0siIwnALUhOlbstgpsD5KSy5vSYJnjKDCGcYBMiWcMxZbLSrSv4OOD8FnNHlQdQgTQyKrL(1KpGwllwEfR8ytcztRrDqqa3ej(aATSy5vSYJnjKnTg1bbPbos61kP8rHhtt(b0AzXYRyLhBsibstgpsD5KSy5vSYJnjKDCGMtMiWcMxZbLSrSv4OOD8FnNHlQdQgTQyKrL(9dO1YILxXkp2KqcKM8dO1sGd3iYRGEt3IJtcKMmEK6YjzXYRyLhBsi74anNmrGHalyEnhuYMrShdh8fasQYPvJUyLEJhH4IoGk9CUA0Q0Xa1gv6xtyZi2JHtsRPJbQvnWrkduKoNSPyNp5dGp6k(csoooQvZPaGKIYkGknL2MMiHjSze7XWjtlHiA1Ov6EGUSP1OoiiVpZnj4JUIVGKJJJA1CkaiPOScOstPTPiWcMxZbLSze7XWbX)1CaiPkNwn6Iv6va0GsnuvhS21aavlL2nQ0VEiOZL)MchNA0kyD7owgyiPl(cAN0etyZi2JHtMwcr0QrR09aDztRrDqqEFMBsWhDfFbjhhh1Q5uaqsrzfqLMsBttKWKpGwltlHiA1Ov6EGUein5dGp6k(csoooQvZPaGKIYkGknL2MAAIeM8b0AzAjerRgTs3d0LaPjFWdbDU83u44uJwbRB3XYadjDXxqBtrGfmVMdkzZi2JHdI)R5aqsvoTA0fR0llptmEpxXuFraDJk97dFaTwMwcr0QrR09aDjqAW8AoOKnJypgoi(VMdajv50k0Os)AcBgXEmCY0siIwnALUhOlBk25tKGnJypgozAjerRgTs3d0LnTg1bZjZCnnPjp4HGox(BkCCQrRG1T7yzGHKU4lODIeSze7XWjP10Xa1Qg4iLbksNt20AuhmNSq2MIalyEnhuYMrShdhe)xZbGKQCA1OlwPx8ceuHBmiO2Os)AcLvavAkTLcGguQHQ6G1UgaOAP0EYpGwltlHiA1Ov6EGUSP1OoOPjsyYduwbuPP0wkaAqPgQQdw7AaGQLs7j)aATmTeIOvJwP7b6YMwJ6GG8mZKFaTwMwcr0QrR09aDjqQPiWcMxZbLSze7XWbX)1CaiPkNwn6Iv6f0BC1OvXXk6CLgOZBuPFzZi2JHtsRPJbQvnWrkduKoNSP1OoyoGBUiWcMxZbLSze7XWbX)1CaiPkNwn6Iv6DPNBbQs7AneQowiJk9BdCeiV4j5dFaTwMwcr0QrR09aDjqAstE4dO1YFtHJtnAfSUDhldmKaPjs8Ghc6C5VPWXPgTcw3UJLbgs6IVG2MIalyEnhuYMrShdhe)xZbGKQCA1OlwP3oECdCGcv)Ar10w9bCFoeybZR5Gs2mI9y4G4)AoaKuLtRgDXk9UsnbQJlGkDClgv63h(aAT83u44uJwbRB3XYadjqAYh(aATmTeIOvJwP7b6sGueybZR5Gs2mI9y4G4)AE641Cgv63pGwltlHiA1Ov6EGUein5hqRL0A6yGAvdCKYafPZjbsrGfmVMdkzZi2JHdI)R5FXmBLgOZBuPF)aATmTeIOvJwP7b6sG0KFaTwsRPJbQvnWrkduKoNeifbwW8AoOKnJypgoi(VM)PgsnO1TyuPF)aATmTeIOvJwP7b6sGueyzjYM17b6ilBgXEmCqeybZR5Gs2mI9y4G4)AEAjerRgTs3d0nQ0VSze7XWjP10Xa1Qg4iLbksNt20AuhebwW8AoOKnJypgoi(VM)BkCCQrRG1T7yzGHraqsnATAHTFFAuPFzZi2JHtsRPJbQvnWrkduKoNSP1Ooys2mI9y4KPLqeTA0kDpqx20AuhebwW8AoOKnJypgoi(VMtRPJbQvnWrkduKoNrL(LnJypgozAjerRgTs3d0Lnf78jFWdbDU83u44uJwbRB3XYadjDXxq7KnWrsVwjLpQSZzHTt2axXuPJbQLBsxSYZ59zUjs41kP8rTlcKmZfbwW8AoOKnJypgoi(VMtRPJbQvnWrkduKoNrL(1e2mI9y4KPLqeTA0kDpqx2uSZNiHxRKYh1UiqYmxtt6HGox(BkCCQrRG1T7yzGHKU4lODYg4kMkDmqDoGd5IalyEnhuYMrShdhe)xZzHqOcMxZPef0n6Iv6LnITchfTBuPF9qqNlzJyRWrr7s6IVG2jnXKpGwlzJyRWrr7sOhmqZ59zUj30hqRLD840fJKqpyG(MTPjs41kP8rTlcK3f22ueybZR5Gs2mI9y4G4)AUUhOBiFVcvAGoVrL(1KpGwltlHiA1Ov6EGUSP1OoiiVlSDIeM8b0AzAjerRgTs3d0LnTg1bbbVM8dO1sGd3iYRGEt3IJt20AuheK3f2o5hqRLahUrKxb9MUfhNei1utt(b0AzAjerRgTs3d0LaPjJhPUCswS8kw5XMeYooqb5nteybZR5Gs2mI9y4G4)AUUhOBiFVcvAGoVrL(1KpGwllwEfR8ytcztRrDqqExy7ejm5dO1YILxXkp2Kq20Auhee8AYpGwlboCJiVc6nDlooztRrDqqExy7KFaTwcC4grEf0B6wCCsGutnn5hqRLflVIvESjHeinz8i1LtYILxXkp2Kq2XbAozIalyEnhuYMrShdhe)xZ19aDd57vOsd05nQ0VETskFu7IazHTtKWeVwjLpQDrGWMrShdNmTeIOvJwP7b6YMwJ6Gj)aATe4WnI8kO30T44KaPMIadbwW8AoOKGq6ye89lMzRgTYXrk6O18gv63pGwltlHiA1Ov6EGUSP1OoiipZnjBgXEmCYFtHJtnAfSUDhldmKnTg1btK4dO1Y0siIwnALUhOlBAnQdcYZCt(Ghc6C5VPWXPgTcw3UJLbgs6IVG2iWcMxZbLeeshJG4)A(cq07ko1OvXJupooeybZR5GsccPJrq8FnNHRecf0Bka1Os)(b0AzAjerRgTs3d0LnTg1bbj7ej8ALu(O2fbs2iWcMxZbLeeshJG4)AUJJua3FaUTspnJmQ0VFaTw2edubbHk90mscKMiXhqRLnXavqqOspnJuSb4CQLqpyGcYZNiWcMxZbLeeshJG4)AUEyaqARIhPUCs9Py1Os)(WhqRLPLqeTA0kDpqxcKM8HpGwl)nfoo1OvW62DSmWqcKIalyEnhusqiDmcI)R5S5y05D40wPfXkzuPFF4dO1Y0siIwnALUhOlbst(WhqRL)MchNA0kyD7owgyibstUhxYMJrN3HtBLweRK6d0NSP1Oo4BUiWcMxZbLeeshJG4)AEkqx681TO(Ia6gv63h(aATmTeIOvJwP7b6sG0Kp8b0A5VPWXPgTcw3UJLbgsGueybZR5GsccPJrq8Fn3W0In4P6unbNlogzuPFF4dO1Y0siIwnALUhOlbst(WhqRL)MchNA0kyD7owgyibsrGfmVMdkjiKogbX)18UstfKQofmnyKrL(9HpGwltlHiA1Ov6EGUein5dFaTw(BkCCQrRG1T7yzGHeifbwW8AoOKGq6yee)xZxP1PZRgTsaWQTA3uScnQ0VFaTwsRPJbQvnWrkduKoNSP1OoiizN8dO1YFtHJtnAfSUDhldmKaPjsysdCK0Rvs5JkZCwy7KnWvmv6yGAqYoxtrGHallr2Sw)IYPo8AoKThp8AoeybZR5GY5lkN6WR5EBADAijiiuzOoNAJk9Rhc6C5s44OUUff0NEvsx8f0gbwW8AoOC(IYPo8Ao8FnF(IYPoCYiwEMGuE0lKdFFAuPFnztFaTw2XJtxmsc9GbkizNiXM(aATSJhNUyKSP1OoiipZ10Kp4HGoxQ7b6qwEhhjPl(cAN8HpGwl7ALKaPjHPKqO8OxihkXnge1TO(Ia658IheybZR5GY5lkN6WR5W)185lkN6WjJk97dEiOZL6EGoKL3Xrs6IVG2jF4dO1YUwjjqAsykjekp6fYHsCJbrDlQViGEoV4bbwW8AoOC(IYPo8Ao8Fnx3d0HS8ooYOs)AYhqRLGwcrDlQ1GHRos2uW8ejm5dO1sqlHOUf1AWWvhjbstAsAtGxTW2YNsDpqxb9UaLsKiTjWRwyB5tjUXGOUf1xeqprI0MaVAHTLpLlIGvHqfBWhhJm1uttctjHq5rVqouQ7b6qwEhhLZBMiWcMxZbLZxuo1HxZH)R5Zxuo1HtgXYZeKYJEHC47tJk9RjB6dO1YoEC6IrsOhmqbj7ej20hqRLD840fJKnTg1bb5zUMM8dO1sqlHOUf1AWWvhjBkyEIeM8b0AjOLqu3IAny4QJKaPjnjTjWRwyB5tPUhORGExGsjsK2e4vlST8Pe3yqu3I6lcONirAtGxTW2YNYfrWQqOIn4JJrMAkcSG51Cq58fLtD41C4)A(8fLtD4KrL(9dO1sqlHOUf1AWWvhjBkyEIeM8b0AjOLqu3IAny4QJKaPjnjTjWRwyB5tPUhORGExGsjsK2e4vlST8Pe3yqu3I6lcONirAtGxTW2YNYfrWQqOIn4JJrMAkcSG51Cq58fLtD41C4)A(IiyviuXg8XXiJk9Rjp8b0AzxRKeinrIg4kMkDmqTCt6IvoipZnrIg4iPxRKYhvM5SW2MMeMscHYJEHCOCreSkeQyd(4yuoVzIalyEnhuoFr5uhEnh(VMJBmiQBr9fb0nQ0VFaTw21kjbstctjHq5rVqouIBmiQBr9fb0Z5nteybZR5GY5lkN6WR5W)1CDpqxb9UaLmILNjiLh9c5W3Ngv6xt20hqRLD840fJKqpyGcs2jsSPpGwl74XPlgjBAnQdcYZCnn5dFaTw21kjbstKObUIPshdul3KUyLdYZCtKObos61kP8rLzolSDYh8qqNl19aDilVJJK0fFbTrGfmVMdkNVOCQdVMd)xZ19aDf07cuYOs)(WhqRLDTssG0ejAGRyQ0Xa1YnPlw5G8m3ejAGJKETskFuzMZcBJalyEnhuoFr5uhEnh(VMJBmiQBr9fb0nQ0VFaTw21kjbsrGfmVMdkNVOCQdVMd)xZNVOCQdNmILNjiLh9c5W3Ngv6xt20hqRLD840fJKqpyGcs2jsSPpGwl74XPlgjBAnQdcYZCnn5dEiOZL6EGoKL3Xrs6IVG2iWcMxZbLZxuo1HxZH)R5Zxuo1HtiWqGLLilMh3o6nYcRBrqGtE0lKJS94HxZHalyEnhuc942rVFBADAijiiuzOoNAeybZR5GsOh3o6n(VMR7b6kO3fOKrL(LnJypgoztRtdjbbHkd15ulBAnQdcYBM49cBN0dbDUCjCCux3Ic6tVkPl(cAJalyEnhuc942rVX)1CCJbrDlQViGUrL(9dO1YUwjjqkcSG51Cqj0JBh9g)xZNVOCQdNmQ0Vp8b0APUNhPtLciGKeinPhc6CPUNhPtLciGKKU4lOncSG51Cqj0JBh9g)xZ19aDf07cuYOs)2axXuPJbQLBsxSYbXKNzJVhc6CzdCftfUthq41Cs6IVG24nEmfbwW8AoOe6XTJEJ)R56EGoKL3Xrgv63pGwlbTeI6wuRbdxDKeinzdCK0Rvs5JcCZ5DHTrGfmVMdkHEC7O34)A(8fLtD4KrL(TbUIPshdul3KUyLNJjzMn(EiOZLnWvmv4oDaHxZjPl(cAJ34XueybZR5GsOh3o6n(VMR7b6kO3fOecSG51Cqj0JBh9g)xZXn9PgTYqDo1iWcMxZbLqpUD0B8FnpAwCKYNUPZ5o35Ca]] )


end
