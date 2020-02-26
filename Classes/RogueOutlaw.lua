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


    spec:RegisterPack( "Outlaw", 20200226, [[d8eejbqirvEKQeBcL0NOeKrHIYPuL0QqrfVIizwOe3suP2Li)IOyyIQ6yuIwgkYZqPktJsQ6AQIQTrjW3evsghLu5CusPADOOQMNQi3df2NOIdQkkwirQhIsv1ePKIlsjLSruuPpIIQOojkvLwPQWlPeuUjkvf7KsYprrvAOIkrhffvrwQQO0tvvtLO0vfvsTvkbv(kkQcJLsqvNLskf7fv)LIbRYHPAXk8ysnzsUmYMv0NfLgTu60kTAkPu61QsnBc3wk2nWVbnCk1XfvclhYZHA6cxxQ2UO47OugpLqNNiwpkvMpr1(Lm3sUS8VYdIBft5Zu(5ZetwqkFRJ9Yv5ZE8FiXM4FBx)2Zs8pWBi(N5ThcNn(32LiGUIll)JHDKM4)2iSXmFzKj7gT9rsdBKbVnDHhleOr(mKbVnAz4)rFfb7lGp4FLhe3kMYNP8ZNjMSGu(wh7zbp3s(hBtAUvmzb5Z)TRsra(G)vewZ)VuhZBpeoB19SWSDQE8sDTryJz(Yit2nA7JKg2idEB6cpwiqJ8zidEB0YupEPoMlnqDhjPoMSawQJP8zk)6r94L6y)ToilHz(1JxQl319mkfPQZcB1VRlG1POP3frDUowiOoXIJu94L6YDDpJsrQ6SrKg2m8OoPfUIQJ5k6iKK6yMcsyGfkQBGi)DD)GCr0(AQE8sD5UoRbcSqrDDmvxGwWBkW1TG6Wb5IOnvpEPUCxN1abwOOUoMQRzbmFl81nHO6yFC0Bsv3eIQZAipARJzByHW1bGrD4UTnefK61u94L6YDDptg4QQdriOqSGS19SH01P6OfKToPfUIQJ5k6iKK6ywhiimUo2O6GaHK6A9muDwwx4OSu8AQE8sD5UUNLeUfRZcBfIfKTUVnIOu94L6YDD5AmvxSnKjGg1s1nHO6iGg2bbHQJaQfKToKhTeQUO1b1foklfPyBitanQLs8VncoxbX)VuhZBpeoB19SWSDQE8sDTryJz(Yit2nA7JKg2idEB6cpwiqJ8zidEB0YupEPoMlnqDhjPoMSawQJP8zk)6r94L6y)ToilHz(1JxQl319mkfPQZcB1VRlG1POP3frDUowiOoXIJu94L6YDDpJsrQ6SrKg2m8OoPfUIQJ5k6iKK6yMcsyGfkQBGi)DD)GCr0(AQE8sD5UoRbcSqrDDmvxGwWBkW1TG6Wb5IOnvpEPUCxN1abwOOUoMQRzbmFl81nHO6yFC0Bsv3eIQZAipARJzByHW1bGrD4UTnefK61u94L6YDDptg4QQdriOqSGS19SH01P6OfKToPfUIQJ5k6iKK6ywhiimUo2O6GaHK6A9muDwwx4OSu8AQE8sD5UUNLeUfRZcBfIfKTUVnIOu94L6YDD5AmvxSnKjGg1s1nHO6iGg2bbHQJaQfKToKhTeQUO1b1foklfPyBitanQLs1J6Xl1zTSiP7bPQBqtiIQtdBgEu3GYUaCQUNrRj7axhacYDRJAMDrDUowiaxheiKKQhVuNRJfcWjBePHndpymfo(D94L6CDSqaozJinSz4HumKX7zBiq4Xcb1JxQZ1Xcb4KnI0WMHhsXqMjeQQhVu3h424wyuhYxvDJ(CsQ6WHh46g0eIO60WMHh1nOSlaxNdu1zJOCBdJybzRBX1PGakvpEPoxhleGt2isdBgEifdzWa3g3cddo8axpCDSqaozJinSz4HumKPXrVjLzcrgf5rll2isdBgEyWKgcuygpNLDYa5RYqziqKCLcNwqowF(1dxhleGt2isdBgEifdzWb5IOLLDYGz5r5I(ABtQKnu)Mc8Yosz0Wg7E4XcbgfLz1KC55PHqHcYgiPLOfWabbR2meoosQoYJfcKlh5RYqziqKwqMUaqiFiOezXfh4xRhUowiaNSrKg2m8qkgYGGcHjAjZaciml2isdBgEyWKgcuygmvpCDSqaozJinSz4HumKblwnzCGYOwnXInI0WMHhgmPHafMbt1dxhleGt2isdBgEifdzCfIaUybKb1XTSyJinSz4HbtAiqHzyjl7KbZYJYf912MujBO(nf4LDKYOHn29WJfcmkkZQj5YZtdHcfKnqslrlGbccwTziCCKuDKhleixoYxLHYqGiTGmDbGq(qqjYIloWVwpCDSqaozJinSz4HumKPJjZgudlaVHy4Sd36ihBMqqyGtJnKncvpCDSqaozJinSz4HumKPJjZgudl0Cs6Wa8gIHwIwadeeSAZq44GLDYipKVkdLHarAbz6caH8HGsKfxCGRhUowiaNSrKg2m8qkgYydJfcQh1JxQZAzrs3dsvhLHqsQl2gQUOLQZ1bev3IRZZ4RWhckvpEPUNLWb5IOTUDwNneJ3HGQJzayDz6caH8HGQJauZs46wqDAyZWJxRhUowiaZ49QFZYozKhoixeTKkHGz7u9W1Xcbyg4GCr0wpEPUNLqqHOUjevhtsv3OpN46GO6KgbDfEvuDSTrBDwd5kClms1dxhleGLIHmzC06dbXcWBigOyyqeckeSaTzGPGLDYWzhH2GskYv4wyKiGpeKILmUOtmqXWm6Zj(jMyLzJ(CMeqxrkJA1uQBlxEEJ(CMgiORWRIsD7xRhVu3ZsiOqu3eIQJjPQB0NtCDquDpBpAfegxxUer6fVqqDSTrBDpJMQRBxNeyhv3xqugIL66abHX1fTeIQZruDnqevN1qUc3cJ6qo4novpCDSqawkgYKXrRpeelaVHyGIHbriOqWc0MbMcw2jdNDeAdk5AY0TnsGDKblikdLiGpeKIvNDeAdk5AY0TnsGDKblikdLqo4DomC2rOnOKICfUfgjKdEZsgx0jgOyyg95e)etSYSrFotcORiLrTAk1TLlF0NZeQhTccJn2isV4fcsiQXxa(jgAiuOGSbsdkyJiGjAjdjHWje14la)A94L6ysQ6(a)nvN1scHz(19mc2Cj46qecke1nHO6ysQ6g95eNQhUowialfdzY4O1hcIfG3qmqXWGieuiybAZatbl7KHZocTbLWa)nzijeoHCW7CyWelzCrNyGIHz0Nt8tmvpEPoMKQUpWFt1zTKqyMFDwdSoamQdriOquhBB0whtsvhoC9BCDWzDrlv3h4VP6SwsiCDJ(CwhZSuQ6WHRFxhBB0wN0iORWRIQRB)AQE46yHaSumKjJJwFiiwaEdXafddIqqHGfOndeHPGLDYWzhH2GsyG)MmKecNqo4DomyI1rFotyG)MmKecNWHRFNddMY9OpNPbc6k8QOu3UE8sDmp2OToPfUIQJ5k6iKK662Su3MfaruDOUGW15dygQohOQl83uDugcjjAxq26IwpQBX1XKu1XmamQtd7GybzR77S)xRdIQdVGScQoP)SuhZZSpSu3ZMlRhUowialfdzY4O1hcIfG3qmqXWGieuiybAZatbl7KXOpNPHWvKzk6iKKu3MLmUOtmqXWm6Zjo3J(CMWV7cHXbkJgbX4beq4u3(jMyLzJ(CMeqxrkJA1uQBlxEEJ(CMYICGY0qcIsDBwZB0NZeQhTccJn2isV4fcsDBwZB0NZ0abDfEvuQB)A9W1XcbyPyitghT(qqSa8gIH3m64wJgcuBSqalzCrNyOHndOXgUGaNu0C1BKddMKIjMdZcxqGiLTfIdHedoq7BkraFiifRAiuOGSbszBH4qiXGd0(MsiQXxa(jlFvQrFotde0v4vrPUnReGqzLKJfKpR5n6Zzc)UleghOmAeeJhqaHtDBwZB0NZ0BISnsGDKHTnWgFa7HrcSN621dxhleGLIHmzC06dbXcWBigJGmAiqTXcbSKXfDIXOpNjupAfegBSrKEXleK62YLZmNDeAdkPixHBHrIa(qqk5YD2rOnOKRjt32ib2rgSGOmuIa(qqQxzD0NZeckeMOLmdiGWPUD94L6yESrBDnDrS2cQUWrzPaZsDr7IRlJJwFiO6wCD6ws)Mu1fW6uKEvuDS1srlHQddBO6y)wdUoClSlu1nO6WsaAsvhBB0wN0cxr1XCfDess9W1XcbyPyitghT(qqSa8gIXq4kYmfDesIblbOzjJl6edSnjeMWrzPaNgcxrMPOJqsEIjwr(QmugcejxPWPfKdt5lx(OpNPHWvKzk6iKKu3UE46yHaSumKr7cHX1XcbgXIdwaEdXahKlIww2jdCqUiAjvYfI6HRJfcWsXqgTlegxhleyeloyb4nedTcxpEPoM7cwCBDEuxJBXTP3uh7pxMQ73h4a56OoiGQBcr1rUUToPrqxHxfvNdu1X8ABdrrhSHK6yRLa1X8uF1VRZAqoB1T46WKG0bPQZbQ6yFMwtDlUoamQdrUssD(miuDrlvhGSyuhM0qGkv3ZiyZLGRRXTyDshwR6yBJ26ysQ6EgnLQhUowialfdzqDGX1XcbgXIdwaEdXyUGf3YYozOHndOXgUGaNddTTPXTObBtavUz2OpNPbc6k8QOu3wQrFotqBBik6GnKK62VYCyw4ccePCrF1VnkKZwIa(qqkwzwEHliqKAC0BszMqKrrE0MiGpeKsUCnekuq2aPgh9MuMjezuKhTje14laNJLV(kZHzo7i0guY1KPBBKa7idwqugkHCW7NysU880qOqbzdKguWgrat0sgscHtDB5YZB0NZeckeMOLmdiGWPU9R1dxhleGLIHmAximUowiWiwCWcWBigJ(ku1dxhleGLIHmos7aYeqeIabl7Kbbiuwjjfnx9g5WWYNlfbiuwjjeLLa1dxhleGLIHmos7aYy3fyQE46yHaSumKrSzBdSXABxLTHar9W1XcbyPyiZWZAGttGw9BC9OE8sDs3xHIq46Xl1LRXuD5YfhqrD)wyu3oRBJ6ydcSqrDA3UonSzaRZgUGaxNdu1fTuDmV22WOd2qsDJ(Cw3IRRBNQ7zYaxvDD8cYwhBTeOolmISRZAdSJQJ5Xg46WHRFJRZruDTB2266abHX1fTuDwd5kClmQB0NZ6wCDUadRRBNQhUowiaNg9vOyyV4akm4wyWYozm6ZzcABdrrhSHKu3MvMn6Zz6nr2gjWoYW2gyJpG9Wib2t4W1VFYsRxU8rFotkYv4wyK62YLtacLvYtw)ZFTE46yHaCA0xHskgYGxWIdczWbAFt1J6Xl1X(HqHcYgaxpCDSqaoPvygAximUowiWiwCWcWBigegtanHzzNmYdhKlIwsLCHOE46yHaCsRWsXqgxHiGlwazqDCll7KrEJ(CMCfIaUybKb1XTPUnReGqzLKITHmb004wmhlzLz5r5I(ABtQKZoCRJCSzcbHbon2q2iKC5AiuOGSbscpiqyCK2bEcrn(cW5Wu(VwpEPo23zDUsHRZruDDBwQddwBQUOLQdcO6yBJ26eq2iCuNSYAnP6Y1yQo2AjqDkjliBDthheQUO1b1X(ZL1PO5Q3OoiQo22Of2J6CGK6y)5Yu9W1Xcb4KwHLIHmno6nPmtiYOipAzrlrlit4OSuGzyjl7KbYxLHYqGi5kfo1TzLzHJYsrk2gYeqJAPN0WMb0ydxqGtkAU6nKlppCqUiAjvcbZ2jw1WMb0ydxqGtkAU6nYHH2204w0GTjGk3w(A94L6yFN1bG15kfUo2wHOo1s1X2gTlOUOLQdqwmQJ9YhZsDDmvh7Z0AQdcQBaX46yBJwypQZbsQJ9Nlt1dxhleGtAfwkgY04O3KYmHiJI8OLLDYa5RYqziqKCLcNwqoSx(5g5RYqziqKCLcNuDKhleWAE4GCr0sQecMTtSQHndOXgUGaNu0C1BKddTTPXTObBtavUTSE8sDslCfvhZv0rij1bb1XKu1raQzjCQoMhB0wNRuyMFD5Amv3oRlAjj1HdxsDtiQoRtQ6WKgcu46GO62zDsGDuDaYIrD6whLLQJTviQBq1HixjPUfuxSnuDtiQUOLQdqwmQJnpdLQhUowiaN0kSumKziCfzMIocjHLDYaBtcHjCuwkW5WGjwZB0NZ0q4kYmfDessQBZkZYd5RYqziqKCLcNilU4alxoYxLHYqGi5kfoHOgFb4CSo5Yr(QmugcejxPWPfKdZyk3AiuOGSbsdHRiZu0rijjDRJYsyZe56yHax8kZHPN)A9W1Xcb4KwHLIHmzBH4qiXGd0(MyzNmY4O1hckneUImtrhHKyWsaAw1WMb0ydxqGtkAU6nYHHLsn6ZzAGGUcVkk1TRhUowiaN0kSumK59keliRbBJiILDYiJJwFiO0q4kYmfDesIblbOzLzeGqzLKITHmb004wmNNlxobiuwjpz5ZFTE46yHaCsRWsXqMHWvKb1XTSStgzC06dbLgcxrMPOJqsmyjanReGqzLKITHmb004wmhlRhVuxUgVGS1zHZblUvMNPz0XT1T46GaHK686Yqij1flqsDlqJihtSuhgw3cQdrUydjSuNey3cHO68bgk6bjKu3CbuDbSUoMQBJ6CCDED9yfBiPoSnjeP6HRJfcWjTclfdzY4Gf3YYozKhoixeTKk5cbRzC06dbL8Mrh3A0qGAJfcQhUowiaN0kSumKb36kiBnKqXYozKhoixeTKk5cbRzC06dbL8Mrh3A0qGAJfcQhUowiaN0kSumKXggleWYozm6ZzAiGqLOJJeICDix(OpNjxHiGlwazqDCBQBxpEPoMRleliBDdx)UUawNIMExe1Tb1uxh7zP6HRJfcWjTclfdz6yYSb1WcWBigzC06dbzwqqa8gsmz3SEgOimqSEfcpwqwdICDarSStgJ(CMgciuj64iHixhYLhBdzcOrT0tmykF5Y1WMb0ydxqGtkAU6nEIbt1dxhleGtAfwkgY0XKzdQbZYozm6ZzAiGqLOJJeICDixESnKjGg1spXGP8LlxdBgqJnCbboPO5Q34jgmvpCDSqaoPvyPyiZqaHkZSJKupCDSqaoPvyPyiZGqyc9EbzRhUowiaN0kSumKzUiAiGqv9W1Xcb4KwHLIHmoqt4a5cJ2fI6HRJfcWjTclfdz6yYSb1WcnNKomaVHyOLOfWabbR2meooyzNmYdhKlIwsLCHG1rFotUcraxSaYG642KcYgG1rFotnudejXaNgrxVkJcrEdoPGSbyLaekRKuSnKjGMg3I5y9SIIHz0Nt8tpVE46yHaCsRWsXqMoMmBqnSa8gIHZoCRJCSzcbHbon2q2iel7KrEJ(CMCfIaUybKb1XTPUnR5n6ZzAiCfzMIocjj1TzvdHcfKnqYvic4Ifqguh3MquJVa8tw(86Xl1zHJqsQdb7zBfsQd1fuDWzDrBVzSZLu114rlUUbjGSX8RlxJP6MquDSVG32qvDA0gSuhmAjeBlMQJTnAR7zE268OoMYxQ6WHRFJRdIQZY8LQo22OToxGH1jTacv11Tt1dxhleGtAfwkgY0XKzdQHfG3qmCCBghqydYzhez0qKlyzNmu0OpNjKZoiYOHixyu0OpNjfKnGC5kA0NZKgcuDDSziZcEBu0OpNPUnRHJYsrQLCr0MS1XtShtSgoklfPwYfrBYwh5WG9YxU88u0OpNjneO66yZqMf82OOrFotDBwzMIg95mHC2brgne5cJIg95mHdx)ohgmLFUTmFMJIg95mneqOYaNMOLmeGAKK62YLhoklfPyBitanQLEYcY)vwh95m5kebCXcidQJBtiQXxaohlTU6Xl1zn007IOUPledx)UUjevxh7dbv3gudovpCDSqaoPvyPyithtMnOgml7KXOpNPHacvIoosiY1HC5X2qMaAul9edMYxUCnSzan2Wfe4KIMREJNyWu9OE8sDwlmMaAcxpCDSqaorymb0eMHgc0eiqEqkZu4nel7KbbiuwjPyBitannUfZXswZB0NZ0q4kYmfDessQBZkZYtbJKgc0eiqEqkZu4nKz0rGuS63lilR556yHGKgc0eiqEqkZu4nuAbMPyZ2gYLp7cHbr6whLLmX2qpLvRsnUfFTE46yHaCIWycOjSumKziGqLbonrlzia1iHLDYiJJwFiO0q4kYmfDesIblbOzvdHcfKnqAqbBebmrlzijeo1TznJJwFiO0iiJgcuBSqq9W1Xcb4eHXeqtyPyit2UJuRdmWPXzhHGrB9W1Xcb4eHXeqtyPyiZeQ7yszC2rOniZG8gw2jdSnjeMWrzPaNgcxrMPOJqsYHbtYLJ8vzOmeisUsHtlihliFwZB0NZKRqeWflGmOoUn1TRhUowiaNimMaAclfdzS7ODkzbzndHJdw2jdSnjeMWrzPaNgcxrMPOJqsYHbtYLJ8vzOmeisUsHtlihli)6HRJfcWjcJjGMWsXqMOLmDWa2bkZeI0el7KXOpNjePFlim2mHinL62YLp6Zzcr63ccJntistgnSdccLWHRF)KL5xpCDSqaorymb0ewkgYGwBBbzwGbB7AQE46yHaCIWycOjSumKHnisOYqlWGime4anvpCDSqaorymb0ewkgY0qnqKedCAeD9Qmke5nyw2jdcqOSsEY6FE9W1Xcb4eHXeqtyPyidIC7fK1mfEdHzzNmchLLIul5IOnzRJCSU8LlpCuwksTKlI2KToEIbt5lxE4OSuKITHmb0yRddt5Nd7LF9OE8sDm3fS4wcHRhVuN0H1Qoygcv3ZgsxhIqqHaxhBB0wN1qUc3cdzEgnvxG8nW1br19S9OvqyCD5sePx8cbP6HRJfcWP5cwClJbfSreWeTKHKqyw2jJmoA9HGsJGmAiqTXcb1dxhleGtZfS4wPyidwSAY4aLrTAILDYy0NZewSAY4aLrTAkHOgFb4NITHmb0OwI1rFotyXQjJdug1QPeIA8fGFIzwkLg2mGgB4cc8Rmhltwx9W1Xcb40CblUvkgYGGcHjAjZaciml7KXOpNjeuimrlzgqaHtiQXxa(jgSNC5zC06dbLqXWGieuiQhVuN0H1Qo22OTUOLQ7z0uD5A76S2a7O6(cIYq1br1znKRWTWOUa5BGt1dxhleGtZfS4wPyiZGc2icyIwYqsiml7KHZocTbLCnz62gjWoYGfeLHseWhcsjxUZocTbLuKRWTWiraFiiv9W1Xcb40CblUvkgYOwSTh626r94L6(b5IOTE46yHaCchKlIwgEZOJB5)mecVqa3kMYNP8ZNjlzI)zZrGfKfZ)SVn2quqQ6Yv156yHG6eloWP6b)79OfI4))2W(5FXIdmxw(NWycOjmxwUvwYLL)jGpeKIln)RrBqO15FcqOSssX2qMaAAClwxo1zzDSwxE1n6ZzAiCfzMIocjj1TRJ16ywD5vNcgjneOjqG8GuMPWBiZOJaPy1Vxq26yTU8QZ1XcbjneOjqG8GuMPWBO0cmtXMTnQtU86MDHWGiDRJYsMyBO6EQUSAvQXTyDVY)UowiG)1qGMabYdszMcVH4b3kM4YY)eWhcsXLM)1Oni068FghT(qqPHWvKzk6iKedwcqxhR1PHqHcYginOGnIaMOLmKecN621XADzC06dbLgbz0qGAJfc4FxhleW)dbeQmWPjAjdbOgj8GBf7XLL)DDSqa)NT7i16adCAC2riy0Y)eWhcsXLMhCRSEUS8pb8HGuCP5FnAdcTo)JTjHWeoklf40q4kYmfDessD5WOoMQtU86q(QmugcejxPWPfuxo1zb5xhR1LxDJ(CMCfIaUybKb1XTPUn)76yHa(Fc1DmPmo7i0gKzqEdp4w9CUS8pb8HGuCP5FnAdcTo)JTjHWeoklf40q4kYmfDessD5WOoMQtU86q(QmugcejxPWPfuxo1zb5Z)UowiG)T7ODkzbzndHJdEWTYc4YY)eWhcsXLM)1Oni068)OpNjePFlim2mHinL621jxEDJ(CMqK(TGWyZeI0Krd7GGqjC46319uDwMp)76yHa(pAjthmGDGYmHinXdUv5kUS8VRJfc4F0ABliZcmyBxt8pb8HGuCP5b3kRJll)76yHa(NnisOYqlWGime4anX)eWhcsXLMhCRS25YY)eWhcsXLM)1Oni068pbiuwj19uDw)Z5FxhleW)nudejXaNgrxVkJcrEdMhCRSmFUS8pb8HGuCP5FnAdcTo)hoklfPwYfrBYwh1LtDwx(1jxEDHJYsrQLCr0MS1rDpXOoMYVo5YRlCuwksX2qMaAS1HHP8RlN6yV85FxhleW)iYTxqwZu4neMh8G)v007IGll3kl5YY)eWhcsXLM)1Oni068FE1HdYfrlPsiy2oX)UowiG)FV638GBftCz5FxhleW)4GCr0Y)eWhcsXLMhCRypUS8pb8HGuCP5FOn)JPG)DDSqa)NXrRpee)NXfDI)rXWm6ZjUUNQJP6yToMv3OpNjb0vKYOwnL621jxED5v3OpNPbc6k8QOu3UUx5FnAdcTo)7SJqBqjf5kClmseWhcsX)zCKb4ne)JIHbriOqWdUvwpxw(Na(qqkU08p0M)XuW)UowiG)Z4O1hcI)Z4IoX)Oyyg95ex3t1XuDSwhZQB0NZKa6kszuRMsD76KlVUrFotOE0kim2yJi9IxiiHOgFb46EIrDAiuOGSbsdkyJiGjAjdjHWje14lax3R8VgTbHwN)D2rOnOKRjt32ib2rgSGOmuIa(qqQ6yToNDeAdk5AY0TnsGDKblikdLqo4DD5WOoNDeAdkPixHBHrc5G38FghzaEdX)Oyyqecke8GB1Z5YY)eWhcsXLM)H28pMc(31Xcb8FghT(qq8Fgx0j(hfdZOpN46EQoM4FnAdcTo)7SJqBqjmWFtgscHtih8UUCyuht8FghzaEdX)Oyyqecke8GBLfWLL)jGpeKIln)dT5FeHPG)DDSqa)NXrRpee)NXrgG3q8pkggeHGcb)RrBqO15FNDeAdkHb(BYqsiCc5G31LdJ6yQowRB0NZeg4VjdjHWjC4631LdJ6yQUCx3OpNPbc6k8QOu3MhCRYvCz5Fc4dbP4sZ)qB(htb)76yHa(pJJwFii(pJl6e)JIHz0NtCD5UUrFot43DHW4aLrJGy8aciCQBx3t1XuDSwhZQB0NZKa6kszuRMsD76KlVU8QB0NZuwKduMgsquQBxhR1LxDJ(CMq9OvqySXgr6fVqqQBxhR1LxDJ(CMgiORWRIsD76EL)1Oni068)OpNPHWvKzk6iKKu3M)Z4idWBi(hfddIqqHGhCRSoUS8pb8HGuCP5FOn)JPG)DDSqa)NXrRpee)NXfDI)1WMb0ydxqGtkAU6nQlhg1XuDsvht1XCQJz1fUGarkBlehcjgCG23uIa(qqQ6yTonekuq2aPSTqCiKyWbAFtje14lax3t1zzDVwNu1n6ZzAGGUcVkk1TRJ16iaHYkPUCQZcYVowRlV6g95mHF3fcJdugncIXdiGWPUDDSwxE1n6Zz6nr2gjWoYW2gyJpG9Wib2tDB(pJJmaVH4FVz0XTgneO2yHaEWTYANll)taFiifxA(hAZ)yk4FxhleW)zC06dbX)zCrN4)rFotOE0kim2yJi9Ixii1TRtU86ywDo7i0gusrUc3cJeb8HGu1jxEDo7i0guY1KPBBKa7idwqugkraFiivDVwhR1n6Zzcbfct0sMbeq4u3M)Z4idWBi(FeKrdbQnwiGhCRSmFUS8pb8HGuCP5FOn)JPG)DDSqa)NXrRpee)NXfDI)X2KqychLLcCAiCfzMIocjPUNQJP6yToKVkdLHarYvkCAb1LtDmLFDYLx3OpNPHWvKzk6iKKu3M)Z4idWBi(FiCfzMIocjXGLa08GBLLwYLL)jGpeKIln)RrBqO15FCqUiAjvYfc(31Xcb8V2fcJRJfcmIfh8VyXHb4ne)JdYfrlp4wzjtCz5Fc4dbP4sZ)UowiG)1UqyCDSqGrS4G)flomaVH4FTcZdUvwYECz5Fc4dbP4sZ)A0geAD(xdBgqJnCbbUUCyuN2204w0GTjGQUCxhZQB0NZ0abDfEvuQBxNu1n6ZzcABdrrhSHKu3UUxRJ5uhZQlCbbIuUOV63gfYzlraFiivDSwhZQlV6cxqGi14O3KYmHiJI8OnraFiivDYLxNgcfkiBGuJJEtkZeImkYJ2eIA8fGRlN6SSUxR716yo1XS6C2rOnOKRjt32ib2rgSGOmuc5G319uDmvNC51LxDAiuOGSbsdkyJiGjAjdjHWPUDDYLxxE1n6Zzcbfct0sMbeq4u3UUx5FxhleW)OoW46yHaJyXb)lwCyaEdX)ZfS4wEWTYsRNll)taFiifxA(31Xcb8V2fcJRJfcmIfh8VyXHb4ne)p6RqXdUvw(CUS8pb8HGuCP5FnAdcTo)tacLvssrZvVrD5WOolFEDsvhbiuwjjeLLa8VRJfc4FhPDazcicrGGhCRS0c4YY)UowiG)DK2bKXUlWe)taFiifxAEWTYYCfxw(31Xcb8VyZ2gyJ12UkBdbc(Na(qqkU08GBLLwhxw(31Xcb8)WZAGttGw9Bm)taFiifxAEWd(3grAyZWdUSCRSKll)taFiifxA(31Xcb8FJJEtkZeImkYJw(xJ2GqRZ)iFvgkdbIKRu40cQlN6S(85FBePHndpmysdbkm))CEWTIjUS8pb8HGuCP5FnAdcTo)ZS6YRokx0xBBsLSH63uGx2rkJg2y3dpwiWOOmRMQtU86YRonekuq2ajTeTagiiy1MHWXrs1rESqqDYLxhYxLHYqGiTGmDbGq(qqjYIloW19k)76yHa(hhKlIwEWTI94YY)eWhcsXLM)DDSqa)JGcHjAjZacim)BJinSz4HbtAiqH5FM4b3kRNll)taFiifxA(31Xcb8pwSAY4aLrTAI)TrKg2m8WGjneOW8pt8GB1Z5YY)eWhcsXLM)DDSqa)7kebCXcidQJB5FnAdcTo)ZS6YRokx0xBBsLSH63uGx2rkJg2y3dpwiWOOmRMQtU86YRonekuq2ajTeTagiiy1MHWXrs1rESqqDYLxhYxLHYqGiTGmDbGq(qqjYIloW19k)BJinSz4HbtAiqH5Fl5b3klGll)taFiifxA(h4ne)7Sd36ihBMqqyGtJnKncX)UowiG)D2HBDKJntiimWPXgYgH4b3QCfxw(Na(qqkU08VRJfc4FTeTagiiy1MHWXb)RrBqO15)8Qd5RYqziqKwqMUaqiFiOezXfhy(NMtshgG3q8VwIwadeeSAZq44GhCRSoUS8VRJfc4FBySqa)taFiifxAEWd(FUGf3YLLBLLCz5Fc4dbP4sZ)A0geAD(pJJwFiO0iiJgcuBSqa)76yHa(FqbBebmrlzijeMhCRyIll)taFiifxA(xJ2GqRZ)J(CMWIvtghOmQvtje14lax3t1fBdzcOrTuDSw3OpNjSy1KXbkJA1ucrn(cW19uDmRolRtQ60WMb0ydxqGR716yo1zzY64FxhleW)yXQjJdug1QjEWTI94YY)eWhcsXLM)1Oni068)OpNjeuimrlzgqaHtiQXxaUUNyuh7vNC51LXrRpeucfddIqqHG)DDSqa)JGcHjAjZacimp4wz9Cz5Fc4dbP4sZ)A0geAD(3zhH2GsUMmDBJeyhzWcIYqjc4dbPQtU86C2rOnOKICfUfgjc4dbP4FxhleW)dkyJiGjAjdjHW8GB1Z5YY)UowiG)vl22dDl)taFiifxAEWd(hhKlIwUSCRSKll)76yHa(3BgDCl)taFiifxAEWd(xRWCz5wzjxw(Na(qqkU08VgTbHwN)ZRoCqUiAjvYfc(31Xcb8V2fcJRJfcmIfh8VyXHb4ne)tymb0eMhCRyIll)taFiifxA(xJ2GqRZ)5v3OpNjxHiGlwazqDCBQBxhR1racLvsk2gYeqtJBX6YPolRJ16ywD5vhLl6RTnPso7WToYXMjeeg40ydzJq1jxEDAiuOGSbscpiqyCK2bEcrn(cW1LtDmLFDVY)UowiG)DfIaUybKb1XT8GBf7XLL)jGpeKIln)76yHa(VXrVjLzcrgf5rl)RrBqO15FKVkdLHarYvkCQBxhR1XS6chLLIuSnKjGg1s19uDAyZaASHliWjfnx9g1jxED5vhoixeTKkHGz7uDSwNg2mGgB4ccCsrZvVrD5WOoTTPXTObBtavD5UolR7v(xlrlit4OSuG5wzjp4wz9Cz5Fc4dbP4sZ)A0geAD(h5RYqziqKCLcNwqD5uh7LFD5UoKVkdLHarYvkCs1rESqqDSwxE1HdYfrlPsiy2ovhR1PHndOXgUGaNu0C1BuxomQtBBAClAW2eqvxURZs(31Xcb8FJJEtkZeImkYJwEWT65Cz5Fc4dbP4sZ)A0geAD(hBtcHjCuwkW1LdJ6yQowRlV6g95mneUImtrhHKK621XADmRU8Qd5RYqziqKCLcNilU4axNC51H8vzOmeisUsHtiQXxaUUCQZ6QtU86q(QmugcejxPWPfuxo1XS6yQUCxNgcfkiBG0q4kYmfDesss36OSe2mrUowiWf19ADmN6y6519k)76yHa(FiCfzMIocjHhCRSaUS8pb8HGuCP5FnAdcTo)NXrRpeuAiCfzMIocjXGLa01XADAyZaASHliWjfnx9g1LdJ6SSoPQB0NZ0abDfEvuQBZ)UowiG)Z2cXHqIbhO9nXdUv5kUS8pb8HGuCP5FnAdcTo)NXrRpeuAiCfzMIocjXGLa01XADmRocqOSssX2qMaAAClwxo1986KlVocqOSsQ7P6S8519k)76yHa()9keliRbBJiIhCRSoUS8pb8HGuCP5FnAdcTo)NXrRpeuAiCfzMIocjXGLa01XADeGqzLKITHmb004wSUCQZs(31Xcb8)q4kYG64wEWTYANll)taFiifxA(xJ2GqRZ)5vhoixeTKk5crDSwxghT(qqjVz0XTgneO2yHa(31Xcb8FghS4wEWTYY85YY)eWhcsXLM)1Oni068FE1HdYfrlPsUquhR1LXrRpeuYBgDCRrdbQnwiG)DDSqa)JBDfKTgsO4b3klTKll)taFiifxA(xJ2GqRZ)J(CMgciuj64iHixh1jxEDJ(CMCfIaUybKb1XTPUn)76yHa(3ggleWdUvwYexw(Na(qqkU08VRJfc4)moA9HGmliiaEdjMSBwpduegiwVcHhliRbrUoGi(xJ2GqRZ)J(CMgciuj64iHixh1jxEDX2qMaAulv3tmQJP8RtU860WMb0ydxqGtkAU6nQ7jg1Xe)d8gI)Z4O1hcYSGGa4nKyYUz9mqryGy9keESGSge56aI4b3klzpUS8pb8HGuCP5FnAdcTo)p6ZzAiGqLOJJeICDuNC51fBdzcOrTuDpXOoMYVo5YRtdBgqJnCbboPO5Q3OUNyuht8VRJfc4)oMmBqnyEWTYsRNll)76yHa(FiGqLz2rs4Fc4dbP4sZdUvw(CUS8VRJfc4)bHWe69cYY)eWhcsXLMhCRS0c4YY)UowiG)NlIgciuX)eWhcsXLMhCRSmxXLL)DDSqa)7anHdKlmAxi4Fc4dbP4sZdUvwADCz5Fc4dbP4sZ)UowiG)1s0cyGGGvBgchh8VgTbHwN)ZRoCqUiAjvYfI6yTUrFotUcraxSaYG642KcYgOowRB0NZud1arsmWPr01RYOqK3GtkiBG6yTocqOSssX2qMaAAClwxo1z91XADOyyg95ex3t19C(NMtshgG3q8VwIwadeeSAZq44GhCRS0ANll)taFiifxA(31Xcb8VZoCRJCSzcbHbon2q2ie)RrBqO15)8QB0NZKRqeWflGmOoUn1TRJ16YRUrFotdHRiZu0rijPUDDSwNgcfkiBGKRqeWflGmOoUnHOgFb46EQolFo)d8gI)D2HBDKJntiimWPXgYgH4b3kMYNll)taFiifxA(31Xcb8VJBZ4acBqo7GiJgICb)RrBqO15Ffn6Zzc5SdImAiYfgfn6ZzsbzduNC51POrFotAiq11XMHml4TrrJ(CM621XADHJYsrQLCr0MS1rDpvh7XuDSwx4OSuKAjxeTjBDuxomQJ9YVo5YRlV6u0OpNjneO66yZqMf82OOrFotD76yToMvNIg95mHC2brgne5cJIg95mHdx)UUCyuht5xxURZY8RJ5uNIg95mneqOYaNMOLmeGAKK621jxEDHJYsrk2gYeqJAP6EQoli)6ETowRB0NZKRqeWflGmOoUnHOgFb46YPolTo(h4ne)742moGWgKZoiYOHixWdUvmzjxw(Na(qqkU08VgTbHwN)h95mneqOs0XrcrUoQtU86ITHmb0OwQUNyuht5xNC51PHndOXgUGaNu0C1Bu3tmQJj(31Xcb8FhtMnOgmp4b)p6RqXLLBLLCz5Fc4dbP4sZ)A0geAD(F0NZe02gIIoydjPUDDSwhZQB0NZ0BISnsGDKHTnWgFa7HrcSNWHRFx3t1zP1xNC51n6ZzsrUc3cJu3Uo5YRJaekRK6EQoR)519k)76yHa(3EXbuyWTWGhCRyIll)76yHa(hVGfheYGd0(M4Fc4dbP4sZdEWdEWdoh]] )


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