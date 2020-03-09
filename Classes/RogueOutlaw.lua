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


    spec:RegisterPack( "Outlaw", 20200309, [[d8KClbqiHQEKQeBcf1NiQqJsvkNsvsRsvu6veHzHs6wcf2LGFru1WeQCmkHLHs8mvPQPruPUMQOABQsfFdLQW4OKIZHsvADOuvMNqP7Hc7tvKdkuulKi6HevWejQKlsjLSrIkQpQkvQCsuQIwPQWlrPQYnvLkzNus(jkvvnuHI0rvLkvTuvrXtvvtLs0vjQiBLskv(QQuPmwkPuCwkPuAVe(lfdwLdt1ILQhtYKj1Lr2SI(SqmAP0PvA1usPQxJImBuDBPy3a)g0WPuhxOiwoKNd10fDDf2Uq67OugpLuDEI06rPY8jk7xYclewk(ApjHvSehlXf37JJ9gIJ9gNfpx8tP2K4B7kM8iK4d8gs8z)hj3zt8TDPCORfwk(y4aPiXVntBm7tE5JSz7OhuWg5XBZG75cbkKpt5XBJsEXVpwEYEceDXx7jjSIL4yjU4EFCS3qCwZZzVYT1i(yBsjSIL3joXVD1Aci6IVMWkX)L6y)hj3zRUNbgzq1JxQRntBm7tE5JSz7OhuWg5XBZG75cbkKpt5XBJs(6Xl19UCKQTo2lR1XsCSex9OE8sDYHwheHWSV6Xl1fJ6IzTM01X(TkMQlH1PPPp4zDUkxiOo(IZq94L6IrDXSwt66SrKc209Soj5UMQtoZhiK06EtdjmqoM11rKZuD)KCE2(AOE8sDXOo5ccKJzDdmvxIwatuIRBb1HtY5zBOE8sDXOo5ccKJzDdmvxZcyFwBQBcr19UCetKUUjevNCrE2w3BBkhX1bGzD4HTneLK(1q94L6IrDXCu4QRdriiNVGi19mPK1PhOfePoj5UMQtoZhiK06EBa4egxhBuDqaxADTEuQolQlDuekFnupEPUyu3ZqC361X(TC(cIu33gruOE8sDXOo5eMQl3gYKqJEP6MquDeqbhGKq1ra9cIuhYZwcvx26G6shfHYqUnKjHg9sH6Xl1fJ6KtyQUNjLSoeHGCEDCyKvvNd019bYvDiAIiCBDCyKvv3cQlBP6SrKc209SoxLleuhFXzq8TrW5YjX)L6y)hj3zRUNbgzq1JxQRntBm7tE5JSz7OhuWg5XBZG75cbkKpt5XBJs(6Xl19UCKQTo2lR1XsCSex9OE8sDYHwheHWSV6Xl1fJ6IzTM01X(TkMQlH1PPPp4zDUkxiOo(IZq94L6IrDXSwt66SrKc209Soj5UMQtoZhiK06EtdjmqoM11rKZuD)KCE2(AOE8sDXOo5ccKJzDdmvxIwatuIRBb1HtY5zBOE8sDXOo5ccKJzDdmvxZcyFwBQBcr19UCetKUUjevNCrE2w3BBkhX1bGzD4HTneLK(1q94L6IrDXCu4QRdriiNVGi19mPK1PhOfePoj5UMQtoZhiK06EBa4egxhBuDqaxADTEuQolQlDuekFnupEPUyu3ZqC361X(TC(cIu33gruOE8sDXOo5eMQl3gYKqJEP6MquDeqbhGKq1ra9cIuhYZwcvx26G6shfHYqUnKjHg9sH6Xl1fJ6KtyQUNjLSoeHGCEDCyKvvNd019bYvDiAIiCBDCyKvv3cQlBP6SrKc209SoxLleuhFXzOEupEPoRL1j1ijDDDAcruDkyt3Z66uKfGd1fZkfzN46aqqmADuZCWRZv5cb46GaU0q94L6CvUqaoyJifSP7jJj3XmvpEPoxLleGd2isbB6Ekbd59rKgcKEUqq94L6CvUqaoyJifSP7PemKFcH66Xl19bUnUfM1H8vxxFmNKUoC6jUUonHiQofSP7zDDkYcW15aDD2ikg2WmxqK6wCDAiGc1JxQZv5cb4GnIuWMUNsWqEmWTXTW0GtpX1dxLleGd2isbB6Ekbd5BCetK2mHiJM8SLvBePGnDpnysbbAmJNZ6ozG8vBOOeidUwJdl4j5oU6HRYfcWbBePGnDpLGH84KCE2Y6oz8w8umzS22KoydvmrjEzhPnkyJ9i9CHaJMIUksMS4vqixdzdeusvCyIGGvz6ChNb9a55cbYKH8vBOOeidli6GdiK35uGS(It8R1JxQ7zieKZRBcr1XIe11hZjUoiQojrqxJxnvhBB2wNCrUg3cZq9Wv5cb4GnIuWMUNsWq(OoA9oNyf4nedu2nicb5CwH2mWuY6oz4SJqBsbn5AClmdeW7CsZAuNpigOSB6J5ehllm)wFmNbo01K2Oxffg2YKfFFmNHoc6A8QPWW(16Xl19mecY51nHO6yrI66J5exhev3ZmYwoHX1ftrKAXleuhBB2wxmRO6g21jfoq195efLyTUbGtyCDzlHO6Cevxder1jxKRXTWSoKdychQhUkxiahSrKc209ucgYh1rR35eRaVHyGYUbriiNZk0MbMsw3jdNDeAtk4kYmSnsHdKbZjkkfiG35KMzNDeAtk4kYmSnsHdKbZjkkfqoGPNy4SJqBsbn5AClmdihWeRrD(GyGYUPpMtCSSW8B9XCg4qxtAJEvuyyltwFmNb0iB5egBSrKAXleequJVaCSmuqixdzde6uYgrat2sgskHdiQXxa(16Xl1XIe19botuDwlPeM9vxmZzZLIRdriiNx3eIQJfjQRpMtCOE4QCHaCWgrkyt3tjyiFuhTENtSc8gIbk7geHGCoRqBgykzDNmC2rOnPag4mrgskHdihW0tmyH1OoFqmqz30hZjowwQhVuhlsu3h4mr1zTKsy2xDYfSoamRdriiNxhBB2whlsuhoDft46GZ6YwQUpWzIQZAjLW11hZzDVzHe1HtxXuDSTzBDsIGUgVAQUH9RH6HRYfcWbBePGnDpLGH8rD06DoXkWBigOSBqecY5ScTzGimLSUtgo7i0MuadCMidjLWbKdy6jgSWCFmNbmWzImKuchWPRy6jgSeJ(yodDe014vtHHD94L6E32SToj5UMQtoZhiK06g2Sw3gbaruDObNW15DyuQohORlDMO6OOesA2UGi1LTEw3IRJfjQ7namRtbhGCbrQ77YHxRdIQdVGiCQoj)Sw37U3fR19mX06HRYfcWbBePGnDpLGH8rD06DoXkWBigOSBqecY5ScTzGPK1DYOpMZqN7AYm5desAyyZAuNpigOSB6J5ehJ(yodyMgCUXbAJcbX4oeq4WWowwy(T(yodCORjTrVkkmSLjl((yodrqoqBAiorHHnZX3hZzanYwoHXgBePw8cbHHnZX3hZzOJGUgVAkmSFTE4QCHaCWgrkyt3tjyipcY5MSLmDiGWSAJifSP7PbtkiqJzWcR7KrFmNbeKZnzlz6qaHdiQXxaowgVxMSOoA9oNcOSBqecY51dxLleGd2isbB6Ekbd5X8vrghOn6vrSAJifSP7PbtkiqJzWcR7KrFmNbmFvKXbAJEvuarn(cWXMBdzsOrVeZ9XCgW8vrghOn6vrbe14lah7BwiHc20HgB4cs8RpRfbRPE4QCHaCWgrkyt3tjyiVRreW5lGmObULvBePGnDpnysbbAmdlyDNmElEkMmwBBshSHkMOeVSJ0gfSXEKEUqGrtrxfjtw8kiKRHSbckPkomrqWQmDUJZGEG8CHazYq(QnuucKHfeDWbeY7CkqwFXj(16HRYfcWbBePGnDpLGH8dmz2KAyf4nedND4wh5yZecsdCASHSrO6HRYfcWbBePGnDpLGH8dmz2KAyLMtsLgG3qmusvCyIGGvz6ChNSUtgXJ8vBOOeidli6GdiK35uGS(ItC9Wv5cb4GnIuWMUNsWqEByUqq9OE8sDwlRtQrs66OOesAD52q1LTuDUkHO6wCDEuF5ENtH6Xl19meojNNT1TZ6SHy825uDVbG1fDWbeY7CQocqnlHRBb1PGnDpFTE4QCHamdMwftSUtgXJtY5zlPdiyKbvpCvUqaMbojNNT1dxLleGLGH8rD06DoXkWBigEtFGBnkiqV5cbSg15dIHc20HgB4csCqtZvT5tmyrcwE23sNtGmePfItUudorltuGaENtAMvqixdzdeI0cXjxQbNOLjkGOgFb4yT4vj6J5m0rqxJxnfg2mtacfr6tVtCmhFFmNbmtdo34aTrHGyChciCyyZC89XCgyIiBJu4azyBtSX7WrAKchHHD9Wv5cbyjyiFuhTENtSc8gIrpjJcc0BUqaRrD(Gy0hZzanYwoHXgBePw8cbHHTmzV5SJqBsbn5AClmdeW7CsltMZocTjfCfzg2gPWbYG5efLceW7Cs)kZ9XCgqqo3KTKPdbeomSRhVu372MT11m45AZP6shfHsmR1LTlUUOoA9oNQBX1PAjftKUUewNMuRMQJTwkBjuDyydvNCqUW1HBHdUUUovhwkqr66yBZ26KK7AQo5mFGqsRhUkxialbd5J6O17CIvG3qm6CxtMjFGqsnyPafRrD(GyGTjo3KokcL4qN7AYm5desASSWmYxTHIsGm4AnoSGNyjozY6J5m05UMmt(aHKgg21dxLleGLGH8kNZnUkxiWWxCYkWBig4KCE2Y6ozGtY5zlPdoNxpCvUqawcgYRCo34QCHadFXjRaVHyO046Xl1jNxWIBRZZ6ACRVnJM6KdX0qD)rhNixL1bbuDtiQoYvT1jjc6A8QP6CGUo2FBBikhGnLwhBTeOU39JvXuDYfYzRUfxhM4KkjDDoqx37Akx1T46aWSoe5AP15ZKq1LTuDaY6zDysbb6qDXmNnxkUUg361jzATQJTnBRJfjQlMvuOE4QCHaSemKhnagxLley4lozf4neJ5cwClR7KHc20HgB4cs8tmu2Mg36gSnb0X4T(yodDe014vtHHTe9XCgG22quoaBknmSF9zFlDobYqmzSkMmAKZwGaENtAMFl(05eidnoIjsBMqKrtE2giG35KwMmfeY1q2aHghXePntiYOjpBdiQXxa(jlE91N9nNDeAtk4kYmSnsHdKbZjkkfqoGPyzrMS4vqixdzde6uYgrat2sgskHddBzYIVpMZacY5MSLmDiGWHH9R1dxLleGLGH8kNZnUkxiWWxCYkWBig9XY11dxLleGLGH8os5aYKqeIajR7KbbiuePbnnx1MpXWINlbbiuePbefHa1dxLleGLGH8os5aYyp4yQE4QCHaSemKNVrAtSXA)qhPHaz9Wv5cbyjyiF3JyGttIwft46r94L6KCSCnHW1JxQtoHP6IPloH86(TWSUDw3M1XgeihZ6uUDDkythwNnCbjUohORlBP6y)TTH5aSP066J5SUfx3WouxmhfU66g4fePo2AjqDSFezxN1w4av372M46WPRycxNJO6A3iT1naCcJRlBP6KlY14wywxFmN1T46Cogw3WoupCvUqao0hlxZWEXjKBWTWK1DYOpMZa02gIYbytPHHnZV1hZzGjISnsHdKHTnXgVdhPrkCeWPRykwlKBzY6J5mOjxJBHzyyltgbiuePXk3p)16HRYfcWH(y5AjyipEblojKbNOLjQEupEPo5aeY1q2a46HRYfcWbLgZq5CUXv5cbg(ItwbEdXGWycOimR7Kr84KCE2s6GZ51dxLleGdknwcgY7AebC(cidAGBzDNmIVpMZGRreW5lGmObUnmSz(T4PyYyTTjDWzhU1ro2mHG0aNgBiBesMmfeY1q2abUNeinos5apGOgFb4NyjUxRhVuh75SoxRX15iQUHnR1HbRnvx2s1bbuDSTzBDCiBeoRZslLRqDYjmvhBTeOoT0fePUPJtcvx26G6KdX0600CvBwhevhBB2chzDoqADYHyAOE4QCHaCqPXsWq(ghXePntiYOjpBzvjvXjt6OiuIzybR7KbYxTHIsGm4AnomSz(T0rrOmKBdzsOrVuSkythASHliXbnnx1MYKfpojNNTKoGGrgeZkythASHliXbnnx1MpXqzBACRBW2eqhdlETE8sDSNZ6aW6CTgxhBlNxNEP6yBZ2fux2s1biRN19(4WSw3at19UMYvDqqDDigxhBB2chzDoqADYHyAOE4QCHaCqPXsWq(ghXePntiYOjpBzDNmq(QnuucKbxRXHf807JlgiF1gkkbYGR14GEG8CHaMJhNKZZwshqWidIzfSPdn2WfK4GMMRAZNyOSnnU1nyBcOJHf1JxQtsURP6KZ8bcjToiOowKOocqnlHd19UTzBDUwJzF1jNWuD7SUSLKwhoDP1nHO6SgjQdtkiqJRdIQBN1jfoq1biRN1PADueQo2woVUovhICT06wqD52q1nHO6YwQoaz9So28OuOE4QCHaCqPXsWq(o31KzYhiKuw3jdSnX5M0rrOe)edwyo((yodDURjZKpqiPHHnZVfpYxTHIsGm4AnoqwFXjwMmKVAdfLazW1ACarn(cWpznYKH8vBOOeidUwJdl4P3yjgkiKRHSbcDURjZKpqiPbvRJIqyZe5QCHaN)6ZYYZFTE4QCHaCqPXsWq(iTqCYLAWjAzIyDNmI6O17Ck05UMmt(aHKAWsbkMvWMo0ydxqIdAAUQnFIHfs0hZzOJGUgVAkmSRhUkxiahuASemKNPLZxqed2greR7KruhTENtHo31KzYhiKudwkqX8BeGqrKgYTHmj004w)PNltgbiuePXAXZFTE4QCHaCqPXsWq(o31KbnWTSUtgrD06Dof6CxtMjFGqsnyPafZeGqrKgYTHmj004w)jly(T47J5m4AebC(cidAGBddBzYiaHIinw5(5VwpEPo5eEbrQZANdwCR8XCtFGBRBX1bbCP151fLqsRlxG06wGcroMyTomSUfuhIC(MszToPWHCer15DmKpsIlTU5cO6syDdmv3M154686g5Y3uADyBIZd1dxLleGdknwcgYh1blUL1DYiECsopBjDW5CMJ6O17Ck4n9bU1OGa9MleupCvUqaoO0yjyipU11q2AiUM1DYiECsopBjDW5CMJ6O17Ck4n9bU1OGa9MleupCvUqaoO0yjyiVnmxiG1DYOpMZqNdHA(aNbe5QuMS(yodUgraNVaYGg42WWUE8sDYzNZxqK66UIP6syDAA6dEw3MutDdShHQhUkxiahuASemKFGjZMudRaVHye1rR35KzbjbWBk1ezJ4rH80aXQLZ9CbrmiYvjeX6oz0hZzOZHqnFGZaICvktwUnKjHg9sXYGL4KjtbB6qJnCbjoOP5Q2mwgSupCvUqaoO0yjyi)atMnPgmR7KrFmNHohc18bodiYvPmz52qMeA0lfldwItMmfSPdn2WfK4GMMRAZyzWs9Wv5cb4GsJLGH8DoeQnZbsA9Wv5cb4GsJLGH8DcHjetlis9Wv5cb4GsJLGH8ZfrDoeQRhUkxiahuASemK3bkcNiNBuoNxpCvUqaoO0yjyi)atMnPgwP5KuPb4nedLufhMiiyvMo3XjR7Kr84KCE2s6GZ5m3hZzW1ic48fqg0a3g0q2am3hZzOHAGiPg40WhQvB0iYBWbnKnaZeGqrKgYTHmj004w)j5Mzu2n9XCIJ951dxLleGdknwcgYpWKztQHvG3qmC2HBDKJntiinWPXgYgHyDNmIVpMZGRreW5lGmObUnmSzo((yodDURjZKpqiPHHnZkiKRHSbcUgraNVaYGg42aIA8fGJ1INxpEPoRDesADi4islxADObNQdoRlBhn9DUKUUgpBX11joKn2xDYjmv3eIQJ9eWKnuxNcTjR1bZwcX2IP6yBZ26I5NPopRJL4KOoC6kMW1br1zrCsuhBB2wNZXW6KKdH66g2H6HRYfcWbLglbd5hyYSj1WkWBigoUnQdiSb5SdImkiY5SUtgAQpMZaYzhezuqKZnAQpMZGgYgqMmn1hZzqbb6Hk3OKzbmz0uFmNHHnZPJIqzOLCE2gSvzSVNfMthfHYql58SnyRYNy8(4KjlEn1hZzqbb6Hk3OKzbmz0uFmNHHnZVPP(yodiNDqKrbro3OP(yod40vm9edwIlgwe3ZQP(yodDoeQnWPjBjdbOgPHHTmzPJIqzi3gYKqJEPyFN4EL5(yodUgraNVaYGg42aIA8fGFYcRPE8sDYfn9bpRB6CE3vmv3eIQBG9oNQBtQbhQhUkxiahuASemKFGjZMudM1DYOpMZqNdHA(aNbe5QuMSCBitcn6LILblXjtMc20HgB4csCqtZvTzSmyPEupEPoRfgtafHRhUkxiahimMakcZqbbkcKipjTzY9gI1DYGaekI0qUnKjHMg36pzbZX3hZzOZDnzM8bcjnmSz(T41WmOGafbsKNK2m5Edz6deiKRIPfeH54DvUqqqbbkcKipjTzY9gkSaZKVrAtzYMdo3GivRJIqMCBOyJO0Hg36VwpCvUqaoqymbuewcgY35qO2aNMSLmeGAKY6oze1rR35uOZDnzM8bcj1GLcumRGqUgYgi0PKnIaMSLmKuchg2mh1rR35uONKrbb6nxiOE4QCHaCGWycOiSemKpYWr61bg404SJqWSTE4QCHaCGWycOiSemKFcvdmPno7i0MKPtEdR7Kb2M4Ct6OiuIdDURjZKpqiPpXGfzYq(QnuucKbxRXHf807ehZX3hZzW1ic48fqg0a3gg21dxLleGdegtafHLGH82d0oLUGiMo3XjR7Kb2M4Ct6OiuIdDURjZKpqiPpXGfzYq(QnuucKbxRXHf807ex9Wv5cb4aHXeqryjyiF2sMbOdhaTzcrkI1DYOpMZaIumXjm2mHiffg2YK1hZzarkM4egBMqKImk4aKekGtxXuSwex9Wv5cb4aHXeqryjyipATT5KzbgSTRO6HRYfcWbcJjGIWsWqE2GiUokTadIWqGduu9Wv5cb4aHXeqryjyiFd1arsnWPHpuR2OrK3GzDNmiaHIinw5(51dxLleGdegtafHLGH8iYTxqeZK7neM1DYiDuekdTKZZ2GTkFYAItMS0rrOm0sopBd2QmwgSeNmzPJIqzi3gYKqJTknSe3tVpU6r94L6KZlyXTecxpEPojtRvDWOeQUNjLSoeHGCoUo22STo5ICnUfMYhZkQUe5BIRdIQ7zgzlNW46IPisT4fcc1dxLleGdZfS4wgDkzJiGjBjdjLWSUtgrD06Dof6jzuqGEZfcQhUkxiahMlyXTsWqEmFvKXbAJEveR7KrFmNbmFvKXbAJEvuarn(cWXMBdzsOrVeZ9XCgW8vrghOn6vrbe14lah7BwiHc20HgB4cs8RpRfbRPE4QCHaCyUGf3kbd5rqo3KTKPdbeM1DYOpMZacY5MSLmDiGWbe14lahlJ3ltwuhTENtbu2nicb586Xl1jzATQJTnBRlBP6IzfvNCYUoRTWbQUpNOOuDquDYf5AClmRlr(M4q9Wv5cb4WCblUvcgY3PKnIaMSLmKucZ6oz4SJqBsbxrMHTrkCGmyorrPab8oN0YK5SJqBsbn5AClmdeW7CsxpCvUqaomxWIBLGH86fB7PQTEupEPUFsopBRhUkxiahWj58SLH30h4wXpkHWleiSIL4yjU4EFCwi(S5iWcIGfF2ZgBikjDDSh15QCHG64loXH6H47JSfIe))2iheF(ItSWsXNWycOiSWsHvwiSu8jG35KwiP4RqBsO1fFcqOisd52qMeAACRx3t1zrDmxx811hZzOZDnzM8bcjnmSRJ56ERU4RtdZGccueirEsAZK7nKPpqGqUkMwqK6yUU4RZv5cbbfeOiqI8K0Mj3BOWcmt(gPnRtMS6Mdo3GivRJIqMCBO6ITUikDOXTEDVk(Ukxiq8vqGIajYtsBMCVHePWkwewk(eW7CslKu8vOnj06IFuhTENtHo31KzYhiKudwkqvhZ1PGqUgYgi0PKnIaMSLmKuchg21XCDrD06Dof6jzuqGEZfceFxLlei(DoeQnWPjBjdbOgPIuy17fwk(Ukxiq8JmCKEDGbono7iemBfFc4DoPfsksHvYTWsXNaENtAHKIVcTjHwx8X2eNBshfHsCOZDnzM8bcjTUNyuhl1jtwDiF1gkkbYGR14WcQ7P6EN4QJ56IVU(yodUgraNVaYGg42WWw8DvUqG4pHQbM0gNDeAtY0jVrKcREUWsXNaENtAHKIVcTjHwx8X2eNBshfHsCOZDnzM8bcjTUNyuhl1jtwDiF1gkkbYGR14WcQ7P6EN4eFxLlei(2d0oLUGiMo3XPifw9oclfFc4DoPfsk(k0MeADXVpMZaIumXjm2mHiffg21jtwD9XCgqKIjoHXMjePiJcoajHc40vmvxS1zrCIVRYfce)SLmdqhoaAZeIuKifwXEiSu8DvUqG4JwBBozwGbB7ks8jG35KwiPifwznclfFxLlei(SbrCDuAbgeHHahOiXNaENtAHKIuyf7vyP4taVZjTqsXxH2KqRl(eGqrKwxS1j3px8DvUqG43qnqKudCA4d1QnAe5nyrkSYI4ewk(eW7CslKu8vOnj06IF6OiugAjNNTbBvw3t1znXvNmz1LokcLHwY5zBWwL1flJ6yjU6KjRU0rrOmKBdzsOXwLgwIRUNQ79Xj(Ukxiq8rKBVGiMj3BiSifP4RPPp4PWsHvwiSu8jG35KwiP4RqBsO1f)4RdNKZZwshqWids8DvUqG4Z0QysKcRyryP47QCHaXhNKZZwXNaENtAHKIuy17fwk(eW7CslKu8H2IpMsX3v5cbIFuhTENtIFuNpiXxbB6qJnCbjoOP5Q2SUNyuhl1jrDSu3Zw3B1LoNazisleNCPgCIwMOab8oN01XCDkiKRHSbcrAH4Kl1Gt0YefquJVaCDXwNf19ADsuxFmNHoc6A8QPWWUoMRJaekI06EQU3jU6yUU4RRpMZaMPbNBCG2OqqmUdbeomSRJ56IVU(yodmrKTrkCGmSTj24D4insHJWWw8J6idWBiX3B6dCRrbb6nxiqKcRKBHLIpb8oN0cjfFOT4JPu8DvUqG4h1rR35K4h15ds87J5mGgzlNWyJnIulEHGWWUozYQ7T6C2rOnPGMCnUfMbc4DoPRtMS6C2rOnPGRiZW2ifoqgmNOOuGaENt66EToMRRpMZacY5MSLmDiGWHHT4h1rgG3qIFpjJcc0BUqGifw9CHLIpb8oN0cjfFOT4JPu8DvUqG4h1rR35K4h15ds8X2eNBshfHsCOZDnzM8bcjTUyRJL6yUoKVAdfLazW1ACyb19uDSexDYKvxFmNHo31KzYhiK0WWw8J6idWBiXVZDnzM8bcj1GLcuIuy17iSu8jG35KwiP47QCHaXx5CUXv5cbg(ItXxH2KqRl(4KCE2s6GZ5IpFXPb4nK4JtY5zRifwXEiSu8jG35KwiP47QCHaXx5CUXv5cbg(ItXNV40a8gs8vASifwznclfFc4DoPfsk(Ukxiq8rdGXv5cbg(ItXxH2KqRl(kythASHliX19eJ6u2Mg36gSnb01fJ6ERU(yodDe014vtHHDDsuxFmNbOTneLdWMsdd76ETUNTU3QlDobYqmzSkMmAKZwGaENt66yUU3Ql(6sNtGm04iMiTzcrgn5zBGaENt66KjRofeY1q2aHghXePntiYOjpBdiQXxaUUNQZI6ETUxR7zR7T6C2rOnPGRiZW2ifoqgmNOOua5aMQl26yPozYQl(6uqixdzde6uYgrat2sgskHdd76KjRU4RRpMZacY5MSLmDiGWHHDDVk(8fNgG3qI)CblUvKcRyVclfFc4DoPfsk(Ukxiq8voNBCvUqGHV4u85lonaVHe)(y5ArkSYI4ewk(eW7CslKu8vOnj06IpbiuePbnnx1M19eJ6S451jrDeGqrKgqueci(Ukxiq8DKYbKjHiebsrkSYclewk(Ukxiq8DKYbKXEWXK4taVZjTqsrkSYcwewk(Ukxiq85BK2eBS2p0rAiqk(eW7CslKuKcRS49clfFxLlei(DpIbonjAvmHfFc4DoPfsksrk(2isbB6EkSuyLfclfFc4DoPfsk(k0MeADXh5R2qrjqgCTghwqDpvNChN47QCHaXVXrmrAZeImAYZwX3grkyt3tdMuqGgl(pxKcRyryP4taVZjTqsXxH2KqRl(Vvx81rXKXABt6GnuXeL4LDK2OGn2J0ZfcmAk6QO6KjRU4RtbHCnKnqqjvXHjccwLPZDCg0dKNleuNmz1H8vBOOeidli6GdiK35uGS(ItCDVk(Ukxiq8Xj58SvKcREVWsXNaENtAHKIp0w8Xuk(Ukxiq8J6O17Cs8J68bj(OSB6J5exxS1XsDmx3B11hZzGdDnPn6vrHHDDYKvx811hZzOJGUgVAkmSR7vXpQJmaVHeFu2nicb5CXxH2KqRl(o7i0MuqtUg3cZab8oN0IuyLClSu8jG35KwiP4dTfFmLIVRYfce)OoA9oNe)OoFqIpk7M(yoX1fBDSuhZ19wD9XCg4qxtAJEvuyyxNmz11hZzanYwoHXgBePw8cbbe14laxxSmQtbHCnKnqOtjBebmzlziPeoGOgFb46Ev8J6idWBiXhLDdIqqox8vOnj06IVZocTjfCfzg2gPWbYG5efLceW7CsxhZ15SJqBsbxrMHTrkCGmyorrPaYbmv3tmQZzhH2KcAY14wygqoGjrkS65clfFc4DoPfsk(qBXhtP47QCHaXpQJwVZjXpQZhK4JYUPpMtCDXwhlIFuhzaEdj(OSBqecY5IVcTjHwx8D2rOnPag4mrgskHdihWuDpXOowePWQ3ryP4taVZjTqsXhAl(ictP47QCHaXpQJwVZjXpQJmaVHeFu2nicb5CXxH2KqRl(o7i0MuadCMidjLWbKdyQUNyuhl1XCD9XCgWaNjYqsjCaNUIP6EIrDSuxmQRpMZqhbDnE1uyylsHvShclfFc4DoPfsk(qBXhtP47QCHaXpQJwVZjXpQZhK4JYUPpMtCDXOU(yodyMgCUXbAJcbX4oeq4WWUUyRJL6yUU3QRpMZah6AsB0RIcd76KjRU4RRpMZqeKd0MgItuyyxhZ1fFD9XCgqJSLtySXgrQfVqqyyxhZ1fFD9XCg6iORXRMcd76Ev8J6idWBiXhLDdIqqox8vOnj06IFFmNHo31KzYhiK0WWwKcRSgHLIpb8oN0cjfFfAtcTU43hZzab5Ct2sMoeq4aIA8fGRlwg19(6KjRUOoA9oNcOSBqecY5IVRYfceFeKZnzlz6qaHfFBePGnDpnysbbAS4ZIifwXEfwk(eW7CslKu8vOnj06IFFmNbmFvKXbAJEvuarn(cW1fBD52qMeA0lvhZ11hZzaZxfzCG2OxffquJVaCDXw3B1zrDsuNc20HgB4csCDVw3ZwNfbRr8DvUqG4J5RImoqB0RIeFBePGnDpnysbbAS4ZIifwzrCclfFc4DoPfsk(k0MeADX)T6IVokMmwBBshSHkMOeVSJ0gfSXEKEUqGrtrxfvNmz1fFDkiKRHSbckPkomrqWQmDUJZGEG8CHG6KjRoKVAdfLazybrhCaH8oNcK1xCIR7vX3v5cbIVRreW5lGmObUv8TrKc2090GjfeOXIVfIuyLfwiSu8jG35KwiP4d8gs8D2HBDKJntiinWPXgYgHeFxLlei(o7WToYXMjeKg40ydzJqIuyLfSiSu8jG35KwiP4RqBsO1f)4Rd5R2qrjqgwq0bhqiVZPaz9fNyX3v5cbIVsQIdteeSktN74u8P5KuPb4nK4RKQ4WebbRY05oofPWklEVWsX3v5cbIVnmxiq8jG35KwiPifP4pxWIBfwkSYcHLIpb8oN0cjfFfAtcTU4h1rR35uONKrbb6nxiq8DvUqG43PKnIaMSLmKuclsHvSiSu8jG35KwiP4RqBsO1f)(yody(QiJd0g9QOaIA8fGRl26YTHmj0OxQoMRRpMZaMVkY4aTrVkkGOgFb46ITU3QZI6KOofSPdn2WfK46ETUNTolcwJ47QCHaXhZxfzCG2OxfjsHvVxyP4taVZjTqsXxH2KqRl(9XCgqqo3KTKPdbeoGOgFb46ILrDVVozYQlQJwVZPak7geHGCU47QCHaXhb5Ct2sMoeqyrkSsUfwk(eW7CslKu8vOnj06IVZocTjfCfzg2gPWbYG5efLceW7CsxNmz15SJqBsbn5AClmdeW7Csl(Ukxiq87uYgrat2sgskHfPWQNlSu8DvUqG4RxSTNQwXNaENtAHKIuKIpojNNTclfwzHWsX3v5cbIV30h4wXNaENtAHKIuKIVsJfwkSYcHLIpb8oN0cjfFxLlei(kNZnUkxiWWxCk(k0MeADXp(6Wj58SL0bNZfF(ItdWBiXNWycOiSifwXIWsXNaENtAHKIVcTjHwx8JVU(yodUgraNVaYGg42WWUoMR7T6IVokMmwBBshC2HBDKJntiinWPXgYgHQtMS6uqixdzde4EsG04iLd8aIA8fGR7P6yjU6Ev8DvUqG47AebC(cidAGBfPWQ3lSu8jG35KwiP4RqBsO1fFKVAdfLazW1ACyyxhZ19wDPJIqzi3gYKqJEP6ITofSPdn2WfK4GMMRAZ6KjRU4RdNKZZwshqWidQoMRtbB6qJnCbjoOP5Q2SUNyuNY204w3GTjGUUyuNf19Q47QCHaXVXrmrAZeImAYZwXxjvXjt6OiuIfwzHifwj3clfFc4DoPfsk(k0MeADXh5R2qrjqgCTghwqDpv37JRUyuhYxTHIsGm4AnoOhipxiOoMRl(6Wj58SL0bemYGQJ56uWMo0ydxqIdAAUQnR7jg1PSnnU1nyBcORlg1zH47QCHaXVXrmrAZeImAYZwrkS65clfFc4DoPfsk(k0MeADXhBtCUjDuekX19eJ6yPoMRl(66J5m05UMmt(aHKgg21XCDVvx81H8vBOOeidUwJdK1xCIRtMS6q(QnuucKbxRXbe14lax3t1zn1jtwDiF1gkkbYGR14WcQ7P6ERowQlg1PGqUgYgi05UMmt(aHKguTokcHntKRYfcCEDVw3ZwhlpVUxfFxLlei(DURjZKpqiPIuy17iSu8jG35KwiP4RqBsO1f)OoA9oNcDURjZKpqiPgSuGQoMRtbB6qJnCbjoOP5Q2SUNyuNf1jrD9XCg6iORXRMcdBX3v5cbIFKwio5sn4eTmrIuyf7HWsXNaENtAHKIVcTjHwx8J6O17Ck05UMmt(aHKAWsbQ6yUU3QJaekI0qUnKjHMg3619uDpVozYQJaekI06ITolEEDVk(Ukxiq8zA58feXGTrejsHvwJWsXNaENtAHKIVcTjHwx8J6O17Ck05UMmt(aHKAWsbQ6yUocqOisd52qMeAACRx3t1zrDmx3B1fFD9XCgCnIaoFbKbnWTHHDDYKvhbiueP1fBDY9ZR7vX3v5cbIFN7AYGg4wrkSI9kSu8jG35KwiP4RqBsO1f)4RdNKZZwshCoVoMRlQJwVZPG30h4wJcc0BUqG47QCHaXpQdwCRifwzrCclfFc4DoPfsk(k0MeADXp(6Wj58SL0bNZRJ56I6O17Ck4n9bU1OGa9Mlei(Ukxiq8XTUgYwdX1IuyLfwiSu8jG35KwiP4RqBsO1f)(yodDoeQ5dCgqKRY6KjRU(yodUgraNVaYGg42WWw8DvUqG4BdZfcePWklyryP4taVZjTqsXh4nK4h1rR35KzbjbWBk1ezJ4rH80aXQLZ9CbrmiYvjej(Ukxiq8J6O17CYSGKa4nLAISr8OqEAGy1Y5EUGige5QeIeFfAtcTU43hZzOZHqnFGZaICvwNmz1LBdzsOrVuDXYOowIRozYQtbB6qJnCbjoOP5Q2SUyzuhlIuyLfVxyP4taVZjTqsXxH2KqRl(9XCg6CiuZh4mGixL1jtwD52qMeA0lvxSmQJL4QtMS6uWMo0ydxqIdAAUQnRlwg1XI47QCHaXFGjZMudwKcRSqUfwk(Ukxiq87CiuBMdKuXNaENtAHKIuyLfpxyP47QCHaXVtimHyAbreFc4DoPfsksHvw8oclfFxLlei(ZfrDoeQfFc4DoPfsksHvwWEiSu8DvUqG47afHtKZnkNZfFc4DoPfsksHvwynclfFc4DoPfsk(k0MeADXp(6Wj58SL0bNZRJ566J5m4AebC(cidAGBdAiBG6yUU(yodnudej1aNg(qTAJgrEdoOHSbQJ56iaHIinKBdzsOPXTEDpvNCxhZ1HYUPpMtCDXw3ZfFxLlei(kPkomrqWQmDUJtXNMtsLgG3qIVsQIdteeSktN74uKcRSG9kSu8jG35KwiP4d8gs8D2HBDKJntiinWPXgYgHeFxLlei(o7WToYXMjeKg40ydzJqIVcTjHwx8JVU(yodUgraNVaYGg42WWUoMRl(66J5m05UMmt(aHKgg21XCDkiKRHSbcUgraNVaYGg42aIA8fGRl26S45IuyflXjSu8jG35KwiP4d8gs8DCBuhqydYzhezuqKZfFxLlei(oUnQdiSb5SdImkiY5IVcTjHwx81uFmNbKZoiYOGiNB0uFmNbnKnqDYKvNM6J5mOGa9qLBuYSaMmAQpMZWWUoMRlDuekdTKZZ2GTkRl26Epl1XCDPJIqzOLCE2gSvzDpXOU3hxDYKvx81PP(yodkiqpu5gLmlGjJM6J5mmSRJ56ERon1hZza5SdImkiY5gn1hZzaNUIP6EIrDSexDXOolIRUNTon1hZzOZHqTbonzlzia1inmSRtMS6shfHYqUnKjHg9s1fBDVtC19ADmxxFmNbxJiGZxazqdCBarn(cW19uDwynIuyflwiSu8jG35KwiP4RqBsO1f)(yodDoeQ5dCgqKRY6KjRUCBitcn6LQlwg1XsC1jtwDkythASHliXbnnx1M1flJ6yr8DvUqG4pWKztQblsrk(9XY1clfwzHWsXNaENtAHKIVcTjHwx87J5maTTHOCa2uAyyxhZ19wD9XCgyIiBJu4azyBtSX7WrAKchbC6kMQl26SqURtMS66J5mOjxJBHzyyxNmz1racfrADXwNC)86Ev8DvUqG4BV4eYn4wyksHvSiSu8DvUqG4JxWItczWjAzIeFc4DoPfsksrksrksHa]] )


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