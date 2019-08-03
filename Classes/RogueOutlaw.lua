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


    spec:RegisterPack( "Outlaw", 20190803, [[daLXhbqirLEKQeBcf1NisfJsvkNsvsRIiL6vOunluIBjQWUe5xeLgMQOogrYYqP8mvPQPrjPUMQuzBQc4BePkJJssohrvL1PkOMNQi3df2NQqhuvGwirXdjsjtKOQCrrfLnsKk9rrfHojrkYkfv9sIuuZKOQkCtIuWoPK6NePqdLiv1rjQQIwQQG8uv1ujQCvrfPTsuvv(QOIOXsuvLoROIG9s4VumyvomvlwHhtQjtYLr2SI(SO0OLsNwPvtuvv9AuKzJQBlf7g43GgoL64IkQwoKNd10fUUuTDrX3rjnEkjoprSEIQmFkX(LSqkHCIVYdsynBplL87zR653NKITNTkR2Qf)qInj(2UMjplj(aVHeFPXEWDwfFBxch6kHCIpg2rAs8BJWg)WYkB2nA7JKg2ilEB6CpwiqJ8zilEB0Yk(J(YdPjGyi(kpiH1S9SuYVNTQNFFsk2E2QEVuIp2M0cRz7bEw8BxLIaIH4RiSw8FPoPXEWDwR7HGz7uL)L6AJWg)WYkB2nA7JKg2ilEB6CpwiqJ8zilEB0Yw5FPUhSNTJJ6Epl1X2Zsj)Qlh1j1ZpmBsVkFL)L6KwToilHF4k)l1LJ6EqLIu1jnVAMQlG1POP35rDUowiOo(IJuL)L6YrDpOsrQ6SrKg2m8Ooz4UIQt6Y7iKK6Etbjmq6e1nqKZuD)GCE0(AQY)sD5Oo5dcKorDDmvxGwatuGRBb1HdY5rBQY)sD5Oo5dcKorDDmvxZcEy5V1nHO6KgCetKQUjevN8rE0w3BBiDW1bGrD4UTnefK61uL)L6YrDpyg4QQdriiNVGS19qHm1P6OfKToz4UIQt6Y7iKK6ERd4egxhRuDqaxsDTEgQoPQlCuwkEnv5FPUCu3drC3k1jnVC(cYw33gruQY)sD5OUCkMQl2gYeqJAP6MquDeqd7GGq1ra1cYwhYJwcvx06G6chLLIuSnKjGg1sjX3gbNlNe)xQtAShCN16Eiy2ov5FPU2iSXpSSYMDJ2(iPHnYI3Mo3Jfc0iFgYI3gTSv(xQ7b7z74OU3ZsDS9SuYV6YrDs98dZM0RYx5FPoPvRdYs4hUY)sD5OUhuPivDsZRMP6cyDkA6DEuNRJfcQJV4iv5FPUCu3dQuKQoBePHndpQtgURO6KU8ocjPU3uqcdKorDde5mv3piNhTVMQ8VuxoQt(GaPtuxht1fOfWef46wqD4GCE0MQ8VuxoQt(GaPtuxht11SGhw(BDtiQoPbhXePQBcr1jFKhT192gshCDayuhUBBdrbPEnv5FPUCu3dMbUQ6qecY5liBDpuitDQoAbzRtgURO6KU8ocjPU36aoHX1XkvheWLuxRNHQtQ6chLLIxtv(xQlh19qe3TsDsZlNVGS19TreLQ8VuxoQlNIP6ITHmb0OwQUjevhb0WoiiuDeqTGS1H8OLq1fToOUWrzPifBdzcOrTuQYx5FPUCMviDpivDdAcruDAyZWJ6gu2fGt19GAnzh46aqqoADuZSZRZ1Xcb46GaUKuL)L6CDSqaozJinSz4bJj3Xmv5FPoxhleGt2isdBgEWodz9E2gceESqqL)L6CDSqaozJinSz4b7mKDcHQk)l19bUnUfg1H8vv3OpNKQoC4bUUbnHiQonSz4rDdk7cW15avD2ikh2Wiwq26wCDkiGsv(xQZ1Xcb4KnI0WMHhSZqwmWTXTWWGdpWvExhleGt2isdBgEWodzTHXcbvExhleGt2isdBgEWodzBCetKYmHiJI8OLfBePHndpmysdbkmJ3XYozG8vzOmeisUsHtl4rR(5kVRJfcWjBePHndpyNHS4GCE0YYoz8wUuoVV22Kkzd1mrbELhPmAyJDp8yHaJIYSAYILC1qixbzfK0s0CyGGGvBgChhjvh5XcbwSG8vzOmeislitNdiKp4uISYId8RvExhleGt2isdBgEWodzrqo3eTKzabeMfBePHndpmysdbkmd2Q8UowiaNSrKg2m8GDgYI5RMmoqzuRMyXgrAyZWddM0qGcZGTkVRJfcWjBePHndpyNHSUcraNVaYG64wwSrKg2m8WGjneOWmKILDY4TCPCEFTTjvYgQzIc8kpsz0Wg7E4XcbgfLz1Kfl5QHqUcYkiPLO5WabbR2m4oosQoYJfcSyb5RYqziqKwqMohqiFWPezLfh4xR8UowiaNSrKg2m8GDgY2XKzdQHfG3qmC5HBDKJntiimWPXgYkHQ8UowiaNSrKg2m8GDgY2XKzdQHfAojDyaEdXqlrZHbccwTzWDCWYozKlYxLHYqGiTGmDoGq(GtjYkloWv(k)l1LZScP7bPQJYqij1fBdvx0s156aIQBX15z8L7doLQ8Vu3dr4GCE0w3oRZgIX7Gt19gawxMohqiFWP6ia1SeUUfuNg2m841kVRJfcWmyA1mXYozKloiNhTKkHGz7uL31Xcbyg4GCE0w5FPUhIqqoVUjevhBSx3OpN46yDJ26K)a6ksvN8TAQUUDQoPXOLqSUyQoeHGCEDtiQo2yVoiQUCIihOQtAG4evhev3d1JwoHX1j9rKEXleKQ8UowiaZodzZ4O1hCIfG3qmqXWGieKZzjJZ7edummJ(CIFInMFB0NZeh6kszuRMsDBlwYD0NZuwKduMgItuQBZCUJ(CMq9OLtySXgr6fVqqQB)AL)L6Eicb586MquDSXEDJ(CIRdIQ7H6rlNW46K(isV4fcQJ1nARt(ixHBHrDquDpOMQRBxNeyhv3Ntugkv5DDSqaMDgYMXrRp4elaVHyGIHbriiNZc0MbMcw2jdxEeAdkPixHBHrIa(GtklwC5rOnOKRjt32ib2rgmNOmuIa(GtkwY48oXafdZOpN4NyJ53g95mXHUIug1QPu32ILrFotOE0Yjm2yJi9IxiiHOgFb4NyOHqUcYkinOGvIaMOLmKecNquJVa8Rv(xQJn2R7dCMO6Yzsi8dx3dYz1LGRdriiNx3eIQJn2RB0NtCQY76yHam7mKnJJwFWjwaEdXafddIqqoNfOndmfSStgU8i0gucdCMidjHWjKdy6rgSXsgN3jgOyyg95e)eBv(xQJn2R7dCMO6Yzsi8dxN8bRdaJ6qecY51X6gT1Xg71HdxZeUo4SUOLQ7dCMO6YzsiCDJ(Cw3BsXED4W1mvhRB0wNmiORWRIQRB)AQY76yHam7mKnJJwFWjwaEdXafddIqqoNfOndeHPGLDYWLhH2GsyGZezijeoHCatpYGnMh95mHbotKHKq4eoCntpYGTCm6ZzAGGUcVkk1TR8Vuxo5gT1jd3vuDsxEhHKux3ML62SaiIQd15eUoFaZq15avDHZevhLHqsI2fKTUO1J6wCDSXEDVbGrDAyheliBDFxA9ADquD4fKLt1jZNL6YjknWsDpK0VY76yHam7mKnJJwFWjwaEdXafddIqqoNfOndmfSStgJ(CMgCxrMjVJqssDBwY48oXafdZOpN4Cm6ZzcZuNZnoqz0iigpGacN62pXgZVn6ZzIdDfPmQvtPUTfl5o6ZzklYbktdXjk1Tzo3rFotOE0Yjm2yJi9Ixii1Tzo3rFotde0v4vrPU9RvExhleGzNHSzC06doXcWBigEZOJBnAiqTXcbSKX5DIHg2mGgB4ccCsrZvVXJmyJD2K2VfoNarkBlehCjgCGwMOeb8bNumRHqUcYkiLTfIdUedoqltucrn(cWpj1RSp6ZzAGGUcVkk1TzMaekRKhFGNzo3rFotyM6CUXbkJgbX4beq4u3M5Ch95mXer2gjWoYW6gyJpG9Wib2tD7kVRJfcWSZq2moA9bNyb4neJrqgneO2yHawY48oXy0NZeQhTCcJn2isV4fcsDBlwEZLhH2GskYv4wyKiGp4KYIfxEeAdk5AY0TnsGDKbZjkdLiGp4K6vMh95mHGCUjAjZaciCQBx5FPUCYnARRPZJ1Mt1foklfywQlAxCDzC06dov3IRt3sAMivDbSofPxfvhRTu0sO6WWgQoPL8HRd3c7CvDdQoSeGMu1X6gT1jd3vuDsxEhHKu5DDSqaMDgYMXrRp4elaVHym4UImtEhHKyWsaAwY48oXaBtCUjCuwkWPb3vKzY7iKKNyJzKVkdLHarYvkCAbpY2ZwSm6ZzAWDfzM8ocjj1TR8UowiaZodz1oNBCDSqGHV4GfG3qmWb58OLLDYahKZJwsLCoVY76yHam7mKv7CUX1Xcbg(IdwaEdXqRWv(xQt6UGf3wNh114wzB6n1jTK(P6(9boqUoQdcO6MquDKRBRtge0v4vr15avDsJ22qu0bBiPowBjqDYF2xnt1jFiN16wCDyIt6Gu15avDsdt5RUfxhag1HixjPoFgeQUOLQdqwjQdtAiqLQ8UowiaZodzrDGX1Xcbg(IdwaEdXyUGf3YYozOHndOXgUGa)idTTPXTIbBtavoEB0NZ0abDfEvuQBZ(OpNjOTnefDWgssD7xL2VfoNarkN3xntgfYznraFWjfZVLB4CcePghXePmtiYOipAteWhCszXIgc5kiRGuJJyIuMjezuKhTje14la)OuV(AL31Xcby2ziR25CJRJfcm8fhSa8gIXOVCvL31Xcby2ziRJ0oGmbeHiqWYozqacLvssrZvVXJmK6DStacLvscrzjqL31Xcby2ziRJ0oGm2DoMQ8UowiaZodz5B22aBK)3vzBiqu5R8VuNm9LRieUY)sD5umvN0FXbKx3Vfg1TZ62OowHaPtuN2TRtdBgW6SHliW15avDrlvN0OTnm6GnKu3OpN1T4662P6EWmWvvxhVGS1XAlbQtAMi76Yja7O6Yj3axhoCnt46Cevx7MTTUoGtyCDrlvN8rUc3cJ6g95SUfxNZXW662PkVRJfcWPrF5kg2loGCdUfgSStgJ(CMG22qu0bBij1Tz(TrFotmrKTrcSJmSUb24dypmsG9eoCntpj1ZwSm6ZzsrUc3cJu32IfcqOSsEYQF3RvExhleGtJ(YvSZqw8cwCqidoqltuLVY)sDsliKRGScWvExhleGtAfMH25CJRJfcm8fhSa8gIbHXeqtyw2jJCXb58OLujNZR8UowiaN0km7mK1vic48fqguh3YYozK7OpNjxHiGZxazqDCBQBZmbiuwjPyBitannUvEukMFlxkN3xBBsLC5HBDKJntiimWPXgYkHSyrdHCfKvqI7bbcJJ0oWtiQXxa(r2E(1k)l1jnnRZvkCDoIQRBZsDyWAt1fTuDqavhRB0whhYkHJ6Kto5lvxoft1XAlbQtjzbzRB64Gq1fToOoPL0Vofnx9g1br1X6gTWEuNdKuN0s6NQ8UowiaN0km7mKTXrmrkZeImkYJww0s0CYeoklfygsXYozG8vzOmeisUsHtDBMFlCuwksX2qMaAul9Kg2mGgB4ccCsrZvVHfl5IdY5rlPsiy2oXSg2mGgB4ccCsrZvVXJm02Mg3kgSnbu5qQxR8VuN00SoaSoxPW1X6Y51PwQow3ODb1fTuDaYkrDV)zml11XuDsdt5RoiOUbeJRJ1nAH9OohiPoPL0pv5DDSqaoPvy2ziBJJyIuMjezuKhTSStgiFvgkdbIKRu40cE89pNdKVkdLHarYvkCs1rESqaZ5IdY5rlPsiy2oXSg2mGgB4ccCsrZvVXJm02Mg3kgSnbu5qQk)l1jd3vuDsxEhHKuheuhBSxhbOMLWP6Yj3OToxPWpCD5umv3oRlAjj1HdxsDtiQoRI96WKgcu46GO62zDsGDuDaYkrD6whLLQJ1LZRBq1HixjPUfuxSnuDtiQUOLQdqwjQJvpdLQ8UowiaN0km7mKDWDfzM8ocjHLDYaBtCUjCuwkWpYGnMZD0NZ0G7kYm5DessQBZ8B5I8vzOmeisUsHtKvwCGTyb5RYqziqKCLcNquJVa8JwLfliFvgkdbIKRu40cE8n2YHgc5kiRG0G7kYm5Desss36OSe2mrUowiW5VkTz7DVw5DDSqaoPvy2ziB2wio4sm4aTmrSStgzC06doLgCxrMjVJqsmyjanZAyZaASHliWjfnx9gpYqk2h95mnqqxHxfL62vExhleGtAfMDgYY0Y5liRbBJiILDYiJJwFWP0G7kYm5DesIblbOz(ncqOSssX2qMaAACR847SyHaekRKNK6DVw5DDSqaoPvy2zi7G7kYG64ww2jJmoA9bNsdURiZK3rijgSeGMzcqOSssX2qMaAACR8Ouv(xQlNIxq26K)5Gf3k7d2m6426wCDqaxsDEDziKK6IfiPUfOrKJjwQddRBb1HiNVHewQtcSlDquD(ad59G4sQBUaQUawxht1TrDoUoVUES8nKuh2M48uL31Xcb4KwHzNHSzCWIBzzNmYfhKZJwsLCoN5moA9bNsEZOJBnAiqTXcbvExhleGtAfMDgYIBDfK1gIRyzNmYfhKZJwsLCoN5moA9bNsEZOJBnAiqTXcbvExhleGtAfMDgYAdJfcyzNmg95mn4qOI3XrcrUoSyz0NZKRqeW5lGmOoUn1TR8VuN0158fKTUHRzQUawNIMENh1Tb1uxh7zPkVRJfcWjTcZodz7yYSb1WcWBigzC06dozwqqa8gsmz3SEgipmqSE5CpwqwdICDarSStgJ(CMgCiuX74iHixhwSeBdzcOrT0tmy7zlw0WMb0ydxqGtkAU6nEIbBvExhleGtAfMDgY2XKzdQbZYozm6ZzAWHqfVJJeICDyXsSnKjGg1spXGTNTyrdBgqJnCbboPO5Q34jgSv5DDSqaoPvy2zi7GdHkZSJKu5DDSqaoPvy2zi7GqycX0cYw5DDSqaoPvy2zi7Cr0GdHQkVRJfcWjTcZodzDGMWbY5gTZ5vExhleGtAfMDgY2XKzdQHfAojDyaEdXqlrZHbccwTzWDCWYozKloiNhTKk5CoZJ(CMCfIaoFbKb1XTjfKvaZJ(CMAOgisIbon8UEvgfI8gCsbzfWmbiuwjPyBitannUvE0QzgfdZOpN4NExL31Xcb4KwHzNHSDmz2GAyb4nedxE4wh5yZeccdCASHSsiw2jJCh95m5kebC(cidQJBtDBMZD0NZ0G7kYm5DessQBZSgc5kiRGKRqeW5lGmOoUnHOgFb4NK6Dv(xQt(hHKuhc2Z2YLuhQZP6GZ6I2EZyNlPQRXJwCDdIdz9HRlNIP6MquDstaMSHQ60OnyPoy0siwxmvhRB0w3d(q15rDS9m71HdxZeUoiQoPEM96yDJ26CogwNmCiuvx3ov5DDSqaoPvy2ziBhtMnOgwaEdXWXTzCaHnixEqKrdroNLDYqrJ(CMqU8GiJgICUrrJ(CMuqwbwSOOrFotAiq11XMHmlGjJIg95m1TzoCuwksTKZJ2KToE69SXC4OSuKAjNhTjBD8iJ3)Sfl5QOrFotAiq11XMHmlGjJIg95m1Tz(nfn6Zzc5YdImAiY5gfn6ZzchUMPhzW2Z5qQNL2kA0NZ0GdHkdCAIwYqaQrsQBBXs4OSuKITHmb0Ow6Ph45xzE0NZKRqeW5lGmOoUnHOgFb4hLYQQ8VuN8rtVZJ6MoNpCnt1nHO66yFWP62GAWPkVRJfcWjTcZodz7yYSb1GzzNmg95mn4qOI3XrcrUoSyj2gYeqJAPNyW2ZwSOHndOXgUGaNu0C1B8ed2Q8v(xQlNHXeqt4kVRJfcWjcJjGMWm0qGMabYdszMCVHyzNmiaHYkjfBdzcOPXTYJsXCUJ(CMgCxrMjVJqssDBMFlxfmsAiqtGa5bPmtU3qMrhbsXQzAbzzoxxhleK0qGMabYdszMCVHslWm5B22WILzNZnis36OSKj2g6PSAvQXTYRvExhleGtegtanHzNHSdoeQmWPjAjdbOgjSStgzC06doLgCxrMjVJqsmyjanZAiKRGScsdkyLiGjAjdjHWPUnZzC06doLgbz0qGAJfcQ8UowiaNimMaAcZodzZ2DKADGbonU8iemAR8UowiaNimMaAcZodzNqDhtkJlpcTbzgK3WYozGTjo3eoklf40G7kYm5DesYJmyZIfKVkdLHarYvkCAbp(apZCUJ(CMCfIaoFbKb1XTPUDL31Xcb4eHXeqty2ziRDhTtjliRzWDCWYozGTjo3eoklf40G7kYm5DesYJmyZIfKVkdLHarYvkCAbp(apx5DDSqaorymb0eMDgYgTKPdgWoqzMqKMyzNmg95mHintCcJntistPUTflJ(CMqKMjoHXMjePjJg2bbHs4W1m9Kupx5DDSqaorymb0eMDgYIwBBozwGbB7AQY76yHaCIWycOjm7mKLviIRYqlWGime4anXYozm6ZzIVtAWHqvchUMPNEFL31Xcb4eHXeqty2ziBd1arsmWPH31RYOqK3GzzNmiaHYk5jR(Dv(k)l1jDxWIBjeUY)sDYe5S6GziuDpuitDicb5CCDSUrBDYh5kClmK9b1uDbY3axhev3d1JwoHX1j9rKEXleKQ8UowiaNMlyXTmguWkrat0sgscHzzNmY4O1hCkncYOHa1gleu5DDSqaonxWIBzNHSy(QjJdug1Qjw2jJrFoty(QjJdug1QPeIA8fGFk2gYeqJAjMh95mH5RMmoqzuRMsiQXxa(P3KIDnSzan2Wfe4xL2sLSQkVRJfcWP5cwCl7mKfb5Ct0sMbeqyw2jJrFotiiNBIwYmGacNquJVa8tmEFL31Xcb40CblULDgYIGCUjAjZaciml7KXBUo2mKHauZsygszXYOpNPb3vKzY7iKKKcYk4vMZ4O1hCkHIHbriiNx5FPozICwDSUrBDrlv3dQP6YP21Lta2r195eLHQdIQt(ixHBHrDbY3aNQ8UowiaNMlyXTSZq2bfSseWeTKHKqyw2jdxEeAdk5AY0TnsGDKbZjkdLiGp4KYIfxEeAdkPixHBHrIa(GtQkVRJfcWP5cwCl7mKvTyBp0Tv(k)l19dY5rBL31Xcb4eoiNhTm8Mrh3k(zieEHaH1S9SuYVNLESzvIpRocSGSyXxAQXgIcsvN0RoxhleuhFXbov5fFVhTqK4)3gPL4ZxCGfYj(egtanHfYjSwkHCIpb8bNuczeFnAdcTU4tacLvsk2gYeqtJBL6ESoPQJ56YTUrFotdURiZK3rijPUDDmx3B1LBDkyK0qGMabYdszMCVHmJocKIvZ0cYwhZ1LBDUowiiPHanbcKhKYm5EdLwGzY3STrDwSu3SZ5gePBDuwYeBdv3t1LvRsnUvQ7vX31XcbIVgc0eiqEqkZK7nKiewZMqoXNa(GtkHmIVgTbHwx8Z4O1hCkn4UImtEhHKyWsa66yUoneYvqwbPbfSseWeTKHKq4u3UoMRlJJwFWP0iiJgcuBSqG476yHaXFWHqLbonrlzia1irecRFVqoX31XcbIF2UJuRdmWPXLhHGrR4taFWjLqgriS2QfYj(eWhCsjKr81Oni06Ip2M4Ct4OSuGtdURiZK3rij19iJ6yRolwQd5RYqziqKCLcNwqDpw3d8CDmxxU1n6ZzYvic48fqguh3M62IVRJfce)ju3XKY4YJqBqMb5nIqy97eYj(eWhCsjKr81Oni06Ip2M4Ct4OSuGtdURiZK3rij19iJ6yRolwQd5RYqziqKCLcNwqDpw3d8S476yHaX3UJ2PKfK1m4ooeHW6hqiN4taFWjLqgXxJ2GqRl(J(CMqKMjoHXMjePPu3UolwQB0NZeI0mXjm2mHinz0WoiiuchUMP6EQoPEw8DDSqG4hTKPdgWoqzMqKMeHWAPNqoX31XcbIpATT5KzbgSTRjXNa(GtkHmIqyTvjKt8jGp4KsiJ4RrBqO1f)rFot8DsdoeQs4W1mv3t19EX31XcbIpRqexLHwGbryiWbAsecRLFc5eFc4doPeYi(A0geADXNaekRK6EQoR(DIVRJfce)gQbIKyGtdVRxLrHiVblcri(kA6DEiKtyTuc5eFc4doPeYi(A0geADXp36Wb58OLujemBNeFxhlei(mTAMeHWA2eYj(Uowiq8Xb58Ov8jGp4KsiJiew)EHCIpb8bNuczeFOT4JPq8DDSqG4NXrRp4K4NX5Ds8rXWm6ZjUUNQJT6yUU3QB0NZeh6kszuRMsD76SyPUCRB0NZuwKduMgItuQBxhZ1LBDJ(CMq9OLtySXgr6fVqqQBx3RIFghzaEdj(OyyqecY5IqyTvlKt8jGp4KsiJ4dTfFmfIVRJfce)moA9bNe)moVtIpkgMrFoX19uDSvhZ19wDJ(CM4qxrkJA1uQBxNfl1n6Zzc1JwoHXgBePx8cbje14lax3tmQtdHCfKvqAqbRebmrlzijeoHOgFb46Ev81Oni06IVlpcTbLuKRWTWiraFWjvDwSuNlpcTbLCnz62gjWoYG5eLHseWhCsj(zCKb4nK4JIHbriiNlcH1VtiN4taFWjLqgXhAl(ykeFxhlei(zC06doj(zCENeFummJ(CIR7P6yt81Oni06IVlpcTbLWaNjYqsiCc5aMQ7rg1XM4NXrgG3qIpkggeHGCUiew)ac5eFc4doPeYi(qBXhrykeFxhlei(zC06doj(zCKb4nK4JIHbriiNl(A0geADX3LhH2GsyGZezijeoHCat19iJ6yRoMRB0NZeg4mrgscHt4W1mv3JmQJT6YrDJ(CMgiORWRIsDBriSw6jKt8jGp4KsiJ4dTfFmfIVRJfce)moA9bNe)moVtIpkgMrFoX1LJ6g95mHzQZ5ghOmAeeJhqaHtD76EQo2QJ56ERUrFotCORiLrTAk1TRZIL6YTUrFotzroqzAiorPUDDmxxU1n6Zzc1JwoHXgBePx8cbPUDDmxxU1n6ZzAGGUcVkk1TR7vXxJ2GqRl(J(CMgCxrMjVJqssDBXpJJmaVHeFummicb5CriS2QeYj(eWhCsjKr8H2IpMcX31XcbIFghT(GtIFgN3jXxdBgqJnCbboPO5Q3OUhzuhB1XEDSvN0UU3QlCobIu2wio4sm4aTmrjc4doPQJ560qixbzfKY2cXbxIbhOLjkHOgFb46EQoPQ716yVUrFotde0v4vrPUDDmxhbiuwj19yDpWZ1XCD5w3OpNjmtDo34aLrJGy8aciCQBxhZ1LBDJ(CMyIiBJeyhzyDdSXhWEyKa7PUT4NXrgG3qIV3m64wJgcuBSqGiewl)eYj(eWhCsjKr8H2IpMcX31XcbIFghT(GtIFgN3jXF0NZeQhTCcJn2isV4fcsD76SyPU3QZLhH2GskYv4wyKiGp4KQolwQZLhH2GsUMmDBJeyhzWCIYqjc4doPQ716yUUrFotiiNBIwYmGacN62IFghzaEdj(JGmAiqTXcbIqyTuplKt8jGp4KsiJ4dTfFmfIVRJfce)moA9bNe)moVtIp2M4Ct4OSuGtdURiZK3rij19uDSvhZ1H8vzOmeisUsHtlOUhRJTNRZIL6g95mn4UImtEhHKK62IFghzaEdj(dURiZK3rijgSeGwecRLskHCIpb8bNuczeFnAdcTU4JdY5rlPsoNl(Uowiq81oNBCDSqGHV4q85lomaVHeFCqopAfHWAPytiN4taFWjLqgX31XcbIV25CJRJfcm8fhIpFXHb4nK4RvyriSwQ3lKt8jGp4KsiJ4RrBqO1fFnSzan2Wfe46EKrDABtJBfd2MaQ6YrDVv3OpNPbc6k8QOu3Uo2RB0NZe02gIIoydjPUDDVwN0UU3QlCobIuoVVAMmkKZAIa(GtQ6yUU3Ql36cNtGi14iMiLzcrgf5rBIa(GtQ6SyPoneYvqwbPghXePmtiYOipAtiQXxaUUhRtQ6ETUxfFxhlei(OoW46yHadFXH4ZxCyaEdj(ZfS4wriSwkRwiN4taFWjLqgX31XcbIV25CJRJfcm8fhIpFXHb4nK4p6lxjcH1s9oHCIpb8bNuczeFnAdcTU4tacLvssrZvVrDpYOoPExDSxhbiuwjjeLLaIVRJfceFhPDazcicrGqecRL6beYj(Uowiq8DK2bKXUZXK4taFWjLqgriSwkPNqoX31XcbIpFZ2gyJ8)UkBdbcXNa(GtkHmIqeIVnI0WMHhc5ewlLqoX31XcbIVnmwiq8jGp4KsiJiewZMqoXNa(GtkHmIVRJfce)ghXePmtiYOipAfFnAdcTU4J8vzOmeisUsHtlOUhRZQFw8TrKg2m8WGjneOWI)7eHW63lKt8jGp4KsiJ4RrBqO1f)3Ql36OCEFTTjvYgQzIc8kpsz0Wg7E4XcbgfLz1uDwSuxU1PHqUcYkiPLO5WabbR2m4oosQoYJfcQZIL6q(QmugcePfKPZbeYhCkrwzXbUUxfFxhlei(4GCE0kcH1wTqoXNa(GtkHmIVRJfceFeKZnrlzgqaHfFBePHndpmysdbkS4ZMiew)oHCIpb8bNuczeFxhlei(y(QjJdug1QjX3grAyZWddM0qGcl(SjcH1pGqoXNa(GtkHmIVRJfceFxHiGZxazqDCR4RrBqO1f)3Ql36OCEFTTjvYgQzIc8kpsz0Wg7E4XcbgfLz1uDwSuxU1PHqUcYkiPLO5WabbR2m4oosQoYJfcQZIL6q(QmugcePfKPZbeYhCkrwzXbUUxfFBePHndpmysdbkS4lLiewl9eYj(eWhCsjKr8bEdj(U8WToYXMjeeg40ydzLqIVRJfceFxE4wh5yZeccdCASHSsiriS2QeYj(eWhCsjKr8DDSqG4RLO5WabbR2m4ooeFnAdcTU4NBDiFvgkdbI0cY05ac5doLiRS4al(0Cs6Wa8gs81s0CyGGGvBgChhIqeI)CblUviNWAPeYj(eWhCsjKr81Oni06IFghT(GtPrqgneO2yHaX31XcbI)GcwjcyIwYqsiSiewZMqoXNa(GtkHmIVgTbHwx8h95mH5RMmoqzuRMsiQXxaUUNQl2gYeqJAP6yUUrFoty(QjJdug1QPeIA8fGR7P6ERoPQJ960WMb0ydxqGR716K21jvYQeFxhlei(y(QjJdug1QjriS(9c5eFc4doPeYi(A0geADXF0NZecY5MOLmdiGWje14lax3tmQ79IVRJfceFeKZnrlzgqaHfHWARwiN4taFWjLqgXxJ2GqRl(VvNRJndzia1SeUog1jvDwSu3OpNPb3vKzY7iKKKcYkOUxRJ56Y4O1hCkHIHbriiNl(Uowiq8rqo3eTKzabewecRFNqoXNa(GtkHmIVgTbHwx8D5rOnOKRjt32ib2rgmNOmuIa(GtQ6SyPoxEeAdkPixHBHrIa(GtkX31XcbI)GcwjcyIwYqsiSiew)ac5eFxhlei(QfB7HUv8jGp4KsiJieH4JdY5rRqoH1sjKt8DDSqG47nJoUv8jGp4KsiJieH4RvyHCcRLsiN4taFWjLqgXxJ2GqRl(5whoiNhTKk5CU476yHaXx7CUX1Xcbg(IdXNV4Wa8gs8jmMaAclcH1SjKt8jGp4KsiJ4RrBqO1f)CRB0NZKRqeW5lGmOoUn1TRJ56iaHYkjfBdzcOPXTsDpwNu1XCDVvxU1r58(ABtQKlpCRJCSzcbHbon2qwjuDwSuNgc5kiRGe3dceghPDGNquJVaCDpwhBpx3RIVRJfceFxHiGZxazqDCRiew)EHCIpb8bNuczeFxhlei(noIjszMqKrrE0k(A0geADXh5RYqziqKCLcN621XCDVvx4OSuKITHmb0OwQUNQtdBgqJnCbboPO5Q3OolwQl36Wb58OLujemBNQJ560WMb0ydxqGtkAU6nQ7rg1PTnnUvmyBcOQlh1jvDVk(AjAozchLLcSWAPeHWARwiN4taFWjLqgXxJ2GqRl(iFvgkdbIKRu40cQ7X6E)Z1LJ6q(QmugcejxPWjvh5Xcb1XCD5whoiNhTKkHGz7uDmxNg2mGgB4ccCsrZvVrDpYOoTTPXTIbBtavD5OoPeFxhlei(noIjszMqKrrE0kcH1VtiN4taFWjLqgXxJ2GqRl(yBIZnHJYsbUUhzuhB1XCD5w3OpNPb3vKzY7iKKu3UoMR7T6YToKVkdLHarYvkCISYIdCDwSuhYxLHYqGi5kfoHOgFb46ESoRQolwQd5RYqziqKCLcNwqDpw3B1XwD5OoneYvqwbPb3vKzY7iKKKU1rzjSzICDSqGZR716K21X27Q7vX31XcbI)G7kYm5DesIiew)ac5eFc4doPeYi(A0geADXpJJwFWP0G7kYm5DesIblbORJ560WMb0ydxqGtkAU6nQ7rg1jvDSx3OpNPbc6k8QOu3w8DDSqG4NTfIdUedoqltKiewl9eYj(eWhCsjKr81Oni06IFghT(GtPb3vKzY7iKedwcqxhZ19wDeGqzLKITHmb004wPUhR7D1zXsDeGqzLu3t1j17Q7vX31XcbIptlNVGSgSnIiriS2QeYj(eWhCsjKr81Oni06IFghT(GtPb3vKzY7iKedwcqxhZ1racLvsk2gYeqtJBL6ESoPeFxhlei(dURidQJBfHWA5NqoXNa(GtkHmIVgTbHwx8ZToCqopAjvY586yUUmoA9bNsEZOJBnAiqTXcbIVRJfce)moyXTIqyTuplKt8jGp4KsiJ4RrBqO1f)CRdhKZJwsLCoVoMRlJJwFWPK3m64wJgcuBSqG476yHaXh36kiRnexjcH1sjLqoXNa(GtkHmIVgTbHwx8h95mn4qOI3XrcrUoQZIL6g95m5kebC(cidQJBtDBX31XcbIVnmwiqecRLInHCIpb8bNuczeFxhlei(zC06dozwqqa8gsmz3SEgipmqSE5CpwqwdICDarIVgTbHwx8h95mn4qOI3XrcrUoQZIL6ITHmb0OwQUNyuhBpxNfl1PHndOXgUGaNu0C1Bu3tmQJnXh4nK4NXrRp4KzbbbWBiXKDZ6zG8WaX6LZ9ybzniY1bejcH1s9EHCIpb8bNuczeFnAdcTU4p6ZzAWHqfVJJeICDuNfl1fBdzcOrTuDpXOo2EUolwQtdBgqJnCbboPO5Q3OUNyuhBIVRJfce)oMmBqnyriSwkRwiN476yHaXFWHqLz2rseFc4doPeYicH1s9oHCIVRJfce)bHWeIPfKv8jGp4KsiJiewl1diKt8DDSqG4pxen4qOs8jGp4KsiJiewlL0tiN476yHaX3bAchiNB0oNl(eWhCsjKrecRLYQeYj(eWhCsjKr8DDSqG4RLO5WabbR2m4ooeFnAdcTU4NBD4GCE0sQKZ51XCDJ(CMCfIaoFbKb1XTjfKvqDmx3OpNPgQbIKyGtdVRxLrHiVbNuqwb1XCDeGqzLKITHmb004wPUhRZQRJ56qXWm6ZjUUNQ7DIpnNKomaVHeFTenhgiiy1Mb3XHiewlL8tiN4taFWjLqgX31XcbIVlpCRJCSzcbHbon2qwjK4RrBqO1f)CRB0NZKRqeW5lGmOoUn1TRJ56YTUrFotdURiZK3rijPUDDmxNgc5kiRGKRqeW5lGmOoUnHOgFb46EQoPEN4d8gs8D5HBDKJntiimWPXgYkHeHWA2EwiN4taFWjLqgX31XcbIVJBZ4acBqU8GiJgICU4RrBqO1fFfn6Zzc5YdImAiY5gfn6ZzsbzfuNfl1POrFotAiq11XMHmlGjJIg95m1TRJ56chLLIul58OnzRJ6EQU3ZwDmxx4OSuKAjNhTjBDu3JmQ79pxNfl1LBDkA0NZKgcuDDSziZcyYOOrFotD76yUU3QtrJ(CMqU8GiJgICUrrJ(CMWHRzQUhzuhBpxxoQtQNRtAxNIg95mn4qOYaNMOLmeGAKK621zXsDHJYsrk2gYeqJAP6EQUh456EToMRB0NZKRqeW5lGmOoUnHOgFb46ESoPSkXh4nK4742moGWgKlpiYOHiNlcH1SjLqoXNa(GtkHmIVgTbHwx8h95mn4qOI3XrcrUoQZIL6ITHmb0OwQUNyuhBpxNfl1PHndOXgUGaNu0C1Bu3tmQJnX31XcbIFhtMnOgSieH4p6lxjKtyTuc5eFc4doPeYi(A0geADXF0NZe02gIIoydjPUDDmx3B1n6ZzIjISnsGDKH1nWgFa7HrcSNWHRzQUNQtQNRZIL6g95mPixHBHrQBxNfl1racLvsDpvNv)U6Ev8DDSqG4BV4aYn4wyicH1SjKt8DDSqG4JxWIdczWbAzIeFc4doPeYicricricHaa]] )


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