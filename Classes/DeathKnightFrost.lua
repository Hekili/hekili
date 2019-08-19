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


    spec:RegisterPack( "Frost DK", 20190818.1250, [[dG00acqirv9irrztIuJIIQtjsSkrr6vuGzrbDlvPGDrYVejnmrvoMQWYeL6zuinnkeUMOITPkf6BQsjnovPOZjkcRtuezEQsUhq2NOshuuuvluu4HQsjmrvPe5IQsP0gffvoPQukwjq5LIIO6MIIOyNuO(POiknuvPu1sffvPNcXuPO8vrrvSxc)fvdMshwyXaEmktwjxgzZK6ZkvJgsoTKvRkLkVgOA2eDBLYUv53kgUioofIwUuph00P66QQTRkvFhsnEvPe15vfTErjZNISFOw8qyMazfojmo78EKjY7nF8MQhzNZJ8ERce)zcjqscg4XojqUyJeizUEGo2(wktUajjEkNyjmtGaNFZibck3tGzsPM6E5O(ak2SLkS2(YWR5yDO9uH1glvbcWVK(BZjaeiRWjHXzN3JmrEV5J3uGeFh10ceKA7TqGGQwl6eacKfbzcKmdBZC9aDS9TefokSnt(v7OCmyzg2IY9eyMuQPUxoQpGInBPcRTVm8AowhApvyTXsfdwMHTz()9p0X2hVPHyB259itGTVbS9r2zsgrEyWWGLzy7BbQ42jyMegSmdBFdy7BZXK)fHTzYu3cBZCnrzrkmyzg2(gW2m)1cB1HucemWXw90y7hw3o2(2M5nZJHy7B)K5W2sJTjY4j1yBDLxHtqSnJbbBbi90e2MmJSUDSvo7fdBli2YMTej50sHblZW23a2(wGkUDcB9O3jx51gX9HVkcB9bB9AJ4(WxfHT(GTFiHT0XM)5uJTs62DuyBhokQXwhvCyBY405viXwVdikSDrHJcQeiYc6qHzce2ixCuu0UWmHXpeMjqOlaK0sKHaH1LtDfceGVwRyJCXrrr7kOhmWX2CX2CW20yRxBe3h(QiS9f2UZwcKG51CcegQOoiF08IrcxyC2cZei0fasAjYqGW6YPUcbI5ylWxRvjLugnF0CDpqx10wuheBFbcB3zlSntXwZX2hyRbylBg5AqFkDpqh9ZEdY1)(PQPy9eBtbBnzcBb(ATkPKYO5JMR7b6QM2I6Gy7lST)hP8AJ4(Wnk2Mc2MgBb(ATkPKYO5JMR7b6QFc2MgBJSOUCsvSNCw5XIKQooWX2xGW2SfibZR5eimurDq(O5fJeUWyJkmtGqxaiPLidbcRlN6keiaFTwLusz08rZ19aDvtBrDqS9f2(MyBASf4R1Q)HAKp5qVPB3rPAAlQdITVW2D2cBZuS1CS9b2Aa2YMrUg0Ns3d0r)S3GC9VFQAkwpX2uW20ylWxRv)d1iFYHEt3UJs10wuheBtJTaFTwLusz08rZ19aD1pbBtJTrwuxoPk2toR8yrsvhh4y7lqyB2cKG51CcegQOoiF08IrcxySrimtGqxaiPLidbcRlN6keiMJTaFTwvSNCw5XIKQM2I6Gy7lS1iWwtMWwGVwRk2toR8yrsvtBrDqS9f22)JuETrCF4gfBtbBtJTaFTwvSNCw5XIKQFc2MgBJSOUCsvSNCw5XIKQooWX2CX2SfibZR5eimurDq(O5fJeUW4CeMjqOlaK0sKHaH1LtDfceGVwRk2toR8yrs1pbBtJTaFTw9puJ8jh6nD7ok1pbBtJTrwuxoPk2toR8yrsvhh4yBUyB2cKG51CcegQOoiF08Ircx4cKbqwo1HxZjmty8dHzce6cajTeziqyD5uxHaXdjDUApCuux3oh6tVPOlaK0sGemVMtG0020qssqihDDo1cxyC2cZei0fasAjYqGW6YPUcbI5y7Ia(ATQJSMUyKc6bdCS9f2Md2AYe2UiGVwR6iRPlgPAAlQdITVW2h5HTPGTPX28XwpK05kDpqhYE6OifDbGKwyBASnFSf4R1QU2i1pbBtJTWesk5E07KdvOg0Y625aYa6yBUGWwJkqcMxZjqgaz5uhojqypzsI7rVtouy8dHlm2OcZei0fasAjYqGW6YPUcbs(yRhs6CLUhOdzpDuKIUaqslSnn2Mp2c81AvxBK6NGTPXwycjLCp6DYHkudAzD7CazaDSnxqyRrfibZR5eidGSCQdNeUWyJqyMaHUaqslrgcewxo1viqmhBb(ATc8skRBNVfmu1rQMcMJTMmHTMJTaFTwbEjL1TZ3cgQ6i1pbBtJTMJTjn9oFNTupu6EGoh6DboHTMmHTjn9oFNTupuOg0Y625aYa6yRjtyBstVZ3zl1d1Umyvi5X694ye2Mc2Mc2Mc2MgBHjKuY9O3jhQ09aDi7PJIW2CbHTzlqcMxZjq09aDi7PJIeUW4CeMjqOlaK0sKHaH1LtDfceZX2fb81AvhznDXif0dg4y7lSnhS1KjSDraFTw1rwtxms10wuheBFHTpYdBtbBtJTaFTwbEjL1TZ3cgQ6ivtbZXwtMWwZXwGVwRaVKY625BbdvDK6NGTPXwZX2KMENVZwQhkDpqNd9UaNWwtMW2KMENVZwQhkudAzD7CazaDS1KjSnPP357SL6HAxgSkK8y9ECmcBtbBtrGemVMtGmaYYPoCsGWEYKe3JENCOW4hcxy8BuyMaHUaqslrgcewxo1viqa(ATc8skRBNVfmu1rQMcMJTMmHTMJTaFTwbEjL1TZ3cgQ6i1pbBtJTMJTjn9oFNTupu6EGoh6DboHTMmHTjn9oFNTupuOg0Y625aYa6yRjtyBstVZ3zl1d1Umyvi5X694ye2Mc2MIajyEnNazaKLtD4KWfg)wfMjqOlaK0sKHaH1LtDfceZX28XwGVwR6AJu)eS1KjST)xX4jdAQvlsxSYX2xy7J8WwtMW2(FKYRnI7dpBSnxSDNTW2uW20ylmHKsUh9o5q1Umyvi5X694ye2MliSnBbsW8AobYUmyvi5X694yKWfg)McZei0fasAjYqGW6YPUcbcWxRvDTrQFc2MgBHjKuY9O3jhQqnOL1TZbKb0X2CbHTzlqcMxZjqqnOL1TZbKb0fUW4mHWmbcDbGKwImeiSUCQRqGyo2UiGVwR6iRPlgPGEWahBFHT5GTMmHTlc4R1QoYA6IrQM2I6Gy7lS9rEyBkyBASnFSf4R1QU2i1pbBnzcB7)vmEYGMA1I0fRCS9f2(ipS1KjST)hP8AJ4(WZgBZfB3zlSnn2Mp26HKoxP7b6q2thfPOlaK0sGemVMtGO7b6CO3f4KaH9KjjUh9o5qHXpeUW4h5jmtGqxaiPLidbcRlN6kei5JTaFTw11gP(jyRjtyB)VIXtg0uRwKUyLJTVW2h5HTMmHT9)iLxBe3hE2yBUy7oBjqcMxZjq09aDo07cCs4cJF8qyMaHUaqslrgcewxo1viqa(ATQRns9teibZR5eiOg0Y625aYa6cxy8JSfMjqOlaK0sKHaH1LtDfceZX2fb81AvhznDXif0dg4y7lSnhS1KjSDraFTw1rwtxms10wuheBFHTpYdBtbBtJT5JTEiPZv6EGoK90rrk6cajTeibZR5eidGSCQdNeiSNmjX9O3jhkm(HWfg)WOcZeibZR5eidGSCQdNei0fasAjYq4cxGamqUxmWRBxyMW4hcZei0fasAjYqGW6YPUcbcBg5AqFkAlzqtnV)hXrtrYCQM2I6GcKG51CcKKskJMpAUUhOlCHXzlmtGemVMtGqBjdAQ59)ioAksMtGqxaiPLidHlm2OcZei0fasAjYqGW6YPUcbI5y7Ia(ATQJSMUyKc6bdCS9f2Md2AYe2UiGVwR6iRPlgPAAlQdITVW2h5HTPGTPX2(FfJNmOPgBFbcBnAEyBASnFS1djDUs3d0HSNoksrxaiPLajyEnNazaKLtD4KaH9KjjUh9o5qHXpeUWyJqyMaHUaqslrgcewxo1viq6)vmEYGMAS9fiS1OzlqcMxZjqgaz5uhojCHX5imtGqxaiPLidbcRlN6keiEiPZv7HJI6625qF6nfDbGKwcKG51CcKM2Mgsscc5ORZPw4cJFJcZei0fasAjYqGW6YPUcbcWxRvDTrQFIajyEnNab1Gww3ohqgqx4cJFRcZei0fasAjYqGW6YPUcbI5y7Ia(ATQJSMUyKc6bdCS9f2Md2AYe2UiGVwR6iRPlgPAAlQdITVW2h5HTPGTPX2(FKYRnI7dphS9f2UZwyRjtyB)VIXtg0uJTVaHTgroyBASnFS1djDUs3d0HSNoksrxaiPLajyEnNazaKLtD4KaH9KjjUh9o5qHXpeUW43uyMaHUaqslrgcewxo1viq6)rkV2iUp8CW2xy7oBHTMmHT9)kgpzqtn2(ce2Ae5iqcMxZjqgaz5uhojCHXzcHzce6cajTeziqyD5uxHab4R1kWlPSUD(wWqvhP(jyBASfMqsj3JENCOs3d0HSNokcBZfe2MTajyEnNar3d0HSNoks4cJFKNWmbcDbGKwImeiSUCQRqG0)Ry8Kbn1QfPlw5yBUGWwJMn2MgB7)rkV2iUpCJIT5IT7SLajyEnNab10hF0C015ulCHXpEimtGemVMtG0020qssqihDDo1ce6cajTeziCHXpYwyMaHUaqslrgcewxo1viqGjKuY9O3jhQ09aDi7PJIW2CbHTzlqcMxZjq09aDi7PJIeUW4hgvyMaHUaqslrgcewxo1viqmhBxeWxRvDK10fJuqpyGJTVW2CWwtMW2fb81AvhznDXivtBrDqS9f2(ipSnfSnn22)Ry8Kbn1QfPlw5yBUyB25GTMmHT9)iSnxS1OyBASnFS1djDUs3d0HSNoksrxaiPLajyEnNazaKLtD4KaH9KjjUh9o5qHXpeUW4hgHWmbcDbGKwImeiSUCQRqG0)Ry8Kbn1QfPlw5yBUyB25GTMmHT9)iSnxS1OcKG51CcKbqwo1Htcxy8JCeMjqOlaK0sKHaH1LtDfcK(FfJNmOPwTiDXkhBZfBZopbsW8Aobs0S4iUpDtNlCHlqIHeMjm(HWmbcDbGKwImeiSUCQRqG4HKoxThokQRBNd9P3u0fasAHTMmHTMJTrwuxoP09KfDCN2siOR64ahBtJTWesk5E07KdvnTnnKKeeYrxNtn2MliS1OyBASnFSf4R1QU2i1pbBtrGemVMtG0020qssqihDDo1cxyC2cZei0fasAjYqGW6YPUcbIhs6CLUhOdzpDuKIUaqslbsW8AobYUmyvi5X694yKWfgBuHzce6cajTeziqyD5uxHaXCSDraFTw1rwtxmsb9Gbo2(cBZbBnzcBxeWxRvDK10fJunTf1bX2xy7J8W2uW20ylBg5AqFQM2Mgsscc5ORZPw10wuheBFbcBZgBZuSDNTW20yRhs6C1E4OOUUDo0NEtrxaiPf2MgBZhB9qsNR09aDi7PJIu0fasAjqcMxZjq09aDo07cCsGWEYKe3JENCOW4hcxySrimtGqxaiPLidbcRlN6keiSzKRb9PAABAijjiKJUoNAvtBrDqS9fiSnBSntX2D2cBtJTEiPZv7HJI6625qF6nfDbGKwcKG51CceDpqNd9UaNeUW4CeMjqOlaK0sKHaH1LtDfceGVwR6AJu)ebsW8AobcQbTSUDoGmGUWfg)gfMjqOlaK0sKHaH1LtDfceGVwRaVKY625BbdvDK6NiqcMxZjq09aDi7PJIeUW43QWmbcDbGKwImeiSUCQRqG0)Ry8Kbn1QfPlw5y7lS1CS9royRbyRhs6Cv)VIXd3P7hEnNIUaqslSntXwJITPiqcMxZjq2LbRcjpwVhhJeUW43uyMaHUaqslrgcewxo1viqmhBxeWxRvDK10fJuqpyGJTVW2CWwtMW2fb81AvhznDXivtBrDqS9f2(ipSnfSnn22)Ry8Kbn1QfPlw5y7lS1CS9royRbyRhs6Cv)VIXd3P7hEnNIUaqslSntXwJITPGTPX28XwpK05kDpqhYE6OifDbGKwcKG51CceDpqNd9UaNeiSNmjX9O3jhkm(HWfgNjeMjqOlaK0sKHaH1LtDfcK(FfJNmOPwTiDXkhBFHTMJTpYbBnaB9qsNR6)vmE4oD)WR5u0fasAHTzk2AuSnfSnn2Mp26HKoxP7b6q2thfPOlaK0sGemVMtGO7b6CO3f4KWfg)ipHzcKG51CcKM2Mgsscc5ORZPwGqxaiPLidHlm(XdHzcKG51CceDpqhYE6OibcDbGKwImeUW4hzlmtGqxaiPLidbcRlN6keiMJTlc4R1QoYA6IrkOhmWX2xyBoyRjty7Ia(ATQJSMUyKQPTOoi2(cBFKh2Mc2MgB7)vmEYGMA1I0fRCSnxS1CSn7CWwdWwpK05Q(FfJhUt3p8AofDbGKwyBMITgfBtbBtJT5JTEiPZv6EGoK90rrk6cajTeibZR5eidGSCQdNeiSNmjX9O3jhkm(HWfg)WOcZei0fasAjYqGW6YPUcbs)VIXtg0uRwKUyLJT5ITMJTzNd2Aa26HKox1)Ry8WD6(HxZPOlaK0cBZuS1OyBkcKG51CcKbqwo1Htcxy8dJqyMajyEnNazxgSkK8y9ECmsGqxaiPLidHlm(rocZei0fasAjYqGW6YPUcbI5y7Ia(ATQJSMUyKc6bdCS9f2Md2AYe2UiGVwR6iRPlgPAAlQdITVW2h5HTPGTPX28XwpK05kDpqhYE6OifDbGKwcKG51CceDpqNd9UaNeiSNmjX9O3jhkm(HWfg)4nkmtGemVMtGO7b6CO3f4KaHUaqslrgcxy8J3QWmbsW8AobcQPp(O5ORZPwGqxaiPLidHlm(XBkmtGemVMtGenloI7t305ce6cajTeziCHlqagipzgzD7cZeg)qyMaHUaqslrgcewxo1viqa(ATQRns9teibZR5eiOg0Y625aYa6cxyC2cZei0fasAjYqGW6YPUcbI5y7Ia(ATQJSMUyKc6bdCS9f2Md2AYe2UiGVwR6iRPlgPAAlQdITVW2h5HTPGTPX2(FfJNmOPwTiDXkhBZfe2MDoyBASnFS1djDUs3d0HSNoksrxaiPLajyEnNazaKLtD4KaH9KjjUh9o5qHXpeUWyJkmtGqxaiPLidbcRlN6kei9)kgpzqtTAr6Ivo2MliSn7CeibZR5eidGSCQdNeUWyJqyMaHUaqslrgcewxo1viq6)vmEYGMA1I0fRCS9f2MDEyBASfMqsj3JENCOAxgSkK8y9ECmcBZfe2Mn2MgBzZixd6tLusz08rZ19aDvtBrDqSnxSnhbsW8AobYUmyvi5X694yKWfgNJWmbcDbGKwImeiSUCQRqGyo2UiGVwR6iRPlgPGEWahBFHT5GTMmHTlc4R1QoYA6IrQM2I6Gy7lS9rEyBkyBAST)xX4jdAQvlsxSYX2xyB25HTPX28XwpK05kDpqhYE6OifDbGKwyBASLnJCnOpvsjLrZhnx3d0vnTf1bX2CX2CeibZR5ei6EGoh6DbojqypzsI7rVtouy8dHlm(nkmtGqxaiPLidbcRlN6kei9)kgpzqtTAr6Ivo2(cBZopSnn2YMrUg0NkPKYO5JMR7b6QM2I6GyBUyBocKG51CceDpqNd9UaNeUW43QWmbcDbGKwImeiSUCQRqGa81Af4Luw3oFlyOQJu)eSnn22)Ry8Kbn1QfPlw5yBUyR5y7JCWwdWwpK05Q(FfJhUt3p8AofDbGKwyBMITgfBtbBtJTWesk5E07Kdv6EGoK90rryBUGW2SfibZR5ei6EGoK90rrcxy8BkmtGqxaiPLidbcRlN6kei9)kgpzqtTAr6Ivo2MliS1CS1O5GTgGTEiPZv9)kgpCNUF41Ck6cajTW2mfBnk2Mc2MgBHjKuY9O3jhQ09aDi7PJIW2CbHTzlqcMxZjq09aDi7PJIeUW4mHWmbcDbGKwImeiSUCQRqGyo2UiGVwR6iRPlgPGEWahBFHT5GTMmHTlc4R1QoYA6IrQM2I6Gy7lS9rEyBkyBAST)xX4jdAQvlsxSYX2CbHTMJTgnhS1aS1djDUQ)xX4H709dVMtrxaiPf2MPyRrX2uW20yB(yRhs6CLUhOdzpDuKIUaqslbsW8AobYailN6Wjbc7jtsCp6DYHcJFiCHXpYtyMaHUaqslrgcewxo1viq6)vmEYGMA1I0fRCSnxqyR5yRrZbBnaB9qsNR6)vmE4oD)WR5u0fasAHTzk2AuSnfbsW8AobYailN6WjHlm(XdHzce6cajTeziqyD5uxHaHnJCnOpvsjLrZhnx3d0vnTf1bX2CX2(FKYRnI7d3iW20yB)VIXtg0uRwKUyLJTVWwJipSnn2ctiPK7rVtouTldwfsESEpogHT5ccBZwGemVMtGSldwfsESEpogjCHXpYwyMaHUaqslrgcewxo1viqmhBxeWxRvDK10fJuqpyGJTVW2CWwtMW2fb81AvhznDXivtBrDqS9f2(ipSnfSnn2YMrUg0NkPKYO5JMR7b6QM2I6GyBUyB)ps51gX9HBeyBAST)xX4jdAQvlsxSYX2xyRrKh2MgBZhB9qsNR09aDi7PJIu0fasAjqcMxZjq09aDo07cCsGWEYKe3JENCOW4hcxy8dJkmtGqxaiPLidbcRlN6keiSzKRb9PskPmA(O56EGUQPTOoi2Ml22)JuETrCF4gb2MgB7)vmEYGMA1I0fRCS9f2Ae5jqcMxZjq09aDo07cCs4cxGK0eB2acxyMW4hcZeibZR5eijJxZjqOlaK0sKHWfgNTWmbcDbGKwImeixSrcKiliQOdixpNZhnpzqtTajyEnNajYcIk6aY1Z58rZtg0ulCHXgvyMaHUaqslrgcKjrGajxGemVMtG8E0vaijbY7H8tceZXwYi)vscTu34txZhY3LXQcFAihiw7e2AYe2sg5VssOLcwxbDQ57YyvHpnKdeRDcBnzcBjJ8xjj0sbRRGo18DzSQWNgY3OviL1CyRjtylzK)kjHwQ3RqYhnpUAlCAXbKZSWwtMWwYi)vscTu6QHoFlCcYHjp3LbeITMmHTKr(RKeAPE7iih1Gwsn2AYe2sg5VssOL6gF6A(q(Umwv4td5B0kKYAoS1KjSLmYFLKqlvar9ECeK3rwtZzthsSnfbY7rZVyJeiJJIA(C8pK4Kr(RKeAjCHlqyZixd6dkmty8dHzce6cajTeziqcMxZjqISGOIoGC9CoF08Kbn1cewxo1viqmhBzZixd6trBjdAQPfV)hXrtrYCQMI1tSnn2Mp2(E0vaij14OOMph)djozK)kjHwyBkyRjtyR5ylBg5AqFQKskJMpAUUhORAAlQdITVaHTpYdBtJTVhDfassnokQ5ZX)qItg5VssOf2MIa5InsGezbrfDa565C(O5jdAQfUW4SfMjqOlaK0sKHajyEnNar(BWPgYRdwRA(q(EPDbcRlN6keiEiPZvanfok(O5W6wDSpWqrxaiPf2MgBnhBnhBzZixd6tLusz08rZ19aDvtBrDqS9fiS9rEyBAS99ORaqsQXrrnFo(hsCYi)vscTW2uWwtMWwZXwGVwRskPmA(O56EGU6NGTPX28X23JUcajPghf1854FiXjJ8xjj0cBtbBtbBnzcBnhBb(ATkPKYO5JMR7b6QFc2MgBZhB9qsNRaAkCu8rZH1T6yFGHIUaqslSnfbYfBKar(BWPgYRdwRA(q(EPDHlm2OcZei0fasAjYqGemVMtGWEYKJ3ZvmoGmGUaH1LtDfcK8XwGVwRskPmA(O56EGU6NiqUyJeiSNm549CfJdidOlCHXgHWmbcDbGKwImeiSUCQRqGyo2YMrUg0NkPKYO5JMR7b6QMI1tS1KjSLnJCnOpvsjLrZhnx3d0vnTf1bX2CX2SZdBtbBtJTMJT5JTEiPZvanfok(O5W6wDSpWqrxaiPf2AYe2YMrUg0NI2sg0uZ7)rC0uKmNQPTOoi2Ml2MjYbBtrGemVMtG8HeVCAdkCHX5imtGqxaiPLidbsW8Aobsar9ECeK3rwtZzthsbcRlN6keilc4R1QoYAAoB6qYxeWxRvRb9jqUyJeibe17XrqEhznnNnDifUW43OWmbcDbGKwImeibZR5eibe17XrqEhznnNnDifiSUCQRqGWMrUg0NI2sg0uZ7)rC0uKmNQPTOoi2Ml2MjYdBtJTlc4R1QoYAAoB6qYxeWxRv)eSnn2(E0vaij14OOMph)djozK)kjHwyRjtylWxRvanfok(O5W6wDSpWq9tW20y7Ia(ATQJSMMZMoK8fb81A1pbBtJT5JTVhDfassnokQ5ZX)qItg5VssOf2AYe2c81AfTLmOPM3)J4OPizo1pbBtJTlc4R1QoYAAoB6qYxeWxRv)eSnn2Mp26HKoxb0u4O4JMdRB1X(adfDbGKwyRjtyRxBe3h(QiS9f2M9dbYfBKajGOEpocY7iRP5SPdPWfg)wfMjqOlaK0sKHajyEnNa5TJGCudAj1cewxo1viqmhBjJ8xjj0sj)n4ud51bRvnFiFV0o2MgBb(ATkPKYO5JMR7b6QM2I6GyBkyRjtyR5yB(ylzK)kjHwk5VbNAiVoyTQ5d57L2X20ylWxRvjLugnF0CDpqx10wuheBFHTpYgBtJTaFTwLusz08rZ19aD1pbBtrGCXgjqE7iih1GwsTWfg)McZei0fasAjYqGemVMtGa(noF084yfDox)7Ncewxo1viqyZixd6trBjdAQ59)ioAksMt10wuheBZfBnI8eixSrceWVX5JMhhROZ56F)u4cJZecZei0fasAjYqGemVMtGS3ZTd5jDTfsEh7KaH1LtDfcK(Fe2(ce2AuSnn2Mp2c81AvsjLrZhnx3d0v)eSnn2Ao2Mp2c81AfqtHJIpAoSUvh7dmu)eS1KjSnFS1djDUcOPWrXhnhw3QJ9bgk6cajTW2ueixSrcK9EUDipPRTqY7yNeUW4h5jmtGqxaiPLidbYfBKaPJSw)dCihO25nT4aF3NtGemVMtG0rwR)boKdu78MwCGV7ZjCHXpEimtGqxaiPLidbsW8AobYg1e4oQaY1XTlqyD5uxHajFSf4R1kGMchfF0CyDRo2hyO(jyBASnFSf4R1QKskJMpAUUhOR(jcKl2ibYg1e4oQaY1XTlCHXpYwyMaHUaqslrgcewxo1viqa(ATkPKYO5JMR7b6QFc2MgBb(ATI2sg0uZ7)rC0uKmN6NiqcMxZjqsgVMt4cJFyuHzce6cajTeziqyD5uxHab4R1QKskJMpAUUhOR(jyBASf4R1kAlzqtnV)hXrtrYCQFIajyEnNabqoZIR)9tHlm(HrimtGqxaiPLidbcRlN6keiaFTwLusz08rZ19aD1prGemVMtGaqnKAWRBx4cJFKJWmbcDbGKwImeiSUCQRqGWMrUg0NI2sg0uZ7)rC0uKmNQPTOoOajyEnNajPKYO5JMR7b6cxy8J3OWmbcDbGKwImeiFiXhTMVZwcKhcKG51CceGMchfF0CyDRo2hyiqyD5uxHaHnJCnOpfTLmOPM3)J4OPizovtBrDqSnn2YMrUg0NkPKYO5JMR7b6QM2I6Gcxy8J3QWmbcDbGKwImeiSUCQRqGWMrUg0NkPKYO5JMR7b6QMI1tSnn2Mp26HKoxb0u4O4JMdRB1X(adfDbGKwyBAST)hP8AJ4(WZbBZfB3zlSnn22)Ry8Kbn1QfPlw5yBUGW2h5HTMmHTETrCF4RIW2xyB25jqcMxZjqOTKbn18(FehnfjZjCHXpEtHzce6cajTeziqyD5uxHaXCSLnJCnOpvsjLrZhnx3d0vnfRNyRjtyRxBe3h(QiS9f2MDEyBkyBAS1djDUcOPWrXhnhw3QJ9bgk6cajTW20yB)VIXtg0uJT5ITVX8eibZR5ei0wYGMAE)pIJMIK5eUW4hzcHzce6cajTeziqcMxZjqyHuYdMxZXLf0fiSUCQRqG4HKoxXg5IJII2v0fasAHTPXwZXwZXwGVwRyJCXrrr7kOhmWX2CbHTpYdBtJTlc4R1QoYA6IrkOhmWXwqyBoyBkyRjtyRxBe3h(QiS9fiSDNTW2ueiYc68l2ibcBKlokkAx4cJZopHzce6cajTeziqyD5uxHaXCSf4R1QKskJMpAUUhORAAlQdITVaHT7Sf2AYe2Ao2c81AvsjLrZhnx3d0vnTf1bX2xy7BITPXwGVwR(hQr(Kd9MUDhLQPTOoi2(ce2UZwyBASf4R1Q)HAKp5qVPB3rP(jyBkyBkyBASf4R1QKskJMpAUUhOR(jyBASnYI6YjvXEYzLhlsQ64ahBFbcBZwGemVMtGO7b6OF2BqU(3pfUW4SFimtGqxaiPLidbcRlN6keiMJTaFTwvSNCw5XIKQM2I6Gy7lqy7oBHTMmHTMJTaFTwvSNCw5XIKQM2I6Gy7lS9nX20ylWxRv)d1iFYHEt3UJs10wuheBFbcB3zlSnn2c81A1)qnYNCO30T7Ou)eSnfSnfSnn2c81AvXEYzLhlsQ(jyBASnYI6YjvXEYzLhlsQ64ahBZfBZwGemVMtGO7b6OF2BqU(3pfUW4SZwyMaHUaqslrgcewxo1viq8AJ4(WxfHTVW2D2cBnzcBnhB9AJ4(WxfHTVWw2mY1G(ujLugnF0CDpqx10wuheBtJTaFTw9puJ8jh6nD7ok1pbBtrGemVMtGO7b6OF2BqU(3pfUWfilshFPlmty8dHzcKG51CcKT6wCDtuwKaHUaqslrgcxyC2cZei0fasAjYqGW6YPUcbs(y7ACLUhOZ107uR8IbED7yBAS1CSnFS1djDUcOPWrXhnhw3QJ9bgk6cajTWwtMWw2mY1G(uanfok(O5W6wDSpWq10wuheBZfBFKd2MIajyEnNab1Gww3ohqgqx4cJnQWmbcDbGKwImeiSUCQRqGa81AvXEY9qohu10wuheBFbcB3zlSnn2c81AvXEY9qohu9tW20ylmHKsUh9o5q1Umyvi5X694ye2MliSnBSnn2Ao2Mp26HKoxb0u4O4JMdRB1X(adfDbGKwyRjtylBg5AqFkGMchfF0CyDRo2hyOAAlQdIT5ITpYbBtrGemVMtGSldwfsESEpogjCHXgHWmbcDbGKwImeiSUCQRqGa81AvXEY9qohu10wuheBFbcB3zlSnn2c81AvXEY9qohu9tW20yR5yB(yRhs6CfqtHJIpAoSUvh7dmu0fasAHTMmHTSzKRb9PaAkCu8rZH1T6yFGHQPTOoi2Ml2(ihSnfbsW8AobIUhOZHExGtcxyCocZei0fasAjYqGemVMtGWcPKhmVMJllOlqKf05xSrceccPJrqHlm(nkmtGqxaiPLidbsW8AobclKsEW8AoUSGUarwqNFXgjqyZixd6dkCHXVvHzce6cajTeziqcMxZjq6)XdMxZXLf0fiSUCQRqG4HKoxb0u4O4JMdRB1X(adfDbGKwyBAS1CS1CSLnJCnOpfqtHJIpAoSUvh7dmunTf1bXwqyBEyBASLnJCnOpvsjLrZhnx3d0vnTf1bX2xy7J8W2uWwtMWwZXw2mY1G(uanfok(O5W6wDSpWq10wuheBFHTzNh2MgB9AJ4(WxfHTVWwJMd2Mc2MIarwqNFXgjqagipzgzD7cxy8BkmtGqxaiPLidbsW8Aobs)pEW8AoUSGUaH1LtDfceGVwRaAkCu8rZH1T6yFGH6NiqKf05xSrceGbY9IbED7cxyCMqyMaHUaqslrgcKG51CcK(F8G51CCzbDbcRlN6keiaFTwLusz08rZ19aD1pbBtJTEiPZvdGSCQdVMtrxaiPLarwqNFXgjqgaz5uhEnNWfg)ipHzce6cajTeziqcMxZjq6)XdMxZXLf0fiSUCQRqGemVEN40rBfbX2CbHTzlqKf05xSrcKyiHlm(XdHzce6cajTeziqcMxZjqyHuYdMxZXLf0fiYc68l2ibc0JBf9s4cxGa94wrVeMjm(HWmbsW8AobstBtdjjbHC015ulqOlaK0sKHWfgNTWmbcDbGKwImeiSUCQRqGWMrUg0NQPTPHKKGqo66CQvnTf1bX2xGW2SX2mfB3zlSnn26HKoxThokQRBNd9P3u0fasAjqcMxZjq09aDo07cCs4cJnQWmbcDbGKwImeiSUCQRqGa81AvxBK6NiqcMxZjqqnOL1TZbKb0fUWyJqyMaHUaqslrgcewxo1viqYhBb(ATs3tw0Xt(siP(jyBAS1djDUs3tw0Xt(siPOlaK0sGemVMtGmaYYPoCs4cJZryMaHUaqslrgcewxo1viq6)vmEYGMA1I0fRCS9f2Ao2(ihS1aS1djDUQ)xX4H709dVMtrxaiPf2MPyRrX2ueibZR5ei6EGoh6DbojCHXVrHzce6cajTeziqyD5uxHab4R1kWlPSUD(wWqvhP(jyBAST)hP8AJ4(WncSnxqy7oBjqcMxZjq09aDi7PJIeUW43QWmbcDbGKwImeiSUCQRqG0)Ry8Kbn1QfPlw5yBUyR5yB25GTgGTEiPZv9)kgpCNUF41Ck6cajTW2mfBnk2MIajyEnNazaKLtD4KWfg)McZeibZR5ei6EGoh6DbojqOlaK0sKHWfgNjeMjqcMxZjqqn9XhnhDDo1ce6cajTeziCHXpYtyMajyEnNajAwCe3NUPZfi0fasAjYq4cxGqqiDmckmty8dHzce6cajTeziqyD5uxHab4R1QKskJMpAUUhORAAlQdITVW2h5HTPXw2mY1G(uanfok(O5W6wDSpWq10wuheBnzcBb(ATkPKYO5JMR7b6QM2I6Gy7lS9rEyBASnFS1djDUcOPWrXhnhw3QJ9bgk6cajTeibZR5eiaYzw8rZDueNoA7PWfgNTWmbsW8AobY(p6vfhF08ilQhhLaHUaqslrgcxySrfMjqOlaK0sKHaH1LtDfceGVwRskPmA(O56EGUQPTOoi2(cBZbBnzcB9AJ4(WxfHTVW2CeibZR5eimuLuYHEtb4cxySrimtGqxaiPLidbcRlN6keiaFTw1edCjbHC90ms9tWwtMWwGVwRAIbUKGqUEAgXzZ)CQvqpyGJTVW2hpeibZR5eiokI)pG5FlUEAgjCHX5imtGqxaiPLidbcRlN6kei5JTaFTwLusz08rZ19aD1pbBtJT5JTaFTwb0u4O4JMdRB1X(ad1prGemVMtGOh2hslEKf1LtCak2eUW43OWmbcDbGKwImeiSUCQRqGKp2c81AvsjLrZhnx3d0v)eSnn2Mp2c81AfqtHJIpAoSUvh7dmu)eSnn2UgxXMJrN3HtlUwgBeh43NQPTOoi2ccBZtGemVMtGWMJrN3HtlUwgBKWfg)wfMjqOlaK0sKHaH1LtDfcK8XwGVwRskPmA(O56EGU6NGTPX28XwGVwRaAkCu8rZH1T6yFGH6NiqcMxZjqs(DPFw3ohqgqx4cJFtHzce6cajTeziqyD5uxHajFSf4R1QKskJMpAUUhOR(jyBASnFSf4R1kGMchfF0CyDRo2hyO(jcKG51Cce0tlxVt1XBcoxCms4cJZecZei0fasAjYqGW6YPUcbs(ylWxRvjLugnF0CDpqx9tW20yB(ylWxRvanfok(O5W6wDSpWq9teibZR5eiDLKijEDCysWiHlm(rEcZei0fasAjYqGW6YPUcbcWxRv0wYGMAE)pIJMIK5unTf1bX2xyBoyBASf4R1kGMchfF0CyDRo2hyO(jyRjtyR5yB)ps51gX9HNn2Ml2UZwyBAST)xX4jdAQX2xyBo5HTPiqcMxZjq2OTPFYhnx(z1IVAk2Gcx4cxG8o1WAoHXzN3JmrEV5J3uGGo6RUDOa5TzlzANwy7J8W2G51CyRSGouHbtGK0JUKKajZW2mxpqhBFlrHJcBZKF1okhdwMHTOCpbMjLAQ7LJ6dOyZwQWA7ldVMJ1H2tfwBSuXGLzyBM)F)dDS9XBAi2MDEpYey7BaBFKDMKrKhgmmyzg2(wGkUDcMjHblZW23a2(2Cm5FryBMm1TW2mxtuwKcdwMHTVbSnZFTWwDiLabdCSvpn2(H1TJTVTzEZ8yi2(2pzoST0yBImEsn2wx5v4eeBZyqWwaspnHTjZiRBhBLZEXW2cITSzlrsoTuyWYmS9nGTVfOIBNWwp6DYvETrCF4RIWwFWwV2iUp8vryRpy7hsylDS5Fo1yRKUDhf22HJIAS1rfh2MmoDEfsS17aIcBxu4OGkmyyWYmS9T9TmX(oTWwaspnHTSzdiCSfG2RdQW2mFgJsCi2EZ9gqf9M(lX2G51CqSDo5tfgSmdBdMxZbvjnXMnGWbPLbeCmyzg2gmVMdQsAInBaHBaOu1ZSWGLzyBW8AoOkPj2SbeUbGsn(7B05HxZHblZWwKlsGOghB7OwylWxRPf2c9WHylaPNMWw2Sbeo2cq71bX24wyBstVHKX962X2cITR5ifgSmdBdMxZbvjnXMnGWnauQWlsGOgNd9WHyWcMxZbvjnXMnGWnauQjJxZHblyEnhuL0eB2ac3aqP(HeVCAZWl2iqrwqurhqUEoNpAEYGMAmybZR5GQKMyZgq4gak13JUcajz4fBeOXrrnFo(hsCYi)vscTm89q(jqMtg5VssOL6gF6A(q(Umwv4td5aXANmzImYFLKqlfSUc6uZ3LXQcFAihiw7KjtKr(RKeAPG1vqNA(Umwv4td5B0kKYAotMiJ8xjj0s9Efs(O5XvBHtloGCMLjtKr(RKeAP0vdD(w4eKdtEUldi0KjYi)vscTuVDeKJAqlP2KjYi)vscTu34txZhY3LXQcFAiFJwHuwZzYezK)kjHwQaI694iiVJSMMZMoKPGbddwMHTVTVLj23Pf2sVt9tS1RncBDue2gmFASTGyB8EuYaqskmybZR5GG2QBX1nrzryWYmSnZpjr(eBZC9aDSnZrVtn2g3cB3I68OoS9TH9eBnlKZbXGfmVMdAaOurnOL1TZbKb0nS0GYFnUs3d05A6DQvEXaVU90MNVhs6CfqtHJIpAoSUvh7dmu0fasAzYeBg5AqFkGMchfF0CyDRo2hyOAAlQdM7JCsbdwW8AoObGsDxgSkK8y9ECmYWsdc4R1QI9K7HCoOQPTOo4lq7SvAGVwRk2tUhY5GQFsAycjLCp6DYHQDzWQqYJ17XXOCbLDAZZ3djDUcOPWrXhnhw3QJ9bgk6cajTmzInJCnOpfqtHJIpAoSUvh7dmunTf1bZ9roPGblyEnh0aqPQ7b6CO3f4KHLgeWxRvf7j3d5CqvtBrDWxG2zR0aFTwvSNCpKZbv)K0MNVhs6CfqtHJIpAoSUvh7dmu0fasAzYeBg5AqFkGMchfF0CyDRo2hyOAAlQdM7JCsbdwW8AoObGsLfsjpyEnhxwq3Wl2iqeeshJGyWcMxZbnauQSqk5bZR54Yc6gEXgbInJCnOpigSG51CqdaLA)pEW8AoUSGUHxSrGagipzgzD7gwAqEiPZvanfok(O5W6wDSpWqrxaiPvAZnNnJCnOpfqtHJIpAoSUvh7dmunTf1bbLxA2mY1G(ujLugnF0CDpqx10wuh81J8sXKjZzZixd6tb0u4O4JMdRB1X(advtBrDWxzNxAV2iUp8vrVmAoPKcgSG51CqdaLA)pEW8AoUSGUHxSrGagi3lg41TByPbb81AfqtHJIpAoSUvh7dmu)emybZR5Ggak1(F8G51CCzbDdVyJanaYYPo8AodlniGVwRskPmA(O56EGU6NK2djDUAaKLtD41Ck6cajTWGfmVMdAaOu7)XdMxZXLf0n8IncumKHLguW86DIthTvemxqzJblyEnh0aqPYcPKhmVMJllOB4fBeiOh3k6fgmmybZR5GQyiqnTnnKKeeYrxNtTHLgKhs6C1E4OOUUDo0NEtrxaiPLjtMhzrD5Ks3tw0XDAlHGUQJd80Wesk5E07KdvnTnnKKeeYrxNtDUGmA68b(ATQRns9tsbdwW8AoOkgYaqPUldwfsESEpogzyPb5HKoxP7b6q2thfPOlaK0cdwW8AoOkgYaqPQ7b6CO3f4KHSNmjX9O3jhc6HHLgK5lc4R1QoYA6IrkOhmWFLJjtlc4R1QoYA6IrQM2I6GVEKxkPzZixd6t1020qssqihDDo1QM2I6GVaLDMUZwP9qsNR2dhf11TZH(0Bk6cajTsNVhs6CLUhOdzpDuKIUaqslmybZR5GQyidaLQUhOZHExGtgwAqSzKRb9PAABAijjiKJUoNAvtBrDWxGYot3zR0EiPZv7HJI6625qF6nfDbGKwyWcMxZbvXqgakvudAzD7CazaDdlniGVwR6AJu)emybZR5GQyidaLQUhOdzpDuKHLgeWxRvGxszD78TGHQos9tWGfmVMdQIHmauQ7YGvHKhR3JJrgwAq9)kgpzqtTAr6Iv(lZFKJbEiPZv9)kgpCNUF41Ck6cajTYuJMcgSG51CqvmKbGsv3d05qVlWjdzpzsI7rVtoe0ddlniZxeWxRvDK10fJuqpyG)khtMweWxRvDK10fJunTf1bF9iVus3)Ry8Kbn1QfPlw5Vm)rog4HKox1)Ry8WD6(HxZPOlaK0ktnAkPZ3djDUs3d0HSNoksrxaiPfgSG51CqvmKbGsv3d05qVlWjdlnO(FfJNmOPwTiDXk)L5pYXapK05Q(FfJhUt3p8AofDbGKwzQrtjD(EiPZv6EGoK90rrk6cajTWGfmVMdQIHmauQnTnnKKeeYrxNtngSG51CqvmKbGsv3d0HSNokcdwW8AoOkgYaqPoaYYPoCYq2tMK4E07Kdb9WWsdY8fb81AvhznDXif0dg4VYXKPfb81AvhznDXivtBrDWxpYlL09)kgpzqtTAr6IvEUMNDog4HKox1)Ry8WD6(HxZPOlaK0ktnAkPZ3djDUs3d0HSNoksrxaiPfgSG51CqvmKbGsDaKLtD4KHLgu)VIXtg0uRwKUyLNR5zNJbEiPZv9)kgpCNUF41Ck6cajTYuJMcgSG51CqvmKbGsDxgSkK8y9ECmcdwW8AoOkgYaqPQ7b6CO3f4KHSNmjX9O3jhc6HHLgK5lc4R1QoYA6IrkOhmWFLJjtlc4R1QoYA6IrQM2I6GVEKxkPZ3djDUs3d0HSNoksrxaiPfgSG51CqvmKbGsv3d05qVlWjmybZR5GQyidaLkQPp(O5ORZPgdwW8AoOkgYaqPgnloI7t305yWWGLzyBgnfokSD0ylsDRo2hyGTjZiRBhB7XdVMdBZKWwOhTdX2SZdITaKEAcBF7lPmASD0yBMRhOJTgGTzmiyB0e2gVhLmaKegSG51CqfWa5jZiRBheQbTSUDoGmGUHLgeWxRvDTrQFcgSG51CqfWa5jZiRB3aqPoaYYPoCYq2tMK4E07Kdb9WWsdY8fb81AvhznDXif0dg4VYXKPfb81AvhznDXivtBrDWxpYlL09)kgpzqtTAr6IvEUGYoN057HKoxP7b6q2thfPOlaK0cdwW8AoOcyG8KzK1TBaOuhaz5uhozyPb1)Ry8Kbn1QfPlw55ck7CWGfmVMdQagipzgzD7gak1DzWQqYJ17XXidlnO(FfJNmOPwTiDXk)v25LgMqsj3JENCOAxgSkK8y9ECmkxqzNMnJCnOpvsjLrZhnx3d0vnTf1bZnhmybZR5GkGbYtMrw3UbGsv3d05qVlWjdzpzsI7rVtoe0ddlniZxeWxRvDK10fJuqpyG)khtMweWxRvDK10fJunTf1bF9iVus3)Ry8Kbn1QfPlw5VYoV057HKoxP7b6q2thfPOlaK0knBg5AqFQKskJMpAUUhORAAlQdMBoyWcMxZbvadKNmJSUDdaLQUhOZHExGtgwAq9)kgpzqtTAr6Iv(RSZlnBg5AqFQKskJMpAUUhORAAlQdMBoyWcMxZbvadKNmJSUDdaLQUhOdzpDuKHLgeWxRvGxszD78TGHQos9ts3)Ry8Kbn1QfPlw55A(JCmWdjDUQ)xX4H709dVMtrxaiPvMA0usdtiPK7rVtouP7b6q2thfLlOSXGfmVMdQagipzgzD7gakvDpqhYE6OidlnO(FfJNmOPwTiDXkpxqMB0CmWdjDUQ)xX4H709dVMtrxaiPvMA0usdtiPK7rVtouP7b6q2thfLlOSXGfmVMdQagipzgzD7gak1bqwo1HtgYEYKe3JENCiOhgwAqMViGVwR6iRPlgPGEWa)voMmTiGVwR6iRPlgPAAlQd(6rEPKU)xX4jdAQvlsxSYZfK5gnhd8qsNR6)vmE4oD)WR5u0fasALPgnL057HKoxP7b6q2thfPOlaK0cdwW8AoOcyG8KzK1TBaOuhaz5uhozyPb1)Ry8Kbn1QfPlw55cYCJMJbEiPZv9)kgpCNUF41Ck6cajTYuJMcgSG51CqfWa5jZiRB3aqPUldwfsESEpogzyPbXMrUg0NkPKYO5JMR7b6QM2I6G52)JuETrCF4gr6(FfJNmOPwTiDXk)LrKxAycjLCp6DYHQDzWQqYJ17XXOCbLngSG51CqfWa5jZiRB3aqPQ7b6CO3f4KHSNmjX9O3jhc6HHLgK5lc4R1QoYA6IrkOhmWFLJjtlc4R1QoYA6IrQM2I6GVEKxkPzZixd6tLusz08rZ19aDvtBrDWC7)rkV2iUpCJiD)VIXtg0uRwKUyL)YiYlD(EiPZv6EGoK90rrk6cajTWGfmVMdQagipzgzD7gakvDpqNd9UaNmS0GyZixd6tLusz08rZ19aDvtBrDWC7)rkV2iUpCJiD)VIXtg0uRwKUyL)YiYddggSmdBZCHucemWXwFW2pKW23(jZzi2(2M5nZd2IgfDy7hs9BOUYRWji2MXGGTjnTf(Vj5tfgSG51CqfWa5EXaVUDqjLugnF0CDpq3WsdInJCnOpfTLmOPM3)J4OPizovtBrDqmybZR5GkGbY9IbED7gakvAlzqtnV)hXrtrYCyWcMxZbvadK7fd862nauQdGSCQdNmK9KjjUh9o5qqpmS0GmFraFTw1rwtxmsb9Gb(RCmzAraFTw1rwtxms10wuh81J8sjD)VIXtg0u)cKrZlD(EiPZv6EGoK90rrk6cajTWGfmVMdQagi3lg41TBaOuhaz5uhozyPb1)Ry8Kbn1Vaz0SXGfmVMdQagi3lg41TBaOuBABAijjiKJUoNAdlnipK05Q9WrrDD7COp9MIUaqslmybZR5GkGbY9IbED7gakvudAzD7CazaDdlniGVwR6AJu)emybZR5GkGbY9IbED7gak1bqwo1HtgYEYKe3JENCiOhgwAqMViGVwR6iRPlgPGEWa)voMmTiGVwR6iRPlgPAAlQd(6rEPKU)hP8AJ4(WZ51oBzYu)VIXtg0u)cKrKt689qsNR09aDi7PJIu0fasAHblyEnhubmqUxmWRB3aqPoaYYPoCYWsdQ)hP8AJ4(WZ51oBzYu)VIXtg0u)cKrKdgSG51CqfWa5EXaVUDdaLQUhOdzpDuKHLgeWxRvGxszD78TGHQos9tsdtiPK7rVtouP7b6q2thfLlOSXGfmVMdQagi3lg41TBaOurn9XhnhDDo1gwAq9)kgpzqtTAr6IvEUGmA2P7)rkV2iUpCJM7oBHblyEnhubmqUxmWRB3aqP2020qssqihDDo1yWcMxZbvadK7fd862nauQ6EGoK90rrgwAqWesk5E07Kdv6EGoK90rr5ckBmybZR5GkGbY9IbED7gak1bqwo1HtgYEYKe3JENCiOhgwAqMViGVwR6iRPlgPGEWa)voMmTiGVwR6iRPlgPAAlQd(6rEPKU)xX4jdAQvlsxSYZn7CmzQ)hLRrtNVhs6CLUhOdzpDuKIUaqslmybZR5GkGbY9IbED7gak1bqwo1HtgwAq9)kgpzqtTAr6IvEUzNJjt9)OCnkgSG51CqfWa5EXaVUDdaLA0S4iUpDtNByPb1)Ry8Kbn1QfPlw55MDEyWWGLzy7BXixylkkAhBzZTkVMdIblyEnhuXg5IJII2bXqf1b5JMxmYWsdc4R1k2ixCuu0Uc6bd8CZjTxBe3h(QOx7SfgSG51CqfBKlokkA3aqPYqf1b5JMxmYWsdYCGVwRskPmA(O56EGUQPTOo4lq7SvMA(ddyZixd6tP7b6OF2BqU(3pvnfRNPyYeWxRvjLugnF0CDpqx10wuh8v)ps51gX9HB0usd81AvsjLrZhnx3d0v)K0rwuxoPk2toR8yrsvhh4VaLngSG51CqfBKlokkA3aqPYqf1b5JMxmYWsdc4R1QKskJMpAUUhORAAlQd(6ntd81A1)qnYNCO30T7OunTf1bFTZwzQ5pmGnJCnOpLUhOJ(zVb56F)u1uSEMsAGVwR(hQr(Kd9MUDhLQPTOoyAGVwRskPmA(O56EGU6NKoYI6YjvXEYzLhlsQ64a)fOSXGfmVMdQyJCXrrr7gakvgQOoiF08IrgwAqMd81AvXEYzLhlsQAAlQd(Yimzc4R1QI9KZkpwKu10wuh8v)ps51gX9HB0usd81AvXEYzLhlsQ(jPJSOUCsvSNCw5XIKQooWZnBmybZR5Gk2ixCuu0UbGsLHkQdYhnVyKHLgeWxRvf7jNvESiP6NKg4R1Q)HAKp5qVPB3rP(jPJSOUCsvSNCw5XIKQooWZnBmyyWcMxZbvSzKRb9bb9HeVCAZWl2iqrwqurhqUEoNpAEYGMAdlniZzZixd6trBjdAQPfV)hXrtrYCQMI1Z05)E0vaij14OOMph)djozK)kjHwPyYK5SzKRb9PskPmA(O56EGUQPTOo4lqpYl97rxbGKuJJIA(C8pK4Kr(RKeALcgSG51CqfBg5AqFqdaL6hs8YPndVyJaj)n4ud51bRvnFiFV0UHLgKhs6CfqtHJIpAoSUvh7dmu0fasAL2CZzZixd6tLusz08rZ19aDvtBrDWxGEKx63JUcajPghf1854FiXjJ8xjj0kftMmh4R1QKskJMpAUUhOR(jPZ)9ORaqsQXrrnFo(hsCYi)vscTsjftMmh4R1QKskJMpAUUhOR(jPZ3djDUcOPWrXhnhw3QJ9bgk6cajTsbdwW8AoOInJCnOpObGs9djE50MHxSrGypzYX75kghqgq3WsdkFGVwRskPmA(O56EGU6NGblyEnhuXMrUg0h0aqP(HeVCAdAyPbzoBg5AqFQKskJMpAUUhORAkwpnzInJCnOpvsjLrZhnx3d0vnTf1bZn78sjT557HKoxb0u4O4JMdRB1X(adfDbGKwMmXMrUg0NI2sg0uZ7)rC0uKmNQPTOoyUzICsbdwW8AoOInJCnOpObGs9djE50MHxSrGciQ3JJG8oYAAoB6qAyPbTiGVwR6iRP5SPdjFraFTwTg0hgSG51CqfBg5AqFqdaL6hs8YPndVyJafquVhhb5DK10C20H0WsdInJCnOpfTLmOPM3)J4OPizovtBrDWCZe5LEraFTw1rwtZzths(Ia(AT6NK(9ORaqsQXrrnFo(hsCYi)vscTmzc4R1kGMchfF0CyDRo2hyO(jPxeWxRvDK10C20HKViGVwR(jPZ)9ORaqsQXrrnFo(hsCYi)vscTmzc4R1kAlzqtnV)hXrtrYCQFs6fb81AvhznnNnDi5lc4R1QFs689qsNRaAkCu8rZH1T6yFGHIUaqsltM8AJ4(Wxf9k7hyWcMxZbvSzKRb9bnauQFiXlN2m8Inc0Bhb5Og0sQnS0GmNmYFLKqlL83GtnKxhSw18H89s7Pb(ATkPKYO5JMR7b6QM2I6GPyYK55tg5VssOLs(BWPgYRdwRA(q(EP90aFTwLusz08rZ19aDvtBrDWxpYonWxRvjLugnF0CDpqx9tsbdwW8AoOInJCnOpObGs9djE50MHxSrGa)gNpAECSIoNR)9tdlni2mY1G(u0wYGMAE)pIJMIK5unTf1bZ1iYddwW8AoOInJCnOpObGs9djE50MHxSrG2752H8KU2cjVJDYWsdQ)h9cKrtNpWxRvjLugnF0CDpqx9tsBE(aFTwb0u4O4JMdRB1X(ad1pXKP89qsNRaAkCu8rZH1T6yFGHIUaqsRuWGfmVMdQyZixd6dAaOu)qIxoTz4fBeOoYA9pWHCGAN30Id8DFomybZR5Gk2mY1G(Ggak1pK4LtBgEXgbAJAcChva5642nS0GYh4R1kGMchfF0CyDRo2hyO(jPZh4R1QKskJMpAUUhOR(jyWcMxZbvSzKRb9bnauQjJxZzyPbb81AvsjLrZhnx3d0v)K0aFTwrBjdAQ59)ioAksMt9tWGfmVMdQyZixd6dAaOubKZS46F)0Wsdc4R1QKskJMpAUUhOR(jPb(ATI2sg0uZ7)rC0uKmN6NGblyEnhuXMrUg0h0aqPcqnKAWRB3Wsdc4R1QKskJMpAUUhOR(jyWYmSnZ1d0Xw2mY1G(GyWcMxZbvSzKRb9bnauQjLugnF0CDpq3WsdInJCnOpfTLmOPM3)J4OPizovtBrDqmybZR5Gk2mY1G(GgakvGMchfF0CyDRo2hyy4hs8rR57SfOhgwAqSzKRb9POTKbn18(FehnfjZPAAlQdMMnJCnOpvsjLrZhnx3d0vnTf1bXGfmVMdQyZixd6dAaOuPTKbn18(FehnfjZzyPbXMrUg0NkPKYO5JMR7b6QMI1Z057HKoxb0u4O4JMdRB1X(adfDbGKwP7)rkV2iUp8CYDNTs3)Ry8Kbn1QfPlw55c6rEMm51gX9HVk6v25HblyEnhuXMrUg0h0aqPsBjdAQ59)ioAksMZWsdYC2mY1G(ujLugnF0CDpqx1uSEAYKxBe3h(QOxzNxkP9qsNRaAkCu8rZH1T6yFGHIUaqsR09)kgpzqtDUVX8WGfmVMdQyZixd6dAaOuzHuYdMxZXLf0n8InceBKlokkA3WsdYdjDUInYfhffTROlaK0kT5Md81AfBKlokkAxb9GbEUGEKx6fb81AvhznDXif0dg4GYjftM8AJ4(Wxf9c0oBLcgSG51CqfBg5AqFqdaLQUhOJ(zVb56F)0WsdYCGVwRskPmA(O56EGUQPTOo4lq7SLjtMd81AvsjLrZhnx3d0vnTf1bF9MPb(AT6FOg5to0B62DuQM2I6GVaTZwPb(AT6FOg5to0B62DuQFskPKg4R1QKskJMpAUUhOR(jPJSOUCsvSNCw5XIKQooWFbkBmybZR5Gk2mY1G(GgakvDpqh9ZEdY1)(PHLgK5aFTwvSNCw5XIKQM2I6GVaTZwMmzoWxRvf7jNvESiPQPTOo4R3mnWxRv)d1iFYHEt3UJs10wuh8fOD2knWxRv)d1iFYHEt3UJs9tsjL0aFTwvSNCw5XIKQFs6ilQlNuf7jNvESiPQJd8CZgdwW8AoOInJCnOpObGsv3d0r)S3GC9VFAyPb51gX9HVk61oBzYK5ETrCF4RIEXMrUg0NkPKYO5JMR7b6QM2I6GPb(AT6FOg5to0B62DuQFskyWWGfmVMdQiiKogbbbiNzXhn3rrC6OTNgwAqaFTwLusz08rZ19aDvtBrDWxpYlnBg5AqFkGMchfF0CyDRo2hyOAAlQdAYeWxRvjLugnF0CDpqx10wuh81J8sNVhs6CfqtHJIpAoSUvh7dmu0fasAHblyEnhurqiDmcAaOu3)rVQ44JMhzr94OWGfmVMdQiiKogbnauQmuLuYHEtb4gwAqaFTwLusz08rZ19aDvtBrDWx5yYKxBe3h(QOx5GblyEnhurqiDmcAaOuDue)FaZ)wC90mYWsdc4R1QMyGljiKRNMrQFIjtaFTw1edCjbHC90mIZM)5uRGEWa)1JhyWcMxZbveeshJGgakv9W(qAXJSOUCIdqXMHLgu(aFTwLusz08rZ19aD1pjD(aFTwb0u4O4JMdRB1X(ad1pbdwW8AoOIGq6ye0aqPYMJrN3HtlUwgBKHLgu(aFTwLusz08rZ19aD1pjD(aFTwb0u4O4JMdRB1X(ad1pj9ACfBogDEhoT4AzSrCGFFQM2I6GGYddwW8AoOIGq6ye0aqPM87s)SUDoGmGUHLgu(aFTwLusz08rZ19aD1pjD(aFTwb0u4O4JMdRB1X(ad1pbdwW8AoOIGq6ye0aqPIEA56DQoEtW5IJrgwAq5d81AvsjLrZhnx3d0v)K05d81AfqtHJIpAoSUvh7dmu)emybZR5GkccPJrqdaLAxjjsIxhhMemYWsdkFGVwRskPmA(O56EGU6NKoFGVwRaAkCu8rZH1T6yFGH6NGblyEnhurqiDmcAaOu3OTPFYhnx(z1IVAk2GgwAqaFTwrBjdAQ59)ioAksMt10wuh8voPb(ATcOPWrXhnhw3QJ9bgQFIjtM3)JuETrCF4zN7oBLU)xX4jdAQFLtEPGbddwMHTzYcilN6WR5W2E8WR5WGfmVMdQgaz5uhEnhOM2Mgsscc5ORZP2WsdYdjDUApCuux3oh6tVPOlaK0cdwW8AoOAaKLtD41Cgak1bqwo1HtgYEYKe3JENCiOhgwAqMViGVwR6iRPlgPGEWa)voMmTiGVwR6iRPlgPAAlQd(6rEPKoFpK05kDpqhYE6OifDbGKwPZh4R1QU2i1pjnmHKsUh9o5qfQbTSUDoGmGEUGmkgSG51Cq1ailN6WR5mauQdGSCQdNmS0GY3djDUs3d0HSNoksrxaiPv68b(ATQRns9tsdtiPK7rVtouHAqlRBNdidONliJIblyEnhunaYYPo8AodaLQUhOdzpDuKHLgK5aFTwbEjL1TZ3cgQ6ivtbZnzYCGVwRaVKY625BbdvDK6NK28KMENVZwQhkDpqNd9UaNmzkPP357SL6Hc1Gww3ohqgq3KPKMENVZwQhQDzWQqYJ17XXOusjL0Wesk5E07Kdv6EGoK90rr5ckBmybZR5GQbqwo1HxZzaOuhaz5uhozi7jtsCp6DYHGEyyPbz(Ia(ATQJSMUyKc6bd8x5yY0Ia(ATQJSMUyKQPTOo4Rh5LsAGVwRaVKY625BbdvDKQPG5MmzoWxRvGxszD78TGHQos9tsBEstVZ3zl1dLUhOZHExGtMmL0078D2s9qHAqlRBNdidOBYustVZ3zl1d1Umyvi5X694yukPGblyEnhunaYYPo8AodaL6ailN6WjdlniGVwRaVKY625BbdvDKQPG5MmzoWxRvGxszD78TGHQos9tsBEstVZ3zl1dLUhOZHExGtMmL0078D2s9qHAqlRBNdidOBYustVZ3zl1d1Umyvi5X694yukPGblyEnhunaYYPo8AodaL6Umyvi5X694yKHLgK55d81AvxBK6NyYu)VIXtg0uRwKUyL)6rEMm1)JuETrCF4zN7oBLsAycjLCp6DYHQDzWQqYJ17XXOCbLngSG51Cq1ailN6WR5mauQOg0Y625aYa6gwAqaFTw11gP(jPHjKuY9O3jhQqnOL1TZbKb0Zfu2yWcMxZbvdGSCQdVMZaqPQ7b6CO3f4KHSNmjX9O3jhc6HHLgK5lc4R1QoYA6IrkOhmWFLJjtlc4R1QoYA6IrQM2I6GVEKxkPZh4R1QU2i1pXKP(FfJNmOPwTiDXk)1J8mzQ)hP8AJ4(WZo3D2kD(EiPZv6EGoK90rrk6cajTWGfmVMdQgaz5uhEnNbGsv3d05qVlWjdlnO8b(ATQRns9tmzQ)xX4jdAQvlsxSYF9iptM6)rkV2iUp8SZDNTWGfmVMdQgaz5uhEnNbGsf1Gww3ohqgq3Wsdc4R1QU2i1pbdwW8AoOAaKLtD41Cgak1bqwo1HtgYEYKe3JENCiOhgwAqMViGVwR6iRPlgPGEWa)voMmTiGVwR6iRPlgPAAlQd(6rEPKoFpK05kDpqhYE6OifDbGKwyWcMxZbvdGSCQdVMZaqPoaYYPoCcdggSmdBr84wrVWwyD7s6n4rVto22JhEnhgSG51Cqf0JBf9cutBtdjjbHC015uJblyEnhub94wrVmauQ6EGoh6DbozyPbXMrUg0NQPTPHKKGqo66CQvnTf1bFbk7mDNTs7HKoxThokQRBNd9P3u0fasAHblyEnhub94wrVmauQOg0Y625aYa6gwAqaFTw11gP(jyWcMxZbvqpUv0ldaL6ailN6WjdlnO8b(ATs3tw0Xt(siP(jP9qsNR09KfD8KVesk6cajTWGfmVMdQGECROxgakvDpqNd9UaNmS0G6)vmEYGMA1I0fR8xM)ihd8qsNR6)vmE4oD)WR5u0fasALPgnfmybZR5GkOh3k6LbGsv3d0HSNokYWsdc4R1kWlPSUD(wWqvhP(jP7)rkV2iUpCJixq7SfgSG51Cqf0JBf9YaqPoaYYPoCYWsdQ)xX4jdAQvlsxSYZ18SZXapK05Q(FfJhUt3p8AofDbGKwzQrtbdwW8AoOc6XTIEzaOu19aDo07cCcdwW8AoOc6XTIEzaOurn9XhnhDDo1yWcMxZbvqpUv0ldaLA0S4iUpDtNlqGjetyC258q4cxiaa]] )
    

end
