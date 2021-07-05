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
        if active_enemies == 1 then return end
        if this_action == "marked_for_death" and target.time_to_die > 3 + Hekili:GetLowestTTD() then return "cycle" end
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


    spec:RegisterPack( "Outlaw", 20210705, [[d8uplbqiuKEejPUKcePnHs6tQenkvQCkvkTkfiPxrsmluu3IKkTla)sLWWqjCmuQwgQkptbQPPsv11ua2MkfY3iPIghkrPZPsHY6iPkZtb09qL2hkIdQsvwiQOhIQQMijv1frvL2Okf1hvGeNKKkSsf0lvGiMPkvLBQsr2jjLFQaHHIsKJQsHQLIsu9uiMkQWvvPaBfLO4RQuqJfvvSxc)vrdw0HfwSkESKMmPUmYMH0NrHrtItl1QvGOEnkLzt0TvODR0VbnCjCCfi1YH65QA6uDDG2Ue57suJNKKZJQmFvs7NYc2fCiq0Htc14Jf8XoluNSyaaSGL9(V)bmabIZRGeifrLTGbjq2yKeidcqxgLfifbpjm0coeipeexjbII7fV6DXfmAxb8auHJx89iOm8gUvCG6x89y9cbYbSLU6yfhbIoCsOgFSGp2zH6KfdaGfSS3)9F)3ibsa6kqSabPh5VarP1AAfhbIM(Qazqa6YOSLSCidqYgoeuYZYbWSL8Xc(y3gAd5VsSmOx9SHQRL3uWgz5nlPxPIdu3YEDcJblCl71YkC8eULnQLLjlhKbF3sDRTSDlrHyllbLH3sA(qzjADabISF)fCiq0eAakDbhc1yxWHajQEdxbcBDLnbcTXrsAbNcxOgFcoei0ghjPfCkq00xXDH3WvGWYP3Pq6kw2Owwa)VpsYY7wOLLaLlHJJKSKwASP3YETSchpHFRajQEdxbY7uiDfHluBWcoei0ghjPfCkqGfcKNCbsu9gUcKsbUJJKeiLcjijqW(zEarrFlhOL8zjRwENLm1YdikkGJbP5HcCVmaalSKvlzQLhquuGdgg6V1eayHL3kq00xXDH3WvGWYjmukT87LHKS8aII(wsbwYZsORqylDLyTKdmizjNuG7LHLXQTKtmm0FRjbsPap3yKeiy)mXegkLcxO29l4qGqBCKKwWPabwiqEYfir1B4kqkf4oossGukKGKaPchpWzbSx)b0eAxB3sMW1s(SuflpGOOahmm0FRjaWclz1sAjmdEwYeUwoawyjRwENLm1YkC1GTduHGRpDfAc16hG24ijTLxVA5beffadLYPRqZdCPhatJrVVLmHRLSZclVvGOPVI7cVHRaHF3hetwwMSKb5wIckLwEVXd4Ryj)zjlze9(wgR2Yat7LULycdLYEzyj)HGRBPRqwoi063Ydik6Bzuo4jqkf45gJKajgpGVYScxD7nCfUqTbi4qGqBCKKwWPabwiqEYfir1B4kqkf4oossGukKGKaPchpWzbSx)TKjCTSwmhdvn)cA1wQUwEarrboyyO)wtaGfwQUwENLhquuayrbe7GB78aalSCq1spK06adAWUY2uJJYa0ghjPT8wlVE1scfLQExIMv44bolG96VLmHRL1I5yOQ5xqRwGOPVI7cVHRa5M7TFfld3YXqvwwa)VpsYs(ZswwUDfiOBjSeHrLWY9YWYdCbFlRWXd0YcyV(ZSLGRK(3sui2soD(1YYkDvXYqwo49w(kqqP2Ydz5auXs(ZscKsbEUXijqq7TFLzfU62B4kCHA3ibhceAJJK0cofiWcbcMEYfir1B4kqkf4oossGukWZngjbcAV9RmRWv3Edxbsf3oH7qGuHqPgwEboKxMOD6k0K4rpaMcnplz1scfLQExIMv44bolG96VLd0Ybiq00xXDH3WvGCpz5G3Bz4onw4w6qlbFYsoD(1YWTCaQyj)zjMTetmcSws)Bje1s(ZswYGwllhVtcxOM6uWHaH24ijTGtbcSqG8KlqIQ3WvGukWDCKKaPuibjbYxqs50dmdYFGJm00evcIX8SCGwYNLSAjoA9KkrRdeA9d0RLmXs(yHLxVA5beff4idnnrLGympamng9(wYelz3svS0djToaBTu2lJ5xGjcG24ijTartFf3fEdxbYnSDflhbLExijl9aZG8NzlDL(TSuG74ijl73YQcvzJ0w6ql1uT1KLLvixHWw(WrYs(R(VLVceuQT8qw(82kPTSC7kwYPm0KL3SeeJ5jqkf45gJKa5idnnrLGymV5ZBRcxOglRGdbcTXrsAbNcKkUDc3Ha5DkKUcPbcPuGevVHRabdUZO6nCNY(DbISFFUXijqENcPRiCHA3ycoei0ghjPfCkqIQ3WvGudPCgvVH7u2VlqK97Zngjbsv)cxOg7SqWHaH24ijTGtbsf3oH7qGukWDCKeaAV9RmRWv3Edxbsu9gUcem4oJQ3WDk73fiY(95gJKabT3(veUqn2zxWHaH24ijTGtbsu9gUcKAiLZO6nCNY(DbISFFUXijqoGTulCHASZNGdbcTXrsAbNcKkUDc3HaHwcZGhGMq7A7wYeUwY(aSuflPLWm4bGjg0kqIQ3WvGe4AS00HymTUWfQX(GfCiqIQ3WvGe4AS0Sau(KaH24ijTGtHluJ97xWHajQEdxbISzO4)CqguZyKwxGqBCKKwWPWfQX(aeCiqIQ3WvGCcgti60XDLTxGqBCKKwWPWfUaPatv44jCbhc1yxWHajQEdxbsuui5nlG9dxbcTXrsAbNcxOgFcoeir1B4kqoq3LKEIkdEKUCVmMouv9kqOnossl4u4c1gSGdbsu9gUcK3Pq6kceAJJK0cofUqT7xWHaH24ijTGtbsu9gUcKXaZgPNOq8utHRiqQ42jChceC06jvIwhi06hOxlzIL8nabsbMQWXt4ZNQWv)cKbiCHAdqWHaH24ijTGtbsf3oH7qG8qq5Pxnqb47GsAsyWcVHlaTXrsAlVE1Yhckp9QbkbLH3sA(qzjADaAJJK0cKO6nCfiOs6vQ4a1fUqTBKGdbcTXrsAbNcKO6nCfiyOuoDfAEGl9cKkUDc3HabtJrVVLd0YblqkWufoEcF(ufU6xGWNWfQPofCiqOnossl4uGevVHRa5LDLMXQN6UscKkUDc3HabtOy6vIJKeifyQchpHpFQcx9lq4t4cxGCaBPwWHqn2fCiqIQ3WvG8uX3VaH24ijTGtHluJpbhcKO6nCfimuGVl5nFh3SrceAJJK0cofUqTbl4qGqBCKKwWPaPIBNWDiqWGlHcXmiaVxEthQQUopYqta0ghjPfir1B4kqELUKWfQD)coeir1B4kqOQcSxgtmvG7Xy1ceAJJK0cofUqTbi4qGqBCKKwWPajQEdxbYtyC4KEEGln)IMnsGOPVI7cVHRa5EffsEwIWjILo0YqkT0dmdYFll3Uce0TmSuthquulJ3YcCdXTZJzllWekHX9YWspWmi)TuZRxgw(q4sylduNWw6kKLf4EmW8S0dmdYfivC7eUdbctTudDGNW4Wj98axA(fnB0udDaVRS1ldHlu7gj4qGqBCKKwWPajQEdxbYtyC4KEEGln)IMnsGuXTt4oeim1sn0bEcJdN0ZdCP5x0Srtn0b8UYwVmeivEvjn9aZG8xOg7cxOM6uWHaH24ijTGtbsu9gUcKNW4Wj98axA(fnBKartFf3fEdxbY9CNglClDOLGpzzzfATSDll3sPL1OWYkC8aTSa2R)wgR2sKv9TSFl1WYlZwcDfcxUFYs2iQWsumC0YAuu0ldlRkbMb9cKkUDc3HabTzO4tmng9(woqUwoalVE1Ykek1WYlWtyC4KEEGln)IMncymu1SQeyg0BP6AzvjWmOFIIJQ3WnKwoqUwYca(gGLxVAzfoEGZcyV(dOj0U2ULCTSwmze9AjRwYulpGOOapBGs5mw9SIH)FGl9aGfwYQL0syg8a8EKMoCogQYsMyj7cxOglRGdbcTXrsAbNcKO6nCfif97q58vGUartFf3fEdxbYn4jlzP(DO0sefOBz52vSCquuaXo42oplBul5pC8eULSe0PTYZYYW9s3syjcxJclPLWm4XSLLvO1Y2TSClLwsQkQUKNL1OWs(ZsmBjeBzzfATe87LHL34GDLnlvFCuwGuXTt4oeihquuayrbe7GB78aalSKvlVZsAjmdEaAcTRTBjtS8olPLWm4bGjg0APkwYolS8wlVE1YkC8aNfWE9hqtODTDlhixlz3svS8aIIcCWWq)TMaalS86vl9qsRdmOb7kBtnokdqBCKK2YBfUqTBmbhceAJJK0cofivC7eUdbYbeffawuaXo42opaWclz1Y7S8aIIcWat0(S17pl3v2i8dawy51RwEarrbQWTsHK0ZJeC1e(a(payHL3kqIQ3WvGu0VdLZxb6cxOg7SqWHajQEdxbY3B)oHNVJB2ibcTXrsAbNcxOg7Sl4qGqBCKKwWPaPIBNWDiq8qsRdOBSZB64UY2dqBCKK2swTSchpWzbSx)b0eAxB3sMW1s2TuflpGOOahmm0FRjaWcbsu9gUcegqqgKWfUaPQFbhc1yxWHaH24ijTGtbsu9gUcKJm00evcIX8eiA6R4UWB4kq4ugAYYBwcIX8SeUwYNkwsln20lqQ42jChcKVGKYPhygK)wYeUwYNLSAjtT8aIIcCKHMMOsqmMhayHWfQXNGdbcTXrsAbNcKO6nCfiLITFfbIM(kUl8gUcKBW3ldlV34b8vSSFldl5BqQL9wXu8eZw(qlzzITFflRXA5HS8HJK3J0B5HSe8jTLXBzyjO3Y25z5xqsPLGRK(3sWVxgwEtX7e2Y79F8FVwcXwQ(u4ksEwIOeAy5xGuXTt4oeim1sm4sOqmdcymWSnHOtxHMJX7eEg)h)3laTXrsAlz1sMA57uiDfsdesPLSAzPa3XrsaX4b8vMv4QBVHRLSA5DwYulXGlHcXmianfUIK38vcnS8dqBCKK2YRxT8aIIcOPWvK8MVsOHLFanS8AjRwwHJh4Sa2R)woqUwYNL3kCHAdwWHaH24ijTGtbcSqG8KlqIQ3WvGukWDCKKaPuGNBmscKsX2VYCmMv4QBVHRaPIBNWDiqWGlHcXmiGXaZ2eIoDfAogVt4z8F8FVa0ghjPTKvlzQLEiP1bgdmBKEIcXtnfUcaTXrsAbIM(kUl8gUcKBy7kwEtX7e2Y79)h)3lZw(82QLSmX2VILLBxXYWs0E7xHWwcXwEVXd4RyPMkOv3ldlHRLC68RLviuQHLxMTeITmKLdEVLHLO92VcHTSC7kwEtOQVaPuibjbYDwYulRqOudlVahYlt0oDfAs8OhatHMNLSAzPa3XrsaO92VYScxD7nCT8wlVE1Y7SScHsnS8cCiVmr70vOjXJEamfAEwYQLLcChhjbeJhWxzwHRU9gUwERWfQD)coei0ghjPfCkqGfcKNCbsu9gUcKsbUJJKeiLcjijqkf4ooscaT3(vMv4QBVHRaPIBNWDiqWGlHcXmiGXaZ2eIoDfAogVt4z8F8FVa0ghjPTKvl9qsRdmgy2i9efINAkCfaAJJK0cKsbEUXijqkfB)kZXywHRU9gUcxO2aeCiqOnossl4uGuXTt4oeiLcChhjbuk2(vMJXScxD7nCTKvlhJ3j8m(p(V3jMgJEFl5AjlSKvllf4oosc4idnnrLGymV5ZBRcKO6nCfiLITFfHlu7gj4qGqBCKKwWPaPIBNWDiqyQLhquuGqJPnK9stm4RaawiqIQ3WvGeAmTHSxAIbFfHlutDk4qGqBCKKwWPartFf3fEdxbYnlPxPIdu3sui2swc8Dqjzj)Ibl8gUw2OwUq3Y3Pq6kK2Yy1wUq3YYTRyjNYqtwEZsqmMNaPIBNWDiqUZYhckp9QbkaFhustcdw4nCbOnossB51Rw(qq5PxnqjOm8wsZhklrRdqBCKK2YBTKvlzQLVtH0vinqiLwYQL3zjtT8aIIcCKHMMOsqmMhayHLxVA5xqs50dmdYFGJm00evcIX8SCGwYNL3AjRwENLm1YdikkqOX0gYEPjg8vaalS86vlPLWm4b49inD4CmuLLmXs(S8wbsVoHXGf(SrfipeuE6vduckdVL08HYs06cKEDcJbl8zpos6oCsGWUajQEdxbcQKELkoqDbsVoHXGf(KHeEcPaHDHluJLvWHaH24ijTGtbsf3oH7qGWulFNcPRqAGqkTKvlVZYsbUJJKaq7TFLzfU62B4A51Rw6bMb5aEpstho1nz5aTK9bB5TcKO6nCfiOYGbjLH3Wv4c1UXeCiqOnossl4uGuXTt4oeim1Y3Pq6kKgiKslz1YkC8aNfWE93YbY1s(SKvlVZsMAzfwI2yDGs06k8WwE9QLA6aIIcGkdgKugEdxaWclVvGevVHRarJPqFKHMEHluJDwi4qGqBCKKwWPaPIBNWDiqgJ3j8m(p(V3jMgJEFl5AjlSKvlpGOOaAmf6Jm00dOHLxlz1Y7S8aIIcGHs50vO5bU0dGPXO33YbY1YbB51RwwkWDCKea2ptmHHsPL3kqIQ3WvGGHs50vO5bU0lCHASZUGdbcTXrsAbNcKO6nCfiJbMnsprH4PMcxrGi7LMvTaHDGbiqQ8QsA6bMb5Vqn2fivC7eUdbcoA9KkrRdeA9dawyjRwENLEGzqoG3J00HtDtwoqlRWXdCwa71FanH212T86vlzQLVtH0vinagYaKSKvlRWXdCwa71FanH212TKjCTSwmhdvn)cA1wQUwYUL3kq00xXDH3WvGOoqTm063YatwcwWSL)2fKLUczjCjll3UILsyz6Dl5Gd1hWYBWtwwwHwl186LHLOX7e2sxjwl5plzPMq7A7wcXwwUDfiOBzS8SK)SeGWfQXoFcoei0ghjPfCkqIQ3WvGmgy2i9efINAkCfbIM(kUl8gUce1bQLl0YqRFll3sPL6MSSC7k9APRqwUKQClhmlEMTe8jlVju13s4A5b(VLLBxbc6wglpl5plbiqQ42jChceC06jvIwhi06hOxlzILdMfwQUwIJwpPs06aHw)aAqC4nCTKvlzQLVtH0vinagYaKSKvlRWXdCwa71FanH212TKjCTSwmhdvn)cA1wQUwYUWfQX(GfCiqOnossl4uGaleip5cKO6nCfiLcChhjjqkfsqsGWulXGlHcXmiGXaZ2eIoDfAogVt4z8F8FVa0ghjPT86vlRqOudlVaLITFfamng9(wYelzNfwE9QLJX7eEg)h)37etJrVVLmXs(eiA6R4UWB4kqUN70yHBPdT85TvlhK0szVmSePatKLLBxXswMy7xXsui2YBkENWwEV)J)7vGukWZngjbcBTu2lJ5xGjAwk2(vMpVTkCHASF)coei0ghjPfCkqIQ3WvGWwlL9Yy(fyIeiA6R4UWB4kqUbpzzVwYU6Yhhw2OwYPZVw2VLGfwgR2YYW9s3YAuyj)UeMbpMTeITmClhmhQy5D8XHkwwUDflvFkCfjplrucnS8FRLqSLLvO1YBkENWwEV)J)71Y(TeSaqGuXTt4oeiLcChhjbCKHMMOsqmM385Tvlz1YsbUJJKayRLYEzm)cmrZsX2VY85Tvlz1sMA57uiDfsdGHmajlz1Y7SuthquuGd5LjANUcnjE0dawyjRwEarrb0yk0hzOPhqdlVwYQL0syg8a0eAxB3sMy5DwslHzWdatmO1Ybvl5ZsvSK9by5TwE9QLFbjLtpWmi)boYqttujigZZsMy5DwYNLQRLhquuanfUIK38vcnS8dawy5TwE9QLJX7eEg)h)37etJrVVLmXswy5TcxOg7dqWHaH24ijTGtbsf3oH7qGukWDCKeWrgAAIkbXyEZN3wTKvlVZsAjmdEaEpsthohdvzjtSKplz1YdikkGgtH(idn9aAy51YRxTKwcZGNLdKRLdMfwE9QLFbjLtpWmi)TKjwYNL3kqIQ3WvGCKHMMyWxr4c1y)gj4qGqBCKKwWPaPIBNWDiqyQLVtH0vinqiLwYQLLcChhjbeJhWxzwHRU9gUcKO6nCfiVsOHLhjPw4c1yxDk4qGqBCKKwWPaPIBNWDiqoGOOahjeQLGVdGPO6wE9QLh4)wYQLOndfFIPXO33YbA5GzHLxVA5beffi0yAdzV0ed(kaGfcKO6nCfifqVHRWfQXolRGdbsu9gUcKJec1tuqmpbcTXrsAbNcxOg73ycoeir1B4kqoe(jmB9YqGqBCKKwWPWfQXhleCiqIQ3WvGG2y6iHqTaH24ijTGtHluJp2fCiqIQ3WvGeBLEhhYznKsbcTXrsAbNcxOgF8j4qGqBCKKwWPajQEdxbIJ7LnYzxGOPVI7cVHRar9j0au6wwHRU9gUVLOqSLGFCKKLTtJpGaPIBNWDiq00beff4qEzI2PRqtIh9aGfwE9QLoUx2ihWzhqj(j4tZdikQLxVA5b(VLSAjAZqXNyAm69TCGCTKpwiCHA8nybhceAJJK0cofivC7eUdbIMoGOOahYlt0oDfAs8OhaSWYRxT0X9Yg5aoFakXpbFAEarrT86vlpW)TKvlrBgk(etJrVVLdKRL8Xcbsu9gUceh3lBKZNWfUa5DkKUIGdHASl4qGqBCKKwWPaPIBNWDiqkf4ooscaT3(vMv4QBVHRajQEdxbIU)IWRkcxOgFcoeir1B4kqIXd4RiqOnossl4u4c1gSGdbcTXrsAbNcKO6nCfivfkkMVc0fivC7eUdbIhsADGcmXBc3PRqZYuWgaTXrsAlz1sMAPhygKd0)8a)xGu5vL00dmdYFHASlCHlqq7TFfbhc1yxWHaH24ijTGtbsu9gUcKd5LjANUcnjE0lq00xXDH3WvGWPZVwcxlRqOudlVw6qlzJOclDfYs(JB3snDarrTeSGzlbxj9VLUczPhygKBz)wghiOBPdTu3KaPIBNWDiq8aZGCaVhPPdN6MSKjwoyHluJpbhceAJJK0cofivC7eUdbYbeff4LDLMXQN6UsayAm69TCGwI2mu8jMgJEFlz1smHIPxjossGevVHRa5LDLMXQN6UscxO2GfCiqIQ3WvGO7Vi8QIaH24ijTGtHlCHlqkr4VHRqn(ybFSZc1jlyxGuoWBVmEbYn8ESC1uhQnOOEwAjhkKL9ybe7wIcXwEPMqdqPFPLyAqd2ysB5dhjldqhogoPTSQeld6bSH3xVKL3V6zj)HBjc7K2YlRWvd2oa)CPLo0YlRWvd2oa)aqBCKK(slVJDvDlGn0gEdVhlxn1HAdkQNLwYHczzpwaXULOqSLxwGPkC8e(LwIPbnyJjTLpCKSmaD4y4K2YQsSmOhWgEF9swoa1Zs(d3se2jTLx(qq5Pxna)CPLo0YlFiO80RgGFaOnossFPL3XUQUfWgEF9swoa1Zs(d3se2jTLx(qq5Pxna)CPLo0YlFiO80RgGFaOnossFPLHBj)oiUplVJDvDlGn0gEdVhlxn1HAdkQNLwYHczzpwaXULOqSLxw1)LwIPbnyJjTLpCKSmaD4y4K2YQsSmOhWgEF9swYN6zj)HBjc7K2YlXGlHcXmia(5slDOLxIbxcfIzqa8daTXrs6lT8o(u1Ta2W7RxYYbREwYF4wIWoPT8sm4sOqmdcGFU0shA5LyWLqHygea)aqBCKK(slVJDvDlGn8(6LS8(vpl5pClryN0wEjgCjuiMbbWpxAPdT8sm4sOqmdcGFaOnossFPL3XUQUfWgEF9swQovpl5pClryN0wE5dbLNE1a8ZLw6qlV8HGYtVAa(bG24ij9LwEhFQ6waB491lzj7dw9SK)WTeHDsB5LyWLqHygea)CPLo0YlXGlHcXmia(bG24ij9LwEh7Q6waB491lzjF8PEwYF4wIWoPT8sh3lBKdWoa)CPLo0YlDCVSroGZoa)CPL3XUQUfWgEF9swY3Gvpl5pClryN0wEPJ7LnYb4dGFU0shA5LoUx2ihW5dGFU0Y7yxv3cydTH3W7XYvtDO2GI6zPLCOqw2JfqSBjkeB5LhWwQV0smnObBmPT8HJKLbOdhdN0wwvILb9a2W7RxYYbREwYF4wIWoPT8sm4sOqmdcGFU0shA5LyWLqHygea)aqBCKK(sld3s(DqCFwEh7Q6waBOnKdfYYlbFA2on(xAzu9gUwwoElxOBjkeC1w2RLUs)w2JfqSdydvhJfqStAlVrwgvVHRLY(9hWgkq(cQkuJVBeleifyiAljbIQvTLdcqxgLTKLdzas2qvRAlhck5z5ay2s(ybFSBdTHQw1wYFLyzqV6zdvTQTuDT8Mc2ilVzj9kvCG6w2RtymyHBzVwwHJNWTSrTSmz5Gm47wQBTLTBjkeBzjOm8wsZhklrRdydTHQw1wYVQIQGoPT8qOqmzzfoEc3YdXO3hWY7vRuH)wUWvDvc8ikO0YO6nCFlHRKhGnmQEd3hOatv44jCUrrHK3Sa2pCTHr1B4(afyQchpHRc3loq3LKEIkdEKUCVmMouv9AdJQ3W9bkWufoEcxfUx8ofsxXggvVH7duGPkC8eUkCVymWSr6jkep1u4kmxGPkC8e(8PkC1p3bWCJYfhTEsLO1bcT(b6Lj8naByu9gUpqbMQWXt4QW9cuj9kvCG6m3OCFiO80RgOa8DqjnjmyH3W961hckp9QbkbLH3sA(qzjADByu9gUpqbMQWXt4QW9cmukNUcnpWLEMlWufoEcF(ufU6NlFm3OCX0y07pWbBdJQ3W9bkWufoEcxfUx8YUsZy1tDxjMlWufoEcF(ufU6NlFm3OCXekMEL4ijBOnu1Q2s(vvuf0jTLujcZZsVhjlDfYYO6qSL9BzukAzCKeGnmQEd3NlBDLnBOQTKLtVtH0vSSrTSa(FFKKL3TqllbkxchhjzjT0ytVL9AzfoEc)wByu9gUVkCV4DkKUInu1wYYjmukT87LHKS8aII(wsbwYZsORqylDLyTKdmizjNuG7LHLXQTKtmm0FRjByu9gUVkCVOuG74ijM3yK4I9ZetyOuYCPqcsCX(zEarr)bYhR3X0dikkGJbP5HcCVmaalyLPhquuGdgg6V1eayXT2qvBj)UpiMSSmzjdYTefukT8EJhWxXs(ZswYi69TmwTLbM2lDlXegkL9YWs(dbx3sxHSCqO1VLhqu03YOCWZggvVH7Rc3lkf4oosI5ngjUX4b8vMv4QBVHlZLcjiXTchpWzbSx)b0eAxBNjC5tLdikkWbdd93AcaSGvAjmdEmH7aybR3X0kC1GTduHGRpDfAc16)61dikkagkLtxHMh4spaMgJEFMWLDwCRnu1wEZ92VILHB5yOkllG)3hjzj)zjll3Uce0TewIWOsy5Ezy5bUGVLv44bAzbSx)z2sWvs)BjkeBjNo)AzzLUQyzilh8ElFfiOuB5HSCaQyj)zjByu9gUVkCVOuG74ijM3yK4I2B)kZkC1T3WL5sHeK4wHJh4Sa2R)mHBTyogQA(f0Qv3dikkWbdd93AcaSqDV7aIIcalkGyhCBNhayXGQhsADGbnyxzBQXrzaAJJK03E9kHIsvVlrZkC8aNfWE9NjCRfZXqvZVGwTnu1wEpz5G3Bz4onw4w6qlbFYsoD(1YWTCaQyj)zjMTetmcSws)Bje1s(ZswYGwllhVt2WO6nCFv4ErPa3XrsmVXiXfT3(vMv4QBVHlZWcUy6jN5gLBfcLAy5f4qEzI2PRqtIh9ayk08yLqrPQ3LOzfoEGZcyV(pWbydvTL3W2vSCeu6DHKS0dmdYFMT0v63YsbUJJKSSFlRkuLnsBPdTut1wtwwwHCfcB5dhjl5V6)w(kqqP2Ydz5ZBRK2YYTRyjNYqtwEZsqmMNnmQEd3xfUxukWDCKeZBmsCpYqttujigZB(82kZLcjiX9liPC6bMb5pWrgAAIkbXyEdKpwXrRNujADGqRFGEzcFS461dikkWrgAAIkbXyEayAm69zc7Q4HKwhGTwk7LX8lWebqBCKK2ggvVH7Rc3lWG7mQEd3PSFN5ngjUVtH0vyUr5(ofsxH0aHuAdJQ3W9vH7f1qkNr1B4oL97mVXiXTQFByu9gUVkCVadUZO6nCNY(DM3yK4I2B)km3OClf4ooscaT3(vMv4QBVHRnmQEd3xfUxudPCgvVH7u2VZ8gJe3dyl12WO6nCFv4ErGRXsthIX06m3OCPLWm4bOj0U2ot4Y(auHwcZGhaMyqRnmQEd3xfUxe4AS0Sau(KnmQEd3xfUxiBgk(phKb1mgP1THr1B4(QW9ItWycrNoURS92qBOQvTLCc2snHFByu9gUpWbSLAUpv89BdJQ3W9boGTuRc3lyOaFxYB(oUzJSHr1B4(ahWwQvH7fVsxI5gLlgCjuiMbb49YB6qv115rgAYggvVH7dCaBPwfUxqvfyVmMyQa3JXQTHQ2Y7vui5zjcNiw6qldP0spWmi)TSC7kqq3YWsnDarrTmEllWne3opMTSatOeg3ldl9aZG83snVEzy5dHlHTmqDcBPRqwwG7XaZZspWmi3ggvVH7dCaBPwfUx8eghoPNh4sZVOzJyUr5Yun0bEcJdN0ZdCP5x0Srtn0b8UYwVmSHr1B4(ahWwQvH7fpHXHt65bU08lA2iMR8QsA6bMb5px2zUr5Yun0bEcJdN0ZdCP5x0Srtn0b8UYwVmSHQ2Y75onw4w6qlbFYYYk0Az7wwULslRrHLv44bAzbSx)TmwTLiR6Bz)wQHLxMTe6keUC)KLSruHLOy4OL1OOOxgwwvcmd6THr1B4(ahWwQvH7fpHXHt65bU08lA2iMBuUOndfFIPXO3FGChW1RviuQHLxGNW4Wj98axA(fnBeWyOQzvjWmOxDRkbMb9tuCu9gUHCGCzbaFd461kC8aNfWE9hqtODTDU1IjJOxwz6beff4zdukNXQNvm8)dCPhaSGvAjmdEaEpsthohdvXe2THQ2YBWtwYs97qPLikq3YYTRy5GOOaIDWTDEw2OwYF44jClzjOtBLNLLH7LULWseUgfwslHzWJzllRqRLTBz5wkTKuvuDjplRrHL8NLy2si2YYk0Aj43ldlVXb7kBwQ(4OSnmQEd3h4a2sTkCVOOFhkNVc0zUr5EarrbGffqSdUTZdaSG17OLWm4bOj0U2otUJwcZGhaMyqRkSZIBVETchpWzbSx)b0eAxBFGCzxLdikkWbdd93AcaS46vpK06adAWUY2uJJYa0ghjPV1ggvVH7dCaBPwfUxu0VdLZxb6m3OCpGOOaWIci2b325bawW6DhquuagyI2NTE)z5UYgHFaWIRxpGOOav4wPqs65rcUAcFa)haS4wByu9gUpWbSLAv4EX3B)oHNVJB2iByu9gUpWbSLAv4EbdiidI5gLRhsADaDJDEth3v2EaAJJK0SwHJh4Sa2R)aAcTRTZeUSRYbeff4GHH(BnbawydTHQw1wYFiuQHL33gQAl5ugAYYBwcIX8SeUwYNkwsln20BdJQ3W9bQ6N7rgAAIkbXyEm3OC)cskNEGzq(ZeU8XktpGOOahzOPjQeeJ5bawydvTL3GVxgwEVXd4Ryz)wgwY3Gul7TIP4jMT8HwYYeB)kwwJ1Ydz5dhjVhP3Ydzj4tAlJ3YWsqVLTZZYVGKslbxj9VLGFVmS8MI3jSL37)4)ETeITu9PWvK8Serj0WYVnmQEd3hOQFv4ErPy7xH5gLltXGlHcXmiGXaZ2eIoDfAogVt4z8F8FVSY03Pq6kKgiKswlf4ooscigpGVYScxD7nCz9oMIbxcfIzqaAkCfjV5ReAy5)61dikkGMcxrYB(kHgw(b0WYlRv44bolG96)a5Y3T2qvB5nSDflVP4DcB59()J)7LzlFEB1swMy7xXYYTRyzyjAV9RqylHylV34b8vSutf0Q7LHLW1soD(1Ykek1WYlZwcXwgYYbV3YWs0E7xHWwwUDflVju13ggvVH7du1VkCVOuG74ijM3yK4wk2(vMJXScxD7nCzUr5IbxcfIzqaJbMTjeD6k0CmENWZ4)4)EzLPEiP1bgdmBKEIcXtnfUcaTXrsAMlfsqI7DmTcHsnS8cCiVmr70vOjXJEamfAESwkWDCKeaAV9RmRWv3Ed3BVE9Ukek1WYlWH8YeTtxHMep6bWuO5XAPa3XrsaX4b8vMv4QBVH7T2WO6nCFGQ(vH7fLcChhjX8gJe3sX2VYCmMv4QBVHlZnkxm4sOqmdcymWSnHOtxHMJX7eEg)h)3lREiP1bgdmBKEIcXtnfUcaTXrsAMlfsqIBPa3XrsaO92VYScxD7nCTHr1B4(av9Rc3lkfB)km3OClf4ooscOuS9RmhJzfU62B4Y6y8oHNX)X)9oX0y07ZLfSwkWDCKeWrgAAIkbXyEZN3wTHr1B4(av9Rc3lcnM2q2lnXGVcZnkxMEarrbcnM2q2lnXGVcayHnu1wEZs6vQ4a1TefITKLaFhuswYVyWcVHRLnQLl0T8DkKUcPTmwTLl0TSC7kwYPm0KL3SeeJ5zdJQ3W9bQ6xfUxGkPxPIduN5gL7DpeuE6vdua(oOKMegSWB4E96dbLNE1aLGYWBjnFOSeT(TSY03Pq6kKgiKswVJPhquuGJm00evcIX8aalUE9liPC6bMb5pWrgAAIkbXyEdKVBz9oMEarrbcnM2q2lnXGVcayX1R0syg8a8EKMoCogQIj8DlZ96egdw4ZECK0D4ex2zUxNWyWcFYqcpHKl7m3RtymyHpBuUpeuE6vduckdVL08HYs062WO6nCFGQ(vH7fOYGbjLH3WL5gLltFNcPRqAGqkz9UsbUJJKaq7TFLzfU62B4E9QhygKd49inD4u30azFW3AdJQ3W9bQ6xfUxOXuOpYqtpZnkxM(ofsxH0aHuYAfoEGZcyV(pqU8X6DmTclrBSoqjADfE4Rx10beffavgmiPm8gUaGf3AdJQ3W9bQ6xfUxGHs50vO5bU0ZCJYDmENWZ4)4)ENyAm695YcwpGOOaAmf6Jm00dOHLxwV7aIIcGHs50vO5bU0dGPXO3FGCh81RLcChhjbG9ZetyOuERnu1wQoqTm063YatwcwWSL)2fKLUczjCjll3UILsyz6Dl5Gd1hWYBWtwwwHwl186LHLOX7e2sxjwl5plzPMq7A7wcXwwUDfiOBzS8SK)SeGnmQEd3hOQFv4EXyGzJ0tuiEQPWvyw2lnRAUSdmaMR8QsA6bMb5px2zUr5IJwpPs06aHw)aGfSENhygKd49inD4u30aRWXdCwa71FanH212VELPVtH0vinagYaKyTchpWzbSx)b0eAxBNjCRfZXqvZVGwT6Y(T2qvBP6a1YfAzO1VLLBP0sDtwwUDLET0vilxsvULdMfpZwc(KL3eQ6BjCT8a)3YYTRabDlJLNL8NLaSHr1B4(av9Rc3lgdmBKEIcXtnfUcZnkxC06jvIwhi06hOxMmywOU4O1tQeToqO1pGgehEdxwz67uiDfsdGHmajwRWXdCwa71FanH212zc3AXCmu18lOvRUSBdvTL3ZDASWT0Hw(82QLdsAPSxgwIuGjYYYTRyjltS9RyjkeB5nfVtylV3)X)9AdJQ3W9bQ6xfUxukWDCKeZBmsCzRLYEzm)cmrZsX2VY85TvMlfsqIltXGlHcXmiGXaZ2eIoDfAogVt4z8F8FVxVwHqPgwEbkfB)kayAm69zc7S461X4DcpJ)J)7DIPXO3Nj8zdvTL3GNSSxlzxD5JdlBul505xl73sWclJvBzz4EPBznkSKFxcZGhZwcXwgULdMdvS8o(4qfll3UILQpfUIKNLikHgw(V1si2YYk0A5nfVtylV3)X)9Az)wcwaydJQ3W9bQ6xfUxWwlL9Yy(fyIyUr5wkWDCKeWrgAAIkbXyEZN3wzTuG74ija2APSxgZVat0SuS9RmFEBLvM(ofsxH0ayidqI1700beff4qEzI2PRqtIh9aGfSEarrb0yk0hzOPhqdlVSslHzWdqtODTDMChTeMbpamXG2bv(uH9bC71RFbjLtpWmi)boYqttujigZJj3XN6Earrb0u4ksEZxj0WYpayXTxVogVt4z8F8FVtmng9(mHf3AdJQ3W9bQ6xfUxCKHMMyWxH5gLBPa3XrsahzOPjQeeJ5nFEBL17OLWm4b49inD4Cmuft4J1dikkGgtH(idn9aAy596vAjmdEdK7GzX1RFbjLtpWmi)zcF3AdJQ3W9bQ6xfUx8kHgwEKKAMBuUm9DkKUcPbcPK1sbUJJKaIXd4RmRWv3EdxByu9gUpqv)QW9IcO3WL5gL7beff4iHqTe8Damfv)61d8FwrBgk(etJrV)ahmlUE9aIIceAmTHSxAIbFfaWcByu9gUpqv)QW9IJec1tuqmpByu9gUpqv)QW9IdHFcZwVmSHr1B4(av9Rc3lqBmDKqO2ggvVH7du1VkCVi2k9ooKZAiL2qvBP6tObO0TScxD7nCFlrHylb)4ijlBNgFaByu9gUpqv)QW9ch3lBKZoZnkxnDarrboKxMOD6k0K4rpayX1RoUx2ihGDaL4NGpnpGOOxVEG)ZkAZqXNyAm69hix(yHnmQEd3hOQFv4EHJ7LnY5J5gLRMoGOOahYlt0oDfAs8OhaS46vh3lBKdWhGs8tWNMhqu0RxpW)zfTzO4tmng9(dKlFSWgAdvTQT8M7TFfc)2qvBjNo)AjCTScHsnS8APdTKnIkS0vil5pUDl10bef1sWcMTeCL0)w6kKLEGzqUL9BzCGGULo0sDt2WO6nCFa0E7xH7H8YeTtxHMep6zUr56bMb5aEpstho1nXKbBdJQ3W9bq7TFfv4EXl7knJvp1DLyUr5EarrbEzxPzS6PUReaMgJE)bI2mu8jMgJEFwXekMEL4ijByu9gUpaAV9ROc3l09xeEvXgAdvTQTeXPq6k2WO6nCFG3Pq6kC19xeEvH5gLBPa3XrsaO92VYScxD7nCTHr1B4(aVtH0vuH7fX4b8vSHr1B4(aVtH0vuH7fvfkkMVc0zUYRkPPhygK)CzN5gLRhsADGcmXBc3PRqZYuWgaTXrsAwzQhygKd0)8a)x4cxia]] )
    

end