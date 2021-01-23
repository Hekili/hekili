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


    spec:RegisterPack( "Outlaw", 20210123, [[d4Ka1aqiPu9icIlbKKAtiKpHqzuaPofqLvHqL0RiKMfHYTOev7sL(fPuddOQJbQAzeupJsW0iuHRHqvBJqv8nkryCuIIZbKeRdirZJsO7HG9jLYbbsyHeOhskXejuvxKqfTrcvYhjivDseQyLusZKqv6MeKk7Ka(jbPmucsokcvQLcKupfWubvUkLiARiuj(kLO0yPeP9c1FLQbR0HPAXQ4XumzsUmQnJOpdkJMuDAjRgij51eIzt0TLIDR43qgoL64eQulhPNRQPlCDq2oq57aX4jL05jfZxkz)IgdpgomGYdglGWGxy4bp8cBHl8wclap4TmyGqJnJbSDJiomgdmEdJbeAqH0bbdy7AKixHHdd8iiQHXa6ry)GsT1gwf6qNRb1O9xnqspk0yOozO9xngTXahOsgeNbFWakpySacdEHHh8WlSfUWBje2YapXJbCOqhrXaavJwWa6LsXd(Gbu8BWacri5k0GcPdsUGAemioTkeHKRvFGCQMCf2cILRWGxy4XaY6JhdhgqXKoKmWWHfaEmCya3efAWaIugrWa84hjRWcIdSacJHddWJFKScligqXVHw2rHgmaOM)GDzONBrMRn6)6i5Cb9GYfmi5Wu)i5C5HBk(ZTMCnOMJhGdd4MOqdg4d2LHooWcybmCyaE8JKvybXaiBmWZbgWnrHgmayoT8JKXaG5sigdqJt)ars(5AXCfoxIYf052EUhisYBqH4(HDAnWUq25suUTN7bIK8EOix9LIVq25comGIFdTSJcnyaqntrszUFnWKCUhisYpx2Psn5IcDMMBO7tUWrH4CfKDAnWY1hvUcsrU6lfJbaZP9XBymanoDktrsjoWcioWWHb4XpswHfedGSXaphya3efAWaG50YpsgdaMlHymGb1CqDBunXFvmzzQi32iKRW5kAUhisY7HIC1xk(czNlr5YdtHPj32iKlXd(CjkxqNB75AqJcQIRbbnrp05osP(lp(rYQCB1k3dej5LIKYEOZ9dA4)s5gVMp32iKl8GpxWHbu8BOLDuObdioNhIY5ccNlmoYLeskZfu0CGE9C1IqLlmVMpxFu56uEiwKlLPiPSgy5Qfe0e5g6CUcnL6Z9ars(56G4AWaG50(4nmgWBoqVE3GgvffAWbwaIhdhgGh)izfwqmaYgd8CGbCtuObdaMtl)izmayUeIXaguZb1Tr1eFUTrixJDVX1A)T5rLRLN7bIK8EOix9LIVq25A55c6CpqKKxKTnIgqtfAUq25sCn3WL8exXnuzePROoixE8JKv5cUCB1kxdQ5G62OAIpxc56t14gDNcJvDJngqXVHw2rHgmG4QM61Z1JCBCTwnqn5QfHk3duKRdgQu5cI)rnWYvqkYvFP4C9rLlXnuzejxXN6GK7bnqFUguZbLRnQM4XaG50(4nmgGSM617g0OQOqdoWciEWWHb4XpswHfedGSXaphya3efAWaG50YpsgdaMlHymWBZszpCkmo(7r6kUtkHOun5AXCfoxIYL6LQZGXtCDL6V1KBB5km4ZTvRCpqKK3J0vCNucrPAUq2yaf)gAzhfAWaw2k0ZTbsgLTKZnCkmoEXYn0RpxWCA5hjNB95A0zJiSk3aLRInLIZfeDo0zAUpQHZvlI)N7RJGKQCpCUVMXWQCbPc9Cfu6koxXLeIs1GbaZP9XBymWr6kUtkHOun9xZyWbwalbgomap(rYkSGyadTcMwog4d2LHoRUUuIbCtuObdqHMUBIcnDz9bgqwF0hVHXaFWUm0Xbwaldgomap(rYkSGya3efAWagxk7Ujk00L1hyaz9rF8ggdyupoWcaQGHddWJFKScligWqRGPLJbaZPLFK8LSM617g0OQOqdgWnrHgmafA6Ujk00L1hyaz9rF8ggdqwt964ala8GhdhgGh)izfwqmGBIcnyaJlLD3efA6Y6dmGS(OpEdJboqLuHdSaWdpgomap(rYkSGyadTcMwogGhMctZvXKLPICBJqUWt85kAU8WuyAUuggpya3efAWao14d3deLYtGdSaWlmgomGBIcnyaNA8H72qYNXa84hjRWcIdSaWBbmCya3efAWaYcME8Dqvqkyn8eyaE8JKvybXbwa4fhy4WaUjk0GbooSoISh0YiYJb4XpswHfeh4adytzdQ54bgoSaWJHdd4MOqdgWTTLA62O6rdgGh)izfwqCGfqymCya3efAWahuesw1jLUgwbsnW6bsR1Gb4XpswHfehybSagomGBIcnyGpyxg6yaE8JKvybXbwaXbgomap(rYkSGya3efAWanovew1jr0UI9qhdyOvW0YXauVuDgmEIRRu)TMCBlxHjEmGnLnOMJh9NnOr9yaIhhybiEmCyaE8JKvybXaUjk0GbOiPSh6C)Gg(XagAfmTCmaLB8A(CTyUwadytzdQ54r)zdAupgqyCGfq8GHddWJFKScligWnrHgmWlld39r1vLHXagAfmTCmaLjP8R7hjJbSPSb1C8O)SbnQhdimoWbgGSM61XWHfaEmCyaE8JKvybXagAfmTCmWbIK8(YYWDFuDvz4lLB8A(CTyUKfm9Ot5gVMpxIYLYKu(19JKXaUjk0GbEzz4UpQUQmmoWcimgomap(rYkSGyaf)gAzhfAWacgIZCrtUgesQqGm5gOCfHz7CdDoxTqRixfFGijZfYgd4MOqdg4Wbimp9qN7Sg(XbwalGHdd4MOqdgqvVThgDmap(rYkSG4ahyaJ6XWHfaEmCyaE8JKvybXaUjk0GbosxXDsjeLQbdO43ql7OqdgqqPR4CfxsikvtUOjxHfnxE4MIFmGHwbtlhd82Su2dNcJJp32iKRW5suUTN7bIK8EKUI7KsikvZfYghybegdhgGh)izfwqmGBIcnyaW8PEDmGIFdTSJcnyal5xdSCbfnhOxp36Z1Zvyq15wJHY(ZIL7JYL4Ip1RNRXNCpCUpQHJQH)CpCUqpRY1)C9CHIswHMCFBwkZfAK8)5c91alxHo)dMMlO4F))AYfrZv8zp0LAYfq3viqEmGHwbtlhd0EUuOHjruy8TXPI0rK9qN7n(hmT7)7)xZLh)izvUeLB75(b7YqNvxxkZLOCbZPLFK81BoqVE3GgvffAYLOCbDUTNlfAysefgFvSh6sn9x3viq(lp(rYQCB1k3dej5vXEOl10FDxHa5VkeitUeLRb1CqDBunXNRfjKRW5coCGfWcy4Wa84hjRWcIbm0kyA5yak0WKikm(24ur6iYEOZ9g)dM29)9)R5YJFKSkxIYTX)GPD)F))A6uUXR5ZLqUGpxIYf052EUgesQqGm3dhGW80dDUZA4)szxPjxIYfmNw(rYxYAQxVBqJQIcn52QvUgesQqGm3dhGW80dDUZA4)szxPjxIYfmNw(rYxV5a96DdAuvuOjxWLlr5c6CBpxdAuqvCniOj6Ho3rk1F5XpswLBRw5EGijVuKu2dDUFqd)xk341852gHCHh85comGBIcnyaW8PEDCGfqCGHdd4MOqdgGu6WyP0JcnyaE8JKvybXbwaIhdhgGh)izfwqmGHwbtlhdO4dej5Lu6WyP0Jcnxk34185AXCfgd4MOqdgGu6WyP0JcnDJK95zCGfq8GHddWJFKScligWqRGPLJbAp3dej51vuECznCNc96xi7CjkxqNB75AqiPcbYCfPKYAG1FBkZxi7CB1k32ZnCjpXvKskRbw)TPmF5XpswLl4WaUjk0GbCfLhxwd3PqVooWcyjWWHb4XpswHfedyOvW0YXan(hmT7)7)xtNYnEnFUeYf85suUGo3dej5LIKYEOZ9dA4)s5gVMpxlsixlKBRw5cMtl)i5lnoDktrszUGdd4MOqdgGIKYEOZ9dA4hhybSmy4Wa84hjRWcIbCtuObd04uryvNer7k2dDmGrJrY9WPW44XcapgWqRGPLJbOEP6my8exxP(lKDUeLlOZnCkmoUr1W9a1vfNRfZ1GAoOUnQM4VkMSmvKBRw52EUFWUm0z1LIGbX5suUguZb1Tr1e)vXKLPICBJqUg7EJR1(BZJkxlpx4ZfCyaf)gAzhfAWaehYCDL6Z1PCUq2IL7pLnNBOZ5IgoxqQqpxjce(JCHdoX)MRL85CbrNNCvAQbwUK(hmn3q3NC1IqLRIjltf5IO5csf6iOixF0KRweQloWcaQGHddWJFKScligWnrHgmqJtfHvDseTRyp0Xak(n0Yok0GbioK5oOCDL6ZfKskZvvCUGuHEn5g6CUdR1ixla(xSCHEoxHosXpx0K7b9FUGuHockY1hn5QfH6Ibm0kyA5yaQxQodgpX1vQ)wtUTLRfaFUwEUuVuDgmEIRRu)vbr9OqtUeLB75(b7YqNvxkcgeNlr5Aqnhu3gvt8xftwMkYTnc5AS7nUw7VnpQCT8CHhhybGh8y4Wa84hjRWcIbm0kyA5yaWCA5hjFpsxXDsjeLQP)AgtUeLlOZLhMctZnQgUhOEJR1CBlxHZTvRCFBwk7HtHXXNBB5kCUGdd4MOqdgqKskRbw)TPmJdSaWdpgomap(rYkSGyadTcMwogamNw(rY3J0vCNucrPA6VMXKlr5c6C5HPW0CJQH7bQ34An32Yv4CB1k33MLYE4uyC852wUcNl4WaUjk0GbosxXDk0RJdSaWlmgomap(rYkSGyadTcMwogO9C)GDzOZQRlL5suUguZb1Tr1eFUwKqUWJbCtuObdOOSRosxXpoWcaVfWWHb4XpswHfedyOvW0YXaTN7hSldDwDDPmxIYfmNw(rYxV5a96DdAuvuObd4MOqdg41DfcKgwQWbwa4fhy4Wa84hjRWcIbm0kyA5yGdej59iriLe6JlLDtKBRw5swW0JoLB8A(CTyUwa852QvUhisYRRO84YA4of61Vq2ya3efAWa2OOqdoWcapXJHdd4MOqdg4irivNeIQbdWJFKSclioWcaV4bdhgWnrHgmWHPptfPgyyaE8JKvybXbwa4Tey4WaUjk0GbilkFKiKcdWJFKSclioWcaVLbdhgWnrHgmGpg(dQl7gxkXa84hjRWcIdSaWdQGHddWJFKScligWnrHgma0Z9k4MhdO43ql7Oqdgq8zshsg5AqJQIcnFUKiAUqVFKCUvWn)fdyOvW0YXaTNlfAysefgFBCQiDezp05EJ)bt7()()1C5XpswLlr5Q4dej59Wbimp9qN7Sg(Vq25suUGo32ZnCjpXfMo6dPM(h0se(YJFKSk3wTYvXhisYlmD0hsn9pOLi8fYoxWLBRw524FW0U)V)FnDk341852wUGp3wTYLSGPhDk34185Arc5km4XboWaFWUm0XWHfaEmCyaE8JKvybXagAfmTCmayoT8JKVK1uVE3GgvffAWaUjk0Gbu1B7HrhhybegdhgWnrHgmG3CGEDmap(rYkSG4alGfWWHb4XpswHfed4MOqdgWOZUD)1rbgWqRGPLJbcxYtCTPSMoA6Ho3bHDrU84hjRYLOCBp3WPW44wF)G(hdy0yKCpCkmoESaWJdCGboqLuHHdla8y4WaUjk0GbE2(RhdWJFKSclioWcimgomGBIcnyay6OpKA6Fqlrymap(rYkSG4alGfWWHb4XpswHfedyOvW0YXauOHjruy8nQrtpqATm9J0v8Lh)izfgWnrHgmWRxGHdSaIdmCya3efAWaSrhvdSoLTPvJpkmap(rYkSG4alaXJHddWJFKScligWnrHgmWZuQhSQFqd3F7segdyOvW0YXaTNRcf3NPupyv)GgU)2Li8nkJi1al3wTY1nrbg35HBk(ZLqUWNlr5s9s1zW4jUUs93AYTTCjHKYoLn6ofg3JQHZTvRCn6ofg)52wUcNlr5swW0JoLB8A(CTyUepgWOXi5E4uyC8ybGhhybepy4Wa84hjRWcIbCtuObdyxFGK9xhfyaf)gAzhfAWawYNZvOQpqYCb0rrUGuHEUcnBBenGMk0KBrMRwqnhpYvOqbpgn5ccAiwKlcmMAC7C5HPW0iwUGOZtUvKliLuMlRv3esn5AC7C1IqjwUiAUGOZtUqFnWYL4gQmIKR4tDqWagAfmTCmWbIK8ISTr0aAQqZfYoxIYf05YdtHP5QyYYurUTLlOZLhMctZLYW4jxrZfEWNl4YTvRCnOMdQBJQj(RIjltf5Arc5cFUIM7bIK8EOix9LIVq252QvUHl5jUIBOYisxrDqU84hjRYfC4alGLadhgGh)izfwqmGHwbtlhdCGijViBBenGMk0CHSZLOCbDUhisYlmkZZlsnFhKYict)lKDUTAL7bIK8AqJHDjR6hj0Oy6b6)lKDUGdd4MOqdgWU(aj7VokWbwaldgomGBIcnyGVM6dM2)GwIWyaE8JKvybXbwaqfmCyaE8JKvybXagAfmTCmq4sEIRQOHMEqlJi)Lh)izvUeLRb1CqDBunXFvmzzQi32iKl85kAUhisY7HIC1xk(czJbCtuObdadbbJXboWbgamM(fAWcim4fgEWdVWWJbaXPtnWEmGLfuaQfG4iGqpOm3CHtNZTASr0ixsenxIPyshsgelxklUHkkRY9rnCUouGA8Gv5A09bg)30Q4TgoxXbOmxTGgWyAWQCjMbnkOkUwkXYnq5smdAuqvCT0lp(rYkILlOHxRG7MwtRwwqbOwaIJac9GYCZfoDo3QXgrJCjr0CjMr9elxklUHkkRY9rnCUouGA8Gv5A09bg)30Q4TgoxHbL5Qf0agtdwLlXOqdtIOW4RLsSCduUeJcnmjIcJVw6Lh)izfXYf0cRvWDtRI3A4CTaOmxTGgWyAWQCjgfAysefgFTuILBGYLyuOHjruy81sV84hjRiwUGgETcUBAv8wdNRfaL5Qf0agtdwLlXmOrbvX1sjwUbkxIzqJcQIRLE5XpswrSCbn8AfC30Q4Tgox4bvaL5Qf0agtdwLlXOqdtIOW4RLsSCduUeJcnmjIcJVw6Lh)izfXYf0WRvWDtRPvllOaulaXraHEqzU5cNoNB1yJOrUKiAUe7avsfXYLYIBOIYQCFudNRdfOgpyvUgDFGX)nTkERHZ1cGYC1cAaJPbRYLyuOHjruy81sjwUbkxIrHgMerHXxl9YJFKSIy56rUItHM4nxqdVwb3nTMwjon2iAWQCfp56MOqtUY6J)MwXa2uezjzmGqesUcnOq6GKlOgbdItRcri5A1hiNQjxHTGy5km4fg(0AAvicjxXPwzduWQCpmjIY5AqnhpY9WWQ5V5ckmg2o(Ch0y56oTHesMRBIcnFUOrQ5MwDtuO5V2u2GAoEqWTTLA62O6rtA1nrHM)AtzdQ54HOe0(GIqYQoP01WkqQbwpqATM0QBIcn)1MYguZXdrjO9hSld90QBIcn)1MYguZXdrjODJtfHvDseTRyp0fZMYguZXJ(Zg0OEceVyfjbQxQodgpX1vQ)wtBct8Pv3efA(RnLnOMJhIsqBksk7Ho3pOHFXSPSb1C8O)SbnQNGWIvKeOCJxZBrlKwDtuO5V2u2GAoEikbTFzz4UpQUQmSy2u2GAoE0F2Gg1tqyXkscuMKYVUFKCAnTkeHKR4uRSbkyvUmymvtUr1W5g6CUUjq0CRpxhmVK(rY30QBIcnpbrkJiPvHKlOM)GDzONBrMRn6)6i5Cb9GYfmi5Wu)i5C5HBk(ZTMCnOMJhGlT6MOqZlkbT)GDzONwfsUGAMIKYC)AGj5CpqKKFUStLAYff6mn3q3NCHJcX5ki70AGLRpQCfKIC1xkoT6MOqZlkbTbZPLFKSyJ3WeOXPtzkskfdmxcXeOXPFGijFlkmrGU9dej5nOqC)WoTgyxiBIA)arsEpuKR(sXxiBWLwfsUIZ5HOCUGW5cJJCjHKYCbfnhOxpxTiu5cZR5Z1hvUoLhIf5szkskRbwUAbbnrUHoNRqtP(CpqKKFUoiUM0QBIcnVOe0gmNw(rYInEdtWBoqVE3GgvffAedmxcXemOMdQBJQj(RIjltfTrqyrpqKK3df5QVu8fYMiEykmnTrG4bprGUDdAuqvCniOj6Ho3rk13Q1bIK8srszp05(bn8FPCJxZ3gb4bp4sRcjxXvn1RNRh524ATAGAYvlcvUhOixhmuPYfe)JAGLRGuKR(sX56JkxIBOYisUIp1bj3dAG(CnOMdkxBunXNwDtuO5fLG2G50YpswSXBycK1uVE3GgvffAedmxcXemOMdQBJQj(2iyS7nUw7Vnpkl)arsEpuKR(sXxiBlh0hisYlY2grdOPcnxiBIRHl5jUIBOYisxrDqU84hjRaxRwguZb1Tr1epbFQg3O7uySQBStRcjxlBf652ajJYwY5gofghVy5g61NlyoT8JKZT(Cn6SrewLBGYvXMsX5cIoh6mn3h1W5QfX)Z91rqsvUho3xZyyvUGuHEUckDfNR4scrPAsRUjk08IsqBWCA5hjl24nmHJ0vCNucrPA6VMXigyUeIj82Su2dNcJJ)EKUI7KsikvJffMiQxQodgpX1vQ)wtBcd(wToqKK3J0vCNucrPAUq2Pv3efAErjOnfA6Ujk00L1hInEdt4d2LHUyfjHpyxg6S66szA1nrHMxucABCPS7MOqtxwFi24nmbJ6tRUjk08IsqBk00DtuOPlRpeB8gMazn1RlwrsamNw(rYxYAQxVBqJQIcnPv3efAErjOTXLYUBIcnDz9HyJ3WeoqLuLwDtuO5fLG2o14d3deLYtiwrsGhMctZvXKLPI2iapXlkpmfMMlLHXtA1nrHMxucA7uJpC3gs(CA1nrHMxucAlly6X3bvbPG1WtKwDtuO5fLG2hhwhr2dAze5tRPvHiKCfeQKkM(Pv3efA(7bQKkcpB)1NwDtuO5VhOsQeLG2W0rFi10)GwIWPv3efA(7bQKkrjO9RxGjwrsGcnmjIcJVrnA6bsRLPFKUItRUjk083dujvIsqB2OJQbwNY20QXhvA1nrHM)EGkPsucA)mL6bR6h0W93UeHfZOXi5E4uyC8eGxSIKq7kuCFMs9Gv9dA4(BxIW3OmIudSwTCtuGXDE4MIFcWte1lvNbJN46k1FRPnsiPStzJUtHX9OA4wTm6ofg)TjmrKfm9Ot5gVM3IeFAvi5AjFoxHQ(ajZfqhf5csf65k0STr0aAQqtUfzUAb1C8ixHcf8y0KliOHyrUiWyQXTZLhMctJy5cIop5wrUGuszUSwDti1KRXTZvlcLy5IO5cIop5c91alxIBOYisUIp1bjT6MOqZFpqLujkbTTRpqY(RJcXkschisYlY2grdOPcnxiBIanpmfMMRIjltfTbAEykmnxkdJhrHh8GRvldQ5G62OAI)QyYYuHfjaVOhisY7HIC1xk(cz3Qv4sEIR4gQmI0vuhKlp(rYkWLwDtuO5VhOsQeLG221hiz)1rHyfjHdej5fzBJOb0uHMlKnrG(arsEHrzEErQ57Gugry6FHSB16arsEnOXWUKv9JeAum9a9)fYgCPv3efA(7bQKkrjO9xt9bt7Fqlr40QBIcn)9avsLOe0ggccglwrsiCjpXvv0qtpOLrK)YJFKSIidQ5G62OAI)QyYYurBeGx0dej59qrU6lfFHStRPvHiKC1ccjviqMpTkKCfu6koxXLeIs1KlAYvyrZLhUP4pT6MOqZFnQNWr6kUtkHOunIvKeEBwk7HtHXX3gbHjQ9dej59iDf3jLquQMlKDAvi5Aj)AGLlOO5a965wFUEUcdQo3Amu2FwSCFuUex8PE9Cn(K7HZ9rnCun8N7HZf6zvU(NRNluuYk0K7BZszUqJK)pxOVgy5k05FW0Cbf)7)xtUiAUIp7HUutUa6UcbYNwDtuO5Vg1lkbTbZN61fRij0ofAysefgFBCQiDezp05EJ)bt7()()1qu7FWUm0z11LsIaZPLFK81BoqVE3GgvffAic0TtHgMerHXxf7HUut)1DfcKVvRdej5vXEOl10FDxHa5VkeidrguZb1Tr1eVfjim4sRUjk08xJ6fLG2G5t96IvKeOqdtIOW4BJtfPJi7Ho3B8pyA3)3)VgIA8pyA3)3)VMoLB8AEcGNiq3UbHKkeiZ9Wbimp9qN7Sg(Vu2vAicmNw(rYxYAQxVBqJQIcnTAzqiPcbYCpCacZtp05oRH)lLDLgIaZPLFK81BoqVE3GgvffAahrGUDdAuqvCniOj6Ho3rk13Q1bIK8srszp05(bn8FPCJxZ3gb4bp4sRUjk08xJ6fLG2KshglLEuOjT6MOqZFnQxucAtkDySu6rHMUrY(8SyfjbfFGijVKshglLEuO5s5gVM3IcNwDtuO5Vg1lkbTDfLhxwd3PqVUyfjH2pqKKxxr5XL1WDk0RFHSjc0TBqiPcbYCfPKYAG1FBkZxi7wTApCjpXvKskRbw)TPmF5XpswbU0QBIcn)1OErjOnfjL9qN7h0WVyfjHg)dM29)9)RPt5gVMNa4jc0hisYlfjL9qN7h0W)LYnEnVfjyHwTaZPLFK8LgNoLPiPeCPvHKlXHmxxP(CDkNlKTy5(tzZ5g6CUOHZfKk0ZvIaH)ix4Gt8V5AjFoxq05jxLMAGLlP)btZn09jxTiu5QyYYurUiAUGuHockY1hn5QfH6MwDtuO5Vg1lkbTBCQiSQtIODf7HUygngj3dNcJJNa8IvKeOEP6my8exxP(lKnrGoCkmoUr1W9a1vfBrdQ5G62OAI)QyYYurRwT)b7YqNvxkcgetKb1CqDBunXFvmzzQOncg7EJR1(BZJYYHhCPvHKlXHm3bLRRuFUGuszUQIZfKk0Rj3qNZDyTg5AbW)ILl0Z5k0rk(5IMCpO)ZfKk0rqrU(OjxTiu30QBIcn)1OErjODJtfHvDseTRyp0fRijq9s1zW4jUUs93AAZcG3YPEP6my8exxP(RcI6rHgIA)d2LHoRUuemiMidQ5G62OAI)QyYYurBem29gxR93MhLLdFA1nrHM)AuVOe0wKskRbw)TPmlwrsamNw(rY3J0vCNucrPA6VMXqeO5HPW0CJQH7bQ34ATnHB16TzPShofghFBcdU0QBIcn)1OErjO9r6kUtHEDXkscG50Yps(EKUI7Ksikvt)1mgIanpmfMMBunCpq9gxRTjCRwVnlL9WPW44BtyWLwDtuO5Vg1lkbTvu2vhPR4xSIKq7FWUm0z11LsImOMdQBJQjElsa(0QBIcn)1OErjO9R7keinSujwrsO9pyxg6S66sjrG50Yps(6nhOxVBqJQIcnPv3efA(Rr9IsqBBuuOrSIKWbIK8EKiKsc9XLYUjA1ISGPhDk3418w0cGVvRdej51vuECznCNc96xi70QBIcn)1OErjO9rIqQojevtA1nrHM)AuVOe0(W0NPIudS0QBIcn)1OErjOnzr5JeHuPv3efA(Rr9IsqBFm8hux2nUuMwfsUIpt6qYixdAuvuO5ZLerZf69JKZTcU5VPv3efA(Rr9IsqBON7vWnVyfjH2PqdtIOW4BJtfPJi7Ho3B8pyA3)3)VgIu8bIK8E4aeMNEOZDwd)xiBIaD7Hl5jUW0rFi10)GwIWxE8JKvTAP4dej5fMo6dPM(h0se(czdUwTA8pyA3)3)VMoLB8A(2aFRwKfm9Ot5gVM3Ieeg8P10QqesUIRAQxNPFA1nrHM)swt96eEzz4UpQUQmSyfjHdej59LLH7(O6QYWxk3418wKSGPhDk3418erzsk)6(rYPvHKRGH4mx0KRbHKkeitUbkxry2o3qNZvl0kYvXhisYCHStRUjk08xYAQxxucAF4aeMNEOZDwd)Pv3efA(lzn1RlkbTv1B7HrpTMwfIqYfiyxg6Pv3efA(7hSldDcQ6T9WOlwrsamNw(rYxYAQxVBqJQIcnPv3efA(7hSldDrjOT3CGE90QBIcn)9d2LHUOe02OZUD)1rHygngj3dNcJJNa8IvKecxYtCTPSMoA6Ho3bHDrU84hjRiQ9WPW44wF)G(hd82SblGWIhWJdCGX]] )

end