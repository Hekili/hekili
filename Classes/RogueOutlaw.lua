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


    spec:RegisterPack( "Outlaw", 20220604, [[Hekili:nZ1EZTnso(plP26uKgBROhrj7oLLQkV2PsUDMj3OS3U)LOOiBjXXuKA5J4OQuPp7ha6MK9tkzNjxM)jXMSjAa0Ob(b0n8IHl(0I5H(fSf)YObJgn4fdEE)HVC8lhnEX8Id7zlMV3p4o)nWpK4Vd(3FTSi2)E8XhIt9dXpppTmlaE12II95)4ZE2MOITLR6hKU7z5r7kJ9lIstcY8xxG)EWZwmFvzuCX7twSY(CpCXC)YITPzlMppA3BakhfgY4dNLhuXeNw(BPBkzN(WhktyNw(8RpTePZPpC6dVzRFYgw(pE6d3CA5p7Fh86)EmlFlXfNwgLuWYYk3t)4PLaNUYh)51NwEpm0FVmh(TWOq4rWpSon70YpNIYrmZlpn(ZSKI(lMhhLxKt6p2A)Y4c4h)fsF6hGs8I53ffC3I5Se)vXSWfVErbiO47BEcjpzr75J)3y5fm)4ITCwzFAEEemWtl7MKcCqzCclZNEalHTlILlZ(9AMxbvW5BS28LUhEnROzSF2plcFl(tXLW)LvSYBv561aXVfuONw2bM)tlFYPL4t7Vkdw1ZJcz9l3l9Umyja0tByWYEsam9SqVvXLjHSSvL559fSWPLhp2qR87kJJ98tc9cYazDvAclNiBpRuok5ZrBsZGLHKnE5B9dtVpewPSt7ISsM3kgiDjBQOzp(qKKWPvsix2kZIa(UiJ5NxMvlH072KH85owmdFUXcxwAC8PLV(tNwE1PL)0pFAjAZKdZnUAjMmGzIpaVPyldEzbyIcFrL6emE)0RbZViC1FETWDnNsZtEt17EDJwLw9847lrHkJydCz)5p4LD0ik1BFkS1iVpyqhfGM(Z4kORCT4d2HzBoWh3KbsRAGvqyzubynuMu4bsSxAyOMzarsKJP3Zx9Zy78JsY5uCiqXEAQ63LGln89PBy4UZsuZ)QDGcb0oV5JWJ5uawVG)jJL8uyuCvdSEadbzju)du4xbMQE9X)E)dYQuFIMEOOertoOyN8vPy5IvWEVD(FXlFpd5WBSQBVHuK0ls3VpnROmjQ4a9QFa4Dy)f4c6)ucoy8cZ8V3II1((qXobCuS1Rzat)zMx7SO2cWFpkjc10OdtymYUPqLpAKMwcVl9ZSS1XP3t6CyXTmN7Pkf)cCMat7YeWPCUWd7RlEh85BJcqIhdRfWlYbAfds1kG6tUcNb5fO1eROUa9cllqzmNlroj1CqIHGer(4kyAmSDmP)kwX9mwczUYoqwR(Hh4BeCOmbxOt0uGVsiB(ffSDyiOcqLuMZeAauVYf1RrZ2n(zHCLu6AH5nd8BCVp4KhL3x(GniHfvClNp4sf2QVk2pK5ToUml7GKh)m)OqpgfOZh34IXzMHXxLSWK)uPnUW(wYJHWi9UiAFhylLbUoR4uvvY)I8SbqfkI2JgscM7ACxAeqZkzaI3HwrBzb3H26OIlKfa7zqdhg3VAE6o0u8TAwp5hGTdHnor9djmbiVlBhiltE43G64)QMoUX0qePLf23hC8wRZHywE8F2dbjWHkiMbPGZ)nn6w95b(yyrhFFqyo(Tdh4KPQ0w9nnQVegK)v0Cm8XWGi4Uq6Z1b70WI84gQXzgoHmBeVcS8zsmSFwGFcZRindCOxquFSmulX73xgNZ0GCn85YdmoAZ2ICVFVmCZoKsAJDI8yx5VXlDnGhaCZMRos4db7zoYldCF(73hFaDbKJ)Mj(VA6NwuGoOxh7FGfIEkbb8lr6FJIGwz(Ooe949vJENF2D4eKM5fY8XpRznW1w8jsIMxodTEaHFITOFsBeGDARIsc7VhaTucWKzi8AGhuJmvpmd401ogQy91141T5wV2qwb(GI4v5qc8Pn2QinYM)ZA9CCuaJWMggHj3it41qaLTCFQoiBr92OkBdltHE4enNIu0a0f3Dm2EbEL3KH7wczO)xiOX(R5zk8BFK7zKEaglLcO(tGd3K87aLGuOwImC)R8VXFffUM8LgX6llP8H1ViAhUZduemYczCfopoFylSyJQ)5cm31O43uZvE3d7RyzsOc70GF3YWqSlci(xm54ymHKjrP3dxTIYrRschKTeYAKEEkkkMbks2A0tIx9tWGMYwgomK03phgLV3ViyRH7f0pFBgpsbQ0nCKdUb2dW(6rxvNZOYUwzOa1O9LwfucXdP9yrH1GZGS3vzL)zob)RcDozVbZX)fM4AaMMfM3toy69)6ZrvgGjfrXRHW4OHxo)xb8riAE(3xcEoa0WWGq(VX2UKpB)mIncS)FvEUpannHVL4TO)pm)lEYvk6bflk0Nj52hmN3rKYZxqjDl1hqUP8pqbVa9W6G16zBynf4qUqiMbB5tPpce4krknCP8L6Ep4AeubuIVCdki7yMFuQtbIr9GwTcAuAXMt0R5y9AmP4i(8XnS4dWbJ2dv2KHmmjhYWbv6Kx3ke)cVPvzJOqdoz)51VTgyDvMVNpBbNi0QtoR7dKqMwp9EC1bOfWJFnRUNDPTDlRwXEuZYw(sAY1ySgF2WMGbQ6rt8)6o4SagrXrcTl0peGP6d59W8YG1fQIr1OdvFNnqiQjClv4skU(h5qSoT8DcmwCqajPfsoye1)GEO1CEAy6Us4Y(kHVvv6oRU666mUIG6NnX0E60XuplQTbpjIkKluDkMj84nVU6VErRLqUQltkdC3owyewQ65dTcrvASBItx5hJd0sQJnFQ)gqA913z5sX1IhdY1FAEUyFMjKnq3nCmj5bhca5tOHrSfwsc9m8I1WisL9d0C(G9aQa3EiJZDcCIYYSrzEpJdIAKF1EfngPWROuDWdXhr2rNlL5Z7HGhCTHGnbw7EMkzI6OXC(VEvSPATkmSw2mTLcUzMD0UGaWv6W(tSSu3sMFnvY3H5J9IdlwrASrYOJJr3krnlFJIFo0SgVVh8M5tvM1hl1lLvtEs0EMi9Lu84E4o1ItVNHhwZN(0B7FA5)mNxjiyHj8afsFTaEaVA7y5ZQ5M0mPQv6NCaFDFR1TWTo3GTXdQHZ63hHlUKgeNfegkX8jSVaZ34buszi)cqi4qp4BInzPZNZ(4bKQu)THLz(1bb)dzL6mB0R3CQSvxP0GdoJlHMs78GGT8WrWRWV8y7w5uNUgW4j6L2vUKUCuO)3rIJDalvqTzBf2ukEUE(kYGHuQEQNaGtvDjh6QSpkFLrkzm(Xgo8MrFIJCGW8YRFGa2W9P0PMe4dp4DuS0kOWOT7NGSj7oc)xU0ONAvpXMlAJOz2y8zQVviCg4VuHN5uD0MjElvQq(e(S6C3OqLe5KRrjDGm8ZidRGzVZJLHtJrnh9JEoBshstBwFdQ2UCbqJTRx72gsPonWSKvncv2tCVhUbaMi43al6ej8yQL0Oct8qxL8ZAHgqFVI0)FVuQ4AhLk5VnjnBNFmg6ytuaFRa4TuaMc34sNVa9X78)D0q(nVnVV90FUK0(nDv6cG8LulaxUyRYiubnL86MtGuYdsqhXqAb3g3WtpVLhRkYAaLwsJOM3zbBtr6MX2NfTdCDP4c)fMcBoBFEKICk9QmGlXZlfWxaEyIUdqBJxqHmywqJwpCts9XG1ZwMHdDFurpSvCP6hsQSDmXzQ4gUUiXQ00Wyu)cIyqHw2bALS82M9MNnR19P0)JfaCGYzyGtO36smLYg2chMYrISILb6xCxL(WuorK1rzmII6Js9WEscaqFz(XEb0XUPouxbfVhsYlpaISIhvyEbSi7SuOMoSHnhaRf249IkQTD0yVyWzv7VS66uzHPqzq3JELme4hGxLI1E(b)NsodjUSk5gMc1dX)lSA)YTWt4b)ioIXwMfK7C5zgfKC87wJBKYatjpyzkAnZwjsCoyVNFjC74bvCR7zf5vxNVdmIK7yfd1IJ8w(v5IFbwODI5cuAL5inWBegBNA4G2axGsHyQ6xmS)w)CpiiKh)8BAveXmRhqIGBFkx8mp6HpZ6AkXXAvD(JwoAclWoCFc01N7rH2HIY9eQTPwpHG69dBz(7HOkPfQNBff9dWiEWlLRwUN5FNz5MPKDJY9qvH1QJuuDC26hXlpoIURNZTqTzBAEbc0d0P3X0krqdXvhMn53wGwia7b68Jd8i3xMhPA(2OpVWsvHvdsvvpm261aIQpJNDfeAf8feWIzWwS0mvSexsTtnItVWsfDB0TgbI1ZZcpGDaB3RNZrSrHtRDn3KbDZrLINCem1PGKIPYaMgRHzHa5v)DIsgKNctlMQZArLdy0NcjvEOAWAQSW0cBOh8WNxeryjxyPSXTkVp4jWAX9CE62NxfBC7K4PZfvuvAdk5qLB0Li5X5jVLNKx1rOaQWS7JqAWpk71zP7OVFpPW5ORucGzXL0KlaUgwVcb1OSRe)mgzGeCe2psRb9hvtoBL)Gx9d8EeQKgKZ7RAhN5r1ArG3hbr8JfUVmts)J0RXuyAkI)V2Cza55U)gXDx(JPfSKGd1PUJx)oAfIvL(U(6h7laFGBJOHrx3SMS2f5s9)G3Wqib)m8kFRHVq)EjQKpPCcZgzlpS)KAK5cF1G)59Pj8SD1YEY2ceUio019sLI85(gssPU46QxLJbSWmUf(EBToQgWSGzcCyMzEbHP1Z5cAd)erCEv)mDBXVPhigmqZNkQrd)EBWdfxvcLf1f12j7ReFYOyYgHmdJYkoiUWtxWYWm3ldsrZsl3WOyPGvoODW7FH4g)pzaOpV3plbm2G9))Rx9B)Y7)LF6hpT80YpHYB0o0etaa7PIRz)tXlAbxNxDB)8lls3HodOT84n)V)Pp8pIWYep(hX9ijW8sV(PnXl)3pL7Ct(rvY8tXcC9LE1u55AuP66nxtJ6hitHHefo9HZix13HOhMKnrJNQdCxZunpXKR(QOb6W5D)6)4YfXGW8hMWn6rVSnws8E8l(dBzX)XrLx(4u1kMH)nnAi21wtHQF3fpm8pgfYWx81Yh6e4rYh660hhzgPtMQ0Mgkjrn5W9Vn(()QJVFKLVFK83F29n88NEyBDg(OvkJUmMIYi6HXtpA7oDpn23rEP7LKPHXI2fBdF6dVN0h4N9cGfP4CNwsTdg8A8sHMUocpCQ)YFbqSP2RA4Jm7xn8Pn9Sg(BFZ6BTQP7DFHfusYWkuVZAi3k2ga1D)tlFfKY3EeAssAYnau6DRlJRK3Ce9s8bGCIFVFDySPY3)zlV)QPpZ1nF2(Of1CW(l1pu2RnUsUtNCD06PMfRBgKeGvs2CVoWp05DJ54rN3De70v949TWOJigLN1ZTJDOmuUpPUjs9vr1Cbh0cuUSu5SjGLWeHgl09Z8Z(rXu(81Z)uSrgbIagXFvDOynbLxtjQ(DP95KzNQIyCnwtXPnxpJRPZxEADldE7OoDFIbyx4zzT3aKhp(K2sHSNcfCCKjv0qR1g7174XA(B6OoCUZOvg5pxTngjT)34oQZTww)mpe6ABPAmB6ORm168elNnDYaq9zVJdpEK(m73nNzthoOhPd(o3uBU1r6fq1IoA2u5BQXngQPB6AjD9FWzcYcnMR2hem2S3RBQSbPv)JRt3EakO09tP(9d9cEMRqBh7sYTtiU)7BtP5wInkZQWMW9jyboTSf9BGyP2wF8nB4vT1)EYCNwVKXzsH7Dk(PYPEk9H6Drg)lHufpl15l6iXDFVip7erWyLhMApMHuxTywG7IjxPumlZpMAan5NR1VzYVsP9YQIs)AKRyzn6G(eFoLFGdApfiI6zfGmDRN1WTthBsd8CbiqdoplbZVXOI(ibEYfC4bhp2YLsH8A8DU4(w0pMLAMK2lOS8xgXukY40HxoXr11)VxO(ltMazqPk(3oDYXJxA17VXSY93ofRApsct4btfvRVtRGS6ywJ(zdjD4Fcl3UPsw60cqLRLG6D6Q5Ws2z1pmSpO9EIL6T3XMk92PdnrCD8Otyd9AuK)HxNBlgCQ1522gOwko)zPNf3SyrSrY2sHYTQhNztpwNYVy7qoP8AVV9A4jicPciakiRCWFaTSyNGEFwWxJI(ZAp5PiJeWNQ48p5IUDVDoFsuDEIcEKooVbwkzKPDdnfaNS1RDkgb3oDupjSKF)7vntfSmYsl9pLkSGwv9NPdoeOuXe1AhuUtiDqQhDV4pwF5S33qr)YK8Zdv1WQVToBRJJRg80bDAdGL6uPDJ)ODAChNMnwfLN83IErtNPul)w3ht936PVnVRv)HafAjPPEvFLPYasc2elXOExBPJXWOrA9gMYJKRWO7YiwPzAUjUwbnQj0on5ahyaWOoMT7ZTdhBStr6ccBzs083rvIr9Q8E8O9lsmQFDS1baQCMg9YGl1kUkWOU3GW9ERDF)70TLsfb5njL4st9b5U3)o2Ws6QbJYHlAlSPa8pBMmM9cwNUwmlSbTbwKYvB3chiGuQp1Wgv23GML6SQd7NeW4b34Q5P68OesRBdAT9OMnCGZnkMj69OBUO2dd6S)AeXWUmyyssQAJvrYOJTLZg1KbXFgApjDfLIQrj4Sru2oNVFLmTQ66(Y86WFLwYEDvY2B0vdN0RT4BZ6o6gROyPA86ArAGHF3MU25mkLU2czkYtrTbJ68e77dQI6coJhOjAZg14w5BAFa5gS25t9q3JWdjxKw67NMWOsQr5iOgD4d8shEASat(YLpdxEgOWoFJ7m7fYCUC76CMQhz2QoZgzAT20nnwGY4U)R0OcVzyQRYGwt3iaxPw9RXvvB3gYA9DuvTuJXBQ7IgdKHvnoJbcFLELr)TyhbGn0a37VzZOyuAbvxiADfZXJwcT(Ibw1hVSDwPLwqXAXDiVdwMg5J43284S5rAsfQ9gvXXIn5m6sBMeDwSQ3uKQMVLOchp2CpLK7UdRC00rdCmlJU0zz0fol8sB93ffFquARVl)TmRrI55)mvx(4f0thS7SXUdgxjPphS1R9hA(3GmrynR)rmd8V16NYZcX2FYY6PlqxzCDqQ2By)VBz3QSC1r5sIyq5Qo0PAfDU(TWr48CA1avI)7UihIpd9nXlRLL300xp2Yz5m93dwkQmLo7bCHfG9T2a6siV4)l]] )


end
