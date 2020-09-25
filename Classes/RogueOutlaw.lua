-- RogueOutlaw.lua
-- June 2018
-- Contributed by Alkena.

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR


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

            spend = function () return talent.dirty_tricks.enabled and 0 or 40 end,
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

            spend = 20,
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

            spend = 30,
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

            spend = 35,
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
            cooldown = function () return 60 - ( talent.retractable_hook.enabled and 30 or 0 ) end,
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
            end,
        },


        kidney_shot = {
            id = 408,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = 25,
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

            spend = function () return 35 - ( talent.dirty_tricks.enabled and 35 or 0 ) end,
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


    spec:RegisterPack( "Outlaw", 20200924, [[d80ccbqirjpskv2euXNikP0Ouj5uQKAvsPWRGQAwef3suq7sKFrjAyIIoguQLPs5zsPQPjkvxtukBtuiFdkjmorbohusADqjrMhuI7bf7Js4GsPilKi1djkjtuuO6IqjvTrPuuJekjQojusLvkL8srHsntIsk6MeLuzNej)ekP0qjkbhfkjklLOe6PQQPcv5QqjfBvuOKVkkuCwIskSxK(lfdg0HPAXs1JjzYK6YO2Sk(mr1OLItlz1eLu1RHknBc3wuTBL(nWWPuhNOeTCephY0fUUQSDvIVRs14jk15jI1lLsZNsA)kMInfp6x7btL6wM3YmtS6TSNWoZBzq7XQ0FiXMPFBxHRlNP)1Zz6hR9fc)o9B7seaxtXJ(rGhrX0Fte2iSswAP8kAE9KcKBjQYFcpkWQi(jSev5klP)(Rebw3s70V2dMk1TmVLzMy1BzpHDM3YG2Nb0pYMvuPULrzs)nLwZlTt)AgPO)2nqS2xi87duwei)XtR2nWpBhCENjd8w2LzG3Y8wM0VnbCkbt)TBGyTVq43hOSiq(JNwTBGF2o48otg4TSlZaVL5TmNwtR2nqSEzZQxW6b25dGWdubY7EmWolVwuAGTjLITd0axWMHnoj)8ed0vrbw0abRqsAA5QOalkztyfiV7bg32wiXydkeyNwUkkWIs2ewbY7EGpglpchH70YvrbwuYMWkqE3d8XyP)KNZB4rb2PLRIcSOKnHvG8Uh4JXYdaONwTBG)1TrnGyGeV0dS)ohwpqu4bAGD(ai8avG8UhdSZYRfnqF1d0MWzOniIALpWcnqny500YvrbwuYMWkqE3d8XyjADBudimOWd00YvrbwuYMWkqE3d8XyPnikWoTCvuGfLSjScK39aFmwM7eCzT5aign7rJm2ewbY7EyqScSAeMSjtDWq8sB4l8gjxRrPATi7zoTCvuGfLSjScK39aFmwIc2frJm1bZvzXYYxzBZ6KnqHlhOQTS2Oa52VWJcSgnFPuSvRzPaaHgCFtkjkbiiGTuMUWrrs)iEuG1QvIxAdFH3iv7LNyzI3fCILDHc01tlxffyrjBcRa5DpWhJLeGqyIg20blJKXMWkqE3ddIvGvJWCtM6GHWhcJA8UGNwUkkWIs2ewbY7EGpglrIsXgF1gDPyzSjScK39WGyfy1im3MwUkkWIs2ewbY7EGpglDnHxxulBipuJm2ewbY7EyqScSAegSLPoyUklww(kBBwNSbkC5avTL1gfi3(fEuG1O5lLITAnlfai0G7BsjrjabbSLY0foks6hXJcSwTs8sB4l8gPAV8elt8UGtSSluGUEA5QOalkztyfiV7b(yS8HytfCUmRNZy82IACIJmhWggWXydUZKPLRIcSOKnHvG8Uh4JXYhInvW5YWNdRcZ65mgLeLaeeWwktx4OqM6GjlIxAdFH3iv7LNyzI3fCILDHc00AA1UbI1lBw9cwpq(ctKmWOY5bgn8aDvaidSqd0V4LW7conTCvuGfHb3sH70QDduwKrb7IOzG1zG2aeQ6cEGxTGbE5jwM4DbpqE58IrdS2bQa5DpUEA5QOalcFmwIc2frZ0QDduw9ieEdHKbUGyG3bKOzGeMaeIALpWAh4xwZbw7a9vYaXDb33bIQ45rb2PLRIcSi8Xy5fNuExWYSEoJHeDdHjaHqMlU4XyYCA5QOalcFmwEXjL3fSmRNZy88(d1yuGvxrbwzU4IhJrbY7aJnO2aL08PuvybMB4FRnUkCbVrsEdafcjguqkC5eVExWACuaGqdUVj5nauiKyqbPWLteo3RfHfSVg)(7CsDcW1OsZPNno8Ye5sSiJYeNS6VZjHW9jegF1gfbGqDWYO0ZgNS6VZjHlZ2gjGhXCVcKX7GxyKaEPN90QDdmJPIMbM)erzl4bgorohizgy0uObEXjL3f8al0avnScxwpWamqnRknpW7nC0WKbIa58aLvzC0arnGNqpWopqKKvX6bEVIMbkTW18aBZIhHizA5QOalcFmwEXjL3fSmRNZy6cxZMJ4rismijRsMlU4Xyq2SqycNiNduQlCnBoIhHibl3WH4L2Wx4nsUwJs1AXTmTAT)oNux4A2Cepcrs6zpTCvuGfHpglvUqyCvuG1ikuiZ65mguWUiAKPoyqb7IOH1jxiMwUkkWIWhJLkximUkkWAefkKz9CgJsJMwTBGT5AluZa9yG5USR8x(aLvYcPb(FDuqCvmqWYd8aidKDvZaLMaCnQ08a9vpqSwBBajEBfsg49gEhiwzVsH7aZ4e)(al0arSGvbRhOV6bkR7KXhyHg4cIbsyxlzG(jyYaJgEGll7yGiwbwDAGTjXDxcAG5UShO0bw)aVxrZaVH)aBtkonTCvuGfHpgljV14QOaRruOqM1ZzmNAluJm1bJcK3bgBqTbYcmkBtUlBdYMxDgEv)DoPob4AuP50Zg)(7CsaBBajEBfssp7RBJRcxWBKKLVsHRrt87jE9UG14CvwHl4ns5obxwBoaIrZE0K417cwB1QcaeAW9nL7eCzT5aign7rtIW5ETilW(6RBJR82YKk4KRyZZ2ib8igKG5lCI4lUy5MvRzPaaHgCFtDoUZ8AIg2Wsyu6zFTvRkqEhySb1gim(w5UQXjYzTrzpTCvuGfHpglvUqyCvuG1ikuiZ65mM(Re6PLRIcSi8XyPtu(YMaqi8gYuhm8Ye5ssA(uQkSad2zdFEzICjjclN3PLRIcSi8XyPtu(Yg7NaXtlxffyr4JXsrjVjqgz9pT8CEJPLRIcSi8Xyz3LBahtqkfUOP10QDdu6xj0mbnTCvuGfL6VsOXWQgqTYne2Mu5(QNwUkkWIs9xj04JXsetiEWAthSSbzx4YYOKOeSjCICoqyWwM6GjlnisiMq8G1MoyzdYUWLtrPWTw5wT6QOUWgE58IryWghIxAdFH3i5AnkvRfNNqyiSQXjYztu5SvRQgNiNrwCdNtjVjmeo3RfHLSnTA3aXAq8aLfkuaed83aIbwNbwXaVdwzTXavU9avG8oyG2GAd0a9vpWOHhiwRTnGeVTcjdS)oNbwOb(StdSnDbu6b(q1kFG3B4DGzSz2EGYAaEKbMXubAGOWv4IgOt4b2uYBgiGmW7n8oWhQw5dmJHDBWM7OGjYmW3kyeAGrdpWmo7Audigy)DodSqd8zNMwUkkWIs9xj04JXs7cfaHb1aczQdMRcxWBKKLVsHRrt87jE9UG1wT6TLjvWjCz22ib8iM7vGmEh8cJeWlr8fxSC7AC6VZjbSTbK4Tvij9SX5Q(7Cs4YSTrc4rm3Raz8o4fgjGxcfUcxSGD2TALxMixcwYE2UEA5QOalk1FLqJpglTluaegudiKPoy6VZjbSTbK4Tvij9SX5Q(7CsA21OgqKE2wT2FNtsoH5fHBTiZ9sHltqPNTvR935KuGvXUG1MU4TAM0Fiu6zF90YvrbwuQ)kHgFmwIQTqbtmOGu4YtRPv7gOScaeAW9fnTCvuGfLuAegLlegxffynIcfYSEoJHriEvmsM6GjluWUiAyDYfIPLRIcSOKsJWhJLhHlNfcpkWoTCvuGfLuAe(yS8iC5Sq4rbwJsW(IyzQdgn3FNt6iC5Sq4rb2eHZ9Ary520YvrbwusPr4JXsxt41f1YgYd1itDWKv)Dojxt41f1YgYd1KE24CvwSS8v22So5Tf14ehzoGnmGJXgCNjwTQaaHgCFtcp4nmor5RNiCUxlYIBzE90YvrbwusPr4JXsBaqyimc8ikwMdGyww2bgSNwUkkWIskncFmwsacHjAythSmsM6GP)oNebieMOHnDWYOeHZ9Arybt7TA9ItkVl4ej6gctacX0QDdeR7mqxRrd0j8aF2Ymq0w28aJgEGGLh49kAgOaCNrXaXdVmEAGyniEG3B4DGAj1kFGhhfmzGrJVduwjlmqnFkvfdeqg49kAaVyG(kzGYkzH00YvrbwusPr4JXYCNGlRnhaXOzpAKrjrjyt4e5CGWGTm1bdXlTHVWBKCTgLE24C1PK3egcN71IWIcK3bgBqTbkP5tPQWQ1Sqb7IOH1jcq(JXrbY7aJnO2aL08PuvybgLTj3LTbzZRodX(6Pv7giw3zGlyGUwJg49sigOU4bEVIMAhy0WdCzzhdS9zIKzGpepqzDNm(ab7a7aeAG3ROb8Ib6RKbkRKfstlxffyrjLgHpglZDcUS2CaeJM9OrM6GH4L2Wx4nsUwJs1Ar7ZmdjEPn8fEJKR1OK(r8OalozHc2frdRteG8hJJcK3bgBqTbkP5tPQWcmkBtUlBdYMxDgI90QDduAHR5b2MfpcrYab7aVH)a5LZlgLgygtfnd01AewPbI1G4bwNbgnSKbIcxYapaYaZa8hiIvGvJgiGmW6mqjGhzGll7yGQgNiNh49sigyNhiHDTKbw7aJkNh4bqgy0WdCzzhd8UFHttlxffyrjLgHpgl7cxZMJ4risKPoyq2SqycNiNdKfyUHtw935K6cxZMJ4risspBCUklIxAdFH3i5AnkXYUqbYQvIxAdFH3i5Ankr4CVwKfzGvReV0g(cVrY1AuQwlU6wgQaaHgCFtDHRzZr8iejjvJtKZiZH4QOaRlUUnULTRNwTBGslCnpW2S4risgiyhi24nW6mqjGhzGll7yGQgNiNh49sigyNhiHDTKbw7aJkNh4bqgy0WdCzzhd8UFHttlxffyrjLgHpgl7cxZMJ4risKPoyq2SqycNiNdegSXH4L2Wx4nsUwJs1AXv3Yqfai0G7BQlCnBoIhHijPACICgzoexffyDX1TXTSnTCvuGfLuAe(ySuEdafcjguqkCzzQdgfiVdm2GAdusZNsvHfyWg)(7CsDcW1OsZPN90YvrbwusPr4JXsClHOw5gKnHzzQdMloP8UGtDHRzZr8iejgKKvHdYMfct4e5CGsDHRzZr8iejwGno8Ye5ssrLZMayYDzBXTPLRIcSOKsJWhJLDHRzd5HAKPoyU4KY7co1fUMnhXJqKyqswfo8Ye5ssrLZMayYDzBXTPv7giwdQw5dmJLVfQXY2uE)HAgyHgiyfsgOpWlmrYaJALmWAve2rSmdebgyTdKWUOcjYmqjGNSwcpqVJaIxWcjd8ulpWamWhIhyfd0rd0h4lkrfsgiYMfI00YvrbwusPr4JXYl(wOgzQdMSqb7IOH1jxiW5ItkVl4KN3FOgJcS6kkWoTCvuGfLuAe(ySutyx3fUMrYuhmzHc2frdRtUqGJcK3bgBqTbclyWEA5QOalkP0i8XyjQX1G75SqltDWKfkyxenSo5cboxCs5DbN88(d1yuGvxrb2PLRIcSOKsJWhJLi2gvizQdMSqb7IOH1jxiMwUkkWIskncFmwAdIcSYuhm935K6caqlEOiryxfwT2FNtY1eEDrTSH8qnPN90YvrbwusPr4JXYUaa0MZJizA5QOalkP0i8XyzNjiMGBTYNwUkkWIskncFmwEkc3faGEA5QOalkP0i8XyPVkgfexyuUqmTCvuGfLuAe(yS8HytfCUm85WQWSEoJrjrjabbSLY0fokKPoyYcfSlIgwNCHaN(7CsUMWRlQLnKhQjPb3xC6VZjLZ5aIed4yepvPnAc75OKgCFXHxMixskQC2eatUlBlYooKOB6VZbHLSnTCvuGfLuAe(yS8HytfCUmRNZy82IACIJmhWggWXydUZezQdMS6VZj5AcVUOw2qEOM0ZgNS6VZj1fUMnhXJqKKE24OaaHgCFtUMWRlQLnKhQjr4CVwewWoBtR2nWmwmrYajGN8gHKbsEcEGGZaJMxEVofRhyUhnOb2zb4owPbI1G4bEaKbI1T4Ad0durQqMbcIgMCVq8aVxrZaBtYId0JbElt8hikCfUObcide7mXFG3ROzGUabgO0caqpWNDAA5QOalkP0i8Xy5dXMk4CzwpNX4OMl(YidXBlGyuaIlKPoy0C)DojI3waXOaexy0C)Dojn4(A1QM7VZjPaR(PI6cBQfxJM7VZj9SXjCICosnSlIMKTkWs7VHt4e5CKAyxenjBvybM2NPvRzP5(7CskWQFQOUWMAX1O5(7CspBCUsZ935KiEBbeJcqCHrZ935KqHRW1cm3YmdXoZ2qZ935K6caqBaht0WgE5CjPNTvRNsEtyiCUxlclzuMxJt)Dojxt41f1YgYd1KiCUxlYcSZGPv7gygNp(ted84cr3v4oWdGmWhY7cEGvW5O00YvrbwusPr4JXYhInvW5izQdM(7CsDbaOfpuKiSRcRwpL8MWq4CVwewWCltRwvG8oWydQnqjnFkvfybZTP10QDdeRhH4vXOPLRIcSOeJq8Qyegfyv8gepyT5i8CwM6GHxMixskQC2eatUlBlWgNS6VZj1fUMnhXJqKKE24CvwAqKuGvXBq8G1MJWZzt)r2uukCRvooz5QOaBsbwfVbXdwBocpNt1AoIsEty165jegcRACIC2evoJf5kDk3L91tlxffyrjgH4vXi8XyzxaaAd4yIg2WlNlrM6G5ItkVl4ux4A2CepcrIbjzv4OaaHgCFtDoUZ8AIg2Wsyu6zJZviBwimHtKZbk1fUMnhXJqKybMBwTs8sB4l8gjxRrPATi7z76PLRIcSOeJq8Qye(ySu(Zj6Yxd4y82Yeq0mTCvuGfLyeIxfJWhJLhG6HyTXBltQGnD2ZLPoyq2SqycNiNduQlCnBoIhHiXcm3SAL4L2Wx4nsUwJs1ArgLjoz1FNtY1eEDrTSH8qnPN90YvrbwuIriEvmcFmwA)i1rsTYnDHJczQdgKnleMWjY5aL6cxZMJ4risSaZnRwjEPn8fEJKR1OuTwKrzoTCvuGfLyeIxfJWhJLrdBEBh8wT5aikwM6GP)oNeHv4kyeYCaefNE2wT2FNtIWkCfmczoaIInkWBdMKqHRWflyN50YvrbwuIriEvmcFmwskBBbBQ1GSDfpTCvuGfLyeIxfJWhJL3beH(cxRHWiW6RINwUkkWIsmcXRIr4JXYCohqKyahJ4PkTrtyphjtDWWltKlblzpBtR2nqSYbc9aLfz3Uw5dSnl8CgnWdGmqw2S6f8aj(kNhiGmqClHyG935GKzG1zG2aeQ6conW2K4UlbnWGizGbyGY5yGrdpqb4oJIbQaaHgCFhy3rSEGGDG(fVeExWdKxoVyuAA5QOalkXieVkgHpgljSBxRCZr45msgLeLGnHtKZbcd2YuhmHtKZrkQC2eaJUySGDkBwTE1vHtKZrQHDr0KSvHfzqMwTgorohPg2frtYwfybZTmVgNRCvuxydVCEXimyB16fNuExWjc721k3OzHlXIBy1RV2Q1RcNiNJuu5SjagBvyULPfTptCUYvrDHn8Y5fJWGTvRxCs5DbNiSBxRCJMfUelYE2V(6P10QDdSnxBHAycAA1UbkDG1pqWoqfai0G77adWaXLz7bgn8aLvKkgOM7VZzGp7PLRIcSO0P2c1GPZXDMxt0WgwcJMwUkkWIsNAlud(ySejkfB8vB0LILPoy6VZjHeLIn(Qn6sXjcN71IWYPK3egcN71IWP)oNesuk24R2OlfNiCUxlclxHn(kqEhySb1gORBdStzW0Yvrbwu6uBHAWhJL6cz7HQzAnTA3a)b7IOzA5QOalkHc2frdgvd72gudiKrjrjyt4e5CGWGTm1bt4cEJKnHLyaRjAyZD2XnXR3fSgNScNiNJuHmDacnTCvuGfLqb7IObFmw659hQH(VWeubwQu3Y8wMzIvXo7PB0)DNS1khr)yD52asW6bIvmqxffyhOOqbknTOF)fnac9)RCzf9lkuGO4r)mcXRIru8OsHnfp6NxVlynvA6xrQGjLt)8Ye5ssrLZMayYDzpqlgi2deNbM1a7VZj1fUMnhXJqKKE2deNbE1aZAGAqKuGvXBq8G1MJWZzt)r2uukCRv(aXzGznqxffytkWQ4niEWAZr45CQwZruYBIbA16appHWqyvJtKZMOY5bILbkxPt5USh410VRIcS0VcSkEdIhS2CeEotdQu3O4r)86DbRPst)ksfmPC6)ItkVl4ux4A2CepcrIbjzvdeNbQaaHgCFtDoUZ8AIg2Wsyu6zpqCg4vdezZcHjCICoqPUW1S5iEeIKbAbMbEBGwToqIxAdFH3i5Ankv7aTyGzpBd8A63vrbw6VlaaTbCmrdB4LZLqdQuTNIh97QOal9l)5eD5RbCmEBzciAOFE9UG1uPPbvQStXJ(517cwtLM(vKkys50pYMfct4e5CGsDHRzZr8iejd0cmd82aTADGeV0g(cVrY1AuQ2bAXaZOmhiodmRb2FNtY1eEDrTSH8qnPNn97QOal9FaQhI1gVTmPc20zpNguPYgfp6NxVlynvA6xrQGjLt)iBwimHtKZbk1fUMnhXJqKmqlWmWBd0Q1bs8sB4l8gjxRrPAhOfdmJYK(DvuGL(TFK6iPw5MUWrbnOsLru8OFE9UG1uPPFfPcMuo93FNtIWkCfmczoaIItp7bA16a7VZjryfUcgHmharXgf4TbtsOWv4oqSmqSZK(DvuGL(Jg282o4TAZbqumnOsHvqXJ(DvuGL(jLTTGn1Aq2UIPFE9UG1uPPbvQmGIh97QOal9Fhqe6lCTgcJaRVkM(517cwtLMguPWQu8OFE9UG1uPPFfPcMuo9ZltKlzGyzGzpB0VRIcS0FoNdismGJr8uL2OjSNJObvkSZKIh9ZR3fSMkn97QOal9ty3Uw5MJWZze9RivWKYP)WjY5ifvoBcGrx8aXYaXoLTbA16aVAGxnWWjY5i1WUiAs2QyGwmWmiZbA16adNiNJud7IOjzRIbIfmd8wMd86bIZaVAGUkQlSHxoVy0aXmqShOvRd8ItkVl4eHD7ALB0SWLmqlg4nS6aVEGxpqRwh4vdmCICosrLZMaySvH5wMd0Ib2(mhiod8Qb6QOUWgE58IrdeZaXEGwToWloP8UGte2TRvUrZcxYaTyGzp7d86bEn9RKOeSjCICoquPWMg0G(18XFIGIhvkSP4r)UkkWs)4wkCPFE9UG1uPPbvQBu8OFxffyPFuWUiAOFE9UG1uPPbvQ2tXJ(517cwtLM(b20pId63vrbw6)ItkVly6)IlEm9Nj9FXjM1Zz6NeDdHjaHGguPYofp6NxVlynvA6hyt)ioOFxffyP)loP8UGP)lU4X0VcK3bgBqTbkP5tPQyGwGzG3gi(d82aBJbE1adxWBKK3aqHqIbfKcxoXR3fSEG4mqfai0G7BsEdafcjguqkC5eHZ9Ardelde7bE9aXFG935K6eGRrLMtp7bIZa5LjYLmqlgygL5aXzGznW(7CsiCFcHXxTrraiuhSmk9ShiodmRb2FNtcxMTnsapI5EfiJ3bVWib8spB6)ItmRNZ0VN3FOgJcS6kkWsdQuzJIh9ZR3fSMkn9dSPFeh0VRIcS0)fNuExW0)fx8y6hzZcHjCICoqPUW1S5iEeIKbILbEBG4mqIxAdFH3i5Ankv7aTyG3YCGwToW(7CsDHRzZr8iejPNn9FXjM1Zz6VlCnBoIhHiXGKSkAqLkJO4r)86DbRPst)ksfmPC6hfSlIgwNCHG(DvuGL(vUqyCvuG1ikuq)IcfM1Zz6hfSlIgAqLcRGIh9ZR3fSMkn97QOal9RCHW4QOaRruOG(ffkmRNZ0VsJObvQmGIh9ZR3fSMkn9RivWKYPFfiVdm2GAd0aTaZav2MCx2gKnV6bMHd8Qb2FNtQtaUgvAo9Shi(dS)oNeW2gqI3wHK0ZEGxpW2yGxnWWf8gjz5Ru4A0e)EIxVly9aXzGxnWSgy4cEJuUtWL1MdGy0ShnjE9UG1d0Q1bQaaHgCFt5obxwBoaIrZE0KiCUxlAGwmqSh41d86b2gd8Qb6TLjvWjxXMNTrc4rmibZx4eXxChiwg4TbA16aZAGkaqOb33uNJ7mVMOHnSegLE2d86bA16avG8oWydQnqdeZa9TYDvJtKZAJYM(DvuGL(jV14QOaRruOG(ffkmRNZ0)P2c1qdQuyvkE0pVExWAQ00VRIcS0VYfcJRIcSgrHc6xuOWSEot)9xj00Gkf2zsXJ(517cwtLM(vKkys50pVmrUKKMpLQIbAbMbID2gi(dKxMixsIWY5L(DvuGL(DIYx2eacH3GguPWgBkE0VRIcS0Vtu(Yg7NaX0pVExWAQ00Gkf23O4r)UkkWs)IsEtGmY6FA558g0pVExWAQ00Gkf2TNIh97QOal93D5gWXeKsHlI(517cwtLMg0G(TjScK39GIhvkSP4r)UkkWs)UTTqIXguiWs)86DbRPstdQu3O4r)86DbRPstdQuTNIh9ZR3fSMknnOsLDkE0pVExWAQ00Gkv2O4r)86DbRPstdQuzefp63vrbw63gefyPFE9UG1uPPbvkSckE0pVExWAQ00VRIcS0FUtWL1MdGy0Shn0VIubtkN(jEPn8fEJKR1OuTd0IbM9mPFBcRa5DpmiwbwnI(ZgnOsLbu8OFE9UG1uPPFfPcMuo9F1aZAGSS8v22Sozdu4YbQAlRnkqU9l8OaRrZxkfpqRwhywdubacn4(MusucqqaBPmDHJIK(r8Oa7aTADGeV0g(cVrQ2lpXYeVl4el7cfObEn97QOal9Jc2frdnOsHvP4r)86DbRPst)UkkWs)eGqyIg20blJOFfPcMuo9t4dHrnExW0VnHvG8UhgeRaRgr)3ObvkSZKIh9ZR3fSMkn97QOal9JeLIn(Qn6sX0VnHvG8UhgeRaRgr)3ObvkSXMIh9ZR3fSMkn97QOal97AcVUOw2qEOg6xrQGjLt)xnWSgillFLTnRt2afUCGQ2YAJcKB)cpkWA08LsXd0Q1bM1avaGqdUVjLeLaeeWwktx4OiPFepkWoqRwhiXlTHVWBKQ9YtSmX7coXYUqbAGxt)2ewbY7EyqScSAe9JnnOsH9nkE0pVExWAQ00)65m97Tf14ehzoGnmGJXgCNj0VRIcS0V3wuJtCK5a2WaogBWDMqdQuy3EkE0pVExWAQ00VRIcS0VsIsaccylLPlCuq)ksfmPC6pRbs8sB4l8gPAV8elt8UGtSSluGOF(CyvywpNPFLeLaeeWwktx4OGg0G(p1wOgkEuPWMIh97QOal9354oZRjAydlHr0pVExWAQ00Gk1nkE0pVExWAQ00VIubtkN(7VZjHeLIn(Qn6sXjcN71Igiwg4PK3egcN71IgiodS)oNesuk24R2OlfNiCUxlAGyzGxnqShi(dubY7aJnO2anWRhyBmqStza97QOal9JeLIn(Qn6sX0Gkv7P4r)UkkWs)6cz7HQH(517cwtLMg0G(rb7IOHIhvkSP4r)86DbRPst)UkkWs)Qg2TnOgqq)ksfmPC6pCbVrYMWsmG1enS5o74M417cwpqCgywdmCICosfY0bie9RKOeSjCICoquPWMguPUrXJ(DvuGL(98(d1q)86DbRPstdAq)knIIhvkSP4r)86DbRPst)ksfmPC6pRbIc2frdRtUqq)UkkWs)kximUkkWAefkOFrHcZ65m9ZieVkgrdQu3O4r)UkkWs)hHlNfcpkWs)86DbRPstdQuTNIh9ZR3fSMkn9RivWKYPFn3FNt6iC5Sq4rb2eHZ9Ardeld8g97QOal9FeUCwi8OaRrjyFrmnOsLDkE0pVExWAQ00VIubtkN(ZAG935KCnHxxulBiput6zpqCg4vdmRbYYYxzBZ6K3wuJtCK5a2WaogBWDMmqRwhOcaeAW9nj8G3W4eLVEIW5ETObAXaVL5aVM(DvuGL(DnHxxulBipudnOsLnkE0pVExWAQ00)bqmll7Gkf20VRIcS0VnaimegbEeftdQuzefp6NxVlynvA6xrQGjLt)935KiaHWenSPdwgLiCUxlAGybZaB)aTADGxCs5DbNir3qycqiOFxffyPFcqimrdB6GLr0Gkfwbfp6NxVlynvA63vrbw6p3j4YAZbqmA2Jg6xrQGjLt)eV0g(cVrY1Au6zpqCg4vd8uYBcdHZ9ArdeldubY7aJnO2aL08PuvmqRwhywdefSlIgwNia5pEG4mqfiVdm2GAdusZNsvXaTaZav2MCx2gKnV6bMHde7bEn9RKOeSjCICoquPWMguPYakE0pVExWAQ00VIubtkN(jEPn8fEJKR1OuTd0Ib2(mhygoqIxAdFH3i5AnkPFepkWoqCgywdefSlIgwNia5pEG4mqfiVdm2GAdusZNsvXaTaZav2MCx2gKnV6bMHdeB63vrbw6p3j4YAZbqmA2JgAqLcRsXJ(517cwtLM(vKkys50pYMfct4e5CGgOfyg4TbIZaZAG935K6cxZMJ4rissp7bIZaVAGznqIxAdFH3i5AnkXYUqbAGwToqIxAdFH3i5Ankr4CVw0aTyGzWaTADGeV0g(cVrY1AuQ2bAXaVAG3gygoqfai0G7BQlCnBoIhHijPACICgzoexffyDXaVEGTXaVLTbEn97QOal93fUMnhXJqKqdQuyNjfp6NxVlynvA6xrQGjLt)iBwimHtKZbAGygi2deNbs8sB4l8gjxRrPAhOfd8QbEBGz4avaGqdUVPUW1S5iEeIKKQXjYzK5qCvuG1fd86b2gd8w2OFxffyP)UW1S5iEeIeAqLcBSP4r)86DbRPst)ksfmPC6xbY7aJnO2aL08PuvmqlWmqShi(dS)oNuNaCnQ0C6zt)UkkWs)YBaOqiXGcsHltdQuyFJIh9ZR3fSMkn9RivWKYP)loP8UGtDHRzZr8iejgKKvnqCgiYMfct4e5CGsDHRzZr8iejd0IbI9aXzG8Ye5ssrLZMayYDzpqlg4n63vrbw6h3siQvUbztyMguPWU9u8OFE9UG1uPPFfPcMuo9FXjL3fCQlCnBoIhHiXGKSQbIZa5LjYLKIkNnbWK7YEGwmWB0VRIcS0Fx4A2qEOgAqLc7StXJ(517cwtLM(vKkys50FwdefSlIgwNCHyG4mWloP8UGtEE)HAmkWQROal97QOal9FX3c1qdQuyNnkE0pVExWAQ00VIubtkN(ZAGOGDr0W6KledeNbQa5DGXguBGgiwWmqSPFxffyPFnHDDx4AgrdQuyNru8OFE9UG1uPPFfPcMuo9N1arb7IOH1jxigiod8ItkVl4KN3FOgJcS6kkWs)UkkWs)OgxdUNZcnnOsHnwbfp6NxVlynvA6xrQGjLt)znquWUiAyDYfc63vrbw6hX2OcrdQuyNbu8OFE9UG1uPPFfPcMuo93FNtQlaaT4HIeHDvmqRwhy)Dojxt41f1YgYd1KE20VRIcS0VnikWsdQuyJvP4r)UkkWs)DbaOnNhrc9ZR3fSMknnOsDltkE0VRIcS0FNjiMGBTYPFE9UG1uPPbvQBytXJ(DvuGL(pfH7caqt)86DbRPstdQu3UrXJ(DvuGL(9vXOG4cJYfc6NxVlynvAAqL6w7P4r)86DbRPst)UkkWs)kjkbiiGTuMUWrb9RivWKYP)SgikyxenSo5cXaXzG935KCnHxxulBiputsdUVdeNb2FNtkNZbejgWXiEQsB0e2Zrjn4(oqCgiVmrUKuu5SjaMCx2d0IbM9bIZajr30FNdAGyzGzJ(5ZHvHz9CM(vsucqqaBPmDHJcAqL6w2P4r)86DbRPst)UkkWs)EBrnoXrMdydd4ySb3zc9RivWKYP)Sgy)Dojxt41f1YgYd1KE2deNbM1a7VZj1fUMnhXJqKKE2deNbQaaHgCFtUMWRlQLnKhQjr4CVw0aXYaXoB0)65m97Tf14ehzoGnmGJXgCNj0Gk1TSrXJ(517cwtLM(DvuGL(DuZfFzKH4TfqmkaXf0VIubtkN(1C)DojI3waXOaexy0C)Dojn4(oqRwhOM7VZjPaR(PI6cBQfxJM7VZj9ShiodmCICosnSlIMKTkgiwgy7VnqCgy4e5CKAyxenjBvmqlWmW2N5aTADGznqn3FNtsbw9tf1f2ulUgn3FNt6zpqCg4vduZ935KiEBbeJcqCHrZ935KqHRWDGwGzG3YCGz4aXoZb2gduZ935K6caqBaht0WgE5CjPN9aTADGNsEtyiCUxlAGyzGzuMd86bIZa7VZj5AcVUOw2qEOMeHZ9Ard0IbIDgq)RNZ0VJAU4lJmeVTaIrbiUGguPULru8OFE9UG1uPPFfPcMuo93FNtQlaaT4HIeHDvmqRwh4PK3egcN71IgiwWmWBzoqRwhOcK3bgBqTbkP5tPQyGybZaVr)UkkWs)peBQGZr0Gg0F)vcnfpQuytXJ(DvuGL(zvdOw5gcBtQCF10pVExWAQ00Gk1nkE0pVExWAQ00VRIcS0pIjepyTPdw2GSlCz6xrQGjLt)znqnisiMq8G1MoyzdYUWLtrPWTw5d0Q1b6QOUWgE58IrdeZaXEG4mqIxAdFH3i5Ankv7aTyGNNqyiSQXjYztu58aTADGQgNiNrd0IbEBG4mWtjVjmeo3RfnqSmWSr)kjkbBcNiNdevkSPbvQ2tXJ(517cwtLM(vKkys50)vdmCbVrsw(kfUgnXVN417cwpqRwhO3wMubNWLzBJeWJyUxbY4DWlmsaVeXxChiwg4TbE9aXzG935Ka22as82kKKE2deNbE1a7VZjHlZ2gjGhXCVcKX7GxyKaEju4kChiwgi2zFGwToqEzICjdeldm7zBGxt)UkkWs)2fkacdQbe0Gkv2P4r)86DbRPst)ksfmPC6V)oNeW2gqI3wHK0ZEG4mWRgy)Dojn7Audisp7bA16a7VZjjNW8IWTwK5EPWLjO0ZEGwToW(7CskWQyxWAtx8wnt6pek9Sh410VRIcS0VDHcGWGAabnOsLnkE0VRIcS0pQ2cfmXGcsHlt)86DbRPstdAqdAqdkf]] )

end