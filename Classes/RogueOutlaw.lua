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


    spec:RegisterPack( "Outlaw", 20190811, [[daLwgbqirPEKQeBcf1NisrJcfXPqrAvePWRqPmlus3suIDjYVikgMQOogkXYisEgrvzAQcLRjkPTrKsFtviACQcPZruvzDQsI5PkY9qH9Pk4GQcvlKO0djQctKOkDrvHWgPKQ8rIQQ0jvLuzLsrVuvsvZKOQk6MQskTtkj)uvsXqjQIokrvvyPQsspvvnvIkxLsQQTsjvOVsjv0yjQQQolLub7fv)LIbRYHPAXk8ysnzsUmYMv0NLcJwkDALwnrvv51QsnBc3wuTBGFdA4uQJtjvA5qEoutx46s12ffFhLQXtjLZteRNivZNsSFjZzHlh)R8G4wj1ZSi)E(rzHLelsBwZAw5)qInX)2U(T3G4FGNt8)RPhcND(32LiGUIlh)JHDKM4)2iSXVImY0yJ2(iPH5YG38UWJfc0iFgYG3CTm8)OVI41b4d(x5bXTsQNzr(98JYcljwK2S(Susl)JTjn3kPK2N5)2vPiaFW)kcR5)xQ710dHZEDVkSrNQMVuxBe24xrgzASrBFK0WCzWBEx4XcbAKpdzWBUwMQ5l1949gDCuhlSWADs9mlYV6YsDSiTVswFUAwnFPo5rRdAq4xPA(sDzPUhxPivDV(v)UUawNIMExe156yHG6elosvZxQll194kfPQZgrAy(WJ6Kv4kQoRNOJqsQJjkiHbsZOUbI8319dYfrlttvZxQll1jVqG0mQRJP6c0cEtbUUfuhoixeTPQ5l1LL6KxiqAg11XuD5l4vK)x3eIQ716O3KQUjevN8sE0wht2qAIRdaJ6WDBBikifttvZxQll19QKWTwDV(viwqJ6(2iIsvZxQll1z9XuDXMtMaAulv3eIQJaAyheeQocOwqJ6qE0sO6Iwhux4OguKInNmb0OwkX)2i4Cfe))sDVMEiC2R7vHn6u18L6AJWg)kYitJnA7JKgMldEZ7cpwiqJ8zidEZ1YunFPUhV3OJJ6yHfwRtQNzr(vxwQJfP9vY6ZvZQ5l1jpADqdc)kvZxQll194kfPQ71V631fW6u007IOoxhleuNyXrQA(sDzPUhxPivD2isdZhEuNScxr1z9eDessDmrbjmqAg1nqK)UUFqUiAzAQA(sDzPo5fcKMrDDmvxGwWBkW1TG6Wb5IOnvnFPUSuN8cbsZOUoMQlFbVI8)6MquDVwh9Mu1nHO6KxYJ26yYgstCDayuhUBBdrbPyAQA(sDzPUxLeU1Q71VcXcAu33gruQA(sDzPoRpMQl2CYeqJAP6MquDeqd7GGq1ra1cAuhYJwcvx06G6ch1GIuS5KjGg1sPQz18L6EewJ09Gu1nOjer1PH5dpQBqnwaov3JR1KDGRdabzP1r5ZUOoxhleGRdcessvZxQZ1Xcb4KnI0W8HhmMch)UA(sDUowiaNSrKgMp8GngY49g5ei8yHGQ5l156yHaCYgrAy(Wd2yiZecvvZxQ7dCBClmQd5RQUrFojvD4WdCDdAcruDAy(WJ6guJfGRZbQ6SruwSHrSGg1T46uqaLQMVuNRJfcWjBePH5dpyJHmyGBJBHHbhEGRMUowiaNSrKgMp8GngYydJfcQMUowiaNSrKgMp8GngYK7O3KYmHiJI8OLvBePH5dpmysdbkmJSY6ozG8vzOmeisUsHtl4Hh75QPRJfcWjBePH5dpyJHm4GCr0Y6ozWKSjRBFTTjvYgQFtbELoPmAyUDp8yHaJIYSAYILS1qOqbzhK0s0cyGGGvBgchhjvh5XcbwSG8vzOmeislitxaiKpeuIS2IdmtRMUowiaNSrKgMp8GngYGGcHjAjZacimR2isdZhEyWKgcuygsvnDDSqaozJinmF4bBmKblwnzCGYOwnXQnI0W8HhgmPHafMHuvtxhleGt2isdZhEWgdzCfIaUybKb1XTSAJinmF4HbtAiqHzWcR7KbtYMSU912MujBO(nf4v6KYOH529WJfcmkkZQjlwYwdHcfKDqslrlGbccwTziCCKuDKhleyXcYxLHYqGiTGmDbGq(qqjYAloWmTA66yHaCYgrAy(Wd2yithtMnOCwbEoXWLoU1ro2mHGWaNgBi7eQA66yHaCYgrAy(Wd2yithtMnOCwP5K0Hb45edTeTagiiy1MHWXbR7Kr2iFvgkdbI0cY0fac5dbLiRT4axnRMVu3JWAKUhKQokdHKuxS5uDrlvNRdiQUfxNNXxHpeuQA(sDVkHdYfrBD7SoBigVdbvhtaW6Y0fac5dbvhbO8LW1TG60W8HhmTA66yHamJ3R(nR7Kr24GCr0sQec2OtvtxhleGzGdYfrB18L6EvcbfI6MquDsXwDJ(CIRJ9nARt(tORivDY7QP662P6EnrlHyFXuDicbfI6MquDsXwDquDYFroqv3RLeevhev3R2JwbHX1jprKEXleKQMUowiaZgdzY4O1hcIvGNtmqXWGieuiynJl6edummJ(CIFskMzYOpNjb0vKYOwnL62wSK9OpNPgihOm5KGOu3M5Sh95mH6rRGWyJnI0lEHGu3MPvZxQ7vjeuiQBcr1jfB1n6ZjUoiQUxThTccJRtEIi9IxiOo23OTo5LCfUfg1br194AQUUDDsGDuDFbrzOu101Xcby2yitghT(qqSc8CIbkggeHGcbRqBgykyDNmCPtOnOKICfUfgjc4dbPSyXLoH2GsUMmDBJeyhzWcIYqjc4dbPynJl6edummJ(CIFskMzYOpNjb0vKYOwnL62wSm6Zzc1JwbHXgBePx8cbjeL7la)ednekuq2bPbfSteWeTKHKq4eIY9fGzA18L6KIT6(a)nv3JqcHFL6ECb7UeCDicbfI6MquDsXwDJ(CItvtxhleGzJHmzC06dbXkWZjgOyyqeckeScTzGPG1DYWLoH2GsyG)MmKecNqo49dmKI1mUOtmqXWm6Zj(jPQMVuNuSv3h4VP6Eesi8RuN8cRdaJ6qecke1X(gT1jfB1Hdx)gxhCwx0s19b(BQUhHecx3OpN1XewyRoC4631X(gT1jlc6k8QO662mnvnDDSqaMngYKXrRpeeRapNyGIHbriOqWk0MbIWuW6oz4sNqBqjmWFtgscHtih8(bgsX8OpNjmWFtgscHt4W1VFGHuzz0NZ0abDfEvuQBxnFPoRZnARtwHRO6SEIocjPUUnR1TnaqevhQliCD(aMHQZbQ6c)nvhLHqsI2f0OUO1J6wCDsXwDmbaJ60WoiwqJ6(U8GP1br1HxqdbvNSFwRt(7RL16Ev5z101Xcby2yitghT(qqSc8CIbkggeHGcbRqBgykyDNmg95mneUImtrhHKK62SMXfDIbkgMrFoXzz0NZe(Dximoqz0iigpGacN62pjfZmz0NZKa6kszuRMsDBlwYE0NZudKduMCsquQBZC2J(CMq9OvqySXgr6fVqqQBZC2J(CMgiORWRIsDBMwnDDSqaMngYKXrRpeeRapNy45JoU1OHa1gleWAgx0jgAy(aASHliWjfnx9gpWqk2KsAWKWfeisnAH4qiXGd0(MseWhcsXSgcfki7GuJwioesm4aTVPeIY9fGFIfMY2OpNPbc6k8QOu3MzcqOgsEqAFM5Sh95mHF3fcJdugncIXdiGWPUnZzp6Zz6nr2gjWoYW(gyJpG9Wib2tD7QPRJfcWSXqMmoA9HGyf45eJrqgneO2yHawZ4IoXy0NZeQhTccJn2isV4fcsDBlwyIlDcTbLuKRWTWiraFiiLflU0j0guY1KPBBKa7idwqugkraFiiftzE0NZeckeMOLmdiGWPUD18L6So3OTU8UiwBbvx4OguGzTUODX1LXrRpeuDlUoDlPFtQ6cyDksVkQo2BPOLq1HH5uDYd5fxhUf2fQ6guDyjanPQJ9nARtwHRO6SEIocjPA66yHamBmKjJJwFiiwbEoXyiCfzMIocjXGLa0SMXfDIb2Mect4OguGtdHRiZu0rijpjfZiFvgkdbIKRu40cEqQNTyz0NZ0q4kYmfDessQBxnDDSqaMngYODHW46yHaJyXbRapNyGdYfrlR7KboixeTKk5cr101Xcby2yiJ2fcJRJfcmIfhSc8CIHwHRMVuN1BblUTopQl3T2M3ZRtEipt197dCGCDuheq1nHO6ix3wNSiORWRIQZbQ6En22qu0bBiPo2BjqDYF0x976KxKZEDlUomjiDqQ6CGQUx7uERBX1bGrDiYvsQZNbHQlAP6aK1I6WKgcuPQPRJfcWSXqguhyCDSqGrS4GvGNtmMlyXTSUtgAy(aASHliWpWqBBYDRzW2eqLfMm6ZzAGGUcVkk1TzB0NZe02gIIoydjPUntLgmjCbbIK1TV63gfYzpraFiifZmj7Wfeis5o6nPmtiYOipAteWhcszXIgcfki7GuUJEtkZeImkYJ2eIY9fGFGfMY0QPRJfcWSXqgTlegxhleyeloyf45eJrFfQQPRJfcWSXqghPDazcicrGG1DYGaeQHKKIMREJhyWswzJaeQHKeIAqGQPRJfcWSXqghPDazS7cmvnDDSqaMngYi2gTb2i)RRAKtGOAwnFPoz7RqriC18L6S(yQo55IdOOUFlmQBN1TrDSdbsZOoTBxNgMpG1zdxqGRZbQ6IwQUxJTnm6GnKu3OpN1T4662P6E8mWvvxhVGg1XElbQ71tKDDwhGDuDwNBGRdhU(nUohr11UnARRdeegxx0s1jVKRWTWOUrFoRBX15cmSUUDQA66yHaCA0xHIH9IdOWGBHbR7KXOpNjOTnefDWgssDBMzYOpNP3ezBKa7id7BGn(a2dJeypHdx)(jwE2ILrFotkYv4wyK62wSqac1qYtpwwzA101Xcb40OVcfBmKbVGfheYGd0(MQMvZxQtEaHcfKDaUA66yHaCsRWm0UqyCDSqGrS4GvGNtmimMaAcZ6ozKnoixeTKk5cr101Xcb4KwHzJHmUcraxSaYG64ww3jJSh95m5kebCXcidQJBtDBMjaHAijfBozcOj3T2dSWmtYMSU912Mujx64wh5yZeccdCASHStilw0qOqbzhKeEqGW4iTd8eIY9fGFqQNzA18L6EDZ6CLcxNJO662SwhgS2uDrlvheq1X(gT1jGSt4Oo5KtEt1z9XuDS3sG6uswqJ6MooiuDrRdQtEipRtrZvVrDquDSVrlSh15aj1jpKNPQPRJfcWjTcZgdzYD0BszMqKrrE0YQwIwqMWrnOaZGfw3jdKVkdLHarYvkCQBZmtch1GIuS5KjGg1spPH5dOXgUGaNu0C1ByXs24GCr0sQec2OtmRH5dOXgUGaNu0C1B8adTTj3TMbBtavwyHPvZxQ71nRdaRZvkCDSVcrDQLQJ9nAxqDrlvhGSwuN89mM166yQUx7uERdcQBaX46yFJwypQZbsQtEiptvtxhleGtAfMngYK7O3KYmHiJI8OL1DYa5RYqziqKCLcNwWdY3Zzb5RYqziqKCLcNuDKhleWC24GCr0sQec2OtmRH5dOXgUGaNu0C1B8adTTj3TMbBtavwyPA(sDYkCfvN1t0rij1bb1jfB1rakFjCQoRZnARZvk8RuN1ht1TZ6IwssD4WLu3eIQ7rzRomPHafUoiQUDwNeyhvhGSwuNU1rnO6yFfI6guDiYvsQBb1fBov3eIQlAP6aK1I6y3ZqPQPRJfcWjTcZgdzgcxrMPOJqsyDNmW2Kqych1Gc8dmKI5Sh95mneUImtrhHKK62mZKSr(QmugcejxPWjYAloWwSG8vzOmeisUsHtik3xa(Hh1IfKVkdLHarYvkCAbpWePYIgcfki7G0q4kYmfDesss36Oge2mrUowiWfmvAivwzA101Xcb4KwHzJHmnAH4qiXGd0(MyDNmY4O1hckneUImtrhHKyWsaAM1W8b0ydxqGtkAU6nEGblSn6ZzAGGUcVkk1TRMUowiaN0kmBmK59kelOHbBJiI1DYiJJwFiO0q4kYmfDesIblbOzMjeGqnKKInNmb0K7w7HSAXcbiudjpXswzA101Xcb4KwHzJHmdHRidQJBzDNmY4O1hckneUImtrhHKyWsaAMjaHAijfBozcOj3T2dSunFPoRpEbnQZ6OdwCRmpE(OJBRBX1bbcj151LHqsQlwGK6wGgroMyTomSUfuhICXgsyTojWU0er15dmu0dsiPU5cO6cyDDmv3g1546866Xk2qsDyBsisvtxhleGtAfMngYKXblUL1DYiBCqUiAjvYfcMZ4O1hck55JoU1OHa1gleunDDSqaoPvy2yidU1vq2ZjHI1DYiBCqUiAjvYfcMZ4O1hck55JoU1OHa1gleunDDSqaoPvy2yiJnmwiG1DYy0NZ0qaHkrhhje56WILrFotUcraxSaYG642u3UA(sDwpxiwqJ6gU(DDbSofn9UiQBdkVUo2BqvtxhleGtAfMngY0XKzdkNvGNtmY4O1hcYSGGa4nKyASn8mqryGy9keESGgge56aIyDNmg95mneqOs0XrcrUoSyj2CYeqJAPNyi1ZwSOH5dOXgUGaNu0C1B8edPQMUowiaN0kmBmKPJjZguoM1DYy0NZ0qaHkrhhje56WILyZjtanQLEIHupBXIgMpGgB4ccCsrZvVXtmKQA66yHaCsRWSXqMHacvMzhjPA66yHaCsRWSXqMbHWe69cAunDDSqaoPvy2yiZCr0qaHQQPRJfcWjTcZgdzCGMWbYfgTlevtxhleGtAfMngY0XKzdkNvAojDyaEoXqlrlGbccwTziCCW6ozKnoixeTKk5cbZJ(CMCfIaUybKb1XTjfKDaZJ(CMYPCisIbonIUEvgfI8CCsbzhWmbiudjPyZjtan5U1E4XygfdZOpN4NYA101Xcb4KwHzJHmDmz2GYzf45edx64wh5yZeccdCASHStiw3jJSh95m5kebCXcidQJBtDBMZE0NZ0q4kYmfDessQBZSgcfki7GKRqeWflGmOoUnHOCFb4NyjRvZxQZ6iHKuhc2B0kKuhQlO6GZ6I2E(yNlPQl3JwCDdsaz)vQZ6JP6MquDVoWBBOQonAdwRdgTeI9ft1X(gT194VADEuNupZwD4W1VX1br1XYZSvh7B0wNlWW6KvaHQ662PQPRJfcWjTcZgdz6yYSbLZkWZjgoUnJdiSb5shImAiYfSUtgkA0NZeYLoez0qKlmkA0NZKcYoWIffn6ZzsdbQUo2mKzbVnkA0NZu3M5WrnOi1sUiAt264j5tkMdh1GIul5IOnzRJhyiFpBXs2kA0NZKgcuDDSziZcEBu0OpNPUnZmrrJ(CMqU0HiJgICHrrJ(CMWHRF)adPEolS8S0qrJ(CMgciuzGtt0sgcq5ssDBlwch1GIuS5KjGg1spjTpZuMh95m5kebCXcidQJBtik3xa(bwE0Q5l1jV007IOUPledx)UUjevxh7dbv3guoovnDDSqaoPvy2yithtMnOCmR7KXOpNPHacvIoosiY1HflXMtMaAul9edPE2IfnmFan2Wfe4KIMREJNyiv1SA(sDpcmMaAcxnDDSqaorymb0eMHgc0eiqEqkZu45eR7KbbiudjPyZjtan5U1EGfMZE0NZ0q4kYmfDessQBZmtYwbJKgc0eiqEqkZu45Kz0rGuS63lObZz76yHGKgc0eiqEqkZu45uAbMPyB0gwSm7cHbr6wh1GmXMtp1qRs5U1yA101Xcb4eHXeqty2yiZqaHkdCAIwYqakxcR7KrghT(qqPHWvKzk6iKedwcqZSgcfki7G0Gc2jcyIwYqsiCQBZCghT(qqPrqgneO2yHGQPRJfcWjcJjGMWSXqMgDhPwhyGtJlDcbJ2QPRJfcWjcJjGMWSXqMju3XKY4sNqBqMb55SUtgyBsimHJAqboneUImtrhHK8adPSyb5RYqziqKCLcNwWds7ZmN9OpNjxHiGlwazqDCBQBxnDDSqaorymb0eMngYy3r7uYcAygchhSUtgyBsimHJAqboneUImtrhHK8adPSyb5RYqziqKCLcNwWds7ZvtxhleGtegtanHzJHmrlz6GbSduMjePjw3jJrFotis)wqySzcrAk1TTyz0NZeI0VfegBMqKMmAyheekHdx)(jwEUA66yHaCIWycOjmBmKbT22cYSad221u101Xcb4eHXeqty2yid7qKqLHwGbryiWbAI1DYy0NZKyN0qaHQeoC97NKVQPRJfcWjcJjGMWSXqMCkhIKyGtJORxLrHiphZ6ozqac1qYtpwwRMvZxQZ6TGf3siC18L6KnEe1bZqO6E1q26qecke46yFJ26KxYv4wyiZJRP6cKVbUoiQUxThTccJRtEIi9IxiivnDDSqaonxWIBzmOGDIaMOLmKecZ6ozKXrRpeuAeKrdbQnwiOA66yHaCAUGf3YgdzWIvtghOmQvtSUtgJ(CMWIvtghOmQvtjeL7la)uS5KjGg1smp6ZzclwnzCGYOwnLquUVa8tmHf20W8b0ydxqGzQ0GL0JwnDDSqaonxWIBzJHmiOqyIwYmGacZ6ozm6Zzcbfct0sMbeq4eIY9fGFIH8zXsghT(qqjummicbfIQ5l1jB8iQJ9nARlAP6ECnvN13UoRdWoQUVGOmuDquDYl5kClmQlq(g4u101Xcb40CblULngYmOGDIaMOLmKecZ6oz4sNqBqjxtMUTrcSJmybrzOeb8HGuwS4sNqBqjf5kClmseWhcsvnDDSqaonxWIBzJHmQfB7HUTAwnFPUFqUiARMUowiaNWb5IOLHNp64w(pdHWleWTsQNzr(98JYYZ8p7ocSGgy()1LBdrbPQ7rwNRJfcQtS4aNQM8V3JwiI))BU8G)floWC54FcJjGMWC54wXcxo(Na(qqkUS8VgTbHwN)jaHAijfBozcOj3TwDpuhl1XCDzx3OpNPHWvKzk6iKKu3UoMRJj1LDDkyK0qGMabYdszMcpNmJocKIv)EbnQJ56YUoxhleK0qGMabYdszMcpNslWmfBJ2OolwQB2fcdI0ToQbzInNQ7P6AOvPC3A1Xu(31Xcb8Vgc0eiqEqkZu45ep4wjfxo(Na(qqkUS8VgTbHwN)Z4O1hckneUImtrhHKyWsa66yUonekuq2bPbfSteWeTKHKq4u3UoMRlJJwFiO0iiJgcuBSqa)76yHa(FiGqLbonrlziaLlHhCRKpUC8VRJfc4)gDhPwhyGtJlDcbJw(Na(qqkUS8GB1JXLJ)jGpeKIll)RrBqO15FSnjeMWrnOaNgcxrMPOJqsQ7bg1jvDwSuhYxLHYqGi5kfoTG6EOoP956yUUSRB0NZKRqeWflGmOoUn1T5FxhleW)tOUJjLXLoH2GmdYZ5b3QSYLJ)jGpeKIll)RrBqO15FSnjeMWrnOaNgcxrMPOJqsQ7bg1jvDwSuhYxLHYqGi5kfoTG6EOoP9z(31Xcb8VDhTtjlOHziCCWdUvslxo(Na(qqkUS8VgTbHwN)h95mHi9BbHXMjePPu3UolwQB0NZeI0VfegBMqKMmAyheekHdx)UUNQJLN5FxhleW)rlz6GbSduMjePjEWT6rYLJ)DDSqa)JwBBbzwGbB7AI)jGpeKIllp4w9OC54Fc4dbP4YY)A0geAD(F0NZKyN0qaHQeoC976EQo5J)DDSqa)ZoejuzOfyqegcCGM4b3k5hxo(Na(qqkUS8VgTbHwN)jaHAiPUNQ7XYk)76yHa(pNYHijg40i66vzuiYZX8Gh8VIMExeC54wXcxo(Na(qqkUS8VgTbHwN)ZUoCqUiAjvcbB0j(31Xcb8)7v)MhCRKIlh)76yHa(hhKlIw(Na(qqkUS8GBL8XLJ)jGpeKIll)dT5Fmf8VRJfc4)moA9HG4)mUOt8pkgMrFoX19uDsvhZ1XK6g95mjGUIug1QPu3UolwQl76g95m1a5aLjNeeL621XCDzx3OpNjupAfegBSrKEXleK621Xu(pJJmapN4FummicbfcEWT6X4YX)eWhcsXLL)H28pMc(31Xcb8FghT(qq8Fgx0j(hfdZOpN46EQoPQJ56ysDJ(CMeqxrkJA1uQBxNfl1n6Zzc1JwbHXgBePx8cbjeL7lax3tmQtdHcfKDqAqb7ebmrlzijeoHOCFb46yk)RrBqO15Fx6eAdkPixHBHrIa(qqQ6SyPox6eAdk5AY0TnsGDKblikdLiGpeKI)Z4idWZj(hfddIqqHGhCRYkxo(Na(qqkUS8p0M)XuW)UowiG)Z4O1hcI)Z4IoX)Oyyg95ex3t1jf)RrBqO15Fx6eAdkHb(BYqsiCc5G319aJ6KI)Z4idWZj(hfddIqqHGhCRKwUC8pb8HGuCz5FOn)Jimf8VRJfc4)moA9HG4)moYa8CI)rXWGieui4FnAdcTo)7sNqBqjmWFtgscHtih8UUhyuNu1XCDJ(CMWa)nzijeoHdx)UUhyuNu1LL6g95mnqqxHxfL628GB1JKlh)taFiifxw(hAZ)yk4FxhleW)zC06dbX)zCrN4FummJ(CIRll1n6Zzc)UleghOmAeeJhqaHtD76EQoPQJ56ysDJ(CMeqxrkJA1uQBxNfl1LDDJ(CMAGCGYKtcIsD76yUUSRB0NZeQhTccJn2isV4fcsD76yUUSRB0NZ0abDfEvuQBxht5FnAdcTo)p6ZzAiCfzMIocjj1T5)moYa8CI)rXWGieui4b3QhLlh)taFiifxw(hAZ)yk4FxhleW)zC06dbX)zCrN4FnmFan2Wfe4KIMREJ6EGrDsvhB1jvDsJ6ysDHliqKA0cXHqIbhO9nLiGpeKQoMRtdHcfKDqQrlehcjgCG23ucr5(cW19uDSuhtRJT6g95mnqqxHxfL621XCDeGqnKu3d1jTpxhZ1LDDJ(CMWV7cHXbkJgbX4beq4u3UoMRl76g95m9MiBJeyhzyFdSXhWEyKa7PUn)NXrgGNt8VNp64wJgcuBSqap4wj)4YX)eWhcsXLL)H28pMc(31Xcb8FghT(qq8Fgx0j(F0NZeQhTccJn2isV4fcsD76SyPoMuNlDcTbLuKRWTWiraFiivDwSuNlDcTbLCnz62gjWoYGfeLHseWhcsvhtRJ56g95mHGcHjAjZaciCQBZ)zCKb45e)pcYOHa1gleWdUvS8mxo(Na(qqkUS8p0M)XuW)UowiG)Z4O1hcI)Z4IoX)yBsimHJAqboneUImtrhHKu3t1jvDmxhYxLHYqGi5kfoTG6EOoPEUolwQB0NZ0q4kYmfDessQBZ)zCKb45e)peUImtrhHKyWsaAEWTIfw4YX)eWhcsXLL)1Oni068poixeTKk5cb)76yHa(x7cHX1XcbgXId(xS4Wa8CI)Xb5IOLhCRyrkUC8pb8HGuCz5FxhleW)AximUowiWiwCW)IfhgGNt8VwH5b3kwKpUC8pb8HGuCz5FnAdcTo)RH5dOXgUGax3dmQtBBYDRzW2eqvxwQJj1n6ZzAGGUcVkk1TRJT6g95mbTTHOOd2qsQBxhtRtAuhtQlCbbIK1TV63gfYzpraFiivDmxhtQl76cxqGiL7O3KYmHiJI8OnraFiivDwSuNgcfki7GuUJEtkZeImkYJ2eIY9fGR7H6yPoMwht5FxhleW)OoW46yHaJyXb)lwCyaEoX)ZfS4wEWTILhJlh)taFiifxw(31Xcb8V2fcJRJfcmIfh8VyXHb45e)p6RqXdUvSKvUC8pb8HGuCz5FnAdcTo)tac1qssrZvVrDpWOowYADSvhbiudjje1Ga8VRJfc4FhPDazcicrGGhCRyrA5YX)UowiG)DK2bKXUlWe)taFiifxwEWTILhjxo(31Xcb8VyB0gyJ8VUQrobc(Na(qqkUS8Gh8VnI0W8HhC54wXcxo(31Xcb8VnmwiG)jGpeKIllp4wjfxo(Na(qqkUS8VRJfc4)Ch9MuMjezuKhT8VgTbHwN)r(QmugcejxPWPfu3d19ypZ)2isdZhEyWKgcuy(pR8GBL8XLJ)jGpeKIll)RrBqO15FMux21rw3(ABtQKnu)Mc8kDsz0WC7E4XcbgfLz1uDwSux21PHqHcYoiPLOfWabbR2meoosQoYJfcQZIL6q(QmugcePfKPlaeYhckrwBXbUoMY)UowiG)Xb5IOLhCREmUC8pb8HGuCz5FxhleW)iOqyIwYmGacZ)2isdZhEyWKgcuy(xkEWTkRC54Fc4dbP4YY)UowiG)XIvtghOmQvt8VnI0W8HhgmPHafM)LIhCRKwUC8pb8HGuCz5FxhleW)UcraxSaYG64w(xJ2GqRZ)mPUSRJSU912MujBO(nf4v6KYOH529WJfcmkkZQP6SyPUSRtdHcfKDqslrlGbccwTziCCKuDKhleuNfl1H8vzOmeislitxaiKpeuIS2IdCDmL)TrKgMp8WGjneOW8pl8GB1JKlh)taFiifxw(h45e)7sh36ihBMqqyGtJnKDcX)UowiG)DPJBDKJntiimWPXgYoH4b3QhLlh)taFiifxw(31Xcb8VwIwadeeSAZq44G)1Oni068F21H8vzOmeislitxaiKpeuIS2Idm)tZjPddWZj(xlrlGbccwTziCCWdEW)ZfS4wUCCRyHlh)taFiifxw(xJ2GqRZ)zC06dbLgbz0qGAJfc4FxhleW)dkyNiGjAjdjHW8GBLuC54Fc4dbP4YY)A0geAD(F0NZewSAY4aLrTAkHOCFb46EQUyZjtanQLQJ56g95mHfRMmoqzuRMsik3xaUUNQJj1XsDSvNgMpGgB4ccCDmToPrDSKEu(31Xcb8pwSAY4aLrTAIhCRKpUC8pb8HGuCz5FnAdcTo)p6Zzcbfct0sMbeq4eIY9fGR7jg1jF1zXsDzC06dbLqXWGieui4FxhleW)iOqyIwYmGacZdUvpgxo(Na(qqkUS8VgTbHwN)DPtOnOKRjt32ib2rgSGOmuIa(qqQ6SyPox6eAdkPixHBHrIa(qqk(31Xcb8)Gc2jcyIwYqsimp4wLvUC8VRJfc4F1IT9q3Y)eWhcsXLLh8G)Xb5IOLlh3kw4YX)UowiG)98rh3Y)eWhcsXLLh8G)1kmxoUvSWLJ)jGpeKIll)RrBqO15)SRdhKlIwsLCHG)DDSqa)RDHW46yHaJyXb)lwCyaEoX)egtanH5b3kP4YX)eWhcsXLL)1Oni068F21n6ZzYvic4Ifqguh3M621XCDeGqnKKInNmb0K7wRUhQJL6yUoMux21rw3(ABtQKlDCRJCSzcbHbon2q2juDwSuNgcfki7GKWdceghPDGNquUVaCDpuNupxht5FxhleW)UcraxSaYG64wEWTs(4YX)eWhcsXLL)DDSqa)N7O3KYmHiJI8OL)1Oni068pYxLHYqGi5kfo1TRJ56ysDHJAqrk2CYeqJAP6EQonmFan2Wfe4KIMREJ6SyPUSRdhKlIwsLqWgDQoMRtdZhqJnCbboPO5Q3OUhyuN22K7wZGTjGQUSuhl1Xu(xlrlit4OguG5wXcp4w9yC54Fc4dbP4YY)A0geAD(h5RYqziqKCLcNwqDpuN89CDzPoKVkdLHarYvkCs1rESqqDmxx21HdYfrlPsiyJovhZ1PH5dOXgUGaNu0C1Bu3dmQtBBYDRzW2eqvxwQJf(31Xcb8FUJEtkZeImkYJwEWTkRC54Fc4dbP4YY)A0geAD(hBtcHjCudkW19aJ6KQoMRl76g95mneUImtrhHKK621XCDmPUSRd5RYqziqKCLcNiRT4axNfl1H8vzOmeisUsHtik3xaUUhQ7rRZIL6q(QmugcejxPWPfu3d1XK6KQUSuNgcfki7G0q4kYmfDesss36Oge2mrUowiWf1X06Kg1jvwRJP8VRJfc4)HWvKzk6iKeEWTsA5YX)eWhcsXLL)1Oni068FghT(qqPHWvKzk6iKedwcqxhZ1PH5dOXgUGaNu0C1Bu3dmQJL6yRUrFotde0v4vrPUn)76yHa(VrlehcjgCG23ep4w9i5YX)eWhcsXLL)1Oni068FghT(qqPHWvKzk6iKedwcqxhZ1XK6iaHAijfBozcOj3TwDpuxwRZIL6iaHAiPUNQJLSwht5FxhleW)VxHybnmyBer8GB1JYLJ)jGpeKIll)RrBqO15)moA9HGsdHRiZu0rijgSeGUoMRJaeQHKuS5KjGMC3A19qDSW)UowiG)hcxrguh3YdUvYpUC8pb8HGuCz5FnAdcTo)NDD4GCr0sQKle1XCDzC06dbL88rh3A0qGAJfc4FxhleW)zCWIB5b3kwEMlh)taFiifxw(xJ2GqRZ)zxhoixeTKk5crDmxxghT(qqjpF0XTgneO2yHa(31Xcb8pU1vq2ZjHIhCRyHfUC8pb8HGuCz5FnAdcTo)p6ZzAiGqLOJJeICDuNfl1n6ZzYvic4Ifqguh3M628VRJfc4FBySqap4wXIuC54Fc4dbP4YY)UowiG)Z4O1hcYSGGa4nKyASn8mqryGy9keESGgge56aI4FnAdcTo)p6ZzAiGqLOJJeICDuNfl1fBozcOrTuDpXOoPEUolwQtdZhqJnCbboPO5Q3OUNyuNu8pWZj(pJJwFiiZcccG3qIPX2WZafHbI1Rq4XcAyqKRdiIhCRyr(4YX)eWhcsXLL)1Oni068)OpNPHacvIoosiY1rDwSuxS5KjGg1s19eJ6K656SyPonmFan2Wfe4KIMREJ6EIrDsX)UowiG)7yYSbLJ5b3kwEmUC8VRJfc4)HacvMzhjH)jGpeKIllp4wXsw5YX)UowiG)hectO3lOb)taFiifxwEWTIfPLlh)76yHa(FUiAiGqf)taFiifxwEWTILhjxo(31Xcb8Vd0eoqUWODHG)jGpeKIllp4wXYJYLJ)jGpeKIll)76yHa(xlrlGbccwTziCCW)A0geAD(p76Wb5IOLujxiQJ56g95m5kebCXcidQJBtki7G6yUUrFot5uoejXaNgrxVkJcrEooPGSdQJ56iaHAijfBozcOj3TwDpu3JvhZ1HIHz0NtCDpvxw5FAojDyaEoX)AjAbmqqWQndHJdEWTIf5hxo(Na(qqkUS8VRJfc4Fx64wh5yZeccdCASHSti(xJ2GqRZ)zx3OpNjxHiGlwazqDCBQBxhZ1LDDJ(CMgcxrMPOJqssD76yUonekuq2bjxHiGlwazqDCBcr5(cW19uDSKv(h45e)7sh36ihBMqqyGtJnKDcXdUvs9mxo(Na(qqkUS8VRJfc4Fh3MXbe2GCPdrgne5c(xJ2GqRZ)kA0NZeYLoez0qKlmkA0NZKcYoOolwQtrJ(CM0qGQRJndzwWBJIg95m1TRJ56ch1GIul5IOnzRJ6EQo5tQ6yUUWrnOi1sUiAt26OUhyuN89CDwSux21POrFotAiq11XMHml4TrrJ(CM621XCDmPofn6Zzc5shImAiYfgfn6ZzchU(DDpWOoPEUUSuhlpxN0Oofn6ZzAiGqLbonrlziaLlj1TRZIL6ch1GIuS5KjGg1s19uDs7Z1X06yUUrFotUcraxSaYG642eIY9fGR7H6y5r5FGNt8VJBZ4acBqU0HiJgICbp4wjflC54Fc4dbP4YY)A0geAD(F0NZ0qaHkrhhje56OolwQl2CYeqJAP6EIrDs9CDwSuNgMpGgB4ccCsrZvVrDpXOoP4FxhleW)Dmz2GYX8Gh8)OVcfxoUvSWLJ)jGpeKIll)RrBqO15)rFotqBBik6GnKK621XCDmPUrFotVjY2ib2rg23aB8bShgjWEchU(DDpvhlpxNfl1n6ZzsrUc3cJu3UolwQJaeQHK6EQUhlR1Xu(31Xcb8V9IdOWGBHbp4wjfxo(31Xcb8pEbloiKbhO9nX)eWhcsXLLh8Gh8GhCoa]] )


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