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


    spec:RegisterPack( "Outlaw", 20201205, [[d8KJQaqiPk9isv5sKQKQnrQ4tKsOrrkPtrkvRsrH6vaLzbv5wuLIDjLFbv1Wuu6yaPLbv6zKs00OkjxJQeBJQu6BKQunosvkNJucSosvsMhPuUNISpPkoOIIYcbQEivPYejvvDrffYgvueFKQKQojPQIvsLAMuLu5MkkQ2jq8tsvIHsvs5OkkqlLuvPNQWuLQ6QKsqBLuLu(QIcQXQOa2Rk)vIbJ0HPSyj9ysMmrxg1MHYNjfJwQCArRwrb51qfZMWTPQ2Ts)gYWPIJtvQA5iEoOPlCDaBxr13jvA8KQ48ujRxrrA(uf7xvFGE9VH0c(ab3zXDwqXDwV0af3z9wC173iC5W3WXu4yA4BSMpFd9cqimDVHJ5sGm51)gqearX3OlchOEf(4RjJoGAtH8XhM(acls0QigwGpm9v4FJkqkc9ZE1BiTGpqWDwCNfuCN1lnqXDwVf3BaDy1bcUE7S3OlLsEV6nKmuDd99u9cqimDFQ(fPbGF367P6pRy)ktEQxW7P4olUZEdhcclf8n03t1laHW09P6xKga(DRVNQ)SI9Rm5PEbVNI7S4o77(DRVNoJ0dRacw(0kJHi8tvi)QfpTYAYf2E6mtPyNa(0fTEtNr8Xaep1urIw4trRWv7DBQirlS5qyfYVAXK54iCvCqjeTVBtfjAHnhcRq(vlaBcFFJGdllyisrYw0HNdHvi)QffiRqReo5f8sSjILYcpN3OzsjSLBpE1SVBtfjAHnhcRq(vlaBcFyWMi6WlXM0AVS3dKooSS5Gu4WbmNPSSOq(oaHfjAlsEEQypE6vHqcjs3TPCPeOGG2uvQcdgnjaXIeTE8qSuw458gTCNdiwMyvb3y9KWaQ93TPIeTWMdHvi)QfGnHpbjeLOJlv0Yq8CiSc5xTOazfALWjCXlXMimgHHDwvWVBtfjAHnhcRq(vlaBcFOivCXwzrMkgphcRq(vlkqwHwjCcx8sSjcJryyNvf872urIwyZHWkKF1cWMW3KeEnrUCHaa7WZHWkKF1IcKvOvcNafVeBsR9YEpq64WYMdsHdhWCMYYIc57aewKOTi55PI94PxfcjKiD3MYLsGccAtvPkmy0Kaels06XdXszHNZB0YDoGyzIvfCJ1tcdO2F3VB990zKEyfqWYNYZzIRNgPp)0OJFQPce5Pj8P2ClfwvWT3TPIeTWjCsfoVB99u9ldd2er3ttSN6GGWSk4NQ1f905aILjwvWpLx2pz4tZ9PkKF1cT)UnvKOfc2e(WGnr09U13t1VmbjepfMRgb)uW7JVx)mh)(G)0kagg8P62X7tDqqywf872urIwiyt4p3iPvfmER5ZtKOwimbje4n3ea8ejQLkagguB4QJwRayyTkajzzjiSbbiCdWXJNkagwtdXwzXNfm3aC84PcGH1ccaxQSrYvtdWr7VBtfjAHGnH)CJKwvW4TMppz(vayxrHwzgjAXBUja4jfYVIkoOCdytYyPkJEMWfSkagwRsqMeMsUb4OdVmrJREM8YSVB990z4m6EQpGishb)0WiA4aI3tJUe(05gjTQGFAcFQQJv4WYNgONkzvk5NQBhhDm5PqKp)uVt)Hpf2HaeYNw5NcDTkw(uDZO7PGlmj)0zIaGqC9UnvKOfc2e(ZnsAvbJ3A(8uvysUGjaiexfORvH3CtaWtqhwikHr0WbSvfMKlycacXL2WvhILYcpN3OzsjSLBp4oRhpvamSwvysUGjaiexnaN3TPIeTqWMWxzcrXurI2IiHbER5ZtWGnr0HxInbd2erhlBMq8UnvKOfc2e(ktikMks0wejmWBnFEsjHVB990zsUjS7Pw8uFtpPpG)t9oVw7PdGkmiMkEkA5NIHipLnv3tbNGmjmL8tTv(u9IJdIeaBgUEQUD8(0zqGuHZt1FIP7tt4tHSGvblFQTYNoZX0)NMWNUO4Pe2KUEQHfm5Prh)0L1t8uiRqRS9UnvKOfc2e(eGTyQirBrKWaV185jSCtyhEj2Kc5xrfhuUbSNjLtX30tb6WR0B0AfadRvjitctj3aCaRcGH1qooisaSz4Qb4O9zSwdtWB08EGuHtrsmDB8Avbl1rR9gMG3O5BeCyzbdrks2IUgVwvWspEuiKqI0DB(gbhwwWqKIKTORryFlxypGQDT7XJc5xrfhuUbCY203uDgrdllkN3TPIeTqWMWxzcrXurI2IiHbER5ZtvGuiF3Mks0cbBcFJOSLlbIq4nWlXM4LjAC1KmwQYONjq9cy8YenUAewdVVBtfjAHGnHVru2YfhabKF3Mks0cbBcFrQPlGLziaPgFEJ3TPIeTqWMWVAAkiSsqsfoW397wFpfCGuizc8DBQirlSvbsHCc2LZXlXMialJHiA4wKRRsG0tQkvHj53TPIeTWwfifsWMWNvDOC1uiSdj9Tv(UnvKOf2QaPqc2e(qMqSGLLkA5c0jXHXt5sj4syenCaNafVeBQxjkAqMqSGLLkA5c0jXHBrQWjxnE8yQiNZfEz)KHtGQdXszHNZB0mPe2YThmaHOqyvNr0WLi9zpEuDgrdd7bxDWsnDrHW(wUqT5L3T(EQwiKFQxlHbs80rhkEQUz09u9IJdIeaBgUEAI90klq6(uVYlpLxMOXfEpfrEQUD8(uayUAE6miqQW5P6pX09DBQirlSvbsHeSj8DsyGefyhkWlXMQayynKJdIeaBgUAao6OvEzIgxAZR8IhpHj4nAEpqQWPijMUnETQGLA)DBQirlSvbsHeSj8DsyGefyhkWlXMQayynKJdIeaBgUAao6O1kagwtYMe2HIgGJhpvamSMgcZleNCHfDtfomb2aC84PcGH1uOvXMGLLQayLmPcaHnahT)UnvKOf2QaPqc2e(WCtyWKcmijo872urIwyRcKcjyt4RbbOHXlXMctWB0KjjCvcsQWb241QcwQJc5xrfhuUbSjzSuLrptGcwfadRvjitctj3aCE3VB99uVdHesKUl8DRVNQfcZvZtNz(vay3tt4tTNIRE9NMRIWgKX7Pq0t1RzBc7EQY2Nw5Ncr(CK(m8Pv(Paqw(ud(u7ParkYW1tHoSq8uGvWq4tbG5Q5PZCdgm5PZmi0GWCFkI8u9NTOt46PJotI0f(UnvKOf2us40CBtyhEj2uVWGnr0XYMje6m3iPvfCZ8RaWUIcTYms0QJVbdMumi0GWCle23YfonRovamSMKTOt4Qa7mjsxytI0DF3Mks0cBkjeSj8XeMgwiSir772urIwytjHGnHpMW0WcHfjAlkbBlKXlXMKCfadRHjmnSqyrI2gH9TCHAd33TPIeTWMscbBcFts41e5YfcaSdVeBQ3kagwZKeEnrUCHaa7Aao6O1EviKqI0DB4KcrUAkqhcZnahpE6nmbVrdNuiYvtb6qyUXRvfSu7VBtfjAHnLec2e(eKquIoUurldXlXMQayyncsikrhxQOLHnc7B5c12Kw6XZCJKwvWnsuleMGeI3T(EQ(b7PMucFQr4Nc4G3tHB6Wpn64NIw(P6Mr3tfiDzy80(91)2t1cH8t1TJ3NkDLRMNIzWGjpn6S9PENx7Psglvz8ue5P6MrhciEQTUEQ351AVBtfjAHnLec2e((gbhwwWqKIKTOdpLlLGlHr0WbCcu8sSjILYcpN3OzsjSb4OJwdJOHJwK(CjqfzYAtH8ROIdk3a2KmwQYWJNEHbBIOJLncsdaRJc5xrfhuUbSjzSuLrptkNIVPNc0HxP3aQ2F367P6hSNUONAsj8P6McXtLj)uDZOl3NgD8txwpXt1YzH49uai)0zoM()u0(0kccFQUz0HaINARRN6DET272urIwytjHGnHVVrWHLfmePizl6WlXMiwkl8CEJMjLWwU9OLZ6nelLfEoVrZKsytcqSirRo9cd2erhlBeKgawhfYVIkoOCdytYyPkJEMuofFtpfOdVsVb03T(Ek4ctYpDMiaiexpfTpfxWEkVSFYW3TPIeTWMscbBc)QWKCbtaqiUWlXMGoSqucJOHdypt4QtVvamSwvysUGjaiexnaN3TPIeTWMscbBcFnDiyiCvGbjXHXlXMui)kQ4GYnGnjJLQm6zcuWQayyTkbzsyk5gGZ72urIwytjHGnHpoPqKRMc0HWmEj20CJKwvWTQWKCbtaqiUkqxRshEzIgxTi95sGk(ME6b33TPIeTWMscbBc)QWKCHaa7WlXMMBK0QcUvfMKlycacXvb6Av6Wlt04QfPpxcuX30tp4(UnvKOf2usiyt4ljSjRctYq8sSPEHbBIOJLnti0rH8ROIdk3aQTjqF3Mks0cBkjeSj8HDMePRplK4Lyt9cd2erhlBMqOZCJKwvWnZVca7kk0kZir772urIwytjHGnHpKDGjeVeBQxyWMi6yzZeI3TPIeTWMscbBcFhuKOfVeBQcGH1QceskaGrJWMk84PcGH1mjHxtKlxiaWUgGZ72urIwytjHGnHFvGqYcgaX172urIwytjHGnHFLjqMGtUAE3Mks0cBkjeSj8XscxfiK8DBQirlSPKqWMW3wfddIjkktiE367P6pJzaI4PyMqunfopfdrEka0Qc(PzW(W272urIwytjHGnHpaKlzW(q8sSPkagwRkqiPaagncBQWJhSutxuiSVLluBt4oRhpkKFfvCq5gWMKXsvgABc3397wFpDMKBc7yc8DRVNcEmJEkAFQcHesKU7td0tXHzNNgD8t9osgpvYvamSNc48UnvKOf2WYnHDtvo0L5TeDCHDXW3TPIeTWgwUjSdSj8HIuXfBLfzQy8sSPkagwdksfxSvwKPIBe23YfQnSutxuiSVLluNkagwdksfxSvwKPIBe23YfQnTckykKFfvCq5gqTpJbTP3E3Mks0cBy5MWoWMWxMqhluDV73T(E6iyteDVBtfjAHnyWMi6MuDS5uGDOapLlLGlHr0WbCcu8sSPWe8gnhc7QG2s0XfDzdNgVwvWsD6nmIgoAjSurq472urIwydgSjIoWMW38RaWUBmNjWeThi4olUZckUZc6n01iBUAG3ygEMPFbr)aIxVE1tFA)o(PPVdIepfdrEQwScKcPw8Pe27bsclFke5Zp1acKVfS8PQoB1WW272Rlx(PGQx9uVdTZzsWYNQfjalJHiA42mGw8Pb6PArcWYyiIgUnd041QcwQfFQfpDgPx86EQwbvpAV9UF36hFhejy5t92NAQir7tfjmGT39nejmGx)Bizmdqex)deqV(3WurI2BGtQW5g8AvblpWV4ab3R)nmvKO9gWGnr0DdETQGLh4xCGOLx)BWRvfS8a)giNBa54gMks0EJ5gjTQGVXCtaW3Ge1sfadd(uT9uCFQopvRpTcGH1QaKKLLGWgeGWnaNN6XZtRayynneBLfFwWCdW5PE880kagwliaCPYgjxnnaNNQ9Bm3iL185BqIAHWeKqCXbIxD9VbVwvWYd8BGCUbKJByQir7nMBK0Qc(gZnbaFdfYVIkoOCdytYyPkJN2Z0tX9PG90kagwRsqMeMsUb48uDEkVmrJRN2Z0t9YS3yUrkR5Z3W8RaWUIcTYms0EXbIxU(3GxRky5b(nqo3aYXnmvKO9gZnsAvbFJ5MaGVb0HfIsyenCaBvHj5cMaGqC9uT9uCFQopLyPSWZ5nAMucB5(0EEkUZ(upEEAfadRvfMKlycacXvdW5gZnsznF(gvHj5cMaGqCvGUw1fhiE71)g8AvblpWVHIKbts7gWGnr0XYMje3WurI2BOmHOyQirBrKW4gIegL185Bad2er3fhi69R)n41QcwEGFdtfjAVHYeIIPIeTfrcJBisyuwZNVHscV4arVD9VbVwvWYd8BOizWK0UHc5xrfhuUb8P9m9uLtX30tb6WR8PEZt16tRayyTkbzsyk5gGZtb7PvamSgYXbrcGndxnaNNQ9NoJFQwFAycEJM3dKkCksIPBJxRky5t15PA9P9(0We8gnFJGdllyisrYw0141Qcw(upEEQcHesKUBZ3i4WYcgIuKSfDnc7B5cFAppf0NQ9NQ9N6XZtvi)kQ4GYnGpD6P2M(MQZiAyzr5CdtfjAVbbylMks0wejmUHiHrznF(gy5MWUloq0cU(3GxRky5b(nmvKO9gktikMks0wejmUHiHrznF(gvGuiV4ab0zV(3GxRky5b(nuKmysA3GxMOXvtYyPkJN2Z0tb1lpfSNYlt04Qryn8EdtfjAVHru2YLari8gxCGakOx)ByQir7nmIYwU4aiG8n41QcwEGFXbcO4E9VHPIeT3qKA6cyzgcqQXN34g8AvblpWV4abuT86FdtfjAVr10uqyLGKkCG3GxRky5b(fxCdhcRq(vlU(hiGE9VHPIeT3WCCeUkoOeI2BWRvfS8a)IdeCV(3GxRky5b(nmvKO9g(gbhwwWqKIKTO7gksgmjTBqSuw458gntkHTCFApp1RM9goewH8RwuGScTs4n8YfhiA51)g8AvblpWVHIKbts7gA9P9(u27bshhw2CqkC4aMZuwwuiFhGWIeTfjppv8t945P9(ufcjKiD3MYLsGccAtvPkmy0Kaels0(upEEkXszHNZB0YDoGyzIvfCJ1tcd4t1(nmvKO9gWGnr0DXbIxD9VbVwvWYd8ByQir7niiHOeDCPIwgEdfjdMK2nimgHHDwvW3WHWkKF1IcKvOvcVbUxCG4LR)n41QcwEGFdtfjAVbuKkUyRSitfFdfjdMK2nimgHHDwvW3WHWkKF1IcKvOvcVbUxCG4Tx)BWRvfS8a)gMks0Edts41e5YfcaS7gksgmjTBO1N27tzVhiDCyzZbPWHdyotzzrH8Dacls0wK88uXp1JNN27tviKqI0DBkxkbkiOnvLQWGrtcqSir7t945PelLfEoVrl35aILjwvWnwpjmGpv73WHWkKF1IcKvOvcVbOxCXnQaPqE9pqa96FdETQGLh43qrYGjPDdcWYyiIgUf56Qei9KQsvysUXRvfS8gMks0Edyxo)IdeCV(3WurI2BWQouUAke2HK(2kVbVwvWYd8loq0YR)n41QcwEGFdtfjAVbKjelyzPIwUaDsC4BOizWK0UrVpvIIgKjelyzPIwUaDsC4wKkCYvZt945PMkY5CHx2pz4tNEkOpvNNsSuw458gntkHTCFAppfdqikew1zenCjsF(PE88uvNr0WWN2ZtX9P68uSutxuiSVLl8PA7PE5gkxkbxcJOHd4bcOxCG4vx)BWRvfS8a)gksgmjTBubWWAihheja2mC1aCEQopvRpLxMOX1t12t9kV8upEEAycEJM3dKkCksIPBJxRky5t1(nmvKO9gojmqIcSdfxCG4LR)n41QcwEGFdfjdMK2nQayynKJdIeaBgUAaopvNNQ1NwbWWAs2KWou0aCEQhppTcGH10qyEH4KlSOBQWHjWgGZt945PvamSMcTk2eSSufaRKjvaiSb48uTFdtfjAVHtcdKOa7qXfhiE71)gMks0EdyUjmysbgKeh(g8AvblpWV4arVF9VbVwvWYd8BOizWK0UrycEJMmjHRsqsfoWgVwvWYNQZtvi)kQ4GYnGnjJLQmEAptpf0Nc2tRayyTkbzsyk5gGZnmvKO9gAqaA4lU4gWGnr0D9pqa96FdETQGLh43WurI2BO6yZPa7qXnuKmysA3imbVrZHWUkOTeDCrx2WPXRvfS8P680EFAyenC0syPIGWBOCPeCjmIgoGhiGEXbcUx)ByQir7nm)kaS7g8AvblpWV4IBOKWR)bcOx)BWRvfS8a)gksgmjTB07tHbBIOJLntiEQopDUrsRk4M5xbGDffALzKO9P68uFdgmPyqObH5wiSVLl8PtpD2NQZtRayynjBrNWvb2zsKUWMeP7EdtfjAVXCBty3fhi4E9VHPIeT3atyAyHWIeT3GxRky5b(fhiA51)g8AvblpWVHIKbts7gsUcGH1WeMgwiSirBJW(wUWNQTNI7nmvKO9gyctdlewKOTOeSTq(IdeV66FdETQGLh43qrYGjPDJEFAfadRzscVMixUqaGDnaNNQZt16t79Pkesir6UnCsHixnfOdH5gGZt945P9(0We8gnCsHixnfOdH5gVwvWYNQ9ByQir7nmjHxtKlxiaWUloq8Y1)g8AvblpWVHIKbts7gvamSgbjeLOJlv0YWgH9TCHpvBtpvlFQhppDUrsRk4gjQfctqcXnmvKO9geKquIoUurldV4aXBV(3GxRky5b(nmvKO9g(gbhwwWqKIKTO7gksgmjTBqSuw458gntkHnaNNQZt16tdJOHJwK(CjqfzYpvBpvH8ROIdk3a2KmwQY4PE880EFkmyteDSSrqAa4NQZtvi)kQ4GYnGnjJLQmEAptpv5u8n9uGo8kFQ38uqFQ2VHYLsWLWiA4aEGa6fhi69R)n41QcwEGFdfjdMK2niwkl8CEJMjLWwUpTNNQLZ(uV5PelLfEoVrZKsytcqSir7t15P9(uyWMi6yzJG0aWpvNNQq(vuXbLBaBsglvz80EMEQYP4B6PaD4v(uV5PGEdtfjAVHVrWHLfmePizl6U4arVD9VbVwvWYd8BOizWK0Ub0HfIsyenCaFAptpf3NQZt79PvamSwvysUGjaiexnaNByQir7nQctYfmbaH46IdeTGR)n41QcwEGFdfjdMK2nui)kQ4GYnGnjJLQmEAptpf0Nc2tRayyTkbzsyk5gGZnmvKO9gA6qWq4QadsIdFXbcOZE9VbVwvWYd8BOizWK0UXCJKwvWTQWKCbtaqiUkqxR6P68uEzIgxTi95sGk(MEEAppf3ByQir7nWjfIC1uGoeMV4abuqV(3GxRky5b(nuKmysA3yUrsRk4wvysUGjaiexfORv9uDEkVmrJRwK(CjqfFtppTNNI7nmvKO9gvHj5cba2DXbcO4E9VbVwvWYd8BOizWK0UrVpfgSjIow2mH4P68ufYVIkoOCd4t120tb9gMks0EdjHnzvysgEXbcOA51)g8AvblpWVHIKbts7g9(uyWMi6yzZeINQZtNBK0QcUz(vayxrHwzgjAVHPIeT3a2zsKU(SqEXbcOE11)g8AvblpWVHIKbts7g9(uyWMi6yzZeIByQir7nGSdmHxCGaQxU(3GxRky5b(nuKmysA3OcGH1QceskaGrJWMkEQhppTcGH1mjHxtKlxiaWUgGZnmvKO9goOir7fhiG6Tx)ByQir7nQceswWaiUUbVwvWYd8loqavVF9VHPIeT3OYeitWjxn3GxRky5b(fhiGQ3U(3WurI2BGLeUkqi5n41QcwEGFXbcOAbx)ByQir7nSvXWGyIIYeIBWRvfS8a)IdeCN96FdETQGLh43qrYGjPDJkagwRkqiPaagncBQ4PE88uSutxuiSVLl8PAB6P4o7t945PkKFfvCq5gWMKXsvgpvBtpf3ByQir7naGCjd2hEXf3al3e2D9pqa96FdtfjAVrLdDzElrhxyxm8g8AvblpWV4ab3R)n41QcwEGFdfjdMK2nQayynOivCXwzrMkUryFlx4t12tXsnDrHW(wUWNQZtRayynOivCXwzrMkUryFlx4t12t16tb9PG9ufYVIkoOCd4t1(tNXpf0ME7gMks0EdOivCXwzrMk(IdeT86FdtfjAVHmHowO6UbVwvWYd8lU4IByarhICJr67DxCXDa]] )

end