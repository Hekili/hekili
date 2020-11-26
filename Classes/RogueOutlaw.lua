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


    spec:RegisterPack( "Outlaw", 20201126, [[d0eL)aqirHhPQcBsvPpbsfQrPQsNcKYQaPQEfOQzreDlrPYUe5xusnmrrhdKSmqPNPQIMMOKUMOu2grv8nIQKXPQqoNOuvRJOkLMNQIUhi2hLKdkkrwirLhkkbtuuI6IGuP2iivXhfLq1ibPc5KGuLwPuv3eKkyNeHFcsfnuqQKJsuLILkkv5PQYubvUQOeYwjQsLVsuLQ2lk)LIbJQdt1ILYJjzYK6YiBwHptugTu50swTOekVgumBc3wuTBL(nWWPuhxvHA5qEoutx46kA7sv(UQQgprvDEI06vvW8Pe7xLzqXGJ90EqmjGntyZekOGvEszkVYkuz7JyVqQnXE2UcgxgXERNtSh05me(F2Z2LkaUMbh7HbtKIyVUiSXYBT2Azv0nBjfi3ACLpfEuGvH8rynUYvwZETzjcO3L1ypThetcyZe2mHckyLNuMYRScvwZk7HTjftcyLNmzVUsRPL1ypnHvS3poo05me()JN9aYM01)hhxcqpkVrOJdR8i5XHntyZK9SrGrji27hhh6Cgc))XZEazt66)JJlbOhL3i0XHvEK84WMjSzE9V()44q3YNuZG0hVrdaIoUcK3844nswT40XZskfzh4JVGn76Cu(ykoURIcS4JdwH0013vrbwCYgrkqEZdiUTTqQXguyWE9DvuGfNSrKcK38aEiwN7iyiTzaqgn5rNK2isbYBEyWKcSAmKSjznGG8sBOE0gjxRXPATkRzE9DvuGfNSrKcK38aEiwJdYfrNK1aYVzqF8SSTjDYgOGHcC9bsBuGC7z4rbwJM6vkYILmuaGqd(VjLuLaeiWwktt44iPNipkWAXcYlTH6rBKQT3uSeYBckrYVWbgAxFxffyXjBePa5npGhI1iGqyIoY0alHL0grkqEZddMuGvJHaRK1acIgic35nbD9DvuGfNSrKcK38aEiwJfLIm(Qn6srsAJifiV5HbtkWQXqGvYAabrdeH78MGU(UkkWIt2isbYBEapeRDnIwxulzqtCNK2isbYBEyWKcSAmeOKSgq(nd6JNLTnPt2afmuGRpqAJcKBpdpkWA0uVsrwSKHcaeAW)nPKQeGab2szAchhj9e5rbwlwqEPnupAJuT9MILqEtqjs(foWq767QOalozJifiV5b8qSEIjtfuUKRNtq8pG7CKJndWggWWyd(tORVRIcS4KnIuG8MhWdX6jMmvq5ssJbPcZ65eeLuLaeiWwktt44qYAajdKxAd1J2ivBVPyjK3euIKFHd81)6)JJdDlFsndsFCQhHKE8OYPJhD0XDvaqhVWh375LWBckD9DvuGfdbMsbZ1)hhp7r4GCr0D8ACCBagxnbD8FxWX7nflH8MGooTuEr4Jx7XvG8Mhq767QOalgEiwJdYfr31)hhp7riGqCCCTYe0XLdoRZIdDWA4K74T5yGp()oApUnaJRMGU(UkkWIHhI19Cu5nbj565eeu0micbecj75IjbbfntBog4pH97VT5yKAturAtGihpruAABXsBogjziF1MCsquAABXsBogPanjtJCuTYstBOD9DvuGfdpeR75OYBcsY1ZjiEEBI7mkWQROaRK9CXKGOa5nGXguBGtAAuQkSccSWdl0)3Wf0gjzDaCiKAWbQGHs06nbP)QaaHg8FtY6a4qi1GdubdLquUxl(tOGg8T5yKAiGRXLMst7V0sizsTsEY8BgT5yKWWmfcJVAJcbW4gyjCAA)nJ2CmsWqKTrkyIm)RaB8gyggPGzAAF9)XXL3xr3XZNIOSf0XdhjJcSKhp6k8X75OYBc64f(4QosbdPpEaoUMuLMo()ok6i0XXGC64zHSm(44oWuOpEJoow6Qi9X)xr3XLt4A64qpIjcj967QOalgEiw3ZrL3eKKRNtqAcxtMHyIqsnyPRsYEUysqW2KqychjJcCQjCnzgIjcj9ty)I8sBOE0gjxRXPATc2mTyPnhJut4AYmetesAAAF9DvuGfdpeRvUqyCvuG1ikCi565eeCqUi6KSgqWb5IOJ0jxiU(UkkWIHhI1kximUkkWAefoKC9CcIsJV()44qp1w4UJ7XXZD5x5Z8JNfGUsh)nB4a5Q44GLo(aGoo5QUJlhc4ACPPJ7R(4qN22aum3kKE8)D0EC5nZsbZXZYi))Xl8XXKGubPpUV6JdDyKLpEHp(cIJJixl94(ii0XJo64lj)44ysbwD64zjXFxk(45U8pUCb09X)xr3XHf(JNLuu667QOalgEiwJMRXvrbwJOWHKRNtqg1w4ojRbefiVbm2GAdSvqu2MCx(gSnT6S732CmsneW14stPPn8T5yKa22aum3kKMM2qd6)B4cAJ0hplfmgnY)NO1Bcs)93mcxqBKYDemK2maiJM8OlrR3eK2Iffai0G)Bk3rWqAZaGmAYJUeIY9AXwbf0Gg0)x)deQck5kYmTnsbtKbliQhLq(cZNWAXsgkaqOb)3uJI)eTMOJmKucNM2qZIffiVbm2GAdmeFRCx15izK2OSV(UkkWIHhI1kximUkkWAefoKC9CcsBwc913vrbwm8qS2rkFjtaqiAdjRbeAjKmPjnnkvfwbbQSbpTesM0eIKr713vrbwm8qS2rkFjJ9uGPRVRIcSy4HyTOK1fytwSPwwoTX13vrbwm8qSU5YmGHjqLcg81)6)JJl3SeAcHV(UkkWItTzj0qWDvpjRbe0CPbajJsrTsnbq(LY0eUMs0hplBBsF9DvuGfNAZsOHhI1KQduRmdISrvUV6RVRIcS4uBwcn8qSgtiKhK20alzW2fmKKkPkbzchjJcmeOKSgqYqdIeMqipiTPbwYGTlyOuukyQvMflUkQEKHwkVimeO(I8sBOE0gjxRXPATAmfcdIuDosgzIkNSyr15ize2ky)okzDHbr5ET4pZ21)hhplcthh6QWbqC8xhio()k6oo0PTnafZTcPhVghVrcW)JN1SDCAjKmPsECa64)7O94tCTYoU8MzPG54zzK))4(QpU8(kWhVWhxd(VPRVRIcS4uBwcn8qS2UWbqyWDGqYAaPnhJeW2gGI5wH000(7V0sizs)mRzZILWf0gPpEwkymAK)prR3eK(BBogjyiY2ifmrM)vGnEdmdJuWmPb)xOD9DvuGfNAZsOHhI12foacdUdeswdiT5yKa22aum3kKMM2F)TnhJKMCnUdePPTflT5yKKHiAXWul28VuWqiCAABXsBogjfyvKliTPjMRMqTjgNM2q767QOalo1MLqdpeRX1w4GqgCGkyORVRIcS4uBwcn8qSwgykJKSgqcxqBK0fkKAcuPGbNO1Bcs)vbYBaJnO2aN00OuvyfeOGVnhJudbCnU0uAAF9V()44zbaqOb)x813vrbwCsPXquUqyCvuG1ikCi565eecJPvryjRbKmWb5IOJ0jxiU(UkkWItkngEiwpeUmsi8Oa713vrbwCsPXWdX6HWLrcHhfynkb5lMKSgq0uBogPHWLrcHhfytik3Rf)jSxFxffyXjLgdpeRDnIwxulzqtCNK1asgT5yKCnIwxulzqtCxAA)93muaGqd(VjykHOwzgSnIO002ILmcxqBKGPeIALzW2iIs06nbPH23FZG(4zzBt6K)bCNJCSza2WaggBWFczXIcaeAW)nj8G2W4iLVEcr5ETyRGntOD9DvuGfNuAm8qSgbect0rMgyjSK1asBogjeqimrhzAGLWjeL71I)eYpTyPNJkVjOekAgeHacX1)hhh6DCCxRXh3r0XN2sEC8w20XJo64GLo()k6oUa8NWXXHdUSC64zry64)7O94AP1k74dhhe64rNVhplaDDCnnkvfhhGo()k6aZ44(k94zbOR013vrbwCsPXWdX6ChbdPndaYOjp6Kujvjit4izuGHaLK1acYlTH6rBKCTgNM2F)nCKmksrLtMay0f9PcK3agBqTboPPrPQWILmWb5IOJ0jeq2K(Qa5nGXguBGtAAuQkScIY2K7Y3GTPvNDqbTR)poo0744l44UwJp()sioUUOJ)VIUApE0rhFj5hh)NzIL84tmDCOdJS8Xb7XBam(4)ROdmJJ7R0JNfGUsxFxffyXjLgdpeRZDemK2maiJM8OtYAab5L2q9OnsUwJt1A1pZm7qEPnupAJKR14KEI8Oa73mWb5IOJ0jeq2K(Qa5nGXguBGtAAuQkScIY2K7Y3GTPvNDqD9)XXLt4A64qpIjcj94G94Wc)XPLYlcNo(dUJ)VIUJNLYBLMKFqOkKE8AC8fCCxRXhV2JhD0Xxs(XXHktC667QOaloP0y4HyDt4AYmetesQK1ac2Mect4izuGTccSzNcS6zfjpVvAs(bHQqAIwVji93mAZXi1eUMmdXeHKMM2FrEPnupAJKR14uTwbvMxFxffyXjLgdpeRL1bWHqQbhOcgsYAarbYBaJnO2aN00OuvyfeOGVnhJudbCnU0uAAF9DvuGfNuAm8qSgMsiQvMbBJisYAaPNJkVjOut4AYmetesQblDvFPLqYKMIkNmbWK7Y3kyV(UkkWItkngEiw3eUMmOjUtYAaPNJkVjOut4AYmetesQblDvFPLqYKMIkNmbWK7Y3kyV()44zr4ALDC5D(w4oRZs5TjU74f(4Gvi94(X7riPhpQv6XRvHihtsECm441ECe5IkKk5XLcMqhJOJ7nmqmdsi94JAPJhGJpX0XR44o(4(XNrjQq6XX2KqKU(UkkWItkngEiw3Z3c3jznGKboixeDKo5cX3EoQ8MGsEEBI7mkWQROa713vrbwCsPXWdXAnICDt4AclznGKboixeDKo5cXxfiVbm2GAd8NqG667QOaloP0y4HynUZ1G)5KqlznGKboixeDKo5cX3EoQ8MGsEEBI7mkWQROa713vrbwCsPXWdXAmzJlSK1asg4GCr0r6KlexFxffyXjLgdpeRTbrbwjRbK2CmsnbaOftCKqKRclwAZXi5AeTUOwYGM4U00(67QOaloP0y4HyDtaaAZyIKE9DvuGfNuAm8qSUrimHGPwzxFxffyXjLgdpeRhfIAcaqF9DvuGfNuAm8qS2xfHdKlmkxiU(UkkWItkngEiwpXKPckxsAmivywpNGOKQeGab2szAchhswdizGdYfrhPtUq8TnhJKRr06IAjdAI7sAW)9BBogPCkhGKAadJyQkTrJiphN0G)7xAjKmPPOYjtam5U8TkRFrrZ0MJb(ZSD9DvuGfNuAm8qSEIjtfuUKRNtq8pG7CKJndWggWWyd(tijRbKmAZXi5AeTUOwYGM4U00(BgT5yKAcxtMHyIqstt7VkaqOb)3KRr06IAjdAI7sik3Rf)juz76)JJlVJqspocmL1jKEC0uqhhmoE0nZB1Oi9XZ9OdF8gja)L3E8SimD8baDCO3fgBG(4kufsECq0rO)fMo()k6oEwk7DCpooSzc)XXHRGbFCa64qLj8h)FfDh3fyWXLtaa6JpTtxFxffyXjLgdpeRNyYubLl565eeh31ZxcBq(haiJcGCHK1aIMAZXiH8paqgfa5cJMAZXiPb)xlw0uBogjfy1tvu9itTWy0uBogPP93WrYOi1rUi6s2Q4ZFc73WrYOi1rUi6s2QWki)mtlwYqtT5yKuGvpvr1Jm1cJrtT5yKM2F)vtT5yKq(haiJcGCHrtT5yKWHRGXkiWMz2bvMqFn1MJrQjaaTbmmrhzOLYLMM2wSmkzDHbr5ET4pLNmH232CmsUgrRlQLmOjUlHOCVwSvq9rx)FC8Smn8Pio(WfIMRG54da64tS3e0XRGYXPRVRIcS4KsJHhI1tmzQGYXswdiT5yKAcaqlM4iHixfwSmkzDHbr5ET4pHaBMwSOa5nGXguBGtAAuQk(ecSx)R)poo0ngtRIWxFxffyXjcJPvryikWQOnqEqAZq45KK1acTesM0uu5KjaMCx(wb13mAZXi1eUMmdXeHKMM2F)ndniskWQOnqEqAZq45KPnrBkkfm1k7BgUkkWMuGvrBG8G0MHWZPuTMHOK1fwSmMcHbrQohjJmrLtFktPt5U8H213vrbwCIWyAvegEiw3eaG2agMOJm0s5sLSgq65OYBck1eUMmdXeHKAWsx1xfai0G)BQrXFIwt0rgskHtt7V)ITjHWeosgf4ut4AYmetesQvqG1IfKxAd1J2i5AnovRvznBq767QOalorymTkcdpeRLnDKU81agg)deceDxFxffyXjcJPvry4Hy9aOMysB8pqOkitJ8CjRbeSnjeMWrYOaNAcxtMHyIqsTccSwSG8sBOE0gjxRXPATsEY8BgT5yKCnIwxulzqtCxAAF9DvuGfNimMwfHHhI12tunKwRmtt44qYAabBtcHjCKmkWPMW1KziMiKuRGaRfliV0gQhTrY1ACQwRKNmV(UkkWItegtRIWWdX6OJmZTbMR2maifjznG0MJrcrkyeegBgaKIstBlwAZXiHifmccJndasrgfyUbHs4WvW8juzE9DvuGfNimMwfHHhI1OY2wqMAnyBxrxFxffyXjcJPvry4Hy9FasO7r1AqegS(QORVRIcS4eHX0Qim8qSoNYbiPgWWiMQsB0iYZXswdi0sizs)mRz76)JJdDeqOpE2JC7ALDCOhHNt4JpaOJtYNuZGooYxz0XbOJdtjehVnhdSKhVgh3gGXvtqPJNLe)DP4JhiPhpahxgfhp6OJla)jCCCfai0G)7XBoM0hhSh375LWBc640s5fHtxFxffyXjcJPvry4HynIC7ALzgcpNWsQKQeKjCKmkWqGsYAajCKmksrLtMay0f9juPSzXYV)gosgfPoYfrxYwfw9rzAXs4izuK6ixeDjBv8jeyZeAF)1vr1Jm0s5fHHaLfl9Cu5nbLqKBxRmJMeUuRGn7dnOzXYVHJKrrkQCYeaJTkmWMPv)mZV)6QO6rgAP8IWqGYILEoQ8MGsiYTRvMrtcxQvznRqdAx)R)poo0tTfUJq4R)poUCb09Xb7XvaGqd(VhpahhgISpE0rhplGQ44AQnhJJpTV(UkkWItJAlChKgf)jAnrhziPe(67QOalonQTWDWdXASOuKXxTrxksYAaPnhJewukY4R2OlfLquUxl(ZrjRlmik3Rf)TnhJewukY4R2OlfLquUxl(ZFHcEfiVbm2GAdm0G(qL(ORVRIcS40O2c3bpeR1f22dv31)6)JJ)cYfr313vrbwCchKlIoiQoYTn4oqiPsQsqMWrYOadbkjRbKWf0gjBej1awt0rM)KdtIwVji93mchjJIuHnnagF9DvuGfNWb5IOdEiw75TjUJ96riCbwMeWMjSzcfuW(t27VJ2ALHzpO3CBaki9XLxh3vrb2JlkCGtxF2tu4aZGJ9imMwfHzWXKakgCShTEtqAMCSNcvbHkN9OLqYKMIkNmbWK7Y)4wDCOo(3JNXXBZXi1eUMmdXeHKMM2h)7X)94zCCniskWQOnqEqAZq45KPnrBkkfm1k74FpEgh3vrb2KcSkAdKhK2meEoLQ1meLSU44wSC8Xuimis15izKjQC64FECzkDk3L)XHg75QOal7PaRI2a5bPndHNtSGjbSm4ypA9MG0m5ypfQccvo71ZrL3euQjCnzgIjcj1GLUQJ)94kaqOb)3uJI)eTMOJmKucNM2h)7X)94yBsimHJKrbo1eUMmdXeHKECRGCCypUflhh5L2q9OnsUwJt1ECRoEwZ2XHg75QOal71eaG2agMOJm0s5szbtIFYGJ9CvuGL9KnDKU81agg)deceDShTEtqAMCSGjrwzWXE06nbPzYXEkufeQC2dBtcHjCKmkWPMW1KziMiK0JBfKJd7XTy54iV0gQhTrY1ACQ2JB1XLNmp(3JNXXBZXi5AeTUOwYGM4U00M9CvuGL9ga1etAJ)bcvbzAKNZcMezJbh7rR3eKMjh7PqvqOYzpSnjeMWrYOaNAcxtMHyIqspUvqooSh3ILJJ8sBOE0gjxRXPApUvhxEYK9CvuGL9SNOAiTwzMMWXblysipm4ypA9MG0m5ypfQccvo71MJrcrkyeegBgaKIst7JBXYXBZXiHifmccJndasrgfyUbHs4WvWC8ppouzYEUkkWYErhzMBdmxTzaqkIfmjKxm4ypxffyzpuzBlitTgSTRi2JwVjintowWK4JyWXEUkkWYE)biHUhvRbryW6RIypA9MG0m5ybtISpdo2JwVjinto2tHQGqLZE0sizsp(NhpRzJ9CvuGL9YPCasQbmmIPQ0gnI8CmlysavMm4ypA9MG0m5ypxffyzpe521kZmeEoHzpfQccvo7fosgfPOYjtam6Io(NhhQu2oUflh)3J)7XdhjJIuh5IOlzRIJB1X)OmpUflhpCKmksDKlIUKTko(NqooSzECOD8Vh)3J7QO6rgAP8IWhhYXH64wSC8EoQ8MGsiYTRvMrtcx6XT64WM9po0oo0oUflh)3JhosgfPOYjtam2QWaBMh3QJ)Zmp(3J)7XDvu9idTuEr4Jd54qDClwoEphvEtqje521kZOjHl94wD8SM1JdTJdn2tjvjit4izuGzsaflyb7PPHpfbdoMeqXGJ9CvuGL9GPuWWE06nbPzYXcMeWYGJ9CvuGL9Wb5IOJ9O1BcsZKJfmj(jdo2JwVjinto2dyZEykypxffyzVEoQ8MGyVEUysShkAM2CmWh)ZJd7X)E8FpEBogP2evK2eiYXteLM2h3ILJ3MJrsgYxTjNeeLM2h3ILJ3MJrkqtY0ihvRS00(4qJ965iZ65e7HIMbriGqWcMezLbh7rR3eKMjh7bSzpmfSNRIcSSxphvEtqSxpxmj2tbYBaJnO2aN00OuvCCRGCCypo8hh2Jd9p(VhpCbTrswhahcPgCGkyOeTEtq6J)94kaqOb)3KSoaoesn4avWqjeL71Ip(NhhQJdTJd)XBZXi1qaxJlnLM2h)7XPLqYKECRoU8K5X)E8moEBogjmmtHW4R2OqamUbwcNM2h)7XZ44T5yKGHiBJuWez(xb24nWmmsbZ00M965iZ65e755TjUZOaRUIcSSGjr2yWXE06nbPzYXEaB2dtb75QOal71ZrL3ee71ZftI9W2KqychjJcCQjCnzgIjcj94FECyp(3JJ8sBOE0gjxRXPApUvhh2mpUflhVnhJut4AYmetesAAAZE9CKz9CI9AcxtMHyIqsnyPRIfmjKhgCShTEtqAMCSNcvbHkN9Wb5IOJ0jxiypxffyzpLlegxffynIchSNOWHz9CI9Wb5IOJfmjKxm4ypA9MG0m5ypxffyzpLlegxffynIchSNOWHz9CI9uAmlys8rm4ypA9MG0m5ypfQccvo7Pa5nGXguBGpUvqoUY2K7Y3GTPvF8S74)E82CmsneW14stPP9XH)4T5yKa22aum3kKMM2hhAhh6F8FpE4cAJ0hplfmgnY)NO1BcsF8Vh)3JNXXdxqBKYDemK2maiJM8OlrR3eK(4wSCCfai0G)Bk3rWqAZaGmAYJUeIY9AXh3QJd1XH2XH2XH(h)3J7FGqvqjxrMPTrkyImybr9OeYxyo(Nhh2JBXYXZ44kaqOb)3uJI)eTMOJmKucNM2hhAh3ILJRa5nGXguBGpoKJ7BL7QohjJ0gLn75QOal7HMRXvrbwJOWb7jkCywpNyVrTfUJfmjY(m4ypA9MG0m5ypxffyzpLlegxffynIchSNOWHz9CI9AZsOzbtcOYKbh7rR3eKMjh7PqvqOYzpAjKmPjnnkvfh3kihhQSDC4poTesM0eIKrl75QOal75iLVKjaieTblysafum4ypxffyzphP8Lm2tbMypA9MG0m5ybtcOGLbh75QOal7jkzDb2KfBQLLtBWE06nbPzYXcMeq9tgCSNRIcSSxZLzadtGkfmy2JwVjintowWc2ZgrkqEZdgCmjGIbh75QOal7522cPgBqHbl7rR3eKMjhlysaldo2JwVjinto2Zvrbw2l3rWqAZaGmAYJo2tHQGqLZEiV0gQhTrY1ACQ2JB1XZAMSNnIuG8MhgmPaRgZEzJfmj(jdo2JwVjinto2tHQGqLZE)E8moo9XZY2M0jBGcgkW1hiTrbYTNHhfynAQxPOJBXYXZ44kaqOb)3KsQsaceylLPjCCK0tKhfypUflhh5L2q9Ons12Bkwc5nbLi5x4aFCOXEUkkWYE4GCr0XcMezLbh7rR3eKMjh75QOal7HacHj6itdSeM9uOkiu5ShIgic35nbXE2isbYBEyWKcSAm7bllysKngCShTEtqAMCSNRIcSShwukY4R2OlfXEkufeQC2drdeH78MGypBePa5npmysbwnM9GLfmjKhgCShTEtqAMCSNRIcSSNRr06IAjdAI7ypfQccvo797XZ440hplBBsNSbkyOaxFG0gfi3EgEuG1OPELIoUflhpJJRaaHg8FtkPkbiqGTuMMWXrsprEuG94wSCCKxAd1J2ivBVPyjK3euIKFHd8XHg7zJifiV5HbtkWQXShuSGjH8Ibh7rR3eKMjh7TEoXE(hWDoYXMbyddyySb)je75QOal75Fa35ihBgGnmGHXg8NqSGjXhXGJ9O1BcsZKJ9CvuGL9usvcqGaBPmnHJd2tHQGqLZEzCCKxAd1J2ivBVPyjK3euIKFHdm7rJbPcZ65e7PKQeGab2szAchhSGfSxBwcndoMeqXGJ9O1BcsZKJ9uOkiu5ShAU0aGKrPOwPMai)szAcxtj6JNLTnPzpxffyzpCx1JfmjGLbh75QOal7rQoqTYmiYgv5(QzpA9MG0m5ybtIFYGJ9O1BcsZKJ9CvuGL9Wec5bPnnWsgSDbdXEkufeQC2lJJRbrctiKhK20alzW2fmukkfm1k74wSCCxfvpYqlLxe(4qoouh)7XrEPnupAJKR14uTh3QJpMcHbrQohjJmrLth3ILJR6CKmcFCRooSh)7XhLSUWGOCVw8X)84zJ9usvcYeosgfyMeqXcMezLbh7rR3eKMjh7PqvqOYzV2CmsaBBakMBfstt7J)94)ECAjKmPh)ZJN1SDClwoE4cAJ0hplfmgnY)NO1BcsF8VhVnhJemezBKcMiZ)kWgVbMHrkyM0G)7XHg75QOal7zx4aim4oqWcMezJbh7rR3eKMjh7PqvqOYzV2CmsaBBakMBfstt7J)94)E82CmsAY14oqKM2h3ILJ3MJrsgIOfdtTyZ)sbdHWPP9XTy54T5yKuGvrUG0MMyUAc1MyCAAFCOXEUkkWYE2foacdUdeSGjH8WGJ9CvuGL9W1w4GqgCGkyi2JwVjintowWKqEXGJ9O1BcsZKJ9uOkiu5Sx4cAJKUqHutGkfm4eTEtq6J)94kqEdySb1g4KMgLQIJBfKJd1XH)4T5yKAiGRXLMstB2Zvrbw2tgykJyblypCqUi6yWXKakgCShTEtqAMCSNRIcSSNQJCBdUdeSNcvbHkN9cxqBKSrKudynrhz(tomjA9MG0h)7XZ44HJKrrQWMgaJzpLuLGmHJKrbMjbuSGjbSm4ypxffyzppVnXDShTEtqAMCSGfSNsJzWXKakgCShTEtqAMCSNcvbHkN9Y444GCr0r6KleSNRIcSSNYfcJRIcSgrHd2tu4WSEoXEegtRIWSGjbSm4ypxffyzVHWLrcHhfyzpA9MG0m5ybtIFYGJ9O1BcsZKJ9uOkiu5SNMAZXineUmsi8OaBcr5ET4J)5XHL9CvuGL9gcxgjeEuG1OeKVyIfmjYkdo2JwVjinto2tHQGqLZEzC82CmsUgrRlQLmOjUlnTp(3J)7XZ44kaqOb)3emLquRmd2gruAAFClwoEghpCbTrcMsiQvMbBJikrR3eK(4q74Fp(VhpJJtF8SSTjDY)aUZro2maByadJn4pHoUflhxbacn4)MeEqByCKYxpHOCVw8XT64WM5XHg75QOal75AeTUOwYGM4owWKiBm4ypA9MG0m5ypfQccvo71MJrcbect0rMgyjCcr5ET4J)jKJ)ZJBXYX75OYBckHIMbriGqWEUkkWYEiGqyIoY0alHzbtc5Hbh7rR3eKMjh75QOal7L7iyiTzaqgn5rh7PqvqOYzpKxAd1J2i5AnonTp(3J)7XdhjJIuu5KjagDrh)ZJRa5nGXguBGtAAuQkoUflhpJJJdYfrhPtiGSjD8VhxbYBaJnO2aN00OuvCCRGCCLTj3LVbBtR(4z3XH64qJ9usvcYeosgfyMeqXcMeYlgCShTEtqAMCSNcvbHkN9qEPnupAJKR14uTh3QJ)ZmpE2DCKxAd1J2i5AnoPNipkWE8VhpJJJdYfrhPtiGSjD8VhxbYBaJnO2aN00OuvCCRGCCLTj3LVbBtR(4z3XHI9CvuGL9YDemK2maiJM8OJfmj(igCShTEtqAMCSNcvbHkN9W2KqychjJc8XTcYXH94z3XvGvpRi55TstYpiufst06nbPp(3JNXXBZXi1eUMmdXeHKMM2h)7XrEPnupAJKR14uTh3QJdvMSNRIcSSxt4AYmetesklysK9zWXE06nbPzYXEkufeQC2tbYBaJnO2aN00OuvCCRGCCOoo8hVnhJudbCnU0uAAZEUkkWYEY6a4qi1GdubdXcMeqLjdo2JwVjinto2tHQGqLZE9Cu5nbLAcxtMHyIqsnyPR64FpoTesM0uu5KjaMCx(h3QJdl75QOal7btje1kZGTreXcMeqbfdo2JwVjinto2tHQGqLZE9Cu5nbLAcxtMHyIqsnyPR64FpoTesM0uu5KjaMCx(h3QJdl75QOal71eUMmOjUJfmjGcwgCShTEtqAMCSNcvbHkN9Y444GCr0r6Kleh)7X75OYBck55TjUZOaRUIcSSNRIcSSxpFlChlysa1pzWXE06nbPzYXEkufeQC2lJJJdYfrhPtUqC8VhxbYBaJnO2aF8pHCCOypxffyzpnICDt4AcZcMeqLvgCShTEtqAMCSNcvbHkN9Y444GCr0r6Kleh)7X75OYBck55TjUZOaRUIcSSNRIcSShUZ1G)5KqZcMeqLngCShTEtqAMCSNcvbHkN9Y444GCr0r6KleSNRIcSShMSXfMfmjGsEyWXE06nbPzYXEkufeQC2RnhJutaaAXehje5Q44wSC82CmsUgrRlQLmOjUlnTzpxffyzpBquGLfmjGsEXGJ9CvuGL9AcaqBgtKu2JwVjintowWKaQpIbh75QOal71ieMqWuRm2JwVjintowWKaQSpdo2Zvrbw2BuiQjaan7rR3eKMjhlysaBMm4ypxffyzpFveoqUWOCHG9O1BcsZKJfmjGfkgCShTEtqAMCSNRIcSSNsQsaceylLPjCCWEkufeQC2lJJJdYfrhPtUqC8VhVnhJKRr06IAjdAI7sAW)94FpEBogPCkhGKAadJyQkTrJiphN0G)7X)ECAjKmPPOYjtam5U8pUvhpRh)7XrrZ0MJb(4FE8SXE0yqQWSEoXEkPkbiqGTuMMWXblysalSm4ypA9MG0m5ypxffyzp)d4oh5yZaSHbmm2G)eI9uOkiu5SxghVnhJKRr06IAjdAI7st7J)94zC82CmsnHRjZqmriPPP9X)ECfai0G)BY1iADrTKbnXDjeL71Ip(NhhQSXERNtSN)bCNJCSza2WaggBWFcXcMeW(tgCShTEtqAMCSNRIcSSNJ765lHni)daKrbqUG9uOkiu5SNMAZXiH8paqgfa5cJMAZXiPb)3JBXYX1uBogjfy1tvu9itTWy0uBogPP9X)E8WrYOi1rUi6s2Q44FE8Fc7X)E8WrYOi1rUi6s2Q44wb54)mZJBXYXZ44AQnhJKcS6PkQEKPwymAQnhJ00(4Fp(VhxtT5yKq(haiJcGCHrtT5yKWHRG54wb54WM5XZUJdvMhh6FCn1MJrQjaaTbmmrhzOLYLMM2h3ILJpkzDHbr5ET4J)5XLNmpo0o(3J3MJrY1iADrTKbnXDjeL71IpUvhhQpI9wpNyph31ZxcBq(haiJcGCblysaBwzWXE06nbPzYXEkufeQC2RnhJutaaAXehje5Q44wSC8rjRlmik3RfF8pHCCyZ84wSCCfiVbm2GAdCstJsvXX)eYXHL9CvuGL9MyYubLJzblyVrTfUJbhtcOyWXEUkkWYEnk(t0AIoYqsjm7rR3eKMjhlysaldo2JwVjinto2tHQGqLZET5yKWIsrgF1gDPOeIY9AXh)ZJpkzDHbr5ET4J)94T5yKWIsrgF1gDPOeIY9AXh)ZJ)7XH64WFCfiVbm2GAd8XH2XH(hhQ0hXEUkkWYEyrPiJVAJUuelys8tgCSNRIcSSNUW2EO6ypA9MG0m5yblyb75ZOdGyVxLNfyblyma]] )

end