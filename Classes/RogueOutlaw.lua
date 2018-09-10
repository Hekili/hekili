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


        -- Azerite Powers
        brigands_blitz = {
            id = 277725,
            duration = 20,
            max_stack = 10,
        },
        deadshot = {
            id = 272940,
            duration = 3600,
            max_stack = 1,
        },
        paradise_lost = {
            id = 278962,
            duration = 3600,
            max_stack = 1,
        },
        snake_eyes = {
            id = 275863,
            duration = 12,
            max_stack = 5,
        },
        storm_of_steel = {
            id = 273455,
            duration = 3600,
            max_stack = 1,
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
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up
            end

            return false
        end
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
            removeBuff( "shadowmeld" )
            if buff.stealth.up then
                removeBuff( "stealth" )
                setCooldown( "stealth", 2 )
            end

            if level < 116 and equipped.mantle_of_the_master_assassin then
                applyBuff( "master_assassins_initiative", 5 )
            end
        end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if amt >= 5 and resource == "combo_points" then
            gain( 1, "combo_points" )
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

            nobuff = "stealth",
            
            handler = function ()
                applyBuff( 'adrenaline_rush', 20 )

                if buff.stealth.up then
                    setCooldown( "stealth", 2 )
                    removeBuff( "stealth" )
                end
                removeBuff( "vanish" )
                removeBuff( "shadowmeld" )

                if talent.loaded_dice.enabled then
                    applyBuff( 'loaded_dice', 45 )
                    return
                end

                if azerite.brigands_blitz.enabled then
                    applyBuff( "brigands_blitz" )
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
                    applyDebuff( 'target', 'prey_on_the_weak', 6 )
                end

                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                applyDebuff( 'target', 'between_the_eyes', combo_points.current ) 

                if azerite.deadshot.enabled then
                    applyBuff( "deadshot" )
                end

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
            
            usable = function () return buff.blade_flurry.remains < gcd.execute end,
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
                
                removeBuff( "storm_of_steel" )

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
            
            toggle = 'interrupts', 
            interrupt = true,

            startsCombat = true,
            texture = 132219,
            
            usable = function () return target.casting end,
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

                removeBuff( "deadshot" )
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
            
            notalent = 'slice_and_dice',

            spend = 25,
            spendType = "energy",
            
            startsCombat = false,
            texture = 1373910,
            
            usable = function ()
                if combo_points.current == 0 then return false end

                if buff.roll_the_bones.down then return true end
                
                -- Don't RtB if we've already done a simulated RtB.
                if buff.rtb_buff_1.up then return false end

                -- Handle reroll checks for pre-combat.
                if time == 0 then
                    if azerite.snake_eyes.rank >= 2 and buff.snake_eyes.stack >= 2 - ( buff.broadside.up and 1 or 0 ) then return false end
                    if azerite.snake_eyes.enabled and ( rtb_buffs < 2 or ( azerite.snake_eyes.rank == 3 and rtb_buffs < 5 ) ) then return true end
                    if ( azerite.deadshot.enabled or azerite.ace_up_your_sleeve.enabled ) and ( rtb_buffs < 2 and ( buff.loaded_dice.up or buff.ruthless_precision.remains <= cooldown.between_the_eyes.remains ) ) then return true end
                    if rtb_buffs < 2 and ( buff.loaded_dice.up or ( not buff.grand_melee.up and not buff.ruthless_precision.up ) ) then return true end
                end

                return true
            end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                for _, name in pairs( rtb_buff_list ) do
                    removeBuff( name )
                end

                if azerite.snake_eyes.enabled then
                    applyBuff( "snake_eyes", 12, 5 )
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

            talent = "slice_and_dice",
            
            usable = function()
                if combo_points.current == 0 or buff.slice_and_dice.remains > 6 + ( 6 * combo_points.current ) then return false end
                return true
            end,

            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
                
                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyBuff( "slice_and_dice", 6 + 6 * ( combo - 1 ) )
                spend( combo, "combo_points" )
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
                applyBuff( "tricks_of_the_trade" )
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

    
    spec:RegisterPack( "Outlaw", 20180902.2146, [[d8KaTaqisj9ivPAteP(KuvszuGsDkqjRsvcELk0SisUfPq7sKFPcgMQKogOYYur9mPQY0if01iLyBsvHVreKghriNJuGwNQe18uLY9uf7Ju0bvLilKi6HsvPMOuv0fjfWgLQs8rPQKQtkvvvRKu5LsvvYmLQss3KiO2jrXpvLqdLiWrLQsILskLNQstfu1vjcITkvvH(QuvfDwPQkyVi9xrnyLomLflLhlyYKCzuBgKptQA0c1PvSAPQk1RbfZMWTfYUb(nIHlvoUuvvwouphY0P66QQTlv57eLgpPuDEIQ1teQ5RISFjtHJcp9QmNPYC(v4KOx1GVEoDUFAOw0sFqVU8oME7SamMEMEbwetVV43fMS0BNjxqmffE6fr(4atVXU3HE5dh0pE8VLcKOdOj6lmFiGa2G8dOjkCOjiTdnitJkU3HombAem6GeGzTzJcDqc0wwBe9Fo)IFxyYMqtuGEB)r49FaTrVkZzQmNFfoj6vn4RNtN7NgQfTah9I64avMZ9XR0RIrb699AFXVlmzRvBe9FU09ES7DOx(Wb9Jh)BPaj6aAI(cZhciGni)aAIchAcs7qdY0OI7DOdtGgbJoibywB2OqhKaTL1gr)NZV43fMSj0efkDVx7L7CoQX4AplvTNFfojQwnwlCW9Y971ALajCPR09ET9DSb0ZOxU09ETAS2xsPyvT9xtaMADsTkgY(cVwl4dbuRyqEQ09ETASwjmPhRQ96Sj84AniNX1(skmdmXa4A12hfx7aQTdZbsuZ8ATGpeqTIb5j6TdtGgbtVVx7l(DHjBTAJO)ZLU3Rn29o0lF4G(XJ)TuGeDanrFH5dbeWgKFanrHdnbPDObzAuX9o0HjqJGrhKamRnBuOdsG2YAJO)Z5x87ct2eAIcLU3R9YDoh1yCTNLQ2ZVcNevRgRfo4E5(9ATsGeU0v6EV2(o2a6z0lx6EVwnw7lPuSQ2(RjatToPwfdzFHxRf8HaQvmipv6EVwnwReM0Jv1ED2eECTgKZ4AFjfMbMyaCTA7JIRDa12H5ajQzETwWhcOwXG8uPR09ETAaTZHVZQABmebZ1girnZRTX6hakv7lfcCNJQfqaAm2WrqFrTwWhcavlbiKNkDwWhcaL6WCGe1m)bsyiykDwWhcaL6WCGe1m)4Zb7RpIbU5dbu6SGpeak1H5ajQz(XNdqeIQ09ETxG1HIjETyBu12(qqSQwKBoQ2gdrWCTbsuZ8ABS(bGQ1aQA7WSg7iUpa91oOAveaNkDwWhcaL6WCGe1m)4ZbeW6qXepJCZrLol4dbGsDyoqIAMF85qhXhcO0zbFiauQdZbsuZ8JphImmmSkdrWzfBESuDyoqIAMNrCGauOhTi1a9GTrL5EmWtMsHsdqtn81sNf8HaqPomhirnZp(CateIShZ5gbWiP6WCGe1mpJ4abOqpNlDwWhcaL6WCGe1m)4ZbKycC2aQSAcSuDyoqIAMNrCGauONZLol4dbGsDyoqIAMF85GPWmWedGZ4pkwQomhirnZZioqak0dCLol4dbGsDyoqIAMF85aYzt4XLUs371Qb0oh(oRQL7Xy516texRhZ1AbNGRDq1A9SrynbNkDVxR2ymriQfIGR98XABFiiuTYoECT9vjMIv12NtGR93LQ9f9ygl7G4AXmMie1crW1E(yTeCT91XgqvReMfmxlbxR2(ESGrOALamhg0qaPsNf8Haqp9m8ynblfWI4hS3YygtecP6zIp)G9wU9HGqVDwAy3(qqjbXuSkRMaN(DNoP12hckPhBavoIfmN(DsR12hckH)ESGrOChMddAiG0VdwLU3RvBmMie1crW1E(yTTpeeQwcUwT99ybJq1kbyomOHaQv2XJRTpztHIjETAZaWu75JPsNf8HaqhFo0ZWJ1eSualIFWElJzmriKI09GyxQb6XKygpoNuSPqXepHnamA(CwQEM4ZpyVLBFii0BNLg2TpeusqmfRYQjWPF3PtTpeuc)9ybJq5omhg0qajmhzda92tGqekISGuJDzzgK9yoZYzucZr2aqWQ09ETVKqwtoQwmJjcrTqeCTNpwB7dbHQv2XJR9cmy4A1aYzuTFGGrOAnV2(vR2mamiPQ1JzqTygteIA5EmwUhpa9PsNf8HaqhFo0ZWJ1eSualIFWElJzmriKI09GyxQb6XKygpoNqadgoZYzuIbwtWkP6zIp)G9wU9HGqVD(0jyBsmJhNtiGbdNz5mkHnamp9tAS3YTpee6nTaRs3712NKAbeVwmJjcrTduTxGbdxRgqoJQDq1AETNpwR2mamOAnGQ2ZhRf5waguTeOA9yU22hcQwyd3XArUfGPwzhpUwjXetHgfx7VdwLol4dbGo(CONHhRjyPawe)G9wgZyIqifP7bZi2LAGEmjMXJZjeWGHZSCgLWgagnFolD7dbLqadgoZYzuc5wagnFoRX2hck1WetHgfN(DLol4dbGo(CONHhRjyPawe)yrTpkohia14dbivpt85NajQrYDKb4OKIHMW4A(C(45xa2UjyGN0htqUqEg54bgoXaRjyL0bcrOiYcs6JjixipJC8adNWCKna0BWbRJTpeuQHjMcnko97KMbmwVCn7JxLwRTpeucbZxiYgqLdycc1iagL(DLU3RT)C84AJ(cF6eCTUH1ZosQA94bvBpdpwtW1oOAdXCagwvRtQvXHrX1kBm7XmUwejIRTV7tuTOyYxOQTX1IKdcSQwzhpUwjfMIRTVi(yS8sNf8HaqhFo0ZWJ1eSualIFActXziXhJLNrYbbP6zIp)G6yHi7gwp7Outykodj(yS83oln2gvM7Xapzkfknanp)6PtTpeuQjmfNHeFmwE63v6SGpea64ZbyMamLol4dbGo(Ciycr2c(qazXGCPawe)GC2eESud0dYzt4XSkzcrPZc(qaOJphcMqKTGpeqwmixkGfXpbfQ09ET9LbmO4AnV2it7t0pQ2(wcs1E)nKJTGxlbW1crW1YwiUwjXetHgfxRbu1(IDDeS)bJlVwzJzqT9v(taMA7tSjBTdQwel4GZQAnGQwjmuFw7GQfq8AXSPKxRb5mUwpMRfWA3RfXbcqLkDwWhcaD85qWeISf8HaYIb5sbSi(bAadkwQb6jqIAKChzaosZNqxoY0Eg1XaLgHD7dbLAyIPqJIt)UJTpeuI01rW(hmU80VdwVaSDtWap1)(taMScBYMyG1eSsAyRv3emWtrgggwLHi4SInpoXaRjy1PtbcrOiYcsrgggwLHi4SInpoH5iBainHdwWQ0zbFia0XNdbtiYwWhcilgKlfWI4N2FeQsNf8HaqhFoy4Gb4StWyg4snqpmGX6LNum0egxZh40YrgWy9YtywpdkDwWhcaD85GHdgGZDFbIlDwWhcaD85Gy0h7OC)9xPpIbEPR09ETs(hHIXOsNf8HaqP2FeQNUb5ergftCPgONajQrYDKb4OKIHMW4A(a3X2hck1WetHgfN(DhDtWap1)(taMScBYMyG1eSs62hckr66iy)dgxE63v6SGpeak1(JqD85aAadYzCg54bgU0v6EV2(MqekISauPZc(qaOuqHE6i(qasnqpTpeuQjieL4J8eMTGF6KBy9SN8jIZojRg(TN(41tNAFiOKPWmWedGZ4pko97kDVxBFXeIbOV2MfGPwNuRIHSVWRDCoQ2pY0ZLol4dbGsbf64ZHpIZJZrsbSi(r8roM8rz9eHIb5oXpY0ZsnqpTpeuQjieL4J8eMTGF6KBy9SN8jIZojRg(TNZVE6uGe1i5oYaCusXqty83Eox6SGpeakfuOJphAccrLH(y5Lol4dbGsbf64ZHgJrmgMbOV0zbFiaukOqhFoanyUjievPZc(qaOuqHo(CWabg5ytKdMqu6SGpeakfuOJphmfMbMyaCg)rXsnqpAT9HGsMcZatmaoJ)O40VtAgWy9Yt(eXzNKJmTRjCLU3RT)dvRPuOAnmx7VtQArGPJR1J5AjaUwzhpUwbrwg51cp89zQwjeexRSXmOwL8bOVwid5mUwp2a123sqTkgAcJxlbxRSJht(ETgqET9TeKkDwWhcaLck0XNdrgggwLHi4SInpwQb6bBJkZ9yGNmLcL(DsdB3W6zp5teNDswn8BbsuJK7idWrjfdnHXpDsRiNnHhZQeMO)ZshirnsUJmahLum0egxZNqxoY0Eg1XaLgHdwLU3RT)dvlGuRPuOALDeIAvdxRSJhpGA9yUwaRDV2(9ksQA)iUwjmuFwlbuBJGq1k74XKVxRbKxBFlbPsNf8HaqPGcD85qKHHHvzicoRyZJLAGEW2OYCpg4jtPqPbOz)EvJyBuzUhd8KPuOK6JnFiaP1kYzt4XSkHj6)S0bsuJK7idWrjfdnHX18j0LJmTNrDmqPr4kDVxRKctX12xeFmwETeqTNpwld4OHrPA7phpUwtPqVCTsiiU2bQwpMLxlYn51crW1krhRfXbcqHQLGRDGQvo5JRfWA3RneBy9CTYocrTnUwmBk51oGA9jIRfIGR1J5AbS29AL16XPsNf8HaqPGcD85qtykodj(ySCPgOhuhlez3W6zhP5ZzP1A7dbLActXziXhJLN(DsdBTITrL5EmWtMsHsS2hKJoDcBJkZ9yGNmLcLWCKnaKMs0PtyBuzUhd8KPuO0a0e2N1yGqekISGutykodj(yS8ui2W6zugcBbFiataRx4SwGvPZc(qaOuqHo(CqFmb5c5zKJhyyPgONEgESMGtnHP4mK4JXYZi5GG0bsuJK7idWrjfdnHX18bUJTpeuQHjMcnko97kDwWhcaLck0XNdWmcXa0NrDyMLAGE6z4XAco1eMIZqIpglpJKdcsdBgWy9Yt(eXzNKJmTRPwoDIbmwV83GtlWQ0zbFiaukOqhFo0eMIZ4pkwQb6PNHhRj4utykodj(yS8msoiindySE5jFI4StYrM21eUs371kHGgG(A7pAGbfF4LIAFuCTdQwcqiVwR2EmwET(aKx7acy2qSu1Ii1oGAXSjgxUu1kN87RH5ATgIi(olKxl0a4ADsTFex741AOATA)(igxETOowisLol4dbGsbf64ZHEgyqXsnqpAf5Sj8ywLmHq6EgESMGtwu7JIZbcqn(qaLol4dbGsbf64ZbuSPiYgXcLud0JwroBcpMvjtiKUNHhRj4Kf1(O4CGauJpeqPR09ET9LbmOygJkDVxRKUgOwspgxR2CjRfZyIqGQv2XJR98XA7t2uOyIxRJTXr1sW1QTVhlyeQwjaZHbneqQ0zbFiaucAadk(PXUSmdYEmNz5msQb6P9HGs4Vhlyek3H5WGgci97oDc2MeZ4X5KInfkM4jSbGrZNZs3(qqjmriYEmNBeaJs)oyv6SGpeakbnGbfF85asmboBavwnbwQb6P9HGsiXe4Sbuz1e4eMJSbGEZnSE2t(eXzNKvdlD7dbLqIjWzdOYQjWjmhzda9gSH7yGe1i5oYaCeSEb4ssuPZc(qaOe0agu8XNdyIqK9yo3iagj1a9a72hckHjcr2J5CJayucZr2aqV90VtN6z4XAcoH9wgZyIqalPHTBy9SN8jIZojRgwZZVE6u7dbLWeHi7XCUramkH5iBaO3CdRN9KprC2jz1WWQ09ETs6AGALD84A9yU2xkW1kH0vB)bYhx7vWCpUwcU2(KnfkM416yBCuQ0zbFiaucAadk(4ZHg7YYmi7XCMLZiPgOhtIz84CYcC(3LLt(4msWCpoXaRjy1PtMeZ4X5KInfkM4jgynbRkDwWhcaLGgWGIp(CqnOoZdXLUs371ED2eECPZc(qaOeYzt4Xpwu7JIP3EmgneavMZVcNe9QebNgmbNg(QwOxznmya6r0B)pQJGDwvBFuRf8HaQvmihLkD0RyqoIcp9Qyi7lCk8uzGJcp9YaRjyfvs6TNj(m9I9wU9HGq1(wTNRv6AHDTTpeusqmfRYQjWPFxTNovRwRT9HGs6XgqLJybZPFxTsxRwRT9HGs4Vhlyek3H5WGgci97Qfw0Rf8HaO3EgESMGP3EgodSiMEXElJzmriOovMZu4PxgynbROssVKo6fXo9AbFia6TNHhRjy6TNj(m9I9wU9HGq1(wTNRv6AHDTTpeusqmfRYQjWPFxTNovB7dbLWFpwWiuUdZHbneqcZr2aq1(2tTbcrOiYcsn2LLzq2J5mlNrjmhzdavlSO3aECgpg9AsmJhNtk2uOyINWgaMA18P2Z0BpdNbwetVyVLXmMieuNkt)OWtVmWAcwrLKEjD0lID61c(qa0BpdpwtW0Bpt8z6f7TC7dbHQ9TApx7Pt1c7AnjMXJZjeWGHZSCgLWgaMAFQTF1kDTyVLBFiiuTVvRwQfw0BapoJhJEnjMXJZjeWGHZSCgLyG1eSIE7z4mWIy6f7TmMXeHG6uz0qk80ldSMGvujPxsh9Ize70Rf8HaO3EgESMGP3EgodSiMEXElJzmriO3aECgpg9AsmJhNtiGbdNz5mkHnam1Q5tTNRv6ABFiOecyWWzwoJsi3cWuRMp1EUwnwB7dbLAyIPqJIt)oQtLrlu4PxgynbROssV9mXNP3ajQrYDKb4OKIHMW41Q5tTNR9yTNR9fQf216MGbEsFmb5c5zKJhy4edSMGv1kDTbcrOiYcs6JjixipJC8adNWCKnauTVvlC1cRApwB7dbLAyIPqJIt)UALUwgWy9YRvZA7JxRv6A1ATTpeucbZxiYgqLdycc1iagL(D0Rf8HaO3EgESMGP3EgodSiMETO2hfNdeGA8HaOovM(Gcp9YaRjyfvs6TNj(m9I6yHi7gwp7Outykodj(yS8AFR2Z1kDTyBuzUhd8KPuO0aQvZAp)ATNovB7dbLActXziXhJLN(D0Rf8HaO3EgESMGP3EgodSiMEBctXziXhJLNrYbbQtLrcLcp9AbFia6fMjad9YaRjyfvsQtLrIOWtVmWAcwrLKEd4Xz8y0lYzt4XSkzcb9AbFia6nycr2c(qazXGC6vmipdSiMEroBcpM6uz0Gu4PxgynbROssVwWhcGEdMqKTGpeqwmiNEfdYZalIP3GcrDQmW9kfE6LbwtWkQK0BapoJhJEdKOgj3rgGJQvZNAdD5it7zuhdu1QXAHDTTpeuQHjMcnko97Q9yTTpeuI01rW(hmU80VRwyv7lulSR1nbd8u)7pbyYkSjBIbwtWQALUwyxRwR1nbd8uKHHHvzicoRyZJtmWAcwv7Pt1gieHIilifzyyyvgIGZk284eMJSbGQvZAHRwyvlSOxl4dbqVbtiYwWhcilgKtVIb5zGfX0l0agum1PYahCu4PxgynbROssVwWhcGEdMqKTGpeqwmiNEfdYZalIP32FekQtLbUZu4PxgynbROssVb84mEm6LbmwV8KIHMW41Q5tTWPLApwldySE5jmRNb0Rf8HaOxdhmaNDcgZaN6uzGRFu4Pxl4dbqVgoyao39fiMEzG1eSIkj1PYaNgsHNETGpea9kg9Xok3F)v6JyGtVmWAcwrLK6uNE7WCGe1mNcpvg4OWtVmWAcwrLK6uzotHNEzG1eSIkj1PY0pk80ldSMGvujPovgnKcp9YaRjyfvsQtLrlu4Pxl4dbqVDeFia6LbwtWkQKuNktFqHNEzG1eSIkj9AbFia6nYWWWQmebNvS5X0BapoJhJEX2OYCpg4jtPqPbuRM1QHVsVDyoqIAMNrCGaui6vluNkJekfE6LbwtWkQK0Rf8HaOxmriYEmNBeaJO3omhirnZZioqake9EM6uzKik80ldSMGvujPxl4dbqViXe4Sbuz1ey6TdZbsuZ8mIdeGcrVNPovgnifE6LbwtWkQK0Rf8HaOxtHzGjgaNXFum92H5ajQzEgXbcqHOx4Oovg4ELcp9AbFia6f5Sj8y6LbwtWkQKuN60B7pcffEQmWrHNEzG1eSIkj9gWJZ4XO3ajQrYDKb4OKIHMW41Q5tTWv7XABFiOudtmfAuC63v7XADtWap1)(taMScBYMyG1eSQwPRT9HGsKUoc2)GXLN(D0Rf8HaO3Ub5ergftCQtL5mfE61c(qa0lAadYzCg54bgMEzG1eSIkj1Po9IC2eEmfEQmWrHNETGpea9ArTpkMEzG1eSIkj1Po9guik8uzGJcp9YaRjyfvs6nGhNXJrVTpeuQjieL4J8eMTGx7Pt16gwp7jFI4StYQHR9TNA7JxR90PABFiOKPWmWedGZ4pko97Oxl4dbqVDeFiaQtL5mfE6LbwtWkQK0Rf8HaOxXh5yYhL1tekgK7e)itptVb84mEm6T9HGsnbHOeFKNWSf8ApDQw3W6zp5teNDswnCTV9u75xR90PAdKOgj3rgGJskgAcJx7Bp1EMEbwetVIpYXKpkRNiumi3j(rMEM6uz6hfE61c(qa0BtqiQm0hlNEzG1eSIkj1PYOHu4Pxl4dbqVngJymmdqp9YaRjyfvsQtLrlu4Pxl4dbqVqdMBccrrVmWAcwrLK6uz6dk80Rf8HaOxdeyKJnroycb9YaRjyfvsQtLrcLcp9YaRjyfvs6nGhNXJrVAT22hckzkmdmXa4m(JIt)UALUwgWy9Yt(eXzNKJmTxRM1ch9AbFia61uygyIbWz8hftDQmsefE6LbwtWkQK0BapoJhJEX2OYCpg4jtPqPFxTsxlSR1nSE2t(eXzNKvdx7B1girnsUJmahLum0egV2tNQvR1IC2eEmRsyI(pxR01girnsUJmahLum0egVwnFQn0LJmTNrDmqvRgRfUAHf9AbFia6nYWWWQmebNvS5XuNkJgKcp9YaRjyfvs6nGhNXJrVyBuzUhd8KPuO0aQvZA73R1QXAX2OYCpg4jtPqj1hB(qa1kDTATwKZMWJzvct0)5ALU2ajQrYDKb4OKIHMW41Q5tTHUCKP9mQJbQA1yTWrVwWhcGEJmmmSkdrWzfBEm1PYa3Ru4PxgynbROssVb84mEm6f1Xcr2nSE2r1Q5tTNRv6A1ATTpeuQjmfNHeFmwE63vR01c7A1ATyBuzUhd8KPuOeR9b5OApDQwSnQm3JbEYukucZr2aq1QzTsuTNovl2gvM7XapzkfknGA1Swyx75A1yTbcrOiYcsnHP4mK4JXYtHydRNrziSf8HamrTWQ2xO2ZAPwyrVwWhcGEBctXziXhJLtDQmWbhfE6LbwtWkQK0BapoJhJE7z4XAco1eMIZqIpglpJKdc1kDTbsuJK7idWrjfdnHXRvZNAHR2J12(qqPgMyk0O40VJETGpea9QpMGCH8mYXdmm1PYa3zk80ldSMGvujP3aECgpg92ZWJ1eCQjmfNHeFmwEgjheQv6AHDTmGX6LN8jIZojhzAVwnRvl1E6uTmGX6Lx7B1cNwQfw0Rf8HaOxygHya6ZOomZuNkdC9Jcp9YaRjyfvs6nGhNXJrV9m8ynbNActXziXhJLNrYbHALUwgWy9Yt(eXzNKJmTxRM1ch9AbFia6TjmfNXFum1PYaNgsHNEzG1eSIkj9gWJZ4XOxTwlYzt4XSkzcrTsxBpdpwtWjlQ9rX5abOgFia61c(qa0BpdmOyQtLboTqHNEzG1eSIkj9gWJZ4XOxTwlYzt4XSkzcrTsxBpdpwtWjlQ9rX5abOgFia61c(qa0lk2uezJyHI6uNEHgWGIPWtLbok80ldSMGvujP3aECgpg92(qqj83JfmcL7WCyqdbK(D1E6uTWUwtIz84CsXMcft8e2aWuRMp1EUwPRT9HGsyIqK9yo3iagL(D1cl61c(qa0BJDzzgK9yoZYze1PYCMcp9YaRjyfvs6nGhNXJrVTpeucjMaNnGkRMaNWCKnauTVvRBy9SN8jIZojRgUwPRT9HGsiXe4Sbuz1e4eMJSbGQ9TAHDTWv7XAdKOgj3rgGJQfw1(c1cxsIOxl4dbqViXe4Sbuz1eyQtLPFu4PxgynbROssVb84mEm6f212(qqjmriYEmNBeaJsyoYgaQ23EQTF1E6uT9m8ynbNWElJzmriQfw1kDTWUw3W6zp5teNDswnCTAw75xR90PABFiOeMiezpMZncGrjmhzdav7B16gwp7jFI4StYQHRfw0Rf8HaOxmriYEmNBeaJOovgnKcp9YaRjyfvs6nGhNXJrVMeZ4X5Kf48VllN8XzKG5ECIbwtWQApDQwtIz84CsXMcft8edSMGv0Rf8HaO3g7YYmi7XCMLZiQtLrlu4Pxl4dbqVQb1zEiMEzG1eSIkj1Po1Px77Xem9ENO(M6uNsb]] )


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