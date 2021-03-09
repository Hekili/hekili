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


    spec:RegisterPack( "Outlaw", 20210308, [[d8uX)aqivv8isv6sequBsvvFcKQrPQsNcKyvKkP6vesZcL0Tivv2fGFjIAyGuogHyzeONrQutdKuDncqBJuvvFJacJdKKohiP06ajX8ivL7HsTpvfDqcGfsqEOiIjsQexuvHAJKQQ8rqsHtsavRuvPxsarMjPsYnfrQDsQ4NKQidLufokPsklLakpfOPIsCvciTvvfsFLuf1yfrYEr1Fv0GL6WuwSQ8yrnzsUmYMrXNbXOjLtlSAqsrVMGA2eDBrA3k9BidxbhxvHy5q9CvMUKRdQTlcFxHmEvfCEc18vO2pvZfHZchuzfX1rqOjOiqt3qdQciOiqDOQac1YblXdehCWYcBqio4APehupbxsBehCWelrMIZch8qW4mXb1QA4GkjNmKO0GFazuAYxKclTkqBgBmvYxKMtMd(GdzjWx(JdQSI46ii0eueOPBObvbeueOouvafKdAWLgcZbbJ0KWb1cLIw(JdQOlZb1tWL0g5TadbbM8VjTHZAEdvz1BbHMGIWbLXvhNfoOIymyzXzHRJiCw4GwUc0YbfoYcZbP1EssXfIxCDeKZchKw7jjfxioOIUmogQaTCqbgDfzYsZ7GX7b0DXtsE)7I8obSCjS9KK30sPbDEhR3zu6ZkOWbTCfOLdEfzYsJxCD0nNfoiT2tskUqCq0ah8OIdA5kqlhmHHd7jjoyctctCqC9MpygMZB95TGE)37F9(hVFWmmafgMMpYWXcbaEW7)E)J3pyggGhgzQluea8G3qHdQOlJJHkqlhuGryKu69flej59dMH58MmSuS3OsJWExA26nlyyYBHidhleVTv5TqyKPUqrCWegEUwkXbX1BIjmsk5fxhOoNfoiT2tskUqCq0ah8OIdA5kqlhmHHd7jjoyctctCWmk9HMdOyRdqrmrokV)KT3c6TOE)GzyaEyKPUqraWdE)3BAjmeXE)jBVfqO59FV)17F8oJwfCuaze8wZsJMiL6aO1Ess594XE)GzyaWiPCwA08Hw6aWuQf759NS9weO5nu4Gk6Y4yOc0Yb)49GXK3JiVHqL3mWsP3cq6d(08oj6H3qSypVTv5THPf6L3ycJKYyH4DsqWB5DPrERNuQZ7hmdZ5TnYeZbty45APeh0sFWN2mJwvubA5fxhbKZchKw7jjfxioiAGdEuXbTCfOLdMWWH9KehmHjHjoygL(qZbuS159NS9opmtTpmVbAvERFE)GzyaEyKPUqraWdERFE)R3pygga0WacxWBuIbGh8wx37YK0waFe4il8uHTra0ApjP8gkEpES3zu6dnhqXwN3S922i1YAggcPM5boOIUmogQaTCq9xSXP5TvENAFisHt9oj6H3p4YBlbkuEpYUkwiElegzQluK32Q8wxdoYc7TUGTrE)ql85DgL(qEpGITooycdpxlL4GmXgN2mJwvubA5fxh9pNfoiT2tskUqCq0ah8OIdA5kqlhmHHd7jjoyctctCWBGKYzzyiuDapPPOjJegJf7T(8wqV)7n2c1KsqBbyk1beR3F6TGqZ7XJ9(bZWa8KMIMmsymwmaMsTypV)0Br8wuVltsBbiCiLXczEdyIaO1EssXbv0LXXqfOLdQNJsZ7uyzfdsY7YWqO6y17sloVty4WEsY748oRrzHjL3fYBfLdf59inQ0iS3hkL8oj6Y59PHGLkVFK3N4ntkVhfLM3cjnf5T(tcJXI5Gjm8CTuId(KMIMmsymw88eVzEX1rGGZchKw7jjfxioyghfHdJdEfzYsJuaMuYbTCfOLdIH3PLRaTtzCfhugxnxlL4GxrMS04fxhOkNfoiT2tskUqCqlxbA5GztkNwUc0oLXvCqzC1CTuIdMvhV46a1YzHdsR9KKIlehmJJIWHXbty4WEscGj240Mz0QIkqlh0YvGwoigENwUc0oLXvCqzC1CTuIdYeBCA8IRJiqJZchKw7jjfxioOLRaTCWSjLtlxbANY4koOmUAUwkXbFWHuXlUoIicNfoiT2tskUqCWmokchghKwcdrmGIyICuE)jBVfra9wuVPLWqedGji0YbTCfOLdA4ST0SqymTfV46iIGCw4GwUc0YbnC2wAoalpIdsR9KKIleV46iIU5SWbTCfOLdkdiA1nHAcRGKsBXbP1EssXfIxCDebQZzHdA5kqlh8zqMiMzHJSWhhKw7jjfxiEXlo4aMYO0NvCw46icNfoOLRaTCqByqkEoGIdTCqATNKuCH4fxhb5SWbTCfOLd(qvjj1KrAIj1OyHml0hILdsR9KKIleV46OBolCqlxbA5GxrMS04G0ApjP4cXlUoqDolCqATNKuCH4GwUc0YbtnSWKAYGWtfzLghmJJIWHXbXwOMucAlatPoGy9(tVfua5GdykJsFwnpkJw1XbfqEX1ra5SWbP1EssXfIdA5kqlheJKYzPrZhAPJdMXrr4W4Gyk1I98wFERBo4aMYO0NvZJYOvDCqb5fxh9pNfoiT2tskUqCqlxbA5GNmY00w1ufzIdMXrr4W4GyIbtNM9KehCatzu6ZQ5rz0QooOG8IxCqMyJtJZcxhr4SWbP1EssXfIdMXrr4W4GpyggGtgzAARAQImbGPul2ZB95ntarRMyk1I98(V3yIbtNM9Keh0YvGwo4jJmnTvnvrM4fxhb5SWbP1EssXfIdA5kqlh8r1iI2zPrtsmDCqfDzCmubA5GcvFS3O17mcjvOrR3fYBHjAW7sJ8oj4O8wrpyggVHhy1B4vs35DPrExggcvEhN32dbxExiVvbXbZ4OiCyCWYWqOcOIuAwOPkiV)0BDZlUo6MZch0YvGwoOkUbRYACqATNKuCH4fV4Gz1XzHRJiCw4G0ApjP4cXbTCfOLd(KMIMmsymwmhurxghdvGwoOqstrER)KWySyVrR3ckQ30sPbDCWmokchgh8giPCwggcvN3FY2Bb9(V3)49dMHb4jnfnzKWySya4bEX1rqolCqATNKuCH4GwUc0YbtyBCACqfDzCmubA5Gc0lwiElaPp4tZ74828wqbYEhBgt2rS69H8(JABCAENT17h59HsPksPZ7h5n8rkVTZBZB4kKrj27BGKsVHxjDN3WxSq8oPTRiS3cWD2DX6nc7TUqwPjf7nOMPqJooyghfHdJd(J3y4LyqyieqQHfEIyMLgntTRi80UZUlwaATNKuE)37F8(kYKLgPamP07)ENWWH9KeGL(GpTzgTQOc069FV)17F8gdVedcdHauKvAsXZtZuOrhaT2tskVhp27hmddGISstkEEAMcn6auOrR3)9oJsFO5ak268wFS9wqVHcV46OBolCqATNKuCH4GObo4rfh0YvGwoycdh2tsCWegEUwkXbtyBCAZuBMrRkQaTCWmokchghedVedcdHasnSWteZS0OzQDfHN2D2DXcqR9KKY7)E)J3LjPTasnSWKAYGWtfzLgaT2tskoOIUmogQaTCq9CuAEN02ve2Bb4UZUlww9(eVzV)O2gNM3JIsZBZBMyJtJWEJWElaPp4tZBfnqRkwiEJwVfQ(yVZiKuHgTS6nc7TjhzIpVnVzInonc79OO08oPz0foyctctCWF9(hVZiKuHgTapQgr0olnAsIPdatMsS3)9oHHd7jjaMyJtBMrRkQaTEdfVhp27F9oJqsfA0c8OAer7S0OjjMoamzkXE)37egoSNKaS0h8PnZOvfvGwVHcV46a15SWbP1EssXfIdIg4GhvCqlxbA5GjmCypjXbtysyIdMWWH9KeatSXPnZOvfvGwoyghfHdJdIHxIbHHqaPgw4jIzwA0m1UIWt7o7UybO1Ess59FVltsBbKAyHj1KbHNkYknaATNKuCWegEUwkXbtyBCAZuBMrRkQaT8IRJaYzHdsR9KKIlehmJJIWHXbty4WEsciHTXPntTzgTQOc069FVtTRi80UZUl2jMsTypVz7n08(V3jmCypjb8KMIMmsymw88eVzoOLRaTCWe2gNgV46O)5SWbP1EssXfIdMXrr4W4G)49dMHbWuyAnzS0edFAaWdCqlxbA5GMctRjJLMy4tJxCDei4SWbP1EssXfIdMXrr4W4G)49vKjlnsbysP3)9(xV)X7Hc794XENWWH9KeatSXPnZOvfvGwVhp27YWqOcOIuAwOPkiV1N3IOBVHch0YvGwoiJ0GqsPvbA5fxhOkNfoiT2tskUqCWmokchgh8hVhkS3)9wrpyggagPbHKsRc0cGPul2ZB95TGCqlxbA5GmsdcjLwfODMLKThXlUoqTCw4G0ApjP4cXbZ4OiCyCWF8(kYKLgPamP07)ENrPp0CafBDERp2ElO3)9(xV)X7mkbT2wajOT0eJ9E8yVv0dMHbGrAqiP0QaTaWdEdfoOLRaTCqfMm1tAk64fxhrGgNfoiT2tskUqCWmokchghm1UIWt7o7UyNyk1I98MT3qZ7)E)GzyauyYupPPOdqHgTE)37F9(bZWaGrs5S0O5dT0bGPul2ZB9X2BD794XENWWH9KeaUEtmHrsP3qHdA5kqlheJKYzPrZhAPJxCDereolCqATNKuCH4GwUc0YbtnSWKAYGWtfzLghmlolPzzyiuDCDeHdMXrr4W4GylutkbTfGPuha8G3)9(xVlddHkGksPzHMQG8wFENrPp0CafBDakIjYr594XE)J3xrMS0ifagbbM8(V3zu6dnhqXwhGIyICuE)jBVZdZu7dZBGwL36N3I4nu4Gk6Y4yOc0Ybf4mEBk15THjVHhy17BJbY7sJ8gTK3JIsZBjAeDL3SWIUa4Ta9iVhPrR3kXXcXBg7kc7DPzR3jrp8wrmrokVryVhfLgcU82wXENe9aGxCDerqolCqATNKuCH4GwUc0YbtnSWKAYGWtfzLghurxghdvGwoOaNX7f5TPuN3JcP0BvqEpkkTy9U0iVx6dL36gAhREdFK3jnJU4nA9(HUZ7rrPHGlVTvS3jrpa4GzCueomoi2c1KsqBbyk1beR3F6TUHM36N3ylutkbTfGPuhGcgBvGwV)79pEFfzYsJuayeeyY7)ENrPp0CafBDakIjYr59NS9opmtTpmVbAvERFElcV46iIU5SWbP1EssXfIdIg4GhvCqlxbA5GjmCypjXbtysyId(J3y4LyqyieqQHfEIyMLgntTRi80UZUlwaATNKuEpES3zesQqJwGe2gNgaMsTypV)0BrGM3Jh7DQDfHN2D2DXoXuQf759NElihurxghdvGwoOaufLouExiVpXB2BbsHugleVbhWe59OO08(JABCAEZGWEN02ve2Bb4o7Uy5Gjm8CTuIdkCiLXczEdyIMjSnoT5jEZ8IRJiqDolCqATNKuCH4GwUc0YbfoKYyHmVbmrCqfDzCmubA5Gc0J8owVfr)eKfVdgVfQ(yVJZB4bVTv59i0c9Y7Sn49hVegIyw9gH92kV1nlI69VcYIOEpkknV1fYknPyVb1mfA0bfVryVhPrR3jTDfH9waUZUlwVJZB4baoyghfHdJdMWWH9KeWtAkAYiHXyXZt8M9(V3jmCypjbiCiLXczEdyIMjSnoT5jEZE)37F8(kYKLgPaWiiWK3)9(xVv0dMHb4r1iI2zPrtsmDaWdE)37hmddGctM6jnfDak0O17)EtlHHigqrmrokV)07F9MwcdrmaMGqR366ElO3I6TicO3qX7XJ9(giPCwggcvhWtAkAYiHXyXE)P3)6TGERFE)GzyauKvAsXZtZuOrha8G3qX7XJ9o1UIWt7o7UyNyk1I98(tVHM3qHxCDera5SWbP1EssXfIdMXrr4W4GjmCypjb8KMIMmsymw88eVzV)79VEtlHHigOIuAwOzQ9bV)0Bb9(V3pyggafMm1tAk6auOrR3Jh7nTegIyV1hBV1n08E8yVVbskNLHHq159NElO3qHdA5kqlh8jnfnXWNgV46iI(NZchKw7jjfxioyghfHdJd(J3xrMS0ifGjLE)37egoSNKaS0h8PnZOvfvGwoOLRaTCWtZuOrPKuXlUoIiqWzHdsR9KKIlehmJJIWHXbFWmmapjcPKWxbGjlxEpES3p0DE)3BMaIwnXuQf75T(8w3qZ7XJ9(bZWaykmTMmwAIHpna4boOLRaTCWbufOLxCDebQYzHdA5kqlh8jri1KbglMdsR9KKIleV46iculNfoOLRaTCWhHpclCSq4G0ApjP4cXlUoccnolCqlxbA5GmbMEsesXbP1EssXfIxCDeueolCqlxbA5G2MPRWMCMnPKdsR9KKIleV46iOGCw4G0ApjP4cXbTCfOLdcF0mkk94Gk6Y4yOc0Yb1fIXGLL3z0QIkq75ndc7n8zpj5Duu6bWbZ4OiCyCWF8gdVedcdHasnSWteZS0OzQDfHN2D2DXcqR9KKY7)EROhmddWJQreTZsJMKy6aGh8(V3)69pExMK2caIg6kP45v4qycGw7jjL3Jh7TIEWmmaq0qxjfpVchctaWdEdfVhp27u7kcpT7S7IDIPul2Z7p9gAEpES3p0DE)3BMaIwnXuQf75T(y7TGqJx8IdEfzYsJZcxhr4SWbP1EssXfIdMXrr4W4GjmCypjbWeBCAZmAvrfOLdA5kqlhuf3GvznEX1rqolCqlxbA5Gw6d(04G0ApjP4cXlUo6MZchKw7jjfxioOLRaTCWSgzdZtdvCWmokchghSmjTfWaMepr7S0O5iYegGw7jjL3)9(hVlddHkG4Mp0DCWS4SKMLHHq1X1reEXlo4doKkolCDeHZch0YvGwo4rdxCCqATNKuCH4fxhb5SWbTCfOLdcrdDLu88kCimXbP1EssXfIxCD0nNfoiT2tskUqCWmokchghedVedcdHaQyfpl0hI88jnfbqR9KKIdA5kqlh80Ie8IRduNZch0YvGwoiL1qXczIPbCKARIdsR9KKIleV46iGCw4G0ApjP4cXbTCfOLdEegBfPMp0sZBieM4GzCueomo4pERqfWrySvKA(qlnVHqycOISWXcX7XJ92YvKGM0sPbDEZ2Br8(V3ylutkbTfGPuhqSE)P3mWs5etznddHMvKsEpES3znddHoV)0Bb9(V3p0DE)3BMaIwnXuQf75T(8wa5GzXzjnlddHQJRJi8IRJ(NZchKw7jjfxioOLRaTCWH4kKCEAOIdQOlJJHkqlhuGEK36rCfs6nOgQ8EuuAERNggq4cEJsS3bJ3jbL(SYB9av0Mf79i0c9YBuccNTbVPLWqeZQ3J0O17O8EuiLEtFWYLuS3zBW7KOhS6nc79inA9g(IfI36AWrwyV1fSnIdMXrr4W4Gpygga0WacxWBuIbGh8(V3)6nTegIyafXe5O8(tV)1BAjmeXayccTElQ3IanVHI3Jh7DgL(qZbuS1bOiMihL36JT3I4TOE)GzyaEyKPUqraWdEpES3LjPTa(iWrw4PcBJaO1Ess5nu4fxhbcolCqATNKuCH4GzCueomo4dMHbanmGWf8gLya4bV)79VE)GzyaGGjApHJ9MJISWe(aGh8E8yVFWmmaz0MjtsQ5tcVkc)GVdaEWBOWbTCfOLdoexHKZtdv8IRduLZch0YvGwo4fBCfHNxHdHjoiT2tskUq8IRdulNfoiT2tskUqCWmokchghSmjTfGkWL4zHJSWhaT2tskV)7DgL(qZbuS1bOiMihL3FY2Br8wuVFWmmapmYuxOia4boOLRaTCqiiyieV4fV4Gji8fOLRJGqtqrGMUHMabhCKH3yHCCq9SaiW0rGRdudOI3EZIg5DKoGWL3miS3qxrmgSSGU3y6Jahys59HsjVn4cLAfP8oRzle6a8V6QyjVH6qfVtcAtq4IuEd9mAvWrbKuq37c5n0ZOvbhfqsbqR9KKc6E)RiFaka(x)REwaey6iW1bQbuXBVzrJ8oshq4YBge2BONvh09gtFe4atkVpuk5TbxOuRiL3znBHqhG)vxfl5TGqfVtcAtq4IuEdDm8smimeciPGU3fYBOJHxIbHHqajfaT2tskO79Vc(bOa4F1vXsERBOI3jbTjiCrkVHogEjgegcbKuq37c5n0XWlXGWqiGKcGw7jjf09(xr(aua8V6QyjVH6qfVtcAtq4IuEdDm8smimeciPGU3fYBOJHxIbHHqajfaT2tskO79VI8bOa4F1vXsEdvHkElq3dEyaHls5TLRaTEdDgPbHKsRc0oZsY2JGoG)vxfl5Ti6gQ4DsqBccxKYBOJHxIbHHqajf09UqEdDm8smimeciPaO1EssbDV)vKpafa)RUkwYBbfeQ4DsqBccxKYBOJHxIbHHqajf09UqEdDm8smimeciPaO1EssbDV)vKpafa)R)vplacmDe46a1aQ4T3SOrEhPdiC5ndc7n0FWHubDVX0hboWKY7dLsEBWfk1ks5DwZwi0b4F1vXsERBOI3jbTjiCrkVHogEjgegcbKuq37c5n0XWlXGWqiGKcGw7jjf092kV)y9KUY7Ff5dqbW)6Ff4PdiCrkV1)EB5kqR3Y4QdW)YbhWiMqsCq9QxV1tWL0g5TadbbM8V6vVEN0goR5nuLvVfeAckI)1)Qx969h)bkdxKY7hXGWK3zu6ZkVFeKypaVfGCMgQZ7fT6NMHtzGLEB5kq75nALIb8VwUc0EadykJsFwX2ggKINdO4qR)1YvG2dyatzu6ZkrzN8dvLKutgPjMuJIfYSqFiw)RLRaThWaMYO0NvIYo5RitwA(xlxbApGbmLrPpReLDYPgwysnzq4PISsJ1bmLrPpRMhLrR6ylGSgmSXwOMucAlatPoGy)uqb0)A5kq7bmGPmk9zLOStgJKYzPrZhAPJ1bmLrPpRMhLrR6yliRbdBmLAXE6t3(xlxbApGbmLrPpReLDYNmY00w1ufzI1bmLrPpRMhLrR6yliRbdBmXGPtZEsY)6F1RE9(J)aLHls5nLGWI9UIuY7sJ82Yfc7DCEBjSqApjb4FTCfO9ylCKf2)QxVfy0vKjlnVdgVhq3fpj59VlY7eWYLW2tsEtlLg05DSENrPpRGI)1YvG2tu2jFfzYsZ)QxVfyegjLEFXcrsE)GzyoVjdlf7nQ0iS3LMTEZcgM8wiYWXcXBBvElegzQluK)1YvG2tu2jNWWH9KeRRLsSX1BIjmskznHjHj246nFWmmN(e8)V)8GzyakmmnFKHJfca8W)FEWmmapmYuxOia4bO4F1R3F8EWyY7rK3qOYBgyP0Bbi9bFAENe9WBiwSN32Q82W0c9YBmHrszSq8oji4T8U0iV1tk159dMH582gzI9VwUc0EIYo5egoSNKyDTuITL(GpTzgTQOc0YActctSZO0hAoGIToafXe5O(KTGI(GzyaEyKPUqraWd)PLWqe)jBbeA))9NmAvWrbKrWBnlnAIuQB84hmddagjLZsJMp0shaMsTyVpzlc0GI)vVER)InonVTY7u7drkCQ3jrp8(bxEBjqHY7r2vXcXBHWitDHI82wL36AWrwyV1fSnY7hAHpVZO0hY7buS15FTCfO9eLDYjmCypjX6APeBMyJtBMrRkQaTSMWKWe7mk9HMdOyR7t25HzQ9H5nqRs)EWmmapmYuxOia4b973hmddaAyaHl4nkXaWd66LjPTa(iWrw4PcBJaO1EssbLXJZO0hAoGITo22gPwwZWqi1mp4F1R365O08ofwwXGK8UmmeQow9U0IZ7egoSNK8ooVZAuwys5DH8wr5qrEpsJknc79HsjVtIUCEFAiyPY7h59jEZKY7rrP5TqstrER)KWySy)RLRaTNOStoHHd7jjwxlLy)KMIMmsymw88eVzwtysyI9nqs5SmmeQoGN0u0KrcJXI1NG)XwOMucAlatPoGy)uqOnE8dMHb4jnfnzKWySyamLAXEFkIOLjPTaeoKYyHmVbmra0ApjP8VwUc0EIYozm8oTCfODkJRyDTuI9vKjlnwdg2xrMS0ifGjL(xlxbAprzNC2KYPLRaTtzCfRRLsSZQZ)A5kq7jk7KXW70YvG2PmUI11sj2mXgNgRbd7egoSNKayInoTzgTQOc06FTCfO9eLDYztkNwUc0oLXvSUwkX(bhsL)1YvG2tu2jB4ST0SqymTfRbdBAjmeXakIjYr9jBreqrPLWqedGji06FTCfO9eLDYgoBlnhGLh5FTCfO9eLDYYaIwDtOMWkiP0w(xlxbAprzN8ZGmrmZchzHp)R)vV61BHGdPIWN)1YvG2d4bhsf7JgU48VwUc0Eap4qQeLDYq0qxjfpVchct(xlxbApGhCivIYo5tlsWAWWgdVedcdHaQyfpl0hI88jnf5FTCfO9aEWHujk7KPSgkwitmnGJuBv(xlxbApGhCivIYo5JWyRi18HwAEdHWeRzXzjnlddHQJTiSgmS)rHkGJWyRi18HwAEdHWeqfzHJfY4XwUIe0KwknOJTi)XwOMucAlatPoGy)KbwkNykRzyi0SIuA84SMHHq3Nc()HU7ptarRMyk1I90Na6F1R3c0J8wpIRqsVb1qL3JIsZB90WacxWBuI9oy8ojO0NvERhOI2SyVhHwOxEJsq4Sn4nTegIyw9EKgTEhL3JcP0B6dwUKI9oBdENe9GvVryVhPrR3WxSq8wxdoYc7TUGTr(xlxbApGhCivIYo5H4kKCEAOI1GH9dMHbanmGWf8gLya4H))slHHigqrmroQp)LwcdrmaMGqROIanOmECgL(qZbuS1bOiMihL(ylIOpyggGhgzQluea8W4XLjPTa(iWrw4PcBJaO1Essbf)RLRaThWdoKkrzN8qCfsopnuXAWW(bZWaGggq4cEJsma8W)FFWmmaqWeTNWXEZrrwycFaWdJh)GzyaYOntMKuZNeEve(bFha8au8VwUc0Eap4qQeLDYxSXveEEfoeM8VwUc0Eap4qQeLDYqqWqiwdg2LjPTaubUeplCKf(aO1Ess9pJsFO5ak26auetKJ6t2Ii6dMHb4HrM6cfbap4F9V6vVENeesQqJ2Z)QxVfsAkYB9NegJf7nA9wqr9MwknOZ)A5kq7bKvh7N0u0KrcJXIznyyFdKuolddHQ7t2c()NhmddWtAkAYiHXyXaWd(x96Ta9IfI3cq6d(08ooVnVfuGS3XMXKDeREFiV)O2gNM3zB9(rEFOuQIu68(rEdFKYB7828gUczuI9(giP0B4vs35n8fleVtA7kc7TaCNDxSEJWERlKvAsXEdQzk0OZ)A5kq7bKvNOStoHTXPXAWW(hm8smimeci1WcprmZsJMP2veEA3z3f7)FUImzPrkatk)NWWH9KeGL(GpTzgTQOc0()3FWWlXGWqiafzLMu880mfA0nE8dMHbqrwPjfppntHgDak0O9FgL(qZbuS1Pp2ccf)RE9wphLM3jTDfH9waU7S7ILvVpXB27pQTXP59OO0828Mj240iS3iS3cq6d(08wrd0QIfI3O1BHQp27mcjvOrlREJWEBYrM4ZBZBMyJtJWEpkknVtAgDX)A5kq7bKvNOStoHHd7jjwxlLyNW240MP2mJwvubAznyyJHxIbHHqaPgw4jIzwA0m1UIWt7o7Uy))tzsAlGudlmPMmi8urwPbqR9KKI1eMeMy)7pzesQqJwGhvJiANLgnjX0bGjtj(Fcdh2tsamXgN2mJwvubAHY4X)MriPcnAbEunIODwA0KethaMmL4)jmCypjbyPp4tBMrRkQaTqX)A5kq7bKvNOStoHHd7jjwxlLyNW240MP2mJwvubAznyyJHxIbHHqaPgw4jIzwA0m1UIWt7o7Uy)xMK2ci1WctQjdcpvKvAa0ApjPynHjHj2jmCypjbWeBCAZmAvrfO1)A5kq7bKvNOStoHTXPXAWWoHHd7jjGe2gN2m1Mz0QIkq7)u7kcpT7S7IDIPul2Jn0(NWWH9KeWtAkAYiHXyXZt8M9VwUc0Eaz1jk7KnfMwtglnXWNgRbd7FEWmmaMctRjJLMy4tdaEW)A5kq7bKvNOStMrAqiP0QaTSgmS)5kYKLgPamP8)V)mu4XJty4WEscGj240Mz0QIkq74XLHHqfqfP0Sqtvq6teDdf)RLRaThqwDIYozgPbHKsRc0oZsY2Jynyy)ZqH)ROhmddaJ0GqsPvbAbWuQf7Ppb9VwUc0Eaz1jk7KvyYupPPOJ1GH9pxrMS0ifGjL)ZO0hAoGITo9XwW))(tgLGwBlGe0wAIXJhROhmddaJ0GqsPvbAbGhGI)1YvG2diRorzNmgjLZsJMp0shRbd7u7kcpT7S7IDIPul2Jn0()GzyauyYupPPOdqHgT))9bZWaGrs5S0O5dT0bGPul2tFS194XjmCypjbGR3etyKucf)RE9wGZ4TPuN3gM8gEGvVVngiVlnYB0sEpkknVLOr0vEZcl6cG3c0J8EKgTERehleVzSRiS3LMTENe9WBfXe5O8gH9EuuAi4YBBf7Ds0da)RLRaThqwDIYo5udlmPMmi8urwPXAwCwsZYWqO6ylcRbdBSfQjLG2cWuQdaE4)VLHHqfqfP0Sqtvq6lJsFO5ak26auetKJA84FUImzPrkamccm9pJsFO5ak26auetKJ6t25HzQ9H5nqRs)ebk(x96TaNX7f5TPuN3JcP0BvqEpkkTy9U0iVx6dL36gAhREdFK3jnJU4nA9(HUZ7rrPHGlVTvS3jrpa8VwUc0Eaz1jk7KtnSWKAYGWtfzLgRbdBSfQjLG2cWuQdi2p1n00pSfQjLG2cWuQdqbJTkq7)FUImzPrkamccm9pJsFO5ak26auetKJ6t25HzQ9H5nqRs)eX)QxVfGQO0HY7c59jEZElqkKYyH4n4aMiVhfLM3FuBJtZBge27K2UIWEla3z3fR)1YvG2diRorzNCcdh2tsSUwkXw4qkJfY8gWentyBCAZt8MznHjHj2)GHxIbHHqaPgw4jIzwA0m1UIWt7o7UyhpoJqsfA0cKW240aWuQf79PiqB84u7kcpT7S7IDIPul27tb9V61Bb6rEhR3IOFcYI3bJ3cvFS3X5n8G32Q8EeAHE5D2g8(JxcdrmREJWEBL36Mfr9(xbzruVhfLM36czLMuS3GAMcn6GI3iS3J0O17K2UIWEla3z3fR3X5n8aG)1YvG2diRorzNSWHuglK5nGjI1GHDcdh2tsapPPOjJegJfppXB(Fcdh2tsachszSqM3aMOzcBJtBEI38)FUImzPrkamccm9)xf9GzyaEunIODwA0Ketha8W)hmddGctM6jnfDak0O9pTegIyafXe5O(8xAjmeXayccT66ckQiciugp(giPCwggcvhWtAkAYiHXyXF(RG63dMHbqrwPjfppntHgDaWdqz84u7kcpT7S7IDIPul27tObf)RLRaThqwDIYo5N0u0edFASgmSty4WEsc4jnfnzKWyS45jEZ))LwcdrmqfP0SqZu7dFk4)hmddGctM6jnfDak0OD8yAjmeX6JTUH24X3ajLZYWqO6(uqO4FTCfO9aYQtu2jFAMcnkLKkwdg2)CfzYsJuaMu(pHHd7jjal9bFAZmAvrfO1)A5kq7bKvNOStEavbAznyy)GzyaEsesjHVcatwUgp(HU7ptarRMyk1I90NUH24XpyggatHP1KXstm8Pbap4FTCfO9aYQtu2j)KiKAYaJf7FTCfO9aYQtu2j)i8ryHJfI)1YvG2diRorzNmtGPNeHu(xlxbApGS6eLDY2MPRWMCMnP0)QxV1fIXGLL3z0QIkq75ndc7n8zpj5Duu6b4FTCfO9aYQtu2jdF0mkk9ynyy)dgEjgegcbKAyHNiMzPrZu7kcpT7S7I9VIEWmmapQgr0olnAsIPdaE4)V)uMK2caIg6kP45v4qycGw7jj14Xk6bZWaardDLu88kCimbapaLXJtTRi80UZUl2jMsTyVpH24Xp0D)zciA1etPwSN(yli08V(x9QxV1FXgNgHp)RLRaThatSXPX(KrMM2QMQitSgmSFWmmaNmY00w1ufzcatPwSN(yciA1etPwS3FmXGPtZEsY)QxVfQ(yVrR3zesQqJwVlK3ct0G3Lg5DsWr5TIEWmmEdpWQ3WRKUZ7sJ8UmmeQ8ooVThcU8UqERcY)A5kq7bWeBCAIYo5hvJiANLgnjX0XAWWUmmeQaQiLMfAQc6tD7FTCfO9ayInonrzNSkUbRYA(x)RE1R3GfzYsZ)A5kq7bCfzYsJTkUbRYASgmSty4WEscGj240Mz0QIkqR)1YvG2d4kYKLMOSt2sFWNM)1YvG2d4kYKLMOStoRr2W80qfRzXzjnlddHQJTiSgmSltsBbmGjXt0olnAoImHbO1Ess9)NYWqOciU5dDhh8gOmxhb1)qJx8IZb]] )

end