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


    spec:RegisterPack( "Outlaw", 20190728, [[daLUbbqiuKEKQqBIOQprKGrHc1PqrSkIe6vOOMfkPBjfyxI8lIIHHc5yOuwgkXZOevtJOIUMQOSnkr8nIKQXrKOZrKeRtvqMNQi3tvAFsHoOQaTquQEirszIev4IuIsBKij9rkrcoPQOkRKs1lvfvAMQck6MQIQANuc)uvq1qPefhLsKqlvvapvvnvIsxLsKARQck8vvbLglLiPolLir7fv)LIbRYHfwSu9ysnzsUmYMvQplfnAP0PvSAkrsEnky2eUTOA3a)g0WfLJRkQy5q9CitNQRRKTtj9DIuJxkOZteRNOsZNsz)sMZgxw(xfoXTGfgXMuHrsDwKYeBsjlpJ)Djze)NfAgIMe)dICI)F4lxesZ)zHebmuCz5FeCH1e)36Eg6HKrMMJ3U6jnmxg0KVeHpqGghBxg0KRLH)7Rr4ppaVZ)QWjUfSWi2KkmsQZIuMytkzroFMLW)OmsZTGflHr8F7OueG35FfH08)J19WxUiKUUha2CrL9hRR19m0djJmnhVD1tAyUmOjFjcFGano2UmOjxltz)X6SVesQJfPK16yHrSjvQRb1XMu(qSiNL9Y(J1j1Adqtc9qL9hRRb19GkfPQ75oAgQZH1PODSeEDH2hiOoXG8uz)X6AqDpOsrQ6YWKgM3dVo2fHIQtQkwySK6yScsiGuWRRJPGH6(ofcVLjPY(J11G6Kdiqk41TquDoEamqoQUbuhYPq4TPY(J11G6Kdiqk41TquD5d4HSux3gIR75hygivDBiUo5GcVTogpUuavha61HwzzqStkMKk7pwxdQ7bTchvDycdfIb0SUhWzVo1cpGM1XUiuuDsvXcJLuhJxabHq1jnvheiKuxByLQJT68a3KCMKk7pwxdQ7bir0W6EUJqmGM19ZWeLk7pwxdQZsJO68jNmo0OgQUnexhb0WfWjCDeqnGM1HdVLW15TbOopWnjp5tozCOrnuI)ZWW9ii()X6E4lxesx3daBUOY(J116Eg6HKrMMJ3U6jnmxg0KVeHpqGghBxg0KRLPS)yD2xcj1XIuYADSWi2Kk11G6ytkFiwKZYEz)X6KATbOjHEOY(J11G6EqLIu19Chnd15W6u0owcVUq7deuNyqEQS)yDnOUhuPivDzysdZ7Hxh7Iqr1jvflmwsDmwbjeqk411XuWqDFNcH3YKuz)X6AqDYbeif86wiQohpagihv3aQd5ui82uz)X6AqDYbeif86wiQU8b8qwQRBdX198dmdKQUnexNCqH3whJhxkGQda96qRSmi2jftsL9hRRb19GwHJQomHHcXaAw3d4SxNAHhqZ6yxekQoPQyHXsQJXlGGqO6KMQdcesQRnSs1XwDEGBsotsL9hRRb19aKiAyDp3rigqZ6(zyIsL9hRRb1zPruD(KtghAudv3gIRJaA4c4eUocOgqZ6WH3s4682auNh4MKN8jNmo0Ogkv2l7pwNLTHKE5KQUoTHyQonmVhEDDQ5aqP6EqTMYCuDaiObTboFVe1fAFGauDqGqsQS)yDH2hiaLYWKgM3d)DlcedL9hRl0(abOugM0W8E4m)ktSAMtap8bck7pwxO9bcqPmmPH59Wz(vMneQk7pw3hezOwOxhogvD91EtQ6qE4O660gIP60W8E411PMdavxau1LHPgKbDFanRBq1PGakv2FSUq7deGszysdZ7HZ8RmiqKHAHUb5HJk7H2hiaLYWKgM3dN5xzYG(abL9q7deGszysdZ7HZ8Rm5bMbsz2qSrrH3YAgM0W8E4gePHaf69zSo7xCmkdzLaEkukuAankNmQShAFGaukdtAyEpCMFLb5ui8wwN9lJzk9CwtwgPszqndKJg5skJgMNT8WhiWOiRJMSzJPAiuOGsdsAjAb0XqWOnDrG8KAHdFGaB2WXOmKvc4PbyDjaeo6ckrnCqoIjL9q7deGszysdZ7HZ8RmyOqy8wY0HacXAgM0W8E4gePHaf6LLYEO9bcqPmmPH59Wz(vgKy0KjakJA0eRzysdZ7HBqKgcuOxwk7H2hiaLYWKgM3dN5xzcfMaHyaKbVqTSMHjnmVhUbrAiqHEzJ1z)YyMspN1KLrQuguZa5OrUKYOH5zlp8bcmkY6OjB2yQgcfkO0GKwIwaDmemAtxeipPw4WhiWMnCmkdzLaEAawxcaHJUGsudhKJyszp0(abOugM0W8E4m)kZcrMXPCwbro9gYf1g4az2qGBGBtguAcx2dTpqakLHjnmVhoZVYSqKzCkNvAVjTBaro9QLOfqhdbJ20fbYzD2VmfhJYqwjGNgG1Laq4OlOe1Wb5OYEz)X6SSnK0lNu1rwjSK68jNQZBP6cTdX1nO6cRXiIUGsL9hR7biKtHWBRB21LbrOPlO6ymawN1Laq4OlO6iaLpeQUbuNgM3dNjL9q7deGEzy0mW6SFzkYPq4TKkHHnxuzp0(abOxKtHWBl7pw3dqyOqu3gIRJfMRRV2BuDspEBDpmHHIu1jhJMQBLLQ7H7Tew6br1HjmuiQBdX1XcZ1bX1zPaoaQ6E(KGO6G46EGL3kieQoldM0dAGGuzp0(abiMFLXAGNOliwbro9I9UbtyOqWQ1qSOxS3n91EJEIf5zCFT3jbmuKYOgnLwz2SX0(AVtnXbqzYjbrPvM8mTV27eE5TccHmzyspObcsRmMu2FSUhGWqHOUnexhlmxxFT3O6G46EGL3kieQoldM0dAGG6KE826KdkuOwOxhex3dQP6wz1jbUW19fezLsL9q7deGy(vgRbEIUGyfe50l27gmHHcbRWSxe5So73qUeECkPOqHAHEIarxqkB2c5s4XPuOjZkZibUWgKGiRuIarxqkwTgIf9I9UPV2B0tSipJ7R9ojGHIug1OP0kZMT(AVt4L3kieYKHj9GgiiHP8yaONE1qOqbLgK6KlnraJ3sgscHsykpgaIjL9hRJfMR7dcgO6SSsi0dv3dkKoKGQdtyOqu3gIRJfMRRV2BuQShAFGaeZVYynWt0feRGiNEXE3GjmuiyfM9IiN1z)gYLWJtjeiyGmKecLWbGHgFzHvRHyrVyVB6R9g9elL9hRJfMR7dcgO6SSsi0dvNCaRda96Wegke1j94T1XcZ1H8qZaQo4UoVLQ7dcgO6SSsiuD91ExhJzJ56qEOzOoPhVTo2XWqHgfv3kJjPYEO9bcqm)kJ1aprxqScIC6f7DdMWqHGvy2lMqKZ6SFd5s4XPecemqgscHs4aWqJVSiFFT3jeiyGmKecLqEOzOXxwAqFT3Poggk0OO0kRShAFGaeZVYynWt0feRGiNEJ8(c1A0qGA8bcy1Aiw0RgM3HMm4aCusr7rpEJVSWmlsrg7HGaEQzle5cjgKJhgOebIUGuYRHqHckni1SfICHedYXdduct5XaqpXgtyUV27uhddfAuuALjpbiCtjnAjmsEM2x7DcXWsimbqz0yic1HacLwzL9q7deGy(vgRbEIUGyfe50B3jJgcuJpqaRwdXIE7R9oHxERGqitgM0dAGG0kZMnghYLWJtjffkul0tei6cszZwixcpoLcnzwzgjWf2GeezLsei6csXe57R9oHHcHXBjthciuALv2FSUh2XBRlFj8jtq15bUj5iwRZBhuDwd8eDbv3GQt3sAgivDoSofPhfvN0TK3s46qWCQoPMCGQd1cxcvDDQoKeGMu1j94T1XUiuuDsvXcJLu2dTpqaI5xzSg4j6cIvqKtVDrOiZwSWyjgKeGMvRHyrVOmsimEGBsok1fHImBXcJL8elYJJrziReWtHsHsdOrwyKnB91EN6IqrMTyHXssRSYEO9bcqm)kJoectO9bcmIb5ScIC6f5ui8wwN9lYPq4TKkfcrzp0(abiMFLrhcHj0(abgXGCwbro9QvOY(J1jvhWGARl86YJgo5R86KAwMuD)vh54q71bbuDBiUok0T1Xoggk0OO6cGQUhEwge7lW4sQt6wcuNLIRrZqDYboKUUbvhIeK2jvDbqv3ZFlh1nO6aqVomfkj1fBNW15TuDaQHEDisdbQuzp0(abiMFLbVaMq7deyedYzfe507EadQL1z)QH5DOjdoah14RoZKhn0GYiGQbmUV27uhddfAuuALXCFT3jywge7lW4ssRmMifzShcc4PNZA0myu4q6ebIUGuYZyM6HGaEkpWmqkZgInkk82ebIUGu2SPHqHckniLhygiLzdXgffEBct5XaqnYgtyszp0(abiMFLrhcHj0(abgXGCwbro92xJqv2dTpqaI5xzcSoaKXHymbCwN9lbiCtjjfTh94n(Y2ZyMaeUPKeMAsGYEO9bcqm)ktG1bGmzlbIk7H2hiaX8RmIPzRJmwQwQM5eWl7L9hRJ91iuegv2FSolnIQZYmihkQ73c96MDDJxN0qGuWRthz1PH5DyDzWb4O6cGQoVLQ7HNLb9fyCj11x7DDdQUvwQUh0kCu1TqdOzDs3sG6EUeLvNLs4cx3d74O6qEOzavxGP6ANMT1TaccHQZBP6KdkuOwOxxFT31nO6cbcw3klv2dTpqak1xJq9MnihkmOwOZ6SF7R9obZYGyFbgxsALjpJ7R9oXarzgjWf2i94it0Hl3ibUsip0m8eBmYMT(AVtkkuOwONwz2Srac3uYtY5Zyszp0(abOuFncfZVYGgWGCcBqoEyGk7L9hRtQbHcfuAaQShAFGausRqV6qimH2hiWigKZkiYPxcHiGMqSo7xMICkeElPsHqu2dTpqakPviMFLjuyceIbqg8c1Y6SFzAFT3PqHjqigazWluBALjpbiCtjjFYjJdn5rdBKTY(J19821fkfQUat1TYyToeyYO68wQoiGQt6XBRtaLMqEDYkRCKQZsJO6KULa1PKmGM1TdKt4682auNuZYuNI2JE86G46KE8w4YRlasQtQzzsL9q7deGsAfI5xzYdmdKYSHyJIcVLvTeTGmEGBso6LnwN9logLHSsapfkfkTYKNXEGBsEYNCY4qJAON0W8o0KbhGJskAp6XTzJPiNcH3sQeg2CrYRH5DOjdoahLu0E0J34RoZKhn0GYiGQbSXKY(J19821bG1fkfQoPhHOo1q1j94TdOoVLQdqn0RZYzeI16wiQUN)woQdcQRdrO6KE8w4YRlasQtQzzsL9q7deGsAfI5xzYdmdKYSHyJIcVL1z)IJrziReWtHsHsdOrlNrnahJYqwjGNcLcLulC4deiptrofcVLujmS5IKxdZ7qtgCaokPO9OhVXxDMjpAObLravdyRS)yDSlcfvNuvSWyj1bb1XcZ1rakFiuQUh2XBRluk0dvNLgr1n768wssDipKu3gIRtkzUoePHafQoiUUzxNe4cxhGAOxNUnWnP6KEeI66uDykusQBa15tov3gIRZBP6aud96KoSsPYEO9bcqjTcX8RmDrOiZwSWyjSo7xugjegpWnjh14llYZ0(AVtDrOiZwSWyjPvM8mMP4yugYkb8uOuOe1Wb5iB2WXOmKvc4PqPqjmLhda1OuAZgogLHSsapfkfknGgzmlnqdHcfuAqQlcfz2IfgljPBdCtcz24q7deecMifz5zmPShAFGausRqm)ktZwiYfsmihpmqSo7xRbEIUGsDrOiZwSWyjgKeGwEnmVdnzWb4OKI2JE8gFzJ5(AVtDmmuOrrPvwzp0(abOKwHy(vgggHyannOmmrSo7xRbEIUGsDrOiZwSWyjgKeGwEgtac3usYNCY4qtE0WgFMnBeGWnL8eBpJjL9q7deGsAfI5xz6Iqrg8c1Y6SFTg4j6ck1fHImBXcJLyqsaA5jaHBkj5tozCOjpAyJSv2FSolnAanR7HraguRmpyEFHARBq1bbcj1f1zLWsQZhGK6gGgtbIyToeSUbuhMcX4syTojWLuat1fDeuSCsiPU9aO6CyDlev341fO6I6w(igxsDOmsisL9q7deGsAfI5xzSgGb1Y6SFzkYPq4TKkfcH8wd8eDbLI8(c1A0qGA8bck7H2hiaL0keZVYGAdfu6CsOyD2Vmf5ui8wsLcHqERbEIUGsrEFHAnAiqn(abL9q7deGsAfI5xzYG(abSo73(AVtDbeQelKNWuODB26R9ofkmbcXaidEHAtRSY(J1jvdHyanRRhAgQZH1PODSeEDJt51TqrtQShAFGausRqm)kZcrMXPCwbro9AnWt0fKzaobqJlX0CAgwHc3ar6ricFannyk0oeZ6SF7R9o1fqOsSqEctH2TzZNCY4qJAONEzHr2SPH5DOjdoahLu0E0J)0llL9q7deGsAfI5xzwiYmoLJyD2V91EN6ciujwipHPq72S5tozCOrn0tVSWiB20W8o0KbhGJskAp6XF6LLYEO9bcqjTcX8RmDbeQm7fwszp0(abOKwHy(vMoHreMHb0SShAFGausRqm)kZEWuxaHQYEO9bcqjTcX8RmbqtihhcJoeIYEO9bcqjTcX8RmlezgNYzL2Bs7gqKtVAjAb0XqWOnDrGCwN9ltrofcVLuPqiKVV27uOWeiedGm4fQnPGsdKVV27uoLdXsmWTrS0JYOWuKJskO0a5jaHBkj5tozCOjpAyJYP8yVB6R9g90Zk7pw3ddclPomC1SviPo8sq1b315TR8(ShsvxE4TO66Kak9dvNLgr1TH46EEagYGQ604XzToO3syPhevN0J3w3d(a1fEDSWiMRd5HMbuDqCDSXiMRt6XBRleiyDSlGqvDRSuzp0(abOKwHy(vMfImJt5ScIC6nqTwdaHm4qUqSrdXHG1z)QO(AVt4qUqSrdXHWOO(AVtkO0aB2uuFT3jneOwAFSsMbWGrr91ENwzY7bUj5PwkeEBkt7pz5SzZgtvuFT3jneOwAFSsMbWGrr91ENwzYZyf1x7DchYfInAioegf1x7Dc5HMHgFzHrnGngjfvuFT3PUacvg424TKHauUK0kZMnpWnjp5tozCOrn0twcJyI891ENcfMaHyaKbVqTjmLhda1iBszz)X6KdAhlHx3oeIEOzOUnex3cfDbv34uokv2dTpqakPviMFLzHiZ4uoI1z)2x7DQlGqLyH8eMcTBZMp5KXHg1qp9YcJSztdZ7qtgCaokPO9Oh)Pxwk7L9hRZYIqeqtOYEO9bcqjcHiGMqVAiqtahhoPmBrKtL9q7deGsecranHy(vMUacvg424TKHauUewN9R1aprxqPUiuKzlwySedscqlVgcfkO0GuNCPjcy8wYqsiuALjV1aprxqPUtgneOgFGGYEO9bcqjcHiGMqm)ktZvGvtamWTjKlHHEBzp0(abOeHqeqtiMFLzd1lePmHCj84KPtroRZ(fLrcHXdCtYrPUiuKzlwySKgFzXMnCmkdzLaEkukuAanAjmsEM2x7DkuyceIbqg8c1MwzL9q7deGsecranHy(vMSfE2sgqttxeiN1z)IYiHW4bUj5OuxekYSflmwsJVSyZgogLHSsapfkfknGgTegv2dTpqakrieb0eI5xz8wYSaD4cOmBiwtSo73(AVtysZGGqiZgI1uALzZwFT3jmPzqqiKzdXAYOHlGt4eYdndpXgJk7H2hiaLieIaAcX8Rm4jltqMbyqzHMk7H2hiaLieIaAcX8RmsdXcLvAagmHGGaOjwN9BFT3jXSPUacvjKhAgEYYl7H2hiaLieIaAcX8Rm5uoelXa3gXspkJctroI1z)sac3uYtY5Zk7L9hRtQoGb1syuz)X6y3TS1bTs46EaN96WegkeO6KE826KdkuOwOlZdQP6CCmoQoiUUhy5TccHQZYGj9Ggiiv2dTpqakThWGAF7KlnraJ3sgscHyD2Vwd8eDbL6oz0qGA8bck7H2hiaL2dyqTm)kdsmAYeaLrnAI1z)2x7DcjgnzcGYOgnLWuEma0t(KtghAudjFFT3jKy0KjakJA0uct5XaqpXy2ywdZ7qtgCaoIjsr2sszzp0(abO0EadQL5xzWqHW4TKPdbeI1z)2x7DcdfcJ3sMoeqOeMYJbGE61Yl7H2hiaL2dyqTm)kdgkegVLmDiGqSo7xghAFSsgcq5dHEzZMT(AVtDrOiZwSWyjjfuAatK3AGNOlOe27gmHHcrz)X6y3TS1j94T15TuDpOMQZsNvNLs4cx3xqKvQoiUo5GcfQf6154yCuQShAFGauApGb1Y8RmDYLMiGXBjdjHqSo73qUeECkfAYSYmsGlSbjiYkLiq0fKYMTqUeECkPOqHAHEIarxqQYEO9bcqP9agulZVYOguw462YEz)X6(ofcVTShAFGauc5ui823iVVqT8VvcJgiGBblmInPcJK6SWc)lDGbdOjI)FE5zqStQ6K61fAFGG6edYrPYo)hlVfI5))Kl14FXGCexw(NqicOjexwUfSXLL)dTpqa)RHanbCC4KYSfroX)ei6csXzN7ClyHll)tGOlifND(xJhNWtW)wd8eDbL6IqrMTyHXsmijaDDYxNgcfkO0GuNCPjcy8wYqsiuALvN81znWt0fuQ7KrdbQXhiG)dTpqa)3fqOYa3gVLmeGYLWDUfwoxw(p0(ab8FZvGvtamWTjKlHHEl)tGOlifNDUZTqo5YY)ei6csXzN)14Xj8e8pkJecJh4MKJsDrOiZwSWyj114BDSuNnB1HJrziReWtHsHsdOUgRZsyuDYxhtRRV27uOWeiedGm4fQnTY4)q7deW)BOEHiLjKlHhNmDkY5o3INXLL)jq0fKIZo)RXJt4j4FugjegpWnjhL6IqrMTyHXsQRX36yPoB2QdhJYqwjGNcLcLgqDnwNLWi(p0(ab8F2cpBjdOPPlcKZDUfwcxw(Narxqko78VgpoHNG)7R9oHjndccHmBiwtPvwD2SvxFT3jmPzqqiKzdXAYOHlGt4eYdnd19uDSXi(p0(ab8V3sMfOdxaLzdXAI7ClK6Cz5)q7deW)4jltqMbyqzHM4FceDbP4SZDUfsjxw(Narxqko78VgpoHNG)7R9ojMn1fqOkH8qZqDpvNLZ)H2hiG)LgIfkR0amycbbbqtCNBHuHll)tGOlifND(xJhNWtW)eGWnLu3t1jNpJ)dTpqa)Nt5qSedCBel9Omkmf5iUZD(xr7yjCUSClyJll)tGOlifND(xJhNWtW)mToKtHWBjvcdBUi(p0(ab8pdJMbUZTGfUS8FO9bc4FKtHWB5FceDbP4SZDUfwoxw(Narxqko78pmJ)rKZ)H2hiG)Tg4j6cI)TgIfX)yVB6R9gv3t1XsDYxhJRRV27KagkszuJMsRS6SzRoMwxFT3PM4aOm5KGO0kRo5RJP11x7DcV8wbHqMmmPh0abPvwDmH)TgydiYj(h7DdMWqHG7ClKtUS8pbIUGuC25Fyg)JiN)dTpqa)BnWt0fe)BnelI)XE30x7nQUNQJL6KVogxxFT3jbmuKYOgnLwz1zZwD91ENWlVvqiKjdt6bnqqct5Xaq190BDAiuOGsdsDYLMiGXBjdjHqjmLhdavht4FnECcpb)hYLWJtjffkul0tei6csvNnB1fYLWJtPqtMvMrcCHnibrwPebIUGu8V1aBaroX)yVBWegkeCNBXZ4YY)ei6csXzN)Hz8pIC(p0(ab8V1aprxq8V1qSi(h7DtFT3O6EQow4FnECcpb)hYLWJtjeiyGmKecLWbGH6A8Tow4FRb2aICI)XE3Gjmui4o3clHll)tGOlifND(hMX)ycro)hAFGa(3AGNOli(3AGnGiN4FS3nycdfc(xJhNWtW)HCj84ucbcgidjHqjCayOUgFRJL6KVU(AVtiqWazijekH8qZqDn(whl11G66R9o1XWqHgfLwzCNBHuNll)tGOlifND(hMX)iY5)q7deW)wd8eDbX)wdXI4FnmVdnzWb4OKI2JE86A8TowQJ56yPoPyDmUopeeWtnBHixiXGC8WaLiq0fKQo5RtdHcfuAqQzle5cjgKJhgOeMYJbGQ7P6yRoMuhZ11x7DQJHHcnkkTYQt(6iaHBkPUgRZsyuDYxhtRRV27eIHLqycGYOXqeQdbekTY4FRb2aICI)J8(c1A0qGA8bc4o3cPKll)tGOlifND(hMX)iY5)q7deW)wd8eDbX)wdXI4)(AVt4L3kieYKHj9GgiiTYQZMT6yCDHCj84usrHc1c9ebIUGu1zZwDHCj84uk0KzLzKaxydsqKvkrGOlivDmPo5RRV27egkegVLmDiGqPvg)BnWgqKt8F3jJgcuJpqa35wiv4YY)ei6csXzN)Hz8pIC(p0(ab8V1aprxq8V1qSi(hLrcHXdCtYrPUiuKzlwySK6EQowQt(6WXOmKvc4PqPqPbuxJ1XcJQZMT66R9o1fHImBXcJLKwz8V1aBaroX)DrOiZwSWyjgKeGM7ClyJrCz5FceDbP4SZ)A84eEc(h5ui8wsLcHG)dTpqa)RdHWeAFGaJyqo)lgKBaroX)iNcH3YDUfSXgxw(Narxqko78FO9bc4FDieMq7deyedY5FXGCdiYj(xRqCNBbBSWLL)jq0fKIZo)RXJt4j4FnmVdnzWb4O6A8ToDMjpAObLravDnOogxxFT3Poggk0OO0kRoMRRV27emldI9fyCjPvwDmPoPyDmUopeeWtpN1OzWOWH0jceDbPQt(6yCDmTopeeWt5bMbsz2qSrrH3Miq0fKQoB2QtdHcfuAqkpWmqkZgInkk82eMYJbGQRX6yRoMuht4)q7deW)4fWeAFGaJyqo)lgKBaroX)7bmOwUZTGnlNll)tGOlifND(p0(ab8VoectO9bcmIb58VyqUbe5e)3xJqXDUfSjNCz5FceDbP4SZ)A84eEc(NaeUPKKI2JE86A8To2EwDmxhbiCtjjm1Ka8FO9bc4)aRdazCigtaN7Cly7zCz5)q7deW)bwhaYKTeiI)jq0fKIZo35wWMLWLL)dTpqa)lMMToYyPAPAMtaN)jq0fKIZo35o)NHjnmVhoxwUfSXLL)dTpqa)Nb9bc4FceDbP4SZDUfSWLL)jq0fKIZo)hAFGa(ppWmqkZgInkk8w(xJhNWtW)4yugYkb8uOuO0aQRX6KtgX)zysdZ7HBqKgcui()zCNBHLZLL)jq0fKIZo)RXJt4j4FgxhtRJEoRjlJuPmOMbYrJCjLrdZZwE4deyuK1rt1zZwDmTonekuqPbjTeTa6yiy0MUiqEsTWHpqqD2SvhogLHSsapnaRlbGWrxqjQHdYr1Xe(p0(ab8pYPq4TCNBHCYLL)jq0fKIZo)hAFGa(hdfcJ3sMoeqi(pdtAyEpCdI0qGcX)SWDUfpJll)tGOlifND(p0(ab8psmAYeaLrnAI)ZWKgM3d3GineOq8plCNBHLWLL)jq0fKIZo)hAFGa(puyceIbqg8c1Y)A84eEc(NX1X06ONZAYYivkdQzGC0ixsz0W8SLh(abgfzD0uD2SvhtRtdHcfuAqslrlGogcgTPlcKNulC4deuNnB1HJrziReWtdW6saiC0fuIA4GCuDmH)ZWKgM3d3GineOq8pBCNBHuNll)tGOlifND(he5e)hYf1g4az2qGBGBtguAcZ)H2hiG)d5IAdCGmBiWnWTjdknH5o3cPKll)tGOlifND(p0(ab8FguZa5OrUKYOH5zlp8bcmkY6Oj(xJhNWtW)mToCmkdzLaEAawxcaHJUGsudhKJ4FAVjTBaroX)AjAb0XqWOnDrGCUZD(FpGb1YLLBbBCz5FceDbP4SZ)A84eEc(3AGNOlOu3jJgcuJpqa)hAFGa(VtU0ebmElzijeI7ClyHll)tGOlifND(xJhNWtW)91ENqIrtMaOmQrtjmLhdav3t15tozCOrnuDYxxFT3jKy0KjakJA0uct5Xaq19uDmUo2QJ560W8o0KbhGJQJj1jfRJTKuY)H2hiG)rIrtMaOmQrtCNBHLZLL)jq0fKIZo)RXJt4j4)(AVtyOqy8wY0HacLWuEmauDp9wNLZ)H2hiG)XqHW4TKPdbeI7ClKtUS8pbIUGuC25FnECcpb)Z46cTpwjdbO8Hq19whB1zZwD91EN6IqrMTyHXsskO0G6ysDYxN1aprxqjS3nycdfc(p0(ab8pgkegVLmDiGqCNBXZ4YY)ei6csXzN)14Xj8e8FixcpoLcnzwzgjWf2GeezLsei6csvNnB1fYLWJtjffkul0tei6csX)H2hiG)7KlnraJ3sgscH4o3clHll)hAFGa(xnOSW1T8pbIUGuC25o35FKtHWB5YYTGnUS8FO9bc4)iVVqT8pbIUGuC25o35FTcXLLBbBCz5FceDbP4SZ)A84eEc(NP1HCkeElPsHqW)H2hiG)1HqycTpqGrmiN)fdYnGiN4FcHiGMqCNBblCz5FceDbP4SZ)A84eEc(NP11x7DkuyceIbqg8c1Mwz1jFDeGWnLK8jNmo0KhnSUgRJn(p0(ab8FOWeiedGm4fQL7ClSCUS8pbIUGuC25)q7deW)5bMbsz2qSrrH3Y)A84eEc(hhJYqwjGNcLcLwz1jFDmUopWnjp5tozCOrnuDpvNgM3HMm4aCusr7rpED2SvhtRd5ui8wsLWWMlQo5RtdZ7qtgCaokPO9OhVUgFRtNzYJgAqzeqvxdQJT6yc)RLOfKXdCtYrClyJ7ClKtUS8pbIUGuC25FnECcpb)JJrziReWtHsHsdOUgRZYzuDnOoCmkdzLaEkukusTWHpqqDYxhtRd5ui8wsLWWMlQo5RtdZ7qtgCaokPO9OhVUgFRtNzYJgAqzeqvxdQJn(p0(ab8FEGzGuMneBuu4TCNBXZ4YY)ei6csXzN)14Xj8e8pkJecJh4MKJQRX36yPo5RJP11x7DQlcfz2IfgljTYQt(6yCDmToCmkdzLaEkukuIA4GCuD2SvhogLHSsapfkfkHP8yaO6ASoPSoB2QdhJYqwjGNcLcLgqDnwhJRJL6AqDAiuOGsdsDrOiZwSWyjjDBGBsiZghAFGGquhtQtkwhlpRoMW)H2hiG)7IqrMTyHXs4o3clHll)tGOlifND(xJhNWtW)wd8eDbL6IqrMTyHXsmijaDDYxNgM3HMm4aCusr7rpEDn(whB1XCD91EN6yyOqJIsRm(p0(ab8FZwiYfsmihpmqCNBHuNll)tGOlifND(xJhNWtW)wd8eDbL6IqrMTyHXsmijaDDYxhJRJaeUPKKp5KXHM8OH11yDpRoB2QJaeUPK6EQo2EwDmH)dTpqa)ZWiedOPbLHjI7ClKsUS8pbIUGuC25FnECcpb)BnWt0fuQlcfz2IfglXGKa01jFDeGWnLK8jNmo0KhnSUgRJn(p0(ab8FxekYGxOwUZTqQWLL)jq0fKIZo)RXJt4j4FMwhYPq4TKkfcrDYxN1aprxqPiVVqTgneOgFGa(p0(ab8V1amOwUZTGngXLL)jq0fKIZo)RXJt4j4FMwhYPq4TKkfcrDYxN1aprxqPiVVqTgneOgFGa(p0(ab8pQnuqPZjHI7ClyJnUS8pbIUGuC25FnECcpb)3x7DQlGqLyH8eMcTxNnB11x7DkuyceIbqg8c1Mwz8FO9bc4)mOpqa35wWglCz5FceDbP4SZ)H2hiG)Tg4j6cYmaNaOXLyAondRqHBGi9ieHpGMgmfAhI5FnECcpb)3x7DQlGqLyH8eMcTxNnB15tozCOrnuDp9whlmQoB2QtdZ7qtgCaokPO9OhVUNERJf(he5e)BnWt0fKzaobqJlX0CAgwHc3ar6ricFannyk0oeZDUfSz5Cz5FceDbP4SZ)A84eEc(VV27uxaHkXc5jmfAVoB2QZNCY4qJAO6E6TowyuD2SvNgM3HMm4aCusr7rpEDp9whl8FO9bc4)fImJt5iUZTGn5Kll)hAFGa(VlGqLzVWs4FceDbP4SZDUfS9mUS8FO9bc4)oHreMHb0K)jq0fKIZo35wWMLWLL)dTpqa)Vhm1fqOI)jq0fKIZo35wWMuNll)hAFGa(paAc54qy0HqW)ei6csXzN7Clytk5YY)ei6csXzN)dTpqa)Nb1mqoAKlPmAyE2YdFGaJISoAI)14Xj8e8ptRd5ui8wsLcHOo5RRV27uOWeiedGm4fQnPGsdQt(66R9oLt5qSedCBel9Omkmf5OKcknOo5RJaeUPKKp5KXHM8OH11yDYzDYxh27M(AVr19uDpJ)P9M0Ube5e)RLOfqhdbJ20fbY5o3c2KkCz5FceDbP4SZ)H2hiG)duR1aqidoKleB0qCi4FnECcpb)RO(AVt4qUqSrdXHWOO(AVtkO0G6SzRof1x7DsdbQL2hRKzamyuuFT3PvwDYxNh4MKNAPq4TPmTx3t1z5SvNnB1X06uuFT3jneOwAFSsMbWGrr91ENwz1jFDmUof1x7DchYfInAioegf1x7Dc5HMH6A8TowyuDnOo2yuDsX6uuFT3PUacvg424TKHauUK0kRoB2QZdCtYt(KtghAudv3t1zjmQoMuN811x7DkuyceIbqg8c1MWuEmauDnwhBsj)dICI)duR1aqidoKleB0qCi4o3cwyexw(Narxqko78VgpoHNG)7R9o1fqOsSqEctH2RZMT68jNmo0OgQUNERJfgvNnB1PH5DOjdoahLu0E0Jx3tV1Xc)hAFGa(FHiZ4uoI7CN)7RrO4YYTGnUS8pbIUGuC25FnECcpb)3x7DcMLbX(cmUK0kRo5RJX11x7DIbIYmsGlSr6XrMOdxUrcCLqEOzOUNQJngvNnB11x7DsrHc1c90kRoB2QJaeUPK6EQo58z1Xe(p0(ab8F2GCOWGAHo35wWcxw(p0(ab8pAadYjSb54HbI)jq0fKIZo35o35o35Ca]] )


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