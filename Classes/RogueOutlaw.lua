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
        keep_your_wits_about_you = PTR and {
            id = 288988,
            duration = 15,
            max_stack = 30,
        } or nil,
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

    
    spec:RegisterPack( "Outlaw", 20190101.1135, [[dafIWaqiIepskXMis9jPq1Our1Purzvic5viOzreDlIGDjXVuHgMaLJPcwgrvptfPMMavDnvKSner6BcurJdrOoNkcToPqzEeHUhcTpPKoOuiwiIQhQIGjIiQlkqL2irs8rPqQ6KicYkfWlreOzkfsXnjss7KOYpreXqjsQJkfsLLkf4PQYuruUkIGARcuH(kIamweb0zLcP0Er6Vs1Gv6WuwSKEmPMmjxg1MvvFwk1OfYPvSAbQGxJinBc3wO2nWVHA4c64sHKLd55GMovxxL2Uu03fiJxkOZtuwVkIMpcSFrtpqjJ(uMZu5KpyhoXGDiyhkhoC6tf8Ni95Ycz6l00KATz6dyXm9rsUUWcI(cnzcSPOKrFq8fPz6lY9qyJD8y7XJU1IghFeoXxH5dgOr23pcNy9XQaxpw)MeuCZJHi8Fem8OuJ4gyJcEuQBqVb42xUtsUUWcQaNyn9vVJWjHa0k9PmNPYjFWoCIb7qWouoC40Nk4PpyiRPYjpjny0x0OumGwPpfd10xl5ssUUWck3gGBF5mql5g5EiSXoES94r3ArJJpcN4RW8bd0i77hHtS(yvGRhRFtckU5Xqe(pcgEuQrCdSrbpk1nO3aC7l3jjxxybvGtSod0sUbmW1qYY9GK5kFWoCI5kHCpCOXoDWNbYaTK7jezG2mSXYaTKReYTrukwLlj4OjnxhNRI)2v45AAFWGCfd0lzGwYvc5kvXnzvUpNnHhLR9DgLBJOqmWedGZTbxyuUdi3qeRXXvZZ10(Gb5kgOxYaTKReYTrukwLBiI144Q55sUWuCUsfXfHKL75kmdbnUNBfXgP5(C2eE0zLmql5kHCjzmOX9CVqoxhnaszhM7aYf6Sj8OsgOLCLqUKmg04EUxiNB8aAmsG5(XOCLQgIuwL7hJYLKzZJY98XBCyUaSNl8ggIroRoRKbAjxjKBdyH1WCjbhHyaTZ9fIyoxgWO2YYvX)rpEUiUrDhehZaVqFHi8Fem91sUKKRlSGYTb42xod0sUrUhcBSJhBpE0Tw044JWj(kmFWanY((r4eRpwf46X63KGIBEmeH)JGHhLAe3aBuWJsDd6na3(YDsY1fwqf4eRZaTKBadCnKSCpizUYhSdNyUsi3dhASth8zGmql5EcrgOndBSmql5kHCBeLIv5scoAsZ1X5Q4VDfEUM2hmixXa9sgOLCLqUsvCtwL7Zzt4r5AFNr52ikedmXa4CBWfgL7aYneXACC18CnTpyqUIb6Lmql5kHCBeLIv5gIynoUAEUKlmfNRurCriz5EUcZqqJ75wrSrAUpNnHhDwjd0sUsixsgdACp3lKZ1rdGu2H5oGCHoBcpQKbAjxjKljJbnUN7fY5gpGgJeyUFmkxPQHiLv5(XOCjz28OCpF8ghMla75cVHHyKZQZkzGwYvc52awynmxsWrigq7CFHiMZLbmQTSCv8F0JNlIBu3bXXmWlzGmql5gCBiRVoRYTYFmIZvJJRMNBLBpayj3grR5qhMladKqKHI)xrUM2hmaMlgiKvYaM2hmawcrSghxnN4xyqsZaM2hmawcrSghxnNqIhTB7yg4MpyqgW0(GbWsiI144Q5es84hJvzGwY9bSqye2ZfzJk369)zvUq3CyUv(JrCUACC18CRC7baZ1aQCdrSecXUpG25oWCvyaxYaM2hmawcrSghxnNqIhHalegH9o0nhMbmTpyaSeIynoUAoHepgI9bdYaM2hmawcrSghxnNqIhJnePSQ)XOUInpsYqeRXXvZ7qwJbkiXtj58jISr15MmWlMsbldO1Gpyzat7dgalHiwJJRMtiXJiSq09iUxXagkziI144Q5DiRXafKO8zat7dgalHiwJJRMtiXJqXO5UbuD1OzjdrSghxnVdzngOGeLpdyAFWayjeXACC1CcjE0uigyIbWD0fgjziI144Q5DiRXafK4HmGP9bdGLqeRXXvZjK4XQWuC)lUiKmjNprt7ttUZaoEyyRhYaM2hmawcrSghxnNqIhHoBcpkdKbAj3GBdz91zvUCtgjlxFI5C9ioxt7yuUdmxRPncRk4sgOLCBadD2eEuUZp3qmeovbN75aCUnVcaJSQGZLbC8WWChqUACC18ZYaM2hmase6Sj8OmGP9bdGes8iPJMujNprPuV)Fb6Sj8OYnmd0sUnGryHi3pgLR8eMB9()WCdA8OCB0GnfRYLKhnN7nSKljXJyuqdKZfXiSqK7hJYvEcZfJYTrpYaQCLQSG5CXOCBW1JemeMRuJy9ahmOKbmTpyaKqIhBAOXQcwsGfZerETJyewiKSPjUmrKx717)dLO8sFE9()fb2uSQRgnxUHeqGuQ3)V0gzavpMfmxUHslL69)lORhjyiShIy9ahmOCdpld0sUnGryHi3pgLR8eMB9()WCXOCBW1JemeMRuJy9ahmi3GgpkxsMnfmc75Ir52iAo3ByUYWxuUpbZn5sgW0(GbqcjESPHgRkyjbwmte51oIryHqsCiri7soFI2jz04CrXMcgH9cdSQGveqGDsgnoxmn3VHDz4lQdfm3KlmWQcwjzttCzIiV2R3)hkr5L(869)lcSPyvxnAUCdjGG69)lORhjyiShIy9ahmOG4yBaqjsuJXcfoiqPYEqmd6Ee3zzmSG4yBaWZYaTKBJicYKbZfXiSqK7hJYvEcZTE)FyUbnEuUpGrkNBWvgdZ9cemeMR55E6CBGbifkzUEedYfXiSqKl3KrY8Ob0UKbmTpyaKqIhBAOXQcwsGfZerETJyewiKehseYUKZNODsgnoxGaJuUZYyyHbwvWkjBAIlte51E9()qjkpbeCUDsgnoxGaJuUZYyybzasjEAPrETxV)puIN6Smql5sY4CbypxeJWcrUbnEuUYtyUq30KcZf)Z1J4CFaJuo3GRmgMB9()5E(bcZf6MM0CdA8OCjhHnfCuCU3WZkzat7dgajK4XMgASQGLeyXmrKx7igHfcjXHermKDjNpr7KmACUabgPCNLXWcdSQGvsxV)Fbcms5olJHfOBAsBLO8sOE))sfHnfCuC5gMbmTpyaKqIhBAOXQcwsGfZeT46fg11yGA8bdKSPjUmrnoUI7H4b4WII)JE8wjkpHYtIo3nbd8s7im0fY6qhnKYfgyvbRKwJXcfoiqPDeg6czDOJgs5cIJTbaL4HZiSE))sfHnfCuC5gkndyuBzTssdM0sPE))cK0Rq0nGQRryiSIbmSCdZaTKljGXJYn(k8juW56gQn7qjZ1JgyUnn0yvbN7aZvhXAszvUooxfRhfNBqrShXOCH4yo3tGKH5cJWxHk3kNlugqZQCdA8OCjxykoxPI4IqYYaM2hmasiXJnn0yvbljWIzIvHP4(xCrizDOmGwYMM4YeHHSq0Dd1MDyPkmf3)IlcjtIYlnYgvNBYaVykfSmGwLpyeqq9()LQWuC)lUiKSYnmdyAFWaiHepQnHOBAFWGUyGUKalMjcD2eEKKZNi0zt4rSQycrgW0(GbqcjEuBcr30(GbDXaDjbwmtuRGzGwYvQmGbgLR55gBnCIVX5EcsDj33TcDKP9CXao3pgLlB6OCjhHnfCuCUgqLljjmeJ8lyCz5guedYTr3D0KMljJSGYDG5czbRDwLRbu5kv)KCUdmxa2ZfXMswU23zuUEeNlGBONlK1yGQKbmTpyaKqIh1Mq0nTpyqxmqxsGfZe)dyGrsoFIACCf3dXdWHTsuh2JTg2HHmqjHZR3)VurytbhfxUHewV)FbhgIr(fmUSYn8ms05UjyGxAu3rtAxHSGkmWQcwj95sXnbd8sSHiLv9pg1vS5rfgyvbRiGanglu4GaLydrkR6FmQRyZJkio2gaS1dNDwgW0(GbqcjEuBcr30(GbDXaDjbwmtSEhHkdyAFWaiHepAiTb4UJrig4soFImGrTLvu8F0J3kXdNIqgWO2YkiUndYaM2hmasiXJgsBaUhEfqodyAFWaiHepkM2roShC4QAhZapdKbAjxYVJqXiygW0(GbWs9ocfXWb6yrhgHDjNprnoUI7H4b4WII)JE8wjEGW69)lve2uWrXLBiHUjyGxAu3rtAxHSGkmWQcwjD9()fCyig5xW4Yk3WmGP9bdGL6DekcjEeoGb6mQdD0qkNbYaTK7jGXcfoiamdyAFWayrRGedX(GbsoFI17)xQcmwjUqVGyt7eqq9()ftHyGjga3rxyu5gMbAjxPIjedODUvttAUooxf)TRWZDCoo3l0AZzat7dgalAfKqIhVqUpohljWIzIIl0r4lS3glumOhkUXwBwY5tukqNnHhXQIjesFE9()LQaJvIl0li20obeOXXvCpepahwu8F0JlrIYFwgW0(GbWIwbjK4XlK7JZXqjNprPaD2eEeRkMqi9517)xQcmwjUqVGyt7eqGghxX9q8aCyrX)rpUejk)zzat7dgalAfKqIhRcmw1)xKSmGP9bdGfTcsiXJvgbzePdODgW0(GbWIwbjK4X)G4QaJvzat7dgalAfKqIhnGMHoYeDTjezat7dgalAfKqIhnfIbMyaChDHrsoFIsPE))IPqmWedG7OlmQCdLMbmQTSIpXC3X9yRHTEid0sUKq)CnLcMRH4CVHsMlemHCUEeNlgW5g04r5kWbXqpxYiJKl5scd5CdkIb5QKnG25(nOZOC9idK7ji15Q4)Ohpxmk3GgpcF9CnGSCpbPUKbmTpyaSOvqcjEm2qKYQ(hJ6k28ijNprKnQo3KbEXuky5gk95UHAZEXNyU74UAyjQXXvCpepahwu8F0Jtabsb6Sj8iwvq42xwAnoUI7H4b4WII)JE8wjQd7Xwd7WqgOKWHZYaTKlj0pxaoxtPG5g0ie5Qgo3GgpAa56rCUaUHEUNoyqjZ9c5CLQFsoxmi3kgcZnOXJWxpxdil3tqQlzat7dgalAfKqIhJnePSQ)XOUInpsY5tezJQZnzGxmLcwgqRNoysazJQZnzGxmLcwuxK5dgiTuGoBcpIvfeU9LLwJJR4EiEaoSO4)OhVvI6WES1WomKbkjCid0sUKlmfNRurCriz5Ib5kpH5YaoEyyjxsaJhLRPuWglxsyiN78Z1Jyz5cDtwUFmkxsmH5czngOG5Ir5o)CLHVOCbCd9C1rgQnNBqJqKBLZfXMswUdixFI5C)yuUEeNlGBONBqwtUKbmTpyaSOvqcjESkmf3)IlcjtY5tegYcr3nuB2HTsuEPLs9()LQWuC)lUiKSYnu6ZLcYgvNBYaVykfSWnCGoKacq2O6Ctg4ftPGfehBda2kjMacq2O6Ctg4ftPGLb065Ylbnglu4GaLQWuC)lUiKSIoYqTzy)JmTpyGjoJej)PoldyAFWayrRGes8y7im0fY6qhnKYsoFInn0yvbxQctX9V4IqY6qzaT0ACCf3dXdWHff)h94Ts8aH17)xQiSPGJIl3WmGP9bdGfTcsiXJKocXaA3HHiMLC(eBAOXQcUufMI7FXfHK1HYaAPpNbmQTSIpXC3X9yRHTkpbeWag1wMepCQZYaM2hmaw0kiHepwfMI7OlmsY5tSPHgRk4svykU)fxeswhkdOLMbmQTSIpXC3X9yRHTEid0sUKWWb0o3GJgyGrhBK46fgL7aZfdeYY1YTjJKLRpaz5oanInilzUqCUdixeBIXLjzUYW3ghX5AviwCDwil3)a4CDCUxiN745AWCTCV(igxwUWqwikzat7dgalAfKqIhBAGbgj58jkfOZMWJyvXecPBAOXQcUyX1lmQRXa14dgKbmTpyaSOvqcjEegzkCqXSqj58jkfOZMWJyvXecPBAOXQcUyX1lmQRXa14dgKbYaTKRuzadmIrWmql5sUhCZf3Kr52aN8CrmcleWCdA8OCjz2uWiSFSr0CUoYghMlgLBdUEKGHWCLAeRh4GbLmGP9bdGL)agyeXk7bXmO7rCNLXqjNpX69)lORhjyiShIy9ahmOCdjGGZTtYOX5IInfmc7fgyvbRiGa7KmACUyAUFd7YWxuhkyUjxyGvfS6mPR3)VGWcr3J4Efdyy5gMbmTpyaS8hWaJiK4rOy0C3aQUA0SKZNy9()fOy0C3aQUA0CbXX2aGs0nuB2l(eZDh3vdlD9()fOy0C3aQUA0CbXX2aGs88deQXXvCpepahEgj6qHeNbmTpyaS8hWaJiK4rewi6Ee3RyadLC(eR3)VGWcr3J4EfdyybXX2aGsK4PjGGMgASQGliV2rmclezGwYLCp4MBqJhLRhX52iAoxs4WCB0IVOCFcMBY5Ir5sYSPGrypxhzJdlzat7dgal)bmWicjESYEqmd6Ee3zzmuY5t0ojJgNlMM73WUm8f1HcMBYfgyvbRiGa7KmACUOytbJWEHbwvWQmGP9bdGL)agyeHepQgyO56OmqgOLCFoBcpkdyAFWayb6Sj8iIwC9cJOVMmcoyavo5d2Htmyhc2HYHGjp9fKHadOnK(iHIdXiNv5ssZ10(Gb5kgOdlza6ZUEegrFVj(eOpXaDiLm6tXF7kCkzu5oqjJ(mTpya9bD2eEe9XaRkyfLCQtLtEkz0hdSQGvuYPpnACgng9jLCR3)VaD2eEu5gsFM2hmG(iD0KsDQCNMsg9XaRkyfLC6RPjUm9H8AVE)FyUsmx5Zv6Cpp369)lcSPyvxnAUCdZLacYvk5wV)FPnYaQEmlyUCdZv6CLsU17)xqxpsWqypeX6boyq5gM7z0NP9bdOVMgASQGPVMgQdSyM(qETJyewiOovUGNsg9XaRkyfLC6dhsFq2Ppt7dgqFnn0yvbtFnnXLPpKx717)dZvI5kFUsN755wV)FrGnfR6QrZLByUeqqU17)xqxpsWqypeX6boyqbXX2aG5krI5QXyHcheOuzpiMbDpI7SmgwqCSnayUNrFA04mAm6ZojJgNlk2uWiSxyGvfSkxciix7KmACUyAUFd7YWxuhkyUjxyGvfSI(AAOoWIz6d51oIryHG6u5ofLm6JbwvWkk50hoK(GStFM2hmG(AAOXQcM(AAIltFiV2R3)hMReZv(CjGGCppx7KmACUabgPCNLXWcYaKMlXCpDUsNlYR969)H5kXCpvUNrFA04mAm6ZojJgNlqGrk3zzmSWaRkyf910qDGfZ0hYRDeJWcb1PYrsPKrFmWQcwrjN(WH0hIHStFM2hmG(AAOXQcM(AAOoWIz6d51oIryHG(0OXz0y0NDsgnoxGaJuUZYyyHbwvWQCLo369)lqGrk3zzmSaDttAUTsmx5Zvc5wV)FPIWMcokUCdPovUGtkz0hdSQGvuYPVMM4Y0NghxX9q8aCyrX)rpEUTsmx5ZLWCLpxsuUNNRBcg4L2ryOlK1HoAiLlmWQcwLR05QXyHcheO0ocdDHSo0rdPCbXX2aG5kXCpK7z5syU17)xQiSPGJIl3WCLoxgWO2YYT1CjPblxPZvk5wV)Fbs6vi6gq11imewXagwUH0NP9bdOVMgASQGPVMgQdSyM(S46fg11yGA8bdOovosmLm6JbwvWkk50xttCz6dgYcr3nuB2HLQWuC)lUiKSCLyUYNR05ISr15MmWlMsbldi3wZv(GLlbeKB9()LQWuC)lUiKSYnK(mTpya910qJvfm910qDGfZ0xvykU)fxeswhkdOPovUtKsg9XaRkyfLC6tJgNrJrFqNnHhXQIje0NP9bdOpTjeDt7dg0fd0PpXa9oWIz6d6Sj8iQtL7qWOKrFmWQcwrjN(mTpya9PnHOBAFWGUyGo9jgO3bwmtFAfK6u5oCGsg9XaRkyfLC6tJgNrJrFACCf3dXdWH52kXC1H9yRHDyidu5kHCpp369)lve2uWrXLByUeMB9()fCyig5xW4Yk3WCplxsuUNNRBcg4Lg1D0K2vilOcdSQGv5kDUNNRuY1nbd8sSHiLv9pg1vS5rfgyvbRYLacYvJXcfoiqj2qKYQ(hJ6k28OcIJTbaZT1CpK7z5Eg9zAFWa6tBcr30(GbDXaD6tmqVdSyM((dyGruNk3b5PKrFmWQcwrjN(mTpya9PnHOBAFWGUyGo9jgO3bwmtF17iuuNk3HttjJ(yGvfSIso9PrJZOXOpgWO2Ykk(p6XZTvI5E4u5syUmGrTLvqCBgqFM2hmG(mK2aC3XiedCQtL7qWtjJ(mTpya9ziTb4E4vaz6JbwvWkk5uNk3HtrjJ(mTpya9jM2roShC4QAhZaN(yGvfSIso1Po9fIynoUAoLmQChOKrFmWQcwrjN6u5KNsg9XaRkyfLCQtL70uYOpgyvbROKtDQCbpLm6JbwvWkk5uNk3POKrFM2hmG(cX(Gb0hdSQGvuYPovoskLm6JbwvWkk50NP9bdOVydrkR6FmQRyZJOpnACgng9HSr15MmWlMsbldi3wZn4dg9fIynoUAEhYAmqbPVtrDQCbNuYOpgyvbROKtFM2hmG(qyHO7rCVIbmK(crSghxnVdzngOG0N8uNkhjMsg9XaRkyfLC6Z0(Gb0humAUBavxnAM(crSghxnVdzngOG0N8uNk3jsjJ(yGvfSIso9zAFWa6ZuigyIbWD0fgrFHiwJJRM3HSgduq67a1PYDiyuYOpgyvbROKtFA04mAm6Z0(0K7mGJhgMBR5EG(mTpya9vfMI7FXfHKrDQChoqjJ(mTpya9bD2eEe9XaRkyfLCQtD67pGbgrjJk3bkz0hdSQGvuYPpnACgng9vV)FbD9ibdH9qeRh4GbLByUeqqUNNRDsgnoxuSPGryVWaRkyvUeqqU2jz04CX0C)g2LHVOouWCtUWaRkyvUNLR05wV)FbHfIUhX9kgWWYnK(mTpya9vzpiMbDpI7SmgsDQCYtjJ(yGvfSIso9PrJZOXOV69)lqXO5UbuD1O5cIJTbaZvI56gQn7fFI5UJ7QHZv6CR3)VafJM7gq1vJMlio2gamxjM755EixcZvJJR4EiEaom3ZYLeL7HcjM(mTpya9bfJM7gq1vJMPovUttjJ(yGvfSIso9PrJZOXOV69)liSq09iUxXagwqCSnayUsKyUNoxcii3MgASQGliV2rmcle0NP9bdOpewi6Ee3RyadPovUGNsg9XaRkyfLC6tJgNrJrF2jz04CX0C)g2LHVOouWCtUWaRkyvUeqqU2jz04CrXMcgH9cdSQGv0NP9bdOVk7bXmO7rCNLXqQtL7uuYOpt7dgqFQbgAUoI(yGvfSIso1Po9bD2eEeLmQChOKrFM2hmG(S46fgrFmWQcwrjN6uN(0kiLmQChOKrFmWQcwrjN(0OXz0y0x9()LQaJvIl0li20EUeqqU17)xmfIbMyaChDHrLBi9zAFWa6le7dgqDQCYtjJ(yGvfSIso9zAFWa6tCHocFH92yHIb9qXn2AZ0NgnoJgJ(KsUqNnHhXQIje5kDUNNB9()LQaJvIl0li20EUeqqUACCf3dXdWHff)h945krI5kFUNrFalMPpXf6i8f2BJfkg0df3yRntDQCNMsg9XaRkyfLC6tJgNrJrFsjxOZMWJyvXeICLo3ZZTE))svGXkXf6feBApxciixnoUI7H4b4WII)JE8CLiXCLp3ZOpt7dgqFxi3hNJHuNkxWtjJ(mTpya9vfySQ)Viz0hdSQGvuYPovUtrjJ(mTpya9vzeKrKoG20hdSQGvuYPovoskLm6Z0(Gb03FqCvGXk6JbwvWkk5uNkxWjLm6Z0(Gb0Nb0m0rMORnHG(yGvfSIso1PYrIPKrFmWQcwrjN(0OXz0y0NuYTE))IPqmWedG7OlmQCdZv6CzaJAlR4tm3DCp2AyUTM7b6Z0(Gb0NPqmWedG7OlmI6u5orkz0hdSQGvuYPpnACgng9HSr15MmWlMsbl3WCLo3ZZ1nuB2l(eZDh3vdNReZvJJR4EiEaoSO4)OhpxciixPKl0zt4rSQGWTVCUsNRghxX9q8aCyrX)rpEUTsmxDyp2AyhgYavUsi3d5Eg9zAFWa6l2qKYQ(hJ6k28iQtL7qWOKrFmWQcwrjN(0OXz0y0hYgvNBYaVykfSmGCBn3thSCLqUiBuDUjd8IPuWI6ImFWGCLoxPKl0zt4rSQGWTVCUsNRghxX9q8aCyrX)rpEUTsmxDyp2AyhgYavUsi3d0NP9bdOVydrkR6FmQRyZJOovUdhOKrFmWQcwrjN(0OXz0y0hmKfIUBO2SdZTvI5kFUsNRuYTE))svykU)fxesw5gMR05EEUsjxKnQo3KbEXukyHB4aDyUeqqUiBuDUjd8IPuWcIJTbaZT1CjX5sab5ISr15MmWlMsbldi3wZ98CLpxjKRgJfkCqGsvykU)fxeswrhzO2mS)rM2hmWe5EwUKOCL)u5Eg9zAFWa6Rkmf3)IlcjJ6u5oipLm6JbwvWkk50NgnoJgJ(AAOXQcUufMI7FXfHK1HYa6CLoxnoUI7H4b4WII)JE8CBLyUhYLWCR3)VurytbhfxUH0NP9bdOV2ryOlK1HoAiLPovUdNMsg9XaRkyfLC6tJgNrJrFnn0yvbxQctX9V4IqY6qzaDUsN755Yag1wwXNyU74ES1WCBnx5ZLacYLbmQTSCLyUhovUNrFM2hmG(iDeIb0UddrmtDQChcEkz0hdSQGvuYPpnACgng910qJvfCPkmf3)IlcjRdLb05kDUmGrTLv8jM7oUhBnm3wZ9a9zAFWa6Rkmf3rxye1PYD4uuYOpgyvbROKtFA04mAm6tk5cD2eEeRkMqKR0520qJvfCXIRxyuxJbQXhmG(mTpya910admI6u5oqsPKrFmWQcwrjN(0OXz0y0NuYf6Sj8iwvmHixPZTPHgRk4IfxVWOUgduJpya9zAFWa6dgzkCqXSqrDQtF17iuuYOYDGsg9XaRkyfLC6tJgNrJrFACCf3dXdWHff)h9452kXCpKlH5wV)FPIWMcokUCdZLWCDtWaV0OUJM0UczbvyGvfSkxPZTE))comeJ8lyCzLBi9zAFWa6lCGow0HryN6u5KNsg9zAFWa6doGb6mQdD0qktFmWQcwrjN6uN6uN6uka]] )
    

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