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


    spec:RegisterPack( "Outlaw", 20190310.0056, [[davkYaqisfEKuOnru8jPizusbNIuPvHaPxHGMfrLBruYUK4xikdtfPJPIAziQEgrPAAsr4AKIABQiQVrukmoPi15ifH1rksZJiQ7Hq7tkQdseXcrKEicqtufHlsukTreaFebe1jravRKu6LsrKzIacDtvezNev9tsr0qrG4OiGGLsePNQktLiCvPiQTIaI8vIsrJfbu6SiGK9I0FL0GvCyQwSu9ybtMKlJAZQQplLA0c50kTAeqXRreZMWTvHDd8BidxOooci1YH65GMUORRsBNu13jfgpPIoprA9iqnFPK9tz6zQe0NYtMkp5NEwtCQSF(0YPNQznR5MG(sPXm9f7bs82m9b8dM(0K3u4AqFXUubYvujOpi6Idm9fLzmutjJS2BgD7La6Gm4ECfEUiqa7)Km4EeiJ(63vKe4aAN(uEYu5j)0ZAItL9ZNwo9unR5Mq2G(GXCGkp5N8P0x0QumG2Ppfdd0xJ2OjVPW1Wgjf1(YM2gTjkZyOMsgzT3m62lb0bzW94k8CrGa2)jzW9iqMPTrBojhhIS58PYzd5NEUPTrw2C6PAQMBctRPTrBiGroOnd1utBJ2ilBKeLIv20K2aj2KiBu83VI0gpKlcyJyHzX02OnYYMtcPNv28s2fzKn(pzSnsIcZaxSa2gj9cJSzb2eJ5a6O7PnEixeWgXcZIPTrBKLnsIsXkBIXCaD090gsfUITHaiUySuBAqHyiOPsB6y2jXMxYUiJ0TyAB0gzzZjqGMkT5czBs8ciHtOnlWgyYUiJkM2gTrw2CceOPsBUq2MJfOPeyT5JW2CsoMewzZhHT5eSNr20WMnf0gakTbEJJr4Kv6wmTnAJSSrs0JwLnx4cABJKMKs2dCcBux8cABdPcxX2qaexmwQnnCbcgcTrd2geqi1MixpBZzBsh3MtDlM2gTrw2iPSW1PnnPviwqBBEXyMl0xmg9xbtFnAJM8McxdBKuu7lBAB0MOmJHAkzK1EZOBVeqhKb3JRWZfbcy)NKb3JazM2gT5KCCiYMZNkNnKF65M2gzzZPNQPAUjmTM2gTHag5G2mutnTnAJSSrsukwzttAdKytISrXF)ksB8qUiGnIfMftBJ2ilBojKEwzZlzxKr24)KX2ijkmdCXcyBK0lmYMfytmMdOJUN24HCraBelmlM2gTrw2ijkfRSjgZb0r3tBiv4k2gcG4IXsTPbfIHGMkTPJzNeBEj7Ims3IPTrBKLnNabAQ0MlKTjXlGeoH2SaBGj7ImQyAB0gzzZjqGMkT5czBowGMsG1MpcBZj5ysyLnFe2MtWEgztdB2uqBaO0g4nogHtwPBX02OnYYgjrpAv2CHlOTnsAskzpWjSrDXlOTnKkCfBdbqCXyP20Wfiyi0gnyBqaHuBIC9SnNTjDCBo1TyAB0gzzJKYcxN20KwHybTT5fJzUyAnTnAJSvNC4MSYMo)ry2Ma6O7PnDU9cGfBKKqGJtOnaeqwro(4Ff24HCraOniGqAX06HCrayjgZb0r3tIFHdjX06HCrayjgZb0r3tcjsMFBFWG0ZfbmTEixeawIXCaD09KqIK9riLPTrBEapggHsBW(QSPF)Fwzdm9eAtN)imBtaD090Mo3EbqBCGYMymlRyuMlOTnl0gfcWftRhYfbGLymhqhDpjKizqGhdJqzfMEcnTEixeawIXCaD09KqIKfJYfbmTEixeawIXCaD09KqIKD4ysyv9JWvf7zKCXyoGo6EwHCabuqIAwU9te7RQY6zqwCLcwwqZnXPMwpKlcalXyoGo6EsirYCfMbUybCfFHrYfJ5a6O7zfYbeqbjE206HCrayjgZb0r3tcjsgmzxKrMwpKlcalXyoGo6EsirYWiHOMrCTJamuUymhqhDpRqoGakirYnTEixeawIXCaD09KqIKbfBGRoqvvBGLlgZb0r3ZkKdiGcsKCtRhYfbGLymhqhDpjKizDHR46xCXyPYTFI97)xWiHOMrCTJamSCJLXd5QNRmGpwg28ztRPTrBKT6Kd3Kv2W6zSuBY9GTjJyB8qIW2SqBC9(k8UGlM2gTrszyYUiJSz)2eJGWTlyBAaGSr)vayS3fSnmGpwgAZcSjGo6EQRP1d5IaqIWKDrgzA9qUiaKqIKrYgiX02OnskJrcHnFe2gYj0M(9)H2OXMr2qGiYvSYMtSb2MBCXgnzgXynwiBdMXiHWMpcBd5eAdcBdbYyhOS5KybZ2GW2iP3msWqOneemhw4IaftRhYfbGesKm9oE9UGLd4hmrC2RygJec507IlteN9A)()qjtUmn0V)FrGCfRQQnWLBCRw6OF))sBSdu1dwWC5glJo63)VGVzKGHWAmMdlCrGYnwxtBJ2iPmgje28ryBiNqB63)hAdcBJKEZibdH2qqWCyHlcyJgBgzZjyxbJqPniSnssGT5gBJu0fBZtWSEUyA9qUiaKqIKP3XR3fSCa)GjIZEfZyKqihkMiKt52prNGz8MCrXUcgHYcd8UGvTA5emJ3KlEGR34Qu0fxHcM1Zfg4DbRKtVlUmrC2R97)dLm5Y0q)()fbYvSQQ2axUXTA1V)FbFZibdH1ymhw4IafmF4lakzIbesOqAakDo1GzqnJ4klLHfmF4laQRPTrBiNqBEaNe2gzRugQP2ijcnCPqBWmgje28ryBiNqB63)hwmTEixeasirY07417cwoGFWeXzVIzmsiKdfteYPC7NOtWmEtUabojCLLYWc2bK0mrYLtVlUmrC2R97)dLm5M2gTHCcT5bCsyBKTszOMAZjq2aqPnygJecB0yZiBiNqBGPhibAd6BtgX28aojSnYwPm0M(9)TPHZeAdm9aj2OXMr2qkg5k4QyBUX6wmTEixeasirY07417cwoGFWeXzVIzmsiKdfteZqoLB)eDcMXBYfiWjHRSugwWoGKMjsUm97)xGaNeUYszybMEGKMjsUS63)V0XixbxfxUXMwpKlcajKiz6D86DblhWpyI(r)cJQbeqT5IaYP3fxMyaD0r1y0csyrX)nSzZejNqYjOnKUGbzPDecMcPvyIxs4cd8UGvYeqiHcPbO0ocbtH0kmXljCbZh(cGs(SUe2V)FPJrUcUkUCJLHbmUT0Mp5tLrh97)xGKCfIQdu1agbHDeGHLBSPTrBKn3mYMJRi3ybBt642CcLZMmAH2O3XR3fSnl0MqehiHv2KiBuCyvSnAeXzeJTbIoyBiGNaAdmcDfkB6SnqPGaRSrJnJSHuHRyBiaIlgl106HCraiHejtVJxVly5a(btSlCfx)IlglTcLccYP3fxMimMfIA642CclDHR46xCXyPsMCzW(QQSEgKfxPGLf0m5N2Qv)()LUWvC9lUyS0Yn206HCraiHejl4cr1d5IavXct5a(bteMSlYi52pryYUiJyvXfctRhYfbGesKSGlevpKlcuflmLd4hmXGcAAB0gcWcwyKnEAZHRZ94EydbKGuS5D7We7H0geGT5JW2WEiYgsXixbxfBJdu2OjJJr48c2uQnAeXaBiq4UbsS5eyxdBwOnqwWHKv24aLnN0)e2SqBaO0gm7kP24)KX2KrSnawNPnqoGaQIP1d5Iaqcjsg(cQEixeOkwykhWpyI)fSWi52pXa6OJQXOfKWMjgIRhUoRWygOKvd97)x6yKRGRIl3yc73)VGIJr48c2uA5gRlbTH0fmileOVBGKQc7AuyG3fSsMg0r6cgKLdhtcRQFeUQypJkmW7cw1QvaHekKgGYHJjHv1pcxvSNrfmF4la28zD1106HCraiHejl4cr1d5IavXct5a(btSFxHY06HCraiHejZXbhW1eHXmiLB)ezaJBlTO4)g2SzIN1mHmGXTLwWCBgyA9qUiaKqIK54Gd4A8vaztRhYfbGesKmX2okHvcmxv7dgKMwtBJ2q6DfkgdnTnAttgY2qqwyIe28IqPn73MnTrdeOPsBcESnb0rhztmAbj0ghOSjJyB0KXXiCEbBk1M(9)TzH2CJl2ij6rRYMlCbTTrJigyttI5yBiqHUyBKn3eAdm9ajqBCmBt02oYMlqWqOnzeBZjyxbJqPn97)BZcTXfqKn34IP1d5IaWs)UcfX4fMirfgHs52pX(9)lO4yeoVGnLwUXY0q)()fsyoUkfDXvn2ew9o6MvPOBbMEGejtUMB1QF))IIDfmcLLBSUMwpKlcal97kuesKm4cwyY4kmXljSP102OneqesOqAaGMwpKlcalbfKymkxeqU9tSF))sxGqkXfMfm7HSvR(9)lUcZaxSaUIVWOYn202OneaxiwqBB6EGeBsKnk(7xrAZM8HnxO3MnTEixeawckiHej7c56M8HCa)GjQ3XR3fCDbjdGBkT2EB76rISIGHvi8CbTRy2djcl3(j2V)FPlqiL4cZcM9q2QvUhCnrv1YsMi5N2QvaD0r1y0csyrX)nSPKjsUP1d5IaWsqbjKizxix3KpGYTFI6aMSlYiwvCHqMg63)V0fiKsCHzbZEiB1kGo6OAmAbjSO4)g2uYejxxtRhYfbGLGcsirY6cesv)xSutRhYfbGLGcsirY6mgYyswqBtRhYfbGLGcsirY(lM7ceszA9qUiaSeuqcjsMdcmmXUOgCHW06HCrayjOGesKmxHzGlwaxXxyKC7NOo63)V4kmdCXc4k(cJk3yzyaJBlTK7bxtu9W1zZNnTnAdb(3gxPG24y2MBSC2abBmBtgX2GaSnASzKncKgmmTrcjorXMMmKTrJigyJs6cABZ3HjJTjJCGneqcInk(VHnTbHTrJnJq30ghi1gcibPyA9qUiaSeuqcjs2HJjHv1pcxvSNrYTFIyFvvwpdYIRuWYnwMgsh3MZsUhCnrv1YsoGo6OAmAbjSO4)g2SvlDat2fzeRkyu7lltaD0r1y0csyrX)nSzZedX1dxNvymduY6SUM2gTHa)BdazJRuqB0yfcBulBJgBgTaBYi2gaRZ0gz)uOC2CHSnN0)e2Ga20rqOnASze6M24aP2qajiftRhYfbGLGcsirYoCmjSQ(r4QI9msU9te7RQY6zqwCLcwwqZY(PYc7RQY6zqwCLcwuxSNlciJoGj7ImIvfmQ9LLjGo6OAmAbjSO4)g2SzIH46HRZkmMbkzD202OnKkCfBdbqCXyP2Ga2qoH2Wa(yzyXgzZnJSXvkOMAttgY2SFBYiwQnW0LAZhHTPPj0gihqaf0ge2M9BJu0fBdG1zAtiYXTzB0yfcB6Sny2vsTzb2K7bBZhHTjJyBaSotB0W1ZftRhYfbGLGcsirY6cxX1V4IXsLB)eHXSquth3MtyZejxgD0V)FPlCfx)IlglTCJLPH(9)lyKquZiU2ragwUXTA1V)Fbk2axDGQQ2axUX6ktd6a7RQY6zqwCLcwyDUWe2Qf2xvL1ZGS4kfSG5dFbWMB6wTW(QQSEgKfxPGLf0CdKlRacjuinaLUWvC9lUyS0siYXTzy9J9qUiGl0LGsUM1106HCrayjOGesKS2riykKwHjEjHLB)e17417cU0fUIRFXfJLwHsbbzcOJoQgJwqclk(VHnBM4zc73)V0XixbxfxUXMwpKlcalbfKqIKrYkelODfgJzwU9tuVJxVl4sx4kU(fxmwAfkfeKPbgW42sl5EW1evpCD2m5TAXag3wQK18P6AA9qUiaSeuqcjswx4kUIVWi52pr9oE9UGlDHR46xCXyPvOuqqggW42sl5EW1evpCD28ztBJ20KHlOTnei5GfgrMKC0VWiBwOniGqQnUn6zSuBYfi1MfeWSdz5SbISzb2GzxSPu5Srk62uy2gVdrIBYcP28xaBtIS5czB20ghAJBZnxXMsTbgZcrX06HCrayjOGesKm9oyHrYTFI6aMSlYiwvCHqg9oE9UGl(r)cJQbeqT5IaMwpKlcalbfKqIKbJCfsJdwOKB)e1bmzxKrSQ4cHm6D86Dbx8J(fgvdiGAZfbmTM2gTHaSGfgXyOPTrBinLT2G0ZyBK0KuBWmgjeqB0yZiBob7kyekjtscSnj23eAdcBJKEZibdH2qqWCyHlcumTEixeaw(lyHre7CQbZGAgXvwkdLB)e73)VGVzKGHWAmMdlCrGYnUvRgCcMXBYff7kyeklmW7cw1QLtWmEtU4bUEJRsrxCfkywpxyG3fSsxz63)VGrcrnJ4Ahbyy5gBA9qUiaS8xWcJiKizqXg4Qduv1gy52pXg8qU65kd4JLHep3Qv)()LUWvC9lUyS0IcPbqxzAOF))cuSbU6avvTbUG5dFbqjNoUnNLCp4AIQQLLPF))cuSbU6avvTbUG5dFbqj3WzcdOJoQgJwqc1LGEU006AA9qUiaS8xWcJiKizyKquZiU2ragk3(j2GhYvpxzaFSmK45wT63)V0fUIRFXfJLwuina6ktd97)xWiHOMrCTJamSG5dFbqjtu2B1sVJxVl4co7vmJrcHUM2gTH0u2AJgBgztgX2ijb2MMCSneOqxSnpbZ6zBqyBob7kyekTjX(MWIP1d5IaWYFblmIqIK15udMb1mIRSugk3(j6emJ3KlEGR34Qu0fxHcM1Zfg4DbRA1YjygVjxuSRGrOSWaVlyLP1d5IaWYFblmIqIKPwySNHitRPTrBEj7ImY06HCraybMSlYiI(r)cJOp9mgUiavEYp9SM4uYpFYfYpR5Z0NgogSG2q6Ja)igHtwzZjBJhYfbSrSWewmT0NyHjKkb9P4VFfjvcQ8NPsqFEixeG(Gj7ImI(yG3fSIsknPYtovc6Zd5Ia0hjBGe6JbExWkkP0KkVStLG(yG3fSIsk9P3fxM(WzV2V)p0gjBd52iJnnyt)()fbYvSQQ2axUX20QLn6WM(9)lTXoqvpybZLBSnYyJoSPF))c(MrcgcRXyoSWfbk3yB0L(8qUia9P3XR3fm9P3XvGFW0ho7vmJrcbnPY3eujOpg4DbROKsFOy6dYj95HCra6tVJxVly6tVlUm9HZETF)FOns2gYTrgBAWM(9)lcKRyvvTbUCJTPvlB63)VGVzKGHWAmMdlCrGcMp8faTrYeTjGqcfsdqPZPgmdQzexzPmSG5dFbqB0L(c4nz860NtWmEtUOyxbJqzHbExWkBA1YgNGz8MCXdC9gxLIU4kuWSEUWaVlyf9P3XvGFW0ho7vmJrcbnPYRzQe0hd8UGvusPpum9b5K(8qUia9P3XR3fm9P3fxM(WzV2V)p0gjBd50xaVjJxN(CcMXBYfiWjHRSugwWoGeBAMOnKtF6DCf4hm9HZEfZyKqqtQ8Nmvc6JbExWkkP0hkM(WmKt6Zd5Ia0NEhVExW0NEhxb(btF4SxXmgje0xaVjJxN(CcMXBYfiWjHRSugwWoGeBAMOnKBJm20V)FbcCs4klLHfy6bsSPzI2qUnYYM(9)lDmYvWvXLBmnPYlBqLG(yG3fSIsk9P3fxM(cOJoQgJwqclk(VHnTPzI2qUneAd52qqTPbBsxWGS0ocbtH0kmXljCHbExWkBKXMacjuinaL2riykKwHjEjHly(Wxa0gjBZzB01gcTPF))shJCfCvC5gBJm2Wag3wQnnBZjFQnYyJoSPF))cKKRquDGQgWiiSJamSCJPppKlcqF6D86DbtF6DCf4hm95h9lmQgqa1MlcqtQ8nnvc6JbExWkkP0NExCz6dgZcrnDCBoHLUWvC9lUySuBKSnKBJm2G9vvz9milUsbllWMMTH8tTPvlB63)V0fUIRFXfJLwUX0NhYfbOp9oE9UGPp9oUc8dM(6cxX1V4IXsRqPGanPYRjOsqFmW7cwrjL(c4nz860hmzxKrSQ4cb95HCra6l4cr1d5IavXct6tSWSc8dM(Gj7ImIMu5pFkvc6JbExWkkP0NhYfbOVGlevpKlcuflmPpXcZkWpy6lOG0Kk)5ZujOpg4DbROKsFb8MmED6lGo6OAmAbj0MMjAtiUE46ScJzGYgzztd20V)FPJrUcUkUCJTHqB63)VGIJr48c2uA5gBJU2qqTPbBsxWGSqG(UbsQkSRrHbExWkBKXMgSrh2KUGbz5WXKWQ6hHRk2ZOcd8UGv20QLnbesOqAakhoMewv)iCvXEgvW8HVaOnnBZzB01gDPppKlcqF4lO6HCrGQyHj9jwywb(btF)fSWiAsL)m5ujOpg4DbROKsFEixeG(cUqu9qUiqvSWK(elmRa)GPV(DfkAsL)SStLG(yG3fSIsk9fWBY41PpgW42slk(VHnTPzI2CwZ2qOnmGXTLwWCBgqFEixeG(CCWbCnrymdsAsL)CtqLG(8qUia954Gd4A8vaz6JbExWkkP0Kk)zntLG(8qUia9j22rjSsG5QAFWGK(yG3fSIsknPj9fJ5a6O7jvcQ8NPsqFmW7cwrjLMu5jNkb9XaVlyfLuAsLx2PsqFmW7cwrjLMu5BcQe0hd8UGvusPjvEntLG(8qUia9fJYfbOpg4DbROKstQ8Nmvc6JbExWkkP0NhYfbOVdhtcRQFeUQypJOVaEtgVo9H9vvz9milUsbllWMMTPjoL(IXCaD09Sc5acOG0NMPjvEzdQe0hd8UGvusPppKlcqFUcZaxSaUIVWi6lgZb0r3ZkKdiGcsFNPjv(MMkb95HCra6dMSlYi6JbExWkkP0KkVMGkb9XaVlyfLu6Zd5Ia0hgje1mIRDeGH0xmMdOJUNvihqafK(iNMu5pFkvc6JbExWkkP0NhYfbOpOydC1bQQAdm9fJ5a6O7zfYbeqbPpYPjv(ZNPsqFmW7cwrjL(c4nz860x)()fmsiQzex7iadl3yBKXgpKREUYa(yzOnnBZz6Zd5Ia0xx4kU(fxmwknPj91VRqrLGk)zQe0hd8UGvusPVaEtgVo91V)FbfhJW5fSP0Yn2gzSPbB63)VqcZXvPOlUQXMWQ3r3SkfDlW0dKyJKTHCnBtRw20V)FrXUcgHYYn2gDPppKlcqFXlmrIkmcL0Kkp5ujOppKlcqFWfSWKXvyIxsy6JbExWkkP0KM0hmzxKrujOYFMkb95HCra6Zp6xye9XaVlyfLuAst6lOGujOYFMkb9XaVlyfLu6lG3KXRtF97)x6cesjUWSGzpK20QLn97)xCfMbUybCfFHrLBm95HCra6lgLlcqtQ8KtLG(yG3fSIsk95HCra6tVJxVl46csga3uAT9221JezfbdRq45cAxXShseM(c4nz860x)()LUaHuIlmly2dPnTAztUhCnrv1Y2izI2q(P20QLnb0rhvJrliHff)3WM2izI2qo9b8dM(07417cUUGKbWnLwBVTD9irwrWWkeEUG2vm7HeHPjvEzNkb9XaVlyfLu6lG3KXRtF6WgyYUiJyvXfcBKXMgSPF))sxGqkXfMfm7H0MwTSjGo6OAmAbjSO4)g20gjt0gYTrx6Zd5Ia03fY1n5dinPY3eujOppKlcqFDbcPQ)lwk9XaVlyfLuAsLxZujOppKlcqFDgdzmjlOn9XaVlyfLuAsL)KPsqFEixeG((lM7cesrFmW7cwrjLMu5LnOsqFEixeG(CqGHj2f1Gle0hd8UGvusPjv(MMkb9XaVlyfLu6lG3KXRtF6WM(9)lUcZaxSaUIVWOYn2gzSHbmUT0sUhCnr1dxN20SnNPppKlcqFUcZaxSaUIVWiAsLxtqLG(yG3fSIsk9fWBY41PpSVQkRNbzXvky5gBJm20GnPJBZzj3dUMOQAzBKSnb0rhvJrliHff)3WM20QLn6WgyYUiJyvbJAFzBKXMa6OJQXOfKWII)BytBAMOnH46HRZkmMbkBKLnNTrx6Zd5Ia03HJjHv1pcxvSNr0Kk)5tPsqFmW7cwrjL(c4nz860h2xvL1ZGS4kfSSaBA2gz)uBKLnyFvvwpdYIRuWI6I9CraBKXgDydmzxKrSQGrTVSnYytaD0r1y0csyrX)nSPnnt0MqC9W1zfgZaLnYYMZ0NhYfbOVdhtcRQFeUQypJOjv(ZNPsqFmW7cwrjL(c4nz860hmMfIA642CcTPzI2qUnYyJoSPF))sx4kU(fxmwA5gBJm20Gn97)xWiHOMrCTJamSCJTPvlB63)VafBGRoqvvBGl3yB01gzSPbB0HnyFvvwpdYIRuWcRZfMqBA1YgSVQkRNbzXvkybZh(cG20SnnTnTAzd2xvL1ZGS4kfSSaBA2MgSHCBKLnbesOqAakDHR46xCXyPLqKJBZW6h7HCraxyJU2qqTHCnBJU0NhYfbOVUWvC9lUySuAsL)m5ujOpg4DbROKsFb8MmED6tVJxVl4sx4kU(fxmwAfkfeSrgBcOJoQgJwqclk(VHnTPzI2C2gcTPF))shJCfCvC5gtFEixeG(AhHGPqAfM4LeMMu5pl7ujOpg4DbROKsFb8MmED6tVJxVl4sx4kU(fxmwAfkfeSrgBAWggW42sl5EW1evpCDAtZ2qUnTAzddyCBP2izB08P2Ol95HCra6JKviwq7kmgZmnPYFUjOsqFmW7cwrjL(c4nz860NEhVExWLUWvC9lUyS0kukiyJm2Wag3wAj3dUMO6HRtBA2MZ0NhYfbOVUWvCfFHr0Kk)zntLG(yG3fSIsk9fWBY41PpDydmzxKrSQ4cHnYyJEhVExWf)OFHr1acO2Cra6Zd5Ia0NEhSWiAsL)8jtLG(yG3fSIsk9fWBY41PpDydmzxKrSQ4cHnYyJEhVExWf)OFHr1acO2Cra6Zd5Ia0hmYvinoyHIM0K((lyHrujOYFMkb9XaVlyfLu6lG3KXRtF97)xW3msWqyngZHfUiq5gBtRw20GnobZ4n5IIDfmcLfg4DbRSPvlBCcMXBYfpW1BCvk6IRqbZ65cd8UGv2ORnYyt)()fmsiQzex7iadl3y6Zd5Ia0xNtnyguZiUYszinPYtovc6JbExWkkP0xaVjJxN(AWgpKREUYa(yzOneT5SnTAzt)()LUWvC9lUyS0IcPbWgDTrgBAWM(9)lqXg4Qduv1g4cMp8faTrY2KoUnNLCp4AIQQLTrgB63)VafBGRoqvvBGly(Wxa0gjBtd2C2gcTjGo6OAmAbj0gDTHGAZ5stBJU0NhYfbOpOydC1bQQAdmnPYl7ujOpg4DbROKsFb8MmED6RbB8qU65kd4JLH2q0MZ20QLn97)x6cxX1V4IXslkKgaB01gzSPbB63)VGrcrnJ4AhbyybZh(cG2izI2i720QLn6D86DbxWzVIzmsiSrx6Zd5Ia0hgje1mIRDeGH0KkFtqLG(yG3fSIsk9fWBY41PpNGz8MCXdC9gxLIU4kuWSEUWaVlyLnTAzJtWmEtUOyxbJqzHbExWk6Zd5Ia0xNtnyguZiUYszinPYRzQe0NhYfbOp1cJ9merFmW7cwrjLM0KM0NFZieM(E7bbKM0Ksb]] )


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