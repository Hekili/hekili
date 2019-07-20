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

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower )

    local spendHook = function( amt, resource )
        if amt > 0 then
            if resource == "runes" then
                gain( amt * 10, "runic_power" )

                if talent.rune_strike.enabled then gainChargeTime( "rune_strike", amt ) end

                if azerite.eternal_rune_weapon.enabled and buff.dancing_rune_weapon.up then
                    if buff.dancing_rune_weapon.expires - buff.dancing_rune_weapon.applied < buff.dancing_rune_weapon.duration + 5 then
                        buff.dancing_rune_weapon.expires = min( buff.dancing_rune_weapon.applied + buff.dancing_rune_weapon.duration + 5, buff.dancing_rune_weapon.expires + ( 0.5 * amt ) )
                        buff.eternal_rune_weapon.expires = min( buff.dancing_rune_weapon.applied + buff.dancing_rune_weapon.duration + 5, buff.dancing_rune_weapon.expires + ( 0.5 * amt ) )
                    end
                end

            elseif resource == "runic_power" then
                local rp = runic_power

                if talent.red_thirst.enabled then cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - amt / 10 ) end
            end
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

        potion = "superior_battle_potion_of_strength",

        package = "Blood",        
    } )


    spec:RegisterSetting( "save_blood_shield", true, {
        name = "Save |T237517:0|t Blood Shield Absorb",
        desc = "If checked, the default priority (or any priority checking |cFFFFD100save_blood_shield|r) will try to avoid letting your |T237517:0|t Blood Shield fall off during lulls in damage.",
        type = "toggle",
        width = 1.5
    } )   


    spec:RegisterPack( "Blood", 20190720.1830, [[dyKjDaqiGkpcb5seqytuv5tarAuaHtPuvRcb1RqOMfb1TiIAxc9leyykvoMI0YicpJamnIiDnc02aI6BavzCkvX5aQQ1rvvzEevDpf1(iihKiIfcKEibKMivvPUivvjTrciAKaruNeicRKO8sQQsCtQQQ2jc5PkzQaL9QQ)kyWiDyslgWJPyYqUmQntOptvgTs50s9AQkZMk3wb7w0Vvz4k0XbIilhQNtPPl56iA7kvPVRigpbuNNOY6PQkMprA)G(N(G9lKw8tKe7Mc(7apj2fNUhbSNPt)vj3i)Rr14t94FL6a)lqD3H(1OkN7u0d2VShj2W)A1dKoT6lfOyvS(faz7kqI8b(fsl(jsIDtb)DGNe7It3JaazbSNFzhzZtKecU7xBncX5d8leBn)IqqkOU7qqQ)M1Ads9xY2BRGYieKUv1O1)iGaVU2ibIMBGaBpq60QV0GvXIaBpyGYieKkJ0jhKkXoHHuj2nf8HujdPtbp)ta7GYGYieKkq300JT(hugHGujdPsccXii1)7ebPcKyM9hocLriivYqQKGqmcs9)UApT6lHuxBRiugHGujdPsccXiifKU09YqkOU7qq6ARzhcsLea7HbaPq6nw9LrOmcbPsgs9)dZqQ65HzRT3l7Kds94KXAXqkOxYq6ARzhcsTLA8zJ)Y12Y(G9RHUApT6lFWEIM(G9lovahJEq)Lb3fJB9xBS6QT4OPGu5Hub3bPsLcPGasbhK6HpYri1piDJvxTfhnfKkpKcYGmKU)Vut1x(R9QdJnUnba3DOVEIK4b7xCQaog9G(ldUlg36V60CdD6fq6G6XbbTqQqZq6UOGqkHH0nwD1wCqfyivQuifeqk4Gup8rocP(bPDAUHo9ciDq94GGwivOziDxucbHucdPBS6QT4GkWq6()snvF5VqSwBbBHBF8xprc4b7xCQaog9G(ldUlg36VS6E5aG7ouWU1SdbP(bPDAUHo9ciDq94GGwiviiDhK6hKcqkkgbC3Hc2TMDOi5iK6hKcqkkgbC3Hc2TMDOiMh0oTqQ8q60OGqkHHupd6xQP6l)fI1AlylC7J)6jssFW(fNkGJrpO)YG7IXT(RnwD1wC0uqQ8qQG7GujdPGasLyhKsyifGuumc4UdfSBn7qrYriD)FPMQV8xTHboYefepC1fjI)6RFzlnrkg9G9en9b7xCQaog9G(ldUlg36VWKzBcJ3eghrSyB6csLFgsNUds9dsbbKcoiTuhNve4s2whEiYPc4yeKkvkKcoi1CNdDtYiWLSTo8qeZksoivQuifGuumI000PxatMCycRJxgjhH09)LAQ(YFHyT2c2c3(4VEIK4b7xCQaog9G(ldUlg36VahKcqkkgrAA60lGjtomH1XlJKJ)snvF5VaC3Hq4o9X4VEIeWd2V4ubCm6b9xgCxmU1FbcifGuumcCjhSBn7qrmpODAHu5NHumzYXQh4qDbbaPsLcPaKIIrGl5GDRzhkI5bTtlKk)mKcci1ZGGuIHuZDo0njJaU7qiCN(yCeZksoiLWqAPooRiG7oec3Ppgh5ubCmcsjmKkbKUpKkvkKcqkkgbUKd2TMDOOTuJpiv(zivsH09Hu)Gumz2MW4nHXrel2MUGuHMHuj29l1u9L)AqX4BcMt0xprs6d2V4ubCm6b9xgCxmU1Fz2uShBdIy1u9LQdsfAgsNg3dK6hKccifGuumUXdNTuBBJ2sn(Gu5NHuqaPccPsgsTJSZfkf7XLnc4UdfaU2bP7dPsLcP2r25cLI94YgbC3Hcax7GuHGujG09)LAQ(YFb4UdfaU291tKGpy)ItfWXOh0FzWDX4w)faPOye4soy3A2HI2sn(Gu5HubHu)G0sDCwXZAjvSCrovahJGu)Gumz2MW4nHXrel2MUGuHMH0Pc(l1u9L)AqX4BcMt0xprG8d2V4ubCm6b9xgCxmU1FHjZ2egVjmgsfAgsNUBhK6hKcoifGuumI000PxatMCycRJxgjh)LAQ(YFbCjBRdp81te49G9lovahJEq)Lb3fJB9xyYSnHXBcJJiwSnDbPYpdPGasNkiKsmKcqkkgrAA60lGjtomH1XlJKJqkHHubHuIHu7i7CHsXECzJBSIRGTWTpgsjmKwQJZkUXkUaWS6JXrovahJGucdPsaP7dPsLcPLI94konw9ahQlGAgsLhsNU7xQP6l)fI1AlylC7J)6jAppy)ItfWXOh0FzWDX4w)LDKDUqPypUSreR1wqtuaXgvoivOziva)snvF5VqSwBbnrbeBu5(6jc8FW(fNkGJrpO)YG7IXT(lqaPMnf7X2GiwnvFP6GuHMH0PX9aPsLcPaKIIrKMMo9cyYKdtyD8Yi5iKUpK6hKIjtow9ahQliaivOzi1ZG(LAQ(YFHjtoylC7J)6jA6UhSFXPc4y0d6Vm4UyCR)cGuumI000PxatMCycRJxgjhHuPsHumzYXQh4qDbjfsLhs9mOFPMQV8xBSIRGTWTp(RNOPtFW(fNkGJrpO)YG7IXT(lasrXisttNEbmzYHjSoEzKC8xQP6l)fG7oua4A3xprtL4b7xCQaog9G(ldUlg36VaiffJgCpyVmynhj2JJKJqQuPqAPooRiwhBuaXMBy8SD1xg5ubCmcsLkfsTJSZfkf7XLnIyT2cAIci2OYbPcndPs8l1u9L)cXATf0efqSrL7RNOPc4b7xQP6l)L5sl5Wy1x(lovahJEq)6jAQK(G9l1u9L)cWDhkaCT7xCQaog9G(1t0ubFW(fNkGJrpO)YG7IXT(lmzYXQh4qDbbaPYdPEgeKkvkKcqkkgbUKd2TMDOOTuJpiviifK)LAQ(YFTXkUc2c3(4VEIMcYpy)ItfWXOh0FL6a)lp8LE2WiUhuxaRE8Vut1x(lp8LE2WiUhuxaRE8xprtbVhSFPMQV8xyYKd2c3(4FXPc4y0d6xprt3Zd2V4ubCm6b9xgCxmU1FHjZ2egVjmoIyX20fKkeKkXUFPMQV8xk2OjhQdJ5S(6RFHyrL0vpyprtFW(LAQ(YFn0jkiIz2F4FXPc4y0d6xprs8G9lovahJEq)Lb3fJB9xM7COBsgrAA60lGjtomH1XlJywrYbP(bPGasbhKAUZHUjzeWDhcH70hJJywrYbPsLcPGdsl1XzfbC3Hq4o9X4iNkGJrq6()snvF5VaC3HcIKy5(6jsapy)snvF5VaySLX(607xCQaog9G(1tKK(G9lovahJEq)Lb3fJB9xM7COBsgrAA60lGjtomH1XlJyEq70cPcbPG)UFPMQV8xKwo0fpy)6jsWhSFXPc4y0d6VsDG)fw9hez6ZgaAVaMrbaYQU8xQP6l)fw9hez6ZgaAVaMrbaYQU8RNiq(b7xCQaog9G(Ruh4FnWy2xTP2GOME)snvF5Vgym7R2uBqutVVEIaVhSFXPc4y0d6Vm4UyCR)cGuumI000PxatMCycRJxgjh)LAQ(YFnEvF5xpr75b7xCQaog9G(ldUlg36VahKwQJZkc4UdHWD6JXrovahJGuPsHuWbPM7COBsgbC3Hq4o9X4iMvKC)snvF5VqAA60lGjtomH1Xl)6jc8FW(fNkGJrpO)YG7IXT(lasrXiWLCWU1SdfTLA8bPcndPG3Vut1x(R6gaS1L8xprt39G9lovahJEq)Lb3fJB9xDAUHo9ciDq94GGwiviiD3Vut1x(lJ6Cb1u9LbxBRF5ABfsDG)1qxTNw9LF9enD6d2V4ubCm6b9xQP6l)LrDUGAQ(YGRT1VCTTcPoW)YwAIum6RV(1iMn3aGwpyF91V2lJT9LprsSBk4Vd8KyxC6EM(Rjko70Z(lqIHXdxmcsfaKQMQVesDTTSrOSFnIpX2X)IqqkOU7qqQ)M1Ads9xY2BRGYieKUv1O1)iGaVU2ibIMBGaBpq60QV0GvXIaBpyGYieKkJ0jhKkXoHHuj2nf8HujdPtbp)ta7GYGYieKkq300JT(hugHGujdPsccXii1)7ebPcKyM9hocLriivYqQKGqmcs9)UApT6lHuxBRiugHGujdPsccXiifKU09YqkOU7qq6ARzhcsLea7HbaPq6nw9LrOmcbPsgs9)dZqQ65HzRT3l7Kds94KXAXqkOxYq6ARzhcsTLA8zJqzqzecs9xfy2qwmcs59Yy5G0QhyiT2yivn1HH02cP6E12PaoocLPMQV0op0jkiIz2FyOm1u9LwINjaWDhkisILt4wC2CNdDtYisttNEbmzYHjSoEzeZkso)ab4m35q3Kmc4UdHWD6JXrmRi5KkfCL64SIaU7qiCN(yCKtfWXO9HYut1xAjEMaagBzSVo9GYut1xAjEMaslh6IhSc3IZM7COBsgrAA60lGjtomH1XlJyEq70ke4VdktnvFPL4zciTCOlEq4uh4zS6piY0Nna0EbmJcaKvDjuMAQ(slXZeqA5qx8GWPoWZdmM9vBQniQPhuMAQ(slXZemEvFPWT4maPOyePPPtVaMm5WewhVmsocLPMQV0s8mbinnD6fWKjhMW64Lc3IZGRuhNveWDhcH70hJJCQaogjvk4m35q3Kmc4UdHWD6JXrmRi5GYut1xAjEMG6gaS1LSWT4maPOye4soy3A2HI2sn(eAg8GYut1xAjEMaJ6Cb1u9LbxBlHtDGNh6Q90QVu4wCUtZn0PxaPdQhhe0k0oOm1u9LwINjWOoxqnvFzW12s4uh4zBPjsXiOmOm1u9L24qxTNw9LZ7vhgBCBcaU7qc3IZBS6QT4OPKxWDsLccW5HpYr)2y1vBXrtjpidY7dLriifKin3qNEqkshupgsXmijYgZdCwqABHujeuGaspriDqfyiDJvxTbP2ZDcdPcUtGaspriDqfyiDJvxTbPDcPkK6HpYXiuMAQ(sBCOR2tR(sINjaXATfSfU9Xc3IZDAUHo9ciDq94GGwHM3ffKWBS6QT4GkWsLccW5HpYr)60CdD6fq6G6XbbTcnVlkHGeEJvxTfhubEFOmcbP(7lbPfK64cs1eszbUTvNEqkOU7qq6ARzhcsr4BmcLPMQV0gh6Q90QVK4zcqSwBbBHBFSWT4Sv3lhaC3Hc2TMDi)60CdD6fq6G6XbbTcTZpasrXiG7ouWU1Sdfjh9dGuumc4UdfSBn7qrmpODALFAuqc7zqqzQP6lTXHUApT6ljEMG2WahzIcIhU6IeXc3IZBS6QT4OPKxWDsgesSJWaKIIra3DOGDRzhksoUpuguMAQ(sB0wAIumAgXATfSfU9Xc3IZyYSnHXBcJJiwSnDj)80D(bcWvQJZkcCjBRdpe5ubCmsQuWzUZHUjze4s2whEiIzfjNuPaKIIrKMMo9cyYKdtyD8Yi54(qzQP6lTrBPjsXiINjaWDhcH70hJfUfNbhaPOyePPPtVaMm5WewhVmsocLPMQV0gTLMifJiEMGbfJVjyorc3IZGaGuumcCjhSBn7qrmpODALFgtMCS6bouxqasLcqkkgbUKd2TMDOiMh0oTYpdcpdIyZDo0njJaU7qiCN(yCeZksocxQJZkc4UdHWD6JXrovahJiSe7lvkaPOye4soy3A2HI2sn(KFws33pmz2MW4nHXrel2MUeAwIDqzQP6lTrBPjsXiINjaWDhkaCTt4wC2SPyp2geXQP6lvNqZtJ7Xpqaqkkg34HZwQTTrBPgFYpdcbLSDKDUqPypUSra3DOaW1U9Lk1oYoxOuShx2iG7oua4ANqsSpuMAQ(sB0wAIumI4zcgum(MG5ejClodqkkgbUKd2TMDOOTuJp5f0VsDCwXZAjvSCrovahJ8dtMTjmEtyCeXITPlHMNkiuMAQ(sB0wAIumI4zcaUKT1HheUfNXKzBcJ3egl080D78dCaKIIrKMMo9cyYKdtyD8Yi5iuMAQ(sB0wAIumI4zcqSwBbBHBFSWT4mMmBty8MW4iIfBtxYpdIPcsmaPOyePPPtVaMm5WewhVmsosybj2oYoxOuShx24gR4kylC7JjCPooR4gR4caZQpgh5ubCmIWsSVuPLI94konw9ahQlGAw(P7GYut1xAJ2stKIreptaI1AlOjkGyJkNWT4SDKDUqPypUSreR1wqtuaXgvoHMfauMAQ(sB0wAIumI4zcWKjhSfU9Xc3IZGWSPyp2geXQP6lvNqZtJ7rQuasrXisttNEbmzYHjSoEzKCCF)WKjhREGd1feGqZEgeuMAQ(sB0wAIumI4zc2yfxbBHBFSWT4maPOyePPPtVaMm5WewhVmsokvkMm5y1dCOUGKkVNbbLPMQV0gTLMifJiEMaa3DOaW1oHBXzasrXisttNEbmzYHjSoEzKCektnvFPnAlnrkgr8mbiwRTGMOaInQCc3IZaKIIrdUhSxgSMJe7XrYrPsl1XzfX6yJci2CdJNTR(YiNkGJrsLAhzNluk2JlBeXATf0efqSrLtOzjGYut1xAJ2stKIreptG5sl5Wy1xcLPMQV0gTLMifJiEMaa3DOaW1oOm1u9L2OT0ePyeXZeSXkUc2c3(yHBXzmzYXQh4qDbbiVNbjvkaPOye4soy3A2HI2sn(ecKHYut1xAJ2stKIreptaPLdDXdcN6ap7HV0ZggX9G6cy1JHYut1xAJ2stKIreptaMm5GTWTpgktnvFPnAlnrkgr8mbk2OjhQdJ5SeUfNXKzBcJ3eghrSyB6sij29lLS2o8Vw9GafsjgsbjZ(Ax)1x)d]] )
end
