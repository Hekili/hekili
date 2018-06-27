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
            resource = 'energy',
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
            aliasMode = 'first', -- use duration info from the first buff that's up, as they should all be equal.
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
            state.removeBuff( "stealth" )
            state.removeBuff( "shadowmeld" )
            state.setCooldown( "stealth", 2 )

            if level < 116 and state.equipped.mantle_of_the_master_assassin then
                state.applyBuff( "master_assassins_initiative", 5 )
            end
        end
    end )


    -- Abilities
    spec:RegisterAbilities( {
        adrenaline_rush = {
            id = 13750,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136206,

            toggle = 'cooldowns',
            
            handler = function ()
                applyBuff( 'adrenaline_rush', 20 )
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
            
            usable = function () return combo_points.current > 0 end,
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
            gcd = "spell",
            
            startsCombat = false,
            texture = 132320,

            usable = function () return not buff.stealth.up end,            
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
    
    spec:RegisterPack( "Outlaw", 20180626.1750, [[dSKxYaqiqjpsfjBcu1NqvzuGkofOuRIur5vKknlQQ6wGk1Uu0VurmmQk5yKswMkupJQkzAQi11afABOQsFJur14avIZbkiRJuH5rvf3Ju1(afDqQQulKQIhIQkMOkK0fbfWgrvvQpcQKojQQQvskMjPICtqbQDIQ4NQqIgkOGAPQqQNIktfeDvviHVIQQyVK8xfgSOdtzXs1JvYKPYLr2Sk9zqA0sXPLSAuvL8AuLMnk3MQSBv9BOgUu64uvQLd8Citx46k12vbFhegVkeNxf16bfiZNuQ9tSslfKkoNfKINJ9LwWfFXVhZVtT05W4XW4PvCX5wsX1AlEnOKI7npsXDuUdMbHIR1oZWMtbPIdH3GfP4AIOfPJtoP1qb1RFUWENamiobgagmmyyyyq1HwfxFxSG)FvxX5SGu8CSV0cU4l(94tp1IF1IFpggsXHAPLINJ5xFP4CeAP4GSPqswijJgsshDTnlK0VxrHFjHHTfVsEXajpk3bZGqYJgdDtijRxsFSiyKKxmqs)ggebWrZu0iA4)qYcjz3qKts8lz0qsYQNxYjzlaFlgjjev0iPx9yGKMJ)AJcp6dKKEMJMIgrJwtjL0VDoYjPpuabrVKrdjjmWzcjzGLmAij57wFHA4tsBv4xswHc)LSUsEgVLSXoqscjyts6dzG6HkzNw2grsY)sEjwijR4LKSIPIRfGVfJuCNssiBkKKo6ABwiPTIc)s2ckmOIZsYkuizHK02b2ZIAzm2zjxaYcYjz3qKts8l5z8gi5QXa2kiWu0Ckj5)qYcjPjPfb51gsgyjBb4dLJK8mEljev0iPjPTIc)sYkuiz0yHKfsYooAKevETmss7Ds2cSvulRZi)fnNssiAkgjjGqBwupujRxstspY(6HE3mjT3jjum2jjQ82mlk8pLK)dj9SZs(4qsaH2SqY6LmAijTocZ2bXolztbTHqHKTyeQ6mssxlAkAoLK83eXK8cisYalj5QWFjnN1gsAVtYYRfGpqswHKbwYZ4nqsmeVKpro0u0Ckj5kVnZIc)8dWUHKfssJbHDgjjdJ5TEOsEXaj3ToliKK27KS8Ab4dKh9bsYalz0qs6ORTzHK2kk8ljRqbAkAenNssyGJqRDqoj70fdijxyVUfs2jO1JMs63Rf1gijF8d3ngW7UzsAROWpss8Zopfn2kk8JMTaAH96wO)YmeVIgBff(rZwaTWEDl0v)j2gQh9Hff(fn2kk8JMTaAH96wOR(tUySt0Ckj5ERf1Gdjbw5KSVVxYjjkSajzNUyaj5c71TqYobTEKK27KSfqWDloI6HkzHK0HFAkASvu4hnBb0c71Tqx9NGERf1GJbkSajASvu4hnBb0c71Tqx9NGcYyrJOXwrHF0SfqlSx3cD1Fslok8lASvu4hnBb0c71Tqx9N4zaEj34IbdhzrJ)1vpWk3GoqFmnNdnRhMN2xIgBff(rZwaTWEDl0v)jamJnIgA0XpH8VU6Hvym6JjIvlAyVB4QfnP36mYjAenNssyGJqRDqojPde4SKr5rsgnKK2kWajlKK2bRywNrtrZPK8OjaMXKeIg6LuNWMJCsEuRfjzHKC3kP9ojRRKNXBjBSdKKmcHKmASxYJLSVVxKKyGKmcHKmASxYtlP9ojFSKqc2KK(qgOEOtj5pv0ij3Fu9xYf(rLJasgnwijeKKpDGas2yhijdSKacGzSPOXwrHFK(dgOSoJ8)npspi6dabWmM)hm2M0dRWy0hteRw0WE3WvlAsV1zKd(((ENmS5i3WvlAUBHhoGOp677f5NJ1wB4aI(OVVxKFon8WQVV3za20OtgOEOZDlSHTO5usYp43vrHFjdSKBejjx9fkiGKCbO4LKeIg6L8XHKacGzS6Hk5rh(ijgijen0l5gvpuj5(JQOXwrHFKU6p5GbkRZi)FZJ0JqJnISoJgpgqamJ5)bJTj9WzH964rlU(a5hyu3Wy0hthrTeyGcGfguYBsV1zKd2IMtjj)GFxff(LmWsUrKKC1xOGasYfGIxYFjHOHEjpJ3s2yhijp6WhjXajFCiASvu4hPR(toyGY6mY)38i9i0yJiRZi)pySnP)GbkRZOji6dabWmg8lSxhpAX1hi)aJ6ggJ(y6iQLaduaSWGsEt6ToJCARnSoyGY6mAcI(aqamJb)bduwNrteASrK1z04XacGzmrZPKKhmWZyscWHff(fn2kk8J0v)jlJXg2kk8pyfk8)npsF)kASvu4hPR(twgJnSvu4FWku4)BEK(LdjAoLK8d(Dvu4hjPbijBiajzGL0oGlNKqGbrdJqijxn0IxjRRKpoAQhQKfss7GvmRZirJTIc)iD1FYYySHTIc)dwHc)FZJ0JcYyrJ)1vpkiJfnKBcWq3K2AVWyMddXppyFHAM7wT1EHXmhgIFIAmhgcpI5M7wrJTIc)iD1FcIvlAyVB4Qf5FD1dRdgOSoJMi0yJiRZi4777DIy1Ig27gUArta5z1J8tyaOumJYJgbE4kc(((ENiwTOH9UHRw0eqEw9i)ahT0DH964rlU(abBDMwt4IOXwrHFKU6pbGzSr0qJo(jK)1vpSoyGY6mAIqJnISoJGhoHbGsXmkpAe4HRiyESV0w7((ENamJnIgA0XpHMaYZQh5NWaqPygLhnc8WveSHho999obygBen0OJFcnbKNvpYp69lT1(GbkRZOji6dabWmgSfn2kk8J0v)j8wmw9qhOwar(xx90taONNr5rJap8SJatyuBTPNaqp7hTGrrJTIc)iD1FsNzoAa2OgrJTIc)iD1FYYySHTIc)dwHc)FZJ033fZjASvu4hPR(twgJnSvu4FWku4)BEK(B9fQX)6QhwhmqzDgnrOXgrwNrIMtjjCfVHsswij3iYjPHK0KKFGHLeUspbSadKeIMIrs(4OPEOssmejzHK0oyfZ6mss7DsEgVLSXoqsEulqCwsib1IxKKHXOpMsY)bFij3pR4LyNLmASqYZ4nFmMKDssRZijdSKoSKrtHKe3gLNXyNLSE4gQ5rsIQFrswHKaY37cqijdSKE4dKK1l5fG)qs8vYOHKmmauk8xY(oKSc(qs2qassewYZ4TKl7L03B7J6wNLScKKhm2MMIgBff(r6Q)eO4nuY)6Qpmg9X0vG48ia1Ix0KERZih8lSxhpAX1hOPJU1QcyQxlrJTIc)iD1FIbw2tJ2ndrIgrZPK0hM5ij5VzBa4SOXwrHF0SF1VSFrSrFFV()MhPVZmhnUSnaC2)6QN89UABj3e1uhmaW(b6SNhfGZWVWyMddXp7mZrJlBdaNNRgdaLqWuVwW3337SZmhnUSnaCEUBHh1sm2imaukqZoZC04Y2aWzyQ)yrJTIc)Oz)QR(t6mZrJlBdaN9VU6rTeJncdaLc0SZmhnUSnaCgM6pgEy1337SZmhnUSnaCEUBfnIMtjPp7I5ias0yROWpA23fZPhAdgfSZduakEj)RR(f2RJhT46d00r3Avbm1RLU999o7aS5qLJM7w4b0fqOgRZirJTIc)OzFxmNU6pPTqbMnqn4W)6QFH964rlU(anD0Twvat9APBFFVZoaBou5O5Uv3Wy0htFVRfVdhWGysV1zKd(((EN42wmi2FfNN7w4Hd9ea65zuE0iWdp7iW8y4omg9X037AX7WbmiM0BDg50wB40337ekGOhXB9ObewqaggkuYnGauOyTVx0C3cFFFVtOaIEeV1JgqybbyyOqj3acqHI1(Erta5z1J8ZXWg2IgBff(rZ(UyoD1FcQ(cfeyGcqXl5FD1FWaL1z0eHgBezDgjAenNss(bJzomeps0yROWpAUCi9T4OWV)1vFFFVZodJDSnkMaYwH2AhgakfZO8OrGhUI8JE(1xARDFFVtZbO3y1tdWg1m3TIgBff(rZLdPR(t6mm2nUBWzrJTIc)O5YH0v)jDcGiaV1dv0yROWpAUCiD1FIbw2tJada0h(xx90taONNo6wRkG5P9LOXwrHF0C5q6Q)ewbTjqd(RTdQh9HOXwrHF0C5q6Q)eZbO3y1tdWg14FD1dR((ENMdqVXQNgGnQzUBHNEca980r3Avbm9LOXwrHF0C5q6Q)epdWl5gxmy4ilA8pmaukg1vVx96imaukMr5rJapCf5FD1hgakfZO8OrGhUI8Zc71XJwC9bA6OBTQqBTHdCaw5g0b6JP5COz9W80(sBT777DgGnn6KbQh6eqEw9iyQfmc3999onhGEJvpnaBuZC3QZGrydpSqbzSOHCtag6MGFH964rlU(anD0Twvat9R2HNDKbQLEhCRfSfn2kk8JMlhsx9NGAb1h(xx9KV3vBl5MrdWosHgbOw8Iopcazoe8W6GbkRZOjcn2iY6ms0yROWpAUCiD1FIZa8Ezf0MW)6QN89UABj3mAa2rk0ia1Ix05raiZHGhwhmqzDgnrOXgrwNrW3337e1cQpMomeVOr0Ckj5VRVqneajAoLK(ajmGK1lPN9bJKCJiNKbwYoj5rfgMtYN2bWys23HKfsstsggHK0TjjdSKXXAjASvu4hnV1xOg9DkGGOFen0Goti)RREY37QTLCtOaIEeV1JgqybbyyOqj3acqHI1(ErWdR((ENqbe9iERhnGWccWWqHsUbeGcfR99IM7wrJTIc)O5T(c1OR(tCfQ1IvJOr0Ckj5cYyrJOXwrHF0efKXIg9hmqzDg5)BEKEZRVrnJf(Dvu43)dgBt6xyVoE0IRpqthDRvfWu)X6ESodoHXOpMqBWOGDEGcqXlnP36mYbpSCuFFVtOnyuWopqbO4LM7wyRBFFVZoaBou5O5UfE6ja0ZWKF9f8WQVV3jI3nJnS3nwamc1XpHM7wrJTIc)OjkiJfn6Q)eZRVrn(xx9hmqzDgnnV(g1mw43vrHFrJTIc)OjkiJfn6Q)Kd2xOg)RRE4CWaL1z0086BuZyHFxff(1wBY37QTLCtp7dgnW3r0qdpdfeyyiKHq1dpSoyGY6mAcI(aqamJbpSoyGY6mAIqJnISoJGn8E2hmA42alk8R3xIgBff(rtuqglA0v)jOgZHHWJyo)RR(dgOSoJMMxFJAgl87QOWVI7abqf(v8CSV0cU4l(94tpp2x(LIdcd81dfP44p(9rZd)ZdCvhskjKnKKLxlgesEXaj5dfKXIg(Keq(ExaYjjc7rsA7a7zb5KC1ypucnfn6u9KKAPdj5h8FGab5KKVWy0htOnyuWopqbO4LM0BDg54tYaljFHXOpMqBWOGDEGcqXlnRb9wNro(K8Ibs6zrd5zrTmMKlSxRbke(LeoADeypfn6u9KKAPdj5h8FGab5KKph1337eAdgfSZduakEP5ULpjdSK85O((ENqBWOGDEGcqXlnRXULpjVyGKEw0qEwulJj5c71AGcHFjHJwhb2trJovpjPw6qs(b)hiqqoj5RVV3zhGnhQC0C3YNKbws(677D2byZHkhnRXULpjVyGKEw0qEwulJj5c71AGcHFjHJwhb2trdKnKKxmJHHOEOsABGHKeccqsUrKtY6LmAijTvu4xswHcj77qsiiaj5JdjV497KSEjJgssZ5WVKolSUHiDiAKeULSdWMdvos0ijCljI3nJnS3nwamc1XpHenIg(JFF08W)8ax1HKsczdjz51IbHKxmqs(C012SGpjbKV3fGCsIWEKK2oWEwqojxn2dLqtrJovpj5X6qs(b)hiqqoj5lmg9X0rulbgOayHbL8M0BDg54tYaljFHXOpMoIAjWafalmOK3Sg0BDg54tYlgiPNfnKNf1YysUWETgOq4xs4O1rG9u0Ot1ts6x6qs(b)hiqqoj5lmg9X0rulbgOayHbL8M0BDg54tYaljFHXOpMoIAjWafalmOK3Sg0BDg54tYlgiPNfnKNf1YysUWETgOq4xs4O1rG9u0Ot1tsQ1P1HKhfpA32Ibb5K0wrHFj5Zal7Pr7MHi(MIgiBijVygddr9qL02adjjeeGKCJiNK1lz0qsAROWVKScfs23HKqqasYhhsEX73jz9sgnKKMZHFjDwyDdr6q0ijClza20OtgOEOIgrd)XVpAE4FEGR6qsjHSHKS8AXGqYlgijF36ludFsciFVla5KeH9ijTDG9SGCsUAShkHMIgiBijVygddr9qL02adjjeeGKCJiNK1lz0qsAROWVKScfs23HKqqasYhhsEX73jz9sgnKKMZHFjDwyDdr6q0ijCljuarpI36rdiSGammuOKBabOqXAFVirJOH)43hnp8ppWvDiPKq2qswETyqi5fdKKVLdXNKaY37cqojrypssBhypliNKRg7HsOPOrNQNKuNRdj5h8FGab5KKV((ENMdqVXQNgGnQzUB5tYaljF999onhGEJvpnaBuZSg7w(K8Ibs6zrd5zrTmMKlSxRbke(LeoADeypfn6u9KKWq6qYJIhTBBXGGCsAROWVK85maVxwbTj4BkAGSHK8Izmme1dvsBdmKKqqasYnICswVKrdjPTIc)sYkuizFhscbbijFCi5fVFNK1lz0qsAoh(L0zH1nePdrJKWTKbytJozG6HkAen8h)(O5H)5bUQdjLeYgsYYRfdcjVyGK813fZXNKaY37cqojrypssBhypliNKRg7HsOPOrNQNKulDij)G)deiiNK81337SdWMdvoAUB5tYaljF999o7aS5qLJM1y3YNKxmqsplAiplQLXKCH9AnqHWVKWrRJa7POrNQNK8yDij)G)deiiNK8fgJ(y67DT4D4aget6ToJC8jzGLKVWy0htFVRfVdhWGywd6ToJC8j5fdK0ZIgYZIAzmjxyVwdui8ljCo(iWEkA0P6jjpwhsYp4)abcYjjF999o7aS5qLJM7w(KmWsYxFFVZoaBou5Ozn2T8j5fdK0ZIgYZIAzmjxyVwdui8ljC06iWEkAGSHK8Izmme1dvsBdmKKqqasYnICswVKrdjPTIc)sYkuizFhscbbijFCi5fVFNK1lz0qsAoh(L0zH1nePdrJKWTKDa2COYrIgjHBjHci6r8wpAaHfeGHHcLCdiafkw77fjAen8h)(O5H)5bUQdjLeYgsYYRfdcjVyGK81V8jjG89UaKtse2JK02b2ZcYj5QXEOeAkA0P6jj1shsEu8ODBlgeKtsBff(LKVL9lIn677LVPOr0W)ETyqqoj15sAROWVKScfOPOrXz7ObduC(nJx6nfhRqbsbPI7wFHAuqQ4rlfKko6ToJCkFuClqfeOmfh57D12sUjuarpI36rdiSGammuOKBabOqXAFVijHxsyjzFFVtOaIEeV1JgqybbyyOqj3acqHI1(ErZDRIZwrHFfxNcii6hrdnOZesfkEowbPIJERZiNYhfNTIc)kUofqq0pIgAqNjKIBbQGaLP4677Dc2rdJqOrlGwfQW)C3Qcfp(LcsfNTIc)koxHATy1O4O36mYP8rfQqX5ORTzHcsfpAPGuXDWaJ38ifhi6dabWmMIJERZiNYhfNTIc)kUdgOSoJuChm2MuCWsYWy0hteRw0WE3WvlAsV1zKts4LSVV3jdBoYnC1IM7wjHxs4iji6J((Ers6hjpwsT1ws4iji6J((Ers6hjpTKWljSKSVV3za20OtgOEOZDRKWwsyRcfphRGuXDWaJ38ifhcn2iY6mA8yabWmMIJERZiNYhfNTIc)kUdgOSoJuChm2MuCWrYf2RJhT46dKK(rsyusDLmmg9X0rulbgOayHbL8M1GERZiNKWwfkE8lfKkUdgy8MhP4qOXgrwNrko6ToJCkFuC2kk8R4oyGY6msXDWyBsXDWaL1z0ee9bGaygts4LCH964rlU(ajPFKegLuxjdJrFmDe1sGbkawyqjVznO36mYjP2AljSK8GbkRZOji6dabWmMKWl5bduwNrteASrK1z04XacGzmvO450kivC0BDg5u(O4Svu4xXTmgByROW)GvOqXXkumEZJuC9Rku8aJkivC0BDg5u(O4Svu4xXTmgByROW)GvOqXXkumEZJuClhsfkE4xfKko6ToJCkFuClqfeOmfhkiJfnKBcWq3KKARTKlmM5Wq8Zd2xOM5UvsT1wYfgZCyi(jQXCyi8iMBUBvC2kk8R4wgJnSvu4FWkuO4yfkgV5rkouqglAuHIhDUcsfh9wNroLpkUfOccuMIdwsEWaL1z0eHgBezDgjj8s2337eXQfnS3nC1IMaYZQhjPFKmmaukMr5rJapCfjj8s2337eXQfnS3nC1IMaYZQhjPFKeosQLK6k5c71XJwC9bssylPotsTMWffNTIc)koeRw0WE3WvlsfkEGlkivC0BDg5u(O4wGkiqzkoyj5bduwNrteASrK1zKKWljCKmmaukMr5rJapCfjjmL8yFjP2AlzFFVtaMXgrdn64Nqta5z1JK0psggakfZO8OrGhUIKe2scVKWrY((ENamJnIgA0XpHMaYZQhjPF0lPFjP2Al5bduwNrtq0hacGzmjHTIZwrHFfhaZyJOHgD8tivO4bgsbPIJERZiNYhf3cubbktXrpbGEEgLhnc8WZoIKWusyusT1ws6ja0Zs6hj1cgvC2kk8R44TyS6HoqTaIuHIhT8LcsfNTIc)kUoZC0aSrnko6ToJCkFuHIhT0sbPIJERZiNYhfNTIc)kULXydBff(hScfkowHIXBEKIRVlMtfkE06yfKko6ToJCkFuClqfeOmfhSK8GbkRZOjcn2iY6msXzROWVIBzm2WwrH)bRqHIJvOy8MhP4U1xOgvO4rl)sbPIJERZiNQR4wGkiqzkUWy0htxbIZJaulErt6ToJCscVKlSxhpAX1hOPJU1QcjHPEj1sXzROWVIdkEdLuHIhToTcsfNTIc)kodSSNgTBgIuC0BDg5u(OcvO4Ab0c71TqbPIhTuqQ4O36mYP8rfkEowbPIJERZiNYhvO4XVuqQ4O36mYP8rfkEoTcsfh9wNroLpQqXdmQGuXzROWVIdfKXIgfh9wNroLpQqXd)QGuXzROWVIRfhf(vC0BDg5u(Ocfp6CfKko6ToJCkFuClqfeOmfhWk3GoqFmnNdnRxsyk5P9LIZwrHFfNNb4LCJlgmCKfnQqXdCrbPIJERZiNYhf3cubbktXbljdJrFmrSArd7DdxTOj9wNrofNTIc)koaMXgrdn64NqQqfkouqglAuqQ4rlfKkUdgy8MhP4mV(g1mw43vrHFfh9wNroLpkoBff(vChmqzDgP4oySnP4wyVoE0IRpqthDRvfsct9sESK6k5XsQZKeosggJ(ycTbJc25bkafV0Sg0BDg5KeEjHLKoQVV3j0gmkyNhOau8sZASBLe2sQRK999o7aS5qLJM1y3kj8sspbGEwsykj)6ljHxsyjzFFVteVBgByVBSayeQJFcn3TQqXZXkivC0BDg5u(O4wGkiqzkUdgOSoJMMxFJAgl87QOWVIZwrHFfN513OgvO4XVuqQ4O36mYP8rXTavqGYuCWrYdgOSoJMMxFJAgl87QOWVKARTKKV3vBl5ME2hmAGVJOHgEgkiWWqidHQxs4LewsEWaL1z0ee9bGaygts4LewsEWaL1z0eHgBezDgjjSLeEj9Spy0WTbwu4xs9s6lfNTIc)kUd2xOgvO450kivC0BDg5u(O4wGkiqzkUdgOSoJMMxFJAgl87QOWVIZwrHFfhQXCyi8iMtfQqXTCifKkE0sbPIJERZiNYhf3cubbktX1337SZWyhBJIjGSviP2AlzyaOumJYJgbE4kss)Oxs(1xsQT2s23370Ca6nw90aSrnZDRIZwrHFfxlok8RcfphRGuXzROWVIRZWy34UbNvC0BDg5u(Ocfp(LcsfNTIc)kUobqeG36HQ4O36mYP8rfkEoTcsfh9wNroLpkUfOccuMIJEca980r3AvHKWuYt7lfNTIc)kodSSNgbgaOpuHIhyubPIZwrHFfhRG2eOb)12b1J(qXrV1zKt5Jku8WVkivC0BDg5u(O4wGkiqzkoyjzFFVtZbO3y1tdWg1m3TscVK0taONNo6wRkKeMs6lfNTIc)koZbO3y1tdWg1Ocfp6CfKko6ToJCkFuC2kk8R48maVKBCXGHJSOrXTavqGYuCWrYWaqPygLhnc8WvKK(rYf2RJhT46d00r3AvHKARTKWrs4ijWk3GoqFmnNdnRxsyk5P9LKARTK999odWMgDYa1dDcipREKKWusTGrjHBj777DAoa9gREAa2OMzn2TsQZKegLe2scVKWssuqglAi3eGHUjjHxYf2RJhT46d00r3AvHKWuVKR2HNDKbQLENKWTKAjjSLe2kUWaqPyuxfNx96imaukMr5rJapCfPcfpWffKko6ToJCkFuClqfeOmfh57D12sUz0aSJuOraQfVOZJaqMdjj8scljpyGY6mAIqJnISoJuC2kk8R4qTG6dvO4bgsbPIJERZiNYhf3cubbktXr(ExTTKBgna7ifAeGAXl68iaK5qscVKWsYdgOSoJMi0yJiRZijHxY((ENOwq9X0HH4vC2kk8R4CgG3lRG2eQqfkU(UyofKkE0sbPIJERZiNYhf3cubbktXTWED8OfxFGMo6wRkKeM6Lulj1vY((ENDa2COYrZASBLeEjb0fqOgRZifNTIc)koOnyuWopqbO4LuHINJvqQ4O36mYP8rXTavqGYuClSxhpAX1hOPJU1QcjHPEj1ssDLSVV3zhGnhQC0Sg7wj1vYWy0htFVRfVdhWGywd6ToJCscVK999oXTTyqS)kop3TscVKWrs6ja0ZZO8OrGhE2rKeMsESKWTKHXOpM(ExlEhoGbXSg0BDg5KuBTLeos2337ekGOhXB9ObewqaggkuYnGauOyTVx0C3kj8s2337ekGOhXB9ObewqaggkuYnGauOyTVx0eqEw9ij9JKhljSLe2koBff(vCTfkWSbQbhQqXJFPGuXrV1zKt5JIBbQGaLP4oyGY6mAIqJnISoJuC2kk8R4q1xOGaduakEjvOcfx)QGuXJwkivC0BDg5u(O4wGkiqzkoY37QTLCtutDWaa7hOZEEuaolj8sUWyMddXp7mZrJlBdaNNRgdaLqsct9sQLKWlzFFVZoZC04Y2aW55Uvs4Le1sm2imaukqZoZC04Y2aWzjHPEjpwX9MhP46mZrJlBdaNvC2kk8R4w2Vi2OVVxvO45yfKko6ToJCkFuClqfeOmfhQLySryaOuGMDM5OXLTbGZsct9sESKWljSKSVV3zNzoACzBa48C3Q4Svu4xX1zMJgx2gaoRcvOcvOcLca]] )

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