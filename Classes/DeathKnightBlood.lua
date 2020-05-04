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
        resource = "runes",

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

        timeTo = function( x )
            return state:TimeToResource( state.runes, x )
        end,
    }, {
        __index = function( t, k, v )
            if k == 'actual' then
                local amount = 0

                for i = 1, 6 do
                    if t.expiry[ i ] <= state.query_time then
                        amount = amount + 1
                    end
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


    spec:RegisterPack( "Blood", 20200425, [[dCKBLaqiOepcPOlrveztuf(evryuqv6uqjTkKQ8kOuZcPYTaOSlr9lOWWGkoguPLHu6zqvzAuf11OG2gaPVbqvJdQQCoaIwhabZtHY9uI9rboisbleqEiaHMisH4IufP2iavyKaurNeGkTsk0lrkKUjvrYoHIEQIMkGAVQ6VuzWeomPfRupMOjJ4YO2ms(mv1OvsNwYQPkI61ay2ICBfSBHFRYWPOJJuOwoONtPPl11bA7qv8DfY4HQQoVcvRhPQMpvP9d5h3h4Fs0MFmPfhAXbhptRHzCWpp7z8bi)zpUj)ttvcG6Z)m0b(NaLUJ8ttD80PKh4FApqOK)5SgatAxxaicvQ(NBWk1aUXV)jrB(XKwCOfhC8mTgMXb)8SNXh((P1KLpM0Aio)CTieo(9pjSv(tAIeaLUJGe0iS2RibnAu(RnYinrI1UnTacyGHF1RG7S8gWWwdGjTRlKqLQXWwdsKrAIe0GjSsibTgshsqlo0IdYiYinrcaXvn8zlGaYinrcadjObcHjiHNQccsa4aYm95mYinrcadjObcHjiHNQ6Yx76cKiv2oJmstKaWqcAGqycs4jMkEyKaO0DeKyUwCIGe0W2EWTNajoZUUiJmstKaWqcpnE4ajgoiJeQVpKT2cpCACKWNdgQnJeaDbJeZ1IteKW2QeaB(NPY22h4FouD5RDDXd8JjUpW)KdDNyYd0pLWQzyP)CL1uVMnLnsmgsyioiHxVibErcSGe(Wd0ej8ajwzn1RztzJeJHeakGIey9NQSRl(jE0bZcws3oDh57htAFG)jh6oXKhOFkHvZWs)zfYBOcFhrhuF2zOfjmybjWjBisqpKyL1uVMhu8hj86fjWlsGfKWhEGMiHhirfYBOcFhrhuF2zOfjmybjWjtRHib9qIvwt9AEqXFKaR)uLDDXpjS2RoBdla4VFmX3d8p5q3jM8a9tjSAgw6pTkEy3oDhXzxlorqcpqIkK3qf(oIoO(SZqlsyasGds4bsSbPOY70DeNDT4ejdAIeEGeBqkQ8oDhXzxlorYqEqRWIeJHe4MnejOhs4lj)uLDDXpjS2RoBdla4VFm98d8p5q3jM8a9tjSAgw6pxzn1RztzJeJHegIdsayibErcAXbjOhsSbPOY70DeNDT4ejdAIey9NQSRl(zj59bgeh1b7Qbj83F)tBRbrHKh4htCFG)jh6oXKhOFkHvZWs)jemkPZ8gXWmHPkz1iXylibU4GeEGe4fjWcs0AIJoVVGT9bhYCO7etqcVErcSGeY7sKBuK3xW2(GdziRKXrcVErInifvMOHScFhemy3iwnVidAIey9NQSRl(jH1E1zByba)9JjTpW)KdDNyYd0pLWQzyP)eliXgKIkt0qwHVdcgSBeRMxKbn)Pk76IFUt3riWkaGHF)yIVh4FYHUtm5b6Nsy1mS0FUbPOY7lyNDT4ejd5bTclsmgsGB2qKGEiHVKKz8NLGnJeE9Ie4fj2Guu59fSZUwCIKH8GwHfjgBbjGGbN7AGD95Whs41lsSbPOY7lyNDT4ejd5bTclsm2csGxKWxsqcSrc5DjYnkY70DecScayygYkzCKGEirRjo68oDhHaRaagM5q3jMGe0djOfjWks41lsSbPOY7lyNDT4ejBBvcasmgsGpKaRiHhibemkPZ8gXWmHPkz1iHblibT48tv21f)CqHWBeKdY3pME(b(NCO7etEG(Pewndl9Nybj2GuuzIgYk8DqWGDJy18ImO5pvzxx8ZvwHTJTwoK83pMg(a)to0DIjpq)ucRMHL(t5Qc9zRJcQYUUqtiHblibUz8dj8ajWlsSbPOYR8WzB1w2STvjaiXylibErcdrcadjSMCk5Af6ZTnVt3rC7RsibwrcVErcRjNsUwH(CBZ70De3(QesyasqlsG1FQYUU4N70De3(Q03pMa6d8p5q3jM8a9tjSAgw6p3Guu59fSZUwCIKTTkbajgBbjauKWdKO1ehD(SwqfoEMdDNycs4bsabJs6mVrmmtyQswnsyWcsGRH)uLDDXphui8gb5G89JjG)b(NCO7etEG(Pewndl9NqWOKoZBedrcdwqcCXbhKWdKaliXgKIkt0qwHVdcgSBeRMxKbn)Pk76IFUVGT9bh((Xe)EG)jh6oXKhOFkHvZWs)jemkPZ8gXWmHPkz1iXylibErcCnejWgj2GuuzIgYk8DqWGDJy18ImOjsqpKWqKaBKWAYPKRvOp328kRW2zBybaJe0djAnXrNxzf2BiRaWWmh6oXeKGEibTibwrcVErIUgyxFosXiXyibU48tv21f)KWAV6SnSaG)(Xeq(a)to0DIjpq)ucRMHL(tRjNsUwH(CBZew7vNgehHL64iHblib((Pk76IFsyTxDAqCewQJ)9JjU48a)to0DIjpq)ucRMHL(t8IeYvf6ZwhfuLDDHMqcdwqcCZ4hs41lsSbPOYenKv47GGb7gXQ5fzqtKaRiHhibem4CxdSRph(qcdwqcFj5NQSRl(jemyNTHfa83pM4I7d8p5q3jM8a9tjSAgw6p3GuuzIgYk8DqWGDJy18ImOjs41lsabdo31a76Z5zKymKWxs(Pk76IFUYkSD2gwaWF)yIlTpW)KdDNyYd0pLWQzyP)CdsrLjAiRW3bbd2nIvZlYGM)uLDDXp3P7iU9vPVFmXfFpW)KdDNyYd0pLWQzyP)CdsrLLWAWEHZkpqOpNbnrcVErIwtC0zOAwehHL3G5zRUUiZHUtmbj86fjSMCk5Af6ZTntyTxDAqCewQJJegSGe0(tv21f)KWAV60G4iSuh)7htC98d8pvzxx8t5fwWbZUU4NCO7etEG((XexdFG)Pk76IFUt3rC7Rs)KdDNyYd03pM4cOpW)KdDNyYd0pLWQzyP)ecgCURb21NdFiXyiHVKGeE9IeBqkQ8(c2zxlorY2wLaGegGea6pvzxx8ZvwHTZ2Wca(7htCb8pW)KdDNyYd0pdDG)Pp8cFRZewdAYbvF(NQSRl(Pp8cFRZewdAYbvF(7htCXVh4FQYUU4NqWGD2gwaW)KdDNyYd03pM4ciFG)jh6oXKhOFkHvZWs)jemkPZ8gXWmHPkz1iHbibT48tv21f)uHsnyxFqih93F)tctPGP(b(Xe3h4FQYUU4NdvqCuqMPp)to0DIjpqF)ys7d8p5q3jM8a9tjSAgw6pL3Li3Oit0qwHVdcgSBeRMxKHSsghj8ajWlsGfKqExICJI8oDhHaRaagMHSsghj86fjWcs0AIJoVt3riWkaGHzo0DIjibw)Pk76IFUt3rCuGWX)(XeFpW)uLDDXp3m0YqaQW)NCO7etEG((X0ZpW)KdDNyYd0pLWQzyP)uLDHh2XbpuSfjmybjOfj86fjGGbJeJHe4IeEGeqWOKoZBedZeMQKvJegGeako)uLDDXpvOud2zcMS83pMg(a)to0DIjpq)ucRMHL(ZnifvgmwV04oBd5WVxZGM)uLDDXptL)ABDEYGe)bo6VFmb0h4FQYUU4NAizBd1KtQP0p5q3jM8a99JjG)b(NQSRl(jvb5D6oYp5q3jM8a99Jj(9a)tv21f)CR(UJY1WscG9NCO7etEG((Xeq(a)to0DIjpq)ucRMHL(t5DjYnkYenKv47GGb7gXQ5fzipOvyrcdqcajo)uLDDXpbTSRAEW(9JjU48a)to0DIjpq)m0b(NqL(eWaaRBx(oitCBWUV4NQSRl(juPpbmaW62LVdYe3gS7l((XexCFG)jh6oXKhOFQYUU4NdmKbOxvRJsd)FkHvZWs)jErc5DjYnkYenKv47GGb7gXQ5fzipOvyrcpqcSGeBqkQmrdzf(oiyWUrSAErg0ej8ajGGbN7AGD958msyasGpKaR)m0b(NdmKbOxvRJsd)VFmXL2h4FYHUtm5b6NQSRl(PAxXJgS1bv6FqN8GA6Nsy1mS0Fs4nifvgQ0)Go5b1KJWBqkQm5gf)m0b(NQDfpAWwhuP)bDYdQPVFmXfFpW)KdDNyYd0pvzxx8t1UIhnyRdQ0)Go5b10pLWQzyP)SvOp35vwt9A2u2iXyib(Wfj8ajyAmyzAYKmbw7DQcFxfayEKFg6a)t1UIhnyRdQ0)Go5b103pM465h4FYHUtm5b6NQSRl(PAxXJgS1bv6FqN8GA6Nsy1mS0FUbPOYenKv47GGb7gXQ5fzqtKWdKGWBqkQmuP)bDYdQjhH3GuuzqtKWdKalibtJblttMKjWAVtv47QaaZJ8Zqh4FQ2v8ObBDqL(h0jpOM((XexdFG)jh6oXKhOFkHvZWs)5gKIkt0qwHVdcgSBeRMxKbn)Pk76IFAEDDX3pM4cOpW)KdDNyYd0pLWQzyP)elirRjo68oDhHaRaagM5q3jMGeE9IeybjK3Li3OiVt3riWkaGHziRKX)Pk76IFs0qwHVdcgSBeRMx89JjUa(h4FYHUtm5b6Nsy1mS0FUbPOY7lyNDT4ejBBvcasyWcsa4)Pk76IF23W22xWF)yIl(9a)to0DIjpq)ucRMHL(ZkK3qf(oIoO(SZqlsyasGZpvzxx8tPMsov21fUuz7FMkB7cDG)5q1LV21fF)yIlG8b(NCO7etEG(Pk76IFk1uYPYUUWLkB)ZuzBxOd8pTTgefs((7FAcz5nS1(b(Xe3h4FYHUtm5b67htAFG)jh6oXKhOVFmX3d8p5q3jM8a99JPNFG)jh6oXKhOVFmn8b(NQSRl(P511f)KdDNyYd03F)9pXddT1fpM0IdT4GdT4GFzA)5ifgv4B)jG7G5bBMGeEgjuzxxGePY22mY4pvWE9G)CwdaIib2ibGtgGkv)0eEuvI)jnrcGs3rqcAew7vKGgnk)1gzKMiXA3MwabmWWV6vWDwEdyyRbWK21fsOs1yyRbjYinrcAWewjKGwdPdjOfhAXbzezKMibG4Qg(SfqazKMibGHe0aHWeKWtvbbjaCazM(CgzKMibGHe0aHWeKWtvD5RDDbsKkBNrgPjsayibnqimbj8etfpmsau6ocsmxlorqcAyBp42tGeNzxxKrgPjsayiHNgpCGedhKrc13hYwBHhonos4Zbd1MrcGUGrI5AXjcsyBvcGnJmImstKWtJ)SeSzcsSzQdYiH8g2AJeB2VcBgjObPKnBlsexayRkCGcmHeQSRlSiXfPXZiJQSRlSztilVHT2luj1caYOk76cB2eYYByRn2lyqDhbzuLDDHnBcz5nS1g7fmuq)boATRlqgPjsmd10UEnsa1IGeBqkkMGe2wBlsSzQdYiH8g2AJeB2VclsObbjmHmGzEDxHpsuwKGCbNrgvzxxyZMqwEdBTXEbdBOM21RD2wBlYOk76cB2eYYByRn2lyyEDDbYiYinrcpn(ZsWMjibJhgoos01aJe9kJeQSpisuwKqXJwjDN4mYOk76c7YqfehfKz6ZiJQSRlSyVGXoDhXrbchNUIArExICJImrdzf(oiyWUrSAErgYkzCpWlwK3Li3OiVt3riWkaGHziRKX96flTM4OZ70DecScayyMdDNycwrgvzxxyXEbJndTmeGk8rgvzxxyXEbdfk1GDMGjltxrTOYUWd74Ghk2AWcTE9cbdEmC9acgL0zEJyyMWuLSAdauCqgvzxxyXEbJu5V2wNNmiXFGJMUIAzdsrLbJ1lnUZ2qo871mOjYOk76cl2lyOHKTnutoPMsiJQSRlSyVGbvb5D6ocYOk76cl2lySvF3r5AyjbWImQYUUWI9cgGw2vnpyPROwK3Li3Oit0qwHVdcgSBeRMxKH8GwH1aajoiJQSRlSyVGbOLDvZd0f6aVav6tadaSUD57GmXTb7(cKrv21fwSxWa0YUQ5b6cDGxgyidqVQwhLg(0vul4vExICJImrdzf(oiyWUrSAErgYdAfwpWYgKIkt0qwHVdcgSBeRMxKbn9acgCURb21NZZgGpSImQYUUWI9cgGw2vnpqxOd8IAxXJgS1bv6FqN8GAIUIAHWBqkQmuP)bDYdQjhH3GuuzYnkqgvzxxyXEbdql7QMhOl0bErTR4rd26Gk9pOtEqnrxrT0k0N78kRPEnBk7XWhUEW0yWY0KjzcS27uf(UkaW8iiJQSRlSyVGbOLDvZd0f6aVO2v8ObBDqL(h0jpOMOROw2GuuzIgYk8DqWGDJy18ImOPheEdsrLHk9pOtEqn5i8gKIkdA6bwyAmyzAYKmbw7DQcFxfayEeKrv21fwSxWW866c6kQLnifvMOHScFhemy3iwnVidAImQYUUWI9cgenKv47GGb7gXQ5f0vulyP1ehDENUJqGvaadZCO7et86flY7sKBuK3P7ieyfaWWmKvY4iJQSRlSyVGrFdBBFbtxrTSbPOY7lyNDT4ejBBvcGblaEKrv21fwSxWqQPKtLDDHlv2MUqh4LHQlFTRlOROwQqEdv47i6G6ZodTgGdYOk76cl2lyi1uYPYUUWLkBtxOd8IT1GOqcYiYOk76cBEO6Yx76If8OdMfSKUD6ocDf1YkRPEnBk7XmehVEXlw8HhOPhRSM61SPShdqbuSImstKaWnK3qf(ibrhuFgjGmngSG8ahnsuwKGwd9KqIJcjgu8hjwzn1RiH9shDiHH44jHehfsmO4psSYAQxrIkqcfj8HhOzgzuLDDHnpuD5RDDb2lyqyTxD2gwaW0vulviVHk8DeDq9zNHwdwWjBi9wzn1R5bf)96fVyXhEGMEuH8gQW3r0b1NDgAnybNmTgsVvwt9AEqXFSImstKGg5cprJejUrcnqcg)lBxHpsau6ocsmxlorqcc8mZiJQSRlS5HQlFTRlWEbdcR9QZ2WcaMUIAXQ4HD70DeNDT4eXJkK3qf(oIoO(SZqRb44XgKIkVt3rC21ItKmOPhBqkQ8oDhXzxlorYqEqRWogUzdPNVKGmQYUUWMhQU81UUa7fmkjVpWG4OoyxniHPROwwzn1RztzpMH4ay4LwCO3gKIkVt3rC21ItKmOjwrgrgvzxxyZ2wdIcjlew7vNTHfamDf1cemkPZ8gXWmHPkz1JTGloEGxS0AIJoVVGT9bhYCO7et86flY7sKBuK3xW2(GdziRKX96DdsrLjAiRW3bbd2nIvZlYGMyfzuLDDHnBBnikKG9cg70DecScayiDf1cw2GuuzIgYk8DqWGDJy18ImOjYOk76cB22Aquib7fmgui8gb5GqxrTSbPOY7lyNDT4ejd5bTc7y4MnKE(ssMXFwc2SxV4DdsrL3xWo7AXjsgYdAf2XwGGbN7AGD95WNxVBqkQ8(c2zxlorYqEqRWo2cE9LeSL3Li3OiVt3riWkaGHziRKXPxRjo68oDhHaRaagM5q3jMqpAXQxVBqkQ8(c2zxlorY2wLamg(WQhqWOKoZBedZeMQKvBWcT4GmQYUUWMTTgefsWEbJvwHTJTwoKmDf1cw2GuuzIgYk8DqWGDJy18ImOjYOk76cB22Aquib7fm2P7iU9vj6kQf5Qc9zRJcQYUUqtgSGBg)8aVBqkQ8kpC2wTLnBBvcWyl41qaZAYPKRvOp328oDhXTVkHvVETMCk5Af6ZTnVt3rC7RsgqlwrgvzxxyZ2wdIcjyVGXGcH3iihe6kQLnifvEFb7SRfNizBRsagBbq9O1ehD(SwqfoEMdDNyIhqWOKoZBedZeMQKvBWcUgImQYUUWMTTgefsWEbJ9fSTp4aDf1cemkPZ8gXqdwWfhC8alBqkQmrdzf(oiyWUrSAErg0ezuLDDHnBBnikKG9cgew7vNTHfamDf1cemkPZ8gXWmHPkz1JTGxCne7nifvMOHScFhemy3iwnVidAspdX2AYPKRvOp328kRW2zBybatVwtC05vwH9gYkammZHUtmHE0IvVE7AGD95ifpgU4GmQYUUWMTTgefsWEbdcR9QtdIJWsDC6kQfRjNsUwH(CBZew7vNgehHL64gSGpKrv21f2ST1GOqc2lyabd2zBybatxrTGx5Qc9zRJcQYUUqtgSGBg)86DdsrLjAiRW3bbd2nIvZlYGMy1diyW5UgyxFo8zWIVKGmQYUUWMTTgefsWEbJvwHTZ2WcaMUIAzdsrLjAiRW3bbd2nIvZlYGME9cbdo31a76Z55X8LeKrv21f2ST1GOqc2lySt3rC7Rs0vulBqkQmrdzf(oiyWUrSAErg0ezuLDDHnBBnikKG9cgew7vNgehHL640vulBqkQSewd2lCw5bc95mOPxVTM4OZq1SioclVbZZwDDrMdDNyIxVwtoLCTc952MjS2Roniocl1XnyHwKrv21f2ST1GOqc2lyiVWcoy21fiJQSRlSzBRbrHeSxWyNUJ42xLqgvzxxyZ2wdIcjyVGXkRW2zBybatxrTabdo31a76ZHVX8LeVE3Guu59fSZUwCIKTTkbWaafzuLDDHnBBnikKG9cgGw2vnpqxOd8Ip8cFRZewdAYbvFgzuLDDHnBBnikKG9cgqWGD2gwaWiJQSRlSzBRbrHeSxWqHsnyxFqihnDf1cemkPZ8gXWmHPkz1gqloF)9)a]] )

end