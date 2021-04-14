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


    spec:RegisterPack( "Outlaw", 20210413, [[d80kbbqickpIOQUerPs2ee8javJcq5uasRIOuLxrOmliPBPa0UuLFPanmirhdcTmiLNruX0GeQRbqABeuPVbjKgNciCoIsvToakMhrvUhb2hG4GauTqcYdjkzIevQlsukBubu(Oci6KeuvRub9sIsfntcQ4MauANef)KOsmuibhLOuHLsqvEkqtfs1vjQK2kKq8vfq1yvaSxu9xfnyPomvlwv9yjnzsUmYMrXNHOrtKtlA1eLk1RjunBsDBfA3k9BqdxIoUciTCOEUktx46O02LGVlHgpaX5jK5dG9tzoIC05GkpiUmOHs0qeLOyeLZdneLJWfqrKdgIkjoyPxf3rsCW1hjoOCHn0EroyPlsdDfhDo4bzXvIdkfr5bygCqKziX(Fv44GxoYQ9iHBf7mXGxowhKd(ztDi8x(NdQ8G4YGgkrdruIIruop0quocxuIIYbD2qcI5GG5OS4GsPsrl)Zbv0v5GYf2q7fTw4brYs2qaVeNARrenuTgnuIgICqDEXXrNdQigNvhC05YGihDoOxJeUCqXZQ4CqA9VMuCH4bxg04OZbP1)AsXfIdQORIZYiHlhu4rxqUoKSozSUeEx(1K1aBHwxGvVe2)AYAAPXKoRZ16kC87bq5GEns4YbVGCDiXdUmYHJohKw)RjfxioiSKdEuWb9AKWLdwWXP)1ehSGRzjoio(ZpldZzT8SgnRrWAGzTWS(ZYW8cmln)KJZf5JT0AeSwyw)zzyEFm0vxQOhBP1aLdQORIZYiHlhu4ryOwB9Llsnz9NLH5SMCSwK1WqIWwhs(An6ywYAHihNlsR9vzTqyORUurCWcoEU(iXbXXFIjmuR5bxgumhDoiT(xtkUqCqyjh8OGd61iHlhSGJt)RjoybxZsCWkC8dNLWCJ7PiMSMH1arG1OzTyw)zzyEFm0vxQOhBP1iynTegPiRbIaRbuuAncwdmRfM1v4QyZ4vHSBmdjAcvQ7rR)1KYAaaW6pldZdd16zirZpCP7HPrp3ZAGiWAerP1aLdQORIZYiHlhu22JftwxKSgjfwZWQ1wd4JF2tYAzHcwJ0Z9S2xL1oMwGhwJjmuRZfP1YcYUH1HezTCrPoR)SmmN1ErxehSGJNRpsCqF8ZEsZkCvzKWLhCzauo6CqA9VMuCH4GWso4rbh0RrcxoybhN(xtCWcUML4Gv44holH5gN1arG11Y5OdiZRKwL1dO1FwgM3hdD1Lk6XwA9aAnWS(ZYW8GLLqCWUzi6XwATSN1HRPnEdu2Sk(uH9IpA9VMuwduRbaaRRWXpCwcZnoRfyTV5OxLCmssnRLCqfDvCwgjC5GdSCZtYApSE0beRlH3LFnzTSqbRlMHeKnSgwGWmAyXCrA9hUSN1v44hADjm34q1A2vt3zndeBTqHSzDrPSkzTRl6IoRpjiRwz9NSgqfZAzHcCWcoEU(iXbzYnpPzfUQms4YdUmcxo6CqA9VMuCH4GWsoiMok4GEns4Ybl440)AIdwWXZ1hjoitU5jnRWvLrcxoyfNbHtNdwHqTcwCFFkks0odjAsIO7HjxjYAeSMyyOAKfOzfo(HZsyUXzT8Sgq5Gk6Q4Sms4YbbCDrx0zThbnwgwhqRzpYAHczZApSgqfZAzHcOAnMq6yLMUZAiJ1YcfSgjTwx0VG4bxguuo6CqA9VMuCH4GWso4rbh0RrcxoybhN(xtCWcUML4GxjP1ZWXiP4EFTROjJMfJfzT8SgnRrWASNQjvG245k19Y1AGynAO0AaaW6pldZ7RDfnz0SySOhMg9CpRbI1iATywhUM24jEQ15ICELyIE06FnP4Gk6Q4Sms4Ybh4ziz9iRoYsnzD4yKuCOADiLN1fCC6FnzDEwxLOQ4KY6aATIQPISUOefse26doswll5(S(KGSAL1FY6t0wjL1fZqYAH0UISEGPzXyrCWcoEU(iXb)AxrtgnlglAEI2kp4YmqWrNdsR)1KIlehSIZGWPZbVGCDirQNR1CqVgjC5Gy2D61iH7uNxWb15fZ1hjo4fKRdjEWLr2NJohKw)RjfxioOxJeUCWQR1tVgjCN68coOoVyU(iXbRQJhCzqeLC05G06FnP4cXbR4miC6CWcoo9VMEm5MN0ScxvgjC5GEns4YbXS70Rrc3PoVGdQZlMRpsCqMCZtIhCzqero6CqA9VMuCH4GEns4YbRUwp9AKWDQZl4G68I56Jeh8ZMAfp4YGiAC05G06FnP4cXbR4miC6CqAjmsrpfXK1mSgicSgra1AXSMwcJu0dtiPLd61iHlh0XvFPzaXyAdEWLbr5WrNd61iHlh0XvFPzjR(ioiT(xtkUq8GldIOyo6CqVgjC5G6ePuCtz3SkKJ0gCqA9VMuCH4bxgebuo6CqVgjC5GFh5eYmdCwf)4G06FnP4cXdEWblXufo(9GJoxge5OZb9AKWLd6LLArZsyEWLdsR)1KIlep4YGghDoOxJeUCWpmcnPMmAxePkMlYzabKC5G06FnP4cXdUmYHJoh0Rrcxo4fKRdjoiT(xtkUq8GldkMJohKw)RjfxioOxJeUCWrhloPMmq8urEiXbR4miC6CqSNQjvG245k19Y1AGynAakhSetv443J5rv4QooiGYdUmakhDoiT(xtkUqCqVgjC5GyOwpdjA(HlDCWkodcNohetJEUN1YZA5WblXufo(9yEufUQJdIgp4YiC5OZbP1)AsXfId61iHlh80zLM(QMQSsCWkodcNohetmy6K8VM4GLyQch)EmpQcx1XbrJh8Gd(ztTIJoxge5OZb9AKWLdEu5LhhKw)RjfxiEWLbno6CqVgjC5GiLGxOfnVaNItCqA9VMuCH4bxg5WrNdsR)1KIlehSIZGWPZbXSlXaXiPxKROzabKSo)AxrpA9VMuCqVgjC5GNuwGhCzqXC05GEns4YbPQemxKtmvIZrFvCqA9VMuCH4bxgaLJohKw)RjfxioOxJeUCWJWypi18dxAELP4ehSIZGWPZbfM1ky8ocJ9GuZpCP5vMItViRINlsRbaaR9AKfOjT0ysN1cSgrRrWASNQjvG245k19Y1AGyndRwpXuvYXiPzKJK1aaG1vjhJKoRbI1Ozncw)H3zncwZKiLIjMg9CpRLN1akhSkQQPz4yKuCCzqKhCzeUC05G06FnP4cXb9AKWLdwMxa1ZtcgCqfDvCwgjC5GY1JSgfYlGARbLGH1fZqYA5szjehSBgISozSwwWXVhwJcWG2QiRlcxGhwdlq4QxAnTegPiuTUOeTwNH1ftT2Acq8AOfzD1lTwwOaQwdXwxuIwRzVCrATSd2SkU1Yn2lYbR4miC6CWpldZdwwcXb7MHOhBP1iynWSMwcJu0trmzndRbI1aZAAjmsrpmHKwRfZAerP1a1AaaW6kC8dNLWCJ7PiMSMH1YtG1iATyw)zzyEFm0vxQOhBP1aaG1HRPnEdu2Sk(uH9IpA9VMuwduEWLbfLJohKw)RjfxioyfNbHtNd(zzyEWYsioy3me9ylTgbRbM1FwgMhsmr7jEU3SywfNW3JT0AaaW6pldZRc3k5Asn)A2vr4p7Dp2sRbkh0RrcxoyzEbuppjyWdUmdeC05GEns4YbVCZli88cCkoXbP1)AsXfIhCzK95OZbP1)AsXfIdwXzq405GHRPnEQehIMboRIFpA9VMuwJG1v44holH5g3trmzndRbIaRr0AXS(ZYW8(yORUurp2soOxJeUCqKqwKep4bhSQoo6CzqKJohKw)RjfxioOxJeUCWV2v0KrZIXI4Gk6Q4Sms4Ybfs7kY6bMMfJfznCTgnXSMwAmPJdwXzq405GxjP1ZWXiP4SgicSgnRrWAHz9NLH591UIMmAwmw0JTKhCzqJJohKw)RjfxioOxJeUCWc(MNehurxfNLrcxoOC9YfP1a(4N9KSopRDRrt2L15wXKFeQwFqRrr8npjRR(A9NS(GJuKJ0z9NSM9iL1(zTBnBK6mez9vsAT1SRMUZA2lxKwdy9liS1a(D(D5AneBTCtEiPfznOKRGfpoyfNbHtNdkmRXSlXaXiP3OJfFczMHenh9li80VZVl3hT(xtkRrWAHz9fKRdjs9CT2AeSUGJt)RPNp(zpPzfUQms4AncwdmRfM1y2LyGyK0trEiPfnpjxblEpA9VMuwdaaw)zzyEkYdjTO5j5kyX7PGfxRrW6kC8dNLWCJZA5jWA0SgO8GlJC4OZbP1)AsXfIdcl5GhfCqVgjC5GfCC6FnXbl4456JehSGV5jnh9zfUQms4YbR4miC6Cqm7smqms6n6yXNqMzirZr)ccp9787Y9rR)1KYAeSwywhUM24n6yXj1KbINkYdPhT(xtkoOIUkolJeUCWbEgswdy9liS1a(DNFxUOA9jARwJI4BEswxmdjRDRzYnpjcBneBnGp(zpjRvujTQCrAnCTwOq2SUcHAfS4IQ1qS1UUOl6S2TMj38KiS1fZqYAalJCZbl4AwIdcmRfM1viuRGf33NIIeTZqIMKi6EyYvISgbRl440)A6XKBEsZkCvzKW1AGAnaaynWSUcHAfS4((uuKODgs0Ker3dtUsK1iyDbhN(xtpF8ZEsZkCvzKW1AGYdUmOyo6CqA9VMuCH4GWso4rbh0RrcxoybhN(xtCWcUML4GfCC6Fn9yYnpPzfUQms4YbR4miC6Cqm7smqms6n6yXNqMzirZr)ccp9787Y9rR)1KYAeSoCnTXB0XItQjdepvKhspA9VMuCWcoEU(iXbl4BEsZrFwHRkJeU8GldGYrNdsR)1KIlehSIZGWPZbl440)A6vW38KMJ(ScxvgjCTgbRh9li80VZVl3jMg9CpRfynkTgbRl440)A691UIMmAwmw08eTvoOxJeUCWc(MNep4YiC5OZbP1)AsXfIdwXzq405GcZ6pldZZvyADDU0eZEsp2soOxJeUCqxHP115stm7jXdUmOOC05G06FnP4cXbR4miC6CqHz9fKRdjs9CT2AeSgywxWXP)10Jj38KMv4QYiHR1aaG1HJrsXlYrAgWPkjRLN1ikhRbkh0RrcxoiJ2rsAThjC5bxMbco6CqA9VMuCH4GvCgeoDoOWS(cY1HePEUwBncwxHJF4SeMBCwlpbwJM1iynWSwywxHfO134vG2qse2AaaWAf9zzyEmAhjP1EKW9XwAnq5GEns4YbvyYvFTROJhCzK95OZbP1)AsXfIdwXzq405GJ(feE6353L7etJEUN1cSgLwJG1FwgMNctU6RDfDpfS4AncwdmR)SmmpmuRNHen)WLUhMg9CpRLNaRLJ1aaG1fCC6Fn9WXFIjmuRTgOCqVgjC5GyOwpdjA(HlD8GldIOKJohKw)RjfxioOxJeUCWrhloPMmq8urEiXbRIQAAgogjfhxge5GvCgeoDoi2t1KkqB8CL6ESLwJG1aZ6WXiP4f5ind4uLK1YZ6kC8dNLWCJ7PiMSMH1aaG1cZ6lixhsK6HHizjRrW6kC8dNLWCJ7PiMSMH1arG11Y5OdiZRKwL1dO1iAnq5Gk6Q4Sms4Ybf(mw7k1zTJjRzlr16BZsY6qISgUK1fZqYAnSiDH1OJUC)SwUEK1fLO1ALOCrAnJFbHToK81AzHcwRiMSMH1qS1fZqcYgw7RiRLfk84bxgerKJohKw)RjfxioOxJeUCWrhloPMmq8urEiXbv0vXzzKWLdk8zSEHw7k1zDXuRTwLK1fZqkxRdjY6LaKWA5GYdvRzpYAalJCBnCT(dVZ6IzibzdR9vK1YcfECWkodcNohe7PAsfOnEUsDVCTgiwlhuA9aAn2t1KkqB8CL6EkwShjCTgbRfM1xqUoKi1ddrYswJG1v44holH5g3trmzndRbIaRRLZrhqMxjTkRhqRrKhCzqeno6CqA9VMuCH4GWso4rbh0RrcxoybhN(xtCWcUML4GcZAm7smqms6n6yXNqMzirZr)ccp9787Y9rR)1KYAaaW6keQvWI7RGV5j9W0ON7znqSgruAnaay9OFbHN(D(D5oX0ON7znqSgnoOIUkolJeUCqapcASmSoGwFI2Q1YotToxKwdwIjY6IziznkIV5jzndeBnG1VGWwd4353LlhSGJNRpsCqXtToxKZRet0SGV5jnprBLhCzquoC05G06FnP4cXb9AKWLdkEQ15ICELyI4Gk6Q4Sms4YbLRhzDUwJ4aIg6wNmwluiBwNN1SLw7RY6IWf4H1vV0AzBjmsrOAneBThwlh0fZAGHg6IzDXmKSwUjpK0ISguYvWIhqTgITUOeTwdy9liS1a(D(D5ADEwZw(4GvCgeoDoybhN(xtVV2v0KrZIXIMNOTAncwxWXP)10t8uRZf58kXenl4BEsZt0wTgbRfM1xqUoKi1ddrYswJG1aZAf9zzyEFkks0odjAsIO7XwAncw)zzyEkm5QV2v09uWIR1iynTegPONIyYAgwdeRbM10syKIEycjTwl7znAwlM1icOwduRbaaRVssRNHJrsX9(AxrtgnlglYAGynWSgnRhqR)Smmpf5HKw08KCfS49ylTgOwdaawp6xq4PFNFxUtmn65EwdeRrP1aLhCzqefZrNdsR)1KIlehSIZGWPZbl440)A691UIMmAwmw08eTvRrWAGznTegPOxKJ0mGZrhqSgiwJM1iy9NLH5PWKR(Axr3tblUwdaawtlHrkYA5jWA5GsRbaaRVssRNHJrsXznqSgnRbkh0Rrcxo4x7kAIzpjEWLbraLJohKw)RjfxioyfNbHtNdkmRVGCDirQNR1wJG1fCC6Fn98Xp7jnRWvLrcxoOxJeUCWtYvWIJKwXdUmikC5OZbP1)AsXfIdwXzq405GFwgM3xdHkn7fpm51WAaaW6p8oRrWAMePumX0ON7zT8SwoO0AaaW6pldZZvyADDU0eZEsp2soOxJeUCWsyKWLhCzqefLJoh0Rrcxo4xdHQjdlwehKw)RjfxiEWLbXbco6CqVgjC5GFcFew8CrYbP1)AsXfIhCzqu2NJoh0RrcxoitIPVgcvCqA9VMuCH4bxg0qjhDoOxJeUCqFR0fyxpRUwZbP1)AsXfIhCzqdro6CqA9VMuCH4GEns4YbdCUItbICqfDvCwgjC5GYnX4S6W6kCvzKW9SMbITM98VMSodA8ECWkodcNohurFwgM3NIIeTZqIMKi6ESLwdaawh4CfNIxG4tYV5fE88v0uvEwdaawZKiLIjMg9CpRLNaRrdL8GldAOXrNdsR)1KIlehSIZGWPZbv0NLH59POir7mKOjjIUhBP1aaG1boxXP4fO9K8BEHhpFfnvLN1aaG1mjsPyIPrp3ZA5jWA0qjh0RrcxoyGZvCkqJh8GdEb56qIJoxge5OZbP1)AsXfIdwXzq405GfCC6Fn9yYnpPzfUQms4Yb9AKWLdQYR0JQep4YGghDoOxJeUCqF8ZEsCqA9VMuCH4bxg5WrNdsR)1KIleh0RrcxoyvI8Y5jbdoyfNbHtNdgUM24vIjrt4odjAwKCXF06FnPSgbRfM1HJrsXlV5hEhhSkQQPz4yKuCCzqKh8GdYKBEsC05YGihDoiT(xtkUqCqVgjC5GFkks0odjAsIOJdQORIZYiHlhuOq2SgUwxHqTcwCToGwlorLwhsK1YcNH1k6ZYWynBjQwZUA6oRdjY6WXiPW68S2)q2W6aATkjoyfNbHtNdgogjfVihPzaNQKSgiwlhEWLbno6CqA9VMuCH4GvCgeoDo4NLH5D6SstFvtvwPhMg9CpRLN1mjsPyIPrp3ZAeSgtmy6K8VM4GEns4YbpDwPPVQPkRep4Yiho6CqVgjC5GQ8k9OkXbP1)AsXfIh8GhCWce(s4YLbnuIgIOuoiIsoyrhV5I84GdCax4jJWxMbsaJ1wJUezDowcXH1mqS1axrmoRoaU1yAGYMysz9bhjRD2ao6bPSUk5ls6E2qHtUK1OyaJ1YcUfiCqkRbEfUk2mEdaWToGwd8kCvSz8gGhT(xtkGBnWqeqa6ZgAdh4aUWtgHVmdKagRTgDjY6CSeIdRzGyRbEvDa3AmnqztmPS(GJK1oBah9GuwxL8fjDpBOWjxYA0amwll4wGWbPSg4y2LyGyK0BaaU1b0AGJzxIbIrsVb4rR)1Kc4wdm0aeG(SHcNCjRLdGXAzb3ceoiL1ahZUedeJKEdaWToGwdCm7smqms6napA9VMua3AGHiGa0Nnu4KlznkgWyTSGBbchKYAGJzxIbIrsVba4whqRboMDjgigj9gGhT(xtkGBnWqeqa6ZgkCYLSgr0amwll4wGWbPSg4y2LyGyK0BaaU1b0AGJzxIbIrsVb4rR)1Kc4wdmebeG(SHcNCjRrdraJ1YcUfiCqkRbEGZvCkEi(gaGBDaTg4boxXP4fi(gaGBnWqeqa6ZgkCYLSgn0amwll4wGWbPSg4boxXP4H2BaaU1b0AGh4CfNIxG2BaaU1adrabOpBOnCGd4cpze(YmqcyS2A0LiRZXsioSMbITg4F2uRaU1yAGYMysz9bhjRD2ao6bPSUk5ls6E2qHtUK1YbWyTSGBbchKYAGJzxIbIrsVba4whqRboMDjgigj9gGhT(xtkGBThwlBYfHJ1adrabOpBOneDjYAGZE0mdA8aU1Ens4ADr)SEHH1mq2vzDUwhs5zDowcXXZgk8hlH4GuwlCT2RrcxR15f3ZgYbVsQYLbnHlk5GLyitQjoO8LV1Yf2q7fTw4brYs2q5lFRb8sCQTgr0q1A0qjAiAdTHYx(wlBacvzdsz9NyGyY6kC87H1FczU3ZAaVwPY4SEH7ak54rgwT1Ens4EwdxTONn0Rrc37vIPkC87HaVSulAwcZdU2qVgjCVxjMQWXVhIjyWpmcnPMmAxePkMlYzabKCTHEns4EVsmvHJFpetWGxqUoKSHEns4EVsmvHJFpetWGJowCsnzG4PI8qc1smvHJFpMhvHR6eaOOMmcWEQMubAJNRu3lxGGgGAd9AKW9ELyQch)EiMGbXqTEgs08dx6qTetv443J5rv4QobOHAYiatJEUN8KJn0Rrc37vIPkC87Hycg80zLM(QMQSsOwIPkC87X8OkCvNa0qnzeGjgmDs(xt2qBO8LV1YgGqv2GuwtfiSiRJCKSoKiR9AaXwNN1Ebp1(xtpBOxJeUNaXZQ42q5BTWJUGCDizDYyDj8U8RjRb2cTUaREjS)1K10sJjDwNR1v443dGAd9AKW9etWGxqUoKSHY3AHhHHAT1xUi1K1FwgMZAYXArwddjcBDi5R1OJzjRfICCUiT2xL1cHHU6sfzd9AKW9etWGfCC6FnH66JKaC8Nycd1Aul4Awsao(ZpldZjp0qayc7ZYW8cmln)KJZf5JTebH9zzyEFm0vxQOhBjqTHY3AzBpwmzDrYAKuyndRwBnGp(zpjRLfkynsp3ZAFvw7yAbEynMWqToxKwlli7gwhsK1YfL6S(ZYWCw7fDr2qVgjCpXemybhN(xtOU(ijWh)SN0ScxvgjCrTGRzjbv44holH5g3trmzndGianX(SmmVpg6Qlv0JTebAjmsraraGIseaMWQWvXMXRcz3ygs0eQuhaa8zzyEyOwpdjA(HlDpmn65EaraIOeO2q5B9al38KS2dRhDaX6s4D5xtwlluW6IzibzdRHfimJgwmxKw)Hl7zDfo(HwxcZnouTMD10DwZaXwluiBwxukRsw76IUOZ6tcYQvw)jRbuXSwwOGn0Rrc3tmbdwWXP)1eQRpscyYnpPzfUQms4IAbxZscQWXpCwcZnoGiOwohDazEL0QgWpldZ7JHU6sf9ylhqG9zzyEWYsioy3me9ylL9cxtB8gOSzv8Pc7fF06FnPakaauHJF4SeMBCc8nh9QKJrsQzT0gkFRbCDrx0zThbnwgwhqRzpYAHczZApSgqfZAzHcOAnMq6yLMUZAiJ1YcfSgjTwx0VGSHEns4EIjyWcoo9VMqD9rsatU5jnRWvLrcxuHLcW0rbQjJGkeQvWI77trrI2zirtseDpm5kriqmmunYc0Sch)Wzjm34KhGAdLV1d8mKSEKvhzPMSoCmskouToKYZ6coo9VMSopRRsuvCszDaTwr1urwxuIcjcB9bhjRLLCFwFsqwTY6pz9jARKY6IzizTqAxrwpW0SySiBOxJeUNycgSGJt)RjuxFKe81UIMmAwmw08eTvul4AwsWvsA9mCmskU3x7kAYOzXyrYdneWEQMubAJNRu3lxGGgkbaGpldZ7RDfnz0SySOhMg9CpGGOyHRPnEINADUiNxjMOhT(xtkBOxJeUNycgeZUtVgjCN68cuxFKeCb56qc1KrWfKRdjs9CT2g61iH7jMGbRUwp9AKWDQZlqD9rsqvD2qVgjCpXemiMDNEns4o15fOU(ijGj38KqnzeuWXP)10Jj38KMv4QYiHRn0Rrc3tmbdwDTE61iH7uNxG66JKGpBQv2qVgjCpXemOJR(sZaIX0gOMmcOLWif9uetwZaicqeqfJwcJu0dtiP1g61iH7jMGbDC1xAwYQpYg61iH7jMGb1jsP4MYUzvihPnSHEns4EIjyWVJCczMboRIF2qBO8LV1cXMAfHpBOxJeU37ZMALGJkV8SHEns4EVpBQvIjyqKsWl0IMxGtXjBOxJeU37ZMALycg8KYcOMmcWSlXaXiPxKROzabKSo)Axr2qVgjCV3Nn1kXemivLG5ICIPsCo6RYg61iH79(SPwjMGbpcJ9GuZpCP5vMItOwfv10mCmskobiIAYiqyky8ocJ9GuZpCP5vMItViRINlsaaWRrwGM0sJjDcqebSNQjvG245k19YfimSA9etvjhJKMrosaaqvYXiPdiOHWhEhcmjsPyIPrp3tEaQnu(wlxpYAuiVaQTgucgwxmdjRLlLLqCWUziY6KXAzbh)EynkadARISUiCbEynSaHREP10syKIq16Is0ADgwxm1ARjaXRHwK1vV0AzHcOAneBDrjATM9YfP1YoyZQ4wl3yVOn0Rrc379ztTsmbdwMxa1ZtcgOMmc(SmmpyzjehSBgIESLiamAjmsrpfXK1macWOLWif9WesAfdrucuaaOch)Wzjm34EkIjRzipbik2NLH59XqxDPIESLaaq4AAJ3aLnRIpvyV4Jw)RjfqTHEns4EVpBQvIjyWY8cOEEsWa1KrWNLH5bllH4GDZq0JTebG9zzyEiXeTN45EZIzvCcFp2saa4ZYW8QWTsUMuZVMDve(ZE3JTeO2qVgjCV3Nn1kXem4LBEbHNxGtXjBOxJeU37ZMALycgejKfjHAYiiCnTXtL4q0mWzv87rR)1KcHkC8dNLWCJ7PiMSMbqeGOyFwgM3hdD1Lk6XwAdTHYx(wlliuRGf3ZgkFRfs7kY6bMMfJfznCTgnXSMwAmPZg61iH79QQtWx7kAYOzXyrOMmcUssRNHJrsXbebOHGW(SmmVV2v0KrZIXIESL2q5BTC9YfP1a(4N9KSopRDRrt2L15wXKFeQwFqRrr8npjRR(A9NS(GJuKJ0z9NSM9iL1(zTBnBK6mez9vsAT1SRMUZA2lxKwdy9liS1a(D(D5AneBTCtEiPfznOKRGfpBOxJeU3RQoXemybFZtc1KrGWWSlXaXiP3OJfFczMHenh9li80VZVlxee2fKRdjs9CTgHcoo9VME(4N9KMv4QYiHlcatyy2LyGyK0trEiPfnpjxblEaaWNLH5PipK0IMNKRGfVNcwCrOch)Wzjm34KNa0aQnu(wpWZqYAaRFbHTgWV787YfvRprB1AueFZtY6IzizTBntU5jryRHyRb8Xp7jzTIkPvLlsRHR1cfYM1viuRGfxuTgIT21fDrN1U1m5MNeHTUygswdyzKBBOxJeU3RQoXemybhN(xtOU(ijOGV5jnh9zfUQms4IAYiaZUedeJKEJow8jKzgs0C0VGWt)o)UCrqyHRPnEJowCsnzG4PI8q6rR)1Kc1cUMLeamHvHqTcwCFFkks0odjAsIO7HjxjcHcoo9VMEm5MN0ScxvgjCbkaaaSkeQvWI77trrI2zirtseDpm5kriuWXP)10Zh)SN0ScxvgjCbQn0Rrc37vvNycgSGJt)RjuxFKeuW38KMJ(ScxvgjCrnzeGzxIbIrsVrhl(eYmdjAo6xq4PFNFxUieUM24n6yXj1KbINkYdPhT(xtkul4AwsqbhN(xtpMCZtAwHRkJeU2qVgjCVxvDIjyWc(MNeQjJGcoo9VMEf8npP5OpRWvLrcxeg9li80VZVl3jMg9CpbOeHcoo9VMEFTROjJMfJfnprB1g61iH79QQtmbd6kmTUoxAIzpjutgbc7ZYW8CfMwxNlnXSN0JT0g61iH79QQtmbdYODKKw7rcxutgbc7cY1HePEUwJaWk440)A6XKBEsZkCvzKWfaachJKIxKJ0mGtvsYdr5auBOxJeU3RQoXemOctU6RDfDOMmce2fKRdjs9CTgHkC8dNLWCJtEcqdbGjSkSaT(gVc0gsIWaaGI(SmmpgTJK0Aps4(ylbQn0Rrc37vvNycged16zirZpCPd1KrWOFbHN(D(D5oX0ON7jaLi8zzyEkm5QV2v09uWIlca7ZYW8WqTEgs08dx6EyA0Z9KNa5aaafCC6Fn9WXFIjmuRbQnu(wl8zS2vQZAhtwZwIQ13MLK1HeznCjRlMHK1Ayr6cRrhD5(zTC9iRlkrR1kr5I0Ag)ccBDi5R1YcfSwrmzndRHyRlMHeKnS2xrwllu4zd9AKW9Ev1jMGbhDS4KAYaXtf5HeQvrvnndhJKItaIOMmcWEQMubAJNRu3JTebGfogjfVihPzaNQKKxfo(HZsyUX9uetwZaaae2fKRdjs9WqKSecv44holH5g3trmzndGiOwohDazEL0QgqebQnu(wl8zSEHw7k1zDXuRTwLK1fZqkxRdjY6LaKWA5GYdvRzpYAalJCBnCT(dVZ6IzibzdR9vK1YcfE2qVgjCVxvDIjyWrhloPMmq8urEiHAYia7PAsfOnEUsDVCbICq5aI9unPc0gpxPUNIf7rcxee2fKRdjs9WqKSecv44holH5g3trmzndGiOwohDazEL0QgqeTHY3AapcASmSoGwFI2Q1YotToxKwdwIjY6IziznkIV5jzndeBnG1VGWwd4353LRn0Rrc37vvNycgSGJt)RjuxFKeiEQ15ICELyIMf8npP5jAROwW1SKaHHzxIbIrsVrhl(eYmdjAo6xq4PFNFxUaaqfc1kyX9vW38KEyA0Z9acIOeaag9li80VZVl3jMg9CpGGMnu(wlxpY6CTgXben0TozSwOq2SopRzlT2xL1fHlWdRREP1Y2syKIq1Ai2ApSwoOlM1adn0fZ6IzizTCtEiPfznOKRGfpGAneBDrjATgW6xqyRb8787Y168SMT8zd9AKW9Ev1jMGbfp16CroVsmrOMmck440)A691UIMmAwmw08eTvek440)A6jEQ15ICELyIMf8npP5jARiiSlixhsK6HHizjeaMI(SmmVpffjANHenjr09ylr4ZYW8uyYvFTRO7PGfxeOLWif9uetwZaiaJwcJu0dtiPv2dnXqeqbkaaCLKwpdhJKI791UIMmAwmweqagAd4NLH5PipK0IMNKRGfVhBjqbaGr)ccp9787YDIPrp3diOeO2qVgjCVxvDIjyWV2v0eZEsOMmck440)A691UIMmAwmw08eTveagTegPOxKJ0mGZrhqacAi8zzyEkm5QV2v09uWIlaaqlHrksEcKdkbaGRK06z4yKuCabnGAd9AKW9Ev1jMGbpjxblosAfQjJaHDb56qIupxRrOGJt)RPNp(zpPzfUQms4Ad9AKW9Ev1jMGblHrcxutgbFwgM3xdHkn7fpm51aaa(W7qGjrkftmn65EYtoOeaa(SmmpxHP115stm7j9ylTHEns4EVQ6etWGFneQMmSyr2qVgjCVxvDIjyWpHpclEUiTHEns4EVQ6etWGmjM(Aiuzd9AKW9Ev1jMGb9TsxGD9S6ATnu(wl3eJZQdRRWvLrc3ZAgi2A2Z)AY6mOX7zd9AKW9Ev1jMGbdCUItbIOMmcu0NLH59POir7mKOjjIUhBjaae4CfNIhIpj)Mx4XZxrtv5baamjsPyIPrp3tEcqdL2qVgjCVxvDIjyWaNR4uGgQjJaf9zzyEFkks0odjAsIO7XwcaaboxXP4H2tYV5fE88v0uvEaaatIukMyA0Z9KNa0qPn0gkF5B9al38Ki8zdLV1cfYM1W16keQvWIR1b0AXjQ06qISww4mSwrFwggRzlr1A2vt3zDirwhogjfwNN1(hYgwhqRvjzd9AKW9Em5MNKGpffjANHenjr0HAYiiCmskErosZaovjbe5yd9AKW9Em5MNKycg80zLM(QMQSsOMmc(SmmVtNvA6RAQYk9W0ON7jpMePumX0ON7HaMyW0j5Fnzd9AKW9Em5MNKycguLxPhvjBOnu(Y3AWGCDizd9AKW9ExqUoKeOYR0JQeQjJGcoo9VMEm5MN0ScxvgjCTHEns4EVlixhsIjyqF8ZEs2qVgjCV3fKRdjXemyvI8Y5jbduRIQAAgogjfNaernzeeUM24vIjrt4odjAwKCXF06FnPqqyHJrsXlV5hEhp4bNda]] )
end