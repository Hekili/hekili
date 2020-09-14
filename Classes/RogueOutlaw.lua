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


    spec:RegisterPack( "Outlaw", 20200914, [[d40QebqiPKEKucBcf5tIkOYOqr5uauRcfv1RqjnlIIBHIk2Li)Ic1WOqogkyzOuEgaX0evX1aiTnrvY3KseJtuP6CIkW6KsKAEIQ6EaAFeLoOOsXcjsEOOkLjkQqUOOkvBukr1ifvqXjrrLSsa8srfu1nfvOyNeP(POcYqLsuoQOckTurLspfOPIs1vrrLARsjs6RIkuDwrfkTxu9xsgmuhwyXs1JjmzkDzKnRWNjQgTuCAjRwkrIxJsmBsDBrz3k9BvnCk64OOklhYZbnDQUUI2UuQVJcnErfDEky9Ikz(eX(vzodC25G2WjU0SzeBgzuoGH8Kmk3ncqa0wch0nysCqZqWsiN4GBKrCWCOPRdg5GMHb9hwo7Cq4prcId24UjSL2yJLxEZSNeFMXWkBQdV(vGIHBmSYegZb7Zs7mxlVZbTHtCPzZi2mYOCad5jzuUBeGKN8IdcnjbxA2YlJ4GnL1slVZbTeuWbBXHZHMUoy8W52x(KoaAXHbjtNY6e6WmKhzomBgXMrCqt0pknXbBXHZHMUoy8W52x(KoaAXHbjtNY6e6WmKhzomBgXMrhahaT4W59CsIPt2d3PXJOdl(SE4hUtYRfMoCUriithE49xMttGYgt9HdHx)cp8VAdPdGwC4q41VWKjIeFwpCGdDaz5aOfhoeE9lmzIiXN1dNvGght5z06Hx)Ea0IdhcV(fMmrK4Z6HZkqJh)BpaAXHb3We28(HrrzpCFogK9WqpC4H704r0HfFwp8d3j51cpCS2dBIiMJ57ETYpCbpS9xkDa0IdhcV(fMmrK4Z6HZkqJHBycBExb9WHhaHWRFHjtej(SE4Sc04AHESUY8l4VhaHWRFHjtej(SE4Sc0ybQmn11kxz(f83dGq41VWKjIeFwpCwbA8oZ61kxz(f83dGq41VWKjIeFwpCwbAC7avrxtYSrgb8BtifYujqLR8gebBETvM2HEsad3dblkbQCznkLh2oacHx)ctMis8z9WzfOXMVx)EaecV(fMmrK4Z6HZkqJZcelKvnEKYsH3iJjIeFwpCfKe)AHabuzQbquuwf1MwpfwlmvRS5XOdGq41VWKjIeFwpCwbAm0Pq7nYudGmRvI5nlttYMmFblKdRCrwL4ZmNE41Vkl1UeKejTk(xBFg3KWGq)o63sO66a6j7efE9RejOOSkQnTEQ22t9sOORPeLZc6qaFaecV(fMmrK4Z6HZkqJH6sqQyTkBjizmrK4Z6HRGK4xleiGitnaIObIGnrxtm1NJrcQlbPI1QSLGsiklQfMVxzKYFLTiM6ZXib1LGuXAv2sqjeLf1cZNzmWQ4Z6VY8R1HaM5Zqk3pacHx)ctMis8z9WzfOXHfrBORLuOjSrgtej(SE4kij(1cbYGm1aiZALyEZY0KSjZxWc5WkxKvj(mZPhE9RYsTlbjrsRI)12NXnjmi0VJ(TeQUoGEYorHx)krckkRIAtRNQT9uVek6Akr5SGoeWhaHWRFHjtej(SE4Sc04jKuLtzYSrgbmYfSjqbun(1v)qz(msOdGq41VWKjIeFwpCwbAm61AL3qQ(Veugtej(SE4kij(1cbY2bqi86xyYerIpRhoRanEcjv5uMm0yqcxTrgbuyqOFh9BjuDDaDzQbWwrrzvuBA9uTTN6LqrxtjkNf0HhahaT4W59CsIPt2dtTjKHd7vgDyVHoCi8hD4cE4ODu6ORP0bqloCULGofAV5W14WMpewDnDyMT)HBp1lHIUMomTuwrWdx7HfFwpCaFaecV(fcKLsWIm1ayRqNcT3q2e6LpPdGq41VqGqNcT3CaecV(fYkqJBhOk6AsMnYiGrwFcBuIFTLx)kt7qpjGIpR)kZVwhMS0OeLllq2yLnMpZ8qtRNK38qxBqbDuXcLOn6AYYK4FT9zCtYBEORnOGoQyHsiklQfMpdaM1(CmsD0hwyzP00KjAjKCdYMxgXuR95yKGSm1AvSwLa9qy)xcMMMm1AFogjwiYuz4NifJLdvr)NUYWpttZdGq41VqwbAC7avrxtYSrgbS7Ks8RT86xzAh6jbSphJeA6nAccvMisuW6300uIeMf5IqLtjlfwyZ7jAJUMSsKe5IqLtPqqQPPYWprkOMO2uI2ORjlGzQphJe61AL3qQ(VemnnpaAXHZXlV5WztTxMA6WEGKtouMd7nf8WTdufDnD4cEyrdjyHSh2)dBjrzPdZyd5ne6WWpJoCElhbpmS5NA7H70HHgwbzpmJL3CyP0HLoClxpridhaHWRFHSc042bQIUMKzJmcyxhwsn0teYGcAyfY0o0tci0K0ALhi5KdtDDyj1qprid5ZgtOOSkQnTEkSwyQwzzZijs6ZXi11HLud9eHmKMMhaHWRFHSc0yrO1Qq41VkDbDz2iJacDk0EJm1ai0Pq7nKnfA9bqi86xiRanweATkeE9RsxqxMnYiGcl8aOfhULxBbBoCnoCEp3EyOhcwoCw4Igcbp8JoC4holYzLnZoCERLLom4SdDui8d)lD4XJomfIMdlf6dlSS0HJ1E4CitZh5ZTCdhMXgApCoSZsWYHZrOGXdxWddjnjCYE4yThohZihD4cE499dJOWA4WXWj0H9g6WlLt)Wqs8RnD4CJMXWa8WzropSuEE)WmwEZHzJ1dNBeu6aieE9lKvGgJMRkeE9RsxqxMnYiGJAlyJm1ayFogjs081kxHituLfRnnnzQphJejA(ALRqKjQYI1MGEiybO4Z6VY8R1HsKi(S(Rm)ADOSafMQSiNkOjTwMdZ6ZXi1rFyHLLsttw7ZXi9MMpYNB5gsttaZ8zMhAA9eZBwcwuwuWyI2ORjltmRvp006PSaXczvJhPSu4njAJUMSsKi(xBFg3uwGyHSQXJuwk8MeIYIAHYYaGbmZNzrUiu5ukeKAAQm8tKcQjQnLqXYs(SjrsRI)12NXn1jNrIwL3qkYabtttjsATphJe61AL3qQ(Vemnnb8bqi86xiRanweATkeE9RsxqxMnYiG9zPThaHWRFHSc04ajILu(Jq06YudG0si5gswAuIYLfidakR0si5gsisoThaHWRFHSc04ajILuMtnKoacHx)czfOX6sEJdvTuMw5z06haHWRFHSc04Eix9dLJkblWdGdGwCyPML2si4bqi86xyQplTfijA(ALRqKjQYI1EaecV(fM6ZsBzfOXqcHcNSQ(VKcAwSqYudGIpR)kZVwhMS0OeLllqgyneE1Mu23tqcHcNSQ(VKcAwSqhaT4Wm3q6WTSc6V(WGnVF4AC4YpmJ)MdNFyryEyXN1)dB(16WdhR9WEdD4CitZh5ZTCdhUphJdxWdpntho30(l7HNWALFygBO9W5WtK5HZX(t0HZXlhEyOhcwGhoq0HBk5nh(rhMXgAp8ewR8dNJtH5Vzb0jKmhEUAccpS3qhohrHf28(H7ZX4Wf8WtZ0bqi86xyQplTLvGgBwq)1kyZ7YudGmZdnTEI5nlblklkymrB01KvIKixeQCkXcrMkd)ePySCOk6)0vg(zcfll5ZgGzQphJ0BA(iFULBinnzIz95yKyHitLHFIumwouf9F6kd)mb9qWs(mKhjsOLqYnKFEauaFaecV(fM6ZsBzfOXMf0FTc28Um1ayFogP308r(Cl3qAAYuFogjlfwyZ7PP5bqi86xyQplTLvGgdRTGoHuqhvSqhahaT4W5T)12NXfEaecV(fMewiqrO1Qq41VkDbDz2iJasqiTccktna2k0Pq7nKnfA9bqi86xysyHSc04WIOn01sk0e2itna2AFogPWIOn01sk0e2KMMmXSwjM3SmnjBkYfSjqbun(1v)qz(msijse)RTpJBshoTUkqIyJeIYIAHYYMra(aOfhM5AC4WAHhoq0HNMYCy4wM0H9g6W)shMXYBoS(zKG(HzN9Cu6Wm3q6Wm2q7HTgQv(Hhb0j0H9MypCERLDylnkr5h(rhMXYB(PF4ynC48wllDaecV(fMewiRanolqSqw14rklfEJmcdcnP8ajNCiqgKPgarrzvuBA9uyTW00KjM5bso5jVYiL)kBr5l(S(Rm)ADyYsJsuUejTcDk0EdztOx(Kys8z9xz(16WKLgLOCzbkmvzrovqtATmhga8bqlomZ14W7F4WAHhMXsRpSTOdZy5n1EyVHo8s50pmGyeuMdpH0HZXmYrh(3d3Fi8WmwEZp9dhRHdN3AzPdGq41VWKWczfOXzbIfYQgpszPWBKPgarrzvuBA9uyTWuTYcigXCqrzvuBA9uyTWKDIcV(LPwHofAVHSj0lFsmj(S(Rm)ADyYsJsuUSafMQSiNkOjTwMddhaT4WsPdlD4wUEIqgo8VhMnwpmTuwrW0HZXlV5WH1cBPpmZnKoCnoS3qgom0ddhE8OdN7SEyij(1cp8JoCnoSHFIo8s50pSOjqYPdZyP1hUthgrH1WHR9WELrhE8Od7n0HxkN(HzmAtPdGq41VWKWczfOXDDyj1qpridYudGqtsRvEGKtouwGSXuR95yK66WsQHEIqgsttMywROOSkQnTEkSwyIYzbDOejOOSkQnTEkSwycrzrTqzZDjsqrzvuBA9uyTWuTYgcV(n11HLud9eHmKe)RTpJlGpacHx)ctclKvGglV5HU2Gc6OIfsMAau8z9xz(16WKLgLOCzbYaR95yK6OpSWYsPP5bWbqi86xysyHSc0ywkTUw5kOjIizQbW2bQIUMsDDyj1qpridkOHvWe0K0ALhi5KdtDDyj1qpridYYat0si5gsELrk)vzroLLTdGq41VWKWczfOXDDyjfAcBKPgaBhOk6Ak11HLud9eHmOGgwbt0si5gsELrk)vzroLLTdGq41VWKWczfOXM)Rvic(tKGKz8i1s50bYWbqi86xysyHSc0y0R1kVHu9FjOm1ayFogj00B0eeQmrKOG1Vj7Z4YuFogj0R1kVHu9Fjyc6HGL8z7aieE9lmjSqwbASfrHTRdlbLPgafFw)vMFTomzPrjkxwJoacHx)ctclKvGgB(E9Rm1ayFogPU(FREc9eIcHlrsFogPWIOn01sk0e2KMMhaT4WT8qRRv(H7HGLd7)HT0iMA)WLtzhEcd50bqi86xysyHSc04jKuLtzYSrgbSDGQORjvToTWYnOKxYJ2V2vpuuAD41kxHOq4psMAaSphJux)VvpHEcrHWLiXRms5VYwu(azZijseFw)vMFTomzPrjkpFGSDaecV(fMewiRanEcjv5uguMAaSphJux)VvpHEcrHWLiXRms5VYwu(azZijseFw)vMFTomzPrjkpFGSDaecV(fMewiRanUR)3QgtKHdGq41VWKWczfOXDcbjel1k)aieE9lmjSqwbA8Oqux)V9aieE9lmjSqwbACScc6OqReHwFaecV(fMewiRangsMWcktna6bso5jVYiL)kBrYYaBhaHWRFHjHfYkqJNqsvoLjdngKWvBKrafge63r)wcvxhqxMAaSvOtH2BiBk0AM6ZXifweTHUwsHMWMK9zCzQphJugL9idQFO0trzvwefzWK9zCzIwcj3qYRms5VklYPS5HjK3v95yaZhqpacHx)ctclKvGgpHKQCktMnYiGrUGnbkGQXVU6hkZNrcjtna2AFogPWIOn01sk0e2KMMm1AFogPUoSKAONiKH00KjX)A7Z4MclI2qxlPqtytcrzrTW8zaqpaAXHBPsidhg9t5nAdhgn10H)XH9MzwVgfzpCw4nWd3j9Zyl9HzUH0Hhp6WmxllMV9Wcu5YC43BieJfKomJL3C4CtU9WHFy2mI1dd9qWc8Wp6WmyeRhMXYBoCOH)HLs)V9WtZ0bqi86xysyHSc04jKuLtzYSrgbmGnTJLGkuKRhPepk0YudGwQphJekY1JuIhfALL6ZXizFgxjsSuFogjXV2PWR2KQwwuwQphJ00KjpqYjp1qH2BsMcpFaHnM8ajN8udfAVjzkCzbcigjrsRwQphJK4x7u4vBsvllkl1NJrAAYeZSuFogjuKRhPepk0kl1NJrc6HGfzbYMrmhgmI5BP(CmsD9)w1puEdPOLYmKMMsKmk5nUcrzrTW8ZlJamt95yKclI2qxlPqtytcrzrTqzzi3paAXHZr0iMA)WJqR7HGLdpE0HNWORPdxoLbthaHWRFHjHfYkqJNqsvoLbLPga7ZXi11)B1tONquiCjsgL8gxHOSOwy(azZijseFw)vMFTomzPrjkpFGSDaCa0IdN3HqAfe8aieE9lmrqiTcccu8RGwhfozvdDKrYudG0si5gsELrk)vzroLLbMATphJuxhwsn0teYqAAYeZA1(Es8RGwhfozvdDKrQ(eTjVeSuRCMAneE9Bs8RGwhfozvdDKrPAvdDjVXLizm1AfIenbsoP8kJYxUWMYICc4dGq41VWebH0kiiRanUR)3Q(HYBifTuMbzQbW2bQIUMsDDyj1qpridkOHvWK4FT9zCtDYzKOv5nKImqW00KP2bQIUMsDNuIFTLx)YeZGMKwR8ajNCyQRdlPg6jczqwGSjrckkRIAtRNcRfMQv28aOawIKrjVXviklQfMpqgm6aieE9lmrqiTccYkqJLpdKTIv9dvKlc9EZbqi86xyIGqAfeKvGgpEXeswvKlcvoP6uKjtnacnjTw5bso5Wuxhwsn0teYGSaztIeuuwf1MwpfwlmvRS5Lrm1AFogPWIOn01sk0e2KMMsKmk5nUcrzrTW8zWOdGq41VWebH0kiiRan2CIQHHALR66a6YudGqtsRvEGKtom11HLud9eHmilq2KibfLvrTP1tH1ct1kBEzKejJsEJRquwulmFgm6aieE9lmrqiTccYkqJ9gsn3(pxRA8ibjtna2NJrcrcw0eeQgpsqPPPej95yKqKGfnbHQXJeKs8Z1juc6HGL8zWOdGq41VWebH0kiiRangvMMAsvRcAgc6aieE9lmrqiTccYkqJz8rABBQwfIG)gRGoacHx)cteesRGGSc04mk7rgu)qPNIYQSikYGYudG0si5gYppa6bqloComV2E4ClfM1k)WTCDKrWdpE0HPCsIPthgfRC6Wp6WSuA9H7ZXakZHRXHnFiS6AkD4CJMXWa8WoYWH9)WYj)WEdDy9Zib9dl(xBFg3d3dizp8VhoAhLo6A6W0szfbthaHWRFHjccPvqqwbAmIcZALRg6iJGYimi0KYdKCYHazqMAa0dKCYtELrk)v2IYNHeGkrcZyMhi5KNAOq7njtHlBUBKejEGKtEQHcT3KmfE(azZiaZeZcHxTjfTuwrqGmirIhi5KN8kJu(RSfjlB5aadyjsyMhi5KN8kJu(RmfUInJKfqmIjMfcVAtkAPSIGazqIepqYjp5vgP8xzls28Khad4dGdGwC4wETfSHqWdGwCyP88(H)2e6W5wxQdJi0R1WdZy5nhohrHf28UX5gbDyhfLdp8JoCUD6nAccpCldrIcw)MoacHx)ctJAlydWo5ms0Q8gsrgiOm1ay7avrxtPUtkXV2YRFpacHx)ctJAlydRangQlbPI1QSLGKPgahL8gxHOSOwOS95yKG6sqQyTkBjOeIYIAHmHObIGnrxthaT4Ws559dZy5nh2BOdNBe0HzUnpCo2FIomOMO20HF0HZruyHnVFyhfLdthaHWRFHPrTfSHvGg3jNrIwL3qkYabLPgaJCrOYPuii10uz4NifutuBkrB01KvIKixeQCkzPWcBEprB01K9aieE9lmnQTGnSc0yBbndx0CaCa0Idd6uO9MdGq41VWe0Pq7naH6ykVXjKm1ayFogjOoMYBCcPm)c(BY(mUhaHWRFHjOtH2ByfOXIgkmvWM3LryqOjLhi5KdbYGm1aOhAA9KjImO(v5nKIrkyjrB01KLPw9ajN8ubv9hcpacHx)ctqNcT3WkqJJS(e2WbBtiy9lxA2mInJmkhyeGWbzmqBTYHCqMRmZh5K9WTKdhcV(9W6c6W0bahuxqhYzNdsqiTccYzNlndC25G0gDnz5sXbfOYjufCqAjKCdjVYiL)QSiNhw2dZWHz6WTE4(CmsDDyj1qpridPP5Hz6Wm7WTEy77jXVcADu4Kvn0rgP6t0M8sWsTYpmthU1dhcV(nj(vqRJcNSQHoYOuTQHUK34hwIKdpMATcrIMajNuELrho)dlxytzropmG5GHWRF5GIFf06OWjRAOJmI7CPzJZohK2ORjlxkoOavoHQGd2oqv01uQRdlPg6jczqbnSIdZ0Hf)RTpJBQtoJeTkVHuKbcMMMhMPd3oqv01uQ7Ks8RT863dZ0Hz2HHMKwR8ajNCyQRdlPg6jcz4WYc8WSDyjsomkkRIAtRNcRfMQ9WYE48aOhgWhwIKdpk5nUcrzrTWdNpWdZGrCWq41VCWU(FR6hkVHu0szg4oxAaHZohmeE9lhu(mq2kw1purUi07nCqAJUMSCP4ox68WzNdsB01KLlfhuGkNqvWbHMKwR8ajNCyQRdlPg6jcz4WYc8WSDyjsomkkRIAtRNcRfMQ9WYE48YOdZ0HB9W95yKclI2qxlPqtytAAEyjso8OK34keLf1cpC(hMbJ4GHWRF5GJxmHKvf5IqLtQofzCNlnGYzNdsB01KLlfhuGkNqvWbHMKwR8ajNCyQRdlPg6jcz4WYc8WSDyjsomkkRIAtRNcRfMQ9WYE48YOdlrYHhL8gxHOSOw4HZ)WmyehmeE9lh0CIQHHALR66a6CNlDEXzNdsB01KLlfhuGkNqvWb7ZXiHiblAccvJhjO008WsKC4(CmsisWIMGq14rcsj(56ekb9qWYHZ)WmyehmeE9lh0Bi1C7)CTQXJee35s3s4SZbdHx)YbrLPPMu1QGMHG4G0gDnz5sXDU05oNDoyi86xoiJpsBBt1Qqe83yfehK2ORjlxkUZLohWzNdsB01KLlfhuGkNqvWbPLqYnC48pCEauoyi86xoygL9idQFO0trzvwefzqUZLMbJ4SZbPn6AYYLIdgcV(LdIOWSw5QHoYiihuGkNqvWb9ajN8KxzKYFLTOdN)HzibOhwIKdZSdZSd7bso5Pgk0EtYu4hw2dN7gDyjsoShi5KNAOq7njtHF48bEy2m6Wa(WmDyMD4q4vBsrlLve8WapmdhwIKd7bso5jVYiL)kBrhw2dZwo4Wa(Wa(WsKCyMDypqYjp5vgP8xzkCfBgDyzpmGy0Hz6Wm7WHWR2KIwkRi4HbEygoSejh2dKCYtELrk)v2IoSShop55Wa(WaMdkmi0KYdKCYHCPzG7CNdAPrm1oNDU0mWzNdsB01KLlfhuGkNqvWbB9WqNcT3q2e6Lpjoyi86xoilLGfUZLMno7CWq41VCqOtH2B4G0gDnz5sXDU0acNDoiTrxtwUuCW3KdcjNdgcV(Ld2oqv01ehSDONehu8z9xz(16WKLgLO8dllWdZ2Hz9WSDyM)Hz2H9qtRNK38qxBqbDuXcLOn6AYEyMoS4FT9zCtYBEORnOGoQyHsiklQfE48pmdhgWhM1d3NJrQJ(WcllLMMhMPdtlHKB4WYE48YOdZ0HB9W95yKGSm1AvSwLa9qy)xcMMMhMPd36H7ZXiXcrMkd)ePySCOk6)0vg(zAAYbBhi1gzehmY6tyJs8RT86xUZLopC25G0gDnz5sXbFtoiKCoyi86xoy7avrxtCW2HEsCW(CmsOP3OjiuzIirbRFttZdlrYHz2HJCrOYPKLclS59eTrxt2dlrYHJCrOYPuii10uz4NifutuBkrB01K9Wa(WmD4(CmsOxRvEdP6)sW00Kd2oqQnYioy3jL4xB51VCNlnGYzNdsB01KLlfh8n5GqY5GHWRF5GTdufDnXbBh6jXbHMKwR8ajNCyQRdlPg6jcz4W5Fy2omthgfLvrTP1tH1ct1EyzpmBgDyjsoCFogPUoSKAONiKH00Kd2oqQnYioyxhwsn0teYGcAyfCNlDEXzNdsB01KLlfhuGkNqvWbHofAVHSPqR5GHWRF5GIqRvHWRFv6c6CqDbD1gzehe6uO9gUZLULWzNdsB01KLlfhmeE9lhueATkeE9RsxqNdQlOR2iJ4GclK7CPZDo7CqAJUMSCP4Gcu5eQcoyFogjs081kxHituLfRnnnpmthUphJejA(ALRqKjQYI1MGEiy5WapS4Z6VY8R1HhwIKdl(S(Rm)AD4HLf4HfMQSiNkOjT2dZComZoCFogPo6dlSSuAAEywpCFogP308r(Cl3qAAEyaFyM)Hz2H9qtRNyEZsWIYIcgt0gDnzpmthMzhU1d7HMwpLfiwiRA8iLLcVjrB01K9WsKCyX)A7Z4MYcelKvnEKYsH3Kquwul8WYEygomGpmGpmZ)Wm7WrUiu5ukeKAAQm8tKcQjQnLqXYYHZ)WSDyjsoCRhw8V2(mUPo5ms0Q8gsrgiyAAEyjsoCRhUphJe61AL3qQ(VemnnpmG5GHWRF5GO5QcHx)Q0f05G6c6QnYio4O2c2WDU05ao7CqAJUMSCP4GHWRF5GIqRvHWRFv6c6CqDbD1gzehSplTL7CPzWio7CqAJUMSCP4Gcu5eQcoiTesUHKLgLO8dllWdZaGEywpmTesUHeIKtlhmeE9lhmqIyjL)ieTo35sZadC25GHWRF5GbselPmNAiXbPn6AYYLI7CPzGno7CWq41VCqDjVXHQwktR8mADoiTrxtwUuCNlndacNDoyi86xoypKR(HYrLGfihK2ORjlxkUZDoOjIeFwpCo7CPzGZohmeE9lhSwOhRRm)c(lhK2ORjlxkUZLMno7CWq41VCqbQmn11kxz(f8xoiTrxtwUuCNlnGWzNdgcV(LdUZSETYvMFb)LdsB01KLlf35sNho7CqAJUMSCP4GVjhesohmeE9lhSDGQORjoy7qpjoy4EiyrjqLFyzpSrP8WghSDGuBKrCWVnHuitLavUYBqeS51wUZLgq5SZbdHx)YbnFV(LdsB01KLlf35sNxC25G0gDnz5sXbdHx)YbZcelKvnEKYsH3WbfOYjufCquuwf1Mwpfwlmv7HL9W5XioOjIeFwpCfKe)AHCqaL7CPBjC25G0gDnz5sXbfOYjufCqMD4wpmX8MLPjztMVGfYHvUiRs8zMtp86xLLAxc6WsKC4wpS4FT9zCtcdc97OFlHQRdONStu41VhwIKdJIYQO206PABp1lHIUMsuolOdpmG5GHWRF5GqNcT3WDU05oNDoiTrxtwUuCWq41VCqOUeKkwRYwcIdkqLtOk4GiAGiyt010Hz6W95yKG6sqQyTkBjOeIYIAHho)d7vgP8xzl6WmD4(CmsqDjivSwLTeucrzrTWdN)Hz2Hz4WSEyXN1FL5xRdpmGpmZ)WmKYDoOjIeFwpCfKe)AHCqaH7CPZbC25G0gDnz5sXbdHx)YbdlI2qxlPqtydhuGkNqvWbz2HB9WeZBwMMKnz(cwihw5ISkXNzo9WRFvwQDjOdlrYHB9WI)12NXnjmi0VJ(TeQUoGEYorHx)EyjsomkkRIAtRNQT9uVek6Akr5SGo8WaMdAIiXN1dxbjXVwihKbUZLMbJ4SZbPn6AYYLIdUrgXbJCbBcuavJFD1puMpJeIdgcV(Ldg5c2eOaQg)6QFOmFgje35sZadC25G0gDnz5sXbdHx)YbrVwR8gs1)LGCqtej(SE4kij(1c5GSXDU0mWgNDoiTrxtwUuCWq41VCqHbH(D0VLq11b05Gcu5eQcoyRhgfLvrTP1t12EQxcfDnLOCwqhYbPXGeUAJmIdkmi0VJ(TeQUoGo35ohSplTLZoxAg4SZbdHx)YbjrZxRCfImrvwSwoiTrxtwUuCNlnBC25G0gDnz5sXbfOYjufCqXN1FL5xRdtwAuIYpSSapmdhM1dhcVAtk77jiHqHtwv)xsbnlwioyi86xoiKqOWjRQ)lPGMfle35sdiC25G0gDnz5sXbfOYjufCqMDyp006jM3SeSOSOGXeTrxt2dlrYHJCrOYPelezQm8tKIXYHQO)txz4NjuSSC48pmBhgWhMPd3NJr6nnFKp3YnKMMhMPdZSd3NJrIfImvg(jsXy5qv0)PRm8Ze0dblho)dZqEoSejhMwcj3WHZ)W5bqpmG5GHWRF5GMf0FTc28o35sNho7CqAJUMSCP4Gcu5eQcoyFogP308r(Cl3qAAEyMoCFogjlfwyZ7PPjhmeE9lh0SG(RvWM35oxAaLZohmeE9lhewBbDcPGoQyH4G0gDnz5sXDUZbHofAVHZoxAg4SZbPn6AYYLIdkqLtOk4G95yKG6ykVXjKY8l4Vj7Z4YbdHx)YbH6ykVXje35sZgNDoiTrxtwUuCWq41VCqrdfMkyZ7CqbQCcvbh0dnTEYergu)Q8gsXifSKOn6AYEyMoCRh2dKCYtfu1FiKdkmi0KYdKCYHCPzG7CPbeo7CWq41VCWiRpHnCqAJUMSCP4o35GclKZoxAg4SZbPn6AYYLIdkqLtOk4GTEyOtH2BiBk0Aoyi86xoOi0Avi86xLUGohuxqxTrgXbjiKwbb5oxA24SZbPn6AYYLIdkqLtOk4GTE4(CmsHfrBORLuOjSjnnpmthMzhU1dtmVzzAs2uKlytGcOA8RR(HY8zKqhwIKdl(xBFg3KoCADvGeXgjeLf1cpSShMnJomG5GHWRF5GHfrBORLuOjSH7CPbeo7CqAJUMSCP4GHWRF5GzbIfYQgpszPWB4Gcu5eQcoikkRIAtRNcRfMMMhMPdZSd7bso5jVYiL)kBrho)dl(S(Rm)ADyYsJsu(HLi5WTEyOtH2BiBc9YN0Hz6WIpR)kZVwhMS0OeLFyzbEyHPklYPcAsR9WmNdZWHbmhuyqOjLhi5Kd5sZa35sNho7CqAJUMSCP4Gcu5eQcoikkRIAtRNcRfMQ9WYEyaXOdZComkkRIAtRNcRfMStu41VhMPd36HHofAVHSj0lFshMPdl(S(Rm)ADyYsJsu(HLf4HfMQSiNkOjT2dZComdCWq41VCWSaXczvJhPSu4nCNlnGYzNdsB01KLlfhuGkNqvWbHMKwR8ajNC4HLf4Hz7WmD4wpCFogPUoSKAONiKH008WmDyMD4wpmkkRIAtRNcRfMOCwqhEyjsomkkRIAtRNcRfMquwul8WYE4C)WsKCyuuwf1Mwpfwlmv7HL9WHWRFtDDyj1qpridjX)A7Z4EyaZbdHx)Yb76WsQHEIqg4ox68IZohK2ORjlxkoOavoHQGdk(S(Rm)ADyYsJsu(HLf4Hz4WSE4(CmsD0hwyzP00KdgcV(LdkV5HU2Gc6OIfI7CPBjC25G0gDnz5sXbfOYjufCW2bQIUMsDDyj1qpridkOHvCyMom0K0ALhi5KdtDDyj1qpridhw2dZWHz6W0si5gsELrk)vzropSShMnoyi86xoilLwxRCf0ere35sN7C25G0gDnz5sXbfOYjufCW2bQIUMsDDyj1qpridkOHvCyMomTesUHKxzKYFvwKZdl7HzJdgcV(Ld21HLuOjSH7CPZbC25G0gDnz5sXbhpsTuoDU0mWbdHx)Ybn)xRqe8NibXDU0myeNDoiTrxtwUuCqbQCcvbhSphJeA6nAccvMisuW63K9zCpmthUphJe61AL3qQ(Vemb9qWYHZ)WSXbdHx)YbrVwR8gs1)LGCNlndmWzNdsB01KLlfhuGkNqvWbfFw)vMFTomzPrjk)WYEyJ4GHWRF5Gwef2UoSeK7CPzGno7CqAJUMSCP4Gcu5eQcoyFogPU(FREc9eIcHFyjsoCFogPWIOn01sk0e2KMMCWq41VCqZ3RF5oxAgaeo7CqAJUMSCP4GHWRF5GTdufDnPQ1PfwUbL8sE0(1U6HIsRdVw5kefc)rCqbQCcvbhSphJux)VvpHEcrHWpSejh2Rms5VYw0HZh4HzZOdlrYHfFw)vMFTomzPrjk)W5d8WSXb3iJ4GTdufDnPQ1PfwUbL8sE0(1U6HIsRdVw5kefc)rCNlnd5HZohK2ORjlxkoOavoHQGd2NJrQR)3QNqpHOq4hwIKd7vgP8xzl6W5d8WSz0HLi5WIpR)kZVwhMS0OeLF48bEy24GHWRF5GtiPkNYGCNlndakNDoyi86xoyx)VvnMidCqAJUMSCP4oxAgYlo7CWq41VCWoHGeILALZbPn6AYYLI7CPzOLWzNdgcV(Ldoke11)B5G0gDnz5sXDU0mK7C25GHWRF5GXkiOJcTseAnhK2ORjlxkUZLMHCaNDoiTrxtwUuCqbQCcvbh0dKCYtELrk)v2IoSShMb24GHWRF5GqYewqUZLMnJ4SZbPn6AYYLIdgcV(Ldkmi0VJ(TeQUoGohuGkNqvWbB9WqNcT3q2uO1hMPd3NJrkSiAdDTKcnHnj7Z4EyMoCFogPmk7rgu)qPNIYQSikYGj7Z4EyMomTesUHKxzKYFvwKZdl7HZZHz6WiVR6ZXaE48pmGYbPXGeUAJmIdkmi0VJ(TeQUoGo35sZgdC25G0gDnz5sXbdHx)YbJCbBcuavJFD1puMpJeIdkqLtOk4GTE4(CmsHfrBORLuOjSjnnpmthU1d3NJrQRdlPg6jczinnpmthw8V2(mUPWIOn01sk0e2Kquwul8W5Fygauo4gzehmYfSjqbun(1v)qz(msiUZLMn24SZbPn6AYYLIdgcV(LdgWM2XsqfkY1JuIhfAoOavoHQGdAP(CmsOixpsjEuOvwQphJK9zCpSejh2s95yKe)ANcVAtQAzrzP(CmstZdZ0H9ajN8udfAVjzk8dN)Hbe2omth2dKCYtnuO9MKPWpSSapmGy0HLi5WTEyl1NJrs8RDk8QnPQLfLL6ZXinnpmthMzh2s95yKqrUEKs8OqRSuFogjOhcwoSSapmBgDyMZHzWOdZ8pSL6ZXi11)Bv)q5nKIwkZqAAEyjso8OK34keLf1cpC(hoVm6Wa(WmD4(CmsHfrBORLuOjSjHOSOw4HL9WmK7CWnYioyaBAhlbvOixpsjEuO5oxA2aeo7CqAJUMSCP4Gcu5eQcoyFogPU(FREc9eIcHFyjso8OK34keLf1cpC(apmBgDyjsoS4Z6VY8R1Hjlnkr5hoFGhMnoyi86xo4esQYPmi35ohCuBbB4SZLMbo7CqAJUMSCP4Gcu5eQcoy7avrxtPUtkXV2YRF5GHWRF5GDYzKOv5nKImqqUZLMno7CqAJUMSCP4Gcu5eQco4OK34keLf1cpSShUphJeuxcsfRvzlbLquwul8WmDyenqeSj6AIdgcV(Ldc1LGuXAv2sqCNlnGWzNdsB01KLlfhuGkNqvWbJCrOYPuii10uz4NifutuBkrB01K9WsKC4ixeQCkzPWcBEprB01KLdgcV(Ld2jNrIwL3qkYab5ox68WzNdgcV(LdAlOz4IgoiTrxtwUuCN7CNdgtV5rCqWklVXDUZ5]] )

end