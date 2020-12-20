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
                return not settings.solo_vanish and not ( boss and group ), "can only vanish in a boss encounter or with a group"
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

        potion = "phantom_fire",

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

    spec:RegisterSetting( "solo_vanish", true, {
        name = "Allow |T132331:0|t Vanish when Solo",
        desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Outlaw", 20201220, [[d4KAQaqiGQEeLIUKsbrBIi8jPKmkIcNcQuRsPGYRGQmlIs3IsH2Ls(fuvdtPOJreTmOINrPutJsjUMusTnkL03ukunoLcLZburRdQenpIQCpLQ9jL4GqLKfcuEirrMOsbUiLcAJkfIpQuiDsGkzLuWmbQq3eQKQDQu6NefvdLsboQsbvlfOs9uPAQsPUkujLTQuq4RavWyjkk7vv)vKbd5WclwupMutMKlJAZq5Zaz0uYPLSALcsVMi1SjCBPy3Q8BedNIooujSCKEoOPt11bSDIKVtuz8ev15PqZNs1(v8l53(7QW5FloBIZMsIdoBU2eCAl2QTbNF3nAYF3m0shG4VFrd)DzoGlc5(Uzyuqc13(7qcavZF3YDtiUeF8bvUfqEPjn4dRgar4f500aZXhwnA8)EgOeo46(83vHZ)wC2eNnLehC2CTj40wSvBBRFhAY6Flo26MF3Quk((83vmu)DBoizoGlc5ge4MacGhd2CqBaR5MmthKKGtzheoBIZMF3KsWkb)DBoizoGlc5ge4MacGhd2CqBaR5MmthKKGtzheoBIZMJHXGnhKnu(SgWz1GYmgHYdstAYHpOmdQo4Aq4kTMnD4GoYzJwbTbdqmOq7f5GdICcJRXqO9ICWLjL1KMC47HPPWyYKuqYngcTxKdUmPSM0KdhVD8Ze3fSkHjcJSsU6aLCI8RBmeAVihCzsznPjhoE743euPzvcJqtkoClznPSM0Kdpbzn5uW9wlBHTtJsLyP4ZxHsbx11coTEmeAVihCzsznPjhoE74tjcrYT4uMCmuwtkRjn5WtqwtofChhzlSDkJrzOvKf8yi0Ero4YKYAstoC82XhkknNItLuLML1KYAsto8eK1Ktb3Xr2cBNYyugAfzbpgcTxKdUmPSM0KdhVD8Hohc3AmmgS5GSHYN1aoRgelftnoiVA4b5w8GcTtOdQGdkKkkrKf8AmeAVihCx6sl9yWMdcCZqNdHBnOcBqMeiSYcEqY4idskaXX0il4bXh3umCq1ninPjhoUhdH2lYbXBhFOZHWTgd2CqGBMseIbbRdKGheyTXFJIRJFBWgugaddoi5S4BqMeiSYcEmeAViheVD8LkOvKfSSx0W7upNOmLieYkvia4DQNtzammO8WrczKbWWwzaAXQKt5acq5fGPD7zamSfiACQudlyEbyA3EgadB5uaoL5GwhOfGjUhd2Cq2Wdcq5bjhpiqSpimaHyq4QMma0AqYKnyqGI6Gdko1GckFTYheLPeHOoqdsMiaNpi3IhKmxPGdkdGHbhuixyCmeAViheVD8LkOvKfSSx0W7rtgaAL0KtvErozLkea8UM0KjjtsDoCPySsxEl74GxgadBLPKqblfVamLGpMcYyl7TEtjKb41Ktbu(staop5wCIOuq72ZayylkrisUfNYKJHlk3e1bBzxYnX9yWMdcCOCRb1ai8YuWdYdki2HYoi3QGdsQGwrwWdQGdsBXAPz1GCYGuSUu8GKZIDlMoiiPHhKmTbWbbTiac1GY8GGgpnRgKCLBniWeHIh0graqPghdH2lYbXBhFPcAfzbl7fn8EwekoHjaOuJjOXtlRuHaG3HMSqK8GcID4klcfNWeauQr5HJe0Oujwk(8vOuWvDTGZM2TNbWWwzrO4eMaGsnUamhdH2lYbXBhFkWLcTxKljkOl7fn8o05q4wYwy7qNdHBXQvieJHq7f5G4TJVoeIuO9ICjrbDzVOH31k4yWMdAJuxbTgu4dQjKF1a0mizYgmOmGpOqksPgKCb0Rd0GaJscfSu8GItnOnCGsl9G2aAi3GYKdaoinPjtgKjPohogcTxKdI3o(uGlfAVixsuqx2lA4DS6kOLSf2UM0KjjtsDoSLDTzQjKFcAYNYgZayyRmLekyP4fGPnkJmag2IyAsOoWvUXfG5gMhc(8fUaO0sNu0qUfFrwWkCB3UM0KjjtsDoCpUQj0wbfeRsAZXqO9ICq82Xxhcrk0ErUKOGUSx0W7zGsOgdH2lYbXBh)GQJJtoHs5ZLTW25JPGmUumwPlVLDjBnE8XuqgxugeFJHq7f5G4TJFq1XXjtabKhdH2lYbXBhFrbYYHPnuafOg(8XqO9ICq82XphGseSKtlT0WXWyWMdcmGsOykCmeAVihCLbkHAhYMWcogcTxKdUYaLqH3o(GSiqxymbDAjnpgcTxKdUYaLqH3o(qRskzlSDkWXyekiE51zm5e5x6uwekEmeAVihCLbkHcVD8zTfPoqjkBsRM4uJHq7f5GRmqju4TJpKP0WzvktoobnlPzz1g1co5bfe7WDjLTW2bVI4litPHZQuMCCcAwsZlV0sxhi72dTxsXj(4MIH7skbnkvILIpFfkfCvxlyacrIYARGcItE1W2TRTckig2cosGvGS8eLBI6GYR1JbBoiCnipiBqbDIyqDlIpi5k3AqYCttc1bUYnoOcBqzwqKBq2sRheFmfKrzheHoi5S4BqaW6anOnCGsl9G2aAi3yi0Ero4kducfE74BwqNisqlIlBHTNbWWwettc1bUYnUamLqg8XuqgLNT0A729qWNVWfaLw6KIgYT4lYcwH7XqO9ICWvgOek82X3SGorKGwex2cBpdGHTiMMeQdCLBCbykHmYayylquMpO01btYvAPzkCbyA3EgadBPjNMdbRszbWPyAgacxaM4EmeAVihCLbkHcVD8H1vqNPjOtlP5XqO9ICWvgOek82XhebaelBHT7HGpFPkQBm50slnCXxKfSscnPjtsMK6C4sXyLU8w2LeVmag2ktjHcwkEbyoggd2CqYeHiue5o4yWMdcxdwhObHRAYaqRbvWbfdcNnKdQonLdil7GGKbTHiUcAniDCdkZdcsAyVAy4GY8GaGSAqbCqXGa8suUXbbnzHyqaNGHWbbaRd0GW1dOZ0bHRGWacRBqe6G2aoClHXb1Tcfro4yi0Ero4sRG7sfxbTKTW2bp05q4wSAfcHesf0kYcEfnzaOvstov5f5KOjGottbegqyDjk3e1b33uczaEkWXyekiEP4WTegtqRqrKdA3EgadBP4WTegtqRqrKdUue5oj0KMmjzsQZHYBhhCpgcTxKdU0kiE74JjcqSqeErUXqO9ICWLwbXBhFmraIfIWlYL0cooilBHTR4mag2cteGyHi8IClk3e1bLhoJHq7f5GlTcI3o(HIYxiQJtuaOLSf2o4ZayyRqr5le1Xjka0AbykHmaVMqekIC3s6siQducAszEbyA3o49qWNVKUeI6aLGMuMx8fzbRW9yi0Ero4sRG4TJpLiej3ItzYXqzlS9mag2IseIKBXPm5y4IYnrDq5TBB72LkOvKf8I65eLPeHymyZbbUWguOuWbfuEqaMYoi4vM8GClEqKJhKCLBnibrog6dQD7nyniCnipi5S4BqkJ1bAqyb0z6GCR4gKmzdgKIXkD5dIqhKCLBra8bfNXbjt2G1yi0Ero4sRG4TJFtqLMvjmcnP4WTKvBul4KhuqSd3Lu2cBNgLkXsXNVcLcUamLqgEqbX(YRgo5KKQy5PjnzsYKuNdxkgR0LB3o4Hohc3IvlkbealHM0KjjtsDoCPySsxEl7AZuti)e0KpLnkjUhd2CqGlSbDKbfkfCqYvcXGufpi5k3QUb5w8Gow((GS9MqzheaKheUo2gmiYnOmbchKCLBra8bfNXbjt2G1yi0Ero4sRG4TJFtqLMvjmcnP4WTKTW2PrPsSu85RqPGR6AX2BAJ0Oujwk(8vOuWLcGgErojap05q4wSArjGayj0KMmjzsQZHlfJv6YBzxBMAc5NGM8PSrjhd2CqGjcfpOnIaGsnoiYniCWBq8XnfdhdH2lYbxAfeVD8ZIqXjmbaLAu2cBhAYcrYdki2HTSJJeGpdGHTYIqXjmbaLACbyogcTxKdU0kiE74lDje1bkbnPmlBHTlvqRil4vwekoHjaOuJjOXtlHm4JPGmU8QHtoj1eYVfCSBhAYcrYdki2HTGdUhdH2lYbxAfeVD8ZIqXjka0s2cBxQGwrwWRSiuCctaqPgtqJNwczWhtbzC5vdNCsQjKFl4y3o0KfIKhuqSdBbhCpgcTxKdU0kiE74ROCOYIqXqzlSDWdDoeUfRwHqiHM0KjjtsDouE7sogcTxKdU0kiE74dTcfrUgwOKTW2bp05q4wSAfcHesf0kYcEfnzaOvstov5f5gdH2lYbxAfeVD8njErozlS9mag2klieLaa6lkhA3UDScKLNOCtuhuE2Et72ZayyRqr5le1Xjka0AbyogcTxKdU0kiE74NfeIkHbqnogcTxKdU0kiE74NzkKPsxhOXqO9ICWLwbXBhFSIYzbHOgdH2lYbxAfeVD8JtZqNgIKoeIXGnh0gWybGWhewie5ql9GWi0bbaJSGhu5CdCngcTxKdU0kiE74da5u5Cdu2cBxXzamSvMD5y(sUfNyJmCbykHmaVhc(8filc0fgtqNwsZl(ISGv2TR4mag2cKfb6cJjOtlP5fGjUTBhRaz5jk3e1bL3ooBoggd2CqBK6kOftHJbBoiWCB4Gi3G0eIqrK7gKtgK0mBoi3IhKmrlFqkodGHniaZXqO9ICWfwDf0ApZUCmFj3ItSrgogcTxKdUWQRGw4TJpuuAofNkPknlBHTNbWWwqrP5uCQKQ08IYnrDq5HvGS8eLBI6GsqzmkdTISGhdH2lYbxy1vql82XxvqZW1wJHXGnhu35q4wJHq7f5GlOZHWT2vf0mCTLSf2UM0KjjtsDoSLDTzQjKFcAYNAmeAVihCbDoeUfE74hnzaO1yi0Ero4c6CiCl82XxBXHzcArCz1g1co5bfe7WDjLTW29qWNVmPSXe5sUfNKJdPx8fzbRKa8EqbX(QGPmbc)UumfwK73IZM4SPK4iPT)UCb9Qde87Gd4kW9wW12nkUCqdQTfpOQXKq9bHrOdQvkglaeERgeLXfafLvdcsA4bfaoPjCwniTvCGy4AmaowhpiBbxoizICsXuNvdQvAYPakFjZA1GCYGALMCkGYxYSfFrwWQwniziP8X9AmmgahWvG7TGRTBuC5GguBlEqvJjH6dcJqhuR0kyRgeLXfafLvdcsA4bfaoPjCwniTvCGy4AmaowhpijXLdsMiNum1z1GAff4ymcfeVKzTAqozqTIcCmgHcIxYSfFrwWQwniziP8X9AmmgahWvG7TGRTBuC5GguBlEqvJjH6dcJqhuRYaLq1QbrzCbqrz1GGKgEqbGtAcNvdsBfhigUgdGJ1XdY24YbjtKtkM6SAqTIcCmgHcIxYSwniNmOwrbogJqbXlz2IVilyvRgu4dYgkZbhhKmKu(4EnggdGRgtc1z1GS1bfAVi3Gef0HRXW3ff0HF7VRySaq4F7FRKF7VhAVi33LU0s)D(ISGvpyV)BX5B)9q7f5(o05q4wFNVily1d27)wB)T)oFrwWQhSVtm)oK9VhAVi33LkOvKf83Lkea83PEoLbWWGdsEdcNbjXGKXGYayyRmaTyvYPCabO8cWCq2TpOmag2cenovQHfmVamhKD7dkdGHTCkaNYCqRd0cWCq4(7sf00fn83PEorzkriE)3AlF7VZxKfS6b77eZVdz)7H2lY9DPcAfzb)DPcba)DnPjtsMK6C4sXyLU8b1Y(GWzq4nOmag2ktjHcwkEbyoijgeFmfKXb1Y(GA9MdsIbjJbb(bPjNcO8LMaCEYT4erPGl(ISGvdYU9bLbWWwuIqKCloLjhdxuUjQdoOw2hKKBoiC)DPcA6Ig(7rtgaAL0KtvErU3)TT(B)D(ISGvpyFNy(Di7Fp0ErUVlvqRil4Vlvia4VdnzHi5bfe7WvwekoHjaOuJdsEdcNbjXGOrPsSu85RqPGR6guldcNnhKD7dkdGHTYIqXjmbaLACby(DPcA6Ig(7zrO4eMaGsnMGgp97)wB9B)D(ISGvpyFxtlNPv8DOZHWTy1keIVhAVi33Paxk0ErUKOG(3ff0tx0WFh6CiCR3)TB8V935lYcw9G99q7f5(UoeIuO9ICjrb9VlkONUOH)UwbF)3UX(2FNVily1d2310YzAfFxtAYKKjPohoOw2hK2m1eYpbn5tniBCqzamSvMscfSu8cWCq24GKXGYayylIPjH6ax5gxaMdAdBqEi4Zx4cGslDsrd5w8fzbRgeUhKD7dstAYKKjPohoO9bfx1eARGcIvjT53dTxK77uGlfAVixsuq)7Ic6PlA4VJvxbTE)3co)2FNVily1d23dTxK776qisH2lYLef0)UOGE6Ig(7zGsOE)3k5MF7VZxKfS6b77AA5mTIVZhtbzCPySsx(GAzFqs26bH3G4JPGmUOmi((EO9ICFpO644KtOu(83)Tsk53(7H2lY99GQJJtMaci)D(ISGvpyV)BLeNV93dTxK77IcKLdtBOakqn85FNVily1d27)wjT93(7H2lY99CakrWsoT0sd)oFrwWQhS3F)7MuwtAYH)T)Ts(T)EO9ICFpmnfgtMKcsUVZxKfS6b79FloF7VhAVi33Ze3fSkHjcJSsU6aLCI8R778fzbREWE)3A7V935lYcw9G99q7f5(EtqLMvjmcnP4WT(UMwotR470Oujwk(8vOuWvDdQLbHtR)UjL1KMC4jiRjNc(9w)(V1w(2FNVily1d23dTxK77uIqKCloLjhd)UMwotR47ugJYqRil4VBsznPjhEcYAYPGFhN3)TT(B)D(ISGvpyFp0ErUVdfLMtXPsQsZFxtlNPv8DkJrzOvKf83nPSM0Kdpbzn5uWVJZ7)wB9B)9q7f5(o05q4wFNVily1d27V)9mqjuF7FRKF7VhAVi33HSjSGFNVily1d27)wC(2Fp0ErUVdYIaDHXe0PL0835lYcw9G9(V12F7VZxKfS6b77AA5mTIVtbogJqbXlVoJjNi)sNYIqXl(ISGvFp0ErUVdTkPE)3AlF7VhAVi33zTfPoqjkBsRM4uFNVily1d27)2w)T)oFrwWQhSVhAVi33HmLgoRszYXjOzjn)DnTCMwX3b)GueFbzknCwLYKJtqZsAE5Lw66ani72huO9skoXh3umCq7dsYbjXGOrPsSu85RqPGR6guldcdqisuwBfuqCYRgEq2TpiTvqbXWb1YGWzqsmiScKLNOCtuhCqYBqT(7AJAbN8GcID4VvY3)T263(78fzbREW(UMwotR47zamSfX0KqDGRCJlaZbjXGKXG4JPGmoi5niBP1dYU9b5HGpFHlakT0jfnKBXxKfSAq4(7H2lY9DZc6ercAr83)TB8V935lYcw9G9DnTCMwX3ZayylIPjH6ax5gxaMdsIbjJbLbWWwGOmFqPRdMKR0sZu4cWCq2TpOmag2stonhcwLYcGtX0maeUamheU)EO9ICF3SGorKGwe)9F7g7B)9q7f5(oSUc6mnbDAjn)D(ISGvpyV)BbNF7VZxKfS6b77AA5mTIV7HGpFPkQBm50slnCXxKfSAqsminPjtsMK6C4sXyLU8b1Y(GKCq4nOmag2ktjHcwkEby(9q7f5(oicai(93)o05q4wF7FRKF7VZxKfS6b77AA5mTIVRjnzsYKuNdhul7dsBMAc5NGM8P(EO9ICFxvqZW1wV)BX5B)9q7f5(E0KbGwFNVily1d27)wB)T)oFrwWQhSVhAVi331wCyMGwe)7AA5mTIV7HGpFzszJjYLClojhhsV4lYcwnijge4hKhuqSVkyktGWVRnQfCYdki2H)wjF)9VRvWV9VvYV935lYcw9G9DnTCMwX3b)GGohc3IvRqigKedsQGwrwWROjdaTsAYPkVi3GKyqnb0zAkGWacRlr5MOo4G2h0MdsIbjJbb(brbogJqbXlfhULWycAfkICWfFrwWQbz3(GYayylfhULWycAfkICWLIi3nijgKM0KjjtsDoCqYBFq4miC)9q7f5(UuXvqR3)T48T)EO9ICFhteGyHi8ICFNVily1d27)wB)T)oFrwWQhSVRPLZ0k(UIZayylmraIfIWlYTOCtuhCqYBq489q7f5(oMiaXcr4f5sAbhhKF)3AlF7VZxKfS6b77AA5mTIVd(bLbWWwHIYxiQJtuaO1cWCqsmizmiWpinHiue5UL0LquhOe0KY8cWCq2TpiWpipe85lPlHOoqjOjL5fFrwWQbH7VhAVi33dfLVquhNOaqR3)TT(B)D(ISGvpyFxtlNPv89mag2IseIKBXPm5y4IYnrDWbjV9bz7bz3(GKkOvKf8I65eLPeH47H2lY9DkrisUfNYKJHV)BT1V935lYcw9G99q7f5(EtqLMvjmcnP4WT(UMwotR470Oujwk(8vOuWfG5GKyqYyqEqbX(YRgo5KKQ4bjVbPjnzsYKuNdxkgR0Lpi72he4he05q4wSArjGa4bjXG0KMmjzsQZHlfJv6Yhul7dsBMAc5NGM8PgKnoijheU)U2OwWjpOGyh(BL89F7g)B)D(ISGvpyFxtlNPv8DAuQelfF(kuk4QUb1YGS9MdYghenkvILIpFfkfCPaOHxKBqsmiWpiOZHWTy1IsabWdsIbPjnzsYKuNdxkgR0LpOw2hK2m1eYpbn5tniBCqs(9q7f5(EtqLMvjmcnP4WTE)3UX(2FNVily1d2310YzAfFhAYcrYdki2HdQL9bHZGKyqGFqzamSvwekoHjaOuJlaZVhAVi33ZIqXjmbaLA89Fl48B)D(ISGvpyFxtlNPv8DPcAfzbVYIqXjmbaLAmbnE6bjXGKXG4JPGmU8QHtoj1eYFqTmiCgKD7dcAYcrYdki2HdQLbHZGW93dTxK77sxcrDGsqtkZV)BLCZV935lYcw9G9DnTCMwX3LkOvKf8klcfNWeauQXe04PhKedsgdIpMcY4YRgo5Kuti)b1YGWzq2TpiOjlejpOGyhoOwgeodc3Fp0ErUVNfHItuaO17)wjL8B)D(ISGvpyFxtlNPv8DWpiOZHWTy1keIbjXG0KMmjzsQZHdsE7dsYVhAVi33vuouzrOy47)wjX5B)D(ISGvpyFxtlNPv8DWpiOZHWTy1keIbjXGKkOvKf8kAYaqRKMCQYlY99q7f5(o0kue5AyH69FRK2(B)D(ISGvpyFxtlNPv89mag2klieLaa6lkhAFq2TpiScKLNOCtuhCqYBq2EZbz3(GYayyRqr5le1Xjka0Aby(9q7f5(UjXlY9(VvsB5B)9q7f5(EwqiQega1435lYcw9G9(VvYw)T)EO9ICFpZuitLUoqFNVily1d27)wjT1V93dTxK77yfLZccr9D(ISGvpyV)BLCJ)T)EO9ICFpondDAis6qi(oFrwWQhS3)TsUX(2FNVily1d2310YzAfFxXzamSvMD5y(sUfNyJmCbyoijgKmge4hKhc(8filc0fgtqNwsZl(ISGvdYU9bP4mag2cKfb6cJjOtlP5fG5GW9GSBFqyfilpr5MOo4GK3(GWzZVhAVi33bGCQCUb((7FhRUcA9T)Ts(T)EO9ICFpZUCmFj3ItSrg(D(ISGvpyV)BX5B)D(ISGvpyFxtlNPv89mag2ckknNItLuLMxuUjQdoi5niScKLNOCtuhCqsmikJrzOvKf83dTxK77qrP5uCQKQ087)wB)T)EO9ICFxvqZW1wFNVily1d27V)(3da3Iq)EVAKP3F)Fa]] )

end