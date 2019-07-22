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


    spec:RegisterPack( "Outlaw", 20190722.0000, [[davX)aqiuOEKQiBIsYNisHrHc6uOaRIOu5vOOMfkv3sbyxI6xejddfYXqjTmuINrKsttbKRPa12OKIVrKknovrLZPaQ1PkknpvHUNQ0(ufCqfiTqukpKOumrIu1fPKs2irQ4JePO4KeLsTskLxsKImtvrvYnvfv1ojQ6NQIIgkrPQJsKIslvbINQQMkrXvPKsTvvrvQVQkQIXsukPZsKIQ9IQ)sXGv5WclwrpMutMKlJSzL6ZkOrRqNwQvtukXRrrMnHBls7g43GgUioUQOWYH65qMovxxjBNs13jQmEkP68eX6jkz(uI9lzoRCz4Fv4exEwyeRdmJKUSWsMrmIfRHf(3LKq8FsOzkgs8pisj()zUCrih)NeseWqXLH)rWfwt8)O7jONvkPg2(4AM1WuPqD6seEdbACSDPqDQwk(FUAHlBd4t(xfoXLNfgX6aZiPllSKzeJy0Gz0ZX)OesZLNfRHr8)yRueGp5FfH08)t19mxUiKRUbboCrLTNQB09e0ZkLudBFCnZAyQuOoDjcVHano2UuOovlvz7P6STesQJfwzVowyeRdCDdOowh4NvAhCzRS9uDYMXamKqpBz7P6gqDdQsrQ6KMAnt15W6u0owcVUq7neuNOrEUS9uDdOUbvPivDjysdtNHxhBIqr1jDelmwsDmubjeqA41nXuWuDFNcHpYGCz7P6gqDspein86wiQoh3aMihvxdQd5ui8XCz7P6gqDspein86wiQU0g8SYwRBdX198dmtKQUnexN0tHpwhdBxAGQda96qRKei2jfdYLTNQBa1nO2HTQomHHcrdgw3G4SvNAHBWW6ytekQoPJyHXsQJHlGGqO6KJQdcesQBmSt1XADEGhsodYLTNQBa1niKiSEDstTq0GH19tWeLlBpv3aQZAJO68oLmo0OAQUnexhb0WfWjCDeq1GH1HdFKW15JbOopWdjp7DkzCOr1uM)tWWDli()P6EMlxeYv3GahUOY2t1n6Ec6zLsQHTpUMznmvkuNUeH3qGghBxkuNQLQS9uD2wcj1XcRSxhlmI1bUUbuhRd8ZkTdUSv2EQozZyagsONTS9uDdOUbvPivDstTMP6CyDkAhlHxxO9gcQt0ipx2EQUbu3GQuKQUemPHPZWRJnrOO6KoIfglPogQGecin86MykyQUVtHWhzqUS9uDdOoPhcKgEDlevNJBatKJQRb1HCke(yUS9uDdOoPhcKgEDlevxAdEwzR1TH46E(bMjsv3gIRt6PWhRJHTlnq1bGEDOvsce7KIb5Y2t1nG6gu7WwvhMWqHObdRBqC2QtTWnyyDSjcfvN0rSWyj1XWfqqiuDYr1bbcj1ng2P6yTopWdjNb5Y2t1nG6gesewVoPPwiAWW6(jyIYLTNQBa1zTruDENsghAunv3gIRJaA4c4eUocOAWW6WHps468XauNh4HKN9oLmo0OAkx2kBpvN1Y6KE5KQUjTHyQonmDgEDtAydq56guTMsCuDaiyaJboDVe1fAVHauDqGqsUS9uDH2BiaLtWKgMod)DlcetLTNQl0EdbOCcM0W0z4m)kvSgMsap8gckBpvxO9gcq5emPHPZWz(vQneQkBpv3hejOrOxhoAvDZ1EtQ6qE4O6M0gIP60W0z41nPHnavxau1LGPbKaDVbdRRr1PGakx2EQUq7neGYjysdtNHZ8RuiqKGgHUb5HJkBH2BiaLtWKgModN5xPsGEdbLTq7neGYjysdtNHZ8RuPbMjsz2qSrrHpYEcM0W0z4gePHaf6DWS37xC0kdzNaEoukuUbpmqmQSfAVHauobtAy6mCMFLc5ui8r279ldzm9mwDscPYjqntKJAzrkJgMMS8WBiWOi7TMSyHXAiuOGYbYAjAb0XqqRntrG8SAHdVHalwWrRmKDc45gyFjaeoMcktwVroIbLTq7neGYjysdtNHZ8RuyOqy8rYmHacXEcM0W0z4gePHaf6LLYwO9gcq5emPHPZWz(vkKO1KjakJQ1e7jysdtNHBqKgcuOxwkBH2BiaLtWKgModN5xPcfMaHObKbVqJSNGjnmDgUbrAiqHEzL9E)YqgtpJvNKqQCcuZe5OwwKYOHPjlp8gcmkYERjlwySgcfkOCGSwIwaDme0AZueipRw4WBiWIfC0kdzNaEUb2xcaHJPGYK1BKJyqzl0EdbOCcM0W0z4m)k1crM2Pu2brk9gYcng4az2qGBGBtcuocx2cT3qakNGjnmDgoZVsTqKPDkLDAVjTBark9QLOfqhdbT2mfbYzV3VmghTYq2jGNBG9Laq4ykOmz9g5OYwO9gcq5emPHPZWz(vQPiuKzlwySe2797CT3zmuim(izMqaHYReRcT32jdbO0MqpWAzRS9uDwlRt6LtQ6i7ewsDENs15JuDH2H46AuDH9OfXuq5Y2t1nieYPq4J1176sGiupfuDmeaRZ(saiCmfuDeGsBcvxdQtdtNHZGYwO9gcqVm1AMyV3Vmg5ui8rsLXWHlQSfAVHa0lYPq4JLTNQBqimuiQBdX1XcZ1nx7nQo5AFSUNxWqrQ6K(wt1TsY19m9rclxJO6Wegke1TH46yH56G46KMbhavDpFsquDqCDdYYhfecvNSht6g1qqUSfAVHaeZVszpWDmfe7GiLEX(0Gjmuiy3Eiw0l2NM5AVrpYIvmCU27SagkszuTMYRelwy8CT35H4aOmPKGO8kXkgpx7DgV8rbHqMemPBudb5vcdkBpv3GqyOqu3gIRJfMRBU2BuDqCDdYYhfecvNSht6g1qqDY1(yDspfk0i0RdIRBq1uDRK6Kax46(cISt5YwO9gcqm)kL9a3XuqSdIu6f7tdMWqHGDyYlIC279Bilc3oLvuOqJqptGykiLflHSiC7uo0KzLyKaxydsqKDktGykif72dXIEX(0mx7n6rwSIHZ1ENfWqrkJQ1uELyXYCT3z8YhfeczsWKUrneKXuA0a0JVAiuOGYbYtYLJiGXhjdjHqzmLgnaXGY2t1XcZ19bbtuDwlje6zRBqfYfsq1HjmuiQBdX1XcZ1nx7nkx2cT3qaI5xPSh4oMcIDqKsVyFAWegkeSdtErKZEVFdzr42PmcemrgscHY4aW0dVSWU9qSOxSpnZ1EJEKLY2t1XcZ19bbtuDwlje6zRt6H1bGEDycdfI6KR9X6yH56qEOzcvhCxNps19bbtuDwljeQU5AVRJHSYCDip0mvNCTpwhByyOqTIQBLWGCzl0EdbiMFLYEG7yki2brk9I9PbtyOqWom5ftiYzV3VHSiC7ugbcMidjHqzCay6HxwSAU27mcemrgscHYip0m9WlldyU278eddfQvuELu2cT3qaI5xPSh4oMcIDqKsVr6CHgnAiq1EdbSBpel6vdtNqtcSbokRODRB)HxwyMfzhd9qqappCeICHedYXntuMaXuqkR0qOqbLdKhocrUqIb54MjkJP0ObOhzLbmpx7DEIHHc1kkVsSIaeEOKhSggzfJNR9oJyAjeMaOmAmeHMqaHYRKY2t1980(yDPlH3jcQopWdjhXED(yJQZEG7ykO6AuD6rsZePQZH1PiDRO6KBK8rcxhcMs1jBKEuDOr4sOQBs1HKa0KQo5AFSo2eHIQt6iwySKYwO9gcqm)kL9a3XuqSdIu6Dkcfz2IfglXGKa0SBpel6fLqcHXd8qYr5PiuKzlwySKhzXkC0kdzNaEoukuUbpWcJSyzU278uekYSflmwsELu2cT3qaI5xP0HqycT3qGr0iNDqKsViNcHpYEVFrofcFKu5qikBH2BiaX8Ru6qimH2BiWiAKZoisPxTcv2EQoPtdA0yDHxxAy9oDLwNSr2NR7VMihhAVoiGQBdX1rHESo2WWqHAfvxau19mtsGyFbAxsDYnsG6KMD1AMQt6XHC11O6qKG0oPQlaQ6E(BPVUgvha61HPqjPUy7eUoFKQdqw3RdrAiqLlBH2BiaX8Ru4fWeAVHaJOro7GiLE3nOrJS37xnmDcnjWg4OhE1jM0W6gucbudGHZ1ENNyyOqTIYReMNR9odtsGyFbAxsELWazhd9qqap)mwTMjJchYLjqmfKYkgYypeeWZPbMjsz2qSrrHpMjqmfKYIfnekuq5a50aZePmBi2OOWhZyknAa6bwzadkBH2BiaX8Ru6qimH2BiWiAKZoisP35QfQYwO9gcqm)kvG1bGmoeJjGZEVFjaHhkjRODRB)HxwhmZeGWdLKX0qcu2cT3qaI5xPcSoaKjzjquzl0EdbiMFLs0dhDKr2YsnmLaEzRS9uDSTAHIWOY2t1zTruDY(g5qrD)rOxxVRR96KdcKgED6iPonmDcRlb2ahvxau15JuDpZKeOVaTlPU5AVRRr1TsY1nO2HTQUfQbdRtUrcuN0erj1jnhUW1980oQoKhAMq1fyQUXE4yDlGGqO68rQoPNcfAe61nx7DDnQUqGG1TsYLTq7neGYZvluVjnYHcdAe6S3735AVZWKei2xG2LKxjwXW5AVZmruIrcCHnY1oYet4YnsGRmYdntpYkJSyzU27SIcfAe65vIfleGWdL84anygu2cT3qakpxTqX8RuOg0iNWgKJBMOYwz7P6KnqOqbLdGkBH2BiaL1k0RoectO9gcmIg5SdIu6LqicOje79(LXiNcHpsQCieLTq7neGYAfI5xPcfMaHObKbVqJS37xgpx7DouyceIgqg8cnMxjwracpus27uY4qtAy9hyTS9uDY276cLcvxGP6wjSxhc0juD(ivheq1jx7J1jGYriVozKr6Z1zTruDYnsG6usAWW62bYjCD(yaQt2i7Rtr7w3EDqCDY1(iC51faj1jBK95YwO9gcqzTcX8RuPbMjsz2qSrrHpYUwIwqgpWdjh9Yk79(fhTYq2jGNdLcLxjwXqpWdjp7DkzCOr10JAy6eAsGnWrzfTBD7wSWyKtHWhjvgdhUiR0W0j0KaBGJYkA362F4vNysdRBqjeqnawzqz7P6KT31bG1fkfQo5AHOovt1jx7JnOoFKQdqw3RtAzeI96wiQUN)w6RdcQBcrO6KR9r4YRlasQt2i7ZLTq7neGYAfI5xPsdmtKYSHyJIcFK9E)IJwzi7eWZHsHYn4bPLrdahTYq2jGNdLcLvlC4neyfJrofcFKuzmC4ISsdtNqtcSbokRODRB)HxDIjnSUbLqa1ayTS9uDSjcfvN0rSWyj1bb1XcZ1rakTjuUUNN2hRluk0ZwN1gr11768rssDipKu3gIR75yUoePHafQoiUUExNe4cxhGSUxNEmWdP6KRfI6MuDykusQRb15Dkv3gIRZhP6aK196KlSt5YwO9gcqzTcX8RutrOiZwSWyjS37xucjegpWdjh9WllwX45AVZtrOiZwSWyj5vIvmKX4OvgYob8COuOmz9g5ilwWrRmKDc45qPqzmLgna9WZzXcoALHStaphkfk3GhyildqdHcfuoqEkcfz2IfgljRhd8qcz24q7neecgi7yzWmOSfAVHauwRqm)k1WriYfsmih3mrS37x7bUJPGYtrOiZwSWyjgKeG2knmDcnjWg4OSI2TU9hEzL55AVZtmmuOwr5vszl0EdbOSwHy(vkMAHObdnOemrS37x7bUJPGYtrOiZwSWyjgKeG2kgsacpus27uY4qtAy9hgSfleGWdL8iRdMbLTq7neGYAfI5xPMIqrg8cnYEVFTh4oMckpfHImBXcJLyqsaARiaHhkj7DkzCOjnS(dSw2EQoRnQbdR75DaA0OudA6CHgRRr1bbcj1f1zNWsQZBGK6AGgtbIyVoeSUguhMcr7syVojWL0at1fteuSCsiPUDdO6CyDlevx71fO6I6wElAxsDOesiYLTq7neGYAfI5xPShGgnYEVFzmYPq4JKkhcHv2dChtbLJ05cnA0qGQ9gckBH2BiaL1keZVsHgdfuUusOyV3Vmg5ui8rsLdHWk7bUJPGYr6CHgnAiq1EdbLTq7neGYAfI5xPsGEdbS3735AVZtbeQelKNXuODlwMR9ohkmbcrdidEHgZRKY2t1jDcHObdRBgAMQZH1PODSeEDTtP1TqXqQSfAVHauwRqm)k1crM2Pu2brk9ApWDmfKPbobqTlXmShg2Hc3ar6wicVbdnyk0oeZEVFNR9opfqOsSqEgtH2TyX7uY4qJQPhFzHrwSOHPtOjb2ahLv0U1T)4llLTq7neGYAfI5xPwiY0oLIyV3VZ1ENNciujwipJPq7wS4DkzCOr10JVSWilw0W0j0KaBGJYkA362F8LLYwO9gcqzTcX8RutbeQm7fwszl0EdbOSwHy(vQjHreMPgmSSfAVHauwRqm)k1UX0uaHQYwO9gcqzTcX8RubqtihhcJoeIYwO9gcqzTcX8RulezANszN2Bs7gqKsVAjAb0XqqRntrGC279lJrofcFKu5qiSAU27COWeienGm4fAmRGYbSAU27CkLcXsmWTrS0TYOWuKIYkOCaRiaHhkj7DkzCOjnS(ddKvyFAMR9g94GlBH2BiaL1keZVsTqKPDkLDqKsVbA0EaiKbhYcInAioeS37xfnx7DghYcInAioegfnx7DwbLdyXcdNR9ohkmbcrdidEHgZRelwu0CT3zneOwAVTtMgWKrrZ1ENxjmWkg6bEi55rke(yor7pkTSAXI3PKXHgvtpAnmIbLTNQt6PDSeED7qiMHMP62qCDlumfuDTtPOCzl0EdbOSwHy(vQfImTtPi2797CT35PacvIfYZyk0UflENsghAun94llmYIfnmDcnjWg4OSI2TU9hFzPSv2EQoRfcranHkBH2BiaLjeIaAc9QHanbCC4KYSfrkv2cT3qaktieb0eI5xPMciuzGBJpsgcqPsyV3V2dChtbLNIqrMTyHXsmijaDzl0EdbOmHqeqtiMFLA4kWQoag42eYIWqFSSfAVHauMqicOjeZVsTH6fIuMqweUDYmPiL9E)IsiHW4bEi5O8uekYSflmwYdVSyXcoALHStaphkfk3GhSggzfJNR9ohkmbcrdidEHgZRKYwO9gcqzcHiGMqm)kvYc3BjnyOzkcKZEVFrjKqy8apKCuEkcfz2Ifgl5HxwSybhTYq2jGNdLcLBWdwdJkBH2BiaLjeIaAcX8Ru(izwGjCbuMneRj2797CT3zmPzsqiKzdXAkVsSyzU27mM0mjieYSHynz0WfWjCg5HMPhzLrLTq7neGYecranHy(vkCNKiitdmOKqtLTq7neGYecranHy(vk5GyHYo1adMqqqa0e79(DU27SO30uaHQmYdntpkTLTq7neGYecranHy(vQukfILyGBJyPBLrHPifXEVFjaHhk5XbAWLTY2t1jDAqJgjmQS9uDS5wR6G2jCDdIZwDycdfcuDY1(yDspfk0i0LAq1uDooAhvhex3GS8rbHq1j7XKUrneKlBH2BiaL3nOrJVtYLJiGXhjdjHqS3735AVZ4LpkieYKGjDJAiiVsSyHHHSiC7uwrHcnc9mbIPGuwSeYIWTt5qtMvIrcCHnibr2PmbIPGumWQ5AVZyOqy8rYmHacLxjLTq7neGY7g0OrMFLcjAnzcGYOAnXEVFNR9oJeTMmbqzuTMYyknAa6rVtjJdnQMSAU27ms0AYeaLr1AkJP0ObOhziRmRHPtOjb2ahXazhR5NRSfAVHauE3GgnY8RuyOqy8rYmHacXEVFNR9oJHcHXhjZeciugtPrdqp(kTLTq7neGY7g0OrMFLcdfcJpsMjeqi279lddT32jdbO0MqVSAXYCT35PiuKzlwySKSckhGbwzpWDmfug7tdMWqHOS9uDS5wR6KR9X68rQUbvt1zTtQtAoCHR7liYovhexN0tHcnc96CC0okx2cT3qakVBqJgz(vQj5YreW4JKHKqi279Bilc3oLdnzwjgjWf2GeezNYeiMcszXsilc3oLvuOqJqptGykivzl0EdbO8UbnAK5xPunkjC9yzRS9uDFNcHpw2cT3qakJCke(4BKoxOr(3oHrneWLNfgX6aZiPlRSKzrAzDG5F5cmObdr8VSDAce7KQoPBDH2BiOorJCuUSX)XYhHy()3PYg(x0ihXLH)jeIaAcXLHlpRCz4)q7neW)AiqtahhoPmBrKs8pbIPGuC24oxEw4YW)eiMcsXzJ)142jCh8V9a3Xuq5PiuKzlwySedscqZ)H2BiG)NciuzGBJpsgcqPs4oxEPLld)hAVHa(F4kWQoag42eYIWqFK)jqmfKIZg35YpqCz4FcetbP4SX)AC7eUd(hLqcHXd8qYr5PiuKzlwySK6E4TowQZIL6WrRmKDc45qPq5gu3d1znmQoRQJX1nx7DouyceIgqg8cnMxj8FO9gc4)nuVqKYeYIWTtMjfPCNl)G5YW)eiMcsXzJ)142jCh8pkHecJh4HKJYtrOiZwSWyj19WBDSuNfl1HJwzi7eWZHsHYnOUhQZAye)hAVHa(pzH7TKgm0mfbY5oxERHld)tGykifNn(xJBNWDW)Z1ENXKMjbHqMneRP8kPolwQBU27mM0mjieYSHynz0WfWjCg5HMP6ESowze)hAVHa(3hjZcmHlGYSHynXDU8sxUm8FO9gc4FCNKiitdmOKqt8pbIPGuC24ox(NJld)tGykifNn(xJBNWDW)Z1ENf9MMciuLrEOzQUhRtA5)q7neW)YbXcLDQbgmHGGaOjUZLFG5YW)eiMcsXzJ)142jCh8pbi8qj19yDd0G5)q7neW)PukelXa3gXs3kJctrkI7CN)v0owcNldxEw5YW)eiMcsXzJ)142jCh8pJRd5ui8rsLXWHlI)dT3qa)ZuRzI7C5zHld)hAVHa(h5ui8r(NaXuqkoBCNlV0YLH)jqmfKIZg)dt4Fe58FO9gc4F7bUJPG4F7Hyr8p2NM5AVr19yDSuNv1XW6MR9olGHIugvRP8kPolwQJX1nx7DEioaktkjikVsQZQ6yCDZ1ENXlFuqiKjbt6g1qqELuhd4F7b2aIuI)X(0Gjmui4ox(bIld)tGykifNn(hMW)iY5)q7neW)2dChtbX)2dXI4FSpnZ1EJQ7X6yPoRQJH1nx7DwadfPmQwt5vsDwSu3CT3z8YhfeczsWKUrneKXuA0auDp(wNgcfkOCG8KC5icy8rYqsiugtPrdq1Xa(3EGnGiL4FSpnycdfc(xJBNWDW)HSiC7uwrHcnc9mbIPGu1zXsDHSiC7uo0KzLyKaxydsqKDktGykif35YpyUm8pbIPGuC24Fyc)JiN)dT3qa)BpWDmfe)BpelI)X(0mx7nQUhRJf(3EGnGiL4FSpnycdfc(xJBNWDW)HSiC7ugbcMidjHqzCayQUhERJfUZL3A4YW)eiMcsXzJ)Hj8pMqKZ)H2BiG)Th4oMcI)Thydisj(h7tdMWqHG)142jCh8Filc3oLrGGjYqsiughaMQ7H36yPoRQBU27mcemrgscHYip0mv3dV1XsDdOU5AVZtmmuOwr5vc35YlD5YW)eiMcsXzJ)Hj8pIC(p0Edb8V9a3Xuq8V9qSi(xdtNqtcSbokRODRBVUhERJL6yUowQt2vhdRZdbb88WriYfsmih3mrzcetbPQZQ60qOqbLdKhocrUqIb54MjkJP0ObO6ESowRJb1XCDZ1ENNyyOqTIYRK6SQocq4HsQ7H6SggvNv1X46MR9oJyAjeMaOmAmeHMqaHYRe(3EGnGiL4)iDUqJgneOAVHaUZL)54YW)eiMcsXzJ)Hj8pIC(p0Edb8V9a3Xuq8V9qSi(hLqcHXd8qYr5PiuKzlwySK6ESowQZQ6WrRmKDc45qPq5gu3d1XcJQZIL6MR9opfHImBXcJLKxj8V9aBarkX)trOiZwSWyjgKeGM7C5hyUm8pbIPGuC24)q7neW)6qimH2BiWiAKZ)AC7eUd(h5ui8rsLdHG)fnYnGiL4FKtHWh5oxEwzexg(NaXuqkoB8FO9gc4FDieMq7neyenY5FrJCdisj(xRqCNlpRSYLH)jqmfKIZg)hAVHa(hVaMq7neyenY5FnUDc3b)RHPtOjb2ahv3dV1PtmPH1nOecOQBa1XW6MR9opXWqHAfLxj1XCDZ1ENHjjqSVaTljVsQJb1j7QJH15HGaE(zSAntgfoKltGykivDwvhdRJX15HGaEonWmrkZgInkk8XmbIPGu1zXsDAiuOGYbYPbMjsz2qSrrHpMXuA0auDpuhR1XG6ya)lAKBarkX)7g0OrUZLNvw4YW)eiMcsXzJ)dT3qa)RdHWeAVHaJOro)lAKBarkX)ZvluCNlpRslxg(NaXuqkoB8Vg3oH7G)jaHhkjRODRBVUhERJ1bxhZ1racpusgtdja)hAVHa(pW6aqghIXeW5oxEwhiUm8FO9gc4)aRdazswceX)eiMcsXzJ7C5zDWCz4)q7neW)IE4OJmYwwQHPeW5FcetbP4SXDUZ)jysdtNHZLHlpRCz4)q7neW)jqVHa(NaXuqkoBCNlplCz4FcetbP4SX)AC7eUd(hhTYq2jGNdLcLBqDpu3aXi(p0Edb8FAGzIuMneBuu4J8FcM0W0z4gePHafI)hm35YlTCz4FcetbP4SX)AC7eUd(NH1X46ONXQtsivobQzICullsz0W0KLhEdbgfzV1uDwSuhJRtdHcfuoqwlrlGogcATzkcKNvlC4neuNfl1HJwzi7eWZnW(saiCmfuMSEJCuDmG)dT3qa)JCke(i35YpqCz4FcetbP4SX)H2BiG)XqHW4JKzcbeI)tWKgMod3GineOq8plCNl)G5YW)eiMcsXzJ)dT3qa)JeTMmbqzuTM4)emPHPZWnisdbke)Zc35YBnCz4FcetbP4SX)AC7eUd(NH1X46ONXQtsivobQzICullsz0W0KLhEdbgfzV1uDwSuhJRtdHcfuoqwlrlGogcATzkcKNvlC4neuNfl1HJwzi7eWZnW(saiCmfuMSEJCuDmG)dT3qa)hkmbcrdidEHg5)emPHPZWnisdbke)Zk35YlD5YW)eiMcsXzJ)brkX)HSqJboqMne4g42KaLJW8FO9gc4)qwOXahiZgcCdCBsGYryUZL)54YW)eiMcsXzJ)142jCh8pJRdhTYq2jGNBG9Laq4ykOmz9g5i(p0Edb8FcuZe5OwwKYOHPjlp8gcmkYERj(N2Bs7gqKs8VwIwaDme0AZueiN7C5hyUm8pbIPGuC24FnUDc3b)px7DgdfcJpsMjeqO8kPoRQl0EBNmeGsBcv3d1Xk)hAVHa(Fkcfz2IfglH7CN)3nOrJCz4YZkxg(NaXuqkoB8Vg3oH7G)NR9oJx(OGqitcM0nQHG8kPolwQJH1fYIWTtzffk0i0ZeiMcsvNfl1fYIWTt5qtMvIrcCHnibr2PmbIPGu1XG6SQU5AVZyOqy8rYmHacLxj8FO9gc4)j5YreW4JKHKqiUZLNfUm8pbIPGuC24FnUDc3b)px7DgjAnzcGYOAnLXuA0auDpwN3PKXHgvt1zvDZ1ENrIwtMaOmQwtzmLgnav3J1XW6yToMRtdtNqtcSboQoguNSRowZph)hAVHa(hjAnzcGYOAnXDU8slxg(NaXuqkoB8Vg3oH7G)NR9oJHcHXhjZeciugtPrdq194BDsl)hAVHa(hdfcJpsMjeqiUZLFG4YW)eiMcsXzJ)142jCh8pdRl0EBNmeGsBcv3BDSwNfl1nx7DEkcfz2IfgljRGYbQJb1zvD2dChtbLX(0Gjmui4)q7neW)yOqy8rYmHacXDU8dMld)tGykifNn(xJBNWDW)HSiC7uo0KzLyKaxydsqKDktGykivDwSuxilc3oLvuOqJqptGykif)hAVHa(FsUCebm(izijeI7C5TgUm8FO9gc4FvJscxpY)eiMcsXzJ7CN)rofcFKldxEw5YW)H2BiG)J05cnY)eiMcsXzJ7CN)1kexgU8SYLH)jqmfKIZg)hAVHa(xhcHj0EdbgrJC(xJBNWDW)mUoKtHWhjvoec(x0i3aIuI)jeIaAcXDU8SWLH)jqmfKIZg)RXTt4o4Fgx3CT35qHjqiAazWl0yELuNv1racpus27uY4qtAy96EOow5)q7neW)HctGq0aYGxOrUZLxA5YW)eiMcsXzJ)142jCh8poALHStaphkfkVsQZQ6yyDEGhsE27uY4qJQP6ESonmDcnjWg4OSI2TU96SyPogxhYPq4JKkJHdxuDwvNgMoHMeydCuwr7w3EDp8wNoXKgw3GsiGQUbuhR1Xa(p0Edb8FAGzIuMneBuu4J8VwIwqgpWdjhXLNvUZLFG4YW)eiMcsXzJ)142jCh8poALHStaphkfk3G6EOoPLr1nG6WrRmKDc45qPqz1chEdb1zvDmUoKtHWhjvgdhUO6SQonmDcnjWg4OSI2TU96E4ToDIjnSUbLqavDdOow5)q7neW)PbMjsz2qSrrHpYDU8dMld)tGykifNn(xJBNWDW)OesimEGhsoQUhERJL6SQogx3CT35PiuKzlwySK8kPoRQJH1X46WrRmKDc45qPqzY6nYr1zXsD4OvgYob8COuOmMsJgGQ7H6EU6SyPoC0kdzNaEoukuUb19qDmSowQBa1PHqHckhipfHImBXcJLK1JbEiHmBCO9gccrDmOozxDSm46ya)hAVHa(Fkcfz2IfglH7C5TgUm8pbIPGuC24FnUDc3b)BpWDmfuEkcfz2IfglXGKa01zvDAy6eAsGnWrzfTBD719WBDSwhZ1nx7DEIHHc1kkVs4)q7neW)dhHixiXGCCZeXDU8sxUm8pbIPGuC24FnUDc3b)BpWDmfuEkcfz2IfglXGKa01zvDmSocq4HsYENsghAsdRx3d1n46SyPocq4HsQ7X6yDW1Xa(p0Edb8ptTq0GHgucMiUZL)54YW)eiMcsXzJ)142jCh8V9a3Xuq5PiuKzlwySedscqxNv1racpus27uY4qtAy96EOow5)q7neW)trOidEHg5ox(bMld)tGykifNn(xJBNWDW)mUoKtHWhjvoeI6SQo7bUJPGYr6CHgnAiq1Edb8FO9gc4F7bOrJCNlpRmIld)tGykifNn(xJBNWDW)mUoKtHWhjvoeI6SQo7bUJPGYr6CHgnAiq1Edb8FO9gc4F0yOGYLscf35YZkRCz4FcetbP4SX)AC7eUd(FU278uaHkXc5zmfAVolwQBU27COWeienGm4fAmVs4)q7neW)jqVHaUZLNvw4YW)eiMcsXzJ)brkX)2dChtbzAGtau7smd7HHDOWnqKUfIWBWqdMcTdX8FO9gc4F7bUJPGmnWjaQDjMH9WWou4gis3cr4nyObtH2Hy(xJBNWDW)Z1ENNciujwipJPq71zXsDENsghAunv3JV1XcJQZIL60W0j0KaBGJYkA362R7X36yH7C5zvA5YW)eiMcsXzJ)142jCh8)CT35PacvIfYZyk0EDwSuN3PKXHgvt194BDSWO6SyPonmDcnjWg4OSI2TU96E8Tow4)q7neW)lezANsrCNlpRdexg(p0Edb8)uaHkZEHLW)eiMcsXzJ7C5zDWCz4)q7neW)tcJimtnyi)tGykifNnUZLNvRHld)hAVHa(F3yAkGqf)tGykifNnUZLNvPlxg(p0Edb8Fa0eYXHWOdHG)jqmfKIZg35YZ6ZXLH)jqmfKIZg)RXTt4o4FgxhYPq4JKkhcrDwv3CT35qHjqiAazWl0ywbLduNv1nx7DoLsHyjg42iw6wzuyksrzfuoqDwvhbi8qjzVtjJdnPH1R7H6gO6SQoSpnZ1EJQ7X6gm)hAVHa(pbQzICullsz0W0KLhEdbgfzV1e)t7nPDdisj(xlrlGogcATzkcKZDU8SoWCz4FcetbP4SX)GiL4)anApaeYGdzbXgnehc(p0Edb8FGgThaczWHSGyJgIdb)RXTt4o4Ffnx7DghYcInAioegfnx7DwbLduNfl1XW6MR9ohkmbcrdidEHgZRK6SyPofnx7DwdbQL2B7KPbmzu0CT35vsDmOoRQJH15bEi55rke(yor719yDslR1zXsDENsghAunv3J1znmQogWDU8SWiUm8pbIPGuC24FnUDc3b)px7DEkGqLyH8mMcTxNfl15DkzCOr1uDp(whlmQolwQtdtNqtcSbokRODRBVUhFRJf(p0Edb8)crM2Pue35o)pxTqXLHlpRCz4FcetbP4SX)AC7eUd(FU27mmjbI9fODj5vsDwvhdRBU27mteLyKaxyJCTJmXeUCJe4kJ8qZuDpwhRmQolwQBU27SIcfAe65vsDwSuhbi8qj19yDd0GRJb8FO9gc4)Kg5qHbncDUZLNfUm8FO9gc4FudAKtydYXnte)tGykifNnUZDUZDUZ5a]] )


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