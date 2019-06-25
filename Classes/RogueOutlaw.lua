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

            usable = function () return time == 0 and not buff.stealth.up and not buff.vanish.up end,            
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


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]
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


    -- 587c02a72bd50631ec7949f7b257a3fab1d7100f
    spec:RegisterPack( "Outlaw", 20190625.0930, [[daLf2aqijIEKukBIk0NaimkaQtbiwfrbEfGAwub3IOu7ss)cLyyefDmIOLHs5zasMgrHUMeHTrfP(grbnoaIohvKSojsmpusDpu0(Ks1bPIWcrbpeLeMikjDrQiQncivFeqkLtsuISsIQxkrsntaPe3KkIStuQ(PejzOeLWrbKs1sjkPNQIPIcDvaPyRasj9vIsuJfLevNfLeXEH6Vu1Gv6WuwSu9ysnzsUmYMb6ZsjJwcNwXQrjr51eHzt42sXUv1VHmCQ0XrjrA5O65GMUW1vPTlr9DQOgVePoprA9aKMpa2VOXsIzeFuwqy2ztMs6uY0PzRevz6uafqjJYq8jK6s4JRPLWAr4ZBne(uQUHWCgFCnPcKPWmIpq0LRj8PicxyPWclTMO42RAudlWP5kSyqVMBGblWPrZc(0VJiKLEChFuwqy2ztMs6uY0PzRevz6uafqbuas8b6sAm7S50YeFkgLIEChFueuJpTLBP6gcZ5CLvuRlLYBl3IiCHLclS0AIIBVQrnSaNMRWIb9AUbgSaNgnlP82Yv(9PCzReoKlBYusNkxzNRmDQsbOKzkpL3wUSIc7BrWsjL3wUYoxNqPivUL6rlrUbkxfbAxrKRPJb95kgyut5TLRSZ1jHktQCpbzIOixdmiEUoHItVjMNYvwVWICNpxxoPrnDlY10XG(CfdmQP82Yv256ekfPY1LtAut3ICzqykkxGU4Y5sZfWkebFarKBNtMe5EcYerbqQP82Yv25YQOhqe5EHuUbFEjOaM785cdYerrnL3wUYoxwf9aIi3lKYTz(sHvEUGiEUojJlbPYfeXZLvjlkYfWtaiG5(Oix411fXdsbKAkVTCLDUorz0OYLtCKqmFRCL1GHCvx(8TYLbHPOCb6IlNlnxaFFbbH56mLl6fsZTWkt5kzUHXBrbqQP82Yv25kRKWkDUL6riMVvUhxorv8XLJahbHpTLBP6gcZ5CLvuRlLYBl3IiCHLclS0AIIBVQrnSaNMRWIb9AUbgSaNgnlP82Yv(9PCzReoKlBYusNkxzNRmDQsbOKzkpL3wUSIc7BrWsjL3wUYoxNqPivUL6rlrUbkxfbAxrKRPJb95kgyut5TLRSZ1jHktQCpbzIOixdmiEUoHItVjMNYvwVWICNpxxoPrnDlY10XG(CfdmQP82Yv256ekfPY1LtAut3ICzqykkxGU4Y5sZfWkebFarKBNtMe5EcYerbqQP82Yv25YQOhqe5EHuUbFEjOaM785cdYerrnL3wUYoxwf9aIi3lKYTz(sHvEUGiEUojJlbPYfeXZLvjlkYfWtaiG5(Oix411fXdsbKAkVTCLDUorz0OYLtCKqmFRCL1GHCvx(8TYLbHPOCb6IlNlnxaFFbbH56mLl6fsZTWkt5kzUHXBrbqQP82Yv25kRKWkDUL6riMVvUhxor1uEkVTCDYLM03Gu52jqeNYvJA6wKBNAnpSMRtO1KBaZ9rVSlmEd4vKRPJb9WCrVqAnLB6yqpS6YjnQPBbtqHbLiLB6yqpS6YjnQPBbWmzXUTAOpSyqFk30XGEy1LtAut3cGzYcicPs5TL75nxybkYLBJk3(feKu5cdlG52jqeNYvJA6wKBNAnpmx7v56Yjz7IIy(w5oWCvONQPCthd6HvxoPrnDlaMjlW3CHfOWddlGPCthd6HvxoPrnDlaMjlUOyqFk30XGEy1LtAut3cGzYsJXLGuEqe3RilkCWLtAut3cpK0OxbzwchgqMCBuEQm9r1ukyD(2LrzMYnDmOhwD5Kg10TayMSyko9MyEYZVWchC5Kg10TWdjn6vqMsMYnDmOhwD5Kg10TayMSadYerrk30XGEy1LtAut3cGzYchje(OG8D0tqhC5Kg10TWdjn6vqMSLYnDmOhwD5Kg10TayMSafJM82R8Qrto4YjnQPBHhsA0RGmzlLB6yqpS6YjnQPBbWmzPlmf5bfxoxQddiZ(feSYrcHpkiFh9eSEDD00XuM80tndbBxYuEkVTCDYLM03Gu5sLjU0CJPHYnkOCnDG45oWCTY2iSUGQP82YvwjyqMikYDaZ1fbHtxq5c4hLB5R4jU1fuU0tndbZD(C1OMUfajLB6yqpKjmitefPCthd6HaZKfjgTeP82YvwjosiYfeXZLnGZTFbbH568ef5c0cYuKkxwD0uUx3AULQOG4opqkxoXrcrUGiEUSbCUiEUaTXTxLRtIeeLlINRSEJcbbH5kl4KEGd6RPCthd6HaZKLYgFSUGC4TgIjp6EoXrcHdLnXLyYJUVFbbHSMnhbC)ccwfitrkVA0u96caaLSFbbRT42R8nKGO611Xs2VGGv(nkeee6D5KEGd6RxxGKYBlxzL4iHixqepx2ao3(feeMlINRSEJcbbH5kl4KEGd6Z15jkYLvjtblqrUiEUoHMY96MRu0LN7rquzQMYnDmOhcmtwkB8X6cYH3AiM8O75ehjeoGCzcPWHbKPbOeFcQQitblqrLERlifaayakXNGQMM8xxVu0L7HcIktv6TUGuou2exIjp6((feeYA2CeW9liyvGmfP8Qrt1Rlaa0VGGv(nkeee6D5KEGd6RCQXMhYAMAesOqo)1ofot07JcYtsjyLtn28qGKYBlx2ao3ZBsq56KLsWsjxNq4SjfMlN4iHixqepx2ao3(feewt5Mog0dbMjlLn(yDb5WBnetE09CIJechqUmHu4WaY0auIpbvHVjb5jPeSYTxI2zYMdLnXLyYJUVFbbHSMTuEB5YgW5EEtckxNSucwk5YQOCFuKlN4iHixNNOix2aoxyyAjG5IaZnkOCpVjbLRtwkbZTFbbZfWscCUWW0sKRZtuKldCKPGJIY96cKAk30XGEiWmzPSXhRlihERHyYJUNtCKq4aYLjNGu4WaY0auIpbvHVjb5jPeSYTxI2zYMJ9liyf(MeKNKsWkmmTeTZKnz3VGG1ohzk4OO61nLB6yqpeyMSu24J1fKdV1qmTM(fw41OxnXGEhkBIlXuJA6iVlA(awve4ONODMSbmBYaahMG(O2QabdHupm4JeuLERliLJAesOqo)1wfiyiK6HbFKGQCQXMhYAjbcW9liyTZrMcokQEDDKEI3sA7oTmDSK9liyfkXvi82R8Aocc7ONG1RBkVTCLLNOi3MRigxbLBy8wuaDi3OyG5w24J1fuUdmxDbPLGu5gOCvKEuuUoxqrbXZfIAOCzfSkmxyb6ku52PCHsFnPY15jkYLbHPOCb6IlNlnLB6yqpeyMSu24J1fKdV1qm7ctrEqXLZL6HsFTdLnXLycDjHWhgVffWAxykYdkUCUuwZMJCBuEQm9r1ukyD(2ztMaaq)ccw7ctrEqXLZLwVUPCthd6HaZKfTjeEthd69Ibgo8wdXegKjIchgqMWGmruqQQjePCthd6HaZKfTjeEthd69Ibgo8wdXuRGP82YfOp)alY1ICBSspn3MCzfYIAUNBhgCth5IEkxqepxY0f5Yahzk4OOCTxLBPY1fXJ7pH0CDUG(CbA)oAjYLv5MZ5oWCHKG0bPY1EvUojqwn3bM7JIC5KPKMRbgep3OGY9Psh5cjn6v1uUPJb9qGzYc)(Ethd69Ibgo8wdXeC(bw4WaYuJA6iVlA(a2otTRVXkTh6sVs2aUFbbRDoYuWrr1RlW9liyf56I4X9NqA96cezaGdtqFuzLEhTeEf3CUsV1fKYraxYWe0h1gJlbP8GiUxrwuuP36csbaaAesOqo)1gJlbP8GiUxrwuu5uJnpSDjbcqs5Mog0dbMjlAti8Mog07fdmC4TgIz)ocvk30XGEiWmzX4A7jFG4C6dhgqM0t8wsRkcC0t0otjlbW0t8wsRCQf9PCthd6HaZKfJRTN8UxbKs5Mog0dbMjlIPvra9SYUQwn0hP8uEB5YWDekIdt5TLlqdKYvwmWajY9uGIChWCNixNrpGiYvBU5QrnDuUUO5dyU2RYnkOClvUUiEC)jKMB)ccM7aZ96wZ1jkJgvUx48TY15c6ZTutKBUSsqxEUYYtaZfgMwcyUgNYTyAvK79feeMBuq5YQKPGfOi3(fem3bMRjGOCVU1uUPJb9WA)ocft3bgiHhwGchgqM9liyf56I4X9NqA966iG7xqWQee56LIUCVZta9whDdVu0TcdtlbRzReaaq)ccwvKPGfOOEDbaa6jElPSwglbqs5Mog0dR97iuaZKf48dmiUhg8rckLNYBlxwbcjuiNFyk30XGEyvRGmDrXGEhgqM9liyTlqiL4cJkNmDaaa9liy1uC6nX8KNFHf1RBkVTCb6MqmFRC7MwICduUkc0UIi3jOMCVqRfLYnDmOhw1kiWmz5cj)euJdV1qmlB8X6cYpFqpCcP(wtlRmseEeupcHfZ3YZjthiUddiZ(feS2fiKsCHrLtMoaaGyAiFG8QHynt2KjaaOrnDK3fnFaRkcC0tWAMSLYnDmOhw1kiWmz5cj)eud0HbKzjHbzIOGuvtiCeW9liyTlqiL4cJkNmDaaaAuth5DrZhWQIah9eSMjBajLB6yqpSQvqGzYsxGqkp4LlnLB6yqpSQvqGzYsN4qIlX8Ts5Mog0dRAfeyMSaoCQlqivk30XGEyvRGaZKf71em4MWRnHiLB6yqpSQvqGzYIP40BI5jp)clCyazwY(feSAko9MyEYZVWI611r6jElP1yAiFG8nwPBxYuEB5klbMRPuWCnoL711HCH)4s5gfuUONY15jkYvGCMGrUmYiRwZfObs56Cb95QKoFRCbnyq8CJc7ZLvilYvrGJEICr8CDEIc0nY1EP5YkKf1uUPJb9WQwbbMjlngxcs5brCVISOWHbKj3gLNktFunLcwVUoc4W4TOOgtd5dKxneR1OMoY7IMpGvfbo6jaaGscdYerbPQCuRl5Og10rEx08bSQiWrpr7m1U(gR0EOl9kzljqs5TLRSeyUpkxtPG568ie5QgkxNNOy(CJck3NkDKlqjtOd5EHuUojqwnx0NBhbH568efOBKR9sZLvilQPCthd6HvTccmtwAmUeKYdI4EfzrHdditUnkpvM(OAkfSoF7aLmLn3gLNktFunLcwvxUfd6DSKWGmruqQkh16soQrnDK3fnFaRkcC0t0otTRVXkTh6sVs2sMYBlxgeMIYfOlUCU0CrFUSbCU0tndbR5klprrUMsblLCbAGuUdyUrbjnxyysZfeXZfqcCUqsJEfmxep3bmxPOlp3NkDKRUW4TOCDEeIC7uUCYusZD(CJPHYfeXZnkOCFQ0rUoBLPAk30XGEyvRGaZKLUWuKhuC5CPomGmHUKq4dJ3Icy7mzZXs2VGG1UWuKhuC5CP1RRJaUFbbRCKq4JcY3rpbRxxaaOFbbRqXOjV9kVA0u96cehbCj52O8uz6JQPuWkv6bgqaaGBJYtLPpQMsbRCQXMh2oGeaa42O8uz6JQPuW68Tdy2KTgHekKZFTlmf5bfxoxAvxy8we0dYnDmO3eargWwjask30XGEyvRGaZKLwfiyiK6HbFKGCyazw24J1fuTlmf5bfxoxQhk91oQrnDK3fnFaRkcC0t0otjbUFbbRDoYuWrr1RBk30XGEyvRGaZKfjgHy(wEOlNihgqMLn(yDbv7ctrEqXLZL6HsFTJaMEI3sAnMgYhiFJv62LeaaON4TKY6sitaaOFbbRMItVjMN88lSOEDbsk30XGEyvRGaZKLUWuKNFHfomGmlB8X6cQ2fMI8GIlNl1dL(AhPN4TKwJPH8bY3yLUDjt5TLlqdC(w5c0Q9dSGfNOPFHf5oWCrVqAUwULjU0CJ5LM78AozqYHCHOCNpxozIjK6qUsrxabNY16qK4gKqAUGZt5gOCVqk3jY1G5A5EJrmH0CHUKqut5Mog0dRAfeyMSu2(bw4WaYSKWGmruqQQjeow24J1fu1A6xyHxJE1ed6t5Mog0dRAfeyMSalmfY5gsOCyazwsyqMikiv1echlB8X6cQAn9lSWRrVAIb9PCthd6HvTccmtw0Mq4nDmO3lgy4WBnetccPxtWuEk30XGEyLGq61eKPg9A6dUfKYdkSgkLB6yqpSsqi9Accmtw6ces5rG(OG80tnst5Mog0dReesVMGaZKLwxJRg79iqVbOehffPCthd6HvccPxtqGzYcisFHKYBakXNG8DYAs5Mog0dReesVMGaZKf3lFaLoFlFxyWiLB6yqpSsqi9AccmtwIcYF)o6(kpiIRPuUPJb9WkbH0RjiWmzHpUUcYpVh6AAkLB6yqpSsqi9AccmtwCgXfQY08EobrV9AkLB6yqpSsqi9AccmtwAOgexQhb6fx9O8koznqhgqM0t8wszTmwIuEkVTCb6ZpWcIdt5TLldHtoxuzINRSgmKlN4iHaMRZtuKlRsMcwGcwCcnLBWTjG5I45kR3OqqqyUYcoPh4G(Ak30XGEyfC(bwWStHZe9(OG8Kuc6WaYSFbbR8Buiii07Yj9ah0xVUaaaGnaL4tqvfzkybkQ0BDbPaaadqj(eu10K)66LIUCpuquzQsV1fKcio2VGGvosi8rb57ONG1RBk30XGEyfC(bwamtwGIrtE7vE1OjhgqM9liyfkgn5Tx5vJMQCQXMhY6W4TOOgtd5dKxnKJ9liyfkgn5Tx5vJMQCQXMhYAaljWAuth5DrZhqGidKScit5Mog0dRGZpWcGzYchje(OG8D0tqhgqM9liyLJecFuq(o6jyLtn28qwZeOs5Mog0dRGZpWcGzYchje(OG8D0tqhgqMa20XuM80tndbzkjaa0VGG1UWuKhuC5CPvfY5hiow24J1fuLhDpN4iHiL3wUmeo5CDEIICJckxNqt5c04MlRe0LN7rquzkxepxwLmfSaf5gCBcynLB6yqpSco)alaMjlDkCMO3hfKNKsqhgqMgGs8jOQPj)11lfD5EOGOYuLERlifaayakXNGQkYuWcuuP36csLYnDmOhwbNFGfaZKf1aDTqxKYt5TL7jitefPCthd6HvyqMikyAn9lSaFktC4GEm7SjtjDkzkJskdRSXMm604JZg)NVfeFKLACr8Gu5kdZ10XG(CfdmG1uo(y3OaXXNZ0WkWhXadiMr8HGq61eeZiMDjXmIpMog0JpA0RPp4wqkpOWAi8HERlifMbCGzNnmJ4JPJb94txGqkpc0hfKNEQrk(qV1fKcZaoWSduygXhthd6XNwxJRg79iqVbOehff4d9wxqkmd4aZUmIzeFmDmOhFar6lKuEdqj(eKVtwd(qV1fKcZaoWSxcmJ4JPJb94J7LpGsNVLVlmyGp0BDbPWmGdm7onMr8X0XGE8jki)97O7R8GiUMWh6TUGuygWbMDziMr8X0XGE8HpUUcYpVh6AAcFO36csHzahy2bKygXhthd6XhNrCHQmnVNtq0BVMWh6TUGuygWbMDNcZi(qV1fKcZa(O5tq8XWh6jElP5Y6CLXsGpMog0JpnudIl1Ja9IREuEfNSgioWb(Oiq7kcmJy2LeZi(y6yqp(adYerb(qV1fKcZaoWSZgMr8X0XGE8rIrlb(qV1fKcZaoWSduygXh6TUGuygWhKl(aPaFmDmOhFkB8X6ccFkBIlHp8O77xqqyUSox2Y1XCbCU9liyvGmfP8Qrt1RBUaaqULm3(feS2IBVY3qcIQx3CDm3sMB)ccw53OqqqO3Lt6boOVEDZfi4tzJ7FRHWhE09CIJecCGzxgXmIp0BDbPWmGpix8bsb(y6yqp(u24J1fe(u2excF4r33VGGWCzDUSLRJ5c4C7xqWQazks5vJMQx3CbaGC7xqWk)gfccc9UCspWb9vo1yZdZL1mZvJqcfY5V2PWzIEFuqEskbRCQXMhMlqWhnFcIpg(yakXNGQkYuWcuuP36csLlaaKRbOeFcQAAYFD9srxUhkiQmvP36csHpLnU)TgcF4r3ZjosiWbM9sGzeFO36csHzaFqU4dKc8X0XGE8PSXhRli8PSjUe(WJUVFbbH5Y6CzdF08ji(y4JbOeFcQcFtcYtsjyLBVe52oZCzdFkBC)Bne(WJUNtCKqGdm7onMr8HERlifMb8b5IpCcsb(y6yqp(u24J1fe(u24(3Ai8HhDpN4iHaF08ji(y4JbOeFcQcFtcYtsjyLBVe52oZCzlxhZTFbbRW3KG8KucwHHPLi32zMlB5k7C7xqWANJmfCuu96Idm7YqmJ4d9wxqkmd4dYfFGuGpMog0JpLn(yDbHpLnXLWhnQPJ8UO5dyvrGJEICBNzUSLlW5YwUYGCbCUHjOpQTkqWqi1dd(ibvP36csLRJ5QriHc58xBvGGHqQhg8rcQYPgBEyUSoxjZfi5cCU9liyTZrMcokQEDZ1XCPN4TKMB7560YmxhZTK52VGGvOexHWBVYR5iiSJEcwVU4tzJ7FRHWhRPFHfEn6vtmOhhy2bKygXh6TUGuygWhKl(aPaFmDmOhFkB8X6ccFkBIlHpqxsi8HXBrbS2fMI8GIlNlnxwNlB56yUCBuEQm9r1ukyD(CBpx2KzUaaqU9liyTlmf5bfxoxA96IpLnU)TgcF6ctrEqXLZL6HsFnoWS7uygXh6TUGuygWhnFcIpg(adYerbPQMqGpMog0JpAti8Mog07fdmWhXad)Bne(adYerboWSlPmXmIp0BDbPWmGpMog0JpAti8Mog07fdmWhXad)Bne(OvqCGzxsjXmIp0BDbPWmGpA(eeFm8rJA6iVlA(aMB7mZv76BSs7HU0RYv25c4C7xqWANJmfCuu96MlW52VGGvKRlIh3FcP1RBUajxzqUao3We0hvwP3rlHxXnNR0BDbPY1XCbCULm3We0h1gJlbP8GiUxrwuuP36csLlaaKRgHekKZFTX4sqkpiI7vKffvo1yZdZT9CLmxGKlqWhthd6Xh(99Mog07fdmWhXad)Bne(ao)alWbMDjzdZi(qV1fKcZa(y6yqp(OnHWB6yqVxmWaFedm8V1q4t)ocfoWSljqHzeFO36csHzaF08ji(y4d9eVL0QIah9e52oZCLSe5cCU0t8wsRCQf94JPJb94JX12t(aX50h4aZUKYiMr8X0XGE8X4A7jV7vaj8HERlifMbCGzxYsGzeFmDmOhFetRIa6zLDvTAOpWh6TUGuygWboWhxoPrnDlWmIzxsmJ4d9wxqkmd4aZoBygXh6TUGuygWbMDGcZi(qV1fKcZaoWSlJygXh6TUGuygWbM9sGzeFmDmOhFCrXGE8HERlifMbCGz3PXmIp0BDbPWmGpMog0Jpngxcs5brCVISOaF08ji(y4d3gLNktFunLcwNp32ZvgLj(4YjnQPBHhsA0RG4tjWbMDziMr8HERlifMb8X0XGE8XuC6nX8KNFHf4JlN0OMUfEiPrVcIpsIdm7asmJ4JPJb94dmitef4d9wxqkmd4aZUtHzeFO36csHzaFmDmOhF4iHWhfKVJEcIpUCsJA6w4HKg9ki(WgoWSlPmXmIp0BDbPWmGpMog0JpqXOjV9kVA0e(4YjnQPBHhsA0RG4dB4aZUKsIzeFO36csHzaF08ji(y4t)ccw5iHWhfKVJEcwVU56yUMoMYKNEQziyUTNRK4JPJb94txykYdkUCUuCGd8bC(bwGzeZUKygXh6TUGuygWhnFcIpg(0VGGv(nkeee6D5KEGd6Rx3CbaGCbCUgGs8jOQImfSafv6TUGu5caa5AakXNGQMM8xxVu0L7HcIktv6TUGu5cKCDm3(feSYrcHpkiFh9eSEDXhthd6XNofot07JcYtsjioWSZgMr8HERlifMb8rZNG4JHp9liyfkgn5Tx5vJMQCQXMhMlRZnmElkQX0q(a5vdLRJ52VGGvOy0K3ELxnAQYPgBEyUSoxaNRK5cCUAuth5DrZhWCbsUYGCLSciXhthd6XhOy0K3ELxnAchy2bkmJ4d9wxqkmd4JMpbXhdF6xqWkhje(OG8D0tWkNAS5H5YAM5cu4JPJb94dhje(OG8D0tqCGzxgXmIp0BDbPWmGpA(eeFm8bW5A6yktE6PMHG5YmxjZfaaYTFbbRDHPipO4Y5sRkKZFUajxhZTSXhRlOkp6EoXrcb(y6yqp(WrcHpkiFh9eehy2lbMr8HERlifMb8rZNG4JHpgGs8jOQPj)11lfD5EOGOYuLERlivUaaqUgGs8jOQImfSafv6TUGu4JPJb94tNcNj69rb5jPeehy2DAmJ4JPJb94JAGUwOlWh6TUGuygWboWhyqMikWmIzxsmJ4JPJb94J10VWc8HERlifMbCGd8rRGygXSljMr8HERlifMb8rZNG4JHp9liyTlqiL4cJkNmDKlaaKB)ccwnfNEtmp55xyr96IpMog0JpUOyqpoWSZgMr8HERlifMb8X0XGE8PSXhRli)8b9WjK6BnTSYir4rq9iewmFlpNmDG44JMpbXhdF6xqWAxGqkXfgvoz6ixaai3yAiFG8QHYL1mZLnzMlaaKRg10rEx08bSQiWrprUSMzUSHpV1q4tzJpwxq(5d6Hti13AAzLrIWJG6riSy(wEoz6aXXbMDGcZi(qV1fKcZa(O5tq8XWNsMlmitefKQAcrUoMlGZTFbbRDbcPexyu5KPJCbaGC1OMoY7IMpGvfbo6jYL1mZLTCbc(y6yqp(CHKFcQbIdm7YiMr8X0XGE8PlqiLh8YLIp0BDbPWmGdm7LaZi(y6yqp(0joK4smFl8HERlifMbCGz3PXmIpMog0JpGdN6cesHp0BDbPWmGdm7YqmJ4JPJb94J9AcgCt41MqGp0BDbPWmGdm7asmJ4d9wxqkmd4JMpbXhdFkzU9liy1uC6nX8KNFHf1RBUoMl9eVL0AmnKpq(gR052EUsIpMog0JpMItVjMN88lSahy2DkmJ4d9wxqkmd4JMpbXhdF42O8uz6JQPuW61nxhZfW5ggVff1yAiFG8QHYL15QrnDK3fnFaRkcC0tKlaaKBjZfgKjIcsv5OwxkxhZvJA6iVlA(awve4ONi32zMR213yL2dDPxLRSZvYCbc(y6yqp(0yCjiLheX9kYIcCGzxszIzeFO36csHzaF08ji(y4d3gLNktFunLcwNp32ZfOKzUYoxUnkpvM(OAkfSQUClg0NRJ5wYCHbzIOGuvoQ1LY1XC1OMoY7IMpGvfbo6jYTDM5QD9nwP9qx6v5k7CLeFmDmOhFAmUeKYdI4EfzrboWSlPKygXh6TUGuygWhnFcIpg(aDjHWhgVffWCBNzUSLRJ5wYC7xqWAxykYdkUCU061nxhZfW52VGGvosi8rb57ONG1RBUaaqU9liyfkgn5Tx5vJMQx3CbsUoMlGZTK5YTr5PY0hvtPGvQ0dmG5caa5YTr5PY0hvtPGvo1yZdZT9CbK5caa5YTr5PY0hvtPG15ZT9CbCUSLRSZvJqcfY5V2fMI8GIlNlTQlmElc6b5Mog0BICbsUYGCzRe5ce8X0XGE8Plmf5bfxoxkoWSljBygXh6TUGuygWhnFcIpg(u24J1fuTlmf5bfxoxQhk9156yUAuth5DrZhWQIah9e52oZCLmxGZTFbbRDoYuWrr1Rl(y6yqp(0QabdHupm4JeeoWSljqHzeFO36csHzaF08ji(y4tzJpwxq1UWuKhuC5CPEO0xNRJ5c4CPN4TKwJPH8bY3yLo32ZvYCbaGCPN4TKMlRZTeYmxaai3(feSAko9MyEYZVWI61nxGGpMog0JpsmcX8T8qxor4aZUKYiMr8HERlifMb8rZNG4JHpLn(yDbv7ctrEqXLZL6HsFDUoMl9eVL0AmnKpq(gR052EUsIpMog0JpDHPip)clWbMDjlbMr8HERlifMb8rZNG4JHpLmxyqMikiv1eICDm3YgFSUGQwt)cl8A0RMyqp(y6yqp(u2(bwGdm7s60ygXh6TUGuygWhnFcIpg(uYCHbzIOGuvtiY1XClB8X6cQAn9lSWRrVAIb94JPJb94dSWuiNBiHchy2LugIzeFO36csHzaFmDmOhF0Mq4nDmO3lgyGpIbg(3Ai8HGq61eeh4aF63rOWmIzxsmJ4d9wxqkmd4JMpbXhdF6xqWkY1fXJ7pH061nxhZfW52VGGvjiY1lfD5ENNa6To6gEPOBfgMwICzDUSvICbaGC7xqWQImfSaf1RBUaaqU0t8wsZL15kJLixGGpMog0JpUdmqcpSaf4aZoBygXhthd6Xh48dmiUhg8rccFO36csHzah4ah4ahyma]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "battle_potion_of_agility",

        package = "Outlaw",
    } )

end