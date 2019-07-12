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


    spec:RegisterPack( "Outlaw", 20190712.0030, [[daf53aqiIk9iaytev9jakgfsWPqcTkIuPxHenlIs3IOIDjPFHuzyaKJHuSmKQEgrkMgveDnaQ2gvQ4BiLOXHusDoaKwhvQ08qk19a0(Os5GurQfIK8qKsYejsPlsKQAJiLWhbOu1jPIaRKk8sakzMauQCtaeTtIIFcGWqjsvokaLILsfjpvftfj1vPIqBfGsPVsfbnwIurDwIuH2lK)svdwPdtzXs1Jj1Kj5YO2mqFMkz0s40kwnrQiVMiz2eUTuA3Q63igUeDCIublhQNdA6cxxL2Uu47urnEQu15jI1dGA(sr7x0iAquJoklyKm0diAaOaIwsd9vabiPbqaIE0jKuYOtPPLYCXOZBTm6aqCdH5m6uAseetHOgDGKlwZOtreLq3Lo6CnrXTx1Kw6Gt7vyXqEn2ad6GtRMo0PFhr4e8Oo6OSGrYqpGObGciAjn0xbeGKg0bwYAKm07oacDkgLIFuhDumuJoaixaIBimNZ1PiUUC6aa5werj0DPJoxtuC7vnPLo40EfwmKxJnWGo40QPlDaGCDCfsYLg6Lnx6bena0CLtUacqUl9a00r6aa5sRkS3fdD30baYvo560kfRYfWA0sLBqYvXG2ve5A6yiFUIbg10baYvo560kfRYTeZAsB3ICPsykoxAH4IXsYLckcdFatKBhZMu5Ec2erbfRPdaKRCYvAjpGjY9c5Cd88sXbm35ZfgSjIIA6aa5kNCLwYdyICVqo325DxPZ5csW5cqAyPyvUGeCUslBrrUuycadm3Ne5cVLLeCWkkwthaix5KRt3GmQCXmMieZ7kxNkOkx1fpVRCPsykoxAH4IXsYLc3xWqyUoZ5sEHKClSgCU0KByyxCqXA6aa5kNCDkwyUpxaRriM3vUNsmZ10baYvo56eHCUX0Y(G4vdNlibNl)AY9dgNl)Q5DLl2IcgNBuyFUHHDXrnMw2heVA4k6uIjGJGrhaKlaXneMZ56uexxoDaGClIOe6U0rNRjkU9QM0shCAVclgYRXgyqhCA10LoaqUoUcj5sd9YMl9aIgaAUYjxabi3LEaA6iDaGCPvf27IHUB6aa5kNCDALIv5cynAPYni5Qyq7kICnDmKpxXaJA6aa5kNCDALIv5wIznPTBrUujmfNlTqCXyj5sbfHHpGjYTJztQCpbBIOGI10baYvo5kTKhWe5EHCUbEEP4aM785cd2errnDaGCLtUsl5bmrUxiNB78UR05Cbj4CbinSuSkxqcoxPLTOixkmbGbM7tICH3YscoyffRPdaKRCY1PBqgvUygteI5DLRtfuLR6IN3vUujmfNlTqCXyj5sH7lyimxN5CjVqsUfwdoxAYnmSloOynDaGCLtUoflm3NlG1ieZ7k3tjM5A6aa5kNCDIqo3yAzFq8QHZfKGZLFn5(bJZLF18UYfBrbJZnkSp3WWU4Ogtl7dIxnCnDKoaqUsF3Z6BWQC7mibZ5QjTDlYTZUMhwZ1P1AUmG5(KxofgUf8kY10XqEyUKxiPMomDmKhwlXSM02TaiOWGsLomDmKhwlXSM02TGsG0zxxT8hwmKpDy6yipSwIznPTBbLaPdKquPdaK75TsybjYfBJk3(feKv5cdlG52zqcMZvtA7wKBNDnpmx7v5wIz5usIyEx5oWCvKNRPdthd5H1smRjTDlOeiDW3kHfKWddlGPdthd5H1smRjTDlOeiDWGnruKomDmKhwlXSM02TGsG0vsIH8Pdthd5H1smRjTDlOeiDTgwkw5bjyVITOq2smRjTDl8qwtEfeiGl7aceBJYZn4pQMsbRZ7MtcO0HPJH8WAjM1K2UfucKomri8rb77KNHYwIznPTBHhYAYRGaPpDy6yipSwIznPTBbLaPdkgn7Tx5vJMLTeZAsB3cpK1KxbbsF6W0XqEyTeZAsB3ckbsNPW8BI5zp(clKTeZAsB3cpK1Kxbbst6W0XqEyTeZAsB3ckbsxxyk2dkUySezhqG9liyftecFuW(o5zy9wkVPJPb75NBhg6gnPJ0baYv67EwFdwLl3GXsYnMwo3OGZ10bbN7aZ1AyJW6cUMoaqUofdd2errUdyULeiC6coxk8KCBCfpJTUGZLFUDyyUZNRM02TGIPdthd5HaLA0sj7acuUWGnruWQkM46YPdthd5HaHbBIOiDaGCDkgteICbj4CPNYC7xqqyUoprrUa2rmfRYvAhnN7TSMlaruWyNhiNlMXeHixqcox6Pmxcoxa7X2RYfGKfmNlbNRtDJcbdH5k9WSEGd5RPdthd5HucKUggESUGL9Twgio6EmJjcHSnmXLbIJUVFbbH0ME5Pq)ccwfetXkVA0C9w2SPC7xqWQlS9kFllyUElLxU9liyfFJcbdH(smRh4q(6TKIPdaKRtXyIqKlibNl9uMB)cccZLGZ1PUrHGHWCLEywpWH8568ef5kTSPGfKixcoxNwZ5ElZvc5IZ9iyUbxthMogYdPeiDnm8yDbl7BTmqC09ygteczjLaHCi7ac0aygpbxvSPGfKOYV1fSQztdGz8eC10S)w6LqUypuWCdUYV1fSs2gM4YaXr33VGGqAtV8uOFbbRcIPyLxnAUElB2SFbbR4Buiyi0xIz9ahYxXCRnpK2a1eIqrC(RDoCM53hfSNLWWkMBT5HumDaGCPNYCpVjfNR0xcdD3CDAHZMeyUygteICbj4CPNYC7xqqynDy6yipKsG01WWJ1fSSV1YaXr3JzmriKLuceYHSdiqdGz8eCf(MuSNLWWk2EPCdi9Y2Wexgio6((feesB6thaix6Pm3ZBsX5k9LWq3nxPLK7tICXmMie568ef5spL5cdtlfmxcyUrbN75nP4CL(syyU9liyUuGgkZfgMwQCDEIICPctmfCuCU3skwthMogYdPeiDnm8yDbl7BTmqC09ygteczjLaXmKdzhqGgaZ4j4k8nPyplHHvS9s5gq6LVFbbRW3KI9SegwHHPLYnG0lN(feS2XetbhfxVLPdthd5HucKUggESUGL9TwgO12VWcVM8QjgYlBdtCzGAsBN4ljZhWQIbh9eUbKEkPx6sHWe8hvxfeyiK4HbEKIR8BDbRKxticfX5V6QGadHepmWJuCfZT28qAtdfPSFbbRDmXuWrX1BP88ZyxsCZDaK8YTFbbRqPUcH3ELxJjqyN8mSElthaixNWjkYT9kIPuW5gg2fhqzZnkgyUnm8yDbN7aZvxWAPyvUbjxfRhfNRZfCuW4CHKwoxAL0cZfwqUcvUDoxOKxZQCDEIICPsykoxAH4IXsshMogYdPeiDnm8yDbl7BTmWUWuShuCXyjEOKxlBdtCzGWswi8HHDXbS2fMI9GIlglH20lp2gLNBWFunLcwN3n6buZM9liyTlmf7bfxmws9wMomDmKhsjq60Mq4nDmK3lgyi7BTmqyWMikKDabcd2erbRQMqKomDmKhsjq60Mq4nDmK3lgyi7BTmqTcMoaqU0I5hyrUwKBR5(P92MlTs6vZ9C7WaB6ixYZ5csW5YMUixQWetbhfNR9QCbiklj44(tijxNl4pxaBUJwQCLwS5CUdmxilyDWQCTxLlajO0M7aZ9jrUy2usY1adgNBuW5(S7JCHSM8QA6W0XqEiLaPdFFVPJH8EXadzFRLbco)alKDabQjTDIVKmFaDdOU03AU3dl5xjhk0VGG1oMyk4O46TKY(feSsklj44(tiPElPO0LcHj4pQshUJwkVcBox536cwjpfKByc(JARHLIvEqc2RylkQ8BDbRA2uticfX5V2AyPyLhKG9k2IIkMBT5HUrdfPy6W0XqEiLaPtBcH30XqEVyGHSV1Ya73rOshMogYdPeiDgwBp7dcgZFi7acKFg7ssvXGJEc3asdGtj)m2LKkMDXF6W0XqEiLaPZWA7zF5va50HPJH8qkbsNyCveqV0PRYvl)r6iDaGCP6ocfJHPdaKRteY5k9gyqe5EkirUdyUtKRZKhWe5QTYC1K2oj3sY8bmx7v5gfCUaeLLK4(tij3(fem3bM7TSMRt3GmQCVW5DLRZf8NlGfZL5kDKCX56eobmxyyAPG5Ayo3IXvrU3xWqyUrbNR0YMcwqIC7xqWChyUMasY9wwthMogYdR97iualhyqeEybjKDab2VGGvszjbh3Fcj1BP8uOFbbRsXCPxc5I9opb0BDYn8si3kmmTu0Mga1Sz)ccwvSPGfKOElB2KFg7scTDsaNIPdthd5H1(DekkbshC(bgm2dd8ifNoshaixAfHiueNFy6W0XqEyvRGaljXqEzhqG9liyTlieL4cJkMnD0Sz)ccwnfMFtmp7Xxyr9wMoaqU0ctiM3vUDtlvUbjxfdAxrK7eCBUxO5IthMogYdRAfKsG0DHSFcUv23AzGnm8yDb7Np4hoHeVRXL1GicpbQhHWI5D5XSPdcw2bey)ccw7ccrjUWOIzthnBgtl7dIxnmTbspGA2utA7eFjz(awvm4ONG2aPpDy6yipSQvqkbs3fY(j4wOSdiq5cd2erbRQMqipf6xqWAxqikXfgvmB6OztnPTt8LK5dyvXGJEcAdKEkMomDmKhw1kiLaPRlieLh8ILKomDmKhw1kiLaPRZyiJLAExPdthd5HvTcsjq6ahm3feIkDy6yipSQvqkbsN9Aggyt41MqKomDmKhw1kiLaPtBcH30XqEVyGHSV1YaziKFndLDabkxyWMikyv1eI0HPJH8WQwbPeiDMcZVjMN94lSq2beOC7xqWQPW8BI5zp(clQ3s55NXUKuJPL9bX3AU3nAshaixNaWCnLcMRH5CVLYMl8Nso3OGZL8CUoprrUcIZmmYLAQL2AUoriNRZf8NRsY8UYf0GbJZnkSpxAL0lxfdo6jYLGZ15jki3ix7LKlTs6vthMogYdRAfKsG01AyPyLhKG9k2Icz1s0c2hg2fhqG0i7aceBJYZn4pQMsbR3s5PqmTSpiE1W0wtA7eFjz(awvm4ONOzt5cd2erbRQyIRllVM02j(sY8bSQyWrpHBa1L(wZ9Eyj)k5qdfthaixNaWCFsUMsbZ15riYvnCUoprX85gfCUp7(ixPbqqzZ9c5CbibL2CjFUDceMRZtuqUrU2ljxAL0RMomDmKhw1kiLaPR1WsXkpib7vSffYoGaX2O8Cd(JQPuW68UjnasoyBuEUb)r1ukyvDXwmKxE5cd2erbRQyIRllVM02j(sY8bSQyWrpHBa1L(wZ9Eyj)k5qt6aa5sLWuCU0cXfJLKl5ZLEkZLFUDyynxNWjkY1ukO7MRteY5oG5gfSKCHHjjxqcoxAnL5czn5vWCj4ChWCLqU4CF29rU6cd7IZ15riYTZ5Iztjj35ZnMwoxqco3OGZ9z3h56S1GRPdthd5HvTcsjq66ctXEqXfJLi7acewYcHpmSloGUbKE5LB)ccw7ctXEqXfJLuVLYtb5ITr55g8hvtPGv29dmGnBITr55g8hvtPGvm3AZdDJw3Sj2gLNBWFunLcwN3nkqVC0eIqrC(RDHPypO4IXsQ6cd7IHEqSPJH8MGIsx6bCkMomDmKhw1kiLaPZvbbgcjEyGhPyzhqGnm8yDbx7ctXEqXfJL4HsET8AsBN4ljZhWQIbh9eUbKgk7xqWAhtmfCuC9wMomDmKhw1kiLaPtQriM3LhwIzw2beyddpwxW1UWuShuCXyjEOKxlpf4NXUKuJPL9bX3AU3nAA2KFg7scTbCa1Sz)ccwnfMFtmp7Xxyr9wsX0HPJH8WQwbPeiDDHPyp(clKDab2WWJ1fCTlmf7bfxmwIhk51YZpJDjPgtl7dIV1CVB0KoaqUor48UYfWw7hybDoDB)clYDG5sEHKCTCBWyj5gZlj351y2GSS5cj5oFUy2etir2CLqUagmNR1HeXnyHKCbNNZni5EHCUtKRbZ1Y9gJycj5clzHOMomDmKhw1kiLaPRH9dSq2beOCHbBIOGvvtiKVHHhRl4Q12VWcVM8QjgYNomDmKhw1kiLaPdwykIZTSqj7acuUWGnruWQQjeY3WWJ1fC1A7xyHxtE1ed5thPdaKR0hc5xZW0HPJH8WkdH8Rziqn518hylyLhuyTC6W0XqEyLHq(1mKsG01feIYta9rb75NBLi7acSHHhRl4Axyk2dkUySepuYRthMogYdRmeYVMHucKoxxdRg79eqVbWmMefPdthd5Hvgc5xZqkbshirFHSYBamJNG9D2ALDabclzHWhg2fhWAxyk2dkUySe3asFZMyBuEUb)r1ukyDE3ChajVC7xqWQPW8BI5zp(clQ3Y0HPJH8WkdH8RziLaPR8IhqjZ7Y3fgmKDabclzHWhg2fhWAxyk2dkUySe3asFZMyBuEUb)r1ukyDE3ChaLomDmKhwziKFndPeiDrb7VFNCFLhKG1C6W0XqEyLHq(1mKsG0HNYsb7N3dlnnNomDmKhwziKFndPeiDotWcvdEEpMHK3Enl7acSFbbRIbK7ccrvHHPLI2st6W0XqEyLHq(1mKsG01YTeSepb0lU6r5vy2AHYoGa5NXUKqBNeWthPdaKlTy(bwWyy6aa5svi9ZL0GX56ubv5IzmriG568ef5kTSPGfKGoNwZ5gyBcyUeCUo1nkemeMR0dZ6boKVMomDmKhwbNFGfa7C4mZVpkyplHHYoGa7xqWk(gfcgc9LywpWH81BzZMuWaygpbxvSPGfKOYV1fSQztdGz8eC10S)w6LqUypuWCdUYV1fSIIY3VGGvmri8rb77KNH1Bz6W0XqEyfC(bwqjq6GIrZE7vE1OzzhqG9liyfkgn7Tx5vJMRyU1Mhs7yAzFq8QHLVFbbRqXOzV9kVA0CfZT28qAtbAOutA7eFjz(asrPlnvAD6W0XqEyfC(bwqjq6WeHWhfSVtEgk7acSFbbRyIq4Jc23jpdRyU1MhsBGst6W0XqEyfC(bwqjq6WeHWhfSVtEgk7acKcMoMgSNFUDyiqAA2SFbbRDHPypO4IXsQkIZpfLVHHhRl4ko6EmJjcr6aa5svi9Z15jkYnk4CDAnNRtSmxPJKlo3JG5gCUeCUslBkybjYnW2eWA6W0XqEyfC(bwqjq66C4mZVpkyplHHYoGanaMXtWvtZ(BPxc5I9qbZn4k)wxWQMnnaMXtWvfBkybjQ8BDbRshMogYdRGZpWckbsNAGLwOlshPdaK7jytefPdthd5HvyWMikaAT9lSaDAWy4qEKm0diAaOaIwsdGQ04Ksd64SH)5DbrhNG2scoyvU0YCnDmKpxXadynDGoIbgqe1OddH8RziIAKm0GOgDmDmKhD0KxZFGTGvEqH1YOd)wxWkevOajd9iQrh(TUGviQqhnEcgpg60WWJ1fCTlmf7bfxmwIhk51OJPJH8Otxqikpb0hfSNFUvckqYiniQrhthd5rhxxdRg79eqVbWmMefOd)wxWkevOajJtIOgD436cwHOcD04jy8yOdSKfcFyyxCaRDHPypO4IXsY1nG5sFUnBMl2gLNBWFunLcwNpx3Y1DauUYNRCZTFbbRMcZVjMN94lSOElrhthd5rhqI(czL3aygpb77S1IcKmaoIA0HFRlyfIk0rJNGXJHoWswi8HHDXbS2fMI9GIlgljx3aMl952SzUyBuEUb)r1ukyD(CDlx3bqOJPJH8Ot5fpGsM3LVlmyGcKmUdIA0X0XqE0jky)97K7R8GeSMrh(TUGviQqbsgAjIA0X0XqE0bpLLc2pVhwAAgD436cwHOcfizO1iQrh(TUGviQqhnEcgpg60VGGvXaYDbHOQWW0sLlTZvAqhthd5rhNjyHQbpVhZqYBVMrbsgakIA0HFRlyfIk0rJNGXJHo8ZyxsYL256Kao6y6yip60YTeSepb0lU6r5vy2AHOafOJIbTRiquJKHge1Od)wxWkevOJgpbJhdDKBUWGnruWQkM46YOJPJH8OJuJwkuGKHEe1OJPJH8OdmytefOd)wxWkevOajJ0GOgD436cwHOcDiLOdKd0X0XqE0PHHhRly0PHjUm6GJUVFbbH5s7CPpx5ZLc52VGGvbXuSYRgnxVL52SzUYn3(feS6cBVY3YcMR3YCLpx5MB)ccwX3OqWqOVeZ6boKVElZLIOtdd7FRLrhC09ygtecuGKXjruJo8BDbRquHoKs0bYb6y6yip60WWJ1fm60WexgDWr33VGGWCPDU0NR85sHC7xqWQGykw5vJMR3YCB2m3(feSIVrHGHqFjM1dCiFfZT28WCPnWC1eIqrC(RDoCM53hfSNLWWkMBT5H5sr0rJNGXJHogaZ4j4QInfSGev(TUGv52SzUgaZ4j4QPz)T0lHCXEOG5gCLFRlyf60WW(3Az0bhDpMXeHafizaCe1Od)wxWkevOdPeDGCGoMogYJonm8yDbJonmXLrhC099liimxANl9OJgpbJhdDmaMXtWv4BsXEwcdRy7Lkx3aMl9Otdd7FRLrhC09ygtecuGKXDquJo8BDbRquHoKs0bZqoqhthd5rNggESUGrNgg2)wlJo4O7XmMieOJgpbJhdDmaMXtWv4BsXEwcdRy7Lkx3aMl95kFU9liyf(MuSNLWWkmmTu56gWCPpx5KB)ccw7yIPGJIR3suGKHwIOgD436cwHOcDiLOdKd0X0XqE0PHHhRly0PHjUm6OjTDIVKmFaRkgC0tKRBaZL(CPmx6Zv6MlfYnmb)r1vbbgcjEyGhP4k)wxWQCLpxnHiueN)QRccmes8WapsXvm3AZdZL25stUumxkZTFbbRDmXuWrX1BzUYNl)m2LKCDlx3bq5kFUYn3(feScL6keE7vEnMaHDYZW6TeDAyy)BTm6yT9lSWRjVAIH8OajdTgrn6WV1fScrf6qkrhihOJPJH8OtddpwxWOtdtCz0bwYcHpmSloG1UWuShuCXyj5s7CPpx5ZfBJYZn4pQMsbRZNRB5spGYTzZC7xqWAxyk2dkUySK6TeDAyy)BTm60fMI9GIlglXdL8AuGKbGIOgD436cwHOcD04jy8yOdmytefSQAcb6y6yip6OnHWB6yiVxmWaDedm8V1YOdmytefOajdnacrn6WV1fScrf6y6yip6OnHWB6yiVxmWaDedm8V1YOJwbrbsgAObrn6WV1fScrf6OXtW4XqhnPTt8LK5dyUUbmxDPV1CVhwYVkx5KlfYTFbbRDmXuWrX1BzUuMB)ccwjLLeCC)jKuVL5sXCLU5sHCdtWFuLoChTuEf2CUYV1fSkx5ZLc5k3CdtWFuBnSuSYdsWEfBrrLFRlyvUnBMRMqekIZFT1WsXkpib7vSffvm3AZdZ1TCPjxkMlfrhthd5rh899MogY7fdmqhXad)BTm6ao)alqbsgAOhrn6WV1fScrf6y6yip6OnHWB6yiVxmWaDedm8V1YOt)ocfkqYqJ0GOgD436cwHOcD04jy8yOd)m2LKQIbh9e56gWCPbWZLYC5NXUKuXSl(rhthd5rhdRTN9bbJ5pqbsgACse1OJPJH8OJH12Z(YRaYOd)wxWkevOajdnaoIA0X0XqE0rmUkcOx60v5QL)aD436cwHOcfOaDkXSM02TarnsgAquJo8BDbRquHcKm0JOgD436cwHOcfizKge1Od)wxWkevOajJtIOgD436cwHOcfizaCe1OJPJH8OdmytefOd)wxWkevOajJ7GOgDmDmKhDkjXqE0HFRlyfIkuGKHwIOgD436cwHOcDmDmKhDAnSuSYdsWEfBrb6OXtW4XqhSnkp3G)OAkfSoFUULRtci0PeZAsB3cpK1KxbrhahfizO1iQrh(TUGviQqhthd5rhmri8rb77KNHOtjM1K2UfEiRjVcIo0JcKmaue1Od)wxWkevOJPJH8OdumA2BVYRgnJoLywtA7w4HSM8ki6qpkqYqdGquJo8BDbRquHoMogYJoMcZVjMN94lSaDkXSM02TWdzn5vq0HguGKHgAquJo8BDbRquHoA8emEm0PFbbRyIq4Jc23jpdR3YCLpxthtd2Zp3ommx3YLg0X0XqE0Plmf7bfxmwckqb60VJqHOgjdniQrh(TUGviQqhnEcgpg60VGGvszjbh3Fcj1BzUYNlfYTFbbRsXCPxc5I9opb0BDYn8si3kmmTu5s7CPbq52SzU9liyvXMcwqI6Tm3MnZLFg7ssU0oxNeWZLIOJPJH8Ot5adIWdlibkqYqpIA0X0XqE0bo)adg7HbEKIrh(TUGviQqbkqhyWMikquJKHge1OJPJH8OJ12VWc0HFRlyfIkuGc0rRGiQrYqdIA0HFRlyfIk0rJNGXJHo9liyTlieL4cJkMnDKBZM52VGGvtH53eZZE8fwuVLOJPJH8OtjjgYJcKm0JOgD436cwHOcDmDmKhDAy4X6c2pFWpCcjExJlRbreEcupcHfZ7YJzthem6OXtW4XqN(feS2feIsCHrfZMoYTzZCJPL9bXRgoxAdmx6buUnBMRM02j(sY8bSQyWrprU0gyU0JoV1YOtddpwxW(5d(HtiX7ACzniIWtG6riSyExEmB6GGrbsgPbrn6WV1fScrf6OXtW4Xqh5MlmytefSQAcrUYNlfYTFbbRDbHOexyuXSPJCB2mxnPTt8LK5dyvXGJEICPnWCPpxkIoMogYJoxi7NGBHOajJtIOgDmDmKhD6ccr5bVyjOd)wxWkevOajdGJOgDmDmKhD6mgYyPM3f6WV1fScrfkqY4oiQrhthd5rhWbZDbHOqh(TUGviQqbsgAjIA0X0XqE0XEnddSj8Atiqh(TUGviQqbsgAnIA0HFRlyfIk0rJNGXJHoYnxyWMikyv1ec0X0XqE0rBcH30XqEVyGb6igy4FRLrhgc5xZquGKbGIOgD436cwHOcD04jy8yOJCZTFbbRMcZVjMN94lSOElZv(C5NXUKuJPL9bX3AUpx3YLg0X0XqE0Xuy(nX8ShFHfOajdnacrn6WV1fScrf6y6yip60AyPyLhKG9k2Ic0rJNGXJHoyBuEUb)r1uky9wMR85sHCJPL9bXRgoxANRM02j(sY8bSQyWrprUnBMRCZfgSjIcwvXexxox5ZvtA7eFjz(awvm4ONix3aMRU03AU3dl5xLRCYLMCPi6OLOfSpmSloGizObfizOHge1Od)wxWkevOJgpbJhdDW2O8Cd(JQPuW6856wUsdGYvo5ITr55g8hvtPGv1fBXq(CLpx5MlmytefSQIjUUCUYNRM02j(sY8bSQyWrprUUbmxDPV1CVhwYVkx5KlnOJPJH8OtRHLIvEqc2RylkqbsgAOhrn6WV1fScrf6OXtW4Xqhyjle(WWU4aMRBaZL(CLpx5MB)ccw7ctXEqXfJLuVL5kFUuix5Ml2gLNBWFunLcwz3pWaMBZM5ITr55g8hvtPGvm3AZdZ1TCP152SzUyBuEUb)r1ukyD(CDlxkKl95kNC1eIqrC(RDHPypO4IXsQ6cd7IHEqSPJH8MixkMR0nx6b8CPi6y6yip60fMI9GIlglbfizOrAquJo8BDbRquHoA8emEm0PHHhRl4Axyk2dkUySepuYRZv(C1K2oXxsMpGvfdo6jY1nG5stUuMB)ccw7yIPGJIR3s0X0XqE0XvbbgcjEyGhPyuGKHgNern6WV1fScrf6OXtW4XqNggESUGRDHPypO4IXs8qjVox5ZLc5YpJDjPgtl7dIV1CFUULln52SzU8ZyxsYL25c4ak3MnZTFbbRMcZVjMN94lSOElZLIOJPJH8OJuJqmVlpSeZmkqYqdGJOgD436cwHOcD04jy8yOtddpwxW1UWuShuCXyjEOKxNR85YpJDjPgtl7dIV1CFUULlnOJPJH8Otxyk2JVWcuGKHg3brn6WV1fScrf6OXtW4Xqh5MlmytefSQAcrUYNBddpwxWvRTFHfEn5vtmKhDmDmKhDAy)alqbsgAOLiQrh(TUGviQqhnEcgpg6i3CHbBIOGvvtiYv(CBy4X6cUAT9lSWRjVAIH8OJPJH8OdSWueNBzHcfOaDaNFGfiQrYqdIA0HFRlyfIk0rJNGXJHo9liyfFJcbdH(smRh4q(6Tm3MnZLc5AamJNGRk2uWcsu536cwLBZM5AamJNGRMM93sVeYf7HcMBWv(TUGv5sXCLp3(feSIjcHpkyFN8mSElrhthd5rNohoZ87Jc2ZsyikqYqpIA0HFRlyfIk0rJNGXJHo9liyfkgn7Tx5vJMRyU1MhMlTZnMw2heVA4CLp3(feScfJM92R8QrZvm3AZdZL25sHCPjxkZvtA7eFjz(aMlfZv6MlnvAn6y6yip6afJM92R8QrZOajJ0GOgD436cwHOcD04jy8yOt)ccwXeHWhfSVtEgwXCRnpmxAdmxPbDmDmKhDWeHWhfSVtEgIcKmojIA0HFRlyfIk0rJNGXJHouixthtd2Zp3ommxG5stUnBMB)ccw7ctXEqXfJLuveN)CPyUYNBddpwxWvC09ygtec0X0XqE0btecFuW(o5zikqYa4iQrh(TUGviQqhnEcgpg6yamJNGRMM93sVeYf7HcMBWv(TUGv52SzUgaZ4j4QInfSGev(TUGvOJPJH8OtNdNz(9rb7zjmefizChe1OJPJH8OJAGLwOlqh(TUGviQqbkqb6y3OGGrNZ0sRqbkqia]] )


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