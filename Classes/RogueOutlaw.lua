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


    spec:RegisterPack( "Outlaw", 20220315, [[d80TwbqiHIhjO0LuPqytavFsq1OeQ6ucvwfrG4vcIzHsClHsAxk6xQuAyOK6yOuTmIONjOyAaf11ek12akY3iLunoGc15iLuADKsY8ivL7rk2hqPdIsslKuLhseAIKQkxKuv1grjrFuLcPtIscRuLQxseintvk4MafStbPFkuIgkrqhvLcrlvOeEkkMkPuxvLc1wjLu8vGczSQu0Ej5VQyWsomvlgWJvyYeUmYMH0NbYOjQtl1QjcuVgLYSr1Tvj7wPFdA4c54ebSCOEUQMUORdX2jv(UanEsjoprA(cy)uwXUsBfJWtsfQKSwsjzDyyp2t2bJddyM1GzftknIumr(GnhePyw)IumXsKK7bvmrUuo0fkTvmpebpifJCMrVwD7TG6ugbyoGx3(9fc3ZgUdSJM3(914wfdasZtwXQaumcpjvOsYAjLK1HH9ypzhmomGzwZUIXrsziwXW0xsuXi3cbTkafJG(HIjwIKCpOvXciieYUdgC8q2k2ddlwjjRLus7UDxIY(cIETYUhRwbgC2iRyLC6LhyhnTQ3KWyKO0QETAaVa80Qg1QGKvsWiFALOfw1PvOqSv6GCpBoDEixhT5uXW7pFL2kgbH6i8uPTku2vARy8r2WvXWwpytXqRdWjHspvQcvsL2kgADaoju6Pye0pWDu2WvXelOpjNNYw1Owfb)Vb4KvXVqR0HWxc7aCYkAPRMER61Qb8cWZ4um(iB4Qy(KCEkRsvOHrPTIHwhGtcLEkgyKI5PuX4JSHRIrNJBhGtkgDohHum4e4aGGI(wPpRK0kWTkERIXkaeu0zIrOda54EbnrIScCRIXkaeu0jag6IVf0ejYQ4umc6h4okB4QyIfegY5w99cItwbGGI(wroMl1kyktyRszFTsBmczLEKJ7fKv(kSspm0fFlifJohFw)Ium4e4GjmKZvPkuWSsBfdToaNek9umWifZtPIXhzdxfJoh3oaNum6CocPygWla4jc2B(tbH2JoTcSASssRcXkaeu0jag6IVf0ejYkWTIwcdsQvGvJvXM1wbUvXBvmwnGRaPZ5aIS5jLPdui(jToaNewfiGvaiOOtmKZpPmDaGl9tmD59(wbwnwXoRTkofJG(bUJYgUkg9FFemzvqYkquAfkcNBfREbG8Ywjrj0kqEVVv(kSYX0gEAfMWqoVxqwjriYMwLYKvXsH4Tcabf9TYd6svm6C8z9lsX4xaiV8zaxrNnCvPk0yR0wXqRdWjHspfdmsX8uQy8r2WvXOZXTdWjfJoNJqkMb8caEIG9MVvGvJvJOZLRLZhrRWQy1kaeu0jag6IVf0ejYQy1Q4TcabfDcJIG4ez7u6ejYkjiwLoN2Ckbq6bBhb2doP1b4KWQ4SkqaRiuuAKTo6mGxaWteS38TcSASAeDUCTC(iAfkgb9dChLnCvmSYE7x2kpT6Y1IvrW)BaozLeLqRc2PmejTcQJWOCyWEbzfaCrERgWlaOvrWEZNfRqwo9VvOqSv6L6VvbL7HSvopOl9T6LHiCHvaKvXoeRKOeQy054Z6xKIbT3(Lpd4k6SHRkvHcMuARyO1b4KqPNIbgPyW0tPIXhzdxfJoh3oaNum6C8z9lsXG2B)YNbCfD2WvXmWDs42vmdiKlGb3jaLbjApPmDiP0pXKlKAf4wrOO0iBD0zaVaGNiyV5BL(Sk2kgb9dChLnCvmSkpOl9TYZKUIsRsOvipzLEP(BLNwf7qSsIsilwHjqowWP)TcIALeLqRarRvb9pjvQcvRR0wXqRdWjHspfdmsX8uQy8r2WvXOZXTdWjfJoNJqkMpI48t6yqu(taUlOdkhbJLAL(SssRa3kS3IdPJ2C6cXp71kWALKS2QabScabfDcWDbDq5iyS0jMU8EFRaRvSBviwLoN2CYwZ59c68ryIM06aCsOye0pWDu2WvXag1PSvxi8SJ4KvPJbr5ZIvPC)wPZXTdWjR63QHmnyJewLqRe0OfKvbLPuMWw9WlYkjQFVvVmeHlScGS6LUdsyvWoLTspUliRyLCemwQIrNJpRFrkgaUlOdkhbJLEEP7qLQqbJvARyO1b4KqPNIzG7KWTRy(KCEktIPZ5kgFKnCvmyK94JSH7H3FQy49NN1VifZNKZtzvQcvRvPTIHwhGtcLEkgFKnCvmdNZp(iB4E49NkgE)5z9lsXmeVkvHYoRvARyO1b4KqPNIzG7KWTRy0542b40eT3(Lpd4k6SHRIXhzdxfdgzp(iB4E49NkgE)5z9lsXG2B)YQufk7SR0wXqRdWjHspfJpYgUkMHZ5hFKnCp8(tfdV)8S(fPyaqAUqLQqzxsL2kgADaoju6Pyg4ojC7kgAjmiPtbH2JoTcSASI9yBviwrlHbjDIjq0Qy8r2WvX44HV0jHymTPkvHYEyuARy8r2WvX44HV0jcH)KIHwhGtcLEQufk7GzL2kgFKnCvm8gKC(hjyebOlAtfdToaNek9uPku2JTsBfJpYgUkgah0bIEsCpy7vm06aCsO0tLQuXeHPb8cWtL2QqzxPTIXhzdxfJhfXLEIG9dxfdToaNek9uPkujvARy8r2WvXaaZKtIdk3LsIG9c6KqT0RIHwhGtcLEQufAyuARy8r2WvX8j58uwXqRdWjHspvQcfmR0wXqRdWjHspfJpYgUkMlhZgjoOq8rqEkRyg4ojC7kgS3IdPJ2C6cXp71kWALKXwXeHPb8cWZZtd4kEftSvPk0yR0wXqRdWjHspfZa3jHBxX8qeoqVIzeYNiC6qyKOSH7KwhGtcRceWQhIWb6vm1b5E2C68qUoAZjToaNekgFKnCvmOC6LhyhnvPkuWKsBfdToaNek9um(iB4QyWqo)KY0baU0Ryg4ojC7kgmD59(wPpRcJIjctd4fGNNNgWv8kgjvPkuTUsBfdToaNek9um(iB4QyEEpOJVIJOhKIzG7KWTRyWekMEzhGtkMimnGxaEEEAaxXRyKuLQuXaG0CHsBvOSR0wX4JSHRI5POVFfdToaNek9uPkujvARyO1b4KqPNIzG7KWTRyeeack6eKm8tU0ZN4MnAIPlV33k9PXQWOy8r2WvXasg(jx65tCZgPsvOHrPTIHwhGtcLEkMbUtc3UIbJSekedIMzVspjul94aWDbnP1b4KqX4JSHRI5LBDQufkywPTIHwhGtcLEkMbUtc3UIjgREichOxXKqrr(whD8TV8JpgeNWEcXtADaojSkqaR0542b40eG7c6GYrWyPNx6oum(iB4QyOHmSxqhmfH7lFfQufASvARyO1b4KqPNIXhzdxfZtySNK4aax68rnBKIrq)a3rzdxfdRgfXLAfJEmwLqRCo3Q0XGO8TkyNYqK0k3kbbGGIAL)wfHBiUtPSyveMqjmUxqwLogeLVvcP9cYQhcxcBLJMe2QuMSkc3xowQvPJbrPIzG7KWTRyIXkbmNpHXEsIdaCPZh1SrhbmNzpyRxqQufkysPTIHwhGtcLEkgFKnCvmpHXEsIdaCPZh1SrkMbUtc3UIjgReWC(eg7jjoaWLoFuZgDeWCM9GTEbPygshC6KogeLVku2vPkuTUsBfdToaNek9um(iB4QyEcJ9Keha4sNpQzJumc6h4okB4Qyy1mPRO0QeAfYtwfuMwR60QGnNB1WJSAaVaGwfb7nFR8vyfZQFw1VvcyWLfRGPmHd2pzfBefzfkgEz1WJI6fKvdzhdIEfZa3jHBxXG2GKZdMU8EFR0NgRITvbcy1ac5cyWD(eg7jjoaWLoFuZgnVCTCgYoge9wfRwnKDmi6pOyFKnCDUv6tJvSEkzSTkqaRgWla4jc2B(tbH2JoTsJvJOdiVxRa3QyScabfD(SHW5hFfNbg(paCPFIezf4wrlHbjDM9fDs45Y1IvG1k2vPkuWyL2kgADaoju6Py8r2WvXe1Fc5NxgMkgb9dChLnCvm34NSsc7pHCRyKHPvb7u2QyzueeNiBNsTQrTsIWlapTscHjTdPwfeUHNwb1r4HhzfTegKuwSkOmTw1PvbBo3ksl(i5sTA4rwjrjKfRGyRcktRviFVGS6gjspyZk9d7bvmdCNeUDfdack6egfbXjY2P0jsKvGBv8wrlHbjDki0E0PvG1Q4TIwcds6etGO1QqSIDwBvCwfiGvd4fa8eb7n)PGq7rNwPpnwXUvHyfack6eadDX3cAIezvGawLoN2Ckbq6bBhb2doP1b4KWQ4uPkuTwL2kgADaoju6Pyg4ojC7kgaeu0jmkcItKTtPtKiRa3Q4TcabfDcct0(S17Fc2d2i8prISkqaRaqqrNd4oiNtIdahzfega5)jsKvbcyfack6mH41fWtIBqGi8ejYQ4um(iB4QyI6pH8ZldtvQcLDwR0wX4JSHRI57T)KWNpXnBKIHwhGtcLEQufk7SR0wXqRdWjHspfZa3jHBxXKoN2CkACk9K4EW2pP1b4KWkWTAaVaGNiyV5pfeAp60kWQXk2TkeRaqqrNayOl(wqtKifJpYgUkgqqeqKkvPIziEL2QqzxPTIHwhGtcLEkgFKnCvmaCxqhuocglvXiOFG7OSHRIrpUliRyLCemwQvW1kjdXkAPRMEfZa3jHBxX8reNFshdIY3kWQXkjTcCRIXkaeu0ja3f0bLJGXsNirQufQKkTvm06aCsO0tX4JSHRIrNV9lRye0pWDu2WvXCJ)EbzfREbG8Yw1VvUvsEJWQEhyYFIfREOvAn(2VSvdFTcGS6Hxu2x0BfazfYtcR83k3kKS5Dk1QpI4CRqwo9VviFVGScm4FsyRy1)9)71ki2k9J8uMl1kgzxad(kMbUtc3UIjgRWilHcXGO5LJz7arpPmDU8pj8X)3)V3jToaNewbUvXyfgzjuigen7vxdcI9SxqNx2fWGcKpN06aCsyf4wfJvFsopLjX05CRa3kDoUDaon9laKx(mGROZgUwbUvXBvmwHrwcfIbrtb5Pmx65LDbm4pP1b4KWQabScabfDkipL5spVSlGb)PagCTcCRgWla4jc2B(wPpnwjPvXPsvOHrPTIHwhGtcLEkgyKI5PuX4JSHRIrNJBhGtkgDo(S(fPy05B)YNl)mGROZgUkMbUtc3UIbJSekedIMxoMTde9KY05Y)KWh)F))EN06aCsyf4wfJvPZPnNxoMnsCqH4JG8uEsRdWjHIrq)a3rzdxfdyuNYwbg8pjSvS6)V)FVSy1lDhwP14B)YwfStzRCRq7TFzcBfeBfREbG8YwjOiAf9cYk4ALEP(B1ac5cyWLfRGyRCEqx6BLBfAV9ltyRc2PSvGbu9tXOZ5iKIjERIXQbeYfWG7eGYGeTNuMoKu6NyYfsTcCR0542b40eT3(Lpd4k6SHRvXzvGawfVvdiKlGb3jaLbjApPmDiP0pXKlKAf4wPZXTdWPPFbG8YNbCfD2W1Q4uPkuWSsBfdToaNek9umWifZtPIXhzdxfJoh3oaNum6CocPy0542b40eT3(Lpd4k6SHRIzG7KWTRyWilHcXGO5LJz7arpPmDU8pj8X)3)V3jToaNewbUvPZPnNxoMnsCqH4JG8uEsRdWjHIrNJpRFrkgD(2V85Ypd4k6SHRkvHgBL2kgADaoju6Pyg4ojC7kgDoUDaon15B)YNl)mGROZgUwbUvx(Ne(4)7)37btxEVVvASI1wbUv6CC7aCAcWDbDq5iyS0ZlDhkgFKnCvm68TFzvQcfmP0wXqRdWjHspfZa3jHBxXeJvaiOOtxGP159shmYlprIum(iB4QyCbMwN3lDWiVSkvHQ1vARyO1b4KqPNIrq)a3rzdxfdRKtV8a7OPvOqSvsiYNiCYk9hJeLnCTQrTAHPvFsopLjHv(kSAHPvb7u2k94UGSIvYrWyPkMbUtc3UIjEREichOxXmc5teoDimsu2WDsRdWjHvbcy1dr4a9kM6GCpBoDEixhT5KwhGtcRIZkWTkgR(KCEktIPZ5wbUvXBvmwbGGIob4UGoOCemw6ejYQabS6Jio)KogeL)eG7c6GYrWyPwPpRK0Q4ScCRI3QyScabfD6cmToVx6GrE5jsKvbcyfTegK0z2x0jHNlxlwbwRK0Q4um9MegJeLNgvX8qeoqVIPoi3ZMtNhY1rBQy6njmgjkp91fjApjfd7kgFKnCvmOC6Lhyhnvm9MegJeLhqCiGZvmSRsvOGXkTvm06aCsO0tXmWDs42vmXy1NKZtzsmDo3kWTkER0542b40eT3(Lpd4k6SHRvbcyv6yquoZ(Ioj8iAYk9zf7HXQ4um(iB4Qyq5oiIZ9SHRkvHQ1Q0wXqRdWjHspfZa3jHBxXeJvFsopLjX05CRa3Qb8caEIG9MVv6tJvsAf4wfVvXy1aQJwFZPoAtzPyRceWkbbGGIor5oiIZ9SH7ejYQ4ScCRI3QySkDoT58YXSrIdkeFeKNYtADaojSkqaRIXQbeYfWG78YXSrIdkeFeKNYtm5cPwfNIXhzdxfJatUaG7c6vPku2zTsBfdToaNek9umdCNeUDfZL)jHp()()9EW0L37BLgRyTvGBfack6uGjxaWDb9tbm4Af4wfVvaiOOtmKZpPmDaGl9tmD59(wPpnwfgRceWkDoUDaonXjWbtyiNBvCkgFKnCvmyiNFsz6aax6vPku2zxPTIHwhGtcLEkgFKnCvmxoMnsCqH4JG8uwXW7LodHIH9zSvmdPdoDshdIYxfk7kMbUtc3UIb7T4q6OnNUq8tKiRa3Q4TkDmikNzFrNeEenzL(SAaVaGNiyV5pfeAp60QabSkgR(KCEktIjgccHScCRgWla4jc2B(tbH2JoTcSASAeDUCTC(iAfwfRwXUvXPye0pWDu2WvXWkqTYfI3khtwHeXIv)2rKvPmzfCjRc2PSvCyq6tR0wB9BA1n(jRcktRvcP9cYku)tcBvk7RvsucTsqO9OtRGyRc2PmejTYxPwjrjCQsvOSlPsBfdToaNek9um(iB4QyUCmBK4GcXhb5PSIrq)a3rzdxfdRa1QfALleVvbBo3krtwfSt5ETkLjRwslPvHH1plwH8KvGbu9Zk4Afa8FRc2PmejTYxPwjrjCQyg4ojC7kgS3IdPJ2C6cXp71kWAvyyTvXQvyVfhshT50fIFkqWE2W1kWTkgR(KCEktIjgccHScCRgWla4jc2B(tbH2JoTcSASAeDUCTC(iAfwfRwXUvGBv8wfJvdOoA9nN6OnLLITkqaRgqixadUtuUdI4CpB4oX0L37BfyTIDwBvGawjiaeu0jk3brCUNnCNirwfNkvHYEyuARyO1b4KqPNIbgPyEkvm(iB4Qy0542b4KIrNZriftmwHrwcfIbrZlhZ2bIEsz6C5Fs4J)V)FVtADaojSkqaRgqixadUtD(2V8etxEVVvG1k2zTvbcy1L)jHp()()9EW0L37BfyTssfJG(bUJYgUkgwnt6kkTkHw9s3HvsqBoVxqwXeHjYQGDkBLwJV9lBfkeBfyW)KWwXQ)7)3RIrNJpRFrkg2AoVxqNpct0rNV9lFEP7qLQqzhmR0wXqRdWjHspfJpYgUkg2AoVxqNpctKIrq)a3rzdxfZn(jR61k2Jvj12Qg1k9s93Q(TcjYkFfwfeUHNwn8iR0)LWGKYIvqSvEAvy0oeRIxsTdXQGDkBL(rEkZLAfJSlGb)4ScITkOmTwbg8pjSvS6)()9Av)wHenvmdCNeUDfJoh3oaNMaCxqhuocgl98s3HvGBLoh3oaNMS1CEVGoFeMOJoF7x(8s3HvGBvmw9j58uMetmeeczf4wfVvccabfDcqzqI2tkthsk9tKiRa3kaeu0PatUaG7c6NcyW1kWTIwcds6uqO9OtRaRvXBfTegK0jMarRvsqSssRcXk2JTvXzvGaw9reNFshdIYFcWDbDq5iySuRaRvXBLKwfRwbGGIofKNYCPNx2fWG)ejYQ4SkqaRU8pj8X)3)V3dMU8EFRaRvS2Q4uPku2JTsBfdToaNek9umdCNeUDfJoh3oaNMaCxqhuocgl98s3HvGBv8wrlHbjDM9fDs45Y1IvG1kjTcCRaqqrNcm5caUlOFkGbxRceWkAjmiPwPpnwfgwBvGaw9reNFshdIY3kWALKwfNIXhzdxfda3f0bJ8YQufk7GjL2kgADaoju6Py8r2WvXOZ3(Lvmc6h4okB4QyyfOwH89cYkwXQRbbXE2liRyKDbmOa5twSc5jRwi(Y5wXHG6Hv9ALleD2W1QeA1qMgS1liRUCjyi2kjQF)uXmWDs42vmyKLqHyq0SxDnii2ZEbDEzxadkq(CsRdWjHvGB1aQJwFZPoAtzPyRa3QyS6tY5PmjMoNBf4wPZXTdWPPFbG8YNbCfD2W1kWTkERIXQbeYfWG7eL7Gio3ZgUtm5cPwbUvXBvmwLoN2CkWKla4UG(jToaNewfiGvXy1ac5cyWDkWKla4UG(jMCHuRceWQySsqaiOOtuUdI4CpB4orISkoRItLQqzxRR0wXqRdWjHspfZa3jHBxXGrwcfIbrZE11GGyp7f05LDbmOa5ZjToaNewbUvXy1aQJwFZPoAtzPyRa3QyS6tY5PmjMoNBf4wfVvdiKlGb3jnKH9c6GPiCF5RyIPlV33kWAfyYQabSkgRgqixadUZNI((NyYfsTkqaRgqixadUZNWypjXbaU05JA2OjkcNFW0q2XGOt2xKvG1kjzTvXPy8r2WvXOZ3(LvPku2bJvARyO1b4KqPNIzG7KWTRyIXQpjNNYKy6CUvGBLoh3oaNM(faYlFgWv0zdxfJpYgUkMx2fWGxexOsvOSR1Q0wXqRdWjHspfZa3jHBxXaGGIob4qOGJ85et(iTkqaRaG)Bf4wH2GKZdMU8EFR0NvHH1wfiGvaiOOtxGP159shmYlprIum(iB4QyIGzdxvQcvswR0wX4JSHRIbGdHIdkcwQIHwhGtcLEQufQKSR0wX4JSHRIbGWpHzRxqkgADaoju6PsvOskPsBfJpYgUkg0gtaCiuOyO1b4KqPNkvHkzyuARy8r2WvX47G(e78ZW5CfdToaNek9uPkujbZkTvm06aCsO0tX4JSHRIjyVIF44tqzk)eUKIzG7KWTRy(iIZpPJbr5pb4UGoOCemwQvG1kb9nMeN0XGO8TkqaRWEloKoAZPle)SxRaRvGjwBvGawH2GKZdMU8EFR0NvADfZ6xKIjyVIF44tqzk)eUKkvHkzSvARyO1b4KqPNIXhzdxfZWhY0bIE8HeaPXK4KyYFem9kMbUtc3UIbabfD6djasJjXX1cnrISkqaRaG)Bf4wH2GKZdMU8EFR0NvsgBfZ6xKIz4dz6arp(qcG0ysCsm5pcMEvQcvsWKsBfdToaNek9um(iB4QysCVSrj7kgb9dChLnCvm6hH6i80QbCfD2W9TcfITc5DaozvN01pvmdCNeUDfJGaqqrNaugKO9KY0HKs)ejYQabSkX9YgLZK9PS)hKNoaiOOwfiGvaW)TcCRqBqY5btxEVVv6tJvsYAvQcvsTUsBfdToaNek9umdCNeUDfJGaqqrNaugKO9KY0HKs)ejYQabSkX9YgLZuYPS)hKNoaiOOwfiGvaW)TcCRqBqY5btxEVVv6tJvsYAfJpYgUkMe3lBukPkvPI5tY5PSsBvOSR0wXqRdWjHspfZa3jHBxXOZXTdWPjAV9lFgWv0zdxfJpYgUkgr)rEoKvPkujvARy8r2WvX4xaiVSIHwhGtcLEQufAyuARyO1b4KqPNIXhzdxfZqM8OZldtfZa3jHBxXKoN2CgHjPh4Esz6eKC2M06aCsyf4wfJvPJbr5S)da8FfZq6GtN0XGO8vHYUkvPIbT3(LvARcLDL2kgADaoju6Py8r2WvXaqzqI2tkthsk9kgb9dChLnCvm6L6VvW1QbeYfWGRvj0k2ikYQuMSsI4oTsqaiOOwHeXIvilN(3QuMSkDmikTQFRCaisAvcTs0KIzG7KWTRyshdIYz2x0jHhrtwbwRcJvGBv8wjiaeu0jaLbjApPmDiP0pX0L37BL(ScmBvGawbGGIoXiPmN()eHPr)nCNirwfNkvHkPsBfdToaNek9umdCNeUDfdack6859Go(koIEqtmD59(wPpRqBqY5btxEVVvGBfMqX0l7aCsX4JSHRI559Go(koIEqQufAyuARy8r2WvXi6pYZHSIHwhGtcLEQuLQuXOJWFdxvOsYAjLK1HH1GXkMGoE7f0RyaJy1yrOSIqVr1kRSsBzYQ(kcItRqHyRcxqOocpd3kmjbqAmjS6HxKvoscV8KewnK9fe9t7(n0lzfywRSsIWvhHtsyv4d4kq6CEZWTkHwf(aUcKoN3CsRdWjr4wfp7AjUPD3UdgXQXIqzfHEJQvwzL2YKv9veeNwHcXwfEeMgWlapd3kmjbqAmjS6HxKvoscV8KewnK9fe9t7(n0lzvS1kRKiC1r4Kewf(dr4a9kM3mCRsOvH)qeoqVI5nN06aCseUvXZUwIBA3VHEjRITwzLeHRocNKWQWFichOxX8MHBvcTk8hIWb6vmV5KwhGtIWTYtR0)y5nyv8SRL4M2D7oyeRglcLve6nQwzLvAltw1xrqCAfkeBv4dXhUvyscG0ysy1dViRCKeE5jjSAi7li6N29BOxYkj1kRKiC1r4KewfogzjuigenVz4wLqRchJSekedIM3CsRdWjr4wfFy0sCt7(n0lzvy0kRKiC1r4KewfogzjuigenVz4wLqRchJSekedIM3CsRdWjr4wfp7AjUPD)g6LScmRvwjr4QJWjjSkCmYsOqmiAEZWTkHwfogzjuigenV5KwhGtIWTkE21sCt7(n0lzLwxRSsIWvhHtsyv4peHd0RyEZWTkHwf(dr4a9kM3CsRdWjr4wfVKAjUPD)g6LSsRvRSsIWvhHtsyv4PZPnN3mCRsOvHNoN2CEZjToaNeHBv8SRL4M29BOxYk2dJwzLeHRocNKWQWXilHcXGO5nd3QeAv4yKLqHyq08MtADaojc3Q4zxlXnT73qVKvSdM0kRKiC1r4KewfE6CAZ5nd3QeAv4PZPnN3CsRdWjr4wfp7AjUPD)g6LSIDWKwzLeHRocNKWQWXilHcXGO5nd3QeAv4yKLqHyq08MtADaojc3Q4zxlXnT73qVKvSR11kRKiC1r4KewfogzjuigenVz4wLqRchJSekedIM3CsRdWjr4wfp7AjUPD)g6LSssWKwzLeHRocNKWQWtCVSr5K95nd3QeAv4jUx2OCMSpVz4wfp7AjUPD)g6LSssTUwzLeHRocNKWQWtCVSr5uY5nd3QeAv4jUx2OCMsoVz4wfp7AjUPD3UdgXQXIqzfHEJQvwzL2YKv9veeNwHcXwfoasZfHBfMKainMew9WlYkhjHxEscRgY(cI(PD)g6LSkmALvseU6iCscRchJSekedIM3mCRsOvHJrwcfIbrZBoP1b4KiCR80k9pwEdwfp7AjUPD)g6LScmRvwjr4QJWjjSk8hIWb6vmVz4wLqRc)HiCGEfZBoP1b4KiCRINDTe30UB3zfxrqCscRatw5JSHRv8(ZFA3vmFenuHkjyI1kMimeT5KIjSH1QyjsY9GwflGGqi7EydRvGbhpKTI9WWIvsYAjL0UB3dByTsIY(cIETYUh2WAvSAfyWzJSIvYPxEGD00QEtcJrIsR61Qb8cWtRAuRcswjbJ8PvIwyvNwHcXwPdY9S505HCD0Mt7UDpSH1k9xl0ajjHvaeketwnGxaEAfabQ3FAfRoguu(wTWnwLD8fkc3kFKnCFRGlx60U7JSH7pJW0aEb4PgpkIl9eb7hU2DFKnC)zeMgWlapdrZTaWm5K4GYDPKiyVGojul9A39r2W9NryAaVa8men3(j58u2U7JSH7pJW0aEb4ziAU9YXSrIdkeFeKNYSeHPb8cWZZtd4kEnXMLgvd2BXH0rBoDH4N9cwjJTD3hzd3FgHPb8cWZq0ClkNE5b2rtwAunpeHd0RygH8jcNoegjkB4giWdr4a9kM6GCpBoDEixhTPD3hzd3FgHPb8cWZq0ClgY5NuMoaWLEwIW0aEb455PbCfVgjzPr1GPlV3xFHXU7JSH7pJW0aEb4ziAU959Go(koIEqSeHPb8cWZZtd4kEnsYsJQbtOy6LDaoz3T7HnSwP)AHgijjSI0ryPwL9fzvktw5JeITQFRCDEZDaonT7(iB4(AyRhSz3dRvXc6tY5PSvnQvrW)Baozv8l0kDi8LWoaNSIw6QP3QETAaVa8mo7UpYgUFiAU9tY5PSDpSwflimKZT67feNScabf9TICmxQvWuMWwLY(AL2yeYk9ih3liR8vyLEyOl(wq2DFKnC)q0CRoh3oaNyz9lsdoboycd5Cw05CesdoboaiOOV(Ke84JbabfDMye6aqoUxqtKiWJbabfDcGHU4BbnrIIZUhwR0)9rWKvbjRarPvOiCUvS6faYlBLeLqRa59(w5RWkhtB4Pvycd58EbzLeHiBAvktwflfI3kaeu03kpOl1U7JSH7hIMB1542b4elRFrA8laKx(mGROZgUSOZ5iKMb8caEIG9M)uqO9OtWQrYqaqqrNayOl(wqtKiWPLWGKcwnXM1GhFmd4kq6CoGiBEsz6afIpqaaeu0jgY5NuMoaWL(jMU8EFWQHDwhNDpSwXk7TFzR80Qlxlwfb)Vb4KvsucTkyNYqK0kOocJYHb7fKvaWf5TAaVaGwfb7nFwScz50)wHcXwPxQ)wfuUhYw58GU03QxgIWfwbqwf7qSsIsOD3hzd3pen3QZXTdWjww)I0G2B)YNbCfD2WLfDohH0mGxaWteS38bRMr05Y1Y5JOveRaiOOtam0fFlOjsuSgpack6egfbXjY2P0jsKeK050Mtjaspy7iWEWjToaNeXfiaHIsJS1rNb8caEIG9Mpy1mIoxUwoFeTc7EyTIv5bDPVvEM0vuAvcTc5jR0l1FR80QyhIvsuczXkmbYXco9VvquRKOeAfiATkO)jz39r2W9drZT6CC7aCIL1VinO92V8zaxrNnCzbgPbtpLS0OAgqixadUtakds0Esz6qsPFIjxifCcfLgzRJod4fa8eb7nF9fB7EyTcmQtzRUq4zhXjRshdIYNfRs5(TsNJBhGtw1VvdzAWgjSkHwjOrliRcktPmHT6HxKvsu)EREzicxyfaz1lDhKWQGDkBLECxqwXk5iySu7UpYgUFiAUvNJBhGtSS(fPbG7c6GYrWyPNx6oyrNZrinFeX5N0XGO8NaCxqhuocglvFsco2BXH0rBoDH4N9cwjzDGaaiOOtaUlOdkhbJLoX0L37dw2djDoT5KTMZ7f05JWenP1b4KWU7JSH7hIMBXi7Xhzd3dV)KL1VinFsopLzPr18j58uMetNZT7(iB4(HO52HZ5hFKnCp8(tww)I0meVD3hzd3pen3Ir2JpYgUhE)jlRFrAq7TFzwAun6CC7aCAI2B)YNbCfD2W1U7JSH7hIMBhoNF8r2W9W7pzz9lsdasZf2DFKnC)q0CRJh(sNeIX0MS0OAOLWGKofeAp6eSAyp2HqlHbjDIjq0A39r2W9drZToE4lDIq4pz39r2W9drZT8gKC(hjyebOlAt7UpYgUFiAUfWbDGONe3d2E7UDpSH1k9qAUGWVD3hzd3FcG0CHMNI((T7(iB4(taKMlcrZTGKHFYLE(e3SrS0OAeeack6eKm8tU0ZN4MnAIPlV3xFAcJD3hzd3FcG0CriAU9LBDS0OAWilHcXGOz2R0tc1spoaCxq2DFKnC)jasZfHO5wAid7f0btr4(YxblnQMyEichOxXKqrr(whD8TV8JpgeNWEcXbcOZXTdWPja3f0bLJGXspV0Dy3dRvSAuexQvm6XyvcTY5CRshdIY3QGDkdrsRCReeackQv(BveUH4oLYIvrycLW4Ebzv6yqu(wjK2liREiCjSvoAsyRszYQiCF5yPwLogeL2DFKnC)jasZfHO52NWypjXbaU05JA2iwAunXiG58jm2tsCaGlD(OMn6iG5m7bB9cYU7JSH7pbqAUien3(eg7jjoaWLoFuZgXYq6GtN0XGO81WolnQMyeWC(eg7jjoaWLoFuZgDeWCM9GTEbz3dRvSAM0vuAvcTc5jRcktRvDAvWMZTA4rwnGxaqRIG9MVv(kSIz1pR63kbm4YIvWuMWb7NSInIIScfdVSA4rr9cYQHSJbrVD3hzd3FcG0CriAU9jm2tsCaGlD(OMnILgvdAdsopy6Y791NMyhiWac5cyWD(eg7jjoaWLoFuZgnVCTCgYoge9X6q2XGO)GI9r2W156tdRNsg7abgWla4jc2B(tbH2Jo1mIoG8Ebpgaeu05ZgcNF8vCgy4)aWL(jse40syqsNzFrNeEUCTaw2T7H1QB8twjH9NqUvmYW0QGDkBvSmkcItKTtPw1Owjr4fGNwjHWK2HuRcc3WtRG6i8WJSIwcdsklwfuMwR60QGnNBfPfFKCPwn8iRKOeYIvqSvbLP1kKVxqwDJePhSzL(H9G2DFKnC)jasZfHO52O(ti)8YWKLgvdack6egfbXjY2P0jse4XtlHbjDki0E0jyJNwcds6etGOne2zDCbcmGxaWteS38NccThDQpnShcack6eadDX3cAIefiq6CAZPeaPhSDeyp4KwhGtI4S7(iB4(taKMlcrZTr9Nq(5LHjlnQgaeu0jmkcItKTtPtKiWJhabfDcct0(S17Fc2d2i8prIceaabfDoG7GCojoaCKvqyaK)NirbcaGGIotiEDb8K4geicprIIZU7JSH7pbqAUien3(92Fs4ZN4MnYU7JSH7pbqAUien3ccIaIyPr1KoN2CkACk9K4EW2pP1b4Ka8b8caEIG9M)uqO9OtWQH9qaqqrNayOl(wqtKi7UDpSH1kjcHCbm4(29WALECxqwXk5iySuRGRvsgIv0sxn92DFKnC)5q8Aa4UGoOCemwklnQMpI48t6yqu(GvJKGhdack6eG7c6GYrWyPtKi7EyT6g)9cYkw9ca5LTQFRCRK8gHv9oWK)elw9qR0A8TFzRg(Afaz1dVOSVO3kaYkKNew5VvUvizZ7uQvFeX5wHSC6FRq(EbzfyW)KWwXQ)7)3RvqSv6h5PmxQvmYUag8T7(iB4(ZH4drZT68TFzwAunXGrwcfIbrZlhZ2bIEsz6C5Fs4J)V)FVGhdgzjuigen7vxdcI9SxqNx2fWGcKpbpMpjNNYKy6Co46CC7aCA6xaiV8zaxrNnCbp(yWilHcXGOPG8uMl98YUag8deaabfDkipL5spVSlGb)PagCbFaVaGNiyV5RpnsgNDpSwbg1PSvGb)tcBfR()7)3llw9s3HvAn(2VSvb7u2k3k0E7xMWwbXwXQxaiVSvckIwrVGScUwPxQ)wnGqUagCzXki2kNh0L(w5wH2B)Ye2QGDkBfyav)S7(iB4(ZH4drZT6CC7aCIL1Vin68TF5ZLFgWv0zdxwAunyKLqHyq08YXSDGONuMox(Ne(4)7)3l4XKoN2CE5y2iXbfIpcYt5jToaNeSOZ5iKM4JzaHCbm4obOmir7jLPdjL(jMCHuW1542b40eT3(Lpd4k6SHBCbce)ac5cyWDcqzqI2tkthsk9tm5cPGRZXTdWPPFbG8YNbCfD2Wno7UpYgU)Ci(q0CRoh3oaNyz9lsJoF7x(C5NbCfD2WLLgvdgzjuigenVCmBhi6jLPZL)jHp()()9cE6CAZ5LJzJehui(iipLN06aCsWIoNJqA0542b40eT3(Lpd4k6SHRD3hzd3FoeFiAUvNV9lZsJQrNJBhGttD(2V85Ypd4k6SHl4x(Ne(4)7)37btxEVVgwdUoh3oaNMaCxqhuocgl98s3HD3hzd3FoeFiAU1fyADEV0bJ8YS0OAIbabfD6cmToVx6GrE5jsKDpSwXk50lpWoAAfkeBLeI8jcNSs)XirzdxRAuRwyA1NKZtzsyLVcRwyAvWoLTspUliRyLCemwQD3hzd3FoeFiAUfLtV8a7OjlnQM4FichOxXmc5teoDimsu2WnqGhIWb6vm1b5E2C68qUoAZ4apMpjNNYKy6Co4Xhdack6eG7c6GYrWyPtKOab(iIZpPJbr5pb4UGoOCemwQ(KmoWJpgaeu0PlW068EPdg5LNirbcqlHbjDM9fDs45Y1cyLmow6njmgjkp91fjApjnSZsVjHXir5behc4CnSZsVjHXir5Pr18qeoqVIPoi3ZMtNhY1rBA39r2W9NdXhIMBr5oiIZ9SHllnQMy(KCEktIPZ5GhVoh3oaNMO92V8zaxrNnCdeiDmikNzFrNeEenPp2dtC2DFKnC)5q8HO5wbMCba3f0ZsJQjMpjNNYKy6Co4d4fa8eb7nF9PrsWJpMbuhT(MtD0MYsXbciiaeu0jk3brCUNnCNirXbE8XKoN2CE5y2iXbfIpcYt5abIzaHCbm4oVCmBK4GcXhb5P8etUqAC2DFKnC)5q8HO5wmKZpPmDaGl9S0OAU8pj8X)3)V3dMU8EFnSgCaeu0PatUaG7c6NcyWf84bqqrNyiNFsz6aax6Ny6Y791NMWeiGoh3oaNM4e4GjmKZJZUhwRyfOw5cXBLJjRqIyXQF7iYQuMScUKvb7u2komi9PvART(nT6g)KvbLP1kH0EbzfQ)jHTkL91kjkHwji0E0PvqSvb7ugIKw5RuRKOeoT7(iB4(ZH4drZTxoMnsCqH4JG8uMfEV0zi0W(m2SmKo40jDmikFnSZsJQb7T4q6OnNUq8tKiWJpDmikNzFrNeEenPVb8caEIG9M)uqO9OZabI5tY5PmjMyiiec8b8caEIG9M)uqO9OtWQzeDUCTC(iAfXk7Xz3dRvScuRwOvUq8wfS5CRenzvWoL71QuMSAjTKwfgw)SyfYtwbgq1pRGRvaW)TkyNYqK0kFLALeLWPD3hzd3FoeFiAU9YXSrIdkeFeKNYS0OAWEloKoAZPle)SxWggwhRyVfhshT50fIFkqWE2Wf8y(KCEktIjgccHaFaVaGNiyV5pfeAp6eSAgrNlxlNpIwrSYo4XhZaQJwFZPoAtzP4abgqixadUtuUdI4CpB4oX0L37dw2zDGaccabfDIYDqeN7zd3jsuC29WAfRMjDfLwLqREP7WkjOnN3liRyIWezvWoLTsRX3(LTcfITcm4FsyRy1)9)71U7JSH7phIpen3QZXTdWjww)I0WwZ59c68ryIo68TF5ZlDhSOZ5iKMyWilHcXGO5LJz7arpPmDU8pj8X)3)V3abgqixadUtD(2V8etxEVpyzN1bcC5Fs4J)V)FVhmD59(Gvs7EyT6g)Kv9Af7XQKABvJALEP(Bv)wHezLVcRcc3WtRgEKv6)syqszXki2kpTkmAhIvXlP2HyvWoLTs)ipL5sTIr2fWGFCwbXwfuMwRad(Ne2kw9F))ETQFRqIM2DFKnC)5q8HO5w2AoVxqNpctelnQgDoUDaonb4UGoOCemw65LUdW1542b40KTMZ7f05JWeD05B)YNx6oapMpjNNYKyIHGqiWJxqaiOOtakds0Esz6qsPFIeboack6uGjxaWDb9tbm4coTegK0PGq7rNGnEAjmiPtmbIwjisgc7XoUab(iIZpPJbr5pb4UGoOCemwkyJxYyfabfDkipL5spVSlGb)jsuCbcC5Fs4J)V)FVhmD59(GL1Xz39r2W9NdXhIMBb4UGoyKxMLgvJoh3oaNMaCxqhuocgl98s3b4XtlHbjDM9fDs45Y1cyLeCaeu0PatUaG7c6NcyWnqaAjmiP6ttyyDGaFeX5N0XGO8bRKXz3dRvScuRq(EbzfRy11GGyp7fKvmYUaguG8jlwH8KvleF5CR4qq9WQETYfIoB4AvcTAitd26fKvxUemeBLe1VFA39r2W9NdXhIMB15B)YS0OAWilHcXGOzV6AqqSN9c68YUaguG8j4dOoA9nN6OnLLIbpMpjNNYKy6Co46CC7aCA6xaiV8zaxrNnCbp(ygqixadUtuUdI4CpB4oXKlKcE8XKoN2CkWKla4UG(abIzaHCbm4ofyYfaCxq)etUqAGaXiiaeu0jk3brCUNnCNirXfND3hzd3FoeFiAUvNV9lZsJQbJSekedIM9QRbbXE2lOZl7cyqbYNGhZaQJwFZPoAtzPyWJ5tY5PmjMoNdE8diKlGb3jnKH9c6GPiCF5RyIPlV3hSGPabIzaHCbm4oFk67FIjxinqGbeYfWG78jm2tsCaGlD(OMnAIIW5hmnKDmi6K9fbwjzDC2DFKnC)5q8HO52x2fWGxexWsJQjMpjNNYKy6Co46CC7aCA6xaiV8zaxrNnCT7(iB4(ZH4drZTrWSHllnQgaeu0jahcfCKpNyYhzGaaW)bhTbjNhmD59(6lmSoqaaeu0PlW068EPdg5LNir2DFKnC)5q8HO5waoekoOiyP2DFKnC)5q8HO5wac)eMTEbz39r2W9NdXhIMBrBmbWHqHD3hzd3FoeFiAU13b9j25NHZ52DFKnC)5q8HO5wKNoDsxSS(fPjyVIF44tqzk)eUelnQMpI48t6yqu(taUlOdkhbJLcwb9nMeN0XGO8dea7T4q6OnNUq8ZEblyI1bcG2GKZdMU8EF9P1T7(iB4(ZH4drZTipD6KUyz9lsZWhY0bIE8HeaPXK4KyYFem9S0OAaqqrN(qcG0ysCCTqtKOabaG)doAdsopy6Y791NKX2UhwR0pc1r4Pvd4k6SH7BfkeBfY7aCYQoPRFA39r2W9NdXhIMBtCVSrj7S0OAeeack6eGYGeTNuMoKu6NirbcK4EzJYj7tz)pipDaqqrdeaa(p4Oni58GPlV3xFAKK12DFKnC)5q8HO52e3lBukjlnQgbbGGIobOmir7jLPdjL(jsuGajUx2OCk5u2)dYthaeu0abaG)doAdsopy6Y791NgjzTD3Uh2WAfRS3(Lj8B3dRv6L6VvW1QbeYfWGRvj0k2ikYQuMSsI4oTsqaiOOwHeXIvilN(3QuMSkDmikTQFRCaisAvcTs0KD3hzd3FI2B)YAaOmir7jLPdjLEwAunPJbr5m7l6KWJOjWggWJxqaiOOtakds0Esz6qsPFIPlV3xFG5abaqqrNyKuMt)FIW0O)gUtKO4S7(iB4(t0E7xoen3(8EqhFfhrpiwAunaiOOZN3d64R4i6bnX0L37Rp0gKCEW0L37doMqX0l7aCYU7JSH7pr7TF5q0CRO)iphY2D7EydRvmj58u2U7JSH7p)KCEkRr0FKNdzwAun6CC7aCAI2B)YNbCfD2W1U7JSH7p)KCEkhIMB9laKx2U7JSH7p)KCEkhIMBhYKhDEzyYYq6GtN0XGO81WolnQM050MZimj9a3tktNGKZ2KwhGtcWJjDmikN9FaG)RsvQu]] )


end
