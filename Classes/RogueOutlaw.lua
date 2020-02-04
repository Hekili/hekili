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
        between_the_eyes = {
            id = 199804,
            duration = 5,
            max_stack = 1
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
        detection = {
            id = 56814,
            duration = 30,
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
            gcd = "off",

            startsCombat = false,
            texture = 136206,

            toggle = 'cooldowns',

            nobuff = "stealth",

            handler = function ()
                applyBuff( 'adrenaline_rush', 20 )

                energy.regen = energy.regen * 1.6
                energy.max = energy.max + 50
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


        detection = {
            id = 56814,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132319,
            
            handler = function ()
                applyBuff( "detection" )
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
                applyBuff( 'feint', 5 )
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

            usable = function ()
                if time > 0 then return false, "cannot stealth in combat"
                elseif buff.stealth.up then return false, "already in stealth"
                elseif buff.vanish.up then return false, "already vanished" end
                return true
            end,

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

            usable = function () return boss and group end,

            handler = function ()
                applyBuff( 'vanish', 3 )
                applyBuff( "stealth" )
            end,
        },
    } )


    -- Override this for rechecking.
    spec:RegisterAbility( "shadowmeld", {
        id = 58984,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        usable = function () return boss and group end,
        handler = function ()
            applyBuff( "shadowmeld" )
        end,
    } )


    spec:RegisterPack( "Outlaw", 20200204, [[da1MjbqirfpsvInHs8jkbAuQs1PuLYQufv9kukZcLQBjQu7sKFruzyQcDmkrldf8mkbnnIeUMQKSnvrPVjkQACIkPZrjaRJirnpvrUhkAFQcoOOsSqIupKsiMiLqDrkH0gvLu9rrrP6KucOvkQ6LejsZuuuc3uvuPDkk8tIeXqfffhvuuIwQQO4PQQPsu1vvfvSvrrf9vrrLgROOcNvuus7fv)LIbRYHPAXk8ysnzsUmYMv0NPKgTuCALwTOOuEnk0SjCBP0Ub(nOHtPoUQKYYH8COMUW1LQTlk9DusJxuKZteRNiP5tu2VK5wYLN)vEq8my4rgE8rgEukswYGfMRsHuW)HeBI)TDnJUvI)bElX)sj9q4SY)2Ueb0vC55FmSJ0e)3eHnwklNCw3OPpsAyRC4TTl8yHanYNHC4Tvlh)p6RiSab8b)R8G4zWWJm84Jm8OuKSKblmZ)kg4FSnP5zWWZ(i)3Skfb4d(xryn))sDsj9q4Sw3ZaT2Pk)l11eHnwklNCw3OPpsAyRC4TTl8yHanYNHC4TvlxL)L6EDAG6ossDsb71XWJm8yLVY)sDwKghyLWs5k)l1L76YfLIu1jLUAgRlG1POP3frDUowiOoXIJuL)L6YDD5IsrQ6SrKg2o8OoPfUIQ71fDessDVRGegybJ6giYzSUFqUiAElv5FPUCxNfdbwWOUoMQlqlGrkW1TG6Wb5IOjv5FPUCxNfdbwWOUoMQRDbs5mh1nHO6EUoIrsv3eIQZIjpAQ79nSG46aWOoC32gIcs9wQY)sD5UUCjlCv1HieuiwG16EMq66uD0cSwN0cxr196IocjPU37abHX1XkvheiKuxJNLQZY6chzLI3sv(xQl319mKWZuDsPRqSaR19TreLQ8VuxUR75GP6ITLmb0OwQUjevhb0WoiiuDeqTaR1H8OHq1fnoOUWrwPifBlzcOrTuI)TrW5ki()L6Ks6HWzTUNbATtv(xQRjcBSuwo5SUrtFK0Ww5WBBx4XcbAKpd5WBRwUk)l1960a1DKK6Kc2RJHhz4XkFL)L6SinoWkHLYv(xQl31LlkfPQtkD1mwxaRtrtVlI6CDSqqDIfhPk)l1L76YfLIu1zJinSD4rDslCfv3Rl6iKK6ExbjmWcg1nqKZyD)GCr08wQY)sD5UolgcSGrDDmvxGwaJuGRBb1HdYfrtQY)sD5UolgcSGrDDmvx7cKYzoQBcr19CDeJKQUjevNftE0u37BybX1bGrD4UTnefK6TuL)L6YDD5sw4QQdriOqSaR19mH01P6OfyToPfUIQ71fDessDV3bccJRJvQoiqiPUgplvNL1foYkfVLQ8VuxUR7ziHNP6KsxHybwR7BJikv5FPUCx3Zbt1fBlzcOrTuDtiQocOHDqqO6iGAbwRd5rdHQlACqDHJSsrk2wYeqJAPuLVY)sDw0mr6EqQ6g0eIO60W2Hh1niRlaNQlx0AYoW1bGGC34O2zxuNRJfcW1bbcjPk)l156yHaCYgrAy7WdMtHJzSY)sDUowiaNSrKg2o8GnMY5DRTei8yHGk)l156yHaCYgrAy7Wd2yk3ecvv(xQ7dCBCdmQd5RQUrFojvD4WdCDdAcruDAy7WJ6gK1fGRZbQ6SruUTHrSaR1T46uqaLQ8VuNRJfcWjBePHTdpyJPCyGBJBGHbhEGR8UowiaNSrKg2o8GnMY16igjLzcrgf5rd72isdBhEyWKgcuyMVI9DYe5RYqzjqKCLcNwWdsXJvExhleGt2isdBhEWgt5Wb5IOH9DY89COxRV22Kkzd1msbELkPmAyRDp8yHaJIYUAsMSC0qOqbzfK0s0cyGGGvBgchhjvh5XcbYKH8vzOSeisliBxaiKpeuIY0Id8BvExhleGt2isdBhEWgt5qqHWenKzabeMDBePHTdpmysdbkmtgQ8UowiaNSrKg2o8GnMYHfRMmoqzuRMy3grAy7WddM0qGcZKHkVRJfcWjBePHTdpyJPCUcraxSaYG64g2TrKg2o8WGjneOWmTK9DY89COxRV22Kkzd1msbELkPmAyRDp8yHaJIYUAsMSC0qOqbzfK0s0cyGGGvBgchhjvh5XcbYKH8vzOSeisliBxaiKpeuIY0Id8BvExhleGt2isdBhEWgt56yYSb1YoWBjMUuXnoYXMjeeg40ydzLqvExhleGt2isdBhEWgt56yYSb1YonNKomaVLyQLOfWabbR2meooyFNmZb5RYqzjqKwq2UaqiFiOeLPfh4kVRJfcWjBePHTdpyJPC2WyHGkFL)L6SOzI09Gu1rzjKK6ITLQlAO6CDar1T468S(k8HGsv(xQ7ziCqUiAQBN1zdX4DiO6EhaRlBxaiKpeuDeGAxcx3cQtdBhE8wL31XcbyMmUAgzFNmZbhKlIgsLqqRDQY76yHamtCqUiAQ8Vu3ZqiOqu3eIQJb2QB0NtCDSUrtDzwaDfPQZIxnvx3ovNus0qiwxmvhIqqHOUjevhdSvhevxMDKdu19Cjbr1br19m9OrqyCDzgePx8cbPkVRJfcWSXuUSoA9HGyh4Tetummicbfc2Z6IoXefdZOpN4NyGL3h95mjGUIug1QPu3wMSCg95mzf5aLPLeeL62SKZOpNjupAeegBSrKEXleK62Vv5FPUNHqqHOUjevhdSv3OpN46GO6EME0iimUUmdI0lEHG6yDJM6SyYv4gyuhevxUOP6621jb2r19feLLsvExhleGzJPCzD06dbXoWBjMOyyqeckeSdTzIPG9DY0LkH2GskYv4gyKiGpeKsMmxQeAdk5AY0TnsGDKbliklLiGpeKI9SUOtmrXWm6Zj(jgy59rFotcORiLrTAk1TLjB0NZeQhnccJn2isV4fcsiQ1xa(jMAiuOGScsdkyLiGjAidjHWje16la)wL)L6yGT6(aNrQolQeclLRlxeS6sW1HieuiQBcr1XaB1n6Zjov5DDSqaMnMYL1rRpee7aVLyIIHbriOqWo0MjMc23jtxQeAdkHboJKHKq4eYbm(atgypRl6etummJ(CIFIHk)l1XaB19boJuDwujewkxNfdRdaJ6qecke1X6gn1XaB1HdxZiUo4SUOHQ7dCgP6SOsiCDJ(Cw37wYwD4W1mwhRB0uN0iORWRIQRB)wQY76yHamBmLlRJwFii2bElXefddIqqHGDOnteHPG9DY0LkH2GsyGZizijeoHCaJpWKbwg95mHboJKHKq4eoCnJpWKHCp6ZzAGGUcVkk1TR8VuxM7gn1jTWvuDVUOJqsQRBZEDRvaer1H6ccxNpGzP6CGQUWzKQJYsijrZcSwx04rDlUogyRU3bWOonSdIfyTUVBrERoiQo8cSkO6K(ZEDz2FUSx3ZKzQ8UowiaZgt5Y6O1hcIDG3smrXWGieuiyhAZetb77K5OpNPHWvKzk6iKKu3M9SUOtmrXWm6Zjo3J(CMWm2fcJdugncIXdiGWPU9tmWY7J(CMeqxrkJA1uQBltwoJ(CMSICGY0scIsDBwYz0NZeQhnccJn2isV4fcsDBwYz0NZ0abDfEvuQB)wL31Xcby2ykxwhT(qqSd8wIP3o64gJgcuBSqa7zDrNyQHTdOXgUGaNu0C1B8atgyJHN)9WfeiswBG4qiXGd0YiLiGpeKIfnekuqwbjRnqCiKyWbAzKsiQ1xa(jlFJTrFotde0v4vrPUnleGqwL8WZ(il5m6ZzcZyximoqz0iigpGacN62SKZOpNjgjY2ib2rgw3aB8bShgjWEQBx5DDSqaMnMYL1rRpee7aVLyocYOHa1gleWEwx0jMJ(CMq9OrqySXgr6fVqqQBlt27Uuj0gusrUc3aJeb8HGuYK5sLqBqjxtMUTrcSJmybrzPeb8HGuVXYOpNjeuimrdzgqaHtD7k)l1L5UrtDTDrS2cQUWrwPaZEDrZIRlRJwFiO6wCD6gsZiPQlG1Pi9QO6yTHIgcvhg2s1zrSyCD4gyxOQBq1HLa0KQow3OPoPfUIQ71fDessL31Xcby2ykxwhT(qqSd8wI5q4kYmfDesIblbOzpRl6etSnjeMWrwPaNgcxrMPOJqsEIbwq(QmuwcejxPWPf8adpkt2OpNPHWvKzk6iKKu3UY76yHamBmLt7cHX1XcbgXId2bElXehKlIg23jtCqUiAivYfIkVRJfcWSXuoTlegxhleyeloyh4TetTcx5FPUxFblUPopQR1Z022BRZIKzs197dCGCDuheq1nHO6ix3uN0iORWRIQZbQ6KsSTHOOd2qsDS2qG6YSSVAgRZIroR1T46WKG0bPQZbQ6EUtlUUfxhag1HixjPoFgeQUOHQdqzkQdtAiqLQlxeS6sW116zQoPdlADSUrtDmWwD5IMsvExhleGzJPCOoW46yHaJyXb7aVLyoxWIByFNm1W2b0ydxqGFGP2206zYGTjGk3Vp6ZzAGGUcVkk1TzB0NZe02gIIoydjPU9Bp)7HliqKET(Qz0OqoRjc4dbPy59CcxqGi16igjLzcrgf5rtIa(qqkzY0qOqbzfKADeJKYmHiJI8OjHOwFb4hS8T3E(3DPsOnOKRjt32ib2rgSGOSuc5agFIbzYYrdHcfKvqAqbRebmrdzijeo1TLjlNrFotiOqyIgYmGacN62Vv5DDSqaMnMYPDHW46yHaJyXb7aVLyo6Rqv5DDSqaMnMY5iTditariceSVtMeGqwLKu0C1B8atlFfBeGqwLKqKvcu5DDSqaMnMY5iTdiJDxGPkVRJfcWSXuoXATjWMmBDL1wcevExhleGzJPCd3QbonbA1mIR8UowiaZgt5uuq6yHa23jt616RTnPsKUbUaRMSWvjtg9A912Mujs3axGvtw4QmWMkFL)L6KUVcfHWv(xQ75GP6YmloGI6(nWOUDw3g1XkeybJ60UDDAy7awNnCbbUohOQlAO6KsSTHrhSHK6g95SUfxx3ovxUKfUQ664fyTowBiqDsPezxxMvyhvxM7g46WHRzexNJO6AwRn11bccJRlAO6SyYv4gyu3OpN1T46Cbgwx3ov5DDSqaon6RqX0EXbuyWnWG9DYC0NZe02gIIoydjPUnlVp6ZzIrISnsGDKH1nWgFa7HrcSNWHRz8jlLczYg95mPixHBGrQBltgbiKvjpjfV6TkVRJfcWPrFfk2ykhEbloiKbhOLrQYx5FPolcekuqwb4kVRJfcWjTcZu7cHX1XcbgXId2bElXKWycOjm77Kzo4GCr0qQKlevExhleGtAfMnMY5kebCXcidQJByFNmZz0NZKRqeWflGmOoUj1TzHaeYQKuSTKjGMwptpyjlVNd9A912MujxQ4gh5yZeccdCASHSsizY0qOqbzfKeEqGW4iTd8eIA9fGFGHhFRY)sDwGZ6CLcxNJO662SxhgS2uDrdvheq1X6gn1jGSs4Oo5L3It19CWuDS2qG6uswG16MooiuDrJdQZIKzQtrZvVrDquDSUrdSh15aj1zrYmPkVRJfcWjTcZgt5ADeJKYmHiJI8OHDTeTGmHJSsbMPLSVtMiFvgklbIKRu4u3ML3dhzLIuSTKjGg1spPHTdOXgUGaNu0C1Bitwo4GCr0qQecATtSOHTdOXgUGaNu0C1B8atTTP1ZKbBtavUT8Tk)l1zboRdaRZvkCDSUcrDQLQJ1nAwqDrdvhGYuuNf(iM966yQUN70IRdcQBaX46yDJgypQZbsQZIKzsvExhleGtAfMnMY16igjLzcrgf5rd77KjYxLHYsGi5kfoTGhSWhZnYxLHYsGi5kfoP6ipwiGLCWb5IOHuje0ANyrdBhqJnCbboPO5Q34bMABtRNjd2MaQCBzL)L6Kw4kQUxx0rij1bb1XaB1raQDjCQUm3nAQZvkSuUUNdMQBN1fnKK6WHlPUjevxUYwDysdbkCDquD7SojWoQoaLPOoDJJSs1X6ke1nO6qKRKu3cQl2wQUjevx0q1bOmf1XQNLsvExhleGtAfMnMYneUImtrhHKW(ozITjHWeoYkf4hyYal5m6ZzAiCfzMIocjj1Tz59Cq(QmuwcejxPWjktloWYKH8vzOSeisUsHtiQ1xa(HCvMmKVkdLLarYvkCAbp8od5wdHcfKvqAiCfzMIocjjPBCKvcBMixhle4I3EEgE1BvExhleGtAfMnMYzTbIdHedoqlJe77KzwhT(qqPHWvKzk6iKedwcqZIg2oGgB4ccCsrZvVXdmTKTrFotde0v4vrPUDL31Xcb4KwHzJPCmUcXcSAW2iIyFNmZ6O1hckneUImtrhHKyWsaAwENaeYQKuSTKjGMwptp8kzYiaHSk5jlF1BvExhleGtAfMnMYneUImOoUH9DYmRJwFiO0q4kYmfDesIblbOzHaeYQKuSTKjGMwptpyzL)L6Eo4fyTUmNoyXnYLlTJoUPUfxheiKuNxxwcjPUybsQBbAe5yI96WW6wqDiYfBiH96Ka7wqevNpWqrpiHK6MlGQlG11XuDBuNJRZRRhRydj1HTjHiv5DDSqaoPvy2ykxwhS4g23jZCWb5IOHujxiyjRJwFiOK3o64gJgcuBSqqL31Xcb4KwHzJPC4gxbzTLek23jZCWb5IOHujxiyjRJwFiOK3o64gJgcuBSqqL31Xcb4KwHzJPC2WyHa23jZrFotdbeQeDCKqKRdzYg95m5kebCXcidQJBsD7k)l196UqSaR1nCnJ1fW6u007IOUnO266y3kv5DDSqaoPvy2ykxhtMnOw2bElXmRJwFiiZcccG3qIX6A1ZcfHbI1Rq4XcSAqKRdiI9DYC0NZ0qaHkrhhje56qMSyBjtanQLEIjdpktMg2oGgB4ccCsrZvVXtmzOY76yHaCsRWSXuUoMmBqTy23jZrFotdbeQeDCKqKRdzYITLmb0Ow6jMm8OmzAy7aASHliWjfnx9gpXKHkVRJfcWjTcZgt5gciuzMDKKkVRJfcWjTcZgt5gectigxG1kVRJfcWjTcZgt5MlIgciuv5DDSqaoPvy2ykNd0eoqUWODHOY76yHaCsRWSXuUoMmBqTStZjPddWBjMAjAbmqqWQndHJd23jZCWb5IOHujxiyz0NZKRqeWflGmOoUjPGScyz0NZul1crsmWPr01RYOqK3ItkiRawiaHSkjfBlzcOP1Z0dsblOyyg95e)0RQ8UowiaN0kmBmLRJjZgul7aVLy6sf34ihBMqqyGtJnKvcX(ozMZOpNjxHiGlwazqDCtQBZsoJ(CMgcxrMPOJqssDBw0qOqbzfKCfIaUybKb1Xnje16la)KLVQY)sDzojKK6qWU1gHK6qDbvhCwx00Bh7CjvDTE0GRBqciRs56EoyQUjevNfiGrBOQonAd2RdgneI1ft1X6gn1LlptDEuhdpYwD4W1mIRdIQZYhzRow3OPoxGH1jTacv11TtvExhleGtAfMnMY1XKzdQLDG3smDCtwhqydYLkez0qKlyFNmv0OpNjKlviYOHixyu0OpNjfKvGmzkA0NZKgcuDDSzjZcy0OOrFotDBwchzLIud5IOjzRJNSqgyjCKvksnKlIMKToEGPf(Omz5OOrFotAiq11XMLmlGrJIg95m1Tz5Dfn6Zzc5sfImAiYfgfn6ZzchUMXhyYWJ52YhFEfn6ZzAiGqLbonrdzia1kj1TLjlCKvksX2sMaAul90Z(4BSm6ZzYvic4Ifqguh3KquRVa8dwMRv(xQZIPP3frDtxigUMX6MquDDSpeuDBqT4uL31Xcb4KwHzJPCDmz2GAXSVtMJ(CMgciuj64iHixhYKfBlzcOrT0tmz4rzY0W2b0ydxqGtkAU6nEIjdv(k)l1zrXycOjCL31Xcb4eHXeqtyMAiqtGa5bPmtH3sSVtMeGqwLKITLmb006z6blzjNrFotdHRiZu0rijPUnlVNJcgjneOjqG8GuMPWBjZOJaPy1mUaRSKJRJfcsAiqtGa5bPmtH3sPfyMI1Atit2SlegePBCKvYeBl9KvTk16z6TkVRJfcWjcJjGMWSXuUHacvg40enKHauRe23jZSoA9HGsdHRiZu0rijgSeGMfnekuqwbPbfSseWenKHKq4u3MLSoA9HGsJGmAiqTXcbvExhleGtegtanHzJPCw7osToWaNgxQecgnvExhleGtegtanHzJPCtOUJjLXLkH2GmdYBzFNmX2KqychzLcCAiCfzMIocj5bMmitgYxLHYsGi5kfoTGhE2hzjNrFotUcraxSaYG64Mu3UY76yHaCIWycOjmBmLZUJ2PKfy1meooyFNmX2KqychzLcCAiCfzMIocj5bMmitgYxLHYsGi5kfoTGhE2hR8UowiaNimMaAcZgt5IgY0bdyhOmtistSVtMJ(CMqKMrbHXMjePPu3wMSrFotisZOGWyZeI0Krd7GGqjC4AgFYYhR8UowiaNimMaAcZgt5qRTTGmlWGTDnv5DDSqaorymb0eMnMYXkejuzPfyqegcCGMQ8UowiaNimMaAcZgt5APwisIbonIUEvgfI8wm77KjbiKvjpjfVQY76yHaCIWycOjmBmLdrU9cSAMcVLWSVtMHJSsrQHCr0KS1Xd56JYKfoYkfPgYfrtYwhpXKHhLjlCKvksX2sMaAS1HHHhFWcFSYx5FPUxFblUHq4k)l1jDyrRdMLq19mH01HieuiW1X6gn1zXKRWnWqUCrt1fiFdCDquDptpAeegxxMbr6fVqqQY76yHaCAUGf3WCqbRebmrdzijeM9DYmRJwFiO0iiJgcuBSqqL31Xcb40CblUHnMYHfRMmoqzuRMyFNmh95mHfRMmoqzuRMsiQ1xa(PyBjtanQLyz0NZewSAY4aLrTAkHOwFb4NE3s20W2b0ydxqGF75TmLRvExhleGtZfS4g2ykhckeMOHmdiGWSVtMJ(CMqqHWenKzabeoHOwFb4NyAHYKL1rRpeucfddIqqHOY)sDshw06yDJM6IgQUCrt19CSRlZkSJQ7liklvhevNftUc3aJ6cKVbov5DDSqaonxWIByJPCdkyLiGjAidjHWSVtMUuj0guY1KPBBKa7idwquwkraFiiLmzUuj0gusrUc3aJeb8HGuvExhleGtZfS4g2ykNAX2EOBQ8v(xQ7hKlIMkVRJfcWjCqUiAy6TJoUH)Zsi8cb8my4rgE8rlzqk4FwDeybwX8VfyRnefKQUmFDUowiOoXIdCQYZ)IfhyU88pHXeqtyU88mSKlp)taFiifxA(xJ2GqRZ)eGqwLKITLmb006zQUhQZY6yPUCQB0NZ0q4kYmfDessQBxhl19ED5uNcgjneOjqG8GuMPWBjZOJaPy1mUaR1XsD5uNRJfcsAiqtGa5bPmtH3sPfyMI1AtuNmz1n7cHbr6ghzLmX2s19uDw1QuRNP6EJ)DDSqa)RHanbcKhKYmfElXdEgmWLN)jGpeKIln)RrBqO15)SoA9HGsdHRiZu0rijgSeGUowQtdHcfKvqAqbRebmrdzijeo1TRJL6Y6O1hckncYOHa1gleW)UowiG)hciuzGtt0qgcqTs4bpdlKlp)76yHa(3A3rQ1bg404sLqWOH)jGpeKIlnp4zifC55Fc4dbP4sZ)A0geAD(hBtcHjCKvkWPHWvKzk6iKK6EGzDmuNmz1H8vzOSeisUsHtlOUhQ7zFSowQlN6g95m5kebCXcidQJBsDB(31Xcb8)eQ7yszCPsOniZG8wEWZ4vC55Fc4dbP4sZ)A0geAD(hBtcHjCKvkWPHWvKzk6iKK6EGzDmuNmz1H8vzOSeisUsHtlOUhQ7zFK)DDSqa)B3r7uYcSAgchh8GNXZYLN)jGpeKIln)RrBqO15)rFotisZOGWyZeI0uQBxNmz1n6ZzcrAgfegBMqKMmAyheekHdxZyDpvNLpY)UowiG)JgY0bdyhOmtist8GNrMNlp)76yHa(hT22cYSad221e)taFiifxAEWZix5YZ)UowiG)zfIeQS0cmicdboqt8pb8HGuCP5bpdlaU88pb8HGuCP5FnAdcTo)taczvsDpvNu8k(31Xcb8Fl1crsmWPr01RYOqK3I5bpdlFKlp)taFiifxA(xJ2GqRZ)HJSsrQHCr0KS1rDpuxU(yDYKvx4iRuKAixenjBDu3tmRJHhRtMS6chzLIuSTKjGgBDyy4X6EOol8r(31Xcb8pIC7fy1mfElH5bp4Ffn9Ui4YZZWsU88pb8HGuCP5FnAdcTo)NtD4GCr0qQecATt8VRJfc4FgxnJ8GNbdC55FxhleW)4GCr0W)eWhcsXLMh8mSqU88pb8HGuCP5FOn)JPG)DDSqa)N1rRpee)N1fDI)rXWm6ZjUUNQJH6yPU3RB0NZKa6kszuRMsD76KjRUCQB0NZKvKduMwsquQBxhl1LtDJ(CMq9OrqySXgr6fVqqQBx3B8FwhzaElX)Oyyqecke8GNHuWLN)jGpeKIln)dT5Fmf8VRJfc4)SoA9HG4)SUOt8pkgMrFoX19uDmuhl19EDJ(CMeqxrkJA1uQBxNmz1n6Zzc1JgbHXgBePx8cbje16lax3tmRtdHcfKvqAqbRebmrdzijeoHOwFb46EJ)1Oni068VlvcTbLuKRWnWiraFiivDYKvNlvcTbLCnz62gjWoYGfeLLseWhcsX)zDKb4Te)JIHbriOqWdEgVIlp)taFiifxA(hAZ)yk4FxhleW)zD06dbX)zDrN4FummJ(CIR7P6yG)1Oni068VlvcTbLWaNrYqsiCc5agR7bM1Xa)N1rgG3s8pkggeHGcbp4z8SC55Fc4dbP4sZ)qB(hryk4FxhleW)zD06dbX)zDKb4Te)JIHbriOqW)A0geAD(3LkH2GsyGZizijeoHCaJ19aZ6yOowQB0NZeg4msgscHt4W1mw3dmRJH6YDDJ(CMgiORWRIsDBEWZiZZLN)jGpeKIln)dT5Fmf8VRJfc4)SoA9HG4)SUOt8pkgMrFoX1L76g95mHzSleghOmAeeJhqaHtD76EQogQJL6EVUrFotcORiLrTAk1TRtMS6YPUrFotwroqzAjbrPUDDSuxo1n6Zzc1JgbHXgBePx8cbPUDDSuxo1n6ZzAGGUcVkk1TR7n(xJ2GqRZ)J(CMgcxrMPOJqssDB(pRJmaVL4FummicbfcEWZix5YZ)eWhcsXLM)H28pMc(31Xcb8FwhT(qq8Fwx0j(xdBhqJnCbboPO5Q3OUhywhd1XwDmu3Zx371fUGarYAdehcjgCGwgPeb8HGu1XsDAiuOGScswBG4qiXGd0YiLquRVaCDpvNL19wDSv3OpNPbc6k8QOu3UowQJaeYQK6EOUN9X6yPUCQB0NZeMXUqyCGYOrqmEabeo1TRJL6YPUrFotmsKTrcSJmSUb24dypmsG9u3M)Z6idWBj(3BhDCJrdbQnwiGh8mSa4YZ)eWhcsXLM)H28pMc(31Xcb8FwhT(qq8Fwx0j(F0NZeQhnccJn2isV4fcsD76KjRU3RZLkH2GskYv4gyKiGpeKQozYQZLkH2GsUMmDBJeyhzWcIYsjc4dbPQ7T6yPUrFotiOqyIgYmGacN628FwhzaElX)JGmAiqTXcb8GNHLpYLN)jGpeKIln)dT5Fmf8VRJfc4)SoA9HG4)SUOt8p2Mect4iRuGtdHRiZu0rij19uDmuhl1H8vzOSeisUsHtlOUhQJHhRtMS6g95mneUImtrhHKK628FwhzaElX)dHRiZu0rijgSeGMh8mS0sU88pb8HGuCP5FnAdcTo)JdYfrdPsUqW)UowiG)1UqyCDSqGrS4G)flomaVL4FCqUiA4bpdlzGlp)taFiifxA(31Xcb8V2fcJRJfcmIfh8VyXHb4Te)RvyEWZWslKlp)taFiifxA(xJ2GqRZ)Ay7aASHliW19aZ602MwptgSnbu1L76EVUrFotde0v4vrPUDDSv3OpNjOTnefDWgssD76ERUNVU3RlCbbI0R1xnJgfYznraFiivDSu371LtDHliqKADeJKYmHiJI8OjraFiivDYKvNgcfkiRGuRJyKuMjezuKhnje16lax3d1zzDVv3B19819EDUuj0guY1KPBBKa7idwquwkHCaJ19uDmuNmz1LtDAiuOGScsdkyLiGjAidjHWPUDDYKvxo1n6Zzcbfct0qMbeq4u3UU34FxhleW)OoW46yHaJyXb)lwCyaElX)ZfS4gEWZWsPGlp)taFiifxA(31Xcb8V2fcJRJfcmIfh8VyXHb4Te)p6RqXdEgw(kU88pb8HGuCP5FnAdcTo)taczvssrZvVrDpWSolFvDSvhbiKvjjezLa8VRJfc4FhPDazcicrGGh8mS8z5YZ)UowiG)DK2bKXUlWe)taFiifxAEWZWYmpxE(31Xcb8VyT2eytMTUYAlbc(Na(qqkU08GNHL5kxE(31Xcb8)WTAGttGwnJy(Na(qqkU08GNHLwaC55Fc4dbP4sZ)A0geAD(NET(ABtQePBGlWQjlCv1jtwD0R1xBBsLiDdCbwnzHRYaB4FxhleW)kkiDSqap4b)BJinSD4bxEEgwYLN)jGpeKIln)76yHa(V1rmskZeImkYJg(xJ2GqRZ)iFvgklbIKRu40cQ7H6KIh5FBePHTdpmysdbkm))kEWZGbU88pb8HGuCP5FnAdcTo))ED5uh9A912MujBOMrkWRujLrdBT7Hhleyuu2vt1jtwD5uNgcfkiRGKwIwadeeSAZq44iP6ipwiOozYQd5RYqzjqKwq2UaqiFiOeLPfh46EJ)DDSqa)JdYfrdp4zyHC55Fc4dbP4sZ)UowiG)rqHWenKzabeM)TrKg2o8WGjneOW8pd8GNHuWLN)jGpeKIln)76yHa(hlwnzCGYOwnX)2isdBhEyWKgcuy(NbEWZ4vC55Fc4dbP4sZ)UowiG)DfIaUybKb1Xn8VgTbHwN)FVUCQJET(ABtQKnuZif4vQKYOHT29WJfcmkk7QP6KjRUCQtdHcfKvqslrlGbccwTziCCKuDKhleuNmz1H8vzOSeisliBxaiKpeuIY0IdCDVX)2isdBhEyWKgcuy(3sEWZ4z5YZ)eWhcsXLM)bElX)UuXnoYXMjeeg40ydzLq8VRJfc4FxQ4gh5yZeccdCASHSsiEWZiZZLN)jGpeKIln)76yHa(xlrlGbccwTziCCW)A0geAD(pN6q(QmuwcePfKTlaeYhckrzAXbM)P5K0Hb4Te)RLOfWabbR2meoo4bpJCLlp)76yHa(3ggleW)eWhcsXLMh8G)h9vO4YZZWsU88pb8HGuCP5FnAdcTo)p6ZzcABdrrhSHKu3UowQ796g95mXir2gjWoYW6gyJpG9Wib2t4W1mw3t1zPuuNmz1n6ZzsrUc3aJu3UozYQJaeYQK6EQoP4v19g)76yHa(3EXbuyWnWGh8myGlp)76yHa(hVGfheYGd0YiX)eWhcsXLMh8G)Xb5IOHlppdl5YZ)UowiG)92rh3W)eWhcsXLMh8G)1kmxEEgwYLN)jGpeKIln)RrBqO15)CQdhKlIgsLCHG)DDSqa)RDHW46yHaJyXb)lwCyaElX)egtanH5bpdg4YZ)eWhcsXLM)1Oni068Fo1n6ZzYvic4Ifqguh3K621XsDeGqwLKITLmb006zQUhQZY6yPU3RlN6OxRV22Kk5sf34ihBMqqyGtJnKvcvNmz1PHqHcYkij8GaHXrAh4je16lax3d1XWJ19g)76yHa(3vic4Ifqguh3WdEgwixE(Na(qqkU08VRJfc4)whXiPmtiYOipA4FnAdcTo)J8vzOSeisUsHtD76yPU3RlCKvksX2sMaAulv3t1PHTdOXgUGaNu0C1BuNmz1LtD4GCr0qQecATt1XsDAy7aASHliWjfnx9g19aZ602MwptgSnbu1L76SSU34FTeTGmHJSsbMNHL8GNHuWLN)jGpeKIln)RrBqO15FKVkdLLarYvkCAb19qDw4J1L76q(QmuwcejxPWjvh5Xcb1XsD5uhoixenKkHGw7uDSuNg2oGgB4ccCsrZvVrDpWSoTTP1ZKbBtavD5Uol5FxhleW)ToIrszMqKrrE0WdEgVIlp)taFiifxA(xJ2GqRZ)yBsimHJSsbUUhywhd1XsD5u3OpNPHWvKzk6iKKu3UowQ796YPoKVkdLLarYvkCIY0IdCDYKvhYxLHYsGi5kfoHOwFb46EOUCTozYQd5RYqzjqKCLcNwqDpu371XqD5UonekuqwbPHWvKzk6iKKKUXrwjSzICDSqGlQ7T6E(6y4v19g)76yHa(FiCfzMIocjHh8mEwU88pb8HGuCP5FnAdcTo)N1rRpeuAiCfzMIocjXGLa01XsDAy7aASHliWjfnx9g19aZ6SSo2QB0NZ0abDfEvuQBZ)UowiG)T2aXHqIbhOLrIh8mY8C55Fc4dbP4sZ)A0geAD(pRJwFiO0q4kYmfDesIblbORJL6EVocqiRssX2sMaAA9mv3d19Q6KjRocqiRsQ7P6S8v19g)76yHa(NXviwGvd2grep4zKRC55Fc4dbP4sZ)A0geAD(pRJwFiO0q4kYmfDesIblbORJL6iaHSkjfBlzcOP1ZuDpuNL8VRJfc4)HWvKb1Xn8GNHfaxE(Na(qqkU08VgTbHwN)ZPoCqUiAivYfI6yPUSoA9HGsE7OJBmAiqTXcb8VRJfc4)SoyXn8GNHLpYLN)jGpeKIln)RrBqO15)CQdhKlIgsLCHOowQlRJwFiOK3o64gJgcuBSqa)76yHa(h34kiRTKqXdEgwAjxE(Na(qqkU08VgTbHwN)h95mneqOs0XrcrUoQtMS6g95m5kebCXcidQJBsDB(31Xcb8VnmwiGh8mSKbU88pb8HGuCP5FxhleW)zD06dbzwqqa8gsmwxREwOimqSEfcpwGvdICDar8VgTbHwN)h95mneqOs0XrcrUoQtMS6ITLmb0OwQUNywhdpwNmz1PHTdOXgUGaNu0C1Bu3tmRJb(h4Te)N1rRpeKzbbbWBiXyDT6zHIWaX6vi8ybwniY1beXdEgwAHC55Fc4dbP4sZ)A0geAD(F0NZ0qaHkrhhje56OozYQl2wYeqJAP6EIzDm8yDYKvNg2oGgB4ccCsrZvVrDpXSog4FxhleW)Dmz2GAX8GNHLsbxE(31Xcb8)qaHkZSJKW)eWhcsXLMh8mS8vC55FxhleW)dcHjeJlWk)taFiifxAEWZWYNLlp)76yHa(FUiAiGqf)taFiifxAEWZWYmpxE(31Xcb8Vd0eoqUWODHG)jGpeKIlnp4zyzUYLN)jGpeKIln)76yHa(xlrlGbccwTziCCW)A0geAD(pN6Wb5IOHujxiQJL6g95m5kebCXcidQJBskiRG6yPUrFotTulejXaNgrxVkJcrEloPGScQJL6iaHSkjfBlzcOP1ZuDpuNuuhl1HIHz0NtCDpv3R4FAojDyaElX)AjAbmqqWQndHJdEWZWslaU88pb8HGuCP5FxhleW)UuXnoYXMjeeg40ydzLq8VgTbHwN)ZPUrFotUcraxSaYG64Mu3UowQlN6g95mneUImtrhHKK621XsDAiuOGScsUcraxSaYG64MeIA9fGR7P6S8v8pWBj(3LkUXro2mHGWaNgBiReIh8my4rU88pb8HGuCP5FxhleW)oUjRdiSb5sfImAiYf8VgTbHwN)v0OpNjKlviYOHixyu0OpNjfKvqDYKvNIg95mPHavxhBwYSagnkA0NZu3UowQlCKvksnKlIMKToQ7P6SqgQJL6chzLIud5IOjzRJ6EGzDw4J1jtwD5uNIg95mPHavxhBwYSagnkA0NZu3UowQ796u0OpNjKlviYOHixyu0OpNjC4AgR7bM1XWJ1L76S8X6E(6u0OpNPHacvg40enKHauRKu3UozYQlCKvksX2sMaAulv3t19Spw3B1XsDJ(CMCfIaUybKb1Xnje16lax3d1zzUY)aVL4Fh3K1be2GCPcrgne5cEWZGbl5YZ)eWhcsXLM)1Oni068)OpNPHacvIoosiY1rDYKvxSTKjGg1s19eZ6y4X6KjRonSDan2Wfe4KIMREJ6EIzDmW)UowiG)7yYSb1I5bp4)5cwCdxEEgwYLN)jGpeKIln)RrBqO15)SoA9HGsJGmAiqTXcb8VRJfc4)bfSseWenKHKqyEWZGbU88pb8HGuCP5FnAdcTo)p6ZzclwnzCGYOwnLquRVaCDpvxSTKjGg1s1XsDJ(CMWIvtghOmQvtje16lax3t19EDwwhB1PHTdOXgUGax3B1981zzkx5FxhleW)yXQjJdug1QjEWZWc5YZ)eWhcsXLM)1Oni068)OpNjeuimrdzgqaHtiQ1xaUUNywNfwNmz1L1rRpeucfddIqqHG)DDSqa)JGcHjAiZacimp4zifC55Fc4dbP4sZ)A0geAD(3LkH2GsUMmDBJeyhzWcIYsjc4dbPQtMS6CPsOnOKICfUbgjc4dbP4FxhleW)dkyLiGjAidjHW8GNXR4YZ)UowiG)vl22dDd)taFiifxAEWdEW)EpAGi()VTweEWdoh]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "potion_of_unbridled_fury",

        package = "Outlaw",
    } )

end