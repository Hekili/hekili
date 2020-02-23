-- RogueOutlaw.lua
-- June 2018
-- Contributed by Alkena.

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'ROGUE' then
    local spec = Hekili:NewSpecialization( 260 )

    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Energy, {
        blade_rush = {
            aura = 'blade_rush',

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

        acrobatic_strikes = 19236, -- 196924
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
        slice_and_dice = 19250, -- 5171

        dancing_steel = 22125, -- 272026
        blade_rush = 23075, -- 271877
        killing_spree = 23175, -- 51690
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
            id = 199804,
            duration = 5,
            max_stack = 1
        },
        blade_flurry = {
            id = 13877,
            duration = 15,
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
            duration = 6,
            max_stack = 1,
        },
        detection = {
            id = 56814,
            duration = 30,
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
        restless_blades = {
            id = 79096,
        },
        riposte = {
            id = 199754,
            duration = 10,
            max_stack = 1,
        },
        -- Replaced this with 'alias' for any of the other applied buffs.
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
            id = 5171,
            duration = 18,
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

        -- Real RtB buffs.
        broadside = {
            id = 193356,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },
        buried_treasure = {
            id = 199600,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },
        grand_melee = {
            id = 193358,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },
        skull_and_crossbones = {
            id = 199603,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },        
        true_bearing = {
            id = 193359,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },
        ruthless_precision = {
            id = 193357,
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },


        -- Fake buffs for forecasting.
        rtb_buff_1 = {
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },

        rtb_buff_2 = {
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
        },

        roll_the_bones = {
            alias = rtb_buff_list,
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return 36 + ( talent.deeper_strategem.enabled and 6 or 0 ) end,
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
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld" }
    }

    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up
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
        if level > 115 then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + 5
        elseif buff.master_assassins_initiative.up then return buff.master_assassins_initiative.remains end
        return 0
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.mantle and ( not a or a.startsCombat ) then
            if level < 116 and equipped.mantle_of_the_master_assassin then
                applyBuff( "master_assassins_initiative", 5 )
            end

            if talent.subterfuge.enabled then
                applyBuff( "subterfuge" )
            end

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
            reduceCooldown( "sprint", cdr )
            reduceCooldown( "grappling_hook", cdr )
            reduceCooldown( "vanish", cdr )

            reduceCooldown( "blade_rush", cdr )
            reduceCooldown( "killing_spree", cdr )
        end
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

            toggle = 'cooldowns',

            nobuff = "stealth",

            handler = function ()
                applyBuff( 'adrenaline_rush', 20 )

                energy.regen = energy.regen * 1.6
                energy.max = energy.max + 50
                forecastResources( 'energy' )

                if talent.loaded_dice.enabled then
                    applyBuff( 'loaded_dice', 45 )
                    return
                end

                if azerite.brigands_blitz.enabled then
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
                gain( buff.broadside.up and 3 or 2, 'combo_points' )
            end,
        },


        between_the_eyes = {
            id = 199804,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = true,
            texture = 135610,

            usable = function() return combo_points.current > 0 end,

            handler = function ()
                if talent.prey_on_the_weak.enabled then
                    applyDebuff( 'target', 'prey_on_the_weak', 6 )
                end

                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                applyDebuff( 'target', 'between_the_eyes', combo_points.current ) 

                if azerite.deadshot.enabled then
                    applyBuff( "deadshot" )
                end

                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" ) 
            end,
        },


        blade_flurry = {
            id = 13877,
            cast = 0,
            charges = 2,
            cooldown = 25,
            recharge = 25,

            gcd = "spell",

            spend = 15,
            spendType = "energy",

            startsCombat = false,
            texture = 132350,

            usable = function () return buff.blade_flurry.remains < gcd.execute end,
            handler = function ()
                if talent.dancing_steel.enabled then 
                    applyBuff ( 'blade_flurry', 15 )
                    return
                end
                applyBuff( 'blade_flurry', 12 )
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
                applyBuff( 'blade_rush', 5 )
            end,
        },


        blind = {
            id = 2094,
            cast = 0,
            cooldown = function () return 120 - ( talent.blinding_powder.enabled and 30 or 0 ) end,
            gcd = "spell",

            startsCombat = true,
            texture = 136175,

            handler = function ()
              applyDebuff( 'target', 'blind', 60)
            end,
        },


        cheap_shot = {
            id = 1833,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 40 - ( talent.dirty_tricks.enabled and 40 or 0 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132092,

            handler = function ()
                applyDebuff( 'target', 'cheap_shot', 4)
                if talent.prey_on_the_weak.enabled then
                    applyDebuff( 'target', 'prey_on_the_weak', 6)
                    return
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
                applyBuff( 'cloak_of_shadows', 5 )
            end,
        },


        crimson_vial = {
            id = 185311,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = false,
            texture = 1373904,

            handler = function ()
                applyBuff( 'crimson_vial', 6 )
            end,
        },


        detection = {
            id = 56814,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132319,
            
            handler = function ()
                applyBuff( "detection" )
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
                applyBuff( 'feint', 5 )
            end,
        },


        ghostly_strike = {
            id = 196937,
            cast = 0,
            cooldown = 35,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            talent = 'ghostly_strike',

            startsCombat = true,
            texture = 132094,

            handler = function ()
                applyDebuff( 'target', 'ghostly_strike', 10 )
                gain( buff.broadside.up and 2 or 1, "combo_points" )
            end,
        },


        gouge = {
            id = 1776,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return talent.dirty_tricks.enabled and 0 or 0 end,
            spendType = "energy",

            startsCombat = true,
            texture = 132155,

            -- Disable Gouge because we can't tell if we're in front of the target to use it.
            usable = function () return false end,
            handler = function ()
                gain( buff.broadside.up and 2 or 1, "combo_points" )
                applyDebuff( 'target', 'gouge', 4 )
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

            toggle = 'interrupts', 
            interrupt = true,

            startsCombat = true,
            texture = 132219,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        killing_spree = {
            id = 51690,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            talent = 'killing_spree',

            startsCombat = true,
            texture = 236277,

            toggle = 'cooldowns',

            handler = function ()
                applyBuff( 'killing_spree', 2 )
            end,
        },


        marked_for_death = {
            id = 137619,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = 'marked_for_death', 

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
            end,

            handler = function ()
                gain( 5, 'combo_points')
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
                gain( buff.broadside.up and 2 or 1, 'combo_points' )

                if talent.quick_draw.enabled and buff.opportunity.up then
                    gain( 1, 'combo_points' )
                end

                removeBuff( "deadshot" )
                removeBuff( 'opportunity' )
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
                applyBuff( 'riposte', 10 )
            end,
        },


        roll_the_bones = {
            id = 193316,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            notalent = 'slice_and_dice',

            spend = 25,
            spendType = "energy",

            startsCombat = false,
            texture = 1373910,

            usable = function ()
                if combo_points.current == 0 then return false end

                -- Don't RtB if we've already done a simulated RtB.
                if buff.rtb_buff_1.up then return false end

                if buff.roll_the_bones.down then return true end

                -- Handle reroll checks for pre-combat.
                if time == 0 then
                    if combo_points.current < 5 then return false end

                    local reroll = rtb_buffs < 2 and ( buff.loaded_dice.up or not buff.grand_melee.up and not buff.ruthless_precision.up )

                    if azerite.deadshot.enabled or azerite.ace_up_your_sleeve.enabled then
                        reroll = rtb_buffs < 2 and ( buff.loaded_dice.up or buff.ruthless_precision.remains <= cooldown.between_the_eyes.remains )
                    end

                    if azerite.snake_eyes.enabled then
                        reroll = rtb_buffs < 2 or ( azerite.snake_eyes.rank == 3 and rtb_buffs < 5 )
                    end

                    if azerite.snake_eyes.rank >= 2 and buff.snake_eyes.stack >= ( buff.broadside.up and 1 or 2 ) then return false end

                    return reroll
                end

                return true
            end,

            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                for _, name in pairs( rtb_buff_list ) do
                    removeBuff( name )
                end

                if azerite.snake_eyes.enabled then
                    applyBuff( "snake_eyes", 12, 5 )
                end

                applyBuff( "rtb_buff_1", 12 + 6 * ( combo_points.current - 1 ) )
                if buff.loaded_dice.up then
                    applyBuff( "rtb_buff_2", 12 + 6 * ( combo_points.current - 1 ) )
                    removeBuff( "loaded_dice" )
                end

                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
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
                applyDebuff( 'target', 'sap', 60 )
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
                applyBuff( 'shroud_of_concealment', 15 )
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
                gain( buff.broadside.up and 2 or 1, 'combo_points')
            end,
        },


        slice_and_dice = {
            id = 5171,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = false,
            texture = 132306,

            talent = "slice_and_dice",

            usable = function()
                if combo_points.current == 0 or buff.slice_and_dice.remains > 6 + ( 6 * combo_points.current ) then return false end
                return true
            end,

            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyBuff( "slice_and_dice", 6 + 6 * ( combo - 1 ) )
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
                applyBuff( 'sprint', 8 )
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
                applyBuff( 'stealth' )
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

            usable = function () return boss and group end,

            handler = function ()
                applyBuff( 'vanish', 3 )
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


    spec:RegisterPack( "Outlaw", 20200212, [[daf8ibqirfpsvkBcL4tePsJsvQofkWQqbPxHszwOuDlrLAxI8lIsdtuvhJOyzQsEgLOmnkr11ufvBtuj(gkimovrPZrjvQ1rKkMNQi3dfTprvoOOsAHejpKivzIuI0fPerBefu(iLubNKivLvQk8suqvZKivv6MOGk7KsYprbrdLseokrQQyPQIINQQMkLWvPKQSvIuv1xPKkzSusf5Susf1Ej8xkgSkhMQfRWJjzYK6YiBwrFwumAP0PvA1usf61OqZgv3wk2nWVbnCk1XPKQA5qEoutx46s12fL(okPXtjLZteRNiL5tuTFjlKryH4R9Gew9k)x5N)lzELE965VKrgXpKytIVTRy0ZqIpWBiXNHShCNvX32LWHUwyH4JHDKIe)2iSXshzLnZgT9rsbBKfVnDUhleOq(mKfVnkzf)rF5H0hqmeFThKWQx5)k)8FjZR0Rxp)v(5I4JTjLWQx5s(IF7Q1eqmeFnHvI)B1Xq2dUZADpdmtNQhVvxBe2yPJSYMzJ2(iPGnYI3Mo3JfcuiFgYI3gLS1J3QJHrdu3rsQtMxSx3R8FLF9OE8wDsVwhKHWsN6XB1L76YvTM01XWVkgRlG1PPP35rDUkwiOo(IJu94T6YDD5Qwt66SrKc2m8OoP4UMQJHX7iKK6Exdjmq6g1nqKZyD)GCE0YGu94T6YDDwkeiDJ66yQUaTagPax3cQdhKZJ2u94T6YDDwkeiDJ66yQUMfiDSov3eIQJHZrms66MquDwk5rBDVVH0fxhag1H722quqAgKQhVvxURlxZcxDDicb58fKPUNjKQoDhTGm1jf31uDmmEhHKu37DaNW46yLQdc4sQR1Zs1jtDHJYqbds1J3Ql319me3TwDm8lNVGm19TreLQhVvxURZ6HP6ITHmb0OxQUjevhbuWoiiuDeqVGm1H8OLq1fToOUWrzOifBdzcOrVus8TrW5YjX)T6yi7b3zTUNbMPt1J3QRncBS0rwzZSrBFKuWgzXBtN7XcbkKpdzXBJs26XB1XWObQ7ij1jZl2R7v(VYVEupERoPxRdYqyPt94T6YDD5Qwt66y4xfJ1fW600078OoxfleuhFXrQE8wD5UUCvRjDD2isbBgEuNuCxt1XW4DessDVRHegiDJ6giYzSUFqopAzqQE8wD5UolfcKUrDDmvxGwaJuGRBb1HdY5rBQE8wD5UolfcKUrDDmvxZcKowNQBcr1XW5igjDDtiQolL8OTU33q6IRdaJ6WDBBikinds1J3Ql31LRzHRUoeHGC(cYu3ZesvNUJwqM6KI7AQoggVJqsQ79oGtyCDSs1bbCj116zP6KPUWrzOGbP6XB1L76EgI7wRog(LZxqM6(2iIs1J3Ql31z9WuDX2qMaA0lv3eIQJakyheeQocOxqM6qE0sO6Iwhux4OmuKITHmb0OxkvpQhVvNL0AKQhKUUbnHiQofSz4rDdkZcWP6YvLISdCDaii3ToQz2515QyHaCDqaxsQE8wDUkwiaNSrKc2m8G5K7ygRhVvNRIfcWjBePGndpyJPSEptdbcpwiOE8wDUkwiaNSrKc2m8GnMYoHqD94T6(a3g3cJ6q(QRB0Ntsxho8ax3GMqevNc2m8OUbLzb46CGUoBeLBByelitDlUoneqP6XB15QyHaCYgrkyZWd2yklg424wyyWHh46HRIfcWjBePGndpyJPSnoIrsBMqKrtE0YUnIuWMHhgmPGanM5ZzFNmr(QnuwcejxRXPfKNLNF9WvXcb4KnIuWMHhSXuwCqopAzFNmFphY63xBBsNSHkgPaVsJ0gfSXUhESqGrtzxfjxEokiKRHScskjkomqqWQmdUJJKUJ8yHa5Yr(QnuwcePfKTZbeYhCkrwBXbMb1dxfleGt2isbBgEWgtzrqo3eTKzabeMDBePGndpmysbbAmZx1dxfleGt2isbBgEWgtzX8vrghOn6vrSBJifSz4HbtkiqJz(QE4QyHaCYgrkyZWd2ykRRreW5lGmOoULDBePGndpmysbbAmtzyFNmFphY63xBBsNSHkgPaVsJ0gfSXUhESqGrtzxfjxEokiKRHScskjkomqqWQmdUJJKUJ8yHa5Yr(QnuwcePfKTZbeYhCkrwBXbMb1dxfleGt2isbBgEWgtz7yYSb1WoWBiMU0WToYXMjeeg40ydzLq1dxfleGt2isbBgEWgtz7yYSb1WonNKkmaVHyQKO4WabbRYm4ooyFNmZb5R2qzjqKwq2ohqiFWPezTfh46HRIfcWjBePGndpyJPS2WyHG6r94T6SKwJu9G01rzjKK6ITHQlAP6Cvar1T468S(Y9bNs1J3Q7ziCqopARBN1zdX4DWP6EhaRlBNdiKp4uDeGAwcx3cQtbBgEWG6HRIfcWmzCvmY(ozMdoiNhTKoHGz6u9WvXcbyM4GCE0wpERUNHqqoVUjev3l2QB0NtCDSUrBDs)cDnPRZsxfvx3ovhdz0siwxmvhIqqoVUjev3l2QdIQZ6aYb66y4ior1br19m9OLtyCDwcePw8cbP6HRIfcWSXu2SoA9bNyh4netummicb5C2Z68oXefdZOpN4NEXY7J(CM4qxtAJEvuQBlxEoJ(CMYGCG20qCIsDBwYz0NZeQhTCcJn2isT4fcsDBgupERUNHqqoVUjev3l2QB0NtCDquDptpA5egxNLarQfVqqDSUrBDwk5AClmQdIQlxvuDD76Ka7O6(CIYsP6HRIfcWSXu2SoA9bNyh4netummicb5C2H2mXuW(oz6sJqBqjn5AClmseWhCslxUlncTbLCfz62gjWoYG5eLLseWhCsZEwN3jMOyyg95e)0lwEF0NZeh6AsB0RIsDB5Yh95mH6rlNWyJnIulEHGeIA8fGFIPcc5AiRG0GcwjcyIwYqsiCcrn(cWmOE8wDVyRUpWzKQZskHWsN6YvoRUeCDicb586MquDVyRUrFoXP6HRIfcWSXu2SoA9bNyh4netummicb5C2H2mXuW(oz6sJqBqjmWzKmKecNqoGX8y(I9SoVtmrXWm6Zj(Px1J3Q7fB19boJuDwsjew6uNLcRdaJ6qecY51X6gT19IT6WHRyexhCwx0s19boJuDwsjeUUrFoR7DzyRoC4kgRJ1nARtke014vt11TzqQE4QyHamBmLnRJwFWj2bEdXefddIqqoNDOnteHPG9DY0LgH2GsyGZizijeoHCaJ5X8flJ(CMWaNrYqsiCchUIX8y(k3J(CMgiORXRMsD76XB1zDTrBDsXDnvhdJ3rij11TzVUndaIO6qDoHRZhWSuDoqxx4ms1rzjKKODbzQlA9OUfx3l2Q7DamQtb7GybzQ77spguhevhEbz4uDs9zVoRdmCSx3ZyjQhUkwiaZgtzZ6O1hCIDG3qmrXWGieKZzhAZetb77K5OpNPb31KzY7iKKu3M9SoVtmrXWm6Zjo3J(CMWm25CJd0gfcIXdiGWPU9tVy59rFotCORjTrVkk1TLlpNrFotzqoqBAiorPUnl5m6Zzc1JwoHXgBePw8cbPUnl5m6ZzAGGUgVAk1Tzq9WvXcby2ykBwhT(GtSd8gIP3m64wJcc0BSqa7zDENyQGndOXgUGaN00CvBKhZxS9IH(E4CcePmTqCWLyWbAzKseWhCsZIcc5AiRGuMwio4sm4aTmsje14la)KmmGTrFotde014vtPUnleGqzKKxUKpl5m6ZzcZyNZnoqBuiigpGacN62SKZOpNjgjY2ib2rgw3aB8bShgjWEQBxpCvSqaMnMYM1rRp4e7aVHyocYOGa9gleWEwN3jMJ(CMq9OLtySXgrQfVqqQBlx(7U0i0gustUg3cJeb8bN0YL7sJqBqjxrMUTrcSJmyorzPeb8bN0mGLrFotiiNBIwYmGacN621J3QZ6AJ26A68yT5uDHJYqbM96I2fxxwhT(Gt1T46uTKIrsxxaRttQvt1XAlfTeQomSHQt6zP46WTWoxx3GQdlbOiDDSUrBDsXDnvhdJ3rij1dxfleGzJPSzD06doXoWBiMdURjZK3rijgSeGI9SoVtmX2eNBchLHcCAWDnzM8ocj5PxSG8vBOSeisUwJtliVx5lx(OpNPb31KzY7iKKu3UE4QyHamBmLv5CUXvXcbg(Id2bEdXehKZJw23jtCqopAjDY586HRIfcWSXuwLZ5gxfley4loyh4netLgxpERog2cwCBDEuxJBTTP3uN0ZsKQ73h4a5QOoiGQBcr1rUQToPqqxJxnvNd01XqABdrrhSHK6yTLa1j9tFvmwNLICwRBX1HjoPcsxNd01XWnT06wCDayuhICTK68zqO6IwQoazTOomPGaDQUCLZQlbxxJBT6KkSK1X6gT19IT6YvfLQhUkwiaZgtzrDGXvXcbg(Id2bEdXCUGf3Y(ozQGndOXgUGaNhtLTPXTMbBtaDUFF0NZ0abDnE1uQBZ2OpNjOTnefDWgssDBgWqFpCobIK1VVkgnAKZAIa(GtAwEpNW5eisnoIrsBMqKrtE0MiGp4KwUCfeY1qwbPghXiPntiYOjpAtiQXxaopzyadyOV7sJqBqjxrMUTrcSJmyorzPeYbm(0l5YZrbHCnKvqAqbRebmrlzijeo1TLlpNrFotiiNBIwYmGacN62mOE4QyHamBmLv5CUXvXcbg(Id2bEdXC0xUUE4QyHamBmL1rkhqMaIqeiyFNmjaHYijPP5Q2ipMY8C2iaHYijHOmeOE4QyHamBmL1rkhqg7oht1dxfleGzJPS8ntBGnwh76mneiQhUkwiaZgtzhEgdCAc0QyexpQhVvNu9LRjeUE8wDwpmvNLyXbKx3Vfg1TZ62OowHaPBuNYTRtbBgW6SHliW15aDDrlvhdPTnm6GnKu3OpN1T4662P6Y1SWvxxhVGm1XAlbQJHNi76Sod7O6SU2axhoCfJ46Cevx7MPTUoGtyCDrlvNLsUg3cJ6g95SUfxNZXW662P6HRIfcWPrF5AM2loGCdUfgSVtMJ(CMG22qu0bBij1Tz59rFotmsKTrcSJmSUb24dypmsG9eoCfJpjJLlx(OpNjn5AClmsDB5YjaHYi5jl)5mOE4QyHaCA0xUMnMYIxWIdczWbAzKQh1J3Qt6bHCnKvaUE4QyHaCsPXmvoNBCvSqGHV4GDG3qmjmMakcZ(ozMdoiNhTKo5CE9WvXcb4KsJzJPSUgraNVaYG64w23jZCg95m5AebC(cidQJBtDBwiaHYijfBdzcOPXTwEYWY75qw)(ABt6KlnCRJCSzcbHbon2qwjKC5kiKRHScsCpiqyCKYbEcrn(cW59kFgupERoPVzDUwJRZruDDB2RddwBQUOLQdcO6yDJ264qwjCuNfwyPP6SEyQowBjqDAjlitDthheQUO1b1j9Se1PP5Q2OoiQow3Of2J6CGK6KEwIu9WvXcb4KsJzJPSnoIrsBMqKrtE0YUsIItMWrzOaZug23jtKVAdLLarY1ACQBZY7HJYqrk2gYeqJEPNuWMb0ydxqGtAAUQnKlphCqopAjDcbZ0jwuWMb0ydxqGtAAUQnYJPY204wZGTjGo3YWG6XB1j9nRdaRZ1ACDSUCED6LQJ1nAxqDrlvhGSwuNLLpM966yQogUPLwheu3aIX1X6gTWEuNdKuN0ZsKQhUkwiaNuAmBmLTXrmsAZeImAYJw23jtKVAdLLarY1ACAb5zz5NBKVAdLLarY1ACs3rESqal5GdY5rlPtiyMoXIc2mGgB4ccCstZvTrEmv2Mg3AgSnb05wM6XB1jf31uDmmEhHKuheu3l2QJauZs4uDwxB0wNR1yPtDwpmv3oRlAjj1HdxsDtiQUNLT6WKcc046GO62zDsGDuDaYArDQwhLHQJ1LZRBq1HixlPUfuxSnuDtiQUOLQdqwlQJvplLQhUkwiaNuAmBmLDWDnzM8ocjH9DYeBtCUjCugkW5X8fl5m6ZzAWDnzM8ocjj1Tz59Cq(QnuwcejxRXjYAloWYLJ8vBOSeisUwJtiQXxaoVNvUCKVAdLLarY1ACAb59(RCRGqUgYkin4UMmtEhHKKuTokdHntKRIfcCodyOVEodQhUkwiaNuAmBmLntlehCjgCGwgj23jZSoA9bNsdURjZK3rijgSeGIffSzan2Wfe4KMMRAJ8ykdBJ(CMgiORXRMsD76HRIfcWjLgZgtzzC58fKXGTreX(ozM1rRp4uAWDnzM8ocjXGLauS8obiugjPyBitannU1Y75YLtacLrYtY8CgupCvSqaoP0y2yk7G7AYG64w23jZSoA9bNsdURjZK3rijgSeGIfcqOmssX2qMaAACRLNm1J3QZ6HxqM6K(7Gf3kBU2m6426wCDqaxsDEDzjKK6IfiPUfOqKJj2RddRBb1HiNVHe2RtcSlDruD(ad59G4sQBUaQUawxht1TrDoUoVUES8nKuh2M48u9WvXcb4KsJzJPSzDWIBzFNmZbhKZJwsNCoNLSoA9bNsEZOJBnkiqVXcb1dxfleGtknMnMYIBDnK1gIRzFNmZbhKZJwsNCoNLSoA9bNsEZOJBnkiqVXcb1dxfleGtknMnMYAdJfcyFNmh95mn4qOM3XrcrUkKlF0NZKRreW5lGmOoUn1TRhVvhdZ58fKPUHRySUawNMMENh1Tb1uxh7zO6HRIfcWjLgZgtz7yYSb1WoWBiMzD06dozwqqa8gsmz2mEwipmqSA5CpwqgdICvarSVtMJ(CMgCiuZ74iHixfYLhBdzcOrV0tmFLVC5kyZaASHliWjnnx1gpX8v9WvXcb4KsJzJPSDmz2GAWSVtMJ(CMgCiuZ74iHixfYLhBdzcOrV0tmFLVC5kyZaASHliWjnnx1gpX8v9WvXcb4KsJzJPSdoeQnZoss9WvXcb4KsJzJPSdcHjeJlit9WvXcb4KsJzJPSZfrdoeQRhUkwiaNuAmBmL1bkchiNBuoNxpCvSqaoP0y2ykBhtMnOg2P5KuHb4netLefhgiiyvMb3Xb77Kzo4GCE0s6KZ5Sm6ZzY1ic48fqguh3M0qwbSm6ZzQHAGijg40W7QvB0iYBWjnKvaleGqzKKITHmb004wlplNfummJ(CIF651dxfleGtknMnMY2XKzdQHDG3qmDPHBDKJntiimWPXgYkHyFNmZz0NZKRreW5lGmOoUn1TzjNrFotdURjZK3rijPUnlkiKRHScsUgraNVaYG642eIA8fGFsMNxpERoP)essDiyptlxsDOoNQdoRlA7nJDUKUUgpAX1nioKvPtDwpmv3eIQt6dWOnuxNcTb71bJwcX6IP6yDJ26Y1NPopQ7v(SvhoCfJ46GO6KjF2QJ1nARZ5yyDsXHqDDD7u9WvXcb4KsJzJPSDmz2GAyh4neth3M1be2GCPbrgfe5C23jtnn6Zzc5sdImkiY5gnn6ZzsdzfixUMg95mPGaDxfBwYSagnAA0NZu3MLWrzOi1sopAt2Q4jl7flHJYqrQLCE0MSvrEmTS8Llphnn6Zzsbb6Uk2SKzbmA00OpNPUnlVRPrFotixAqKrbro3OPrFot4WvmMhZx5NBzYNHQPrFotdoeQnWPjAjdbOgjPUTC5HJYqrk2gYeqJEPNYL8zalJ(CMCnIaoFbKb1XTje14laNNmpB94T6SuA6DEu3058HRySUjevxh7dov3gudovpCvSqaoP0y2ykBhtMnOgm77K5OpNPbhc18oosiYvHC5X2qMaA0l9eZx5lxUc2mGgB4ccCstZvTXtmFvpQhVvNLeJjGIW1dxfleGtegtafHzQGafbcKhK2m5EdX(ozsacLrsk2gYeqtJBT8KHLCg95mn4UMmtEhHKK62S8EoAyKuqGIabYdsBMCVHmJocKIvX4cYWsoUkwiiPGafbcKhK2m5EdLwGzY3mTHC5ZoNBqKQ1rzitSn0tzu6uJBngupCvSqaorymbueMnMYo4qO2aNMOLmeGAKW(ozM1rRp4uAWDnzM8ocjXGLauSOGqUgYkinOGvIaMOLmKecN62SK1rRp4uAeKrbb6nwiOE4QyHaCIWycOimBmLnt3r61bg404sJqWOTE4QyHaCIWycOimBmLDcvDmPnU0i0gKzqEd77Kj2M4Ct4OmuGtdURjZK3rij5X8LC5iF1gklbIKR140cYlxYNLCg95m5AebC(cidQJBtD76HRIfcWjcJjGIWSXuw7oANswqgZG74G9DYeBtCUjCugkWPb31KzY7iKK8y(sUCKVAdLLarY1ACAb5Ll5xpCvSqaorymbueMnMYgTKPdgWoqBMqKIyFNmh95mHifJCcJntisrPUTC5J(CMqKIroHXMjePiJc2bbHs4Wvm(Km5xpCvSqaorymbueMnMYIwBBozwGbB7kQE4QyHaCIWycOimBmLLviIRZslWGime4afvpCvSqaorymbueMnMY2qnqKedCA4D1QnAe5ny23jtcqOmsEYYFE9WvXcb4eHXeqry2yklIC7fKXm5EdHzFNmdhLHIul58OnzRI8E28LlpCugksTKZJ2KTkEI5R8LlpCugksX2qMaASvH5v(5zz5xpQhVvhdBblULq46XB1jvyjRdMLq19mHu1HieKZX1X6gT1zPKRXTWq2Cvr1fiFdCDquDptpA5egxNLarQfVqqQE4QyHaCAUGf3YCqbRebmrlzijeM9DYmRJwFWP0iiJcc0BSqq9WvXcb40CblULnMYI5RImoqB0RIyFNmh95mH5RImoqB0RIsiQXxa(PyBitan6Lyz0NZeMVkY4aTrVkkHOgFb4NExg2uWMb0ydxqGzadvM0ZwpCvSqaonxWIBzJPSiiNBIwYmGacZ(ozo6Zzcb5Ct0sMbeq4eIA8fGFIPLjxEwhT(Gtjummicb586XB1jvyjRJ1nARlAP6YvfvN1ZUoRZWoQUpNOSuDquDwk5AClmQlq(g4u9WvXcb40CblULnMYoOGvIaMOLmKecZ(oz6sJqBqjxrMUTrcSJmyorzPeb8bN0YL7sJqBqjn5AClmseWhCsxpCvSqaonxWIBzJPS6fB7HQTEupERUFqopARhUkwiaNWb58OLP3m64wXplHWleiS6v(VYp)x5B5IpRocSGmyXx6RXgIcsxhdrDUkwiOo(IdCQEi(8fhyHfIpHXeqryHfcRKryH4taFWjTqkXxH2GqRl(eGqzKKITHmb004wRU8QtM6yPUCQB0NZ0G7AYm5DessQBxhl19ED5uNggjfeOiqG8G0Mj3BiZOJaPyvmUGm1XsD5uNRIfcskiqrGa5bPntU3qPfyM8ntBuNC51n7CUbrQwhLHmX2q19uDzu6uJBT6yG47QyHaXxbbkceipiTzY9gsecREjSq8jGp4KwiL4RqBqO1f)SoA9bNsdURjZK3rijgSeGQowQtbHCnKvqAqbRebmrlzijeo1TRJL6Y6O1hCkncYOGa9glei(Ukwiq8hCiuBGtt0sgcqnseHWkltyH47QyHaXpt3r61bg404sJqWOv8jGp4KwiLiewz5cleFc4doPfsj(k0geADXhBtCUjCugkWPb31KzY7iKK6YJzDVQtU86q(QnuwcejxRXPfuxE1Ll5xhl1LtDJ(CMCnIaoFbKb1XTPUT47QyHaXFcvDmPnU0i0gKzqEJiew9CHfIpb8bN0cPeFfAdcTU4JTjo3eokdf40G7AYm5DessD5XSUx1jxEDiF1gklbIKR140cQlV6YL8fFxflei(2D0oLSGmMb3XHiewLlcleFc4doPfsj(k0geADXF0NZeIumYjm2mHifL621jxEDJ(CMqKIroHXMjePiJc2bbHs4Wvmw3t1jt(IVRIfce)OLmDWa2bAZeIuKiewXqiSq8DvSqG4JwBBozwGbB7ks8jGp4KwiLiew9ScleFxflei(ScrCDwAbgeHHahOiXNa(GtAHuIqyL1TWcXNa(GtAHuIVcTbHwx8jaHYiPUNQZYFU47QyHaXVHAGijg40W7QvB0iYBWIqyLm5lSq8jGp4KwiL4RqBqO1f)WrzOi1sopAt2QOU8Q7zZVo5YRlCugksTKZJ2KTkQ7jM19k)6KlVUWrzOifBdzcOXwfMx5xxE1zz5l(Ukwiq8rKBVGmMj3BiSieH4RPP35HWcHvYiSq8jGp4KwiL4RqBqO1f)CQdhKZJwsNqWmDs8DvSqG4Z4QyuecREjSq8DvSqG4JdY5rR4taFWjTqkriSYYewi(eWhCslKs8H2IpMcX3vXcbIFwhT(GtIFwN3jXhfdZOpN46EQUx1XsDVx3OpNjo01K2OxfL621jxED5u3OpNPmihOnneNOu3UowQlN6g95mH6rlNWyJnIulEHGu3Uogi(zDKb4nK4JIHbriiNlcHvwUWcXNa(GtAHuIp0w8Xui(Ukwiq8Z6O1hCs8Z68oj(Oyyg95ex3t19QowQ796g95mXHUM0g9QOu3Uo5YRB0NZeQhTCcJn2isT4fcsiQXxaUUNywNcc5AiRG0GcwjcyIwYqsiCcrn(cW1XaXxH2GqRl(U0i0gustUg3cJeb8bN01jxEDU0i0guYvKPBBKa7idMtuwkraFWjT4N1rgG3qIpkggeHGCUiew9CHfIpb8bN0cPeFOT4JPq8DvSqG4N1rRp4K4N15Ds8rXWm6ZjUUNQ7L4RqBqO1fFxAeAdkHboJKHKq4eYbmwxEmR7L4N1rgG3qIpkggeHGCUiewLlcleFc4doPfsj(qBXhrykeFxflei(zD06doj(zDKb4nK4JIHbriiNl(k0geADX3LgH2GsyGZizijeoHCaJ1LhZ6Evhl1n6ZzcdCgjdjHWjC4kgRlpM19QUCx3OpNPbc6A8QPu3wecRyiewi(eWhCslKs8H2IpMcX3vXcbIFwhT(GtIFwN3jXhfdZOpN46YDDJ(CMWm25CJd0gfcIXdiGWPUDDpv3R6yPU3RB0NZeh6AsB0RIsD76KlVUCQB0NZugKd0MgItuQBxhl1LtDJ(CMq9OLtySXgrQfVqqQBxhl1LtDJ(CMgiORXRMsD76yG4RqBqO1f)rFotdURjZK3rijPUT4N1rgG3qIpkggeHGCUiew9ScleFc4doPfsj(qBXhtH47QyHaXpRJwFWjXpRZ7K4RGndOXgUGaN00CvBuxEmR7vDSv3R6yO19EDHZjqKY0cXbxIbhOLrkraFWjDDSuNcc5AiRGuMwio4sm4aTmsje14lax3t1jtDmOo2QB0NZ0abDnE1uQBxhl1racLrsD5vxUKFDSuxo1n6ZzcZyNZnoqBuiigpGacN621XsD5u3OpNjgjY2ib2rgw3aB8bShgjWEQBl(zDKb4nK47nJoU1OGa9gleicHvw3cleFc4doPfsj(qBXhtH47QyHaXpRJwFWjXpRZ7K4p6Zzc1JwoHXgBePw8cbPUDDYLx3715sJqBqjn5AClmseWhCsxNC515sJqBqjxrMUTrcSJmyorzPeb8bN01XG6yPUrFotiiNBIwYmGacN62IFwhzaEdj(JGmkiqVXcbIqyLm5lSq8jGp4KwiL4dTfFmfIVRIfce)SoA9bNe)SoVtIp2M4Ct4OmuGtdURjZK3rij19uDVQJL6q(QnuwcejxRXPfuxE19k)6KlVUrFotdURjZK3rijPUT4N1rgG3qI)G7AYm5DesIblbOeHWkzKryH4taFWjTqkXxH2GqRl(4GCE0s6KZ5IVRIfceFLZ5gxfley4loeF(IddWBiXhhKZJwriSsMxcleFc4doPfsj(Ukwiq8voNBCvSqGHV4q85lomaVHeFLglcHvYyzcleFc4doPfsj(k0geADXxbBgqJnCbbUU8ywNY204wZGTjGUUCx371n6ZzAGGUgVAk1TRJT6g95mbTTHOOd2qsQBxhdQJHw371foNarY63xfJgnYznraFWjDDSu371LtDHZjqKACeJK2mHiJM8OnraFWjDDYLxNcc5AiRGuJJyK0Mjez0KhTje14laxxE1jtDmOoguhdTU3RZLgH2GsUImDBJeyhzWCIYsjKdySUNQ7vDYLxxo1PGqUgYkinOGvIaMOLmKecN621jxED5u3OpNjeKZnrlzgqaHtD76yG47QyHaXh1bgxfley4loeF(IddWBiXFUGf3kcHvYy5cleFc4doPfsj(Ukwiq8voNBCvSqGHV4q85lomaVHe)rF5AriSsMNlSq8jGp4KwiL4RqBqO1fFcqOmssAAUQnQlpM1jZZRJT6iaHYijHOmeq8DvSqG47iLditariceIqyLm5IWcX3vXcbIVJuoGm2DoMeFc4doPfsjcHvYWqiSq8DvSqG4Z3mTb2yDSRZ0qGq8jGp4KwiLiewjZZkSq8DvSqG4p8mg40eOvXiw8jGp4KwiLieH4BJifSz4HWcHvYiSq8jGp4KwiL47QyHaXVXrmsAZeImAYJwXxH2GqRl(iF1gklbIKR140cQlV6S88fFBePGndpmysbbAS4)CriS6LWcXNa(GtAHuIVcTbHwx8FVUCQJS(912M0jBOIrkWR0iTrbBS7Hhley0u2vr1jxED5uNcc5AiRGKsIIddeeSkZG74iP7ipwiOo5YRd5R2qzjqKwq2ohqiFWPezTfh46yG47QyHaXhhKZJwriSYYewi(eWhCslKs8DvSqG4JGCUjAjZaciS4BJifSz4HbtkiqJf)xIqyLLlSq8jGp4KwiL47QyHaXhZxfzCG2Oxfj(2isbBgEyWKcc0yX)Liew9CHfIpb8bN0cPeFxflei(UgraNVaYG64wXxH2GqRl(Vxxo1rw)(ABt6KnuXif4vAK2OGn29WJfcmAk7QO6KlVUCQtbHCnKvqsjrXHbccwLzWDCK0DKhleuNC51H8vBOSeisliBNdiKp4uIS2IdCDmq8TrKc2m8WGjfeOXIVmIqyvUiSq8jGp4KwiL4d8gs8DPHBDKJntiimWPXgYkHeFxflei(U0WToYXMjeeg40ydzLqIqyfdHWcXNa(GtAHuIVRIfceFLefhgiiyvMb3XH4RqBqO1f)CQd5R2qzjqKwq2ohqiFWPezTfhyXNMtsfgG3qIVsIIddeeSkZG74qecREwHfIVRIfceFBySqG4taFWjTqkricXF0xUwyHWkzewi(eWhCslKs8vOni06I)OpNjOTnefDWgssD76yPU3RB0NZeJezBKa7idRBGn(a2dJeypHdxXyDpvNmwEDYLx3OpNjn5AClmsD76KlVocqOmsQ7P6S8NxhdeFxflei(2loGCdUfgIqy1lHfIVRIfceF8cwCqidoqlJK4taFWjTqkricXhhKZJwHfcRKryH47QyHaX3BgDCR4taFWjTqkricXxPXclewjJWcXNa(GtAHuIVcTbHwx8ZPoCqopAjDY5CX3vXcbIVY5CJRIfcm8fhIpFXHb4nK4tymbuewecREjSq8jGp4KwiL4RqBqO1f)CQB0NZKRreW5lGmOoUn1TRJL6iaHYijfBdzcOPXTwD5vNm1XsDVxxo1rw)(ABt6KlnCRJCSzcbHbon2qwjuDYLxNcc5AiRGe3dceghPCGNquJVaCD5v3R8RJbIVRIfceFxJiGZxazqDCRiewzzcleFc4doPfsj(Ukwiq8BCeJK2mHiJM8Ov8vOni06IpYxTHYsGi5Ano1TRJL6EVUWrzOifBdzcOrVuDpvNc2mGgB4ccCstZvTrDYLxxo1HdY5rlPtiyMovhl1PGndOXgUGaN00CvBuxEmRtzBACRzW2eqxxURtM6yG4RKO4KjCugkWcRKrecRSCHfIpb8bN0cPeFfAdcTU4J8vBOSeisUwJtlOU8QZYYVUCxhYxTHYsGi5AnoP7ipwiOowQlN6Wb58OL0jemtNQJL6uWMb0ydxqGtAAUQnQlpM1PSnnU1myBcORl31jJ47QyHaXVXrmsAZeImAYJwriS65cleFc4doPfsj(k0geADXhBtCUjCugkW1LhZ6Evhl1LtDJ(CMgCxtMjVJqssD76yPU3RlN6q(QnuwcejxRXjYAloW1jxEDiF1gklbIKR14eIA8fGRlV6E26KlVoKVAdLLarY1ACAb1LxDVx3R6YDDkiKRHScsdURjZK3rijjvRJYqyZe5QyHaNxhdQJHw3RNxhdeFxflei(dURjZK3rijIqyvUiSq8jGp4KwiL4RqBqO1f)SoA9bNsdURjZK3rijgSeGQowQtbBgqJnCbboPP5Q2OU8ywNm1XwDJ(CMgiORXRMsDBX3vXcbIFMwio4sm4aTmsIqyfdHWcXNa(GtAHuIVcTbHwx8Z6O1hCkn4UMmtEhHKyWsaQ6yPU3RJaekJKuSnKjGMg3A1LxDpVo5YRJaekJK6EQozEEDmq8DvSqG4Z4Y5liJbBJisecREwHfIpb8bN0cPeFfAdcTU4N1rRp4uAWDnzM8ocjXGLau1XsDeGqzKKITHmb004wRU8QtgX3vXcbI)G7AYG64wriSY6wyH4taFWjTqkXxH2GqRl(5uhoiNhTKo5CEDSuxwhT(GtjVz0XTgfeO3yHaX3vXcbIFwhS4wriSsM8fwi(eWhCslKs8vOni06IFo1HdY5rlPtoNxhl1L1rRp4uYBgDCRrbb6nwiq8DvSqG4JBDnK1gIRfHWkzKryH4taFWjTqkXxH2GqRl(J(CMgCiuZ74iHixf1jxEDJ(CMCnIaoFbKb1XTPUT47QyHaX3ggleicHvY8syH4taFWjTqkX3vXcbIFwhT(GtMfeeaVHetMnJNfYddeRwo3JfKXGixfqK4RqBqO1f)rFotdoeQ5DCKqKRI6KlVUyBitan6LQ7jM19k)6KlVofSzan2Wfe4KMMRAJ6EIzDVeFG3qIFwhT(GtMfeeaVHetMnJNfYddeRwo3JfKXGixfqKiewjJLjSq8jGp4KwiL4RqBqO1f)rFotdoeQ5DCKqKRI6KlVUyBitan6LQ7jM19k)6KlVofSzan2Wfe4KMMRAJ6EIzDVeFxflei(Dmz2GAWIqyLmwUWcX3vXcbI)GdHAZSJKi(eWhCslKsecRK55cleFxflei(dcHjeJliJ4taFWjTqkriSsMCryH47QyHaXFUiAWHqT4taFWjTqkriSsggcHfIVRIfceFhOiCGCUr5CU4taFWjTqkriSsMNvyH4taFWjTqkX3vXcbIVsIIddeeSkZG74q8vOni06IFo1HdY5rlPtoNxhl1n6ZzY1ic48fqguh3M0qwb1XsDJ(CMAOgisIbon8UA1gnI8gCsdzfuhl1racLrsk2gYeqtJBT6YRolVowQdfdZOpN46EQUNl(0CsQWa8gs8vsuCyGGGvzgChhIqyLmw3cleFc4doPfsj(Ukwiq8DPHBDKJntiimWPXgYkHeFfAdcTU4NtDJ(CMCnIaoFbKb1XTPUDDSuxo1n6ZzAWDnzM8ocjj1TRJL6uqixdzfKCnIaoFbKb1XTje14lax3t1jZZfFG3qIVlnCRJCSzcbHbon2qwjKiew9kFHfIpb8bN0cPeFxflei(oUnRdiSb5sdImkiY5IVcTbHwx810OpNjKlniYOGiNB00OpNjnKvqDYLxNMg95mPGaDxfBwYSagnAA0NZu3UowQlCugksTKZJ2KTkQ7P6SSx1XsDHJYqrQLCE0MSvrD5XSoll)6KlVUCQttJ(CMuqGURInlzwaJgnn6ZzQBxhl19EDAA0NZeYLgezuqKZnAA0NZeoCfJ1LhZ6ELFD5UozYVogADAA0NZ0GdHAdCAIwYqaQrsQBxNC51fokdfPyBitan6LQ7P6YL8RJb1XsDJ(CMCnIaoFbKb1XTje14laxxE1jZZk(aVHeFh3M1be2GCPbrgfe5CriS6LmcleFc4doPfsj(k0geADXF0NZ0GdHAEhhje5QOo5YRl2gYeqJEP6EIzDVYVo5YRtbBgqJnCbboPP5Q2OUNyw3lX3vXcbIFhtMnOgSieH4pxWIBfwiSsgHfIpb8bN0cPeFfAdcTU4N1rRp4uAeKrbb6nwiq8DvSqG4pOGvIaMOLmKeclcHvVewi(eWhCslKs8vOni06I)OpNjmFvKXbAJEvucrn(cW19uDX2qMaA0lvhl1n6ZzcZxfzCG2OxfLquJVaCDpv371jtDSvNc2mGgB4ccCDmOogADYKEwX3vXcbIpMVkY4aTrVksecRSmHfIpb8bN0cPeFfAdcTU4p6Zzcb5Ct0sMbeq4eIA8fGR7jM1zz1jxEDzD06doLqXWGieKZfFxflei(iiNBIwYmGaclcHvwUWcXNa(GtAHuIVcTbHwx8DPrOnOKRit32ib2rgmNOSuIa(Gt66KlVoxAeAdkPjxJBHrIa(GtAX3vXcbI)GcwjcyIwYqsiSiew9CHfIVRIfceF9IT9q1k(eWhCslKseIqeIV3Jwis8)BJ0teIqiaa]] )


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

    spec:RegisterSetting( "mfd_waste", false, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If checked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
        width = 1.5
    } )  
end