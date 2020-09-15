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

            spend = 50,
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


    spec:RegisterPack( "Outlaw", 20200914.2, [[d8KpbbqirjpsIWMqGprOO0OuH6uQqwLOu8kc0SiuDlrb2Li)IcAyIIoMkYYqKEMePMMerxtuQ2MOq(gckmorP05iuO1HGImpeK7Hq7JcCqrHYcjipebLMOOq1frqvTrrbzKiOO6KiOkRuI6LIcQAMekk6MekQStcQFIGknucf4OiOOSucf0tvvtLaUkcQyRIcQ8vrbLZsOOWEr6VuAWahMQflPhtYKj1LrTzv6ZeYOLWPLA1ekQ61iIzt0Tfv7wPFdA4u0XjuKLd1ZHmDHRRkBxf8DvuJNqPZJOwVejZNcTFftprfG(1EWuHjntsZmtX4PsMinZtLM0mI(dYMm9B6ksCrm9VEot)eUVq6NPFtNSe6AQa0pc(WkM(lIWeryYqdf1rXRMuWCdrD(t6rdxf2VHHOoxzi9xFTmi8wAL(1EWuHjntsZmtX4PsMinZtLM0st)itwrfM0mkt6VO1AEPv6xZif9xIbq4(cPFEaIHqrpEkxIb8zZGZRmEaNkP4dG0mjnZP8uUedid1yumGo3eIJbCXW8b87Cc7aqklgk6XjLPzI(nXWBlz6VedGW9fs)8aedHIE8uUed4ZMbNxz8aovsXhaPzsAMt5PCjgqgQXOyaDUjehd4IH5d435e2bGuwmu0JtktZ0uEkxIbq4lww9cwpGkFHyEakyE1Jbuzr9IsdiJPuSzGgWc3mOWX53NCaUkA4IgaCLKttzxfnCrjtmRG5vpi6MMsYwtyJG7u2vrdxuYeZkyE1dbjA4v6isMYUkA4IsMywbZREiird9NOCEdpA4oLDv0WfLmXScMx9qqIgEHq9uUed4VUjQagda7TEa139Y6bGcpqdOYxiMhGcMx9yavwuVOb4REaMyodmHr0ROb0ObOHlNMYUkA4IsMywbZREiirdrRBIkGHffEGMYUkA4IsMywbZREiirdnHrd3PSRIgUOKjMvW8Qhcs0WChtcRTxi2Qzpke3eZkyE1dlIvWvJiMDX7lrS3AlFG3i5Ank1RbLmZPSRIgUOKjMvW8Qhcs0quWUmkeVVepolwm9AttwNmHks4a1LI1wfm38fE0W1Q5dTInAmlfek1WZBsrwjHbgUTYwLoks6h2JgUgnI9wB5d8gPEp8KlJ9QKtSyBuGoAk7QOHlkzIzfmV6HGenedLsBuW2kCzK4MywbZREyrScUAersNYUkA4IsMywbZREiirdrYwXwF1wDRyXnXScMx9WIyfC1iIKoLDv0WfLmXScMx9qqIg6AmVUSx2IFOcXnXScMx9WIyfC1iINeVVepolwm9AttwNmHks4a1LI1wfm38fE0W1Q5dTInAmlfek1WZBsrwjHbgUTYwLoks6h2JgUgnI9wB5d8gPEp8KlJ9QKtSyBuGoAk7QOHlkzIzfmV6HGen8HyBhCU4RNZe9sHkCSJSx4gw41AcpZ4PSRIgUOKjMvW8Qhcs0WhITDW5IZ3lRc765mrfzLegy42kBv6Oq8(smlS3AlFG3i17HNCzSxLCIfBJc0uEkxIbq4lww9cwpa(aJjpGOZ5bef8aCvaXdOrdWp4T0RsonLDv0WfrKKwrYuUedqmKrb7YOya9DaMqeQRsEahVWbC4jxg7vjpaE58MrdO3bOG5vpoAk7QOHlsqIgIc2LrXuUedGW(WyEdj5bSWyaNH4OyaygdLYEfnGEhWxmZb07a8L8aizHN3bG645rd3PSRIgUibjA4bh3EvYIVEotehvlMXqPu8dU8XeZCk7QOHlsqIgEWXTxLS4RNZe986dvyvWv3rdxXp4YhtubZRqRjS3aL08TvDyarsfK0S54WL8gjrfquijBrbUjHt86vjRjqbHsn88MevarHKSff4MeoH5CVxeHoDKG139MQyORrTMtptc4LXIiBqgLjbzvF3BcrYtkT(QTkmeHQWLrPNjbzvF3BIeMnTKHpS9ChiRxHVWsg(spZPCjgqgwhfdi)jJ2uYdiCSioqIpGOOrd4GJBVk5b0ObOkyfjSEabCaAw1AEaNl4OGXdabZ5bqyZ4ObGkGpPEavEaiYRI1d4ChfdqiPR5bKHKpmM8u2vrdxKGen8GJBVkzXxpNjwLUMTx5dJjBrKxL4hC5JjImzP0gowehOuv6A2ELpmMmHiLaS3AlFG3i5Ank1RbKMPrJ139MQsxZ2R8HXKtpZPSRIgUibjAOYLsRRIgUwzJcXxpNjIc2LrH49LikyxgfSo5s5u2vrdxKGenu5sP1vrdxRSrH4RNZevA0uUedid1BJkgGhdi3fBN)YhaHvminG)RIcSRIbaxEaxiEaSRkgGqyORrTMhGV6bq4AAcXXB7G8aoxW7aim71ksgqgh7NhqJgaILSky9a8vpaXC3m(aA0awymam7AYdWVbJhquWdyzXgdaXk4QtdiJjp7Krdi3f7aeki8hW5okgaPcoGmMIttzxfnCrcs0q8BTUkA4ALnkeF9CM4T3gviEFjQG5vO1e2BGmGOY0M7I1Im5vNbhxF3BQIHUg1Ao9mfS(U3e00eIJ32b50Z8OS54WL8gjX0RvKy1y)CIxVkznbhNv4sEJuUJjH12leB1ShfjE9QK1gnQGqPgEEt5oMewBVqSvZEuKWCU3lYGthDu2CSxkg3bNCfBFMwYWh2IKmFGtyFjHqKA0ywkiuQHN3uLJZmV2OGTmzgLEMhz0OcMxHwtyVbIOVDURkCSiwBvMtzxfnCrcs0qLlLwxfnCTYgfIVEotS(APEk7QOHlsqIg6yLVSnGymVH49LiVmwe5KMVTQddiEk7cYlJfroHzr8oLDv0WfjirdDSYx2A(KiEk7QOHlsqIgkBrfbYkM)PfLZBmLDv0WfjirdRUil8AdCRibnLNYLyac9APMXOPSRIgUOu91snrwva7vKfZM4o3x9u2vrdxuQ(APwqIgIym2dwBRWLTiZMewCfzLKTHJfXbI4jX7lXS0WiHym2dwBRWLTiZMeofTIKEfz0ORI(aB5LZBgr8ebyV1w(aVrY1AuQxdUpP0IzvHJfX2OZzJgvfoweJmGucUTOIWI5CVxeHY(uUedGWbXdqmOrbuoGFbmgqFhqhd4mCfZgdq5MdqbZRWbyc7nqdWx9aIcEaeUMMqC82oipG67EhqJgWZmnGm2byRhWd1RObCUG3bKHNzZbiMb8HhqgwhObGcxrcAaoMhqrlQyaq8aoxW7aEOEfnGmm2nHBUJcgl(aERKrObef8aY4SRrfWya139oGgnGNzAk7QOHlkvFTulirdnBuaLwubmeVVepoCjVrsm9Afjwn2pN41RswB0Oxkg3bNiHztlz4dBp3bY6v4lSKHVe2xsiePhrq9DVjOPjehVTdYPNjbhxF3BIeMnTKHpS9ChiRxHVWsg(sOWvKqOtL0OrEzSiYeQKz)OPSRIgUOu91sTGen0SrbuArfWq8(sS(U3e00eIJ32b50ZKGJRV7nPzxJkGr6zA0y9DVjryMxej9ISNBfjmgLEMgnwF3Bsbxf7swBRY3QzC9HqPN5rtzxfnCrP6RLAbjAiQ3gfm2IcCtcpLNYLyaewiuQHNx0u2vrdxusPrevUuADv0W1kBui(65mrgH4vXiX7lXSqb7YOG1jxkNYUkA4IsknsqIg6AmVUSx2IFOcX7lXSQV7n5AmVUSx2IFOI0ZKGJZIftV20K1jVuOch7i7fUHfETMWZm2Orfek1WZBs6bVH1XkF9eMZ9ErgqAMhnLDv0WfLuAKGenedLsBuW2kCzK49Ly9DVjmukTrbBRWLrjmN79IieXsB04bh3EvYjCuTygdLYPCjgaH3DaUwJgGJ5b8mfFaOTn5bef8aGlpGZDumaj8mJIbiGaz80aiCq8aoxW7a0K7v0aUoky8aIcFhaHvmyaA(2QogaepGZDuaFXa8L8aiSIbPPSRIgUOKsJeKOH5oMewBVqSvZEuiUISsY2WXI4ar8K49Li2BTLpWBKCTgLEMeC8TfvewmN79IiKcMxHwtyVbkP5BR6WOXSqb7YOG1jmu0JjqbZRqRjS3aL08TvDyarLPn3fRfzYRodoD0uUedGW7oGfoaxRrd4ClLdq38ao3rrVdik4bSSyJbu6mrIpGhIhGyUBgFaWDavicnGZDuaFXa8L8aiSIbPPSRIgUOKsJeKOH5oMewBVqSvZEuiEFjI9wB5d8gjxRrPEnO0zMbyV1w(aVrY1Aus)WE0WLGSqb7YOG1jmu0JjqbZRqRjS3aL08TvDyarLPn3fRfzYRodonLlXaes6AEazi5dJjpa4oasfCa8Y5nJsdidRJIb4AnIW0aiCq8a67aIcM8aqHtEaxiEazRGdaXk4QrdaIhqFhaz4dpGLfBmavHJfXd4ClLdOYdaZUM8a6DarNZd4cXdik4bSSyJbC2pWPPSRIgUOKsJeKOHvPRz7v(WyYI3xIitwkTHJfXbYaIKsqw139MQsxZ2R8HXKtptcoolS3AlFG3i5AnkXITrbYOrS3AlFG3i5AnkH5CVxKbzRrJyV1w(aVrY1AuQxdoM0mqbHsn88MQsxZ2R8HXKtQchlIr2l2vrdxxEu2qA2pAkxIbiK018aYqYhgtEaWDaNeya9DaKHp8awwSXaufowepGZTuoGkpam7AYdO3beDopGlepGOGhWYIngWz)aNMYUkA4IsknsqIgwLUMTx5dJjlEFjImzP0gowehiINia7T2Yh4nsUwJs9AWXKMbkiuQHN3uv6A2ELpmMCsv4yrmYEXUkA46YJYgsZ(u2vrdxusPrcs0qrfquijBrbUjHfVVevW8k0Ac7nqjnFBvhgq8KG139MQyORrTMtpZPSRIgUOKsJeKOHK0szVISitmZI3xIhCC7vjNQsxZ2R8HXKTiYRIaKjlL2WXI4aLQsxZ2R8HXKn4eb8YyrKtrNZ2aAZDXAaPtzxfnCrjLgjirdRsxZw8dviEFjEWXTxLCQkDnBVYhgt2IiVkc4LXIiNIoNTb0M7I1asNYLyaeoOEfnGmC(2OcdZy51hQyanAaWvsEa(aoWyYdi6L8a6vHzhXIpaeCa9oam7Yoil(aidFIzX8a8kckFbljpGBV8ac4aEiEaDmahnaFaVOLDqEaitwkttzxfnCrjLgjirdp4BJkeVVeZcfSlJcwNCPKGdoU9QKtEE9HkSk4Q7OH7u2vrdxusPrcs0qnMDDv6AgjEFjMfkyxgfSo5sjbkyEfAnH9gicr80u2vrdxusPrcs0quHRHNZzPw8(smluWUmkyDYLsco442Rso551hQWQGRUJgUtzxfnCrjLgjirdrSjQrI3xIzHc2LrbRtUuoLDv0WfLuAKGen0egnCfVVeRV7nvLqOw(qrcZUkmAS(U3KRX86YEzl(HkspZPSRIgUOKsJeKOHvjeQT3hM8u2vrdxusPrcs0WkJrmMKEfnLDv0WfLuAKGen82yUkHq9u2vrdxusPrcs0qFvmkWU0QCPCk7QOHlkP0ibjA4dX2o4CX57LvHD9CMOISscdmCBLTkDuiEFjMfkyxgfSo5sjb139MCnMxx2lBXpursdpVeuF3BkNZHyYw41kFQwB1y2Zrjn88saVmwe5u05SnG2CxSguscWr1wF3lIqzFk7QOHlkP0ibjA4dX2o4CXxpNj6Lcv4yhzVWnSWR1eEMXI3xIzvF3BY1yEDzVSf)qfPNjbzvF3BQkDnBVYhgto9mjqbHsn88MCnMxx2lBXpurcZ5EVicDk7t5smGmCmM8aWWNOcj5bGFsEaW7aIIxETVnRhqUhfObuzj8mHPbq4G4bCH4bq4TKyc1dqH7q8baJcgFUr8ao3rXaYyIHdWJbqAMcoau4ksqdaIhWPmfCaN7OyaUebhGqsiupGNzAk7QOHlkP0ibjA4dX2o4CXxpNj6OId(Yil2lfeBvqSlfVVe1C9DVjSxki2QGyxA1C9DVjn88A0OMRV7nPGR(PI(aB7LeRMRV7n9mjiCSiosfSlJIKPkiuPjLGWXI4ivWUmksMQWaILotJgZsZ139MuWv)urFGT9sIvZ139MEMeCSMRV7nH9sbXwfe7sRMRV7nHcxrIbejnZm4uMzJMRV7nvLqO2cV2OGT8Y5KtptJgVTOIWI5CVxeHYOmpIG67EtUgZRl7LT4hQiH5CVxKbNY2PCjgqgNV(tgd46sz1vKmGlepGhYRsEaDW5O0u2vrdxusPrcs0WhITDW5iX7lX67EtvjeQLpuKWSRcJgVTOIWI5CVxeHisAMgnQG5vO1e2BGsA(2QoiersNYt5smacFeIxfJMYUkA4IsmcXRIrevWvXBG9G12R0ZzX7lrEzSiYPOZzBaT5Uyn4ebzvF3BQkDnBVYhgto9mj44S0WiPGRI3a7bRTxPNZ26dVPOvK0RicYYvrd3KcUkEdShS2ELEoN61ELTOIWOX7tkTywv4yrSn6CMqIu6uUl2JMYUkA4IsmcXRIrcs0WQec1w41gfSLxoNS49L4bh3EvYPQ01S9kFymzlI8QiqbHsn88MQCCM51gfSLjZO0ZKGJrMSuAdhlIduQkDnBVYhgt2aIKA0i2BTLpWBKCTgL61GsM9JMYUkA4IsmcXRIrcs0qrphRBFTWR1lfJHrXu2vrdxuIriEvmsqIgEHQhI1wVumUd2wzpx8(sezYsPnCSioqPQ01S9kFymzdisQrJyV1w(aVrY1AuQxdYOmjiR67EtUgZRl7LT4hQi9mNYUkA4IsmcXRIrcs0qZhUVK7vKTkDuiEFjImzP0gowehOuv6A2ELpmMSbej1OrS3AlFG3i5Ank1RbzuMtzxfnCrjgH4vXibjAyuW23wHVvBVqSIfVVeRV7nHzfjsgHSxiwXPNPrJ139MWSIejJq2leRyRc(2GXju4ksi0PmNYUkA4IsmcXRIrcs0qCBAkzBVwKPR4PSRIgUOeJq8QyKGen8mel1h4ETygbxFv8u2vrdxuIriEvmsqIgMZ5qmzl8ALpvRTAm75iX7lrEzSiYeQKzFkxIbqyouQhGyi7M9kAaziPNZObCH4bWILvVGha2xr8aG4bqslLdO(UxK4dOVdWeIqDvYPbKXKNDYObeyYdiGdqehdik4biHNzumafek1WZ7aQoI1daUdWp4T0RsEa8Y5nJstzxfnCrjgH4vXibjAiMDZEfzVspNrIRiRKSnCSioqepjEFjgowehPOZzBaT6Mj0Pu2nA84JdhlIJub7YOizQcdY2mnAmCSiosfSlJIKPkiersZ8ico2vrFGT8Y5nJiEYOXdoU9QKty2n7vKvZsNSbKkgp6iJgpoCSiosrNZ2aAnvHL0mnO0zsWXUk6dSLxoVzeXtgnEWXTxLCcZUzVISAw6KnOKL8OJMYt5smGmuVnQGXOPCjgGqbH)aG7auqOudpVdiGdGeMnhquWdGWI7yaAU(U3b8mNYUkA4Is3EBubXkhNzETrbBzYmAk7QOHlkD7Trfcs0qKSvS1xTv3kw8(sS(U3es2k26R2QBfNWCU3lIq3wuryXCU3lIG67EtizRyRVARUvCcZ5EVicD8jbvW8k0Ac7nqhLnNsz7u2vrdxu62BJkeKOH6gz6HQykpLlXa(b7YOyk7QOHlkHc2Lrbrvb7MwubmexrwjzB4yrCGiEs8(smCjVrYeZKTW1gfS9m7KK41RswtqwHJfXrQr2keHMYUkA4IsOGDzuiirdrs)jQiy8u2vrdxucfSlJcbjAONxFOc6)aJrnCPctAMKMzMIXtLmDI(p74Txri6NWl3eIdwpacJb4QOH7aKnkqPPm9lBuGOcq)mcXRIrubOcFIka9ZRxLSMke9RWDW42PFEzSiYPOZzBaT5UyhGbd40aiyaznG67EtvPRz7v(WyYPN5aiyahpGSgGggjfCv8gypyT9k9C2wF4nfTIKEfnacgqwdWvrd3KcUkEdShS2ELEoN61ELTOIyagnoG7tkTywv4yrSn6CEaeAaIu6uUl2bCe97QOHl9RGRI3a7bRTxPNZ0GkmPubOFE9QK1uHOFfUdg3o9FWXTxLCQkDnBVYhgt2IiVQbqWauqOudpVPkhNzETrbBzYmk9mhabd44bGmzP0gowehOuv6A2ELpmM8amG4aiDagnoaS3AlFG3i5Ank17amyaLm7d4i63vrdx6VkHqTfETrbB5LZjtdQWLMka97QOHl9l65yD7RfETEPymmkOFE9QK1uHObv4ssfG(51RswtfI(v4oyC70pYKLsB4yrCGsvPRz7v(WyYdWaIdG0by04aWERT8bEJKR1OuVdWGbKrzoacgqwdO(U3KRX86YEzl(Hkspt63vrdx6)cvpeRTEPyChSTYEonOcNDQa0pVEvYAQq0Vc3bJBN(rMSuAdhlIduQkDnBVYhgtEagqCaKoaJgha2BTLpWBKCTgL6DagmGmkt63vrdx638H7l5EfzRshf0GkCgrfG(51RswtfI(v4oyC70F9DVjmRirYiK9cXko9mhGrJdO(U3eMvKizeYEHyfBvW3gmoHcxrYai0aoLj97QOHl9hfS9Tv4B12leRyAqfMWGka97QOHl9JBttjB71ImDft)86vjRPcrdQWzlva63vrdx6)mel1h4ETygbxFvm9ZRxLSMkenOclgPcq)86vjRPcr)kChmUD6NxglI8ai0akz2PFxfnCP)CohIjBHxR8PATvJzphrdQWNYKka9ZRxLSMke97QOHl9Jz3Sxr2R0Zze9RWDW42P)WXI4ifDoBdOv38ai0aoLY(amACahpGJhq4yrCKkyxgfjtvmadgq2M5amACaHJfXrQGDzuKmvXaieXbqAMd4ObqWaoEaUk6dSLxoVz0aioGtdWOXbCWXTxLCcZUzVISAw6KhGbdGuX4aoAahnaJghWXdiCSiosrNZ2aAnvHL0mhGbdO0zoacgWXdWvrFGT8Y5nJgaXbCAagnoGdoU9QKty2n7vKvZsN8amyaLSKd4ObCe9RiRKSnCSioquHprdAq)A(6pzqfGk8jQa0VRIgU0pjTIe6NxVkznviAqfMuQa0VRIgU0pkyxgf0pVEvYAQq0GkCPPcq)86vjRPcr)qt6hXb97QOHl9FWXTxLm9FWLpM(ZK(p4y765m9JJQfZyOusdQWLKka9ZRxLSMke9dnPFeh0VRIgU0)bh3EvY0)bx(y6xbZRqRjS3aL08TvDmadioashGGdG0bKnd44beUK3ijQaIcjzlkWnjCIxVkz9aiyakiuQHN3KOcikKKTOa3KWjmN79IgaHgWPbC0aeCa139MQyORrTMtpZbqWa4LXIipadgqgL5aiyaznG67EtisEsP1xTvHHiufUmk9mhabdiRbuF3BIeMnTKHpS9ChiRxHVWsg(spt6)GJTRNZ0VNxFOcRcU6oA4sdQWzNka9ZRxLSMke9dnPFeh0VRIgU0)bh3EvY0)bx(y6hzYsPnCSioqPQ01S9kFym5bqObq6aiyayV1w(aVrY1AuQ3byWainZby04aQV7nvLUMTx5dJjNEM0)bhBxpNP)Q01S9kFymzlI8QObv4mIka9ZRxLSMke9RWDW42PFuWUmkyDYLs63vrdx6x5sP1vrdxRSrb9lBuyxpNPFuWUmkObvycdQa0pVEvYAQq0VRIgU0VYLsRRIgUwzJc6x2OWUEot)knIguHZwQa0pVEvYAQq0Vc3bJBN(vW8k0Ac7nqdWaIdqzAZDXArM8QhqgmGJhq9DVPkg6AuR50ZCacoG67EtqttioEBhKtpZbC0aYMbC8acxYBKetVwrIvJ9ZjE9QK1dGGbC8aYAaHl5ns5oMewBVqSvZEuK41RswpaJghGccLA45nL7ysyT9cXwn7rrcZ5EVObyWaonGJgWrdiBgWXdWlfJ7GtUITptlz4dBrsMpWjSVKmacnashGrJdiRbOGqPgEEtvooZ8AJc2YKzu6zoGJgGrJdqbZRqRjS3anaIdW3o3vfoweRTkt63vrdx6h)wRRIgUwzJc6x2OWUEot)3EBubnOclgPcq)86vjRPcr)UkA4s)kxkTUkA4ALnkOFzJc765m9xFTutdQWNYKka9ZRxLSMke9RWDW42PFEzSiYjnFBvhdWaId4u2hGGdGxglICcZI4L(Dv0WL(DSYx2gqmM3GguHpDIka97QOHl97yLVS18jrm9ZRxLSMkenOcFIuQa0VRIgU0VSfveiRy(NwuoVb9ZRxLSMkenOcFQ0ubOFxfnCP)QlYcV2a3ksq0pVEvYAQq0Gg0VjMvW8QhubOcFIka97QOHl97MMsYwtyJGl9ZRxLSMkenOctkva6NxVkznviAqfU0ubOFE9QK1uHObv4ssfG(51RswtfIguHZova6NxVkznviAqfoJOcq)UkA4s)MWOHl9ZRxLSMkenOctyqfG(51RswtfI(Dv0WL(ZDmjS2EHyRM9OG(v4oyC70p2BTLpWBKCTgL6DagmGsMj9BIzfmV6HfXk4Qr0F2Pbv4SLka9ZRxLSMke9RWDW42P)JhqwdGftV20K1jtOIeoqDPyTvbZnFHhnCTA(qR4by04aYAakiuQHN3KISscdmCBLTkDuK0pShnChGrJda7T2Yh4ns9E4jxg7vjNyX2OanGJOFxfnCPFuWUmkObvyXiva6NxVkznvi63vrdx6hdLsBuW2kCze9BIzfmV6HfXk4Qr0pP0Gk8PmPcq)86vjRPcr)UkA4s)izRyRVARUvm9BIzfmV6HfXk4Qr0pP0Gk8PtubOFE9QK1uHOFxfnCPFxJ51L9Yw8dvq)kChmUD6)4bK1ayX0RnnzDYeQiHduxkwBvWCZx4rdxRMp0kEagnoGSgGccLA45nPiRKWad3wzRshfj9d7rd3by04aWERT8bEJuVhEYLXEvYjwSnkqd4i63eZkyE1dlIvWvJO)t0Gk8jsPcq)86vjRPcr)RNZ0VxkuHJDK9c3WcVwt4zgt)UkA4s)EPqfo2r2lCdl8AnHNzmnOcFQ0ubOFE9QK1uHOFxfnCPFfzLegy42kBv6OG(v4oyC70Fwda7T2Yh4ns9E4jxg7vjNyX2Oar)89YQWUEot)kYkjmWWTv2Q0rbnOb9xFTutfGk8jQa0VRIgU0pRkG9kYIztCN7RM(51RswtfIguHjLka9ZRxLSMke97QOHl9Jym2dwBRWLTiZMeM(v4oyC70FwdqdJeIXypyTTcx2ImBs4u0ks6v0amACaUk6dSLxoVz0aioGtdGGbG9wB5d8gjxRrPEhGbd4(KslMvfoweBJoNhGrJdqv4yrmAagmashabd42IkclMZ9ErdGqdi70VISsY2WXI4arf(enOcxAQa0pVEvYAQq0Vc3bJBN(pEaHl5nsIPxRiXQX(5eVEvY6by04a8sX4o4ejmBAjdFy75oqwVcFHLm8LW(sYai0aiDahnacgq9DVjOPjehVTdYPN5aiyahpG67EtKWSPLm8HTN7az9k8fwYWxcfUIKbqObCQKdWOXbWlJfrEaeAaLm7d4i63vrdx63SrbuArfWGguHljva6NxVkznvi6xH7GXTt)139MGMMqC82oiNEMdGGbC8aQV7nPzxJkGr6zoaJghq9DVjryMxej9ISNBfjmgLEMdWOXbuF3Bsbxf7swBRY3QzC9HqPN5aoI(Dv0WL(nBuaLwubmObv4StfG(Dv0WL(r92OGXwuGBsy6NxVkznviAqd6hfSlJcQauHprfG(51RswtfI(Dv0WL(vfSBArfWG(v4oyC70F4sEJKjMjBHRnky7z2jjXRxLSEaemGSgq4yrCKAKTcri6xrwjzB4yrCGOcFIguHjLka97QOHl9JK(turWy6NxVkznviAqfU0ubOFxfnCPFpV(qf0pVEvYAQq0Gg0VsJOcqf(eva6NxVkznvi6xH7GXTt)znauWUmkyDYLs63vrdx6x5sP1vrdxRSrb9lBuyxpNPFgH4vXiAqfMuQa0pVEvYAQq0Vc3bJBN(ZAa139MCnMxx2lBXpur6zoacgWXdiRbWIPxBAY6KxkuHJDK9c3WcVwt4zgpaJghGccLA45nj9G3W6yLVEcZ5EVObyWainZbCe97QOHl97AmVUSx2IFOcAqfU0ubOFE9QK1uHOFfUdg3o9xF3BcdLsBuW2kCzucZ5EVObqiIdO0dWOXbCWXTxLCchvlMXqPK(Dv0WL(XqP0gfSTcxgrdQWLKka9ZRxLSMke97QOHl9N7ysyT9cXwn7rb9RWDW42PFS3AlFG3i5Ank9mhabd44bCBrfHfZ5EVObqObOG5vO1e2BGsA(2QogGrJdiRbGc2LrbRtyOOhpacgGcMxHwtyVbkP5BR6yagqCaktBUlwlYKx9aYGbCAahr)kYkjBdhlIdev4t0GkC2Pcq)86vjRPcr)kChmUD6h7T2Yh4nsUwJs9oadgqPZCazWaWERT8bEJKR1OK(H9OH7aiyaznauWUmkyDcdf94bqWauW8k0Ac7nqjnFBvhdWaIdqzAZDXArM8QhqgmGt0VRIgU0FUJjH12leB1Shf0GkCgrfG(51RswtfI(v4oyC70pYKLsB4yrCGgGbehaPdGGbK1aQV7nvLUMTx5dJjNEMdGGbC8aYAayV1w(aVrY1AuIfBJc0amACayV1w(aVrY1AucZ5EVObyWaY2by04aWERT8bEJKR1OuVdWGbC8aiDazWauqOudpVPQ01S9kFym5KQWXIyK9IDv0W1Ld4ObKndG0SpGJOFxfnCP)Q01S9kFymzAqfMWGka9ZRxLSMke9RWDW42PFKjlL2WXI4anaId40aiyayV1w(aVrY1AuQ3byWaoEaKoGmyakiuQHN3uv6A2ELpmMCsv4yrmYEXUkA46YbC0aYMbqA2PFxfnCP)Q01S9kFymzAqfoBPcq)86vjRPcr)kChmUD6xbZRqRjS3aL08TvDmadioGtdqWbuF3BQIHUg1Ao9mPFxfnCPFrfquijBrbUjHPbvyXiva6NxVkznvi6xH7GXTt)hCC7vjNQsxZ2R8HXKTiYRAaemaKjlL2WXI4aLQsxZ2R8HXKhGbd40aiya8YyrKtrNZ2aAZDXoadgaP0VRIgU0pjTu2RilYeZmnOcFktQa0pVEvYAQq0Vc3bJBN(p442RsovLUMTx5dJjBrKx1aiya8YyrKtrNZ2aAZDXoadgaP0VRIgU0Fv6A2IFOcAqf(0jQa0pVEvYAQq0Vc3bJBN(ZAaOGDzuW6KlLdGGbCWXTxLCYZRpuHvbxDhnCPFxfnCP)d(2OcAqf(ePubOFE9QK1uHOFfUdg3o9N1aqb7YOG1jxkhabdqbZRqRjS3anacrCaNOFxfnCPFnMDDv6AgrdQWNknva6NxVkznvi6xH7GXTt)znauWUmkyDYLYbqWao442Rso551hQWQGRUJgU0VRIgU0pQW1WZ5SutdQWNkjva6NxVkznvi6xH7GXTt)znauWUmkyDYLs63vrdx6hXMOgrdQWNYova6NxVkznvi6xH7GXTt)139MQsiulFOiHzxfdWOXbuF3BY1yEDzVSf)qfPNj97QOHl9BcJgU0Gk8PmIka97QOHl9xLqO2EFyY0pVEvYAQq0Gk8jcdQa0VRIgU0FLXigtsVIOFE9QK1uHObv4tzlva63vrdx6)2yUkHqn9ZRxLSMkenOcFsmsfG(Dv0WL(9vXOa7sRYLs6NxVkznviAqfM0mPcq)86vjRPcr)UkA4s)kYkjmWWTv2Q0rb9RWDW42P)SgakyxgfSo5s5aiya139MCnMxx2lBXpursdpVdGGbuF3BkNZHyYw41kFQwB1y2Zrjn88oacgaVmwe5u05SnG2CxSdWGbuYbqWaWr1wF3lAaeAazN(57LvHD9CM(vKvsyGHBRSvPJcAqfM0tubOFE9QK1uHOFxfnCPFVuOch7i7fUHfETMWZmM(v4oyC70FwdO(U3KRX86YEzl(HkspZbqWaYAa139MQsxZ2R8HXKtpZbqWauqOudpVjxJ51L9Yw8dvKWCU3lAaeAaNYo9VEot)EPqfo2r2lCdl8AnHNzmnOctkPubOFE9QK1uHOFxfnCPFhvCWxgzXEPGyRcIDj9RWDW42PFnxF3Bc7LcITki2LwnxF3BsdpVdWOXbO567Etk4QFQOpW2EjXQ567EtpZbqWachlIJub7YOizQIbqObuAshabdiCSiosfSlJIKPkgGbehqPZCagnoGSgGMRV7nPGR(PI(aB7LeRMRV7n9mhabd44bO567EtyVuqSvbXU0Q567EtOWvKmadioasZCazWaoL5aYMbO567EtvjeQTWRnkylVCo50ZCagnoGBlQiSyo37fnacnGmkZbC0aiya139MCnMxx2lBXpurcZ5EVObyWaoLT0)65m97OId(Yil2lfeBvqSlPbvyslnva6NxVkznvi6xH7GXTt)139MQsiulFOiHzxfdWOXbCBrfHfZ5EVObqiIdG0mhGrJdqbZRqRjS3aL08TvDmacrCaKs)UkA4s)peB7GZr0Gg0)T3gvqfGk8jQa0VRIgU0FLJZmV2OGTmzgr)86vjRPcrdQWKsfG(51RswtfI(v4oyC70F9DVjKSvS1xTv3koH5CVx0ai0aUTOIWI5CVx0aiya139MqYwXwF1wDR4eMZ9ErdGqd44bCAacoafmVcTMWEd0aoAazZaoLYw63vrdx6hjBfB9vB1TIPbv4stfG(Dv0WL(1nY0dvb9ZRxLSMkenObnOF)ffqm9)7CclnObLc]] )

end