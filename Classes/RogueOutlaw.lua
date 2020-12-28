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


    spec:RegisterPack( "Outlaw", 20201228, [[d4uuQaqiLIEeLcxIsrjBcr6tuQYOqu6uebRIsvjVcr1SikDlkfzxk5xefddr0XiswMsPNrPuttPaxJsjBtPq9nkvfJdrGZrufSoefAEeHUNs1(Ou5GicAHa0dru0ePuvDrkfvBuPq6JukkojIqTskyMkfu3uPGyNa4NevjdLOk1rPuvQLIiKNkvtvk1vjQcTvkfL6RkfIXsufTxv9xrgmKdt1If1Jj1Kj5YO2mcFgqJMsoTKvRuq61ePMnHBlf7wLFd1WPOJJOGLJ0ZbnDHRd02jI(orLXtuvNNcnFPK9R4xQV93vEWpaBj5wsk12TKGLuB3AlBBF(Ey0K)UPRL2bYF)8g(7YlWq4Y9Dt3Oa7QV93HyqQM)UveMqYOmYaSclW8sJBKbwnGcpk8PPoridSA0Y89myjcs895VR8GFa2sYTKuQTBjblP2U1w2EJ)Udgwy637vdz(DRsP47ZFxXq93TXGKxGHWLBqKimqqEmyJbz)SMBYmDqBjbYoOTKClj)UOGb8B)Dft4GI4B)ai13(7Uok89DPlT0FNpply1d4hpaB)2F31rHVVdd2fH135ZZcw9a(XdGT)2FNpply1d43XMFhYX3DDu477s60YZc(7s6cq(70iNYGeeWbjXbTDqKoiYoOnhugKGyfuqoLzNwhWfO5GiDqBoOmibXktXUcwkEbAoij8DjDA68g(70iNOmfleF8aSbF7VZNNfS6b87yZVd547Uok89DjDA5zb)DjDbi)DnUjJtM46c4sXeLUIbz3(G2oiYhugKGyLPyxblfVanhePdIpMc04GSBFq2IKdI0br2bT5G04tbwXsJbVifwCcRuWfFEwWQb1Q1GYGeelkwisHfNY4JHlk341bhKD7dsksoij8DjDA68g(7EtgeAL04tvrHVpEaS13(785zbREa)o287qo(URJcFFxsNwEwWFxsxaYFhAYcrkCkqoGRSWvCIqasPghKeh02br6GOEPsSK8flxPGR6gKDdAljhuRwdkdsqSYcxXjcbiLACbA(DjDA68g(7zHR4eHaKsnMGgp9hpaB83(785zbREa)UMwbtl)7WGDryXQLleF31rHVVtbVKRJcFjrbJVlkyKoVH)omyxewF8ayF(2FNpply1d43DDu477AxisUok8Lefm(UOGr68g(7Af8JhasW3(785zbREa)UMwbtl)7ACtgNmX1fWbz3(G0MPgx(jOjFQbztdkdsqSYuSRGLIxGMdYMgezhugKGyHnnX0a8QW4c0Cq2xdkCbFXImawAPtkQl3Ipply1GKWGA1AqACtgNmX1fWbTpi)QgxB5uGSkPn)URJcFFNcEjxhf(sIcgFxuWiDEd)DI6kO1hpaYdF7VZNNfS6b87Uok89DTlejxhf(sIcgFxuWiDEd)9myjuF8aifj)2FNpply1d4310kyA5FNpMc04sXeLUIbz3(GKYwdI8bXhtbACrzG89Dxhf((Ut1(XPatP8fF8aiLuF7V76OW33DQ2pozckG835ZZcw9a(XdGuB)2F31rHVVlkGwbmTHcQa2Wx8D(8SGvpGF8aiLT)2F31rHVVNDGjmrkOLwA435ZZcw9a(XhF3KYACt2JV9dGuF7V76OW33DttHXKjUG47785zbREa)4by73(7Uok899mocbRsec3iRKRoGPal)6(oFEwWQhWpEaS93(7Uok89DyWUiS(oFEwWQhWpEa2GV935ZZcw9a(Dxhf((EJtLMvjcmnPypS(UMwbtl)7uVujws(ILRuWvDdYUbT1wF3KYACt2JeK14tb)UT(4bWwF7VZNNfS6b87Uok89DkwisHfNY4JHFxtRGPL)Dk341bhKehKT)UjL14MShjiRXNc(9TF8aSXF7VZNNfS6b87Uok89DOO0CYpvsvA(7AAfmT8VtzckdT8SG)UjL14MShjiRXNc(9TF8X3jQRGwF7haP(2F31rHVVN5qoMVuyXj2id)oFEwWQhWpEa2(T)oFEwWQhWVRPvW0Y)EgKGybfLMt(PsQsZlk341bhKeherb0ksuUXRdoisheLjOm0YZc(7Uok89DOO0CYpvsvA(JhaB)T)URJcFFxvqtp0wFNpply1d4hF8DTc(TFaK6B)D(8SGvpGFxtRGPL)9nhemyxewSA5cXGiDqs60YZcE5nzqOvsJpvff(gePdQXHbttoe6qyDjk341bh0(Gi5GiDqKDqBoik4XeykqEPypSegtqlxHLdU4ZZcwnOwTgugKGyPypSegtqlxHLdUuy5Ubr6G04MmozIRlGdsI7dA7GKW3DDu477s6xbT(4by73(7Uok89DcHdKfcpk89D(8SGvpGF8ay7V935ZZcw9a(DnTcMw(3vCgKGyriCGSq4rHVfLB86GdsIdA73DDu477echileEu4lPfSFq(JhGn4B)D(8SGvpGFxtRGPL)9nhugKGy5kkFUOoorbHwlqZbr6Gi7G2CqAmwOWYDlPlHOoGjOjL5fO5GA1AqBoOWf8flPlHOoGjOjL5fFEwWQbjHV76OW33DfLpxuhNOGqRpEaS13(785zbREa)UMwbtl)7zqcIfflePWItz8XWfLB86GdsI7dY2dQvRbjPtlpl4fnYjktXcX3DDu477uSqKcloLXhd)4byJ)2FNpply1d43DDu477novAwLiW0KI9W67AAfmT8Vt9sLyj5lwUsbxGMdI0br2bfofihROA4uGtQIhKehKg3KXjtCDbCPyIsxXGA1AqBoiyWUiSy1IIbcYdI0bPXnzCYexxaxkMO0vmi72hK2m14Ypbn5tniBAqsnij8DTrTGtHtbYb8bqQpEaSpF7VZNNfS6b87AAfmT8Vt9sLyj5lwUsbx1ni7gKTj5GSPbr9sLyj5lwUsbxkqQhf(gePdAZbbd2fHfRwumqqEqKoinUjJtM46c4sXeLUIbz3(G0MPgx(jOjFQbztdsQV76OW33BCQ0SkrGPjf7H1hpaKGV935ZZcw9a(DnTcMw(3HMSqKcNcKd4GSBFqBhePdAZbLbjiwzHR4eHaKsnUan)URJcFFplCfNieGuQXpEaKh(2FNpply1d4310kyA5FxsNwEwWRSWvCIqasPgtqJNEqKoiYoi(ykqJROA4uGtnU8hKDdA7GA1AqqtwisHtbYbCq2nOTdscF31rHVVlDje1bmbnPm)XdGuK8B)D(8SGvpGFxtRGPL)DjDA5zbVYcxXjcbiLAmbnE6br6Gi7G4JPanUIQHtbo14YFq2nOTdQvRbbnzHifofihWbz3G2oij8Dxhf((Ew4korbHwF8aiLuF7VZNNfS6b87AAfmT8VV5GGb7IWIvlxigePdsJBY4KjUUaoijUpiP(URJcFFxrzxLfUIHF8ai12V935ZZcw9a(DnTcMw(33CqWGDryXQLledI0bjPtlpl4L3KbHwjn(uvu477Uok89DOLRWY1Wc1hpasz7V935ZZcw9a(DnTcMw(3ZGeeRSaJvcqySOSRJb1Q1GikGwrIYnEDWbjXbzBsoOwTgugKGy5kkFUOoorbHwlqZV76OW33nXrHVpEaKAd(2F31rHVVNfySkrasn(D(8SGvpGF8aiLT(2F31rHVVNzkKPsxhWVZNNfS6b8JhaP24V93DDu477efLZcmw9D(8SGvpGF8aiL95B)Dxhf((UFAgguxK0Uq8D(8SGvpGF8aifj4B)D(8SGvpGFxtRGPL)DfNbjiwzoKJ5lfwCInYWfO5GiDqKDqBoOWf8flGwyyimMGbTKMx85zbRguRwdsXzqcIfqlmmegtWGwsZlqZbjHb1Q1GikGwrIYnEDWbjX9bTLKF31rHVVdc5ufCd8Jp(omyxewF7haP(2FNpply1d4310kyA5FxJBY4KjUUaoi72hK2m14Ypbn5t9Dxhf((UQGMEOT(4by73(7Uok89DVjdcT(oFEwWQhWpEaS93(785zbREa)URJcFFxBXUzcAHJVRPvW0Y)E4c(ILjLnMWxkS4KCSl9Ipply1GiDqBoOWPa5yvWugdHFxBul4u4uGCaFaK6Jp(EgSeQV9dGuF7V76OW33HSjSGFNpply1d4hpaB)2F31rHVVd0cddHXemOL0835ZZcw9a(XdGT)2FNpply1d4310kyA5FNcEmbMcKxrDgtbw(LoLfUIx85zbR(URJcFFhAvs(XdWg8T)URJcFFN1w46aMOSjTA8t9D(8SGvpGF8ayRV935ZZcw9a(Dxhf((oKPupyvkJpobnlP5VRPvW0Y)(MdsHJfKPupyvkJpobnlP5vuAPRd4GA1AqUokj5eFCtXWbTpiPgePdI6LkXsYxSCLcUQBq2nicqHirzTLtbYPOA4b1Q1G0wofidhKDdA7GiDqefqRir5gVo4GK4GS131g1cofofihWhaP(4byJ)2FNpply1d4310kyA5FpdsqSWMMyAaEvyCbAoishezheFmfOXbjXbTb2AqTAnOWf8flYayPLoPOUCl(8SGvdscF31rHVVBwWalsqlC8XdG95B)D(8SGvpGFxtRGPL)9mibXcBAIPb4vHXfO5GiDqKDqzqcIfqkZhu66Gj5kT0mfUanhuRwdkdsqS04tZUGvPSa8umndcHlqZbjHV76OW33nlyGfjOfo(4bGe8T)URJcFFhwxbdMMGbTKM)oFEwWQhWpEaKh(2FNpply1d4310kyA5FpCbFXsv0WykOLwA4Ipply1GiDqACtgNmX1fWLIjkDfdYU9bj1GiFqzqcIvMIDfSu8c087Uok89DGyqG8hF8X3LKPWcFpaBj5wsk12T2Aj13LZPxDaHFFJqcjraqIbWMHmoOb12Ihu1yIPXGiW0bzpft4GIWEdIYKbWIYQbbXn8GCWa34bRgK2YpGmCng2W1XdAdiJdImXNKmny1GSNgFkWkwYt7nOapi7PXNcSIL8CXNNfSYEdISsjFjSgdJHncjKebajgaBgY4GguBlEqvJjMgdIathK90kO9geLjdGfLvdcIB4b5GbUXdwniTLFaz4AmSHRJhKuKXbrM4tsMgSAq2JcEmbMcKxYt7nOapi7rbpMatbYl55IpplyL9gezLs(synggdBesijcasma2mKXbnO2w8GQgtmngebMoi7LblHYEdIYKbWIYQbbXn8GCWa34bRgK2YpGmCng2W1XdY2KXbrM4tsMgSAq2JcEmbMcKxYt7nOapi7rbpMatbYl55IpplyL9gKhdYMlV2WdISsjFjSgdJbsCJjMgSAqB8GCDu4BqIcgW1y47Mumrj4VBJbjVadHl3GiryGG8yWgdY(zn3Kz6G2scKDqBj5wsoggd2yq2C5ZAWGvdkZeykpinUj7XGYmW6GRbrc1A2mGd6WNnz50gcqXGCDu4doi8jmUgdUok8bxMuwJBYES7MMcJjtCbX3yW1rHp4YKYACt2dY3LjJJqWQeHWnYk5QdykWYVUXGRJcFWLjL14MShKVldmyxewJbxhf(GltkRXnzpiFxMgNknRseyAsXEyjRjL14MShjiRXNcUBlzlIDQxQeljFXYvk4Qo72ARXGRJcFWLjL14MShKVldflePWItz8XqznPSg3K9ibzn(uW9TYwe7uUXRdkrBpgCDu4dUmPSg3K9G8DzGIsZj)ujvPzznPSg3K9ibzn(uW9TYwe7uMGYqlpl4XWyWgdYMlFwdgSAqSKm14GIQHhuyXdY1bMoOcoixsVeEwWRXGRJcFWDPlT0JbBmisedd2fH1GkIbzIHWkl4br2dpijbfht9SGheFCtXWbv3G04MShsym46OWhK8DzGb7IWAmyJbrIykwigeSoGcEqzqcc4GyNkmoiCyX0bfw(nO2uqEqaYoToGdYp1GaKIDfSu8yW1rHpi57YiPtlplyzpVH3ProrzkwiKvsxaY70iNYGeeqjULuYUzgKGyfuqoLzNwhWfOjPBMbjiwzk2vWsXlqtjmgSXGS5heKYdsoEqa5yqeGcXGiHnzqO1Git59Ga61bhKFQb5u(SxmiktXcrDahezIbVyqHfpi5LsbhugKGaoixo34yW1rHpi57YiPtlplyzpVH39Mmi0kPXNQIcFYkPla5DnUjJtM46c4sXeLUc723sEgKGyLPyxblfVanjLpMc0OD72IKKs2n14tbwXsJbVifwCcRuWwTYGeelkwisHfNY4JHlk341bTBxkskHXGng0gPcRb1akIYuWdkCkqoGYoOWQGdssNwEwWdQGdsBXAPz1Gc8GuSUu8GKZIdlMoiiUHhezA)WbbTWGc1GY8GGgpnRgKCvyniafUIh0gvasPghdUok8bjFxgjDA5zbl75n8Ew4koriaPuJjOXtlRKUaK3HMSqKcNcKd4klCfNieGuQrjULuQxQeljFXYvk4Qo72sYwTYGeeRSWvCIqasPgxGMJbxhf(GKVldf8sUok8LefmK98gEhgSlclzlIDyWUiSy1YfIXGRJcFqY3Lr7crY1rHVKOGHSN3W7AfCmyJbTrRRGwdYJb14YVAaBgezkVhugmgKljUudsohg1bCqasXUcwkEq(PgK9nyPLEq2p1LBqz8bchKg3KXdYexxahdUok8bjFxgk4LCDu4ljkyi75n8orDf0s2IyxJBY4KjUUaA3U2m14Ypbn5tztzqcIvMIDfSu8c00MiBgKGyHnnX0a8QW4c00(kCbFXImawAPtkQl3IpplyLeA1sJBY4KjUUaU7x14AlNcKvjT5yW1rHpi57YODHi56OWxsuWq2ZB49myjuJbxhf(GKVlJt1(XPatP8fYwe78XuGgxkMO0vy3Uu2IC(ykqJlkdKVXGRJcFqY3LXPA)4KjOaYJbxhf(GKVlJOaAfW0gkOcydFXyW1rHpi57YKDGjmrkOLwA4yymyJbbiyjumfogCDu4dUYGLqTdztybhdUok8bxzWsOiFxgGwyyimMGbTKMhdUok8bxzWsOiFxgOvjPSfXof8ycmfiVI6mMcS8lDklCfpgCDu4dUYGLqr(UmS2cxhWeLnPvJFQXGRJcFWvgSekY3LbYuQhSkLXhNGML0SSAJAbNcNcKd4UuYwe7BQWXcYuQhSkLXhNGML08kkT01bSvlxhLKCIpUPy4UuKs9sLyj5lwUsbx1zhbOqKOS2YPa5uunCRwAlNcKH2TLuIcOvKOCJxhuI2AmyJbjpc5bjVlyGfdQBHJbjxfwdsEzAIPb4vHXbvedkZcSCdAdS1G4JPank7GW0bjNfFdcewhWbzFdwAPhK9tD5gdUok8bxzWsOiFxgZcgyrcAHdzlI9mibXcBAIPb4vHXfOjPKLpMc0Oe3aB1Qv4c(IfzaS0sNuuxUfFEwWkjmgCDu4dUYGLqr(UmMfmWIe0chYwe7zqcIf20etdWRcJlqtsjBgKGybKY8bLUoysUslntHlqZwTYGeeln(0SlyvklapftZGq4c0ucJbxhf(GRmyjuKVldSUcgmnbdAjnpgCDu4dUYGLqr(UmaXGazzlI9Wf8flvrdJPGwAPHl(8SGvKQXnzCYexxaxkMO0vy3UuKNbjiwzk2vWsXlqZXWyWgdImXyHcl3bhd2yqYJW6aoisytgeAnOcoiFqBTznO60u2HSSdcIhKnB)kO1G0(nOmpiiUHJQHHdkZdceYQb5Wb5dcmkrfghe0KfIbbEcgcheiSoGdAdXHbthejecDiSUbHPdY(zpSeghu3Yvy5GJbxhf(GlTcUlPFf0s2IyFtyWUiSy1YfcsL0PLNf8YBYGqRKgFQkk8rAJddMMCi0HW6suUXRdUtssj7MuWJjWuG8sXEyjmMGwUclhSvRmibXsXEyjmMGwUclhCPWYDKQXnzCYexxaL4(wjmgCDu4dU0ki57YqiCGSq4rHVXGRJcFWLwbjFxgcHdKfcpk8L0c2pilBrSR4mibXIq4azHWJcFlk341bL42XGRJcFWLwbjFxgxr5Zf1Xjki0s2IyFZmibXYvu(CrDCIccTwGMKs2n1ySqHL7wsxcrDatqtkZlqZwT2mCbFXs6siQdycAszEXNNfSscJbxhf(GlTcs(UmuSqKcloLXhdLTi2ZGeelkwisHfNY4JHlk341bL4UTB1ssNwEwWlAKtuMIfIXGngejMyqUsbhKt5bbAk7GGxzYdkS4bHpEqYvH1Gey5yymO2TT)1GKhH8GKZIVbPmwhWbr4WGPdkS8BqKP8EqkMO0vmimDqYvHfgmgKFghezkVxJbxhf(GlTcs(UmnovAwLiW0KI9WswTrTGtHtbYbCxkzlIDQxQeljFXYvk4c0KuYgofihROA4uGtQILOg3KXjtCDbCPyIsxrRwBcd2fHfRwumqqMunUjJtM46c4sXeLUc721MPgx(jOjFkBskjmgSXGiXed6WdYvk4GKReIbPkEqYvHvDdkS4bDS8JbzBscLDqGqEqBie2)GW3GYyiCqYvHfgmgKFghezkVxJbxhf(GlTcs(UmnovAwLiW0KI9Ws2IyN6LkXsYxSCLcUQZoBtsBI6LkXsYxSCLcUuGupk8r6MWGDryXQffdeKjvJBY4KjUUaUumrPRWUDTzQXLFcAYNYMKAmyJbbOWv8G2Ocqk14GW3G2s(G4JBkgogCDu4dU0ki57YKfUItecqk1OSfXo0KfIu4uGCaTBFlPBMbjiwzHR4eHaKsnUanhdUok8bxAfK8DzKUeI6aMGMuMLTi2L0PLNf8klCfNieGuQXe04PjLS8XuGgxr1WPaNAC5B32wTGMSqKcNcKdODBLWyW1rHp4sRGKVltw4korbHwYwe7s60YZcELfUItecqk1ycA80Ksw(ykqJROA4uGtnU8TBBRwqtwisHtbYb0UTsym46OWhCPvqY3LrrzxLfUIHYwe7Bcd2fHfRwUqqQg3KXjtCDbuI7sngCDu4dU0ki57YaTCfwUgwOKTi23egSlclwTCHGujDA5zbV8Mmi0kPXNQIcFJbxhf(GlTcs(UmM4OWNSfXEgKGyLfySsacJfLDD0Qfrb0ksuUXRdkrBtYwTYGeelxr5Zf1Xjki0AbAogCDu4dU0ki57YKfySkrasnogCDu4dU0ki57YKzkKPsxhWXGRJcFWLwbjFxgIIYzbgRgdUok8bxAfK8Dz8tZWG6IK2fIXGngK9ZeoOigeHlezxl9GiW0bbc9SGhufCdCngCDu4dU0ki57Yac5ufCdu2IyxXzqcIvMd5y(sHfNyJmCbAskz3mCbFXcOfggcJjyqlP5fFEwWQwTuCgKGyb0cddHXemOL08c0ucTAruaTIeLB86GsCFljhdJbBmOnADf0IPWXGngeGHnFq4BqAmwOWYDdkWdsAMnhuyXdImPvmifNbjigeO5yW1rHp4IOUcATN5qoMVuyXj2idhdUok8bxe1vqlY3LbkknN8tLuLMLTi2ZGeelOO0CYpvsvAEr5gVoOejkGwrIYnEDqsPmbLHwEwWJbxhf(GlI6kOf57YOkOPhARXWyWgdQhSlcRXGRJcFWfmyxew7QcA6H2s2IyxJBY4KjUUaA3U2m14Ypbn5tngCDu4dUGb7IWI8Dz8Mmi0Am46OWhCbd2fHf57YOTy3mbTWHSAJAbNcNcKd4UuYwe7Hl4lwMu2ycFPWItYXU0l(8SGvKUz4uGCSkykJHWVdnz9dW2nMKF8X)a]] )

end