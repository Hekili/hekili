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


    spec:RegisterPack( "Outlaw", 20200823.4, [[d40OfbqiPepsOQ2euXNOijPrbqDkOeRcGuVcQ0SOiUfaj7sWVOOAycLogu0YGQ8mPKAAaexdkjBtOk9nPKW4OiX5OiPwNussZtOY9a0(OOCqHQWcjsEOqv0efkIlkLeTrPKuJukjrNekP0kLs9skss1nfksANeP(jusXqfkkhLIKelvOO6PanvOQUkfjXwPijLVkuK6Scfj2lQ(ljdgLdlAXs1JjmzsDzKnRWNjkJwkoTKvlLKWRHsnBkDBHSBL(TkdNchhkPA5qEoOPt11v02bW3HcJNIuNNOA9cfMprSFvnhto(CqD6exA8IfVyJ1uWR1bmn1yfEX2k4GUCdIdAKcStzehCZiIdI1mDBIbh0iLBVuZXNdcVjsqCWg3nGTQMBUSYBM9G4ImhwrtB61TcuoCZHvKWCoyFwwhRD5DoOoDIlnEXIxSXAk416aMMAScVyJxoi0GeCPXlEJLd2uAnT8ohutqbhm(pdRz62eJNfZpzt6Bh)NfZqKTIQnrYFgytQpmS5QHpBAOtNcCqd0nklXbJ)ZWAMUnX4zX8t2K(2X)zXmezROAtK8Nb2K6ddBUA4ZMg60PW3(Bh)N1knnjMoPFwNghIEM4I6P)SojRwy4zXdHGmC4Z2BbunjkAmTplfEDl8z3ALh(2X)zPWRBHbdejUOE6ah2eI93o(plfEDlmyGiXf1thxGMNtzr06Px3(TJ)ZsHx3cdgisCr90XfO5J70F74)mWnnGnN)muw6N1NJbPFg0th(Sonoe9mXf1t)zDswTWNLR(zgicqzCUxRSNvWNPVLcF74)Su41TWGbIexupDCbAoCtdyZ5kONo8BNcVUfgmqK4I6PJlqZRf656kJRG3(TtHx3cdgisCr90XfO5cuzyyRvMY4k4TF7u41TWGbIexupDCbA(oJ61ktzCf82VDk86wyWarIlQNoUanhGevz3sMSzeb8aGqkKHsGkx5nic2CwTjaK2jbmDpfyReOYnl2aGG33ofEDlmyGiXf1thxGMBCED73ofEDlmyGiXf1thxGMhLiSjTACiLMsVXedejUOE6kijUvdbIvMudGOS0kcaA9qQ1WqTMbiX(TtHx3cdgisCr90XfO5qNsR3ysnac4wiS(SmmiDW4eytoSIbPvIlYy6Px3Q0eaLGKiPfXDw9HXgeYf2Zr3wcv3MqpONO0RBLibLLwraqRhQfGPDju2TuGmDbDiw(2PWRBHbdejUOE64c0COTeKkxTsxcYedejUOE6kijUvdb2AtQbW(CmcqBjivUALUeuarrzTW48kIu(P0fHtFogbOTeKkxTsxckGOOSwyCagtCfxu)ugxToelaAmdMY3ofEDlmyGiXf1thxGMNAeTPTwsHMWgtmqK4I6PRGK4wneiMMudGaUfcRplddshmob2KdRyqAL4ImME61TknbqjijsArCNvFySbHCH9C0TLq1Tj0d6jk96wjsqzPvea06HAbyAxcLDlfitxqhILVDk86wyWarIlQNoUanFcjv5uKjBgraZyaBsucvJBD1nughge6BNcVUfgmqK4I6PJlqZrN1Q8gs1VLGMyGiXf1txbjXTAiq8(2PWRBHbdejUOE64c08jKuLtrMqJbjC1MreqHCH9C0TLq1Tj0nPgaBbLLwraqRhQfGPDju2TuGmDbD43(Bh)N1knnjMoPFgbaHK)mVION5n0ZsHFONvWNLaKLn7wk8TJ)ZI5e0P06npRgpZ4GWQBPNb49Egat7sOSBPNrlfve8z1(mXf1thlF7u41TqGyxcSnPgaBb6uA9gshqNSj9TtHx3cbcDkTEZ3ofEDlexGMdqIQSBjt2mIaMr9jSrjUvxEDRjaK2jbuCr9tzC16WGMgLOCZaIhU4bObSNwA9GSMd6w5kOJkSPaTz3sACe3z1hgBqwZbDRCf0rf2uarrzTW4Wel42NJrOJUudlnfMg4qlHKj3S4nwCAPphJae7P1QYvReOdc73sWW0aNw6ZXiGnrgk53ePWOCOk730vYVzyA8TtHx3cXfO5aKOk7wYKnJiGDNuIB1Lx3AcaPDsa7ZXiGMEJLGqLbIefSUnmnKibWzmiu5uqtPg2CEG2SBjTejzmiu5uifKAAOKFtKcAjcakqB2TKgl40NJraDwRYBiv)wcgMgF74)Sy6YBEw006LHLEMNizKdn5zEtbFgajQYULEwbFMOHeyt6N53Z0KO00ZWOH8gc9m4frplEgtGpd2CtR(zD6zq5RG0pdJYBEMu2utpRvBNiK8VDk86wiUanhGevz3sMSzebSBtnPg2jcjxbLVctaiTtci0GSwLNizKddDBQj1Wori5XHhoOS0kcaA9qQ1WqTMHxSsK0NJrOBtnPg2jcjpmn(2PWRBH4c0CrATQu41TkBbDt2mIacDkTEJj1ai0P06nKoKw73ofEDlexGMlsRvLcVUvzlOBYMreqHg(TJ)ZA11wWMNvJN1kJ5pd6Pa7NfLUOHqWNDONL(ZIstxrZONfpJzHNbo7qhLc)z3spBCONrPO5zsHUudln9SC1pdRXW4q(Clx(ZWOH2NzQYSey)SyckX4zf8zqYscN0plx9ZIPoIjpRGpBp)zik1YFwoCc9mVHE2sM2FgKe3QdplEyXiLdFwuA6NjL3kFggL38m8W9zXdbf(2PWRBH4c0C0CvPWRBv2c6MSzebCuBbBmPga7ZXiqIMRwzkezGQOC1HPbo95yeirZvRmfImqvuU6a0tb2afxu)ugxTouIeXf1pLXvRdndOWqfLMwbnOvdOaCFogHo6snS0uyAGBFogHZW4q(ClxEyAGfanG90sRhW6ZsGTsJsmc0MDlPXbWT4PLwpeLiSjTACiLMsVjqB2TKwIeXDw9HXgIse2KwnoKstP3equuwl0mmXcwa0aoJbHkNcPGutdL8BIuqlraqbuUyhhEsK0I4oR(WydDYXGOv5nKIKtWW0qIKw6ZXiGoRv5nKQFlbdtdS8TtHx3cXfO5I0AvPWRBv2c6MSzebSplR(BNcVUfIlqZtKixs5hcrRBsnaslHKjpOPrjk3mGyIv4slHKjpGiz0(TtHx3cXfO5jsKlPmMwi9TtHx3cXfO52swJdvTkMAzr06F7u41TqCbAEpLPUHYrLaB43(Bh)Nj1SSAcb)2PWRBHH(SSAGKO5QvMcrgOkkx93ofEDlm0NLvJlqZHecLoPv9Bjf0OWMmPgafxu)ugxTomOPrjkpomXvt95yeGecLoPv9Bjf0OWMcqpfy)TJ)ZmvG0ZIzf0p7ZaBo)z14zL)mmU1uv)zI04zIlQFpZ4Q1Hplx9Z8g6zyngghYNB5YFwFogpRGpBAeEw8aGR0pBcRv2ZWOH2NzQorgplMYnrplMUC4ZGEkWg(SerpRPK18Sd9mmAO9ztyTYEwmnLg3gLqNqM8S5Aji8zEd9SycLAyZ5pRphJNvWNnncF7u41TWqFwwnUan3OG(zvWMZnPgabSNwA9awFwcSvAuIrG2SBjTejzmiu5uaBImuYVjsHr5qv2VPRKFZakxSJdpSGtFogHZW4q(ClxEyAGdG7ZXiGnrgk53ePWOCOk730vYVza6Pa74WeqKiHwcjtECacwHLVDk86wyOplRgxGMBuq)SkyZ5MudG95yeodJd5ZTC5HPbo95ye0uQHnNhMgF7u41TWqFwwnUanhwBbDcPGoQWM(2F74)S45Dw9HXc)2PWRBHbHgcuKwRkfEDRYwq3KnJiGeesRGGMudGTaDkTEdPdP1(TtHx3cdcnexGMNAeTPTwsHMWgtQbWw6ZXiKAeTPTwsHMWMW0aha3cH1NLHbPdzmGnjkHQXTU6gkJddcjrI4oR(Wyd20P1vjsKBgquuwl0m8IflF74)mS2XZsTg(SerpBAyYZGBzqpZBONDl9mmkV5z2ddc6pdF8JjHNzQaPNHrdTptlVwzpBKqNqpZBY9zXZy2Z00OeL)Sd9mmkV5M(ZYv(ZINXSW3ofEDlmi0qCbAEuIWM0QXHuAk9gteYfws5jsg5qGyAsnaIYsRiaO1dPwddtdCaSNizKh8kIu(P0ffN4I6NY4Q1Hbnnkr5sK0c0P06nKoGoztchXf1pLXvRddAAuIYndOWqfLMwbnOvdOWelF74)mS2XZ27zPwdFggL1(mDrpdJYBQ9zEd9SLmT)Swhl0KNnH0ZIPoIjp72N1pi8zyuEZn9NLR8NfpJzHVDk86wyqOH4c08OeHnPvJdP0u6nMudGOS0kcaA9qQ1WqTM16ybuOS0kcaA9qQ1WGEIsVUfNwGoLwVH0b0jBs4iUO(PmUADyqtJsuUzafgQO00kObTAafMF74)mPSPMEwR2ori5p72NHhUpJwkQiy4zX0L38SuRHTQpZubspRgpZBi5pd6P8Nno0ZmfCFgKe3QHp7qpRgpt(nrpBjt7pt0Kiz0ZWOS2N1PNHOul)z1(mVIONno0Z8g6zlzA)zyKaqHVDk86wyqOH4c08Un1KAyNiKCtQbqObzTkprYihAgq8WPL(CmcDBQj1Wori5HPboaUfuwAfbaTEi1AyGmDbDOejOS0kcaA9qQ1WaIIYAHMzksKGYsRiaO1dPwdd1Awk862q3MAsnStesEqCNvFySy5BNcVUfgeAiUanxwZbDRCf0rf2Kj1aO4I6NY4Q1Hbnnkr5MbetC7ZXi0rxQHLMctJV93ofEDlmi0qCbAo2L1wRmf0arKj1aiajQYULcDBQj1Wori5kO8vGd0GSwLNizKddDBQj1Wori5MHjo0sizYdEfrk)urPPndVVDk86wyqOH4c08Un1KcnHnMudGaKOk7wk0TPMud7eHKRGYxbo0sizYdEfrk)urPPndVVDk86wyqOH4c0CJ7SkebVjsqMmoKAjt7aX8BNcVUfgeAiUanhDwRYBiv)wcAsna2NJran9glbHkdejkyDBqFyS40NJraDwRYBiv)wcgGEkWoo8(2PWRBHbHgIlqZ1ik1DBQjOj1aO4I6NY4Q1Hbnnkr5Mf73ofEDlmi0qCbAUX51TMudG95ye62702j0dikfUej95yesnI20wlPqtytyA8TJ)ZA1P1wRSN1tb2pZVNPProT(ZkNIE2eMYOVDk86wyqOH4c08jKuLtrMSzebeGevz3sQADAHLlxjRKLaCwxDqrzTPxRmfIsHFitQbW(CmcD7DA7e6beLcxIeVIiLFkDrXbeVyLirCr9tzC16WGMgLO84aI33ofEDlmi0qCbA(esQYPiOj1ayFogHU9oTDc9aIsHlrIxrKYpLUO4aIxSsKiUO(PmUADyqtJsuECaX7BNcVUfgeAiUanVBVtRgtK8VDk86wyqOH4c08oHGec7AL9TtHx3cdcnexGMpke1T3P)2PWRBHbHgIlqZZvqqhLwLiT2VDk86wyqOH4c0CizalOj1aONizKh8kIu(P0fzgM49TtHx3cdcnexGMpHKQCkYeAmiHR2mIakKlSNJUTeQUnHUj1aylqNsR3q6qAT40NJri1iAtBTKcnHnb9HXItFogHik6qYv3qzNIsR0ikJGb9HXIdTesM8GxrKYpvuAAZaeCqEx1NJbmoS6BNcVUfgeAiUanFcjv5uKjBgraZyaBsucvJBD1nughgeYKAaSL(CmcPgrBARLuOjSjmnWPL(CmcDBQj1Wori5HPboI7S6dJnKAeTPTwsHMWMaIIYAHXHjw9TJ)ZmvJqYFg6MYASYFgAAPNDJN5nZOEnks)SO0BGpRt2dJw1NzQaPNno0ZWAxSno9ZeOYn5zN3qimki9mmkV5zXJy(Zs)z4flUpd6PaB4Zo0ZWmwCFggL38S0cVNjL9o9ZMgHVDk86wyqOH4c08jKuLtrMSzebmHnaKlbvOmghsjouAnPga1uFogbugJdPehkTkn1NJrqFySsKOP(CmcIB1tHxaqQAXwPP(CmctdC8ejJ8qdLwVjyi84AnE44jsg5HgkTEtWq4MbS1XkrslAQphJG4w9u4faKQwSvAQphJW0ahaRP(CmcOmghsjouAvAQphJa0tb2MbeVybuyglGwt95ye6270QBO8gsrlfjpmnKizuYACfIIYAHXfVXIfC6ZXiKAeTPTwsHMWMaIIYAHMHPP8TJ)ZIj0iNw)zJ0A7Pa7Nno0ZMWSBPNvofbdF7u41TWGqdXfO5tiPkNIGMudG95ye62702j0dikfUejJswJRquuwlmoG4fRejIlQFkJRwhg00OeLhhq8(2F74)SwjesRGGF7u41TWabH0kiiqXTcADu6KwnSzezsnaslHKjp4veP8tfLM2mmXPL(CmcDBQj1Wori5HPboaUf95bXTcADu6KwnSzeP6t0g8sGDTYWPLu41TbXTcADu6KwnSzefQvnSLSgxIKX0Avis0KizKYRikozcDiknnw(2PWRBHbccPvqqCbAE3ENwDdL3qkAPi5MudGaKOk7wk0TPMud7eHKRGYxboI7S6dJn0jhdIwL3qksobdtdCairv2TuO7KsCRU86wCam0GSwLNizKddDBQj1Wori5MbepjsqzPvea06HuRHHAndqWkSirYOK14kefL1cJdiMX(TtHx3cdeesRGG4c0CzZePRCv3qLXGqN38TtHx3cdeesRGG4c08XjMqsRYyqOYjvNYitQbqObzTkprYihg62utQHDIqYndiEsKGYsRiaO1dPwdd1Aw8gloT0NJri1iAtBTKcnHnHPHejJswJRquuwlmomJ9BNcVUfgiiKwbbXfO5gtunKxRmv3Mq3KAaeAqwRYtKmYHHUn1KAyNiKCZaINejOS0kcaA9qQ1WqTMfVXkrYOK14kefL1cJdZy)2PWRBHbccPvqqCbAU3qQ52V5QvJdjitQbW(CmcisGTLGq14qckmnKiPphJaIeyBjiunoKGuIBUoHcqpfyhhMX(TtHx3cdeesRGG4c0CuzyyjvTkOrkOVDk86wyGGqAfeexGMJXHSAaOAvicEBUc6BNcVUfgiiKwbbXfO5ru0HKRUHYofLwPrugbnPgaPLqYKhhGGvF74)SwLNv)SyoLg1k7zTABgrWNno0ZittIPtpdLRm6zh6zyxw7Z6ZXaAYZQXZmoiS6wk8S4HfJuo8zos(Z87zYi)zEd9m7Hbb9NjUZQpm2N1tiPF2TplbilB2T0ZOLIkcg(2PWRBHbccPvqqCbAoIsJALPg2mIGMiKlSKYtKmYHaX0KAa0tKmYdEfrk)u6IIdZawjrcGbSNizKhAO06nbdHBMPeRejEIKrEOHsR3emeECaXlwSGdGtHxaqkAPOIGaXuIeprYip4veP8tPlYm8m1yblsKayprYip4veP8tziCfEXAwRJfhaNcVaGu0srfbbIPejEIKrEWRis5NsxKzacGGfS8T)2X)zT6AlydHGF74)mP8w5Zoai0ZI5UupdrOZAHpdJYBEwmHsnS5CZJhc6zoklh(Sd9Sy(0BSee(SygIefSUn8TtHx3cdJAlydWo5yq0Q8gsrYjOj1aiajQYULcDNuIB1Lx3(TtHx3cdJAlydUanhAlbPYvR0LGmPga7ZXiqIMRwzkezGQOC1b9HXkrsFogbs0C1ktHidufLRoa9uGDlafxu)ugxToeN(CmcqBjivUALUeuarrzTW4gLSgxHOOSwio95yeG2sqQC1kDjOaIIYAHXbymXvCr9tzC16qSaOXmykF74)mP8w5ZWO8MN5n0ZIhc6zMkgplMYnrpd0sea0Zo0ZIjuQHnN)mhLLddF7u41TWWO2c2GlqZ7KJbrRYBifjNGMudGzmiu5uifKAAOKFtKcAjcakqB2TKwIKmgeQCkOPudBopqB2TK(BNcVUfgg1wWgCbAUUGgPlA(2F74)mqNsR38TtHx3cdqNsR3aeAZPSgNqMudG95yeG2CkRXjKY4k4Tb9HX(TtHx3cdqNsR3GlqZfnuAOGnNBIqUWskprYihcettQbqpT06bdejxDRYBifguIDG2SBjnoT4jsg5HcQ6he(TtHx3cdqNsR3GlqZZO(e2WbbGqW6wU04flEXgRPGxRdTMdIrI2ALb5GyTrghYj9ZAfplfED7ZSf0HHVnhmNEZH4GGvu8KdAlOd54ZbjiKwbb54ZLgto(CqAZUL0CP4Gcu5eQsoiTesM8GxrKYpvuA6Nz2ZW8z48SwEwFogHUn1KAyNiK8W04z48ma)SwEM(8G4wbTokDsRg2mIu9jAdEjWUwzpdNN1YZsHx3ge3kO1rPtA1WMruOw1WwYA8NjrYZgtRvHirtIKrkVIONf3ZKj0HO00pdlCWu41TCqXTcADu6KwnSzeXDU04XXNdsB2TKMlfhuGkNqvYbbirv2TuOBtnPg2jcjxbLVINHZZe3z1hgBOtogeTkVHuKCcgMgpdNNbqIQSBPq3jL4wD51TpdNNb4NbniRv5jsg5Wq3MAsnStes(Zmd4ZW7zsK8muwAfbaTEi1AyO2Nz2ZaeS6zy5zsK8SrjRXvikkRf(S4a(mmJLdMcVULd2T3Pv3q5nKIwkso35s3Ao(CWu41TCqzZePRCv3qLXGqN3WbPn7wsZLI7CPbeo(CqAZUL0CP4Gcu5eQsoi0GSwLNizKddDBQj1Wori5pZmGpdVNjrYZqzPvea06HuRHHAFMzplEJ9z48SwEwFogHuJOnT1sk0e2eMgptIKNnkznUcrrzTWNf3ZWmwoyk86wo44etiPvzmiu5KQtze35sJvC85G0MDlP5sXbfOYjuLCqObzTkprYihg62utQHDIqYFMzaFgEptIKNHYsRiaO1dPwdd1(mZEw8g7ZKi5zJswJRquuwl8zX9mmJLdMcVULdAmr1qETYuDBcDUZLoE54ZbPn7wsZLIdkqLtOk5G95yeqKaBlbHQXHeuyA8mjsEwFogbejW2sqOACibPe3CDcfGEkW(zX9mmJLdMcVULd6nKAU9BUA14qcI7CPBfC85GPWRB5GOYWWsQAvqJuqCqAZUL0CP4oxAtHJphmfEDlheJdz1aq1Qqe82CfehK2SBjnxkUZL2uZXNdsB2TKMlfhuGkNqvYbPLqYK)S4EgGGvCWu41TCWik6qYv3qzNIsR0ikJGCNlnMXYXNdsB2TKMlfhmfEDlherPrTYudBgrqoOavoHQKd6jsg5bVIiLFkDrplUNHzaREMejpdWpdWpZtKmYdnuA9MGHWFMzpZuI9zsK8mprYip0qP1Bcgc)zXb8z4f7ZWYZW5za(zPWlaifTuurWNb8zy(mjsEMNizKh8kIu(P0f9mZEgEM6NHLNHLNjrYZa8Z8ejJ8GxrKYpLHWv4f7Zm7zTo2NHZZa8ZsHxaqkAPOIGpd4ZW8zsK8mprYip4veP8tPl6zM9mabqEgwEgw4Gc5clP8ejJCixAm5o35GAAKtRZXNlnMC85G0MDlP5sXbfOYjuLCWwEg0P06nKoGoztIdMcVULdIDjWM7CPXJJphmfEDlhe6uA9goiTz3sAUuCNlDR54ZbPn7wsZLIdEgCqi5CWu41TCqasuLDlXbbiTtIdkUO(PmUADyqtJsu(Zmd4ZW7z4(m8EgG(za(zEAP1dYAoOBLRGoQWMc0MDlPFgoptCNvFySbznh0TYvqhvytbefL1cFwCpdZNHLNH7Z6ZXi0rxQHLMctJNHZZOLqYK)mZEw8g7ZW5zT8S(CmcqSNwRkxTsGoiSFlbdtJNHZZA5z95yeWMidL8BIuyuouL9B6k53mmn4GaKi1MrehmJ6tyJsCRU86wUZLgq44ZbPn7wsZLIdEgCqi5CWu41TCqasuLDlXbbiTtId2NJran9glbHkdejkyDByA8mjsEgGFwgdcvof0uQHnNhOn7ws)mjsEwgdcvofsbPMgk53ePGwIaGc0MDlPFgwEgopRphJa6SwL3qQ(Temmn4GaKi1MrehS7KsCRU86wUZLgR44ZbPn7wsZLIdEgCqi5CWu41TCqasuLDlXbbiTtIdcniRv5jsg5Wq3MAsnStes(ZI7z49mCEgklTIaGwpKAnmu7Zm7z4f7ZKi5z95ye62utQHDIqYdtdoiajsTzeXb72utQHDIqYvq5RG7CPJxo(CqAZUL0CP4Gcu5eQsoi0P06nKoKwlhmfEDlhuKwRkfEDRYwqNdAlOR2mI4GqNsR3WDU0Tco(CqAZUL0CP4GPWRB5GI0AvPWRBv2c6CqBbD1MrehuOHCNlTPWXNdsB2TKMlfhuGkNqvYb7ZXiqIMRwzkezGQOC1HPXZW5z95yeirZvRmfImqvuU6a0tb2pd4Zexu)ugxTo8zsK8mXf1pLXvRdFMzaFMWqfLMwbnOv)ma1Za8Z6ZXi0rxQHLMctJNH7Z6ZXiCgghYNB5YdtJNHLNbOFgGFMNwA9awFwcSvAuIrG2SBj9ZW5za(zT8mpT06HOeHnPvJdP0u6nbAZUL0ptIKNjUZQpm2quIWM0QXHuAk9MaIIYAHpZSNH5ZWYZWYZa0pdWplJbHkNcPGutdL8BIuqlraqbuUy)S4EgEptIKN1YZe3z1hgBOtogeTkVHuKCcgMgptIKN1YZ6ZXiGoRv5nKQFlbdtJNHfoyk86woiAUQu41TkBbDoOTGUAZiIdoQTGnCNlTPMJphK2SBjnxkoyk86woOiTwvk86wLTGoh0wqxTzeXb7ZYQ5oxAmJLJphK2SBjnxkoOavoHQKdslHKjpOPrjk)zMb8zyIvpd3NrlHKjpGiz0YbtHx3YbtKixs5hcrRZDU0yIjhFoyk86woyIe5skJPfsCqAZUL0CP4oxAmXJJphmfEDlh0wYACOQvXullIwNdsB2TKMlf35sJzR54ZbtHx3Yb7Pm1nuoQeyd5G0MDlP5sXDUZbnqK4I6PZXNlnMC85GPWRB5G1c9CDLXvWB5G0MDlP5sXDU04XXNdMcVULdkqLHHTwzkJRG3YbPn7wsZLI7CPBnhFoyk86wo4oJ61ktzCf8woiTz3sAUuCNlnGWXNdsB2TKMlfh8m4GqY5GPWRB5GaKOk7wIdcqANehmDpfyReOYFMzpl2aGGhheGeP2mI4GhaesHmucu5kVbrWMZQ5oxASIJphmfEDlh0486woiTz3sAUuCNlD8YXNdsB2TKMlfhmfEDlhmkrytA14qknLEdhuGkNqvYbrzPvea06HuRHHAFMzpdqILdAGiXf1txbjXTAiheR4ox6wbhFoiTz3sAUuCqbQCcvjheWpRLNry9zzyq6GXjWMCyfdsRexKX0tVUvPjakb9mjsEwlptCNvFySbHCH9C0TLq1Tj0d6jk962NjrYZqzPvea06HAbyAxcLDlfitxqh(mSWbtHx3YbHoLwVH7CPnfo(CqAZUL0CP4GPWRB5GqBjivUALUeehuGkNqvYb7ZXiaTLGu5Qv6sqbefL1cFwCpZRis5Nsx0ZW5z95yeG2sqQC1kDjOaIIYAHplUNb4NH5ZW9zIlQFkJRwh(mS8ma9ZWmykCqdejUOE6kijUvd5GTM7CPn1C85G0MDlP5sXbtHx3YbtnI20wlPqtydhuGkNqvYbb8ZA5zewFwggKoyCcSjhwXG0kXfzm90RBvAcGsqptIKN1YZe3z1hgBqixyphDBjuDBc9GEIsVU9zsK8muwAfbaTEOwaM2Lqz3sbY0f0HpdlCqdejUOE6kijUvd5GyYDU0yglhFoiTz3sAUuCWnJioygdytIsOACRRUHY4WGqCWu41TCWmgWMeLq14wxDdLXHbH4oxAmXKJphK2SBjnxkoyk86woi6SwL3qQ(TeKdAGiXf1txbjXTAihepUZLgt844ZbPn7wsZLIdMcVULdkKlSNJUTeQUnHohuGkNqvYbB5zOS0kcaA9qTamTlHYULcKPlOd5G0yqcxTzeXbfYf2Zr3wcv3MqN7CNdoQTGnC85sJjhFoiTz3sAUuCqbQCcvjheGevz3sHUtkXT6YRB5GPWRB5GDYXGOv5nKIKtqUZLgpo(CqAZUL0CP4Gcu5eQsoyFogbs0C1ktHidufLRoOpm2NjrYZ6ZXiqIMRwzkezGQOC1bONcSFwlaFM4I6NY4Q1HpdNN1NJraAlbPYvR0LGcikkRf(S4E2OK14kefL1cFgopRphJa0wcsLRwPlbfquuwl8zX9ma)mmFgUptCr9tzC16WNHLNbOFgMbtHdMcVULdcTLGu5Qv6sqCNlDR54ZbPn7wsZLIdkqLtOk5Gzmiu5uifKAAOKFtKcAjcakqB2TK(zsK8SmgeQCkOPudBopqB2TKMdMcVULd2jhdIwL3qksob5oxAaHJphmfEDlhuxqJ0fnCqAZUL0CP4o35GqNsR3WXNlnMC85G0MDlP5sXbfOYjuLCW(CmcqBoL14eszCf82G(Wy5GPWRB5GqBoL14eI7CPXJJphK2SBjnxkoyk86woOOHsdfS5CoOavoHQKd6PLwpyGi5QBvEdPWGsSd0MDlPFgopRLN5jsg5HcQ6heYbfYfws5jsg5qU0yYDU0TMJphmfEDlhmJ6tydhK2SBjnxkUZDoOqd54ZLgto(CqAZUL0CP4Gcu5eQsoylpd6uA9gshsRLdMcVULdksRvLcVUvzlOZbTf0vBgrCqccPvqqUZLgpo(CqAZUL0CP4Gcu5eQsoylpRphJqQr0M2AjfAcBctJNHZZa8ZA5zewFwggKoKXa2KOeQg36QBOmomi0ZKi5zI7S6dJnytNwxLirUzarrzTWNz2ZWl2NHfoyk86woyQr0M2AjfAcB4ox6wZXNdsB2TKMlfhmfEDlhmkrytA14qknLEdhuGkNqvYbrzPvea06HuRHHPXZW5za(zEIKrEWRis5Nsx0ZI7zIlQFkJRwhg00OeL)mjsEwlpd6uA9gshqNSj9mCEM4I6NY4Q1Hbnnkr5pZmGptyOIstRGg0QFgG6zy(mSWbfYfws5jsg5qU0yYDU0achFoiTz3sAUuCqbQCcvjheLLwraqRhsTggQ9zM9Swh7ZaupdLLwraqRhsTgg0tu61TpdNN1YZGoLwVH0b0jBspdNNjUO(PmUADyqtJsu(Zmd4ZegQO00kObT6NbOEgMCWu41TCWOeHnPvJdP0u6nCNlnwXXNdsB2TKMlfhuGkNqvYbHgK1Q8ejJC4Zmd4ZW7z48SwEwFogHUn1KAyNiK8W04z48ma)SwEgklTIaGwpKAnmqMUGo8zsK8muwAfbaTEi1AyarrzTWNz2ZmLNjrYZqzPvea06HuRHHAFMzplfEDBOBtnPg2jcjpiUZQpm2NHfoyk86woy3MAsnSteso35shVC85G0MDlP5sXbfOYjuLCqXf1pLXvRddAAuIYFMzaFgMpd3N1NJrOJUudlnfMgCWu41TCqznh0TYvqhvytCNlDRGJphK2SBjnxkoOavoHQKdcqIQSBPq3MAsnStesUckFfpdNNbniRv5jsg5Wq3MAsnStes(Zm7zy(mCEgTesM8GxrKYpvuA6Nz2ZWJdMcVULdIDzT1ktbnqeXDU0MchFoiTz3sAUuCqbQCcvjheGevz3sHUn1KAyNiKCfu(kEgopJwcjtEWRis5Nkkn9Zm7z4XbtHx3Yb72utk0e2WDU0MAo(CqAZUL0CP4GJdPwY0oxAm5GPWRB5Gg3zvicEtKG4oxAmJLJphK2SBjnxkoOavoHQKd2NJran9glbHkdejkyDBqFySpdNN1NJraDwRYBiv)wcgGEkW(zX9m84GPWRB5GOZAvEdP63sqUZLgtm54ZbPn7wsZLIdkqLtOk5GIlQFkJRwhg00OeL)mZEwSCWu41TCqnIsD3MAcYDU0yIhhFoiTz3sAUuCqbQCcvjhSphJq3EN2oHEarPWFMejpRphJqQr0M2AjfAcBctdoyk86woOX51TCNlnMTMJphK2SBjnxkoyk86woiajQYULu160clxUswjlb4SU6GIYAtVwzkeLc)qCqbQCcvjhSphJq3EN2oHEarPWFMejpZRis5Nsx0ZId4ZWl2NjrYZexu)ugxTomOPrjk)zXb8z4Xb3mI4GaKOk7wsvRtlSC5kzLSeGZ6QdkkRn9ALPquk8dXDU0yciC85G0MDlP5sXbfOYjuLCW(CmcD7DA7e6beLc)zsK8mVIiLFkDrploGpdVyFMejptCr9tzC16WGMgLO8NfhWNHhhmfEDlhCcjv5ueK7CPXeR44ZbtHx3Yb7270QXejNdsB2TKMlf35sJz8YXNdMcVULd2jeKqyxRmoiTz3sAUuCNlnMTco(CWu41TCWrHOU9onhK2SBjnxkUZLgttHJphmfEDlhmxbbDuAvI0A5G0MDlP5sXDU0yAQ54ZbPn7wsZLIdkqLtOk5GEIKrEWRis5Nsx0Zm7zyIhhmfEDlhesgWcYDU04flhFoiTz3sAUuCWu41TCqHCH9C0TLq1Tj05Gcu5eQsoylpd6uA9gshsR9z48S(CmcPgrBARLuOjSjOpm2NHZZ6ZXierrhsU6gk7uuALgrzemOpm2NHZZOLqYKh8kIu(PIst)mZEgG8mCEgY7Q(CmGplUNHvCqAmiHR2mI4Gc5c75OBlHQBtOZDU04HjhFoiTz3sAUuCWu41TCWmgWMeLq14wxDdLXHbH4Gcu5eQsoylpRphJqQr0M2AjfAcBctJNHZZA5z95ye62utQHDIqYdtJNHZZe3z1hgBi1iAtBTKcnHnbefL1cFwCpdtSIdUzeXbZyaBsucvJBD1nughgeI7CPXdpo(CqAZUL0CP4GPWRB5GjSbGCjOcLX4qkXHslhuGkNqvYb1uFogbugJdPehkTkn1NJrqFySptIKNPP(CmcIB1tHxaqQAXwPP(CmctJNHZZ8ejJ8qdLwVjyi8Nf3ZAnEpdNN5jsg5HgkTEtWq4pZmGpR1X(mjsEwlptt95yee3QNcVaGu1ITst95yeMgpdNNb4NPP(CmcOmghsjouAvAQphJa0tb2pZmGpdVyFgG6zyg7Za0ptt95ye6270QBO8gsrlfjpmnEMejpBuYACfIIYAHplUNfVX(mS8mCEwFogHuJOnT1sk0e2equuwl8zM9mmnfo4MrehmHnaKlbvOmghsjouA5oxA8AnhFoiTz3sAUuCqbQCcvjhSphJq3EN2oHEarPWFMejpBuYACfIIYAHploGpdVyFMejptCr9tzC16WGMgLO8NfhWNHhhmfEDlhCcjv5ueK7CNd2NLvZXNlnMC85GPWRB5GKO5QvMcrgOkkxnhK2SBjnxkUZLgpo(CqAZUL0CP4Gcu5eQsoO4I6NY4Q1Hbnnkr5plUNH5ZW9zAQphJaKqO0jTQFlPGgf2ua6PaBoyk86woiKqO0jTQFlPGgf2e35s3Ao(CqAZUL0CP4Gcu5eQsoiGFMNwA9awFwcSvAuIrG2SBj9ZKi5zzmiu5uaBImuYVjsHr5qv2VPRKFZakxSFwCpdVNHLNHZZ6ZXiCgghYNB5YdtJNHZZa8Z6ZXiGnrgk53ePWOCOk730vYVza6Pa7Nf3ZWeqEMejpJwcjt(ZI7zacw9mSWbtHx3YbnkOFwfS5CUZLgq44ZbPn7wsZLIdkqLtOk5G95yeodJd5ZTC5HPXZW5z95ye0uQHnNhMgCWu41TCqJc6NvbBoN7CPXko(CWu41TCqyTf0jKc6OcBIdsB2TKMlf35o35o35Ca]] )

end