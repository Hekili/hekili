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


    spec:RegisterPack( "Outlaw", 20201020, [[d8eD)aqirrpsvcBsvQpjkvIrbkCkvjTkqr6vejZIi6wIsv7sKFjkmmkPogi1YaLEgOOMMOKUMuI2MOe9nvjIXjLGZrjPADuskmpPKUhi2hrvhuucwirLhsjjMOOuXfvLOSrqr0iPKKOtQkrALsPEPOujntkjj1nPKKYojs9trj0qvLO6OussyPGIWtvvtLiCvkjL2kLKI(QOuPolLKKSxK(lPgmIdt1ILQhtYKP4YO2Ss(mrz0sXPLSAkjP61QIMnHBlQ2TIFdmCk1XLsOLd1ZHmDHRRuBxv47GKXtjX5bvRxukZNsSFvMcnvc634btLgwRH1AOTgwRtqB1ZQ1W2c0Fa3MPFBx90LX0)45m9Nf3HWHI(TD4cGBOsq)iWgRy6VjcBKvJmYqwfn7EsbYZav5BHhfyuyFfzGQCvg0FFxI4Lo0o9B8GPsdR1WAn0wdR1jOT6z1AyPFKnROsdBwAn93ugdp0o9ByKI(FXrYI7q4qDeycGSnFTFXrYIQa0z8rG1AjpcSwdR10VngSkbt)V4izXDiCOocmbq2MV2V4izrva6m(iWATKhbwRH16R91(fh5LzfwTd2CKoVay(ikqE3JJ0zz1GshjlOuSDGoYaMSVXX5RT4iUkkWGocyeWtxBxffyqjBmRa5DpG422c4ABqHaZ12vrbguYgZkqE3dPGKrUJFYg9cG1g2JgjTXScK39qJyfymiiTuYAbb7LrZp4jsUXGs1iFwT(A7QOadkzJzfiV7HuqYafSlIgjRfeyKj3I7Y2MnjBG6jhOkBSrRa527WJcmAd)OuSflzQaaHba1KuWvcqGbtP0DHJIKzJ9OaJflyVmA(bprQMhBXWyVl4eBLcfOxV2UkkWGs2ywbY7EifKmWaHqhnSUdggjPnMvG8UhAeRaJbbbwjRfemVWmQX7c(A7QOadkzJzfiV7HuqYajkfR9XOnLIL0gZkqE3dnIvGXGGaRK1ccMxyg14DbFTDvuGbLSXScK39qkiz4gmpUOgwJ3OgjTXScK39qJyfymiiqlzTGaJm5wCx22Sjzdup5avzJnAfi3EhEuGrB4hLITyjtfaimaOMKcUsacmykLUlCuKmBShfySyb7LrZp4js18ylgg7DbNyRuOa9612vrbguYgZkqE3dPGKXgX6k4CjhpNH4zd14yhPxGj0GL2gafJV2UkkWGs2ywbY7EifKm2iwxbNljVwSk0JNZquWvcqGbtP0DHJcjRfKmXEz08dEIunp2IHXExWj2kfkqx7R9loYlZkSAhS5i8dgd)irLZhjA4J4QaGpsHoI)WlH3fC6A7QOadcYZs98A)IJatWOGDr0CKADeBacvDbFeymGJ8ylgg7DbFeE48IrhPMJOa5DpE9A7QOadskizGc2frZ1(fhXQSXyEcb8JmG4iqbWrZrWmgie1i7i1CKVv1hPMJ4d8J8CaqnhbvX2JcmxBxffyqsbjJhoU8UGLC8Cgco6AmJbcHKpCXMHy912vrbgKuqY4HJlVlyjhpNH459nQrRaJPIcms(WfBgIcK3bABqnbkz4vPQqEiWkfSWuyeUGNijRbGcbCnkW1toXJ3fS5Tcaegautswdafc4AuGRNCcZ5EnOwH(vP671k1Xa3GkdN22V5HXYGlFwA97m771kHEUfcTpgTcdqOoyyuAB)oZ(ETspz2wdhSXAOQaP9oyhA4GDABFTFXrYURO5i5Bru2c(iHJLXbsYJenf6ipCC5DbFKcDevdREYMJeGJyyvz4Javdhnm(iiqoFeRs2bDeudylmhPZhbbFuS5iqvrZrKt4g(iWKIngd)A7QOadskiz8WXL3fSKJNZq6c3W6LyJXW1i4JsYhUyZqq2SqOdhlJduQlCdRxIngdVvyFJ9YO5h8ej3yqPAKhwRTyPVxRux4gwVeBmgEABFTDvuGbjfKmuUqODvuGrlkui545meuWUiAKSwqqb7IOHnjxiU2UkkWGKcsgkxi0UkkWOffkKC8CgIYGU2V4iWK1uOMJ4XrYDRu578JyvE5PJ83DuGDvCeWWhzbWhHDvZrKddCdQm8r8XCKSOTnah7Pc4hbQgEoIvf7s98izhSd1rk0rqSGvbBoIpMJyvBLDosHoYaIJGz3a)i(ky8rIg(idBL4iiwbgt6izbbuoC0rYDRCe5Ix2rGQIMJaRuhjlO4012vrbgKuqYaVhTRIcmArHcjhpNHSQPqnswlikqEhOTb1ei5HOS15Uv0iBEmzpm671k1Xa3GkdN22s13RvcyBdWXEQaEAB)kmfgHl4jsT4Uup1gSdvIhVlyZByKz4cEIuUJFYg9cG1g2JMepExWglwuaGWaGAs5o(jB0lawBypAsyo3Rbjp0V(kmfgE2yCfCYvSEBRHd2ynsW8doH95zRWAXsMkaqyaqnPohqX8OJgwZWzuAB)QflkqEhOTb1eii(u5UQXXYyJwzFTDvuGbjfKmuUqODvuGrlkui545mK(UeMRTRIcmiPGKHJv(W6aGX8eswli8WyzWtgEvQkKhc0TukEySm4jmlJNRTRIcmiPGKHJv(WA7TaXxBxffyqsbjdrjRjqAR6BJSCEIRTRIcmiPGKr3LPblDGl1t01(A)IJi3UeggJU2UkkWGs9Djmqqn1djRfe8E4falJtrnW1bWkLs3fUHtClUlBB2CTDvuGbL67syKcsgSQbuJmnMTXvUpMRTRIcmOuFxcJuqYaXyShSr3bdRr21twsfCLG1HJLXbcc0swlizAarcXyShSr3bdRr21tofL6znYSyXvr9G18W5fJGa9BSxgn)GNi5gdkvJ8RTqOXSQXXYyDu5SflQghlJrYd77vjRj0yo3Rb1AlV2V4iwTi(iV8cfaXr(nG4i16ivCeOat2L4ik3(ikqEhCeBqnb6i(yos0WhjlABdWXEQa(r6716if6iB70rYcpaL5iBunYocun8CKSRmBFeRQaB8rYURaDeu4QNOJ4y(inLSMJaWhbQgEoYgvJSJKDZUnyYDuWyjpYEemcDKOHps2HDdQbehPVxRJuOJSTtxBxffyqP(UegPGKHDHcGqJAaHK1ccmcxWtKAXDPEQnyhQepExWglw8SX4k40tMT1WbBSgQkqAVd2HgoyNW(8SvyF9DFVwjGTnah7Pc4PT9By03Rv6jZ2A4GnwdvfiT3b7qdhStOWvpBf6SAXcpmwg8wZAlF9A7QOadk13LWifKmSluaeAudiKSwq671kbSTb4ypvapTTFdJ(ETsg2nOgqK22wS03RvsgM5b9SgKgQs9KXO022IL(ETskWOyxWgDxShdJ7BekTTF9A7QOadk13LWifKmq1uOGXAuGRN81(A)IJyvaaHba1GU2UkkWGskdcIYfcTRIcmArHcjhpNHWiepkgjzTGKjkyxenSj5cX12vrbguszqsbjJLWLXcHhfyU2UkkWGskdskizSeUmwi8OaJwjyFqSK1cIH771kTeUmwi8OatcZ5EnOwH1Ifd33RvAjCzSq4rbMekC1t5HKvRV2UkkWGskdskiz4gmpUOgwJ3OgjRfKm771k5gmpUOgwJ3OM02(nmYubacdaQj9SeIAKPr2yMtBBlwYmCbpr6zje1itJSXmN4X7c286ByKj3I7Y2MnjpBOgh7i9cmHgS02aOySflkaqyaqnjHh8eAhR8Xtyo3RbjpSw)612vrbguszqsbjdmqi0rdR7GHrswli99ALWaHqhnSUdggLWCUxdQviWSflpCC5DbNWrxJzmqiU2V4iV01rCJbDehZhzBl5rqtzZhjA4Jag(iqvrZreaOyuCejKi7KoIvlIpcun8Ced8AKDKLJcgFKOXNJyvE5hXWRsvXra4JavfnGDCeFGFeRYlpDTDvuGbLugKuqYi3XpzJEbWAd7rJKk4kbRdhlJdeeOLSwqWEz08dEIKBmO02(nmchlJJuu5SoaAtXTQa5DG2gutGsgEvQkSyjtuWUiAytcdKT53kqEhOTb1eOKHxLQc5HOS15Uv0iBEmzp0VETFXrEPRJmGJ4gd6iqvcXrmfFeOQOPMJen8rg2kXrGzRrsEKnIpIvTv25iG5iDacDeOQObSJJ4d8JyvE5PRTRIcmOKYGKcsg5o(jB0lawBypAKSwqWEz08dEIKBmOunYdZwN9yVmA(bprYnguYSXEuG5DMOGDr0WMegiBZVvG8oqBdQjqjdVkvfYdrzRZDROr28yYEOV2V4iYjCdFeysXgJHFeWCeyL6i8W5fJsh5lXrGQIMJKfY7LHTsW4kGFKADKbCe3yqhPMJen8rg2kXrG2Au6A7QOadkPmiPGKrx4gwVeBmgUK1ccYMfcD4yzCGKhcSzVcmMDfjpVxg2kbJRaEIhVlyZ7m771k1fUH1lXgJHN22VXEz08dEIKBmOunYdT1xBxffyqjLbjfKmK1aqHaUgf46jlzTGOa5DG2gutGsgEvQkKhc0s13RvQJbUbvgoTTV2UkkWGskdskiz8SeIAKPr2yMLSwqE44Y7co1fUH1lXgJHRrWh1BKnle6WXY4aL6c3W6LyJXWLh638WyzWtrLZ6aOZDRipSxBxffyqjLbjfKm6c3WA8g1izTG8WXL3fCQlCdRxIngdxJGpQ38WyzWtrLZ6aOZDRipSx7xCeRwunYoIvtFkutgzH8(g1CKcDeWiGFe)ipym8Je1a)i1OWSJyjpccCKAocMDrfWL8iWb7Sly(iEhbe7GfWpYQg(ib4iBeFKkoIJoIFKDuIkGFeKnlePRTRIcmOKYGKcsgp8PqnswlizIc2frdBsUq8(HJlVl4KN33OgTcmMkkWCTDvuGbLugKuqYWGz30fUHrswlizIc2frdBsUq8wbY7aTnOMa1keOV2UkkWGskdskizGACdaQCwyKSwqYefSlIg2KCH49dhxExWjpVVrnAfymvuG5A7QOadkPmiPGKbITrfsYAbjtuWUiAytYfIRTRIcmOKYGKcsg2GOaJK1csFVwPUaamInksy2vHfl99ALCdMhxudRXButABFTDvuGbLugKuqYOlaaJETXWV2UkkWGskdskiz0zmIXpRr212vrbguszqsbjJvH5UaamxBxffyqjLbjfKm8rXOa7cTYfIRTRIcmOKYGKcsgBeRRGZLKxlwf6XZzik4kbiWGPu6UWrHK1csMOGDr0WMKleV771k5gmpUOgwJ3OMKba18UVxRuoNdWW1GLwSvLrBWSNJsgauZBEySm4POYzDa05UvKpRVXrx33RfQ1wETDvuGbLugKuqYyJyDfCUKJNZq8SHACSJ0lWeAWsBdGIXswliz23RvYnyECrnSgVrnPT97m771k1fUH1lXgJHN22VvaGWaGAsUbZJlQH14nQjH5CVguRq3YR9loIvtgd)iyWwwJa(rWBbFeW6irZoVxRInhj3Jg0r6SaaLvJJy1I4JSa4J8sNN2aZru4kK8iGOHXqvi(iqvrZrYcWehXJJaR1sDeu4QNOJaWhbARL6iqvrZrCbcCe5eaG5iB7012vrbguszqsbjJnI1vW5soEodXrnp8HrASNnawRayxizTGy4(ETsypBaSwbWUqB4(ETsgauJflgUVxRKcmMTkQhSUMNAd33RvAB)oCSmosnSlIMKTkAfMH9D4yzCKAyxenjBvipey2AlwY0W99ALuGXSvr9G118uB4(ETsB73WWW99ALWE2ayTcGDH2W99ALqHREkpeyTo7H2AyQH771k1faGrdw6OH18W5WtBBlwwLSMqJ5CVguRzP1V(UVxRKBW84IAynEJAsyo3Rbjp0TW1(fhj7WlFlIJSCHO7QNhzbWhzJ8UGpsfCokDTDvuGbLugKuqYyJyDfCosYAbPVxRuxaagXgfjm7QWILvjRj0yo3Rb1keyT2IffiVd02GAcuYWRsvrRqG9AFTFXrEziepkgDTDvuGbLyeIhfJGOaJINa7bB0lHNZswli8WyzWtrLZ6aOZDRip0VZSVxRux4gwVeBmgEAB)ggzAarsbgfpb2d2OxcpN19nEsrPEwJS3z6QOatsbgfpb2d2OxcpNt1OxIswtyXYAleAmRACSmwhvo3QmLjL7w51RTRIcmOeJq8OyKuqYOlaaJgS0rdR5HZHlzTG8WXL3fCQlCdRxIngdxJGpQ3kaqyaqnPohqX8OJgwZWzuAB)ggiBwi0HJLXbk1fUH1lXgJHlpeyTyb7LrZp4jsUXGs1iFwB5RxBxffyqjgH4rXiPGKHSTJnLpAWs7zJXGO5A7QOadkXiepkgjfKmwa1gXgTNngxbR7SNlzTGGSzHqhowghOux4gwVeBmgU8qG1IfSxgn)GNi5gdkvJ8zP1VZSVxRKBW84IAynEJAsB7RTRIcmOeJq8OyKuqYWEJRf8AKP7chfswliiBwi0HJLXbk1fUH1lXgJHlpeyTyb7LrZp4jsUXGs1iFwA912vrbguIriEumskizenSEpDWEm6faRyjRfK(ETsyw9uWiKEbWkoTTTyPVxReMvpfmcPxaSI1kWEcgNqHRE2k0wFTDvuGbLyeIhfJKcsg4Y2wW6A0iBxXxBxffyqjgH4rXiPGKbuaSW8GRrJzey8rXxBxffyqjgH4rXiPGKroNdWW1GLwSvLrBWSNJKSwq4HXYG3AwB51(fhXQsGWCeyc2TRr2rGjfEoJoYcGpcBfwTd(iyFKXhbGpYZsiosFVwijpsToInaHQUGthjliGYHJosGHFKaCezCCKOHpIaafJIJOaaHba1CKUJyZraZr8hEj8UGpcpCEXO012vrbguIriEumskizGz3Ugz6LWZzKKk4kbRdhlJdeeOLSwqchlJJuu5SoaAtXTcDQLwSadyeowghPg2frtYwfY3cwBXs4yzCKAyxenjBv0keyT(13WWvr9G18W5fJGaTflpCC5DbNWSBxJmTHfoC5H1Q)6RwSaJWXY4ifvoRdG2wfAyTwEy263WWvr9G18W5fJGaTflpCC5DbNWSBxJmTHfoC5ZAwF91R91(fhbMSMc1Wy01(fhrU4LDeWCefaimaOMJeGJ8Kz7Jen8rSk4koIH7716iB7RTRIcmO0QMc1aPZbump6OH1mCgDTDvuGbLw1uOgPGKbsukw7JrBkflzTG03RvcjkfR9XOnLItyo3Rb16QK1eAmN71GE33RvcjkfR9XOnLItyo3Rb1kmGwkfiVd02GAc0RWuOtTW12vrbguAvtHAKcsgMcz7HQ5AFTFXr(b7IO5A7QOadkHc2frdevd72AudiKubxjyD4yzCGGaTK1cs4cEIKnMHRbJoAynuS)mXJ3fS5DMHJLXrQq6oaHU2UkkWGsOGDr0ifKm88(g1q)pymQadvAyTgwRH2AOZk9dLJNAKHO)xAUnahS5iVKJ4QOaZrefkqPRn9lkuGOsq)mcXJIrujOsdnvc6NhVlydvo6xHRGXLt)8WyzWtrLZ6aOZDRCe5pc0h59rY8i99AL6c3W6LyJXWtB7J8(iW4izEediskWO4jWEWg9s45SUVXtkk1ZAKDK3hjZJ4QOatsbgfpb2d2OxcpNt1OxIswtCelwoYAleAmRACSmwhvoFKwpImLjL7w5iVs)UkkWq)kWO4jWEWg9s45mnOsdlvc6NhVlydvo6xHRGXLt)pCC5DbN6c3W6LyJXW1i4J6iVpIcaegautQZbump6OH1mCgL22h59rGXrq2SqOdhlJduQlCdRxIngd)iYd5iWEelwoc2lJMFWtKCJbLQ5iYFKS2YJ8k97QOad93faGrdw6OH18W5WPbvAyMkb97QOad9lB7yt5JgS0E2ymiAOFE8UGnu5Obv6SsLG(5X7c2qLJ(v4kyC50pYMfcD4yzCGsDHBy9sSXy4hrEihb2JyXYrWEz08dEIKBmOunhr(JKLwFK3hjZJ03RvYnyECrnSgVrnPTn97QOad9VaQnInApBmUcw3zpNguPBjvc6NhVlydvo6xHRGXLt)iBwi0HJLXbk1fUH1lXgJHFe5HCeypIflhb7LrZp4jsUXGs1Ce5pswAn97QOad9BVX1cEnY0DHJcAqLolPsq)84DbBOYr)kCfmUC6VVxReMvpfmcPxaSItB7JyXYr671kHz1tbJq6faRyTcSNGXju4QNhP1JaT10VRIcm0F0W690b7XOxaSIPbv6xcvc63vrbg6hx22cwxJgz7kM(5X7c2qLJguPBbQe0VRIcm0puaSW8GRrJzey8rX0ppExWgQC0GkTvNkb9ZJ3fSHkh9RWvW4YPFEySm4hP1JK1ws)UkkWq)5CoadxdwAXwvgTbZEoIguPH2AQe0ppExWgQC0VRIcm0pMD7AKPxcpNr0VcxbJlN(dhlJJuu5SoaAtXhP1JaDQLhXILJaJJaJJeowghPg2frtYwfhr(J0cwFelwos4yzCKAyxenjBvCKwHCeyT(iVEK3hbghXvr9G18W5fJocKJa9rSy5ipCC5DbNWSBxJmTHfo8Ji)rG1QFKxpYRhXILJaJJeowghPOYzDa02QqdR1hr(JaZwFK3hbghXvr9G18W5fJocKJa9rSy5ipCC5DbNWSBxJmTHfo8Ji)rYAwpYRh5v6xbxjyD4yzCGOsdnnOb9B4LVfbvcQ0qtLG(DvuGH(FwQN0ppExWgQC0GknSujOFxffyOFuWUiAOFE8UGnu5ObvAyMkb9ZJ3fSHkh9dSPFeh0VRIcm0)dhxExW0)dxSz63A6)HJ1JNZ0po6AmJbcbnOsNvQe0ppExWgQC0pWM(rCq)UkkWq)pCC5Dbt)pCXMPFfiVd02GAcuYWRsvXrKhYrG9isDeypcm9iW4iHl4jsYAaOqaxJcC9Kt84DbBoY7JOaaHba1KK1aqHaUgf46jNWCUxd6iTEeOpYRhrQJ03RvQJbUbvgoTTpY7JWdJLb)iYFKS06J8(izEK(ETsONBHq7JrRWaeQdggL22h59rY8i99ALEYSTgoyJ1qvbs7DWo0Wb702M(F4y945m9759nQrRaJPIcm0GkDlPsq)84DbBOYr)aB6hXb97QOad9)WXL3fm9)WfBM(r2SqOdhlJduQlCdRxIngd)iTEeypY7JG9YO5h8ej3yqPAoI8hbwRpIflhPVxRux4gwVeBmgEABt)pCSE8CM(7c3W6LyJXW1i4JIguPZsQe0ppExWgQC0VcxbJlN(rb7IOHnjxiOFxffyOFLleAxffy0Icf0VOqHE8CM(rb7IOHguPFjujOFE8UGnu5OFxffyOFLleAxffy0Icf0VOqHE8CM(vgenOs3cujOFE8UGnu5OFfUcgxo9Ra5DG2gutGoI8qoIYwN7wrJS5XCKS)iW4i99AL6yGBqLHtB7Ji1r671kbSTb4ypvapTTpYRhbMEeyCKWf8ePwCxQNAd2HkXJ3fS5iVpcmosMhjCbprk3XpzJEbWAd7rtIhVlyZrSy5ikaqyaqnPCh)Kn6faRnShnjmN71GoI8hb6J86rE9iW0JaJJ4zJXvWjxX6TTgoyJ1ibZp4e2NNhP1Ja7rSy5izEefaimaOMuNdOyE0rdRz4mkTTpYRhXILJOa5DG2gutGocKJ4tL7QghlJnALn97QOad9J3J2vrbgTOqb9lkuOhpNP)vnfQHguPT6ujOFE8UGnu5OFxffyOFLleAxffy0Icf0VOqHE8CM(77syObvAOTMkb9ZJ3fSHkh9RWvW4YPFEySm4jdVkvfhrEihb6wEePocpmwg8eMLXd97QOad97yLpSoaympbnOsdn0ujOFxffyOFhR8H12BbIPFE8UGnu5ObvAOHLkb97QOad9lkznbsBvFBKLZtq)84DbBOYrdQ0qdZujOFxffyO)Ultdw6axQNi6NhVlydvoAqd63gZkqE3dQeuPHMkb97QOad9722c4ABqHad9ZJ3fSHkhnOsdlvc6NhVlydvo63vrbg6p3XpzJEbWAd7rd9RWvW4YPFSxgn)GNi5gdkvZrK)iz1A63gZkqE3dnIvGXGO)wsdQ0Wmvc6NhVlydvo6xHRGXLt)W4izEeUf3LTnBs2a1toqv2yJwbYT3Hhfy0g(rP4JyXYrY8ikaqyaqnjfCLaeyWukDx4Oiz2ypkWCelwoc2lJMFWtKQ5Xwmm27coXwPqb6iVs)UkkWq)OGDr0qdQ0zLkb9ZJ3fSHkh97QOad9JbcHoAyDhmmI(v4kyC50pMxyg14Dbt)2ywbY7EOrScmge9dlnOs3sQe0ppExWgQC0VRIcm0psukw7JrBkft)kCfmUC6hZlmJA8UGPFBmRa5Dp0iwbgdI(HLguPZsQe0ppExWgQC0VRIcm0VBW84IAynEJAOFfUcgxo9dJJK5r4wCx22Sjzdup5avzJnAfi3EhEuGrB4hLIpIflhjZJOaaHba1KuWvcqGbtP0DHJIKzJ9OaZrSy5iyVmA(bprQMhBXWyVl4eBLcfOJ8k9BJzfiV7HgXkWyq0p00Gk9lHkb9ZJ3fSHkh9pEot)E2qno2r6fycnyPTbqXy63vrbg63ZgQXXosVatOblTnakgtdQ0Tavc6NhVlydvo63vrbg6xbxjabgmLs3fokOFfUcgxo9N5rWEz08dEIunp2IHXExWj2kfkq0pVwSk0JNZ0VcUsacmykLUlCuqdAq)9DjmujOsdnvc6NhVlydvo6xHRGXLt)49WlawgNIAGRdGvkLUlCdN4wCx22SH(DvuGH(rn1dAqLgwQe0VRIcm0pRAa1itJzBCL7JH(5X7c2qLJguPHzQe0ppExWgQC0VRIcm0pIXypyJUdgwJSRNm9RWvW4YP)mpIbejeJXEWgDhmSgzxp5uuQN1i7iwSCexf1dwZdNxm6iqoc0h59rWEz08dEIKBmOunhr(JS2cHgZQghlJ1rLZhXILJOACSmgDe5pcSh59rwLSMqJ5CVg0rA9iTK(vWvcwhowghiQ0qtdQ0zLkb9ZJ3fSHkh9RWvW4YPFyCKWf8ePwCxQNAd2HkXJ3fS5iwSCepBmUco9KzBnCWgRHQcK27GDOHd2jSpppsRhb2J86rEFK(ETsaBBao2tfWtB7J8(iW4i99ALEYSTgoyJ1qvbs7DWo0Wb7ekC1ZJ06rGoRhXILJWdJLb)iTEKS2YJ8k97QOad9BxOai0OgqqdQ0TKkb9ZJ3fSHkh9RWvW4YP)(ETsaBBao2tfWtB7J8(iW4i99ALmSBqnGiTTpIflhPVxRKmmZd6zninuL6jJrPT9rSy5i99ALuGrXUGn6Uypgg33iuABFKxPFxffyOF7cfaHg1acAqLolPsq)UkkWq)OAkuWynkW1tM(5X7c2qLJg0G(rb7IOHkbvAOPsq)84DbBOYr)UkkWq)Qg2T1Ogqq)kCfmUC6pCbprYgZW1GrhnSgk2FM4X7c2CK3hjZJeowghPcP7aeI(vWvcwhowghiQ0qtdQ0WsLG(DvuGH(98(g1q)84DbBOYrdAq)kdIkbvAOPsq)84DbBOYr)kCfmUC6pZJGc2frdBsUqq)UkkWq)kxi0UkkWOffkOFrHc945m9ZiepkgrdQ0WsLG(DvuGH(xcxgleEuGH(5X7c2qLJguPHzQe0ppExWgQC0VcxbJlN(nCFVwPLWLXcHhfysyo3RbDKwpcShXILJy4(ETslHlJfcpkWKqHREEe5HCKSAn97QOad9VeUmwi8OaJwjyFqmnOsNvQe0ppExWgQC0VcxbJlN(Z8i99ALCdMhxudRXButABFK3hbghjZJOaaHba1KEwcrnY0iBmZPT9rSy5izEKWf8ePNLquJmnYgZCIhVlyZrE9iVpcmosMhHBXDzBZMKNnuJJDKEbMqdwABaum(iwSCefaimaOMKWdEcTJv(4jmN71GoI8hbwRpYR0VRIcm0VBW84IAynEJAObv6wsLG(5X7c2qLJ(v4kyC50FFVwjmqi0rdR7GHrjmN71GosRqocmFelwoYdhxExWjC01ygdec63vrbg6hdecD0W6oyyenOsNLujOFE8UGnu5OFxffyO)Ch)Kn6faRnShn0VcxbJlN(XEz08dEIKBmO02(iVpcmos4yzCKIkN1bqBk(iTEefiVd02GAcuYWRsvXrSy5izEeuWUiAytcdKT5J8(ikqEhOTb1eOKHxLQIJipKJOS15Uv0iBEmhj7pc0h5v6xbxjyD4yzCGOsdnnOs)sOsq)84DbBOYr)kCfmUC6h7LrZp4jsUXGs1Ce5pcmB9rY(JG9YO5h8ej3yqjZg7rbMJ8(izEeuWUiAytcdKT5J8(ikqEhOTb1eOKHxLQIJipKJOS15Uv0iBEmhj7pc00VRIcm0FUJFYg9cG1g2JgAqLUfOsq)84DbBOYr)kCfmUC6hzZcHoCSmoqhrEihb2JK9hrbgZUIKN3ldBLGXvapXJ3fS5iVpsMhPVxRux4gwVeBmgEABFK3hb7LrZp4jsUXGs1Ce5pc0wt)UkkWq)DHBy9sSXy40GkTvNkb9ZJ3fSHkh9RWvW4YPFfiVd02GAcuYWRsvXrKhYrG(isDK(ETsDmWnOYWPTn97QOad9lRbGcbCnkW1tMguPH2AQe0ppExWgQC0VcxbJlN(F44Y7co1fUH1lXgJHRrWh1rEFeKnle6WXY4aL6c3W6LyJXWpI8hb6J8(i8WyzWtrLZ6aOZDRCe5pcS0VRIcm0)ZsiQrMgzJzMguPHgAQe0ppExWgQC0VcxbJlN(F44Y7co1fUH1lXgJHRrWh1rEFeEySm4POYzDa05UvoI8hbw63vrbg6VlCdRXBudnOsdnSujOFE8UGnu5OFfUcgxo9N5rqb7IOHnjxioY7J8WXL3fCYZ7BuJwbgtffyOFxffyO)h(uOgAqLgAyMkb9ZJ3fSHkh9RWvW4YP)mpckyxenSj5cXrEFefiVd02GAc0rAfYrGM(DvuGH(ny2nDHByenOsdDwPsq)84DbBOYr)kCfmUC6pZJGc2frdBsUqCK3h5HJlVl4KN33OgTcmMkkWq)UkkWq)Og3aGkNfgAqLg6wsLG(5X7c2qLJ(v4kyC50FMhbfSlIg2KCHG(DvuGH(rSnQq0Gkn0zjvc6NhVlydvo6xHRGXLt)99AL6caWi2OiHzxfhXILJ03RvYnyECrnSgVrnPTn97QOad9BdIcm0Gkn0VeQe0VRIcm0Fxaag9AJHt)84DbBOYrdQ0q3cujOFxffyO)oJrm(znYOFE8UGnu5ObvAOT6ujOFxffyO)vH5Uaam0ppExWgQC0GknSwtLG(DvuGH(9rXOa7cTYfc6NhVlydvoAqLgwOPsq)84DbBOYr)UkkWq)k4kbiWGPu6UWrb9RWvW4YP)mpckyxenSj5cXrEFK(ETsUbZJlQH14nQjzaqnh59r671kLZ5amCnyPfBvz0gm75OKba1CK3hHhgldEkQCwhaDUBLJi)rY6rEFeC0199AHosRhPL0pVwSk0JNZ0VcUsacmykLUlCuqdQ0Wclvc6NhVlydvo63vrbg63ZgQXXosVatOblTnakgt)kCfmUC6pZJ03RvYnyECrnSgVrnPT9rEFKmpsFVwPUWnSEj2ym802(iVpIcaegautYnyECrnSgVrnjmN71GosRhb6ws)JNZ0VNnuJJDKEbMqdwABaumMguPHfMPsq)84DbBOYr)UkkWq)oQ5HpmsJ9SbWAfa7c6xHRGXLt)gUVxRe2ZgaRvaSl0gUVxRKba1CelwoIH771kPaJzRI6bRR5P2W99AL22h59rchlJJud7IOjzRIJ06rGzypY7JeowghPg2frtYwfhrEihbMT(iwSCKmpIH771kPaJzRI6bRR5P2W99AL22h59rGXrmCFVwjSNnawRayxOnCFVwju4QNhrEihbwRps2FeOT(iW0Jy4(ETsDbay0GLoAynpCo802(iwSCKvjRj0yo3RbDKwpswA9rE9iVpsFVwj3G5Xf1WA8g1KWCUxd6iYFeOBb6F8CM(DuZdFyKg7zdG1ka2f0GknSzLkb9ZJ3fSHkh9RWvW4YP)(ETsDbayeBuKWSRIJyXYrwLSMqJ5CVg0rAfYrG16JyXYruG8oqBdQjqjdVkvfhPvihbw63vrbg6FJyDfCoIg0G(x1uOgQeuPHMkb97QOad935akMhD0WAgoJOFE8UGnu5ObvAyPsq)84DbBOYr)kCfmUC6VVxResukw7JrBkfNWCUxd6iTEKvjRj0yo3RbDK3hPVxResukw7JrBkfNWCUxd6iTEeyCeOpIuhrbY7aTnOMaDKxpcm9iqNAb63vrbg6hjkfR9XOnLIPbvAyMkb97QOad9BkKThQg6NhVlydvoAqdAq)(oAay6)x5wfAqdkf]] )

end