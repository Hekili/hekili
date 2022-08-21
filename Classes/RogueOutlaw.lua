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
            if cycle_enemies == 1 or active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
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


    spec:RegisterPack( "Outlaw", 20220809, [[Hekili:nZvEVTnYs(plbdGI1Z2ksYXjZmWYa5AgKSZr2rz337VmvlYwsCmfPE8WoAHG(SVvvDtY(Ks2jzZcmiJcj7Q7U664xvvx5Mr38PBMgXk538hJhoE8WFC0ZhmE0LVC0ZVzA52n8BMUHfElBj8Ju2A4p)ZQYe294J3MKXIWHxKvLhcVAvz5MIF(zpBzC5QQ5dcZw)SI41vjSY4S0WC2Is8Vh(SBMoVkoP89P3m39CFXntzvLRYYVz6041VbOCCuex858IW6fX(z)v2Yk((p8QQLvfL7N9tNTFgsP9Fy)hEZkw6sEXpV)dNVF2VZULVF2VKWlwrRJ9ZItl555vBOFUFgSwNZWFVy)S7Hp9Vj6ffhbpc(XIS89ZUld3jj8GISK74PLdeKolkErmh(WfXPXfRccZsJIXD8(zLzWtRsdf)nCE(Tk2(zfBtlzFEWnttIlklOda(cwvsj8Z)Goqy0qUz6TXH3EZuEkBEcp6MxFtjWPW33(eIHKhVr89)fVOKZskxj2jBYkkIHpC)StsHLYDvjP8Cg9aEkFDmVqD33VDELubNVlmMVSnWR5LTF7DS8y8T4VsQG)xE58G5vlwae)k48y)SEW8VF2t2pdF6G55GytrCeFq1gL3LxLYb28soi3KgctppkyEsvAepFEvrXa5sy)SD7APvXTvjjbS0OGWCyVoplLxqKTVtkhNEx8YSC4umDzqXkwu29rWbTBAxMxXdMZHDx6YAA2x8jk7Wj17qXERkhefckZ5SIQ8MDi9UL546CnpHJp36Glpljz)Sx)P9ZoD)SF933pdf5kG5gpTKtgSys2cVPCfhEzjiHdJOMDcY(F61G0BmE6pTzZDMGsttFt97EDlxLo9cek24MkNwg4X(ZFWh7OquwWMmqZQyaiqhhIAoxlyqN67WhKdZxUv8Dxou5udvJQIlbPHQ0YayhhKffzigqKexX07fN(581S40cbfhbuSVbR(DP4rJqnFjhvURqo)RwdmeG78Mpcpwqb48c(JCE6tHVsWAGZd4tWLeY)bk8NWIQ58HDpBRklLr0S1IaYyV8lIXk2wHBcwZ(CqXgoUcp3jV9CIrsViBZMS8YQ04YT1S9sq)cSG9VRadmbr5S7DWyDRhk1eWVIVybhw03Xd6EjACa8lKDsGBb8q4BuntHmFuinRcEx2D88fjz3t8C4WTQqyPkdhbotGODvkytVqAG(1LVdg(Q4qK4jWzb8IcGwjWUAoq9lpfNb1ditt24b0lCCaLZ9Ee5LutHDm4JjMHNGzjG6y6G58Y758usCLVLKwzrBfkcEyMGj0lnyGVsU3yLL81Ohm0ptvbxYbq(QyREgk2UKLhjyszlKI3CWUX9mWipUFF5drG8y2TKWZIeaZqIW1pzRuZwO9BBuBH97OoziKfLoePgFQWPgPEMWq)4)6BERy3)lkZBJ(1iKl8JpeUanmq0gn8WahlGbV5jSiEWIKQ88Tk(9YzXrbCcTadnFHlSRrqkk6zQdvX8fXhoTrv92yY6dOrLdoqQxP6SH)jzFhqCvgVbvNKlUZqMrmqZ69aWGqDPv8WBrnEu8jIhcwoq1hUW7sr2AuH8Tg6qa2LqCm1UsyreWkCTRkFOUNcWXG84FYGh3kYiXBWJgWa3pn8CWZDG43biujbGj5mOarz0qdcxp(qgIoWdbcJkObpY7QQMDnWwA)ywHIrrZHjOTJAbIGKJOHBIbRDjkCFoyoRGhO5ZD0LKWJ89GvaUYQMLhYs5bLz5GZTsAkEUkSt573uLuWnGFo6s1pmjE5QYIG)UkA5AKsgF7lu)25SLbzlaSrGlNc9VegiivlqHAHbMTztYwu7Va)B2yHBOFwzj6ScSTSLhHEnGn4NJnhZfQJPwis)tmX(u)1Rz53ItqwoWRz4WApi8POFPYwlOGJIqWM)sxibuuha9T5XPrd2aa4QGio4yKkWAq3lDZNzfzsJ5H6L(IMqFC5IRrAwdkL22tX88fo3sJD5lPHpNehYjC6rXyKIQeEb4CDLWYQhYw2OlvlB4ykmDTAyAK8mIg6ULZ3iDo8MCuBjIJwHbhOBote10F9rH9r6biUccCXVcMDtlUfyckWoiYiSYkgdBobDHSOgZhOUtfF2GY41OMhWi4KeYf1yEfRdxqeAz9pxg)rtenlBwvb3d6v8CfeY9AJLXXNHUJLH7C0Kt4PgImh39b4PvCbkvsycDfCQbOaDXaTD2c0ssqZtqxNQsgEeKm1NJIl2WkdxzzEbn23LWJI7ktbhvxCG8qQaHHm(znTwvabnr(OCkO5OhcbStg2AeFwEaROa(V40wwdq2HTNgricsIWqqxaetZOTnIoQ(uVX1wBuFuKsESe4ipaTwwuHu1U(HfGMx96fMxNQY4sCQKmQgVuwHq4WqCbbnEbTbc3gc2bLhc4bUd75AlYwHF08o5Hc22gCFtLQhqkfmha55aCOj(wl11hbpZLQL15SzOOAcMogCFvKV14ym9yz8fUaJ(wX2ToJeOXZm4dwh))WLgwvdPJInHNZeRqalAnoEHjA0clkKR5a5XZzfkqgJQrjYimSgTzVSuFbpEWGPeSpqMZD8upkjuzudMqw6mWHFNi5(zVQqs0Ze493p7)MjIVsG6NvNRt8JXJW6CNeXXW9P41XZpYNBDSVsFP1XLRrdbz)9fVTj4Q6CaD44M7q3qMMItEGeYwvP)doozAt0r8dFjNUh8OTBjlhb76iKhhJKM8d7wQHe2Xa6WKI)ycRnoXaxCPmi2xEqoCUq5oTj2a931zWGkqGN2K9)G4fsSjwyOX5PD1CIcC7Vqu51zN2N1EpWfKu)GzDOVjDSzGY03Pe7yTdxkFCxlOJzowuQEcz4(Jc2W(zVtYheWNtZkv2yYSOsp0vod6ocCNSiFgMRTza8AgWTrw(QT5kjAXDoPu5xhq1QbXCJ9eRVuAprX9PccToZfGD0L0rwiOqpAWLoq20r0NTvwXfGQR05HTjRxU7Az55u91mz66z33kz0JSLDEpixWOmLZWuVtrwvKgVHlDVdGmRfpsYUNJ5S7tF6Td2p7)QGxJdiAl5yzH0jLO6hy6mBwnz5kzpMLUfF9aNjqXpp3AzJfotS0Vpgfajoioln5ymL)zy(UyifyiUEbhzchGc4Q2lPdN3GlgsSsZ3gvvJnY0(XJ9K6a6nnc6Q6o6jPC4H1WAZW0dY)5dhDU2sw4KX5I1RxSRTZT8RuZYUao0)rSSsqyglAKCRbjrghvWsrtHQxzTu5gi90wNK0r(azRnkJ1iPMGIoJoF8NeMHjWxI0yiTbFFgviRqg8G3r2(RXKHIVFccQ9KX4FEVtG79L6xKUO5UREMg4elHfqaDCcEzhDjL3rctul0GZWJDN0uIMQ5lD)S)rDTlXSP2)WoGf0yCBj5mdUqP4zDjcoSwNXmCIJM5EYbDVRe(NktsY8EsNk0TOhe(FVyOdEJcoc90S0GuZx2cDgojAlUQG06EVsm3gL6MS)MMLVMLGUswghk0laRNk3jdQYh0GxZ(BuQ(nVTyGBq5ht892Mo9HUR7WXnc6XWKBDCkAivup68csr9JK0r9Io4fwKqg0FWcpmUKtFmDadUz5ZdxLH0nNVjpEnyktZK(lS3Vf8nfXABvLxLdRsSK2aKdWIt8Tq0z4DijhMfuULuvAQrNZSGmQZyw8Sx6(Ym0RZ4yL7p5r(9C2MSuH5d3uWvaSTzqLoDwZfLwASz0sgzSDEswwucEucCZWYdMfUlurd0vKBBYO)pUe0Q2dnHblQW8W2USWptVyp8C4Oe1Hn)mT8bVioNtu08R0l3vAia5mNLeesLFu)tn9hl8HFFoBtbIhHNWdlZZkkbH)qa2vjCgfZukI5b)sCs8wrguWhgBygOGUbn)b8MYQC9mptCBcLIWyHWt3bpQQ3lDmj4AZNz67HGClcbunynJlkbfkVzd32pjylcoBIADwq11Wny4xC4S)(YMZf7ffUhmnIvVhczHOY4Iaw4)UsSGK3DlBgCZNW(CBcw7ynH1(twQ5oMfC1zAqPUg6GGliTa6prbq0or3YZdxfZx4kwqn9hpds1mvugynkVINeSKLNdYIqiIKprkx)(YHcYzjz5fOv0Cq5oauCIxWDL4gVFCWZpg2xR8P)zfxR(QPd8fP3YlhzGJ4TIRAPWMmzESqczVQaPbEHp5R1Hd0fstCxiNQbLJgSIveaGqcejSUZTiM4IH0wWFvGo6zE8dFMn5uYsTwxtChLlZb8t)xnIMAXvAuOEH7jdZS(IqhuCyBaifzL3OvlvYvieWW2GmbBbClERDsWPKFexeGScNfhQS(Ew0r1bf4jU5W1YDKiG6dDO1vvSg5Cv2rDcLt2YvGJfmsd4W8w1sRoHkyF9wr)ZCX4DbVdG1TLUmfHbKHC77xqXQ47qQ1zP2AYmkFXcak)DyjNaaDGvXqW3iOBNLRdI9ysLSf6qCz4lg6nXGlHeP4KDe0FKEngsbLUskuxK7IRN5B3lUeI4LMMvqvWaMXmydU1YvHJBCz9LXSJsXtV3)TUS5ta(ukaIdVknlxcGavIQSRPON)xRjcoGUDk(qK4abTzctWlSdWeF9ur0weo4g)8TzdR9QxGSZAE5z4p5lGzHcqRzCY0)vKbtlMZIfYSaYPHUMH4keFSdpDow0b4Zv8559QR4A)(GNaNk1(aLCeSyRB(PqynUSonLuwE0UTSYSann9TTfs9m5Lj)(yKgIRgZI8S1043qmCryrAw)C4o5YJiolm3JsQrzir(B0RoTXXq2rAnCW4gY5kvMImzI3rBTuv4Txa61DUqOJcteypodguIZ(ZwDFrM4EJS3s(iI4pCBtI4W73mDmXRtgN5Hi)ZW6a1LOpJUpVT5GtMmK)t8kCVF2BZXMY5Omd5l9xw5(cSeC0bF6(Ocpoh572)t4x8Fp0fzFWlsue3bManPNSolpIf8DyQa3p5dS6dd6uDQK2WViIlsMVTfmY4ZBqS9a)ptM3v6Hsev1PfL2jAH5AT81adzvJilKprX5LBL3LYJ4C4A)NdkydYQwYjirGSoWDWR2LSZSEjeW807z5PGihyk4F(Q)6pE)F8R)8(z7N9jC)gVgf0K4OFQSBMEkEhUe886RtmRQmBnAxG0(X(ZAW(p8BXy1FU4NrnLuyEPx)0w0h)RNkSZP(O698tXKw)5(nu55guPoXln0O5bQuyerH9F4a7RMRN4dBNDPXAQbguZIQ9j2RQViAGMDE3F(Bh)wmmQ4HT5mz4h)X2fDS9oEQOYKEXxfQ8YVkuz0Wh3jMM08OrgerQ93qI6)U3vXJ)4rJmM8Kh864Ret9h)6qMF6lWkH0AL1jJmq8rkmL2Sc8VSg)ypJFSJXpwD8hufwer(dtl2C3C881Xh3IIIX(HTME0oemn652q1XQpQsdt5MJxny)hEpXpWH9cyjsUC3pJAay414vFpBrmw77F4haiK6T3m(ixT4m(822Cg)BFdB15AY)OB356v87(mpSIyeZXdpE7kAoFjeqXayZggY3GqTsZsphIsy9IQKAMwbIglzlqo5FFqJB5jQTkIJ3F6KN5RjrC)1YuH5(LM3DKZS6EHjxEw8Ij2j1(Ai(gNKS9kQHd079nB3oV3Xm30v)2C7yHoMwOIa6U6cpmdTljSFI0CR9TpWbUafMovIncOmmrO8g16e3XItOS90m)tW(FhicOj8f1y7neu9mLO63LUUwD5uNIRZWuDpP924FgDhyM00P5xnU3jpXc8o8SwBGoZC0UDpPROJ7RrbpLXTMggDeF)(721S(MmUNy1z1b89KjDsT73jU)34gX2px2S(OsETRqNUEY4tT56IiLVEYLdb2N7A7UBhnm3nN(1tgnSpXd(o3l0(5rMw3DWJUEI6fk7Cl205N4ije98gXVKJ5l)NGWM7ocwFzqC1VEni9dGbLTzc1M4OvWdCFZ75ENC1LwYehBZm)awNIdYr4YKy4UU(h988MAxeJ8Sda1fAl89TrK9ZmSQJGKB4Vy1GDxxoWhkLwD172xp60U6zB1vxUE7dlwKspueeaTltIYanBCyXiHO3pi1fYdiX9FJto4erW5v)m9okgPUJSmcM9U8uTSmAtbQNJvFUrlgR(kTokUgTXRXLgpVLrmGwStefX7mT0ek0cSlM31Jg1ZFr8GJEWiDpTSGF1OrgtiS(0l2govDwSURMCHnnWcRr4Q8wmo7XyvsmKap5iQ(2UDDCTcr96VOQKzVqvYUEJ5id3fN4VIwhWHH812flRV8nojApFVQ5GEGWk937QC5quXUMl0b)ruFQJJyo0DooIJSR)pVIvh3Ec2d6kYtUC3UJTmwNBxcRRMGLVcjHnyYjYYw1Rti598uSQRh5vf87CDNECk2UCqO6C4FaAAqKhok8upxm3RMmYgP(UDEHB2VLB(vVEpoe90R3JlvjAX7UivhKEo89GfZr4DZBbJCYhV2fFSjBtsfJcI51DRX3UMayjAiViKnQiUayJsDcZEEtLg2jYaOJNRr)KHcd5M3))6GOTAlEfxFTbH33C(vre70COgGTEN4fIvpxGog6gzXfwldXDrMMWJQbz6D4y8v)eJUwO3XVRe21m7MCfERzO31McnhsFLWi(M0c5(zPhnFqiG5O9X10RUcKT9FZSB3LF)B(ABwIAOtoAiyDUvNYFhOXkLHHHjtP7aN9k6bG6o5OhS5XGdfSVAB9JBNF4yXSKt7QvT753Syxi81NkJRVpzUr4KYUHIP8w8TObHTTaRMI8tEm5iVVLbnN(Eak0rwb6xpkBMXUD(qWnU)zQDEUWLVJgp3CtR4fZHxgtRnOwKEF2id4XvMEW9Hhrua81b6ZzHv6VJn3RjJYQMmYwOEcGL0L)A7(MU3j2EMVYfojG7uO3xIEGtPLK0rTSSVbnw8bzho2YXPxFXWZ91OX9EuBsNIGD2kXcWpEfsTdH8r3iUDBQ3BVOkTtFC4Tu2S6nHmTn9yB(6XTrK8)hALxtgLgRrZbKLNKEhU3ETfSoXFg38GL3veKNOfc54thDz)UmKF9jJp3jooknr(oPgAbyOTZwpaN5eV(gKqH1Bgx5dDPuu7M5Qjxm0ylcoAAmZ8nTNzpgu0(c4W0cHPxz)XmOat0UhzB9NPWjvDLz1nS1L30PLNoI96WBrlRGwipoCtUE9lux8QT26bYtLDBTE9yBb322b1v8RURTPFu4UZxtt(goEa4I2dTjTigTHQZ4KVO2dIl4PMAR1nzQ1BA6RulGN1TsQfmzTUh18TyhzHnuMW9YH6f0UhT)(0SHrz0eOEyuhyrA1cLwjSr3gQrVCUBNdmgVWDYnEz3lLoACsNPmZx1zuVWnUMhVDnP3CE7S3j7Es82gJTrw1Dlt6908hqF8hxBnAUeR7ssCn0vjVAVFJQ9zOZv0KXwcy1Dy4XolJpYzrKvYFrMldzwj)U8V0RT7yHnXjM7prUyTs63f(X9uVtFoOq14QXUYusicEkr2t6CO0iD(pOR9n3qNADdWQvaD)VQRxPDC1t7EHzr56EfT(eDQ5fVt6xAs9hQHYYFotKddTslYsMJ302HPUloCNDAkMzl6mTPhtb7KHyd9pK6JIB(Fp]] )


end
