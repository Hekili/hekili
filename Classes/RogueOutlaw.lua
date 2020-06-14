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

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

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
                if combo_points.current == 0 then return false, "no combo points" end

                -- Don't RtB if we've already done a simulated RtB.
                if buff.rtb_buff_1.up then return false, "we already rerolled and can't know which buffs we'll have" end

                --[[ This was based on 8.2 logic; tweaking APL instead to avoid hardcoding.  2020-03-09
                
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
                end ]]

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

            disabled = function ()
                return not ( boss and group )
            end,

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


    spec:RegisterPack( "Outlaw", 20200614, [[defPubqiPu9iaLnHs6tsjHrbiofaAvaQ4veHzHsClaWUe8lHWWKs5yOuwgq8mIOAAasDnavTnaj(gGk14iQkNdqLSoIO08esUhqTpPeheqslKOYdLssMirv6IsjP2irv4JevryKevrYjjQQyLa0ljQQ0mjQIu3KikStHu)KOkQHkLu5Oevr0sLskpfftvi6QevvTvPKQYxjIIgRusv1zLsQI9s4VKmyvomvlwQEmPMmfxgzZk6ZuIrlfNwPvlLuLEnqA2O62c1Ub9BidNsDCPKOLRQNd10fDDf2oL03rPA8aqNNOSEIiZNiTFjlytePGX4jjIgK2aPT2akSb0b2aHn5Rn2emPmBsWy7AqDlKGb6XKGrEEKCNDbJTlJJCJisbdgnEnjyAY0glzJiclB2m6bnkoc8gp4EUiO(9zgbEJ1riy6JLNYpqrxWy8KerdsBG0wBaf2a6aBGWgWnWd0cgSnPfrdcqPnbtZAmeu0fmgcRfmaRo55rYD2RR1qwgubiWQRjtBSKnIiSSzZOh0O4iWB8G75IG63Nze4nwhrbiWQdWbKQJnGML6aPnqARaSaey11QACOfclzlabwDaqDavJHm1j)UAqRlr1zOPp4zDUoxeSo(IZqbiWQdaQdOAmKPo7N0O4UN1jh3nuDYd(4Fz1bedIWWwrwx)jh06ysY5zdadfGaRoaOo5fbBfzDdmvx(leukX1TW6Wj58SjuacS6aG6KxeSvK1nWuDXluY26VUj6RtYWFqjtDt0xN8sE2uhq2SvGRdIY6WdBB0NKbGHcqGvhauhq1kAn190J48fAPUwlLRoZ4xOL6KJ7gQo5bF8VS6aYaYjmUo2P6qqUS6ACRuDSvx6VfkbyOaey1ba11Ae3bW6KFxoFHwQJX(jkuacS6aG6K)yQUCJjvIuMLQBI(6iOgnGj91rqZcTu37zd91LnoSU0FlugYnMujszwkuacS6aG6K)yQUwlLRUNEeNxhhzz115qtDmq5TUNMpHBQJJSS66wyDzdvN9tAuC3Z6CDUiyD8fNbbJ9JMlNemaRo55rYD2RR1qwgubiWQRjtBSKnIiSSzZOh0O4iWB8G75IG63Nze4nwhrbiWQdWbKQJnGML6aPnqARaSaey11QACOfclzlabwDaqDavJHm1j)UAqRlr1zOPp4zDUoxeSo(IZqbiWQdaQdOAmKPo7N0O4UN1jh3nuDYd(4Fz1bedIWWwrwx)jh06ysY5zdadfGaRoaOo5fbBfzDdmvx(leukX1TW6Wj58SjuacS6aG6KxeSvK1nWuDXluY26VUj6RtYWFqjtDt0xN8sE2uhq2SvGRdIY6WdBB0NKbGHcqGvhauhq1kAn190J48fAPUwlLRoZ4xOL6KJ7gQo5bF8VS6aYaYjmUo2P6qqUS6ACRuDSvx6VfkbyOaey1ba11Ae3bW6KFxoFHwQJX(jkuacS6aG6K)yQUCJjvIuMLQBI(6iOgnGj91rqZcTu37zd91LnoSU0FlugYnMujszwkuacS6aG6K)yQUwlLRUNEeNxhhzz115qtDmq5TUNMpHBQJJSS66wyDzdvN9tAuC3Z6CDUiyD8fNHcWcqGvxRgaj9ijtDDAIEQonkU7zDDYYcXH6aQAnzN46Giia04F8CWRZ15IG46qqUSqbiWQZ15IG4G9tAuC3tWtUJbTaey156CrqCW(jnkU7PeGJWhwIjy65IGfGaRoxNlcId2pPrXDpLaCeteYuacS6yGUnUbL19(AQRpMtYuho9exxNMONQtJI7EwxNSSqCDo0uN9taGnkZfAPUfxNbbPqbiWQZ15IG4G9tAuC3tjahbg624guQWPN4cqxNlcId2pPrXDpLaCew9F9oNyb6XeyKv6vVTs)BQYMNWniUHfRoFqG9mDnOk9VzlTfaAqkaDDUiioy)Kgf39ucWryJYfblaDDUiioy)Kgf39ucWre7pOKrnrVYqE2WI9tAuC3tfM0iObdg4zzNGFFnkYkbZGBm4WcBbOBRa015IG4G9tAuC3tjahbojNNnSStWaPDQvowBBYeSrAqPeVsImknk2EKEUiOYqwxnjvA7AeIBqSddAzAokFeC1Qo3XzWmEpxeuQ03xJISsWmSqRdoKEVZPabGloXaSaey11A0J486MOVoqKOo0xN8eVdn1jzqCIQd911AJSHtyCDTUN0lErWqbORZfbXb7N0O4UNsaocR(VENtSa9yc8ND1tpIZzXQZhe4p7Q(yoXrbcRT3hZzWY7qJkM4efg2S2EFmNHFKnCcJv2pPx8IGHHDbiWQR1OhX51nrFDGirD9XCIRd91j3JCdEnuDSVztDYl5gCdkdfGUoxeehSFsJI7Ekb4iS6)6DoXc0JjWF2vp9ioNfKnymLSStWUKOFtkyi3GBqzGGENtgPsT6)6DofqwPx92k9VPkBEc3G4gwS68bb(ZUQpMtCuGWkq6J5mWrUHmkZQPWWwQ027J5m0FKBWRHcdBawacS6An6rCEDt0xhisuxFmN46qFDT2iB4egxxR7j9IxeSo23SPoGQMQByxNm04RJHtKvIL6gqoHX1Ln0t15pvxm6P6KxYn4guw37qqXHcqxNlcId2pPrXDpLaCew9F9oNyb6Xe4p7QNEeNZcYgmMsw2jyxs0VjfCnPg2kzOXRWCISsbc6Dozy1Le9BsbxtQHTsgA8kmNiRu4DiOTa2Le9Bsbd5gCdkdVdbL12T6)6DofqwPx92k9VPkBEc3G4gwS68bb(ZUQpMtCuGWkq6J5mWrUHmkZQPWWwQ0(yod)iB4egRSFsV4fbdpf7lehfyncXni2HHoLSteuLnKIKr4WtX(cXaSaey1bIe1XaDqP6A1YiSKToGkNDxgUUNEeNx3e91bIe11hZjoua66CrqCW(jnkU7PeGJWQ)R35elqpMa)zx90J4Cwq2GXuYYob7sI(nPag6GsksgHdVdbTfWGWIvNpiWF2v9XCIJcKcqGvhisuhd0bLQRvlJWs26KxuDquw3tpIZRJ9nBQdejQdNUguCDOzDzdvhd0bLQRvlJW11hZzDaHnjQdNUg06yFZM6K7rUbVgQUHnadfGUoxeehSFsJI7Ekb4iS6)6DoXc0JjWF2vp9ioNfKn4NWuYYob7sI(nPag6GsksgHdVdbTfWGWAFmNbm0bLuKmchWPRbTfWGaa9XCg6pYn41qHHDbiWQtYCZM6KJ7gQo5bF8VS6g2Su3AbIEQUFWjCDEhzLQZHM6shuQoYk9YYMfAPUSXZ6wCDGirDabIY60ObmxOL6y8wfaRd91HxOfovNCmSuN8esgSuxR16kaDDUiioy)Kgf39ucWry1)17CIfOhtG)SRE6rColiBWykzzNG7J5m05UHut(4FzHHnlwD(Ga)zx1hZjga6J5mGbDW5khAu6hHXDeKWHHDuGWkq6J5mWrUHmkZQPWWwQ027J5my5DOrftCIcdBwBVpMZWpYgoHXk7N0lErWWWM127J5m0FKBWRHcdBawacS6Km3SPo5PrUHm1jVRMQByZsDp9ioVohkRo8cTWP66J5KL6COS6aPU(yoRJ9nBQtUXVKPUiFYXJNyPo0x3cRZ2HgkE1HcqxNlcId2pPrXDpLaCew9F9oNyb6Xe4p7QNEeNZcYgmMsw2j4(yodCKBiJYSAkmSzXQZheyG8zx1hZjga6J5m0h)sgv(KJhpfg2amkqKkTpMZWJ4Cv2qQocs4WtX(cXrXwBb5tcGWwq(aoPZjygmeztVcNVNUfkoqqVZjdalaDDUiioy)Kgf39ucWr8ioxLnKQJGeMf7N0O4UNkmPrqdgmiSStW9XCgEeNRYgs1rqchEk2xiokWsUuPw9F9oNcF2vp9ioVa015IG4G9tAuC3tjahbMVAs5qJYSAIf7N0O4UNkmPrqdgmiSStW9XCgW8vtkhAuMvtHNI9fIJk3ysLiLzjw7J5mG5RMuo0OmRMcpf7lehfqytcnkUJu2OfMyacCyliFfGUoxeehSFsJI7Ekb4iCZtqNVqs9dCdl2pPrXDpvysJGgmy2yzNGbs7uRCS22KjyJ0GsjELezuAuS9i9CrqLHSUAsQ021ie3Gyhg0Y0Cu(i4QvDUJZGz8EUiOuPVVgfzLGzyHwhCi9ENtbcaxCIbybORZfbXb7N0O4UNsaoIbMuBsXSa9ycSljCJ)ownrWuHMkBe70xa66CrqCW(jnkU7PeGJyGj1Muml0Cs6ub9ycSwMMJYhbxTQZDCYYob3(7RrrwjygwO1bhsV35uGaWfN4cWcqGvxRgaj9ijtDKv6LvxUXuDzdvNRt0x3IRZT6l37CkuacS6AncNKZZM62zD2imE7CQoGar1zDWH07DovhbP4LW1TW60O4UNaSa015IGyWGUAqzzNGBhNKZZgYeEKLbva66CrqmyCsopBkaDDUiiwcWry1)17CIfOhtG94(a3O0iOzZfbzXQZheynkUJu2OfM4GHMREZwadIeGaCas6CcMblniCYLPW5VGsbc6DozyvJqCdIDyWsdcNCzkC(lOu4PyFH4OydGs0hZzO)i3Gxdfg2Ssq6TiRfGsBS2EFmNbmOdox5qJs)imUJGeomSzT9(yodGsKTsgA8k23eR8oAKkzOryyxa66CrqSeGJWQ)R35elqpMa3tsPrqZMlcYIvNpiW9XCg(r2Wjmwz)KEXlcgg2sLcexs0VjfmKBWnOmqqVZjJuPUKOFtk4AsnSvYqJxH5ezLce07CYaqw7J5m8ioxLnKQJGeomSlabwDsMB2ux8GNRnNQl93cLywQlBwCDw9F9oNQBX1PBinOKPUevNH0RHQJ9gkBOVomkMQRvjV46WnOb3uxNQdldQjtDSVztDYXDdvN8Gp(xwbORZfbXsaocR(VENtSa9ycCN7gsn5J)LPWYGAwS68bbgBtCUk93cL4qN7gsn5J)LffiS((AuKvcMb3yWHf2ciTjvAFmNHo3nKAYh)llmSlaDDUiiwcWrODox56CrqfFXjlqpMaJtY5zdl7emojNNnKj4CEbORZfbXsaocTZ5kxNlcQ4lozb6XeyTbxacS6KhlCXn15zDXoaUXJ46AvTUqDmJooFxN1HGuDt0xh56M6K7rUbVgQohAQtE22g95aUPS6yVHG1jp5y1GwN8(o71T46WeN0jzQZHM6KmMYBDlUoikR7j3iRoFM0xx2q1bjamRdtAe0eQdOYz3LHRl2bW6KlB11X(Mn1bIe1bu1uOa015IGyjahXpGkxNlcQ4lozb6Xe45cxCdl7eSgf3rkB0ctClG12QyhavyBcAaaG0hZzO)i3Gxdfg2s0hZzazBJ(Ca3uwyydqGdqsNtWm0khRguL5D2de07CYWkqApDobZqS)Gsg1e9kd5ztGGENtgPs1ie3GyhgI9huYOMOxzipBcpf7le3cBaeGahG4sI(nPGRj1WwjdnEfMtKvk8oe0OarQ021ie3Gyhg6uYorqv2qksgHddBPsBVpMZWJ4Cv2qQocs4WWgGfGUoxeelb4i0oNRCDUiOIV4KfOhtG7JLBkaDDUiiwcWr4V2HKkr)tWKLDcMG0BrwWqZvVzlGzd4LGG0Brw4jleSa015IGyjahH)Ahsk7bhtfGUoxeelb4i4RLMeRA9omwIjywa66CrqSeGJO7wuOPk)vdkUaSaey1j3y5g6XfGaRo5pMQR1T4eXRJPbL1TZ62So2rWwrwN2TRtJI7O6SrlmX15qtDzdvN8STn6ZbCtz11hZzDlUUHDOoGQv0AQBGxOL6yVHG1j)sKDDTEqJVojZnX1HtxdkUo)P6Awln1H(6yVHG1nWl0sDsMKBJGXooPNL6gqoHX1LnuDYl5gCdkRRpMZ6wCDd7qbORZfbXH(y5gW2lorCfUbLSStWajDobZqRCSAqvM3zpqqVZjJuPUKOFtkakr2kzOXRyFtSY7OrQKHgH3HGgfiaK1(yodiBB0Nd4MYcdBwbsFmNbqjYwjdnEf7BIvEhnsLm0iGtxdAuSb0sLsq6TilkGg4bybORZfbXH(y5gjahH9ItexHBqjl7eCFmNbKTn6ZbCtzHHnR9XCgmKBWnOmmSlaDDUiio0hl3ib4iWlCXj9kC(lOubybiWQRvHqCdIDiUa015IG4G2GbRDox56CrqfFXjlqpMatymb1eMLDcUDCsopBitW58cqxNlcIdAdwcWr4MNGoFHK6h4gw2j427J5m4MNGoFHK6h4MWWMvG0o1khRTnzcUKWn(7y1ebtfAQSrStVuPAeIBqSddCpjyQ8x7qp8uSVqClG0galabwDYpZ6CJbxN)uDdBwQddxBQUSHQdbP6yFZM64i2jCwxKrkVH6K)yQo2BiyDgzl0sDthN0xx24W6AvTU6m0C1Bwh6RJ9nBqJSohkRUwvRlua66CrqCqBWsaoIy)bLmQj6vgYZgw0Y0CsL(BHsmy2yzNGFFnkYkbZGBm4WWMvGK(BHYqUXKkrkZsrPrXDKYgTWehm0C1BkvA74KCE2qMWJSmiw1O4oszJwyIdgAU6nBbS2wf7aOcBtqdaWgalabwDYpZ6GO6CJbxh7lNxNzP6yFZMfwx2q1bjamRtYBdZsDdmvNKXuERdbRRJW46yFZg0iRZHYQRv16cfGUoxeeh0gSeGJi2FqjJAIELH8SHLDc(91OiRemdUXGdlSfjVna491OiRemdUXGdMX75IGS2oojNNnKj8ildIvnkUJu2OfM4GHMREZwaRTvXoaQW2e0aaSvacS6KJ7gQo5bF8VS6qW6arI6iifVeouNK5Mn15gdwYwN8ht1TZ6YgswD40Lv3e91jFsuhM0iObxh6RBN1jdn(6GeaM1PB83cvh7lNxxNQ7j3iRUfwxUXuDt0xx2q1bjamRJD3kfkaDDUiioOnyjahrN7gsn5J)LXYobJTjoxL(BHsClGbH127J5m05UHut(4FzHHnRaP93xJISsWm4gdoqa4ItSuPVVgfzLGzWngC4PyFH4wKpPsFFnkYkbZGBm4WcBbiGaaAeIBqSddDUBi1Kp(xwq34VfcRMVRZfbDoaboGa8aSa015IG4G2GLaCewAq4KltHZFbLyzNG1O4oszJwyIdgAU6nBbmBs0hZzO)i3Gxdfg2fGUoxeeh0gSeGJa0LZxOff2(jILDc2Q)R35uOZDdPM8X)YuyzqnRyBIZvP)wOeh6C3qQjF8VSwyJvcsVfzHCJjvIuXoa2cifGUoxeeh0gSeGJOZDdP(bUHLDc2Q)R35uOZDdPM8X)YuyzqnReKElYc5gtQePIDaSfqkabwDYF8cTuxRphU4MiaQX9bUPUfxhcYLvNxNv6LvxUqz1Tq9toMyPomQUfw3toFtzSuNm0Ov8uDEhJ4JK4YQBUqQUev3at1TzDoUoVUrU8nLvh2M48qbORZfbXbTblb4iS6Wf3WYob3oojNNnKj4CoRw9F9oNcECFGBuAe0S5IGfGUoxeeh0gSeGJa34ge7Xe3WYob3oojNNnKj4CoRw9F9oNcECFGBuAe0S5IGfGUoxeeh0gSeGJWgLlcYYob3hZzOZridFGZWtUoLkTpMZGBEc68fsQFGBcd7cqGvN8W58fAPUURbTUevNHM(GN1Tjfx3a7wOcqxNlcIdAdwcWrmWKAtkMfOhtGT6)6DoPwysq8MYuwwlUvepviSE5CpxOf1tUorpl7eCFmNHohHm8bodp56uQ0CJjvIuMLIcmiTjvQgf3rkB0ctCWqZvVzuGbPa015IG4G2GLaCedmP2KIXSStW9XCg6CeYWh4m8KRtPsZnMujszwkkWG0MuPAuChPSrlmXbdnx9MrbgKcqxNlcIdAdwcWr05iKrnhVScqxNlcIdAdwcWr0PhtpOl0sbORZfbXbTblb4iM7tDoczkaDDUiioOnyjahHd1eoFNR0oNxa66CrqCqBWsaoIbMuBsXSqZjPtf0JjWAzAokFeC1Qo3Xjl7eC74KCE2qMGZ5S2hZzWnpbD(cj1pWnbdIDiR9XCgIPy0ltHMk(qVgL5jpghmi2HSsq6TilKBmPsKk2bWwaAw)SR6J5ehfWxa66CrqCqBWsaoIbMuBsXSa9ycSljCJ)ownrWuHMkBe70ZYob3EFmNb38e05lKu)a3eg2S2EFmNHo3nKAYh)llmSzvJqCdIDyWnpbD(cj1pWnHNI9fIJInGVaey116JEz19OHLgUS6(bNQdnRlBgX9DUKPUypBW11joIDjBDYFmv3e91j)ab1gzQt)BYsDOSHE2xmvh7B2uhqT1QZZ6aPnjQdNUguCDOVo2AtI6yFZM6CogvNCCeYu3Woua66CrqCqBWsaoIbMuBsXSa9ycSJBS6qcRExsOxPrVZzzNGnuFmNH3Le6vA07CLH6J5myqSdLk1q9XCg0iOzOZ1kPwiOkd1hZzyyZA6VfkdnKZZMGToJsYbH10FlugAiNNnbBD2cyjVnPsB3q9XCg0iOzOZ1kPwiOkd1hZzyyZkqmuFmNH3Le6vA07CLH6J5mGtxdAlGbPnaGT2aogQpMZqNJqgfAQYgsrqkwwyylv6CT0KQNI9fIJcO0gazTpMZGBEc68fsQFGBcpf7le3cBYxbiWQtEPPp4zDtNZ7Ug06MOVUb27CQUnPyCOa015IG4G2GLaCedmP2KIXSStW9XCg6CeYWh4m8KRtPsNRLMu9uSVqCuGbPnPs1O4oszJwyIdgAU6nJcmifGfGaRUwngtqnHlaDDUiioqymb1egSgb1emFpjJAY9yILDcMG0Brwi3ysLivSdGTWgRT3hZzOZDdPM8X)YcdBwbs7gug0iOMG57jzutUhtQ(4HHC1GUqlS2URZfbdAeutW89KmQj3JPWcvt(APjLkDo4C1t6g)TqQCJPOSOnHyhabybORZfbXbcJjOMWsaoIohHmk0uLnKIGuSmw2jyR(VENtHo3nKAYh)ltHLb1SQriUbXom0PKDIGQSHuKmchg2SA1)17Ck0tsPrqZMlcYkqW2eNRs)Tqjo05UHut(4FzTagePsFFnkYkbZGBm4WcBbObEakv6CT0KQNI9fIJcmBTva66CrqCGWycQjSeGJWYWFZ6qfAQCjrpkBkaDDUiioqymb1ewcWrmr6bMmkxs0VjP6KhZYobJTjoxL(BHsCOZDdPM8X)YAbmisL((AuKvcMb3yWHf2cqPnwBVpMZGBEc68fsQFGBcdBPsNRLMu9uSVqCuS1wbORZfbXbcJjOMWsaoc7XVtzl0IQZDCYYobJTjoxL(BHsCOZDdPM8X)YAbmisL((AuKvcMb3yWHf2cqPnPsNRLMu9uSVqCuS1wbORZfbXbcJjOMWsaoISHudyhnGg1e9AILDcUpMZWtAq5egRMOxtHHTuP9XCgEsdkNWy1e9AsPrdysFaNUg0OyRTcqxNlcIdegtqnHLaCe)ABZj1cvyBxtfGUoxeehimMGAclb4iyh9CJvAHQNWiOd1ubORZfbXbcJjOMWsaoIykg9YuOPIp0RrzEYJXSStWeKElYIcOb(cqGvN8uiUPUwJC7fAPo5b3JjCDt0xhbGKEKuDVdTq1H(6aD5866J5eZsD7SoBegVDofQdOYz3LHRlFz1LO6SqzDzdvhhXoHZ60ie3Gyhwx3XKPoeSo3QVCVZP6iifVeoua66CrqCGWycQjSeGJ4j3EHwutUhtyw0Y0CsL(BHsmy2yzNGt)Tqzi3ysLiLzPOyla8sLceGK(BHYqd58SjyRZwKV2Kkn93cLHgY5ztWwNrbgK2aiRaX15ALueKIxcdMnPst)Tqzi3ysLiLzPwab4cGauQuGK(BHYqUXKkrkBDQaPTwK82yfiUoxRKIGu8syWSjvA6Vfkd5gtQePml1cqd0aeGfGfGaRo5XcxCd94cqGvNCzRUoKv6RR1s5Q7PhX546yFZM6KxYn4gugbqvt1LVVjUo0xxRnYgoHX116EsV4fbdfGUoxeehMlCXnG7uYorqv2qksgHzzNGT6)6Dof6jP0iOzZfblaDDUiiomx4IBKaCey(QjLdnkZQjw2j4(yody(QjLdnkZQPWtX(cXrnxlnP6PyFHyw7J5mG5RMuo0OmRMcpf7lehfqytcnkUJu2OfMyacCyliFfGUoxeehMlCXnsaoIhX5QSHuDeKWSStW9XCgEeNRYgs1rqchEk2xiokWsUuPw9F9oNcF2vp9ioVaey1jx2QRJ9nBQlBO6aQAQo5VDDTEqJVogorwP6qFDYl5gCdkRlFFtCOa015IG4WCHlUrcWr0PKDIGQSHuKmcZYob7sI(nPGRj1WwjdnEfMtKvkqqVZjJuPUKOFtkyi3GBqzGGENtMcqxNlcIdZfU4gjahHzX2EQBkalabwDmj58SPa015IG4aojNNnG1nKBRWnOKfTmnNuP)wOedMnw2j405emd2pjtHGQSHuStoObc6DozyT90FlugwSQJW4cqxNlcId4KCE2ib4i84(a3iySspErqr0G0giT1gqZwBcg29hUqlybJ8tSn6tYuhWDDUoxeSo(ItCOauWWxCIfrkyimMGAclIuenBIifme07CYiKtWO)nPFDbdbP3ISqUXKkrQyhaRRL6yRowRR966J5m05UHut(4FzHHDDSwhqQR96mOmOrqnbZ3tYOMCpMu9Xdd5QbDHwQJ16AVoxNlcg0iOMG57jzutUhtHfQM81stwNuP1nhCU6jDJ)wivUXuDrvNfTje7ayDauW46CrqbJgb1emFpjJAY9ysKIObrePGHGENtgHCcg9Vj9RlyS6)6Dof6C3qQjF8VmfwguxhR1PriUbXom0PKDIGQSHuKmchg21XADw9F9oNc9KuAe0S5IG1XADaPoSnX5Q0FluIdDUBi1Kp(xwDTaUoqQtQ06EFnkYkbZGBm4WcRRL6aAGVoawNuP1nxlnP6PyFH46IcCDS1MGX15IGcMohHmk0uLnKIGuSmrkIwYfrkyCDUiOGXYWFZ6qfAQCjrpkBeme07CYiKtKIObArKcgc6DozeYjy0)M0VUGbBtCUk93cL4qN7gsn5J)LvxlGRdK6KkTU3xJISsWm4gdoSW6APoGsB1XADTxxFmNb38e05lKu)a3eg21jvADZ1stQEk2xiUUOQJT2emUoxeuWmr6bMmkxs0VjP6Khlsr0aVisbdb9oNmc5em6Ft6xxWGTjoxL(BHsCOZDdPM8X)YQRfW1bsDsLw37RrrwjygCJbhwyDTuhqPT6KkTU5APjvpf7lexxu1XwBcgxNlckySh)oLTqlQo3XPifrduerkyiO35KriNGr)Bs)6cM(yodpPbLtySAIEnfg21jvAD9XCgEsdkNWy1e9AsPrdysFaNUg06IQo2AtW46Crqbt2qQbSJgqJAIEnjsr0a3IifmUoxeuW8RTnNuluHTDnjyiO35KriNifrlFIifmUoxeuWWo65gR0cvpHrqhQjbdb9oNmc5ePiAGlrKcgc6DozeYjy0)M0VUGHG0BrwDrvhqd8cgxNlckyIPy0ltHMk(qVgL5jpglsr0S1Misbdb9oNmc5emUoxeuW8KBVqlQj3JjSGr)Bs)6cM0FlugYnMujszwQUOQJTaWxNuP1bK6asDP)wOm0qopBc26SUwQt(ARoPsRl93cLHgY5ztWwN1ff46aPT6ayDSwhqQZ15ALueKIxcxh46yRoPsRl93cLHCJjvIuMLQRL6ab4QoawhaRtQ06asDP)wOmKBmPsKYwNkqARUwQtYBRowRdi156CTskcsXlHRdCDSvNuP1L(BHYqUXKkrkZs11sDanqxhaRdGcgTmnNuP)wOelIMnrksbJHM(GNIifrZMisbdb9oNmc5em6Ft6xxW0ED4KCE2qMWJSmibJRZfbfmGUAqfPiAqerkyCDUiOGbNKZZgbdb9oNmc5ePiAjxePGHGENtgHCcgKTGbtPGX15IGcgR(VENtcgRoFqcgnkUJu2OfM4GHMREZ6AbCDGuNe1bsDaN6asDPZjygS0GWjxMcN)ckfiO35KPowRtJqCdIDyWsdcNCzkC(lOu4PyFH46IQo2QdG1jrD9XCg6pYn41qHHDDSwhbP3IS6APoGsB1XADTxxFmNbmOdox5qJs)imUJGeomSRJ16AVU(yodGsKTsgA8k23eR8oAKkzOryylyS6Vc6XKGXJ7dCJsJGMnxeuKIObArKcgc6DozeYjyq2cgmLcgxNlckyS6)6DojyS68bjy6J5m8JSHtySY(j9IxemmSRtQ06asDUKOFtkyi3GBqzGGENtM6KkToxs0VjfCnPg2kzOXRWCISsbc6DozQdG1XAD9XCgEeNRYgs1rqchg2cgR(RGEmjy6jP0iOzZfbfPiAGxePGHGENtgHCcgKTGbtPGX15IGcgR(VENtcgRoFqcgSnX5Q0FluIdDUBi1Kp(xwDrvhi1XADVVgfzLGzWngCyH11sDG0wDsLwxFmNHo3nKAYh)llmSfmw9xb9ysW05UHut(4FzkSmOwKIObkIifme07CYiKtWO)nPFDbdojNNnKj4CUGX15IGcgTZ5kxNlcQ4lofm8fNkOhtcgCsopBePiAGBrKcgc6DozeYjyCDUiOGr7CUY15IGk(ItbdFXPc6XKGrBWIueT8jIuWqqVZjJqobJ(3K(1fmAuChPSrlmX11c4602QyhavyBcAQdaQdi11hZzO)i3Gxdfg21jrD9XCgq22OphWnLfg21bW6ao1bK6sNtWm0khRguL5D2de07CYuhR1bK6AVU05emdX(dkzut0RmKNnbc6DozQtQ060ie3GyhgI9huYOMOxzipBcpf7lexxl1XwDaSoawhWPoGuNlj63KcUMudBLm04vyorwPW7qqRlQ6aPoPsRR960ie3Gyhg6uYorqv2qksgHdd76KkTU2RRpMZWJ4Cv2qQocs4WWUoakyCDUiOG5hqLRZfbv8fNcg(Itf0JjbZCHlUrKIObUerkyiO35KriNGX15IGcgTZ5kxNlcQ4lofm8fNkOhtcM(y5grkIMT2erkyiO35KriNGr)Bs)6cgcsVfzbdnx9M11c46yd4RtI6ii9wKfEYcbfmUoxeuW4V2HKkr)tWuKIOzJnrKcgxNlcky8x7qszp4ysWqqVZjJqorkIMnqerkyCDUiOGHVwAsSQ17WyjMGPGHGENtgHCIuenBsUisbJRZfbfmD3Icnv5VAqXcgc6DozeYjsrkySFsJI7EkIuenBIifme07CYiKtWGSfmykfmUoxeuWy1)17CsWy15dsW4z6Aqv6FZ6APU2canicgR(RGEmjyqwPx92k9VPkBEc3G4grkIgerKcgxNlckySr5IGcgc6DozeYjsr0sUisbdb9oNmc5emUoxeuWe7pOKrnrVYqE2iy0)M0VUG591OiRemdUXGdlSUwQdOBtWy)Kgf39uHjncAWcgGxKIObArKcgc6DozeYjy0)M0VUGbi11EDuRCS22KjyJ0GsjELezuAuS9i9CrqLHSUAQoPsRR960ie3Gyhg0Y0Cu(i4QvDUJZGz8EUiyDsLw37RrrwjygwO1bhsV35uGaWfN46aOGX15IGcgCsopBePiAGxePGHGENtgHCcgKTGbtPGX15IGcgR(VENtcgRoFqcMp7Q(yoX1fvDGuhR11ED9XCgS8o0OIjorHHDDSwx711hZz4hzdNWyL9t6fViyyylyS6Vc6XKG5ZU6PhX5IuenqrePGHGENtgHCcgKTGbtPGX15IGcgR(VENtcgRoFqcMp7Q(yoX1fvDGuhR1bK66J5mWrUHmkZQPWWUoPsRR966J5m0FKBWRHcd76aOGr)Bs)6cgxs0VjfmKBWnOmqqVZjtDsLwNv)xVZPaYk9Q3wP)nvzZt4ge3iyS6Vc6XKG5ZU6PhX5IuenWTisbdb9oNmc5emiBbdMsbJRZfbfmw9F9oNemwD(GemF2v9XCIRlQ6aPowRdi11hZzGJCdzuMvtHHDDsLwxFmNHFKnCcJv2pPx8IGHNI9fIRlkW1PriUbXom0PKDIGQSHuKmchEk2xiUoaky0)M0VUGXLe9BsbxtQHTsgA8kmNiRuGGENtM6yToxs0VjfCnPg2kzOXRWCISsH3HGwxlGRZLe9Bsbd5gCdkdVdbTowRR96S6)6DofqwPx92k9VPkBEc3G4gbJv)vqpMemF2vp9ioxKIOLprKcgc6DozeYjyq2cgmLcgxNlckyS6)6DojyS68bjy(SR6J5exxu1bIGr)Bs)6cgxs0VjfWqhusrYiC4DiO11c46arWy1Ff0JjbZND1tpIZfPiAGlrKcgc6DozeYjyq2cMNWukyCDUiOGXQ)R35KGXQ)kOhtcMp7QNEeNly0)M0VUGXLe9Bsbm0bLuKmchEhcADTaUoqQJ166J5mGHoOKIKr4aoDnO11c46aPoaOU(yod9h5g8AOWWwKIOzRnrKcgc6DozeYjyq2cgmLcgxNlckyS6)6DojyS68bjy(SR6J5exhauxFmNbmOdox5qJs)imUJGeomSRlQ6aPowRdi11hZzGJCdzuMvtHHDDsLwx711hZzWY7qJkM4efg21XADTxxFmNHFKnCcJv2pPx8IGHHDDSwx711hZzO)i3Gxdfg21bqbJ(3K(1fm9XCg6C3qQjF8VSWWwWy1Ff0JjbZND1tpIZfPiA2ytePGHGENtgHCcgKTGbtPGX15IGcgR(VENtcgRoFqcgGu3NDvFmN46aG66J5m0h)sgv(KJhpfg21bW6IQoqQtQ066J5m8ioxLnKQJGeo8uSVqCDrvhBTfKV6KOoGuhBb5RoGtDPZjygmeztVcNVNUfkoqqVZjtDauWO)nPFDbtFmNboYnKrzwnfg2cgR(RGEmjy(SRE6rCUifrZgiIifme07CYiKtW46CrqbZJ4Cv2qQocsybJ(3K(1fm9XCgEeNRYgs1rqchEk2xiUUOaxNKxNuP1z1)17Ck8zx90J4CbJ9tAuC3tfM0iOblyarKIOztYfrkyiO35KriNGX15IGcgmF1KYHgLz1KGr)Bs)6cM(yody(QjLdnkZQPWtX(cX1fvD5gtQePmlvhR11hZzaZxnPCOrzwnfEk2xiUUOQdi1XwDsuNgf3rkB0ctCDaSoGtDSfKpbJ9tAuC3tfM0iOblyarKIOzdOfrkyiO35KriNGX15IGcg38e05lKu)a3iy0)M0VUGbi11EDuRCS22KjyJ0GsjELezuAuS9i9CrqLHSUAQoPsRR960ie3Gyhg0Y0Cu(i4QvDUJZGz8EUiyDsLw37RrrwjygwO1bhsV35uGaWfN46aOGX(jnkU7PctAe0GfmSjsr0Sb8Iifme07CYiKtWa9ysW4sc34VJvtemvOPYgXo9cgxNlckyCjHB83XQjcMk0uzJyNErkIMnGIisbdb9oNmc5emUoxeuWOLP5O8rWvR6ChNcg9Vj9RlyAVU3xJISsWmSqRdoKEVZPabGloXcgAojDQGEmjy0Y0Cu(i4QvDUJtrksbtFSCJisr0SjIuWqqVZjJqobJ(3K(1fmaPU05emdTYXQbvzEN9ab9oNm1jvADUKOFtkakr2kzOXRyFtSY7OrQKHgH3HGwxu1bsDaSowRRpMZaY2g95aUPSWWUowRdi11hZzauISvYqJxX(MyL3rJujdnc401Gwxu1XgqxNuP1rq6TiRUOQdOb(6aOGX15IGcg7fNiUc3GsrkIgerKcgc6DozeYjy0)M0VUGPpMZaY2g95aUPSWWUowRRpMZGHCdUbLHHTGX15IGcg7fNiUc3GsrkIwYfrkyCDUiOGbVWfN0RW5VGscgc6DozeYjsrkyWj58SrePiA2erkyiO35KriNGX15IGcgDd52kCdkfm6Ft6xxWKoNGzW(jzkeuLnKIDYbnqqVZjtDSwx71L(BHYWIvDegly0Y0CsL(BHsSiA2ePiAqerkyCDUiOGXJ7dCJGHGENtgHCIuKcgTblIuenBIifme07CYiKtWO)nPFDbt71HtY5zdzcoNlyCDUiOGr7CUY15IGk(ItbdFXPc6XKGHWycQjSifrdIisbdb9oNmc5em6Ft6xxW0ED9XCgCZtqNVqs9dCtyyxhR1bK6AVoQvowBBYeCjHB83XQjcMk0uzJyN(6KkToncXni2HbUNemv(RDOhEk2xiUUwQdK2QdGcgxNlckyCZtqNVqs9dCJifrl5Iifme07CYiKtW46CrqbtS)Gsg1e9kd5zJGr)Bs)6cM3xJISsWm4gdomSRJ16asDP)wOmKBmPsKYSuDrvNgf3rkB0ctCWqZvVzDsLwx71HtY5zdzcpYYGQJ160O4oszJwyIdgAU6nRRfW1PTvXoaQW2e0uhauhB1bqbJwMMtQ0FluIfrZMifrd0Iifme07CYiKtWO)nPFDbZ7RrrwjygCJbhwyDTuNK3wDaqDVVgfzLGzWngCWmEpxeSowRR96Wj58SHmHhzzq1XADAuChPSrlmXbdnx9M11c4602QyhavyBcAQdaQJnbJRZfbfmX(dkzut0RmKNnIuenWlIuWqqVZjJqobJ(3K(1fmyBIZvP)wOexxlGRdK6yTU2RRpMZqN7gsn5J)Lfg21XADaPU2R791OiRemdUXGdeaU4exNuP19(AuKvcMb3yWHNI9fIRRL6KV6KkTU3xJISsWm4gdoSW6APoGuhi1ba1PriUbXom05UHut(4FzbDJ)wiSA(Uoxe051bW6ao1bcWxhafmUoxeuW05UHut(4FzIuenqrePGHGENtgHCcg9Vj9Rly0O4oszJwyIdgAU6nRRfW1XwDsuxFmNH(JCdEnuyylyCDUiOGXsdcNCzkC(lOKifrdClIuWqqVZjJqobJ(3K(1fmw9F9oNcDUBi1Kp(xMcldQRJ16W2eNRs)Tqjo05UHut(4Fz11sDSvhR1rq6TilKBmPsKk2bW6APoqemUoxeuWa6Y5l0IcB)ejsr0YNisbdb9oNmc5em6Ft6xxWy1)17Ck05UHut(4FzkSmOUowRJG0Brwi3ysLivSdG11sDGiyCDUiOGPZDdP(bUrKIObUerkyiO35KriNGr)Bs)6cM2RdNKZZgYeCoVowRZQ)R35uWJ7dCJsJGMnxeuW46CrqbJvhU4grkIMT2erkyiO35KriNGr)Bs)6cM2RdNKZZgYeCoVowRZQ)R35uWJ7dCJsJGMnxeuW46CrqbdUXni2JjUrKIOzJnrKcgc6DozeYjy0)M0VUGPpMZqNJqg(aNHNCDwNuP11hZzWnpbD(cj1pWnHHTGX15IGcgBuUiOifrZgiIifme07CYiKtW46CrqbJv)xVZj1ctcI3uMYYAXTI4PcH1lN75cTOEY1j6fm6Ft6xxW0hZzOZridFGZWtUoRtQ06YnMujszwQUOaxhiTvNuP1PrXDKYgTWehm0C1BwxuGRdebd0JjbJv)xVZj1ctcI3uMYYAXTI4PcH1lN75cTOEY1j6fPiA2KCrKcgc6DozeYjy0)M0VUGPpMZqNJqg(aNHNCDwNuP1LBmPsKYSuDrbUoqARoPsRtJI7iLnAHjoyO5Q3SUOaxhicgxNlckygysTjfJfPiA2aArKcgxNlcky6CeYOMJxMGHGENtgHCIuenBaVisbJRZfbfmD6X0d6cTiyiO35KriNifrZgqrePGX15IGcM5(uNJqgbdb9oNmc5ePiA2aUfrkyCDUiOGXHAcNVZvANZfme07CYiKtKIOzt(erkyiO35KriNGX15IGcgTmnhLpcUAvN74uWO)nPFDbt71HtY5zdzcoNxhR11hZzWnpbD(cj1pWnbdIDyDSwxFmNHykg9YuOPIp0RrzEYJXbdIDyDSwhbP3ISqUXKkrQyhaRRL6a66yTUp7Q(yoX1fvDaVGHMtsNkOhtcgTmnhLpcUAvN74uKIOzd4sePGHGENtgHCcgxNlckyCjHB83XQjcMk0uzJyNEbJ(3K(1fmTxxFmNb38e05lKu)a3eg21XADTxxFmNHo3nKAYh)llmSRJ160ie3GyhgCZtqNVqs9dCt4PyFH46IQo2aEbd0JjbJljCJ)ownrWuHMkBe70lsr0G0Misbdb9oNmc5emUoxeuW44gRoKWQ3Le6vA07CbJ(3K(1fmgQpMZW7sc9kn6DUYq9XCgmi2H1jvADgQpMZGgbndDUwj1cbvzO(yodd76yTU0FlugAiNNnbBDwxu1j5GuhR1L(BHYqd58SjyRZ6AbCDsEB1jvADTxNH6J5mOrqZqNRvsTqqvgQpMZWWUowRdi1zO(yodVlj0R0O35kd1hZzaNUg06AbCDG0wDaqDS1wDaN6muFmNHohHmk0uLnKIGuSSWWUoPsRBUwAs1tX(cX1fvDaL2QdG1XAD9XCgCZtqNVqs9dCt4PyFH46APo2Kpbd0JjbJJBS6qcRExsOxPrVZfPiAqytePGHGENtgHCcg9Vj9Rly6J5m05iKHpWz4jxN1jvADZ1stQEk2xiUUOaxhiTvNuP1PrXDKYgTWehm0C1BwxuGRdebJRZfbfmdmP2KIXIuKcM5cxCJisr0SjIuWqqVZjJqobJ(3K(1fmw9F9oNc9KuAe0S5IGcgxNlcky6uYorqv2qksgHfPiAqerkyiO35KriNGr)Bs)6cM(yody(QjLdnkZQPWtX(cX1fvDZ1stQEk2xiUowRRpMZaMVAs5qJYSAk8uSVqCDrvhqQJT6KOonkUJu2OfM46ayDaN6yliFcgxNlckyW8vtkhAuMvtIueTKlIuWqqVZjJqobJ(3K(1fm9XCgEeNRYgs1rqchEk2xiUUOaxNKxNuP1z1)17Ck8zx90J4CbJRZfbfmpIZvzdP6iiHfPiAGwePGHGENtgHCcg9Vj9RlyCjr)MuW1KAyRKHgVcZjYkfiO35KPoPsRZLe9Bsbd5gCdkde07CYiyCDUiOGPtj7ebvzdPizewKIObErKcgxNlckyml22tDJGHGENtgHCIuKIuW4JSb9cgMnUvjsrkea]] )


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