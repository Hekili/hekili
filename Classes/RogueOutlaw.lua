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

            usable = function () return talent.dirty_tricks.enabled and settings.dirty_gouge, "requires dirty_tricks and dirty_gouge checked" end,

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

    spec:RegisterSetting( "dirty_gouge", false, {
        name = "Use |T132155:0|t Gouge with Dirty Tricks",
        desc = "If checked, the addon will recommend |T132155:0|t Gouge when Dirty Tricks is talented and you do not have " ..
            "enough energy to Sinister Strike.  |cFFFFD100This may be problematic for positioning|r, as you'd need to be in front of your " ..
            "target.\n\nThis setting is unchecked by default.",
        type = "toggle",
        width = "full",
    } )


    spec:RegisterPack( "Outlaw", 20201128, [[dW0RRaqiPipIIKnbv1NuOemkkcNIevRIeP6vaPzbv5wue1UK4xKGHbv4yaXYGk9mOIAAuKQRbvKTrIKVPqfnofk6CueX6OiszEKiUhG2NuuhKePyHavpuHknrfQQlQqvAJkukFuHsOtQqvSsPWnjrkTtGYpPiLgkfP4OkuIwQcv4Ps1ubWvPis2kfrQ(QcLu7vL)sPbJ0HfwSKEmPMmrxg1MHYNjjJwkDArRwHsYRviZMWTvWUv63GgofoUcfwoINdz6uDDfTDa67KqJNeLZtsTEfkvZNIA)Q6dKdGRldNpWWfh4Idqab3XSaIsHdtcoRux3vBWx3i0Jcv813yGVUPD6IqXRBeQfWqEaCDeCs081BD3azstbfuLE7Sw0Wbfq5WueEcxnjWCfq5GwHRxNPWhp7vVUmC(adxCGloabeChZcikfomj4AsUoYG1hy4Qu446TPuY7vVUKr6RBQNAANUiu8PJdOQj)nm1tbdcipuzYtXDmX7P4IdCXX1niqSuWx3up10oDrO4thhqvt(ByQNcgeqEOYKNI7yI3tXfh4IJVX3WupD8QmwpDw(0kJbj8t1WHA4pTYQYfvEQsJwZgo6PlCn52GmGnfpn0Ecx0tHRqD5BeApHlQyqynCOgoWWWqO2AateC)gH2t4IkgewdhQHdkqfgcYiwAXGeRKdVfpdcRHd1WTiwdxjcioHxIbKeP0YaYRxcPevYTzthhFJq7jCrfdcRHd1WbfOciNdH3IxIb0enXJXmnmyzXaQhXokh7S0QHdgtp8eUwjdyQzZMBsdHcjuXTOvRfqNa3uBRIa5f5KeEcxZMjrkTmG86LCbCkwMevbxyLLihP8VrO9eUOIbH1WHA4GcubcuiSElBRWLr4zqynCOgUfXA4kraXfVediHXimQnQc(BeApHlQyqynCOgoOavajsnBJvALPMXZGWA4qnClI1WvIaIlEjgqcJryuBuf83i0EcxuXGWA4qnCqbQqij8gICzlzIAXZGWA4qnClI1WvIaccEjgqt0epgZ0WGLfdOEe7OCSZsRgoym9Wt4ALmGPMnBUjnekKqf3IwTwaDcCtTTkcKxKts4jCnBMeP0YaYRxYfWPyzsufCHvwICKY)gFdt90XRYy90z5tzazI6N65a)uVLFAODi5Pj6PbGrkIQGlFJq7jCrahL6rFdt90XbJCoeE7ttSNAarOSk4NAIf(uaNILjrvWpLxEiz0tZ9PA4qnCL)ncTNWfbkqfqohcV9ByQNooycuiEkkxvc(PGdGcJfvAvaaWFADIHHEQIT8(udicLvb)ncTNWfbkqfamizufmEBmWajE1sycuiWdWqmzGeVARtmmKsWfFtuNyyL6KKS06eoqtcxMgMnxNyyfvKyL2bwWCzAy2CDIHvCYKTvoi5QQmnu(3i0EcxeOavaWGKrvW4TXadmgQtuRvdxz6jCXdWqmzGA4qfAnG56OIKXsD6ndexqXvPBcpe86fvTqKluBrojhXfEJQGL4RHqHeQ4wu1crUqTf5KCexi8qKlsjGOCqRtmSsLadjkLCzAGpVmrL6MvkCGFt1jgwbnAke2yLwnbIqv4YOY0a)MQtmSYiMnSQHtIvX0r2OcNUvnCwMgFdt90X60BF6Wu4PHGFQhevSJW7PEBIEkGbjJQGFAIEQUL1Jy5tD4tLSoL8tvSL9wM8ueCGF64o(ONIAHtH8Pv(Pi1RMLpvX0BFk4IqYpDSjMeI6VrO9eUiqbQaGbjJQGXBJbgyves2IjMeIAls9QXdWqmzGidwiSEquXoQufHKTyIjHOwj4IpjsPLbKxVesjQKBZ4IdZMRtmSsves2IjMeI6Y04BeApHlcuGkOdHWgApHRvKihVngyGiNdH3IxIbe5Ci8wwwcH4BeApHlcuGkOdHWgApHRvKihVngyGAj6ByQNo2YnrTpn8NoeklhMdpDCnnLN2NvKtcT)u4YpfdsEkh62Ncobgsuk5NgR8PMwddiXNB6QFQIT8(0XYzQh90XNek(0e9uelyTZYNgR8PkTyJ)tt0txO)uchs1pnWCM8uVLF6YkZFkI1Wvw(gH2t4IafOcK5AdTNW1ksKJ3gdmqSCtulEjgqnCOcTgWCDuZa1g2HqzwKbVst2e1jgwPsGHeLsUmnaToXWkqddiXNB6QltdLR0nHhcE9Yymt9iRKekw4nQcwIVjAYdbVEziiJyPfdsSso82cVrvWsZM1qOqcvCldbzelTyqIvYH3wi8qKlQzquUYnBwdhQqRbmxhbm2Ci0TbrflTAJVrO9eUiqbQGoecBO9eUwrIC82yGbwNPq(ncTNWfbkqfcIow26qcHxhVediVmrL6IKXsD6ndeeCcuEzIk1fcRI3VrO9eUiqbQqq0XYwJPaXFJq7jCrGcubrQQ1r2XQPu1aV(3i0EcxeOavOgQSqmRts9i034ByQNc(mfsMG(gH2t4Ik1zkKarTjG4LyajZLXGevCXZvT1Hkl12QiKCHhJzAyWYVrO9eUOsDMcjOavG1TWCvzjSbjhIv(ncTNWfvQZuibfOciMqcNL2kCzlYihX4PvRfS1dIk2rabbVedytsOxqmHeolTv4YwKroIlEQhLRkZMdTNaYwE5HKrabbFsKsldiVEjKsuj3MXMcHLW62GOITEoWMnRBdIkg1mU4JLQADlHhICrkbN(gM6PMui(PMMe5qXt7Tq)PkME7tnTggqIp30v)0e7Pvwav8PMoo9uEzIk149ui5Pk2Y7tNOCv90XYzQh90XNek(0yLpDSoD0tt0tLqf3Y3i0EcxuPotHeuGkyKihkSOwOJxIbSoXWkqddiXNB6Qltd8nbVmrLALy64KzZEi41lJXm1JSssOyH3Okyj(1jgwzeZgw1WjXQy6iBuHt3QgolsOIRY)gH2t4Ik1zkKGcubJe5qHf1cD8smG1jgwbAyaj(CtxDzAGVjQtmSIKdjQf6LPHzZ1jgwrfH5fnkxKvXupIjOY0WS56edROHRMdblTvXCLmPorOY0q5FJq7jCrL6mfsqbQak3e5mXICsoI)gH2t4Ik1zkKGcubvWPkgVedOhcE9ImjUARts9iuH3Okyj(A4qfAnG56OIKXsD6ndeeqRtmSsLadjkLCzA8n(gM6PJlekKqfx03i0EcxurlraXeHkwicpH73i0EcxurlrGcubmrOIfIWt4A1coweJxIbuY1jgwbteQyHi8eUfcpe5IucUFJq7jCrfTebkqfcjH3qKlBjtulEjgWMQtmSsij8gICzlzIAltd8nrtAiuiHkULrPqKRklYGWCzAy2CtEi41lJsHixvwKbH5cVrvWsL)ncTNWfv0seOavGafcR3Y2kCzeEjgW6edRqGcH1BzBfUmQq4HixKsaIZMndyqYOk4cXRwctGcX3WupD8G90qkrpni8tNg49u0Mg8t9w(PWLFQIP3(uburg5pfaag)YtnPq8tvSL3NkvNRQNIfiNjp1BJ9PJRP5Psgl1P)ui5PkMElC6pnw1pDCnnLVrO9eUOIwIafOcdbzelTyqIvYH3INwTwWwpiQyhbee8smGKiLwgqE9siLOY0aFt4brf7fphyRdTYKvIgouHwdyUoQizSuNUzZnHCoeEllleOQjJVgouHwdyUoQizSuNEZa1g2HqzwKbVstgeL)nm1thpypDHpnKs0tvmfINkt(PkMEBUp1B5NUSY8NIZ4aH3tNi(PkTyJ)tH7tRqe6PkMElC6pnw1pDCnnLVrO9eUOIwIafOcdbzelTyqIvYH3IxIbKeP0YaYRxcPevYTzCghMmjsPLbKxVesjQiNKWt4IFtiNdH3YYcbQAY4RHdvO1aMRJksgl1P3mqTHDiuMfzWR0Kb5ByQNcUiK8thBIjHO(PW9P4c6t5LhsgvEAhGNQy6TpvPzOMswzotsx9ttSNUWNgsj6P5(uVLF6YkZFki4av(gH2t4IkAjcuGkufHKTyIjHOgVediYGfcRhevSJAgiUMSgUYz6LyOMswzotsxDH3Okyj(nvNyyLQiKSftmje1LPb(KiLwgqE9siLOsUndco(gH2t4IkAjcuGkOQfICHAlYj5igVedOgouHwdyUoQizSuNEZabb06edRujWqIsjxMgFJq7jCrfTebkqfgLcrUQSidcZ4LyabmizufCPkcjBXetcrTfPE14ZltuPU45aBDODiuwZ4(ncTNWfv0seOavOkcjBjtulEjgqadsgvbxQIqYwmXKquBrQxn(8YevQlEoWwhAhcL1mUFdt9utkuUQEQj9ytuRcknd1jQ9Pj6PWvO(PXtbKjQFQNR6NMRMWbIX7Pi4tZ9PeoePRgVNQgohlq4NgveumDwO(Py5Yp1HpDI4NM(td0tJNo9uKU6NImyHO8ncTNWfv0seOavaWytulEjgWMqohcVLLLqiWhWGKrvWLyOorTwnCLPNW9BeApHlQOLiqbQGKWHSkcjJWlXa2eY5q4TSSecb(A4qfAnG56iLaeKVrO9eUOIwIafOcO2qcvCGfs8smGnHCoeElllHqGpGbjJQGlXqDIATA4ktpH73i0EcxurlrGcubeBGseEjgWMqohcVLLLqi(gH2t4IkAjcuGkya9eU4LyaRtmSsvaHsXe5fchA3S56edRescVHix2sMO2Y04BeApHlQOLiqbQqvaHsl2KO(BeApHlQOLiqbQqLjiMmkxvFJq7jCrfTebkqfWscxfqO8BeApHlQOLiqbQqSAg5Kqy1Hq8nm1thFglMc)PyHqud9ONIbjpDIIQGFA68aQ8ncTNWfv0seOavyIyB68acVedyDIHvQciukMiVq4q7MnJLQADlHhICrkbiU4WSznCOcTgWCDurYyPoDLae3VX3WupDSLBIAzc6ByQNcUpEFkCFQgcfsOI7tD4thXSXt9w(PJlj9Nk56ed7PtJVrO9eUOcwUjQfyLDfzETElBz1m6BeApHlQGLBIAbfOcirQzBSsRm1mEjgW6edRGePMTXkTYuZfcpe5IucwQQ1TeEiYfHFDIHvqIuZ2yLwzQ5cHhICrkXeGaQgouHwdyUos5kDqkJ53i0Ecxubl3e1ckqfKjYiCD734ByQN2DoeE73i0Ecxub5Ci8wG6womSOwOJNwTwWwpiQyhbee8smGEi41lgewTfUwVLTkYXOcVrvWs8BYdIk2ljYwHi03i0Ecxub5Ci8wqbQqmuNO2RditqjCpWWfh4IdqabxL66kgKnxvORpEgmGeNLpvPEAO9eUpvKihv(gxxKihDaCDjJftHFaCGbYbW1dTNW96Js9ORZBufS8a)8dmCpaUEO9eUxh5Ci82RZBufS8a)8dmC(a468gvblpWVo046i2VEO9eUxhWGKrvWxhWqm5Rt8QToXWqpvjpf3NI)tnXtRtmSsDsswADchOjHltJNA28tRtmSIksSs7alyUmnEQzZpToXWkozY2khKCvvMgpv5xhWGy3yGVoXRwctGcX5hyM(bW15nQcwEGFDOX1rSF9q7jCVoGbjJQGVoGHyYxxdhQqRbmxhvKmwQt)Pnd8P4(uqFkUpvP)ut8upe86fvTqKluBrojhXfEJQGLpf)NQHqHeQ4wu1crUqTf5KCexi8qKl6Pk5PG8uL)uqFADIHvQeyirPKltJNI)t5LjQu)0MFQsHJNI)tB6P1jgwbnAke2yLwnbIqv4YOY04P4)0MEADIHvgXSHvnCsSkMoYgv40TQHZY046age7gd81JH6e1A1WvMEc3ZpWWPdGRZBufS8a)6qJRJy)6H2t4EDadsgvbFDadXKVoYGfcRhevSJkvrizlMysiQFQsEkUpf)NsIuAza51lHuIk5(0MFkU44PMn)06edRufHKTyIjHOUmnUoGbXUXaF9QiKSftmje1wK6vF(bMsDaCDEJQGLh4xxtsNjzCDKZHWBzzjeIRhApH711HqydTNW1ksKFDrIC7gd81rohcV98dSX5bW15nQcwEGF9q7jCVUoecBO9eUwrI8RlsKB3yGVUwIo)aBmpaUoVrvWYd8RRjPZKmUUgouHwdyUo6Pnd8PAd7qOmlYGx5tn5NAINwNyyLkbgsuk5Y04PG(06edRanmGeFUPRUmnEQYFQs)PM4PEi41lJXm1JSssOyH3Oky5tX)PM4Pn9upe86LHGmILwmiXk5WBl8gvblFQzZpvdHcjuXTmeKrS0IbjwjhEBHWdrUON28tb5Pk)Pk)PMn)unCOcTgWCD0tb(0yZHq3gevS0QnUEO9eUxNmxBO9eUwrI8RlsKB3yGVowUjQ98dmtYbW15nQcwEGF9q7jCVUoecBO9eUwrI8RlsKB3yGVEDMc55hyGGJdGRZBufS8a)6As6mjJRZltuPUizSuN(tBg4tbbNEkOpLxMOsDHWQ496H2t4E9GOJLToKq41p)adeqoaUEO9eUxpi6yzRXuG4RZBufS8a)8dmqW9a46H2t4EDrQQ1r2XQPu1aV(15nQcwEGF(bgi48bW1dTNW961qLfIzDsQhHUoVrvWYd8Zp)6gewdhQHFaCGbYbW1dTNW96HHHqT1aMi4EDEJQGLh4NFGH7bW15nQcwEGF9q7jCV(qqgXslgKyLC4TxxtsNjzCDsKsldiVEjKsuj3N28tnDCCDdcRHd1WTiwdxj66405hy48bW15nQcwEGFDnjDMKX1nXtB6P8ymtddwwmG6rSJYXolTA4GX0dpHRvYaMA(PMn)0MEQgcfsOIBrRwlGobUP2wfbYlYjj8eUp1S5NsIuAza51l5c4uSmjQcUWklro6Pk)6H2t4EDKZHWBp)aZ0paUoVrvWYd8RhApH71jqHW6TSTcxgDDnjDMKX1jmgHrTrvWx3GWA4qnClI1WvIUoUNFGHthaxN3Oky5b(1dTNW96irQzBSsRm1811K0zsgxNWyeg1gvbFDdcRHd1WTiwdxj664E(bMsDaCDEJQGLh4xp0Ec3RhscVHix2sMO2RRjPZKmUUjEAtpLhJzAyWYIbupIDuo2zPvdhmME4jCTsgWuZp1S5N20t1qOqcvClA1Ab0jWn12QiqErojHNW9PMn)usKsldiVEjxaNILjrvWfwzjYrpv5x3GWA4qnClI1WvIUoiNF(1RZuipaoWa5a468gvblpWVUMKotY46K5YyqIkU45Q26qLLABvesUWJXmnmy51dTNW96O2eWZpWW9a46H2t4EDw3cZvLLWgKCiw515nQcwEGF(bgoFaCDEJQGLh4xp0Ec3RJycjCwARWLTiJCeFDnjDMKX1B6PsOxqmHeolTv4YwKroIlEQhLRQNA28tdTNaYwE5HKrpf4tb5P4)usKsldiVEjKsuj3N28tXMcHLW62GOITEoWp1S5NQBdIkg90MFkUpf)NILQADlHhICrpvjpfNUUwTwWwpiQyhDGbY5hyM(bW15nQcwEGFDnjDMKX1RtmSc0Was85MU6Y04P4)ut8uEzIk1pvjp10XPNA28t9qWRxgJzQhzLKqXcVrvWYNI)tRtmSYiMnSQHtIvX0r2OcNUvnCwKqf3NQ8RhApH71nsKdfwul0p)adNoaUoVrvWYd8RRjPZKmUEDIHvGggqIp30vxMgpf)NAINwNyyfjhsul0ltJNA28tRtmSIkcZlAuUiRIPEetqLPXtnB(P1jgwrdxnhcwARI5kzsDIqLPXtv(1dTNW96gjYHclQf6NFGPuhaxp0Ec3RJYnrotSiNKJ4RZBufS8a)8dSX5bW15nQcwEGFDnjDMKX19qWRxKjXvBDsQhHk8gvblFk(pvdhQqRbmxhvKmwQt)Pnd8PG8uqFADIHvQeyirPKltJRhApH71vbNQ4Zp)6iNdH3EaCGbYbW15nQcwEGF9q7jCVUULddlQf6xxtsNjzCDpe86fdcR2cxR3Ywf5yuH3Oky5tX)Pn9upiQyVKiBfIqxxRwlyRhevSJoWa58dmCpaUEO9eUxpgQtu715nQcwEGF(5xxlrhahyGCaC9q7jCVoMiuXcr4jCVoVrvWYd8ZpWW9a468gvblpWVUMKotY46sUoXWkyIqfleHNWTq4Hix0tvYtX96H2t4EDmrOIfIWt4A1coweF(bgoFaCDEJQGLh4xxtsNjzC9MEADIHvcjH3qKlBjtuBzA8u8FQjEAtpvdHcjuXTmkfICvzrgeMltJNA28tB6PEi41lJsHixvwKbH5cVrvWYNQ8RhApH71djH3qKlBjtu75hyM(bW15nQcwEGFDnjDMKX1RtmScbkewVLTv4YOcHhICrpvjaFko)uZMFkGbjJQGleVAjmbkexp0Ec3RtGcH1BzBfUm68dmC6a468gvblpWVEO9eUxFiiJyPfdsSso82RRjPZKmUojsPLbKxVesjQmnEk(p1ep1dIk2lEoWwhALj)uL8unCOcTgWCDurYyPo9NA28tB6PiNdH3YYcbQAYpf)NQHdvO1aMRJksgl1P)0Mb(uTHDiuMfzWR8PM8tb5Pk)6A1AbB9GOID0bgiNFGPuhaxN3Oky5b(11K0zsgxNeP0YaYRxcPevY9Pn)uCghp1KFkjsPLbKxVesjQiNKWt4(u8FAtpf5Ci8wwwiqvt(P4)unCOcTgWCDurYyPo9N2mWNQnSdHYSidELp1KFkixp0Ec3RpeKrS0IbjwjhE75hyJZdGRZBufS8a)6As6mjJRJmyHW6brf7ON2mWNI7tn5NQHRCMEjgQPKvMZK0vx4nQcw(u8FAtpToXWkvrizlMysiQltJNI)tjrkTmG86LqkrLCFAZpfeCC9q7jCVEves2IjMeI6ZpWgZdGRZBufS8a)6As6mjJRRHdvO1aMRJksgl1P)0Mb(uqEkOpToXWkvcmKOuYLPX1dTNW96QAHixO2ICsoIp)aZKCaCDEJQGLh4xxtsNjzCDadsgvbxQIqYwmXKquBrQx9tX)P8YevQlEoWwhAhcL90MFkUxp0Ec3RpkfICvzrgeMp)adeCCaCDEJQGLh4xxtsNjzCDadsgvbxQIqYwmXKquBrQx9tX)P8YevQlEoWwhAhcL90MFkUxp0Ec3RxfHKTKjQ98dmqa5a468gvblpWVUMKotY46n9uKZHWBzzjeINI)tbmizufCjgQtuRvdxz6jCVEO9eUxhWytu75hyGG7bW15nQcwEGFDnjDMKX1B6PiNdH3YYsiepf)NQHdvO1aMRJEQsa(uqUEO9eUxxs4qwfHKrNFGbcoFaCDEJQGLh4xxtsNjzC9MEkY5q4TSSecXtX)PagKmQcUed1jQ1QHRm9eUxp0Ec3RJAdjuXbwip)adet)a468gvblpWVUMKotY46n9uKZHWBzzjeIRhApH71rSbkrNFGbcoDaCDEJQGLh4xxtsNjzC96edRufqOumrEHWH2FQzZpToXWkHKWBiYLTKjQTmnUEO9eUx3a6jCp)adeL6a46H2t4E9QacLwSjr915nQcwEGF(bgiJZdGRhApH71RmbXKr5Q668gvblpWp)adKX8a46H2t4EDSKWvbekVoVrvWYd8ZpWaXKCaC9q7jCVESAg5Kqy1HqCDEJQGLh4NFGHlooaUoVrvWYd8RRjPZKmUEDIHvQciukMiVq4q7p1S5NILQADlHhICrpvjaFkU44PMn)unCOcTgWCDurYyPo9NQeGpf3RhApH71Ni2MopGo)8RJLBIApaoWa5a46H2t4E9k7kY8A9w2YQz015nQcwEGF(bgUhaxN3Oky5b(11K0zsgxVoXWkirQzBSsRm1CHWdrUONQKNILQADlHhICrpf)NwNyyfKi1SnwPvMAUq4Hix0tvYtnXtb5PG(unCOcTgWCD0tv(tv6pfKYyE9q7jCVosKA2gR0ktnF(bgoFaC9q7jCVUmrgHRBVoVrvWYd8Zp)8RhtVfsUEphg3Zp)oa]] )

end