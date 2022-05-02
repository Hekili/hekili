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


    spec:RegisterPack( "Outlaw", 20220501, [[d805xbqibvpsqXLuPiytaLpjumkHQoLqLvrer8kbYSqjULGsTlv8lvknmusDmIWYqP6zcLAAQuORjuY2qjrFtaPgNkfvNtajTobeZJOs3JiTpGQoiqLwOa8qIOMOakxuavBeLK6JQueDsusYkvP6LerKMPkfCtusyNcu)uqjnuIiDuvkcTubL4POyQevDvvksBvaj(QkfLXcuXEj5VkAWsomvlgWJvyYeUmYMb5Zaz0KYPLA1eruVgLYSr1Tvj7wPFdz4c54ery5q9CvnDrxhuBNu57cY4jQ48eL5tQA)uwjHsEfJWtsfm7SMD2zDSyTeh2Liw34ngBftklIumr(GnhePyw)IumHv4K7HumrUmoYfk5vmpcgpifJwMrFGC7TG6udg4mqx3(9fm3ZgTdSdL3(914wfdaCZtw1QaumcpjvWSZA2zN1XI1sCyxIyDJ3i7kgho1qyfdtFjzfJwle0Qaumc6hkMWkCY9qwfwqGGj7o4gHBUvSFZzXk2zn7SB3T7swZxq0hi29W2kwHZgzfRMtV2a7qPv9MegdhLw1Rvd0fGNw1qwfISssg(tReTWQoTccHTshI7zZP5J46OnpkgE)5RKxXiiihMNk5vblHsEfJpYgTkg26bBkgADaojubOsvWSRKxXqRdWjHkafJG(bUJYgTkMWc9j58uZQgYQi0)naNSk(fzLoy(syhGtwrlD10BvVwnqxaEgNIXhzJwfZNKZtnvQco2k5vm06aCsOcqXGIumpLkgFKnAvm6CC7aCsXOZ5WKIbNatayiO3k5Af7wbMvXBv4wbadbDsmmnbih3lOdCKvGzv4wbadbDaWix8TGoWrwfNIrq)a3rzJwftyHWio3QVxqCYkayiO3kYXCzwHsncBvQ5RvYJHjRcGCCVGSYxHvbGrU4BbPy05456xKIbNatmHrCUkvbFJk5vm06aCsOcqXGIumpLkgFKnAvm6CC7aCsXOZ5WKIzGUaqZiuV5Feeup60kWl1k2TkiRaGHGoayKl(wqh4iRaZkAjmizwbEPwflwBfywfVvHB1aTc4opde8MZuJMiH4p06aCsyLE9wbadbDWioFMA0eaT0FW0L37Bf4LALeS2Q4umc6h4okB0Qyc89HXKvHiRarPvqWCUvG7fa8RzLKLuRa59(w5RWkhtBmPvycJ48EbzLKrWBAvQrwfwfI3kayiO3kpKltXOZXZ1VifJFba)AZbAfD2OvLQGJLsEfdToaNeQaumOifZtPIXhzJwfJoh3oaNum6ComPygOla0mc1B(wbEPwnIMxUCMFeTcRcBRaGHGoayKl(wqh4iRcBRI3kayiOdkkcHt4Ttzh4iRKKyv6CAZJKaUhSnfyp0HwhGtcRIZk96TIGGOr26O5aDbGMrOEZ3kWl1Qr08YLZ8JOvOye0pWDu2OvXWQ7TFnR80QlxowfH(Vb4KvswsTkuNAi40kKocdXrH6fKvaOf(TAGUaqwfH6nFwScE50)wbHWwfqg4wfsRhAw58qUS3QxdbZfwbqwfRGSsYsQIrNJNRFrkgOE7xBoqROZgTQufmRujVIHwhGtcvakguKIbtpLkgFKnAvm6CC7aCsXOZXZ1VifduV9RnhOv0zJwfZa3jHBxXmqiUafApaugIODMA0KKr)btUqMvGzfbbrJS1rZb6canJq9MVvY1QyPye0pWDu2OvXaU8qUS3kpt6kkTkrwb)KvbKbUvEAvScYkjlPSyfMa5ybN(3keKvswsTceTwfY)KuPk4aTsEfdToaNeQaumOifZtPIXhzJwfJoh3oaNum6ComPy(iIZNPJbr5Fa4UGMqCymwMvY1k2TcmRWElMKoAZJle)PxRaVvSZAR0R3kayiOda3f0eIdJXYoy6Y79Tc8wjHvbzv6CAZdBnN3lO5hHj6qRdWjHIrq)a3rzJwfZnRtnRUG5zhXjRshdIYNfRsT(TsNJBhGtw1VvdnAWgjSkrwjOrliRcPrPgHT6rxKvsoWEREnemxyfaz1lBhKWQqDQzvaCxqwXQ5WySmfJohpx)IumaCxqtiomglB(Y2HkvbFZvYRyO1b4KqfGIzG7KWTRy(KCEQrIJZ5kgFKnAvmy4D6JSr7K3FQy49NZ1VifZNKZtnvQcoqvjVIHwhGtcvakgFKnAvmdNZN(iB0o59NkgE)5C9lsXmeVkvblbRvYRyO1b4KqfGIzG7KWTRy0542b40bQ3(1Md0k6SrRIXhzJwfdgEN(iB0o59NkgE)5C9lsXa1B)AQufSesOKxXqRdWjHkafJpYgTkMHZ5tFKnAN8(tfdV)CU(fPyaGBUqLQGLGDL8kgADaojubOyg4ojC7kgAjmizhbb1JoTc8sTsIyzvqwrlHbj7Gjq0Qy8r2OvX44HV0mrymTPkvblrSvYRy8r2OvX44HV0mcM)KIHwhGtcvaQufSe3OsEfJpYgTkgEdsl)PKmSa0fTPIHwhGtcvaQufSeXsjVIXhzJwfdGdAIGMjUhS9kgADaojubOsvQyIW0aDb4PsEvWsOKxX4JSrRIXJI4YMrO(rRIHwhGtcvaQufm7k5vm(iB0QyaqzYjXeI7YirOEbntKC6vXqRdWjHkavQco2k5vm(iB0Qy(KCEQPyO1b4KqfGkvbFJk5vm06aCsOcqX4JSrRI5YXSrIjecpfKNAkMbUtc3UIb7Tys6OnpUq8NETc8wXESumryAGUa8C(0aTIxXelvQcowk5vm06aCsOcqXmWDs42vmpcMd0R4eb)jmNMegokB0EO1b4KWk96T6rWCGEfhDiUNnNMpIRJ28qRdWjHIXhzJwfdeNETb2HsvQcMvQKxXqRdWjHkafJpYgTkgmIZNPgnbql9kMbUtc3UIbtxEVVvY1QyRyIW0aDb458PbAfVIHDvQcoqRKxXqRdWjHkafJpYgTkMN3dA6Ryk6bPyg4ojC7kgmbHPxZb4KIjctd0fGNZNgOv8kg2vPkvmaWnxOKxfSek5vm(iB0QyEk67xXqRdWjHkavQcMDL8kgADaojubOyg4ojC7kgbbadbDaPH(KlB(jUzJoy6Y79TsUsTk2kgFKnAvmG0qFYLn)e3SrQufCSvYRyO1b4KqfGIzG7KWTRyWWlbHWGOt2RSzIKtpMaCxqhADaojum(iB0QyETwNkvbFJk5vm06aCsOcqXmWDs42vmHB1JG5a9koeee836OPV9Lp9XG4e2te(qRdWjHv61BLoh3oaNoaCxqtiomglB(Y2HIXhzJwfdn0q9cAIPiCF5RqLQGJLsEfdToaNeQaum(iB0QyEcJ9Keta0sZpQzJumc6h4okB0Qya3OiUmRycGXQezLZ5wLogeLVvH6udbNw5wjiayiiR83QiCJWDkJfRIWeeHX9cYQ0XGO8TsiRxqw9i0syRCOKWwLAKvr4(YXYSkDmikvmdCNeUDft4wjq55jm2tsmbqln)OMnAkq5j7bB9csLQGzLk5vm06aCsOcqX4JSrRI5jm2tsmbqln)OMnsXmWDs42vmHBLaLNNWypjXeaT08JA2OPaLNShS1lifZq2GtZ0XGO8vblHkvbhOvYRyO1b4KqfGIXhzJwfZtySNKycGwA(rnBKIrq)a3rzJwfd4MjDfLwLiRGFYQqA0AvNwfQ5CRgEKvd0faYQiuV5BLVcRy2aZQ(TsGcTSyfk1iCO(jRyJOiRGWOlRgEuuVGSAO5yq0Ryg4ojC7kgOgKwoX0L37BLCLAvSSsVERgiexGcTNNWypjXeaT08JA2OZLlN5qZXGO3QW2QHMJbr)ec7JSrRZTsUsTI1h2JLv61B1aDbGMrOEZ)iiOE0PvsTAenb59AfywfUvaWqqNNnyoF6RyoWO)bql9h4iRaZkAjmizNSVOzIMxUCSc8wjHkvbFZvYRyO1b4KqfGIXhzJwftu)jIpFnuQye0pWDu2OvXCtFYkjT)eXTIrdLwfQtnRcRrriCcVDkZQgYkjJUa80kjfL0oKzvi0gtAfshHhEKv0syqYyXQqA0AvNwfQ5CRi54JKlZQHhzLKLuwScHTkKgTwb)9cYQBIW9GnRcmShsXmWDs42vmaWqqhuuecNWBNYoWrwbMvXBfTegKSJGG6rNwbERI3kAjmizhmbIwRcYkjyTvXzLE9wnqxaOzeQ38pccQhDALCLALewfKvaWqqhamYfFlOdCKv61Bv6CAZJKaUhSnfyp0HwhGtcRItLQGduvYRyO1b4KqfGIzG7KWTRyaGHGoOOieoH3oLDGJScmRI3kayiOdimr7ZwV)mupyJW)boYk96Tcagc6mq7GCojMaC4vqya4)pWrwPxVvaWqqNeHxxGMjUbbIWh4iRItX4JSrRIjQ)eXNVgkvPkyjyTsEfJpYgTkMV3(tcp)e3SrkgADaojubOsvWsiHsEfdToaNeQaumdCNeUDft6CAZJOXPSzI7bB)HwhGtcRaZQb6canJq9M)rqq9OtRaVuRKWQGScagc6aGrU4BbDGJum(iB0QyaHGbrQuLkMH4vYRcwcL8kgADaojubOy8r2OvXaWDbnH4WySmfJG(bUJYgTkMa4UGSIvZHXyzwHwRypiROLUA6vmdCNeUDfZhrC(mDmikFRaVuRy3kWSkCRaGHGoaCxqtiomgl7ahPsvWSRKxXqRdWjHkafJpYgTkgD(2VMIrq)a3rzJwfZn97fKvG7fa8Rzv)w5wX(nbR6DGj)jwS6rwfO4B)Awn81kaYQhDrzFrVvaKvWpjSYFRCRGZM3PmR(iIZTcE50)wb)9cYkwH)jHTcC)3)VxRqyRcmYtnUmRy0Cbk0Ryg4ojC7kMWTcdVeecdIoxoMTjcAMA08Y)KWt)F))Ep06aCsyfywfUvy4LGqyq0PxDnie2ZEbnFnxGcjG)8qRdWjHvGzv4w9j58uJehNZTcmR0542b40XVaGFT5aTIoB0AfywfVvHBfgEjiegeDeKNACzZxZfOq)HwhGtcR0R3kayiOJG8uJlB(AUaf6pcuO1kWSAGUaqZiuV5BLCLAf7wfNkvbhBL8kgADaojubOyqrkMNsfJpYgTkgDoUDaoPy05456xKIrNV9RnV85aTIoB0Qyg4ojC7kgm8sqimi6C5y2MiOzQrZl)tcp9)9)79qRdWjHvGzv4wLoN28C5y2iXecHNcYtTdToaNekgb9dChLnAvm3So1SIv4FsyRa3)F))EzXQx2oSkqX3(1SkuNAw5wb1B)Ae2ke2kW9ca(1Ssqr0k6fKvO1QaYa3QbcXfOqllwHWw58qUS3k3kOE7xJWwfQtnRyfqbMIrNZHjft8wfUvdeIlqH2daLHiANPgnjz0FWKlKzfywPZXTdWPduV9RnhOv0zJwRIZk96TkERgiexGcThakdr0otnAsYO)GjxiZkWSsNJBhGth)ca(1Md0k6SrRvXPsvW3OsEfdToaNeQaumOifZtPIXhzJwfJoh3oaNum6ComPy0542b40bQ3(1Md0k6SrRIzG7KWTRyWWlbHWGOZLJzBIGMPgnV8pj80)3)V3dToaNewbMvPZPnpxoMnsmHq4PG8u7qRdWjHIrNJNRFrkgD(2V28YNd0k6SrRkvbhlL8kgADaojubOyg4ojC7kgDoUDaoD05B)AZlFoqROZgTwbMvx(NeE6)7)37etxEVVvsTI1wbMv6CC7aC6aWDbnH4WySS5lBhkgFKnAvm68TFnvQcMvQKxXqRdWjHkafZa3jHBxXeUvaWqqhxGP159stm8RDGJum(iB0QyCbMwN3lnXWVMkvbhOvYRyO1b4KqfGIrq)a3rzJwfdRMtV2a7qPvqiSvsk8NWCYQahdhLnATQHSArPvFsop1iHv(kSArPvH6uZQa4UGSIvZHXyzkMbUtc3UIjEREemhOxXjc(tyonjmCu2O9qRdWjHv61B1JG5a9ko6qCpBonFexhT5HwhGtcRIZkWSkCR(KCEQrIJZ5wbMvXBv4wbadbDa4UGMqCymw2boYk96T6JioFMogeL)bG7cAcXHXyzwjxRy3Q4ScmRI3QWTcagc64cmToVxAIHFTdCKv61BfTegKSt2x0mrZlxowbERy3Q4um9MegdhLZgsX8iyoqVIJoe3ZMtZhX1rBQy6njmgokN91fjApjfJekgFKnAvmqC61gyhkvm9MegdhLtqCeGZvmsOsvW3CL8kgADaojubOyg4ojC7kMWT6tY5PgjooNBfywfVv6CC7aC6a1B)AZbAfD2O1k96TkDmikpzFrZenfnzLCTsIyBvCkgFKnAvmqCheX5E2OvLQGduvYRyO1b4KqfGIzG7KWTRyc3QpjNNAK44CUvGz1aDbGMrOEZ3k5k1k2TcmRI3QWTAG0rRV5rhTPMmSv61BLGaGHGoqCheX5E2O9ahzvCwbMvXBv4wLoN28C5y2iXecHNcYtTdToaNewPxVvHB1aH4cuO9C5y2iXecHNcYtTdMCHmRItX4JSrRIrGjxaWDb9QufSeSwjVIHwhGtcvakMbUtc3UI5Y)KWt)F))ENy6Y79TsQvS2kWScagc6iWKla4UG(JafATcmRI3kayiOdgX5ZuJMaOL(dMU8EFRKRuRITv61BLoh3oaNo4eyIjmIZTkofJpYgTkgmIZNPgnbql9QufSesOKxXqRdWjHkafJpYgTkMlhZgjMqi8uqEQPy49sZHqXiXjwkMHSbNMPJbr5RcwcfZa3jHBxXG9wmjD0Mhxi(dCKvGzv8wLogeLNSVOzIMIMSsUwnqxaOzeQ38pccQhDALE9wfUvFsop1iXbJabtwbMvd0faAgH6n)JGG6rNwbEPwnIMxUCMFeTcRcBRKWQ4umc6h4okB0Qyyvqw5cXBLJjRGJyXQF7iYQuJScTKvH6uZkoke9PvYlFGDS6M(KvH0O1kHSEbzfK)jHTk181kjlPwjiOE0PviSvH6udbNw5RmRKSKEuPkyjyxjVIHwhGtcvakgFKnAvmxoMnsmHq4PG8utXiOFG7OSrRIHvbz1ISYfI3QqnNBLOjRc1PwVwLAKvljN0QyZ6NfRGFYkwbuGzfATca9VvH6udbNw5RmRKSKEumdCNeUDfd2BXK0rBECH4p9Af4Tk2S2QW2kS3IjPJ284cXFeWypB0AfywfUvFsop1iXbJabtwbMvd0faAgH6n)JGG6rNwbEPwnIMxUCMFeTcRcBRKWkWSkERc3QbshT(MhD0MAYWwPxVvdeIlqH2de3brCUNnApy6Y79Tc8wjbRTsVEReeame0bI7Gio3ZgTh4iRItLQGLi2k5vm06aCsOcqXGIumpLkgFKnAvm6CC7aCsXOZ5WKIjCRWWlbHWGOZLJzBIGMPgnV8pj80)3)V3dToaNewPxVvdeIlqH2JoF7x7GPlV33kWBLeS2k96T6Y)KWt)F))ENy6Y79Tc8wXUIrq)a3rzJwfd4MjDfLwLiREz7WkjPnN3liRyIWezvOo1SkqX3(1SccHTIv4FsyRa3)9)7vXOZXZ1VifdBnN3lO5hHjAQZ3(1MVSDOsvWsCJk5vm06aCsOcqX4JSrRIHTMZ7f08JWePye0pWDu2OvXCtFYQETsIWMD5TQHSkGmWTQFRGJSYxHvHqBmPvdpYQaFjmizSyfcBLNwfB5dYQ4zx(GSkuNAwfyKNACzwXO5cuOpoRqyRcPrRvSc)tcBf4(V)FVw1VvWrhfZa3jHBxXOZXTdWPda3f0eIdJXYMVSDyfywPZXTdWPdBnN3lO5hHjAQZ3(1MVSDyfywfUvFsop1iXbJabtwbMvXBLGaGHGoaugIODMA0KKr)boYkWScagc6iWKla4UG(JafATcmROLWGKDeeup60kWBv8wrlHbj7Gjq0ALKeRy3QGSsIyzvCwPxVvFeX5Z0XGO8paCxqtiomglZkWBv8wXUvHTvaWqqhb5Pgx281Cbk0FGJSkoR0R3Ql)tcp9)9)7DIPlV33kWBfRTkovQcwIyPKxXqRdWjHkafZa3jHBxXOZXTdWPda3f0eIdJXYMVSDyfywfVv0syqYozFrZenVC5yf4TIDRaZkayiOJatUaG7c6pcuO1k96TIwcdsMvYvQvXM1wPxVvFeX5Z0XGO8Tc8wXUvXPy8r2OvXaWDbnXWVMkvblbRujVIHwhGtcvakgFKnAvm68TFnfJG(bUJYgTkgwfKvWFVGSIvT6AqiSN9cYkgnxGcjG)KfRGFYQfHVCUvCeOEyvVw5crNnATkrwn0ObB9cYQlxsgHTsYb2FumdCNeUDfdgEjiegeD6vxdcH9SxqZxZfOqc4pp06aCsyfywnq6O138OJ2utg2kWSkCR(KCEQrIJZ5wbMv6CC7aC64xaWV2CGwrNnATcmRI3QWTAGqCbk0EG4oiIZ9Sr7btUqMvGzv8wfUvPZPnpcm5caUlO)qRdWjHv61Bv4wnqiUafApcm5caUlO)GjxiZk96TkCReeame0bI7Gio3ZgTh4iRIZQ4uPkyjc0k5vm06aCsOcqXmWDs42vmy4LGqyq0PxDnie2ZEbnFnxGcjG)8qRdWjHvGzv4wnq6O138OJ2utg2kWSkCR(KCEQrIJZ5wbMvXB1aH4cuO9qdnuVGMykc3x(koy6Y79Tc8wXkTsVERc3QbcXfOq75POV)dMCHmR0R3QbcXfOq75jm2tsmbqln)OMn6abZ5tmn0CmiAM9fzf4TIDwBvCkgFKnAvm68TFnvQcwIBUsEfdToaNeQaumdCNeUDft4w9j58uJehNZTcmR0542b40XVaGFT5aTIoB0Qy8r2OvX8AUaf6I4cvQcwIavL8kgADaojubOyg4ojC7kgayiOdahHeC4ppyYhPv61Bfa6FRaZkOgKwoX0L37BLCTk2S2k96Tcagc64cmToVxAIHFTdCKIXhzJwftekB0QsvWSZAL8kgFKnAvmaCesmHGXYum06aCsOcqLQGzxcL8kgFKnAvmae(jmB9csXqRdWjHkavQcMD2vYRy8r2OvXa1ycGJqcfdToaNeQauPky2JTsEfJpYgTkgFh0NyNphoNRyO1b4KqfGkvbZ(nQKxXqRdWjHkafJpYgTkMq9k(HJNH0O8t0skMbUtc3UI5JioFMogeL)bG7cAcXHXyzwbERe03ysmthdIY3k96Tc7Tys6OnpUq8NETc8wXkzTv61Bfa6FRaZkOgKwoX0L37BLCTkqRyw)IumH6v8dhpdPr5NOLuPky2JLsEfdToaNeQaum(iB0Qyg(qJMiOPpKeWnMeZet(dJPxXmWDs42vmaWqqhFijGBmjMUCOdCKv61Bfa6FRaZkOgKwoX0L37BLCTI9yPyw)IumdFOrte00hsc4gtIzIj)HX0RsvWSZkvYRyO1b4KqfGIXhzJwfZpC8prqtiSNeED(8tCdrkMbUtc3UIjCRaGHGo)WX)ebnHWEs415ZpXnenVXdCKv61Bfa6FRaZkOgKwoX0L37BLCTk2SwXS(fPy(HJ)jcAcH9KWRZNFIBisLQGzpqRKxXqRdWjHkafJpYgTkMe3lBukHIrq)a3rzJwftGrqompTAGwrNnAFRGqyRGFhGtw1jD9hfZa3jHBxXiiayiOdaLHiANPgnjz0FGJSsVERsCVSr5jL4O5)e(PjameKv61Bfa6FRaZkOgKwoX0L37BLCLAf7SwLQGz)MRKxXqRdWjHkafZa3jHBxXiiayiOdaLHiANPgnjz0FGJSsVERsCVSr5jz)O5)e(PjameKv61Bfa6FRaZkOgKwoX0L37BLCLAf7SwX4JSrRIjX9YgLSRsvQy(KCEQPKxfSek5vm06aCsOcqXmWDs42vm6CC7aC6a1B)AZbAfD2OvX4JSrRIr0FKNdnvQcMDL8kgFKnAvm(fa8RPyO1b4KqfGkvbhBL8kgADaojubOy8r2OvXm0ipA(AOuXmWDs42vmPZPnprys2eTZuJMHiNTdToaNewbMvHBv6yquE6FcG(xXmKn40mDmikFvWsOsvQyG6TFnL8QGLqjVIHwhGtcvakgFKnAvmaugIODMA0KKrVIrq)a3rzJwftazGBfATAGqCbk0AvISInIISk1iRKmUtReeameKvWrSyf8YP)Tk1iRshdIsR63khabNwLiRenPyg4ojC7kM0XGO8K9fnt0u0KvG3QyBfywfVvccagc6aqziI2zQrtsg9hmD59(wjxRUrR0R3kayiOdgo140)Zimn6Vr7boYQ4uPky2vYRyO1b4KqfGIzG7KWTRyaGHGopVh00xXu0d6GPlV33k5AfudslNy6Y79TcmRWeeMEnhGtkgFKnAvmpVh00xXu0dsLQGJTsEfJpYgTkgr)rEo0um06aCsOcqLQuLkgDe(B0QcMDwZo7So2selftihV9c6vm3mWnSemRk4BYaXkRKxJSQVIq40kie2QyeeKdZZySctsc4gtcRE0fzLdNOlpjHvdnFbr)XUFd9swDJbIvsgT6iCscRIzGwbCNhWjgRsKvXmqRaUZd4CO1b4KigRIxc5e3XUB3VzGByjywvW3KbIvwjVgzvFfHWPvqiSvXeHPb6cWZySctsc4gtcRE0fzLdNOlpjHvdnFbr)XUFd9swfRaXkjJwDeojHvX8iyoqVId4eJvjYQyEemhOxXbCo06aCseJvXlHCI7y3VHEjRIvGyLKrRocNKWQyEemhOxXbCIXQezvmpcMd0R4aohADaojIXkpTkWdR3GvXlHCI7y3T73mWnSemRk4BYaXkRKxJSQVIq40kie2QygIpgRWKKaUXKWQhDrw5Wj6Ytsy1qZxq0FS73qVKvShiwjz0QJWjjSkgm8sqimi6aoXyvISkgm8sqimi6aohADaojIXQ4JTCI7y3VHEjRIDGyLKrRocNKWQyWWlbHWGOd4eJvjYQyWWlbHWGOd4CO1b4KigRIxc5e3XUFd9swDJbIvsgT6iCscRIbdVeecdIoGtmwLiRIbdVeecdIoGZHwhGtIySkEjKtCh7(n0lzvGoqSsYOvhHtsyvmpcMd0R4aoXyvISkMhbZb6vCaNdToaNeXyv8SlN4o29BOxYQa1aXkjJwDeojHvXKoN28aoXyvISkM050MhW5qRdWjrmwfVeYjUJD)g6LSsIyhiwjz0QJWjjSkgm8sqimi6aoXyvISkgm8sqimi6aohADaojIXQ4LqoXDS73qVKvsWkdeRKmA1r4Kewft6CAZd4eJvjYQysNtBEaNdToaNeXyv8siN4o29BOxYkjyLbIvsgT6iCscRIbdVeecdIoGtmwLiRIbdVeecdIoGZHwhGtIySkEjKtCh7(n0lzLeb6aXkjJwDeojHvXGHxccHbrhWjgRsKvXGHxccHbrhW5qRdWjrmwfVeYjUJD)g6LSI9aDGyLKrRocNKWQysCVSr5rId4eJvjYQysCVSr5jL4aoXyv8siN4o29BOxYk2V5bIvsgT6iCscRIjX9YgLh2pGtmwLiRIjX9YgLNK9d4eJvXlHCI7y3T73mWnSemRk4BYaXkRKxJSQVIq40kie2QyaGBUigRWKKaUXKWQhDrw5Wj6Ytsy1qZxq0FS73qVKvXoqSsYOvhHtsyvmy4LGqyq0bCIXQezvmy4LGqyq0bCo06aCseJvEAvGhwVbRIxc5e3XUFd9swDJbIvsgT6iCscRI5rWCGEfhWjgRsKvX8iyoqVId4CO1b4KigRIxc5e3XUB3zvxriCscRyLw5JSrRv8(Z)y3vmFenubZoRK1kMimcQ5KIjmHXQWkCY9qwfwqGGj7EycJvGBeU5wX(nNfRyN1SZUD3UhMWyLK18fe9bIDpmHXQW2kwHZgzfRMtV2a7qPv9MegdhLw1Rvd0fGNw1qwfISssg(tReTWQoTccHTshI7zZP5J46Onp2D7EycJvbUCObCscRaiieMSAGUa80kacuV)XkWDmOO8TArByR54liyUv(iB0(wHwUSJD3hzJ2)eHPb6cWtPEuex2mc1pAT7(iB0(NimnqxaEgK0BbqzYjXeI7YirOEbntKC61U7JSr7FIW0aDb4zqsV9tY5PMD3hzJ2)eHPb6cWZGKE7LJzJetieEkip1yjctd0fGNZNgOv8sJflnKuS3IjPJ284cXF6f8Shl7UpYgT)jctd0fGNbj9wio9AdSdLS0qsFemhOxXjc(tyonjmCu2OvV(hbZb6vC0H4E2CA(iUoAt7UpYgT)jctd0fGNbj9wmIZNPgnbql9SeHPb6cWZ5td0kEPSZsdjftxEVVCJTD3hzJ2)eHPb6cWZGKE7Z7bn9vmf9Gyjctd0fGNZNgOv8szNLgskMGW0R5aCYUB3dtySkWLdnGtsyfPJWYSk7lYQuJSYhjcBv)w568M7aC6y39r2O9LYwpyZUhgRcl0NKZtnRAiRIq)3aCYQ4xKv6G5lHDaozfT0vtVv9A1aDb4zC2DFKnA)GKE7NKZtn7EySkSqyeNB13liozfame0Bf5yUmRqPgHTk181k5XWKvbqoUxqw5RWQaWix8TGS7(iB0(bj9wDoUDaoXY6xKuCcmXegX5SOZ5WKuCcmbGHGE5YoyXhoame0jXW0eGCCVGoWrGfoame0baJCX3c6ahfNDpmwf47dJjRcrwbIsRGG5CRa3la4xZkjlPwbY79TYxHvoM2ysRWegX59cYkjJG30QuJSkSkeVvaWqqVvEixMD3hzJ2piP3QZXTdWjww)IK6xaWV2CGwrNnAzrNZHjPd0faAgH6n)JGG6rNGxk7bbadbDaWix8TGoWrGrlHbjd8sJfRbl(WhOva35zGG3CMA0ejeVE9aWqqhmIZNPgnbql9hmD59(GxQeSoo7EySIv3B)Aw5PvxUCSkc9FdWjRKSKAvOo1qWPviDegIJc1liRaql8B1aDbGSkc1B(Syf8YP)TccHTkGmWTkKwp0SY5HCzVvVgcMlScGSkwbzLKLu7UpYgTFqsVvNJBhGtSS(fjfQ3(1Md0k6Srll6ComjDGUaqZiuV5dEPJO5LlN5hrRiSbGHGoayKl(wqh4OWoEayiOdkkcHt4Ttzh4ijjPZPnpsc4EW2uG9qhADaojItVEccIgzRJMd0faAgH6nFWlDenVC5m)iAf29Wyf4Yd5YER8mPRO0Qezf8twfqg4w5PvXkiRKSKYIvycKJfC6FRqqwjzj1kq0Avi)tYU7JSr7hK0B1542b4elRFrsH6TFT5aTIoB0YckskMEkzPHKoqiUafApaugIODMA0KKr)btUqgyeeenYwhnhOla0mc1B(Ynw29Wy1nRtnRUG5zhXjRshdIYNfRsT(TsNJBhGtw1VvdnAWgjSkrwjOrliRcPrPgHT6rxKvsoWEREnemxyfaz1lBhKWQqDQzvaCxqwXQ5WySm7UpYgTFqsVvNJBhGtSS(fjfG7cAcXHXyzZx2oyrNZHjPFeX5Z0XGO8paCxqtiomgltUSdg2BXK0rBECH4p9cE2zTE9aWqqhaUlOjehgJLDW0L37dEjckDoT5HTMZ7f08JWeDO1b4KWU7JSr7hK0BXW70hzJ2jV)KL1ViPFsop1yPHK(j58uJehNZT7(iB0(bj92HZ5tFKnAN8(tww)IKoeVD3hzJ2piP3IH3PpYgTtE)jlRFrsH6TFnwAiP6CC7aC6a1B)AZbAfD2O1U7JSr7hK0BhoNp9r2ODY7pzz9lskaCZf2DFKnA)GKERJh(sZeHX0MS0qsPLWGKDeeup6e8sLiwbrlHbj7Gjq0A39r2O9ds6ToE4lnJG5pz39r2O9ds6T8gKw(tjzybOlAt7UpYgTFqsVfWbnrqZe3d2E7UDpmHXQaGBUGWVD3hzJ2)aa3CH0NI((T7(iB0(ha4Mlcs6TG0qFYLn)e3SrS0qsfeame0bKg6tUS5N4Mn6GPlV3xUsJTD3hzJ2)aa3CrqsV91ADS0qsXWlbHWGOt2RSzIKtpMaCxq2DFKnA)daCZfbj9wAOH6f0etr4(YxblnK0WFemhOxXHGGG)whn9TV8PpgeNWEIW61RZXTdWPda3f0eIdJXYMVSDy3dJvGBuexMvmbWyvISY5CRshdIY3QqDQHGtRCReeameKv(BveUr4oLXIvrycIW4Ebzv6yqu(wjK1liREeAjSvousyRsnYQiCF5yzwLogeL2DFKnA)daCZfbj92NWypjXeaT08JA2iwAiPHlq55jm2tsmbqln)OMnAkq5j7bB9cYU7JSr7FaGBUiiP3(eg7jjMaOLMFuZgXYq2GtZ0XGO8LkblnK0WfO88eg7jjMaOLMFuZgnfO8K9GTEbz3dJvGBM0vuAvISc(jRcPrRvDAvOMZTA4rwnqxaiRIq9MVv(kSIzdmR63kbk0YIvOuJWH6NSInIISccJUSA4rr9cYQHMJbrVD3hzJ2)aa3CrqsV9jm2tsmbqln)OMnILgskudslNy6Y79LR0yPx)aH4cuO98eg7jjMaOLMFuZgDUC5mhAoge9H9qZXGOFcH9r2O15YvkRpShl96hOla0mc1B(hbb1JoLoIMG8EblCayiOZZgmNp9vmhy0)aOL(dCey0syqYozFrZenVC5aEjS7HXQB6twjP9NiUvmAO0QqDQzvynkcHt4Ttzw1qwjz0fGNwjPOK2HmRcH2ysRq6i8WJSIwcdsglwfsJwR60QqnNBfjhFKCzwn8iRKSKYIviSvH0O1k4VxqwDteUhSzvGH9q2DFKnA)daCZfbj92O(teF(AOKLgskame0bffHWj82PSdCeyXtlHbj7iiOE0j4JNwcds2btGOnijyDC61pqxaOzeQ38pccQhDkxPseeame0baJCX3c6ahPxF6CAZJKaUhSnfyp0HwhGtI4S7(iB0(ha4Mlcs6Tr9Ni(81qjlnKuayiOdkkcHt4Ttzh4iWIhagc6act0(S17pd1d2i8FGJ0Rhagc6mq7GCojMaC4vqya4)pWr61dadbDseEDbAM4geicFGJIZU7JSr7FaGBUiiP3(92Fs45N4MnYU7JSr7FaGBUiiP3ccbdIyPHKMoN28iACkBM4EW2FO1b4KaSb6canJq9M)rqq9OtWlvIGaGHGoayKl(wqh4i7UDpmHXkjJqCbk0(29WyvaCxqwXQ5WySmRqRvShKv0sxn92DFKnA)Zq8sb4UGMqCymwglnK0pI48z6yqu(Gxk7Gfoame0bG7cAcXHXyzh4i7EyS6M(9cYkW9ca(1SQFRCRy)MGv9oWK)elw9iRcu8TFnRg(Afaz1JUOSVO3kaYk4New5VvUvWzZ7uMvFeX5wbVC6FRG)EbzfRW)KWwbU)7)3RviSvbg5PgxMvmAUaf6T7(iB0(NH4ds6T68TFnwAiPHJHxccHbrNlhZ2ebntnAE5Fs4P)V)FVGfogEjiegeD6vxdcH9SxqZxZfOqc4pbl8pjNNAK44Coy6CC7aC64xaWV2CGwrNnAbl(WXWlbHWGOJG8uJlB(AUaf61Rhagc6iip14YMVMlqH(JafAbBGUaqZiuV5lxPShNDpmwDZ6uZkwH)jHTcC))9)7LfREz7WQafF7xZQqDQzLBfuV9RryRqyRa3la4xZkbfrROxqwHwRcidCRgiexGcTSyfcBLZd5YERCRG6TFncBvOo1SIvafy2DFKnA)Zq8bj9wDoUDaoXY6xKuD(2V28YNd0k6SrllnKum8sqimi6C5y2MiOzQrZl)tcp9)9)7fSWtNtBEUCmBKycHWtb5P2HwhGtcw05CysA8HpqiUafApaugIODMA0KKr)btUqgy6CC7aC6a1B)AZbAfD2Ono96JFGqCbk0EaOmer7m1OjjJ(dMCHmW0542b40XVaGFT5aTIoB0gND3hzJ2)meFqsVvNJBhGtSS(fjvNV9RnV85aTIoB0YsdjfdVeecdIoxoMTjcAMA08Y)KWt)F))EblDoT55YXSrIjecpfKNAhADaojyrNZHjP6CC7aC6a1B)AZbAfD2O1U7JSr7FgIpiP3QZ3(1yPHKQZXTdWPJoF7xBE5ZbAfD2OfSl)tcp9)9)7DIPlV3xkRbtNJBhGthaUlOjehgJLnFz7WU7JSr7FgIpiP36cmToVxAIHFnwAiPHdadbDCbMwN3lnXWV2boYUhgRy1C61gyhkTccHTssH)eMtwf4y4OSrRvnKvlkT6tY5PgjSYxHvlkTkuNAwfa3fKvSAomglZU7JSr7FgIpiP3cXPxBGDOKLgsA8pcMd0R4eb)jmNMegokB0Qx)JG5a9ko6qCpBonFexhTzCGf(NKZtnsCCohS4dhagc6aWDbnH4WySSdCKE9FeX5Z0XGO8paCxqtiomgltUShhyXhoame0XfyADEV0ed)Ah4i96PLWGKDY(IMjAE5Yb8Shhl9MegdhLZ(6IeTNKujyP3KWy4OCcIJaCUujyP3KWy4OC2qsFemhOxXrhI7zZP5J46OnT7(iB0(NH4ds6TqCheX5E2OLLgsA4Fsop1iXX5CWIxNJBhGthOE7xBoqROZgT61NogeLNSVOzIMIMKReXoo7UpYgT)zi(GKERatUaG7c6zPHKg(NKZtnsCCohSb6canJq9MVCLYoyXh(aPJwFZJoAtnzy96feame0bI7Gio3ZgTh4O4al(WtNtBEUCmBKycHWtb5PME9HpqiUafApxoMnsmHq4PG8u7Gjxilo7UpYgT)zi(GKElgX5ZuJMaOLEwAiPx(NeE6)7)37etxEVVuwdgame0rGjxaWDb9hbk0cw8aWqqhmIZNPgnbql9hmD59(YvAS1RxNJBhGthCcmXegX5Xz3dJvSkiRCH4TYXKvWrSy1VDezvQrwHwYQqDQzfhfI(0k5LpWowDtFYQqA0ALqwVGScY)KWwLA(ALKLuReeup60ke2QqDQHGtR8vMvswsp2DFKnA)Zq8bj92lhZgjMqi8uqEQXcVxAoesL4elwgYgCAMogeLVujyPHKI9wmjD0Mhxi(dCeyXNogeLNSVOzIMIMK7aDbGMrOEZ)iiOE0PE9H)j58uJehmcemb2aDbGMrOEZ)iiOE0j4LoIMxUCMFeTIWwI4S7HXkwfKvlYkxiERc1CUvIMSkuNA9AvQrwTKCsRInRFwSc(jRyfqbMvO1ka0)wfQtneCALVYSsYs6XU7JSr7FgIpiP3E5y2iXecHNcYtnwAiPyVftshT5XfI)0l4JnRdBS3IjPJ284cXFeWypB0cw4Fsop1iXbJabtGnqxaOzeQ38pccQhDcEPJO5LlN5hrRiSLaS4dFG0rRV5rhTPMmSE9deIlqH2de3brCUNnApy6Y79bVeSwVEbbadbDG4oiIZ9Sr7boko7EyScCZKUIsRsKvVSDyLK0MZ7fKvmryISkuNAwfO4B)AwbHWwXk8pjSvG7)()9A39r2O9pdXhK0B1542b4elRFrszR58Ebn)imrtD(2V28LTdw05CysA4y4LGqyq05YXSnrqZuJMx(NeE6)7)3RE9deIlqH2JoF7x7GPlV3h8sWA96V8pj80)3)V3jMU8EFWZUDpmwDtFYQETsIWMD5TQHSkGmWTQFRGJSYxHvHqBmPvdpYQaFjmizSyfcBLNwfB5dYQ4zx(GSkuNAwfyKNACzwXO5cuOpoRqyRcPrRvSc)tcBf4(V)FVw1VvWrh7UpYgT)zi(GKElBnN3lO5hHjILgsQoh3oaNoaCxqtiomglB(Y2by6CC7aC6WwZ59cA(ryIM68TFT5lBhGf(NKZtnsCWiqWeyXliayiOdaLHiANPgnjz0FGJadagc6iWKla4UG(JafAbJwcds2rqq9OtWhpTegKSdMarRKe2dsIyfNE9FeX5Z0XGO8paCxqtiomgld8XZEydadbDeKNACzZxZfOq)boko96V8pj80)3)V3jMU8EFWZ64S7(iB0(NH4ds6TaCxqtm8RXsdjvNJBhGthaUlOjehgJLnFz7aS4PLWGKDY(IMjAE5Yb8Sdgame0rGjxaWDb9hbk0QxpTegKm5kn2SwV(pI48z6yqu(GN94S7HXkwfKvWFVGSIvT6AqiSN9cYkgnxGcjG)KfRGFYQfHVCUvCeOEyvVw5crNnATkrwn0ObB9cYQlxsgHTsYb2FS7(iB0(NH4ds6T68TFnwAiPy4LGqyq0PxDnie2ZEbnFnxGcjG)eSbshT(MhD0MAYWGf(NKZtnsCCohmDoUDaoD8la4xBoqROZgTGfF4deIlqH2de3brCUNnApyYfYal(WtNtBEeyYfaCxqVE9HpqiUafApcm5caUlO)GjxitV(Wfeame0bI7Gio3ZgTh4O4IZU7JSr7FgIpiP3QZ3(1yPHKIHxccHbrNE11Gqyp7f081CbkKa(tWcFG0rRV5rhTPMmmyH)j58uJehNZbl(bcXfOq7HgAOEbnXueUV8vCW0L37dEwPE9HpqiUafAppf99FWKlKPx)aH4cuO98eg7jjMaOLMFuZgDGG58jMgAogenZ(Iap7Soo7UpYgT)zi(GKE7R5cuOlIlyPHKg(NKZtnsCCohmDoUDaoD8la4xBoqROZgT2DFKnA)Zq8bj92iu2OLLgskame0bGJqco8Nhm5JuVEa0)Gb1G0YjMU8EF5gBwRxpame0XfyADEV0ed)Ah4i7UpYgT)zi(GKElahHetiySm7UpYgT)zi(GKElaHFcZwVGS7(iB0(NH4ds6TqnMa4iKWU7JSr7FgIpiP367G(e785W5C7UpYgT)zi(GKEl8tZoPlww)IKgQxXpC8mKgLFIwILgs6hrC(mDmik)da3f0eIdJXYaVG(gtIz6yqu(61J9wmjD0Mhxi(tVGNvYA96bq)dgudslNy6Y79LBG2U7JSr7FgIpiP3c)0St6IL1ViPdFOrte00hsc4gtIzIj)HX0Zsdjfagc64djbCJjX0LdDGJ0Rha9pyqniTCIPlV3xUShl7UpYgT)zi(GKEl8tZoPlww)IK(dh)te0ec7jHxNp)e3qelnK0WbGHGo)WX)ebnHWEs415ZpXnenVXdCKE9aO)bdQbPLtmD59(Yn2S2UhgRcmcYH5Pvd0k6Sr7BfecBf87aCYQoPR)y39r2O9pdXhK0BtCVSrPeS0qsfeame0bGYqeTZuJMKm6pWr61N4EzJYJehn)NWpnbGHG0Rha9pyqniTCIPlV3xUszN12DFKnA)Zq8bj92e3lBuYolnKubbadbDaOmer7m1OjjJ(dCKE9jUx2O8W(rZ)j8ttayii96bq)dgudslNy6Y79LRu2zTD3UhMWyfRU3(1i8B3dJvbKbUvO1QbcXfOqRvjYk2ikYQuJSsY4oTsqaWqqwbhXIvWlN(3QuJSkDmikTQFRCaeCAvISs0KD3hzJ2)a1B)AsbOmer7m1OjjJEwAiPPJbr5j7lAMOPOjWhBWIxqaWqqhakdr0otnAsYO)GPlV3xU3OE9aWqqhmCQXP)NryA0FJ2dCuC2DFKnA)duV9RfK0BFEpOPVIPOhelnKuayiOZZ7bn9vmf9Goy6Y79LludslNy6Y79bdtqy61Caoz39r2O9pq92VwqsVv0FKNdn7UDpmHXkMKCEQz39r2O9pFsop1Kk6pYZHglnKuDoUDaoDG6TFT5aTIoB0A39r2O9pFsop1cs6T(fa8Rz39r2O9pFsop1cs6TdnYJMVgkzziBWPz6yqu(sLGLgsA6CAZteMKnr7m1OziYz7qRdWjbyHNogeLN(NaO)vPkvka]] )


end
