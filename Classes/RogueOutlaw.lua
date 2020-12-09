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


    spec:RegisterPack( "Outlaw", 20201209, [[d4epQaqiGQEefIlrHuQnru8jkunkIQCkIQAvsPkEfuLzreUffs2Lc)Ii1WKs5yaPLbv1ZKIQPjLkxdiyBaH8nPuvghquDoIKQ1rKqZdOY9uK9jf5GejyHaLhsKOjkffxKcPAJsPk9rPuvDsGOSskyMsrPUjqOANkQ(jrsAOejLJkfLyPar8uPAQkkxLcPyRuiL8vGqzSejXEv1FLyWiomvlwspMutMKlJAZq5ZqLrtjNw0QLIs61eLMnHBtP2Tk)gYWPOJdePLJ0ZbnDHRdy7erFNOY4Pq58sH5lLSFL(b9N9DLh8ph)2WVnqXVnP(auqu7Ax7A(3JgM83nDTSoo(7NBZFxQcecxUVB6neix9Z(oebq183TIWekfLwACzybuhAKT0W0gq4rIon1XcPHPTw6VxbsraYUV(DLh8ph)2WVnqXVnP(auqu7AxZB33HMS(NJpiQTVBLkfFF97kgQ)UrwIufieUClbKGWbWRbJSKMH1SDLPlbKlXsWVn8B77Muewk4VBKLivbcHl3sajiCa8AWilPzynBxz6sK6sSe8Bd)2wdRbJSeJUXynqWQLuzmeLxIgzx9yjvgxEWXsKcAnBgWLCOZOSCQngGyjUos0bxc6engRbxhj6GdtkRr2vpMCttrJIjkHOBn46irhCysznYU6bEtsB7uzzvbdrlk2dljmPSgzx9Oazn6uWjqqIeBI6PQWsYxmCLcoYRP212AW1rIo4WKYAKD1d8MKMIeIsyXLk6yOeMuwJSREuGSgDk4e(sKytugJYqlVk41GRJeDWHjL1i7Qh4njnuKAU4NQOsnlHjL1i7QhfiRrNcoHVej2eLXOm0YRcEn46irhCysznYU6bEtsdd2fH1AynyKLy0ngRbcwTewsM2yjrAZljS4L46arxscxIlPNcVk4XAW1rIo4KSPw21GrwciHHb7IWAjj2smrqywf8sK3HwIKaIJPEvWlHp2oz4sYBjAKD1d5VgCDKOdI3K0WGDryTgmYsajmfjelbMhobVeWMjD7hex6zGTKkaggCjYzX3smrqywf8AW1rIoiEtslPttVkyjo3MNOrTqzksiKqsxaWt0OwQayyqWHVmYRcGHnQa0KvLGYoeGYdaZwTQayydCu)ufBwW8aWSvRkag2iOaCPYonpCdat5VgmYsm6heGYlroEj44yjyacXsKc2vaO1sKsP2sW55bxIFQL4u(mESektrcrE4wIuIaUyjHfVePQsbxsfaddUexoVXAW1rIoiEtslPttVkyjo3MNC7ka0QOrNkJeDsiPla4jnYUIkMO8c4qXyPoJMMWhVkag2OsrUcMkEaykdFmfxJMMaH2KrEGxJofqgdnc4IsyXfKsbB1QcGHnOiHOewCPIogoOSTNhSPjqBt(RbJSeqSmSwInGistbVKWP44akXscReUejDA6vbVKeUeTfRLLvljqlrX6uXlroloSy6sGiBEjszZaxc0cbiulPYlb240SAjYLH1sat4kEjTxbaL2yn46irheVjPL0PPxfSeNBZtvHR4cMaGsBuGnoTes6caEcAYcrjCkooGJQWvCbtaqPnah(Yq9uvyj5lgUsbh51e(T1QvfadBufUIlycakTXaWCn46irheVjP1UquCDKORisyiX528emyxewsKytWGDryXQHleRbxhj6G4njT2fIIRJeDfrcdjo3MN0k4AWilP9MxcTwIhlX2nwAdyVePuQTKkqSexsuQwIComYd3saJICfmv8s8tTKMfGul7sAgQl3sQOdaUenYUIwIjkVaUgCDKOdI3K0uGR46irxrKWqIZT5jS8sOLej2KgzxrftuEbSPjTzX2nwbAYNYOQayyJkf5kyQ4bGPrjVkag2azAIObWLrJbGz7jCbFXaKcKAzlkQl3GpVkyL8B1sJSROIjkVao5xA7AlNIJvfT5AW1rIoiEtsRDHO46irxrKWqIZT5PkqkuRbxhj6G4njTt1(XLarP8fsKyt8XuCngkgl1z00eOGaE8XuCngughFRbxhj6G4njTt1(XftabKxdUos0bXBsArIZkGLMvafoB(I1GRJeDq8MKU64kiSsqtTSW1WAWilbmGuOykCn46irhCubsHAcALskrInrbogdrXXJiVgLazSuxQcxXRbxhj6GJkqku4njnRTq5HRqztAA7NAn46irhCubsHcVjPHmL6bRkv0XfOzkllHUHwWLWP44aobQej2e4vOyazk1dwvQOJlqZuwEePw28W1QLRJusUWhBNmCcuzOEQkSK8fdxPGJ8AcdqikuwB5uCCjsBUvlTLtXXWMWxgSeNvuOSTNheCGWAWilXObYlrQLWajws3cflrUmSwIu10erdGlJgljXwsLfi5ws7aHLWhtX1qILGOlrol(wcampClPzbi1YUKMH6YTgCDKOdoQaPqH3K0MjmqIc0cfsKytvamSbY0erdGlJgdatzKhFmfxdW1oqOvRWf8fdqkqQLTOOUCd(8QGvYFn46irhCubsHcVjPntyGefOfkKiXMQayydKPjIgaxgngaMYiVkag2ahL5dkBEWICPwwMchaMTAvbWWgA0PzxWQsvaCkMwbGWbGP8xdUos0bhvGuOWBsAyEjmyAbg0uwEn46irhCubsHcVjPXHaWXsKytHl4lgQKgnkbn1Ych85vbRKrJSROIjkVaoumwQZOPjqXRcGHnQuKRGPIhaMRH1GrwIuIqcfsUdUgmYsmAG5HBjsb7ka0AjjCj(sW3O9sYttzhYsSeiAjgT8lHwlr73sQ8sGiBosBgUKkVeaiRwIdxIVeGifz0yjqtwiwcWjyiCjaW8WTeqChgmDjsbi0HW8wcIUKMH9Ws0yjDlxHKdUgCDKOdo0k4KK(LqljsSjWdd2fHfRgUqiJKon9QGhUDfaAv0OtLrIozSDyW0IdHoeMxHY2EEWP2KrEGNcCmgIIJhk2dlrJc0Yvi5GTAvbWWgk2dlrJc0Yvi5GdfsUtgnYUIkMO8ci4MWx(Rbxhj6GdTcI3K0ychhleEKOBn46irhCOvq8MKgt44yHWJeDfTG9dYsKytkUcGHnWeoowi8ir3GY2EEqWH)AW1rIo4qRG4njTRO85I84cfaAjrInb(kag2Wvu(CrECHcaTgaMYipWRriHcj3nKnfI8WvGMuMhaMTAb(Wf8fdztHipCfOjL5bFEvWk5VgCDKOdo0kiEtstrcrjS4sfDmuIeBQcGHnOiHOewCPIogoOSTNheCtnVvljDA6vbpOrTqzksiwdgzjGmSL4kfCjoLxcGPelbEPjVKWIxc64LixgwlrGKJHXsMnRzglXObYlrol(wIQrE4wcMddMUKWYVLiLsTLOySuNXsq0LixgwiGyj(1yjsPuBSgCDKOdo0kiEtsB7uzzvbdrlk2dlj0n0cUeofhhWjqLiXMOEQkSK8fdxPGdatzKx4uCCmI0MlbQOsgCAKDfvmr5fWHIXsDgTAbEyWUiSy1GIWbWYOr2vuXeLxahkgl1z00K2Sy7gRan5tzuGk)1GrwcidBjhAjUsbxICPqSevYlrUmSYBjHfVKJnwSKM3guILaa5LaIJ1mlbDlPIGWLixgwiGyj(1yjsPuBSgCDKOdo0kiEtsB7uzzvbdrlk2dljsSjQNQcljFXWvk4iVMAEBgf1tvHLKVy4kfCOaOEKOtgWdd2fHfRgueoawgnYUIkMO8c4qXyPoJMM0MfB3yfOjFkJc01GrwcycxXlP9kaO0glbDlbF8wcFSDYW1GRJeDWHwbXBs6QWvCbtaqPnKiXMGMSqucNIJdytt4ld4RayyJQWvCbtaqPngaMRbxhj6GdTcI3K04SqWq0OadAkllrInPr2vuXeLxahkgl1z00eO4vbWWgvkYvWuXdaZ1GRJeDWHwbXBsAztHipCfOjLzjsSjjDA6vbpQcxXfmbaL2OaBCAz4JP4AmI0MlbQy7gRj8xdUos0bhAfeVjPRcxXfka0sIeBssNMEvWJQWvCbtaqPnkWgNwg(ykUgJiT5sGk2UXAc)1GRJeDWHwbXBsAfLDvv4kgkrInbEyWUiSy1Wfcz0i7kQyIYlGGBc01GRJeDWHwbXBsAOLRqYzZcLej2e4Hb7IWIvdxiKrsNMEvWd3UcaTkA0PYir3AW1rIo4qRG4njnKnHjuIeBc8WGDryXQHleRbxhj6GdTcI3K0MOirNej2ufadBufiKsaaJbLDD0QfwIZkku22ZdcUM3wRwvamSHRO85I84cfaAnamxdUos0bhAfeVjPRcesvWaOnwdUos0bhAfeVjPRmfYuzZd3AW1rIo4qRG4njnws5QaHuRbxhj6GdTcI3K0(PzyqDrr7cXAWilPzymhqelbZfIQRLDjyi6saGEvWljd2gowdUos0bhAfeVjPbGCjd2gkrInvbWWgvbcPeaWyqzxhTAHL4SIcLT98GGBc)2A1sJSROIjkVaoumwQZaCt4VgwdgzjT38sOftHRbJSeWcJ(sq3s0iKqHK7wsGwISmBUKWIxIusZyjkUcGHTeaZ1GRJeDWbwEj0AQYHCmFLWIlCdgUgCDKOdoWYlHw4njnuKAU4NQOsnlrInvbWWgqrQ5IFQIk18GY2EEqWHL4SIcLT98GYubWWgqrQ5IFQIk18GY2EEqWjpqXtJSROIjkVak)2dOdq(AW1rIo4alVeAH3K0QeA6H2AnSgmYs6b7IWAn46irhCad2fH1KkHMEOTKiXM0i7kQyIYlGnnPnl2UXkqt(uRbxhj6GdyWUiSM0wSBwGwOqcDdTGlHtXXbCcujsSPWf8fdtk3OGUsyXf5yx2bFEvWkzaF4uCCmsyPIGW1GRJeDWbmyxew4njTBxbGwFxsMct09ZXVn8Bdu8BdK)D5C6Lho43bXKcGK5GS5TFP4swYmlEjPTjIglbdrxIXvmMdicJVekdsbskRwcezZlXbcKThSAjAl)WXWXAOzNhVK2jfxIuIojzAWQLyCn6uazmKkgFjbAjgxJofqgdPYGpVkyLXxI8a1yYFSgwdGysbqYCq282VuCjlzMfVK02erJLGHOlX4Af04lHYGuGKYQLar28sCGaz7bRwI2YpCmCSgA25XlbuP4sKs0jjtdwTeJtbogdrXXdPIXxsGwIXPahJHO44HuzWNxfSY4lrEGAm5pwdRbqmPaizoiBE7xkUKLmZIxsABIOXsWq0Ly8kqkugFjugKcKuwTeiYMxIdeiBpy1s0w(HJHJ1qZopEjGkfxIuIojzAWQLyCkWXyikoEivm(sc0smof4ymefhpKkd(8QGvgFjESeJUuTzVe5bQXK)ynSgaz2MiAWQLaIwIRJeDlrKWaowdFxKWa(Z(UIXCar8Z(5G(Z(URJeDFx2ul735ZRcw9G9Xph)F23DDKO77WGDry9D(8QGvpyF8ZB(p7785vbREW(oY87qo(URJeDFxsNMEvWFxsxaWFNg1sfaddUeWTe8xImlrElPcGHnQa0KvLGYoeGYdaZL0Q1sQayydCu)ufBwW8aWCjTATKkag2iOaCPYonpCdaZLi)VlPtlNBZFNg1cLPiH4JFE7(zFNpVky1d23rMFhYX3DDKO77s600Rc(7s6ca(7AKDfvmr5fWHIXsDglPPPLG)sWBjvamSrLICfmv8aWCjYSe(ykUglPPPLacTTezwI8wc4xIgDkGmgAeWfLWIliLco4ZRcwTKwTwsfadBqrcrjS4sfDmCqzBpp4sAAAjG22sK)3L0PLZT5V72vaOvrJovgj6(4Ndc)SVZNxfS6b77iZVd547Uos09DjDA6vb)DjDba)DOjleLWP44aoQcxXfmbaL2yjGBj4Vezwc1tvHLKVy4kfCK3sAAj432sA1AjvamSrv4kUGjaO0gdaZVlPtlNBZFVkCfxWeauAJcSXP)4NdI(zFNpVky1d2310myA6FhgSlclwnCH47Uos09DTlefxhj6kIegFxKWOCUn)DyWUiS(4N3((zFNpVky1d23DDKO77AxikUos0vejm(UiHr5CB(7Af8JFoi)N9D(8QGvpyFxtZGPP)DnYUIkMO8c4sAAAjAZITBSc0Kp1smQLubWWgvkYvWuXdaZLyulrElPcGHnqMMiAaCz0yayUK2ZscxWxmaPaPw2II6Yn4ZRcwTe5VKwTwIgzxrftuEbCjtlXV021wofhRkAZV76ir33PaxX1rIUIiHX3fjmkNBZFhlVeA9XpxQ)Z(oFEvWQhSV76ir331UquCDKORisy8DrcJY5283RaPq9Xph02(zFNpVky1d2310myA6FNpMIRXqXyPoJL000safewcElHpMIRXGY4477Uos09DNQ9JlbIs5l(4NdkO)SV76ir33DQ2pUyciG835ZRcw9G9Xphu8)zF31rIUVlsCwbS0ScOWzZx8D(8QGvpyF8ZbT5)SV76ir33RoUccRe0ull8785vbREW(4JVBsznYU6Xp7Nd6p77Uos09D30u0OyIsi6(oFEvWQhSp(54)Z(oFEvWQhSV76ir33TDQSSQGHOff7H1310myA6FN6PQWsYxmCLcoYBjnTK2123nPSgzx9Oazn6uWVdcF8ZB(p7785vbREW(URJeDFNIeIsyXLk6y4310myA6FNYyugA5vb)DtkRr2vpkqwJof874)XpVD)SVZNxfS6b77Uos09DOi1CXpvrLA(7AAgmn9VtzmkdT8QG)UjL1i7QhfiRrNc(D8)4Ndc)SV76ir33Hb7IW6785vbREW(4JVxbsH6N9Zb9N9D(8QGvpyFxtZGPP)DkWXyikoEe51OeiJL6sv4kEWNxfS67Uos09DOvk5h)C8)zF31rIUVZAluE4ku2KM2(P(oFEvWQhSp(5n)N9D(8QGvpyF31rIUVdzk1dwvQOJlqZuw(7AAgmn9Vd(LOqXaYuQhSQurhxGMPS8isTS5HBjTATexhPKCHp2oz4sMwcOlrMLq9uvyj5lgUsbh5TKMwcgGquOS2YP44sK28sA1AjAlNIJHlPPLG)sKzjyjoROqzBpp4sa3saHVRBOfCjCkooG)Cq)4N3UF235ZRcw9G9DnndMM(3RayydKPjIgaxgngaMlrMLiVLWhtX1yjGBjTdewsRwljCbFXaKcKAzlkQl3GpVky1sK)3DDKO77MjmqIc0cfF8ZbHF235ZRcw9G9DnndMM(3RayydKPjIgaxgngaMlrMLiVLubWWg4OmFqzZdwKl1YYu4aWCjTATKkag2qJon7cwvQcGtX0kaeoamxI8)URJeDF3mHbsuGwO4JFoi6N9Dxhj6(omVegmTadAkl)D(8QGvpyF8ZBF)SVZNxfS6b77AAgmn9VhUGVyOsA0Oe0ullCWNxfSAjYSenYUIkMO8c4qXyPoJL000saDj4TKkag2OsrUcMkEay(Dxhj6(ooeao(Jp(omyxew)SFoO)SVZNxfS6b77AAgmn9VRr2vuXeLxaxsttlrBwSDJvGM8P(URJeDFxLqtp0wF8ZX)N9D(8QGvpyF31rIUVRTy3SaTqX310myA6FpCbFXWKYnkORewCro2LDWNxfSAjYSeWVKWP44yKWsfbHFx3ql4s4uCCa)5G(XpV5)SV76ir33D7ka06785vbREW(4JVRvWF2ph0F235ZRcw9G9DnndMM(3b)sGb7IWIvdxiwImlrsNMEvWd3UcaTkA0PYir3sKzj2omyAXHqhcZRqzBpp4sMwsBlrMLiVLa(LqbogdrXXdf7HLOrbA5kKCWbFEvWQL0Q1sQayydf7HLOrbA5kKCWHcj3TezwIgzxrftuEbCjGBAj4Ve5)Dxhj6(UK(LqRp(54)Z(URJeDFht44yHWJeDFNpVky1d2h)8M)Z(oFEvWQhSVRPzW00)UIRayydmHJJfcps0nOSTNhCjGBj4)Dxhj6(oMWXXcHhj6kAb7hK)4N3UF235ZRcw9G9DnndMM(3b)sQayydxr5Zf5Xfka0AayUezwI8wc4xIgHekKC3q2uiYdxbAszEayUKwTwc4xs4c(IHSPqKhUc0KY8GpVky1sK)3DDKO77UIYNlYJluaO1h)Cq4N9D(8QGvpyFxtZGPP)9kag2GIeIsyXLk6y4GY2EEWLaUPL08L0Q1sK0PPxf8Gg1cLPiH47Uos09DksikHfxQOJHF8Zbr)SVZNxfS6b77Uos09DBNklRkyiArXEy9DnndMM(3PEQkSK8fdxPGdaZLiZsK3scNIJJrK2CjqfvYlbClrJSROIjkVaoumwQZyjTATeWVeyWUiSy1GIWbWlrMLOr2vuXeLxahkgl1zSKMMwI2Sy7gRan5tTeJAjGUe5)DDdTGlHtXXb8Nd6h)823p7785vbREW(UMMbtt)7upvfws(IHRuWrElPPL082wIrTeQNQcljFXWvk4qbq9ir3sKzjGFjWGDryXQbfHdGxImlrJSROIjkVaoumwQZyjnnTeTzX2nwbAYNAjg1sa97Uos09DBNklRkyiArXEy9XphK)Z(oFEvWQhSVRPzW00)o0KfIs4uCCaxsttlb)LiZsa)sQayyJQWvCbtaqPngaMF31rIUVxfUIlycakTXh)CP(p7785vbREW(UMMbtt)7AKDfvmr5fWHIXsDglPPPLa6sWBjvamSrLICfmv8aW87Uos09DCwiyiAuGbnLL)4NdAB)SVZNxfS6b77AAgmn9VlPttVk4rv4kUGjaO0gfyJtVezwcFmfxJrK2CjqfB3ylPPLG)3DDKO77YMcrE4kqtkZF8Zbf0F235ZRcw9G9DnndMM(3L0PPxf8OkCfxWeauAJcSXPxImlHpMIRXisBUeOITBSL00sW)7Uos099QWvCHcaT(4Ndk()SVZNxfS6b77AAgmn9Vd(Lad2fHfRgUqSezwIgzxrftuEbCjGBAjG(Dxhj6(UIYUQkCfd)4NdAZ)zFNpVky1d2310myA6Fh8lbgSlclwnCHyjYSejDA6vbpC7ka0QOrNkJeDF31rIUVdTCfsoBwO(4NdA7(zFNpVky1d2310myA6Fh8lbgSlclwnCH47Uos09DiBct4h)CqbHF235ZRcw9G9DnndMM(3RayyJQaHucaymOSRJL0Q1sWsCwrHY2EEWLaUL082wsRwlPcGHnCfLpxKhxOaqRbG53DDKO77MOir3h)Cqbr)SV76ir33RcesvWaOn(oFEvWQhSp(5G2((zF31rIUVxzkKPYMhUVZNxfS6b7JFoOG8F23DDKO77yjLRces9D(8QGvpyF8ZbvQ)Z(URJeDF3pnddQlkAxi(oFEvWQhSp(5432p7785vbREW(UMMbtt)7vamSrvGqkbamgu21XsA1AjyjoROqzBpp4sa30sWVTL0Q1s0i7kQyIYlGdfJL6mwc4Mwc(F31rIUVda5sgSn8Jp(owEj06N9Zb9N9Dxhj6(ELd5y(kHfx4gm8785vbREW(4NJ)p7785vbREW(UMMbtt)7vamSbuKAU4NQOsnpOSTNhCjGBjyjoROqzBpp4sKzjvamSbuKAU4NQOsnpOSTNhCjGBjYBjGUe8wIgzxrftuEbCjYFjTNLa6aK)Dxhj6(ouKAU4NQOsn)XpV5)SV76ir33vj00dT135ZRcw9G9XhF8DhiSq0V3tBP8Jp(ha]] )

end