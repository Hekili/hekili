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


    spec:RegisterPack( "Outlaw", 20210131, [[d80j6aqiqvEebQlPqs1MqK(KQQAuQQ0PuvXQiqIxrOmlcv3IKI2fGFjummvv5yiILrqEgjLMgOQ4Aei2gjvPVPqsgNcj6CeiL1PqQMNqPUhIAFkehKKilKaEijvMijfUOcPSrfs4JkKuojOQQvku9sqvPmtsc5MKeyNeu)KKqnusI6OeiPLcQQ8uGMkOYvjjOTsGu9vqvjJLKQAVi9xfnyPomvlwvESGjtQlJAZi8zqz0K40swnOQu9AssZMOBRGDR0VHmCHCCsQILd1Zvz6IUoiBxvPVRqnEHsopHmFvf7NYusOWrb1EYuHf6pHi5psuljacrc8zucFgvuWuuetbJ8GQomMcU(atbvXqP0htbJCrsKRPWrbpeeoWuqLmJUrpMyGvPc0diGgI5QbiPNfAdyNiJ5QHqmuWhujt4)sFuqTNmvyH(tis(Je1scGqKaFgLQDurbDOubHPGG1G6OGkLwZl9rb18fOGcwWwRIHsPp2A4hcgeBXfSGToUVqowK1QLeXTwO)eIekOSU8OWrb1mHdjtkCuHjHchf0dzHwkOQvqvkiV(tYAQa0KkSqu4OG86pjRPcqb18fWvuwOLcc)4lzxMkwxewhHUREs26FxK1FHKlJ9NKTMxEO4Z6AToGgEE(df0dzHwk4LSltfAsfwTu4OG86pjRPcqbrruWJtkOhYcTuWVoU8NKPGFDjetbX5B(GiioRJT1cznPw)R1WZ6hebbqIH45JDCTWaGISMuRHN1piccGhg56R0mauK1)qb18fWvuwOLcc)ymskT(QfMKT(brqCwZowkYAuQWyRtfFTgomeBTaSJRfM1(QTwamY1xPzk4xhpxFGPG48nXmgjL0Kkm8HchfKx)jznvakikIcECsb9qwOLc(1XL)Kmf8RlHykyan8qZiuT5bOzIkuP1Jq2AHSwmRFqeeapmY1xPzaOiRj1AEzmmrwpczRfK)SMuR)1A4zDaTAOkbciOnNPcprA9bWR)KS26pFS(brqaGrs5mv45dT8bG5bV2Z6riBnj)z9puqnFbCfLfAPGJ2Eqy26XS1W40AciP0AvA4bDkwRov2AyETN1(QT2X8(FAnMXiPSwywRoe0MwNkS1QyT(S(brqCw7JDruWVoEU(atb9Hh0PmdOvxzHwAsfwqOWrb51FswtfGcIIOGhNuqpKfAPGFDC5pjtb)6siMcgqdp0mcvBEwpczRdrZbpwZlIxT1QP1piccGhg56R0mauK1QP1)A9dIGaaffHWj0wPiaOiRfuSoDjVjG6bQcQo1yFmaV(tYAR)X6pFSoGgEOzeQ28SMS1(wdEqXXWy9merb18fWvuwOLcokQTofR906bpw1a0G1QtLT(bLw7FrL26X(L1cZAbWixFLMT2xT1cQqvqvRvdSp26hAHoRdOHhY6iuT5rb)6456dmfKO26uMb0QRSqlnPcREPWrb51FswtfGcIIOGhNuqpKfAPGFDC5pjtb)6siMcErSuothdJZd4jDnpjKqySiRJT1cznPwJ9sp5V8MaUwFa1A9iwl0Fw)5J1piccGN018KqcHXIaGIOGA(c4kkl0sbHVQuX6bizwrs260XW48e36uPoR)64YFs266SoOWbvzT1jYAnhknB9yfovyS1hAGTwDQXz9PGGKARFS1NOnWARhxPI1ciDnB9OqcHXIOGFD8C9bMc(KUMNesimw08eTbAsfEurHJcYR)KSMkafmGRKXLtbVKDzQWAaxkPGEil0sbXq70dzH2PSUKckRlNRpWuWlzxMk0Kk8OKchfKx)jznvakOhYcTuWGlLtpKfANY6skOSUCU(atbd6JMuHf0OWrb51FswtfGcgWvY4YPGFDC5pjdquBDkZaA1vwOLc6HSqlfedTtpKfANY6skOSUCU(atbjQTofAsfMK)OWrb51FswtfGc6HSqlfm4s50dzH2PSUKckRlNRpWuWhuj10KkmjKqHJcYR)KSMkafmGRKXLtb5LXWebOzIkuP1Jq2AseeRfZAEzmmrayggVuqpKfAPGoo4lptegZBstQWKiefokOhYcTuqhh8LNrqYJPG86pjRPcqtQWKOwkCuqpKfAPGYcMsEt47qAyd8MuqE9NK1ubOjvysGpu4OGEil0sbFoSjIyM4kO6rb51FswtfGM0KcgH5aA45jfoQWKqHJc6HSqlf0JIKIMrO6qlfKx)jznvaAsfwikCuqpKfAPGpuMswpjKUiwpUwyZefRAPG86pjRPcqtQWQLchf0dzHwk4LSltfkiV(tYAQa0Kkm8HchfKx)jznvakOhYcTuWbhRkRNei8uZEQqbd4kzC5uqSx6j)L3eW16dOwRhXAHeekyeMdOHNNZJdOvFuqbHMuHfekCuqE9NK1ubOGEil0sbXiPCMk88Hw(OGbCLmUCkiMh8ApRJT1QLcgH5aA45584aA1hfuiAsfw9sHJcYR)KSMkaf0dzHwk4jRap9vp1vGPGbCLmUCkiMjW8P4pjtbJWCan88CECaT6JckenPjf8bvsnfoQWKqHJc6HSqlf84ORokiV(tYAQa0KkSqu4OGEil0sbHPGUukAEjUuLPG86pjRPcqtQWQLchfKx)jznvakyaxjJlNcIHwMaHHXazTIMjkwvy(KUMb41Fswtb9qwOLcEk1xAsfg(qHJc6HSqlfKdkOAHnXCeUg8vtb51FswtfGMuHfekCuqE9NK1ubOGEil0sbpgJ9K1ZhA55fvQYuWaUsgxofeEwRrjWXySNSE(qlpVOsvgiRGQ1cZ6pFS2dz9LN8YdfFwt2AsSMuRXEPN8xEtaxRpGATEeRjGKYjMdkoggpZAGT(ZhRdkoggFwpI1cznPwtuWuYjMh8ApRJT1ccfmiki5z6yyCEuHjHMuHvVu4OG86pjRPcqb9qwOLcgvxIKZtbLuqnFbCfLfAPGQWJTwLRlrsRbvqP1JRuXAvCuecNqBLISUiSwDOHNNwRYOK3GiRhJ2)tRrFzCWJSMxgdtK4wpwHxRR06XLuAnhlpKsrwh8iRvNklU1iS1Jv41AORwywlOcvbvTwnW(ykyaxjJlNc(GiiaqrriCcTvkcakYAsT(xR5LXWebOzIkuP1Jy9VwZlJHjcaZW41AXSMK)S(hR)8X6aA4HMrOAZdqZevOsRJnzRjXAXS(brqa8WixFLMbGIS(ZhRtxYBcOEGQGQtn2hdWR)KS26FOjv4rffokiV(tYAQauWaUsgxof8brqaGIIq4eARueauK1KA9Vw)GiiaGHzEpvR9MJRGQm(aGIS(ZhRFqeeab0gyxY65tcTAg)GUdakY6FOGEil0sbJQlrY5PGsAsfEusHJc6HSqlf8QTUKXZlXLQmfKx)jznvaAsfwqJchfKx)jznvakyaxjJlNcMUK3eqx4u0mXvq1dGx)jzT1KADan8qZiuT5bOzIkuP1Jq2AsSwmRFqeeapmY1xPzaOikOhYcTuqyiiymnPjfmOpkCuHjHchfKx)jznvakOhYcTuWN018KqcHXIOGA(c4kkl0sbfq6A26rHecJfznATwiXSMxEO4JcgWvY4YPGxelLZ0XW48SEeYwlK1KAn8S(brqa8KUMNesimweauenPclefokiV(tYAQauqpKfAPGF9TofkOMVaUIYcTuqv4vlmRvPHh0PyDDw7wl0OU11gWSFS4wFiRf09TofRd(A9JT(qdCwd8z9JTg6yT1(zTBnuwYkfz9fXsP1qRKVZAORwywRc8lzS1Q0D(D1AncBTAWEQifznOIRrJpkyaxjJlNccpRXqltGWWyGbhR6ermtfEo4xY4PFNFxTa86pjRTMuRHN1xYUmvynGlLwtQ1FDC5pjd4dpOtzgqRUYcTwtQ1)An8SgdTmbcdJb0SNksrZtX1OXhaV(tYAR)8X6hebbGM9urkAEkUgn(a0OXR1KADan8qZiuT5zDSjBTqw)dnPcRwkCuqE9NK1ubOGbCLmUCkigAzceggdm4yvNiIzQWZb)sgp9787QfGx)jzT1KA9GFjJN(D(D1oX8Gx7znzR)ZAsT(RJl)jzGN018KqcHXIMNOnynPw)R1WZ6acj1OXlWJZXmVZuHNSi(aWSRfznPw)1XL)KmarT1PmdOvxzHwR)8X6acj1OXlWJZXmVZuHNSi(aWSRfznPw)1XL)KmGp8GoLzaT6kl0A9pwtQ1)An8SoGwnuLabe0MZuHNiT(a41FswB9Npw)GiiaWiPCMk88Hw(aW8Gx7z9iKTMK)S(hkOhYcTuWV(wNcnPcdFOWrb9qwOLcsiDySu6zHwkiV(tYAQa0KkSGqHJcYR)KSMkafmGRKXLtb18dIGaGq6WyP0ZcTayEWR9So2wlef0dzHwkiH0HXsPNfANbj77X0KkS6LchfKx)jznvakyaxjJlNccpRFqeeaUgZRlRLNyOtbakIc6HSqlf01yEDzT8edDk0Kk8OIchfKx)jznvakyaxjJlNco4xY4PFNFxTtmp41Ewt26)SMuR)16hebbagjLZuHNp0YhaMh8ApRJnzRvR1F(y9xhx(tYa48nXmgjLw)df0dzHwkigjLZuHNp0YhnPcpkPWrb51FswtfGc6HSqlfCWXQY6jbcp1SNkuWGOGKNPJHX5rfMekyaxjJlNcI9sp5V8MaUwFaqrwtQ1)AD6yyCcK1apt0uxS1X26aA4HMrOAZdqZevOsR)8XA4z9LSltfwdGrWGyRj16aA4HMrOAZdqZevOsRhHS1HO5GhR5fXR2A10AsS(hkOMVaUIYcTuq4pH1UwFw7y2AOiXT(2kITovyRrlB94kvSwIgZxAnCWPgawRcp26Xk8ATwuTWSMWVKXwNk(AT6uzR1mrfQ0Ae26XvQGGsR9vK1QtLbOjvybnkCuqE9NK1ubOGEil0sbhCSQSEsGWtn7PcfuZxaxrzHwki8NW6fzTR1N1JlP0ADXwpUsLATovyRxowP1Q9VtCRHo2AvaHAynAT(HUZ6XvQGGsR9vK1QtLbOGbCLmUCki2l9K)YBc4A9buR1JyTA)ZA10ASx6j)L3eW16dqdH9SqR1KAn8S(s2LPcRbWiyqS1KADan8qZiuT5bOzIkuP1Jq26q0CWJ18I4vBTAAnj0Kkmj)rHJcYR)KSMkafefrbpoPGEil0sb)64YFsMc(1LqmfeEwJHwMaHHXadow1jIyMk8CWVKXt)o)UAb41FswB9NpwhqiPgnEb(6BDkayEWR9SEeRj5pR)8X6b)sgp9787QDI5bV2Z6rSwikOMVaUIYcTuqvktEikTorwFI2G1W3kPSwywdgHz26XvQyTGUV1PynbcBTkWVKXwRs353vlf8RJNRpWuqvlPSwyZlcZ88RV1PmprBGMuHjHekCuqE9NK1ubOGEil0sbvTKYAHnVimZuqnFbCfLfAPGQWJTUwRjrnfcoRlcRfihnRRZAOiR9vB9y0(FADWJSE0wgdtK4wJWw7P1QfoXS(xHGtmRhxPI1Qb7PIuK1GkUgn((XAe26Xk8ATkWVKXwRs353vR11znueafmGRKXLtb)64YFsg4jDnpjKqySO5jAdwtQ1FDC5pjdOAjL1cBEryMNF9ToL5jAdwtQ1WZ6lzxMkSgaJGbXwtQ1)ATMFqeeapohZ8otfEYI4dakYAsTMxgdteGMjQqLwpI1)AnVmgMiamdJxRfuSwiRfZAseeR)X6pFS(IyPCMoggNhWt6AEsiHWyrwpI1)ATqwRMw)Giia0SNksrZtX1OXhauK1)y9Npwp4xY4PFNFxTtmp41EwpI1)z9p0KkmjcrHJcYR)KSMkafmGRKXLtb)64YFsg4jDnpjKqySO5jAdwtQ1)AnVmgMiGSg4zIMdESSEeRfY6pFS(IyPCMoggNN1JyTqw)df0dzHwk4t6AEIHofAsfMe1sHJcYR)KSMkafmGRKXLtbHN1xYUmvynGlLwtQ1b0WdnJq1MN1XMS1Kqb9qwOLcQXSRFsxZhnPctc8HchfKx)jznvakyaxjJlNccpRVKDzQWAaxkTMuR)64YFsgWhEqNYmGwDLfAPGEil0sbpfxJgpWsnnPctIGqHJcYR)KSMkafmGRKXLtbFqeeapjcPLqxcGzpKw)5J1efmLCI5bV2Z6yBTA)Z6pFS(brqa4AmVUSwEIHofaOikOhYcTuWiuwOLMuHjr9sHJc6HSqlf8jri9KaclIcYR)KSMkanPctYOIchf0dzHwk4JXhJvTwyuqE9NK1ubOjvysgLu4OGEil0sbjkm)KiKMcYR)KSMkanPctIGgfokOhYcTuqFd8LyxodUusb51FswtfGMuHf6pkCuqE9NK1ubOGEil0sbHoEwjpCuqnFbCfLfAPGQbt4qY06aA1vwO9SMaHTg68NKTUsE4aOGbCLmUCki8SgdTmbcdJbgCSQteXmv45GFjJN(D(D1cWR)KS2AsTwZpiccGhNJzENPcpzr8bafznPw)R1WZ60L8MaWuqxkfnVexQYa86pjRT(ZhR18dIGaaMc6sPO5L4svgakY6FS(ZhRh8lz80VZVR2jMh8ApRhX6)S(ZhRjkyk5eZdETN1XMS1c9hnPjf8s2LPcfoQWKqHJcYR)KSMkafmGRKXLtb)64YFsgGO26uMb0QRSqlf0dzHwkOUUipdk0KkSqu4OGEil0sb9Hh0Pqb51FswtfGMuHvlfokiV(tYAQauqpKfAPGbf2JMNckPGbCLmUCky6sEtGimlAI2zQWZXSRkaV(tYARj1A4zD6yyCcu38HUJcgefK8mDmmopQWKqtAsbjQTofkCuHjHchfKx)jznvakyaxjJlNc(Giiaozf4PV6PUcmaMh8ApRJT1efmLCI5bV2ZAsTgZey(u8NKPGEil0sbpzf4PV6PUcmnPclefokiV(tYAQauqpKfAPGpohZ8otfEYI4JcQ5lGROSqlfuGC0SgTwhqiPgnETorwRkZrwNkS1QdxP1A(brqynuK4wdTs(oRtf260XW4066S2FiO06ezTUykyaxjJlNcMoggNaznWZen1fB9iwRwAsfwTu4OGEil0sb11f5zqHcYR)KSMkanPjnPGFz8vOLkSq)jej)rIqccfCSJ3AHDuq4lvc(jm8x4rTr3ARHtHTUgIq40Ace26)1mHdjZ)TgZQhOcZARp0aBTdLObpzT1bfFHXhGfxfvlBn8z0TwDO9lJtwB9)b0QHQeq9)36ez9)b0QHQeq9b41Fsw)V1)ssS(bWIBXHVuj4NWWFHh1gDRTgof26AicHtRjqyR)pOV)TgZQhOcZARp0aBTdLObpzT1bfFHXhGfxfvlBTqJU1QdTFzCYAR)hdTmbcdJbu))Torw)pgAzceggdO(a86pjR)36Ffkw)ayXvr1YwR2r3A1H2VmozT1)JHwMaHHXaQ))wNiR)hdTmbcdJbuFaE9NK1)B9VKeRFaS4QOAzRv7OBT6q7xgNS26)dOvdvjG6)V1jY6)dOvdvjG6dWR)KS(FR)LKy9dGfxfvlBnj)n6wRo0(LXjRT(Fm0Yeimmgq9)36ez9)yOLjqyymG6dWR)KS(FR)LKy9dGfxfvlBTq)n6wRo0(LXjRT(Fm0Yeimmgq9)36ez9)yOLjqyymG6dWR)KS(FR)LKy9dGf3IdFPsWpHH)cpQn6wBnCkS11qecNwtGWw))dQK6)TgZQhOcZARp0aBTdLObpzT1bfFHXhGfxfvlBTAhDRvhA)Y4K1w)pgAzceggdO()BDIS(Fm0Yeimmgq9b41Fsw)V1EA9OPIvrw)ljX6halUfh(peHWjRTw9AThYcTwlRlpalof8I4avyHuV)rbJWiIsYuqblyRvXqP0hBn8dbdIT4cwWwh3xihlYA1sI4wl0FcrIf3IlybB9OfloaLS26htGWS1b0WZtRFmSApaRvPqGJYZ6fTQPIJhiGKw7HSq7znALIaS4Eil0EaryoGgEEs2JIKIMrO6qRf3dzH2dicZb0WZtXihZdLPK1tcPlI1JRf2mrXQwlUhYcThqeMdOHNNIroMlzxMkwCpKfApGimhqdppfJCmdowvwpjq4PM9ur8imhqdppNhhqR(iliIxeKXEPN8xEtaxRpGAhribXI7HSq7beH5aA45PyKJbJKYzQWZhA5t8imhqdppNhhqR(ilK4fbzmp41EXwTwCpKfApGimhqdppfJCmNSc80x9uxbw8imhqdppNhhqR(ilK4fbzmtG5tXFs2IBXfSGTE0IfhGswBn)LXISoRb26uHT2djcBDDw7F9s6pjdyX9qwO9iRAfu1IlyRHF8LSltfRlcRJq3vpjB9VlY6VqYLX(tYwZlpu8zDTwhqdpp)XI7HSq7jg5yUKDzQyXfS1WpgJKsRVAHjzRFqeeN1SJLISgLkm26uXxRHddXwla74AHzTVARfaJC9vA2I7HSq7jg5y(64YFsw81hyY48nXmgjLI)1LqmzC(MpicIl2cr6VW7brqaKyiE(yhxlmaOisH3dIGa4HrU(kndaf9JfxWwpA7bHzRhZwdJtRjGKsRvPHh0PyT6uzRH51Ew7R2AhZ7)P1ygJKYAHzT6qqBADQWwRI16Z6hebXzTp2fzX9qwO9eJCmFDC5pjl(6dmzF4bDkZaA1vwOv8VUeIjhqdp0mcvBEaAMOcvoczHe7brqa8WixFLMbGIiLxgdt0iKfK)i9x4fqRgQsGacAZzQWtKwFF(8GiiaWiPCMk88Hw(aW8Gx7nczs(7hlUGTEuuBDkw7P1dESQbObRvNkB9dkT2)IkT1J9lRfM1cGrU(knBTVARfuHQGQwRgyFS1p0cDwhqdpK1rOAZZI7HSq7jg5y(64YFsw81hyYe1wNYmGwDLfAf)RlHyYb0WdnJq1M3iKdrZbpwZlIxTA(GiiaEyKRVsZaqrQ5VpiccauuecNqBLIaGIeusxYBcOEGQGQtn2hdWR)KS(NpFcOHhAgHQnpY(wdEqXXWy9mezXfS1WxvQy9aKmRijBD6yyCEIBDQuN1FDC5pjBDDwhu4GQS26ezTMdLMTEScNkm26dnWwRo14S(uqqsT1p26t0gyT1JRuXAbKUMTEuiHWyrwCpKfApXihZxhx(tYIV(at(jDnpjKqySO5jAdI)1Lqm5lILYz6yyCEapPR5jHecJffBHif7LEYF5nbCT(aQDeH(7ZNhebbWt6AEsiHWyraqrwCpKfApXihdgANEil0oL1LIV(at(s2LPI4fb5lzxMkSgWLslUhYcTNyKJj4s50dzH2PSUu81hyYb9zX9qwO9eJCmyOD6HSq7uwxk(6dmzIARtr8IG8xhx(tYae1wNYmGwDLfAT4Eil0EIroMGlLtpKfANY6sXxFGj)GkP2I7HSq7jg5yCCWxEMimM3u8IGmVmgMiantuHkhHmjcIy8YyyIaWmmET4Eil0EIroghh8LNrqYJT4Eil0EIrogzbtjVj8DinSbEtlUhYcTNyKJ55WMiIzIRGQNf3IlybBTaqLuZ4ZI7HSq7b8GkPM8XrxDwCpKfApGhuj1IrogykOlLIMxIlvzlUhYcThWdQKAXihZPuFfViiJHwMaHHXazTIMjkwvy(KUMT4Eil0EapOsQfJCmCqbvlSjMJW1GVAlUhYcThWdQKAXihZXySNSE(qlpVOsvw8GOGKNPJHX5rMeXlcYWtJsGJXypz98HwEErLQmqwbvRf2NpEiRV8KxEO4JmjKI9sp5V8MaUwFa1ocbKuoXCqXXW4zwd8NpbfhdJVreIuIcMsoX8Gx7fBbXIlyRvHhBTkxxIKwdQGsRhxPI1Q4OieoH2kfzDryT6qdppTwLrjVbrwpgT)NwJ(Y4GhznVmgMiXTEScVwxP1JlP0AowEiLISo4rwRovwCRryRhRWR1qxTWSwqfQcQATAG9XwCpKfApGhuj1IroMO6sKCEkOu8IG8dIGaaffHWj0wPiaOis)LxgdteGMjQqLJ8lVmgMiamdJxXi5VF(8jGgEOzeQ28a0mrfQm2KjrShebbWdJC9vAgak6ZN0L8MaQhOkO6uJ9Xa86pjR)XI7HSq7b8GkPwmYXevxIKZtbLIxeKFqeeaOOieoH2kfbafr6VpiccayyM3t1AV54kOkJpaOOpFEqeeab0gyxY65tcTAg)GUdak6hlUhYcThWdQKAXihZvBDjJNxIlvzlUhYcThWdQKAXihdmeemw8IGC6sEtaDHtrZexbvpaE9NK1Kgqdp0mcvBEaAMOcvoczse7brqa8WixFLMbGIS4wCblyRvhcj1OX7zXfS1ciDnB9OqcHXISgTwlKywZlpu8zX9qwO9ac6J8t6AEsiHWyrIxeKViwkNPJHX5nczHifEpiccGN018KqcHXIaGIS4c2Av4vlmRvPHh0PyDDw7wl0OU11gWSFS4wFiRf09TofRd(A9JT(qdCwd8z9JTg6yT1(zTBnuwYkfz9fXsP1qRKVZAORwywRc8lzS1Q0D(D1AncBTAWEQifznOIRrJplUhYcThqqFIroMV(wNI4fbz4HHwMaHHXadow1jIyMk8CWVKXt)o)UAjfExYUmvynGlLK(1XL)KmGp8GoLzaT6kl0s6VWddTmbcdJb0SNksrZtX1OX3Nppiccan7PIu08uCnA8bOrJxsdOHhAgHQnVytwOFS4Eil0Eab9jg5y(6BDkIxeKXqltGWWyGbhR6ermtfEo4xY4PFNFxTKo4xY4PFNFxTtmp41EK)J0VoU8NKbEsxZtcjeglAEI2aP)cVacj1OXlWJZXmVZuHNSi(aWSRfr6xhx(tYae1wNYmGwDLfA)8jGqsnA8c84CmZ7mv4jlIpam7ArK(1XL)KmGp8GoLzaT6kl0(dP)cVaA1qvceqqBotfEI067ZNhebbagjLZuHNp0YhaMh8AVritYF)yX9qwO9ac6tmYXqiDySu6zHwlUhYcThqqFIrogcPdJLspl0ods23JfViiR5hebbaH0HXsPNfAbW8Gx7fBHS4Eil0Eab9jg5yCnMxxwlpXqNI4fbz49GiiaCnMxxwlpXqNcauKf3dzH2diOpXihdgjLZuHNp0YN4fb5b)sgp9787QDI5bV2J8FK(7dIGaaJKYzQWZhA5daZdETxSjR2pF(64YFsgaNVjMXiP8hlUGTg(tyTR1N1oMTgksCRVTIyRtf2A0YwpUsfRLOX8LwdhCQbG1QWJTEScVwRfvlmRj8lzS1PIVwRov2AntuHkTgHTECLkiO0AFfzT6uzalUhYcThqqFIroMbhRkRNei8uZEQiEquqYZ0XW48itI4fbzSx6j)L3eW16dakI0FthdJtGSg4zIM6IJDan8qZiuT5bOzIku5NpW7s2LPcRbWiyqmPb0WdnJq1MhGMjQqLJqoenh8ynViE1Qjj)yXfS1WFcRxK1UwFwpUKsR1fB94kvQ16uHTE5yLwR2)oXTg6yRvbeQH1O16h6oRhxPcckT2xrwRovgWI7HSq7be0NyKJzWXQY6jbcp1SNkIxeKXEPN8xEtaxRpGAhrT)PMyV0t(lVjGR1hGgc7zHwsH3LSltfwdGrWGysdOHhAgHQnpantuHkhHCiAo4XAEr8QvtsS4c2AvktEikTorwFI2G1W3kPSwywdgHz26XvQyTGUV1PynbcBTkWVKXwRs353vRf3dzH2diOpXihZxhx(tYIV(atw1skRf28IWmp)6BDkZt0ge)RlHyYWddTmbcdJbgCSQteXmv45GFjJN(D(D1(5taHKA04f4RV1PaG5bV2Bes(7ZNb)sgp9787QDI5bV2BeHS4c2Av4XwxR1KOMcbN1fH1cKJM11znuK1(QTEmA)pTo4rwpAlJHjsCRryR90A1cNyw)RqWjM1JRuXA1G9urkYAqfxJgF)yncB9yfETwf4xYyRvP787Q166SgkcWI7HSq7be0NyKJr1skRf28IWmlErq(RJl)jzGN018KqcHXIMNOnq6xhx(tYaQwszTWMxeM55xFRtzEI2aPW7s2LPcRbWiyqmP)Q5hebbWJZXmVZuHNSi(aGIiLxgdteGMjQqLJ8lVmgMiamdJxbfHeJeb5NpFUiwkNPJHX5b8KUMNesimw0i)kKA(Giia0SNksrZtX1OXhau0pF(m4xY4PFNFxTtmp41EJ83pwCpKfApGG(eJCmpPR5jg6ueVii)1XL)KmWt6AEsiHWyrZt0gi9xEzmmraznWZenh8ynIqF(CrSuothdJZBeH(XI7HSq7be0NyKJrJzx)KUMpXlcYW7s2LPcRbCPK0aA4HMrOAZl2KjXI7HSq7be0NyKJ5uCnA8al1IxeKH3LSltfwd4sjPFDC5pjd4dpOtzgqRUYcTwCpKfApGG(eJCmrOSqR4fb5hebbWtIqAj0Lay2d5NpefmLCI5bV2l2Q9VpFEqeeaUgZRlRLNyOtbakYI7HSq7be0NyKJ5jri9KaclYI7HSq7be0NyKJ5X4JXQwlmlUhYcThqqFIrogIcZpjcPT4Eil0Eab9jg5y8nWxID5m4sPfxWwRgmHdjtRdOvxzH2ZAce2AOZFs26k5HdWI7HSq7be0NyKJb64zL8WjErqgEyOLjqyymWGJvDIiMPcph8lz80VZVRws18dIGa4X5yM3zQWtweFaqrK(l8sxYBcatbDPu08sCPkdWR)KS(Zhn)GiiaGPGUukAEjUuLbGI(5ZNb)sgp9787QDI5bV2BK)(8HOGPKtmp41EXMSq)zXT4cwWwpkQTofgFwCpKfApaIARtH8jRap9vp1vGfVii)Giiaozf4PV6PUcmaMh8AVytuWuYjMh8ApsXmbMpf)jzlUGTwGC0SgTwhqiPgnETorwRkZrwNkS1QdxP1A(brqynuK4wdTs(oRtf260XW4066S2FiO06ezTUylUhYcTharT1Pig5yECoM5DMk8KfXN4fb50XW4eiRbEMOPU4ruRf3dzH2dGO26ueJCm66I8mOyXT4cwWwdMSltflUhYcThWLSltfY66I8mOiErq(RJl)jzaIARtzgqRUYcTwCpKfApGlzxMkIrogF4bDkwCpKfApGlzxMkIroMGc7rZtbLIhefK8mDmmopYKiErqoDjVjqeMfnr7mv45y2vfGx)jznPWlDmmobQB(q3rtAsPa]] )

end