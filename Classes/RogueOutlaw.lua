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


    spec:RegisterPack( "Outlaw", 20220228, [[d800ubqirQEKirxsuvfTjvv9jrkJsuLtjQ0QevvPxrQQzHsClrfzxk6xQu1Wqj1XiIwgkLNjQktJiuDnvQyBQQqFturzCKQuohrO06ivjZtuH7rk2NQkDqusSqsPEirWefj4IIeAJQQiFeLKItQQIALQuEPOQkmtrvLBIss2PiPFkQOAOeHCuuskTusvQEkkMkPKRQQcSvusQ(QQkOXQsL2lj)vfdwYHPAXQYJvyYeUmYMH0NvvgnrDAPwnrO41OunBuDBvYUv63GgUOCCrvvTCOEoW0fUoeBNu57IW4jvX5jsZxeTFkRKuPLIr4bPsLnwZgBSMn20Bt2Yx(0B3rsftinJumz(GD)JumRFrkMCosW9ekMmxkh6cLwkgaebpifJCeza96(7)6qg5nhWR7b9fc3JgUdSJg3d6RX9kMhsZJFEvpfJWdsLkBSMn2ynBSP3MSLV8P3K4sSkghjKHyfdtFjbfJCle0QEkgbbgkMCosW9ewP3HFiKD7NOhgXXsTIn9glwXgRzJn7MDtcY((ra9YULtwXQC2jR(jobKhyhnSQ3GWyKSWQETAaVEEyvJAvcYkjgeqyLOfw1HvOqSv6GCpAoDaqUoAJPIH3GaO0sXiiuhHhkTuPkPslfJpIgUkg27b7kgA9hNekTvHkv2uAPyO1FCsO0wXiiWa3zrdxfJENab58q2Qg1Qmia0pozvEl0kDi8LW(JtwrlD1eWQETAaVEEKRIXhrdxfdiiNhYQqLA(uAPyO1FCsO0wXaZumakum(iA4Qy0542FCsXOZ5iKIbhVZdbffyvoSInR(BvEwLUvpeu0zGrOZJCCVFtKmR(Bv6w9qqrNpm0fGwqtKmRYvXiiWa3zrdxfJENWqo3kqVFCYQhckkWkYXCPwbdzcBvi7RvAHriR0MCCVFw5RWkTXqxaAbPy054Z6xKIbhVdMWqoxfQuL4kTum06pojuARyGzkgafkgFenCvm6CC7poPy05CesXmGxp4jd2BaMccThDy1VASInR03Qhck68HHUa0cAIKz1FROLWFsT6xnwDhwB1FRYZQ0TAaxbshZbezJtithOqaM06pojSkzsREiOOtmKZpHmDEWLatmD59cS6xnwjjRTkxfJGadCNfnCvmP4cqWKvjiR(OWkueo3kw56HaKTscsKvFEVaR8vyLJPnTWkmHHCEVFwjbiYgwfYKv5CHay1dbffyLNWLQy054Z6xKIXVEia5ZaUIoA4QcvQ3rPLIHw)XjHsBfdmtXaOqX4JOHRIrNJB)XjfJoNJqkMb86bpzWEdGv)QXQr25Y1ZbKrRWQCYQhck68HHUa0cAIKzvozvEw9qqrNWSmioq2oKorYSk)1QW50gZ8pspy)iWEIjT(JtcRY1QKjTIqrPr06OZaE9GNmyVbWQF1y1i7C565aYOvOyeeyG7SOHRI5N6TbYw5HvxUESkdca9JtwjbjYQeDidrcRG6imkhMO3pREWfby1aE9GwLb7naSyfYYjaWkui2kTJu0QeY9q2kNNWLcScidr4cREKv3rFRKGePy054Z6xKIbT3giFgWv0rdxvOs9hvAPyO1FCsO0wXaZumycqHIXhrdxfJoh3(JtkgDo(S(fPyq7TbYNbCfD0WvXmWDq42vmdiKlGj25JIeeTNqMoKucmXKlKA1FRiuuAeTo6mGxp4jd2BaSkhwDhfJGadCNfnCvmScpHlfyLhbDLfwfqRqaKvAhPOvEy1D03kjirSyfM(CSGtaGvquRKGez1hTwLWbbPcvQ5mLwkgA9hNekTvmWmfdGcfJpIgUkgDoU9hNum6CocPyazeNFch)rby(4UGoOCemwQv5Wk2S6VvyVfhshTX0fcWSxR(1k2yTvjtA1dbfD(4UGoOCemw6etxEVaR(1kjTsFRcNtBmzV58E)oGmmrtA9hNekgbbg4olA4Qy(HDiB1fcp6mozv44pkaSyvi3aR0542FCYQgy1qMgStcRcOvcA0cYQeYuityRaWlYkjKcaRaYqeUWQhzfq6oiHvj6q2kT5UGS6N4iySufJohFw)IumpUlOdkhbJLEas3HkuPQ3uAPyO1FCsO0wXmWDq42vmGGCEitIPZ5kgFenCvmyK94JOH7H3GqXWBqCw)IumGGCEiRcvQsSkTum06pojuARy8r0WvXmCo)4JOH7H3GqXWBqCw)IumdbqfQuLK1kTum06pojuARyg4oiC7kgDoU9hNMO92a5ZaUIoA4Qy8r0WvXGr2JpIgUhEdcfdVbXz9lsXG2BdKvHkvjLuPLIHw)XjHsBfJpIgUkMHZ5hFenCp8gekgEdIZ6xKI5H0CHkuPkjBkTum06pojuARyg4oiC7kgAj8N0PGq7rhw9RgRK8owPVv0s4pPtm9rRIXhrdxfJJh(sNaIX0gQqLQK5tPLIXhrdxfJJh(sNmeoGum06pojuARcvQskXvAPy8r0WvXW7p5aCKyqeFx0gkgA9hNekTvHkvjVJslfJpIgUkMN)DGONa3d2bkgA9hNekTvHkumzyAaVEEO0sLQKkTum(iA4Qy8SmU0tgSbWvXqR)4KqPTkuPYMslfJpIgUkMhmcojoOCxkjs073jG6PxfdT(JtcL2QqLA(uAPy8r0WvXacY5HSIHw)XjHsBvOsvIR0sXqR)4KqPTIXhrdxfZLJzNehui(iipKvmdCheUDfd2BXH0rBmDHam71QFTIT7OyYW0aE984aObCfafZDuHk17O0sXqR)4KqPTIzG7GWTRyaqe(RxXmdbeiC6qyKSOH7Kw)XjHvjtAfaIWF9kM6GCpAoDaqUoAJjT(JtcfJpIgUkguobKhyhnuHk1FuPLIHw)XjHsBfJpIgUkgmKZpHmDEWLakMbUdc3UIbtxEVaRYHv5tXKHPb865Xbqd4kakg2uHk1CMslfdT(JtcL2kgFenCvmaEpOJVIJOhKIzG7GWTRyWekMaY(JtkMmmnGxppoaAaxbqXWMkuHI5H0CHslvQsQ0sX4JOHRIbqzGgOyO1FCsO0wfQuztPLIXhrdxfZNmeeCPhqGB2jfdT(JtcL2QqLA(uAPyO1FCsO0wXmWDq42vmyKLqH4pAg9k9eq90JZJ7cAsR)4KqX4JOHRIbi36uHkvjUslfdT(JtcL2kMbUdc3UIjDRaqe(RxXKqrraTo64BF5hFmioH9aIN06pojSkzsR0542FCA(4UGoOCemw6biDhkgFenCvm0qg273btz4(YxHkuPEhLwkgA9hNekTvm(iA4Qyaeg7bjop4shqwZoPyeeyG7SOHRIHvYY4sTIrBgRcOvoNBv44pkawLOdzisyLBLGEiOOw5aRYWne3HuwSkdtOeg37NvHJ)OayLqAVFwbGWLWw5ObHTkKjRYW9LJLAv44pkumdCheUDft6wjGXeqyShK48GlDazn70raJz0d279tfQu)rLwkgA9hNekTvm(iA4Qyaeg7bjop4shqwZoPyg4oiC7kM0TsaJjGWypiX5bx6aYA2PJagZOhS37NIziDWPt44pkaQuLufQuZzkTum06pojuARy8r0WvXaim2dsCEWLoGSMDsXiiWa3zrdxfdRebDLfwfqRqaKvjKP1QoSkrZ5wn8mRgWRh0QmyVbWkFfwXSPGvnWkbmXYIvWqMWjAazf7eLzfkgEz1WZY69ZQHSJ)iGIzG7GWTRyq7p54GPlVxGv5qJv3XQKjTAaHCbmXobeg7bjop4shqwZonVC9CgYo(JawLtwnKD8hboOyFenCDUv5qJvSEY2DSkzsRgWRh8Kb7natbH2JoSsJvJSZN3Rv)TkDREiOOta7iC(XxXzGHaWdUeyIKz1FROLWFsNrFrNaEUC9y1VwjPkuPQ3uAPyO1FCsO0wX4JOHRIjRbbKFaYWqXiiWa3zrdxfZpaqwjrniGCRyKHHvj6q2QCEwgehiBhsTQrTscWRNhwjrWG2HuRsa30cRG6i8WZSIwc)jLfRsitRvDyvIMZTI0JpcUuRgEMvsqIyXki2QeY0AfcO3pRy1I0d2TkfWEcfZa3bHBxX8qqrNWSmioq2oKorYS6Vv5zfTe(t6uqO9OdR(1Q8SIwc)jDIPpATsFRKK1wLRvjtA1aE9GNmyVbyki0E0Hv5qJvsAL(w9qqrNpm0fGwqtKmRsM0QW50gZ8pspy)iWEIjT(JtcRYvfQuLyvAPyO1FCsO0wXmWDq42vmpeu0jmldIdKTdPtKmR(BvEw9qqrNFyIwa79coj6b7egmrYSkzsREiOOZbChKZjX5XrwbHFiaWejZQKjT6HGIodiEDb8e4(7JWtKmRYvX4JOHRIjRbbKFaYWqfQuLK1kTum(iA4Qya92GGWhqGB2jfdT(JtcL2QqLQKsQ0sXqR)4KqPTIzG7GWTRycNtBmfnoKEcCpyhmP1FCsy1FRgWRh8Kb7natbH2JoS6xnwjPv6B1dbfD(WqxaAbnrYum(iA4Qy(GiFKkuHIziakTuPkPslfdT(JtcL2kgFenCvmpUlOdkhbJLQyeeyG7SOHRIrBUliR(jocgl1k4AfB6BfT0vtafZa3bHBxXaYio)eo(JcGv)QXk2S6VvPB1dbfD(4UGoOCemw6ejtfQuztPLIHw)XjHsBfJpIgUkgD(2azfJGadCNfnCvm)aqVFwXkxpeGSvnWk3k2YFAvVdm5aIfRaqRy19TbYwn81QhzfaErrFraREKviasyLdSYTcjAEhsTcKrCUvilNaaRqa9(zfRYbbHTIvaaha61ki2QuG8qMl1kgzxataumdCheUDft6wHrwcfI)O5LJz)arpHmDUCqq4Jdaoa07Kw)XjHv)TkDRWilHcXF0SxD9he7rVFhGSlGjeiGysR)4KWQ)wLUvGGCEitIPZ5w93kDoU9hNM(1dbiFgWv0rdxR(BvEwLUvyKLqH4pAkipK5spazxataM06pojSkzsREiOOtb5Hmx6bi7cycWuatSw93Qb86bpzWEdGv5qJvSzvUQqLA(uAPyO1FCsO0wXaZumakum(iA4Qy0542FCsXOZXN1VifJoFBG85Ypd4k6OHRIzG7GWTRyWilHcXF08YXSFGONqMoxoii8Xbaha6DsR)4KWQ)wLUvHZPnMxoMDsCqH4JG8qEsR)4KqXiiWa3zrdxfZpSdzRyvoiiSvScaaCaOxwSciDhwXQ7BdKTkrhYw5wH2BdKjSvqSvSY1dbiBLGYOv07NvW1kTJu0QbeYfWellwbXw58eUuGvUvO92azcBvIoKTIvHMckgDohHum5zv6wnGqUaMyNpksq0Ecz6qsjWetUqQv)TsNJB)XPjAVnq(mGROJgUwLRvjtAvEwnGqUaMyNpksq0Ecz6qsjWetUqQv)TsNJB)XPPF9qaYNbCfD0W1QCvHkvjUslfdT(JtcL2kgyMIbqHIXhrdxfJoh3(JtkgDohHum6CC7ponr7TbYNbCfD0WvXmWDq42vmyKLqH4pAE5y2pq0titNlhee(4aGda9oP1FCsy1FRcNtBmVCm7K4GcXhb5H8Kw)XjHIrNJpRFrkgD(2a5ZLFgWv0rdxvOs9okTum06pojuARyg4oiC7kgDoU9hNM68TbYNl)mGROJgUw93Qlhee(4aGda9EW0L3lWknwXAR(BLoh3(JtZh3f0bLJGXspaP7qX4JOHRIrNVnqwfQu)rLwkgA9hNekTvmdCheUDft6w9qqrNUatRZ7LoyeG8ejtX4JOHRIXfyADEV0bJaKvHk1CMslfdT(JtcL2kgbbg4olA4Qy(jobKhyhnScfITsIqabcNSkfXizrdxRAuRwyyfiiNhYKWkFfwTWWQeDiBL2Cxqw9tCemwQIzG7GWTRyYZkaeH)6vmZqabcNoegjlA4oP1FCsyvYKwbGi8xVIPoi3JMthaKRJ2ysR)4KWQCT6VvPBfiiNhYKy6CUv)TkpRs3Qhck68XDbDq5iyS0jsMvjtAfiJ48t44pkaZh3f0bLJGXsTkhwXMv5A1FRYZQ0T6HGIoDbMwN3lDWia5jsMvjtAfTe(t6m6l6eWZLRhR(1k2SkxftVbHXizXPrvmaic)1RyQdY9O50ba56Onum9gegJKfN(6IeThKIrsfJpIgUkguobKhyhnum9gegJKfNpo85CfJKQqLQEtPLIHw)XjHsBfZa3bHBxXKUvGGCEitIPZ5w93Q8SsNJB)XPjAVnq(mGROJgUwLmPvHJ)Oyg9fDc4r0Kv5WkjZNv5Qy8r0WvXGY9pIZ9OHRkuPkXQ0sXqR)4KqPTIzG7GWTRys3kqqopKjX05CR(B1aE9GNmyVbWQCOXk2S6Vv5zv6wnG6O13yQJ2qwk2QKjTsqpeu0jk3)io3JgUtKmRY1Q)wLNvPBv4CAJ5LJzNehui(iipKN06pojSkzsRs3QbeYfWe78YXStIdkeFeKhYtm5cPwLRIXhrdxfJatU4XDbbuHkvjzTslfdT(JtcL2kMbUdc3UI5YbbHpoa4aqVhmD59cSsJvS2Q)w9qqrNcm5Ih3feykGjwR(BvEw9qqrNyiNFcz68GlbMy6Y7fyvo0yv(SkzsR0542FCAIJ3btyiNBvUkgFenCvmyiNFcz68GlbuHkvjLuPLIHw)XjHsBfJpIgUkMlhZojoOq8rqEiRy49sNHqXi58okMH0bNoHJ)OaOsvsfZa3bHBxXG9wCiD0gtxiatKmR(BvEwfo(JIz0x0jGhrtwLdRgWRh8Kb7natbH2JoSkzsRs3kqqopKjXed)qiR(B1aE9GNmyVbyki0E0Hv)QXQr25Y1ZbKrRWQCYkjTkxfJGadCNfnCvm)mQvUqaSYXKvizSyfy7mYQqMScUKvj6q2kombbcR0sRuyA1paqwLqMwRes79Zkuhee2Qq2xRKGezLGq7rhwbXwLOdzisyLVsTscs0ufQuLKnLwkgA9hNekTvm(iA4QyUCm7K4GcXhb5HSIrqGbUZIgUkMFg1QfALleaRs0CUvIMSkrhY9AvitwTKEcRYhRbSyfcGSIvHMcwbxREqaWQeDidrcR8vQvsqIMkMbUdc3UIb7T4q6OnMUqaM9A1VwLpwBvozf2BXH0rBmDHamfiypA4A1FRs3kqqopKjXed)qiR(B1aE9GNmyVbyki0E0Hv)QXQr25Y1ZbKrRWQCYkjT6Vv5zv6wnG6O13yQJ2qwk2QKjTAaHCbmXor5(hX5E0WDIPlVxGv)ALKS2QKjTsqpeu0jk3)io3JgUtKmRYvfQuLmFkTum06pojuARyGzkgafkgFenCvm6CC7poPy05CesXKUvyKLqH4pAE5y2pq0titNlhee(4aGda9oP1FCsyvYKwnGqUaMyN68TbYtmD59cS6xRKK1wLmPvxoii8Xbaha69GPlVxGv)AfBkgbbg4olA4QyyLiORSWQaAfq6oSk)rZ59(zftgMiRs0HSvS6(2azRqHyRyvoiiSvSca4aqVkgDo(S(fPyyV58E)oGmmrhD(2a5dq6ouHkvjL4kTum06pojuARy8r0WvXWEZ59(DazyIumccmWDw0WvX8daKv9ALK5eBAzvJAL2rkAvdScjZkFfwLaUPfwn8mRsXLWFszXki2kpSkFAPVv5XMw6BvIoKTkfipK5sTIr2fWeGCTcITkHmTwXQCqqyRyfaWbGETQbwHKnvmdCheUDfJoh3(JtZh3f0bLJGXspaP7WQ)wPZXT)40K9MZ797aYWeD05BdKpaP7WQ)wLUvGGCEitIjg(Hqw93Q8Ssqpeu05JIeeTNqMoKucmrYS6Vvpeu0PatU4XDbbMcyI1Q)wrlH)KofeAp6WQFTkpROLWFsNy6JwRYFTInR03kjVJv5AvYKwbYio)eo(JcW8XDbDq5iySuR(1Q8SInRYjREiOOtb5Hmx6bi7cycWejZQCTkzsRUCqq4Jdaoa07btxEVaR(1kwBvUQqLQK3rPLIHw)XjHsBfZa3bHBxXOZXT)408XDbDq5iyS0dq6oS6Vv5zfTe(t6m6l6eWZLRhR(1k2S6Vvpeu0PatU4XDbbMcyI1QKjTIwc)j1QCOXQ8XARsM0kqgX5NWXFuaS6xRyZQCvm(iA4QyECxqhmcqwfQuL8hvAPyO1FCsO0wX4JOHRIrNVnqwXiiWa3zrdxfZpJAfcO3pR(5vx)bXE07NvmYUaMqGacwScbqwTq8LZTId)6Hv9ALleD0W1QaA1qMgS37NvxUedeBLesbWuXmWDq42vmyKLqH4pA2RU(dI9O3Vdq2fWeceqmP1FCsy1FRgqD06Bm1rBilfB1FRs3kqqopKjX05CR(BLoh3(Jtt)6HaKpd4k6OHRv)TkpRs3QbeYfWe7eL7FeN7rd3jMCHuR(BvEwLUvHZPnMcm5Ih3feysR)4KWQKjTkDRgqixatStbMCXJ7ccmXKlKAvYKwLUvc6HGIor5(hX5E0WDIKzvUwLRkuPkzotPLIHw)XjHsBfZa3bHBxXGrwcfI)OzV66pi2JE)oazxatiqaXKw)XjHv)TkDRgqD06Bm1rBilfB1FRs3kqqopKjX05CR(BvEwnGqUaMyN0qg273btz4(YxXetxEVaR(1QF0QKjTkDRgqixatStaLbAWetUqQvjtA1ac5cyIDcim2dsCEWLoGSMDAIIW5hmnKD8hDI(IS6xRyJ1wLRIXhrdxfJoFBGSkuPkPEtPLIHw)XjHsBfZa3bHBxXKUvGGCEitIPZ5w93kDoU9hNM(1dbiFgWv0rdxfJpIgUkgGSlGjUiUqfQuLuIvPLIHw)XjHsBfZa3bHBxX8qqrNpoek4iGyIjFewLmPvpiay1FRq7p54GPlVxGv5WQ8XARsM0Qhck60fyADEV0bJaKNizkgFenCvmzWOHRkuPYgRvAPy8r0WvX84qO4GIGLQyO1FCsO0wfQuztsLwkgFenCvmpcdim79(PyO1FCsO0wfQuzJnLwkgFenCvmOnMECiuOyO1FCsO0wfQuzlFkTum(iA4Qy8DqGa78ZW5CfdT(JtcL2QqLkBsCLwkgA9hNekTvm(iA4Qys0RamC8jHmfGaUKIzG7GWTRyazeNFch)rby(4UGoOCemwQv)ALGanMeNWXFuaSkzsRWEloKoAJPleGzVw9Rv)iRTkzsRq7p54GPlVxGv5WQCMIz9lsXKOxby44tczkabCjvOsLT7O0sXqR)4KqPTIXhrdxftG7LDkKuXiiWa3zrdxftkqOocpSAaxrhnCbwHcXwHa8hNSQd6cmvmdCheUDfJGEiOOZhfjiApHmDiPeyIKzvYKwf4EzNIzi5u2bheaDEiOOwLmPvpiay1FRq7p54GPlVxGv5qJvSXAvOsLTFuPLIHw)XjHsBfZa3bHBxXiOhck68rrcI2tithskbMizwLmPvbUx2PygSnLDWbbqNhckQvjtA1dcaw93k0(tooy6Y7fyvo0yfBSwX4JOHRIjW9YofSPcvOyab58qwPLkvjvAPyO1FCsO0wXmWDq42vm6CC7ponr7TbYNbCfD0WvX4JOHRIr0GmpgYQqLkBkTum(iA4Qy8RhcqwXqR)4KqPTkuPMpLwkgA9hNekTvm(iA4QygYKNDaYWqXmWDq42vmHZPnMzys6bUNqMojiN9jT(JtcR(Bv6wfo(JIzdopiaOygshC6eo(JcGkvjvHkumO92azLwQuLuPLIHw)XjHsBfJpIgUkMhfjiApHmDiPeqXiiWa3zrdxfJ2rkAfCTAaHCbmXAvaTIDIYSkKjRKaUdRe0dbf1kKmwScz5eayvitwfo(JcRAGv(dIewfqRenPyg4oiC7kMWXFumJ(Iob8iAYQFTkFQqLkBkTum06pojuARyg4oiC7kMhck6eW7bD8vCe9GMy6Y7fyvoScT)KJdMU8Ebw93kmHIjGS)4KIXhrdxfdG3d64R4i6bPcvQ5tPLIXhrdxfJObzEmKvm06pojuARcvOcfJocdA4QsLnwZgBSMn2KuXKWXBVFafZpKv07P(ZPYQrVSYkTKjR6RmioScfITknbH6i8inRWu(hPXKWka8ISYrc4LhKWQHSVFeyA3YVEjRK46LvsaU6iCqcRsBaxbshZ7MMvb0Q0gWvG0X8UtA9hNePzvEsQNCN2n72pKv07P(ZPYQrVSYkTKjR6RmioScfITkTmmnGxppsZkmL)rAmjScaViRCKaE5bjSAi77hbM2T8RxYQ7Oxwjb4QJWbjSknaeH)6vmVBAwfqRsdar4VEfZ7oP1FCsKMv5jPEYDA3YVEjRUJEzLeGRochKWQ0aqe(RxX8UPzvaTknaeH)6vmV7Kw)XjrAw5HvPyop)Skpj1tUt7MD7hYk69u)5uz1OxwzLwYKv9vgehwHcXwL2qasZkmL)rAmjScaViRCKaE5bjSAi77hbM2T8RxYk20lRKaC1r4GewLggzjui(JM3nnRcOvPHrwcfI)O5DN06pojsZQ8YNEYDA3YVEjRYNEzLeGRochKWQ0WilHcXF08UPzvaTknmYsOq8hnV7Kw)XjrAwLNK6j3PDl)6LSsIRxwjb4QJWbjSknmYsOq8hnVBAwfqRsdJSeke)rZ7oP1FCsKMv5jPEYDA3YVEjRYz6LvsaU6iCqcRsdar4VEfZ7MMvb0Q0aqe(RxX8UtA9hNePzvESPNCN2T8RxYkjw9YkjaxDeoiHvPfoN2yE30SkGwLw4CAJ5DN06pojsZQ8Kup5oTB5xVKvsMp9YkjaxDeoiHvPHrwcfI)O5DtZQaAvAyKLqH4pAE3jT(JtI0Skpj1tUt7w(1lzLK)OEzLeGRochKWQ0cNtBmVBAwfqRslCoTX8UtA9hNePzvEsQNCN2T8RxYkj)r9YkjaxDeoiHvPHrwcfI)O5DtZQaAvAyKLqH4pAE3jT(JtI0Skpj1tUt7w(1lzLK5m9YkjaxDeoiHvPHrwcfI)O5DtZQaAvAyKLqH4pAE3jT(JtI0Skpj1tUt7w(1lzfB3rVSscWvhHdsyvAbUx2Pyk58UPzvaTkTa3l7umdjN3nnRYts9K70ULF9swX2pQxwjb4QJWbjSkTa3l7umzBE30SkGwLwG7LDkMbBZ7MMv5jPEYDA3SB)qwrVN6pNkRg9YkR0sMSQVYG4Wkui2Q0EinxKMvyk)J0ysyfaErw5ib8Ydsy1q23pcmTB5xVKv5tVSscWvhHdsyvAyKLqH4pAE30SkGwLggzjui(JM3DsR)4KinR8WQumNNFwLNK6j3PDl)6LSsIRxwjb4QJWbjSknaeH)6vmVBAwfqRsdar4VEfZ7oP1FCsKMv5jPEYDA3SB)8vgehKWQF0kFenCTI3GamTBkgqgnuPY2pYAftggI2CsXKYuAvohj4EcR07WpeYULYuA1prpmIJLAfB6nwSInwZgB2n7wktPvsq23pcOx2TuMsRYjRyvo7Kv)eNaYdSJgw1BqymswyvVwnGxppSQrTkbzLedciSs0cR6Wkui2kDqUhnNoaixhTX0Uz3szkTkf1dnqcsy1JqHyYQb865Hvp6RxW0kwzmOSay1c3Cs2XxOiCR8r0WfyfC5sN2nFenCbZmmnGxpp04zzCPNmydGRDZhrdxWmdtd41Zd91C)dgbNehuUlLej697eq90RDZhrdxWmdtd41Zd91CpiiNhY2nFenCbZmmnGxpp0xZ9xoMDsCqH4JG8qMLmmnGxppoaAaxbqZDyPr1G9wCiD0gtxiaZE)LT7y38r0WfmZW0aE98qFn3JYjG8a7OblnQgaeH)6vmZqabcNoegjlA4MmjaIWF9kM6GCpAoDaqUoAd7MpIgUGzgMgWRNh6R5EmKZpHmDEWLaSKHPb865Xbqd4kaAyJLgvdMU8Eb5iF2nFenCbZmmnGxpp0xZ9aEpOJVIJOhelzyAaVEECa0aUcGg2yPr1GjumbK9hNSB2TuMsRsr9qdKGewr6iSuRI(ISkKjR8raXw1aRCDEZ9hNM2nFenCbAyVhSB3sPv6DceKZdzRAuRYGaq)4Kv5TqR0HWxc7pozfT0vtaR61Qb865rU2nFenCb6R5EqqopKTBP0k9oHHCUvGE)4KvpeuuGvKJ5sTcgYe2Qq2xR0cJqwPn54E)SYxHvAJHUa0cYU5JOHlqFn3RZXT)4elRFrAWX7GjmKZzrNZrin44DEiOOGCW2)8s)HGIodmcDEKJ79BIK9p9hck68HHUa0cAIKLRDlLwLIlabtwLGS6JcRqr4CRyLRhcq2kjirw959cSYxHvoM20cRWegY59(zLeGiByvitwLZfcGvpeuuGvEcxQDZhrdxG(AUxNJB)Xjww)I04xpeG8zaxrhnCzrNZrind41dEYG9gGPGq7rh)QHn9FiOOZhg6cqlOjs2FAj8N0F1Chw)pV0hWvG0XCar24eY0bkeGKjFiOOtmKZpHmDEWLatmD59c(vJKSox7wkT6N6TbYw5HvxUESkdca9JtwjbjYQeDidrcRG6imkhMO3pREWfby1aE9GwLb7naSyfYYjaWkui2kTJu0QeY9q2kNNWLcScidr4cREKv3rFRKGez38r0WfOVM71542FCIL1VinO92a5ZaUIoA4YIoNJqAgWRh8Kb7na)QzKDUC9Caz0kYPhck68HHUa0cAIKLt59qqrNWSmioq2oKorYYFdNtBmZ)i9G9Ja7jM06pojYnzscfLgrRJod41dEYG9gGF1mYoxUEoGmAf2TuAfRWt4sbw5rqxzHvb0keazL2rkALhwDh9TscselwHPphl4eayfe1kjirw9rRvjCqq2nFenCb6R5EDoU9hNyz9lsdAVnq(mGROJgUSaZ0GjafS0OAgqixatSZhfjiApHmDiPeyIjxi9pHIsJO1rNb86bpzWEdqoUJDlLw9d7q2QleE0zCYQWXFuayXQqUbwPZXT)4KvnWQHmnyNewfqRe0OfKvjKPqMWwbGxKvsifawbKHiCHvpYkG0DqcRs0HSvAZDbz1pXrWyP2nFenCb6R5EDoU9hNyz9lsZJ7c6GYrWyPhG0DWIoNJqAazeNFch)rby(4UGoOCemwAoy7p2BXH0rBmDHam79x2yDYKpeu05J7c6GYrWyPtmD59c(vs9dNtBmzV58E)oGmmrtA9hNe2nFenCb6R5EmYE8r0W9WBqWY6xKgqqopKzPr1acY5HmjMoNB38r0WfOVM7hoNF8r0W9WBqWY6xKMHay38r0WfOVM7Xi7Xhrd3dVbblRFrAq7TbYS0OA0542FCAI2BdKpd4k6OHRDZhrdxG(AUF4C(Xhrd3dVbblRFrAEinxy38r0WfOVM7D8Wx6eqmM2GLgvdTe(t6uqO9OJF1i5D0Nwc)jDIPpATB(iA4c0xZ9oE4lDYq4aYU5JOHlqFn3Z7p5aCKyqeFx0g2nFenCb6R5(N)DGONa3d2b2n7wktPvAJ0CbHb2nFenCbZhsZfAaugOb2nFenCbZhsZf6R5(pzii4spGa3St2nFenCbZhsZf6R5EGCRJLgvdgzjui(JMrVspbup9484UGSB(iA4cMpKMl0xZ90qg273btz4(YxblnQM0bqe(RxXKqrraTo64BF5hFmioH9aItMuNJB)XP5J7c6GYrWyPhG0Dy3sPvSswgxQvmAZyvaTY5CRch)rbWQeDidrcRCRe0dbf1khyvgUH4oKYIvzycLW4E)SkC8hfaRes79ZkaeUe2khniSvHmzvgUVCSuRch)rHDZhrdxW8H0CH(AUhqyShK48GlDazn7elnQM0fWycim2dsCEWLoGSMD6iGXm6b79(z38r0WfmFinxOVM7beg7bjop4shqwZoXYq6GtNWXFua0ijlnQM0fWycim2dsCEWLoGSMD6iGXm6b79(z3sPvSse0vwyvaTcbqwLqMwR6WQenNB1WZSAaVEqRYG9gaR8vyfZMcw1aReWellwbdzcNObKvStuMvOy4LvdplR3pRgYo(Ja2nFenCbZhsZf6R5EaHXEqIZdU0bK1StS0OAq7p54GPlVxqo0CNKjhqixatStaHXEqIZdU0bK1StZlxpNHSJ)iqonKD8hboOyFenCDEo0W6jB3jzYb86bpzWEdWuqO9OdnJSZN37)0FiOOta7iC(XxXzGHaWdUeyIK9Nwc)jDg9fDc45Y1ZVsA3sPv)aazLe1GaYTIrggwLOdzRY5zzqCGSDi1Qg1kjaVEEyLebdAhsTkbCtlScQJWdpZkAj8NuwSkHmTw1HvjAo3ksp(i4sTA4zwjbjIfRGyRsitRviGE)SIvlspy3Qua7jSB(iA4cMpKMl0xZ9zniG8dqggS0OAEiOOtywgehiBhsNiz)ZJwc)jDki0E0XV5rlH)KoX0hT6ljRZnzYb86bpzWEdWuqO9OJCOrs9FiOOZhg6cqlOjswYKHZPnM5FKEW(rG9etA9hNe5A38r0WfmFinxOVM7ZAqa5hGmmyPr18qqrNWSmioq2oKorY(N3dbfD(HjAbS3l4KOhStyWejlzYhck6Ca3b5CsCECKvq4hcamrYsM8HGIodiEDb8e4(7JWtKSCTB(iA4cMpKMl0xZ9GEBqq4diWn7KDZhrdxW8H0CH(AU)dI8rS0OAcNtBmfnoKEcCpyhmP1FCs8FaVEWtgS3amfeAp64xnsQ)dbfD(WqxaAbnrYSB2TuMsRKaeYfWelWULsR0M7cYQFIJGXsTcUwXM(wrlD1eWU5JOHlyoeanpUlOdkhbJLYsJQbKrC(jC8hfGF1W2)0FiOOZh3f0bLJGXsNiz2TuA1pa07NvSY1dbiBvdSYTIT8Nw17atoGyXka0kwDFBGSvdFT6rwbGxu0xeWQhzfcGew5aRCRqIM3HuRazeNBfYYjaWkeqVFwXQCqqyRyfaWbGETcITkfipK5sTIr2fWea7MpIgUG5qa0xZ968TbYS0OAshJSeke)rZlhZ(bIEcz6C5GGWhhaCaO3)PJrwcfI)OzV66pi2JE)oazxatiqaX)0bb58qMetNZ)RZXT)400VEia5ZaUIoA4(pV0XilHcXF0uqEiZLEaYUaMaKm5dbfDkipK5spazxataMcyI9)aE9GNmyVbihAylx7wkT6h2HSvSkhee2kwbaaoa0llwbKUdRy19TbYwLOdzRCRq7TbYe2ki2kw56HaKTsqz0k69Zk4AL2rkA1ac5cyILfRGyRCEcxkWk3k0EBGmHTkrhYwXQqtb7MpIgUG5qa0xZ96CC7poXY6xKgD(2a5ZLFgWv0rdxwAunyKLqH4pAE5y2pq0titNlhee(4aGda9(p9W50gZlhZojoOq8rqEipP1FCsWIoNJqAYl9beYfWe78rrcI2tithskbMyYfs)RZXT)40eT3giFgWv0rd3CtMmVbeYfWe78rrcI2tithskbMyYfs)RZXT)400VEia5ZaUIoA4MRDZhrdxWCia6R5EDoU9hNyz9lsJoFBG85Ypd4k6OHllnQgmYsOq8hnVCm7hi6jKPZLdccFCaWbGE)hoN2yE5y2jXbfIpcYd5jT(Jtcw05CesJoh3(Jtt0EBG8zaxrhnCTB(iA4cMdbqFn3RZ3giZsJQrNJB)XPPoFBG85Ypd4k6OH7)lhee(4aGda9EW0L3lqdR)RZXT)408XDbDq5iyS0dq6oSB(iA4cMdbqFn37cmToVx6GraYS0OAs)HGIoDbMwN3lDWia5jsMDlLw9tCcipWoAyfkeBLeHaceozvkIrYIgUw1OwTWWkqqopKjHv(kSAHHvj6q2kT5UGS6N4iySu7MpIgUG5qa0xZ9OCcipWoAWsJQjpaeH)6vmZqabcNoegjlA4MmjaIWF9kM6GCpAoDaqUoAJC)NoiiNhYKy6C()8s)HGIoFCxqhuocglDIKLmjiJ48t44pkaZh3f0bLJGXsZbB5(pV0FiOOtxGP159shmcqEIKLmjTe(t6m6l6eWZLRNFzlxw6nimgjlo91fjApinsYsVbHXizX5JdFoxJKS0BqymswCAunaic)1RyQdY9O50ba56OnSB(iA4cMdbqFn3JY9pIZ9OHllnQM0bb58qMetNZ)NNoh3(Jtt0EBG8zaxrhnCtMmC8hfZOVOtapIMYHK5lx7MpIgUG5qa0xZ9cm5Ih3feGLgvt6GGCEitIPZ5)hWRh8Kb7na5qdB)Zl9buhT(gtD0gYsXjtkOhck6eL7FeN7rd3jswU)Zl9W50gZlhZojoOq8rqEiNmz6diKlGj25LJzNehui(iipKNyYfsZ1U5JOHlyoea91CpgY5NqMop4sawAunxoii8Xbaha69GPlVxGgw))HGIofyYfpUliWuatS)Z7HGIoXqo)eY05bxcmX0L3lihAYxYK6CC7ponXX7GjmKZZ1ULsR(zuRCHayLJjRqYyXkW2zKvHmzfCjRs0HSvCyccewPLwPW0QFaGSkHmTwjK27NvOoiiSvHSVwjbjYkbH2JoScITkrhYqKWkFLALeKOPDZhrdxWCia6R5(lhZojoOq8rqEiZcVx6meAKCEhwgshC6eo(JcGgjzPr1G9wCiD0gtxiatKS)5fo(JIz0x0jGhrt5yaVEWtgS3amfeAp6izY0bb58qMetm8dH(pGxp4jd2BaMccThD8RMr25Y1ZbKrRiNKmx7wkT6NrTAHw5cbWQenNBLOjRs0HCVwfYKvlPNWQ8XAalwHaiRyvOPGvW1QheaSkrhYqKWkFLALeKOPDZhrdxWCia6R5(lhZojoOq8rqEiZsJQb7T4q6OnMUqaM9(B(yDoH9wCiD0gtxiatbc2JgU)theKZdzsmXWpe6)aE9GNmyVbyki0E0XVAgzNlxphqgTICsY)5L(aQJwFJPoAdzP4KjhqixatStuU)rCUhnCNy6Y7f8RKSozsb9qqrNOC)J4CpA4orYY1ULsRyLiORSWQaAfq6oSk)rZ59(zftgMiRs0HSvS6(2azRqHyRyvoiiSvSca4aqV2nFenCbZHaOVM71542FCIL1VinS3CEVFhqgMOJoFBG8biDhSOZ5iKM0XilHcXF08YXSFGONqMoxoii8Xbaha6nzYbeYfWe7uNVnqEIPlVxWVsY6KjVCqq4Jdaoa07btxEVGFzZULsR(baYQETsYCInTSQrTs7ifTQbwHKzLVcRsa30cRgEMvP4s4pPSyfeBLhwLpT03Q8ytl9TkrhYwLcKhYCPwXi7cycqUwbXwLqMwRyvoiiSvSca4aqVw1aRqYM2nFenCbZHaOVM7zV58E)oGmmrS0OA0542FCA(4UGoOCemw6biDh)1542FCAYEZ59(DazyIo68TbYhG0D8pDqqopKjXed)qO)5jOhck68rrcI2tithskbMiz)FiOOtbMCXJ7ccmfWe7FAj8N0PGq7rh)MhTe(t6etF0M)YM(sENCtMeKrC(jC8hfG5J7c6GYrWyP)MhB50dbfDkipK5spazxataMiz5Mm5LdccFCaWbGEpy6Y7f8lRZ1U5JOHlyoea91C)J7c6GraYS0OA0542FCA(4UGoOCemw6biDh)ZJwc)jDg9fDc45Y1ZVS9)HGIofyYfpUliWuatSjtslH)KMdn5J1jtcYio)eo(JcWVSLRDlLw9ZOwHa69ZQFE11FqSh9(zfJSlGjeiGGfRqaKvleF5CR4WVEyvVw5crhnCTkGwnKPb79(z1LlXaXwjHuamTB(iA4cMdbqFn3RZ3giZsJQbJSeke)rZE11FqSh9(DaYUaMqGaI)dOoA9nM6OnKLI)NoiiNhYKy6C(FDoU9hNM(1dbiFgWv0rd3)5L(ac5cyIDIY9pIZ9OH7etUq6)8spCoTXuGjx84UGajtM(ac5cyIDkWKlECxqGjMCH0Kjtxqpeu0jk3)io3JgUtKSCZ1U5JOHlyoea91CVoFBGmlnQgmYsOq8hn7vx)bXE073bi7cycbci(N(aQJwFJPoAdzP4)PdcY5HmjMoN)pVbeYfWe7KgYWE)oykd3x(kMy6Y7f87pMmz6diKlGj2jGYanyIjxinzYbeYfWe7eqyShK48GlDazn70efHZpyAi74p6e9f9lBSox7MpIgUG5qa0xZ9azxatCrCblnQM0bb58qMetNZ)RZXT)400VEia5ZaUIoA4A38r0WfmhcG(AUpdgnCzPr18qqrNpoek4iGyIjFejt(GaWF0(tooy6Y7fKJ8X6KjFiOOtxGP159shmcqEIKz38r0WfmhcG(AU)XHqXbfbl1U5JOHlyoea91C)JWacZEVF2nFenCbZHaOVM7rBm94qOWU5JOHlyoea91CVVdceyNFgoNB38r0WfmhcG(AUhbqNoOlww)I0KOxby44tczkabCjwAunGmIZpHJ)OamFCxqhuocgl9xbbAmjoHJ)OaKmj2BXH0rBmDHam793FK1jtI2FYXbtxEVGCKZSBP0QuGqDeEy1aUIoA4cScfITcb4pozvh0fyA38r0WfmhcG(AUpW9YofsYsJQrqpeu05JIeeTNqMoKucmrYsMmW9YoftjNYo4GaOZdbfnzYhea(J2FYXbtxEVGCOHnwB38r0WfmhcG(AUpW9YofSXsJQrqpeu05JIeeTNqMoKucmrYsMmW9Yoft2MYo4GaOZdbfnzYhea(J2FYXbtxEVGCOHnwB3SBPmLw9t92azcdSBP0kTJu0k4A1ac5cyI1QaAf7eLzvitwjbChwjOhckQvizSyfYYjaWQqMSkC8hfw1aR8hejSkGwjAYU5JOHlyI2BdK18Oibr7jKPdjLaS0OAch)rXm6l6eWJOPFZNDZhrdxWeT3giRVM7b8EqhFfhrpiwAunpeu0jG3d64R4i6bnX0L3lihO9NCCW0L3l4pMqXeq2FCYU5JOHlyI2BdK1xZ9IgK5Xq2Uz3szkTIjiNhY2nFenCbtqqopK1iAqMhdzwAun6CC7ponr7TbYNbCfD0W1U5JOHlyccY5HS(AU3VEiaz7MpIgUGjiiNhY6R5(Hm5zhGmmyziDWPt44pkaAKKLgvt4CAJzgMKEG7jKPtcYzFsR)4K4F6HJ)Oy2GZdcaQqfkfa]] )
    

end
