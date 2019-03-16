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
            cooldown = 180,
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
                applyBuff( 'feint', 5)
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

            usable = function () return boss end,
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

        usable = function () return boss and race.night_elf end,
        handler = function ()
            applyBuff( "shadowmeld" )
        end,
    } )


    spec:RegisterPref( {
        key = "no_ooc_reroll",
        name = "Don't Reroll the Bones Out of Combat",
        description = "If any Roll the Bones buff is applied, do not reroll out of combat until it expires.",
        type = "toggle",
        default = false,
        order = 1,
    } )


    spec:RegisterPack( "Outlaw", 20190316.1314, [[daLbYaqiHGhjeTjIsFsLOmkPsDkvcRcrsEfcmlIk3IiYUK4xeHHru0XuPAzikptLctJuKUMkLSnIc9nsrKXPsKohPO06ifvZJiQ7Hq7tQKdsuWcrepuLOAIQuQlskcBuLI6JisqDsejQvsk9svIWmrKGCtvkYojQ6NKIIHIiPokIeWsrKQNQktfr1vvjI2kIeOVskIASisKolIeQ9I0FL0GvCyQwSuESGjtYLrTzv1NLkgnP60kTAejIxJGMnHBlvTBGFdA4c1XrKqwouphY0fDDvSDH03jfgVqOZtKwpIuMVkP9tz6Dk50NYtMkpzY8UMvM34UmwUFJ736gAk9LsJz6l2de6Dy6d49m9PzoPW1G(IDPcOROKtFi4bhy6tpZyKMlHeD2u)0kbyVeOT)i8CHGa2)PeOTpib91oRijLb0g9P8KPYtMmVRzL5nUlJL734UMQPKrFOyoqLNmzuM0N(QumG2OpfJc0xK2OzoPW1Wgsh25WM2iTrpZyKMlHeD2u)0kbyVeOT)i8CHGa2)PeOTpiHPnsBUjhh0T5UmkNnKjZ7xQnsYM73qZVRPMwtBK2C56oOdJ0CtBK2ijBKbLIv2Cj2aH2KqBu83pI0gpKleyJyrzX0gPnsYMBcgLv28s2fPUn(pzSnYGcZaxSa2gs)G0Tzb2eJ5aSV5PnEixiWgXIYIPnsBKKnYGsXkBIXCa2380gseUIT5MfhmwQnDRGmcCzPnnm7eAZlzxK6xumTrAJKS52qWLL2CqSnjEbeYjYMfydkzxK6ftBK2ijBUneCzPnheBt)c0CsP28HyBUjhtiRS5dX2CB2tDB6EZldzdaM2GoXXqCYQlkM2iTrs2idrHRYgmJHcXc6ydPNKyJ6GxqhBir4k2MBwCWyP209biyeYgnyBGaHuB09OSn3TjDChoVOyAJ0gjzdPZcpI2CjwHybDS5fJzUqFXy4Ffm9fPnAMtkCnSH0HDoSPnsB0ZmgP5sirNn1pTsa2lbA7pcpxiiG9FkbA7dsyAJ0MBYXbDBUlJYzdzY8(LAJKS5(n087AQP10gPnxUUd6Win30gPnsYgzqPyLnxInqOnj0gf)9JiTXd5cb2iwuwmTrAJKS5MGrzLnVKDrQBJ)tgBJmOWmWflGTH0piDBwGnXyoa7BEAJhYfcSrSOSyAJ0gjzJmOuSYMymhG9npTHeHRyBUzXbJLAt3kiJaxwAtdZoH28s2fP(fftBK2ijBUneCzPnheBtIxaHCISzb2Gs2fPEX0gPnsYMBdbxwAZbX20VanNuQnFi2MBYXeYkB(qSn3M9u3MU38Yq2aGPnOtCmeNS6IIPnsBKKnYqu4QSbZyOqSGo2q6jj2Oo4f0XgseUIT5MfhmwQnDFacgHSrd2giqi1gDpkBZDBsh3HZlkM2iTrs2q6SWJOnxIviwqhBEXyMlMwtBK2OjIihojRSPXFiMTja7BEAtJ7SauXgzie44ezdacKKUJ7)hHnEixiazdeiKwmTEixiavIXCa238K4x4icnTEixiavIXCa238KaIs4No9mi9CHatRhYfcqLymhG9npjGOeFiuzAJ0MhWJr6W0gSVkBAN)Nv2Gspr204peZ2eG9npTPXDwaYghOSjgZskgM5c6yZISrbbCX06HCHaujgZbyFZtcikbc4XiDywrPNitRhYfcqLymhG9npjGOeXWCHatRhYfcqLymhG9npjGOe9oMqwv)qCvXEQlxmMdW(MNvehGafI4TKB)eX(QQCugKfxPqLf0LMkttRhYfcqLymhG9npjGOeUcZaxSaUIpiD5IXCa238SI4aeOqeVBA9qUqaQeJ5aSV5jbeLaLSlsDtRhYfcqLymhG9npjGOeyOqutDU2GagjxmMdW(MNvehGafIizMwpKleGkXyoa7BEsarjqInWvhOQQnWYfJ5aSV5zfXbiqHisMP1d5cbOsmMdW(MNequIMWvC9loySu52pX25)lyOqutDU2GagvoXY6HCJYvgW9lJ66UP10gPnAIiYHtYkB4OmwQn52Z2K6SnEiHyBwKnEuFfEtWftBK2q6mkzxK62SFBIHi02eSnDdG2e9iam2Bc2ggW9lJSzb2eG9npVW06HCHaeruYUi1nTEixiararjiCdeAAJ0gsNXqHWMpeBdzeyt78)iB0ytDBifc6kwzZT3aBZjUyJMj1zSglITbZyOqyZhITHmcSbITHuySdu2CtSGzBGyBi9tQlyeYgsnMdlAHGIP1d5cbicikruhVEtWYb8EMioBvmJHcHCrDXHjIZwTD(FKKjt2UBN)ViGUIvv1g4Yj(61i0o)FPd2bQAplyUCILncTZ)xWNuxWiungZHfTqq5eFHPnsBiDgdfcB(qSnKrGnTZ)JSbITH0pPUGriBi1yoSOfcSrJn1T52SRq6W0gi2gziW2CITrk8GT5jyokxmTEixiararjI641BcwoG3ZeXzRIzmuiKdgteXPC7NOtAmEtUOyxH0HzHbEtWQRxDsJXBYfpW1tCvk8GRibZr5cd8MGvYf1fhMioB125)rsMmz7UD()Ia6kwvvBGlN4RxBN)VGpPUGrOAmMdlAHGcM79fGKmXaekuqnaLgNAWmOM6CLLYOcM79fGUW0gPnKrGnpGtiBJMqkJ0CBKbHgUuKnygdfcB(qSnKrGnTZ)JkMwpKleGiGOerD86nblhW7zI4SvXmgkeYbJjI4uU9t0jngVjxqaNqUYszub7ac7IizYf1fhMioB125)rsMmtBK2qgb28aoHSnAcPmsZT52qBaW0gmJHcHnASPUnKrGnO0deISb(Tj1zBEaNq2gnHugzt78)209DcSbLEGqB0ytDBibdDfAvSnN4lkMwpKleGiGOerD86nblhW7zI4SvXmgkeYbJjIzeNYTFIoPX4n5cc4eYvwkJkyhqyxejt225)liGtixzPmQGspqyxejtsTZ)xAyORqRIlNytRhYfcqequIOoE9MGLd49mrVVDq61aeO2CHa5I6Idtma7BWAmCbjQO4)g2SlIKrazKQUtxWGS0rhIsH0kkXlHCHbEtWkzdqOqb1au6OdrPqAfL4LqUG5EFbijF)ccAN)V0WqxHwfxoXYYag3rAxYOmLncTZ)xqeEeIQdu1agIqniGrLtSPnsB0K3u3M(Ji3ybBt64oCIKZMuFr2e1XR3eSnlYMGohiKv2KqBuCyvSnAOZPoJTbb7zBU8BJSbPdpcLnn2gKuqGv2OXM62qIWvSn3S4GXsnTEixiararjI641BcwoG3ZeBcxX1V4GXsRiPGGCrDXHjIIzHOMoUdNOst4kU(fhmwQKjtwSVQkhLbzXvkuzbDrMmVETD()st4kU(fhmwA5eBA9qUqaIaIseCHO6HCHGQyrPCaVNjIs2fPUC7NikzxK6SQ4cHP1d5cbicikrWfIQhYfcQIfLYb8EMyqHmTrAZnVGfPBJN207rC7p92C5K6InVtdLypK2abSnFi2g2d62qcg6k0QyBCGYgntCmeNhWMsTrdDgydPaNnqOn3g7AyZISbXcoKSYghOS5M(32MfzdaM2Gzxj1g)Nm2MuNTbWrmTbXbiqvmTEixiararjWhq1d5cbvXIs5aEpt8VGfPl3(jgG9nyngUGe1fXqCT3JyffZaLK6UD()sddDfAvC5etq78)fyCmeNhWMslN4livDNUGbzHu0zdewvyxJcd8MGvY2DesxWGS07yczv9dXvf7PEHbEtWQRxdqOqb1au6DmHSQ(H4QI9uVG5EFbOUUFXfMwpKleGiGOebxiQEixiOkwukhW7zITZkuMwpKleGiGOeoo4aUMqmMbPC7NidyChPff)3WMDr8(TiGbmUJ0cM7WatRhYfcqequchhCaxJpceBA9qUqaIaIsi2o6jQsk5O60ZG00AAJ0gsoRqXyKPnsBUKi2gs9IsOWMNomTz)2SPnAabxwAtWJTja7BqBIHlir24aLnPoBJMjogIZdytP20o)VnlYMtCXgzikCv2CqlOJnAOZaBUemhBdPy4bBJM8MiBqPhiezJJzB03o62CacgHSj1zBUn7kKomTPD(FBwKnUabT5exmTEixiavANvOigVOekQiDyk3(j2o)FbghdX5bSP0Yjw2UBN)VqiZXvPWdUQXMOQ3GNSkfEkO0dekzYU11RTZ)xuSRq6WSCIVW06HCHauPDwHIaIsGwWIsgxrjEjKnTM2iT5YHqHcQbazA9qUqaQeuiIXWCHa52pX25)lnbeQehuwWShYRxBN)V4kmdCXc4k(G0lNytBK2CZUqSGo208aH2KqBu83pI0Mn5EBoiVdBA9qUqaQeuicikXbX1n5E5aEptmQJxVj46csgG2uATZ2XJcfzfIcRq45c6uXShsiwU9tSD()staHkXbLfm7H861C75AcRQLLmrYK51RbyFdwJHlirff)3WMsMizMwpKleGkbfIaIsCqCDtUhj3(jgbuYUi1zvXfcz7UD()staHkXbLfm7H861aSVbRXWfKOII)BytjtKSlmTEixiavckebeLOjGqv9FWsnTEixiavckebeLOXyeJjCbDmTEixiavckebeL4VyUjGqLP1d5cbOsqHiGOeoiWOe7IAWfctRhYfcqLGcrarjCfMbUybCfFq6YTFIrOD()IRWmWflGR4dsVCILLbmUJ0sU9CnH1EpIDD30gPnKYFBCLczJJzBoXYzdcSXSnPoBdeW2OXM62iGAWO0gYj)2fBUKi2gn0zGnkPlOJnFhLm2Mu3b2C5KABu8FdBAdeBJgBQdpPnoqQnxoPUyA9qUqaQeuicikrVJjKv1pexvSN6YTFIyFvvokdYIRuOYjw2Uth3HZsU9CnHv1Ysoa7BWAmCbjQO4)g2861iGs2fPoRkyyNdlBa23G1y4csurX)nSzxedX1EpIvumdus6(fM2iTHu(BdaAJRuiB0yfcBulBJgBQVaBsD2gahX0MBitKC2CqSn30)22ab20GiKnASPo8K24aP2C5K6IP1d5cbOsqHiGOe9oMqwv)qCvXEQl3(jI9vv5OmilUsHklORBitjH9vv5OmilUsHkQd2ZfcKncOKDrQZQcg25WYgG9nyngUGevu8FdB2fXqCT3JyffZaLKUBAJ0gseUIT5MfhmwQnqGnKrGnmG7xgvSrtEtDBCLcP52CjrSn73MuNLAdkDP28HyBUucSbXbiqHSbITz)2ifEW2a4iM2e0DCh2gnwHWMgBdMDLuBwGn52Z28HyBsD2gahX0gn8OCX06HCHaujOqequIMWvC9loySu52prumle10XD4e1frYKncTZ)xAcxX1V4GXslNyz7UD()cgke1uNRniGrLt81RTZ)xqInWvhOQQnWLt8fY2DeW(QQCugKfxPqfoIlkrxVI9vv5OmilUsHkyU3xaQRl96vSVQkhLbzXvkuzbD1nzskaHcfudqPjCfx)IdglTe0DChgv)ypKle4IlivKDRlmTEixiavckebeLOJoeLcPvuIxcz52pXOoE9MGlnHR46xCWyPvKuqq2aSVbRXWfKOII)ByZUiENG25)lnm0vOvXLtSP1d5cbOsqHiGOeeUcXc6urXyMLB)eJ641BcU0eUIRFXbJLwrsbbz7MbmUJ0sU9CnH1EpIDr21RmGXDKk5BjZlmTEixiavckebeLOjCfxXhKUC7NyuhVEtWLMWvC9loyS0kskiildyChPLC75AcR9Ee76UPnsBUKOf0XgsbDWI0Lqg6BhKUnlYgiqi1g3MOmwQn5cKAZccy2rSC2GG2SaBWSl2uQC2ifEUmmBJ3qqXjzHuB(lGTjH2CqSnBAJJSXT5KRytP2GIzHOyA9qUqaQeuicikruhSiD52pXiGs2fPoRkUqiBuhVEtWfVVDq61aeO2CHatRhYfcqLGcrarjq6UcQrpluYTFIraLSlsDwvCHq2OoE9MGlEF7G0RbiqT5cbMwtBK2CZlyr6mgzAJ0gssnHnWOm2gspjXgmJHcbYgn2u3MBZUcPdtjKHaBtI9nr2aX2q6NuxWiKnKAmhw0cbftRhYfcqL)cwKoXgNAWmOM6CLLYi52pX25)l4tQlyeQgJ5WIwiOCIVETBN0y8MCrXUcPdZcd8MGvxV6KgJ3KlEGRN4Qu4bxrcMJYfg4nbRUq225)lyOqutDU2GagvoXMwpKleGk)fSiDcikbsSbU6avvTbwU9tSD()csSbU6avvTbUG5EFbijNoUdNLC75AcRQLLTD()csSbU6avvTbUG5EFbij39DccW(gSgdxqIUGuDVCPMwpKleGk)fSiDcikbgke1uNRniGrYTFITZ)xWqHOM6CTbbmQG5EFbijt8gMwpKleGk)fSiDcikbgke1uNRniGrYTFID7HCJYvgW9lJiE)6125)lnHR46xCWyPffudWfYg1XR3eCbNTkMXqHW0gPnKKAcB0ytDBsD2gziW2CjJTHum8GT5jyokBdeBZTzxH0HPnj23evmTEixiav(lyr6equIgNAWmOM6CLLYi52prN0y8MCXdC9exLcp4ksWCuUWaVjy11RoPX4n5IIDfshMfg4nbRmTEixiav(lyr6equc1II9mOBAnTrAZlzxK6MwpKleGkOKDrQt07BhKo9fLXOfcOYtMmVRzL5nUlZImL5TKr6tdhdwqhe9rk3hdXjRSrgTXd5cb2iwuIkMw6ZpPoetFVT)YPpXIseLC6tXF)isk5u5VtjN(8qUqa9Hs2fPo9XaVjyfLeAsLNmk50NhYfcOpc3aH0hd8MGvusOjv(BqjN(yG3eSIsc9f1fhM(WzR2o)pYgjBdz2iRnDBt78)fb0vSQQ2axoX2C9QnrWM25)lDWoqv7zbZLtSnYAteSPD()c(K6cgHQXyoSOfckNyBUG(8qUqa9f1XR3em9f1XvG3Z0hoBvmJHcbnPYRPuYPpg4nbROKqFWy6dXj95HCHa6lQJxVjy6lQlom9HZwTD(FKns2gYSrwB62M25)lcORyvvTbUCIT56vBAN)VGpPUGrOAmMdlAHGcM79fGSrYeTjaHcfudqPXPgmdQPoxzPmQG5EFbiBUG(c4nz860NtAmEtUOyxH0HzHbEtWkBUE1gN0y8MCXdC9exLcp4ksWCuUWaVjyf9f1XvG3Z0hoBvmJHcbnPYFlk50hd8MGvusOpym9H4K(8qUqa9f1XR3em9f1fhM(WzR2o)pYgjBdz0xaVjJxN(CsJXBYfeWjKRSugvWoGqB6IOnKrFrDCf49m9HZwfZyOqqtQ8YiLC6JbEtWkkj0hmM(WmIt6Zd5cb0xuhVEtW0xuhxbEptF4SvXmgke0xaVjJxN(CsJXBYfeWjKRSugvWoGqB6IOnKzJS20o)FbbCc5klLrfu6bcTPlI2qMnsYM25)lnm0vOvXLtmnPYRjrjN(yG3eSIsc9f1fhM(cW(gSgdxqIkk(VHnTPlI2qMneydz2qQSPBBsxWGS0rhIsH0kkXlHCHbEtWkBK1MaekuqnaLo6qukKwrjEjKlyU3xaYgjBZDBUWgcSPD()sddDfAvC5eBJS2Wag3rQnDzJmktBK1Miyt78)feHhHO6avnGHiudcyu5etFEixiG(I641BcM(I64kW7z6Z7BhKEnabQnxiGMu5Vuk50hd8MGvusOVOU4W0hkMfIA64oCIknHR46xCWyP2izBiZgzTb7RQYrzqwCLcvwGnDzdzY0MRxTPD()st4kU(fhmwA5etFEixiG(I641BcM(I64kW7z6RjCfx)IdglTIKcc0KkVMLso9XaVjyfLe6lG3KXRtFOKDrQZQIle0NhYfcOVGlevpKleuflkPpXIYkW7z6dLSlsDAsL)UmPKtFmWBcwrjH(8qUqa9fCHO6HCHGQyrj9jwuwbEptFbfIMu5VFNso9XaVjyfLe6lG3KXRtFbyFdwJHlir20frBcX1EpIvumdu2ijB62M25)lnm0vOvXLtSneyt78)fyCmeNhWMslNyBUWgsLnDBt6cgKfsrNnqyvHDnkmWBcwzJS20TnrWM0fmil9oMqwv)qCvXEQxyG3eSYMRxTjaHcfudqP3XeYQ6hIRk2t9cM79fGSPlBUBZf2Cb95HCHa6dFavpKleuflkPpXIYkW7z67VGfPttQ83jJso9XaVjyfLe6Zd5cb0xWfIQhYfcQIfL0Nyrzf49m91oRqrtQ83VbLC6JbEtWkkj0xaVjJxN(yaJ7iTO4)g20MUiAZ9Bzdb2Wag3rAbZDya95HCHa6ZXbhW1eIXmiPjv(7AkLC6Zd5cb0NJdoGRXhbIPpg4nbROKqtQ83VfLC6Zd5cb0Ny7ONOkPKJQtpds6JbEtWkkj0KM0xmMdW(MNuYPYFNso9XaVjyfLeAsLNmk50hd8MGvusOjv(BqjN(yG3eSIscnPYRPuYPpg4nbROKqtQ83Iso95HCHa6lgMleqFmWBcwrjHMu5Lrk50hd8MGvusOppKleqF9oMqwv)qCvXEQtFb8MmED6d7RQYrzqwCLcvwGnDzJMkt6lgZbyFZZkIdqGcrF3IMu51KOKtFmWBcwrjH(8qUqa95kmdCXc4k(G0PVymhG9npRioabke9DNMu5Vuk50NhYfcOpuYUi1Ppg4nbROKqtQ8Awk50hd8MGvusOppKleqFyOqutDU2GagrFXyoa7BEwrCacui6JmAsL)UmPKtFmWBcwrjH(8qUqa9HeBGRoqvvBGPVymhG9npRioabke9rgnPYF)oLC6JbEtWkkj0xaVjJxN(AN)VGHcrn15Adcyu5eBJS24HCJYvgW9lJSPlBUtFEixiG(AcxX1V4GXsPjnPV)cwKoLCQ83PKtFmWBcwrjH(c4nz860x78)f8j1fmcvJXCyrleuoX2C9QnDBJtAmEtUOyxH0HzHbEtWkBUE1gN0y8MCXdC9exLcp4ksWCuUWaVjyLnxyJS20o)FbdfIAQZ1geWOYjM(8qUqa914udMb1uNRSugrtQ8KrjN(yG3eSIsc9fWBY41PV25)liXg4Qduv1g4cM79fGSrY2KoUdNLC75AcRQLTrwBAN)VGeBGRoqvvBGlyU3xaYgjBt32C3gcSja7BWAmCbjYMlSHuzZ9YLsFEixiG(qInWvhOQQnW0Kk)nOKtFmWBcwrjH(c4nz860x78)fmuiQPoxBqaJkyU3xaYgjt0MBqFEixiG(WqHOM6CTbbmIMu51uk50hd8MGvusOVaEtgVo91TnEi3OCLbC)YiBiAZDBUE1M25)lnHR46xCWyPffudGnxyJS2e1XR3eCbNTkMXqHG(8qUqa9HHcrn15AdcyenPYFlk50hd8MGvusOVaEtgVo95KgJ3KlEGRN4Qu4bxrcMJYfg4nbRS56vBCsJXBYff7kKomlmWBcwrFEixiG(ACQbZGAQZvwkJOjvEzKso95HCHa6tTOypd60hd8MGvusOjnPpuYUi1PKtL)oLC6Zd5cb0N33oiD6JbEtWkkj0KM0xqHOKtL)oLC6JbEtWkkj0xaVjJxN(AN)V0eqOsCqzbZEiT56vBAN)V4kmdCXc4k(G0lNy6Zd5cb0xmmxiGMu5jJso9XaVjyfLe6Zd5cb0xuhVEtW1fKmaTP0ANTJhfkYkefwHWZf0PIzpKqm9fWBY41PV25)lnbeQehuwWShsBUE1MC75AcRQLTrYeTHmzAZ1R2eG9nyngUGevu8FdBAJKjAdz0hW7z6lQJxVj46csgG2uATZ2XJcfzfIcRq45c6uXShsiMMu5VbLC6JbEtWkkj0xaVjJxN(IGnOKDrQZQIle2iRnDBt78)LMacvIdkly2dPnxVAta23G1y4csurX)nSPnsMOnKzZf0NhYfcOVdIRBY9iAsLxtPKtFEixiG(Aciuv)hSu6JbEtWkkj0Kk)TOKtFEixiG(AmgXycxqh6JbEtWkkj0KkVmsjN(8qUqa99xm3eqOI(yG3eSIscnPYRjrjN(8qUqa95GaJsSlQbxiOpg4nbROKqtQ8xkLC6JbEtWkkj0xaVjJxN(IGnTZ)xCfMbUybCfFq6LtSnYAddyChPLC75AcR9EeTPlBUtFEixiG(CfMbUybCfFq60KkVMLso9XaVjyfLe6lG3KXRtFyFvvokdYIRuOYj2gzTPBBsh3HZsU9CnHv1Y2izBcW(gSgdxqIkk(VHnT56vBIGnOKDrQZQcg25W2iRnbyFdwJHlirff)3WM20frBcX1EpIvumdu2ijBUBZf0NhYfcOVEhtiRQFiUQyp1Pjv(7YKso9XaVjyfLe6lG3KXRtFyFvvokdYIRuOYcSPlBUHmTrs2G9vv5OmilUsHkQd2ZfcSrwBIGnOKDrQZQcg25W2iRnbyFdwJHlirff)3WM20frBcX1EpIvumdu2ijBUtFEixiG(6DmHSQ(H4QI9uNMu5VFNso9XaVjyfLe6lG3KXRtFOywiQPJ7WjYMUiAdz2iRnrWM25)lnHR46xCWyPLtSnYAt320o)FbdfIAQZ1geWOYj2MRxTPD()csSbU6avvTbUCIT5cBK1MUTjc2G9vv5OmilUsHkCexuIS56vBW(QQCugKfxPqfm37laztx2CP2C9QnyFvvokdYIRuOYcSPlB62gYSrs2eGqHcQbO0eUIRFXbJLwc6oUdJQFShYfcCHnxydPYgYULnxqFEixiG(AcxX1V4GXsPjv(7KrjN(yG3eSIsc9fWBY41PVOoE9MGlnHR46xCWyPvKuqWgzTja7BWAmCbjQO4)g20MUiAZDBiWM25)lnm0vOvXLtm95HCHa6RJoeLcPvuIxczAsL)(nOKtFmWBcwrjH(c4nz860xuhVEtWLMWvC9loyS0kskiyJS20TnmGXDKwYTNRjS27r0MUSHmBUE1ggW4osTrY2ClzAZf0NhYfcOpcxHybDQOymZ0Kk)DnLso9XaVjyfLe6lG3KXRtFrD86nbxAcxX1V4GXsRiPGGnYAddyChPLC75AcR9EeTPlBUtFEixiG(AcxXv8bPttQ83VfLC6JbEtWkkj0xaVjJxN(IGnOKDrQZQIle2iRnrD86nbx8(2bPxdqGAZfcOppKleqFrDWI0Pjv(7YiLC6JbEtWkkj0xaVjJxN(IGnOKDrQZQIle2iRnrD86nbx8(2bPxdqGAZfcOppKleqFiDxb1ONfkAst6RDwHIsov(7uYPpg4nbROKqFb8MmED6RD()cmogIZdytPLtSnYAt320o)FHqMJRsHhCvJnrvVbpzvk8uqPhi0gjBdz3YMRxTPD()IIDfshMLtSnxqFEixiG(IxucfvKomPjvEYOKtFEixiG(qlyrjJROeVeY0hd8MGvusOjnPjnPjLca]] )


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