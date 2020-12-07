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


    spec:RegisterPack( "Outlaw", 20201207, [[d8KlQaqiqfpIcLljfQWMOaFIevnkPaNIcvRsrH8kOIzbv5wuizxk8lOQgMuIJbkwguPNPOKPjfIRPOuBtrr9nPqzCKOuNJefzDsbP5bQ09uK9jL0bPqQwiO0dLcQjkfsxurHAJkkWhjrbNKevALuKzsIsCtsuODQO6NuiLHkfehvkuvlLev8uPAQsPUkjkQTkfQOVsIsASkkO9Q0FLyWiDyQwSKEmrtMuxg1MHYNjHrtPoTOvlfQYRjrMnHBtj7wLFdz4K0XvuKLJ45atx46GSDqvFNcA8uiopf16LcvA(sr7xvVWST3U2dENJBl42cm42sJnGPfCHbgL92dZQ82vDPsUcE7NBXB3Obfc3WTR6MfixVT3oabrK82TJqf0qXhFfzydvhsKf(G0cs4rIojXXc8bPLe)TxHsrOCVTUDTh8oh3wWTfyWTLgBatl42YSASTduz5oh3zULTBNAnFBD7Agi3UXEQrdkeUHpv5GuaXVjJ90gLLSvLjpTXW7P42cUTSDvcclf82n2tnAqHWn8PkhKci(nzSN2OSKTQm5PngEpf3wWTL30BYypDgBewcfS(Pvgdr4NkrwvpEALvKhy8uJUuYQb4Ph6mkBNyHbjEQlJeDGNIoH5XBYLrIoWqLWsKv1JjxvvyUOIsa6EtUms0bgQewISQEGZe(worjwxWqKIM9WgpvclrwvpkawIonyA24Lytep1fgE(IHR1GrET2iT8MCzKOdmujSezv9aNj8bb7IW(n5YirhyOsyjYQ6bot4tqcrjS5sfDmapvclrwvpkawIonycx8sSjcJryGTxf8BYLrIoWqLWsKv1dCMWhisjx8tx0PKXtLWsKv1JcGLOtdMWfVeBIWyegy7vb)MCzKOdmujSezv9aNj8DnHpxKhxiqaB8ujSezv9Oayj60GjyWlXMAaC4zckvvz9qfjvIdq24Y6IezPcfEKOROz4tj3SjCKiKqJm8gsZsbkiOlLLQWbXqdr8irxZMep1fgE(IrEWdjoM4vbpyJKGay830BYypDgBewcfS(Pm8mX8tJ0IFAyZp1LbI80e8uhEpfEvWJ3KlJeDGjLsPsVjJ9uLddc2fH9ttSNQIaGSk4N2Gd9u4Heht8QGFkFSvYGNM3tLiRQhg)n5YirhaNj8bb7IW(nzSNQCycsiEkipfc(PW2gFLbLr8Bd7tRqyyGNAOnFpvfbazvWVjxgj6a4mHp8oj9QGX7ClEIe1cHjiHap4DbeprIAPcHHbGlUg0Gkeg2Ocrswxcc7aicpGuB2ScHHnuq8txSybZdi1MnRqyyJGaXLk7K8umGun(BYLrIoaot4dVtsVky8o3INCRkeWUirNoJeD4bVlG4jjYQIkQO8cWqZyPmJwNWfNkeg2OsqUgKAEaPAaFmrH5wNMDlVjJ9uL1mSFQfKisvb)0Wjk4aG3td7e8u4Ds6vb)0e8uPnlvI1pnqpvZYuZp1qBoSzYtbil(PnCJcEkWgbj0pTYpfy(KS(PgMH9tHv4A(PZabeHy(n5YirhaNj8H3jPxfmENBXtvHR5cMaIqmxaMpjEW7ciEcOYcrjCIcoaJQW1CbtariMHlUgq8uxy45lgUwdg51kUT0SzfcdBufUMlycicX8as9n5YirhaNj8LUquCzKORisqG35w8eiyxe24LytGGDryZ6HleVjxgj6a4mHV0fIIlJeDfrcc8o3INKAWBYypDgKxcSFQhp1YnsAbz90gUH80ku8uhEuQFQHoiYtXtHLGCni18t9t)0gFOuQ0tBuIB4tROdc8ujYQIEQkkVa8MCzKOdGZe(eOR4YirxrKGaVZT4jS8sGnEj2KezvrfvuEbO1jPAXYnsbOYN2OQqyyJkb5AqQ5bKQr1Gkeg2aPQIib0LH5bK6mkCbFXyMGsPsfnXnCWNxfS24nBkrwvurfLxaM8lTCPTtuW6Iu9n5YirhaNj8LUquCzKORisqG35w8ufkf63KlJeDaCMW3js)4sGie(c8sSj(yIcZdnJLYmADcMzJdFmrH5bHvW3BYLrIoaot47ePFCrfsa43KlJeDaCMWxKkSdqPXdsRWIV4n5YirhaNj8RUIccReKuQe4n9Mm2tHfkfAMaEtUms0bgvOuONa2j84LyteOJXqef8iYZCjqgjLLQW18BYLrIoWOcLcnot4ZsBuEkkewLKw(PFtUms0bgvOuOXzcFatiEW6sfDCbOMkX4jnlfCjCIcoatWGxInbhnkgaMq8G1Lk64cqnvIhrkvkpfnB6YiHNl8XwjdMGXaIN6cdpFXW1AWiVwXGeIcHL2orbxI0IB2uA7efmOvCnalvyhfcB55bG7SFtg7PkZa(PnKeeiXt72O4PgMH9tnAQQisaDzy(Pj2tRSaz4tBKz)u(yIcZ49ue5PgAZ3tHa5P4Pn(qPuPN2Oe3W3KlJeDGrfkfACMWxnbbsua2OaVeBQcHHnqQQisaDzyEaPAqd4Jjkmd3gz2nBgUGVymtqPuPIM4go4ZRcwB83KlJeDGrfkfACMWxnbbsua2OaVeBQcHHnqQQisaDzyEaPAqdQqyydfeMpGs5bkgMsLycyaP2SzfcdBirNKDbRlvb0PzsfcagqQg)n5YirhyuHsHgNj8b5LGGjfqqsL43KlJeDGrfkfACMWxbcsbJxInfUGVyOtsyUeKuQeyWNxfS2ajYQIkQO8cWqZyPmJwNGbNkeg2OsqUgKAEaP(MEtg7Pnmcj0idpWBYypvzgKNINA0TQqa7NMGN6pf3ghpnpjHDaJ3tbON240Vey)uPFpTYpfGS4iTyWtR8tHaS(Po4P(tHIuKH5NcuzH4PqNGbGNcbYtXtvgDqWKNA0bahaY7PiYtBu2dBH5N2TDnYqWBYLrIoWqQbtW7xcSXlXMGdiyxe2SE4cHbW7K0RcE4wviGDrIoDgj6mWYbbtkoa4aqEfcB55bMAXGgahc0XyiIcEOzpSfMlaBxJme0SzfcdBOzpSfMlaBxJmem0idpdKiRkQOIYlaWfxJ)MCzKOdmKAaot4JjCfSq4rIU3KlJeDGHudWzcFmHRGfcps0vKc2paJxInP5keg2at4kyHWJeDdcB55bGlUVjxgj6adPgGZe(UMWNlYJleiGnEj2eCQqyydxt4Zf5XfceWEaPAqdGJeHeAKH3qPuiYtrbOsyEaP2SjCcxWxmukfI8uuaQeMh85vbRn(BYLrIoWqQb4mHpbjeLWMlv0Xa8sSPkeg2GGeIsyZLk6yWGWwEEa4onRMnH3jPxf8Ge1cHjiH4nzSNQCXEQR1GN6e(PqQ49uWLQ8tdB(POJFQHzy)ubYqgepTD7gD8uLza)udT57PAZ5P4PyoiyYtdB)EAd3qEQMXszgpfrEQHzyJGIN6N5N2WnKXBYLrIoWqQb4mHVLtuI1fmePOzpSXtAwk4s4efCaMGbVeBI4PUWWZxmCTgmGunObHtuWXislUeOIoz4krwvurfLxagAglLz0SjCab7IWM1dcsbeBGezvrfvuEbyOzSuMrRts1ILBKcqLpTrbJXFtg7PkxSNEON6An4PgMcXt1j)udZWoVNg28tp2iXtNvla8EkeGFQYiwJ(u090kcaEQHzyJGIN6N5N2WnKXBYLrIoWqQb4mHVLtuI1fmePOzpSXlXMiEQlm88fdxRbJ8ADwTyuep1fgE(IHR1GHgI4rIodGdiyxe2SEqqkGydKiRkQOIYladnJLYmADsQwSCJuaQ8PnkyEtg7PWkCn)0zGaIqm)u09uCX5P8XwjdEtUms0bgsnaNj8RcxZfmbeHygVeBcOYcrjCIcoaToHRbWPcHHnQcxZfmbeHyEaP(MCzKOdmKAaot4RWgbcH5ciiPsmEj2KezvrfvuEbyOzSuMrRtWGtfcdBujixdsnpGuFtUms0bgsnaNj8vkfI8uuaQeMXlXMG3jPxf8OkCnxWeqeI5cW8jnGpMOW8islUeOILBKwX9n5Yirhyi1aCMWVkCnxiqaB8sSj4Ds6vbpQcxZfmbeHyUamFsd4JjkmpI0IlbQy5gPvCFtUms0bgsnaNj81e21vHRzaEj2eCab7IWM1dximqISQOIkkVaa3jyEtUms0bgsnaNj8b2UgzOfl04LytWbeSlcBwpCHWa4Ds6vbpCRkeWUirNoJeDVjxgj6adPgGZe(awfKa8sSj4ac2fHnRhUq8MCzKOdmKAaot4RIIeD4LytvimSrvGqAbeige2LrZMyPc7OqylppaCNvlnBwHWWgUMWNlYJleiG9as9n5Yirhyi1aCMWVkqiDbdIy(n5Yirhyi1aCMWVYeatukpfVjxgj6adPgGZe(yjHRces)MCzKOdmKAaot47NKbbXffPleVjJ90gLXCir8umxiQUuPNIHipfc4vb)0mylW4n5Yirhyi1aCMWhcWLmylaEj2ufcdBufiKwabIbHDz0SjwQWoke2YZda3jCBPztjYQIkQO8cWqZyPmd4oH7B6nzSNodYlb2mb8Mm2tHnMXpfDpvIqcnYW7Pb6PkXS6tdB(PnmjJNQ5keg2tHuFtUms0bgy5La7PkhgY8vcBUWMzWBYLrIoWalVeyJZe(ark5IF6IoLmEj2ufcdBaePKl(Pl6uYdcB55bGlwQWoke2YZdyqfcdBaePKl(Pl6uYdcB55bGBdGbhjYQIkQO8cGXNrWmu2Vjxgj6adS8sGnot4RtGQhs730BYypThSlc73KlJeDGbiyxe2t6eO6H0gVeBsISQOIkkVa06KuTy5gPau5t)MCzKOdmab7IWEsAZUAbyJc8KMLcUeorbhGjyWlXMcxWxmujS5c6kHnxmKDLg85vbRnaoHtuWXibLkcaEtUms0bgGGDryJZe(UvfcyVD4zcir3oh3wWTfyWTLzE7g6KlpfGTRSA0voZvUZvgAOp9PTT5NMwQis8ume5PkVudu(Ns4zckjS(PaKf)uhkqwEW6NkT9tbdgVjLL84Nctd9Pnm6GNjbRFQYtGogdruWJzOY)0a9uLNaDmgIOGhZWbFEvWAL)PnagJy8XB6nPSA0voZvUZvgAOp9PTT5NMwQis8ume5PkFfkfAL)PeEMGscRFkazXp1HcKLhS(PsB)uWGXBszjp(PW0qFAdJo4zsW6NQ8eOJXqef8ygQ8pnqpv5jqhJHik4XmCWNxfSw5FQhpDgB0uwEAdGXigF8MEtkxlvejy9tN5N6Yir3tfjiaJ302fjiaB7TRzmhseB7DomB7T7Yir32vkLkTD(8QG1lSBSZXDBVDxgj62oiyxe2BNpVky9c7g78zTT3oFEvW6f2TJu3oGJT7Yir32H3jPxf82H3fq82jrTuHWWapfUpf3NAWtBWtRqyyJkejzDjiSdGi8as9PnB(0keg2qbXpDXIfmpGuFAZMpTcHHnccexQStYtXas9PgF7W7KY5w82jrTqycsi2yN3iB7TZNxfSEHD7i1Td4y7Ums0TD4Ds6vbVD4DbeVDjYQIkQO8cWqZyPmJN260tX9P480keg2OsqUgKAEaP(udEkFmrH5N260tNDlBhENuo3I3UBvHa2fj60zKOBJD(S32BNpVky9c72rQBhWX2DzKOB7W7K0RcE7W7ciE7avwikHtuWbyufUMlycicX8tH7tX9Pg8uIN6cdpFXW1AWiVN26tXTLN2S5tRqyyJQW1CbtariMhqQBhENuo3I3Ev4AUGjGieZfG5tUXoFM32BNpVky9c72LKmys6BheSlcBwpCHy7Ums0TDPlefxgj6kIeeBxKGOCUfVDqWUiS3yN3yB7TZNxfSEHD7Ums0TDPlefxgj6kIeeBxKGOCUfVDPgSXoxzVT3oFEvW6f2TljzWK03UezvrfvuEb4PTo9uPAXYnsbOYN(Pg1tRqyyJkb5AqQ5bK6tnQN2GNwHWWgivvejGUmmpGuF6m6PHl4lgZeukvQOjUHd(8QG1p14pTzZNkrwvurfLxaE60t9lTCPTtuW6IuD7Ums0TDc0vCzKORisqSDrcIY5w82XYlb2BSZvM22BNpVky9c72DzKOB7sxikUms0veji2Uibr5ClE7vOuO3yNdtlB7TZNxfSEHD7ssgmj9TZhtuyEOzSuMXtBD6PWm7NIZt5JjkmpiSc(2UlJeDB3js)4sGie(In25WaZ2E7Ums0TDNi9JlQqcaVD(8QG1lSBSZHb3T92DzKOB7IuHDaknEqAfw8fBNpVky9c7g7CyM12E7Ums0T9QROGWkbjLkb2oFEvW6f2n2y7QewISQEST35WST3UlJeDB3vvfMlQOeGUTZNxfSEHDJDoUB7TZNxfSEHD7Ums0TDlNOeRlyisrZEyVDjjdMK(2jEQlm88fdxRbJ8EARpTrAz7QewISQEuaSeDAW2N9g78zTT3UlJeDBheSlc7TZNxfSEHDJDEJST3oFEvW6f2T7Yir32jiHOe2CPIogSDjjdMK(2jmgHb2EvWBxLWsKv1JcGLOtd2oUBSZN92E785vbRxy3UlJeDBhisjx8tx0PK3UKKbtsF7egJWaBVk4TRsyjYQ6rbWs0PbBh3n25Z82E785vbRxy3UlJeDB31e(CrECHabS3UKKbtsF7n4PW5P8mbLQQSEOIKkXbiBCzDrISuHcps0v0m8PKFAZMpfopvIqcnYWBinlfOGGUuwQchedneXJeDpTzZNs8uxy45lg5bpK4yIxf8GnsccWtn(2vjSezv9Oayj60GTdZgBS9kuk0B7DomB7TZNxfSEHD7ssgmj9TtGogdruWJipZLazKuwQcxZd(8QG1B3LrIUTdSt43yNJ72E7Ums0TDwAJYtrHWQK0Yp925ZRcwVWUXoFwB7TZNxfSEHD7Ums0TDatiEW6sfDCbOMkXBxsYGjPVD48unkgaMq8G1Lk64cqnvIhrkvkpfpTzZN6YiHNl8XwjdE60tH5Pg8uIN6cdpFXW1AWiVN26tXGeIcHL2orbxI0IFAZMpvA7efm4PT(uCFQbpflvyhfcB55bEkCF6S3U0SuWLWjk4aSZHzJDEJST3oFEvW6f2TljzWK03EfcdBGuvrKa6YW8as9Pg80g8u(yIcZpfUpTrM9tB28PHl4lgZeukvQOjUHd(8QG1p14B3LrIUTRMGajkaBuSXoF2B7TZNxfSEHD7ssgmj9TxHWWgivvejGUmmpGuFQbpTbpTcHHnuqy(akLhOyykvIjGbK6tB28PvimSHeDs2fSUufqNMjviayaP(uJVDxgj62UAccKOaSrXg78zEBVDxgj62oiVeemPacsQeVD(8QG1lSBSZBST925ZRcwVWUDjjdMK(2dxWxm0jjmxcskvcm4ZRcw)udEQezvrfvuEbyOzSuMXtBD6PW8uCEAfcdBujixdsnpGu3UlJeDBxbcsbVXgBheSlc7T9ohMT925ZRcwVWUDjjdMK(2LiRkQOIYlapT1PNkvlwUrkav(0B3LrIUTRtGQhs7n254UT3oFEvW6f2T7Yir32L2SRwa2Oy7ssgmj9ThUGVyOsyZf0vcBUyi7kn4ZRcw)udEkCEA4efCmsqPIaGTlnlfCjCIcoa7Cy2yNpRT92DzKOB7UvfcyVD(8QG1lSBSX2LAW2ENdZ2E785vbRxy3UKKbtsF7W5PGGDryZ6Hlep1GNcVtsVk4HBvHa2fj60zKO7Pg8ulhemP4aGda5viSLNh4PtpTLNAWtBWtHZtjqhJHik4HM9WwyUaSDnYqWGpVky9tB28PvimSHM9WwyUaSDnYqWqJm8EQbpvISQOIkkVa8u4(uCFQX3UlJeDBhE)sG9g7CC32B3LrIUTJjCfSq4rIUTZNxfSEHDJD(S22BNpVky9c72LKmys6BxZvimSbMWvWcHhj6ge2YZd8u4(uC3UlJeDBht4kyHWJeDfPG9dWBSZBKT925ZRcwVWUDjjdMK(2HZtRqyydxt4Zf5XfceWEaP(udEAdEkCEQeHeAKH3qPuiYtrbOsyEaP(0MnFkCEA4c(IHsPqKNIcqLW8GpVky9tn(2DzKOB7UMWNlYJleiG9g78zVT3oFEvW6f2TljzWK03EfcdBqqcrjS5sfDmyqylppWtH70tN1tB28PW7K0RcEqIAHWeKqSDxgj62objeLWMlv0XGn25Z82E785vbRxy3UlJeDB3YjkX6cgIu0Sh2BxsYGjPVDIN6cdpFXW1AWas9Pg80g80Wjk4yePfxcurN8tH7tLiRkQOIYladnJLYmEAZMpfopfeSlcBwpiifq8tn4PsKvfvur5fGHMXszgpT1PNkvlwUrkav(0p1OEkmp14BxAwk4s4efCa25WSXoVX22BNpVky9c72LKmys6BN4PUWWZxmCTgmY7PT(0z1YtnQNs8uxy45lgUwdgAiIhj6EQbpfopfeSlcBwpiifq8tn4PsKvfvur5fGHMXszgpT1PNkvlwUrkav(0p1OEkmB3LrIUTB5eLyDbdrkA2d7n25k7T925ZRcwVWUDjjdMK(2bQSqucNOGdWtBD6P4(udEkCEAfcdBufUMlycicX8asD7Ums0T9QW1CbtariM3yNRmTT3oFEvW6f2TljzWK03UezvrfvuEbyOzSuMXtBD6PW8uCEAfcdBujixdsnpGu3UlJeDBxHncecZfqqsL4n25W0Y2E785vbRxy3UKKbtsF7W7K0RcEufUMlycicXCby(Kp1GNYhtuyEePfxcuXYnYtB9P4UDxgj62UsPqKNIcqLW8g7CyGzBVD(8QG1lSBxsYGjPVD4Ds6vbpQcxZfmbeHyUamFYNAWt5JjkmpI0IlbQy5g5PT(uC3UlJeDBVkCnxiqa7n25WG72E785vbRxy3UKKbtsF7W5PGGDryZ6Hlep1GNkrwvurfLxaEkCNEkmB3LrIUTRjSRRcxZGn25WmRT925ZRcwVWUDjjdMK(2HZtbb7IWM1dxiEQbpfENKEvWd3QcbSls0PZir32DzKOB7aBxJm0If6n25W0iB7TZNxfSEHD7ssgmj9TdNNcc2fHnRhUqSDxgj62oGvbjyJDomZEBVD(8QG1lSBxsYGjPV9keg2OkqiTacedc7Y4PnB(uSuHDuiSLNh4PW9PZQLN2S5tRqyydxt4Zf5XfceWEaPUDxgj62Ukks0TXohMzEBVDxgj62EvGq6cgeX825ZRcwVWUXohMgBBVDxgj62ELjaMOuEk2oFEvW6f2n25WOS32B3LrIUTJLeUkqi925ZRcwVWUXohgLPT92DzKOB7(jzqqCrr6cX25ZRcwVWUXoh3w22BNpVky9c72LKmys6BVcHHnQceslGaXGWUmEAZMpflvyhfcB55bEkCNEkUT80MnFQezvrfvuEbyOzSuMXtH70tXD7Ums0TDiaxYGTaBSX2XYlb2B7DomB7T7Yir32RCyiZxjS5cBMbBNpVky9c7g7CC32BNpVky9c72LKmys6BVcHHnaIuYf)0fDk5bHT88apfUpflvyhfcB55bEQbpTcHHnaIuYf)0fDk5bHT88apfUpTbpfMNIZtLiRkQOIYlap14pDg9uygk7T7Yir32bIuYf)0fDk5n25ZABVDxgj62UobQEiT3oFEvW6f2n2yJT7qHnIS9EA1WBSXUa]] )

end