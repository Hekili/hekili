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


    spec:RegisterPack( "Outlaw", 20201208, [[d4uWOaqiiQEervUerPuTjIuFIiIrrrXPOOYQKIuEfezwqQUfrPAxk8lIWWuu5yqOLbP8mikMgeLUgfvTnIOQVruv14KIW5iQQSoIQI5POQ7Pi7tkQdsuIwie8qIsAIsr0fjQkTrPiPpsejojruzLuKzsuk5Mers7ur5NeLIHsuchvksyPerXtLQPkL6QerQ2krPu(krKYyLIuTxv(RedgXHPAXs6XKmzsDzuBguFgsgnLCArRwks0RjsMnHBtP2TQ(nudNchNikTCKEoW0fUoiBNO47evgpfLoVuy(sj7xPpeV2xx7bFZqBo0Mdr0MRjgik)qwZBEK96rdd(6gUskhfF93T5RlBGcHl31n8gcSRV2xhGHOk(6wryaKpsibQmSGQdf2wcqAdj8iXVI6WHeG0wjX1RqPiKC)vVU2d(MH2COnhIOnxtmqu(HSM38ODDGbRUzOj5N76wPwZ)vVUMbQRlVLiBGcHl3sKmyuq8AsElPjzfBxz6sAc0xcAZH2Cx3GIHtbFD5TezduiC5wIKbJcIxtYBjnjRy7ktxstG(sqBo0MBnTMK3sKVMLvqbRxsLHXuEjkSD1JLuzu5dglrwQuSrawYJFz3YP2WqIL4QiXpyj4x0ySMCvK4hmmOScBx9yYnmenkg4eG)1KRIe)GHbLvy7QhinjHTtLI1fymTOzpSq3GYkSD1JcGv4xdMmp6j8e1tDHLH)y4AnyKFZi7CRjxfj(bddkRW2vpqAsckwikHfxQ4NbOBqzf2U6rbWk8RbtOHEcprzykdS8QGxtUks8dgguwHTREG0KearQ4I)6Iovm6guwHTREuaSc)AWeAONWtugMYalVk41KRIe)GHbLvy7QhinjbiyxewRP1K8wI81SScky9syzyAJLePnVKWIxIRcmDjjyjUmEk8QGhRjxfj(btsLkPwtYBjsggeSlcRLKWlXadazvWlXmpEjYajEM6vbVe(z7Kblj)LOW2vpm3AYvrIFastsac2fH1AsElrYWuSqSeq(Oe8sqOTesksQs0gHLuHGHblrol(xIbgaYQGxtUks8dqAsczCA6vbJ(728enQfktXcb6Y4ciEIg1sfcggmpAsBMkem8Ocrtwxck7aikpGmA1Qcbdpqr9xxSzbZdiJwTQqWWJGcXLk708rnGmm3AsElr((aikVe54LGIJLadjelrwAxHawlrwLflbLNpyj(RxIt5xsILqzkwiYh1sKvm0hljS4LiB0AWsQqWWGL4Y5nwtiTexfj(binjHmon9QGr)DBEYTRqaRIc)6ms8JUmUaINuy7kUyGZpadndNQmAEcnKQqWWJkf7AqQ5bKH08ZuunAEY8ZjTzqUc)AOmgkm0hLWIlyTg0QvfcgEqXcrjS4sf)myqzBpFqZtioN5wtYBjsAzyTeBirKgcEjHtrXba9LewjyjY400RcEjjyjklwjfRxsGxIMvPMxICwCyX0LaW28sK1MeSeGfgsOxsLxcOXRy9sKldRLGGW18sAQcikTXAYvrIFastsiJttVky0F3MNQcxZfybeL2OaA8k0LXfq8eWGfIs4uuCagvHR5cSaIsBmpAst9uxyz4pgUwdg53mAZ1QvfcgEufUMlWcikTXaYyn5QiXpaPjjuUquCvK4VisqG(728eiyxewONWtGGDryX6HleRjxfj(binjHYfIIRIe)frcc0F3MNuAWAsElPPMFcSwIhlX2nBAdzVezvwSKkuSexgCQxICoiYh1sqGIDni18s8xVKMcOuj1sAsQl3sQ4hcSef2UIxIbo)aSMCvK4hG0KeuOV4QiXFrKGa93T5j48tGf6j8KcBxXfdC(bO5jLrX2nBbyWVw2RqWWJkf7AqQ5bKHSBMkem8aByGPb0NrJbKrtlCb)XqYcLkPkAQl3GFVkyT5A1sHTR4Ibo)am5FA7klNII1fLXAYvrIFastsOCHO4QiXFrKGa93T5Pkuk0Rjxfj(binjHtv(ZLatP8hONWt8ZuungAgovz08eIMhj(zkQgdkJI)1KRIe)aKMKWPk)5IbKaWRjxfj(binjHirzfGstjKgLn)XAYvrIFastsuDufmCjOPskWAAnjVLGauk0mfSMCvK4hmQqPqpbSszqpHNOqpdJPO4rKFJsGnBQkvHR51KRIe)GrfkfAKMKGvw48rvOSbnT9xVMCvK4hmQqPqJ0KeaMs9G1Lk(5cWiLIrx1qj4s4uuCaMqe9eEc5ACmamL6bRlv8ZfGrkfpIujv(OA1Yvrkdx4NTtgmHO0up1fwg(JHR1Gr(nddjefkRSCkkUePn3QLYYPOyqZOjnCIYkku22ZhmV5xtYBjs6aEjYIeeyXs6w4yjYLH1sKnggyAa9z0yjj8sQSal3sqwZVe(zkQgOVemDjYzX)sGa5JAjnfqPsQL0KuxU1KRIe)GrfkfAKMKWibbwuaw4a9eEQcbdpWggyAa9z0yaziTz4NPOAmpYA(wTcxWFmKSqPsQIM6Yn43RcwBU1KRIe)GrfkfAKMKWibbwuaw4a9eEQcbdpWggyAa9z0yaziTzQqWWduuMFGu5dkYLkPykyaz0QvfcgEOWVIDbRlvb0RzAfcagqgMBn5QiXpyuHsHgPjja5NGGPfqqtP41KRIe)GrfkfAKMKafgcfJEcpfUG)yOtA0Oe0ujfyWVxfSwAf2UIlg48dWqZWPkJMNqePkem8OsXUgKAEazSMwtYBjYkgl0y5EWAsElrshKpQLilTRqaRLKGL4lbnz7ljFfLDaJ(sa4LiBZ)eyTeL)lPYlbGT5iTzWsQ8sGaSEjoyj(sGIuKrJLamyHyjqVGbGLabYh1sKuDqW0LilbahaYFjy6sAs2dlrJL0TCnwoWAYvrIFWqPbtY4FcSqpHNqoiyxewSE4cH0Y400RcE42viGvrHFDgj(L22bbtloa4aq(fkB75dMMtAZGCk0ZWykkEOzpSenkalxJLd0QvfcgEOzpSenkalxJLdm0y5EPvy7kUyGZpaZpHM5wtUks8dgknaPjjGfokwi8iX)AYvrIFWqPbinjbSWrXcHhj(lkb7pGrpHN0CfcgEalCuSq4rI)bLT98bZJ2AYvrIFWqPbinjHRP87I85cfcyHEcpH8kem8W1u(Dr(CHcbSgqgsBgKRWyHgl3pKkfI8rvaguMhqgTAH8Wf8hdPsHiFufGbL5b)EvWAZTMCvK4hmuAastsqXcrjS4sf)ma9eEQcbdpOyHOewCPIFgmOSTNpy(jKPvlzCA6vbpOrTqzkwiwtYBjso4L4AnyjoLxcKb6lb8PbVKWIxc(5LixgwlrGLJbXsA3UjhlrshWlrol(xIUr(OwcSdcMUKWY)LiRYILOz4uLXsW0LixgwyOyj(3yjYQSySMCvK4hmuAastsy7uPyDbgtlA2dl0vnucUeoffhGjerpHNOEQlSm8hdxRbdidPnt4uuCmI0MlbUOtEEf2UIlg48dWqZWPkJwTqoiyxewSEqXOGyPvy7kUyGZpadndNQmAEszuSDZwag8RLDen3AsElrYbVKhVexRblrUuiwIo5Lixgw5VKWIxYZMnwcYmha9Lab4LiPc3Klb)lPIbGLixgwyOyj(3yjYQSySMCvK4hmuAastsy7uPyDbgtlA2dl0t4jQN6cld)XW1AWi)MrM5KDQN6cld)XW1AWqdr9iXV0iheSlclwpOyuqS0kSDfxmW5hGHMHtvgnpPmk2Uzlad(1YoIRj5TeeeUMxstvarPnwc(xcAiTe(z7KbRjxfj(bdLgG0KevHR5cSaIsBGEcpbmyHOeoffhGMNqtAKxHGHhvHR5cSaIsBmGmwtUks8dgknaPjjqzHbHOrbe0ukg9eEsHTR4Ibo)am0mCQYO5jerQcbdpQuSRbPMhqgRjxfj(bdLgG0KesLcr(OkadkZONWtY400RcEufUMlWcikTrb04vsZptr1yePnxcCX2nBZOTMCvK4hmuAastsufUMluiGf6j8Kmon9QGhvHR5cSaIsBuanEL08ZuungrAZLaxSDZ2mARjxfj(bdLgG0KeAk76QW1ma9eEc5GGDryX6HlesRW2vCXaNFaMFcX1KRIe)GHsdqAscGLRXYzZcn6j8eYbb7IWI1dxiKwgNMEvWd3UcbSkk8RZiX)AYvrIFWqPbinjbGnaja9eEc5GGDryX6HleRjxfj(bdLgG0Keg4iXp6j8ufcgEufySwabIbLDv0QfCIYkku22ZhmpYmxRwviy4HRP87I85cfcynGmwtUks8dgknaPjjQcmwxGHOnwtUks8dgknaPjjQmfWuPYh1AYvrIFWqPbinjbCs5QaJ1Rjxfj(bdLgG0Ke(RyqqDrr5cXAsElPjzyhselb2fIQRKAjWy6sGaEvWljd2gmwtUks8dgknaPjjGaCjd2gGEcpvHGHhvbgRfqGyqzxfTAbNOSIcLT98bZpH2CTAPW2vCXaNFagAgovzm)eARP1K8wstn)eyXuWAsElbHq(Ue8Vefgl0y5(Le4LifZgljS4LiR0mwIMRqWWlbYyn5QiXpyaNFcSMQCihZFjS4c3GbRjxfj(bd48tGfstsaePIl(Rl6uXONWtviy4bqKkU4VUOtfpOSTNpyE4eLvuOSTNpq6kem8aisfx8xx0PIhu22ZhmVzqejf2UIlg48dG5AAioAI1KRIe)GbC(jWcPjj0jWWdL1AAnjVL0d2fH1AYvrIFWaeSlcRjDcm8qzHEcpPW2vCXaNFaAEszuSDZwag8RxtUks8dgGGDrynPSy3OaSWb6QgkbxcNIIdWeIONWtHl4pgguUrb)LWIlYXUud(9QG1sJ8WPO4yKGsfdaRjxfj(bdqWUiSqAsc3UcbSUUmmfK4)MH2COnhIOnN8)6Y50pFuGRlPjlLmZKCZKuKplzjTT4LK2gyASeymDjsIsdKKLqzjlusz9sayBEjouGT9G1lrz5pkgmwtYw5Zlbr5ZsKv8ldtdwVejHc9mmMIIhnDjzjbEjscf6zymffpA6d(9QG1sYsmdIM1CJ10AsstwkzMj5MjPiFwYsABXljTnW0yjWy6sKKkuk0sYsOSKfkPSEjaSnVehkW2EW6LOS8hfdgRjzR85LGO8zjYk(LHPbRxIKqHEggtrXJMUKSKaVejHc9mmMIIhn9b)EvWAjzjESe5RSr2AjMbrZAUXAAnj5SnW0G1lrYVexfj(xIibbySMUUdfwy617PTSEDrccW1(6Ag2HeX1(MH41(6Uks8FDPsLuxNFVky9HWf3m0U2x3vrI)Rdc2fH1153RcwFiCXndzU2xNFVky9HW1XgxhWX1DvK4)6Y400Rc(6Y4ci(60OwQqWWGLm)sqBjsVeZSKkem8Ocrtwxck7aikpGmwsRwlPcbdpqr9xxSzbZdiJL0Q1sQqWWJGcXLk708rnGmwI5UUmoT8UnFDAuluMIfIlUzi71(687vbRpeUo246aoUURIe)xxgNMEvWxxgxaXxhyWcrjCkkoaJQW1CbwarPnwY8lbTLi9sOEQlSm8hdxRbJ8xsZlbT5wsRwlPcbdpQcxZfybeL2yazCDzCA5DB(6vHR5cSaIsBuanE1f3mZFTVo)EvW6dHRROzW00VoiyxewSE4cX1DvK4)6kxikUks8xejiUUibr5DB(6GGDryDXntYFTVo)EvW6dHR7QiX)1vUquCvK4VisqCDrcIY7281vAWf3m5)1(687vbRpeUUIMbtt)6kSDfxmW5hGL080sugfB3SfGb)6Li7lPcbdpQuSRbPMhqglr2xIzwsfcgEGnmW0a6ZOXaYyjnTLeUG)yizHsLufn1LBWVxfSEjMBjTATef2UIlg48dWsMwI)PTRSCkkwxugx3vrI)RtH(IRIe)frcIRlsquE3MVoC(jW6IBwtCTVo)EvW6dHR7QiX)1vUquCvK4VisqCDrcIY7281RqPqFXnt(DTVo)EvW6dHRROzW00Vo)mfvJHMHtvglP5PLGO5xcslHFMIQXGYO4)6Uks8FDNQ8NlbMs5pU4MH4Cx7R7QiX)1DQYFUyaja8153RcwFiCXndreV2x3vrI)RlsuwbO0ucPrzZFCD(9QG1hcxCZqeTR91DvK4)6vhvbdxcAQKcCD(9QG1hcxCX1nOScBx94AFZq8AFDxfj(VUByiAumWja)xNFVky9HWf3m0U2xNFVky9HW1DvK4)62ovkwxGX0IM9W66kAgmn9Rt9uxyz4pgUwdg5VKMxcYo31nOScBx9Oayf(1GRB(lUziZ1(687vbRpeUURIe)xNIfIsyXLk(zW1v0myA6xNYWugy5vbFDdkRW2vpkawHFn46ODXndzV2xNFVky9HW1DvK4)6arQ4I)6Iov81v0myA6xNYWugy5vbFDdkRW2vpkawHFn46ODXnZ8x7R7QiX)1bb7IW6687vbRpeU4IRdNFcSU23meV2x3vrI)Rx5qoM)syXfUbdUo)EvW6dHlUzODTVo)EvW6dHRROzW00VEfcgEaePIl(Rl6uXdkB75dwY8lborzffkB75dwI0lPcbdpaIuXf)1fDQ4bLT98blz(LyMLG4sqAjkSDfxmW5hGLyUL00wcIJM46Uks8FDGivCXFDrNk(IBgYCTVURIe)xxNadpuwxNFVky9HWfxCDqWUiSU23meV2xNFVky9HW1v0myA6xxHTR4Ibo)aSKMNwIYOy7MTam4xFDxfj(VUobgEOSU4MH21(687vbRpeUURIe)xxzXUrbyHJRROzW00VE4c(JHbLBuWFjS4ICSl1GFVky9sKEjiFjHtrXXibLkgaUUQHsWLWPO4aCZq8IBgYCTVURIe)x3TRqaRRZVxfS(q4IlUUsdU23meV2xNFVky9HW1v0myA6xh5lbeSlclwpCHyjsVezCA6vbpC7keWQOWVoJe)lr6Ly7GGPfhaCai)cLT98blzAjZTePxIzwcYxcf6zymffp0ShwIgfGLRXYbg87vbRxsRwlPcbdp0ShwIgfGLRXYbgASC)sKEjkSDfxmW5hGLm)0sqBjM76Uks8FDz8pbwxCZq7AFDxfj(VoSWrXcHhj(Vo)EvW6dHlUziZ1(687vbRpeUUIMbtt)6AUcbdpGfokwi8iX)GY2E(GLm)sq76Uks8FDyHJIfcps8xuc2FaFXndzV2xNFVky9HW1v0myA6xh5lPcbdpCnLFxKpxOqaRbKXsKEjMzjiFjkmwOXY9dPsHiFufGbL5bKXsA1AjiFjHl4pgsLcr(OkadkZd(9QG1lXCx3vrI)R7Ak)UiFUqHawxCZm)1(687vbRpeUUIMbtt)6viy4bfleLWIlv8ZGbLT98blz(PLGmlPvRLiJttVk4bnQfktXcX1DvK4)6uSquclUuXpdU4Mj5V2xNFVky9HW1DvK4)62ovkwxGX0IM9W66kAgmn9Rt9uxyz4pgUwdgqglr6LyMLeoffhJiT5sGl6KxY8lrHTR4Ibo)am0mCQYyjTATeKVeqWUiSy9GIrbXlr6LOW2vCXaNFagAgovzSKMNwIYOy7MTam4xVezFjiUeZDDvdLGlHtrXb4MH4f3m5)1(687vbRpeUUIMbtt)6up1fwg(JHR1Gr(lP5LGmZTezFjup1fwg(JHR1GHgI6rI)Li9sq(sab7IWI1dkgfeVePxIcBxXfdC(byOz4uLXsAEAjkJITB2cWGF9sK9LG41DvK4)62ovkwxGX0IM9W6IBwtCTVo)EvW6dHRROzW00VoWGfIs4uuCawsZtlbTLi9sq(sQqWWJQW1CbwarPngqgx3vrI)RxfUMlWcikTXf3m531(687vbRpeUUIMbtt)6kSDfxmW5hGHMHtvglP5PLG4sqAjviy4rLIDni18aY46Uks8FDuwyqiAuabnLIV4MH4Cx7RZVxfS(q46kAgmn9RlJttVk4rv4AUalGO0gfqJxTePxc)mfvJrK2CjWfB3SlP5LG21DvK4)6sLcr(OkadkZxCZqeXR9153RcwFiCDfndMM(1LXPPxf8OkCnxGfquAJcOXRwI0lHFMIQXisBUe4ITB2L08sq76Uks8F9QW1CHcbSU4MHiAx7RZVxfS(q46kAgmn9RJ8Lac2fHfRhUqSePxIcBxXfdC(byjZpTeeVURIe)xxtzxxfUMbxCZqezU2xNFVky9HW1v0myA6xh5lbeSlclwpCHyjsVezCA6vbpC7keWQOWVoJe)x3vrI)RdSCnwoBwOV4MHiYETVo)EvW6dHRROzW00VoYxciyxewSE4cX1DvK4)6a2aKGlUziA(R9153RcwFiCDfndMM(1RqWWJQaJ1ciqmOSRIL0Q1sGtuwrHY2E(GLm)sqM5wsRwlPcbdpCnLFxKpxOqaRbKX1DvK4)6g4iX)f3meL8x7R7QiX)1RcmwxGHOnUo)EvW6dHlUzik)V2x3vrI)RxzkGPsLpQRZVxfS(q4IBgInX1(6Uks8FD4KYvbgRVo)EvW6dHlUzik)U2x3vrI)R7VIbb1ffLlexNFVky9HWf3m0M7AFD(9QG1hcxxrZGPPF9kem8OkWyTacedk7QyjTATe4eLvuOSTNpyjZpTe0MBjTATef2UIlg48dWqZWPkJLm)0sq76Uks8FDiaxYGTbxCX1RqPqFTVziETVo)EvW6dHRROzW00Vof6zymffpI8BucSztvPkCnp43RcwFDxfj(VoWkL5IBgAx7R7QiX)1zLfoFufkBqtB)1xNFVky9HWf3mK5AFD(9QG1hcx3vrI)Rdyk1dwxQ4NlaJuk(6kAgmn9RJ8LOXXaWuQhSUuXpxagPu8isLu5JAjTATexfPmCHF2ozWsMwcIlr6Lq9uxyz4pgUwdg5VKMxcmKquOSYYPO4sK28sA1AjklNIIblP5LG2sKEjWjkROqzBpFWsMFjM)6QgkbxcNIIdWndXlUzi71(687vbRpeUUIMbtt)6viy4b2WatdOpJgdiJLi9smZs4NPOASK5xcYA(L0Q1scxWFmKSqPsQIM6Yn43RcwVeZDDxfj(VUrccSOaSWXf3mZFTVo)EvW6dHRROzW00VEfcgEGnmW0a6ZOXaYyjsVeZSKkem8afL5hiv(GICPskMcgqglPvRLuHGHhk8RyxW6sva9AMwHaGbKXsm31DvK4)6gjiWIcWchxCZK8x7R7QiX)1b5NGGPfqqtP4RZVxfS(q4IBM8)AFD(9QG1hcxxrZGPPF9Wf8hdDsJgLGMkPad(9QG1lr6LOW2vCXaNFagAgovzSKMNwcIlbPLuHGHhvk21GuZdiJR7QiX)1rHHqXxCXfxCXDa]] )

end