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
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
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
        return 0
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.all and ( not a or a.startsCombat ) then
            if buff.stealth.up then
                setCooldown( "stealth", 2 )
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

                removeBuff( "sepsis_buff" )
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


    spec:RegisterPack( "Outlaw", 20201225.1, [[d4eAQaqia0JOu0LiQsvBcQ0NOuQrre6uebRcaqVcQQzru6wukXUuYVikggurhJi1YukEgLQmnkL01OuyBaq9naqnoaqohrvkRdQqMhuf3tPAFuQCqOkXcbOhcvPMiLQQlsPQyJaa9rOkjNeQGwjfmtaiDtkvLStLs)KOkAOevjhLsvPwkubEQunvPuxfQsQTsuLkFfaIXsuf2RQ(RidgYHPAXI6XKAYKCzuBgkFgqJMsoTKvdaWRjIMnHBlf7wLFJy4u0XHkulhPNdA6cxhOTtK8DIkJNOQopfA(sj7xXV0F7VR8G)TBW5gCk9Mna4L0sBVnBS1Vhgn5VB6AjDG83pVH)U8emeUCF30nkiU6B)DibKQ5VBfHjehjJmaRWcmV0KgzGvdOWJICAQJfYaRgTmFpdwIahEF(7kp4F7gCUbNsVzJn(Udgwe637vdE)DRsP47ZFxXq93T5GKNGHWLBq4acqqEmyZbz)SMBYmDqBSHSdAdo3GZVlkya)2FxXyoOi(2)wP)2F31rrUVlzPL8785zbREa)43U5B)Dxhf5(omyxewFNpply1d4h)w79T)oFEwWQhWVtm)oKJV76Oi33LYPLNf83LYfG83ProLbXWGdcpdAZGWDqsCqaCqzqmSvqb5uMDADaxGMdc3bbWbLbXWwzkXvWsXlqZbjHVlLttN3WFNg5eLPeH4JFRT(T)oFEwWQhWVtm)oKJV76Oi33LYPLNf83LYfG831KMmjzsQlGlfJv6kgKD7dAZGWFqzqmSvMsCfSu8c0Cq4oi(ykqJdYU9bzdCoiChKeheahKMCkWkwAc4fPWIteLcU4ZZcwnOwTgugedBrjcrkS4uMCmCr5gVo4GSBFqsJZbjHVlLttN3WF3BYGqRKMCQkkY9XV1gF7VZNNfS6b87eZVd547UokY9DPCA5zb)DPCbi)DOjlePWPa5aUYcxXjmbiLACq4zqBgeUdI6LkXsXxSCLcUQBq2nOn4CqTAnOmig2klCfNWeGuQXfO53LYPPZB4VNfUItycqk1ycA80F8BbWF7VZNNfS6b87AAfmT8Vdd2fHfRwUq8Dxhf5(of8sUokYLefm(UOGr68g(7WGDry9XVfa(B)D(8SGvpGF31rrUVRDHi56OixsuW47IcgPZB4VRvWp(TaqF7VZNNfS6b87AAfmT8VRjnzsYKuxahKD7dsBMAC5NGM8PgKTmOmig2ktjUcwkEbAoiBzqsCqzqmSfX0KqdWRcJlqZbbaCqHl4lw4yWslzsrD5w85zbRgKeguRwdstAYKKjPUaoO9b5x14AlNcKvjT53DDuK77uWl56OixsuW47IcgPZB4VJvxbT(43kV9T)oFEwWQhWV76Oi331UqKCDuKljky8DrbJ05n83ZGLq9XVvAC(T)oFEwWQhWVRPvW0Y)oFmfOXLIXkDfdYU9bjTnge(dIpMc04IYa577UokY9DNQ9JtbHs5l(43kT0F7V76Oi33DQ2pozckG835ZZcw9a(XVv6nF7V76Oi33ffqRaMaaaQa2Wx8D(8SGvpGF8BL2EF7V76Oi33ZoWeblf0slj8785zbREa)4JVBsznPj7X3(3k93(7UokY9D30uymzski5(oFEwWQhWp(TB(2F31rrUVNjriyvct4gzLC1bmfe5x335ZZcw9a(XV1EF7VZNNfS6b87UokY99gNkjRsyeAsXEy9DnTcMw(3PEPsSu8flxPGR6gKDdAJn(UjL1KMShjiRjNc(DB8XV1w)2FNpply1d43DDuK77uIqKcloLjhd)UMwbtl)7uUXRdoi8mi7niChenYPmiggCq4zqB(UjL1KMShjiRjNc(9nF8BTX3(785zbREa)URJICFhkknN8tLuLM)UMwbtl)7ugJYqlpl4VBsznPj7rcYAYPGFFZh)wa83(7UokY9DyWUiS(oFEwWQhWp(47zWsO(2)wP)2F31rrUVdztyb)oFEwWQhWp(TB(2F31rrUVd0IadHXemOLK835ZZcw9a(XV1EF7VZNNfS6b87AAfmT8VtbpgJqbYROoJPGi)sNYcxXl(8SGvF31rrUVdTkP(43ARF7V76Oi33zTfPoGjkBsRg)uFNpply1d4h)wB8T)oFEwWQhWV76Oi33HmL6bRszYXjOzjj)DnTcMw(3b4GuKybzk1dwLYKJtqZssEfLwY6aoOwTgKRJskoXh3umCq7ds6bH7GOEPsSu8flxPGR6gKDdcduisuwB5uGCkQgEqTAniTLtbYWbz3G2miChewb0ksuUXRdoi8miB8DTrTGtHtbYb83k9h)wa83(785zbREa)UMwbtl)7zqmSfX0KqdWRcJlqZbH7GK4G4JPanoi8miB1gdQvRbfUGVyHJblTKjf1LBXNNfSAqs47UokY9DZcgercArIp(TaWF7VZNNfS6b87AAfmT8VNbXWwettcnaVkmUanheUdsIdkdIHTasz(GswhmjxPLKPWfO5GA1AqzqmSLMCA2fSkLfGNIPzqiCbAoij8Dxhf5(UzbdIibTiXh)waOV93DDuK77W6kyW0emOLK835ZZcw9a(XVvE7B)D(8SGvpGFxtRGPL)9Wf8flvrdJPGwAjHl(8SGvdc3bPjnzsYKuxaxkgR0vmi72hK0dc)bLbXWwzkXvWsXlqZV76Oi33bsabYF8X31k43(3k93(785zbREa)UMwbtl)7aCqWGDryXQLledc3bjLtlpl4L3KbHwjn5uvuKBq4oOghgmn5qOdH1LOCJxhCq7dcNdc3bjXbbWbrbpgJqbYlf7HLWycA5kICWfFEwWQb1Q1GYGyylf7HLWycA5kICWLIi3niChKM0KjjtsDbCq4zFqBgKe(URJICFxk)kO1h)2nF7V76Oi33Xeoqwi8Oi335ZZcw9a(XV1EF7VZNNfS6b87AAfmT8VR4mig2ct4azHWJIClk341bheEg0MV76Oi33Xeoqwi8Oixsly)G8h)wB9B)D(8SGvpGFxtRGPL)DaoOmig2Yvu(CrDCIccTwGMdc3bjXbbWbPjeHIi3TKSeI6aMGMuMxGMdQvRbbWbfUGVyjzje1bmbnPmV4ZZcwnij8Dxhf5(URO85I64efeA9XV1gF7VZNNfS6b87AAfmT8VNbXWwuIqKcloLjhdxuUXRdoi8Spi7nOwTgKuoT8SGx0iNOmLieF31rrUVtjcrkS4uMCm8JFla(B)D(8SGvpGF31rrUV34ujzvcJqtk2dRVRPvW0Y)o1lvILIVy5kfCbAoiChKehu4uGCSIQHtbjPkEq4zqAstMKmj1fWLIXkDfdQvRbbWbbd2fHfRwucqqEq4oinPjtsMK6c4sXyLUIbz3(G0MPgx(jOjFQbzlds6bjHVRnQfCkCkqoG)wP)43ca)T)oFEwWQhWVRPvW0Y)o1lvILIVy5kfCv3GSBq2dNdYwge1lvILIVy5kfCPaPEuKBq4oiaoiyWUiSy1IsacYdc3bPjnzsYKuxaxkgR0vmi72hK2m14Ypbn5tniBzqs)Dxhf5(EJtLKvjmcnPypS(43ca9T)oFEwWQhWVRPvW0Y)o0KfIu4uGCahKD7dAZGWDqaCqzqmSvw4koHjaPuJlqZV76Oi33ZcxXjmbiLA8JFR823(785zbREa)UMwbtl)7s50YZcELfUItycqk1ycA80dc3bjXbXhtbACfvdNcsQXL)GSBqBguRwdcAYcrkCkqoGdYUbTzqs47UokY9DjlHOoGjOjL5p(TsJZV935ZZcw9a(DnTcMw(3LYPLNf8klCfNWeGuQXe04PheUdsIdIpMc04kQgofKuJl)bz3G2mOwTge0KfIu4uGCahKDdAZGKW3DDuK77zHR4efeA9XVvAP)2FNpply1d4310kyA5FhGdcgSlclwTCHyq4oinPjtsMK6c4GWZ(GK(7UokY9DfLDvw4kg(XVv6nF7VZNNfS6b87AAfmT8VdWbbd2fHfRwUqmiChKuoT8SGxEtgeAL0KtvrrUV76Oi33HwUIixdluF8BL2EF7VZNNfS6b87AAfmT8VNbXWwzbHOeGWyrzxhdQvRbHvaTIeLB86GdcpdYE4CqTAnOmig2Yvu(CrDCIccTwGMF31rrUVBsIICF8BL2w)2F31rrUVNfeIkHbsn(D(8SGvpGF8BL2gF7V76Oi33ZmfYujRd435ZZcw9a(XVvAa83(7UokY9DSIYzbHO(oFEwWQhWp(Tsda)T)URJICF3pnddQlsAxi(oFEwWQhWp(Tsda9T)oFEwWQhWVRPvW0Y)UIZGyyRmhYX8LcloXgz4c0Cq4oijoiaoOWf8flGweyimMGbTKKx85zbRguRwdsXzqmSfqlcmegtWGwsYlqZbjHb1Q1GWkGwrIYnEDWbHN9bTbNF31rrUVdc5ufCd8Jp(omyxewF7FR0F7VZNNfS6b87AAfmT8VRjnzsYKuxahKD7dsBMAC5NGM8P(URJICFxvqtp0wF8B38T)URJICF3BYGqRVZNNfS6b8JFR9(2FNpply1d43DDuK77Al2ntqls8DnTcMw(3dxWxSmPSXe5sHfNKJDjx85zbRgeUdcGdkCkqowfmLjq431g1cofofihWFR0F8X3XQRGwF7FR0F7V76Oi33ZCihZxkS4eBKHFNpply1d4h)2nF7VZNNfS6b87AAfmT8VNbXWwqrP5KFQKQ08IYnEDWbHNbHvaTIeLB86Gdc3brzmkdT8SG)URJICFhkknN8tLuLM)43AVV93DDuK77QcA6H26785zbREa)4Jp(UumfwK73UbNBWP0B2yJVlNtV6ac)oacEbhSfhUfVchnOb12Ihu1ysOXGWi0bzBfJ5GIW2dIY4yWIYQbbjn8GCWG04bRgK2YpGmCngaqRJhKTIJgeEtoPyAWQbzBn5uGvSKh2Eqbzq2wtofyfl5XIpplyLThKeLw(synggdai4fCWwC4w8kC0GguBlEqvJjHgdcJqhKT1kOTheLXXGfLvdcsA4b5GbPXdwniTLFaz4AmaGwhpiPXrdcVjNumny1GSnf8ymcfiVKh2Eqbzq2McEmgHcKxYJfFEwWkBpijkT8LWAmmgaqWl4GT4WT4v4ObnO2w8GQgtcngegHoiBNblHY2dIY4yWIYQbbjn8GCWG04bRgK2YpGmCngaqRJhK9WrdcVjNumny1GSnf8ymcfiVKh2Eqbzq2McEmgHcKxYJfFEwWkBpipgK9rEcGoijkT8LWAmmgWHnMeAWQbbGhKRJICdsuWaUgdFhAY6F7gamo)UjLGvc(72CqYtWq4YniCabiipgS5GSFwZnzMoOn2q2bTbNBW5yymyZbzFKpRbdwnOmJrO8G0KMShdkZaRdUgeErRzZaoOJC2ILtBWafdY1rro4GiNW4Am46OihCzsznPj7XUBAkmMmjfKCJbxhf5GltkRjnzpWFxMmjcbRsyc3iRKRoGPGi)6gdUokYbxMuwtAYEG)UmnovswLWi0KI9WswtkRjnzpsqwtofC3gYwy7uVujwk(ILRuWvD2TXgJbxhf5GltkRjnzpWFxgkrisHfNYKJHYAsznPj7rcYAYPG7BKTW2PCJxhep2dxAKtzqmmiE2mgCDuKdUmPSM0K9a)DzGIsZj)ujvPzznPSM0K9ibzn5uW9nYwy7ugJYqlpl4XGRJICWLjL1KMSh4VldmyxewJHXGnhK9r(Sgmy1GyPyQXbfvdpOWIhKRdcDqfCqUuEj8SGxJbxhf5G7swAjhd2Cq4aggSlcRbvydYKaHvwWdsIhzqsbkoM6zbpi(4MIHdQUbPjnzpKWyW1rroi(7Yad2fH1yWMdchWuIqmiyDaf8GYGyyWbXovyCqKWIPdkS8BqTPG8GaKDADahKFQbbiL4kyP4XGRJICq83LrkNwEwWYEEdVtJCIYuIqiRuUaK3ProLbXWG4zdUseGzqmSvqb5uMDADaxGM4cWmig2ktjUcwkEbAkHXGnhK95GGuEqYXdcihdcduigeEPjdcTgeElVgeqVo4G8tniNYNTJbrzkriQd4GWBc4fdkS4bjpvk4GYGyyWb5Y5ghdUokYbXFxgPCA5zbl75n8U3KbHwjn5uvuKtwPCbiVRjnzsYKuxaxkgR0vy3(g8ZGyyRmL4kyP4fOjU8XuGgTB3g4exjcqn5uGvS0eWlsHfNikfSvRmig2IseIuyXPm5y4IYnEDq72LgNsymyZbbGuH1GAafrzk4bfofihqzhuyvWbjLtlpl4bvWbPTyTKSAqbzqkwxkEqYzXHftheK0WdcVTF4GGweqHAqzEqqJNMvdsUkSgeGcxXdcauasPghdUokYbXFxgPCA5zbl75n8Ew4koHjaPuJjOXtlRuUaK3HMSqKcNcKd4klCfNWeGuQr8SbxQxQelfFXYvk4Qo72GZwTYGyyRSWvCctasPgxGMJbxhf5G4Vldf8sUokYLefmK98gEhgSlclzlSDyWUiSy1YfIXGRJICq83Lr7crY1rrUKOGHSN3W7AfCmyZbbawxbTgKhdQXLF1a2mi8wEnOmymixksPgKComQd4GaKsCfSu8G8tni7BWsl5GSFQl3GYKdeoinPjtgKjPUaogCDuKdI)UmuWl56OixsuWq2ZB4DS6kOLSf2UM0KjjtsDb0UDTzQXLFcAYNYwYGyyRmL4kyP4fOPTiXmig2IyAsOb4vHXfOjaWWf8flCmyPLmPOUCl(8SGvsOvlnPjtsMK6c4UFvJRTCkqwL0MJbxhf5G4VlJ2fIKRJICjrbdzpVH3ZGLqngCDuKdI)Umov7hNccLYxiBHTZhtbACPySsxHD7sBd85JPanUOmq(gdUokYbXFxgNQ9JtMGcipgCDuKdI)UmIcOvataaavaB4lgdUokYbXFxMSdmrWsbT0schdJbBoiablHIPWXGRJICWvgSeQDiBcl4yW1rro4kdwcf(7Ya0IadHXemOLK8yW1rro4kdwcf(7YaTkPKTW2PGhJrOa5vuNXuqKFPtzHR4XGRJICWvgSek83LH1wK6aMOSjTA8tngCDuKdUYGLqH)UmqMs9GvPm54e0SKKLvBul4u4uGCa3Lw2cBhGksSGmL6bRszYXjOzjjVIslzDaB1Y1rjfN4JBkgUlnUuVujwk(ILRuWvD2HbkejkRTCkqofvd3QL2YPazODBWfRaAfjk341bXJngd2Cq41qEqYRcgeXG6wKyqYvH1GKNMMeAaEvyCqf2GYSGi3GSvBmi(ykqJYoicDqYzX3GaH1bCq23GLwYbz)uxUXGRJICWvgSek83LXSGbrKGwKq2cBpdIHTiMMeAaEvyCbAIRe5JPanIhB1gTAfUGVyHJblTKjf1LBXNNfSscJbxhf5GRmyju4VlJzbdIibTiHSf2EgedBrmnj0a8QW4c0exjMbXWwaPmFqjRdMKR0sYu4c0SvRmig2ston7cwLYcWtX0mieUanLWyW1rro4kdwcf(7YaRRGbttWGwsYJbxhf5GRmyju4Vldqciqw2cBpCbFXsv0WykOLws4IpplyfUAstMKmj1fWLIXkDf2Tln(zqmSvMsCfSu8c0CmmgS5GWBcrOiYDWXGnheEnSoGdcV0KbHwdQGdYh0g59dQonLDil7GGKbjVZVcAniTFdkZdcsA4OAy4GY8GaHSAqoCq(GaJsuHXbbnzHyqGNGHWbbcRd4GSVCyW0bHxGqhcRBqe6GSF2dlHXb1TCfro4yW1rro4sRG7s5xbTKTW2bimyxewSA5cbUs50YZcE5nzqOvstovff5WTXHbttoe6qyDjk341b3XjUseGuWJXiuG8sXEyjmMGwUIihSvRmig2sXEyjmMGwUIihCPiYD4QjnzsYKuxaXZ(gjmgCDuKdU0ki(7YGjCGSq4rrUXGRJICWLwbXFxgmHdKfcpkYL0c2pilBHTR4mig2ct4azHWJIClk341bXZMXGRJICWLwbXFxgxr5Zf1Xjki0s2cBhGzqmSLRO85I64efeATanXvIauticfrUBjzje1bmbnPmVanB1cGHl4lwswcrDatqtkZl(8SGvsym46OihCPvq83LHseIuyXPm5yOSf2EgedBrjcrkS4uMCmCr5gVoiE2TxRws50YZcErJCIYuIqmgS5GWHydYvk4GCkpiqtzhe8ktEqHfpiYXdsUkSgKGihdJb1UT9VgeEnKhKCw8niLX6aoimhgmDqHLFdcVLxdsXyLUIbrOdsUkSiGXG8Z4GWB51Am46OihCPvq83LPXPsYQegHMuShwYQnQfCkCkqoG7slBHTt9sLyP4lwUsbxGM4kXWPa5yfvdNcssvmE0KMmjzsQlGlfJv6kA1cGWGDryXQfLaeKXvtAYKKjPUaUumwPRWUDTzQXLFcAYNYwKwcJbBoiCi2GoYGCLcoi5kHyqQIhKCvyv3GclEqhl)yq2dNqzheiKhK9fM9piYnOmbchKCvyraJb5NXbH3YR1yW1rro4sRG4VltJtLKvjmcnPypSKTW2PEPsSu8flxPGR6SZE40wOEPsSu8flxPGlfi1JIC4cqyWUiSy1IsacY4QjnzsYKuxaxkgR0vy3U2m14Ypbn5tzlspgS5Gau4kEqaGcqk14Gi3G2G)G4JBkgogCDuKdU0ki(7YKfUItycqk1OSf2o0KfIu4uGCaTBFdUamdIHTYcxXjmbiLACbAogCDuKdU0ki(7Yizje1bmbnPmlBHTlLtlpl4vw4koHjaPuJjOXtJRe5JPanUIQHtbj14Y3UnTAbnzHifofihq72iHXGRJICWLwbXFxMSWvCIccTKTW2LYPLNf8klCfNWeGuQXe04PXvI8XuGgxr1WPGKAC5B3MwTGMSqKcNcKdODBKWyW1rro4sRG4VlJIYUklCfdLTW2bimyxewSA5cbUAstMKmj1fq8Sl9yW1rro4sRG4Vld0Yve5AyHs2cBhGWGDryXQLle4kLtlpl4L3KbHwjn5uvuKBm46OihCPvq83LXKef5KTW2ZGyyRSGqucqySOSRJwTWkGwrIYnEDq8ypC2QvgedB5kkFUOoorbHwlqZXGRJICWLwbXFxMSGqujmqQXXGRJICWLwbXFxMmtHmvY6aogCDuKdU0ki(7YGvuolie1yW1rro4sRG4VlJFAgguxK0UqmgS5GSFgZbfXGWCHi7AjhegHoiqONf8GQGBGRXGRJICWLwbXFxgqiNQGBGYwy7kodIHTYCihZxkS4eBKHlqtCLiadxWxSaArGHWycg0ssEXNNfSQvlfNbXWwaTiWqymbdAjjVanLqRwyfqRir5gVoiE23GZXWyWMdcaSUcAXu4yWMdcWW(miYninHiue5UbfKbjjZMdkS4bH30kgKIZGyydc0Cm46OihCHvxbT2ZCihZxkS4eBKHJbxhf5GlS6kOf(7YafLMt(PsQsZYwy7zqmSfuuAo5NkPknVOCJxhepyfqRir5gVoiUugJYqlpl4XGRJICWfwDf0c)Dzuf00dT1yymyZb1d2fH1yW1rro4cgSlcRDvbn9qBjBHTRjnzsYKuxaTBxBMAC5NGM8PgdUokYbxWGDryH)UmEtgeAngCDuKdUGb7IWc)Dz0wSBMGwKqwTrTGtHtbYbCxAzlS9Wf8fltkBmrUuyXj5yxYfFEwWkCby4uGCSkyktGWp(4F]] )

end