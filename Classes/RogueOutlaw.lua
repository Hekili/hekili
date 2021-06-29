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


    spec:RegisterPack( "Outlaw", 20210628, [[d8Krfbqiuqpse0LqPuQnHI8jfuJsLkNsLsRIOIQxrinluu3seWUuXVuqggkfhJGAzOqpJOQMgkL01uPW2qPu9nrO04eHW5ebI1jcvZJOk3Ja7tLQoikqlKG8qcrtuesxKOcBeLs8rrG0jje0kvjEjkLsMPkf5MQuu7KO0pjQidffWrjQO0sje4PanvuQUQiuSvukfFveOglHq7fv)vrdwQdt1Ib8yrnzsDzKndQpJsgnroTKvturXRjkMnj3wH2Ts)gYWfPJlcrlhQNRQPlCDq2Uc8Dr04jQ05juZxL0(Pmxyo7CqThexwgzdJcZg2oJjIdJYNTYg2khmeNsCWuplJZI4GRpsCq5euO8KCWuxSc5Ao7CWhbHZehukI0pXhAiwvibbCYOXH(Aes5rH2m2HJH(AmpeheaQuHiC5aCqThexwgzdJcZg2oJjIdJYNTYg5lmh0HcjeMdcwJIKdkvAnTCaoOM(mhuobfkpP1IaeliYUCbAjRzmrWS1mYggfMdQQpEo7Cqnb7qQGZoxwH5SZb9CuOLdktLLHdsRdOinxiEWLLro7CqADafP5cXb10NXvAuOLdkcOpixfswxWwNI(VauK13TiRhaPwc7akYAAPXIERR16mAeWJB5GEok0Yb)GCviXdUSYNZohKwhqrAUqCqukh8PGd65OqlhCGJlhqrCWbUcI4G4aycabd)wlpRz0AMS(oRzO1aqWWNadrtaYX1Y6aLAntwZqRbGGHpayKR)sthOuRVLdQPpJR0OqlhueqyKsz9xllfznaem8Bn5yLyRrHeHToK81A2XqK1croUwww7R2AHWix)LM4GdC8C9rIdIdGjMWiLIhCzzRC25G06aksZfIdIs5GpfCqphfA5GdCC5akIdoWvqehmJgbqZuuTXF0eCLRW67fynJwlQ1aqWWhamY1FPPduQ1mznTeMLyRVxG13GnwZK13zndToJwnufNmcAJzirtKw)hADafPT(6vRbGGHpyKsndjAcGw6pyA0R9T(EbwlmBS(woOM(mUsJcTCq5yFimzDsYAwuynmKszndoca9swlsgWAwETV1(QT2X0oCynMWiLQwwwlse0gwhsK1YjT(Tgacg(T2t6I5GdC8C9rId6JaqV0mJwDffA5bx2BWzNdsRdOinxioikLd(uWb9CuOLdoWXLdOio4axbrCWmAeantr1gV13lW6C6C0L78tPvBDcynaem8baJC9xA6aLADcy9DwdabdFqPPiCaTvi(aLATCU1HROnojsOklZuJ9KhADafPT(wRVE1AcgMYrnGMz0iaAMIQnERVxG1505Ol35NsRMdQPpJR0OqlhKTuB9sw7H1JUCTof9FbOiRfjdyDYkKqqH1ObegwHswllRbql0BDgncGSofvB8mBn0QO)TggHTwOqoSoPuLLS2vjDXV1VecsPTgGS(gIATizao4ahpxFK4GW1wV0mJwDffA5bxw2oNDoiToGI0CH4GOuoiMEk4GEok0Ybh44YbuehCGJNRpsCq4ARxAMrRUIcTCWmUccxohmJqknk5EaOijr7mKOjjM(dMCTyRzYAcgMYrnGMz0iaAMIQnERLN13GdQPpJR0OqlhKbvjDXV1Ee0yAyDGSg6jRfkKdR9W6BiQ1IKby2AmXYXAf9V1iyRfjdynlAToP)bXdUSjwo7CqADafP5cXbrPCWNcoONJcTCWboUCafXbh4kiId(PKsndhZII)aOCnnHvqySyRLN1mAntwJ9spPb0ghxR)tTwFV1mYgRVE1Aaiy4dGY10ewbHXIpyA0R9T(ERf2ArToCfTXrMsPQL18tXeDO1buKMdQPpJR0OqlhmbxHK1JqQOsvK1HJzrXZS1Hu9wpWXLdOiRR36SeLLH0whiR1uU0K1jLOqIWw)OrYArMOV1VecsPTgGS(fVzsBDYkKSwiLRjRzlkimwmhCGJNRpsCqaLRPjSccJfpFXBMhCzteC25G06aksZfIdMXvq4Y5GFqUkKi9XvkoONJcTCqm0o9CuODQQp4GQ6J56Jeh8dYvHep4YMGWzNdsRdOinxioONJcTCWSRutphfANQ6doOQ(yU(iXbZ6NhCzfMnC25G06aksZfIdMXvq4Y5GdCC5ak6axB9sZmA1vuOLd65OqlhedTtphfANQ6doOQ(yU(iXbHRTEjEWLvyH5SZbP1buKMleh0ZrHwoy2vQPNJcTtv9bhuvFmxFK4GaqLsZdUScZiNDoiToGI0CH4GzCfeUCoiTeML4JMGRCfwFVaRf(gwlQ10sywIpyIfTCqphfA5Goo7lndegtBWdUSclFo7CqphfA5Goo7lntHupXbP1buKMlep4YkmBLZoh0ZrHwoOQyjf)uodKM1iTbhKwhqrAUq8GlRW3GZoh0ZrHwoiGZAIGNbUYY8CqADafP5cXdEWbtXugnc4bNDUScZzNd65Oqlh0ttvINPO6rlhKwhqrAUq8GllJC25GEok0YbbqrOi9ew5IjDYAzndKCRLdsRdOinxiEWLv(C25GEok0Yb)GCviXbP1buKMlep4YYw5SZbP1buKMleh0ZrHwo4OJLH0tyeEQjpK4GzCfeUCoi2l9KgqBCCT(p1A99wZ4n4GPykJgb8y(ugT6NdEdEWL9gC25G06aksZfIdMXvq4Y5GpcsbuR(Kc9bKIMegknk0EO1buKMd65OqlhewrVug7Wbp4YY25SZbP1buKMleh0ZrHwoigPuZqIMaOLEoygxbHlNdIPrV23A5zT85GPykJgb8y(ugT6NdYip4YMy5SZbP1buKMleh0ZrHwo4RQmn9vp1vM4GzCfeUCoiMGX0l5akIdMIPmAeWJ5tz0QFoiJ8GhCqaOsP5SZLvyo7CqphfA5GpL(1ZbP1buKMlep4YYiNDoONJcTCqwsOpuINFGlzioiToGI0CH4bxw5ZzNdsRdOinxioygxbHlNdIHwcgHzrNOwXZaj3kpbuUMo06aksZb9CuOLd(s1aEWLLTYzNd65OqlhKYsOAznXukUg9vZbP1buKMlep4YEdo7CqADafP5cXb9CuOLd(eg7bPNaOLMFAjdXbZ4kiC5Cqaiy4ZRQmn9vp1vMoqPwZK1m0AnkopHXEq6jaAP5NwYqtnkorLLPwwwF9Q1aO)TMjRHlwsXetJETV1YtG13W6RxToJqknk5EEcJ9G0ta0sZpTKHoJUCNzjhZIERtaRZsoMf9tySNJcTUYA5jWA2Cy8gCWS4SIMHJzrXZLvyEWLLTZzNdsRdOinxioONJcTCW06dKA(sOGdQPpJR0OqlhmX8K1mq9bsznOekSozfswlNstr4aARqS1fS1Ienc4H1makOnl26KOD4WA0acN9uRPLWSeZS1jLO16kSozPuwtY1ZHsS1zp1ArYamBncBDsjATg6RLL1YzHQSmwNOypjhmJRGWLZbbGGHpO0ueoG2keFGsTMjRVZAAjmlXhnbx5kS(ERVZAAjmlXhmXIwRf1AHzJ13A91RwNrJaOzkQ24pAcUYvyT8eyTWwlQ1aqWWhamY1FPPduQ1xVAD4kAJtIeQYYm1yp5HwhqrARVLhCztSC25G06aksZfIdMXvq4Y5GaqWWhuAkchqBfIpqPwZK13znaem8HfMO9LP2FMSYYq4)aLA91RwdabdFYOntUI0taf0Qjma0)hOuRVLd65OqlhmT(aPMVek4bx2ebNDoONJcTCWV26dcp)axYqCqADafP5cXdUSjiC25G06aksZfIdMXvq4Y5GHROno6chINbUYY8hADafPTMjRZOra0mfvB8hnbx5kS(EbwlS1IAnaem8baJC9xA6aLYb9CuOLdYcbXI4bp4Gz9ZzNlRWC25G06aksZfId65Oqlheq5AAcRGWyXCqn9zCLgfA5GcPCnznBrbHXITgTwZOOwtlnw0ZbZ4kiC5CWpLuQz4ywu8wFVaRz0AMSMHwdabdFauUMMWkimw8bkLhCzzKZohKwhqrAUqCqphfA5Gd8TEjoOM(mUsJcTCWeZxllRzWraOxY66T2TMr22wxBgt(tmB9JSMTX36LSo7R1aK1pAKIAKERbiRHEsBT)w7wdfLQcXw)PKszn0QO)Tg6RLL13S)bHTMb)3)VwRryRtuYdjLyRbLCnk5ZbZ4kiC5CqgAngAjyeMfDgDSmte8mKO5O)bHN()()1EO1buK2AMSMHw)b5QqI0hxPSMjRh44Ybu0XhbGEPzgT6kk0AntwFN1m0Am0sWiml6OjpKuINVKRrj)dToGI0wF9Q1aqWWhn5HKs88LCnk5F0OKR1mzDgncGMPOAJ3A5jWAgT(wEWLv(C25G06aksZfIdIs5GpfCqphfA5GdCC5akIdoWXZ1hjo4aFRxAo6ZmA1vuOLdMXvq4Y5GyOLGryw0z0XYmrWZqIMJ(heE6)7)x7HwhqrARzYAgAD4kAJZOJLH0tyeEQjpKo06aksZb10NXvAuOLdMGRqY6B2)GWwZG))()1YS1V4nBnBJV1lzDYkKS2TgU26LiS1iS1m4ia0lzTMsPvxllRrR1cfYH1zesPrjxMTgHT2vjDXV1U1W1wVeHTozfswFZWjkhCGRGio4DwZqRZiKsJsUhakss0odjAsIP)Gjxl2AMSEGJlhqrh4ARxAMrRUIcTwFR1xVA9DwNriLgLCpauKKODgs0Ket)btUwS1mz9ahxoGIo(ia0lnZOvxrHwRVLhCzzRC25G06aksZfIdIs5GpfCqphfA5GdCC5akIdoWvqehCGJlhqrh4ARxAMrRUIcTCWmUccxohedTemcZIoJowMjcEgs0C0)GWt)F))Ap06aksBntwhUI24m6yzi9egHNAYdPdToGI0CWboEU(iXbh4B9sZrFMrRUIcT8Gl7n4SZbP1buKMlehmJRGWLZbh44Ybu0zGV1lnh9zgT6kk0Antwp6Fq4P)V)FTtmn61(wlWA2yntwpWXLdOOdGY10ewbHXINV4nZb9CuOLdoW36L4bxw2oNDoiToGI0CH4GzCfeUCoidTgacg(4AmTUQwAIHEPdukh0ZrHwoORX06QAPjg6L4bx2elNDoiToGI0CH4GEok0YbHv0lLXoCWb10NXvAuOLdYwu0lLXoCynmcBnda9bKISwoWqPrHwRlyRxuy9hKRcjsBTVARxuyDYkKSwiLRjRzlkimwmhmJRGWLZbFeKcOw9jf6difnjmuAuO9qRdOiT1mzndT(dYvHePpUszntwFN1m0Aaiy4dGY10ewbHXIpqPwF9Q1FkPuZWXSO4pakxttyfegl2A5znJwFR1mz9DwZqRbGGHpUgtRRQLMyOx6aLA91RwtlHzj(e1ind0C0LR13BnJwFlp4YMi4SZbP1buKMlehmJRGWLZbzO1FqUkKi9XvkRzY67SEGJlhqrh4ARxAMrRUIcTwF9Q1HJzrXjQrAgOPUiRLN1clFRVLd65Oqlhew5SiLYJcT8GlBccNDoiToGI0CH4GzCfeUCoidT(dYvHePpUszntwNrJaOzkQ24TwEcSMrRzY67SMHwNrdO134mG2qsm26RxTwtaqWWhyLZIukpk0EGsT(woONJcTCqnMCnGY10ZdUScZgo7CqADafP5cXbZ4kiC5CWr)dcp9)9)RDIPrV23AbwZgRzYAaiy4JgtUgq5A6pAuY1AMS(oRbGGHpyKsndjAcGw6pyA0R9TwEcSw(wF9Q1dCC5ak6GdGjMWiLY6B5GEok0YbXiLAgs0eaT0ZdUSclmNDoiToGI0CH4GEok0YbhDSmKEcJWtn5HehuvlnZAoOWNBWbZIZkAgoMffpxwH5GzCfeUCoi2l9KgqBCCT(pqPwZK13zD4ywuCIAKMbAQlYA5zDgncGMPOAJ)Oj4kxH1xVAndT(dYvHePpyeliYAMSoJgbqZuuTXF0eCLRW67fyDoDo6YD(P0QTobSwyRVLdQPpJR0OqlhuecBTR1V1oMSgkLzR)TsjRdjYA0swNScjRvOK0hwZo7j6X6eZtwNuIwR1IRLL1W(he26qYxRfjdyTMGRCfwJWwNScjeuyTVITwKmWHhCzfMro7CqADafP5cXb9CuOLdo6yzi9egHNAYdjoOM(mUsJcTCqriS1lYAxRFRtwkL16ISozfs1ADirwVKCdRLpBEMTg6jRVz4e1A0Ana6FRtwHeckS2xXwlsg4WbZ4kiC5CqSx6jnG244A9FQ167Tw(SX6eWASx6jnG244A9F0qypk0AntwZqR)GCvir6dgXcISMjRZOra0mfvB8hnbx5kS(EbwNtNJUCNFkTARtaRfMhCzfw(C25G06aksZfIdIs5GpfCqphfA5GdCC5akIdoWvqehKHwJHwcgHzrNrhlZebpdjAo6Fq4P)V)FThADafPT(6vRZiKsJsUNb(wV0btJETV13BTWSX6RxTE0)GWt)F))ANyA0R9T(ERzKdQPpJR0OqlhKbJGgtdRdK1V4nBnBRsPQLL1GPyISozfswZ24B9swdJWwFZ(he2Ag8F))A5GdC8C9rIdktPu1YA(PyIMd8TEP5lEZ8GlRWSvo7CqADafP5cXb9CuOLdktPu1YA(PyI4GA6Z4knk0YbtmpzDTwlCcWi7wxWwluihwxV1qPw7R26KOD4W6SNATCSeMLyMTgHT2dRLp7IA9DmYUOwNScjRtuYdjLyRbLCnk5FR1iS1jLO16B2)GWwZG)7)xR11Bnu6HdMXvq4Y5GdCC5ak6aOCnnHvqyS45lEZwZK1dCC5ak6itPu1YA(PyIMd8TEP5lEZwZK1m06pixfsK(GrSGiRzY67SwtaqWWhakss0odjAsIP)aLAntwdabdF0yY1akxt)rJsUwZK10sywIpAcUYvy99wFN10sywIpyIfTwlNBnJwlQ1cFdRV16RxT(tjLAgoMff)bq5AAcRGWyXwFV13znJwNawdabdF0KhskXZxY1OK)bk16BT(6vRh9pi80)3)V2jMg9AFRV3A2y9T8GlRW3GZohKwhqrAUqCWmUccxohCGJlhqrhaLRPjSccJfpFXB2AMS(oRPLWSeFIAKMbAo6Y167TMrRzYAaiy4JgtUgq5A6pAuY16RxTMwcZsS1YtG1YNnwF9Q1FkPuZWXSO4T(ERz06B5GEok0YbbuUMMyOxIhCzfMTZzNdsRdOinxioygxbHlNdYqR)GCvir6JRuwZK1dCC5ak64JaqV0mJwDffA5GEok0YbFjxJsosknp4YkCILZohKwhqrAUqCWmUccxoheacg(aOqiTc6JdM8Cy91RwdG(3AMSgUyjftmn61(wlpRLpBS(6vRbGGHpUgtRRQLMyOx6aLYb9CuOLdMIIcT8GlRWjco7CqphfA5GakespHHWI5G06aksZfIhCzfobHZoh0ZrHwoiaHFcltTS4G06aksZfIhCzzKnC25GEok0YbHlmbOqinhKwhqrAUq8GllJcZzNd65Oqlh03m9b2vZSRuCqADafP5cXdUSmYiNDoiToGI0CH4GEok0YbdCTYqHWCqn9zCLgfA5Gjkb7qQW6mA1vuO9TggHTg6DafzDf04F4GzCfeUCoOMaGGHpauKKODgs0Ket)bk16RxToW1kdfNq4JK)tONMaqWWwF9Q1WflPyIPrV23A5jWAgzdp4YYO85SZbP1buKMlehmJRGWLZb1eaem8bGIKeTZqIMKy6pqPwF9Q1bUwzO4emEK8Fc90eacg26RxTgUyjftmn61(wlpbwZiB4GEok0YbdCTYqbJ8GhCWpixfsC25YkmNDoiToGI0CH4GzCfeUCo4ahxoGIoW1wV0mJwDffA5GEok0Yb11N6rwIhCzzKZoh0ZrHwoOpca9sCqADafP5cXdUSYNZohKwhqrAUqCqphfA5GzjYtNVek4GzCfeUCoy4kAJtkMepr7mKOzsYL5qRdOiT1mzndToCmlko1pbq)ZbZIZkAgoMffpxwH5bp4GW1wVeNDUScZzNdsRdOinxioONJcTCqakss0odjAsIPNdQPpJR0OqlhuOqoSgTwNriLgLCToqwldrPwhsK1IexH1Acacg2AOuMTgAv0)whsK1HJzrH11BTdGGcRdK16I4GzCfeUCoy4ywuCIAKMbAQlY67Tw(8GllJC25G06aksZfIdMXvq4Y5GaqWWNxvzA6REQRmDW0Ox7BT8SgUyjftmn61(wZK1ycgtVKdOioONJcTCWxvzA6REQRmXdUSYNZoh0ZrHwoOU(upYsCqADafP5cXdEWdo4ac)fA5YYiByuy2W2zmXYbt64TwwphmbZGIazfHYMGM4wBn7sK11ykchwdJWwpSMGDivmS1ykrcvysB9JgjRDOan6bPTol5ll6p2LBQwYA2AIBTir7achK26HZOvdvXreh26az9Wz0QHQ4iIhADafPh267ewU3ESl2LemdkcKvekBcAIBT1SlrwxJPiCynmcB9WPykJgb8yyRXuIeQWK26hnsw7qbA0dsBDwYxw0FSl3uTK13iXTwKODaHdsB9WpcsbuR(iIdBDGSE4hbPaQvFeXdToGI0dBThwlhYPBY67ewU3ESl2LemdkcKvekBcAIBT1SlrwxJPiCynmcB9Wz9pS1ykrcvysB9JgjRDOan6bPTol5ll6p2LBQwYAgtCRfjAhq4G0wpmgAjyeMfDeXHToqwpmgAjyeMfDeXdToGI0dB9Dmk3Bp2LBQwYA5N4wls0oGWbPTEym0sWiml6iIdBDGSEym0sWiml6iIhADafPh267ewU3ESl3uTK1S1e3ArI2beoiT1dJHwcgHzrhrCyRdK1dJHwcgHzrhr8qRdOi9WwFNWY92JD5MQLSoXM4wls0oGWbPTE4hbPaQvFeXHToqwp8JGua1QpI4Hwhqr6HT(oHL7Th7YnvlzTWYpXTwKODaHdsB9WyOLGryw0reh26az9WyOLGryw0rep06akspS13jSCV9yxUPAjRzKXe3ArI2beoiT1dh4ALHIJWhrCyRdK1dh4ALHIti8reh267ewU3ESl3uTK1mk)e3ArI2beoiT1dh4ALHIdJhrCyRdK1dh4ALHItW4reh267ewU3ESl2LemdkcKvekBcAIBT1SlrwxJPiCynmcB9WaqLspS1ykrcvysB9JgjRDOan6bPTol5ll6p2LBQwYA5N4wls0oGWbPTEym0sWiml6iIdBDGSEym0sWiml6iIhADafPh2ApSwoKt3K13jSCV9yxSlSlrwpm0tZkOXFyR9CuO16K(B9IcRHrqR26AToKQ36AmfHJJDreoMIWbPTMTBTNJcTwRQp(JDHd(PuMllJSD2WbtXi4srCWeMqRLtqHYtATiaXcISljmHwFbAjRzmrWS1mYggf2UyxsycTwoKlLHcsBnabJWK1z0iGhwdqSQ9pwZG5mLgV1lAtajhpcdPS2ZrH23A0QeFSlEok0(NumLrJaEiWttvINPO6rRDXZrH2)KIPmAeWdrfmeakcfPNWkxmPtwlRzGKBT2fphfA)tkMYOrapevWqFqUkKSlEok0(NumLrJaEiQGHgDSmKEcJWtn5HeZPykJgb8y(ugT6xWnyUGfG9spPb0ghxR)tT3Z4nSlEok0(NumLrJaEiQGHGv0lLXoCWCbl4rqkGA1NuOpGu0KWqPrHw7INJcT)jftz0iGhIkyimsPMHenbql9mNIPmAeWJ5tz0QFbmYCblatJETV8KVDXZrH2)KIPmAeWdrfm0RQmn9vp1vMyoftz0iGhZNYOv)cyK5cwaMGX0l5akYUyxsycTwoKlLHcsBnnGWIToQrY6qIS2ZbcBD9w7d8s5ak6yx8CuO9fitLLXUKqRfb0hKRcjRlyRtr)xakY67wK1dGulHDafznT0yrV11ADgnc4XT2fphfAFrfm0hKRcj7scTweqyKsz9xllfznaem8Bn5yLyRrHeHToK81A2XqK1croUwww7R2AHWix)LMSlEok0(IkyOboUCafX86JKaCamXegPumpWvqKaCambGGHF5Xit3Xqaiy4tGHOja54AzDGszIHaqWWhamY1FPPdu6T2LeATCSpeMSojznlkSggsPSMbhbGEjRfjdynlV23AF1w7yAhoSgtyKsvllRfjcAdRdjYA5Kw)wdabd)w7jDX2fphfAFrfm0ahxoGIyE9rsGpca9sZmA1vuOL5bUcIeKrJaOzkQ24pAcUYvCVagffacg(aGrU(lnDGszIwcZs89cUbBy6ogMrRgQItgbTXmKOjsR)RxbGGHpyKsndjAcGw6pyA0R9VxGWS5w7scTMTuB9sw7H1JUCTof9FbOiRfjdyDYkKqqH1ObegwHswllRbql0BDgncGSofvB8mBn0QO)TggHTwOqoSoPuLLS2vjDXV1VecsPTgGS(gIATiza7INJcTVOcgAGJlhqrmV(ijaU26LMz0QROqlZdCfejiJgbqZuuTXFVGC6C0L78tPvNaaqWWhamY1FPPduAcChaem8bLMIWb0wH4duQCE4kAJtIeQYYm1yp5Hwhqr6BVELGHPCudOzgncGMPOAJ)Eb505Ol35NsR2UKqRzqvsx8BThbnMgwhiRHEYAHc5WApS(gIATizaMTgtSCSwr)Bnc2ArYawZIwRt6Fq2fphfAFrfm0ahxoGIyE9rsaCT1lnZOvxrHwMrPcW0tbZfSGmcP0OK7bGIKeTZqIMKy6pyY1IzIGHPCudOzgncGMPOAJxE3WUKqRtWviz9iKkQufzD4ywu8mBDivV1dCC5akY66TolrzziT1bYAnLlnzDsjkKiS1pAKSwKj6B9lHGuARbiRFXBM0wNScjRfs5AYA2IccJfBx8CuO9fvWqdCC5akI51hjbakxttyfeglE(I3mZdCfej4tjLAgoMff)bq5AAcRGWyXYJrMWEPN0aAJJR1)P27zKnxVcabdFauUMMWkimw8btJET)9clA4kAJJmLsvlR5NIj6qRdOiTDXZrH2xubdHH2PNJcTtv9bZRpsc(GCviXCbl4dYvHePpUszx8CuO9fvWqzxPMEok0ov1hmV(ijiRF7INJcTVOcgcdTtphfANQ6dMxFKeaxB9smxWcg44Ybu0bU26LMz0QROqRDXZrH2xubdLDLA65Oq7uvFW86JKaaOsPTlEok0(IkyihN9LMbcJPnyUGfqlHzj(Oj4kxX9ce(gIslHzj(Gjw0Ax8CuO9fvWqoo7lntHupzx8CuO9fvWqQILu8t5mqAwJ0g2fphfAFrfmeGZAIGNbUYY82f7sctO1cbvknHF7INJcT)baQuAbpL(1Bx8CuO9paqLslQGHyjH(qjE(bUKHSlEok0(haOsPfvWqVunG5cwagAjyeMfDIAfpdKCR8eq5AYU45Oq7FaGkLwubdrzjuTSMykfxJ(QTlEok0(haOsPfvWqpHXEq6jaAP5NwYqmNfNv0mCmlkEbcZCblaacg(8QkttF1tDLPduktmuJIZtyShKEcGwA(PLm0uJItuzzQL11RaO)zcUyjftmn61(YtWnUEnJqknk5EEcJ9G0ta0sZpTKHoJUCNzjhZI(eil5yw0pHXEok06k5jGnhgVHDjHwNyEYAgO(aPSgucfwNScjRLtPPiCaTvi26c2ArIgb8WAgaf0MfBDs0oCynAaHZEQ10sywIz26Ks0ADfwNSukRj565qj26SNATizaMTgHToPeTwd91YYA5SqvwgRtuSN0U45Oq7FaGkLwubdLwFGuZxcfmxWcaGGHpO0ueoG2keFGsz6oAjmlXhnbx5kU)oAjmlXhmXIwrfMn3E9AgncGMPOAJ)Oj4kxH8eiSOaqWWhamY1FPPdu61RHROnojsOklZuJ9KhADafPV1U45Oq7FaGkLwubdLwFGuZxcfmxWcaGGHpO0ueoG2keFGsz6oaiy4dlmr7ltT)mzLLHW)bk96vaiy4tgTzYvKEcOGwnHbG()aLERDXZrH2)aavkTOcg6RT(GWZpWLmKDXZrH2)aavkTOcgIfcIfXCbliCfTXrx4q8mWvwM)qRdOintz0iaAMIQn(JMGRCf3lqyrbGGHpayKR)sthOu7IDjHj0ArIqknk5(2LeATqkxtwZwuqySyRrR1mkQ10sJf92fphfA)tw)cauUMMWkimwmZfSGpLuQz4ywu83lGrMyiaem8bq5AAcRGWyXhOu7scToX81YYAgCea6LSUERDRzKTT11MXK)eZw)iRzB8TEjRZ(Anaz9JgPOgP3AaYAON0w7V1U1qrPQqS1FkPuwdTk6FRH(Azz9n7FqyRzW)9)R1Ae26eL8qsj2AqjxJs(2fphfA)tw)IkyOb(wVeZfSagIHwcgHzrNrhlZebpdjAo6Fq4P)V)FTmXWpixfsK(4kftdCC5ak64JaqV0mJwDffAz6ogIHwcgHzrhn5HKs88LCnk5F9kaem8rtEiPepFjxJs(hnk5YugncGMPOAJxEcy8w7scTobxHK13S)bHTMb))9)RLzRFXB2A2gFRxY6KvizTBnCT1lryRryRzWraOxYAnLsRUwwwJwRfkKdRZiKsJsUmBncBTRs6IFRDRHRTEjcBDYkKS(MHtu7INJcT)jRFrfm0ahxoGIyE9rsWaFRxAo6ZmA1vuOL5cwagAjyeMfDgDSmte8mKO5O)bHN()()1YeddxrBCgDSmKEcJWtn5H0HwhqrAMh4kisWDmmJqknk5EaOijr7mKOjjM(dMCTyMg44Ybu0bU26LMz0QROq7TxVExgHuAuY9aqrsI2zirtsm9hm5AXmnWXLdOOJpca9sZmA1vuO9w7INJcT)jRFrfm0ahxoGIyE9rsWaFRxAo6ZmA1vuOL5cwagAjyeMfDgDSmte8mKO5O)bHN()()1Yu4kAJZOJLH0tyeEQjpKo06aksZ8axbrcg44Ybu0bU26LMz0QROqRDXZrH2)K1VOcgAGV1lXCblyGJlhqrNb(wV0C0Nz0QROqltJ(heE6)7)x7etJETVa2W0ahxoGIoakxttyfeglE(I3SDXZrH2)K1VOcgY1yADvT0ed9smxWcyiaem8X1yADvT0ed9shOu7scTMTOOxkJD4WAye2Aga6difzTCGHsJcTwxWwVOW6pixfsK2AF1wVOW6KvizTqkxtwZwuqySy7INJcT)jRFrfmeSIEPm2HdMlybpcsbuR(Kc9bKIMegknk0Yed)GCvir6JRumDhdbGGHpakxttyfegl(aLE96Nsk1mCmlk(dGY10ewbHXILhJ3Y0Dmeacg(4AmTUQwAIHEPdu61R0sywIprnsZanhD5EpJ3Ax8CuO9pz9lQGHGvolsP8OqlZfSag(b5QqI0hxPy6UboUCafDGRTEPzgT6kk0E9A4ywuCIAKMbAQlsEcl)BTlEok0(NS(fvWqAm5AaLRPN5cwad)GCvir6JRumLrJaOzkQ24LNagz6ogMrdO134mG2qsm(6vnbabdFGvolsP8Oq7bk9w7INJcT)jRFrfmegPuZqIMaOLEMlybJ(heE6)7)x7etJETVa2Weaem8rJjxdOCn9hnk5Y0DaqWWhmsPMHenbql9hmn61(YtG8VEDGJlhqrhCamXegPu3AxsO1IqyRDT(T2XK1qPmB9VvkzDirwJwY6KvizTcLK(WA2zprpwNyEY6Ks0ATwCTSSg2)GWwhs(ATizaR1eCLRWAe26KviHGcR9vS1IKbo2fphfA)tw)IkyOrhldPNWi8utEiXSQwAM1ce(CdMZIZkAgoMffVaHzUGfG9spPb0ghxR)dukt3foMffNOgPzGM6IKxgncGMPOAJ)Oj4kxX1Rm8dYvHePpyeliIPmAeantr1g)rtWvUI7fKtNJUCNFkT6eq4BTlj0AriS1lYAxRFRtwkL16ISozfs1ADirwVKCdRLpBEMTg6jRVz4e1A0Ana6FRtwHeckS2xXwlsg4yx8CuO9pz9lQGHgDSmKEcJWtn5HeZfSaSx6jnG244A9FQ9E5ZMea7LEsdOnoUw)hne2JcTmXWpixfsK(GrSGiMYOra0mfvB8hnbx5kUxqoDo6YD(P0QtaHTlj0AgmcAmnSoqw)I3S1STkLQwwwdMIjY6KviznBJV1lznmcB9n7FqyRzW)9)R1U45Oq7FY6xubdnWXLdOiMxFKeitPu1YA(PyIMd8TEP5lEZmpWvqKagIHwcgHzrNrhlZebpdjAo6Fq4P)V)FTxVMriLgLCpd8TEPdMg9A)7fMnxVo6Fq4P)V)FTtmn61(3ZODjHwNyEY6ATw4eGr2TUGTwOqoSUERHsT2xT1jr7WH1zp1A5yjmlXmBncBThwlF2f167yKDrTozfswNOKhskXwdk5AuY)wRryRtkrR13S)bHTMb)3)VwRR3AO0JDXZrH2)K1VOcgsMsPQL18tXeXCblyGJlhqrhaLRPjSccJfpFXBMPboUCafDKPuQAzn)umrZb(wV08fVzMy4hKRcjsFWiwqet3Pjaiy4dafjjANHenjX0FGszcacg(OXKRbuUM(JgLCzIwcZs8rtWvUI7VJwcZs8btSOvoNrrf(g3E96Nsk1mCmlk(dGY10ewbHXIV)ogtaaiy4JM8qsjE(sUgL8pqP3E96O)bHN()()1oX0Ox7FpBU1U45Oq7FY6xubdbOCnnXqVeZfSGboUCafDauUMMWkimw88fVzMUJwcZs8jQrAgO5Ol37zKjaiy4JgtUgq5A6pAuY96vAjmlXYtG8zZ1RFkPuZWXSO4VNXBTlEok0(NS(fvWqVKRrjhjLM5cwad)GCvir6JRumnWXLdOOJpca9sZmA1vuO1U45Oq7FY6xubdLIIcTmxWcaGGHpakesRG(4GjphxVcG(Nj4ILumX0Ox7lp5ZMRxbGGHpUgtRRQLMyOx6aLAx8CuO9pz9lQGHauiKEcdHfBx8CuO9pz9lQGHai8tyzQLLDXZrH2)K1VOcgcUWeGcH02fphfA)tw)IkyiFZ0hyxnZUszxsO1jkb7qQW6mA1vuO9TggHTg6DafzDf04FSlEok0(NS(fvWqbUwzOqyMlybAcacg(aqrsI2zirtsm9hO0RxdCTYqXr4JK)tONMaqWWxVcxSKIjMg9AF5jGr2yx8CuO9pz9lQGHcCTYqbJmxWc0eaem8bGIKeTZqIMKy6pqPxVg4ALHIdJhj)NqpnbGGHVEfUyjftmn61(YtaJSXUyxsycTMTuB9se(Tlj0AHc5WA0ADgHuAuY16azTmeLADirwlsCfwRjaiyyRHsz2AOvr)BDirwhoMffwxV1oackSoqwRlYU45Oq7FGRTEjbauKKODgs0KetpZfSGWXSO4e1ind0ux09Y3U45Oq7FGRTEjrfm0RQmn9vp1vMyUGfaabdFEvLPPV6PUY0btJETV8GlwsXetJETptycgtVKdOi7INJcT)bU26LevWq66t9ilzxSljmHwdgKRcj7INJcT)5dYvHKaD9PEKLyUGfmWXLdOOdCT1lnZOvxrHw7INJcT)5dYvHKOcgYhbGEj7INJcT)5dYvHKOcgklrE68LqbZzXzfndhZIIxGWmxWccxrBCsXK4jANHentsUmhADafPzIHHJzrXP(ja6FEWdoh]] )


end