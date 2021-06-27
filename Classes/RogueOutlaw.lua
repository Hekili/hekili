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
            handler = function ()
                if debuff.dreadblades.up then
                    gain( combo_points.max, "combo_points" )
                else
                    gain( ( buff.shadow_blades.up and 1 or 0 ) + buff.broadside.up and 3 or 2, "combo_points" )
                end

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

            handler = function ()
                applyDebuff( "target", "cheap_shot", 4 )

                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end
                
                if talent.prey_on_the_weak.enabled then
                    applyDebuff( "target", "prey_on_the_weak", 6 )
                end

                if pvptalent.control_is_king.enabled then
                    applyBuff( "slice_and_dice", 15 )
                end

                gain( ( buff.shadow_blades.up and 1 or 0 ) + 1, "combo_points" )
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
            
            handler = function ()
                applyDebuff( "player", "dreadblades" )
                gain( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ), "combo_points" )
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

            handler = function ()
                applyDebuff( "target", "ghostly_strike", 10 )
                gain( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ), "combo_points" )
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

            handler = function ()
                gain( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ), "combo_points" )
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

            handler = function ()
                gain( 5, "combo_points" )
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

            handler = function ()
                if debuff.dreadblades.up then
                    gain( combo_points.max, "combo_points" )
                else
                    gain( 1 + ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ) + ( buff.opportunity.up and 1 or 0 ) + ( buff.concealed_blunderbuss.up and 2 or 0 ), "combo_points" )
                end

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
            
            handler = function ()
                gain( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ), "combo_point" )
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

            handler = function ()
                removeStack( "snake_eyes" )
                if debuff.dreadblades.up then
                    gain( combo_points.max, "combo_points" )
                else
                    gain( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 2 or 1 ), "combo_points" )
                end

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


    spec:RegisterPack( "Outlaw", 20210627, [[d8uDbbqicIhruvxIOsrBcQ4tasJcq5uaQwLiQKxrinliPBruu7sL(fammirhdQQLbv5zIOmncsCnrK2gbP8ncsACaOY5aqvRdaP5ruX9iW(aehesWcjepKOWejQIlsujBeaHpkIk1jjksRub9sIkLmtcs1nbqzNeL(jrLQHcj0rjQuyPefXtbAQqLUQiQyRai6RIOkJLOkTxu9xfnyPomvlwfpwutMKlJSzi(mKA0e50swnrLs9AcQztQBRq7wPFdA4I0XfrvTCuEUQMUW1HY2vGVlcJxeX5juZhG2pL54ZXLdQ8G4YIhkXdFuk0WtOEXxOMmaUKcWZbdXPehm1Zc7Ojo46JehuUJfApbhm1fRHUIJlh8HySmXbLIi9bOaaaORqc7CZWra81iM2JcUzMJea4RXma4GhSshY0LF4GkpiUS4Hs8WhLcn8eQx8fQjdGlPcnoOJfsqgheSgLbhuQukA5hoOI(mhuUJfApH1YeiAmYgoeBjRXtOIQ14Hs8WNdQRpEoUCqfH4y6GJlxw854Yb9CuWLdkCLfMdsRF0KIlcp4YIhhxoiT(rtkUiCqf9zwLgfC5GYe6dY1HK1fI1PW)RJMSgyl06by6Ly(rtwtlnw0BDTwNHJhpaoh0Zrbxo4hKRdjEWLnzCC5G06hnP4IWbHPCWNcoONJcUCWboR8JM4GdCngXbzXzEWqqERLJ14znowdmRfI1hmeKBWWO5HCwTOVyPwJJ1cX6dgcY9WGU6lfDXsTg4Cqf9zwLgfC5GYeIb1AR)ArRjRpyiiV1KZ0ITggseZ6qYxRXLHrwlc5SArBTVkRfHbD1xkIdoWzZ1hjoilotgXGAnp4Yku44YbP1pAsXfHdct5GpfCqphfC5GdCw5hnXbh4AmIdMHJh4mfwB8xfHu5kSgicSgpRf16dgcY9WGU6lfDXsTghRPLyOfBnqeyDsrP14ynWSwiwNHRcRIBgITXmKOjuP(lT(rtkRbeqRpyiixguRNHenpWL(lJg9AFRbIaRXhLwdCoOI(mRsJcUCq5AFmgzDcYA0uyncMwBnkmEWEjRLbkAnAV23AFvw7mAbAynJyqTUw0wldi2gwhsK1YDL6T(GHG8w7jCXCWboBU(iXb9Xd2lnZWvvrbxEWLnPCC5G06hnP4IWbHPCWNcoONJcUCWboR8JM4GdCngXbZWXdCMcRnERbIaRZPZrpjZpLwL1YS1hmeK7HbD1xk6ILATmBnWS(GHGCHPPqwGTvi(ILADYL1HRPnUjFSkl8uX8exA9JMuwdCRbeqRjeekh1aAMHJh4mfwB8wdebwNtNJEsMFkTkoOI(mRsJcUCqaIARxYApSE0tI1PW)RJMSwgOO1jQqcIfwdhqmenmrTOT(axS36mC8aTofwB8OAn2QP)TgbYSwKqUSoHuLLS21jCXV1VeetRS(qwNurTwgOihCGZMRpsCqKARxAMHRQIcU8GlRqJJlhKw)OjfxeoimLdYONcoONJcUCWboR8JM4GdC2C9rIdIuB9sZmCvvuWLdMzvqSY5GziuRGj27HIeeTZqIMKy6VmYvITghRjeekh1aAMHJh4mfwB8wlhRtkhurFMvPrbxoikOt4IFR9iOX0W6aAn2twlsixw7H1jvuRLbkIQ1mcTZuA6FRHiwldu0A00ADc)dIhCzfQCC5G06hnP4IWbHPCWNcoONJcUCWboR8JM4GdCngXb)usRNHZqtXFpAxrtengJj2A5ynEwJJ1mVutAaTX1vQ)wR1aXA8qP1acO1hmeK7r7kAIOXymXxgn61(wdeRX3ArToCnTXv4sRRf98tzeDP1pAsXbv0NzvAuWLdM8QqY6rmDuPAY6WzOP4r16qQERh4SYpAY66TolrzHjL1b0AfLlfzDcjkKiM1pCKSwgYZB9lbX0kRpK1V4ntkRtuHK1IODfznaHgJXeZbh4S56Jeh8ODfnr0ymM45lEZ8GllahhxoiT(rtkUiCWmRcIvoh8dY1HePUUwZb9CuWLdYW2PNJcUtD9bhuxFmxFK4GFqUoK4bxwaEoUCqA9JMuCr4GEok4YbZUwp9CuWDQRp4G66J56JehmREEWLfFuYXLdsRF0KIlchmZQGyLZbh4SYpA6IuB9sZmCvvuWLd65OGlhKHTtphfCN66doOU(yU(iXbrQTEjEWLfF854YbP1pAsXfHd65OGlhm7A90Zrb3PU(GdQRpMRpsCWdwPv8Gll(4XXLdsRF0KIlchmZQGyLZbPLyOfFvesLRWAGiWA8tQ1IAnTedT4lJqtlh0ZrbxoOZY(sZaYy0g8Gll(jJJlh0ZrbxoOZY(sZum9tCqA9JMuCr4bxw8fkCC5GEok4Yb1fAP4NYTXuOhPn4G06hnP4IWdUS4NuoUCqphfC5Ghh9eImdwLf(5G06hnP4IWdEWbtzugoE8GJlxw854Yb9CuWLd6PPAXZuy9WLdsRF0KIlcp4YIhhxoONJcUCWdmcnPMiAxmPsul6zatsTCqA9JMuCr4bx2KXXLd65OGlh8dY1HehKw)OjfxeEWLvOWXLdsRF0KIlch0Zrbxo4OZeMuteiBQipK4GzwfeRCoiZl1KgqBCDL6V1AnqSgVKYbtzugoE8y(ugUQNdMuEWLnPCC5G06hnP4IWb9CuWLdYGA9mKO5bU0ZbZSkiw5Cqgn61(wlhRtghmLrz44XJ5tz4QEoiE8GlRqJJlhKw)OjfxeoONJcUCWxxzA6RAQQmXbZSkiw5CqgHWOxYpAIdMYOmC84X8PmCvphepEWdoisT1lXXLll(CC5G06hnP4IWb9CuWLdEOibr7mKOjjMEoOI(mRsJcUCqrc5YA4ADgc1kyI16aATWeLADirwldwfwROdgcI1yPOAn2QP)ToKiRdNHMcRR3A)aXcRdO1QI4GzwfeRCoy4m0uCJAKMbCQkYAGyDY4bxw844YbP1pAsXfHdMzvqSY5GhmeK7RRmn9vnvvMUmA0R9TwowJuOLIjJg9AFRXXAgHWOxYpAId65OGlh81vMM(QMQkt8GlBY44Yb9CuWLdQQp1JSehKw)OjfxeEWdoyw9CC5YIphxoiT(rtkUiCqphfC5GhTROjIgJXeZbv0NzvAuWLdkI2vK1aeAmgtS1W1A8e1AAPXIEoyMvbXkNd(PKwpdNHMI3AGiWA8SghRfI1hmeK7r7kAIOXymXxSuEWLfpoUCqA9JMuCr4GEok4Ybh4B9sCqf9zwLgfC5GjNVw0wJcJhSxY66T2Tgp5MwxBMr(tOA9dTgG036LSo7R1hY6hosrnsV1hYASNuw7V1U1yrPRqS1FkP1wJTA6FRX(ArBnaZ)GywJc)7)xR1qM1Yd5HKwS1GsUcM45GzwfeRCoOqSMHTecKHMUJot4jezgs0C0)Gyt)F))AV06hnPSghRfI1FqUoKi111ARXX6boR8JMU(4b7LMz4QQOGR14ynWSwiwZWwcbYqtxf5HKw88LCfmXFP1pAsznGaA9bdb5QipK0INVKRGj(RcMyTghRZWXdCMcRnERLJaRXZAGZdUSjJJlhKw)OjfxeoimLd(uWb9CuWLdoWzLF0ehCGZMRpsCWb(wV0C0Nz4QQOGlhmZQGyLZbzylHazOP7OZeEcrMHenh9pi20)3)V2lT(rtkRXXAHyD4AAJ7OZeMuteiBQipKU06hnP4Gk6ZSknk4YbtEviznaZ)GywJc))()1IQ1V4nBnaPV1lzDIkKS2TgP26LiM1qM1OW4b7LSwrP0QQfT1W1Arc5Y6meQvWelQwdzw76eU43A3AKARxIywNOcjRbyiYdhCGRXioiWSwiwNHqTcMyVhksq0odjAsIP)Yixj2ACSEGZk)OPlsT1lnZWvvrbxRbU1acO1aZ6meQvWe79qrcI2zirtsm9xg5kXwJJ1dCw5hnD9Xd2lnZWvvrbxRbop4Yku44YbP1pAsXfHdct5GpfCqphfC5GdCw5hnXbh4AmIdoWzLF00fP26LMz4QQOGlhmZQGyLZbzylHazOP7OZeEcrMHenh9pi20)3)V2lT(rtkRXX6W10g3rNjmPMiq2urEiDP1pAsXbh4S56JehCGV1lnh9zgUQkk4YdUSjLJlhKw)OjfxeoyMvbXkNdoWzLF00DGV1lnh9zgUQkk4Anowp6FqSP)V)FTtgn61(wlWAuAnowpWzLF009ODfnr0ymM45lEZCqphfC5Gd8TEjEWLvOXXLdsRF0KIlchmZQGyLZbfI1hmeKRRy066APjd7LUyPCqphfC5GUIrRRRLMmSxIhCzfQCC5G06hnP4IWbZSkiw5CqHy9hKRdjsDDT2ACSgywpWzLF00fP26LMz4QQOGR1acO1HZqtXnQrAgWPQiRLJ14NmRboh0ZrbxoiI2rtAThfC5bxwaooUCqA9JMuCr4GzwfeRCoOqS(dY1HePUUwBnowNHJh4mfwB8wlhbwJN14ynWSwiwNHdO134oG2qsmZAab0AfDWqqUiAhnP1EuW9ILAnW5GEok4YbvmYvhTRONhCzb454YbP1pAsXfHdMzvqSY5GJ(heB6)7)x7KrJETV1cSgLwJJ1hmeKRIrU6ODf9xfmXAnowdmRpyiixguRNHenpWL(lJg9AFRLJaRtM1acO1dCw5hnDzXzYiguRTg4CqphfC5GmOwpdjAEGl98Gll(OKJlhKw)OjfxeoONJcUCWrNjmPMiq2urEiXb11sZSIdI)nPCWS4SMMHZqtXZLfFoyMvbXkNdY8snPb0gxxP(lwQ14ynWSoCgAkUrnsZaovfzTCSodhpWzkS24VkcPYvynGaATqS(dY1HePUmiAmYACSodhpWzkS24VkcPYvynqeyDoDo6jz(P0QSwMTgFRbohurFMvPrbxoOmfXAxPERDgznwkQw)BLswhsK1WLSorfswRHjOpSgxCLNR1jNNSoHeTwRexlARr8piM1HKVwldu0AfHu5kSgYSorfsqSWAFfBTmqXlp4YIp(CC5G06hnP4IWb9CuWLdo6mHj1ebYMkYdjoOI(mRsJcUCqzkI1l0AxPERtuAT1QISorfs1ADirwVuscRtgkFuTg7jRbyiYJ1W16d8FRtuHeelS2xXwldu8YbZSkiw5CqMxQjnG246k1FR1AGyDYqP1YS1mVutAaTX1vQ)QWyEuW1ACSwiw)b56qIuxgengznowNHJh4mfwB8xfHu5kSgicSoNoh9Km)uAvwlZwJpp4YIpECC5G06hnP4IWbHPCWNcoONJcUCWboR8JM4GdCngXbfI1mSLqGm00D0zcpHiZqIMJ(heB6)7)x7Lw)OjL1acO1ziuRGj27aFRx6YOrV23AGyn(O0Aab06r)dIn9)9)RDYOrV23AGynECqf9zwLgfC5GOqe0yAyDaT(fVzRLBvADTOTgmLrK1jQqYAasFRxYAeiZAaM)bXSgf(3)Vwo4aNnxFK4GcxADTONFkJO5aFRxA(I3mp4YIFY44YbP1pAsXfHd65OGlhu4sRRf98tzeXbv0NzvAuWLdMCEY6ATgFzgpCTUqSwKqUSUERXsT2xL1jGlqdRZEQ1Y1sm0Ir1AiZApSoz4kQ1adpCf16evizT8qEiPfBnOKRGjEGBnKzDcjATgG5FqmRrH)9)R166Tgl9YbZSkiw5CWboR8JMUhTROjIgJXepFXB2ACSEGZk)OPRWLwxl65NYiAoW36LMV4nBnowleR)GCDirQldIgJSghRbM1k6GHGCpuKGODgs0Ket)fl1ACS(GHGCvmYvhTRO)QGjwRXXAAjgAXxfHu5kSgiwdmRPLyOfFzeAATo5YA8SwuRXpPwdCRbeqR)usRNHZqtXFpAxrtengJj2AGynWSgpRLzRpyiixf5HKw88LCfmXFXsTg4wdiGwp6FqSP)V)FTtgn61(wdeRrP1aNhCzXxOWXLdsRF0KIlchmZQGyLZbh4SYpA6E0UIMiAmgt88fVzRXXAGznTedT4BuJ0mGZrpjwdeRXZACS(GHGCvmYvhTRO)QGjwRbeqRPLyOfBTCeyDYqP1acO1FkP1ZWzOP4TgiwJN1aNd65OGlh8ODfnzyVep4YIFs54YbP1pAsXfHdMzvqSY5GcX6pixhsK66AT14y9aNv(rtxF8G9sZmCvvuWLd65OGlh8LCfmXiPv8Gll(cnoUCqA9JMuCr4GzwfeRCo4bdb5E0qOsJ9XLrEoSgqaT(a)3ACSgPqlftgn61(wlhRtgkTgqaT(GHGCDfJwxxlnzyV0flLd65OGlhmfgfC5bxw8fQCC5GEok4YbpAiunrWyI5G06hnP4IWdUS4dWXXLd65OGlh8qSNycxlAoiT(rtkUi8Gll(a8CC5GEok4YbrkgD0qOIdsRF0KIlcp4YIhk54Yb9CuWLd6BM(G56z21AoiT(rtkUi8GllE4ZXLdsRF0KIlch0ZrbxoyWQvykWNdQOpZQ0OGlhuEiehthwNHRQIcUV1iqM1yVF0K1vqJ)LdMzvqSY5Gk6GHGCpuKGODgs0Ket)fl1Aab06GvRWuCd8Vs(pXEAEWqqSgqaTgPqlftgn61(wlhbwJhk5bxw8WJJlhKw)OjfxeoyMvbXkNdQOdgcY9qrcI2zirtsm9xSuRbeqRdwTctXnW7k5)e7P5bdbXAab0AKcTumz0Ox7BTCeynEOKd65OGlhmy1kmf4XdEWb)GCDiXXLll(CC5G06hnP4IWbZSkiw5CWboR8JMUi1wV0mdxvffC5GEok4Ybv1N6rwIhCzXJJlh0ZrbxoOpEWEjoiT(rtkUi8GlBY44YbP1pAsXfHd65OGlhmlrE68LGbhmZQGyLZbdxtBCtzK4jCNHentqUWxA9JMuwJJ1cX6WzOP4w)8a)NdMfN10mCgAkEUS4ZdEWbpyLwXXLll(CC5GEok4YbFk9RNdsRF0KIlcp4YIhhxoONJcUCq0sWp0INFWkHjoiT(rtkUi8GlBY44YbP1pAsXfHdMzvqSY5GmSLqGm00nQv8mGjPYZJ2v0Lw)Ojfh0Zrbxo4lvd4bxwHchxoONJcUCqklbRf9KrPSA0xfhKw)OjfxeEWLnPCC5G06hnP4IWb9CuWLd(eJ5bPMh4sZpTeM4GzwfeRCo4bdb5(6kttFvtvLPlwQ14yTqSwbJ7tmMhKAEGln)0syAQGXnQSW1I2Aab06d8FRXXAKcTumz0Ox7BTCeyDsTgqaTodHAfmXEFIX8GuZdCP5Nwct3rpjZSKZqtV1YS1zjNHM(jcZZrbxxBTCeynkV4LuoywCwtZWzOP45YIpp4Yk044YbP1pAsXfHd65OGlhmT(aQNVem4Gk6ZSknk4YbtopznkwFa1wdkbdRtuHK1Y90uilW2keBDHyTmGJhpSgfHbTzXwNaUanSgoGyzp1AAjgAXOADcjATUcRtuAT1us8COfBD2tTwgOiQwdzwNqIwRX(ArBTCdSklS1YdZtWbZSkiw5CWdgcYfMMczb2wH4lwQ14ynWSMwIHw8vrivUcRbI1aZAAjgAXxgHMwRf1A8rP1a3Aab06mC8aNPWAJ)QiKkxH1YrG14BTOwFWqqUhg0vFPOlwQ1acO1HRPnUjFSkl8uX8exA9JMuwdCEWLvOYXLdsRF0KIlchmZQGyLZbpyiixyAkKfyBfIVyPwJJ1aZ6dgcYfnJO9fU2FMOYctS)ILAnGaA9bdb5MHBMCnPMhn2Qi2b7)lwQ1aNd65OGlhmT(aQNVem4bxwaooUCqphfC5GFT1heB(bReM4G06hnP4IWdUSa8CC5G06hnP4IWbZSkiw5CWW10gxvXcXZGvzH)lT(rtkRXX6mC8aNPWAJ)QiKkxH1arG14BTOwFWqqUhg0vFPOlwkh0ZrbxoiAigAIh8GhCWbe7l4YLfpuIh(OuOGVqHdMWzBTOFoyYdfKjYktLn5gGAT14krwxJPqwyncKznqveIJPdGAnJs(yfJuw)WrYAhlGJEqkRZs(IM(RnuOxlzTqbGATmG7aIfKYAGMHRcRIR8cuRdO1andxfwfx59sRF0KcOwdm8tcWV2qByYdfKjYktLn5gGAT14krwxJPqwyncKznqZQhOwZOKpwXiL1pCKS2Xc4OhKY6SKVOP)Adf61swJha1Aza3beliL1aLHTecKHMUYlqToGwdug2siqgA6kVxA9JMua1AGHxsa(1gk0RLSozauRLbChqSGuwdug2siqgA6kVa16aAnqzylHazOPR8EP1pAsbuRbg(jb4xBOqVwYAHca1Aza3beliL1aLHTecKHMUYlqToGwdug2siqgA6kVxA9JMua1AGHFsa(1gk0RLSgF8aOwld4oGybPSgOmSLqGm00vEbQ1b0AGYWwcbYqtx59sRF0KcOwdm8tcWV2qHETK14Hpa1Aza3beliL1any1kmfx8VYlqToGwd0GvRWuCd8VYlqTgy4NeGFTHc9AjRXdpaQ1YaUdiwqkRbAWQvykU4DLxGADaTgObRwHP4g4DLxGAnWWpja)AdTHjpuqMiRmv2KBaQ1wJRezDnMczH1iqM1a9GvAfqTMrjFSIrkRF4izTJfWrpiL1zjFrt)1gk0RLSozauRLbChqSGuwdug2siqgA6kVa16aAnqzylHazOPR8EP1pAsbuR9WA5sUl0Tgy4NeGFTH2qCLiRbk2tZkOXhOw75OGR1j836fgwJaXwL11ADivV11ykKfxBOmDmfYcszTqZAphfCTwxF8xBihmLbrknXbLV8TwUJfApH1YeiAmYgkF5B9qSLSgpHkQwJhkXdFBOnu(Y3A5kjugliL1hcbYiRZWXJhwFi01(xRrHCMsJ36fUYSKZgrW0w75OG7BnC1IV2qphfC)BkJYWXJhc80uT4zkSE4Ad9CuW9VPmkdhpEiQaaCGrOj1er7IjvIArpdysQ1g65OG7FtzugoE8quba4dY1HKn0Zrb3)MYOmC84HOcaWOZeMuteiBQipKqnLrz44XJ5tz4QEbjf1craZl1KgqBCDL6V1ce8sQn0Zrb3)MYOmC84HOcaadQ1ZqIMh4spQPmkdhpEmFkdx1lapulebmA0R9LtYSHEok4(3ugLHJhpevaaEDLPPVQPQYeQPmkdhpEmFkdx1lapulebmcHrVKF0Kn0gkF5BTCLekJfKYAAaXeBDuJK1HezTNdiZ66T2h4L2pA6Ad9CuW9fiCLf2gkFRLj0hKRdjRleRtH)xhnznWwO1dW0lX8JMSMwASO36ATodhpEaCBONJcUVOcaWhKRdjBO8TwMqmOwB9xlAnz9bdb5TMCMwS1WqIywhs(AnUmmYAriNvlAR9vzTimOR(sr2qphfCFrfaGboR8JMqD9rsalotgXGAnQdCngjGfN5bdb5LdE4amHCWqqUbdJMhYz1I(ILIJqoyii3dd6QVu0flf42q5BTCTpgJSobznAkSgbtRTgfgpyVK1YafTgTx7BTVkRDgTanSMrmOwxlARLbeBdRdjYA5Us9wFWqqER9eUyBONJcUVOcaWaNv(rtOU(ijWhpyV0mdxvffCrDGRXibz44botH1g)vrivUcGiaprpyii3dd6QVu0flfhAjgAXarqsrjoatiz4QWQ4MHyBmdjAcvQhqapyiixguRNHenpWL(lJg9AFGiaFucCBO8TgGO26LS2dRh9KyDk8)6OjRLbkADIkKGyH1WbedrdtulARpWf7TodhpqRtH1gpQwJTA6FRrGmRfjKlRtivzjRDDcx8B9lbX0kRpK1jvuRLbkAd9CuW9fvaag4SYpAc11hjbi1wV0mdxvffCrDGRXibz44botH1gpqeKtNJEsMFkTkz(GHGCpmOR(srxSuzgyhmeKlmnfYcSTcXxS0KRW10g3KpwLfEQyEIlT(rtkGdiGeccLJAanZWXdCMcRnEGiiNoh9Km)uAv2q5BnkOt4IFR9iOX0W6aAn2twlsixw7H1jvuRLbkIQ1mcTZuA6FRHiwldu0A00ADc)dYg65OG7lQaamWzLF0eQRpscqQTEPzgUQkk4IkmvaJEkqTqeKHqTcMyVhksq0odjAsIP)YixjghcbHYrnGMz44botH1gVCsQnu(wN8QqY6rmDuPAY6WzOP4r16qQERh4SYpAY66TolrzHjL1b0AfLlfzDcjkKiM1pCKSwgYZB9lbX0kRpK1V4ntkRtuHK1IODfznaHgJXeBd9CuW9fvaag4SYpAc11hjbhTROjIgJXepFXBg1bUgJe8PKwpdNHMI)E0UIMiAmgtSCWdhMxQjnG246k1FRfi4Hsab8GHGCpAxrtengJj(YOrV2hi4lA4AAJRWLwxl65NYi6sRF0KYg65OG7lQaaWW2PNJcUtD9bQRpsc(GCDiHAHi4dY1HePUUwBd9CuW9fvaaYUwp9CuWDQRpqD9rsqw92qphfCFrfaag2o9CuWDQRpqD9rsasT1lHAHiyGZk)OPlsT1lnZWvvrbxBONJcUVOcaq216PNJcUtD9bQRpscoyLwzd9CuW9fvaaCw2xAgqgJ2a1craTedT4RIqQCfara(jvuAjgAXxgHMwBONJcUVOcaGZY(sZum9t2qphfCFrfaaDHwk(PCBmf6rAdBONJcUVOcaWXrpHiZGvzHFBOnu(Y3ArWkTIyVn0Zrb3)EWkTsWtPF92qphfC)7bR0krfaa0sWp0INFWkHjBONJcU)9GvALOcaWlvdqTqeWWwcbYqt3OwXZaMKkppAxr2qphfC)7bR0krfaaklbRf9KrPSA0xLn0Zrb3)EWkTsuba4jgZdsnpWLMFAjmHAwCwtZWzOP4fGpQfIGdgcY91vMM(QMQktxSuCeIcg3Nympi18axA(PLW0ubJBuzHRfnGaEG)JdsHwkMmA0R9LJGKciGziuRGj27tmMhKAEGln)0sy6o6jzMLCgA6L5SKZqt)eH55OGRRLJauEXlP2q5BDY5jRrX6dO2AqjyyDIkKSwUNMczb2wHyRleRLbC84H1OimOnl26eWfOH1Wbel7PwtlXqlgvRtirR1vyDIsRTMsINdTyRZEQ1Yafr1AiZ6es0An2xlARLBGvzHTwEyEcBONJcU)9GvALOcaqA9bupFjyGAHi4GHGCHPPqwGTvi(ILIdWOLyOfFvesLRaiaJwIHw8LrOPvu8rjWbeWmC8aNPWAJ)QiKkxHCeGVOhmeK7HbD1xk6ILciGHRPnUjFSkl8uX8exA9JMua3g65OG7FpyLwjQaaKwFa1ZxcgOwicoyiixyAkKfyBfIVyP4aSdgcYfnJO9fU2FMOYctS)ILciGhmeKBgUzY1KAE0yRIyhS)VyPa3g65OG7FpyLwjQaa81wFqS5hSsyYg65OG7FpyLwjQaaGgIHMqTqeeUM24QkwiEgSkl8FP1pAsHtgoEGZuyTXFvesLRaicWx0dgcY9WGU6lfDXsTH2q5lFRLbeQvWe7BdLV1IODfznaHgJXeBnCTgprTMwASO3g65OG7FZQxWr7kAIOXymXOwic(usRNHZqtXdeb4HJqoyii3J2v0erJXyIVyP2q5BDY5RfT1OW4b7LSUERDRXtUP11MzK)eQw)qRbi9TEjRZ(A9HS(HJuuJ0B9HSg7jL1(BTBnwu6keB9NsAT1yRM(3ASVw0wdW8piM1OW)()1AnKzT8qEiPfBnOKRGjEBONJcU)nRErfaGb(wVeQfIaHWWwcbYqt3rNj8eImdjAo6FqSP)V)FT4iKpixhsK66AnodCw5hnD9Xd2lnZWvvrbxCaMqyylHazOPRI8qslE(sUcM4beWdgcYvrEiPfpFjxbt8xfmXItgoEGZuyTXlhb4bCBO8To5vHK1am)dIznk8)7)xlQw)I3S1aK(wVK1jQqYA3AKARxIywdzwJcJhSxYAfLsRQw0wdxRfjKlRZqOwbtSOAnKzTRt4IFRDRrQTEjIzDIkKSgGHip2qphfC)Bw9IkaadCw5hnH66JKGb(wV0C0Nz4QQOGlQfIag2siqgA6o6mHNqKzirZr)dIn9)9)RfhHeUM24o6mHj1ebYMkYdPlT(rtkuh4AmsaWesgc1kyI9EOibr7mKOjjM(lJCLyCg4SYpA6IuB9sZmCvvuWf4aciWYqOwbtS3dfjiANHenjX0FzKReJZaNv(rtxF8G9sZmCvvuWf42qphfC)Bw9IkaadCw5hnH66JKGb(wV0C0Nz4QQOGlQfIag2siqgA6o6mHNqKzirZr)dIn9)9)RfNW10g3rNjmPMiq2urEiDP1pAsH6axJrcg4SYpA6IuB9sZmCvvuW1g65OG7FZQxubayGV1lHAHiyGZk)OP7aFRxAo6ZmCvvuWfNr)dIn9)9)RDYOrV2xakXzGZk)OP7r7kAIOXymXZx8MTHEok4(3S6fvaaCfJwxxlnzyVeQfIaHCWqqUUIrRRRLMmSx6ILAd9CuW9Vz1lQaaGOD0Kw7rbxulebc5dY1HePUUwJdWg4SYpA6IuB9sZmCvvuWfqadNHMIBuJ0mGtvrYb)KbCBONJcU)nRErfaafJC1r7k6rTqeiKpixhsK66Anoz44botH1gVCeGhoatiz4aA9nUdOnKeZaeqfDWqqUiAhnP1EuW9ILcCBONJcU)nRErfaaguRNHenpWLEulebJ(heB6)7)x7KrJETVauIZbdb5QyKRoAxr)vbtS4aSdgcYLb16zirZdCP)YOrV2xocsgGaoWzLF00LfNjJyqTg42q5BTmfXAxPERDgznwkQw)BLswhsK1WLSorfswRHjOpSgxCLNR1jNNSoHeTwRexlARr8piM1HKVwldu0AfHu5kSgYSorfsqSWAFfBTmqXRn0Zrb3)MvVOcaWOZeMuteiBQipKqvxlnZkb4FtkQzXznndNHMIxa(OwicyEPM0aAJRRu)flfhGfodnf3OgPzaNQIKtgoEGZuyTXFvesLRaqafYhKRdjsDzq0yeoz44botH1g)vrivUcGiiNoh9Km)uAvYm(a3gkFRLPiwVqRDL6TorP1wRkY6evivR1Hez9sjjSozO8r1ASNSgGHipwdxRpW)TorfsqSWAFfBTmqXRn0Zrb3)MvVOcaWOZeMuteiBQipKqTqeW8snPb0gxxP(BTajzOuMzEPM0aAJRRu)vHX8OGloc5dY1HePUmiAmcNmC8aNPWAJ)QiKkxbqeKtNJEsMFkTkzgFBO8TgfIGgtdRdO1V4nBTCRsRRfT1GPmISorfswdq6B9swJazwdW8piM1OW)()1Ad9CuW9Vz1lQaamWzLF0eQRpsceU06Arp)ugrZb(wV08fVzuh4AmsGqyylHazOP7OZeEcrMHenh9pi20)3)VwabmdHAfmXEh4B9sxgn61(abFuciGJ(heB6)7)x7KrJETpqWZgkFRtopzDTwJVmJhUwxiwlsixwxV1yPw7RY6eWfOH1zp1A5AjgAXOAnKzThwNmCf1AGHhUIADIkKSwEipK0ITguYvWepWTgYSoHeTwdW8piM1OW)()1AD9wJLETHEok4(3S6fvaaeU06Arp)ugrOwicg4SYpA6E0UIMiAmgt88fVzCg4SYpA6kCP11IE(PmIMd8TEP5lEZ4iKpixhsK6YGOXiCaMIoyii3dfjiANHenjX0FXsX5GHGCvmYvhTRO)QGjwCOLyOfFvesLRaiaJwIHw8LrOPn5cprXpPahqa)usRNHZqtXFpAxrtengJjgiadpz(GHGCvKhsAXZxYvWe)flf4ac4O)bXM()()1oz0Ox7deucCBONJcU)nRErfaGJ2v0KH9sOwicg4SYpA6E0UIMiAmgt88fVzCagTedT4BuJ0mGZrpjabpCoyiixfJC1r7k6VkyIfqaPLyOflhbjdLac4NsA9mCgAkEGGhWTHEok4(3S6fvaaEjxbtmsAfQfIaH8b56qIuxxRXzGZk)OPRpEWEPzgUQkk4Ad9CuW9Vz1lQaaKcJcUOwicoyii3JgcvASpUmYZbGaEG)JdsHwkMmA0R9LtYqjGaEWqqUUIrRRRLMmSx6ILAd9CuW9Vz1lQaaC0qOAIGXeBd9CuW9Vz1lQaaCi2tmHRfTn0Zrb3)MvVOcaasXOJgcv2qphfC)Bw9Ikaa(MPpyUEMDT2gkFRLhcXX0H1z4QQOG7BncKzn27hnzDf04FTHEok4(3S6fvaacwTctb(Owicu0bdb5EOibr7mKOjjM(lwkGagSAfMIl(xj)NypnpyiiacisHwkMmA0R9LJa8qPn0Zrb3)MvVOcaqWQvykWd1crGIoyii3dfjiANHenjX0FXsbeWGvRWuCX7k5)e7P5bdbbqark0sXKrJETVCeGhkTH2q5lFRbiQTEjI92q5BTiHCznCTodHAfmXADaTwyIsToKiRLbRcRv0bdbXASuuTgB10)whsK1HZqtH11BTFGyH1b0Avr2qphfC)lsT1lj4qrcI2zirtsm9OwiccNHMIBuJ0mGtvrajz2qphfC)lsT1ljQaa86kttFvtvLjulebhmeK7RRmn9vnvvMUmA0R9LdsHwkMmA0R9XHrim6L8JMSHEok4(xKARxsubaqvFQhzjBOnu(Y3AWGCDizd9CuW9VFqUoKeOQp1JSeQfIGboR8JMUi1wV0mdxvffCTHEok4(3pixhsIkaa(4b7LSHEok4(3pixhsIkaazjYtNVemqnloRPz4m0u8cWh1crq4AAJBkJepH7mKOzcYf(sRF0KchHeodnf36Nh4)CWpLYCzXtOHsEWdoha]] )


end