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


    spec:RegisterPack( "Outlaw", 20190925, [[da18hbqiHKhbqTjuIprucJcq6uOiwfGiVcLQzHs6wcPAxc(frLHHI0XikwgkLNruktJiHRbaTnHu6BaGACusQZrKiRdquZdGCpuyFaOdcaSqIupKOenrIs1fjkP2irj5Juss6KejkRuO6LejQMjLKeDtaHANus9taHmukjXrPKKWsbe8uGMkrvxfaKTkKc6RcPqJLssQoRqkWEj8xkgSkhMQfRWJj1Kj5YiBwrFwOmAP0PvA1uss51aQzJQBlf7wv)g0WPuhxifTCiphQPl66s12fIVJIA8usCEIy9ejnFkX(LSqgH8cqLNKWA2yQmsjMkLytkcYy1sHvlfaOamLytcqBxdShJeGV3qcqGOEYDMfG2Ueo0vc5fGyyhPjbyBM2yGSCYfBZ2(iOHnYH3Mo3Zf(AKpt5WBJwob4OV8uk7fdbOYtsynBmvgPetLsSjfbzSAPWQLnauaITjTWA2IwMkaBxLIEXqaQiSwac46aI6j3zUoGamwNQ4aUU2mTXaz5Kl2MT9rqdBKdVnDUNl81iFMYH3gTCvCaxhizNuZGq1XgaYADSXuzKsv8koGRtw26FmcdKR4aUUOxhaqPivDs5Rg46syDkA6DEwNRZf(1XxCgQ4aUUOxhaqPivD2isdBgEwN0Cxr1jR4DessDavbj8llY6giYbUoWKCE2YKqfhW1f96KD4llY66yQUeTpWuIRB)6Wj58SnuXbCDrVozh(YISUoMQRzFGSv96MquDaXocysv3eIQt2jpBRdOBklW19WSoC32gIssXKqfhW1f96aarGRQoeHGC((XQdiKsxNQJ2pwDsZDfvNSI3rij1b0(ZjmUoMP6GpxsDTEeQozQlDumkzsOId46IEDabI7wPoP8LZ3pwDG2iIcvCaxx0Rdact1LBdzsOrTuDtiQo61W(NeQo6v7hRoKNTeQUS1)6shfJYqUnKjHg1sbbOncoxojabCDar9K7mxhqagRtvCaxxBM2yGSCYfBZ2(iOHnYH3Mo3Zf(AKpt5WBJwUkoGRdKStQzqO6ydazTo2yQmsPkEfhW1jlB9pgHbYvCaxx0RdaOuKQoP8vdCDjSofn9opRZ15c)64lodvCaxx0RdaOuKQoBePHndpRtAURO6Kv8ocjPoGQGe(LfzDde5axhysopBzsOId46IEDYo8LfzDDmvxI2hykX1TFD4KCE2gQ4aUUOxNSdFzrwxht11Spq2QEDtiQoGyhbmPQBcr1j7KNT1b0nLf46EywhUBBdrjPysOId46IEDaGiWvvhIqqoF)y1besPRt1r7hRoP5UIQtwX7iKK6aA)5egxhZuDWNlPUwpcvNm1LokgLmjuXbCDrVoGaXDRuNu(Y57hRoqBerHkoGRl61baHP6YTHmj0OwQUjevh9Ay)tcvh9Q9JvhYZwcvx26FDPJIrzi3gYKqJAPqfVId46K1wH09Ku1nOjer1PHndpRBqX2hhQdaO1KDIR7HF0BDuZSZRZ15cFCDWNljuXbCDUox4Jd2isdBgEYyYDmWvCaxNRZf(4GnI0WMHNSZqoVhRH(0Zf(vCaxNRZf(4GnI0WMHNSZqUjeQQ4aUoW3TXTWSoKVQ6g95Ku1HtpX1nOjer1PHndpRBqX2hxN)Q6Sru0THzUFS6wCDk4tHkoGRZ15cFCWgrAyZWt2zih(DBClmn40tCf315cFCWgrAyZWt2ziNnmx4xXDDUWhhSrKg2m8KDgY14iGjLzcrgf5zlR2isdBgEAWKg(kmdaK1DYa5RYqrOpdUsHd7dqPGPvCxNl8XbBePHndpzNHC4KCE2Y6oza0OOOzFTTjvWgQbMs8kvsz0Wg7E65cFJIISAYILO0qixbz(dAjAomrWF1Mb3Xzq1rEUW3IfKVkdfH(mSFKo)jKp4uGSYItmtQ4Uox4Jd2isdBgEYod5qqo3KTKzaFcZQnI0WMHNgmPHVcZGTkURZf(4GnI0WMHNSZqomF1KXFLrTAIvBePHndpnysdFfMbBvCxNl8XbBePHndpzNHCUcrVZ3NmOoULvBePHndpnysdFfMHmSUtgankkA2xBBsfSHAGPeVsLugnSXUNEUW3OOiRMSyjkneYvqM)GwIMdte8xTzWDCguDKNl8Tyb5RYqrOpd7hPZFc5dofiRS4eZKkURZf(4GnI0WMHNSZqUoMmBsnS(EdXWLkU1ro2mHFAGtJnKzcvXDDUWhhSrKg2m8KDgY1XKztQHvAojDAEVHyOLO5Web)vBgChNSUtgrH8vzOi0NH9J05pH8bNcKvwCIR4vCaxNS2kKUNKQokcHKuxUnuDzlvNRtiQUfxNhXxUp4uOId46aceojNNT1TZ6SHy8o4uDa9H1fPZFc5dovh9uZs462VonSz4jtQ4Uox4Jza8QbM1DYikCsopBjvabJ1PkURZf(yg4KCE2wXbCDabcb586MquDSXEDJ(CIRJ5nBRZQsORivDY(QP662H6aIYwcX8IP6qecY51nHO6yJ96GO6SQI8xvhqmXjQoiQoGqpB5egxNvbr6fVWpuXDDUWhZod5I4O1hCI13BigOCyqecY5SgX5DIbkhMrFoXaInwa6OpNbo0vKYOwnf62wSe1OpNHyi)vMgItuOBZsuJ(Cgq9SLtySXgr6fVWp0TzsfhW1beieKZRBcr1Xg71n6ZjUoiQoGqpB5egxNvbr6fVWVoM3STozNCfUfM1br1ba0uDD76Ka7O6a5efHcvCxNl8XSZqUioA9bNy99gIbkhgeHGCoRqBgykzDNmCPsOnPGICfUfMb69bNuwS4sLqBsbxtMUTrcSJmyorrOa9(GtkwJ48oXaLdZOpNyaXglaD0NZah6kszuRMcDBlwg95mG6zlNWyJnI0lEHFarn((yaXqdHCfK5pmOKzIEt2sgscHdiQX3hZKkoGRJn2Rd8DGP6K1simqUoaaNzxcUoeHGCEDtiQo2yVUrFoXHkURZf(y2zixehT(GtS(EdXaLddIqqoNvOndmLSUtgUuj0Mua)oWKHKq4aYFGbid2ynIZ7eduomJ(CIbeBvCaxhBSxh47at1jRLqyGCDYoSUhM1HieKZRJ5nBRJn2RdNUgyCDWzDzlvh47at1jRLq46g95SoGkd71HtxdCDmVzBDsJGUcVkQUUntcvCxNl8XSZqUioA9bNy99gIbkhgeHGCoRqBgictjR7KHlvcTjfWVdmzijeoG8hyaYGnwg95mGFhyYqsiCaNUgyaYGTOp6ZzyGGUcVkk0TR4aUUOXnBRtAURO6Kv8ocjPUUnR1TXEiIQd15eUoFaJq15VQU0bMQJIqijz7(XQlB9SUfxhBSxhqFywNg2)C)y1b6YsMuhevhE)yCQoPbzToRQaXSwhqWQuXDDUWhZod5I4O1hCI13BigOCyqecY5ScTzGPK1DYy0NZWG7kYm5DessOBZAeN3jgOCyg95eh9rFodyG7CUXFLrJGy8a(eo0TbeBSa0rFodCORiLrTAk0TTyjQrFodXq(RmneNOq3MLOg95mG6zlNWyJnI0lEHFOBZsuJ(CggiORWRIcDBMuXDDUWhZod5I4O1hCI13BigEZOJBnA4R2CHpRrCENyOHndOXgUFIdkAU6nbid2yNnGeqtNtFgI1cXjxIbNOfykqVp4KIfneYvqM)qSwio5sm4eTatbe147JbKmmH9rFodde0v4vrHUnl0tOysay0YuwIA0NZag4oNB8xz0iigpGpHdDBwIA0NZaWezBKa7idZBIn(a2tJeyp0TR4Uox4JzNHCrC06doX67neJrsgn8vBUWN1ioVtmg95mG6zlNWyJnI0lEHFOBBXcqDPsOnPGICfUfMb69bNuwS4sLqBsbxtMUTrcSJmyorrOa9(GtkMWYOpNbeKZnzlzgWNWHUDfhW1fnUzBDnDEU2CQU0rXOeZADz7IRlIJwFWP6wCD6wsdmPQlH1Pi9QO6yULYwcvhg2q1jlLDCD4wyNRQBq1HL8AsvhZB2wN0Cxr1jR4Dessf315cFm7mKlIJwFWjwFVHym4UImtEhHKyWsEnRrCENyGTjo3KokgL4WG7kYm5DescGyJfKVkdfH(m4kfoSpazJPwSm6ZzyWDfzM8ocjj0TR4Uox4JzNHCANZnUox4B4loz99gIbojNNTSUtg4KCE2sQGZ5vCxNl8XSZqoTZ5gxNl8n8fNS(EdXqRWvCaxNSA)f3wNN114wzB6n1jlTkH6a7dCICDwh8P6MquDKRBRtAe0v4vr15VQoGiBBik7)MsQJ5w6RZQI(QbUozh5mx3IRdtCsNKQo)v1bepL96wCDpmRdrUssD(mjuDzlv3twjRdtA4Rc1ba4m7sW114wPoPtzDDmVzBDSXEDaanfQ4Uox4JzNHCO(BCDUW3WxCY67neJ5(lUL1DYqdBgqJnC)edqgABtJBfd2MEv0b6OpNHbc6k8QOq3M9rFodqBBik7)MscDBMaKaA6C6Zq0SVAGnkKZCGEFWjflanQ050NHghbmPmtiYOipBd07doPSyrdHCfK5p04iGjLzcrgf5zBarn((yakdtycqcOUuj0MuW1KPBBKa7idMtuekG8hyaXMflrPHqUcY8hguYmrVjBjdjHWHUTflrn6Zzab5Ct2sMb8jCOBZKkURZf(y2ziN25CJRZf(g(ItwFVHym6lxvXDDUWhZod5CK2FYKqeI(K1DYGEcftsqrZvVjazidaYo9ekMKaIIrFf315cFm7mKZrA)jJDNJPkURZf(y2zihFJ1MyJvTUkwd9zfVId46KUVCfHWvCaxhaeMQZQS4eYRdSfM1TZ62SoMHVSiRt721PHndyD2W9tCD(RQlBP6aISTHz)3usDJ(Cw3IRRBhQdaebUQ6649JvhZT0xNuor21fna2r1fnUjUoC6AGX15iQU2nwBD9NtyCDzlvNStUc3cZ6g95SUfxNZXW662HkURZf(4WOVCfd7fNqUb3ctw3jJrFodqBBik7)MscDBwa6OpNbGjY2ib2rgM3eB8bSNgjWEaNUgyajJuyXYOpNbf5kClmdDBlwONqXKaiPaazsf315cFCy0xUIDgYH3FXjHm4eTatv8koGRtwcHCfK5hxXDDUWhh0kmdTZ5gxNl8n8fNS(EdXGWy61eM1DYikCsopBjvW58kURZf(4GwHzNHCUcrVZ3NmOoUL1DYiQrFodUcrVZ3NmOoUn0TzHEcftsi3gYKqtJBfakdlankkA2xBBsfCPIBDKJnt4Ng40ydzMqwSOHqUcY8h4EsFACK2FpGOgFFmazJPmPId46KYM15kfUohr11TzTo8V2uDzlvh8P6yEZ264qMjCwN8Yl7H6aGWuDm3sFDkj7hRUPJtcvx26FDYsRsDkAU6nRdIQJ5nBH9So)LuNS0QeQ4Uox4JdAfMDgY14iGjLzcrgf5zlRAjAozshfJsmdzyDNmq(Qmue6ZGRu4q3MfGMokgLHCBitcnQLaKg2mGgB4(joOO5Q30ILOWj58SLubemwNyrdBgqJnC)ehu0C1BcqgABtJBfd2MEv0LHjvCaxNu2SUhwNRu46yE586ulvhZB2UFDzlv3twjRt2ykM166yQoG4PSxh8RBaX46yEZwypRZFj1jlTkHkURZf(4GwHzNHCnocyszMqKrrE2Y6ozG8vzOi0NbxPWH9bOSX0OJ8vzOi0NbxPWbvh55cFwIcNKZZwsfqWyDIfnSzan2W9tCqrZvVjazOTnnUvmyB6vrxMkoGRtAURO6Kv8ocjPo4xhBSxh9uZs4qDrJB2wNRuyGCDaqyQUDwx2ssQdNUK6MquDwn71Hjn8v46GO62zDsGDuDpzLSoDRJIr1X8Y51nO6qKRKu3(1LBdv3eIQlBP6EYkzDm7rOqf315cFCqRWSZqUb3vKzY7iKew3jdSnX5M0rXOedqgSXsuJ(CggCxrMjVJqscDBwaAuiFvgkc9zWvkCGSYItSfliFvgkc9zWvkCarn((yaA1wSG8vzOi0NbxPWH9biqzl6AiKRGm)Hb3vKzY7iKKGU1rXiSzICDUW35mbiXgaYKkURZf(4GwHzNHCXAH4KlXGt0cmX6ozeXrRp4uyWDfzM8ocjXGL8Aw0WMb0yd3pXbfnx9MaKHmSp6ZzyGGUcVkk0TR4Uox4JdAfMDgYb8Y57hZGTreX6ozeXrRp4uyWDfzM8ocjXGL8Awak9ekMKqUnKjHMg3kaeaTyHEcftcGKbazsf315cFCqRWSZqUb3vKb1XTSUtgrC06dofgCxrMjVJqsmyjVMf6jumjHCBitcnnUvaOmvCaxhaeE)y1fn0)f3khaOz0XT1T46GpxsDEDriKK6Y9Lu3(Ae5yI16WW62Voe58nLWADsGDzbIQZhyiVNexsDZ9P6syDDmv3M15468665Y3usDyBIZdvCxNl8XbTcZod5I4)IBzDNmIcNKZZwsfCoNLioA9bNcEZOJBnA4R2CHFf315cFCqRWSZqoCRRGm3qCfR7Kru4KCE2sQGZ5SeXrRp4uWBgDCRrdF1Ml8R4Uox4JdAfMDgYzdZf(SUtgJ(CggCiuX74mGixNwSm6ZzWvi6D((Kb1XTHUDfhW1jRCoF)y1nCnW1LW6u0078SUnPM66ypgvXDDUWhh0km7mKRJjZMudRV3qmI4O1hCYSFspEtjMyBmpcKNgiwVCUN7hZGixNqeR7KXOpNHbhcv8oodiY1Pfl52qMeAulbigSXulw0WMb0yd3pXbfnx9MaIbBvCxNl8XbTcZod56yYSj1GzDNmg95mm4qOI3XzarUoTyj3gYKqJAjaXGnMAXIg2mGgB4(joOO5Q3eqmyRI76CHpoOvy2zi3GdHkZSJKuXDDUWhh0km7mKBqimHaE)yvCxNl8XbTcZod5MlIgCiuvXDDUWhh0km7mKZFnHtKZnANZR4Uox4JdAfMDgY1XKztQHvAojDAEVHyOLO5Web)vBgChNSUtgrHtY5zlPcoNZYOpNbxHO357tguh3guqMFwg95m0qnqKedCA4D9Qmke5n4GcY8Zc9ekMKqUnKjHMg3kaukybLdZOpNyabGvCxNl8XbTcZod56yYSj1W67nedxQ4wh5yZe(Pbon2qMjeR7KruJ(CgCfIENVpzqDCBOBZsuJ(CggCxrMjVJqscDBw0qixbz(dUcrVZ3NmOoUnGOgFFmGKbaR4aUUOHessDiypwlxsDOoNQdoRlB7nJDUKQUgpBX1nioKzGCDaqyQUjevNu2dSnuvNgTjR1bZwcX8IP6yEZ26aaaH68So2yk71HtxdmUoiQozyk71X8MT15CmSoP5qOQUUDOI76CHpoOvy2zixhtMnPgwFVHy442i(tydYLkez0qKZzDNmu0OpNbKlviYOHiNBu0OpNbfK53Iffn6ZzqdFvxNBeYSpWgfn6ZzOBZs6OyugAjNNTbBDcizJnwshfJYql58SnyRtaYq2yQflrPOrFodA4R66CJqM9b2OOrFodDBwaQIg95mGCPcrgne5CJIg95mGtxdmazWgtJUmmfiPOrFoddoeQmWPjBjd9uJKq32IL0rXOmKBdzsOrTeGIwMYewg95m4ke9oFFYG642aIA89XaugRUId46KDA6DEw3058HRbUUjevxh7dov3MudouXDDUWhh0km7mKRJjZMudM1DYy0NZWGdHkEhNbe560ILCBitcnQLaed2yQflAyZaASH7N4GIMREtaXGTkEfhW1jRXy61eUI76CHpoqym9AcZqdFn9jYtszMCVHyDNmONqXKeYTHmj004wbGYWsuJ(CggCxrMjVJqscDBwaAukyg0WxtFI8KuMj3BiZOJ(qUAG3pglr56CHFqdFn9jYtszMCVHc7BM8nwBAXYSZ5gePBDumYKBdbOyAvOXTctQ4Uox4JdegtVMWSZqUbhcvg40KTKHEQrcR7KrehT(GtHb3vKzY7iKedwYRzrdHCfK5pmOKzIEt2sgscHdDBwI4O1hCkmsYOHVAZf(vCxNl8XbcJPxty2zixSUJuR)g404sLqWSTI76CHpoqym9AcZod5MqDhtkJlvcTjzgK3W6ozGTjo3KokgL4WG7kYm5DescazWMfliFvgkc9zWvkCyFagTmLLOg95m4ke9oFFYG642q3UI76CHpoqym9AcZod5S7ODkz)yMb3XjR7Kb2M4Ct6OyuIddURiZK3rijaKbBwSG8vzOi0NbxPWH9by0Y0kURZf(4aHX0Rjm7mKlBjt)hW(RmtistSUtgJ(CgqKgyoHXMjePPq32ILrFodisdmNWyZeI0Krd7FsOaoDnWasgMwXDDUWhhimMEnHzNHCO12MtM9nyBxtvCxNl8XbcJPxty2zihZqexfH23Gim89xtSUtgJ(Cg47KgCiufWPRbgqYwf315cFCGWy61eMDgY1qnqKedCA4D9Qmke5nyw3jd6jumjaskaWkEfhW1jR2FXTecxXbCDsNY66GriuDaHu66qecY546yEZ26KDYv4wykhaqt1LiFtCDquDaHE2YjmUoRcI0lEHFOI76CHpom3FXTmguYmrVjBjdjHWSUtgrC06dofgjz0WxT5c)kURZf(4WC)f3Yod5W8vtg)vg1Qjw3jJrFody(QjJ)kJA1uarn((yaLBdzsOrTelJ(CgW8vtg)vg1QPaIA89XacOYWUg2mGgB4(jMjajzcwDf315cFCyU)IBzNHCiiNBYwYmGpHzDNmg95mGGCUjBjZa(eoGOgFFmGyiBwSeXrRp4uaLddIqqoVId46KoL11X8MT1LTuDaanvhaKDDrdGDuDGCIIq1br1j7KRWTWSUe5BIdvCxNl8XH5(lULDgYnOKzIEt2sgscHzDNmCPsOnPGRjt32ib2rgmNOiuGEFWjLflUuj0MuqrUc3cZa9(GtQkURZf(4WC)f3Yod5ul22tDBfVId46atY5zBf315cFCaNKZZwgEZOJBfGrieEHVWA2yQmsjMA1YeTcqMD0VFmSaukRXgIssvhaCDUox4xhFXjouXfG8fNyH8cqcJPxtyH8cRLriVaKEFWjLqAbOgTjHwxaspHIjjKBdzsOPXTsDaSozQJL6IQUrFoddURiZK3rijHUDDSuhqRlQ6uWmOHVM(e5jPmtU3qMrh9HC1aVFS6yPUOQZ15c)Gg(A6tKNKYm5Edf23m5BS2SolwQB25CdI0TokgzYTHQdq1ftRcnUvQJjcqxNl8fGA4RPprEskZK7nKifwZMqEbi9(GtkH0cqnAtcTUamIJwFWPWG7kYm5DesIbl511XsDAiKRGm)HbLmt0BYwYqsiCOBxhl1fXrRp4uyKKrdF1Ml8fGUox4lahCiuzGtt2sg6PgjIuyTSjKxa66CHVamw3rQ1FdCACPsiy2kaP3hCsjKwKcRLcH8cq69bNucPfGA0MeADbi2M4Ct6OyuIddURiZK3rij1bqg1XwDwSuhYxLHIqFgCLch2Voawx0Y06yPUOQB0NZGRq0789jdQJBdDBbORZf(cWju3XKY4sLqBsMb5nIuynakKxasVp4KsiTauJ2KqRlaX2eNBshfJsCyWDfzM8ocjPoaYOo2QZIL6q(Qmue6ZGRu4W(1bW6IwMkaDDUWxaA3r7uY(XmdUJtrkSoAfYlaP3hCsjKwaQrBsO1fGJ(CgqKgyoHXMjePPq3UolwQB0NZaI0aZjm2mHinz0W(NekGtxdCDaQozyQa015cFby2sM(pG9xzMqKMePWAayH8cqxNl8fGO12MtM9nyBxtcq69bNucPfPWARwiVaKEFWjLqAbOgTjHwxao6ZzGVtAWHqvaNUg46auDYMa015cFbiZqexfH23Gim89xtIuyTusiVaKEFWjLqAbOgTjHwxaspHIjPoavNuaGcqxNl8fGnudejXaNgExVkJcrEdwKIuaQOP35PqEH1YiKxasVp4KsiTauJ2KqRlaJQoCsopBjvabJ1jbORZf(cqGxnWIuynBc5fGUox4laXj58SvasVp4KsiTifwlBc5fG07doPeslaH2cqmLcqxNl8fGrC06dojaJ48ojar5Wm6ZjUoavhB1XsDaTUrFodCORiLrTAk0TRZIL6IQUrFodXq(RmneNOq3UowQlQ6g95mG6zlNWyJnI0lEHFOBxhteGrCK59gsaIYHbriiNlsH1sHqEbi9(GtkH0cqOTaetPa015cFbyehT(GtcWioVtcquomJ(CIRdq1XwDSuhqRB0NZah6kszuRMcD76SyPUrFodOE2Yjm2yJi9Ix4hquJVpUoaXOoneYvqM)WGsMj6nzlzijeoGOgFFCDmraQrBsO1fGUuj0MuqrUc3cZa9(GtQ6SyPoxQeAtk4AY0TnsGDKbZjkcfO3hCsjaJ4iZ7nKaeLddIqqoxKcRbqH8cq69bNucPfGqBbiMsbORZf(cWioA9bNeGrCENeGOCyg95exhGQJnbOgTjHwxa6sLqBsb87atgscHdi)bUoaYOo2eGrCK59gsaIYHbriiNlsH1rRqEbi9(GtkH0cqOTaerykfGUox4laJ4O1hCsagXrM3BibikhgeHGCUauJ2KqRlaDPsOnPa(DGjdjHWbK)axhazuhB1XsDJ(CgWVdmzijeoGtxdCDaKrDSvx0RB0NZWabDfEvuOBlsH1aWc5fG07doPeslaH2cqmLcqxNl8fGrC06dojaJ48ojar5Wm6ZjUUOx3OpNbmWDo34VYOrqmEaFch621bO6yRowQdO1n6ZzGdDfPmQvtHUDDwSuxu1n6ZzigYFLPH4ef621XsDrv3OpNbupB5egBSrKEXl8dD76yPUOQB0NZWabDfEvuOBxhteGA0MeADb4OpNHb3vKzY7iKKq3wagXrM3BibikhgeHGCUifwB1c5fG07doPeslaH2cqmLcqxNl8fGrC06dojaJ48oja1WMb0yd3pXbfnx9M1bqg1XwDSxhB1bKQdO1LoN(meRfItUedorlWuGEFWjvDSuNgc5kiZFiwleNCjgCIwGPaIA89X1bO6KPoMuh71n6ZzyGGUcVkk0TRJL6ONqXKuhaRlAzADSuxu1n6ZzadCNZn(RmAeeJhWNWHUDDSuxu1n6ZzayISnsGDKH5nXgFa7PrcSh62cWioY8Edja9Mrh3A0WxT5cFrkSwkjKxasVp4KsiTaeAlaXukaDDUWxagXrRp4KamIZ7KaC0NZaQNTCcJn2isV4f(HUDDwSuhqRZLkH2KckYv4wygO3hCsvNfl15sLqBsbxtMUTrcSJmyorrOa9(GtQ6ysDSu3OpNbeKZnzlzgWNWHUTamIJmV3qcWrsgn8vBUWxKcRLHPc5fG07doPeslaH2cqmLcqxNl8fGrC06dojaJ48ojaX2eNBshfJsCyWDfzM8ocjPoavhB1XsDiFvgkc9zWvkCy)6ayDSX06SyPUrFoddURiZK3rijHUTamIJmV3qcWb3vKzY7iKedwYRfPWAzKriVaKEFWjLqAbOgTjHwxaItY5zlPcoNlaDDUWxaQDo346CHVHV4uaYxCAEVHeG4KCE2ksH1YWMqEbi9(GtkH0cqxNl8fGANZnUox4B4lofG8fNM3BibOwHfPWAzKnH8cq69bNucPfGA0MeADbOg2mGgB4(jUoaYOoTTPXTIbBtVQUOxhqRB0NZWabDfEvuOBxh71n6ZzaABdrz)3usOBxhtQdivhqRlDo9ziA2xnWgfYzoqVp4KQowQdO1fvDPZPpdnocyszMqKrrE2gO3hCsvNfl1PHqUcY8hACeWKYmHiJI8SnGOgFFCDaSozQJj1XK6as1b06CPsOnPGRjt32ib2rgmNOiua5pW1bO6yRolwQlQ60qixbz(ddkzMO3KTKHKq4q3UolwQlQ6g95mGGCUjBjZa(eo0TRJjcqxNl8fGO(BCDUW3WxCka5lonV3qcW5(lUvKcRLrkeYlaP3hCsjKwa66CHVau7CUX15cFdFXPaKV408Edjah9LRePWAzaqH8cq69bNucPfGA0MeADbi9ekMKGIMREZ6aiJ6KbaRJ96ONqXKequm6fGUox4laDK2FYKqeI(uKcRLjAfYlaDDUWxa6iT)KXUZXKaKEFWjLqArkSwgayH8cqxNl8fG8nwBInw16Qyn0Ncq69bNucPfPifG2isdBgEkKxyTmc5fGUox4laTH5cFbi9(GtkH0IuynBc5fG07doPeslaDDUWxa24iGjLzcrgf5zRauJ2KqRlar(Qmue6ZGRu4W(1bW6KcMkaTrKg2m80Gjn8vybiaksH1YMqEbi9(GtkH0cqnAtcTUaeO1fvDu0SV22Kkyd1atjELkPmAyJDp9CHVrrrwnvNfl1fvDAiKRGm)bTenhMi4VAZG74mO6ipx4xNfl1H8vzOi0NH9J05pH8bNcKvwCIRJjcqxNl8fG4KCE2ksH1sHqEbi9(GtkH0cqxNl8fGiiNBYwYmGpHfG2isdBgEAWKg(kSaKnrkSgafYlaP3hCsjKwa66CHVaeZxnz8xzuRMeG2isdBgEAWKg(kSaKnrkSoAfYlaP3hCsjKwa66CHVa0vi6D((Kb1XTcqnAtcTUaeO1fvDu0SV22Kkyd1atjELkPmAyJDp9CHVrrrwnvNfl1fvDAiKRGm)bTenhMi4VAZG74mO6ipx4xNfl1H8vzOi0NH9J05pH8bNcKvwCIRJjcqBePHndpnysdFfwakJifwdalKxasVp4KsiTa89gsa6sf36ihBMWpnWPXgYmHeGUox4laDPIBDKJnt4Ng40ydzMqIuyTvlKxasVp4KsiTa015cFbOwIMdte8xTzWDCka1Onj06cWOQd5RYqrOpd7hPZFc5dofiRS4elaP5K0P59gsaQLO5Web)vBgChNIuKcWrF5kH8cRLriVaKEFWjLqAbOgTjHwxao6ZzaABdrz)3usOBxhl1b06g95mamr2gjWoYW8MyJpG90ib2d401axhGQtgPOolwQB0NZGICfUfMHUDDwSuh9ekMK6auDsbawhteGUox4laTxCc5gClmfPWA2eYlaDDUWxaI3FXjHm4eTatcq69bNucPfPifG4KCE2kKxyTmc5fGUox4la9Mrh3kaP3hCsjKwKIuaQvyH8cRLriVaKEFWjLqAbOgTjHwxagvD4KCE2sQGZ5cqxNl8fGANZnUox4B4lofG8fNM3BibiHX0RjSifwZMqEbi9(GtkH0cqnAtcTUamQ6g95m4ke9oFFYG642q3UowQJEcftsi3gYKqtJBL6ayDYuhl1b06IQokA2xBBsfCPIBDKJnt4Ng40ydzMq1zXsDAiKRGm)bUN0NghP93diQX3hxhaRJnMwhteGUox4laDfIENVpzqDCRifwlBc5fG07doPeslaDDUWxa24iGjLzcrgf5zRauJ2KqRlar(Qmue6ZGRu4q3UowQdO1LokgLHCBitcnQLQdq1PHndOXgUFIdkAU6nRZIL6IQoCsopBjvabJ1P6yPonSzan2W9tCqrZvVzDaKrDABtJBfd2MEvDrVozQJjcqTenNmPJIrjwyTmIuyTuiKxasVp4KsiTauJ2KqRlar(Qmue6ZGRu4W(1bW6KnMwx0Rd5RYqrOpdUsHdQoYZf(1XsDrvhojNNTKkGGX6uDSuNg2mGgB4(joOO5Q3SoaYOoTTPXTIbBtVQUOxNmcqxNl8fGnocyszMqKrrE2ksH1aOqEbi9(GtkH0cqnAtcTUaeBtCUjDumkX1bqg1XwDSuxu1n6ZzyWDfzM8ocjj0TRJL6aADrvhYxLHIqFgCLchiRS4exNfl1H8vzOi0NbxPWbe147JRdG1z11zXsDiFvgkc9zWvkCy)6ayDaTo2Ql61PHqUcY8hgCxrMjVJqsc6whfJWMjY15cFNxhtQdivhBayDmra66CHVaCWDfzM8ocjrKcRJwH8cq69bNucPfGA0MeADbyehT(GtHb3vKzY7iKedwYRRJL60WMb0yd3pXbfnx9M1bqg1jtDSx3OpNHbc6k8QOq3wa66CHVamwleNCjgCIwGjrkSgawiVaKEFWjLqAbOgTjHwxagXrRp4uyWDfzM8ocjXGL866yPoGwh9ekMKqUnKjHMg3k1bW6aW6SyPo6jumj1bO6KbaRJjcqxNl8fGaVC((XmyBerIuyTvlKxasVp4KsiTauJ2KqRlaJ4O1hCkm4UImtEhHKyWsEDDSuh9ekMKqUnKjHMg3k1bW6Kra66CHVaCWDfzqDCRifwlLeYlaP3hCsjKwaQrBsO1fGrvhojNNTKk4CEDSuxehT(GtbVz0XTgn8vBUWxa66CHVamI)lUvKcRLHPc5fG07doPesla1Onj06cWOQdNKZZwsfCoVowQlIJwFWPG3m64wJg(Qnx4laDDUWxaIBDfK5gIRePWAzKriVaKEFWjLqAbOgTjHwxao6ZzyWHqfVJZaICDwNfl1n6ZzWvi6D((Kb1XTHUTa015cFbOnmx4lsH1YWMqEbi9(GtkH0cqxNl8fGrC06doz2pPhVPetSnMhbYtdeRxo3Z9JzqKRtisaQrBsO1fGJ(CggCiuX74mGixN1zXsD52qMeAulvhGyuhBmTolwQtdBgqJnC)ehu0C1BwhGyuhBcW3BibyehT(GtM9t6XBkXeBJ5rG80aX6LZ9C)yge56eIePWAzKnH8cq69bNucPfGA0MeADb4OpNHbhcv8oodiY1zDwSuxUnKjHg1s1big1XgtRZIL60WMb0yd3pXbfnx9M1big1XMa015cFbyhtMnPgSifwlJuiKxa66CHVaCWHqLz2rseG07doPeslsH1YaGc5fGUox4lahectiG3pMaKEFWjLqArkSwMOviVa015cFb4Cr0GdHkbi9(GtkH0IuyTmaWc5fGUox4la9xt4e5CJ25Cbi9(GtkH0IuyTmwTqEbi9(GtkH0cqxNl8fGAjAomrWF1Mb3XPauJ2KqRlaJQoCsopBjvW586yPUrFodUcrVZ3NmOoUnOGm)1XsDJ(CgAOgisIbon8UEvgfI8gCqbz(RJL6ONqXKeYTHmj004wPoawNuuhl1HYHz0NtCDaQoauasZjPtZ7nKaulrZHjc(R2m4oofPWAzKsc5fG07doPeslaDDUWxa6sf36ihBMWpnWPXgYmHeGA0MeADbyu1n6ZzWvi6D((Kb1XTHUDDSuxu1n6ZzyWDfzM8ocjj0TRJL60qixbz(dUcrVZ3NmOoUnGOgFFCDaQozaqb47nKa0LkU1ro2mHFAGtJnKzcjsH1SXuH8cq69bNucPfGUox4laDCBe)jSb5sfImAiY5cqnAtcTUaurJ(CgqUuHiJgICUrrJ(CguqM)6SyPofn6ZzqdFvxNBeYSpWgfn6ZzOBxhl1LokgLHwY5zBWwN1bO6Kn2QJL6shfJYql58SnyRZ6aiJ6KnMwNfl1fvDkA0NZGg(QUo3iKzFGnkA0NZq3UowQdO1POrFodixQqKrdro3OOrFod401axhazuhBmTUOxNmmToGuDkA0NZWGdHkdCAYwYqp1ij0TRZIL6shfJYqUnKjHg1s1bO6IwMwhtQJL6g95m4ke9oFFYG642aIA89X1bW6KXQfGV3qcqh3gXFcBqUuHiJgICUifwZMmc5fG07doPesla1Onj06cWrFoddoeQ4DCgqKRZ6SyPUCBitcnQLQdqmQJnMwNfl1PHndOXgUFIdkAU6nRdqmQJnbORZf(cWoMmBsnyrksb4C)f3kKxyTmc5fG07doPesla1Onj06cWioA9bNcJKmA4R2CHVa015cFb4GsMj6nzlzijewKcRztiVaKEFWjLqAbOgTjHwxao6ZzaZxnz8xzuRMciQX3hxhGQl3gYKqJAP6yPUrFody(QjJ)kJA1uarn((46auDaTozQJ960WMb0yd3pX1XK6as1jtWQfGUox4laX8vtg)vg1QjrkSw2eYlaP3hCsjKwaQrBsO1fGJ(Cgqqo3KTKzaFchquJVpUoaXOozRolwQlIJwFWPakhgeHGCUa015cFbicY5MSLmd4tyrkSwkeYlaP3hCsjKwaQrBsO1fGUuj0MuW1KPBBKa7idMtuekqVp4KQolwQZLkH2KckYv4wygO3hCsjaDDUWxaoOKzIEt2sgscHfPWAauiVa015cFbOAX2EQBfG07doPeslsrksbO3ZwisacUnYsrksHa]] )


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