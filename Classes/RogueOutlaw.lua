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
        if amt >= 5 and resource == "combo_points" then
            gain( 1, "combo_points" )

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

    
    spec:RegisterPack( "Outlaw", 20180930.2141, [[d8KRUaqibupsfXMiQ8jIQeJsvrNsvHvPIu9kvuZIi5wev1Ue1VuHgMQsDmiXYGKEMuvAAevX1KQkBteIVruL04iIY5eqY6iIO5PQK7PQAFIGdkGyHeHhQIetuesxKOk1gjIuFKisQtQIuALc0ljIKmtvKeUPasTtIu)KicdLiQoQksIwQuv8uvAQqQUQksXwvrsYxvrs5SQij1Er6VcnyLomLflLhtQjtYLrTzi(SiA0sLtRy1QiP61qkZMWTf0Ub(nIHlshNisSCqphQPt11vLTlv57cW4fH68eL1lvvnFvW(Lmffk60RYCMknQFJIK9DGQVFNrff5b1(Ic96Ysz6n10Ozjz6fyHm9kjEUWcGEtnzcIPOOtVyYdQz6TZ9uSK84XKJ39Aznj8iEcFcZhcqdne)iEc1hBcs7ydXKVI7DmfsqgbJpk5qUp2OWhL8(e7dj5JJsINlSaY4jutVT3i8tlG2OxL5mvAu)gfj77avF)oJkkYdQOMi0loL1uPrnr(ME7gLIb0g9QySMEpPwjXZfwa12hsYhxbpP2o3tXsYJhtoE3RL1KWJ4j8jmFian0q8J4juFSjiTJnet(kU3Xuibzem(OKd5(yJcFuY7tSpKKpokjEUWciJNqDf8KAVCQZHngwBF)wQAr9BuKSALFTOIIKuE6xfScEsTNsNbsYyjzf8KALFTbIsXQALunA0Q1j1Qye7j8AnTpeqTIb75k4j1k)Ad0KESQ2RZMW7Q1qCgwBGOGmWedGRTppCxTdO2uiRjHnZR10(qa1kgSNRGNuR8RnqukwvBkK1KWM51kHWuCTsAXdcLv7NkcJbYlETniBOv71zt4DFKP3uibzem9EsTsINlSaQTpKKpUcEsTDUNILKhpMC8UxlRjHhXt4ty(qaAOH4hXtO(ytqAhBiM8vCVJPqcYiy8rjhY9Xgf(OK3NyFijFCus8CHfqgpH6k4j1E5uNdBmS2((Tu1I63Oiz1k)ArffjP80Vkyf8KApLodKKXsYk4j1k)AdeLIv1kPA0OvRtQvXi2t41AAFiGAfd2ZvWtQv(1gOj9yvTxNnH3vRH4mS2arbzGjgaxBFE4UAhqTPqwtcBMxRP9HaQvmypxbpPw5xBGOuSQ2uiRjHnZRvcHP4AL0IhekR2pvegdKx8ABq2qR2RZMW7(ixbRGNuR8oXS(5SQ2gJqGCTAsyZ8ABCYbGZ1giAnN64AbeG87myiYtuRP9HaW1sacz5kOP9HaW5uiRjHnZ)reggTkOP9HaW5uiRjHnZp)F0EjdzGB(qavqt7dbGZPqwtcBMF()icHOQGNu7fyP4oIxl0gvTThccRQf7MJRTXieixRMe2mV2gNCa4AnGQ2uil)uI7dizTdUwfbW5kOP9HaW5uiRjHnZp)FedSuChXJy3CCf00(qa4CkK1KWM5N)pMs8HaQGM2hcaNtHSMe2m)8)XqdIgRIieyuXM3jvkK1KWM5rmRjaf(VFsni)qBurUhd8SPu48asqE(UcAAFiaCofYAsyZ8Z)hHeHi6DCSramwQuiRjHnZJywtak8pQvqt7dbGZPqwtcBMF()iwmAoAavunAwQuiRjHnZJywtak8pQvqt7dbGZPqwtcBMF()OPGmWedGJWhUtQuiRjHnZJywtak8pkvqt7dbGZPqwtcBMF()i2zt4Dvqt7dbGZPqwtcBMF()ytykoIiEqOmPgKFt7tpoYaoCyCcOubRGNuR8oXS(5SQwUhdLvRpHCTEhxRPDcS2bxR1ZgH1eCUcAAFia8pAJgTk4j12hgseIAriWAr9CTThccU2agVR2tfetXQAt0rZ1(sZ1kj8oggWG5AHmKie1IqG1I65AjWALudnGQ2anlyUwcS2(88obJX1k5qwp4HaYvqt7dbGp)FSNbhRjyPawi)d9weYqIqivpt84FO3IThcc(luL7Z2dbjliMIvr1O58l9WHa3Eii5KqdOIHSG58lvUa3Eiiz4Z7emghtHSEWdbKFPFubpP2(WqIqulcbwlQNRT9qqW1sG12NN3jymUwjhY6bpeqTbmExTjkBkChXRLaRnq0CTV0ALrEWAVcM7X5kOP9HaWN)p2ZGJ1eSualK)HElcziriKIK(JzxQb536pdhNZk2u4oINzG1eS6WbR)mCCoBAo(sJYipyelyUhNzG1eSsQEM4X)qVfBpee8xOk3NThcswqmfRIQrZ5x6HdThcsg(8obJXXuiRh8qazihAda)1VMqeksaGCJ9ayge9ooYYyCgYH2aWFubpP2areGjdxlKHeHOwecSwupxB7HGGRnGX7Q9cm04AL3YyCTpGGX4AnV2(wBFmaAyPQ17yqTqgseIA5EmuM3nGK5kOP9HaWN)p2ZGJ1eSualK)HElcziriKIK(JzxQb536pdhNZyGHghzzmoZaRjyLu9mXJ)HEl2Eii4Vq9WHpT(ZWX5mgyOXrwgJZqdG2FFLd6Ty7HGG)QFFubpP2eLulG41cziriQDqQ9cm04AL3YyCTdUwZRf1Z12hdGgUwdOQf1Z1IDtJgUwcsTEhxB7HGu7NOCUwSBA0QnGX7QvciXu4rX1(s)OcAAFia85)J9m4ynblfWc5FO3IqgsecPiP)qgZUudYV1FgooNXadnoYYyCgAa0s4hv5ApeKmgyOXrwgJZy30OLWpQYV9qqYniXu4rX5xAf00(qa4Z)h7zWXAcwkGfY)wy7H7IAcqn(qas1Zep(xtcBKykzaooRyKrpEc)OEg1t)t3emWZj7iyxilID4GgNzG1eSsonHiuKaa5KDeSlKfXoCqJZqo0ga(lu(4C7HGKBqIPWJIZVu5yadtklHe5B5cC7HGKXO9eIOburnKGXncGX5xAf8KAp1gVR2WNWNubxRBWKSJLQwVBW12ZGJ1eCTdUwDhRrJv16KAvSEuCTb0XEhdRftc5ApLefxlUJ8eQABCTyzanRQnGX7QvcHP4AL0IhekRcAAFia85)J9m4ynblfWc5)MWuCer8GqzrSmGwQEM4X)4uwiIUbtYoo3eMIJiIhek7luLdAJkY9yGNnLcNhqcO(9HdThcsUjmfhrepiuw(LwbnTpea(8)rTjert7dbefd2LcyH8p2zt4Dsni)yNnH3XQSjevqt7dbGp)FuBcr00(qarXGDPawi)Rv4k4j1kPhWG7Q18AdTepHVWApfjpx791Wo00ETeaxlcbwlB6UALasmfEuCTgqvRKinLa9hyCz1gqhdQ9u5B0OvBIcTaQDW1IzbRDwvRbu1gOrs0AhCTaIxlKnLSAneNH16DCTaoXETywtaQCf00(qa4Z)h1MqenTpequmyxkGfY)idyWDsni)AsyJetjdWXj8RtJHwIJ4ugOK)NThcsUbjMcpko)sp3EiizsAkb6pW4YYV0po9pDtWaplP8gnArf0ciZaRjyLCFgy3emWZHgenwfriWOInVlZaRjy1HdAcrOibaYHgenwfriWOInVld5qBa4eq5JpQGM2hcaF()O2eIOP9HaIIb7sbSq(V9gHQcAAFia85)JguBao6eiKbUudYpdyyszzfJm6Xt4hL(DMbmmPSmKtYGkOP9HaWN)pAqTb4y6tG5kOP9HaWN)pkMKDooEQ)ujdzGxbRGNuReVrOyiUcAAFiaCU9gH6pDWoreXDexQb5xtcBKykzaooRyKrpEc)OCU9qqYniXu4rX5x6z3emWZskVrJwubTaYmWAcwjx7HGKjPPeO)aJll)sRGM2hcaNBVrOo)FepGb7mmID4GgxbRGNu7PqicfjaaUcAAFiaCwRW)PeFiaPgK)2dbj3eeIs8WEgYM2pCWnys2Z(eYrNevd)1FI89HdThcs2uqgyIbWr4d3LFPvWtQvsBcXaswBZ0OvRtQvXi2t41oohw7dBj5kOP9HaWzTcF()4dZXX5qPawi)lEyhsE4ysIqXGyQ4fAjzPgK)2dbj3eeIs8WEgYM2pCWnys2Z(eYrNevd)1pQFF4GMe2iXuYaCCwXiJE8V(rTcAAFiaCwRWN)p2eeIkI8GYQGM2hcaN1k85)JngIziAdizf00(qa4SwHp)FezGCtqiQkOP9HaWzTcF()Ob0m2HMiQnHOcAAFiaCwRWN)pAkidmXa4i8H7KAq(dC7HGKnfKbMyaCe(WD5xQCmGHjLL9jKJojgAjobuQGNu7PfPwtPW1AqU2xQu1IbtkxR3X1saCTbmExTcsam2RfD0t0CTNgmxBaDmOwLSbKSwed7mSwVZa1EksETkgz0JxlbwBaJ3rEETgqwTNIKNRGM2hcaN1k85)JHgenwfriWOInVtQb5hAJkY9yGNnLcNFPY9PBWKSN9jKJojQg(lnjSrIPKb44SIrg94hoeySZMW7yvgss(y50KWgjMsgGJZkgz0JNWVongAjoItzGs(O8rf8KApTi1ci1AkfU2agHOw1W1gW4DdOwVJRfWj2RTVFJLQ2hMRnqJKO1sa12iyCTbmEh551Aaz1EksEUcAAFiaCwRWN)pgAq0yveHaJk28oPgKFOnQi3JbE2ukCEaj03VLp0gvK7XapBkfoREqZhcqUaJD2eEhRYqsYhlNMe2iXuYaCCwXiJE8e(1PXqlXrCkduYhLk4j1kHWuCTsAXdcLvlbulQNRLbC4W4CTNAJ3vRPuyjzTNgmx7GuR3XYQf7MSAriWALSZ1IznbOW1sG1oi1kJ8G1c4e71Q7mysU2agHO2gxlKnLSAhqT(eY1IqG16DCTaoXETby94Cf00(qa4SwHp)FSjmfhrepiuMudYpoLfIOBWKSJt4hv5cC7HGKBctXreXdcLLFPY9zGH2OICpg4ztPWzoXd2XhoaTrf5EmWZMsHZqo0gaobj7WbOnQi3JbE2ukCEaj8jQYxticfjaqUjmfhrepiuww3zWKmoIanTpeGj(40rTFFubnTpeaoRv4Z)ht2rWUqwe7WbnwQb5VNbhRj4CtykoIiEqOSiwgqlNMe2iXuYaCCwXiJE8e(r5C7HGKBqIPWJIZV0kOP9HaWzTcF()iAJqmGKrCkKzPgK)EgCSMGZnHP4iI4bHYIyzaTCFYagMuw2Nqo6KyOL4e63HdmGHjL9fk97JkOP9HaWzTcF()ytykocF4oPgK)EgCSMGZnHP4iI4bHYIyzaTCmGHjLL9jKJojgAjobuQGNu7PbpGK1EQYadU7yGe2E4UAhCTeGqwTwT9yOSA9biR2bOHSHzPQftQDa1cztmUmPQvg5jVa5ATgMiEolKvlYa4ADsTpmx741A4ATAF(igxwT4uwiYvqt7dbGZAf(8)XEgyWDsni)bg7Sj8owLnHqUEgCSMGZwy7H7IAcqn(qavqt7dbGZAf(8)rCNPibeYcLudYFGXoBcVJvztiKRNbhRj4Sf2E4UOMauJpeqfScEsTs6bm4ogIRGNuReU8UwspgwBFCjQfYqIqGRnGX7QnrztH7i(XarZ16qBCCTeyT955DcgJRvYHSEWdbKRGM2hcaNrgWG7(BShaZGO3XrwgJLAq(BpeKm85DcgJJPqwp4HaYV0dh(06pdhNZk2u4oINzG1eS6WbR)mCCoBAo(sJYipyelyUhNzG1eS6d5ApeKmKierVJJncGX5xAf00(qa4mYagC35)JyXO5Obur1OzPgK)2dbjJfJMJgqfvJMZqo0ga(l3Gjzp7tihDsunSCThcsglgnhnGkQgnNHCOna8xFIYznjSrIPKb44poDuYswf00(qa4mYagC35)JqIqe9oo2iagl1G8)z7HGKHeHi6DCSramod5qBa4V(77Hd9m4ynbNHElcziri(qUpDdMK9SpHC0jr1WjG63ho0EiiziriIEhhBeaJZqo0ga(l3Gjzp7tihDsun8hvWtQvcxExBaJ3vR3X1giAU2ttATNQjpyTxbZ94AjWAtu2u4oIxRdTXX5kOP9HaWzKbm4UZ)hBShaZGO3XrwgJLAq(T(ZWX5SP54lnkJ8GrSG5ECMbwtWQdhS(ZWX5SInfUJ4zgynbRQGM2hcaNrgWG7o)Fun4uZ1DvWk4j1ED2eExf00(qa4m2zt4D)wy7H7O3EmepeavAu)gfj77a13OMrff5jrO3amiyajX07PnmLaDwvBIuRP9HaQvmyhNRG0RyWoMIo9Qye7jCk6uPrHIo9AAFia6fTrJg9YaRjyfvcQtLgvk60ldSMGvujO3EM4X0l0BX2dbbx7x1IATYv7N12EiizbXuSkQgnNFP1E4qTbU22dbjNeAavmKfmNFP1kxTbU22dbjdFENGX4ykK1dEiG8lT2pOxt7dbqV9m4ynbtV9myeyHm9c9weYqIqqDQ09LIo9YaRjyfvc6LKsVy2Pxt7dbqV9m4ynbtV9mXJPxO3IThccU2VQf1ALR2pRT9qqYcIPyvunAo)sR9WHABpeKm85DcgJJPqwp4HaYqo0gaU2V(RvticfjaqUXEamdIEhhzzmod5qBa4A)GE1WXz4y0R1FgooNvSPWDepZaRjyvThouR1FgooNnnhFPrzKhmIfm3JZmWAcwrV9myeyHm9c9weYqIqqDQ0YdfD6LbwtWkQe0ljLEXStVM2hcGE7zWXAcME7zIhtVqVfBpeeCTFvlQ1E4qTFwR1FgooNXadnoYYyCgAa0Q9V2(wRC1c9wS9qqW1(vT9R2pOxnCCgog9A9NHJZzmWqJJSmgNzG1eSIE7zWiWcz6f6TiKHeHG6uP7hfD6LbwtWkQe0ljLEHmMD610(qa0BpdowtW0BpdgbwitVqVfHmKie0RgoodhJET(ZWX5mgyOXrwgJZqdGwTj8xlQ1kxTThcsgdm04ilJXzSBA0QnH)ArTw5xB7HGKBqIPWJIZVuQtLorOOtVmWAcwrLGE7zIhtVAsyJetjdWXzfJm6XRnH)ArT2Z1IATNETFwRBcg45KDeSlKfXoCqJZmWAcwvRC1QjeHIeaiNSJGDHSi2HdACgYH2aW1(vTOu7h1EU22dbj3GetHhfNFP1kxTmGHjLvBc1MiFxRC1g4ABpeKmgTNqenGkQHemUramo)sPxt7dbqV9m4ynbtV9myeyHm9AHThUlQja14dbqDQ0YRu0PxgynbROsqV9mXJPxCkler3GjzhNBctXreXdcLv7x1IATYvl0gvK7XapBkfopGAtOwu)U2dhQT9qqYnHP4iI4bHYYVu610(qa0BpdowtW0BpdgbwitVnHP4iI4bHYIyzan1Pslzu0PxgynbROsqVA44mCm6f7Sj8owLnHGEnTpea9QnHiAAFiGOyWo9kgShbwitVyNnH3rDQ0bkk60ldSMGvujOxt7dbqVAtiIM2hcikgStVIb7rGfY0RwHPovAu(MIo9YaRjyfvc6vdhNHJrVAsyJetjdWX1MWFT60yOL4ioLbQALFTFwB7HGKBqIPWJIZV0ApxB7HGKjPPeO)aJll)sR9JAp9A)Sw3emWZskVrJwubTaYmWAcwvRC1(zTbUw3emWZHgenwfriWOInVlZaRjyvThouRMqeksaGCObrJvrecmQyZ7Yqo0gaU2eQfLA)O2pOxt7dbqVAtiIM2hcikgStVIb7rGfY0lYagCh1PsJcku0PxgynbROsqVM2hcGE1MqenTpequmyNEfd2JalKP32BekQtLgfuPOtVmWAcwrLGE1WXz4y0ldyyszzfJm6XRnH)ArPF1EUwgWWKYYqojdOxt7dbqVguBao6eiKbo1PsJsFPOtVM2hcGEnO2aCm9jWm9YaRjyfvcQtLgf5HIo9AAFia6vmj7CC8u)PsgYaNEzG1eSIkb1Po9McznjSzofDQ0OqrNEzG1eSIkb1PsJkfD6LbwtWkQeuNkDFPOtVmWAcwrLG6uPLhk60ldSMGvujOov6(rrNEnTpea9Ms8HaOxgynbROsqDQ0jcfD6LbwtWkQe0RP9HaO3qdIgRIieyuXM3rVA44mCm6fAJkY9yGNnLcNhqTjuR88n9McznjSzEeZAcqHP3(rDQ0YRu0PxgynbROsqVM2hcGEHeHi6DCSramMEtHSMe2mpIznbOW0lQuNkTKrrNEzG1eSIkb9AAFia6flgnhnGkQgntVPqwtcBMhXSMauy6fvQtLoqrrNEzG1eSIkb9AAFia61uqgyIbWr4d3rVPqwtcBMhXSMauy6ffQtLgLVPOtVM2hcGEXoBcVJEzG1eSIkb1PsJcku0PxgynbROsqVA44mCm610(0JJmGdhgxBc1Ic9AAFia6Tjmfhrepiug1Po92EJqrrNknku0PxgynbROsqVA44mCm6vtcBKykzaooRyKrpETj8xlk1EU22dbj3GetHhfNFP1EUw3emWZskVrJwubTaYmWAcwvRC12EiizsAkb6pW4YYVu610(qa0B6GDIiI7io1PsJkfD610(qa0lEad2zye7WbnMEzG1eSIkb1Po9ID2eEhfDQ0OqrNEnTpea9AHThUJEzG1eSIkb1Po9Qvyk6uPrHIo9YaRjyfvc6vdhNHJrVThcsUjieL4H9mKnTx7Hd16gmj7zFc5OtIQHR9R)AtKVR9WHABpeKSPGmWedGJWhUl)sPxt7dbqVPeFiaQtLgvk60ldSMGvujOxt7dbqVIh2HKhoMKiumiMkEHwsME1WXz4y0B7HGKBccrjEypdzt71E4qTUbtYE2Nqo6KOA4A)6Vwu)U2dhQvtcBKykzaooRyKrpETF9xlQ0lWcz6v8WoK8WXKeHIbXuXl0sYuNkDFPOtVM2hcGEBccrfrEqz0ldSMGvujOovA5HIo9AAFia6TXqmdrBajPxgynbROsqDQ09JIo9AAFia6fzGCtqik6LbwtWkQeuNkDIqrNEnTpea9AanJDOjIAtiOxgynbROsqDQ0YRu0PxgynbROsqVA44mCm6nW12EiiztbzGjgahHpCx(LwRC1YagMuw2Nqo6KyOL4AtOwuOxt7dbqVMcYatmaocF4oQtLwYOOtVmWAcwrLGE1WXz4y0l0gvK7XapBkfo)sRvUA)Sw3Gjzp7tihDsunCTFvRMe2iXuYaCCwXiJE8ApCO2axl2zt4DSkdjjFCTYvRMe2iXuYaCCwXiJE8At4VwDAm0sCeNYavTYVwuQ9d610(qa0BObrJvrecmQyZ7Oov6affD6LbwtWkQe0RgoodhJEH2OICpg4ztPW5buBc123VRv(1cTrf5EmWZMsHZQh08HaQvUAdCTyNnH3XQmKK8X1kxTAsyJetjdWXzfJm6XRnH)A1PXqlXrCkdu1k)ArHEnTpea9gAq0yveHaJk28oQtLgLVPOtVmWAcwrLGE1WXz4y0loLfIOBWKSJRnH)ArTw5QnW12Eii5MWuCer8Gqz5xATYv7N1g4AH2OICpg4ztPWzoXd2X1E4qTqBurUhd8SPu4mKdTbGRnHALSApCOwOnQi3JbE2ukCEa1MqTFwlQ1k)A1eIqrcaKBctXreXdcLL1DgmjJJiqt7dbyIA)O2tVwu7xTFqVM2hcGEBctXreXdcLrDQ0OGcfD6LbwtWkQe0RgoodhJE7zWXAco3eMIJiIheklILb01kxTAsyJetjdWXzfJm6XRnH)ArP2Z12Eii5gKyk8O48lLEnTpea9MSJGDHSi2HdAm1PsJcQu0PxgynbROsqVA44mCm6TNbhRj4CtykoIiEqOSiwgqxRC1(zTmGHjLL9jKJojgAjU2eQTF1E4qTmGHjLv7x1Is)Q9d610(qa0lAJqmGKrCkKzQtLgL(srNEzG1eSIkb9QHJZWXO3EgCSMGZnHP4iI4bHYIyzaDTYvldyyszzFc5OtIHwIRnHArHEnTpea92eMIJWhUJ6uPrrEOOtVmWAcwrLGE1WXz4y0BGRf7Sj8owLnHOw5QTNbhRj4Sf2E4UOMauJpea9AAFia6TNbgCh1PsJs)OOtVmWAcwrLGE1WXz4y0BGRf7Sj8owLnHOw5QTNbhRj4Sf2E4UOMauJpea9AAFia6f3zksaHSqrDQtVidyWDu0PsJcfD6LbwtWkQe0RgoodhJEBpeKm85DcgJJPqwp4HaYV0ApCO2pR16pdhNZk2u4oINzG1eSQ2dhQ16pdhNZMMJV0OmYdgXcM7XzgynbRQ9JALR22dbjdjcr074yJayC(LsVM2hcGEBShaZGO3XrwgJPovAuPOtVmWAcwrLGE1WXz4y0B7HGKXIrZrdOIQrZzihAdax7x16gmj7zFc5OtIQHRvUABpeKmwmAoAavunAod5qBa4A)Q2pRfLApxRMe2iXuYaCCTFu7PxlkzjJEnTpea9IfJMJgqfvJMPov6(srNEzG1eSIkb9QHJZWXO3pRT9qqYqIqe9oo2iagNHCOnaCTF9xBFR9WHA7zWXAcod9weYqIqu7h1kxTFwRBWKSN9jKJojQgU2eQf1VR9WHABpeKmKierVJJncGXzihAdax7x16gmj7zFc5OtIQHR9d610(qa0lKierVJJncGXuNkT8qrNEzG1eSIkb9QHJZWXOxR)mCCoBAo(sJYipyelyUhNzG1eSQ2dhQ16pdhNZk2u4oINzG1eSIEnTpea92ypaMbrVJJSmgtDQ09JIo9AAFia6vn4uZ1D0ldSMGvujOo1Po9ApVJaP37eEkuN6uka]] )
    

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