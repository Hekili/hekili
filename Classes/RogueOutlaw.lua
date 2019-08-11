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


    spec:RegisterPack( "Outlaw", 20190810, [[daLXhbqivbpsvuBcf1NikOrPkLtPkvRIOq9kuQMfkXTOK0Ue5xeLgMQKogrYYqj9mIQyAIkX1evyBevvFtuP04uLGZruLADQsO5PkY9qH9Pk0bfvslKi1djkWejQkxuuPyJefYhfve6KQsuwPOQxQkr1mfve0nvLiTtkP(PQeXqjQsoQOIalvuP6PQQPsu5QIkkBvursFvurQXkQiQZkQiXEj8xkgSkhMQfRWJj1Kj5YiBwrFwuA0sPtR0Qfve51OiZgv3wk2nWVbnCk1XfvuTCiphQPlCDPA7IIVJsz8usCEIy9efnFkX(LSqkHCIVYdsynRVkL8(1xqQxtSYAoyLvwf)qInj(2UMjplj(aVHe)xsp4oBIVTlHdDLqoXhd7inj(TryJFrzLn7gT9rsdBKfVnDUhleOr(mKfVnAzf)rF5XldigIVYdsynRVkL8(1xqQxtSkvoK)CjhIp2M0cRzv(Fv8BxLIaIH4RiSw8FUUxsp4oB1L7WSDQY)CDTryJFrzLn7gT9rsdBKfVnDUhleOr(mKfVnAzR8pxxU2Z2XrD5GL6y9vPK31z16yvQxmh5OYx5FUozqRdYs4xSY)CDwTUCvPivDV8vZuDbSofn9opQZ1Xcb1XxCKQ8pxNvRlxvksvNnI0WMHh1jn3vuDYiEhHKu3BkiHbYWOUbICMQ7hKZJ23tv(NRZQ1jFqGmmQRJP6c0cyIcCDlOoCqopAtv(NRZQ1jFqGmmQRJP6AwWlMtUUjev3l1rmrQ6MquDYh5rBDVTHmexhag1H722quqQ3tv(NRZQ1LRzGRQoeHGC(cYwxUhsxNQJwq26KM7kQozeVJqsQ7ToGtyCDSr1bbCj116zO6KQUWrzP49uL)56SAD5oXDRu3lF58fKTUVnIOuL)56SAD5mmvxSnKjGg1s1nHO6iGg2bbHQJaQfKToKhTeQUO1b1foklfPyBitanQLsIVncoxoj(px3lPhCNT6YDy2ov5FUU2iSXVOSYMDJ2(iPHnYI3Mo3Jfc0iFgYI3gTSv(NRlx7z74OUCWsDS(QuY76SADSk1lMJCu5R8pxNmO1bzj8lw5FUoRwxUQuKQUx(QzQUawNIMENh156yHG64losv(NRZQ1LRkfPQZgrAyZWJ6KM7kQozeVJqsQ7nfKWazyu3arot19dY5r77Pk)Z1z16Kpiqgg11XuDbAbmrbUUfuhoiNhTPk)Z1z16Kpiqgg11XuDnl4fZjx3eIQ7L6iMivDtiQo5J8OTU32qgIRdaJ6WDBBiki17Pk)Z1z16Y1mWvvhIqqoFbzRl3dPRt1rliBDsZDfvNmI3rij19whWjmUo2O6GaUK6A9muDsvx4OSu8EQY)CDwTUCN4UvQ7LVC(cYw33gruQY)CDwTUCgMQl2gYeqJAP6MquDeqd7GGq1ra1cYwhYJwcvx06G6chLLIuSnKjGg1sPkFL)56YnwH09Gu1nOjer1PHndpQBqzxaovxUQ1KDGRdabwT1rnZoVoxhleGRdc4ssv(NRZ1Xcb4KnI0WMHhmMChZuL)56CDSqaozJinSz4b7mK17zBiq4Xcbv(NRZ1Xcb4KnI0WMHhSZq2jeQQ8px3h424wyuhYxvDJ(CsQ6WHh46g0eIO60WMHh1nOSlaxNdu1zJiRAdJybzRBX1PGakv5FUoxhleGt2isdBgEWodzXa3g3cddo8ax5DDSqaozJinSz4b7mK1ggleu5DDSqaozJinSz4b7mKTXrmrkZeImkYJwwSrKg2m8WGjneOWmYbl7KbYxLHYqGi5kfoTGhZLxR8UowiaNSrKg2m8GDgYIdY5rll7KXBpq58(ABtQKnuZef4vMKYOHn29WJfcmkkZQjlwEqdHCfKnqslrZHbccwTzWDCKuDKhleyXcYxLHYqGiTGmDoGq(GtjYkloWVx5DDSqaozJinSz4b7mKfb5Ct0sMbeqywSrKg2m8WGjneOWmyTY76yHaCYgrAyZWd2zilMVAY4aLrTAIfBePHndpmysdbkmdwR8UowiaNSrKg2m8GDgY6kebC(cidQJBzXgrAyZWddM0qGcZqkw2jJ3EGY5912MujBOMjkWRmjLrdBS7HhleyuuMvtwS8Ggc5kiBGKwIMddeeSAZG74iP6ipwiWIfKVkdLHarAbz6CaH8bNsKvwCGFVY76yHaCYgrAyZWd2ziBhtMnOgwaEdXWLjU1ro2mHGWaNgBiBeQY76yHaCYgrAyZWd2ziBhtMnOgwO5K0Hb4nedTenhgiiy1Mb3Xbl7KXdiFvgkdbI0cY05ac5doLiRS4ax5R8pxxUXkKUhKQokdHKuxSnuDrlvNRdiQUfxNNXxUp4uQY)CD5oHdY5rBD7SoBigVdov3BayDz6CaH8bNQJauZs46wqDAyZWJ3R8UowiaZGPvZel7KXd4GCE0sQecMTtvExhleGzGdY5rBL)56YDcb586MquDSYEDJ(CIRJTnARlNqORivDY3QP662P6EjrlHyBXuDicb586MquDSYEDquD5eroqv3lL4evhevxU3JwoHX1jVqKEXleKQ8UowiaZodzZ4O1hCIfG3qmqXWGieKZzjJZ7edummJ(CIFIvMFB0NZeh6kszuRMsDBlwEy0NZuwKduMgItuQBZ8dJ(CMq9OLtySXgr6fVqqQB)EL)56YDcb586MquDSYEDJ(CIRdIQl37rlNW46KxisV4fcQJTnARt(ixHBHrDquD5QMQRBxNeyhv3Ntugkv5DDSqaMDgYMXrRp4elaVHyGIHbriiNZc0MbMcw2jdxMeAdkPixHBHrIa(GtklwCzsOnOKRjt32ib2rgmNOmuIa(GtkwY48oXafdZOpN4NyL53g95mXHUIug1QPu32ILrFotOE0Yjm2yJi9IxiiHOgFb4NyOHqUcYginOGnIaMOLmKecNquJVa87v(NRJv2R7dCMO6Ynsi8lwxUYzZLGRdriiNx3eIQJv2RB0NtCQY76yHam7mKnJJwFWjwaEdXafddIqqoNfOndmfSStgUmj0gucdCMidjHWjKdy6rgSYsgN3jgOyyg95e)eRv(NRJv2R7dCMO6Ynsi8lwN8bRdaJ6qecY51X2gT1Xk71HdxZeUo4SUOLQ7dCMO6YnsiCDJ(Cw3BsXED4W1mvhBB0wN0iORWRIQRB)EQY76yHam7mKnJJwFWjwaEdXafddIqqoNfOndeHPGLDYWLjH2GsyGZezijeoHCatpYGvMh95mHbotKHKq4eoCntpYGvRo6ZzAGGUcVkk1TR8pxxo9gT1jn3vuDYiEhHKux3ML62SaiIQd15eUoFaZq15avDHZevhLHqsI2fKTUO1J6wCDSYEDVbGrDAyheliBDFxg8EDquD4fKLt1j9NL6Yj(szPUCxEv5DDSqaMDgYMXrRp4elaVHyGIHbriiNZc0MbMcw2jJrFotdURiZK3rijPUnlzCENyGIHz0NtSvh95mHzQZ5ghOmAeeJhqaHtD7NyL53g95mXHUIug1QPu32ILhg95mLf5aLPH4eL62m)WOpNjupA5egBSrKEXleK62m)WOpNPbc6k8QOu3(9kVRJfcWSZq2moA9bNyb4nedVz0XTgneO2yHawY48oXqdBgqJnCbboPO5Q34rgSYoRY43cNtGiLTfIdUedoqltuIa(GtkM1qixbzdKY2cXbxIbhOLjkHOgFb4NK6D2h95mnqqxHxfL62mtacLvYJY)Rm)WOpNjmtDo34aLrJGy8aciCQBZ8dJ(CMyIiBJeyhzyBdSXhWEyKa7PUDL31Xcby2ziBghT(GtSa8gIXiiJgcuBSqalzCENym6Zzc1JwoHXgBePx8cbPUTflV5YKqBqjf5kClmseWhCszXIltcTbLCnz62gjWoYG5eLHseWhCs9oZJ(CMqqo3eTKzabeo1TR8pxxo9gT1105XAZP6chLLcml1fTlUUmoA9bNQBX1PBjntKQUawNI0RIQJTwkAjuDyydvNmq(W1HBHDUQUbvhwcqtQ6yBJ26KM7kQozeVJqsQ8UowiaZodzZ4O1hCIfG3qmgCxrMjVJqsmyjanlzCENyGTjo3eoklf40G7kYm5DesYtSYmYxLHYqGi5kfoTGhz9vlwg95mn4UImtEhHKK62vExhleGzNHSANZnUowiWWxCWcWBig4GCE0YYozGdY5rlPsoNx5DDSqaMDgYQDo346yHadFXblaVHyOv4k)Z1jJwWIBRZJ6ACRSn9M6KbYRuD)(ahixh1bbuDtiQoY1T1jnc6k8QO6CGQUxITnefDWgsQJTwcuxob9vZuDYhYzRUfxhM4KoivDoqv3lDkF1T46aWOoe5kj15ZGq1fTuDaYkrDysdbQuL31Xcby2zilQdmUowiWWxCWcWBigZfS4ww2jdnSzan2Wfe4hzOTnnUvmyBcOS6BJ(CMgiORWRIsDB2h95mbTTHOOd2qsQB)Um(TW5eis58(QzYOqoBjc4doPy(ThcNtGi14iMiLzcrgf5rBIa(Gtklw0qixbzdKACetKYmHiJI8OnHOgFb4hL693R8UowiaZodz1oNBCDSqGHV4GfG3qmg9LRQ8UowiaZodzDK2bKjGiebcw2jdcqOSsskAU6nEKHu5GDcqOSssiklbQ8UowiaZodzDK2bKXUZXuL31Xcby2zilFZ2gytoPUkBdbIkFL)56KUVCfHWv(NRlNHP6KxloG86(TWOUDw3g1XgeidJ60UDDAyZawNnCbbUohOQlAP6Ej22WOd2qsDJ(Cw3IRRBNQlxZaxvDD8cYwhBTeOUxor21Ltb2r1LtVbUoC4AMW15iQU2nBBDDaNW46IwQo5JCfUfg1n6ZzDlUoNJH11TtvExhleGtJ(YvmSxCa5gClmyzNmg95mbTTHOOd2qsQBZ8BJ(CMyIiBJeyhzyBdSXhWEyKa7jC4AMEsQxTyz0NZKICfUfgPUTfleGqzL8uUKJ3R8UowiaNg9LRyNHS4fS4GqgCGwMOkFL)56KbqixbzdGR8UowiaN0kmdTZ5gxhley4loyb4nedcJjGMWSStgpGdY5rlPsoNx5DDSqaoPvy2ziRRqeW5lGmOoULLDY4HrFotUcraNVaYG642u3MzcqOSssX2qMaAACR8Oum)2duoVV22Kk5Ye36ihBMqqyGtJnKnczXIgc5kiBGe3dceghPDGNquJVa8JS(67v(NR7LnRZvkCDoIQRBZsDyWAt1fTuDqavhBB0whhYgHJ6Kto5lvxodt1XwlbQtjzbzRB64Gq1fToOozG8Qofnx9g1br1X2gTWEuNdKuNmqELQ8UowiaN0km7mKTXrmrkZeImkYJww0s0CYeoklfygsXYozG8vzOmeisUsHtDBMFlCuwksX2qMaAul9Kg2mGgB4ccCsrZvVHflpGdY5rlPsiy2oXSg2mGgB4ccCsrZvVXJm02Mg3kgSnbuwvQ3R8px3lBwhawNRu46yB586ulvhBB0UG6IwQoazLOo55vml11XuDV0P8vheu3aIX1X2gTWEuNdKuNmqELQ8UowiaN0km7mKTXrmrkZeImkYJww2jdKVkdLHarYvkCAbpkpVAvKVkdLHarYvkCs1rESqaZpGdY5rlPsiy2oXSg2mGgB4ccCsrZvVXJm02Mg3kgSnbuwvQk)Z1jn3vuDYiEhHKuheuhRSxhbOMLWP6YP3OToxPWVyD5mmv3oRlAjj1HdxsDtiQUxG96WKgcu46GO62zDsGDuDaYkrD6whLLQJTLZRBq1HixjPUfuxSnuDtiQUOLQdqwjQJnpdLQ8UowiaN0km7mKDWDfzM8ocjHLDYaBtCUjCuwkWpYGvMFy0NZ0G7kYm5DessQBZ8BpG8vzOmeisUsHtKvwCGTyb5RYqziqKCLcNquJVa8JVGfliFvgkdbIKRu40cE8nwTQgc5kiBG0G7kYm5Desss36OSe2mrUowiW5VlJznhVx5DDSqaoPvy2ziB2wio4sm4aTmrSStgzC06doLgCxrMjVJqsmyjanZAyZaASHliWjfnx9gpYqk2h95mnqqxHxfL62vExhleGtAfMDgYY0Y5liRbBJiILDYiJJwFWP0G7kYm5DesIblbOz(ncqOSssX2qMaAACR8yoSyHaekRKNKkhVx5DDSqaoPvy2zi7G7kYG64ww2jJmoA9bNsdURiZK3rijgSeGMzcqOSssX2qMaAACR8Ouv(NRlNHxq26YP6Gf3kBU2m6426wCDqaxsDEDziKK6IfiPUfOrKJjwQddRBb1HiNVHewQtcSldruD(ad59G4sQBUaQUawxht1TrDoUoVUES8nKuh2M48uL31Xcb4KwHzNHSzCWIBzzNmEahKZJwsLCoN5moA9bNsEZOJBnAiqTXcbvExhleGtAfMDgYIBDfKTgIRyzNmEahKZJwsLCoN5moA9bNsEZOJBnAiqTXcbvExhleGtAfMDgYAdJfcyzNmg95mn4qOI3XrcrUoSyz0NZKRqeW5lGmOoUn1TR8pxNmY58fKTUHRzQUawNIMENh1Tb1uxh7zPkVRJfcWjTcZodz7yYSb1WcWBigzC06dozwqqa8gsmz3SEgipmqSE5CpwqwdICDarSStgJ(CMgCiuX74iHixhwSeBdzcOrT0tmy9vlw0WMb0ydxqGtkAU6nEIbRvExhleGtAfMDgY2XKzdQbZYozm6ZzAWHqfVJJeICDyXsSnKjGg1spXG1xTyrdBgqJnCbboPO5Q34jgSw5DDSqaoPvy2zi7GdHkZSJKu5DDSqaoPvy2zi7GqycX0cYw5DDSqaoPvy2zi7Cr0GdHQkVRJfcWjTcZodzDGMWbY5gTZ5vExhleGtAfMDgY2XKzdQHfAojDyaEdXqlrZHbccwTzWDCWYoz8aoiNhTKk5CoZJ(CMCfIaoFbKb1XTjfKnaZJ(CMAOgisIbon8UEvgfI8gCsbzdWmbiuwjPyBitannUvEmxygfdZOpN4NYrL31Xcb4KwHzNHSDmz2GAyb4nedxM4wh5yZeccdCASHSriw2jJhg95m5kebC(cidQJBtDBMFy0NZ0G7kYm5DessQBZSgc5kiBGKRqeW5lGmOoUnHOgFb4NKkhv(NRlNkHKuhc2Z2YLuhQZP6GZ6I2EZyNlPQRXJwCDdIdz7fRlNHP6MquDVmat2qvDA0gSuhmAjeBlMQJTnARlxZ968OowFL96WHRzcxhevNuVYEDSTrBDohdRtAoeQQRBNQ8UowiaN0km7mKTJjZgudlaVHy442moGWgKltiYOHiNZYozOOrFotixMqKrdro3OOrFotkiBalwu0OpNjneO66yZqMfWKrrJ(CM62mhoklfPwY5rBYwhpjpSYC4OSuKAjNhTjBD8id55vlwEqrJ(CM0qGQRJndzwatgfn6ZzQBZ8BkA0NZeYLjez0qKZnkA0NZeoCntpYG1xTQuVkJv0OpNPbhcvg40eTKHauJKu32ILWrzPifBdzcOrT0tY)RVZ8OpNjxHiGZxazqDCBcrn(cWpk1lu5FUo5JMENh1nDoF4AMQBcr11X(Gt1Tb1GtvExhleGtAfMDgY2XKzdQbZYozm6ZzAWHqfVJJeICDyXsSnKjGg1spXG1xTyrdBgqJnCbboPO5Q34jgSw5R8pxxUbJjGMWvExhleGtegtanHzOHanbcKhKYm5EdXYozqacLvsk2gYeqtJBLhLI5hg95mn4UImtEhHKK62m)2dkyK0qGMabYdszMCVHmJocKIvZ0cYY8dUowiiPHanbcKhKYm5EdLwGzY3STHflZoNBqKU1rzjtSn0tz1QuJBL3R8UowiaNimMaAcZodzhCiuzGtt0sgcqnsyzNmY4O1hCkn4UImtEhHKyWsaAM1qixbzdKguWgrat0sgscHtDBMZ4O1hCkncYOHa1gleu5DDSqaorymb0eMDgYMT7i16adCACzsiy0w5DDSqaorymb0eMDgYoH6oMugxMeAdYmiVHLDYaBtCUjCuwkWPb3vKzY7iKKhzWQfliFvgkdbIKRu40cEu(FL5hg95m5kebC(cidQJBtD7kVRJfcWjcJjGMWSZqw7oANswqwZG74GLDYaBtCUjCuwkWPb3vKzY7iKKhzWQfliFvgkdbIKRu40cEu(FTY76yHaCIWycOjm7mKnAjthmGDGYmHinXYozm6ZzcrAM4egBMqKMsDBlwg95mHintCcJntistgnSdccLWHRz6jPETY76yHaCIWycOjm7mKfT22CYSad221uL31Xcb4eHXeqty2zilBqexLHwGbryiWbAILDYy0NZeFN0GdHQeoCntpjpvExhleGtegtanHzNHSnudejXaNgExVkJcrEdMLDYGaekRKNYLCu5R8pxNmAblULq4k)Z1jDKBQdMHq1L7H01HieKZX1X2gT1jFKRWTWq2Cvt1fiFdCDquD5EpA5egxN8cr6fVqqQY76yHaCAUGf3YyqbBebmrlzijeMLDYiJJwFWP0iiJgcuBSqqL31Xcb40CblULDgYI5RMmoqzuRMyzNmg95mH5RMmoqzuRMsiQXxa(PyBitanQLyE0NZeMVAY4aLrTAkHOgFb4NEtk21WMb0ydxqGFxglv6fQ8UowiaNMlyXTSZqweKZnrlzgqaHzzNmg95mHGCUjAjZaciCcrn(cWpXqEQ8UowiaNMlyXTSZqweKZnrlzgqaHzzNmEZ1XMHmeGAwcZqklwg95mn4UImtEhHKKuq2aVZCghT(Gtjummicb58k)Z1jDKBQJTnARlAP6YvnvxoZUUCkWoQUpNOmuDquDYh5kClmQlq(g4uL31Xcb40CblULDgYoOGnIaMOLmKecZYoz4YKqBqjxtMUTrcSJmyorzOeb8bNuwS4YKqBqjf5kClmseWhCsv5DDSqaonxWIBzNHSQfB7HUTYx5FUUFqopAR8UowiaNWb58OLH3m64wXpdHWleiSM1xLsE)6l8Q8i(S5iWcYIf)xwJnefKQUCBDUowiOo(IdCQYl(EpAHiX)VnYaXNV4alKt8jmMaAclKtyTuc5eFc4doPesl(A0geADXNaekRKuSnKjGMg3k19yDsvhZ19qDJ(CMgCxrMjVJqssD76yUU3Q7H6uWiPHanbcKhKYm5EdzgDeifRMPfKToMR7H6CDSqqsdbAceipiLzY9gkTaZKVzBJ6SyPUzNZnis36OSKj2gQUNQlRwLACRu37IVRJfceFneOjqG8GuMj3BiriSMvHCIpb8bNucPfFnAdcTU4NXrRp4uAWDfzM8ocjXGLa01XCDAiKRGSbsdkyJiGjAjdjHWPUDDmxxghT(GtPrqgneO2yHaX31XcbI)GdHkdCAIwYqaQrIiewlpc5eFxhlei(z7osToWaNgxMecgTIpb8bNucPfHW6CriN4taFWjLqAXxJ2GqRl(yBIZnHJYsbon4UImtEhHKu3JmQJ16SyPoKVkdLHarYvkCAb19yDY)R1XCDpu3OpNjxHiGZxazqDCBQBl(Uowiq8NqDhtkJltcTbzgK3icH15qiN4taFWjLqAXxJ2GqRl(yBIZnHJYsbon4UImtEhHKu3JmQJ16SyPoKVkdLHarYvkCAb19yDY)RIVRJfceF7oANswqwZG74qecRLFHCIpb8bNucPfFnAdcTU4p6ZzcrAM4egBMqKMsD76SyPUrFotisZeNWyZeI0Krd7GGqjC4AMQ7P6K6vX31XcbIF0sMoya7aLzcrAsecRZTc5eFxhlei(O12MtMfyW2UMeFc4doPeslcH1VGqoXNa(GtkH0IVgTbHwx8h95mX3jn4qOkHdxZuDpvN8i(Uowiq8zdI4Qm0cmicdboqtIqyT8wiN4taFWjLqAXxJ2GqRl(eGqzLu3t1Ll5q8DDSqG43qnqKedCA4D9Qmke5nyricXxrtVZdHCcRLsiN4taFWjLqAXxJ2GqRl(puhoiNhTKkHGz7K476yHaXNPvZKiewZQqoX31XcbIpoiNhTIpb8bNucPfHWA5riN4taFWjLqAXhAl(ykeFxhlei(zC06doj(zCENeFummJ(CIR7P6yToMR7T6g95mXHUIug1QPu3UolwQ7H6g95mLf5aLPH4eL621XCDpu3OpNjupA5egBSrKEXleK6219U4NXrgG3qIpkggeHGCUiewNlc5eFc4doPesl(qBXhtH476yHaXpJJwFWjXpJZ7K4JIHz0NtCDpvhR1XCDVv3OpNjo0vKYOwnL621zXsDJ(CMq9OLtySXgr6fVqqcrn(cW19eJ60qixbzdKguWgrat0sgscHtiQXxaUU3fFnAdcTU47YKqBqjf5kClmseWhCsvNfl15YKqBqjxtMUTrcSJmyorzOeb8bNuIFghzaEdj(OyyqecY5IqyDoeYj(eWhCsjKw8H2IpMcX31XcbIFghT(GtIFgN3jXhfdZOpN46EQowfFnAdcTU47YKqBqjmWzImKecNqoGP6EKrDSk(zCKb4nK4JIHbriiNlcH1YVqoXNa(GtkH0Ip0w8reMcX31XcbIFghT(GtIFghzaEdj(OyyqecY5IVgTbHwx8DzsOnOeg4mrgscHtihWuDpYOowRJ56g95mHbotKHKq4eoCnt19iJ6yToRw3OpNPbc6k8QOu3wecRZTc5eFc4doPesl(qBXhtH476yHaXpJJwFWjXpJZ7K4JIHz0NtCDwTUrFotyM6CUXbkJgbX4beq4u3UUNQJ16yUU3QB0NZeh6kszuRMsD76SyPUhQB0NZuwKduMgItuQBxhZ19qDJ(CMq9OLtySXgr6fVqqQBxhZ19qDJ(CMgiORWRIsD76Ex81Oni06I)OpNPb3vKzY7iKKu3w8Z4idWBiXhfddIqqoxecRFbHCIpb8bNucPfFOT4JPq8DDSqG4NXrRp4K4NX5Ds81WMb0ydxqGtkAU6nQ7rg1XADSxhR1jJR7T6cNtGiLTfIdUedoqltuIa(GtQ6yUoneYvq2aPSTqCWLyWbAzIsiQXxaUUNQtQ6EVo2RB0NZ0abDfEvuQBxhZ1racLvsDpwN8)ADmx3d1n6ZzcZuNZnoqz0iigpGacN621XCDpu3OpNjMiY2ib2rg22aB8bShgjWEQBl(zCKb4nK47nJoU1OHa1gleicH1YBHCIpb8bNucPfFOT4JPq8DDSqG4NXrRp4K4NX5Ds8h95mH6rlNWyJnI0lEHGu3UolwQ7T6CzsOnOKICfUfgjc4doPQZIL6CzsOnOKRjt32ib2rgmNOmuIa(GtQ6EVoMRB0NZecY5MOLmdiGWPUT4NXrgG3qI)iiJgcuBSqGiewl1Rc5eFc4doPesl(qBXhtH476yHaXpJJwFWjXpJZ7K4JTjo3eoklf40G7kYm5DessDpvhR1XCDiFvgkdbIKRu40cQ7X6y916SyPUrFotdURiZK3rijPUT4NXrgG3qI)G7kYm5DesIblbOfHWAPKsiN4taFWjLqAXxJ2GqRl(4GCE0sQKZ5IVRJfceFTZ5gxhley4loeF(IddWBiXhhKZJwriSwkwfYj(eWhCsjKw8DDSqG4RDo346yHadFXH4ZxCyaEdj(AfwecRLsEeYj(eWhCsjKw81Oni06IVg2mGgB4ccCDpYOoTTPXTIbBtavDwTU3QB0NZ0abDfEvuQBxh71n6ZzcABdrrhSHKu3UU3Rtgx3B1foNarkN3xntgfYzlraFWjvDmx3B19qDHZjqKACetKYmHiJI8OnraFWjvDwSuNgc5kiBGuJJyIuMjezuKhTje14lax3J1jvDVx37IVRJfceFuhyCDSqGHV4q85lomaVHe)5cwCRiewlvUiKt8jGp4KsiT476yHaXx7CUX1Xcbg(IdXNV4Wa8gs8h9LReHWAPYHqoXNa(GtkH0IVgTbHwx8jaHYkjPO5Q3OUhzuNu5Oo2RJaekRKeIYsaX31XcbIVJ0oGmbeHiqicH1sj)c5eFxhlei(os7aYy35ys8jGp4KsiTiewlvUviN476yHaXNVzBdSjNuxLTHaH4taFWjLqAricX3grAyZWdHCcRLsiN476yHaX3gglei(eWhCsjKwecRzviN4taFWjLqAX31XcbIFJJyIuMjezuKhTIVgTbHwx8r(QmugcejxPWPfu3J1LlVk(2isdBgEyWKgcuyXphIqyT8iKt8jGp4KsiT4RrBqO1f)3Q7H6OCEFTTjvYgQzIc8ktsz0Wg7E4XcbgfLz1uDwSu3d1PHqUcYgiPLO5WabbR2m4oosQoYJfcQZIL6q(QmugcePfKPZbeYhCkrwzXbUU3fFxhlei(4GCE0kcH15IqoXNa(GtkH0IVRJfceFeKZnrlzgqaHfFBePHndpmysdbkS4ZQiewNdHCIpb8bNucPfFxhlei(y(QjJdug1QjX3grAyZWddM0qGcl(SkcH1YVqoXNa(GtkH0IVRJfceFxHiGZxazqDCR4RrBqO1f)3Q7H6OCEFTTjvYgQzIc8ktsz0Wg7E4XcbgfLz1uDwSu3d1PHqUcYgiPLO5WabbR2m4oosQoYJfcQZIL6q(QmugcePfKPZbeYhCkrwzXbUU3fFBePHndpmysdbkS4lLiewNBfYj(eWhCsjKw8bEdj(UmXToYXMjeeg40ydzJqIVRJfceFxM4wh5yZeccdCASHSririS(feYj(eWhCsjKw8DDSqG4RLO5WabbR2m4ooeFnAdcTU4)qDiFvgkdbI0cY05ac5doLiRS4al(0Cs6Wa8gs81s0CyGGGvBgChhIqeI)CblUviNWAPeYj(eWhCsjKw81Oni06IFghT(GtPrqgneO2yHaX31XcbI)Gc2icyIwYqsiSiewZQqoXNa(GtkH0IVgTbHwx8h95mH5RMmoqzuRMsiQXxaUUNQl2gYeqJAP6yUUrFoty(QjJdug1QPeIA8fGR7P6ERoPQJ960WMb0ydxqGR796KX1jv6feFxhlei(y(QjJdug1QjriSwEeYj(eWhCsjKw81Oni06I)OpNjeKZnrlzgqaHtiQXxaUUNyuN8i(Uowiq8rqo3eTKzabewecRZfHCIpb8bNucPfFnAdcTU4)wDUo2mKHauZs46yuNu1zXsDJ(CMgCxrMjVJqsskiBG6EVoMRlJJwFWPekggeHGCU476yHaXhb5Ct0sMbeqyriSohc5eFc4doPesl(A0geADX3LjH2GsUMmDBJeyhzWCIYqjc4doPQZIL6CzsOnOKICfUfgjc4doPeFxhlei(dkyJiGjAjdjHWIqyT8lKt8DDSqG4RwSTh6wXNa(GtkH0IqeIpoiNhTc5ewlLqoX31XcbIV3m64wXNa(GtkH0IqeIVwHfYjSwkHCIpb8bNucPfFnAdcTU4)qD4GCE0sQKZ5IVRJfceFTZ5gxhley4loeF(IddWBiXNWycOjSiewZQqoXNa(GtkH0IVgTbHwx8FOUrFotUcraNVaYG642u3UoMRJaekRKuSnKjGMg3k19yDsvhZ19wDpuhLZ7RTnPsUmXToYXMjeeg40ydzJq1zXsDAiKRGSbsCpiqyCK2bEcrn(cW19yDS(ADVl(Uowiq8DfIaoFbKb1XTIqyT8iKt8jGp4KsiT476yHaXVXrmrkZeImkYJwXxJ2GqRl(iFvgkdbIKRu4u3UoMR7T6chLLIuSnKjGg1s19uDAyZaASHliWjfnx9g1zXsDpuhoiNhTKkHGz7uDmxNg2mGgB4ccCsrZvVrDpYOoTTPXTIbBtavDwToPQ7DXxlrZjt4OSuGfwlLiewNlc5eFc4doPesl(A0geADXh5RYqziqKCLcNwqDpwN88ADwToKVkdLHarYvkCs1rESqqDmx3d1HdY5rlPsiy2ovhZ1PHndOXgUGaNu0C1Bu3JmQtBBACRyW2eqvNvRtkX31XcbIFJJyIuMjezuKhTIqyDoeYj(eWhCsjKw81Oni06Ip2M4Ct4OSuGR7rg1XADmx3d1n6ZzAWDfzM8ocjj1TRJ56ERUhQd5RYqziqKCLcNiRS4axNfl1H8vzOmeisUsHtiQXxaUUhR7fQZIL6q(QmugcejxPWPfu3J19wDSwNvRtdHCfKnqAWDfzM8ocjjPBDuwcBMixhle486EVozCDSMJ6Ex8DDSqG4p4UImtEhHKicH1YVqoXNa(GtkH0IVgTbHwx8Z4O1hCkn4UImtEhHKyWsa66yUonSzan2Wfe4KIMREJ6EKrDsvh71n6ZzAGGUcVkk1TfFxhlei(zBH4GlXGd0YejcH15wHCIpb8bNucPfFnAdcTU4NXrRp4uAWDfzM8ocjXGLa01XCDVvhbiuwjPyBitannUvQ7X6YrDwSuhbiuwj19uDsLJ6Ex8DDSqG4Z0Y5liRbBJisecRFbHCIpb8bNucPfFnAdcTU4NXrRp4uAWDfzM8ocjXGLa01XCDeGqzLKITHmb004wPUhRtkX31XcbI)G7kYG64wriSwElKt8jGp4KsiT4RrBqO1f)hQdhKZJwsLCoVoMRlJJwFWPK3m64wJgcuBSqG476yHaXpJdwCRiewl1Rc5eFc4doPesl(A0geADX)H6Wb58OLujNZRJ56Y4O1hCk5nJoU1OHa1glei(Uowiq8XTUcYwdXvIqyTusjKt8jGp4KsiT4RrBqO1f)rFotdoeQ4DCKqKRJ6SyPUrFotUcraNVaYG642u3w8DDSqG4BdJfceHWAPyviN4taFWjLqAXh4nK4NXrRp4KzbbbWBiXKDZ6zG8WaX6LZ9ybzniY1bej(Uowiq8Z4O1hCYSGGa4nKyYUz9mqEyGy9Y5ESGSge56aIeFnAdcTU4p6ZzAWHqfVJJeICDuNfl1fBdzcOrTuDpXOowFTolwQtdBgqJnCbboPO5Q3OUNyuhRIqyTuYJqoXNa(GtkH0IVgTbHwx8h95mn4qOI3XrcrUoQZIL6ITHmb0OwQUNyuhRVwNfl1PHndOXgUGaNu0C1Bu3tmQJvX31XcbIFhtMnOgSiewlvUiKt8DDSqG4p4qOYm7ijIpb8bNucPfHWAPYHqoX31XcbI)GqycX0cYk(eWhCsjKwecRLs(fYj(Uowiq8NlIgCiuj(eWhCsjKwecRLk3kKt8DDSqG47anHdKZnANZfFc4doPeslcH1s9cc5eFc4doPesl(Uowiq81s0CyGGGvBgChhIVgTbHwx8FOoCqopAjvY586yUUrFotUcraNVaYG642KcYgOoMRB0NZud1arsmWPH31RYOqK3GtkiBG6yUocqOSssX2qMaAACRu3J1Ll1XCDOyyg95ex3t1LdXNMtshgG3qIVwIMddeeSAZG74qecRLsElKt8jGp4KsiT4d8gs8DzIBDKJntiimWPXgYgHeFxhlei(UmXToYXMjeeg40ydzJqIVgTbHwx8FOUrFotUcraNVaYG642u3UoMR7H6g95mn4UImtEhHKK621XCDAiKRGSbsUcraNVaYG642eIA8fGR7P6KkhIqynRVkKt8jGp4KsiT4d8gs8DCBghqydYLjez0qKZfFxhlei(oUnJdiSb5YeImAiY5IVgTbHwx8v0OpNjKltiYOHiNBu0OpNjfKnqDwSuNIg95mPHavxhBgYSaMmkA0NZu3UoMRlCuwksTKZJ2KToQ7P6KhwRJ56chLLIul58OnzRJ6EKrDYZR1zXsDpuNIg95mPHavxhBgYSaMmkA0NZu3UoMR7T6u0OpNjKltiYOHiNBu0OpNjC4AMQ7rg1X6R1z16K616KX1POrFotdoeQmWPjAjdbOgjPUDDwSux4OSuKITHmb0OwQUNQt(FTU3RJ56g95m5kebC(cidQJBtiQXxaUUhRtQxqecRzvkHCIpb8bNucPfFnAdcTU4p6ZzAWHqfVJJeICDuNfl1fBdzcOrTuDpXOowFTolwQtdBgqJnCbboPO5Q3OUNyuhRIVRJfce)oMmBqnyricXF0xUsiNWAPeYj(eWhCsjKw81Oni06I)OpNjOTnefDWgssD76yUU3QB0NZetezBKa7idBBGn(a2dJeypHdxZuDpvNuVwNfl1n6ZzsrUc3cJu3UolwQJaekRK6EQUCjh19U476yHaX3EXbKBWTWqecRzviN476yHaXhVGfheYGd0Yej(eWhCsjKweIqeIqecba]] )


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