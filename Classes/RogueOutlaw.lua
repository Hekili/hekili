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

            usable = function () return time == 0 and not buff.stealth.up and not buff.vanish.up end,            
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


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]
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


    -- 587c02a72bd50631ec7949f7b257a3fab1d7100f
    spec:RegisterPack( "Outlaw", 20190709.1430, [[da1C3aqiIQ6rQe2evuFsLOAuijoLkPwfru5viHzruClIkTlj9lIWWqkCmKslJO0ZqsQPHuKRPsITruL(grfmovIY5iQO1rLQmpIi3tLAFuPCqQuXcrIEissAIer5IevOnIuu(issuDsIQGvsfEjvQQMjssuUjssyNej)KkvLHsevDuKKiwkvQ0tvXursDvIQOTIKePVsufASifv1zrkQ0EH8xQAWkDyklwQEmPMmjxg1Mb6ZujJwcNwXQrkQYRjsnBc3wkTBv9BOgUeDCKIkwoINdA6cxhW2LcFNkY4vjY5rQwVkjnFPO9lAeTiQrhLfmskzPbTYjnKd0qoR0stu9LDfQgDc6Lm6uAAPnxm68wlJoUpGqyoHoLgDb2uiQrhigGOz0PiIsO7jHeUMOaOx14wjGtlGWIb)AIbgsaNwTeOthyeH8WJ6OJYcgjLS0Gw5KgYbAiNvAPjQ(YOj5eDGLSgjLSYlnqNIrP4h1rhfd1OZf56(acH5uUUl2faNoUi3IikHUNes4AIcGEvJBLaoTaclg8RjgyibCA1sKoUixhac65kNYKRS0Gw5mx5MlT0K7r10iDKoUixQAH9UyO7LoUix5MR7OuSkx3)OLo3aNRIbnarKRPJb)5kgyuthxKRCZ1DukwLBjH142Uf5sPWuCU0mbaHqpxQOWm8V8i3oHnPZ9eSjIIRRPJlYvU5kz4)YJCbGCUbzEP5aM785cd2errnDCrUYnxjd)xEKlaKZTDE3JMFUGysUufgrAwLliMKRKXwuKlvM4YH5(4ixiqzjMeS66A64ICLBUUtd8OYLWeSqmVRCD3GYCvaK5DLlLctX5sZeaec9CPcWlyimxN4CXVGEUfwdoxAZnmIloUUMoUix5MR7Yc7s56(hHyEx5EkjmxthxKRCZvEc5CJPL9b2Rgoxqmjx(1yGpysU8RM3vUelkysUrH95ggXfh1yAzFG9QHROtjbdocgDUix3hqimNY1DXUa40Xf5werj09Kqcxtua0RACReWPfqyXGFnXadjGtRwI0Xf56aqqpx5uMCLLg0kN5k3CPLMCpQMgPJ0Xf5svlS3fdDV0Xf5k3CDhLIv56(hT05g4CvmObiICnDm4pxXaJA64ICLBUUJsXQCljSg32TixkfMIZLMjaie65sffMH)Lh52jSjDUNGnruCDnDCrUYnxjd)xEKlaKZniZlnhWCNpxyWMikQPJlYvU5kz4)YJCbGCUTZ7E08ZfetYLQWisZQCbXKCLm2IICPYexom3hh5cbklXKGvxxthxKRCZ1DAGhvUeMGfI5DLR7guMRcGmVRCPuykoxAMaGqONlvaEbdH56eNl(f0ZTWAW5sBUHrCXX110Xf5k3CDxwyxkx3)ieZ7k3tjH5A64ICLBUYtiNBmTSpWE1W5cIj5YVgd8btYLF18UYLyrbtYnkSp3WiU4Ogtl7dSxnCnDKoUix54LynqWQC7miMW5QXTDlYTZUMhwZ1D0AUmG5(4xUfgPfeqKRPJb)WCXVGEnDy6yWpSwsynUTBXnOWGsNomDm4hwljSg32TGIBjmaxT8hwm4pDy6yWpSwsynUTBbf3saIXQ0Xf5EERewGJCj2OYTdacYQCHHfWC7miMW5QXTDlYTZUMhMR9QCljSClXrmVRChyUk8Z10HPJb)WAjH142UfuClb8Tsybo8WWcy6W0XGFyTKWACB3ckULagSjII0HPJb)WAjH142UfuClrjog8NomDm4hwljSg32TGIBjAnI0SYdIjEfBrHmLewJB7w4HSg)k49vKzaVj2O8Cd(JQPuW68Urt0iDy6yWpSwsynUTBbf3sqWcHpkyFh)muMscRXTDl8qwJFf8w20HPJb)WAjH142UfuClbumA2BVYRgnltjH142UfEiRXVcElB6W0XGFyTKWACB3ckULWue(nX8SNaalKPKWACB3cpK14xbVPnDy6yWpSwsynUTBbf3s0fMI9GcacHUmd4DhaeSsWcHpkyFh)mScu6SPJPb75NBhg6gTPJ0Xf5khVeRbcwLl3Gj0ZnMwo3OGZ10bMK7aZ1AyJW6cUMoUix3LHbBIOi3bm3smeoDbNlvECUnaeptSUGZLFUDyyUZNRg32T460HPJb)WBPhT0YmG3YhgSjIcwvjyxaC6W0XGF4nmytefPJlY1DzcwiYfetYvwkYTdaccZ1PjkYLQmSPyvUs2O5CbkR56(IcM40a5Cjmble5cIj5klf5Ij5svoXEvUufSG5CXKCDxGOqWqyUsEcRh4G)A6W0XGFif3s0WiJ1fSmV1Y3KO7jmbleY0Wea8nj6(oaiiusY6mv6aGGvb2uSYRgnxbkB2u(DaqWQlI9kFllyUcu6S87aGGvcquiyi0xsy9ah8xbkVoDCrUUltWcrUGysUYsrUDaqqyUysUUlquiyimxjpH1dCWFUonrrUsgBkyboYftY1D0CUaL5shdqY9iyUbxthMog8dP4wIggzSUGL5Tw(MeDpHjyHqgC5nKdzgWB7QmzcUQytblWrLFRlyvZM2vzYeC10ShO0thdq8qbZn4k)wxWkzAyca(MeDFhaeekjzDMkDaqWQaBkw5vJMRaLnB2babReGOqWqOVKW6bo4Vs4wBEOKU1ySqHD6RDoCI53hfSNPZWkHBT5HxNoUixzPi3ZBsZ5khPZq3lx3r4KrhMlHjyHixqmjxzPi3oaiiSMomDm4hsXTenmYyDblZBT8nj6EctWcHm4YBihYmG32vzYeCf(M0SNPZWkXEPD7wwzAyca(MeDFhaeekjzthxKRSuK75nP5CLJ0zO7LRKHZ9XrUeMGfICDAIICLLICHHPLgMlgm3OGZ98M0CUYr6mm3oaiyUuHwkYfgMw6CDAIICPKGnfCuCUaLxxthMog8dP4wIggzSUGL5Tw(MeDpHjyHqgC5nHHCiZaEBxLjtWv4BsZEModRe7L2TBzDUdacwHVjn7z6mScdtlTB3Yk3oaiyTtWMcokUcuMomDm4hsXTenmYyDblZBT8T12bGfEn(vtm4xMgMaGV142o2xINpGvfdo6jC7wwkKvYrLWe8hvxfyyiO7HbzKMR8BDbRCwJXcf2PV6QaddbDpmiJ0CLWT28qjr71u0babRDc2uWrXvGsN5NjUO7M8sdNLFhaeScLgqi82R8Acgc74NHvGY0Xf5kporrUTaIykfCUHrCXbuMCJIbMBdJmwxW5oWC1fSwAwLBGZvX6rX56ubhfmjxiULZLQkzWCHfyaHk3oNlK(RzvUonrrUukmfNlntaqi0thMog8dP4wIggzSUGL5Tw(Ulmf7bfaecDpK(RLPHja4Byjle(WiU4aw7ctXEqbaHqxsY6mXgLNBWFunLcwN3nzPrZMDaqWAxyk2dkaie6vGY0HPJb)qkULqBcH30XGFVyGHmV1Y3WGnruiZaEdd2erbRQMqKomDm4hsXTeAti8Mog87fdmK5Tw(wRGPJlYLMn)alY1ICBTlnTaT5svL81CpaDyqmDKl(5CbXKCztxKlLeSPGJIZ1EvUUVYsmja(jONRtf8NlvjaJw6CLmI5uUdmxilyDWQCTxLlvbOKL7aZ9XrUe2u0Z1adMKBuW5(8LICHSg)QA6W0XGFif3sqaEVPJb)EXadzERLVbNFGfYmG3ACBh7lXZhq3U1L(w7sEyj)k5sLoaiyTtWMcokUcusrhaeSIllXKa4NGEfO8AjhvctWFuP5amAP9kI5uLFRlyLZur(Hj4pQTgrAw5bXeVITOOYV1fSQztngluyN(ARrKMvEqmXRylkQeU1Mh6gTxFD6W0XGFif3sOnHWB6yWVxmWqM3A57oWiuPdthd(HuClHr02Z(ati8hYmG38Zex0RkgC0t42nTxHc(zIl6vc7I)0HPJb)qkULWiA7zFjGaYPdthd(HuClHyCveqpnpaLRw(J0r64ICPeyekMathxKR8eY5k5hyGf5EkWrUdyUtKRt4)YJC1wzUACBhNBjE(aMR9QCJcox3xzjoa(jONBhaem3bMlqznx3PbEu5caN3vUovWFUUFMlZLMlgGKR84eWCHHPLgMRr4Clgxf5c8cgcZnk4CLm2uWcCKBhaem3bMRjG4CbkRPdthd(H1oWiu3LdmWcpSahYmG3DaqWkUSetcGFc6vGsNPshaeSknZLE6yaI3PjGERJbcpDmqfgMwAjrlnA2SdacwvSPGf4Ocu2Sj)mXfDjrtx560HPJb)WAhyekkULao)adM4HbzKMthPJlYLQIXcf2PhMomDm4hw1k4Djog8lZaE3babRDbgReaWOsythnB2babRMIWVjMN9eayrfOmDCrU0mtiM3vUDtlDUboxfdAaIi3j42CbGMloDy6yWpSQvqkULaaY(j4wzERLVByKX6c2pFWpCc6ExJlRbweEmupcHfZ7YtythyImd4DhaeS2fySsaaJkHnD0SzmTSpWE1Ws6wwA0SPg32X(s88bSQyWrpHKULnDy6yWpSQvqkULaaY(j4wOmd4T8HbBIOGvvtiCMkDaqWAxGXkbamQe20rZMACBh7lXZhWQIbh9es6w2RthMog8dRAfKIBj6cmw5bbi0thMog8dRAfKIBj6mbYePN3v6W0XGFyvRGuClb4q4UaJvPdthd(HvTcsXTe2RzyqmHxBcr6W0XGFyvRGuClH2ecVPJb)EXadzERLVziKFndLzaVLpmytefSQAcr6W0XGFyvRGuClHPi8BI5zpbawiZaEl)oaiy1ue(nX8SNaalQaLoZptCrVgtl7dSV1UKB0MoUix5bWCnLcMRr4CbkLjx4pLCUrbNl(5CDAIICfyNyyKl1ulz1CLNqoxNk4pxf95DLlObdMKBuyFUuvjFUkgC0tKlMKRttuGbICTNEUuvjFnDy6yWpSQvqkULO1isZkpiM4vSffYOPRfSpmIloG30kZaEtSr55g8hvtPGvGsNPsmTSpWE1WssJB7yFjE(awvm4ONOzt5dd2erbRQeSla2znUTJ9L45dyvXGJEc3U1L(w7sEyj)k5s71PJlYvEam3hNRPuWCDAeICvdNRttumFUrbN7ZxkYLQPbuMCbGCUufGswU4p3ogcZ1PjkWarU2tpxQQKVMomDm4hw1kif3s0AePzLhet8k2IczgWBInkp3G)OAkfSoVBunnKlXgLNBWFunLcwvaelg87S8HbBIOGvvc2fa7Sg32X(s88bSQyWrpHB36sFRDjpSKFLCPnDCrUukmfNlntaqi0Zf)5klf5Yp3omSMR84ef5Akf09YvEc5ChWCJcMEUWWONliMK7LrrUqwJFfmxmj3bmx6yasUpFPixDHrCX560ie525CjSPON785gtlNliMKBuW5(8LICDYAW10HPJb)WQwbP4wIUWuShuaqi0LzaVHLSq4dJ4IdOB3Y6S87aGG1UWuShuaqi0RaLotf5tSr55g8hvtPGv(sdmGnBsSr55g8hvtPGvc3AZdD7YA2KyJYZn4pQMsbRZ7gvKvUAmwOWo91UWuShuaqi0R6cJ4IHEqIPJb)M4AjNSx560HPJb)WQwbP4wcxfyyiO7HbzKMLzaVByKX6cU2fMI9GcacHUhs)1oRXTDSVepFaRkgC0t42nTu0babRDc2uWrXvGY0HPJb)WQwbP4wcPhHyExEyjHzzgW7ggzSUGRDHPypOaGqO7H0FTZuHFM4IEnMw2hyFRDj3OTzt(zIl6s6k0OzZoaiy1ue(nX8SNaalQaLxNomDm4hw1kif3s0fMI9eayHmd4DdJmwxW1UWuShuaqi09q6V2z(zIl61yAzFG9T2LCJ20Xf5kpHZ7kxQsTFGfs4oTDayrUdmx8lONRLBdMqp3yE65oVMWgKLjxio35ZLWMyc6YKlDmWLt4CToelacwqpxW55CdCUaqo3jY1G5A5ceJyc65clzHOMomDm4hw1kif3s0W(bwiZaElFyWMikyv1ecNByKX6cUATDayHxJF1ed(thMog8dRAfKIBjGfMc7ulluYmG3YhgSjIcwvnHW5ggzSUGRwBhaw414xnXG)0r64ICLJqi)AgMomDm4hwziKFndV14xZFqSGvEqH1YPdthd(Hvgc5xZqkULOlWyLhd6Jc2Zp3sxMb8UHrgRl4Axyk2dkaie6Ei9xNomDm4hwziKFndP4wcxagrn27XGE7QmbhfPdthd(Hvgc5xZqkULaeRbGSYBxLjtW(oBTYmG3Wswi8HrCXbS2fMI9GcacHUB3Y2SjXgLNBWFunLcwN3n5LgPdthd(Hvgc5xZqkULOeGmG0N3LVlmyiZaEdlzHWhgXfhWAxyk2dkaie6UDlBZMeBuEUb)r1ukyDE3KxAKomDm4hwziKFndP4wIOG9aFhd8kpiMO50HPJb)WkdH8Rzif3sqMYsb7N3dlnnNomDm4hwziKFndP4wcNWeHQbpVNWq8BVMthMog8dRmeYVMHuClrl3Ij09yqVaqpkVIWwluMb8MFM4IUKOPRKoshxKlnB(bwWey64ICPmKJ5IBWKCD3GYCjmbleWCDAIICLm2uWcCiH7O5CdInbmxmjx3fikemeMRKNW6bo4VMomDm4hwbNFGf3DoCI53hfSNPZqzgW7oaiyLaefcgc9LewpWb)vGYMnPIDvMmbxvSPGf4OYV1fSQzt7QmzcUAA2du6PJbiEOG5gCLFRly11o3babReSq4Jc23XpdRaLPdthd(HvW5hybf3safJM92R8QrZYmG3DaqWkumA2BVYRgnxjCRnpusX0Y(a7vd7ChaeScfJM92R8QrZvc3AZdLevOLcnUTJ9L45d41soARxw6W0XGFyfC(bwqXTeeSq4Jc23XpdLzaV7aGGvcwi8rb774NHvc3AZdL0nv3Sz6W0XGFyfC(bwqXTeeSq4Jc23XpdLzaVPIPJPb75NBhgEtBZMDaqWAxyk2dkaie6vf2P)ANByKX6cUsIUNWeSqKoUixkd5yUonrrUrbNR7O5CLNL5sZfdqY9iyUbNlMKRKXMcwGJCdInbSMomDm4hwbNFGfuClrNdNy(9rb7z6muMb82UktMGRMM9aLE6yaIhkyUbx536cw1SPDvMmbxvSPGf4OYV1fSkDy6yWpSco)alO4wc1alTqxKoshxK7jytefPdthd(HvyWMikUT2oaSaDAWe4GFKuYsdALtAiVYELknKtQgDCYi)8UGOJ8qBjMeSkx5qUMog8NRyGbSMoqhdikWe05mTuv0rmWaIOgDyiKFndruJKIwe1OJPJb)OJg)A(dIfSYdkSwgD436cwHOefiPKfrn6WV1fScrj6OjtWKXqNggzSUGRDHPypOaGqO7H0Fn6y6yWp60fySYJb9rb75NBPJcKuunIA0X0XGF0XfGruJ9EmO3UktWrb6WV1fScrjkqsrtiQrh(TUGvikrhnzcMmg6alzHWhgXfhWAxyk2dkaie6562DUYMBZM5sSr55g8hvtPG15Z1TCLxAGoMog8JoGynaKvE7Qmzc23zRffiPUcIA0HFRlyfIs0rtMGjJHoWswi8HrCXbS2fMI9GcacHEUUDNRS52SzUeBuEUb)r1ukyD(CDlx5LgOJPJb)OtjazaPpVlFxyWafiPKxe1OJPJb)OtuWEGVJbELhet0m6WV1fScrjkqsjhquJoMog8JoKPSuW(59WstZOd)wxWkeLOaj1LHOgDmDm4hDCcteQg88EcdXV9AgD436cwHOefiPKte1Od)wxWkeLOJMmbtgdD4NjUONRKYLMUc6y6yWp60YTycDpg0la0JYRiS1crbkqhfdAaIarnskAruJo8BDbRquIoAYemzm0r(5cd2erbRQeSlagDmDm4hDKE0sJcKuYIOgDmDm4hDGbBIOaD436cwHOefiPOAe1Od)wxWkeLOdUeDGCGoMog8JonmYyDbJonmbaJoKO77aGGWCLuUYMRZ5sLC7aGGvb2uSYRgnxbkZTzZCLFUDaqWQlI9kFllyUcuMRZ5k)C7aGGvcquiyi0xsy9ah8xbkZ9A0PHr8V1YOdj6EctWcbkqsrtiQrh(TUGvikrhCj6a5aDmDm4hDAyKX6cgDAycagDir33babH5kPCLnxNZLk52babRcSPyLxnAUcuMBZM52babReGOqWqOVKW6bo4Vs4wBEyUs6oxngluyN(ANdNy(9rb7z6mSs4wBEyUxJoAYemzm0XUktMGRk2uWcCu536cwLBZM5AxLjtWvtZEGspDmaXdfm3GR8BDbRqNggX)wlJoKO7jmbleOaj1vquJo8BDbRquIo4s0bYb6y6yWp60WiJ1fm60Weam6qIUVdaccZvs5kl6OjtWKXqh7QmzcUcFtA2Z0zyLyV0562DUYIonmI)TwgDir3tycwiqbsk5frn6WV1fScrj6Glrhcd5aDmDm4hDAyKX6cgDAye)BTm6qIUNWeSqGoAYemzm0XUktMGRW3KM9mDgwj2lDUUDNRS56CUDaqWk8nPzptNHvyyAPZ1T7CLnx5MBhaeS2jytbhfxbkrbsk5aIA0HFRlyfIs0bxIoqoqhthd(rNggzSUGrNgMaGrhnUTJ9L45dyvXGJEICD7oxzZLICLnxjxUuj3We8hvxfyyiO7HbzKMR8BDbRY15C1ySqHD6RUkWWqq3ddYinxjCRnpmxjLlT5EDUuKBhaeS2jytbhfxbkZ15C5NjUONRB5kV0ixNZv(52babRqPbecV9kVMGHWo(zyfOeDAye)BTm6yTDayHxJF1ed(rbsQldrn6WV1fScrj6GlrhihOJPJb)OtdJmwxWOtdtaWOdSKfcFyexCaRDHPypOaGqONRKYv2CDoxInkp3G)OAkfSoFUULRS0i3MnZTdacw7ctXEqbaHqVcuIonmI)TwgD6ctXEqbaHq3dP)AuGKsoruJo8BDbRquIoAYemzm0bgSjIcwvnHaDmDm4hD0Mq4nDm43lgyGoIbg(3Az0bgSjIcuGKIwAGOgD436cwHOeDmDm4hD0Mq4nDm43lgyGoIbg(3Az0rRGOajfT0IOgD436cwHOeD0KjyYyOJg32X(s88bmx3UZvx6BTl5HL8RYvU5sLC7aGG1obBk4O4kqzUuKBhaeSIllXKa4NGEfOm3RZvYLlvYnmb)rLMdWOL2RiMtv(TUGv56CUujx5NByc(JARrKMvEqmXRylkQ8BDbRYTzZC1ySqHD6RTgrAw5bXeVITOOs4wBEyUULlT5EDUxJoMog8JoeG3B6yWVxmWaDedm8V1YOd48dSafiPOvwe1Od)wxWkeLOJPJb)OJ2ecVPJb)EXad0rmWW)wlJoDGrOqbskAPAe1Od)wxWkeLOJMmbtgdD4NjUOxvm4ONix3UZL2RKlf5YptCrVsyx8JoMog8JogrBp7dmHWFGcKu0stiQrhthd(rhJOTN9LaciJo8BDbRquIcKu0Efe1OJPJb)OJyCveqpnpaLRw(d0HFRlyfIsuGc0PKWACB3ce1iPOfrn6WV1fScrjkqsjlIA0HFRlyfIsuGKIQruJo8BDbRquIcKu0eIA0HFRlyfIsuGK6kiQrhthd(rhyWMikqh(TUGvikrbsk5frn6y6yWp6uIJb)Od)wxWkeLOajLCarn6WV1fScrj6y6yWp60AePzLhet8k2Ic0rtMGjJHoeBuEUb)r1ukyD(CDlxAIgOtjH142UfEiRXVcIoxbfiPUme1Od)wxWkeLOJPJb)Odble(OG9D8Zq0PKWACB3cpK14xbrhzrbsk5ern6WV1fScrj6y6yWp6afJM92R8QrZOtjH142UfEiRXVcIoYIcKu0sde1Od)wxWkeLOJPJb)OJPi8BI5zpbawGoLewJB7w4HSg)ki6qlkqsrlTiQrh(TUGvikrhnzcMmg60babReSq4Jc23XpdRaL56CUMoMgSNFUDyyUULlTOJPJb)Otxyk2dkaie6OafOd48dSarnskAruJo8BDbRquIoAYemzm0PdacwjarHGHqFjH1dCWFfOm3MnZLk5AxLjtWvfBkyboQ8BDbRYTzZCTRYKj4QPzpqPNogG4HcMBWv(TUGv5EDUoNBhaeSsWcHpkyFh)mScuIoMog8JoDoCI53hfSNPZquGKswe1Od)wxWkeLOJMmbtgdD6aGGvOy0S3ELxnAUs4wBEyUsk3yAzFG9QHZ15C7aGGvOy0S3ELxnAUs4wBEyUskxQKlT5srUACBh7lXZhWCVoxjxU0wVm0X0XGF0bkgn7Tx5vJMrbskQgrn6WV1fScrj6OjtWKXqNoaiyLGfcFuW(o(zyLWT28WCL0DUuDUnBIoMog8JoeSq4Jc23XpdrbskAcrn6WV1fScrj6OjtWKXqhQKRPJPb75NBhgM7DU0MBZM52babRDHPypOaGqOxvyN(CVoxNZTHrgRl4kj6EctWcb6y6yWp6qWcHpkyFh)mefiPUcIA0HFRlyfIs0rtMGjJHo2vzYeC10ShO0thdq8qbZn4k)wxWQCB2mx7QmzcUQytblWrLFRlyf6y6yWp605WjMFFuWEModrbsk5frn6y6yWp6OgyPf6c0HFRlyfIsuGc0bgSjIce1iPOfrn6y6yWp6yTDayb6WV1fScrjkqb6Ovqe1iPOfrn6WV1fScrj6OjtWKXqNoaiyTlWyLaagvcB6i3MnZTdacwnfHFtmp7jaWIkqj6y6yWp6uIJb)OajLSiQrh(TUGvikrhthd(rNggzSUG9Zh8dNGU314YAGfHhd1JqyX8U8e20bMGoAYemzm0Pdacw7cmwjaGrLWMoYTzZCJPL9b2RgoxjDNRS0i3MnZvJB7yFjE(awvm4ONixjDNRSOZBTm60WiJ1fSF(GF4e09UgxwdSi8yOEeclM3LNWMoWeuGKIQruJo8BDbRquIoAYemzm0r(5cd2erbRQMqKRZ5sLC7aGG1UaJvcayujSPJCB2mxnUTJ9L45dyvXGJEICL0DUYM71OJPJb)OdaK9tWTquGKIMquJoMog8JoDbgR8Gae6Od)wxWkeLOaj1vquJoMog8JoDMazI0Z7cD436cwHOefiPKxe1OJPJb)Od4q4UaJvOd)wxWkeLOajLCarn6y6yWp6yVMHbXeETjeOd)wxWkeLOaj1LHOgD436cwHOeD0KjyYyOJ8ZfgSjIcwvnHaDmDm4hD0Mq4nDm43lgyGoIbg(3Az0HHq(1mefiPKte1Od)wxWkeLOJMmbtgdDKFUDaqWQPi8BI5zpbawubkZ15C5NjUOxJPL9b23Axkx3YLw0X0XGF0Xue(nX8SNaalqbskAPbIA0HFRlyfIs0X0XGF0P1isZkpiM4vSffOJMmbtgdDi2O8Cd(JQPuWkqzUoNlvYnMw2hyVA4CLuUACBh7lXZhWQIbh9e52SzUYpxyWMikyvLGDbW56CUACBh7lXZhWQIbh9e562DU6sFRDjpSKFvUYnxAZ9A0rtxlyFyexCarsrlkqsrlTiQrh(TUGvikrhnzcMmg6qSr55g8hvtPG15Z1TCPAAKRCZLyJYZn4pQMsbRkaIfd(Z15CLFUWGnruWQkb7cGZ15C142o2xINpGvfdo6jY1T7C1L(w7sEyj)QCLBU0IoMog8JoTgrAw5bXeVITOafiPOvwe1Od)wxWkeLOJMmbtgdDGLSq4dJ4IdyUUDNRS56CUYp3oaiyTlmf7bfaec9kqzUoNlvYv(5sSr55g8hvtPGv(sdmG52SzUeBuEUb)r1ukyLWT28WCDl3ll3MnZLyJYZn4pQMsbRZNRB5sLCLnx5MRgJfkStFTlmf7bfaec9QUWiUyOhKy6yWVjY96CLC5k7vY9A0X0XGF0Plmf7bfaecDuGKIwQgrn6WV1fScrj6OjtWKXqNggzSUGRDHPypOaGqO7H0FDUoNRg32X(s88bSQyWrprUUDNlT5srUDaqWANGnfCuCfOeDmDm4hDCvGHHGUhgKrAgfiPOLMquJo8BDbRquIoAYemzm0PHrgRl4Axyk2dkaie6Ei9xNRZ5sLC5NjUOxJPL9b23Axkx3YL2CB2mx(zIl65kPCVcnYTzZC7aGGvtr43eZZEcaSOcuM71OJPJb)OJ0JqmVlpSKWmkqsr7vquJo8BDbRquIoAYemzm0PHrgRl4Axyk2dkaie6Ei9xNRZ5YptCrVgtl7dSV1UuUULlTOJPJb)Otxyk2taGfOajfTYlIA0HFRlyfIs0rtMGjJHoYpxyWMikyv1eICDo3ggzSUGRwBhaw414xnXGF0X0XGF0PH9dSafiPOvoGOgD436cwHOeD0KjyYyOJ8ZfgSjIcwvnHixNZTHrgRl4Q12bGfEn(vtm4hDmDm4hDGfMc7ulluOafOthyeke1iPOfrn6WV1fScrj6OjtWKXqNoaiyfxwIjbWpb9kqzUoNlvYTdacwLM5spDmaX70eqV1XaHNogOcdtlDUskxAPrUnBMBhaeSQytblWrfOm3MnZLFM4IEUskxA6k5En6y6yWp6uoWal8WcCGcKuYIOgDmDm4hDGZpWGjEyqgPz0HFRlyfIsuGcuGcuGq]] )


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