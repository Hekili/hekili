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

    spec:RegisterHook( "reset_precast", function()
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


    spec:RegisterPack( "Outlaw", 20220911, [[Hekili:nVvEVTTss(plbdGI1yBfDeN3bSmqsCEpKSVJSpLzN5VmvlYwsCmfPwEyhTqqF23Q6dY(KuYjzZcmtEYKSRU6QRJFv1DD3O7(0DZIiL07(JXdhpE4pnA0GrdVA84F6UzL72sVB2ws49KvWpsjBG)9pRktipIpExsgjchErwvEi8Q1LLBl(5x8IvXLRRwmimBZlkI3uLqkJZsdZjllX)o8f3nBrvCs57tVBH75(Q7MrQkxNLF3SzXBElq54Oik)ZPfHsM4W8)kBvf9WhMr3ws3SGMFy(OrxCyosTdF4WhE7As6kAXpF4dxEy(VtUNEy(VKqlwZ4LdZJtlP55vBz)8WCGFxqWFV8W8hHp9Fxva)vuCe8i4hlZaY)qgUAsObfzjpqtlhWjDwu8Yyk8HlJtJlwheMLgfJR6dZlZGNwLgY)lCE(TkYH5f7sljFEWDZsIlklyBc0LKQKs4N)bBtHWgYDZUpo8(7MrtjlsOr39M7kbPf((MNWek5XB5F)FrlkPKKY18vY2SIIy4dpm)SuGvEOkjLMtypGMs3etlux99BMxbvW5BIX8LTfEnTS5BFGKhJVf)vsf8FYlxeSOA5sG4xd7hhM3dM)dZF2H54thSihuDkIJOdQ2Q8U8QukiMxrbDN0qy6PrblsQsJO5lQkkgiyHdZ3VVHwf3xLKeqsJccZH16ISuAbJS9Ds540hIxLLd7IPRckwtIYEmc2ODt7Y8kAWckS6sxjPzF(NOScNkxH81wvoOkeuMtjfv51Rq27wLJ85gAcfFU1gxEwsYH5V5thMF(H5)6VFyoQYvaZnUBjMmGzs2bVPCnQUxcA4WiKItq3)tVb0EJXD)z1lUl4uAw6BLV7nnsv2Uxa34gxu5m2a32F5jVTJkrzbBZalRIbGcDCiA5CdxaDUVnFqpmF1o(3D1qLDn0mQkUe0gQsldGvCqwuKHAaJKihZEpF3pNUHeNwWP4iGI9ne1Vlf3A4M5ROOXDfk5F9gqGasN3(r4XCka7xW)KttFo8vCrdSFaFcYsO8hOWFcmv9(d5rYovrkHrZgpcOG9QViblFzfUnyd5ZbfBPihEPtz7Lmbj7fzB3MLxwLgxUtk2lb7lWd2)Df4GjikN8OdbRB7qHLa(v0LlPat)anODw0yd4xy(jbPfidHVr1nfk8rL0Sk4DzpqZxMK9itMdBUvfCpvz4iWzcuTRsbF6fch0VP8DWWxhhIepb2lGxua0kbwvlaQF154mOUbz6Yg3GELJnOCQ3TiVKAgSIHymXeChmlbmhthSGw(iLMYuxP7yARKODCdbpctWf6vgcWxlwBKsiYhgbdJZuvqfsauUYxQxGQTRi5rCHu2sH6nf8B8ibCYJR3F4uuipMvlt5zzcGBiHh(N5RuZxO9BRnBH17OwfimpkTOsn(CEqnM5zcbJJ)RV9w(Q)xuM3A7RrOu4hpfPaByGQn64HabwahElsir0GLjv557uI7LtIJcOm0ce09fYy3GGuuSZuhQI7lMC48At17JzEFalQCiaIKt1fd)tM)Da1vz8w0CsWCxGcJyGMY1aiGqBP10W7rlEu9jIgcEoqZhkp6sr2g0G8wdBia7siogzOesedyfY7Q6hQRPaCmOm(NmKXnQmc8g0Obei8tTmhIChW)DacvIdysmdkqugn0GWYXhsq0bEiqyubBWJ8YvsX1aBT9JHd5JInhMG2okgebkhXgUjgSgwKh(CWcsbnqlM7ORykpI3dEbOkCnjpKKsdkZYHGBLSP4LQWofVFBvsb1a(5ORu)WK4vRllc(3vrR2GuY4BFL63UGSkiBjGncc5uO)LWabTAokulmWKTBt2Hw)f4FzJfUM(zLLyWkW3YoAeg1awGFo2CmtuhJujs)tmX(i)6nK87XjilhK1eCynBe(m0VszPfuqrviyXFLlKakMdG92I40ObBbaCvqghumtfGh0Jsx)zwzMu7EqY6lRt9XviUATznOuAlpf3ZtCUKg7kwsTCojoKYWPhfJzlQs4LqW11CpREiBP0wqQA4AgOBlI1yzUZVbLXBqnDyIPCNQ8OlruUVxZaYyukMN5mmIzpmRoqfpql80iyA2fcIBH)vKRCKzwdRiMSvRZkkbD5cWg4EQsiVPmHQCPO)zUYbtr8vNBdKtZoMcFyaZ5RToqX64hCPE3qTNPOtbHFRkWOVK04neWjviK5cK6uwUUsyTtsBx(1ZmnCDgApMt3MdelnYL6V8J3cEaZsG0ZYkncV9pqioFK9AmdNSsw4QuEyuKFwStauetSLG)FaQyECgSa3zHqXbQ4ZQtvd0jkUh2CcEe8wrZv0lAhzC9NaYPuifm0D3Qv0CvyZTnf98)AnvWbx1MDCbnh2Pq2dSJbedOAKbes0PkieFZmE4FcMcKqDwbcorAOWfNsz5f4pPlHzHHnVECr7y)DrgmTaecWBdppvkBOG7ZDYp2qRlkRCGdMoaFEjS(bY2Q7fxR3tEcCAuBIl8eeXwOZ5kRye6hJr5DizRrgnICoNLElhIgM0WfIe(FmgPX9ukmOL5zByJFltGhUg5znVFMUTW0R5QF1jJ4yjmaZztqnwkKIFhSmNVWjjCAnCW4AY5kTFEgGyE0mD6oRxtDLa4qzKoTzPhIoTDbF8P5WGHB9pBS95vk7TI6)9XSsAAi8WhZyz9J5GY2M4C3f2BI0pd8bAlX(mwoxyUO8pRQGT)8FIPzFy(T5yXtpk3qUX1PJN7W8)oZtqDzRezk8iLSnlDdMFNIV6E(2QWTZr(Qqds5wQvq)wHFxGaGbMqgjZ2aZuyqcHzjhujjFgw35q4NC7ALX2vNjOn8lgXbPEQlpymNpVLeI)NBZ(eF3M9qyyP3J1)bn0GjPoxaVSVo4w)H7fcSO48YDc8UhX(Wn(3huWgKvTIYHeH5V0cGi1WXgcqTS24cUXNxxsynGOQ54wxmpfdATCx5cr)YfUkzaPOa(FXPnENqhknX(IWIIWimiDahvMfq2OGFs10AGinfYKv8ppGBDaRQbSSAvc0HhPMOQKX8MNOOuBUXHoSBGMtylaxHLAfdxdOqmJfwsxWY2q6RPrEAvj3CaSKHqaRSVTW8dFcYmEWcTKgS3NnRUQEKg7bROl8arMAUpuOIVWv9vULVCLfzhlVsg8bBI)FOIcrQgtNvUne4mJd5Hfy(F4WQKr5DdQ)KLSCdiJrvBezuzXARzVIuxGmpQ6dYfFGoN7se(K0qfUvnZcV1AH97eEqIxxii6f8syDy()fHxYqoGaI847Wpg3cLhhqefRGnlkoU)XkWQebLiuVSuZA0Gt2FF5T11luESgDxk4wSnePqC2jsiBtL(UWt3DrpBPKyFj7UDU12UMLdC6oQINJrYM8UdlDm5424sXFzoLoNiqioakDma7oh2x0IWB8UwbyPuvNz1hODq8sbAkRYcHZtd3CMs2(FHfAsEGR(827bUGG6Dwi9(M0XwakorQwYHyS9rbQEHayoU)ixmCy(7eYboEXumZH6fMijT0M0j0ldE7fv2PiYNJzPpdqwtaPnkYxVlxPmcUpMfv5vhMw1jpu7pX6lf(tucFQGqZjuy)fmLTLfcg0yfmAnFaZcQ2KBKlavx7dvTy11iYZzxBK2HHBD(QJS1DEpwte2H)sWttUAlgzjnElveEhazkvpsYEKIhd1N(0Tdom)F0ukar9swkcsXpqF8e6Q5MSC1QXKUdF9G7CDMa(L5wSnExq4SopfwMeeNL6JnlL(zy(MmKDeRi)cbY4ba5WvTzPUlf(KHmrP5BJQKyJm9F8u3P6WUPwrx12r)C3g2Tf2D1hAYjf)80rNRXY8GmozwVrXUX(4s1knfho0)rS4YnGfHVwZvcsI5CublfBkuJkRD6KbIiTYZ9BKpq2AJYvw(OQZOlhlsBNb(INTUWhSOknSsV8ozfAyyYq13pbj1E2y8FF0jW9(QLQXC1jNPboXsybeqhNGxXrBA5N1(Ps0RT0J9vVOZCuYi(1XbpGW(DhaMtJXn3YeZKlukSDBQGdL2mMPtC0c3Z6m8Us6FQcjHW7zTAq3GEqCEmdDiBuWrOxMLAKA(QqTZ0jrFXIke(ELCUnU9wm)VPz5BWAVMKTkoKBxaEpvUMHSdZNn4nK)nQv)2Blg4gu(XKFVTRtFO7ApDCJKEmC5kZtrdPI6wNxqkQFKGoIpPDyrCDq)jlCAsjNXyAbgCn7BDGyAU0FL96LF8MQl1wlJpEL2aIZREpZuP(AN4SkiJAnNfpRL2VFE9Anp2JSI1TMaRYbBI7oBO8BlXyZSLmQX8IKSSOeCReKMHLDwfUjQObAlZTTzS)lYcA1rMnHblRW6W2Ww4NPF)fO5Wwj)KO0)mTRSWY4CkJIMFL(n4ineGCMtsccz3Og9p1mEmpg(J5KTfiEeAcnSmpROeu(dbyxLWEumr5E505xItI3lzaQ4dJnmdmq3IU)aztzvUELNzsBgkfUZcEKUo3QKRLwMeK385M(rij3IqavdEnOkkbdkVvd3ooj4lID2f1blqU1dy4x1D1F)H69fBMcxd(ozYq8WoW1E9HPiVoY2cy1ZB5yU6d41zrC7PAzwqUZ0HI8AHbkUG2cy)efaz7eDpnpCDmDPRCb1SF8miZZ4nmVIMeSIKNd6IQhD8eVhsfizz6YlrVO5GXn78EwAEcY8Qk77JdE5Xi(Mul(8pRiV67mDehz1idCe3Y7EaUpzM7XcbK9QcKg4Xvs3OdhOR7)IyQguoAWAsraacjGxW6wxIyHlgYwcDEzy6EMhF6ZSPKIDPKM4)6Z0fVCSthYKmz8DSJMtETYCC8CoG76)2fgfxSLugYcrRfRGho0WTUVkcagQKTIJhp08qkHeu2fKXx6qy47Tl6oRylXfbOSW5HrvwFvhB74ineXMhjjMAhIJLF)g4NABoMeJ8(NWkWcMf4F9rzQzIC9yA6)A9fMr5wHZpNxgVYhdzb)qHZyf9yGU8W5X0nPRuZuTVFPWNFnishxJhd5lJOTCFJE2jqogTYRG0ZGvFaEz6IlWyN1fSWVrj37M(zMPUYm0)7HxSCLlUxTZu975xPX1TSwFwtXLPb9aSyWVH3ny)iGGA2JK8uW7nOQ8pF9F9hV)p(1F(W8dZ)eUNgVbV0eIT(Nl6EQNJmfpyK86ltQkZ2GGJXeKy9d2GdF43IXsZn5NXB9rkmVSx)8gP8)65Cne1hjLZphROWN7xtLxAqfjQ4AAu)avkmIrHdFOJ1v91H80wzxzWt1vVVMPAEInx9frdSSlV7p)TJFjggvCAlotb(XVTnPLL3XtfvH0R(QqLF4Rcvgn8PTJPPnpAKbrebjQjH8V9Yfp9ThnYyktoz(4RKq9h)6qMF6lWlHWBL1oJaL0ifHsdKT)L14h7z8JDm(XQJVttyES)tZk2C1C8Y1XhhtXUV4Ngp9Kdiy60ZTJQJ1EuLgM6nhVzWHp8EM8ah2RawmKx0ewdhdVMLlBiMK(q8w3NTmgJI)3(BhMB0D14J81H147A6YA8V(g2P1sY)K72Ajh)UptdRyYLf4EjTHJwqxbGBgCy(RddHLCbw110lxtY3SSkrkdlWJblzhqoXFpOok9u1ovXX7pF6l81JkU)ArAeUFP558DHvZtm9QlIxo1Uae3m(k3KS56eGd07Ddy)EV3ha30v)M35GrhZyuo4YRN4ryObT0prQrLAVHdsb2nqNvouwUbWeH6BSudEGeNWYhRE(NITFpqeWA4lQV6RjO6EkJQFxA6Bv2rMe6fyzjM2CZjVGDELtRB09Rh37SNXtas5EPcpRXLOZMIy)E(O8CXV7RrbpLCxsdJgYVF)97R5VPJ7X5oRgWVNidl1MVNj9)g3h4(LYM1YwiRDDi33mD852sD(5uDZ0RgcIp31HF)EEYGo7n(BMoAyFMm47CRy7xgz6D3Hm6MPQh()LwIPlpJ9i97xFpVxMDHeZxR9akBUBizD2Gjv)61F2NGakB7uwxQJEb74Ub2Z9k56RS0jo2EP(e4t(g5iKn9EuD988gziIrEwbG5cBj89TpO9lmSoyBH0W)bla(DDfaFOqB1vRJFZOZBRLXv5UC9UxMZKIiumiaAh8NYan7Bz(iHK57K6C9bK4(pDWoNig6E1ptVHMrQ74craU9U6CTBdHnfyT8S6Zn6Wz1xP1qZs0gVbznAEJGyaJzNYpa3l0kFk3kWUWJ3mAup)vMg26bN090Qi31JgzmHa)P3hP4u1AFOE90j20a7zugUQ6G0M9zQ9ySoCBKap7iAS097B5kGG21FrnaQnJQ04y1UJmcxCM)6Z2radXRT7d0(I34KO989Q6n6bCV0FVBGthQk23db2g)r06LhhXCy7CCehfx)FEZyECRjynOBip9Q97p2o08s7UZ86PyNzIKWgm5urhz2Rvi598CjRUzKxtWVZTu5tZW2vac1Gd)DWsdY8WXnuPNlH71thzJuF)EVWn73in)Q3kJou90BLrxMsmM3D)x2j9Ce7b7trE0nV9cPt54nUKJ1vBsyyuWeET3gJn8ealrd5fdzJkIla2OWMWS)euPHDHma645kpoDi3rU5D1uMeTvlmQe6Rjj8(MZVkIyNUd1aS17mVqS65c0Xq3ilMyXg87ngBcpQlZCVUZXx9tmUHP9o(vf3VMzN)PiBnt9w6k0Ci9vsJ4Bs7(5xKE0YbUcMJw9tZU6Aq32)TORzv(9Vr5SfjQPo5O5T0LwTQ)1rtWisddlMs7jo7v1da1D2rpyZTbhgyF1w6h3kV7CXS0tBRT6653TyBi81NkJRAjZDdpiLDZFXQBX3IM5Y2dSAjYp7PuJ8(wo0Cg7bOqlvfOVCu2cJ979HGBC)lu7sqEiFhnjO5IwjkMJOmMEBqRi97eTiHhxv6bxhEurbWxD0tACV0FhBeltbL1zYiA3TPawsxXRT7XTENzhz(Ax4KaPJrpK4boLwrsh1iY(g0eyDkoCSKJtVzYWl91uy9EslsNQGT22xCWpEvsTtH8j30uT7Q3BFdj8tFC4TuwS6nmgBz6X38nJBYi5)p02vMcknrJwaiRij96UpSSvSoZFf38GL3vgKNPLc54ZhDv)2CKFZzJV0joowzI8Ttn0cWqtxi1HK5mVXgeqH1BCkXdDzuidZC90jdnwIqGMA3mFt7VPJbfTVeom9qygv2FodkWeT7NPM4zkss1qzwDUK84nD65PLCV6EjA5f0c5r3nK0nVsL5vBdPoQtLDliDZyBf3Mw3Xv(RUpBt)OWDxVM66nC8aW5TYtDzrmAziN5jprgbXf8utRvzdbz9M6EaYc4PSTFSGjR1PpMVvEX05Hx6QVDAF0(7PMAbLrd74rq1btA1UlwfSr3hQrF3SFVdmgVYDXn(H2zLwAYfNLmZ3PZOEHBCnpE7WfV182zFU0(K4TLtAYSQ92BX9Uj)4io2wqXKfLD0cYdTDKxnx3r1EcXjhnDSLcMSBqo2zz8tAwQBcKUMgFKJxKZFruAerro)U0yenlnUl2PMRdEPDTQH4e)WOKR0xc2N1rUSpOlbIdpN42ZADOSr6S)h6BUGo36cLjTND3eexRTD1t7AMzrzzBoi3rNzEp(eH5Mk)qnqB(lbJyyOtFEr3C8MMM9X9zn3At)GfklxTDFWwZ4U)3)]] )


end
