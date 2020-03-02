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

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
            end,

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


    spec:RegisterPack( "Outlaw", 20200301, [[d8enjbqirfpsvInHs8jIKyuOioLQKwfks6vOunlus3suP2Li)IOYWev1XOewgkQNrKutJsKUMQOSnkr5BIkHXPkQCokPsTouKY8uf5EOW(ev5GIkPfsK6HejPjsjQUiLuXgPeHpIIevNefPQvQk8skrKBIIe2jLKFIIuzOusvDuuKOSuvrvpvvnvIQUQOs0wPer5ROirglLiQolLujTxu9xkgSkhMQfRWJj1Kj5YiBwrFwuA0sXPvA1usL41QsnBc3wkTBGFdA4uQJtjvz5qEoutx46s12ffFhLY4PKY5jI1tKy(eL9lzUfC55FLhe3kMZN58ZxQZ3IKfww(m)SCb)hsSj(321V9Se)d8wI)z66HWzJ)TDjcOR4YZ)yyhPj(VjcBmtto5YUrtFK0Ww5WBBx4XcbAKpd5WBRwo(F0xrW0d4d(x5bXTI58zo)8L68TizHLLpZp7z8p2M0CRy2YYN)BwLIa8b)RiSM)FPoMUEiC2Q75Hz7u94L6AIWgZ0KtUSB00hjnSvo822fESqGg5Zqo82QLRE8sDmfos3uNfSwhZ5ZC(1J6Xl1jvBCqwcZ0QhVuxURlxvksvNL0QFxxaRtrtVlI6CDSqqDIfhP6Xl1L76YvLIu1zJinSD4rDslCfvNLq0rij1XefKWaPsu3ar(76(b5IO51u94L6YDDwoeivI66yQUaTG3uGRBb1HdYfrtQE8sD5UolhcKkrDDmvx7cyAwYRBcr1Xu4O3KQUjevNLtE0uht2qQGRdaJ6WDBBiki1RP6Xl1L76Y1mWvvhIqqHybzR75dPRt1rliBDslCfvNLq0rij1XKoqqyCDSr1bbcj114zO6SOUWrzP41u94L6YDDppjCRvNL0keliBDFBerP6Xl1L76YLyQUyBjtanQLQBcr1ranSdccvhbuliBDipAiuDrJdQlCuwksX2sMaAulL4FBeCUcI)FPoMUEiC2Q75Hz7u94L6AIWgZ0KtUSB00hjnSvo822fESqGg5Zqo82QLRE8sDmfos3uNfSwhZ5ZC(1J6Xl1jvBCqwcZ0QhVuxURlxvksvNL0QFxxaRtrtVlI6CDSqqDIfhP6Xl1L76YvLIu1zJinSD4rDslCfvNLq0rij1XefKWaPsu3ar(76(b5IO51u94L6YDDwoeivI66yQUaTG3uGRBb1HdYfrtQE8sD5UolhcKkrDDmvx7cyAwYRBcr1Xu4O3KQUjevNLtE0uht2qQGRdaJ6WDBBiki1RP6Xl1L76Y1mWvvhIqqHybzR75dPRt1rliBDslCfvNLq0rij1XKoqqyCDSr1bbcj114zO6SOUWrzP41u94L6YDDppjCRvNL0keliBDFBerP6Xl1L76YLyQUyBjtanQLQBcr1ranSdccvhbuliBDipAiuDrJdQlCuwksX2sMaAulLQh1JxQZ6yns3dsv3GMqevNg2o8OUbLDb4uD5Qwt2bUoaeK7gh1o7I6CDSqaUoiqijvpEPoxhleGt2isdBhEWykC876Xl156yHaCYgrAy7Wd2ziN3Z2sGWJfcQhVuNRJfcWjBePHTdpyNHCtiuvpEPUpWTXnWOoKVQ6g95Ku1HdpW1nOjer1PHTdpQBqzxaUohOQZgr52ggXcYw3IRtbbuQE8sDUowiaNSrKg2o8GDgYHbUnUbggC4bUE46yHaCYgrAy7Wd2zixRJEtkZeImkYJgwTrKg2o8WGjneOWmEgR7KbYxLHYqGi5kfoTG8S08RhUowiaNSrKg2o8GDgYHdYfrdR7KbtYHSE912MujBO(nf4vkKYOHT29WJfcmkkZQjzYYrdHcfKnqslrlGbccwTziCCKuDKhleitgYxLHYqGiTGmDbGq(qqjYAloWVwpCDSqaozJinSD4b7mKdbfct0qMbeqywTrKg2o8WGjneOWmyUE46yHaCYgrAy7Wd2zihwSAY4aLrTAIvBePHTdpmysdbkmdMRhUowiaNSrKg2o8GDgY5kebCXcidQJBy1grAy7WddM0qGcZWcw3jdMKdz96RTnPs2q9BkWRuiLrdBT7HhleyuuMvtYKLJgcfkiBGKwIwadeeSAZq44iP6ipwiqMmKVkdLHarAbz6caH8HGsK1wCGFTE46yHaCYgrAy7Wd2zixhtMnOwwbElXWLcUXro2mHGWaNgBiBeQE46yHaCYgrAy7Wd2zixhtMnOwwP5K0Hb4TedTeTagiiy1MHWXbR7KroiFvgkdbI0cY0fac5dbLiRT4axpCDSqaozJinSD4b7mKZggleupQhVuN1XAKUhKQokdHKuxSTuDrdvNRdiQUfxNNXxHpeuQE8sDppHdYfrtD7SoBigVdbvhtaW6Y0fac5dbvhbO2LW1TG60W2HhVwpCDSqaMX7v)M1DYihCqUiAivcbZ2P6HRJfcWmWb5IOPE8sDppHGcrDtiQoMzVUrFoX1br1jnc6k8QO6yBJM6SCYv4gyKQhUowiaZod5Y4O1hcIvG3smqXWGieuiyfAZatbR7KHlfcTbLuKRWnWiraFiifRzCrNyGIHz0Nt8tmZctg95mjGUIug1QPu3wMSCg95mnqqxHxfL62VwpEPUNNqqHOUjevhZSx3OpN46GO6E(E0iimUoRpI0lEHG6yBJM6Yvnvx3UojWoQUVGOmeR11bccJRlAievNJO6AHiQolNCfUbg1HCWBCQE46yHam7mKlJJwFiiwbElXafddIqqHGvOndmfSUtgUui0guY1KPBBKa7idwqugkraFiiflUui0guY1KPBBKa7idwqugkHCW78y4sHqBqjf5kCdmsih8M1mUOtmqXWm6Zj(jMzHjJ(CMeqxrkJA1uQBlt2OpNjupAeegBSrKEXleKquRVa8tm0qOqbzdKguWgrat0qgscHtiQ1xa(16Xl1Xm719b(BQoRJecZ0QlxfS5sW1HieuiQBcr1Xm71n6ZjovpCDSqaMDgYLXrRpeeRaVLyGIHbriOqWk0MbMcw3jdxkeAdkHb(BYqsiCc5G35XGzwZ4IoXafdZOpN4NyUE8sDmZEDFG)MQZ6iHWmT6SCyDayuhIqqHOo22OPoMzVoC46346GZ6IgQUpWFt1zDKq46g95SoMyb71Hdx)Uo22OPoPrqxHxfvx3(1u9W1Xcby2zixghT(qqSc8wIbkggeHGcbRqBgictbR7KHlfcTbLWa)nzijeoHCW78yWmlJ(CMWa)nzijeoHdx)opgmN7rFotde0v4vrPUD94L6ykTrtDslCfvNLq0rij11TzTUnlaIO6qDbHRZhWmuDoqvx4VP6Omess0SGS1fnEu3IRJz2RJjayuNg2bXcYw33LQVwhevhEbzfuDs)zToMYzkyTUN36xpCDSqaMDgYLXrRpeeRaVLyGIHbriOqWk0MbMcw3jJrFotdHRiZu0rijPUnRzCrNyGIHz0NtCUh95mHF3fcJdugncIXdiGWPU9tmZctg95mjGUIug1QPu3wMSCg95mLf5aLPLeeL62SKZOpNjupAeegBSrKEXleK62SKZOpNPbc6k8QOu3(16HRJfcWSZqUmoA9HGyf4TedVD0XngneO2yHawZ4IoXqdBhqJnCbboPO5Q3ipgmZoZmvMeUGarkBdehcjgCG23uIa(qqkw0qOqbzdKY2aXHqIbhO9nLquRVa8tw8k7J(CMgiORWRIsDBwiaHYkjpllFwYz0NZe(Dximoqz0iigpGacN62SKZOpNP3ezBKa7idBBGn(a2dJeyp1TRhUowiaZod5Y4O1hcIvG3smgbz0qGAJfcynJl6eJrFotOE0iim2yJi9Ixii1TLjJjUui0gusrUc3aJeb8HGuYK5sHqBqjxtMUTrcSJmybrzOeb8HGuVYYOpNjeuimrdzgqaHtD76Xl1XuAJM6A7IyTfuDHJYsbM16IMfxxghT(qq1T460nK(nPQlG1Pi9QO6yRHIgcvhg2s1jvTCCD4gyxOQBq1HLa0KQo22OPoPfUIQZsi6iKK6HRJfcWSZqUmoA9HGyf4TeJHWvKzk6iKedwcqZAgx0jgyBsimHJYsboneUImtrhHK8eZSG8vzOmeisUsHtlipMZxMSrFotdHRiZu0rijPUD9W1Xcby2ziN2fcJRJfcmIfhSc8wIboixenSUtg4GCr0qQKle1dxhleGzNHCAximUowiWiwCWkWBjgAfUE8sDwIfS4M68OUw3ABBVToPQ1pv3VpWbY1rDqav3eIQJCDtDsJGUcVkQohOQJPZ2gIIoydj1XwdbQJPS(QFxNLJC2QBX1HjbPdsvNdu1XumT86wCDayuhICLK68zqO6IgQoazTOomPHavQUCvWMlbxxRBT6KoSo1X2gn1Xm71LRAkvpCDSqaMDgYH6aJRJfcmIfhSc8wIXCblUH1DYqdBhqJnCbbopgABtRBnd2MaQCZKrFotde0v4vrPUn7J(CMG22qu0bBij1TFLPYKWfeiswV(QFBuiNTeb8HGuSWKCcxqGi16O3KYmHiJI8OjraFiiLmzAiuOGSbsTo6nPmtiYOipAsiQ1xaoplE9vMktCPqOnOKRjt32ib2rgSGOmuc5G3pXSmz5OHqHcYginOGnIaMOHmKecN62YKLZOpNjeuimrdzgqaHtD7xRhUowiaZod50UqyCDSqGrS4GvG3smg9vOQhUowiaZod5CK2bKjGiebcw3jdcqOSsskAU6nYJHfpJDcqOSssiklbQhUowiaZod5CK2bKXUlWu9W1Xcby2ziNyZ2eyJ1LUkBlbI6HRJfcWSZqUHN1aNMaT6346r94L6KUVcfHW1JxQlxIP6S(loGI6(nWOUDw3g1XgeivI60UDDAy7awNnCbbUohOQlAO6y6STHrhSHK6g95SUfxx3ovxUMbUQ664fKTo2AiqDwsezxN1vyhvhtPnW1Hdx)gxNJO6A2Sn11bccJRlAO6SCYv4gyu3OpN1T46Cbgwx3ovpCDSqaon6RqXWEXbuyWnWG1DYy0NZe02gIIoydjPUnlmz0NZ0BISnsGDKHTnWgFa7HrcSNWHRF)KfwQmzJ(CMuKRWnWi1TLjJaekRKNS0N9A9W1Xcb40OVcf7mKdVGfheYGd0(MQh1JxQtQcHcfKnaUE46yHaCsRWm0UqyCDSqGrS4GvG3smimMaAcZ6ozKdoixenKk5cr9W1Xcb4KwHzNHCUcraxSaYG64gw3jJCg95m5kebCXcidQJBsDBwysoK1RV22Kk5sb34ihBMqqyGtJnKncjtMgcfkiBGKWdceghPDGNquRVaCEmN)R1JxQJPFwNRu46Cevx3M16WG1MQlAO6GaQo22OPobKnch1jV8wEQUCjMQJTgcuNsYcYw30XbHQlACqDsvRFDkAU6nQdIQJTnAG9OohiPoPQ1pvpCDSqaoPvy2zixRJEtkZeImkYJgw1s0cYeoklfygwW6ozG8vzOmeisUsHtDBwys4OSuKITLmb0Ow6jnSDan2Wfe4KIMREdzYYbhKlIgsLqWSDIfnSDan2Wfe4KIMREJ8yOTnTU1myBcOYTfVwpEPoM(zDayDUsHRJTviQtTuDSTrZcQlAO6aK1I6K68XSwxht1XumT86GG6gqmUo22Ob2J6CGK6KQw)u9W1Xcb4KwHzNHCTo6nPmtiYOipAyDNmq(QmugcejxPWPfKNuNFUr(QmugcejxPWjvh5XcbSKdoixenKkHGz7elAy7aASHliWjfnx9g5XqBBADRzW2eqLBlQhVuN0cxr1zjeDessDqqDmZEDeGAxcNQJP0gn15kfMPvxUet1TZ6IgssD4WLu3eIQ75yVomPHafUoiQUDwNeyhvhGSwuNUXrzP6yBfI6guDiYvsQBb1fBlv3eIQlAO6aK1I6yZZqP6HRJfcWjTcZod5gcxrMPOJqsyDNmW2KqychLLcCEmyMLCg95mneUImtrhHKK62SWKCq(QmugcejxPWjYAloWYKH8vzOmeisUsHtiQ1xaoVNtMmKVkdLHarYvkCAb5XeMZTgcfkiBG0q4kYmfDesss34OSe2mrUowiWfVYuz(zVwpCDSqaoPvy2zix2gioesm4aTVjw3jJmoA9HGsdHRiZu0rijgSeGMfnSDan2Wfe4KIMREJ8yyb7J(CMgiORWRIsD76HRJfcWjTcZod5EVcXcYAW2iIyDNmY4O1hckneUImtrhHKyWsaAwycbiuwjPyBjtanTU1Y7zYKracLvYtw8SxRhUowiaN0km7mKBiCfzqDCdR7KrghT(qqPHWvKzk6iKedwcqZcbiuwjPyBjtanTU1YZcwysoJ(CMCfIaUybKb1XnPUTmzeGqzL8KL(SxRhVuxUeVGS1zjZblUrUCTD0Xn1T46GaHK686Yqij1flqsDlqJihtSwhgw3cQdrUydjSwNeyxQGO68bgk6bjKu3CbuDbSUoMQBJ6CCDED9yfBiPoSnjeP6HRJfcWjTcZod5Y4Gf3W6ozKdoixenKk5cblzC06dbL82rh3y0qGAJfcQhUowiaN0km7mKd34kiBTKqX6ozKdoixenKk5cblzC06dbL82rh3y0qGAJfcQhUowiaN0km7mKZggleW6ozm6ZzAiGqLOJJeICDit2OpNjxHiGlwazqDCtQBxpEPolHleliBDdx)UUawNIMExe1Tb1wxh7zP6HRJfcWjTcZod56yYSb1YkWBjgzC06dbzwqqa8gsmz3SEgOimqSEfcpwqwdICDarSUtgJ(CMgciuj64iHixhYKfBlzcOrT0tmyoFzY0W2b0ydxqGtkAU6nEIbZ1dxhleGtAfMDgY1XKzdQfZ6ozm6ZzAiGqLOJJeICDitwSTKjGg1spXG58LjtdBhqJnCbboPO5Q34jgmxpCDSqaoPvy2zi3qaHkZSJKupCDSqaoPvy2zi3Gqyc9EbzRhUowiaN0km7mKBUiAiGqv9W1Xcb4KwHzNHCoqt4a5cJ2fI6HRJfcWjTcZod56yYSb1YknNKomaVLyOLOfWabbR2meooyDNmYbhKlIgsLCHGLrFotUcraxSaYG64MKcYgGLrFotTulejXaNgrxVkJcrEloPGSbyHaekRKuSTKjGMw3A5zPSGIHz0Nt8tpRE46yHaCsRWSZqUoMmBqTSc8wIHlfCJJCSzcbHbon2q2ieR7KroJ(CMCfIaUybKb1XnPUnl5m6ZzAiCfzMIocjj1TzrdHcfKnqYvic4Ifqguh3KquRVa8tw8S6Xl1zjJqsQdb7zBesQd1fuDWzDrtVDSZLu116rdUUbjGSX0QlxIP6MquDm9G32qvDA0gSwhmAieBlMQJTnAQlxF(68OoMZN96WHRFJRdIQZI8zVo22OPoxGH1jTacv11Tt1dxhleGtAfMDgY1XKzdQLvG3smCCtghqydYLcez0qKlyDNmu0OpNjKlfiYOHixyu0OpNjfKnGmzkA0NZKgcuDDSziZcEBu0OpNPUnlHJYsrQHCr0KS1XtsnZSeoklfPgYfrtYwh5XqQZxMSCu0OpNjneO66yZqMf82OOrFotDBwyIIg95mHCPargne5cJIg95mHdx)opgmNFUTiFMQIg95mneqOYaNMOHmeGALK62YKfoklfPyBjtanQLEYYY)vwg95m5kebCXcidQJBsiQ1xaoplEU6Xl1z5007IOUPledx)UUjevxh7dbv3gulovpCDSqaoPvy2zixhtMnOwmR7KXOpNPHacvIoosiY1HmzX2sMaAul9edMZxMmnSDan2Wfe4KIMREJNyWC9OE8sDwhmMaAcxpCDSqaorymb0eMHgc0eiqEqkZu4TeR7KbbiuwjPyBjtanTU1YZcwYz0NZ0q4kYmfDessQBZctYrbJKgc0eiqEqkZu4TKz0rGuS63lill546yHGKgc0eiqEqkZu4TuAbMPyZ2eYKn7cHbr6ghLLmX2spLvRsTU1ETE46yHaCIWycOjm7mKBiGqLbonrdzia1kH1DYiJJwFiO0q4kYmfDesIblbOzrdHcfKnqAqbBebmrdzijeo1TzjJJwFiO0iiJgcuBSqq9W1Xcb4eHXeqty2zix2UJuRdmWPXLcHGrt9W1Xcb4eHXeqty2zi3eQ7yszCPqOniZG8ww3jdSnjeMWrzPaNgcxrMPOJqsYJbZYKH8vzOmeisUsHtlipllFwYz0NZKRqeWflGmOoUj1TRhUowiaNimMaAcZod5S7ODkzbzndHJdw3jdSnjeMWrzPaNgcxrMPOJqsYJbZYKH8vzOmeisUsHtlipll)6HRJfcWjcJjGMWSZqUOHmDWa2bkZeI0eR7KXOpNjePFlim2mHinL62YKn6Zzcr63ccJntistgnSdccLWHRF)Kf5xpCDSqaorymb0eMDgYHwBBbzwGbB7AQE46yHaCIWycOjm7mKJnisOYqlWGime4anvpCDSqaorymb0eMDgY1sTqKedCAeD9Qmke5Tyw3jdcqOSsEYsFw9W1Xcb4eHXeqty2zihIC7fK1mfElHzDNmchLLIud5IOjzRJ8EU8LjlCuwksnKlIMKToEIbZ5ltw4OSuKITLmb0yRddZ5NNuNF9OE8sDwIfS4gcHRhVuN0H1Poygcv3ZhsxhIqqHaxhBB0uNLtUc3ad5YvnvxG8nW1br1989OrqyCDwFePx8cbP6HRJfcWP5cwCdJbfSreWenKHKqyw3jJmoA9HGsJGmAiqTXcb1dxhleGtZfS4g2zihwSAY4aLrTAI1DYy0NZewSAY4aLrTAkHOwFb4NITLmb0OwILrFotyXQjJdug1QPeIA9fGFIjwWUg2oGgB4cc8Rmvlspx9W1Xcb40CblUHDgYHGcHjAiZacimR7KXOpNjeuimrdzgqaHtiQ1xa(jgsTmzzC06dbLqXWGieuiQhVuN0H1Po22OPUOHQlx1uD5s76SUc7O6(cIYq1br1z5KRWnWOUa5BGt1dxhleGtZfS4g2zi3Gc2icyIgYqsimR7KHlfcTbLCnz62gjWoYGfeLHseWhcsjtMlfcTbLuKRWnWiraFiiv9W1Xcb40CblUHDgYPwSTh6M6r94L6(b5IOPE46yHaCchKlIggE7OJB4)mecVqa3kMZN58ZNzMTm(Nnhbwqwm)Z03AdrbPQlxuNRJfcQtS4aNQh8VyXbMlp)tymb0eMlp3kl4YZ)eWhcsXLM)1Oni068pbiuwjPyBjtanTU1QlV6SOowQlN6g95mneUImtrhHKK621XsDmPUCQtbJKgc0eiqEqkZu4TKz0rGuS63liBDSuxo156yHGKgc0eiqEqkZu4TuAbMPyZ2e1jtwDZUqyqKUXrzjtSTuDpvxwTk16wRUx5FxhleW)AiqtGa5bPmtH3s8GBfZC55Fc4dbP4sZ)A0geAD(pJJwFiO0q4kYmfDesIblbORJL60qOqbzdKguWgrat0qgscHtD76yPUmoA9HGsJGmAiqTXcb8VRJfc4)Hacvg40enKHauReEWTsQ5YZ)UowiG)Z2DKADGbonUuiemA4Fc4dbP4sZdUvwkxE(Na(qqkU08VgTbHwN)X2KqychLLcCAiCfzMIocjPU8yuhZ1jtwDiFvgkdbIKRu40cQlV6SS8RJL6YPUrFotUcraxSaYG64Mu3M)DDSqa)pH6oMugxkeAdYmiVLhCREgxE(Na(qqkU08VgTbHwN)X2KqychLLcCAiCfzMIocjPU8yuhZ1jtwDiFvgkdbIKRu40cQlV6SS85FxhleW)2D0oLSGSMHWXbp4wzzC55Fc4dbP4sZ)A0geAD(F0NZeI0VfegBMqKMsD76KjRUrFotis)wqySzcrAYOHDqqOeoC976EQolYN)DDSqa)hnKPdgWoqzMqKM4b3QCbxE(31Xcb8pATTfKzbgSTRj(Na(qqkU08GB1ZXLN)DDSqa)ZgejuzOfyqegcCGM4Fc4dbP4sZdUvw3C55Fc4dbP4sZ)A0geAD(NaekRK6EQol9z8VRJfc4)wQfIKyGtJORxLrHiVfZdUvwKpxE(Na(qqkU08VgTbHwN)dhLLIud5IOjzRJ6YRUNl)6KjRUWrzPi1qUiAs26OUNyuhZ5xNmz1foklfPyBjtan26WWC(1LxDsD(8VRJfc4Fe52liRzk8wcZdEW)kA6DrWLNBLfC55Fc4dbP4sZ)A0geAD(pN6Wb5IOHujemBN4FxhleW)Vx9BEWTIzU88VRJfc4FCqUiA4Fc4dbP4sZdUvsnxE(Na(qqkU08p0M)XuW)UowiG)Z4O1hcI)Z4IoX)Oyyg95ex3t1XCDSuhtQB0NZKa6kszuRMsD76KjRUCQB0NZ0abDfEvuQBx3R8VgTbHwN)DPqOnOKICfUbgjc4dbP4)moYa8wI)rXWGieui4b3klLlp)taFiifxA(hAZ)yk4FxhleW)zC06dbX)zCrN4FummJ(CIR7P6yUowQJj1n6ZzsaDfPmQvtPUDDYKv3OpNjupAeegBSrKEXleKquRVaCDpXOonekuq2aPbfSreWenKHKq4eIA9fGR7v(xJ2GqRZ)Uui0guY1KPBBKa7idwqugkraFiivDSuNlfcTbLCnz62gjWoYGfeLHsih8UU8yuNlfcTbLuKRWnWiHCWB(pJJmaVL4FummicbfcEWT6zC55Fc4dbP4sZ)qB(htb)76yHa(pJJwFii(pJl6e)JIHz0NtCDpvhZ8VgTbHwN)DPqOnOeg4VjdjHWjKdExxEmQJz(pJJmaVL4FummicbfcEWTYY4YZ)eWhcsXLM)H28pIWuW)UowiG)Z4O1hcI)Z4idWBj(hfddIqqHG)1Oni068VlfcTbLWa)nzijeoHCW76YJrDmxhl1n6Zzcd83KHKq4eoC976YJrDmxxURB0NZ0abDfEvuQBZdUv5cU88pb8HGuCP5FOn)JPG)DDSqa)NXrRpee)NXfDI)rXWm6ZjUUCx3OpNj87UqyCGYOrqmEabeo1TR7P6yUowQJj1n6ZzsaDfPmQvtPUDDYKvxo1n6ZzklYbktljik1TRJL6YPUrFotOE0iim2yJi9Ixii1TRJL6YPUrFotde0v4vrPUDDVY)A0geAD(F0NZ0q4kYmfDessQBZ)zCKb4Te)JIHbriOqWdUvphxE(Na(qqkU08p0M)XuW)UowiG)Z4O1hcI)Z4IoX)Ay7aASHliWjfnx9g1LhJ6yUo2RJ56yQ1XK6cxqGiLTbIdHedoq7BkraFiivDSuNgcfkiBGu2gioesm4aTVPeIA9fGR7P6SOUxRJ96g95mnqqxHxfL621XsDeGqzLuxE1zz5xhl1LtDJ(CMWV7cHXbkJgbX4beq4u3UowQlN6g95m9MiBJeyhzyBdSXhWEyKa7PUn)NXrgG3s8V3o64gJgcuBSqap4wzDZLN)jGpeKIln)dT5Fmf8VRJfc4)moA9HG4)mUOt8)OpNjupAeegBSrKEXleK621jtwDmPoxkeAdkPixHBGrIa(qqQ6KjRoxkeAdk5AY0TnsGDKblikdLiGpeKQUxRJL6g95mHGcHjAiZaciCQBZ)zCKb4Te)pcYOHa1gleWdUvwKpxE(Na(qqkU08p0M)XuW)UowiG)Z4O1hcI)Z4IoX)yBsimHJYsboneUImtrhHKu3t1XCDSuhYxLHYqGi5kfoTG6YRoMZVozYQB0NZ0q4kYmfDessQBZ)zCKb4Te)peUImtrhHKyWsaAEWTYcl4YZ)eWhcsXLM)1Oni068poixenKk5cb)76yHa(x7cHX1XcbgXId(xS4Wa8wI)Xb5IOHhCRSGzU88pb8HGuCP5FxhleW)AximUowiWiwCW)IfhgG3s8VwH5b3klKAU88pb8HGuCP5FnAdcTo)RHTdOXgUGaxxEmQtBBADRzW2eqvxURJj1n6ZzAGGUcVkk1TRJ96g95mbTTHOOd2qsQBx3R1XuRJj1fUGarY61x9BJc5SLiGpeKQowQJj1LtDHliqKAD0BszMqKrrE0KiGpeKQozYQtdHcfKnqQ1rVjLzcrgf5rtcrT(cW1LxDwu3R19ADm16ysDUui0guY1KPBBKa7idwqugkHCW76EQoMRtMS6YPonekuq2aPbfSreWenKHKq4u3UozYQlN6g95mHGcHjAiZaciCQBx3R8VRJfc4FuhyCDSqGrS4G)flomaVL4)5cwCdp4wzHLYLN)jGpeKIln)76yHa(x7cHX1XcbgXId(xS4Wa8wI)h9vO4b3klEgxE(Na(qqkU08VgTbHwN)jaHYkjPO5Q3OU8yuNfpRo2RJaekRKeIYsa(31Xcb8VJ0oGmbeHiqWdUvwyzC55FxhleW)os7aYy3fyI)jGpeKIlnp4wzrUGlp)76yHa(xSzBcSX6sxLTLab)taFiifxAEWTYINJlp)76yHa(F4znWPjqR(nM)jGpeKIlnp4b)BJinSD4bxEUvwWLN)jGpeKIln)76yHa(V1rVjLzcrgf5rd)RrBqO15FKVkdLHarYvkCAb1LxDwA(8VnI0W2HhgmPHafM)Fgp4wXmxE(Na(qqkU08VgTbHwN)zsD5uhz96RTnPs2q9BkWRuiLrdBT7HhleyuuMvt1jtwD5uNgcfkiBGKwIwadeeSAZq44iP6ipwiOozYQd5RYqziqKwqMUaqiFiOezTfh46EL)DDSqa)JdYfrdp4wj1C55Fc4dbP4sZ)UowiG)rqHWenKzabeM)TrKg2o8WGjneOW8pZ8GBLLYLN)jGpeKIln)76yHa(hlwnzCGYOwnX)2isdBhEyWKgcuy(NzEWT6zC55Fc4dbP4sZ)UowiG)DfIaUybKb1Xn8VgTbHwN)zsD5uhz96RTnPs2q9BkWRuiLrdBT7HhleyuuMvt1jtwD5uNgcfkiBGKwIwadeeSAZq44iP6ipwiOozYQd5RYqziqKwqMUaqiFiOezTfh46EL)TrKg2o8WGjneOW8Vf8GBLLXLN)jGpeKIln)d8wI)DPGBCKJntiimWPXgYgH4FxhleW)UuWnoYXMjeeg40ydzJq8GBvUGlp)taFiifxA(31Xcb8VwIwadeeSAZq44G)1Oni068Fo1H8vzOmeislitxaiKpeuIS2Idm)tZjPddWBj(xlrlGbccwTziCCWdUvphxE(31Xcb8VnmwiG)jGpeKIlnp4b)p6RqXLNBLfC55Fc4dbP4sZ)A0geAD(F0NZe02gIIoydjPUDDSuhtQB0NZ0BISnsGDKHTnWgFa7HrcSNWHRFx3t1zHLwNmz1n6ZzsrUc3aJu3UozYQJaekRK6EQol9z19k)76yHa(3EXbuyWnWGhCRyMlp)76yHa(hVGfheYGd0(M4Fc4dbP4sZdEW)4GCr0WLNBLfC55FxhleW)E7OJB4Fc4dbP4sZdEW)AfMlp3kl4YZ)eWhcsXLM)1Oni068Fo1HdYfrdPsUqW)UowiG)1UqyCDSqGrS4G)flomaVL4FcJjGMW8GBfZC55Fc4dbP4sZ)A0geAD(pN6g95m5kebCXcidQJBsD76yPoMuxo1rwV(ABtQKlfCJJCSzcbHbon2q2iuDYKvNgcfkiBGKWdceghPDGNquRVaCD5vhZ5x3R8VRJfc4FxHiGlwazqDCdp4wj1C55Fc4dbP4sZ)UowiG)BD0BszMqKrrE0W)A0geAD(h5RYqziqKCLcN621XsDmPUWrzPifBlzcOrTuDpvNg2oGgB4ccCsrZvVrDYKvxo1HdYfrdPsiy2ovhl1PHTdOXgUGaNu0C1BuxEmQtBBADRzW2eqvxURZI6EL)1s0cYeoklfyUvwWdUvwkxE(Na(qqkU08VgTbHwN)r(QmugcejxPWPfuxE1j15xxURd5RYqziqKCLcNuDKhleuhl1LtD4GCr0qQecMTt1XsDAy7aASHliWjfnx9g1LhJ602Mw3AgSnbu1L76SG)DDSqa)36O3KYmHiJI8OHhCREgxE(Na(qqkU08VgTbHwN)X2KqychLLcCD5XOoMRJL6YPUrFotdHRiZu0rijPUDDSuhtQlN6q(QmugcejxPWjYAloW1jtwDiFvgkdbIKRu4eIA9fGRlV6EU6KjRoKVkdLHarYvkCAb1LxDmPoMRl31PHqHcYgineUImtrhHKK0noklHntKRJfcCrDVwhtToMFwDVY)UowiG)hcxrMPOJqs4b3klJlp)taFiifxA(xJ2GqRZ)zC06dbLgcxrMPOJqsmyjaDDSuNg2oGgB4ccCsrZvVrD5XOolQJ96g95mnqqxHxfL628VRJfc4)SnqCiKyWbAFt8GBvUGlp)taFiifxA(xJ2GqRZ)zC06dbLgcxrMPOJqsmyjaDDSuhtQJaekRKuSTKjGMw3A1LxDpRozYQJaekRK6EQolEwDVY)UowiG)FVcXcYAW2iI4b3QNJlp)taFiifxA(xJ2GqRZ)zC06dbLgcxrMPOJqsmyjaDDSuhbiuwjPyBjtanTU1QlV6SOowQJj1LtDJ(CMCfIaUybKb1XnPUDDYKvhbiuwj19uDw6ZQ7v(31Xcb8)q4kYG64gEWTY6Mlp)taFiifxA(xJ2GqRZ)5uhoixenKk5crDSuxghT(qqjVD0XngneO2yHa(31Xcb8FghS4gEWTYI85YZ)eWhcsXLM)1Oni068Fo1HdYfrdPsUquhl1LXrRpeuYBhDCJrdbQnwiG)DDSqa)JBCfKTwsO4b3klSGlp)taFiifxA(xJ2GqRZ)J(CMgciuj64iHixh1jtwDJ(CMCfIaUybKb1XnPUn)76yHa(3ggleWdUvwWmxE(Na(qqkU08VRJfc4)moA9HGmliiaEdjMSBwpduegiwVcHhliRbrUoGi(xJ2GqRZ)J(CMgciuj64iHixh1jtwDX2sMaAulv3tmQJ58RtMS60W2b0ydxqGtkAU6nQ7jg1Xm)d8wI)Z4O1hcYSGGa4nKyYUz9mqryGy9keESGSge56aI4b3klKAU88pb8HGuCP5FnAdcTo)p6ZzAiGqLOJJeICDuNmz1fBlzcOrTuDpXOoMZVozYQtdBhqJnCbboPO5Q3OUNyuhZ8VRJfc4)oMmBqTyEWTYclLlp)76yHa(FiGqLz2rs4Fc4dbP4sZdUvw8mU88VRJfc4)bHWe69cYY)eWhcsXLMhCRSWY4YZ)UowiG)NlIgciuX)eWhcsXLMhCRSixWLN)DDSqa)7anHdKlmAxi4Fc4dbP4sZdUvw8CC55Fc4dbP4sZ)UowiG)1s0cyGGGvBgchh8VgTbHwN)ZPoCqUiAivYfI6yPUrFotUcraxSaYG64MKcYgOowQB0NZul1crsmWPr01RYOqK3ItkiBG6yPocqOSssX2sMaAADRvxE1zP1XsDOyyg95ex3t19m(NMtshgG3s8VwIwadeeSAZq44GhCRSW6Mlp)taFiifxA(31Xcb8VlfCJJCSzcbHbon2q2ie)RrBqO15)CQB0NZKRqeWflGmOoUj1TRJL6YPUrFotdHRiZu0rijPUDDSuNgcfkiBGKRqeWflGmOoUjHOwFb46EQolEg)d8wI)DPGBCKJntiimWPXgYgH4b3kMZNlp)taFiifxA(31Xcb8VJBY4acBqUuGiJgICb)RrBqO15Ffn6Zzc5sbImAiYfgfn6ZzsbzduNmz1POrFotAiq11XMHml4TrrJ(CM621XsDHJYsrQHCr0KS1rDpvNuZCDSux4OSuKAixenjBDuxEmQtQZVozYQlN6u0OpNjneO66yZqMf82OOrFotD76yPoMuNIg95mHCPargne5cJIg95mHdx)UU8yuhZ5xxURZI8RJPwNIg95mneqOYaNMOHmeGALK621jtwDHJYsrk2wYeqJAP6EQoll)6ETowQB0NZKRqeWflGmOoUjHOwFb46YRolEo(h4Te)74MmoGWgKlfiYOHixWdUvmBbxE(Na(qqkU08VgTbHwN)h95mneqOs0XrcrUoQtMS6ITLmb0OwQUNyuhZ5xNmz1PHTdOXgUGaNu0C1Bu3tmQJz(31Xcb8FhtMnOwmp4b)pxWIB4YZTYcU88pb8HGuCP5FnAdcTo)NXrRpeuAeKrdbQnwiG)DDSqa)pOGnIaMOHmKecZdUvmZLN)jGpeKIln)RrBqO15)rFotyXQjJdug1QPeIA9fGR7P6ITLmb0OwQowQB0NZewSAY4aLrTAkHOwFb46EQoMuNf1XEDAy7aASHliW19ADm16Si9C8VRJfc4FSy1KXbkJA1ep4wj1C55Fc4dbP4sZ)A0geAD(F0NZeckeMOHmdiGWje16lax3tmQtQRtMS6Y4O1hckHIHbriOqW)UowiG)rqHWenKzabeMhCRSuU88pb8HGuCP5FnAdcTo)7sHqBqjxtMUTrcSJmybrzOeb8HGu1jtwDUui0gusrUc3aJeb8HGu8VRJfc4)bfSreWenKHKqyEWT6zC55FxhleW)QfB7HUH)jGpeKIlnp4bp4FVhnqe))3wPkp4bNda]] )


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

    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = "full"
    } )  
end