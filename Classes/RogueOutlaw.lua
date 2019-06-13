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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 180 end,
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


    spec:RegisterPack( "Outlaw", 20190417.2246, [[dafjYaqiHGhjeTjIsFsksnkvIoLkHvHOGxHaZIOYTikSlj(fr0WiLYXuPAziONHOutJOixtkITrkv9nefzCikQZHOkwhPuzEiQCpeAFsrDqvk1crKEOkfAIQuYfjkQ2Okf5JQuq1jruLSssXlLIKMPkfuUjrrzNev9tPiXqruOJQsbXsruvpvvMkr4QQuGTQsbPVIOk1yvPO0zvPOQ9I0FL0GvCyQwSu9ybtMKlJAZQQplfgnP60kTAvkQ8AeXSjCBP0Ub(nOHluhxLIILd1ZHmDrxxfBxi9DsjJxi05jsRhrjZxL0(Pm9ovc6t5jtLNqTDN8Onz6ozQqiHYK2t2Kj6lLgZ0xShiXBW0hWBz6RPCsHRf9f7sfqxrLG(qWdoW0NEMXiTtsjBSP(PxcWwjrB7r45cbbS)tjrBBqs6RFwrsEbOD6t5jtLNqTDN8Onz6ozQqiHYK2t2Kn9HI5avEc1ETrF6RsXaAN(umkqFrAtt5KcxlBiFyJdBAI0g9mJrANKs2yt9tVeGTsI22JWZfccy)NsI22GKMMiT52X4vyZDYKC2qO2UtESrg2q4DTRjnX0yAI0MBu3bnyK2zAI0gzyZTvkwzttDdKytcTrXF)isB8qUqGnIfLfttK2idBKzWOSYMxYUi1TX)jJT52kmdCXcyBi)ds3MfytmMdW2UN24HCHaBelklMMiTrg2CBLIv2eJ5aST7PnKkCfBZnjoySuBUubzeOPtB6y2jXMxYUi1VOyAI0gzyZTGGMoT5GyBs8ciHtKnlWguYUi1lMMiTrg2CliOPtBoi2M2fOD3S28HyBKzoMewzZhIT5wSN62C5MnnYgamTbDIJH4KvxumnrAJmS52rHRYgmJHcXcAyd5NKAJ6GxqdBiv4k2MBsCWyP2C5biyeYgTyBGaHuB09OSn3TjDCdoVOyAI0gzyd5ZcpI20uxHybnS5fJzUqFXy4Ffm9fPnnLtkCTSH8HnoSPjsB0ZmgPDskzJn1p9sa2kjABpcpxiiG9FkjABdsAAI0MBhJxHn3jtYzdHA7o5XgzydH31UM0etJPjsBUrDh0GrANPjsBKHn3wPyLnn1nqInj0gf)9JiTXd5cb2iwuwmnrAJmSrMbJYkBEj7Iu3g)Nm2MBRWmWflGTH8piDBwGnXyoaB7EAJhYfcSrSOSyAI0gzyZTvkwztmMdW2UN2qQWvSn3K4GXsT5sfKrGMoTPJzNeBEj7Iu)IIPjsBKHn3ccA60MdITjXlGeor2SaBqj7IuVyAI0gzyZTGGMoT5GyBAxG2DZAZhITrM5ysyLnFi2MBXEQBZLB20iBaW0g0jogItwDrX0ePnYWMBhfUkBWmgkelOHnKFsQnQdEbnSHuHRyBUjXbJLAZLhGGriB0ITbcesTr3JY2C3M0Xn48IIPjsBKHnKpl8iAttDfIf0WMxmM5IPX0ePnY8iYHtYkB68hIzBcW2UN205glavS52HahNiBaqGm0DC7)iSXd5cbiBGaH0IPXd5cbOsmMdW2UNe)chrIPXd5cbOsmMdW2UNequs)0OLbPNleyA8qUqaQeJ5aST7jbeL8dHkttK28aEmshM2G9vzt)8)SYgu6jYMo)Hy2MaST7PnDUXcq24aLnXywgXWmxqdBwKnkiGlMgpKleGkXyoaB7EsarjrapgPdZkk9ezA8qUqaQeJ5aST7jbeLmgMleyA8qUqaQeJ5aST7jbeLS1XKWQ6hIRk2tD5IXCa229SI4aeOqeBIC7Ni2xvLJYGS4kfQSGMLjTzA8qUqaQeJ5aST7jbeL0vyg4IfWv8bPlxmMdW2UNvehGafI4DtJhYfcqLymhGTDpjGOKOKDrQBA8qUqaQeJ5aST7jbeLedfIAQZ1oeWi5IXCa229SI4aeOqej004HCHaujgZbyB3tcikjsSbU6avvTbwUymhGTDpRioabkercnnEixiavIXCa229KaIs2fUIRFXbJLk3(j2p)FbdfIAQZ1oeWOYjwwpKBuUYaUDzuZ3nnMMiTrMhroCswzdhLXsTj3w2MuNTXdjeBZISXJ6RW7cUyAI0gYNrj7Iu3M9BtmeH2UGT5sa0MOhbGXExW2WaUDzKnlWMaST75fMgpKleGiIs2fPUPXd5cbicikjjBGettK2q(mgke28HyBiKaB6N)hzJwBQBZnmORyLn3AdSnN4InnLuNXATi2gmJHcHnFi2gcjWgi2MB4yhOSrMXcMTbITH8pPUGriBiJyoSOfckMgpKleGiGOKrD86DblhWBzI4SxXmgkeYf1fhMio71(5)rKJqzVSF()Ia6kwvvBGlN4RxJq)8)LgyhOQTSG5Yjw2i0p)FbFsDbJq1ymhw0cbLt8fMMiTH8zmuiS5dX2qib20p)pYgi2gY)K6cgHSHmI5WIwiWgT2u3MBXUcPdtBGyBUDGT5eBJu4bBZtWCuUyA8qUqaIaIsg1XR3fSCaVLjIZEfZyOqihmMiIt52prNSy8MCrXUcPdZcd8UGvxV6KfJ3KlEGRN4Qu4bxrcMJYfg4DbRKlQlomrC2R9Z)JihHYEz)8)fb0vSQQ2axoXxV2p)FbFsDbJq1ymhw0cbfm36laroIbiuOGAbkDo1Izqn15klLrfm36laDHPjsBiKaBEaNe2gzUugPD2CBHwUuKnygdfcB(qSnesGn9Z)JkMgpKleGiGOKrD86DblhWBzI4SxXmgkeYbJjI4uU9t0jlgVjxqaNeUYszub7asAMiHYf1fhMio71(5)rKJqttK2qib28aojSnYCPms7S5wqBaW0gmJHcHnATPUnesGnO0dKGSb(Tj1zBEaNe2gzUugzt)8)2C5DcSbLEGeB0AtDBifdDfAvSnN4lkMgpKleGiGOKrD86DblhWBzI4SxXmgkeYbJjIzeNYTFIozX4n5cc4KWvwkJkyhqsZeju2(5)liGtcxzPmQGspqsZejug9Z)x6yORqRIlNytJhYfcqequYOoE9UGLd4TmrVTFq61aeO2CHa5I6IdtmaB7WAmCbjQO4)g2SzIesaHKHltxWGS0qhIsH0kkXljCHbExWkzdqOqb1cuAOdrPqAfL4LeUG5wFbiYD)cc6N)V0XqxHwfxoXYYag3qAZAV2Knc9Z)xqKCeIQdu1agIqDiGrLtSPjsBiV3u3M2Ji3ybBt64gCIKZMuFr2e1XR3fSnlYMGohiHv2KqBuCyvSnAPZPoJTbbBzBUXBHSbPdpcLnD2gKuqGv2O1M62qQWvSn3K4GXsnnEixiararjJ6417cwoG3Ye7cxX1V4GXsRiPGGCrDXHjIIzHOMoUbNOsx4kU(fhmwk5iuwSVQkhLbzXvkuzbntO2UETF()sx4kU(fhmwA5eBA8qUqaIaIsgCHO6HCHGQyrPCaVLjIs2fPUC7NikzxK6SQ4cHPXd5cbicikzWfIQhYfcQIfLYb8wMyqHmnrAZnTGfPBJN206rCBpT2CJKXInVthLypK2abSnFi2g2d62qkg6k0QyBCGYMMsCmeNhWMsTrlDgyZnKZgiXMBHDTSzr2GybhswzJdu2iZ(3YMfzdaM2Gzxj1g)Nm2MuNTbWrmTbXbiqvmnEixiararjXhq1d5cbvXIs5aElt8VGfPl3(jgGTDyngUGe1mXqCT1JyffZaLmUSF()shdDfAvC5etq)8)fyCmeNhWMslN4lidxMUGbz5M5SbsQkSRvHbExWkzVmcPlyqwADmjSQ(H4QI9uVWaVly11RbiuOGAbkToMewv)qCvXEQxWCRVauZ3V4ctJhYfcqequYGlevpKleuflkLd4TmX(zfktJhYfcqequshhCaxtigZGuU9tKbmUH0II)ByZMjEVjeWag3qAbZnyGPXd5cbicikPJdoGRXhbInnEixiararjfBd9evV5oQgTminnMMiTH0ZkumgzAI0MBaITHmUOekS5PdtB2VnBAJwqqtN2e8yBcW2o0My4csKnoqztQZ20uIJH48a2uQn9Z)BZIS5exS52rHRYMdAbnSrlDgyttL5yBU5HhSnK3BISbLEGeKnoMTrFBOBZbiyeYMuNT5wSRq6W0M(5)Tzr24ce0MtCX04HCHauPFwHIy8IsOOI0HPC7Ny)8)fyCmeNhWMslNyzVSF()cjmhxLcp4QwBIQEhEYQu4PGspqc5iSjxV2p)FrXUcPdZYj(6vgW4gsjNm1KlmnEixiav6NvOiGOKOfSOKXvuIxsytJPjsBUriuOGAbqMgpKleGkbfIymmxiqU9tSF()sxaHkXbLfm7H861(5)lUcZaxSaUIpi9Yj20ePn3KlelOHnDpqInj0gf)9JiTztU1MdYBWMgpKleGkbfIaIsEqCDtUvoG3YeJ6417cUUGKbOnLwBSn8OqrwHOWkeEUGgvm7HeILB)e7N)V0fqOsCqzbZEiVEn3wUMWQAzYrKqTD9Aa22H1y4csurX)nSj5isOPXd5cbOsqHiGOKhex3KBrYTFIraLSlsDwvCHq2l7N)V0fqOsCqzbZEiVEnaB7WAmCbjQO4)g2KCej8ctJhYfcqLGcrarj7ciuv)hSutJhYfcqLGcrarj7mgXyswqdtJhYfcqLGcrarj)lM7ciuzA8qUqaQeuicikPdcmkXUOgCHW04HCHaujOqequsxHzGlwaxXhKUC7Nye6N)V4kmdCXc4k(G0lNyzzaJBiTKBlxtyT1JyZ3nnrAd513gxPq24y2MtSC2GaBmBtQZ2abSnATPUncOwmkTrcjUvXMBaITrlDgyJs6cAyZ3rjJTj1DGn3iz0gf)3WM2aX2O1M6WtAJdKAZnsglMgpKleGkbfIaIs26ysyv9dXvf7PUC7Ni2xvLJYGS4kfQCIL9Y0Xn4SKBlxtyvTm5cW2oSgdxqIkk(VHnVEncOKDrQZQcg24WYgGTDyngUGevu8FdB2mXqCT1JyffZaLmUFHPjsBiV(2aG24kfYgTwHWg1Y2O1M6lWMuNTbWrmTHS1gsoBoi2gz2)w2ab20HiKnATPo8K24aP2CJKXIPXd5cbOsqHiGOKToMewv)qCvXEQl3(jI9vv5OmilUsHklOzYwBYa7RQYrzqwCLcvuhSNleiBeqj7IuNvfmSXHLnaB7WAmCbjQO4)g2SzIH4ARhXkkMbkzC30ePnKkCfBZnjoySuBGaBiKaBya3UmQyd59M624kfs7S5gGyB2VnPol1gu6sT5dX2qMjWgehGafYgi2M9BJu4bBdGJyAtq3XnyB0AfcB6Sny2vsTzb2KBlBZhITj1zBaCetB0YJYftJhYfcqLGcrarj7cxX1V4GXsLB)erXSquth3GtuZeju2i0p)FPlCfx)IdglTCIL9Y(5)lyOqutDU2HagvoXxV2p)Fbj2axDGQQ2axoXxi7Lra7RQYrzqwCLcv4iUOeD9k2xvLJYGS4kfQG5wFbOMjZxVI9vv5OmilUsHklO5ljugbiuOGAbkDHR46xCWyPLGUJBWO6h7HCHaxCbzGWMCHPXd5cbOsqHiGOKn0HOuiTIs8scl3(jg1XR3fCPlCfx)IdglTIKccYgGTDyngUGevu8FdB2mX7e0p)FPJHUcTkUCInnEixiavckebeLKKviwqJkkgZSC7NyuhVExWLUWvC9loyS0kskii7LmGXnKwYTLRjS26rSzcVELbmUHuY1eTDHPXd5cbOsqHiGOKDHR4k(G0LB)eJ6417cU0fUIRFXbJLwrsbbzzaJBiTKBlxtyT1JyZ3nnrAZnaTGg2Cd1blsxYB32piDBwKnqGqQnUnrzSuBYfi1MfeWSJy5SbbTzb2GzxSPu5Srk800y2gVJGItYcP28xaBtcT5GyB20ghzJBZjxXMsTbfZcrX04HCHaujOqequYOoyr6YTFIraLSlsDwvCHq2OoE9UGlEB)G0RbiqT5cbMgpKleGkbfIaIsI0DfuRwwOKB)eJakzxK6SQ4cHSrD86Dbx82(bPxdqGAZfcmnMMiT5MwWI0zmY0ePnKMYCBGrzSnKFsQnygdfcKnATPUn3IDfshMsE7aBtI9nr2aX2q(NuxWiKnKrmhw0cbftJhYfcqL)cwKoXoNAXmOM6CLLYi52pX(5)l4tQlyeQgJ5WIwiOCIVE9sNSy8MCrXUcPdZcd8UGvxV6KfJ3KlEGRN4Qu4bxrcMJYfg4DbRUq2(5)lyOqutDU2HagvoXMgpKleGk)fSiDcikjsSbU6avvTbwU9tSF()csSbU6avvTbUG5wFbiYLoUbNLCB5AcRQLLTF()csSbU6avvTbUG5wFbiYD5DccW2oSgdxqIUGmCVqMnnEixiav(lyr6equsmuiQPox7qaJKB)e7N)VGHcrn15AhcyubZT(cqKJizBA8qUqaQ8xWI0jGOKyOqutDU2Hagj3(jEPhYnkxza3UmI49Rx7N)V0fUIRFXbJLwuqTaxiBuhVExWfC2RygdfcttK2qAkZTrRn1Tj1zBUDGT5geBZnp8GT5jyokBdeBZTyxH0HPnj23evmnEixiav(lyr6equYoNAXmOM6CLLYi52prNSy8MCXdC9exLcp4ksWCuUWaVly11RozX4n5IIDfshMfg4DbRmnEixiav(lyr6equs1II9mOBAmnrAZlzxK6MgpKleGkOKDrQt0B7hKo9fLXOfcOYtO2UtE0gzFx7l3j77Ye9PLJblObI(iVAJH4Kv2O924HCHaBelkrftd95NuhIPV32EJ0NyrjIkb9P4VFejvcQ83PsqFEixiG(qj7IuN(yG3fSIsknPYtivc6Zd5cb0hjBGe6JbExWkkP0KkpztLG(yG3fSIsk9f1fhM(WzV2p)pYgYzdH2iRnxAt)8)fb0vSQQ2axoX2C9QnrWM(5)lnWoqvBzbZLtSnYAteSPF()c(K6cgHQXyoSOfckNyBUG(8qUqa9f1XR3fm9f1XvG3Y0ho7vmJHcbnPYltujOpg4DbROKsFWy6dXj95HCHa6lQJxVly6lQlom9HZETF(FKnKZgcTrwBU0M(5)lcORyvvTbUCIT56vB6N)VGpPUGrOAmMdlAHGcMB9fGSHCeTjaHcfulqPZPwmdQPoxzPmQG5wFbiBUG(c4nz860NtwmEtUOyxH0HzHbExWkBUE1gNSy8MCXdC9exLcp4ksWCuUWaVlyf9f1XvG3Y0ho7vmJHcbnPY3eQe0hd8UGvusPpym9H4K(8qUqa9f1XR3fm9f1fhM(WzV2p)pYgYzdH0xaVjJxN(CYIXBYfeWjHRSugvWoGeBAMOnesFrDCf4Tm9HZEfZyOqqtQ8Apvc6JbExWkkP0hmM(WmIt6Zd5cb0xuhVExW0xuhxbEltF4SxXmgke0xaVjJxN(CYIXBYfeWjHRSugvWoGeBAMOneAJS20p)FbbCs4klLrfu6bsSPzI2qOnYWM(5)lDm0vOvXLtmnPYtMOsqFmW7cwrjL(I6IdtFbyBhwJHlirff)3WM20mrBi0gcSHqBid2CPnPlyqwAOdrPqAfL4LeUWaVlyLnYAtacfkOwGsdDikfsROeVKWfm36lazd5S5Unxydb20p)FPJHUcTkUCITrwByaJBi1MMTr71MnYAteSPF()cIKJquDGQgWqeQdbmQCIPppKleqFrD86DbtFrDCf4Tm95T9dsVgGa1MleqtQ8KzQe0hd8UGvusPVOU4W0hkMfIA64gCIkDHR46xCWyP2qoBi0gzTb7RQYrzqwCLcvwGnnBdHAZMRxTPF()sx4kU(fhmwA5etFEixiG(I6417cM(I64kWBz6RlCfx)IdglTIKcc0Kkp5Hkb9XaVlyfLu6lG3KXRtFOKDrQZQIle0NhYfcOVGlevpKleuflkPpXIYkWBz6dLSlsDAsL)U2OsqFmW7cwrjL(8qUqa9fCHO6HCHGQyrj9jwuwbEltFbfIMu5VFNkb9XaVlyfLu6lG3KXRtFbyBhwJHlir20mrBcX1wpIvumdu2idBU0M(5)lDm0vOvXLtSneyt)8)fyCmeNhWMslNyBUWgYGnxAt6cgKLBMZgiPQWUwfg4DbRSrwBU0Miyt6cgKLwhtcRQFiUQyp1lmW7cwzZ1R2eGqHcQfO06ysyv9dXvf7PEbZT(cq20Sn3T5cBUG(8qUqa9HpGQhYfcQIfL0Nyrzf4Tm99xWI0Pjv(7esLG(yG3fSIsk95HCHa6l4cr1d5cbvXIs6tSOSc8wM(6NvOOjv(7Knvc6JbExWkkP0xaVjJxN(yaJBiTO4)g20MMjAZ9Mydb2Wag3qAbZnya95HCHa6ZXbhW1eIXmiPjv(7Yevc6Zd5cb0NJdoGRXhbIPpg4DbROKstQ83Bcvc6Zd5cb0NyBONO6n3r1OLbj9XaVlyfLuAst6lgZbyB3tQeu5VtLG(yG3fSIsknPYtivc6JbExWkkP0KkpztLG(yG3fSIsknPYltujOpg4DbROKstQ8nHkb95HCHa6lgMleqFmW7cwrjLMu51EQe0hd8UGvusPppKleqFToMewv)qCvXEQtFb8MmED6d7RQYrzqwCLcvwGnnBJmPn6lgZbyB3ZkIdqGcrFnHMu5jtujOpg4DbROKsFEixiG(CfMbUybCfFq60xmMdW2UNvehGafI(UttQ8KzQe0NhYfcOpuYUi1Ppg4DbROKstQ8KhQe0hd8UGvusPppKleqFyOqutDU2HagrFXyoaB7EwrCacui6JqAsL)U2OsqFmW7cwrjL(8qUqa9HeBGRoqvvBGPVymhGTDpRioabke9rinPYF)ovc6JbExWkkP0xaVjJxN(6N)VGHcrn15Ahcyu5eBJS24HCJYvgWTlJSPzBUtFEixiG(6cxX1V4GXsPjnPV)cwKovcQ83PsqFmW7cwrjL(c4nz860x)8)f8j1fmcvJXCyrleuoX2C9QnxAJtwmEtUOyxH0HzHbExWkBUE1gNSy8MCXdC9exLcp4ksWCuUWaVlyLnxyJS20p)FbdfIAQZ1oeWOYjM(8qUqa915ulMb1uNRSugrtQ8esLG(yG3fSIsk9fWBY41PV(5)liXg4Qduv1g4cMB9fGSHC2KoUbNLCB5AcRQLTrwB6N)VGeBGRoqvvBGlyU1xaYgYzZL2C3gcSjaB7WAmCbjYMlSHmyZ9czM(8qUqa9HeBGRoqvvBGPjvEYMkb9XaVlyfLu6lG3KXRtF9Z)xWqHOM6CTdbmQG5wFbiBihrBiB6Zd5cb0hgke1uNRDiGr0KkVmrLG(yG3fSIsk9fWBY41PVlTXd5gLRmGBxgzdrBUBZ1R20p)FPlCfx)IdglTOGAbS5cBK1MOoE9UGl4SxXmgke0NhYfcOpmuiQPox7qaJOjv(MqLG(yG3fSIsk9fWBY41PpNSy8MCXdC9exLcp4ksWCuUWaVlyLnxVAJtwmEtUOyxH0HzHbExWk6Zd5cb0xNtTygutDUYszenPYR9ujOppKleqFQff7zqN(yG3fSIsknPj9Hs2fPovcQ83PsqFEixiG(82(bPtFmW7cwrjLM0K(ckevcQ83PsqFmW7cwrjL(c4nz860x)8)LUacvIdkly2dPnxVAt)8)fxHzGlwaxXhKE5etFEixiG(IH5cb0KkpHujOpg4DbROKsFEixiG(I6417cUUGKbOnLwBSn8OqrwHOWkeEUGgvm7HeIPVaEtgVo91p)FPlGqL4GYcM9qAZ1R2KBlxtyvTSnKJOneQnBUE1MaSTdRXWfKOII)BytBihrBiK(aEltFrD86DbxxqYa0MsRn2gEuOiRquyfcpxqJkM9qcX0KkpztLG(yG3fSIsk9fWBY41PViydkzxK6SQ4cHnYAZL20p)FPlGqL4GYcM9qAZ1R2eGTDyngUGevu8FdBAd5iAdH2Cb95HCHa67G46MClIMu5LjQe0NhYfcOVUacv1)blL(yG3fSIsknPY3eQe0NhYfcOVoJrmMKf0G(yG3fSIsknPYR9ujOppKleqF)fZDbeQOpg4DbROKstQ8KjQe0NhYfcOpheyuIDrn4cb9XaVlyfLuAsLNmtLG(yG3fSIsk9fWBY41PViyt)8)fxHzGlwaxXhKE5eBJS2Wag3qAj3wUMWARhrBA2M70NhYfcOpxHzGlwaxXhKonPYtEOsqFmW7cwrjL(c4nz860h2xvLJYGS4kfQCITrwBU0M0Xn4SKBlxtyvTSnKZMaSTdRXWfKOII)BytBUE1MiydkzxK6SQGHnoSnYAta22H1y4csurX)nSPnnt0MqCT1JyffZaLnYWM72Cb95HCHa6R1XKWQ6hIRk2tDAsL)U2OsqFmW7cwrjL(c4nz860h2xvLJYGS4kfQSaBA2gYwB2idBW(QQCugKfxPqf1b75cb2iRnrWguYUi1zvbdBCyBK1MaSTdRXWfKOII)BytBAMOnH4ARhXkkMbkBKHn3PppKleqFToMewv)qCvXEQttQ83VtLG(yG3fSIsk9fWBY41Ppumle10Xn4eztZeTHqBK1Miyt)8)LUWvC9loyS0Yj2gzT5sB6N)VGHcrn15Ahcyu5eBZ1R20p)Fbj2axDGQQ2axoX2CHnYAZL2ebBW(QQCugKfxPqfoIlkr2C9QnyFvvokdYIRuOcMB9fGSPzBiZ2C9QnyFvvokdYIRuOYcSPzBU0gcTrg2eGqHcQfO0fUIRFXbJLwc6oUbJQFShYfcCHnxydzWgcBInxqFEixiG(6cxX1V4GXsPjv(7esLG(yG3fSIsk9fWBY41PVOoE9UGlDHR46xCWyPvKuqWgzTjaB7WAmCbjQO4)g20MMjAZDBiWM(5)lDm0vOvXLtm95HCHa6RHoeLcPvuIxsyAsL)oztLG(yG3fSIsk9fWBY41PVOoE9UGlDHR46xCWyPvKuqWgzT5sByaJBiTKBlxtyT1JOnnBdH2C9QnmGXnKAd5SPjAZMlOppKleqFKScXcAurXyMPjv(7Yevc6JbExWkkP0xaVjJxN(I6417cU0fUIRFXbJLwrsbbBK1ggW4gsl52Y1ewB9iAtZ2CN(8qUqa91fUIR4dsNMu5V3eQe0hd8UGvusPVaEtgVo9fbBqj7IuNvfxiSrwBI6417cU4T9dsVgGa1MleqFEixiG(I6GfPttQ831EQe0hd8UGvusPVaEtgVo9fbBqj7IuNvfxiSrwBI6417cU4T9dsVgGa1MleqFEixiG(q6UcQvllu0KM0x)ScfvcQ83PsqFmW7cwrjL(c4nz860x)8)fyCmeNhWMslNyBK1MlTPF()cjmhxLcp4QwBIQEhEYQu4PGspqInKZgcBInxVAt)8)ff7kKomlNyBUE1ggW4gsTHC2itnXMlOppKleqFXlkHIkshM0KkpHujOppKleqFOfSOKXvuIxsy6JbExWkkP0KM0KM0Ksb]] )


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