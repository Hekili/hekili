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


    spec:RegisterPack( "Outlaw", 20201129, [[d4KqSaqiPOEKueBcQYNakvJIePtrryvuevVcOAwqLUffPSlj(fj0WakoMuvldQQNrrIPrrKRrcyBsvsFdOenoPi5CaLY6ibkZJeX9aY(KQ4GaLWcHkEOuKAIKa5IsvQSrPkv9rPkL6KuKkRKIAMsvkCtsGQDcO(jfjzOuKuhvQsrlLIu1tvyQa4QueL2kqjvFLIOySaLu2RQ(lLgmIdlSyj9ysnzIUmQndLptsgTu60IwTuLsEnGmBc3wQSBL(nOHtHJlvjwosphY0P66kA7a03jrnEsqNNKA9aLK5lf2Vk)9Fa(HmC(bgFWGpy63hFWwbmnLj1VVj9dxTb)dJqduOI)XgD8pmvtxek)dJqTagYhGFGGtQM)rR7gifmfvuv6TZArd7ueLDtr4jC10aZveLDAf)rDMc30TF9hYW5hy8bd(GPFF8bBfW0uMuFW0u)azW6hy87vW8J2uk59R)qYi9pAYrmvtxekFetpu1KpZn5iadbK7Qm9i4d2W9i4dg8bZpmOqSuW)OjhXunDrO8rm9qvt(m3KJameqURY0JGpyd3JGpyWhmN5ZCtosVtHSE6S8ivgds5JOHD1WpsLvLlQCeWcTMnC0rw4AATbTdBkosO9eUOJaxH6Yzo0EcxuXGYAyxnCqHHHqT1aMi4EMdTNWfvmOSg2vdhCqk2fuGyPfdsTso8wCnOSg2vd3IynCLiqkaUjgiAKsldiVEjKsuj3EmjWCMdTNWfvmOSg2vdhCqkICoeElUjgiL2m3lZ0WGLfdOgi2rjyflTAyNX0dpHRvYaMAUrJM1qOqcvElA1Ab0PWn12QiqEroPHNWTrdAKsldiVEjxaNILPrvWfwHjYrM4mhApHlQyqznSRgo4GuKcfcR3Y2kCzeUguwd7QHBrSgUsei8XnXarzmkJAJQGpZH2t4Ikguwd7QHdoifrIuZ2yLwzQzCnOSg2vd3IynCLiq4JBIbIYyug1gvbFMdTNWfvmOSg2vdhCqkgskVHix2sNOwCnOSg2vd3IynCLiq9XnXaP0M5EzMggSSya1aXokbRyPvd7mME4jCTsgWuZnA0SgcfsOYBrRwlGofUP2wfbYlYjn8eUnAqJuAza51l5c4uSmnQcUWkmroYeN5ZCtosVtHSE6S8imGmv9r8SJpI3Yhj0oKEKeDKaWifrvWLZCO9eUiqaLAGoZn5iMEg5Ci82JKyhXaIqzvWhrPl8iaofltJQGpcVCxYOJK7r0WUA4M4mhApHlcCqkICoeE7zUjhX0ZuOqCeuUQe8rWbaf7TvWveaCosDIHHoIYT8EedicLvbFMdTNWfboifbmOzufmUB0XGOE1szkuiWfWqmzquVARtmmKsWhpLwNyyL6KMS06uoqtkxMgnAuNyyfv0yL2owWCzA0OrDIHvC6KTvoO5QQmnmXzo0Ecxe4GueWGMrvW4Urhdk6QtuRvdxz6jCXfWqmzqAyxfAnG56OIKXsD69acFWX3KRupe86fvTqKluBronbIl8gvblXtdHcju5TOQfICHAlYPjqCHYDrUiL03eGxNyyLkfgsuk5Y0apEzQk190RGbVMRtmSccOPqyJvA1uicvHlJktd8AUoXWkaXSHvnCsTkNoYgv40TQHZY04m3KJyYKE7r6Mcpne8r8GQIDeUhXBt0ramOzuf8rs0r0TSgiwEehEejRtjFeLBzVLPhbb74J00ki0rqTWPqEKkFeK6vZYJOC6Thbhri5J07ftkv9zo0Ecxe4GueWGMrvW4UrhdQkcjBXetkvTfPE14cyiMmiKblewpOQyhvQIqYwmXKsvRe8XJgP0YaYRxcPevYTh8btJg1jgwPkcjBXetkvDzACMdTNWfboif1HqydTNW1ksKJ7gDmiKZHWBXnXaHCoeElllHqCMdTNWfboif1HqydTNW1ksKJ7gDmiTeDMBYr695MO2Je(r6cfMDZUJ00M6YrgZkYPH2pcC5JGbPhHdD7rWHcdjkL8rIvEetLHbK6ZnD1hr5wEpsV5m1aDefenu(ij6iiwWANLhjw5ruWXuqhjrhzH(rOCivFKaZz6r8w(ilRq)iiwdxz5mhApHlcCqksNRn0EcxRiroUB0XGWYnrT4MyG0WUk0AaZ1r9asBy7cfArg8knnLwNyyLkfgsuk5Y0a86edRanmGuFUPRUmnmHjxPEi41l9Ym1azL0q5cVrvWs8uAZEi41lDbfiwAXGuRKdVTWBufSSrdnekKqL3sxqbILwmi1k5WBluUlYf1tFtyIgn0WUk0AaZ1rGIn7cDBqvXsR24mhApHlcCqkQdHWgApHRvKih3n6yq1zkKN5q7jCrGdsXGQJLToKs51XnXaXltvPUizSuNEpG6RaGZltvPUqzv8EMdTNWfboifdQow2Amfi(mhApHlcCqkksvToY2BnLQ641pZH2t4IahKI1qLfIzDAQbcDMpZn5i4mtHKPOZCO9eUOsDMcjiuBciUjgi6Czmivfx8CvBDOctTTkcjFMdTNWfvQZuibhKISUfMRklLnOzxSYZCO9eUOsDMcj4GueXuA4S0wHlBrgjqmUA1AbB9GQIDeO(4MyGAwc9cIP0WzPTcx2ImsG4INAGYvvJgH2tazlVCxYiq9XJgP0YaYRxcPevYThSPqyPSUnOQyRNDCJg62GQIr9GpEyPQw3s5UixKsuGZCtoIjlIpIPorouCKrl0pIYP3EetLHbK6ZnD1hjXosLfqLpIjPahHxMQsnUhbspIYT8EKjkxvhP3CMAGoIcIgkFKyLhXKjD0rs0rKqL3Yzo0EcxuPotHeCqkAKihkSOwOJBIbQoXWkqddi1NB6Qltd8ukVmvLALyskqJgEi41l9Ym1azL0q5cVrvWs8QtmScqmByvdNuRYPJSrfoDRA4SiHkVM4mhApHlQuNPqcoifnsKdfwul0XnXavNyyfOHbK6ZnD1LPbEkToXWksoKOwOxMgnAuNyyfvuMxeq5ISkNAGykQmnA0OoXWkA4Q5qWsBvmxjtRteQmnmXzo0EcxuPotHeCqkIYnrotTiNMaXN5q7jCrL6mfsWbPOk4ufJBIbYdbVErMuxT1PPgiuH3OkyjEAyxfAnG56OIKXsD69aQp41jgwPsHHeLsUmnoZN5MCKMgcfsOYl6mhApHlQOLiqyIqfleHNW9mhApHlQOLiWbPiMiuXcr4jCTAbhlIXnXaj56edRGjcvSqeEc3cL7ICrkb)ZCO9eUOIwIahKIHKYBiYLT0jQf3eduZ1jgwjKuEdrUSLorTLPbEkTznekKqL3cqPqKRklYGYCzA0OrZEi41laLcrUQSidkZfEJQGLM4mhApHlQOLiWbPifkewVLTv4YiCtmq1jgwHcfcR3Y2kCzuHYDrUiLaYuA0aWGMrvWfQxTuMcfIZCtoIPd7iHuIosq5JmnW9iOnn4J4T8rGlFeLtV9icOYmYpcaaOGkhXKfXhr5wEpIuDUQocwGCMEeVn2J00M6JizSuN(rG0JOC6TWPFKyvFKM2uxoZH2t4IkAjcCqk2fuGyPfdsTso8wC1Q1c26bvf7iq9XnXarJuAza51lHuIktd8uQhuvSx8SJTo0ktwjAyxfAnG56OIKXsD6nA0mY5q4TSSqHQMmEAyxfAnG56OIKXsD69asBy7cfArg8knT(M4m3KJy6WoYcpsiLOJOCkehrM8ruo92CpI3Yhzzf6hXuadc3Jmr8ruWXuqhbUhPcrOJOC6TWPFKyvFKM2uxoZH2t4IkAjcCqk2fuGyPfdsTso8wCtmq0iLwgqE9siLOsU9ykGX0OrkTmG86Lqkrf5KgEcx8Ag5Ci8wwwOqvtgpnSRcTgWCDurYyPo9EaPnSDHcTidELMw)ZCtocoIqYhP3lMuQ6Ja3JGp4hHxUlzu5idaoIYP3EeWIUAkzf6mnD1hjXoYcpsiLOJK7r8w(ilRq)i9bdQCMdTNWfv0se4GuSkcjBXetkvnUjgiKblewpOQyh1di8nnnCLZ0lrxnLScDMMU6cVrvWs8AUoXWkvrizlMysPQltd8OrkTmG86LqkrLC7PpyoZH2t4IkAjcCqkQQfICHAlYPjqmUjginSRcTgWCDurYyPo9Ea1h86edRuPWqIsjxMgN5q7jCrfTeboifbkfICvzrguMXnXabyqZOk4sves2IjMuQAls9QXJxMQsDXZo26qBxOWEW)mhApHlQOLiWbPyves2sNOwCtmqag0mQcUufHKTyIjLQ2IuVA84LPQux8SJTo02fkSh8pZn5iMSOCvDeW6XMOwfbl6Qtu7rs0rGRq9rIJaitvFepx1hjxnLdeJ7rqWJK7rOCisxnUhrnCc2P8rIkckMoluFeSC5J4WJmr8rs)ib6iXrMEksx9rqgSquoZH2t4IkAjcCqkcySjQf3eduZiNdH3YYsie4byqZOk4s0vNOwRgUY0t4EMdTNWfv0se4Guus5qwfHKr4MyGAg5Ci8wwwcHapnSRcTgWCDKsa1)mhApHlQOLiWbPiQnKqL7yHe3eduZiNdH3YYsie4byqZOk4s0vNOwRgUY0t4EMdTNWfv0se4GueXgOeHBIbQzKZHWBzzjeIZCO9eUOIwIahKIgqpHlUjgO6edRufqOumrEHYH2B0OoXWkHKYBiYLT0jQTmnoZH2t4IkAjcCqkwfqO0InPQpZH2t4IkAjcCqkwzkIPaLRQZCO9eUOIwIahKIyjLRciuEMdTNWfv0se4GumwnJCAiS6qioZn5ikiglMc)iyHqudnqhbdspYefvbFK05ou5mhApHlQOLiWbP4eX205oeUjgO6edRufqOumrEHYH2B0alv16wk3f5Iuci8btJgAyxfAnG56OIKXsD6kbe(N5ZCtosVp3e1Yu0zUjhbhV3De4EenekKqL3J4WJaeZghXB5J0000pIKRtmSJmnoZH2t4Iky5MOwqv2vM516TSLvZOZCO9eUOcwUjQfCqkIePMTXkTYuZ4MyGQtmScsKA2gR0ktnxOCxKlsjyPQw3s5UixeE1jgwbjsnBJvALPMluUlYfPeL2hCnSRcTgWCDKjm59ln1zo0Ecxubl3e1coifLjYiCD7z(m3KJmCoeE7zo0Ecxub5Ci8wq6womSOwOJRwTwWwpOQyhbQpUjgipe86fdkR2cxR3YwL5aOcVrvWs8A2dQk2ljYwHi0zo0Ecxub5Ci8wWbPy0vNO2FaitrjCFGXhm4dM(9XVP(HYbDZvf6hMmGfMEGnDa3BRGDKJaqlFKSZas9JGbPhbSxNPqc2pcL7Lzsz5rqWo(iX0HDHZYJOBJvfJkN5EJC5J0xb7innCbKPolpcyNoxgdsvXfWAG9J4WJa2PZLXGuvCbSwH3Okyjy)iHFKENPQ34ikTVcnr5mFMnDDgqQZYJ0Rhj0Ec3JisKJkN5FisKJEa(HKXIPWFaEG7)a8Jq7jC)bqPgOFWBufS8X59hy8Fa(rO9eU)a5Ci82FWBufS8X59hyt5b4h8gvblFC(b04hi2)rO9eU)aWGMrvW)aWqm5Fq9QToXWqhrjhb)JG3ru6rQtmSsDstwADkhOjLltJJ0OXrQtmSIkASsBhlyUmnosJghPoXWkoDY2kh0CvvMghXe)aWGA3OJ)b1RwktHcX7pWM0dWp4nQcw(48dOXpqS)Jq7jC)bGbnJQG)bGHyY)qd7QqRbmxhvKmwQt)i9a6i4FeWpc(hXKFeLEepe86fvTqKluBronbIl8gvblpcEhrdHcju5TOQfICHAlYPjqCHYDrUOJOKJ0)iM4iGFK6edRuPWqIsjxMghbVJWltvP(i9CKEfmhbVJ08rQtmSccOPqyJvA1uicvHlJktJJG3rA(i1jgwbiMnSQHtQv50r2OcNUvnCwMg)aWGA3OJ)r0vNOwRgUY0t4((dSc8a8dEJQGLpo)aA8de7)i0Ec3FayqZOk4FayiM8pqgSqy9GQIDuPkcjBXetkv9ruYrW)i4DeAKsldiVEjKsuj3J0ZrWhmhPrJJuNyyLQiKSftmPu1LPXpamO2n64FufHKTyIjLQ2IuV63FG71hGFWBufS8X5hAA6mnJFGCoeElllHq8Jq7jC)HoecBO9eUwrI8FisKB3OJ)bY5q4TV)adw(a8dEJQGLpo)i0Ec3FOdHWgApHRvKi)hIe52n64FOLO3FGBQhGFWBufS8X5hAA6mnJFOHDvO1aMRJospGoI2W2fk0Im4vEet7ik9i1jgwPsHHeLsUmnoc4hPoXWkqddi1NB6QltJJyIJyYpIspIhcE9sVmtnqwjnuUWBufS8i4DeLEKMpIhcE9sxqbILwmi1k5WBl8gvblpsJghrdHcju5T0fuGyPfdsTso82cL7ICrhPNJ0)iM4iM4inACenSRcTgWCD0raDKyZUq3guvS0Qn(rO9eU)GoxBO9eUwrI8FisKB3OJ)bwUjQ99hyW2dWp4nQcw(48Jq7jC)HoecBO9eUwrI8FisKB3OJ)rDMc57pW9bZdWp4nQcw(48dnnDMMXp4LPQuxKmwQt)i9a6i9vGJa(r4LPQuxOSkE)rO9eU)iO6yzRdPuE93FG73)b4hH2t4(JGQJLTgtbI)bVrvWYhN3FG7J)dWpcTNW9hIuvRJS9wtPQoE9FWBufS8X59h4(MYdWpcTNW9h1qLfIzDAQbc9dEJQGLpoV)(pmOSg2vd)b4bU)dWpcTNW9hHHHqT1aMi4(dEJQGLpoV)aJ)dWp4nQcw(48Jq7jC)rxqbILwmi1k5WB)HMMotZ4h0iLwgqE9siLOsUhPNJysG5hguwd7QHBrSgUs0puG3FGnLhGFWBufS8X5hAA6mnJFO0J08r4EzMggSSya1aXokbRyPvd7mME4jCTsgWuZhPrJJ08r0qOqcvElA1Ab0PWn12QiqEroPHNW9inACeAKsldiVEjxaNILPrvWfwHjYrhXe)i0Ec3FGCoeE77pWM0dWp4nQcw(48Jq7jC)bfkewVLTv4YOFOPPZ0m(bLXOmQnQc(hguwd7QHBrSgUs0pW)9hyf4b4h8gvblFC(rO9eU)ajsnBJvALPM)HMMotZ4hugJYO2Ok4FyqznSRgUfXA4kr)a)3FG71hGFWBufS8X5hH2t4(Jqs5ne5Yw6e1(dnnDMMXpu6rA(iCVmtddwwmGAGyhLGvS0QHDgtp8eUwjdyQ5J0OXrA(iAiuiHkVfTATa6u4MABveiViN0Wt4EKgnocnsPLbKxVKlGtXY0Ok4cRWe5OJyIFyqznSRgUfXA4kr)O)7V)J6mfYhGh4(pa)G3Oky5JZp000zAg)GoxgdsvXfpx1whQWuBRIqYfEJQGL)i0Ec3FGAtaF)bg)hGFeApH7pyDlmxvwkBqZUyL)G3Oky5JZ7pWMYdWp4nQcw(48Jq7jC)bIP0WzPTcx2ImsG4FOPPZ0m(rZhrc9cIP0WzPTcx2ImsG4INAGYv1rA04iH2tazlVCxYOJa6i9pcEhHgP0YaYRxcPevY9i9CeSPqyPSUnOQyRND8rA04i62GQIrhPNJG)rW7iyPQw3s5Uix0ruYruGFOvRfS1dQk2rpW9F)b2KEa(bVrvWYhNFOPPZ0m(rDIHvGggqQp30vxMghbVJO0JWltvP(ik5iMKcCKgnoIhcE9sVmtnqwjnuUWBufS8i4DK6edRaeZgw1Wj1QC6iBuHt3QgolsOY7rmXpcTNW9hgjYHclQf6V)aRapa)G3Oky5JZp000zAg)OoXWkqddi1NB6QltJJG3ru6rQtmSIKdjQf6LPXrA04i1jgwrfL5fbuUiRYPgiMIktJJ0OXrQtmSIgUAoeS0wfZvY06eHktJJyIFeApH7pmsKdfwul0F)bUxFa(rO9eU)aLBICMAronbI)bVrvWYhN3FGblFa(bVrvWYhNFOPPZ0m(HhcE9ImPUARttnqOcVrvWYJG3r0WUk0AaZ1rfjJL60pspGos)Ja(rQtmSsLcdjkLCzA8Jq7jC)Hk4uf)(7)a5Ci82hGh4(pa)G3Oky5JZpcTNW9h6womSOwO)dnnDMMXp8qWRxmOSAlCTElBvMdGk8gvblpcEhP5J4bvf7LezRqe6hA1AbB9GQID0dC)3FGX)b4hH2t4(JORorT)G3Oky5JZ7V)dTe9a8a3)b4hH2t4(dmrOIfIWt4(dEJQGLpoV)aJ)dWp4nQcw(48dnnDMMXpKCDIHvWeHkwicpHBHYDrUOJOKJG)pcTNW9hyIqfleHNW1QfCSi(9hyt5b4h8gvblFC(HMMotZ4hnFK6edReskVHix2sNO2Y04i4DeLEKMpIgcfsOYBbOuiYvLfzqzUmnosJghP5J4HGxVauke5QYImOmx4nQcwEet8Jq7jC)riP8gICzlDIAF)b2KEa(bVrvWYhNFOPPZ0m(rDIHvOqHW6TSTcxgvOCxKl6ikb0rmLJ0OXramOzufCH6vlLPqH4hH2t4(dkuiSElBRWLrV)aRapa)G3Oky5JZpcTNW9hDbfiwAXGuRKdV9hAA6mnJFqJuAza51lHuIktJJG3ru6r8GQI9INDS1HwzYhrjhrd7QqRbmxhvKmwQt)inACKMpcY5q4TSSqHQM8rW7iAyxfAnG56OIKXsD6hPhqhrBy7cfArg8kpIPDK(hXe)qRwlyRhuvSJEG7)(dCV(a8dEJQGLpo)qttNPz8dAKsldiVEjKsuj3J0ZrmfWCet7i0iLwgqE9siLOICsdpH7rW7inFeKZHWBzzHcvn5JG3r0WUk0AaZ1rfjJL60pspGoI2W2fk0Im4vEet7i9)rO9eU)OlOaXslgKALC4TV)adw(a8dEJQGLpo)qttNPz8dKblewpOQyhDKEaDe8pIPDenCLZ0lrxnLScDMMU6cVrvWYJG3rA(i1jgwPkcjBXetkvDzACe8ocnsPLbKxVesjQK7r65i9bZpcTNW9hvrizlMysPQF)bUPEa(bVrvWYhNFOPPZ0m(Hg2vHwdyUoQizSuN(r6b0r6FeWpsDIHvQuyirPKltJFeApH7pu1crUqTf50ei(9hyW2dWp4nQcw(48dnnDMMXpamOzufCPkcjBXetkvTfPE1hbVJWltvPU4zhBDOTlu4r65i4)Jq7jC)bqPqKRklYGY87pW9bZdWp4nQcw(48dnnDMMXpamOzufCPkcjBXetkvTfPE1hbVJWltvPU4zhBDOTlu4r65i4)Jq7jC)rves2sNO23FG73)b4h8gvblFC(HMMotZ4hnFeKZHWBzzjeIJG3ramOzufCj6QtuRvdxz6jC)rO9eU)aWytu77pW9X)b4h8gvblFC(HMMotZ4hnFeKZHWBzzjeIJG3r0WUk0AaZ1rhrjGos)FeApH7pKuoKvriz07pW9nLhGFWBufS8X5hAA6mnJF08rqohcVLLLqiocEhbWGMrvWLORorTwnCLPNW9hH2t4(duBiHk3Xc57pW9nPhGFWBufS8X5hAA6mnJF08rqohcVLLLqi(rO9eU)aXgOe9(dCFf4b4h8gvblFC(HMMotZ4h1jgwPkGqPyI8cLdTFKgnosDIHvcjL3qKlBPtuBzA8Jq7jC)Hb0t4((dC)E9b4hH2t4(JQacLwSjv9p4nQcw(48(dCFWYhGFeApH7pQmfXuGYv1p4nQcw(48(dC)M6b4hH2t4(dSKYvbek)bVrvWYhN3FG7d2Ea(rO9eU)iwnJCAiS6qi(bVrvWYhN3FGXhmpa)G3Oky5JZp000zAg)OoXWkvbekftKxOCO9J0OXrWsvTULYDrUOJOeqhbFWCKgnoIg2vHwdyUoQizSuN(rucOJG)pcTNW9hteBtN7qV)(pWYnrTpapW9Fa(rO9eU)OYUYmVwVLTSAg9dEJQGLpoV)aJ)dWp4nQcw(48dnnDMMXpQtmScsKA2gR0ktnxOCxKl6ik5iyPQw3s5Uix0rW7i1jgwbjsnBJvALPMluUlYfDeLCeLEK(hb8JOHDvO1aMRJoIjoIj)i9ln1pcTNW9hirQzBSsRm187pWMYdWpcTNW9hYezeUU9h8gvblFCE)93)rm9wi9hJSRPF)9)b]] )

end