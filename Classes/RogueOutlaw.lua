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
                if combo_points.current == 0 then return false, "no combo points" end

                -- Don't RtB if we've already done a simulated RtB.
                if buff.rtb_buff_1.up then return false, "we already rerolled and can't know which buffs we'll have" end

                --[[ This was based on 8.2 logic; tweaking APL instead to avoid hardcoding.  2020-03-09
                
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
                end ]]

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


    spec:RegisterPack( "Outlaw", 20200401, [[de1RrbqiQQ6rQsztOK(evbzusjDkPeRskv5vOunluIBrvj7Ik)Isyyuv5yeOLHI6zeqnnvPQRPkv2MuQQVjLk14iuLZrvaRJasZJQO7Hc7tkLdsvilKq5HufOjsOsxukvyJeQWhLsLWijurYjjuvALQsEjHQIzsOIOBsaHDsvXpjurnuPurhLqfPwkvH6PQQPsj6QufuBLqfHVsarJvkvsDwPujAVe9xsgSkhwyXk8ykMmPUmYMv0NPKgTQ40kTAPuj51OiZgv3wk2nOFdz4uQJtOQA5aphQPl66s12Pk9DukJNQsDEcA9eG5ti7xYsbLwk)6ijPpm7hZ(5379tqNFEa)yMzpG8NcTj53ommfwj5hgnK8lo3tEWM8Bhc5OqlTu(XOoWqY)tM2ybQfwyDZN(WzqnwG3MopYfbnGyMwG3gJfY)OV8u8fkhYVoss6dZ(XSF(9E)e05NhWpM9RDl)yBYi9H523p5)z1AckhYVMWg5)T6eN7jpyRopgzTt1R3Q7jtBSa1clSU5tF4mOglWBtNh5IGgqmtlWBJXI61B15r2GLxNGSuhZ(XSF1R61B15bFcOvclqRxVvNVQZJ0AsxN4ZAyQUevNMMrNN1fMCrW64loD1R3QZx15rAnPRZgqguZiY6eJhAQoXbVdacRRvnIWqpuw3aqbt19tk45tlU61B15R6exe0dL11XuDjyHmrjUUfwhoPGNpU61B15R6exe0dL11XuDnluG2UUUjcuNarayI01nrG6exkYN6ADtpeUoikRd3TTrGK0T4QxVvNVQZJ8IwDDacG48fATopofRoDhSqR1jgp0uDIdEhaewxRDiNW46yJQdb5cR7j8s1jyDzaSszlU61B15R68yIh(UoXNLZxO16(2aIC1R3QZx15HXuD52qQeP0lv3ebQJGguhMeOocQxO16ar(qG6YNawxgaRu6YTHujsPxYvVERoFvNhgt15XPy1biaIZRJJSUM6cOUUpuCRdqtaHFQJJSUM6wyD5dvNnGmOMrK1fMCrW64loDYVnanxoj)VvN4Cp5bB15XiRDQE9wDpzAJfOwyH1nF6dNb1ybEB68ixe0aIzAbEBmwuVERopYgS86eKL6y2pM9REvVERop4taTsybA96T68vDEKwt66eFwdt1LO600m68SUWKlcwhFXPRE9wD(QopsRjDD2aYGAgrwNy8qt1jo4DaqyDTQreg6HY6gakyQUFsbpFAXvVERoFvN4IGEOSUoMQlblKjkX1TW6Wjf88XvVERoFvN4IGEOSUoMQRzHc0211nrG6eicatKUUjcuN4sr(uxRB6HW1brzD4UTncKKUfx96T68vDEKx0QRdqaeNVqR15XPy1P7GfAToX4HMQtCW7aGW6ATd5egxhBuDiixyDpHxQobRldGvkBXvVERoFvNht8W31j(SC(cTw33gqKRE9wD(QopmMQl3gsLiLEP6MiqDe0G6WKa1rq9cTwhiYhcux(eW6YayLsxUnKkrk9sU61B15R68WyQopofRoabqCEDCK11uxa119HIBDaAci8tDCK11u3cRlFO6SbKb1mISUWKlcwhFXPREvVERU2HVjtpjDDdAIauDguZiY6gK1fID15rgdzN46GiOVEcqZSZRlm5IG46qqUqx96T6ctUii2zdidQzejJjpWmvVERUWKlcID2aYGAgrYodlIU1gcMrUiy96T6ctUii2zdidQzej7mSyIq661B19HHn(bL1bIvx3OpNKUoCgjUUbnraQodQzezDdY6cX1fqDD2aYx2OmxO16wCDAeKC1R3Qlm5IGyNnGmOMrKSZWcmmSXpOuHZiX1RWKlcID2aYGAgrYodlAcatKwnraLMI8HfBazqnJivyYGGAmJ3XYozaIvRiVemDHwJDlST37x9km5IGyNnGmOMrKSZWcCsbpFyzNmA1Fs83xBBs7SrgMOeVcG0kdQXUNrUiOstExdjsK)geIRrSbDgHgokbi4AudEGtNUdICrqrIaXQvKxcMUf6TZHeigCYr(EXjUL61B15XeaX51nrG6yM96qG6AxacOUobcItuDiqDECpF4egxx7eqMfViOREfMCrqm7mSWBa2yWjwGrdXaKdfGaioNfVbVtma5qn6Zj2tMz1)rFoDwbbuRAiorUUnR(p6ZPd0ZhoHXkBazw8IGUUD96T68ycG486MiqDmZEDJ(CIRdbQtmak04vt1X2Mp1jUuOXpO0vVctUiiMDgw4naBm4elWOHyaYHcqaeNZcYMbMsw2jJqaeytYPPqJFqPJGXGtAw8g8oXaKd1OpNypzM1wh950XrHM0k9Aix3wKi)h950naOqJxn562TuVERopMaioVUjcuhZSx3OpN46qG684E(WjmUU2jGmlErW6yBZN68idvx3UoHOoOUpNiVel11HCcJRlFiavxaO6AqaQoXLcn(bL1bcityx9km5IGy2zyH3aSXGtSaJgIbihkabqColiBgykzzNmcbqGnjxyiv3wje1bkmNiVKJGXGtAwdbqGnjxyiv3wje1bkmNiVKdeqMAJriacSj50uOXpO0bcitS4n4DIbihQrFoXEYmRTo6ZPJJcnPv61qUUTirJ(C6a98HtySYgqMfViOdqnXcXEYWGqCnInOBqjBebv5dPiHe2bOMyH4wQxVvhZSx3hgmr11oesybADEeNTqiUoabqCEDteOoMzVUrFoXU6vyYfbXSZWcVbyJbNybgnedqouacG4Cwq2mWuYYozecGaBsommyIuKqc7abKP2yWmlEdENyaYHA0NtSNmxVERoMzVUpmyIQRDiKWc06exuDquwhGaioVo228PoMzVoCggMW1HM1LpuDFyWevx7qiHRB0NZ6Avq2RdNHHP6yBZN6edGcnE1uDD7wC1RWKlcIzNHfEdWgdoXcmAigGCOaeaX5SGSzaimLSStgHaiWMKdddMifjKWoqazQngmZ6OpNommyIuKqc7WzyyQngm7RrFoDdak04vtUUD96T6ei38PoX4HMQtCW7aGW662Su3AfIauDGoNW1fdKxQUaQRldMO6iVeqy(SqR1Lprw3IRJz2RRvikRZG6WCHwR7hEWwQdbQdVqRCQoX(Sux7cbcwQZJBN1RWKlcIzNHfEdWgdoXcmAigGCOaeaX5SGSzGPKLDYy0Nt3GhAsn5DaqORBZI3G3jgGCOg95e7RrFoDyM6CUkGALbGW4bcsyx32tMzT1rFoDCuOjTsVgY1TfjY)rFoDwbbuRAiorUUnR(p6ZPd0ZhoHXkBazw8IGUUnR(p6ZPBaqHgVAY1TBPE9wDcKB(uN4KOqt66e31q11TzPoabqCEDbuyD4fALt1n6Zjl1fqH1XCDJ(CwhBB(uNyDWs66SeqbUdiwQdbQBH1zhqn1Sgx9km5IGy2zyH3aSXGtSaJgIbihkabqColiBgykzzNmg950XrHM0k9Aix3MfVbVtmAfKd1OpNyFn6ZPB0blPvjGcChqUUDlEYSirJ(C6aioxLpKAGGe2bOMyHypf0pN4XERc6eV2ldobtNMiBcOWjiYWk14iym4KUL6vyYfbXoBazqnJizNHfaeNRYhsnqqcZInGmOMrKkmzqqnMbZSStgJ(C6aioxLpKAGGe2bOMyHypziWIe5naBm4KdKdfGaioVEfMCrqSZgqguZis2zybMVgsfqTsVgIfBazqnJivyYGGAmdMzzNmg950H5RHubuR0RHCaQjwi2ZCBivIu6LyD0NthMVgsfqTsVgYbOMyHypBvq2nOMbszJwyIBP9e0jE1RWKlcID2aYGAgrYodlcnGGbFHKc0XpSydidQzePctgeuJziil7KrR(tI)(ABtANnYWeL4vaKwzqn29mYfbvAY7AirI83GqCnInOZi0WrjabxJAWdC60DqKlckseiwTI8sW0TqVDoKaXGtoY3loXTuVctUii2zdidQzej7mSOJj1MudlWOHyeca)eGaRMiyQqtLnIncuVctUii2zdidQzej7mSOJj1Mudl0CsMubJgIHrOHJsacUg1Gh4KLDYWFqSAf5LGPBHE7CibIbNCKVxCIRxHjxee7SbKb1mIKDgwyJYfbRx1R3QRD4BY0tsxh5LacRl3gQU8HQlmjcu3IRl8glpgCYvVERopMWjf88PUDwNncJ3bNQRviQoVDoKaXGt1rqQzjCDlSodQzezl1RWKlcIzW0AyILDYWFCsbpFiTdGS2P6vyYfbXmWjf88PEfMCrqm7mSWBa2yWjwGrdXiAgD8JYGG6nxeKfVbVtmmOMbszJwyIDAAUMnBJbZSZC71AgCcMoRpiCYfQWjyzICemgCsZQbH4AeBqN1heo5cv4eSmroa1ele7PGTW(OpNUbafA8Qjx3MvcsaRcBR99Jv)h950HzQZ5QaQvgacJhiiHDDBw9F0NthtezReI6afBBIvXa1tLqu31TRxHjxeeZodl8gGngCIfy0qmgjPmiOEZfbzXBW7eJrFoDGE(WjmwzdiZIxe01TfjQ1qaeytYPPqJFqPJGXGtArIcbqGnjxyiv3wje1bkmNiVKJGXGt6wyD0NthaX5Q8HudeKWUUD96T6ei38PUMopxBovxgaRuIzPU8zX15naBm4uDlUoZdzyI01LO60Kz1uDS9q5dbQdJAO68GIlUo8dQZ11nO6WcHgsxhBB(uNy8qt1jo4Daqy9km5IGy2zyH3aSXGtSaJgIXGhAsn5DaqOcleAyXBW7edSnX5QmawPe7g8qtQjVdac9KzwbXQvKxcMUqRXUf2gZ(js0OpNUbp0KAY7aGqx3UEfMCrqm7mSWeCUkm5IGk(ItwGrdXaNuWZhw2jdCsbpFiTl486vyYfbXSZWctW5QWKlcQ4lozbgnedJgxVERoXXcx8tDrwxt47TP3uNhSD6Q73h4eeMSoeKQBIa1rH5PoXaOqJxnvxa11joBBJazhUPW6y7HG1joDFnmvN4cc2QBX1Hjozssxxa11jqmf36wCDquwhGcTW6IzsG6YhQoi57SomzqqTRopIZwiexxt476elBh1X2Mp1Xm715rgYvVctUiiMDgwa6qvyYfbv8fNSaJgIXCHl(HLDYWGAgiLnAHjUnggBvt4Bf2MGAF16OpNUbafA8Qjx3M9rFoDiBBei7Wnf662T0ETMbNGPt83xdtkniyZrWyWjnRT6FgCcMUMaWePvteqPPiFCemgCslsKbH4AeBqxtayI0QjcO0uKpoa1ele3MGT0s71AiacSj5cdP62kHOoqH5e5LCGaYKNmlsK)geIRrSbDdkzJiOkFifjKWUUTir(p6ZPdG4Cv(qQbcsyx3UL6vyYfbXSZWctW5QWKlcQ4lozbgneJrF566vyYfbXSZWIayciPseaqWKLDYGGeWQqNMMRzZ2yi47yNGeWQqhGSsW6vyYfbXSZWIayciPS7CmvVctUiiMDgwWxRpjw1UQRT2qWSEfMCrqm7mSyewvOPkbRHjC9QE9wDI1xUMa461B15HXuDTZfNiED)huw3oRBZ6ydb9qzDMWUodQzGQZgTWexxa11LpuDIZ22iq2HBkSUrFoRBX11TD15rErRUUoEHwRJThcwN4dr211Ue1b1jqUjUoCggMW1faQUN16tDiqDS9qW664fATobskSrWMaNeGL66qoHX1LpuDIlfA8dkRB0NZ6wCDDBx9km5IGy3OVCnd7fNiUc)Gsw2jJwZGtW0j(7RHjLgeS5iym4KwKOqaeytYXer2kHOoqX2Myvmq9uje1DGaYKNm3cRJ(C6q22iq2HBk01TzT1rFoDmrKTsiQduSTjwfdupvcrDhoddtEk47fjIGeWQqpF)7APEfMCrqSB0xUMDgwyV4eXv4huYYozm6ZPdzBJazhUPqx3M1rFoDAk04hu6621RWKlcIDJ(Y1SZWc8cxCsafobltu9QE9wDEqeIRrSbX1RWKlcIDgnMHj4CvyYfbv8fNSaJgIbHXe0qyw2jd)Xjf88H0UGZRxHjxee7mAm7mSi0acg8fskqh)WYoz4)OpNUqdiyWxiPaD8JRBZAR(tI)(ABtAxia8tacSAIGPcnv2i2iGirgeIRrSbD8ijyQcGjGHdqnXcXTXSFTuVERoX3zDHwJRlauDDBwQddxBQU8HQdbP6yBZN64i2iCwNLwkUU68WyQo2EiyDAHl0ADZaNeOU8jG15bBN1PP5A2SoeOo228b1Z6cOW68GTtx9km5IGyNrJzNHfnbGjsRMiGstr(WIrOHtQmawPeZqqw2jdqSAf5LGPl0ASRBZARzaSsPl3gsLiLEjpnOMbszJwyIDAAUMnfjYFCsbpFiTdGS2jwnOMbszJwyIDAAUMnBJHXw1e(wHTjO2xc2s96T6eFN1br1fAnUo2woVo9s1X2MplSU8HQds(oRtG9dZsDDmvNaXuCRdbRBGW46yBZhupRlGcRZd2oD1RWKlcIDgnMDgw0eaMiTAIaknf5dl7KbiwTI8sW0fAn2TW2ey)8fiwTI8sW0fAn2P7GixeKv)Xjf88H0oaYANy1GAgiLnAHj2PP5A2SnggBvt4Bf2MGAFjy96T6eJhAQoXbVdacRdbRJz2RJGuZsyxDcKB(uxO1ybADEymv3oRlFiH1HZqyDteOoXJ96WKbb146qG62zDcrDqDqY3zDMNayLQJTLZRBq1bOqlSUfwxUnuDteOU8HQds(oRJTWl5QxHjxee7mAm7mSyWdnPM8oaiKLDYaBtCUkdGvkXTXGzw9F0Nt3GhAsn5DaqORBZAR(dIvRiVemDHwJDKVxCIfjceRwrEjy6cTg7autSqCBINirGy1kYlbtxO1y3cBRvM9LbH4AeBq3GhAsn5DaqOZ8eaRewnbHjxem4T0Em)UwQxHjxee7mAm7mSW6dcNCHkCcwMiw2jdVbyJbNCdEOj1K3baHkSqOHvdQzGu2OfMyNMMRzZ2yii7J(C6gauOXRMCD76vyYfbXoJgZodlyA58fAvHTbeXYoz4naBm4KBWdnPM8oaiuHfcnS2kbjGvHUCBivIunHVB7DIerqcyvONc(UwQxHjxee7mAm7mSyWdnPaD8dl7KH3aSXGtUbp0KAY7aGqfwi0WkbjGvHUCBivIunHVBtqwB1)rFoDHgqWGVqsb64hx3wKicsaRc989VRL61B15HXl0ADIteWf)yHh1m64N6wCDiixyDrDEjGW6YfkSUfAauGjwQdJQBH1bOGVPqwQtiQ7HauDXaJ49K4cRBUqQUevxht1TzDbUUOUEU8nfwh2M4Cx9km5IGyNrJzNHfEd4IFyzNm8hNuWZhs7coNvVbyJbNCrZOJFugeuV5IG1RWKlcIDgnMDgwGFcnITgIRzzNm8hNuWZhs7coNvVbyJbNCrZOJFugeuV5IG1RWKlcIDgnMDgwyJYfbzzNmg950n4iKM3XPdqHjfjA0NtxObem4lKuGo(X1TRxVvN4i48fATUryyQUevNMMrNN1Tj1uxhhwP6vyYfbXoJgZodl6ysTj1WcmAigEdWgdoPwysq8McvwxRHxepviSz58ixOvfGctIaSStgJ(C6gCesZ740bOWKIeLBdPsKsVKNmy2prImOMbszJwyIDAAUMn9KbZ1RWKlcIDgnMDgw0XKAtQbZYozm6ZPBWrinVJthGctksuUnKkrk9sEYGz)ejYGAgiLnAHj2PP5A20tgmxVctUii2z0y2zyXGJqA1SdewVctUii2z0y2zyXGaycW0cTwVctUii2z0y2zyXCb0GJq66vyYfbXoJgZodlcOHWji4ktW51RWKlcIDgnMDgw0XKAtQHfAojtQGrdXWi0WrjabxJAWdCYYoz4poPGNpK2fCoRJ(C6cnGGbFHKc0XponIniRJ(C6AOgeqOcnv8Uz1knGIgStJydYkbjGvHUCBivIunHVB79ScYHA0NtSNVREfMCrqSZOXSZWIoMuBsnSaJgIria8tacSAIGPcnv2i2ial7KH)J(C6cnGGbFHKc0XpUUnR(p6ZPBWdnPM8oai01Tz1GqCnInOl0acg8fskqh)4autSqSNc(U61B1jobbewha1T(WfwhOZP6qZ6YNEZyNlPRRjYhCDdIJytGwNhgt1nrG6eFHmzJ01zaBYsDO8HaSTyQo228PopYJRlY6y2p2RdNHHjCDiqDc6h71X2Mp1fCmQoX4iKUUUTREfMCrqSZOXSZWIoMuBsnSaJgIrGF8gqcRaHaqaLbbcol7KHMg950bcbGakdceCLMg950PrSbfjstJ(C6miOUBY1lPwitknn6ZPRBZAgaRu6EOGNpoBt6PaZmRzaSsP7HcE(4SnzBmey)ejYFnn6ZPZGG6UjxVKAHmP00OpNUUnRTQPrFoDGqaiGYGabxPPrFoD4mmm1gdM9Zxc6x7PPrFoDdocPvOPkFifbPgHUUTirzaSsPl3gsLiLEjpBF)AH1rFoDHgqWGVqsb64hhGAIfIBtqXRE9wDIlnJopRBgC(immv3ebQRJJbNQBtQb7QxHjxee7mAm7mSOJj1MudMLDYy0Nt3GJqAEhNoafMuKOCBivIu6L8KbZ(jsKb1mqkB0ctSttZ1SPNmyUEvVERU2bgtqdHRxHjxee7imMGgcZWGGgcMGijTAYJgILDYGGeWQqxUnKkrQMW3TjiR(p6ZPBWdnPM8oai01TzTv)1O0zqqdbtqKKwn5rdPgDa0LRHPfALv)dtUiOZGGgcMGijTAYJgYTq1KVwFsrIMDoxbiZtaSsQCBipTA0UMW3TuVctUii2rymbneMDgwm4iKwHMQ8HueKAeYYoz4naBm4KBWdnPM8oaiuHfcnSAqiUgXg0nOKnIGQ8HuKqc762S6naBm4KBKKYGG6nxeSEfMCrqSJWycAim7mSWApa6nGk0ufcGaO8PEfMCrqSJWycAim7mSyImDmPvHaiWMKAqrdl7Kb2M4CvgaRuIDdEOj1K3baHTXGzrIaXQvKxcMUqRXUf2w77hR(p6ZPl0acg8fskqh)4621RWKlcIDegtqdHzNHf2DWofUqRQbpWjl7Kb2M4CvgaRuIDdEOj1K3baHTXGzrIaXQvKxcMUqRXUf2w77x9km5IGyhHXe0qy2zyr(qQoCG6qTAIagILDYy0NthGmmXjmwnrad562Ien6ZPdqgM4egRMiGHuguhMeWHZWWKNc6x9km5IGyhHXe0qy2zybyTT5KAHkSDyO6vyYfbXocJjOHWSZWc2qaU2lTqfGWiyanu9km5IGyhHXe0qy2zyrd1GacvOPI3nRwPbu0GzzNmiibSk0Z3)U61B1jofIRRZJPWEHwRtCWJgcx3ebQJ8nz6jvhiGwP6qG6yA586g95eZsD7SoBegVdo5QZJ4SfcX1LaH1LO6SszD5dvhhXgHZ6miexJydw3iWKUoeSUWBS8yWP6ii1Se2vVctUii2rymbneMDgwaOWEHwvtE0qywmcnCsLbWkLygcYYozKbWkLUCBivIu6L8uq37ejQ1wZayLs3df88XzBY2ep)ejkdGvkDpuWZhNTj9KbZ(1cRTgMC9skcsnlHziOirzaSsPl3gsLiLEP2y2d0slIe1AgaRu6YTHujszBsfZ(1Ma7hRTgMC9skcsnlHziOirzaSsPl3gsLiLEP2E)7BPL6v96T6ehlCXpeaxVERoXY2rDiVeOopofRoabqCoUo228PoXLcn(bLw4rgQUeeBIRdbQZJ75dNW46ANaYS4fbD1RWKlcIDZfU4hgdkzJiOkFifjKWSStgEdWgdo5gjPmiOEZfbRxHjxee7MlCXpSZWcmFnKkGALEnel7KXOpNomFnKkGALEnKdqnXcXEMBdPsKsVeRJ(C6W81qQaQv61qoa1ele7zRcYUb1mqkB0ctClTNGoXREfMCrqSBUWf)WodlaioxLpKAGGeMLDYy0NthaX5Q8HudeKWoa1ele7jdbwKiVbyJbNCGCOaeaX51R3QtSSDuhBB(ux(q15rgQopSDDTlrDqDForEP6qG6exk04huwxcInXU6vyYfbXU5cx8d7mSyqjBebv5dPiHeMLDYieab2KCHHuDBLquhOWCI8socgdoPfjkeab2KCAk04hu6iym4KUEfMCrqSBUWf)Wodl0l2osZt9QE9wD)KcE(uVctUii2Htk45dJOz0XpYVxcGxeu6dZ(XSF(jWcSFYpBbaUqRy5x8TXgbssxx7UUWKlcwhFXj2vVKF(ItS0s5NWycAiS0sPpckTu(jym4KwkM8BaBsGnKFcsaRcD52qQePAcFxxB1jyDSwN)1n6ZPBWdnPM8oai01TRJ16ATo)RtJsNbbnembrsA1KhnKA0bqxUgMwO16yTo)Rlm5IGodcAiycIK0QjpAi3cvt(A9jRtKO6MDoxbiZtaSsQCBO68SoRgTRj8DDTi)Hjxeu(niOHGjissRM8OHKP0hMLwk)emgCslft(nGnjWgYV3aSXGtUbp0KAY7aGqfwi0uhR1zqiUgXg0nOKnIGQ8HuKqc7621XADEdWgdo5gjPmiOEZfbL)WKlck)docPvOPkFifbPgHYu6JalTu(dtUiO8BTha9gqfAQcbqau(i)emgCslftMsFEV0s5NGXGtAPyYVbSjb2q(X2eNRYayLsSBWdnPM8oaiSU2yuhZ1jsuDGy1kYlbtxO1y3cRRT6AF)QJ168VUrFoDHgqWGVqsb64hx3w(dtUiO8prMoM0QqaeytsnOOrMsFEN0s5NGXGtAPyYVbSjb2q(X2eNRYayLsSBWdnPM8oaiSU2yuhZ1jsuDGy1kYlbtxO1y3cRRT6AF)K)WKlck)2DWofUqRQbpWPmL(0(slLFcgdoPLIj)gWMeyd5F0NthGmmXjmwnrad5621jsuDJ(C6aKHjoHXQjcyiLb1HjbC4mmmvNN1jOFYFyYfbL)8HuD4a1HA1ebmKmL(0ULwk)Hjxeu(bRTnNuluHTddj)emgCslftMsFepPLYFyYfbLF2qaU2lTqfGWiyanK8tWyWjTumzk9XdiTu(jym4KwkM8BaBsGnKFcsaRcRZZ6E)7K)WKlck)nudciuHMkE3SALgqrdwMsFe0pPLYpbJbN0sXK)WKlck)akSxOv1Khnew(nGnjWgYFgaRu6YTHujsPxQopRtq37QtKO6ATUwRldGvkDpuWZhNTjRRT6ep)QtKO6YayLs3df88XzBY68KrDm7xDTuhR11ADHjxVKIGuZs46yuNG1jsuDzaSsPl3gsLiLEP6ARoM9a11sDTuNir11ADzaSsPl3gsLiLTjvm7xDTvNa7xDSwxR1fMC9skcsnlHRJrDcwNir1LbWkLUCBivIu6LQRT6E)7RRL6Ar(ncnCsLbWkLyPpcktzk)AAgDEkTu6JGslLFcgdoPLIj)iB5htP8hMCrq53Ba2yWj53BW7K8dYHA0NtCDEwhZ1XAD(x3OpNoRGaQvneNix3UowRZ)6g950b65dNWyLnGmlErqx3w(9gafmAi5hKdfGaioxMsFywAP8tWyWjTum5hzl)ykL)WKlck)EdWgdoj)EdENKFqouJ(CIRZZ6yUowRR16g950XrHM0k9Aix3UorIQZ)6g950naOqJxn56211I8BaBsGnK)qaeytYPPqJFqPJGXGtA53BauWOHKFqouacG4Czk9rGLwk)emgCslft(r2YpMs5pm5IGYV3aSXGtYV3G3j5hKd1OpN468SoMRJ16ATUrFoDCuOjTsVgY1TRtKO6g950b65dNWyLnGmlErqhGAIfIRZtg1zqiUgXg0nOKnIGQ8HuKqc7autSqCDTi)gWMeyd5peab2KCHHuDBLquhOWCI8socgdoPRJ16cbqGnjxyiv3wje1bkmNiVKdeqMQRng1fcGaBsonfA8dkDGaYK87naky0qYpihkabqCUmL(8EPLYpbJbN0sXKFKT8JPu(dtUiO87naBm4K87n4Ds(b5qn6ZjUopRJz53a2KaBi)HaiWMKdddMifjKWoqazQU2yuhZYV3aOGrdj)GCOaeaX5Yu6Z7Kwk)emgCslft(r2YpGWuk)Hjxeu(9gGngCs(9gafmAi5hKdfGaiox(nGnjWgYFiacSj5WWGjsrcjSdeqMQRng1XCDSw3OpNommyIuKqc7WzyyQU2yuhZ15R6g950naOqJxn562Yu6t7lTu(jym4KwkM8JSLFmLYFyYfbLFVbyJbNKFVbVtYpihQrFoX15R6g950HzQZ5QaQvgacJhiiHDD768SoMRJ16ATUrFoDCuOjTsVgY1TRtKO68VUrFoDwbbuRAiorUUDDSwN)1n6ZPd0ZhoHXkBazw8IGUUDDSwN)1n6ZPBaqHgVAY1TRRf53a2KaBi)J(C6g8qtQjVdacDDB53BauWOHKFqouacG4Czk9PDlTu(jym4KwkM8JSLFmLYFyYfbLFVbyJbNKFVbVtYFR1bYHA0NtCD(QUrFoDJoyjTkbuG7aY1TRRL68SoMRtKO6g950bqCUkFi1abjSdqnXcX15zDc6Nt8QJ96ATobDIxDTxDzWjy60eztafobrgwPghbJbN011I8BaBsGnK)rFoDCuOjTsVgY1TLFVbqbJgs(b5qbiaIZLP0hXtAP8tWyWjTum53a2KaBi)(xhoPGNpK2bqw7K8hMCrq5NP1WKmL(4bKwk)Hjxeu(Xjf88r(jym4KwkMmL(iOFslLFcgdoPLIj)iB5htP8hMCrq53Ba2yWj53BW7K8BqndKYgTWe700CnBwxBmQJ56yVoMRR9QR16YGtW0z9bHtUqfobltKJGXGt66yTodcX1i2GoRpiCYfQWjyzICaQjwiUopRtW6APo2RB0Nt3aGcnE1KRBxhR1rqcyvyDTvx77xDSwN)1n6ZPdZuNZvbuRmaegpqqc7621XAD(x3OpNoMiYwje1bk22eRIbQNkHOURBl)EdGcgnK8hnJo(rzqq9MlcktPpckO0s5NGXGtAPyYpYw(Xuk)Hjxeu(9gGngCs(9g8oj)J(C6a98HtySYgqMfViORBxNir11ADHaiWMKttHg)GshbJbN01jsuDHaiWMKlmKQBReI6afMtKxYrWyWjDDTuhR1n6ZPdG4Cv(qQbcsyx3w(9gafmAi5FKKYGG6nxeuMsFeKzPLYpbJbN0sXKFKT8JPu(dtUiO87naBm4K87n4Ds(X2eNRYayLsSBWdnPM8oaiSopRJ56yToqSAf5LGPl0ASBH11wDm7xDIev3OpNUbp0KAY7aGqx3w(9gafmAi5FWdnPM8oaiuHfcnYu6JGcS0s5NGXGtAPyYVbSjb2q(Xjf88H0UGZL)WKlck)MGZvHjxeuXxCk)8fNky0qYpoPGNpYu6JGVxAP8tWyWjTum5pm5IGYVj4CvyYfbv8fNYpFXPcgnK8B0yzk9rW3jTu(jym4KwkM8BaBsGnKFdQzGu2OfM46AJrDgBvt4Bf2MG668vDTw3OpNUbafA8Qjx3Uo2RB0NthY2gbYoCtHUUDDTux7vxR1LbNGPt83xdtkniyZrWyWjDDSwxR15FDzWjy6AcatKwnraLMI8XrWyWjDDIevNbH4AeBqxtayI0QjcO0uKpoa1elexxB1jyDTuxl11E11ADHaiWMKlmKQBReI6afMtKxYbcit15zDmxNir15FDgeIRrSbDdkzJiOkFifjKWUUDDIevN)1n6ZPdG4Cv(qQbcsyx3UUwK)WKlck)GoufMCrqfFXP8ZxCQGrdj)ZfU4hzk9rW2xAP8tWyWjTum5pm5IGYVj4CvyYfbv8fNYpFXPcgnK8p6lxltPpc2ULwk)emgCslft(nGnjWgYpbjGvHonnxZM11gJ6e8D1XEDeKawf6aKvck)Hjxeu(dGjGKkraabtzk9rqXtAP8hMCrq5paMask7ohtYpbJbN0sXKP0hb9aslL)WKlck)816tIvTR6ARnemLFcgdoPLIjtPpm7N0s5pm5IGY)iSQqtvcwdty5NGXGtAPyYuMYVnGmOMrKslL(iO0s5NGXGtAPyYFyYfbL)MaWePvteqPPiFKFdytcSH8dIvRiVemDHwJDlSU2Q79(j)2aYGAgrQWKbb1y5)DYu6dZslLFcgdoPLIj)gWMeyd5V168Vos83xBBs7SrgMOeVcG0kdQXUNrUiOstExdvNir15FDgeIRrSbDgHgokbi4AudEGtNUdICrW6ejQoqSAf5LGPBHE7CibIbNCKVxCIRRf5pm5IGYpoPGNpYu6JalTu(jym4KwkM8hMCrq5hG4Cv(qQbcsy53a2KaBi)J(C6aioxLpKAGGe2bOMyH468KrDcCDIevN3aSXGtoqouacG4C53gqguZisfMmiOgl)mltPpVxAP8tWyWjTum5pm5IGYpMVgsfqTsVgs(nGnjWgY)OpNomFnKkGALEnKdqnXcX15zD52qQeP0lvhR1n6ZPdZxdPcOwPxd5autSqCDEwxR1jyDSxNb1mqkB0ctCDTux7vNGoXt(TbKb1mIuHjdcQXYpZYu6Z7Kwk)emgCslft(dtUiO8hAabd(cjfOJFKFdytcSH83AD(xhj(7RTnPD2idtuIxbqALb1y3ZixeuPjVRHQtKO68VodcX1i2GoJqdhLaeCnQbpWPt3brUiyDIevhiwTI8sW0TqVDoKaXGtoY3loX11I8BdidQzePctgeuJLFbLP0N2xAP8tWyWjTum5hgnK8hca)eGaRMiyQqtLnInci)Hjxeu(dbGFcqGvtemvOPYgXgbKP0N2T0s5NGXGtAPyYFyYfbLFJqdhLaeCnQbpWP8BaBsGnKF)RdeRwrEjy6wO3ohsGyWjh57fNy5NMtYKky0qYVrOHJsacUg1Gh4uMsFepPLYFyYfbLFBuUiO8tWyWjTumzkt5F0xUwAP0hbLwk)emgCslft(nGnjWgYFR1LbNGPt83xdtkniyZrWyWjDDIevxiacSj5yIiBLquhOyBtSkgOEQeI6oqazQopRJ56APowRB0NthY2gbYoCtHUUDDSwxR1n6ZPJjISvcrDGITnXQyG6PsiQ7WzyyQopRtW3xNir1rqcyvyDEw37FxDTi)Hjxeu(TxCI4k8dkLP0hMLwk)emgCslft(nGnjWgY)OpNoKTncKD4McDD76yTUrFoDAk04hu662YFyYfbLF7fNiUc)Gszk9rGLwk)Hjxeu(XlCXjbu4eSmrYpbJbN0sXKPmLFCsbpFKwk9rqPLYFyYfbL)Oz0XpYpbJbN0sXKPmLFJglTu6JGslLFcgdoPLIj)gWMeyd53)6Wjf88H0UGZL)WKlck)MGZvHjxeuXxCk)8fNky0qYpHXe0qyzk9HzPLYpbJbN0sXKFdytcSH87FDJ(C6cnGGbFHKc0XpUUDDSwxR15FDK4VV22K2fca)eGaRMiyQqtLnIncuNir1zqiUgXg0XJKGPkaMagoa1elexxB1XSF11I8hMCrq5p0acg8fskqh)itPpcS0s5NGXGtAPyYFyYfbL)MaWePvteqPPiFKFdytcSH8dIvRiVemDHwJDD76yTUwRldGvkD52qQeP0lvNN1zqndKYgTWe700CnBwNir15FD4KcE(qAhazTt1XADguZaPSrlmXonnxZM11gJ6m2QMW3kSnb115R6eSUwKFJqdNuzaSsjw6JGYu6Z7Lwk)emgCslft(nGnjWgYpiwTI8sW0fAn2TW6ARob2V68vDGy1kYlbtxO1yNUdICrW6yTo)RdNuWZhs7aiRDQowRZGAgiLnAHj2PP5A2SU2yuNXw1e(wHTjOUoFvNGYFyYfbL)MaWePvteqPPiFKP0N3jTu(jym4KwkM8BaBsGnKFSnX5QmawPexxBmQJ56yTo)RB0Nt3GhAsn5DaqORBxhR11AD(xhiwTI8sW0fAn2r(EXjUorIQdeRwrEjy6cTg7autSqCDTvN4vNir1bIvRiVemDHwJDlSU2QR16yUoFvNbH4AeBq3GhAsn5DaqOZ8eaRewnbHjxem411sDTxDm)U6Ar(dtUiO8p4HMutEhaektPpTV0s5NGXGtAPyYVbSjb2q(9gGngCYn4HMutEhaeQWcHM6yTodQzGu2OfMyNMMRzZ6AJrDcwh71n6ZPBaqHgVAY1TL)WKlck)wFq4KluHtWYejtPpTBPLYpbJbN0sXKFdytcSH87naBm4KBWdnPM8oaiuHfcn1XADTwhbjGvHUCBivIunHVRRT6ExDIevhbjGvH15zDc(U6Ar(dtUiO8Z0Y5l0QcBdisMsFepPLYpbJbN0sXKFdytcSH87naBm4KBWdnPM8oaiuHfcn1XADeKawf6YTHujs1e(UU2QtW6yTUwRZ)6g950fAabd(cjfOJFCD76ejQocsaRcRZZ6E)7QRf5pm5IGY)GhAsb64hzk9XdiTu(jym4KwkM8BaBsGnKF)RdNuWZhs7coVowRZBa2yWjx0m64hLbb1BUiO8hMCrq53Bax8JmL(iOFslLFcgdoPLIj)gWMeyd53)6Wjf88H0UGZRJ168gGngCYfnJo(rzqq9Mlck)Hjxeu(XpHgXwdX1Yu6JGckTu(jym4KwkM8BaBsGnK)rFoDdocP5DC6auyY6ejQUrFoDHgqWGVqsb64hx3w(dtUiO8BJYfbLP0hbzwAP8tWyWjTum5pm5IGYV3aSXGtQfMeeVPqL11A4fXtfcBwopYfAvbOWKiG8BaBsGnK)rFoDdocP5DC6auyY6ejQUCBivIu6LQZtg1XSF1jsuDguZaPSrlmXonnxZM15jJ6yw(Hrdj)EdWgdoPwysq8McvwxRHxepviSz58ixOvfGctIaYu6JGcS0s5NGXGtAPyYVbSjb2q(h950n4iKM3XPdqHjRtKO6YTHujsPxQopzuhZ(vNir1zqndKYgTWe700CnBwNNmQJz5pm5IGYFhtQnPgSmL(i47Lwk)Hjxeu(hCesRMDGq5NGXGtAPyYu6JGVtAP8hMCrq5FqambyAHwLFcgdoPLIjtPpc2(slL)WKlck)ZfqdocPLFcgdoPLIjtPpc2ULwk)Hjxeu(dOHWji4ktW5YpbJbN0sXKP0hbfpPLYpbJbN0sXK)WKlck)gHgokbi4AudEGt53a2KaBi)(xhoPGNpK2fCEDSw3OpNUqdiyWxiPaD8JtJydwhR1n6ZPRHAqaHk0uX7MvR0akAWonInyDSwhbjGvHUCBivIunHVRRT6EFDSwhihQrFoX15zDVt(P5KmPcgnK8BeA4OeGGRrn4boLP0hb9aslLFcgdoPLIj)Hjxeu(dbGFcqGvtemvOPYgXgbKFdytcSH87FDJ(C6cnGGbFHKc0XpUUDDSwN)1n6ZPBWdnPM8oai01TRJ16miexJyd6cnGGbFHKc0Xpoa1elexNN1j47KFy0qYFia8tacSAIGPcnv2i2iGmL(WSFslLFcgdoPLIj)Hjxeu(d8J3asyfieacOmiqWLFdytcSH8RPrFoDGqaiGYGabxPPrFoDAeBW6ejQonn6ZPZGG6UjxVKAHmP00OpNUUDDSwxgaRu6EOGNpoBtwNN1jWmxhR1LbWkLUhk45JZ2K11gJ6ey)QtKO68Vonn6ZPZGG6UjxVKAHmP00OpNUUDDSwxR1PPrFoDGqaiGYGabxPPrFoD4mmmvxBmQJz)QZx1jOF11E1PPrFoDdocPvOPkFifbPgHUUDDIevxgaRu6YTHujsPxQopRR99RUwQJ16g950fAabd(cjfOJFCaQjwiUU2QtqXt(Hrdj)b(XBajScecabugei4Yu6dZckTu(jym4KwkM8BaBsGnK)rFoDdocP5DC6auyY6ejQUCBivIu6LQZtg1XSF1jsuDguZaPSrlmXonnxZM15jJ6yw(dtUiO83XKAtQbltzk)ZfU4hPLsFeuAP8tWyWjTum53a2KaBi)EdWgdo5gjPmiOEZfbL)WKlck)dkzJiOkFifjKWYu6dZslLFcgdoPLIj)gWMeyd5F0NthMVgsfqTsVgYbOMyH468SUCBivIu6LQJ16g950H5RHubuR0RHCaQjwiUopRR16eSo2RZGAgiLnAHjUUwQR9QtqN4j)Hjxeu(X81qQaQv61qYu6JalTu(jym4KwkM8BaBsGnK)rFoDaeNRYhsnqqc7autSqCDEYOobUorIQZBa2yWjhihkabqCU8hMCrq5hG4Cv(qQbcsyzk959slLFcgdoPLIj)gWMeyd5peab2KCHHuDBLquhOWCI8socgdoPRtKO6cbqGnjNMcn(bLocgdoPL)WKlck)dkzJiOkFifjKWYu6Z7Kwk)Hjxeu(1l2osZJ8tWyWjTumzktzk)rpFqa5)VnEqzktPea]] )


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