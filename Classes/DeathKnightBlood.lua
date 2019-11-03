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

            handler = function ()
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

            handler = function ()
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


    spec:RegisterPack( "Blood", 20190920, [[dyuIDaqiGIhbu6sisL2efXNuPQmkvQCkvsTkKIEfIQzHu6wQKyxc(fq1WuPCmeXYOapdPW0qKY1OG2Mkj9nvQQghsL6CQuL1PqeZJI09ur7dPQdIujleiEisfAIkevxuHOSrePQgjIurNuHiTskQxIiv5MivWoruEQIMkqAVQ6Vu1GjCyslgWJjAYqDzuBgjFwOgTkCAjVwLy2u52ky3I(TsdxihhrQWYb9CknDPUocBhrY3vOgpsfDEfsRxHW8Pq7hYpjpO)eRn)KzWnsU3T7zWTWT7rdsJgx9N9Or8pJu5fnM)zQd8pbXTl(Nr6OUvXpO)0Ueqj)Zznq40U2KocvQ(NaeLRhP5d8tS28tMb3i5E3UNb3c3UhninAyWpTrS8jZadV9ZJcJ58b(jMTYFcwKae3UyKyKZAFGeKEzfF0iZGfjo6oYosah84QpiacYDaCBnq40U2ucvQgCBnirMblsm5OMhayisyWnArcdUrY9qMrMblsqhp0mMTJeKzWIexbjOlmMXibDOsmsq6dzEeCazgSiXvqc6cJzmsqhQUI1U2ejCLTdiZGfjUcsqxymJrI7BQKIrcqC7IrI5rXomsqxa2fcCFiXg11MbKzWIexbjgzKItKyyHmsOXXq2AlsXUrrIyozO2msaYMmsmpk2HrcBRYl2WpDLTTpO)CO6kw7AZh0NmsEq)jNkGJXpi)ucRMHL(ZdwD9ris2iHPiHH3qcJgrI7qcWGeXWLicjmbjoy11hHizJeMIex9QiX1)uLDT5pjLoevWs6bC7I)(jZGh0FYPc4y8dYpLWQzyP)Ss5ouzShRdAm7n0Ie0FIe3cgIe0ejoy11hHbLorcJgrI7qcWGeXWLicjmbjQuUdvg7X6GgZEdTib9NiXTGbgIe0ejoy11hHbLorIR)Pk7AZFIzTp82gwx4VFYOXd6p5ubCm(b5Nsy1mS0FAvsXEa3UyV9OyhgjmbjQuUdvg7X6GgZEdTib9iXnKWeKaGGIka42f7Thf7WbIiKWeKaGGIka42f7Thf7WbipOvArctrcscgIe0ejIL4FQYU28Nyw7dVTH1f(7Nms7b9NCQaog)G8tjSAgw6ppy11hHizJeMIegEdjUcsChsyWnKGMibabfvaWTl2Bpk2HderiX1)uLDT5pljdSej2tTWUAcm)93)02AIvi(b9jJKh0FYPc4y8dYpLWQzyP)esKL0hTJzyaZuLSAKW0tKGKBiHjiXDibyqIwDC2bGnzBVWHaNkGJXiHrJibyqc5Uo8oodaBY2EHdbiR4rrcJgrcackQawtzLXEirY(XSgTzGicjU(NQSRn)jM1(WBByDH)(jZGh0FYPc4y8dYpLWQzyP)emibabfvaRPSYypKiz)ywJ2mqe9tv21M)eWTlgdR8cd)(jJgpO)KtfWX4hKFkHvZWs)5Dibabfvayt2Bpk2HdqEqR0IeMEIeqIKdDnW(E90ajmAejaiOOcaBYE7rXoCaYdALwKW0tK4oKiwIrcYrc5Uo8oodaUDXyyLxyyaYkEuKGMirRoo7aGBxmgw5fgg4ubCmgjOjsyasCnsy0isaqqrfa2K92JID4GTv5fKW0tKG0qIRrctqcirwsF0oMHbmtvYQrc6prcdU9tv21M)CqHWDmKt83pzK2d6p5ubCm(b5Nsy1mS0FkpuymB9uqv21MQdjO)ejijq3iHjiXDibabfv4GhwBR2YgSTkVGeMEIe3HegIexbjSrSZ5BfgZTna42f7b2YHexJegnIe2i258TcJ52gaC7I9aB5qc6rcdqIR)Pk7AZFc42f7b2Y99tMHpO)KtfWX4hKFkHvZWs)jabfvayt2Bpk2Hd2wLxqctrIRIeMGeT64SdR1sOWrdCQaogJeMGeqISK(ODmddyMQKvJe0FIeKy4pvzxB(Zbfc3XqoXF)KD1h0FYPc4y8dYpLWQzyP)esKL0hTJzisq)jsqYTBiHjibyqcackQawtzLXEirY(XSgTzGi6NQSRn)jWMSTx4W3pz3)d6p5ubCm(b5Nsy1mS0FcjYs6J2XmmGzQswnsy6jsChsqIHib5ibabfvaRPSYypKiz)ywJ2mqeHe0ejmejihjSrSZ5BfgZTnCWkS92gwxyKGMirRoo7WbRWgaY6fgg4ubCmgjOjsyasCnsy0is01a771Jlgjmfji52pvzxB(tmR9H32W6c)9tgD)G(tovahJFq(Pewndl9N2i258TcJ52gWS2hEnXEml1rrc6prcA8tv21M)eZAF41e7XSuh97NS79G(tovahJFq(Pewndl9N3HeYdfgZwpfuLDTP6qc6prcsc0nsy0isaqqrfWAkRm2djs2pM1OnderiX1iHjibKi5qxdSVxpnqc6prIyj(NQSRn)jKizVTH1f(7NmsU9G(tovahJFq(Pewndl9NaeuubSMYkJ9qIK9JznAZaresy0isajso01a771tAiHPirSe)tv21M)8Gvy7TnSUWF)KrcjpO)KtfWX4hKFkHvZWs)jabfvaRPSYypKiz)ywJ2mqe9tv21M)eWTl2dSL77Nmsm4b9NCQaog)G8tjSAgw6pbiOOcsyny30BLlbmMderiHrJirRoo7auJkShZYDiATvxBg4ubCmgjmAejSrSZ5BfgZTnGzTp8AI9ywQJIe0FIeg8tv21M)eZAF41e7XSuh97NmsOXd6pvzxB(t5MwIHOU28NCQaog)G89tgjK2d6pvzxB(ta3UypWwUFYPc4y8dY3pzKy4d6p5ubCm(b5Nsy1mS0Fcjso01a771tdKWuKiwIrcJgrcackQaWMS3EuSdhSTkVGe0Jex9NQSRn)5bRW2BByDH)(jJKR(G(tovahJFq(zQd8pJHBgB9rWAqDEOgZ)uLDT5pJHBgB9rWAqDEOgZF)KrY9)G(tv21M)esKS32W6c)tovahJFq((jJe6(b9NCQaog)G8tjSAgw6pHezj9r7yggWmvjRgjOhjm42pvzxB(tfk1K99cHC2F)9pXmLs46h0NmsEq)Pk7AZFouj2tbzEe8p5ubCm(b57NmdEq)jNkGJXpi)ucRMHL(t5Uo8oodynLvg7Hej7hZA0MbiR4rrctqI7qcWGeYDD4DCgaC7IXWkVWWaKv8OiHrJibyqIwDC2ba3UymSYlmmWPc4ymsC9pvzxB(ta3UypfbC0VFYOXd6pvzxB(tagAz4LkJ)jNkGJXpiF)KrApO)uLDT5pjSSVAEW(tovahJFq((jZWh0FYPc4y8dYpvzxB(t1EqknzRhQJyHE5cv3pLWQzyP)eZaeuubOoIf6LluDEmdqqrfW748NPoW)uThKst26H6iwOxUq199t2vFq)jNkGJXpi)uLDT5pv7bP0KTEOoIf6LluD)ucRMHL(tackQawtzLXEirY(XSgTzGicjmbjWmabfvaQJyHE5cvNhZaeuubIOFM6a)t1EqknzRhQJyHE5cv33pz3)d6p5ubCm(b5Nsy1mS0FcqqrfWAkRm2djs2pM1Onder)uLDT5pJ2U287Nm6(b9NCQaog)G8tjSAgw6pbds0QJZoa42fJHvEHHbovahJrcJgrcWGeYDD4DCgaC7IXWkVWWaKv8O)uLDT5pXAkRm2djs2pM1On)(j7EpO)KtfWX4hKFkHvZWs)jabfvayt2Bpk2Hd2wLxqc6prI7)NQSRn)zVda2Et(7NmsU9G(tovahJFq(Pewndl9Nvk3HkJ9yDqJzVHwKGEK42pvzxB(tP6CEv21MExz7F6kB7tDG)5q1vS21MF)KrcjpO)KtfWX4hKFQYU28Ns158QSRn9UY2)0v22N6a)tBRjwH4V)(NrqwUdaA)G(93)Kum0wB(KzWnsU3n6(gn(5yfMvgB)5iDiAHnJrcAGeQSRnrcxzBBaz(NkrFSWFoRb6isqosq6KVuU6NrWLQC8pblsaIBxmsmYzTpqcsVSIpAKzWIehDhzhjGdEC1heab5oaUTgiCAxBkHkvdUTgKiZGfjMCuZdamejm4gTiHb3i5EiZiZGfjOJhAgZ2rcYmyrIRGe0fgZyKGoujgji9HmpcoGmdwK4kibDHXmgjOdvxXAxBIeUY2bKzWIexbjOlmMXiX9nvsXibiUDXiX8OyhgjOla7cbUpKyJ6AZaYmyrIRGeJmsXjsmSqgj04yiBTfPy3OirmNmuBgjaztgjMhf7WiHTv5fBazgzgSiXiJozjrZyKGjfdhfj6AGrI(Grcv2lejklsOKslNc44aYSk7At75qLypfK5rWiZQSRnTKFcoGBxSNIaokTf1PCxhEhNbSMYkJ9qIK9JznAZaKv8OMChyK76W74ma42fJHvEHHbiR4rnAemT64SdaUDXyyLxyyGtfWX4RrMvzxBAj)eCagAz4LkJrMvzxBAj)eCcl7RMhSiZQSRnTKFcoHL9vZd0M6aFQ2dsPjB9qDel0lxO6OTOoXmabfvaQJyHE5cvNhZaeuub8oorMvzxBAj)eCcl7RMhOn1b(uThKst26H6iwOxUq1rBrDcqqrfWAkRm2djs2pM1OnderMGzackQauhXc9YfQopMbiOOceriZQSRnTKFcE021M0wuNaeuubSMYkJ9qIK9JznAZareYSk7Atl5NGJ1uwzShsKSFmRrBsBrDcMwDC2ba3UymSYlmmWPc4ySrJGrURdVJZaGBxmgw5fggGSIhfzwLDTPL8tW7DaW2BY0wuNaeuubGnzV9OyhoyBvEH(Z7hzwLDTPL8tWLQZ5vzxB6DLTPn1b(CO6kw7AtAlQZkL7qLXESoOXS3ql93qMvzxBAj)eCP6CEv21MExzBAtDGpTTMyfIrMrMvzxBAddvxXAxBEskDiQGL0d42ftBrDEWQRpcrY2udVz04DGjgUerMCWQRpcrY20RE1RrMblsmst5ouzmsG1bnMrcit6GOG8aNnsuwKWadjDrILcjgu6ejoy11hiHDDlTiHH3iDrILcjgu6ejoy11hirLiHIeXWLikGmRYU20ggQUI1U2K8tWXS2hEBdRlmTf1zLYDOYypwh0y2BOL(ZBbdP5bRU(imO0PrJ3bMy4sezsLYDOYypwh0y2BOL(ZBbdmKMhS66JWGsNxJmdwKyKV591iHJBKqtKGPZY2vgJeG42fJeZJIDyKad3OaYSk7AtByO6kw7AtYpbhZAF4TnSUW0wuNwLuShWTl2Bpk2HnPs5ouzShRdAm7n0s)ntaiOOcaUDXE7rXoCGiYeackQaGBxS3EuSdhG8GwP1uscgsZyjgzwLDTPnmuDfRDTj5NGxsgyjsSNAHD1eyM2I68GvxFeIKTPgE7k3zWnAcqqrfaC7I92JID4ar01iZiZQSRnTbBRjwH4tmR9H32W6ctBrDcjYs6J2XmmGzQswTPNKCZK7atRoo7aWMSTx4qGtfWXyJgbJCxhEhNbGnzBVWHaKv8OgncqqrfWAkRm2djs2pM1OnderxJmRYU20gSTMyfIj)eCa3UymSYlmK2I6emaeuubSMYkJ9qIK9JznAZareYSk7AtBW2AIviM8tWhuiChd5etBrDEhabfvayt2Bpk2HdqEqR0A6jKi5qxdSVxpnmAeGGIkaSj7Thf7WbipOvAn98UyjMC5Uo8oodaUDXyyLxyyaYkEuA2QJZoa42fJHvEHHbovahJPPbxB0iabfvayt2Bpk2Hd2wLxm9K0U2eirwsF0oMHbmtvYQP)0GBiZQSRnTbBRjwHyYpbhWTl2dSLJ2I6uEOWy26PGQSRnvh9NKeOBtUdGGIkCWdRTvBzd2wLxm98odVInIDoFRWyUTba3UypWwURnA0gXoNVvym32aGBxShylh9gCnYSk7AtBW2AIviM8tWhuiChd5etBrDcqqrfa2K92JID4GTv5ftVQjT64SdR1sOWrdCQaogBcKilPpAhZWaMPkz10FsIHiZQSRnTbBRjwHyYpbhyt22lCG2I6esKL0hTJzi9NKC7MjGbGGIkG1uwzShsKSFmRrBgiIqMvzxBAd2wtScXKFcoM1(WBByDHPTOoHezj9r7yggWmvjR20Z7iXqYbiOOcynLvg7Hej7hZA0MbIiAAi52i258TcJ52goyf2EBdRlmnB1Xzhoyf2aqwVWWaNkGJX00GRnASRb23RhxSPKCdzwLDTPnyBnXket(j4yw7dVMypML6O0wuN2i258TcJ52gWS2hEnXEml1rP)KgiZQSRnTbBRjwHyYpbhsKS32W6ctBrDEN8qHXS1tbvzxBQo6pjjq3gncqqrfWAkRm2djs2pM1OnderxBcKi5qxdSVxpnO)mwIrMvzxBAd2wtScXKFc(bRW2BByDHPTOobiOOcynLvg7Hej7hZA0MbIiJgHejh6AG996jntJLyKzv21M2GT1eRqm5NGd42f7b2YrBrDcqqrfWAkRm2djs2pM1OnderiZQSRnTbBRjwHyYpbhZAF41e7XSuhL2I6eGGIkiH1GDtVvUeWyoqez0yRoo7auJkShZYDiATvxBg4ubCm2OrBe7C(wHXCBdyw7dVMypML6O0FAaYSk7AtBW2AIviM8tWLBAjgI6AtKzv21M2GT1eRqm5NGd42f7b2YHmRYU20gSTMyfIj)e8dwHT32W6ctBrDcjso01a771tdtJLyJgbiOOcaBYE7rXoCW2Q8c9xfzwLDTPnyBnXket(j4ew2xnpqBQd8zmCZyRpcwdQZd1ygzwLDTPnyBnXket(j4qIK92gwxyKzv21M2GT1eRqm5NGRqPMSVxiKZM2I6esKL0hTJzyaZuLSA6n423F)p]] )


end
