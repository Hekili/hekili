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
        if this_action == "marked_for_death" and target.time_to_die > Hekili:GetLowestTTD() then return "cycle" end
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


    spec:RegisterPack( "Outlaw", 20210701, [[d8uWjbqiuepIKQUKcqYMqr9jfuJsLsNsLkRsbO8kuvnluIBPayxa(LcYWqj5yOuwgQWZuGmnskPRPsHTPav(McOACOKcNdLu06uGY8iPY9qL2NkvDqvkAHOQ8qskMijL6IKeAJOKsFubO6KKeyLQKEPcq0mrrIBIIK2jjPFssjgkksDufGWsjjONc0urfDvfqzRkqvFvbeJfLuTxc)vrdwYHfwSkESOMmPUmYMH0NrHrtItl1Qvas9AuQMnr3wH2Ts)g0WfXXvaPLd1Zv10P66qSDrQVlsgpjrNhvz(Qe7NYc2eCka1Htcv5GvCWgRg4SInawXAWbBCmibOZlHeGjrM9Gbja3yKeGQfexgPeGjbpjm0cofGpebNjbOI7j)Gn0qmAxb5aKHJd99iIm8gUzCG6d99yEib4bPLUkyfhbOoCsOkhSId2y1aNvSbWkwdoyJn1QamqCfiwac2JQraQ0AnTIJautFwaQwqCzKYkviKbczxVIi5zfBSyfhSId2eGY(9xWPautObI0fCkuLnbNcWi7nCfGS3z2fG0ghjPf8jCHQCi4uasBCKKwWNautFg3jEdxbOkKENcPRyvJAvc8)(ijRUDHwLgrUeoosYkAPXMER61QmC8e(DcWi7nCfGVtH0veUq1bj4uasBCKKwWNaeMiaFYfGr2B4kath4oossaMoKiKae7N5bbf9TsDwXHvmB1TwXeRoiOOaogHMhkW9YaajXkMTIjwDqqrboyyO)wtaijwDNautFg3jEdxbOkKWqP0QVxgsYQdck6BffyjpRGUcHTYvI1koXiKv8rbUxgwfR2k(WWq)TMeGPd8CJrsaI9ZetyOukCHQQvbNcqAJJK0c(eGWeb4tUamYEdxby6a3XrscW0HeHeGz44botG96pGMq7C7wDpxR4Wk(T6GGIcCWWq)TMaqsSIzROLWm4z19CT6gSYkMT6wRyIvz4QrAhidrwF6k0eQ1paTXrsARUCXQdckkagkLtxHMh4spaMgJEFRUNRvSXkRUtaQPpJ7eVHRauf3hbtwLISIb5wHIiLwDZXdYRyLAyARye9(wfR2Qat7WUvycdLYEzyLAGiRBLRqwPw063Qdck6BvKk4jath45gJKamgpiVYmdxD7nCfUq1Bi4uasBCKKwWNaeMiaFYfGr2B4kath4oossaMoKiKamdhpWzcSx)T6EUwLtMJHkNFcTARgaRoiOOahmm0FRjaKeRgaRU1QdckkamjbIDKTDEaijwnGzLhsADGbksNzFQXrkaAJJK0wDNvxUyfHIszVttZmC8aNjWE93Q75AvozogQC(j0QfGA6Z4oXB4kazT92VIvHB1yOsRsG)3hjzLAyARs1UceXTcMMWOsyQEzy1bUiVvz44bAvcSx)zXkKvs)BfkeBfFUkAvkLoRyvitf8EREfiIuB1HS6g8BLAyAby6ap3yKeGO92VYmdxD7nCfUq1bNGtbiTXrsAbFcqyIaetp5cWi7nCfGPdChhjjath45gJKaeT3(vMz4QBVHRamJBNWDiaZqOudtTahYtr0oDfAs8OhatHMNvmBfHIszVttZmC8aNjWE93k1z1neGA6Z4oXB4kaVPmvW7TkCNgtCRCOvipzfFUkAv4wDd(TsnmnlwHjgbwlP)TcIALAyARyqRvPI3jHluDGl4uasBCKKwWNaeMiaFYfGr2B4kath4oossaMoKiKa8tiPC6bMb5pWrgAAIkrWyEwPoR4WkMTchTEsPP1bcT(b61Q7TIdwz1LlwDqqrboYqttujcgZdatJrVVv3BfBwXVvEiP1byVLYEzm)emra0ghjPfGA6Z4oXB4kahiTRy1iI07ejzLhygK)SyLR0VvPdChhjzv)wLvOm7K2khALMYTMSkLc5ke2QhoswPg1(T6vGisTvhYQN3MjTvPAxXk(KHMSI1krWyEcW0bEUXijapYqttujcgZB(82SWfQYAi4uasBCKKwWNamJBNWDiaFNcPRqAGqkfGr2B4kaXi7mYEd3PSFxak73NBmscW3Pq6kcxOkRPGtbiTXrsAbFcWi7nCfG5qkNr2B4oL97cqz)(CJrsaM1VWfQYgReCkaPnossl4taMXTt4oeGPdChhjbG2B)kZmC1T3WvagzVHRaeJSZi7nCNY(DbOSFFUXijar7TFfHluLn2eCkaPnossl4tagzVHRamhs5mYEd3PSFxak73NBmscWdsl1cxOkBCi4uasBCKKwWNamJBNWDiaPLWm4bOj0o3Uv3Z1k2UHv8BfTeMbpamXGwbyK9gUcWaNJLMoeJP1fUqv2gKGtbyK9gUcWaNJLMjiYNeG0ghjPf8jCHQSPwfCkaJS3WvakBgk(phqJOzmsRlaPnossl4t4cvz7gcofGr2B4kapbJjeD64oZ(laPnossl4t4cxaMGPmC8eUGtHQSj4uagzVHRamssK8MjW(HRaK24ijTGpHluLdbNcWi7nCfGhO7ssprLbpsNQxgthQYEfG0ghjPf8jCHQdsWPamYEdxb47uiDfbiTXrsAbFcxOQAvWPaK24ijTGpbyK9gUcWXaZoPNOq8utHRiaZ42jChcqC06jLMwhi06hOxRU3koUHambtz44j85tz4QFb4neUq1Bi4uasBCKKwWNamJBNWDiaFiI80Rgib5DejnjmsI3WfG24ijTvxUy1drKNE1aPHYWBjnFOmnToaTXrsAbyK9gUcquj9kzCG6cxO6GtWPaK24ijTGpbyK9gUcqmukNUcnpWLEbyg3oH7qaIPXO33k1z1GeGjykdhpHpFkdx9la5q4cvh4cofG0ghjPf8jaJS3Wva(YotZy1tDNjbyg3oH7qaIjum9kXrscWemLHJNWNpLHR(fGCiCHlar7TFfbNcvztWPaK24ijTGpbyK9gUcWd5PiANUcnjE0la10NXDI3WvaYNRIwbxRYqOudtTw5qRyNOeRCfYk1GB3knDqqrTcjHfRqwj9VvUczLhygKBv)wfhiIBLdTs3KamJBNWDia9aZGCaVhPPdN6MS6ERgKWfQYHGtbiTXrsAbFcWmUDc3Ha8GGIc8YotZy1tDNjamng9(wPoRqBgk(etJrVVvmBfMqX0RehjjaJS3Wva(YotZy1tDNjHluDqcofGr2B4ka19NeEwrasBCKKwWNWfUamRFbNcvztWPaK24ijTGpbyK9gUcWJm00evIGX8eGA6Z4oXB4ka5tgAYkwRebJ5zfCTId(TIwASPxaMXTt4oeGFcjLtpWmi)T6EUwXHvmBftS6GGIcCKHMMOsemMhasIWfQYHGtbiTXrsAbFcWi7nCfGPJTFfbOM(mUt8gUcWb23ldRU54b5vSQFRcR4yaLv9MXu8elw9qRg8X2VIv5yT6qw9WrY7r6T6qwH8K2Q4TkScXBz78S6tiP0kKvs)BfY3ldRyQX7e2QB(F8FVwbXwP2u4ksEwbQeAyQxaMXTt4oeGmXkmYsOqmdcymWSpHOtxHMJX7eEg)h)3laTXrsARy2kMy17uiDfsdesPvmBv6a3XrsaX4b5vMz4QBVHRvmB1TwXeRWilHcXmianfUIK38vcnm1dqBCKK2QlxS6GGIcOPWvK8MVsOHPEanm1AfZwLHJh4mb2R)wPoUwXHv3jCHQdsWPaK24ijTGpbimra(KlaJS3WvaMoWDCKKamDGNBmscW0X2VYCmMz4QBVHRamJBNWDiaXilHcXmiGXaZ(eIoDfAogVt4z8F8FVa0ghjPTIzRyIvEiP1bgdm7KEIcXtnfUcaTXrsAbOM(mUt8gUcWbs7kwXuJ3jSv38)p(VxwS65TzRg8X2VIvPAxXQWk0E7xHWwbXwDZXdYRyLMsOv3ldRGRv85QOvziuQHPwwScITkKPcEVvHvO92VcHTkv7kwXurvBby6qIqcWBTIjwLHqPgMAboKNIOD6k0K4rpaMcnpRy2Q0bUJJKaq7TFLzgU62B4A1DwD5Iv3AvgcLAyQf4qEkI2PRqtIh9ayk08SIzRsh4ooscigpiVYmdxD7nCT6oHluvTk4uasBCKKwWNaeMiaFYfGr2B4kath4oossaMoKiKamDG74ija0E7xzMHRU9gUcWmUDc3HaeJSekeZGagdm7ti60vO5y8oHNX)X)9cqBCKK2kMTYdjToWyGzN0tuiEQPWvaOnosslath45gJKamDS9RmhJzgU62B4kCHQ3qWPaK24ijTGpbyg3oH7qaMoWDCKeq6y7xzogZmC1T3W1kMTAmENWZ4)4)ENyAm69TIRvSYkMTkDG74ijGJm00evIGX8MpVnlaJS3WvaMo2(veUq1bNGtbiTXrsAbFcWmUDc3HaKjwDqqrbcnM2q2lnXiVcasIamYEdxbyOX0gYEPjg5veUq1bUGtbiTXrsAbFcWi7nCfGOs6vY4a1fGA6Z4oXB4kazTs6vY4a1TcfITIPrEhrswPIyKeVHRvnQvl0T6DkKUcPTkwTvl0Tkv7kwXNm0KvSwjcgZtaMXTt4oeG3A1drKNE1ajiVJiPjHrs8gUa0ghjPT6YfREiI80RginugElP5dLPP1bOnossB1DwXSvmXQ3Pq6kKgiKsRy2QBTIjwDqqrboYqttujcgZdajXQlxS6tiPC6bMb5pWrgAAIkrWyEwPoR4WQ7SIzRU1kMy1bbffi0yAdzV0eJ8kaijwD5Iv0syg8a8EKMoCogQ0Q7TIdRUt4cvzneCkaPnossl4taMXTt4oeGmXQ3Pq6kKgiKsRy2QBTkDG74ija0E7xzMHRU9gUwD5IvEGzqoG3J00HtDtwPoRyBqwDNamYEdxbiQmyqsz4nCfUqvwtbNcqAJJK0c(eGzC7eUdbitS6DkKUcPbcP0kMTkdhpWzcSx)TsDCTIdRy2QBTIjwLHPPnwhinTUcpSvxUyLMoiOOaOYGbjLH3WfajXQ7eGr2B4ka1yk0hzOPx4cvzJvcofG0ghjPf8jaZ42jChcWX4DcpJ)J)7DIPXO33kUwXkRy2QdckkGgtH(idn9aAyQ1kMT6wRoiOOayOuoDfAEGl9ayAm69TsDCTAqwD5IvPdChhjbG9ZetyOuA1DcWi7nCfGyOuoDfAEGl9cxOkBSj4uasBCKKwWNamYEdxb4yGzN0tuiEQPWveGYEPzwlazd4gcWmVSKMEGzq(luLnbyg3oH7qaIJwpP006aHw)aijwXSv3ALhygKd49inD4u3KvQZQmC8aNjWE9hqtODUDRUCXkMy17uiDfsdGHmqiRy2QmC8aNjWE9hqtODUDRUNRv5K5yOY5NqR2QbWk2S6obOM(mUt8gUcqvaQvHw)wfyYkKewS63oHSYviRGlzvQ2vSsctrVBfNCQ2awnWEYQuk0ALMxVmScnENWw5kXALAyAR0eANB3ki2QuTRarCRILNvQHPbeUqv24qWPaK24ijTGpbyK9gUcWXaZoPNOq8utHRia10NXDI3WvaQcqTAHwfA9BvQwkTs3KvPAxPxRCfYQLuPB1Gy1ZIvipzftfvTTcUwDG)BvQ2vGiUvXYZk1W0acWmUDc3HaehTEsPP1bcT(b61Q7TAqSYQbWkC06jLMwhi06hqJGdVHRvmBftS6DkKUcPbWqgiKvmBvgoEGZeyV(dOj0o3Uv3Z1QCYCmu58tOvB1ayfBcxOkBdsWPaK24ijTGpbimra(KlaJS3WvaMoWDCKKamDiribitScJSekeZGagdm7ti60vO5y8oHNX)X)9cqBCKK2QlxSkdHsnm1cKo2(vaW0y07B19wXgRS6YfRgJ3j8m(p(V3jMgJEFRU3koeGA6Z4oXB4kaVP70yIBLdT65TzRgq2szVmScmbtKvPAxXQbFS9RyfkeBftnENWwDZ)J)7vaMoWZngjbi7Tu2lJ5NGjAMo2(vMpVnlCHQSPwfCkaPnossl4tagzVHRaK9wk7LX8tWeja10NXDI3WvaoWEYQETITbGdoTQrTIpxfTQFRqsSkwTvPG7WUv5iXkvCjmdESyfeBv4wnio53QB5Gt(Tkv7kwP2u4ksEwbQeAyQ)oRGyRsPqRvm14DcB1n)p(VxR63kKeabyg3oH7qaMoWDCKeWrgAAIkrWyEZN3MTIzRsh4ooscG9wk7LX8tWenthB)kZN3MTIzRyIvVtH0vinagYaHSIzRU1knDqqrboKNIOD6k0K4rpasIvmB1bbffqJPqFKHMEanm1AfZwrlHzWdqtODUDRU3QBTIwcZGhaMyqRvdywXHv8BfB3WQ7S6YfR(eskNEGzq(dCKHMMOsemMNv3B1TwXHvdGvheuuanfUIK38vcnm1dGKy1DwD5IvJX7eEg)h)37etJrVVv3BfRS6oHluLTBi4uasBCKKwWNamJBNWDiath4oosc4idnnrLiymV5ZBZwXSv3AfTeMbpaVhPPdNJHkT6ER4WkMT6GGIcOXuOpYqtpGgMAT6YfROLWm4zL64A1GyLvxUy1Nqs50dmdYFRU3koS6obyK9gUcWJm00eJ8kcxOkBdobNcqAJJK0c(eGzC7eUdbitS6DkKUcPbcP0kMTkDG74ijGy8G8kZmC1T3WvagzVHRa8vcnm1ij1cxOkBdCbNcqAJJK0c(eGzC7eUdb4bbff4iHqTe5Damfz3QlxS6a)3kMTcTzO4tmng9(wPoRgeRS6YfRoiOOaHgtBi7LMyKxbajragzVHRamb6nCfUqv2yneCkaJS3WvaEKqOEIIG5jaPnossl4t4cvzJ1uWPamYEdxb4HWpHzVxgcqAJJK0c(eUqvoyLGtbyK9gUcq0gthjeQfG0ghjPf8jCHQCWMGtbyK9gUcWyZ074qoZHukaPnossl4t4cv5GdbNcqAJJK0c(eGr2B4kaDCVStoBcqn9zCN4nCfGQnHgis3QmC1T3W9TcfITc5JJKSQDA8beGzC7eUdbOMoiOOahYtr0oDfAs8OhajXQlxSYX9Yo5aoBakXprEAEqqrT6YfRoW)TIzRqBgk(etJrVVvQJRvCWkHluLJbj4uasBCKKwWNamJBNWDia10bbff4qEkI2PRqtIh9aijwD5IvoUx2jhW5aqj(jYtZdckQvxUy1b(VvmBfAZqXNyAm69TsDCTIdwjaJS3Wva64EzNCoeUWfGVtH0veCkuLnbNcqAJJK0c(eGzC7eUdby6a3XrsaO92VYmdxD7nCfGr2B4ka19NeEwr4cv5qWPamYEdxbymEqEfbiTXrsAbFcxO6GeCkaPnossl4tagzVHRamRqrY8vGUamJBNWDia9qsRdKGjEt4oDfAMIc2bOnossBfZwXeR8aZGCG(Nh4)cWmVSKMEGzq(luLnHlCb4bPLAbNcvztWPamYEdxb4tjF)cqAJJK0c(eUqvoeCkaJS3WvaYqb(UK38DCZojaPnossl4t4cvhKGtbiTXrsAbFcWmUDc3HaeJSekeZGa8E5nDOk788idnbqBCKKwagzVHRa8v60cxOQAvWPamYEdxbiLvG9YyIPeCpgRwasBCKKwWNWfQEdbNcqAJJK0c(eGr2B4kaFcJdN0ZdCP5N0Stcqn9zCN4nCfG3mjrYZkq(aTYHwfsPvEGzq(BvQ2vGiUvHvA6GGIAv8wLGBiUDESyvcMqjmUxgw5bMb5VvAE9YWQhcxcBvG6e2kxHSkb3JbMNvEGzqUamJBNWDiazIvAOd8eghoPNh4sZpPzNMAOd4DM9EziCHQdobNcqAJJK0c(eGr2B4kaFcJdN0ZdCP5N0StcWmUDc3HaKjwPHoWtyC4KEEGln)KMDAQHoG3z27LHamZllPPhygK)cvzt4cvh4cofG0ghjPf8jaJS3Wva(eghoPNh4sZpPzNeGA6Z4oXB4kaVP70yIBLdTc5jRsPqRvTBvQwkTkhjwLHJhOvjWE93Qy1wbUQTv9BLgMAzXkORq4u9twXorjwHIHJwLJKKEzyvwjWmOxaMXTt4oeGOndfFIPXO33k1X1QBy1LlwLHqPgMAbEcJdN0ZdCP5N0StaJHkNzLaZGERgaRYkbMb9tuCK9gUH0k1X1kwbWXnS6YfRYWXdCMa71FanH252TIRv5KjJOxRy2kMy1bbff4zhrkNXQNzm8)dCPhajXkMTIwcZGhG3J00HZXqLwDVvSjCHQSgcofG0ghjPf8jaJS3WvaM0VdLZxb6cqn9zCN4nCfGdSNSIP73HsRavGUvPAxXk1ssce7iB78SQrTsnWXt4wX0qN2mpRsb3HDRGPjCosSIwcZGhlwLsHwRA3QuTuAfPYi7sEwLJeRudtZIvqSvPuO1kKVxgwnGaPZSBLAJJucWmUDc3Ha8GGIcatsGyhzBNhasIvmB1TwrlHzWdqtODUDRU3QBTIwcZGhaMyqRv8BfBSYQ7S6YfRYWXdCMa71FanH252TsDCTInR43QdckkWbdd93AcajXQlxSYdjToWafPZSp14ifaTXrsARUt4cvznfCkaPnossl4taMXTt4oeGheuuaysce7iB78aqsSIzRU1Qdckkadmr7ZEV)mvNzNWpasIvxUy1bbffid3mfssppsKvt4dY)aijwDNamYEdxbys)ouoFfOlCHQSXkbNcWi7nCfGFV97eE(oUzNeG0ghjPf8jCHQSXMGtbiTXrsAbFcWmUDc3Ha0djToGUXoVPJ7m7paTXrsARy2QmC8aNjWE9hqtODUDRUNRvSzf)wDqqrboyyO)wtaijcWi7nCfGmGimiHlCHlatt4VHRqvoyfhSXQbhhSMcWubE7LXlahi3ufQQkq1b8bZkR4uHSQhtGy3kui2QH1eAGi9HTctduKgtARE4izvG4WXWjTvzLyzqpGDLP0lzLADWSsnWnnHDsB1Wz4QrAhG1h2khA1Wz4QrAhG1bOnosspSv3YMkVdWUAxhi3ufQQkq1b8bZkR4uHSQhtGy3kui2QHtWugoEcFyRW0afPXK2QhoswfioCmCsBvwjwg0dyxzk9swDJbZk1a30e2jTvd)qe5PxnaRpSvo0QHFiI80RgG1bOnosspSv3YMkVdWUYu6LS6gdMvQbUPjStARg(HiYtVAawFyRCOvd)qe5PxnaRdqBCKKEyRc3kvuTWuS6w2u5Da2v76a5MQqvvbQoGpywzfNkKv9yce7wHcXwnCw)dBfMgOinM0w9WrYQaXHJHtARYkXYGEa7ktPxYkogmRudCttyN0wnmgzjuiMbbW6dBLdTAymYsOqmdcG1bOnosspSv3YHkVdWUYu6LSAqdMvQbUPjStARggJSekeZGay9HTYHwnmgzjuiMbbW6a0ghjPh2QBztL3byxzk9swPwhmRudCttyN0wnmgzjuiMbbW6dBLdTAymYsOqmdcG1bOnosspSv3YMkVdWUYu6LSAGpywPg4MMWoPTA4hIip9Qby9HTYHwn8drKNE1aSoaTXrs6HT6wou5Da2vMsVKvSnObZk1a30e2jTvdJrwcfIzqaS(Ww5qRggJSekeZGayDaAJJK0dB1TSPY7aSRmLEjR4GJbZk1a30e2jTvd74EzNCa2ay9HTYHwnSJ7LDYbC2ay9HT6w2u5Da2vMsVKvCmObZk1a30e2jTvd74EzNCaoay9HTYHwnSJ7LDYbCoay9HT6w2u5Da2v76a5MQqvvbQoGpywzfNkKv9yce7wHcXwn8bPL6HTctduKgtARE4izvG4WXWjTvzLyzqpGDLP0lz1GgmRudCttyN0wnmgzjuiMbbW6dBLdTAymYsOqmdcG1bOnosspSvHBLkQwykwDlBQ8oa7QDLtfYQHrEA2on(dBvK9gUwLkERwOBfkez1w1RvUs)w1JjqSdyxvbJjqStARgCwfzVHRvY(9hWUkatWq0wscq1RERuliUmszLkeYaHSRQx9wDfrYZk2yXkoyfhSzxTRQx9wPIQKYioPT6qOqmzvgoEc3QdXO3hWQBMZuI)wTWDauc8ikI0Qi7nCFRGRKhGDnYEd3hibtz44jCUrsIK3mb2pCTRr2B4(ajykdhpHZp3Hoq3LKEIkdEKovVmMouL9AxJS3W9bsWugoEcNFUd9ofsxXUgzVH7dKGPmC8eo)ChAmWSt6jkep1u4kSKGPmC8e(8PmC1p3BWsJYfhTEsPP1bcT(b69EoUHDnYEd3hibtz44jC(5oeQKELmoqDwAuUperE6vdKG8oIKMegjXB4E5YdrKNE1aPHYWBjnFOmnTUDnYEd3hibtz44jC(5oegkLtxHMh4spljykdhpHpFkdx9ZLdwAuUyAm69v3GSRr2B4(ajykdhpHZp3HEzNPzS6PUZeljykdhpHpFkdx9ZLdwAuUycftVsCKKD1UQE1BLkQskJ4K2kknH5zL3JKvUczvKDi2Q(TkshTmoscWUgzVH7ZL9oZUDv9wPcP3Pq6kw1OwLa)VpsYQBxOvPrKlHJJKSIwASP3QETkdhpHFNDnYEd3NFUd9ofsxXUQERuHegkLw99YqswDqqrFROal5zf0viSvUsSwXjgHSIpkW9YWQy1wXhgg6V1KDnYEd3NFUdLoWDCKelBmsCX(zIjmukzjDiriUy)mpiOOV64G5BzYbbffWXi08qbUxgaijmZKdckkWbdd93Acaj5o7Q6Tsf3hbtwLISIb5wHIiLwDZXdYRyLAyARye9(wfR2Qat7WUvycdLYEzyLAGiRBLRqwPw063Qdck6BvKk4zxJS3W95N7qPdChhjXYgJe3y8G8kZmC1T3WLL0HeH4MHJh4mb2R)aAcTZTFpxo4)GGIcCWWq)TMaqsyMwcZG39CVbRy(wMKHRgPDGmez9PRqtOw)xUCqqrbWqPC6k08ax6bW0y07Fpx2y1D2v1BfRT3(vSkCRgdvAvc8)(ijRudtBvQ2vGiUvW0egvct1ldRoWf5TkdhpqRsG96plwHSs6FRqHyR4ZvrRsP0zfRczQG3B1RarKARoKv3GFRudtBxJS3W95N7qPdChhjXYgJex0E7xzMHRU9gUSKoKie3mC8aNjWE9)EU5K5yOY5NqREaoiOOahmm0FRjaKKb42dckkamjbIDKTDEaijdyEiP1bgOiDM9PghPaOnossF3LlekkL9onnZWXdCMa71)75MtMJHkNFcTA7Q6T6MYubV3QWDAmXTYHwH8Kv85QOvHB1n43k1W0SyfMyeyTK(3kiQvQHPTIbTwLkENSRr2B4(8ZDO0bUJJKyzJrIlAV9RmZWv3EdxwGjCX0tolnk3mek1WulWH8ueTtxHMep6bWuO5XmHIszVttZmC8aNjWE9xD3WUQERgiTRy1iI07ejzLhygK)SyLR0VvPdChhjzv)wLvOm7K2khALMYTMSkLc5ke2QhoswPg1(T6vGisTvhYQN3MjTvPAxXk(KHMSI1krWyE21i7nCF(5ou6a3XrsSSXiX9idnnrLiymV5ZBZSKoKie3pHKYPhygK)ahzOPjQebJ5PooyghTEsPP1bcT(b69Eoy1LlheuuGJm00evIGX8aW0y07FpB87HKwhG9wk7LX8tWebqBCKK2UgzVH7Zp3HWi7mYEd3PSFNLngjUVtH0vyPr5(ofsxH0aHuAxJS3W95N7q5qkNr2B4oL97SSXiXnRF7AK9gUp)ChcJSZi7nCNY(Dw2yK4I2B)kS0OCth4ooscaT3(vMz4QBVHRDnYEd3NFUdLdPCgzVH7u2VZYgJe3dsl121i7nCF(5ouGZXsthIX06S0OCPLWm4bOj0o3(9Cz7g8tlHzWdatmO1UgzVH7Zp3HcCowAMGiFYUgzVH7Zp3HKndf)NdOr0mgP1TRr2B4(8ZDOtWycrNoUZS)2v7Q6vVv8H0snHF7AK9gUpWbPLAUpL89BxJS3W9boiTuZp3HyOaFxYB(oUzNSRr2B4(ahKwQ5N7qVsNMLgLlgzjuiMbb49YB6qv255rgAYUgzVH7dCqAPMFUdrzfyVmMykb3JXQTRQ3QBMKi5zfiFGw5qRcP0kpWmi)Tkv7kqe3QWknDqqrTkERsWne3opwSkbtOeg3ldR8aZG83knVEzy1dHlHTkqDcBLRqwLG7XaZZkpWmi3UgzVH7dCqAPMFUd9eghoPNh4sZpPzNyPr5Yen0bEcJdN0ZdCP5N0Sttn0b8oZEVmSRr2B4(ahKwQ5N7qpHXHt65bU08tA2jwY8YsA6bMb5px2yPr5Yen0bEcJdN0ZdCP5N0Sttn0b8oZEVmSRQ3QB6onM4w5qRqEYQuk0Av7wLQLsRYrIvz44bAvcSx)TkwTvGRABv)wPHPwwSc6keov)KvStuIvOy4Ov5ijPxgwLvcmd6TRr2B4(ahKwQ5N7qpHXHt65bU08tA2jwAuUOndfFIPXO3xDCVXLlziuQHPwGNW4Wj98axA(jn7eWyOYzwjWmOFaYkbMb9tuCK9gUHuDCzfah34YLmC8aNjWE9hqtODUDU5KjJOxMzYbbff4zhrkNXQNzm8)dCPhajHzAjmdEaEpsthohdvEpB2v1B1a7jRy6(DO0kqfOBvQ2vSsTKKaXoY2opRAuRudC8eUvmn0PnZZQuWDy3kyAcNJeROLWm4XIvPuO1Q2TkvlLwrQmYUKNv5iXk1W0SyfeBvkfATc57LHvdiq6m7wP24iLDnYEd3h4G0sn)ChkPFhkNVc0zPr5EqqrbGjjqSJSTZdajH5BPLWm4bOj0o3(93slHzWdatmOLF2y1DxUKHJh4mb2R)aAcTZTRoUSX)bbff4GHH(BnbGKC5IhsADGbksNzFQXrkaAJJK03zxJS3W9boiTuZp3Hs63HY5RaDwAuUheuuaysce7iB78aqsy(2dckkadmr7ZEV)mvNzNWpasYLlheuuGmCZuij98irwnHpi)dGKCNDnYEd3h4G0sn)Ch67TFNWZ3Xn7KDnYEd3h4G0sn)ChIbeHbXsJY1djToGUXoVPJ7m7paTXrsAMZWXdCMa71FanH252VNlB8FqqrboyyO)wtaij2v7Q6vVvQbcLAyQ9TRQ3k(KHMSI1krWyEwbxR4GFROLgB6TRr2B4(az9Z9idnnrLiympwAuUFcjLtpWmi)VNlhmZKdckkWrgAAIkrWyEaij2v1B1a77LHv3C8G8kw1VvHvCmGYQEZykEIfREOvd(y7xXQCSwDiRE4i59i9wDiRqEsBv8wfwH4TSDEw9jKuAfYkP)Tc57LHvm14DcB1n)p(VxRGyRuBkCfjpRavcnm1BxJS3W9bY6NFUdLo2(vyPr5YemYsOqmdcymWSpHOtxHMJX7eEg)h)3lZm5DkKUcPbcPK50bUJJKaIXdYRmZWv3EdxMVLjyKLqHygeGMcxrYB(kHgM6VC5GGIcOPWvK8MVsOHPEanm1YCgoEGZeyV(RoUCCNDv9wnqAxXkMA8oHT6M))X)9YIvpVnB1Gp2(vSkv7kwfwH2B)ke2ki2QBoEqEfR0ucT6EzyfCTIpxfTkdHsnm1YIvqSvHmvW7TkScT3(viSvPAxXkMkQABxJS3W9bY6NFUdLoWDCKelBmsCthB)kZXyMHRU9gUS0OCXilHcXmiGXaZ(eIoDfAogVt4z8F8FVmZepK06aJbMDsprH4PMcxbG24ijnlPdjcX9wMKHqPgMAboKNIOD6k0K4rpaMcnpMth4ooscaT3(vMz4QBVH7DxUCBgcLAyQf4qEkI2PRqtIh9ayk08yoDG74ijGy8G8kZmC1T3W9o7AK9gUpqw)8ZDO0bUJJKyzJrIB6y7xzogZmC1T3WLLgLlgzjuiMbbmgy2Nq0PRqZX4DcpJ)J)7LzpK06aJbMDsprH4PMcxbG24ijnlPdjcXnDG74ija0E7xzMHRU9gU21i7nCFGS(5N7qPJTFfwAuUPdChhjbKo2(vMJXmdxD7nCzEmENWZ4)4)ENyAm695YkMth4oosc4idnnrLiymV5ZBZ21i7nCFGS(5N7qHgtBi7LMyKxHLgLltoiOOaHgtBi7LMyKxbajXUQERyTs6vY4a1TcfITIPrEhrswPIyKeVHRvnQvl0T6DkKUcPTkwTvl0Tkv7kwXNm0KvSwjcgZZUgzVH7dK1p)ChcvsVsghOolnk3BFiI80Rgib5DejnjmsI3W9YLhIip9QbsdLH3sA(qzAA97yMjVtH0vinqiLmFltoiOOahzOPjQebJ5bGKC5YNqs50dmdYFGJm00evIGX8uhh3X8Tm5GGIceAmTHSxAIrEfaKKlxOLWm4b49inD4Cmu59CCNDnYEd3hiRF(5oeQmyqsz4nCzPr5YK3Pq6kKgiKsMVnDG74ija0E7xzMHRU9gUxU4bMb5aEpstho1nPo2g0D21i7nCFGS(5N7qAmf6Jm00ZsJYLjVtH0vinqiLmNHJh4mb2R)QJlhmFltYW00gRdKMwxHh(YfnDqqrbqLbdskdVHlasYD21i7nCFGS(5N7qyOuoDfAEGl9S0OChJ3j8m(p(V3jMgJEFUSI5dckkGgtH(idn9aAyQL5BpiOOayOuoDfAEGl9ayAm69vh3bD5s6a3Xrsay)mXegkL3zxvVvQauRcT(TkWKvijSy1VDczLRqwbxYQuTRyLeMIE3ko5uTbSAG9KvPuO1knVEzyfA8oHTYvI1k1W0wPj0o3UvqSvPAxbI4wflpRudtdyxJS3W9bY6NFUdngy2j9efINAkCfwK9sZSMlBa3GLmVSKMEGzq(ZLnwAuU4O1tknToqO1pascZ36bMb5aEpstho1nPUmC8aNjWE9hqtODU9lxyY7uiDfsdGHmqiMZWXdCMa71FanH252VNBozogQC(j0Qha2UZUQERubOwTqRcT(TkvlLwPBYQuTR0RvUcz1sQ0TAqS6zXkKNSIPIQ2wbxRoW)Tkv7kqe3Qy5zLAyAa7AK9gUpqw)8ZDOXaZoPNOq8utHRWsJYfhTEsPP1bcT(b69(bXQbahTEsPP1bcT(b0i4WB4YmtENcPRqAamKbcXCgoEGZeyV(dOj0o3(9CZjZXqLZpHw9aWMDv9wDt3PXe3khA1ZBZwnGSLYEzyfycMiRs1UIvd(y7xXkui2kMA8oHT6M)h)3RDnYEd3hiRF(5ou6a3XrsSSXiXL9wk7LX8tWenthB)kZN3MzjDiriUmbJSekeZGagdm7ti60vO5y8oHNX)X)9E5sgcLAyQfiDS9RaGPXO3)E2y1LlJX7eEg)h)37etJrV)9CyxvVvdSNSQxRyBa4GtRAuR4ZvrR63kKeRIvBvk4oSBvosSsfxcZGhlwbXwfUvdIt(T6wo4KFRs1UIvQnfUIKNvGkHgM6VZki2Quk0AftnENWwDZ)J)71Q(TcjbWUgzVH7dK1p)ChI9wk7LX8tWeXsJYnDG74ijGJm00evIGX8MpVnZC6a3XrsaS3szVmMFcMOz6y7xz(82mZm5DkKUcPbWqgieZ3QPdckkWH8ueTtxHMep6bqsy(GGIcOXuOpYqtpGgMAzMwcZGhGMq7C73FlTeMbpamXG2bmo4NTBC3LlFcjLtpWmi)boYqttujcgZ7(B5yaoiOOaAkCfjV5ReAyQhaj5UlxgJ3j8m(p(V3jMgJE)7z1D21i7nCFGS(5N7qhzOPjg5vyPr5MoWDCKeWrgAAIkrWyEZN3Mz(wAjmdEaEpsthohdvEphmFqqrb0yk0hzOPhqdtTxUqlHzWtDCheRUC5tiPC6bMb5)9CCNDnYEd3hiRF(5o0ReAyQrsQzPr5YK3Pq6kKgiKsMth4ooscigpiVYmdxD7nCTRr2B4(az9Zp3HsGEdxwAuUheuuGJec1sK3bWuK9lxoW)zgTzO4tmng9(QBqS6YLdckkqOX0gYEPjg5vaqsSRr2B4(az9Zp3HosiuprrW8SRr2B4(az9Zp3Hoe(jm79YWUgzVH7dK1p)ChcTX0rcHA7AK9gUpqw)8ZDOyZ074qoZHuAxvVvQnHgis3QmC1T3W9TcfITc5JJKSQDA8bSRr2B4(az9Zp3HCCVStoBS0OC10bbff4qEkI2PRqtIh9aijxU44EzNCa2auIFI808GGIE5Yb(pZOndfFIPXO3xDC5Gv21i7nCFGS(5N7qoUx2jNdwAuUA6GGIcCipfr70vOjXJEaKKlxCCVStoahakXprEAEqqrVC5a)Nz0MHIpX0y07RoUCWk7QDv9Q3kwBV9Rq43UQER4ZvrRGRvziuQHPwRCOvStuIvUczLAWTBLMoiOOwHKWIviRK(3kxHSYdmdYTQFRIdeXTYHwPBYUgzVH7dG2B)kCpKNIOD6k0K4rplnkxpWmihW7rA6WPUP7hKDnYEd3haT3(v4N7qVSZ0mw9u3zILgL7bbff4LDMMXQN6otayAm69vhAZqXNyAm69zgtOy6vIJKSRr2B4(aO92Vc)Chs3Fs4zf7QDv9Q3kqNcPRyxJS3W9bENcPRWv3Fs4zfwAuUPdChhjbG2B)kZmC1T3W1UgzVH7d8ofsxHFUdfJhKxXUgzVH7d8ofsxHFUdLvOiz(kqNLmVSKMEGzq(ZLnwAuUEiP1bsWeVjCNUcntrb7a0ghjPzMjEGzqoq)Zd8Fb4NqzHQCm4yLWfUqaa]] )
    

end