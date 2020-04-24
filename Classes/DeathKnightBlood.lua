-- DeathKnightBlood.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DEATHKNIGHT' then
    local spec = Hekili:NewSpecialization( 250 )

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

            if state.talent.rune_strike.enabled then state.gainChargeTime( "rune_strike", amount ) end

            if state.azerite.eternal_rune_weapon.enabled and state.buff.dancing_rune_weapon.up then
                if state.buff.dancing_rune_weapon.expires - state.buff.dancing_rune_weapon.applied < state.buff.dancing_rune_weapon.duration + 5 then
                    state.buff.dancing_rune_weapon.expires = min( state.buff.dancing_rune_weapon.applied + state.buff.dancing_rune_weapon.duration + 5, state.buff.dancing_rune_weapon.expires + ( 0.5 * amount ) )
                    state.buff.eternal_rune_weapon.expires = min( state.buff.dancing_rune_weapon.applied + state.buff.dancing_rune_weapon.duration + 5, state.buff.dancing_rune_weapon.expires + ( 0.5 * amount ) )
                end
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

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower )

    local spendHook = function( amt, resource )
        if amt > 0 and resource == "runic_power" and talent.red_thirst.enabled then
            cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - amt / 10 )
        end
    end

    spec:RegisterHook( "spend", spendHook )


    -- Talents
    spec:RegisterTalents( {
        heartbreaker = 19165, -- 221536
        blooddrinker = 19166, -- 206931
        rune_strike = 19217, -- 210764

        rapid_decomposition = 19218, -- 194662
        hemostasis = 19219, -- 273946
        consumption = 19220, -- 274156

        foul_bulwark = 19221, -- 206974
        ossuary = 22134, -- 219786
        tombstone = 22135, -- 219809

        will_of_the_necropolis = 22013, -- 206967
        antimagic_barrier = 22014, -- 205727
        rune_tap = 22015, -- 194679

        grip_of_the_dead = 19227, -- 273952
        tightening_grasp = 19226, -- 206970
        wraith_walk = 19228, -- 212552

        voracious = 19230, -- 273953
        bloodworms = 19231, -- 195679
        mark_of_blood = 19232, -- 206940

        purgatory = 21207, -- 114556
        red_thirst = 21208, -- 205723
        bonestorm = 21209, -- 194844
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3468, -- 214027
        gladiators_medallion = 3467, -- 208683
        relentless = 3466, -- 196029

        antimagic_zone = 3434, -- 51052
        blood_for_blood = 607, -- 233411
        dark_simulacrum = 3511, -- 77606
        death_chain = 609, -- 203173
        decomposing_aura = 3441, -- 199720
        heartstop_aura = 3438, -- 199719
        last_dance = 608, -- 233412
        murderous_intent = 841, -- 207018
        necrotic_aura = 3436, -- 199642
        strangulate = 206, -- 47476
        unholy_command = 204, -- 202727
        walking_dead = 205, -- 202731
    } )


    -- Auras
    spec:RegisterAuras( {
        antimagic_shell = {
            id = 48707,
            duration = function () return ( azerite.runic_barrier.enabled and 1 or 0 ) + ( talent.antimagic_barrier.enabled and 6.5 or 5 ) * ( ( level < 116 and equipped.acherus_drapes ) and 2 or 1 ) end,
            max_stack = 1,
        },
        asphyxiate = {
            id = 108194,
            duration = 4,
            max_stack = 1,
        },
        blooddrinker = {
            id = 206931,
            duration = 3,
            max_stack = 1,
        },        
        blood_plague = {
            id = 55078,
            duration = 24, -- duration is capable of going to 32s if its reapplied before the first wears off
            type = "Disease",
            max_stack = 1,
        },
        blood_shield = {
            id = 77535,
            duration = 10,
            max_stack = 1,
        },
        bone_shield = {
            id = 195181,
            duration = 30,
            max_stack = 10,
        },
        bonestorm = {
            id = 194844,
        },
        crimson_scourge = {
            id = 81141,
            duration = 15,
            max_stack = 1,
        },
        dark_command = {
            id = 56222,
            duration = 3,
            max_stack = 1,
        },
        dancing_rune_weapon = {
            id = 81256,
            duration = 8,
            max_stack = 1,
        },
        death_and_decay = {
            id = 43265,
            duration = 10,
        },
        death_grip = {
            id = 51399,
            duration = 3,
        },
        deaths_advance = {
            id = 48265,
            duration = 8,
            max_stack = 1,
        },
        grip_of_the_dead = {
            id = 273984,
            duration = 10,
            max_stack = 10,
        },
        heart_strike = {
            id = 206930, -- slow debuff heart strike applies
            duration = 8,
            max_stack = 1,
        },
        hemostasis = {
            id = 273947,
            duration = 15,
            max_stack = 5,
            copy = "haemostasis"
        },
        icebound_fortitude = {
            id = 48792,
            duration = 8,
            max_stack = 1,
        },
        mark_of_blood = {
            id = 206940,
            duration = 15,
            max_stack = 1,
        },
        on_a_pale_horse = {
            id = 51986,
        },
        ossuary = {
            id = 219788,
            duration = 0, -- duration is persistent when boneshield stacks => 5
            max_stack = 1,
        },
        path_of_frost = {
            id = 3714,
            duration = 600,
            max_stack = 1,
        },
        perdition = { -- debuff from purgatory getting procced
            id = 123981,
            duration = 240,
            max_stack = 1,
        },
        rune_tap = {
            id = 194679,
            duration = 4,
            max_stack = 1,
        },
        shroud_of_purgatory = {
            id = 116888,
            duration = 3,
            max_stack = 1,
        },
        tombstone = {
            id = 219809,
            duration = 8,
            max_stack = 1,
        },
        unholy_strength = {
            id = 53365,
            duration = 15,
            max_stack = 1,
        },
        wraith_walk = {
            id = 212552,
            duration = 4,
            max_stack = 1,
        },
        vampiric_blood = {
            id = 55233,
            duration = 10,
            max_stack = 1,
        },
        veteran_of_the_third_war = {
            id = 48263,
        },
        voracious = {
            id = 274009,
            duration = 6,
            max_stack = 1,
        },

        -- Azerite Powers
        bloody_runeblade = {
            id = 289349,
            duration = 5,
            max_stack = 1
        },

        bones_of_the_damned = {
            id = 279503,
            duration = 30,
            max_stack = 1,
        },

        cold_hearted = {
            id = 288426,
            duration = 8,
            max_stack = 1
        },

        deep_cuts = {
            id = 272685,
            duration = 15,
            max_stack = 1,
        },

        eternal_rune_weapon = {
            id = 278543,
            duration = 5,
            max_stack = 1,
        },

        march_of_the_damned = {
            id = 280149,
            duration = 15,
            max_stack = 1,
        },


        -- PvP Talents
        antimagic_zone = {
            id = 145629,
            duration = 10,
            max_stack = 1,
        },

        blood_for_blood = {
            id = 233411,
            duration = 12,
            max_stack = 1,
        },

        dark_simulacrum = {
            id = 77606,
            duration = 12,
            max_stack = 1,
        },

        death_chain = {
            id = 203173,
            duration = 10,
            max_stack = 1
        },

        decomposing_aura = {
            id = 228581,
            duration = 3600,
            max_stack = 1,
        },

        focused_assault = {
            id = 206891,
            duration = 6,
            max_stack = 1,
        },

        heartstop_aura = {
            id = 228579,
            duration = 3600,
            max_stack = 1,
        },

        necrotic_aura = {
            id = 214968,
            duration = 3600,
            max_stack = 1,
        },

        strangulate = {
            id = 47476,
            duration = 5,
            max_stack = 1,                
        }, 
    } )


    spec:RegisterGear( "tier19", 138355, 138361, 138364, 138349, 138352, 138358 )
    spec:RegisterGear( "tier20", 147124, 147126, 147122, 147121, 147123, 147125 )
        spec:RegisterAura( "gravewarden", {
            id = 242010,
            duration = 10,
            max_stack = 0
        } )

    spec:RegisterGear( "tier21", 152115, 152117, 152113, 152112, 152114, 152116 )

    spec:RegisterGear( "acherus_drapes", 132376 )
    spec:RegisterGear( "cold_heart", 151796 ) -- chilled_heart stacks NYI
    spec:RegisterGear( "consorts_cold_core", 144293 )
    spec:RegisterGear( "death_march", 144280 )
    -- spec:RegisterGear( "death_screamers", 151797 )
    spec:RegisterGear( "draugr_girdle_of_the_everlasting_king", 132441 )
    spec:RegisterGear( "koltiras_newfound_will", 132366 )
    spec:RegisterGear( "lanathels_lament", 133974 )
    spec:RegisterGear( "perseverance_of_the_ebon_martyr", 132459 )
    spec:RegisterGear( "rethus_incessant_courage", 146667 )
    spec:RegisterGear( "seal_of_necrofantasia", 137223 )
    spec:RegisterGear( "service_of_gorefiend", 132367 )
    spec:RegisterGear( "shackles_of_bryndaor", 132365 ) -- NYI (Death Strike heals refund RP...)
    spec:RegisterGear( "skullflowers_haemostasis", 144281 )
        spec:RegisterAura( "haemostasis", {
            id = 235559,
            duration = 3600,
            max_stack = 5
        } )

    spec:RegisterGear( "soul_of_the_deathlord", 151740 )
    spec:RegisterGear( "soulflayers_corruption", 151795 )
    spec:RegisterGear( "the_instructors_fourth_lesson", 132448 )
    spec:RegisterGear( "toravons_whiteout_bindings", 132458 )
    spec:RegisterGear( "uvanimor_the_unbeautiful", 137037 )


    spec:RegisterHook( "reset_precast", function ()
        local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up then
            summonPet( "controlled_undead", control_expires - now )
        end
    end )

    spec:RegisterStateExpr( "save_blood_shield", function ()
        return settings.save_blood_shield
    end )


    -- Abilities
    spec:RegisterAbilities( {
        antimagic_shell = {
            id = 48707,
            cast = 0,
            cooldown = function () return talent.antimagic_barrier.enabled and 45 or 60 end,
            gcd = "off",

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

            pvptalent = "antimagic_zone",

            handler = function ()
                applyBuff( "antimagic_zone" )
            end,
        },


        asphyxiate = {
            id = 221562,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 538558,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,            

            handler = function ()
                interrupt()
                applyDebuff( "target", "asphyxiate" )
            end,
        },


        blood_boil = {
            id = 50842,
            cast = 0,
            charges = 2,
            cooldown = 7.5,
            recharge = 7.5,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 237513,

            handler = function ()
                applyDebuff( "target", "blood_plague" )
                active_dot.blood_plague = active_enemies

                if talent.hemostasis.enabled then
                    applyBuff( "hemostasis", 15, min( 5, active_enemies) )
                end

                if level < 116 and equipped.skullflowers_haemostasis then
                    applyBuff( "haemostasis" )
                end

                if level < 116 and set_bonus.tier20_2pc == 1 then
                    applyBuff( "gravewarden" )
                end
            end,
        },


        blood_for_blood = {
            id = 233411,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.15,
            spendType = "health",

            startsCombat = false,
            texture = 1035037,

            pvptalent = "blood_for_blood",

            handler = function ()
                applyBuff( "blood_for_blood" )
            end,
        },


        blooddrinker = {
            id = 206931,
            cast = 3,
            cooldown = 30,
            channeled = true,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 838812,

            talent = "blooddrinker",

            start = function ()
                applyDebuff( "target", "blooddrinker" )
            end,
        },


        bonestorm = {
            id = 194844,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0,
            spendType = "runic_power",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 342917,

            talent = "bonestorm",

            handler = function ()
                local cost = min( runic_power.current, 100 )
                spend( cost, "runic_power" )
                applyBuff( "bonestorm", cost / 10 )
            end,
        },


        consumption = {
            id = 274156,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 1121487,

            talent = "consumption",

            handler = function ()                
            end,
        },


        control_undead = {
            id = 111673,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 237273,

            handler = function ()
            end,
        },


        dancing_rune_weapon = {
            id = 49028,
            cast = 0,
            cooldown = function () return pvptalent.last_dance.enabled and 60 or 120 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135277,

            handler = function ()
                applyBuff( "dancing_rune_weapon" )
                if azerite.eternal_rune_weapon.enabled then applyBuff( "dancing_rune_weapon" ) end
            end,
        },


        dark_command = {
            id = 56222,
            cast = 0,
            cooldown = 8,
            gcd = "off",

            startsCombat = true,
            texture = 136088,

            nopvptalent = "murderous_intent",

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


        death_and_decay = {
            id = 43265,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return buff.crimson_scourge.up and 0 or 1 end,
            spendType = "runes",

            startsCombat = true,
            texture = 136144,

            handler = function ()
                applyBuff( "death_and_decay" )
                removeBuff( "crimson_scourge" )
            end,
        },


        --[[ death_gate = {
            id = 50977,
            cast = 4,
            cooldown = 60,
            gcd = "spell",

            spend = -10,
            spendType = "runic_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 135766,

            handler = function ()
            end,
        }, ]]


        death_chain = {
            id = 203173,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1390941,

            pvptalent = "death_chain",

            handler = function ()
                applyDebuff( "target", "death_chain" )
                active_dot.death_chain = min( 3, active_enemies )
            end,
        },


        death_grip = {
            id = 49576,
            cast = 0,
            charges = function () return pvptalent.unholy_command.enabled and 2 or 1 end,
            cooldown = 15,
            recharge = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 237532,

            handler = function ()
                applyDebuff( "target", "death_grip" )
                setDistance( 5 )
            end,
        },


        death_strike = {
            id = 49998,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( talent.ossuary.enabled and buff.bone_shield.stack >= 5 ) and 40 or 45 end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237517,

            handler = function ()
                applyBuff( "blood_shield" ) -- gain absorb shield
                gain( 0.075 * health.max * ( 1.2 * buff.haemostasis.stack ) * ( 1.08 * buff.hemostasis.stack ), "health" )
                removeBuff( "haemostasis" )
                removeBuff( "hemostasis" )

                if talent.voracious.enabled then applyBuff( "voracious" ) end
            end,
        },


        deaths_advance = {
            id = 48265,
            cast = 0,
            cooldown = function () return azerite.march_of_the_damned.enabled and 40 or 45 end,
            gcd = "spell",

            startsCombat = false,
            texture = 237561,

            handler = function ()
                applyBuff( "deaths_advance" )
            end,
        },


        deaths_caress = {
            id = 195292,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 1376743,

            handler = function ()
                applyDebuff( "target", "blood_plague" )
            end,
        },


        gorefiends_grasp = {
            id = 108199,
            cast = 0,
            cooldown = function () return talent.tightening_grasp.enabled and 90 or 120 end,
            gcd = "spell",

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 538767,

            handler = function ()
            end,
        },


        heart_strike = {
            id = 206930,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 135675,

            handler = function ()                
                applyDebuff( "target", "heart_strike" )
                local targets = min( active_enemies, buff.death_and_decay.up and 5 or 2 )

                removeBuff( "blood_for_blood" )

                if azerite.deep_cuts.enabled then applyDebuff( "target", "deep_cuts" ) end

                if level < 116 and equipped.service_of_gorefiend then cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - 2 ) end
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


        mark_of_blood = {
            id = 206940,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = 30,
            spendType = "runic_power",

            startsCombat = true,
            texture = 132205,

            talent = "mark_of_blood",

            handler = function ()
                applyDebuff( "target", "mark_of_blood" )
            end,
        },


        marrowrend = {
            id = 195182,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 2,
            spendType = "runes",

            startsCombat = true,
            texture = 1376745,

            handler = function ()
                applyBuff( "bone_shield", 30, buff.bone_shield.stack + ( buff.dancing_rune_weapon.up and 6 or 3 ) )
                if azerite.bones_of_the_damned.enabled then applyBuff( "bones_of_the_damned" ) end
            end,
        },


        mind_freeze = {
            id = 47528,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = 0,
            spendType = "runic_power",

            startsCombat = true,
            texture = 237527,

            toggle = "interrupts",
            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        murderous_intent = {
            id = 207018,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 136088,

            pvptalent = "murderous_intent",

            handler = function ()
                applyDebuff( "target", "focused_assault" )
            end,
        },


        path_of_frost = {
            id = 3714,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 237528,

            handler = function ()
                applyBuff( "path_of_frost" )
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


        rune_strike = {
            id = 210764,
            cast = 0,
            charges = 2,
            cooldown = 60,
            recharge = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 237518,

            talent = "rune_strike",

            handler = function ()
                gain( 1, "runes" )
            end,
        },


        rune_tap = {
            id = 194679,
            cast = 0,
            charges = 2,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 237529,

            talent = "rune_tap",

            handler = function ()
                applyBuff( "rune_tap" )
            end,
        },


        --[[ runeforging = {
            id = 53428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 237523,

            handler = function ()
            end,
        }, ]]


        strangulate = {
            id = 47476,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0,
            spendType = "runes",

            toggle = "interrupts",
            pvptalent = "strangulate",
            interrupt = true,

            startsCombat = true,
            texture = 136214,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                applyDebuff( "target", "strangulate" )
            end,
        },


        tombstone = {
            id = 219809,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132151,

            talent = "tombstone",
            buff = "bone_shield",

            handler = function ()
                local bs = min( 5, buff.bone_shield.stack )

                removeStack( "bone_shield", bs )                
                gain( 6 * bs, "runic_power" )

                if set_bonus.tier21_2pc == 1 then
                    cooldown.dancing_rune_weapon.expires = max( 0, cooldown.dancing_rune_weapon.expires - ( 3 * bs ) )
                end

                applyBuff( "tombstone" )
            end,
        },


        vampiric_blood = {
            id = 55233,
            cast = 0,
            cooldown = function () return 90 * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) end,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136168,

            handler = function ()
                applyBuff( "vampiric_blood" )
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]


        wraith_walk = {
            id = 212552,
            cast = 4,
            fixedCast = true,
            channeled = true,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
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
        damageExpiration = 8,

        potion = "potion_of_unbridled_fury",

        package = "Blood",        
    } )


    spec:RegisterSetting( "save_blood_shield", true, {
        name = "Save |T237517:0|t Blood Shield",
        desc = "If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r) will try to avoid letting your |T237517:0|t Blood Shield fall off during lulls in damage.",
        type = "toggle",
        width = 1.5
    } )   


    spec:RegisterPack( "Blood", 20200208.2, [[dSerLaqiOkEesrxIskLnrvPpHuWOGQQtbvLvHuXRGknlKs3cazxk8lOIHbuogGSmKQEgLunnKcDnQk2gqfFdaQXbG6CaqwhuLY8evCpL0(OKCqkPyHaXdHQunrGkPlcaYgba1hbQenskPeojaGvsjEjLuQMjLusDtaG2jqAPusj5PkAQaQVsjLO9QQ)sLbt4WKwSs9yIMmIlJAZi5ZuLrReNwQvduj8ArvZwKBlk7w43QmCk1XbQulh0ZPy6sUou2oqvFhGgpuLCErLwpsLMpvv7hYpqpW)KOf)Gspy0dgy0dgapadabeq04pRCT5FARY8Qh)ZqZ4Fcs6oYpT1CtNsEG)P5WGs(NZodlPvFbEhQu1p3yDQaaIF)tIw8dk9GrpyGrpya8amaeqarpa(NgBw(GsVpG9ZLMq443)KWg5pPjsas6ocsaUYATGew7r7Tuil0ejwQY2G3WbhVUwW2d5LHJPZWsA1xiHkvHJPZKil0ejaG5netH5IeamTib9Grpyilil0ejW7lA4Xg8gYcnrcacjSgcHjibayheKaagYmD5bYcnrcacjSgcHjibayxTNw9firQn1azHMibaHewdHWeKGgMk4zKaK0DeKyU0CIGewZ2CWnnGeND1xmqwOjsaqibae45ajYoiJeQNhKnMg8CkxKWJdgQfJeGCbJeZLMteKWuQmVz8ZuBkZd8pZ6Q90QV4b(bfOh4FYHUtm5b5NsyxmS1FUWAQwg2YcjYbj8bmKWVFKa)ibEqcp4HzJe(IelSMQLHTSqICqcWbCqc89tvw9f)e8AMDdBPBNUJ81dk9pW)KdDNyYdYpLWUyyR)Sd5L1HNJOzQh78XGewTIeGn8bjOdsSWAQwgzkEHe(9Je4hjWds4bpmBKWxKOd5L1HNJOzQh78XGewTIeGnO3hKGoiXcRPAzKP4fsGVFQYQV4NewRfNPGDE(RhuR)a)to0DIjpi)uc7IHT(tJcE2Tt3rCMLMteKWxKOd5L1HNJOzQh78XGewHeGHe(IeBmkQXoDhXzwAorgy2iHViXgJIASt3rCMLMtKbKZ0omiroibqdFqc6GeEsYpvz1x8tcR1IZuWop)1dkn(a)to0DIjpi)uc7IHT(Zfwt1YWwwiroiHpGHeaesGFKGEWqc6GeBmkQXoDhXzwAorgy2ib((PkR(IF2sEFybXrDWQlmc)1x)0uAqui5b(bfOh4FYHUtm5b5NsyxmS1FcXIw6Spaz4GWuTSlKiNvKaiWqcFrc8Je4bjknXrn2xWM6Gzdo0DIjiHF)ibEqc5DjYbym2xWM6GzdiRKCrc)(rIngf1GOHSdphelyhGSAFXaZgjW3pvz1x8tcR1IZuWop)1dk9pW)KdDNyYdYpLWUyyR)epiXgJIAq0q2HNdIfSdqwTVyGz)tvw9f)CNUJqGDKNHF9GA9h4FYHUtm5b5NsyxmS1FUXOOg7lyNzP5eza5mTddsKdsa0WhKGoiHNKmy8ILyfJe(9Je4hj2yuuJ9fSZS0CImGCM2HbjYzfjGybpQoJD15Sos43psSXOOg7lyNzP5eza5mTddsKZksGFKWtsqcCrc5DjYbym2P7ieyh5z4aYkjxKGoirPjoQXoDhHa7ipdhCO7etqc6Ge0Je4dj87hj2yuuJ9fSZS0CImmLkZJe5GewhjWhs4lsaXIw6Spaz4GWuTSlKWQvKGEW(PkR(IFMPq4biKdYxpO04d8p5q3jM8G8tjSlg26pXdsSXOOgenKD45Gyb7aKv7lgy2)uLvFXpxyfwo2y4qYF9G6Zd8p5q3jM8G8tjSlg26pLlk0JnokOkR(cnHewTIeanayKWxKa)iXgJIASWzNPutBgMsL5rICwrc8Je(GeaesyS5uYvk0JlZyNUJ42xNqc8He(9JegBoLCLc94Ym2P7iU91jKWkKGEKaF)uLvFXp3P7iU91PVEqbNh4FYHUtm5b5NsyxmS1FUXOOg7lyNzP5ezykvMhjYbjahKWxKO0eh14mgmfM7GdDNycs4lsaXIw6Spaz4GWuTSlKWQvKaiF(PkR(IFMPq4biKdYxpOa4h4FYHUtm5b5NsyxmS1FcXIw6Spazisy1ksaeyGHe(Ie4bj2yuudIgYo8CqSGDaYQ9fdm7FQYQV4N7lytDWSVEqb4h4FYHUtm5b5NsyxmS1FcXIw6Spaz4GWuTSlKiNvKa)ibq(Ge4IeBmkQbrdzhEoiwWoaz1(IbMnsqhKWhKaxKWyZPKRuOhxMXcRWYzkyNNrc6GeLM4OglScRnK18mCWHUtmbjOdsqpsGpKWVFKO6m2vNJ0msKdsaey)uLvFXpjSwlotb788xpOaOh4FYHUtm5b5NsyxmS1FAS5uYvk0JlZGWAT40G4iSuZfjSAfjS(pvz1x8tcR1ItdIJWsn3VEqbcSh4FYHUtm5b5NsyxmS1FIFKqUOqp24OGQS6l0esy1ksa0aGrc)(rIngf1GOHSdphelyhGSAFXaZgjWhs4lsaXcEuDg7QZzDKWQvKWts(PkR(IFcXc2zkyNN)6bfiGEG)jh6oXKhKFkHDXWw)5gJIAq0q2HNdIfSdqwTVyGzJe(9JeqSGhvNXU6C0isKds4jj)uLvFXpxyfwotb788xpOar)d8p5q3jM8G8tjSlg26p3yuudIgYo8CqSGDaYQ9fdm7FQYQV4N70De3(60xpOaz9h4FYHUtm5b5NsyxmS1FUXOOgsyNzUWzKhg0Jhy2iHF)irPjoQbuTBIJWYlZ(mD1xm4q3jMGe(9JegBoLCLc94YmiSwloniocl1CrcRwrc6)PkR(IFsyTwCAqCewQ5(1dkq04d8pvz1x8t5fgSm7QV4NCO7etEq(6bfiFEG)PkR(IFUt3rC7Rt)KdDNyYdYxpOabopW)KdDNyYdYpLWUyyR)eIf8O6m2vNZ6iroiHNKGe(9JeBmkQX(c2zwAorgMsL5rcRqcW5NQS6l(5cRWYzkyNN)6bfia8d8p5q3jM8G8ZqZ4F6bVWZ4SHDMMCq1J)PkR(IF6bVWZ4SHDMMCq1J)6bfia(b(NQS6l(jelyNPGDE(NCO7etEq(6bfia0d8p5q3jM8G8tjSlg26pHyrlD2hGmCqyQw2fsyfsqpy)uLvFXpvOud2vheYr91x)KWukwQEGFqb6b(NQS6l(zwhehfKz6Y)KdDNyYdYxpO0)a)to0DIjpi)uc7IHT(t5DjYbymiAi7WZbXc2biR2xmGSsYfj8fjWpsGhKqExICagJD6ocb2rEgoGSsYfj87hjWdsuAIJASt3riWoYZWbh6oXeKaF)uLvFXp3P7iokmyUF9GA9h4FQYQV4NBgAyy(o8(jh6oXKhKVEqPXh4FYHUtm5b5NsyxmS1FQYQbp74GZA2GewTIe0Je(9JeqSGrICqcGqcFrciw0sN9bidheMQLDHewHeGdy)uLvFXpvOud2zJLm8xpO(8a)to0DIjpi)uc7IHT(Zngf1alwUuUotb5WRwgy2)uLvFXptT3szCGlWiEzCuF9GcopW)uLvFXp1qYMcQjNutPFYHUtm5b5Rhua8d8pvz1x8tQgY70DKFYHUtm5b5Rhua(b(NQS6l(5w9ChLRGTmV5NCO7etEq(6bfa9a)to0DIjpi)uc7IHT(t5DjYbymiAi7WZbXc2biR2xmGCM2HbjScjaqG9tvw9f)eZWUU4mZxpOab2d8p5q3jM8G8ZqZ4Fcv6sWI8g3U9CqM42yvDXpvz1x8tOsxcwK342TNdYe3gRQl(6bfiGEG)jh6oXKhKFgAg)ZmgY5Rf14O0W7NQS6l(zgd581IACuA491dkq0)a)to0DIjpi)uLvFXpvZc41GnoOs3d6Khut)uc7IHT(tcVXOOgqLUh0jpOMCeEJrrnihGXpdnJ)PAwaVgSXbv6EqN8GA6RhuGS(d8p5q3jM8G8tvw9f)unlGxd24GkDpOtEqn9tjSlg26plf6X1yH1uTmSLfsKdsyDGqcFrcgCJ122mzqG9EN6WZ1rE7J8ZqZ4FQMfWRbBCqLUh0jpOM(6bfiA8b(NCO7etEq(PkR(IFQMfWRbBCqLUh0jpOM(Pe2fdB9NBmkQbrdzhEoiwWoaz1(IbMns4lsq4ngf1aQ09Go5b1KJWBmkQbMns4lsGhKGb3yTTntgeyV3Po8CDK3(i)m0m(NQzb8AWghuP7bDYdQPVEqbYNh4FYHUtm5b5NsyxmS1FUXOOgenKD45Gyb7aKv7lgy2)uLvFXpTVQV4RhuGaNh4FYHUtm5b5NsyxmS1FIhKO0eh1yNUJqGDKNHdo0DIjiHF)ibEqc5DjYbym2P7ieyh5z4aYkj3FQYQV4NenKD45Gyb7aKv7l(6bfia8d8p5q3jM8G8tjSlg26p3yuuJ9fSZS0CImmLkZJewTIea4FQYQV4N1LTn1f8xpOabWpW)KdDNyYdYpLWUyyR)Sd5L1HNJOzQh78XGewHeG9tvw9f)uQPKtLvFHl1M6NP2uUqZ4FM1v7PvFXxpOabGEG)jh6oXKhKFQYQV4NsnLCQS6lCP2u)m1MYfAg)ttPbrHKV(6N2qwEzBTEGFqb6b(NCO7etEq(6bL(h4FYHUtm5b5RhuR)a)to0DIjpiF9GsJpW)KdDNyYdYxpO(8a)tvw9f)0(Q(IFYHUtm5b5RV(6NGNHM(Ihu6bJEWaJEWa4FcOcJo8m)0AP1yTcuaaqbxI3qcKa4fgj6m7dwib1brcAWuAquiHgqcidUXAitqcZLXiHIvxMwmbjKlA4XMbYI16oyKaGXBibE)cWZWIjibnuk0JRbqJQZyxDosZ0asuhsqdvNXU6CKMPbKa)aHx4BGSGSaaKzFWIjibnIeQS6lqIuBkZaz5N2WJQt8pPjsas6ocsaUYATGew7r7Tuil0ejwQY2G3WbhVUwW2d5LHJPZWsA1xiHkvHJPZKil0ejaG5netH5IeamTib9Grpyilil0ejW7lA4Xg8gYcnrcacjSgcHjibayheKaagYmD5bYcnrcacjSgcHjibayxTNw9firQn1azHMibaHewdHWeKGgMk4zKaK0DeKyU0CIGewZ2CWnnGeND1xmqwOjsaqibae45ajYoiJeQNhKnMg8CkxKWJdgQfJeGCbJeZLMteKWuQmVzGSGSqtKaacVyjwXeKyZuhKrc5LT1cj2SxhMbsynsjBxgKiUaGwuygfwcjuz1xyqIls5oqwuz1xyg2qwEzBTwPsQjpYIkR(cZWgYYlBRfUR4qDhbzrLvFHzydz5LT1c3vCumVmokT6lqwOjsmd12SCfsa1MGeBmkkMGeMsldsSzQdYiH8Y2AHeB2RddsObbjSHmazFv1Hhs0gKGCbpqwuz1xyg2qwEzBTWDfhtO2MLRCMsldYIkR(cZWgYYlBRfUR4yFvFbYcYcnrcai8ILyftqcg8mmxKO6mgjQfgjuzDqKOniHcETt6oXdKfvw9fM1SoiokiZ0Lrwuz1xyWDfND6oIJcdMlTn1Q8Ue5amgenKD45Gyb7aKv7lgqwj56l(XJ8Ue5amg70DecSJ8mCazLKRF)4P0eh1yNUJqGDKNHdo0DIj4dzrLvFHb3vC2m0WW8D4HSOYQVWG7kokuQb7SXsgM2MAvLvdE2XbN1SXQv697hIfCoa5lelAPZ(aKHdct1YUScCadzrLvFHb3vCsT3szCGlWiEzCu02uRBmkQbwSCPCDMcYHxTmWSrwuz1xyWDfhnKSPGAYj1uczrLvFHb3vCOAiVt3rqwuz1xyWDfNT65okxbBzEdYIkR(cdUR4GzyxxCMH2MAvExICagdIgYo8CqSGDaYQ9fdiNPDyScabgYIkR(cdUR4GzyxxCgTHMXRqLUeSiVXTBphKjUnwvxGSOYQVWG7koyg21fNrBOz8Agd581IACuA4HSOYQVWG7koyg21fNrBOz8QAwaVgSXbv6EqN8GAI2MALWBmkQbuP7bDYdQjhH3yuudYbyGSOYQVWG7koyg21fNrBOz8QAwaVgSXbv6EqN8GAI2MATuOhxJfwt1YWww5yDG8Lb3yTTntgeyV3Po8CDK3(iilQS6lm4UIdMHDDXz0gAgVQMfWRbBCqLUh0jpOMOTPw3yuudIgYo8CqSGDaYQ9fdmBFj8gJIAav6EqN8GAYr4ngf1aZ2x8WGBS22MjdcS37uhEUoYBFeKfvw9fgCxXX(Q(cABQ1ngf1GOHSdphelyhGSAFXaZgzrLvFHb3vCiAi7WZbXc2biR2xqBtTINstCuJD6ocb2rEgo4q3jM43pEK3LihGXyNUJqGDKNHdiRKCrwuz1xyWDfN6Y2M6cM2MADJrrn2xWoZsZjYWuQmVvRayKfvw9fgCxXrQPKtLvFHl1MI2qZ41SUApT6lOTPw7qEzD45iAM6XoFmwbgYIkR(cdUR4i1uYPYQVWLAtrBOz8QP0GOqcYcYIkR(cZiRR2tR(IvWRz2nSLUD6ocTn16cRPAzylRC8bm)(XpE8GhMTVlSMQLHTSYbCah8HSqtKaaiKxwhEibrZupgjGm4gRHCghfs0gKGEFS2qIJcjYu8cjwynvliH5shTiHpGzTHehfsKP4fsSWAQwqIoqcfj8GhM9azrLvFHzK1v7PvFbUR4qyTwCMc25zABQ1oKxwhEoIMPESZhJvRGn8HolSMQLrMIx(9JF84bpmBF7qEzD45iAM6XoFmwTc2GEFOZcRPAzKP4f(qwOjsaUEbnuirIlKqdKGXR2uD4HeGKUJGeZLMteKGap7bYIkR(cZiRR2tR(cCxXHWAT4mfSZZ02uRgf8SBNUJ4mlnNi(2H8Y6WZr0m1JD(yScmF3yuuJD6oIZS0CImWS9DJrrn2P7ioZsZjYaYzAhMCaA4dD8KeKfvw9fMrwxTNw9f4UItl59Hfeh1bRUWimTn16cRPAzylRC8bmac)0dgD2yuuJD6oIZS0CImWSXhYcYIkR(cZWuAquizLWAT4mfSZZ02uRqSOLo7dqgoimvl7kNvGaZx8JNstCuJ9fSPoy2GdDNyIF)4rExICagJ9fSPoy2aYkjx)(3yuudIgYo8CqSGDaYQ9fdmB8HSOYQVWmmLgefsWDfND6ocb2rEgsBtTINngf1GOHSdphelyhGSAFXaZgzrLvFHzyknikKG7kozkeEac5GqBtTUXOOg7lyNzP5eza5mTdtoan8HoEsYGXlwIvSF)4FJrrn2xWoZsZjYaYzAhMCwHybpQoJD15SUF)BmkQX(c2zwAorgqot7WKZk(9KeCL3LihGXyNUJqGDKNHdiRKCPtPjoQXoDhHa7ipdhCO7etOd94ZV)ngf1yFb7mlnNidtPY85yD85lelAPZ(aKHdct1YUSALEWqwuz1xygMsdIcj4UIZcRWYXgdhsM2MAfpBmkQbrdzhEoiwWoaz1(IbMnYIkR(cZWuAquib3vC2P7iU91jABQv5Ic9yJJcQYQVqtwTc0aG9f)BmkQXcNDMsnTzykvMpNv87dazS5uYvk0JlZyNUJ42xNWNF)gBoLCLc94Ym2P7iU91jROhFilQS6lmdtPbrHeCxXjtHWdqiheABQ1ngf1yFb7mlnNidtPY85ao(wAIJACgdMcZDWHUtmXxiw0sN9bidheMQLDz1kq(GSOYQVWmmLgefsWDfN9fSPoygTn1kelAPZ(aKHwTceyG5lE2yuudIgYo8CqSGDaYQ9fdmBKfvw9fMHP0GOqcUR4qyTwCMc25zABQviw0sN9bidheMQLDLZk(bYhC3yuudIgYo8CqSGDaYQ9fdmB64dUgBoLCLc94Ymwyfwotb78mDknXrnwyfwBiR5z4GdDNycDOhF(9xk0JRbqJQZyxDosZ5aeyilQS6lmdtPbrHeCxXHWAT40G4iSuZL2MA1yZPKRuOhxMbH1AXPbXryPMRvRwhzrLvFHzyknikKG7koqSGDMc25zABQv8lxuOhBCuqvw9fAYQvGgaSF)BmkQbrdzhEoiwWoaz1(IbMn(8fIf8O6m2vNZ6wT6jjilQS6lmdtPbrHeCxXzHvy5mfSZZ02uRBmkQbrdzhEoiwWoaz1(IbMTF)qSGhvNXU6C0yoEscYIkR(cZWuAquib3vC2P7iU91jABQ1ngf1GOHSdphelyhGSAFXaZgzrLvFHzyknikKG7koewRfNgehHLAU02uRBmkQHe2zMlCg5Hb94bMTF)LM4Ogq1UjoclVm7Z0vFXGdDNyIF)gBoLCLc94YmiSwloniocl1CTALEKfvw9fMHP0GOqcUR4iVWGLzx9filQS6lmdtPbrHeCxXzNUJ42xNqwuz1xygMsdIcj4UIZcRWYzkyNNPTPwHybpQoJD15SEoEsIF)BmkQX(c2zwAorgMsL5TcCqwuz1xygMsdIcj4UIdMHDDXz0gAgV6bVWZ4SHDMMCq1Jrwuz1xygMsdIcj4UIdelyNPGDEgzrLvFHzyknikKG7kokuQb7Qdc5OOTPwHyrlD2hGmCqyQw2Lv0d2pvSA5G)C2z4DKaxKWAbNVt9xF9p]] )

end