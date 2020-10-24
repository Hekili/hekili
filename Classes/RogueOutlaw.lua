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


    spec:RegisterPack( "Outlaw", 20201024, [[d0KN(aqirrpskv2KQsFsucQrbk5uQQQvbkvEfOQzrKClrPyxI8lkPgMOWXaPwgO4zsPQPjkPRjkvBJss9nrPuJtkLCorPK1rjjvZtvvUhi2hrvhuuIAHevEiLKyIIsKlckLSrqPuJeuQkojOuyLsjZeuQkDtqPQANeP(POeAOGsrhLssILckv5PQYubvUQOeyRuss5RIsq2lI)sXGr6WuTyP6XKmzsDzuBwjFMOmAP40swnLKKEniz2eUTOA3k(nWWPuhxkLA5q9Citx46k12vv8DvvgpLeNNiwVukMpLy)QmbAcCKN2dMinmzatgqNbmznbnmz0wqdd5fsSzYZ2vq5YyYB8CM8YI7q4)ipBxIa4AcCKhcSXkM8AIWgzv3ARLvrZUNuGCRrv(w4rbgf2xH1Okxzn513LiGngsN80EWePHjdyYa6mGjRjOHjdOHggYdzZkI0Wy1zqEnLwZdPtEAgPiV2D0S4oe(VJc7bKT5Rv7oAwufGoJpkmzvQJctgWKb5zJbRsWKx7oAwChc)3rH9aY281QDhnlQcqNXhfMSk1rHjdyY4ADTA3rHTScR2bRpANxamFufiV7Xr7SSAqPJMLvk2oqhDat204481wCuxffyqhfmcjPRLRIcmOKnMvG8UhqCBBHeJnOqG5A5QOadkzJzfiV7b8qSo3XqXAZcGnA2JgPSXScK39WGyfy0iizxQAbb7L2WF4jsUwJs1iFwZ4A5QOadkzJzfiV7b8qSgfSlIgPQfeyLj327Y2M1jBGckoqvByTrbYT3HhfymA(tPylwYubacn43KusucqGbtPmDHJIKEJ9OaJflyV0g(dprQMpBXWyVl4eBLcfO)VwUkkWGs2ywbY7EapeRXaHWenSPdggjLnMvG8UhgeRaJgbbgPQfemVWmQX7c(A5QOadkzJzfiV7b8qSgjkfB8rB0LILYgZkqE3ddIvGrJGaJu1ccMxyg14DbFTCvuGbLSXScK39aEiw7AmpUOg2G3OgPSXScK39WGyfy0iiqlvTGaRm52Ex22SozduqXbQAdRnkqU9o8OaJrZFkfBXsMkaqOb)MKsIsacmykLPlCuK0BShfySyb7L2WF4js18zlgg7DbNyRuOa9)1YvrbguYgZkqE3d4Hy9gXMk4CPgpNH4Tb14yhzwGjmGLXg8JXxlxffyqjBmRa5DpGhI1BeBQGZLIxlwfMXZzikjkbiWGPuMUWrHu1csMyV0g(dprQMpBXWyVl4eBLcfOR11QDhf2YkSAhS(O8hgl5OrLZhnA4J6QaGpAHoQ)XlH3fC6A5QOadccuLcQRv7okShJc2frZrR1rTbiu1f8rH1ao6NTyyS3f8r5HZlgD0AoQcK394)RLRIcmi4HynkyxenxR2DuRYgJ5jeso6aIJ(dGJMJIzmqiQr2rR5OpyFpAnh1hjhfQb8BokQIThfyUwUkkWGGhI1FCC5Dbl145meC0nygdecP(4IndjJRLRIcmi4Hy9hhxExWsnEodXZ7BuJrbgDffyK6Jl2mefiVdm2GAcusZRsvH8qGbEyGDWkCbprswdafcjguGlO4epExW6VkaqOb)MKSgakesmOaxqXjmN71G(d6)HVVxRuhdCnQ0CAB)LhgltI8wDgFZSVxRecQTqy8rBuyac1bdJsB7Vz23RvckMTnsaBS5xfiJ3b7WibStB7Rv7oAwOkAoA(weLTGpA4yzCGK6OrtHo6hhxExWhTqhv1WkOy9rdWr1SQ08r)1WrdJpkcKZh1QKLqhf1a2c9r78rrsgfRp6VkAoQCcxZhf2wSXyjxlxffyqWdX6poU8UGLA8Cgsx4A2SeBmwIbjzus9XfBgcYMfct4yzCGsDHRzZsSXyj)bZxSxAd)HNi5AnkvJ8WKHfl99AL6cxZMLyJXssB7RLRIcmi4HyTYfcJRIcmgrHcPgpNHGc2frJu1cckyxenSo5cX1Yvrbge8qSw5cHXvrbgJOqHuJNZquA01QDhf2UMc1CupoAUBLkFNFuRcSz6OVDhfyxfhfm8rxa8rzx1Cu5WaxJknFuF0hnlABdWXEQqYr)1WZrTQSlfuhnlH9FhTqhfXcwfS(O(OpkS)vw6Of6OdiokMDTKJ6RGXhnA4JoSvIJIyfy0PJMLf)CjOJM7w5OYfWwh9xfnhfg4pAwwXPRLRIcmi4HynEpgxffymIcfsnEodzvtHAKQwquG8oWydQjqYdrzBYDRyq28OZgy13RvQJbUgvAoTTHVVxReW2gGJ9uHK02(FyhScxWtKA7DPGYOX(VepExW6VWkZWf8ePChdfRnla2OzpAs84DbRTyrbacn43KYDmuS2SayJM9OjH5CVgK8q)))Woy5THXvWjxXMTTrcyJnibZF4e2hO(dglwYubacn43K6C8J5XenSHLWO02(FlwuG8oWydQjqq8PYDvJJLXAJY(A5QOadcEiwRCHW4QOaJruOqQXZzi9Dj0xlxffyqWdXAhR8HnbaJ5jKQwq4HXYKK08QuvipeOZo88WyzssywgpxlxffyqWdXAhR8Hn2BbIVwUkkWGGhI1IswtGmwv3Az58exlxffyqWdX6UlZawMaxkOqxRRv7oQC7sOzm6A5QOadk13Lqdb1uFKQwqW7HxaSmof1iXeaRuktx4AoXT9USTz91YvrbguQVlHgEiwZQgqnYmy2gx5(OVwUkkWGs9Dj0WdXAeJXEWAthmSbzxqXsPKOeSjCSmoqqGwQAbjtnisigJ9G1MoyydYUGItrPGQgzwS4QO(WgE48IrqG(l2lTH)WtKCTgLQr(1wimyw14yzSjQC2IfvJJLXi5H57QK1egmN71G(l7xR2D0SaeFuyZcfaXrFnG4O)QO5OzrBBao2tfsoAToANfGFhnRz)O8WyzsK6Oa8r)1WZr3OAKDuRk7sb1rZsy)3r9rF0SqvGoAHoQg8BsxlxffyqP(UeA4HyTDHcGWGAaHu1csFVwjGTnah7PcjPT9xyXdJLj5VSMDlwcxWtKA7DPGYOX(VepExW6V99ALGIzBJeWgB(vbY4DWomsa7Kg8B()A5QOadk13LqdpeRTluaegudiKQwq671kbSTb4ypvijTT)cR(ETsA21OgqK22wS03RvsgM5bbvniZVsbfJrPTTfl99ALuGrXUG1MUypAg33iuAB))1YvrbguQVlHgEiwJQPqbJnOaxqXxRRv7oQvbaeAWVbDTCvuGbLuAeeLlegxffymIcfsnEodHriEumsQAbjtuWUiAyDYfIRLRIcmOKsJGhI1lHlJfcpkWCTCvuGbLuAe8qSEjCzSq4rbgJsW(GyPQfen33RvAjCzSq4rbMeMZ9Aq)bJflAUVxR0s4YyHWJcmju4kOKhs7Z4A5QOadkP0i4HyTRX84IAydEJAKQwqYSVxRKRX84IAydEJAsB7VWktfai0GFtcQsiQrMbzJzoTTTyjZWf8ejOkHOgzgKnM5epExW6))cRm52Ex22So5Tb14yhzwGjmGLXg8JXwSOaaHg8Bscp4jmow5JNWCUxdsEyY4)RLRIcmOKsJGhI1yGqyIg20bdJKQwq671kHbcHjAythmmkH5CVg0FqAVflFCC5DbNWr3GzmqiUwT7OWgRJ6An6OoMp62wQJIMYMpA0Whfm8r)vrZrfGFmkokCWLLshnlaXh9xdphvlPgzhD5OGXhnA85OwfyZJQ5vPQ4Oa8r)vrdyhh1hjh1QaBMUwUkkWGskncEiwN7yOyTzbWgn7rJukjkbBchlJdeeOLQwqWEPn8hEIKR1O02(lSchlJJuu5SjagDX)Pa5DGXgutGsAEvQkSyjtuWUiAyDcdKT5VkqEhySb1eOKMxLQc5HOSn5UvmiBE0zd0)FTA3rHnwhDah11A0r)vcXr1fF0Fv0uZrJg(OdBL4OTpdKuhDJ4Jc7FLLokyoAhGqh9xfnGDCuFKCuRcSz6A5QOadkP0i4HyDUJHI1MfaB0ShnsvliyV0g(dprY1AuQg5BFgzd2lTH)WtKCTgL0BShfy(MjkyxenSoHbY28xfiVdm2GAcusZRsvH8qu2MC3kgKnp6Sb6Rv7oQCcxZhf2wSXyjhfmhfg4pkpCEXO0rFWD0Fv0C0SCEV0SvcgxHKJwRJoGJ6An6O1C0OHp6Wwjok0zGsxlxffyqjLgbpeR7cxZMLyJXsKQwqq2SqychlJdK8qGjBuGrVRi559sZwjyCfss84DbR)MzFVwPUW1Szj2ySK02(l2lTH)WtKCTgLQrEOZ4A5QOadkP0i4HyTSgakesmOaxqXsvlikqEhySb1eOKMxLQc5Han899AL6yGRrLMtB7RLRIcmOKsJGhI1qvcrnYmiBmZsvliFCC5DbN6cxZMLyJXsmijJ6lYMfct4yzCGsDHRzZsSXyjYd9xEySmjPOYztam5UvKhMRLRIcmOKsJGhI1DHRzdEJAKQwq(44Y7co1fUMnlXgJLyqsg1xEySmjPOYztam5UvKhMRv7oAwaQgzh1QMpfQX6SCEFJAoAHokyesoQF0pmwYrJAKC0Auy2rSuhfboAnhfZUOcjsDujGDwymFuVJaIDWcjhDvdF0aC0nIpAfh1rh1p6okrfsokYMfI01YvrbgusPrWdX6p(uOgPQfKmrb7IOH1jxi((XXL3fCYZ7BuJrbgDffyUwUkkWGskncEiwRXSR7cxZiPQfKmrb7IOH1jxi(Qa5DGXgutG(dc0xlxffyqjLgbpeRrnUg8lNfAPQfKmrb7IOH1jxi((XXL3fCYZ7BuJrbgDffyUwUkkWGskncEiwJyBuHKQwqYefSlIgwNCH4A5QOadkP0i4HyTnikWivTG03RvQlaaTyJIeMDvyXsFVwjxJ5Xf1Wg8g1K22xlxffyqjLgbpeR7caqBwBSKRLRIcmOKsJGhI1DgJymu1i7A5QOadkP0i4Hy9QWCxaa6RLRIcmOKsJGhI1(OyuGDHr5cX1YvrbgusPrWdX6nInvW5sXRfRcZ45meLeLaeyWuktx4OqQAbjtuWUiAyDYfIV99ALCnMhxudBWButsd(nF771kLZ5aSedyzeBvPnAm75OKg8B(YdJLjjfvoBcGj3TI8z9lo6M(ETq)L9RLRIcmOKsJGhI1BeBQGZLA8CgI3guJJDKzbMWawgBWpglvTGKzFVwjxJ5Xf1Wg8g1K22FZSVxRux4A2SeBmwsAB)vbacn43KCnMhxudBWButcZ5EnO)Go7xR2DuRAmwYrXGTSgHKJI3c(OG1rJMDEVwfRpAUhnOJ2zb4Nv9JMfG4JUa4JcBmqzd0hvHRqQJcIgg)Rq8r)vrZrZYWEh1JJctgWFuu4kOqhfGpk0za)r)vrZrDbcCu5eaG(OB701YvrbgusPrWdX6nInvW5snEodXrnF8HrgS3ga2OayxivTGO5(ETsyVnaSrbWUWO5(ETsAWVXIfn33Rvsbg9wf1h2udugn33RvAB)nCSmosnSlIMKTk(R9W8nCSmosnSlIMKTkKhs7ZWILm1CFVwjfy0BvuFytnqz0CFVwPT9xyP5(ETsyVnaSrbWUWO5(ETsOWvqjpeyYiBGodyNM771k1faG2awMOHn8W5ssBBlwwLSMWG5CVg0FwDg))TVxRKRX84IAydEJAsyo3Rbjp0T11QDhnlXlFlIJUCHO7kOo6cGp6g5DbF0k4Cu6A5QOadkP0i4Hy9gXMk4CKu1csFVwPUaa0Inksy2vHflRswtyWCUxd6piWKHflkqEhySb1eOKMxLQI)GaZ16A1UJcBHq8Oy01YvrbguIriEumcIcmkEcShS2SeEolvTGWdJLjjfvoBcGj3TI8q)nZ(ETsDHRzZsSXyjPT9xyLPgejfyu8eypyTzj8C2034jfLcQAK9ntxffyskWO4jWEWAZs45CQgZsuYAclwwBHWGzvJJLXMOY5)KP0PC3k)FTCvuGbLyeIhfJGhI1DbaOnGLjAydpCUePQfKpoU8UGtDHRzZsSXyjgKKr9vbacn43K6C8J5XenSHLWO02(lSq2SqychlJduQlCnBwInglrEiWyXc2lTH)WtKCTgLQr(SM9)VwUkkWGsmcXJIrWdXAzBhRlFmGLXBdJbrZ1YvrbguIriEumcEiwVaQnI1gVnmUc20zpxQAbbzZcHjCSmoqPUW1Szj2ySe5HaJflyV0g(dprY1AuQg5T6m(MzFVwjxJ5Xf1Wg8g1K22xlxffyqjgH4rXi4HyT9gxlj1iZ0fokKQwqq2SqychlJduQlCnBwInglrEiWyXc2lTH)WtKCTgLQrERoJRLRIcmOeJq8Oye8qSoAyZE6G9OnlawXsvli99ALWSckbJqMfaR4022IL(ETsywbLGriZcGvSrb2tW4ekCfu)bDgxlxffyqjgH4rXi4HynUSTfSPgdY2v81YvrbguIriEumcEiw)dGf6pCngmJaJpk(A5QOadkXiepkgbpeRZ5CawIbSmITQ0gnM9CKu1ccpmwMK)YA2VwT7OW(ae6Jc7XUDnYokSTWZz0rxa8rzRWQDWhf7Jm(Oa8rHQeIJ23RfsQJwRJAdqOQl40rZYIFUe0rdSKJgGJkJJJgn8rfGFmkoQcaeAWV5ODhX6JcMJ6F8s4DbFuE48IrPRLRIcmOeJq8Oye8qSgZUDnYmlHNZiPusuc2eowghiiqlvTGeowghPOYztam6I)d6u2TybwWkCSmosnSlIMKTkKVTYWILWXY4i1WUiAs2Q4piWKX)FHLRI6dB4HZlgbbAlw(44Y7coHz3UgzgnlCjYdt26))TybwHJLXrkQC2eaJTkmWKH8TpJVWYvr9Hn8W5fJGaTflFCC5DbNWSBxJmJMfUe5ZAw)))R11QDhf2UMc1Wy01QDhvUa26OG5OkaqOb)MJgGJcfZ2hnA4JAvWvCun33R1r32xlxffyqPvnfQbsNJFmpMOHnSegDTCvuGbLw1uOg4Hynsuk24J2OlflvTG03RvcjkfB8rB0LItyo3Rb93QK1egmN71G(23RvcjkfB8rB0LItyo3Rb9hSGgEfiVdm2GAc0)WoOtT11YvrbguAvtHAGhI16cz7HQ5ADTA3rFb7IO5A5QOadkHc2frdevd72gudiKsjrjyt4yzCGGaTu1cs4cEIKnMLyaJjAyZp2HkXJ3fS(BMHJLXrQqMoaHUwUkkWGsOGDr0apeR98(g1qEFymQadrAyYaMmGodyYG8(54PgziYd2i3gGdwF0S9rDvuG5OIcfO01I8efkqe4ipgH4rXicCePHMah5XJ3fSMih5PWvW4YjpEySmjPOYztam5UvoQ8hf6J(9OzE0(ETsDHRzZsSXyjPT9r)EuyD0mpQgejfyu8eypyTzj8C2034jfLcQAKD0VhnZJ6QOatsbgfpb2dwBwcpNt1ywIswtCulwo6AlegmRACSm2evoF0)oQmLoL7w5O)tEUkkWqEkWO4jWEWAZs45mjisddboYJhVlynroYtHRGXLtEFCC5DbN6cxZMLyJXsmijJ6OFpQcaeAWVj154hZJjAydlHrPT9r)EuyDuKnleMWXY4aL6cxZMLyJXsoQ8qokmh1ILJI9sB4p8ejxRrPAoQ8hnRz)O)tEUkkWqEDbaOnGLjAydpCUesqKU9e4ipxffyipzBhRlFmGLXBdJbrd5XJ3fSMihjisNvcCKhpExWAICKNcxbJlN8q2SqychlJduQlCnBwIngl5OYd5OWCulwok2lTH)WtKCTgLQ5OYFuRoJJ(9OzE0(ETsUgZJlQHn4nQjTTjpxffyiVfqTrS24THXvWMo75KGiD2jWrE84DbRjYrEkCfmUCYdzZcHjCSmoqPUW1Szj2ySKJkpKJcZrTy5OyV0g(dprY1AuQMJk)rT6mipxffyip7nUwsQrMPlCuqcI0wnboYJhVlynroYtHRGXLtE99ALWSckbJqMfaR402(OwSC0(ETsywbLGriZcGvSrb2tW4ekCfuh9VJcDgKNRIcmKx0WM90b7rBwaSIjbr6SnboYZvrbgYdx22c2uJbz7kM84X7cwtKJeePBlcCKNRIcmK3pawO)W1yWmcm(OyYJhVlynrosqKoBrGJ84X7cwtKJ8u4kyC5KhpmwMKJ(3rZA2jpxffyiVCohGLyalJyRkTrJzphrcI0qNbboYJhVlynroYZvrbgYdZUDnYmlHNZiYtHRGXLtEHJLXrkQC2eaJU4J(3rHoL9JAXYrH1rH1rdhlJJud7IOjzRIJk)rBRmoQflhnCSmosnSlIMKTko6FqokmzC0)p63JcRJ6QO(WgE48IrhfYrH(OwSC0poU8UGty2TRrMrZcxYrL)OWKTo6)h9)JAXYrH1rdhlJJuu5SjagBvyGjJJk)rBFgh97rH1rDvuFydpCEXOJc5OqFulwo6hhxExWjm721iZOzHl5OYF0SM1J()r)N8usuc2eowghiI0qtcsqEAE5BrqGJin0e4ipxffyipOkfuKhpExWAICKGinme4ipxffyipuWUiAipE8UG1e5ibr62tGJ84X7cwtKJ8a2KhIdYZvrbgY7JJlVlyY7Jl2m5Lb59XXMXZzYdhDdMXaHGeePZkboYJhVlynroYdytEioipxffyiVpoU8UGjVpUyZKNcK3bgBqnbkP5vPQ4OYd5OWCu4pkmhf2DuyD0Wf8ejznauiKyqbUGIt84DbRp63JQaaHg8BsYAaOqiXGcCbfNWCUxd6O)DuOp6)hf(J23RvQJbUgvAoTTp63JYdJLj5OYFuRoJJ(9OzE0(ETsiO2cHXhTrHbiuhmmkTTp63JM5r771kbfZ2gjGn28RcKX7GDyKa2PTn59XXMXZzYZZ7BuJrbgDffyibr6StGJ84X7cwtKJ8a2KhIdYZvrbgY7JJlVlyY7Jl2m5HSzHWeowghOux4A2SeBmwYr)7OWC0Vhf7L2WF4jsUwJs1Cu5pkmzCulwoAFVwPUW1Szj2ySK02M8(4yZ45m51fUMnlXgJLyqsgfjisB1e4ipE8UG1e5ipfUcgxo5Hc2frdRtUqqEUkkWqEkximUkkWyefkiprHcZ45m5Hc2frdjisNTjWrE84DbRjYrEUkkWqEkximUkkWyefkiprHcZ45m5P0isqKUTiWrE84DbRjYrEkCfmUCYtbY7aJnOMaDu5HCuLTj3TIbzZJ(OzZrH1r771k1XaxJknN22hf(J23RvcyBdWXEQqsABF0)pkS7OW6OHl4jsT9Uuqz0y)xIhVly9r)EuyD0mpA4cEIuUJHI1MfaB0ShnjE8UG1h1ILJQaaHg8Bs5ogkwBwaSrZE0KWCUxd6OYFuOp6)h9)Jc7okSoQ3ggxbNCfB22gjGn2Gem)HtyFG6O)DuyoQflhnZJQaaHg8BsDo(X8yIg2WsyuABF0)pQflhvbY7aJnOMaDuih1Nk3vnowgRnkBYZvrbgYdVhJRIcmgrHcYtuOWmEotERAkudjisNTiWrE84DbRjYrEUkkWqEkximUkkWyefkiprHcZ45m513LqtcI0qNbboYJhVlynroYtHRGXLtE8WyzssAEvQkoQ8qok0z)OWFuEySmjjmlJhYZvrbgYZXkFytaWyEcsqKgAOjWrEUkkWqEow5dBS3cetE84DbRjYrcI0qddboYZvrbgYtuYAcKXQ6wllNNG84X7cwtKJeePHU9e4ipxffyiVUlZawMaxkOqKhpExWAICKGeKNnMvG8Uhe4isdnboYZvrbgYZTTfsm2GcbgYJhVlynrosqKggcCKhpExWAICKNRIcmKxUJHI1MfaB0ShnKNcxbJlN8WEPn8hEIKR1Ounhv(JM1mipBmRa5DpmiwbgnI8Yojis3EcCKhpExWAICKNcxbJlN8G1rZ8OCBVlBBwNSbkO4avTH1gfi3EhEuGXO5pLIpQflhnZJQaaHg8BskjkbiWGPuMUWrrsVXEuG5OwSCuSxAd)HNivZNTyyS3fCITsHc0r)N8CvuGH8qb7IOHeePZkboYJhVlynroYZvrbgYddect0WMoyye5PWvW4YjpmVWmQX7cM8SXScK39WGyfy0iYdgsqKo7e4ipE8UG1e5ipxffyipKOuSXhTrxkM8u4kyC5KhMxyg14DbtE2ywbY7EyqScmAe5bdjisB1e4ipE8UG1e5ipxffyipxJ5Xf1Wg8g1qEkCfmUCYdwhnZJYT9USTzDYgOGIdu1gwBuGC7D4rbgJM)uk(OwSC0mpQcaeAWVjPKOeGadMsz6chfj9g7rbMJAXYrXEPn8hEIunF2IHXExWj2kfkqh9FYZgZkqE3ddIvGrJipOjbr6SnboYJhVlynroYB8CM882GACSJmlWegWYyd(XyYZvrbgYZBdQXXoYSatyalJn4hJjbr62Iah5XJ3fSMih55QOad5PKOeGadMsz6chfKNcxbJlN8Y8OyV0g(dprQMpBXWyVl4eBLcfiYJxlwfMXZzYtjrjabgmLY0fokibjiV(UeAcCePHMah5XJ3fSMih5PWvW4Yjp8E4falJtrnsmbWkLY0fUMtCBVlBBwtEUkkWqEOM6djisddboYZvrbgYJvnGAKzWSnUY9rtE84DbRjYrcI0TNah5XJ3fSMih55QOad5Hym2dwB6GHni7ckM8u4kyC5KxMhvdIeIXypyTPdg2GSlO4uukOQr2rTy5OUkQpSHhoVy0rHCuOp63JI9sB4p8ejxRrPAoQ8hDTfcdMvnowgBIkNpQflhv14yzm6OYFuyo63JUkznHbZ5EnOJ(3rZo5PKOeSjCSmoqePHMeePZkboYJhVlynroYtHRGXLtE99ALa22aCSNkKK22h97rH1r5HXYKC0)oAwZ(rTy5OHl4jsT9Uuqz0y)xIhVly9r)E0(ETsqXSTrcyJn)Qaz8oyhgjGDsd(nh9FYZvrbgYZUqbqyqnGGeePZoboYJhVlynroYtHRGXLtE99ALa22aCSNkKK22h97rH1r771kPzxJAarABFulwoAFVwjzyMheu1Gm)kfumgL22h1ILJ23Rvsbgf7cwB6I9OzCFJqPT9r)N8CvuGH8SluaegudiibrARMah55QOad5HQPqbJnOaxqXKhpExWAICKGeKhkyxene4isdnboYJhVlynroYZvrbgYt1WUTb1acYtHRGXLtEHl4js2ywIbmMOHn)yhQepExW6J(9OzE0WXY4ivithGqKNsIsWMWXY4arKgAsqKggcCKNRIcmKNN33OgYJhVlynrosqcYtPre4isdnboYJhVlynroYtHRGXLtEzEuuWUiAyDYfcYZvrbgYt5cHXvrbgJOqb5jkuygpNjpgH4rXisqKggcCKNRIcmK3s4YyHWJcmKhpExWAICKGiD7jWrE84DbRjYrEkCfmUCYtZ99ALwcxgleEuGjH5CVg0r)7OWCulwoQM771kTeUmwi8OatcfUcQJkpKJ2(mipxffyiVLWLXcHhfymkb7dIjbr6SsGJ84X7cwtKJ8u4kyC5KxMhTVxRKRX84IAydEJAsB7J(9OW6OzEufai0GFtcQsiQrMbzJzoTTpQflhnZJgUGNibvje1iZGSXmN4X7cwF0)p63JcRJM5r52Ex22So5Tb14yhzwGjmGLXg8JXh1ILJQaaHg8Bscp4jmow5JNWCUxd6OYFuyY4O)tEUkkWqEUgZJlQHn4nQHeePZoboYJhVlynroYtHRGXLtE99ALWaHWenSPdggLWCUxd6O)b5OT)OwSC0poU8UGt4OBWmgieKNRIcmKhgieMOHnDWWisqK2QjWrE84DbRjYrEUkkWqE5ogkwBwaSrZE0qEkCfmUCYd7L2WF4jsUwJsB7J(9OW6OHJLXrkQC2eaJU4J(3rvG8oWydQjqjnVkvfh1ILJM5rrb7IOH1jmq2Mp63JQa5DGXgutGsAEvQkoQ8qoQY2K7wXGS5rF0S5OqF0)jpLeLGnHJLXbIin0KGiD2Mah5XJ3fSMih5PWvW4YjpSxAd)HNi5AnkvZrL)OTpJJMnhf7L2WF4jsUwJs6n2Jcmh97rZ8OOGDr0W6egiBZh97rvG8oWydQjqjnVkvfhvEihvzBYDRyq28OpA2CuOjpxffyiVChdfRnla2OzpAibr62Iah5XJ3fSMih5PWvW4YjpKnleMWXY4aDu5HCuyoA2Cufy07ksEEV0SvcgxHKepExW6J(9OzE0(ETsDHRzZsSXyjPT9r)EuSxAd)HNi5AnkvZrL)OqNb55QOad51fUMnlXgJLqcI0zlcCKhpExWAICKNcxbJlN8uG8oWydQjqjnVkvfhvEihf6Jc)r771k1XaxJknN22KNRIcmKNSgakesmOaxqXKGin0zqGJ84X7cwtKJ8u4kyC5K3hhxExWPUW1Szj2ySedsYOo63JISzHWeowghOux4A2SeBmwYrL)OqF0VhLhgltskQC2eatUBLJk)rHH8CvuGH8GQeIAKzq2yMjbrAOHMah5XJ3fSMih5PWvW4YjVpoU8UGtDHRzZsSXyjgKKrD0VhLhgltskQC2eatUBLJk)rHH8CvuGH86cxZg8g1qcI0qddboYJhVlynroYtHRGXLtEzEuuWUiAyDYfIJ(9OFCC5DbN88(g1yuGrxrbgYZvrbgY7JpfQHeePHU9e4ipE8UG1e5ipfUcgxo5L5rrb7IOH1jxio63JQa5DGXgutGo6Fqok0KNRIcmKNgZUUlCnJibrAOZkboYJhVlynroYtHRGXLtEzEuuWUiAyDYfIJ(9OFCC5DbN88(g1yuGrxrbgYZvrbgYd14AWVCwOjbrAOZoboYJhVlynroYtHRGXLtEzEuuWUiAyDYfcYZvrbgYdX2OcrcI0qB1e4ipE8UG1e5ipfUcgxo513RvQlaaTyJIeMDvCulwoAFVwjxJ5Xf1Wg8g1K22KNRIcmKNnikWqcI0qNTjWrEUkkWqEDbaOnRnwc5XJ3fSMihjisdDBrGJ8CvuGH86mgXyOQrg5XJ3fSMihjisdD2Iah55QOad5Tkm3faGM84X7cwtKJeePHjdcCKNRIcmKNpkgfyxyuUqqE84DbRjYrcI0WanboYJhVlynroYZvrbgYtjrjabgmLY0fokipfUcgxo5L5rrb7IOH1jxio63J23RvY1yECrnSbVrnjn43C0VhTVxRuoNdWsmGLrSvL2OXSNJsAWV5OFpkpmwMKuu5SjaMC3khv(JM1J(9O4OB671cD0)oA2jpETyvygpNjpLeLaeyWuktx4OGeePHbgcCKhpExWAICKNRIcmKN3guJJDKzbMWawgBWpgtEkCfmUCYlZJ23RvY1yECrnSbVrnPT9r)E0mpAFVwPUW1Szj2ySK02(OFpQcaeAWVj5AmpUOg2G3OMeMZ9Aqh9VJcD2jVXZzYZBdQXXoYSatyalJn4hJjbrAyApboYJhVlynroYZvrbgYZrnF8HrgS3ga2OayxqEkCfmUCYtZ99ALWEBayJcGDHrZ99AL0GFZrTy5OAUVxRKcm6TkQpSPgOmAUVxR02(OFpA4yzCKAyxenjBvC0)oA7H5OFpA4yzCKAyxenjBvCu5HC02NXrTy5OzEun33Rvsbg9wf1h2udugn33RvABF0VhfwhvZ99ALWEBayJcGDHrZ99ALqHRG6OYd5OWKXrZMJcDghf2Dun33RvQlaaTbSmrdB4HZLK22h1ILJUkznHbZ5EnOJ(3rT6mo6)h97r771k5AmpUOg2G3OMeMZ9Aqhv(JcDBrEJNZKNJA(4dJmyVnaSrbWUGeePHjRe4ipE8UG1e5ipfUcgxo513RvQlaaTyJIeMDvCulwo6QK1egmN71Go6FqokmzCulwoQcK3bgBqnbkP5vPQ4O)b5OWqEUkkWqEBeBQGZrKGeK3QMc1qGJin0e4ipxffyiVoh)yEmrdByjmI84X7cwtKJeePHHah5XJ3fSMih5PWvW4YjV(ETsirPyJpAJUuCcZ5EnOJ(3rxLSMWG5CVg0r)E0(ETsirPyJpAJUuCcZ5EnOJ(3rH1rH(OWFufiVdm2GAc0r))OWUJcDQTipxffyipKOuSXhTrxkMeePBpboYZvrbgYtxiBpunKhpExWAICKGeKG88D0aWK3RYTkKGeeca]] )

end