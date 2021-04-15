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
        cheap_tricks = 142, -- 212035
        control_is_king = 138, -- 212217
        death_from_above = 3619, -- 269513
        dismantle = 145, -- 207777
        drink_up_me_hearties = 139, -- 212210
        honor_among_thieves = 3451, -- 198032
        maneuverability = 129, -- 197000
        plunder_armor = 150, -- 198529
        shiv = 3449, -- 248744
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
                    gain( buff.broadside.up and 3 or 2, "combo_points" )
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

                gain( 1, "combo_points" )
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
                gain( buff.broadside.up and 2 or 1, "combo_points" )
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
                gain( buff.broadside.up and 2 or 1, "combo_points" )
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
                gain( buff.broadside.up and 2 or 1, "combo_points" )
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
                    gain( 1 + ( buff.broadside.up and 1 or 0 ) + ( buff.opportunity.up and 1 or 0 ) + ( buff.concealed_blunderbuss.up and 2 or 0 ), "combo_points" )
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
                gain( buff.broadside.up and 2 or 1, "combo_point" )
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
                    gain( buff.broadside.up and 2 or 1, "combo_points" )
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


    spec:RegisterPack( "Outlaw", 20210414, [[d8urbbqickpIOsxIOKInbr9javJcq5uasRIOKQxrOmliYTuazxQYVuGggeQJbblds5zkatJOQ6AkOSnIk4BeLkghrPsNtbuSofKAEev5EeyFaIdQGQfsqEibvtKOQCrIszJkiXhvaLojrjALa4LqikZKOeUjec7KO4NeLQgkeshfcr1sjkjpfOPcP6QevOTcHiFvbunwIkAVO6VkAWsDyQwSQ6XsAYKCzKnJIpdjJMiNw0QjkP0RjunBsDBfA3k9BqdxIoUcsA5q9CvMUW1rPTlbFxcnEfeNNqMpaTFkZrGJohu5bXLbneJgciw(rq(FOHgAiGy5ahmevsCWsVkUJI4GRpsCqzpBO9ICWsxKg6ko6CWdYIRehukIYBOhCquziX(Fv44GxoYQ9iHBf7mXGxowhKd(ztDilx(NdQ8G4YGgIrdbel)ii)p0qdneq8a4GoBibXCqWCu4CqPuPOL)5Gk6QCqzpBO9IwlRGOyjdGHxItT1ii)iznAigne4G68IJJohurmoRo4OZLbbo6CqVgjC5GINvX5G06FnP4cXdUmOXrNdsR)1KIlehurxfNLrcxoOSIUGCDizDYyDj8U8RjRb2cTUaREjS)1K10sJjDwNR1v443dGYb9AKWLdEb56qIhCzgahDoiT(xtkUqCqyjh8OGd61iHlhSGJt)RjoybxZsCqC8NFwgMZA5znAwJS1aZAHz9NLH5fywA(jhNlQhBP1iBTWS(ZYW8(yORUurp2sRbkhurxfNLrcxoOSIWqT26lxuAY6pldZzn5yTiRHHeHToK81A0XSK1crooxuw7RYAHWqxDPI4GfC8C9rIdIJ)etyOwZdUmYphDoiT(xtkUqCqyjh8OGd61iHlhSGJt)RjoybxZsCWkC8dNLWCJ7PiMSMH1arG1OzTyw)zzyEFm0vxQOhBP1iBnTegLiRbIaRhgITgzRbM1cZ6kCvSz8Qq2nMHenHk19O1)AsznGaA9NLH5HHA9mKO5hU09W0ON7znqeynci2AGYbv0vXzzKWLdkB7XIjRlswJIcRzy1ARh(4N9KSw4iQ1O8CpR9vzTJPf4H1ycd16CrzTWHSByDirwl7vQZ6pldZzTx0fXbl4456Jeh0h)SN0ScxvgjC5bxMHXrNdsR)1KIlehewYbpk4GEns4Ybl440)AIdwW1SehSch)Wzjm34SgicSUwoh9HmVsAvwpqw)zzyEFm0vxQOhBP1dK1aZ6pldZdwwcXb7MHOhBP1Y6whUM24nuzZQ4tf2l(O1)AsznqTgqaTUch)Wzjm34SwG1(MJEvYXOi1SwYbv0vXzzKWLdouYnpjR9W6rFiwxcVl)AYAHJOwxmdjiBynSaHz0WI5IY6pCzpRRWXp06syUXHK1SRMUZAgi2AHczZ6IszvYAxx0fDwFsqwTY6pz9WeZAHJOCWcoEU(iXbzYnpPzfUQms4YdUmYbo6CqA9VMuCH4GWsoiMok4GEns4Ybl440)AIdwWXZ1hjoitU5jnRWvLrcxoyfNbHtNdwHqTcwCFFkks0odjAsIO7HjxjYAKTMyyOAKfOzfo(HZsyUXzT8SEyCqfDvCwgjC5Gdxx0fDw7rqJLH1b0A2JSwOq2S2dRhMywlCefjRXekhR00DwdzSw4iQ1OO16I(fep4Yi7WrNdsR)1KIlehewYbpk4GEns4Ybl440)AIdwW1Seh8kjTEgogff37RDfnz0SySiRLN1OznYwJ9unPc0gpxPUxUwdeRrdXwdiGw)zzyEFTROjJMfJf9W0ON7znqSgbRfZ6W10gpXtToxuZRet0Jw)RjfhurxfNLrcxo4apdjRhz1rwQjRdhJIIdjRdP8SUGJt)RjRZZ6QevfNuwhqRvunvK1fLOqIWwFWrYAHlFN1NeKvRS(twFI2kPSUygswlK2vK1dfnlglIdwWXZ1hjo4x7kAYOzXyrZt0w5bxgzxo6CqA9VMuCH4GvCgeoDo4fKRdjs9CTMd61iHlheZUtVgjCN68coOoVyU(iXbVGCDiXdUmdmC05G06FnP4cXb9AKWLdwDTE61iH7uNxWb15fZ1hjoyvD8GldciMJohKw)RjfxioyfNbHtNdwWXP)10Jj38KMv4QYiHlh0RrcxoiMDNEns4o15fCqDEXC9rIdYKBEs8GldciWrNdsR)1KIleh0Rrcxoy116PxJeUtDEbhuNxmxFK4GF2uR4bxgeqJJohKw)RjfxioyfNbHtNdslHrj6PiMSMH1arG1immRfZAAjmkrpmHIwoOxJeUCqhx9LMbeJPn4bxgegahDoOxJeUCqhx9LMLS6J4G06FnP4cXdUmii)C05GEns4Yb1jkP4MYAzvOgPn4G06FnP4cXdUmimmo6CqVgjC5GFh1eYmdCwf)4G06FnP4cXdEWblXufo(9GJoxge4OZb9AKWLd6LLArZsyEWLdsR)1KIlep4YGghDoOxJeUCWpmcnPMmAxePkMlQzahsUCqA9VMuCH4bxMbWrNd61iHlh8cY1HehKw)RjfxiEWLr(5OZbP1)AsXfId61iHlhC0XItQjdepvKhsCWkodcNohe7PAsfOnEUsDVCTgiwJ2W4GLyQch)EmpQcx1Xbhgp4Ymmo6CqA9VMuCH4GEns4YbXqTEgs08dx64GvCgeoDoiMg9CpRLN1dGdwIPkC87X8OkCvhhenEWLroWrNdsR)1KIleh0Rrcxo4PZkn9vnvzL4GvCgeoDoiMyW0j5FnXblXufo(9yEufUQJdIgp4bh8ZMAfhDUmiWrNd61iHlh8OYlpoiT(xtkUq8GldAC05GEns4YbrjbVqlAEbofN4G06FnP4cXdUmdGJohKw)RjfxioyfNbHtNdIzxIbIrrVixrZaoKSo)AxrpA9VMuCqVgjC5GNuwGhCzKFo6CqVgjC5GuvcMlQjMkX5OVkoiT(xtkUq8GlZW4OZbP1)AsXfId61iHlh8im2dsn)WLMxzkoXbR4miC6CqHzTcgVJWypi18dxAELP40lYQ45IYAab0AVgzbAslnM0zTaRrWAKTg7PAsfOnEUsDVCTgiwZWQ1tmvLCmkAg5iznGaADvYXOOZAGynAwJS1F4DwJS1mjkPyIPrp3ZA5z9W4GvrvnndhJIIJldc8GlJCGJohKw)RjfxioOxJeUCWY8cOEEsWGdQORIZYiHlhuoEK1iAEbuBnOemSUygswl7llH4GDZqK1jJ1cho(9WAefg0wfzDr4c8WAybcx9sRPLWOeHK1fLO16mSUyQ1wtdXRHwK1vV0AHJOizneBDrjATM9YfL1iYzZQ4wlFyVihSIZGWPZb)SmmpyzjehSBgIESLwJS1aZAAjmkrpfXK1mSgiwdmRPLWOe9WekATwmRraXwduRbeqRRWXpCwcZnUNIyYAgwlpbwJG1Iz9NLH59XqxDPIESLwdiGwhUM24nuzZQ4tf2l(O1)Asznq5bxgzho6CqA9VMuCH4GvCgeoDo4NLH5bllH4GDZq0JT0AKTgyw)zzyEOWeTN45EZIzvCcFp2sRbeqR)SmmVkCRKRj18RzxfH)S39ylTgOCqVgjC5GL5fq98KGbp4Yi7YrNd61iHlh8YnVGWZlWP4ehKw)RjfxiEWLzGHJohKw)RjfxioyfNbHtNdgUM24PsCiAg4Sk(9O1)AsznYwxHJF4SeMBCpfXK1mSgicSgbRfZ6pldZ7JHU6sf9yl5GEns4Ybrbzrr8GhCWQ64OZLbbo6CqA9VMuCH4GEns4Yb)AxrtgnlglIdQORIZYiHlhuiTRiRhkAwmwK1W1A0eZAAPXKooyfNbHtNdELKwpdhJIIZAGiWA0SgzRfM1FwgM3x7kAYOzXyrp2sEWLbno6CqA9VMuCH4GEns4Ybl4BEsCqfDvCwgjC5GYXlxuwp8Xp7jzDEw7wJMSgRZTIj)iKS(GwJi5BEswx916pz9bhPihPZ6pzn7rkR9ZA3A2i1ziY6RK0ARzxnDN1SxUOSgr4xqyRh(D(D5AneBT8rEiPfznOKRGfpoyfNbHtNdkmRXSlXaXOO3OJfFczMHenh9li80VZVl3hT(xtkRr2AHz9fKRdjs9CT2AKTUGJt)RPNp(zpPzfUQms4AnYwdmRfM1y2LyGyu0trEiPfnpjxblEpA9VMuwdiGw)zzyEkYdjTO5j5kyX7PGfxRr26kC8dNLWCJZA5jWA0SgO8GlZa4OZbP1)AsXfIdcl5GhfCqVgjC5GfCC6FnXbl4456JehSGV5jnh9zfUQms4YbR4miC6Cqm7smqmk6n6yXNqMzirZr)ccp9787Y9rR)1KYAKTwywhUM24n6yXj1KbINkYdPhT(xtkoOIUkolJeUCWbEgswJi8liS1d)UZVlxKS(eTvRrK8npjRlMHK1U1m5MNeHTgITE4JF2tYAfvsRkxuwdxRfkKnRRqOwblUizneBTRl6IoRDRzYnpjcBDXmKSgrWiFCWcUML4GaZAHzDfc1kyX99POir7mKOjjIUhMCLiRr26coo9VMEm5MN0ScxvgjCTgOwdiGwdmRRqOwblUVpffjANHenjr09WKReznYwxWXP)10Zh)SN0ScxvgjCTgO8GlJ8ZrNdsR)1KIlehewYbpk4GEns4Ybl440)AIdwW1SehSGJt)RPhtU5jnRWvLrcxoyfNbHtNdIzxIbIrrVrhl(eYmdjAo6xq4PFNFxUpA9VMuwJS1HRPnEJowCsnzG4PI8q6rR)1KIdwWXZ1hjoybFZtAo6ZkCvzKWLhCzgghDoiT(xtkUqCWkodcNohSGJt)RPxbFZtAo6ZkCvzKW1AKTE0VGWt)o)UCNyA0Z9SwG1i2AKTUGJt)RP3x7kAYOzXyrZt0w5GEns4Ybl4BEs8GlJCGJohKw)RjfxioyfNbHtNdkmR)SmmpxHP115stm7j9yl5GEns4YbDfMwxNlnXSNep4Yi7WrNdsR)1KIlehSIZGWPZbfM1xqUoKi1Z1ARr2AGzDbhN(xtpMCZtAwHRkJeUwdiGwhogffVihPzaNQKSwEwJWaSgOCqVgjC5GmAhfP1EKWLhCzKD5OZbP1)AsXfIdwXzq405GcZ6lixhsK65AT1iBDfo(HZsyUXzT8eynAwJS1aZAHzDfwGwFJxbAdjryRbeqRv0NLH5XODuKw7rc3hBP1aLd61iHlhuHjx91UIoEWLzGHJohKw)RjfxioyfNbHtNdo6xq4PFNFxUtmn65EwlWAeBnYw)zzyEkm5QV2v09uWIR1iBnWS(ZYW8WqTEgs08dx6EyA0Z9SwEcSEawdiGwxWXP)10dh)jMWqT2AGYb9AKWLdIHA9mKO5hU0XdUmiGyo6CqA9VMuCH4GEns4YbhDS4KAYaXtf5HehuNlnRkoicVHXbRIQAAgogffhxge4GvCgeoDoi2t1KkqB8CL6ESLwJS1aZ6WXOO4f5ind4uLK1YZ6kC8dNLWCJ7PiMSMH1acO1cZ6lixhsK6HHOyjRr26kC8dNLWCJ7PiMSMH1arG11Y5OpK5vsRY6bYAeSgOCqfDvCwgjC5GYsgRDL6S2XK1SLiz9TzjzDirwdxY6IzizTgwKUWA0rx(EwlhpY6Is0ATsuUOSMXVGWwhs(ATWruRvetwZWAi26IzibzdR9vK1chrF8GldciWrNdsR)1KIleh0Rrcxo4OJfNutgiEQipK4Gk6Q4Sms4YbLLmwVqRDL6SUyQ1wRsY6IziLR1Hez9sdjSEai(qYA2JSgrWiFwdxR)W7SUygsq2WAFfzTWr0hhSIZGWPZbXEQMubAJNRu3lxRbI1daXwpqwJ9unPc0gpxPUNIf7rcxRr2AHz9fKRdjs9WquSK1iBDfo(HZsyUX9uetwZWAGiW6A5C0hY8kPvz9aznc8GldcOXrNdsR)1KIlehewYbpk4GEns4Ybl440)AIdwW1SehuywJzxIbIrrVrhl(eYmdjAo6xq4PFNFxUpA9VMuwdiGwxHqTcwCFf8npPhMg9CpRbI1iGyRbeqRh9li80VZVl3jMg9CpRbI1OXbv0vXzzKWLdo8iOXYW6aA9jARwJil16CrznyjMiRlMHK1is(MNK1mqS1ic)ccB9WVZVlxoybhpxFK4GINADUOMxjMOzbFZtAEI2kp4YGWa4OZbP1)AsXfId61iHlhu8uRZf18kXeXbv0vXzzKWLdkhpY6CTgHbcn0TozSwOq2SopRzlT2xL1fHlWdRREP1Y2syuIqYAi2ApSEaOlM1adn0fZ6IzizT8rEiPfznOKRGfpGAneBDrjATgr4xqyRh(D(D5ADEwZw(4GvCgeoDoybhN(xtVV2v0KrZIXIMNOTAnYwxWXP)10t8uRZf18kXenl4BEsZt0wTgzRfM1xqUoKi1ddrXswJS1aZAf9zzyEFkks0odjAsIO7XwAnYw)zzyEkm5QV2v09uWIR1iBnTegLONIyYAgwdeRbM10syuIEycfTwlRBnAwlM1immRbQ1acO1xjP1ZWXOO4EFTROjJMfJfznqSgywJM1dK1FwgMNI8qslAEsUcw8ESLwduRbeqRh9li80VZVl3jMg9CpRbI1i2AGYdUmii)C05G06FnP4cXbR4miC6CWcoo9VMEFTROjJMfJfnprB1AKTgywtlHrj6f5ind4C0hI1aXA0SgzR)SmmpfMC1x7k6EkyX1Aab0AAjmkrwlpbwpaeBnGaA9vsA9mCmkkoRbI1Oznq5GEns4Yb)Axrtm7jXdUmimmo6CqA9VMuCH4GvCgeoDoOWS(cY1HePEUwBnYwxWXP)10Zh)SN0ScxvgjC5GEns4YbpjxblosAfp4YGGCGJohKw)RjfxioyfNbHtNd(zzyEFneQ0Sx8WKxdRbeqR)W7SgzRzsusXetJEUN1YZ6bGyRbeqR)SmmpxHP115stm7j9yl5GEns4YblHrcxEWLbbzho6CqVgjC5GFneQMmSyrCqA9VMuCH4bxgeKD5OZb9AKWLd(j8ryXZffhKw)RjfxiEWLbHbgo6CqVgjC5GmjM(AiuXbP1)AsXfIhCzqdXC05GEns4Yb9TsxGD9S6AnhKw)RjfxiEWLbne4OZbP1)AsXfId61iHlhmW5kofiWbv0vXzzKWLdkFeJZQdRRWvLrc3ZAgi2A2Z)AY6mOX7XbR4miC6Cqf9zzyEFkks0odjAsIO7XwAnGaADGZvCkEbcpj)Mx4XZxrtv5znGaAntIskMyA0Z9SwEcSgneZdUmOHghDoiT(xtkUqCWkodcNohurFwgM3NIIeTZqIMKi6ESLwdiGwh4CfNIxG2tYV5fE88v0uvEwdiGwZKOKIjMg9CpRLNaRrdXCqVgjC5GboxXPanEWdo4fKRdjo6CzqGJohKw)RjfxioyfNbHtNdwWXP)10Jj38KMv4QYiHlh0RrcxoOkVspQs8GldAC05GEns4Yb9Xp7jXbP1)AsXfIhCzgahDoiT(xtkUqCqVgjC5GvjYlNNem4GvCgeoDoy4AAJxjMenH7mKOzrYf)rR)1KYAKTwywhogffV8MF4DCWQOQMMHJrrXXLbbEWdoitU5jXrNldcC05G06FnP4cXb9AKWLd(POir7mKOjjIooOIUkolJeUCqHczZA4ADfc1kyX16aAT4evADirwlCCgwROpldJ1SLizn7QP7SoKiRdhJIcRZZA)dzdRdO1QK4GvCgeoDoy4yuu8ICKMbCQsYAGy9a4bxg04OZbP1)AsXfIdwXzq405GFwgM3PZkn9vnvzLEyA0Z9SwEwZKOKIjMg9CpRr2AmXGPtY)AId61iHlh80zLM(QMQSs8GlZa4OZb9AKWLdQYR0JQehKw)RjfxiEWdEWblq4lHlxg0qmAiGy5hHbWbl64nxuhhCGpCzLmYszgyhARTgDjY6CSeIdRzGyRbUIyCwDaCRX0qLnXKY6dosw7SbC0dszDvYxu09maKf5swl)dT1chUfiCqkRbEfUk2mEYjWToGwd8kCvSz8KZhT(xtkGBnWqyia9zayamWhUSsgzPmdSdT1wJUezDowcXH1mqS1aVQoGBnMgQSjMuwFWrYANnGJEqkRRs(IIUNbGSixYA0gARfoClq4GuwdCm7smqmk6jNa36aAnWXSlXaXOONC(O1)AsbCRbgAdbOpdazrUK1dyOTw4WTaHdsznWXSlXaXOONCcCRdO1ahZUedeJIEY5Jw)RjfWTgyimeG(maKf5swl)dT1chUfiCqkRboMDjgigf9KtGBDaTg4y2LyGyu0toF06FnPaU1adHHa0NbGSixYAeqBOTw4WTaHdsznWXSlXaXOONCcCRdO1ahZUedeJIEY5Jw)RjfWTgyimeG(maKf5swJgcdT1chUfiCqkRbEGZvCkEi8KtGBDaTg4boxXP4fi8KtGBnWqyia9zailYLSgn0gARfoClq4Guwd8aNR4u8q7jNa36aAnWdCUItXlq7jNa3AGHWqa6ZaWayGpCzLmYszgyhARTgDjY6CSeIdRzGyRb(Nn1kGBnMgQSjMuwFWrYANnGJEqkRRs(IIUNbGSixY6bm0wlC4wGWbPSg4y2LyGyu0tobU1b0AGJzxIbIrrp58rR)1Kc4w7H1YMSxwynWqyia9zayaGUeznWzpAMbnEa3AVgjCTUOFwVWWAgi7QSoxRdP8SohlH44zailhlH4GuwlhS2RrcxR15f3ZaGdELuLldAYbeZblXqMutCq5kxRL9SH2lATScIILmaKRCTE4L4uBncYpswJgIrdbdada5kxRLTHqv2Guw)jgiMSUch)Ey9NqL79SE41kvgN1lChijhpYWQT2Rrc3ZA4Qf9ma8AKW9ELyQch)EiWll1IMLW8GRbGxJeU3Retv443dXem4hgHMutgTlIufZf1mGdjxdaVgjCVxjMQWXVhIjyWlixhsgaEns4EVsmvHJFpetWGJowCsnzG4PI8qcPsmvHJFpMhvHR6emmKsgbypvtQaTXZvQ7LlqqBygaEns4EVsmvHJFpetWGyOwpdjA(HlDivIPkC87X8OkCvNa0qkzeGPrp3tEdWaWRrc37vIPkC87Hycg80zLM(QMQSsivIPkC87X8OkCvNa0qkzeGjgmDs(xtgagaYvUwlBdHQSbPSMkqyrwh5izDirw71aITopR9cEQ9VMEgaEns4EcepRIBaixRLv0fKRdjRtgRlH3LFnznWwO1fy1lH9VMSMwAmPZ6CTUch)EaudaVgjCpXem4fKRdjda5ATSIWqT26lxuAY6pldZzn5yTiRHHeHToK81A0XSK1crooxuw7RYAHWqxDPIma8AKW9etWGfCC6FnH06JKaC8Nycd1AKk4Awsao(ZpldZjp0qgyc7ZYW8cmln)KJZf1JTezH9zzyEFm0vxQOhBjqnaKR1Y2ESyY6IK1OOWAgwT26Hp(zpjRfoIAnkp3ZAFvw7yAbEynMWqToxuwlCi7gwhsK1YEL6S(ZYWCw7fDrgaEns4EIjyWcoo9VMqA9rsGp(zpPzfUQms4IubxZscQWXpCwcZnUNIyYAgaraAI9zzyEFm0vxQOhBjY0syuIaIGHHyKbMWQWvXMXRcz3ygs0eQuhGa(zzyEyOwpdjA(HlDpmn65EaracigOgaY16HsU5jzThwp6dX6s4D5xtwlCe16IzibzdRHfimJgwmxuw)Hl7zDfo(HwxcZnoKSMD10DwZaXwluiBwxukRsw76IUOZ6tcYQvw)jRhMywlCe1aWRrc3tmbdwWXP)1esRpscyYnpPzfUQms4IubxZscQWXpCwcZnoGiOwoh9HmVsAvd0NLH59XqxDPIESLdeW(SmmpyzjehSBgIESLY6HRPnEdv2Sk(uH9IpA9VMuafqaRWXpCwcZnob(MJEvYXOi1SwAaixRhUUOl6S2JGgldRdO1ShzTqHSzThwpmXSw4ikswJjuowPP7SgYyTWruRrrR1f9lidaVgjCpXemybhN(xtiT(ijGj38KMv4QYiHlsWsby6OaPKrqfc1kyX99POir7mKOjjIUhMCLiKjggQgzbAwHJF4SeMBCYBygaY16bEgswpYQJSutwhogffhswhs5zDbhN(xtwNN1vjQkoPSoGwROAQiRlkrHeHT(GJK1cx(oRpjiRwz9NS(eTvszDXmKSwiTRiRhkAwmwKbGxJeUNycgSGJt)RjKwFKe81UIMmAwmw08eTvKk4AwsWvsA9mCmkkU3x7kAYOzXyrYdnKXEQMubAJNRu3lxGGgIbeWpldZ7RDfnz0SySOhMg9CpGGGyHRPnEINADUOMxjMOhT(xtkdaVgjCpXemiMDNEns4o15fiT(ij4cY1HesjJGlixhsK65ATbGxJeUNycgS6A90Rrc3PoVaP1hjbv1za41iH7jMGbXS70Rrc3PoVaP1hjbm5MNesjJGcoo9VMEm5MN0ScxvgjCna8AKW9etWGvxRNEns4o15fiT(ij4ZMALbGxJeUNycg0XvFPzaXyAdKsgb0syuIEkIjRzaebimmXOLWOe9WekAna8AKW9etWGoU6lnlz1hza41iH7jMGb1jkP4MYAzvOgPnma8AKW9etWGFh1eYmdCwf)mamaKRCTwi2uRi8za41iH79(SPwj4OYlpdaVgjCV3Nn1kXemikj4fArZlWP4KbGxJeU37ZMALycg8KYciLmcWSlXaXOOxKROzahswNFTRidaVgjCV3Nn1kXemivLG5IAIPsCo6RYaWRrc379ztTsmbdEeg7bPMF4sZRmfNqQkQQPz4yuuCcqaPKrGWuW4Deg7bPMF4sZRmfNErwfpxuacOxJSanPLgt6eGaYypvtQaTXZvQ7Llqyy16jMQsogfnJCKaeWQKJrrhqqd5p8oKzsusXetJEUN8gMbGCTwoEK1iAEbuBnOemSUygswl7llH4GDZqK1jJ1cho(9WAefg0wfzDr4c8WAybcx9sRPLWOeHK1fLO16mSUyQ1wtdXRHwK1vV0AHJOizneBDrjATM9YfL1iYzZQ4wlFyVObGxJeU37ZMALycgSmVaQNNemqkze8zzyEWYsioy3me9ylrgy0syuIEkIjRzaeGrlHrj6Hju0kgcigOacyfo(HZsyUX9uetwZqEcqqSpldZ7JHU6sf9ylbeWW10gVHkBwfFQWEXhT(xtkGAa41iH79(SPwjMGblZlG65jbdKsgbFwgMhSSeId2ndrp2sKb2NLH5Hct0EIN7nlMvXj89ylbeWpldZRc3k5Asn)A2vr4p7Dp2sGAa41iH79(SPwjMGbVCZli88cCkoza41iH79(SPwjMGbrbzrriLmccxtB8ujoendCwf)E06FnPqUch)Wzjm34EkIjRzaebii2NLH59XqxDPIESLgagaYvUwlCiuRGf3ZaqUwlK2vK1dfnlglYA4AnAIznT0ysNbGxJeU3RQobFTROjJMfJfHuYi4kjTEgogffhqeGgYc7ZYW8(Axrtgnlgl6XwAaixRLJxUOSE4JF2tY68S2TgnznwNBft(riz9bTgrY38KSU6R1FY6dosrosN1FYA2Juw7N1U1SrQZqK1xjP1wZUA6oRzVCrznIWVGWwp8787Y1Ai2A5J8qslYAqjxblEgaEns4EVQ6etWGf8npjKsgbcdZUedeJIEJow8jKzgs0C0VGWt)o)UCrwyxqUoKi1Z1AKl440)A65JF2tAwHRkJeUidmHHzxIbIrrpf5HKw08KCfS4biGFwgMNI8qslAEsUcw8EkyXf5kC8dNLWCJtEcqdOgaY16bEgswJi8liS1d)UZVlxKS(eTvRrK8npjRlMHK1U1m5MNeHTgITE4JF2tYAfvsRkxuwdxRfkKnRRqOwblUizneBTRl6IoRDRzYnpjcBDXmKSgrWiFgaEns4EVQ6etWGfCC6FnH06JKGc(MN0C0Nv4QYiHlsjJam7smqmk6n6yXNqMzirZr)ccp9787YfzHfUM24n6yXj1KbINkYdPhT(xtkKk4AwsaWewfc1kyX99POir7mKOjjIUhMCLiKl440)A6XKBEsZkCvzKWfOaciWQqOwblUVpffjANHenjr09WKReHCbhN(xtpF8ZEsZkCvzKWfOgaEns4EVQ6etWGfCC6FnH06JKGc(MN0C0Nv4QYiHlsjJam7smqmk6n6yXNqMzirZr)ccp9787Yf5W10gVrhloPMmq8urEi9O1)AsHubxZsck440)A6XKBEsZkCvzKW1aWRrc37vvNycgSGV5jHuYiOGJt)RPxbFZtAo6ZkCvzKWf5r)ccp9787YDIPrp3taIrUGJt)RP3x7kAYOzXyrZt0wna8AKW9Ev1jMGbDfMwxNlnXSNesjJaH9zzyEUctRRZLMy2t6XwAa41iH79QQtmbdYODuKw7rcxKsgbc7cY1HePEUwJmWk440)A6XKBEsZkCvzKWfqadhJIIxKJ0mGtvsYdHbaudaVgjCVxvDIjyqfMC1x7k6qkzeiSlixhsK65AnYv44holH5gN8eGgYatyvybA9nEfOnKeHbeqf9zzyEmAhfP1EKW9XwcudaVgjCVxvDIjyqmuRNHen)WLoKsgbJ(feE6353L7etJEUNaeJ8NLH5PWKR(Axr3tblUidSpldZdd16zirZpCP7HPrp3tEcgaGawWXP)10dh)jMWqTgOgaY1AzjJ1UsDw7yYA2sKS(2SKSoKiRHlzDXmKSwdlsxyn6OlFpRLJhzDrjATwjkxuwZ4xqyRdjFTw4iQ1kIjRzyneBDXmKGSH1(kYAHJOpdaVgjCVxvDIjyWrhloPMmq8urEiHKoxAwvcq4nmKQIQAAgogffNaeqkzeG9unPc0gpxPUhBjYalCmkkErosZaovjjVkC8dNLWCJ7PiMSMbGakSlixhsK6HHOyjKRWXpCwcZnUNIyYAgarqTCo6dzEL0QgieaQbGCTwwYy9cT2vQZ6IPwBTkjRlMHuUwhsK1lnKW6bG4djRzpYAebJ8znCT(dVZ6IzibzdR9vK1chrFgaEns4EVQ6etWGJowCsnzG4PI8qcPKra2t1KkqB8CL6E5cKbG4bc7PAsfOnEUsDpfl2JeUilSlixhsK6HHOyjKRWXpCwcZnUNIyYAgarqTCo6dzEL0QgiemaKR1dpcASmSoGwFI2Q1iYsToxuwdwIjY6IziznIKV5jzndeBnIWVGWwp8787Y1aWRrc37vvNycgSGJt)RjKwFKeiEQ15IAELyIMf8npP5jARivW1SKaHHzxIbIrrVrhl(eYmdjAo6xq4PFNFxUacyfc1kyX9vW38KEyA0Z9accigqah9li80VZVl3jMg9CpGGMbGCTwoEK15AncdeAOBDYyTqHSzDEwZwATVkRlcxGhwx9sRLTLWOeHK1qS1Ey9aqxmRbgAOlM1fZqYA5J8qslYAqjxblEa1Ai26Is0AnIWVGWwp8787Y168SMT8za41iH79QQtmbdkEQ15IAELyIqkzeuWXP)107RDfnz0SySO5jARixWXP)10t8uRZf18kXenl4BEsZt0wrwyxqUoKi1ddrXsidmf9zzyEFkks0odjAsIO7XwI8NLH5PWKR(Axr3tblUitlHrj6PiMSMbqagTegLOhMqrRSoAIHWWakGaELKwpdhJII791UIMmAwmweqagAd0NLH5PipK0IMNKRGfVhBjqbeWr)ccp9787YDIPrp3diigOgaEns4EVQ6etWGFTROjM9KqkzeuWXP)107RDfnz0SySO5jARidmAjmkrVihPzaNJ(qacAi)zzyEkm5QV2v09uWIlGaslHrjsEcgaIbeWRK06z4yuuCabnGAa41iH79QQtmbdEsUcwCK0kKsgbc7cY1HePEUwJCbhN(xtpF8ZEsZkCvzKW1aWRrc37vvNycgSegjCrkze8zzyEFneQ0Sx8WKxdab8dVdzMeLumX0ON7jVbGyab8ZYW8CfMwxNlnXSN0JT0aWRrc37vvNycg8RHq1KHflYaWRrc37vvNycg8t4JWINlkdaVgjCVxvDIjyqMetFneQma8AKW9Ev1jMGb9TsxGD9S6ATbGCTw(igNvhwxHRkJeUN1mqS1SN)1K1zqJ3ZaWRrc37vvNycgmW5kofiGuYiqrFwgM3NIIeTZqIMKi6ESLacyGZvCkEi8K8BEHhpFfnvLhGaYKOKIjMg9Cp5janeBa41iH79QQtmbdg4CfNc0qkzeOOpldZ7trrI2zirtseDp2sabmW5kofp0Es(nVWJNVIMQYdqazsusXetJEUN8eGgInamaKRCTEOKBEse(maKR1cfYM1W16keQvWIR1b0AXjQ06qISw44mSwrFwggRzlrYA2vt3zDirwhogffwNN1(hYgwhqRvjza41iH79yYnpjbFkks0odjAsIOdPKrq4yuu8ICKMbCQscidWaWRrc37XKBEsIjyWtNvA6RAQYkHuYi4ZYW8oDwPPVQPkR0dtJEUN8ysusXetJEUhYyIbtNK)1KbGxJeU3Jj38KetWGQ8k9Okzayaix5AnyqUoKma8AKW9ExqUoKeOYR0JQesjJGcoo9VMEm5MN0ScxvgjCna8AKW9ExqUoKetWG(4N9Kma8AKW9ExqUoKetWGvjYlNNemqQkQQPz4yuuCcqaPKrq4AAJxjMenH7mKOzrYf)rR)1KczHfogffV8MF4D8GhCoa]] )


end