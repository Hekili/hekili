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
            
            startsCombat = false,
            texture = 136066,
            
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


    spec:RegisterPack( "Outlaw", 20200823, [[d8uFfbqifPEKIkBcLYNqPQAuksoLIOvPiKxrinlkj3sHs7sOFrjAyuQCmuOLHI6zOuX0uO4AkQQTPiW3uufnokP05Ouv16OKcZtHQ7Hs2hLIdQiOfsiEikvLjsPQCrfvjBeLQyKkQsLtIsvYkviVeLkPBsPQIDsP0prPsmufvHJQOkLwQIq9uqnvkHRsjfTvfvPQVsPQsJfLQuoRIQuSxu9xsnyLoSOfdYJjAYuCzKnRIptqJwbNwQvJsvQEnkYSj52cA3Q63adxGJJsLA5qEoutNQRRsBxr57OGXtPkNNqTEkPA(ey)sMZi3coSjDIBlZ2XSD2zTmZorghZyyhgzMd7IdioCqkzkfsC4pdjom7Y1vjdC4GuScKgUfCym4IKehEW9aS1Wslf2(WfkkbHwI7WRk9g8suEClXDO0som0Tvo71ZH4WM0jUTmBhZ2zN1Ym7ezCmmB)hd7WHXbKKBlZtGDC4H2yONdXHnewYHNRw2LRRsgQDIbcVunAUAhCpaBnS0sHTpCHIsqOL4o8QsVbVeLh3sChkTSgnxTJUpvlJJXQAz2oMTRgvJMRw23q(cjS1OgnxTJT2j0yitTSRTKPADqTg6KxLxBk9g81QAShRrZv7yRDcngYuBaIKGqO0RvevAOAzpQlcjU2Pmac)SFVwieLmvlStPYhMmwJMR2XwR9bE2Vx7ft16O(zICCT9xl2Pu5dXA0C1o2ATpWZ(9AVyQ2W(TgS3Q9aq1A)KiMitThaQw7JsFO2PAN9JR9bET4Bqaa5KzYynAUAhBTt4mqBQfriGs1VWANyxKAnxu)cRvevAOAzpQlcjU2PUVIW4AzGQf8kX1oKZOAzSwprcjFYynAUAhBTtmPs7vl7ARu9lSw4aerXA0C1o2ATMyQwVdjTd0MMQ9aq1sVeCFNq1sVPFH1IsFGq16d5xRNiHKh9oK0oqBAkwJMR2XwR1et1oXUi1IieqPQvbe2YAZ3ul8BF1IOdIWd1QacBzT9xRpq1gGijiek9AtP3GVwvJ9ihoaboTI4WZvl7Y1vjd1oXaHxQgnxTdUhGTgwAPW2hUqrji0sChEvP3GxIYJBjUdLwwJMR2r3NQLXXyvTmBhZ2vJQrZvl7BiFHe2AuJMR2Xw7eAmKPw21wYuToOwdDYRYRnLEd(Avn2J1O5QDS1oHgdzQnarsqiu61kIknuTSh1fHex7ugaHF2VxleIsMQf2Pu5dtgRrZv7yR1(ap73R9IPADu)mroU2(Rf7uQ8HynAUAhBT2h4z)ETxmvBy)wd2B1EaOATFsetKP2davR9rPpu7uTZ(X1(aVw8niaGCYmzSgnxTJT2jCgOn1IieqP6xyTtSlsTMlQFH1kIknuTSh1fHex7u3xryCTmq1cEL4AhYzuTmwRNiHKpzSgnxTJT2jMuP9QLDTvQ(fwlCaIOynAUAhBTwtmvR3HK2bAtt1EaOAPxcUVtOAP30VWArPpqOA9H8R1tKqYJEhsAhOnnfRrZv7yR1AIPANyxKArecOu1QacBzT5BQf(TVAr0br4HAvaHTS2(R1hOAdqKeecLETP0BWxRQXESgvJMR25L9i51jtTq0bGOALGqO0RfIe2pow7ekLuGJR9b)yhsu45QQnLEdECTGxjowJMR2u6n4XXaejbHqPZ6Osmt1O5QnLEdECmarsqiu6IYYY8kmKEp9g81O5QnLEdECmarsqiu6IYYYdayQrZvl8Nb4bGxlkBtTq3ZHm1I90X1crhaIQvccHsVwisy)4AZ3uBaIgBaW9(fwBJR1aEkwJMR2u6n4XXaejbHqPlkllXFgGhaUg7PJRrP0BWJJbisccHsxuwwolrDcPiR(mKybMrinkqlrTR9beHhakJvZs1LyLUNsM0su72yxCmmxJsP3GhhdqKeecLUOSSma4n4RrP0BWJJbisccHsxuwwgMiMiJ(aqAdL(GvbisccHsxJjj4nywZ3Q(WcLTrtZO3JPXGJ9BZySRgLsVbpogGijiekDrzzj2Pu5dw1hwtnnXUVDqazIbajtKJBRtgTeegC90BWRn0SwscemTeaugadFukwQaoc8TudPsShnxu6n4fiaLTrtZO3J9p7QEcLqkks2RXoEYAuk9g84yaIKGqO0fLLLyvljD(gTPLKvbisccHsxJjj4nywSJv9Hf09CIyvljD(gTPLuerHz)4X9oK0oqBAInO75eXQws68nAtlPiIcZ(XJpfJIkbHqaDaOFhp5eXy0ARrP0BWJJbisccHsxuwwMge9PQFsJU4bRcqKeecLUgtsWBWSy0Q(WAQPj29TdcitmaizICCBDYOLGWGRNEdETHM1ssGGPLaGYay4JsXsfWrGVLAivI9O5IsVbVabOSnAAg9ES)zx1tOesrrYEn2XtwJsP3GhhdqKeecLUOSS8IjD7uOvFgsSsRJhsuI1hW7AWrhayGq1Ou6n4XXaejbHqPlkllraLs7dKgc8e2QaejbHqPRXKe8gmlMRrP0BWJJbisccHsxuwwEXKUDk0k6CiPR)mKyjflvahb(wQHuj2TQpSMgLTrtZO3J9p7QEcLqkks2RXoUgvJMR25L9i51jtT0mcjUwVdPA9bQ2u6auTnU2Cw2QesrXA0C1oXe2Pu5d12NAdayCdPOAN6b1o7QEcLqkQw6PWMW12FTsqiu6twJsP3GhZIPwYKv9H10yNsLpqMici8s1Ou6n4XSWoLkFOgLsVbpwuwwolrDcPiR(mKyLHqx8GwcEt7n4TAwQUeljiecOda974OHoTSDByXSOmprt5PIEpkCaGDLyn2rntuK(esrg2KaGYay4JchayxjwJDuZefruy2pECgNuuO75eHqG0GBdfVbSrpHek2MjWo2Mg6EormtxLsNVrlramgc8eoEdyBAO75ezIOaTyWfPzODSoHaxxlgCJ3GAuk9g8yrzz5Se1jKIS6ZqIfKtAj4nT3G3QzP6sSGUNteD9bfHX6aejBCd(4nqGGPsRtO2POHsdEa4r6tifzeiiToHANIPK03aTyWfPXkIMrr6tifzMKnO75eraLs7dKgc8eoEdQrZvR9B7d1gEvEhOOA9ejKCSv16dnU2zjQtifvBJRvoqsMitToOwdjBdvlddKpqOAXGqQw2N9HRfpaUktTquTyXVKm1Yq7d1kIknuTSh1fHexJsP3GhlkllNLOoHuKvFgsSGuPH0h1fHeRXIFPvZs1LyHdiLs7jsi54iKknK(OUiK4XzMnu2gnnJEpMgdo2VnmBNabq3ZjcPsdPpQlcjoEdQrP0BWJfLLLYuP0P0BWRvn2T6ZqIf2Pu5dw1hwyNsLpqMyQu1Ou6n4XIYYszQu6u6n41Qg7w9ziXsAW1O5QL90FJhQn9Adt71H3WAzFZJyTWxiSJsPxl4PApauTukhQveein42q1MVPw2LGaaYVF7IRLHb6RDE7TLmvR9HsgQTX1IjfjDYuB(MATFo2xTnU2h41IO0iU284eQwFGQ9j751Ijj4nXANqfdPyCTHP9QveFEvldTpulZIw7ekPynkLEdESOSSeDFDk9g8AvJDR(mKyD6VXdw1hwsqieqha63X2WsgOdt7PXb0Bg7uq3ZjcHaPb3gkEdef6Eorqqaa53VDXXBWKt0uEQO3JS7BlzsBqjdr6tifzyBQP9urVhdtetKrFaiTHsFisFcPiJabsaqzam8XWeXez0hasBO0hIikm7hBdJto5envADc1oftjPVbAXGlsJvenJIO8zACMfiyAjaOmag(ie5mq0R9bstIjC8giqW0q3ZjIakL2hine4jC8gmznkLEdESOSSuMkLoLEdETQXUvFgsSGUTYuJsP3GhlklltKmFs7aeIE3Q(WIEcjuC0qNw2UnSyC(IspHekoIiH0xJsP3GhlklltKmFshCvyQgLsVbpwuwwQAHdowZE)AegsVxJsP3GhlkllHsHAWr7OwYeUgvJMRwrUTYqiCnAUATMyQ25rJDGQw4bGxBFQT9Aza8SFVwzguReecbQna0VJRnFtT(avl7sqaa53VDX1cDpNABCT3GyTt4mqBQ9I7xyTmmqFTSRefu78gWfvR9B74AXEkzcxBIOAhAHd1cq1YWa91EX9lSw7xkdaFyIDczvT3xryCT(avR9rPbpa8AHUNtTnU2BqSgLsVbpocDBLHvqJDGsJhaUv9H1uEQO3JS7BlzsBqjdr6tifzeiiToHANImruGwm4I0m0owNqGRRfdUru(mnoZtYg09CIGGaaYVF7IJ3a2Mc6EorMikqlgCrAgAhRtiW11Ib3i2tjtJZ4yeiGEcju84Jz(twJsP3GhhHUTYiklldASduA8aWTQpSGUNteeeaq(9BxC8gWg09CIgkn4bGhVb1Ou6n4XrOBRmIYYsC)n2jKg7OMjQgvJMRw2haOmagECnkLEdECuAWSKPsPtP3GxRASB1NHelcJPxsyR6dRPXoLkFGmXuPQrP0BWJJsdwuwwMge9PQFsJU4bR6dRPHUNtmni6tv)KgDXdXBaBtnnXUVDqazIP1XdjkX6d4Dn4OdamqibcKaGYay4JQ0P31jsMFgruy2p2gMTBYA0C1YEDQnngCTjIQ9gyvT4VdOA9bQwWt1Yq7d1QamqyVwlSW(I1AnXuTmmqFTgX9lS2tIDcvRpKFTSV5rTg60Y2RfGQLH2haxV28fxl7BEeRrP0BWJJsdwuwwgMiMiJ(aqAdL(GvsXsfP9ejKCmlgTQpSqzB00m69yAm44nGTP8ejK8O3HK2bAttJlbHqaDaOFhhn0PLTlqW0yNsLpqMici8sSjbHqaDaOFhhn0PLTBdlzGomTNghqVzSmoznAUAzVo1(GAtJbxldTsvRPPAzO9H(R1hOAFYEETSJDyRQ9IPATFo2xTGVwiagxldTpaUET5lUw238iwJsP3GhhLgSOSSmmrmrg9bG0gk9bR6dlu2gnnJEpMgdo2VnSJDJfLTrtZO3JPXGJMlk9g8Snn2Pu5dKjIacVeBsqieqha63XrdDAz72WsgOdt7PXb0BglJ1O5QvevAOAzpQlcjUwWxlZIwl9uyt4yT2VTpuBAmyRrTwtmvBFQ1hiX1I9uCThaQwRv0AXKe8gCTauT9PwXGlQ2NSNxRCircPAzOvQAHOAruAexB)16Div7bGQ1hOAFYEETmKZOynkLEdECuAWIYYsivAi9rDriXw1hw4asP0EIeso2gwmZ20q3ZjcPsdPpQlcjoEdyBQPrzB00m69yAm4izVg7ybcqzB00m69yAm4iIcZ(X2yTceGY2OPz07X0yWX(TzkMhReaugadFesLgsFuxesCuoKiHewFqP0BWNQjNiMN)K1Ou6n4XrPblkllfoaWUsSg7OMjYQ(WsccHa6aq)ooAOtlB3gwmkk09CIqiqAWTHI3GAunkLEdECuAWIYYsMALQFHACaIiR6dRzjQtiffHuPH0h1fHeRXIFjB4asP0EIesoocPsdPpQlcj2ggzJEcjuC07qs7aDyApByUgLsVbpoknyrzzjKknKgDXdw1hwZsuNqkkcPsdPpQlcjwJf)s2ONqcfh9oK0oqhM2ZgMRrP0BWJJsdwuwwIakL2hine4jSv9Hf09CIORpOimwhGizJBWhnagE2GUNtebukTpqAiWt4i2tjtJZCnkLEdECuAWIYYsdIsdKkne2Q(WsccHa6aq)ooAOtlB3g7QrP0BWJJsdwuwwga8g8w1hwq3ZjcPaaJ6I9iIsPlqa09CIPbrFQ6N0OlEiEdQrZvl7jvQ(fwlukzQwhuRHo5v512ofw7fNcPAuk9g84O0GfLLLxmPBNcT6ZqI1Se1jKI0970JBxSwylmNbuUgGLTsLE)c1ikLoazvFybDpNiKcamQl2JikLUabEhsAhOnnnolMTtGajiecOda974OHoTS9XzXCnkLEdECuAWIYYYlM0TtHyR6dlO75eHuaGrDXEerP0fiW7qs7aTPPXzXSDceibHqaDaOFhhn0PLTpolMRrP0BWJJsdwuwwcPaaJ(CrIRrP0BWJJsdwuwwcrimHyQFH1Ou6n4XrPblkllpnIGuaGPgLsVbpoknyrzzz(sc7OuPLPsvJsP3GhhLgSOSS8IjD7uOv05qsx)ziXskwQaoc8TudPsSBvFynn2Pu5dKjMkfBq3ZjMge9PQFsJU4HObWWZg09CIHuiajwdoA1v2gTbrzioAam8SrpHeko6DiPDGomTNnJHnKdPHUNdE85xJsP3GhhLgSOSS8IjD7uOvFgsSsRJhsuI1hW7AWrhayGqw1hwtdDpNyAq0NQ(jn6IhI3a2Mg6EorivAi9rDriXXBaBsaqzam8X0GOpv9tA0fperuy2pECgNFnAUAN3tiX1IaxHdkX1IUkQwWPwF4gc1NMm1gM(aUwisbyWAuR1et1EaOAzVEMcaMALO2TQwGpqigAmvldTpu7eoX1METmBNO1I9uYeUwaQwgTt0AzO9HAtfguRikaWu7niwJsP3GhhLgSOSS8IjD7uOvFgsSs8WS8jSgLwhG0sakvw1hwgc6EoruADaslbOuPne09CIgadVabgc6Eorj4nxP3ZiD)mPne09CI3a28ejK84aLkFigi9XzhMzZtKqYJduQ8HyG0THf7yNabtBiO75eLG3CLEpJ09ZK2qq3ZjEdyBkdbDpNikToaPLauQ0gc6EorSNsMSHfZ2nwgTBIme09CIqkaWObhTpqA6PqXXBGabNw4GRruy2pE8jWUjzd6EoX0GOpv9tA0fperuy2p2ggT2A0C1AF0jVkV2tQuqPKPApauTxCcPOABNcXXAuk9g84O0GfLLLxmPBNcXw1hwq3ZjcPaaJ6I9iIsPlqWPfo4AefM9JhNfZ2jqGeecb0bG(DC0qNw2(4SyUgvJMR25fgtVKW1Ou6n4XrcJPxsywsWlP3rPtg9rLHKv9Hf9esO4O3HK2b6W0E2WiBtdDpNiKknK(OUiK44nGTPM2a8Oe8s6Du6KrFuziPHUOp6TKP(fY20P0BWhLGxsVJsNm6JkdPy)6JQfo4ceCUkLgrYHejK0EhsJluAIHP9MSgLsVbposym9sclkllHuaGrdoAFG00tHITQpSMLOoHuuesLgsFuxesSgl(LSjbaLbWWhHiNbIETpqAsmHJ3a2MLOoHuueYjTe8M2BWZ2u4asP0EIesoocPsdPpQlcj2gwmlqakBJMMrVhtJbh73MXm)jfi40chCnIcZ(XJZIr7QrP0BWJJegtVKWIYYsH3ez681GJoToHa(qnkLEdECKWy6LewuwwEaYlMm606eQDsdrzOv9HfoGukTNiHKJJqQ0q6J6IqITHfZceGY2OPz07X0yWX(TzcSJTPHUNtmni6tv)KgDXdXBGabNw4GRruy2pECgTRgLsVbposym9sclklldUO(iUFHAivIDR6dlCaPuAprcjhhHuPH0h1fHeBdlMfiaLTrtZO3JPXGJ9BZeyNabNw4GRruy2pECgTRgLsVbposym9sclkll9bsFFiW9n6dajjR6dlO75erKKjfHX6dajP4nqGaO75erKKjfHX6dajjTeCFNqrSNsMgNr7QrP0BWJJegtVKWIYYsuheOiD)ACqkPAuk9g84iHX0ljSOSSKbaszMr9Rreg85lPAuk9g84iHX0ljSOSSmKcbiXAWrRUY2OnikdXw1hw0tiHIhFmZVgnxTZ7aktTtmLb9lSw2JkdjCThaQwYEK86uTO8fs1cq1YuRu1cDphSv12NAdayCdPOyTtOIHumUwhjUwhuRqYR1hOAvagiSxReaugadFTqjMm1c(AZzzRsifvl9uyt4ynkLEdECKWy6LewuwwIOmOFH6JkdjSvsXsfP9ejKCmlgTQpS8ejK8O3HK2bAttJZyC(cem1uEIesECGsLpedKUnwRDce4jsi5Xbkv(qmq6JZIz7MKTPsP3Zin9uytywmkqGNiHKh9oK0oqBAYgMT)toPabt5jsi5rVdjTd0bsxZSD2Wo2X2uP07zKMEkSjmlgfiWtKqYJEhsAhOnnzZygZKtwJQrZvl7P)gpqiCnAUAfXNx1cMrOANyxKArecOu4AzO9HATpkn4bGB5ekPADu2oUwaQ2j(6dkcJRDEGizJBWhRrP0BWJJN(B8aliYzGOx7dKMetyR6dRzjQtiffHCslbVP9g81Ou6n4XXt)nEquwwIvTK05B0Mwsw1hwq3ZjIvTK05B0MwsrefM9Jh)0chCnIcZ(XSbDpNiw1ssNVrBAjfruy2pE8PyuujiecOda974jNigJwBnAUAfXNx1Yq7d16duTtOKQ1Agu78gWfvlSIOzuTauT2hLg8aWR1rz74ynkLEdEC80FJheLLLqKZarV2hinjMWw1hwP1ju7umLK(gOfdUinwr0mksFcPiJabP1ju7u0qPbpa8i9jKIm1Ou6n4XXt)nEquwwAACq6YHAunAUAHDkv(qnkLEdECe7uQ8bwYbkd04bGBLuSurAprcjhZIrR6dlpv07XaejwdETpqAgOKPi9jKImSnTNiHKhBSgcGX1Ou6n4XrStPYheLLLzi0fpWHNriCdEUTmBhZ2z3eW4y4WmKOVFHyom7vyaa5KP25zTP0BWxRQXoowJ4W51haiomChY(4WQg7yUfCycJPxsyUfCBzKBbhM(esrgUiCyjQDc1jhMEcjuC07qs7aDyAVATPwgRLTANUwO75eHuPH0h1fHehVb1YwTtv701AaEucEj9okDYOpQmK0qx0h9wYu)cRLTANU2u6n4JsWlP3rPtg9rLHuSF9r1ch8AfiO2ZvP0isoKiHK27qQ2XRvO0edt7v7KC4u6n45WsWlP3rPtg9rLHe352Ym3com9jKImCr4Wsu7eQto8Se1jKIIqQ0q6J6IqI1yXVSw2QvcakdGHpcrode9AFG0KychVb1YwTZsuNqkkc5KwcEt7n4RLTANQwCaPuAprcjhhHuPH0h1fHexRnSQL5AfiOwu2gnnJEpMgdo2FT2u7yMFTtwRab1EAHdUgrHz)4AhNvTmAhhoLEdEomKcamAWr7dKMEkum352YoCl4WP0BWZHfEtKPZxdo606ec4dCy6tifz4IWDUTJHBbhM(esrgUiCyjQDc1jhghqkL2tKqYXrivAi9rDriX1AdRAzUwbcQfLTrtZO3JPXGJ9xRn1ob2vlB1oDTq3ZjMge9PQFsJU4H4nOwbcQ90chCnIcZ(X1oETmAhhoLEdEo8biVyYOtRtO2jneLHCNB785wWHPpHuKHlchwIANqDYHXbKsP9ejKCCesLgsFuxesCT2WQwMRvGGArzB00m69yAm4y)1AtTtGD1kqqTNw4GRruy2pU2XRLr74WP0BWZHdUO(iUFHAivIDUZTDc4wWHPpHuKHlchwIANqDYHHUNtersMuegRpaKKI3GAfiOwO75erKKjfHX6dajjTeCFNqrSNsMQD8Az0ooCk9g8CyFG03hcCFJ(aqsI7CBNNCl4WP0BWZHrDqGI09RXbPK4W0NqkYWfH7CBTwUfC4u6n45WmaqkZmQFnIWGpFjXHPpHuKHlc352A)5wWHPpHuKHlchwIANqDYHPNqcfx741oM5ZHtP3GNdhsHaKyn4OvxzB0geLHyUZTLr74wWHPpHuKHlchwIANqDYH9ejK8O3HK2bAtt1oETmgNFTceu7u1ovTEIesECGsLpedKET2uR1AxTceuRNiHKhhOu5dXaPx74SQLz7QDYAzR2PQnLEpJ00tHnHRLvTmwRab16jsi5rVdjTd0MMQ1MAz2(x7K1ozTceu7u16jsi5rVdjTd0bsxZSD1AtTSJD1YwTtvBk9EgPPNcBcxlRAzSwbcQ1tKqYJEhsAhOnnvRn1oMXu7K1ojhoLEdEomIYG(fQpQmKWCyPyPI0EIesoMBlJCN7CydDYRY5wWTLrUfCy6tifz4IWHLO2juNC4PRf7uQ8bYeraHxIdNsVbphMPwYe352Ym3coCk9g8CyStPYh4W0NqkYWfH7CBzhUfCy6tifz4IWHbbCym5C4u6n45WZsuNqkIdplvxIdlbHqaDaOFhhn0PLTxRnSQL5AfTwMRDIQDQA9urVhfoaWUsSg7OMjksFcPitTSvReaugadFu4aa7kXASJAMOiIcZ(X1oETmw7K1kATq3ZjcHaPb3gkEdQLTAPNqcfxRn1ob2vlB1oDTq3ZjIz6Qu68nAjcGXqGNWXBqTSv701cDpNitefOfdUindTJ1je46AXGB8gWHNLi9NHehodHU4bTe8M2BWZDUTJHBbhM(esrgUiCyqahgtohoLEdEo8Se1jKI4WZs1L4Wq3ZjIU(GIWyDaIKnUbF8guRab1ovTP1ju7u0qPbpa8i9jKIm1kqqTP1ju7umLK(gOfdUinwr0mksFcPitTtwlB1cDpNicOuAFG0qGNWXBahEwI0FgsCyiN0sWBAVbp352oFUfCy6tifz4IWHbbCym5C4u6n45WZsuNqkIdplvxIdJdiLs7jsi54iKknK(OUiK4AhVwMRLTArzB00m69yAm4y)1AtTmBxTceul09CIqQ0q6J6IqIJ3ao8SeP)mK4WqQ0q6J6IqI1yXVK7CBNaUfCy6tifz4IWHtP3GNdltLsNsVbVw1yNdlrTtOo5WyNsLpqMyQuCyvJD9NHehg7uQ8bUZTDEYTGdtFcPidxeoCk9g8CyzQu6u6n41Qg7CyvJD9NHehwAWCNBR1YTGdtFcPidxeoCk9g8Cy091P0BWRvn25Wsu7eQtoSeecb0bG(DCT2WQwzGomTNghqVP2Xw7u1cDpNiecKgCBO4nOwrRf6Eorqqaa53VDXXBqTtw7ev7u16PIEpYUVTKjTbLmePpHuKPw2QDQANUwpv07XWeXez0hasBO0hI0NqkYuRab1kbaLbWWhdtetKrFaiTHsFiIOWSFCT2ulJ1ozTtw7ev7u1MwNqTtXus6BGwm4I0yfrZOikFMQD8AzUwbcQD6ALaGYay4JqKZarV2hinjMWXBqTceu701cDpNicOuAFG0qGNWXBqTtYHvn21FgsC4t)nEG7CBT)Cl4W0NqkYWfHdNsVbphwMkLoLEdETQXohw1yx)ziXHHUTYWDUTmAh3com9jKImCr4Wsu7eQtom9esO4OHoTS9ATHvTmo)AfTw6jKqXrejKEoCk9g8C4ejZN0oaHO35o3wgzKBbhoLEdEoCIK5t6GRctCy6tifz4IWDUTmYm3coCk9g8CyvlCWXA27xJWq6Dom9jKImCr4o3wgzhUfC4u6n45WqPqn4ODulzcZHPpHuKHlc35ohoarsqiu6Cl42Yi3com9jKImCr4WGaomMCoCk9g8C4zjQtifXHNLQlXHt3tjtAjQ9ATPw7IJHzo8SeP)mK4WGzesJc0su7AFar4bGYWDUTmZTGdNsVbphoa4n45W0NqkYWfH7CBzhUfCy6tifz4IWHLO2juNCyu2gnnJEpMgdo2FT2u7ySJdNsVbphomrmrg9bG0gk9boCaIKGqO01yscEdMdpFUZTDmCl4W0NqkYWfHdlrTtOo5Wtv701sS7BheqMyaqYe5426KrlbHbxp9g8AdnRLuTceu701kbaLbWWhLILkGJaFl1qQe7rZfLEd(AfiOwu2gnnJEp2)SR6jucPOizVg74ANKdNsVbphg7uQ8bUZTD(Cl4W0NqkYWfHdlrTtOo5Wq3ZjIvTK05B0MwsrefM9JRD8A9oK0oqBAQw2Qf6EorSQLKoFJ20skIOWSFCTJx7u1YyTIwReecb0bG(DCTtw7evlJrRLdNsVbphgRAjPZ3OnTK4WbisccHsxJjj4nyom7WDUTta3com9jKImCr4Wsu7eQto8u1oDTe7(2bbKjgaKmroUToz0sqyW1tVbV2qZAjvRab1oDTsaqzam8rPyPc4iW3snKkXE0CrP3GVwbcQfLTrtZO3J9p7QEcLqkks2RXoU2j5WP0BWZHtdI(u1pPrx8ahoarsqiu6AmjbVbZHzK7CBNNCl4W0NqkYWfHd)ziXHtRJhsuI1hW7AWrhayGqC4u6n45WP1XdjkX6d4Dn4OdamqiUZT1A5wWHPpHuKHlchoLEdEomcOuAFG0qGNWC4aejbHqPRXKe8gmhMzUZT1(ZTGdtFcPidxeoSe1oH6KdpDTOSnAAg9ES)zx1tOesrrYEn2XC4u6n45WsXsfWrGVLAivIDomDoK01FgsCyPyPc4iW3snKkXo35oh(0FJh4wWTLrUfCy6tifz4IWHLO2juNC4zjQtiffHCslbVP9g8C4u6n45WqKZarV2hinjMWCNBlZCl4W0NqkYWfHdlrTtOo5Wq3ZjIvTK05B0MwsrefM9JRD8ApTWbxJOWSFCTSvl09CIyvljD(gTPLuerHz)4AhV2PQLXAfTwjiecOda974ANS2jQwgJwlhoLEdEomw1ssNVrBAjXDUTSd3com9jKImCr4Wsu7eQtoCADc1oftjPVbAXGlsJvenJI0NqkYuRab1MwNqTtrdLg8aWJ0NqkYWHtP3GNddrode9AFG0KycZDUTJHBbhoLEdEoSPXbPlh4W0NqkYWfH7CNdJDkv(a3cUTmYTGdtFcPidxeoSe1oH6Kd7PIEpgGiXAWR9bsZaLmfPpHuKPw2QD6A9ejK8yJ1qamMdNsVbphwoqzGgpaCoSuSurAprcjhZTLrUZTLzUfC4u6n45Wzi0fpWHPpHuKHlc35ohwAWCl42Yi3com9jKImCr4WP0BWZHLPsPtP3GxRASZHLO2juNC4PRf7uQ8bYetLIdRASR)mK4WegtVKWCNBlZCl4W0NqkYWfHdlrTtOo5Wtxl09CIPbrFQ6N0OlEiEdQLTANQ2PRLy33oiGmX064HeLy9b8UgC0bagiuTceuReaugadFuLo9UorY8ZiIcZ(X1AtTmBxTtYHtP3GNdNge9PQFsJU4bUZTLD4wWHPpHuKHlchwIANqDYHrzB00m69yAm44nOw2QDQA9ejK8O3HK2bAtt1oETsqieqha63XrdDAz71kqqTtxl2Pu5dKjIacVuTSvReecb0bG(DC0qNw2ET2WQwzGomTNghqVP2XwlJ1ojhoLEdEoCyIyIm6daPnu6dCyPyPI0EIesoMBlJCNB7y4wWHPpHuKHlchwIANqDYHrzB00m69yAm4y)1AtTSJD1o2ArzB00m69yAm4O5IsVbFTSv701IDkv(azIiGWlvlB1kbHqaDaOFhhn0PLTxRnSQvgOdt7PXb0BQDS1YihoLEdEoCyIyIm6daPnu6dCNB785wWHPpHuKHlchwIANqDYHXbKsP9ejKCCT2WQwMRLTANUwO75eHuPH0h1fHehVb1YwTtv701IY2OPz07X0yWrYEn2X1kqqTOSnAAg9EmngCerHz)4ATPwRTwbcQfLTrtZO3JPXGJ9xRn1ovTmx7yRvcakdGHpcPsdPpQlcjokhsKqcRpOu6n4tvTtw7evlZZV2j5WP0BWZHHuPH0h1fHeZDUTta3com9jKImCr4Wsu7eQtoSeecb0bG(DC0qNw2ET2WQwgRv0AHUNtecbsdUnu8gWHtP3GNdlCaGDLyn2rnte352op5wWHPpHuKHlchwIANqDYHNLOoHuuesLgsFuxesSgl(L1YwT4asP0EIesoocPsdPpQlcjUwBQLXAzRw6jKqXrVdjTd0HP9Q1MAzMdNsVbphMPwP6xOghGiI7CBTwUfCy6tifz4IWHLO2juNC4zjQtiffHuPH0h1fHeRXIFzTSvl9esO4O3HK2b6W0E1AtTmZHtP3GNddPsdPrx8a352A)5wWHPpHuKHlchwIANqDYHHUNteD9bfHX6aejBCd(ObWWxlB1cDpNicOuAFG0qGNWrSNsMQD8AzMdNsVbphgbukTpqAiWtyUZTLr74wWHPpHuKHlchwIANqDYHLGqiGoa0VJJg60Y2R1MATJdNsVbph2GO0aPsdH5o3wgzKBbhM(esrgUiCyjQDc1jhg6EorifayuxShruk9AfiOwO75etdI(u1pPrx8q8gWHtP3GNdha8g8CNBlJmZTGdtFcPidxeoCk9g8C4zjQtifP73Ph3UyTWwyodOCnalBLk9(fQrukDaIdlrTtOo5Wq3ZjcPaaJ6I9iIsPxRab16DiPDG20uTJZQwMTRwbcQvccHa6aq)ooAOtlBV2XzvlZC4pdjo8Se1jKI0970JBxSwylmNbuUgGLTsLE)c1ikLoaXDUTmYoCl4W0NqkYWfHdlrTtOo5Wq3ZjcPaaJ6I9iIsPxRab16DiPDG20uTJZQwMTRwbcQvccHa6aq)ooAOtlBV2XzvlZC4u6n45WxmPBNcXCNBlJJHBbhoLEdEomKcam6ZfjMdtFcPidxeUZTLX5ZTGdNsVbphgIqycXu)c5W0NqkYWfH7CBzCc4wWHtP3GNdFAebPaadhM(esrgUiCNBlJZtUfC4u6n45W5ljSJsLwMkfhM(esrgUiCNBlJwl3com9jKImCr4Wsu7eQto801IDkv(azIPsvlB1cDpNyAq0NQ(jn6IhIgadFTSvl09CIHuiajwdoA1v2gTbrzioAam81YwT0tiHIJEhsAhOdt7vRn1oMAzRwKdPHUNdU2XRD(C4u6n45WsXsfWrGVLAivIDomDoK01FgsCyPyPc4iW3snKkXo352YO9NBbhM(esrgUiC4u6n45WP1XdjkX6d4Dn4OdamqioSe1oH6KdpDTq3ZjMge9PQFsJU4H4nOw2QD6AHUNtesLgsFuxesC8gulB1kbaLbWWhtdI(u1pPrx8qerHz)4AhVwgNph(ZqIdNwhpKOeRpG31GJoaWaH4o3wMTJBbhM(esrgUiC4u6n45WjEyw(ewJsRdqAjaLkoSe1oH6KdBiO75erP1biTeGsL2qq3ZjAam81kqqTgc6Eorj4nxP3ZiD)mPne09CI3GAzRwprcjpoqPYhIbsV2XRLDyUw2Q1tKqYJduQ8HyG0R1gw1Yo2vRab1oDTgc6Eorj4nxP3ZiD)mPne09CI3GAzR2PQ1qq3ZjIsRdqAjaLkTHGUNte7PKPATHvTmBxTJTwgTR2jQwdbDpNiKcamAWr7dKMEkuC8guRab1EAHdUgrHz)4AhV2jWUANSw2Qf6EoX0GOpv9tA0fperuy2pUwBQLrRLd)ziXHt8WS8jSgLwhG0sakvCNBlZmYTGdtFcPidxeoSe1oH6KddDpNiKcamQl2JikLETceu7Pfo4AefM9JRDCw1YSD1kqqTsqieqha63XrdDAz71ooRAzMdNsVbph(IjD7uiM7CNddDBLHBb3wg5wWHPpHuKHlchwIANqDYHNQwpv07r29TLmPnOKHi9jKIm1kqqTP1ju7uKjIc0IbxKMH2X6ecCDTyWnIYNPAhVwMRDYAzRwO75ebbbaKF)2fhVb1YwTtvl09CImruGwm4I0m0owNqGRRfdUrSNsMQD8AzCm1kqqT0tiHIRD8AhZ8RDsoCk9g8C4Gg7aLgpaCUZTLzUfCy6tifz4IWHLO2juNCyO75ebbbaKF)2fhVb1YwTq3ZjAO0GhaE8gWHtP3GNdh0yhO04bGZDUTSd3coCk9g8CyC)n2jKg7OMjIdtFcPidxeUZDUZDUZ5a]] )


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
end