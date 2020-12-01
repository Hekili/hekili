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


    spec:RegisterPack( "Outlaw", 20201201, [[d4uJRaqiPipIIuBIi6tav0OisCkIqRIIGEfqAwqLULuuzxs8lOkddOQJbqldQQNrKKPrrKRbuPTPqW3aQGXrrOohqfADejvnpIG7bO9Pq6GueWcHkEOcHMOuu6IkevBuHO8rPOOojfr1kPOMPuuKBsrG2jq5NueYqPikhvHiSuPOWtLQPcGRsKuzRejf9vIKsJvHiAVQ8xknyKoSWIL0JjzYK6YO2mu(mrz0sPtlA1ejfETc1SjCBfSBL(nOHtHJlfvTCephY0P66kA7aX3jsnEksopr16visZxkSFv9b4bW11HZhy4dE8bpG4dEalaAsGxQUUl3GVUrOghY4RVXaFDt00fH0x3iKlGH(a46i4KO4R36UbsQhp8KLE7SwuWb8q5WueEcxfjWC8q5GcVRxNPWn57vVUoC(adFWJp4beFWdybqtc84dUM4RJmy1bg(Ja4VEBQ18E1RRzK66M(PMOPlcPFAZakBYVzt)0MLv8qLjpfqCFk(GhFWFDdcelf81n9tnrtxes)0Mbu2KFZM(PnlR4HktEkG4(u8bp(G)n)Mn9th5MIvtN1pTYyqc)ufCOg(tRSSCrLNAcOuSHJE6c3MRnidytXtdLNWf9u4kKxEZHYt4IkgewbhQHdmmmeYTgWeb33CO8eUOIbHvWHA4GceVHGmM1wmiXQ5WBX1GWk4qnClIvWvJacU4MyajrQTmi86LqRrLCh1Ka)BouEcxuXGWk4qnCqbIhY5q4T4MyaLstCZptddwxmGQXSJYrkRTk4GX0dpHRvZGKkUrJMuqOqdLElk5kb0jWnv2QiqErpjHNWTrdsKAldcVEjxqMILjrvWf2ujYrs8nhkpHlQyqyfCOgoOaXJafcR3Y2kCzeUgewbhQHBrScUAeq8XnXasymcJAJQGFZHYt4IkgewbhQHdkq8qIuX2y1wDQyCniScoud3IyfC1iG4JBIbKWyeg1gvb)MdLNWfvmiScoudhuG4fAcVHix2sMOwCniScoud3IyfC1iGaIBIbuknXn)mnmyDXaQgZokhPS2QGdgtp8eUwndsQ4gnAsbHcnu6TOKReqNa3uzRIa5f9KeEc3gnirQTmi86LCbzkwMevbxytLihjX38B20pDKBkwnDw)ugeMi)PEoWp1B5NgkhsEAIEAasKIOk4YBouEcxeWXPA8B20pTzWiNdH3(0e7PgqekRc(PszHpfKPyzsuf8t5Lhsg90CFQcoudxIV5q5jCrGcepKZHWBFZM(PndMafINIYvMGFkoaGxZSjiEaGZtRtmm0tLUL3NAarOSk43CO8eUiqbIhibjJQGXDJbgiXRwctGcbUGeIjdK4vBDIHHKa(skL6edRuNKK1wNWbAs4Y0OrJ6edRiJeR2oWcMltJgnQtmSItMSTYbjxzLPHeFZHYt4IafiEGeKmQcg3ngyGXqDIATk4QtpHlUGeIjdubhQqRbmxhv0mwQsFuG4dk(MqP4HGxViRfICHClYj5yUWBufSwsfek0qP3ISwiYfYTiNKJ5cHhICrsaqjcADIHvQeyOrPMltdj5LjYKp6iaEjBQoXWkOXtHWgR2QiqeQcxgvMgs2uDIHvgZSHvoCsSsNoYgv40TYHZY04nB6Nk1ME7thMcpne8t9GiJDeUp1Bt0tbjizuf8tt0tvTSAmRFQdFQMvPMFQ0TS3YKNIGd8thXMf9uulCk0pTYpfjFvS(PsNE7tXreA(PJmXKqK)MdLNWfbkq8ajizufmUBmWaRIqZwmXKqKBrYxfUGeIjdezWcH1dIm2rLQi0Sftmje5saFjjrQTmi86LqRrLChfFW3OrDIHvQIqZwmXKqKxMgV5q5jCrGcepvie2q5jCTIe54UXade5Ci8wCtmGiNdH3Y6sieV5q5jCrGcepvie2q5jCTIe54UXaduPrVzt)0rwUjQ9PH)0HWu5WC4PJOjR80(SICsO8Ncx(PyqYt5q1(uCiWqJsn)0y1p1ezyaj(Ctx(tLUL3Nosmt14N2SKq6NMONIybRCw)0y1p1eeRzFAIE6c9Ns4ql)PbMZKN6T8tx2u(trScU6YBouEcxeOaXJmxBO8eUwrICC3yGbILBIAXnXaQGdvO1aMRJgfOYWoeMYIm4v3CsPoXWkvcm0OuZLPbO1jgwbAyaj(CtxEzAirtOu8qWRxA(zQgB1Kq6cVrvWAjLstEi41ldbzmRTyqIvZH3w4nQcw3OHccfAO0BziiJzTfdsSAo82cHhICrJcOeLyJgk4qfAnG56iGXMdHQniYyTvz8MdLNWfbkq8uHqydLNW1ksKJ7gdmW6mf63CO8eUiqbIxquXYwhsi864Mya5LjYKx0mwQsFuGacUGYltKjVqyz8(MdLNWfbkq8cIkw2Amfi(nhkpHlcuG4jszToYk1yQLnWR)MdLNWfbkq8QHmleZ6Kung9MFZM(P4mtHMjO3CO8eUOsDMcnquBccUjgqYCzmirgx8CLBDOPsLTkcn)MdLNWfvQZuObfiESQfMRmlHni5qS63CO8eUOsDMcnOaXdXes4S2wHlBrg5ygxLCLGTEqKXociG4MyaBsd9cIjKWzTTcx2ImYXCXt14CL1OrO8ee2YlpKmciGssIuBzq41lHwJk5ok2uiSew1gezS1ZbUrdvBqKXOrXxsSuwRBj8qKlscG7B20pvQdXp1KLihkEAVf6pv60BFQjYWas85MU8NMypTYcO0p1Ka3NYltKjh3Ncjpv6wEF6eLRSNosmt14N2SKq6NgR(PsTPJEAIEQgk9wEZHYt4Ik1zk0GcepJe5qHf1cDCtmG1jgwbAyaj(CtxEzAiPu4LjYKlbtcCB0WdbVEP5NPASvtcPl8gvbRLSoXWkJz2WkhojwPthzJkC6w5WzrdLEL4BouEcxuPotHguG4zKihkSOwOJBIbSoXWkqddiXNB6YltdjLsDIHv0COrTqVmnA0OoXWkYimVOX5ISsNQXmbvMgnAuNyyffCvCiyTTkMRMj1jcvMgs8nhkpHlQuNPqdkq8q5MiNjwKtYX8BouEcxuPotHguG4jdoLX4Mya9qWRx0jXLBDsQgJk8gvbRLubhQqRbmxhv0mwQsFuGacADIHvQeyOrPMltJ38B20pDeHqHgk9IEZHYt4IkknciMiKXcr4jCFZHYt4IkkncuG4HjczSqeEcxRsWXIyCtmGAUoXWkyIqgleHNWTq4HixKeW)nhkpHlQO0iqbIxOj8gICzlzIAXnXa2uDIHvcnH3qKlBjtuBzAiPuAsbHcnu6TmofICLzrgeMltJgnAYdbVEzCke5kZImimx4nQcwlX3CO8eUOIsJafiEeOqy9w2wHlJWnXawNyyfcuiSElBRWLrfcpe5IKaqPQrdqcsgvbxiE1sycuiEZM(PMCSNgAn6PbHF60a3NI20GFQ3YpfU8tLo92NkGsZi)PaaqZwEQuhIFQ0T8(uT8CL9uSa5m5PEBSpDenzpvZyPk9Ncjpv60BHt)PXk)PJOjR8MdLNWfvuAeOaXBiiJzTfdsSAo8wCvYvc26brg7iGaIBIbKeP2YGWRxcTgvMgskfpiYyV45aBDOvNSeuWHk0AaZ1rfnJLQ0B0OjKZHWBzDHaLnzjvWHk0AaZ1rfnJLQ0hfOYWoeMYIm4v3CakX3SPFQjh7Pl8PHwJEQ0Pq8uDYpv60BZ9PEl)0LnL)uPc8iCF6eXp1eeRzFkCFAfIqpv60BHt)PXk)PJOjR8MdLNWfvuAeOaXBiiJzTfdsSAo8wCtmGKi1wgeE9sO1OsUJkvGV5irQTmi86LqRrf9KeEcxjBc5Ci8wwxiqztwsfCOcTgWCDurZyPk9rbQmSdHPSidE1nhGVzt)uCeHMF6itmje5pfUpfFqFkV8qYO3CO8eUOIsJafiEvrOzlMysiYXnXaImyHW6brg7OrbIVKnvNyyLQi0Sftmje5LPXBouEcxurPrGcepzTqKlKBrojhZ4MyavWHk0AaZ1rfnJLQ0hfiGGwNyyLkbgAuQ5Y04nhkpHlQO0iqbI34uiYvMfzqyg3ediibjJQGlvrOzlMysiYTi5RssEzIm5fphyRdTdHPgf)3CO8eUOIsJafiEvrOzlzIAXnXacsqYOk4sveA2IjMeICls(QKKxMitEXZb26q7qyQrX)nB6Nk1HYv2tLAgBIAXZeyOorTpnrpfUc5pnEkimr(t9CL)0CveoqmUpfbFAUpLWHiD54(u5Wj4KWpnQiOy6Sq(tXYLFQdF6eXpn9NgONgpD6PiD5pfzWcr5nhkpHlQO0iqbIhiXMOwCtmGnHCoeElRlHqijibjJQGlXqDIATk4QtpH7BouEcxurPrGcepnHdDveAgHBIbSjKZHWBzDjecjvWHk0AaZ1rsaiGV5q5jCrfLgbkq8qTHgk9al04MyaBc5Ci8wwxcHqsqcsgvbxIH6e1AvWvNEc33CO8eUOIsJafiEi2aLiCtmGnHCoeElRlHq8MdLNWfvuAeOaXZa6jCXnXawNyyLQac1IjYleouEJg1jgwj0eEdrUSLmrTLPXBouEcxurPrGceVQac1wSjr(BouEcxurPrGceVktqmzCUYEZHYt4IkkncuG4HLeUkGq9BouEcxurPrGceVyvmYjHWQcH4nB6N2Smwmf(tXcHOgQXpfdsE6efvb)005bu5nhkpHlQO0iqbI3eX205beUjgW6edRufqOwmrEHWHYB0alL16wcpe5IKaq8bFJgk4qfAnG56OIMXsv6sai(V53SPF6il3e1Ye0B20pfhFK)u4(ufek0qP3N6WNoMzJN6T8thrs6pvZ1jg2tNgV5q5jCrfSCtulWk7sZ8A9w2YYz0BouEcxubl3e1ckq8qIuX2y1wDQyCtmG1jgwbjsfBJvB1PIleEiYfjbSuwRBj8qKlsY6edRGePITXQT6uXfcpe5IKGuaeufCOcTgWCDKenHawmXV5q5jCrfSCtulOaXtNiJWvTV53SPFA35q4TV5q5jCrfKZHWBbQA5WWIAHoUk5kbB9GiJDeqaXnXa6HGxVyqy5w4A9w2knhJl8gvbRLSjpiYyVKiBfIqV5q5jCrfKZHWBbfiEXqDIAVoimbLW9adFWJp4beq8bhVU0bzZvg66sTMandWm5G1ml1)0Ncql)0CWas8NIbjpfCwNPqdoFkHB(zsy9trWb(PX0HdHZ6NQAJvgJkV5MPC5NcOu)thr4cctCw)uWjzUmgKiJlJKGZN6WNcojZLXGezCzKSWBufSgC(0WF6i3e1m9uPaOPKy5n)Mn5dgqIZ6NocpnuEc3NksKJkV5RlsKJoaUUMXIPWpaoWa8a46HYt4E9XPA815nQcwF4C(bg(haxpuEc3RJCoeE715nQcwF4C(bMuDaCDEJQG1hoxhACDe7xpuEc3RdsqYOk4RdsiM81jE1wNyyONkHNI)tL8Ps5P1jgwPojjRToHd0KWLPXtB04P1jgwrgjwTDGfmxMgpTrJNwNyyfNmzBLdsUYktJNkXRdsqSBmWxN4vlHjqH48dmt6a468gvbRpCUo046i2VEO8eUxhKGKrvWxhKqm5RRGdvO1aMRJkAglvP)0rb(u8FkOpf)NAcFQuEQhcE9ISwiYfYTiNKJ5cVrvW6Nk5tvqOqdLElYAHixi3ICsoMleEiYf9uj8uaFQeFkOpToXWkvcm0OuZLPXtL8P8YezYF6OpDea)tL8Pn906edRGgpfcBSARIarOkCzuzA8ujFAtpToXWkJz2WkhojwPthzJkC6w5WzzACDqcIDJb(6XqDIATk4QtpH75hyG7bW15nQcwF4CDOX1rSF9q5jCVoibjJQGVoiHyYxhzWcH1dIm2rLQi0Sftmje5pvcpf)Nk5tjrQTmi86LqRrLCF6OpfFW)0gnEADIHvQIqZwmXKqKxMgxhKGy3yGVEveA2IjMeICls(Qo)aBeoaUoVrvW6dNRRiPZKmUoY5q4TSUecX1dLNW96QqiSHYt4AfjYVUirUDJb(6iNdH3E(bg4WbW15nQcwF4C9q5jCVUkecBO8eUwrI8RlsKB3yGVUsJo)aZeFaCDEJQG1hoxxrsNjzCDfCOcTgWCD0thf4tvg2HWuwKbV6N2CpvkpToXWkvcm0OuZLPXtb9P1jgwbAyaj(CtxEzA8uj(ut4tLYt9qWRxA(zQgB1Kq6cVrvW6Nk5tLYtB6PEi41ldbzmRTyqIvZH3w4nQcw)0gnEQccfAO0BziiJzTfdsSAo82cHhICrpD0Nc4tL4tL4tB04Pk4qfAnG56ONc8PXMdHQniYyTvzC9q5jCVozU2q5jCTIe5xxKi3UXaFDSCtu75hyGJhaxN3Oky9HZ1dLNW96QqiSHYt4AfjYVUirUDJb(61zk0NFGbi4paUoVrvW6dNRRiPZKmUoVmrM8IMXsv6pDuGpfqW9PG(uEzIm5fclJ3RhkpH71dIkw26qcHx)8dmab8a46HYt4E9GOILTgtbIVoVrvW6dNZpWae)dGRhkpH71fPSwhzLAm1Yg41VoVrvW6dNZpWauQoaUEO8eUxVgYSqmRts1y015nQcwF4C(5x3GWk4qn8dGdmapaUEO8eUxpmmeYTgWeb3RZBufS(W58dm8paUoVrvW6dNRhkpH71hcYywBXGeRMdV96ks6mjJRtIuBzq41lHwJk5(0rFQjb(RBqyfCOgUfXk4QrxhCp)atQoaUoVrvW6dNRRiPZKmUUuEAtpLB(zAyW6IbunMDuoszTvbhmME4jCTAgKuXpTrJN20tvqOqdLElk5kb0jWnv2QiqErpjHNW9PnA8usKAldcVEjxqMILjrvWf2ujYrpvIxpuEc3RJCoeE75hyM0bW15nQcwF4C9q5jCVobkewVLTv4YORRiPZKmUoHXimQnQc(6gewbhQHBrScUA01X)8dmW9a468gvbRpCUEO8eUxhjsfBJvB1PIVUIKotY46egJWO2Ok4RBqyfCOgUfXk4Qrxh)ZpWgHdGRZBufS(W56HYt4E9qt4ne5YwYe1EDfjDMKX1LYtB6PCZptddwxmGQXSJYrkRTk4GX0dpHRvZGKk(PnA80MEQccfAO0BrjxjGobUPYwfbYl6jj8eUpTrJNsIuBzq41l5cYuSmjQcUWMkro6Ps86gewbhQHBrScUA01b88ZVEDMc9bWbgGhaxN3Oky9HZ1vK0zsgxNmxgdsKXfpx5whAQuzRIqZfEJQG1xpuEc3RJAtqo)ad)dGRhkpH71zvlmxzwcBqYHy1xN3Oky9HZ5hys1bW15nQcwF4C9q5jCVoIjKWzTTcx2ImYX81vK0zsgxVPNQHEbXes4S2wHlBrg5yU4PACUYEAJgpnuEccB5Lhsg9uGpfWNk5tjrQTmi86LqRrLCF6OpfBkewcRAdIm265a)0gnEQQniYy0th9P4)ujFkwkR1TeEiYf9uj8uW96k5kbB9GiJD0bgGNFGzshaxN3Oky9HZ1vK0zsgxVoXWkqddiXNB6YltJNk5tLYt5LjYK)uj8utcCFAJgp1dbVEP5NPASvtcPl8gvbRFQKpToXWkJz2WkhojwPthzJkC6w5WzrdLEFQeVEO8eUx3irouyrTq)8dmW9a468gvbRpCUUIKotY461jgwbAyaj(CtxEzA8ujFQuEADIHv0COrTqVmnEAJgpToXWkYimVOX5ISsNQXmbvMgpTrJNwNyyffCvCiyTTkMRMj1jcvMgpvIxpuEc3RBKihkSOwOF(b2iCaC9q5jCVok3e5mXICsoMVoVrvW6dNZpWahoaUoVrvW6dNRRiPZKmUUhcE9IojUCRts1yuH3Oky9tL8Pk4qfAnG56OIMXsv6pDuGpfWNc6tRtmSsLadnk1CzAC9q5jCVUm4ugF(5xh5Ci82dGdmapaUoVrvW6dNRhkpH71vTCyyrTq)6ks6mjJR7HGxVyqy5w4A9w2knhJl8gvbRFQKpTPN6brg7LezRqe66k5kbB9GiJD0bgGNFGH)bW1dLNW96XqDIAVoVrvW6dNZp)6kn6a4adWdGRhkpH71XeHmwicpH715nQcwF4C(bg(haxN3Oky9HZ1vK0zsgxxZ1jgwbteYyHi8eUfcpe5IEQeEk(xpuEc3RJjczSqeEcxRsWXI4ZpWKQdGRZBufS(W56ks6mjJR30tRtmSsOj8gICzlzIAltJNk5tLYtB6PkiuOHsVLXPqKRmlYGWCzA80gnEAtp1dbVEzCke5kZImimx4nQcw)ujE9q5jCVEOj8gICzlzIAp)aZKoaUoVrvW6dNRRiPZKmUEDIHviqHW6TSTcxgvi8qKl6Psa4tLQN2OXtbjizufCH4vlHjqH46HYt4EDcuiSElBRWLrNFGbUhaxN3Oky9HZ1dLNW96dbzmRTyqIvZH3EDfjDMKX1jrQTmi86LqRrLPXtL8Ps5PEqKXEXZb26qRo5NkHNQGdvO1aMRJkAglvP)0gnEAtpf5Ci8wwxiqzt(Ps(ufCOcTgWCDurZyPk9NokWNQmSdHPSidE1pT5EkGpvIxxjxjyRhezSJoWa88dSr4a468gvbRpCUUIKotY46Ki1wgeE9sO1OsUpD0NkvG)Pn3tjrQTmi86LqRrf9KeEc3Nk5tB6PiNdH3Y6cbkBYpvYNQGdvO1aMRJkAglvP)0rb(uLHDimLfzWR(Pn3tb86HYt4E9HGmM1wmiXQ5WBp)adC4a468gvbRpCUUIKotY46idwiSEqKXo6PJc8P4)ujFAtpToXWkvrOzlMysiYltJRhkpH71RIqZwmXKqKF(bMj(a468gvbRpCUUIKotY46k4qfAnG56OIMXsv6pDuGpfWNc6tRtmSsLadnk1CzAC9q5jCVUSwiYfYTiNKJ5ZpWahpaUoVrvW6dNRRiPZKmUoibjJQGlvrOzlMysiYTi5R6Ps(uEzIm5fphyRdTdHPE6Opf)RhkpH71hNcrUYSidcZNFGbi4paUoVrvW6dNRRiPZKmUoibjJQGlvrOzlMysiYTi5R6Ps(uEzIm5fphyRdTdHPE6Opf)RhkpH71RIqZwYe1E(bgGaEaCDEJQG1hoxxrsNjzC9MEkY5q4TSUecXtL8PGeKmQcUed1jQ1QGRo9eUxpuEc3RdsSjQ98dmaX)a468gvbRpCUUIKotY46n9uKZHWBzDjeINk5tvWHk0AaZ1rpvcaFkGxpuEc3RRjCORIqZOZpWauQoaUoVrvW6dNRRiPZKmUEtpf5Ci8wwxcH4Ps(uqcsgvbxIH6e1AvWvNEc3RhkpH71rTHgk9al0NFGbOjDaCDEJQG1hoxxrsNjzC9MEkY5q4TSUecX1dLNW96i2aLOZpWaeCpaUoVrvW6dNRRiPZKmUEDIHvQciulMiVq4q5pTrJNwNyyLqt4ne5YwYe1wMgxpuEc3RBa9eUNFGb4iCaC9q5jCVEvaHAl2Ki)68gvbRpCo)adqWHdGRhkpH71RmbXKX5k768gvbRpCo)adqt8bW1dLNW96yjHRciuFDEJQG1hoNFGbi44bW1dLNW96XQyKtcHvfcX15nQcwF4C(bg(G)a468gvbRpCUUIKotY461jgwPkGqTyI8cHdL)0gnEkwkR1TeEiYf9uja8P4d(N2OXtvWHk0AaZ1rfnJLQ0FQea(u8VEO8eUxFIyB68a68ZVowUjQ9a4adWdGRhkpH71RSlnZR1BzllNrxN3Oky9HZ5hy4FaCDEJQG1hoxxrsNjzC96edRGePITXQT6uXfcpe5IEQeEkwkR1TeEiYf9ujFADIHvqIuX2y1wDQ4cHhICrpvcpvkpfWNc6tvWHk0AaZ1rpvIp1e(ualM4RhkpH71rIuX2y1wDQ4ZpWKQdGRhkpH711jYiCv715nQcwF4C(5NF9y6TqY175WiE(53b]] )

end