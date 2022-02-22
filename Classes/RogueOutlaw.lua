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


    spec:RegisterPack( "Outlaw", 20220221, [[d8extbqirspseXLevGAtQQ8jrIrjQYPevAvIQk6vKQAwOKULisTlf9lvQAyOu6yOuTmuINjQktJuL4AQuX2qPiFtvvkJtuvHZjQawhbQMNOIUhPyFQQQdIsHfsk1djqMiPk1ffrYgvvf(OQQu5KQQIwPkLxkQazMIk0nvvLStru)uubnucuoQQQu1sjvj9uumvsjxvuvvBfLIQVkQQ0yvPs7LK)QIbl5WuTyv5XkmzIUmYMH0NvvgnHoTuRgLIYRjGzJQBRs2Ts)g0WfLJlQQYYH65atx46qSDsLVlcJNufNNGMVi1(PSIDLwkgPhKkzwyllSWwwyH9jlSLD2u(yrXecZiftMpeW)ifZ6xKIjhIeCpHIjZfYHUuPLIbarWdsXigrgqWV)(VoerEZb86EqFHW9OH7a7OX9G(ACVI5H084px1tXi9GujZcBzHf2YclSpzHTSZMYh7kghjeHyfdtFjifJylL0QEkgjbgkMCisW9ewPxHFiKD7pOhgXXcTIf2z1kwyllSy3SBcs03pci42TK2Q)YfGS6p4eqCGD0WQEdcJrYcR61Qb865HvnQvjiRyZqaHvYwAvhwHcXwPdY9O50ba56OnMkgEdcGslfJKqDeEO0sLm7kTum(iA4QyeOhcOyO1FCsQ0wfQKzrPLIHw)XjPsBfJKadCNfnCvm6vceKZdrRAuRYGaq)4Kv5TqR0HWxc7pozfT0vtaR61Qb865rUkgFenCvmGGCEiQcvY5tPLIHw)XjPsBfdmtXaOqX4JOHRIrNJB)XjfJoNJqkgC8opeuuGv50kwS6Nv5zvQw9qqrNbgHopYX9(nrYS6NvPA1dbfD(WqxcAjnrYSkxfJKadCNfnCvm6vcd5CRa9(XjREiOOaRihZfAfmejSvHOVwPfgHSsBYX9(zLVsR0gdDjOLKIrNJpRFrkgC8oycd5CvOswVO0sXqR)4KuPTIbMPyauOy8r0WvXOZXT)4KIrNZrifZaE9GNmyVbykj0E0Hv)RXkwSsFREiOOZhg6sqlPjsMv)SIwc)j0Q)1y1DyRv)SkpRs1QbCLiDmhqKnoHiDGsjysR)4K0Q0PT6HGIoXqo)eI05bxcmX0L3lWQ)1yf7S1QCvmscmWDw0WvXKulabtwLGS6JcRqr4CRyJRhcq0kbjyw959cSYxPvoM2ucRWegY59(zLGGiByviswLdLsGvpeuuGvEcxOIrNJpRFrkg)6Haepd4k7OHRkujFhLwkgA9hNKkTvmWmfdGcfJpIgUkgDoU9hNum6CocPygWRh8Kb7naw9VgRgzNlxphqgTsRsAREiOOZhg6sqlPjsMvjTv5z1dbfDcZYG4az7q4ejZQ8tRcNtBmZFi9qGJe7jM06pojTkxRsN2kcfLgrRJod41dEYG9gaR(xJvJSZLRNdiJwPIrsGbUZIgUkM)O3giALhwD56XQmia0pozLGemRs0HiejScQJWOCyIE)S6bxeGvd41dAvgS3aWQvilNaaRqHyR0oskRsi2drRCEcxiWkGieHlT6rwDh9TsqcMIrNJpRFrkg0EBG4zaxzhnCvHkz2KslfdT(JtsL2kgyMIbtakum(iA4Qy0542FCsXOZXN1VifdAVnq8mGRSJgUkMbUdc3UIzaHCjmXoFuKGO9eI0HesGjMCPqR(zfHIsJO1rNb86bpzWEdGv50Q7OyKeyG7SOHRIHn4jCHaR8iORSWQaAfcGSs7iPSYdRUJ(wjibJvRW0NJLCcaScIALGemR(O1QeoiivOs(VP0sXqR)4KuPTIbMPyauOy8r0WvXOZXT)4KIrNZrifdiJ48t44pkaZh3L0bLJGXcTkNwXIv)Sc7T8q6OnMUucM9A1)wXcBTkDAREiOOZh3L0bLJGXcNy6Y7fy1)wXUv6Bv4CAJPanN373bKHjAsR)4KuXijWa3zrdxft(TdrRUq4rNXjRch)rbGvRcXgyLoh3(Jtw1aRgI0qasAvaTssJwswLqKcrcBfaErwji9gyfqeIWLw9iRac3bjTkrhIwPn3LKv)bhbJfQy054Z6xKI5XDjDq5iySWdq4ouHk58dLwkgA9hNKkTvmdCheUDfdiiNhIKC6CUIXhrdxfdgzp(iA4E4nium8geN1VifdiiNhIQqLCoGslfdT(JtsL2kgFenCvmdNZp(iA4E4nium8geN1VifZqcuHkz2zRslfdT(JtsL2kMbUdc3UIrNJB)XPjAVnq8mGRSJgUkgFenCvmyK94JOH7H3GqXWBqCw)IumO92arvOsMD2vAPyO1FCsQ0wX4JOHRIz4C(Xhrd3dVbHIH3G4S(fPyEinxQcvYSZIslfdT(JtsL2kMbUdc3UIHwc)jCkj0E0Hv)RXk2VJv6BfTe(t4etF0Qy8r0WvX44HV0jGymTHkujZE(uAPy8r0WvX44HV0jdHdifdT(JtsL2QqLm76fLwkgFenCvm8(tmah2me53fTHIHw)XjPsBvOsM97O0sX4JOHRI55Fhi6jW9qaGIHw)XjPsBvOcftgMgWRNhkTujZUslfJpIgUkgplJl8KbBaCvm06pojvARcvYSO0sX4JOHRI5bJGtYdk3fsYe9(DcOE6vXqR)4KuPTkujNpLwkgFenCvmGGCEiQyO1FCsQ0wfQK1lkTum06pojvARy8r0WvXC5ybi5bfIpsYdrfZa3bHBxXG9wEiD0gtxkbZET6FRy5okMmmnGxppoaAaxjqXChvOs(okTum06pojvARyg4oiC7kgaeH)6voZqabcNoegjlA4oP1FCsAv60wbGi8xVYPoi3JMthaKRJ2ysR)4KuX4JOHRIbLtaXb2rdvOsMnP0sXqR)4KuPTIXhrdxfdgY5NqKop4safZa3bHBxXGPlVxGv50Q8PyYW0aE984aObCLafdlQqL8FtPLIHw)XjPsBfJpIgUkgaVh0Xx5r2dsXmWDq42vmycftar)XjftgMgWRNhhanGReOyyrfQqX8qAUuPLkz2vAPy8r0WvXaOmqdum06pojvARcvYSO0sX4JOHRI5teccUWdiWTaKIHw)XjPsBvOsoFkTum06pojvARyg4oiC7kgmYsOq8hnJEfEcOE6X5XDjnP1FCsQy8r0WvXaeBDQqLSErPLIHw)XjPsBfZa3bHBxXKQvaic)1RCsOOiGwhD8TV8JpgeNWEaXtA9hNKwLoTv6CC7ponFCxshuocgl8aeUdfJpIgUkgAic797GPmCF5RufQKVJslfdT(JtsL2kgFenCvmacJ9GKNhCPdiRfGumscmWDw0WvXWgzzCHwXOnJvb0kNZTkC8hfaRs0HiejSYTsspeuuRCGvz4gI7qiRwLHjucJ79ZQWXFuaSskS3pRaq4syRC0GWwfIKvz4(YXcTkC8hfkMbUdc3UIjvRKWycim2dsEEWLoGSwa6iHXm6Ha9(PcvYSjLwkgA9hNKkTvm(iA4Qyaeg7bjpp4shqwlaPyg4oiC7kMuTscJjGWypi55bx6aYAbOJegZOhc07NIziCWPt44pkaQKzxfQK)BkTum06pojvARy8r0WvXaim2dsEEWLoGSwasXijWa3zrdxfdBebDLfwfqRqaKvjeP1QoSkrZ5wn8mRgWRh0QmyVbWkFLwXS6TvnWkjmXYQvWqKWjAazLaeLzfkgEz1WZY69ZQHOJ)iGIzG7GWTRyq7pX4GPlVxGv5uJv3XQ0PTAaHCjmXobeg7bjpp4shqwlanVC9CgIo(JawL0wneD8hboOyFenCDUv5uJvSDYYDSkDARgWRh8Kb7natjH2JoSsJvJSZN3Rv)SkvREiOOtGaiC(Xx5zGHaWdUeyIKz1pROLWFcNrFrNaEUC9y1)wXUkujNFO0sXqR)4KuPTIXhrdxftwdci)aeHHIrsGbUZIgUkM8pGSsWAqa5wXicdRs0HOv5WSmioq2oeAvJALGGxppSsWGbTdHwLaUPewb1r4HNzfTe(tiRwLqKwR6WQenNBfPhFeCHwn8mReKGXQvqSvjeP1keqVFw93J0dbSsVXEcfZa3bHBxX8qqrNWSmioq2oeorYS6Nv5zfTe(t4usO9OdR(3Q8SIwc)jCIPpATsFRyNTwLRvPtB1aE9GNmyVbykj0E0Hv5uJvSBL(w9qqrNpm0LGwstKmRsN2QW50gZ8hspe4iXEIjT(JtsRYvfQKZbuAPyO1FCsQ0wXmWDq42vmpeu0jmldIdKTdHtKmR(zvEw9qqrNFyIwGa9coj6HaegmrYSkDAREiOOZbChKZj55XrwjHFiaWejZQCvm(iA4QyYAqa5hGimuHkz2zRslfJpIgUkgqVnii8be4wasXqR)4KuPTkujZo7kTum06pojvARyg4oiC7kMW50gtzJdHNa3dbatA9hNKw9ZQb86bpzWEdWusO9OdR(xJvSBL(w9qqrNpm0LGwstKmfJpIgUkMpiYhPcvOygsGslvYSR0sXqR)4KuPTIXhrdxfZJ7s6GYrWyHkgjbg4olA4Qy0M7sYQ)GJGXcTcUwXI(wrlD1eqXmWDq42vmGmIZpHJ)Oay1)ASIfR(zvQw9qqrNpUlPdkhbJforYuHkzwuAPyO1FCsQ0wX4JOHRIrNVnquXijWa3zrdxft(h07NvSX1dbiAvdSYTILCWw17atoGy1ka0k2CFBGOvdFT6rwbGxu0xeWQhzfcGKw5aRCRqIM3HqRazeNBfYYjaWkeqVFw9xoiiSvSba4aqVwbXwP3KhICHwXi6sycGIzG7GWTRys1kmYsOq8hnVCSahi6jePZLdccFCaWbGEN06pojT6NvPAfgzjui(JM9QR)Gyp697aeDjmHebetA9hNKw9ZQuTceKZdrsoDo3QFwPZXT)400VEiaXZaUYoA4A1pRYZQuTcJSeke)rtj5Hix4bi6sycWKw)XjPvPtB1dbfDkjpe5cparxctaMsyI1QFwnGxp4jd2BaSkNASIfRYvfQKZNslfdT(JtsL2kgyMIbqHIXhrdxfJoh3(JtkgDo(S(fPy05Bdepx(zaxzhnCvmdCheUDfdgzjui(JMxowGde9eI05YbbHpoa4aqVtA9hNKw9ZQuTkCoTX8YXcqYdkeFKKhItA9hNKkgjbg4olA4QyYVDiA1F5GGWwXgaaWbGEz1kGWDyfBUVnq0QeDiALBfAVnqKWwbXwXgxpeGOvskJwzVFwbxR0oskRgqixctSSAfeBLZt4cbw5wH2BdejSvj6q0Q)cvVvm6CocPyYZQuTAaHCjmXoFuKGO9eI0HesGjMCPqR(zLoh3(Jtt0EBG4zaxzhnCTkxRsN2Q8SAaHCjmXoFuKGO9eI0HesGjMCPqR(zLoh3(Jtt)6Haepd4k7OHRv5QcvY6fLwkgA9hNKkTvmWmfdGcfJpIgUkgDoU9hNum6CocPy0542FCAI2Bdepd4k7OHRIzG7GWTRyWilHcXF08YXcCGONqKoxoii8Xbaha6DsR)4K0QFwfoN2yE5ybi5bfIpsYdXjT(JtsfJohFw)Ium68TbINl)mGRSJgUQqL8DuAPyO1FCsQ0wXmWDq42vm6CC7pon15Bdepx(zaxzhnCT6Nvxoii8Xbaha69GPlVxGvASITw9ZkDoU9hNMpUlPdkhbJfEac3HIXhrdxfJoFBGOkujZMuAPyO1FCsQ0wXmWDq42vmPA1dbfD6smToVx6GraItKmfJpIgUkgxIP159shmcqufQK)BkTum06pojvARyKeyG7SOHRI5p4eqCGD0Wkui2kbdbeiCYQKcJKfnCTQrTAHHvGGCEissR8vA1cdRs0HOvAZDjz1FWrWyHkMbUdc3UIjpRaqe(Rx5mdbeiC6qyKSOH7Kw)XjPvPtBfaIWF9kN6GCpAoDaqUoAJjT(JtsRY1QFwLQvGGCEisYPZ5w9ZQ8SkvREiOOZh3L0bLJGXcNizwLoTvGmIZpHJ)OamFCxshuocgl0QCAflwLRv)SkpRs1Qhck60LyADEV0bJaeNizwLoTv0s4pHZOVOtapxUES6FRyXQCvm9gegJKfNgvXaGi8xVYPoi3JMthaKRJ2qX0BqymswC6Rls2Eqkg2vm(iA4Qyq5eqCGD0qX0BqymswC(4WNZvmSRcvY5hkTum06pojvARyg4oiC7kMuTceKZdrsoDo3QFwLNv6CC7ponr7TbINbCLD0W1Q0PTkC8hfZOVOtapYMSkNwXE(SkxfJpIgUkguU)rCUhnCvHk5CaLwkgA9hNKkTvmdCheUDftQwbcY5HijNoNB1pRgWRh8Kb7nawLtnwXIv)SkpRs1QbuhT(gtD0gIcXwLoTvs6HGIor5(hX5E0WDIKzvUw9ZQ8SkvRcNtBmVCSaK8GcXhj5H4Kw)XjPvPtBvQwnGqUeMyNxowasEqH4JK8qCIjxk0QCvm(iA4QyKyYLpUljGkujZoBvAPyO1FCsQ0wXmWDq42vmxoii8Xbaha69GPlVxGvASITw9ZQhck6uIjx(4UKatjmXA1pRYZQhck6ed58tisNhCjWetxEVaRYPgRYNvPtBLoh3(JttC8oycd5CRYvX4JOHRIbd58tisNhCjGkujZo7kTum06pojvARy8r0WvXC5ybi5bfIpsYdrfdVx6mKkg2N3rXmeo40jC8hfavYSRyg4oiC7kgS3YdPJ2y6sjyIKz1pRYZQWXFumJ(Iob8iBYQCA1aE9GNmyVbykj0E0HvPtBvQwbcY5HijNy4hcz1pRgWRh8Kb7natjH2JoS6FnwnYoxUEoGmALwL0wXUv5QyKeyG7SOHRI5prTYLsGvoMScjJvRaBNrwfIKvWLSkrhIwXHjiqyLwAP3tRY)aYQeI0ALuyVFwH6GGWwfI(ALGemRKeAp6Wki2QeDicrcR8vOvcsWMQqLm7SO0sXqR)4KuPTIXhrdxfZLJfGKhui(ijpevmscmWDw0WvX8NOwTqRCPeyvIMZTs2Kvj6qSxRcrYQL0tyv(ylGvRqaKv)fQEBfCT6bbaRs0HiejSYxHwjibBQyg4oiC7kgS3YdPJ2y6sjy2Rv)Bv(yRvjTvyVLhshTX0LsWuIG9OHRv)SkvRab58qKKtm8dHS6Nvd41dEYG9gGPKq7rhw9VgRgzNlxphqgTsRsARy3QFwLNvPA1aQJwFJPoAdrHyRsN2QbeYLWe7eL7FeN7rd3jMU8Ebw9VvSZwRsN2kj9qqrNOC)J4CpA4orYSkxvOsM98P0sXqR)4KuPTIbMPyauOy8r0WvXOZXT)4KIrNZriftQwHrwcfI)O5LJf4arpHiDUCqq4Jdaoa07Kw)XjPvPtB1ac5syIDQZ3gioX0L3lWQ)TID2Av60wD5GGWhhaCaO3dMU8Ebw9VvSOyKeyG7SOHRIHnIGUYcRcOvaH7WQCqnN37NvmzyISkrhIwXM7BdeTcfIT6VCqqyRydaWbGEvm6C8z9lsXiqZ59(DazyIo68TbIhGWDOcvYSRxuAPyO1FCsQ0wX4JOHRIrGMZ797aYWePyKeyG7SOHRIj)diR61k2tAw0YQg1kTJKYQgyfsMv(kTkbCtjSA4zwLulH)eYQvqSvEyv(0sFRYJfT03QeDiALEtEiYfAfJOlHja5AfeBvcrAT6VCqqyRydaWbGETQbwHKnvmdCheUDfJoh3(JtZh3L0bLJGXcpaH7WQFwPZXT)40uGMZ797aYWeD05BdepaH7WQFwLQvGGCEisYjg(Hqw9ZQ8Ssspeu05JIeeTNqKoKqcmrYS6Nvpeu0PetU8XDjbMsyI1QFwrlH)eoLeAp6WQ)TkpROLWFcNy6JwRYpTIfR03k2VJv5Av60wbYio)eo(JcW8XDjDq5iySqR(3Q8SIfRsAREiOOtj5Hix4bi6sycWejZQCTkDARUCqq4Jdaoa07btxEVaR(3k2AvUQqLm73rPLIHw)XjPsBfZa3bHBxXOZXT)408XDjDq5iySWdq4oS6Nv5zfTe(t4m6l6eWZLRhR(3kwS6Nvpeu0PetU8XDjbMsyI1Q0PTIwc)j0QCQXQ8XwRsN2kqgX5NWXFuaS6FRyXQCvm(iA4QyECxshmcqufQKzNnP0sXqR)4KuPTIXhrdxfJoFBGOIrsGbUZIgUkM)e1keqVFw9NRU(dI9O3pRyeDjmHebeSAfcGSAH4lNBfh(1dR61kxk7OHRvb0QHineO3pRUC2mi2kbP3GPIzG7GWTRyWilHcXF0SxD9he7rVFhGOlHjKiGysR)4K0QFwnG6O13yQJ2qui2QFwLQvGGCEisYPZ5w9ZkDoU9hNM(1dbiEgWv2rdxR(zvEwLQvdiKlHj2jk3)io3JgUtm5sHw9ZQ8SkvRcNtBmLyYLpUljWKw)XjPvPtBvQwnGqUeMyNsm5Yh3LeyIjxk0Q0PTkvRK0dbfDIY9pIZ9OH7ejZQCTkxvOsM9)MslfdT(JtsL2kMbUdc3UIbJSeke)rZE11FqSh9(DaIUeMqIaIjT(JtsR(zvQwnG6O13yQJ2qui2QFwLQvGGCEisYPZ5w9ZQ8SAaHCjmXoPHiS3VdMYW9LVYjMU8Ebw9VvSjRsN2QuTAaHCjmXobugObtm5sHwLoTvdiKlHj2jGWypi55bx6aYAbOjkcNFW0q0XF0j6lYQ)TIf2AvUkgFenCvm68TbIQqLm75hkTum06pojvARyg4oiC7kMuTceKZdrsoDo3QFwPZXT)400VEiaXZaUYoA4Qy8r0WvXaeDjmXfXLQqLm75akTum06pojvARyg4oiC7kMhck68XHqjhbetm5JWQ0PT6bbaR(zfA)jghmD59cSkNwLp2Av60w9qqrNUetRZ7LoyeG4ejtX4JOHRIjdgnCvHkzwyRslfJpIgUkMhhcLhueSqfdT(JtsL2QqLmlSR0sX4JOHRI5ryaHfO3pfdT(JtsL2QqLmlSO0sX4JOHRIbTX0JdHsfdT(JtsL2QqLml5tPLIXhrdxfJVdceyNFgoNRyO1FCsQ0wfQKzrVO0sXqR)4KuPTIXhrdxftG7vakyxXijWa3zrdxfJEtOocpSAaxzhnCbwHcXwHa8hNSQd6cmvmdCheUDfJKEiOOZhfjiApHiDiHeyIKzv60wf4EfGIzW(u0bheaDEiOOwLoTvpiay1pRq7pX4GPlVxGv5uJvSWwvOsML7O0sXqR)4KuPTIzG7GWTRyK0dbfD(Oibr7jePdjKatKmRsN2Qa3RaumdwMIo4GaOZdbf1Q0PT6bbaR(zfA)jghmD59cSkNASIf2Qy8r0WvXe4EfGcwuHkumGGCEiQ0sLm7kTum06pojvARyg4oiC7kgDoU9hNMO92aXZaUYoA4Qy8r0WvXiBqMhdrvOsMfLwkgFenCvm(1dbiQyO1FCsQ0wfQKZNslfdT(JtsL2kgFenCvmdrYZoaryOyg4oiC7kMW50gZmmj8a3tisNeKlWKw)XjPv)SkvRch)rXSbNheaumdHdoDch)rbqLm7Qqfkg0EBGOslvYSR0sXqR)4KuPTIXhrdxfZJIeeTNqKoKqcOyKeyG7SOHRIr7iPScUwnGqUeMyTkGwjarzwfIKvcc3Hvs6HGIAfsgRwHSCcaSkejRch)rHvnWk)brcRcOvYMumdCheUDft44pkMrFrNaEKnz1)wLpvOsMfLwkgA9hNKkTvmdCheUDfZdbfDc49Go(kpYEqtmD59cSkNwH2FIXbtxEVaR(zfMqXeq0FCsX4JOHRIbW7bD8vEK9GuHk58P0sX4JOHRIr2GmpgIkgA9hNKkTvHkuHIrhHbnCvjZcBzHf2Yc7SOys44T3pGIj)Yg61K)ZK)7eCRSslrYQ(kdIdRqHyRsrsOocpsXkmL)qAmjTcaViRCKaE5bjTAi67hbM2TCSxYk9IGBLGGRochK0QugWvI0X8UPyvaTkLbCLiDmV7Kw)XjzkwLh76j3PDZULFzd9AY)zY)DcUvwPLizvFLbXHvOqSvPKHPb865rkwHP8hsJjPva4fzLJeWlpiPvdrF)iW0ULJ9swDhb3kbbxDeoiPvPaGi8xVY5DtXQaAvkaic)1RCE3jT(JtYuSkp21tUt7wo2lz1DeCReeC1r4GKwLcaIWF9kN3nfRcOvPaGi8xVY5DN06pojtXkpSkPYH5Ov5XUEYDA3SB5x2qVM8FM8FNGBLvAjsw1xzqCyfkeBvkdjifRWu(dPXK0ka8ISYrc4LhK0QHOVFeyA3YXEjRyrWTsqWvhHdsAvkyKLqH4pAE3uSkGwLcgzjui(JM3DsR)4KmfRYlF6j3PDlh7LSkFcUvccU6iCqsRsbJSeke)rZ7MIvb0QuWilHcXF08UtA9hNKPyvESRNCN2TCSxYk9IGBLGGRochK0QuWilHcXF08UPyvaTkfmYsOq8hnV7Kw)XjzkwLh76j3PDlh7LS6Vj4wji4QJWbjTkfaeH)6voVBkwfqRsbar4VELZ7oP1FCsMIv5XIEYDA3YXEjRYbeCReeC1r4GKwLs4CAJ5DtXQaAvkHZPnM3DsR)4KmfRYJD9K70ULJ9swXE(eCReeC1r4GKwLcgzjui(JM3nfRcOvPGrwcfI)O5DN06pojtXQ8yxp5oTB5yVKvSZMeCReeC1r4GKwLs4CAJ5DtXQaAvkHZPnM3DsR)4KmfRYJD9K70ULJ9swXoBsWTsqWvhHdsAvkyKLqH4pAE3uSkGwLcgzjui(JM3DsR)4KmfRYJD9K70ULJ9swX(FtWTsqWvhHdsAvkyKLqH4pAE3uSkGwLcgzjui(JM3DsR)4KmfRYJD9K70ULJ9swXIErWTsqWvhHdsAvkbUxbOyY(8UPyvaTkLa3Raumd2N3nfRYJD9K70ULJ9swXYDeCReeC1r4GKwLsG7vakMSmVBkwfqRsjW9kafZGL5DtXQ8yxp5oTB2T8lBOxt(pt(VtWTYkTejR6RmioScfITkLhsZLPyfMYFinMKwbGxKvosaV8GKwne99Jat7wo2lzv(eCReeC1r4GKwLcgzjui(JM3nfRcOvPGrwcfI)O5DN06pojtXkpSkPYH5Ov5XUEYDA3YXEjR0lcUvccU6iCqsRsbar4VELZ7MIvb0Quaqe(Rx58UtA9hNKPyvESRNCN2n72FELbXbjTInzLpIgUwXBqaM2nfdiJgQKzHnXwftggI2CsXKKKyvoej4EcR0RWpeYULKKy1FqpmIJfAflSZQvSWwwyXUz3sssSsqI((rab3ULKKyvsB1F5cqw9hCcioWoAyvVbHXizHv9A1aE98WQg1QeKvSziGWkzlTQdRqHyR0b5E0C6aGCD0gt7MDljjXQKsp0ajiPvpcfIjRgWRNhw9OVEbtRyJXGYcGvlCtArhFHIWTYhrdxGvWLlCA38r0WfmZW0aE98qJNLXfEYGnaU2nFenCbZmmnGxpp0xZ9pyeCsEq5UqsMO3Vta1tV2nFenCbZmmnGxpp0xZ9GGCEiA38r0WfmZW0aE98qFn3F5ybi5bfIpsYdrwZW0aE984aObCLan3H1gvd2B5H0rBmDPem79FwUJDZhrdxWmdtd41Zd91CpkNaIdSJgS2OAaqe(Rx5mdbeiC6qyKSOHB60aic)1RCQdY9O50ba56OnSB(iA4cMzyAaVEEOVM7Xqo)eI05bxcWAgMgWRNhhanGReOHfwBuny6Y7fKZ8z38r0WfmZW0aE98qFn3d49Go(kpYEqSMHPb865Xbqd4kbAyH1gvdMqXeq0FCYUz3sssSkP0dnqcsAfPJWcTk6lYQqKSYhbeBvdSY15n3FCAA38r0WfOrGEiGDljwPxjqqopeTQrTkdca9JtwL3cTshcFjS)4Kv0sxnbSQxRgWRNh5A38r0WfOVM7bb58q0ULeR0RegY5wb69Jtw9qqrbwroMl0kyisyRcrFTslmczL2KJ79ZkFLwPng6sqlj7MpIgUa91CVoh3(JtSU(fPbhVdMWqoNvDohH0GJ35HGIcYjl)Yl1hck6mWi05roU3Vjs2VuFiOOZhg6sqlPjswU2TKyvsTaemzvcYQpkScfHZTInUEiarReKGz1N3lWkFLw5yAtjSctyiN37NvccISHvHizvoukbw9qqrbw5jCH2nFenCb6R5EDoU9hNyD9lsJF9qaINbCLD0WLvDohH0mGxp4jd2BaMscThD8Vgw0)HGIoFyOlbTKMiz)OLWFc)xZDy7V8sDaxjshZbezJtishOucsN(HGIoXqo)eI05bxcmX0L3l4FnSZ2CTBjXQ)O3giALhwD56XQmia0pozLGemRs0HiejScQJWOCyIE)S6bxeGvd41dAvgS3aWQvilNaaRqHyR0oskRsi2drRCEcxiWkGieHlT6rwDh9TsqcMDZhrdxG(AUxNJB)Xjwx)I0G2Bdepd4k7OHlR6CocPzaVEWtgS3a8VMr25Y1ZbKrRmPFiOOZhg6sqlPjswsN3dbfDcZYG4az7q4ejl)mCoTXm)H0dbosSNysR)4Km30PjuuAeTo6mGxp4jd2Ba(xZi7C565aYOvA3sIvSbpHleyLhbDLfwfqRqaKvAhjLvEy1D03kbjySAfM(CSKtaGvquReKGz1hTwLWbbz38r0WfOVM71542FCI11VinO92aXZaUYoA4YkmtdMauWAJQzaHCjmXoFuKGO9eI0HesGjMCPWFekknIwhDgWRh8Kb7na58o2TKyv(TdrRUq4rNXjRch)rbGvRcXgyLoh3(Jtw1aRgI0qasAvaTssJwswLqKcrcBfaErwji9gyfqeIWLw9iRac3bjTkrhIwPn3LKv)bhbJfA38r0WfOVM71542FCI11VinpUlPdkhbJfEac3bR6CocPbKrC(jC8hfG5J7s6GYrWyH5KLFyVLhshTX0LsWS3)zHTPt)qqrNpUlPdkhbJfoX0L3l4F21pCoTXuGMZ797aYWenP1FCsA38r0WfOVM7Xi7Xhrd3dVbbRRFrAab58qK1gvdiiNhIKC6CUDZhrdxG(AUF4C(Xhrd3dVbbRRFrAgsGDZhrdxG(AUhJShFenCp8geSU(fPbT3giYAJQrNJB)XPjAVnq8mGRSJgU2nFenCb6R5(HZ5hFenCp8geSU(fP5H0CPDZhrdxG(AU3XdFPtaXyAdwBun0s4pHtjH2Jo(xd73rFAj8NWjM(O1U5JOHlqFn374HV0jdHdi7MpIgUa91CpV)edWHndr(DrBy38r0WfOVM7F(3bIEcCpeay3SBjjjwPnsZLegy38r0WfmFinxQbqzGgy38r0WfmFinxQVM7)eHGGl8acClaz38r0WfmFinxQVM7bITowBunyKLqH4pAg9k8eq90JZJ7sYU5JOHly(qAUuFn3tdryVFhmLH7lFLS2OAsfar4VELtcffb06OJV9LF8XG4e2dioDADoU9hNMpUlPdkhbJfEac3HDljwXgzzCHwXOnJvb0kNZTkC8hfaRs0HiejSYTsspeuuRCGvz4gI7qiRwLHjucJ79ZQWXFuaSskS3pRaq4syRC0GWwfIKvz4(YXcTkC8hf2nFenCbZhsZL6R5EaHXEqYZdU0bK1cqS2OAsvcJjGWypi55bx6aYAbOJegZOhc07NDZhrdxW8H0CP(AUhqyShK88GlDazTaeRdHdoDch)rbqd7S2OAsvcJjGWypi55bx6aYAbOJegZOhc07NDljwXgrqxzHvb0keazvcrATQdRs0CUvdpZQb86bTkd2BaSYxPvmREBvdSsctSSAfmejCIgqwjarzwHIHxwn8SSE)SAi64pcy38r0WfmFinxQVM7beg7bjpp4shqwlaXAJQbT)eJdMU8Eb5uZDsNEaHCjmXobeg7bjpp4shqwlanVC9CgIo(Jaj9q0XFe4GI9r0W155udBNSCN0PhWRh8Kb7natjH2Jo0mYoFEV)s9HGIobcGW5hFLNbgcap4sGjs2pAj8NWz0x0jGNlxp)ZUDljwL)bKvcwdci3kgryyvIoeTkhMLbXbY2HqRAuRee865HvcgmODi0QeWnLWkOocp8mROLWFcz1QeI0AvhwLO5CRi94JGl0QHNzLGemwTcITkHiTwHa69ZQ)EKEiGv6n2ty38r0WfmFinxQVM7ZAqa5hGimyTr18qqrNWSmioq2oeorY(LhTe(t4usO9OJ)ZJwc)jCIPpA1ND2MB60d41dEYG9gGPKq7rh5ud76)qqrNpm0LGwstKS0PdNtBmZFi9qGJe7jM06pojZ1U5JOHly(qAUuFn3N1GaYparyWAJQ5HGIoHzzqCGSDiCIK9lVhck68dt0ceOxWjrpeGWGjsw60peu05aUdY5K884iRKWpeayIKLRDZhrdxW8H0CP(AUh0BdccFabUfGSB(iA4cMpKMl1xZ9FqKpI1gvt4CAJPSXHWtG7HaGjT(JtYFd41dEYG9gGPKq7rh)RHD9FiOOZhg6sqlPjsMDZULKKyLGGqUeMyb2TKyL2Cxsw9hCemwOvW1kw03kAPRMa2nFenCbZHeO5XDjDq5iySqwBunGmIZpHJ)Oa8Vgw(L6dbfD(4UKoOCemw4ejZULeRY)GE)SInUEiarRAGvUvSKd2QEhyYbeRwbGwXM7BdeTA4RvpYka8II(Iaw9iRqaK0khyLBfs08oeAfiJ4CRqwobawHa69ZQ)YbbHTInaaha61ki2k9M8qKl0kgrxctaSB(iA4cMdjqFn3RZ3giYAJQjvmYsOq8hnVCSahi6jePZLdccFCaWbGE)Lkgzjui(JM9QR)Gyp697aeDjmHebe)sfeKZdrsoDo)Noh3(Jtt)6Haepd4k7OH7V8sfJSeke)rtj5Hix4bi6sycq60peu0PK8qKl8aeDjmbykHj2Fd41dEYG9gGCQHLCTBjXQ8BhIw9xoiiSvSbaaCaOxwTciChwXM7BdeTkrhIw5wH2BdejSvqSvSX1dbiALKYOv27NvW1kTJKYQbeYLWelRwbXw58eUqGvUvO92arcBvIoeT6Vq1B7MpIgUG5qc0xZ96CC7poX66xKgD(2aXZLFgWv2rdxwBunyKLqH4pAE5yboq0tisNlhee(4aGda9(l1W50gZlhlajpOq8rsEioP1FCsYQoNJqAYl1beYLWe78rrcI2tishsibMyYLc)PZXT)40eT3giEgWv2rd3CtNoVbeYLWe78rrcI2tishsibMyYLc)PZXT)400VEiaXZaUYoA4MRDZhrdxWCib6R5EDoU9hNyD9lsJoFBG45Ypd4k7OHlRnQgmYsOq8hnVCSahi6jePZLdccFCaWbGE)foN2yE5ybi5bfIpsYdXjT(Jtsw15CesJoh3(Jtt0EBG4zaxzhnCTB(iA4cMdjqFn3RZ3giYAJQrNJB)XPPoFBG45Ypd4k7OH7Vlhee(4aGda9EW0L3lqdB)PZXT)408XDjDq5iySWdq4oSB(iA4cMdjqFn37smToVx6GraIS2OAs9HGIoDjMwN3lDWiaXjsMDljw9hCcioWoAyfkeBLGHaceozvsHrYIgUw1OwTWWkqqopejPv(kTAHHvj6q0kT5UKS6p4iySq7MpIgUG5qc0xZ9OCcioWoAWAJQjpaeH)6voZqabcNoegjlA4MonaIWF9kN6GCpAoDaqUoAJC)LkiiNhIKC6C(V8s9HGIoFCxshuocglCIKLoniJ48t44pkaZh3L0bLJGXcZjl5(lVuFiOOtxIP159shmcqCIKLonTe(t4m6l6eWZLRN)zjxw7nimgjlo91fjBpinSZAVbHXizX5JdFoxd7S2BqymswCAunaic)1RCQdY9O50ba56OnSB(iA4cMdjqFn3JY9pIZ9OHlRnQMubb58qKKtNZ)LNoh3(Jtt0EBG4zaxzhnCtNoC8hfZOVOtapYMYj75lx7MpIgUG5qc0xZ9sm5Yh3LeG1gvtQGGCEisYPZ5)gWRh8Kb7na5udl)Yl1buhT(gtD0gIcXPtlPhck6eL7FeN7rd3jswU)Yl1W50gZlhlajpOq8rsEiMoDQdiKlHj25LJfGKhui(ijpeNyYLcZ1U5JOHlyoKa91CpgY5NqKop4sawBunxoii8Xbaha69GPlVxGg2(7HGIoLyYLpUljWuctS)Y7HGIoXqo)eI05bxcmX0L3liNAYx606CC7ponXX7GjmKZZ1ULeR(tuRCPeyLJjRqYy1kW2zKvHizfCjRs0HOvCyccewPLw690Q8pGSkHiTwjf27NvOoiiSvHOVwjibZkjH2JoScITkrhIqKWkFfALGeSPDZhrdxWCib6R5(lhlajpOq8rsEiYkVx6mKAyFEhwhchC6eo(JcGg2zTr1G9wEiD0gtxkbtKSF5fo(JIz0x0jGhzt5CaVEWtgS3amLeAp6iD6ubb58qKKtm8dH(nGxp4jd2BaMscThD8VMr25Y1ZbKrRmPzpx7wsS6prTAHw5sjWQenNBLSjRs0HyVwfIKvlPNWQ8XwaRwHaiR(lu92k4A1dcawLOdrisyLVcTsqc20U5JOHlyoKa91C)LJfGKhui(ijpezTr1G9wEiD0gtxkbZE)pFSnPXElpKoAJPlLGPeb7rd3FPccY5HijNy4hc9BaVEWtgS3amLeAp64FnJSZLRNdiJwzsZ(V8sDa1rRVXuhTHOqC60diKlHj2jk3)io3JgUtmD59c(ND2MoTKEiOOtuU)rCUhnCNiz5A3sIvSre0vwyvaTciChwLdQ58E)SIjdtKvj6q0k2CFBGOvOqSv)LdccBfBaaoa0RDZhrdxWCib6R5EDoU9hNyD9lsJanN373bKHj6OZ3giEac3bR6CocPjvmYsOq8hnVCSahi6jePZLdccFCaWbGEtNEaHCjmXo15BdeNy6Y7f8p7SnD6lhee(4aGda9EW0L3l4FwSBjXQ8pGSQxRypPzrlRAuR0oskRAGvizw5R0QeWnLWQHNzvsTe(tiRwbXw5Hv5tl9Tkpw0sFRs0HOv6n5HixOvmIUeMaKRvqSvjeP1Q)YbbHTInaaha61Qgyfs20U5JOHlyoKa91CVanN373bKHjI1gvJoh3(JtZh3L0bLJGXcpaH74Noh3(JttbAoV3Vdidt0rNVnq8aeUJFPccY5HijNy4hc9lpj9qqrNpksq0Ecr6qcjWej73dbfDkXKlFCxsGPeMy)rlH)eoLeAp64)8OLWFcNy6J28tw0N97KB60GmIZpHJ)OamFCxshuocgl8)8yjPFiOOtj5Hix4bi6sycWejl30PVCqq4Jdaoa07btxEVG)zBU2nFenCbZHeOVM7FCxshmcqK1gvJoh3(JtZh3L0bLJGXcpaH74xE0s4pHZOVOtapxUE(NLFpeu0PetU8XDjbMsyInDAAj8NWCQjFSnDAqgX5NWXFua(NLCTBjXQ)e1keqVFw9NRU(dI9O3pRyeDjmHebeSAfcGSAH4lNBfh(1dR61kxk7OHRvb0QHineO3pRUC2mi2kbP3GPDZhrdxWCib6R5ED(2arwBunyKLqH4pA2RU(dI9O3Vdq0LWeseq8Ba1rRVXuhTHOq8Vubb58qKKtNZ)PZXT)400VEiaXZaUYoA4(lVuhqixctStuU)rCUhnCNyYLc)LxQHZPnMsm5Yh3LeiD6uhqixctStjMC5J7scmXKlfMoDQs6HGIor5(hX5E0WDIKLBU2nFenCbZHeOVM715BdezTr1GrwcfI)OzV66pi2JE)oarxctiraXVuhqD06Bm1rBike)lvqqopej5058F5nGqUeMyN0qe273btz4(Yx5etxEVG)ztPtN6ac5syIDcOmqdMyYLctNEaHCjmXobeg7bjpp4shqwlanrr48dMgIo(JorFr)ZcBZ1U5JOHlyoKa91Cpq0LWexexYAJQjvqqopej5058F6CC7pon9Rhcq8mGRSJgU2nFenCbZHeOVM7ZGrdxwBunpeu05JdHsociMyYhr60pia8dT)eJdMU8Eb5mFSnD6hck60LyADEV0bJaeNiz2nFenCbZHeOVM7FCiuEqrWcTB(iA4cMdjqFn3)imGWc07NDZhrdxWCib6R5E0gtpoekTB(iA4cMdjqFn377Gab25NHZ52TKyLEtOocpSAaxzhnCbwHcXwHa8hNSQd6cmTB(iA4cMdjqFn3h4EfGc2zTr1iPhck68rrcI2tishsibMizPth4EfGIj7trhCqa05HGIMo9dca)q7pX4GPlVxqo1WcBTB(iA4cMdjqFn3h4EfGcwyTr1iPhck68rrcI2tishsibMizPth4EfGIjltrhCqa05HGIMo9dca)q7pX4GPlVxqo1WcBTB2TKKeR(JEBGiHb2TKyL2rszfCTAaHCjmXAvaTsaIYSkejReeUdRK0dbf1kKmwTcz5eayviswfo(JcRAGv(dIewfqRKnz38r0Wfmr7TbIAEuKGO9eI0HesawBunHJ)Oyg9fDc4r20)5ZU5JOHlyI2Bde1xZ9aEpOJVYJSheRnQMhck6eW7bD8vEK9GMy6Y7fKt0(tmoy6Y7f8dtOyci6poz38r0Wfmr7TbI6R5EzdY8yiA3SBjjjwXeKZdr7MpIgUGjiiNhIAKniZJHiRnQgDoU9hNMO92aXZaUYoA4A38r0Wfmbb58quFn37xpeGODZhrdxWeeKZdr91C)qK8SdqegSoeo40jC8hfanSZAJQjCoTXmdtcpW9eI0jb5cmP1FCs(l1WXFumBW5bbavOcLc]] )
    

end
