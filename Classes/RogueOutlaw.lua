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


    spec:RegisterPack( "Outlaw", 20201011, [[d8KAcbqirjpskL2euYNefHmkvkoLuQwLOu1RGQAwef3IssTlr(fLudtu4yQKwguQNbvKPbvW1ef12efPVbvigNOuCorPuRdQqX8uP09GI9ru6GIsflKi1dPKKMOOuPlcvuSrOcPrkkc4KqfvwPuYlffr1mffb6MIIG2jrYpfLsgkurPJcvOulfQq1tvvtfQYvHkQARIIO8vrrKZcvOK9I0FPyWGomvlwfpMKjtQlJAZs1NjQgTO60swTOiuVgQ0SjCBPy3k9BGHtPooLKy5iEoKPlCDvz7QeFxLQXtjX5jI1lLI5tj2VIPxP4r)ApyQuyNb2zCnJRxtyNboLnyNz6pKyZ0VTRW1LZ0)6nm9NTEHWVt)2UebW1u8OFe4rum9NhHnchJ1wlVI83jPanwJQMNWJcSkI3dRrvJYA6)8krGZT0d9R9GPsHDgyNX1mUEL(r2SIkf2zAg0FEP18sp0VMrk6VTdmB9cHFFG44a5pEA12bMTub4WKbE9Qmde7mWod63Ma6LGP)2oWS1le(9bIJdK)4PvBhy2sfGdtg41RYmqSZa7mMwtR2oqCgRWQxW6bE4oGWdubAoEmWdlVwuAGzhLITd0axWA15oPP)ed0vrbw0abRqsAA5QOalkztyfO54bg32wiXydkeyNwUkkWIs2ewbAoEGpgR7chH70YvrbwuYMWkqZXd8XyT)K3WB4rb2PLRIcSOKnHvGMJh4JX6oaONwTDG)1Tr5GyGeV0d886Dwpqu4bAGhUdi8avGMJhd8WYRfnqF1d0MWwTniIALpWcnqny500YvrbwuYMWkqZXd8XynADBuoimOWd00YvrbwuYMWkqZXd8XyTnikWoTCvuGfLSjSc0C8aFmw34eCzTPdign7rUm2ewbAoEyqScSAeMmlt1Xq8sB4l8gjxRrPALfhYyA5QOalkztyfO54b(ySgfSlICzQoMBYITkVY2M1jBGcxoqvByTrbASFHhfynA(sPylwYsbacn4(MusucqqaBPmhHJIK(r8OaRfleV0g(cVrQ2lpXYe)i4eBLcfO2NwUkkWIs2ewbAoEGpgRjaHWe5S5awgjJnHvGMJhgeRaRgHbBzQogc3jmk3pcEA5QOalkztyfO54b(ySgjkfB8vB0LILXMWkqZXddIvGvJWGTmvhdH7egL7hbpTCvuGfLSjSc0C8aFmw7AcVUOw2qEOCzSjSc0C8WGyfy1imxLP6yUjl2Q8kBBwNSbkC5avTH1gfOX(fEuG1O5lLITyjlfai0G7BsjrjabbSLYCeoks6hXJcSwSq8sB4l8gPAV8elt8JGtSvkuGAFA5QOalkztyfO54b(yS(HytfCJmR3Wy82GYDIJmDWggq3ydUZKPLRIcSOKnHvGMJh4JX6hInvWnYW9oRcZ6nmgLeLaeeWwkZr4OqMQJjlIxAdFH3iv7LNyzIFeCITsHc00AA12bIZyfw9cwpq(ctKmWOA4bg58aDvaidSqd0V4LWpconTCvuGfHb3sH70QTdehNrb7IiFGvFG2aeQocEG3SGbE5jwM4hbpqE5MIrdS2bQanhpAFA5QOalcFmwJc2fr(0QTd0Q(ieEdHKbUGyG3bKiFGeMaeIALpWAh4ptWbw7a9vYaXDb33bIQ45rb2PLRIcSi8Xy9fNu(rWYSEdJHehdHjaHqMlU4XyYyA5QOalcFmwFXjLFeSmR3Wy8MZdLBuGvxrbwzU4IhJrbAoaJnO2aL0CVuvilgSXh7S)MWf8gj55auiKyqbPWLt86hbRXsbacn4(MKNdqHqIbfKcxor4gVw0TxBh)ZR3thcW1OsZPNnw8Ye5sKntZaRSoVEpHW9jegF1gfbGqhWYO0ZgRSoVEpHlZ2gjGhXCVcKXpGxyKaEPN90QTdmtQI8b28erzl4bgorohizgyKxObEXjLFe8al0av5ScxwpWamqnRknpW75CKZKbIan8aTQzx0ar5GNqpWdpqKKvX6bEVI8bkTW18aXrfpcrY0Yvrbwe(yS(Itk)iyzwVHXCeUMnDXJqKyqswLmxCXJXGSzHWeorohO0r4A20fpcrYTyJfXlTHVWBKCTgLQvwSZWILZR3thHRztx8iejPN90Yvrbwe(ySw5cHXvrbwJOqHmR3Wyqb7IixMQJbfSlICwNCHyA5QOalcFmwRCHW4QOaRruOqM1BymknAA12bIJwBHYhOhdSXTs18AgOvfNnnW)7GcIRIbcwEGDazGSRYhO0eGRrLMhOV6bMTSTbK4TvizG3Z5DG4y)kfUdm7s87dSqdeXcwfSEG(QhyMWE2DGfAGligiHDTKb69GjdmY5bUSvIbIyfy1PbMDe3DjOb24wzGsh4md8Ef5deB8hy2rXPPLRIcSi8Xyn5TgxffynIcfYSEdJPxBHYLP6yuGMdWydQnqYIrzBACRyq28QT6BoVEpDiaxJknNE24FE9EcyBdiXBRqs6z3E2Ft4cEJKv5vkCnAIFpXRFeSgRBYkCbVrQXj4YAthqmA2J8eV(rWAlwuaGqdUVPgNGlRnDaXOzpYteUXRfj712Bp7VXBdtQGtUInpBJeWJyqcMVWjIV4El2wSKLcaeAW9nD44oZRjYzdlHrPND7wSOanhGXguBGW4B14QCNiN1gL90Yvrbwe(ySw5cHXvrbwJOqHmR3WyoVsONwUkkWIWhJ1or5lBcaHWBit1XWltKljP5EPQqwmxZm(8Ye5ssewoVtlxffyr4JXANO8Ln2pbINwUkkWIWhJ1IsEEGmzIFA5n8gtlxffyr4JX6Jl3a6MGukCrtRPvBhO0VsOzcAA5QOalkDELqJHv5GALBiSnPA8vpTCvuGfLoVsOXhJ1iMq8G1MdyzdYUWLLrjrjyt4e5CGWCvMQJjlnisiMq8G1MdyzdYUWLtrPWTw5wS4QOUWgE5MIryUIfXlTHVWBKCTgLQv2(timewL7e5SjQg2IfvUtKZizXgREjppmeUXRfDBMNwTDG48iEG4SfkaIb(ZbXaR(aRyG3bBMOyGk3EGkqZbmqBqTbAG(QhyKZdmBzBdiXBRqYapVEFGfAGp70aZoxaLEGpuTYh49CEhyMCMThiowGhzGzsvGgikCfUOb6eEG5L88bcid8EoVd8HQv(aZKy3gSnokyImd8TcgHgyKZdm7YUgLdIbEE9(al0aF2PPLRIcSO05vcn(yS2Uqbqyq5GqMQJ5MWf8gjRYRu4A0e)EIx)iyTflEBysfCcxMTnsapI5EfiJFaVWib8seFX9wSBhRZR3taBBajEBfsspBSU5869eUmBBKaEeZ9kqg)aEHrc4LqHRW92R4Gfl8Ye5sUfhYC7tlxffyrPZReA8XyTDHcGWGYbHmvhZ517jGTnGeVTcjPNnw3CE9EsZUgLdI0Z2ILZR3tYjmViCRfzUxkCzck9STy5869KcSk2fS2CeVvZKZdHsp72NwUkkWIsNxj04JXAuTfkyIbfKcxEAnTA7aTQaGqdUVOPLRIcSOKsJWOCHW4QOaRruOqM1BymmcXRIrYuDmzHc2froRtUqmTCvuGfLuAe(ySUlC5Sq4rb2PLRIcSOKsJWhJ1DHlNfcpkWAuc2xelt1XO5ZR3tDHlNfcpkWMiCJxl6wSTyrZNxVN6cxoleEuGnHcxHRSyWHmMwUkkWIskncFmw7AcVUOw2qEOCzQoMSoVEp5AcVUOw2qEO80ZgRBYITkVY2M1jVnOCN4ithSHb0n2G7mXIffai0G7Bs4bVHXjkF9eHB8ArYIDgTpTCvuGfLuAe(yS2gaegcJapIILPdiMLTsG560YvrbwusPr4JXAcqimroBoGLrYuDmNxVNiaHWe5S5awgLiCJxl6wm4KflxCs5hbNiXXqycqiMwTDG4C9b6AnAGoHh4ZwMbI2YMhyKZdeS8aVxr(afG7mkgiE4LDtdeNhXd8EoVdulPw5dS7OGjdmY9DGwvC2bQ5EPQyGaYaVxro4fd0xjd0QIZMMwUkkWIskncFmw34eCzTPdign7rUmkjkbBcNiNdeMRYuDmeV0g(cVrY1Au6zJ1n9sEEyiCJxl6wfO5am2GAdusZ9svHflzHc2froRteG8hJLc0CagBqTbkP5EPQqwmkBtJBfdYMxTvFT9PvBhioxFGlyGUwJg49sigOU4bEVI8AhyKZdCzRedeNYajZaFiEGzc7z3bc2bEai0aVxro4fd0xjd0QIZMMwUkkWIskncFmw34eCzTPdign7rUmvhdXlTHVWBKCTgLQvwCkdRM4L2Wx4nsUwJs6hXJcSyLfkyxe5SoraYFmwkqZbySb1gOKM7LQczXOSnnUvmiBE1w91PvBhO0cxZdehv8iejdeSdeB8hiVCtXO0aZKQiFGUwJWXmqCEepWQpWiNLmqu4sgyhqgy2G)arScSA0abKbw9bkb8idCzReduL7e58aVxcXap8ajSRLmWAhyun8a7aYaJCEGlBLyG39lCAA5QOalkP0i8Xy9r4A20fpcrImvhdYMfct4e5CGKfd2yL1517PJW1SPlEeIK0ZgRBYI4L2Wx4nsUwJsSvkuGSyH4L2Wx4nsUwJseUXRfjB2yXcXlTHVWBKCTgLQv2BW2QvaGqdUVPJW1SPlEeIKKk3jYzKPtCvuG1fTN9yN52NwTDGslCnpqCuXJqKmqWoWR4nWQpqjGhzGlBLyGQCNiNh49sig4HhiHDTKbw7aJQHhyhqgyKZdCzRed8UFHttlxffyrjLgHpgRpcxZMU4risKP6yq2SqycNiNdeMRyr8sB4l8gjxRrPAL9gSTAfai0G7B6iCnB6IhHijPYDICgz6exffyDr7zp2zEA5QOalkP0i8XyT8CakesmOGu4YYuDmkqZbySb1gOKM7LQczXCf)ZR3thcW1OsZPN90YvrbwusPr4JXAClHOw5gKnHzzQoMloP8JGthHRztx8iejgKKvHfYMfct4e5CGshHRztx8iejYEflEzICjPOAytamnUvKf7PLRIcSOKsJWhJ1hHRzd5HYLP6yU4KYpcoDeUMnDXJqKyqswfw8Ye5ssr1WMayACRil2tR2oqCEuTYhyMmFluU1zNMZdLpWcnqWkKmqFGxyIKbg1kzG1QiSJyzgicmWAhiHDrfsKzGsaVmreEG(bbeVGfsgyVwEGbyGpepWkgOJgOpWxuIkKmqKnlePPLRIcSOKsJWhJ1x8Tq5YuDmzHc2froRtUqG1fNu(rWjV58q5gfy1vuGDA5QOalkP0i8XyTMWU(iCnJKP6yYcfSlICwNCHalfO5am2GAd0TyUoTCvuGfLuAe(ySgL7AW9gwOLP6yYcfSlICwNCHaRloP8JGtEZ5HYnkWQROa70YvrbwusPr4JXAeBJkKmvhtwOGDrKZ6KletlxffyrjLgHpgRTbrbwzQoMZR3thbaOfpuKiSRclwoVEp5AcVUOw2qEO80ZEA5QOalkP0i8Xy9raaAt)rKmTCvuGfLuAe(yS(WeetWTw5tlxffyrjLgHpgR7fHpcaqpTCvuGfLuAe(yS2xfJcIlmkxiMwUkkWIskncFmw)qSPcUrgU3zvywVHXOKOeGGa2szochfYuDmzHc2froRtUqG1517jxt41f1YgYdLN0G7lwNxVNA4garIb0nINQ0gnH9gusdUVyXltKljfvdBcGPXTIS4awK4yoVEhDBMNwUkkWIskncFmw)qSPcUrM1BymEBq5oXrMoyddOBSb3zImvhtwNxVNCnHxxulBipuE6zJvwNxVNocxZMU4risspBSuaGqdUVjxt41f1YgYdLNiCJxl62RzEA12bMjJjsgib8KNlKmqYtWde0hyK)AovVy9aB8ihnWdla3XXmqCEepWoGmqCUfxBGEGksfYmqqKZK7fIh49kYhy2bhFGEmqSZa)bIcxHlAGaYaVMb(d8Ef5d0fiWaLwaa6b(SttlxffyrjLgHpgRFi2ub3iZ6nmghLFXxgziEBaeJcqCHmvhJMpVEpr82aigfG4cJMpVEpPb3xlw08517jfy1pvuxytT4A08517PNnwHtKZrkNDrKNSvXT4e2yforohPC2frEYwfYIbNYWILS08517jfy1pvuxytT4A08517PNnw3O5ZR3teVnaIrbiUWO5ZR3tOWv4klgSZWQVMr2R5ZR3thbaOnGUjYzdVCJK0Z2ILEjppmeUXRfDBMMr7yDE9EY1eEDrTSH8q5jc341IK9A2mTA7aZUC3FIyGDxioUc3b2bKb(q(rWdScUbLMwUkkWIskncFmw)qSPcUbjt1XCE9E6iaaT4HIeHDvyXsVKNhgc341IUfd2zyXIc0CagBqTbkP5EPQ4wmypTMwTDG4mieVkgnTCvuGfLyeIxfJWOaRI3G4bRnDH3WYuDm8Ye5ssr1WMayACRi7vSY68690r4A20fpcrs6zJ1nzPbrsbwfVbXdwB6cVHnNhztrPWTw5yLLRIcSjfyv8gepyTPl8govRPlk55Hfl9NqyiSk3jYztun8TYv6uJBL2NwUkkWIsmcXRIr4JX6Jaa0gq3e5SHxUrImvhZfNu(rWPJW1SPlEeIedsYQWsbacn4(MoCCN51e5SHLWO0ZgRBq2SqycNiNdu6iCnB6IhHirwmyBXcXlTHVWBKCTgLQvwCiZTpTCvuGfLyeIxfJWhJ1YForx(AaDJ3gMaI8PLRIcSOeJq8Qye(ySUdupeRnEBysfS5WEJmvhdYMfct4e5CGshHRztx8iejYIbBlwiEPn8fEJKR1OuTYMPzGvwNxVNCnHxxulBipuE6zpTCvuGfLyeIxfJWhJ12ps1LuRCZr4OqMQJbzZcHjCICoqPJW1SPlEeIezXGTfleV0g(cVrY1AuQwzZ0mMwUkkWIsmcXRIr4JX6iNnV9aER20beflt1XCE9EIWkCfmcz6aIItpBlwoVEpryfUcgHmDarXgf4TbtsOWv4E71mMwUkkWIsmcXRIr4JXAszBlytTgKTR4PLRIcSOeJq8Qye(yS(oGi0x4AnegbwFv80YvrbwuIriEvmcFmw3WnaIedOBepvPnAc7nizQogEzICj3IdzEA12bMjaqOhioo721kFG4OcVHrdSdidKTcREbpqIVY5bcide3sig4517izgy1hOnaHQJGtdm7iU7sqdmisgyagOCogyKZduaUZOyGkaqOb33bECeRhiyhOFXlHFe8a5LBkgLMwUkkWIsmcXRIr4JXAc721k30fEdJKrjrjyt4e5CGWCvMQJjCICosr1WMay0fF71uMTy5MBcNiNJuo7IipzRczZMmSyjCICos5SlI8KTkUfd2z0ow34QOUWgE5MIryUAXYfNu(rWjc721k3OzHlrwSZ2T3Ufl3eorohPOAytam2QWGDgYItzG1nUkQlSHxUPyeMRwSCXjLFeCIWUDTYnAw4sKfhWH2BFAnTA7aXrRTq5mbnTA7aLoWzgiyhOcaeAW9DGbyG4YS9aJCEGwvsfduZNxVpWN90YvrbwuQxBHYXC44oZRjYzdlHrtlxffyrPETfkhFmwJeLIn(Qn6sXYuDmNxVNqIsXgF1gDP4eHB8Ar32l55HHWnETiSoVEpHeLIn(Qn6sXjc341IU9MR4RanhGXguBGAp7VMYMPLRIcSOuV2cLJpgR1fY2dv(0AA12b(d2fr(0YvrbwucfSlICmQC2TnOCqiJsIsWMWjY5aH5Qmvht4cEJKnHLyaRjYzZD2XnXRFeSgRScNiNJuHmhacnTCvuGfLqb7IihFmw7nNhkN(VWeubwQuyNb2zCnJRxP)7ozRvoI(X5ASbKG1dehzGUkkWoqrHcuAAr)(lYbe6)xnwv6xuOarXJ(zeIxfJO4rL6kfp6Nx)iynvA6xrQGjLt)8Ye5ssr1WMayACRmqzh41bI1aZAGNxVNocxZMU4rissp7bI1aVzGznqniskWQ4niEWAtx4nS58iBkkfU1kFGynWSgORIcSjfyv8gepyTPl8govRPlk55XaTyzG9NqyiSk3jYztun8aVDGYv6uJBLb2o97QOal9RaRI3G4bRnDH3W0Gkf2u8OFE9JG1uPPFfPcMuo9FXjLFeC6iCnB6IhHiXGKSQbI1avaGqdUVPdh3zEnroByjmk9Shiwd8MbISzHWeorohO0r4A20fpcrYaLfZaXEGwSmqIxAdFH3i5Ankv7aLDG4qMhy70VRIcS0)raaAdOBIC2Wl3iHguPWjkE0VRIcS0V8Nt0LVgq34THjGiN(51pcwtLMguPWbkE0pV(rWAQ00VIubtkN(r2SqycNiNdu6iCnB6IhHizGYIzGypqlwgiXlTHVWBKCTgLQDGYoWmnJbI1aZAGNxVNCnHxxulBipuE6zt)UkkWs)DG6HyTXBdtQGnh2BObvQmtXJ(51pcwtLM(vKkys50pYMfct4e5CGshHRztx8iejduwmde7bAXYajEPn8fEJKR1OuTdu2bMPzq)UkkWs)2ps1LuRCZr4OGguPYukE0pV(rWAQ00VIubtkN(pVEpryfUcgHmDarXPN9aTyzGNxVNiScxbJqMoGOyJc82Gjju4kCh4Td8Ag0VRIcS0FKZM3EaVvB6aIIPbvkCekE0VRIcS0pPSTfSPwdY2vm9ZRFeSMknnOsLnu8OFxffyP)7aIqFHR1qyey9vX0pV(rWAQ00Gkv2MIh9ZRFeSMkn9RivWKYPFEzICjd82bIdzM(DvuGL(B4garIb0nINQ0gnH9genOsDndkE0pV(rWAQ00VRIcS0pHD7ALB6cVHr0VIubtkN(dNiNJuunSjagDXd82bEnL5bAXYaVzG3mWWjY5iLZUiYt2QyGYoWSjJbAXYadNiNJuo7IipzRIbElMbIDgdS9bI1aVzGUkQlSHxUPy0aXmWRd0ILbEXjLFeCIWUDTYnAw4sgOSde7S9aBFGTpqlwg4ndmCICosr1WMaySvHb7mgOSdeNYyGynWBgORI6cB4LBkgnqmd86aTyzGxCs5hbNiSBxRCJMfUKbk7aXbCyGTpW2PFLeLGnHtKZbIk1vAqd6xZD)jckEuPUsXJ(DvuGL(XTu4s)86hbRPstdQuytXJ(DvuGL(rb7IiN(51pcwtLMguPWjkE0pV(rWAQ00pWM(rCq)UkkWs)xCs5hbt)xCXJP)mO)loXSEdt)K4yimbie0GkfoqXJ(51pcwtLM(b20pId63vrbw6)Itk)iy6)IlEm9RanhGXguBGsAUxQkgOSygi2de)bI9aZ(bEZadxWBKKNdqHqIbfKcxoXRFeSEGynqfai0G7BsEoafcjguqkC5eHB8Ard82bEDGTpq8h4517Pdb4AuP50ZEGynqEzICjdu2bMPzmqSgywd8869ec3Nqy8vBueacDalJsp7bI1aZAGNxVNWLzBJeWJyUxbY4hWlmsaV0ZM(V4eZ6nm97nNhk3OaRUIcS0GkvMP4r)86hbRPst)aB6hXb97QOal9FXjLFem9FXfpM(r2SqycNiNdu6iCnB6IhHizG3oqShiwdK4L2Wx4nsUwJs1oqzhi2zmqlwg4517PJW1SPlEeIK0ZM(V4eZ6nm9FeUMnDXJqKyqswfnOsLPu8OFE9JG1uPPFfPcMuo9Jc2froRtUqq)UkkWs)kximUkkWAefkOFrHcZ6nm9Jc2fronOsHJqXJ(51pcwtLM(DvuGL(vUqyCvuG1ikuq)IcfM1By6xPr0Gkv2qXJ(51pcwtLM(vKkys50Vc0CagBqTbAGYIzGkBtJBfdYMx9aT6bEZapVEpDiaxJknNE2de)bEE9EcyBdiXBRqs6zpW2hy2pWBgy4cEJKv5vkCnAIFpXRFeSEGynWBgywdmCbVrQXj4YAthqmA2J8eV(rW6bAXYavaGqdUVPgNGlRnDaXOzpYteUXRfnqzh41b2(aBFGz)aVzGEBysfCYvS5zBKaEedsW8for8f3bE7aXEGwSmWSgOcaeAW9nD44oZRjYzdlHrPN9aBFGwSmqfO5am2GAd0aXmqFRgxL7e5S2OSPFxffyPFYBnUkkWAefkOFrHcZ6nm93RTq50Gkv2MIh9ZRFeSMkn97QOal9RCHW4QOaRruOG(ffkmR3W0)5vcnnOsDndkE0pV(rWAQ00VIubtkN(5LjYLK0CVuvmqzXmWRzEG4pqEzICjjclNx63vrbw63jkFztaieEdAqL66vkE0VRIcS0Vtu(Yg7NaX0pV(rWAQ00Gk1vSP4r)UkkWs)IsEEGmzIFA5n8g0pV(rWAQ00Gk1vCIIh97QOal9FC5gq3eKsHlI(51pcwtLMg0G(TjSc0C8GIhvQRu8OFxffyPF32wiXydkeyPFE9JG1uPPbvkSP4r)86hbRPstdQu4efp6Nx)iynvAAqLchO4r)86hbRPstdQuzMIh9ZRFeSMknnOsLPu8OFxffyPFBquGL(51pcwtLMguPWrO4r)86hbRPst)UkkWs)nobxwB6aIrZEKt)ksfmPC6N4L2Wx4nsUwJs1oqzhioKb9BtyfO54HbXkWQr0FMPbvQSHIh9ZRFeSMkn9RivWKYP)BgywdKTkVY2M1jBGcxoqvByTrbASFHhfynA(sP4bAXYaZAGkaqOb33KsIsaccylL5iCuK0pIhfyhOfldK4L2Wx4ns1E5jwM4hbNyRuOanW2PFxffyPFuWUiYPbvQSnfp6Nx)iynvA63vrbw6NaectKZMdyze9RivWKYPFc3jmk3pcM(TjSc0C8WGyfy1i6hBAqL6Agu8OFE9JG1uPPFxffyPFKOuSXxTrxkM(vKkys50pH7egL7hbt)2ewbAoEyqScSAe9JnnOsD9kfp6Nx)iynvA63vrbw631eEDrTSH8q50VIubtkN(VzGznq2Q8kBBwNSbkC5avTH1gfOX(fEuG1O5lLIhOfldmRbQaaHgCFtkjkbiiGTuMJWrrs)iEuGDGwSmqIxAdFH3iv7LNyzIFeCITsHc0aBN(TjSc0C8WGyfy1i6)knOsDfBkE0pV(rWAQ00)6nm97TbL7ehz6GnmGUXgCNj0VRIcS0V3guUtCKPd2Wa6gBWDMqdQuxXjkE0pV(rWAQ00VRIcS0VsIsaccylL5iCuq)ksfmPC6pRbs8sB4l8gPAV8elt8JGtSvkuGOFU3zvywVHPFLeLaeeWwkZr4OGg0G(71wOCkEuPUsXJ(DvuGL(pCCN51e5SHLWi6Nx)iynvAAqLcBkE0pV(rWAQ00VIubtkN(pVEpHeLIn(Qn6sXjc341Ig4TdSxYZddHB8ArdeRbEE9EcjkfB8vB0LIteUXRfnWBh4nd86aXFGkqZbySb1gOb2(aZ(bEnLn0VRIcS0psuk24R2OlftdQu4efp63vrbw6xxiBpu50pV(rWAQ00Gg0pkyxe5u8OsDLIh9ZRFeSMkn97QOal9RYz32GYbb9RivWKYP)Wf8gjBclXawtKZM7SJBIx)iy9aXAGznWWjY5iviZbGq0VsIsWMWjY5arL6knOsHnfp63vrbw63Bopuo9ZRFeSMknnOb9R0ikEuPUsXJ(51pcwtLM(vKkys50FwdefSlICwNCHG(DvuGL(vUqyCvuG1ikuq)IcfM1By6NriEvmIguPWMIh97QOal93fUCwi8Oal9ZRFeSMknnOsHtu8OFE9JG1uPPFfPcMuo9R5ZR3tDHlNfcpkWMiCJxlAG3oqShOflduZNxVN6cxoleEuGnHcxH7aLfZaXHmOFxffyP)UWLZcHhfynkb7lIPbvkCGIh9ZRFeSMkn9RivWKYP)Sg4517jxt41f1YgYdLNE2deRbEZaZAGSv5v22So5TbL7ehz6GnmGUXgCNjd0ILbQaaHgCFtcp4nmor5RNiCJxlAGYoqSZyGTt)UkkWs)UMWRlQLnKhkNguPYmfp6Nx)iynvA6VdiMLTsqL6k97QOal9BdacdHrGhrX0GkvMsXJ(51pcwtLM(vKkys50)517jcqimroBoGLrjc341Ig4Tygionqlwg4fNu(rWjsCmeMaec63vrbw6NaectKZMdyzenOsHJqXJ(51pcwtLM(DvuGL(BCcUS20beJM9iN(vKkys50pXlTHVWBKCTgLE2deRbEZa7L88Wq4gVw0aVDGkqZbySb1gOKM7LQIbAXYaZAGOGDrKZ6ebi)XdeRbQanhGXguBGsAUxQkgOSygOY204wXGS5vpqREGxhy70VsIsWMWjY5arL6knOsLnu8OFE9JG1uPPFfPcMuo9t8sB4l8gjxRrPAhOSdeNYyGw9ajEPn8fEJKR1OK(r8Oa7aXAGznquWUiYzDIaK)4bI1avGMdWydQnqjn3lvfduwmduzBACRyq28QhOvpWR0VRIcS0FJtWL1MoGy0Sh50Gkv2MIh9ZRFeSMkn9RivWKYPFKnleMWjY5anqzXmqShiwdmRbEE9E6iCnB6IhHij9Shiwd8MbM1ajEPn8fEJKR1OeBLcfObAXYajEPn8fEJKR1OeHB8Ardu2bMnd0ILbs8sB4l8gjxRrPAhOSd8MbI9aT6bQaaHgCFthHRztx8iejjvUtKZitN4QOaRlgy7dm7hi2zEGTt)UkkWs)hHRztx8iej0Gk11mO4r)86hbRPst)ksfmPC6hzZcHjCICoqdeZaVoqSgiXlTHVWBKCTgLQDGYoWBgi2d0QhOcaeAW9nDeUMnDXJqKKu5oroJmDIRIcSUyGTpWSFGyNz63vrbw6)iCnB6IhHiHguPUELIh9ZRFeSMkn9RivWKYPFfO5am2GAdusZ9svXaLfZaVoq8h4517Pdb4AuP50ZM(DvuGL(LNdqHqIbfKcxMguPUInfp6Nx)iynvA6xrQGjLt)xCs5hbNocxZMU4rismijRAGynqKnleMWjY5aLocxZMU4risgOSd86aXAG8Ye5ssr1WMayACRmqzhi20VRIcS0pULquRCdYMWmnOsDfNO4r)86hbRPst)ksfmPC6)Itk)i40r4A20fpcrIbjzvdeRbYltKljfvdBcGPXTYaLDGyt)UkkWs)hHRzd5HYPbvQR4afp6Nx)iynvA6xrQGjLt)znquWUiYzDYfIbI1aV4KYpco5nNhk3OaRUIcS0VRIcS0)fFluonOsDnZu8OFE9JG1uPPFfPcMuo9N1arb7IiN1jxigiwdubAoaJnO2anWBXmWR0VRIcS0VMWU(iCnJObvQRzkfp6Nx)iynvA6xrQGjLt)znquWUiYzDYfIbI1aV4KYpco5nNhk3OaRUIcS0VRIcS0pk31G7nSqtdQuxXrO4r)86hbRPst)ksfmPC6pRbIc2froRtUqq)UkkWs)i2gviAqL6A2qXJ(51pcwtLM(vKkys50)517PJaa0Ihkse2vXaTyzGNxVNCnHxxulBipuE6zt)UkkWs)2GOalnOsDnBtXJ(DvuGL(pcaqB6pIe6Nx)iynvAAqLc7mO4r)UkkWs)hMGycU1kN(51pcwtLMguPW(kfp63vrbw6Vxe(iaan9ZRFeSMknnOsHn2u8OFxffyPFFvmkiUWOCHG(51pcwtLMguPWgNO4r)86hbRPst)UkkWs)kjkbiiGTuMJWrb9RivWKYP)Sgikyxe5So5cXaXAGNxVNCnHxxulBipuEsdUVdeRbEE9EQHBaejgq3iEQsB0e2Bqjn4(oqSgiVmrUKuunSjaMg3kdu2bIddeRbsIJ586D0aVDGzM(5ENvHz9gM(vsucqqaBPmhHJcAqLcBCGIh9ZRFeSMkn9RivWKYP)Sg4517jxt41f1YgYdLNE2deRbM1apVEpDeUMnDXJqKKE2deRbQaaHgCFtUMWRlQLnKhkpr4gVw0aVDGxZm9VEdt)EBq5oXrMoyddOBSb3zc97QOal97TbL7ehz6GnmGUXgCNj0Gkf2zMIh9ZRFeSMkn9RivWKYPFnFE9EI4TbqmkaXfgnFE9EsdUVd0ILbQ5ZR3tkWQFQOUWMAX1O5ZR3tp7bI1adNiNJuo7IipzRIbE7aXjShiwdmCICos5SlI8KTkgOSygioLXaTyzGznqnFE9Esbw9tf1f2ulUgnFE9E6zpqSg4nduZNxVNiEBaeJcqCHrZNxVNqHRWDGYIzGyNXaT6bEnJbM9duZNxVNocaqBaDtKZgE5gjPN9aTyzG9sEEyiCJxlAG3oWmnJb2(aXAGNxVNCnHxxulBipuEIWnETObk7aVMn0)6nm97O8l(YidXBdGyuaIlOFxffyPFhLFXxgziEBaeJcqCbnOsHDMsXJ(51pcwtLM(vKkys50)517PJaa0Ihkse2vXaTyzG9sEEyiCJxlAG3IzGyNXaTyzGkqZbySb1gOKM7LQIbElMbIn97QOal9)qSPcUbrdAq)Nxj0u8OsDLIh97QOal9ZQCqTYne2Mun(QPFE9JG1uPPbvkSP4r)86hbRPst)UkkWs)iMq8G1MdyzdYUWLPFfPcMuo9N1a1GiHycXdwBoGLni7cxofLc3ALpqlwgORI6cB4LBkgnqmd86aXAGeV0g(cVrY1AuQ2bk7a7pHWqyvUtKZMOA4bAXYav5oroJgOSde7bI1a7L88Wq4gVw0aVDGzM(vsuc2eorohiQuxPbvkCIIh9ZRFeSMkn9RivWKYP)Bgy4cEJKv5vkCnAIFpXRFeSEGwSmqVnmPcoHlZ2gjGhXCVcKXpGxyKaEjIV4oWBhi2dS9bI1apVEpbSTbK4Tvij9Shiwd8MbEE9EcxMTnsapI5EfiJFaVWib8sOWv4oWBh4vCyGwSmqEzICjd82bIdzEGTt)UkkWs)2fkacdkhe0GkfoqXJ(51pcwtLM(vKkys50)517jGTnGeVTcjPN9aXAG3mWZR3tA21OCqKE2d0ILbEE9EsoH5fHBTiZ9sHltqPN9aTyzGNxVNuGvXUG1MJ4TAMCEiu6zpW2PFxffyPF7cfaHbLdcAqLkZu8OFxffyPFuTfkyIbfKcxM(51pcwtLMg0Gg0Gguk]] )

end