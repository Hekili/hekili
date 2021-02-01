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


    spec:RegisterPack( "Outlaw", 20210125, [[d4eZ1aqiPk9icQUecrytGQ(ecPrbK6uavwfcr0RifMfH4wuIQDPs)IuQHbu1XiilJa9mkbtJGIUgqsBJuu8nkryCKIGZrjkwhqIMhLq3db7tQIdcKWcrOEiPetKuuDrsr0gjfjFKue6KieALusZKuu6MieLDsa)KGcdLGshfHOAPie8uatfu5QuIOTIqK6RuIsJLsK2lu)vkdwXHPAXQ4XumzsUmQnJOpdkJMuDAjRgHi51esZMOBlv2Ts)gYWPuhNuKA5i9CvnDHRdY2bkFhigpPKopHA(svTFrJfcdhgq5bJfqqWlOqGxibb1RGG3cwcliegieBZyaB3iQdJXaR3XyaHbuiDqWa2UyjYvy4WapcIAymGEe2pOuBTHvHo05AqDA)vhK0JcTgQtgA)vNrBmWbQKbrCXhmGYdglGGGxqHaVqccQxbbVfSecAzWaouOJOyaGQtlya9sP4fFWak(nyaHl8CegqH0bjhIacgeNwfUWZXQVqovCoccQIKJGGxqHWaY6JhdhgqXKoKmWWHfqimCya3efAXaIwgrXa86hjRWeJdSacIHddWRFKSctmgqXVHw2rHwmarG)GDzONtrMJn6)6i5Ca9IYbmi5Yu)i5C4L7k(ZP2CmOUJhGdd4MOqlg4d2LHooWcybmCyaE9JKvyIXaiBmWZbgWnrHwmayoT8JKXaG5sigdqJt7ars(5yXCemh4Zb050BohisYBqH42HDATWUq25aFo9MZbIK8EOix9LIVq25aomGIFdTSJcTyaIatrszoFTWKCohisYph2PsX5GcDMMtO7BoWrH4CiMDATWYXxvoetrU6lfJbaZPT17ymanonktrsjoWcimXWHb41pswHjgdGSXaphya3efAXaG50YpsgdaMlHymGb1DqnBuTXFvmzzQiNEiKJG5OrohisY7HIC1xk(czNd85WltHjoNEiKdOc(CGphqNtV5yqRcQIRbbTrl05gsP(lV(rYQC63pNdej5LIKYwOZTdA5)s5oV2pNEiKJqGphWHbu8BOLDuOfdOj3hIY5acNdmoYHeskZbu0DGE9C0IWMdmV2phFv54uEjAKdLPiPSwy5Ofe0g5e6CocdL6Z5ars(54G4IXaG5026DmgW7oqVEZGwvffAXbwaqfdhgGx)izfMymaYgd8CGbCtuOfdaMtl)izmayUeIXagu3b1Sr1gFo9qihJDRZ1A7T5vLJLNZbIK8EOix9LIVq25y55a6CoqKKxKTnIgqBfIVq25qKmNWL8gxnnuzeTPOoixE9JKv5aUC63phdQ7GA2OAJphc54B15gDNcJvnJngqXVHw2rHwmGMQ261ZXJC6CTwDqD5OfHnNduKJdgQu5aI)rTWYHykYvFP4C8vLdrouzenhnN6GKZbTqFogu3bLJnQ24XaG5026DmgGS261Bg0QQOqloWcOzWWHb41pswHjgdGSXaphya3efAXaG50YpsgdaMlHymWBZszlCkmo(7r6kUrkHOuX5yXCemh4ZH6LQXGXBCDL6V1Mtp5ii4ZPF)CoqKK3J0vCJucrPIVq2yaf)gAzhfAXaw2k0ZPdsgLTKZjCkmoErYj0RphWCA5hjNt95y0zJOSkNaLJInLIZbeDo0zAopQJZrlA(NZRJGKQCoCoV41WQCaPc9Ciw6kohnLeIsfJbaZPT17ymWr6kUrkHOuXTx8AWbwalbgomaV(rYkmXyadTcMwog4d2LHoRUUuIbCtuOfdqH2MBIcTnz9bgqwF0wVJXaFWUm0XbwanbmCyaE9JKvyIXaUjk0IbmUu2CtuOTjRpWaY6J26DmgWOECGfWYGHddWRFKSctmgWqRGPLJbaZPLFK8LS261Bg0QQOqlgWnrHwmafABUjk02K1hyaz9rB9ogdqwB964alGqGhdhgGx)izfMymGBIcTyaJlLn3efABY6dmGS(OTEhJboqLuHdSacjegomaV(rYkmXyadTcMwogGxMct8vXKLPIC6HqocbQ5Oro8YuyIVuggVya3efAXao14l3ceLYBGdSacjigomGBIcTyaNA8LB2qYNXa86hjRWeJdSaczbmCya3efAXaYcME8nIuqkyD8gyaE9JKvyIXbwaHeMy4WaUjk0IbooSgISf0Yi6Jb41pswHjgh4adytzdQ74bgoSacHHdd4MOqlgWTTLIB2O6rlgGx)izfMyCGfqqmCya3efAXahuesw1iLUywbsTWAbsR1Ib41pswHjghybSagomGBIcTyGpyxg6yaE9JKvyIXbwaHjgomaV(rYkmXya3efAXaDovuw1ir0MI9qhdyOvW0YXauVungmEJRRu)T2C6jhbbvmGnLnOUJhTNnOv9yaqfhybavmCyaE9JKvyIXaUjk0IbOiPSf6C7Gw(XagAfmTCmaL78A)CSyowadytzdQ74r7zdAvpgqqCGfqZGHddWRFKSctmgWnrHwmWlld38v1uLHXagAfmTCmaLjP8R7hjJbSPSb1D8O9SbTQhdiioWbg4avsfgoSacHHdd4MOqlg4z7VEmaV(rYkmX4alGGy4WaUjk0IbGPJ(qkU9bTeLXa86hjRWeJdSawadhgGx)izfMymGHwbtlhdqHwMerHX3OwXTaP1Y0osxXxE9JKvya3efAXaVEbgoWcimXWHbCtuOfdWgDuTWAu2MwD(QWa86hjRWeJdSaGkgomaV(rYkmXya3efAXaptPEWQ2bTC7TlrzmGHwbtlhd0BokuCFMs9GvTdA52BxIY3OmIwlSC63ph3efyCJxUR4phc5iuoWNd1lvJbJ346k1FRnNEYHeskBu2O7uyClQooN(9ZXO7uy8Ntp5iyoWNdzbtpAuUZR9ZXI5aQyaJyJKBHtHXXJfqiCGfqZGHddWRFKSctmgWnrHwmGD9bs2EDuGbu8BOLDuOfdyjFohHT(ajZbqhf5asf65imSTr0aARqCofzoAb1D8ihHff8AeNdiOLOroiWyQXTZHxMctSi5aIoV5uroGuszoSwDtifNJXTZrlcRi5GO5aIoV5a91clhICOYiAoAo1bbdyOvW0YXahisYlY2grdOTcXxi7CGphqNdVmfM4RIjltf50toGohEzkmXxkdJ3C0ihHaFoGlN(9ZXG6oOMnQ24VkMSmvKJfjKJq5OrohisY7HIC1xk(czNt)(5eUK34QPHkJOnf1b5YRFKSkhWHdSawcmCyaE9JKvyIXagAfmTCmWbIK8ISTr0aARq8fYoh4Zb05CGijVWOmVVO1(nqkJOm9Vq250VFohisYRbTg2LSQDKqRIPhO)Vq25aomGBIcTya76dKS96Oahyb0eWWHbCtuOfd81wFW02h0sugdWRFKSctmoWcyzWWHb41pswHjgdyOvW0YXaHl5nUQIgIBbTmI(xE9JKv5aFogu3b1Sr1g)vXKLPIC6HqocLJg5CGijVhkYvFP4lKngWnrHwmameemgh4adyupgoSacHHddWRFKSctmgWnrHwmWr6kUrkHOuXyaf)gAzhfAXaelDfNJMscrPIZbT5iOg5Wl3v8Jbm0kyA5yG3MLYw4uyC850dHCemh4ZP3CoqKK3J0vCJucrPIVq24alGGy4Wa86hjRWeJbCtuOfdaMV1RJbu8BOLDuOfdyj)AHLdOO7a965uFoEocsKiNAnu2FwKCEuoeP9TE9Cm(MZHZ5rDCuD8NZHZb6zvo(NJNduuYkeNZBZszoqRK)phOVwy5qK5FW0Caf)7)xBoiAoAo7HUuCoa6UcbYJbm0kyA5yGEZHcTmjIcJVDov0gISf6CRZ)GPn)F))AV86hjRYb(C6nNpyxg6S66szoWNdyoT8JKVE3b61Bg0QQOqBoWNdOZP3COqltIOW4RI9qxkU96UcbYF51pswLt)(5CGijVk2dDP42R7kei)vHazZb(CmOUdQzJQn(CSiHCemhWHdSawadhgGx)izfMymGHwbtlhdqHwMerHX3oNkAdr2cDU15FW0M)V)FTxE9JKv5aFoD(hmT5)7)xBJYDETFoeYb85aFoG50Yps(EKUIBKsikvC7fVMCGphqNtV5yqiPcbYEpCacZBl05glM)lLDL4CGphWCA5hjFjRTE9MbTQkk0Mt)(5yqiPcbYEpCacZBl05glM)lLDL4CGphWCA5hjF9Ud0R3mOvvrH2CaxoWNdOZP3CmOvbvX1GG2Of6CdPu)Lx)izvo97NZbIK8srszl052bT8FPCNx7NtpeYriWNd4WaUjk0IbaZ361XbwaHjgomGBIcTyasPdJLspk0Ib41pswHjghybavmCyaE9JKvyIXagAfmTCmGIpqKKxsPdJLspk0EPCNx7NJfZrqmGBIcTyasPdJLspk02ms23NXbwandgomaV(rYkmXyadTcMwogO3CoqKKxxr51L1Ynk0RFHSZb(CaDo9MJbHKkei7v0skRfw7TPmFHSZPF)C6nNWL8gxrlPSwyT3MY8Lx)izvoGdd4MOqlgWvuEDzTCJc964alGLadhgGx)izfMymGHwbtlhd05FW0M)V)FTnk351(5qihWNd85a6CoqKKxkskBHo3oOL)lL78A)CSiHCSqo97NdyoT8JKV040OmfjL5aomGBIcTyakskBHo3oOLFCGfqtadhgGx)izfMymGBIcTyGoNkkRAKiAtXEOJbmInsUfofghpwaHWagAfmTCma1lvJbJ346k1FHSZb(CaDoHtHXXnQoUfOMQ4CSyogu3b1Sr1g)vXKLPIC63pNEZ5d2LHoRUuemioh4ZXG6oOMnQ24VkMSmvKtpeYXy36CT2EBEv5y55iuoGddO43ql7OqlgGisMJRuFooLZbYwKC(TS5CcDoh0Y5asf65irGWFKdCWP53CSKpNdi68MJsCTWYH0)GP5e6(MJwe2CumzzQihenhqQqhbf54R4C0IWEXbwaldgomaV(rYkmXya3efAXaDovuw1ir0MI9qhdO43ql7OqlgGisMZIYXvQphqkPmhvX5asf61MtOZ5SSwJCSa4FrYb65CiYi18CqBoh0)5asf6iOihFfNJwe2lgWqRGPLJbOEPAmy8gxxP(BT50towa85y55q9s1yW4nUUs9xfe1JcT5aFo9MZhSldDwDPiyqCoWNJb1DqnBuTXFvmzzQiNEiKJXU15AT928QYXYZriCGfqiWJHddWRFKSctmgWqRGPLJbaZPLFK89iDf3iLquQ42lEn5aFoGohEzkmX3O64wGADUwZPNCemN(9Z5TzPSfofghFo9KJG5aomGBIcTyarlPSwyT3MYmoWciKqy4Wa86hjRWeJbm0kyA5yaWCA5hjFpsxXnsjeLkU9IxtoWNdOZHxMct8nQoUfOwNR1C6jhbZPF)CEBwkBHtHXXNtp5iyoGdd4MOqlg4iDf3OqVooWciKGy4Wa86hjRWeJbm0kyA5yGEZ5d2LHoRUUuMd85yqDhuZgvB85yrc5iegWnrHwmGIYU6iDf)4alGqwadhgGx)izfMymGHwbtlhd0BoFWUm0z11LYCGphWCA5hjF9Ud0R3mOvvrHwmGBIcTyGx3viq6yPchybesyIHddWRFKSctmgWqRGPLJboqKK3JeHusOpUu2nro97NdzbtpAuUZR9ZXI5ybWNt)(5CGijVUIYRlRLBuOx)czJbCtuOfdyJIcT4alGqGkgomGBIcTyGJeHunsiQymaV(rYkmX4alGqAgmCya3efAXahM(mv0AHHb41pswHjghybeYsGHdd4MOqlgGSO8rIqkmaV(rYkmX4alGqAcy4WaUjk0Ib81WFqDzZ4sjgGx)izfMyCGfqildgomaV(rYkmXya3efAXaqp3QG7EmGIFdTSJcTyanNjDizKJbTQkk0(5qIO5a9(rY5ub39xmGHwbtlhd0BouOLjruy8TZPI2qKTqNBD(hmT5)7)x7Lx)izvoWNJIpqKK3dhGW82cDUXI5)czNd85a6C6nNWL8gxy6OpKIBFqlr5lV(rYQC63phfFGijVW0rFif3(GwIYxi7Caxo97NtN)btB()()12OCNx7Ntp5a(C63phYcME0OCNx7NJfjKJGGhh4ad8b7YqhdhwaHWWHb41pswHjgdyOvW0YXaG50Yps(swB96ndAvvuOfd4MOqlgqvVThgDCGfqqmCya3efAXaE3b61Xa86hjRWeJdSawadhgGx)izfMymGBIcTyaJo72TxhfyadTcMwogiCjVX1MYIBOTf6Cde2f9YRFKSkh4ZP3CcNcJJB9Td6FmGrSrYTWPW44XcieoWbgGS261XWHfqimCyaE9JKvyIXagAfmTCmWbIK8(YYWnFvnvz4lL78A)CSyoKfm9Or5oV2ph4ZHYKu(19JKXaUjk0IbEzz4MVQMQmmoWciigomaV(rYkmXya3efAXahoaH5Tf6CJfZpgqXVHw2rHwmaXHMmh0MJbHKkeiBobkhrz2oNqNZrl0kYrXhisYCGSfjhOvY)NtOZ5eofgh5uFo(bbf5eOCufJbm0kyA5yGWPW44gvh3cutvCo9KJfWbwalGHdd4MOqlgqvVThgDmaV(rYkmX4ah4adagt)cTybee8cke4fsqHjgaeNU1c7XawwqbrqaIOaAIGYCYboDoNQZgrJCir0CiQIjDizq0COSMgQOSkNh1X54qbQZdwLJr3xy8FtRA2A5CeMGYC0cAbJPbRYHOg0QGQ4APenNaLdrnOvbvX1sV86hjRiAoGwiTcUBAnTAzbfebbiIcOjckZjh405CQoBenYHerZHOg1t0COSMgQOSkNh1X54qbQZdwLJr3xy8FtRA2A5CeeuMJwqlymnyvoeLcTmjIcJVwkrZjq5quk0YKikm(APxE9JKvenhqlOwb3nTQzRLZXcGYC0cAbJPbRYHOuOLjruy81sjAobkhIsHwMerHXxl9YRFKSIO5aAH0k4UPvnBTCowauMJwqlymnyvoe1GwfufxlLO5eOCiQbTkOkUw6Lx)izfrZb0cPvWDtRA2A5CeYYakZrlOfmMgSkhIsHwMerHXxlLO5eOCikfAzsefgFT0lV(rYkIMdOfsRG7MwtRwwqbrqaIOaAIGYCYboDoNQZgrJCir0Ci6bQKkIMdL10qfLv58OoohhkqDEWQCm6(cJ)BAvZwlNJfaL5Of0cgtdwLdrPqltIOW4RLs0CcuoeLcTmjIcJVw6Lx)izfrZXJC0KcdnBoGwiTcUBAnTse7Sr0Gv5OzYXnrH2CK1h)nTIbEB2Gfqqnd4Xa2uezjzmGWfEocdOq6GKdrabdItRcx45y1xiNkohbbvrYrqWlOqP10QWfEoAsTYgOGv5CyseLZXG6oEKZHHv7FZbuymSD85SO1Y1DAhjKmh3efA)CqRu8nT6MOq7FTPSb1D8GGBBlf3Sr1J20QBIcT)1MYgu3XdniO9bfHKvnsPlMvGulSwG0ATPv3efA)RnLnOUJhAqq7pyxg6Pv3efA)RnLnOUJhAqq7oNkkRAKiAtXEOlInLnOUJhTNnOv9eavrkscuVungmEJRRu)T2EeeutRUjk0(xBkBqDhp0GG2uKu2cDUDql)IytzdQ74r7zdAvpbbfPijq5oV23IwiT6MOq7FTPSb1D8qdcA)YYWnFvnvzyrSPSb1D8O9SbTQNGGIuKeOmjLFD)i50AAv4cphnPwzduWQCyWyQ4CIQJZj05CCtGO5uFooyEj9JKVPv3efAFcIwgrtRcphIa)b7YqpNImhB0)1rY5a6fLdyqYLP(rY5Wl3v8NtT5yqDhpaxA1nrH2xdcA)b7YqpTk8CicmfjL581ctY5CGij)CyNkfNdk0zAoHUV5ahfIZHy2P1clhFv5qmf5QVuCA1nrH2xdcAdMtl)izrwVJjqJtJYuKukcyUeIjqJt7ars(wuq4bDVhisYBqH42HDATWUq2W37bIK8EOix9LIVq2GlTk8C0K7dr5CaHZbgh5qcjL5ak6oqVEoAryZbMx7NJVQCCkVenYHYuKuwlSC0ccAJCcDohHHs95CGij)CCqCXPv3efAFniOnyoT8JKfz9oMG3DGE9MbTQkk0kcyUeIjyqDhuZgvB8xftwMk6HGGACGijVhkYvFP4lKn88YuyI7HaOcE4bDVg0QGQ4AqqB0cDUHuQVF)dej5LIKYwOZTdA5)s5oV2VhccbEWLwfEoAQARxphpYPZ1A1b1LJwe2CoqrooyOsLdi(h1clhIPix9LIZXxvoe5qLr0C0CQdsoh0c95yqDhuo2OAJpT6MOq7RbbTbZPLFKSiR3XeiRTE9MbTQkk0kcyUeIjyqDhuZgvB89qWy36CT2EBEvw(bIK8EOix9LIVq2woOpqKKxKTnIgqBfIVq2ejdxYBC10qLr0MI6GC51pswbU(9nOUdQzJQnEc(wDUr3PWyvZyNwfEow2k0ZPdsgLTKZjCkmoErYj0RphWCA5hjNt95y0zJOSkNaLJInLIZbeDo0zAopQJZrlA(NZRJGKQCoCoV41WQCaPc9Ciw6kohnLeIsfNwDtuO91GG2G50YpswK17ychPR4gPeIsf3EXRreWCjet4TzPSfofgh)9iDf3iLquQylki8uVungmEJRRu)T2Eee897FGijVhPR4gPeIsfFHStRUjk0(AqqBk02CtuOTjRpez9oMWhSldDrkscFWUm0z11LY0QBIcTVge024szZnrH2MS(qK17ycg1NwDtuO91GG2uOT5MOqBtwFiY6DmbYARxxKIKayoT8JKVK1wVEZGwvffAtRUjk0(AqqBJlLn3efABY6drwVJjCGkPkT6MOq7RbbTDQXxUfikL3qKIKaVmfM4RIjltf9qqiqvdEzkmXxkdJ30QBIcTVge02PgF5MnK850QBIcTVge0wwW0JVrKcsbRJ3iT6MOq7RbbTpoSgISf0Yi6NwtRcx45qmujvm9tRUjk0(3dujveE2(RpT6MOq7FpqLuPbbTHPJ(qkU9bTeLtRUjk0(3dujvAqq7xVatKIKafAzsefgFJAf3cKwlt7iDfNwDtuO9VhOsQ0GG2SrhvlSgLTPvNVQ0QBIcT)9avsLge0(zk1dw1oOLBVDjklIrSrYTWPW44jiKifjHEvO4(mL6bRAh0YT3UeLVrzeTwy977MOaJB8YDf)eecEQxQgdgVX1vQ)wBpKqszJYgDNcJBr1X97B0Dkm(7rq4jly6rJYDETVfb10QWZXs(CocB9bsMdGokYbKk0ZryyBJOb0wH4CkYC0cQ74roclk41iohqqlrJCqGXuJBNdVmfMyrYbeDEZPICaPKYCyT6MqkohJBNJwewrYbrZbeDEZb6Rfwoe5qLr0C0CQdsA1nrH2)EGkPsdcABxFGKTxhfIuKeoqKKxKTnIgqBfIVq2WdAEzkmXxftwMk6b08YuyIVuggVAie4bx)(gu3b1Sr1g)vXKLPclsqinoqKK3df5QVu8fYUF)WL8gxnnuzeTPOoixE9JKvGlT6MOq7FpqLuPbbTTRpqY2RJcrkschisYlY2grdOTcXxiB4b9bIK8cJY8(Iw73aPmIY0)cz3V)bIK8AqRHDjRAhj0Qy6b6)lKn4sRUjk0(3dujvAqq7V26dM2(GwIYPv3efA)7bQKkniOnmeemwKIKq4sEJRQOH4wqlJO)Lx)izf8gu3b1Sr1g)vXKLPIEiiKghisY7HIC1xk(czNwtRcx45OfesQqGSFAv45qS0vCoAkjeLkoh0MJGAKdVCxXFA1nrH2)AupHJ0vCJucrPIfPij82Su2cNcJJVhcccFVhisY7r6kUrkHOuXxi70QWZXs(1clhqr3b61ZP(C8CeKiro1AOS)Si58OCis7B965y8nNdNZJ64O64pNdNd0ZQC8phphOOKvioN3MLYCGwj)FoqFTWYHiZ)GP5ak(3)V2Cq0C0C2dDP4Ca0DfcKpT6MOq7FnQxdcAdMV1RlsrsOxk0YKikm(25urBiYwOZTo)dM28)9)Rf(E)GDzOZQRlLWdMtl)i5R3DGE9MbTQkk0cpO7LcTmjIcJVk2dDP42R7keiF)(hisYRI9qxkU96UcbYFviqw4nOUdQzJQnElsqqWLwDtuO9Vg1RbbTbZ361fPijqHwMerHX3oNkAdr2cDU15FW0M)V)FTW35FW0M)V)FTnk351(eap8G50Yps(EKUIBKsikvC7fVg4bDVgesQqGS3dhGW82cDUXI5)szxjgEWCA5hjFjRTE9MbTQkk02VVbHKkei79WbimVTqNBSy(Vu2vIHhmNw(rYxV7a96ndAvvuOfCWd6EnOvbvX1GG2Of6CdPuF)(hisYlfjLTqNBh0Y)LYDETFpeec8GlT6MOq7FnQxdcAtkDySu6rH20QBIcT)1OEniOnP0HXsPhfABgj77ZIuKeu8bIK8skDySu6rH2lL78AFlkyA1nrH2)AuVge02vuEDzTCJc96IuKe69arsEDfLxxwl3OqV(fYgEq3RbHKkei7v0skRfw7TPmFHS73V3WL8gxrlPSwyT3MY8Lx)izf4sRUjk0(xJ61GG2uKu2cDUDql)IuKe68pyAZ)3)V2gL78AFcGhEqFGijVuKu2cDUDql)xk351(wKGf63hmNw(rYxACAuMIKsWLwfEoerYCCL6ZXPCoq2IKZVLnNtOZ5GwohqQqphjce(JCGdon)MJL85CarN3CuIRfwoK(hmnNq33C0IWMJIjltf5GO5asf6iOihFfNJwe2BA1nrH2)AuVge0UZPIYQgjI2uSh6IyeBKClCkmoEccjsrsG6LQXGXBCDL6Vq2Wd6WPW44gvh3cutvSfnOUdQzJQn(RIjltf9737hSldDwDPiyqm8gu3b1Sr1g)vXKLPIEiySBDUwBVnVklxiWLwfEoerYCwuoUs95asjL5OkohqQqV2CcDoNL1AKJfa)lsoqpNdrgPMNdAZ5G(phqQqhbf54R4C0IWEtRUjk0(xJ61GG2Dovuw1ir0MI9qxKIKa1lvJbJ346k1FRThlaElN6LQXGXBCDL6VkiQhfAHV3pyxg6S6srWGy4nOUdQzJQn(RIjltf9qWy36CT2EBEvwUqPv3efA)Rr9AqqBrlPSwyT3MYSifjbWCA5hjFpsxXnsjeLkU9Ixd8GMxMct8nQoUfOwNR1EeSF)3MLYw4uyC89ii4sRUjk0(xJ61GG2hPR4gf61fPijaMtl)i57r6kUrkHOuXTx8AGh08YuyIVr1XTa16CT2JG97)2Su2cNcJJVhbbxA1nrH2)AuVge0wrzxDKUIFrksc9(b7YqNvxxkH3G6oOMnQ24TibHsRUjk0(xJ61GG2VURqG0XsLifjHE)GDzOZQRlLWdMtl)i5R3DGE9MbTQkk0MwDtuO9Vg1RbbTTrrHwrkschisY7rIqkj0hxk7MOFFYcME0OCNx7Brla((9pqKKxxr51L1Ynk0RFHStRUjk0(xJ61GG2hjcPAKquXPv3efA)Rr9Aqq7dtFMkATWsRUjk0(xJ61GG2KfLpsesLwDtuO9Vg1RbbT91WFqDzZ4szAv45O5mPdjJCmOvvrH2phsenhO3psoNk4U)MwDtuO9Vg1RbbTHEUvb39IuKe6LcTmjIcJVDov0gISf6CRZ)GPn)F))AHxXhisY7HdqyEBHo3yX8FHSHh09gUK34cth9HuC7dAjkF51psw1VVIpqKKxy6OpKIBFqlr5lKn463VZ)GPn)F))ABuUZR97b897twW0JgL78AFlsqqWNwtRcx45OPQTEDM(Pv3efA)lzT1Rt4LLHB(QAQYWIuKeoqKK3xwgU5RQPkdFPCNx7BrYcME0OCNx7dpLjP8R7hjNwfEoehAYCqBogesQqGS5eOCeLz7CcDohTqRihfFGijZbYwKCGwj)FoHoNt4uyCKt954heuKtGYrvCA1nrH2)swB96Aqq7dhGW82cDUXI5xKIKq4uyCCJQJBbQPkUhlKwDtuO9VK1wVUge0wvVThg90AAv4cphGGDzONwDtuO9VFWUm0jOQ32dJUifjbWCA5hjFjRTE9MbTQkk0MwDtuO9VFWUm01GG2E3b61tRUjk0(3pyxg6AqqBJo72TxhfIyeBKClCkmoEccjsrsiCjVX1MYIBOTf6Cde2f9YRFKSc(EdNcJJB9Td6FCGdmga]] )

end