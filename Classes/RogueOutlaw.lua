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


    spec:RegisterPack( "Outlaw", 20220308, [[d8u0vbqirfpsKOljQKsBsvvFsKQrjQQtjQYQevs1Riv1SqjDlrk1Uu0VuP0WqjCmIOLreEMkfMgPKQRjQuBtvf5BKskJdLO4CIeyDKsY8eP4EKI9PQsheLilKuLhIsvtuKsUOiH2ikv4JOeLCsvvuRuLQxkQKIzkQe3uLIANIK(POsYqrPshfLOulvKGEkkMkPuxvLIyROur9vvksJvvf2lj)vfdwYHPAXQYJvyYeUmYMH0NvvgnrDAPwnkvKxJsz2O62QKDR0VbnCr54OevlhQNdmDHRdX2jv(UiA8KsCEI08fH9tzLKkTvmcpivQsWcjKGf3GfPGjlsb5wsTEkqXesZiftMpyZ)ifZ6xKIjxHeCpPIjZLYHUqPTIbarWdsXihrgqRU92VoKrEZb86wqFHW9OH7a7OXTG(ACRI5H084Nx1tXi8GuPkblKqcwCdwKcMSifKBwCJuGIXrcziwXW0xSxXi3cbTQNIrqGHIjxHeCpPvPq4hcz3VzhpKTILHvRKGfsiHD3UZEzF)iGwz3tBRUzNnYk2bNaYdSJgw1BqymswyvVwnGxppSQrTkjzf7eciSs0cR6Wkui2kDqUhnNoaixhTXuXWBqauARyeeQJWdL2QuLuPTIXhrdxfdB9GnfdT(JtcLEQqLQekTvm06poju6PyeeyG7SOHRIjfsGGCEiBvJAvgea6hNSk)fALoe(sy)XjROLUAcyvVwnGxppYtX4JOHRIbeKZdzvOs9gkTvm06poju6PyGzkgafkgFenCvm6CC7poPy05CesXGJ35HGIcSknwjHv)TkFRYXQhck6mWi05roU3VjsMv)TkhREiOOZhg6cqlOjsMv5PyeeyG7SOHRIjfsyiNBfO3poz1dbffyf5yUuRGHmHTkK91kTXiKv6roU3pR8vyLEyOlaTGum6C8z9lsXGJ3btyiNRcvQADL2kgA9hNek9umWmfdGcfJpIgUkgDoU9hNum6CocPygWRh8Kb7natbH2JoS6xnwjHv6B1dbfD(WqxaAbnrYS6Vv0s4pPw9RgRYnlS6Vv5BvownGRaPJ5aISXjKPduiatA9hNewLiHvpeu0jgY5NqMop4sGjMU8Ebw9RgRKKfwLNIrqGbUZIgUkMuCbiyYQKKvFuyfkcNBflD9qaYwXE21QpVxGv(kSYX0MEyfMWqoV3pRypezdRczYQCLqaS6HGIcSYt6svm6C8z9lsX4xpeG8zaxrhnCvHk1CR0wXqR)4KqPNIbMPyauOy8r0WvXOZXT)4KIrNZrifZaE9GNmyVbWQF1y1i7C5A5aYOvyvAB1dbfD(WqxaAbnrYSkTTkFREiOOtywgehiBhsNizwLRBv4CAJjlhPhSDeyp5Kw)XjHv5zvIewrOO0iAD0zaVEWtgS3ay1VASAKDUCTCaz0kumccmWDw0WvXWo6TbYw5HvxUwSkdca9JtwXE21QKDidrcRG6imkhMS3pREWfby1aE9GwLb7naSAfYYjaWkui2k9Iu0QKY9q2kNN0LcScidr4cREKv5wFRyp7Qy054Z6xKIbT3giFgWv0rdxvOs9NuARyO1FCsO0tXaZumycqHIXhrdxfJoh3(JtkgDo(S(fPyq7TbYNbCfD0WvXmWDq42vmdiKlGj35JIKeTNqMoKucmXKlKA1FRiuuAeTo6mGxp4jd2BaSknwLBfJGadCNfnCvmSepPlfyLhbDLfwfqRqaKv6fPOvEyvU13k2ZUSAfM(CSGtaGvquRyp7A1hTwL0bbPcvQAnL2kgA9hNek9umWmfdGcfJpIgUkgDoU9hNum6CocPyazeNFch)rby(4UGoOCemwQvPXkjS6VvyVfhshTX0fcWSxR(1kjyHvjsy1dbfD(4UGoOCemw6etxEVaR(1kjTsFRcNtBmzR58E)oGmmrtA9hNekgbbg4olA4QyUPDiB1fcp6mozv44pkaSAvi3aR0542FCYQgy1qMgSrcRcOvcA0cYQKYuityRaWlYk2NwaRaYqeUWQhzfq6oiHvj7q2k94UGSIDWrWyPkgDo(S(fPyECxqhuocgl9aKUdvOsLLrPTIHw)XjHspfZa3bHBxXacY5HmjMoNRy8r0WvXGr2JpIgUhEdcfdVbXz9lsXacY5HSkuPMcuARyO1FCsO0tX4JOHRIz4C(Xhrd3dVbHIH3G4S(fPygcGkuPkjluARyO1FCsO0tXmWDq42vm6CC7ponr7TbYNbCfD0WvX4JOHRIbJShFenCp8gekgEdIZ6xKIbT3giRcvQskPsBfdT(JtcLEkgFenCvmdNZp(iA4E4nium8geN1VifZdP5cvOsvsjuARyO1FCsO0tXmWDq42vm0s4pPtbH2JoS6xnwjzUTsFROLWFsNy6JwfJpIgUkghp8LobeJPnuHkvjVHsBfJpIgUkghp8LoziCaPyO1FCsO0tfQuLuRR0wX4JOHRIH3FYb4WoHi(UOnum06poju6PcvQsMBL2kgFenCvmp)7arpbUhSbum06poju6PcvOyYW0aE98qPTkvjvARy8r0WvX4zzCPNmydGRIHw)XjHspvOsvcL2kgFenCvmpyeCsCq5UusKS3Vta1sVkgA9hNek9uHk1BO0wX4JOHRIbeKZdzfdT(JtcLEQqLQwxPTIHw)XjHspfJpIgUkMlhZgjoOq8rqEiRyg4oiC7kgS3IdPJ2y6cby2Rv)ALe5wXKHPb865Xbqd4kakMCRcvQ5wPTIHw)XjHspfZa3bHBxXaGi8xVIzgciq40HWizrd3jT(JtcRsKWkaeH)6vm1b5E0C6aGCD0gtA9hNekgFenCvmOCcipWoAOcvQ)KsBfdT(JtcLEkgFenCvmyiNFcz68GlbumdCheUDfdMU8EbwLgRUHIjdtd41ZJdGgWvaumsOcvQAnL2kgA9hNek9um(iA4Qya8EqhFfhrpifZa3bHBxXGjumbK9hNumzyAaVEECa0aUcGIrcvOcfZdP5cL2QuLuPTIXhrdxfdGYanqXqR)4KqPNkuPkHsBfJpIgUkMpzii4spGa3SrkgA9hNek9uHk1BO0wXqR)4KqPNIzG7GWTRyWilHcXF0m6v6jGAPhNh3f0Kw)XjHIXhrdxfdqU1PcvQADL2kgA9hNek9umdCheUDftowbGi8xVIjHIIaAD0X3(Yp(yqCc7bepP1FCsyvIewPZXT)408XDbDq5iyS0dq6oum(iA4QyOHmS3VdMYW9LVcvOsn3kTvm06poju6Py8r0WvXaim2dsCEWLoGSMnsXiiWa3zrdxfdlLLXLAfJEmwfqRCo3QWXFuaSkzhYqKWk3kb9qqrTYbwLHBiUdPSAvgMqjmU3pRch)rbWkH0E)ScaHlHTYrdcBvitwLH7lhl1QWXFuOyg4oiC7kMCSsaJjGWypiX5bx6aYA2OJagZOhS17NkuP(tkTvm06poju6Py8r0WvXaim2dsCEWLoGSMnsXmWDq42vm5yLagtaHXEqIZdU0bK1SrhbmMrpyR3pfZq6GtNWXFuauPkPkuPQ1uARyO1FCsO0tX4JOHRIbqyShK48GlDaznBKIrqGbUZIgUkgwkc6klSkGwHaiRsktRvDyvYMZTA4zwnGxpOvzWEdGv(kSIztlRAGvcyYLvRGHmHt2aYk2ikZkum8YQHNL17Nvdzh)rafZa3bHBxXG2FYXbtxEVaRsJgRYTvjsy1ac5cyYDcim2dsCEWLoGSMnAE5A5mKD8hbSkTTAi74pcCqX(iA46CRsJgRyXuICBvIewnGxp4jd2BaMccThDyLgRgzNpVxR(Bvow9qqrNa2q48JVIZadbGhCjWejZQ)wrlH)KoJ(Iob8C5AXQFTssvOsLLrPTIHw)XjHspfJpIgUkMSgeq(biddfJGadCNfnCvm3eazf72GaYTIrggwLSdzRYvzzqCGSDi1Qg1k2dVEEyf7cdAhsTkjCtpScQJWdpZkAj8NuwTkPmTw1HvjBo3ksl(i4sTA4zwXE2LvRGyRsktRviGE)SILnspyZQ0c7jvmdCheUDfZdbfDcZYG4az7q6ejZQ)wLVv0s4pPtbH2JoS6xRY3kAj8N0jM(O1k9TsswyvEwLiHvd41dEYG9gGPGq7rhwLgnwjPv6B1dbfD(WqxaAbnrYSkrcRcNtBmz5i9GTJa7jN06pojSkpvOsnfO0wXqR)4KqPNIzG7GWTRyEiOOtywgehiBhsNizw93Q8T6HGIo)WeTa26fCs2d2imyIKzvIew9qqrNd4oiNtIZJJScc)qaGjsMvjsy1dbfDgq86c4jW93hHNizwLNIXhrdxftwdci)aKHHkuPkjluARy8r0WvXa6TbbHpGa3SrkgA9hNek9uHkvjLuPTIHw)XjHspfZa3bHBxXeoN2ykACi9e4EWgysR)4KWQ)wnGxp4jd2BaMccThDy1VASssR03Qhck68HHUa0cAIKPy8r0WvX8br(ivOcfZqauARsvsL2kgA9hNek9um(iA4QyECxqhuocglvXiiWa3zrdxfJECxqwXo4iySuRGRvsOVv0sxnbumdCheUDfdiJ48t44pkaw9RgRKWQ)wLJvpeu05J7c6GYrWyPtKmvOsvcL2kgA9hNek9um(iA4Qy05BdKvmccmWDw0WvXCta9(zflD9qaYw1aRCRKixRv9oWKdiwTcaTID23giB1WxREKva4ff9fbS6rwHaiHvoWk3kKO5Di1kqgX5wHSCcaScb07Nv3SdccBflbaoa0RvqSvPf5HmxQvmYUaMeOyg4oiC7kMCScJSeke)rZlhZ2bIEcz6C5GGWhhaCaO3jT(JtcR(BvowHrwcfI)OzV66pi2JE)oazxatkqaXKw)XjHv)TkhRab58qMetNZT6Vv6CC7pon9Rhcq(mGROJgUw93Q8TkhRWilHcXF0uqEiZLEaYUaMemP1FCsyvIew9qqrNcYdzU0dq2fWKGPaMCT6Vvd41dEYG9gaRsJgRKWQ8uHk1BO0wXqR)4KqPNIbMPyauOy8r0WvXOZXT)4KIrNJpRFrkgD(2a5ZLFgWv0rdxfZa3bHBxXGrwcfI)O5LJz7arpHmDUCqq4Jdaoa07Kw)XjHv)TkhRcNtBmVCmBK4GcXhb5H8Kw)XjHIrqGbUZIgUkMBAhYwDZoiiSvSeaaCaOxwTciDhwXo7BdKTkzhYw5wH2BdKjSvqSvS01dbiBLGYOv07NvW1k9Iu0QbeYfWKlRwbXw58KUuGvUvO92azcBvYoKT6MrtlfJoNJqkM8TkhRgqixatUZhfjjApHmDiPeyIjxi1Q)wPZXT)40eT3giFgWv0rdxRYZQejSkFRgqixatUZhfjjApHmDiPeyIjxi1Q)wPZXT)400VEia5ZaUIoA4AvEQqLQwxPTIHw)XjHspfdmtXaOqX4JOHRIrNJB)XjfJoNJqkgDoU9hNMO92a5ZaUIoA4Qyg4oiC7kgmYsOq8hnVCmBhi6jKPZLdccFCaWbGEN06pojS6VvHZPnMxoMnsCqH4JG8qEsR)4KqXOZXN1VifJoFBG85Ypd4k6OHRkuPMBL2kgA9hNek9umdCheUDfJoh3(JttD(2a5ZLFgWv0rdxR(B1LdccFCaWbGEpy6Y7fyLgRyHv)TsNJB)XP5J7c6GYrWyPhG0DOy8r0WvXOZ3giRcvQ)KsBfdT(JtcLEkMbUdc3UIjhREiOOtxGP159shmcqEIKPy8r0WvX4cmToVx6GraYQqLQwtPTIHw)XjHspfJGadCNfnCvmSdobKhyhnScfITIDrabcNSkfXizrdxRAuRwyyfiiNhYKWkFfwTWWQKDiBLECxqwXo4iySufZa3bHBxXKVvaic)1RyMHaceoDimsw0WDsR)4KWQejScar4VEftDqUhnNoaixhTXKw)XjHv5z1FRYXkqqopKjX05CR(Bv(wLJvpeu05J7c6GYrWyPtKmRsKWkqgX5NWXFuaMpUlOdkhbJLAvASscRYZQ)wLVv5y1dbfD6cmToVx6GraYtKmRsKWkAj8N0z0x0jGNlxlw9RvsyvEkMEdcJrYItJQyaqe(RxXuhK7rZPdaY1rBOy6nimgjlo91fjApifJKkgFenCvmOCcipWoAOy6nimgjloFC4Z5kgjvHkvwgL2kgA9hNek9umdCheUDftowbcY5HmjMoNB1FRY3kDoU9hNMO92a5ZaUIoA4AvIewfo(JIz0x0jGhrtwLgRK8gwLNIXhrdxfdk3)io3JgUQqLAkqPTIHw)XjHspfZa3bHBxXKJvGGCEitIPZ5w93Qb86bpzWEdGvPrJvsy1FRY3QCSAa1rRVXuhTHSuSvjsyLGEiOOtuU)rCUhnCNizwLNv)TkFRYXQW50gZlhZgjoOq8rqEipP1FCsyvIewLJvdiKlGj35LJzJehui(iipKNyYfsTkpfJpIgUkgbMCXJ7ccOcvQsYcL2kgA9hNek9umdCheUDfZLdccFCaWbGEpy6Y7fyLgRyHv)T6HGIofyYfpUliWuatUw93Q8T6HGIoXqo)eY05bxcmX0L3lWQ0OXQByvIewPZXT)40ehVdMWqo3Q8um(iA4QyWqo)eY05bxcOcvQskPsBfdT(JtcLEkgFenCvmxoMnsCqH4JG8qwXW7LodHIrYzUvmdPdoDch)rbqLQKkMbUdc3UIb7T4q6OnMUqaMizw93Q8TkC8hfZOVOtapIMSknwnGxp4jd2BaMccThDyvIewLJvGGCEitIjg(Hqw93Qb86bpzWEdWuqO9OdR(vJvJSZLRLdiJwHvPTvsAvEkgbbg4olA4Qy(zuRCHayLJjRqYy1kW2zKvHmzfCjRs2HSvCyscewPT2P10QBcGSkPmTwjK27NvOoiiSvHSVwXE21kbH2JoScITkzhYqKWkFLAf7z3PkuPkPekTvm06poju6Py8r0WvXC5y2iXbfIpcYdzfJGadCNfnCvm)mQvl0kxiawLS5CRenzvYoK71QqMSAjTewDdway1keaz1nJMwwbxREqaWQKDidrcR8vQvSNDNkMbUdc3UIb7T4q6OnMUqaM9A1VwDdwyvABf2BXH0rBmDHamfiypA4A1FRYXkqqopKjXed)qiR(B1aE9GNmyVbyki0E0Hv)QXQr25Y1YbKrRWQ02kjT6Vv5BvownG6O13yQJ2qwk2QejSAaHCbm5or5(hX5E0WDIPlVxGv)ALKSWQejSsqpeu0jk3)io3JgUtKmRYtfQuL8gkTvm06poju6PyGzkgafkgFenCvm6CC7poPy05CesXKJvyKLqH4pAE5y2oq0titNlhee(4aGda9oP1FCsyvIewnGqUaMCN68TbYtmD59cS6xRKKfwLiHvxoii8Xbaha69GPlVxGv)ALekgbbg4olA4QyyPiORSWQaAfq6oSkxtZ59(zftgMiRs2HSvSZ(2azRqHyRUzhee2kwcaCaOxfJohFw)IumS1CEVFhqgMOJoFBG8biDhQqLQKADL2kgA9hNek9um(iA4QyyR58E)oGmmrkgbbg4olA4QyUjaYQETsY0wcTTQrTsVifTQbwHKzLVcRsc30dRgEMvP4s4pPSAfeBLhwDdT13Q8LqB9TkzhYwLwKhYCPwXi7cysqEwbXwLuMwRUzhee2kwcaCaOxRAGviztfZa3bHBxXOZXT)408XDbDq5iyS0dq6oS6Vv6CC7ponzR58E)oGmmrhD(2a5dq6oS6Vv5yfiiNhYKyIHFiKv)TkFRe0dbfD(Oijr7jKPdjLatKmR(B1dbfDkWKlECxqGPaMCT6Vv0s4pPtbH2JoS6xRY3kAj8N0jM(O1QCDRKWk9TsYCBvEwLiHvGmIZpHJ)OamFCxqhuocgl1QFTkFRKWQ02Qhck6uqEiZLEaYUaMemrYSkpRsKWQlhee(4aGda9EW0L3lWQFTIfwLNkuPkzUvARyO1FCsO0tXmWDq42vm6CC7ponFCxqhuocgl9aKUdR(Bv(wrlH)KoJ(Iob8C5AXQFTscR(B1dbfDkWKlECxqGPaMCTkrcROLWFsTknAS6gSWQejScKrC(jC8hfaR(1kjSkpfJpIgUkMh3f0bJaKvHkvj)jL2kgA9hNek9um(iA4Qy05BdKvmccmWDw0WvX8ZOwHa69ZQFE11FqSh9(zfJSlGjfiGGvRqaKvleF5CR4WVEyvVw5crhnCTkGwnKPbB9(z1LZobXwX(0cmvmdCheUDfdgzjui(JM9QR)Gyp697aKDbmPabetA9hNew93QbuhT(gtD0gYsXw93QCSceKZdzsmDo3Q)wPZXT)400VEia5ZaUIoA4A1FRY3QCSAaHCbm5or5(hX5E0WDIjxi1Q)wLVv5yv4CAJPatU4XDbbM06pojSkrcRYXQbeYfWK7uGjx84UGatm5cPwLiHv5yLGEiOOtuU)rCUhnCNizwLNv5PcvQsQ1uARyO1FCsO0tXmWDq42vmyKLqH4pA2RU(dI9O3Vdq2fWKceqmP1FCsy1FRYXQbuhT(gtD0gYsXw93QCSceKZdzsmDo3Q)wLVvdiKlGj3jnKH9(DWugUV8vmX0L3lWQFT6NSkrcRYXQbeYfWK7eqzGgmXKlKAvIewnGqUaMCNacJ9GeNhCPdiRzJMOiC(btdzh)rNOViR(1kjyHv5Py8r0WvXOZ3giRcvQsYYO0wXqR)4KqPNIzG7GWTRyYXkqqopKjX05CR(BLoh3(Jtt)6HaKpd4k6OHRIXhrdxfdq2fWKxexOcvQsMcuARyO1FCsO0tXmWDq42vmpeu05JdHcociMyYhHvjsy1dcaw93k0(tooy6Y7fyvAS6gSWQejS6HGIoDbMwN3lDWia5jsMIXhrdxftgmA4QcvQsWcL2kgFenCvmpoekoOiyPkgA9hNek9uHkvjKuPTIXhrdxfZJWacZwVFkgA9hNek9uHkvjKqPTIXhrdxfdAJPhhcfkgA9hNek9uHkvjUHsBfJpIgUkgFheiWo)mCoxXqR)4KqPNkuPkHwxPTIHw)XjHspfJpIgUkMK9kadhFsktbiGlPyg4oiC7kgqgX5NWXFuaMpUlOdkhbJLA1VwjiqJjXjC8hfaRsKWkS3IdPJ2y6cby2Rv)A1pXcRsKWk0(tooy6Y7fyvASsRPyw)Iumj7vago(KuMcqaxsfQuLi3kTvm06poju6Py8r0WvXm8HmDGOhFWYrAmjobMCacMakMbUdc3UI5HGIo9blhPXK44AHMizwLiHvpiay1FRq7p54GPlVxGvPXkjYTIz9lsXm8HmDGOhFWYrAmjobMCacMaQqLQe)KsBfdT(JtcLEkgFenCvmbUx2OqsfJGadCNfnCvmPfH6i8WQbCfD0WfyfkeBfcWFCYQoOlWuXmWDq42vmc6HGIoFuKKO9eY0HKsGjsMvjsyvG7LnkMHKtzhCqa05HGIAvIew9GaGv)TcT)KJdMU8EbwLgnwjbluHkvj0AkTvm06poju6Pyg4oiC7kgb9qqrNpkss0Ecz6qsjWejZQejSkW9YgfZqIPSdoia68qqrTkrcREqaWQ)wH2FYXbtxEVaRsJgRKGfkgFenCvmbUx2OqcvOcfdiiNhYkTvPkPsBfdT(JtcLEkMbUdc3UIrNJB)XPjAVnq(mGROJgUkgFenCvmIgK5XqwfQuLqPTIXhrdxfJF9qaYkgA9hNek9uHk1BO0wXqR)4KqPNIXhrdxfZqM8SdqggkMbUdc3UIjCoTXmdtspW9eY0jj5SnP1FCsy1FRYXQWXFumBW5bbafZq6GtNWXFuauPkPkuHIbT3giR0wLQKkTvm06poju6Py8r0WvX8Oijr7jKPdjLakgbbg4olA4Qy0lsrRGRvdiKlGjxRcOvSruMvHmzf7XDyLGEiOOwHKXQvilNaaRczYQWXFuyvdSYFqKWQaALOjfZa3bHBxXeo(JIz0x0jGhrtw9Rv3qfQuLqPTIHw)XjHspfZa3bHBxX8qqrNaEpOJVIJOh0etxEVaRsJvO9NCCW0L3lWQ)wHjumbK9hNum(iA4Qya8EqhFfhrpivOs9gkTvm(iA4QyeniZJHSIHw)XjHspvOcvOy0ryqdxvQsWcjKGfsiblJIjPJ3E)akMBklLct9NtLLLwzLvAltw1xzqCyfkeBv6cc1r4r6wHjwosJjHva4fzLJeWlpiHvdzF)iW0UNl9swP11kRypC1r4GewL(aUcKoM)iDRcOvPpGRaPJ5pM06pojs3Q8Lul5nT729BklLct9NtLLLwzLvAltw1xzqCyfkeBv6zyAaVEEKUvyILJ0ysyfaErw5ib8Ydsy1q23pcmT75sVKv5wRSI9WvhHdsyv6aic)1Ry(J0TkGwLoaIWF9kM)ysR)4KiDRYxsTK30UNl9swLBTYk2dxDeoiHvPdGi8xVI5ps3QaAv6aic)1Ry(JjT(JtI0TYdRsXCvUyv(sQL8M2D7(nLLsHP(ZPYYsRSYkTLjR6RmioScfITk9HaKUvyILJ0ysyfaErw5ib8Ydsy1q23pcmT75sVKvsOvwXE4QJWbjSkDmYsOq8hn)r6wfqRshJSeke)rZFmP1FCsKUv5FdTK30UNl9swDdTYk2dxDeoiHvPJrwcfI)O5ps3QaAv6yKLqH4pA(JjT(JtI0TkFj1sEt7EU0lzLwxRSI9WvhHdsyv6yKLqH4pA(J0TkGwLogzjui(JM)ysR)4KiDRYxsTK30UNl9swP10kRypC1r4GewLoaIWF9kM)iDRcOvPdGi8xVI5pM06pojs3Q8Lql5nT75sVKvPaTYk2dxDeoiHvPhoN2y(J0TkGwLE4CAJ5pM06pojs3Q8Lul5nT75sVKvsEdTYk2dxDeoiHvPJrwcfI)O5ps3QaAv6yKLqH4pA(JjT(JtI0TkFj1sEt7EU0lzLK)Kwzf7HRochKWQ0dNtBm)r6wfqRspCoTX8htA9hNePBv(sQL8M29CPxYkj)jTYk2dxDeoiHvPJrwcfI)O5ps3QaAv6yKLqH4pA(JjT(JtI0TkFj1sEt7EU0lzLKAnTYk2dxDeoiHvPJrwcfI)O5ps3QaAv6yKLqH4pA(JjT(JtI0TkFj1sEt7EU0lzLe)Kwzf7HRochKWQ0dCVSrXuY5ps3QaAv6bUx2Oygso)r6wLVKAjVPDpx6LSscTMwzf7HRochKWQ0dCVSrXuI5ps3QaAv6bUx2Oygsm)r6wLVKAjVPD3UFtzPuyQ)CQSS0kRSsBzYQ(kdIdRqHyRs)H0Cr6wHjwosJjHva4fzLJeWlpiHvdzF)iW0UNl9swDdTYk2dxDeoiHvPJrwcfI)O5ps3QaAv6yKLqH4pA(JjT(JtI0TYdRsXCvUyv(sQL8M29CPxYkTUwzf7HRochKWQ0bqe(RxX8hPBvaTkDaeH)6vm)XKw)Xjr6wLVKAjVPD3U)ZxzqCqcR(jR8r0W1kEdcW0URyaz0qLQe)elumzyiAZjftktPv5kKG7jTkfc)qi7EktPv3SJhYwXYWQvsWcjKWUB3tzkTI9Y((raTYUNYuAvAB1n7SrwXo4eqEGD0WQEdcJrYcR61Qb865HvnQvjjRyNqaHvIwyvhwHcXwPdY9O50ba56OnM2D7EktPvPOwObsqcREeketwnGxppS6rF9cMwXsJbLfaRw4M2Yo(cfHBLpIgUaRGlx60U7JOHlyMHPb865HgplJl9KbBaCT7(iA4cMzyAaVEEOVMBFWi4K4GYDPKizVFNaQLET7(iA4cMzyAaVEEOVMBbb58q2U7JOHlyMHPb865H(AU9YXSrIdkeFeKhYSMHPb865Xbqd4kaAYnRnQgS3IdPJ2y6cby27VsKB7UpIgUGzgMgWRNh6R5wuobKhyhnyTr1aGi8xVIzgciq40HWizrd3ejaqe(RxXuhK7rZPdaY1rBy39r0WfmZW0aE98qFn3IHC(jKPZdUeG1mmnGxppoaAaxbqJeS2OAW0L3lin3WU7JOHlyMHPb865H(AUfW7bD8vCe9Gyndtd41ZJdGgWva0ibRnQgmHIjGS)4KD3UNYuAvkQfAGeKWkshHLAv0xKvHmzLpci2QgyLRZBU)400U7JOHlqdB9Gn7EkTkfsGGCEiBvJAvgea6hNSk)fALoe(sy)XjROLUAcyvVwnGxppYZU7JOHlqFn3ccY5HSDpLwLcjmKZTc07hNS6HGIcSICmxQvWqMWwfY(AL2yeYk9ih37Nv(kSspm0fGwq2DFenCb6R5wDoU9hNyD9lsdoEhmHHCoR6CocPbhVZdbffKgj(NFopeu0zGrOZJCCVFtKS)58qqrNpm0fGwqtKS8S7P0QuCbiyYQKKvFuyfkcNBflD9qaYwXE21QpVxGv(kSYX0MEyfMWqoV3pRypezdRczYQCLqaS6HGIcSYt6sT7(iA4c0xZT6CC7poX66xKg)6HaKpd4k6OHlR6CocPzaVEWtgS3amfeAp64xnsO)dbfD(WqxaAbnrY(tlH)K(RMCZI)5NZaUcKoMdiYgNqMoqHaKiXdbfDIHC(jKPZdUeyIPlVxWVAKKf5z3tPvSJEBGSvEy1LRfRYGaq)4KvSNDTkzhYqKWkOocJYHj79ZQhCrawnGxpOvzWEdaRwHSCcaScfITsVifTkPCpKTY5jDPaRaYqeUWQhzvU13k2ZU2DFenCb6R5wDoU9hNyD9lsdAVnq(mGROJgUSQZ5iKMb86bpzWEdWVAgzNlxlhqgTI0(HGIoFyOlaTGMizPD(peu0jmldIdKTdPtKSC9W50gtwospy7iWEYjT(JtI8sKGqrPr06OZaE9GNmyVb4xnJSZLRLdiJwHDpLwXs8KUuGvEe0vwyvaTcbqwPxKIw5Hv5wFRyp7YQvy6ZXcobawbrTI9SRvF0AvsheKD3hrdxG(AUvNJB)Xjwx)I0G2BdKpd4k6OHlRWmnycqbRnQMbeYfWK78rrsI2tithskbMyYfs)tOO0iAD0zaVEWtgS3aKMCB3tPv30oKT6cHhDgNSkC8hfawTkKBGv6CC7pozvdSAitd2iHvb0kbnAbzvszkKjSva4fzf7tlGvazicxy1JSciDhKWQKDiBLECxqwXo4iySu7UpIgUa91CRoh3(JtSU(fP5XDbDq5iyS0dq6oyvNZrinGmIZpHJ)OamFCxqhuocglnns8h7T4q6OnMUqaM9(ReSirIhck68XDbDq5iyS0jMU8Eb)kP(HZPnMS1CEVFhqgMOjT(Jtc7UpIgUa91Clgzp(iA4E4niyD9lsdiiNhYS2OAab58qMetNZT7(iA4c0xZTdNZp(iA4E4niyD9lsZqaS7(iA4c0xZTyK94JOH7H3GG11VinO92azwBun6CC7ponr7TbYNbCfD0W1U7JOHlqFn3oCo)4JOH7H3GG11VinpKMlS7(iA4c0xZToE4lDcigtBWAJQHwc)jDki0E0XVAKm36tlH)KoX0hT2DFenCb6R5whp8LoziCaz39r0WfOVMB59NCaoStiIVlAd7UpIgUa91C7Z)oq0tG7bBa7UDpLP0k9qAUGWa7UpIgUG5dP5cnakd0a7UpIgUG5dP5c91C7NmeeCPhqGB2i7UpIgUG5dP5c91ClqU1XAJQbJSeke)rZOxPNaQLECECxq2DFenCbZhsZf6R5wAid797GPmCF5RG1gvtoaic)1RysOOiGwhD8TV8JpgeNWEaXjsOZXT)408XDbDq5iyS0dq6oS7P0kwklJl1kg9ySkGw5CUvHJ)OayvYoKHiHvUvc6HGIALdSkd3qChsz1QmmHsyCVFwfo(JcGvcP9(zfacxcBLJge2QqMSkd3xowQvHJ)OWU7JOHly(qAUqFn3cim2dsCEWLoGSMnI1gvtocymbeg7bjop4shqwZgDeWyg9GTE)S7(iA4cMpKMl0xZTacJ9GeNhCPdiRzJyDiDWPt44pkaAKK1gvtocymbeg7bjop4shqwZgDeWyg9GTE)S7P0kwkc6klSkGwHaiRsktRvDyvYMZTA4zwnGxpOvzWEdGv(kSIztlRAGvcyYLvRGHmHt2aYk2ikZkum8YQHNL17Nvdzh)ra7UpIgUG5dP5c91ClGWypiX5bx6aYA2iwBunO9NCCW0L3linAYDIediKlGj3jGWypiX5bx6aYA2O5LRLZq2XFeiThYo(JahuSpIgUopnAyXuICNiXaE9GNmyVbyki0E0HMr25Z79Fopeu0jGneo)4R4mWqa4bxcmrY(tlH)KoJ(Iob8C5A5xjT7P0QBcGSIDBqa5wXiddRs2HSv5QSmioq2oKAvJAf7HxppSIDHbTdPwLeUPhwb1r4HNzfTe(tkRwLuMwR6WQKnNBfPfFeCPwn8mRyp7YQvqSvjLP1keqVFwXYgPhSzvAH9K2DFenCbZhsZf6R52Sgeq(biddwBunpeu0jmldIdKTdPtKS)5tlH)KofeAp6438PLWFsNy6Jw9LKf5LiXaE9GNmyVbyki0E0rA0iP(peu05ddDbOf0ejlrIW50gtwospy7iWEYjT(JtI8S7(iA4cMpKMl0xZTzniG8dqggS2OAEiOOtywgehiBhsNiz)Z)HGIo)WeTa26fCs2d2imyIKLiXdbfDoG7GCojopoYki8dbaMizjs8qqrNbeVUaEcC)9r4jswE2DFenCbZhsZf6R5wqVnii8be4MnYU7JOHly(qAUqFn3(br(iwBunHZPnMIghspbUhSbM06poj(pGxp4jd2BaMccThD8Rgj1)HGIoFyOlaTGMiz2D7EktPvShc5cyYfy3tPv6XDbzf7GJGXsTcUwjH(wrlD1eWU7JOHlyoeanpUlOdkhbJLYAJQbKrC(jC8hfGF1iX)CEiOOZh3f0bLJGXsNiz29uA1nb07NvS01dbiBvdSYTsICTw17atoGy1ka0k2zFBGSvdFT6rwbGxu0xeWQhzfcGew5aRCRqIM3HuRazeNBfYYjaWkeqVFwDZoiiSvSea4aqVwbXwLwKhYCPwXi7cysGD3hrdxWCia6R5wD(2azwBun5GrwcfI)O5LJz7arpHmDUCqq4Jdaoa07)CWilHcXF0SxD9he7rVFhGSlGjfiG4FoGGCEitIPZ5)1542FCA6xpeG8zaxrhnC)NFoyKLqH4pAkipK5spazxatcsK4HGIofKhYCPhGSlGjbtbm5(FaVEWtgS3aKgnsKNDpLwDt7q2QB2bbHTILaaGda9YQvaP7Wk2zFBGSvj7q2k3k0EBGmHTcITILUEiazReugTIE)ScUwPxKIwnGqUaMCz1ki2kNN0LcSYTcT3gityRs2HSv3mAAz39r0WfmhcG(AUvNJB)Xjwx)I0OZ3giFU8ZaUIoA4YAJQbJSeke)rZlhZ2bIEcz6C5GGWhhaCaO3)5eoN2yE5y2iXbfIpcYd5jT(Jtcw15Cest(5mGqUaMCNpkss0Ecz6qsjWetUq6FDoU9hNMO92a5ZaUIoA4MxIe5pGqUaMCNpkss0Ecz6qsjWetUq6FDoU9hNM(1dbiFgWv0rd38S7(iA4cMdbqFn3QZXT)4eRRFrA05BdKpx(zaxrhnCzTr1GrwcfI)O5LJz7arpHmDUCqq4Jdaoa07)W50gZlhZgjoOq8rqEipP1FCsWQoNJqA0542FCAI2BdKpd4k6OHRD3hrdxWCia6R5wD(2azwBun6CC7pon15BdKpx(zaxrhnC)F5GGWhhaCaO3dMU8EbAyXFDoU9hNMpUlOdkhbJLEas3HD3hrdxWCia6R5wxGP159shmcqM1gvtopeu0PlW068EPdgbiprYS7P0k2bNaYdSJgwHcXwXUiGaHtwLIyKSOHRvnQvlmSceKZdzsyLVcRwyyvYoKTspUliRyhCemwQD3hrdxWCia6R5wuobKhyhnyTr1KpaIWF9kMziGaHthcJKfnCtKaar4VEftDqUhnNoaixhTrE)ZbeKZdzsmDo)F(58qqrNpUlOdkhbJLorYsKaKrC(jC8hfG5J7c6GYrWyPPrI8(NFopeu0PlW068EPdgbiprYsKGwc)jDg9fDc45Y1YVsKhR9gegJKfN(6IeThKgjzT3GWyKS48XHpNRrsw7nimgjlonQgaeH)6vm1b5E0C6aGCD0g2DFenCbZHaOVMBr5(hX5E0WL1gvtoGGCEitIPZ5)ZxNJB)XPjAVnq(mGROJgUjseo(JIz0x0jGhrtPrYBKND3hrdxWCia6R5wbMCXJ7ccWAJQjhqqopKjX058)d41dEYG9gG0OrI)5NZaQJwFJPoAdzP4eje0dbfDIY9pIZ9OH7ejlV)5Nt4CAJ5LJzJehui(iipKtKiNbeYfWK78YXSrIdkeFeKhYtm5cP5z39r0WfmhcG(AUfd58titNhCjaRnQMlhee(4aGda9EW0L3lqdl()qqrNcm5Ih3feykGj3)5)qqrNyiNFcz68GlbMy6Y7fKgn3ircDoU9hNM44DWegY55z3tPv)mQvUqaSYXKvizSAfy7mYQqMScUKvj7q2komjbcR0w70AA1nbqwLuMwRes79Zkuhee2Qq2xRyp7ALGq7rhwbXwLSdzisyLVsTI9S70U7JOHlyoea91C7LJzJehui(iipKzL3lDgcnsoZnRdPdoDch)rbqJKS2OAWEloKoAJPleGjs2)8dh)rXm6l6eWJOP0mGxp4jd2BaMccThDKiroGGCEitIjg(Hq)hWRh8Kb7natbH2Jo(vZi7C5A5aYOvK2sMNDpLw9ZOwTqRCHayvYMZTs0Kvj7qUxRczYQL0sy1nybGvRqaKv3mAAzfCT6bbaRs2HmejSYxPwXE2DA39r0WfmhcG(AU9YXSrIdkeFeKhYS2OAWEloKoAJPleGzV)EdwK2yVfhshTX0fcWuGG9OH7)Cab58qMetm8dH(pGxp4jd2BaMccThD8RMr25Y1YbKrRiTL8F(5mG6O13yQJ2qwkorIbeYfWK7eL7FeN7rd3jMU8Eb)kjlsKqqpeu0jk3)io3JgUtKS8S7P0kwkc6klSkGwbKUdRY10CEVFwXKHjYQKDiBf7SVnq2kui2QB2bbHTILaaha61U7JOHlyoea91CRoh3(JtSU(fPHTMZ797aYWeD05BdKpaP7GvDohH0Kdgzjui(JMxoMTde9eY05YbbHpoa4aqVjsmGqUaMCN68TbYtmD59c(vswKiXLdccFCaWbGEpy6Y7f8Re29uA1nbqw1RvsM2sOTvnQv6fPOvnWkKmR8vyvs4MEy1WZSkfxc)jLvRGyR8WQBOT(wLVeARVvj7q2Q0I8qMl1kgzxatcYZki2QKY0A1n7GGWwXsaGda9AvdScjBA39r0WfmhcG(AULTMZ797aYWeXAJQrNJB)XP5J7c6GYrWyPhG0D8xNJB)XPjBnN373bKHj6OZ3giFas3X)Cab58qMetm8dH(NVGEiOOZhfjjApHmDiPeyIK9)HGIofyYfpUliWuatU)PLWFsNccThD8B(0s4pPtm9rBUUe6lzUZlrcqgX5NWXFuaMpUlOdkhbJL(B(sK2peu0PG8qMl9aKDbmjyIKLxIexoii8Xbaha69GPlVxWVSip7UpIgUG5qa0xZTpUlOdgbiZAJQrNJB)XP5J7c6GYrWyPhG0D8pFAj8N0z0x0jGNlxl)kX)hck6uGjx84UGatbm5MibTe(tAA0CdwKibiJ48t44pka)krE29uA1pJAfcO3pR(5vx)bXE07NvmYUaMuGacwTcbqwTq8LZTId)6Hv9ALleD0W1QaA1qMgS17Nvxo7eeBf7tlW0U7JOHlyoea91CRoFBGmRnQgmYsOq8hn7vx)bXE073bi7cysbci(pG6O13yQJ2qwk(FoGGCEitIPZ5)1542FCA6xpeG8zaxrhnC)NFodiKlGj3jk3)io3JgUtm5cP)ZpNW50gtbMCXJ7ccKirodiKlGj3PatU4XDbbMyYfstKihb9qqrNOC)J4CpA4orYYlp7UpIgUG5qa0xZT68TbYS2OAWilHcXF0SxD9he7rVFhGSlGjfiG4FodOoA9nM6OnKLI)NdiiNhYKy6C()8hqixatUtAid797GPmCF5RyIPlVxWV)uIe5mGqUaMCNakd0GjMCH0ejgqixatUtaHXEqIZdU0bK1Srtueo)GPHSJ)Ot0x0VsWI8S7(iA4cMdbqFn3cKDbm5fXfS2OAYbeKZdzsmDo)Voh3(Jtt)6HaKpd4k6OHRD3hrdxWCia6R52my0WL1gvZdbfD(4qOGJaIjM8rKiXdca)r7p54GPlVxqAUblsK4HGIoDbMwN3lDWia5jsMD3hrdxWCia6R52hhcfhueSu7UpIgUG5qa0xZTpcdimB9(z39r0WfmhcG(AUfTX0JdHc7UpIgUG5qa0xZT(oiqGD(z4CUD3hrdxWCia6R5weaD6GUyD9lstYEfGHJpjLPaeWLyTr1aYio)eo(JcW8XDbDq5iyS0FfeOXK4eo(JcqIeyVfhshTX0fcWS3F)jwKibA)jhhmD59csJwZU7JOHlyoea91ClcGoDqxSU(fPz4dz6arp(GLJ0ysCcm5aembyTr18qqrN(GLJ0ysCCTqtKSejEqa4pA)jhhmD59csJe52UNsRslc1r4Hvd4k6OHlWkui2keG)4KvDqxGPD3hrdxWCia6R52a3lBuijRnQgb9qqrNpkss0Ecz6qsjWejlrIa3lBumLCk7GdcGopeu0ejEqa4pA)jhhmD59csJgjyHD3hrdxWCia6R52a3lBuibRnQgb9qqrNpkss0Ecz6qsjWejlrIa3lBumLyk7GdcGopeu0ejEqa4pA)jhhmD59csJgjyHD3UNYuAf7O3gityGDpLwPxKIwbxRgqixatUwfqRyJOmRczYk2J7Wkb9qqrTcjJvRqwobawfYKvHJ)OWQgyL)GiHvb0krt2DFenCbt0EBGSMhfjjApHmDiPeG1gvt44pkMrFrNaEen97nS7(iA4cMO92az91ClG3d64R4i6bXAJQ5HGIob8EqhFfhrpOjMU8EbPbT)KJdMU8Eb)XekMaY(Jt2DFenCbt0EBGS(AUv0GmpgY2D7EktPvmb58q2U7JOHlyccY5HSgrdY8yiZAJQrNJB)XPjAVnq(mGROJgU2DFenCbtqqopK1xZT(1dbiB39r0Wfmbb58qwFn3oKjp7aKHbRdPdoDch)rbqJKS2OAcNtBmZWK0dCpHmDssoBtA9hNe)ZjC8hfZgCEqaqfQqPa]] )
    

end
