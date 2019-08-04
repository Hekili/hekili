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


    spec:RegisterPack( "Blood", 20190803, [[dye1BaqiGOhbu6seqYMeK(KsfAukv5ukvAveGxHqnlIu3IiPDrv)cbnmfPJbuTmcQNbeMgqHRrG2Msf9nbbJdOOZPuvwNsfmpII7Pu2hb5Gkvvlei9qcOAIejQlkiKnsarJKacDsbHALevVKasDtIezNiKNQKPIa7f0FfAWiDyklgWJjzYqUmQntOplWOvuNwQxlOMnPUTcTBr)wLHRGJtablhQNtLPl56iA7cI(UIy8ejCEIsRNakZNi2VQgcoKa4czfdjs4PGVVPG5uq4fgCqSVPccxLSdmCnyQWwadxPnYWfO67qW1GjR(meKa4YDKyfdxREKuBvFPahBIfCbq26keNqa4czfdjs4PGVVPG5uq4fgCqSVPGaUCdScsKWcofUMBeItiaCHyNcUa7tbvFh6Psz2Q5NkqNDWC9Yb7tNRAWTdesyqxZKaE1nsORhj1w1xQWMyrORhvVCW(09tgq6QNccPFQWtbFFpvQpD6(2bWy6l)Ld2NkWNTmGD7WlhSpvQpD)ieJEQuQt0tfiXmlWy)lhSpvQpD)ieJEQuQRoWQ(YNQBx5F5G9Ps9P7hHy0t3XLfs(PGQVd901CZA0t3pG7Wa74tVHQV0)Yb7tL6tdrHKZNoEy(PwqaMDUoKSw2NgWjJTIFkOxYpDn3Sg9uxzQWopCPBx5GeaxJD1bw1xcjase4qcGlonanJGGcxkCxmUn4AMnDn7hu1tL5Pco9PsK809EkiFAa(ihEAOpDMnDn7hu1tL5P7CNpDx4YuvFjCfsBCOXTkcOVdblircdjaU40a0mcckCPWDX42GRov3yNbrKnAbCuq3tfA7Pt9c(ub80z201SF0KINkrYt37PG8Pb4JC4PH(0ov3yNbrKnAbCuq3tfA7Pt9cl4tfWtNztxZ(rtkE6UWLPQ(s4cXwnhDfUdZWcseiGeaxCAaAgbbfUu4UyCBWLZcjhb03HIU5M1ONg6t7uDJDger2OfWrbDpvONo9PH(uasrrpG(ou0n3Sg5jhEAOpfGuu0dOVdfDZnRrEmpAD6EQmpfCVGpvapnqHGltv9LWfITAo6kChMHfKiWasaCXPbOzeeu4sH7IXTbxZSPRz)GQEQmpvWPpvQpDVNk80NkGNcqkk6b03HIU5M1ip5Wt3fUmv1xcxTIboYeffpC1fjIHfSGlxzjYWiibqIahsaCXPbOzeeu4sH7IXTbxyYSvXHBcJ9iwSvD9uz2Ek4tFAOpDVNcYNwMMZYdCj7Qdp650a0m6PsK8uq(u1DA0nj9axYU6WJEmBizFQejpfGuu0JSu1zqetMCCcBdx6jhE6UWLPQ(s4cXwnhDfUdZWcsKWqcGlonanJGGcxkCxmUn4cKpfGuu0JSu1zqetMCCcBdx6jhGltv9LWfG(oec3zygdlirGasaCXPbOzeeu4sH7IXTbx79uasrrpWLC0n3Sg5X8O1P7PYS9umzY(Qh5yDrq8ujsEkaPOOh4so6MBwJ8yE0609uz2E6EpnqHEkXpvDNgDtspG(oec3zyg7XSHK9Pc4PLP5S8a67qiCNHzSNtdqZONkGNk8t39PsK8uasrrpWLC0n3Sg5DLPc)uz2Eky80DFAOpftMTkoCtyShXITQRNk02tfEkCzQQVeUgnm(MG5eblirGbKa4ItdqZiiOWLc3fJBdUuZgoGDrrSPQ(st)uH2Ek4EW8PH(09EkaPOOFMhpxzU25DLPc)uz2E6EpvWNk1N6gyTowgoGlNhqFhkcCT(P7(ujsEQBG16yz4aUCEa9DOiW16Nk0tf(P7cxMQ6lHla9DOiW1AybjsqibWfNgGMrqqHlfUlg3gCbqkk6bUKJU5M1iVRmv4NkZt35td9PLP5S8NZrAyz9CAaAg90qFkMmBvC4MWypIfBvxpvOTNcUGWLPQ(s4A0W4BcMteSGeTtibWfNgGMrqqHlfUlg3gCHjZwfhUjm(PcT9uWNo9PH(uq(uasrrpYsvNbrmzYXjSnCPNCaUmv1xcxaxYU6WJWcsuiajaU40a0mcckCPWDX42Glmz2Q4WnHXEel2QUEQmBpDVNcUGpL4Ncqkk6rwQ6miIjtooHTHl9KdpvapvWNs8tDdSwhldhWLZpZgUIUc3H5NkGNwMMZYpZgUaWSfMXEonanJEQaEQWpD3NkrYtREKJ1frn)uzEk4tHltv9LWfITAo6kChMHfKiWesaCXPbOzeeu4sH7IXTbxUbwRJLHd4Y5rSvZrlrreRmzFQqBpfeWLPQ(s4cXwnhTefrSYKfwqI2hKa4ItdqZiiOWLc3fJBdU27PQzdhWUOi2uvFPPFQqBpfCpy(ujsEkaPOOhzPQZGiMm54e2gU0to80DFAOpftMSV6rowxeepvOTNgOqWLPQ(s4ctMC0v4omdlirGpfsaCXPbOzeeu4sH7IXTbxaKIIEKLQodIyYKJtyB4sp5WtLi5PyYK9vpYX6IGXtL5PbkeCzQQVeUMzdxrxH7WmSGebo4qcGlonanJGGcxkCxmUn4cGuu0JSu1zqetMCCcBdx6jhGltv9LWfG(oue4AnSGebUWqcGlonanJGGcxkCxmUn4cGuu0RW9O7YOtDK4a2to8ujsEAzAolp2gAueXQBC4CD1x650a0m6PsK8u3aR1XYWbC58i2Q5OLOiIvMSpvOTNkmCzQQVeUqSvZrlrreRmzHfKiWbbKa4YuvFjCPU0roou9LWfNgGMrqqHfKiWbdibWLPQ(s4cqFhkcCTgU40a0mcckSGebUGqcGlonanJGGcxkCxmUn4ctMSV6rowxeepvMNgOqpvIKNcqkk6bUKJU5M1iVRmv4Nk0t3jCzQQVeUMzdxrxH7WmSGeb(oHeaxCAaAgbbfUsBKHRa8LbU4aUhnDeBbmCzQQVeUcWxg4Id4E00rSfWWcse4HaKa4YuvFjCHjto6kChMHlonanJGGclirGdMqcGlonanJGGcxkCxmUn4ctMTkoCtyShXITQRNk0tfEkCzQQVeUmSYsowhgZzblybxiw0i1fKairGdjaUmv1xcxJDIIIyMfymCXPbOzeeuybjsyibWfNgGMrqqHlfUlg3gCPUtJUjPhzPQZGiMm54e2gU0Jzdj7td9P79uq(u1DA0nj9a67qiCNHzShZgs2NkrYtb5tltZz5b03Hq4odZypNgGMrpDx4YuvFjCbOVdffjXYclirGasaCzQQVeUaySJXH7maU40a0mcckSGebgqcGltv9LWfPJJDXJo4ItdqZiiOWcsKGqcGlonanJGGcxkCxmUn4cGuu0JSu1zqetMCCcBdx6jhGltv9LW1Wv9LWcs0oHeaxCAaAgbbfUu4UyCBWfiFAzAolpG(oec3zyg750a0m6PsK8uq(u1DA0nj9a67qiCNHzShZgsw4YuvFjCHSu1zqetMCCcBdxclirHaKa4ItdqZiiOWLc3fJBdUaiff9axYr3CZAK3vMk8tfA7PHaCzQQVeUQBeWvxYWcseycjaU40a0mcckCPWDX42GRov3yNbrKnAbCuq3tf6PtHltv9LWLY06OPQ(YOUDfCPBxftBKHRXU6aR6lHfKO9bjaU40a0mcckCzQQVeUuMwhnv1xg1TRGlD7QyAJmC5klrggblybxdywDJawbjawWcUcjJD9LqIeEk47BAii8up4HGWccxtmC2zGdUcXJdhUy0tbXtnv1x(uD7kN)Ldxd4tS1mCb2NcQ(o0tLYSvZpvGo7G56Ld2Nox1GBhiKWGUMjb8QBKqxpsQTQVuHnXIqxpQE5G9P7NmG0vpfes)uHNc((EQuF609TdGX0x(lhSpvGpBza72HxoyFQuF6(rig9uPuNONkqIzwGX(xoyFQuF6(rig9uPuxDGv9Lpv3UY)Yb7tL6t3pcXONUJllK8tbvFh6PR5M1ONUFa3Hb2XNEdvFP)Ld2Nk1NgIcjNpD8W8tTGam7CDizTSpnGtgBf)uqVKF6AUzn6PUYuHD(x(lhSpnejfSISy0t5qYyzFA1J8tRz(PMQo8tB3tTqAT2a0S)LBQQV0Tn2jkkIzwGXVCtv9LoI3ieqFhkksILv6wCtDNgDtspYsvNbrmzYXjSnCPhZgs2q3dKQ70OBs6b03Hq4odZypMnKSsKaYY0CwEa9DieUZWm2ZPbOz0UVCtv9LoI3ieGXoghUZGxUPQ(shXBes64yx8O7LBQQV0r8gHdx1xkDlUbqkk6rwQ6miIjtooHTHl9KdVCtv9LoI3iezPQZGiMm54e2gUu6wCdKLP5S8a67qiCNHzSNtdqZijsaP6on6MKEa9DieUZWm2Jzdj7l3uvFPJ4ncRBeWvxYs3IBaKIIEGl5OBUznY7ktfwOTq4LBQQV0r8gHktRJMQ6lJ62vsN2iVn2vhyvFP0T4wNQBSZGiYgTaokOtOPVCtv9LoI3iuzAD0uvFzu3Us60g5nxzjYWOx(l3uvFPZp2vhyvF5wiTXHg3QiG(oK0T42mB6A2pOkzeCQej7bYa8roe6mB6A2pOkz25o39Ld2NgIt1n2zWtr2OfWpfZceiBmpYz9029uHfuG6PN4thnP4PZSPR5N6o9j9tfCQa1tpXNoAsXtNztxZpTZNApnaFKd(xUPQ(sNFSRoWQ(sI3ieXwnhDfUdZs3IBDQUXodIiB0c4OGoH2M6fuaZSPRz)OjfsKShidWh5qODQUXodIiB0c4OGoH2M6fwqbmZMUM9JMuS7lhSpvkF5owpvZ1tT8PSu0UQZGNcQ(o0txZnRrpfHVb)l3uvFPZp2vhyvFjXBeIyRMJUc3HzPBXnNfsocOVdfDZnRrH2P6g7miISrlGJc6eAAOaKIIEa9DOOBUznYtoekaPOOhqFhk6MBwJ8yE060jd4EbfqGc9Ynv1x68JD1bw1xs8gHTIboYeffpC1fjILUf3MztxZ(bvjJGtL6EcpvaaKIIEa9DOOBUznYtoS7l)LBQQV05DLLidJ2qSvZrxH7WS0T4gMmBvC4MWypIfBvxYSb(0q3dKLP5S8axYU6WJEonanJKibKQ70OBs6bUKD1Hh9y2qYkrcaPOOhzPQZGiMm54e2gU0toS7l3uvFPZ7klrggr8gHa67qiCNHzS0T4gibiff9ilvDgeXKjhNW2WLEYHxUPQ(sN3vwImmI4nchnm(MG5ejDlUThaPOOh4so6MBwJ8yE060jZgMmzF1JCSUiiKibGuu0dCjhDZnRrEmpAD6KzBVafIy1DA0nj9a67qiCNHzShZgswbuMMZYdOVdHWDgMXEonanJeGW7krcaPOOh4so6MBwJ8UYuHLzdm2numz2Q4WnHXEel2QUeAt4PVCtv9LoVRSezyeXBecOVdfbUwlDlUPMnCa7IIytv9LMwOnW9GzO7bqkk6N5XZvMRDExzQWYSTNGs1nWADSmCaxopG(oue4A9UsK4gyTowgoGlNhqFhkcCTwiH39LBQQV05DLLidJiEJWrdJVjyors3IBaKIIEGl5OBUznY7ktfwMDgAzAol)5CKgwwpNgGMrHIjZwfhUjm2JyXw1LqBGl4l3uvFPZ7klrggr8gHaxYU6WJs3IByYSvXHBcJfAd8PtdfKaKIIEKLQodIyYKJtyB4sp5Wl3uvFPZ7klrggr8gHi2Q5ORWDyw6wCdtMTkoCtyShXITQlz22dCbjgGuu0JSu1zqetMCCcBdx6jheGGe7gyTowgoGlNFMnCfDfUdZcOmnNLFMnCbGzlmJ9CAaAgjaH3vIKQh5yDruZYa(0xUPQ(sN3vwImmI4ncrSvZrlrreRmzLUf3CdSwhldhWLZJyRMJwIIiwzYk0giE5MQ6lDExzjYWiI3ietMC0v4omlDlUTNA2WbSlkInv1xAAH2a3dMsKaqkk6rwQ6miIjtooHTHl9Kd7gkMmzF1JCSUiieAlqHE5MQ6lDExzjYWiI3iCMnCfDfUdZs3IBaKIIEKLQodIyYKJtyB4sp5GejyYK9vpYX6IGHmbk0l3uvFPZ7klrggr8gHa67qrGR1s3IBaKIIEKLQodIyYKJtyB4sp5Wl3uvFPZ7klrggr8gHi2Q5OLOiIvMSs3IBaKIIEfUhDxgDQJehWEYbjsktZz5X2qJIiwDJdNRR(spNgGMrsK4gyTowgoGlNhXwnhTefrSYKvOnHF5MQ6lDExzjYWiI3iuDPJCCO6lF5MQ6lDExzjYWiI3ieqFhkcCT(LBQQV05DLLidJiEJWz2Wv0v4omlDlUHjt2x9ihRlcczcuijsaiff9axYr3CZAK3vMkSq78LBQQV05DLLidJiEJqshh7IhLoTrElaFzGloG7rthXwa)Ynv1x68UYsKHreVriMm5ORWDy(LBQQV05DLLidJiEJqdRSKJ1HXCws3IByYSvXHBcJ9iwSvDjKWtHlJSMpmCT6rb(tj(Pce5WTUHfSGqa]] )


end
