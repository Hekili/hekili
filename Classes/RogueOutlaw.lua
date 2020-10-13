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
            cooldown = function () return ( 1 - conduit.quick_decisions.mod * 0.01 ) * ( talent.retractable_hook.enabled and 30 or 60 ) end,
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


    spec:RegisterPack( "Outlaw", 20201013, [[d8ufbbqirjpskjBck6tuskzuQeDkvcRsuQ8kIOzrK6wIc1Ue5xusnmrrhtLYYGk9mPennPK6AIc2MOq(MOuY4eLQohLKQ1bfsmpOG7bL2hrPdcfclKO4Husstuuk1fHcfBekensOqsojui1kvj9sOqsntkjf6Musk1ojs(POu0qHcvokLKcwkuO0tvvtLiCvOqvBLssrFvuk4SIsHAVi9xkgmWHPAXQ4XKmzsDzuBwQ(mr1OfvNwYQfLc51qfZMWTLIDR0VbnCk1XPKelhYZrmDHRRkBxk13vPA8usCEOQ1lLW8Pe7xX0BujOFThmvkCZe3mVL5TwMY0Q3YBziBr)bEBM(TDfoUCM(xVHP)S5le(D632XlGUMkb9tGpKIP)8iSjyuS2A5vK)ojfSXAs18eEuWvH8EynPAuwt)Nxjcm6LEOFThmvkCZe3mVL5TwMY0Q3YBzid0pXMvuPWnJYK(ZlTMx6H(1mrr)TAazZxi87daJfk)XZ1wnGSPkGhgnGBTu6bGBM4Mj9BJG9sW0FRgq28fc)(aWyHYF8CTvdiBQc4Hrd4wlLEa4MjUzoxNRTAaymwHvVG1d4WDiIhGc2C8yahwETK0aWiuk2oidyHBgN7OM(tmaxffCjdaUc8P5QRIcUKKnIvWMJhyDBBbEJnSiWDU6QOGljzJyfS54HKyTUXr4WAthImA2JCPTrSc2C8WqyfC1eSzq6QJf5L2WT5nsUwts1kBRZCU6QOGljzJyfS54HKyTMeSlICPRo2lZITkVY2M1jBOchoivlyTrbBSFHhfCnAUDPylwYsbHcn8(Mu4vcyGGBPmhHtIK(H8OGRfliV0gUnVrQ22pXYi)i4eBLIeKlMRUkk4ss2iwbBoEijwRrqHWe5S5axMiTnIvWMJhgcRGRMGfxPRowe3rmj3pcEU6QOGljzJyfS54HKyTMikfB8vB0LIL2gXkyZXddHvWvtWIR0vhlI7iMK7hbpxDvuWLKSrSc2C8qsSw7AeVUOw2GEKCPTrSc2C8WqyfC1eS3KU6yVml2Q8kBBwNSHkC4GuTG1gfSX(fEuW1O52LITyjlfek0W7BsHxjGbcULYCeojs6hYJcUwSG8sB428gPAB)elJ8JGtSvksqUyU6QOGljzJyfS54HKyT(rytfCJ0R3Wy9wqYDKtmD4ggy3ydVZO5QRIcUKKnIvWMJhsI16hHnvWnsZ9oRcZ6nmwfELagi4wkZr4Kq6QJnlKxAd3M3ivB7NyzKFeCITsrcYCDU2QbGXyfw9cwpaUnJWpGOA4be58aCvardOidWB7LWpconxDvuWLGfNsHZCTvdaJLjb7IiFavFa2qcPocEaxUWb0(jwg5hbpaE5MIjdO2bOGnhpUyU6QOGlrsSwtc2fr(CTvdWQ(qiEdb(bSWya3HOiFaigbfIALpGAhW3QXbu7a8f)aWzH33bqQ45rb35QRIcUejXADBhv(rWsVEdJffhdIrqHq62U4XyZCU6QOGlrsSw32rLFeS0R3Wy9MZJKBuWvxrbxPB7IhJvbBoqJnS2GK0CVuvilwCLe3S7YWf8gj55qsiWBibQWHt86hbRXubHcn8(MKNdjHaVHeOchoH4gVwcgUDHKNxVNoiORjLMtpBm5LrYXlBgLjMzDE9EIGZtim(QnkeKqoWLjPNnMzDE9EchMTn4HpK5EfeJFGVWGh(sp75ARgq2qf5dO5jIYwWdiCKCoispGiVidOTJk)i4buKbOYzfoSEabCaAwvAEa3Z5iNrdGaB4byvZ2KbqYHpHEahEae8RI1d4Ef5dqgHR5bGrkEie(5QRIcUejXADBhv(rWsVEdJ9iCnB6IhcH3qWVkPB7IhJLyZcHjCKCoiPJW1SPlEieEmGlMiV0gUnVrY1AsQwzXntlwoVEpDeUMnDXdHWNE2ZvxffCjsI1ALlegxffCnIIesVEdJLeSlICPRowsWUiYzDYfI5QRIcUejXATYfcJRIcUgrrcPxVHXQ0K5ARgagzTfjFaEmGg3kvZRzawvmU0a(VdjqUkgaC5b0HObWUkFaYGGUMuAEa(Qhq202gII3wb(bCpN3by1WRu4mGSnYVpGImaclyvW6b4REawT7z7buKbSWyai214hG3dgnGiNhWYwjgaHvWvNgagH4UJNmGg3kdqMaJza3RiFa4k5aWiuCAU6QOGlrsSwJERXvrbxJOiH0R3Wy71wKCPRowfS5an2WAdISyv2Mg3kgInV6m(YZR3the01KsZPNTKNxVNG22qu82kWNE2xKDxgUG3izvELchJg53t86hbRX8YScxWBKACeoS20HiJM9ipXRFeS2Iffek0W7BQXr4WAthImA2J8eIB8AjYE7IlYUl9wWOk4KRyZZ2Gh(qgIG52Cc5loyaxlwYsbHcn8(MoCCN51e5SHXZK0Z(clwuWMd0ydRniy9TACvUJKZAJYEU6QOGlrsSwRCHW4QOGRruKq61BySNxj0ZvxffCjsI1AhP8LnbeH4nKU6y5LrYXN0CVuvil2BzqsEzKC8jelN35QRIcUejXATJu(Yg7NGWZvxffCjsI1ArjppiMSrpT8gEJ5QRIcUejXA9XLBGDtGkfoK56CTvdqMxj0mImxDvuWLKoVsOXYQCyTYni2gvn(QNRUkk4ssNxj0sI1AcJqEWAZbUSHyx4WsRWReSjCKCoiyVjD1XMLggjcJqEWAZbUSHyx4WPOu4uRClwCvuTzdVCtXeS3We5L2WT5nsUwts1kB)jegeRYDKC2evdBXIk3rYzIS4IzVKNhge341sWqgMRTAay8eEayCfjGIb8ZHXaQ(aQya3HRvRyak3EakyZboaByTbza(QhqKZdiBABdrXBRa)aoVEFafzap70aWiAdl9aEKALpG758oamQz2EazJHp0aYgQGmas4kCidWr8aYl55daIgW9CEhWJuR8bKnWUnCBCsWiPhWBfmHmGiNhq2MDnjhgd4869buKb8StZvxffCjPZReAjXATDrcOWqYHH0vh7LHl4nswLxPWXOr(9eV(rWAlw8wWOk4eomBBWdFiZ9kig)aFHbp8Lq(IdgW9cmpVEpbTTHO4TvGp9SX8YZR3t4WSTbp8Hm3RGy8d8fg8WxIeUchmCR1wSWlJKJhdTodxmxDvuWLKoVsOLeR12fjGcdjhgsxDSNxVNG22qu82kWNE2yE5517jn7AsomspBlwoVEpjhX8sWPwI5EPWHrK0Z2ILZR3tk4QyxWAZr8wnJopcj9SVyU6QOGljDELqljwRj1wKGrgsGkC456CTvdWQcHcn8(sMRUkk4ssknbRYfcJRIcUgrrcPxVHXYecVkMiD1XMfjyxe5So5cXC1vrbxssPjsI16UWLZcHhfCNRUkk4ssknrsSw3fUCwi8OGRrjyFjS0vhRMpVEp1fUCwi8OGBcXnETemGRflA(869ux4YzHWJcUjs4kCKfBRZCU6QOGljP0ejXATRr86IAzd6rYLU6yZ6869KRr86IAzd6rYtpBmVml2Q8kBBwN8wqYDKtmD4ggy3ydVZilwuqOqdVVjHh8gghP81tiUXRLilUzEXC1vrbxssPjsI1ABiuyqmb(qkw6oezw2kb2BZvxffCjjLMijwRrqHWe5S5axMiD1XEE9EcbfctKZMdCzscXnETemGTLwS02rLFeCcfhdIrqHyU2QbGr3hGR1Kb4iEapBPhazlBEaropa4Yd4Ef5dqaVZKyasir2onamEcpG758oan(ALpGUtcgnGi33byvX4gGM7LQIbard4Ef5WxmaFXpaRkgxAU6QOGljP0ejXADJJWH1Moez0Sh5sRWReSjCKCoiyVjD1XI8sB428gjxRjPNnMx2l55HbXnETemOGnhOXgwBqsAUxQkSyjlsWUiYzDcbL)ymvWMd0ydRnijn3lvfYIvzBACRyi28QZ4BxmxB1aWO7dyHdW1AYaUxcXa0fpG7vKx7aICEalBLyaTmtI0d4r4by1UNThaChWbsid4Ef5WxmaFXpaRkgxAU6QOGljP0ejXADJJWH1Moez0Sh5sxDSiV0gUnVrY1AsQwzBzMzmYlTHBZBKCTMK0pKhfCXmlsWUiYzDcbL)ymvWMd0ydRnijn3lvfYIvzBACRyi28QZ4BZ1wnazeUMhagP4Hq4haChaUsoaE5MIjPbKnur(aCTMGrzay8eEavFaroJFaKWXpGoenGSxYbqyfC1KbardO6dap8HgWYwjgGk3rY5bCVeIbC4bGyxJFa1oGOA4b0HObe58aw2kXaU7T50C1vrbxssPjsI16JW1SPlEieEPRowInleMWrY5GilwCXmRZR3thHRztx8qi8PNnMxMfYlTHBZBKCTMKyRuKGyXcYlTHBZBKCTMKqCJxlr2S3IfKxAd3M3i5AnjvRSxIBgRGqHgEFthHRztx8qi8jvUJKZeth5QOGRlUi7WndxmxB1aKr4AEayKIhcHFaWDa3KyavFa4Hp0aw2kXau5osopG7LqmGdpae7A8dO2bevdpGoenGiNhWYwjgWDVnNMRUkk4ssknrsSwFeUMnDXdHWlD1XsSzHWeosoheS3We5L2WT5nsUwts1k7L4MXkiuOH330r4A20fpecFsL7i5mX0rUkk46IlYoCZWC1vrbxssPjsI1A55qsiWBibQWHLU6yvWMd0ydRnijn3lvfYI9MKNxVNoiORjLMtp75QRIcUKKstKeR14ucrTYneBeZsxDSTDu5hbNocxZMU4Hq4ne8RctInleMWrY5GKocxZMU4Hq4L9gM8Yi54tr1WMaAACRilUZvxffCjjLMijwRpcxZg0JKlD1X22rLFeC6iCnB6IhcH3qWVkm5LrYXNIQHnb004wrwCNRTAay8KALpaRM(wKCRXiAops(akYaGRa)a8b0Mr4hqul(buRcXoHLEae4aQDai2fvGx6bGh(SAH4b4hcu8cwGFa9A5beWb8i8aQyaoza(aErjQa)ai2SqKMRUkk4ssknrsSw323IKlD1XMfjyxe5So5cbMTDu5hbN8MZJKBuWvxrb35QRIcUKKstKeR1Ae76JW1mr6QJnlsWUiYzDYfcmvWMd0ydRniya7T5QRIcUKKstKeR1KCxdV3WcT0vhBwKGDrKZ6Kley22rLFeCYBopsUrbxDffCNRUkk4ssknrsSwtyBsrKU6yZIeSlICwNCHyU6QOGljP0ejXATnmk4kD1XEE9E6iGqT4rIeIDvyXY517jxJ41f1Yg0JKNE2ZvxffCjjLMijwRpciuB6pe(5QRIcUKKstKeR1hgryeo1kFU6QOGljP0ejXADVq8raH65QRIcUKKstKeR1(QysGCHr5cXC1vrbxssPjsI16hHnvWnsZ9oRcZ6nmwfELagi4wkZr4Kq6QJnlsWUiYzDYfcmpVEp5AeVUOw2GEK8KgEFX8869ud3ar4nWUr8uL2OrS3qsA49ftEzKC8POAytannUvKT1yIIJ586DcgYWC1vrbxssPjsI16hHnvWnsVEdJ1Bbj3roX0HByGDJn8oJKU6yZ6869KRr86IAzd6rYtpBmZ68690r4A20fpecF6zJPccfA49n5AeVUOw2GEK8eIB8Ajy4wgMRTAawnze(bGGp55c8da9e8aG9be5VMt1lwpGgpYjd4Wc4DmkdaJNWdOdrdaJEXXgQhGcvH0dag5m6Er4bCVI8bGrGXoapgaUzk5aiHRWHmaiAa3YuYbCVI8b4ccCaYiGq9aE2P5QRIcUKKstKeR1pcBQGBKE9ggRtYB7ltmiVfqKrbrUq6QJvZNxVNqElGiJcICHrZNxVN0W7RflA(869KcU6NkQ2SPwCmA(8690ZgZWrY5iLZUiYt2QadTexmdhjNJuo7IipzRczX2YmTyjlnFE9Esbx9tfvB2ulognFE9E6zJ5LA(869eYBbezuqKlmA(869ejCfoYIf3mZ4BzMDA(8690raHAdSBIC2Wl3Gp9STyPxYZddIB8AjyiJY8cmpVEp5AeVUOw2GEK8eIB8AjYEl7NRTAazBU7prmGUlehxHZa6q0aEe)i4bub3qsZvxffCjjLMijwRFe2ub3qKU6ypVEpDeqOw8ircXUkSyPxYZddIB8AjyalUzAXIc2CGgByTbjP5EPQadyXDUoxB1aWyieEvmzU6QOGljXecVkMGvbxfVbYdwB6cVHLU6y5LrYXNIQHnb004wr2ByM1517PJW1SPlEie(0ZgZlZsdJKcUkEdKhS20fEdBop0MIsHtTYXmlxffCtk4Q4nqEWAtx4nCQwtxuYZdlw6pHWGyvUJKZMOAymixPtnUvUyU6QOGljXecVkMijwRpciuBGDtKZgE5g8sxDSTDu5hbNocxZMU4Hq4ne8Rctfek0W7B6WXDMxtKZggptspBmVKyZcHjCKCoiPJW1SPlEieEzXIRfliV0gUnVrY1AsQwzBDgUyU6QOGljXecVkMijwRL)CKU81a7gVfmcg5ZvxffCjjMq4vXejXADhQEewB8wWOkyZH9gPRowInleMWrY5GKocxZMU4Hq4LflUwSG8sB428gjxRjPALnJYeZSoVEp5AeVUOw2GEK80ZEU6QOGljXecVkMijwRTFOQJVw5MJWjH0vhlXMfct4i5CqshHRztx8qi8YIfxlwqEPnCBEJKR1KuTYMrzoxDvuWLKycHxftKeR1roBE7b(wTPdrkw6QJ9869eIv4iycX0HifNE2wSCE9EcXkCemHy6qKInk4BdgLiHRWbd3YCU6QOGljXecVkMijwRrLTTGn1Ai2UINRUkk4ssmHWRIjsI167qKq3MR1GycC9vXZvxffCjjMq4vXejXADd3ar4nWUr8uL2OrS3qKU6y5LrYXJHwNH5ARgagvqHEaySSBxR8bGrk8gMmGoena2kS6f8aq(kNhaenaCkHyaNxVtKEavFa2qcPoconamcXDhpzabc)ac4aKZXaICEac4DMedqbHcn8(oGJty9aG7a82Ej8JGhaVCtXK0C1vrbxsIjeEvmrsSwJy3Uw5MUWByI0k8kbBchjNdc2BsxDSHJKZrkQg2eqJUymClLblwU8YWrY5iLZUiYt2Qq2SptlwchjNJuo7IipzRcmGf3mVaZlDvuTzdVCtXeS3SyPTJk)i4eID7ALB0SWXllUw9lUWILldhjNJuunSjGgBvyWntzBzMyEPRIQnB4LBkMG9MflTDu5hbNqSBxRCJMfoEzBDRV4I56CTvdaJS2IKZiYCTvdqMaJzaWDakiuOH33beWbGdZ2diY5byvrvmanFE9(aE2ZvxffCjPETfjh7HJ7mVMiNnmEMmxDvuWLK61wKCjXAnruk24R2OlflD1XEE9EIikfB8vB0LItiUXRLGHEjppmiUXRLG5517jIOuSXxTrxkoH4gVwcgU8MKkyZbASH1gKlYUBPSFU6QOGlj1RTi5sI1ADrS9qLpxNRTAa)GDrKpxDvuWLKib7IihRkNDBdjhgsRWReSjCKCoiyVjD1XgUG3izJy8g4AIC2CNDCs86hbRXmRWrY5iveZbsiZvxffCjjsWUiYLeR1EZ5rYP)2mIuWLkfUzIBM3Y82n6)UJ2ALtOFm6gBiky9aYwdWvrb3biksqsZv63Froer))QXQs)IIeeQe0pti8QycvcQu3Osq)86hbRPYq)kufmQC6NxgjhFkQg2eqtJBLbi7aUnamhqwd48690r4A20fpecF6zpamhWLdiRbOHrsbxfVbYdwB6cVHnNhAtrPWPw5daZbK1aCvuWnPGRI3a5bRnDH3WPAnDrjppgGfldO)ecdIv5osoBIQHhaggGCLo14wzaxq)Ukk4s)k4Q4nqEWAtx4nmnOsHlvc6Nx)iynvg6xHQGrLt)TDu5hbNocxZMU4Hq4ne8RAayoafek0W7B6WXDMxtKZggptsp7bG5aUCaeBwimHJKZbjDeUMnDXdHWpazXoaChGflda5L2WT5nsUwts1oazhqRZWaUG(DvuWL(pciuBGDtKZgE5g80GkvlPsq)Ukk4s)YFosx(AGDJ3cgbJC6Nx)iynvgAqLQ1ujOFE9JG1uzOFfQcgvo9tSzHWeosohK0r4A20fpec)aKf7aWDawSmaKxAd3M3i5Anjv7aKDazuMdaZbK1aoVEp5AeVUOw2GEK80ZM(DvuWL(7q1JWAJ3cgvbBoS3qdQuzGkb9ZRFeSMkd9RqvWOYPFInleMWrY5GKocxZMU4Hq4hGSyhaUdWILbG8sB428gjxRjPAhGSdiJYK(DvuWL(TFOQJVw5MJWjbnOsLrujOFE9JG1uzOFfQcgvo9FE9EcXkCemHy6qKItp7byXYaoVEpHyfocMqmDisXgf8TbJsKWv4mammGBzs)Ukk4s)roBE7b(wTPdrkMguPYwujOFxffCPFuzBlytTgITRy6Nx)iynvgAqLk7Psq)Ukk4s)3HiHUnxRbXe46RIPFE9JG1uzObvkRovc6Nx)iynvg6xHQGrLt)8Yi54haggqRZa97QOGl93WnqeEdSBepvPnAe7neAqL6wMujOFE9JG1uzOFxffCPFe721k30fEdtOFfQcgvo9hosohPOAytan6IhaggWTuggGfld4YbC5achjNJuo7IipzRIbi7aY(mhGfldiCKCos5SlI8KTkgagWoaCZCaxmamhWLdWvr1Mn8Ynftga2bCBawSmG2oQ8JGti2TRvUrZch)aKDa4A1hWfd4IbyXYaUCaHJKZrkQg2eqJTkm4M5aKDaTmZbG5aUCaUkQ2SHxUPyYaWoGBdWILb02rLFeCcXUDTYnAw44hGSdO1TEaxmGlOFfELGnHJKZbHk1nAqd6xZD)jcQeuPUrLG(DvuWL(XPu4q)86hbRPYqdQu4sLG(DvuWL(jb7IiN(51pcwtLHguPAjvc6Nx)iynvg6hAt)eoOFxffCP)2oQ8JGP)2U4X0FM0FBhzwVHPFuCmigbfcAqLQ1ujOFE9JG1uzOFOn9t4G(DvuWL(B7OYpcM(B7Iht)kyZbASH1gKKM7LQIbil2bG7aKCa4oGSBaxoGWf8gj55qsiWBibQWHt86hbRhaMdqbHcn8(MKNdjHaVHeOchoH4gVwYaWWaUnGlgGKd48690bbDnP0C6zpamhaVmso(bi7aYOmhaMdiRbCE9EIGZtim(QnkeKqoWLjPN9aWCaznGZR3t4WSTbp8Hm3RGy8d8fg8Wx6zt)TDKz9gM(9MZJKBuWvxrbxAqLkdujOFE9JG1uzOFOn9t4G(DvuWL(B7OYpcM(B7Iht)eBwimHJKZbjDeUMnDXdHWpammaChaMda5L2WT5nsUwts1oazhaUzoalwgW517PJW1SPlEie(0ZM(B7iZ6nm9FeUMnDXdHWBi4xfnOsLrujOFE9JG1uzOFfQcgvo9tc2froRtUqq)Ukk4s)kximUkk4AefjOFrrcZ6nm9tc2fronOsLTOsq)86hbRPYq)Ukk4s)kximUkk4AefjOFrrcZ6nm9R0eAqLk7Psq)86hbRPYq)kufmQC6xbBoqJnS2GmazXoaLTPXTIHyZREaz8aUCaNxVNoiORjLMtp7bi5aoVEpbTTHO4TvGp9ShWfdi7gWLdiCbVrYQ8kfognYVN41pcwpamhWLdiRbeUG3i14iCyTPdrgn7rEIx)iy9aSyzakiuOH33uJJWH1Moez0Sh5je341sgGSd42aUyaxmGSBaxoaVfmQco5k28Sn4HpKHiyUnNq(IZaWWaWDawSmGSgGccfA49nD44oZRjYzdJNjPN9aUyawSmafS5an2WAdYaWoaFRgxL7i5S2OSPFxffCPF0BnUkk4AefjOFrrcZ6nm93RTi50GkLvNkb9ZRFeSMkd97QOGl9RCHW4QOGRruKG(ffjmR3W0)5vcnnOsDltQe0pV(rWAQm0VcvbJkN(5LrYXN0CVuvmazXoGBzyasoaEzKC8jelNx63vrbx63rkFztariEdAqL62nQe0VRIcU0VJu(Yg7NGW0pV(rWAQm0Gk1nCPsq)Ukk4s)IsEEqmzJEA5n8g0pV(rWAQm0Gk1TwsLG(DvuWL(pUCdSBcuPWHq)86hbRPYqdAq)2iwbBoEqLGk1nQe0VRIcU0VBBlWBSHfbU0pV(rWAQm0GkfUujOFE9JG1uzOFxffCP)ghHdRnDiYOzpYPFfQcgvo9J8sB428gjxRjPAhGSdO1zs)2iwbBoEyiScUAc9NbAqLQLujOFE9JG1uzOFfQcgvo9F5aYAaSv5v22Sozdv4WbPAbRnkyJ9l8OGRrZTlfpalwgqwdqbHcn8(Mu4vcyGGBPmhHtIK(H8OG7aSyzaiV0gUnVrQ22pXYi)i4eBLIeKbCb97QOGl9tc2fronOs1AQe0pV(rWAQm0VRIcU0pckeMiNnh4Ye6xHQGrLt)iUJysUFem9BJyfS54HHWk4Qj0pU0GkvgOsq)86hbRPYq)Ukk4s)erPyJVAJUum9RqvWOYPFe3rmj3pcM(TrSc2C8WqyfC1e6hxAqLkJOsq)86hbRPYq)Ukk4s)UgXRlQLnOhjN(vOkyu50)LdiRbWwLxzBZ6KnuHdhKQfS2OGn2VWJcUgn3Uu8aSyzaznafek0W7BsHxjGbcULYCeojs6hYJcUdWILbG8sB428gPAB)elJ8JGtSvksqgWf0VnIvWMJhgcRGRMq)3ObvQSfvc6Nx)iynvg6F9gM(9wqYDKtmD4ggy3ydVZi63vrbx63Bbj3roX0HByGDJn8oJObvQSNkb9ZRFeSMkd97QOGl9RWReWab3szocNe0VcvbJkN(ZAaiV0gUnVrQ22pXYi)i4eBLIee6N7DwfM1By6xHxjGbcULYCeojObnO)ETfjNkbvQBujOFxffCP)dh3zEnroBy8mH(51pcwtLHguPWLkb9ZRFeSMkd9RqvWOYP)ZR3terPyJVAJUuCcXnETKbGHb0l55HbXnETKbG5aoVEpreLIn(Qn6sXje341sgaggWLd42aKCakyZbASH1gKbCXaYUbClL90VRIcU0pruk24R2OlftdQuTKkb97QOGl9RlIThQC6Nx)iynvgAqd6NeSlICQeuPUrLG(51pcwtLH(DvuWL(v5SBBi5WG(vOkyu50F4cEJKnIXBGRjYzZD2XjXRFeSEayoGSgq4i5CKkI5aje6xHxjyt4i5CqOsDJguPWLkb97QOGl97nNhjN(51pcwtLHg0G(vAcvcQu3Osq)86hbRPYq)kufmQC6pRbqc2froRtUqq)Ukk4s)kximUkk4AefjOFrrcZ6nm9ZecVkMqdQu4sLG(DvuWL(7cxoleEuWL(51pcwtLHguPAjvc6Nx)iynvg6xHQGrLt)A(869ux4YzHWJcUje341sgaggaUdWILbO5ZR3tDHlNfcpk4MiHRWzaYIDaTot63vrbx6VlC5Sq4rbxJsW(syAqLQ1ujOFE9JG1uzOFfQcgvo9N1aoVEp5AeVUOw2GEK80ZEayoGlhqwdGTkVY2M1jVfKCh5ethUHb2n2W7mAawSmafek0W7Bs4bVHXrkF9eIB8Ajdq2bGBMd4c63vrbx631iEDrTSb9i50GkvgOsq)86hbRPYq)DiYSSvcQu3OFxffCPFBiuyqmb(qkMguPYiQe0pV(rWAQm0VcvbJkN(pVEpHGcHjYzZbUmjH4gVwYaWa2b0YbyXYaA7OYpcoHIJbXiOqq)Ukk4s)iOqyIC2CGltObvQSfvc6Nx)iynvg63vrbx6VXr4WAthImA2JC6xHQGrLt)iV0gUnVrY1As6zpamhWLdOxYZddIB8AjdaddqbBoqJnS2GK0CVuvmalwgqwdGeSlICwNqq5pEayoafS5an2WAdssZ9svXaKf7au2Mg3kgInV6bKXd42aUG(v4vc2eosoheQu3ObvQSNkb9ZRFeSMkd9RqvWOYPFKxAd3M3i5Anjv7aKDaTmZbKXda5L2WT5nsUwts6hYJcUdaZbK1aib7IiN1jeu(JhaMdqbBoqJnS2GK0CVuvmazXoaLTPXTIHyZREaz8aUr)Ukk4s)nochwB6qKrZEKtdQuwDQe0pV(rWAQm0VcvbJkN(j2SqychjNdYaKf7aWDayoGSgW517PJW1SPlEie(0ZEayoGlhqwda5L2WT5nsUwtsSvksqgGflda5L2WT5nsUwtsiUXRLmazhq2palwgaYlTHBZBKCTMKQDaYoGlhaUdiJhGccfA49nDeUMnDXdHWNu5osotmDKRIcUUyaxmGSBa4MHbCb97QOGl9FeUMnDXdHWtdQu3YKkb9ZRFeSMkd9RqvWOYPFInleMWrY5GmaSd42aWCaiV0gUnVrY1AsQ2bi7aUCa4oGmEakiuOH330r4A20fpecFsL7i5mX0rUkk46IbCXaYUbGBgOFxffCP)JW1SPlEieEAqL62nQe0pV(rWAQm0VcvbJkN(vWMd0ydRnijn3lvfdqwSd42aKCaNxVNoiORjLMtpB63vrbx6xEoKec8gsGkCyAqL6gUujOFE9JG1uzOFfQcgvo932rLFeC6iCnB6IhcH3qWVQbG5ai2SqychjNds6iCnB6IhcHFaYoGBdaZbWlJKJpfvdBcOPXTYaKDa4s)Ukk4s)4ucrTYneBeZ0Gk1TwsLG(51pcwtLH(vOkyu50FBhv(rWPJW1SPlEieEdb)QgaMdGxgjhFkQg2eqtJBLbi7aWL(DvuWL(pcxZg0JKtdQu3Anvc6Nx)iynvg6xHQGrLt)znasWUiYzDYfIbG5aA7OYpco5nNhj3OGRUIcU0VRIcU0FBFlsonOsDldujOFE9JG1uzOFfQcgvo9N1aib7IiN1jxigaMdqbBoqJnS2GmamGDa3OFxffCPFnID9r4AMqdQu3YiQe0pV(rWAQm0VcvbJkN(ZAaKGDrKZ6KledaZb02rLFeCYBopsUrbxDffCPFxffCPFsURH3ByHMguPULTOsq)86hbRPYq)kufmQC6pRbqc2froRtUqq)Ukk4s)e2MueAqL6w2tLG(51pcwtLH(vOkyu50)517PJac1Ihjsi2vXaSyzaNxVNCnIxxulBqpsE6zt)Ukk4s)2WOGlnOsDZQtLG(DvuWL(pciuB6peE6Nx)iynvgAqLc3mPsq)Ukk4s)hgryeo1kN(51pcwtLHguPW9gvc63vrbx6Vxi(iGqn9ZRFeSMkdnOsHlUujOFxffCPFFvmjqUWOCHG(51pcwtLHguPWTLujOFE9JG1uzOFxffCPFfELagi4wkZr4KG(vOkyu50FwdGeSlICwNCHyayoGZR3tUgXRlQLnOhjpPH33bG5aoVEp1WnqeEdSBepvPnAe7nKKgEFhaMdGxgjhFkQg2eqtJBLbi7aA9aWCaO4yoVENmammGmq)CVZQWSEdt)k8kbmqWTuMJWjbnOsHBRPsq)86hbRPYq)Ukk4s)Eli5oYjMoCddSBSH3ze9RqvWOYP)SgW517jxJ41f1Yg0JKNE2daZbK1aoVEpDeUMnDXdHWNE2daZbOGqHgEFtUgXRlQLnOhjpH4gVwYaWWaULb6F9gM(9wqYDKtmD4ggy3ydVZiAqLc3mqLG(51pcwtLH(DvuWL(DsEBFzIb5TaImkiYf0VcvbJkN(18517jK3ciYOGixy08517jn8(oalwgGMpVEpPGR(PIQnBQfhJMpVEp9ShaMdiCKCos5SlI8KTkgaggqlXDayoGWrY5iLZUiYt2QyaYIDaTmZbyXYaYAaA(869KcU6NkQ2SPwCmA(8690ZEayoGlhGMpVEpH8wargfe5cJMpVEprcxHZaKf7aWnZbKXd4wMdi7gGMpVEpDeqO2a7MiNn8Yn4tp7byXYa6L88WG4gVwYaWWaYOmhWfdaZbCE9EY1iEDrTSb9i5je341sgGSd4w2t)R3W0VtYB7ltmiVfqKrbrUGguPWnJOsq)86hbRPYq)kufmQC6)8690raHAXJeje7QyawSmGEjppmiUXRLmamGDa4M5aSyzakyZbASH1gKKM7LQIbGbSdax63vrbx6)rytfCdHg0G(pVsOPsqL6gvc63vrbx6Nv5WALBqSnQA8vt)86hbRPYqdQu4sLG(51pcwtLH(DvuWL(jmc5bRnh4YgIDHdt)kufmQC6pRbOHrIWiKhS2CGlBi2foCkkfo1kFawSmaxfvB2Wl3umzayhWTbG5aqEPnCBEJKR1KuTdq2b0FcHbXQChjNnr1WdWILbOYDKCMmazhaUdaZb0l55HbXnETKbGHbKb6xHxjyt4i5CqOsDJguPAjvc6Nx)iynvg6xHQGrLt)xoGWf8gjRYRu4y0i)EIx)iy9aSyzaElyufCchMTn4HpK5EfeJFGVWGh(siFXzayya4oGlgaMd4869e02gII3wb(0ZEayoGlhW517jCy22Gh(qM7vqm(b(cdE4lrcxHZaWWaU16byXYa4LrYXpammGwNHbCb97QOGl9BxKakmKCyqdQuTMkb9ZRFeSMkd9RqvWOYP)ZR3tqBBikEBf4tp7bG5aUCaNxVN0SRj5Wi9ShGfld4869KCeZlbNAjM7Lchgrsp7byXYaoVEpPGRIDbRnhXB1m68iK0ZEaxq)Ukk4s)2fjGcdjhg0GkvgOsq)Ukk4s)KAlsWidjqfom9ZRFeSMkdnObnObnOua]] )

end