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


    spec:RegisterPack( "Outlaw", 20201106, [[d0Kf(aqirrpsvbBsvLpjkb1OGOCkvv1QGOkVIizwePULOuAxI8lkPgMOWXGelds5zQkY0uvuxtusBJOeFtukACIs05uvOSoIsknpvv5EqyFusoOOuyHefpKOKmrrj0fHOs2ievLrcrvfNeIkALsPMjevv6Mquv1oHu9tvfQgkevQJsusXsHOcpvPMkK0vfLaBLOKQ(krjv2lO)sXGr6WuTyP6XKmzsDzuBwjFMOA0sXPLSArjiVgImBc3wuTBf)gy4uQJRQqwoINd10fUUQSDPKVRQ04jk15jI1lkvZNsSFvgIcev4w7bdrhTmqlduqjdzjH2NYilZAwc3HeBgUTDfsUCgUhpNH7p(le(x422LiaUgIkCJbpIIH7MiSXYAT2A5v086jfi3ACL)eEuGrr8vynUYvwd39xjcKZb2HBThmeD0YaTmqbLmKLeAFkJSmRFgUX2ScIoAYsgWDtP18a7WTMXk4(dh9J)cH)9Oiha5p(A)HJIoOfN3zYrLfPpkAzGwgWTnbSkbd3F4OF8xi8Vhf5ai)Xx7pCu0bT48otoQSi9rrld0Y4AFT)WrrUKnREbRpANxacFufiV7Xr7S8AWPJMnuk2oWhDat224K81tCuxffyWhfmcjPRTRIcm4KnHvG8UhiCBBHeJnOWG5A7QOadoztyfiV7HuiSo3jiXAZcqmA2JgPTjScK39WGzfy0yezv6AHG4L2WT4jsUwJt1y1NZ4A7QOadoztyfiV7HuiSghSlIgPRfcKLj)rVY2M1jBGcjoWv2zTrbYTFHhfymAUvPylwYubacn47KusucqqatPmDHJJK(r8OaJfleV0gUfprQMwpXWeVl4el7ch4)V2UkkWGt2ewbY7EifcRjaHWenSPdgglTnHvG8UhgmRaJgJanPRfccVimUX7c(A7QOadoztyfiV7HuiSglkfB8rB0LIL2MWkqE3ddMvGrJrGM01cbHxeg34DbFTDvuGbNSjScK39qkew7AcpUOg2qE4gPTjScK39WGzfy0yeOiDTqGSm5p6v22SozduiXbUYoRnkqU9l8OaJrZTkfBXsMkaqObFNKsIsaccykLPlCCK0pIhfySyH4L2WT4js106jgM4DbNyzx4a))12vrbgCYMWkqE3dPqy9dZMk4CPhpNr4zh34ehBwGjmGLXg8LjxBxffyWjBcRa5DpKcH1pmBQGZLMxlwfMXZzekjkbiiGPuMUWXH01crMeV0gUfprQMwpXWeVl4el7ch4R91(dhf5s2S6fS(OClMi5OrLZhnA4J6QaqoAHpQ3YlH3fC6A7QOadgbsLcPR9hokYbJd2frZrR1rTbyC1f8rr2aoARNyyI3f8r5HZlgF0AoQcK394)RTRIcmyPqynoyxenx7pCuz1Jq4jeso6aIJ(fqIMJsycqiQr(rR5OBKFpAnh1hjhfPb8DokUINhfyU2UkkWGLcH1TCs5Dbl945mcs0neMaecPB5IhJiJRTRIcmyPqyDlNuExWspEoJWZ7pCJrbgDffyKULlEmcfiVdm2GAcCsZRsvHviqtk0qEilCbprsEdahcjgCqkK4epExW6FkaqObFNK8gaoesm4GuiXjcN71G)dL)LQ)wRuNaCnU0C6z)JhMixIvYsg)YS)wRegPNqy8rBueag3bdJtp7Fz2FRvcjMTnsapI5BfyJ3bVWib8sp7R9hoQSUkAoA(teLTGpA4e5CGL(OrtHpAlNuExWhTWhv1WkKy9rdWr1SQ08r)2WrdtokgKZhvwLfXhf3aEc9r78rXsgfRp63kAoQmcxZhf5t8iejxBxffyWsHW6woP8UGLE8Cgrx4A2SepcrIblzus3Yfpgb2Mfct4e5CGtDHRzZs8iej)H2pIxAd3INi5AnovJvOLHfl93AL6cxZML4rissp7RTRIcmyPqyTYfcJRIcmgrHdPhpNrGd2frJ01cboyxenSo5cX12vrbgSuiSw5cHXvrbgJOWH0JNZiuA81(dhf5RMc3CupoAUl7k)LFuzfYD6O7xhhexfhfm8rxaYrzx1CuziaxJlnFuF0h9JBBdiXBQqYr)2WZrL18kfshnls8VhTWhfZcwfS(O(OpkY)vw8Of(OdiokHDTKJ6RGjhnA4JoSSJJIzfy0PJMneFDj4JM7Y(OYeixh9BfnhfnPoA2qXPRTRIcmyPqyn5ngxffymIchspEoJyvtHBKUwiuG8oWydQjWwHqzBYDzBW28OZwK1FRvQtaUgxAo9SLQ)wReW2gqI3uHK0Z(FKhYcxWtK(OxPqYOj(3epExW6FilZWf8ePCNGeRnlaXOzpAs84DbRTyrbacn47KYDcsS2SaeJM9Ojr4CVgSvO8))ipK5zNjvWjxXMNTrc4rmybZT4eXhK(dnlwYubacn47K6C8L5XenSHLW40Z(FlwuG8oWydQjWi8PYDvJtKZAJY(A7QOadwkewRCHW4QOaJru4q6XZze9xj0xBxffyWsHWANO8HnbGq4jKUwi4HjYLK08QuvyfcuYQu8We5ssewopxBxffyWsHWANO8Hn2pbMV2UkkWGLcH1IsEtGnzHEA558exBxffyWsHW6Ul3awMGukKWx7R9hoQmVsOzc(A7QOado1FLqJa3uTKUwiiVHxaICof1iXeazxktx4AoXF0RSTz912vrbgCQ)kHwkewZQgqnYne2Mu5(OV2UkkWGt9xj0sHWAmtiEWAthmSbBxiXsRKOeSjCICoWiqr6AHitnisyMq8G1Moyyd2UqItrPqQg5wS4QOAXgE48IXiq5hXlTHBXtKCTgNQXQ1timew14e5SjQC2IfvJtKZyRq73QK3egcN71G)lRx7pC0SamFuK7chaXr3nG4OFRO5OFCBBajEtfsoAToANfGVh9Zz9O8We5sK(OaYr)2WZrF4AKFuznVsH0rZIe)7r9rFuzDvGpAHpQg8DsxBxffyWP(ReAPqyTDHdGWGBaH01cr)TwjGTnGeVPcjPN9pKXdtKl5VpNvlwcxWtK(OxPqYOj(3epExW6F93ALqIzBJeWJy(wb24DWlmsaVKg8D()A7QOado1FLqlfcRTlCaegCdiKUwi6V1kbSTbK4nvij9S)HS(BTsA214gqKE2wS0FRvsoH5bJunyZ3sHetWPNTfl93ALuGrXUG1MU4nAM0FyC6z))12vrbgCQ)kHwkewJRPWbtm4GuiXx7R9hoQScaeAW3bFTDvuGbNuAmcLlegxffymIchspEoJGXyEumw6AHitCWUiAyDYfIRTRIcm4KsJLcH1lHlNfcpkWCTDvuGbNuASuiSEjC5Sq4rbgJsW(GzPRfcn3FRvAjC5Sq4rbMeHZ9AW)H212vrbgCsPXsHWAxt4Xf1WgYd3iDTqKz)Twjxt4Xf1WgYd3KE2)qwMkaqObFNesLquJCd2MWC6zBXsMHl4jsivcrnYnyBcZjE8UG1))dzzYF0RSTzDYZoUXjo2SatyalJn4ltSyrbacn47KeEWtyCIYhpr4CVgSvOLX)xBxffyWjLglfcRjaHWenSPdgglDTq0FRvIaect0WMoyyCIW5En4)q8jlwA5KY7corIUHWeGqCT)Wrroxh11A8rDcF0NT0hfpLnF0OHpky4J(TIMJkaFzCCuurnlMoAwaMp63gEoQwsnYp6YXbtoA04ZrLvi3hvZRsvXrbKJ(TIgWloQpsoQSc5oDTDvuGbNuASuiSo3jiXAZcqmA2JgPvsuc2eorohyeOiDTqq8sB4w8ejxRXPN9pKforohPOYztam6I)tbY7aJnOMaN08QuvyXsM4GDr0W6ebi)X)uG8oWydQjWjnVkvfwHqzBYDzBW28OZwu()A)HJICUo6aoQR14J(TeIJQl(OFROPMJgn8rhw2Xr)ugyPp6dZhf5)klEuWC0oaJp63kAaV4O(i5OYkK7012vrbgCsPXsHW6CNGeRnlaXOzpAKUwiiEPnClEIKR14unw9PmYwIxAd3INi5AnoPFepkW8ltCWUiAyDIaK)4FkqEhySb1e4KMxLQcRqOSn5USnyBE0zlkx7pCuzeUMpkYN4risokyokAsDuE48IXPJUr9OFRO5OzJ8EPzzhmPcjhTwhDah11A8rR5OrdF0HLDCuuYaNU2UkkWGtknwkew3fUMnlXJqKiDTqGTzHWeorohyRqGw2QaJ(vrYZ7LMLDWKkKK4X7cw)lZ(BTsDHRzZs8iejPN9pIxAd3INi5AnovJvOKX12vrbgCsPXsHWA5naCiKyWbPqILUwiuG8oWydQjWjnVkvfwHafP6V1k1jaxJlnNE2xBxffyWjLglfcRrQeIAKBW2eMLUwiA5KY7co1fUMnlXJqKyWsg1pEyICjPOYztam5USTcTRTRIcm4KsJLcH1DHRzd5HBKUwiA5KY7co1fUMnlXJqKyWsg1pEyICjPOYztam5USTcTR9hoAwaUg5hvwVpfUX6SrE)HBoAHpkyesoQF0wmrYrJAKC0Aue2XS0hfdoAnhLWUOcjsFujGxwycFuVJbIxWcjhDvdF0aC0hMpAfh1Xh1p6lkrfsok2MfI012vrbgCsPXsHW6w(u4gPRfImXb7IOH1jxi(1YjL3fCYZ7pCJrbgDffyU2UkkWGtknwkewRjSR7cxZyPRfImXb7IOH1jxi(Pa5DGXgutG)dbkxBxffyWjLglfcRXnUg8nNfAPRfImXb7IOH1jxi(1YjL3fCYZ7pCJrbgDffyU2UkkWGtknwkewJzBCHLUwiYehSlIgwNCH4A7QOadoP0yPqyTnikWiDTq0FRvQlaaT4HJeHDvyXs)Twjxt4Xf1WgYd3KE2xBxffyWjLglfcR7caqBwpIKRTRIcm4KsJLcH1DMGzcs1i)A7QOadoP0yPqy9QiCxaa6RTRIcm4KsJLcH1(OyCqCHr5cX12vrbgCsPXsHW6hMnvW5sZRfRcZ45mcLeLaeeWuktx44q6AHitCWUiAyDYfIF93ALCnHhxudBipCtsd(o)6V1kLZ5aIedyzepvPnAc754Kg8D(XdtKljfvoBcGj3LTvF(hj6M(BTW)L1RTRIcm4KsJLcH1pmBQGZLE8CgHNDCJtCSzbMWawgBWxMiDTqKz)Twjxt4Xf1WgYd3KE2)YS)wRux4A2Sepcrs6z)tbacn47KCnHhxudBipCtIW5En4)qjRx7pCuz9mrYrjGN8gHKJsEc(OG1rJMxEVwfRpAUhn4J2zb4RS2JMfG5JUaKJICoizd0hvrQq6JcIgM8TW8r)wrZrZgihh1JJIwgsDuC4kKWhfqokkzi1r)wrZrDbgCuzeaG(Op7012vrbgCsPXsHW6hMnvW5spEoJWXnT8HXgINDaXOaexiDTqO5(BTsep7aIrbiUWO5(BTsAW3XIfn3FRvsbg9tfvl2udsgn3FRv6z)lCICosnSlIMKTk(7tO9lCICosnSlIMKTkScXNYWILm1C)Twjfy0pvuTytniz0C)TwPN9pKP5(BTsep7aIrbiUWO5(BTs4Wvizfc0YiBrjdKNM7V1k1faG2awMOHn8W5sspBlwwL8MWq4CVg8FYsg))R)wRKRj84IAyd5HBseo3RbBfkz51(dhnlYl)jIJUCHO7kKo6cqo6d7DbF0k4CC6A7QOadoP0yPqy9dZMk4CS01cr)TwPUaa0Ihose2vHflRsEtyiCUxd(peOLHflkqEhySb1e4KMxLQI)qG21(A)HJICHX8Oy812vrbgCIXyEumgHcmkEcIhS2SeEolDTqWdtKljfvoBcGj3LTvO8lZ(BTsDHRzZs8iejPN9pKLPgejfyu8eepyTzj8C20FKjfLcPAK)ltxffyskWO4jiEWAZs45CQgZsuYBclwwpHWqyvJtKZMOY5)KR0PCx2)FTDvuGbNymMhfJLcH1DbaOnGLjAydpCUePRfIwoP8UGtDHRzZs8iejgSKr9tbacn47K6C8L5XenSHLW40Z(hYW2SqycNiNdCQlCnBwIhHiXkeOzXcXlTHBXtKCTgNQXQpN1)V2UkkWGtmgZJIXsHWA5pNOlFmGLXZotarZ12vrbgCIXyEumwkewVaQhM1gp7mPc20zpx6AHaBZcHjCICoWPUW1SzjEeIeRqGMfleV0gUfprY1ACQgRKLm(Lz)Twjxt4Xf1WgYd3KE2xBxffyWjgJ5rXyPqyT9Julj1i30fooKUwiW2SqycNiNdCQlCnBwIhHiXkeOzXcXlTHBXtKCTgNQXkzjJRTRIcm4eJX8OySuiSoAyZB6G3OnlarXsxle93ALiScjbJXMfGO40Z2IL(BTsewHKGXyZcquSrbEtWKeoCfs)HsgxBxffyWjgJ5rXyPqynPSTfSPgd22v812vrbgCIXyEumwkew)fqe6wCngcJbJpk(A7QOadoXympkglfcRZ5CarIbSmINQ0gnH9CS01cbpmrUK)(CwV2F4Oi)ae6JICWUDnYpkYNWZz8rxaYrzzZQxWhL4JC(OaYrrQeIJ2FRfw6JwRJAdW4Ql40rZgIVUe8rdIKJgGJkNJJgn8rfGVmooQcaeAW35ODhZ6JcMJ6T8s4DbFuE48IXPRTRIcm4eJX8OySuiSMWUDnYnlHNZyPvsuc2eorohyeOiDTqeorohPOYztam6I)dLuwTybzilCICosnSlIMKTkSklZWILWjY5i1WUiAs2Q4peOLX))qMRIQfB4HZlgJaflwA5KY7cory3Ug5gnlCjwH2h7))TybzHtKZrkQC2eaJTkmOLHvFkJFiZvr1In8W5fJrGIflTCs5DbNiSBxJCJMfUeR(8N)))R91(dhf5RMc3We81(dhvMa56OG5OkaqObFNJgGJIeZ2hnA4JkRivCun3FR1rF2xBxffyWPvnfUbrNJVmpMOHnSegFTDvuGbNw1u4gPqynwuk24J2OlflDTq0FRvclkfB8rB0LIteo3Rb)3QK3egcN71G)1FRvclkfB8rB0LIteo3Rb)hYqrkfiVdm2GAc8)ipusz512vrbgCAvtHBKcH16cB7HQ5AFT)Wr3b7IO5A7QOadoHd2frdcvd72gCdiKwjrjyt4e5CGrGI01cr4cEIKnHLyaJjAyZx2rkXJ3fS(xMHtKZrQWMoaJV2UkkWGt4GDr0ifcR98(d3a3TycUadeD0YaTmqbLm(eC)1jtnYXWnYzUnGeS(OzZJ6QOaZrffoWPRnC7VObqG7DLlRGBrHdmev4MXyEumgIkeDuGOc384DbRHYa3ksfmPC4MhMixskQC2eatUl7JA1rr5O)oAMhT)wRux4A2Sepcrs6zF0FhfzhnZJQbrsbgfpbXdwBwcpNn9hzsrPqQg5h93rZ8OUkkWKuGrXtq8G1MLWZ5unMLOK3eh1ILJUEcHHWQgNiNnrLZh9VJkxPt5USp6)WTRIcmWTcmkEcIhS2SeEoddi6ObrfU5X7cwdLbUvKkys5WDlNuExWPUW1SzjEeIedwYOo6VJQaaHg8DsDo(Y8yIg2WsyC6zF0FhfzhfBZcHjCICoWPUW1SzjEeIKJAfIJI2rTy5OeV0gUfprY1ACQMJA1r)Cwp6)WTRIcmWDxaaAdyzIg2WdNlbgq0)eev42vrbg4w(Zj6Yhdyz8SZeq0a384DbRHYadi6FgIkCZJ3fSgkdCRivWKYHBSnleMWjY5aN6cxZML4risoQviokAh1ILJs8sB4w8ejxRXPAoQvhvwY4O)oAMhT)wRKRj84IAyd5HBspB42vrbg4EbupmRnE2zsfSPZEomGONviQWnpExWAOmWTIubtkhUX2SqycNiNdCQlCnBwIhHi5OwH4OODulwokXlTHBXtKCTgNQ5OwDuzjd42vrbg42(rQLKAKB6chhWaIUSarfU5X7cwdLbUvKkys5WD)TwjcRqsWySzbiko9SpQflhT)wReHvijym2SaefBuG3emjHdxH0r)7OOKbC7QOadChnS5nDWB0MfGOyyarpBcrfUDvuGbUjLTTGn1yW2UIHBE8UG1qzGbe9SeIkC7QOadC)fqe6wCngcJbJpkgU5X7cwdLbgq0)yquHBE8UG1qzGBfPcMuoCZdtKl5O)D0pNv42vrbg4oNZbejgWYiEQsB0e2ZXWaIokzarfU5X7cwdLbUDvuGbUjSBxJCZs45mgUvKkys5WD4e5CKIkNnbWOl(O)Duusz9OwSCuKDuKD0WjY5i1WUiAs2Q4OwD0SmJJAXYrdNiNJud7IOjzRIJ(hIJIwgh9)J(7Oi7OUkQwSHhoVy8rrCuuoQflhTLtkVl4eHD7AKB0SWLCuRokAFSJ()r))OwSCuKD0WjY5ifvoBcGXwfg0Y4OwD0pLXr)DuKDuxfvl2WdNxm(Oiokkh1ILJ2YjL3fCIWUDnYnAw4soQvh9ZF(O)F0)HBLeLGnHtKZbgIokWagWTMx(tequHOJcev42vrbg4gPsHeCZJ3fSgkdmGOJgev42vrbg4ghSlIg4MhVlynugyar)tquHBE8UG1qzGBGnCJ5aUDvuGbUB5KY7cgUB5Ihd3za3TCIz8CgUjr3qycqiGbe9pdrfU5X7cwdLbUb2WnMd42vrbg4ULtkVly4ULlEmCRa5DGXgutGtAEvQkoQviokAhvQJI2rrEhfzhnCbprsEdahcjgCqkK4epExW6J(7OkaqObFNK8gaoesm4GuiXjcN71Gp6FhfLJ()rL6O93AL6eGRXLMtp7J(7O8We5soQvhvwY4O)oAMhT)wRegPNqy8rBueag3bdJtp7J(7OzE0(BTsiXSTrc4rmFRaB8o4fgjGx6zd3TCIz8CgU98(d3yuGrxrbgyarpRquHBE8UG1qzGBGnCJ5aUDvuGbUB5KY7cgUB5Ihd3yBwimHtKZbo1fUMnlXJqKC0)okAh93rjEPnClEIKR14unh1QJIwgh1ILJ2FRvQlCnBwIhHij9SH7woXmEod3DHRzZs8iejgSKrbdi6Ycev4MhVlynug4wrQGjLd34GDr0W6KleWTRIcmWTYfcJRIcmgrHd4wu4WmEod34GDr0adi6ztiQWnpExWAOmWTRIcmWTYfcJRIcmgrHd4wu4WmEod3knggq0ZsiQWnpExWAOmWTIubtkhUvG8oWydQjWh1kehvzBYDzBW28OpA2EuKD0(BTsDcW14sZPN9rL6O93ALa22as8MkKKE2h9)JI8okYoA4cEI0h9kfsgnX)M4X7cwF0FhfzhnZJgUGNiL7eKyTzbign7rtIhVly9rTy5OkaqObFNuUtqI1MfGy0ShnjcN71GpQvhfLJ()r))OiVJISJ6zNjvWjxXMNTrc4rmybZT4eXhKo6FhfTJAXYrZ8OkaqObFNuNJVmpMOHnSegNE2h9)JAXYrvG8oWydQjWhfXr9PYDvJtKZAJYgUDvuGbUjVX4QOaJru4aUffomJNZW9QMc3adi6FmiQWnpExWAOmWTRIcmWTYfcJRIcmgrHd4wu4WmEod39xj0WaIokzarfU5X7cwdLbUvKkys5WnpmrUKKMxLQIJAfIJIswpQuhLhMixsIWY5bUDvuGbUDIYh2eacHNagq0rbfiQWTRIcmWTtu(Wg7NaZWnpExWAOmWaIokObrfUDvuGbUfL8MaBYc90YZ5jGBE8UG1qzGbeDu(eev42vrbg4U7YnGLjiLcjmCZJ3fSgkdmGbCBtyfiV7bevi6OarfUDvuGbUDBBHeJnOWGbU5X7cwdLbgq0rdIkCZJ3fSgkdC7QOadCN7eKyTzbign7rdCRivWKYHBIxAd3INi5AnovZrT6OFod42MWkqE3ddMvGrJH7Scdi6FcIkCZJ3fSgkdCRivWKYHBKD0mpk)rVY2M1jBGcjoWv2zTrbYTFHhfymAUvP4JAXYrZ8OkaqObFNKsIsaccykLPlCCK0pIhfyoQflhL4L2WT4js106jgM4DbNyzx4aF0)HBxffyGBCWUiAGbe9pdrfU5X7cwdLbUDvuGbUjaHWenSPdggd3ksfmPC4MWlcJB8UGHBBcRa5DpmywbgngUrdgq0Zkev4MhVlynug42vrbg4glkfB8rB0LIHBfPcMuoCt4fHXnExWWTnHvG8UhgmRaJgd3Obdi6Ycev4MhVlynug42vrbg421eECrnSH8WnWTIubtkhUr2rZ8O8h9kBBwNSbkK4axzN1gfi3(fEuGXO5wLIpQflhnZJQaaHg8DskjkbiiGPuMUWXrs)iEuG5OwSCuIxAd3INivtRNyyI3fCILDHd8r)hUTjScK39WGzfy0y4gfyarpBcrfU5X7cwdLbUhpNHBp74gN4yZcmHbSm2GVmbUDvuGbU9SJBCIJnlWegWYyd(YeyarplHOc384DbRHYa3UkkWa3kjkbiiGPuMUWXbCRivWKYH7mpkXlTHBXtKQP1tmmX7coXYUWbgU51IvHz8CgUvsucqqatPmDHJdyad4EvtHBGOcrhfiQWTRIcmWDNJVmpMOHnSegd384DbRHYadi6ObrfU5X7cwdLbUvKkys5WD)TwjSOuSXhTrxkor4CVg8r)7ORsEtyiCUxd(O)oA)TwjSOuSXhTrxkor4CVg8r)7Oi7OOCuPoQcK3bgBqnb(O)FuK3rrjLLWTRIcmWnwuk24J2Olfddi6FcIkC7QOadCRlSThQg4MhVlynugyad4ghSlIgiQq0rbIkCZJ3fSgkdC7QOadCRAy32GBabCRivWKYH7Wf8ejBclXagt0WMVSJuIhVly9r)D0mpA4e5CKkSPdWy4wjrjyt4e5CGHOJcmGOJgev42vrbg42Z7pCdCZJ3fSgkdmGbCR0yiQq0rbIkCZJ3fSgkdCRivWKYH7mpkoyxenSo5cbC7QOadCRCHW4QOaJru4aUffomJNZWnJX8OymmGOJgev42vrbg4EjC5Sq4rbg4MhVlynugyar)tquHBE8UG1qzGBfPcMuoCR5(BTslHlNfcpkWKiCUxd(O)Du0GBxffyG7LWLZcHhfymkb7dMHbe9pdrfU5X7cwdLbUvKkys5WDMhT)wRKRj84IAyd5HBsp7J(7Oi7OzEufai0GVtcPsiQrUbBtyo9SpQflhnZJgUGNiHuje1i3GTjmN4X7cwF0)p6VJISJM5r5p6v22So5zh34ehBwGjmGLXg8Ljh1ILJQaaHg8Dscp4jmor5JNiCUxd(OwDu0Y4O)d3UkkWa3UMWJlQHnKhUbgq0Zkev4MhVlynug4wrQGjLd393ALiaHWenSPdggNiCUxd(O)H4OF6OwSC0woP8UGtKOBimbieWTRIcmWnbieMOHnDWWyyarxwGOc384DbRHYa3UkkWa35objwBwaIrZE0a3ksfmPC4M4L2WT4jsUwJtp7J(7Oi7OHtKZrkQC2eaJU4J(3rvG8oWydQjWjnVkvfh1ILJM5rXb7IOH1jcq(Jp6VJQa5DGXgutGtAEvQkoQvioQY2K7Y2GT5rF0S9OOC0)HBLeLGnHtKZbgIokWaIE2eIkCZJ3fSgkdCRivWKYHBIxAd3INi5AnovZrT6OFkJJMThL4L2WT4jsUwJt6hXJcmh93rZ8O4GDr0W6ebi)Xh93rvG8oWydQjWjnVkvfh1kehvzBYDzBW28OpA2EuuGBxffyG7CNGeRnlaXOzpAGbe9SeIkCZJ3fSgkdCRivWKYHBSnleMWjY5aFuRqCu0oA2Eufy0VksEEV0SSdMuHKepExW6J(7OzE0(BTsDHRzZs8iejPN9r)DuIxAd3INi5AnovZrT6OOKbC7QOadC3fUMnlXJqKadi6FmiQWnpExWAOmWTIubtkhUvG8oWydQjWjnVkvfh1kehfLJk1r7V1k1jaxJlnNE2WTRIcmWT8gaoesm4GuiXWaIokzarfU5X7cwdLbUvKkys5WDlNuExWPUW1SzjEeIedwYOo6VJYdtKljfvoBcGj3L9rT6OOb3UkkWa3ivcrnYnyBcZWaIokOarfU5X7cwdLbUvKkys5WDlNuExWPUW1SzjEeIedwYOo6VJYdtKljfvoBcGj3L9rT6OOb3UkkWa3DHRzd5HBGbeDuqdIkCZJ3fSgkdCRivWKYH7mpkoyxenSo5cXr)D0woP8UGtEE)HBmkWOROadC7QOadC3YNc3adi6O8jiQWnpExWAOmWTIubtkhUZ8O4GDr0W6Kleh93rvG8oWydQjWh9pehff42vrbg4wtyx3fUMXWaIokFgIkCZJ3fSgkdCRivWKYH7mpkoyxenSo5cXr)D0woP8UGtEE)HBmkWOROadC7QOadCJBCn4Bol0WaIokzfIkCZJ3fSgkdCRivWKYH7mpkoyxenSo5cbC7QOadCJzBCHHbeDuKfiQWnpExWAOmWTIubtkhU7V1k1faGw8WrIWUkoQflhT)wRKRj84IAyd5HBspB42vrbg42gefyGbeDuYMquHBxffyG7Uaa0M1JibU5X7cwdLbgq0rjlHOc3UkkWa3DMGzcs1ihU5X7cwdLbgq0r5JbrfUDvuGbUxfH7caqd384DbRHYadi6OLbev42vrbg42hfJdIlmkxiGBE8UG1qzGbeD0qbIkCZJ3fSgkdC7QOadCRKOeGGaMsz6chhWTIubtkhUZ8O4GDr0W6Kleh93r7V1k5AcpUOg2qE4MKg8Do6VJ2FRvkNZbejgWYiEQsB0e2ZXjn47C0FhLhMixskQC2eatUl7JA1r)8r)Dus0n93AHp6FhnRWnVwSkmJNZWTsIsaccykLPlCCadi6OHgev4MhVlynug42vrbg42ZoUXjo2SatyalJn4ltGBfPcMuoCN5r7V1k5AcpUOg2qE4M0Z(O)oAMhT)wRux4A2Sepcrs6zF0Fhvbacn47KCnHhxudBipCtIW5En4J(3rrjRW945mC7zh34ehBwGjmGLXg8LjWaIoAFcIkCZJ3fSgkdC7QOadC74Mw(WydXZoGyuaIlGBfPcMuoCR5(BTsep7aIrbiUWO5(BTsAW35OwSCun3FRvsbg9tfvl2udsgn3FRv6zF0FhnCICosnSlIMKTko6Fh9tOD0FhnCICosnSlIMKTkoQvio6NY4OwSC0mpQM7V1kPaJ(PIQfBQbjJM7V1k9Sp6VJISJQ5(BTsep7aIrbiUWO5(BTs4WviDuRqCu0Y4Oz7rrjJJI8oQM7V1k1faG2awMOHn8W5ssp7JAXYrxL8MWq4CVg8r)7OYsgh9)J(7O93ALCnHhxudBipCtIW5En4JA1rrjlH7XZz42XnT8HXgINDaXOaexadi6O9ziQWnpExWAOmWTIubtkhU7V1k1faGw8WrIWUkoQflhDvYBcdHZ9AWh9pehfTmoQflhvbY7aJnOMaN08QuvC0)qCu0GBxffyG7hMnvW5yyad4U)kHgIkeDuGOc384DbRHYa3ksfmPC4M8gEbiY5uuJetaKDPmDHR5e)rVY2M1WTRIcmWnUPAbdi6ObrfUDvuGbUzvdOg5gcBtQCF0WnpExWAOmWaI(NGOc384DbRHYa3UkkWa3yMq8G1Moyyd2UqIHBfPcMuoCN5r1GiHzcXdwB6GHny7cjofLcPAKFulwoQRIQfB4HZlgFuehfLJ(7OeV0gUfprY1ACQMJA1rxpHWqyvJtKZMOY5JAXYrvnoroJpQvhfTJ(7ORsEtyiCUxd(O)D0Sc3kjkbBcNiNdmeDuGbe9pdrfU5X7cwdLbUvKkys5WD)TwjGTnGeVPcjPN9r)DuKDuEyICjh9VJ(5SEulwoA4cEI0h9kfsgnX)M4X7cwF0FhT)wResmBBKaEeZ3kWgVdEHrc4L0GVZr)hUDvuGbUTlCaegCdiGbe9ScrfU5X7cwdLbUvKkys5WD)TwjGTnGeVPcjPN9r)DuKD0(BTsA214gqKE2h1ILJ2FRvsoH5bJunyZ3sHetWPN9rTy5O93ALuGrXUG1MU4nAM0FyC6zF0)HBxffyGB7chaHb3acyarxwGOc3UkkWa34AkCWedoifsmCZJ3fSgkdmGbmGbmGq]] )

end