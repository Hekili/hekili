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

            spend = 45,
            spendType = "energy",

            startsCombat = false,
            texture = 1373910,

            handler = function ()
                spend( 5, "energy" ) -- this is a temporary band-aid to make RTB come up before spenders.
                -- If you constantly spend down below 50 energy, RtB will get buried.

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
            
            spend = 20,
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


    spec:RegisterPack( "Outlaw", 20201014, [[d8umbbqirKhjLKnPs1NeHcnkvIoLkHvjLGxrenlIIBjcv7su)IsQHjcoge1YGeptkPMMikxteY2OKuFtevmoPe6CqKO1brsmpiI7bH9rKCqruLfsu6Husstuev1fHivTrisyKqKKCsisLvQs6LIqbMPiuq3uekQDsK6NIOsdfIu6OIqPAPqKupvvnvIWvHifBvekYxfHsolejP2ls)LIbdCyQwSkEmjtMuxg1MLQptunAr60swTiukVgsA2eUTuSBL(nOHtPooLKy5q9Cetx46QY2Ls9DvkJNsIZdPwVuIMpLy)kMImvc6x7btLgLeqjbKta5KLtiHwNSeSA6pqBZ0VTRq1LZ0)6nm9NCFHWVr)2oAb01ujOFc8Hvm9NgHnbPI1wlVI03jRGnwtQMNWJcUkS3dRjvJYA6)8krG0T0d9R9GPsJscOKaYjGCYYjKqRBDIso0pXMvuPrXQtG(tlTMx6H(1mrr)TAaj3xi8BdaPgk)XZ1wnGKRkGhgpaKtMmdaLeqjb63gd7LGP)wnGK7le(TbGudL)45ARgqYvfWdJhaYjtMbGscOKWCDU2QbG0Bfw9cwpGd3HyEakyZXJbCy51sYdi5PuSDqgWc3ep1Xn9NyaUkk4sgaCfOZZvxffCjzBmRGnhpq422c0gByrG7C1vrbxs2gZkyZXdjryDJJrL1MoeB0ShPYyJzfS54HHWk4QjisKmvhb2lTHBZBKDTMKRvQKLWC1vrbxs2gZkyZXdjrynjyxePYuDexMeBvELTnRZ2qfQCqQwYAJc2y)cpk4A0C7sXwSKKccfA4TnRqReWad3szocNez9d7rbxlwWEPnCBEJCTTFILX(rWz2kfjixmxDvuWLKTXSc2C8qsewJHcHjszZbUmrgBmRGnhpmewbxnbbkYuDeyUJzsQFe8C1vrbxs2gZkyZXdjrynruk24R2OlflJnMvWMJhgcRGRMGafzQocm3Xmj1pcEU6QOGljBJzfS54HKiS21yEDrTSb)iPYyJzfS54HHWk4QjiqwMQJ4YKyRYRSTzD2gQqLds1swBuWg7x4rbxJMBxk2ILKuqOqdVTzfALagy4wkZr4KiRFypk4AXc2lTHBZBKRT9tSm2pcoZwPib5I5QRIcUKSnMvWMJhsIW6hHnvWnYSEdJWBjj1XoX0HByGDJn8gJNRUkk4sY2ywbBoEijcRFe2ub3id37SkmR3WiuOvcyGHBPmhHtczQoIKWEPnCBEJCTTFILX(rWz2kfjiZ15ARgasVvy1ly9a42mg9aIQHhqKYdWvbepGImaVTxc)i48C1vrbxcculfQZ1wnaKAMeSlI0bu9bydjK6i4bC5chq7NyzSFe8a4LBkMmGAhGc2C84I5QRIcUejrynjyxePZ1wnaR6dJ5neOhWcJbCdIJ0bGzmuiQv(aQDa)edhqTdWx0da1fEBhaPINhfCNRUkk4sKeH1TDC5hblZ6nmcCCmygdfczA7IhJiH5QRIcUejryDBhx(rWYSEdJWBopsQrbxDffCLPTlEmcfS5an2WAdswZ9svHuiqrsuAHldxWBKLNcjHaTHe4cvoZRFeS(UccfA4TnlpfscbAdjWfQCgZnETeKG8fsEE9E(GHUMuAo)SVZlJLJwkRoH7jDE9EMG6tim(QnkmKqoWLj5N99KoVEpJkZ2g0Wh2CRcIXpWxyqdF5N9CTvdiXQI0b08erzl4beowohezgqKwKb02XLFe8akYauPScvwpGaoanRknpGBPCKY4bqGn8aSQjFYaiPWNqpGdpac6vX6bCRI0biRW18aqkepmg9C1vrbxIKiSUTJl)iyzwVHrCeUMnDXdJrBiOxLmTDXJrqSzHWeowohK8r4A20fpmgnsq5o2lTHBZBKDTMKRvkusWILZR3ZhHRztx8Wy05N9C1vrbxIKiSw5cHXvrbxJOiHmR3Wiib7IivMQJGeSlIuwNDHyU6QOGlrsewRCHW4QOGRruKqM1ByeknzU2QbGuuBrshGhdOXTs18AgGvfPnpG)7qcSRIbaxEaDiEaSRshGSyORjLMhGV6bKCTTH44TvGEa3s5Daj2FLc1bK8X(TbuKbqybRcwpaF1diXCp5pGImGfgdaZUg9a8EW4beP8aw2kXaiScU68asEIBoAYaACRmazdK(bCRI0bGIKdi5P48C1vrbxIKiSg)wJRIcUgrrczwVHr0RTiPYuDekyZbASH1gePqOSnnUvmeBE1j(LNxVNpyORjLMZpBjpVEpdTTH44TvGo)SVOfUmCbVr2Q8kfQgn2VL51pcwF)YKcxWBKBCmQS20HyJM9inZRFeS2Iffek0WBBUXXOYAthInA2J0mMB8AjsH8fx0cx6TKXvWzxXMNTbn8HnebZT5m2xurckwSKKccfA4TnF44gZRjszdJMj5N9fwSOGnhOXgwBqq4B14QuhlN1gL9C1vrbxIKiSw5cHXvrbxJOiHmR3WioVsONRUkk4sKeH1ow5lBcigZBit1rWlJLJoR5EPQqkeiNij5LXYrNXSCENRUkk4sKeH1ow5lBSFccpxDvuWLijcRfL80GysS90YB4nMRUkk4sKeH1hxUb2nbUuOsMRZ1wnazFLqZyYC1vrbxs(8kHgbRsH1k3GzBC14REU6QOGljFELqljcRjmg7bRnh4YgIDHklJcTsWMWXY5GGazzQoIK0Witym2dwBoWLne7cvohLc1ALBXIRIQnB4LBkMGa57yV0gUnVr21AsUwP6pHWGzvQJLZMOAylwuPowotKcL79sEAyWCJxlbjjAU2QbG0q4bG0wKakgWpfgdO6dOIbCdUjgJbOC7bOGnh4aSH1gKb4REarkpGKRTnehVTc0d4869buKb8SZdi51gw6b8i1kFa3s5DajgWS9aqQg(WdiXQcYaiHRqLmahZdiTKNoaiEa3s5DapsTYhqIf72WTXjbJLzaVvWeYaIuEajF21KuymGZR3hqrgWZopxDvuWLKpVsOLeH12fjGcdjfgYuDexgUG3iBvELcvJg73Y86hbRTyXBjJRGZOYSTbn8Hn3QGy8d8fg0Wxg7lQibLlUFE9EgABdXXBRaD(zF)YZR3ZOYSTbn8Hn3QGy8d8fg0WxMeUcvKGCYSyHxglhnsswIUyU6QOGljFELqljcRTlsafgskmKP6ioVEpdTTH44TvGo)SVF5517zn7AskmYpBlwoVEplhZ8sqTwI5wPqLXK8Z2ILZR3Zk4QyxWAZr8wnJppcj)SVyU6QOGljFELqljcRj1wKGXgsGlu556CTvdWQcHcn82sMRUkk4sYknbHYfcJRIcUgrrczwVHrWecVkMit1rKejyxePSo7cXC1vrbxswPjsIW6UWLZcHhfCNRUkk4sYknrsew3fUCwi8OGRrjyFjSmvhHMpVEp3fUCwi8OGBgZnETeKGIflA(869Cx4YzHWJcUzs4kuLcrYsyU6QOGljR0ejryTRX86IAzd(rsLP6is6869SRX86IAzd(rsZp77xMeBvELTnRZEljPo2jMoCddSBSH3ySflkiuOH32SWdEdJJv(6zm341sKcLeUyU6QOGljR0ejryTnekmyMaFyflthInlBLabYZvxffCjzLMijcRXqHWePS5axMit1rCE9EgdfctKYMdCzsgZnETeKGO1wS02XLFeCghhdMXqHyU2QbG01hGR1Kb4yEapBzgazlBEarkpa4Yd4wfPdqaVXKyasirYppaKgcpGBP8oan6ALpGUtcgpGi13byvrAhGM7LQIbaXd4wfPWxmaFrpaRksBEU6QOGljR0ejryDJJrL1MoeB0ShPYOqReSjCSCoiiqwMQJa7L2WT5nYUwtYp77x2l5PHbZnETeKOGnhOXgwBqYAUxQkSyjjsWUiszDgdL)47kyZbASH1gKSM7LQcPqOSnnUvmeBE1joYxmxB1aq66dyHdW1AYaUvcXa0fpGBvKw7aIuEalBLyaTobImd4r4bKyUN8haChWbsid4wfPWxmaFrpaRksBEU6QOGljR0ejryDJJrL1MoeB0ShPYuDeyV0gUnVr21AsUwPADcjo2lTHBZBKDTMK1pShfCVNejyxePSoJHYF8DfS5an2WAdswZ9svHuiu2Mg3kgInV6eh55ARgGScxZdaPq8Wy0daUdafjhaVCtXK8asSQiDaUwtqQmaKgcpGQpGiLrpas4OhqhIhqlk5aiScUAYaG4bu9bGg(WdyzRedqL6y58aUvcXao8aWSRrpGAhqun8a6q8aIuEalBLya382CEU6QOGljR0ejry9r4A20fpmgTmvhbXMfct4y5CqKcbk3t68698r4A20fpmgD(zF)YKWEPnCBEJSR1KmBLIeelwWEPnCBEJSR1KmMB8Ajs1IwSG9sB428gzxRj5AL6susCfek0WBB(iCnB6IhgJoRsDSCMy6yxffCDXfTakj6I5ARgGScxZdaPq8Wy0daUdazjgq1haA4dpGLTsmavQJLZd4wjed4WdaZUg9aQDar1WdOdXdis5bSSvIbCZBZ55QRIcUKSstKeH1hHRztx8Wy0YuDeeBwimHJLZbbbY3fCBwifIeHYDSxAd3M3i7AnjxRuxIsIRGqHgEBZhHRztx8Wy0zvQJLZeth7QOGRlUOfqjrZvxffCjzLMijcRLNcjHaTHe4cvwMQJqbBoqJnS2GK1CVuvifcKL88698bdDnP0C(zpxDvuWLKvAIKiSg1siQvUHyJzwMQJOTJl)i48r4A20fpmgTHGEv3j2SqychlNds(iCnB6IhgJwkKVZlJLJohvdBcOPXTIuOmxDvuWLKvAIKiS(iCnBWpsQmvhrBhx(rW5JW1SPlEymAdb9QUZlJLJohvdBcOPXTIuOmxB1aqAi1kFajM8TiPwN8Aops6akYaGRa9a8b0MXOhqul6buRcZoHLzae4aQDay2fvGwMbGg(smI5b4hcu8cwGEa9A5beWb8i8aQyaoza(aErjQa9ai2SqKNRUkk4sYknrsew323IKkt1rKejyxePSo7cX92oU8JGZEZ5rsnk4QROG7C1vrbxswPjsIWAnMD9r4AMit1rKejyxePSo7cXDfS5an2WAdcsqG8C1vrbxswPjsIWAsQRH3AyHwMQJijsWUiszD2fI7TDC5hbN9MZJKAuWvxrb35QRIcUKSstKeH1e2MuezQoIKib7IiL1zxiMRUkk4sYknrsewBdJcUYuDeNxVNpciulEKiJzxfwSCE9E21yEDrTSb)iP5N9C1vrbxswPjsIW6Jac1M(dJEU6QOGljR0ejry9HXegJATYNRUkk4sYknrsew3lmFeqOEU6QOGljR0ejryTVkMeyxyuUqmxDvuWLKvAIKiS(rytfCJmCVZQWSEdJqHwjGbgULYCeojKP6isIeSlIuwNDH4(517zxJ51f1Yg8JKM1WB79ZR3ZnCdeJ2a7gXtvAJgZEdjRH3278Yy5OZr1WMaAACRivYUJJJ586Dcss0C1vrbxswPjsIW6hHnvWnYSEdJWBjj1XoX0HByGDJn8gJLP6is6869SRX86IAzd(rsZp77jDE9E(iCnB6IhgJo)SVRGqHgEBZUgZRlQLn4hjnJ5gVwcsqorZ1wnGetmg9aWWN8ub6bGFcEaW(aI0xZP6fRhqJhPKbCyb8gsLbG0q4b0H4bG0TOAd1dqHRqMbaJugFRi8aUvr6asEi1dWJbGscsoas4kujdaIhaYji5aUvr6aCbboazfqOEap78C1vrbxswPjsIW6hHnvWnYSEdJWjPT9LjgS3si2OGyxit1rO5ZR3ZyVLqSrbXUWO5ZR3ZA4T1IfnFE9Ewbx9tfvB2ulQgnFE9E(zFpCSCoYPSlI0STkqsRr5E4y5CKtzxePzBvifIwNGfljP5ZR3Zk4QFQOAZMAr1O5ZR3Zp77xQ5ZR3ZyVLqSrbXUWO5ZR3ZKWvOkfcusiXroHwqZNxVNpciuBGDtKYgE5g05NTfl9sEAyWCJxlbjwDcxC)869SRX86IAzd(rsZyUXRLifYT4CTvdi5ZD)jIb0DH44kuhqhIhWJ4hbpGk4gsEU6QOGljR0ejry9JWMk4gImvhX5175Jac1IhjYy2vHfl9sEAyWCJxlbjiqjblwuWMd0ydRnizn3lvfibbkZ15ARgaspHWRIjZvxffCjzMq4vXeek4Q4nWEWAtx4nSmvhbVmwo6CunSjGMg3ksH89KoVEpFeUMnDXdJrNF23VmjnmYk4Q4nWEWAtx4nS58WBokfQ1k)EsUkk4MvWvXBG9G1MUWB4CTMUOKNgwS0FcHbZQuhlNnr1WirUsNBCRCXC1vrbxsMjeEvmrsewFeqO2a7MiLn8YnOLP6iA74YpcoFeUMnDXdJrBiOx1Dfek0WBB(WXnMxtKYggntYp77xsSzHWeowohK8r4A20fpmgTuiqXIfSxAd3M3i7AnjxRujlrxmxDvuWLKzcHxftKeH1YFowx(AGDJ3sgdJ05QRIcUKmti8QyIKiSUdvpcRnElzCfS5WEJmvhbXMfct4y5CqYhHRztx8Wy0sHaflwWEPnCBEJSR1KCTsz1jCpPZR3ZUgZRlQLn4hjn)SNRUkk4sYmHWRIjsIWA7hU6ORvU5iCsit1rqSzHWeowohK8r4A20fpmgTuiqXIfSxAd3M3i7AnjxRuwDcZvxffCjzMq4vXejryDKYM3EGVvB6qSILP6ioVEpJzfQcMqmDiwX5NTflNxVNXScvbtiMoeRyJc(2GXzs4kurcYjmxDvuWLKzcHxftKeH14Y2wWMAneBxXZvxffCjzMq4vXejry9niwOBZ1AWmbU(Q45QRIcUKmti8QyIKiSUHBGy0gy3iEQsB0y2BiYuDe8Yy5OrsYs0CTvdaPkOqpaKA2TRv(aqkeEdtgqhIhaBfw9cEayFLZdaIhaQLqmGZR3jYmGQpaBiHuhbNhqYtCZrtgqGrpGaoa5CmGiLhGaEJjXauqOqdVTd44ewpa4oaVTxc)i4bWl3umjpxDvuWLKzcHxftKeH1y2TRvUPl8gMiJcTsWMWXY5GGazzQoIWXY5ihvdBcOrxmsqoNilwU8YWXY5iNYUisZ2QqQwmblwchlNJCk7IinBRcKGaLeU4(LUkQ2SHxUPyccKTyPTJl)i4mMD7ALB0SWrlfkiLxCHflxgowoh5OAytan2QWGscs16eUFPRIQnB4LBkMGazlwA74YpcoJz3Uw5gnlC0sLSKDXfZ15ARgasrTfjLXK5ARgGSbs)aG7auqOqdVTdiGdavMThqKYdWQIRyaA(869b8SNRUkk4sY9AlskIdh3yEnrkBy0mzU6QOGlj3RTiPsIWAIOuSXxTrxkwMQJ4869mruk24R2OlfNXCJxlbj9sEAyWCJxl5(517zIOuSXxTrxkoJ5gVwcsUezjvWMd0ydRnix0ciNBX5QRIcUKCV2IKkjcR1fX2dv6CDU2Qb8d2fr6C1vrbxsMeSlIueQu2TnKuyiJcTsWMWXY5GGazzQoIWf8gzBmJ2axtKYMBSJAMx)iy99KchlNJCrmhiHmxDvuWLKjb7Iivsew7nNhjL(BZysbxQ0OKakjGCci3A6)MJ3ALtOFKUgBioy9asodWvrb3biksqYZv63Frket))QXQs)IIeeQe0pti8QycvcQ0itLG(51pcwtLL(v4kyC50pVmwo6CunSjGMg3kdqQbG8aUpGKgW5175JW1SPlEym68ZEa3hWLdiPbOHrwbxfVb2dwB6cVHnNhEZrPqTw5d4(asAaUkk4MvWvXBG9G1MUWB4CTMUOKNgdWILb0FcHbZQuhlNnr1WdajdqUsNBCRmGlOFxffCPFfCv8gypyTPl8gMguPrHkb9ZRFeSMkl9RWvW4YP)2oU8JGZhHRztx8Wy0gc6vnG7dqbHcn82MpCCJ51ePSHrZK8ZEa3hWLdGyZcHjCSCoi5JW1SPlEym6bifIbGYaSyzayV0gUnVr21AsU2bi1aswIgWf0VRIcU0)raHAdSBIu2Wl3GMguPBnvc63vrbx6x(ZX6YxdSB8wYyyKs)86hbRPYsdQ0jJkb9ZRFeSMkl9RWvW4YPFInleMWXY5GKpcxZMU4HXOhGuigakdWILbG9sB428gzxRj5AhGudWQtya3hqsd4869SRX86IAzd(rsZpB63vrbx6VdvpcRnElzCfS5WEdnOsNiQe0pV(rWAQS0VcxbJlN(j2SqychlNds(iCnB6IhgJEasHyaOmalwga2lTHBZBKDTMKRDasnaRob63vrbx63(HRo6ALBocNe0GkTvtLG(51pcwtLL(v4kyC50)517zmRqvWeIPdXko)ShGfld4869mMvOkycX0HyfBuW3gmotcxH6aqYaqob63vrbx6pszZBpW3QnDiwX0GkDYHkb97QOGl9JlBBbBQ1qSDft)86hbRPYsdQ0Tivc63vrbx6)gel0T5AnyMaxFvm9ZRFeSMklnOsJusLG(51pcwtLL(v4kyC50pVmwo6bGKbKSer)Ukk4s)nCdeJ2a7gXtvAJgZEdHguProbQe0pV(rWAQS0VRIcU0pMD7ALB6cVHj0VcxbJlN(dhlNJCunSjGgDXdajda5CIgGfld4YbC5achlNJCk7IinBRIbi1aAXegGfldiCSCoYPSlI0STkgasqmausyaxmG7d4Yb4QOAZgE5MIjdaXaqEawSmG2oU8JGZy2TRvUrZch9aKAaOGuoGlgWfdWILbC5achlNJCunSjGgBvyqjHbi1aADcd4(aUCaUkQ2SHxUPyYaqmaKhGfldOTJl)i4mMD7ALB0SWrpaPgqYs2aUyaxq)k0kbBchlNdcvAKPbnOFn39NiOsqLgzQe0VRIcU0pQLcv6Nx)iynvwAqLgfQe0VRIcU0pjyxeP0pV(rWAQS0GkDRPsq)86hbRPYs)qB6NWb97QOGl932XLFem932fpM(tG(B7yZ6nm9JJJbZyOqqdQ0jJkb9ZRFeSMkl9dTPFch0VRIcU0FBhx(rW0FBx8y6xbBoqJnS2GK1CVuvmaPqmaugGKdaLb0cd4YbeUG3ilpfscbAdjWfQCMx)iy9aUpafek0WBBwEkKec0gsGlu5mMB8Ajdajda5bCXaKCaNxVNpyORjLMZp7bCFa8Yy5OhGudWQtya3hqsd4869mb1Nqy8vBuyiHCGltYp7bCFajnGZR3ZOYSTbn8Hn3QGy8d8fg0Wx(zt)TDSz9gM(9MZJKAuWvxrbxAqLorujOFE9JG1uzPFOn9t4G(DvuWL(B74YpcM(B7Iht)eBwimHJLZbjFeUMnDXdJrpaKmaugW9bG9sB428gzxRj5AhGudaLegGfld48698r4A20fpmgD(zt)TDSz9gM(pcxZMU4HXOne0RIguPTAQe0pV(rWAQS0VcxbJlN(jb7IiL1zxiOFxffCPFLlegxffCnIIe0VOiHz9gM(jb7IiLguPtoujOFE9JG1uzPFxffCPFLlegxffCnIIe0VOiHz9gM(vAcnOs3IujOFE9JG1uzPFfUcgxo9RGnhOXgwBqgGuigGY204wXqS5vpGeFaxoGZR3Zhm01KsZ5N9aKCaNxVNH22qC82kqNF2d4Ib0cd4YbeUG3iBvELcvJg73Y86hbRhW9bC5asAaHl4nYnogvwB6qSrZEKM51pcwpalwgGccfA4Tn34yuzTPdXgn7rAgZnETKbi1aqEaxmGlgqlmGlhG3sgxbNDfBE2g0Wh2qem3MZyFrDaizaOmalwgqsdqbHcn82MpCCJ51ePSHrZK8ZEaxmalwgGc2CGgByTbzaigGVvJRsDSCwBu20VRIcU0p(TgxffCnIIe0VOiHz9gM(71wKuAqLgPKkb9ZRFeSMkl97QOGl9RCHW4QOGRruKG(ffjmR3W0)5vcnnOsJCcujOFE9JG1uzPFfUcgxo9ZlJLJoR5EPQyasHyaiNObi5a4LXYrNXSCEPFxffCPFhR8LnbeJ5nObvAKrMkb97QOGl97yLVSX(jim9ZRFeSMklnOsJmkujOFxffCPFrjpniMeBpT8gEd6Nx)iynvwAqLg5wtLG(DvuWL(pUCdSBcCPqLq)86hbRPYsdAq)2ywbBoEqLGknYujOFxffCPF32wG2ydlcCPFE9JG1uzPbvAuOsq)86hbRPYs)Ukk4s)nogvwB6qSrZEKs)kCfmUC6h7L2WT5nYUwtY1oaPgqYsG(TXSc2C8WqyfC1e6pr0GkDRPsq)86hbRPYs)kCfmUC6)YbK0ayRYRSTzD2gQqLds1swBuWg7x4rbxJMBxkEawSmGKgGccfA4TnRqReWad3szocNez9d7rb3byXYaWEPnCBEJCTTFILX(rWz2kfjid4c63vrbx6NeSlIuAqLozujOFE9JG1uzPFxffCPFmuimrkBoWLj0VcxbJlN(XChZKu)iy63gZkyZXddHvWvtOFuObv6erLG(51pcwtLL(DvuWL(jIsXgF1gDPy6xHRGXLt)yUJzsQFem9BJzfS54HHWk4Qj0pk0GkTvtLG(51pcwtLL(DvuWL(DnMxxulBWpsk9RWvW4YP)lhqsdGTkVY2M1zBOcvoivlzTrbBSFHhfCnAUDP4byXYasAakiuOH32ScTsadmClL5iCsK1pShfChGflda7L2WT5nY12(jwg7hbNzRuKGmGlOFBmRGnhpmewbxnH(rMguPtoujOFE9JG1uzP)1By63Bjj1XoX0HByGDJn8gJPFxffCPFVLKuh7ethUHb2n2WBmMguPBrQe0pV(rWAQS0VRIcU0VcTsadmClL5iCsq)kCfmUC6pPbG9sB428g5AB)elJ9JGZSvksqOFU3zvywVHPFfALagy4wkZr4KGg0G(71wKuQeuPrMkb97QOGl9F44gZRjszdJMj0pV(rWAQS0GknkujOFE9JG1uzPFfUcgxo9FE9EMikfB8vB0LIZyUXRLmaKmGEjpnmyUXRLmG7d4869mruk24R2OlfNXCJxlzaizaxoaKhGKdqbBoqJnS2GmGlgqlmaKZTi97QOGl9teLIn(Qn6sX0GkDRPsq)Ukk4s)6Iy7HkL(51pcwtLLg0G(jb7IiLkbvAKPsq)86hbRPYs)Ukk4s)Qu2TnKuyq)kCfmUC6pCbVr2gZOnW1ePS5g7OM51pcwpG7diPbeowoh5IyoqcH(vOvc2eowoheQ0itdQ0OqLG(DvuWL(9MZJKs)86hbRPYsdAq)knHkbvAKPsq)86hbRPYs)kCfmUC6pPbqc2frkRZUqq)Ukk4s)kximUkk4AefjOFrrcZ6nm9ZecVkMqdQ0OqLG(DvuWL(7cxoleEuWL(51pcwtLLguPBnvc6Nx)iynvw6xHRGXLt)A(869Cx4YzHWJcUzm341sgasgakdWILbO5ZR3ZDHlNfcpk4MjHRqDasHyajlb63vrbx6VlC5Sq4rbxJsW(syAqLozujOFE9JG1uzPFfUcgxo9N0aoVEp7AmVUOw2GFK08ZEa3hWLdiPbWwLxzBZ6S3ssQJDIPd3Wa7gB4ngpalwgGccfA4Tnl8G3W4yLVEgZnETKbi1aqjHbCb97QOGl97AmVUOw2GFKuAqLorujOFE9JG1uzP)oeBw2kbvAKPFxffCPFBiuyWmb(WkMguPTAQe0pV(rWAQS0VcxbJlN(pVEpJHcHjszZbUmjJ5gVwYaqcIb06byXYaA74YpcoJJJbZyOqq)Ukk4s)yOqyIu2CGltObv6Kdvc6Nx)iynvw63vrbx6VXXOYAthInA2Ju6xHRGXLt)yV0gUnVr21As(zpG7d4Yb0l5PHbZnETKbGKbOGnhOXgwBqYAUxQkgGfldiPbqc2frkRZyO8hpG7dqbBoqJnS2GK1CVuvmaPqmaLTPXTIHyZREaj(aqEaxq)k0kbBchlNdcvAKPbv6wKkb9ZRFeSMkl9RWvW4YPFSxAd3M3i7Anjx7aKAaToHbK4da7L2WT5nYUwtY6h2JcUd4(asAaKGDrKY6mgk)Xd4(auWMd0ydRnizn3lvfdqkedqzBACRyi28QhqIpaKPFxffCP)ghJkRnDi2OzpsPbvAKsQe0pV(rWAQS0VcxbJlN(j2SqychlNdYaKcXaqza3hqsd48698r4A20fpmgD(zpG7d4YbK0aWEPnCBEJSR1KmBLIeKbyXYaWEPnCBEJSR1KmMB8AjdqQb0IdWILbG9sB428gzxRj5AhGud4YbGYas8bOGqHgEBZhHRztx8Wy0zvQJLZeth7QOGRlgWfdOfgakjAaxq)Ukk4s)hHRztx8Wy00GknYjqLG(51pcwtLL(v4kyC50pXMfct4y5CqgaIbG8aUpab3MfdqkedirOmG7da7L2WT5nYUwtY1oaPgWLdaLbK4dqbHcn82MpcxZMU4HXOZQuhlNjMo2vrbxxmGlgqlmause97QOGl9FeUMnDXdJrtdQ0iJmvc6Nx)iynvw6xHRGXLt)kyZbASH1gKSM7LQIbifIbG8aKCaNxVNpyORjLMZpB63vrbx6xEkKec0gsGluzAqLgzuOsq)86hbRPYs)kCfmUC6VTJl)i48r4A20fpmgTHGEvd4(ai2SqychlNds(iCnB6IhgJEasnaKhW9bWlJLJohvdBcOPXTYaKAaOq)Ukk4s)OwcrTYneBmZ0GknYTMkb9ZRFeSMkl9RWvW4YP)2oU8JGZhHRztx8Wy0gc6vnG7dGxglhDoQg2eqtJBLbi1aqH(DvuWL(pcxZg8JKsdQ0iNmQe0pV(rWAQS0VcxbJlN(tAaKGDrKY6Sled4(aA74Ypco7nNhj1OGRUIcU0VRIcU0FBFlsknOsJCIOsq)86hbRPYs)kCfmUC6pPbqc2frkRZUqmG7dqbBoqJnS2GmaKGyait)Ukk4s)Am76JW1mHguPr2QPsq)86hbRPYs)kCfmUC6pPbqc2frkRZUqmG7dOTJl)i4S3CEKuJcU6kk4s)Ukk4s)KuxdV1WcnnOsJCYHkb9ZRFeSMkl9RWvW4YP)KgajyxePSo7cb97QOGl9tyBsrObvAKBrQe0pV(rWAQS0VcxbJlN(pVEpFeqOw8irgZUkgGfld4869SRX86IAzd(rsZpB63vrbx63ggfCPbvAKrkPsq)Ukk4s)hbeQn9hgn9ZRFeSMklnOsJscujOFxffCP)dJjmg1ALt)86hbRPYsdQ0OGmvc63vrbx6Vxy(iGqn9ZRFeSMklnOsJckujOFxffCPFFvmjWUWOCHG(51pcwtLLguPrP1ujOFE9JG1uzPFxffCPFfALagy4wkZr4KG(v4kyC50FsdGeSlIuwNDHya3hW517zxJ51f1Yg8JKM1WB7aUpGZR3ZnCdeJ2a7gXtvAJgZEdjRH32bCFa8Yy5OZr1WMaAACRmaPgqYgW9bGJJ586DYaqYase9Z9oRcZ6nm9RqReWad3szocNe0GknkjJkb9ZRFeSMkl97QOGl97TKK6yNy6WnmWUXgEJX0VcxbJlN(tAaNxVNDnMxxulBWpsA(zpG7diPbCE9E(iCnB6IhgJo)ShW9bOGqHgEBZUgZRlQLn4hjnJ5gVwYaqYaqor0)6nm97TKK6yNy6WnmWUXgEJX0GknkjIkb9ZRFeSMkl97QOGl97K02(Yed2BjeBuqSlOFfUcgxo9R5ZR3ZyVLqSrbXUWO5ZR3ZA4TDawSmanFE9Ewbx9tfvB2ulQgnFE9E(zpG7diCSCoYPSlI0STkgasgqRrza3hq4y5CKtzxePzBvmaPqmGwNWaSyzajnanFE9Ewbx9tfvB2ulQgnFE9E(zpG7d4YbO5ZR3ZyVLqSrbXUWO5ZR3ZKWvOoaPqmausyaj(aqoHb0cdqZNxVNpciuBGDtKYgE5g05N9aSyza9sEAyWCJxlzaizawDcd4IbCFaNxVNDnMxxulBWpsAgZnETKbi1aqUfP)1By63jPT9LjgS3si2OGyxqdQ0Oy1ujOFE9JG1uzPFfUcgxo9FE9E(iGqT4rImMDvmalwgqVKNggm341sgasqmausyawSmafS5an2WAdswZ9svXaqcIbGc97QOGl9)iSPcUHqdAq)Nxj0ujOsJmvc63vrbx6NvPWALBWSnUA8vt)86hbRPYsdQ0OqLG(51pcwtLL(DvuWL(jmg7bRnh4YgIDHkt)kCfmUC6pPbOHrMWyShS2CGlBi2fQCokfQ1kFawSmaxfvB2Wl3umzaigaYd4(aWEPnCBEJSR1KCTdqQb0FcHbZQuhlNnr1WdWILbOsDSCMmaPgakd4(a6L80WG5gVwYaqYase9RqReSjCSCoiuPrMguPBnvc6Nx)iynvw6xHRGXLt)xoGWf8gzRYRuOA0y)wMx)iy9aSyzaElzCfCgvMTnOHpS5wfeJFGVWGg(YyFrDaizaOmGlgW9bCE9EgABdXXBRaD(zpG7d4YbCE9EgvMTnOHpS5wfeJFGVWGg(YKWvOoaKmaKt2aSyza8Yy5OhasgqYs0aUG(DvuWL(TlsafgskmObv6KrLG(51pcwtLL(v4kyC50)517zOTnehVTc05N9aUpGlhW517zn7AskmYp7byXYaoVEplhZ8sqTwI5wPqLXK8ZEawSmGZR3Zk4QyxWAZr8wnJppcj)ShWf0VRIcU0VDrcOWqsHbnOsNiQe0VRIcU0pP2Iem2qcCHkt)86hbRPYsdAqdAqdkfa]] )

end