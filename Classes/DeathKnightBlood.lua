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

            usable = function () return target.casting end,
            readyTime = function () return debuff.casting.up and ( debuff.casting.remains - 0.5 ) or 3600 end,
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


    spec:RegisterPack( "Blood", 20200208, [[dSe5KaqiOkEesrxIcLYMef9jKcgfuvDkOQSkku9kOsZcP0TakSlf(fuXWashdOAziv9mKkMMsrDnrHTPuKVbuuJtPqNdQsSoOkP5jk19us7Jc5GifAHkv9qOkvteOiDrLcYgvkO(iqr0iPqjCsLcyLuWlPqPAMuOK6MkfODcelLcLKNQOPQu5RuOeTxv9xQmychM0Ib8yIMmIlJAZi5ZuLrReNwQvdueETOQzlYTPQ2TWVvz4u0XHQuwoONtPPl56qz7aL(UsPXtHIZlkz9ivA(Ik7hYp4)UFs0IFqOhu6bfu6bDJdq34M3mO05NvwM8pnvzE1J)zO(8p3NUJ8ttnR0PKF3pThguY)C2(yjT6lW7qLQ(jawNQnq8a)KOf)GqpO0dkO0d6ghGUXntNn)tRjlFqOpdq)5stiC8a)KWw5pPjsSpDhbjatzTwqcJ9O9wkKbAIelvzAXR4GJxxlyad55JJT9XsA1xiHkvHJT9Lid0ej2WmaetHzHeBKwKGEqPhuKbKbAIe49fn8ylEfzGMibyGe0iHWeKyd2bbj2WqMPlpqgOjsagibnsimbj2GD1EA1xGeP2wdKbAIeGbsqJectqcAyQGLrI9P7iiXCP5ebjOra7bbObK4mR(IbYanrcWaj2qGLdKW)GmsOEEq2ABWYPSqcpoyOwmsS)cgjMlnNiiHTuzE74NP2w2F3p97Q90QV439Ga(V7NCOajM87)Pe2fdB9NlSMQLHPSqISrImafjYLdjWpsGhKWdEyMirMiXcRPAzyklKiBKytBcjW3pvz1x8tWQ(MnSLoG0DKVEqO)39touGet(9)uc7IHT(ZoKNFhEoI6RESldlsy0ksa6idKW4iXcRPAz4RgdsKlhsGFKapiHh8WmrImrIoKNFhEoI6RESldlsy0ksa6G(mqcJJelSMQLHVAmib((PkR(IFsyTwC2c255VEqOZV7NCOajM87)Pe2fdB9NwfSSdiDhXzxAorqImrIoKNFhEoI6RESldlsyesaksKjsaGrrnas3rC2LMtKbMjsKjsaGrrnas3rC2LMtKbK91oSir2ib4JmqcJJeEsYpvz1x8tcR1IZwWop)1dYM)D)KdfiXKF)pLWUyyR)CH1uTmmLfsKnsKbOibyGe4hjOhuKW4ibagf1aiDhXzxAorgyMib((PkR(IF2sg4WcIJ6Gvxye(RV(PT0GOqYV7bb8F3p5qbsm53)tjSlg26pHyrlDM3wgoimvl7cjYEfjahuKitKa)ibEqIstCudGlyBDq)bhkqIjirUCibEqc5DjYTngaxW26G(diRKSqIC5qcamkQbrdzhEoiwWUTSAEXaZejW3pvz1x8tcR1IZwWop)1dc9)UFYHcKyYV)NsyxmS1FIhKaaJIAq0q2HNdIfSBlRMxmWm)PkR(IFcKUJqGDKNHF9GqNF3p5qbsm53)tjSlg26pXpsaGrrnaUGD2LMtKbK91oSir2Ribel4r1(SRohDqIC5qcamkQbWfSZU0CImGSV2HfjYEfjWps4jjibUiH8Ue52gdG0DecSJ8mCazLKfsyCKO0eh1aiDhHa7ipdhCOajMGeghjOhjWhsKlhsaGrrnaUGD2LMtKHTuzEKiBKGoib(qImrciw0sN5TLHdct1YUqcJwrc6b9NQS6l(PVcH3wihKVEq28V7NCOajM87)Pe2fdB9N4bjaWOOgenKD45Gyb72YQ5fdmZFQYQV4NlSclhBTCi5VEqY439touGet(9)uc7IHT(t5Ic9yRJcQYQVqtiHrRib4JnIezIe4hjaWOOglS)zl122HTuzEKi7vKa)irgibyGewtoLCLc94Yoas3rCaxNqc8He5YHewtoLCLc94Yoas3rCaxNqcJqc6rc89tvw9f)eiDhXbCD6RhKn97(jhkqIj)(FkHDXWw)jagf1a4c2zxAorg2sL5rISrInHezIeLM4OgN1IPWSgCOajMGezIeqSOLoZBldheMQLDHegTIeGNXpvz1x8tFfcVTqoiF9GaM)D)KdfiXKF)pLWUyyR)eIfT0zEBzisy0ksaoOGIezIe4bjaWOOgenKD45Gyb72YQ5fdmZFQYQV4NaxW26G(F9GSXF3p5qbsm53)tjSlg26pHyrlDM3wgoimvl7cjYEfjWpsaEgibUibagf1GOHSdphely3wwnVyGzIeghjYajWfjSMCk5kf6XLDSWkSC2c25zKW4irPjoQXcRWcaYAEgo4qbsmbjmosqpsGpKixoKOAF2vNJ0msKnsaoO)uLvFXpjSwloBb788xpi4LF3p5qbsm53)tjSlg26pTMCk5kf6XLDqyTwCAqCewQzHegTIe05NQS6l(jH1AXPbXryPM1xpiGd6V7NCOajM87)Pe2fdB9N4hjKlk0JTokOkR(cnHegTIeGp2isKlhsaGrrniAi7WZbXc2TLvZlgyMib(qImrciwWJQ9zxDo6GegTIeEsYpvz1x8tiwWoBb788xpiGd(V7NCOajM87)Pe2fdB9NayuudIgYo8CqSGDBz18IbMjsKlhsaXcEuTp7QZTzKiBKWts(PkR(IFUWkSC2c255VEqaN(F3p5qbsm53)tjSlg26pbWOOgenKD45Gyb72YQ5fdmZFQYQV4NaP7ioGRtF9GaoD(D)KdfiXKF)pLWUyyR)eaJIAiHTV9cNvEyqpEGzIe5YHeLM4Ogq1SjoclpFZZ2vFXGdfiXeKixoKWAYPKRuOhx2bH1AXPbXryPMfsy0ksq)pvz1x8tcR1ItdIJWsnRVEqaFZ)UFQYQV4NYlSy(MvFXp5qbsm53)1dc4z87(PkR(IFcKUJ4aUo9touGet(9F9Ga(M(D)KdfiXKF)pLWUyyR)eIf8OAF2vNJoir2iHNKGe5YHeayuudGlyNDP5ezylvMhjmcj20pvz1x8ZfwHLZwWop)1dc4G5F3p5qbsm53)Zq95F6bVWZ6mHTVMCq1J)PkR(IF6bVWZ6mHTVMCq1J)6bb8n(7(PkR(IFcXc2zlyNN)jhkqIj)(VEqahV87(jhkqIj)(FkHDXWw)jelAPZ82YWbHPAzxiHrib9G(tvw9f)uHsnyxDqih1xF9tctPyP639Ga(V7NQS6l(PFhehfKz6Y)KdfiXKF)xpi0)7(jhkqIj)(FkHDXWw)P8Ue52gdIgYo8CqSGDBz18IbKvswirMib(rc8GeY7sKBBmas3riWoYZWbKvswirUCibEqIstCudG0DecSJ8mCWHcKycsGVFQYQV4NaP7iokmywF9GqNF3pvz1x8tagAzy(o8(jhkqIj)(VEq28V7NCOajM87)Pe2fdB9NQSAWYooy)MTiHrRib9irUCibelyKiBKaCKitKaIfT0zEBz4GWuTSlKWiKytG(tvw9f)uHsnyNjwYYF9GKXV7NCOajM87)Pe2fdB9NayuudSy5sz5SfKdVAzGz(tvw9f)m1ElL1bMaJ45Zr91dYM(D)uLvFXp1qY2cQjNutPFYHcKyYV)RheW8V7NQS6l(jvdzG0DKFYHcKyYV)RhKn(7(PkR(IFcOEUJYvWwM3(touGet(9F9GGx(D)KdfiXKF)pLWUyyR)uExICBJbrdzhEoiwWUTSAEXaY(AhwKWiKaVa6pvz1x8tml76I9TF9GaoO)UFYHcKyYV)NH6Z)eQ0LGf5ToG2ZbzIdaRQl(PkR(IFcv6sWI8whq75GmXbGv1fF9Gao4)UFYHcKyYV)NH6Z)0NHC(ArTokn8(PkR(IF6ZqoFTOwhLgEF9Gao9)UFYHcKyYV)NQS6l(PAxaRgS1bv6EqN8GA6NsyxmS1FsyamkQbuP7bDYdQjhHbWOOgKBB8Zq95FQ2fWQbBDqLUh0jpOM(6bbC687(jhkqIj)(FQYQV4NQDbSAWwhuP7bDYdQPFkHDXWw)zPqpUglSMQLHPSqISrc6aosKjsW4nS20KjdcSbasD456iV5r(zO(8pv7cy1GToOs3d6KhutF9Ga(M)D)KdfiXKF)pvz1x8t1UawnyRdQ09Go5b10pLWUyyR)eaJIAq0q2HNdIfSBlRMxmWmrImrccdGrrnGkDpOtEqn5imagf1aZejYejWdsW4nS20KjdcSbasD456iV5r(zO(8pv7cy1GToOs3d6KhutF9GaEg)UFYHcKyYV)NsyxmS1FcGrrniAi7WZbXc2TLvZlgyM)uLvFXpnVQV4RheW30V7NCOajM87)Pe2fdB9N4bjknXrnas3riWoYZWbhkqIjirUCibEqc5DjYTngaP7ieyh5z4aYkjRFQYQV4NenKD45Gyb72YQ5fF9Gaoy(39touGet(9)uc7IHT(tamkQbWfSZU0CImSLkZJegTIeG5FQYQV4N15dyRl4VEqaFJ)UFYHcKyYV)NsyxmS1F2H887WZruF1JDzyrcJqcq)PkR(IFk1uYPYQVWLAB9ZuBlxO(8p97Q90QV4RheWXl)UFYHcKyYV)NQS6l(PutjNkR(cxQT1ptTTCH6Z)0wAqui5RV(PjKLNpGw)UheW)D)KdfiXKF)xpi0)7(jhkqIj)(VEqOZV7NCOajM87)6bzZ)UFYHcKyYV)RhKm(D)uLvFXpnVQV4NCOajM87)6RV(jyzOTV4bHEqPhuqbN(n)ZTkm6WZ(tJL0OXkq2aGaMeVIeiXUfgjAFZdwib1brcAWwAquiHgqciJ3WAitqc75ZiHIvNVwmbjKlA4X2bYGX6oyKyJ4vKaVFbyzyXeKGgkf6X1a8r1(SRohPzAajQdjOHQ9zxDosZ0asGFWng8nqgqg2a(MhSycsSzKqLvFbsKABzhid)0eEuDI)jnrI9P7iibykR1csyShT3sHmqtKyPktlEfhC86AbdyipFCSTpwsR(cjuPkCSTVezGMiXgMbGykmlKyJ0Ie0dk9GImGmqtKaVVOHhBXRid0ejadKGgjeMGeBWoiiXggYmD5bYanrcWajOrcHjiXgSR2tR(cKi12AGmqtKamqcAKqycsqdtfSmsSpDhbjMlnNiibncypianGeNz1xmqgOjsagiXgcSCGe(hKrc1ZdYwBdwoLfs4Xbd1IrI9xWiXCP5ebjSLkZBhidid0ej2qgdlXkMGeam1bzKqE(aAHeaSxh2bsqJsjBwwKiUamwuOpfwcjuz1xyrIlsznqguz1xyhMqwE(aATsLuBEKbvw9f2HjKLNpGw4UId1DeKbvw9f2HjKLNpGw4UIJI55ZrPvFbYanrIzOM2LRqcO2eKaaJIIjiHT0YIeam1bzKqE(aAHeaSxhwKqdcsyczWW8QQdpKOTib5cEGmOYQVWomHS88b0c3vCSHAAxUYzlTSidQS6lSdtilpFaTWDfhZR6lqgqgOjsSHmgwIvmbjyWYWSqIQ9zKOwyKqL1brI2Ieky1oPajEGmOYQVWU63bXrbzMUmYGkR(clUR4aKUJ4OWGzrBtTkVlrUTXGOHSdphely3wwnVyazLKvM4hpY7sKBBmas3riWoYZWbKvsw5YHNstCudG0DecSJ8mCWHcKyc(qguz1xyXDfhagAzy(o8qguz1xyXDfhfk1GDMyjltBtTQYQbl74G9B2A0k95YbXcoBWZeIfT0zEBz4GWuTSlJ2eOidQS6lS4UItQ9wkRdmbgXZNJI2MAfaJIAGflxklNTGC4vldmtKbvw9fwCxXrdjBlOMCsnLqguz1xyXDfhQgYaP7iidQS6lS4UIdG65okxbBzElYGkR(clUR4GzzxxSVL2MAvExICBJbrdzhEoiwWUTSAEXaY(AhwJWlGImOYQVWI7koyw21f7tBO(8kuPlblYBDaTNdYehawvxGmOYQVWI7koyw21f7tBO(8Qpd581IADuA4HmOYQVWI7koyw21f7tBO(8QAxaRgS1bv6EqN8GAI2MALWayuudOs3d6KhutocdGrrni32azqLvFHf3vCWSSRl2N2q95v1UawnyRdQ09Go5b1eTn1APqpUglSMQLHPSYMoGNjJ3WAttMmiWgai1HNRJ8MhbzqLvFHf3vCWSSRl2N2q95v1UawnyRdQ09Go5b1eTn1kagf1GOHSdphely3wwnVyGzMjHbWOOgqLUh0jpOMCegaJIAGzMjEy8gwBAYKbb2aaPo8CDK38iidQS6lS4UIJ5v9f02uRayuudIgYo8CqSGDBz18IbMjYGkR(clUR4q0q2HNdIfSBlRMxqBtTINstCudG0DecSJ8mCWHcKysUC4rExICBJbq6ocb2rEgoGSsYczqLvFHf3vCQZhWwxW02uRayuudGlyNDP5ezylvM3OvWmYGkR(clUR4i1uYPYQVWLABrBO(8QFxTNw9f02uRDip)o8Ce1x9yxgwJafzqLvFHf3vCKAk5uz1x4sTTOnuFE1wAquibzazqLvFHD43v7PvFXkyvFZg2shq6ocTn16cRPAzykRSZa0C5WpE8GhMzMlSMQLHPSYEtBcFid0ej2aH887WdjiQV6XibKXBynK95OqI2Ie0NHXgsCuiHVAmiXcRPAbjSx6OfjYauJnK4OqcF1yqIfwt1cs0bsOiHh8WmhidQS6lSd)UApT6lWDfhcR1IZwWoptBtT2H887WZruF1JDzynAf0rggFH1uTm8vJjxo8Jhp4HzMzhYZVdphr9vp2LH1Ovqh0NHXxynvldF1yWhYanrcW0lOHcjsCHeAGeSX02QdpKyF6ocsmxAorqcc8mhidQS6lSd)UApT6lWDfhcR1IZwWoptBtTAvWYoG0DeNDP5ejZoKNFhEoI6RESldRrGMjagf1aiDhXzxAorgyMzcGrrnas3rC2LMtKbK91oSzd(idJ7jjidQS6lSd)UApT6lWDfNwYahwqCuhS6cJW02uRlSMQLHPSYodqbd8tpOghaJIAaKUJ4SlnNidmt8HmGmOYQVWoSLgefswjSwloBb78mTn1kelAPZ82YWbHPAzxzVcoOzIF8uAIJAaCbBRd6p4qbsmjxo8iVlrUTXa4c2wh0FazLKvUCayuudIgYo8CqSGDBz18IbMj(qguz1xyh2sdIcj4UIdq6ocb2rEgsBtTIhamkQbrdzhEoiwWUTSAEXaZezqLvFHDylnikKG7ko(keEBHCqOTPwXpagf1a4c2zxAorgq2x7WM9kel4r1(SRohDYLdaJIAaCb7SlnNidi7RDyZEf)EscUY7sKBBmas3riWoYZWbKvswgV0eh1aiDhHa7ipdhCOajMyC6XxUCayuudGlyNDP5ezylvMpB6GVmHyrlDM3wgoimvl7YOv6bfzqLvFHDylnikKG7kolSclhBTCizABQv8aGrrniAi7WZbXc2TLvZlgyMidQS6lSdBPbrHeCxXbiDhXbCDI2MAvUOqp26OGQS6l0KrRGp2yM4haJIASW(NTuBBh2sL5ZEf)zagwtoLCLc94Yoas3rCaxNWxUCwtoLCLc94Yoas3rCaxNmIE8HmOYQVWoSLgefsWDfhFfcVTqoi02uRayuudGlyNDP5ezylvMp7nLzPjoQXzTykmRbhkqIjzcXIw6mVTmCqyQw2LrRGNbYGkR(c7WwAquib3vCaUGT1b9PTPwHyrlDM3wgA0k4GcAM4baJIAq0q2HNdIfSBlRMxmWmrguz1xyh2sdIcj4UIdH1AXzlyNNPTPwHyrlDM3wgoimvl7k7v8dEg4cGrrniAi7WZbXc2TLvZlgyMgpdCTMCk5kf6XLDSWkSC2c25zJxAIJASWkSaGSMNHdouGetmo94lxUsHECnaFuTp7QZrAoBWbfzqLvFHDylnikKG7koewRfNgehHLAw02uRwtoLCLc94YoiSwloniocl1SmALoidQS6lSdBPbrHeCxXbIfSZwWoptBtTIF5Ic9yRJcQYQVqtgTc(yJ5YbGrrniAi7WZbXc2TLvZlgyM4ltiwWJQ9zxDo6y0QNKGmOYQVWoSLgefsWDfNfwHLZwWoptBtTcGrrniAi7WZbXc2TLvZlgyM5YbXcEuTp7QZT5S9KeKbvw9f2HT0GOqcUR4aKUJ4aUorBtTcGrrniAi7WZbXc2TLvZlgyMidQS6lSdBPbrHeCxXHWAT40G4iSuZI2MAfaJIAiHTV9cNvEyqpEGzMlxPjoQbunBIJWYZ38SD1xm4qbsmjxoRjNsUsHECzhewRfNgehHLAwgTspYGkR(c7WwAquib3vCKxyX8nR(cKbvw9f2HT0GOqcUR4aKUJ4aUoHmOYQVWoSLgefsWDfNfwHLZwWoptBtTcXcEuTp7QZrNS9KKC5aWOOgaxWo7sZjYWwQmVrBczqLvFHDylnikKG7koyw21f7tBO(8Qh8cpRZe2(AYbvpgzqLvFHDylnikKG7koqSGD2c25zKbvw9f2HT0GOqcUR4OqPgSRoiKJI2MAfIfT0zEBz4GWuTSlJOh0FQy1Yb)5S9X7ibUiHXcoFN6V(6F]] )

end