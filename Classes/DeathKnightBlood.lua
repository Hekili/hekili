-- DeathKnightBlood.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'DEATHKNIGHT' then
    local spec = Hekili:NewSpecialization( 250 )

    spec:RegisterResource( Enum.PowerType.Runes, {
        rune_regen = {
            resource = 'runes',

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
                local r = runes
                r.actual = nil

                r.spend( amt )

                gain( amt * 10, "runic_power" )

                if talent.rune_strike.enabled then gainChargeTime( "rune_strike", amt ) end            
            
            elseif resource == "runic_power" then
                local rp = runic_power

                if talent.red_thirst.enabled then cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - amt / 10 ) end
            end
        end
    end

    spec:RegisterHook( "spend", spendHook )

    
    local gainHook = function( amt, resource )
        if resource == 'runes' then
            local r = runes
            r.actual = nil

            r.gain( amt )
        end
    end

    spec:RegisterHook( "gain", gainHook )


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

        strangulate = 206, -- 47476
        blood_for_blood = 607, -- 233411
        last_dance = 608, -- 233412
        death_chain = 609, -- 203173
        walking_dead = 205, -- 202731
        unholy_command = 204, -- 202727
        murderous_intent = 841, -- 207018
        dark_simulacrum = 3511, -- 77606
        decomposing_aura = 3441, -- 199720
        antimagic_zone = 3434, -- 51052
        necrotic_aura = 3436, -- 199642
        heartstop_aura = 3438, -- 199719
    } )

    -- Auras
    spec:RegisterAuras( {
        antimagic_shell = {
            id = 48707,
            duration = function () return ( talent.antimagic_barrier.enabled and 6.5 or 5 ) * ( ( level < 116 and equipped.acherus_drapes ) and 2 or 1 ) end,
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
        unholy_strength = {
            id = 53365,
            duration = 15,
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
        

        asphyxiate = {
            id = 221562,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 538558,
            
            toggle = "interrupts",
            
            usable = function () return target.casting end,
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
            cooldown = 120,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135277,
            
            handler = function ()
                applyBuff( "dancing_rune_weapon" )
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
        

        death_grip = {
            id = 49576,
            cast = 0,
            charges = 1,
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
            cooldown = 45,
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

                -- ( ( buff.dancing_rune_weapon.up and 2 or 1 ) * ( 5 + ( talent.heartbreaker.enabled and ( targets * 2 ) ) or 0 ), "runic_power" )

                if level < 116 and equipped.service_of_gorefiend then cooldown.vampiric_blood.expires = max( 0, cooldown.vampiric_blood.expires - 2 ) end
            end,
        },
        

        icebound_fortitude = {
            id = 48792,
            cast = 0,
            cooldown = 180,
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
            usable = function () return target.casting end,            
            handler = function ()
                interrupt()
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
            cooldown = 90,
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
    
        package = "Blood",        
    } )


    spec:RegisterPack( "Blood", 20180730.0003, [[dCKunaqiOcBcQYNqfPrbv1PGkTkjuUfur0UuLFjHWWKGJrPSmuPEgQKPPqLRrkSnjK8nurnovv6CsOADOcY8uv19uvX(ifDqfQklKs8qfQQMiQG6JOcyKkufNevOwjQqEjuryMqfvDtOIs7eOgQesTuOIupf0ubYvHks2kurXxHkQSxK)cLblCyrlgWJjzYuCzIntQ(mP0OvvoTkVMs1Sv0TvWUv63OmCj64siA5qEUKMUuxhvTDur8DfY4rfOZRqz9kuLMpL0(PAYgbIGMSfcm3fS9BboZvHxHcf4YwrrWESsHGLPYEQvi4MdcbTmzmdblZXMS0qGiyLXJucbH3W43JIWJXJy)MNhfHhCSAmCsCg52QhfHhfTGQSnNEu0irxqYQeccWFZMJxcGGMSfcm3fS9BboZDXF24ECAqWAPOiWCRrbcAKQIGwKo9WYKXmCyCcp4WIUS1JtepkA0Xqxpgblrm9BkeKGCIGQhBjWCxW2Vf4m3f)zJ7XPbbhLO9wTvcIZn(WPbZXG5aCip8a0N4XnuYqTh6mKhCQr0t(zZPEGKIK)qIXJkBq8i5B2q2IXd1xUAL6Z5iC(BfpSXH8aNAR8LLmulgpsvFS1don5Bgw2DQSZPpNJCoIJhkzOwmEWThPQp26X8QD95CebNxTReicw7CnjYqGiW2iqeyBeiQjOSjWumKfcMQ(ylb5KCO8qNcdyYygcQqxlOlj4NKZ(7vQAp(7bxfOMaZnbIGYMatXqwiOcDTGUKG3Qyd3QfZKdPwbtJQhA6b(Eu4PHhfZJpjN93Bi5GEGRhwT6b(EG43tHvYgjONr0p11E83dBf8appW3dC4rNtz7haBLAZqdpztGPy8WQvpum20WgTpa2k1MHgEiziVT6HvREKQ(4ebtwz4KQh)9GlpW1dCjyQ6JTe0iz)HvB0zxOMaZfbIGYMatXqwiOcDTGUKGa866pa2ky1VtMMhsgYBRE8)hp0QmEump4MGPQp2sWHeHyJqYAOMapocebLnbMIHSqqf6AbDjbvFjsRuX0rPQp2Mtp08hpS9(1d88aFpa411FFYaR2z9QVANk7E83dn8appW3dC4HuK8xzPyEv78ZP(KnsqvSVugy1oRx1dRw9aGxx)9LYaR2z9QVANk7E83dn8axpW1d88aFpW3daED93NmWQDwV6R2PYUh)9GlpWZd89ahEifj)vwkMx1o)CQpzJeuf7lLbwTZ6v9WQvpa411FFPmWQDwV6R2PYUh)9GlpW1dC9WQvpWHha866ptUQB1IH4xbBKKLS9Xx6bUemv9Xwccmzmdga7MutG1GarGTrGOMGPQp2sqJK9hwTrNDHGk01c6sc(j5S)ELQ2J))4XVf8appq87PWkzJeKhA(JhfVGhwT6b(E8j5S)ELQ2J))4XVf8appq87PWkzJeKhA(Jh)wWd88aGxx)bWwbR(DY08QDQS7HMEOHh415u2(XQv(en2t2eykgpWLAcCrrGiW2iqutqztGPyileuLL9Xwcsqf6AbDjbb411Fk0nuzlwvX4rALhFPh45rNtz7hklpdMruSHsw96JTpztGPyiyQ6JTe0iz)HLRbZiQCmQjWCMarqztGPyileuHUwqxsqC4baVU(ZKR6wTyi(vWgjzjBF8LEGNh47rTuMtSorALU((Ke1y1gD2fp(7bxEy1QhFso7VxPQ94VhCUGh4sWu1hBjiWKXmg0T2fe1e4Fjqeu2eykgYcbvORf0LeeFpa411FaSvWQFNmnVANk7E83do7bUEy1Qha866pa2ky1VtMMhsgYBRE83dTkJhfZdUiyQ6JTeCiri2iKSgQjWfNarqztGPyileuHUwqxsq89aGxx)bmzmdw97KP5zyJwpWZJBvSHB1IzYHuRGPr1dn94tYz)9gsoOhfZJcpU1WdC9WQvpW3d89ahE05u2(bWwP2m0Wt2eykgpSA1dfJnnSr7dGTsTzOHhsgYBREOPhAvgpW1d88aFpq87PWkzJe0Zi6N6Ap(7Hnn8appW3de)EkSs2ib9mI(PU2J)EWTgEy1Qh4WdaED9Njx1TAXq8RGnsYs2(4l9axpW1dCjyQ6JTe0iz)HvB0zxOMaBRabIGYMatXqwiOcDTGUKGa866ptUQB1IH4xbBKKLS9XxsWu1hBj4NKOgR2OZUqnb2MncebLnbMIHSqqf6AbDjbr87PWkzJeKhA(Jh2kuWd88OwkZjwNiTsxFaSvQndn4HM)4bxemv9XwccWwP2m0a1eyBCtGiOSjWumKfcQqxlOljiIFLxFdcwZW4YJ)EOvz8appa411FaSvWQFNmnpKmK3w9qtp0QmEump4IGPQp2sWpjrnwTrNDHAcSnUiqeu2eykgYcbtvFSLGgj7pSCnygrLJrqf6AbDjbr8R86BqWAggxE83dTkJh45baVU(dGTcw97KP5HKH82QhA6HwLXJI5bxutGTnoceb2gbIAckBcmfdzHGPQp2sqJK9hwUgmJOYXiOcDTGUKGa866pf6gQSfRQy8iTYJVKAcSnniqemv9XwcI4xbR2OZUqqztGPyilutnbnIEYpBceb2gbIGPQp2sWKVzyz3PYobLnbMIHSqnbMBcebtvFSLGd3AW0rImEfckBcmfdzHAcmxeickBcmfdzHGk01c6scI43tHvYgjONr0p11EOPhCxGGPQp2sWePYvWAgcjBtnbECeickBcmfdzHGPQp2sqGjJzW05rJrqf6AbDjbPMaRbbIGYMatXqwiOcDTGUKGa866ptUQB1IH4xbBKKLS9XxsWu1hBjiGGQcY(TAPMaxueicMQ(ylb5Rc21YqLGYMatXqwOMaZzcebLnbMIHSqqf6AbDjbb411FMCv3QfdXVc2ijlz7JVKGPQp2sWswFSLAc8VeickBcmfdzHGk01c6scIVh4WJoNY2pGjJzmOBTlONSjWumEy1Qh4WdfJnnSr7dyYygd6w7c6HK0mMh4sWu1hBjOjx1TAXq8RGnsYs2snbU4eickBcmfdzHGk01c6sccWRR)ayRGv)ozAE1ov29qZF8GZemv9Xwc2SbGAZwHAcSTceickBcmfdzHGPQp2sqvoNyPQp2InVAtW5vBSnhecw7CnjYqn1eSejk2aq2eiQPMGjF)XqeKdaXztKDPVvl1ute]] )
end
