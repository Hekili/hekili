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
            aliasMode = "longest", -- use duration info from the buff with the longest remaining time.
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

        master_assassins_mark = {
            id = 340094,
            duration = 4,
            max_stack = 1,
            copy = "master_assassin_any"
        },


        -- Guile Charm
        shallow_insight = {
            id = 340582,
            duration = 12,
            max_stack = 1,
            copy = "guile_charm_insight_1"
        },
        moderate_insight = {
            id = 340583,
            duration = 12,
            max_stack = 1,
            copy = "guile_charm_insight_2"
        },
        deep_insight = {
            id = 340584,
            duration = 12,
            max_stack = 1,
            copy = "guile_charm_insight_3"
        },
    } )


    spec:RegisterStateExpr( "rtb_buffs", function ()
        return buff.roll_the_bones.count
    end )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )


    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        sepsis  = { "sepsis_buff" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld", "sepsis_buff" }
    }


    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )
            
            elseif k == "sepsis" then
                return buff.sepsis_buff.up
            elseif k == "sepsis_remains" then
                return buff.sepsis_buff.remains
            
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
        return legendary.mark_of_the_master_assassin.enabled and 4 or 0
    end )

    spec:RegisterStateExpr( "master_assassin_remains", function ()
        if not legendary.mark_of_the_master_assassin.enabled then
            return 0
        end

        if stealthed.mantle then
            return cooldown.global_cooldown.remains + 4
        elseif buff.master_assassins_mark.up then
            return buff.master_assassins_mark.remains
        end

        return 0
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.all and ( not a or a.startsCombat ) then
            if buff.stealth.up then
                setCooldown( "stealth", 2 )
            end

            if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
                applyBuff( "master_assassins_mark" )
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
            reduceCooldown( "marked_for_death", cdr )
        end
    end )


    local ExpireSepsis = setfenv( function ()
        applyBuff( "sepsis_buff" )
    end, state )

    spec:RegisterHook( "reset_precast", function( amt, resource )
        if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end
        if debuff.sepsis.up then
            state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
        end
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

                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end
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
                local use_combo = combo_points.current == animacharged_cp and 7 or combo_points.current

                if talent.alacrity.enabled and use_combo > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                applyDebuff( "target", "between_the_eyes", 3 * use_combo )

                if azerite.deadshot.enabled then
                    applyBuff( "deadshot" )
                end

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end

                if legendary.greenskins_wickers.enabled and use_combo >= 5 then
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
                if target.is_boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

            nodebuff = "cheap_shot",

            handler = function ()
                applyDebuff( "target", "cheap_shot", 4 )

                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end
                
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
            gcd = "off",

            talent = "marked_for_death", 

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return combo_points.current <= settings.mfd_points, "combo_point (" .. combo_points.current .. ") > user preference (" .. settings.mfd_points .. ")"
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

            toggle = "cooldowns",

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

    spec:RegisterSetting( "mfd_points", 3, {
        name = "|T236340:0|t Marked for Death Combo Points",
        desc = "The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer.",
        type = "range",
        min = 0,
        max = 5,
        step = 1,
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

    spec:RegisterSetting( "allow_shadowmeld", nil, {
        name = "Allow |T132089:0|t Shadowmeld",
        desc = "If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  " ..
            "Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat).",
        type = "toggle",
        width = "full",
        get = function () return not Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 260 ].abilities.shadowmeld.disabled = not val
        end,
    } )     


    spec:RegisterPack( "Outlaw", 20210307, [[d8uF)aqiqIhrQsxIqb1Muv1NaPAuQQ4uQQ0QiusEfbzwOKUfPQYUa8lruddKYXivSmukpJujtdKexJqP2gPk4BKkvghPsrNJuPW6ajP5rQk3Ja7tvrheKuleLQhkIyIek6IQkuBuvH4JekGtsOeRuvPxsOGmtsLs3ueP2jHQFsQu1qjvrhLqj1sjuONc0urjUkPk0wvvi9vsvvnwrKSxu9xfnyPomLfRkpwutMKlJSzu8zqmAs50cRMqb61euZMOBls7wPFdz4k44KQQSCOEUktxY1b12fHVRqgVQcopHmFfQ9t1CD4SWbvwrCXzdASPd00f00DaSXgurxqf9ahSenqCWbllSbH4GRLsCqDpCjTrCWbtKezkolCWdbJZehuRQHdQMCYqIsd(bKrPjFrkS0QaTzSXujFrAozo4doKLyz5poOYkIloBqJnDGMUGMUdGn2Gk6cQWgh0GlneMdcgPjHdQfkfT8hhurxMdQ7HlPnYBXiccm5FtAdN18w3XQ3Sbn20HdkJRoolCqfXyWYIZcxCD4SWbTCfOLdkCKfMdsR9KKIZoV4IZgNfoiT2tsko7CqfDzCmubA5GIr6kYKLM3bJ3dO7INK8(Nf5Dcy5sy7jjVPLsd68owVZO0Nv)YbTCfOLdEfzYsJxCX1fNfoiT2tsko7Cq0ah8OIdA5kqlhmHHd7jjoyctctCqC9MpygMZB95nBE)37F8gkE)GzyakmmnFKHJfca8G3)9gkE)GzyaEyKPUqraWdE)lhurxghdvGwoOyKWiP07lwisY7hmdZ5nzyPiVrLgH9U0S1BwWWK3StgowiEBRYB2XitDHI4Gjm8CTuIdIR3etyKuYlU4qfolCqATNKuC25GObo4rfh0YvGwoycdh2tsCWeMeM4Gzu6dnhqXwhGIyICuE)PaVzZBH8(bZWa8WitDHIaGh8(V30syiI8(tbEl2qZ7)E)J3qX7mAvWrbKrWBnlnAIuQdGw7jjL3Jh79dMHbaJKYzPrZhAPdatPwSN3FkWBDGM3)Ybv0LXXqfOLd(X7bJjVhrEdHkVzGLsVH60h8P5Ds0tVHyXEEBRYBdtl0lVXegjLXcX7KGG3Y7sJ8w3RuN3pygMZBBKjIdMWWZ1sjoOL(GpTzgTQOc0YlU4InNfoiT2tsko7Cq0ah8OIdA5kqlhmHHd7jjoyctctCWmk9HMdOyRZ7pf4DEyMAFyEd0Q8w)8(bZWa8WitDHIaGh8w)8(hVFWmmaOHbeUG3Oebap4TyL3LjPTa0FWrw4PcBJaO1Ess59VEpES3zu6dnhqXwN3c822i1YAggcPM5boOIUmogQaTCWpsSXP5TvENAFisHt9oj6P3p4YBlbkuEpYUkwiEZogzQluK32Q8wSgoYc7TyITrE)ql85DgL(qEpGITooycdpxlL4GmXgN2mJwvubA5fxC9aNfoiT2tsko7Cq0ah8OIdA5kqlhmHHd7jjoyctctCWBGKYzzyiuDapPPOjJegJf5T(8MnV)7n2c1KsqBbyk1beR3F6nBqZ7XJ9(bZWa8KMIMmsymweaMsTypV)0BD8wiVltsBbiCiLXczEdyIaO1EssXbv0LXXqfOLdQ)JsZ7uyzfdsY7YWqO6y17sloVty4WEsY748oRrzHjL3fYBfLdf59inQ0iS3hkL8ojI559PHGLkVFK3NOntkVhfLM3Slnf59hrcJXI4Gjm8CTuId(KMIMmsymw08eTzEXfx3XzHdsR9KKIZohmJJIWHXbVImzPrkatk5GwUc0YbXW70YvG2PmUIdkJRMRLsCWRitwA8IlUUjNfoiT2tsko7CqlxbA5GztkNwUc0oLXvCqzC1CTuIdMvhV4IRBWzHdsR9KKIZohmJJIWHXbty4WEscGj240Mz0QIkqlh0YvGwoigENwUc0oLXvCqzC1CTuIdYeBCA8IlUoqJZchKw7jjfNDoOLRaTCWSjLtlxbANY4koOmUAUwkXbFWHuXlU46OdNfoiT2tsko7CWmokchghKwcdreGIyICuE)PaV1rS9wiVPLWqebGji0YbTCfOLdA4ST0SqymTfV4IRdBCw4GwUc0YbnC2wAoalpIdsR9KKIZoV4IRJU4SWbTCfOLdkdiA1nfdcRGKsBXbP1EssXzNxCX1bQWzHdA5kqlh8zqMiMzHJSWhhKw7jjfNDEXlo4aMYO0NvCw4IRdNfoOLRaTCqByqkAoGIdTCqATNKuC25fxC24SWbTCfOLd(qvjj1KrAIi1OyHml0hILdsR9KKIZoV4IRlolCqlxbA5GxrMS04G0ApjP4SZlU4qfolCqATNKuC25GwUc0YbtnSWKAYGWtfzLghmJJIWHXbXwOMucAlatPoGy9(tVztS5GdykJsFwnpkJw1XbfBEXfxS5SWbP1EssXzNdA5kqlheJKYzPrZhAPJdMXrr4W4Gyk1I98wFERlo4aMYO0NvZJYOvDCq24fxC9aNfoiT2tsko7CqlxbA5GNmY00w1ufzIdMXrr4W4GyIbtNM9KehCatzu6ZQ5rz0QooiB8IxCWhCivCw4IRdNfoOLRaTCWJgU44G0ApjP4SZlU4SXzHdA5kqlheIg6kPO5v4qyIdsR9KKIZoV4IRlolCqATNKuC25GzCueomoigEjgegcbuXkAwOpe55tAkcGw7jjfh0YvGwo4Pfj4fxCOcNfoOLRaTCqkRHIfYetd4i1wfhKw7jjfNDEXfxS5SWbP1EssXzNdA5kqlh8im2ksnFOLM3qimXbZ4OiCyCqO4TcvahHXwrQ5dT08gcHjGkYchleVhp2BlxrcAslLg05TaV1X7)EJTqnPe0waMsDaX69NEZalLtmL1mmeAwrk594XEN1mme68(tVzZ7)E)q359FVzciA1etPwSN36ZBXMdMfLL0SmmeQoU46WlU46bolCqATNKuC25GwUc0YbhIRqY5PHkoOIUmogQaTCq94rERNXviP3GAOY7rrP5TUFyaHl4nkrEhmENeu6ZkV1turBwK3Jql0lVrjiC2g8MwcdreREpsJwVJY7rHu6n9blxsrENTbVtIEYQ3iS3J0O1B4lwiElwdhzH9wmX2ioyghfHdJd(GzyaqddiCbVrjcaEW7)E)J30syiIauetKJY7p9(hVPLWqebGji06TqERd08(xVhp27mk9HMdOyRdqrmrokV1NaV1XBH8(bZWa8WitDHIaGh8E8yVltsBbO)GJSWtf2gbqR9KKY7F5fxCDhNfoiT2tsko7CWmokchgh8bZWaGggq4cEJsea8G3)9(hVFWmmaqWeTNWXEZrrwycFaWdEpES3pyggGmAZKjj18jHxfHFW3bap49VCqlxbA5GdXvi580qfV4IRBYzHdA5kqlh8InUIWZRWHWehKw7jjfNDEXfx3GZchKw7jjfNDoyghfHdJdwMK2cqf4s0SWrw4dGw7jjL3)9oJsFO5ak26auetKJY7pf4ToElK3pyggGhgzQluea8ah0YvGwoieemeIx8IdMvhNfU46WzHdsR9KKIZoh0YvGwo4tAkAYiHXyrCqfDzCmubA5GSlnf59hrcJXI8gTEZMqEtlLg0XbZ4OiCyCWBGKYzzyiuDE)PaVzZ7)EdfVFWmmapPPOjJegJfbapWlU4SXzHdsR9KKIZoh0YvGwoycBJtJdQOlJJHkqlhupEXcXBOo9bFAEhN3M3Sjg27yZyYoIvVpK3FuBJtZ7STE)iVpukvrkDE)iVHps5TDEBEdxHmkrEFdKu6n8kP78g(IfI3jTDfH9gQVZUlwVryVftYknPiVb1mfA0XbZ4OiCyCqO4ngEjgegcbKAyHNiMzPrZu7kcpT7S7IfGw7jjL3)9gkEFfzYsJuaMu69FVty4WEscWsFWN2mJwvubA9(V3)4nu8gdVedcdHauKvAsrZtZuOrhaT2tskVhp27hmddGISstkAEAMcn6auOrR3)9oJsFO5ak268wFc8MnV)LxCX1fNfoiT2tsko7Cq0ah8OIdA5kqlhmHHd7jjoycdpxlL4GjSnoTzQnZOvfvGwoyghfHdJdIHxIbHHqaPgw4jIzwA0m1UIWt7o7UybO1Ess59FVHI3LjPTasnSWKAYGWtfzLgaT2tskoOIUmogQaTCq9FuAEN02ve2BO(UZUlww9(eTzV)O2gNM3JIsZBZBMyJtJWEJWEd1Pp4tZBfnqRkwiEJwVzV(yVZiKuHgTS6nc7TjhzIoVnVzInonc79OO08oPzetoyctctCWF8gkENriPcnAbEunIODwA0KerhaMmLiV)7Dcdh2tsamXgN2mJwvubA9(xVhp27F8oJqsfA0c8OAer7S0OjjIoamzkrE)37egoSNKaS0h8PnZOvfvGwV)LxCXHkCw4G0ApjP4SZbrdCWJkoOLRaTCWegoSNK4GjmjmXbty4WEscGj240Mz0QIkqlhmJJIWHXbXWlXGWqiGudl8eXmlnAMAxr4PDNDxSa0ApjP8(V3LjPTasnSWKAYGWtfzLgaT2tskoycdpxlL4GjSnoTzQnZOvfvGwEXfxS5SWbP1EssXzNdMXrr4W4GjmCypjbKW240MP2mJwvubA9(V3P2veEA3z3f7etPwSN3c8gAE)37egoSNKaEstrtgjmglAEI2mh0YvGwoycBJtJxCX1dCw4G0ApjP4SZbZ4OiCyCqO49dMHbWuyAnzS0edFAaWdCqlxbA5GMctRjJLMy4tJxCX1DCw4G0ApjP4SZbZ4OiCyCqO49vKjlnsbysP3)9(hVHI3df27XJ9oHHd7jjaMyJtBMrRkQaTEpES3LHHqfqfP0SqtvqERpV1rxE)lh0YvGwoiJ0GqsPvbA5fxCDtolCqATNKuC25GzCueomoOIEWmmamsdcjLwfOfatPwSN36ZB24GwUc0YbzKgeskTkq7mljBpIxCX1n4SWbP1EssXzNdMXrr4W4GqX7RitwAKcWKsV)7DgL(qZbuS15T(e4nBE)37F8gkENrjO12cibTLMiS3Jh7TIEWmmamsdcjLwfOfaEW7F5GwUc0YbvyYupPPOJxCX1bACw4G0ApjP4SZbZ4OiCyCWu7kcpT7S7IDIPul2ZBbEdnV)79dMHbqHjt9KMIoafA069FV)X7hmddagjLZsJMp0shaMsTypV1NaV1L3Jh7Dcdh2tsa46nXegjLE)lh0YvGwoigjLZsJMp0shV4IRJoCw4G0ApjP4SZbTCfOLdMAyHj1KbHNkYknoywuwsZYWqO64IRdhmJJIWHXbXwOMucAlatPoa4bV)79pExggcvavKsZcnvb5T(8oJsFO5ak26auetKJY7XJ9gkEFfzYsJuayeeyY7)ENrPp0CafBDakIjYr59Nc8opmtTpmVbAvERFERJ3)Ybv0LXXqfOLdkwy82uQZBdtEdpWQ33gdK3Lg5nAjVhfLM3s0i6kVzHfXeWB94rEpsJwVvIIfI3m2ve27sZwVtIE6TIyICuEJWEpkkneC5TTI8oj6jaV4IRdBCw4G0ApjP4SZbTCfOLdMAyHj1KbHNkYknoOIUmogQaTCqXcJ3lYBtPoVhfsP3QG8EuuAX6DPrEV0hkV1f0ow9g(iVtAgX0B069dDN3JIsdbxEBRiVtIEcWbZ4OiCyCqSfQjLG2cWuQdiwV)0BDbnV1pVXwOMucAlatPoafm2QaTE)3BO49vKjlnsbGrqGjV)7DgL(qZbuS1bOiMihL3FkW78Wm1(W8gOv5T(5To8IlUo6IZchKw7jjfNDoiAGdEuXbTCfOLdMWWH9KehmHjHjoiu8gdVedcdHasnSWteZS0OzQDfHN2D2DXcqR9KKY7XJ9oJqsfA0cKW240aWuQf759NERd08E8yVtTRi80UZUl2jMsTypV)0B24Gk6Y4yOc0YbH6QO0HY7c59jAZElgkKYyH4n4aMiVhfLM3FuBJtZBge27K2UIWEd13z3flhmHHNRLsCqHdPmwiZBat0mHTXPnprBMxCX1bQWzHdsR9KKIZoh0YvGwoOWHuglK5nGjIdQOlJJHkqlhupEK3X6To6hBS4DW4n71h7DCEdp4TTkVhHwOxENTbV)4LWqeXQ3iS3w5TUyriV)HnweY7rrP5TyswPjf5nOMPqJUF9gH9EKgTEN02ve2BO(o7Uy9ooVHha4GzCueomoycdh2tsapPPOjJegJfnprB27)ENWWH9KeGWHuglK5nGjAMW240MNOn79FVHI3xrMS0ifagbbM8(V3)4TIEWmmapQgr0olnAsIOdaEW7)E)GzyauyYupPPOdqHgTE)3BAjmerakIjYr59NE)J30syiIaWeeA9wSYB28wiV1rS9(xVhp27BGKYzzyiuDapPPOjJegJf59NE)J3S5T(59dMHbqrwPjfnpntHgDaWdE)R3Jh7DQDfHN2D2DXoXuQf759NEdnV)LxCX1rS5SWbP1EssXzNdMXrr4W4GjmCypjb8KMIMmsymw08eTzV)79pEtlHHicOIuAwOzQ9bV)0B28(V3pyggafMm1tAk6auOrR3Jh7nTegIiV1NaV1f08E8yVVbskNLHHq159NEZM3)YbTCfOLd(KMIMy4tJxCX1rpWzHdsR9KKIZohmJJIWHXbHI3xrMS0ifGjLE)37egoSNKaS0h8PnZOvfvGwoOLRaTCWtZuOrPKuXlU46O74SWbP1EssXzNdMXrr4W4GpyggGNeHus4RaWKLlVhp27h6oV)7ntarRMyk1I98wFERlO594XE)GzyamfMwtglnXWNga8ah0YvGwo4aQc0YlU46OBYzHdA5kqlh8jri1KbglIdsR9KKIZoV4IRJUbNfoOLRaTCWhHpclCSq4G0ApjP4SZlU4SbnolCqlxbA5GmbMEsesXbP1EssXzNxCXztholCqlxbA5G2MPRWMCMnPKdsR9KKIZoV4IZgBCw4G0ApjP4SZbTCfOLdcF0mkk94Gk6Y4yOc0YbftIXGLL3z0QIkq75ndc7n8zpj5Duu6bWbZ4OiCyCqO4ngEjgegcbKAyHNiMzPrZu7kcpT7S7IfGw7jjL3)9wrpyggGhvJiANLgnjr0bap49FV)XBO4DzsAlaiAORKIMxHdHjaATNKuEpES3k6bZWaardDLu08kCimbap49VEpES3P2veEA3z3f7etPwSN3F6n08E8yVFO78(V3mbeTAIPul2ZB9jWB2GgV4fh8kYKLgNfU46WzHdsR9KKIZohmJJIWHXbty4WEscGj240Mz0QIkqlh0YvGwoOkUbRYA8IloBCw4GwUc0YbT0h8PXbP1EssXzNxCX1fNfoiT2tsko7CqlxbA5GznYgMNgQ4GzCueomoyzsAlGbmjAI2zPrZrKjmaT2tskV)7nu8UmmeQaIB(q3XbZIYsAwggcvhxCD4fV4GmXgNgNfU46WzHdsR9KKIZohmJJIWHXbFWmmaNmY00w1ufzcatPwSN36ZBMaIwnXuQf759FVXedMon7jjoOLRaTCWtgzAARAQImXlU4SXzHdsR9KKIZoh0YvGwo4JQreTZsJMKi64Gk6Y4yOc0YbzV(yVrR3zesQqJwVlK3ct0G3Lg5DsWr5TIEWmmEdpWQ3WRKUZ7sJ8UmmeQ8ooVThcU8UqERcIdMXrr4W4GLHHqfqfP0SqtvqE)P36IxCX1fNfoOLRaTCqvCdwL14G0ApjP4SZlEXloyccFbA5IZg0ythOXg0yJdoYWBSqooO(hQfJIlwexmau1BVzrJ8oshq4YBge2BORigdwwq3BmP)GdmP8(qPK3gCHsTIuEN1SfcDa(xDBSK3qfOQ3jbTjiCrkVHEgTk4OaskO7DH8g6z0QGJciPaO1EssbDV)rNp8lG)1)Q)HAXO4IfXfdav92Bw0iVJ0beU8MbH9g6z1bDVXK(doWKY7dLsEBWfk1ks5DwZwi0b4F1TXsEZgu17KG2eeUiL3qhdVedcdHaskO7DH8g6y4LyqyieqsbqR9KKc6E)dBF4xa)RUnwYBDbv9ojOnbHls5n0XWlXGWqiGKc6ExiVHogEjgegcbKua0ApjPGU3)OZh(fW)QBJL8gQav9ojOnbHls5n0XWlXGWqiGKc6ExiVHogEjgegcbKua0ApjPGU3)OZh(fW)QBJL8whDbv9ojOnbHls5n0XWlXGWqiGKc6ExiVHogEjgegcbKua0ApjPGU3)OZh(fW)QBJL8Mn2GQENe0MGWfP8g6y4LyqyieqsbDVlK3qhdVedcdHaskaATNKuq37F05d)c4F9V6FOwmkUyrCXaqvV9MfnY7iDaHlVzqyVH(doKkO7nM0FWbMuEFOuYBdUqPwrkVZA2cHoa)RUnwYBDbv9ojOnbHls5n0XWlXGWqiGKc6ExiVHogEjgegcbKua0ApjPGU3w59hR71TE)JoF4xa)R)vSKoGWfP8wp4TLRaTElJRoa)lh8gOmxC20dqJdoGrmHK4G6vVER7HlPnYBXiccm5F1RE9oPnCwZBDhREZg0yth)R)vV617p(dugUiL3pIbHjVZO0NvE)iiXEaEd15mnuN3lA1pndNYal92YvG2ZB0kfb4FTCfO9agWugL(SsGnmifnhqXHw)RLRaThWaMYO0Nvcji5hQkjPMmstePgflKzH(qS(xlxbApGbmLrPpResqYxrMS08VwUc0EadykJsFwjKGKtnSWKAYGWtfzLgRdykJsFwnpkJw1jqSznyeGTqnPe0waMsDaX(jBIT)1YvG2dyatzu6ZkHeKmgjLZsJMp0shRdykJsFwnpkJw1jGnwdgbyk1I90NU8VwUc0EadykJsFwjKGKpzKPPTQPkYeRdykJsFwnpkJw1jGnwdgbyIbtNM9KK)1)Qx969h)bkdxKYBkbHf5DfPK3Lg5TLle27482syH0EscW)A5kq7jq4ilS)vVElgPRitwAEhmEpGUlEsY7FwK3jGLlHTNK8MwknOZ7y9oJsFw9R)1YvG2tibjFfzYsZ)QxVfJegjLEFXcrsE)GzyoVjdlf5nQ0iS3LMTEZcgM8MDYWXcXBBvEZogzQluK)1YvG2tibjNWWH9KeRRLscW1BIjmskznHjHjb46nFWmmN(y7)pq5bZWauyyA(idhlea4H)q5bZWa8WitDHIaGh(1)QxV)49GXK3JiVHqL3mWsP3qD6d(08oj6P3qSypVTv5THPf6L3ycJKYyH4DsqWB5DPrER7vQZ7hmdZ5TnYe5FTCfO9esqYjmCypjX6APKal9bFAZmAvrfOL1eMeMeKrPp0CafBDakIjYr9Pa2e6bZWa8WitDHIaGh(tlHHi6tbIn0()duYOvbhfqgbV1S0OjsPUXJFWmmayKuolnA(qlDayk1I9(uGoq7x)RE9(JeBCAEBL3P2hIu4uVtIE69dU82sGcL3JSRIfI3SJrM6cf5TTkVfRHJSWElMyBK3p0cFENrPpK3dOyRZ)A5kq7jKGKty4WEsI11sjbmXgN2mJwvubAznHjHjbzu6dnhqXw3NcYdZu7dZBGwL(9GzyaEyKPUqraWd63ppygga0WacxWBuIaGheRktsBbO)GJSWtf2gbqR9KK63XJZO0hAoGITob2gPwwZWqi1mp4F1R36)O08ofwwXGK8UmmeQow9U0IZ7egoSNK8ooVZAuwys5DH8wr5qrEpsJknc79HsjVtIyEEFAiyPY7h59jAZKY7rrP5n7strE)rKWySi)RLRaTNqcsoHHd7jjwxlLe8KMIMmsymw08eTzwtysysWnqs5SmmeQoGN0u0KrcJXI0hB)XwOMucAlatPoGy)KnOnE8dMHb4jnfnzKWySiamLAXEFQJqLjPTaeoKYyHmVbmra0ApjP8VwUc0Ecjizm8oTCfODkJRyDTusWvKjlnwdgbxrMS0ifGjL(xlxbApHeKC2KYPLRaTtzCfRRLscYQZ)A5kq7jKGKXW70YvG2PmUI11sjbmXgNgRbJGegoSNKayInoTzgTQOc06FTCfO9esqYztkNwUc0oLXvSUwkj4bhsL)1YvG2tibjB4ST0SqymTfRbJaAjmerakIjYr9PaDeBHOLWqebGji06FTCfO9esqYgoBlnhGLh5FTCfO9esqYYaIwDtXGWkiP0w(xlxbApHeK8ZGmrmZchzHp)R)vV61B2HdPIWN)1YvG2d4bhsLGJgU48VwUc0Eap4qQesqYq0qxjfnVchct(xlxbApGhCivcji5tlsWAWiadVedcdHaQyfnl0hI88jnf5FTCfO9aEWHujKGKPSgkwitmnGJuBv(xlxbApGhCivcji5JWyRi18HwAEdHWeRzrzjnlddHQtGoSgmcGIcvahHXwrQ5dT08gcHjGkYchlKXJTCfjOjTuAqNaD(JTqnPe0waMsDaX(jdSuoXuwZWqOzfP04XznddHUpz7)dD3FMaIwnXuQf7PpX2)QxV1Jh5TEgxHKEdQHkVhfLM36(HbeUG3Oe5DW4DsqPpR8wprfTzrEpcTqV8gLGWzBWBAjmerS69inA9okVhfsP30hSCjf5D2g8oj6jREJWEpsJwVHVyH4TynCKf2BXeBJ8VwUc0Eap4qQesqYdXvi580qfRbJGhmddaAyaHl4nkraWd))HwcdreGIyICuF(dTegIiambHwH0bA)oECgL(qZbuS1bOiMihL(eOJqpyggGhgzQluea8W4XLjPTa0FWrw4PcBJaO1Ess9R)1YvG2d4bhsLqcsEiUcjNNgQynye8GzyaqddiCbVrjcaE4)ppyggaiyI2t4yV5OilmHpa4HXJFWmmaz0MjtsQ5tcVkc)GVdaE4x)RLRaThWdoKkHeK8fBCfHNxHdHj)RLRaThWdoKkHeKmeemeI1GrqzsAlavGlrZchzHpaATNKu)ZO0hAoGIToafXe5O(uGoc9GzyaEyKPUqraWd(x)RE1R3jbHKk0O98V61B2LMI8(JiHXyrEJwVztiVPLsd68VwUc0Eaz1j4jnfnzKWySiwdgb3ajLZYWqO6(uaB)HYdMHb4jnfnzKWySia4b)RE9wpEXcXBOo9bFAEhN3M3Sjg27yZyYoIvVpK3FuBJtZ7STE)iVpukvrkDE)iVHps5TDEBEdxHmkrEFdKu6n8kP78g(IfI3jTDfH9gQVZUlwVryVftYknPiVb1mfA05FTCfO9aYQtibjNW240ynyeafm8smimeci1WcprmZsJMP2veEA3z3f7FOCfzYsJuaMu(pHHd7jjal9bFAZmAvrfO9)pqbdVedcdHauKvAsrZtZuOr34XpyggafzLMu080mfA0bOqJ2)zu6dnhqXwN(eW2V(x96T(pknVtA7kc7nuF3z3flREFI2S3FuBJtZ7rrP5T5ntSXPryVryVH60h8P5TIgOvfleVrR3SxFS3zesQqJww9gH92KJmrN3M3mXgNgH9EuuAEN0mIP)1YvG2diRoHeKCcdh2tsSUwkjiHTXPntTzgTQOc0YAWiadVedcdHasnSWteZS0OzQDfHN2D2DX(hkLjPTasnSWKAYGWtfzLgaT2tskwtysysWpqjJqsfA0c8OAer7S0OjjIoamzkr)ty4WEscGj240Mz0QIkq7VJh)tgHKk0Of4r1iI2zPrtseDayYuI(NWWH9KeGL(GpTzgTQOc0(R)1YvG2diRoHeKCcdh2tsSUwkjiHTXPntTzgTQOc0YAWiadVedcdHasnSWteZS0OzQDfHN2D2DX(VmjTfqQHfMutgeEQiR0aO1EssXActctcsy4WEscGj240Mz0QIkqR)1YvG2diRoHeKCcBJtJ1Grqcdh2tsajSnoTzQnZOvfvG2)P2veEA3z3f7etPwSNaO9pHHd7jjGN0u0KrcJXIMNOn7FTCfO9aYQtibjBkmTMmwAIHpnwdgbq5bZWaykmTMmwAIHpna4b)RLRaThqwDcjizgPbHKsRc0YAWiakxrMS0ifGjL))bkdfE84egoSNKayInoTzgTQOc0oECzyiuburknl0ufK(0rx)6FTCfO9aYQtibjZiniKuAvG2zws2EeRbJaf9GzyayKgeskTkqlaMsTyp9XM)1YvG2diRoHeKSctM6jnfDSgmcGYvKjlnsbys5)mk9HMdOyRtFcy7)pqjJsqRTfqcAlnr4XJv0dMHbGrAqiP0QaTaWd)6FTCfO9aYQtibjJrs5S0O5dT0XAWii1UIWt7o7UyNyk1I9eaT)pyggafMm1tAk6auOr7)FEWmmayKuolnA(qlDayk1I90NaDnECcdh2tsa46nXegjL)6F1R3IfgVnL682WK3WdS69TXa5DPrEJwY7rrP5TenIUYBwyrmb8wpEK3J0O1BLOyH4nJDfH9U0S17KONERiMihL3iS3JIsdbxEBRiVtIEc4FTCfO9aYQtibjNAyHj1KbHNkYknwZIYsAwggcvNaDynyeGTqnPe0waMsDaWd))PmmeQaQiLMfAQcsFzu6dnhqXwhGIyICuJhdLRitwAKcaJGat)ZO0hAoGIToafXe5O(uqEyMAFyEd0Q0pD(1)QxVflmEViVnL68EuiLERcY7rrPfR3Lg59sFO8wxq7y1B4J8oPzetVrR3p0DEpkkneC5TTI8oj6jG)1YvG2diRoHeKCQHfMutgeEQiR0ynyeGTqnPe0waMsDaX(PUGM(HTqnPe0waMsDakySvbA)dLRitwAKcaJGat)ZO0hAoGIToafXe5O(uqEyMAFyEd0Q0pD8V61BOUkkDO8UqEFI2S3IHcPmwiEdoGjY7rrP59h12408MbH9oPTRiS3q9D2DX6FTCfO9aYQtibjNWWH9KeRRLsceoKYyHmVbmrZe2gN28eTzwtysysauWWlXGWqiGudl8eXmlnAMAxr4PDNDxSJhNriPcnAbsyBCAayk1I9(uhOnECQDfHN2D2DXoXuQf79jB(x96TE8iVJ1BD0p2yX7GXB2Rp2748gEWBBvEpcTqV8oBdE)XlHHiIvVryVTYBDXIqE)dBSiK3JIsZBXKSstkYBqntHgD)6nc79inA9oPTRiS3q9D2DX6DCEdpa4FTCfO9aYQtibjlCiLXczEdyIynyeKWWH9KeWtAkAYiHXyrZt0M)NWWH9KeGWHuglK5nGjAMW240MNOn)hkxrMS0ifagbbM()JIEWmmapQgr0olnAsIOdaE4)dMHbqHjt9KMIoafA0(NwcdreGIyICuF(dTegIiambHwXk2eshX(3XJVbskNLHHq1b8KMIMmsymw0N)WM(9GzyauKvAsrZtZuOrha8WVJhNAxr4PDNDxStmLAXEFcTF9VwUc0Eaz1jKGKFstrtm8PXAWiiHHd7jjGN0u0KrcJXIMNOn))hAjmeravKsZcntTp8jB)FWmmakmzQN0u0bOqJ2XJPLWqePpb6cAJhFdKuolddHQ7t2(1)A5kq7bKvNqcs(0mfAukjvSgmcGYvKjlnsbys5)egoSNKaS0h8PnZOvfvGw)RLRaThqwDcji5bufOL1GrWdMHb4jriLe(kamz5A84h6U)mbeTAIPul2tF6cAJh)GzyamfMwtglnXWNga8G)1YvG2diRoHeK8tIqQjdmwK)1YvG2diRoHeK8JWhHfowi(xlxbApGS6esqYmbMEses5FTCfO9aYQtibjBBMUcBYz2Ks)RE9wmjgdwwENrRkQaTN3miS3WN9KK3rrPhG)1YvG2diRoHeKm8rZOO0J1GrauWWlXGWqiGudl8eXmlnAMAxr4PDNDxS)v0dMHb4r1iI2zPrtseDaWd))bkLjPTaGOHUskAEfoeMaO1EssnESIEWmmaq0qxjfnVchctaWd)oECQDfHN2D2DXoXuQf79j0gp(HU7ptarRMyk1I90Na2GM)1)Qx969hj240i85FTCfO9ayInonbNmY00w1ufzI1GrWdMHb4KrMM2QMQitayk1I90htarRMyk1I9(JjgmDA2ts(x96n71h7nA9oJqsfA06DH8wyIg8U0iVtcokVv0dMHXB4bw9gEL0DExAK3LHHqL3X5T9qWL3fYBvq(xlxbApaMyJttibj)OAer7S0OjjIowdgbLHHqfqfP0SqtvqFQl)RLRaThatSXPjKGKvXnyvwZ)6F1RE9gSitwA(xlxbApGRitwAcuXnyvwJ1Grqcdh2tsamXgN2mJwvubA9VwUc0EaxrMS0esqYw6d(08VwUc0EaxrMS0esqYznYgMNgQynlklPzzyiuDc0H1GrqzsAlGbmjAI2zPrZrKjmaT2tsQ)qPmmeQaIB(q3XlEX5a]] )

end