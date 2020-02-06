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


    spec:RegisterPack( "Blood", 20200124, [[dSu5KaqiefpcPWLujbTjrrFcrPgfIkNcrvRIcvVcOAwiLULkPSlf(fqzyishtLYYqQ6zifnneLCnrHTHiY3ujPghfkDoerTovsL5jk5EQO9rHCqkuSqG4HivOjIubUOkjYgvjj5JQKKAKivqoPkjQvsbVuLeYmvjb6MQKe7eiTuvsapvrtvLQVIub1Ev1FPYGjCyslgWJjAYqDzuBgjFMQmAv40sTAvsOETOQzlYTPQ2TWVvA4u0XvjvTCqpNstxY1ry7icFxLy8iv05fLA9ivA(Ik7hY)T)(pXAXpO0tk9Ks6n6jRbPKmnjzY62pRSn5FAQY8Qh)Zq95FcsAx8pn1StRI)7)0Ueqj)Zz7tK0Q3GocvQ6NaeDQUYXd8tSw8dk9KspPKEJEYAqkjttsMMx9pTMS8bL(mi9NhngZXd8tmBL)KgibiPDXibDaR1bsCffT3rHmqdK4Okt71bgyEDDqamKRpy22NiPvVHeQufy22xImqdKWGgekmBKG(B0Ie0tk9KImGmqdKGoEOHhBVoKbAGexdjmgmMXiXvPdmsCvbzMU8azGgiX1qcJbJzmsCv6Q90Q3ajsTTgid0ajUgsymymJrcYEQKGrcqs7IrI5rZjmsyma2fcq2iXAw9gdKbAGexdjUsKGdKWFHmsOEEq2ABsWPSrcpoyOwmsaYgmsmpAoHrcBPY82XptTTS)9F63v7PvVXF)b92F)NCOajg)G8tjSlg26ppynvhdtzHezHezqksKlhsqoKGmiHhCjmrImrIdwt1XWuwirwibjrsib5)PkREJFsc13SHT0bK2f)1dk9)9FYHcKy8dYpLWUyyR)Sd563HNdR(Qh7YWIegDIeKoYajmosCWAQog(kDIe5YHeKdjids4bxctKitKOd563HNdR(Qh7YWIegDIeKoOpdKW4iXbRP6y4R0jsq(FQYQ34NywRdNTGDE(RhuA(3)jhkqIXpi)uc7IHT(tRsc2bK2f7ShnNWirMirhY1Vdphw9vp2LHfjmcjifjYejaiOOgaPDXo7rZj8GWejYejaiOOgaPDXo7rZj8aY(AhwKilK42idKW4iHNe)tvw9g)eZAD4SfSZZF9Gsw)9FYHcKy8dYpLWUyyR)8G1uDmmLfsKfsKbPiX1qcYHe0tksyCKaGGIAaK2f7ShnNWdctKG8)uLvVXpBjdSeb2rTWQlcm)1x)0wAGvi(V)GE7V)touGeJFq(Pe2fdB9NqIOLoZ9cdhyMQLDHezDIe3ifjYejihsqgKO0eh1ayd2wl0FWHcKymsKlhsqgKqUBcVxIbWgSTwO)aYkoBKixoKaGGIAG1q2HNdseS7cRMBmimrcY)tvw9g)eZAD4SfSZZF9Gs)F)NCOajg)G8tjSlg26pjdsaqqrnWAi7WZbjc2DHvZngeM)uLvVXpbs7IXWoYZWVEqP5F)NCOajg)G8tjSlg26pjhsaqqrna2GD2JMt4bK91oSirwNibKi4r1(SRwhnrIC5qcackQbWgSZE0CcpGSV2HfjY6ejihs4jXib4iHC3eEVedG0UymSJ8mCazfNnsyCKO0eh1aiTlgd7ipdhCOajgJeghjOhjipsKlhsaqqrna2GD2JMt4HTuzEKilKGMib5rImrcir0sN5EHHdmt1YUqcJorc6j9NQS6n(PVcH7fih4VEqjR)(p5qbsm(b5NsyxmS1FsgKaGGIAG1q2HNdseS7cRMBmim)PkREJFEWkSCS1YHK)6bnJ)(p5qbsm(b5NsyxmS1FkpuOhBDuqvw9gAcjm6ejUnmwKitKGCibabf14G9xBP22oSLkZJezDIeKdjYajUgsyn5uYvk0Jl7aiTl2bSDcjipsKlhsyn5uYvk0Jl7aiTl2bSDcjmcjOhji)pvz1B8tG0UyhW2PVEqjP)(p5qbsm(b5NsyxmS1Fcqqrna2GD2JMt4HTuzEKilKidKitKO0eh1yTwcfM9GdfiXyKitKaseT0zUxy4aZuTSlKWOtK4wg)uLvVXp9viCVa5a)1d6v)3)jhkqIXpi)uc7IHT(tir0sN5EHHiHrNiXnsjfjYejidsaqqrnWAi7WZbjc2DHvZngeM)uLvVXpb2GT1c9)6b1y)7)KdfiX4hKFkHDXWw)jKiAPZCVWWbMPAzxirwNib5qIBzGeGJeaeuudSgYo8CqIGDxy1CJbHjsyCKidKaCKWAYPKRuOhx2XbRWYzlyNNrcJJeLM4OghSclaiR5z4GdfiXyKW4ib9ib5rIC5qIQ9zxToCZirwiXns)PkREJFIzToC2c255VEqj5)(p5qbsm(b5NsyxmS1FAn5uYvk0Jl7aZAD40a7WSuZgjm6ejO5pvz1B8tmR1HtdSdZsn7VEqVr6F)NCOajg)G8tjSlg26pjhsipuOhBDuqvw9gAcjm6ejUnmwKixoKaGGIAG1q2HNdseS7cRMBmimrcYJezIeqIGhv7ZUAD0ejm6ej8K4FQYQ34NqIGD2c255VEqVD7V)touGeJFq(Pe2fdB9NaeuudSgYo8CqIGDxy1CJbHjsKlhsajcEuTp7Q1rwirwiHNe)tvw9g)8Gvy5SfSZZF9GEJ()(p5qbsm(b5NsyxmS1FcqqrnWAi7WZbjc2DHvZngeM)uLvVXpbs7IDaBN(6b9gn)7)KdfiX4hKFkHDXWw)jabf1qcBF7goRCjGE8GWejYLdjknXrnGQzJDywU(MRTREJbhkqIXirUCiH1KtjxPqpUSdmR1HtdSdZsnBKWOtKG(FQYQ34NywRdNgyhMLA2F9GEJS(7)uLvVXpLByj8nREJFYHcKy8dYxpO3Y4V)tvw9g)eiTl2bSD6NCOajg)G81d6ns6V)touGeJFq(Pe2fdB9NqIGhv7ZUAD0ejYcj8KyKixoKaGGIAaSb7ShnNWdBPY8iHribj9tvw9g)8Gvy5SfSZZF9GE7Q)7)KdfiX4hKFgQp)tp4gEwNjS91KdQE8pvz1B8tp4gEwNjS91KdQE8xpO3m2)(pvz1B8tirWoBb788p5qbsm(b5Rh0BK8F)NCOajg)G8tjSlg26pHerlDM7fgoWmvl7cjmcjON0FQYQ34NkuQb7Qfc5O(6RFIzkLiv)9h0B)9FQYQ34N(DGDuqMPl)touGeJFq(6bL()(p5qbsm(b5NsyxmS1Fk3nH3lXaRHSdphKiy3fwn3yazfNnsKjsqoKGmiHC3eEVedG0UymSJ8mCazfNnsKlhsqgKO0eh1aiTlgd7ipdhCOajgJeK)NQS6n(jqAxSJIaM9xpO08V)tvw9g)eGHwgMVdVFYHcKy8dYxpOK1F)NCOajg)G8tjSlg26pvz1KGDCW(nBrcJorc6rIC5qcirWirwiXnKitKaseT0zUxy4aZuTSlKWiKGKi9NQS6n(PcLAWotIKL)6bnJ)(p5qbsm(b5NsyxmS1FcqqrniIJnLTZwqo8QJbH5pvz1B8Zu7Duw3vmb2ZNJ6Rhus6V)tvw9g)udjBlOMCsnL(jhkqIXpiF9GE1)9FQYQ34NunKbs7I)jhkqIXpiF9GAS)9FQYQ34NaQNBPCfSL5T)KdfiX4hKVEqj5)(p5qbsm(b5NsyxmS1Fk3nH3lXaRHSdphKiy3fwn3yazFTdlsyesqYK(tvw9g)KWYUUyF7xpO3i9V)touGeJFq(zO(8pHkDXerERdO9Cqg7aiQAJFQYQ34NqLUyIiV1b0EoiJDaevTXxpO3U93)jhkqIXpi)muF(N(mKZxhQ1rPH3pvz1B8tFgY5Rd16O0W7Rh0B0)3)jhkqIXpi)uLvVXpv7bj0GToOs3f6Klut)uc7IHT(tmdqqrnGkDxOtUqn5Wmabf1aVxIFgQp)t1EqcnyRdQ0DHo5c10xpO3O5F)NCOajg)G8tvw9g)uThKqd26GkDxOtUqn9tjSlg26plf6X14G1uDmmLfsKfsqZBirMibF9eTPjJhyydaK6WZ1rEZf)Zq95FQ2dsObBDqLUl0jxOM(6b9gz93)jhkqIXpi)uLvVXpv7bj0GToOs3f6Klut)uc7IHT(tackQbwdzhEoirWUlSAUXGWejYejWmabf1aQ0DHo5c1KdZaeuudctKitKGmibF9eTPjJhyydaK6WZ1rEZf)Zq95FQ2dsObBDqLUl0jxOM(6b9wg)9FYHcKy8dYpLWUyyR)eGGIAG1q2HNdseS7cRMBmim)PkREJFAUvVXxpO3iP)(p5qbsm(b5NsyxmS1FsgKO0eh1aiTlgd7ipdhCOajgJe5YHeKbjK7MW7LyaK2fJHDKNHdiR4S)PkREJFI1q2HNdseS7cRMB81d6TR(V)touGeJFq(Pe2fdB9NaeuudGnyN9O5eEylvMhjm6ejU6FQYQ34N16dyRn4VEqVzS)9FYHcKy8dYpLWUyyR)Sd563HNdR(Qh7YWIegHeK(tvw9g)uQPKtLvVHl126NP2wUq95F63v7PvVXxpO3i5)(p5qbsm(b5NQS6n(PutjNkREdxQT1ptTTCH6Z)0wAGvi(RV(PjKLRpGw)9h0B)9FYHcKy8dYxpO0)3)jhkqIXpiF9GsZ)(p5qbsm(b5RhuY6V)touGeJFq(6bnJ)(pvz1B8tZT6n(jhkqIXpiF91x)Kem02B8GspP3izsjz6j9Nxuy0HN9N0HnMRaGELb9Q(6qcK4(bJeTV5clKGAHibzBlnWket2ibKVEIgYyKWU(msOe16RfJrc5HgESDGmCfSdgjm2RdjOJBqcgwmgji7sHECnUnQ2ND16Wnt2irTibzxTp7Q1HBMSrcYDJoj)azaz4k7BUWIXibzHeQS6nqIuBl7az4NkrDSWFoBF6isaosqhIZ3P(NMWLQt8pPbsasAxmsqhWADGexrr7Duid0ajoQY0EDGbMxxhead56dMT9jsA1BiHkvbMT9Lid0ajmObHcZgjO)gTib9KspPidid0ajOJhA4X2RdzGgiX1qcJbJzmsCv6aJexvqMPlpqgObsCnKWyWygJexLUApT6nqIuBRbYanqIRHegdgZyKGSNkjyKaK0UyKyE0CcJegdGDHaKnsSMvVXazGgiX1qIRej4aj8xiJeQNhKT2MeCkBKWJdgQfJeGSbJeZJMtyKWwQmVDGmGmqdK4krNSKOymsaWulKrc56dOfsaWEDyhiHXiLSzzrIyJRDOqFkIesOYQ3WIeBKYEGmOYQ3WomHSC9b06KkP28idQS6nSdtilxFaTa)emQDXidQS6nSdtilxFaTa)emLWZNJsREdKbAGeZqnThBHeqTXibabffJrcBPLfjayQfYiHC9b0cjayVoSiHgyKWeYxZCRQdpKOTibEdEGmOYQ3WomHSC9b0c8tWSHAAp2YzlTSidQS6nSdtilxFaTa)emZT6nqgqgObsCLOtwsumgjysWWSrIQ9zKOoyKqL1crI2Iekj0oPajEGmOYQ3WE63b2rbzMUmYGkREdl4NGbK2f7OiGztBtDk3nH3lXaRHSdphKiy3fwn3yazfNDMKJmYDt49smas7IXWoYZWbKvC25YrMstCudG0UymSJ8mCWHcKym5rguz1Byb)emagAzy(o8qguz1Byb)emfk1GDMejltBtDQYQjb74G9B2A0j95YbjcoRBzcjIw6m3lmCGzQw2LrKePidQS6nSGFcwQ9okR7kMa75ZrrBtDcqqrniIJnLTZwqo8QJbHjYGkREdl4NGPHKTfutoPMsidQS6nSGFcgvdzG0UyKbvw9gwWpbdq9ClLRGTmVfzqLvVHf8tWiSSRl23sBtDk3nH3lXaRHSdphKiy3fwn3yazFTdRrKmPidQS6nSGFcgHLDDX(0gQpFcv6IjI8whq75Gm2bqu1gidQS6nSGFcgHLDDX(0gQpF6ZqoFDOwhLgEidQS6nSGFcgHLDDX(0gQpFQ2dsObBDqLUl0jxOMOTPoXmabf1aQ0DHo5c1KdZaeuud8Ejqguz1Byb)emcl76I9PnuF(uThKqd26GkDxOtUqnrBtDwk0JRXbRP6yykRSO5Tm5RNOnnz8adBaGuhEUoYBUyKbvw9gwWpbJWYUUyFAd1Npv7bj0GToOs3f6Klut02uNaeuudSgYo8CqIGDxy1CJbHzMygGGIAav6UqNCHAYHzackQbHzMKHVEI20KXdmSbasD456iV5Irguz1Byb)emZT6nOTPobiOOgynKD45Geb7UWQ5gdctKbvw9gwWpbdRHSdphKiy3fwn3G2M6KmLM4OgaPDXyyh5z4GdfiX4C5iJC3eEVedG0UymSJ8mCazfNnYGkREdl4NGvRpGT2GPTPobiOOgaBWo7rZj8WwQmVrNxnYGkREdl4NGj1uYPYQ3WLABrBO(8PFxTNw9g02uNDix)o8Cy1x9yxgwJifzqLvVHf8tWKAk5uz1B4sTTOnuF(0wAGvigzazqLvVHD43v7PvVXjjuFZg2shqAxmTn15bRP6yykRSYG0C5ihz8GlHzMhSMQJHPSYIKijYJmqdK4khY1VdpKaR(QhJeq(6jAi7ZrHeTfjOpJRqKyPqcFLorIdwt1bsy30slsKbPxHiXsHe(kDIehSMQdKOdKqrcp4syoqguz1Byh(D1EA1Ba(jyywRdNTGDEM2M6Sd563HNdR(Qh7YWA0jPJmm(bRP6y4R0zUCKJmEWLWmZoKRFhEoS6RESldRrNKoOpdJFWAQog(kDsEKbAGe0bBq2fsK4cj0ajy6STvhEibiPDXiX8O5egjWW1CGmOYQ3Wo87Q90Q3a8tWWSwhoBb78mTn1Pvjb7as7ID2JMt4m7qU(D45WQV6XUmSgrAMaeuudG0UyN9O5eEqyMjabf1aiTl2zpAoHhq2x7WM1Trgg3tIrguz1Byh(D1EA1Ba(jyTKbwIa7Owy1fbMPTPopynvhdtzLvgKEnYrpPghGGIAaK2f7ShnNWdctYJmGmOYQ3WoSLgyfIpXSwhoBb78mTn1jKiAPZCVWWbMPAzxzDEJ0mjhzknXrna2GT1c9hCOajgNlhzK7MW7LyaSbBRf6pGSIZoxoackQbwdzhEoirWUlSAUXGWK8idQS6nSdBPbwHyWpbdiTlgd7ipdPTPojdabf1aRHSdphKiy3fwn3yqyImOYQ3WoSLgyfIb)emFfc3lqoW02uNKdGGIAaSb7ShnNWdi7RDyZ6ese8OAF2vRJM5Ybqqrna2GD2JMt4bK91oSzDsopjgC5Uj8EjgaPDXyyh5z4aYkoBJxAIJAaK2fJHDKNHdouGeJno9KpxoackQbWgSZE0CcpSLkZNfnjFMqIOLoZ9cdhyMQLDz0j9KImOYQ3WoSLgyfIb)eSdwHLJTwoKmTn1jzaiOOgynKD45Geb7UWQ5gdctKbvw9g2HT0aRqm4NGbK2f7a2orBtDkpuOhBDuqvw9gAYOZBdJntYbqqrnoy)1wQTTdBPY8zDsUmUM1KtjxPqpUSdG0UyhW2jYNlN1KtjxPqpUSdG0UyhW2jJON8idQS6nSdBPbwHyWpbZxHW9cKdmTn1jabf1ayd2zpAoHh2sL5ZkJmlnXrnwRLqHzp4qbsmotir0sN5EHHdmt1YUm68wgidQS6nSdBPbwHyWpbdyd2wl0N2M6eseT0zUxyOrN3iL0mjdabf1aRHSdphKiy3fwn3yqyImOYQ3WoSLgyfIb)emmR1HZwWoptBtDcjIw6m3lmCGzQw2vwNK7wgGdqqrnWAi7WZbjc2DHvZngeMgpdWTMCk5kf6XLDCWkSC2c25zJxAIJACWkSaGSMNHdouGeJno9KpxUsHECnUnQ2ND16WnN1nsrguz1Byh2sdScXGFcgM16WPb2HzPMnTn1P1KtjxPqpUSdmR1HtdSdZsnBJoPjYGkREd7WwAGvig8tWGeb7SfSZZ02uNKtEOqp26OGQS6n0KrN3ggBUCaeuudSgYo8CqIGDxy1CJbHj5Zese8OAF2vRJMgD6jXidQS6nSdBPbwHyWpb7Gvy5SfSZZ02uNaeuudSgYo8CqIGDxy1CJbHzUCqIGhv7ZUADKvwEsmYGkREd7WwAGvig8tWas7IDaBNOTPobiOOgynKD45Geb7UWQ5gdctKbvw9g2HT0aRqm4NGHzToCAGDywQztBtDcqqrnKW23UHZkxcOhpimZLR0eh1aQMn2Hz56BU2U6ngCOajgNlN1KtjxPqpUSdmR1HtdSdZsnBJoPhzqLvVHDylnWked(jyYnSe(MvVbYGkREd7WwAGvig8tWas7IDaBNqguz1Byh2sdScXGFc2bRWYzlyNNPTPoHebpQ2ND16OzwEsCUCaeuudGnyN9O5eEylvM3isczqLvVHDylnWked(jyew21f7tBO(8PhCdpRZe2(AYbvpgzqLvVHDylnWked(jyqIGD2c25zKbvw9g2HT0aRqm4NGPqPgSRwiKJI2M6eseT0zUxy4aZuTSlJON0V(6Fa]] )

end