-- RogueOutlaw.lua
-- June 2018
-- Contributed by Alkena.

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State


if UnitClassBase( 'player' ) == 'ROGUE' then
    local spec = Hekili:NewSpecialization( 260 )

    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Energy, {
        blade_rush = {
            aura = 'blade_rush',

            last = function ()
                local app = state.buff.blade_rush.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 5,
        }, 
    } )
    
    -- Talents
    spec:RegisterTalents( {
        weaponmaster = 22118, -- 200733
        quick_draw = 22119, -- 196938
        ghostly_strike = 22120, -- 196937

        acrobatic_strikes = 19236, -- 196924
        retractable_hook = 19237, -- 256188
        hit_and_run = 19238, -- 196922

        vigor = 19239, -- 14983
        deeper_stratagem = 19240, -- 193531
        marked_for_death = 19241, -- 137619

        iron_stomach = 22121, -- 193546
        cheat_death = 22122, -- 31230
        elusiveness = 22123, -- 79008

        dirty_tricks = 23077, -- 108216
        blinding_powder = 22114, -- 256165
        prey_on_the_weak = 22115, -- 131511

        loaded_dice = 21990, -- 256170
        alacrity = 23128, -- 193539
        slice_and_dice = 19250, -- 5171

        dancing_steel = 22125, -- 272026
        blade_rush = 23075, -- 271877
        killing_spree = 23175, -- 51690
    } )



    local rtb_buff_list = {
        "broadside", "buried_treasure", "grand_melee", "ruthless_precision", "skull_and_crossbones", "true_bearing", "rtb_buff_1", "rtb_buff_2"
    }

    
    -- Auras
    spec:RegisterAuras( {
        adrenaline_rush = {
            id = 13750,
            duration = 20,
            max_stack = 1,
        },
        alacrity = {
            id = 193538,
            duration = 20,
            max_stack = 5,
        },
        blade_flurry = {
            id = 13877,
            duration = 15,
            max_stack = 1,
        },
        blade_rush = {
            id = 271896,
            duration = 5,
            max_stack = 1,
        },
        blind = {
            id = 2094,
            duration = 60,
            max_stack = 1,
        },
        cheap_shot = {
            id = 1833,
            duration = 4,
            max_stack = 1,
        },
        cloak_of_shadows = {
            id = 31224,
            duration = 5,
            max_stack = 1,
        },
        combat_potency = {
            id = 61329,
        },
        crimson_vial = {
            id = 185311,
            duration = 6,
            max_stack = 1,
        },
        feint = {
            id = 1966,
            duration = 5,
            max_stack = 1,
        },
        fleet_footed = {
            id = 31209,
        },
        ghostly_strike = {
            id = 196937,
            duration = 10,
            max_stack = 1,
        },
        gouge = {
            id = 1776,
            duration = 4,
            max_stack = 1,
        },
        killing_spree = {
            id = 51690,
            duration = 2,
            max_stack = 1,
        },
        loaded_dice = {
            id = 240837,
            duration = 45,
            max_stack = 1,
        },
        marked_for_death = {
            id = 137619,
            duration = 60,
            max_stack = 1,
        },
        opportunity = {
            id = 195627,
            duration = 10,
            max_stack = 1,
        },
        pistol_shot = {
            id = 185763,
            duration = 6,
            max_stack = 1,
        },
        restless_blades = {
            id = 79096,
        },
        riposte = {
            id = 199754,
            duration = 10,
            max_stack = 1,
        },
        -- Replaced this with 'alias' for any of the other applied buffs.
        -- roll_the_bones = { id = 193316, },
        ruthlessness = {
            id = 14161,
        },
        sharpened_sabers = {
            id = 252285,
            duration = 15,
            max_stack = 2,
        },
        shroud_of_concealment = {
            id = 114018,
            duration = 15,
            max_stack = 1,
        },
        slice_and_dice = {
            id = 5171,
            duration = 18,
            max_stack = 1,
        },
        sprint = {
            id = 2983,
            duration = 8,
            max_stack = 1,
        },
        stealth = {
            id = 1784,
            duration = 3600,
        },
        vanish = {
            id = 11327,
            duration = 3,
            max_stack = 1,
        },

        -- Real RtB buffs.
        broadside = {
            id = 193356,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },
        buried_treasure = {
            id = 199600,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },
        grand_melee = {
            id = 193358,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },
        skull_and_crossbones = {
            id = 199603,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },        
        true_bearing = {
            id = 193359,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },
        ruthless_precision = {
            id = 193357,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },

        -- Fake buffs for forecasting.
        rtb_buff_1 = {
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },

        rtb_buff_2 = {
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },

        roll_the_bones = {
            alias = rtb_buff_list,
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },
    } )


    spec:RegisterStateExpr( "rtb_buffs", function ()
        return buff.roll_the_bones.count
    end )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )


    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld" }
    }

    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            local auras = stealth[ k ]
            if not auras then return false end

            for _, aura in pairs( auras ) do
                if state.buff[ aura ].up then return true end
            end

            return false
        end,
    } ) )


    -- Legendary from Legion, shows up in APL still.
    spec:RegisterGear( "mantle_of_the_master_assassin", 144236 )
    spec:RegisterAura( "master_assassins_initiative", {
        id = 235027,
        duration = 3600
    } )

    spec:RegisterStateExpr( "mantle_duration", function ()
        if level > 115 then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + 5
        elseif buff.master_assassins_initiative.up then return buff.master_assassins_initiative.remains end
        return 0
    end )

    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if a and a.startsCombat then
            removeBuff( "stealth" )
            removeBuff( "shadowmeld" )
            setCooldown( "stealth", 2 )

            if level < 116 and equipped.mantle_of_the_master_assassin then
                applyBuff( "master_assassins_initiative", 5 )
            end
        end
    end )


    -- Abilities
    spec:RegisterAbilities( {
        adrenaline_rush = {
            id = 13750,
            cast = 0,
            cooldown = 180,
            gcd = "off",
            
            startsCombat = false,
            texture = 136206,

            toggle = 'cooldowns',
            
            handler = function ()
                applyBuff( 'adrenaline_rush', 20 )
                removeBuff( "vanish" )
                removeBuff( "stealth" )
                removeBuff( "shadowmeld" )
                if talent.loaded_dice.enabled then
                    applyBuff( 'loaded_dice', 45 )
                    return
                end
            end,
        },
        

        ambush = {
            id = 8676,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 50,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132282,

            usable = function () return stealthed.all end,            
            handler = function ()
                gain( buff.broadside.up and 3 or 2, 'combo_points' )
                removeBuff( 'stealth' )
            end,
        },
        

        between_the_eyes = {
            id = 199804,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 25,
            spendType = "energy",
            
            startsCombat = true,
            texture = 135610,
            
            usable = function() return combo_points.current > 0 end,
            handler = function ()
                if talent.prey_on_the_weak.enabled then
                    applyDebuff( 'target', 'prey_on_the_weak', 6)
                    return
                end

                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                applyDebuff( 'target', 'between_the_eyes', combo_points.current ) 
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" ) 
            end,
        },
        

        blade_flurry = {
            id = 13877,
            cast = 0,
            charges = 2,
            cooldown = 25,
            recharge = 25,

            gcd = "spell",
            
            spend = 15,
            spendType = "energy",
            
            startsCombat = false,
            texture = 132350,
            
            usable = function () return buff.blade_flurry.remains < gcd end,
            handler = function ()
                if talent.dancing_steel.enabled then 
                    applyBuff ( 'blade_flurry', 15 )
                    return
                end
                applyBuff( 'blade_flurry', 12 )
            end,
        },
        

        blade_rush = {
            id = 271877,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1016243,
            
            handler = function ()
                applyBuff( 'blade_rush', 5 )
            end,
        },
        

        blind = {
            id = 2094,
            cast = 0,
            cooldown = function () return 120 - ( talent.blinding_powder.enabled and 30 or 0 ) end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136175,
            
            handler = function ()
              applyDebuff( 'target', 'blind', 60)
            end,
        },
        

        cheap_shot = {
            id = 1833,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 40 - ( talent.dirty_tricks.enabled and 40 or 0 ) end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132092,
            
            handler = function ()
                applyDebuff( 'target', 'cheap_shot', 4)
                if talent.prey_on_the_weak.enabled then
                    applyDebuff( 'target', 'prey_on_the_weak', 6)
                    return
                end
            end,
        },
        

        cloak_of_shadows = {
            id = 31224,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136177,
            
            handler = function ()
                applyBuff( 'cloak_of_shadows', 5 )
            end,
        },
        

        crimson_vial = {
            id = 185311,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 30,
            spendType = "energy",
            
            startsCombat = false,
            texture = 1373904,
            
            handler = function ()
                applyBuff( 'crimson_vial', 6 )
            end,
        },
        

        dispatch = {
            id = 2098,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 35,
            spendType = "energy",
            
            startsCombat = true,
            texture = 236286,
            
            usable = function() return combo_points.current > 0 end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },
        

        distract = {
            id = 1725,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 30,
            spendType = "energy",
            
            startsCombat = false,
            texture = 132289,
            
            handler = function ()
            end,
        },
        

        feint = {
            id = 1966,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            spend = 35,
            spendType = "energy",
            
            startsCombat = false,
            texture = 132294,
            
            handler = function ()
                applyBuff( 'feint', 5)
            end,
        },
        

        ghostly_strike = {
            id = 196937,
            cast = 0,
            cooldown = 35,
            gcd = "spell",
            
            spend = 30,
            spendType = "energy",
            
            talent = 'ghostly_strike',

            startsCombat = true,
            texture = 132094,

            handler = function ()
                applyDebuff( 'target', 'ghostly_strike', 10 )
                gain( buff.broadside.up and 2 or 1, "combo_points" )
            end,
        },
        

        gouge = {
            id = 1776,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            spend = function () return talent.dirty_tricks.enabled and 0 or 0 end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132155,
            
            -- Disable Gouge because we can't tell if we're in front of the target to use it.
            usable = function () return false end,
            handler = function ()
                gain( buff.broadside.up and 2 or 1, "combo_points" )
                applyDebuff( 'target', 'gouge', 4 )
            end,
        },
        

        grappling_hook = {
            id = 195457,
            cast = 0,
            cooldown = function () return 60 - ( talent.retractable_hook.enabled and 30 or 0 ) end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1373906,
            
            handler = function ()
            end,
        },
        

        kick = {
            id = 1766,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            toggle = 'interrupt', 

            startsCombat = true,
            texture = 132219,
            
            handler = function ()
                interrupt()
            end,
        },
        

        killing_spree = {
            id = 51690,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            talent = 'killing_spree',

            startsCombat = true,
            texture = 236277,

            toggle = 'cooldowns',
            
            handler = function ()
                applyBuff( 'killing_spree', 2 )
            end,
        },
        

        marked_for_death = {
            id = 137619,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            talent = 'marked_for_death', 

            startsCombat = false,
            texture = 236364,
            
            handler = function ()
                gain( 5, 'combo_points')
            end,
        },
        

        pick_lock = {
            id = 1804,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136058,
            
            handler = function ()
            end,
        },
        

        pick_pocket = {
            id = 921,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",
            
            startsCombat = false,
            texture = 133644,
            
            handler = function ()
            end,
        },
        

        pistol_shot = {
            id = 185763,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 40 - ( buff.opportunity.up and 20 or 0 ) end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 1373908,
            
            handler = function ()
                gain( buff.broadside.up and 2 or 1, 'combo_points' )
                if talent.quick_draw.enabled and buff.opportunity.up then
                    gain( 1, 'combo_points' )
                end
                removeBuff( 'opportunity' )
            end,
        },
        

        riposte = {
            id = 199754,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132269,
            
            handler = function ()
                applyBuff( 'riposte', 10 )
            end,
        },
        

        roll_the_bones = {
            id = 193316,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            notalent= 'slice_and_dice',

            spend = 25,
            spendType = "energy",
            
            startsCombat = false,
            texture = 1373910,
            
            usable = function () return combo_points.current > 0 and ( time > 0 or not prev_gcd[1].roll_the_bones ) end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                for _, name in pairs( rtb_buff_list ) do
                    removeBuff( name )
                end

                applyBuff( "rtb_buff_1", 12 + 6 * ( combo_points.current - 1 ) )
                if buff.loaded_dice.up then
                    applyBuff( "rtb_buff_2", 12 + 6 * ( combo_points.current - 1 ) )
                    removeBuff( "loaded_dice" )
                end

                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },
        

        sap = {
            id = 6770,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 35 - ( talent.dirty_tricks.enabled and 35 or 0 ) end,
            spendType = "energy",
            
            startsCombat = false,
            texture = 132310,
            
            handler = function ()
                applyDebuff( 'target', 'sap', 60 )
            end,
        },
        

        shroud_of_concealment = {
            id = 114018,
            cast = 0,
            cooldown = 360,
            gcd = "spell",
            
            startsCombat = false,
            texture = 635350,
            
            handler = function ()
                applyBuff( 'shroud_of_concealment', 15 )
            end,
        },
        

        sinister_strike = {
            id = 193315,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 45,
            spendType = "energy",
            
            startsCombat = true,
            texture = 136189,
            
            handler = function ()
                gain( buff.broadside.up and 2 or 1, 'combo_points')
            end,
        },
        

        slice_and_dice = {
            id = 5171,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 25,
            spendType = "energy",
            
            startsCombat = false,
            texture = 132306,
            
            usable = function() return combo_points.current > 0 end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyBuff( "slice_and_dice", 12 + 6 * ( combo - 1 ) )
            end,
        },
        

        sprint = {
            id = 2983,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132307,
            
            handler = function ()
                applyBuff( 'sprint', 8 )
            end,
        },
        

        stealth = {
            id = 1784,
            cast = 0,
            cooldown = 2,
            gcd = "off",
            
            startsCombat = false,
            texture = 132320,

            usable = function () return not buff.stealth.up and not buff.vanish.up end,            
            handler = function ()
                applyBuff( 'stealth' )
            end,
        },
        

        tricks_of_the_trade = {
            id = 57934,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236283,
            
            handler = function ()
                applyBuff( 'target', 'tricks_of_the_trade', 6)
            end,
        },
        

        vanish = {
            id = 1856,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132331,
            
            usable = function () return boss end,
            handler = function ()
                applyBuff( 'vanish', 3 )
                applyBuff( "stealth" )
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
    } )


    -- Override this for rechecking.
    spec:RegisterAbility( "shadowmeld", {
        id = 58984,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        usable = function () return boss and race.night_elf end,
        handler = function ()
            applyBuff( "shadowmeld" )
        end,
    } )

    
    spec:RegisterPack( "Outlaw", 20180717.0128, [[d4uoIaqiQiEevcBcPQpHKIYOasofqQvrLsEfqmlIu3IiP2Lc)cP0Wuu6ykQwgvupdjfMgrsUgvI2gsk9nQizCuPuNtrr16OIu17uuKAEejUhsSpQKoivkQfIK8qKuLjQOiUiskYgPsH(ivKIojsQQvQiMjvKkUPIIKDIu8tKuPHsLcokvKswksQ4PQyQksxLksHTsfPsFLksP2lK)kLbR0HfwSu9ysnzsUmQnd4ZuHrtvDArRwrr51ivMnHBtu7wv)g0WPkhNkfz5q9CetNY1vPTdu(ovQgVIcNNiwpskQMpq1(LmAoAk6OcJr048SZD7zDQ5o1y25o7uUKArhtIhJoEHMUWbJoFiZOd19AIWD0XlKiGHcnfDiWlwZOJVzEeNEAP1rA(3(qdLPLKYxryj814aWOLKYAA7cyN2oqi1kgmA9WqGuWeANMm2550o155nQd0XLBu3Rjc3hKuwJo9BkmQ)J6OJkmgrJZZo3TN1PM7uJzNp355sf6q8ynIgNP2zrhft0OZu)KuBsQ185AvmqCfwTUzTLWVw3qOPRwaiUwQ71eH71sDGoUmP28RLQWmbxlaexRBMAoJHM)OMutO(wTjP2EqyvTWVwZNRvKpDSQwpmeifCTUNMFTY5dX1gQz2LyY8BKALdfpQj1KP(CTX1GA4dgJngxR7PquBk7bXwTMFsQ1ddbsbxB(AigZAtizMUwQFTUdVcvTp0QfZPSheB1EFlf1A(CTPSheBmU2Ku71tfgRgOJhgcKcgDCrTt9tsTkgiUcR2qBj8R1dNqCAsQvKeR2KuBCnOCyPoecj1QXCySQ2EqyvTWVwjWlUwTFGdTX4rnXf1s9TAtsTrTHzSSNvRbR1ddblvCTsG3ADpn)AJAdTLWVwrsSAn)WQnj12HMFTKu2tW1gVQwpCOTuhDblDnXf16UFk4AXm5kS8DuB(1g1kZXNVdGRO24v16acv1ss5RiSe(JAP(wTYHKAFOvlMjxHvB(1A(CTrNafxJfsQ1pD4ZeRwpiHKDbxRYJmQjUOw3iZIAbWmxRbRLvPjDTHk8SAJxvBk7HHGX1MwTgSwjWlUwO7FTpZkYOM4IApP8vewcFQhoaSAtsTHW9qcPwbesx(oQfaIR96PcJj1gVQ2u2ddbJL53i1AWAnFUwfdexHvBOTe(1ksIrg1KAIlQLAAgS(ASQ2odaXCTAOCpSA7SJ8jJADZAn7zKAF4l1(bwg4kQn0wcFsTWxizutcTLWNm8WSgk3dJcGii0vtcTLWNm8WSgk3ddek0gxhY8BHLWVMeAlHpz4HznuUhgiuOfacv1exu75dpIp0QfhPQ2(faGv1sSWi12zaiMRvdL7HvBNDKpP24v16HzP2dAw(oQnj1QGppQjH2s4tgEywdL7HbcfAjF4r8HwJyHrQjH2s4tgEywdL7HbcfAjghcZVMeAlHpz4HznuUhgiuO1dAj8RjH2s4tgEywdL7HbcfALdmDSQbaXnfhMV0EywdL7H1iSg(kcfxkDcqbhPQXGXVncLImY3vPA2AsOTe(KHhM1q5EyGqHwmuiAMp36WNjs7HznuUhwJWA4RiuCUMeAlHpz4HznuUhgiuOLisn3Ix1uPML2dZAOCpSgH1WxrO4Cnj0wcFYWdZAOCpmqOqBOW8hI85g(s8L2dZAOCpSgH1WxrOmVMutCrTutZG1xJv1YGXyj1APmxR5Z1gAdIRnj1gGfPi6cEutCrTuhgdfIAbG4ADgKA7xaasTUNMFToDGHIv1otsnx71Bul118zS7jHRfZyOqulaexRZGulexRttC8QANPybZ1cX1sDUMVGjKADdywNKe(JAsOTe(ekGf4m6cw6pKzkyR3WmgkesdwiUmfS1B9laarkotpO6xaGHagkw1uPMhxpWb3j9laWWboEvtMfmpUE07K(fayGVMVGjKMhM1jjH)46b6AsOTe(eqOqlyboJUGL(dzMsi3Ve)Mg(Q0s4lnyH4Yu0q5oS5bZ3idfdK60CLIZG4SBbkle8Bdh(qIjK0igoPJh8hDbROxdHcf09F4WhsmHKgXWjD8aZYr(ePmh0G0VaaJoggksQ4X1JE(zSdjUsTZsVt6xaGbHURq0Ix10yiH0HptgxVAIlQ1PDA(1kFfw6j4ATa7GnI01A(jPwWcCgDbxBsQv7ZA6yvTgSwfRtfxR7(S5Z4AjqzUwQ3mHulXhEfQA7CTejVMv16EA(1sLiuCTUrXfJLutcTLWNacfAblWz0fS0FiZu6IqXnaXfJL0isET0GfIltH4XcrZcSd2iJUiuCdqCXyjsXz6XrQAmy8BJqPiJ8D15zbh8(fay0fHIBaIlglzC9QjH2s4taHcT6qiAH2s43ejXK(dzMcX4qy(sNauighcZNvJqiQjH2s4taHcT6qiAH2s43ejXK(dzMIwrQjUOw3y(jXV2WQvoMrkFLRL65gg1EUDIHdTvl85AbG4A5q7xlvyyOiPIRnEvTuxppi2UFAsQ1DF(R1P1n10v7mbhUxBsQLWcwBSQ24v1otbmtQnj1(qRwmhkj1gagJR185AFEgwTewdF1OMeAlHpbek0QdHOfAlHFtKet6pKzka5NeFPtakAOCh28G5BexPO9AYXmAep(vsnO6xaGrhddfjv846bs)camGEEqSD)0KmUEG2TaLfc(THB6MA6AkC4(G)Olyf9GYjwi43gYbMow1aG4MIdZFWF0fScCW1qOqbD)hYbMow1aG4MIdZFGz5iFIRZbnORjH2s4taHcT6qiAH2s43ejXK(dzMs)Mcvnj0wcFciuOnW645MbXy(nPtak8Zyhsgkgi1P5kL5Uee(zSdjdm7G)AsOTe(eqOqBG1XZnVRGW1KAIlQLQBkumMutcTLWNm63uOO4LedkAeFOjDcqrdL7WMhmFJmumqQtZvkZbPFbagDmmuKuXJRhiwi43gUPBQPRPWH7d(JUGv03VaadONheB3pnjJRxnj0wcFYOFtHcek0sYpjgJBedN0X1KAIlQL6bHcf09NutcTLWNm0kcfpOLWx6eGs)cam6ciujUeBG5qBGdUfyhSnSuMBgSPswkuO2zbh8(fayekm)HiFUHVe)X1RMeAlHpzOveqOqBxaHQgWflPMeAlHpzOveqOqBNXegtx(oQjH2s4tgAfbek0ksh(gPnZUkhY8B1KqBj8jdTIacfAdfM)qKp3WxIV0jafN0VaaJqH5pe5Zn8L4pUE0ZpJDizyPm3mytoMHRZRjH2s4tgAfbek0khy6yvdaIBkomFPTa7GTwcqroFNElWoyByPm3mytLS0jaflWoyByPm3mytLSu0q5oS5bZ3idfdK60ahCqbkCKQgdg)2iukYiFxLQzbh8(fayy4l36CGZ3XaZYr(exN7sPUFbagHcZFiYNB4lXFC9ClxcA6DcX4qy(SAGHoUm9AOCh28G5BKHIbsDAUsr71KJz0iE8RK65GUMeAlHpzOveqOqBxekUbiUySePtakepwiAwGDWgz0fHIBaIlglXvkotVt6xaGrxekUbiUySKX1RMeAlHpzOveqOqRdFiXesAedN0XsNaualWz0f8Olcf3aexmwsJi510RHYDyZdMVrgkgi1P5kL5G0VaaJoggksQ4X1RMeAlHpzOveqOqlDPqKVJgXdZS0jafWcCgDbp6IqXnaXfJL0isEn9GIFg7qYWszUzWMCmdxDj4GZpJDirkZDjORjH2s4tgAfbek02fHIB4lXx6eGcyboJUGhDrO4gG4IXsAejVME(zSdjdlL5MbBYXmCDEnXf160GKVJAD6gFs8P1nl3Ve)AtsTWxiP2OwWySKAT8LuB(Amhew6AjWAZVwmhI0KiDTsGxQzyU2OtGIRXcj1cKpxRbR9s4AtR2GuBu71srAsQL4XcXOMeAlHpzOveqOqlyXNeFPtakoHyCimFwncHGEWcCgDbpc5(L430WxLwc)AsOTe(KHwraHcTe)qbDxMfkPtakoHyCimFwncHGEWcCgDbpc5(L430WxLwc)AsnXf16gZpj(mMutcTLWNmaYpj(uiIuZT4vnvQzPtak9laWGisn3Ix1uPMhywoYNiflWoyByPm3mytLm99laWGisn3Ix1uPMhywoYNifqnhenuUdBEW8ncODR5d3UMeAlHpzaKFs8bHcTyOq0mFU1HptKobOaQ(fayGHcrZ85wh(mzGz5iFIuOqnahCWcCgDbpWwVHzmuian9GYcSd2gwkZnd2uj7QZZco49laWadfIM5ZTo8zYaZYr(ePyb2bBdlL5MbBQKbDnXf1s1uQPADhIn)A7C(oQ9syvTUNMFTMpxBhcjgRQvJtRwTF8AUwamuUwQZ18fmHuRBaZ6KKWVMeAlHpzaKFs8bHcTD2CN5Vz(CJLWePtak9laWaFnFbtinpmRtsc)X1RMeAlHpzaKFs8bHcTQK4fM2VMutCrThJdH5xtcTLWNmighcZNsi3VeF0bmgts4JOX5zN72ZsTotTJ5oLlrh3d8NVdc6GoIKye0u0rXaXvyOPiAMJMIo8hDbRquHoGfIlJoyR36xaasTsPwNRL(AbvT9laWqadfRAQuZJRxTGdEToP2(fay4ahVQjZcMhxVAPVwNuB)camWxZxWesZdZ6KKWFC9Qf0OtOTe(OdyboJUGrhWcC7dzgDWwVHzmuiqgIgNrtrh(JUGviQqhWcXLrhnuUdBEW8nYqXaPoTADLsToxli16CTUvTGQwqvRfc(THdFiXesAedN0Xd(JUGv1sFTAiuOGU)dh(qIjK0igoPJhywoYNuRuQDETGUw6RDETGdETZwlORfKA7xaGrhddfjv8ahpD1sFT8ZyhsQ11AP2zRL(ADsT9laWGq3viAXRAAmKq6WNjJRh6eAlHp6awGZOly0bSa3(qMrNqUFj(nn8vPLWhziAOgOPOd)rxWkevOdyH4YOdXJfIMfyhSrgDrO4gG4IXsQvk16CT0xlosvJbJFBekfzKFTUwRZZwl4GxB)cam6IqXnaXfJLmUEOtOTe(OdyboJUGrhWcC7dzgD6IqXnaXfJL0isEnYq0ivOPOd)rxWkevOJgNgJZaDighcZNvJqiqNqBj8rhDieTqBj8BIKyOJijw7dzgDighcZhziACjAk6WF0fScrf6eAlHp6OdHOfAlHFtKedDejXAFiZOJwrqgIgQfnfD4p6cwHOcD040yCgOJgk3Hnpy(gPwxPuR2RjhZOr84xvRuxlOQTFbagDmmuKuXdC80vli12VaadONheB3pnjdC80vlOR1TQfu1cQATqWVnCt3utxtHd3h8hDbRQL(AbvToPwle8Bd5athRAaqCtXH5p4p6cwvl4GxRgcfkO7)qoW0XQgae3uCy(dmlh5tQ11ANxlORf01sFTZRfCWRD2Abn6eAlHp6OdHOfAlHFtKedDejXAFiZOdq(jXhziACk0u0H)OlyfIk0j0wcF0rhcrl0wc)Mijg6isI1(qMrN(nfkKHOXTrtrh(JUGviQqhnongNb6WpJDizOyGuNwTUsP25USwqQLFg7qYaZo4hDcTLWhDcSoEUzqmMFdziAM5OPOtOTe(OtG1XZnVRGWOd)rxWkevidzOJhM1q5EyOPiAMJMIo8hDbRquHmenoJMIo8hDbRquHmenud0u0H)OlyfIkKHOrQqtrh(JUGviQqgIgxIMIoH2s4JoeJdH5Jo8hDbRquHmenulAk6eAlHp64bTe(Od)rxWkevidrJtHMIo8hDbRquHoH2s4JoYbMow1aG4MIdZhD040yCgOdosvJbJFBekfzKFTUwRunl64HznuUhwJWA4RiOJlrgIg3gnfD4p6cwHOcDcTLWhDWqHOz(CRdFMGoEywdL7H1iSg(kc64mYq0mZrtrh(JUGviQqNqBj8rhIi1ClEvtLAgD8WSgk3dRryn8ve0XzKHOz(SOPOd)rxWkevOtOTe(OtOW8hI85g(s8rhpmRHY9WAewdFfbDMJmKHo9BkuOPiAMJMIo8hDbRquHoACAmod0rdL7WMhmFJmumqQtRwxPu78AbP2(fay0XWqrsfpWXtxTGuRfc(THB6MA6AkC4(ahpD1sFT9laWa65bX29ttY46HoH2s4JoEjXGIgXhAidrJZOPOtOTe(Odj)KymUrmCshJo8hDbRquHmKHoeJdH5JMIOzoAk6eAlHp6eY9lXhD4p6cwHOczidD0kcAkIM5OPOd)rxWkevOJgNgJZaD6xaGrxaHkXLydmhARwWbVwlWoyByPm3mytLCTsHsTu7S1co412VaaJqH5pe5Zn8L4pUEOtOTe(OJh0s4JmenoJMIoH2s4JoDbeQAaxSe0H)OlyfIkKHOHAGMIoH2s4JoDgtymD57aD4p6cwHOcziAKk0u0j0wcF0rKo8nsBMDvoK53qh(JUGviQqgIgxIMIo8hDbRquHoACAmod0Xj12VaaJqH5pe5Zn8L4pUE1sFT8ZyhsgwkZnd2KJzuRR1ohDcTLWhDcfM)qKp3WxIpYq0qTOPOd)rxWkevOtOTe(OJCGPJvnaiUP4W8rhnongNb6yb2bBdlL5MbBQKRvk1QHYDyZdMVrgkgi1Pvl4GxlOQfu1IJu1yW43gHsrg5xRR1kvZwl4GxB)camm8LBDoW57yGz5iFsTUw7CxwRuxB)camcfM)qKp3WxI)ahpD16w16YAbDT0xRtQLyCimFwnWqhxUw6RvdL7WMhmFJmumqQtRwxPuR2RjhZOr84xvRux78Abn6yb2bBTeaDSa7GTHLYCZGnvYidrJtHMIo8hDbRquHoACAmod0H4XcrZcSd2iJUiuCdqCXyj16kLADUw6R1j12VaaJUiuCdqCXyjJRh6eAlHp60fHIBaIlglbziACB0u0H)OlyfIk0rJtJXzGoGf4m6cE0fHIBaIlglPrK86APVwnuUdBEW8nYqXaPoTADLsTZRfKA7xaGrhddfjv8ahpDOtOTe(OJdFiXesAedN0XidrZmhnfD4p6cwHOcD040yCgOdyboJUGhDrO4gG4IXsAejVUw6Rfu1YpJDizyPm3mytoMrTUwRlRfCWRLFg7qsTsP25USwqJoH2s4Jo0Lcr(oAepmZidrZ8zrtrh(JUGviQqhnongNb6awGZOl4rxekUbiUySKgrYRRL(A5NXoKmSuMBgSjhZOwxRDo6eAlHp60fHIB4lXhziAMphnfD4p6cwHOcD040yCgOJtQLyCimFwncHOw6RfSaNrxWJqUFj(nn8vPLWhDcTLWhDal(K4JmenZDgnfD4p6cwHOcD040yCgOJtQLyCimFwncHOw6RfSaNrxWJqUFj(nn8vPLWhDcTLWhDi(Hc6UmluidzOdq(jXhnfrZC0u0H)OlyfIk0rJtJXzGo9laWGisn3Ix1uPMhywoYNuRuQ1cSd2gwkZnd2ujxl912VaadIi1ClEvtLAEGz5iFsTsPwqv78AbPwnuUdBEW8nsTGUw3Q25d3gDcTLWhDiIuZT4vnvQzKHOXz0u0H)OlyfIk0rJtJXzGoGQ2(fayGHcrZ85wh(mzGz5iFsTsHsTuJAbh8AblWz0f8aB9gMXqHOwqxl91cQATa7GTHLYCZGnvY16ATopBTGdET9laWadfIM5ZTo8zYaZYr(KALsTwGDW2WszUzWMk5Abn6eAlHp6GHcrZ85wh(mbziAOgOPOd)rxWkevOJgNgJZaD6xaGb(A(cMqAEywNKe(JRh6eAlHp60zZDM)M5ZnwctqgIgPcnfDcTLWhDujXlmTp6WF0fScrfYqgYqN4A(qm6CszQhYqgcb]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = "Outlaw",
    } )

end