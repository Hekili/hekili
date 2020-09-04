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
            alias = { "instant_poison", "wound_poison" },
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


    spec:RegisterPack( "Outlaw", 20200903, [[d4uYebqiPepsuL2euYNOKcPrbK6uqfwfur1RGknlkHBbve7sKFrjzyIkogu0YGQ8mPKAAsj5AajTnrv03asuJtufohLu06asOMNOQUhqTpkrhuuP0cjsEOOsvtKsk5IajyJajYibsiDsOIuRuk1lPKcv3KskL2jrQFcvKmurLIJsjfILkQu5PaMkuvxLskyRusHYxPKs1zPKsXEr1FjzWOCyHflvpMWKP4YiBwHptugTuCAjRgiH41qPMnPUTOSBL(TQgoL64qfLLd55GMovxxrBhi(ouy8us15jQwVOsMprSFvMJjhFoGjCIlnE5Gxo5ynZP1j8WS1GkE5jhWLBtCa7qGDiJ4aBKrCaCQPRdm4a2HC9hgo(Ca4prcId04UneuSvwjR8Mzpj(mRGv2uhE9Rafd3kyLjSId0NL2XPxENdycN4sJxo4LtowZCADcpmBnOIzR4aqBsWLgV8mhoqtzm0Y7CadbfCG8EmCQPRdmowU7LnPRDEpwUbr6kR2aj)yanH5XqhRbESPTjCkXbSr)O0ehiVhdNA66aJJL7Ezt6AN3JLBqKUYQnqYpgqtyEm0XAGhBABcNsx7RDEpgOG1jX0jZX604r0XeFwp8J1jz1cthl3keKTdp2(loPjqzJP(yHWRFHh7xT801oVhleE9lmzJiXN1dh8qhqSV259yHWRFHjBej(SE44c2QyklJwp863RDEpwi86xyYgrIpRhoUGTA8V5AN3JbSHnS59JHIYCS(CmiZXGE4WJ1PXJOJj(SE4hRtYQfESynhZgr4e739ALDScEmZVu6AN3JfcV(fMSrK4Z6HJlyRGBydBExb9WHx7q41VWKnIeFwpCCbBvTqpwxz)f83RDi86xyYgrIpRhoUGTsGkBBDTYu2Fb)9AhcV(fMSrK4Z6HJlyR2zwVwzk7VG)ETdHx)ct2is8z9WXfSvGeOk6AYInYiWpiesHSvcu5kVbrWMxBSaKqpjWH7HaBLavUL5KAfEx7q41VWKnIeFwpCCbBL971Vx7q41VWKnIeFwpCCbBvwGWMmQXJugk8glSrK4Z6HRGK4xdemOArnaJIYOiqO1tHXat1AzRY5AhcV(fMSrK4Z6HJlyRGofAVXIAag0Tq4SzzBtMK9lWMCyLlYOeFM90dV(vziqkbjrslI)1MhJnjKl0VJ(TeQUoGEYmrHx)krckkJIaHwpvlit9sOORPez9c6qCCTdHx)ct2is8z9WXfSvqDjivSgLPeKf2is8z9Wvqs8RbcU1wudWiAGiyt01ew95yKG6sqQynktjOeIYIAH57vgP8xzkcR(CmsqDjivSgLPeucrzrTW8bnM4k(S(RS)ADioW5yMYJRDi86xyYgrIpRhoUGTkmiAdDTKcnHnwyJiXN1dxbjXVgiymTOgGbDleoBw22Kjz)cSjhw5ImkXNzp9WRFvgcKsqsK0I4FT5Xytc5c97OFlHQRdONmtu41VsKGIYOiqO1t1cYuVek6AkrwVGoehx7q41VWKnIeFwpCCbB1esQYPml2iJah5c2eOaQg)6QFOSFmi01oeE9lmzJiXN1dhxWwHETw5nKQ)lbTWgrIpRhUcsIFnqW4DTdHx)ct2is8z9WXfSvtiPkNYSGgds4QnYiWc5c97OFlHQRdOBrna3ckkJIaHwpvlit9sOORPez9c6WR91oVhduW6Ky6K5yeies(X8kJoM3qhle(Jowbpwasu6ORP01oVhl3rqNcT3CSACm7hcRUMogO3)yGm1lHIUMogTuwrWJv7XeFwpCCCTdHx)cbJDjW2IAaUfOtH2Bitc9YM01oeE9lem0Pq7nx7q41VqCbBfibQIUMSyJmcCK1NWgL4xt51VwasONeyXN1FL9xRdtgAuIYTemE4Ihoh0EOP1tYAEORLRGoQWMs0gDnzWs8V28ySjznp01YvqhvytjeLf1cZhtCGBFogPo6ddSmuAAJfTesMClZZCWQL(CmsqSNATkwJsGEiS)lbttBSAPphJe2ezRK)tKcJYHQO)txj)NPP91oeE9lexWwbsGQORjl2iJa3Dsj(1uE9RfGe6jbUphJeA6nAccv2isuW6300wIeqh5IqLtjdfgyZ7jAJUMmsKe5IqLtPqqQPTs(prkOMiqOeTrxtgCGvFogj0R1kVHu9FjyAAFTZ7XS2lV5yztTx2A6yEGKro0IJ5nf8yGeOk6A6yf8yIgsGnzoM)hZqIYqhdJgYBi0XGFgDSCV1cEmyZp1MJ1PJbLVcYCmmkV5ysPddDmqj9eHKFTdHx)cXfSvGeOk6AYInYiWDDyi1qpri5kO8vybiHEsGH2KwR8ajJCyQRddPg6jcjpF8WcfLrrGqRNcJbMQ1s8YrIK(CmsDDyi1qpri5PP91oeE9lexWwjcTwfcV(vPlOBXgzeyOtH2BSOgGHofAVHmPqRV2HWRFH4c2krO1Qq41VkDbDl2iJalmWRDEpgOuTfS5y14yGc5UJb9qG9XYcx0qi4XE0Xc)yzH1RSz2XY95M0XaMDOJcHFSFPJnE0XOq0CmPqFyGLHowSMJHtzB)iFULl)yy0q7XSgzwcSpM1cfyCScEmiPjHtMJfR5ywBhwRJvWJTVFmefg5hlgoHoM3qhBjR7hdsIFnPJLB1yeYHhllS(XKYbfoggL3Cm8W9y5wbLU2HWRFH4c2k0CvHWRFv6c6wSrgbEuBbBSOgG7ZXirIMVwzkezJQSynPPnw95yKirZxRmfISrvwSMe0db2GfFw)v2FTouIeXN1FL9xRdTeSWwLfwxbTP1GtaDFogPo6ddSmuAAJBFogP32(r(ClxEAAJdCoO9qtRNWzZsGTYGcms0gDnzWc0T4HMwpLfiSjJA8iLHcVjrB01KrIeX)AZJXMYce2KrnEKYqH3Kquwul0smXboW5GoYfHkNsHGutBL8FIuqnrGqjuSyNpEsK0I4FT5XytDYXGOv5nKIKtW00wIKw6ZXiHETw5nKQ)lbttBCCTdHx)cXfSvIqRvHWRFv6c6wSrgbUplT5AhcV(fIlyRcKiws5pcrRBrnatlHKjpzOrjk3sWycQ4slHKjpHiz0ETdHx)cXfSvbselPSNAiDTdHx)cXfSv6swJdvGImnYYO1V2HWRFH4c2QEit9dLJkb2WR91oVhtQzPnecETdHx)ct9zPnGjrZxRmfISrvwSMRDi86xyQplTbxWwbjekCYO6)skODHnzrnal(S(RS)ADyYqJsuE(yIRH6ZXibjekCYO6)skODHnLGEiW(AN3JznaPJLBkO)6Jb08(XQXXk)yy8R1O(XeH9XeFw)pM9xRdpwSMJ5n0XWPSTFKp3YLFS(Cmowbp20oDSCliFzo2ewRSJHrdThZACISpM1MFIoM1E5WJb9qGn8ybIowtjR5yp6yy0q7XMWALDmRDkS)nlGoHS4yZvtq4X8g6ywlkmWM3pwFoghRGhBANU2HWRFHP(S0gCbBLDb9xRGnVBrnadAp006jC2SeyRmOaJeTrxtgjsICrOYPe2ezRK)tKcJYHQO)txj)NjuSyNpE4aR(CmsVT9J85wU800glq3NJrcBISvY)jsHr5qv0)PRK)Ze0db25JzRKiHwcjtE(TcuXX1oeE9lm1NL2GlyRSlO)AfS5DlQb4(CmsVT9J85wU800gR(CmsgkmWM3tt7RDi86xyQplTbxWwbRTGoHuqhvytx7RDEpwU)FT5XyHx7q41VWKWablcTwfcV(vPlOBXgzeyccPvqqlQb4wGofAVHmPqRV2HWRFHjHbIlyRcdI2qxlPqtyJf1aCl95yKcdI2qxlPqtytAAJfOBHWzZY2MmPixWMafq14xx9dL9JbHKir8V28ySjD406QajInsiklQfAjE5GJRDEpgo94yHXapwGOJnTT4yWTSPJ5n0X(LoggL3Cm9Jbb9JHp(wR0XSgG0XWOH2JzKxRSJncOtOJ5nXESCFU5ygAuIYp2JoggL38t)yXk)y5(Ct6AhcV(fMegiUGTklqytg14rkdfEJfc5cnP8ajJCiymTOgGrrzuei06PWyGPPnwG2dKmYtELrk)vMIYx8z9xz)16WKHgLOCjsAb6uO9gYKqVSjHL4Z6VY(R1Hjdnkr5wcwyRYcRRG20AWjyIJRDEpgo94y7FSWyGhdJsRpMPOJHr5n1EmVHo2sw3pwRZbAXXMq6ywBhwRJ97X6peEmmkV5N(XIv(XY95M01oeE9lmjmqCbBvwGWMmQXJugk8glQbyuugfbcTEkmgyQwlBDo4euugfbcTEkmgyYmrHx)IvlqNcT3qMe6LnjSeFw)v2FTomzOrjk3sWcBvwyDf0MwdobZRDEpMu6Wqhduspri5h73JHhUhJwkRiy6yw7L3CSWyGGIpM1aKownoM3qYpg0d5hB8OJLh4Emij(1ap2JownoM8FIo2sw3pMOjqYOJHrP1hRthdrHr(XQ9yELrhB8OJ5n0XwY6(XWiaHsx7q41VWKWaXfSvDDyi1qpri5wudWqBsRvEGKro0sW4Hvl95yK66WqQHEIqYttBSaDlOOmkceA9uymWez9c6qjsqrzuei06PWyGjeLf1cTmpKibfLrrGqRNcJbMQ1Yq41VPUomKAONiK8K4FT5XyXX1oeE9lmjmqCbBLSMh6A5kOJkSjlQbyXN1FL9xRdtgAuIYTemM42NJrQJ(WaldLM2x7RDi86xysyG4c2kSlTUwzkOnIilQbyqcufDnL66WqQHEIqYvq5RalOnP1kpqYihM66WqQHEIqYTetSOLqYKN8kJu(RYcRBjEx7q41VWKWaXfSvDDyifAcBSOgGbjqv01uQRddPg6jcjxbLVcSOLqYKN8kJu(RYcRBjEx7q41VWKWaXfSv2)Rvic(tKGSy8i1sw3bJ51oeE9lmjmqCbBf61AL3qQ(Ve0IAaUphJeA6nAccv2isuW63K5XyXQphJe61AL3qQ(Vemb9qGD(4DTdHx)ctcdexWwzquy66WqqlQbyXN1FL9xRdtgAuIYTmNRDi86xysyG4c2k73RFTOgG7ZXi11)B0tONquiCjs6ZXifgeTHUwsHMWM00(AN3JbkfADTYowpeyFm)pMHgXu7hRCk7ytyiJU2HWRFHjHbIlyRMqsvoLzXgzeyqcufDnPQ1PfwUCLSswaYRD1dfLwhETYuike(JSOgG7ZXi11)B0tONquiCjs8kJu(RmfLpy8YrIeXN1FL9xRdtgAuIYZhmEx7q41VWKWaXfSvtiPkNYGwudW95yK66)n6j0tikeUejELrk)vMIYhmE5irI4Z6VY(R1Hjdnkr55dgVRDi86xysyG4c2QU(FJAmrYV2HWRFHjHbIlyR6ecsiSRv21oeE9lmjmqCbB1Oqux)V5AhcV(fMegiUGTkwbbDuOvIqRV2HWRFHjHbIlyRGKnSGwudWEGKrEYRms5VYuKLyI31oeE9lmjmqCbB1esQYPmlOXGeUAJmcSqUq)o63sO66a6wudWTaDk0EdzsHwJvFogPWGOn01sk0e2Kmpglw95yKYOShjx9dLEkkJYGOidMmpglw0sizYtELrk)vzH1TSvyH8UQphdy(G61oeE9lmjmqCbB1esQYPml2iJah5c2eOaQg)6QFOSFmiKf1aCl95yKcdI2qxlPqtytAAJvl95yK66WqQHEIqYttBSe)RnpgBkmiAdDTKcnHnjeLf1cZhtq9AN3JzngHKFm0pL1OLFm0uth7hhZBMz9AuK5yzH3apwN0pgGIpM1aKo24rhdNEX2(nhtGk3IJ9EdHWOG0XWO8MJLBZDhl8JHxo4EmOhcSHh7rhdZCW9yyuEZXcn8pMu6)nhBANU2HWRFHjHbIlyRMqsvoLzXgze4a2asSeuHIC9iL4rH2IAa2q95yKqrUEKs8OqRmuFogjZJXkrIH6ZXij(1mfEbcPQfBLH6ZXinTXYdKmYtnuO9MKTWZV14HLhizKNAOq7njBHBj4wNJejTyO(CmsIFntHxGqQAXwzO(CmstBSaTH6ZXiHIC9iL4rHwzO(CmsqpeyBjy8YbNGzo4Cd1NJrQR)3O(HYBifTuM800wIKrjRXviklQfMFEMdoWQphJuyq0g6AjfAcBsiklQfAjM5X1oVhZArJyQ9JncTUhcSp24rhBcJUMow5ugmDTdHx)ctcdexWwnHKQCkdArna3NJrQR)3ONqpHOq4sKmkznUcrzrTW8bJxosKi(S(RS)ADyYqJsuE(GX7AFTZ7XafGqAfe8AhcV(fMiiKwbbbl(vqRJcNmQHoYilQbyAjKm5jVYiL)QSW6wIjwT0NJrQRddPg6jcjpnTXc0TyEpj(vqRJcNmQHoYivFI2KxcSRvgwTecV(nj(vqRJcNmQHoYOuTQHUK14sKmMATcrIMajJuELr5ltyszH1XX1oeE9lmrqiTccIlyR66)nQFO8gsrlLj3IAagKavrxtPUomKAONiKCfu(kWs8V28ySPo5yq0Q8gsrYjyAAJfibQIUMsDNuIFnLx)IfOH2KwR8ajJCyQRddPg6jcj3sW4jrckkJIaHwpfgdmvRLTcuXHejJswJRquwulmFWyMZ1oeE9lmrqiTccIlyRKndKPIv9dvKlc9EZ1oeE9lmrqiTccIlyRgVycjJkYfHkNuDkYSOgGH2KwR8ajJCyQRddPg6jcj3sW4jrckkJIaHwpfgdmvRL5zoy1sFogPWGOn01sk0e2KM2sKmkznUcrzrTW8XmNRDi86xyIGqAfeexWwzpr1qETYuDDaDlQbyOnP1kpqYihM66WqQHEIqYTemEsKGIYOiqO1tHXat1AzEMJejJswJRquwulmFmZ5AhcV(fMiiKwbbXfSvEdPMB)NRrnEKGSOgG7ZXiHib2AccvJhjO00wIK(CmsisGTMGq14rcsj(56ekb9qGD(yMZ1oeE9lmrqiTccIlyRqLTTMu1QG2HGU2HWRFHjccPvqqCbBfgpsBaHQvHi4VXkORDi86xyIGqAfeexWwLrzpsU6hk9uugLbrrg0IAaMwcjtE(TcuV259yGI(AZXYDuyxRSJbkPJmcESXJogzDsmD6yOyLrh7rhd7sRpwFogqlownoM9dHvxtPJLB1yeYHhZrYpM)htg5hZBOJPFmiOFmX)AZJXESEajZX(9ybirPJUMogTuwrW01oeE9lmrqiTccIlyRquyxRm1qhze0cHCHMuEGKroemMwudWEGKrEYRms5VYuu(yMavjsanO9ajJ8udfAVjzlClZJCKiXdKmYtnuO9MKTWZhmE5GdSaDi8cesrlLveemMsK4bsg5jVYiL)ktrwIN1eh4qIeq7bsg5jVYiL)kBHRWlhlBDoyb6q4fiKIwkRiiymLiXdKmYtELrk)vMISSvTch44AFTZ7XaLQTGnecETZ7XKYbfo2dcHowUZL6yic9An8yyuEZXSwuyGnVBvUvqhZrr5WJ9OJL7MEJMGWJLBqKOG1VPRDi86xyAuBbBa3jhdIwL3qksobTOgGbjqv01uQ7Ks8RP863RDi86xyAuBbBWfSvqDjivSgLPeKf1a8OK14keLf1cTSphJeuxcsfRrzkbLquwulelenqeSj6A6AN3JjLdkCmmkV5yEdDSCRGoM1G9XS28t0Xa0ebcDShDmRffgyZ7hZrr5W01oeE9lmnQTGn4c2Qo5yq0Q8gsrYjOf1aCKlcvoLcbPM2k5)ePGAIaHs0gDnzKijYfHkNsgkmWM3t0gDnzU2HWRFHPrTfSbxWwzkOD4IMR91oVhdWPq7nx7q41VWe0Pq7nGH6ykRXjKf1aCFogjOoMYACcPS)c(BY8ySx7q41VWe0Pq7n4c2krdf2kyZ7wiKl0KYdKmYHGX0IAa2dnTEYgrYv)Q8gsHbfyNOn6AYGvlEGKrEQGQ(dHx7q41VWe0Pq7n4c2QiRpHnCaqieS(LlnE5Gxo5Kh416uR4ayeOTwzqoaoDM9JCYCmq5JfcV(9y6c6W01MdOlOd54ZbiiKwbb54ZLgto(CaAJUMmCP4acu5eQcoaTesM8KxzKYFvwy9Jz5XW8yyDSwowFogPUomKAONiK800(yyDmqFSwoM59K4xbTokCYOg6iJu9jAtEjWUwzhdRJ1YXcHx)Me)kO1rHtg1qhzuQw1qxYA8JjrYXgtTwHirtGKrkVYOJL)XKjmPSW6hdhCGq41VCaXVcADu4Krn0rgXDU04XXNdqB01KHlfhqGkNqvWbajqv01uQRddPg6jcjxbLVIJH1Xe)RnpgBQtogeTkVHuKCcMM2hdRJbsGQORPu3jL4xt51VhdRJb6JbTjTw5bsg5Wuxhgsn0tes(XSe8XW7ysKCmuugfbcTEkmgyQ2Jz5XAfOEmCCmjso2OK14keLf1cpw(GpgM5WbcHx)Yb66)nQFO8gsrlLjN7CPBnhFoqi86xoGSzGmvSQFOICrO3B4a0gDnz4sXDU0TIJphG2ORjdxkoGavoHQGdaTjTw5bsg5Wuxhgsn0tes(XSe8XW7ysKCmuugfbcTEkmgyQ2Jz5XYZCogwhRLJ1NJrkmiAdDTKcnHnPP9XKi5yJswJRquwul8y5FmmZHdecV(LdmEXesgvKlcvoP6uKXDU0GkhFoaTrxtgUuCabQCcvbhaAtATYdKmYHPUomKAONiK8Jzj4JH3XKi5yOOmkceA9uymWuThZYJLN5Cmjso2OK14keLf1cpw(hdZC4aHWRF5a2tunKxRmvxhqN7CPZto(CaAJUMmCP4acu5eQcoqFogjejWwtqOA8ibLM2htIKJ1NJrcrcS1eeQgpsqkXpxNqjOhcSpw(hdZC4aHWRF5aEdPMB)NRrnEKG4oxAqzo(CGq41VCauzBRjvTkODiioaTrxtgUuCNlDEWXNdecV(LdGXJ0gqOAvic(BScIdqB01KHlf35sBn54ZbOn6AYWLIdiqLtOk4a0sizYpw(hRvGkhieE9lhiJYEKC1pu6POmkdIImi35sJzoC85a0gDnz4sXbcHx)YbquyxRm1qhzeKdiqLtOk4aEGKrEYRms5VYu0XY)yyMa1JjrYXa9Xa9X8ajJ8udfAVjzl8Jz5XYJCoMejhZdKmYtnuO9MKTWpw(GpgE5CmCCmSogOpwi8cesrlLve8yGpgMhtIKJ5bsg5jVYiL)ktrhZYJHN18y44y44ysKCmqFmpqYip5vgP8xzlCfE5CmlpwRZ5yyDmqFSq4fiKIwkRi4XaFmmpMejhZdKmYtELrk)vMIoMLhRvT6y44y4GdiKl0KYdKmYHCPXK7CNdyOrm1ohFU0yYXNdqB01KHlfhqGkNqvWbA5yqNcT3qMe6Lnjoqi86xoa2LaBUZLgpo(CGq41VCaOtH2B4a0gDnz4sXDU0TMJphG2ORjdxkoWBZbGKZbcHx)Ybajqv01ehaKqpjoG4Z6VY(R1Hjdnkr5hZsWhdVJH7XW7y48Jb6J5HMwpjR5HUwUc6OcBkrB01K5yyDmX)AZJXMK18qxlxbDuHnLquwul8y5FmmpgoogUhRphJuh9HbwgknTpgwhJwcjt(XS8y5zohdRJ1YX6ZXibXEQ1Qynkb6HW(VemnTpgwhRLJ1NJrcBISvY)jsHr5qv0)PRK)Z00MdasGuBKrCGiRpHnkXVMYRF5ox6wXXNdqB01KHlfh4T5aqY5aHWRF5aGeOk6AIdasONehOphJeA6nAccv2isuW6300(ysKCmqFSixeQCkzOWaBEprB01K5ysKCSixeQCkfcsnTvY)jsb1ebcLOn6AYCmCCmSowFogj0R1kVHu9FjyAAZbajqQnYioq3jL4xt51VCNlnOYXNdqB01KHlfh4T5aqY5aHWRF5aGeOk6AIdasONehaAtATYdKmYHPUomKAONiK8JL)XW7yyDmuugfbcTEkmgyQ2Jz5XWlNJjrYX6ZXi11HHud9eHKNM2CaqcKAJmId01HHud9eHKRGYxb35sNNC85a0gDnz4sXbeOYjufCaOtH2Bitk0Aoqi86xoGi0Avi86xLUGohqxqxTrgXbGofAVH7CPbL54ZbOn6AYWLIdecV(LdicTwfcV(vPlOZb0f0vBKrCaHbYDU05bhFoaTrxtgUuCabQCcvbhOphJejA(ALPqKnQYI1KM2hdRJ1NJrIenFTYuiYgvzXAsqpeyFmWht8z9xz)16WJjrYXeFw)v2FTo8ywc(ycBvwyDf0MwZXWjhd0hRphJuh9HbwgknTpgUhRphJ0BB)iFULlpnTpgoogo)yG(yEOP1t4SzjWwzqbgjAJUMmhdRJb6J1YX8qtRNYce2KrnEKYqH3KOn6AYCmjsoM4FT5XytzbcBYOgpszOWBsiklQfEmlpgMhdhhdhhdNFmqFSixeQCkfcsnTvY)jsb1ebcLqXI9XY)y4Dmjsowlht8V28ySPo5yq0Q8gsrYjyAAFmjsowlhRphJe61AL3qQ(VemnTpgo4aHWRF5aO5QcHx)Q0f05a6c6QnYioWO2c2WDU0wto(CaAJUMmCP4aHWRF5aIqRvHWRFv6c6CaDbD1gzehOplTH7CPXmho(CaAJUMmCP4acu5eQcoaTesM8KHgLO8Jzj4JHjOEmCpgTesM8eIKrlhieE9lhiqIyjL)ieTo35sJjMC85aHWRF5abselPSNAiXbOn6AYWLI7CPXepo(CGq41VCaDjRXHkqrMgzz06CaAJUMmCP4oxAmBnhFoqi86xoqpKP(HYrLaBihG2ORjdxkUZDoGnIeFwpCo(CPXKJphieE9lhOwOhRRS)c(lhG2ORjdxkUZLgpo(CGq41VCabQST11ktz)f8xoaTrxtgUuCNlDR54ZbcHx)Yb2zwVwzk7VG)YbOn6AYWLI7CPBfhFoaTrxtgUuCG3MdajNdecV(LdasGQORjoaiHEsCGW9qGTsGk)ywESCsTcpoaibsTrgXbEqiKczReOYvEdIGnV2WDU0GkhFoqi86xoG971VCaAJUMmCP4ox68KJphG2ORjdxkoqi86xoqwGWMmQXJugk8goGavoHQGdGIYOiqO1tHXat1EmlpwRYHdyJiXN1dxbjXVgihau5oxAqzo(CaAJUMmCP4acu5eQcoaOpwlhJWzZY2Mmj7xGn5WkxKrj(m7PhE9RYqGuc6ysKCSwoM4FT5Xytc5c97OFlHQRdONmtu41VhtIKJHIYOiqO1t1cYuVek6AkrwVGo8y4GdecV(LdaDk0Ed35sNhC85a0gDnz4sXbcHx)YbG6sqQynktjioGavoHQGdGObIGnrxthdRJ1NJrcQlbPI1OmLGsiklQfES8pMxzKYFLPOJH1X6ZXib1LGuXAuMsqjeLf1cpw(hd0hdZJH7XeFw)v2FTo8y44y48JHzkp4a2is8z9Wvqs8RbYbAn35sBn54ZbOn6AYWLIdecV(LdegeTHUwsHMWgoGavoHQGda6J1YXiC2SSTjtY(fytoSYfzuIpZE6Hx)QmeiLGoMejhRLJj(xBEm2KqUq)o63sO66a6jZefE97XKi5yOOmkceA9uTGm1lHIUMsK1lOdpgo4a2is8z9Wvqs8RbYbWK7CPXmho(CaAJUMmCP4aBKrCGixWMafq14xx9dL9JbH4aHWRF5arUGnbkGQXVU6hk7hdcXDU0yIjhFoaTrxtgUuCGq41VCa0R1kVHu9FjihWgrIpRhUcsIFnqoaECNlnM4XXNdqB01KHlfhieE9lhqixOFh9BjuDDaDoGavoHQGd0YXqrzuei06PAbzQxcfDnLiRxqhYbOXGeUAJmIdiKl0VJ(TeQUoGo35ohOplTHJpxAm54ZbcHx)YbirZxRmfISrvwSgoaTrxtgUuCNlnEC85a0gDnz4sXbeOYjufCaXN1FL9xRdtgAuIYpw(hdZJH7XmuFogjiHqHtgv)xsbTlSPe0db2CGq41VCaiHqHtgv)xsbTlSjUZLU1C85a0gDnz4sXbeOYjufCaqFmp006jC2SeyRmOaJeTrxtMJjrYXICrOYPe2ezRK)tKcJYHQO)txj)NjuSyFS8pgEhdhhdRJ1NJr6TTFKp3YLNM2hdRJb6J1NJrcBISvY)jsHr5qv0)PRK)Ze0db2hl)JHzRoMejhJwcjt(XY)yTcupgo4aHWRF5a2f0FTc28o35s3ko(CaAJUMmCP4acu5eQcoqFogP32(r(ClxEAAFmSowFogjdfgyZ7PPnhieE9lhWUG(RvWM35oxAqLJphieE9lhawBbDcPGoQWM4a0gDnz4sXDUZbGofAVHJpxAm54ZbOn6AYWLIdiqLtOk4a95yKG6ykRXjKY(l4VjZJXYbcHx)YbG6ykRXje35sJhhFoaTrxtgUuCGq41VCardf2kyZ7CabQCcvbhWdnTEYgrYv)Q8gsHbfyNOn6AYCmSowlhZdKmYtfu1FiKdiKl0KYdKmYHCPXK7CPBnhFoqi86xoqK1NWgoaTrxtgUuCN7CaHbYXNlnMC85a0gDnz4sXbeOYjufCGwog0Pq7nKjfAnhieE9lhqeATkeE9RsxqNdOlOR2iJ4aeesRGGCNlnEC85a0gDnz4sXbeOYjufCGwowFogPWGOn01sk0e2KM2hdRJb6J1YXiC2SSTjtkYfSjqbun(1v)qz)yqOJjrYXe)RnpgBshoTUkqIyJeIYIAHhZYJHxohdhCGq41VCGWGOn01sk0e2WDU0TMJphG2ORjdxkoqi86xoqwGWMmQXJugk8goGavoHQGdGIYOiqO1tHXatt7JH1Xa9X8ajJ8KxzKYFLPOJL)XeFw)v2FTomzOrjk)ysKCSwog0Pq7nKjHEzt6yyDmXN1FL9xRdtgAuIYpMLGpMWwLfwxbTP1CmCYXW8y4GdiKl0KYdKmYHCPXK7CPBfhFoaTrxtgUuCabQCcvbhafLrrGqRNcJbMQ9ywESwNZXWjhdfLrrGqRNcJbMmtu41VhdRJ1YXGofAVHmj0lBshdRJj(S(RS)ADyYqJsu(XSe8Xe2QSW6kOnTMJHtogMCGq41VCGSaHnzuJhPmu4nCNlnOYXNdqB01KHlfhqGkNqvWbG2KwR8ajJC4XSe8XW7yyDSwowFogPUomKAONiK800(yyDmqFSwogkkJIaHwpfgdmrwVGo8ysKCmuugfbcTEkmgycrzrTWJz5XYJJjrYXqrzuei06PWyGPApMLhleE9BQRddPg6jcjpj(xBEm2JHdoqi86xoqxhgsn0teso35sNNC85a0gDnz4sXbeOYjufCaXN1FL9xRdtgAuIYpMLGpgMhd3J1NJrQJ(WaldLM2CGq41VCaznp01YvqhvytCNlnOmhFoaTrxtgUuCabQCcvbhaKavrxtPUomKAONiKCfu(kogwhdAtATYdKmYHPUomKAONiK8Jz5XW8yyDmAjKm5jVYiL)QSW6hZYJHhhieE9lha7sRRvMcAJiI7CPZdo(CaAJUMmCP4acu5eQcoaibQIUMsDDyi1qpri5kO8vCmSogTesM8KxzKYFvwy9Jz5XWJdecV(Ld01HHuOjSH7CPTMC85a0gDnz4sXbgpsTK1DU0yYbcHx)YbS)xRqe8NibXDU0yMdhFoaTrxtgUuCabQCcvbhOphJeA6nAccv2isuW63K5XypgwhRphJe61AL3qQ(Vemb9qG9XY)y4XbcHx)YbqVwR8gs1)LGCNlnMyYXNdqB01KHlfhqGkNqvWbeFw)v2FTomzOrjk)ywESC4aHWRF5agefMUomeK7CPXepo(CaAJUMmCP4acu5eQcoqFogPU(FJEc9eIcHFmjsowFogPWGOn01sk0e2KM2CGq41VCa73RF5oxAmBnhFoaTrxtgUuCGq41VCaqcufDnPQ1PfwUCLSswaYRD1dfLwhETYuike(J4acu5eQcoqFogPU(FJEc9eIcHFmjsoMxzKYFLPOJLp4JHxohtIKJj(S(RS)ADyYqJsu(XYh8XWJdSrgXbajqv01KQwNwy5YvYkzbiV2vpuuAD41ktHOq4pI7CPXSvC85a0gDnz4sXbeOYjufCG(CmsD9)g9e6jefc)ysKCmVYiL)ktrhlFWhdVCoMejht8z9xz)16WKHgLO8JLp4JHhhieE9lhycjv5ugK7CPXeu54ZbcHx)Yb66)nQXejNdqB01KHlf35sJzEYXNdecV(Ld0jeKqyxRmoaTrxtgUuCNlnMGYC85aHWRF5aJcrD9)goaTrxtgUuCNlnM5bhFoqi86xoqScc6OqReHwZbOn6AYWLI7CPX0AYXNdqB01KHlfhqGkNqvWb8ajJ8KxzKYFLPOJz5XWepoqi86xoaKSHfK7CPXlho(CaAJUMmCP4aHWRF5ac5c97OFlHQRdOZbeOYjufCGwog0Pq7nKjfA9XW6y95yKcdI2qxlPqtytY8yShdRJ1NJrkJYEKC1pu6POmkdIImyY8yShdRJrlHKjp5vgP8xLfw)ywESwDmSogY7Q(CmGhl)JbQCaAmiHR2iJ4ac5c97OFlHQRdOZDU04HjhFoaTrxtgUuCGq41VCGixWMafq14xx9dL9JbH4acu5eQcoqlhRphJuyq0g6AjfAcBst7JH1XA5y95yK66WqQHEIqYtt7JH1Xe)RnpgBkmiAdDTKcnHnjeLf1cpw(hdtqLdSrgXbICbBcuavJFD1pu2pgeI7CPXdpo(CaAJUMmCP4aHWRF5abSbKyjOcf56rkXJcnhqGkNqvWbmuFogjuKRhPepk0kd1NJrY8yShtIKJzO(CmsIFntHxGqQAXwzO(Cmst7JH1X8ajJ8udfAVjzl8JL)XAnEhdRJ5bsg5Pgk0EtYw4hZsWhR15CmjsowlhZq95yKe)AMcVaHu1ITYq95yKM2hdRJb6JzO(CmsOixpsjEuOvgQphJe0db2hZsWhdVCogo5yyMZXW5hZq95yK66)nQFO8gsrlLjpnTpMejhBuYACfIYIAHhl)JLN5CmCCmSowFogPWGOn01sk0e2Kquwul8ywEmmZdoWgzehiGnGelbvOixpsjEuO5oxA8AnhFoaTrxtgUuCabQCcvbhOphJux)VrpHEcrHWpMejhBuYACfIYIAHhlFWhdVCoMejht8z9xz)16WKHgLO8JLp4JHhhieE9lhycjv5ugK7CNdmQTGnC85sJjhFoaTrxtgUuCabQCcvbhaKavrxtPUtkXVMYRF5aHWRF5aDYXGOv5nKIKtqUZLgpo(CaAJUMmCP4acu5eQcoWOK14keLf1cpMLhRphJeuxcsfRrzkbLquwul8yyDmenqeSj6AIdecV(Lda1LGuXAuMsqCNlDR54ZbOn6AYWLIdiqLtOk4arUiu5ukeKAARK)tKcQjcekrB01K5ysKCSixeQCkzOWaBEprB01KHdecV(Ld0jhdIwL3qksob5ox6wXXNdecV(LdykOD4IgoaTrxtgUuCN7CNdetV5rCaGkl3ZDUZ5a]] )

end