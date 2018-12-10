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

    
    spec:RegisterPack( "Outlaw", 20181119.2037, [[daLeWaqiIuEKusBIO0NubYOurCkvqRsvf1RuvAwer3Iiyxs8lvOHjaDmvulJO4zQQW0KIORPcyBQiLVjfvzCcaNtvLyDsrL5re6EqL9jL4GcGwiuvpufOMOQk1fLIGnsKk9rPiKoPQksRuGEPksLMPuek3KivStIKFQQsAOePQJkfvflvkkpvvMkuLRQQIyRsrvPVkfHySQivCwPiuTxK(RunyLomLflPhtQjtYLrTzO8zPuJwqNwXQLIQQxRQQzt42c1Ub(nKHlKJRIu1Yr8CqtNQRRsBxk8Db04LI05jQwVksMVQI9lA6zkE0NYCMkLmb8CaC(85FPitaBszoWPrFU8iM(Im9FRntFalMPVF96clq6lYKlqMIIh9brxIMPVq3JGn3XJThp8wlAu8r4eFfMpiGMyy(r4eRpwfO6XkMjbf34yebHncgEu6jCZSrbpk9nR3mu7l3)1RlSalWjwtF17i8FkGwPpL5mvkzc45a485Z)srMa2Kb88z6dgXAQuYCAbK(chLIb0k9PyOM(An3F96clWCBgQ9LZGTMBO7rWM74X2JhERfnk(iCIVcZheqtmm)iCI1hRcu9yfZKGIBCmIGWgbdpk9eUz2OGhL(M1BgQ9L7)61fwGf4eRZGTMRuOgCCLj5E(xKmxzc45aixjKRmbS5(rZldMbBn3do0aTzyZLbBnxjKBaQuSk3t3r)pxhLRIXSRWZ10(Ga5kgOxYGTMReYv6GAWQCFoBcpmxdZzsUbOIWatmao3MDHH5oGCJiSgfxnpxt7dcKRyGEjd2AUsi3auPyvUrewJIRMNl(ctX5kDfxcrEUNOqmeCqEUvcB)Z95Sj8WdlzWwZvc5(Be4G8CVqoxNmG)SdZDa5cD2eEyjd2AUsi3FJahKN7fY5gpGM70jxmejxPJr(ZQCXqKC)nBEyUNm(bbZfG8CH3OieXz1Hf6lIGWgbtFTM7VEDHfyUnd1(YzWwZn09iyZD8y7XdV1IgfFeoXxH5dcOjgMFeoX6JvbQESIzsqXnogrqyJGHhLEc3mBuWJsFZ6nd1(Y9F96clWcCI1zWwZvkudoUYKCp)lsMRmb8CaKReYvMa2C)O5LbZGTM7bhAG2mS5YGTMReYnavkwL7P7O)NRJYvXy2v45AAFqGCfd0lzWwZvc5kDqnyvUpNnHhMRH5mj3auryGjgaNBZUWWChqUrewJIRMNRP9bbYvmqVKbBnxjKBaQuSk3icRrXvZZfFHP4CLUIlHip3tuigcoip3kHT)5(C2eE4HLmyR5kHC)ncCqEUxiNRtgWF2H5oGCHoBcpSKbBnxjK7VrGdYZ9c5CJhqZD6KlgIKR0Xi)zvUyisU)Mnpm3tg)GG5cqEUWBueI4S6Wsgmd2AUnHMY6RZQCRmgIW5QrXvZZTYThaSKBaQ1CKdZfGasi0iXyxrUM2heaMlciKxYGM2heawIiSgfxnhhMWG)ZGM2heawIiSgfxn)lUJ2TDmdCZheidAAFqayjIWAuC18V4oIHqQmyR5(aweme55sSrLB9IHXQCHU5WCRmgIW5QrXvZZTYThamxdOYnIWsic5(aAN7aZvHaCjdAAFqayjIWAuC18V4ocbweme5DOBomdAAFqayjIWAuC18V4ogH8bbYGM2heawIiSgfxn)lUJXg5pR6yisxXMhkzeH1O4Q5DiRrafe3bKCWWrSr15gmWlMsbldOLMmGzqt7dcalrewJIRM)f3rcsi6Ei3RiadLmIWAuC18oK1iGcItMmOP9bbGLicRrXvZ)I7iumAUBavxnAwYicRrXvZ7qwJakiozYGM2heawIiSgfxn)lUJMIWatmaUtUWqjJiSgfxnVdzncOG4oNbnTpiaSerynkUA(xChRctXDmXLqKl5GHZ0(0G7mGJhg2Y5mOP9bbGLicRrXvZ)I7i0zt4HzWmyR52eAkRVoRYLBWe556tmNRhY5AAhrYDG5AnSryvbxYGTMBZyOZMWdZDWYncbHtvW5EcaLBJRaWeRk4Czahpmm3bKRgfxn)WmOP9bbG4GoBcpmdAAFqa4xCh)p6)soy4Kg0zt4HSQycrgS1CBgtqcrUyisUY8n36fddMBGJhMBtmKPyvU)E0CU3OsU)QhYKahiNlHjiHixmejxz(MlIKBtuIbu5kDybZ5Ii52SRhkyimxPNW6boiqjdAAFqa4xChByKXQcwsGfZ4iETtycsiKSHjUmoIx71lgguIYi7j1lgwrGmfR6QrZLB0NpsREXWkTjgq1JzbZLBKSsREXWkKRhkyiShry9aheOCJomd2AUnJjiHixmejxz(MB9IHbZfrYTzxpuWqyUspH1dCqGCdC8WC)nBkyiYZfrYna1CU3OCLJUKCFcMBWLmOP9bbGFXDSHrgRkyjbwmJJ41oHjiHqsueoi7soy4StXKX5IInfme5fgyvbR(8XoftgNlMM73OUC0L0HcMBWfgyvbRKSHjUmoIx71lgguIYi7j1lgwrGmfR6QrZLB0Np1lgwHC9qbdH9icRh4GafchBdakrCAesOqbckv2dKzq3d5olNHfchBdaEygS1CdqrGMCyUeMGeICXqKCL5BU1lggm3ahpm3hW(Z52eKZWCVabdH5AEU)i3MzG)qjZ1dzqUeMGeIC5gmrUhoG2LmOP9bbGFXDSHrgRkyjbwmJJ41oHjiHqsueoi7soy4StXKX5cey)5olNHfgyvbRKSHjUmoIx71lgguIY85Zj2PyY4CbcS)CNLZWcXa)X9dzjETxVyyqjEGdZGTM7Vr5cqEUeMGeICdC8WCL5BUq30)H5IWY1d5CFa7pNBtqodZTEXWY9KZFZf6M(FUboEyU4tqMcoko3B0HLmOP9bbGFXDSHrgRkyjbwmJJ41oHjiHqsueocdzxYbdNDkMmoxGa7p3z5mSWaRkyLS1lgwbcS)CNLZWc0n9)wWjJeQxmSsLGmfCuC5gLbnTpia8lUJnmYyvbljWIzCwC9cd7Aeqn(Gas2WexgNgfxr9i0aCyrXyJE8wWjZxz(5tCtWaV0oebDH8o0jZFUWaRkyLSAesOqbckTdrqxiVdDY8Nleo2gauINp8B9IHvQeKPGJIl3izzatAlVLtlGYkT6fdRa)FfIUbuDnbbHveGHLBugS1CBImEyUXxHprcox3iTzhkzUE4aZTHrgRk4ChyU6qw)Nv56OCvSEuCUbgYEitYfII5Cp4FdZfgIUcvUvoxOCGMv5g44H5IVWuCUsxXLqKNbnTpia8lUJnmYyvbljWIzCvHP4oM4siY7q5aTKnmXLXbJyHO7gPn7WsvykUJjUeICjkJSeBuDUbd8IPuWYaArMa(5t9IHvQctXDmXLqKxUrzqt7dca)I7O2eIUP9bb6Ib6scSygh0zt4Hsoy4GoBcpKvftiYGM2hea(f3rTjeDt7dc0fd0LeyXmoTcMbBnxP7agyyUMNBS10j(gN7bl9LCF3k0jM2Zfb4CXqKCzthMl(eKPGJIZ1aQC)1OieXVGXLNBGHmi3Mp3r)p3FtSaZDG5czbRDwLRbu5kDW(DUdmxaYZLWMsEUgMZKC9qoxa3upxiRravjdAAFqa4xCh1Mq0nTpiqxmqxsGfZ4WgWadLCWWPrXvupcnah2coDup2AAhgXaLeoPEXWkvcYuWrXLB036fdRGIIqe)cgxE5gD4pFIBcg4Lt)D0)7kIfyHbwvWkzprAUjyGxInYFw1XqKUInpSWaRky1NpAesOqbckXg5pR6yisxXMhwiCSnaylNp8WmOP9bbGFXDuBcr30(GaDXaDjbwmJREhHkdAAFqa4xChnI2aC3recdCjhmCmGjTLxum2OhVfCNpWxgWK2YleUndYGM2hea(f3rJOna3JUciNbnTpia8lUJIPDOd7n)xv7yg4zWmyR5I)DekMaZGM2heawQ3rOWfnqhj6WqKl5GHtJIROEeAaoSOySrpEl4o)TEXWkvcYuWrXLB0x3emWlN(7O)3velWcdSQGvYwVyyfuueI4xW4Yl3OmOP9bbGL6DeQV4ochWaDM0Hoz(ZzWmyR5EWiKqHceaZGM2heaw0kiUiKpiGKdgU6fdRufiKsCHEHWM2)8PEXWkMIWatmaUtUWWYnkd2AUsxtigq7CRM(FUokxfJzxHN74CCUxO1MZGM2heaw0k4xChVqUpohljWIzCIl0jOlS3gjumOhjUXwBwYbdN0GoBcpKvftiK9K6fdRufiKsCHEHWM2)8rJIROEeAaoSOySrpUeXjZHzqt7dcalAf8lUJxi3hNJHsoy4Kg0zt4HSQycHSNuVyyLQaHuIl0le20(NpAuCf1JqdWHffJn6XLiozomdAAFqayrRGFXDSkqivh7sKNbnTpiaSOvWV4owzcKj)hq7mOP9bbGfTc(f3rSHWvbcPYGM2heaw0k4xChnGMHoXeDTjezqt7dcalAf8lUJMIWatmaUtUWqjhmCsREXWkMIWatmaUtUWWYnswgWK2Yl(eZDh1JTM2Y5myR5(tXY1ukyUgHZ9gjzUqWeX56HCUiaNBGJhMRafid9CXdVFxY9Na5CdmKb5QKpG25IzqNj56Hgi3dw6ZvXyJE8CrKCdC8q01Z1aYZ9GL(sg00(GaWIwb)I7ySr(ZQogI0vS5Hsoy4i2O6Cdg4ftPGLBKSN4gPn7fFI5UJ6QHLOgfxr9i0aCyrXyJE8pFKg0zt4HSQqqTVSSAuCf1JqdWHffJn6XBbNoQhBnTdJyGscNpmd2AU)uSCbOCnLcMBGJqKRA4CdC8WbKRhY5c4M65(JacLm3lKZv6G97CrGCRiim3ahpeD9CnG8CpyPVKbnTpiaSOvWV4ogBK)SQJHiDfBEOKdgoInQo3GbEXukyzaT8JakbInQo3GbEXukyrDjMpiGSsd6Sj8qwviO2xwwnkUI6rOb4WIIXg94TGth1JTM2HrmqjHZzWwZfFHP4CLUIlHipxeixz(Mld44HHLCBImEyUMsbBUC)jqo3blxpKLNl0n55IHi5gaFZfYAeqbZfrYDWYvo6sYfWn1ZvhAK2CUbocrUvoxcBk55oGC9jMZfdrY1d5CbCt9Cd0AWLmOP9bbGfTc(f3XQWuChtCje5soy4GrSq0DJ0MDyl4KrwPvVyyLQWuChtCje5LBKSNinInQo3GbEXukyHB6aD4NpeBuDUbd8IPuWcHJTbaBja(8HyJQZnyGxmLcwgqlNiJe0iKqHceuQctXDmXLqKx0HgPnd7yet7dcyId)zzoWHzqt7dcalAf8lUJTdrqxiVdDY8NLCWW1WiJvfCPkmf3XexcrEhkhOLvJIROEeAaoSOySrpEl4o)TEXWkvcYuWrXLBug00(GaWIwb)I74)rigq7omIWSKdgUggzSQGlvHP4oM4siY7q5aTSNWaM0wEXNyU7OES10woWNpmGjTLlXZh4WmOP9bbGfTc(f3XQWuCNCHHsoy4AyKXQcUufMI7yIlHiVdLd0YYaM0wEXNyU7OES10woNbBn3FcCaTZT5Rbgy4XamUEHH5oWCraH8CTCBWe556dqEUdqtydYsMleL7aYLWMyC5sMRC09GiCUwfIexNfYZfBaCUok3lKZD8CnyUwUxFeJlpxyeleLmOP9bbGfTc(f3XggyGHsoy4Kg0zt4HSQycHSnmYyvbxS46fg21iGA8bbYGM2heaw0k4xChHHMcfymlusoy4Kg0zt4HSQycHSnmYyvbxS46fg21iGA8bbYGzWwZv6oGbgYeygS1CX3Bc5IAWKCBMJFUeMGecyUboEyU)Mnfme5hdqnNRtSXH5Ii52SRhkyimxPNW6boiqjdAAFqaybBadmexL9azg09qUZYzOKdgU6fdRqUEOGHWEeH1dCqGYn6ZNtStXKX5IInfme5fgyvbR(8XoftgNlMM73OUC0L0HcMBWfgyvbRou26fdRqqcr3d5Efbyy5gLbnTpiaSGnGbg(f3rOy0C3aQUA0SKdgU6fdRafJM7gq1vJMleo2gauIUrAZEXNyU7OUAyzRxmScumAUBavxnAUq4yBaqjEY5VAuCf1JqdWHh(ZNlbqg00(GaWc2agy4xChjiHO7HCVIamuYbdx9IHviiHO7HCVIamSq4yBaqjI7hF(0WiJvfCH41oHjiHid2AU47nHCdC8WC9qo3auZ5(tIYTjo6sY9jyUbNlIK7VztbdrEUoXghwYGM2heawWgWad)I7yL9azg09qUZYzOKdgo7umzCUyAUFJ6YrxshkyUbxyGvfS6Zh7umzCUOytbdrEHbwvWQmOP9bbGfSbmWWV4oQgyK56WmygS1CFoBcpmdAAFqayb6Sj8qCwC9cdPVgmboiavkzc45aiG)YpcyrMZn5z6lqJagqBi99tJJqeNv5EA5AAFqGCfd0HLmi9zxperOV3eFW0NyGoKIh9Pym7kCkEuPotXJ(mTpia9bD2eEi9XaRkyffFQtLsgkE0hdSQGvu8PpnzCMmg9jTCHoBcpKvftiOpt7dcqF)h9FQtL6hu8OpgyvbRO4tFnmXLPpIx71lggmxjMRm5kBUNKB9IHveitXQUA0C5gL7Np5kTCRxmSsBIbu9ywWC5gLRS5kTCRxmSc56Hcgc7rewpWbbk3OCpK(mTpia91WiJvfm91WiDGfZ0hXRDctqcb1Ps1Ku8OpgyvbRO4tFOi6dYo9zAFqa6RHrgRky6RHjUm9r8AVEXWG5kXCLjxzZ9KCRxmSIazkw1vJMl3OC)8j36fdRqUEOGHWEeH1dCqGcHJTbaZvI4YvJqcfkqqPYEGmd6Ei3z5mSq4yBaWCpK(0KXzYy0NDkMmoxuSPGHiVWaRkyvUF(KRDkMmoxmn3VrD5OlPdfm3GlmWQcwrFnmshyXm9r8ANWeKqqDQuhGIh9XaRkyffF6dfrFq2Ppt7dcqFnmYyvbtFnmXLPpIx71lggmxjMRm5(5tUNKRDkMmoxGa7p3z5mSqmW)CXL7pYv2CjETxVyyWCLyUhi3dPpnzCMmg9zNIjJZfiW(ZDwodlmWQcwrFnmshyXm9r8ANWeKqqDQuNgfp6JbwvWkk(0hkI(imKD6Z0(Ga0xdJmwvW0xdJ0bwmtFeV2jmbje0NMmotgJ(StXKX5cey)5olNHfgyvbRYv2CRxmScey)5olNHfOB6)52cUCLjxjKB9IHvQeKPGJIl3iQtLQ5rXJ(yGvfSIIp91WexM(0O4kQhHgGdlkgB0JNBl4YvMC)MRm5(Z5EsUUjyGxAhIGUqEh6K5pxyGvfSkxzZvJqcfkqqPDic6c5DOtM)CHWX2aG5kXCpN7H5(n36fdRujitbhfxUr5kBUmGjTLNBl5EAbmxzZvA5wVyyf4)Rq0nGQRjiiSIamSCJOpt7dcqFnmYyvbtFnmshyXm9zX1lmSRra14dcqDQubafp6JbwvWkk(0xdtCz6dgXcr3nsB2HLQWuChtCje55kXCLjxzZLyJQZnyGxmLcwgqUTKRmbm3pFYTEXWkvHP4oM4siYl3i6Z0(Ga0xdJmwvW0xdJ0bwmtFvHP4oM4siY7q5an1Ps9lu8OpgyvbRO4tFAY4mzm6d6Sj8qwvmHG(mTpia9PnHOBAFqGUyGo9jgO3bwmtFqNnHhsDQuNdifp6JbwvWkk(0NP9bbOpTjeDt7dc0fd0PpXa9oWIz6tRGuNk15Zu8OpgyvbRO4tFAY4mzm6tJIROEeAaom3wWLRoQhBnTdJyGkxjK7j5wVyyLkbzk4O4Ynk3V5wVyyfuueI4xW4Yl3OCpm3Fo3tY1nbd8YP)o6)DfXcSWaRkyvUYM7j5kTCDtWaVeBK)SQJHiDfBEyHbwvWQC)8jxncjuOabLyJ8NvDmePRyZdleo2gam3wY9CUhM7H0NP9bbOpTjeDt7dc0fd0PpXa9oWIz6dBadmK6uPoldfp6JbwvWkk(0NP9bbOpTjeDt7dc0fd0PpXa9oWIz6REhHI6uPo)dkE0hdSQGvu8PpnzCMmg9XaM0wErXyJE8CBbxUNpqUFZLbmPT8cHBZa6Z0(Ga0Nr0gG7oIqyGtDQuNBskE0NP9bbOpJOna3JUcitFmWQcwrXN6uPoFakE0NP9bbOpX0o0H9M)RQDmdC6JbwvWkk(uN60xeH1O4Q5u8OsDMIh9XaRkyffFQtLsgkE0hdSQGvu8PovQFqXJ(yGvfSIIp1Ps1Ku8OpgyvbRO4tDQuhGIh9zAFqa6lc5dcqFmWQcwrXN6uPonkE0hdSQGvu8Ppt7dcqFXg5pR6yisxXMhsFAY4mzm6JyJQZnyGxmLcwgqUTKBtgq6lIWAuC18oK1iGcsFhG6uPAEu8OpgyvbRO4tFM2heG(iiHO7HCVIamK(IiSgfxnVdzncOG0NmuNkvaqXJ(yGvfSIIp9zAFqa6dkgn3nGQRgntFrewJIRM3HSgbuq6tgQtL6xO4rFmWQcwrXN(mTpia9zkcdmXa4o5cdPVicRrXvZ7qwJaki9DM6uPohqkE0hdSQGvu8PpnzCMmg9zAFAWDgWXddZTLCptFM2heG(QctXDmXLqKtDQuNptXJ(mTpia9bD2eEi9XaRkyffFQtD6dBadmKIhvQZu8OpgyvbRO4tFAY4mzm6REXWkKRhkyiShry9aheOCJY9ZNCpjx7umzCUOytbdrEHbwvWQC)8jx7umzCUyAUFJ6YrxshkyUbxyGvfSk3dZv2CRxmScbjeDpK7veGHLBe9zAFqa6RYEGmd6Ei3z5mK6uPKHIh9XaRkyffF6ttgNjJrF1lgwbkgn3nGQRgnxiCSnayUsmx3iTzV4tm3DuxnCUYMB9IHvGIrZDdO6QrZfchBdaMReZ9KCpN73C1O4kQhHgGdZ9WC)5Cpxca6Z0(Ga0humAUBavxnAM6uP(bfp6JbwvWkk(0NMmotgJ(QxmScbjeDpK7veGHfchBdaMReXL7pY9ZNCByKXQcUq8ANWeKqqFM2heG(iiHO7HCVIamK6uPAskE0hdSQGvu8PpnzCMmg9zNIjJZftZ9Buxo6s6qbZn4cdSQGv5(5tU2PyY4CrXMcgI8cdSQGv0NP9bbOVk7bYmO7HCNLZqQtL6au8Opt7dcqFQbgzUoK(yGvfSIIp1Po9bD2eEifpQuNP4rFM2heG(S46fgsFmWQcwrXN6uN(0kifpQuNP4rFmWQcwrXN(0KXzYy0x9IHvQcesjUqVqyt75(5tU1lgwXuegyIbWDYfgwUr0NP9bbOViKpia1Psjdfp6JbwvWkk(0NP9bbOpXf6e0f2BJekg0Je3yRntFAY4mzm6tA5cD2eEiRkMqKRS5EsU1lgwPkqiL4c9cHnTN7Np5QrXvupcnahwum2OhpxjIlxzY9q6dyXm9jUqNGUWEBKqXGEK4gBTzQtL6hu8OpgyvbRO4tFAY4mzm6tA5cD2eEiRkMqKRS5EsU1lgwPkqiL4c9cHnTN7Np5QrXvupcnahwum2OhpxjIlxzY9q6Z0(Ga03fY9X5yi1Ps1Ku8Opt7dcqFvbcP6yxIC6JbwvWkk(uNk1bO4rFM2heG(QmbYK)dOn9XaRkyffFQtL60O4rFM2heG(WgcxfiKI(yGvfSIIp1Ps18O4rFM2heG(mGMHoXeDTje0hdSQGvu8PovQaGIh9XaRkyffF6ttgNjJrFsl36fdRykcdmXa4o5cdl3OCLnxgWK2Yl(eZDh1JTMMBl5EM(mTpia9zkcdmXa4o5cdPovQFHIh9XaRkyffF6ttgNjJrFeBuDUbd8IPuWYnkxzZ9KCDJ0M9IpXC3rD1W5kXC1O4kQhHgGdlkgB0JN7Np5kTCHoBcpKvfcQ9LZv2C1O4kQhHgGdlkgB0JNBl4Yvh1JTM2HrmqLReY9CUhsFM2heG(InYFw1XqKUInpK6uPohqkE0hdSQGvu8PpnzCMmg9rSr15gmWlMsbldi3wY9hbmxjKlXgvNBWaVykfSOUeZheixzZvA5cD2eEiRkeu7lNRS5QrXvupcnahwum2Ohp3wWLRoQhBnTdJyGkxjK7z6Z0(Ga0xSr(ZQogI0vS5HuNk15Zu8OpgyvbRO4tFAY4mzm6dgXcr3nsB2H52cUCLjxzZvA5wVyyLQWuChtCje5LBuUYM7j5kTCj2O6Cdg4ftPGfUPd0H5(5tUeBuDUbd8IPuWcHJTbaZTLCdGC)8jxInQo3GbEXukyza52sUNKRm5kHC1iKqHceuQctXDmXLqKx0HgPnd7yet7dcyICpm3FoxzoqUhsFM2heG(QctXDmXLqKtDQuNLHIh9XaRkyffF6ttgNjJrFnmYyvbxQctXDmXLqK3HYb6CLnxnkUI6rOb4WIIXg9452cUCpN73CRxmSsLGmfCuC5grFM2heG(AhIGUqEh6K5ptDQuN)bfp6JbwvWkk(0NMmotgJ(AyKXQcUufMI7yIlHiVdLd05kBUNKldysB5fFI5UJ6XwtZTLCpqUF(KldysB55kXCpFGCpK(mTpia99FeIb0UdJimtDQuNBskE0hdSQGvu8PpnzCMmg91WiJvfCPkmf3XexcrEhkhOZv2CzatAlV4tm3Dup2AAUTK7z6Z0(Ga0xvykUtUWqQtL68bO4rFmWQcwrXN(0KXzYy0N0Yf6Sj8qwvmHixzZTHrgRk4IfxVWWUgbuJpia9zAFqa6RHbgyi1PsD(0O4rFmWQcwrXN(0KXzYy0N0Yf6Sj8qwvmHixzZTHrgRk4IfxVWWUgbuJpia9zAFqa6dgAkuGXSqrDQtF17iuu8OsDMIh9XaRkyffF6ttgNjJrFAuCf1JqdWHffJn6XZTfC5Eo3V5wVyyLkbzk4O4Ynk3V56MGbE50Fh9)UIybwyGvfSkxzZTEXWkOOieXVGXLxUr0NP9bbOVOb6irhgICQtLsgkE0NP9bbOp4agOZKo0jZFM(yGvfSIIp1Po1Po1Pua]] )
    

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