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


    spec:RegisterPack( "Outlaw", 20210310, [[d8KY(aqivv1JiP0LiifTjqYNaPAuQQ4uQQ0QiivEfjYSqjDlsQyxa(LiQHPQkhdLYYijEgjPMgjj6Aee2gjj5BeKQghif15iPOwhifMNis3Ja7tHQdcsPfIs1djPQjsqYfvOuBKKk1hbPiojbrwPQsVKGuyMKKu3ueHDsI6NKKWqjPWrjiLwkbr9uGMkkXvjPiBvHs6RkuIXkIO9IQ)QObl1HPSyv5XIAYeDzKnJIpdIrtOtlSAqksVMGA2K62I0Uv63qgUcoojvYYH65QmDjxhuBxe(Ucz8kuCEsy(Qk2pvZzJZchuAfXvwL)uHT)unB)bWMAwiu9FQkoyPyG4GdwwydcXbxlL4GQc4sBJ4GdMcnYKCw4GhcgNjoOyvdh0i5KHeLi8diJst(IuyTvbAZyJPs(I0CYCWhCOlH0YFCqPvexzv(tf2(t1S9haBQzHqfHqnZbn4seH5GGrQ65GIHusl)XbL0L5GQc4sBJ8wiJGat(3KWWzrVz7pw9wL)uHnoOoU64SWbLeJbRlolCLzJZch0YvGwoOWrwyoiT2ttso78IRSkCw4G0Apnj5SZbL0LXXqfOLdkKPRitxIEhmEpGUlEAY7FwK3jG1lHTNM8MwknOZ7y9oJsFw9lh0YvGwo4vKPlrEXvw1Cw4G0Apnj5SZbrdCWJkoOLRaTCWegoSNM4GjmnmXbX1B(GzyoVtQ3Q4nuE)J3)79dMHbOWW08rgowiaWdEdL3)79dMHb4HrM8cjbap49VCqjDzCmubA5GczcJ0AVVyHOjVFWmmN3KH1k8gvIe27s0wVzbdtEZoz4yH4TTsVzhJm5fsIdMWWZ1sjoiUEtmHrAnV4kRk5SWbP1EAsYzNdIg4GhvCqlxbA5GjmCypnXbtyAyIdMrPp0CafBDasIjYr594c8wfVvY7hmddWdJm5fscaEWBO8MwcdrH3JlWBH4pVHY7F8(FVZOvchfqgbV1SePjskpaATNMKE)5J3pyggamsRNLinFOLoamLAXEEpUaVz7pV)LdkPlJJHkqlhCS3dgtEpI8gcvEZaR1EdTPp4t0B1RgEdXI982wP3gMwOxEJjmsRJfI3QhbVL3Li5TQqkpVFWmmN32itbhmHHNRLsCql9bFIZmALrfOLxCLfcolCqATNMKC25GObo4rfh0YvGwoycdh2ttCWeMgM4Gzu6dnhqXwN3JlW78Wm1gZ8gOv6T649dMHb4HrM8cjbap4T649pE)GzyaqddiCbVrPaaEWBHoVlttBbOUGJSWtj2gbqR90K07F9(ZhVZO0hAoGIToVf4TTrQLfnmesoZdCqjDzCmubA5GQ7yJt0BR8o1gtKcN6T6vdVFWL3wcui9EKDvSq8MDmYKxijVTv6TqlCKf2BHcBJ8(Hw4Z7mk9H8EafBDCWegEUwkXbzInoXzgTYOc0YlUYQkolCqATNMKC25GObo4rfh0YvGwoycdh2ttCWeMgM4G3aP1ZYWqO6aEAtstgnmgRW7K6TkEdL3ylKtkbTfGjLhqSEpU3Q8N3F(49dMHb4Pnjnz0WyScamLAXEEpU3S5TsExMM2cq4qRJfY8gWebqR90KKdkPlJJHkqlhCSeLO3PW6kg0K3LHHq1XQ3LyCENWWH90K3X5DwKYctsVlK3skhsY7rIujsyVpuk5T6fQZ7tebRLE)iVpfBMKEpkkrVzxBsYB1TggJvWbty45APeh8Pnjnz0WySI5PyZ8IRSqpNfoiT2ttso7CWmokchgh8kY0LijbmTMdA5kqlhedVtlxbAN64koOoUAUwkXbVImDjYlUYqZCw4G0Apnj5SZbTCfOLdMnTEA5kq7uhxXb1XvZ1sjoywE8IRSAMZchKw7PjjNDoyghfHdJdMWWH90eatSXjoZOvgvGwoOLRaTCqm8oTCfODQJR4G64Q5APehKj24e5fxz2(JZchKw7PjjNDoOLRaTCWSP1tlxbAN64koOoUAUwkXbFWHwYlUYSXgNfoiT2ttso7CWmokchghKwcdrbGKyICuEpUaVzti8wjVPLWquaGji0YbTCfOLdA4ST0SqymTfV4kZMkCw4GwUc0YbnC2wAoaRpIdsR90KKZoV4kZMQ5SWbTCfOLdQdiI1nHMclHKsBXbP1EAsYzNxCLztvYzHdA5kqlh8zqMiMzHJSWhhKw7PjjNDEXlo4aMYO0NvCw4kZgNfoOLRaTCqByqRyoGIdTCqATNMKC25fxzv4SWbTCfOLd(qvPj5KrBki5OyHml0yILdsR90KKZoV4kRAolCqlxbA5GxrMUe5G0Apnj5SZlUYQsolCqATNMKC25GwUc0YbtnSWKCYGWtjzLihmJJIWHXbXwiNucAlatkpGy9ECVvri4GdykJsFwnpkJw5XbfcEXvwi4SWbP1EAsYzNdA5kqlheJ06zjsZhAPJdMXrr4W4Gyk1I98oPERAo4aMYO0NvZJYOvECqv4fxzvfNfoiT2ttso7CqlxbA5GNoY00w5ugzIdMXrr4W4GyIbtNO90ehCatzu6ZQ5rz0kpoOk8IxCqMyJtKZcxz24SWbP1EAsYzNdMXrr4W4GpyggGthzAARCkJmbGPul2Z7K6ntarSMyk1I98gkVXedMor7PjoOLRaTCWthzAARCkJmXlUYQWzHdsR90KKZoh0YvGwo4JQreTZsKMKc64Gs6Y4yOc0YbzVgBVrR3zeslrJwVlK3ct0G3Li5T6Xr5TKEWmmEdpWQ3WRMUZ7sK8UmmeQ8ooVThcU8UqEldIdMXrr4W4GLHHqfqfP0SqtzqEpU3QMxCLvnNfoOLRaTCqzCdwLf5G0Apnj5SZlEXbZYJZcxz24SWbP1EAsYzNdA5kqlh8Pnjnz0WyScoOKUmogQaTCq21MK8wDRHXyfEJwVvrjVPLsd64GzCueomo4nqA9SmmeQoVhxG3Q4nuE)V3pyggGN2K0KrdJXkaGh4fxzv4SWbP1EAsYzNdA5kqlhmHTXjYbL0LXXqfOLdQMUyH4n0M(GprVJZBZBveA6DSzmzhXQ3hY7XQTXj6D2wVFK3hkLQiLoVFK3Whj92oVnVHRqhLcVVbsR9gE10DEdFXcX7KWUIWEdT3z3fR3iS3cfzLOwH3GIMen64GzCueomo4)EJHxIbHHqaPgw4jIzwI0m1UIWt7o7UybO1EAs6nuE)V3xrMUejjGP1EdL3jmCypnbyPp4tCMrRmQaTEdL3)49)EJHxIbHHqasYkrTI5jAs0OdGw7PjP3F(49dMHbqswjQvmprtIgDas0O1BO8oJsFO5ak268oPc8wfV)LxCLvnNfoiT2ttso7Cq0ah8OIdA5kqlhmHHd7PjoycdpxlL4GjSnoXzQnZOvgvGwoyghfHdJdIHxIbHHqaPgw4jIzwI0m1UIWt7o7UybO1EAs6nuE)V3LPPTasnSWKCYGWtjzLiaT2ttsoOKUmogQaTCWXsuIENe2ve2BO9UZUlww9(uSzVhR2gNO3JIs0BZBMyJtKWEJWEdTPp4t0BjnqRmwiEJwVzVgBVZiKwIgTS6nc7TPhzkoVnVzInorc79OOe9ojyekoyctdtCWF8(FVZiKwIgTapQgr0olrAskOdatMuH3q5Dcdh2ttamXgN4mJwzubA9(xV)8X7F8oJqAjA0c8OAer7SePjPGoamzsfEdL3jmCypnbyPp4tCMrRmQaTE)lV4kRk5SWbP1EAsYzNdIg4GhvCqlxbA5GjmCypnXbtyAyIdMWWH90eatSXjoZOvgvGwoyghfHdJdIHxIbHHqaPgw4jIzwI0m1UIWt7o7UybO1EAs6nuExMM2ci1WctYjdcpLKvIa0Apnj5Gjm8CTuIdMW24eNP2mJwzubA5fxzHGZchKw7PjjNDoyghfHdJdMWWH90eqcBJtCMAZmALrfO1BO8o1UIWt7o7UyNyk1I98wG3)5nuENWWH90eWtBsAYOHXyfZtXM5GwUc0YbtyBCI8IRSQIZchKw7PjjNDoyghfHdJd(V3pyggatIP10Xstm8jcapWbTCfOLdAsmTMowAIHprEXvwONZchKw7PjjNDoyghfHdJd(V3xrMUejjGP1EdL3)4Dcdh2ttamXgN4mJwzubA9(ZhVlddHkGksPzHMYG8oPEZMQ9(xoOLRaTCqgTbH0ARc0YlUYqZCw4G0Apnj5SZbZ4OiCyCW)9(kY0LijbmT2BO8oJsFO5ak268oPc8wfVHY7F8(FVZOe0ABbKG2sub27pF8wspyggagTbH0ARc0cap49VCqlxbA5GsmzYN2K0XlUYQzolCqATNMKC25GzCueomoyQDfHN2D2DXoXuQf75TaV)ZBO8(bZWaiXKjFAtshGenA9gkV)X7hmddagP1ZsKMp0shaMsTypVtQaVvT3F(4Dcdh2tta46nXegP1E)lh0YvGwoigP1ZsKMp0shV4kZ2FCw4G0Apnj5SZbTCfOLdMAyHj5KbHNsYkroywrwtZYWqO64kZghmJJIWHXbXwiNucAlatkpa4bVHY7F8UmmeQaQiLMfAkdY7K6DgL(qZbuS1bijMihL3F(49)EFfz6sKKayeeyYBO8oJsFO5ak26aKetKJY7Xf4DEyMAJzEd0k9wD8MnV)LdkPlJJHkqlhuiX4TjLN3gM8gEGvVVngiVlrYB0sEpkkrV1Or0vEZclcfG3QPJ8EKiTElveleVzSRiS3LOTERE1WBjXe5O8gH9EuuIi4YBBv4T6vdaEXvMn24SWbP1EAsYzNdA5kqlhm1WctYjdcpLKvICqjDzCmubA5GcjgVxK3MuEEpk0AVLb59OOeJ17sK8EPXuER6)ow9g(iVtcgHYB069dDN3JIsebxEBRcVvVAaWbZ4OiCyCqSfYjLG2cWKYdiwVh3Bv)N3QJ3ylKtkbTfGjLhGegBvGwVHY7)9(kY0LijbWiiWK3q5DgL(qZbuS1bijMihL3JlW78Wm1gZ8gOv6T64nB8IRmBQWzHdsR90KKZohenWbpQ4GwUc0Ybty4WEAIdMW0Weh8FVXWlXGWqiGudl8eXmlrAMAxr4PDNDxSa0Apnj9(ZhVZiKwIgTajSnoramLAXEEpU3S9N3F(4DQDfHN2D2DXoXuQf7594ERchusxghdvGwoi0wfLouExiVpfB2BHgHwhleVbhWe59OOe9ESABCIEZGWENe2ve2BO9o7Uy5Gjm8CTuIdkCO1XczEdyIMjSnoX5PyZ8IRmBQMZchKw7PjjNDoOLRaTCqHdTowiZBatehusxghdvGwoOA6iVJ1B2uhvyX7GXB2RX2748gEWBBLEpcTqV8oBdEp2lHHOGvVryVTYBvZIsE)JkSOK3JIs0BHISsuRWBqrtIgD)6nc79irA9ojSRiS3q7D2DX6DCEdpaWbZ4OiCyCWegoSNMaEAtstgnmgRyEk2S3q5Dcdh2ttachADSqM3aMOzcBJtCEk2S3q59)EFfz6sKKayeeyYBO8(hVL0dMHb4r1iI2zjstsbDaWdEdL3pyggajMm5tBs6aKOrR3q5nTegIcajXe5O8ECV)XBAjmefayccTEl05TkERK3SjeE)R3F(49nqA9SmmeQoGN2K0KrdJXk8ECV)XBv8wD8(bZWaijRe1kMNOjrJoa4bV)17pF8o1UIWt7o7UyNyk1I98ECV)Z7F5fxz2uLCw4G0Apnj5SZbZ4OiCyCWegoSNMaEAtstgnmgRyEk2S3q59pEtlHHOaOIuAwOzQngVh3Bv8gkVFWmmasmzYN2K0birJwV)8XBAjmefENubER6)8(ZhVVbsRNLHHq1594ERI3)YbTCfOLd(0MKMy4tKxCLzti4SWbP1EAsYzNdMXrr4W4G)79vKPlrscyAT3q5Dcdh2ttaw6d(eNz0kJkqlh0YvGwo4jAs0Ousl5fxz2uvCw4G0Apnj5SZbZ4OiCyCWhmddWtJqsn8vayYYL3F(49dDN3q5ntarSMyk1I98oPER6)8(ZhVFWmmaMetRPJLMy4teaEGdA5kqlhCavbA5fxz2e65SWbTCfOLd(0iKCYaJvWbP1EAsYzNxCLzdAMZch0YvGwo4JWhHfowiCqATNMKC25fxz2uZCw4GwUc0Ybzcm90iKKdsR90KKZoV4kRYFCw4GwUc0YbTntxHn9mBAnhKw7PjjNDEXvwf24SWbP1EAsYzNdA5kqlhe(Ozuu6XbL0LXXqfOLdkueJbRlVZOvgvG2ZBge2B4ZEAY7OO0dGdMXrr4W4G)7ngEjgegcbKAyHNiMzjsZu7kcpT7S7IfGw7PjP3q5TKEWmmapQgr0olrAskOdaEWBO8(hV)37Y00waqerxPvmVchcta0Apnj9(ZhVL0dMHbaIi6kTI5v4qycaEW7F9(ZhVtTRi80UZUl2jMsTypVh37)8(ZhVFO78gkVzciI1etPwSN3jvG3Q8hV4fh8kY0LiNfUYSXzHdsR90KKZohmJJIWHXbty4WEAcGj24eNz0kJkqlh0YvGwoOmUbRYI8IRSkCw4GwUc0YbT0h8jYbP1EAsYzNxCLvnNfoiT2ttso7CqlxbA5GzrYgMNiQ4GzCueomoyzAAlGbmPyI2zjsZrKjmaT2ttsVHY7)9UmmeQaIB(q3XbZkYAAwggcvhxz24fV4Gp4ql5SWvMnolCqlxbA5GhnCXXbP1EAsYzNxCLvHZch0YvGwoier0vAfZRWHWehKw7PjjNDEXvw1Cw4G0Apnj5SZbZ4OiCyCqm8smimecOIvXSqJjYZN2KeaT2ttsoOLRaTCWtmsWlUYQsolCqlxbA5GuweflKjMgWrQTsoiT2ttso78IRSqWzHdsR90KKZoh0YvGwo4rySvKC(qlnVHqyIdMXrr4W4G)7TevahHXwrY5dT08gcHjGkYchleV)8XBlxrcAslLg05TaVzZBO8gBHCsjOTamP8aI17X9MbwRNyklAyi0SIuY7pF8olAyi0594ERI3q59dDN3q5ntarSMyk1I98oPEleCWSISMMLHHq1XvMnEXvwvXzHdsR90KKZoh0YvGwo4qCfsppruXbL0LXXqfOLdQMoYB1iUcP9guevEpkkrVvfddiCbVrPW7GXB1JsFw5TAGkAZk8EeAHE5nkbHZ2G30syiky17rI06DuEpk0AVPXy5sRW7Sn4T6vdw9gH9EKiTEdFXcXBHw4ilS3cf2gXbZ4OiCyCWhmddaAyaHl4nkfaWdEdL3)4nTegIcajXe5O8ECV)XBAjmefayccTERK3S9N3)69NpENrPp0CafBDasIjYr5Dsf4nBERK3pyggGhgzYlKea8G3F(4DzAAla1fCKfEkX2iaATNMKE)lV4kl0ZzHdsR90KKZohmJJIWHXbFWmmaOHbeUG3Ouaap4nuE)J3pyggaiyI2t4yV5OilmHpa4bV)8X7hmddqgTzY0KC(0WRKWp47aGh8(xoOLRaTCWH4kKEEIOIxCLHM5SWbTCfOLdEXgxr45v4qyIdsR90KKZoV4kRM5SWbP1EAsYzNdMXrr4W4GLPPTaKbUumlCKf(aO1EAs6nuENrPp0CafBDasIjYr594c8MnVvY7hmddWdJm5fscaEGdA5kqlheccgcXlEXloyccFbA5kRYFQW2FQ(pOzo4idVXc54GJfOviRSqszOjqdV9MfrY7iDaHlVzqyVHUKymyDbDVXK6coWK07dLsEBWfk1ks6Dw0wi0b4Fv1XsERkHgERE0MGWfj9g6z0kHJcijHU3fYBONrReokGKeGw7Pjj09(h2gZVa(x)7ybAfYklKugAc0WBVzrK8oshq4YBge2BONLh09gtQl4atsVpuk5TbxOuRiP3zrBHqhG)vvhl5TkqdVvpAtq4IKEdDm8smimecijHU3fYBOJHxIbHHqajjaT2ttsO79pQmMFb8VQ6yjVvn0WB1J2eeUiP3qhdVedcdHassO7DH8g6y4LyqyieqscqR90Ke6E)dBJ5xa)RQowYBvj0WB1J2eeUiP3qhdVedcdHassO7DH8g6y4LyqyieqscqR90Ke6E)dBJ5xa)RQowYB2ubA4T6rBccxK0BOJHxIbHHqajj09UqEdDm8smimecijbO1EAscDV)HTX8lG)vvhl5TkSbn8w9OnbHls6n0XWlXGWqiGKe6ExiVHogEjgegcbKKa0ApnjHU3)W2y(fW)6FhlqRqwzHKYqtGgE7nlIK3r6acxEZGWEd9hCOLq3BmPUGdmj9(qPK3gCHsTIKENfTfcDa(xvDSK3QgA4T6rBccxK0BOJHxIbHHqajj09UqEdDm8smimecijbO1EAscDVTY7XwvOQ9(h2gZVa(x)RqkDaHls6TQYBlxbA9whxDa(xo4agXeAIdQw16TQaU02iVfYiiWK)vTQ17KWWzrVz7pw9wL)uHn)R)vTQ17XEmugUiP3pIbHjVZO0NvE)iiXEaEdT5mnuN3lAvhrdNYaR92YvG2ZB0Qva4FTCfO9agWugL(SsGnmOvmhqXHw)RLRaThWaMYO0Nvkji5hQknjNmAtbjhflKzHgtS(xlxbApGbmLrPpRusqYxrMUe9VwUc0EadykJsFwPKGKtnSWKCYGWtjzLiRdykJsFwnpkJw5jqiynyeGTqoPe0waMuEaXoUkcH)1YvG2dyatzu6ZkLeKmgP1ZsKMp0shRdykJsFwnpkJw5jqfwdgbyk1I9sQQ9VwUc0EadykJsFwPKGKpDKPPTYPmYeRdykJsFwnpkJw5jqfwdgbyIbtNO90K)1)Qw169ypgkdxK0BkbHv4DfPK3Li5TLle27482syH2EAcW)A5kq7jq4ilS)vTElKPRitxIEhmEpGUlEAY7FwK3jG1lHTNM8MwknOZ7y9oJsFw9R)1YvG2tjbjFfz6s0)QwVfYegP1EFXcrtE)GzyoVjdRv4nQejS3LOTEZcgM8MDYWXcXBBLEZogzYlKK)1YvG2tjbjNWWH90eRRLscW1BIjmsRznHPHjb46nFWmmxsvbQF()bZWauyyA(idhlea4bO()bZWa8WitEHKaGh(1)QwVh79GXK3JiVHqL3mWAT3qB6d(e9w9QH3qSypVTv6THPf6L3ycJ06yH4T6rWB5DjsERkKYZ7hmdZ5TnYu4FTCfO9usqYjmCypnX6APKal9bFIZmALrfOL1eMgMeKrPp0CafBDasIjYrnUavu6bZWa8WitEHKaGhGIwcdrX4ceI)G6N)ZOvchfqgbV1SePjskVpFEWmmayKwplrA(qlDayk1I9gxaB)9R)vTERUJnorVTY7uBmrkCQ3Qxn8(bxEBjqH07r2vXcXB2XitEHK82wP3cTWrwyVfkSnY7hAHpVZO0hY7buS15FTCfO9usqYjmCypnX6APKaMyJtCMrRmQaTSMW0WKGmk9HMdOyRBCb5HzQnM5nqRuDEWmmapmYKxija4b15NhmddaAyaHl4nkfaWdcDLPPTauxWrw4PeBJaO1EAs(7Npzu6dnhqXwNaBJullAyiKCMh8VQ17XsuIENcRRyqtExggcvhRExIX5Dcdh2ttEhN3zrklmj9UqElPCijVhjsLiH9(qPK3QxOoVpreSw69J8(uSzs69OOe9MDTjjVv3AymwH)1YvG2tjbjNWWH90eRRLscEAtstgnmgRyEk2mRjmnmj4giTEwggcvhWtBsAYOHXyfjvfOWwiNucAlatkpGyhxL)(85bZWa80MKMmAymwbaMsTyVXztPY00wachADSqM3aMiaATNMK(xlxbApLeKmgENwUc0o1XvSUwkj4kY0LiRbJGRitxIKeW0A)RLRaTNscsoBA90YvG2PoUI11sjbz55FTCfO9usqYy4DA5kq7uhxX6APKaMyJtK1Grqcdh2ttamXgN4mJwzubA9VwUc0Ekji5SP1tlxbAN64kwxlLe8GdT0)A5kq7PKGKnC2wAwimM2I1GraTegIcajXe5OgxaBcHs0syikaWeeA9VwUc0EkjizdNTLMdW6J8VwUc0EkjizDarSUj0uyjKuAl)RLRaTNscs(zqMiMzHJSWN)1)Qw16n7WHws4Z)A5kq7b8GdTuWrdxC(xlxbApGhCOLkjiziIOR0kMxHdHj)RLRaThWdo0sLeK8jgjynyeGHxIbHHqavSkMfAmrE(0MK8VwUc0Eap4qlvsqYuweflKjMgWrQTs)RLRaThWdo0sLeK8rySvKC(qlnVHqyI1SISMMLHHq1jGnwdgb)lrfWrySvKC(qlnVHqycOISWXc5ZhlxrcAslLg0jGnOWwiNucAlatkpGyhNbwRNyklAyi0SIu6ZNSOHHq34Qa1dDhumbeXAIPul2lPcH)vTERMoYB1iUcP9guevEpkkrVvfddiCbVrPW7GXB1JsFw5TAGkAZk8EeAHE5nkbHZ2G30syiky17rI06DuEpk0AVPXy5sRW7Sn4T6vdw9gH9EKiTEdFXcXBHw4ilS3cf2g5FTCfO9aEWHwQKGKhIRq65jIkwdgbpygga0WacxWBukaGhG6hAjmefasIjYrn(p0syikaWeeAvIT)(9ZNmk9HMdOyRdqsmroQKkGnLEWmmapmYKxija4HpFkttBbOUGJSWtj2gbqR90K8x)RLRaThWdo0sLeK8qCfsppruXAWi4bZWaGggq4cEJsba8au)8GzyaGGjApHJ9MJISWe(aGh(85bZWaKrBMmnjNpn8kj8d(oa4HF9VwUc0Eap4qlvsqYxSXveEEfoeM8VwUc0Eap4qlvsqYqqWqiwdgbLPPTaKbUumlCKf(aO1EAscvgL(qZbuS1bijMih14cytPhmddWdJm5fscaEW)6FvRA9w9iKwIgTN)vTEZU2KK3QBnmgRWB06Tkk5nTuAqN)1YvG2dilpbpTjPjJggJvWAWi4giTEwggcv34cubQ)FWmmapTjPjJggJvaap4FvR3QPlwiEdTPp4t074828wfHMEhBgt2rS69H8ESABCIENT17h59HsPksPZ7h5n8rsVTZBZB4k0rPW7BG0AVHxnDN3WxSq8ojSRiS3q7D2DX6nc7TqrwjQv4nOOjrJo)RLRaThqwEkji5e2gNiRbJG)XWlXGWqiGudl8eXmlrAMAxr4PDNDxSq9)vKPlrscyAnujmCypnbyPp4tCMrRmQaTq9Z)y4LyqyieGKSsuRyEIMen6(85bZWaijRe1kMNOjrJoajA0cvgL(qZbuS1LubQ8R)vTEpwIs07KWUIWEdT3D2DXYQ3NIn79y124e9EuuIEBEZeBCIe2Be2BOn9bFIElPbALXcXB06n71y7DgH0s0OLvVryVn9itX5T5ntSXjsyVhfLO3jbJq5FTCfO9aYYtjbjNWWH90eRRLscsyBCIZuBMrRmQaTSgmcWWlXGWqiGudl8eXmlrAMAxr4PDNDxSq9FzAAlGudlmjNmi8uswjcqR90KK1eMgMe8Z)zeslrJwGhvJiANLinjf0bGjtQaQegoSNMayInoXzgTYOc0(7Np)KriTenAbEunIODwI0KuqhaMmPcOsy4WEAcWsFWN4mJwzubA)1)A5kq7bKLNscsoHHd7PjwxlLeKW24eNP2mJwzubAznyeGHxIbHHqaPgw4jIzwI0m1UIWt7o7UyHQmnTfqQHfMKtgeEkjRebO1EAsYActdtcsy4WEAcGj24eNz0kJkqR)1YvG2dilpLeKCcBJtK1Grqcdh2ttajSnoXzQnZOvgvGwOsTRi80UZUl2jMsTypb)bvcdh2ttapTjPjJggJvmpfB2)A5kq7bKLNscs2KyAnDS0edFISgmc()bZWaysmTMowAIHpra4b)RLRaThqwEkjizgTbH0ARc0YAWi4)RitxIKeW0AO(jHHd7PjaMyJtCMrRmQaTF(uggcvavKsZcnLbLu2u9V(xlxbApGS8usqYsmzYN2K0XAWi4)RitxIKeW0AOYO0hAoGITUKkqfO(5)mkbT2wajOTevG)8rspyggagTbH0ARc0cap8R)1YvG2dilpLeKmgP1ZsKMp0shRbJGu7kcpT7S7IDIPul2tWFq9GzyaKyYKpTjPdqIgTq9ZdMHbaJ06zjsZhAPdatPwSxsfO6pFsy4WEAcaxVjMWiT(x)RA9wiX4TjLN3gM8gEGvVVngiVlrYB0sEpkkrV1Or0vEZclcfG3QPJ8EKiTElveleVzSRiS3LOTERE1WBjXe5O8gH9EuuIi4YBBv4T6vda)RLRaThqwEkji5udlmjNmi8uswjYAwrwtZYWqO6eWgRbJaSfYjLG2cWKYdaEaQFkddHkGksPzHMYGsAgL(qZbuS1bijMih1Np)Ffz6sKKayeeycQmk9HMdOyRdqsmroQXfKhMP2yM3aTs1HTF9VQ1BHeJ3lYBtkpVhfAT3YG8EuuIX6DjsEV0ykVv9FhREdFK3jbJq5nA9(HUZ7rrjIGlVTvH3Qxna8VwUc0Eaz5PKGKtnSWKCYGWtjzLiRbJaSfYjLG2cWKYdi2Xv9FQd2c5KsqBbys5biHXwfOfQ)VImDjssamccmbvgL(qZbuS1bijMih14cYdZuBmZBGwP6WM)vTEdTvrPdL3fY7tXM9wOrO1XcXBWbmrEpkkrVhR2gNO3miS3jHDfH9gAVZUlw)RLRaThqwEkji5egoSNMyDTusGWHwhlK5nGjAMW24eNNInZActdtc(hdVedcdHasnSWteZSePzQDfHN2D2DX(5tgH0s0OfiHTXjcGPul2BC2(7ZNu7kcpT7S7IDIPul2BCv8VQ1B10rEhR3SPoQWI3bJ3SxJT3X5n8G32k9EeAHE5D2g8ESxcdrbREJWEBL3QMfL8(hvyrjVhfLO3cfzLOwH3GIMen6(1Be27rI06DsyxryVH27S7I1748gEaW)A5kq7bKLNscsw4qRJfY8gWeXAWiiHHd7PjGN2K0KrdJXkMNIndvcdh2ttachADSqM3aMOzcBJtCEk2mu)Ffz6sKKayeeycQFK0dMHb4r1iI2zjstsbDaWdq9GzyaKyYKpTjPdqIgTqrlHHOaqsmroQX)HwcdrbaMGqRqNkkXMq87Np3aP1ZYWqO6aEAtstgnmgRy8FurDEWmmasYkrTI5jAs0OdaE43pFsTRi80UZUl2jMsTyVX)7x)RLRaThqwEkji5N2K0edFISgmcsy4WEAc4Pnjnz0WySI5PyZq9dTegIcGksPzHMP2ygxfOEWmmasmzYN2K0birJ2pFOLWquKubQ(VpFUbsRNLHHq1nUk)6FTCfO9aYYtjbjFIMenkL0swdgb)Ffz6sKKaMwdvcdh2ttaw6d(eNz0kJkqR)1YvG2dilpLeK8aQc0YAWi4bZWa80iKudFfaMSC95ZdDhumbeXAIPul2lPQ(VpFEWmmaMetRPJLMy4teaEW)A5kq7bKLNscs(Pri5KbgRW)A5kq7bKLNscs(r4JWchle)RLRaThqwEkjizMatpncj9VwUc0Eaz5PKGKTntxHn9mBAT)vTElueJbRlVZOvgvG2ZBge2B4ZEAY7OO0dW)A5kq7bKLNscsg(Ozuu6XAWi4Fm8smimeci1WcprmZsKMP2veEA3z3flus6bZWa8OAer7SePjPGoa4bO(5)Y00waqerxPvmVchcta0Apnj)8rspyggaiIOR0kMxHdHja4HF)8j1UIWt7o7UyNyk1I9g)VpFEO7GIjGiwtmLAXEjvGk)5F9VQvTERUJnorcF(xlxbApaMyJtuWPJmnTvoLrMynye8GzyaoDKPPTYPmYeaMsTyVKYeqeRjMsTypOWedMor7Pj)RA9M9AS9gTENriTenA9UqElmrdExIK3QhhL3s6bZW4n8aREdVA6oVlrY7YWqOY7482Ei4Y7c5Tmi)RLRaThatSXjQKGKFunIODwI0KuqhRbJGYWqOcOIuAwOPmOXvT)1YvG2dGj24evsqYY4gSkl6F9VQvTEdwKPlr)RLRaThWvKPlrbY4gSklYAWiiHHd7PjaMyJtCMrRmQaT(xlxbApGRitxIkjizl9bFI(xlxbApGRitxIkji5SizdZtevSMvK10SmmeQobSXAWiOmnTfWaMumr7SeP5iYegGw7Pjju)xggcvaXnFO74G3aL5kRIQ6pEXloh]] )

end