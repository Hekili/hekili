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


    spec:RegisterPack( "Blood", 20190720.1725, [[dyuXBaqiLQ6riGlHajBsb5tiqmkfvDkfvwfcQxHqnluf3cvs7IQ(fczykvogqSmGYZqLyAiiUgkyBii9neOghksDoLQ06uqP5HQ09uk7df1brr0cbspefHMOck6IkOqBubfmsfuvDsfuLvIQ6LiqQBQGk7ef6PkzQav7f0FfAWiDyklgWJjzYqUmXMrPplWOvKtl51kWSj1TvODl63QmCbDCfuvwoupNktxQRJOTRufFxrz8Oi58OsTEuemFuX(v1qqGGdxiRfiJGTdK9UJGbBNhK9cgdGbgC1ChkWvOPgybcCL2OaxGQVdbxHg36ZqqWHl3rIvcCTQrsT11LmrSX2WfazP7HxcbGlK1cKrW2bYE3rWGTZdYEbJqade4YfkkiJGXWo4AQqijHaWfsCk4Iapfu9DONomfRNEkbDwbt9ZNapDQ7q3Wserbvprc4v3irUAKuBDDPcBSnrUAu98jWt5tQ5(PGTJNNc2oq27t56tbHGhwUS75)8jWtzItwgiUH95tGNY1NYKiKGE6Wvj6PddyrycI)5tGNY1NYKiKGE6WvDfyDD5t1LR9pFc8uU(uMeHe0tjilBpYtbvFh6PRPs0ONYKaUddqqE6f21L(NpbEkxF6WDy5PwqawCUApIM7NgiPGTwEkOxkpDnvIg9uxBQbopCPlx7GGdxJvxbwxxcbhYiiqWHljnaTGGGcxkC1cUm4AsmDp5dv9t59PmS7PC4805F6(pnaFKHpDONojMUN8HQ(P8(ucLqF6CWLP66s4Ap2yyHlveqFhc2qgbdcoCjPbOfeeu4sHRwWLbxvQUXkdIiB0cKidUNY82t35z4Pe(PtIP7j)OXupLdNNo)t3)Pb4Jm8Pd90kv3yLbrKnAbsKb3tzE7P78GXWtj8tNet3t(rJPE6CWLP66s4cjwpfDnUgiWgYixGGdxsAaAbbbfUu4QfCzWLZ2Jeb03HIUPs0ONo0tRuDJvger2OfirgCpL5NU7Pd9uaswwpG(ou0nvIg5jdF6qpfGKL1dOVdfDtLOrESmAv6EkVpfepdpLWpnqHGlt11LWfsSEk6ACnqGnKrcbcoCjPbOfeeu4sHRwWLbxtIP7jFOQFkVpLHDpLRpD(Nc2UNs4NcqYY6b03HIUPs0ipz4tNdUmvxxcxLsaoYefzpCxnjsGnSHlxBjYWii4qgbbcoCjPbOfeeu4sHRwWLbxyYSuXWBMG9iHTuv)uE3Eki7E6qpD(NU)tBtlz7bUuC9Hh9sAaAb9uoCE6(pvDNgDZspWLIRp8OhlgI7NYHZtbizz9ilvvgeXKPeNjw4LEYWNohCzQUUeUqI1trxJRbcSHmcgeC4ssdqliiOWLcxTGldU2)PaKSSEKLQkdIyYuIZel8spziCzQUUeUa03Hq4khiyydzKlqWHljnaTGGGcxkC1cUm4A(NcqYY6bUuIUPs0ipwgTkDpL3TNIjtX31Oe7lYLNYHZtbizz9axkr3ujAKhlJwLUNY72tN)Pbk0tj(PQ70OBw6b03Hq4khiypwme3pLWpTnTKThqFhcHRCGG9sAaAb9uc)uWE6CpLdNNcqYY6bUuIUPs0iVRn1GNY72tjKNo3th6PyYSuXWBMG9iHTuv)uM3Eky7Glt11LW1OHX3mSKiydzKqGGdxsAaAbbbfUu4QfCzWLAYWbIlYInvxxA6NY82tbXZ0pDONo)tbizz9tY45AZvoVRn1GNY72tN)Pm8uU(uxOO1X2Wbs78a67qrGR0pDUNYHZtDHIwhBdhiTZdOVdfbUs)uMFkypDo4YuDDjCbOVdfbUsdBiJmabhUK0a0ccckCPWvl4YGlaswwpWLs0nvIg5DTPg8uEFkdpDON2MwY2FohPH52lPbOf0th6PyYSuXWBMG9iHTuv)uM3EkimaxMQRlHRrdJVzyjrWgYiHcbhUK0a0ccckCPWvl4YGlmzwQy4ntWpL5TNcYUDpDONU)tbizz9ilvvgeXKPeNjw4LEYq4YuDDjCbCP46dpcBiJemeC4ssdqliiOWLcxTGldUWKzPIH3mb7rcBPQ(P8U905Fkim8uIFkajlRhzPQYGiMmL4mXcV0tg(uc)ugEkXp1fkADSnCG0o)Ky4o6ACnqEkHFABAjB)Ky4gal2ab7L0a0c6Pe(PG905EkhopTRrj2xevYt59PGSdUmvxxcxiX6PORX1ab2qgzAi4WLKgGwqqqHlfUAbxgC5cfTo2goqANhjwpfTefrIY4(PmV9uUaxMQRlHlKy9u0suejkJBydzCVqWHljnaTGGGcxkC1cUm4A(NQMmCG4ISyt11LM(PmV9uq8m9t5W5PaKSSEKLQkdIyYuIZel8spz4tN7Pd9umzk(UgLyFrU8uM3EAGcbxMQRlHlmzkrxJRbcSHmcYoi4WLKgGwqqqHlfUAbxgCbqYY6rwQQmiIjtjotSWl9KHpLdNNIjtX31Oe7lsipL3NgOqWLP66s4AsmChDnUgiWgYiiGabhUK0a0ccckCPWvl4YGlaswwpYsvLbrmzkXzIfEPNmeUmvxxcxa67qrGR0WgYiiGbbhUK0a0ccckCPWvl4YGlaswwVcxJUlJo1rIdepz4t5W5PTPLS9ylSqrKOUXWZvDDPxsdqlONYHZtDHIwhBdhiTZJeRNIwIIirzC)uM3EkyWLP66s4cjwpfTefrIY4g2qgbHlqWHlt11LWL6sh5yyxxcxsAaAbbbf2qgbHqGGdxMQRlHla9DOiWvA4ssdqliiOWgYiimabhUK0a0ccckCPWvl4YGlmzk(UgLyFrU8uEFAGc9uoCEkajlRh4sj6MkrJ8U2udEkZpLqHlt11LW1Ky4o6ACnqGnKrqiui4WLKgGwqqqHR0gf4kaFzGlgIRrthXwGaxMQRlHRa8LbUyiUgnDeBbcSHmccbdbhUmvxxcxyYuIUgxde4ssdqliiOWgYiimneC4ssdqliiOWLcxTGldUWKzPIH3mb7rcBPQ(Pm)uW2bxMQRlHldRSuI9HXs2Wg2WfsynsDdbhYiiqWHlt11LW1yLOilweMGaxsAaAbbbf2qgbdcoCjPbOfeeu4sHRwWLbxQ70OBw6rwQQmiIjtjotSWl9yXqC)0HE68pD)NQUtJUzPhqFhcHRCGG9yXqC)uoCE6(pTnTKThqFhcHRCGG9sAaAb905Glt11LWfG(ouKLeZnSHmYfi4WLP66s4cqWobpOYa4ssdqliiOWgYiHabhUmvxxcxKojwTm6GljnaTGGGcBiJmabhUK0a0ccckCPWvl4YGlaswwpYsvLbrmzkXzIfEPNmeUmvxxcxHxxxcBiJekeC4ssdqliiOWLcxTGldU2)PTPLS9a67qiCLdeSxsdqlONYHZt3)PQ70OBw6b03Hq4khiypwme3WLP66s4czPQYGiMmL4mXcVe2qgjyi4WLKgGwqqqHlfUAbxgCbqYY6bUuIUPs0iVRn1GNY82tjy4YuDDjC13iGRVuGnKrMgcoCjPbOfeeu4sHRwWLbxvQUXkdIiB0cKidUNY8t3bxMQRlHlLP1rt11LrD5A4sxUoM2OaxJvxbwxxcBiJ7fcoCjPbOfeeu4YuDDjCPmToAQUUmQlxdx6Y1X0gf4Y1wImmc2WgUcXI6gbSgcoSHnCThb7QlHmc2oq27ocgSDEqyAUaxZmCwzGdUgEJHhUf0t5Ytnvxx(uD5AN)5dxH4JT0cCrGNcQ(o0thMI1tpLGoRGP(5tGNo1DOByjIOGQNib8QBKixnsQTUUuHn2MixnQE(e4P8j1C)uW2XZtbBhi79PC9PGS3HfSDp)NpbEktCYYaXnSpFc8uU(uMeHe0thUkrpDyalctq8pFc8uU(uMeHe0thUQRaRRlFQUCT)5tGNY1NYKiKGEkbzz7rEkO67qpDnvIg9uMeWDyacYtVWUU0)8jWt56thUdlp1ccWIZv7r0C)0ajfS1Ytb9s5PRPs0ON6AtnW5F(pFc80HrMsuKTGEQShbZ9t7AuEApjp1u9HFA5EQThR0gGw8pFt11LUTXkrrwSimb55BQUU0r8gra67qrwsm38uSBQ70OBw6rwQQmiIjtjotSWl9yXqCp087RUtJUzPhqFhcHRCGG9yXqCZHZ(TPLS9a67qiCLdeSxsdqlO5E(MQRlDeVreGGDcEqLbpFt11LoI3iI0jXQLr3Z3uDDPJ4nIcVUUKNIDdGKL1JSuvzqetMsCMyHx6jdF(MQRlDeVreYsvLbrmzkXzIfEjpf72(TPLS9a67qiCLdeSxsdqlioC2xDNgDZspG(oecx5ab7XIH4(5BQUU0r8gr9nc46lfEk2naswwpWLs0nvIg5DTPgW8gb)8nvxx6iEJiLP1rt11LrD5AEsBu2gRUcSUUKNIDRs1nwzqezJwGezWX8UNVP66shXBePmToAQUUmQlxZtAJYMRTezy0Z)5BQUU05hRUcSUUCBp2yyHlveqFhINIDBsmDp5dvnVmSJdN53paFKHdnjMUN8HQMxcLqN75tGNo8s1nwzWtr2OfipfldFKfwgLSFA5Ekymqq90J9PJgt90jX090tDN(45PmSJG6Ph7thnM6PtIP7PNw5tTNgGpYq)Z3uDDPZpwDfyDDjXBeHeRNIUgxdeEk2Tkv3yLbrKnAbsKbhZB78mq4jX09KF0ykoCMF)a8rgouLQBSYGiYgTajYGJ5TDEWyGWtIP7j)OXuZ98jWthMxsq6NQL(Pw(uHPkxxzWtbvFh6PRPs0ONIWxO)5BQUU05hRUcSUUK4nIqI1trxJRbcpf7MZ2Jeb03HIUPs0OHQuDJvger2OfirgCmVBiaswwpG(ou0nvIg5jdhcGKL1dOVdfDtLOrESmAv64fepdeoqHE(MQRlD(XQRaRRljEJOsjahzIIShURMej8uSBtIP7jFOQ5LHDCDEW2ryaswwpG(ou0nvIg5jdN75)8nvxx68U2sKHrBiX6PORX1aHNIDdtMLkgEZeShjSLQAE3az3qZVFBAjBpWLIRp8OxsdqlioC2xDNgDZspWLIRp8OhlgIBoCaizz9ilvvgeXKPeNjw4LEYW5E(MQRlDExBjYWiI3icqFhcHRCGG5Py32hGKL1JSuvzqetMsCMyHx6jdF(MQRlDExBjYWiI3iA0W4Bgwsepf728aKSSEGlLOBQenYJLrRshVByYu8DnkX(ICHdhaswwpWLs0nvIg5XYOvPJ3T5duiIv3Pr3S0dOVdHWvoqWESyiUjCBAjBpG(oecx5ab7L0a0cIWGnhhoaKSSEGlLOBQenY7AtnG3nczUHWKzPIH3mb7rcBPQM5nW298nvxx68U2sKHreVreG(oue4knpf7MAYWbIlYInvxxAAM3aXZ0dnpajlRFsgpxBUY5DTPgW728mWvxOO1X2Wbs78a67qrGR0ZXHJlu06yB4aPDEa9DOiWvAMbBUNVP66sN31wImmI4nIgnm(MHLeXtXUbqYY6bUuIUPs0iVRn1aEzyO20s2(Z5inm3EjnaTGgctMLkgEZeShjSLQAM3aHHNVP66sN31wImmI4nIaUuC9Hh5Py3WKzPIH3mbZ8gi72n0(aKSSEKLQkdIyYuIZel8spz4Z3uDDPZ7Alrggr8griX6PORX1aHNIDdtMLkgEZeShjSLQAE3MhegigGKL1JSuvzqetMsCMyHx6jdjmde7cfTo2goqANFsmChDnUgieUnTKTFsmCdGfBGG9sAaAbryWMJdNUgLyFruj8cYUNVP66sN31wImmI4nIqI1trlrrKOmU5Py3CHIwhBdhiTZJeRNIwIIirzCZ8gxE(MQRlDExBjYWiI3ictMs014AGWtXUnVAYWbIlYInvxxAAM3aXZ0C4aqYY6rwQQmiIjtjotSWl9KHZneMmfFxJsSVixyElqHE(MQRlDExBjYWiI3iAsmChDnUgi8uSBaKSSEKLQkdIyYuIZel8spzihoyYu8DnkX(IecVbk0Z3uDDPZ7Alrggr8gra67qrGR08uSBaKSSEKLQkdIyYuIZel8spz4Z3uDDPZ7Alrggr8griX6POLOisug38uSBaKSSEfUgDxgDQJehiEYqoCAtlz7XwyHIirDJHNR66sVKgGwqC44cfTo2goqANhjwpfTefrIY4M5nWE(MQRlDExBjYWiI3isDPJCmSRlF(MQRlDExBjYWiI3icqFhkcCL(5BQUU05DTLidJiEJOjXWD014AGWtXUHjtX31Oe7lYfEduioCaizz9axkr3ujAK31MAaZe6Z3uDDPZ7Alrggr8grKojwTmYtAJYwa(YaxmexJMoITa55BQUU05DTLidJiEJimzkrxJRbYZ3uDDPZ7Alrggr8grgwzPe7dJLS5Py3WKzPIH3mb7rcBPQMzW2bxgzpDy4AvJmXNs8th(LbLUGnSHqa]] )
end
