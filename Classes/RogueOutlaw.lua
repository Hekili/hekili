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
                    gain( ( buff.shadow_blades.up and 1 or 0 ) + ( buff.broadside.up and 3 or 2 ), "combo_points" )
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


    spec:RegisterPack( "Outlaw", 20210629, [[d80fgbqiuqpseXLiPO0MqH(KcXOuPYPuP0QiPQ0RiKMfkXTiPk7sf)sH0Wqr1XiGLHI8mruMgHGUMiQ2gHaFtLc14qrHoNkfY6uPG5rsL7rq7tLQoikqlKa9qcrtuePUijf2ikk6JKuvCscHALkuVKKIIzQsrUPkf1ojj9tskYqrbCuskQSucH8uqMkkPRkIK2kkk4RKuvnwuuAVO6VkAWsDyQwmGhlQjtQlJSzq9zuQrtItlz1Kuu1RjjMnr3wLSBL(nKHlshxejwoupxvtx46aTDr47kW4jP05juZxbTFkZfGZkhs7bXvLjMZKamxeW0n6iGajN5IqrihkeNsCOupRIZM4qRFrCi1eyi9bCOuxSe5AoRCOhbIZehsjI0)ggDu2vOacCYORr)6cu6rH2m2HJr)6kpkhcaSKHiE5aCiThexvMyotcWCrat3OJacKCMNSBmhYbdfeMdbvxIKdPuAnTCaoKM(mhsnbgsFG1IieBqYgpgCjRz6gXI1mXCMeGdjRpEoRCinb7GYGZkxvb4SYH8CuOLdPsLvHdrRdijnxqEWvLjoRCiADajP5cYH00NXvAuOLdjIOpixgkwxWwNI(VaKK13TiRtakxc7asYAAPRIERR16m6cWJB5qEok0YH(GCzOWdUQjJZkhIwhqsAUGCiukh6PGd55OqlhkHJlhqsCOeUeK4q4aycacd)wRoRzYAgT(oRzO1aGWWNadstaYX1Y(aMAnJwZqRbaHHpayKR)sthWuRVLdPPpJR0OqlhseryKuA9xlBjznaim8Bn5yPyRrHcHTou81AwXGK1csoUw2w7R2AbXix)LM4qjC8C9lIdHdGjMWiPKhCvfHCw5q06assZfKdHs5qpfCiphfA5qjCC5asIdLWLGehkJUaqZuuTXF0eCLRW67fAntwlQ1aGWWhamY1FPPdyQ1mAnTeMTyRVxO1jN5wZO13zndToJwnyfNmcCJzOqtKw)hADajPTE4qRbaHHpyKuodfAcGw6py6YR9T(EHwlaZT(woKM(mUsJcTCi1yFqmz9aYA2uynmOuAndEba(kwlsgWA2ETV1(QT2X0osynMWiPSw2wlse4gwhkK1QjT(Tgaeg(T2h4I5qjC8C9lId5xaGVYmJwDffA5bx1KZzLdrRdijnxqoekLd9uWH8CuOLdLWXLdijoucxcsCOm6cantr1gV13l06C68Yv78tPvBT6znaim8baJC9xA6aMAT6z9DwdacdFqPPiCaUvi(aMAT6R1HlPnojfWkRYuJ9bhADajPT(wRho0AcgMYrLGMz0faAMIQnERVxO1505LR25NsRMdPPpJR0OqlhIzwB9kw7H1xUATof9FbijRfjdy9GkuqGH1OeegwIgulBRbql4BDgDbGSofvB8Syn4kP)TggHTwWqnSEGsLvS2LdCXV1VccuQTgGSo5IATizaouchpx)I4qW1wVYmJwDffA5bxvraNvoeToGK0Cb5qOuoeMEk4qEok0YHs44YbKehkHJNRFrCi4ARxzMrRUIcTCOmUccxohkJqsnAWEaOyar7muOjjM(dMCTyRz0AcgMYrLGMz0faAMIQnERvN1jNdPPpJR0OqlhIbLdCXV1Ee0vAyDGSg8jRfmudR9W6KlQ1IKbyXAmX2XAj9V1iyRfjdynBATEG)bXdUQ3yoRCiADajP5cYHqPCONcoKNJcTCOeoUCajXHs4sqId9PKuodhZMI)aiDnnHLGySyRvN1mznJwJ9spPe0ghxR)tTwFV1mXCRho0Aaqy4dG010ewcIXIpy6YR9T(ERfWArToCjTXrLskRL98tXeDO1bKKMdPPpJR0Oqlhs9xHI1xGYOsLK1HJztXZI1Hs9wNWXLdijRR36ScLvH0whiR1uU0K1duOqHWw)OlYArM0V1VccuQTgGS(fVzsB9GkuSwqPRjRzMsqmwmhkHJNRFrCiaPRPjSeeJfpFXBMhCvzg5SYHO1bKKMlihkJRGWLZH(GCzOq6JlLCiphfA5qyWD65Oq7uwFWHK1hZ1Vio0hKldfEWv9gXzLdrRdijnxqoKNJcTCOSlLtphfANY6doKS(yU(fXHY6NhCvfG5Cw5q06assZfKdLXvq4Y5qjCC5as6axB9kZmA1vuOLd55OqlhcdUtphfANY6doKS(yU(fXHGRTEfEWvvab4SYHO1bKKMlihYZrHwou2LYPNJcTtz9bhswFmx)I4qaGLuZdUQcWeNvoeToGK0Cb5qzCfeUCoeTeMT4JMGRCfwFVqRfi5wlQ10sy2IpyInTCiphfA5qoo7lndegtBWdUQcKmoRCiphfA5qoo7lntbLpXHO1bKKMlip4QkGiKZkhYZrHwoKSyRe)unpOM9fTbhIwhqsAUG8GRQajNZkhYZrHwoeGZEIGNbUYQ8CiADajP5cYdEWHsXugDb4bNvUQcWzLd55OqlhYttLINPO6rlhIwhqsAUG8GRktCw5qEok0YHaqrij9ew6Ij9GAzpdKARLdrRdijnxqEWvnzCw5qEok0YH(GCzOWHO1bKKMlip4Qkc5SYHO1bKKMlihYZrHwo0LJvH0tyeEQjpu4qzCfeUCoe2l9KsqBCCT(p1A99wZuY5qPykJUa8y(ugT6NdLCEWvn5Cw5q06assZfKdLXvq4Y5qpcucuR(Kc(bOKMegmnk0EO1bKK26HdT(rGsGA1NeiPhLKMpsMG24qRdijnhYZrHwoeSKELm2HdEWvveWzLdrRdijnxqoKNJcTCimskNHcnbql9COmUccxohctxETV1QZ6KXHsXugDb4X8PmA1phIjEWv9gZzLdrRdijnxqoKNJcTCOxwzA6REQRmXHY4kiC5CimbJPxXbKehkftz0fGhZNYOv)CiM4bp4qaGLuZzLRQaCw5qEok0YHEk9RNdrRdijnxqEWvLjoRCiphfA5qSvqFifp)axQqCiADajP5cYdUQjJZkhIwhqsAUGCOmUccxohcdUemcZMorTINbsTvEciDnDO1bKKMd55Oqlh6vQe8GRQiKZkhYZrHwoeLvq1YEIPuCD5RMdrRdijnxqEWvn5Cw5q06assZfKd55Oqlh6jm2dspbqln)0sfIdLXvq4Y5qaGWWNxwzA6REQRmDatTMrRzO1AuCEcJ9G0ta0sZpTuHMAuCIkRsTSTE4qRbq)BnJwdxSvIjMU8AFRvNqRtU1dhADgHKA0G98eg7bPNaOLMFAPcDUC1oZkoMn9wREwNvCmB6NWyphfADP1QtO1m)WuY5qzXzjndhZMINRQa8GRQiGZkhIwhqsAUGCiphfA5qP1hi58vqbhstFgxPrHwous9jRzG6dK0Aifuy9GkuSwnLMIWb4wHyRlyRfj6cWdRzauqBwS1dq7iH1Oeeo7PwtlHzlMfRhOqR1vy9GskTMuRNdPyRZEQ1IKbyXAe26bk0An4xlBRvZbwzvSoPX(aougxbHlNdbacdFqPPiCaUvi(aMAnJwFN10sy2IpAcUYvy99wFN10sy2IpyInTwlQ1cWCRV16HdToJUaqZuuTXF0eCLRWA1j0AbSwuRbaHHpayKR)sthWuRho06WL0gNKcyLvzQX(GdToGK0wFlp4QEJ5SYHO1bKKMlihkJRGWLZHaaHHpO0ueoa3keFatTMrRVZAaqy4dBmr7RsT)CqLvHW)bm16HdTgaeg(KrBMCjPNasWvtyaW)pGPwFlhYZrHwouA9bsoFfuWdUQmJCw5qEok0YH(ARpi88dCPcXHO1bKKMlip4QEJ4SYHO1bKKMlihkJRGWLZHcxsBC0foepdCLv5p06assBnJwNrxaOzkQ24pAcUYvy99cTwaRf1Aaqy4dag56V00bmLd55OqlhIncKnXdEWHY6NZkxvb4SYHO1bKKMlihYZrHwoeG010ewcIXI5qA6Z4knk0YHeu6AYAMPeeJfBnATMjrTMw6QONdLXvq4Y5qFkjLZWXSP4T(EHwZK1mAndTgaeg(aiDnnHLGyS4dykp4QYeNvoeToGK0Cb5qEok0YHs4B9kCin9zCLgfA5qj1Vw2wZGxaGVI11BTBntQzTU2mM8NyX6hznZGV1RyD2xRbiRF0ff1f9wdqwd(K2A)T2TgmkzfIT(tjP0AWvs)Bn4xlBRVz)dcBnd(V)FTwJWwN0KhksXwdP4A0GNdLXvq4Y5qm0Am4sWimB6C5yvMi4zOqZl)dcp9)9)R9qRdijT1mAndT(dYLHcPpUuAnJwNWXLdiPJFba(kZmA1vuO1AgT(oRzO1yWLGry20rtEOifpFfxJg8hADajPTE4qRbaHHpAYdfP45R4A0G)OrdwRz06m6cantr1gV1QtO1mz9T8GRAY4SYHO1bKKMlihcLYHEk4qEok0YHs44YbKehkHJNRFrCOe(wVY8YNz0QROqlhkJRGWLZHWGlbJWSPZLJvzIGNHcnV8pi80)3)V2dToGK0wZO1m06WL0gNlhRcPNWi8utEOCO1bKKMdPPpJR0Oqlhs9xHI13S)bHTMb))9)RLfRFXB2AMbFRxX6bvOyTBnCT1RqyRryRzWlaWxXAnLsRUw2wJwRfmudRZiKuJgSSyncBTlh4IFRDRHRTEfcB9GkuS(MHtAoucxcsCO7SMHwNriPgnypaumGODgk0Ket)btUwS1mADchxoGKoW1wVYmJwDffAT(wRho067SoJqsnAWEaOyar7muOjjM(dMCTyRz06eoUCajD8laWxzMrRUIcTwFlp4Qkc5SYHO1bKKMlihcLYHEk4qEok0YHs44YbKehkHlbjouchxoGKoW1wVYmJwDffA5qzCfeUCoegCjyeMnDUCSkte8muO5L)bHN()()1EO1bKK2AgToCjTX5YXQq6jmcp1KhkhADajP5qjC8C9lIdLW36vMx(mJwDffA5bx1KZzLdrRdijnxqougxbHlNdLWXLdiPtcFRxzE5ZmA1vuO1AgT(Y)GWt)F))ANy6YR9TwO1m3AgToHJlhqshaPRPjSeeJfpFXBMd55OqlhkHV1RWdUQIaoRCiADajP5cYHY4kiC5CigAnaim8X1yADzT0ed(khWuoKNJcTCixJP1L1stm4RWdUQ3yoRCiADajP5cYH8CuOLdblPxjJD4GdPPpJR0OqlhIzkPxjJD4WAye2Aga8dqjzTAGbtJcTwxWwVOW6pixgkK2AF1wVOW6bvOyTGsxtwZmLGySyougxbHlNdDN1pcucuR(Kc(bOKMegmnk0EO1bKK26HdT(rGsGA1NeiPhLKMpsMG24qRdijT13AnJwZqR)GCzOq6JlLwZO13zndTgaeg(aiDnnHLGyS4dyQ1dhA9Nss5mCmBk(dG010ewcIXITwDwZK13AnJwFN1m0Aaqy4JRX06YAPjg8voGPwpCO10sy2IprDrZanVC1A99wZK13YdUQmJCw5q06assZfKdLXvq4Y5qm06pixgkK(4sP1mA9DwNWXLdiPdCT1RmZOvxrHwRho06WXSP4e1fnd0uxK1QZAbsM13YH8CuOLdblD2Ku6rHwEWv9gXzLdrRdijnxqougxbHlNdXqR)GCzOq6JlLwZO1z0faAMIQnERvNqRzYAgT(oRzO1zucA9nojOnueJTE4qR1eaim8bw6SjP0JcThWuRVLd55OqlhsJjxdiDn98GRQamNZkhIwhqsAUGCOmUccxoh6Y)GWt)F))ANy6YR9TwO1m3AgTgaeg(OXKRbKUM(JgnyTMrRVZAaqy4dgjLZqHMaOL(dMU8AFRvNqRtM1dhADchxoGKo4ayIjmskT(woKNJcTCimskNHcnbql98GRQacWzLdrRdijnxqoKNJcTCOlhRcPNWi8utEOWHK1sZSMdjWj5COS4SKMHJztXZvvaougxbHlNdH9spPe0ghxR)dyQ1mA9DwhoMnfNOUOzGM6ISwDwNrxaOzkQ24pAcUYvy9WHwZqR)GCzOq6dgXgKSMrRZOla0mfvB8hnbx5kS(EHwNtNxUANFkTARvpRfW6B5qA6Z4knk0YHeXWw7A9BTJjRbtzX6FRuY6qHSgTK1dQqXAjAa9H1SYAsFSoP(K1duO1AT4AzBnS)bHTou81ArYawRj4kxH1iS1dQqbbgw7RyRfjdC4bxvbyIZkhIwhqsAUGCiphfA5qxowfspHr4PM8qHdPPpJR0OqlhsedB9IS21636bLuATUiRhuHsTwhkK1lP2W6KX8NfRbFY6BgoPTgTwdG(36bvOGadR9vS1IKboCOmUccxohc7LEsjOnoUw)NAT(ERtgZTw9Sg7LEsjOnoUw)hni2JcTwZO1m06pixgkK(GrSbjRz06m6cantr1g)rtWvUcRVxO1505LR25NsR2A1ZAb4bxvbsgNvoeToGK0Cb5qOuo0tbhYZrHwouchxoGK4qjCjiXHyO1yWLGry205YXQmrWZqHMx(heE6)7)x7HwhqsARho06mcj1Ob7jHV1RCW0Lx7B99wlaZTE4qRV8pi80)3)V2jMU8AFRV3AM4qA6Z4knk0YHyWiOR0W6az9lEZwRMPKYAzBnukMiRhuHI1md(wVI1WiS13S)bHTMb)3)Vwouchpx)I4qQuszTSNFkMOzcFRxz(I3mp4QkGiKZkhIwhqsAUGCiphfA5qQuszTSNFkMioKM(mUsJcTCOK6twxR1cOEmXQ1fS1cgQH11BnyQ1(QTEaAhjSo7PwRglHzlMfRryR9W6KXQOwFhtSkQ1dQqX6KM8qrk2AifxJg83AncB9afAT(M9piS1m4)()1AD9wdME4qzCfeUCouchxoGKoasxttyjiglE(I3S1mADchxoGKoQuszTSNFkMOzcFRxz(I3S1mAndT(dYLHcPpyeBqYAgT(oR1eaim8bGIbeTZqHMKy6pGPwZO1aGWWhnMCnG010F0ObR1mAnTeMT4JMGRCfwFV13znTeMT4dMytR1QVwZK1IATaj36BTE4qR)uskNHJztXFaKUMMWsqmwS13B9DwZK1QN1aGWWhn5HIu88vCnAWFatT(wRho06l)dcp9)9)RDIPlV2367TM5wFlp4QkqY5SYHO1bKKMlihkJRGWLZHs44YbK0bq6AAclbXyXZx8MTMrRVZAAjmBXNOUOzGMxUAT(ERzYAgTgaeg(OXKRbKUM(JgnyTE4qRPLWSfBT6eADYyU1dhA9Nss5mCmBkERV3AMS(woKNJcTCiaPRPjg8v4bxvbebCw5q06assZfKdLXvq4Y5qm06pixgkK(4sP1mADchxoGKo(fa4RmZOvxrHwoKNJcTCOxX1ObxKuZdUQcCJ5SYHO1bKKMlihkJRGWLZHaaHHpaseslb)4GjphwpCO1aO)TMrRHl2kXetxETV1QZ6KXCRho0Aaqy4JRX06YAPjg8voGPCiphfA5qPOOqlp4QkaZiNvoKNJcTCiajcPNWGyXCiADajP5cYdUQcCJ4SYH8CuOLdbq4NWQulBoeToGK0Cb5bxvMyoNvoKNJcTCi4ctasesZHO1bKKMlip4QYKaCw5qEok0YH8ntFGD5m7sjhIwhqsAUG8GRktmXzLdrRdijnxqoKNJcTCOaxRkuiahstFgxPrHwoustWoOmSoJwDffAFRHryRbFhqswxbD9hougxbHlNdPjaqy4dafdiANHcnjX0FatTE4qRdCTQqXje4O4)e8PjaimS1dhAnCXwjMy6YR9TwDcTMjMZdUQmLmoRCiADajP5cYHY4kiC5CinbacdFaOyar7muOjjM(dyQ1dhADGRvfkobthf)NGpnbaHHTE4qRHl2kXetxETV1QtO1mXCoKNJcTCOaxRkuWep4bh6dYLHcNvUQcWzLdrRdijnxqougxbHlNdLWXLdiPdCT1RmZOvxrHwoKNJcTCiD9PEKv4bxvM4SYH8CuOLd5xaGVchIwhqsAUG8GRAY4SYHO1bKKMlihYZrHwouwH805RGcougxbHlNdfUK24KIjXt0odfAoGCvo06assBnJwZqRdhZMIt9ta0)COS4SKMHJztXZvvaEWdoeCT1RWzLRQaCw5q06assZfKd55OqlhcGIbeTZqHMKy65qA6Z4knk0YHemudRrR1zesQrdwRdK1QquQ1HczTiXvyTMaaHHTgmLfRbxj9V1HczD4y2uyD9w7aiWW6azTUiougxbHlNdfoMnfNOUOzGM6IS(ERtgp4QYeNvoeToGK0Cb5qzCfeUCoeaim85LvMM(QN6kthmD51(wRoRHl2kXetxETV1mAnMGX0R4asId55Oqlh6LvMM(QN6kt8GRAY4SYH8CuOLdPRp1JSchIwhqsAUG8Gh8GdLGWFHwUQmXCMeG5IaMyg5qdC8wl7NdP(zqrKQIyvvFUbRTMvfY66kfHdRHryRhrtWoOmgXAmLualmPT(rxK1oyGU8G0wNv8Ln9hB8nvlzTi8gSwKOnbHdsB9iz0QbR4WSJyDGSEKmA1GvCy2dToGK0Jy9DcO2Bp2yBS6NbfrQkIvv95gS2AwviRRRueoSggHTEKumLrxaEmI1ykPawysB9JUiRDWaD5bPToR4lB6p24BQwY6KFdwls0MGWbPTEKhbkbQvFy2rSoqwpYJaLa1Qpm7Hwhqs6rS(obu7ThB8nvlzDYVbRfjAtq4G0wpYJaLa1Qpm7iwhiRh5rGsGA1hM9qRdij9iw7H1QHA6MS(obu7ThBSnw9ZGIivfXQQ(CdwBnRkK11vkchwdJWwpsw)JynMskGfM0w)OlYAhmqxEqARZk(YM(Jn(MQLSMPBWArI2eeoiT1JGbxcgHzthMDeRdK1JGbxcgHzthM9qRdij9iwFhtQ92Jn(MQLSoz3G1IeTjiCqARhbdUemcZMom7iwhiRhbdUemcZMom7Hwhqs6rS(obu7ThB8nvlzTi8gSwKOnbHdsB9iyWLGry20HzhX6az9iyWLGry20Hzp06asspI13jGAV9yJVPAjRVX3G1IeTjiCqARh5rGsGA1hMDeRdK1J8iqjqT6dZEO1bKKEeRVJj1E7XgFt1swlqYUbRfjAtq4G0wpcgCjyeMnDy2rSoqwpcgCjyeMnDy2dToGK0Jy9DcO2Bp24BQwYAMy6gSwKOnbHdsB9ibUwvO4iWHzhX6az9ibUwvO4ecCy2rS(obu7ThB8nvlzntj7gSwKOnbHdsB9ibUwvO4W0HzhX6az9ibUwvO4emDy2rS(obu7ThBSnw9ZGIivfXQQ(CdwBnRkK11vkchwdJWwpcayj1JynMskGfM0w)OlYAhmqxEqARZk(YM(Jn(MQLSoz3G1IeTjiCqARhbdUemcZMom7iwhiRhbdUemcZMom7Hwhqs6rS2dRvd10nz9DcO2Bp2yBmRkK1Ja(0Sc66hXAphfATEG)wVOWAye4QTUwRdL6TUUsr44yJfXxPiCqARfbw75OqR1Y6J)yJ5qFkL5QYKiG5COumcUKehkjjXA1eyi9bwlIqSbjBCssI1JbxYAMUrSyntmNjbSX24KKeRvd1szWG0wdqWimzDgDb4H1ae7A)J1myotPXB9Iw1tXXxWGsR9CuO9TgTsXhBSNJcT)jftz0fGhc90uP4zkQE0AJ9CuO9pPykJUa8quHJcGIqs6jS0ft6b1YEgi1wRn2ZrH2)KIPm6cWdrfo6hKldfBSNJcT)jftz0fGhIkC0lhRcPNWi8utEOWskMYOlapMpLrR(fMCwkyHyV0tkbTXX16)u79mLCBSNJcT)jftz0fGhIkCuyj9kzSdhSuWcFeOeOw9jf8dqjnjmyAuOD4WhbkbQvFsGKEusA(izcAdBSNJcT)jftz0fGhIkCumskNHcnbql9SKIPm6cWJ5tz0QFHmXsbletxETV6sMn2ZrH2)KIPm6cWdrfo6lRmn9vp1vMyjftz0fGhZNYOv)czILcwiMGX0R4asYgBJtssSwnulLbdsBnLGWIToQlY6qHS2ZbcBD9w7j8s6as6yJ9CuO9fQsLvXgNeRfr0hKldfRlyRtr)xasY67wK1jaLlHDajznT0vrV11ADgDb4XT2yphfAFrfo6hKldfBCsSweryKuA9xlBjznaim8Bn5yPyRrHcHTou81AwXGK1csoUw2w7R2AbXix)LMSXEok0(IkC0eoUCajXY6xKqCamXegjLSKWLGKqCambaHHF1XeJ3Xqaqy4tGbPja54AzFatzKHaGWWhamY1FPPdy6T24KyTASpiMSEaznBkSggukTMbVaaFfRfjdynBV23AF1w7yAhjSgtyKuwlBRfjcCdRdfYA1Kw)wdacd)w7dCX2yphfAFrfoAchxoGKyz9lsOFba(kZmA1vuOLLeUeKeMrxaOzkQ24pAcUYvCVqMefaeg(aGrU(lnDatzKwcZw89ctoZz8ogMrRgSItgbUXmuOjsR)HdbaHHpyKuodfAcGw6py6YR9VxOam)wBCsSMzwB9kw7H1xUATof9FbijRfjdy9GkuqGH1OeegwIgulBRbql4BDgDbGSofvB8Syn4kP)TggHTwWqnSEGsLvS2LdCXV1VccuQTgGSo5IATizaBSNJcTVOchnHJlhqsSS(fjeU26vMz0QROqlljCjijmJUaqZuuTXFVWC68Yv78tPvREaGWWhamY1FPPdyQ6Dhaim8bLMIWb4wH4dyQ6B4sAJtsbSYQm1yFWHwhqs6BhoKGHPCujOzgDbGMPOAJ)EH505LR25NsR2gNeRzq5ax8BThbDLgwhiRbFYAbd1WApSo5IATizawSgtSDSws)Bnc2ArYawZMwRh4Fq2yphfAFrfoAchxoGKyz9lsiCT1RmZOvxrHwwqPcX0tblfSWmcj1Ob7bGIbeTZqHMKy6pyY1IzKGHPCujOzgDbGMPOAJxDj3gNeRv)vOy9fOmQujzD4y2u8SyDOuV1jCC5asY66ToRqzviT1bYAnLlnz9afkuiS1p6ISwKj9B9RGaLARbiRFXBM0wpOcfRfu6AYAMPeeJfBJ9CuO9fv4OjCC5asIL1ViHasxttyjiglE(I3mljCjij8tjPCgoMnf)bq6AAclbXyXQJjgXEPNucAJJR1)P27zI5dhcacdFaKUMMWsqmw8btxET)9ciA4sAJJkLuwl75NIj6qRdijTn2ZrH2xuHJIb3PNJcTtz9blRFrc)GCzOWsbl8dYLHcPpUuAJ9CuO9fv4OzxkNEok0oL1hSS(fjmRFBSNJcTVOchfdUtphfANY6dww)IecxB9kSuWct44YbK0bU26vMz0QROqRn2ZrH2xuHJMDPC65Oq7uwFWY6xKqaWsQTXEok0(IkCuhN9LMbcJPnyPGfslHzl(Oj4kxX9cfi5IslHzl(Gj20AJ9CuO9fv4Ooo7lntbLpzJ9CuO9fv4OYITs8t18GA2x0g2yphfAFrfokGZEIGNbUYQ82yBCssI1ccwsnHFBSNJcT)baSKAHpL(1BJ9CuO9paGLulQWrzRG(qkE(bUuHSXEok0(haWsQfv4OVsLGLcwigCjyeMnDIAfpdKAR8eq6AYg75Oq7FaalPwuHJszfuTSNykfxx(QTXEok0(haWsQfv4OpHXEq6jaAP5NwQqSKfNL0mCmBkEHcWsbleaeg(8YkttF1tDLPdykJmuJIZtyShKEcGwA(PLk0uJItuzvQL9WHaO)zeUyRetmD51(QtyYhomJqsnAWEEcJ9G0ta0sZpTuHoxUANzfhZME1lR4y20pHXEok06s1jK5hMsUnojwNuFYAgO(ajTgsbfwpOcfRvtPPiCaUvi26c2ArIUa8WAgaf0MfB9a0osynkbHZEQ10sy2IzX6bk0ADfwpOKsRj165qk26SNATizawSgHTEGcTwd(1Y2A1CGvwfRtASpWg75Oq7FaalPwuHJMwFGKZxbfSuWcbaHHpO0ueoa3keFatz8oAjmBXhnbx5kU)oAjmBXhmXMwrfG53oCygDbGMPOAJ)Oj4kxH6ekGOaGWWhamY1FPPdy6WHHlPnojfWkRYuJ9bhADajPV1g75Oq7FaalPwuHJMwFGKZxbfSuWcbaHHpO0ueoa3keFatz8oaqy4dBmr7RsT)CqLvHW)bmD4qaqy4tgTzYLKEcibxnHba))aMERn2ZrH2)aawsTOch9RT(GWZpWLkKn2ZrH2)aawsTOchLncKnXsblmCjTXrx4q8mWvwL)qRdijnJz0faAMIQn(JMGRCf3luarbaHHpayKR)sthWuBSnojjXArIqsnAW(24KyTGsxtwZmLGySyRrR1mjQ10sxf92yphfA)tw)cbKUMMWsqmwmlfSWpLKYz4y2u83lKjgziaim8bq6AAclbXyXhWuBCsSoP(1Y2Ag8ca8vSUERDRzsnR11MXK)elw)iRzg8TEfRZ(Anaz9JUOOUO3AaYAWN0w7V1U1GrjRqS1FkjLwdUs6FRb)AzB9n7FqyRzW)9)R1Ae26KM8qrk2AifxJg82yphfA)tw)IkC0e(wVclfSqgIbxcgHztNlhRYebpdfAE5Fq4P)V)FTmYWpixgkK(4sjJjCC5as64xaGVYmJwDffAz8ogIbxcgHzthn5HIu88vCnAWpCiaim8rtEOifpFfxJg8hnAWYygDbGMPOAJxDcz6wBCsSw9xHI13S)bHTMb))9)RLfRFXB2AMbFRxX6bvOyTBnCT1RqyRryRzWlaWxXAnLsRUw2wJwRfmudRZiKuJgSSyncBTlh4IFRDRHRTEfcB9GkuS(MHtABSNJcT)jRFrfoAchxoGKyz9lsycFRxzE5ZmA1vuOLLcwigCjyeMnDUCSkte8muO5L)bHN()()1YiddxsBCUCSkKEcJWtn5HYHwhqsAws4sqs4DmmJqsnAWEaOyar7muOjjM(dMCTygt44YbK0bU26vMz0QROq7TdhExgHKA0G9aqXaI2zOqtsm9hm5AXmMWXLdiPJFba(kZmA1vuO9wBSNJcT)jRFrfoAchxoGKyz9lsycFRxzE5ZmA1vuOLLcwigCjyeMnDUCSkte8muO5L)bHN()()1Yy4sAJZLJvH0tyeEQjpuo06assZscxcsct44YbK0bU26vMz0QROqRn2ZrH2)K1VOchnHV1RWsblmHJlhqsNe(wVY8YNz0QROqlJx(heE6)7)x7etxETVqMZychxoGKoasxttyjiglE(I3Sn2ZrH2)K1VOch11yADzT0ed(kSuWcziaim8X1yADzT0ed(khWuBCsSMzkPxjJD4WAye2Aga8dqjzTAGbtJcTwxWwVOW6pixgkK2AF1wVOW6bvOyTGsxtwZmLGySyBSNJcT)jRFrfokSKELm2HdwkyH39iqjqT6tk4hGsAsyW0Oq7WHpcucuR(Kaj9OK08rYe0g3Yid)GCzOq6JlLmEhdbaHHpasxttyjigl(aMoC4Nss5mCmBk(dG010ewcIXIvht3Y4Dmeaeg(4AmTUSwAIbFLdy6WH0sy2IprDrZanVC1Ept3AJ9CuO9pz9lQWrHLoBsk9OqllfSqg(b5YqH0hxkz8UeoUCajDGRTELzgT6kk0oCy4y2uCI6IMbAQlsDcKSBTXEok0(NS(fv4OAm5AaPRPNLcwid)GCzOq6JlLmMrxaOzkQ24vNqMy8ogMrjO134KG2qrmE4qnbacdFGLoBsk9Oq7bm9wBSNJcT)jRFrfokgjLZqHMaOLEwkyHx(heE6)7)x7etxETVqMZiaim8rJjxdiDn9hnAWY4DaGWWhmskNHcnbql9hmD51(QtyYgomHJlhqshCamXegjL3AJtI1IyyRDT(T2XK1GPSy9VvkzDOqwJwY6bvOyTenG(WAwznPpwNuFY6bk0ATwCTSTg2)GWwhk(ATizaR1eCLRWAe26bvOGadR9vS1IKbo2yphfA)tw)IkC0lhRcPNWi8utEOWISwAM1cf4KCwYIZsAgoMnfVqbyPGfI9spPe0ghxR)dykJ3foMnfNOUOzGM6IuxgDbGMPOAJ)Oj4kxXWHm8dYLHcPpyeBqIXm6cantr1g)rtWvUI7fMtNxUANFkTA1tGBTXjXArmS1lYAxRFRhusP16ISEqfk1ADOqwVKAdRtgZFwSg8jRVz4K2A0Ana6FRhuHccmS2xXwlsg4yJ9CuO9pz9lQWrVCSkKEcJWtn5HclfSqSx6jLG244A9FQ9(KXC1d7LEsjOnoUw)hni2JcTmYWpixgkK(GrSbjgZOla0mfvB8hnbx5kUxyoDE5QD(P0QvpbSXjXAgmc6knSoqw)I3S1QzkPSw2wdLIjY6bvOynZGV1RynmcB9n7FqyRzW)9)R1g75Oq7FY6xuHJMWXLdijww)IeQsjL1YE(PyIMj8TEL5lEZSKWLGKqgIbxcgHztNlhRYebpdfAE5Fq4P)V)FTdhMriPgnypj8TELdMU8A)7fG5dhE5Fq4P)V)FTtmD51(3ZKnojwNuFY6ATwa1JjwTUGTwWqnSUERbtT2xT1dq7iH1zp1A1yjmBXSyncBThwNmwf167yIvrTEqfkwN0KhksXwdP4A0G)wRryRhOqR13S)bHTMb)3)VwRR3AW0Jn2ZrH2)K1VOchvLskRL98tXeXsblmHJlhqshaPRPjSeeJfpFXBMXeoUCajDuPKYAzp)umrZe(wVY8fVzgz4hKldfsFWi2GeJ3Pjaqy4dafdiANHcnjX0Fatzeaeg(OXKRbKUM(JgnyzKwcZw8rtWvUI7VJwcZw8btSPv9Ljrfi53oC4Nss5mCmBk(dG010ewcIXIV)oMupaqy4JM8qrkE(kUgn4pGP3oC4L)bHN()()1oX0Lx7FpZV1g75Oq7FY6xuHJciDnnXGVclfSWeoUCajDaKUMMWsqmw88fVzgVJwcZw8jQlAgO5LR27zIraqy4JgtUgq6A6pA0GD4qAjmBXQtyYy(WHFkjLZWXSP4VNPBTXEok0(NS(fv4OVIRrdUiPMLcwid)GCzOq6JlLmMWXLdiPJFba(kZmA1vuO1g75Oq7FY6xuHJMIIcTSuWcbaHHpaseslb)4GjphdhcG(Nr4ITsmX0Lx7RUKX8HdbaHHpUgtRlRLMyWx5aMAJ9CuO9pz9lQWrbKiKEcdIfBJ9CuO9pz9lQWrbi8tyvQLTn2ZrH2)K1VOchfUWeGeH02yphfA)tw)IkCuFZ0hyxoZUuAJtI1jnb7GYW6mA1vuO9TggHTg8DajzDf01FSXEok0(NS(fv4ObUwvOqawkyHAcaeg(aqXaI2zOqtsm9hW0HddCTQqXrGJI)tWNMaGWWdhcxSvIjMU8AF1jKjMBJ9CuO9pz9lQWrdCTQqbtSuWc1eaim8bGIbeTZqHMKy6pGPdhg4AvHIdthf)NGpnbaHHhoeUyRetmD51(Qtitm3gBJtssSMzwB9ke(TXjXAbd1WA0ADgHKA0G16azTkeLADOqwlsCfwRjaqyyRbtzXAWvs)BDOqwhoMnfwxV1oacmSoqwRlYg75Oq7FGRTEfHaumGODgk0KetplfSWWXSP4e1fnd0ux09jZg75Oq7FGRTEfrfo6lRmn9vp1vMyPGfcacdFEzLPPV6PUY0btxETV6Gl2kXetxETpJycgtVIdijBSNJcT)bU26vev4O66t9iRyJTXjjjwdfKldfBSNJcT)5dYLHIqD9PEKvyPGfMWXLdiPdCT1RmZOvxrHwBSNJcT)5dYLHIOch1VaaFfBSNJcT)5dYLHIOchnRqE68vqblzXzjndhZMIxOaSuWcdxsBCsXK4jANHcnhqUkhADajPzKHHJztXP(ja6FEWdoh]] )
    

end