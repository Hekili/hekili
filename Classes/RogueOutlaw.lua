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


    spec:RegisterPack( "Outlaw", 20210102, [[d4KsQaqiLQ8ikfUervQAtiOprPsJIiQtHq1QuQkYRicZIO0TOuKDPKFrummGkhdHSme4zuQyAukvxJsjBdOk(gLsPXrPuCokfvRdOQmpIi3tPSpkvDqekAHaLhIqPjcuvDrkfLnQuvXhvQQ0jbQsRKcMPsvPUPsvH2PsLFsufnuIQKJQuvWsvQQ6Ps1uLsDvIQu2krvQ8vLQsglrvyVQ6VsmyihMQflPhtQjtYLrTze9zGmAk50IwTsvr9AIuZMWTLIDRYVHA4u0XrOWYr65GMUW1bSDIKVtuz8ev15PqZxkz)k(j6B)DLh8VJaWrarGJiWrWcC2C7ylB99WOj)DtxlTdI)(5n83LNaHWL77MUrb2vF7VdXaun)DRimHGpzKbugwa1Lg3idmBaeEK4ttDYqgy2OL57vGueG37RFx5b)7iaCeqe4icCeSaNn3o2Y2TTF3bclm979SHy)UvQu891VRyO(72yqYtGq4YnO9hdcGhd2yqg8dWPgherYoicahbe9Drcd43(7kM0beX3(3r03(7Uos89DPtT0FNpVky1d2h)oc(2F31rIVVdd2fH135ZRcw9G9XVZoF7VZNxfS6b77yZVd547Uos89DPCA6vb)DPCba)DAulvass4GK0GiyqeoijpO9gufGKCfuaUuzNMhOfG5GiCq7nOkaj5QsXUcMkEbyoiI)DPCA58g(70OwOmfleF87S9V935ZRcw9G9DS53HC8Dxhj((Uuon9QG)UuUaG)Ug3uXftCEbCPyYuNXGSFBqemijgufGKCvPyxbtfVamheHdIpMcY4GSFBq2cCdIWbj5bT3G04tbKXsJbUOewCbRuWfFEvWQb1Q1GQaKKlkwikHfxQ4JHlk345bhK9BdIiWniI)DPCA58g(7EtfaAv04tLrIVp(D26B)D(8QGvpyFhB(DihF31rIVVlLttVk4VlLla4VdnzHOeofehWvv4kUqkaOuJdssdIGbr4GOEQkSu8flxPGR8gK9dIaWnOwTgufGKCvfUIlKcak14cW87s50Y5n83RcxXfsbaLASanE6p(DGNV935ZRcw9G9DnndMM(3Hb7IWIvlxi(URJeFFNcCfxhj(kIegFxKWOCEd)DyWUiS(43zB)2FNpVky1d23DDK477AxikUos8vejm(UiHr58g(7Af8JFNT5B)D(8QGvpyFxtZGPP)DnUPIlM48c4GSFBqAZsJl)c0Kp1GSPbvbijxvk2vWuXlaZbztdsYdQcqsUWMMyAaCzyCbyoO9PbfUGVyrmasT0ff1LBXNxfSAqeFqTAninUPIlM48c4G2gKFzJRTCkiwv0MF31rIVVtbUIRJeFfrcJVlsyuoVH)ozEj06JFNn)B)D(8QGvpyF31rIVVRDHO46iXxrKW47IegLZB4VxbsH6JFhrG7B)D(8QGvpyFxtZGPP)D(ykiJlftM6mgK9BdIiBnijgeFmfKXfLbX33DDK477ov7hxcmLYx8XVJiI(2F31rIVV7uTFCXeqa5VZNxfS6b7JFhre8T)URJeFFxKGScyzFgqbQHV4785vbREW(43rKD(2F31rIVVxDqfmzjOPwA435ZRcw9G9XhF3KYACt1JV9VJOV93DDK477UPPWyXeNq89D(8QGvpyF87i4B)Dxhj((EfhHGvfsHBKvYLhOsGLFEFNpVky1d2h)o78T)URJeFFhgSlcRVZNxfS6b7JFNT)T)oFEvWQhSV76iX33BCQ0SQqIPff7H1310myA6FN6PQWsXxSCLcUYBq2picS13nPSg3u9Oazn(uWVBRp(D26B)D(8QGvpyF31rIVVtXcrjS4sfFm87AAgmn9Vt5gpp4GK0GSZ3nPSg3u9Oazn(uWVtWh)oWZ3(785vbREW(URJeFFhksnx8tvuPM)UMMbtt)7uMKYqlVk4VBsznUP6rbYA8PGFNGp(47vGuO(2)oI(2F31rIVVdztyc)oFEvWQhSp(De8T)URJeFFhKfggcJfyqtP5VZNxfS6b7JFND(2FNpVky1d2310myA6FNcCmjMcIxrEglbw(PUufUIx85vbR(URJeFFhALs9XVZ2)2F31rIVVZAlCEGku2KMn(P(oFEvWQhSp(D26B)D(8QGvpyF31rIVVdzk1dwvQ4JlqZuA(7AAgmn9VV3Gu4ybzk1dwvQ4JlqZuAEfPw68anOwTgKRJukUWh3KmCqBdIObr4GOEQkSu8flxPGR8gK9dIeqikuwB5uqCjYgEqTAniTLtbXWbz)GiyqeoiYeKvuOCJNhCqsAq267AJAbxcNcId4VJOp(DGNV935ZRcw9G9DnndMM(3RaKKlSPjMgaxggxaMdIWbj5bXhtbzCqsAq2UTguRwdkCbFXIyaKAPlkQl3IpVky1Gi(3DDK477MjmWIc0chF87STF7VZNxfS6b77AAgmn9VxbijxyttmnaUmmUamheHdsYdQcqsUarz(GsNhSixQLMPWfG5GA1AqvasYLgFA2fSQufaNIPvaiCbyoiI)Dxhj((UzcdSOaTWXh)oBZ3(7Uos89DyEjmyAbg0uA(785vbREW(43zZ)2FNpVky1d2310myA6FpCbFXsL0WyjOPwA4IpVky1GiCqACtfxmX5fWLIjtDgdY(Tbr0GKyqvasYvLIDfmv8cW87Uos89Dqyaq8hF8DTc(T)De9T)oFEvWQhSVRPzW00)o0KfIs4uqCahK9BdIGbr4G2BqvasYvv4kUqkaOuJlaZV76iX33RcxXfsbaLA8JFhbF7VZNxfS6b77AAgmn9VV3GGb7IWIvlxigeHdskNMEvWlVPcaTkA8PYiX3GiCqnomyAXHqhcZRq5gpp4G2ge4geHdsYdAVbrboMetbXlf7HLWybA5kSCWfFEvWQb1Q1GQaKKlf7HLWybA5kSCWLcl3nichKg3uXftCEbCqsABqemiI)Dxhj((Uu(LqRp(D25B)Dxhj((oPWbXcHhj((oFEvWQhSp(D2(3(785vbREW(UMMbtt)7kUcqsUifoiwi8iX3IYnEEWbjPbrW3DDK477KcheleEK4ROfSFq(JFNT(2FNpVky1d2310myA6FFVbvbijxUIYNlYJluaO1cWCqeoijpO9gKgJfkSC3s6uiYdubAszEbyoOwTg0EdkCbFXs6uiYdubAszEXNxfSAqe)7Uos89Dxr5Zf5Xfka06JFh45B)D(8QGvpyFxtZGPP)9kaj5IIfIsyXLk(y4IYnEEWbjPTbzNb1Q1GKYPPxf8Ig1cLPyH47Uos89DkwikHfxQ4JHF87STF7VZNxfS6b77Uos899gNknRkKyArXEy9DnndMM(3PEQkSu8flxPGlaZbr4GK8GcNcIJvKnCjWfvYdssdsJBQ4IjoVaUumzQZyqTAnO9gemyxewSArXGa4br4G04MkUyIZlGlftM6mgK9BdsBwAC5xGM8PgKnniIgeX)U2OwWLWPG4a(7i6JFNT5B)D(8QGvpyFxtZGPP)DQNQclfFXYvk4kVbz)GSd4gKnniQNQclfFXYvk4sbq9iX3GiCq7niyWUiSy1IIbbWdIWbPXnvCXeNxaxkMm1zmi73gK2S04YVan5tniBAqe9Dxhj((EJtLMvfsmTOypS(43zZ)2FNpVky1d2310myA6FxkNMEvWRQWvCHuaqPglqJNEqeoijpi(ykiJRiB4sGlnU8hK9dIGb1Q1GGMSqucNcId4GSFqemiI)Dxhj((U0PqKhOc0KY8h)oIa33(785vbREW(UMMbtt)7s500RcEvfUIlKcak1ybA80dIWbj5bXhtbzCfzdxcCPXL)GSFqemOwTge0KfIs4uqCahK9dIGbr8V76iX33RcxXfka06JFhre9T)oFEvWQhSVRPzW00)(EdcgSlclwTCHyqeoinUPIlM48c4GK02Gi67Uos89DfLDvv4kg(XVJic(2FNpVky1d2310myA6FFVbbd2fHfRwUqmichKuon9QGxEtfaAv04tLrIVV76iX33HwUclxdluF87iYoF7VZNxfS6b77AAgmn9VxbijxvbgReaWyrzxhdQvRbrMGSIcLB88GdssdYoGBqTAnOkaj5Yvu(CrECHcaTwaMF31rIVVBIJeFF87iY2)2F31rIVVxfySQqcqn(D(8QGvpyF87iYwF7V76iX33RmfYuPZd035ZRcw9G9XVJiWZ3(7Uos89DYKYvbgR(oFEvWQhSp(DezB)2F31rIVV7NMHb1ffTleFNpVky1d2h)oISnF7VZNxfS6b77AAgmn9VR4kaj5QYHCmFLWIlSrgUamheHdsYdAVbfUGVybYcddHXcmOP08IpVky1GA1AqkUcqsUazHHHWybg0uAEbyoiIpOwTgezcYkkuUXZdoijTnica33DDK477aqUKb3a)4JVdd2fH13(3r03(785vbREW(UMMbtt)7ACtfxmX5fWbz)2G0MLgx(fOjFQV76iX33vj00dT1h)oc(2F31rIVV7nvaO135ZRcw9G9XVZoF7VZNxfS6b77Uos89DTf7MfOfo(UMMbtt)7Hl4lwMu2ybFLWIlYXU0l(8QGvdIWbT3GcNcIJvclvme(DTrTGlHtbXb83r0hF8DY8sO13(3r03(785vbREW(UMMbtt)7vasYfuKAU4NQOsnVOCJNhCqsAqKjiROq5gpp4GiCquMKYqlVk4V76iX33HIuZf)ufvQ5p(De8T)URJeFFVYHCmFLWIlSrg(D(8QGvpyF87SZ3(7Uos89Dvcn9qB9D(8QGvpyF8XhFxkMct897iaCeaoIiGaBZ3LZPxEGGFFFrm3)DG3D7xW3GguBlEqzJjMgdIethKDvmPdic7oiktmaskRgee3WdYbcCJhSAqAl)aXW1yyFNhpiBh8niIfFsX0GvdYUA8PaYyjpS7Gc8GSRgFkGmwYJfFEvWk7oijtK8j(Ammg2xeZ9Fh4D3(f8nOb12Ihu2yIPXGiX0bzxTcA3brzIbqsz1GG4gEqoqGB8GvdsB5higUgd7784bra4Bqel(KIPbRgKDPahtIPG4L8WUdkWdYUuGJjXuq8sES4ZRcwz3bjzIKpXxJHXW(IyU)7aV72VGVbnO2w8GYgtmngejMoi7wbsHYUdIYedGKYQbbXn8GCGa34bRgK2YpqmCng235XdYoGVbrS4tkMgSAq2LcCmjMcIxYd7oOapi7sboMetbXl5XIpVkyLDhKhdYMjp33dsYejFIVgdJbWBJjMgSAqGNb56iX3GejmGRXW3HMS(3ra4bCF3KIjtb)DBmi5jqiC5g0(JbbWJbBmid(b4uJdIizhebGJaIgdJbBmiBM8znqWQbvzsmLhKg3u9yqvguEW1GiMAnBgWbD4ZMSCAdjGyqUos8bhe(egxJbxhj(GltkRXnvp2CttHXIjoH4Bm46iXhCzsznUP6HeBYuXriyvHu4gzLC5bQey5N3yW1rIp4YKYACt1dj2KbgSlcRXGRJeFWLjL14MQhsSjtJtLMvfsmTOypSK1KYACt1JcK14tb3SLSj5g1tvHLIVy5kfCLN9eyRXGRJeFWLjL14MQhsSjdfleLWIlv8XqznPSg3u9Oazn(uWncKnj3OCJNhus2zm46iXhCzsznUP6HeBYafPMl(PkQuZYAsznUP6rbYA8PGBeiBsUrzskdT8QGhdJbBmiBM8znqWQbXsXuJdkYgEqHfpixhy6Gs4GCP8u4vbVgdUos8b3Ko1spgSXG2FggSlcRbLKdYedHzvWdsYhEqsbioM6vbpi(4MKHdkVbPXnvpi(yW1rIpOeBYad2fH1yWgdA)zkwigempqcEqvass4GyNkmoiCyX0bfw(nO2uaEqGXonpqdYp1GaJIDfmv8yW1rIpOeBYiLttVkyzpVH3OrTqzkwiKvkxaWB0OwQaKKqjraHsEVkaj5kOaCPYonpqlatc3RcqsUQuSRGPIxaMeFmyJbzZoiaLhKC8GaXXGibeIbrmBQaqRbrSYRbbYZdoi)udYP8z3yquMIfI8aniIfdCXGclEqYtLcoOkajjCqUCUXXGRJeFqj2KrkNMEvWYEEdV5nvaOvrJpvgj(KvkxaWBACtfxmX5fWLIjtDg2VrGevasYvLIDfmv8cWKq(ykiJ2VzlWrOK3tJpfqglng4IsyXfSsbB1QcqsUOyHOewCPIpgUOCJNh0(nIahXhd2yq7RmSgudGistbpOWPG4ak7GcReoiPCA6vbpOeoiTfRLMvdkWdsX6uXdsoloSy6GG4gEqel4hoiOfgqOguLhe04Pz1GKldRbbMWv8G2pcak14yW1rIpOeBYiLttVkyzpVH3QcxXfsbaLASanEAzLYfa8g0KfIs4uqCaxvHR4cPaGsnkjciK6PQWsXxSCLcUYZEcaxRwvasYvv4kUqkaOuJlaZXGRJeFqj2KHcCfxhj(kIegYEEdVbd2fHLSj5gmyxewSA5cXyW1rIpOeBYODHO46iXxrKWq2ZB4nTcogSXG2p5LqRb5XGAC5NnandIyLxdQcedYLcNQbjNdJ8aniWOyxbtfpi)udAFai1spiWp1LBqv8bahKg3uXdYeNxahdUos8bLytgkWvCDK4Risyi75n8gzEj0s2KCtJBQ4IjoVaA)M2S04YVan5tztvasYvLIDfmv8cW0MKCfGKCHnnX0a4YW4cWCFkCbFXIyaKAPlkQl3IpVkyfXB1sJBQ4IjoVaU5x24AlNcIvfT5yW1rIpOeBYODHO46iXxrKWq2ZB4TkqkuJbxhj(GsSjJt1(XLatP8fYMKB8XuqgxkMm1zy)gr2sc(ykiJlkdIVXGRJeFqj2KXPA)4IjGaYJbxhj(GsSjJibzfWY(mGcudFXyW1rIpOeBYuDqfmzjOPwA4yymyJbbgqkumfogCDK4dUQaPqTbztychdUos8bxvGuOKytgqwyyimwGbnLMhdUos8bxvGuOKytgOvkLSj5gf4ysmfeVI8mwcS8tDPkCfpgCDK4dUQaPqjXMmS2cNhOcLnPzJFQXGRJeFWvfifkj2KbYuQhSQuXhxGMP0SSAJAbxcNcId4grYMKB7PWXcYuQhSQuXhxGMP08ksT05bQvlxhPuCHpUjz4gres9uvyP4lwUsbx5zpjGquOS2YPG4sKnCRwAlNcIH2taHKjiROq5gppOKS1yWgdsEdYdsELWalgu3chdsUmSgK800etdGldJdkjhuLfy5gKTBRbXhtbzu2bHPdsol(geampqdAFai1spiWp1LBm46iXhCvbsHsInzmtyGffOfoKnj3QaKKlSPjMgaxggxaMekz(ykiJsY2TvRwHl4lwedGulDrrD5w85vbRi(yW1rIp4QcKcLeBYyMWalkqlCiBsUvbijxyttmnaUmmUamjuYvasYfikZhu68Gf5sT0mfUamB1QcqsU04tZUGvLQa4umTcaHlatIpgCDK4dUQaPqjXMmW8syW0cmOP08yW1rIp4QcKcLeBYacdaILnj3cxWxSujnmwcAQLgU4ZRcwrOg3uXftCEbCPyYuNH9BejrfGKCvPyxbtfVamhdJbBmiIfJfkSChCmyJbbMWv8G2pcak14GW3GiqIbXh3KmCm46iXhCPvWTQWvCHuaqPgLnj3GMSqucNcIdO9Beq4EvasYvv4kUqkaOuJlaZXGngK8gmpqdIy2ubGwdkHdYhebY7huEAk7qw2bbXdsENFj0AqA)guLhee3Wr2WWbv5bbaz1GC4G8bbePidJdcAYcXGaobdHdcaMhObTp6WGPdIycHoeM3GW0bb(zpSeghu3Yvy5GJbxhj(GlTckXMms5xcTKnj32dgSlclwTCHGqPCA6vbV8Mka0QOXNkJeFe24WGPfhcDimVcLB88GBGJqjVhf4ysmfeVuShwcJfOLRWYbB1QcqsUuShwcJfOLRWYbxkSChHACtfxmX5fqjTraXhdUos8bxAfuInzifoiwi8iX3yW1rIp4sRGsSjdPWbXcHhj(kAb7hKLnj3uCfGKCrkCqSq4rIVfLB88GsIGXGRJeFWLwbLytgxr5Zf5Xfka0s2KCBVkaj5Yvu(CrECHcaTwaMek590ySqHL7wsNcrEGkqtkZlaZwT2lCbFXs6uiYdubAszEXNxfSI4Jbxhj(GlTckXMmuSquclUuXhdLnj3QaKKlkwikHfxQ4JHlk345bL0MDA1skNMEvWlAuluMIfIXGnge4LCqUsbhKt5bbyk7GGxAYdkS4bHpEqYLH1Gey5yymO2Tb)RbjVb5bjNfFdszmpqdI0Hbthuy53Giw51GumzQZyqy6GKldlmqmi)moiIvETgdUos8bxAfuInzACQ0SQqIPff7HLSAJAbxcNcId4grYMKBupvfwk(ILRuWfGjHsoCkiowr2WLaxujljnUPIlM48c4sXKPoJwT2dgSlclwTOyqamHACtfxmX5fWLIjtDg2VPnlnU8lqt(u2ereFmyJbbEjh0HhKRuWbjxkedsL8GKldR8guyXd6y5hdYoGdk7GaG8G2hjb)dcFdQIHWbjxgwyGyq(zCqeR8AngCDK4dU0kOeBY04uPzvHetlk2dlztYnQNQclfFXYvk4kp7Td4SjQNQclfFXYvk4sbq9iXhH7bd2fHfRwumiaMqnUPIlM48c4sXKPod730MLgx(fOjFkBIOXGRJeFWLwbLytgPtHipqfOjLzztYnPCA6vbVQcxXfsbaLASanEAcLmFmfKXvKnCjWLgx(2tqRwqtwikHtbXb0Eci(yW1rIp4sRGsSjtv4kUqbGwYMKBs500RcEvfUIlKcak1ybA80ekz(ykiJRiB4sGlnU8TNGwTGMSqucNcIdO9eq8XGRJeFWLwbLytgfLDvv4kgkBsUThmyxewSA5cbHACtfxmX5fqjTr0yW1rIp4sRGsSjd0Yvy5AyHs2KCBpyWUiSy1YfccLYPPxf8YBQaqRIgFQms8ngCDK4dU0kOeBYyIJeFYMKBvasYvvGXkbamwu21rRwKjiROq5gppOKSd4A1QcqsUCfLpxKhxOaqRfG5yW1rIp4sRGsSjtvGXQcja14yW1rIp4sRGsSjtLPqMkDEGgdUos8bxAfuInzitkxfySAm46iXhCPvqj2KXpnddQlkAxigd2yqGFM0beXGiDHO6APhejMoiaOxf8GYGBGRXGRJeFWLwbLytgaixYGBGYMKBkUcqsUQCihZxjS4cBKHlatcL8EHl4lwGSWWqySadAknV4ZRcw1QLIRaKKlqwyyimwGbnLMxaMeVvlYeKvuOCJNhusBeaUXWyWgdA)KxcTykCm46iXhCrMxcT2GIuZf)ufvQzztYTkaj5cksnx8tvuPMxuUXZdkjYeKvuOCJNhKqktszOLxf8yWgdcSWMni8ningluy5Ubf4bjnZMdkS4brS0mgKIRaKKdcWCm46iXhCrMxcTKytMkhYX8vclUWgz4yW1rIp4ImVeAjXMmQeA6H2AmmgSXG6b7IWAm46iXhCbd2fH1MkHMEOTKnj304MkUyIZlG2VPnlnU8lqt(uJbxhj(GlyWUiSKytgVPcaTgdUos8bxWGDryjXMmAl2nlqlCiR2OwWLWPG4aUrKSj5w4c(ILjLnwWxjS4ICSl9IpVkyfH7fofehRewQyi8Jp(ha]] )

end