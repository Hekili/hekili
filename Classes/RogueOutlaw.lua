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
            max_stack = 1
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
        if not legendary.mark_of_the_master_assassin.enabled then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + 4
        elseif buff.master_assassins_mark.up then return buff.master_assassin_mark.remains end
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
                applyBuff( "master_assassins_mark", 4 )
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


    spec:RegisterPack( "Outlaw", 20210117, [[d4KhRaqiaXJOu4sukkzteOprPuJckPtrawfLQiVckAwes3Isr2Ls(fHyyakhtPQLbL6zukzAeQuxJsvTnav5BuQsJdqIohLIQ1bLOMhb09uk7JsLdcLilek8qavMiGQ6IuQcBeqs9rkffNKqfwjfAMasYnbKGDQu5NeQKHciLJsPkQLcLqpvQMQuQRcivTvkfL6RasLXsOI2RQ(RedgYHPAXs6XKAYKCzuBgQ(maJMsoTOvdiHEnb1Sj62sXUv53igofDCOeSCKEoOPlCDG2ob57ekJNqvNNcMVuY(v8V)B)DLh8VdBGH9EGTFV9UaMn3(2AVT(EyWK)UPRf2bWF)8g(7IlWq6I9Dt3GK4QV93HeqQM)UveMqSSiIaidlW6stAebMnGspsYPPoEicmB0I89kykdXX91VR8G)DydmS3dS97T3fWS523w7X(7oyyrOFVNna33TsLIVV(Dfd1F3gdsCbgsxSbHfjaa5XOngKr)aDQHbT3EfDqydmS3)Dzcd43(7kg3bLX3(3T)B)Dxhj5(UWPw4VZNxLS6X4JFh2F7V76ij33Hb7YW6785vjREm(43zRV935ZRsw9y8DI53HC8Dxhj5(Uqon9QK)UqUeK)onQLkiooCqcCqypibhewheqgufehFfuqUuzNMhGfO5GeCqazqvqC8vLsCfmv8c0Cqc47c50Y5n83PrTqzkrk)43jU)2FNpVkz1JX3jMFhYX3DDKK77c500Rs(7c5sq(7AstLumj5fWLIXtDgdYUTbH9GWCqvqC8vLsCfmv8c0Cqcoi(ykaddYUTbzFGnibhewheqgKMCkWmwAc4fLWIleLcU4ZRswnOwTgufehFrjszjS4sLCmCr5gpp4GSBBq7b2GeW3fYPLZB4V7nvqOvrtovgj5(43z)V935ZRsw9y8DI53HC8Dxhj5(Uqon9QK)UqUeK)o0KLYs4uaCaxvPR4cUeKsnmiboiShKGdI6PQWcXxSCLcUYBq2niSb2GA1AqvqC8vv6kUGlbPudlqZVlKtlN3WFVkDfxWLGuQHc0WP)43b8(2FNpVkz1JX310myA6FhgSldlwTCP87UosY9Dk4vCDKKRity8DzcJY5n83Hb7YW6JFN9(T)oFEvYQhJV76ij331UuwCDKKRity8DzcJY5n831k4h)oGYV935ZRsw9y8DnndMM(31KMkPysYlGdYUTbPnlnU4lqt(udYMgufehFvPexbtfVanhKnniSoOkio(IyAsOb4LHHfO5GSNgu4s(Ifwam1cxuuxSfFEvYQbjGb1Q1G0KMkPysYlGdABq(LnU2YPayvrB(Dxhj5(of8kUosYvKjm(UmHr58g(745LqRp(D28V935ZRsw9y8Dxhj5(U2LYIRJKCfzcJVltyuoVH)EfmLQp(D7b23(785vjREm(UMMbtt)78Xuagwkgp1zmi72g0E7pimheFmfGHfLbW33DDKK77ov7hxccLYx8XVB)(V93DDKK77ov7hxmbLq(785vjREm(43Th7V93DDKK77YeGvalafbvaA4l(oFEvYQhJp(D7T13(7UosY99QdOqWlbn1cd)oFEvYQhJp(47MuwtAQE8T)D7)2F31rsUV7MMsdftscj335ZRsw9y8XVd7V93DDKK77vseswvWLUbwjwEakbr859D(8QKvpgF87S13(7UosY9DyWUmS(oFEvYQhJp(DI7V935ZRsw9y8Dxhj5(EJtfMvfCcTOypS(UMMbtt)7upvfwi(ILRuWvEdYUbHT9)UjL1KMQhfiRjNc(D7)XVZ(F7VZNxLS6X47UosY9DkrklHfxQKJHFxtZGPP)Dk345bhKahKT(UjL1KMQhfiRjNc(DS)43b8(2FNpVkz1JX3DDKK77qzQ5IFQIk18310myA6FNY4ugA5vj)DtkRjnvpkqwtof87y)XhFhpVeA9T)D7)2FNpVkz1JX310myA6FVcIJVGYuZf)ufvQ5fLB88GdsGdcpbyffk345bhKGdIY4ugA5vj)Dxhj5(ouMAU4NQOsn)XVd7V93DDKK77voeJ5RewCHnWWVZNxLS6X4JFNT(2F31rsUVRsOPhARVZNxLS6X4Jp(Uwb)2)U9F7VZNxLS6X47AAgmn9VdnzPSeofahWbz32GWEqcoiGmOkio(QkDfxWLGuQHfO53DDKK77vPR4cUeKsn8XVd7V935ZRsw9y8DnndMM(3bYGGb7YWIvlxkhKGdsiNMEvYlVPccTkAYPYij3GeCqnomyAXHqhcZRq5gpp4G2geWgKGdcRdcidIcEmoHcGxk2dlPHc0YveXGl(8QKvdQvRbvbXXxk2dlPHc0YveXGlfrSBqcoinPPskMK8c4Ge42GWEqc47UosY9DH8lHwF87S13(7UosY9DCPdGLspsY9D(8QKvpgF87e3F7VZNxLS6X47AAgmn9VR4kio(cx6ayP0JKClk345bhKahe2F31rsUVJlDaSu6rsUIwY(b5p(D2)B)D(8QKvpgFxtZGPP)DGmOkio(Yvu(CzECHccTwGMdsWbH1bbKbPjePIi2TeoLY8auGMuMxGMdQvRbbKbfUKVyjCkL5bOanPmV4ZRswnib8Dxhj5(URO85Y84cfeA9XVd49T)oFEvYQhJVRPzW00)EfehFrjszjS4sLCmCr5gpp4Ge42GS1GA1Aqc500RsErJAHYuIu(Dxhj5(oLiLLWIlvYXWp(D273(785vjREm(URJKCFVXPcZQcoHwuShwFxtZGPP)DQNQcleFXYvk4c0CqcoiSoOWPa4yfzdxcsrL8Ge4G0KMkPysYlGlfJN6mguRwdcidcgSldlwTOeaG8GeCqAstLumj5fWLIXtDgdYUTbPnlnU4lqt(udYMg0(bjGVRnOLCjCkaoG)U9F87ak)2FNpVkz1JX310myA6FN6PQWcXxSCLcUYBq2niBbSbztdI6PQWcXxSCLcUuGupsYnibheqgemyxgwSArjaa5bj4G0KMkPysYlGlfJN6mgKDBdsBwACXxGM8PgKnnO9F31rsUV34uHzvbNqlk2dRp(D28V935ZRsw9y8DnndMM(3fYPPxL8QkDfxWLGuQHc0WPhKGdcRdIpMcWWkYgUeKsJl(bz3GWEqTAniOjlLLWPa4aoi7ge2dsaF31rsUVlCkL5bOanPm)XVBpW(2FNpVkz1JX310myA6FxiNMEvYRQ0vCbxcsPgkqdNEqcoiSoi(ykadRiB4sqknU4hKDdc7b1Q1GGMSuwcNcGd4GSBqypib8Dxhj5(Ev6kUqbHwF872V)B)D(8QKvpgFxtZGPP)DGmiyWUmSy1YLYbj4G0KMkPysYlGdsGBdA)3DDKK77kk7QQ0vm8JF3ES)2FNpVkz1JX310myA6FhidcgSldlwTCPCqcoiHCA6vjV8Mki0QOjNkJKCF31rsUVdTCfrSgwQ(43T3wF7VZNxLS6X47AAgmn9VxbXXxvjHOKGWyrzxhdQvRbHNaSIcLB88GdsGdYwaBqTAnOkio(Yvu(CzECHccTwGMF31rsUVBsIKCF872lU)2F31rsUVxLeIQGdsn8D(8QKvpgF872B)V93DDKK77vMczQW5b4785vjREm(43Th49T)URJKCFhpPCvsiQVZNxLS6X4JF3E79B)Dxhj5(UFAgguxw0Uu(D(8QKvpgF872du(T)oFEvYQhJVRPzW00)UIRG44RkhIX8vclUWgy4c0CqcoiSoiGmOWL8flaweyinuGbnfMx85vjRguRwdsXvqC8falcmKgkWGMcZlqZbjGb1Q1GWtawrHYnEEWbjWTbHnW(URJKCFheYLm4g4hF8DyWUmS(2)U9F7VZNxLS6X47AAgmn9VRjnvsXKKxahKDBdsBwACXxGM8P(URJKCFxLqtp0wF87W(B)Dxhj5(U3ubHwFNpVkz1JXh)oB9T)oFEvYQhJV76ij331wSBwGwK47AAgmn9VhUKVyzszdfYvclUig7cV4ZRswnibheqgu4uaCSsyPsGWVRnOLCjCkaoG)U9F8X3RGPu9T)D7)2F31rsUVdztyc)oFEvYQhJp(Dy)T)URJKCFhGfbgsdfyqtH5VZNxLS6X4JFNT(2FNpVkz1JX310myA6FNcEmoHcGxrEgkbr8PUuLUIx85vjR(URJKCFhALc9XVtC)T)URJKCFN1wK8auOSjnB8t9D(8QKvpgF87S)3(785vjREm(URJKCFhYuQhSQujhxGMPW8310myA6FhidsrIfKPupyvPsoUantH5vKAHZdWGA1AqUosH4cFCtYWbTnO9dsWbr9uvyH4lwUsbx5ni7geoOuwOS2YPa4sKn8GA1AqAlNcGHdYUbH9GeCq4jaROq5gpp4Ge4GS)31g0sUeofahWF3(p(DaVV935ZRsw9y8DnndMM(3RG44lIPjHgGxggwGMdsWbH1bXhtbyyPy8uNXGSBqyDq8XuagwugaFdcZbThydsadQvRbPjnvsXKKxaxkgp1zmibUnO9dcZbvbXXxvkXvWuXlqZb1Q1GcxYxSWcGPw4II6IT4ZRswnib8Dxhj5(UzcdISaTiXh)o79B)D(8QKvpgFxtZGPP)9kio(IyAsOb4LHHfO5GeCqyDqvqC8fakZhu48GfXsTWmfUanhuRwdQcIJV0KtZUKvLQe8umTccHlqZbjGV76ij33ntyqKfOfj(43bu(T)URJKCFhMxcdMwGbnfM)oFEvYQhJp(D28V935ZRsw9y8DnndMM(3dxYxSujnmucAQfgU4ZRswnibhKM0ujftsEbCPy8uNXGSBBq7heMdQcIJVQuIRGPIxGMF31rsUVdGacG)4Jp(UqmfMK73HnWWEpW2V3E)Uyo9Yda87aDyjS4oXXoBgS8GguBlEqzJjHgdcNqhKTvmUdkdBpikJfatkRgeK0WdYbdsJhSAqAl)aWW1yeOkpEqIBS8GaoYjetdwniBRjNcmJL402dkidY2AYPaZyjox85vjRS9GW6EXlG1yCmc0HLWI7eh7SzWYdAqTT4bLnMeAmiCcDq2wRG2EquglaMuwniiPHhKdgKgpy1G0w(bGHRXiqvE8GWglpiGJCcX0GvdY2uWJXjua8sCA7bfKbzBk4X4ekaEjox85vjRS9GW6EXlG1yCmc0HLWI7eh7SzWYdAqTT4bLnMeAmiCcDq2UcMsLTheLXcGjLvdcsA4b5GbPXdwniTLFay4AmcuLhpiBHLheWroHyAWQbzBk4X4ekaEjoT9GcYGSnf8yCcfaVeNl(8QKv2EqEmi7H4cOAqyDV4fWAmogfhnMeAWQbb8gKRJKCdsMWaUgJF3KsWtj)DBmiXfyiDXgewKaaKhJ2yqg9d0Pgg0E7v0bHnWWE)yCmAJbzpepRbdwnOkJtO8G0KMQhdQYaYdUgewsRzZaoOJC2KLtBWbLdY1rso4GiN0WAm66ijhCzsznPP6XMBAknumjjKCJrxhj5GltkRjnvpWCtKkjcjRk4s3aRelpaLGi(8gJUosYbxMuwtAQEG5MiWGDzyngDDKKdUmPSM0u9aZnrACQWSQGtOff7HLOMuwtAQEuGSMCk4M9fnX3OEQkSq8flxPGR8SdB7pgDDKKdUmPSM0u9aZnrOePSewCPsogkQjL1KMQhfiRjNcUHTOj(gLB88Gc0wJrxhj5GltkRjnvpWCteOm1CXpvrLAwutkRjnvpkqwtofCdBrt8nkJtzOLxL8yCmAJbzpepRbdwniwiMAyqr2WdkS4b56GqhuchKlKNsVk51y01rso4MWPw4XOngewKHb7YWAqj(GmjqywL8GW6rgKqGYJPEvYdIpUjz4GYBqAst1dbmgDDKKdI5MiWGDzyngTXGWImLiLdcMhajpOkiooCqStLggejSy6Gcl)guBkipimyNMhGb5NAqyqjUcMkEm66ijheZnreYPPxLSON3WB0OwOmLiLIkKlb5nAulvqCCOaXwqScKkio(kOGCPYonpalqtbbsfehFvPexbtfVanfWy0gdYECqqkpiX4bbGJbHdkLdcl1ubHwdc4aAdcGNhCq(PgKt5Z2XGOmLiL5byqahb8Ibfw8GexkfCqvqCC4GCXCdJrxhj5GyUjIqon9QKf98gEZBQGqRIMCQmsYjQqUeK30KMkPysYlGlfJN6mSBdBmRG44RkL4kyQ4fOPG8XuagSBZ(atqScen5uGzS0eWlkHfxikfSvRkio(IsKYsyXLk5y4IYnEEq722dmbmgTXGa6YWAqnGYinL8GcNcGdOOdkSs4GeYPPxL8Gs4G0wSwywnOGmifRtfpiXS4WIPdcsA4bbCaF4GGweqPAqvEqqdNMvdsSmSgegsxXdcOwcsPggJUosYbXCteHCA6vjl65n8wv6kUGlbPudfOHtlQqUeK3GMSuwcNcGd4QkDfxWLGuQbbITGupvfwi(ILRuWvE2HnWA1QcIJVQsxXfCjiLAybAogDDKKdI5MiuWR46ijxrMWq0ZB4nyWUmSenX3Gb7YWIvlxkhJUosYbXCteTlLfxhj5kYegIEEdVPvWXOngeqDEj0AqEmOgx8zdyZGaoG2GQGXGCHiPAqI5WipadcdkXvWuXdYp1GSNbtTWdc4tDXguLCGWbPjnvYGmj5fWXORJKCqm3eHcEfxhj5kYegIEEdVHNxcTenX30KMkPysYlG2TPnlnU4lqt(u2ufehFvPexbtfVanTjSwbXXxettcnaVmmSanTNcxYxSWcGPw4II6IT4ZRswjGwT0KMkPysYlGB(LnU2YPayvrBogDDKKdI5MiAxklUosYvKjme98gERcMs1y01rsoiMBI4uTFCjiukFHOj(gFmfGHLIXtDg2TT3(yYhtbyyrza8ngDDKKdI5Miov7hxmbLqEm66ijheZnrKjaRawakcQa0WxmgDDKKdI5MivhqHGxcAQfgoghJ2yqyaMsftHJrxhj5GRkykvBq2eMWXORJKCWvfmLkm3ebGfbgsdfyqtH5XORJKCWvfmLkm3ebALcjAIVrbpgNqbWRipdLGi(uxQsxXJrxhj5GRkykvyUjcRTi5bOqztA24NAm66ijhCvbtPcZnrGmL6bRkvYXfOzkmlQ2GwYLWPa4aUTx0eFdiksSGmL6bRkvYXfOzkmVIulCEaA1Y1rkex4JBsgUTxqQNQcleFXYvk4kp7WbLYcL1wofaxISHB1sB5uam0oSfepbyffk345bfO9hJ2yqa9qEqaTege5G6wKyqILH1GexMMeAaEzyyqj(Gaost1Jbb0ibFAddsmYz7yqeHyQ2nheFmfGbrhKyw8nOmgKyPuoiw8UoKggK2nheWb0eDqe6GeZIVbbcZdWGSNbtTWdc4tDXgJUosYbxvWuQWCteZegezbArcrt8Tkio(IyAsOb4LHHfOPGyLpMcWWsX4Pod7WkFmfGHfLbWhM7bMaA1stAQKIjjVaUumEQZqGB7XScIJVQuIRGPIxGMTAfUKVyHfatTWff1fBXNxLSsaJrxhj5GRkykvyUjIzcdISaTiHOj(wfehFrmnj0a8YWWc0uqSwbXXxaOmFqHZdwel1cZu4c0SvRkio(ston7swvQsWtX0kieUanfWy01rso4QcMsfMBIaZlHbtlWGMcZJrxhj5GRkykvyUjcaciaw0eFlCjFXsL0WqjOPwy4IpVkzLGAstLumj5fWLIXtDg2TThZkio(QsjUcMkEbAoghJ2yqahHiveXo4y0gdcdPR4bbulbPuddICdcBmheFCtYWXORJKCWLwb3QsxXfCjiLAq0eFdAYszjCkaoG2THTGaPcIJVQsxXfCjiLAybAogTXGa6H5byqyPMki0AqjCq(GW2M1GYttzhYIoiizq2S9lHwds73GQ8GGKgoYggoOkpiqiRgKdhKpiWiLzyyqqtwkhe4jziCqGW8amiGcomy6GWsqOdH5nicDqaF2dlPHb1TCfrm4y01rso4sRGyUjIq(Lqlrt8nGad2LHfRwUukOqon9QKxEtfeAv0KtLrsobBCyW0IdHoeMxHYnEEWnGjiwbcf8yCcfaVuShwsdfOLRiIbB1QcIJVuShwsdfOLRiIbxkIyNGAstLumj5fqbUHTagJUosYbxAfeZnrWLoawk9ij3y01rso4sRGyUjcU0bWsPhj5kAj7hKfnX3uCfehFHlDaSu6rsUfLB88Gce7XORJKCWLwbXCtexr5ZL5Xfki0s0eFdivqC8LRO85Y84cfeATanfeRartisfrSBjCkL5bOanPmVanB1ciHl5lwcNszEakqtkZl(8QKvcym66ijhCPvqm3eHsKYsyXLk5yOOj(wfehFrjszjS4sLCmCr5gppOa3SvRwc500RsErJAHYuIuogTXGeh4dYvk4GCkpiqtrhe8stEqHfpiYXdsSmSgKKigdJb1UnWFniGEipiXS4Bqkd5byq4omy6Gcl)geWb0gKIXtDgdIqhKyzyraJb5NHbbCaT1y01rso4sRGyUjsJtfMvfCcTOypSevBql5s4uaCa32lAIVr9uvyH4lwUsbxGMcI1WPa4yfzdxcsrLSa1KMkPysYlGlfJN6mA1ciWGDzyXQfLaaKfutAQKIjjVaUumEQZWUnTzPXfFbAYNYM2lGXOngK4aFqhzqUsbhKyPuoivYdsSmSYBqHfpOJfFmiBbmOOdceYdcOaoWFqKBqvceoiXYWIagdYpddc4aARXORJKCWLwbXCtKgNkmRk4eArXEyjAIVr9uvyH4lwUsbx5zNTaMnr9uvyH4lwUsbxkqQhj5eeiWGDzyXQfLaaKfutAQKIjjVaUumEQZWUnTzPXfFbAYNYM2pgDDKKdU0kiMBIiCkL5bOanPmlAIVjKttVk5vv6kUGlbPudfOHtliw5JPamSISHlbP04I3oSB1cAYszjCkaoG2HTagJUosYbxAfeZnrQsxXfki0s0eFtiNMEvYRQ0vCbxcsPgkqdNwqSYhtbyyfzdxcsPXfVDy3Qf0KLYs4uaCaTdBbmgDDKKdU0kiMBIOOSRQsxXqrt8nGad2LHfRwUukOM0ujftsEbuGB7hJUosYbxAfeZnrGwUIiwdlvIM4BabgSldlwTCPuqHCA6vjV8Mki0QOjNkJKCJrxhj5GlTcI5MiMKijNOj(wfehFvLeIsccJfLDD0QfEcWkkuUXZdkqBbSwTQG44lxr5ZL5Xfki0AbAogDDKKdU0kiMBIuLeIQGdsnmgDDKKdU0kiMBIuzkKPcNhGXORJKCWLwbXCte8KYvjHOgJUosYbxAfeZnr8tZWG6YI2LYXOngeWNXDqzmiCxkRUw4bHtOdce6vjpOm4g4Am66ijhCPvqm3ebeYLm4gOOj(MIRG44RkhIX8vclUWgy4c0uqScKWL8flaweyinuGbnfMx85vjRA1sXvqC8falcmKgkWGMcZlqtb0QfEcWkkuUXZdkWnSb2yCmAJbbuNxcTykCm66ijhCHNxcT2GYuZf)ufvQzrt8Tkio(cktnx8tvuPMxuUXZdkq8eGvuOCJNhuqkJtzOLxL8y0gdcJWEmiYninHiveXUbfKbjmZMdkS4bbC0mgKIRG44dc0Cm66ijhCHNxcTWCtKkhIX8vclUWgy4y01rso4cpVeAH5MiQeA6H2AmogTXG6b7YWAm66ijhCbd2LH1MkHMEOTenX30KMkPysYlG2TPnlnU4lqt(uJrxhj5GlyWUmSWCteVPccTgJUosYbxWGDzyH5MiAl2nlqlsiQ2GwYLWPa4aUTx0eFlCjFXYKYgkKRewCrm2fEXNxLSsqGeofahRewQei87qtw)7Wg4bSp(4Fa]] )

end