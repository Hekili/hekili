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


    spec:RegisterPack( "Outlaw", 20201213, [[d4KOQaqiOkEefIlrHkYMis9jPinkIQ6uuiTkGk4vaLzrKClIQyxk8lIWWuu6yaXYGQ6zuOmnIQ01KIyBavY3OqvnokuLZPOOADqvkZdOQ7Pi7tkQdcvjTqG0djkyIkk4IuOsBurr8rffLtcvjwjfmtffPBcuH2PIQFsuidfQs1rvuiwkqf9uPAQsjxLcvyRuOI6RkkuJLOqTxv9xjgmIdt1IL0Jj1Kj5YO2mu(muz0uYPfTAffsVMO0SjCBk1Uv53qgofDCGk1Yr65GMUW1bSDIOVtuz8efDEPW8LsTFL(b5B9DLh8ph)zXFwqWheJnaXyG0e8n(FpAyYF301Y644VFUn)DzeqiC5(UP3qGC1367qeavZF3kctiEtcjWLHfqDOr2satBaHhj60uhlKaM2Aj(EfifbE5(63vEW)C8Nf)zbbFqm2aeJbstWVjFhAY6Fo(GRz)UvQu891VRyO(7gzjYiGq4YTeWjchaVgmYsMbwZ2vMUeqmMulb)zXF2VBsryPG)UrwImcieUClbCIWbWRbJSKzG1SDLPlbeJj1sWFw8NDnSgmYsmUYK1abRwsLXquEjAKD1JLuzC5bhlbVQ1SzaxYHo5XYP2yaIL46irhCjOt0ySgCDKOdomPSgzx9yYnnfnkMOeIU1GRJeDWHjL1i7QhGnjrffHGvfmH3GvYLhUsGKzERbxhj6GdtkRr2vpaBscBNklRkyiArXEyjLjL1i7QhfiRrNco1ePsSjQNQcljFXWvk4iVML3zxdUos0bhMuwJSREa2KeuKquclUurhdLYKYAKD1JcK1OtbNWxQeBIYyugA5vbVgCDKOdomPSgzx9aSjjGIuZf)ufvQzPmPSgzx9Oazn6uWj8LkXMOmgLHwEvWRbxhj6GdtkRr2vpaBscyWUiSwdRbJSeJRmznqWQLWsY0gljsBEjHfVexhi6ss4sCj9u4vbpwdUos0bNKn1YUgmYsaNmmyxewljXwIjccZQGxI8p0sKeqCm1RcEj8X2jdxsElrJSREy01GRJeDqWMKagSlcR1Grwc4KPiHyjW8Wj4LaAljMzGJs0c0LubWWGlrol(wIjccZQGxdUos0bbBscjDA6vbl1528enQfktrcHus6caEIg1sfaddcE8Lw(vamSrfGMSQeu2HauEay2UDfadBGJ6NQyZcMhaMTBxbWWgbfGlv2P5HBayA01GrwIX9GauEjYXlbhhlbdqiwcE1UcaTwImG3xcopp4s8tTeNYxtJLqzksiYd3sKbeWfljS4LiJuk4sQayyWL4Y5nwdUos0bbBscjDA6vbl1528KBxbGwfn6uzKOtkjDbapPr2vuXeLxahkgl1z08e(GvbWWgvkYvWuXdatP5JP4A08utMvA5Jhn6uazm0iGlkHfxqkfSD7kag2GIeIsyXLk6y4GY2EEWMNazwJUgmYsMXzyTeBarKMcEjHtXXbuQLewjCjs600RcEjjCjAlwllRwsGwII1PIxICwCyX0Lar28sKHzaUeOfcqOwsLxcSXPz1sKldRLaQWv8sMjcakTXAW1rIoiytsiPttVkyPo3MNQcxXfmbaL2OaBCAPK0fa8e0KfIs4uCCahvHR4cMaGsBaE8LM6PQWsYxmCLcoYRz8NTD7kag2OkCfxWeauAJbG5AW1rIoiytsODHO46irxrKWqQZT5jyWUiSKkXMGb7IWIvdxiwdUos0bbBscTlefxhj6kIegsDUnpPvW1GrwYmjVeATepwITlZ0gWEjYaEFjvGyjUKOuTe5CyKhULakf5kyQ4L4NAjZiaPw2LmduxULurhaCjAKDfTetuEbCn46irheSjjOaxX1rIUIiHHuNBZty5LqlPsSjnYUIkMO8cyZtAZITlZc0KpL8ubWWgvkYvWuXdat5r(vamSbY0erdGlJgdatWHWf8fdWnqQLTOOUCd(8QGvgTDBnYUIkMO8c4KFPTRTCkowv0MRbxhj6GGnjH2fIIRJeDfrcdPo3MNQaPqTgCDKOdc2Keov7hxceLYxivInXhtX1yOySuNrZtG0eW4JP4AmOmo(wdUos0bbBscNQ9JlMaciVgCDKOdc2KeIeNvalZOakC28fRbxhj6GGnjr1XvqyLGMAzHRH1GrwcOaPqXu4AW1rIo4OcKc1e0kLuQeBIcCmgIIJhrEnkbsMPUufUIxdUos0bhvGuOaBscwBHYdxHYM002p1AW1rIo4OcKcfytsazk1dwvQOJlqZuwwkDdTGlHtXXbCcePsSj8OqXaYuQhSQurhxGMPS8isTS5HRDBxhPKCHp2oz4eist9uvyj5lgUsbh51mgGquOS2YP44sK2C72AlNIJHnJV0yjoROqzBppi4BYAWilX4aYlbVNWajws3cflrUmSwImY0erdGlJgljXwsLfi5wI82KLWhtX1qQLGOlrol(wcampClzgbi1YUKzG6YTgCDKOdoQaPqb2KeMjmqIc0cfsLytvamSbY0erdGlJgdatPLpFmfxdWlVnPD7Wf8fdWnqQLTOOUCd(8QGvgDn46irhCubsHcSjjmtyGefOfkKkXMQayydKPjIgaxgngaMsl)kag2ahL5dkBEWICPwwMchaMTBxbWWgA0PzxWQsvaCkMwbGWbGPrxdUos0bhvGuOaBscyEjmyAbg0uwEn46irhCubsHcSjjWHaWXsLytHl4lgQKgnkbn1Ych85vbRKwJSROIjkVaoumwQZO5jqaRcGHnQuKRGPIhaMRH1GrwImGqcfsUdUgmYsmoG5HBj4v7ka0AjjCj(sW340sYttzhYsTeiAjgN9lHwlr73sQ8sGiBosBgUKkVeaiRwIdxIVeGifz0yjqtwiwcWjyiCjaW8WTeWrhgmDj4vi0HW8wcIUKzG9Ws0yjDlxHKdUgCDKOdo0k4KK(LqlPsSj8ad2fHfRgUqiTKon9QGhUDfaAv0OtLrIoPTDyW0IdHoeMxHY2EEWPzLw(4HcCmgIIJhk2dlrJc0Yvi5GTBxbWWgk2dlrJc0Yvi5GdfsUtAnYUIkMO8ci4NW3ORbxhj6GdTcc2KeychhleEKOBn46irhCOvqWMKat44yHWJeDfTG9dYsLytkUcGHnWeoowi8ir3GY2EEqWJ)AW1rIo4qRGGnjHRO85I84cfaAjvInHNkag2Wvu(CrECHcaTgaMslF8OriHcj3nKnfI8WvGMuMhaMTBJNWf8fdztHipCfOjL5bFEvWkJUgCDKOdo0kiytsqrcrjS4sfDmuQeBQcGHnOiHOewCPIogoOSTNhe8tgRDBjDA6vbpOrTqzksiwdgzj4fSL4kfCjoLxcGPulbEPjVKWIxc64LixgwlrGKJHXsA1AgglX4aYlrol(wIQrE4wcMddMUKWYVLid49LOySuNXsq0LixgwiGyj(1yjYaEFSgCDKOdo0kiytsy7uzzvbdrlk2dlP0n0cUeofhhWjqKkXMOEQkSK8fdxPGdatPLF4uCCmI0MlbQOsg8AKDfvmr5fWHIXsDgTBJhyWUiSy1GIWbWsRr2vuXeLxahkgl1z08K2Sy7YSan5tjpGy01GrwcEbBjhAjUsbxICPqSevYlrUmSYBjHfVKJLzSeJnluQLaa5LaoIndlbDlPIGWLixgwiGyj(1yjYaEFSgCDKOdo0kiytsy7uzzvbdrlk2dlPsSjQNQcljFXWvk4iVMn2SYd1tvHLKVy4kfCOaOEKOtA8ad2fHfRgueoawAnYUIkMO8c4qXyPoJMN0MfBxMfOjFk5bK1GrwcOcxXlzMiaO0glbDlbFWwcFSDYW1GRJeDWHwbbBsIQWvCbtaqPnKkXMGMSqucNIJdyZt4lnEQayyJQWvCbtaqPngaMRbxhj6GdTcc2Ke4SqWq0OadAkllvInPr2vuXeLxahkgl1z08eiGvbWWgvkYvWuXdaZ1GRJeDWHwbbBscztHipCfOjLzPsSjjDA6vbpQcxXfmbaL2OaBCAP5JP4AmI0MlbQy7YSz8xdUos0bhAfeSjjQcxXfka0sQeBssNMEvWJQWvCbtaqPnkWgNwA(ykUgJiT5sGk2UmBg)1GRJeDWHwbbBscfLDvv4kgkvInHhyWUiSy1WfcP1i7kQyIYlGGFcK1GRJeDWHwbbBscOLRqYzZcLuj2eEGb7IWIvdxiKwsNMEvWd3UcaTkA0PYir3AW1rIo4qRGGnjbKnHjuQeBcpWGDryXQHleRbxhj6GdTcc2KeMOirNuj2ufadBufiKsaaJbLDD0UnwIZkku22ZdcEJnB72vamSHRO85I84cfaAnamxdUos0bhAfeSjjQcesvWaOnwdUos0bhAfeSjjQmfYuzZd3AW1rIo4qRGGnjbws5QaHuRbxhj6GdTcc2Ke(PzyqDrr7cXAWilzgymhqelbZfIQRLDjyi6saGEvWljd2gowdUos0bhAfeSjjaGCjd2gkvInvbWWgvbcPeaWyqzxhTBJL4SIcLT98GGFc)zB3wJSROIjkVaoumwQZa8t4VgwdgzjZK8sOftHRbJSeqdJ7sq3s0iKqHK7wsGwISmBUKWIxImqZyjkUcGHTeaZ1GRJeDWbwEj0AQYHCmFLWIlCdgUgCDKOdoWYlHwGnjbuKAU4NQOsnlvInvbWWgqrQ5IFQIk18GY2EEqWJL4SIcLT98GsxbWWgqrQ5IFQIk18GY2EEqWlFqatJSROIjkVaAuWbqggV1GRJeDWbwEj0cSjjuj00dT1AynyKL0d2fH1AW1rIo4agSlcRjvcn9qBjvInPr2vuXeLxaBEsBwSDzwGM8PwdUos0bhWGDryb2KeUDfaATgCDKOdoGb7IWcSjj0wSBwGwOqkDdTGlHtXXbCcePsSPWf8fdtk3OGUsyXf5yx2bFEvWkPXt4uCCmsyPIGWVljtHj6(54pl(Zcc(ZoZ)UCo9Ydh87Zy8k4CoEz(mdVTKL0YIxsABIOXsWq0L0ufJ5aIOPlHYGBGKYQLar28sCGaz7bRwI2YpCmCSgMP5XlrEXBlrgqNKmny1sAQgDkGmgY4MUKaTKMQrNciJHmEWNxfSQPlr(GitJowdRHzmEfCohVmFMH3wYsAzXljTnr0yjyi6sAQwbB6sOm4giPSAjqKnVehiq2EWQLOT8dhdhRHzAE8sabVTezaDsY0GvlPPuGJXquC8qg30LeOL0ukWXyikoEiJh85vbRA6sKpiY0OJ1WAygJxbNZXlZNz4TLSKww8ssBtenwcgIUKMwbsHQPlHYGBGKYQLar28sCGaz7bRwI2YpCmCSgMP5Xlbe82sKb0jjtdwTKMsbogdrXXdzCtxsGwstPahJHO44HmEWNxfSQPlXJLyCLrZ0LiFqKPrhRH1aEX2erdwTeW1sCDKOBjIegWXA47IegWV13vmMdiIV1phKV13DDKO77YMAz)oFEvWQh0p(54)T(URJeDFhgSlcRVZNxfS6b9JFUX(wFNpVky1d63rMFhYX3DDKO77s600Rc(7s6ca(70OwQayyWLa(LG)sKEjYFjvamSrfGMSQeu2HauEayUK2TxsfadBGJ6NQyZcMhaMlPD7LubWWgbfGlv2P5HBayUeJ(DjDA5CB(70OwOmfjeF8ZL3V135ZRcw9G(DK53HC8Dxhj6(UKon9QG)UKUaG)UgzxrftuEbCOySuNXsAEAj4VeWwsfadBuPixbtfpamxI0lHpMIRXsAEAjnz2Li9sK)sWZs0OtbKXqJaUOewCbPuWbFEvWQL0U9sQayydksikHfxQOJHdkB75bxsZtlbKzxIr)UKoTCUn)D3UcaTkA0PYir3h)8M8T(oFEvWQh0VJm)oKJV76ir33L0PPxf83L0fa83HMSqucNIJd4OkCfxWeauAJLa(LG)sKEjupvfws(IHRuWrElP5LG)SlPD7LubWWgvHR4cMaGsBmam)UKoTCUn)9QWvCbtaqPnkWgN(JFo46B9D(8QGvpOFxtZGPP)DyWUiSy1WfIV76ir331UquCDKORisy8DrcJY5283Hb7IW6JFUX)B9D(8QGvpOF31rIUVRDHO46irxrKW47IegLZT5VRvWp(5gVV135ZRcw9G(DnndMM(31i7kQyIYlGlP5PLOnl2Umlqt(ulrEwsfadBuPixbtfpamxI8Se5VKkag2azAIObWLrJbG5sahws4c(Ib4gi1YwuuxUbFEvWQLy0L0U9s0i7kQyIYlGlzAj(L2U2YP4yvrB(Dxhj6(of4kUos0vejm(UiHr5CB(7y5LqRp(5Z8V135ZRcw9G(Dxhj6(U2fIIRJeDfrcJVlsyuo3M)EfifQp(5Gm736785vbREq)UMMbtt)78XuCngkgl1zSKMNwcinzjGTe(ykUgdkJJVV76ir33DQ2pUeikLV4JFoiG8T(URJeDF3PA)4IjGaYFNpVky1d6h)CqW)B9Dxhj6(UiXzfWYmkGcNnFX35ZRcw9G(XpheJ9T(URJeDFV64kiSsqtTSWVZNxfS6b9Jp(UjL1i7QhFRFoiFRV76ir33DttrJIjkHO7785vbREq)4NJ)367Uos099kkcbRkycVbRKlpCLajZ8(oFEvWQh0p(5g7B9D(8QGvpOF31rIUVB7uzzvbdrlk2dRVRPzW00)o1tvHLKVy4kfCK3sAEjY7SF3KYAKD1JcK1Otb)Et(4NlVFRVZNxfS6b97Uos09DksikHfxQOJHFxtZGPP)DkJrzOLxf83nPSgzx9Oazn6uWVJ)h)8M8T(oFEvWQh0V76ir33HIuZf)ufvQ5VRPzW00)oLXOm0YRc(7MuwJSREuGSgDk43X)JFo46B9Dxhj6(omyxewFNpVky1d6hF89kqkuFRFoiFRVZNxfS6b97AAgmn9VtbogdrXXJiVgLajZuxQcxXd(8QGvF31rIUVdTsj)4NJ)367Uos09DwBHYdxHYM002p135ZRcw9G(Xp3yFRVZNxfS6b97Uos09DitPEWQsfDCbAMYYFxtZGPP)D8SefkgqMs9GvLk64c0mLLhrQLnpClPD7L46iLKl8X2jdxY0sazjsVeQNQcljFXWvk4iVL08sWaeIcL1wofhxI0Mxs72lrB5uCmCjnVe8xI0lblXzffkB75bxc4xst(UUHwWLWP44a(Zb5JFU8(T(oFEvWQh0VRPzW00)EfadBGmnr0a4YOXaWCjsVe5Ve(ykUglb8lrEBYsA3EjHl4lgGBGulBrrD5g85vbRwIr)URJeDF3mHbsuGwO4JFEt(wFNpVky1d6310myA6FVcGHnqMMiAaCz0yayUePxI8xsfadBGJY8bLnpyrUulltHdaZL0U9sQayydn60SlyvPkaoftRaq4aWCjg97Uos09DZegirbAHIp(5GRV13DDKO77W8syW0cmOPS835ZRcw9G(Xp34)T(oFEvWQh0VRPzW00)E4c(IHkPrJsqtTSWbFEvWQLi9s0i7kQyIYlGdfJL6mwsZtlbKLa2sQayyJkf5kyQ4bG53DDKO774qa44p(47WGDry9T(5G8T(oFEvWQh0VRPzW00)UgzxrftuEbCjnpTeTzX2LzbAYN67Uos09Dvcn9qB9Xph)V13DDKO77UDfaA9D(8QGvpOF8Zn236785vbREq)URJeDFxBXUzbAHIVRPzW00)E4c(IHjLBuqxjS4ICSl7GpVky1sKEj4zjHtXXXiHLkcc)UUHwWLWP44a(Zb5Jp(Uwb)w)Cq(wFNpVky1d6310myA6FhplbgSlclwnCHyjsVejDA6vbpC7ka0QOrNkJeDlr6Ly7WGPfhcDimVcLT98GlzAjZUePxI8xcEwcf4ymefhpuShwIgfOLRqYbh85vbRws72lPcGHnuShwIgfOLRqYbhkKC3sKEjAKDfvmr5fWLa(PLG)sm63DDKO77s6xcT(4NJ)367Uos09DmHJJfcps09D(8QGvpOF8Zn236785vbREq)UMMbtt)7kUcGHnWeoowi8ir3GY2EEWLa(LG)3DDKO77ychhleEKOROfSFq(JFU8(T(oFEvWQh0VRPzW00)oEwsfadB4kkFUipUqbGwdaZLi9sK)sWZs0iKqHK7gYMcrE4kqtkZdaZL0U9sWZscxWxmKnfI8WvGMuMh85vbRwIr)URJeDF3vu(CrECHcaT(4N3KV135ZRcw9G(DnndMM(3RayydksikHfxQOJHdkB75bxc4NwIXws72lrsNMEvWdAuluMIeIV76ir33PiHOewCPIog(XphC9T(oFEvWQh0V76ir33TDQSSQGHOff7H1310myA6FN6PQWsYxmCLcoamxI0lr(ljCkoogrAZLavujVeWVenYUIkMO8c4qXyPoJL0U9sWZsGb7IWIvdkchaVePxIgzxrftuEbCOySuNXsAEAjAZITlZc0Kp1sKNLaYsm631n0cUeofhhWFoiF8Zn(FRVZNxfS6b97AAgmn9Vt9uvyj5lgUsbh5TKMxIXMDjYZsOEQkSK8fdxPGdfa1JeDlr6LGNLad2fHfRgueoaEjsVenYUIkMO8c4qXyPoJL080s0MfBxMfOjFQLiplbKV76ir33TDQSSQGHOff7H1h)CJ336785vbREq)UMMbtt)7qtwikHtXXbCjnpTe8xI0lbplPcGHnQcxXfmbaL2yay(Dxhj6(Ev4kUGjaO0gF8ZN5FRVZNxfS6b97AAgmn9VRr2vuXeLxahkgl1zSKMNwcilbSLubWWgvkYvWuXdaZV76ir33XzHGHOrbg0uw(JFoiZ(T(oFEvWQh0VRPzW00)UKon9QGhvHR4cMaGsBuGno9sKEj8XuCngrAZLavSDzUKMxc(F31rIUVlBke5HRanPm)Xpheq(wFNpVky1d6310myA6FxsNMEvWJQWvCbtaqPnkWgNEjsVe(ykUgJiT5sGk2UmxsZlb)V76ir33RcxXfka06JFoi4)T(oFEvWQh0VRPzW00)oEwcmyxewSA4cXsKEjAKDfvmr5fWLa(PLaY3DDKO77kk7QQWvm8JFoig7B9D(8QGvpOFxtZGPP)D8SeyWUiSy1WfILi9sK0PPxf8WTRaqRIgDQms09Dxhj6(o0Yvi5SzH6JFoiY736785vbREq)UMMbtt)74zjWGDryXQHleF31rIUVdztyc)4Ndst(wFNpVky1d6310myA6FVcGHnQcesjaGXGYUows72lblXzffkB75bxc4xIXMDjTBVKkag2Wvu(CrECHcaTgaMF31rIUVBIIeDF8ZbbC9T(URJeDFVkqivbdG24785vbREq)4NdIX)B9Dxhj6(ELPqMkBE4(oFEvWQh0p(5Gy8(wF31rIUVJLuUkqi135ZRcw9G(XphKz(367Uos09D)0mmOUOODH4785vbREq)4NJ)SFRVZNxfS6b97AAgmn9VxbWWgvbcPeaWyqzxhlPD7LGL4SIcLT98Glb8tlb)zxs72lrJSROIjkVaoumwQZyjGFAj4)Dxhj6(oaKlzW2Wp(47y5LqRV1phKV13DDKO77voKJ5RewCHBWWVZNxfS6b9JFo(FRVZNxfS6b97AAgmn9VxbWWgqrQ5IFQIk18GY2EEWLa(LGL4SIcLT98Glr6LubWWgqrQ5IFQIk18GY2EEWLa(Li)LaYsaBjAKDfvmr5fWLy0LaoSeqggVV76ir33HIuZf)ufvQ5p(5g7B9Dxhj6(UkHMEOT(oFEvWQh0p(4JV7aHfI(9EAldF8X)a]] )

end