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
            duration = 10,
            max_stack = 1,
        },
        moderate_insight = {
            id = 340583,
            duration = 10,
            max_stack = 1,
        },
        deep_insight = {
            id = 340584,
            duration = 10,
            max_stack = 1,
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
            gcd = "spell",

            talent = "marked_for_death", 

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
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

            -- nobuff = "master_assassin_any",

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

    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
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


    spec:RegisterPack( "Outlaw", 20210124, [[d4ep1aqiPQ6reexcHkXMqiFcHYOaQCkGuRcHkvVIqAwKc3IsvAxQ0ViLAyavDmqvlJG6zuQQPrPsDnsrSncs5BuQIghcvX5asO1bKK5rPI7HG9jvLdcKOfsGEiPetKuuDrsrQnsks(ibPQtcKuRKszMKIIBsqQStc4NiuvdLGKJIqvAPiuXtbmvqLRsPkSveQu(kqcglLkzVq9xPmyLomvlwfpMIjtYLrTze9zqz0KQtlz1iuj9AcXSj62sLDR43qgoLCCsrPLJ0Zv10fUoiBhO8DGy8Ks68eQ5lvz)IgdpgomGYdglGWGxy4bp8cB3x4bp82t4HhdeITymGLBeXHXyGX7ymaXhkKoiyalxSe5kmCyGhbrnmgqpcRhuPT2WQqh6CnOoT)Qds6rHgd1jdT)QZOng4avYaup4dgq5bJfqyWlm8GhEHT7l8GhEHMDdpgWHcDefdauDAbdOxkfp4dgqXVbdieHKlXhkKoi5sCqWG40MqesU28bYPIZvy7wJCfg8cdpgqwF8y4WakM0HKbgoSaWJHdd4MOqdgqKYicgGh)izfwqCGfqymCyaE8JKvybXak(n0Ykk0Gbio8hSld9ClYCTq)xhjNl4guUGbjhM6hjNlpCxXFU1KRb1D8a0ya3efAWaFWUm0Xbwa7JHddWJFKScligazHbEoWaUjk0GbaZPLFKmgamxcXyaACAhisYpx7KRW5suUGl3(Z9arsEdke3oStRb2fYkxIYT)CpqKK3df5QVu8fYkxqJbu8BOLvuObdqCykskZ9RbMKZ9ars(5YovkoxuOZ0CdDFYfokeNRGStRbwU(OYvqkYvFPymayoTnEhJbOXPrzkskXbwa7gdhgGh)izfwqmaYcd8CGbCtuObdaMtl)izmayUeIXagu3b1Sq1e)vXKLPIC7JqUcNRO5EGijVhkYvFP4lKvUeLlpmfM4C7JqUAc4ZLOCbxU9NRbnkOkUge0eTqNBiL6V84hjRYTxVCpqKKxkskBHo3oOH)lL78A(C7JqUWd(CbngqXVHwwrHgmGMEEikNliCUW4ixsiPmxqz3b61ZvlcvUW8A(C9rLRt5HyrUuMIKYAGLRwqqtKBOZ5s8vQp3dej5NRdIlgdaMtBJ3XyaV7a96ndAuvuObhyb0emCyaE8JKvybXailmWZbgWnrHgmayoT8JKXaG5sigdyqDhuZcvt852hHCnwToxRT3IhvU2BUhisY7HIC1xk(czLR9Ml4Y9arsErwwiAanvi(czLlX9CdxYtC1SqLrKMI6GC5XpswLlOZTxVCnOUdQzHQj(CjKRpvNB0Dkmw1mwyaf)gAzffAWaAQAQxpxpYTZ1A1b1LRweQCpqrUoyOsLli(h1alxbPix9LIZ1hvUeVqLrKC1CQdsUh0a95AqDhuUwOAIhdaMtBJ3XyaYAQxVzqJQIcn4alGqddhgGh)izfwqmaYcd8CGbCtuObdaMtl)izmayUeIXaVflLTWPW44VhPR4gPeIsfNRDYv4CjkxQxQgdgpX1vQ)wtU9LRWGp3E9Y9arsEpsxXnsjeLk(czHbu8BOLvuObdakuHEUDqYOSKCUHtHXXRrUHE95cMtl)i5CRpxJoBeHv5gOCvSPuCUGOZHotZ9rDCUArZ)CFDeKuL7HZ9fpgwLlivONRGsxX5QPKquQymayoTnEhJbosxXnsjeLkU9IhdoWcypXWHb4XpswHfedyOvW0YXaFWUm0z11LsmGBIcnyak00CtuOPjRpWaY6J24Dmg4d2LHooWcq8GHddWJFKScligWnrHgmGXLYMBIcnnz9bgqwF0gVJXag1JdSaGIy4Wa84hjRWcIbm0kyA5yaWCA5hjFjRPE9MbnQkk0GbCtuObdqHMMBIcnnz9bgqwF0gVJXaK1uVooWcap4XWHb4XpswHfed4MOqdgW4szZnrHMMS(adiRpAJ3XyGdujv4ala8WJHddWJFKScligWqRGPLJb4HPWeFvmzzQi3(iKl8AsUIMlpmfM4lLHXdgWnrHgmGtn(WTarP8e4ala8cJHdd4MOqdgWPgF4MfK8zmap(rYkSG4ala82hdhgWnrHgmGSGPhFJ4kKcwhpbgGh)izfwqCGfaE7gdhgWnrHgmWXH1qKTGwgrEmap(rYkSG4ahyalkBqDhpWWHfaEmCya3efAWaULLuCZcvpAWa84hjRWcIdSacJHdd4MOqdg4GIqYQgP0fZkqQbwlqATgmap(rYkSG4alG9XWHbCtuObd8b7YqhdWJFKSclioWcy3y4Wa84hjRWcIbCtuObd05uryvJerBk2dDmGHwbtlhdq9s1yW4jUUs93AYTVCfwtWawu2G6oE0E2Gg1Jb0eCGfqtWWHb4XpswHfed4MOqdgGIKYwOZTdA4hdyOvW0YXauUZR5Z1o5AFmGfLnOUJhTNnOr9yaHXbwaHggomap(rYkSGya3efAWaVSmCZhvtvggdyOvW0YXauMKYVUFKmgWIYgu3XJ2Zg0OEmGW4ahyGdujvy4WcapgomGBIcnyGNT(6Xa84hjRWcIdSacJHdd4MOqdgaMo6dP42h0segdWJFKSclioWcyFmCyaE8JKvybXagAfmTCmafAysefgFJAe3cKwlt7iDfF5XpswHbCtuObd86fy4alGDJHdd4MOqdgGn6OAG1OSfT68rHb4XpswHfehyb0emCyaE8JKvybXaUjk0GbEMs9GvTdA42BvIWyadTcMwogO)CvO4(mL6bRAh0WT3QeHVrzePgy52RxUUjkW4gpCxXFUeYf(CjkxQxQgdgpX1vQ)wtU9LljKu2OSr3PW4wuDCU96LRr3PW4p3(Yv4CjkxYcME0OCNxZNRDYvtWagXgj3cNcJJhla84alGqddhgGh)izfwqmGBIcnyaR6dKS96OadO43qlROqdgWE8CUcv9bsMlGokYfKk0ZL4BzHOb0uH4ClYC1cQ74rUcfk4XioxqqdXICrGXuJBLlpmfMynYfeDEYTICbPKYCzT6MqkoxJBLRweknYfrZfeDEYf6RbwUeVqLrKC1CQdcgWqRGPLJboqKKxKLfIgqtfIVqw5suUGlxEykmXxftwMkYTVCbxU8WuyIVuggp5kAUWd(CbDU96LRb1DqnlunXFvmzzQix7qix4Zv0CpqKK3df5QVu8fYk3E9YnCjpXvZcvgrAkQdYLh)izvUGghybSNy4Wa84hjRWcIbm0kyA5yGdej5fzzHOb0uH4lKvUeLl4Y9arsEHrzEErQ5BGugry6FHSYTxVCpqKKxdAmSlzv7iHgftpq)FHSYf0ya3efAWaw1hiz71rboWcq8GHdd4MOqdg4RP(GPTpOLimgGh)izfwqCGfauedhgGh)izfwqmGHwbtlhdeUKN4QkAiUf0YiYF5XpswLlr5AqDhuZcvt8xftwMkYTpc5cFUIM7bIK8EOix9LIVqwya3efAWaWqqWyCGdmGr9y4Wcapgomap(rYkSGya3efAWahPR4gPeIsfJbu8BOLvuObdiO0vCUAkjeLkox0KRWIMlpCxXpgWqRGPLJbElwkBHtHXXNBFeYv4Cjk3(Z9arsEpsxXnsjeLk(czHdSacJHddWJFKScligWnrHgmay(uVogqXVHwwrHgmG94RbwUGYUd0RNB9565kmXLCRXqz)znY9r5sCZN61Z14tUho3h1Xr1XFUhoxONv56FUEUqrjRqCUVflL5cns()CH(AGLRqN)btZfu(V)Fn5IO5Q5Sh6sX5cO7keipgWqRGPLJb6pxk0WKikm(25urAiYwOZTo)dM28)9)R5YJFKSkxIYT)C)GDzOZQRlL5suUG50Yps(6DhOxVzqJQIcn5suUGl3(ZLcnmjIcJVk2dDP42R7kei)Lh)izvU96L7bIK8Qyp0LIBVURqG8xfcKjxIY1G6oOMfQM4Z1oeYv4CbnoWcyFmCyaE8JKvybXagAfmTCmafAysefgF7CQinezl05wN)btB()()1C5XpswLlr525FW0M)V)Fnnk35185sixWNlr5cMtl)i57r6kUrkHOuXTx8yYLOCbxU9NRbHKkeiZ9WbimpTqNBSy(Vu2vIZLOCbZPLFK8LSM61Bg0OQOqtU96LRbHKkeiZ9WbimpTqNBSy(Vu2vIZLOCbZPLFK817oqVEZGgvffAYf05suUGl3(Z1GgfufxdcAIwOZnKs9xE8JKv52RxUhisYlfjLTqNBh0W)LYDEnFU9rix4bFUGgd4MOqdgamFQxhhybSBmCya3efAWaKshglLEuObdWJFKSclioWcOjy4Wa84hjRWcIbm0kyA5yafFGijVKshglLEuO5s5oVMpx7KRWya3efAWaKshglLEuOPzKSppJdSacnmCyaE8JKvybXagAfmTCmq)5EGijVUIYJlRHBuOx)czLlr5cUC7pxdcjviqMRiLuwdS2Brz(czLBVE52FUHl5jUIusznWAVfL5lp(rYQCbngWnrHgmGRO84YA4gf61Xbwa7jgomap(rYkSGyadTcMwogOZ)GPn)F))AAuUZR5ZLqUGpxIYfC5EGijVuKu2cDUDqd)xk35185Ahc5A)C71lxWCA5hjFPXPrzkskZf0ya3efAWauKu2cDUDqd)4alaXdgomap(rYkSGya3efAWaDovew1ir0MI9qhdyeBKClCkmoESaWJbm0kyA5yaQxQgdgpX1vQ)czLlr5cUCdNcJJBuDClqnvX5ANCnOUdQzHQj(RIjltf52RxU9N7hSldDwDPiyqCUeLRb1DqnlunXFvmzzQi3(iKRXQ15AT9w8OY1EZf(CbngqXVHwwrHgmaOMmxxP(CDkNlKLg5(tzX5g6CUOHZfKk0ZvIaH)ix4GtZV5ApEoxq05jxL4AGLlP)btZn09jxTiu5QyYYurUiAUGuHockY1hX5QfH6IdSaGIy4Wa84hjRWcIbCtuObd05uryvJerBk2dDmGIFdTSIcnyaqnzUdkxxP(CbPKYCvfNlivOxtUHoN7WAnY1(G)1ixONZvOJuZZfn5Eq)NlivOJGIC9rCUArOUyadTcMwogG6LQXGXtCDL6V1KBF5AFWNR9Ml1lvJbJN46k1Fvqupk0Klr52FUFWUm0z1LIGbX5suUgu3b1Sq1e)vXKLPIC7JqUgRwNR12BXJkx7nx4Xbwa4bpgomap(rYkSGyadTcMwogamNw(rY3J0vCJucrPIBV4XKlr5cUC5HPWeFJQJBbQ15An3(Yv4C71l33ILYw4uyC852xUcNlOXaUjk0GbePKYAG1ElkZ4ala8WJHddWJFKScligWqRGPLJbaZPLFK89iDf3iLquQ42lEm5suUGlxEykmX3O64wGADUwZTVCfo3E9Y9TyPSfofghFU9LRW5cAmGBIcnyGJ0vCJc964ala8cJHddWJFKScligWqRGPLJb6p3pyxg6S66szUeLRb1DqnlunXNRDiKl8ya3efAWakk7QJ0v8JdSaWBFmCyaE8JKvybXagAfmTCmq)5(b7YqNvxxkZLOCbZPLFK817oqVEZGgvffAWaUjk0GbEDxHaPJLkCGfaE7gdhgGh)izfwqmGHwbtlhdCGijVhjcPKqFCPSBIC71lxYcME0OCNxZNRDY1(Gp3E9Y9arsEDfLhxwd3OqV(fYcd4MOqdgWcffAWbwa41emCya3efAWahjcPAKquXyaE8JKvybXbwa4fAy4WaUjk0Gbom9zQi1addWJFKSclioWcaV9edhgWnrHgmazr5JeHuyaE8JKvybXbwa4jEWWHbCtuObd4JH)G6YMXLsmap(rYkSG4ala8GIy4Wa84hjRWcIbCtuObda9CRcU7Xak(n0Ykk0Gb0CM0HKrUg0OQOqZNljIMl07hjNBfC3FXagAfmTCmq)5sHgMerHX3oNksdr2cDU15FW0M)V)FnxE8JKv5suUk(arsEpCacZtl05glM)lKvUeLl4YT)CdxYtCHPJ(qkU9bTeHV84hjRYTxVCv8bIK8cth9HuC7dAjcFHSYf052RxUD(hmT5)7)xtJYDEnFU9Ll4ZTxVCjly6rJYDEnFU2HqUcdECGdmWhSldDmCybGhdhgGh)izfwqmGHwbtlhdaMtl)i5lzn1R3mOrvrHgmGBIcnyav9wEy0XbwaHXWHbCtuObd4DhOxhdWJFKSclioWcyFmCyaE8JKvybXaUjk0Gbm6SB1EDuGbm0kyA5yGWL8exlklUHMwOZnqyxKlp(rYQCjk3(ZnCkmoU13oO)XagXgj3cNcJJhla84ahyaYAQxhdhwa4XWHb4XpswHfedyOvW0YXahisY7lld38r1uLHVuUZR5Z1o5swW0JgL78A(Cjkxkts5x3psgd4MOqdg4LLHB(OAQYW4alGWy4Wa84hjRWcIbu8BOLvuObdiyOPZfn5AqiPcbYKBGYveMTYn05C1cTICv8bIKmxilmGBIcnyGdhGW80cDUXI5hhybSpgomGBIcnyav9wEy0Xa84hjRWcIdCGdmaym9l0GfqyWlm8GhEHTpgaeNo1a7XaGcGsIJaGAbe6bv5MlC6CUvNfIg5sIO5smft6qYGy5sznlurzvUpQJZ1HcuNhSkxJUpW4)M20m1W5A3GQC1cAaJPbRYLyg0OGQ4Axel3aLlXmOrbvX1UU84hjRiwUGdETc6BAlTbkakjocaQfqOhuLBUWPZ5wDwiAKljIMlXmQNy5sznlurzvUpQJZ1HcuNhSkxJUpW4)M20m1W5kmOkxTGgWyAWQCjgfAysefgFTlILBGYLyuOHjruy81UU84hjRiwUGtyTc6BAtZudNR9bv5Qf0agtdwLlXOqdtIOW4RDrSCduUeJcnmjIcJV21Lh)izfXYfCWRvqFtBAMA4CTpOkxTGgWyAWQCjMbnkOkU2fXYnq5smdAuqvCTRlp(rYkILl4GxRG(M20m1W5cpOiOkxTGgWyAWQCjgfAysefgFTlILBGYLyuOHjruy81UU84hjRiwUGdETc6BAlTbkakjocaQfqOhuLBUWPZ5wDwiAKljIMlXoqLurSCPSMfQOSk3h1X56qbQZdwLRr3hy8FtBAMA4CTpOkxTGgWyAWQCjgfAysefgFTlILBGYLyuOHjruy81UU84hjRiwUEKRMM4RzYfCWRvqFtBPnqDNfIgSkxHwUUjk0KRS(4VPnmWBXgSacl0apgWIIiljJbeIqYL4dfshKCjoiyqCAticjxB(a5uX5kSDRrUcdEHHpTL2eIqYvtRv2afSk3dtIOCUgu3XJCpmSA(BUGsJHTIp3bn2RUt7iHK56MOqZNlAKIVPn3efA(RfLnOUJheCllP4MfQE0K2CtuO5Vwu2G6oEikbTpOiKSQrkDXScKAG1cKwRjT5MOqZFTOSb1D8qucA)b7YqpT5MOqZFTOSb1D8qucA35uryvJerBk2dDnSOSb1D8O9SbnQNGMOrrsG6LQXGXtCDL6V10NWAsAZnrHM)ArzdQ74HOe0MIKYwOZTdA4xdlkBqDhpApBqJ6jiSgfjbk35182X(Pn3efA(RfLnOUJhIsq7xwgU5JQPkdRHfLnOUJhTNnOr9eewJIKaLjP8R7hjN2sBcri5QP1kBGcwLldgtfNBuDCUHoNRBcen36Z1bZlPFK8nT5MOqZtqKYisAti5sC4pyxg65wK5AH(VosoxWnOCbdsom1psoxE4UI)CRjxdQ74bOtBUjk08Isq7pyxg6PnHKlXHPiPm3Vgyso3dej5Nl7uP4CrHotZn09jx4OqCUcYoTgy56JkxbPix9LItBUjk08IsqBWCA5hjRX4DmbACAuMIKsnaZLqmbACAhisY3octe46)arsEdke3oStRb2fYIO(pqKK3df5QVu8fYc0PnHKRMEEikNliCUW4ixsiPmxqz3b61ZvlcvUW8A(C9rLRt5HyrUuMIKYAGLRwqqtKBOZ5s8vQp3dej5NRdIloT5MOqZlkbTbZPLFKSgJ3Xe8Ud0R3mOrvrHgnaZLqmbdQ7GAwOAI)QyYYurFeew0dej59qrU6lfFHSiIhMctCFe0eWte463GgfufxdcAIwOZnKs996DGijVuKu2cDUDqd)xk35189raEWd60MqYvtvt9656rUDUwRoOUC1IqL7bkY1bdvQCbX)Ogy5kif5QVuCU(OYL4fQmIKRMtDqY9GgOpxdQ7GY1cvt8Pn3efAErjOnyoT8JK1y8oMazn1R3mOrvrHgnaZLqmbdQ7GAwOAIVpcgRwNR12BXJYEpqKK3df5QVu8fYYEb3bIK8ISSq0aAQq8fYI4E4sEIRMfQmI0uuhKlp(rYkq3RNb1DqnlunXtWNQZn6ofgRAgR0MqYfuOc9C7GKrzj5CdNcJJxJCd96ZfmNw(rY5wFUgD2icRYnq5QytP4CbrNdDMM7J64C1IM)5(6iiPk3dN7lEmSkxqQqpxbLUIZvtjHOuXPn3efAErjOnyoT8JK1y8oMWr6kUrkHOuXTx8y0amxcXeElwkBHtHXXFpsxXnsjeLk2octe1lvJbJN46k1FRPpHbFVEhisY7r6kUrkHOuXxiR0MBIcnVOe0Mcnn3efAAY6dngVJj8b7YqxJIKWhSldDwDDPmT5MOqZlkbTnUu2CtuOPjRp0y8oMGr9Pn3efAErjOnfAAUjk00K1hAmEhtGSM611OijaMtl)i5lzn1R3mOrvrHM0MBIcnVOe024szZnrHMMS(qJX7ychOsQsBUjk08IsqBNA8HBbIs5j0OijWdtHj(QyYYurFeGxteLhMct8LYW4jT5MOqZlkbTDQXhUzbjFoT5MOqZlkbTLfm94BexHuW64jsBUjk08Isq7JdRHiBbTmI8PT0MqesUccvsft)0MBIcn)9avsfHNT(6tBUjk083dujvIsqBy6OpKIBFqlr40MBIcn)9avsLOe0(1lW0OijqHgMerHX3OgXTaP1Y0osxXPn3efA(7bQKkrjOnB0r1aRrzlA15JkT5MOqZFpqLujkbTFMs9GvTdA42BvIWAyeBKClCkmoEcWRrrsOFfkUptPEWQ2bnC7Tkr4BugrQbwVEUjkW4gpCxXpb4jI6LQXGXtCDL6V10hjKu2OSr3PW4wuDCVEgDNcJ)(eMiYcME0OCNxZBhnjTjKCThpNRqvFGK5cOJICbPc9Cj(wwiAanvio3ImxTG6oEKRqHcEmIZfe0qSixeym14w5YdtHjwJCbrNNCRixqkPmxwRUjKIZ14w5QfHsJCr0CbrNNCH(AGLlXluzejxnN6GK2CtuO5VhOsQeLG2w1hiz71rHgfjHdej5fzzHOb0uH4lKfrGJhMct8vXKLPI(ahpmfM4lLHXJOWdEq3RNb1DqnlunXFvmzzQWoeGx0dej59qrU6lfFHS61lCjpXvZcvgrAkQdYLh)izfOtBUjk083dujvIsqBR6dKS96OqJIKWbIK8ISSq0aAQq8fYIiWDGijVWOmpVi18nqkJim9Vqw96DGijVg0yyxYQ2rcnkMEG()czb60MBIcn)9avsLOe0(RP(GPTpOLiCAZnrHM)EGkPsucAddbbJ1OijeUKN4QkAiUf0YiYF5XpswrKb1DqnlunXFvmzzQOpcWl6bIK8EOix9LIVqwPT0MqesUAbHKkeiZN2esUckDfNRMscrPIZfn5kSO5Yd3v8N2CtuO5Vg1t4iDf3iLquQynkscVflLTWPW447JGWe1)bIK8EKUIBKsikv8fYkTjKCThFnWYfu2DGE9CRpxpxHjUKBngk7pRrUpkxIB(uVEUgFY9W5(OooQo(Z9W5c9Skx)Z1ZfkkzfIZ9TyPmxOrY)Nl0xdSCf68pyAUGY)9)RjxenxnN9qxkoxaDxHa5tBUjk08xJ6fLG2G5t96AuKe6NcnmjIcJVDovKgISf6CRZ)GPn)F))AiQ)pyxg6S66sjrG50Yps(6DhOxVzqJQIcnebU(PqdtIOW4RI9qxkU96UcbY3R3bIK8Qyp0LIBVURqG8xfcKHidQ7GAwOAI3oeeg0Pn3efA(Rr9IsqBW8PEDnkscuOHjruy8TZPI0qKTqNBD(hmT5)7)xdrD(hmT5)7)xtJYDEnpbWteyoT8JKVhPR4gPeIsf3EXJHiW1VbHKkeiZ9WbimpTqNBSy(Vu2vIjcmNw(rYxYAQxVzqJQIcn96zqiPcbYCpCacZtl05glM)lLDLyIaZPLFK817oqVEZGgvffAanrGRFdAuqvCniOjAHo3qk13R3bIK8srszl052bn8FPCNxZ3hb4bpOtBUjk08xJ6fLG2KshglLEuOjT5MOqZFnQxucAtkDySu6rHMMrY(8SgfjbfFGijVKshglLEuO5s5oVM3ocN2CtuO5Vg1lkbTDfLhxwd3OqVUgfjH(pqKKxxr5XL1Wnk0RFHSicC9BqiPcbYCfPKYAG1ElkZxiRE96pCjpXvKskRbw7TOmF5Xpswb60MBIcn)1OErjOnfjLTqNBh0WVgfjHo)dM28)9)RPr5oVMNa4jcChisYlfjLTqNBh0W)LYDEnVDiy)E9aZPLFK8LgNgLPiPe0PnHKlOMmxxP(CDkNlKLg5(tzX5g6CUOHZfKk0ZvIaH)ix4GtZV5ApEoxq05jxL4AGLlP)btZn09jxTiu5QyYYurUiAUGuHockY1hX5QfH6M2CtuO5Vg1lkbT7CQiSQrIOnf7HUggXgj3cNcJJNa8AuKeOEPAmy8exxP(lKfrGlCkmoUr1XTa1ufBhdQ7GAwOAI)QyYYurVE9)b7YqNvxkcgetKb1DqnlunXFvmzzQOpcgRwNR12BXJYEHh0PnHKlOMm3bLRRuFUGuszUQIZfKk0Rj3qNZDyTg5AFW)AKl0Z5k0rQ55IMCpO)ZfKk0rqrU(ioxTiu30MBIcn)1OErjODNtfHvnseTPyp01Oijq9s1yW4jUUs93A6Z(G3EPEPAmy8exxP(RcI6rHgI6)d2LHoRUuemiMidQ7GAwOAI)QyYYurFemwToxRT3IhL9cFAZnrHM)AuVOe0wKskRbw7TOmRrrsamNw(rY3J0vCJucrPIBV4Xqe44HPWeFJQJBbQ15ATpH717TyPSfofghFFcd60MBIcn)1OErjO9r6kUrHEDnkscG50Yps(EKUIBKsikvC7fpgIahpmfM4BuDClqToxR9jCVEVflLTWPW447tyqN2CtuO5Vg1lkbTvu2vhPR4xJIKq)FWUm0z11LsImOUdQzHQjE7qa(0MBIcn)1OErjO9R7keiDSuPrrsO)pyxg6S66sjrG50Yps(6DhOxVzqJQIcnPn3efA(Rr9IsqBluuOrJIKWbIK8EKiKsc9XLYUj61JSGPhnk35182X(GVxVdej51vuECznCJc96xiR0MBIcn)1OErjO9rIqQgjevCAZnrHM)AuVOe0(W0NPIudS0MBIcn)1OErjOnzr5JeHuPn3efA(Rr9IsqBFm8hux2mUuM2esUAot6qYixdAuvuO5ZLerZf69JKZTcU7VPn3efA(Rr9IsqBONBvWDVgfjH(PqdtIOW4BNtfPHiBHo368pyAZ)3)VgIu8bIK8E4aeMNwOZnwm)xilIax)Hl5jUW0rFif3(GwIWxE8JKv96P4dej5fMo6dP42h0se(czb6E968pyAZ)3)VMgL78A((aFVEKfm9Or5oVM3oeeg8PT0MqesUAQAQxNPFAZnrHM)swt96eEzz4MpQMQmSgfjHdej59LLHB(OAQYWxk35182HSGPhnk3518erzsk)6(rYPnHKRGHMox0KRbHKkeitUbkxry2k3qNZvl0kYvXhisYCHSsBUjk08xYAQxxucAF4aeMNwOZnwm)Pn3efA(lzn1RlkbTv1B5HrpTL2eIqYfiyxg6Pn3efA(7hSldDcQ6T8WORrrsamNw(rYxYAQxVzqJQIcnPn3efA(7hSldDrjOT3DGE90MBIcn)9d2LHUOe02OZUv71rHggXgj3cNcJJNa8AuKecxYtCTOS4gAAHo3aHDrU84hjRiQ)WPW44wF7G(hh4aJba]] )

end