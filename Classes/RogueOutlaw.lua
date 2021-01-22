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


    spec:RegisterPack( "Outlaw", 20210121, [[d4uaSaqivcpIsrxsuHKnraFIsHrbL4uqjTkrLeVck1SiKULOc2Lu9lcXWGcoMkPLbqpturttuP6AqHABei6BekQXjQeoNOcX6GcX8iqDpvQ9rP0bjqyHqrpuLOMibsUOOc1gfvk9rcfYjjuWkPqZuuj6MIkPSta8tcfzOQePJkQK0sHcPNQIPkQ6QekuBvuHuFvuPySQeXEv1FfzWqomvlwkpMutMKlJAZq1Nb0OPKtlz1IkP61euZMOBlk7wPFJy4u0XjqQLJ0ZbnDHRd02jiFNq14ju68uW8PuTFf)x)8)r5b)aaiga8kgUc41oGyaWCpNx)tyWK)JPRf2bY)z9m(pIjWq6I)ht3GK4Qp)FGeqQM)JveMqmIiIaSclWwxtYebwzGspkYQPoEicSY0I8NgyjdXW(T)O8GFaaedaEfdxb8AhqmayUdOy(poyyrO)5uzx(pwLsX73(JIH6)yZbjMadPl(GWOeGG8y0MdYOVGo1WGa8QOdcqma41)ilya)8)rX4oOm(8pax)8)X1rr2)iCPf(p86njREm)4baWp)FCDuK9pWGDzy9hE9MKvpMF8aKZp)F41Bsw9y(hI5FGC8hxhfz)JqoT8MK)JqUeK)dnAPgiooCqcEqaoibgewg0fdQbIJ3dkiNAStRfyh0CqcmOlgudehV3Oexblf3bnhew)JqonTEg)hA0suMsKYpEaY9p)F41Bsw9y(hI5FGC8hxhfz)JqoT8MK)JqUeK)JMK1ijtsTbSRy8sxXGS9EqaoiShudehV3Oexblf3bnhKadIxMc0WGS9EqymggKadcld6IbPjRcSIUMaUrkS4erPGDE9MKvdYU9b1aXX7uIuMclo1ild7uoZRfoiBVh0vmmiS(hHCAA9m(pEwdeAL0Kvvrr2pEaW4p)F41Bsw9y(hI5FGC8hxhfz)JqoT8MK)JqUeK)d0KLYu4uGCa7nPR4eUeKsnmibpiahKadI6LkXcXB0DLc2RDq2oiaXWGSBFqnqC8Et6koHlbPudDqZ)iKttRNX)PjDfNWLGuQHe0WQ)4bqq(5)dVEtYQhZ)OPvW0Y)dmyxgwSQ7s5FCDuK9puWn56OiBswW4pYcgP1Z4)ad2LH1hpaI5p)F41Bsw9y(hxhfz)J2LYKRJISjzbJ)ilyKwpJ)Jwb)4bix85)dVEtYQhZ)OPvW0Y)JMK1ijtsTbCq2EpiTzkZfBcAYRAq5WGAG449gL4kyP4oO5GYHbHLb1aXX7ettcna3km0bnhuUYGcxYB0f0GLw4KI6I351BswniSoi72hKMK1ijtsTbCq3dY3kZ1wofiRsAZ)46Oi7FOGBY1rr2KSGXFKfmsRNX)bV2cA9XdqoYN)p86njREm)JRJIS)r7szY1rr2KSGXFKfmsRNX)Pbws1hpaxXWN)p86njREm)JMwbtl)p8YuGg6kgV0vmiBVh0vmEqypiEzkqdDkdK3)46Oi7FCQ2xofekL34JhGRx)8)X1rr2)4uTVCYeuc5)WR3KS6X8JhGRa(5)JRJIS)rwaTcykxhubmJ34p86njREm)4b4Ao)8)X1rr2)0CGjcEkOLwy4F41Bsw9y(Xh)XKYAswZJp)dW1p)FCDuK9pUPP0qYKuqY(hE9MKvpMF8aa4N)pUokY(NgjcjRs4s3aReVwGPGi2A)dVEtYQhZpEaY5N)pUokY(hyWUmS(dVEtYQhZpEaY9p)F41Bsw9y(hxhfz)tMtfMvjCcnPypS(JMwbtl)puVujwiEJURuWETdY2bbig)htkRjznpsqwtwf8py8hpay8N)p86njREm)JRJIS)HsKYuyXPgzz4F00kyA5)HYzETWbj4bLZ)ysznjR5rcYAYQG)bWpEaeKF()WR3KS6X8pUokY(hOS0CYxvsvA(pAAfmT8)qzCkdT8MK)JjL1KSMhjiRjRc(ha)4J)GxBbT(8pax)8)HxVjz1J5F00kyA5)PbIJ3HYsZjFvjvP5oLZ8AHdsWdcVaAfjkN51chKadIY4ugA5nj)hxhfz)duwAo5RkPkn)XdaGF()46Oi7FACioZBkS4eBGH)HxVjz1J5hpa58Z)hxhfz)JQGMEOT(dVEtYQhZp(4pAf8Z)aC9Z)hE9MKvpM)rtRGPL)hOjlLPWPa5aoiBVheGdsGbDXGAG449M0vCcxcsPg6GM)X1rr2)0KUIt4sqk1Whpaa(5)dVEtYQhZ)OPvW0Y)ZfdcgSldlw1DPCqcmiHCA5nj39Sgi0kPjRQIISdsGbL5WGPjhcDiS2eLZ8AHd6EqyyqcmiSmOlgefCzCcfi3vShwsdjOLRiId786njRgKD7dQbIJ3vShwsdjOLRiId7kI47GeyqAswJKmj1gWbj47bb4GW6FCDuK9pc5BbT(4biNF()46Oi7FWLoqwk9Oi7F41Bsw9y(XdqU)5)dVEtYQhZ)OPvW0Y)JIBG44DCPdKLspkY2PCMxlCqcEqa(hxhfz)dU0bYsPhfztAj7lK)4baJ)8)HxVjz1J5F00kyA5)5Ib1aXX7UIYRlRLtuqOvh0CqcmiSmOlgKMqKkI4Bx4skRfycAszUdAoi72h0fdkCjVrx4skRfycAszUZR3KSAqy9pUokY(hxr51L1Yjki06Jhab5N)p86njREm)JMwbtl)pnqC8oLiLPWItnYYWoLZ8AHdsW3dkNdYU9bjKtlVj5onAjktjs5FCDuK9puIuMclo1ild)4bqm)5)dVEtYQhZ)46Oi7FYCQWSkHtOjf7H1F00kyA5)H6LkXcXB0DLc2bnhKadcldkCkqo6rLXPGKufpibpinjRrsMKAdyxX4LUIbz3(GUyqWGDzyXQoLaeKhKadstYAKKjP2a2vmEPRyq2EpiTzkZfBcAYRAq5WGUoiS(hTbTKtHtbYb8b46hpa5Ip)F41Bsw9y(hnTcMw(FOEPsSq8gDxPG9AhKTdkNyyq5WGOEPsSq8gDxPGDfi1JISdsGbDXGGb7YWIvDkbiipibgKMK1ijtsTbSRy8sxXGS9EqAZuMl2e0Kx1GYHbD9pUokY(NmNkmRs4eAsXEy9XdqoYN)p86njREm)JMwbtl)pc50YBsU3KUIt4sqk1qcAy1dsGbHLbXltbAOhvgNcskZf7GSDqaoi72he0KLYu4uGCahKTdcWbH1)46Oi7FeUKYAbMGMuM)4b4kg(8)HxVjz1J5F00kyA5)riNwEtY9M0vCcxcsPgsqdREqcmiSmiEzkqd9OY4uqszUyhKTdcWbz3(GGMSuMcNcKd4GSDqaoiS(hxhfz)tt6korbHwF8aC96N)p86njREm)JMwbtl)pxmiyWUmSyv3LYbjWG0KSgjzsQnGdsW3d66FCDuK9pkk7QM0vm8JhGRa(5)dVEtYQhZ)OPvW0Y)ZfdcgSldlw1DPCqcmiHCA5nj39Sgi0kPjRQIIS)X1rr2)aTCfr8mwQ(4b4Ao)8)HxVjz1J5F00kyA5)PbIJ3BscrjbHrNYUogKD7dcVaAfjkN51chKGhuoXWGSBFqnqC8URO86YA5efeA1bn)JRJIS)XKefz)4b4AU)5)JRJIS)PjjevchKA4p86njREm)4b4kg)5)JRJIS)PXuitfUwG)HxVjz1J5hpaxfKF()46Oi7FWlk3KeI6p86njREm)4b4Qy(Z)hxhfz)JVAgguxM0Uu(hE9MKvpMF8aCnx85)dVEtYQhZ)OPvW0Y)ZfdIcUmoHcK7zov4ebpfwCkZHbttoe6qyTDE9MKvdsGbP4gioEVXH4mVPWItSbg2bnhKadcld6IbfUK3Od0IadPHemOLWCNxVjz1GSBFqkUbIJ3bArGH0qcg0syUdAoiSoi72huMddMMCi0HWAtuoZRfoiBheggKD7dcVaAfjkN51chKGVheGy4pUokY(hqiNQGZGF8XFGb7YW6Z)aC9Z)hE9MKvpM)rtRGPL)hnjRrsMKAd4GS9EqAZuMl2e0Kx1FCDuK9pQcA6H26Jhaa)8)X1rr2)4znqO1F41Bsw9y(Xdqo)8)HxVjz1J5FCDuK9pAl2ntqls8hnTcMw(FcxYB0nPSHeztHfNeNDH786njRgKad6Ibfofih9cMAei8pAdAjNcNcKd4dW1p(4pnWsQ(8pax)8)X1rr2)aztyb)dVEtYQhZpEaa8Z)hxhfz)dqlcmKgsWGwcZ)HxVjz1J5hpa58Z)hE9MKvpM)rtRGPL)hk4Y4ekqUh1AifeXw6ut6kUZR3KS6pUokY(hOvj0hpa5(N)pUokY(hwBrQfyIYM0kZx1F41Bsw9y(Xdag)5)dVEtYQhZ)46Oi7FGmL6bRsnYYjOzjm)hnTcMw(FUyqks0HmL6bRsnYYjOzjm3JslCTahKD7dY1rjeN4LZkgoO7bDDqcmiQxQeleVr3vkyV2bz7GWbLYeL1wofiNIkJhKD7dsB5uGmCq2oiahKadcVaAfjkN51chKGheg)hTbTKtHtbYb8b46hpacYp)F41Bsw9y(hnTcMw(FAG44DIPjHgGBfg6GMdsGbHLbXltbAORy8sxXGSDqyzq8YuGg6ugiVdc7bDfddcRdYU9bPjznsYKuBa7kgV0vmibFpORdc7b1aXX7nkXvWsXDqZbz3(GcxYB0f0GLw4KI6I351BswniS(hxhfz)JzbdImbTiXhpaI5p)F41Bsw9y(hnTcMw(FAG44DIPjHgGBfg6GMdsGbHLb1aXX7aPmVqHRfMeV0cZuyh0Cq2TpOgioExtwn7swLAsWvX0gie2bnhew)JRJIS)XSGbrMGwK4JhGCXN)pUokY(hyTfmyAcg0sy(p86njREm)4bih5Z)hE9MKvpM)rtRGPL)NWL8gDvrddPGwAHHDE9MKvdsGbPjznsYKuBa7kgV0vmiBVh01bH9GAG449gL4kyP4oO5FCDuK9pajGa5p(4J)ietHfzFaaedaEfdxVkM)J4oDRfi8p5gbbgfaXaaIryKbnO8w8GQmtcngeoHoiBOyChug2yquwqdwuwniijJhKdgKmpy1G0w(cKH9XyUSwEq5ogzqxMScX0GvdYgAYQaROFj2yqbzq2qtwfyf9lPZR3KSYgdclxflw7JXXyUrqGrbqmaGyegzqdkVfpOkZKqJbHtOdYgAf0gdIYcAWIYQbbjz8GCWGK5bRgK2YxGmSpgZL1YdcqmYGUmzfIPbRgKnOGlJtOa5(LyJbfKbzdk4Y4ekqUFjDE9MKv2yqy5QyXAFmMlRLh01CbgzqxMScX0GvdYguWLXjuGC)sSXGcYGSbfCzCcfi3VKoVEtYkBmiSCvSyTpghJ5gbbgfaXaaIryKbnO8w8GQmtcngeoHoiB0alPYgdIYcAWIYQbbjz8GCWGK5bRgK2YxGmSpgZL1YdkNyKbDzYketdwniBqbxgNqbY9lXgdkidYguWLXjuGC)s686njRSXG8yq5yXuUCqy5QyXAFmogfdzMeAWQbjihKRJISdswWa2hJ)XKsWlj)hBoiXeyiDXhegLaeKhJ2Cqg9f0PggeGxfDqaIbaVoghJ2Cq5yXYAWGvdQX4ekpinjR5XGAmWAH9bji0A2mGdAjBoy50mCq5GCDuKfoiYkn0hJUokYc7MuwtYAEC7MMsdjtsbj7y01rrwy3KYAswZdSVfPrIqYQeU0nWkXRfykiIT2XORJISWUjL1KSMhyFlcmyxgwJrxhfzHDtkRjznpW(wKmNkmRs4eAsXEyjQjL1KSMhjiRjRcEJXIw43uVujwiEJURuWET2cigpgDDuKf2nPSMK18a7BrOePmfwCQrwgkQjL1KSMhjiRjRcEdOOf(nLZ8AHcoNJrxhfzHDtkRjznpW(weOS0CYxvsvAwutkRjznpsqwtwf8gqrl8BkJtzOL3K8yCmAZbLJflRbdwniwiMAyqrLXdkS4b56GqhubhKlKxsVj5(y01rrw4TWLw4XOnhegLHb7YWAqf(Gmjqy1K8GWYsgKqGYLPEtYdIxoRy4GQDqAswZdSogDDuKfI9TiWGDzyngT5GWOmLiLdcwlqjpOgiooCqStLggejSy6GclFhuEkipimzNwlWb5RAqysjUcwkEm66Oile7BreYPL3KSORNX30OLOmLiLIkKlb5BA0snqCCOGbuaSCrdehVhuqo1yNwlWoOPax0aXX7nkXvWsXDqtSogT5GYXleKYdsCEqa5yq4Gs5GeeznqO1GU8LoiGETWb5RAqoLxBedIYuIuwlWbDzc4gdkS4bjMuk4GAG44Wb5I7ggJUokYcX(weHCA5njl66z8TN1aHwjnzvvuKvuHCjiFRjznsYKuBa7kgV0vy7nGy3aXX7nkXvWsXDqtb4LPany7ngJbbWYfAYQaRORjGBKclorukOD7nqC8oLiLPWItnYYWoLZ8AH2EFfdyDmAZbLBQWAqzGYOmL8GcNcKdOOdkSk4GeYPL3K8Gk4G0wSwywnOGmifRlfpiXT4WIPdcsY4bDzbfCqqlcOunOgpiOHvZQbjEfwdctPR4bLBLGuQHXORJISqSVfriNwEtYIUEgF3KUIt4sqk1qcAy1IkKlb5BOjlLPWPa5a2BsxXjCjiLAqWaka1lvIfI3O7kfSxRTaIb72BG449M0vCcxcsPg6GMJrxhfzHyFlcfCtUokYMKfmeD9m(ggSldlrl8ByWUmSyv3LYXORJISqSVfr7szY1rr2KSGHORNX3AfCmAZbLBRTGwdYJbL5ITYaZg0LV0b1aJb5crk1Ge3HrTaheMuIRGLIhKVQbLRcwAHhKGI6IpOgzbHdstYAKbzsQnGJrxhfzHyFlcfCtUokYMKfmeD9m(gV2cAjAHFRjznsYKuBaT9wBMYCXMGM8QYHgioEVrjUcwkUdAMdyPbIJ3jMMeAaUvyOdAMReUK3OlOblTWjf1fVZR3KScR2TRjznsYKuBaV9TYCTLtbYQK2Cm66Oile7Br0UuMCDuKnjlyi66z8DdSKQXORJISqSVfXPAF5uqOuEdrl8BEzkqdDfJx6kS9(kgJnVmfOHoLbY7y01rrwi23I4uTVCYeuc5XORJISqSVfrwaTcykxhubmJ3ym66Oile7BrAoWebpf0slmCmogT5GWeSKkMchJUokYc7nWsQUHSjSGJrxhfzH9gyjvyFlcqlcmKgsWGwcZJrxhfzH9gyjvyFlc0Qes0c)McUmoHcK7rTgsbrSLo1KUIhJUokYc7nWsQW(wewBrQfyIYM0kZx1y01rrwyVbwsf23Iazk1dwLAKLtqZsywuTbTKtHtbYb8(QOf(9fks0HmL6bRsnYYjOzjm3JslCTaTB31rjeN4LZkgEFvaQxQeleVr3vkyVwBXbLYeL1wofiNIkJTBxB5uGm0wafaVaAfjkN51cfmgpgT5GeJH8GU0cge5GowKyqIxH1GetMMeAaUvyyqf(GUmjR5XGUusWR2WGeNS2igeriMQDZbXltbAq0bjUfVdQIbjEjLdIfRRdPHbPDZbD5lv0brOdsClEheiSwGdkxfS0cpibf1fFm66OilS3alPc7BrmlyqKjOfjeTWVBG44DIPjHgGBfg6GMcGfEzkqdDfJx6kSfl8YuGg6ugiVyFfdy1UDnjRrsMKAdyxX4LUcbFFf7gioEVrjUcwkUdAA3E4sEJUGgS0cNuux8oVEtYkSogDDuKf2BGLuH9TiMfmiYe0IeIw43nqC8oX0KqdWTcdDqtbWsdehVdKY8cfUwys8slmtHDqt72BG44Dnz1SlzvQjbxftBGqyh0eRJrxhfzH9gyjvyFlcS2cgmnbdAjmpgDDuKf2BGLuH9TiajGazrl87WL8gDvrddPGwAHHDE9MKvcOjznsYKuBa7kgV0vy79vSBG449gL4kyP4oO5yCmAZbDzcrQiIVWXOnheMsxXdk3kbPuddISdcqSheVCwXWXORJISWUwbVBsxXjCjiLAq0c)gAYszkCkqoG2EdOax0aXX7nPR4eUeKsn0bnhJ2CqIXWAboibrwdeAnOcoiFqaMJAq1QPSdzrheKmOC0(wqRbP9DqnEqqsghvgdhuJheiKvdYHdYheyuYkmmiOjlLdcCLmeoiqyTahuUMddMoibbe6qyTdIqhKGI9WsAyqhlxrehogDDuKf21ki23IiKVf0s0c)(cyWUmSyv3LsbeYPL3KC3ZAGqRKMSQkkYkqMddMMCi0HWAtuoZRfEJbbWYfuWLXjuGCxXEyjnKGwUIio0U9gioExXEyjnKGwUIioSRiIVcOjznsYKuBaf8nGyDm66OilSRvqSVfbx6azP0JISJrxhfzHDTcI9Ti4shilLEuKnPLSVqw0c)wXnqC8oU0bYsPhfz7uoZRfkyahJUokYc7Afe7BrCfLxxwlNOGqlrl87lAG44Dxr51L1Yjki0QdAkawUqtisfr8TlCjL1cmbnPm3bnTB)IWL8gDHlPSwGjOjL5oVEtYkSogDDuKf21ki23IqjszkS4uJSmu0c)UbIJ3PePmfwCQrwg2PCMxluW350UDHCA5nj3PrlrzkrkhJ2CqIb8b5kfCqoLheOPOdcULjpOWIhez5bjEfwdsseNHXGYNxq1hKymKhK4w8oiLHAboiChgmDqHLVd6Yx6GumEPRyqe6GeVclcymiFnmOlFP9XORJISWUwbX(wKmNkmRs4eAsXEyjQ2GwYPWPa5aEFv0c)M6LkXcXB0DLc2bnfalHtbYrpQmofKKQybRjznsYKuBa7kgV0vy3(fWGDzyXQoLaeKfqtYAKKjP2a2vmEPRW2BTzkZfBcAYRkhUI1XOnhKyaFqlzqUsbhK4LuoivXds8kSQDqHfpOLfBmOCIbOOdceYdkxdxqniYoOgbchK4vyraJb5RHbD5lTpgDDuKf21ki23IK5uHzvcNqtk2dlrl8BQxQeleVr3vkyVwBZjgYbQxQeleVr3vkyxbs9OiRaxad2LHfR6ucqqwanjRrsMKAdyxX4LUcBV1MPmxSjOjVQC46y01rrwyxRGyFlIWLuwlWe0KYSOf(TqoT8MK7nPR4eUeKsnKGgwTayHxMc0qpQmofKuMlwBb0UDOjlLPWPa5aAlGyDm66OilSRvqSVfPjDfNOGqlrl8BHCA5nj3BsxXjCjiLAibnSAbWcVmfOHEuzCkiPmxS2cOD7qtwktHtbYb0waX6y01rrwyxRGyFlIIYUQjDfdfTWVVagSldlw1DPuanjRrsMKAdOGVVogDDuKf21ki23IaTCfr8mwQeTWVVagSldlw1DPuaHCA5nj39Sgi0kPjRQIISJrxhfzHDTcI9TiMKOiROf(DdehV3KeIsccJoLDDy3oEb0ksuoZRfk4CIb72BG44Dxr51L1Yjki0QdAogDDuKf21ki23I0KeIkHdsnmgDDuKf21ki23I0ykKPcxlWXORJISWUwbX(we8IYnjHOgJUokYc7Afe7Br8vZWG6YK2LYXOnhKGIXDqzminzvvuKfoiCcDqGqVj5bvbNb7JrxhfzHDTcI9TiGqovbNbfTWVVGcUmoHcK7zov4ebpfwCkZHbttoe6qyTcO4gioEVXH4mVPWItSbg2bnfalxeUK3Od0IadPHemOLWCNxVjzLD7kUbIJ3bArGH0qcg0syUdAIv72ZCyW0KdHoewBIYzETqBXGD74fqRir5mVwOGVbedJXXOnhuUT2cAXu4y01rrwyhV2cADdLLMt(QsQsZIw43nqC8ouwAo5RkPkn3PCMxluW4fqRir5mVwOaugNYqlVj5XOnheMroEqKDqAcrQiIVdkidsyMnhuyXd6Y0kgKIBG44dc0Cm66OilSJxBbTW(wKghIZ8McloXgy4y01rrwyhV2cAH9TiQcA6H2AmogT5Gob7YWAm66OilSdd2LH1TQGMEOTeTWV1KSgjzsQnG2ERntzUytqtEvJrxhfzHDyWUmSW(wepRbcTgJUokYc7WGDzyH9TiAl2ntqlsiQ2GwYPWPa5aEFv0c)oCjVr3KYgsKnfwCsC2fUZR3KSsGlcNcKJEbtnce(hOjRFaauqIHp(4Fa]] )

end