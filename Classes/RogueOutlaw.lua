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
    },
    nil, -- No replacement model.
    {    -- Meta function replacements.
        base_time_to_max = function( t )
            if buff.adrenaline_rush.up then
                if t.current > t.max - 50 then return 0 end
                return state:TimeToResource( t, t.max - 50 )
            end
        end,
        base_deficit = function( t )
            if buff.adrenaline_rush.up then
                return max( 0, ( t.max - 50 ) - t.current )
            end
        end,
    }
 )

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


    spec:RegisterPack( "Outlaw", 20220713, [[Hekili:nV1EZTnso(plP2QuKwBROhXzEuwUQK4mtLC7mtUXzVD)lt1ISLehtrQJpSJUsL(SFa9dY(jfLtYLRQDZitYgnA0Ob(bGg3n(UpD3TrKs6D)(KrtMm6hgpD4OF6LJh9J3DB5UT07UDlj8EYk4hPKnW)(hvLjKhXhVljJeHdViRkpeE16YYTf)8lEXQ4Y1vlggMT5ffXBQsiLXzPH5KLL4Fh(I7UDrvCs57tVBH75E8D3sQkxNLF3T3gV5TaLJJIO8pNwekzIdZ)ZSvv0dF4dvj7omF8KZpmhj0HpC4dVDnjDfT4Np8Hlom)3i3tpm)xsOfRzSXH5XPL088QTSFEyoWQli4VxEy(JWN(xvfWFffhbpc(XYS8dZFidxij0GISKhOPLd5KolkEzmf(WLXPXfRdcZsJIXf8H5LzWtRsd5)fop)JkYH5f7sljFE4D3MexuwWK)0LKQKs4N)oB)GWgYD3EFC493DlnLSiHgD3BUReeu47BEctEKhVL)9)jTOKsskxZxjBZkkIHp8W8(PaR8qvsknNWEanLUjMwOU6h0mVcQGZ3uJ5lBl8AAzZ3(ajpgFl(RKk4)KxUiyr1YLaXVc2pomVhm)hM)SdZXNoCroO1uehrhwTv5D5vPuqmVIcQnPHW0tJcwKuLgrZxuvumuWchMVFFdTkUVkjjGKgfeMdR1fzP0cgzh4KYXPpeVklh2ftxfuSMeL9yeSr7M2L5v0Gfuy1LUssZb8przfotUc5RTQCqviOmNskQYRxHS3Tkh5Zn0ek(CRnU8SKKdZFZNom)SdZ)1F7WCuLRaMBC3smzaZG65zLRPWllbnCyesXjO7)P3aAVX4U)T1lUZ5u6203kF3BAKQSDVa(5ACrLZydCB)LN82oQeLfSndozvmeuOJdXtoxZfqN5BZh0dZxTJ)DxoszxdpgvfxcAdvPLbWkoilkYqnGrsKJzVNV7Nt3qItl4uCmqXbgI63LIBn8J5RO4H7kuY)6nGabKoV9JWJ5ua2VG)jNM(C4R4Igy)a(eKLq5pqH)ayQ69hYJKDQIucJMnweqb7LFrcw(YkCBWgYNdk2sro8cNY2lycs2lY2UnlVSknUCNuSxcNValy)3vGbMGOCYJoeSUphkojGFfD5skW0pqdANfn2a(fMDsqAbYq4BuntHcFujnRcEx2d08LjzpYK5WMBvb3svgocCMav7QuWMEHWa9BkFhm81XHiXtG9c4ffaTsGv1cG6xEgodQBqMMSXnOx5ydkN6DlYlPUfwXGpMycUdMLahhthUGw(iLMYuxP7yARKOD8dcEeMGj0lneGVwS2iLL0nOhm0ptvbvibq5kFPEoQ2UIKhXfszlfQ3uWUXJeWipUE)HtrHSlRwMYZYeaYqc3ZpZwPMTq73wFSfwVJBvGWSO0Ik1KZ4o1yhptiOF8F9T3Wx9)IY8wF(Amkf(XtrkWggOAJgEiGJfWG3IesenyzsvE(of)E5K4OakdTabnFHm21iifLZzQdvX8ftoCw9r17JzwFGtu5GdejNQlg(xm77aGRY4T4XjbZDokmIbAkxdGacplTMgEpEIhvFIOHGLd84dL7DPiBdEG8gJZqa2LqCmsxjKigWkK3v1puxtb4yqz8pziJBuze4nOrdjG7NAzo45oG)7aeQehWKyguGOmEKbHLJpKGOd8qGWOc2Gh7LRKIRH2A7DHd5JInhMG26edIyKJyd3edwdlYDFoCbPGgO5ZD8LmLhX7bRaufUMKhssPbLz5GZTs2u8svyNI3VTkPGAa)C8LQFys8Q1Lfb)vv0QniLm(2xP(TliRcYwcyJaxof6FjmqqRMJc1cdmz72KD4P)c8VSXcxt)SYs0zfyBzhnc9AalWphBoMPQJrQeP)jMyFKF9gs(94eKLdYAcoSMncFh0VuzPfuqrviyXFPlKakhhGZBlItJgUfaWvbrCqXivaEq3lD9NzfzsT5bjRVSo0hxU4Q1M1GsPT8umpp15sAIlFj1Y5K4qkdNEumgOOkHxcoxxZTS6HSLYZcsvdxZaDBrSglZn(nSmEdQPdtmLBuL7DjIYT9A6qg9sXSmNHEm7Hr1bQ4bAUNGOtd3fcIBH9vKRCezwdRiMSvRZkkbD5c4mW9ufxEZycv5sr)ZCfdMI4Ro2giMMDmf(WaMXxBDGI1Xp4s9UHAptrNcC)wvGEFjPXBiGrQqiYfi0PSCDLWAJK2M8RNzA46m88yoDBoqS0ixQ)YpElybmlbcplR0W92)eH48r2RXiCYkzURs5Urr(zXobqrmWwc()bOI5XzWcCNfcfhOI7xhQgOtuCpS5e8iyTIMROx0oY46pbKtPqiyO5UvRO5QWMBBk65)1AQGdVSTZXf0CyNczp4CmGyavJmGqIgvbH4BUL7(NGHajuNvGGtKhu4ItPS8C8N0LWSWWMxpUODS)UidMwacbyTHhNkLnuW85o5hBO1fLvo0bthGpVew)azB18IR17jpbopuBIl8eeXwOZ5kROh6hJr5DizRrenIyoVn9goenmOHZfb8)ymsJ7PuyqlZZ2Wg)wMapCnYZAw)mnBHHxZv)QdgXXsyigZMGASqif)oyzoFHts40A0Wj1KZvy)8iaX4Oz60hnFn1zcGdLrA0MfEiA02f8XNMbdgU1)O5SpptzVvK)VpMvstdHh(yglQFmgu22eN7o3EtK(zGpWZsSpJfZfglk)ZQky7p)Nyy2hMFtoM30ozgYnUoD8ChM)3zwcQtBLisHhPKTzPBW47uSv3Z3wfUDo2xgAqk3sUcg0k87ceamWespz2hWmfgKqywYbvsYNH1Do4(j3oxzSD1Bf0g(fJ4Gup1LfmMXN3scX)ZnzFIVBZEimS07X8)Gh0GjPowaVSVo4w)U7fcSO48YDc8UDyF4A)7dkydYQwr5qIW4xAbqKQ7ydbOwuBCb3KZQtjSgqu1yCRtMNYbATyx5cr)YfUkzaPOa(FXPnwNqdkn((IWKIWimiDadvMjq2iHFs10AGinjYKL8ppGBDaRQbSSAwc0HhPgOQKX8gNOivBUXHo64anNYwaUCl1kgUgqHyelSGUGLTH0xtJ80YsU5aybdHawzFBH5h(eKzCNfAbnyVpBMDvDpn2dwrx4bIm0CFOqfFHR8RCdF5ktYoMELm4d2e))qfjIu1NolDBiWzghYDlWS)WHvj9Y7gu)jlz5hGmgv9HiJmlwFA2Ri1fiZoLFqU4d05CNIWNKgQWSQzu4TMlSFJWDs86cbrpNNcRdZ)Vi8ugYbeqKLVd)yCluwoGikMbBMxCC)JLGvjckHREzQM1ObNS)2YBQZxOSSghpvWTC2qecr)tKq2hvg4cp9Xt6zlPe7lz39OBTTRz5aNUJS45yKSj)4UL6smUnMu8NMtPXjc4IdGshdWUZH9fnp8gVRvawkz1526cAheVuGMYkTq480Wn9vI2)lmrtYcU6ZAVh4ccQF0ePpWKo2cqrfPAjgIj2Lcu9cbWmC)rUy4W83jKdC8IPyKd1lmrqAPnHtONg82tQStrKpdZsBgGSMasBuKVExUsAeCxMfv51roAvh8qT9eRVuyprX9PccnNqH9NWu2wwiCGgZGrRXdyMq1MyJCbO6kFOQfRUgrEo7gJ0omCR6Ro2w359yoryf)LGvtUAl6zjnElv4EhazkvpsYEKILH6tF6MHhM)pBsfGiFjlfoP4f0hRqxn3KLRMnM0D4RhENRAc4xMBX24DbHZ68qyzsqCwQlBwk9ZW8nDeReRi)coY4oa5WvTzPJNk8PJyIsZ3gvjXgzA)4PUtDKZn1k6QND0R72OJFc7U6IMCs(ppD05ASm3jJtM1RxSRTlxQwQP4WH(pIfxUbmj81AUsqsmJJkyPytHQxzTQtgi80kR73yFGS1gLRO8rvNXxmre2od8fpADHnyrwAyPE5DYm0WWKHQVFccQT)e8FF0jW9bQPQXC1jNPHoXsybeqhNGxXrBA59BVQe9Al8yF5lQVJugXVooybchCChWCAmP5wMygCHsITBtfCK8mJz4eDw42)OU3vc)tvijeEpR1d0nOhe1JzKdzJcoc90SuJuZxgQDgojAlwKHW3ReZTXT3Iz)nnlFdM71KSvXH8ZfG1tLRziRy(SbVH8xOw9BVPyOBq5Dj(EBtN(q31E44gb9yyYvgNIgsf1ToVGuu)ibDeFs7WI46G(dw40Kso9X0cm4A23QGyAM0FL96LxEt1LARPXhVsBaX5zVNDuP(AN4mliJBnMfpRL2VFE9Ano2oMX6wdGvPWM4UZgk)2smXmAjJCmVijllkb3kbPzy5rZc3uv0aTf522m2)fzbT8iZMWGLvyEyByl8Z0V)c0CyRKxjk9pt7klSmoNYOO5xPFdosdbiN5KKGq2nQr)t95p(rigVIqWPoElGkkb9jVjd22nbCuKL6(ABLOqZdwWxD8KF(dY7BUdMcxd(Q9ziMRFevvDTeK3g3Iwl3qxQ8pEBoexEOwMfK78wPsyHuGJBjEMnhuLyvxyPz9k55W03hh8YUWTthj5w)ZkYR(kXPOajJn8ADd)UQZTaWomwiaiwvG0alogDJUZNJDBlet1WYXdxtkcaxEb80J26sedtEeBj438vNN5jN(mBkPe3vf5LkYrXzCa2X)DllkUylPmCDDrvQpCZmgACO2x8GGEkzRO4OHMLOcGNUliJlwaJW3BNYvwO2XfbOOWzPikRVOBTvmkdXVzbPqG9ikgE1T51SlhHWkV9bSWRXya(ZpkbMlq6Z08(16RlHYDcMxLpgVYhdzbVKGzSqEhQlpCwKMPhdyU65Txkm5vdHWXL4Wq(YiAl32KNDcKJxBSkaCoS6dWRsvCbcZQoCv)fMZvftuxzgQ)9WRvSY12Q24M(T8Q04Y2vRpRP4Y0GEawm43WBdOxnEky2NKNc(cbvL)1R)ZF)9)(V(ZhMFy(NW904nyjZfB9px07mphzkUTy5LxLuvMTbHgHWJzDd0WdF4FeJjMz6pJ18pfMx2RFEJu(F)CUgI6JKY5NJXt(5b1u5LgurIjQMg1pqLcJzu4WhoY6Q(YWDARSln4P6C3wZunpXMR(IObg097(J)r3xIHrfN2IZuG39TTPTS86ovufsV6Rcv(HVkuz8ON2oMM284Xger4KOMeY)2lx803E0iJPm5K5JVsc1F8Rdz(PVaReCsmXKtKOwgRiuAGq9VTgVjli)4jog)e1XF0JWCF)N2Pyt9SUlxN0nMIDBHpnE6j7qW0ONBdvD98OknS2068XGdF49m5boSxbSyipKzw7McVMfkxigd1i8oxNTmg9I)3(BhMB0wT4JC0AT4JBAVw8V(g2ITsY)KBZwjh)UptdRyIKf42iTHJwqxb4AgEy(RddPBXqxtZsVynjFZYQeP4RaR)rYoGCI)EyTd6zQTOGJ3F2Sx4R5eC)1IiiC)sZc8CU1TMF2LNhVCMDO3xp5s3KSPoY4a9wu4979wiy30v)kx5GrNWyuoUYRM6ryOHQ0prQbKAVHdsb2vpMLhmwybWeH6BSOcEGeNWcfRE(NH9Dnqe4GWxudvxtq19ugv)U0TVQSJm(ZZXmemR5kZDoRqvZQ7W5RM0R)Z4X(OCHeHN1yn05THF)E(O8CJFhOrbp5AvsdJoXEWG97R5Vzt6X5oRoVUNi4k1UUMj9)g3aW(LYMjXuiRDvDZRNn5mBPoVafxp7YrG4ZDcy3VNhhOZMI(6zJhnGjd(o3dU(LrMw3DiJUEMAvFVWsmDrF2J0Vy198ElMfsmF90bOS5Utu1zdMu9RxJ5EccOSTZyTNmAf8ixkSEUxjxDPLorxBI2tGp5BKJr20BnA655nsxeJ9ScGJlSLW33gG1VWWQIMcPH)uQd2DD5aFKqB1vpdF94ZARxHv5UC92wLZKcpumiaAv8rzGMnSkFKqC8hL6C9bK4(ll0rNigWE1ptVtwrQ7Os4GzVlptRm42uG1RRQp3O1wvFLwNSkrB8gK1O5ncIHmMDgVYDNRL5u(Pa7CoE94X98NWAyRhms3tlzCxnESXec8NEdeItvRnG4vZMAtdSzbz4QQDsB2GH2JXQQMibEwh6OW97BP2)456VOo)ZMrv6yOAZrgUl67p1ShXHH412na4aXBCs0E(Ev9g9qUv6V3DUNdvf7cqZ247qp31nI54St3iokU()8UWRBRjynOFqE2L7331wZ7c72Y7Qzyl5HKWgm5mrR41Rvi598C7AUES3JGFN7LUN2bBxoiuDo83HtAqKhoUAc9CjCVA2yBK6737fU5GgP5x9EyZHQNEpS56OeJ5D34DhLEo89GnOg37M3MGZPC8AxYX6SnjoyuWeET3)An8ealrd5fdzJkIla2O4mH5ftxLg2jYaOJN762SrCd5Mxspzq0w9UMIRVMGWhyo)QiIDAoudWwV(EHy1ZfOJrUrwm1In4xyi2e2PBXAVJhJV6NyC1c719vf3UMzlFPiBnd9wAk0CiducJ4BsFE5xK2z5axbZrpEPDU6kq32)1NQzv(9VdPSfjQHo5ORD0LwTQ)DKUFqeggMmL2dC2RQhaQRFNhS52GJdyF1w6DBLF8yXS0tBRFQ653SyBi81NkJ7yhZCd3jLDx)WYBX3IU4X2cSAkY7)uYr(aldAo99auOLScmqokBHX(9(qWnzW5QThg3LVJUdZCrR4fZHxgtRn4Pi9ldRiGhxz6bxhEurbWxhPzK4wP)o2boMckRAYi6ZPzawsx(RTBUPE9T9mFLlCsG0XO5b8aNsljPJBezFd6(NJkoCSKJtVE6Ol81nq9EslsNQGT2VpCWpEvsTdH8j3TmTBQ3BdJiSt3n8wklw9ofITm9yB(6jnrK8)h63gtbLMOrZbKLNKEhVbCSvS67pJBEWY7kcY(AHqo5SXxoOnd5x3FYfoXXXstKVDQrwagAA)KJiz6713GakSEhZiEORdfs3mxnB6iJLi4OP2mZ30gBPlOO9fWHPfctVY(JzqbMODJS04ptrsQ6kZQLvKL30PLNwI964lrlRGwipoENOC9RuzE1(p5i5PYU3tUEITIBtpB4k(v3120pkC35RPoFdDhaoVhoQtlIrVI4mo5PspiUGNAEAv2jiwVPU5pSaEk73dlyYAT4H5BXlYoEp85UxS7HcRCHOBEYOzo2V3H77x5oVb)q7SslDoHZSr5RWhQ3LfxZJ3EEOjEI27VcpB2mdCDThimzrzlvOutgNf6P5(9P2uco5Oztg5zwM01zzshNfEU4(fre8ICX9D5Q73SI5wcMzU(4zG0kvxt97TxUsFjORxBG1UEmchJEkm0ZADO8ma66g6pWCbDM19EsE2W910)kTTREA3gklklVi(YD0BnVUzcRXZKFOg2c)zkqmm02ep3qoEtt7O4UKOT2wky(CYvBifS5bU7)9]] )


end
