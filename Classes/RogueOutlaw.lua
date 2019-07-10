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


    spec:RegisterPack( "Outlaw", 20190710.1430, [[da1B3aqiQqEKuKnrf1NujjJci5uaPwfrk1RaQMfrXTOcSlj9lIWWKI6yaXYik9mQuX0isvxtLuTnQuPVHusgNkj15OcQ1rLQmpKsDpvQ9rLYbPcvleO8qKsQjsKIlsKkTrKs0hrkHQtsfewjr1lrkbZePek3Kkvv7Ki6NuPQmuIuXrrkHyPuHYtvXurkUkvqARiLq6RubrJLiLuNLiLO9c5Vu1Gv6WuwSu9ysnzsUmQnJKptLmAjCAfRMiLKxtKmBc3wkTBv9BOgUeDCIuclhXZbnDHRdy7sHVtfz8QK48ivRxLuMVkX(fnceenOJYcgjPSndId3mTcKMRn7WGasZsp6e0lz0P00szUy05TwgDCFaHWCcDkn6cSPq0GoqmarZOtreLq3tcjCnrbqVQXTsaNwaHfd(1eJkKaoTAjqNoWichIh1rhLfmsszBgehUzAfinxB2HbP5RF1OdSK1ijL1DBgDkgLIFuhDumuJonLR7dieMt56yyxaCkVPClIOe6EsiHRjka6vnUvc40ciSyWVMyuHeWPvlrkVPCLdiONlinltUY2mioCUoi3MDy3dKMt5P8MYLwxyVlg6EP8MY1b564kfRYLwy0sLBGZvXugGiY10XG)CfdmQP8MY1b564kfRYTKWACB3ICbtykoxAPaGqONlOuyg(xvKBNWMu5Ec2erbORP8MY1b5kn4)QICbGCUbzEP4aM785cd2errnL3uUoixPb)xvKlaKZTDE3tADUuysUUFJifRYLctYvAylkYfutCvWCFCKleOSetcwb6AkVPCDqUoEd8OYLWeSqmVRCDSaSCvaK5DLlyctX5slfaec9CbfWlyimxN4CXVGEUfwdoxqYnmIloaDnL3uUoixhJf2vYLwyeI5DL7PKWCnL3uUoixhkKZnMw2hyVA4CPWKC5xJb(Gj5YVAEx5sSOGj5gf2NByexCuJPL9b2RgUIoLem1iy0PPCDFaHWCkxhd7cGt5nLBreLq3tcjCnrbqVQXTsaNwaHfd(1eJkKaoTAjs5nLRCab9CbPzzYv2MbXHZ1b52Sd7EG0CkpL3uU06c7DXq3lL3uUoixhxPyvU0cJwQCdCUkMYaerUMog8NRyGrnL3uUoixhxPyvULewJB7wKlyctX5slfaec9CbLcZW)QIC7e2Kk3tWMikaDnL3uUoixPb)xvKlaKZniZlfhWCNpxyWMikQP8MY1b5kn4)QICbGCUTZ7EsRZLctY19BePyvUuysUsdBrrUGAIRcM7JJCHaLLysWkqxt5nLRdY1XBGhvUeMGfI5DLRJfGLRcGmVRCbtykoxAPaGqONlOaEbdH56eNl(f0ZTWAW5csUHrCXbORP8MY1b56ySWUsU0cJqmVRCpLeMRP8MY1b56qHCUX0Y(a7vdNlfMKl)AmWhmjx(vZ7kxIffmj3OW(CdJ4IJAmTSpWE1W1uEkVPCLUxH1abRYTZuycNRg32Ti3o7AEynxhxR5YaM7JFhuyKwkarUMog8dZf)c61uUPJb)WAjH142Uf3ucdkvk30XGFyTKWACB3cWVLWaC1YFyXG)uUPJb)WAjH142UfGFlbfgRs5nL75TsyboYLyJk3oaffRYfgwaZTZuycNRg32Ti3o7AEyU2RYTKWoOehX8UYDG5QWpxt5Mog8dRLewJB7wa(TeW3kHf4WddlGPCthd(H1scRXTDla)wcyWMiks5Mog8dRLewJB7wa(TeL4yWFk30XGFyTKWACB3cWVLO1isXkpfM4vSffYusynUTBHhYA8RG3xxMH6MyJYZn4pQMsbRZ7M03Ck30XGFyTKWACB3cWVLGGfcFuW(o(zOmLewJB7w4HSg)k4TSPCthd(H1scRXTDla)wcOy0S3ELxnAwMscRXTDl8qwJFf8w2uUPJb)WAjH142UfGFlHPi8BI5zpbawitjH142UfEiRXVcEdsk30XGFyTKWACB3cWVLOlmf7PeaecDzgQ7oafvLGfcFuW(o(zyfO0zthtd2Zp3om0nqs5P8MYv6EfwdeSkxUbtONBmTCUrbNRPdmj3bMR1WgH1fCnL3uUogdd2errUdvULyiC6coxq94CBaiEMyDbNl)C7WWCNpxnUTBbOt5Mog8dVLA0sjZqD7iyWMikyvLGDbWPCthd(H3WGnruKYBkxhJjyHixkmjxzbp3oaffmxNMOixAXWMIv5knJMZfOSMR7lkyItdKZLWeSqKlfMKRSGNlMKlT4e7v56(zbZ5Ij56yarHGHWCLoewpWb)1uUPJb)qWVLOHrgRlyzERLVjr3tycwiKPHja4Bs09DakkiTL1zq1bOOQcSPyLxnAUcuE5IJ6auuvxe7v(wwWCfO0zh1bOOQeGOqWqOVKW6bo4Vcuc6uEt56ymble5sHj5kl452bOOG5Ij56yarHGHWCLoewpWb)560ef5knSPGf4ixmjxhxZ5cuMlDmaj3JG5gCnLB6yWpe8BjAyKX6cwM3A5Bs09eMGfczWL3qoKzOUTRXKj4QInfSahv(TUGvxUyxJjtWvtZEGspDmaXdfm3GR8BDbRKPHja4Bs09DakkiTL1zq1bOOQcSPyLxnAUcuE5shGIQsaIcbdH(scRh4G)kHBT5H0(wJXcf2PV25WjMFFuWEModReU1Mhc6uEt5kl45EEtkoxPlDg6E564cNm6WCjmble5sHj5kl452bOOG1uUPJb)qWVLOHrgRlyzERLVjr3tycwiKbxEd5qMH62UgtMGRW3KI9mDgwj2lLB3YktdtaW3KO77auuqAlBkVPCLf8CpVjfNR0LodDVCLgCUpoYLWeSqKRttuKRSGNlmmTuWCXu5gfCUN3KIZv6sNH52bOOYfuGaEUWW0sLRttuKlyeSPGJIZfOe01uUPJb)qWVLOHrgRlyzERLVjr3tycwiKbxEtyihYmu321yYeCf(MuSNPZWkXEPC7wwN7auuv4BsXEModRWW0s52TSoOdqrv7eSPGJIRaLPCthd(HGFlrdJmwxWY8wlFBTDayHxJF1ed(LPHja4BnUTJ9L45dyvXuJEc3ULfCzL2Gkmb)r1vbggc6EyqgP4k)wxWkN1ySqHD6RUkWWqq3ddYifxjCRnpK2GaAW7auu1obBk4O4kqPZ8Zex0DZDB2zh1bOOQqPaecV9kVMGHWo(zyfOmL3uUoKtuKBlGiMsbNByexCaLj3OyG52WiJ1fCUdmxDbRLIv5g4CvSEuCUovWrbtYfIB5CP1sdmxybgqOYTZ5cP)AwLRttuKlyctX5slfaec9uUPJb)qWVLOHrgRlyzERLV7ctXEkbaHq3dP)AzAyca(gwYcHpmIloG1UWuSNsaqi0PTSotSr55g8hvtPG15Dt2MVCPdqrv7ctXEkbaHqVcuMYnDm4hc(TeAti8Mog87fdmK5Tw(ggSjIczgQByWMikyv1eIuUPJb)qWVLqBcH30XGFVyGHmV1Y3AfmL3uU0Y5hyrUwKBRDLPfOnxAT0PM7bOddIPJCXpNlfMKlB6ICbJGnfCuCU2RY19vwIjbWpb9CDQG)CPfby0sLR0qmNYDG5czbRdwLR9QCD)ustUdm3hh5sytrpxJkysUrbN7ZxjYfYA8RQPCthd(HGFlbb49Mog87fdmK5Tw(MA(bwiZqDRXTDSVepFaD7wx6BTR4HL8RCaO6auu1obBk4O4kqj4DakQkUSetcGFc6vGsqlTbvyc(JQ0cGrlLxrmNQ8BDbRCguokmb)rT1isXkpfM4vSffv(TUGvxUOXyHc70xBnIuSYtHjEfBrrLWT28q3ab0GoLB6yWpe8Bj0Mq4nDm43lgyiZBT8DhyeQuUPJb)qWVLWiA7zFGje(dzgQB(zIl6vftn6jC7gKRdo)mXf9kHDXFk30XGFi43syeT9SVeqa5uUPJb)qWVLqmUkcOxAfGYvl)rkpL3uUGbmcftGP8MY1Hc5CLodmWICpf4i3Hk3jY1j8FvrUARmxnUTJZTepFaZ1EvUrbNR7RSeha)e0ZTdqrL7aZfOSMRJ3apQCbGZ7kxNk4pxAbMlZvAjgGKRd5eWCHHPLcMRr4Clgxf5c8cgcZnk4CLg2uWcCKBhGIk3bMRjG4CbkRPCthd(H1oWiu3LdmWcpSahYmu3DakQkUSetcGFc6vGsNbvhGIQkfZLE6yaI3PjGERJbcpDmqfgMwkAdsZxU0bOOQk2uWcCubkVCHFM4IoTL(Rd6uUPJb)WAhyekWVLao)adM4HbzKIt5P8MYLwJXcf2PhMYnDm4hw1k4Djog8lZqD3bOOQDbgReaWOsythxU0bOOQMIWVjMN9eayrfOmL3uU0stiM3vUDtlvUboxftzaIi3j42CbGMloLB6yWpSQvqWVLaaY(j4wzERLVByKX6c2pFWpCc6ExJlRbweEmupcHfZ7YtythyImd1DhGIQ2fySsaaJkHnDC5smTSpWE1W0(w2MVCrJB7yFjE(awvm1ONG23YMYnDm4hw1ki43saaz)eCluMH62rWGnruWQQjeodQoafvTlWyLaagvcB64YfnUTJ9L45dyvXuJEcAFllOt5Mog8dRAfe8Bj6cmw5Pai0t5Mog8dRAfe8Bj6mbYePM3vk30XGFyvRGGFlb1q4UaJvPCthd(HvTcc(Te2RzyqmHxBcrk30XGFyvRGGFlH2ecVPJb)EXadzERLVziKFndLzOUDemytefSQAcrk30XGFyvRGGFlHPi8BI5zpbawiZqD7Ooafv1ue(nX8SNaalQaLoZptCrVgtl7dSV1UIBGKYBkxhcQCnLcMRr4CbkLjx4pLCUrbNl(5CDAIICfyNyyKln0in1CDOqoxNk4pxf95DLlLbdMKBuyFU0APtUkMA0tKlMKRttuGbICTNEU0APtnLB6yWpSQvqWVLO1isXkpfM4vSffYOPRfSpmIloG3GiZqDtSr55g8hvtPGvGsNbvmTSpWE1W0wJB7yFjE(awvm1ON4Yfhbd2erbRQeSla2znUTJ9L45dyvXuJEc3U1L(w7kEyj)khacOt5nLRdbvUpoxtPG560ie5QgoxNMOy(CJco3NVsKR70muMCbGCUUFkPjx8NBhdH560efyGix7PNlTw6ut5Mog8dRAfe8BjAnIuSYtHjEfBrHmd1nXgLNBWFunLcwN3n3PzhqSr55g8hvtPGvfaXIb)o7iyWMikyvLGDbWoRXTDSVepFaRkMA0t42TU03AxXdl5x5aqs5nLlyctX5slfaec9CXFUYcEU8ZTddR56qorrUMsbDVCDOqo3Hk3OGPNlmm65sHj5E1GNlK14xbZftYDOYLogGK7ZxjYvxyexCUoncrUDoxcBk65oFUX0Y5sHj5gfCUpFLixNSgCnLB6yWpSQvqWVLOlmf7PeaecDzgQByjle(WiU4a62TSo7OoafvTlmf7Peaec9kqPZGYreBuEUb)r1ukyLVYad4LleBuEUb)r1ukyLWT28q3U6lxi2O8Cd(JQPuW68UbkzDGgJfkStFTlmf7Peaec9QUWiUyONIy6yWVjaT0w2Rd6uUPJb)WQwbb)wcxfyyiO7HbzKILzOUByKX6cU2fMI9ucacHUhs)1oRXTDSVepFaRkMA0t42niG3bOOQDc2uWrXvGYuUPJb)WQwbb)wcPgHyExEyjHzzgQ7ggzSUGRDHPypLaGqO7H0FTZGIFM4IEnMw2hyFRDf3a5Yf(zIl60(6nF5shGIQAkc)MyE2taGfvGsqNYnDm4hw1ki43s0fMI9eayHmd1DdJmwxW1UWuSNsaqi09q6V2z(zIl61yAzFG9T2vCdKuEt56qHZ7kxArTFGfs44TDayrUdmx8lONRLBdMqp3yE65oVMWgKLjxio35ZLWMyc6YKlDmWvr4CToelacwqpxQ55CdCUaqo3jY1G5A5ceJyc65clzHOMYnDm4hw1ki43s0W(bwiZqD7iyWMikyv1ecNByKX6cUATDayHxJF1ed(t5Mog8dRAfe8BjGfMc7ulluYmu3ocgSjIcwvnHW5ggzSUGRwBhaw414xnXG)uEkVPCLUqi)AgMYnDm4hwziKFndV14xZFqSGvEkH1YPCthd(Hvgc5xZqWVLOlWyLht5Jc2Zp3sxMH6UHrgRl4Axyk2tjaie6Ei9xNYnDm4hwziKFndb)wcxagrn27XuE7AmbhfPCthd(Hvgc5xZqWVLGcRbGSYBxJjtW(oBTYmu3Wswi8HrCXbS2fMI9ucacHUB3YE5cXgLNBWFunLcwN3n3T5uUPJb)WkdH8Rzi43sucqgk6Z7Y3fgmKzOUHLSq4dJ4IdyTlmf7PeaecD3UL9YfInkp3G)OAkfSoVBUBZPCthd(Hvgc5xZqWVLikypW3XaVYtHjAoLB6yWpSYqi)Agc(TeKPSuW(59WstZPCthd(Hvgc5xZqWVLWjmrOAWZ7jme)2R5uUPJb)WkdH8Rzi43s0YTycDpMYla0JYRiS1cLzOU5NjUOtBP)6P8uEt5slNFGfmbMYBkxWcPBU4gmjxhlalxctWcbmxNMOixPHnfSahs44Ao3GytaZftY1XaIcbdH5kDiSEGd(RPCthd(HvQ5hyXDNdNy(9rb7z6muMH6UdqrvjarHGHqFjH1dCWFfO8YfqzxJjtWvfBkyboQ8BDbRUCXUgtMGRMM9aLE6yaIhkyUbx536cwbAN7auuvcwi8rb774NHvGYuUPJb)Wk18dSa8BjGIrZE7vE1OzzgQ7oafvfkgn7Tx5vJMReU1Mhs7yAzFG9QHDUdqrvHIrZE7vE1O5kHBT5H0guGaUg32X(s88be0sBqQxDk30XGFyLA(bwa(TeeSq4Jc23XpdLzOU7auuvcwi8rb774NHvc3AZdP9T7KYnDm4hwPMFGfGFlbble(OG9D8ZqzgQBqz6yAWE(52HH3GC5shGIQ2fMI9ucacHEvHD6bTZnmYyDbxjr3tycwis5nLlyH0nxNMOi3OGZ1X1CUo0YCLwIbi5Eem3GZftYvAytblWrUbXMawt5Mog8dRuZpWcWVLOZHtm)(OG9mDgkZqDBxJjtWvtZEGspDmaXdfm3GR8BDbRUCXUgtMGRk2uWcCu536cwLYnDm4hwPMFGfGFlHAGLwOls5P8MY9eSjIIuUPJb)Wkmytef3wBhawGonycCWpsszBgehUzAvZoCfeP3DqhNmYpVli64q0wIjbRYLwLRPJb)5kgyaRPC0rmWaIObDyiKFndr0GKeeenOJPJb)OJg)A(dIfSYtjSwgD436cwHadfijLfrd6WV1fScbg6OjtWKXqNggzSUGRDHPypLaGqO7H0Fn6y6yWp60fySYJP8rb75NBPJcKKUdIg0X0XGF0XfGruJ9EmL3UgtWrb6WV1fScbgkqsk9iAqh(TUGviWqhnzcMmg6alzHWhgXfhWAxyk2tjaie6562DUYM7Ll5sSr55g8hvtPG15Z1TCD3Mrhthd(rhkSgaYkVDnMmb77S1IcKKxhrd6WV1fScbg6OjtWKXqhyjle(WiU4aw7ctXEkbaHqpx3UZv2CVCjxInkp3G)OAkfSoFUULR72m6y6yWp6ucqgk6Z7Y3fgmqbss3frd6y6yWp6efSh47yGx5PWenJo8BDbRqGHcKK0kenOJPJb)OdzklfSFEpS00m6WV1fScbgkqsE1iAqhthd(rhNWeHQbpVNWq8BVMrh(TUGviWqbsshgrd6WV1fScbg6OjtWKXqh(zIl65s7CL(RJoMog8JoTClMq3JP8ca9O8kcBTquGc0rXugGiq0GKeeenOd)wxWkeyOJMmbtgdDCuUWGnruWQkb7cGrhthd(rhPgTuOajPSiAqhthd(rhyWMikqh(TUGviWqbss3brd6WV1fScbg6GlrhihOJPJb)OtdJmwxWOtdtaWOdj6(oaffmxANRS56CUGk3oafvvGnfR8QrZvGYCVCjxhLBhGIQ6IyVY3YcMRaL56CUok3oafvLaefcgc9LewpWb)vGYCbn60Wi(3Az0HeDpHjyHafijLEenOd)wxWkeyOdUeDGCGoMog8JonmYyDbJonmbaJoKO77auuWCPDUYMRZ5cQC7auuvb2uSYRgnxbkZ9YLC7auuvcquiyi0xsy9ah8xjCRnpmxAFNRgJfkStFTZHtm)(OG9mDgwjCRnpmxqJoAYemzm0XUgtMGRk2uWcCu536cwL7Ll5AxJjtWvtZEGspDmaXdfm3GR8BDbRqNggX)wlJoKO7jmbleOaj51r0Go8BDbRqGHo4s0bYb6y6yWp60WiJ1fm60Weam6qIUVdqrbZL25kl6OjtWKXqh7AmzcUcFtk2Z0zyLyVu562DUYIonmI)TwgDir3tycwiqbss3frd6WV1fScbg6Glrhcd5aDmDm4hDAyKX6cgDAye)BTm6qIUNWeSqGoAYemzm0XUgtMGRW3KI9mDgwj2lvUUDNRS56CUDakQk8nPyptNHvyyAPY1T7CLnxhKBhGIQ2jytbhfxbkrbssAfIg0HFRlyfcm0bxIoqoqhthd(rNggzSUGrNgMaGrhnUTJ9L45dyvXuJEICD7oxzZf8CLnxPDUGk3We8hvxfyyiO7HbzKIR8BDbRY15C1ySqHD6RUkWWqq3ddYifxjCRnpmxANli5c6Cbp3oafvTtWMcokUcuMRZ5YptCrpx3Y1DBoxNZ1r52bOOQqPaecV9kVMGHWo(zyfOeDAye)BTm6yTDayHxJF1ed(rbsYRgrd6WV1fScbg6GlrhihOJPJb)OtdJmwxWOtdtaWOdSKfcFyexCaRDHPypLaGqONlTZv2CDoxInkp3G)OAkfSoFUULRSnN7Ll52bOOQDHPypLaGqOxbkrNggX)wlJoDHPypLaGqO7H0Fnkqs6WiAqh(TUGviWqhnzcMmg6ad2erbRQMqGoMog8JoAti8Mog87fdmqhXad)BTm6ad2erbkqscsZiAqh(TUGviWqhthd(rhTjeEthd(9IbgOJyGH)TwgD0kikqscciiAqh(TUGviWqhnzcMmg6OXTDSVepFaZ1T7C1L(w7kEyj)QCDqUGk3oafvTtWMcokUcuMl452bOOQ4Ysmja(jOxbkZf05kTZfu5gMG)OkTay0s5veZPk)wxWQCDoxqLRJYnmb)rT1isXkpfM4vSffv(TUGv5E5sUAmwOWo91wJifR8uyIxXwuujCRnpmx3YfKCbDUGgDmDm4hDiaV30XGFVyGb6igy4FRLrhQ5hybkqscISiAqh(TUGviWqhthd(rhTjeEthd(9IbgOJyGH)TwgD6aJqHcKKG4oiAqh(TUGviWqhnzcMmg6WptCrVQyQrprUUDNlixpxWZLFM4IELWU4hDmDm4hDmI2E2hycH)afijbr6r0GoMog8JogrBp7lbeqgD436cwHadfijb56iAqhthd(rhX4QiGEPvakxT8hOd)wxWkeyOafOtjH142UfiAqsccIg0HFRlyfcmuGKuwenOd)wxWkeyOajP7GObD436cwHadfijLEenOd)wxWkeyOaj51r0GoMog8JoWGnruGo8BDbRqGHcKKUlIg0X0XGF0Pehd(rh(TUGviWqbssAfIg0HFRlyfcm0X0XGF0P1isXkpfM4vSffOJMmbtgdDi2O8Cd(JQPuW6856wUsFZOtjH142UfEiRXVcIoxhfijVAenOd)wxWkeyOJPJb)Odble(OG9D8Zq0PKWACB3cpK14xbrhzrbsshgrd6WV1fScbg6y6yWp6afJM92R8QrZOtjH142UfEiRXVcIoYIcKKG0mIg0HFRlyfcm0X0XGF0Xue(nX8SNaalqNscRXTDl8qwJFfeDabfijbbeenOd)wxWkeyOJMmbtgdD6auuvcwi8rb774NHvGYCDoxthtd2Zp3ommx3Yfe0X0XGF0Plmf7PeaecDuGc0PdmcfIgKKGGObD436cwHadD0KjyYyOthGIQIllXKa4NGEfOmxNZfu52bOOQsXCPNogG4DAcO36yGWthduHHPLkxANlinN7Ll52bOOQk2uWcCubkZ9YLC5NjUONlTZv6VEUGgDmDm4hDkhyGfEyboqbsszr0GoMog8JoW5hyWepmiJum6WV1fScbgkqb6ad2erbIgKKGGObDmDm4hDS2oaSaD436cwHadfOaD0kiIgKKGGObD436cwHadD0KjyYyOthGIQ2fySsaaJkHnDK7Ll52bOOQMIWVjMN9eayrfOeDmDm4hDkXXGFuGKuwenOd)wxWkeyOJPJb)OtdJmwxW(5d(Htq37ACznWIWJH6riSyExEcB6atqhnzcMmg60bOOQDbgReaWOsyth5E5sUX0Y(a7vdNlTVZv2MZ9YLC142o2xINpGvftn6jYL235kl68wlJonmYyDb7Np4hobDVRXL1alcpgQhHWI5D5jSPdmbfijDhenOd)wxWkeyOJMmbtgdDCuUWGnruWQQje56CUGk3oafvTlWyLaagvcB6i3lxYvJB7yFjE(awvm1ONixAFNRS5cA0X0XGF0baY(j4wikqsk9iAqhthd(rNUaJvEkacD0HFRlyfcmuGK86iAqhthd(rNotGmrQ5DHo8BDbRqGHcKKUlIg0X0XGF0HAiCxGXk0HFRlyfcmuGKKwHObDmDm4hDSxZWGycV2ec0HFRlyfcmuGK8Qr0Go8BDbRqGHoAYemzm0Xr5cd2erbRQMqGoMog8JoAti8Mog87fdmqhXad)BTm6Wqi)AgIcKKomIg0HFRlyfcm0rtMGjJHook3oafv1ue(nX8SNaalQaL56CU8Zex0RX0Y(a7BTRKRB5cc6y6yWp6ykc)MyE2taGfOajjinJObD436cwHadDmDm4hDAnIuSYtHjEfBrb6OjtWKXqhInkp3G)OAkfScuMRZ5cQCJPL9b2RgoxANRg32X(s88bSQyQrprUxUKRJYfgSjIcwvjyxaCUoNRg32X(s88bSQyQrprUUDNRU03AxXdl5xLRdYfKCbn6OPRfSpmIloGijbbfijbbeenOd)wxWkeyOJMmbtgdDi2O8Cd(JQPuW6856wUUtZ56GCj2O8Cd(JQPuWQcGyXG)CDoxhLlmytefSQsWUa4CDoxnUTJ9L45dyvXuJEICD7oxDPV1UIhwYVkxhKliOJPJb)OtRrKIvEkmXRylkqbssqKfrd6WV1fScbg6OjtWKXqhyjle(WiU4aMRB35kBUoNRJYTdqrv7ctXEkbaHqVcuMRZ5cQCDuUeBuEUb)r1ukyLVYadyUxUKlXgLNBWFunLcwjCRnpmx3Y9QZ9YLCj2O8Cd(JQPuW6856wUGkxzZ1b5QXyHc70x7ctXEkbaHqVQlmIlg6PiMog8BICbDUs7CL965cA0X0XGF0Plmf7PeaecDuGKee3brd6WV1fScbg6OjtWKXqNggzSUGRDHPypLaGqO7H0FDUoNRg32X(s88bSQyQrprUUDNli5cEUDakQANGnfCuCfOeDmDm4hDCvGHHGUhgKrkgfijbr6r0Go8BDbRqGHoAYemzm0PHrgRl4Axyk2tjaie6Ei9xNRZ5cQC5NjUOxJPL9b23Axjx3YfKCVCjx(zIl65s7CVEZ5E5sUDakQQPi8BI5zpbawubkZf0OJPJb)OJuJqmVlpSKWmkqscY1r0Go8BDbRqGHoAYemzm0PHrgRl4Axyk2tjaie6Ei9xNRZ5YptCrVgtl7dSV1UsUULliOJPJb)Otxyk2taGfOajjiUlIg0HFRlyfcm0rtMGjJHookxyWMikyv1eICDo3ggzSUGRwBhaw414xnXGF0X0XGF0PH9dSafijbHwHObD436cwHadD0KjyYyOJJYfgSjIcwvnHixNZTHrgRl4Q12bGfEn(vtm4hDmDm4hDGfMc7ulluOafOd18dSardssqq0Go8BDbRqGHoAYemzm0PdqrvjarHGHqFjH1dCWFfOm3lxYfu5AxJjtWvfBkyboQ8BDbRY9YLCTRXKj4QPzpqPNogG4HcMBWv(TUGv5c6CDo3oafvLGfcFuW(o(zyfOeDmDm4hD6C4eZVpkyptNHOajPSiAqh(TUGviWqhnzcMmg60bOOQqXOzV9kVA0CLWT28WCPDUX0Y(a7vdNRZ52bOOQqXOzV9kVA0CLWT28WCPDUGkxqYf8C142o2xINpG5c6CL25cs9Qrhthd(rhOy0S3ELxnAgfijDhenOd)wxWkeyOJMmbtgdD6auuvcwi8rb774NHvc3AZdZL2356oOJPJb)Odble(OG9D8ZquGKu6r0Go8BDbRqGHoAYemzm0bu5A6yAWE(52HH5ENli5E5sUDakQAxyk2tjaie6vf2PpxqNRZ52WiJ1fCLeDpHjyHaDmDm4hDiyHWhfSVJFgIcKKxhrd6WV1fScbg6OjtWKXqh7AmzcUAA2du6PJbiEOG5gCLFRlyvUxUKRDnMmbxvSPGf4OYV1fScDmDm4hD6C4eZVpkyptNHOajP7IObDmDm4hDudS0cDb6WV1fScbgkqbkqhdikWe05mT0AuGceca]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "battle_potion_of_agility",

        package = "Outlaw",
    } )

end