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


    spec:RegisterPack( "Outlaw", 20200124, [[daL7ibqirfpsvInHs8jkryuQs1PuLYQuLuEfkLzHs1TufyxI8lIIHPkYXikTmuWZOePPrKW1ufQTPkK(MQGQXPkeNJsQY6uLunpvrDpu0(ev6GQcYcjs9qkr0ePevxKsuAJejQpsjvOtsKiwPOQxsKintkPc6MQssTtkj)uvsYqPefhLsQalvvs8uv1uPeUQQGYwPKkPVsjvQXsjvuNLsQe7LWFPyWQCyQwScpMKjtQlJSzf9zrXOLsNwPvtjvKxJcnBuDBPy3a)g0WPuhNsQQLd55qnDHRlvBxu67OKgpLuoprSEIKMpr1(LSqwHfIV2dsyfdpXWtpjldsr6jR3JLIhlfIFiXMeFBxXONHeFG3qI)RQhCNvX32LWHUwyH4JHDKIe)2iSXVUmYKzJ2(iPGnYG3Mo3JfcuiFgYG3gLmI)OV8qkbigIV2dsyfdpXWtpjldsr6jR3JLIhBPIp2MucRy4rFs8BxTMaIH4RjSs8FPUxvp4oR19kWmDQY)sDTryJFDzKjZgT9rsbBKbVnDUhleOq(mKbVnkzQ8VuxEh0DKK6yqw2RJHNy4PkFL)L6SKToidHF9k)l19G6EiTM01jLUkgRlG1PPP35rDUkwiOo(IJuL)L6EqDpKwt66SrKc2m8OoP5UMQtkZ7iKK6ExdjmWse1nqKZyD)GCE0(wQY)sDpOolhcSerDDmvxGwaJuGRBb1HdY5rBQY)sDpOolhcSerDDmvxZcEDRZ1nHO6E1oIrsx3eIQZYjpAR79nSe46aWOoC32gIcs)wQY)sDpOUhklC11HieKZxqM6ELq660D0cYuN0Cxt1jL5DessDV3bCcJRJvQoiGlPUwplvNS1fokdfVLQ8Vu3dQ7viUBT6KsxoFbzQ7BJikv5FPUhu3ddt1fBdzcOrVuDtiQocOGDqqO6iGEbzQd5rlHQlADqDHJYqrk2gYeqJEPK4BJGZLtI)l19Q6b3zTUxbMPtv(xQRncB8RlJmz2OTpskyJm4TPZ9yHafYNHm4TrjtL)L6Y7GUJKuhdYYEDm8edpv5R8VuNLS1bzi8Rx5FPUhu3dP1KUoP0vXyDbSonn9opQZvXcb1XxCKQ8Vu3dQ7H0AsxNnIuWMHh1jn31uDszEhHKu37AiHbwIOUbICgR7hKZJ23sv(xQ7b1z5qGLiQRJP6c0cyKcCDlOoCqopAtv(xQ7b1z5qGLiQRJP6AwWRBDUUjev3R2rms66MquDwo5rBDVVHLaxhag1H722quq63sv(xQ7b19qzHRUoeHGC(cYu3ResxNUJwqM6KM7AQoPmVJqsQ79oGtyCDSs1bbCj116zP6KTUWrzO4TuL)L6EqDVcXDRvNu6Y5litDFBerPk)l19G6EyyQUyBitan6LQBcr1rafSdccvhb0litDipAjuDrRdQlCugksX2qMaA0lLQ8v(xQZYAns1dsx3GMqevNc2m8OUbLzb4uDpKsr2bUoae8Gwh1m786CvSqaUoiGljv5FPoxfleGt2isbBgEWCYDmJv(xQZvXcb4KnIuWMHhSXugVNPHaHhleu5FPoxfleGt2isbBgEWgtzMqOUY)sDFGBJBHrDiF11n6ZjPRdhEGRBqtiIQtbBgEu3GYSaCDoqxNnIEGnmIfKPUfxNgcOuL)L6CvSqaozJifSz4bBmLbdCBClmm4WdCL3vXcb4KnIuWMHhSXuMghXiPntiYOjpAz3grkyZWddMuqGgZ8XSVtMiF1gklbIKR140cYvkEQY7QyHaCYgrkyZWd2ykdoiNhTSVtMVNdz97RTnPt2qfJuGxPsAJc2y3dpwiWOPSRIKlphfeY1qwbjLefhgiiyvMb3Xrs3rESqGC5iF1gklbI0cY25ac5doLiRT4a)wL3vXcb4KnIuWMHhSXugeKZnrlzgqaHz3grkyZWddMuqGgZKHkVRIfcWjBePGndpyJPmy(QiJd0g9Qi2TrKc2m8WGjfeOXmzOY7QyHaCYgrkyZWd2ykJRreW5lGmOoULDBePGndpmysbbAmtzzFNmFphY63xBBsNSHkgPaVsL0gfSXUhESqGrtzxfjxEokiKRHScskjkomqqWQmdUJJKUJ8yHa5Yr(QnuwcePfKTZbeYhCkrwBXb(TkVRIfcWjBePGndpyJPmDmz2GAyh4netxQ4wh5yZeccdCASHSsOkVRIfcWjBePGndpyJPmDmz2GAyNMtsfgG3qmvsuCyGGGvzgChhSVtM5G8vBOSeisliBNdiKp4uIS2IdCL3vXcb4KnIuWMHhSXugBySqqLVY)sDwwRrQEq66OSessDX2q1fTuDUkGO6wCDEwF5(GtPk)l19keoiNhT1TZ6SHy8o4uDVdG1LTZbeYhCQocqnlHRBb1PGndpERY7QyHamtgxfJSVtM5GdY5rlPtiyMov5DvSqaMjoiNhTv(xQ7vieKZRBcr1XaB1n6ZjUow3OToRdHUM01z5RIQRBNQ7vfTeI1ft1HieKZRBcr1XaB1br1zDe5aDDVAItuDquDVspA5egxNLbrQfVqqQY7QyHamBmLjRJwFWj2bEdXefddIqqoN9SoVtmrXWm6Zj(zgy59rFotCORjTrVkk1TLlpNrFotzqoqBAiorPUnl5m6Zzc1JwoHXgBePw8cbPU9Bv(xQ7vieKZRBcr1XaB1n6ZjUoiQUxPhTCcJRZYGi1IxiOow3OTolNCnUfg1br19qkQUUDDsGDuDForzPuL3vXcby2yktwhT(GtSd8gIjkggeHGCo7qBMykyFNmDPsOnOKMCnUfgjc4doPLl3LkH2GsUImDBJeyhzWCIYsjc4doPzpRZ7etummJ(CIFMbwEF0NZeh6AsB0RIsDB5Yh95mH6rlNWyJnIulEHGeIA8fGFMPcc5AiRG0GcwjcyIwYqsiCcrn(cWVv5FPogyRUpWzKQZYkHWVEDpeNvxcUoeHGCEDtiQogyRUrFoXPkVRIfcWSXuMSoA9bNyh4netummicb5C2H2mXuW(oz6sLqBqjmWzKmKecNqoGXCzYa7zDENyIIHz0Nt8Zmu5FPogyRUpWzKQZYkHWVEDwoSoamQdriiNxhRB0whdSvhoCfJ46GZ6IwQUpWzKQZYkHW1n6ZzDVllB1HdxXyDSUrBDsJGUgVAQUU9BPkVRIfcWSXuMSoA9bNyh4netummicb5C2H2mreMc23jtxQeAdkHboJKHKq4eYbmMltgyz0NZeg4msgscHt4WvmMltgEWOpNPbc6A8QPu3UY)sDw3B0wN0Cxt1jL5DessDDB2RBZaGiQouNt468bmlvNd01foJuDuwcjjAxqM6IwpQBX1XaB19oag1PGDqSGm19Dl5B1br1HxqgovN0F2RZ64RM96EfltL3vXcby2yktwhT(GtSd8gIjkggeHGCo7qBMykyFNmh95mn4UMmtEhHKK62SN15DIjkgMrFoXpy0NZeMXoNBCG2OqqmEabeo1TFMbwEF0NZeh6AsB0RIsDB5YZz0NZugKd0MgItuQBZsoJ(CMq9OLtySXgrQfVqqQBZsoJ(CMgiORXRMsD73Q8UkwiaZgtzY6O1hCIDG3qm9Mrh3AuqGEJfcypRZ7etfSzan2Wfe4KMMRAJCzYaBm8AVhoNarktlehCjgCGwgPeb8bN0SOGqUgYkiLPfIdUedoqlJucrn(cWpl7BSn6ZzAGGUgVAk1TzHaekJKCF0NyjNrFotyg7CUXbAJcbX4beq4u3MLCg95mXir2gjWoYW6gyJpG9Wib2tD7kVRIfcWSXuMSoA9bNyh4neZrqgfeO3yHa2Z68oXC0NZeQhTCcJn2isT4fcsDB5YF3LkH2GsAY14wyKiGp4KwUCxQeAdk5kY0TnsGDKbZjklLiGp4K(nwg95mHGCUjAjZaciCQBx5FPoR7nARRPZJ1Mt1fokdfy2RlAxCDzD06dov3IRt1skgjDDbSonPwnvhRTu0sO6WWgQolPLJRd3c7CDDdQoSeGI01X6gT1jn31uDszEhHKu5DvSqaMnMYK1rRp4e7aVHyo4UMmtEhHKyWsak2Z68oXeBtCUjCugkWPb31KzY7iKKNzGfKVAdLLarY1ACAb5YWtYLp6ZzAWDnzM8ocjj1TR8UkwiaZgtzuoNBCvSqGHV4GDG3qmXb58OL9DYehKZJwsNCoVY7QyHamBmLr5CUXvXcbg(Id2bEdXuPXv(xQtkVGf3wNh114wBB6n1zjTmP6(9boqUkQdcO6MquDKRARtAe014vt15aDDVkBBik6GnKuhRTeOoRd6RIX6SCKZADlUomXjvq66CGUUx90YRBX1bGrDiY1sQZNbHQlAP6aK1I6WKcc0P6EioRUeCDnU1Qt6WYwhRB0whdSv3dPOuL3vXcby2ykdQdmUkwiWWxCWoWBiMZfS4w23jtfSzan2Wfe4CzQSnnU1myBcOFW7J(CMgiORXRMsDB2g95mbTTHOOd2qsQB)2R9E4CcejRFFvmA0iN1eb8bN0S8EoHZjqKACeJK2mHiJM8OnraFWjTC5kiKRHScsnoIrsBMqKrtE0MquJVaCUY(2BV27Uuj0guYvKPBBKa7idMtuwkHCaJpZGC55OGqUgYkinOGvIaMOLmKecN62YLNZOpNjeKZnrlzgqaHtD73Q8UkwiaZgtzuoNBCvSqGHV4GDG3qmh9LRR8UkwiaZgtzCKYbKjGiebc23jtcqOmssAAUQnYLPSpMncqOmssikdbQ8UkwiaZgtzCKYbKXUZXuL3vXcby2ykdFZ0gyJ1PUotdbIkVRIfcWSXuMHNXaNMaTkgXv(k)l1jDF5AcHR8Vu3ddt1zzwCa519BHrD7SUnQJviWse1PC76uWMbSoB4ccCDoqxx0s19QSTHrhSHK6g95SUfxx3ov3dLfU6664fKPowBjqDsPezxN1fyhvN19g46WHRyexNJO6A3mT11bCcJRlAP6SCY14wyu3OpN1T46Cogwx3ov5DvSqaon6lxZ0EXbKBWTWG9DYC0NZe02gIIoydjPUnlVp6ZzIrISnsGDKH1nWgFa7HrcSNWHRy8zzLc5Yh95mPjxJBHrQBlxobiugjplfp(TkVRIfcWPrF5A2ykdEbloiKbhOLrQYx5FPoljeY1qwb4kVRIfcWjLgZu5CUXvXcbg(Id2bEdXKWycOim77Kzo4GCE0s6KZ5vExfleGtknMnMY4AebC(cidQJBzFNmZz0NZKRreW5lGmOoUn1TzHaekJKuSnKjGMg3A5kllVNdz97RTnPtUuXToYXMjeeg40ydzLqYLRGqUgYkiX9GaHXrkh4je14laNldp9wL)L6KsM15AnUohr11TzVomyTP6IwQoiGQJ1nARJdzLWrDwyHLNQ7HHP6yTLa1PLSGm1nDCqO6IwhuNL0YuNMMRAJ6GO6yDJwypQZbsQZsAzsvExfleGtknMnMY04igjTzcrgn5rl7kjkozchLHcmtzzFNmr(QnuwcejxRXPUnlVhokdfPyBitan6LEwbBgqJnCbboPP5Q2qU8CWb58OL0jemtNyrbBgqJnCbboPP5Q2ixMkBtJBnd2Ma6hi7Bv(xQtkzwhawNR146yD5860lvhRB0UG6IwQoazTOol9jm711XuDV6PLxheu3aIX1X6gTWEuNdKuNL0YKQ8UkwiaNuAmBmLPXrmsAZeImAYJw23jtKVAdLLarY1ACAb5APp9aKVAdLLarY1ACs3rESqal5GdY5rlPtiyMoXIc2mGgB4ccCstZvTrUmv2Mg3AgSnb0pq2k)l1jn31uDszEhHKuheuhdSvhbOMLWP6SU3OToxRXVEDpmmv3oRlAjj1HdxsDtiQUhHT6WKcc046GO62zDsGDuDaYArDQwhLHQJ1LZRBq1HixlPUfuxSnuDtiQUOLQdqwlQJvplLQ8UkwiaNuAmBmLzWDnzM8ocjH9DYeBtCUjCugkW5YKbwYz0NZ0G7AYm5DessQBZY75G8vBOSeisUwJtK1wCGLlh5R2qzjqKCTgNquJVaCUpIC5iF1gklbIKR140cY9DgEGcc5AiRG0G7AYm5Desss16Ome2mrUkwiW5V9Am843Q8UkwiaNuAmBmLjtlehCjgCGwgj23jZSoA9bNsdURjZK3rijgSeGIffSzan2Wfe4KMMRAJCzklBJ(CMgiORXRMsD7kVRIfcWjLgZgtzyC58fKXGTreX(ozM1rRp4uAWDnzM8ocjXGLauS8obiugjPyBitannU1Y9XYLtacLrYZY(43Q8UkwiaNuAmBmLzWDnzqDCl77KzwhT(GtPb31KzY7iKedwcqXcbiugjPyBitannU1Yv2k)l19WWlitDwxDWIBL5HAgDCBDlUoiGlPoVUSessDXcKu3cuiYXe71HH1TG6qKZ3qc71jb2TeiQoFGH8EqCj1nxavxaRRJP62OohxNxxpw(gsQdBtCEQY7QyHaCsPXSXuMSoyXTSVtM5GdY5rlPtoNZswhT(GtjVz0XTgfeO3yHGkVRIfcWjLgZgtzWTUgYAdX1SVtM5GdY5rlPtoNZswhT(GtjVz0XTgfeO3yHGkVRIfcWjLgZgtzSHXcbSVtMJ(CMgCiuZ74iHixfYLp6ZzY1ic48fqguh3M62v(xQtk7C(cYu3WvmwxaRtttVZJ62GAQRJ9muL3vXcb4KsJzJPmDmz2GAyh4neZSoA9bNmliiaEdjMmBgplKhgiwTCUhliJbrUkGi23jZrFotdoeQ5DCKqKRc5YJTHmb0Ox6zMm8KC5kyZaASHliWjnnx1gpZKHkVRIfcWjLgZgtz6yYSb1GzFNmh95mn4qOM3XrcrUkKlp2gYeqJEPNzYWtYLRGndOXgUGaN00CvB8mtgQ8UkwiaNuAmBmLzWHqTz2rsQ8UkwiaNuAmBmLzqimHyCbzQ8UkwiaNuAmBmLzUiAWHqDL3vXcb4KsJzJPmoqr4a5CJY58kVRIfcWjLgZgtz6yYSb1WonNKkmaVHyQKO4WabbRYm4ooyFNmZbhKZJwsNCoNLrFotUgraNVaYG642KgYkGLrFotnudejXaNgExTAJgrEdoPHScyHaekJKuSnKjGMg3A5kfSGIHz0Nt8ZpUY7QyHaCsPXSXuMoMmBqnSd8gIPlvCRJCSzcbHbon2qwje77KzoJ(CMCnIaoFbKb1XTPUnl5m6ZzAWDnzM8ocjj1TzrbHCnKvqY1ic48fqguh3MquJVa8ZY(4k)l1zDLqsQdb7zA5sQd15uDWzDrBVzSZL0114rlUUbXHS(619WWuDtiQoPeaJ2qDDk0gSxhmAjeRlMQJ1nAR7HEL68OogEIT6WHRyexhevNSpXwDSUrBDohdRtAoeQRRBNQ8UkwiaNuAmBmLPJjZgud7aVHy642SoGWgKlviYOGiNZ(ozQPrFotixQqKrbro3OPrFotAiRa5Y10OpNjfeO7QyZsMfWOrtJ(CM62SeokdfPwY5rBYwfpBPmWs4OmuKAjNhTjBvKltl9j5YZrtJ(CMuqGURInlzwaJgnn6ZzQBZY7AA0NZeYLkezuqKZnAA0NZeoCfJ5YKHNEGSp9AAA0NZ0GdHAdCAIwYqaQrsQBlxE4OmuKITHmb0Ox65h9P3yz0NZKRreW5lGmOoUnHOgFb4CL9rQ8VuNLttVZJ6MoNpCfJ1nHO66yFWP62GAWPkVRIfcWjLgZgtz6yYSb1GzFNmh95mn4qOM3XrcrUkKlp2gYeqJEPNzYWtYLRGndOXgUGaN00CvB8mtgQ8v(xQZYIXeqr4kVRIfcWjcJjGIWmvqGIabYdsBMCVHyFNmjaHYijfBdzcOPXTwUYYsoJ(CMgCxtMjVJqssDBwEphnmskiqrGa5bPntU3qMrhbsXQyCbzyjhxfleKuqGIabYdsBMCVHslWm5BM2qU8zNZnis16OmKj2g65mkDQXT2BvExfleGtegtafHzJPmdoeQnWPjAjdbOgjSVtMzD06doLgCxtMjVJqsmyjaflkiKRHScsdkyLiGjAjdjHWPUnlzD06doLgbzuqGEJfcQ8UkwiaNimMakcZgtzY0DKEDGbonUujemAR8UkwiaNimMakcZgtzMqvhtAJlvcTbzgK3W(ozITjo3eokdf40G7AYm5DessUmzqUCKVAdLLarY1ACAb5(OpXsoJ(CMCnIaoFbKb1XTPUDL3vXcb4eHXeqry2ykJDhTtjliJzWDCW(ozITjo3eokdf40G7AYm5DessUmzqUCKVAdLLarY1ACAb5(Opv5DvSqaorymbueMnMYeTKPdgWoqBMqKIyFNmh95mHifJCcJntisrPUTC5J(CMqKIroHXMjePiJc2bbHs4Wvm(SSpv5DvSqaorymbueMnMYGwBBozwGbB7kQY7QyHaCIWycOimBmLHviIRZslWGime4afv5DvSqaorymbueMnMY0qnqKedCA4D1QnAe5ny23jtcqOmsEwkECL3vXcb4eHXeqry2ykdIC7fKXm5EdHzFNmdhLHIul58OnzRICFKNKlpCugksTKZJ2KTkEMjdpjxE4OmuKITHmb0yRcddpLRL(uLVY)sDs5fS4wcHR8VuN0HLToywcv3ResxhIqqohxhRB0wNLtUg3cdzEifvxG8nW1br19k9OLtyCDwgePw8cbPkVRIfcWP5cwClZbfSseWeTKHKqy23jZSoA9bNsJGmkiqVXcbvExfleGtZfS4w2ykdMVkY4aTrVkI9DYC0NZeMVkY4aTrVkkHOgFb4NJTHmb0OxILrFoty(QiJd0g9QOeIA8fGF(DzztbBgqJnCbb(Txt20Ju5DvSqaonxWIBzJPmiiNBIwYmGacZ(ozo6Zzcb5Ct0sMbeq4eIA8fGFMPLkxEwhT(Gtjummicb58k)l1jDyzRJ1nARlAP6Eifv3dZUoRlWoQUpNOSuDquDwo5AClmQlq(g4uL3vXcb40CblULnMYmOGvIaMOLmKecZ(oz6sLqBqjxrMUTrcSJmyorzPeb8bN0YL7sLqBqjn5AClmseWhCsx5DvSqaonxWIBzJPm6fB7HQTYx5FPUFqopAR8UkwiaNWb58OLP3m64wXplHWleiSIHNK169K1JHhl(S6iWcYGfFPKgBikiDDp86CvSqqD8fh4uLx89E0crI)FBSKIpFXbwyH4tymbuewyHWkzfwi(eWhCslKw8vOni06IpbiugjPyBitannU1Ql36KTowQlN6g95mn4UMmtEhHKK621XsDVxxo1PHrsbbkceipiTzY9gYm6iqkwfJlitDSuxo15QyHGKccueiqEqAZK7nuAbMjFZ0g1jxEDZoNBqKQ1rzitSnuDpxxgLo14wRU3eFxflei(kiqrGa5bPntU3qIqyfdcleFc4doPfsl(k0geADXpRJwFWP0G7AYm5DesIblbOQJL6uqixdzfKguWkrat0sgscHtD76yPUSoA9bNsJGmkiqVXcbIVRIfce)bhc1g40eTKHauJeriSYsfwi(Ukwiq8Z0DKEDGbonUujemAfFc4doPfslcHvsHWcXNa(GtAH0IVcTbHwx8X2eNBchLHcCAWDnzM8ocjPUCzwhd1jxEDiF1gklbIKR140cQl36E0NQJL6YPUrFotUgraNVaYG642u3w8DvSqG4pHQoM0gxQeAdYmiVrecRESWcXNa(GtAH0IVcTbHwx8X2eNBchLHcCAWDnzM8ocjPUCzwhd1jxEDiF1gklbIKR140cQl36E0NeFxflei(2D0oLSGmMb3XHiew9OcleFc4doPfsl(k0geADXF0NZeIumYjm2mHifL621jxEDJ(CMqKIroHXMjePiJc2bbHs4Wvmw3Z1j7tIVRIfce)OLmDWa2bAZeIuKiew9Wfwi(Ukwiq8rRTnNmlWGTDfj(eWhCslKwecREeHfIVRIfceFwHiUolTadIWqGduK4taFWjTqAriSY6jSq8jGp4KwiT4RqBqO1fFcqOmsQ756KIhl(Ukwiq8BOgisIbon8UA1gnI8gSiewj7tcleFc4doPfsl(k0geADXpCugksTKZJ2KTkQl36EKNQtU86chLHIul58OnzRI6EMzDm8uDYLxx4OmuKITHmb0yRcddpvxU1zPpj(Ukwiq8rKBVGmMj3BiSieH4RPP35HWcHvYkSq8jGp4KwiT4RqBqO1f)CQdhKZJwsNqWmDs8DvSqG4Z4QyuecRyqyH47QyHaXhhKZJwXNa(GtAH0IqyLLkSq8jGp4KwiT4dTfFmfIVRIfce)SoA9bNe)SoVtIpkgMrFoX19CDmuhl19EDJ(CM4qxtAJEvuQBxNC51LtDJ(CMYGCG20qCIsD76yPUCQB0NZeQhTCcJn2isT4fcsD76Et8Z6idWBiXhfddIqqoxecRKcHfIpb8bN0cPfFOT4JPq8DvSqG4N1rRp4K4N15Ds8rXWm6ZjUUNRJH6yPU3RB0NZeh6AsB0RIsD76KlVUrFotOE0Yjm2yJi1IxiiHOgFb46EMzDkiKRHScsdkyLiGjAjdjHWje14lax3BIVcTbHwx8DPsOnOKMCnUfgjc4doPRtU86CPsOnOKRit32ib2rgmNOSuIa(GtAXpRJmaVHeFummicb5CriS6XcleFc4doPfsl(qBXhtH47QyHaXpRJwFWjXpRZ7K4JIHz0NtCDpxhdIVcTbHwx8DPsOnOeg4msgscHtihWyD5YSoge)SoYa8gs8rXWGieKZfHWQhvyH4taFWjTqAXhAl(ictH47QyHaXpRJwFWjXpRJmaVHeFummicb5CXxH2GqRl(Uuj0gucdCgjdjHWjKdySUCzwhd1XsDJ(CMWaNrYqsiCchUIX6YLzDmu3dQB0NZ0abDnE1uQBlcHvpCHfIpb8bN0cPfFOT4JPq8DvSqG4N1rRp4K4N15Ds8rXWm6ZjUUhu3OpNjmJDo34aTrHGy8aciCQBx3Z1XqDSu371n6ZzIdDnPn6vrPUDDYLxxo1n6ZzkdYbAtdXjk1TRJL6YPUrFotOE0Yjm2yJi1Ixii1TRJL6YPUrFotde014vtPUDDVj(k0geADXF0NZ0G7AYm5DessQBl(zDKb4nK4JIHbriiNlcHvpIWcXNa(GtAH0Ip0w8Xui(Ukwiq8Z6O1hCs8Z68oj(kyZaASHliWjnnx1g1LlZ6yOo2QJH6ET6EVUW5eiszAH4GlXGd0YiLiGp4KUowQtbHCnKvqktlehCjgCGwgPeIA8fGR756KTU3QJT6g95mnqqxJxnL621XsDeGqzKuxU19Opvhl1LtDJ(CMWm25CJd0gfcIXdiGWPUDDSuxo1n6ZzIrISnsGDKH1nWgFa7HrcSN62IFwhzaEdj(EZOJBnkiqVXcbIqyL1tyH4taFWjTqAXhAl(ykeFxflei(zD06doj(zDENe)rFotOE0Yjm2yJi1Ixii1TRtU86EVoxQeAdkPjxJBHrIa(Gt66KlVoxQeAdk5kY0TnsGDKbZjklLiGp4KUU3QJL6g95mHGCUjAjZaciCQBl(zDKb4nK4pcYOGa9gleicHvY(KWcXNa(GtAH0Ip0w8Xui(Ukwiq8Z6O1hCs8Z68oj(yBIZnHJYqbon4UMmtEhHKu3Z1XqDSuhYxTHYsGi5AnoTG6YTogEQo5YRB0NZ0G7AYm5DessQBl(zDKb4nK4p4UMmtEhHKyWsakriSswzfwi(eWhCslKw8vOni06IpoiNhTKo5CU47QyHaXx5CUXvXcbg(IdXNV4Wa8gs8Xb58OvecRKLbHfIpb8bN0cPfFxflei(kNZnUkwiWWxCi(8fhgG3qIVsJfHWkzTuHfIpb8bN0cPfFfAdcTU4RGndOXgUGaxxUmRtzBACRzW2eqx3dQ796g95mnqqxJxnL621XwDJ(CMG22qu0bBij1TR7T6ET6EVUW5eisw)(Qy0OroRjc4doPRJL6EVUCQlCobIuJJyK0Mjez0KhTjc4doPRtU86uqixdzfKACeJK2mHiJM8OnHOgFb46YTozR7T6ERUxRU3RZLkH2GsUImDBJeyhzWCIYsjKdySUNRJH6KlVUCQtbHCnKvqAqbRebmrlzijeo1TRtU86YPUrFotiiNBIwYmGacN6219M47QyHaXh1bgxfley4loeF(IddWBiXFUGf3kcHvYkfcleFc4doPfsl(Ukwiq8voNBCvSqGHV4q85lomaVHe)rF5AriSs2hlSq8jGp4KwiT4RqBqO1fFcqOmssAAUQnQlxM1j7JRJT6iaHYijHOmeq8DvSqG47iLditariceIqyLSpQWcX3vXcbIVJuoGm2DoMeFc4doPfslcHvY(Wfwi(Ukwiq85BM2aBSo11zAiqi(eWhCslKwecRK9rewi(Ukwiq8hEgdCAc0Qyel(eWhCslKweIq8TrKc2m8qyHWkzfwi(eWhCslKw8DvSqG434igjTzcrgn5rR4RqBqO1fFKVAdLLarY1ACAb1LBDsXtIVnIuWMHhgmPGanw8FSiewXGWcXNa(GtAH0IVcTbHwx8FVUCQJS(912M0jBOIrkWRujTrbBS7Hhley0u2vr1jxED5uNcc5AiRGKsIIddeeSkZG74iP7ipwiOo5YRd5R2qzjqKwq2ohqiFWPezTfh46Et8DvSqG4JdY5rRiewzPcleFc4doPfsl(Ukwiq8rqo3eTKzabew8TrKc2m8WGjfeOXIpdIqyLuiSq8jGp4KwiT47QyHaXhZxfzCG2Oxfj(2isbBgEyWKcc0yXNbriS6XcleFc4doPfsl(Ukwiq8DnIaoFbKb1XTIVcTbHwx8FVUCQJS(912M0jBOIrkWRujTrbBS7Hhley0u2vr1jxED5uNcc5AiRGKsIIddeeSkZG74iP7ipwiOo5YRd5R2qzjqKwq2ohqiFWPezTfh46Et8TrKc2m8WGjfeOXIVSIqy1JkSq8jGp4KwiT4d8gs8DPIBDKJntiimWPXgYkHeFxflei(UuXToYXMjeeg40ydzLqIqy1dxyH4taFWjTqAX3vXcbIVsIIddeeSkZG74q8vOni06IFo1H8vBOSeisliBNdiKp4uIS2IdS4tZjPcdWBiXxjrXHbccwLzWDCicHvpIWcX3vXcbIVnmwiq8jGp4KwiTieH4pxWIBfwiSswHfIpb8bN0cPfFfAdcTU4N1rRp4uAeKrbb6nwiq8DvSqG4pOGvIaMOLmKeclcHvmiSq8jGp4KwiT4RqBqO1f)rFoty(QiJd0g9QOeIA8fGR756ITHmb0OxQowQB0NZeMVkY4aTrVkkHOgFb46EUU3Rt26yRofSzan2Wfe46ERUxRoztpI47QyHaXhZxfzCG2OxfjcHvwQWcXNa(GtAH0IVcTbHwx8h95mHGCUjAjZaciCcrn(cW19mZ6S06KlVUSoA9bNsOyyqecY5IVRIfceFeKZnrlzgqaHfHWkPqyH4taFWjTqAXxH2GqRl(Uuj0guYvKPBBKa7idMtuwkraFWjDDYLxNlvcTbL0KRXTWiraFWjT47QyHaXFqbRebmrlzijewecRESWcX3vXcbIVEX2EOAfFc4doPfslcri(4GCE0kSqyLScleFxflei(EZOJBfFc4doPfslcri(knwyHWkzfwi(eWhCslKw8vOni06IFo1HdY5rlPtoNl(Ukwiq8voNBCvSqGHV4q85lomaVHeFcJjGIWIqyfdcleFc4doPfsl(k0geADXpN6g95m5AebC(cidQJBtD76yPocqOmssX2qMaAACRvxU1jBDSu371LtDK1VV22Ko5sf36ihBMqqyGtJnKvcvNC51PGqUgYkiX9GaHXrkh4je14laxxU1XWt19M47QyHaX31ic48fqguh3kcHvwQWcXNa(GtAH0IVRIfce)ghXiPntiYOjpAfFfAdcTU4J8vBOSeisUwJtD76yPU3RlCugksX2qMaA0lv3Z1PGndOXgUGaN00CvBuNC51LtD4GCE0s6ecMPt1XsDkyZaASHliWjnnx1g1LlZ6u2Mg3AgSnb019G6KTU3eFLefNmHJYqbwyLSIqyLuiSq8jGp4KwiT4RqBqO1fFKVAdLLarY1ACAb1LBDw6t19G6q(QnuwcejxRXjDh5Xcb1XsD5uhoiNhTKoHGz6uDSuNc2mGgB4ccCstZvTrD5YSoLTPXTMbBtaDDpOozfFxflei(noIrsBMqKrtE0kcHvpwyH4taFWjTqAXxH2GqRl(yBIZnHJYqbUUCzwhd1XsD5u3OpNPb31KzY7iKKu3UowQ796YPoKVAdLLarY1ACIS2IdCDYLxhYxTHYsGi5AnoHOgFb46YTUhPo5YRd5R2qzjqKCTgNwqD5w371XqDpOofeY1qwbPb31KzY7iKKKQ1rziSzICvSqGZR7T6ET6y4X19M47QyHaXFWDnzM8ocjrecREuHfIpb8bN0cPfFfAdcTU4N1rRp4uAWDnzM8ocjXGLau1XsDkyZaASHliWjnnx1g1LlZ6KTo2QB0NZ0abDnE1uQBl(Ukwiq8Z0cXbxIbhOLrsecRE4cleFc4doPfsl(k0geADXpRJwFWP0G7AYm5DesIblbOQJL6EVocqOmssX2qMaAACRvxU1946KlVocqOmsQ756K9X19M47QyHaXNXLZxqgd2grKiew9icleFc4doPfsl(k0geADXpRJwFWP0G7AYm5DesIblbOQJL6iaHYijfBdzcOPXTwD5wNSIVRIfce)b31Kb1XTIqyL1tyH4taFWjTqAXxH2GqRl(5uhoiNhTKo5CEDSuxwhT(GtjVz0XTgfeO3yHaX3vXcbIFwhS4wriSs2Newi(eWhCslKw8vOni06IFo1HdY5rlPtoNxhl1L1rRp4uYBgDCRrbb6nwiq8DvSqG4JBDnK1gIRfHWkzLvyH4taFWjTqAXxH2GqRl(J(CMgCiuZ74iHixf1jxEDJ(CMCnIaoFbKb1XTPUT47QyHaX3ggleicHvYYGWcXNa(GtAH0IVRIfce)SoA9bNmliiaEdjMmBgplKhgiwTCUhliJbrUkGiXxH2GqRl(J(CMgCiuZ74iHixf1jxEDX2qMaA0lv3ZmRJHNQtU86uWMb0ydxqGtAAUQnQ7zM1XG4d8gs8Z6O1hCYSGGa4nKyYSz8SqEyGy1Y5ESGmge5QaIeHWkzTuHfIpb8bN0cPfFfAdcTU4p6ZzAWHqnVJJeICvuNC51fBdzcOrVuDpZSogEQo5YRtbBgqJnCbboPP5Q2OUNzwhdIVRIfce)oMmBqnyriSswPqyH47QyHaXFWHqTz2rseFc4doPfslcHvY(yHfIVRIfce)bHWeIXfKr8jGp4KwiTiewj7JkSq8DvSqG4pxen4qOw8jGp4KwiTiewj7dxyH47QyHaX3bkchiNBuoNl(eWhCslKwecRK9rewi(eWhCslKw8DvSqG4RKO4WabbRYm4ooeFfAdcTU4NtD4GCE0s6KZ51XsDJ(CMCnIaoFbKb1XTjnKvqDSu3OpNPgQbIKyGtdVRwTrJiVbN0qwb1XsDeGqzKKITHmb004wRUCRtkQJL6qXWm6ZjUUNR7XIpnNKkmaVHeFLefhgiiyvMb3XHiewjR1tyH4taFWjTqAX3vXcbIVlvCRJCSzcbHbon2qwjK4RqBqO1f)CQB0NZKRreW5lGmOoUn1TRJL6YPUrFotdURjZK3rijPUDDSuNcc5AiRGKRreW5lGmOoUnHOgFb46EUozFS4d8gs8DPIBDKJntiimWPXgYkHeHWkgEsyH4taFWjTqAX3vXcbIVJBZ6acBqUuHiJcICU4RqBqO1fFnn6Zzc5sfImkiY5gnn6ZzsdzfuNC51PPrFotkiq3vXMLmlGrJMg95m1TRJL6chLHIul58OnzRI6EUolLH6yPUWrzOi1sopAt2QOUCzwNL(uDYLxxo1PPrFotkiq3vXMLmlGrJMg95m1TRJL6EVonn6Zzc5sfImkiY5gnn6ZzchUIX6YLzDm8uDpOozFQUxRonn6ZzAWHqTbonrlzia1ij1TRtU86chLHIuSnKjGg9s19CDp6t19wDSu3OpNjxJiGZxazqDCBcrn(cW1LBDY(iIpWBiX3XTzDaHnixQqKrbroxecRyqwHfIpb8bN0cPfFfAdcTU4p6ZzAWHqnVJJeICvuNC51fBdzcOrVuDpZSogEQo5YRtbBgqJnCbboPP5Q2OUNzwhdIVRIfce)oMmBqnyricXF0xUwyHWkzfwi(eWhCslKw8vOni06I)OpNjOTnefDWgssD76yPU3RB0NZeJezBKa7idRBGn(a2dJeypHdxXyDpxNSsrDYLx3OpNjn5AClmsD76KlVocqOmsQ756KIhx3BIVRIfceF7fhqUb3cdriSIbHfIVRIfceF8cwCqidoqlJK4taFWjTqAricricriea]] )


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

end