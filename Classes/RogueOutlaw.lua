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


    spec:RegisterPack( "Outlaw", 20210202, [[d8uL9aqiqupIOKlbIu1MqP6tGugfi0PabRIOu0RiKMfkXTiQKDPQ(LiLHbs1XiGLHs6zIuzAOuuxdeX2iQu9nIsjJtQkX5ikLADGizEsvX9iO9jvvheLclKa9qIQmruk1fjQQ2ikL4JGifNeLISsG4LGivMjrPQBkvLANef)KOuzOev4OeLclfLs6PaMki5QevKTkvL0xjQuglrvzVO6VszWkomLfRkpwutMuxgzZO4Za1OjYPfwnisPxtiMnj3we7wPFd1WLkhNOIA5qEUktxY1b12fjFxQY4fPQZtOMpqA)unxaouCaTvexgwHoRcaDwHoRFb6lPdsGeb4aL4oId0zzrmWehyTeIdi7GlL1Jd0zIvytZHIdCyyuM4asv1DqQ0sdCusWVFgNK2fjWkRc8MrgtL2fj504ap4qvSPL)4aARiUmScDwfa6ScDw)c0xshKWMHeoGbxsyehaisKhhqk0AA5poGMUmhqwYYhzhCPSE(WwXGHjhezjlFyl0dbBiX(Wkl(Wk0zvaoGkU64qXb0eJbRkouCzeGdfhWYvGxoGirweoaT2trAUG8IldRCO4a0ApfP5cYb00Lrrxf4LdWwPRitvs(em(0HVlEkYhiUyFsbRwczpf5dTusqNpX6tgN8SccCalxbE5axrMQK4fxM0XHIdqR9uKMliha3XboQ4awUc8YbszOWEkIdKYuWehavV2dMH58Pp(WQpS7de9bY(8Gzy(fcMApYqXc(d35d7(azFEWmm)hcB6l00hUZhiWb00Lrrxf4LdWwjewP85IfSI85bZWC(qgsj2hCjriFkjB9bkem5JGKHIfSp2Q9rqe20xOjoqkd1wlH4aO61qecRu8IldBMdfhGw7PinxqoaUJdCuXbSCf4LdKYqH9uehiLPGjoqgN8WToCS191etKJYN(f6dR(iQppygM)dHn9fA6d35d7(qlHal2N(f6dKaDFy3hi6dK9jJxnCu)mgERwjrnSwFFATNI0(akO(8Gzy(iSs1kjQ9WlDFeLyXE(0VqFea6(aboGMUmk6QaVCa5Fpye5tpYhWu5ddSs5dBK8GpjFKNC4dyl2ZhB1(yiAHw5dIqyLkwW(ipm8w(usKpYoT(85bZWC(y9mXCGugQTwcXbSKh8j1Y4vhvGxEXLbs4qXbO1EksZfKdG74ahvCalxbE5aPmuypfXbszkyIdKXjpCRdhBD(0VqFYDTel9TRJwTpYLppygM)dHn9fA6d35JC5de95bZW8XDDyubVrj(d35JSPpLPOT(Yz4ilstJSEFATNI0(abFafuFY4KhU1HJToFe6JTrILLmeys3YDCanDzu0vbE5aSLyJtYhR8jXsFKaN4J8KdFEWLpwkCO9PNDvSG9rqe20xOjFSv7JSbCKfXh2gz985Hx4ZNmo5H9PdhBDCGugQTwcXbyInoPwgV6Oc8YlUmYDouCaATNI0Cb5a4ooWrfhWYvGxoqkdf2trCGuMcM4axhPuTYqGP6(pLPPgJcgHe7tF8HvFy3hKf6gLI26BA99J1N(9HvO7dOG6ZdMH5)uMMAmkyes8hrjwSNp97Ja(iQpLPOT(IekvSGBxhIOpT2trAoGMUmk6QaVCa5wus(KaRQOtr(ugcmvhl(usX5tkdf2tr(eNpzjklcP9PW(OPCOjF6jrLeH85WjKpYJTpFojmSs7ZJ85eVzs7tVOK8rqLPjFylkyesmhiLHARLqCGNY0uJrbJqIBN4nZlUmYwCO4a0ApfP5cYbYOOiuyCGRitvsK(BkfhWYvGxoacEBwUc82uXvCavCvBTeIdCfzQsIxCz6lCO4a0ApfP5cYbSCf4LdKnLQz5kWBtfxXbuXvT1sioqwF8IlJSnhkoaT2trAUGCGmkkcfghiLHc7POptSXj1Y4vhvGxoGLRaVCae82SCf4TPIR4aQ4Q2AjehGj24K4fxgbGohkoaT2trAUGCalxbE5aztPAwUc82uXvCavCvBTeId8GdLMxCzeqaouCaATNI0Cb5azuuekmoaTecS4VMyICu(0VqFeas8ruFOLqGf)reyA5awUc8Ybmu2wQvyeI2IxCzeGvouCalxbE5agkBl16GvhXbO1EksZfKxCzeiDCO4awUc8YbubyP6AqAH1GtOT4a0ApfP5cYlUmcWM5qXbSCf4Ld8mWnmtRqrwKJdqR9uKMliV4fhOdrzCYZkouCzeGdfhWYvGxoG11Pe36WXHxoaT2trAUG8IldRCO4awUc8YbE4QuKUXOmXKUxSGBfo9XYbO1EksZfKxCzshhkoGLRaVCGRitvsCaATNI0Cb5fxg2mhkoaT2trAUGCalxbE5ajgses3yWOMMSsIdKrrrOW4ail0nkfT13067hRp97dRqchOdrzCYZQ2rz8QpoaKWlUmqchkoaT2trAUGCalxbE5aiSs1kjQ9WlDCGmkkcfgharjwSNp9XN0Xb6qugN8SQDugV6JdWkV4Yi35qXbO1EksZfKdy5kWlh4urMA2QB6itCGmkkcfgharmi6KSNI4aDikJtEw1okJx9XbyLx8Id8GdLMdfxgb4qXbSCf4LdCu3fhhGw7PinxqEXLHvouCalxbE5aGLWxPe3UcfIqCaATNI0Cb5fxM0XHIdqR9uKMlihiJIIqHXbqWlXGrGPFfR4wHtFKBpLPPpT2trAoGLRaVCGtksXlUmSzouCalxbE5auwchl4gI6qrITAoaT2trAUG8IldKWHIdqR9uKMlihWYvGxoWriKvKU9Wl1UUqeIdKrrrOW4aq2hnU(hHqwr62dVu76crOFfzrIfSpGcQpwUIuuJwkjOZhH(iGpS7dYcDJsrB9nT((X6t)(WaRuneLLmeyQvrc5dOG6twYqGPZN(9HvFy3hMaSu1quIf75tF8bs4azXzf1kdbMQJlJa8IlJCNdfhGw7PinxqoGLRaVCGU4kSQDs4IdOPlJIUkWlhqoDKpYrCfw5dGeU8Pxus(i766WOcEJsSpbJpYdN8SYh5ax0Mf7tp8cTYhCkcLToFOLqGfZIp9KO1NO8PxOu(qP3YLsSpzRZh5jhS4dg5tpjA9b(IfSpYgWrweFyBK1JdKrrrOW4apygMpURdJk4nkXF4oFy3hi6dTecS4VMyICu(0Vpq0hAjeyXFebMwFe1hbGUpqWhqb1Nmo5HBD4yR7RjMihLp9rOpc4JO(8Gzy(pe20xOPpCNpGcQpLPOT(Yz4ilstJSEFATNI0(abEXLr2IdfhGw7PinxqoqgffHcJd8Gzy(4UomQG3Oe)H78HDFGOppygMpyer7jsSxRxKfHq3hUZhqb1NhmdZpJ3mzks3Ek4vtOh8DF4oFGahWYvGxoqxCfw1ojCXlUm9fouCalxbE5axSXveQDfkeH4a0ApfP5cYlUmY2CO4a0ApfP5cYbYOOiuyCGYu0wFDGkXTcfzrUpT2trAFy3Nmo5HBD4yR7RjMihLp9l0hb8ruFEWmm)hcB6l00hUJdy5kWlhamggmXlEXbY6Jdfxgb4qXbO1EksZfKdy5kWlh4Pmn1yuWiKyoGMUmk6QaVCabvMM8HTOGriX(GxFyvuFOLsc64azuuekmoW1rkvRmeyQoF6xOpS6d7(azFEWmm)NY0uJrbJqI)WD8IldRCO4a0ApfP5cYbSCf4LdKY24K4aA6YOORc8YbKtxSG9HnsEWNKpX5J5dRq69j2mISJyXNd7tF124K8jBRppYNdNqvKqNppYh4J0(yNpMpWvOIsSpxhPu(aVk6oFGVyb7tFBxriFyJ7S7I1hmYh2MSssj2hajtJ7DCGmkkcfghaY(GGxIbJat)edjsdZ0kjQLyxrOMDNDxSFATNI0(WUpq2NRitvsK(BkLpS7tkdf2trFl5bFsTmE1rf41h29bI(azFqWlXGrGPVMSssjUDsMg37(0ApfP9buq95bZW81KvskXTtY04E3xJ7T(WUpzCYd36WXwNp9rOpS6de4fxM0XHIdqR9uKMliha3XboQ4awUc8YbszOWEkIdKYqT1sioqkBJtQLyTmE1rf4LdKrrrOW4ai4LyWiW0pXqI0WmTsIAj2veQz3z3f7Nw7PiTpS7dK9PmfT1pXqIq6gdg10KvsFATNI0CanDzu0vbE5aYTOK8PVTRiKpSXDNDxSS4ZjEZ(0xTnojF6fLKpMpmXgNeH8bJ8HnsEWNKpAQJwDSG9bV(iyj)(KXyLg3BzXhmYht1ZeF(y(WeBCseYNErj5tFZW2CGuMcM4aq0hi7tgJvACV9)OQhrBRKOgjMUpImTyFy3NugkSNI(mXgNulJxDubE9bc(akO(arFYySsJ7T)hv9iABLe1iX09rKPf7d7(KYqH9u03sEWNulJxDubE9bc8IldBMdfhGw7PinxqoaUJdCuXbSCf4LdKYqH9uehiLPGjoqkdf2trFMyJtQLXRoQaVCGmkkcfghabVedgbM(jgsKgMPvsulXUIqn7o7Uy)0ApfP9HDFktrB9tmKiKUXGrnnzL0Nw7PinhiLHARLqCGu2gNulXAz8QJkWlV4YajCO4a0ApfP5cYbYOOiuyCGugkSNI(PSnoPwI1Y4vhvGxFy3Ne7kc1S7S7ITHOel2ZhH(aDFy3NugkSNI(pLPPgJcgHe3oXBMdy5kWlhiLTXjXlUmYDouCalxbE5amkdmPuwf4LdqR9uKMliV4YiBXHIdqR9uKMlihiJIIqHXb00dMH5ZOmWKszvG3pIsSypF6JpSYbSCf4LdWOmWKszvG3wwr2EeV4Y0x4qXbO1EksZfKdKrrrOW4aq2NhmdZ30iAnvSudbFsF4ooGLRaVCatJO1uXsne8jXlUmY2CO4a0ApfP5cYbYOOiuyCGe7kc1S7S7ITHOel2ZhH(aDFy3hi6ZdMH5JWkvRKO2dV09ruIf75tFe6t68buq9jLHc7POpQEneHWkLpqGdy5kWlhaHvQwjrThEPJxCzea6CO4a0ApfP5cYbSCf4LdKyiriDJbJAAYkjoqwCwrTYqGP64YiahiJIIqHXbqwOBukARVP13hUZh29bI(ugcmv)ksOwHB6G8Pp(KXjpCRdhBDFnXe5O8buq9bY(CfzQsI0Fegmm5d7(KXjpCRdhBDFnXe5O8PFH(K7Ajw6BxhTAFKlFeWhiWb00Lrrxf4LdWMy8X06Zhdr(a3XIp3gDKpLe5dEjF6fLKpkCp6kFGck2(7JC6iF6jrRpAXXc2hg7kc5tjzRpYto8rtmrokFWiF6fLegU8XwX(ip54ZlUmciahkoaT2trAUGCalxbE5ajgses3yWOMMSsIdOPlJIUkWlhGnX4ZI9X06ZNEHs5JoiF6fLuS(usKplL(YN0b9JfFGpYN(MHT9bV(8W35tVOKWWLp2k2h5jhFoqgffHcJdGSq3Ou0wFtRVFS(0VpPd6(ix(GSq3Ou0wFtRVVggzvGxFy3hi7ZvKPkjs)ryWWKpS7tgN8WToCS191etKJYN(f6tURLyPVDD0Q9rU8raEXLraw5qXbO1EksZfKdG74ahvCalxbE5aPmuypfXbszkyIdazFqWlXGrGPFIHePHzALe1sSRiuZUZUl2pT2trAFafuFYySsJ7T)u2gN0hrjwSNp97Jaq3hqb1Ne7kc1S7S7ITHOel2ZN(9HvoGMUmk6QaVCa2OkkPR8PW(CI3Spq6cLkwW(a0HiYNErj5tF124K8HbJ8PVTRiKpSXD2DXYbszO2AjehqKqPIfC76qe1szBCsTt8M5fxgbshhkoaT2trAUGCalxbE5aIekvSGBxhIioGMUmk6QaVCa50r(eRpcixScLpbJpcwYVpX5dCNp2Q9PhEHw5t268r(xcbwml(Gr(yLpPdkr9bIScLO(0lkjFyBYkjLyFaKmnU3bbFWiF6jrRp9TDfH8HnUZUlwFIZh4UphiJIIqHXbszOWEk6)uMMAmkyesC7eVzFy3NugkSNI(IekvSGBxhIOwkBJtQDI3SpS7dK95kYuLeP)imyyYh29bI(OPhmdZ)rvpI2wjrnsmDF4oFy3hAjeyXFnXe5O8PFFGOp0siWI)icmT(iB6dR(iQpcaj(abFafuFUosPALHat19Fkttngfmcj2N(9bI(WQpYLppygMVMSssjUDsMg37(WD(abFafuFsSRiuZUZUl2gIsSypF63hO7de4fxgbyZCO4a0ApfP5cYbYOOiuyCGugkSNI(pLPPgJcgHe3oXB2h29bI(qlHal(xrc1kClXsVp97dR(akO(CDKs1kdbMQZN(9HvFGahWYvGxoWtzAQHGpjEXLraiHdfhGw7PinxqoqgffHcJdazFUImvjr6VPu(WUpzCYd36WXwNp9rOpcWbSCf4LdOrKPFktthV4YiGCNdfhGw7PinxqoqgffHcJdazFUImvjr6VPu(WUpPmuypf9TKh8j1Y4vhvGxoGLRaVCGtY04EjKsZlUmciBXHIdqR9uKMlihiJIIqHXbEWmm)NcJ1k4R(iYYLpGcQpmbyPQHOel2ZN(4t6GUpGcQppygMVPr0AQyPgc(K(WDCalxbE5aD4kWlV4YiqFHdfhWYvGxoWtHX6gdmsmhGw7PinxqEXLrazBouCalxbE5apcDesKybZbO1EksZfKxCzyf6CO4awUc8Ybyce9uySMdqR9uKMliV4YWQaCO4awUc8YbSntxHmvlBkfhGw7PinxqEXLHvw5qXbO1EksZfKdy5kWlha(OwuuYXb00Lrrxf4LdW2eJbRkFY4vhvG3ZhgmYh4ZEkYNOOK7ZbYOOiuyCai7dcEjgmcm9tmKinmtRKOwIDfHA2D2DX(P1Eks7d7(OPhmdZ)rvpI2wjrnsmDF4oFy3hi6dK9PmfT1hSe(kL42vOqe6tR9uK2hqb1hn9Gzy(GLWxPe3UcfIqF4oFGGpGcQpj2veQz3z3fBdrjwSNp97d09buq9HjalvneLyXE(0hH(Wk05fV4axrMQK4qXLraouCaATNI0Cb5azuuekmoqkdf2trFMyJtQLXRoQaVCalxbE5a646SklXlUmSYHIdy5kWlhWsEWNehGw7PinxqEXLjDCO4a0ApfP5cYbSCf4LdKLiRRDs4IdKrrrOW4aLPOT(DisCdVTsIA9itKpT2trAFy3hi7tziWu9JR9W3XbYIZkQvgcmvhxgb4fV4amXgNehkUmcWHIdqR9uKMlihiJIIqHXbEWmm)tfzQzRUPJm9ruIf75tF8HjalvneLyXE(WUpiIbrNK9uehWYvGxoWPIm1Sv30rM4fxgw5qXbO1EksZfKdy5kWlh4rvpI2wjrnsmDCanDzu0vbE5acwYVp41NmgR04ERpf2hriQZNsI8rEOO8rtpyggFG7yXh4vr35tjr(ugcmv(eNp2ddx(uyF0bXbYOOiuyCGYqGP6xrc1kCthKp97t64fxM0XHIdy5kWlhqhxNvzjoaT2trAUG8Ix8IdKIqxGxUmScDwfa6cKob4a9m0gl4Jdi3yd2QmSjzG0aP8XhOKiFIKomQ8HbJ8bAAIXGvf08brYz4arAFoCc5Jbx4eRiTpzjBbt33br2hl5dBgs5J8WBkcvK2hOLXRgoQV8bnFkSpqlJxnCuF57tR9uKgA(arbspe(oioiYn2GTkdBsginqkF8bkjYNiPdJkFyWiFGwwFqZhejNHdeP95WjKpgCHtSI0(KLSfmDFhezFSKpScP8rE4nfHks7d0qWlXGrGPV8bnFkSpqdbVedgbM(Y3Nw7Pin08bISMEi8DqK9Xs(KoiLpYdVPiurAFGgcEjgmcm9LpO5tH9bAi4LyWiW0x((0ApfPHMpquG0dHVdISpwYh2mKYh5H3ueQiTpqdbVedgbM(Yh08PW(ane8smyey6lFFATNI0qZhikq6HW3br2hl5JaScP8rE4nfHks7d0qWlXGrGPV8bnFkSpqdbVedgbM(Y3Nw7Pin08bIcKEi8DqK9Xs(WkRqkFKhEtrOI0(ane8smyey6lFqZNc7d0qWlXGrGPV89P1EksdnFGOaPhcFhehe5gBWwLHnjdKgiLp(aLe5tK0HrLpmyKpq7bhkn08brYz4arAFoCc5Jbx4eRiTpzjBbt33br2hl5t6Gu(ip8MIqfP9bAi4LyWiW0x(GMpf2hOHGxIbJatF57tR9uKgA(yLpYVSt27defi9q47G4GWMs6WOI0(i39XYvGxFuXv33bHdCDuMldRYDOZb6qyMqrCazjlFKDWLY65dBfdgMCqKLS8HTqpeSHe7dRS4dRqNvbCqCqKLS8r(tpLHls7ZJyWiYNmo5zLppcCS33h2iNPU68zXRCjzOegyLpwUc8E(GxL4VdILRaV3VdrzCYZkHwxNsCRdhhEDqSCf49(DikJtEwjQW0E4QuKUXOmXKUxSGBfo9X6Gy5kW797qugN8SsuHPDfzQsYbXYvG373HOmo5zLOctlXqIq6gdg10KvsS0HOmo5zv7OmE1NqiHLGriYcDJsrB9nT((X2pRqIdILRaV3VdrzCYZkrfMgcRuTsIAp8shlDikJtEw1okJx9jKvwcgHikXI96t6CqSCf49(DikJtEwjQW0ovKPMT6MoYelDikJtEw1okJx9jKvwcgHiIbrNK9uKdIdISKLpYF6PmCrAFOuesSpvKq(usKpwUWiFIZhlLfk7POVdILRaVNqrISioiYYh2kDfzQsYNGXNo8DXtr(aXf7tky1si7PiFOLsc68jwFY4KNvqWbXYvG3tuHPDfzQsYbrw(WwjewP85IfSI85bZWC(qgsj2hCjriFkjB9bkem5JGKHIfSp2Q9rqe20xOjhelxbEprfMwkdf2trSSwcjevVgIqyLILuMcMeIQx7bZWC9Hv2HiKFWmm)cbtThzOyb)H7yhYpygM)dHn9fA6d3bbhez5J8VhmI8Ph5dyQ8HbwP8HnsEWNKpYto8bSf75JTAFmeTqR8briSsflyFKhgElFkjYhzNwF(8GzyoFSEMyhelxbEprfMwkdf2trSSwcj0sEWNulJxDubEzjLPGjHzCYd36WXw3xtmroQ(fYQOpygM)dHn9fA6d3XoTecS4(fcjqNDic5mE1Wr9Zy4TALe1WA9bkOpygMpcRuTsIAp8s3hrjwSx)cfa6qWbrw(WwInojFSYNel9rcCIpYto85bx(yPWH2NE2vXc2hbrytFHM8XwTpYgWrweFyBK1ZNhEHpFY4Kh2NoCS15Gy5kW7jQW0szOWEkIL1siHmXgNulJxDubEzjLPGjHzCYd36WXwx)cZDTel9TRJwTC9Gzy(pe20xOPpCNCbXhmdZh31Hrf8gL4pCNSzzkARVCgoYI00iR3Nw7Pineaf0mo5HBD4yRtOTrILLmeys3YDoiYYh5wus(KaRQOtr(ugcmvhl(usX5tkdf2tr(eNpzjklcP9PW(OPCOjF6jrLeH85WjKpYJTpFojmSs7ZJ85eVzs7tVOK8rqLPjFylkyesSdILRaVNOctlLHc7PiwwlHe(uMMAmkyesC7eVzwszkys41rkvRmeyQU)tzAQXOGriX9Hv2rwOBukARVP13p2(zf6Gc6dMH5)uMMAmkyes8hrjwSx)ciAzkARViHsfl421Hi6tR9uK2bXYvG3tuHPHG3MLRaVnvCflRLqcVImvjXsWi8kYuLeP)Ms5Gy5kW7jQW0YMs1SCf4TPIRyzTesywFoiwUc8EIkmne82SCf4TPIRyzTesitSXjXsWimLHc7POptSXj1Y4vhvGxhelxbEprfMw2uQMLRaVnvCflRLqcFWHs7Gy5kW7jQW0mu2wQvyeI2ILGriTecS4VMyICu9luairuAjeyXFebMwhelxbEprfMMHY2sToy1roiwUc8EIkmnvawQUgKwyn4eAlhelxbEprfM2Za3WmTcfzrohehezjlFeeouAcDoiwUc8E)hCO0cpQ7IZbXYvG37)GdLwuHPbwcFLsC7kuic5Gy5kW79FWHslQW0oPiflbJqe8smyey6xXkUv40h52tzAYbXYvG37)GdLwuHPrzjCSGBiQdfj2QDqSCf49(p4qPfvyAhHqwr62dVu76criwYIZkQvgcmvNqbyjyecznU(hHqwr62dVu76crOFfzrIfmOGA5ksrnAPKGoHcWoYcDJsrB9nT((X2pdSs1quwYqGPwfjeOGMLmey66Nv2zcWsvdrjwSxFGehez5JC6iFKJ4kSYhajC5tVOK8r211Hrf8gLyFcgFKho5zLpYbUOnl2NE4fALp4uekBD(qlHalMfF6jrRpr5tVqP8HsVLlLyFYwNpYtoyXhmYNEs06d8flyFKnGJSi(W2iRNdILRaV3)bhkTOctRlUcRANeUyjye(Gzy(4UomQG3Oe)H7yhI0siWI)AIjYr1pePLqGf)reyAfvaOdbqbnJtE4who26(AIjYr1hHci6dMH5)qytFHM(WDGcAzkARVCgoYI00iR3Nw7PineCqSCf49(p4qPfvyADXvyv7KWflbJWhmdZh31Hrf8gL4pCh7q8bZW8bJiAprI9A9ISie6(WDGc6dMH5NXBMmfPBpf8Qj0d(UpCheCqSCf49(p4qPfvyAxSXveQDfkeHCqSCf49(p4qPfvyAGXWGjwcgHLPOT(6avIBfkYICFATNI0SNXjpCRdhBDFnXe5O6xOaI(Gzy(pe20xOPpCNdIdISKLpYdJvACV9CqKLpcQmn5dBrbJqI9bV(WQO(qlLe05Gy5kW79Z6t4tzAQXOGriXSemcVosPALHat11VqwzhYpygM)tzAQXOGriXF4ohez5JC6IfSpSrYd(K8joFmFyfsVpXMrKDel(CyF6R2gNKpzB95r(C4eQIe685r(aFK2h78X8bUcvuI956iLYh4vr35d8flyF6B7kc5dBCNDxS(Gr(W2KvskX(aizACVZbXYvG37N1NOctlLTXjXsWieYi4LyWiW0pXqI0WmTsIAj2veQz3z3fl7q(kYuLeP)MsXEkdf2trFl5bFsTmE1rf4LDicze8smyey6RjRKuIBNKPX9oqb9bZW81KvskXTtY04E3xJ7TSNXjpCRdhBD9riRqWbrw(i3IsYN(2UIq(Wg3D2DXYIpN4n7tF124K8Pxus(y(WeBCseYhmYh2i5bFs(OPoA1Xc2h86JGL87tgJvACVLfFWiFmvpt85J5dtSXjriF6fLKp9ndB7Gy5kW79Z6tuHPLYqH9uelRLqctzBCsTeRLXRoQaVSemcrWlXGrGPFIHePHzALe1sSRiuZUZUlw2HCzkARFIHeH0ngmQPjRK(0ApfPzjLPGjHqeYzmwPX92)JQEeTTsIAKy6(iY0IzpLHc7POptSXj1Y4vhvGxiakOqmJXknU3(Fu1JOTvsuJet3hrMwm7Pmuypf9TKh8j1Y4vhvGxi4Gy5kW79Z6tuHPLYqH9uelRLqctzBCsTeRLXRoQaVSemcrWlXGrGPFIHePHzALe1sSRiuZUZUlw2ltrB9tmKiKUXGrnnzL0Nw7PinlPmfmjmLHc7POptSXj1Y4vhvGxhelxbEVFwFIkmTu2gNelbJWugkSNI(PSnoPwI1Y4vhvGx2tSRiuZUZUl2gIsSypHqN9ugkSNI(pLPPgJcgHe3oXB2bXYvG37N1NOctJrzGjLYQaVoiwUc8E)S(evyAmkdmPuwf4TLvKThXsWiutpygMpJYatkLvbE)ikXI96dRoiwUc8E)S(evyAMgrRPILAi4tILGriKFWmmFtJO1uXsne8j9H7CqSCf49(z9jQW0qyLQvsu7Hx6yjyeMyxrOMDNDxSneLyXEcHo7q8bZW8ryLQvsu7Hx6(ikXI96JW0bkOPmuypf9r1RHiewPGGdIS8HnX4JP1NpgI8bUJfFUn6iFkjYh8s(0lkjFu4E0v(afuS93h50r(0tIwF0IJfSpm2veYNsYwFKNC4JMyICu(Gr(0lkjmC5JTI9rEYX3bXYvG37N1NOctlXqIq6gdg10KvsSKfNvuRmeyQoHcWsWiezHUrPOT(MwFF4o2HyziWu9RiHAfUPdQpzCYd36WXw3xtmrokqbfYxrMQKi9hHbdtSNXjpCRdhBDFnXe5O6xyURLyPVDD0QLlbGGdIS8HnX4ZI9X06ZNEHs5JoiF6fLuS(usKplL(YN0b9JfFGpYN(MHT9bV(8W35tVOKWWLp2k2h5jhFhelxbEVFwFIkmTedjcPBmyuttwjXsWiezHUrPOT(MwF)y7pDqxUqwOBukARVP13xdJSkWl7q(kYuLeP)imyyI9mo5HBD4yR7RjMihv)cZDTel9TRJwTCjGdIS8HnQIs6kFkSpN4n7dKUqPIfSpaDiI8Pxus(0xTnojFyWiF6B7kc5dBCNDxSoiwUc8E)S(evyAPmuypfXYAjKqrcLkwWTRdrulLTXj1oXBMLuMcMecze8smyey6NyirAyMwjrTe7kc1S7S7IfuqZySsJ7T)u2gN0hrjwSx)caDqbnXUIqn7o7UyBikXI96Nvhez5JC6iFI1hbKlwHYNGXhbl53N48bUZhB1(0dVqR8jBD(i)lHalMfFWiFSYN0bLO(arwHsuF6fLKpSnzLKsSpasMg37GGpyKp9KO1N(2UIq(Wg3z3fRpX5dC33bXYvG37N1NOcttKqPIfC76qeXsWimLHc7PO)tzAQXOGriXTt8MzpLHc7POViHsfl421HiQLY24KAN4nZoKVImvjr6pcdgMyhIA6bZW8Fu1JOTvsuJet3hUJDAjeyXFnXe5O6hI0siWI)icmTYMSkQaqceaf0RJuQwziWuD)NY0uJrbJqI7hISkxpygMVMSssjUDsMg37(WDqauqtSRiuZUZUl2gIsSyV(HoeCqSCf49(z9jQW0Ekttne8jXsWimLHc7PO)tzAQXOGriXTt8MzhI0siWI)vKqTc3sS03pRGc61rkvRmeyQU(zfcoiwUc8E)S(evyAAez6NY00XsWieYxrMQKi93uk2Z4KhU1HJTU(iuahelxbEVFwFIkmTtY04EjKsZsWieYxrMQKi93uk2tzOWEk6Bjp4tQLXRoQaVoiwUc8E)S(evyAD4kWllbJWhmdZ)PWyTc(QpISCbkOmbyPQHOel2RpPd6Gc6dMH5BAeTMkwQHGpPpCNdILRaV3pRprfM2tHX6gdmsSdILRaV3pRprfM2JqhHejwWoiwUc8E)S(evyAmbIEkmw7Gy5kW79Z6tuHPzBMUczQw2ukhez5dBtmgSQ8jJxDubEpFyWiFGp7PiFIIsUVdILRaV3pRprfMg8rTOOKJLGriKrWlXGrGPFIHePHzALe1sSRiuZUZUlw210dMH5)OQhrBRKOgjMUpCh7qeYLPOT(GLWxPe3UcfIqFATNI0GcQMEWmmFWs4RuIBxHcrOpCheaf0e7kc1S7S7ITHOel2RFOdkOmbyPQHOel2Rpczf6oioiYsw(WwInojcDoiwUc8EFMyJts4PIm1Sv30rMyjye(Gzy(NkYuZwDthz6JOel2RpmbyPQHOel2JDeXGOtYEkYbrw(iyj)(GxFYySsJ7T(uyFeHOoFkjYh5HIYhn9Gzy8bUJfFGxfDNpLe5tziWu5tC(ypmC5tH9rhKdILRaV3Nj24KevyApQ6r02kjQrIPJLGryziWu9RiHAfUPdQ)05Gy5kW79zInojrfMMoUoRYsoioiYsw(auKPkjhelxbEV)vKPkjH646SklXsWimLHc7POptSXj1Y4vhvGxhelxbEV)vKPkjrfMML8GpjhelxbEV)vKPkjrfMwwISU2jHlwYIZkQvgcmvNqbyjyewMI263HiXn82kjQ1Jmr(0ApfPzhYLHat1pU2dFhV4fNd]] )

end