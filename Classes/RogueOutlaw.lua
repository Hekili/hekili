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


    spec:RegisterPack( "Outlaw", 20200330, [[defHqbqiHkpsvQ2ekPprPcnkPKoLQeRsvs5vOunluu3IsL2LGFrjmmHQogbAzOiptvkMgbORPkL2MQKQVPkjzCeQY5uLKADeanpkvDpuyFsjoOqjTqcLhsPcMiHkDrHsyJeQWhvLeyKeasNKqfzLsPEjHQIzsaOCtca2PqXpjuvAOcLOJsaOAPuQONQQMkLORsOQARQsc6ReQOgRQKqDwvjHSxI(lPgSshMQflvpMIjtYLr2SI(mL0OvfNwLvtaiEnkXSr1TLIDd63qgUqoUQKOLd8COMUORRW2Pu(okLXluQZtqRNaA(eY(LSuqPLYVYtsgdtXZu8X)M3eFGP4f8nmXK8NcJi5pYnS4wj5h6nK8l(osUZM8h5c5ixjTu(XObWqY)tMrybOfwy9YNrpyqnwGVMb3ZdbnaFMwGVgJfYFFC8uCck7YVYtsgdtXZu8X)M3eFGP4f8nc(QKFCezKXW0RhV8)CkfbLD5xryJ8)ETIVJK7SvRDISoOQ971(KzewaAHfwV8z0dguJf4RzW98qqdWNPf4RXyr1(9AfaCG5P23epZ1Yu8mfF1UA)ET2HhhALWcWQ971A3AJvLIu1k(CgwQnr1QOPp4zTUjpeSw(HZq1(9ATBTXQsrQAJaKb109SwX4UIQvCWhaGWABvHim0oM12bKZsT)KCE(8sOA)ET2TwXfbTJzTdmvBcoiluIR9G1ItY55tOA)ET2TwXfbTJzTdmvBZbfGVIRDIa1ka4awivTteOwXL88P2wV0oIRfIYAXJOieij1lHQ971A3AJvBOtvlGaio)GwR1otXQvnah0ATIXDfvR4GpaaH126aYjmUw2OArqUWAFCBuTcwB6aRu(sOA)ET2Tw7K4ESRv8548dAT2FeGOq1(9ATBTIFmvBEnKorA1r1orGAjObnGjbQLGQdATwGNpeO28XH1MoWkLH8AiDI0QJcv73R1U1k(XuT2zkwTacG48A5iRNPwhQQ9df3Ab0eq4NA5iRNP2dwB(q1gbidQP7zTUjpeSw(HZG8hbqZJtY)71k(osUZwT2jY6GQ2Vx7tMrybOfwy9YNrpyqnwGVMb3ZdbnaFMwGVgJfv73RvaWbMNAFt8mxltXZu8v7Q971AhECOvclaR2VxRDRnwvksvR4ZzyP2evRIM(GN16M8qWA5hodv73R1U1gRkfPQncqgut3ZAfJ7kQwXbFaacRTvfIWq7ywBhqol1(tY55ZlHQ971A3Afxe0oM1oWuTj4GSqjU2dwlojNNpHQ971A3Afxe0oM1oWuTnhua(kU2jcuRaGdyHu1orGAfxYZNAB9s7iUwikRfpIIqGKuVeQ2VxRDRnwTHovTacG48dATw7mfRw1aCqR1kg3vuTId(aaewBRdiNW4AzJQfb5cR9XTr1kyTPdSs5lHQ971A3ATtI7XUwXNJZpO1A)raIcv73R1U1k(XuT51q6ePvhv7ebQLGg0aMeOwcQoO1AbE(qGAZhhwB6aRugYRH0jsRokuTFVw7wR4ht1ANPy1ciaIZRLJSEMADOQ2puCRfqtaHFQLJSEMApyT5dvBeGmOMUN16M8qWA5hodv7Q971glInzgjPQTtteGQ1GA6EwBNSEqCO2y1yOOexlebT7JdAMdETUjpeexlcYfgQ2VxRBYdbXHiazqnDpzm5oMLQ9716M8qqCicqgut3t2zyHpS2qW0ZdbR2VxRBYdbXHiazqnDpzNHftesvTFV2p0JWpOSwGFQA7J5Ku1ItpX12Pjcq1AqnDpRTtwpiUwhQQncq2ncL5bTw7HRvHGuOA)ETUjpeehIaKb109KDgwGHEe(bLAC6jUA7M8qqCicqgut3t2zyrJdyHu6jcOvKNpmhbidQP7PgtgeuHz8wMVjdGFknzJGzWvkC4GTiGXxTDtEiioebidQP7j7mSaNKZZhMVjJwJJELJlkIuHiKHfkXNajL2GAIgPNhcQvKTZqIefNbH4keBWGrOHJsacEgDN74mOgappeuKiGFknzJGz4G2gCib8oNcuSpCIFPA)ET2jbqCETteOwMyVweO2xbahQQvaG4evlcuRDoYhoHX1glbK5WhcgQ2UjpeeZodlS5GZ7CIzO3qmazxdiaIZz2MZhedq219XCITNjwJRpMZGvGdv6gItuyeXAC9XCgaJ8HtySocqMdFiyyevTFVw7KaioV2jcultSxBFmN4ArGAfdGCf(uuTSD5tTIl5k8dkdvB3KhcIzNHf2CW5DoXm0BigGSRbeaX5mJIyGPK5BYWfibUKckYv4hugiO35KIzBoFqmazx3hZj2EMyT1(yodCKRiLwDgkmIejkU(yodDaYv4trHr0lv73R1ojaIZRDIa1Ye712hZjUweOw7CKpCcJRnwciZHpeSw2U8P2y1q1oIQviAaQ9ZjYgXCTdiNW4AZhcq16aQ2geGQvCjxHFqzTahYcouTDtEiiMDgwyZbN35eZqVHyaYUgqaeNZmkIbMsMVjdxGe4sk4gspI0crdGgZjYgfiO35KIvxGe4sk4gspI0crdGgZjYgfaoKLwy4cKaxsbf5k8dkdahYcZ2C(GyaYUUpMtS9mXAR9XCg4ixrkT6muyejsuFmNbWiF4egRJaK5WhcgauJFqS9mmiexHydg6uYgrqD(qAsiHdaQXpi(LQ971Ye71(HoluTXcHewawBSYzZfIRfqaeNx7ebQLj2RTpMtCOA7M8qqm7mSWMdoVZjMHEdXaKDnGaioNzuedmLmFtgUajWLuadDwinjKWbGdzPfgmXSnNpigGSR7J5eBptv73RLj2R9dDwOAJfcjSaSwXfvleL1ciaIZRLTlFQLj2RfNUHfCTOzT5dv7h6Sq1gles4A7J5S2wfK9AXPByPw2U8PwXaixHpfv7i6Lq12n5HGy2zyHnhCENtmd9gIbi7AabqCoZOigactjZ3KHlqcCjfWqNfstcjCa4qwAHbtS2hZzadDwinjKWbC6gwAHbt2TpMZqhGCf(uuyevTFVwX5lFQvmUROAfh8baiS2reZ1EwHiavlyWjCTEhzJQ1HQAtNfQwYgbeMph0AT5JN1E4AzI9ABfIYAnObmpO1A)UD4LArGAXh0kNQvSpZ1(kqaG5ATZyz12n5HGy2zyHnhCENtmd9gIbi7AabqCoZOigykz(Mm6J5m05UI0t(aaeggrmBZ5dIbi76(yoX2TpMZaMLbNRDOsBaimUJGeomISNjwBTpMZah5ksPvNHcJirIIRpMZGvGdv6gItuyeXAC9XCgaJ8HtySocqMdFiyyeXAC9XCg6aKRWNIcJOxQ2VxR48Lp1kagYvKQwX9muTJiMRfqaeNxRdfwl(Gw5uT9XCYCTouyTmvBFmN1Y2Lp1k2aCKQwlbKJhaI5ArGApyTrournNjuTDtEiiMDgwyZbN35eZqVHyaYUgqaeNZmkIbMsMVjJ(yodCKRiLwDgkmIy2MZheJwbzx3hZj2U9XCg6dWrkDcihpauye9I9mjsuFmNbaIZ15dP7iiHdaQXpi2EbJpiES3QGbX71sNtWmOikIaACc80Tsnbc6DoPEPA7M8qqCicqgut3t2zybaX568H0DeKWmhbidQP7PgtgeuHzWeZ3KrFmNbaIZ15dP7iiHdaQXpi2EgVrKiBo48oNcGSRbeaX5vB3KhcIdraYGA6EYodlW8ZqAhQ0QZqmhbidQP7PgtgeuHzWeZ3KrFmNbm)mK2HkT6muaqn(bX2NxdPtKwDeR9XCgW8ZqAhQ0QZqba14heBFRcYUb10r6i0bt8lVMGbXRA7M8qqCicqgut3t2zyHRae05hK0Gb(H5iazqnDp1yYGGkmdbz(MmAno6voUOisfIqgwOeFcKuAdQjAKEEiOwr2odjsuCgeIRqSbdgHgokbi4z0DUJZGAa88qqrIa(P0KncMHdABWHeW7CkqX(Wj(LQTBYdbXHiazqnDpzNHfdmPVKAyg6nedxG4hh4y9ebtnAQJqSrGQTBYdbXHiazqnDpzNHfdmPVKAyMMtYKAO3qmmcnCucqWZO7ChNmFtgXb8tPjBemdh02GdjG35uGI9HtC12n5HG4qeGmOMUNSZWIiuEiy1UA)ETXIytMrsQAjBeqyT51q1MpuTUjrGApCTUn)4ENtHQ971ANeojNNp1EZAJqy815uTTcr1ABWHeW7CQwcsnhHR9G1AqnDpFPA7M8qqmdwodlmFtgXHtY55dPcaK1bvTDtEiiMbojNNpvB3KhcIzNHf2CW5DoXm0BigEtFGF0geuD5HGmBZ5dIHb10r6i0btCqrZZCzlmyIDMETwtNtWmy9bHtUqnobhluGGENtkwniexHydgS(GWjxOgNGJfkaOg)Gy7f8f27J5m0bixHpffgrSsqcyvylVE8SgxFmNbmldox7qL2aqyChbjCyeXAC9XCgyHOiTq0aOz7sS27OrQfIgHru12n5HGy2zyHnhCENtmd9gIrpjTbbvxEiiZ2C(Gy0hZzamYhoHX6iazo8HGHrKirT6cKaxsbf5k8dkde07CsjsKlqcCjfCdPhrAHObqJ5ezJce07Cs9cR9XCgaioxNpKUJGeomIQ2VxR48Lp12m45fXPAthyLsmZ1MphUwBo48oNQ9W1AEidlKQ2evRImNIQLThkFiqTyudvRDqCX1IFqdUQ2ovlwi0qQAz7YNAfJ7kQwXbFaacR2UjpeeZodlS5GZ7CIzO3qm6Cxr6jFaac1yHqdZ2C(GyGJioxNoWkL4qN7ksp5daqO9mXkWpLMSrWm4kfoCWwykErI6J5m05UI0t(aaeggrvB3KhcIzNHfgNZ1UjpeuZpCYm0Big4KCE(W8nzGtY55dPcoNxTDtEiiMDgwyCox7M8qqn)WjZqVHyyu4Q971koo4HFQ1ZAB8yFnJMATdXYqT)rhNa3K1IGuTteOwYnp1kga5k8POADOQwX3OieihWlfwlBpeSwbWhNHLAfxGZwThUwmXjtsQADOQwbGP4w7HRfIYAbKRewRptcuB(q1cPyN1IjdcQc1gRC2CH4AB8yxRyzSOw2U8PwMyV2y1qHQTBYdbXSZWcWaQDtEiOMF4KzO3qmMh8WpmFtgguthPJqhmXTWWePB8yRXreuz3w7J5m0bixHpffgrS3hZzaffHa5aEPWWi6LxR105emdVYXzyrRaoBbc6DoPyT14sNtWm04awiLEIaAf55tGGENtkrImiexHydgACalKspraTI88jaOg)G4we8LxETwDbsGlPGBi9islenaAmNiBua4qwSNjrIIZGqCfInyOtjBeb15dPjHeomIejkU(yodaeNRZhs3rqchgrVuTDtEiiMDgwyCox7M8qqn)WjZqVHy0hhxvTDtEiiMDgw4aJdjDIaacMmFtgeKawfgu08mx2cdbFl7eKawfgaKvcwTDtEiiMDgw4aJdjD0GJPQTBYdbXSZWc(z9jXAbqgkRnemR2UjpeeZodl6UvnAQtWzybxTR2VxRyJJRiaUA)ETIFmvBS8WjIx7)bL1EZAVSw2qq7ywRXJQ1GA6OAJqhmX16qvT5dvR4BuekhWlfwBFmN1E4AhrHAJvBOtv7aFqR1Y2dbRv8HOOAFfHgGAfNVexloDdl4ADav7Zz9P2bKtyCT5dvR4sUc)GYA7J5S2dxRZXOAhrHQTBYdbXH(44kgrhorCn(bLmFtg9XCgqrriqoGxkmmIyT1(yodSquKwiAa0SDjw7D0i1crJaoDdl2lOaksuFmNbf5k8dkdJirIiibSk0Eb8TVuTDtEiio0hhxXodlWh8Wjb04eCSqv7Q971AhqiUcXgexTDtEiioyuyggNZ1UjpeuZpCYm0BigegtqdHz(MmIdNKZZhsfCoVA7M8qqCWOWSZWcxbiOZpiPbd8dZ3KrC9XCgCfGGo)GKgmWpHreRTgh9khxuePcUaXpoWX6jcMA0uhHyJaIezqiUcXgmW9KGP2bgh6ba14he3ctX)s1(9AfNM16kfUwhq1oIyUwm8IOAZhQweKQLTlFQLJyJWzTwAP4gQv8JPAz7HG1QeEqR1oDCsGAZhhwRDiwwRIMN5YArGAz7Yh0iR1HcR1oeldvB3KhcIdgfMDgw04awiLEIaAf55dZgHgoPthyLsmdbz(Mma(P0KncMbxPWHreRTMoWkLH8AiDI0QJS3GA6iDe6GjoOO5zUuKO4Wj588HubaY6Gy1GA6iDe6GjoOO5zUSfgMiDJhBnoIGk7k4lv73RvCAwlevRRu4Az748AvhvlBx(CWAZhQwif7S23epM5AhyQwbGP4wlcwBhHX1Y2LpOrwRdfwRDiwgQ2Ujpeehmkm7mSOXbSqk9eb0kYZhMVjdGFknzJGzWvkC4GT8M4TlWpLMSrWm4kfoOgappeK14Wj588HubaY6Gy1GA6iDe6GjoOO5zUSfgMiDJhBnoIGk7ky1(9AfJ7kQwXbFaacRfbRLj2RLGuZr4qTIZx(uRRuybyTIFmv7nRnFiH1ItxyTteOwXJ9AXKbbv4ArGAVzTcrdqTqk2zTMhhyLQLTJZRTt1cixjS2dwBEnuTteO28HQfsXoRLn3gfQ2Ujpeehmkm7mSOZDfPN8baiK5BYahrCUoDGvkXTWGjwJRpMZqN7ksp5daqyyeXARXb8tPjBemdUsHduSpCIfjc4Nst2iygCLchauJFqClINira)uAYgbZGRu4WbBPvMSRbH4keBWqN7ksp5daqyW84aRewpbUjpe05V8Am92xQ2Ujpeehmkm7mSW6dcNCHACcowiMVjdBo48oNcDURi9KpaaHASqOHvdQPJ0rOdM4GIMN5Ywyii79XCg6aKRWNIcJOQTBYdbXbJcZodly548dAvJJaeX8nzyZbN35uOZDfPN8baiuJfcnS2kbjGvHH8AiDI0nESB5TIerqcyvO9c(2xQ2Ujpeehmkm7mSOZDfPbd8dZ3KHnhCENtHo3vKEYhaGqnwi0WkbjGvHH8AiDI0nESBrqwBnU(yodUcqqNFqsdg4NWisKicsaRcTxaF7lv73Rv8JpO1AFf6Wd)yrS20h4NApCTiixyTET2iGWAZdkS2dAaKJjMRfJQ9G1ciNFPqMRviAyhbuTEhJ4JK4cRDEqQ2ev7at1EzToUwV2rE8lfwloI48q12n5HG4GrHzNHf2C4HFy(MmIdNKZZhsfCoNvBo48oNcEtFGF0geuD5HGvB3KhcIdgfMDgwGFCfITgIRy(MmIdNKZZhsfCoNvBo48oNcEtFGF0geuD5HGvB3KhcIdgfMDgweHYdbz(Mm6J5m05iKIpWzaqUjfjQpMZGRae05hK0Gb(jmIQ2VxR4W58dAT2UByP2evRIM(GN1Ej1u7a7wPQTBYdbXbJcZodlgysFj1Wm0Big2CW5DoPpysq8Lc1wpRUnep1iS54CppOvnGCtIamFtg9XCg6CesXh4mai3KIeLxdPtKwDK9mykErImOMoshHoyIdkAEMlTNbtvB3KhcIdgfMDgwmWK(sQbZ8nz0hZzOZrifFGZaGCtksuEnKorA1r2ZGP4fjYGA6iDe6GjoOO5zU0EgmvTDtEiioyuy2zyrNJqk9CaewTDtEiioyuy2zyrNaycWYbTwTDtEiioyuy2zyX8auNJqQQTBYdbXbJcZodlCOHWjW5AJZ5vB3KhcIdgfMDgwmWK(sQHzAojtQHEdXWi0WrjabpJUZDCY8nzehojNNpKk4CoR9XCgCfGGo)GKgmWpbfIniR9XCgAOgeqOgn18H5uAfG8gCqHydYkbjGvHH8AiDI0nESBrazfKDDFmNy7FB12n5HG4GrHzNHfdmPVKAyg6nedxG4hh4y9ebtnAQJqSraMVjJ46J5m4kabD(bjnyGFcJiwJRpMZqN7ksp5daqyyeXQbH4keBWGRae05hK0Gb(jaOg)Gy7f8Tv73R9vibewlanS(WfwlyWPArZAZNrt)MhPQTXZhCTDIJytawR4ht1orGAfNGSeHu1AaxYCTO8HaSDyQw2U8P2y1oR1ZAzkE2RfNUHfCTiqTcgp71Y2Lp16CmQwX4iKQ2ruOA7M8qqCWOWSZWIbM0xsnmd9gIHJFS5qcRbUaraTbbCoZ3KHI6J5maCbIaAdc4CTI6J5mOqSbfjsr9XCgmiOAyYZgPpilAf1hZzyeXA6aRugEiNNpHitA)ByI10bwPm8qopFcrMSfgVjErIItr9XCgmiOAyYZgPpilAf1hZzyeXARkQpMZaWficOniGZ1kQpMZaoDdlTWGP4TRGX)AkQpMZqNJqknAQZhstqQryyejsu6aRugYRH0jsRoY(xp(xyTpMZGRae05hK0Gb(jaOg)G4weu8Q2VxR4stFWZANoN3Ddl1orGAhyVZPAVKAWHQTBYdbXbJcZodlgysFj1Gz(Mm6J5m05iKIpWzaqUjfjkVgsNiT6i7zWu8IezqnDKocDWehu08mxApdMQ2v73RnwGXe0q4QTBYdbXbcJjOHWmmiOHGjWtsPNCVHy(MmiibSkmKxdPtKUXJDlcYAC9XCg6Cxr6jFaacdJiwBnofkdge0qWe4jP0tU3q6(aad5zy5Gwzno3KhcgmiOHGjWtsPNCVHchup5N1NuKO5GZ1aY84aRKoVgYERgvOXJ9lvB3KhcIdegtqdHzNHfDocP0OPoFinbPgHmFtg2CW5Dof6Cxr6jFaac1yHqdRgeIRqSbdDkzJiOoFinjKWHreR2CW5Dof6jPniO6YdbR2UjpeehimMGgcZodlSoCG6COgn1UajakFQ2UjpeehimMGgcZodlMiZatkTlqcCjP7K3W8nzGJioxNoWkL4qN7ksp5daqylmysKiGFknzJGzWvkC4GT86XZAC9XCgCfGGo)GKgmWpHru12n5HG4aHXe0qy2zyr0aCtHh0QUZDCY8nzGJioxNoWkL4qN7ksp5daqylmysKiGFknzJGzWvkC4GT86XxTDtEiioqymbneMDgwKpKEa7ObuPNiGHy(Mm6J5maidlCcJ1teWqHrKir9XCgaKHfoHX6jcyiTbnGjbc40nSyVGXxTDtEiioqymbneMDgwaUOioPpOgh5gQA7M8qqCGWycAim7mSGneGRSrhudimc6qdvTDtEiioqymbneMDgw0qniGqnAQ5dZP0ka5nyMVjdcsaRcTxaFB1(9AfafXv1ANKhDqR1ko4EdHRDIa1sXMmJKQf4qRuTiqTSCCET9XCIzU2BwBecJVoNc1gRC2CH4AtGWAtuTwPS28HQLJyJWzTgeIRqSbRT7ysvlcwRBZpU35uTeKAochQ2UjpeehimMGgcZodlaKhDqR6j3BimZgHgoPthyLsmdbz(MmshyLYqEnKorA1r2ly4TIe1ARPdSsz4HCE(eImzlIx8IeLoWkLHhY55tiYK2ZGP4FH1wDtE2inbPMJWmeuKO0bwPmKxdPtKwDulm9QF5frIAnDGvkd51q6ePJmPMP4B5nXZARUjpBKMGuZrygcksu6aRugYRH0jsRoQfbuaF5LQD1(9Afhh8WpeaxTFVwXYyrTiBeOw7mfRwabqCoUw2U8PwXLCf(bLweRgQ2e4xIRfbQ1oh5dNW4AJLaYC4dbdvB3KhcIdZdE4hgDkzJiOoFinjKWmFtg2CW5Dof6jPniO6YdbR2UjpeehMh8WpSZWcm)mK2HkT6meZ3KrFmNbm)mK2HkT6muaqn(bX2NxdPtKwDeR9XCgW8ZqAhQ0QZqba14heBFRcYUb10r6i0bt8lVMGbXRA7M8qqCyEWd)WodlaioxNpKUJGeM5BYOpMZaaX568H0DeKWba14heBpJ3isKnhCENtbq21acG48Q971kwglQLTlFQnFOAJvdvR4pQ2xrObO2pNiBuTiqTIl5k8dkRnb(L4q12n5HG4W8Gh(HDgw0PKnIG68H0KqcZ8nz4cKaxsb3q6rKwiAa0yor2Oab9oNuIe5cKaxsbf5k8dkde07CsvTDtEiiomp4HFyNHfQdh5P5PAxTFV2FsopFQ2UjpeehWj588HH30h4h53gbWhckJHP4zk(4Ft8VA5NnhapOvS8lo1eHajPQ9vvRBYdbRLF4ehQ2Yp)WjwAP8tymbnewAPmgbLwk)e07Csjft(nGljW5YpbjGvHH8AiDI0nESRTLAfSwwRnUA7J5m05UI0t(aaeggr1YATTwBC1QqzWGGgcMapjLEY9gs3hayipdlh0ATSwBC16M8qWGbbnembEsk9K7nu4G6j)S(K1ksuTZbNRbK5XbwjDEnuT2xRvJk04XU2xKF3Khck)ge0qWe4jP0tU3qYugdtslLFc6DoPKIj)gWLe4C53MdoVZPqN7ksp5daqOgleAQL1AniexHydg6uYgrqD(qAsiHdJOAzTwBo48oNc9K0geuD5HGYVBYdbL)ohHuA0uNpKMGuJqzkJ5nslLF3Khck)whoqDouJMAxGeaLpYpb9oNusXKPmgbuAP8tqVZjLum53aUKaNl)4iIZ1PdSsjo05UI0t(aaewBlmQLPAfjQwGFknzJGzWvkC4G12sTVE81YATXvBFmNbxbiOZpiPbd8tyej)Ujpeu(NiZatkTlqcCjP7K3itzmVvAP8tqVZjLum53aUKaNl)4iIZ1PdSsjo05UI0t(aaewBlmQLPAfjQwGFknzJGzWvkC4G12sTVE8YVBYdbL)Ob4McpOvDN74uMYyEDPLYpb9oNusXKFd4scCU83hZzaqgw4egRNiGHcJOAfjQ2(yodaYWcNWy9ebmK2GgWKabC6gwQ1(AfmE53n5HGYF(q6bSJgqLEIagsMYyEvslLF3Khck)GlkIt6dQXrUHKFc6DoPKIjtzmIN0s53n5HGYpBiaxzJoOgqye0Hgs(jO35KskMmLX8QLwk)e07Csjft(nGljW5YpbjGvH1AFTc4BLF3Khck)nudciuJMA(WCkTcqEdwMYyemEPLYpb9oNusXKF3Khck)aYJoOv9K7new(nGljW5YF6aRugYRH0jsRoQw7RvWWBRvKOABT2wRnDGvkdpKZZNqKjRTLAfV4RvKOAthyLYWd588jezYATNrTmfFTVulR12ATUjpBKMGuZr4AzuRG1ksuTPdSsziVgsNiT6OABPwME11(sTVuRir12ATPdSsziVgsNiDKj1mfFTTu7BIVwwRT1ADtE2inbPMJW1YOwbRvKOAthyLYqEnKorA1r12sTcOaw7l1(I8BeA4KoDGvkXYyeuMYu(v00h8uAPmgbLwk)e07Csjft(rrYpMs53n5HGYVnhCENtYVnNpi5hKDDFmN4ATVwMQL1AJR2(yodwbouPBiorHruTSwBC12hZzamYhoHX6iazo8HGHrK8BZbAO3qYpi7AabqCUmLXWK0s5NGENtkPyYpks(Xuk)Ujpeu(T5GZ7Cs(T58bj)GSR7J5exR91YuTSwBR12hZzGJCfP0QZqHruTIevBC12hZzOdqUcFkkmIQ9f53aUKaNl)UajWLuqrUc)GYab9oNuYVnhOHEdj)GSRbeaX5YugZBKwk)e07Csjft(rrYpMs53n5HGYVnhCENtYVnNpi5hKDDFmN4ATVwMQL1ABT2(yodCKRiLwDgkmIQvKOA7J5mag5dNWyDeGmh(qWaGA8dIR1Eg1AqiUcXgm0PKnIG68H0KqchauJFqCTVi)gWLe4C53fibUKcUH0JiTq0aOXCISrbc6DoPQL1ADbsGlPGBi9islenaAmNiBua4qwQTfg16cKaxsbf5k8dkdahYI8BZbAO3qYpi7AabqCUmLXiGslLFc6DoPKIj)Oi5htP87M8qq53MdoVZj53MZhK8dYUUpMtCT2xltYVbCjbox(DbsGlPag6SqAsiHdahYsTTWOwMKFBoqd9gs(bzxdiaIZLPmM3kTu(jO35KskM8JIKFaHPu(DtEiO8BZbN35K8BZbAO3qYpi7AabqCU8BaxsGZLFxGe4skGHolKMes4aWHSuBlmQLPAzT2(yodyOZcPjHeoGt3WsTTWOwMQ1U12hZzOdqUcFkkmIKPmMxxAP8tqVZjLum5hfj)ykLF3Khck)2CW5Doj)2C(GKFq219XCIR1U12hZzaZYGZ1ouPnaeg3rqchgr1AFTmvlR12AT9XCg4ixrkT6muyevRir1gxT9XCgScCOs3qCIcJOAzT24QTpMZayKpCcJ1raYC4dbdJOAzT24QTpMZqhGCf(uuyev7lYVbCjbox(7J5m05UI0t(aaeggrYVnhOHEdj)GSRbeaX5YugZRsAP8tqVZjLum5hfj)ykLF3Khck)2CW5Doj)2C(GK)wRfKDDFmN4ATBT9XCg6dWrkDcihpauyev7l1AFTmvRir12hZzaG4CD(q6ocs4aGA8dIR1(Afm(G4vl712ATcgeVAFTAtNtWmOikIaACc80Tsnbc6DoPQ9f53aUKaNl)9XCg4ixrkT6muyej)2CGg6nK8dYUgqaeNltzmIN0s5NGENtkPyYVbCjbox(JRwCsopFivaGSoi53n5HGYplNHfzkJ5vlTu(DtEiO8JtY55J8tqVZjLumzkJrW4Lwk)e07Csjft(rrYpMs53n5HGYVnhCENtYVnNpi53GA6iDe6GjoOO5zUS2wyult1YETmv7RvBR1MoNGzW6dcNCHACcowOab9oNu1YATgeIRqSbdwFq4KluJtWXcfauJFqCT2xRG1(sTSxBFmNHoa5k8POWiQwwRLGeWQWABP2xp(AzT24QTpMZaMLbNRDOsBaimUJGeomIQL1AJR2(yodSquKwiAa0SDjw7D0i1crJWis(T5an0Bi53B6d8J2GGQlpeuMYyeuqPLYpb9oNusXKFuK8JPu(DtEiO8BZbN35K8BZ5ds(7J5mag5dNWyDeGmh(qWWiQwrIQT1ADbsGlPGICf(bLbc6DoPQvKOADbsGlPGBi9islenaAmNiBuGGENtQAFPwwRTpMZaaX568H0DeKWHrK8BZbAO3qYFpjTbbvxEiOmLXiitslLFc6DoPKIj)Oi5htP87M8qq53MdoVZj53MZhK8JJioxNoWkL4qN7ksp5daqyT2xlt1YATa)uAYgbZGRu4WbRTLAzk(AfjQ2(yodDURi9KpaaHHrK8BZbAO3qYFN7ksp5daqOgleAKPmgbFJ0s5NGENtkPyYVbCjbox(Xj588HubNZLF3Khck)gNZ1UjpeuZpCk)8dNAO3qYpojNNpYugJGcO0s5NGENtkPyYVBYdbLFJZ5A3KhcQ5hoLF(Htn0Bi53OWYugJGVvAP8tqVZjLum53aUKaNl)guthPJqhmX12cJAnr6gp2ACebv1A3ABT2(yodDaYv4trHruTSxBFmNbuuecKd4LcdJOAFP2xR2wRnDobZWRCCgw0kGZwGGENtQAzT2wRnUAtNtWm04awiLEIaAf55tGGENtQAfjQwdcXvi2GHghWcP0teqRipFcaQXpiU2wQvWAFP2xQ91QT1ADbsGlPGBi9islenaAmNiBua4qwQ1(AzQwrIQnUAniexHydg6uYgrqD(qAsiHdJOAfjQ24QTpMZaaX568H0DeKWHruTVi)Ujpeu(bdO2n5HGA(Ht5NF4ud9gs(Nh8WpYugJGVU0s5NGENtkPyYVBYdbLFJZ5A3KhcQ5hoLF(Htn0Bi5VpoUsMYye8vjTu(jO35KskM8BaxsGZLFcsaRcdkAEMlRTfg1k4BRL9AjibSkmaiReu(DtEiO87aJdjDIaacMYugJGIN0s53n5HGYVdmoK0rdoMKFc6DoPKIjtzmc(QLwk)Ujpeu(5N1NeRfazOS2qWu(jO35KskMmLXWu8slLF3Khck)D3Qgn1j4mSGLFc6DoPKIjtzk)raYGA6EkTugJGslLFc6DoPKIj)Ujpeu(BCalKspraTI88r(nGljW5YpWpLMSrWm4kfoCWABPwbmE5pcqgut3tnMmiOcl)VvMYyysAP8tqVZjLum53aUKaNl)TwBC1sVYXffrQqeYWcL4tGKsBqnrJ0Zdb1kY2zOAfjQ24Q1GqCfInyWi0WrjabpJUZDCgudGNhcwRir1c8tPjBemdh02GdjG35uGI9HtCTVi)Ujpeu(Xj588rMYyEJ0s5NGENtkPyYVBYdbLFaIZ15dP7iiHLFd4scCU83hZzaG4CD(q6ocs4aGA8dIR1Eg1(MAfjQwBo48oNcGSRbeaX5YFeGmOMUNAmzqqfw(zsMYyeqPLYpb9oNusXKF3Khck)y(ziTdvA1zi53aUKaNl)9XCgW8ZqAhQ0QZqba14hexR91MxdPtKwDuTSwBFmNbm)mK2HkT6muaqn(bX1AFTTwRG1YETguthPJqhmX1(sTVwTcgep5pcqgut3tnMmiOcl)mjtzmVvAP8tqVZjLum53n5HGYVRae05hK0Gb(r(nGljW5YFR1gxT0RCCrrKkeHmSqj(eiP0gut0i98qqTISDgQwrIQnUAniexHydgmcnCucqWZO7ChNb1a45HG1ksuTa)uAYgbZWbTn4qc4DofOyF4ex7lYFeGmOMUNAmzqqfw(fuMYyEDPLYpb9oNusXKFO3qYVlq8JdCSEIGPgn1ri2iG87M8qq53fi(XbowprWuJM6ieBeqMYyEvslLFc6DoPKIj)Ujpeu(ncnCucqWZO7ChNYVbCjbox(JRwGFknzJGz4G2gCib8oNcuSpCILFAojtQHEdj)gHgokbi4z0DUJtzkJr8Kwk)Ujpeu(Jq5HGYpb9oNusXKPmL)(44kPLYyeuAP8tqVZjLum53aUKaNl)9XCgqrriqoGxkmmIQL1ABT2(yodSquKwiAa0SDjw7D0i1crJaoDdl1AFTckG1ksuT9XCguKRWpOmmIQvKOAjibSkSw7RvaFBTVi)Ujpeu(JoCI4A8dkLPmgMKwk)Ujpeu(Xh8Wjb04eCSqYpb9oNusXKPmLFCsopFKwkJrqPLYVBYdbLFVPpWpYpb9oNusXKPmLFJclTugJGslLFc6DoPKIj)gWLe4C5pUAXj588HubNZLF3Khck)gNZ1UjpeuZpCk)8dNAO3qYpHXe0qyzkJHjPLYpb9oNusXKFd4scCU8hxT9XCgCfGGo)GKgmWpHruTSwBR1gxT0RCCrrKk4ce)4ahRNiyQrtDeIncuRir1AqiUcXgmW9KGP2bgh6ba14hexBl1Yu81(I87M8qq53vac68dsAWa)itzmVrAP8tqVZjLum53n5HGYFJdyHu6jcOvKNpYVbCjbox(b(P0KncMbxPWHruTSwBR1MoWkLH8AiDI0QJQ1(AnOMoshHoyIdkAEMlRvKOAJRwCsopFivaGSoOAzTwdQPJ0rOdM4GIMN5YABHrTMiDJhBnoIGQATBTcw7lYVrOHt60bwPelJrqzkJraLwk)e07Csjft(nGljW5YpWpLMSrWm4kfoCWABP23eFT2TwGFknzJGzWvkCqnaEEiyTSwBC1ItY55dPcaK1bvlR1AqnDKocDWehu08mxwBlmQ1ePB8yRXreuvRDRvq53n5HGYFJdyHu6jcOvKNpYugZBLwk)e07Csjft(nGljW5YpoI4CD6aRuIRTfg1YuTSwBC12hZzOZDfPN8baimmIQL1ABT24Qf4Nst2iygCLchOyF4exRir1c8tPjBemdUsHdaQXpiU2wQv8QvKOAb(P0KncMbxPWHdwBl12ATmvRDR1GqCfInyOZDfPN8baimyECGvcRNa3Khc68AFP2xRwMEBTVi)Ujpeu(7Cxr6jFaacLPmMxxAP8tqVZjLum53aUKaNl)2CW5Dof6Cxr6jFaac1yHqtTSwRb10r6i0btCqrZZCzTTWOwbRL9A7J5m0bixHpffgrYVBYdbLFRpiCYfQXj4yHKPmMxL0s5NGENtkPyYVbCjbox(T5GZ7Ck05UI0t(aaeQXcHMAzT2wRLGeWQWqEnKor6gp212sTVTwrIQLGeWQWATVwbFBTVi)Ujpeu(z548dAvJJaejtzmIN0s5NGENtkPyYVbCjbox(T5GZ7Ck05UI0t(aaeQXcHMAzTwcsaRcd51q6ePB8yxBl1kyTSwBR1gxT9XCgCfGGo)GKgmWpHruTIevlbjGvH1AFTc4BR9f53n5HGYFN7ksdg4hzkJ5vlTu(jO35KskM8BaxsGZL)4QfNKZZhsfCoVwwR1MdoVZPG30h4hTbbvxEiO87M8qq53Mdp8JmLXiy8slLFc6DoPKIj)gWLe4C5pUAXj588HubNZRL1AT5GZ7Ck4n9b(rBqq1Lhck)Ujpeu(XpUcXwdXvYugJGckTu(jO35KskM8BaxsGZL)(yodDocP4dCgaKBYAfjQ2(yodUcqqNFqsdg4NWis(DtEiO8hHYdbLPmgbzsAP8tqVZjLum53n5HGYVnhCENt6dMeeFPqT1ZQBdXtncBoo3ZdAvdi3KiG8BaxsGZL)(yodDocP4dCgaKBYAfjQ28AiDI0QJQ1Eg1Yu81ksuTguthPJqhmXbfnpZL1ApJAzs(HEdj)2CW5DoPpysq8Lc1wpRUnep1iS54CppOvnGCtIaYugJGVrAP8tqVZjLum53aUKaNl)9XCg6CesXh4mai3K1ksuT51q6ePvhvR9mQLP4RvKOAnOMoshHoyIdkAEMlR1Eg1YK87M8qq5FGj9LudwMYyeuaLwk)Ujpeu(7CesPNdGq5NGENtkPyYugJGVvAP87M8qq5Vtamby5GwLFc6DoPKIjtzmc(6slLF3Khck)ZdqDocPKFc6DoPKIjtzmc(QKwk)Ujpeu(DOHWjW5AJZ5Ypb9oNusXKPmgbfpPLYpb9oNusXKF3Khck)gHgokbi4z0DUJt53aUKaNl)XvlojNNpKk4CETSwBFmNbxbiOZpiPbd8tqHydwlR12hZzOHAqaHA0uZhMtPvaYBWbfInyTSwlbjGvHH8AiDI0nESRTLAfWAzTwq219XCIR1(AFR8tZjzsn0Bi53i0WrjabpJUZDCktzmc(QLwk)e07Csjft(DtEiO87ce)4ahRNiyQrtDeInci)gWLe4C5pUA7J5m4kabD(bjnyGFcJOAzT24QTpMZqN7ksp5daqyyevlR1AqiUcXgm4kabD(bjnyGFcaQXpiUw7RvW3k)qVHKFxG4hh4y9ebtnAQJqSrazkJHP4Lwk)e07Csjft(DtEiO874hBoKWAGlqeqBqaNl)gWLe4C5xr9XCgaUaraTbbCUwr9XCgui2G1ksuTkQpMZGbbvdtE2i9bzrRO(yodJOAzT20bwPm8qopFcrMSw7R9nmvlR1MoWkLHhY55tiYK12cJAFt81ksuTXvRI6J5myqq1WKNnsFqw0kQpMZWiQwwRT1AvuFmNbGlqeqBqaNRvuFmNbC6gwQTfg1Yu81A3Afm(AFTAvuFmNHohHuA0uNpKMGuJWWiQwrIQnDGvkd51q6ePvhvR91(6Xx7l1YAT9XCgCfGGo)GKgmWpba14hexBl1kO4j)qVHKFh)yZHewdCbIaAdc4CzkJHjbLwk)e07Csjft(nGljW5YFFmNHohHu8bodaYnzTIevBEnKorA1r1ApJAzk(AfjQwdQPJ0rOdM4GIMN5YATNrTmj)Ujpeu(hysFj1GLPmL)5bp8J0szmckTu(jO35KskM8BaxsGZLFBo48oNc9K0geuD5HGYVBYdbL)oLSreuNpKMesyzkJHjPLYpb9oNusXKFd4scCU83hZzaZpdPDOsRodfauJFqCT2xBEnKorA1r1YAT9XCgW8ZqAhQ0QZqba14hexR912ATcwl71AqnDKocDWex7l1(A1kyq8KF3Khck)y(ziTdvA1zizkJ5nslLFc6DoPKIj)gWLe4C5VpMZaaX568H0DeKWba14hexR9mQ9n1ksuT2CW5DofazxdiaIZLF3Khck)aeNRZhs3rqcltzmcO0s5NGENtkPyYVbCjbox(DbsGlPGBi9islenaAmNiBuGGENtQAfjQwxGe4skOixHFqzGGENtk53n5HGYFNs2icQZhstcjSmLX8wPLYVBYdbLF1HJ808i)e07CsjftMYuMYVpYheq()xJDqMYukb]] )


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