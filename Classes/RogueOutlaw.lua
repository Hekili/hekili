-- RogueOutlaw.lua
-- June 2018
-- Contributed by Alkena.

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR


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
            id = 256171,
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
        keep_your_wits_about_you = {
            id = 288988,
            duration = 15,
            max_stack = 30,
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

        if stealthed.mantle and ( not a or a.startsCombat ) then
            if level < 116 and equipped.mantle_of_the_master_assassin then
                applyBuff( "master_assassins_initiative", 5 )
            end

            if talent.subterfuge.enabled then
                applyBuff( "subterfuge" )
            end

            if buff.stealth.up then
                setCooldown( "stealth", 2 )
            end
    
            removeBuff( "stealth" )
            removeBuff( "shadowmeld" )
            removeBuff( "vanish" )
        end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "combo_points" then
            if amt >= 5 then gain( 1, "combo_points" ) end

            local cdr = amt * ( buff.true_bearing.up and 2 or 1 )

            reduceCooldown( "adrenaline_rush", cdr )
            reduceCooldown( "between_the_eyes", cdr )
            reduceCooldown( "sprint", cdr )
            reduceCooldown( "grappling_hook", cdr )
            reduceCooldown( "vanish", cdr )

            reduceCooldown( "blade_rush", cdr )
            reduceCooldown( "killing_spree", cdr )
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
                energy.regen = energy.regen * 1.6
                forecastResources( 'energy' )

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
            
            debuff = "casting",
            readyTime = state.timeToInterrupt,

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

                -- Don't RtB if we've already done a simulated RtB.
                if buff.rtb_buff_1.up then return false end

                if buff.roll_the_bones.down then return true end

                -- Handle reroll checks for pre-combat.
                if time == 0 then
                    if combo_points.current < 5 then return false end

                    local reroll = rtb_buffs < 2 and ( buff.loaded_dice.up or not buff.grand_melee.up and not buff.ruthless_precision.up )
                    
                    if azerite.deadshot.enabled or azerite.ace_up_your_sleeve.enabled then
                        reroll = rtb_buffs < 2 and ( buff.loaded_dice.up or buff.ruthless_precision.remains <= cooldown.between_the_eyes.remains )
                    end

                    if azerite.snake_eyes.enabled then
                        reroll = rtb_buffs < 2 or ( azerite.snake_eyes.rank == 3 and rtb_buffs < 5 )
                    end

                    if azerite.snake_eyes.rank >= 2 and buff.snake_eyes.stack >= ( buff.broadside.up and 1 or 2 ) then return false end

                    return reroll
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
                removeStack( "snake_eyes" )
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

            usable = function () return time == 0 and not buff.stealth.up and not buff.vanish.up end,            
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


    spec:RegisterPref( {
        key = "no_ooc_reroll",
        name = "Don't Reroll the Bones Out of Combat",
        description = "If any Roll the Bones buff is applied, do not reroll out of combat until it expires.",
        type = "toggle",
        default = false,
        order = 1,
    } )

    
    spec:RegisterPack( "Outlaw", 20190216.2151, [[daLzZaqisv8iPsTjIIpPIqJsQWPKkAveb6vqrZIOQBbL0UK4xqHHrkYXurTmOkpJOsMgucUMkI2gPQ4BqjQghPOCoIkvRJuunpIkUhuzFsLCqIqTqOQEiucnrvKCrIkLnsQk9rvKs6Keb0kjLEPkcAMQiqUjuIStsHFQIunuIqoQkculLuLEQQAQerxvfPyRQiL4RQiGXQIuQZcLO0Ej8xPmyfhMQflPhlyYKCzKnRkFwfmAH60kTAOefVgk1Sr1TLQ2nWVbnCHCCIaSCuEoKPl66Q02jv(orPXtQQoprA9ebnFvO9tzXzHKIVYtsObEA6SCxt4DwFk4D(KAclGLl(P0is8J8a2(bs8bEpj(N(n5USIFKlLdDLqsXhbVSaj(XzgH0CmW4WMX3Aja7XaT9xUNleey(lXaT9bmQCyfJ6ZXQI0Hred(woHWqIyKE9vHWqI0BtVWdxQD63K7YwqBFq8R3LNsGarv8vEscnWttNL7AcVZ6tbVZNu8rruqObE6JMe)4vPiGOk(kcfe)UT50Vj3L1g9cpCjtB32eNzesZXaJdBgFRLaShd02F5EUqqG5Ved02hWOYHvmQphRkshgrm4B5ecdjIr61xfcdjsVn9cpCP2PFtUlBbT9btB32OVuLDDMuBoRpYBdEA6SMzdwTbVZAUCPz2iryjtRPTBBWIXo4aH0CtB32GvBKyLIu2Cc3a22KqBu0ZV80gpKleydFrzX02Tny1gSeuhPS5NKZZyB8xsmBKyfJaoFbKn69IITzb2eXOaSV6PnEixiWg(IYIPTBBWQnsSsrkBIyua2x90g85UISrF5xgtQnDOGecCIPnvg5yBZpjNNXDwmTDBdwT5uqWjM2CrKnjBbytjYMfydkjNNXftB32GvBofeCIPnxezt)c08tBBEqMnyjNHnPS5bz2CkYZyB6yZtezdaM2GUrrqwsQolM2UTbR2iX6GRYMlAbhSrVj(y8bNYg1LTGd2Gp3vKn6l)YysTPJlGtiKnYs2abCP2e76iBoBt6Sdu2zX02Tny1g9sCx)2CcxoFbhS5hXiQi(rm4B5K43TnN(n5US2Ox4HlzA72M4mJqAogyCyZ4BTeG9yG2(l3Zfccm)LyG2(agvoSIr95yvr6WiIbFlNqyirmsV(Qqyir6TPx4Hl1o9BYDzlOTpyA72g9LQSRZKAZz9rEBWttN1mBWQn4DwZLlnZgjclzAnTDBdwm2bhiKMBA72gSAJeRuKYMt4gW2MeAJIE(LN24HCHaB4lklM2UTbR2GLG6iLn)KCEgBJ)sIzJeRyeW5lGSrVxuSnlWMigfG9vpTXd5cb2WxuwmTDBdwTrIvkszteJcW(QN2Gp3vKn6l)YysTPdfKqGtmTPYihBB(j58mUZIPTBBWQnNccoX0MlISjzlaBkr2SaBqj58mUyA72gSAZPGGtmT5IiB6xGMFABZdYSbl5mSjLnpiZMtrEgBthBEIiBaW0g0nkcYss1zX02Tny1gjwhCv2Crl4Gn6nXhJp4u2OUSfCWg85UISrF5xgtQnDCbCcHSrwYgiGl1MyxhzZzBsNDGYolM2UTbR2OxI763Mt4Y5l4Gn)igrftRPTBBKB6Nc3Ku2uPhKr2eG9vpTPshwaQyJehcuuISbabyn2z9Vl3gpKleGSbc4slMwpKleGkrmka7REI7XDe2MwpKleGkrmka7REIjom87HEcKEUqGP1d5cbOseJcW(QNyIdJheQmTDBZh4rOyyAdZxLn177rkBqPNiBQ0dYiBcW(QN2uPdlazJdu2eXiSgbZCbhSzr2OGaQyA9qUqaQeXOaSV6jM4Wab8iummBO0tKP1d5cbOseJcW(QNyIdJiyUqGP1d5cbOseJcW(QNyIdJENHnPApiRPipJLpIrbyF1ZgIcqGcH7KYVpCmFvnshbYIRuOYc6clOjtRhYfcqLigfG9vpXehgUIraNVaQXUOy5Jyua2x9SHOaeOq4oBA9qUqaQeXOaSV6jM4WaLKZZytRhYfcqLigfG9vpXehgmiN3YyQvHacjFeJcW(QNnefGafchEMwpKleGkrmka7REIjomq8nqnhOAQnqYhXOaSV6zdrbiqHWHNP1d5cbOseJcW(QNyIdJk3vu7XVmMu53hU699kmiN3YyQvHacvUrY4HC1rncq9lH66SP102TnYn9tHBskBiDetQn52t2KXKnEiHmBwKnUoF5ELtftB32OxcLKZZyB2NnrqeARCYMoaqB0D5aI5vozdbO(Lq2SaBcW(QNDAA9qUqachkjNNXMwpKleGWehgyVbSnTDBJEjgKZT5bz2GhM2uVVhYgz3m2MtqqxrkBo1giBUrfBo9mMyYUiYggXGCUnpiZg8W0giZMtRmhOSblrCISbYSrV3mMtiKnseJclAHGIP1d5cbimXHHoNTELtYd8EchlRngXGCU86C(LWXYAREFpKCWtMoQ33RWHUIun1gOYn64r9uVVx5aZbQwpXjQCJKrp177vy3mMtiulIrHfTqq5g1PPTBB0lXGCUnpiZg8W0M699q2az2O3BgZjeYgjIrHfTqGnYUzSnNICfkgM2az2iXbYMBKnsHxMnFor6OIP1d5cbimXHHoNTELtYd8EchlRngXGCU8WiCikLFF4CjKyBsff5kummleWRCsD8OlHeBtQ4bQDJAsHxwdXjshviGx5KsEDo)s4yzTvVVhso4jth177v4qxrQMAdu5gD8y9(Ef2nJ5ec1IyuyrleuyuVVaKCWfGqUcklOuPuwIaTmMAKucvyuVVauNM2UTbpmT5dCSjBKBsjKMBJeZL1LISHrmiNBZdYSbpmTPEFpuX06HCHaeM4WqNZwVYj5bEpHJL1gJyqoxEyeoeLYVpCUesSnPcc4ytnskHkmhGDx4WtEDo)s4yzTvVVhso4zA72g8W0MpWXMSrUjLqAUnNcAdaM2WigKZTr2nJTbpmTbLEaBKnWNnzmzZh4yt2i3KsiBQ33ZMooJPnO0dyBJSBgBd(mORqRIS5g1zX06HCHaeM4WqNZwVYj5bEpHJL1gJyqoxEyeogHOu(9HZLqITjvqahBQrsjuH5aS7chEYuVVxbbCSPgjLqfu6bS7chEyTEFVsLbDfAvu5gzA9qUqactCyOZzRx5K8aVNW591lkUfGa1MleiVoNFjCbyFf2IGlirff92WMDHdpmXtc2r6CcKLdXquYL2qjBXMkeWRCsjtac5kOSGYHyik5sBOKTytfg17lajNZDIz9(ELkd6k0QOYnsgcqSds7sF0Km6PEFVcc7lN3CGQfyqeQcbeQCJmTDBZjWMX20F55gXjBsNDGsK82KXlYgDoB9kNSzr2eIPa2KYMeAJIcRISr2ykJjMniypzdw8uiBqXWlxztLSbjfeiLnYUzSn4ZDfzJ(YVmMutRhYfcqyIddDoB9kNKh49eUk3vu7XVmM0gskiiVoNFjCOiIZBPZoqjQu5UIAp(LXKkh8KH5RQr6iqwCLcvwqx4PPJhR33Ru5UIAp(LXKwUrMwpKleGWehgbNZBEixiOXxukpW7jCOKCEgl)(WHsY5zmPkoNBA9qUqactCyeCoV5HCHGgFrP8aVNWfuitB32OVlyrX24Pn9U(3(BVnyrjQyZ)wrjZdPnqazZdYSH8qSn4ZGUcTkYghOS50JIGS8c2uQnYgtaBobF3a22CkMlRnlYgeXPqskBCGYgS07u2SiBaW0gg5kP24VKy2KXKnas)PnikabQIP1d5cbimXHrW58MhYfcA8fLYd8Ec3Bblkw(9Hla7RWweCbjQlCHOwVR)gkIakS2r9(ELkd6k0QOYncZ699kWOiilVGnLwUrDkb7iDobYIeWDdy3umx2cb8kNuY0HEsNtGS07mSjv7bznf5zCHaELtQJhdqixbLfu6Dg2KQ9GSMI8mUWOEFbOUo3zNMwpKleGWehgbNZBEixiOXxukpW7jC17YvMwpKleGWehgol4aQLqgJaP87dhbi2bPff92WMDH78jXKae7G0cJoqatRhYfcqyIddNfCa1IUCezA9qUqactCyW3dXjQHL5Qo0tG00AA72g8VlxrmKPTBBoniYgjArjKBZpgM2SpB20gzHGtmTj4r2eG9vOnrWfKiBCGYMmMS50JIG5fSPuBQ33ZMfzZnQyJeRdUkBUOfCWgzJjGnNqIISbll8YS5eytKnO0dyJSXzKnX7HyBUaoHq2KXKnNICfkgM2uVVNnlYgNJG2CJkMwpKleGk17Yv4Iwuc5nummLFF4cW(kSfbxqIkk6THn7c3zmR33RuzqxHwfvUryMoNazrc4UbSBkMlBHaELtkzQ33RaJIGS8c2uA5gjth177vWMOOMu4L1KDtuZRWB2KcVfu6bSLdEN84X699kkYvOyywUrDAA9qUqaQuVlxHjomqlyrjXAOKTytMwtB32GfHqUcklazA9qUqaQeuiCrWCHa53hU699kvoeQ4xuwyKhYJhR33R4kgbC(cOg7IIl3itB32OVoNVGd2u9a22KqBu0ZV80MnPEBUi)azA9qUqaQeuimXHXfrTnPE5bEpHtNZwVYP2cscG2uA7WEW1b5zdIclN75co0yKhsit(9HREFVsLdHk(fLfg5H84XC7PwcBQLKdo800XJbyFf2IGlirff92WMYbhEMwpKleGkbfctCyCruBtQhj)(WPhusopJjvX5Cz6OEFVsLdHk(fLfg5H84XaSVcBrWfKOIIEByt5GdVonTEixiavckeM4WOYHqv7DzsnTEixiavckeM4WOsmeXWEbhmTEixiavckeM4W4TmQYHqLP1d5cbOsqHWehgoiqOK58wW5CtRhYfcqLGcHjomCfJaoFbuJDrXYVpC6PEFVIRyeW5lGASlkUCJKHae7G0sU9ulHTEx)DD202TnsGpBCLczJZiBUrYBdcSrKnzmzdeq2i7MX2WHYsO0gjL8ufBoniYgzJjGnkPl4GnphLeZMm2b2GfLiBu0BdBAdKzJSBgdVPnoqQnyrjQyA9qUqaQeuimXHrVZWMuThK1uKNXYVpCmFvnshbYIRuOYnsMosNDGYsU9ulHn1sYja7RWweCbjQOO3g284r9GsY5zmPkm4Hljta2xHTi4csurrVnSzx4crTEx)nuebuy9CNM2UTrc8zdaAJRuiBKD5CBulzJSBgVaBYyYgaP)0g5sti5T5IiBWsVtzdeytfIq2i7MXWBAJdKAdwuIkMwpKleGkbfctCy07mSjv7bznf5zS87dhZxvJ0rGS4kfQSGUKlnHvMVQgPJazXvkurDzEUqGm6bLKZZysvyWdxsMaSVcBrWfKOIIEByZUWfIA9U(BOicOW6ztB32Gp3vKn6l)YysTbcSbpmTHau)sOInNaBgBJRuin3MtdISzF2KXKuBqPl1MhKzJMHPnikabkKnqMn7ZgPWlZgaP)0MqSZoq2i7Y52ujByKRKAZcSj3EYMhKztgt2ai9N2iRRJkMwpKleGkbfctCyu5UIAp(LXKk)(WHIioVLo7aLOUWHNm6PEFVsL7kQ94xgtA5gjth177vyqoVLXuRcbeQCJoESEFVcIVbQ5avtTbQCJ6uMo0dZxvJ0rGS4kfQq6Frj64rMVQgPJazXvkuHr9(cqDPzhpY8v1iDeilUsHklORoWdRbiKRGYckvURO2JFzmPLqSZoqO2J5HCHaN3PeeVt2PP1d5cbOsqHWehghIHOKlTHs2Inj)(WPZzRx5uPYDf1E8lJjTHKccYeG9vylcUGevu0BdB2fUZywVVxPYGUcTkQCJmTEixiavckeM4Wa7LZxWHgkIrK87dNoNTELtLk3vu7XVmM0gskiitheGyhKwYTNAjS176Vl8oEKae7Gu5Csn1PP1d5cbOsqHWehgvUROg7IILFF405S1RCQu5UIAp(LXK2qsbbziaXoiTKBp1syR31FxNnTDBZPbTGd2CAXblkgdjUVErX2SiBGaUuBCB0rmP2KlqQnliWihrYBdcAZcSHroFtPYBJu49ezKnEfb53K4sT5TaYMeAZfr2SPnoYg3MBU8nLAdkI48IP1d5cbOsqHWehg6CWIILFF40dkjNNXKQ4CUm6C26vov8(6ff3cqGAZfcmTEixiavckeM4Waf7kOS9exj)(WPhusopJjvX5Cz05S1RCQ491lkUfGa1MleyAnTDBJ(UGfftmKPTBBWpLB2a1rmB0BIVnmIb5CKnYUzSnNICfkgMyiXbYMK5BISbYSrV3mMtiKnseJclAHGIP1d5cbOYBblkgxLszjc0YyQrsjK87dx9(Ef2nJ5ec1IyuyrleuUrhp2HlHeBtQOixHIHzHaELtQJhDjKyBsfpqTButk8YAior6Ocb8kNuDkt9(EfgKZBzm1QqaHk3itRhYfcqL3cwumM4WaX3a1CGQP2aj)(W1HhYvh1ia1Vec35JhR33Ru5UIAp(LXKwuqzbDkth177vq8nqnhOAQnqfg17lajN0zhOSKBp1sytTKm177vq8nqnhOAQnqfg17lajNooJza2xHTi4csuNsWZfnRttRhYfcqL3cwumM4WGb58wgtTkeqi53hUo8qU6OgbO(Lq4oF8y9(ELk3vu7XVmM0IcklOtz6OEFVcdY5TmMAviGqfg17lajhCY1XJ6C26vovyzTXigKZ7002Tn4NYnBKDZyBYyYgjoq2CAISbll8YS5ZjshzdKzZPixHIHPnjZ3evmTEixiavElyrXyIdJkLYseOLXuJKsi53hoxcj2MuXdu7g1KcVSgItKoQqaVYj1XJUesSnPIICfkgMfc4voPmTEixiavElyrXyIdd1II8meBAnTDBZpjNNXMwpKleGkOKCEgJZ7RxuS4RJyOfceAGNMol310znDUC(SCDsXxwNbwWbK4lb2hbzjPSrFSXd5cb2WxuIkMwXNVOejKu8v0ZV8uiPqJZcjfFpKlei(OKCEgl(eWRCsjWxKcnWtiP47HCHaXh7nGT4taVYjLaFrk0qUesk(eWRCsjWx8158lj(SS2Q33dzJCSbpBKXMoSPEFVch6ks1uBGk3iBoE0g9yt9(ELdmhOA9eNOYnYgzSrp2uVVxHDZyoHqTigfw0cbLBKnDk(Eixiq815S1RCs815SgW7jXNL1gJyqoxKcnWccjfFc4voPe4l(WiXhrP47HCHaXxNZwVYjXxNZVK4ZYAREFpKnYXg8SrgB6WM699kCORivtTbQCJS54rBQ33RWUzmNqOweJclAHGcJ69fGSro4SjaHCfuwqPsPSebAzm1iPeQWOEFbiB6u8dSnj26IVlHeBtQOixHIHzHaELtkBoE0gxcj2MuXdu7g1KcVSgItKoQqaVYjL4RZznG3tIplRngXGCUifACsHKIpb8kNuc8fFyK4JOu89qUqG4RZzRx5K4RZ5xs8zzTvVVhYg5ydEIFGTjXwx8DjKyBsfeWXMAKucvyoaBB6cNn4j(6Cwd49K4ZYAJrmiNlsHg6JqsXNaELtkb(Ipms8zeIsX3d5cbIVoNTELtIVoN1aEpj(SS2yedY5IFGTjXwx8DjKyBsfeWXMAKucvyoaBB6cNn4zJm2uVVxbbCSPgjLqfu6bSTPlC2GNny1M699kvg0vOvrLBKifAGLlKu8jGx5KsGV4RZ5xs8dW(kSfbxqIkk6THnTPlC2GNnyAdE2ibTPdBsNtGSCigIsU0gkzl2uHaELtkBKXMaeYvqzbLdXquYL2qjBXMkmQ3xaYg5yZzB60gmTPEFVsLbDfAvu5gzJm2qaIDqQnDzJ(OjBKXg9yt9(Efe2xoV5avlWGiufciu5gj(Eixiq815S1RCs815SgW7jX37RxuClabQnxiqKcn0mHKIpb8kNuc8fFDo)sIpkI48w6SduIkvURO2JFzmP2ihBWZgzSH5RQr6iqwCLcvwGnDzdEAYMJhTPEFVsL7kQ94xgtA5gj(Eixiq815S1RCs815SgW7jXVYDf1E8lJjTHKccIuOHCxiP4taVYjLaFXpW2KyRl(OKCEgtQIZ5IVhYfce)GZ5npKle04lkfF(IYgW7jXhLKZZyrk04SMesk(eWRCsjWx89qUqG4hCoV5HCHGgFrP4Zxu2aEpj(bfsKcnoFwiP4taVYjLaFXpW2KyRl(byFf2IGlir20foBcrTEx)nuebu2GvB6WM699kvg0vOvrLBKnyAt9(EfyueKLxWMsl3iB60gjOnDyt6CcKfjG7gWUPyUSfc4voPSrgB6Wg9yt6CcKLENHnPApiRPipJleWRCszZXJ2eGqUcklO07mSjv7bznf5zCHr9(cq20LnNTPtB6u89qUqG4hCoV5HCHGgFrP4Zxu2aEpj(VfSOyrk04mEcjfFc4voPe4l(Eixiq8doN38qUqqJVOu85lkBaVNe)6D5krk04SCjKu8jGx5KsGV4hyBsS1fFcqSdslk6THnTPlC2C(K2GPneGyhKwy0bci(Eixiq8DwWbulHmgbsrk04mwqiP47HCHaX3zbhqTOlhrIpb8kNuc8fPqJZNuiP47HCHaXNVhItudlZvDONaP4taVYjLaFrksXpIrbyF1tHKcnolKu8jGx5KsGVifAGNqsXNaELtkb(IuOHCjKu8jGx5KsGVifAGfesk(eWRCsjWxKcnoPqsX3d5cbIFemxiq8jGx5KsGVifAOpcjfFc4voPe4l(Eixiq87Dg2KQ9GSMI8mw8dSnj26IpZxvJ0rGS4kfQSaB6YgSGMe)igfG9vpBikabkK4Fsrk0alxiP4taVYjLaFX3d5cbIVRyeW5lGASlkw8Jyua2x9SHOaeOqI)zrk0qZesk(Eixiq8rj58mw8jGx5KsGVifAi3fsk(eWRCsjWx89qUqG4ZGCElJPwfciK4hXOaSV6zdrbiqHeF8ePqJZAsiP4taVYjLaFX3d5cbIpIVbQ5avtTbs8Jyua2x9SHOaeOqIpEIuOX5ZcjfFc4voPe4l(b2MeBDXVEFVcdY5TmMAviGqLBKnYyJhYvh1ia1VeYMUS5S47HCHaXVYDf1E8lJjvKIu8R3LResk04SqsXNaELtkb(IFGTjXwx8dW(kSfbxqIkk6THnTPlC2C2gmTPEFVsLbDfAvu5gzdM2KoNazrc4UbSBkMlBHaELtkBKXM699kWOiilVGnLwUr2iJnDyt9(EfSjkQjfEznz3e18k8MnPWBbLEaBBKJn4DsBoE0M699kkYvOyywUr20P47HCHaXpArjK3qXWuKcnWtiP47HCHaXhTGfLeRHs2Inj(eWRCsjWxKIu8rj58mwiPqJZcjfFpKlei(EF9IIfFc4voPe4lsrk(bfsiPqJZcjfFc4voPe4l(b2MeBDXVEFVsLdHk(fLfg5H0MJhTPEFVIRyeW5lGASlkUCJeFpKlei(rWCHark0apHKIpb8kNuc8fFpKlei(6C26vo1wqsa0MsBh2dUoipBquy5CpxWHgJ8qczIFGTjXwx8R33Ru5qOIFrzHrEiT54rBYTNAjSPwYg5GZg80KnhpAta2xHTi4csurrVnSPnYbNn4j(aVNeFDoB9kNAlijaAtPTd7bxhKNnikSCUNl4qJrEiHmrk0qUesk(eWRCsjWx8dSnj26IVESbLKZZysvCo3gzSPdBQ33Ru5qOIFrzHrEiT54rBcW(kSfbxqIkk6THnTro4SbpB6u89qUqG4FruBtQhjsHgybHKIVhYfce)khcvT3Ljv8jGx5KsGVifACsHKIVhYfce)kXqed7fCq8jGx5KsGVifAOpcjfFpKlei(VLrvoeQeFc4voPe4lsHgy5cjfFpKlei(oiqOK58wW5CXNaELtkb(IuOHMjKu8jGx5KsGV4hyBsS1fF9yt9(EfxXiGZxa1yxuC5gzJm2qaIDqAj3EQLWwVRFB6YMZIVhYfceFxXiGZxa1yxuSifAi3fsk(eWRCsjWx8dSnj26IpZxvJ0rGS4kfQCJSrgB6WM0zhOSKBp1sytTKnYXMaSVcBrWfKOIIEBytBoE0g9ydkjNNXKQWGhUKnYyta2xHTi4csurrVnSPnDHZMquR31FdfraLny1MZ20P47HCHaXV3zytQ2dYAkYZyrk04SMesk(eWRCsjWx8dSnj26IpZxvJ0rGS4kfQSaB6Yg5st2GvBy(QAKocKfxPqf1L55cb2iJn6XgusopJjvHbpCjBKXMaSVcBrWfKOIIEBytB6cNnHOwVR)gkIakBWQnNfFpKlei(9odBs1EqwtrEglsHgNplKu8jGx5KsGV4hyBsS1fFueX5T0zhOeztx4SbpBKXg9yt9(ELk3vu7XVmM0YnYgzSPdBQ33RWGCElJPwfciu5gzZXJ2uVVxbX3a1CGQP2avUr20PnYyth2OhBy(QAKocKfxPqfs)lkr2C8OnmFvnshbYIRuOcJ69fGSPlB0mBoE0gMVQgPJazXvkuzb20LnDydE2GvBcqixbLfuQCxrTh)YyslHyNDGqThZd5cbo3MoTrcAdEN0MofFpKlei(vURO2JFzmPIuOXz8esk(eWRCsjWx8dSnj26IVoNTELtLk3vu7XVmM0gskiyJm2eG9vylcUGevu0BdBAtx4S5SnyAt9(ELkd6k0QOYns89qUqG4FigIsU0gkzl2KifACwUesk(eWRCsjWx8dSnj26IVoNTELtLk3vu7XVmM0gskiyJm20HneGyhKwYTNAjS1763MUSbpBoE0gcqSdsTro2CsnztNIVhYfceFSxoFbhAOigrIuOXzSGqsXNaELtkb(IFGTjXwx815S1RCQu5UIAp(LXK2qsbbBKXgcqSdsl52tTe26D9Btx2Cw89qUqG4x5UIASlkwKcnoFsHKIpb8kNuc8f)aBtITU4RhBqj58mMufNZTrgB05S1RCQ491lkUfGa1Mlei(Eixiq815GfflsHgN1hHKIpb8kNuc8f)aBtITU4RhBqj58mMufNZTrgB05S1RCQ491lkUfGa1Mlei(Eixiq8rXUckBpXvIuKI)BblkwiPqJZcjfFc4voPe4l(b2MeBDXVEFVc7MXCcHArmkSOfck3iBoE0MoSXLqITjvuKRqXWSqaVYjLnhpAJlHeBtQ4bQDJAsHxwdXjshviGx5KYMoTrgBQ33RWGCElJPwfciu5gj(Eixiq8RuklrGwgtnskHePqd8esk(eWRCsjWx8dSnj26IFh24HC1rncq9lHSbNnNT54rBQ33Ru5UIAp(LXKwuqzb20PnYyth2uVVxbX3a1CGQP2avyuVVaKnYXM0zhOSKBp1sytTKnYyt9(EfeFduZbQMAduHr9(cq2ihB6WMZ2GPnbyFf2IGlir20PnsqBox0mB6u89qUqG4J4BGAoq1uBGePqd5siP4taVYjLaFXpW2KyRl(DyJhYvh1ia1VeYgC2C2MJhTPEFVsL7kQ94xgtArbLfytN2iJnDyt9(EfgKZBzm1QqaHkmQ3xaYg5GZg5YMJhTrNZwVYPclRngXGCUnDk(Eixiq8zqoVLXuRcbesKcnWccjfFc4voPe4l(b2MeBDX3LqITjv8a1UrnPWlRH4ePJkeWRCszZXJ24siX2KkkYvOyywiGx5Ks89qUqG4xPuwIaTmMAKucjsHgNuiP47HCHaXxTOipdXIpb8kNuc8fPifP473mgYe))2JffPifca]] )
    

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "battle_potion_of_agility",
        
        package = "Outlaw",
    } )

end