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


    spec:RegisterPack( "Outlaw", 20190712.2319, [[davV3aqibKhjfztcuFcGKrHu0PqQ0QissVcjAweLULayxs6xivnmKkogsyziPEgsbttaLRjfvBtaQVHuOghrcDoPO06euP5bqDpaTpbLdkOIfIK8qIemrIeDrIKQnIuiFeGuvNuacRKO6LaKYmbiv5Msrr7KO4NsrHHsKuokaPILkGQNQIPIu6QcqARaKk9vbiASejrDwIKq7fYFfAWkDyklwQEmPMmjxg1Mb6ZcYOLWPvSAIKiVMi1SjCBP0Uv1VHA4s0XjscwoINdA6uDDvA7sHVlqgVGQoprSEaI5dG9lAefiArhL5msgQPdfnlDOXuqDLAAGA6qraJoUKsgDknT0wigDERLrNMX1fwqOtPjrGnfIw0bIVenJofUxcdx6Pp04f3EvJBPhoTxH5d(1ed0PhoTA6rN(DeEaXJ6OJYCgjd10HIMLo0ykOUsnnqnDOdfOdSK1izOoGPd6umkf)Oo6OyOgDAk3MX1fwq5g44qxoL3uUfUxcdx6Pp04f3EvJBPhoTxH5d(1ed0PhoTA6t5nLR8RqsUuqTS5snDOOzZna5snneUu0SP8uEt5kfkSpedd3uEt5gGCdhLIv5cOnAPZ1X5Qyq7k8CnTp4pxXa9AkVPCdqUHJsXQCljSg32npxQeMIZLgjUeIKCPPcZWhq552jSjDUhNnHxq3AkVPCdqUsj(buEUxiNRtMxA2H5oFUqNnHxut5nLBaYvkXpGYZ9c5CBNpCLkNliMKBZ0isZQCbXKCLs28ICP54akyUp2ZfEllXeNv0TMYBk3aKB40apQCjmbleZhk3a3Pkx1LmFOCPsykoxAK4sisYLM3xWqyUbX5IFHKClSgCUuKRBKqSt3AkVPCdqUbolSWNlG2ieZhk3tjH5AkVPCdqUbuiNRpTC0Xr1W5cIj5YVgFFNj5YVA(q5smVGj56f2NRBKqSx9PLJooQgUIoLem4iy0PPCBgxxybLBGJdD5uEt5w4EjmCPN(qJxC7vnULE40EfMp4xtmqNE40QPpL3uUYVcj5sb1YMl10HIMn3aKl10q4srZMYt5nLRuOW(qmmCt5nLBaYnCukwLlG2OLoxhNRIbTRWZ10(G)Cfd0RP8MYna5gokfRYTKWACB38CPsykoxAK4sisYLMkmdFaLNBNWM05EC2eEbDRP8MYna5kL4hq55EHCUozEPzhM785cD2eErnL3uUbixPe)akp3lKZTD(WvQCUGysUntJinRYfetYvkzZlYLMJdOG5(ypx4TSetCwr3AkVPCdqUHtd8OYLWeSqmFOCdCNQCvxY8HYLkHP4CPrIlHijxAEFbdH5geNl(fsYTWAW5srUUrcXoDRP8MYna5g4SWcFUaAJqmFOCpLeMRP8MYna5gqHCU(0YrhhvdNliMKl)A89DMKl)Q5dLlX8cMKRxyFUUrcXE1Nwo64OA4AkpL3uUs9WZ6RZQC7miMW5QXTDZZTZHMhwZnC0AU0H5(4pafgPf8kY10(GFyU4xiPMYnTp4hwljSg32nhiOWGsNYnTp4hwljSg32nNsG0B3qT87Mp4pLBAFWpSwsynUTBoLaPheJvP8MY98wjSa75sSrLB)ccYQCHU5WC7miMW5QXTDZZTZHMhMR9QCljCakXUpFOChyUk8Z1uUP9b)WAjH142U5ucKE4BLWcShHU5WuUP9b)WAjH142U5ucKEOZMWls5M2h8dRLewJB7Mtjq6lX(G)uUP9b)WAjH142U5ucK(wJinRIGysuXMxiBjH142U5riRXVccS5YoGaj2OICd(9QPuW68Hfy0jLBAFWpSwsynUTBoLaPNGfIOxWXo(zOSLewJB7MhHSg)kiqQt5M2h8dRLewJB7Mtjq6HIrZr7vr1OzzljSg32npczn(vqGuNYnTp4hwljSg32nNsG0Bkc)MyEosUWczljSg32npczn(vqGuKYnTp4hwljSg32nNsG03fMIJGIlHir2bey)ccwjyHi6fCSJFgwVLbBAFAWr(52HHHrrkpL3uUs9WZ6RZQC5gmrsU(0Y56fCUM2XKChyUwdBewxW1uEt5g4m0zt4f5oG5wIHWPl4CP5JZTXv8mX6cox(52HH5oFUACB3C6MYnTp4hcu6rlTSdiWabD2eEbRQeCOlNYnTp4hce6Sj8IuEt5g4mble5cIj5snL52VGGWCdA8ICb0dBkwLRuoAo3Bzn3MHxWKGgiNlHjyHixqmjxQPmxmjxa9j2RYTzYcMZftYnWVEHGHWCLAewpWb)1uUP9b)qkbsFdJmwxWY(wldK49iHjyHq2gM4YajEp2VGGqatDW0SFbbRcSPyvunAUElbaGa1VGG1qe7vXwwWC9wgCG6xqWk56fcgcJLewpWb)1BjDt5nLBGZeSqKliMKl1uMB)cccZftYnWVEHGHWCLAewpWb)5g04f5kLSPGfypxmj3WrZ5ElZvc(sY9iyUbxt5M2h8dPei9nmYyDbl7BTmqI3JeMGfczXLaHSl7ac0aeMmoxvSPGfyVYV1fScaamaHjJZvtZXBzuc(sIqbZn4k)wxWkzByIldK49y)cccbm1btZ(feSkWMIvr1O56Teaa6xqWk56fcgcJLewpWb)vc3AZdbmqnglu4G(AN9Gy(JEbhzjmSs4wBEiDt5nLl1uM75nP5CL6syy4MB4icYKaZLWeSqKliMKl1uMB)cccRPCt7d(HucK(ggzSUGL9TwgiX7rctWcHS4sGq2LDabAactgNRW3KMJSegwj2lDyaPw2gM4YajEp2VGGqatDkVPCPMYCpVjnNRuxcdd3CLsCUp2ZLWeSqKBqJxKl1uMl0nT0WCXG56fCUN3KMZvQlHH52VGG5stkOmxOBAPZnOXlYLkc2uWrX5ElPBnLBAFWpKsG03WiJ1fSSV1YajEpsycwiKfxcKWq2LDabAactgNRW3KMJSegwj2lDyaPo4(feScFtAoYsyyf6Mw6WasDa6xqWANGnfCuC9wMYnTp4hsjq6ByKX6cw23AzGwB)clIA8RgFWVSnmXLbQXTDCSepVdRkgC0JhgqQPKAPknDtWVxdvGHUqse6KrAUYV1fSkynglu4G(AOcm0fsIqNmsZvc3AZdbmf0LY(feS2jytbhfxVLbZptcjjSaMobhO(feScL(ker7vrnbdHD8ZW6TmL3uUbKJxKB7v4tPGZ1nsi2HYMRxmWCByKX6co3bMRUG1sZQCDCUkwpko3GkyVGj5cXTCUsbPeMlSaFfQC7CUqjVMv5g04f5sLWuCU0iXLqKKYnTp4hsjq6ByKX6cw23AzGDHP4iO4sisIqjVw2gM4YaHLSqeDJeIDyTlmfhbfxcrcGPoyInQi3GFVAkfSoFyuthaaOFbbRDHP4iO4sisQ3YuUP9b)qkbsV2eIOP9b)rXaDzFRLbcD2eEHSdiqOZMWlyv1eIuUP9b)qkbsV2eIOP9b)rXaDzFRLbQvWuEt5sJMFGf5AEUTw4N2BBUsbPwn3ZTdDIP9CXpNliMKlB6ICPIGnfCuCU2RYTzuwIj(9hxsUbvWFUa6ChT05kLelOChyUqwWANv5AVk3MjOuM7aZ9XEUe2usY1aDMKRxW5(C49CHSg)QAk30(GFiLaPNC)OP9b)rXaDzFRLbco)alKDabQXTDCSepVdddOUm2AHpcl5xfaA2VGG1obBk4O46TKY(feSIllXe)(JlPElPRuLMUj43RsfUJw6OIybv536cwfmndKBc(9ARrKMvrqmjQyZlQ8BDbRaaanglu4G(ARrKMvrqmjQyZlQeU1Mhggf0LUPCt7d(HucKETjert7d(JIb6Y(wldSFhHkLBAFWpKsG0BeT9C0Xec)USdiq(zsijvfdo6XddifnNs(zsijvchI)uUP9b)qkbsVr02ZXYRaYPCt7d(HucKEXeQWHrPsxvOw(9uEkVPCP6ocftGP8MYnGc5CLAd0XICpfyp3bm3XZni8dO8C1wzUACBhNBjEEhMR9QC9co3Mrzj2V)4sYTFbbZDG5ElR5gonWJk3lC(q5gub)5cOXCzUsfXxsUbKJdZf6MwAyUgHZTycvK79fmeMRxW5kLSPGfyp3(fem3bMRjG4CVL1uUP9b)WA)ocfWYb6yrewGDzhqG9liyfxwIj(9hxs9wgmn7xqWQ0mxgLGVKyqJdJwhF9Oe8TcDtlnGPGoaaq)ccwvSPGfyVElbaa(zsijaoWAoDt5M2h8dR97iuucKE48d0zse6KrAoLNYBkxPaglu4GEyk30(GFyvRGa1MqenTp4pkgOl7BTmqgc5xZqzhqGbc6Sj8cwvnHiLBAFWpSQvqkbsVPi8BI55i5clKDabgO(feSAkc)MyEosUWI6Tmy(zsijvFA5OJJTw4dJIuEt5gqaMRPuWCncN7Tu2CH)uY56fCU4NZnOXlYvGdIHEU0sRuwZnGc5CdQG)CvsMpuUGg0zsUEH95kfKA5QyWrpEUysUbnEb(65AVKCLcsTAk30(GFyvRGucK(wJinRIGysuXMxiRwIwWr3iHyhcKczhqGeBurUb)E1uky9wgmnDJeI9QpTC0Xr1WawJB74yjEEhwvm4Ohhaace0zt4fSQsWHUCWACBhhlXZ7WQIbh94HbuxgBTWhHL8Rcaf0nL3uUbeG5(4CnLcMBqJqKRA4CdA8I5Z1l4CFo8EU0aDGYM7fY52mbLYCXFUDmeMBqJxGVEU2ljxPGuRMYnTp4hw1kiLaPV1isZQiiMevS5fYoGaj2OICd(9QPuW68Hrd0jaeBurUb)E1ukyvDjMp4p4abD2eEbRQeCOlhSg32XXs88oSQyWrpEya1LXwl8ryj)QaqrkVPCPsykoxAK4sisYf)5snL5Yp3omSMBa54f5AkfmCZnGc5ChWC9cwsUq3KKliMKRuKYCHSg)kyUysUdyUsWxsUphEpxDHrcX5g0ie525CjSPKK7856tlNliMKRxW5(C49CdYAW1uUP9b)WQwbPei9DHP4iO4sisKDabclzHi6gje7WWasDWbQFbbRDHP4iO4sisQ3YGPzGi2OICd(9QPuWkh(b6qaaGyJkYn43RMsbReU1MhgMueaai2OICd(9QPuW68HrtQdGgJfkCqFTlmfhbfxcrsvxyKqmmcsmTp43e0vQsDZPBk30(GFyvRGucK(qfyOlKeHozKMLDab2WiJ1fCTlmfhbfxcrsek51bRXTDCSepVdRkgC0JhgqkOSFbbRDc2uWrX1Bzk30(GFyvRGucKEPhHy(qryjHzzhqGnmYyDbx7ctXrqXLqKeHsEDW0KFMess1Nwo64yRf(WAoaaWptcjbWu0C6MYnTp4hw1kiLaPVlmfhjxyHSdiWggzSUGRDHP4iO4sisIqjVoy(zsijvFA5OJJTw4dJIuEt5gqHZhkxaDTFGf0hoT9lSi3bMl(fsY1YTbtKKRpVKCNxtydYYMleN785sytmUezZvc(cOiCUwhIfxNfsYfCEoxhN7fY5oEUgmxl3RpIXLKlSKfIAk30(GFyvRGucK(g2pWczhqGbc6Sj8cwvnHi4ggzSUGRwB)clIA8RgFWFk30(GFyvRGucKEyHPWb1YcLSdiWabD2eEbRQMqeCdJmwxWvRTFHfrn(vJp4pLBAFWpSQvqkbsFj2h8l7acSFbbRDbgRexOxjSPDaaOFbbRMIWVjMNJKlSOElt5nLlnYeI5dLB30sNRJZvXG2v45oo3M7fAH4uUP9b)WQwbPei9xihhNBL9TwgydJmwxWX5D(HJljgAcznWcpIH6rimF(qrcBAhtKDab2VGG1UaJvIl0Re20oaa4tlhDCunmGbsnDaaanUTJJL45DyvXGJECadK6uUP9b)WQwbPei9xihhNBHYoGa7xqWAxGXkXf6vcBAhaa8PLJooQggWaPMoaaGg32XXs88oSQyWrpoGbsDk30(GFyvRGucK(UaJvrWlrsk30(GFyvRGucK(otGmr65dLYnTp4hw1kiLaPhCiCxGXQuUP9b)WQwbPei92RzOtmruBcrkpL3uUsDiKFndt5M2h8dRmeYVMHa14xZVtmNvrqH1YPCt7d(Hvgc5xZqkbsFxGXQigm6fCKFUvISdiWggzSUGRDHP4iO4sisIqjVoLBAFWpSYqi)Agsjq6dDnIASpIbJgGWeSxKYnTp4hwziKFndPei9Gy9fYQObimzCo2zRv2beiSKfIOBKqSdRDHP4iO4siscdi1aaaXgvKBWVxnLcwNpSaMobhO(feSAkc)MyEosUWI6TmLBAFWpSYqi)Agsjq6lVKbuY8HIDHbDzhqGWswiIUrcXoS2fMIJGIlHijmGudaaeBurUb)E1ukyD(Wcy6KYnTp4hwziKFndPei9EbhVFhFFveet0Ck30(GFyLHq(1mKsG0tMYsbhNpclnnNYnTp4hwziKFndPei9bHjcvdE(iHH43Enl7acSFbbRIbK7cmwvHUPLgW0qk30(GFyLHq(1mKsG03YTyIKigmkU6rfve2AHYoGa5NjHKa4aR5P8uEt5sJMFGfmbMYBkxQCPEU4gmj3a3PkxctWcbm3GgVixPKnfSa70hoAoxNyJdZftYnWVEHGHWCLAewpWb)1uUP9b)Wk48dSayN9Gy(JEbhzjmu2bey)ccwjxVqWqySKW6bo4VElbaaAAactgNRk2uWcSx536cwbaagGWKX5QP54TmkbFjrOG5gCLFRlyfDdUFbbReSqe9co2XpdR3YuUP9b)Wk48dSGsG0dfJMJ2RIQrZYoGa7xqWkumAoAVkQgnxjCRnpeW(0YrhhvdhC)ccwHIrZr7vr1O5kHBT5HaMMuqPg32XXs88oKUsvkQsXuUP9b)Wk48dSGsG0tWcr0l4yh)mu2bey)ccwjyHi6fCSJFgwjCRnpeWaPHuUP9b)Wk48dSGsG0tWcr0l4yh)mu2beinnTpn4i)C7WqGuaaa9liyTlmfhbfxcrsvHd6PBWnmYyDbxjEpsycwis5nLlvUup3GgVixVGZnC0CUb0YCLkIVKCpcMBW5Ij5kLSPGfypxNyJdRPCt7d(HvW5hybLaPVZEqm)rVGJSegk7ac0aeMmoxnnhVLrj4ljcfm3GR8BDbRaaadqyY4CvXMcwG9k)wxWQuUP9b)Wk48dSGsG0RgyP56IuEkVPCpoBcViLBAFWpScD2eEbqRTFHfOtdMah8JKHA6qrZshAmfuxPdDOb0jiJ8ZhcIobeTLyIZQCPX5AAFWFUIb6WAkhDed0HiArhgc5xZqeTizOarl6yAFWp6OXVMFNyoRIGcRLrh(TUGviQqosgQr0Io8BDbRquHoAY4mzm0PHrgRl4AxykockUeIKiuYRrht7d(rNUaJvrmy0l4i)CReKJKHgq0IoM2h8JoHUgrn2hXGrdqyc2lqh(TUGviQqosMadrl6WV1fScrf6OjJZKXqhyjler3iHyhw7ctXrqXLqKKByaZL6CbaGCj2OICd(9QPuW685gwUbmDYn4CduU9liy1ue(nX8CKCHf1Bj6yAFWp6aI1xiRIgGWKX5yNTwKJKP5iArh(TUGviQqhnzCMmg6alzHi6gje7WAxykockUeIKCddyUuNlaaKlXgvKBWVxnLcwNp3WYnGPd6yAFWp6uEjdOK5df7cd6ihjtaJOfDmTp4hD8coE)o((QiiMOz0HFRlyfIkKJKHgJOfDmTp4hDitzPGJZhHLMMrh(TUGviQqosgPiIw0HFRlyfIk0rtgNjJHo9liyvmGCxGXQk0nT05c4CPb0X0(GF0jimrOAWZhjme)2RzKJKPzr0Io8BDbRquHoAY4mzm0HFMessUao3aR5OJP9b)Otl3IjsIyWO4QhvuryRfICKJokg0Uchrlsgkq0Io8BDbRquHoAY4mzm0jq5cD2eEbRQeCOlJoM2h8JospAProsgQr0IoM2h8JoqNnHxGo8BDbRquHCKm0aIw0HFRlyfIk0bxIoq2rht7d(rNggzSUGrNgM4YOdX7X(feeMlGZL6CdoxAMB)ccwfytXQOA0C9wMlaaKBGYTFbbRHi2RITSG56Tm3GZnq52VGGvY1lemegljSEGd(R3YCPl60WiX3Az0H49iHjyHa5izcmeTOd)wxWkevOdUeDGSJoM2h8JonmYyDbJonmXLrhI3J9liimxaNl15gCU0m3(feSkWMIvr1O56Tmxaai3(feSsUEHGHWyjH1dCWFLWT28WCbmWC1ySqHd6RD2dI5p6fCKLWWkHBT5H5sx0rtgNjJHogGWKX5QInfSa7v(TUGv5caa5AactgNRMMJ3YOe8LeHcMBWv(TUGvOtdJeFRLrhI3JeMGfcKJKP5iArh(TUGviQqhCj6azhDmTp4hDAyKX6cgDAyIlJoeVh7xqqyUaoxQrhnzCMmg6yactgNRW3KMJSegwj2lDUHbmxQrNggj(wlJoeVhjmbleihjtaJOfD436cwHOcDWLOdHHSJoM2h8JonmYyDbJonms8TwgDiEpsycwiqhnzCMmg6yactgNRW3KMJSegwj2lDUHbmxQZn4C7xqWk8nP5ilHHvOBAPZnmG5sDUbi3(feS2jytbhfxVLihjdngrl6WV1fScrf6Glrhi7OJP9b)OtdJmwxWOtdtCz0rJB74yjEEhwvm4Ohp3WaMl15szUuNRunxAMRBc(9AOcm0fsIqNmsZv(TUGv5gCUAmwOWb91qfyOlKeHozKMReU1MhMlGZLICPBUuMB)ccw7eSPGJIR3YCdox(zsij5gwUbmDYn4CduU9liyfk9viI2RIAcgc74NH1Bj60WiX3Az0XA7xyruJF14d(rosgPiIw0HFRlyfIk0bxIoq2rht7d(rNggzSUGrNgM4YOdSKfIOBKqSdRDHP4iO4sisYfW5sDUbNlXgvKBWVxnLcwNp3WYLA6KlaaKB)ccw7ctXrqXLqKuVLOtdJeFRLrNUWuCeuCjejrOKxJCKmnlIw0HFRlyfIk0rtgNjJHoqNnHxWQQjeOJP9b)OJ2eIOP9b)rXaD0rmqp(wlJoqNnHxGCKmuqheTOd)wxWkevOJP9b)OJ2eIOP9b)rXaD0rmqp(wlJoAfe5izOGceTOd)wxWkevOJMmotgdD042oowIN3H5ggWC1LXwl8ryj)QCdqU0m3(feS2jytbhfxVL5szU9liyfxwIj(9hxs9wMlDZvQMlnZ1nb)EvQWD0shvelOk)wxWQCdoxAMBGY1nb)ET1isZQiiMevS5fv(TUGv5caa5QXyHch0xBnI0SkcIjrfBErLWT28WCdlxkYLU5sx0X0(GF0HC)OP9b)rXaD0rmqp(wlJoGZpWcKJKHcQr0Io8BDbRquHoM2h8JoAtiIM2h8hfd0rhXa94BTm60VJqHCKmuqdiArh(TUGviQqhnzCMmg6WptcjPQyWrpEUHbmxkAEUuMl)mjKKkHdXp6yAFWp6yeT9C0Xec)oYrYqrGHOfDmTp4hDmI2EowEfqgD436cwHOc5izOO5iArht7d(rhXeQWHrPsxvOw(D0HFRlyfIkKJC0PKWACB3CeTizOarl6WV1fScrfYrYqnIw0HFRlyfIkKJKHgq0Io8BDbRquHCKmbgIw0HFRlyfIkKJKP5iArht7d(rhOZMWlqh(TUGviQqosMagrl6yAFWp6uI9b)Od)wxWkevihjdngrl6WV1fScrf6yAFWp60AePzveetIk28c0rtgNjJHoeBurUb)E1ukyD(Cdl3aJoOtjH142U5riRXVcIonh5izKIiArh(TUGviQqht7d(rhcwiIEbh74NHOtjH142U5riRXVcIouJCKmnlIw0HFRlyfIk0X0(GF0bkgnhTxfvJMrNscRXTDZJqwJFfeDOg5izOGoiArh(TUGviQqht7d(rhtr43eZZrYfwGoLewJB7MhHSg)ki6qbYrYqbfiArh(TUGviQqhnzCMmg60VGGvcwiIEbh74NH1BzUbNRP9Pbh5NBhgMBy5sb6yAFWp60fMIJGIlHib5ihD63rOq0IKHceTOd)wxWkevOJMmotgdD6xqWkUSet87pUK6Tm3GZLM52VGGvPzUmkbFjXGghgTo(6rj4Bf6Mw6CbCUuqNCbaGC7xqWQInfSa71BzUaaqU8ZKqsYfW5gynpx6IoM2h8JoLd0XIiSa7ihjd1iArht7d(rh48d0zse6KrAgD436cwHOc5ihDGoBcVarlsgkq0IoM2h8JowB)clqh(TUGviQqoYrhTcIOfjdfiArh(TUGviQqhnzCMmg6eOCHoBcVGvvtiqht7d(rhTjert7d(JIb6OJyGE8TwgDyiKFndrosgQr0Io8BDbRquHoAY4mzm0jq52VGGvtr43eZZrYfwuVL5gCU8ZKqsQ(0YrhhBTWNBy5sb6yAFWp6ykc)MyEosUWcKJKHgq0Io8BDbRquHoM2h8JoTgrAwfbXKOInVaD0KXzYyOdXgvKBWVxnLcwVL5gCU0mx3iHyV6tlhDCunCUaoxnUTJJL45DyvXGJE8CbaGCduUqNnHxWQkbh6Y5gCUACBhhlXZ7WQIbh945ggWC1LXwl8ryj)QCdqUuKlDrhTeTGJUrcXoejdfihjtGHOfD436cwHOcD0KXzYyOdXgvKBWVxnLcwNp3WYLgOtUbixInQi3GFVAkfSQUeZh8NBW5gOCHoBcVGvvco0LZn4C142oowIN3Hvfdo6XZnmG5QlJTw4JWs(v5gGCPaDmTp4hDAnI0SkcIjrfBEbYrY0CeTOd)wxWkevOJMmotgdDGLSqeDJeIDyUHbmxQZn4CduU9liyTlmfhbfxcrs9wMBW5sZCduUeBurUb)E1ukyLd)aDyUaaqUeBurUb)E1ukyLWT28WCdlxPyUaaqUeBurUb)E1ukyD(CdlxAMl15gGC1ySqHd6RDHP4iO4sisQ6cJeIHrqIP9b)Mix6MRunxQBEU0fDmTp4hD6ctXrqXLqKGCKmbmIw0HFRlyfIk0rtgNjJHonmYyDbx7ctXrqXLqKeHsEDUbNRg32XXs88oSQyWrpEUHbmxkYLYC7xqWANGnfCuC9wIoM2h8JoHkWqxijcDYinJCKm0yeTOd)wxWkevOJMmotgdDAyKX6cU2fMIJGIlHijcL86CdoxAMl)mjKKQpTC0XXwl85gwUnpxaaix(zsij5c4CPO55sx0X0(GF0r6riMpuewsyg5izKIiArh(TUGviQqhnzCMmg60WiJ1fCTlmfhbfxcrsek515gCU8ZKqsQ(0YrhhBTWNBy5sb6yAFWp60fMIJKlSa5izAweTOd)wxWkevOJMmotgdDcuUqNnHxWQQje5gCUnmYyDbxT2(fwe14xn(GF0X0(GF0PH9dSa5izOGoiArh(TUGviQqhnzCMmg6eOCHoBcVGvvtiYn4CByKX6cUAT9lSiQXVA8b)OJP9b)OdSWu4GAzHc5izOGceTOd)wxWkevOJMmotgdD6xqWAxGXkXf6vcBApxaai3(feSAkc)MyEosUWI6TeDmTp4hDkX(GFKJKHcQr0Io8BDbRquHoM2h8JonmYyDbhN35hoUKyOjK1al8igQhHW85dfjSPDmbD0KXzYyOt)ccw7cmwjUqVsyt75caa56tlhDCunCUagyUutNCbaGC142oowIN3Hvfdo6XZfWaZLA05TwgDAyKX6cooVZpCCjXqtiRbw4rmupcH5Zhksyt7ycYrYqbnGOfD436cwHOcD0KXzYyOt)ccw7cmwjUqVsyt75caa56tlhDCunCUagyUutNCbaGC142oowIN3Hvfdo6XZfWaZLA0X0(GF05c544Cle5izOiWq0IoM2h8JoDbgRIGxIe0HFRlyfIkKJKHIMJOfDmTp4hD6mbYePNpe6WV1fScrfYrYqraJOfDmTp4hDahc3fyScD436cwHOc5izOGgJOfDmTp4hDSxZqNyIO2ec0HFRlyfIkKJC0bC(bwGOfjdfiArh(TUGviQqhnzCMmg60VGGvY1lemegljSEGd(R3YCbaGCPzUgGWKX5QInfSa7v(TUGv5caa5AactgNRMMJ3YOe8LeHcMBWv(TUGv5s3Cdo3(feSsWcr0l4yh)mSElrht7d(rNo7bX8h9coYsyiYrYqnIw0HFRlyfIk0rtgNjJHo9liyfkgnhTxfvJMReU1MhMlGZ1Nwo64OA4Cdo3(feScfJMJ2RIQrZvc3AZdZfW5sZCPixkZvJB74yjEEhMlDZvQMlfvPi6yAFWp6afJMJ2RIQrZihjdnGOfD436cwHOcD0KXzYyOt)ccwjyHi6fCSJFgwjCRnpmxadmxAaDmTp4hDiyHi6fCSJFgICKmbgIw0HFRlyfIk0rtgNjJHo0mxt7tdoYp3ommxG5srUaaqU9liyTlmfhbfxcrsvHd6ZLU5gCUnmYyDbxjEpsycwiqht7d(rhcwiIEbh74NHihjtZr0Io8BDbRquHoAY4mzm0XaeMmoxnnhVLrj4ljcfm3GR8BDbRYfaaY1aeMmoxvSPGfyVYV1fScDmTp4hD6SheZF0l4ilHHihjtaJOfDmTp4hDudS0CDb6WV1fScrfYroYrh76fyc6CMwPaYrocb]] )


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