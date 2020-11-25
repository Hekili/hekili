-- RogueOutlaw.lua
-- June 2018
-- Contributed by Alkena.

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR


-- Conduits
-- [-] ambidexterity
-- [-] count_the_odds
-- [-] sleight_of_hand
-- [-] triple_threat


if UnitClassBase( "player" ) == "ROGUE" then
    local spec = Hekili:NewSpecialization( 260 )

    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Energy, {
        blade_rush = {
            aura = "blade_rush",

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

        acrobatic_strikes = 23470, -- 196924
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
        dreadblades = 19250, -- 343142

        dancing_steel = 22125, -- 272026
        blade_rush = 23075, -- 271877
        killing_spree = 23175, -- 51690
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        boarding_party = 853, -- 209752
        cheap_tricks = 142, -- 212035
        control_is_king = 138, -- 212217
        death_from_above = 3619, -- 269513
        dismantle = 145, -- 207777
        drink_up_me_hearties = 139, -- 212210
        honor_among_thieves = 3451, -- 198032
        maneuverability = 129, -- 197000
        plunder_armor = 150, -- 198529
        shiv = 3449, -- 248744
        smoke_bomb = 3483, -- 212182
        take_your_cut = 135, -- 198265
        thick_as_thieves = 1208, -- 221622
        turn_the_tables = 3421, -- 198020
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
            id = 315341,
            duration = 15,
            max_stack = 1,
        },
        blade_flurry = {
            id = 13877,
            duration = function () return talent.dancing_steel.enabled and 15 or 12 end,
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
            duration = 4,
            max_stack = 1,
        },
        crippling_poison = {
            id = 3408,
            duration = 3600,
            max_stack = 1,
        },
        detection = {
            id = 56814,
            duration = 30,
            max_stack = 1,
        },
        dreadblades = {
            id = 343142,
            duration = 10,
            max_stack = 1,
        },
        evasion = {
            id = 5277,
            duration = 10.001,
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
        instant_poison = {
            id = 315584,
            duration = 3600,
            max_stack = 1,
        },
        kidney_shot = {
            id = 408,
            duration = 6,
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
        numbing_poison = {
            id = 5761,
            duration = 3600,
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
        prey_on_the_weak = {
            id = 255909,
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
        -- Replaced this with "alias" for any of the other applied buffs.
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
            id = 315496,
            duration = function () return talent.deeper_stratagem.enabled and 42 or 36 end,
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
        wound_poison = {
            id = 8679,
            duration = 3600,
            max_stack = 1
        },

        -- Real RtB buffs.
        broadside = {
            id = 193356,
            duration = 30,
        },
        buried_treasure = {
            id = 199600,
            duration = 30,
        },
        grand_melee = {
            id = 193358,
            duration = 30,
        },
        skull_and_crossbones = {
            id = 199603,
            duration = 30,
        },        
        true_bearing = {
            id = 193359,
            duration = 30,
        },
        ruthless_precision = {
            id = 193357,
            duration = 30,
        },


        -- Fake buffs for forecasting.
        rtb_buff_1 = {
            duration = 30,
        },

        rtb_buff_2 = {
            duration = 30,
        },

        roll_the_bones = {
            alias = rtb_buff_list,
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = 30,
        },


        lethal_poison = {
            alias = { "instant_poison", "wound_poison", "slaughter_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
        },
        nonlethal_poison = {
            alias = { "crippling_poison", "numbing_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
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


        -- Legendaries (Shadowlands)
        concealed_blunderbuss = {
            id = 340587,
            duration = 8,
            max_stack = 1
        },

        greenskins_wickers = {
            id = 340573,
            duration = 15,
            max_stack = 1
        },

        -- Guile Charm
        shallow_insight = {
            id = 340582,
            duration = 10,
            max_stack = 1,
        },
        moderate_insight = {
            id = 340583,
            duration = 10,
            max_stack = 1,
        },
        deep_insight = {
            id = 340584,
            duration = 10,
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
        rogue   = { "stealth", "vanish", "shadow_dance" },
        mantle  = { "stealth", "vanish" },
        all     = { "stealth", "vanish", "shadow_dance", "shadowmeld" }
    }


    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.sepsis_buff.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.sepsis_buff.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up or buff.sepsis_buff.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains, buff.sepsis_buff.remains )
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
        return 0
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.all and ( not a or a.startsCombat ) then
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
            reduceCooldown( "blade_flurry", cdr )
            reduceCooldown( "grappling_hook", cdr )
            reduceCooldown( "roll_the_bones", cdr )
            reduceCooldown( "sprint", cdr )
            reduceCooldown( "blade_rush", cdr )
            reduceCooldown( "killing_spree", cdr )
            reduceCooldown( "vanish", cdr )
        end
    end )

    spec:RegisterHook( "reset_precast", function( amt, resource )
        if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end
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

            toggle = "cooldowns",
            nobuff = "stealth",

            handler = function ()
                applyBuff( "adrenaline_rush", 20 )

                energy.regen = energy.regen * 1.6
                energy.max = energy.max + 50

                forecastResources( "energy" )

                if talent.loaded_dice.enabled then
                    applyBuff( "loaded_dice", 45 )
                elseif azerite.brigands_blitz.enabled then
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

            usable = function () return stealthed.all or buff.sepsis_buff.up, "requires stealth or sepsis_buff" end,
            handler = function ()
                if debuff.dreadblades.up then
                    gain( combo_points.max, "combo_points" )
                else
                    gain( buff.broadside.up and 3 or 2, "combo_points" )
                end

                removeBuff( "sepsis_buff" )
            end,
        },


        between_the_eyes = {
            id = 315341,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 135610,

            usable = function() return combo_points.current > 0 end,

            handler = function ()
                if talent.prey_on_the_weak.enabled then
                    applyDebuff( "target", "prey_on_the_weak", 6 )
                end

                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                applyDebuff( "target", "between_the_eyes", combo_points.current ) 

                if azerite.deadshot.enabled then
                    applyBuff( "deadshot" )
                end

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end

                if legendary.greenskins_wickers.enabled and ( combo_points.current >= 5 or combo_points == animacharged_cp ) then
                    applyBuff( "greenskins_wickers" )
                end

                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" ) 
            end,
        },


        blade_flurry = {
            id = 13877,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 15,
            spendType = "energy",

            startsCombat = false,
            texture = 132350,

            usable = function () return buff.blade_flurry.remains < gcd.execute end,
            handler = function ()
                applyBuff( "blade_flurry" )
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
                applyBuff( "blade_rush", 5 )
            end,
        },


        blind = {
            id = 2094,
            cast = 0,
            cooldown = function () return talent.blinding_powder.enabled and 90 or 120 end,
            gcd = "spell",

            startsCombat = true,
            texture = 136175,

            handler = function ()
              applyDebuff( "target", "blind", 60 )
            end,
        },


        cheap_shot = {
            id = 1833,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( talent.dirty_tricks.enabled and 0 or 40 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132092,

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

            handler = function ()
                applyDebuff( "target", "cheap_shot", 4 )

                if talent.prey_on_the_weak.enabled then
                    applyDebuff( "target", "prey_on_the_weak", 6 )
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
                applyBuff( "cloak_of_shadows", 5 )
            end,
        },


        crimson_vial = {
            id = 185311,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 20 - conduit.nimble_fingers.mod end,
            spendType = "energy",

            startsCombat = false,
            texture = 1373904,

            handler = function ()
                applyBuff( "crimson_vial", 6 )
            end,
        },


        crippling_poison = {
            id = 3408,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            essential = true,
            
            startsCombat = false,
            texture = 132274,
            
            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "crippling_poison" )
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

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        distract = {
            id = 1725,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 30 * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132289,

            handler = function ()
            end,
        },


        dreadblades = {
            id = 343142,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            spend = 30,
            spendType = "energy",

            toggle = "cooldowns",
            talent = "dreadblades",

            startsCombat = true,
            texture = 458731,
            
            handler = function ()
                applyDebuff( "player", "dreadblades" )
                gain( buff.broadside.up and 2 or 1, "combo_points" )
            end,
        },


        evasion = {
            id = 5277,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = true,
            texture = 136205,
            
            handler = function ()
                applyBuff( "evasion" )
            end,
        },


        feint = {
            id = 1966,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return 35 - conduit.nimble_fingers.mod end,
            spendType = "energy",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                applyBuff( "feint", 5 )
            end,
        },


        ghostly_strike = {
            id = 196937,
            cast = 0,
            cooldown = 35,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            talent = "ghostly_strike",

            startsCombat = true,
            texture = 132094,

            handler = function ()
                applyDebuff( "target", "ghostly_strike", 10 )
                gain( buff.broadside.up and 2 or 1, "combo_points" )
            end,
        },


        gouge = {
            id = 1776,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return talent.dirty_tricks.enabled and 0 or 25 end,
            spendType = "energy",

            startsCombat = true,
            texture = 132155,

            -- Disable Gouge because we can't tell if we're in front of the target to use it.
            usable = function () return false end,
            handler = function ()
                gain( buff.broadside.up and 2 or 1, "combo_points" )
                applyDebuff( "target", "gouge", 4 )
            end,
        },


        grappling_hook = {
            id = 195457,
            cast = 0,
            cooldown = function () return ( 1 - conduit.quick_decisions.mod * 0.01 ) * ( talent.retractable_hook.enabled and 45 or 60 ) - ( level > 55 and 15 or 0 ) end,
            gcd = "spell",

            startsCombat = false,
            texture = 1373906,

            handler = function ()
            end,
        },


        instant_poison = {
            id = 315584,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            essential = true,
            
            startsCombat = false,
            texture = 132273,
            
            readyTime = function () return buff.lethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "instant_poison" )
            end,
        },


        kick = {
            id = 1766,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            toggle = "interrupts", 
            interrupt = true,

            startsCombat = true,
            texture = 132219,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                
                if conduit.prepared_for_all.enabled and cooldown.cloak_of_shadows.remains > 0 then
                    reduceCooldown( "cloak_of_shadows", 2 * conduit.prepared_for_all.mod )
                end
            end,
        },


        kidney_shot = {
            id = 408,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = function () return 25 * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132298,
            
            handler = function ()
                applyDebuff( "kidney_shot", 1 + combo_points.current )
                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( combo_points.current, "combo_points" )
            end,
        },


        killing_spree = {
            id = 51690,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            talent = "killing_spree",

            startsCombat = true,
            texture = 236277,

            toggle = "cooldowns",

            handler = function ()
                applyBuff( "killing_spree", 2 )
                setCooldown( "global_cooldown", 2 )
            end,
        },


        marked_for_death = {
            id = 137619,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = "marked_for_death", 

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
            end,

            handler = function ()
                gain( 5, "combo_points" )
            end,
        },


        numbing_poison = {
            id = 5761,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            essential = true,
            
            startsCombat = false,
            texture = 136066,
            
            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "numbing_poison" )
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
                if debuff.dreadblades.up then
                    gain( combo_points.max, "combo_points" )
                else
                    gain( 1 + ( buff.broadside.up and 1 or 0 ) + ( buff.opportunity.up and 1 or 0 ) + ( buff.concealed_blunderbuss.up and 2 or 0 ), "combo_points" )
                end

                removeBuff( "deadshot" )
                removeBuff( "opportunity" )
                removeBuff( "concealed_blunderbuss" ) -- Generating 2 extra combo points is purely a guess.
                removeBuff( "greenskins_wickers" )
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
                applyBuff( "riposte", 10 )
            end,
        },


        roll_the_bones = {
            id = 315508,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = false,
            texture = 1373910,

            handler = function ()
                for _, name in pairs( rtb_buff_list ) do
                    removeBuff( name )
                end

                if azerite.snake_eyes.enabled then
                    applyBuff( "snake_eyes", 12, 5 )
                end

                applyBuff( "rtb_buff_1" )

                if buff.loaded_dice.up then
                    applyBuff( "rtb_buff_2"  )
                    removeBuff( "loaded_dice" )
                end
            end,
        },


        sap = {
            id = 6770,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( talent.dirty_tricks.enabled and 0 or 35 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132310,

            handler = function ()
                applyDebuff( "target", "sap", 60 )
            end,
        },
        

        
        shiv = {
            id = 5938,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            spend = function () return legendary.tiny_toxic_blade.enabled and 0 or 20 end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 135428,
            
            handler = function ()
                gain( buff.broadside.up and 2 or 1, "combo_point" )
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
                applyBuff( "shroud_of_concealment", 15 )
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
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
                if debuff.dreadblades.up then
                    gain( combo_points.max, "combo_points" )
                else
                    gain( buff.broadside.up and 2 or 1, "combo_points" )
                end

                if buff.shallow_insight.up then buff.shallow_insight.expires = query_time + 10 end
                if buff.moderate_insight.up then buff.moderate_insight.expires = query_time + 10 end
                -- Deep Insight does not refresh, and I don't see a way to track why/when we'd advance from Shallow > Moderate > Deep.
            end,
        },


        slice_and_dice = {
            id = 315496,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = false,
            texture = 132306,

            usable = function()
                return combo_points.current > 0, "requires combo_points"
            end,

            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyBuff( "slice_and_dice", 6 + 6 * combo )
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
                applyBuff( "sprint", 8 )
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
                applyBuff( "stealth" )

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
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

            disabled = function ()
                return not ( boss and group )
            end,

            handler = function ()
                applyBuff( "vanish", 3 )
                applyBuff( "stealth" )

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end

                if legendary.invigorating_shadowdust.enabled then
                    for name, cd in pairs( cooldown ) do
                        if cd.remains > 0 then reduceCooldown( name, 20 ) end
                    end
                end
            end,
        },


        wound_poison = {
            id = 8679,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 134194,

            readyTime = function () return buff.lethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "wound_poison" )
            end,
        }


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

    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = "full"
    } )  


    spec:RegisterPack( "Outlaw", 20201123, [[d0KT(aqirHhPkKnPk5tGKqnkvrDkqIvbsQEfrLzreDlrP0Ue5xusgMOKJbsTmqPNPkOPPkuxtuKTruv(MOuyCQc4CIIsRJOQIMNQi3de7JsQdkkQAHeHhsuv1effvUiij1gbjfFuuuuJeKeYjbjLwPuQBcsc2jOQFcsIgkij5OevvyPIsrpvvnvqLRkkkSvIQk5RevvQ9IYFPyWO6WuTyP6XKmzsDzKnRWNjkJwkoTKvlkkYRbfZMWTfv7wPFdmCk1XvfOLd55qnDHRROTlL8DvPgprvoprA9Is18Pe7xLzqZGJ91Eqm4HnlyZcAOH9HjOZuMYgz9aSFi1MyFBxbJlJy)1Zj2hQCgc)n7B7sfaxZGJ9XGjsrSFte2y5NwzLSkAM9KcKBfUYNcpkWQq(iScx5kRy)(Sebu7Y6SV2dIbpSzbBwqdnSpmbDMYK8LPml7JTjfdEyLVSy)MsRPL1zFnHvS)Joou5me(7JNnbYM01(rhhEqlkVtOJd7dL84WMfSzX(2iWOee7)OJdvodH)(4ztGSjDTF0XHh0IY7e64W(qjpoSzbBwx7R9JoouT8i1mi9X70aGOJRa5DpoENKvloD8mVsr2b(4lyZ2ghLpMIJ7QOal(4GvinDTDvuGfNSrKcK39aIBBlKASbfgSxBxffyXjBePa5DpKdIv5ocgsBgaKrtE0iPnIuG8UhgmPaRgdjtswdiiV0gQfTrY1ACQwRFCwxBxffyXjBePa5DpKdIv4GCr0iznG8Cg0dolBBsNSbkyOaxzN0gfi3EgEuG1OPwLISyjdfai0G3BsjvjabcSLY0foos6jYJcSwSG8sBOw0gPABnflH8UGsK8kCGHY12vrbwCYgrkqE3d5GyfcieMOHmDWsyjTrKcK39WGjfy1yiWkznGGObIWnExqxBxffyXjBePa5DpKdIvyrPiJVAJUuKK2isbY7EyWKcSAmeyLSgqq0ar4gVlORTRIcS4KnIuG8UhYbXkxJO1f1sg0e3iPnIuG8UhgmPaRgdbAjRbKNZGEWzzBt6Knqbdf4k7K2Oa52ZWJcSgn1QuKflzOaaHg8EtkPkbiqGTuMUWXrsprEuG1IfKxAd1I2ivBRPyjK3fuIKxHdmuU2UkkWIt2isbY7EiheRMyYubLl565eep74gh5yZaSHbmm2G3e6A7QOalozJifiV7HCqSAIjtfuUK0yqQWSEobrjvjabcSLY0fooKSgqYa5L2qTOns12Akwc5DbLi5v4aFTV2p64q1YJuZG0hNAriPhpQC64rdDCxfa0Xl8X9wEj8UGsxBxffyXqGPuWCTF0XZMeoixenhVgh3gGXvxqh)5fC8wtXsiVlOJtlLxe(41ECfiV7buU2UkkWILdIv4GCr0CTF0XZMeciehhxRmbDCjGZQmZqfScojoEFog4J)UH2JBdW4QlORTRIcSy5GyvlhvExqsUEobbfDdIqaHqYwUysqqr30NJb(jyF9CFogP(evK2eiYXteLM2wS0NJrsgYxTjNeeLM2wS0NJrkqtY0jhvRS00gkxBxffyXYbXQwoQ8UGKC9CcIN3N4gJcS6kkWkzlxmjikqEhySb1g4KMgLQcRHaRCWc1FoCbTrswdahcPgCGkyOeTExq6xkaqObV3KSgaoesn4avWqjeL71IFcAOixFogPoc4ACPP00(fTesMuRLVSELrFogjmmtHW4R2OqamUdwcNM2VYOphJemezBKcMiZ7kWgVdMHrkyMM2x7hDC53v0C88PikBbD8WrYOal5XJMcF8woQ8UGoEHpUQHuWq6JhGJRjvPPJ)UHIgcDCmiNoU8pZHpoUbmf6J3PJJLUksF83v0CCjeUMoouJyIqsV2UkkWILdIvTCu5Dbj565eKUW1KziMiKudw6QKSLlMeeSnjeMWrYOaN6cxtMHyIqsFc2xiV0gQfTrY1ACQwRHnllw6ZXi1fUMmdXeHKMM2xBxffyXYbXkLlegxffynIchsUEobbhKlIgjRbeCqUiAiDYfIRTRIcSy5GyLYfcJRIcSgrHdjxpNGO04R9JooutTfU54EC8CxEv(m)4YFOQ0X)ZooqUkooyPJpaOJtUQ54sGaUgxA64(QpouPTnafZTcPh)DdThx(XSuWC8mhYFF8cFCmjivq6J7R(4qfgzUJx4JVG44iY1spUpccD8OHo(sYlooMuGvNoEMx82LIpEUlVJlravF83v0CCyL74zEfLU2UkkWILdIvO5ACvuG1ikCi565eKrTfUrYAarbY7aJnO2aBneLTj3LNbBtRoBFUphJuhbCnU0uAAlxFogjGTnafZTcPPPnuG6phUG2i9GZsbJrJ83jA9UG0VEoJWf0gPChbdPndaYOjpAs06DbPTyrbacn49MYDemK2maiJM8OjHOCVwS1qdfOa1F2ZoHQGsUImtBJuWezWcIArjKVW8eSwSKHcaeAW7n1P4nrRjAidjLWPPnuSyrbY7aJnO2adX3k3vnosgPnk7RTRIcSy5GyLYfcJRIcSgrHdjxpNG0NLqFTDvuGflheRCKYxYeaeI2qYAaHwcjtAstJsvH1qGotYrlHKjnHiz0ETDvuGflheRCKYxYypfy6A7QOalwoiwjkznb2KzAQLLtBCTDvuGflheR6UmdyycuPGbFTV2p64smlHMq4RTRIcS4uFwcneCt1sYAabnxAaqYOuuRutaKxPmDHRPe9GZY2M0xBxffyXP(SeA5GyfPAa1kZGiBuL7R(A7QOalo1NLqlheRWec5bPnDWsgSDbdjPsQsqMWrYOadbAjRbKm0GiHjeYdsB6GLmy7cgkfLcMALzXIRIQfzOLYlcdb6xiV0gQfTrY1ACQwRhtHWGivJJKrMOYjlwunosgHTg2xJswtyquUxl(PmDTF0XZmW0XHQkCaeh)3aIJ)UIMJdvABdqXCRq6XRXX7Ka8(4pothNwcjtQKhhGo(7gAp(exRSJl)ywkyoEMd5VpUV6Jl)Uc8Xl8X1G3B6A7QOalo1NLqlheRSlCaegCdiKSgq6ZXibSTbOyUvinnTF9mTesM0NECMSyjCbTr6bNLcgJg5Vt06DbPF1NJrcgISnsbtK5DfyJ3bZWifmtAW7fkxBxffyXP(SeA5GyLDHdGWGBaHK1asFogjGTnafZTcPPP9RN7ZXiPjxJBarAABXsFogjziIwmm1InVlfmecNM2wS0NJrsbwf5csB6I5QjuFIXPPnuU2UkkWIt9zj0YbXkCTfoiKbhOcg6AFTF0XL)aGqdEV4RTRIcS4KsJHOCHW4QOaRru4qY1ZjiegtRIWswdizGdYfrdPtUqCTDvuGfNuASCqSAiCzKq4rb2RTRIcS4KsJLdIvdHlJecpkWAucYxmjznGOP(CmsdHlJecpkWMquUxl(jyV2UkkWItknwoiw5AeTUOwYGM4gjRbKm6ZXi5AeTUOwYGM4M00(1ZzOaaHg8EtWucrTYmyBerPPTflzeUG2ibtje1kZGTreLO17csdLxpNb9GZY2M0jp74gh5yZaSHbmm2G3eYIffai0G3Bs4bTHXrkF9eIY9AXwdBwq5A7QOaloP0y5GyfcieMOHmDWsyjRbK(CmsiGqyIgY0blHtik3Rf)eKhAXslhvExqju0nicbeIR9Joou744UwJpUJOJpTL844TSPJhn0XblD83v0CCb4nHJJdhCzU0XZmW0XF3q7X1sRv2Xhooi0XJgFpU8hQ64AAuQkooaD83v0aMXX9v6XL)qvPRTRIcS4KsJLdIv5ocgsBgaKrtE0iPsQsqMWrYOadbAjRbeKxAd1I2i5AnonTF9C4izuKIkNmbWOl6jfiVdm2GAdCstJsvHflzGdYfrdPtiGSj9sbY7aJnO2aN00OuvyneLTj3LNbBtRoBHgkx7hDCO2XXxWXDTgF83LqCCDrh)Dfn1E8OHo(sYlo(dZcl5XNy64qfgzUJd2J3by8XFxrdygh3xPhx(dvLU2UkkWItknwoiwL7iyiTzaqgn5rJK1acYlTHArBKCTgNQ16hMv2I8sBOw0gjxRXj9e5rb2xzGdYfrdPtiGSj9sbY7aJnO2aN00OuvyneLTj3LNbBtRoBH(A)OJlHW10XHAetes6Xb7XHvUJtlLxeoD8pCh)DfnhpZN3lnjVGqvi94144l44UwJpEThpAOJVK8IJdDw4012vrbwCsPXYbXQUW1KziMiKujRbeSnjeMWrYOaBneyZwfy1ZksEEV0K8ccvH0eTExq6xz0NJrQlCnzgIjcjnnTFH8sBOw0gjxRXPATg6SU2UkkWItknwoiwjRbGdHudoqfmKK1aIcK3bgBqTboPPrPQWAiqlxFogPoc4ACPP00(A7QOaloP0y5GyfmLquRmd2grKK1aslhvExqPUW1KziMiKudw6QErlHKjnfvozcGj3LN1WETDvuGfNuASCqSQlCnzqtCJK1aslhvExqPUW1KziMiKudw6QErlHKjnfvozcGj3LN1WETF0XZmW1k74YV8TWnwL5Z7tCZXl8XbRq6X9J3IqspEuR0JxRcroMK84yWXR94iYfvivYJlfmHkgrh37yGygKq6Xh1shpahFIPJxXXD8X9JpJsuH0JJTjHiDTDvuGfNuASCqSQLVfUrYAajdCqUiAiDYfIxTCu5DbL88(e3yuGvxrb2RTRIcS4KsJLdIvAe56UW1ewYAajdCqUiAiDYfIxkqEhySb1g4NGa912vrbwCsPXYbXkCJRbVZjHwYAajdCqUiAiDYfIxTCu5DbL88(e3yuGvxrb2RTRIcS4KsJLdIvyYgxyjRbKmWb5IOH0jxiU2UkkWItknwoiwzdIcSswdi95yK6caqlM4iHixfwS0NJrY1iADrTKbnXnPP912vrbwCsPXYbXQUaa0MXej9A7QOaloP0y5GyvNqycbtTYU2UkkWItknwoiwnke1faG(A7QOaloP0y5GyLVkchixyuUqCTDvuGfNuASCqSAIjtfuUK0yqQWSEobrjvjabcSLY0fooKSgqYahKlIgsNCH4vFogjxJO1f1sg0e3K0G37R(Cms5uoaj1aggXuvAJgrEooPbV3x0sizstrLtMayYD5z9JFHIUPphd8tz6A7QOaloP0y5Gy1etMkOCjxpNG4zh34ihBgGnmGHXg8Mqswdiz0NJrY1iADrTKbnXnPP9Rm6ZXi1fUMmdXeHKMM2VuaGqdEVjxJO1f1sg0e3KquUxl(jOZ01(rhx(fHKECeykRri94OPGooyC8OzM3Rrr6JN7rd(4DsaEl)84zgy64da64qTlm2a9XvOkK84GOHqVlmD83v0C8mF284ECCyZsUJJdxbd(4a0XHol5o(7kAoUlWGJlHaa0hFANU2UkkWItknwoiwnXKPckxY1ZjioUPLVe2G8Sdqgfa5cjRben1NJrc5zhGmkaYfgn1NJrsdEVwSOP(CmskWQNQOArMAHXOP(Cmst7xHJKrrQHCr0KSvXtpe2xHJKrrQHCr0KSvH1qEywwSKHM6ZXiPaREQIQfzQfgJM6ZXinTF9SM6ZXiH8Sdqgfa5cJM6ZXiHdxbJ1qGnRSf6SG6AQphJuxaaAdyyIgYqlLlnnTTyzuYAcdIY9AXpjFzbLx95yKCnIwxulzqtCtcr5ETyRH(bU2p64zoA4trC8HleDxbZXha0XNyVlOJxbLJtxBxffyXjLglheRMyYubLJLSgq6ZXi1faGwmXrcrUkSyzuYAcdIY9AXpbb2SSyrbY7aJnO2aN00Ouv8eeyV2x7hDCOAmMwfHV2UkkWItegtRIWquGvrBG8G0MHWZjjRbeAjKmPPOYjtam5U8Sg6xz0NJrQlCnzgIjcjnnTF9CgAqKuGvrBG8G0MHWZjtFI2uukyQv2RmCvuGnPaRI2a5bPndHNtPAndrjRjSyzmfcdIunosgzIkNEsMsNYD5bLRTRIcS4eHX0QiSCqSQlaaTbmmrdzOLYLkznG0YrL3fuQlCnzgIjcj1GLUQxkaqObV3uNI3eTMOHmKucNM2VEgBtcHjCKmkWPUW1KziMiKuRHaRfliV0gQfTrY1ACQwRFCMGY12vrbwCIWyAvewoiwjB6iD5RbmmE2jeiAU2UkkWItegtRIWYbXQbqnXK24zNqvqMo55swdiyBsimHJKrbo1fUMmdXeHKAneyTyb5L2qTOnsUwJt1AT8L1Rm6ZXi5AeTUOwYGM4M00(A7QOalorymTkclheRSNOAiTwzMUWXHK1ac2Mect4izuGtDHRjZqmriPwdbwlwqEPnulAJKR14uTwlFzDTDvuGfNimMwfHLdIvrdzMBhmxTzaqksYAaPphJeIuWiim2maifLM2wS0NJrcrkyeegBgaKImkWCdcLWHRG5jOZ6A7QOalorymTkclheRqLTTGm1AW2UIU2UkkWItegtRIWYbXQ3aKq3IQ1Gimy9vrxBxffyXjcJPvry5GyvoLdqsnGHrmvL2OrKNJLSgqOLqYK(0JZ01(rhhQiGqF8Sj521k74qncpNWhFaqhNKhPMbDCKVYOJdqhhMsioEFogyjpEnoUnaJRUGshpZlE7sXhpqspEaoUmkoE0qhxaEt444kaqObV3J3DmPpoypU3YlH3f0XPLYlcNU2UkkWItegtRIWYbXke521kZmeEoHLujvjit4izuGHaTK1as4izuKIkNmbWOl6jOtzYILNFoCKmksnKlIMKTkS(bYYILWrYOi1qUiAs2Q4jiWMfuE9SRIQfzOLYlcdbAlwA5OY7ckHi3UwzgnjCPwdBMfkqXILNdhjJIuu5KjagBvyGnlRFywVE2vr1Im0s5fHHaTflTCu5DbLqKBxRmJMeUuRF8JHcuU2x7hDCOMAlCdHWx7hDCjcO6Jd2JRaaHg8EpEaoomezF8OHoU8hvXX1uFoghFAFTDvuGfNg1w4giDkEt0AIgYqsj812vrbwCAuBHBKdIvyrPiJVAJUuKK1asFogjSOuKXxTrxkkHOCVw8tJswtyquUxl(vFogjSOuKXxTrxkkHOCVw8tpdTCkqEhySb1gyOa1Ho9axBxffyXPrTfUroiwPlSThQMR91(rh)hKlIMRTRIcS4eoixenqunKBBWnGqsLuLGmHJKrbgc0swdiHlOns2isQbSMOHmVjhMeTExq6xzeosgfPcB6am(A7QOaloHdYfrJCqSYZ7tCd73Iq4cSm4HnlyZcAOZs(y)3oARvgM9HAZTbOG0hpBCCxffypUOWboDTzFrHdmdo2NWyAveMbhdEOzWX(06DbPzsW(kufeQC2NwcjtAkQCYeatUlVJB9XH(4VoEghVphJux4AYmetesAAAF8xh)5JNXX1GiPaRI2a5bPndHNtM(eTPOuWuRSJ)64zCCxffytkWQOnqEqAZq45uQwZquYAIJBXYXhtHWGivJJKrMOYPJ)0XLP0PCxEhhkSVRIcSSVcSkAdKhK2meEoXcg8WYGJ9P17csZKG9vOkiu5SFlhvExqPUW1KziMiKudw6Qo(RJRaaHg8EtDkEt0AIgYqsjCAAF8xh)5JJTjHWeosgf4ux4AYmetes6XTgYXH94wSCCKxAd1I2i5Anov7XT(4pothhkSVRIcSSFxaaAdyyIgYqlLlLfm4Fido23vrbw2x20r6Yxdyy8Stiq0W(06DbPzsWcg8pMbh7tR3fKMjb7RqvqOYzFSnjeMWrYOaN6cxtMHyIqspU1qooSh3ILJJ8sBOw0gjxRXPApU1hx(Y64VoEghVphJKRr06IAjdAIBstB23vrbw2FautmPnE2jufKPtEolyWNjgCSpTExqAMeSVcvbHkN9X2KqychjJcCQlCnzgIjcj94wd54WEClwooYlTHArBKCTgNQ94wFC5ll23vrbw23EIQH0ALz6chhSGbV8XGJ9P17csZKG9vOkiu5SFFogjePGrqySzaqkknTpUflhVphJeIuWiim2maifzuG5gekHdxbZXF64qNf77QOal7hnKzUDWC1MbaPiwWGpBWGJ9DvuGL9rLTTGm1AW2UIyFA9UG0mjybd(hGbh77QOal7)gGe6wuTgeHbRVkI9P17csZKGfm4ZSm4yFA9UG0mjyFfQccvo7tlHKj94pD8hNj23vrbw2pNYbiPgWWiMQsB0iYZXSGbp0zXGJ9P17csZKG9DvuGL9rKBxRmZq45eM9vOkiu5SF4izuKIkNmbWOl64pDCOtz64wSC8Np(ZhpCKmksnKlIMKTkoU1h)bY64wSC8WrYOi1qUiAs2Q44pb54WM1XHYXFD8NpURIQfzOLYlcFCihh6JBXYXB5OY7ckHi3UwzgnjCPh36JdBM94q54q54wSC8NpE4izuKIkNmbWyRcdSzDCRp(dZ64Vo(Zh3vr1Im0s5fHpoKJd9XTy54TCu5DbLqKBxRmJMeU0JB9XF8JpouoouyFLuLGmHJKrbMbp0SGfSVMg(uem4yWdndo23vrbw2hMsbd7tR3fKMjblyWdldo23vrbw2hhKlIg2NwVlintcwWG)Hm4yFA9UG0mjyFGn7JPG9DvuGL9B5OY7cI9B5IjX(OOB6ZXaF8NooSh)1XF(495yK6turAtGihpruAAFClwoEFogjziF1MCsquAAFClwoEFogPanjtNCuTYst7Jdf2VLJmRNtSpk6geHacblyW)ygCSpTExqAMeSpWM9XuW(UkkWY(TCu5DbX(TCXKyFfiVdm2GAdCstJsvXXTgYXH94YDCypou)4pF8Wf0gjznaCiKAWbQGHs06DbPp(RJRaaHg8EtYAa4qi1GdubdLquUxl(4pDCOpouoUChVphJuhbCnU0uAAF8xhNwcjt6XT(4Yxwh)1XZ4495yKWWmfcJVAJcbW4oyjCAAF8xhpJJ3NJrcgISnsbtK5DfyJ3bZWifmttB2VLJmRNtSVN3N4gJcS6kkWYcg8zIbh7tR3fKMjb7dSzFmfSVRIcSSFlhvExqSFlxmj2hBtcHjCKmkWPUW1KziMiK0J)0XH94VooYlTHArBKCTgNQ94wFCyZ64wSC8(CmsDHRjZqmriPPPn73YrM1Zj2VlCnzgIjcj1GLUkwWGx(yWX(06DbPzsW(kufeQC2hhKlIgsNCHG9DvuGL9vUqyCvuG1ikCW(IchM1Zj2hhKlIgwWGpBWGJ9P17csZKG9DvuGL9vUqyCvuG1ikCW(IchM1Zj2xPXSGb)dWGJ9P17csZKG9vOkiu5SVcK3bgBqTb(4wd54kBtUlpd2Mw9XZ2J)8X7ZXi1raxJlnLM2hxUJ3NJrcyBdqXCRqAAAFCOCCO(XF(4HlOnsp4SuWy0i)DIwVli9XFD8NpEghpCbTrk3rWqAZaGmAYJMeTExq6JBXYXvaGqdEVPChbdPndaYOjpAsik3RfFCRpo0hhkhhkhhQF8NpUNDcvbLCfzM2gPGjYGfe1IsiFH54pDCypUflhpJJRaaHg8EtDkEt0AIgYqsjCAAFCOCClwoUcK3bgBqTb(4qoUVvURACKmsBu2SVRIcSSpAUgxffynIchSVOWHz9CI9h1w4gwWGpZYGJ9P17csZKG9DvuGL9vUqyCvuG1ikCW(IchM1Zj2VplHMfm4HolgCSpTExqAMeSVcvbHkN9PLqYKM00OuvCCRHCCOZ0XL740sizstisgTSVRIcSSVJu(sMaGq0gSGbp0qZGJ9DvuGL9DKYxYypfyI9P17csZKGfm4HgwgCSVRIcSSVOK1eytMPPwwoTb7tR3fKMjblyWd9dzWX(UkkWY(DxMbmmbQuWGzFA9UG0mjyblyFBePa5DpyWXGhAgCSVRIcSSVBBlKASbfgSSpTExqAMeSGbpSm4yFA9UG0mjyFxffyz)ChbdPndaYOjpAyFfQccvo7J8sBOw0gjxRXPApU1h)XzX(2isbY7EyWKcSAm7NjwWG)Hm4yFA9UG0mjyFfQccvo7)8XZ440dolBBsNSbkyOaxzN0gfi3EgEuG1OPwLIoUflhpJJRaaHg8EtkPkbiqGTuMUWXrsprEuG94wSCCKxAd1I2ivBRPyjK3fuIKxHd8XHc77QOal7JdYfrdlyW)ygCSpTExqAMeSVRIcSSpcieMOHmDWsy2xHQGqLZ(iAGiCJ3fe7BJifiV7HbtkWQXSpSSGbFMyWX(06DbPzsW(UkkWY(yrPiJVAJUue7RqvqOYzFenqeUX7cI9TrKcK39WGjfy1y2hwwWGx(yWX(06DbPzsW(UkkWY(UgrRlQLmOjUH9vOkiu5S)ZhpJJtp4SSTjDYgOGHcCLDsBuGC7z4rbwJMAvk64wSC8moUcaeAW7nPKQeGab2sz6chhj9e5rb2JBXYXrEPnulAJuTTMILqExqjsEfoWhhkSVnIuG8UhgmPaRgZ(qZcg8zdgCSpTExqAMeS)65e77zh34ihBgGnmGHXg8MqSVRIcSSVNDCJJCSza2WaggBWBcXcg8pado2NwVlintc23vrbw2xjvjabcSLY0fooyFfQccvo7NXXrEPnulAJuTTMILqExqjsEfoWSpngKkmRNtSVsQsaceylLPlCCWcwW(9zj0m4yWdndo2NwVlintc2xHQGqLZ(O5sdasgLIALAcG8kLPlCnLOhCw22KM9DvuGL9XnvlwWGhwgCSVRIcSSpPAa1kZGiBuL7RM9P17csZKGfm4Fido2NwVlintc23vrbw2htiKhK20blzW2fme7RqvqOYz)moUgejmHqEqAthSKbBxWqPOuWuRSJBXYXDvuTidTuEr4Jd54qF8xhh5L2qTOnsUwJt1ECRp(ykegePACKmYevoDClwoUQXrYi8XT(4WE8xhFuYAcdIY9AXh)PJNj2xjvjit4izuGzWdnlyW)ygCSpTExqAMeSVcvbHkN97ZXibSTbOyUvinnTp(RJ)8XPLqYKE8No(JZ0XTy54HlOnsp4SuWy0i)DIwVli9XFD8(CmsWqKTrkyImVRaB8oyggPGzsdEVhhkSVRIcSSVDHdGWGBablyWNjgCSpTExqAMeSVcvbHkN97ZXibSTbOyUvinnTp(RJ)8X7ZXiPjxJBarAAFClwoEFogjziIwmm1InVlfmecNM2h3ILJ3NJrsbwf5csB6I5QjuFIXPP9XHc77QOal7Bx4aim4gqWcg8Yhdo23vrbw2hxBHdczWbQGHyFA9UG0mjyblyFCqUiAyWXGhAgCSpTExqAMeSVRIcSSVQHCBdUbeSVcvbHkN9dxqBKSrKudynrdzEtomjA9UG0h)1XZ44HJKrrQWMoaJzFLuLGmHJKrbMbp0SGbpSm4yFxffyzFpVpXnSpTExqAMeSGfSVsJzWXGhAgCSpTExqAMeSVcvbHkN9Z444GCr0q6KleSVRIcSSVYfcJRIcSgrHd2xu4WSEoX(egtRIWSGbpSm4yFxffyz)HWLrcHhfyzFA9UG0mjybd(hYGJ9P17csZKG9vOkiu5SVM6ZXineUmsi8OaBcr5ET4J)0XHL9DvuGL9hcxgjeEuG1OeKVyIfm4Fmdo2NwVlintc2xHQGqLZ(zC8(CmsUgrRlQLmOjUjnTp(RJ)8XZ44kaqObV3emLquRmd2gruAAFClwoEghpCbTrcMsiQvMbBJikrR3fK(4q54Vo(ZhpJJtp4SSTjDYZoUXro2maByadJn4nHoUflhxbacn49MeEqByCKYxpHOCVw8XT(4WM1XHc77QOal77AeTUOwYGM4gwWGptm4yFA9UG0mjyFfQccvo73NJrcbect0qMoyjCcr5ET4J)eKJ)WJBXYXB5OY7ckHIUbriGqW(UkkWY(iGqyIgY0blHzbdE5Jbh7tR3fKMjb77QOal7N7iyiTzaqgn5rd7RqvqOYzFKxAd1I2i5AnonTp(RJ)8XdhjJIuu5KjagDrh)PJRa5DGXguBGtAAuQkoUflhpJJJdYfrdPtiGSjD8xhxbY7aJnO2aN00OuvCCRHCCLTj3LNbBtR(4z7XH(4qH9vsvcYeosgfyg8qZcg8zdgCSpTExqAMeSVcvbHkN9rEPnulAJKR14uTh36J)WSoE2ECKxAd1I2i5AnoPNipkWE8xhpJJJdYfrdPtiGSjD8xhxbY7aJnO2aN00OuvCCRHCCLTj3LNbBtR(4z7XHM9DvuGL9ZDemK2maiJM8OHfm4FagCSpTExqAMeSVcvbHkN9X2KqychjJc8XTgYXH94z7XvGvpRi559stYliufst06DbPp(RJNXX7ZXi1fUMmdXeHKMM2h)1XrEPnulAJKR14uTh36JdDwSVRIcSSFx4AYmetesklyWNzzWX(06DbPzsW(kufeQC2xbY7aJnO2aN00OuvCCRHCCOpUChVphJuhbCnU0uAAZ(UkkWY(YAa4qi1GdubdXcg8qNfdo2NwVlintc2xHQGqLZ(TCu5DbL6cxtMHyIqsnyPR64VooTesM0uu5KjaMCxEh36Jdl77QOal7dtje1kZGTreXcg8qdndo2NwVlintc2xHQGqLZ(TCu5DbL6cxtMHyIqsnyPR64VooTesM0uu5KjaMCxEh36Jdl77QOal73fUMmOjUHfm4HgwgCSpTExqAMeSVcvbHkN9Z444GCr0q6Kleh)1XB5OY7ck559jUXOaRUIcSSVRIcSSFlFlCdlyWd9dzWX(06DbPzsW(kufeQC2pJJJdYfrdPtUqC8xhxbY7aJnO2aF8NGCCOzFxffyzFnICDx4AcZcg8q)ygCSpTExqAMeSVcvbHkN9Z444GCr0q6Kleh)1XB5OY7ck559jUXOaRUIcSSVRIcSSpUX1G35KqZcg8qNjgCSpTExqAMeSVcvbHkN9Z444GCr0q6KleSVRIcSSpMSXfMfm4Hw(yWX(06DbPzsW(kufeQC2VphJuxaaAXehje5Q44wSC8(CmsUgrRlQLmOjUjnTzFxffyzFBquGLfm4HoBWGJ9DvuGL97caqBgtKu2NwVlintcwWGh6hGbh77QOal73jeMqWuRm2NwVlintcwWGh6mldo23vrbw2FuiQlaan7tR3fKMjblyWdBwm4yFxffyzFFveoqUWOCHG9P17csZKGfm4HfAgCSpTExqAMeSVRIcSSVsQsaceylLPlCCW(kufeQC2pJJJdYfrdPtUqC8xhVphJKRr06IAjdAIBsAW794VoEFogPCkhGKAadJyQkTrJiphN0G37XFDCAjKmPPOYjtam5U8oU1h)Xh)1Xrr30NJb(4pD8mX(0yqQWSEoX(kPkbiqGTuMUWXblyWdlSm4yFA9UG0mjyFxffyzFp74gh5yZaSHbmm2G3eI9vOkiu5SFghVphJKRr06IAjdAIBst7J)64zC8(CmsDHRjZqmriPPP9XFDCfai0G3BY1iADrTKbnXnjeL71Ip(thh6mX(RNtSVNDCJJCSza2WaggBWBcXcg8W(qgCSpTExqAMeSVRIcSSVJBA5lHnip7aKrbqUG9vOkiu5SVM6ZXiH8Sdqgfa5cJM6ZXiPbV3JBXYX1uFogjfy1tvuTitTWy0uFogPP9XFD8WrYOi1qUiAs2Q44pD8hc7XFD8WrYOi1qUiAs2Q44wd54pmRJBXYXZ44AQphJKcS6PkQwKPwymAQphJ00(4Vo(Zhxt95yKqE2biJcGCHrt95yKWHRG54wd54WM1XZ2JdDwhhQFCn1NJrQlaaTbmmrdzOLYLMM2h3ILJpkznHbr5ET4J)0XLVSoouo(RJ3NJrY1iADrTKbnXnjeL71IpU1hh6hG9xpNyFh30YxcBqE2biJcGCblyWd7JzWX(06DbPzsW(kufeQC2VphJuxaaAXehje5Q44wSC8rjRjmik3RfF8NGCCyZ64wSCCfiVdm2GAdCstJsvXXFcYXHL9DvuGL9NyYubLJzbly)rTfUHbhdEOzWX(UkkWY(DkEt0AIgYqsjm7tR3fKMjblyWdldo2NwVlintc2xHQGqLZ(95yKWIsrgF1gDPOeIY9AXh)PJpkznHbr5ET4J)6495yKWIsrgF1gDPOeIY9AXh)PJ)8XH(4YDCfiVdm2GAd8XHYXH6hh60dW(UkkWY(yrPiJVAJUuelyW)qgCSVRIcSSVUW2EOAyFA9UG0mjyblyb77ZObGy)FLl)zblym]] )

end