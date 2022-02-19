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


    spec:RegisterPack( "Outlaw", 20220212, [[d8K6obqiiLEeQuDjarQnHs5taKrbOCkaPvbisEfPkZcs1TqjYUuPFbqnmuQ6yOIwgQWZKezAOeY1ae2MKq6BOsjJtsuQZjjkSouQyEscUhQY(GuCqavTqsfpKuPMikv6IOsXgbuPpkjk5KscXkbWlrLsLzcOIBciQDsQQFkjudfLGJIkLQwkkH6PqmvusxvsuzROsP8varmwuIAVe9xfnyHdlAXQ4XkmzsUmYMrXNHKrtkNwQvljk61OsMnHBlP2Ts)g0WLWXLevTCOEUQMovxhOTlr(Ue14jvY5rvnFjP9tzjNswLiQ0jP(CWEo4G9CWjhxo4K9SOkvrLio)csIuKdUsuKezZAsIuXGUillrks(cyQKSkrEiiEqsen3lE2bWagv7AGN7awd4VRbfP3WDGtghWFxpaSe5a2cVISYJerLoj1Nd2ZbhSNdo54YbNSNfvjoLijORbXseKUw3seTwPOvEKik6hsKkg0fzzlyXquGKba7sdQ(qyl4GBHUfCWEo40aWaq3A5IIE2XaGLSaiNCrwaCf0RnWjJBrVoHXGfUf9AXawFs3IMXIYKfvMGVBHQvw0UfmqSfLGI0BbnFOOeT(1aGLSG1kMDRy2XcUrxf5QSa7NPOF3cgWD4nCtr78TWHwuN(qZIVRhxdawYcwRy2TIzhlyfI3ubTGvCJcfHT4liHqLEAXcDl61cwGvwSf8j)kre97VKvjIIysqHlzvQpNswLi5WB4kr4QhCjrOnpcsj1r6s95qYQeH28iiLuhjII(bUl8gUsewm9oLcxZIMXIc4)9rqwaSfArjqXs48iilOLQB6TOxlgW6t6avIKdVHRe5DkfUM0L6xjjRseAZJGusDKiWcjYtUejhEdxjsPe35rqsKsPaKKiy)mpGmmVfvWcoSGnlaMfO1IdidZ1XG08qjUxuxWclyZc0AXbKH5EWWu9TIUGfwaujII(bUl8gUsewmHHcHfFVOeKfhqgM3ckXc(waDncBHRLRfSIbjl0HsCVOSixLf6GHP6BfjrkL45M1Keb7NjMWqHq6s9zrswLi0MhbPK6irGfsKNCjso8gUsKsjUZJGKiLsbijrgW6dCwa71)RIy6r7wGgEwWHf6zXbKH5EWWu9TIUGfwWMf0syu8Tan8SaiyVfSzbWSaTwmGRcS97acU(01OjuP(lT5rqklQw1IdidZfdfIPRrZdCP)IP6S33c0WZcozVfavIOOFG7cVHReHB2hetwuMSaf5wWakewa81hWxZcDZcwGk79TixLfjMwa5wGjmui6fLf6gcUUfUgzrfRuVfhqgM3ISCYxIukXZnRjjswFaFT5aUQ2B4kDP(aHKvjcT5rqkPoseyHe5jxIKdVHRePuI78iijsPuassKbS(aNfWE93c0WZIrXSo118lOvzblzXbKH5EWWu9TIUGfwWswamloGmmxyrbe7GB78VGfwaKYcpf063kpyp4AQWz5lT5rqklaQfvRAbXWqdVlrZbS(aNfWE93c0WZIrXSo118lOvjru0pWDH3WvIaC7TFnls3I6uxwua)VpcYcDZcwuUDniOBbSeHzeWY9IYIdCbFlgW6d0IcyV(JUfGRG(3cgi2cDCUXIYA9qZIuuo5)w8AqqHYIdzbqONf6MfKiLs8CZAsIW0B)AZbCvT3Wv6s9ROswLi0MhbPK6irGfsem9KlrYH3WvIukXDEeKePuINBwtseME7xBoGRQ9gUsKbUDc3PezaHcfS8EpKxMOD6A0K4t)ftPIVfSzbXWqdVlrZbS(aNfWE93Ikybqiru0pWDH3WvIa8IYj)3I0DQUWTWHwa(Kf64CJfPBbqONf6Mfq3cmHkXkb9Vfqgl0nlybkATOC(ojDP(CljRseAZJGusDKiWcjYtUejhEdxjsPe35rqsKsPaKKiFbjetpXOi)VhrQOjJaeJ5BrfSGdlyZcC2QjvIw)Mk1F71c0ybhS3IQvT4aYWCpIurtgbigZ)IP6S33c0ybNwONfEkO1VC1crVOMFbMOlT5rqkjII(bUl8gUseGK21SOgu4DHGSWtmkYF0TW163IsjUZJGSOFlgA0GlszHdTqrJwrwuwJCncBXdRjl0n7(w8AqqHYIdzXZFhKYIYTRzHoIurwaCfGymFjsPep3SMKihrQOjJaeJ5pF(7q6s9RSLSkrOnpcsj1rImWTt4oLiVtPW1i1nfcjso8gUsem4oZH3WDk63LiI(95M1Ke5DkfUM0L6xzizvIqBEeKsQJejhEdxjYifIzo8gUtr)Uer0Vp3SMKid1lDP(CYEjRseAZJGusDKidC7eUtjsPe35rqxME7xBoGRQ9gUsKC4nCLiyWDMdVH7u0Vlre97ZnRjjctV9RjDP(CYPKvjcT5rqkPosKC4nCLiJuiM5WB4of97ser)(CZAsICaBHs6s95KdjRseAZJGusDKidC7eUtjcTegf)RIy6r7wGgEwWjqyHEwqlHrX)Iju0krYH3WvIK4rU00HymTU0L6ZzLKSkrYH3WvIK4rU0Sau8KeH28iiLuhPl1NtwKKvjso8gUserJsZ)zLjOcvnTUeH28iiLuhPl1NtGqYQejhEdxjYjrnHmth3dUEjcT5rqkPosx6sKcmnG1N0LSk1NtjRsKC4nCLizrHG)Sa2pCLi0MhbPK6iDP(CizvIKdVHRe5aDxqQjJi5tQY9IA6qD1ReH28iiLuhPl1VsswLi5WB4krENsHRjrOnpcsj1r6s9zrswLi0MhbPK6irYH3WvIuNyUi1KbINkkDnjYa3oH7uIGZwnPs063uP(BVwGgl4aiKifyAaRpPpFAax1lracPl1hiKSkrOnpcsj1rImWTt4oLipeuC6vDlaFhuqtcdw4nCV0MhbPSOAvlEiO40R6wcksVf08HIs06xAZJGusKC4nCLimc61g4KXLUu)kQKvjcT5rqkPosKC4nCLiyOqmDnAEGl9sKbUDc3Pebt1zVVfvWIkjrkW0awFsF(0aUQxIWH0L6ZTKSkrOnpcsj1rIKdVHRe5f9GM5QMQEqsKbUDc3Pebtmy61YJGKifyAaRpPpFAax1lr4q6sxICaBHsYQuFoLSkrYH3WvI8uX3VeH28iiLuhPl1NdjRsKC4nCLiO0GVl4pFh3CrseAZJGusDKUu)kjzvIqBEeKsQJezGBNWDkrWGlXaXOOR3l)Pd1vpMhrQOlT5rqkjso8gUsKxRljDP(SijRseAZJGusDKidC7eUtjcAT4HGItVQlXWa(DjAMBxNZCmibHthIV0MhbPSOAvlkL4opc6EePIMmcqmM)85Vdjso8gUseAOb7f1etf4UoxL0L6deswLi0MhbPK6irYH3WvI8egNoPMh4sZVO5IKik6h4UWB4kra(IcbFlq0bXchArkew4jgf5VfLBxdc6wKwOOdidJf5BrbUH425JUffyIHW4ErzHNyuK)wO43lklEiCjSfjJtylCnYIcCxNy(w4jgf5sKbUDc3PebTwOG(9jmoDsnpWLMFrZfnvq)69GRErjDP(vujRseAZJGusDKi5WB4krEcJtNuZdCP5x0CrsKbUDc3PebTwOG(9jmoDsnpWLMFrZfnvq)69GRErjrg8hcA6jgf5VuFoLUuFULKvjcT5rqkPosKC4nCLipHXPtQ5bU08lAUijII(bUl8gUseG3DQUWTWHwa(KfL1O1I2TOClewmYclgW6d0IcyV(BrUklqw21I(TqblVOBb01iC5(jl4IOclyWWAlgzrrVOSyOLyu0lrg42jCNseMgLMpXuD27Brf4zbqyr1QwmGqHcwEVpHXPtQ5bU08lAUOBDQR5qlXOO3cwYIHwIrr)KbNdVHBkSOc8SG9xoaclQw1IbS(aNfWE9)QiME0Uf8SyumrL9AbBwGwloGmm3NlqHyMRAoWW)pWL(lyHfSzbTegf)R3100HZ6uxwGgl4u6s9RSLSkrOnpcsj1rIKdVHRePOFhkMVg0Lik6h4UWB4krQCpzbl0VdfwGObDlk3UMfvCrbe7GB78TOzSq3W6t6wWcqN2bFlkdxa5walr4rwybTegfF0TOSgTw0UfLBHWcsx5Wf8TyKfwOBwaDlGylkRrRfGFVOSGBpyp4Yc2fNLLidC7eUtjYbKH5clkGyhCBN)fSWc2SaywqlHrX)QiME0UfOXcGzbTegf)lMqrRf6zbNS3cGAr1QwmG1h4Sa2R)xfX0J2TOc8SGtl0ZIdidZ9GHP6BfDblSOAvl8uqRFR8G9GRPcNLV0MhbPSaOsxQFLHKvjcT5rqkPosKbUDc3Pe5aYWCHffqSdUTZ)cwybBwamloGmmxuyI2NRE)z5EWfH)lyHfvRAXbKH5oG7GsbPMhb4Qi8b8)lyHfvRAXbKH56q8Mk40Xnkue(cwybqLi5WB4krk63HI5RbDPl1Nt2lzvIKdVHRe57TFNWZ3XnxKeH28iiLuhPl1NtoLSkrOnpcsj1rImWTt4oLiEkO1VQg78NoUhC9xAZJGuwWMfdy9bolG96)vrm9ODlqdpl40c9S4aYWCpyyQ(wrxWcjso8gUseuqquK0LUezOEjRs95uYQeH28iiLuhjso8gUsKJiv0KraIX8Lik6h4UWB4kr0rKkYcGRaeJ5BbCTGd9SGwQUPxImWTt4oLiFbjetpXOi)Tan8SGdlyZc0AXbKH5EePIMmcqmM)fSq6s95qYQeH28iiLuhjso8gUsKs52VMerr)a3fEdxjsL77fLfaF9b81SOFlsl4aiTf9oWu(e6w8ql42YTFnlg5AXHS4H1K310BXHSa8jLf5BrAbO3I25BXxqcHfGRG(3cWVxuwaKZ3jSfa))5)9AbeBb7sPRj4BbIwQGLFjYa3oH7uIGwlWGlXaXOOBDI5AczMUgnRZ3j8m)p)V3lT5rqklyZc0AX7ukCnsDtHWc2SOuI78iOBwFaFT5aUQ2B4AbBwamlqRfyWLyGyu0vrPRj4pFTubl)xAZJGuwuTQfhqgMRIsxtWF(APcw(Vky51c2SyaRpWzbSx)TOc8SGdlaQ0L6xjjRseAZJGusDKiWcjYtUejhEdxjsPe35rqsKsjEUznjrkLB)AZ6CoGRQ9gUsKbUDc3PebdUedeJIU1jMRjKz6A0SoFNWZ8)8)EV0MhbPSGnlqRfEkO1V1jMlsnzG4PIsx7sBEeKsIOOFG7cVHRebiPDnlaY57e2cG))p)Vx0T45Vdl42YTFnlk3UMfPfm92VgHTaITa4RpGVMfkQGwvVOSaUwOJZnwmGqHcwEr3ci2Iuuo5)wKwW0B)Ae2IYTRzbqMHDLiLsbijraMfO1IbekuWY79qEzI2PRrtIp9xmLk(wWMfLsCNhbDz6TFT5aUQ2B4AbqTOAvlaMfdiuOGL37H8YeTtxJMeF6Vykv8TGnlkL4opc6M1hWxBoGRQ9gUwauPl1NfjzvIqBEeKsQJebwirEYLi5WB4krkL4opcsIukfGKePuI78iOltV9RnhWv1EdxjYa3oH7uIGbxIbIrr36eZ1eYmDnAwNVt4z(F(FVxAZJGuwWMfEkO1V1jMlsnzG4PIsx7sBEeKsIukXZnRjjsPC7xBwNZbCvT3Wv6s9bcjRseAZJGusDKidC7eUtjsPe35rq3s52V2SoNd4QAVHRfSzrD(oHN5)5)9oXuD27BbplyVfSzrPe35rq3Jiv0KraIX8Np)DirYH3WvIuk3(1KUu)kQKvjcT5rqkPosKbUDc3PebTwCazyUPctBk6LMyWx7cwirYH3WvIKkmTPOxAIbFnPl1NBjzvIqBEeKsQJerr)a3fEdxjcWvqV2aNmUfmqSfSa47GcYcUbdw4nCTOzSyHUfVtPW1iLf5QSyHUfLBxZcDePISa4kaXy(sKbUDc3Pebyw8qqXPx1Ta8DqbnjmyH3W9sBEeKYIQvT4HGItVQBjOi9wqZhkkrRFPnpcszbqTGnlqRfVtPW1i1nfclyZcGzbAT4aYWCpIurtgbigZ)cwyr1Qw8fKqm9eJI8)EePIMmcqmMVfvWcoSaOwWMfaZc0AXbKH5MkmTPOxAIbFTlyHfvRAbTegf)R3100HZ6uxwGgl4WcGkr61jmgSWNnJe5HGItVQBjOi9wqZhkkrRlr61jmgSWNDDnP60jjcNsKC4nCLimc61g4KXLi96egdw4tuc4jfseoLUu)kBjRseAZJGusDKidC7eUtjcAT4DkfUgPUPqybBwamlkL4opc6Y0B)AZbCvT3W1IQvTWtmkYVExtthovnzrfSGZkzbqLi5WB4kryejksisVHR0L6xzizvIqBEeKsQJezGBNWDkrqRfVtPW1i1nfclyZIbS(aNfWE93IkWZcoSGnlaMfO1IbSeT563s06A8XwuTQfk6aYWCzejksisVH7fSWcGkrYH3WvIOWuQoIurV0L6Zj7LSkrOnpcsj1rImWTt4oLi157eEM)N)37et1zVVf8SG9wWMfhqgMRctP6isf9xfS8AbBwamloGmmxmuiMUgnpWL(lMQZEFlQaplQKfvRArPe35rqxSFMycdfclaQejhEdxjcgketxJMh4sV0L6ZjNswLi0MhbPK6irYH3WvIuNyUi1KbINkkDnjIOxAouseoVaHezWFiOPNyuK)s95uImWTt4oLi4SvtQeT(nvQ)cwybBwaml8eJI8R3100HtvtwublgW6dCwa71)RIy6r7wuTQfO1I3Pu4AK6IHOajlyZIbS(aNfWE9)QiME0UfOHNfJIzDQR5xqRYcwYcoTaOsef9dCx4nCLiveglsL6TiXKfGfOBXVDbzHRrwaxYIYTRzHawME3cwzLDVwu5EYIYA0AHIFVOSGjFNWw4A5AHUzbluetpA3ci2IYTRbbDlYLVf6MfUsxQpNCizvIqBEeKsQJejhEdxjsDI5IutgiEQO01Kik6h4UWB4krQimwSqlsL6TOClewOAYIYTR1RfUgzXs6YTOsS)r3cWNSaiZWUwaxloW)TOC7Aqq3IC5BHUzHRezGBNWDkrWzRMujA9BQu)TxlqJfvI9wWswGZwnPs063uP(RceNEdxlyZc0AX7ukCnsDXquGKfSzXawFGZcyV(FvetpA3c0WZIrXSo118lOvzblzbNsxQpNvsYQeH28iiLuhjcSqI8KlrYH3WvIukXDEeKePukajjcATadUedeJIU1jMRjKz6A0SoFNWZ8)8)EV0MhbPSOAvlgqOqblV3s52V2ft1zVVfOXcozVfvRArD(oHN5)5)9oXuD27BbASGdjII(bUl8gUseG3DQUWTWHw883HfC7AHOxuwGuGjYIYTRzb3wU9RzbdeBbqoFNWwa8)N)3RePuINBwtseUAHOxuZVat0SuU9RnF(7q6s95KfjzvIqBEeKsQJejhEdxjcxTq0lQ5xGjsIOOFG7cVHRePY9Kf9AbNSehSArZyHoo3yr)wawyrUklkdxa5wmYcl4MLWO4JUfqSfPBrLyvplaghSQNfLBxZc2LsxtW3ceTubl)a1ci2IYA0AbqoFNWwa8)N)3Rf9BbyXvImWTt4oLiLsCNhbDpIurtgbigZF(83HfSzrPe35rqxUAHOxuZVat0SuU9RnF(7Wc2SaTw8oLcxJuxmefizbBwamlu0bKH5EiVmr701OjXN(lyHfSzXbKH5QWuQoIur)vblVwWMf0syu8VkIPhTBbASaywqlHrX)Iju0Abqkl4Wc9SGtGWcGAr1Qw8fKqm9eJI8)EePIMmcqmMVfOXcGzbhwWswCazyUkkDnb)5RLky5)cwybqTOAvlQZ3j8m)p)V3jMQZEFlqJfS3cGkDP(CceswLi0MhbPK6irg42jCNsKsjUZJGUhrQOjJaeJ5pF(7Wc2SaywqlHrX)6DnnD4So1LfOXcoSGnloGmmxfMs1rKk6Vky51IQvTGwcJIVfvGNfvI9wuTQfFbjetpXOi)TanwWHfavIKdVHRe5isfnXGVM0L6ZzfvYQeH28iiLuhjYa3oH7uIGwlENsHRrQBkewWMfLsCNhbDZ6d4RnhWv1Edxjso8gUsKxlvWY1KqjDP(CYTKSkrOnpcsj1rImWTt4oLihqgM7raHkb47xmLd3IQvT4a)3c2SGPrP5tmvN9(wublQe7TOAvloGmm3uHPnf9stm4RDblKi5WB4krkGEdxPl1NZkBjRsKC4nCLihbeQMmGy(seAZJGusDKUuFoRmKSkrYH3WvICi8tyU6fLeH28iiLuhPl1Nd2lzvIKdVHReHPX0raHkjcT5rqkPosxQphCkzvIKdVHRej3b9oofZrkeseAZJGusDKUuFo4qYQeH28iiLuhjso8gUsKY9Q(rINL1i)D4ssKbUDc3Pe5liHy6jgf5)9isfnzeGymFlqJfk6BmPMEIrr(Br1QwGZwnPs063uP(BVwGglQOS3IQvT4a)3c2SGPrP5tmvN9(wubl4wsKnRjjs5Ev)iXZYAK)oCjPl1NJkjzvIqBEeKsQJejhEdxjIJ7LlY5uIOOFG7cVHReHDjMeu4wmGRQ9gUVfmqSfGFEeKfTt1)vImWTt4oLik6aYWCpKxMOD6A0K4t)fSWIQvTWX9Yf5xNZRw(tWNMhqgglQw1Id8FlyZcMgLMpXuD27Brf4zbhSx6s95GfjzvIqBEeKsQJezGBNWDkru0bKH5EiVmr701OjXN(lyHfvRAHJ7LlYVohxT8NGpnpGmmwuTQfh4)wWMfmnknFIP6S33IkWZcoyVejhEdxjIJ7LlY5q6sxI8oLcxtYQuFoLSkrOnpcsj1rImWTt4oLiLsCNhbDz6TFT5aUQ2B4krYH3WvIO6Vi9HM0L6ZHKvjso8gUsKS(a(AseAZJGusDKUu)kjzvIqBEeKsQJejhEdxjYqJYI5RbDjYa3oH7uI4PGw)wGj(t4oDnAwMsUU0MhbPSGnlqRfEIrr(T)5b(VezWFiOPNyuK)s95u6sxIW0B)AswL6ZPKvjcT5rqkPosKC4nCLihYlt0oDnAs8PxIOOFG7cVHRerhNBSaUwmGqHcwETWHwWfrfw4AKf6g3Ufk6aYWybyb6waUc6FlCnYcpXOi3I(Tipqq3chAHQjjYa3oH7uI4jgf5xVRPPdNQMSanwujPl1NdjRseAZJGusDKidC7eUtjYbKH5(IEqZCvtvpOlMQZEFlQGfmnknFIP6S33c2Satmy61YJGKi5WB4krErpOzUQPQhK0L6xjjRsKC4nCLiQ(lsFOjrOnpcsj1r6sx6sKse(B4k1Nd2ZbNSNBXzLKiLt82lQxIaKa8Sy9Ri6xzXowybRAKfDDbe7wWaXwaifXKGchqwGPkpyJjLfpSMSibDyD6KYIHwUOO)AaaC6LSGfXowOB4wIWoPSaqd4QaB)YYaYchAbGgWvb2(LLV0MhbPaKfaJtDb0RbGbaqcWZI1VIOFLf7yHfSQrw01fqSBbdeBbGkW0awFshqwGPkpyJjLfpSMSibDyD6KYIHwUOO)AaaC6LSaiyhl0nClryNuwaOhcko9QUSmGSWHwaOhcko9QUS8L28iifGSayCQlGEnaao9swaeSJf6gULiStkla0dbfNEvxwgqw4qla0dbfNEvxw(sBEeKcqwKUfCtfdCSayCQlGEnamaasaEwS(ve9RSyhlSGvnYIUUaIDlyGyla0q9aYcmv5bBmPS4H1KfjOdRtNuwm0Yff9xdaGtVKfCWowOB4wIWoPSaqyWLyGyu0LLbKfo0caHbxIbIrrxw(sBEeKcqwamo0fqVgaaNEjlQe7yHUHBjc7KYcaHbxIbIrrxwgqw4qlaegCjgigfDz5lT5rqkazbW4uxa9AaaC6LSGfXowOB4wIWoPSaqyWLyGyu0LLbKfo0caHbxIbIrrxw(sBEeKcqwamo1fqVgaaNEjl4wSJf6gULiStkla0dbfNEvxwgqw4qla0dbfNEvxw(sBEeKcqwamo0fqVgaaNEjl4SsSJf6gULiStklaegCjgigfDzzazHdTaqyWLyGyu0LLV0MhbPaKfaJtDb0RbaWPxYcoQe7yHUHBjc7KYca54E5I8lNxwgqw4qlaKJ7LlYVoNxwgqwamo1fqVgaaNEjl4GfXowOB4wIWoPSaqoUxUi)YXLLbKfo0ca54E5I8RZXLLbKfaJtDb0RbGbaqcWZI1VIOFLf7yHfSQrw01fqSBbdeBbGoGTqbilWuLhSXKYIhwtwKGoSoDszXqlxu0Fnaao9swuj2XcDd3se2jLfacdUedeJIUSmGSWHwaim4smqmk6YYxAZJGuaYI0TGBQyGJfaJtDb0RbaWPxYcwe7yHUHBjc7KYca9qqXPx1LLbKfo0ca9qqXPx1LLV0MhbPaKfaJtDb0RbaRAKfmqHawUxuwKG48TOmHjlaFszrVw4AKf5WB4AHOF3IdOBrzctwSq3cgi4QSOxlCnYIuPGRfQ0Zt(e7yayblzHdXBQGth3OqrydadGksDbe7KYIkQf5WB4AHOF)VgasKVGgs95OIYEjsbgY0csIWDUBrfd6ISSfSyikqYaG7C3c2Lgu9HWwWb3cDl4G9CWPbGba35Uf6wlxu0ZogaCN7wWswaKtUilaUc61g4KXTOxNWyWc3IETyaRpPBrZyrzYIktW3Tq1klA3cgi2Isqr6TGMpuuIw)AaWDUBblzbRvm7wXSJfCJUkYvzb2ptr)UfmG7WB4MI25BHdTOo9HMfFxpUgaCN7wWswWAfZUvm7ybRq8MkOfSIBuOiSfFbjeQ0tlwOBrVwWcSYITGp5xdadaUZDl4gDrdqNuwCigiMSyaRpPBXHq17FTa4hdQWFlw4YsAjUMbuyro8gUVfWvW)AaKdVH7FlW0awFsNxwui4plG9dxdGC4nC)BbMgW6t66XdWhO7csnzejFsvUxuthQREnaYH3W9VfyAaRpPRhpa)oLcxZaihEd3)wGPbS(KUE8aCDI5IutgiEQO01qVatdy9j95td4QEEab6ndpC2QjvIw)Mk1F7fnCaega5WB4(3cmnG1N01JhGze0RnWjJJEZW7HGItVQBb47GcAsyWcVHB1QpeuC6vDlbfP3cA(qrjADdGC4nC)BbMgW6t66XdWyOqmDnAEGl9OxGPbS(K(8PbCvppoqVz4HP6S3VcvYaihEd3)wGPbS(KUE8a8l6bnZvnv9GqVatdy9j95td4QEECGEZWdtmy61YJGmama4o3TGB0fnaDszbvIW8TW7AYcxJSihoeBr)wKLYwKhbDnaYH3W95Xvp4YaG7wWIP3Pu4Aw0mwua)VpcYcGTqlkbkwcNhbzbTuDtVf9AXawFshOga5WB4(6XdWVtPW1ma4UfSycdfcl(ErjiloGmmVfuIf8Ta6Ae2cxlxlyfdswOdL4ErzrUkl0bdt13kYaihEd3xpEaUuI78ii03SM4H9ZetyOqGEPuas8W(zEazy(kWbBadThqgMRJbP5HsCVOUGfSH2didZ9GHP6BfDblaQba3TGB2hetwuMSaf5wWakewa81hWxZcDZcwGk79TixLfjMwa5wGjmui6fLf6gcUUfUgzrfRuVfhqgM3ISCY3aihEd3xpEaUuI78ii03SM4L1hWxBoGRQ9gUOxkfGeVbS(aNfWE9)QiME0oA4XHEhqgM7bdt13k6cwWgTegfF0WdiypBadTd4QaB)oGGRpDnAcvQVA1didZfdfIPRrZdCP)IP6S3hn84K9a1aG7waC7TFnls3I6uxwua)VpcYcDZcwuUDniOBbSeHzeWY9IYIdCbFlgW6d0IcyV(JUfGRG(3cgi2cDCUXIYA9qZIuuo5)w8AqqHYIdzbqONf6MfmaYH3W91JhGlL4opcc9nRjEm92V2Caxv7nCrVukajEdy9bolG96pA4nkM1PUMFbTkw6aYWCpyyQ(wrxWcwcyhqgMlSOaIDWTD(xWcGuEkO1VvEWEW1uHZYxAZJGuaTAvIHHgExIMdy9bolG96pA4nkM1PUMFbTkdaUBbWlkN8Fls3P6c3chAb4twOJZnwKUfaHEwOBwaDlWeQeRe0)wazSq3SGfOO1IY57Kbqo8gUVE8aCPe35rqOVznXJP3(1Md4QAVHl6WcEy6jh9MH3acfky59EiVmr701OjXN(lMsfF2iggA4DjAoG1h4Sa2R)vaima4UfajTRzrnOW7cbzHNyuK)OBHR1VfLsCNhbzr)wm0ObxKYchAHIgTISOSg5Ae2IhwtwOB29T41GGcLfhYIN)oiLfLBxZcDePISa4kaXy(ga5WB4(6XdWLsCNhbH(M1eVJiv0KraIX8Np)DGEPuas8(csiMEIrr(FpIurtgbigZVcCWgoB1KkrRFtL6V9IgoyF1QhqgM7rKkAYiaXy(xmvN9(OHt98uqRF5QfIErn)cmrxAZJGuga5WB4(6XdWyWDMdVH7u0VJ(M1eV3Pu4AO3m8ENsHRrQBkega5WB4(6XdWJuiM5WB4of97OVznXBOEdGC4nCF94bym4oZH3WDk63rFZAIhtV9RHEZWRuI78iOltV9RnhWv1EdxdGC4nCF94b4rkeZC4nCNI(D03SM4DaBHYaihEd3xpEaoXJCPPdXyAD0BgE0syu8VkIPhTJgECce6rlHrX)Iju0AaKdVH7RhpaN4rU0Sau8Kbqo8gUVE8aSOrP5)SYeuHQMw3aihEd3xpEa(KOMqMPJ7bxVbGba35Uf6a2cfHFdGC4nC)7bSfkEpv89BaKdVH7FpGTqPhpaJsd(UG)8DCZfzaKdVH7FpGTqPhpa)ADj0BgEyWLyGyu017L)0H6QhZJivKbqo8gU)9a2cLE8amn0G9IAIPcCxNRc9MHhAFiO40R6smmGFxIM5215mhdsq40H4QvlL4opc6EePIMmcqmM)85VddaUBbWxui4BbIoiw4qlsHWcpXOi)TOC7Aqq3I0cfDazySiFlkWne3oF0TOatmeg3lkl8eJI83cf)ErzXdHlHTizCcBHRrwuG76eZ3cpXOi3aihEd3)EaBHspEa(jmoDsnpWLMFrZfHEZWdTkOFFcJtNuZdCP5x0Crtf0VEp4Qxuga5WB4(3dylu6XdWpHXPtQ5bU08lAUi0h8hcA6jgf5pporVz4Hwf0VpHXPtQ5bU08lAUOPc6xVhC1lkdaUBbW7ovx4w4qlaFYIYA0Ar7wuUfclgzHfdy9bArbSx)TixLfil7Ar)wOGLx0Ta6AeUC)KfCruHfmyyTfJSOOxuwm0smk6naYH3W9VhWwO0JhGFcJtNuZdCP5x0CrO3m8yAuA(et1zVFf4bevRoGqHcwEVpHXPtQ5bU08lAUOBDQR5qlXOONLgAjgf9tgCo8gUPOc8y)LdGOA1bS(aNfWE9)QiME0oVrXev2lBO9aYWCFUafIzUQ5ad))ax6VGfSrlHrX)6DnnD4So1fA40aG7wu5EYcwOFhkSard6wuUDnlQ4Ici2b325BrZyHUH1N0TGfGoTd(wugUaYTawIWJSWcAjmk(OBrznATODlk3cHfKUYHl4BXilSq3Sa6waXwuwJwla)Erzb3EWEWLfSlolBaKdVH7FpGTqPhpax0VdfZxd6O3m8oGmmxyrbe7GB78VGfSbmAjmk(xfX0J2rdWOLWO4FXekA1Jt2d0QvhW6dCwa71)RIy6r7vGhN6DazyUhmmvFROlyr1QEkO1VvEWEW1uHZYxAZJGua1aihEd3)EaBHspEaUOFhkMVg0rVz4DazyUWIci2b325FblydyhqgMlkmr7ZvV)SCp4IW)fSOA1didZDa3bLcsnpcWvr4d4)xWIQvpGmmxhI3ubNoUrHIWxWcGAaKdVH7FpGTqPhpa)92Vt4574MlYaihEd3)EaBHspEagfeefHEZWZtbT(v1yN)0X9GR)sBEeKITbS(aNfWE9)QiME0oA4XPEhqgM7bdt13k6cwyayaWDUBHUHqHcwEFdaUBHoIurwaCfGymFlGRfCONf0s1n9ga5WB4(3H65DePIMmcqmMp6ndVVGeIPNyuK)OHhhSH2didZ9isfnzeGym)lyHba3TOY99IYcGV(a(Aw0VfPfCaK2IEhykFcDlEOfCB52VMfJCT4qw8WAY7A6T4qwa(KYI8TiTa0Br78T4liHWcWvq)Bb43lklaY57e2cG))8)ETaITGDP01e8TarlvWYVbqo8gU)DOE94b4s52Vg6ndp0IbxIbIrr36eZ1eYmDnAwNVt4z(F(FVSH23Pu4AK6McbBLsCNhbDZ6d4RnhWv1Edx2agAXGlXaXOORIsxtWF(APcw(Rw9aYWCvu6Ac(ZxlvWY)vblVSnG1h4Sa2R)vGhha1aG7waK0UMfa58DcBbW))N)3l6w883HfCB52VMfLBxZI0cME7xJWwaXwa81hWxZcfvqRQxuwaxl0X5glgqOqblVOBbeBrkkN8Flsly6TFncBr521SaiZWUga5WB4(3H61JhGlL4opcc9nRjELYTFTzDohWv1Edx0BgEyWLyGyu0ToXCnHmtxJM157eEM)N)3lBO1tbT(ToXCrQjdepvu6AxAZJGuOxkfGepGH2bekuWY79qEzI2PRrtIp9xmLk(SvkXDEe0LP3(1Md4QAVHlqRwfydiuOGL37H8YeTtxJMeF6Vykv8zRuI78iOBwFaFT5aUQ2B4cudGC4nC)7q96XdWLsCNhbH(M1eVs52V2SoNd4QAVHl6ndpm4smqmk6wNyUMqMPRrZ68DcpZ)Z)7Lnpf0636eZfPMmq8urPRDPnpcsHEPuas8kL4opc6Y0B)AZbCvT3W1aihEd3)ouVE8aCPC7xd9MHxPe35rq3s52V2SoNd4QAVHlB157eEM)N)37et1zVpp2ZwPe35rq3Jiv0KraIX8Np)DyaKdVH7FhQxpEaovyAtrV0ed(AO3m8q7bKH5MkmTPOxAIbFTlyHba3Ta4kOxBGtg3cgi2cwa8Dqbzb3Gbl8gUw0mwSq3I3Pu4AKYICvwSq3IYTRzHoIurwaCfGymFdGC4nC)7q96XdWmc61g4KXrVz4bShcko9QUfGVdkOjHbl8gUvR(qqXPx1TeuKElO5dfLO1bkBO9DkfUgPUPqWgWq7bKH5EePIMmcqmM)fSOA1VGeIPNyuK)3Jiv0KraIX8RahaLnGH2didZnvyAtrV0ed(AxWIQvPLWO4F9UMMoCwN6cnCau071jmgSWNDDnP60jECIEVoHXGf(eLaEsbporVxNWyWcF2m8EiO40R6wcksVf08HIs06ga5WB4(3H61JhGzejksisVHl6ndp0(oLcxJu3uiydyLsCNhbDz6TFT5aUQ2B4wTQNyuKF9UMMoCQAQcCwjGAaKdVH7FhQxpEawHPuDePIE0BgEO9DkfUgPUPqW2awFGZcyV(xbECWgWq7awI2C9BjADn(4Qvv0bKH5YisuKqKEd3lybqnaYH3W9Vd1RhpaJHcX01O5bU0JEZWRoFNWZ8)8)ENyQo795XE2oGmmxfMs1rKk6Vky5LnGDazyUyOqmDnAEGl9xmvN9(vGxLQwTuI78iOl2ptmHHcbqna4UfveglsL6TiXKfGfOBXVDbzHRrwaxYIYTRzHawME3cwzLDVwu5EYIYA0AHIFVOSGjFNWw4A5AHUzbluetpA3ci2IYTRbbDlYLVf6MfUga5WB4(3H61JhGRtmxKAYaXtfLUg6IEP5qXJZlqG(G)qqtpXOi)5Xj6ndpC2QjvIw)Mk1FblydyEIrr(17AA6WPQPkmG1h4Sa2R)xfX0J2RwfTVtPW1i1fdrbsSnG1h4Sa2R)xfX0J2rdVrXSo118lOvXsCcudaUBrfHXIfArQuVfLBHWcvtwuUDTETW1ilwsxUfvI9p6wa(Kfazg21c4AXb(VfLBxdc6wKlFl0nlCnaYH3W9Vd1RhpaxNyUi1KbINkkDn0BgE4SvtQeT(nvQ)2lAQe7zjC2QjvIw)Mk1FvG40B4YgAFNsHRrQlgIcKyBaRpWzbSx)VkIPhTJgEJIzDQR5xqRIL40aG7wa8Ut1fUfo0IN)oSGBxle9IYcKcmrwuUDnl42YTFnlyGylaY57e2cG))8)EnaYH3W9Vd1RhpaxkXDEee6Bwt84QfIErn)cmrZs52V285Vd0lLcqIhAXGlXaXOOBDI5AczMUgnRZ3j8m)p)V3QvhqOqblV3s52V2ft1zVpA4K9vRwNVt4z(F(FVtmvN9(OHddaUBrL7jl61cozjoy1IMXcDCUXI(TaSWICvwugUaYTyKfwWnlHrXhDlGyls3IkXQEwamoyvplk3UMfSlLUMGVfiAPcw(bQfqSfL1O1cGC(oHTa4)p)Vxl63cWIRbqo8gU)DOE94byUAHOxuZVate6ndVsjUZJGUhrQOjJaeJ5pF(7GTsjUZJGUC1crVOMFbMOzPC7xB(83bBO9DkfUgPUyikqInGPOdidZ9qEzI2PRrtIp9xWc2oGmmxfMs1rKk6Vky5LnAjmk(xfX0J2rdWOLWO4FXekAbsXHECceaTA1VGeIPNyuK)3Jiv0KraIX8rdW4GLoGmmxfLUMG)81sfS8FblaA1Q157eEM)N)37et1zVpAypqnaYH3W9Vd1RhpaFePIMyWxd9MHxPe35rq3Jiv0KraIX8Np)DWgWOLWO4F9UMMoCwN6cnCW2bKH5QWuQoIur)vblVvRslHrXVc8Qe7Rw9liHy6jgf5pA4aOga5WB4(3H61JhGFTublxtcf6ndp0(oLcxJu3uiyRuI78iOBwFaFT5aUQ2B4AaKdVH7FhQxpEaUa6nCrVz4DazyUhbeQeGVFXuo8QvpW)zJPrP5tmvN9(vOsSVA1didZnvyAtrV0ed(AxWcdGC4nC)7q96XdWhbeQMmGy(ga5WB4(3H61JhGpe(jmx9IYaihEd3)ouVE8amtJPJacvga5WB4(3H61JhGZDqVJtXCKcHbqo8gU)DOE94byWNMTt1OVznXRCVQFK4zznYFhUe6ndVVGeIPNyuK)3Jiv0KraIX8rJI(gtQPNyuK)vRIZwnPs063uP(BVOPIY(QvpW)zJPrP5tmvN9(vGBzaWDlyxIjbfUfd4QAVH7BbdeBb4Nhbzr7u9FnaYH3W9Vd1Rhpa74E5ICorVz4POdidZ9qEzI2PRrtIp9xWIQvDCVCr(LZRw(tWNMhqgMQvpW)zJPrP5tmvN9(vGhhS3aihEd3)ouVE8aSJ7LlY5a9MHNIoGmm3d5LjANUgnj(0FblQw1X9Yf5xoUA5pbFAEazyQw9a)NnMgLMpXuD27xbECWEdadaUZDlaU92VgHFdaUBHoo3ybCTyaHcfS8AHdTGlIkSW1il0nUDlu0bKHXcWc0TaCf0)w4AKfEIrrUf9BrEGGUfo0cvtga5WB4(xME7xJ3H8YeTtxJMeF6rVz45jgf5xVRPPdNQMqtLmaYH3W9Vm92VME8a8l6bnZvnv9GqVz4DazyUVOh0mx1u1d6IP6S3VcmnknFIP6S3NnmXGPxlpcYaihEd3)Y0B)A6XdWQ(lsFOzayaWDUBbItPW1maYH3W9VVtPW14P6Vi9Hg6ndVsjUZJGUm92V2Caxv7nCnaYH3W9VVtPW10JhGZ6d4RzaKdVH7FFNsHRPhpap0OSy(Aqh9b)HGMEIrr(ZJt0BgEEkO1VfyI)eUtxJMLPKRlT5rqk2qRNyuKF7FEG)lDPlLa]] )
    

end
