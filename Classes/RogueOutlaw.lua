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
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up
            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.shadowmeld.up
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
            
            readyTime = function () return buff.crippling_poison.remains - 120 end,

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
            
            readyTime = function () return buff.instant_poison.remains - 120 end,

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
            
            readyTime = function () return buff.numbing_poison.remains - 120 end,

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
                    gain( 1 + ( buff.broadside.up and 1 or 0 ) + ( buff.opportunity.up and 1 or 0 ), "combo_points" )
                end

                removeBuff( "deadshot" )
                removeBuff( "opportunity" )
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

            spend = 50,
            spendType = "energy",

            startsCombat = false,
            texture = 1373910,

            usable = function ()
                return combo_points.current > 0, "requires combo_points"
            end,

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


        slaughter = {
            id = 323654,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 50,
            spendType = "energy",
            
            startsCombat = true,
            texture = 3565724,
            
            handler = function ()
                applyBuff( "slaughter_poison" )
                gain( 2, "combo_points" )
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


    spec:RegisterPack( "Outlaw", 20200823.3, [[d4eacbqiPepsukBcL4tKKO0OaiNcGAvIsvVIemlsQULusSlr(LOWWOK6yOildf1ZaKmnarxtkP2Mus6BaczCKK05ijH1biqZtuY9qH9rj5GIIulKK4HIsLMOOiCraHAJacAKacOtciLwjaEjjjQ6MIIiTtsk)eqkgQOi5OKKOyPIsfpfOPscDvssKTssIkFvue1zffrSxu9xIgmKdlSyP6XeMmfxgzZk8zkXOLItlz1acWRrjnBsDBr1Uv53QA4uQJdivlhQNdA6uDDfTDPuFhqnErrDEs06jj18rP2VsZzIRih0eoXvJzRz2ARvvMbQetT2AvbqXmh0vAtCq7qWAyH4GxKtCqGMPRdG5G2Hs9hgUICq4pXcId24UneiygzyP8Mzpj(8mGv(uhE9NahdpdyLlYGd2NL2bApENdAcN4QXS1mBT1QkZavIPwBTQGzvbheAtcUAm3QwZbBkJHoENdAiOGdMTfb0mDDa8IYoVLjTaKTfLPWKUYRlWkxeytyEG1XzGlAABcNsCqB8pknXbZ2IaAMUoaErzN3YKwaY2IYuysx51fyLlcSjmpW64mWfnTnHtPfGfGSTiG4mtIPtMf1PXJPfj(8E4lQtwQdMwuMwiiBhUO7VwPjW5JPErHWR)Gl6pTY0cq2wui86pyYgtIpVhoJHoGSUaKTffcV(dMSXK4Z7HRaJmIPLC68WR)waY2IcHx)bt2ys859WvGrgJ)nlazBrGxydBEFr4OmlQphdYSiOhoCrDA8yArIpVh(I6KL6GlkoZISXuRy)UxNLfvWfz(JslazBrHWR)GjBmj(8E4kWid4f2WM3LqpC4cqi86pyYgtIpVhUcmYOoOhNlT)c(3cqi86pyYgtIpVhUcmYqGlBBDDwK2Fb)BbieE9hmzJjXN3dxbgzCZ8EDwK2Fb)BbieE9hmzJjXN3dxbgz0oWv01K6xKtm(2ewITLcC5sVbtWMxBuVDONeJW9qWQuGl3kRtajZlaHWR)GjBmj(8E4kWid73R)wacHx)bt2ys859WvGrg5bMvYihpwAOWBu3gtIpVhUesI)mqgTw9AWahLrsTPZtHXat1zfqA9cqi86pyYgtIpVhUcmYa6uO9g1Rbda1cb0NLTnzs2VGvYHLQjJu852tp86pPHAxcIn7we)RnpWxsOuOFh)xjKDDa9KzIdV(JnBCugj1Mopvx7P(iC01uIYCbDiGxacHx)bt2ys859WvGrgqDjizCgPPeK62ys859WLqs8NbYaOuVgm6ZXib1LGKXzKMsqjmLh1bZYRCs6V0uel95yKG6sqY4mstjOeMYJ6GzbiMuq859xA)15qaN9mLu1fGq41FWKnMeFEpCfyKryW0f66ijEcBu3gtIpVhUesI)mqgmPEnyaOwiG(SSTjtY(fSsoSunzKIp3E6Hx)jnu7sqSz3I4FT5b(scLc974)kHSRdONmtC41FSzJJYiP205P6Ap1hHJUMsuMlOdb8cqi86pyYgtIpVhUcmYycjz5uU6xKtmcvdBcCaLJ)C5pK2pWeEbieE9hmzJjXN3dxbgzGFTw6nKS)hbv3gtIpVhUesI)mqgmVaecV(dMSXK4Z7HRaJmMqswoLRongKWLxKtmekf63X)vczxhqx9AWOfCugj1Mopvx7P(iC01uIYCbD4cWcq2weqCMjX0jZIO2ew5I8kNwK3qlke(Jxubxu0okD01uAbiBlk7qqNcT3SOASi7hcRUMweGUFrTN6JWrxtlIokVi4IQBrIpVhoGxacHx)bzWAjyv9AWOfOtH2Bitc)wM0cqi86pidOtH2BwacHx)bvGrgTdCfDnP(f5eJiVpHnsXFMYR)uVDONedXN3FP9xNdtgAuIYTIbZkWC2dip005jlnp01kLqhxSsj6IUMmSi(xBEGVKLMh6ALsOJlwPeMYJ6GzXeGvOphJuh)HbwgknTzHocBrPvTQ1S0sFogjiRtTwgNrkWpe2)JGPPnlT0NJrIvISLk)jwcC5qz0)Plv(Z00EbieE9hubgz0oWv01K6xKtm6ojf)zkV(t92HEsm6ZXiHNEJMGqPnMefS(lnTzZgqHQjC5uYqHb28EIUORjdB2HQjC5ukeKCAlv(tSeQjQnLOl6AYayw6ZXiHFTw6nKS)hbtt7fGSTOm5YBwu(u7LTMwKhylKdvFrEtbxu7axrxtlQGls0qcwjZI8FrgsugAra3qEdHxe8ZPfLDZeWfbB(P2SOoTiOYtqMfbC5nlsfDyOfbeQNySYfGq41FqfyKr7axrxtQFroXORddjh6jgRucvEc1Bh6jXaAtAT0dSfYHPUomKCONySYSyMfCugj1MopfgdmvNvmBnB295yK66WqYHEIXktt7fGq41FqfyKHi0Azi86pPUGU6xKtmGofAVr9AWa6uO9gYKcTEbieE9hubgzicTwgcV(tQlOR(f5edHbUaKTfbewxbBwu4lkpYCLpZxu2ntLwe4SdDCi8f9hTOXJxefIMfPc(ddSm0IIZSiGgB7h7ZRCLlc4g6wKQmZsW6IYe4a4fvWfbjnjCYSO4mlkt6itSOcUO79fHPWOCrXWj8I8gArhLzFrqs8NjTOmTg4qjCr5rMxKkoq8IaU8MfXSclktlO0cqi86pOcmYappzi86pPUGU6xKtmg1vWg1RbdXN3FP9xNdTIHWwMhzwcTPZ0kaQphJuh)HbwgknTvOphJ0BB)yFELRmnTbC2dip005jG(SeSkn4a4eDrxtgwaulEOPZt5bMvYihpwAOWBs0fDnzyZw8V28aFP8aZkzKJhlnu4njmLh1bTIjad4ShqHQjC5ukeKCAlv(tSeQjQnLWXXAwmZMDlI)1Mh4l1jhyIoP3qssjbttB2SBPphJe(1AP3qY(FemnTb8cqi86pOcmYqeATmeE9Nuxqx9lYjg9zPnlaHWR)GkWiJalIJK(JX05Qxdg0rylktgAuIYTIbtTwb6iSfLjmzHUfGq41FqfyKrGfXrs7PgslaHWR)GkWidDzPXHsGaMgl505laHWR)GkWiJEyr(dPJlbRWfGfGSTivML2qy4cq2wKQeKwuMQG(RxeyZ7lQglQ8fb8FQY6lse2ls859Fr2FDoCrXzwK3qlcOX2(X(8kx5I6ZXyrfCrt70IY0T)YSOjSollc4g6wKQ8ezVOmj)eVOm5YHlc6HGv4IcmTOMYsZIE8IaUHUfnH1zzrzYuy)xEaDcR(IMNMGWf5n0IYeuyGnVVO(Cmwubx00oTaecV(dM6ZsByyxq)1syZ7QxdgaYdnDEcOplbRsdoaorx01KHn7q1eUCkXkr2sL)elbUCOm6)0Lk)zchhRzXmGzPphJ0BB)yFELRmnTzbq95yKyLiBPYFILaxoug9F6sL)mb9qWAwmbKSzthHTOmlGS1aEbieE9hm1NL2OaJmSlO)AjS5D1RbJ(CmsVT9J95vUY00ML(CmsgkmWM3tt7fGq41FWuFwAJcmYawxbDclHoUyLwawaY2IYU)RnpWhCbieE9hmjmqgIqRLHWR)K6c6QFroXGGq6eeu9AWOfOtH2Bitk06fGq41FWKWavGrgHbtxORJK4jSr9AWOL(CmsHbtxORJK4jSjnTzbqTqa9zzBtMuOAytGdOC8Nl)H0(bMWSzl(xBEGVKoC6CzGfXfjmLh1bTIzRb8cq2weq7yrHXaxuGPfnTvFrWRSPf5n0I(JweWL3Si9dmb9fPOIzI0IuLG0IaUHUfzuwNLfncOt4f5nXTOSBMArgAuIYx0JxeWL38tFrXPCrz3mvAbieE9hmjmqfyKrEGzLmYXJLgk8g1fkfAs6b2c5qgmPEnyGJYiP205PWyGPPnlaYdSfYtELts)LMIYs859xA)15WKHgLOC2SBb6uO9gYKWVLjXI4Z7V0(RZHjdnkr5wXqylZJmlH20zAfMa8cq2weq7yr3VOWyGlc4sRxKPOfbC5n1TiVHw0rz2xeqznu9fnH0IYKoYel6Vf1FiCraxEZp9ffNYfLDZuPfGq41FWKWavGrg5bMvYihpwAOWBuVgmWrzKuB68uymWuDwbuw3k4OmsQnDEkmgyYmXHx)XslqNcT3qMe(TmjweFE)L2FDomzOrjk3kgcBzEKzj0MotRW0cq2wKk6WqlciupXyLl6VfXSclIokViyArzYL3SOWyGabxKQeKwunwK3qkxe0dLlA84fPQkSiij(Zax0JxunwKYFIx0rz2xKOjWwOfbCP1lQtlctHr5IQBrELtlA84f5n0IokZ(IaoAtPfGq41FWKWavGrgDDyi5qpXyLQxdgqBsRLEGTqo0kgmZsl95yK66WqYHEIXkttBwaul4OmsQnDEkmgyIYCbDiB24OmsQnDEkmgyct5rDqRuv2SXrzKuB68uymWuDwbiMBfX)AZd8L66WqYHEIXktIMaBHGYboeE9xObC2ZCRb8cqi86pysyGkWidlnp01kLqhxSsQxdgIpV)s7VohMm0OeLBfdMuOphJuh)HbwgknTxawacHx)btcdubgzWAP11zrcTXePEny0oWv01uQRddjh6jgRucvEcwG2Kwl9aBHCyQRddjh6jgR0kMyHocBrzYRCs6VmpYSvmVaecV(dMegOcmYORddjXtyJ61Gr7axrxtPUomKCONySsju5jyHocBrzYRCs6VmpYSvmVaecV(dMegOcmYa)AT0Biz)pcQEny0NJrcp9gnbHsBmjky9xY8aFS0NJrc)AT0Biz)pcMGEiynlMxacHx)btcdubgzyWuy66Wqq1RbdXN3FP9xNdtgAuIYTY6fGq41FWKWavGrg2Vx)PEny0NJrQR)3ONqpHPq4Sz3NJrkmy6cDDKepHnPP9cq2weqyO11zzr9qW6I8FrgAetTVOYP8fnHHfAbieE9hmjmqfyKXesYYPC1ViNy0oWv01KSoNoy5kLwklr7x7YhkkTo86SiXui8hREny0NJrQR)3ONqpHPq4Sz7voj9xAkklgmBnB2IpV)s7VohMm0OeLNfdMxacHx)btcdubgzmHKSCkhQEny0NJrQR)3ONqpHPq4Sz7voj9xAkklgmBnB2IpV)s7VohMm0OeLNfdMxacHx)btcdubgz01)BKJjw5cqi86pysyGkWiJoHHeM16SSaecV(dMegOcmYyuyQR)3SaecV(dMegOcmYiobbDCOLIqRxacHx)btcdubgzmHKSCkxDAmiHlViNyiuk0VJ)ReYUoGU61GrlqNcT3qMuO1S0NJrkmy6cDDKepHnjZd8XsFogPCk)XkL)qQNIYinykYHjZd8XcDe2IYKx5K0FzEKzRaswWEx2NJbmRwVaecV(dMegOcmYycjz5uU6xKtmcvdBcCaLJ)C5pK2pWew9AWOL(CmsHbtxORJK4jSjnTzPL(CmsDDyi5qpXyLPPnlI)1Mh4lfgmDHUosINWMeMYJ6GzXuRxaY2IuLJWkxe(NwA0kxeEQPf9Jf5nZ8EnkYSO8WBGlQt6hyGGlsvcslA84fb0ESA)MfjWLR(IEVHWaxqAraxEZIY0zNff(Iy2Afwe0dbRWf94fXK1kSiGlVzrHg(lsf9)MfnTtlaHWR)GjHbQaJmMqswoLR(f5eJa20oockXHQFSu84qREnyyO(Cms4q1pwkECOLgQphJK5b(yZ2q95yKe)zMcVAtY6yvAO(CmstBw8aBH8udfAVjzl8SakMzXdSfYtnuO9MKTWTIbqznB2TyO(CmsI)mtHxTjzDSknuFogPPnlaYq95yKWHQFSu84qlnuFogjOhcwTIbZw3kmzD2BO(CmsD9)g5pKEdjPJYvMM2SzpklnUet5rDWSAvRbml95yKcdMUqxhjXtytct5rDqRysvxaY2IYe0iMAFrJqR7HG1fnE8IMWORPfvoLdtlaHWR)GjHbQaJmMqswoLdvVgm6ZXi11)B0tONWuiC2ShLLgxIP8Ooywmy2A2SfFE)L2FDomzOrjkplgmVaSaKTfbedH0ji4cqi86pyIGq6eeKH4pbDooCYih6iNuVgmOJWwuM8kNK(lZJmBftS0sFogPUomKCONySY00Mfa1I59K4pbDooCYih6iNK9j(sEjyTolS0si86VK4pbDooCYih6iNs1jh6YsJZM9yQ1smjAcSfs6voLLfHjLhzgWlaHWR)GjccPtqqfyKrx)Vr(dP3qs6OCLQxdgTdCfDnL66WqYHEIXkLqLNGfX)AZd8L6KdmrN0BijPKGPPnlTdCfDnL6ojf)zkV(JfabTjTw6b2c5Wuxhgso0tmwPvmyMnBCugj1MopfgdmvNvazRbmB2JYsJlXuEuhmlgmz9cqi86pyIGq6eeubgzyzgytfN8hYq1e(9MfGq41FWebH0jiOcmYy8IjKmYq1eUCs2Pix9AWaAtAT0dSfYHPUomKCONySsRyWmB24OmsQnDEkmgyQoRAvRzPL(CmsHbtxORJK4jSjnTzZEuwACjMYJ6GzXK1laHWR)GjccPtqqfyKH9exdL1zr21b0vVgmG2Kwl9aBHCyQRddjh6jgR0kgmZMnokJKAtNNcJbMQZQw1A2ShLLgxIP8Ooywmz9cqi86pyIGq6eeubgz4nKCE9FEg54Xcs9AWOphJeMeSQjiuoESGstB2S7ZXiHjbRAccLJhliP4NNt4e0dbRzXK1laHWR)GjccPtqqfyKbUST1KSoj0oe0cqi86pyIGq6eeubgza8J1M2uDsmb)lobTaecV(dMiiKobbvGrg5u(Jvk)HupfLrAWuKdvVgmOJWwuMfq26fGSTiGaFTzrzhkSRZYIac1robx04XlIYmjMoTiCCwOf94fXAP1lQphdO6lQglY(HWQRP0IY0AGdLWf5yLlY)fzH8f5n0I0pWe0xK4FT5b(wupGKzr)TOODu6ORPfrhLxemTaecV(dMiiKobbvGrgykSRZICOJCcQUqPqtspWwihYGj1RbdpWwip5voj9xAkklMsTMnBabipWwip1qH2Bs2c3kv1A2S9aBH8udfAVjzl8SyWS1aMfafcVAts6O8IGmyInBpWwip5voj9xAkYkMvfagWSzdipWwip5voj9xAlCjZwBfqznlakeE1MK0r5fbzWeB2EGTqEYRCs6V0uKvajqcyaVaSaKTfbewxbBimCbiBlsfhiErFBcVOSJRYIWe(1A4IaU8MfLjOWaBEpJmTGwKJJYHl6Xlk7m9gnbHlktHjrbR)slaHWR)GPrDfSHrNCGj6KEdjjLeu9AWODGRORPu3jP4pt51FlaHWR)GPrDfSrbgza1LGKXzKMsqQxdg95yKG6sqY4mstjOeMYJ6GznklnUet5rDqw6ZXib1LGKXzKMsqjmLh1bZcqmPG4Z7V0(RZHao7zkPQlazBrQ4aXlc4YBwK3qlktlOfPkzVOmj)eViqnrTPf94fLjOWaBEFrookhMwacHx)btJ6kyJcmYOtoWeDsVHKKscQEnyeQMWLtPqqYPTu5pXsOMO2uIUORjdB2HQjC5uYqHb28EIUORjZcqi86pyAuxbBuGrgMcAhUOzbybiBlc0Pq7nlaHWR)GjOtH2ByiAOWwcBExDHsHMKEGTqoKbtQxdgEOPZt2ysP8pP3qsGPG1eDrxtgwAXdSfYtfu2FiCbieE9hmbDk0EJcmYiY7tydhSnHH1FC1y2AMT2AvLzGkXmhe4aF1zbYbbAZTFStMfbeTOq41FlsxqhMwa4GX0BEmheSYZUCqDbDixroibH0jiixrUAmXvKdsx01KHRchuGlNWvWbPJWwuM8kNK(lZJmViRwetlILf1YI6ZXi11HHKd9eJvMM2lILfbOf1YImVNe)jOZXHtg5qh5KSpXxYlbR1zzrSSOwwui86VK4pbDooCYih6iNs1jh6YsJVi2Sx0yQ1smjAcSfs6voTOSwKfHjLhzEraMdgcV(Jdk(tqNJdNmYHoYjUZvJzUICq6IUMmCv4GcC5eUcoy7axrxtPUomKCONySsju5jwells8V28aFPo5at0j9gsskjyAAViwwu7axrxtPUtsXFMYR)wellcqlcAtAT0dSfYHPUomKCONySYfzfJfX8IyZEr4OmsQnDEkmgyQUfz1IaYwViaVi2Sx0OS04smLh1bxuwmwetwZbdHx)Xb76)nYFi9gsshLRK7C1akUICWq41FCqlZaBQ4K)qgQMWV3WbPl6AYWvH7C1asUICq6IUMmCv4GcC5eUcoi0M0APhylKdtDDyi5qpXyLlYkglI5fXM9IWrzKuB68uymWuDlYQf1QwViwwullQphJuyW0f66ijEcBst7fXM9IgLLgxIP8Oo4IYArmznhmeE9hhC8IjKmYq1eUCs2PiN7C1AnxroiDrxtgUkCqbUCcxbheAtAT0dSfYHPUomKCONySYfzfJfX8IyZEr4OmsQnDEkmgyQUfz1IAvRxeB2lAuwACjMYJ6GlkRfXK1CWq41FCq7jUgkRZISRdOZDUATkxroiDrxtgUkCqbUCcxbhSphJeMeSQjiuoESGst7fXM9I6ZXiHjbRAccLJhliP4NNt4e0dbRlkRfXK1CWq41FCqVHKZR)ZZihpwqCNRgqexroyi86poiUST1KSoj0oeehKUORjdxfUZvtv5kYbdHx)Xbb(XAtBQojMG)fNG4G0fDnz4QWDUAQcUICq6IUMmCv4GcC5eUcoiDe2IYfL1IaYwZbdHx)XbZP8hRu(dPEkkJ0GPihYDUAmznxroiDrxtgUkCWq41FCqmf21zro0rob5GcC5eUcoOhylKN8kNK(lnfTOSwetPwVi2SxeGweGwKhylKNAOq7njBHViRwKQA9IyZErEGTqEQHcT3KSf(IYIXIy26fb4fXYIa0IcHxTjjDuErWfXyrmTi2SxKhylKN8kNK(lnfTiRweZQIfb4fb4fXM9Ia0I8aBH8Kx5K0FPTWLmB9ISAraL1lILfbOffcVAts6O8IGlIXIyArSzVipWwip5voj9xAkArwTiGeixeGxeG5GcLcnj9aBHCixnM4o35GgAetTZvKRgtCf5G0fDnz4QWbf4YjCfCWwwe0Pq7nKjHFltIdgcV(JdYAjyL7C1yMRihmeE9hhe6uO9goiDrxtgUkCNRgqXvKdsx01KHRch8T5GqY5GHWR)4GTdCfDnXbBh6jXbfFE)L2FDomzOrjkFrwXyrmVifweZlk7xeGwKhA68KLMh6ALsOJlwPeDrxtMfXYIe)RnpWxYsZdDTsj0XfRuct5rDWfL1IyAraErkSO(CmsD8hgyzO00ErSSi6iSfLlYQf1QwViwwullQphJeK1PwlJZif4hc7)rW00ErSSOwwuFogjwjYwQ8NyjWLdLr)NUu5pttBoy7alViN4GrEFcBKI)mLx)XDUAajxroiDrxtgUkCW3MdcjNdgcV(Jd2oWv01ehSDONehSphJeE6nAccL2ysuW6V00ErSzViaTOq1eUCkzOWaBEprx01KzrSzVOq1eUCkfcsoTLk)jwc1e1Ms0fDnzweGxellQphJe(1AP3qY(FemnT5GTdS8ICId2Dsk(ZuE9h35Q1AUICq6IUMmCv4GVnhesohmeE9hhSDGRORjoy7qpjoi0M0APhylKdtDDyi5qpXyLlkRfX8Iyzr4OmsQnDEkmgyQUfz1Iy26fXM9I6ZXi11HHKd9eJvMM2CW2bwEroXb76WqYHEIXkLqLNG7C1AvUICq6IUMmCv4GcC5eUcoi0Pq7nKjfAnhmeE9hhueATmeE9NuxqNdQlOlViN4GqNcT3WDUAarCf5G0fDnz4QWbdHx)XbfHwldHx)j1f05G6c6YlYjoOWa5oxnvLRihKUORjdxfoOaxoHRGdk(8(lT)6C4ISIXIe2Y8iZsOnDMf1klcqlQphJuh)HbwgknTxKclQphJ0BB)yFELRmnTxeGxu2ViaTip005jG(SeSkn4a4eDrxtMfXYIa0IAzrEOPZt5bMvYihpwAOWBs0fDnzweB2ls8V28aFP8aZkzKJhlnu4njmLh1bxKvlIPfb4fb4fL9lcqlkunHlNsHGKtBPYFILqnrTPeoowxuwlI5fXM9IAzrI)1Mh4l1jhyIoP3qssjbtt7fXM9IAzr95yKWVwl9gs2)JGPP9IamhmeE9hheppzi86pPUGohuxqxEroXbh1vWgUZvtvWvKdsx01KHRchmeE9hhueATmeE9NuxqNdQlOlViN4G9zPnCNRgtwZvKdsx01KHRchuGlNWvWbPJWwuMm0OeLViRySiMA9Iuyr0rylktyYcDCWq41FCWalIJK(JX05CNRgtmXvKdgcV(JdgyrCK0EQHehKUORjdxfUZvJjM5kYbdHx)Xb1LLghkbcyASKtNZbPl6AYWvH7C1ycO4kYbdHx)Xb7Hf5pKoUeSc5G0fDnz4QWDUZbTXK4Z7HZvKRgtCf5GHWR)4G1b94CP9xW)4G0fDnz4QWDUAmZvKdgcV(JdkWLTTUols7VG)XbPl6AYWvH7C1akUICWq41FCWBM3RZI0(l4FCq6IUMmCv4oxnGKRihKUORjdxfo4BZbHKZbdHx)XbBh4k6AId2o0tIdgUhcwLcC5lYQfzDcizMd2oWYlYjo43MWsSTuGlx6nyc28Ad35Q1AUICWq41FCq73R)4G0fDnz4QWDUATkxroiDrxtgUkCWq41FCW8aZkzKJhlnu4nCqbUCcxbhehLrsTPZtHXat1TiRweqAnh0gtIpVhUesI)mqoyR5oxnGiUICq6IUMmCv4GcC5eUcoiGwullIa6ZY2Mmj7xWk5Ws1Krk(C7PhE9N0qTlbTi2Sxulls8V28aFjHsH(D8FLq21b0tMjo86VfXM9IWrzKuB68uDTN6JWrxtjkZf0HlcWCWq41FCqOtH2B4oxnvLRihKUORjdxfoyi86poiuxcsgNrAkbXbf4YjCfCW(CmsqDjizCgPPeuct5rDWfL1I8kNK(lnfTiwwuFogjOUeKmoJ0uckHP8Oo4IYAraArmTifwK4Z7V0(RZHlcWlk7xetjvLdAJjXN3dxcjXFgiheO4oxnvbxroiDrxtgUkCWq41FCWWGPl01rs8e2Wbf4YjCfCqaTOwweb0NLTnzs2VGvYHLQjJu852tp86pPHAxcArSzVOwwK4FT5b(scLc974)kHSRdONmtC41FlIn7fHJYiP205P6Ap1hHJUMsuMlOdxeG5G2ys859WLqs8NbYbzI7C1yYAUICq6IUMmCv4GxKtCWq1WMahq54px(dP9dmH5GHWR)4GHQHnboGYXFU8hs7hycZDUAmXexroiDrxtgUkCWq41FCq8R1sVHK9)iih0gtIpVhUesI)mqoiZCNRgtmZvKdsx01KHRchmeE9hhuOuOFh)xjKDDaDoOaxoHRGd2YIWrzKuB68uDTN6JWrxtjkZf0HCqAmiHlViN4GcLc974)kHSRdOZDUZbh1vWgUIC1yIRihKUORjdxfoOaxoHRGd2oWv01uQ7Ku8NP86poyi86poyNCGj6KEdjjLeK7C1yMRihKUORjdxfoOaxoHRGd2NJrcQlbjJZinLGsykpQdUOSw0OS04smLh1bxellQphJeuxcsgNrAkbLWuEuhCrzTiaTiMwKcls859xA)15Wfb4fL9lIPKQYbdHx)XbH6sqY4mstjiUZvdO4kYbPl6AYWvHdkWLt4k4GHQjC5ukeKCAlv(tSeQjQnLOl6AYSi2SxuOAcxoLmuyGnVNOl6AYWbdHx)Xb7KdmrN0BijPKGCNRgqYvKdgcV(JdAkOD4IgoiDrxtgUkCN7CqOtH2B4kYvJjUICq6IUMmCv4GHWR)4GIgkSLWM35GcC5eUcoOhA68KnMuk)t6nKeykynrx01KzrSSOwwKhylKNkOS)qihuOuOjPhylKd5QXe35QXmxroyi86poyK3NWgoiDrxtgUkCN7CqHbYvKRgtCf5G0fDnz4QWbf4YjCfCWwwe0Pq7nKjfAnhmeE9hhueATmeE9NuxqNdQlOlViN4GeesNGGCNRgZCf5G0fDnz4QWbf4YjCfCWwwuFogPWGPl01rs8e2KM2lILfbOf1YIiG(SSTjtkunSjWbuo(ZL)qA)at4fXM9Ie)RnpWxshoDUmWI4IeMYJ6GlYQfXS1lcWCWq41FCWWGPl01rs8e2WDUAafxroiDrxtgUkCWq41FCW8aZkzKJhlnu4nCqbUCcxbhehLrsTPZtHXatt7fXYIa0I8aBH8Kx5K0FPPOfL1IeFE)L2FDomzOrjkFrSzVOwwe0Pq7nKjHFltArSSiXN3FP9xNdtgAuIYxKvmwKWwMhzwcTPZSOwzrmTiaZbfkfAs6b2c5qUAmXDUAajxroiDrxtgUkCqbUCcxbhehLrsTPZtHXat1TiRweqz9IALfHJYiP205PWyGjZehE93IyzrTSiOtH2Bitc)wM0IyzrIpV)s7VohMm0OeLViRySiHTmpYSeAtNzrTYIyIdgcV(JdMhywjJC8yPHcVH7C1AnxroiDrxtgUkCqbUCcxbheAtAT0dSfYHlYkglI5fXYIAzr95yK66WqYHEIXktt7fXYIa0IAzr4OmsQnDEkmgyIYCbD4IyZEr4OmsQnDEkmgyct5rDWfz1Iu1fXM9IWrzKuB68uymWuDlYQfbOfX8IALfj(xBEGVuxhgso0tmwzs0eyleuoWHWR)c9Ia8IY(fXCRxeG5GHWR)4GDDyi5qpXyLCNRwRYvKdsx01KHRchuGlNWvWbfFE)L2FDomzOrjkFrwXyrmTifwuFogPo(ddSmuAAZbdHx)XbT08qxRucDCXkXDUAarCf5G0fDnz4QWbf4YjCfCW2bUIUMsDDyi5qpXyLsOYtSiwwe0M0APhylKdtDDyi5qpXyLlYQfX0Iyzr0rylktELts)L5rMxKvlIzoyi86poiRLwxNfj0gte35QPQCf5G0fDnz4QWbf4YjCfCW2bUIUMsDDyi5qpXyLsOYtSiwweDe2IYKx5K0FzEK5fz1IyMdgcV(Jd21HHK4jSH7C1ufCf5G0fDnz4QWbf4YjCfCW(Cms4P3OjiuAJjrbR)sMh4BrSSO(Cms4xRLEdj7)rWe0dbRlkRfXmhmeE9hhe)AT0Biz)pcYDUAmznxroiDrxtgUkCqbUCcxbhu859xA)15WKHgLO8fz1ISMdgcV(JdAWuy66WqqUZvJjM4kYbPl6AYWvHdkWLt4k4G95yK66)n6j0tyke(IyZEr95yKcdMUqxhjXtytAAZbdHx)XbTFV(J7C1yIzUICq6IUMmCv4GHWR)4GTdCfDnjRZPdwUsPLYs0(1U8HIsRdVolsmfc)XCqbUCcxbhSphJux)VrpHEctHWxeB2lYRCs6V0u0IYIXIy26fXM9IeFE)L2FDomzOrjkFrzXyrmZbViN4GTdCfDnjRZPdwUsPLYs0(1U8HIsRdVolsmfc)XCNRgtafxroiDrxtgUkCqbUCcxbhSphJux)VrpHEctHWxeB2lYRCs6V0u0IYIXIy26fXM9IeFE)L2FDomzOrjkFrzXyrmZbdHx)XbNqswoLd5oxnMasUICWq41FCWU(FJCmXk5G0fDnz4QWDUAm1AUICWq41FCWoHHeM16SWbPl6AYWvH7C1yQv5kYbdHx)XbhfM66)nCq6IUMmCv4oxnMaI4kYbdHx)XbJtqqhhAPi0AoiDrxtgUkCNRgtQkxroiDrxtgUkCWq41FCqHsH(D8FLq21b05GcC5eUcoyllc6uO9gYKcTErSSO(CmsHbtxORJK4jSjzEGVfXYI6ZXiLt5pwP8hs9uugPbtromzEGVfXYIOJWwuM8kNK(lZJmViRweqUiwwe27Y(CmGlkRf1AoingKWLxKtCqHsH(D8FLq21b05oxnMufCf5G0fDnz4QWbdHx)XbdvdBcCaLJ)C5pK2pWeMdkWLt4k4GTSO(CmsHbtxORJK4jSjnTxellQLf1NJrQRddjh6jgRmnTxells8V28aFPWGPl01rs8e2KWuEuhCrzTiMAnh8ICIdgQg2e4akh)5YFiTFGjm35QXS1Cf5G0fDnz4QWbdHx)Xbdyt74iOehQ(XsXJdnhuGlNWvWbnuFogjCO6hlfpo0sd1NJrY8aFlIn7fzO(CmsI)mtHxTjzDSknuFogPP9IyzrEGTqEQHcT3KSf(IYArafZlILf5b2c5Pgk0EtYw4lYkglcOSErSzVOwwKH6ZXij(ZmfE1MK1XQ0q95yKM2lILfbOfzO(Cms4q1pwkECOLgQphJe0dbRlYkglIzRxuRSiMSErz)ImuFogPU(FJ8hsVHK0r5ktt7fXM9IgLLgxIP8Oo4IYArTQ1lcWlILf1NJrkmy6cDDKepHnjmLh1bxKvlIjvLdEroXbdyt74iOehQ(XsXJdn35QXmtCf5G0fDnz4QWbf4YjCfCW(CmsD9)g9e6jmfcFrSzVOrzPXLykpQdUOSySiMTErSzViXN3FP9xNdtgAuIYxuwmweZCWq41FCWjKKLt5qUZDoyFwAdxrUAmXvKdsx01KHRchuGlNWvWbb0I8qtNNa6ZsWQ0GdGt0fDnzweB2lkunHlNsSsKTu5pXsGlhkJ(pDPYFMWXX6IYArmViaViwwuFogP32(X(8kxzAAViwweGwuFogjwjYwQ8NyjWLdLr)NUu5ptqpeSUOSweta5IyZEr0rylkxuwlciB9IamhmeE9hh0UG(RLWM35oxnM5kYbPl6AYWvHdkWLt4k4G95yKEB7h7ZRCLPP9Iyzr95yKmuyGnVNM2CWq41FCq7c6VwcBEN7C1akUICWq41FCqyDf0jSe64IvIdsx01KHRc35o35o35C]] )

end