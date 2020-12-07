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

    spec:RegisterCycle( function ()
        if active_enemies == 1 then return end
        if this_action == "marked_for_death" and target.time_to_die > Hekili:GetLowestTTD() then return "cycle" end
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


    spec:RegisterPack( "Outlaw", 20201206, [[d8KOOaqifv9iQeUevskTjsuFIkGgLuroLuHwLurvVcinlOs3Iki7sHFbv1WKQ4yavldQYZuuPPbvW1Os02Oc03uurnoQGQZbvOSoOcvZdQO7Pi7tQshurfSqG4Hsf0eLkWfvuH2OIkYhLkkCsQKKvsfntPIkUjvaStfLFsfugkvs0rLkkAPujHNkLPkv1vPcqBLkjfFvQOsJvQOu7vP)kXGjCyklwspMOjtQlJAZq5ZKWOPQoTOvlvuYRjrMns3MQSBv(nKHtshhQqwoINdA6cxhW2bkFNk04PsQZtLA9ujPA(sL2VQEbF7VnTf8odVEWRhWXRhhCGxp4GlXbxUTWTkVnvtQKPG32zE82Cyab1CCBQMBkY0B)TbraejVn)iuH444JVIm8bQdjYdFy6bqTirNKyyb(W0tI)2QajnCv3w3M2cENHxp41d441JdoWRhCWL4a4BdQYYDgEoypBZp1A(2620muUnx8chgqqnhFHRaPaGFNU4fDalzVktEHdI7lWRh86zBQeews5T5Ix4WacQ54lCfifa870fVOdyj7vzYlCqCFbE9GxpVZ3PlEXC01Seiy9lQmgIWVqI8Qw8IkRip44fZbPKvd4lo05q(gXddG(ctgj6GVaDu3J3PjJeDWHkHLiVQftMQk1DrfLq09onzKOdoujSe5vTa0j89mIsSUGHifnBHpUQewI8QwuGSeDA4KlXnXMiwQlmy8fdtRHJ86fh65DAYirhCOsyjYRAbOt4dd2OH)70KrIo4qLWsKx1cqNWNGO0s4ZLk6yiUQewI8QwuGSeDA4eE4MytegJWqFRs53PjJeDWHkHLiVQfGoHpKMsUyNUOtjJRkHLiVQffilrNgoHhUj2eHXim03Qu(DAYirhCOsyjYRAbOt4BAcFgnpUqaG(4QsyjYRArbYs0PHtGJBIn1P5zCeqQQY6HksQehW0vN1fjYtfiSirxrZGLsUB35LievJC8gs3skkiOlLLk1GXqdqSirx3Uel1fgm(IrEGbqpMyvkpyxNWa2X3570fVyo6AwceS(fmymX9lI0JFr4ZVWKbI8Ie(cdmlPwLYJ3PjJeDWjLsPsVtx8cxbdd2OH)lsSxOIGWSs5x0Pd9cWaOhtSkLFbFSxYWxK3lKiVQfD8DAYirhe0j8HbB0W)D6Ix4kycIsFbmpfu(fG0h)odha87dYlQayyWx4OpFVqfbHzLYVttgj6GGoHpygjTkLX9mpEIe1cHjikfxWmkaprIAPcGHbXjEk3Pkag2OcqswxccBqacpau72TcGHnuqStx8ykZda1UDRayyJGaWLkBK8umau7470KrIoiOt4dMrsRszCpZJNmVka0VirNoJeD4cMrb4jjYRIkQO8c4qZyPmJENWd0kag2OsqMgMAEaOQmFmrH7ENCzpVtx8Io3m8FHhansvk)IWik4aI7lc)e(cWmsAvk)Ie(cPplvI1ViqVqZYuZVWrFo8zYlGip(fDyhaFb0hbq1VOYVa6(KS(foMH)laHAA(fZjkaH4(DAYirhe0j8bZiPvPmUN5XtvQP5cgfGqCxGUpjUGzuaEcQYuAjmIcoGJk10CbJcqiUXjEktSuxyW4lgMwdh51lE90TBfadBuPMMlyuacX9aq9DAYirhe0j8LgLwmzKORqtyG7zE8emyJg(4MytWGnA4Z6HrPVttgj6GGoHV0O0IjJeDfAcdCpZJNKA470fVyoLxc9FHfVWZCD6b49Io0v(Ikq8cdmuQFHJgmYtXlaHGmnm18lSt)IotGuQ0l6aI54lQOda(cjYRIEHkkVa(onzKOdc6e(eGRyYirxHMWa3Z84jS8sOpUj2Ke5vrfvuEbS3jPAXZCDbQYN2HQayyJkbzAyQ5bGQd1Pkag2aPQIibWLH7bGANpmkFXahbKsLkAI54GpRszDh72vI8QOIkkVaozx6zsFJOG1fP670KrIoiOt4lnkTyYirxHMWa3Z84Pkqs1Vttgj6GGoHVrK2XLari8f4Myt8XefUhAglLz07e4Ueu(yIc3dcRGV3PjJeDqqNW3is74IkafYVttgj6GGoHpnv4hWsNfGwHhFX70KrIoiOt4xnffewjiPuj478D6Ixacqs1mb(onzKOdoQajvpb9tWWnXMiahJHik4rKN7sGCDklvQP53PjJeDWrfiPAqNWNL(O8uuiSkj9St)onzKOdoQajvd6e(qMqSG1Lk64cunvIXv6ws5syefCaNah3eBAEnkgqMqSG1Lk64cunvIhrkvkpfD7AYibJl8XEjdNaxzIL6cdgFXW0A4iVEXaO0cHL(grbxI0J72v6BefmSx8uglv4hfc7z5bXPlFNU4foGq(fUYegi6lA(O4foMH)lCyQQisaCz4(fj2lQmf54lWbx(c(yIc34(ce5fo6Z3laG5P4fDMaPuPx0beZX3PjJeDWrfiPAqNWxnHbIwG(Oa3eBQcGHnqQQisaCz4EaOQCN4JjkCJtCWLD7ggLVyGJasPsfnXCCWNvPSUJVttgj6GJkqs1GoHVAcdeTa9rbUj2ufadBGuvrKa4YW9aqv5ovbWWgkimFqLYdwCmLkXe4aqTB3kag2qIojBuwxQuGtZKkaeoau7470KrIo4OcKunOt4dZlHbtkWGKkXVttgj6GJkqs1GoHVceGcg3eBkmkFXqNKWDjiPuj4GpRszTYsKxfvur5fWHMXszg9oboOvamSrLGmnm18aq9D(oDXl6qeIQroEW3PlEHdimpfVyo4vbG(ViHVWEbEUAFrEscBqg3xarVWvJDj0)fs7ErLFbe5Xr6XWxu5xaaz9lm4lSxaejnd3VaQYu6laokdHVaaMNIx4ayWGjVyoaHgeM3lqKx0bSf(u3VO5BAKJW3PjJeDWHudNaZUe6JBInnpmyJg(SEyuQYGzK0QuEyEvaOFrIoDgj6u2ZGbtkgeAqyEfc7z5bN6r5kag2qZw4tDxG(Mg5iCOroEVttgj6GdPgc6e(yutbtPwKO7DAYirhCi1qqNWhJAkyk1IeDfjLTdY4MytAUcGHnWOMcMsTir3GWEwEqCI370KrIo4qQHGoHVPj8z084cba6JBInnFfadByAcFgnpUqaG(davL708seIQroEdLsknpffOkH5bGA3UZhgLVyOusP5POavjmp4ZQuw3X3PjJeDWHudbDcFcIslHpxQOJH4MytvamSbbrPLWNlv0XWbH9S8G4CAUD7cMrsRs5bjQfctqu670fVWvH9ctRHVWi8lauX9fWlv5xe(8lqh)chZW)fuKJmmEr)(DW4foGq(fo6Z3l0UZtXlWmyWKxe(29Io0v(cnJLYmEbI8chZWhbeVWo3VOdDLJ3PjJeDWHudbDcFpJOeRlyisrZw4JR0TKYLWik4aoboUj2eXsDHbJVyyAnCaOQCNcJOGJrKECjqfDY4uI8QOIkkVao0mwkZOB35HbB0WN1dcsbaRSe5vrfvuEbCOzSuMrVts1IN56cuLpTdbEhFNU4fUkSxCOxyAn8foMu6l0j)chZWpVxe(8lo21XlMBpqCFbaKFHdawh8c09IkccFHJz4JaIxyN7x0HUYX70KrIo4qQHGoHVNruI1fmePOzl8XnXMiwQlmy8fdtRHJ86DU94qel1fgm(IHP1WHgGyrIoLNhgSrdFwpiifaSYsKxfvur5fWHMXszg9ojvlEMRlqv(0oe4Vtx8cqOMMFXCIcqiUFb6EbEG(c(yVKHVttgj6GdPgc6e(vQP5cgfGqCJBInbvzkTegrbhWENWt55RayyJk10CbJcqiUhaQVttgj6GdPgc6e(k8rWG6UadsQeJBInjrEvurfLxahAglLz07e4GwbWWgvcY0WuZda13PjJeDWHudbDcFLsknpffOkHzCtSjWmsAvkpQutZfmkaH4UaDFsL5JjkCpI0JlbQ4zUUx8ENMms0bhsne0j8RutZfca0h3eBcmJKwLYJk10CbJcqiUlq3Nuz(yIc3Ji94sGkEMR7fV3PjJeDWHudbDcFnHnDLAAgIBInnpmyJg(SEyuQYsKxfvur5fqCob(70KrIo4qQHGoHp030ih9yQg3eBAEyWgn8z9WOuLbZiPvP8W8Qaq)IeD6ms09onzKOdoKAiOt4dzvycXnXMMhgSrdFwpmk9DAYirhCi1qqNWxffj6WnXMQayyJkfH0uaymiSjJUDXsf(rHWEwEqCo3E62TcGHnmnHpJMhxiaq)bG670KrIo4qQHGoHFLIq6cgaX970KrIo4qQHGoHFLjqMOuEkENMms0bhsne0j8XscxPiK(DAYirhCi1qqNW3ojddIrlsJsFNU4fDaJza04fygLwnPsVadrEba0Qu(fzWEWX70KrIo4qQHGoHpaKlzWEqCtSPkag2OsrinfagdcBYOBxSuHFuiSNLheNt41t3UsKxfvur5fWHMXszg4CcV3570fVyoLxc9zc8D6IxasmhFb6EHeHOAKJ3lc0luIz1xe(8l6qsgVqZvamSxaO(onzKOdoWYlH(tvoCK5Re(CHDZW3PjJeDWbwEj0h0j8H0uYf70fDkzCtSPkag2astjxStx0PKhe2ZYdItSuHFuiSNLhu5kag2astjxStx0PKhe2ZYdIZoboOsKxfvur5fWo25bF4WFNMms0bhy5LqFqNWxNqvlK(VZ3PlErlyJg(Vttgj6GdyWgn8NK(SPwG(OaxPBjLlHruWbCcCCtSPWO8fdvc7UGUs4ZfhztPbFwLYALNpmIcogjSurq470KrIo4agSrdFqNW38Qaq)TbgtGj62z41dE9aoE94YT5OrU8ua3wN7CWvmZvnRZah)fVOVp)I0tfrIxGHiVWbwbsQ2b(ccJJascRFbe5XVWacKNfS(fsF7uWWX7SZjp(fGJJ)IoeDGXKG1VWbsaogdruWJoBh4lc0lCGeGJXqef8OZEWNvPS2b(clEXC0H158IobUR744D(oDvEQisW6x4GVWKrIUxqtyahVZTrtya3(BtZygan2(7mW3(BZKrIUTPukvAB8zvkRxq2yNH32FBMms0TnyWgn83gFwLY6fKn2zZD7Vn(SkL1liBdPUnihBZKrIUTbMrsRs5TbMrb4TrIAPcGHbFboFbEVq5x0PxubWWgvasY6sqydcq4bG6l629fvamSHcID6IhtzEaO(IUDFrfadBeeaUuzJKNIbG6l642aZiLZ84TrIAHWeeLUXodh2(BJpRsz9cY2qQBdYX2mzKOBBGzK0QuEBGzuaEBsKxfvur5fWHMXszgVO3PxG3la9fvamSrLGmnm18aq9fk)c(yIc3VO3Px4YE2gygPCMhVnZRca9ls0PZir3g7mxU93gFwLY6fKTHu3gKJTzYir32aZiPvP82aZOa82GQmLwcJOGd4OsnnxWOaeI7xGZxG3lu(fel1fgm(IHP1WrEVO3xGxpVOB3xubWWgvQP5cgfGqCpau3gygPCMhVTk10CbJcqiUlq3NCJDMdU93gFwLY6fKTjjzWK02gmyJg(SEyu62mzKOBBsJslMms0vOjm2gnHr5mpEBWGnA4VXoBoV93gFwLY6fKTzYir32KgLwmzKORqtySnAcJYzE82KA4g7mh(2FB8zvkRxq2MKKbtsBBsKxfvur5fWx070lKQfpZ1fOkF6x4qVOcGHnQeKPHPMhaQVWHErNErfadBGuvrKa4YW9aq9fD(xegLVyGJasPsfnXCCWNvPS(fD8fD7(cjYRIkQO8c4lMEHDPNj9nIcwxKQBZKrIUTraUIjJeDfAcJTrtyuoZJ3gwEj0FJDgo22FB8zvkRxq2MjJeDBtAuAXKrIUcnHX2OjmkN5XBRcKu9g7mW7z7Vn(SkL1liBtsYGjPTn(yIc3dnJLYmErVtVaCx(cqFbFmrH7bHvW32mzKOBBgrAhxceHWxSXodCW3(BZKrIUTzePDCrfGc5TXNvPSEbzJDg44T93MjJeDBJMk8dyPZcqRWJVyB8zvkRxq2yNb(C3(BZKrIUTvnffewjiPuj424ZQuwVGSXgBtLWsKx1IT)od8T)2mzKOBBMQk1DrfLq0Tn(SkL1liBSZWB7Vn(SkL1liBZKrIUT5zeLyDbdrkA2c)TjjzWK02gXsDHbJVyyAnCK3l69f4qpBtLWsKx1IcKLOtd3Ml3yNn3T)2mzKOBBWGnA4Vn(SkL1liBSZWHT)24ZQuwVGSntgj62gbrPLWNlv0XWTjjzWK02gHXim03QuEBQewI8QwuGSeDA42WBJDMl3(BJpRsz9cY2mzKOBBqAk5ID6IoL82KKmysABJWyeg6BvkVnvclrEvlkqwIonCB4TXoZb3(BJpRsz9cY2mzKOBBMMWNrZJleaO)2KKmysABRtVy(xW4iGuvL1dvKujoGPRoRlsKNkqyrIUIMblL8l629fZ)cjcr1ihVH0TKIcc6szPsnym0aels09IUDFbXsDHbJVyKhya0JjwLYd21jmGVOJBtLWsKx1IcKLOtd3g4BSX2QajvV93zGV93gFwLY6fKTjjzWK02gb4ymerbpI8CxcKRtzPsnnp4ZQuwVntgj62g0pbBJDgEB)TzYir32yPpkpffcRssp70BJpRsz9cYg7S5U93gFwLY6fKTzYir32GmHybRlv0XfOAQeVnjjdMK22M)fAumGmHybRlv0XfOAQepIuQuEkEr3UVWKrcgx4J9sg(IPxa(lu(fel1fgm(IHP1WrEVO3xGbqPfcl9nIcUePh)IUDFH03iky4l69f49cLFbwQWpke2ZYd(cC(cxUnPBjLlHruWbCNb(g7mCy7Vn(SkL1liBtsYGjPTTkag2aPQIibWLH7bG6lu(fD6f8XefUFboFbo4Yx0T7lcJYxmWraPuPIMyoo4ZQuw)IoUntgj62MAcdeTa9rXg7mxU93gFwLY6fKTjjzWK02wfadBGuvrKa4YW9aq9fk)Io9Ikag2qbH5dQuEWIJPujMahaQVOB3xubWWgs0jzJY6sLcCAMubGWbG6l642mzKOBBQjmq0c0hfBSZCWT)2mzKOBBW8syWKcmiPs824ZQuwVGSXoBoV93gFwLY6fKTjjzWK02wyu(IHojH7sqsPsWbFwLY6xO8lKiVkQOIYlGdnJLYmErVtVa8xa6lQayyJkbzAyQ5bG62mzKOBBkqak4n2yBWGnA4V93zGV93gFwLY6fKTzYir32K(SPwG(OyBssgmjTTfgLVyOsy3f0vcFU4iBkn4ZQuw)cLFX8VimIcogjSurq42KULuUegrbhWDg4BSZWB7Vntgj62M5vbG(BJpRsz9cYgBSnPgU93zGV93gFwLY6fKTjjzWK0228VagSrdFwpmk9fk)cWmsAvkpmVka0VirNoJeDVq5x4zWGjfdcnimVcH9S8GVy6f98cLFrfadBOzl8PUlqFtJCeo0ihVTzYir32aZUe6VXodVT)2mzKOBByutbtPwKOBB8zvkRxq2yNn3T)24ZQuwVGSnjjdMK220CfadBGrnfmLArIUbH9S8GVaNVaVTzYir32WOMcMsTirxrsz7G8g7mCy7Vn(SkL1liBtsYGjPTT5FrfadByAcFgnpUqaG(da1xO8l60lM)fseIQroEdLsknpffOkH5bG6l629fZ)IWO8fdLsknpffOkH5bFwLY6x0XTzYir32mnHpJMhxiaq)n2zUC7Vn(SkL1liBtsYGjPTTkag2GGO0s4ZLk6y4GWEwEWxGZPxm3x0T7laZiPvP8Ge1cHjikDBMms0TncIslHpxQOJHBSZCWT)24ZQuwVGSntgj62MNruI1fmePOzl83MKKbtsBBel1fgm(IHP1WbG6lu(fD6fHruWXispUeOIo5xGZxirEvurfLxahAglLz8IUDFX8VagSrdFwpiifa8lu(fsKxfvur5fWHMXszgVO3PxivlEMRlqv(0VWHEb4VOJBt6ws5syefCa3zGVXoBoV93gFwLY6fKTjjzWK02gXsDHbJVyyAnCK3l69fZTNx4qVGyPUWGXxmmTgo0aels09cLFX8VagSrdFwpiifa8lu(fsKxfvur5fWHMXszgVO3PxivlEMRlqv(0VWHEb4BZKrIUT5zeLyDbdrkA2c)n2zo8T)24ZQuwVGSnjjdMK22GQmLwcJOGd4l6D6f49cLFX8VOcGHnQutZfmkaH4EaOUntgj62wLAAUGrbie3BSZWX2(BJpRsz9cY2KKmysABtI8QOIkkVao0mwkZ4f9o9cWFbOVOcGHnQeKPHPMhaQBZKrIUTPWhbdQ7cmiPs8g7mW7z7Vn(SkL1liBtsYGjPTnWmsAvkpQutZfmkaH4UaDFYxO8l4JjkCpI0JlbQ4zU(f9(c82MjJeDBtPKsZtrbQsyEJDg4GV93gFwLY6fKTjjzWK02gygjTkLhvQP5cgfGqCxGUp5lu(f8XefUhr6XLav8mx)IEFbEBZKrIUTvPMMleaO)g7mWXB7Vn(SkL1liBtsYGjPTT5FbmyJg(SEyu6lu(fsKxfvur5fWxGZPxa(2mzKOBBAcB6k10mCJDg4ZD7Vn(SkL1liBtsYGjPTT5FbmyJg(SEyu6lu(fGzK0QuEyEvaOFrIoDgj62MjJeDBd6BAKJEmvVXodCCy7Vn(SkL1liBtsYGjPTT5FbmyJg(SEyu62mzKOBBqwfMWn2zG7YT)24ZQuwVGSnjjdMK22QayyJkfH0uaymiSjJx0T7lWsf(rHWEwEWxGZxm3EEr3UVOcGHnmnHpJMhxiaq)bG62mzKOBBQOir3g7mWDWT)2mzKOBBvkcPlyae3BJpRsz9cYg7mWNZB)TzYir32QmbYeLYtX24ZQuwVGSXodCh(2FBMms0TnSKWvkcP3gFwLY6fKn2zGJJT93MjJeDBZojddIrlsJs3gFwLY6fKn2z41Z2FB8zvkRxq2MKKbtsBBvamSrLIqAkamge2KXl629fyPc)Oqyplp4lW50lWRNx0T7lKiVkQOIYlGdnJLYmEboNEbEBZKrIUTba5sgShCJn2gwEj0F7VZaF7Vntgj62wLdhz(kHpxy3mCB8zvkRxq2yNH32FB8zvkRxq2MKKbtsBBvamSbKMsUyNUOtjpiSNLh8f48fyPc)Oqyplp4lu(fvamSbKMsUyNUOtjpiSNLh8f48fD6fG)cqFHe5vrfvuEb8fD8fD(xa(WHVntgj62gKMsUyNUOtjVXoBUB)TzYir320ju1cP)24ZQuwVGSXgBSndi8rKT1sVoCJn2f]] )

end