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

    spec:RegisterStateExpr( "effective_combo_points", function ()
        local c = combo_points.current or 0
        if not covenant.kyrian then return c end
        if c < 2 or c > 5 then return c end
        if buff[ "echoing_reprimand_" .. c ].up then return 7 end
        return c
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
                
            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
                applyDebuff( "target", "kidney_shot", 1 + combo_points.current )
                if pvptalent.control_is_king.enabled then
                    gain( 10 * combo_points.current, "energy" )
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


    spec:RegisterPack( "Outlaw", 20220613, [[Hekili:nV1EZTnos(plU26uKwBRikhLS7uwQQK4mtLCZJCJYE78xMcIesIJPi1Xh2rvPsF2VUbajXtszNKnZ)Kits0OrJgD)RFGB9U9t3opKuqV9xhpA84rV07QHExn6vJ8UDEX(D0BNVJeChzn8JeYw4F)TYIyYd4J3hNscXHNNwMfaVAtrXU8F45pFDuXMYLdds3(88OTLXKIO0KGmYQc8VdE(TZxwgfx8(KBxABUF5KxD7CszXM0SBNppA7Bbkhfgs5FonpOIjoU43txxsp(HpuMqpUW7QloUaj0XpC8dVDdjznn)ho(HlpU4xi3bV)hJP5BySXXfrjf0SSYDSFECbWQlj4VxDCXdWN(NL5WFfgfcpc(XQ0SJlUpfxiXu)8047Pjfd5KonmAvef(Wvrjr5B8dstcJWf8XffPWtltc4)fop)Cj54I89jfKpp825Xr5f5m5pDfPmUa(5VY2piSHC787IcU7250eYYyA4TV52cqqHVV5jm5rw0o(3)708ckjUydFLSlnppc(WJl6NaSY9LXj0mc7b0e62iAU8QFqZ8kOcoFxPnFP7GxtlA(27jzr4BXFfxc)xwXs)LLRwbe)Ay)44IEW8FCXzhxGpD4YmqRjpkKoSCN07YGTqqmVMcQnjbW0td9xgxMesZwwMNpuWchxC4qdTYVRmo2NKe6hKbR1LPj0CgzhyLYrj3hTond2ftw7NVHeM(qiSrBN2fzLu)Luy1LSUIMd4FI0kCA1kKV2kZavb)ImkjVmREfYE36mKp3sJP4Zn24YsJJpU4nF64IZpU4N(LJlqvUCyUXDlXKbmt8E4nfBOWllanCyevItq3)tVb0EJWD)51lUl4uAEYBRE3BAKQSDpF(5ACrLXydCB)fp6TDujk1FxkCYkFiOqhfGNCMXfqN7AZh0dZwVN)DtgjTRHhJkJkaTHYKcFyf7NggQPgWijYXS3Z39ZOBjrj5Ck6buCGMO(Dj4wd)y(AkE4UeL8VEliqaPZB)i8yofG9l4FYOjpd(kUOb2pGpbzju(du43aMQE)H8azVSiLWOzJfbuWo5lsWYxwb783s(SF(okYHxAv2EjtqYEr6UDPzfLjrf7Re7fW5lWc2)xjyGXpmJ8GfbR9ZHItc4xrxTIcm99u)2zrTnGFKzNeKwGme(gzZuOWhvstlH3LEpnBvC6dmzoS5wMZTuLIJaNjq1UmbSPNlmq)MI3bdFtuas8yyVaEroqRyyvTeO(KZXzqEds3KnUb9slBqzuNBroj1Cyfd(yIi4oyAmCCmz4sAXduActDLUNPTsc3Zpi4qycMqNOjaFTyTrkkOBrpyOFMYCQqcGYv(s9cuTDnjlKlKsxjuVPGDJhiGrEC9(QhTcjSPIh5iGjv4O(Yysi1FvCzw2Ejl(zKOqFkZpjbp4I(zMHUNL0WKhQ0bx4ClZIHqj9Ui25oqxkdmDwXPQIK)nZYga1OiAhQijyUlWtPranRwdG)oulAdn4ouxhfCH0a4mdQ4q52vZt3IQI3OP9aETdWXuzeLeYGuG8USEG8AYhhdkJ)hAY4gvdHNwA4qcy4TwMd(S85)2hbjWHkiMbjNZ)tn6wn8ac6w0X4dcZXX6nYjtvjTgAQuFkmiFuS5W7PWGi4Wq2W1b70WIC)gQ(z8MWuBeVc08PsmmjlGKq9lsZad6fmQFLmulX73vgNt1GC59c5pmoA9MIC))SmC9wKsAF7e5VDjzTF6kapayMnx9lHbc6ZCKxg4(i72fVhnbKJ)Lj(VA6NwuGgOxft2tdrlLWc8Zr6JrzHwP(O(j6(7R(6TKS7WjinZpKsWH1Sh46i(ePLMFof1EGf)eBE)KoiaN0wgLeoChaAPeqztr05apO6zQ(ZmqJxByOI1xvd33Mz9Afzf4dklVkdsGnTRSUKgBZ(zTCookGYWMggHbhjt4vGdLnCBQoiBr1XaDvJC6U8O8ockOzUcPCWNBsZlavQCqv8oAJT2RNYwBvex9ZSb)xAvudRgGtVNP3f4ZS(zUvKVj6EBAznu7mPTwWvyzo6jKKeTLaMjcaqZaQ90mvDHAZuM2CRNzAWMu8yrgDxgqSKqBAHnY2myAqapGUa4VbLbAUEXdMaA63mN78GGqhfoBKGUqq3kOGh(j8CyQtHv6(lWFsxbZcdtt94c3Z(78uyAbhqGglhFpLnu4i4(QpwtKfMwm0ct7JpVaS5aKTnDFRR3h9empyFaCouSAq112ov0Ti2avd4zoHhh(drO8oGStdjOaR(8KB4o4rWwxicu6HiKg3rPWGwLLULn(DmbEWgKNvo0VcTU7RC(ycxBRgeNLLWqeRRGAmO3IF7VkJVWjXCAnA44AYzlCjoYzm(dgiQoJZTocky3yl6DZNHOgHq1oUdxbg0VoAvaNAoS)M7)aSptZ4Z3jeCq9NaNxtGOqrVFRxtZ4ro0OjSdC4NgdHHNw0gug5ptvr5FH7RFK9AmG30IkSz)wZYINhK3kYUZhtlOjbWdFiLfthgHbtzIldVWuvJ(zGpWt8SpJHOgJ0G)zL5mTO)hmiQJlUjdZk2jjHnaVOcA54I)oS)nCsD(ieaHFGs2LMSfbUlzjSNlDjuFZZvO3iLBjiWbwriwFigb4bmrLFctla6YbsamlzG2c5ZGXJmW4EMzsqyBOZf0g(fJ4GapXMjwM1X3scW)7M0pX3OzpegwYDyG9OLaysQXH6K9vrW52zQqGfgLvSxaQ7e2hM5EFqYZBA5Ak3VpIpVYRVfHVSZonbOsqjCb34ZRZ1NcAl5q4QZsJKfhLqZ4crD5sfdDpHb3xFVKD2OkRk4wb4uC8)fMWXam9yy(QYbd4)VeE2acWKzXIZcc)cnMLZ)tWdqi3lkm(saXh7unJ)Bc)xCs8xiCnNxNNtYZrBO4H1BqCRmV2SKILR5IRbhdI1LbxhqdYpL5teuszB(XLtr(auIZJ9WA0l6zjYAQld5lcXmylpy6Fb6RYqRKBvyS4a(Jk3Uvb4Y3UbbK9CD8KeNIdw6bB0AW(sB2CIEbpg9gvkU3asvM5Xpg1hQ0jdPyYPykoOqNL7KkN8c78vzrsHgCY(lRUPoHivzSS7S84mY66KQ1)rsitTNb2qA3DwDAjO)VKD3o3ABxZQ1ygRzzlJKn5AmwdUoekMQCSLyieg4SaKwXqc3rxyg8(4iazygSVOyJx7D2GjRMOuP6vXsW5h5HgFCX7eXgZ96LGqFQnWiWcN0GhslxvnmDFPGU(cd7UQKlwn113PFfb17mHId0PJPCwKtA7OHzw8Mxx0p)OvszCqFnP8HB3sdJWsuo3ZAQfK(21XPljX4hAb6DZqjRHvlr)KLlbxlwmyM(tr)F9QqivVWdJOmzN3vSvUTq00rC3bVy1nIu5Aajhb0hqb4M9zCUtK9b51Sr556Warni4ARIgFPWQOuSfH4Jy6rDLQZUTqWDU2qWghR97OcuSKROLQIMQSPWWAzHQTuNAMro2PGaWukeZq7yX1ZyxtijouFSJOvSJ0OJKXkdF7qGnkALNzT5EpMWewf1iyj6k3H(0tI2rfq7tXY8ZnQfN(afRr)N(0ndpU4F1KNarYuwjGhWRskw2JAUjntovnj7Xxp0k0F3YCd2glWoN15roYKG4SGWqzmFc9ZW8D1iwDRq(fGqWHEWpeBYsDNR1RgXeL6VnSmJu7e8RYovhh0RpCQCuxPKoJ6WKWT1PK)rbB5XJGxHF5(2TYPonnG(tAlPvCuO)3rIYfJP4TwTTcBkZFUE8kYGHuQ6LVaGtv9K8CLUELrzl8AuVX7YXI4LzyE5HjlGniYmclDhVRkRimOWOU7NGOj7pg)x(Qrp0QbYPhXmAm(mn0keod8xQWZCkoAtfVFT6MbsA5oZWQXDl5OPVL00W7TbSYtd6gldNgJBkzVEmBsfxVnTVrvhxobOX2LR9BdPuVgywYIgHi7m3NHBaGjC(nYImrcpMAknQWe75kD1wt0aA7ve()7LcfxRfyy2BtsZ2IjInoDDua)OayTuQxTy1fMn4TK)evKF7n5dTh(ZPe2VPPsxaKpLCb4YeBveHkOPK33CcKs(Je0r8jTGBJR4Ph3Ytvez1HslHruZ7g11rXe(lnxS86MjVoBnH(ytbbeNNhFF8qsD7lmWwKHEUt1(JBhxUOzOiBlvulC3W1fbwLMggJYxyjguOfDGEznAoB2zuR7sz)pMaWrYzrLnH(RkXqkByl8Zus26sAgiF5fks9ZuQK9QOmkJI6FLAr6tcaqFzKy)aw7sO(PUCk(aeKxEa4zfBXJ8cyt2zQqnnydhoyjUU26fk0CGg7LJ6uS)QQ2O1ctHRbxLMmaZ0ncTPot6vnzyERjBVPKmU5jSG9IwdPLzb5oNfsewi544wHhKYavjwU1xPxorEXSC9X(V4u42RgvXTUNvKxDvbsr5b808JCdVfCpUO(KyUaLwzosdSQq0TQUdAdCbRal8PAyH3WnKCFWjKpVOWTUeXiRhXwcUTPCYZ84h)mRlPeTJqvFJyP0ewGD4UZHcJY3rkc2uxsH6d3mlHAhQ1diO(8WgkzNOQGb6fObWiU3pLlwEGsUZmDZSGDJY9rrH1SJuu3gtTvkgnXVE5yq01iUcEXN5vSkdbtw1CaSaCrG4)(hRqhlGBZ08(P6IWk1QJ8ACX4vrDvwYliwklOZHQYdZO6NXskr7OJLpV9cHjVA)6wknSM8TRkiF2JGC8mSucWKHvVp2Tmr5rYXm6UCDCRnkTHJYktt9Vh2TKsDMtTXn1g5PqRFQQ1NvuCzAq3dlg8BQUDdGnNhizjGVqqv5F)6F)xF)V(t)WXfhx8jCpnAlwRyXw)ZexjGNHmf3wCvNjskls3I4vyTzaEjhgE8d)CeMAKR(bSy3jW8YE9ZAKY)XZ4AiYpQso)mmOUppOMkVqJkvTIDnnQFGmf8yu44h6yDv3VtpUv2enEQo5T1mvZtm5QViAGr((UF7Np9Lyqy(JBXn(jVTDL0Y7PV571YM)tJkV6PjQvud)NA0qyCVMcv)TlEW7RJaX7LFP8HobEI8HUm9PrMX6KPcQGN0kQb3YFym()HJXp2Y4hlp(op3WD4(4o649KfkJpnMI1fMpoE6jR3PBPX(jYt9SK3xLZsh)W7zYdCyqy1CVEhxWU6AWRzXpfGHgmc7L10vrORZ)2F74cTROh(ilxtp8Xnxvp8V(gED9Qi)t(k7vXXV7Z0GsMizjUnsB4OL01ayIHhx86Ga6omEXK0Kl3qY2UQmUs8LJP9pEpqoXFpS2R4u5w)2Y7pF6ZD1032)AbSD7VuVUgxy0nYtNCr0QPMX7oB8e7KSP0O4aDwE5dhCw(v70vTczwy0XmgLdM76RCimuGY5Mi1Oan3WbPaRDCzzeIHfhMiuFJbf)Esuml(N65FkEhobIahe(IUCM1euEpLr1Vl3Cqz2PkOVlWWYN2uHZlyLOzA9TL86X96FMrpWbplR97(5Hd8r5OlyhOqbhzDSIgA3QZbdoCOM)MoUhN7mUfN9er0iFdozs)VXxMq3sz90gkK12kQ3SPJp3uQZZt)SPtgbIp7x2YdhAP82ZM6nAatg8D((85wgPBD3ImA2u5IDEPHy6Y(ShP2gV9C24ScjMRMJgu2SFn)uzdMu9R3L87riGs3nLDvhrRGD0fA9SVsUEcJ7)(EF8CVInQgMqNWDsGbJw28(nsSvB7kmoZ782U6IYCN21OJZKcZ7m)NkfoqAG6xGo(iHip7K68nDK4UBTOoNigQy5pt961HuxTaQG5IjNRu9uZbZU7DYpx7Q2j)kLBwxLx63GCfnRrgmKXNt51(r7ParuVUtit361L66Pxzsd8QnXan486qzogJIxHe4St4(pD4ql11Lz14789tYI8XS4ASv7jCZIonIPK82PENoXrX1)XVRrN2AcwdkjN86PtoC4uVasxAE5JUEkEXJqsycpyQ4ch1Rvqw9mBxGzEMlgPBRdUiS58SV7Sd3H7tXRnVxrCCi)f8(a90eqAwoLTA(39gcBJNz5cb1Z2E71t9mH(D4Gt8lscYV63dhlA(Q3dhBNKzmV9lpuN0ZI9E8s2GKTLlYJv54mBYX60xioxMZeETFhCA4jWvTcAeM3EzuiaSDXrs9EMMVh9x27xJYAKHaRcWXzNuN61R7O56DMcWOEo7McLqd162kH5eB3BgfLGRNoEGeO2V)37etbSmexl3fcv8jTk67OBSfWLXigBp6aNylHyG6FYdwF7CW3WL(PTY7gZSHwFB3sLEoAZVPJ61gsp1PsR7DyN04gonVKeSa2)wCVs0zk18a2)PKiWb6hZ7B1EiqHwIEBq1Omfgq04MGAgp4cl3(d0BK298q5rYP60D(mRKmnDvNv0RAlANQCGbmaHwpZI8FT3vgNuKA2pltIM9owkHuBlVdhS3uGO81XrhaOshxAddUullVaJ6(ac36TwV7kGxApNvqaCsrq1KOsU59VJx(aDXGrE5fxXJPa8pBQmM3RJE9TOwydAdSjP160oqaPKOmVgr23Gl(qNId7LK4Qrx66Iq07jTiTEmO1R6WmVropOygX5t(Ic0UBqN9kVWh2PbdtALQEjjyRrhhlNnUjcI)kCvd0fukIgfNZgEz719DpWuRQV7gZZH9kTG96ReT34Z9MmOn)BZ6p(sROyzjB21M0id7UnDGFhcL(2CzkItr9Yc07m7NdQ86cgJhPT0MnUXSY30E63nyTUd9q3IWJjwKw6H)g3OsIrzpOgDRp8shwASat(0xFgM8mqH1Dt4p7LYCUCR33rASmB7(zJn1wB6mElqzCFxk0OcVX2RZYGwd0laxPMgURQs7VnK16NOQApEJ3u3r8gidRAcEde(k99U(BXU7fBozU1FZgl3i1cQMq06W9dhS4A9LJSkpEv7SslTtU1K7WZXN50i3Rb2MhNncEtOqT305o2SzgJo1gdxNfR6ZCPYkyXRWHdn9FLCNABLJMoEKJzz8PolJpXzHNARFuK8brQT(U0pZnRyE8pt1xF8e6Pd2D2vUDgxTsFbOR3sFilCR5iv1N16q5rHyRTLhOVGo3OVuQoByV3LVwz7QNs3Qyq5QUtUAhDUE7ajmEoT6dv8)7ojhIHH2M4P1YYBA6rFBXS0rV6JPIktUl9XoQ(2))]] )


end
