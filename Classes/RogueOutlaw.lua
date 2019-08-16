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


    spec:RegisterPack( "Outlaw", 20190816, [[da1dhbqivbpsvuBcL4tefyuOioLQKwfrH8kuQMfkPBjQWUe5xeLggkshdf1YisEgrLmnIkCnrLABev03evKgNQeCoIkvRtvcnpvrUhkSpvHoOOsSqIupKOqnrkj5IIkkBKOG(iLKkDsvjkRuu1lvLOAMusk4MQse7KsQFQkrAOevkhLssHwQOs6PQQPsu1vfvuTvkjL6RusQASusk5SuskAVe(lfdwLdt1Iv4XKAYKCzKnROplknAP0PvA1usQ41QsnBuDBPy3a)g0WPuhxurSCiphQPlCDPA7IIVJsz8usCEIy9efnFkX(LSGzH8IVYdsyTumLz5otFbMLZeZ5wkMLJCQ4hsSjX321V9SK4d8gs8FP9G7Sj(2Ueo0vc5fFmSJ0K43gHn(fLv2SB02hjnSrw8205ESqGg5Zqw82OLv8h9LhVmGyi(kpiH1sXuML7m9fywotmNBPywoKlXhBtAH1sjNmv8BxLIaIH4RiSw8FUUxAp4oB1LRWSDQY)CDTryJFrzLn7gT9rsdBKfVnDUhleOr(mKfVnAzR8pxxU0Z2XrDmlNSwNumLz5ED5OoMZ9lYCUR8v(NRtg36GSe(fR8pxxoQlxuksv3lF1VRlG1POP35rDUowiOo(IJuL)56YrD5IsrQ6SrKg2m8OoP5UIQtgY7iKK6yIcsyGmiQBGi)DD)GCE0(AQY)CD5OoRccKbrDDmvxGwWBkW1TG6Wb58Onv5FUUCuNvbbYGOUoMQRzbVOvR6MquDVeh9Mu1nHO6SkYJ26yYgYaCDayuhUBBdrbPEnv5FUUCuxUKbUQ6qecY5liBD5AiDDQoAbzRtAURO6KH8ocjPoM0bCcJRJnQoiGlPUwpdvhZ1foklfVMQ8pxxoQlxjUBL6E5lNVGS19TreLQ8pxxoQlNJP6ITHmb0OwQUjevhb0WoiiuDeqTGS1H8OLq1fToOUWrzPifBdzcOrTus8TrW5YjX)56EP9G7SvxUcZ2Pk)Z11gHn(fLv2SB02hjnSrw8205ESqGg5Zqw82OLTY)CD5spBhh1XSCYADsXuML71LJ6yo3ViZ5UYx5FUozCRdYs4xSY)CD5OUCrPivDV8v)UUawNIMENh156yHG64losv(NRlh1LlkfPQZgrAyZWJ6KM7kQoziVJqsQJjkiHbYGOUbI8319dY5r7RPk)Z1LJ6Skiqge11XuDbAbVPax3cQdhKZJ2uL)56YrDwfeidI66yQUMf8IwTQBcr19sC0Bsv3eIQZQipARJjBidW1bGrD4UTnefK61uL)56YrD5sg4QQdriiNVGS1LRH01P6OfKToP5UIQtgY7iKK6yshWjmUo2O6GaUK6A9muDmxx4OSu8AQY)CD5OUCL4UvQ7LVC(cYw33gruQY)CD5OUCoMQl2gYeqJAP6MquDeqd7GGq1ra1cYwhYJwcvx06G6chLLIuSnKjGg1sPkFL)56YzwH09Gu1nOjer1PHndpQBqzxaovxUO1KDGRdab5O1rnZoVoxhleGRdc4ssv(NRZ1Xcb4KnI0WMHhmMCh)UY)CDUowiaNSrKg2m8GDgY69Snei8yHGk)Z156yHaCYgrAyZWd2zi7ecvv(NR7dCBClmQd5RQUrFojvD4WdCDdAcruDAyZWJ6gu2fGRZbQ6SruoSHrSGS1T46uqaLQ8pxNRJfcWjBePHndpyNHSyGBJBHHbhEGR8UowiaNSrKg2m8GDgYAdJfcQ8UowiaNSrKg2m8GDgY24O3KYmHiJI8OLvBePHndpmysdbkmJCZ6ozG8vzOmeisUsHtl4r5GPvExhleGt2isdBgEWodzXb58OL1DYGjpq5K(ABtQKnu)Mc8ktsz0Wg7E4XcbgfLz1KflpOHqUcYgiPLO5WabbR2m4oosQoYJfcSyb5RYqziqKwqMohqiFWPezLfh4xR8UowiaNSrKg2m8GDgYIGCUjAjZacimR2isdBgEyWKgcuygsv5DDSqaozJinSz4b7mKfZxnzCGYOwnXQnI0WMHhgmPHafMHuvExhleGt2isdBgEWodzDfIaoFbKb1XTSAJinSz4HbtAiqHzWmR7KbtEGYj912MujBO(nf4vMKYOHn29WJfcmkkZQjlwEqdHCfKnqslrZHbccwTzWDCKuDKhleyXcYxLHYqGiTGmDoGq(GtjYkloWVw5DDSqaozJinSz4b7mKTJjZgudRaVHy4Ye36ihBMqqyGtJnKncv5DDSqaozJinSz4b7mKTJjZgudR0Cs6Wa8gIHwIMddeeSAZG74G1DY4bKVkdLHarAbz6CaH8bNsKvwCGR8v(NRlNzfs3dsvhLHqsQl2gQUOLQZ1bev3IRZZ4l3hCkv5FUUCLWb58OTUDwNneJ3bNQJjayDz6CaH8bNQJauZs46wqDAyZWJxR8UowiaZ49QFZ6oz8aoiNhTKkHGz7uL31Xcbyg4GCE0w5FUUCLqqoVUjevNuSx3OpN46yBJ26SAa6ksvNvTAQUUDQUxA0si2wmvhIqqoVUjevNuSxhevNvxKdu19sior1br1LR9OLtyCDYnePx8cbPkVRJfcWSZq2moA9bNyf4nedummicb5CwZ48oXafdZOpN4NKIfMm6ZzIdDfPmQvtPUTflpm6ZzklYbktdXjk1Tz5HrFotOE0Yjm2yJi9Ixii1TFTY)CD5kHGCEDtiQoPyVUrFoX1br1LR9OLtyCDYnePx8cb1X2gT1zvKRWTWOoiQUCrt11TRtcSJQ7ZjkdLQ8UowiaZodzZ4O1hCIvG3qmqXWGieKZzfAZatbR7KHltcTbLuKRWTWiraFWjLflUmj0guY1KPBBKa7idMtugkraFWjfRzCENyGIHz0Nt8tsXctg95mXHUIug1QPu32ILrFotOE0Yjm2yJi9IxiiHOgFb4NyOHqUcYginOGnIaMOLmKecNquJVa8Rv(NRtk2R7d83uD5mje(fRlx4S5sW1HieKZRBcr1jf71n6Zjov5DDSqaMDgYMXrRp4eRaVHyGIHbriiNZk0MbMcw3jdxMeAdkHb(BYqsiCc5G3pYqkwZ48oXafdZOpN4NKQY)CDsXEDFG)MQlNjHWVyDwfSoamQdriiNxhBB0wNuSxhoC9BCDWzDrlv3h4VP6YzsiCDJ(CwhtyM96WHRFxhBB0wN0iORWRIQRB)AQY76yHam7mKnJJwFWjwbEdXafddIqqoNvOndeHPG1DYWLjH2GsyG)MmKecNqo49JmKILrFotyG)MmKecNWHRF)idPYXOpNPbc6k8QOu3UY)CDw9B0wN0Cxr1jd5DessDDBwRBZcGiQouNt468bmdvNdu1f(BQokdHKeTliBDrRh1T46KI96ycag1PHDqSGS19Dz8R1br1HxqwovN0FwRZQ7lH16Yv5wL31Xcby2ziBghT(GtSc8gIbkggeHGCoRqBgykyDNmg95mn4UImtEhHKK62SMX5DIbkgMrFoX5y0NZe(DNZnoqz0iigpGacN62pjflmz0NZeh6kszuRMsDBlwEy0NZuwKduMgItuQBZYdJ(CMq9OLtySXgr6fVqqQBZYdJ(CMgiORWRIsD7xR8UowiaZodzZ4O1hCIvG3qm8Mrh3A0qGAJfcynJZ7ednSzan2Wfe4KIMREJhzif7sjJys4CcePSTqCWLyWbAFtjc4doPyrdHCfKnqkBlehCjgCG23ucrn(cWpX8RSp6ZzAGGUcVkk1TzHaekRKhLtMYYdJ(CMWV7CUXbkJgbX4beq4u3MLhg95m9MiBJeyhzyBdSXhWEyKa7PUDL31Xcby2ziBghT(GtSc8gIXiiJgcuBSqaRzCENym6Zzc1JwoHXgBePx8cbPUTflmXLjH2GskYv4wyKiGp4KYIfxMeAdk5AY0TnsGDKbZjkdLiGp4K6vwg95mHGCUjAjZaciCQBx5FUoR(nARRPZJ1Mt1foklfywRlAxCDzC06dov3IRt3s63KQUawNI0RIQJTwkAjuDyydvNm2QW1HBHDUQUbvhwcqtQ6yBJ26KM7kQoziVJqsQ8UowiaZodzZ4O1hCIvG3qmgCxrMjVJqsmyjanRzCENyGTjo3eoklf40G7kYm5DesYtsXcYxLHYqGi5kfoTGhLIPwSm6ZzAWDfzM8ocjj1TR8UowiaZodz1oNBCDSqGHV4GvG3qmWb58OL1DYahKZJwsLCoVY76yHam7mKv7CUX1Xcbg(IdwbEdXqRWv(NRtgUGf3wNh114wzB6n1jJLBP6(9boqUoQdcO6MquDKRBRtAe0v4vr15avDVuBBik6GnKuhBTeOoRg7R(DDwfYzRUfxhM4KoivDoqv3lzAv1T46aWOoe5kj15ZGq1fTuDaYkrDysdbQuL31Xcby2zilQdmUowiWWxCWkWBigZfS4ww3jdnSzan2Wfe4hzOTnnUvmyBcOYbtg95mnqqxHxfL62Sp6ZzcABdrrhSHKu3(vzetcNtGiLt6R(TrHC2seWhCsXctEiCobIuJJEtkZeImkYJ2eb8bNuwSOHqUcYgi14O3KYmHiJI8OnHOgFb4hz(1xR8UowiaZodz1oNBCDSqGHV4GvG3qmg9LRQ8UowiaZodzDK2bKjGiebcw3jdcqOSsskAU6nEKbZ5MDcqOSssiklbQ8UowiaZodzDK2bKXUZXuL31Xcby2zilFZ2gyJvNUkBdbIkFL)56KUVCfHWv(NRlNJP6KBloG86(TWOUDw3g1XgeidI60UDDAyZawNnCbbUohOQlAP6EP22WOd2qsDJ(Cw3IRRBNQlxYaxvDD8cYwhBTeOUxor21z1e2r1z1VbUoC46346Cevx7MTTUoGtyCDrlvNvrUc3cJ6g95SUfxNZXW662PkVRJfcWPrF5kg2loGCdUfgSUtgJ(CMG22qu0bBij1TzHjJ(CMEtKTrcSJmSTb24dypmsG9eoC97NywoSyz0NZKICfUfgPUTfleGqzL8KCK7xR8UowiaNg9LRyNHS4fS4GqgCG23uLVY)CDYyiKRGSbWvExhleGtAfMH25CJRJfcm8fhSc8gIbHXeqtyw3jJhWb58OLujNZR8UowiaN0km7mK1vic48fqguh3Y6oz8WOpNjxHiGZxazqDCBQBZcbiuwjPyBitannUvEKzwyYduoPV22Kk5Ye36ihBMqqyGtJnKnczXIgc5kiBGe3dceghPDGNquJVa8JsX0xR8px3lBwNRu46Cevx3M16WG1MQlAP6GaQo22OTooKnch1jV8wvQUCoMQJTwcuNsYcYw30XbHQlADqDYy5wDkAU6nQdIQJTnAH9OohiPozSClv5DDSqaoPvy2ziBJJEtkZeImkYJww1s0CYeoklfygmZ6ozG8vzOmeisUsHtDBwys4OSuKITHmb0Ow6jnSzan2Wfe4KIMREdlwEahKZJwsLqWSDIfnSzan2Wfe4KIMREJhzOTnnUvmyBcOYbZVw5FUUx2SoaSoxPW1X2Y51PwQo22ODb1fTuDaYkrDYftXSwxht19sMwvDqqDdigxhBB0c7rDoqsDYy5wQY76yHaCsRWSZq2gh9MuMjezuKhTSUtgiFvgkdbIKRu40cEuUyAoq(QmugcejxPWjvh5XcbS8aoiNhTKkHGz7elAyZaASHliWjfnx9gpYqBBACRyW2eqLdMR8pxN0Cxr1jd5DessDqqDsXEDeGAwcNQZQFJ26CLc)I1LZXuD7SUOLKuhoCj1nHO6Eb2RdtAiqHRdIQBN1jb2r1biRe1PBDuwQo2woVUbvhICLK6wqDX2q1nHO6IwQoazLOo28muQY76yHaCsRWSZq2b3vKzY7iKew3jdSnX5MWrzPa)idPy5HrFotdURiZK3rijPUnlm5bKVkdLHarYvkCISYIdSfliFvgkdbIKRu4eIA8fGF8fSyb5RYqziqKCLcNwWJmrQCOHqUcYgin4UImtEhHKK0ToklHntKRJfcC(RYiPY9RvExhleGtAfMDgYMTfIdUedoq7BI1DYiJJwFWP0G7kYm5DesIblbOzrdBgqJnCbboPO5Q34rgmZ(OpNPbc6k8QOu3UY76yHaCsRWSZq23lNVGSgSnIiw3jJmoA9bNsdURiZK3rijgSeGMfMqacLvsk2gYeqtJBLhZTfleGqzL8eZ5(1kVRJfcWjTcZodzhCxrguh3Y6ozKXrRp4uAWDfzM8ocjXGLa0SqacLvsk2gYeqtJBLhzUY)CD5C8cYwNvBhS4wzZLMrh3w3IRdc4sQZRldHKuxSaj1TanICmXADyyDlOoe58nKWADsGDzaIQZhyiVhexsDZfq1fW66yQUnQZX1511JLVHK6W2eNNQ8UowiaN0km7mKnJdwClR7KXd4GCE0sQKZ5SKXrRp4uYBgDCRrdbQnwiOY76yHaCsRWSZqwCRRGS1qCfR7KXd4GCE0sQKZ5SKXrRp4uYBgDCRrdbQnwiOY76yHaCsRWSZqwBySqaR7KXOpNPbhcv8oosiY1HflJ(CMCfIaoFbKb1XTPUDL)56KHoNVGS1nC976cyDkA6DEu3gutDDSNLQ8UowiaN0km7mKTJjZgudRaVHyKXrRp4KzbbbWBiXKDZ6zG8WaX6LZ9ybzniY1beX6ozm6ZzAWHqfVJJeICDyXsSnKjGg1spXqkMAXIg2mGgB4ccCsrZvVXtmKQY76yHaCsRWSZq2oMmBqnyw3jJrFotdoeQ4DCKqKRdlwITHmb0Ow6jgsXulw0WMb0ydxqGtkAU6nEIHuvExhleGtAfMDgYo4qOYm7ijvExhleGtAfMDgYoieMqVxq2kVRJfcWjTcZodzNlIgCiuv5DDSqaoPvy2ziRd0eoqo3ODoVY76yHaCsRWSZq2oMmBqnSsZjPddWBigAjAomqqWQndUJdw3jJhWb58OLujNZzz0NZKRqeW5lGmOoUnPGSbyz0NZud1arsmWPH31RYOqK3GtkiBawiaHYkjfBdzcOPXTYJYblOyyg95e)uUR8UowiaN0km7mKTJjZgudRaVHy4Ye36ihBMqqyGtJnKncX6oz8WOpNjxHiGZxazqDCBQBZYdJ(CMgCxrMjVJqssDBw0qixbzdKCfIaoFbKb1XTje14la)eZ5UY)CDwTjKK6qWE2wUK6qDovhCwx02Bg7CjvDnE0IRBqCiBVyD5Cmv3eIQ7LbEBdv1PrBWADWOLqSTyQo22OTUCjxRZJ6KIPSxhoC9BCDquDmZu2RJTnARZ5yyDsZHqvDD7uL31Xcb4KwHzNHSDmz2GAyf4nedh3MXbe2GCzcrgne5Cw3jdfn6Zzc5YeImAiY5gfn6ZzsbzdyXIIg95mPHavxhBgYSG3gfn6ZzQBZs4OSuKAjNhTjBD8KCjflHJYsrQLCE0MS1XJmKlMAXYdkA0NZKgcuDDSziZcEBu0OpNPUnlmrrJ(CMqUmHiJgICUrrJ(CMWHRF)idPyAoyMPYifn6ZzAWHqLbonrlzia1ij1TTyjCuwksX2qMaAul9KCY0xzz0NZKRqeW5lGmOoUnHOgFb4hz(fQ8pxNvrtVZJ6MoNpC976MquDDSp4uDBqn4uL31Xcb4KwHzNHSDmz2GAWSUtgJ(CMgCiuX74iHixhwSeBdzcOrT0tmKIPwSOHndOXgUGaNu0C1B8edPQ8v(NRlNHXeqt4kVRJfcWjcJjGMWm0qGMabYdszMCVHyDNmiaHYkjfBdzcOPXTYJmZYdJ(CMgCxrMjVJqssDBwyYdkyK0qGMabYdszMCVHmJocKIv)Ebzz5bxhleK0qGMabYdszMCVHslWm5B22WILzNZnis36OSKj2g6PSAvQXTYRvExhleGtegtanHzNHSdoeQmWPjAjdbOgjSUtgzC06doLgCxrMjVJqsmyjanlAiKRGSbsdkyJiGjAjdjHWPUnlzC06doLgbz0qGAJfcQ8UowiaNimMaAcZodzZ2DKADGbonUmjemAR8UowiaNimMaAcZodzNqDhtkJltcTbzgK3W6ozGTjo3eoklf40G7kYm5DesYJmKYIfKVkdLHarYvkCAbpkNmLLhg95m5kebC(cidQJBtD7kVRJfcWjcJjGMWSZqw7oANswqwZG74G1DYaBtCUjCuwkWPb3vKzY7iKKhziLfliFvgkdbIKRu40cEuozAL31Xcb4eHXeqty2ziB0sMoya7aLzcrAI1DYy0NZeI0V5egBMqKMsDBlwg95mHi9BoHXMjePjJg2bbHs4W1VFIzMw5DDSqaorymb0eMDgYIwBBozwGbB7AQY76yHaCIWycOjm7mKLniIRYqlWGime4anX6ozm6ZzIVtAWHqvchU(9tYvL31Xcb4eHXeqty2ziBd1arsmWPH31RYOqK3GzDNmiaHYk5j5i3v(k)Z1jdxWIBjeUY)CDsh5S6GziuD5AiDDicb5CCDSTrBDwf5kClmKnx0uDbY3axhevxU2JwoHX1j3qKEXleKQ8UowiaNMlyXTmguWgrat0sgscHzDNmY4O1hCkncYOHa1gleu5DDSqaonxWIBzNHSy(QjJdug1Qjw3jJrFoty(QjJdug1QPeIA8fGFk2gYeqJAjwg95mH5RMmoqzuRMsiQXxa(jMWm7AyZaASHliWVkJyo9cvExhleGtZfS4w2zilcY5MOLmdiGWSUtgJ(CMqqo3eTKzabeoHOgFb4NyixwSKXrRp4ucfddIqqoVY)CDsh5S6yBJ26IwQUCrt1LZTRZQjSJQ7ZjkdvhevNvrUc3cJ6cKVbov5DDSqaonxWIBzNHSdkyJiGjAjdjHWSUtgUmj0guY1KPBBKa7idMtugkraFWjLflUmj0gusrUc3cJeb8bNuvExhleGtZfS4w2ziRAX2EOBR8v(NR7hKZJ2kVRJfcWjCqopAz4nJoUv8Zqi8cbcRLIPml3z6lWmZIpBocSGSyX)L1ydrbPQlNwNRJfcQJV4aNQ8IV3Jwis8)BJmw85loWc5fFcJjGMWc5fwZSqEXNa(GtkH0IVgTbHwx8jaHYkjfBdzcOPXTsDpwhZ1XsDpu3OpNPb3vKzY7iKKu3UowQJj19qDkyK0qGMabYdszMCVHmJocKIv)EbzRJL6EOoxhleK0qGMabYdszMCVHslWm5B22OolwQB25CdI0ToklzITHQ7P6YQvPg3k19Q476yHaXxdbAceipiLzY9gsecRLsiV4taFWjLqAXxJ2GqRl(zC06doLgCxrMjVJqsmyjaDDSuNgc5kiBG0Gc2icyIwYqsiCQBxhl1LXrRp4uAeKrdbQnwiq8DDSqG4p4qOYaNMOLmeGAKicH1YLqEX31XcbIF2UJuRdmWPXLjHGrR4taFWjLqAriSwoeYl(eWhCsjKw81Oni06Ip2M4Ct4OSuGtdURiZK3rij19iJ6KQolwQd5RYqziqKCLcNwqDpwNCY06yPUhQB0NZKRqeW5lGmOoUn1TfFxhlei(tOUJjLXLjH2GmdYBeHW6ClKx8jGp4KsiT4RrBqO1fFSnX5MWrzPaNgCxrMjVJqsQ7rg1jvDwSuhYxLHYqGi5kfoTG6ESo5KPIVRJfceF7oANswqwZG74qecRLtH8Ipb8bNucPfFnAdcTU4p6Zzcr63CcJntistPUDDwSu3OpNjePFZjm2mHinz0WoiiuchU(DDpvhZmv8DDSqG4hTKPdgWoqzMqKMeHW6CQqEX31XcbIpATT5KzbgSTRjXNa(GtkH0Iqy9liKx8jGp4KsiT4RrBqO1f)rFot8DsdoeQs4W1VR7P6KlX31XcbIpBqexLHwGbryiWbAsecRL7c5fFc4doPesl(A0geADXNaekRK6EQo5i3IVRJfce)gQbIKyGtdVRxLrHiVblcri(kA6DEiKxynZc5fFc4doPesl(A0geADX)H6Wb58OLujemBNeFxhlei(Vx9BriSwkH8IVRJfceFCqopAfFc4doPeslcH1YLqEXNa(GtkH0Ip0w8Xui(Uowiq8Z4O1hCs8Z48oj(Oyyg95ex3t1jvDSuhtQB0NZeh6kszuRMsD76SyPUhQB0NZuwKduMgItuQBxhl19qDJ(CMq9OLtySXgr6fVqqQBx3RIFghzaEdj(OyyqecY5IqyTCiKx8jGp4KsiT4dTfFmfIVRJfce)moA9bNe)moVtIpkgMrFoX19uDsvhl1XK6g95mXHUIug1QPu3UolwQB0NZeQhTCcJn2isV4fcsiQXxaUUNyuNgc5kiBG0Gc2icyIwYqsiCcrn(cW19Q4RrBqO1fFxMeAdkPixHBHrIa(GtQ6SyPoxMeAdk5AY0TnsGDKbZjkdLiGp4Ks8Z4idWBiXhfddIqqoxecRZTqEXNa(GtkH0Ip0w8Xui(Uowiq8Z4O1hCs8Z48oj(Oyyg95ex3t1jL4RrBqO1fFxMeAdkHb(BYqsiCc5G319iJ6Ks8Z4idWBiXhfddIqqoxecRLtH8Ipb8bNucPfFOT4JimfIVRJfce)moA9bNe)moYa8gs8rXWGieKZfFnAdcTU47YKqBqjmWFtgscHtih8UUhzuNu1XsDJ(CMWa)nzijeoHdx)UUhzuNu1LJ6g95mnqqxHxfL62IqyDoviV4taFWjLqAXhAl(ykeFxhlei(zC06doj(zCENeFummJ(CIRlh1n6Zzc)UZ5ghOmAeeJhqaHtD76EQoPQJL6ysDJ(CM4qxrkJA1uQBxNfl19qDJ(CMYICGY0qCIsD76yPUhQB0NZeQhTCcJn2isV4fcsD76yPUhQB0NZ0abDfEvuQBx3RIVgTbHwx8h95mn4UImtEhHKK62IFghzaEdj(OyyqecY5Iqy9liKx8jGp4KsiT4dTfFmfIVRJfce)moA9bNe)moVtIVg2mGgB4ccCsrZvVrDpYOoPQJ96KQozuDmPUW5eiszBH4GlXGd0(MseWhCsvhl1PHqUcYgiLTfIdUedoq7BkHOgFb46EQoMR716yVUrFotde0v4vrPUDDSuhbiuwj19yDYjtRJL6EOUrFot43Do34aLrJGy8aciCQBxhl19qDJ(CMEtKTrcSJmSTb24dypmsG9u3w8Z4idWBiX3BgDCRrdbQnwiqecRL7c5fFc4doPesl(qBXhtH476yHaXpJJwFWjXpJZ7K4p6Zzc1JwoHXgBePx8cbPUDDwSuhtQZLjH2GskYv4wyKiGp4KQolwQZLjH2GsUMmDBJeyhzWCIYqjc4doPQ716yPUrFotiiNBIwYmGacN62IFghzaEdj(JGmAiqTXcbIqynZmviV4taFWjLqAXhAl(ykeFxhlei(zC06doj(zCENeFSnX5MWrzPaNgCxrMjVJqsQ7P6KQowQd5RYqziqKCLcNwqDpwNumTolwQB0NZ0G7kYm5DessQBl(zCKb4nK4p4UImtEhHKyWsaAriSMzMfYl(eWhCsjKw81Oni06IpoiNhTKk5CU476yHaXx7CUX1Xcbg(IdXNV4Wa8gs8Xb58OvecRzwkH8Ipb8bNucPfFxhlei(ANZnUowiWWxCi(8fhgG3qIVwHfHWAMLlH8Ipb8bNucPfFnAdcTU4RHndOXgUGax3JmQtBBACRyW2eqvxoQJj1n6ZzAGGUcVkk1TRJ96g95mbTTHOOd2qsQBx3R1jJQJj1foNarkN0x9BJc5SLiGp4KQowQJj19qDHZjqKAC0BszMqKrrE0MiGp4KQolwQtdHCfKnqQXrVjLzcrgf5rBcrn(cW19yDmx3R19Q476yHaXh1bgxhley4loeF(IddWBiXFUGf3kcH1mlhc5fFc4doPesl(Uowiq81oNBCDSqGHV4q85lomaVHe)rF5kriSM5ClKx8jGp4KsiT4RrBqO1fFcqOSsskAU6nQ7rg1XCURJ96iaHYkjHOSeq8DDSqG47iTditariceIqynZYPqEX31XcbIVJ0oGm2DoMeFc4doPeslcH1mNtfYl(Uowiq85B22aBS60vzBiqi(eWhCsjKweIq8TrKg2m8qiVWAMfYl(Uowiq8THXcbIpb8bNucPfHWAPeYl(eWhCsjKw8DDSqG434O3KYmHiJI8Ov81Oni06IpYxLHYqGi5kfoTG6ESo5GPIVnI0WMHhgmPHafw8ZTiewlxc5fFc4doPesl(A0geADXNj19qDuoPV22Kkzd1VPaVYKugnSXUhESqGrrzwnvNfl19qDAiKRGSbsAjAomqqWQndUJJKQJ8yHG6SyPoKVkdLHarAbz6CaH8bNsKvwCGR7vX31XcbIpoiNhTIqyTCiKx8jGp4KsiT476yHaXhb5Ct0sMbeqyX3grAyZWddM0qGcl(sjcH15wiV4taFWjLqAX31XcbIpMVAY4aLrTAs8TrKg2m8WGjneOWIVuIqyTCkKx8jGp4KsiT476yHaX3vic48fqguh3k(A0geADXNj19qDuoPV22Kkzd1VPaVYKugnSXUhESqGrrzwnvNfl19qDAiKRGSbsAjAomqqWQndUJJKQJ8yHG6SyPoKVkdLHarAbz6CaH8bNsKvwCGR7vX3grAyZWddM0qGcl(mlcH15uH8Ipb8bNucPfFG3qIVltCRJCSzcbHbon2q2iK476yHaX3LjU1ro2mHGWaNgBiBesecRFbH8Ipb8bNucPfFxhlei(AjAomqqWQndUJdXxJ2GqRl(puhYxLHYqGiTGmDoGq(GtjYkloWIpnNKomaVHeFTenhgiiy1Mb3XHieH4pxWIBfYlSMzH8Ipb8bNucPfFnAdcTU4NXrRp4uAeKrdbQnwiq8DDSqG4pOGnIaMOLmKeclcH1sjKx8jGp4KsiT4RrBqO1f)rFoty(QjJdug1QPeIA8fGR7P6ITHmb0OwQowQB0NZeMVAY4aLrTAkHOgFb46EQoMuhZ1XEDAyZaASHliW19ADYO6yo9cIVRJfceFmF1KXbkJA1Kiewlxc5fFc4doPesl(A0geADXF0NZecY5MOLmdiGWje14lax3tmQtUQZIL6Y4O1hCkHIHbriiNl(Uowiq8rqo3eTKzabewecRLdH8Ipb8bNucPfFnAdcTU47YKqBqjxtMUTrcSJmyorzOeb8bNu1zXsDUmj0gusrUc3cJeb8bNuIVRJfce)bfSreWeTKHKqyriSo3c5fFxhlei(QfB7HUv8jGp4KsiTieH4JdY5rRqEH1mlKx8DDSqG47nJoUv8jGp4KsiTieH4RvyH8cRzwiV4taFWjLqAXxJ2GqRl(puhoiNhTKk5CU476yHaXx7CUX1Xcbg(IdXNV4Wa8gs8jmMaAclcH1sjKx8jGp4KsiT4RrBqO1f)hQB0NZKRqeW5lGmOoUn1TRJL6iaHYkjfBdzcOPXTsDpwhZ1XsDmPUhQJYj912MujxM4wh5yZeccdCASHSrO6SyPoneYvq2ajUheimos7apHOgFb46ESoPyADVk(Uowiq8DfIaoFbKb1XTIqyTCjKx8jGp4KsiT476yHaXVXrVjLzcrgf5rR4RrBqO1fFKVkdLHarYvkCQBxhl1XK6chLLIuSnKjGg1s19uDAyZaASHliWjfnx9g1zXsDpuhoiNhTKkHGz7uDSuNg2mGgB4ccCsrZvVrDpYOoTTPXTIbBtavD5OoMR7vXxlrZjt4OSuGfwZSiewlhc5fFc4doPesl(A0geADXh5RYqziqKCLcNwqDpwNCX06YrDiFvgkdbIKRu4KQJ8yHG6yPUhQdhKZJwsLqWSDQowQtdBgqJnCbboPO5Q3OUhzuN2204wXGTjGQUCuhZIVRJfce)gh9MuMjezuKhTIqyDUfYl(eWhCsjKw81Oni06Ip2M4Ct4OSuGR7rg1jvDSu3d1n6ZzAWDfzM8ocjj1TRJL6ysDpuhYxLHYqGi5kforwzXbUolwQd5RYqziqKCLcNquJVaCDpw3luNfl1H8vzOmeisUsHtlOUhRJj1jvD5OoneYvq2aPb3vKzY7iKKKU1rzjSzICDSqGZR716Kr1jvUR7vX31XcbI)G7kYm5DesIiewlNc5fFc4doPesl(A0geADXpJJwFWP0G7kYm5DesIblbORJL60WMb0ydxqGtkAU6nQ7rg1XCDSx3OpNPbc6k8QOu3w8DDSqG4NTfIdUedoq7BsecRZPc5fFc4doPesl(A0geADXpJJwFWP0G7kYm5DesIblbORJL6ysDeGqzLKITHmb004wPUhRl31zXsDeGqzLu3t1XCUR7vX31XcbI)7LZxqwd2grKiew)cc5fFc4doPesl(A0geADXpJJwFWP0G7kYm5DesIblbORJL6iaHYkjfBdzcOPXTsDpwhZIVRJfce)b3vKb1XTIqyTCxiV4taFWjLqAXxJ2GqRl(puhoiNhTKk5CEDSuxghT(GtjVz0XTgneO2yHaX31XcbIFghS4wriSMzMkKx8jGp4KsiT4RrBqO1f)hQdhKZJwsLCoVowQlJJwFWPK3m64wJgcuBSqG476yHaXh36kiBnexjcH1mZSqEXNa(GtkH0IVgTbHwx8h95mn4qOI3XrcrUoQZIL6g95m5kebC(cidQJBtDBX31XcbIVnmwiqecRzwkH8Ipb8bNucPfFxhlei(zC06dozwqqa8gsmz3SEgipmqSE5CpwqwdICDarIVgTbHwx8h95mn4qOI3XrcrUoQZIL6ITHmb0OwQUNyuNumTolwQtdBgqJnCbboPO5Q3OUNyuNuIpWBiXpJJwFWjZcccG3qIj7M1Za5HbI1lN7XcYAqKRdisecRzwUeYl(eWhCsjKw81Oni06I)OpNPbhcv8oosiY1rDwSuxSnKjGg1s19eJ6KIP1zXsDAyZaASHliWjfnx9g19eJ6Ks8DDSqG43XKzdQblcH1mlhc5fFxhlei(doeQmZosI4taFWjLqAriSM5ClKx8DDSqG4pieMqVxqwXNa(GtkH0IqynZYPqEX31XcbI)Cr0GdHkXNa(GtkH0IqynZ5uH8IVRJfceFhOjCGCUr7CU4taFWjLqAriSM5xqiV4taFWjLqAX31XcbIVwIMddeeSAZG74q81Oni06I)d1HdY5rlPsoNxhl1n6ZzYvic48fqguh3Muq2a1XsDJ(CMAOgisIbon8UEvgfI8gCsbzduhl1racLvsk2gYeqtJBL6ESo5OowQdfdZOpN46EQUCl(0Cs6Wa8gs81s0CyGGGvBgChhIqynZYDH8Ipb8bNucPfFxhlei(UmXToYXMjeeg40ydzJqIVgTbHwx8FOUrFotUcraNVaYG642u3UowQ7H6g95mn4UImtEhHKK621XsDAiKRGSbsUcraNVaYG642eIA8fGR7P6yo3IpWBiX3LjU1ro2mHGWaNgBiBesecRLIPc5fFc4doPesl(Uowiq8DCBghqydYLjez0qKZfFnAdcTU4ROrFotixMqKrdro3OOrFotkiBG6SyPofn6ZzsdbQUo2mKzbVnkA0NZu3UowQlCuwksTKZJ2KToQ7P6KlPQJL6chLLIul58OnzRJ6EKrDYftRZIL6EOofn6ZzsdbQUo2mKzbVnkA0NZu3UowQJj1POrFotixMqKrdro3OOrFot4W1VR7rg1jftRlh1XmtRtgvNIg95mn4qOYaNMOLmeGAKK621zXsDHJYsrk2gYeqJAP6EQo5KP19ADSu3OpNjxHiGZxazqDCBcrn(cW19yDm)cIpWBiX3XTzCaHnixMqKrdroxecRLIzH8Ipb8bNucPfFnAdcTU4p6ZzAWHqfVJJeICDuNfl1fBdzcOrTuDpXOoPyADwSuNg2mGgB4ccCsrZvVrDpXOoPeFxhlei(Dmz2GAWIqeI)OVCLqEH1mlKx8jGp4KsiT4RrBqO1f)rFotqBBik6GnKK621XsDmPUrFotVjY2ib2rg22aB8bShgjWEchU(DDpvhZYrDwSu3OpNjf5kClmsD76SyPocqOSsQ7P6KJCx3RIVRJfceF7fhqUb3cdriSwkH8IVRJfceF8cwCqidoq7Bs8jGp4KsiTieHieHieca]] )


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