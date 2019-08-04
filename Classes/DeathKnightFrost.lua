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


    spec:RegisterPack( "Frost DK", 20190803.2145, [[dGuE6bqiLepsuK2Ki1OOu6uuQSkiL6vqQMfLOBbKGDr0VOu1Wev6ykPwMOupdi10GuY1eLSnGe6BajLXbKKZjkcRtuezEaX9uL2NOIdkkQQfkk8qGeXebsKCrGKkBuuu5KajkReO6LIIO6MajsTtkHFkkIsdfiPQLkkQspfIPsP4RIIQyVO6VKmykoSWIvvpgLjRuxgzZK6ZkXOHKtlz1ajQEnqz2eUTQy3Q8BfdxehxuuwUuph00P66a2oKIVtjnErruCErvRxjP5ls2puZxZTHJSdN4wKDURZe5cQYf0YSxJwGolqfhXZNqCKKGbwSqCKlEiosMRhOJnGsLjNJKe5ftS52WrGdqZiock3tGzs2B)s5Oa(s28ypSEaeHxZX6q72dRhM9CKpqjCqzh)Zr2HtClYo31zICbv5cAz2RrlqN1Aosa4OMMJGupGs4iOQ9Mo(NJSjiJJKPytMRhOJnGsrHJcBYKF1ckhdEMInOCpbMjzV9lLJc4lzZJ9W6bqeEnhRdTBpSEy2JbptXMmFGfaOJnG2sSj7CxNjWgqbSjtKjHw5IbhdEMInGsqf3cbZKWGNPydOa2ak7ycGnHnGsx3gBYCnrRssm4zk2akGnz(7n2OdH4hmWWg90ydaSUfSbuxM3mpwInG6Nmh2uASjre5PgBQR8kCcInzmiyZN0ttytYmI6wWgXSumSPGydBEseKtBjg8mfBafWgqjOIBHWgp6fYLE9qkFu7IWgFWgVEiLpQDryJpydaKWg6ydW5uJnc6wCuythokQXghvCytY405viWgVdikSztHJck5iIc6qUnCe2i2kuu0o3gUfR52WrOl(cAZZGJW6YPUcoYhqRLSrSvOOODj0dgyytoytwytASXRhs5JAxe2ac2SW2CKG51CCegQOoOA0QIrCNBr2CB4i0fFbT5zWryD5uxbhXwS5dO1YKsiIwnALUhOlB6jQdInG8InlSn2G2yJTyZASbDSHnJypwpPUhOBnF)avAGoVSPyNhBSdBsLcB(aATmPeIOvJwP7b6YMEI6GydiytdCK0Rhs5Jc0yJDytAS5dO1YKsiIwnALUhOlbsWM0ytSk1LtYILxXkp2Kq2Xbg2aYl2KnhjyEnhhHHkQdQgTQye35waAUnCe6IVG28m4iSUCQRGJ8b0AzsjerRgTs3d0Ln9e1bXgqWgqf2KgB(aATe4qnI8kO30T4OKn9e1bXgqWMf2gBqBSXwSzn2Go2WMrShRNu3d0TMVFGknqNx2uSZJn2HnPXMpGwlbouJiVc6nDlokztprDqSjn28b0AzsjerRgTs3d0LajytASjwL6YjzXYRyLhBsi74adBa5fBYMJemVMJJWqf1bvJwvmI7ClqlUnCe6IVG28m4iSUCQRGJyl28b0AzXYRyLhBsiB6jQdInGGnOf2Kkf28b0AzXYRyLhBsiB6jQdInGGnnWrsVEiLpkqJn2HnPXMpGwllwEfR8ytcjqc2KgBIvPUCswS8kw5XMeYooWWMCWMS5ibZR54imurDq1OvfJ4o3IS42WrOl(cAZZGJW6YPUcoYhqRLflVIvESjHeibBsJnFaTwcCOgrEf0B6wCusGeSjn2eRsD5KSy5vSYJnjKDCGHn5GnzZrcMxZXryOI6GQrRkgXDUZrMVOCQdVMJBd3I1CB4i0fFbT5zWryD5uxbhXdbDUCjCuux3Ic6t)iPl(cAZrcMxZXrA6zAijiiuzToNAUZTiBUnCe6IVG28m4ibZR54iZxuo1HtCewxo1vWrSfB20hqRLDS60fJKqpyGHnGGnzHnPsHnB6dO1YowD6IrYMEI6GydiyZ6CXg7WM0yZkyJhc6CPUhOdz5DuKKU4lOn2KgBwbB(aATSRhscKGnPXgycjekp6fYHsuJvrDlQViGo2KZl2aAoclptqkp6fYHClwZDUfGMBdhHU4lOnpdocRlN6k4iRGnEiOZL6EGoKL3rrs6IVG2ytASzfS5dO1YUEijqc2KgBGjKqO8Oxihkrnwf1TO(Ia6ytoVydO5ibZR54iZxuo1HtCNBbAXTHJqx8f0MNbhH1LtDfCeBXMpGwlbReI6wupbdvDKSPG5ytQuyJTyZhqRLGvcrDlQNGHQoscKGnPXgBXMKMqJAHTLRL6EGUc6DbgHnPsHnjnHg1cBlxlrnwf1TO(Ia6ytQuytstOrTW2Y1YfrWQqOInAIJryJDyJDyJDytASbMqcHYJEHCOu3d0HS8okcBY5fBYMJemVMJJO7b6qwEhfXDUfzXTHJqx8f0MNbhjyEnhhz(IYPoCIJW6YPUcoITyZM(aATSJvNUyKe6bdmSbeSjlSjvkSztFaTw2XQtxms20tuheBabBwNl2yh2KgB(aATeSsiQBr9emu1rYMcMJnPsHn2InFaTwcwje1TOEcgQ6ijqc2KgBSfBsAcnQf2wUwQ7b6kO3fye2Kkf2K0eAulSTCTe1yvu3I6lcOJnPsHnjnHg1cBlxlxebRcHk2OjogHn2Hn2Xry5zcs5rVqoKBXAUZTauKBdhHU4lOnpdocRlN6k4iFaTwcwje1TOEcgQ6iztbZXMuPWgBXMpGwlbReI6wupbdvDKeibBsJn2InjnHg1cBlxl19aDf07cmcBsLcBsAcnQf2wUwIASkQBr9fb0XMuPWMKMqJAHTLRLlIGvHqfB0ehJWg7Wg74ibZR54iZxuo1HtCNBbOg3gocDXxqBEgCewxo1vWrSfBwbB(aATSRhscKGnPsHnnWvmvYyLA5M0fRCSbeSzDUytQuytdCK0Rhs5JkBSjhSzHTXg7WM0ydmHecLh9c5q5IiyviuXgnXXiSjNxSjBosW8AooYIiyviuXgnXXiUZTauXTHJqx8f0MNbhH1LtDfCKpGwl76HKajytASbMqcHYJEHCOe1yvu3I6lcOJn58InzZrcMxZXrqnwf1TO(Ia6CNBrMGBdhHU4lOnpdosW8AooIUhORGExGrCewxo1vWrSfB20hqRLDS60fJKqpyGHnGGnzHnPsHnB6dO1YowD6IrYMEI6GydiyZ6CXg7WM0yZkyZhqRLD9qsGeSjvkSPbUIPsgRul3KUyLJnGGnRZfBsLcBAGJKE9qkFuzJn5GnlSn2KgBwbB8qqNl19aDilVJIK0fFbT5iS8mbP8OxihYTyn35wSoxUnCe6IVG28m4iSUCQRGJSc28b0AzxpKeibBsLcBAGRyQKXk1YnPlw5ydiyZ6CXMuPWMg4iPxpKYhv2ytoyZcBZrcMxZXr09aDf07cmI7ClwVMBdhHU4lOnpdocRlN6k4iFaTw21djbs4ibZR54iOgRI6wuFraDUZTyD2CB4i0fFbT5zWrcMxZXrMVOCQdN4iSUCQRGJyl2SPpGwl7y1PlgjHEWadBabBYcBsLcB20hqRLDS60fJKn9e1bXgqWM15In2HnPXMvWgpe05sDpqhYY7OijDXxqBoclptqkp6fYHClwZDUfRbn3gosW8AooY8fLtD4ehHU4lOnpdUZDoYFGkVyGv3c3gUfR52WrOl(cAZZGJW6YPUcocBgXESEs6jzSsTQboszLIK5Kn9e1b5ibZR54ijLqeTA0kDpqN7ClYMBdhjyEnhhHEsgRuRAGJuwPizoocDXxqBEgCNBbO52WrOl(cAZZGJemVMJJmFr5uhoXryD5uxbhXwSztFaTw2XQtxmsc9Gbg2ac2Kf2Kkf2SPpGwl7y1PlgjB6jQdInGGnRZfBSdBsJnnWvmvYyLASbKxSb05InPXMvWgpe05sDpqhYY7OijDXxqBoclptqkp6fYHClwZDUfOf3gocDXxqBEgCewxo1vWrAGRyQKXk1ydiVydOZMJemVMJJmFr5uhoXDUfzXTHJqx8f0MNbhH1LtDfCepe05YLWrrDDlkOp9JKU4lOnhjyEnhhPPNPHKGGqL16CQ5o3cqrUnCe6IVG28m4iSUCQRGJ8b0AzxpKeiHJemVMJJGASkQBr9fb05o3cqnUnCe6IVG28m4ibZR54iZxuo1HtCewxo1vWrSfB20hqRLDS60fJKqpyGHnGGnzHnPsHnB6dO1YowD6IrYMEI6GydiyZ6CXg7WM0ytdCK0Rhs5JklSbeSzHTXMuPWMg4kMkzSsn2aYl2GwzHnPXMvWgpe05sDpqhYY7OijDXxqBoclptqkp6fYHClwZDUfGkUnCe6IVG28m4iSUCQRGJ0ahj96Hu(OYcBabBwyBSjvkSPbUIPsgRuJnG8InOvwCKG51CCK5lkN6WjUZTitWTHJqx8f0MNbhH1LtDfCKpGwlbReI6wupbdvDKeibBsJnWesiuE0lKdL6EGoKL3rrytoVyt2CKG51CCeDpqhYY7OiUZTyDUCB4i0fFbT5zWryD5uxbhPbUIPsgRul3KUyLJn58InGoBSjn20ahj96Hu(Oan2Kd2SW2CKG51CCeutFQrRSwNtn35wSEn3gosW8AoostptdjbbHkR15uZrOl(cAZZG7ClwNn3gocDXxqBEgCewxo1vWrGjKqO8Oxihk19aDilVJIWMCEXMS5ibZR54i6EGoKL3rrCNBXAqZTHJqx8f0MNbhjyEnhhz(IYPoCIJW6YPUcoITyZM(aATSJvNUyKe6bdmSbeSjlSjvkSztFaTw2XQtxms20tuheBabBwNl2yh2KgBAGRyQKXk1YnPlw5ytoyt2zHnPsHnnWrytoydOXM0yZkyJhc6CPUhOdz5DuKKU4lOnhHLNjiLh9c5qUfR5o3I1Of3gocDXxqBEgCewxo1vWrAGRyQKXk1YnPlw5ytoyt2zHnPsHnnWrytoydO5ibZR54iZxuo1HtCNBX6S42WrOl(cAZZGJW6YPUcosdCftLmwPwUjDXkhBYbBYoxosW8Aoos0S4iLpDtNZDUZriiKogb52WTyn3gocDXxqBEgCewxo1vWr(aATmPeIOvJwP7b6YMEI6GydiyZ6CXM0ydBgXESEYFtHJsnAfSUDhldmKn9e1bXMuPWMpGwltkHiA1Ov6EGUSPNOoi2ac2SoxSjn2Sc24HGox(BkCuQrRG1T7yzGHKU4lOnhjyEnhh5lMzRgTYrrk6ON8CNBr2CB4ibZR54ilarVR4uJwfRs94O4i0fFbT5zWDUfGMBdhHU4lOnpdocRlN6k4iFaTwMucr0QrR09aDztprDqSbeSjlSjvkSXRhs5JAxe2ac2KfhjyEnhhHHQecf0BkaJ7ClqlUnCe6IVG28m4iSUCQRGJ8b0AztmWeeeQ0tZijqc2Kkf28b0AztmWeeeQ0tZifBaoNAj0dgyydiyZ61CKG51CCehfPaU)aCBLEAgXDUfzXTHJqx8f0MNbhH1LtDfCKvWMpGwltkHiA1Ov6EGUeibBsJnRGnFaTw(BkCuQrRG1T7yzGHeiHJemVMJJOhgaK2QyvQlNuFkE4o3cqrUnCe6IVG28m4iSUCQRGJSc28b0AzsjerRgTs3d0LajytASzfS5dO1YFtHJsnAfSUDhldmKajytASzpUKnhJoVdN2kTiEi1hOpztprDqS5fBYLJemVMJJWMJrN3HtBLwepe35waQXTHJqx8f0MNbhH1LtDfCKvWMpGwltkHiA1Ov6EGUeibBsJnRGnFaTw(BkCuQrRG1T7yzGHeiHJemVMJJKa0LoFDlQViGo35waQ42WrOl(cAZZGJW6YPUcoYkyZhqRLjLqeTA0kDpqxcKGnPXMvWMpGwl)nfok1OvW62DSmWqcKWrcMxZXrSoTyJgQovtW5IJrCNBrMGBdhHU4lOnpdocRlN6k4iRGnFaTwMucr0QrR09aDjqc2KgBwbB(aAT83u4OuJwbRB3XYadjqchjyEnhhPRKebPQtbtcgXDUfRZLBdhHU4lOnpdocRlN6k4iFaTwspjJvQvnWrkRuKmNSPNOoi2ac2Kf2KgB(aAT83u4OuJwbRB3XYadjqc2Kkf2yl20ahj96Hu(OYgBYbBwyBSjn20axXujJvQXgqWMSYfBSJJemVMJJ8qptNxnALaGvB1UP4bYDUZr(duLmJOUfUnClwZTHJqx8f0MNbhH1LtDfCKpGwl76HKajCKG51CCeuJvrDlQViGo35wKn3gocDXxqBEgCKG51CCK5lkN6WjocRlN6k4i2InB6dO1YowD6IrsOhmWWgqWMSWMuPWMn9b0AzhRoDXiztprDqSbeSzDUyJDytASPbUIPsgRul3KUyLJn58InzNf2KgBwbB8qqNl19aDilVJIK0fFbT5iS8mbP8OxihYTyn35waAUnCe6IVG28m4iSUCQRGJ0axXujJvQLBsxSYXMCEXMSZIJemVMJJmFr5uhoXDUfOf3gocDXxqBEgCewxo1vWrAGRyQKXk1YnPlw5ydiyt25InPXgycjekp6fYHYfrWQqOInAIJrytoVyt2ytASHnJypwpzsjerRgTs3d0Ln9e1bXMCWMS4ibZR54ilIGvHqfB0ehJ4o3IS42WrOl(cAZZGJemVMJJO7b6kO3fyehH1LtDfCeBXMn9b0AzhRoDXij0dgyydiytwytQuyZM(aATSJvNUyKSPNOoi2ac2SoxSXoSjn20axXujJvQLBsxSYXgqWMSZfBsJnRGnEiOZL6EGoKL3rrs6IVG2ytASHnJypwpzsjerRgTs3d0Ln9e1bXMCWMS4iS8mbP8OxihYTyn35wakYTHJqx8f0MNbhH1LtDfCKg4kMkzSsTCt6Ivo2ac2KDUytASHnJypwpzsjerRgTs3d0Ln9e1bXMCWMS4ibZR54i6EGUc6DbgXDUfGACB4i0fFbT5zWryD5uxbh5dO1sWkHOUf1tWqvhjbsWM0ytdCftLmwPwUjDXkhBYbBSfBwNf2Go24HGox2axXuH70beEnNKU4lOn2G2ydOXg7WM0ydmHecLh9c5qPUhOdz5Due2KZl2KnhjyEnhhr3d0HS8okI7ClavCB4i0fFbT5zWryD5uxbhPbUIPsgRul3KUyLJn58In2InGolSbDSXdbDUSbUIPc3Pdi8AojDXxqBSbTXgqJn2HnPXgycjekp6fYHsDpqhYY7OiSjNxSjBosW8AooIUhOdz5Due35wKj42WrOl(cAZZGJemVMJJmFr5uhoXryD5uxbhXwSztFaTw2XQtxmsc9Gbg2ac2Kf2Kkf2SPpGwl7y1PlgjB6jQdInGGnRZfBSdBsJnnWvmvYyLA5M0fRCSjNxSXwSb0zHnOJnEiOZLnWvmv4oDaHxZjPl(cAJnOn2aASXoSjn2Sc24HGoxQ7b6qwEhfjPl(cAZry5zcs5rVqoKBXAUZTyDUCB4i0fFbT5zWryD5uxbhPbUIPsgRul3KUyLJn58In2InGolSbDSXdbDUSbUIPc3Pdi8AojDXxqBSbTXgqJn2XrcMxZXrMVOCQdN4o3I1R52WrOl(cAZZGJW6YPUcocBgXESEYKsiIwnALUhOlB6jQdIn5GnnWrsVEiLpk0cBsJnnWvmvYyLA5M0fRCSbeSbTYfBsJnWesiuE0lKdLlIGvHqfB0ehJWMCEXMS5ibZR54ilIGvHqfB0ehJ4o3I1zZTHJqx8f0MNbhjyEnhhr3d0vqVlWiocRlN6k4i2InB6dO1YowD6IrsOhmWWgqWMSWMuPWMn9b0AzhRoDXiztprDqSbeSzDUyJDytASHnJypwpzsjerRgTs3d0Ln9e1bXMCWMg4iPxpKYhfAHnPXMg4kMkzSsTCt6Ivo2ac2Gw5InPXMvWgpe05sDpqhYY7OijDXxqBoclptqkp6fYHClwZDUfRbn3gocDXxqBEgCewxo1vWryZi2J1tMucr0QrR09aDztprDqSjhSPbos61dP8rHwytASPbUIPsgRul3KUyLJnGGnOvUCKG51CCeDpqxb9UaJ4o35ijnXMNF4CB4wSMBdhjyEnhhjz8AoocDXxqBEgCNBr2CB4i0fFbT5zWrMeocKCosW8AoocAIUIVG4iOjeaehXwSHYmGkjH2YB8PRbaQweXUcFAO6h7fcBsLcBOmdOssOTewxbDQvlIyxHpnu9J9cHnPsHnuMbujj0wcRRGo1QfrSRWNgQEODie1CytQuydLzavscTLOPcHA0Q4QNWPT6lMzJnPsHnuMbujj0wQRg6QNWjOcMKFreqi2Kkf2qzgqLKqBjOCcQqnwfuJnPsHnuMbujj0wEJpDnaq1Ii2v4tdvp0oeIAoSXoocAIwDXdXrghf1Q5uaqsrzgqLKqBUZDosme3gUfR52WrOl(cAZZGJW6YPUcoIhc6C5s4OOUUff0N(rsx8f0gBsLcBSfBIvPUCsQ7zv6uo9Kqqx2Xbg2KgBGjKqO8OxihkB6zAijiiuzToNASjNxSb0ytASzfS5dO1YUEijqc2yhhjyEnhhPPNPHKGGqL16CQ5o3IS52WrOl(cAZZGJW6YPUcoIhc6CPUhOdz5DuKKU4lOnhjyEnhhzreSkeQyJM4ye35waAUnCe6IVG28m4ibZR54i6EGUc6DbgXryD5uxbhXwSztFaTw2XQtxmsc9Gbg2ac2Kf2Kkf2SPpGwl7y1PlgjB6jQdInGGnRZfBSdBsJnSze7X6jB6zAijiiuzToNAztprDqSbKxSjBSbTXMf2gBsJnEiOZLlHJI66wuqF6hjDXxqBSjn2Sc24HGoxQ7b6qwEhfjPl(cAZry5zcs5rVqoKBXAUZTaT42WrOl(cAZZGJW6YPUcocBgXESEYMEMgscccvwRZPw20tuheBa5fBYgBqBSzHTXM0yJhc6C5s4OOUUff0N(rsx8f0MJemVMJJO7b6kO3fye35wKf3gocDXxqBEgCewxo1vWr(aATSRhscKWrcMxZXrqnwf1TO(Ia6CNBbOi3gocDXxqBEgCewxo1vWr(aATeSsiQBr9emu1rsGeosW8AooIUhOdz5Due35waQXTHJqx8f0MNbhH1LtDfCKg4kMkzSsTCt6Ivo2ac2yl2SolSbDSXdbDUSbUIPc3Pdi8AojDXxqBSbTXgqJn2XrcMxZXrwebRcHk2OjogXDUfGkUnCe6IVG28m4ibZR54i6EGUc6DbgXryD5uxbhXwSztFaTw2XQtxmsc9Gbg2ac2Kf2Kkf2SPpGwl7y1PlgjB6jQdInGGnRZfBSdBsJnnWvmvYyLA5M0fRCSbeSXwSzDwyd6yJhc6CzdCftfUthq41Cs6IVG2ydAJnGgBSdBsJnRGnEiOZL6EGoKL3rrs6IVG2CewEMGuE0lKd5wSM7ClYeCB4i0fFbT5zWryD5uxbhPbUIPsgRul3KUyLJnGGn2InRZcBqhB8qqNlBGRyQWD6acVMtsx8f0gBqBSb0yJDytASzfSXdbDUu3d0HS8okssx8f0MJemVMJJO7b6kO3fye35wSoxUnCKG51CCKMEMgscccvwRZPMJqx8f0MNb35wSEn3gosW8AooIUhOdz5DuehHU4lOnpdUZTyD2CB4i0fFbT5zWrcMxZXrMVOCQdN4iSUCQRGJyl2SPpGwl7y1PlgjHEWadBabBYcBsLcB20hqRLDS60fJKn9e1bXgqWM15In2HnPXMg4kMkzSsTCt6Ivo2Kd2yl2KDwyd6yJhc6CzdCftfUthq41Cs6IVG2ydAJnGgBSdBsJnRGnEiOZL6EGoKL3rrs6IVG2CewEMGuE0lKd5wSM7ClwdAUnCe6IVG28m4iSUCQRGJ0axXujJvQLBsxSYXMCWgBXMSZcBqhB8qqNlBGRyQWD6acVMtsx8f0gBqBSb0yJDCKG51CCK5lkN6WjUZTynAXTHJemVMJJSicwfcvSrtCmIJqx8f0MNb35wSolUnCe6IVG28m4ibZR54i6EGUc6DbgXryD5uxbhXwSztFaTw2XQtxmsc9Gbg2ac2Kf2Kkf2SPpGwl7y1PlgjB6jQdInGGnRZfBSdBsJnRGnEiOZL6EGoKL3rrs6IVG2CewEMGuE0lKd5wSM7ClwdkYTHJemVMJJO7b6kO3fyehHU4lOnpdUZTynOg3gosW8AoocQPp1OvwRZPMJqx8f0MNb35wSguXTHJemVMJJenlos5t305Ce6IVG28m4o35iqpUD0BUnClwZTHJemVMJJ00Z0qsqqOYADo1Ce6IVG28m4o3IS52WrOl(cAZZGJW6YPUcocBgXESEYMEMgscccvwRZPw20tuheBa5fBYgBqBSzHTXM0yJhc6C5s4OOUUff0N(rsx8f0MJemVMJJO7b6kO3fye35waAUnCe6IVG28m4iSUCQRGJ8b0AzxpKeiHJemVMJJGASkQBr9fb05o3c0IBdhHU4lOnpdocRlN6k4iRGnFaTwQ7zv6ujacijbsWM0yJhc6CPUNvPtLaiGKKU4lOnhjyEnhhz(IYPoCI7ClYIBdhHU4lOnpdocRlN6k4inWvmvYyLA5M0fRCSbeSXwSzDwyd6yJhc6CzdCftfUthq41Cs6IVG2ydAJnGgBSJJemVMJJO7b6kO3fye35wakYTHJqx8f0MNbhH1LtDfCKpGwlbReI6wupbdvDKeibBsJnnWrsVEiLpk0cBY5fBwyBosW8AooIUhOdz5Due35waQXTHJqx8f0MNbhH1LtDfCKg4kMkzSsTCt6Ivo2Kd2yl2KDwyd6yJhc6CzdCftfUthq41Cs6IVG2ydAJnGgBSJJemVMJJmFr5uhoXDUfGkUnCKG51CCeDpqxb9UaJ4i0fFbT5zWDUfzcUnCKG51CCeutFQrRSwNtnhHU4lOnpdUZTyDUCB4ibZR54irZIJu(0nDohHU4lOnpdUZDoYM0bGW52WTyn3gosW8AooYtDBLUjAvIJqx8f0MNb35wKn3gocDXxqBEgCewxo1vWrwbB2Jl19aDLMqd1sVyGv3c2KgBSfBwbB8qqNl)nfok1OvW62DSmWqsx8f0gBsLcByZi2J1t(BkCuQrRG1T7yzGHSPNOoi2Kd2SolSXoosW8AoocQXQOUf1xeqN7Clan3gocDXxqBEgCewxo1vWr(aATSy5vEiMdkB6jQdInG8InlSn2KgB(aATSy5vEiMdkbsWM0ydmHecLh9c5q5IiyviuXgnXXiSjNxSjBSjn2yl2Sc24HGox(BkCuQrRG1T7yzGHKU4lOn2Kkf2WMrShRN83u4OuJwbRB3XYadztprDqSjhSzDwyJDCKG51CCKfrWQqOInAIJrCNBbAXTHJqx8f0MNbhH1LtDfCKpGwllwELhI5GYMEI6GydiVyZcBJnPXMpGwllwELhI5GsGeSjn2yl2Sc24HGox(BkCuQrRG1T7yzGHKU4lOn2Kkf2WMrShRN83u4OuJwbRB3XYadztprDqSjhSzDwyJDCKG51CCeDpqxb9UaJ4o3IS42WrOl(cAZZGJemVMJJWcHqfmVMtjkOZref0vx8qCeccPJrqUZTauKBdhHU4lOnpdosW8AooclecvW8AoLOGohruqxDXdXryZi2J1dYDUfGACB4i0fFbT5zWryD5uxbhXdbDU83u4OuJwbRB3XYadjDXxqBSjn2yl2yl2WMrShRN83u4OuJwbRB3XYadztprDqS5fBYfBsJnSze7X6jtkHiA1Ov6EGUSPNOoi2ac2SoxSXoSjvkSXwSHnJypwp5VPWrPgTcw3UJLbgYMEI6Gydiyt25InPXgVEiLpQDrydiydOZcBSdBSJJemVMJJ0aNkyEnNsuqNJikORU4H4i)bQsMru3c35waQ42WrOl(cAZZGJW6YPUcoYhqRL)MchLA0kyD7owgyibs4ibZR54inWPcMxZPef05iIc6QlEioYFGkVyGv3c35wKj42WrOl(cAZZGJW6YPUcoYhqRLjLqeTA0kDpqxcKGnPXgpe05Y5lkN6WR5K0fFbT5ibZR54inWPcMxZPef05iIc6QlEioY8fLtD41CCNBX6C52WrOl(cAZZGJW6YPUcosW8cnKIo6Pii2KZl2KnhjyEnhhPbovW8AoLOGohruqxDXdXrIH4o3I1R52WrOl(cAZZGJemVMJJWcHqfmVMtjkOZref0vx8qCeOh3o6n35ohHnJypwpi3gUfR52WrOl(cAZZGJemVMJJeRcrfDav65C1OvjJvQ5iSUCQRGJyl2WMrShRNKEsgRuRAGJuwPizoztXop2KgBwbBqt0v8fKCCuuRMtbajfLzavscTXg7WMuPWgBXg2mI9y9KjLqeTA0kDpqx20tuheBa5fBwNl2KgBqt0v8fKCCuuRMtbajfLzavscTXg74ix8qCKyviQOdOspNRgTkzSsn35wKn3gocDXxqBEgCKG51CCebqdg1qvDWAxdauTuANJW6YPUcoIhc6C5VPWrPgTcw3UJLbgs6IVG2ytASXwSXwSHnJypwpzsjerRgTs3d0Ln9e1bXgqEXM15InPXg0eDfFbjhhf1Q5uaqsrzgqLKqBSXoSjvkSXwS5dO1YKsiIwnALUhOlbsWM0yZkydAIUIVGKJJIA1CkaiPOmdOssOn2yh2yh2Kkf2yl28b0AzsjerRgTs3d0LajytASzfSXdbDU83u4OuJwbRB3XYadjDXxqBSXooYfpehra0GrnuvhS21aavlL25o3cqZTHJqx8f0MNbhjyEnhhHLNjgVNRyQViGohH1LtDfCKvWMpGwltkHiA1Ov6EGUeiHJCXdXry5zIX75kM6lcOZDUfOf3gocDXxqBEgCKG51CCeq5euHASkOMJW6YPUcoITydLzavscTLcGgmQHQ6G1UgaOAP0o2KgB(aATmPeIOvJwP7b6YMEI6GyJDytQuyJTyZkydLzavscTLcGgmQHQ6G1UgaOAP0o2KgB(aATmPeIOvJwP7b6YMEI6GydiyZ6SXM0yZhqRLjLqeTA0kDpqxcKGn2XrU4H4iGYjOc1yvqn35wKf3gocDXxqBEgCKG51CCeWUXvJwfhROZvAGophH1LtDfCe2mI9y9K0tYyLAvdCKYkfjZjB6jQdIn5GnOvUCKlEiocy34QrRIJv05knqNN7Claf52WrOl(cAZZGJemVMJJS0ZTavjD9ecvhlehH1LtDfCKg4iSbKxSb0ytASzfS5dO1YKsiIwnALUhOlbsWM0yJTyZkyZhqRL)MchLA0kyD7owgyibsWMuPWMvWgpe05YFtHJsnAfSUDhldmK0fFbTXg74ix8qCKLEUfOkPRNqO6yH4o3cqnUnCe6IVG28m4ix8qCKowDdCGbv)Ar10w9bCFoosW8AooshRUboWGQFTOAAR(aUph35waQ42WrOl(cAZZGJemVMJJ8qnbMJkGkDClCewxo1vWrwbB(aAT83u4OuJwbRB3XYadjqc2KgBwbB(aATmPeIOvJwP7b6sGeoYfpeh5HAcmhvav64w4o3Imb3gocDXxqBEgCewxo1vWr(aATmPeIOvJwP7b6sGeSjn28b0Aj9KmwPw1ahPSsrYCsGeosW8AoosY41CCNBX6C52WrOl(cAZZGJW6YPUcoYhqRLjLqeTA0kDpqxcKGnPXMpGwlPNKXk1Qg4iLvksMtcKWrcMxZXr(Iz2knqNN7ClwVMBdhHU4lOnpdocRlN6k4iFaTwMucr0QrR09aDjqchjyEnhh5tnKAWQBH7ClwNn3gocDXxqBEgCewxo1vWryZi2J1tspjJvQvnWrkRuKmNSPNOoihjyEnhhjPeIOvJwP7b6CNBXAqZTHJqx8f0MNbhH1LtDfCe2mI9y9K0tYyLAvdCKYkfjZjB6jQdInPXg2mI9y9KjLqeTA0kDpqx20tuhKJemVMJJ8BkCuQrRG1T7yzGbhbasQrRvlSnhzn35wSgT42WrOl(cAZZGJW6YPUcocBgXESEYKsiIwnALUhOlBk25XM0yZkyJhc6C5VPWrPgTcw3UJLbgs6IVG2ytASPbos61dP8rLf2Kd2SW2ytASPbUIPsgRul3KUyLJn58InRZfBsLcB86Hu(O2fHnGGnzNlhjyEnhhHEsgRuRAGJuwPizoUZTyDwCB4i0fFbT5zWryD5uxbhXwSHnJypwpzsjerRgTs3d0Lnf78ytQuyJxpKYh1UiSbeSj7CXg7WM0yJhc6C5VPWrPgTcw3UJLbgs6IVG2ytASPbUIPsgRuJn5GnGI5YrcMxZXrONKXk1Qg4iLvksMJ7ClwdkYTHJqx8f0MNbhH1LtDfCepe05s2i2kuu0UKU4lOn2KgBSfBSfB(aATKnITcffTlHEWadBY5fBwNl2KgB20hqRLDS60fJKqpyGHnVytwyJDytQuyJxpKYh1UiSbKxSzHTXg74ibZR54iSqiubZR5uIc6CerbD1fpehHnITcffTZDUfRb142WrOl(cAZZGJW6YPUcoITyZhqRLjLqeTA0kDpqx20tuheBa5fBwyBSjvkSXwS5dO1YKsiIwnALUhOlB6jQdInGGnGkSjn28b0AjWHAe5vqVPBXrjB6jQdInG8InlSn2KgB(aATe4qnI8kO30T4OKajyJDyJDytAS5dO1YKsiIwnALUhOlbsWM0ytSk1LtYILxXkp2Kq2Xbg2aYl2KnhjyEnhhr3d0TMVFGknqNN7ClwdQ42WrOl(cAZZGJW6YPUcoITyZhqRLflVIvESjHSPNOoi2aYl2SW2ytQuyJTyZhqRLflVIvESjHSPNOoi2ac2aQWM0yZhqRLahQrKxb9MUfhLSPNOoi2aYl2SW2ytAS5dO1sGd1iYRGEt3IJscKGn2Hn2HnPXMpGwllwEfR8ytcjqc2KgBIvPUCswS8kw5XMeYooWWMCWMS5ibZR54i6EGU189duPb68CNBX6mb3gocDXxqBEgCewxo1vWr86Hu(O2fHnGGnlSn2Kkf2yl241dP8rTlcBabByZi2J1tMucr0QrR09aDztprDqSjn28b0AjWHAe5vqVPBXrjbsWg74ibZR54i6EGU189duPb68CN7CNJGgQH1CClYo31zICbv5cAoI1OV6wGCeqzpjt70gBwNl2emVMdBef0Hsm4CeycX4wKDwR5ij9OlbXrYuSjZ1d0XgqPOWrHnzYVAbLJbptXguUNaZKS3(LYrb8LS5XEy9aicVMJ1H2Thwpm7XGNPytMpWca0XgqBj2KDURZeydOa2KjYKqRCXGJbptXgqjOIBHGzsyWZuSbuaBaLDmbWMWgqPRBJnzUMOvjjg8mfBafWMm)9gB0Hq8dgyyJEASbaw3c2aQlZBMhlXgq9tMdBkn2KiI8uJn1vEfobXMmgeS5t6PjSjzgrDlyJywkg2uqSHnpjcYPTedEMInGcydOeuXTqyJh9c5sVEiLpQDryJpyJxpKYh1UiSXhSbasydDSb4CQXgbDlokSPdhf1yJJkoSjzC68keyJ3bef2SPWrbLyWXGNPydOUmzigGtBS5t6PjSHnp)WXMpTuhuInz(mgL4qS5Mduav0pAab2emVMdInZjYlXGNPytW8AoOmPj288d)vlciyyWZuSjyEnhuM0eBE(HJ(R96z2yWZuSjyEnhuM0eBE(HJ(R9bWYdDE41CyWZuSb5IeiQXXMoQn28b0AAJnqpCi28j90e2WMNF4yZNwQdInXTXMKMafsg3RBbBki2SNJKyWZuSjyEnhuM0eBE(HJ(R9WlsGOgxb9WHyWdMxZbLjnXMNF4O)AFY41CyWdMxZbLjnXMNF4O)ApAIUIVGS8Ih6DCuuRMtbajfLzavscTTenHaGETLYmGkjH2YB8PRbaQweXUcFAO6h7fkvkkZaQKeAlH1vqNA1Ii2v4tdv)yVqPsrzgqLKqBjSUc6uRweXUcFAO6H2HquZLkfLzavscTLOPcHA0Q4QNWPT6lMzNkfLzavscTL6QHU6jCcQGj5xebeMkfLzavscTLGYjOc1yvqDQuuMbujj0wEJpDnaq1Ii2v4tdvp0oeIAo7WGJbptXgqDzYqmaN2ydHgQZJnE9qyJJIWMG5tJnfeBc0eLi(csIbpyEnh89PUTs3eTkHbptXMm)KerESjZ1d0XMmhHgQXM42yZtuNh1HnGYy5XgBcXCqm4bZR5GO)ApQXQOUf1xeq3Ys)UYECPUhOR0eAOw6fdS6wsB7kEiOZL)MchLA0kyD7owgyiPl(cANkfBgXESEYFtHJsnAfSUDhldmKn9e1bZzDw2HbpyEnhe9x7xebRcHk2OjogzzPF)aATSy5vEiMdkB6jQdcY7cBN(dO1YILx5HyoOeijnmHecLh9c5q5IiyviuXgnXXOCEZoTTR4HGox(BkCuQrRG1T7yzGHKU4lODQuSze7X6j)nfok1OvW62DSmWq20tuhmN1zzhg8G51Cq0FTx3d0vqVlWill97hqRLflVYdXCqztprDqqExy70FaTwwS8kpeZbLajPTDfpe05YFtHJsnAfSUDhldmK0fFbTtLInJypwp5VPWrPgTcw3UJLbgYMEI6G5Sol7WGhmVMdI(R9SqiubZR5uIc6wEXd9sqiDmcIbpyEnhe9x7zHqOcMxZPef0T8Ih6LnJypwpig8G51Cq0FTVbovW8AoLOGULx8qV)bQsMru3ILL(1dbDU83u4OuJwbRB3XYadjDXxq702AlBgXESEYFtHJsnAfSUDhldmKn9e1bFZnnBgXESEYKsiIwnALUhOlB6jQdcY6CTlvkBzZi2J1t(BkCuQrRG1T7yzGHSPNOoiizNBAVEiLpQDrGa6SSZom4bZR5GO)AFdCQG51CkrbDlV4HE)du5fdS6wSS0VFaTw(BkCuQrRG1T7yzGHeibdEW8Aoi6V23aNkyEnNsuq3YlEO35lkN6WR5SS0VFaTwMucr0QrR09aDjqsApe05Y5lkN6WR5K0fFbTXGhmVMdI(R9nWPcMxZPef0T8Ih6ngYYs)gmVqdPOJEkcMZB2yWdMxZbr)1EwieQG51CkrbDlV4HEHEC7O3yWXGhmVMdkJHEB6zAijiiuzToNAll9Rhc6C5s4OOUUff0N(rsx8f0ovkBJvPUCsQ7zv6uo9Kqqx2XbwAycjekp6fYHYMEMgscccvwRZPoNxqNELpGwl76HKaj2HbpyEnhugdH(R9lIGvHqfB0ehJSS0VEiOZL6EGoKL3rrs6IVG2yWdMxZbLXqO)AVUhORGExGrwYYZeKYJEHC47All9RTB6dO1YowD6IrsOhmWajRuP20hqRLDS60fJKn9e1bbzDU2LMnJypwpztptdjbbHkR15ulB6jQdcYB2O9cBN2dbDUCjCuux3Ic6t)iPl(cANEfpe05sDpqhYY7OijDXxqBm4bZR5GYyi0FTx3d0vqVlWill9lBgXESEYMEMgscccvwRZPw20tuheK3Sr7f2oThc6C5s4OOUUff0N(rsx8f0gdEW8AoOmgc9x7rnwf1TO(Ia6ww63pGwl76HKajyWdMxZbLXqO)AVUhOdz5DuKLL(9dO1sWkHOUf1tWqvhjbsWGhmVMdkJHq)1(frWQqOInAIJrww63g4kMkzSsTCt6Ivoi2Uol09qqNlBGRyQWD6acVMtsx8f0gTbTDyWdMxZbLXqO)AVUhORGExGrwYYZeKYJEHC47All9RTB6dO1YowD6IrsOhmWajRuP20hqRLDS60fJKn9e1bbzDU2LUbUIPsgRul3KUyLdITRZcDpe05Yg4kMkCNoGWR5K0fFbTrBqBx6v8qqNl19aDilVJIK0fFbTXGhmVMdkJHq)1EDpqxb9UaJSS0VnWvmvYyLA5M0fRCqSDDwO7HGox2axXuH70beEnNKU4lOnAdA7sVIhc6CPUhOdz5DuKKU4lOng8G51Cqzme6V230Z0qsqqOYADo1yWdMxZbLXqO)AVUhOdz5Dueg8G51Cqzme6V2pFr5uhozjlptqkp6fYHVRTS0V2UPpGwl7y1PlgjHEWadKSsLAtFaTw2XQtxms20tuheK15Ax6g4kMkzSsTCt6IvEo2MDwO7HGox2axXuH70beEnNKU4lOnAdA7sVIhc6CPUhOdz5DuKKU4lOng8G51Cqzme6V2pFr5uhozzPFBGRyQKXk1YnPlw55yB2zHUhc6CzdCftfUthq41Cs6IVG2OnOTddEW8AoOmgc9x7xebRcHk2OjogHbpyEnhugdH(R96EGUc6Dbgzjlptqkp6fYHVRTS0V2UPpGwl7y1PlgjHEWadKSsLAtFaTw2XQtxms20tuheK15Ax6v8qqNl19aDilVJIK0fFbTXGhmVMdkJHq)1EDpqxb9UaJWGhmVMdkJHq)1EutFQrRSwNtng8G51Cqzme6V2hnlos5t305yWXGNPytgnfokSz0ydsD7owgyGnjZiQBbB6XdVMdBYKWgOhTdXMSZfInFspnHnG6lHiASz0ytMRhOJnOJnzmiyt0e2eOjkr8feg8G51Cq5FGQKze1T8IASkQBr9fb0TS0VFaTw21djbsWGhmVMdk)duLmJOUf0FTF(IYPoCYswEMGuE0lKdFxBzPFTDtFaTw2XQtxmsc9GbgizLk1M(aATSJvNUyKSPNOoiiRZ1U0nWvmvYyLA5M0fR8CEZoR0R4HGoxQ7b6qwEhfjPl(cAJbpyEnhu(hOkzgrDlO)A)8fLtD4KLL(TbUIPsgRul3KUyLNZB2zHbpyEnhu(hOkzgrDlO)A)IiyviuXgnXXill9BdCftLmwPwUjDXkhKSZnnmHecLh9c5q5IiyviuXgnXXOCEZonBgXESEYKsiIwnALUhOlB6jQdMtwyWdMxZbL)bQsMru3c6V2R7b6kO3fyKLS8mbP8Oxih(U2Ys)A7M(aATSJvNUyKe6bdmqYkvQn9b0AzhRoDXiztprDqqwNRDPBGRyQKXk1YnPlw5GKDUPxXdbDUu3d0HS8okssx8f0onBgXESEYKsiIwnALUhOlB6jQdMtwyWdMxZbL)bQsMru3c6V2R7b6kO3fyKLL(TbUIPsgRul3KUyLds25MMnJypwpzsjerRgTs3d0Ln9e1bZjlm4bZR5GY)avjZiQBb9x719aDilVJISS0VFaTwcwje1TOEcgQ6ijqs6g4kMkzSsTCt6IvEo2Uol09qqNlBGRyQWD6acVMtsx8f0gTbTDPHjKqO8Oxihk19aDilVJIY5nBm4bZR5GY)avjZiQBb9x719aDilVJISS0VnWvmvYyLA5M0fR8CETf0zHUhc6CzdCftfUthq41Cs6IVG2OnOTlnmHecLh9c5qPUhOdz5DuuoVzJbpyEnhu(hOkzgrDlO)A)8fLtD4KLS8mbP8Oxih(U2Ys)A7M(aATSJvNUyKe6bdmqYkvQn9b0AzhRoDXiztprDqqwNRDPBGRyQKXk1YnPlw558AlOZcDpe05Yg4kMkCNoGWR5K0fFbTrBqBx6v8qqNl19aDilVJIK0fFbTXGhmVMdk)duLmJOUf0FTF(IYPoCYYs)2axXujJvQLBsxSYZ51wqNf6EiOZLnWvmv4oDaHxZjPl(cAJ2G2om4bZR5GY)avjZiQBb9x7xebRcHk2OjogzzPFzZi2J1tMucr0QrR09aDztprDWCAGJKE9qkFuOv6g4kMkzSsTCt6IvoiOvUPHjKqO8OxihkxebRcHk2OjogLZB2yWdMxZbL)bQsMru3c6V2R7b6kO3fyKLS8mbP8Oxih(U2Ys)A7M(aATSJvNUyKe6bdmqYkvQn9b0AzhRoDXiztprDqqwNRDPzZi2J1tMucr0QrR09aDztprDWCAGJKE9qkFuOv6g4kMkzSsTCt6IvoiOvUPxXdbDUu3d0HS8okssx8f0gdEW8AoO8pqvYmI6wq)1EDpqxb9UaJSS0VSze7X6jtkHiA1Ov6EGUSPNOoyonWrsVEiLpk0kDdCftLmwPwUjDXkhe0kxm4yWZuSjZfcXpyGHn(GnaqcBa1pzolXgqDzEZ8Gnwrrh2aaPguOUYRWji2KXGGnjn9eoqtI8sm4bZR5GY)avEXaRUL3KsiIwnALUhOBzPFzZi2J1tspjJvQvnWrkRuKmNSPNOoig8G51Cq5FGkVyGv3c6V2tpjJvQvnWrkRuKmhg8G51Cq5FGkVyGv3c6V2pFr5uhozjlptqkp6fYHVRTS0V2UPpGwl7y1PlgjHEWadKSsLAtFaTw2XQtxms20tuheK15Ax6g4kMkzSsniVGo30R4HGoxQ7b6qwEhfjPl(cAJbpyEnhu(hOYlgy1TG(R9Zxuo1Htww63g4kMkzSsniVGoBm4bZR5GY)avEXaRUf0FTVPNPHKGGqL16CQTS0VEiOZLlHJI66wuqF6hjDXxqBm4bZR5GY)avEXaRUf0FTh1yvu3I6lcOBzPF)aATSRhscKGbpyEnhu(hOYlgy1TG(R9Zxuo1HtwYYZeKYJEHC47All9RTB6dO1YowD6IrsOhmWajRuP20hqRLDS60fJKn9e1bbzDU2LUbos61dP8rLfilSDQunWvmvYyLAqErRSsVIhc6CPUhOdz5DuKKU4lOng8G51Cq5FGkVyGv3c6V2pFr5uhozzPFBGJKE9qkFuzbYcBNkvdCftLmwPgKx0klm4bZR5GY)avEXaRUf0FTx3d0HS8okYYs)(b0AjyLqu3I6jyOQJKajPHjKqO8Oxihk19aDilVJIY5nBm4bZR5GY)avEXaRUf0FTh10NA0kR15uBzPFBGRyQKXk1YnPlw558c6St3ahj96Hu(OaDolSng8G51Cq5FGkVyGv3c6V230Z0qsqqOYADo1yWdMxZbL)bQ8IbwDlO)AVUhOdz5DuKLL(fMqcHYJEHCOu3d0HS8okkN3SXGhmVMdk)du5fdS6wq)1(5lkN6Wjlz5zcs5rVqo8DTLL(12n9b0AzhRoDXij0dgyGKvQuB6dO1YowD6IrYMEI6GGSox7s3axXujJvQLBsxSYZj7SsLQbokhqNEfpe05sDpqhYY7OijDXxqBm4bZR5GY)avEXaRUf0FTF(IYPoCYYs)2axXujJvQLBsxSYZj7SsLQbokhqJbpyEnhu(hOYlgy1TG(R9rZIJu(0nDULL(TbUIPsgRul3KUyLNt25IbhdEMInGsgXgBqrr7ydBUD51Cqm4bZR5Gs2i2kuu0(ldvuhunAvXill97hqRLSrSvOOODj0dgy5KvAVEiLpQDrGSW2yWdMxZbLSrSvOOOD0FTNHkQdQgTQyKLL(12pGwltkHiA1Ov6EGUSPNOoiiVlSnAB7A0zZi2J1tQ7b6wZ3pqLgOZlBk25TlvQpGwltkHiA1Ov6EGUSPNOoiinWrsVEiLpkqBx6pGwltkHiA1Ov6EGUeijDSk1LtYILxXkp2Kq2XbgiVzJbpyEnhuYgXwHII2r)1EgQOoOA0QIrww63pGwltkHiA1Ov6EGUSPNOoiiGQ0FaTwcCOgrEf0B6wCuYMEI6GGSW2OTTRrNnJypwpPUhOBnF)avAGoVSPyN3U0FaTwcCOgrEf0B6wCuYMEI6GP)aATmPeIOvJwP7b6sGK0XQuxojlwEfR8ytczhhyG8Mng8G51CqjBeBfkkAh9x7zOI6GQrRkgzzPFT9dO1YILxXkp2Kq20tuhee0kvQpGwllwEfR8ytcztprDqqAGJKE9qkFuG2U0FaTwwS8kw5XMesGK0XQuxojlwEfR8ytczhhy5Kng8G51CqjBeBfkkAh9x7zOI6GQrRkgzzPF)aATSy5vSYJnjKajP)aATe4qnI8kO30T4OKajPJvPUCswS8kw5XMeYooWYjBm4yWdMxZbLSze7X6bFbGKQC6XYlEO3yviQOdOspNRgTkzSsTLL(1w2mI9y9K0tYyLAvdCKYkfjZjBk25tVcAIUIVGKJJIA1CkaiPOmdOssOTDPszlBgXESEYKsiIwnALUhOlB6jQdcY76CtJMOR4li54OOwnNcaskkZaQKeABhg8G51CqjBgXESEq0FThasQYPhlV4HEfanyudv1bRDnaq1sPDll9Rhc6C5VPWrPgTcw3UJLbgs6IVG2PT1w2mI9y9KjLqeTA0kDpqx20tuheK315MgnrxXxqYXrrTAofaKuuMbujj02UuPS9dO1YKsiIwnALUhOlbssVcAIUIVGKJJIA1CkaiPOmdOssOTD2LkLTFaTwMucr0QrR09aDjqs6v8qqNl)nfok1OvW62DSmWqsx8f02om4bZR5Gs2mI9y9GO)ApaKuLtpwEXd9YYZeJ3Zvm1xeq3Ys)UYhqRLjLqeTA0kDpqxcKGbpyEnhuYMrShRhe9x7bGKQC6XYlEOxq5euHASkO2Ys)AlLzavscTLcGgmQHQ6G1UgaOAP0E6pGwltkHiA1Ov6EGUSPNOoODPsz7kuMbujj0wkaAWOgQQdw7AaGQLs7P)aATmPeIOvJwP7b6YMEI6GGSo70FaTwMucr0QrR09aDjqIDyWdMxZbLSze7X6br)1EaiPkNES8Ih6fSBC1OvXXk6CLgOZBzPFzZi2J1tspjJvQvnWrkRuKmNSPNOoyoOvUyWdMxZbLSze7X6br)1EaiPkNES8Ih6DPNBbQs66jeQowill9BdCeiVGo9kFaTwMucr0QrR09aDjqsABx5dO1YFtHJsnAfSUDhldmKajPsTIhc6C5VPWrPgTcw3UJLbgs6IVG22HbpyEnhuYMrShRhe9x7bGKQC6XYlEO3owDdCGbv)Ar10w9bCFom4bZR5Gs2mI9y9GO)ApaKuLtpwEXd9(qnbMJkGkDClww63v(aAT83u4OuJwbRB3XYadjqs6v(aATmPeIOvJwP7b6sGem4bZR5Gs2mI9y9GO)AFY41Cww63pGwltkHiA1Ov6EGUeij9hqRL0tYyLAvdCKYkfjZjbsWGhmVMdkzZi2J1dI(R9FXmBLgOZBzPF)aATmPeIOvJwP7b6sGK0FaTwspjJvQvnWrkRuKmNeibdEW8AoOKnJypwpi6V2)Pgsny1TyzPF)aATmPeIOvJwP7b6sGem4zk2K56b6ydBgXESEqm4bZR5Gs2mI9y9GO)AFsjerRgTs3d0TS0VSze7X6jPNKXk1Qg4iLvksMt20tuhedEW8AoOKnJypwpi6V2)BkCuQrRG1T7yzGHLaqsnATAHTFxBzPFzZi2J1tspjJvQvnWrkRuKmNSPNOoyA2mI9y9KjLqeTA0kDpqx20tuhedEW8AoOKnJypwpi6V2tpjJvQvnWrkRuKmNLL(LnJypwpzsjerRgTs3d0Lnf78PxXdbDU83u4OuJwbRB3XYadjDXxq70nWrsVEiLpQSYzHTt3axXujJvQLBsxSYZ5DDUPs51dP8rTlcKSZfdEW8AoOKnJypwpi6V2tpjJvQvnWrkRuKmNLL(1w2mI9y9KjLqeTA0kDpqx2uSZNkLxpKYh1UiqYox7s7HGox(BkCuQrRG1T7yzGHKU4lOD6g4kMkzSsDoGI5IbpyEnhuYMrShRhe9x7zHqOcMxZPef0T8Ih6LnITcffTBzPF9qqNlzJyRqrr7s6IVG2PT12pGwlzJyRqrr7sOhmWY5DDUP30hqRLDS60fJKqpyG9MLDPs51dP8rTlcK3f22om4bZR5Gs2mI9y9GO)AVUhOBnF)avAGoVLL(12pGwltkHiA1Ov6EGUSPNOoiiVlSDQu2(b0AzsjerRgTs3d0Ln9e1bbbuL(dO1sGd1iYRGEt3IJs20tuheK3f2o9hqRLahQrKxb9MUfhLeiXo7s)b0AzsjerRgTs3d0LajPJvPUCswS8kw5XMeYooWa5nBm4bZR5Gs2mI9y9GO)AVUhOBnF)avAGoVLL(12pGwllwEfR8ytcztprDqqExy7uPS9dO1YILxXkp2Kq20tuheeqv6pGwlbouJiVc6nDlokztprDqqExy70FaTwcCOgrEf0B6wCusGe7Sl9hqRLflVIvESjHeijDSk1LtYILxXkp2Kq2XbwozJbpyEnhuYMrShRhe9x719aDR57hOsd05TS0VE9qkFu7IazHTtLYwVEiLpQDrGWMrShRNmPeIOvJwP7b6YMEI6GP)aATe4qnI8kO30T4OKaj2HbhdEW8AoOKGq6ye89lMzRgTYrrk6ON8ww63pGwltkHiA1Ov6EGUSPNOoiiRZnnBgXESEYFtHJsnAfSUDhldmKn9e1btL6dO1YKsiIwnALUhOlB6jQdcY6CtVIhc6C5VPWrPgTcw3UJLbgs6IVG2yWdMxZbLeeshJGO)A)cq07ko1OvXQupokm4bZR5GsccPJrq0FTNHQecf0BkaZYs)(b0AzsjerRgTs3d0Ln9e1bbjRuP86Hu(O2fbswyWdMxZbLeeshJGO)AVJIua3FaUTspnJSS0VFaTw2edmbbHk90mscKKk1hqRLnXatqqOspnJuSb4CQLqpyGbY61yWdMxZbLeeshJGO)AVEyaqARIvPUCs9P4XYs)UYhqRLjLqeTA0kDpqxcKKELpGwl)nfok1OvW62DSmWqcKGbpyEnhusqiDmcI(R9S5y05D40wPfXdzzPFx5dO1YKsiIwnALUhOlbssVYhqRL)MchLA0kyD7owgyibssVhxYMJrN3HtBLwepK6d0NSPNOo4BUyWdMxZbLeeshJGO)AFcqx681TO(Ia6ww63v(aATmPeIOvJwP7b6sGK0R8b0A5VPWrPgTcw3UJLbgsGem4bZR5GsccPJrq0FT360InAO6unbNlogzzPFx5dO1YKsiIwnALUhOlbssVYhqRL)MchLA0kyD7owgyibsWGhmVMdkjiKogbr)1(UsseKQofmjyKLL(DLpGwltkHiA1Ov6EGUeij9kFaTw(BkCuQrRG1T7yzGHeibdEW8AoOKGq6yee9x7FONPZRgTsaWQTA3u8aTS0VFaTwspjJvQvnWrkRuKmNSPNOoiizL(dO1YFtHJsnAfSUDhldmKajPszBdCK0Rhs5Jk7Cwy70nWvmvYyLAqYkx7WGJbptXMmz)IYPo8AoSPhp8Aom4bZR5GY5lkN6WR5EB6zAijiiuzToNAll9Rhc6C5s4OOUUff0N(rsx8f0gdEW8AoOC(IYPo8Ao0FTF(IYPoCYswEMGuE0lKdFxBzPFTDtFaTw2XQtxmsc9GbgizLk1M(aATSJvNUyKSPNOoiiRZ1U0R4HGoxQ7b6qwEhfjPl(cANELpGwl76HKajPHjKqO8Oxihkrnwf1TO(Ia658cAm4bZR5GY5lkN6WR5q)1(5lkN6Wjll97kEiOZL6EGoKL3rrs6IVG2Px5dO1YUEijqsAycjekp6fYHsuJvrDlQViGEoVGgdEW8AoOC(IYPo8Ao0FTx3d0HS8okYYs)A7hqRLGvcrDlQNGHQos2uW8uPS9dO1sWkHOUf1tWqvhjbssBBstOrTW2Y1sDpqxb9UaJsLkPj0OwyB5AjQXQOUf1xeqpvQKMqJAHTLRLlIGvHqfB0ehJSZo7sdtiHq5rVqouQ7b6qwEhfLZB2yWdMxZbLZxuo1HxZH(R9Zxuo1HtwYYZeKYJEHC47All9RTB6dO1YowD6IrsOhmWajRuP20hqRLDS60fJKn9e1bbzDU2L(dO1sWkHOUf1tWqvhjBkyEQu2(b0AjyLqu3I6jyOQJKajPTnPj0OwyB5APUhORGExGrPsL0eAulSTCTe1yvu3I6lcONkvstOrTW2Y1YfrWQqOInAIJr2zhg8G51Cq58fLtD41CO)A)8fLtD4KLL(9dO1sWkHOUf1tWqvhjBkyEQu2(b0AjyLqu3I6jyOQJKajPTnPj0OwyB5APUhORGExGrPsL0eAulSTCTe1yvu3I6lcONkvstOrTW2Y1YfrWQqOInAIJr2zhg8G51Cq58fLtD41CO)A)IiyviuXgnXXill9RTR8b0AzxpKeijvQg4kMkzSsTCt6IvoiRZnvQg4iPxpKYhv25SW22LgMqcHYJEHCOCreSkeQyJM4yuoVzJbpyEnhuoFr5uhEnh6V2JASkQBr9fb0TS0VFaTw21djbssdtiHq5rVqouIASkQBr9fb0Z5nBm4bZR5GY5lkN6WR5q)1EDpqxb9UaJSKLNjiLh9c5W31ww6xB30hqRLDS60fJKqpyGbswPsTPpGwl7y1PlgjB6jQdcY6CTl9kFaTw21djbssLQbUIPsgRul3KUyLdY6CtLQbos61dP8rLDolSD6v8qqNl19aDilVJIK0fFbTXGhmVMdkNVOCQdVMd9x719aDf07cmYYs)UYhqRLD9qsGKuPAGRyQKXk1YnPlw5GSo3uPAGJKE9qkFuzNZcBJbpyEnhuoFr5uhEnh6V2JASkQBr9fb0TS0VFaTw21djbsWGhmVMdkNVOCQdVMd9x7NVOCQdNSKLNjiLh9c5W31ww6xB30hqRLDS60fJKqpyGbswPsTPpGwl7y1PlgjB6jQdcY6CTl9kEiOZL6EGoKL3rrs6IVG2yWdMxZbLZxuo1HxZH(R9Zxuo1HtyWXGNPydIh3o6n2aRBrqGcE0lKJn94HxZHbpyEnhuc942rVFB6zAijiiuzToNAm4bZR5GsOh3o6n6V2R7b6kO3fyKLL(LnJypwpztptdjbbHkR15ulB6jQdcYB2O9cBN2dbDUCjCuux3Ic6t)iPl(cAJbpyEnhuc942rVr)1EuJvrDlQViGULL(9dO1YUEijqcg8G51Cqj0JBh9g9x7NVOCQdNSS0VR8b0APUNvPtLaiGKeijThc6CPUNvPtLaiGKKU4lOng8G51Cqj0JBh9g9x719aDf07cmYYs)2axXujJvQLBsxSYbX21zHUhc6CzdCftfUthq41Cs6IVG2OnOTddEW8AoOe6XTJEJ(R96EGoKL3rrww63pGwlbReI6wupbdvDKeijDdCK0Rhs5JcTY5DHTXGhmVMdkHEC7O3O)A)8fLtD4KLL(TbUIPsgRul3KUyLNJTzNf6EiOZLnWvmv4oDaHxZjPl(cAJ2G2om4bZR5GsOh3o6n6V2R7b6kO3fyeg8G51Cqj0JBh9g9x7rn9PgTYADo1yWdMxZbLqpUD0B0FTpAwCKYNUPZ5o35C]] )


end
