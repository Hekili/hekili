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

                if talent.deeper_stratagem.enabled then
                    local combo = min( 6, combo_points.current )
                    spend( combo, "combo_points" ) 
                    applyDebuff( 'target', 'between_the_eyes', combo )
                    return
                end   

                local combo = min( 5, combo_points.current )
                spend( combo, "combo_points" ) 
                applyDebuff( 'target', 'between_the_eyes', combo ) 
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
                applyBuff ('blade_rush', 5 )
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
                --[[if talent.alacrity.enabled and combo_points.current > 4 then 
                    if buff.alacrity.up then addStack( 'alacrity', 20 ) end
                    applyBuff( "alacrity", 20 )
                    return
                end ]]--
                if talent.deeper_stratagem.enabled then
                    local combo = min( 6, combo_points.current )
                    spend( combo, "combo_points" ) 
                    return
                end     
                local combo = min( 5, combo_points.current )
                spend( combo, "combo_points" ) 

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
                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                spend( combo, "combo_points" ) 

                for _, name in pairs( rtb_buff_list ) do
                    removeBuff( name )
                end

                applyBuff( "rtb_buff_1", 12 + 6 * ( combo - 1 ) )
                if buff.loaded_dice.up then
                    applyBuff( "rtb_buff_2", 12 + 6 * ( combo - 1 ) )
                    removeBuff( "loaded_dice" )
                end
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
                if talent.deeper_stratagem.enabled then
                    local combo = min( 6, combo_points.current )
                    spend( combo, "combo_points" ) 
                    applyBuff( "slice_and_dice", 12 + 6 * ( combo - 1 ) )
                    return
                end     
                local combo = min( 5, combo_points.current )
                spend( combo, "combo_points" )
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
    
    spec:RegisterPack( "Outlaw", 20180624.2030, [[dS0rYaqiiPEKkk2eKQpHQ0OGeDkiHvrvf5vKknlQQ6wqkAxk6xQqnmQk5yKswMkQEMkkzAqkCniLABuvHVrvLQXbPKohvvkRJQcZJQIUhPQ9bj5GuvjlKuXdrvftufs6IQqInIQkvFesjojQQQvskMjQQYnvrP0orv5NQOumuvuQwQkK6POYuHqxfvvkFfvvYEj5VkmyrhMYILQhRKjtLlJSzv6Zq0OLItlz1uvr51OkMnk3MQSBv9BOgUu64uvQLd8Cqtx46k12vbFhcgVkeNxfz9uvr18jLA)eR0sHOIZzbP47CFPfA1x(X5OX8CFDUFZxAP4ItTKIR1w8yijf3BEKI7SzhmdbfxRDIHnNcrfheVblsX1erl0hhFCRbdQx)CH9ogyiC8r5S9S9S7NxhAvC9DXc()vDfNZcsX35(sl0QV8JZrJPw(Hw(X5(nfhSLwk(o3p8LIZrWLIdXMckzbLmAijD012Sqs)Aff(L8SBlEK8IbsE2SdMHGKhng5MGswVK6yrWijVyGK(LFobWrZu0iA4)qYckz3GKts8lz0qsYQNhYjzlaFlgjjcv0iPx9yGKMZpBddp6dOKEMJMIgrJwtjL0VCoYjPouGarVKrdj5r5ebLmWsgnKK8ERVGn8kPTk8ljRGH)swxjpH3s2yhijreSjj1Hmq9iLStlBdjj5FjVelKKv8qswXuX1cW3IrkUZijInfushDTnlK0wrHFjBbfguXjjzfmKSGsA7a7zrTmg7KKlazb5KSBqYjj(L8eEdKC1yaBfeykAoJK8FizbL0K0IG8AdjdSKTa8HYrsEcVLeHkAK0K0wrHFjzfmKmASqYckzhhnsclVwgjP9ojBb2kQL1zK)IMZijcnfJKeqWnlQhPK1lPjPhzF9iVBMK27Kejg7KewEBMff(NsY)HKE2jjFCijGGBwiz9sgnKKwhIz7GyNKSPq2qWqYwmewDgjPRfofnNrs(DIysEbejzGLKCv4VKMZAdjT3jz51cWhijRqYal5j8gijgHxYNihCkAoJKCL3MzrHF(by3qYckPXqWobLKHX8upsjVyGK7wNfeus7DswETa8bYJ(akzGLmAijD012SqsBff(LKvWaofnIMZi5r5i0AhKtYoDXasYf2RBHKDcz9WPK(1ArTbuYh)OzJb8UBMK2kk8dLe)SttrJTIc)WzlGwyVUf6VmdYJOXwrHF4SfqlSx3cD1FSTr6rFyrHFrJTIc)WzlGwyVUf6Q)4lg7enNrsU3AHn4qsGvoj777LCscdlGs2PlgqsUWEDlKStiRhkP9ojBbeA2IJOEKswqjD4NMIgBff(HZwaTWEDl0v)XW3AHn4yadlGIgBff(HZwaTWEDl0v)XWGmw0iASvu4hoBb0c71Tqx9h3IJc)IgBff(HZwaTWEDl0v)XEgGhYnUyWWrw04FD1dSYnOd0htZ5GZ6rfA4lrJTIc)WzlGwyVUf6Q)yaMXgrdn64NG(xx9Oomg9XeYQfnS3nC1IM0BDg5enIMZi5r5i0AhKts6abojzuEKKrdjPTcmqYckPDWkM1z0u0CgjpAcGzmjrOHEj5pS5iNKh1Arswqj3TsAVtY6k5j8wYg7ajjJGqjJg7L8Cj777fkjgijJGqjJg7LenK0ENKpwsebBssDidupYPK8RkAKK7pQ(l5c)WYrajJglKebsYNoqajBSdKKbwsabWm2u0yROWpu)bduwNr()MhPhe9bGaygZ)dgBt6rDym6JjKvlAyVB4QfnP36mYHEFFVtg2CKB4Qfn3TOJsq0h999c955ARnkbrF033l0NOb6OUVV3za20OtgOEKZDlkqHO5msYp43vrHFjdSKBijjx9fmiGKCbO4HKeHg6L8XHKacGzS6rk5rh6ijgijcn0l5gwpsj5(JQOXwrHFOU6p(GbkRZi)FZJ0dHJnKSoJgpgqamJ5)bJTj9OCH964rlU(a6t0w3Wy0hthrTeyadGfgsYBsV1zKdfIMZij)GFxff(LmWsUHKKC1xWGasYfGIhYFjrOHEjpH3s2yhijp6qhjXajFCiASvu4hQR(JpyGY6mY)38i9q4ydjRZi)pySnP)GbkRZOji6dabWmg6lSxhpAX1hqFI26ggJ(y6iQLadyaSWqsEt6ToJCARnQpyGY6mAcI(aqamJH(bduwNrtiCSHK1z04XacGzmrZzKKpmWZyscWHff(fn2kk8d1v)XlJXg2kk8pyfm8)npsF)kASvu4hQR(JxgJnSvu4FWky4)BEK(LdkAoJK8d(Dvu4hkPbijBiajzGL0oGlNKiGbrdJGqjxn0IhjRRKpoAQhPKfus7GvmRZirJTIc)qD1F8YySHTIc)dwbd)FZJ0ddYyrJ)1vpmiJfnKBcWi3K2AVWyMdJWppyFbBM7wT1EHXmhgHFcBmhgbpI5M7wrJTIc)qD1FmKvlAyVB4Qf5FD1J6dgOSoJMq4ydjRZi0777Dcz1Ig27gUArta5z1d9zyaKumJYJgbE4kc9((ENqwTOH9UHRw0eqEw9qFIsT0DH964rlU(aIc)Kwt0QOXwrHFOU6pgGzSr0qJo(jO)1vpQpyGY6mAcHJnKSoJqhLHbqsXmkpAe4HRiuDUV0w7((ENamJnIgA0XpbNaYZQh6ZWaiPygLhnc8WvekqhL999obygBen0OJFcobKNvp0N6plT1(GbkRZOji6dabWmgken2kk8d1v)X8umw9ihWwar(xx90taKNMr5rJap8SJGk0wBTPNaip5tTqBrJTIc)qD1FCNzoAa2WgrJTIc)qD1F8YySHTIc)dwbd)FZJ033fZjASvu4hQR(JxgJnSvu4FWky4)BEK(B9fSX)6Qh1hmqzDgnHWXgswNrIMZijAbVrsswqj3qYjPbL0KKFo7sIwONawGbsIqtXijFC0upsjjgKKSGsAhSIzDgjP9ojpH3s2yhijpQfiojjIGAXduYWy0htj5)GxOK7Nv8qStsgnwi5j8MxgtYojP1zKKbwshwYOPGsIBJYZyStswpAI08ijH1VijRqsa57DbiOKbwsp8bsY6L8cWFij(kz0qsggajf(lzFhswbVqjBiajjel5j8wYL9s67T9rDRtswbuYdgBttrJTIc)qD1Fms8gj5FD1hgJ(y6kqCAeGAXdCsV1zKd9f2RJhT46d40r3AvbQ0RLOXwrHFOU6p2al7Pr7MbjrJO5msQdZCKK87SnaCs0yROWpC2V6x2Vi2OVVx)FZJ03zMJgx2gao5FD1t(ExTTKBcBQdgay)aEYZJcWj0xymZHr4NDM5OXLTbGtZvJbqsquPxl0777D2zMJgx2gaon3TOdBjgBegajfWzNzoACzBa4eQ0FUOXwrHF4SF1v)XDM5OXLTbGt(xx9WwIXgHbqsbC2zMJgx2gaoHk9NJoQ777D2zMJgx2gaon3TIgrZzKuNDXCeakASvu4ho77I50JSbdd2PbmafpK)1v)c71XJwC9bC6OBTQav61s3((ENDa2CWYrZDl6a6ciyJ1zKOXwrHF4SVlMtx9h3wWaZgWgC4FD1VWED8OfxFaNo6wRkqLET0TVV3zhGnhSC0C3QBym6JPV31INHdyimP36mYHEFFVtCBlge7VItZDl6OKEcG80mkpAe4HNDeuDoAggJ(y67DT4z4agct6ToJCARnk777DIeq0d5PE4abliadJej5giakyS23lCUBrVVV3jsarpKN6HdeSGammsKKBGaOGXAFVWjG8S6H(8CuGcrJTIc)WzFxmNU6pgwFbdcmGbO4H8VU6pyGY6mAcHJnKSoJenIMZij)GXmhgHhkASvu4hoxoO(wCu43)6QVVV3zNHXo2ggtazRqBTddGKIzuE0iWdxr(uVF4lT1UVV3P5a0BS6PbydBM7wrJTIc)W5Yb1v)XDgg7g3n4KOXwrHF4C5G6Q)4obGeGN6rkASvu4hoxoOU6p2al7PrGba6d)RRE6jaYtthDRvfOcn8LOXwrHF4C5G6Q)ywHSjGd)STdPh9HOXwrHF4C5G6Q)yZbO3y1tdWg24FD1J6((ENMdqVXQNgGnSzUBrNEcG800r3AvbQ8LOXwrHF4C5G6Q)ypdWd5gxmy4ilA8pmaskg1vVx9(imaskMr5rJapCf5FD1hgajfZO8OrGhUI85c71XJwC9bC6OBTQqBTrjkbw5g0b6JP5CWz9Ocn8L2A3337maBA0jdupYjG8S6HOsl0gn777DAoa9gREAa2WM5U1pH2OaDuddYyrd5MamYnH(c71XJwC9bC6OBTQav6xTdp7idyl9o0uluiASvu4hoxoOU6pg2cQp8VU6jFVR2wYnJgGDKcocqT4bEAeaYCq0r9bduwNrtiCSHK1zKOXwrHF4C5G6Q)yNb45YkKnH)1vp57D12sUz0aSJuWraQfpWtJaqMdIoQpyGY6mAcHJnKSoJqVVV3jSfuFmDyeErJO5msYVxFbBiau0Cgj1bXJIK1lPN9bJKCdjNKbwYoj5r9SZj5t7aymj77qYckPjjddHs62KKbwY4CTen2kk8dN36lyJ(ofiq0pIgAqNiO)1vp57D12sUjsarpKN6HdeSGammsKKBGaOGXAFVq0rDFFVtKaIEip1dhiybbyyKij3abqbJ1(EHZDROXwrHF48wFbB0v)XUc2AXQr0iAoJKCbzSOr0yROWpCcdYyrJ(dgOSoJ8)npsV513WMXc)Ukk87)bJTj9lSxhpAX1hWPJU1QcuP)CDp3pHYWy0htKnyyWonGbO4HM0BDg5qh1oQVV3jYgmmyNgWau8qZDlk0TVV3zhGnhSC0C3Io9ea5ju5h(cDu3337eYZMXg27glagc74NGZDROXwrHF4egKXIgD1FS513Wg)RR(dgOSoJMMxFdBgl87QOWVOXwrHF4egKXIgD1F8b7lyJ)1vpkpyGY6mAAE9nSzSWVRIc)ARn57D12sUPN9bJg47iAOHNbdcmmi0GW6rh1hmqzDgnbrFaiaMXqh1hmqzDgnHWXgswNrOaDp7dgnCBGff(17lrJTIc)WjmiJfn6Q)yyJ5Wi4rmN)1v)bduwNrtZRVHnJf(Dvu4xXHGb(6rcvC8l)6O5J)5dT4djLeXgsYYRfdcjVyGK8cdYyrdVsciFVla5KeI9ijTDG9SGCsUAShjbNIg(REssT8HK8d(pqGGCsYBym6JjYgmmyNgWau8qt6ToJC8kzGLK3Wy0htKnyyWonGbO4HM1GERZihVsEXaj9SOH8SOwgtYf2R1afe)sIsTockMIg(REssT8HK8d(pqGGCsYRJ677DISbdd2Pbmafp0C3YRKbwsEDuFFVtKnyyWonGbO4HM1y3YRKxmqsplAiplQLXKCH9AnqbXVKOuRJGIPOH)QNKulFij)G)deiiNK82337SdWMdwoAUB5vYaljV999o7aS5GLJM1y3YRKxmqsplAiplQLXKCH9AnqbXVKOuRJGIPObXgsYlMXWiupsjTnWGsIabij3qYjz9sgnKK2kk8ljRGHK9DijceGK8XHKx8(DswVKrdjP5C4xsNfw3GKpensIMs2byZblhjAKenLeYZMXg27glagc74NGIgrd)YVoA(4F(ql(qsjrSHKS8AXGqYlgijVo6ABwWRKaY37cqojHypssBhypliNKRg7rsWPOH)QNK8CFij)G)deiiNK8ggJ(y6iQLadyaSWqsEt6ToJC8kzGLK3Wy0hthrTeyadGfgsYBwd6ToJC8k5fdK0ZIgYZIAzmjxyVwduq8ljk16iOykA4V6jjplFij)G)deiiNK8ggJ(y6iQLadyaSWqsEt6ToJC8kzGLK3Wy0hthrTeyadGfgsYBwd6ToJC8k5fdK0ZIgYZIAzmjxyVwduq8ljk16iOykA4V6jj1cn8HK8BpC32Ibb5K0wrHFj51al7Pr7MbjENIgeBijVygdJq9iL02adkjceGKCdjNK1lz0qsAROWVKScgs23HKiqasYhhsEX73jz9sgnKKMZHFjDwyDds(q0ijAkza20OtgOEKIgrd)YVoA(4F(ql(qsjrSHKS8AXGqYlgijV36lydVsciFVla5KeI9ijTDG9SGCsUAShjbNIgeBijVygdJq9iL02adkjceGKCdjNK1lz0qsAROWVKScgs23HKiqasYhhsEX73jz9sgnKKMZHFjDwyDds(q0ijAkjsarpKN6HdeSGammsKKBGaOGXAFVqrJOHF5xhnF8pFOfFiPKi2qswETyqi5fdKK3LdYRKaY37cqojHypssBhypliNKRg7rsWPOH)QNK0V7dj5h8FGab5KK3((ENMdqVXQNgGnSzUB5vYaljV999onhGEJvpnaByZSg7wEL8Ibs6zrd5zrTmMKlSxRbki(LeLADeumfn8x9KK(nFij)2d3TTyqqojTvu4xsEDgGNlRq2e8ofni2qsEXmggH6rkPTbguseiaj5gsojRxYOHK0wrHFjzfmKSVdjrGaKKpoK8I3VtY6LmAijnNd)s6SW6gK8HOrs0uYaSPrNmq9ifnIg(LFD08X)8Hw8HKsIydjz51IbHKxmqsE77I54vsa57DbiNKqShjPTdSNfKtYvJ9ij4u0WF1tsQLpKKFW)bceKtsE777D2byZblhn3T8kzGLK3((ENDa2CWYrZASB5vYlgiPNfnKNf1YysUWETgOG4xsuQ1rqXu0WF1tsEUpKKFW)bceKtsEdJrFm99Uw8mCadHj9wNroELmWsYBym6JPV31INHdyimRb9wNroEL8Ibs6zrd5zrTmMKlSxRbki(LeLNFeumfn8x9KKN7dj5h8FGab5KK3((ENDa2CWYrZDlVsgyj5TVV3zhGnhSC0Sg7wEL8Ibs6zrd5zrTmMKlSxRbki(LeLADeumfni2qsEXmggH6rkPTbguseiaj5gsojRxYOHK0wrHFjzfmKSVdjrGaKKpoK8I3VtY6LmAijnNd)s6SW6gK8HOrs0uYoaBoy5irJKOPKibe9qEQhoqWccWWirsUbcGcgR99cfnIg(LFD08X)8Hw8HKsIydjz51IbHKxmqsE7xELeq(ExaYjje7rsA7a7zb5KC1ypscofn8x9KKA5dj53E4UTfdcYjPTIc)sY7Y(fXg999Y7u0iA4FVwmiiNK(DjTvu4xswbd4u0O4SD0Gbko)IXd9MIJvWaQquXDRVGnkev8PLcrfh9wNroLokUfOccuMIJ89UABj3ejGOhYt9WbcwqaggjsYnqauWyTVxOKOljQLSVV3jsarpKN6HdeSGammsKKBGaOGXAFVW5UvXzROWVIRtbce9JOHg0jcQcfFNRquXrV1zKtPJIZwrHFfxNcei6hrdnOteuXTavqGYuC999ob7OHrq4OfqRcw4FUBvHIVZsHOIZwrHFfNRGTwSAuC0BDg5u6OcvO4C012SqHOIpTuiQ4O36mYP0rXDWyBsXHAjdJrFmHSArd7DdxTOj9wNrojrxY((ENmS5i3WvlAUBLeDjrPKGOp677fkPpL8Cj1wBjrPKGOp677fkPpLenKeDjrTK999odWMgDYa1JCUBLefsIcfNTIc)kUdgOSoJuChmW4npsXbI(aqamJPcfFNRquXrV1zKtPJI7GX2KIdLsUWED8OfxFaL0NsI2sQRKHXOpMoIAjWagalmKK3Sg0BDg5KefkoBff(vChmqzDgP4oyGXBEKIdchBizDgnEmGaygtfk(olfIko6ToJCkDuChm2MuChmqzDgnbrFaiaMXKeDjxyVoE0IRpGs6tjrBj1vYWy0hthrTeyadGfgsYBwd6ToJCsQT2sIAjpyGY6mAcI(aqamJjj6sEWaL1z0echBizDgnEmGaygtXzROWVI7GbkRZif3bdmEZJuCq4ydjRZivO4dnuiQ4O36mYP0rXzROWVIBzm2WwrH)bRGHIJvWy8MhP46xvO4dTviQ4O36mYP0rXzROWVIBzm2WwrH)bRGHIJvWy8MhP4woOku85hkevC0BDg5u6O4wGkiqzkoyqglAi3eGrUjj1wBjxymZHr4NhSVGnZDRKARTKlmM5Wi8tyJ5Wi4rm3C3Q4Svu4xXTmgByROW)GvWqXXkymEZJuCWGmw0OcfF(DfIko6ToJCkDuClqfeOmfhQL8GbkRZOjeo2qY6mss0LSVV3jKvlAyVB4QfnbKNvpusFkzyaKumJYJgbE4kss0LSVV3jKvlAyVB4QfnbKNvpusFkjkLulj1vYf2RJhT46dOKOqs)KKAnrRkoBff(vCqwTOH9UHRwKku8HwviQ4O36mYP0rXTavqGYuCOwYdgOSoJMq4ydjRZijrxsukzyaKumJYJgbE4kssuj55(ssT1wY((ENamJnIgA0XpbNaYZQhkPpLmmaskMr5rJapCfjjkKeDjrPK999obygBen0OJFcobKNvpusFQxYZssT1wYdgOSoJMGOpaeaZysIcfNTIc)koaMXgrdn64NGQqXNFtHOIJERZiNshf3cubbktXrpbqEAgLhnc8WZoIKOss0wsT1ws6jaYts6tj1cTvC2kk8R44PyS6roGTaIuHIpT8LcrfNTIc)kUoZC0aSHnko6ToJCkDuHIpT0sHOIJERZiNshfNTIc)kULXydBff(hScgkowbJXBEKIRVlMtfk(06CfIko6ToJCkDuClqfeOmfhQL8GbkRZOjeo2qY6msXzROWVIBzm2WwrH)bRGHIJvWy8MhP4U1xWgvO4tRZsHOIJERZiNQR4wGkiqzkUWy0htxbItJaulEGt6ToJCsIUKlSxhpAX1hWPJU1QcjrLEj1sXzROWVIdjEJKuHIpTqdfIkoBff(vCgyzpnA3miP4O36mYP0rfQqX1cOf2RBHcrfFAPquXrV1zKtPJku8DUcrfh9wNroLoQqX3zPquXrV1zKtPJku8HgkevC0BDg5u6OcfFOTcrfNTIc)koyqglAuC0BDg5u6OcfF(HcrfNTIc)kUwCu4xXrV1zKtPJku853viQ4O36mYP0rXTavqGYuCaRCd6a9X0Co4SEjrLKOHVuC2kk8R48mapKBCXGHJSOrfk(qRkevC0BDg5u6O4wGkiqzkoulzym6JjKvlAyVB4QfnP36mYP4Svu4xXbWm2iAOrh)eufQqXTCqfIk(0sHOIJERZiNshf3cubbktX1337SZWyhBdJjGSviP2AlzyaKumJYJgbE4kssFQxs)WxsQT2s23370Ca6nw90aSHnZDRIZwrHFfxlok8RcfFNRquXzROWVIRZWy34UbNuC0BDg5u6OcfFNLcrfNTIc)kUobGeGN6rQ4O36mYP0rfk(qdfIko6ToJCkDuClqfeOmfh9ea5PPJU1QcjrLKOHVuC2kk8R4mWYEAeyaG(qfk(qBfIkoBff(vCScztah(zBhsp6dfh9wNroLoQqXNFOquXrV1zKtPJIBbQGaLP4qTK999onhGEJvpnaByZC3kj6sspbqEA6OBTQqsujPVuC2kk8R4mhGEJvpnaByJku853viQ4O36mYP0rXzROWVIZZa8qUXfdgoYIgf3cubbktXHsjddGKIzuE0iWdxrs6tjxyVoE0IRpGthDRvfsQT2sIsjrPKaRCd6a9X0Co4SEjrLKOHVKuBTLSVV3za20OtgOEKta5z1dLevsQfAljAkzFFVtZbO3y1tdWg2mRXUvs)KKOTKOqs0Le1scdYyrd5MamYnjj6sUWED8OfxFaNo6wRkKev6LC1o8SJmGT07KenLuljrHKOqXfgajfJ6Q48Q3hHbqsXmkpAe4HRivO4dTQquXrV1zKtPJIBbQGaLP4iFVR2wYnJgGDKcocqT4bEAeaYCqjrxsul5bduwNrtiCSHK1zKIZwrHFfhSfuFOcfF(nfIko6ToJCkDuClqfeOmfh57D12sUz0aSJuWraQfpWtJaqMdkj6sIAjpyGY6mAcHJnKSoJKeDj777DcBb1hthgHxXzROWVIZzaEUScztOcvO4GbzSOrHOIpTuiQ4O36mYP0rXDWyBsXTWED8OfxFaNo6wRkKev6L8Cj1vYZL0pjjkLmmg9XezdggStdyakEOznO36mYjj6sIAjDuFFVtKnyyWonGbO4HM1y3kjkKuxj777D2byZblhnRXUvs0LKEcG8KKOss)WxsIUKOwY((ENqE2m2WE3ybWqyh)eCUBvC2kk8R4oyGY6msXDWaJ38ifN513WMXc)Ukk8RcfFNRquXrV1zKtPJIBbQGaLP4oyGY6mAAE9nSzSWVRIc)koBff(vCMxFdBuHIVZsHOIJERZiNshf3cubbktXHsjpyGY6mAAE9nSzSWVRIc)sQT2ss(ExTTKB6zFWOb(oIgA4zWGaddcniSEjrxsul5bduwNrtq0hacGzmjrxsul5bduwNrtiCSHK1zKKOqs0L0Z(Grd3gyrHFj1lPVuC2kk8R4oyFbBuHIp0qHOIJERZiNshf3cubbktXDWaL1z0086ByZyHFxff(vC2kk8R4GnMdJGhXCQqfkU(UyofIk(0sHOIJERZiNshf3cubbktXTWED8OfxFaNo6wRkKev6Lulj1vY((ENDa2CWYrZASBLeDjb0fqWgRZifNTIc)koKnyyWonGbO4HuHIVZviQ4O36mYP0rXTavqGYuClSxhpAX1hWPJU1QcjrLEj1ssDLSVV3zhGnhSC0Sg7wj1vYWy0htFVRfpdhWqywd6ToJCsIUK999oXTTyqS)kon3TsIUKOus6jaYtZO8OrGhE2rKevsEUKOPKHXOpM(ExlEgoGHWSg0BDg5KuBTLeLs2337ejGOhYt9WbcwqaggjsYnqauWyTVx4C3kj6s2337ejGOhYt9WbcwqaggjsYnqauWyTVx4eqEw9qj9PKNljkKefkoBff(vCTfmWSbSbhQqX3zPquXrV1zKtPJIBbQGaLP4oyGY6mAcHJnKSoJuC2kk8R4G1xWGadyakEivOcfx)QquXNwkevC0BDg5u6O4Svu4xXTSFrSrFFVkUfOccuMIJ89UABj3e2uhmaW(b8KNhfGtsIUKlmM5Wi8ZoZC04Y2aWP5QXaijOKOsVKAjj6s2337SZmhnUSnaCAUBLeDjHTeJncdGKc4SZmhnUSnaCssuPxYZvCV5rkUoZC04Y2aWjvO47CfIko6ToJCkDuClqfeOmfhSLySryaKuaNDM5OXLTbGtsIk9sEUKOljQLSVV3zNzoACzBa40C3Q4Svu4xX1zMJgx2gaoPcvOcvOcLca]] )


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