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

        vendetta_regen = {
            aura = "vendetta_regen",

            last = function ()
                local app = state.buff.vendetta_regen.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 20,
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
        control_is_king = 138, -- 354406
        death_from_above = 3619, -- 269513
        dismantle = 145, -- 207777
        drink_up_me_hearties = 139, -- 354425
        enduring_brawler = 5412, -- 354843
        float_like_a_butterfly = 5413, -- 354897
        maneuverability = 129, -- 197000
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
            duration = function() return 3 * effective_combo_points end,
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
            duration = function() return ( 1 + effective_combo_points ) end,
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
            duration = function () return 6 * ( 1 + effective_combo_points ) end,
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
            alias = { "instant_poison", "wound_poison" },
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


        -- PvP Talents
        take_your_cut = {
            id = 198368,
            duration = 8,
            max_stack = 1,
        },


        -- T28
        tornado_trigger = {
            id = 364235,
            duration = 3600,
            max_stack = 1
        },
        tornado_trigger_loading = {
            id = 364234,
            duration = 3600,
            max_stack = 6
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


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364555, "tier28_4pc", 363592 )


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

    spec:RegisterStateExpr( "cp_gain", function ()
        return ( this_action and class.abilities[ this_action ].cp_gain or 0 )
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

            if legendary.obedience.enabled and buff.flagellation_buff.up then
                reduceCooldown( "flagellation", amt )
            end
        end
    end )


    local ExpireSepsis = setfenv( function ()
        applyBuff( "sepsis_buff" )

        if legendary.toxic_onslaught.enabled then
            applyBuff( "shadow_blades", 10 )
            applyDebuff( "target", "vendetta", 10 )
        end
    end, state )

    spec:RegisterHook( "reset_precast", function( amt, resource )
        if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end
        if debuff.sepsis.up then
            state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
        end

        class.abilities.apply_poison = class.abilities.apply_poison_actual
        if buff.lethal_poison.down or level < 33 then
            class.abilities.apply_poison = state.spec.assassination and level > 12 and class.abilities.deadly_poison or class.abilities.instant_poison
        else
            if level > 32 and buff.nonlethal_poison.down then class.abilities.apply_poison = class.abilities.crippling_poison end
        end
    end )

    spec:RegisterHook( "runHandler", function ()
        class.abilities.apply_poison = class.abilities.apply_poison_actual
        if buff.lethal_poison.down or level < 33 then
            class.abilities.apply_poison = state.spec.assassination and level > 12 and class.abilities.deadly_poison or class.abilities.instant_poison
        else
            if level > 32 and buff.nonlethal_poison.down then class.abilities.apply_poison = class.abilities.crippling_poison end
        end
    end )

    spec:RegisterCycle( function ()
        if this_action == "marked_for_death" then
            if active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
            if debuff.marked_for_death.up then return "cycle" end -- If current target already has MfD, cycle.
            if target.time_to_die > 3 + Hekili:GetLowestTTD() and active_dot.marked_for_death == 0 then return "cycle" end -- If our target isn't lowest TTD, and we don't have to worry that the lowest TTD target is already MfD'd, cycle.
        end
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

            cp_gain = function ()
                return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 3 or 2 ) )
            end,

            handler = function ()
                gain( action.ambush.cp_gain, "combo_points" )
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
                if talent.alacrity.enabled and effective_combo_points > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                applyDebuff( "target", "between_the_eyes", 3 * effective_combo_points )

                if azerite.deadshot.enabled then
                    applyBuff( "deadshot" )
                end

                if legendary.greenskins_wickers.enabled and effective_combo_points >= 5 then
                    applyBuff( "greenskins_wickers" )
                end

                removeBuff( "echoing_reprimand_" .. combo_points.current )
                spend( combo_points.current, "combo_points" )
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

            spend = function () return ( talent.dirty_tricks.enabled and 0 or 40 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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

            cp_gain = function () return buff.shadow_blades.up and 2 or 1 end,

            handler = function ()
                applyDebuff( "target", "cheap_shot", 4 )

                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

                if talent.prey_on_the_weak.enabled then
                    applyDebuff( "target", "prey_on_the_weak", 6 )
                end

                if pvptalent.control_is_king.enabled then
                    applyBuff( "slice_and_dice", 15 )
                end

                gain( action.cheap_shot.cp_gain, "combo_points" )
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

            spend = function () return 20 + conduit.nimble_fingers.mod end,
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

                removeBuff( "echoing_reprimand_" .. combo_points.current )
                spend( combo_points.current, "combo_points" )
            end,
        },


        distract = {
            id = 1725,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 30 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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

            cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) end,

            handler = function ()
                applyDebuff( "player", "dreadblades" )
                gain( action.dreadblades.cp_gain, "combo_points" )
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

            spend = function () return 35 + conduit.nimble_fingers.mod end,
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

            cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) end,

            handler = function ()
                applyDebuff( "target", "ghostly_strike", 10 )
                gain( action.ghostly_strike.cp_gain, "combo_points" )
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

            cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) end,

            handler = function ()
                gain( action.gouge.cp_gain, "combo_points" )
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

            spend = function () return 25 * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132298,

            handler = function ()
                applyDebuff( "kidney_shot", 1 + combo_points.current )
                if pvptalent.control_is_king.enabled then
                    gain( 15 * combo_points.current, "energy" )
                end
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

            cp_gain = function () return 5 end,

            handler = function ()
                gain( action.marked_for_death.cp_gain, "combo_points" )
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

            cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) + ( buff.opportunity.up and 1 or 0 ) + ( buff.concealed_blunderbuss.up and 2 or 0 ) ) end,

            handler = function ()
                gain( action.pistol_shot.cp_gain, "combo_points" )

                removeBuff( "deadshot" )
                removeBuff( "opportunity" )
                removeBuff( "concealed_blunderbuss" ) -- Generating 2 extra combo points is purely a guess.
                removeBuff( "greenskins_wickers" )

                if set_bonus.tier28_4pc == 1 then
                    if buff.tornado_trigger.up then
                        removeBuff( "tornado_trigger" )
                    else
                        if buff.tornado_trigger_loading.stack > 4 then
                            applyBuff( "tornado_trigger" )
                            removeBuff( "tornado_trigger_loading" )
                        else
                            addStack( "tornado_trigger_loading", nil, 1 )
                        end
                    end
                end
                removeBuff( "tornado_trigger" )
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

                if pvptalent.take_your_cut.enabled then
                    applyBuff( "take_your_cut" )
                end
            end,
        },


        sap = {
            id = 6770,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( talent.dirty_tricks.enabled and 0 or 35 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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

            cp_gain = function () return ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) end,

            handler = function ()
                gain( action.shiv.cp_gain, "combo_point" )
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

            cp_gain = function () return debuff.dreadblades.up and combo_points.max or ( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) ) end,

            -- 20220604 Outlaw priority spreads bleeds from the trinket.
            cycle = function ()
                if buff.acquired_axe_driver.up and debuff.vicious_wound.up then return "vicious_wound" end
            end,

            handler = function ()
                removeStack( "snake_eyes" )
                gain( action.sinister_strike.cp_gain, "combo_points" )

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


    spec:RegisterPack( "Outlaw", 20220611, [[Hekili:nVvBZTnos6FlU26uKgBRikhLm7uwQQK4mtLC7mtUrzVD)KPGiHK4yksD8f7OQuPF7x3aGK4vszNKnZxsKjbB0OrJUF6xWTE3(PBNhskO3(BJhnE8Ox65n0B8Krt(XBNxSFh9257ib3rwd)iHSf(3FVSiM8a(49XPKq8ZZtlZcGxTPOyx(p98NVoQyt5YHbPBFEE02YysruAsqgzvb(3bp)25llJIlEFYTlTo3x9QBNtkl2KMD785rBFlq5OWqkF408GkM44I)iDDj94h(qzc94cVrxCCbsOJF44hE7gsYAA(pD8dxECXVsUdE)phtZ3WyJJlIskOzzL7y)84cGvxsWFV64IhGH(NL5WFfgfcpc(XQ0SJlUpfxiXu)8047PjfdVDECuErotasxrkJlGF(BmbkjaxY3o)UOG7UDonHSmMgE7BUTawP47BEcBbLfTJp()GMxqjXfB4SYU088iyGhx0pjf4GY4eAgH9aAcDBenxM9h0mVcQGZ3vAZx6o410IMXEpjlcFl(R4s4)Ykw6VSC1kG4xdc0Jl6bZ)XfNDCb(0HlZGT98Oq6WYDsVld2da50AkSVNeatpn0FzCzsinBzzE(qblCCXHdn0k)UY4yFssOFqgSwxMMqZzKDGvkhLCF060myBizTF(gsy6dHWoLDAxKvs9xsHvxY6kAoGpePv40QviFTvMfb8DrgLKxMvVczVBDgYNBPXu85gBCzPXXhx8MpDCX5hx8l)6XfOotom34ULyYaMjEp8MInu4LfGkk8fvItq59tVbu)IWD)51lUl4uAEYBRE3BAKQSDpF(btCrLXydCB)fp6TDujk1FxkC0iFiOqhfGQ(Z4cOZDT5d6HzR3Zh3Krs7AGwqyzubOnuMu4dRy)0Wqn1agjroM9E(UFgDljkjNtrpGId0e1Vlb3A4NtxtXtNLOK)1BbbciDE7hHhZPaSFb)tgn5zWO4Igy)agcYsO8hOWVdmv9(d5bYEzrkHrtFCPeXMCqWo5lsWYxwb783s(SF(okYHxAv2EjtqYEr6UDPzfLjrf7zV6haEhoFbMG()kbdm(HzKhSiyTFouCsahfD1kkW03t9BNf12a(5OKiusJgmHXiBMcf(OsAAj8U07PzRItFGjZHn3YCULQu8lWzcuTltaJY5clSVP4DWNVjkajEmSxaVihOvmSQwcuFY54miVbTIXkQBqV0Ygug15wKtsnhwXGtIicUdMgdhhtgUKw8aLMWuxP7zARKW98dcoeMGj0jAcWxlwBKIc6w0fubiskZPcjakx5l1lq121KSqUqkDLq9Mc2nEGag5X17RE0kKWMkEKJaMuHJ6lJjHu)vXLzz7LS4NrIc9PmhDe8Gl6Nzg6Fvsdt(tLo4cNBzwmekP3fXo3b6szGPZkovvK8Vyw2aScfr7qfjbZDbEkncOz1Aa83HArBOb3H66OGlKgaNzqfhk3UAE6wuv8gnTN89WXHWgJOKqgMaK3L1dKxt(43GY4Futg3OAi80sdhsadV1YCWNLp)3(iiboubXmi5C(VRr3QppGGUfD89bH5436nYjtvjTgAQuFkmi)RyZH3tHbr0DHSpxhStdlY9BO6NXBctTr8kqZNkXWKSasc1VindmOxWO(vYqTeVFxzCovdYL3lKhyC06nf5()zz46TiL0g7e5XUKS2pDfGhamZMRos4db9zoYldCFKD7I3JMaYX)Ye)xn9tlkqd0RIj7PHOLsyb(5i9VrzHwP(OoeD)9vJElj7oCcsZ8dPe8ZA2dCDeFI0sZpNIApWIFInVFsheGtAlJschUdaTucWKPi8AGhu9mvpmd401ggQy9v141TzwVwrwb(GYYRYGeyt7kRlPX2SFwlNJJcOmSPHry0nYeEf4qzd3MQdYwuDmqx1iNUlpkVJGcAMRqkh85M08cqLkhufVJ2yR96PS1wfXvhMn4)sRIAy1aC69m9UaFM1pZTI8nr3BtlRHANjT1cUclZrpHKKOTeWmraaAgqTNMPQluBMY0MB9mtd2KIhlYO7YaILeAtlSr2Mbtdc4b0fa)nOmqZ1lEWeqt)M5CNhee6OWzJe0fc6wbf8WpHNdtDkSs3Fb(t6kywyyAQ)UW9S)opfMwWbeOXYX3tzFkCeCF1G1ezHPfdTW0(4ZlaBoazBt33669rpbZd2haNdfRguDTTtfDlInq1aEMt4bs)qekVdi70qckWQpp5gUdEeS1fIaLEicPXDuk8rRYs3Y((DmbEWgKNvo0VcTU7RC(ycxBRgeNLLWqeRRGAmO3IF7VkJVWjXCAnA44AYzlCjoYzm(dgiQoJZTocky3yl6DZNHOgHq1oUdRbg0RjMH1awRKCy)n3)byFMMXNVti4G6HaNxtGOqrVFRxtZ4ro0OjSdC4NgdHHNw0gug5HPQO8pX91pYEngWBArf2SFVzzXZdYBfPN5JPf0Ka4HpKYIPdJWGPmXLHxyQQr)mWh4jE2WyiQXin4dRmNPf9)GbrDCXnzyATojjSb4fvqlSi08goPoFecGWpqj7st2Ia3LSe2ZLUeQV55k0BKYTee4aRieRpeJa8aMOYpHPfaD5ajaMLmqBH8zW4rgyCpZmjiSn05cAd)IrCqGNyZelZ64Bjb4)Dt6N4B0ShcFwYDyG9OLaysQXH6K9vrW52zQqGfgLvSxaQ7e2hM5EFqYZBA5Ak3VpIpVYRVfHVSZonbOsqjCb34ZRZ1NcAl5q4QZsJKfhLqZ4crD5sfdDpHb3xFVKD2OkRk4wb4uC8)fMWXam9yy(QYbd4)VeE2acWKzXIZcc)cnMLZ)tWdqi3lk89LaIp2PAg)3e(V4K4Vs4AoVopNKNJ2qXdR3G4wzETzjflxZfxdogeRldUoGgKFkZNiOKY28JlNI8pqjop2dRrVONLiRPUmKVieZGT8GPpc0xLHwj3QWyXb8hvUDRcWLVDdci7564jjofhS0d2O1G9L2S5e9cEm6nQuCVbGAdpGuCWO(qLoziftoftXbf6SCNu5KxyNVklsk0Gt2FD1n1jePkJLDNLhNrwxNuT(psczQ9mWgs7UZQtlb9)LS725wB7AwTgZynlB5lztUgJ1GRdHIPkhBjgcHbolaPvmKWD0fMbVpocqgMb7lk241ENnyYQjkvQGtSeC(rEOXhx8orSXCVEji0NAdmcSWjn4H0Yvvdt3xkORVWWURk5IvtD9D6xrq9otO4aD6ykNf5K2oAyMfV51vTZpALugh0xtkdC7wAyewJX5EwtTG0yxhNUKeJd0c07MpLSgwTe9twUeCTyXGz6pf9)1RcHu9cpmIYKDExXw52crthXDh8Iv3isLRbKCeqFafGB2NX5or2hKxZgLNRdde1GGRTkAmsHvrPylcXhX0J6kvNDBHG7CTHGnow73rfOyjxrlvfnvztHH1YcvBPo1mJCStbbGPuiMH2XIRNXUMqsCO(yhrRyhPrhjJvh92HaBu0kpZAZ9EmHjSkQrWs0vUd9PNeTJkG2NI1PNBulo9bkwK9p9PBgECX)SjpbIKPSsapGxLuSSh1CtAMCQAs2JVEOvO)UL5gSnwGDoRZJCKjbXzbHHYy(e6NH57QrS6wH8laHGd9GFi2KL6oxRxnIjk1FByzgP2j4xLDQooOxF4u5OUsjDg1HjHBRtj)Jc2YJhbVc)Y9TBLtDAAa9N0wsR4Oq)VJeLlgtXBTABf2uM)C94vKbdPu1lFbaNQ6j55kD9kFLTWRr9gVlhlIxMH5LhMSa2GiZiS0D8UQSIWGcJ6UFcIMS)y8F5Rg9qRgiNEeZOX4Z0qRq4mWFPcpZP4Onv8(1QBgiPL7mdRg3TKJM(wstdV3gWkpnOBSmCAmUPK96XSjvC920(gvDC5eGgBxU2VnKs9AGzjlAeISZCFgUbaMW53ilYej8yQP0OctSNR0vBnrdOTxr4)VxkuCTwGHzVnjnBlMi2401rb8JcG1sbyk8GlRUWSpEl5prf53Et(q7H)CkH9BAQ0fa5tjxaUmXwfrOcAk59nNaPKhKGoIH0cUnUINEClpvrKvhkTegrnVBuxhft4V0CXYRBM86S1e6JnfeqCEE89Xdj1TVWaBrg65ov7pUDC5IMHISTurTWDdxxeyvAAymkFHLyqHw0b6L1O5SzNrTUlL9)ycahjNfv2e6VQedPSHTWHPKS1L0mq(YluK6WuQK9QOmkJI6JsTi9jbaOVmsSFaRDjuhQlNIpab5LhaEwXw8iVa2KDMkutd2WHdwIRRTEHcnhOXE5Oof7VQQpyTWu4AWvPjdWmDJqBQZKEvtgM3AY2BkjJBEclyVO1qAzwqUZzHeHfso(DRWdszGQel36R0lNiVywUgS)lofU9QrvCR7zf5vxvGuuEapn)i3WBb3JlQpjMlqPvMJ0aRkeDRQ7G2axWkWcFQgw4nCdj3hCc5ZlkCRlrmY6rSLGBBkN8mp(XpZ6skr7iu13iwknHfyhU7COWO8DKIGn1LuO(WnZsO2HA9acQppSHs2jQkyGEbAamI79t5ILhOK7mt3mly3OCFuuyn7if1TXuBLIrt8RxogeDnIRGx8zEfRYqWKvnhalaxei(F8Xk0Xc42mnVFPUiSsT6iVgxmEvuxLL8cILYc6COQ8WmQ(zSKs0o6y5ZBVqyYR2VULsdRjF7QcYN9iihpdlLamzy17JDltuEKCmJUlxh3AJsB4OSY0u)7HDlPuN5uBCtTrEk06NQA9zffxMg09WIbhJ46jm6fGzFswc4leuv(xV(p(T3)B)YpDCXXfFc3tJ2I1kwS1)mXvc4zitXTfx1zIKYI0TiEfwBgG3sHHh)W)ictnYv)ewS7eyEzV(zns5)9Z4AiYpQso)mmOUppOMkVqJkvTIDnnQFGmf8yu44h6yDv3VtpUv2enEQo5T1mvZtm5QViAGr((UF)FC6lXGW8h3IB8tEB7kPL3tFZ3RLn)NgvE1ttuROg(31OHW4EnfQ(Bx8G3xhbI3l)s5dDc8e5dDz6tJmJ1jtfubpPvudUL)TX3)Jo((Xw((XYFFNNB4oCFChD8EYcLXNgtX6cZhhp9K170T0y)e5PEwY7RYzPJF49m5b(zqy1CVEhxWU6AWRzXpfGHgmc7L10vrORZ)2F74cT7yh(il3Zo8Xn31o8V(MDF7QMU39zAqjB9Se3dOnKBjDnGey4XfVoiGUdd2ljn5YnKSTRkJRw75yo7J3dKt83dRDPnvUVTT8(ZN(CxDST9rlWCB)L6fL4cJwjE6KlIwn1my1zJNyNKn11e)qN1g(WbN1o1oDvlVLfgDmJr5iXU(khcdfCyUjsneoZnCqkW6Lww6CyaPHjcvwy4OVNefZcEPE(NIxatGiGw8x0nRSMGY7PmQ(D5A)jZovrSDbgt90MYtEbR(ktRVQJxpUx)ZmAGn4zzTFXnpCG)voAH1bkuWrkdROH2vYCWGdhQ5VPJ7X5oJRGzpr4iYx)sM0)B8nb0TuwpNFczTTkYnB64ZnL68KSpB6KrG4Z(nL8WHwQn9SPEJgWKbFNVmEULr6jqWImA2u5kvEPHy6Y(ShP2dU)GZUEviXC1zZGYM97ONkBWKQF9UHEpcbu6UPS7PiAfSJwiRN9vY1tyC)33ltN7vSrPSe6eUZGly0YM3VrITAB3)WzEN329ouM70UdCCMuyEN5)ujR)sFO(TFJ)LqyJDsD(MosC39fuNtedsR8WuVBCi1vR(jyUyY5kL(08JzxCo5NRDp5KFLY1IRYl9BqUIM1idgY4ZP8c3O9uGiQ3vjKPB9UoD90RmPbEVKyGgCExMm)gJkpHe4St4YlD4qlfLLz1478LlYI8XSYySv7jCTGonIPK51PENoXrX1)XVOqN2Acwdkzw86PtoC4uV9qxAEZHUEkERHqsycpyQ42c1Rvqw9mR1)mpZfJ0vTbxewCE2RV7u72H7tXRnVuqCCi)f8Y880eqAwoLTA(dEdHTXZSCBE6zBV96PEMq)oCWj(fjb5x9lrJfnF1lrJTtYmM3(n)Pt6zXEpEdzqY2YTWXQCCMn5yDUheNlZzcV2Vann8e4QwbncZBVmkea2U4iPEdpZ3J(l7LJrznYqGvb44StQn761D0C9otbyupNTcHsOHATkLWCITl9IIsW1thpqcu73)lnIPawgIRLlYGk(Kwf9D0k1c4YyeJThDGtSLqmq9p5pwF7CW3WL(PTY7gZSHwFBxXKEo6rVPJ61gsp1PsR1ByN04gonVHdSa2)wCPq0zk18a2)PKiWb6hZ7B1EiqHwIEBq1xzkmGOXnb1mEWfwU6gO3iTlPHYJKt1P78zwjzAAjoROx1w0ov5adyacTEMvO)AVRmoPi1PEwMen7DSucP2tDhoyVJ(q5RJJoaqLoUXfgCPwwEbg19beU1BTgVvaV0EoRGa4KIGQjrLCZ7FhV5a6IbJ8YlUFgtb4F2uzmVug96BrTWg0gytsRVNDGasjrzEnISVb3AHofh2ljXvJU01TyO3tArA9yqR3tHzEJCEqXmIZNCx(3UBqNn6UWh2PbdtALQEdhyRrhhlNnUjcI)kCpb0fukIgfNZgEz719fhWuRQV7UQZH9kTG96ReT34Z9MmOn)BZ6p(sROyzjB21M0id7UnTpFhcL(2CzkItrTt)7DM9ZbvEDbJXJ0wAZg3yw5BAd57gSw3HEOBr4XelslnGFJBujXOShuJwThEPdlnwGjF6RpdtEgOW6Ud6N9szoxUV57inwM9m)SXMARnT1UfOmUVieAuH3v61zzqR73fGRutd3vvP93gYA9tuv92UXBQBNDdKHvDWUbcFLMwx)TyR5IDwm36VzxHBKAbvtiATN(HdwCT(YrwLhVQDwPLEb3AYD454ZCAK71aBZJZU4UjuO27yChB2mJrNAxDRZIvnjUuzfS4v4WHMMNsUnRTYrthpYXSm(uNLXN4SWtT1pls(Gi1wFxAg5Mvmp(NP6RpEc90b7o7k3oJRwPVa01BPjIfU1CKQ6ZA9t5rHyRNJhOVGo3OVuQoByVXJVwz7QNs3Qyq5QwlUAhDUE7ajmEoTAGk()DNKdXNH2M4P1YYBAAWEBXS0rJ2JPIktUf7X2H(2))d]] )


end
