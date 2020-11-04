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
        }
    } )


    spec:RegisterStateExpr( "rtb_buffs", function ()
        return buff.roll_the_bones.count
    end )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )


    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance" },
        mantle  = { "stealth", "vanish" },
        all     = { "stealth", "vanish", "shadow_dance", "shadowmeld" }
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
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains )
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
        end
    end )

    spec:RegisterHook( "reset_precast", function( amt, resource )
        if buff.killing_spree.up then setCooldown( "global_cooldown", max( gcd.remains, buff.killing_spree.remains ) ) end
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

            usable = function () return stealthed.all end,            
            handler = function ()
                if debuff.dreadblades.up then
                    gain( combo_points.max, "combo_points" )
                else
                    gain( buff.broadside.up and 3 or 2, "combo_points" )
                end
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
                if talent.prey_on_the_weak.enabled then
                    applyDebuff( "target", "prey_on_the_weak", 6 )
                end

                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                applyDebuff( "target", "between_the_eyes", combo_points.current ) 

                if azerite.deadshot.enabled then
                    applyBuff( "deadshot" )
                end

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
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
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

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

            -- Disable Gouge because we can't tell if we're in front of the target to use it.
            usable = function () return false end,
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
            
            spend = function () return legendary.tiny_toxic_blades.enabled and 0 or 20 end,
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
                return not ( boss and group )
            end,

            handler = function ()
                applyBuff( "vanish", 3 )
                applyBuff( "stealth" )

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end

                if legendary.invigorating_shadowdust.enabled then
                    for name, cd in pairs( cooldown ) do
                        if cd.remains > 0 then reduceCooldown( name, 15 ) end
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

        potion = "potion_of_unbridled_fury",

        package = "Outlaw",
    } )

    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = "full"
    } )  


    spec:RegisterPack( "Outlaw", 20201103, [[d4e3(aqirHhjLkBsvPpjLQQrbsCkqsRIOeEfrQzrKClPu0Ue5xuIgMOOJbsTmqLNjkPPPQQCnrPSnrj8nPuvgNukCorPsRtuIY8uvL7bI9rjCqrjYcjkEirjzIIsfxKOezJQQQQpsuIsJKOefNukvXkLsMjrjvUjrjL2jOQFQQQIHQQQkhLOKILkLQ0tvLPckDvvvvAReLO6RIsuTxe)LIbJ0HPAXs1JjzYK6YO2Ss(mr1OLItlz1eLu1RbfZMWTfv7wXVbgoL64IsvlhQNdz6cxxP2UQIVRQY4jk15jI1lLsZNsA)QmbAcSKN2dMapCzcxMqdDMznbxwZwBaDwjVqIntE2UcgxotEJNZK3)zhc)h5z7seaxtGL8qGnwXKxte2OSmlTuEfn7EsbYTev5BHhfyuyFfwIQCLLKxFxIO9mKo5P9GjWdxMWLj0qNzwtWL1S1gzMfKhYMve4HllYK8AkTMhsN80msrET7O)NDi8FhT9cKV5Rv7ok8GpCENXhnRsDu4YeUmjpBmyvcM8A3r)p7q4)oA7fiFZxR2Du4bF48oJpAwL6OWLjCzETUwT7OYsYMv7G1hTZlaMpQcK394ODwEnO0rZskfBhOJoGPnBCC(AloQRIcmOJcgHK01YvrbguYgZkqE3diUTTqIXguiWCTCvuGbLSXScK39qAiwM7yyyTzbWgn7rJu2ywbY7EyqScmAeKSjvTGG9sB4p8ejxRrPAS4FzETCvuGbLSXScK39qAiwIc2frJu1ccuYGZ(DzBZ6KnqbdhOQTS2Oa527WJcmgn)PuSvRzOaaHg8BskjkbiWGPuMUWrrsVXEuGXQvSxAd)HNivZNTyyS3fCILDHceuVwUkkWGs2ywbY7EinelXaHWenSPdggjLnMvG8UhgeRaJgbboPQfemVWmQX7c(A5QOadkzJzfiV7H0qSejkfB8rB0LILYgZkqE3ddIvGrJGaNu1ccMxyg14DbFTCvuGbLSXScK39qAiw6AmpUOg2G3OgPSXScK39WGyfy0iiqlvTGaLm4SFx22SozduWWbQAlRnkqU9o8OaJrZFkfB1AgkaqOb)MKsIsacmykLPlCuK0BShfySAf7L2WF4js18zlgg7DbNyzxOab1RLRIcmOKnMvG8UhsdXYnInvW5snEodXBlQXXoYSatyalJn4hJVwUkkWGs2ywbY7Einel3i2ubNlfVwSkmJNZqusucqGbtPmDHJcPQfKmWEPn8hEIunF2IHXExWjw2fkqxRRv7oQSKSz1oy9r5pmwYrJkNpA0Wh1vbaF0cDu)JxcVl401YvrbgeeykfmxR2D02lJc2frZrR1rTbiu1f8rHYao6NTyyS3f8r5HZlgD0AoQcK39aQxlxffyqsdXsuWUiAUwT7OYQngZtiKC0beh9hahnhfZyGquJ8JwZrFY6oAnh1hjhfMb8BokQIThfyUwUkkWGKgILFCC5Dbl145meC0nygdecP(4IndjZRLRIcmiPHy5hhxExWsnEodXZ7BuJrbgDffyK6Jl2mefiVdm2GAcusZRsvHfqGtA4KfqjCbprsEdafcjguGly4epExW6VkaqOb)MK8gakesmOaxWWjmN71G(dAOkDFVwPog4AuP502(lpmwUelYIm)MrFVwjemBHW4J2OWaeQdggL22FZOVxRemmBBKa2yZVkqgVd2HrcyN22xR2D0S8kAoA(weLTGpA4y5CGK6OrtHo6hhxExWhTqhv1Wkyy9rdWr1SQ08r)1WrdJpkcKZhvwLDqhf1a2c9r78rrsgfRp6VkAoQmcxZh9)l2ySKRLRIcmiPHy5hhxExWsnEodPlCnBwInglXGKmkP(4IndbzZcHjCSCoqPUW1Szj2ySK)G7l2lTH)WtKCTgLQXc4Y0Q1(ETsDHRzZsSXyjPT91YvrbgK0qSu5cHXvrbgJOqHuJNZqqb7IOrQAbbfSlIgwNCH4A5QOadsAiwQCHW4QOaJruOqQXZzikn6A1UJ()RPqnh1JJM7YUY35hvw9)sh9T7Oa7Q4OGHp6cGpk7QMJkdg4AuP5J6J(O)hBBao2tfso6VgEoQSMDPG5OzhS)7Of6OiwWQG1h1h9rL1UYohTqhDaXrXSRLCuFfm(OrdF0HLDCueRaJoD0SK4NlbD0Cx2hvMqw6O)QO5OWj9rZskoDTCvuGbjnelX7X4QOaJruOqQXZziRAkuJu1cIcK3bgBqnbYcikBtUlBdYMhDBcL(ETsDmW1OsZPTT099ALa22aCSNkKK22qvwaLWf8ePSFxkymAS)lXJ3fS(luYiCbprk3XWWAZcGnA2JMepExWARwvaGqd(nPChddRnla2OzpAsyo3Rbzb0qfQYcO4TLXvWjxXMTTrcyJnibZF4e2hy(doRwZqbacn43K6C8J5XenSHLWO02gQwTQa5DGXgutGG4tL7QghlN1gL91YvrbgK0qSu5cHXvrbgJOqHuJNZq67sOVwUkkWGKgILow5dBcagZtivTGWdJLljP5vPQWciqNnP5HXYLKWSCEUwUkkWGKgILow5dBS3ceFTCvuGbjnelfL8MazK1V1YZ5jUwUkkWGKgILDxUbSmbUuWGUwxR2Duz2LqZy01YvrbguQVlHgcQP(ivTGG3dVay5CkQrIjaYUuMUW1CIZ(DzBZ6RLRIcmOuFxcT0qSKvnGAKBWSnUY9rFTCvuGbL67sOLgILigJ9G1MoyydYUGHLsjrjyt4y5CGGaTu1csgAqKqmg7bRnDWWgKDbdNIsbtnYTA1vr9Hn8W5fJGa9xSxAd)HNi5AnkvJfRTqyWSQXXYztu5SvRQghlNrwa33vjVjmyo3Rb9x2UwT7O)xeF0)xHcG4OVgqC0Fv0C0)JTnah7PcjhTwhTZcWVJ(VSDuEySCjsDua(O)A45OBunYpQSMDPG5OzhS)7O(OpAwEfOJwOJQb)M01YvrbguQVlHwAiwAxOaimOgqivTG03RvcyBdWXEQqsAB)fk8Wy5s(7FzZQ1Wf8ePSFxkymAS)lXJ3fS(BFVwjyy22ibSXMFvGmEhSdJeWoPb)gOETCvuGbL67sOLgIL2fkacdQbesvli99ALa22aCSNkKK22FHsFVwjn7AudisBBRw771kjhZ8GGPgK5xPGHXO022Q1(ETskWOyxWAtxShnJ7BekTTH61YvrbguQVlHwAiwIQPqbJnOaxWWxRRv7oQScaeAWVbDTCvuGbLuAeeLlegxffymIcfsnEodHriEumsQAbjduWUiAyDYfIRLRIcmOKsJKgILlHlNfcpkWCTCvuGbLuAK0qSCjC5Sq4rbgJsW(GyPQfen33RvAjC5Sq4rbMeMZ9Aq)b31YvrbgusPrsdXsxJ5Xf1Wg8g1ivTGKrFVwjxJ5Xf1Wg8g1K22FHsgkaqOb)MemLquJCdYgZCABB1AgHl4jsWucrnYniBmZjE8UG1q9luYGZ(DzBZ6K3wuJJDKzbMWawgBWpgB1QcaeAWVjj8GNW4yLpEcZ5EnilGltOETCvuGbLuAK0qSedect0WMoyyKu1csFVwjmqimrdB6GHrjmN71G(dswTA9JJlVl4eo6gmJbcX1QDhT9SoQR1OJ6y(OBBPokAkB(OrdFuWWh9xfnhva(XO4OWcB2jD0)lIp6VgEoQwsnYp6YrbJpA04ZrLv)VJQ5vPQ4Oa8r)vrdyhh1hjhvw9)sxlxffyqjLgjnelZDmmS2SayJM9OrkLeLGnHJLZbcc0svliyV0g(dprY1AuAB)fkHJLZrkQC2eaJU4)uG8oWydQjqjnVkvfwTMbkyxenSoHbY38xfiVdm2GAcusZRsvHfqu2MCx2gKnp62eAOETA3rBpRJoGJ6An6O)kH4O6Ip6VkAQ5OrdF0HLDC0SMjsQJUr8rL1UYohfmhTdqOJ(RIgWooQpsoQS6)LUwUkkWGsknsAiwM7yyyTzbWgn7rJu1cc2lTH)WtKCTgLQXISMzBI9sB4p8ejxRrj9g7rbMVzGc2frdRtyG8n)vbY7aJnOMaL08QuvybeLTj3LTbzZJUnH(A1UJkJW18r))Ingl5OG5OWj9r5HZlgLo6d2J(RIMJMLY7LMLDW4kKC0AD0bCuxRrhTMJgn8rhw2XrHotu6A5QOadkP0iPHyzx4A2SeBmwIu1ccYMfct4y5CGSacCTPcm6DfjpVxAw2bJRqsIhVly93m671k1fUMnlXgJLK22FXEPn8hEIKR1OunwaDMxlxffyqjLgjnelL3aqHqIbf4cgwQAbrbY7aJnOMaL08QuvybeOLUVxRuhdCnQ0CABFTCvuGbLuAK0qSeMsiQrUbzJzwQAb5JJlVl4ux4A2SeBmwIbjzuFr2SqychlNduQlCnBwInglXcO)YdJLljfvoBcGj3LTfWDTCvuGbLuAK0qSSlCnBWBuJu1cYhhxExWPUW1Szj2ySedsYO(YdJLljfvoBcGj3LTfWDTA3r)VOAKFuz5(uOglZs59nQ5Of6OGri5O(r)WyjhnQrYrRrHzhXsDue4O1Cum7IkKi1rLa2TFmFuVJaIDWcjhDvdF0aC0nIpAfh1rh1p6okrfsokYMfI01YvrbgusPrsdXYp(uOgPQfKmqb7IOH1jxi((XXL3fCYZ7BuJrbgDffyUwUkkWGsknsAiwQXSR7cxZiPQfKmqb7IOH1jxi(Qa5DGXgutG(dc0xlxffyqjLgjnelrnUg8lNfAPQfKmqb7IOH1jxi((XXL3fCYZ7BuJrbgDffyUwUkkWGsknsAiwIyBuHKQwqYafSlIgwNCH4A5QOadkP0iPHyPnikWivTG03RvQlaaTyJIeMDvy1AFVwjxJ5Xf1Wg8g1K22xlxffyqjLgjnel7caqBwBSKRLRIcmOKsJKgILDgJymm1i)A5QOadkP0iPHy5QWCxaa6RLRIcmOKsJKgIL(OyuGDHr5cX1YvrbgusPrsdXYnInvW5sXRfRcZ45meLeLaeyWuktx4OqQAbjduWUiAyDYfIV99ALCnMhxudBWButsd(nF771kLZ5aSedyzeBvPnAm75OKg8B(YdJLljfvoBcGj3LTf)7lo6M(ETq)LTRLRIcmOKsJKgILBeBQGZLA8CgI3wuJJDKzbMWawgBWpglvTGKrFVwjxJ5Xf1Wg8g1K22FZOVxRux4A2SeBmwsAB)vbacn43KCnMhxudBWButcZ5EnO)GoBxR2Duz5mwYrXGT8gHKJI3c(OG1rJMDEVwfRpAUhnOJ2zb4xw2r)Vi(Ola(OTNbgBG(OkCfsDuq0W4FfIp6VkAoAwQ9EupokCzk9rrHRGbDua(OqNP0h9xfnh1fiWrLraa6JUTtxlxffyqjLgjnel3i2ubNl145meh18XhgzWEBbyJcGDHu1cIM771kH92cWgfa7cJM771kPb)gRw1CFVwjfy0BvuFytnWy0CFVwPT93WXY5i1WUiAs2Q4VSc33WXY5i1WUiAs2QWcizntRwZqZ99ALuGrVvr9Hn1aJrZ99AL22FHIM771kH92cWgfa7cJM771kHcxbJfqGlZ2e6mLfAUVxRuxaaAdyzIg2WdNljTTTADvYBcdMZ9Aq)Lfzc1V99ALCnMhxudBWButcZ5EnilGUnUwT7OzhE5BrC0LleDxbZrxa8r3iVl4JwbNJsxlxffyqjLgjnel3i2ubNJKQwq671k1faGwSrrcZUkSADvYBcdMZ9Aq)bbUmTAvbY7aJnOMaL08Quv8he4UwxR2DuzjeIhfJUwUkkWGsmcXJIrquGrXtG9G1MLWZzPQfeEySCjPOYztam5USTa6Vz03RvQlCnBwIngljTT)cLm0GiPaJINa7bRnlHNZM(gpPOuWuJ8Vz4QOatsbgfpb2dwBwcpNt1ywIsEty16AlegmRACSC2evo)NCLoL7YgQxlxffyqjgH4rXiPHyzxaaAdyzIg2WdNlrQAb5JJlVl4ux4A2SeBmwIbjzuFvaGqd(nPoh)yEmrdByjmkTT)cfKnleMWXY5aL6cxZMLyJXsSacCwTI9sB4p8ejxRrPAS4FzdQxlxffyqjgH4rXiPHyP8TJ1LpgWY4TLXGO5A5QOadkXiepkgjnelxa1gXAJ3wgxbB6SNlvTGGSzHWeowohOux4A2SeBmwIfqGZQvSxAd)HNi5AnkvJfzrMFZOVxRKRX84IAydEJAsB7RLRIcmOeJq8OyK0qS0EJRLKAKB6chfsvliiBwimHJLZbk1fUMnlXgJLybe4SAf7L2WF4jsUwJs1yrwK51YvrbguIriEumsAiwgnSzpDWE0MfaRyPQfK(ETsywbJGriZcGvCABB1AFVwjmRGrWiKzbWk2Oa7jyCcfUcM)GoZRLRIcmOeJq8OyK0qSex22c2uJbz7k(A5QOadkXiepkgjnel)bWc9hUgdMrGXhfFTCvuGbLyeIhfJKgIL5CoalXawgXwvAJgZEosQAbHhglxYF)lBxR2Duzzac9rBVSBxJ8J()fEoJo6cGpklBwTd(OyFKZhfGpkmLqC0(ETqsD0ADuBacvDbNoAws8ZLGoAGLC0aCu5CC0OHpQa8JrXrvaGqd(nhT7iwFuWCu)JxcVl4JYdNxmkDTCvuGbLyeIhfJKgILy2TRrUzj8CgjLsIsWMWXY5abbAPQfKWXY5ifvoBcGrx8FqNYMvRqbkHJLZrQHDr0KSvHfTrMwTgowohPg2frtYwf)bbUmH6xO4QO(WgE48IrqG2Q1poU8UGty2TRrUrZcxIfWLDHkuTAfkHJLZrkQC2eaJTkmWLPfznZVqXvr9Hn8W5fJGaTvRFCC5DbNWSBxJCJMfUel(3)GkuVwxR2D0)FnfQHXORv7oQmHS0rbZrvaGqd(nhnahfgMTpA0WhvwHR4OAUVxRJUTVwUkkWGsRAkudKoh)yEmrdByjm6A5QOadkTQPqnsdXsKOuSXhTrxkwQAbPVxResuk24J2OlfNWCUxd6VvjVjmyo3Rb9TVxResuk24J2OlfNWCUxd6pOaT0kqEhySb1eiOklGo1gxlxffyqPvnfQrAiwQlKThQMR11QDh9fSlIMRLRIcmOekyxenqunSBBqnGqkLeLGnHJLZbcc0svliHl4js2ywIbmMOHn)yhMepExW6VzeowohPcz6ae6A5QOadkHc2frJ0qS0Z7Bud59HXOcme4Hlt4Ye6mH7FK3php1ihrEz5zP2l8Th4LLnl7Ohf2g(OvUnahhDbWhT9R0O2)rXC2VlmRpkcKZh13bi3dwFuvJpYzu6AjRRg(Oznl7O)3bTTTb4G1h1vrbMJ2(xcxoleEuGXOeSpiU9NUwxR2tUnahS(OTVJ6QOaZrffkqPRf557ObGjVxLlRiprHcebwYJriEumIalbEOjWsE84DbRjYqEkCfmUCYJhglxskQC2eatUl7JAXrH(OFpAghTVxRux4A2SeBmwsABF0VhfkhnJJQbrsbgfpb2dwBwcpNn9nEsrPGPg5h97rZ4OUkkWKuGrXtG9G1MLWZ5unMLOK3eh1Q1JU2cHbZQghlNnrLZh9VJkxPt5USpkujpxffyipfyu8eypyTzj8CMee4HJal5XJ3fSMid5PWvW4YjVpoU8UGtDHRzZsSXyjgKKrD0Vhvbacn43K6C8J5XenSHLWO02(OFpkuokYMfct4y5CGsDHRzZsSXyjh1cihfUJA16rXEPn8hEIKR1Ounh1IJ(VSDuOsEUkkWqEDbaOnGLjAydpCUesqGpReyjpxffyip5BhRlFmGLXBlJbrd5XJ3fSMidjiW)pcSKhpExWAImKNcxbJlN8q2SqychlNduQlCnBwIngl5Owa5OWDuRwpk2lTH)WtKCTgLQ5OwC0SiZJ(9OzC0(ETsUgZJlQHn4nQjTTjpxffyiVfqTrS24TLXvWMo75KGaF2iWsE84DbRjYqEkCfmUCYdzZcHjCSCoqPUW1Szj2ySKJAbKJc3rTA9OyV0g(dprY1AuQMJAXrZImjpxffyip7nUwsQrUPlCuqcc8zbbwYJhVlynrgYtHRGXLtE99ALWScgbJqMfaR402(OwTE0(ETsywbJGriZcGvSrb2tW4ekCfmh9VJcDMKNRIcmKx0WM90b7rBwaSIjbb(2hbwYZvrbgYdx22c2uJbz7kM84X7cwtKHee4BdcSKNRIcmK3pawO)W1yWmcm(OyYJhVlynrgsqGp7sGL84X7cwtKH8u4kyC5KhpmwUKJ(3r)x2ipxffyiVCohGLyalJyRkTrJzphrcc8qNjbwYJhVlynrgYZvrbgYdZUDnYnlHNZiYtHRGXLtEHJLZrkQC2eaJU4J(3rHoLTJA16rHYrHYrdhlNJud7IOjzRIJAXrBJmpQvRhnCSCosnSlIMKTko6FqokCzEuOE0Vhfkh1vr9Hn8W5fJokKJc9rTA9OFCC5DbNWSBxJCJMfUKJAXrHl7EuOEuOEuRwpkuoA4y5CKIkNnbWyRcdCzEuloAwZ8OFpkuoQRI6dB4HZlgDuihf6JA16r)44Y7coHz3Ug5gnlCjh1IJ(V)DuOEuOsEkjkbBchlNdebEOjbjipnV8TiiWsGhAcSKNRIcmKhmLcgYJhVlynrgsqGhocSKNRIcmKhkyxenKhpExWAImKGaFwjWsE84DbRjYqEaBYdXb55QOad59XXL3fm59XfBM8YK8(4yZ45m5HJUbZyGqqcc8)Jal5XJ3fSMid5bSjpehKNRIcmK3hhxExWK3hxSzYtbY7aJnOMaL08QuvCulGCu4oQ0hfUJklokuoA4cEIK8gakesmOaxWWjE8UG1h97rvaGqd(nj5nauiKyqbUGHtyo3RbD0)ok0hfQhv6J23RvQJbUgvAoTTp63JYdJLl5OwC0SiZJ(9OzC0(ETsiy2cHXhTrHbiuhmmkTTp63JMXr771kbdZ2gjGn28RcKX7GDyKa2PTn59XXMXZzYZZ7BuJrbgDffyibb(SrGL84X7cwtKH8a2KhIdYZvrbgY7JJlVlyY7Jl2m5HSzHWeowohOux4A2SeBmwYr)7OWD0Vhf7L2WF4jsUwJs1CulokCzEuRwpAFVwPUW1Szj2ySK02M8(4yZ45m51fUMnlXgJLyqsgfjiWNfeyjpE8UG1ezipfUcgxo5Hc2frdRtUqqEUkkWqEkximUkkWyefkiprHcZ45m5Hc2frdjiW3(iWsE84DbRjYqEUkkWqEkximUkkWyefkiprHcZ45m5P0isqGVniWsE84DbRjYqEkCfmUCYtbY7aJnOMaDulGCuLTj3LTbzZJ(OT5rHYr771k1XaxJknN22hv6J23RvcyBdWXEQqsABFuOEuzXrHYrdxWtKY(DPGXOX(VepExW6J(9Oq5OzC0Wf8ePChddRnla2OzpAs84DbRpQvRhvbacn43KYDmmS2SayJM9OjH5CVg0rT4OqFuOEuOEuzXrHYr92Y4k4KRyZ22ibSXgKG5pCc7dmh9VJc3rTA9OzCufai0GFtQZXpMht0WgwcJsB7Jc1JA16rvG8oWydQjqhfYr9PYDvJJLZAJYM8CvuGH8W7X4QOaJruOG8efkmJNZK3QMc1qcc8zxcSKhpExWAImKNRIcmKNYfcJRIcmgrHcYtuOWmEotE9Dj0KGap0zsGL84X7cwtKH8u4kyC5KhpmwUKKMxLQIJAbKJcD2oQ0hLhglxscZY5H8CvuGH8CSYh2eamMNGee4HgAcSKNRIcmKNJv(Wg7TaXKhpExWAImKGap0WrGL8CvuGH8eL8MazK1V1YZ5jipE8UG1ezibbEOZkbwYZvrbgYR7YnGLjWLcge5XJ3fSMidjib5zJzfiV7bbwc8qtGL8CvuGH8CBBHeJnOqGH84X7cwtKHee4HJal5XJ3fSMid55QOad5L7yyyTzbWgn7rd5PWvW4YjpSxAd)HNi5AnkvZrT4O)ltYZgZkqE3ddIvGrJiVSrcc8zLal5XJ3fSMid5PWvW4YjpOC0mokN97Y2M1jBGcgoqvBzTrbYT3HhfymA(tP4JA16rZ4OkaqOb)MKsIsacmykLPlCuK0BShfyoQvRhf7L2WF4js18zlgg7DbNyzxOaDuOsEUkkWqEOGDr0qcc8)Jal5XJ3fSMid55QOad5HbcHjAythmmI8u4kyC5KhMxyg14DbtE2ywbY7EyqScmAe5bhjiWNncSKhpExWAImKNRIcmKhsuk24J2OlftEkCfmUCYdZlmJA8UGjpBmRa5DpmiwbgnI8GJee4ZccSKhpExWAImKNRIcmKNRX84IAydEJAipfUcgxo5bLJMXr5SFx22SozduWWbQAlRnkqU9o8OaJrZFkfFuRwpAghvbacn43KusucqGbtPmDHJIKEJ9OaZrTA9OyV0g(dprQMpBXWyVl4el7cfOJcvYZgZkqE3ddIvGrJipOjbb(2hbwYJhVlynrgYB8CM882IACSJmlWegWYyd(XyYZvrbgYZBlQXXoYSatyalJn4hJjbb(2Gal5XJ3fSMid55QOad5PKOeGadMsz6chfKNcxbJlN8Y4OyV0g(dprQMpBXWyVl4el7cfiYJxlwfMXZzYtjrjabgmLY0fokibjiVvnfQHalbEOjWsEUkkWqEDo(X8yIg2Wsye5XJ3fSMidjiWdhbwYJhVlynrgYtHRGXLtE99ALqIsXgF0gDP4eMZ9Aqh9VJUk5nHbZ5EnOJ(9O99ALqIsXgF0gDP4eMZ9Aqh9VJcLJc9rL(OkqEhySb1eOJc1Jklok0P2G8CvuGH8qIsXgF0gDPysqGpReyjpxffyipDHS9q1qE84DbRjYqcsqEOGDr0qGLap0eyjpE8UG1ezipxffyipvd72gudiipfUcgxo5fUGNizJzjgWyIg28JDys84DbRp63JMXrdhlNJuHmDacrEkjkbBchlNdebEOjbbE4iWsEUkkWqEEEFJAipE8UG1ezibjipLgrGLap0eyjpE8UG1ezipfUcgxo5LXrrb7IOH1jxiipxffyipLlegxffymIcfKNOqHz8CM8yeIhfJibbE4iWsEUkkWqElHlNfcpkWqE84DbRjYqcc8zLal5XJ3fSMid5PWvW4Yjpn33RvAjC5Sq4rbMeMZ9Aqh9VJch55QOad5TeUCwi8OaJrjyFqmjiW)pcSKhpExWAImKNcxbJlN8Y4O99ALCnMhxudBWButABF0VhfkhnJJQaaHg8BsWucrnYniBmZPT9rTA9OzC0Wf8ejykHOg5gKnM5epExW6Jc1J(9Oq5OzCuo73LTnRtEBrno2rMfycdyzSb)y8rTA9OkaqOb)MKWdEcJJv(4jmN71GoQfhfUmpkujpxffyipxJ5Xf1Wg8g1qcc8zJal5XJ3fSMid5PWvW4YjV(ETsyGqyIg20bdJsyo3RbD0)GC0SEuRwp6hhxExWjC0nygdecYZvrbgYddect0WMoyyejiWNfeyjpE8UG1ezipxffyiVChddRnla2OzpAipfUcgxo5H9sB4p8ejxRrPT9r)EuOC0WXY5ifvoBcGrx8r)7OkqEhySb1eOKMxLQIJA16rZ4OOGDr0W6egiFZh97rvG8oWydQjqjnVkvfh1cihvzBYDzBq28OpABEuOpkujpLeLGnHJLZbIap0KGaF7Jal5XJ3fSMid5PWvW4YjpSxAd)HNi5AnkvZrT4OznZJ2Mhf7L2WF4jsUwJs6n2Jcmh97rZ4OOGDr0W6egiFZh97rvG8oWydQjqjnVkvfh1cihvzBYDzBq28OpABEuOjpxffyiVChddRnla2OzpAibb(2Gal5XJ3fSMid5PWvW4YjpKnleMWXY5aDulGCu4oABEufy07ksEEV0SSdgxHKepExW6J(9OzC0(ETsDHRzZsSXyjPT9r)EuSxAd)HNi5AnkvZrT4OqNj55QOad51fUMnlXgJLqcc8zxcSKhpExWAImKNcxbJlN8uG8oWydQjqjnVkvfh1cihf6Jk9r771k1XaxJknN22KNRIcmKN8gakesmOaxWWKGap0zsGL84X7cwtKH8u4kyC5K3hhxExWPUW1Szj2ySedsYOo63JISzHWeowohOux4A2SeBmwYrT4OqF0VhLhglxskQC2eatUl7JAXrHJ8CvuGH8GPeIAKBq2yMjbbEOHMal5XJ3fSMid5PWvW4YjVpoU8UGtDHRzZsSXyjgKKrD0VhLhglxskQC2eatUl7JAXrHJ8CvuGH86cxZg8g1qcc8qdhbwYJhVlynrgYtHRGXLtEzCuuWUiAyDYfIJ(9OFCC5DbN88(g1yuGrxrbgYZvrbgY7JpfQHee4HoReyjpE8UG1ezipfUcgxo5LXrrb7IOH1jxio63JQa5DGXgutGo6Fqok0KNRIcmKNgZUUlCnJibbEO)hbwYJhVlynrgYtHRGXLtEzCuuWUiAyDYfIJ(9OFCC5DbN88(g1yuGrxrbgYZvrbgYd14AWVCwOjbbEOZgbwYJhVlynrgYtHRGXLtEzCuuWUiAyDYfcYZvrbgYdX2Ocrcc8qNfeyjpE8UG1ezipfUcgxo513RvQlaaTyJIeMDvCuRwpAFVwjxJ5Xf1Wg8g1K22KNRIcmKNnikWqcc8q3(iWsEUkkWqEDbaOnRnwc5XJ3fSMidjiWdDBqGL8CvuGH86mgXyyQro5XJ3fSMidjiWdD2Lal55QOad5Tkm3faGM84X7cwtKHee4HltcSKNRIcmKNpkgfyxyuUqqE84DbRjYqcc8WbnbwYJhVlynrgYZvrbgYtjrjabgmLY0fokipfUcgxo5LXrrb7IOH1jxio63J23RvY1yECrnSbVrnjn43C0VhTVxRuoNdWsmGLrSvL2OXSNJsAWV5OFpkpmwUKuu5SjaMCx2h1IJ(VJ(9O4OB671cD0)oA2ipETyvygpNjpLeLaeyWuktx4OGee4HdocSKhpExWAImKNRIcmKN3wuJJDKzbMWawgBWpgtEkCfmUCYlJJ23RvY1yECrnSbVrnPT9r)E0moAFVwPUW1Szj2ySK02(OFpQcaeAWVj5AmpUOg2G3OMeMZ9Aqh9VJcD2iVXZzYZBlQXXoYSatyalJn4hJjbbE4YkbwYJhVlynrgYZvrbgYZrnF8HrgS3wa2OayxqEkCfmUCYtZ99ALWEBbyJcGDHrZ99AL0GFZrTA9OAUVxRKcm6TkQpSPgymAUVxR02(OFpA4y5CKAyxenjBvC0)oAwH7OFpA4y5CKAyxenjBvCulGC0SM5rTA9OzCun33Rvsbg9wf1h2udmgn33RvABF0VhfkhvZ99ALWEBbyJcGDHrZ99ALqHRG5Owa5OWL5rBZJcDMhvwCun33RvQlaaTbSmrdB4HZLK22h1Q1JUk5nHbZ5EnOJ(3rZImpkup63J23RvY1yECrnSbVrnjmN71GoQfhf62G8gpNjph18XhgzWEBbyJcGDbjiWd3)iWsE84DbRjYqEkCfmUCYRVxRuxaaAXgfjm7Q4OwTE0vjVjmyo3RbD0)GCu4Y8OwTEufiVdm2GAcusZRsvXr)dYrHJ8CvuGH82i2ubNJibjiV(UeAcSe4HMal5XJ3fSMid5PWvW4Yjp8E4falNtrnsmbq2LY0fUMtC2VlBBwtEUkkWqEOM6djiWdhbwYZvrbgYJvnGAKBWSnUY9rtE84DbRjYqcc8zLal5XJ3fSMid55QOad5Hym2dwB6GHni7cgM8u4kyC5KxghvdIeIXypyTPdg2GSly4uukyQr(rTA9OUkQpSHhoVy0rHCuOp63JI9sB4p8ejxRrPAoQfhDTfcdMvnowoBIkNpQvRhv14y5m6OwCu4o63JUk5nHbZ5EnOJ(3rZg5PKOeSjCSCoqe4HMee4)hbwYJhVlynrgYtHRGXLtE99ALa22aCSNkKK22h97rHYr5HXYLC0)o6)Y2rTA9OHl4jsz)UuWy0y)xIhVly9r)E0(ETsWWSTrcyJn)Qaz8oyhgjGDsd(nhfQKNRIcmKNDHcGWGAabjiWNncSKhpExWAImKNcxbJlN8671kbSTb4ypvijTTp63JcLJ23RvsZUg1aI02(OwTE0(ETsYXmpiyQbz(vkyymkTTpQvRhTVxRKcmk2fS20f7rZ4(gHsB7JcvYZvrbgYZUqbqyqnGGee4ZccSKNRIcmKhQMcfm2GcCbdtE84DbRjYqcsqcsqccb]] )

end