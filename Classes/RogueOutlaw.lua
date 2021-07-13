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
            alias = { "instant_poison", "wound_poison", "slaughter_poison" },
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
        }
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

            spend = function () return ( talent.dirty_tricks.enabled and 0 or 40 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
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

            spend = function () return 30 * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
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
            
            spend = function () return 25 * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
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

            spend = function () return ( talent.dirty_tricks.enabled and 0 or 35 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
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


    spec:RegisterPack( "Outlaw", 20210713, [[d8uimbqiuGhrQuxsbI0Mqj9jfKrPsPtPsLvPsvfVIuXSqHUfPQyxa(LcQHHs0XqPSmurptb00uGW1uPW2uGQ(gPQIXPavoNcK06ivLMNcW9qL2hkOdQsvwiQkpevvMiPQQlIQQAJQuv(OcK4KOQkwPc5LkqeZuLI6MQuKDsQYpjvvAOOe6OQuvPLIQQ0tHyQOcxvbk2Qkvv9vfO0yrjyVe(RIgSKdlSyv8yrnzsUmYMH0NrrJMuoTuRwbI61OunBIUTkz3k9BqdxehxbsTCOEUQMovxhOTls(Ui14jvY5rvMVc1(PSGnbhcev4KqpozjNSXs9dBdeGLdowo4giNceNxcjqsIm7btsGSXfjq0VGUmslqscEsyOeCiqEiiotcen3tE9D4Hz2Ug4bidVg(7lqz4nCZ4a1h(7R8WcKdylD(Zkocev4KqpozjNSXs9dBdeGLdowo44CWlqcqxdIfii9f)eiATsrR4iqu0Nfi6xqxgPTI)czcs2OrGsEwX2az0kozjNSzJSr8tlwM0RV2i9XQBkyNS6(K0RLXbQBvVoHXGjUv9AvgEDc3Qg1Q0KvdYGVBLQvw1UvOqSvPGYWBjnFOmfToGar2V)coeikcnaLUGdHESj4qGezVHRaH9oZUaH24ijLGpHl0JtbhceAJJKuc(eik6Z4oXB4kq4V07uiDnRAuRsG)3hjz1Tl0QuGYLWXrswrlD10BvVwLHxNWVtGezVHRa5DkKUMWf6nqbhceAJJKuc(eiWebYtUajYEdxbsQa3XrscKuHeKeiy)mpGOOVvdWkoTIvRU1kgy1beffWXG08qbUxMaGjwXQvmWQdikkWbdd13kcamXQ7eik6Z4oXB4kq4VegkLw99YuswDarrFROal5zf01iSvUwSwXbgKSIpkW9Y0QyvwXhggQVvKajvGNBCrceSFMycdLsHl0Bqi4qGqBCKKsWNabMiqEYfir2B4kqsf4oossGKkKGKajdVoWzcSx)bueANB3kgY1koTshRoGOOahmmuFRiaWeRy1kAjmtEwXqUwDdwAfRwDRvmWQmCvGTdKHGRpDnAcvQhG24ijLvJhB1beffadLYPRrZdCPhatxrVVvmKRvSXsRUtGOOpJ7eVHRaH)3hetwLMSIj5wHckLwDVRd4Rzf)yrRyg9(wfRYQat7qUvycdLYEzAf)GGRBLRrwPFvQ3Qdik6BvKo4jqsf45gxKajUoGV2mdxv7nCfUqVBi4qGqBCKKsWNabMiqEYfir2B4kqsf4oossGKkKGKajdVoWzcSx)TIHCTkNmVcDn)eAvwPpwDarrboyyO(wraGjwPpwDRvhquuaysce7GB78aatS6(XkpK06adAWoZ(uHJ0a0ghjPS6oRgp2kcfLYENIMz41botG96VvmKRv5K5vOR5NqRsGOOpJ7eVHRa5(6TFnRc3QRqxwLa)VpsYk(XIwLUDniOBfmfHrLW09Y0QdCbFRYWRd0QeyV(ZOvGRK(3kui2k(C(3Q0ADwZQqMo49w9AqqPYQdz1n0Xk(XIcKubEUXfjqq7TFTzgUQ2B4kCHEdEbhceAJJKuc(eiWebcMEYfir2B4kqsf4oossGKkWZnUibcAV9RnZWv1Edxbsg3oH7qGKHqPcMEboKNMOD6A0K4rpaMcfpRy1kcfLYENIMz41botG96VvdWQBiqu0NXDI3WvGCpz6G3Bv4oDL4w5qRaFYk(C(3QWT6g6yf)yrgTctmdSss)Bfe1k(XIwXKwRshVtcxON(rWHaH24ijLGpbcmrG8KlqIS3WvGKkWDCKKajvibjbYNqs50dmtYFGJmu0evcIX8SAawXPvSAfoA1KsrRdek1d0Rvm0kozPvJhB1beff4idfnrLGympamDf9(wXqRyZkDSYdjToa7Tu2lZ5NGjcG24ijLarrFg3jEdxbYGTDnRUaLENijR8aZK8NrRCT(TkvG74ijR63QSgLzNuw5qRuuUvKvP1ixJWw9WlYk(P)VvVgeuQS6qw982mPSkD7AwXNmuKv3NeeJ5jqsf45gxKa5idfnrLGymV5ZBZcxO3GtWHaH24ijLGpbsg3oH7qG8ofsxJuaHukqIS3WvGGb3zK9gUtz)Uar2Vp34IeiVtH01eUqVbvbhceAJJKuc(eir2B4kqYHuoJS3WDk73fiY(95gxKajREHl0Jnwk4qGqBCKKsWNajJBNWDiqsf4ooscaT3(1Mz4QAVHRajYEdxbcgCNr2B4oL97cez)(CJlsGG2B)AcxOhBSj4qGqBCKKsWNajYEdxbsoKYzK9gUtz)Uar2Vp34IeihWwQeUqp24uWHaH24ijLGpbsg3oH7qGqlHzYdqrODUDRyixRy7gwPJv0syM8aWetAfir2B4kqcCowA6qmMwx4c9yBGcoeir2B4kqcCowAMakFsGqBCKKsWNWf6X2GqWHajYEdxbISzQ5)CqguX8IwxGqBCKKsWNWf6X2neCiqIS3WvGCcMti60XDM9xGqBCKKsWNWfUajbtz41jCbhc9ytWHajYEdxbsKKi5ntG9dxbcTXrskbFcxOhNcoeir2B4kqoq3LKAIkdEKkDVmNoux9kqOnossj4t4c9gOGdbsK9gUcK3Pq6AceAJJKuc(eUqVbHGdbcTXrskbFcKi7nCfixbMDsnrH4PIcxtGKXTt4oei4OvtkfToqOupqVwXqR48gcKemLHxNWNpLHR6fi3q4c9UHGdbcTXrskbFcKmUDc3Ha5HGYtVkGeW3bL0KWGjEdxaAJJKuwnESvpeuE6vbKckdVL08HYu06a0ghjPeir2B4kqqL0RLXbQlCHEdEbhceAJJKuc(eir2B4kqWqPC6A08ax6fizC7eUdbcMUIEFRgGvduGKGPm86e(8PmCvVaHtHl0t)i4qGqBCKKsWNajYEdxbYl7mnJvnvDMeizC7eUdbcMqX0RfhjjqsWugEDcF(ugUQxGWPWfUa5a2sLGdHESj4qGezVHRa5PKVFbcTXrskbFcxOhNcoeir2B4kqyQbFxYB(oUzNei0ghjPe8jCHEduWHaH24ijLGpbsg3oH7qGGbxcfIzsaEV8MouxDEEKHIaOnossjqIS3WvG8ADkHl0Bqi4qGqBCKKsWNajJBNWDiqyGvpeuE6vbqOOGFNIMX2xXmYzss4WHyaAJJKuwnESvPcChhjbCKHIMOsqmM385TzbsK9gUcekRb7L5etj4(kwLWf6DdbhceAJJKuc(eir2B4kqEcJdNuZdCP5N0Stcef9zCN4nCfi3ljrYZke(qSYHwfsPvEGzs(Bv621GGUvHvk6aIIAv8wLGBiUDEmAvcMqjmUxMw5bMj5VvkE9Y0QhcxcBvG6e2kxJSkb3xbMNvEGzsUajJBNWDiqyGvkOd8eghoPMh4sZpPzNMkOd4DM9EzkCHEdEbhceAJJKuc(eir2B4kqEcJdNuZdCP5N0StcKmUDc3HaHbwPGoWtyC4KAEGln)KMDAQGoG3z27LPajZllPPhyMK)c9yt4c90pcoei0ghjPe8jqIS3WvG8eghoPMh4sZpPzNeik6Z4oXB4kqUN70vIBLdTc8jRsRrRvTBv6wkTkhjwLHxhOvjWE93QyvwHS6Vv9BLcMEz0kORr409twXorjwHIHxwLJKKEzAvwlWmPxGKXTt4oeiOntnFIPRO33QbW1QBy14XwLHqPcMEbEcJdNuZdCP5N0StaxHUMzTaZKER0hRYAbMj9tuCK9gUH0QbW1kwcW5nSA8yRYWRdCMa71FafH252TIRv5KjZOxRy1kgy1beff4zhukNXQMzm8)dCPhamXkwTIwcZKhG3x00HZRqxwXqRyt4c9gCcoei0ghjPe8jqIS3WvGK0VdLZxd6cef9zCN4nCfidMNSIf73HsRq0GUvPBxZk9Bsce7GB78SQrTIFWRt4wXIqN2mpRsd3HCRGPiCosSIwcZKhJwLwJwRA3Q0TuAfPRi7sEwLJeR4hlYOvqSvP1O1kWVxMwD)c2z2Ts)XrAbsg3oH7qGCarrbGjjqSdUTZdamXkwT6wROLWm5bOi0o3Uvm0QBTIwcZKhaMysRv6yfBS0Q7SA8yRYWRdCMa71FafH252TAaCTInR0XQdikkWbdd13kcamXQXJTYdjToWGgSZSpv4inaTXrskRUt4c9gufCiqOnossj4tGKXTt4oeihquuaysce7GB78aatSIvRU1Qdikkatmr7ZEV)mDNzNWpayIvJhB1beffid3mfssnpsWvr4d4)aGjwDNajYEdxbss)ouoFnOlCHESXsbhcKi7nCfiFV97eE(oUzNei0ghjPe8jCHESXMGdbcTXrskbFcKmUDc3HaXdjToGQXoVPJ7m7paTXrskRy1Qm86aNjWE9hqrODUDRyixRyZkDS6aIIcCWWq9TIaateir2B4kqycbzscx4cKS6fCi0JnbhceAJJKuc(eir2B4kqoYqrtujigZtGOOpJ7eVHRaHpzOiRUpjigZZk4AfN6yfT0vtVajJBNWDiq(eskNEGzs(Bfd5AfNwXQvmWQdikkWrgkAIkbXyEaGjcxOhNcoei0ghjPe8jqIS3WvGKk2(1eik6Z4oXB4kqgmFVmT6ExhWxZQ(TkSIZbPw1BgtXtmA1dT6(hB)AwLJ1Qdz1dViVVO3Qdzf4tkRI3QWkqVLTZZQpHKsRaxj9VvGFVmT6MI3jSv37)4)ETcITs)PW1K8ScrluW0VajJBNWDiqyGvyWLqHyMeWvGzFcrNUgnVI3j8m(p(VxaAJJKuwXQvmWQ3Pq6AKciKsRy1QubUJJKaIRd4RnZWv1EdxRy1QBTIbwHbxcfIzsakkCnjV5Rfky6hG24ijLvJhB1beffqrHRj5nFTqbt)aky61kwTkdVoWzcSx)TAaCTItRUt4c9gOGdbcTXrskbFceyIa5jxGezVHRajvG74ijbsQap34IeiPITFT5vmZWv1Edxbsg3oH7qGGbxcfIzsaxbM9jeD6A08kENWZ4)4)EbOnosszfRwXaR8qsRdCfy2j1efINkkCnaAJJKucef9zCN4nCfid221S6MI3jSv37)p(VxgT65TzRU)X2VMvPBxZQWk0E7xJWwbXwDVRd4RzLIsOv1ltRGRv858VvziuQGPxgTcITkKPdEVvHvO92VgHTkD7AwDtO6VajvibjbYTwXaRYqOubtVahYtt0oDnAs8OhatHINvSAvQa3XrsaO92V2mdxv7nCT6oRgp2QBTkdHsfm9cCipnr701OjXJEamfkEwXQvPcChhjbexhWxBMHRQ9gUwDNWf6nieCiqOnossj4tGateip5cKi7nCfiPcChhjjqsfsqsGKkWDCKeaAV9RnZWv1Edxbsg3oH7qGGbxcfIzsaxbM9jeD6A08kENWZ4)4)EbOnosszfRw5HKwh4kWStQjkepvu4Aa0ghjPeiPc8CJlsGKk2(1MxXmdxv7nCfUqVBi4qGqBCKKsWNajJBNWDiqsf4ooscivS9RnVIzgUQ2B4AfRwDfVt4z8F8FVtmDf9(wX1kwAfRwLkWDCKeWrgkAIkbXyEZN3Mfir2B4kqsfB)AcxO3GxWHaH24ijLGpbsg3oH7qGWaRoGOOaHctBi7LMyWxdamrGezVHRajuyAdzV0ed(AcxON(rWHaH24ijLGpbII(mUt8gUcK7tsVwghOUvOqSvSi47GsYk(hdM4nCTQrTAHUvVtH01iLvXQSAHUvPBxZk(KHIS6(KGympbsg3oH7qGCRvpeuE6vbKa(oOKMegmXB4cqBCKKYQXJT6HGYtVkGuqz4TKMpuMIwhG24ijLv3zfRwXaRENcPRrkGqkTIvRU1kgy1beff4idfnrLGympaWeRgp2QpHKYPhyMK)ahzOOjQeeJ5z1aSItRUZkwT6wRyGvhquuGqHPnK9stm4RbaMy14XwrlHzYdW7lA6W5vOlRyOvCA1DcKEDcJbt8zJkqEiO80RcifugElP5dLPO1fi96egdM4Z(6IuD4KaHnbsK9gUceuj9AzCG6cKEDcJbt8jtj8esbcBcxO3GtWHaH24ijLGpbsg3oH7qGWaRENcPRrkGqkTIvRU1QubUJJKaq7TFTzgUQ2B4A14Xw5bMj5aEFrthovnz1aSITbA1DcKi7nCfiOYGjjLH3Wv4c9gufCiqOnossj4tGKXTt4oeimWQ3Pq6AKciKsRy1Qm86aNjWE93QbW1koTIvRU1kgyvgMI2yDGu06A8WwnESvk6aIIcGkdMKugEdxaWeRUtGezVHRarHPqDKHIEHl0Jnwk4qGqBCKKsWNajJBNWDiqUI3j8m(p(V3jMUIEFR4AflTIvRoGOOakmfQJmu0dOGPxRy1QBT6aIIcGHs501O5bU0dGPRO33QbW1QbA14XwLkWDCKea2ptmHHsPv3jqIS3WvGGHs501O5bU0lCHESXMGdbcTXrskbFcKi7nCfixbMDsnrH4PIcxtGi7LMzLaHnGBiqY8YsA6bMj5Vqp2eizC7eUdbcoA1KsrRdek1daMyfRwDRvEGzsoG3x00HtvtwnaRYWRdCMa71FafH252TA8yRyGvVtH01ifagYeKSIvRYWRdCMa71FafH252TIHCTkNmVcDn)eAvwPpwXMv3jqu0NXDI3WvGWFqTkuQ3QatwbMWOv)2jKvUgzfCjRs3UMvsyA6DR4Gd9hWQbZtwLwJwRu86LPvOX7e2kxlwR4hlALIq7C7wbXwLUDniOBvS8SIFSiGWf6XgNcoei0ghjPe8jqIS3WvGCfy2j1efINkkCnbII(mUt8gUce(dQvl0QqPERs3sPvQMSkD7A9ALRrwTKUCRgilFgTc8jRUju93k4A1b(VvPBxdc6wflpR4hlciqY42jChceC0QjLIwhiuQhOxRyOvdKLwPpwHJwnPu06aHs9akqC4nCTIvRyGvVtH01ifagYeKSIvRYWRdCMa71FafH252TIHCTkNmVcDn)eAvwPpwXMWf6X2afCiqOnossj4tGateip5cKi7nCfiPcChhjjqsfsqsGWaRWGlHcXmjGRaZ(eIoDnAEfVt4z8F8FVa0ghjPSA8yRYqOubtVaPITFnamDf9(wXqRyJLwnESvxX7eEg)h)37etxrVVvm0kofik6Z4oXB4kqUN70vIBLdT65TzRgK0szVmTcjbtKvPBxZQ7FS9RzfkeB1nfVtyRU3)X)9kqsf45gxKaH9wk7L58tWentfB)AZN3MfUqp2gecoei0ghjPe8jqIS3WvGWElL9YC(jyIeik6Z4oXB4kqgmpzvVwXM(Wjhw1OwXNZ)w1VvGjwfRYQ0WDi3QCKyf)VeMjpgTcITkCRgih6y1TCYHowLUDnR0FkCnjpRq0cfm9FNvqSvP1O1QBkENWwDV)J)71Q(TcmbqGKXTt4oeiPcChhjbCKHIMOsqmM385TzRy1QubUJJKayVLYEzo)emrZuX2V285TzRy1kgy17uiDnsbGHmbjRy1QBTsrhquuGd5PjANUgnjE0daMyfRwDarrbuykuhzOOhqbtVwXQv0syM8aueANB3kgA1TwrlHzYdatmP1Q7hR40kDSITBy1DwnESvFcjLtpWmj)boYqrtujigZZkgA1TwXPv6JvhquuaffUMK381cfm9daMy1DwnESvxX7eEg)h)37etxrVVvm0kwA1DcxOhB3qWHaH24ijLGpbsg3oH7qGKkWDCKeWrgkAIkbXyEZN3MTIvRU1kAjmtEaEFrthoVcDzfdTItRy1QdikkGctH6idf9aky61QXJTIwcZKNvdGRvdKLwnESvFcjLtpWmj)TIHwXPv3jqIS3WvGCKHIMyWxt4c9yBWl4qGqBCKKsWNajJBNWDiqyGvVtH01ifqiLwXQvPcChhjbexhWxBMHRQ9gUcKi7nCfiVwOGPViPs4c9yt)i4qGqBCKKsWNajJBNWDiqoGOOahjeQKGVdGPi7wnESvh4)wXQvOntnFIPRO33Qby1azPvJhB1beffiuyAdzV0ed(AaGjcKi7nCfijqVHRWf6X2GtWHajYEdxbYrcHQjkiMNaH24ijLGpHl0JTbvbhcKi7nCfihc)eM9EzkqOnossj4t4c94KLcoeir2B4kqqBmDKqOsGqBCKKsWNWf6XjBcoeir2B4kqIntVJd5mhsPaH24ijLGpHl0JtofCiqOnossj4tGezVHRaXX9Yo5Sjqu0NXDI3WvGO)eAakDRYWv1Ed33kui2kWposYQ2PRhqGKXTt4oeik6aIIcCipnr701OjXJEaWeRgp2kh3l7Kd4SbOf)e8P5bef1QXJT6a)3kwTcTzQ5tmDf9(wnaUwXjlfUqpohOGdbcTXrskbFcKmUDc3HarrhquuGd5PjANUgnjE0daMy14Xw54EzNCaNtaT4NGpnpGOOwnESvh4)wXQvOntnFIPRO33QbW1kozPajYEdxbIJ7LDY5u4cxG8ofsxtWHqp2eCiqOnossj4tGKXTt4oeiPcChhjbG2B)AZmCvT3WvGezVHRar1Fs4znHl0JtbhcKi7nCfiX1b81ei0ghjPe8jCHEduWHaH24ijLGpbsK9gUcKSgfjZxd6cKmUDc3HaXdjToqcM4nH701OzAkyhG24ijLvSAfdSYdmtYb6FEG)lqY8YsA6bMj5Vqp2eUWfiO92VMGdHESj4qGqBCKKsWNajYEdxbYH80eTtxJMep6fik6Z4oXB4kq4Z5FRGRvziuQGPxRCOvStuIvUgzf)WTBLIoGOOwbMWOvGRK(3kxJSYdmtYTQFRIde0TYHwPAsGKXTt4oeiEGzsoG3x00HtvtwXqRgOWf6XPGdbcTXrskbFcKmUDc3Ha5aIIc8YotZyvtvNjamDf9(wnaRqBMA(etxrVVvSAfMqX0RfhjjqIS3WvG8YotZyvtvNjHl0BGcoeir2B4kqu9NeEwtGqBCKKsWNWfUWfiPi83WvOhNSKt2yP(HL3qGKoWBVmFbYG9E8x94p6nOOVwzfhAKv9vce7wHcXwnKIqdqPpKvyAqd2ysz1dViRcqhEfoPSkRflt6bSr3CVKvdc91k(b3ue2jLvdLHRcSDawyiRCOvdLHRcSDawaG24ij1qwDlB66oaBKnAWEp(RE8h9gu0xRSIdnYQ(kbIDRqHyRgkbtz41j8HSctdAWgtkRE4fzva6WRWjLvzTyzspGn6M7LS6g6Rv8dUPiStkRg6HGYtVkawyiRCOvd9qq5PxfalaqBCKKAiRULnDDhGn6M7LS6g6Rv8dUPiStkRg6HGYtVkawyiRCOvd9qq5PxfalaqBCKKAiRc3k(x)EZwDlB66oaBKnAWEp(RE8h9gu0xRSIdnYQ(kbIDRqHyRgkR(HSctdAWgtkRE4fzva6WRWjLvzTyzspGn6M7LSIt91k(b3ue2jLvdHbxcfIzsaSWqw5qRgcdUekeZKaybaAJJKudz1TCQR7aSr3CVKvduFTIFWnfHDsz1qyWLqHyMealmKvo0QHWGlHcXmjawaG24ij1qwDlB66oaB0n3lz1GqFTIFWnfHDsz1qyWLqHyMealmKvo0QHWGlHcXmjawaG24ij1qwDlB66oaB0n3lzL(rFTIFWnfHDsz1qpeuE6vbWcdzLdTAOhckp9QaybaAJJKudz1TCQR7aSr3CVKvSnq91k(b3ue2jLvdHbxcfIzsaSWqw5qRgcdUekeZKaybaAJJKudz1TSPR7aSr3CVKvCYP(Af)GBkc7KYQHCCVStoaBaSWqw5qRgYX9Yo5aoBaSWqwDlB66oaB0n3lzfNduFTIFWnfHDsz1qoUx2jhGtawyiRCOvd54EzNCaNtawyiRULnDDhGnYgnyVh)vp(JEdk6RvwXHgzvFLaXUvOqSvdDaBPAiRW0GgSXKYQhErwfGo8kCszvwlwM0dyJU5EjRgO(Af)GBkc7KYQHWGlHcXmjawyiRCOvdHbxcfIzsaSaaTXrsQHSkCR4F97nB1TSPR7aSr3CVKvdc91k(b3ue2jLvd9qq5PxfalmKvo0QHEiO80RcGfaOnossnKv3YMUUdWgzJ4qJSAiWNMTtx)qwfzVHRvPJ3Qf6wHcbxLv9ALR1Vv9vce7a2i(Zvce7KYQbVvr2B4ALSF)bSrcKpHYc94CWZsbscgI2ssGOBDBL(f0LrAR4VqMGKns362QrGsEwX2az0kozjNSzJSr6w3wXpTyzsV(AJ0TUTsFS6Mc2jRUpj9AzCG6w1RtymyIBvVwLHxNWTQrTknz1Gm47wPALvTBfkeBvkOm8wsZhktrRdyJSr6w3wX)6IYGoPS6qOqmzvgEDc3QdXS3hWQ7LZuI)wTWvF0c8fkO0Qi7nCFRGRKhGnkYEd3hibtz41jCUrsIK3mb2pCTrr2B4(ajykdVoHRd3Hpq3LKAIkdEKkDVmNoux9AJIS3W9bsWugEDcxhUd)ofsxZgfzVH7dKGPm86eUoCh(kWStQjkepvu4AmMGPm86e(8PmCvp3BWyJYfhTAsPO1bcL6b6LHCEdBuK9gUpqcMYWRt46WDyuj9AzCG6m2OCFiO80Rcib8DqjnjmyI3WD84hckp9QasbLH3sA(qzkADBuK9gUpqcMYWRt46WDymukNUgnpWLEgtWugEDcF(ugUQNlNm2OCX0v07pGbAJIS3W9bsWugEDcxhUd)YotZyvtvNjgtWugEDcF(ugUQNlNm2OCXekMET4ijBKns362k(xxug0jLvukcZZkVViRCnYQi7qSv9BvKkAzCKeGnkYEd3Nl7DMDBKUTI)sVtH01SQrTkb(FFKKv3UqRsbkxchhjzfT0vtVv9AvgEDc)oBuK9gUVoCh(DkKUMns3wXFjmukT67LPKS6aII(wrbwYZkORryRCTyTIdmizfFuG7LPvXQSIpmmuFRiBuK9gUVoChovG74ijg34I4I9ZetyOuYyQqcsCX(zEarr)bWjR3YGdikkGJbP5HcCVmbatyLbhquuGdggQVveayYD2iDBf)VpiMSknzftYTcfukT6ExhWxZk(XIwXm69TkwLvbM2HCRWegkL9Y0k(bbx3kxJSs)QuVvhqu03QiDWZgfzVH7Rd3Htf4oosIXnUiUX1b81Mz4QAVHlJPcjiXndVoWzcSx)bueANBNHC5uNdikkWbdd13kcamHvAjmtEmK7nyjR3YGmCvGTdKHGRpDnAcvQF84dikkagkLtxJMh4spaMUIEFgYLnwENns3wDF92VMvHB1vOlRsG)3hjzf)yrRs3Uge0TcMIWOsy6EzA1bUGVvz41bAvcSx)z0kWvs)BfkeBfFo)BvAToRzvith8EREniOuz1HS6g6yf)yrBuK9gUVoChovG74ijg34I4I2B)AZmCvT3WLXuHeK4MHxh4mb2R)mKBozEf6A(j0Q0NdikkWbdd13kcamrFU9aIIcatsGyhCBNhayY9JhsADGbnyNzFQWrAaAJJKu3nEmHIszVtrZm86aNjWE9NHCZjZRqxZpHwLns3wDpz6G3Bv4oDL4w5qRaFYk(C(3QWT6g6yf)yrgTctmdSss)Bfe1k(XIwXKwRshVt2Oi7nCFD4oCQa3XrsmUXfXfT3(1Mz4QAVHlJWeUy6jNXgLBgcLky6f4qEAI2PRrtIh9ayku8yLqrPS3POzgEDGZeyV(pGByJ0Tvd221S6cu6DIKSYdmtYFgTY163QubUJJKSQFRYAuMDszLdTsr5wrwLwJCncB1dViR4N()w9AqqPYQdz1ZBZKYQ0TRzfFYqrwDFsqmMNnkYEd3xhUdNkWDCKeJBCrCpYqrtujigZB(82mJPcjiX9tiPC6bMj5pWrgkAIkbXyEdGtwXrRMukADGqPEGEziNSC84dikkWrgkAIkbXyEay6k69ziB64HKwhG9wk7L58tWebqBCKKYgfzVH7Rd3HXG7mYEd3PSFNXnUiUVtH01ySr5(ofsxJuaHuAJIS3W91H7W5qkNr2B4oL97mUXfXnREBuK9gUVoChgdUZi7nCNY(Dg34I4I2B)Am2OCtf4ooscaT3(1Mz4QAVHRnkYEd3xhUdNdPCgzVH7u2VZ4gxe3dylv2Oi7nCFD4oCGZXsthIX06m2OCPLWm5bOi0o3od5Y2n0HwcZKhaMysRnkYEd3xhUdh4CS0mbu(KnkYEd3xhUdlBMA(phKbvmVO1Trr2B4(6WD4tWCcrNoUZS)2iBKU1Tv8b2sfHFBuK9gUpWbSLkUpL89BJIS3W9boGTuPd3HzQbFxYB(oUzNSrr2B4(ahWwQ0H7WVwNIXgLlgCjuiMjb49YB6qD155rgkYgfzVH7dCaBPshUdtznyVmNykb3xXQySr5YGhckp9QaiuuWVtrZy7Ryg5mjjC4q84XPcChhjbCKHIMOsqmM385TzBKUT6EjjsEwHWhIvo0QqkTYdmtYFRs3Uge0TkSsrhquuRI3QeCdXTZJrRsWekHX9Y0kpWmj)TsXRxMw9q4syRcuNWw5AKvj4(kW8SYdmtYTrr2B4(ahWwQ0H7WpHXHtQ5bU08tA2jgBuUmqbDGNW4Wj18axA(jn70ubDaVZS3ltBuK9gUpWbSLkD4o8tyC4KAEGln)KMDIXmVSKMEGzs(ZLngBuUmqbDGNW4Wj18axA(jn70ubDaVZS3ltBKUT6EUtxjUvo0kWNSkTgTw1UvPBP0QCKyvgEDGwLa71FRIvzfYQ)w1Vvky6LrRGUgHt3pzf7eLyfkgEzvoss6LPvzTaZKEBuK9gUpWbSLkD4o8tyC4KAEGln)KMDIXgLlAZuZNy6k69ha3BmECgcLky6f4jmoCsnpWLMFsZobCf6AM1cmt61NSwGzs)efhzVHBihaxwcW5ngpodVoWzcSx)bueANBNBozYm6LvgCarrbE2bLYzSQzgd))ax6batyLwcZKhG3x00HZRqxmKnBKUTAW8KvSy)ouAfIg0TkD7AwPFtsGyhCBNNvnQv8dEDc3kwe60M5zvA4oKBfmfHZrIv0syM8y0Q0A0Av7wLULsRiDfzxYZQCKyf)yrgTcITkTgTwb(9Y0Q7xWoZUv6posBJIS3W9boGTuPd3Ht63HY5RbDgBuUhquuaysce7GB78aaty9wAjmtEakcTZTZWBPLWm5bGjM0QdBS8UXJZWRdCMa71FafH252hax205aIIcCWWq9TIaatgp2djToWGgSZSpv4inaTXrsQ7Srr2B4(ahWwQ0H7Wj97q581GoJnk3dikkamjbIDWTDEaGjSE7beffGjMO9zV3FMUZSt4hamz84dikkqgUzkKKAEKGRIWhW)batUZgfzVH7dCaBPshUd)92Vt4574MDYgfzVH7dCaBPshUdZecYKySr56HKwhq1yN30XDM9hG24ijfRz41botG96pGIq7C7mKlB6CarrboyyO(wraGj2iBKU1Tv8dcLky69Tr62k(KHIS6(KGympRGRvCQJv0sxn92Oi7nCFGS65EKHIMOsqmMhJnk3pHKYPhyMK)mKlNSYGdikkWrgkAIkbXyEaGj2iDB1G57LPv376a(Aw1VvHvCoi1QEZykEIrREOv3)y7xZQCSwDiRE4f59f9wDiRaFszv8wfwb6TSDEw9jKuAf4kP)Tc87LPv3u8oHT6E)h)3RvqSv6pfUMKNviAHcM(Trr2B4(az1Rd3HtfB)Am2OCzagCjuiMjbCfy2Nq0PRrZR4DcpJ)J)7Lvg8ofsxJuaHuYAQa3XrsaX1b81Mz4QAVHlR3Yam4sOqmtcqrHRj5nFTqbt)JhFarrbuu4AsEZxluW0pGcMEzndVoWzcSx)haxoVZgPBRgSTRz1nfVtyRU3)F8FVmA1ZBZwD)JTFnRs3UMvHvO92VgHTcIT6ExhWxZkfLqRQxMwbxR4Z5FRYqOubtVmAfeBvith8ERcRq7TFncBv621S6Mq1FBuK9gUpqw96WD4ubUJJKyCJlIBQy7xBEfZmCvT3WLXgLlgCjuiMjbCfy2Nq0PRrZR4DcpJ)J)7Lvg4HKwh4kWStQjkepvu4Aa0ghjPymvibjU3YGmekvW0lWH80eTtxJMep6bWuO4XAQa3XrsaO92V2mdxv7nCVB84BZqOubtVahYtt0oDnAs8OhatHIhRPcChhjbexhWxBMHRQ9gU3zJIS3W9bYQxhUdNkWDCKeJBCrCtfB)AZRyMHRQ9gUm2OCXGlHcXmjGRaZ(eIoDnAEfVt4z8F8FVS6HKwh4kWStQjkepvu4Aa0ghjPymvibjUPcChhjbG2B)AZmCvT3W1gfzVH7dKvVoChovS9RXyJYnvG74ijGuX2V28kMz4QAVHlRxX7eEg)h)37etxrVpxwYAQa3XrsahzOOjQeeJ5nFEB2gfzVH7dKvVoChouyAdzV0ed(Am2OCzWbeffiuyAdzV0ed(AaGj2iDB19jPxlJdu3kui2kwe8Dqjzf)Jbt8gUw1OwTq3Q3Pq6AKYQyvwTq3Q0TRzfFYqrwDFsqmMNnkYEd3hiRED4omQKETmoqDgBuU3(qq5Pxfqc47GsAsyWeVH74XpeuE6vbKckdVL08HYu063XkdENcPRrkGqkz9wgCarrboYqrtujigZdamz84pHKYPhyMK)ahzOOjQeeJ5naoVJ1BzWbeffiuyAdzV0ed(AaGjJhtlHzYdW7lA6W5vOlgY5Dm2RtymyIp7Rls1HtCzJXEDcJbt8jtj8esUSXyVoHXGj(Sr5(qq5PxfqkOm8wsZhktrRBJIS3W9bYQxhUdJkdMKugEdxgBuUm4DkKUgPacPK1Btf4ooscaT3(1Mz4QAVH74XEGzsoG3x00HtvtdGTbENnkYEd3hiRED4oSctH6idf9m2OCzW7uiDnsbesjRz41botG96)a4YjR3YGmmfTX6aPO114HhpwrhquuauzWKKYWB4caMCNnkYEd3hiRED4omgkLtxJMh4spJnk3R4DcpJ)J)7DIPRO3Nllz9aIIcOWuOoYqrpGcMEz92dikkagkLtxJMh4spaMUIE)bWDGJhNkWDCKea2ptmHHs5D2iDBf)b1QqPERcmzfycJw9BNqw5AKvWLSkD7AwjHPP3TIdo0FaRgmpzvAnATsXRxMwHgVtyRCTyTIFSOvkcTZTBfeBv621GGUvXYZk(XIa2Oi7nCFGS61H7WxbMDsnrH4PIcxJrzV0mR4YgWnymZllPPhyMK)CzJXgLloA1KsrRdek1daMW6TEGzsoG3x00HtvtdidVoWzcSx)bueANBF8yg8ofsxJuayitqI1m86aNjWE9hqrODUDgYnNmVcDn)eAv6dB3zJ0Tv8huRwOvHs9wLULsRunzv62161kxJSAjD5wnqw(mAf4twDtO6VvW1Qd8FRs3Uge0TkwEwXpweWgfzVH7dKvVoCh(kWStQjkepvu4Am2OCXrRMukADGqPEGEz4azP(GJwnPu06aHs9akqC4nCzLbVtH01ifagYeKyndVoWzcSx)bueANBNHCZjZRqxZpHwL(WMns3wDp3PRe3khA1ZBZwniPLYEzAfscMiRs3UMv3)y7xZkui2QBkENWwDV)J)71gfzVH7dKvVoChovG74ijg34I4YElL9YC(jyIMPITFT5ZBZmMkKGexgGbxcfIzsaxbM9jeD6A08kENWZ4)4)EhpodHsfm9cKk2(1aW0v07Zq2y54XxX7eEg)h)37etxrVpd50gPBRgmpzvVwXM(Wjhw1OwXNZ)w1VvGjwfRYQ0WDi3QCKyf)VeMjpgTcITkCRgih6y1TCYHowLUDnR0FkCnjpRq0cfm9FNvqSvP1O1QBkENWwDV)J)71Q(TcmbWgfzVH7dKvVoChM9wk7L58tWeXyJYnvG74ijGJmu0evcIX8MpVnZAQa3XrsaS3szVmNFcMOzQy7xB(82mRm4DkKUgPaWqMGeR3QOdikkWH80eTtxJMep6baty9aIIcOWuOoYqrpGcMEzLwcZKhGIq7C7m8wAjmtEayIjT3pCQdB34UXJ)eskNEGzs(dCKHIMOsqmMhdVLt95aIIcOOW1K8MVwOGPFaWK7gp(kENWZ4)4)ENy6k69zilVZgfzVH7dKvVoCh(idfnXGVgJnk3ubUJJKaoYqrtujigZB(82mR3slHzYdW7lA6W5vOlgYjRhquuafMc1rgk6buW074X0syM8ga3bYYXJ)eskNEGzs(ZqoVZgfzVH7dKvVoCh(1cfm9fjvm2OCzW7uiDnsbesjRPcChhjbexhWxBMHRQ9gU2Oi7nCFGS61H7WjqVHlJnk3dikkWrcHkj47aykY(4Xh4)SI2m18jMUIE)bmqwoE8beffiuyAdzV0ed(AaGj2Oi7nCFGS61H7WhjeQMOGyE2Oi7nCFGS61H7Whc)eM9EzAJIS3W9bYQxhUdJ2y6iHqLnkYEd3hiRED4oCSz6DCiN5qkTr62k9NqdqPBvgUQ2B4(wHcXwb(Xrsw1oD9a2Oi7nCFGS61H7WoUx2jNngBuUk6aIIcCipnr701OjXJEaWKXJDCVStoaBaAXpbFAEarrhp(a)Nv0MPMpX0v07paUCYsBuK9gUpqw96WDyh3l7KZjJnkxfDarrboKNMOD6A0K4rpayY4XoUx2jhGtaT4NGpnpGOOJhFG)ZkAZuZNy6k69haxozPnYgPBDB191B)Ae(Tr62k(C(3k4AvgcLky61khAf7eLyLRrwXpC7wPOdikQvGjmAf4kP)TY1iR8aZKCR63Q4abDRCOvQMSrr2B4(aO92Vg3d5PjANUgnjE0ZyJY1dmtYb8(IMoCQAIHd0gfzVH7dG2B)A6WD4x2zAgRAQ6mXyJY9aIIc8YotZyvtvNjamDf9(daTzQ5tmDf9(SIjum9AXrs2Oi7nCFa0E7xthUdR6pj8SMnYgPBDBfItH01Srr2B4(aVtH014Q6pj8SgJnk3ubUJJKaq7TFTzgUQ2B4AJIS3W9bENcPRPd3HJRd4RzJIS3W9bENcPRPd3HZAuKmFnOZyMxwstpWmj)5YgJnkxpK06ajyI3eUtxJMPPGDaAJJKuSYapWmjhO)5b(VWfUqa]] )
    

end