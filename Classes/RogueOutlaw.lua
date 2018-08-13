-- RogueOutlaw.lua
-- June 2018
-- Contributed by Alkena.

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State


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
            id = 240837,
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
            local auras = stealth[ k ]
            if not auras then return false end

            for _, aura in pairs( auras ) do
                if state.buff[ aura ].up then return true end
            end

            return false
        end,
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

        if a and a.startsCombat then
            removeBuff( "stealth" )
            removeBuff( "shadowmeld" )
            setCooldown( "stealth", 2 )

            if level < 116 and equipped.mantle_of_the_master_assassin then
                applyBuff( "master_assassins_initiative", 5 )
            end
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
            
            handler = function ()
                applyBuff( 'adrenaline_rush', 20 )
                removeBuff( "vanish" )
                removeBuff( "stealth" )
                removeBuff( "shadowmeld" )
                if talent.loaded_dice.enabled then
                    applyBuff( 'loaded_dice', 45 )
                    return
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
                removeBuff( 'stealth' )
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
                    applyDebuff( 'target', 'prey_on_the_weak', 6)
                    return
                end

                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                applyDebuff( 'target', 'between_the_eyes', combo_points.current ) 
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
            
            usable = function () return buff.blade_flurry.remains < gcd end,
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
            
            toggle = 'interrupt', 

            startsCombat = true,
            texture = 132219,
            
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
            
            notalent= 'slice_and_dice',

            spend = 25,
            spendType = "energy",
            
            startsCombat = false,
            texture = 1373910,
            
            usable = function ()
                if buff.rtb_buff_1.up then return false end -- don't recommend if we don't know what buff(s) we actually have.
                if time == 0 and not ( rtb_buffs < 2 and ( buff.loaded_dice.up or buff.grand_melee.down and buff.ruthless_precision.down ) ) then return false end

                return combo_points.current > 0
            end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                for _, name in pairs( rtb_buff_list ) do
                    removeBuff( name )
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
            
            usable = function() return combo_points.current > 0 end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyBuff( "slice_and_dice", 12 + 6 * ( combo - 1 ) )
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

            usable = function () return not buff.stealth.up and not buff.vanish.up end,            
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

    
    spec:RegisterPack( "Outlaw", 20180728.1615, [[davCJaqisOEesqBcPQpPivzukkDkffRIeKxPKAwuuUfsGDjQFHuzyifoMsyzKepdPiMMIeUgjL2gsr9nsqnofPCoKq06qcL3PivQ5rc5EiP9rs6GiHQfIe9qfjPjscuxeje2OIuXhvKOCssaTsfXmvKk5MksuTtKs)KeidvrsCufjclvrs9uatvj5QiHKTQirQVIesnwfjsoRIer7fQ)kYGv5WuTyfEmPMmrxg1Mb6ZuKrtjNwYQvKQ61KunBc3Mc7wv)gYWPuhhPiTCqphX0fUUsTDLOVtr14jP48KO1tcW8vuTFPgVaVcdi9GX0QcnwmnAOWQmT8cAEHcpfkmgiuAZyaBxRUBIXaVBWyaf0oeU5yaBxPa5s8kmabTHAgdyfHnHIrhDMQWApYAKbDKYyl8OqVg6GbDKYqt3qGg0naDkqYlPZgIalbtOBvXqvwq3kvwKMAKPnNuq7q4MNjLHgdm2LiuGpEGbKEWyAvHglMgnuyvMwEbnVqHvzAyaInRX0QcntdmGKjAmWkRI0xr6lS4(KmOVfrFuCDuOVVPIRvVpqeSpf0oeU59n1itBM0x99rPhHG7deb7JIRayikSY9KEIcm6Ri9nCcl7d99fwCFI6vNL9zdrGLG7Z8kS6ZOEeSpxo93KWG)G0NHl5CpPNSYI7Z3bsJ(LmmyyFMxcrFLHncg9fwfPpBicSeCF1RrqiRdHYP7(uG9zoAlK99OOpixg2iy03(Js0xyX9vg2iyWW(ksFBBPhSmJbSHiWsWyakSpkc1W6DWY(gmicY9Prgdp6BWMQNK7JIR1SDq67rpfy5qdWTOpxhf6j9HEHYCpX1rHEs2gYAKXWdQGcNOEpX1rHEs2gYAKXWJ1uPZ3Mm4p8OqFpX1rHEs2gYAKXWJ1uPdeHK9ekSpG3TjwOOpOxY(gBqqw2hj8G03GbrqUpnYy4rFd2u9K(8x2NnKPaBue1BQVI0Ne9CUN46OqpjBdznYy4XAQ0rE3MyHIej8G0tCDuONKTHSgzm8ynv6ib7IWQN46OqpjBdznYy4XAQ0zJIc99exhf6jzBiRrgdpwtLodhQoltGiysYEyzMnK1iJHhjcRrVKqvTMvGuHEjt8s(JSlLKC9Qof0ON46OqpjBdznYy4XAQ0brcrkS40a9mXmBiRrgdpsewJEjHQk9exhf6jzBiRrgdpwtLoIO0CYFzswA2mBiRrgdpsewJEjHQk9exhf6jzBiRrgdpwtLoxc53f1Zj4MyzMnK1iJHhjcRrVKqDrpPNqH9rrOgwVdw2hVKHk7lkdUVWI7Z1bc2xr6Zx6LWhco3tCDuONqv9sREpHc7BQzisi6deb7tL19n2GGK(mVcR(MUqUKL9PGln332o3NckSyO5fH7dYqKq0hic2NkR7db7Bkd6VSVPCwWCFiyFt9oSemH03ubY6IuOp3tCDuONSMkDlDy5dbB27gmvymsqgIecZw6IntfgJ0ydcsuKk0p7ydcMfixYYKS0CEBpFUIhBqWSjO)YKblyoVTPxXJniygUdlbtijBiRlsH(82EMEIRJc9K1uPBPdlFiyZE3GP6gJnXkPrVSIc9MT0fBMQgzmqjBu9bjlzWsxHQuvzTkk0SHl4pYMSqKqOmrcyPoN53hcwsVgHesK5F2KfIecLjsal15mKn86jkAXmRhBqW8aICjPKCEBtp)m0KsvPzAqVIhBqWmr9TqK8xM0qeHmqptYB7Ecf2hfDfw9zSfrzl4(chAIdIz9fwfPVLoS8HG7Ri9PTyT6SSVa1NK1LK7ZCloSyyFeKb33uvbt6JyH2czFdUpIYxZY(mVcR(Ou4sUVPJydHk7jUok0twtLULoS8HGn7DdM6q4sobk2qOYer5RnBPl2mvInlePWHM4GKhcxYjqXgcvQivOh6LmXl5pYUusY1RQk0y(8XgempeUKtGIneQmVT7jUok0twtLoTlejxhf6tIIeM9UbtLeSlclZkqQKGDryXYSle9exhf6jRPsN2fIKRJc9jrrcZE3GPQLKEcf230P(Iy1Nh9z4QPm2g9nvNk5(a2dsaDD0h65(arW(yxB1hLqKljLK7ZFzFkiBBem2Ffk7ZCl(7BkXU0Q3Ncg6M3xr6JWcwhSSp)L9nLdQG7Ri99OOpi7sL95Gbd7lS4(EwnrFewJEzUN46Oqpznv60UqKCDuOpjksy27gmvW6lILzfivnYyGs2O6dIQu12jdxnjIn)sky2XgempGixskjN32RhBqWmY2gbJ9xHY82EgfA2Wf8hzA6U0QNKq38m)(qWs6NvXHl4pYgouDwMarWKK9WkZVpeSC(CncjKiZ)SHdvNLjqemjzpSYq2WRNO6IzMPN46Oqpznv60UqKCDuOpjksy27gm1XUeYEIRJc9K1uPZHA)5uGGq(dZkqQ8ZqtkZsgS0vOk1fQDn)m0KYmKnXFpX1rHEYAQ05qT)CYEliCpX1rHEYAQ0jktwbjn93stg8h9KEcf2hL7siziPN46Oqpjp2Lqs1UibsKiwOWScKQgzmqjBu9bjlzWsxHQuxSESbbZdiYLKsY5T96Wf8hzA6U0QNKq38m)(qWs6hBqWmY2gbJ9xHY82UN46Oqpjp2LqUMkDK6lsWWejGL6CpPNqH9nvriHez(t6jUok0tYAjHQnkk0BwbsDSbbZdbcjfBsKHSRJ5ZdhAIJCugCkqjzXkIkntJ5ZhBqWSlH87I65eCtSYB7EIRJc9KSwswtLUHaHKjWnuzpX1rHEswljRPs3GHegQE9M6jUok0tYAjznv6CjKFxupNGBILzfivfp2GGzxc53f1Zj4MyL320ZpdnPmhLbNcuYWvJQl6jUok0tYAjznv6mCO6SmbIGjj7HLzHdnXrQaPAupflCOjoYrzWPaLKfBwbsnCOjoYrzWPaLKfRinYyGs2O6dswYGLUI5ZNDwOxYeVK)i7sjjxVQtbnMpFSbbZbCZPb7W6nLHSHxpr1fQLcgBqWSlH87I65eCtSYBBfsTZqVIjb7IWILziY0MPxJmgOKnQ(GKLmyPRqvQA7KHRMeXMFjfSyMEcf2hLcxY9nDeBiuzFOVpvw3h)SrXKCFu0vy1NlLekwFuueUVcSVWIv2hjCL9bIG9nT19ryn6LK(qW(kW(uI2W(EwnrFAlhAI7Z8si6BW9bzxQSV67lkdUpqeSVWI77z1e9zUVKZ9exhf6jzTKSMkDdHl5eOydHknRaPsSzHifo0ehevPQc9kESbbZdHl5eOydHkZBB6NvXqVKjEj)r2LssMvtrcY85qVKjEj)r2LssgYgE9evN285AesirM)5HWLCcuSHqLzTLdnXeQlOh6LmXl5pYUusY1R6SQqbAesirM)5HWLCcuSHqLzTLdnXKei01rHExmJcPIANPN46OqpjRLK1uPZKfIecLjsal1zZkqQlDy5dbNhcxYjqXgcvMikFn9AKXaLSr1hKSKblDfQsDX6XgempGixskjN329exhf6jzTKSMkDQxcr9MseBiZMvGux6WYhcopeUKtGIneQmru(A6NLFgAszokdofOKHRgvv7858Zqtkv0c1otpX1rHEswljRPs3q4sob3elZkqQlDy5dbNhcxYjqXgcvMikFn98ZqtkZrzWPaLmC1O6IEcf2hffPEt9nL2)Iyrhf3ySjw9vK(qVqzFEFlzOY(I6v2x9Ai7e2S(iO(QVpi7IkuAwFkr7PhK7ZheKyhSqzFG1Z9fO(2eUVk6Zj959TJsuHY(i2SqK7jUok0tYAjznv6w6FrSmRaPQysWUiSyz2fc6x6WYhco7gJnXkPrVSIc99exhf6jzTKSMkDelxIm3GfsZkqQkMeSlclwMDHG(LoS8HGZUXytSsA0lROqFpPNqH9nDQViwmK0tCDuONKbRViwujIsZj)LjzPzZkqQJniyMiknN8xMKLMZq2WRNOOWHM4ihLbNcuswm9JniyMiknN8xMKLMZq2WRNOOzxSwJmgOKnQ(GmJcTipTEIRJc9Kmy9fXAnv6GiHifwCAGEMywbsD2XgemdrcrkS40a9mjdzdVEIIOstMpFPdlFi4mmgjidrcXm0pB4qtCKJYGtbkjlwvvOX85JniygIeIuyXPb6zsgYgE9effo0eh5Om4uGsYINPNqH9r5kkI(mVcR(clUVPEhwcMq6BQazDrk033ydc2hiez03uhu2hc2N5vy1xyX9rX1CFuu29nLeTH9biyEj3hc2NcMDjXcf9fqVcsUN46OqpjdwFrSwtLUbhMZ8NcloXkzIzfi1Xgemd3HLGjKKnK1fPqFEBpFURayyfC21CABNuI2WerW8soZVpeSC(CxbWWk4SKDjXcfz(9HGL9exhf6jzW6lI1AQ0jlIThAREspHc7diyxew9exhf6jzsWUiSO6gJnXcdSKHKc9yAvHglMgnu4fkCMgluzAyaZD4xVjcgGIMIp10QaPDkJI1xFRS4(kdBem6deb7B6PLKPxFqMMUlil7JGm4(8DGm8GL9PT83etY9KPR65(ulfRVPMnqlzzFg1tXMs1N2I1Q33Spk6Zx6LWhcUV67Jn2cpk0ptFuaf03SluZm5EsprbAyJGbl7JM7Z1rH((efji5EcgquKGGxHbKmOVfbEfM2f4vyaxhf6XaQxA1Xa87dblXuIdmTQGxHb43hcwIPedS0fBgdaJrASbbj9PO(uPp67B2(gBqWSa5swMKLMZB7(MpVpf33ydcMnb9xMmybZ5TDF03NI7BSbbZWDyjycjzdzDrk0N329ndgW1rHEmWshw(qWyGLom9UbJbGXibzisiWbMwAcEfgGFFiyjMsmWsxSzmGgzmqjBu9bjlzWsxrFQsTpv6BDFQ0Nc13S9fUG)iBYcrcHYejGL6CMFFiyzF03NgHesK5F2KfIecLjsal15mKn86j9PO(w03m9TUVXgempGixskjN329rFF8Zqtk7t1(OzA0h99P4(gBqWmr9TqK8xM0qeHmqptYBBmGRJc9yGLoS8HGXalDy6Ddgd4gJnXkPrVSIc94at7uGxHb43hcwIPedS0fBgdqSzHifo0ehK8q4sobk2qOY(uuFQ0h99b9sM4L8hzxkj567t1(uHg9nFEFJniyEiCjNafBiuzEBJbCDuOhdS0HLpemgyPdtVBWyGHWLCcuSHqLjIYxJdmTQfVcdWVpeSetjgqdRGHLJbib7IWILzxiWaUok0Jb0UqKCDuOpjksGbefjsVBWyasWUiSWbMwAgVcdWVpeSetjgW1rHEmG2fIKRJc9jrrcmGOir6DdgdOLeCGPvHXRWa87dblXuIb0Wkyy5yanYyGs2O6dsFQsTpTDYWvtIyZVSpkOVz7BSbbZdiYLKsY5TDFR7BSbbZiBBem2FfkZB7(MPpfQVz7lCb)rMMUlT6jj0npZVpeSSp67B2(uCFHl4pYgouDwMarWKK9WkZVpeSSV5Z7tJqcjY8pB4q1zzcebts2dRmKn86j9PAFl6BM(Mbd46Oqpgq7crY1rH(KOibgquKi9UbJbaRViw4at70WRWa87dblXuIbCDuOhdODHi56OqFsuKadiksKE3GXaJDjK4atlfjEfgGFFiyjMsmGgwbdlhdWpdnPmlzWsxrFQsTVfQTV19XpdnPmdzt8JbCDuOhd4qT)Ckqqi)boW0UGg4vyaxhf6Xaou7pNS3ccJb43hcwIPehyAxSaVcd46OqpgquMScsA6VLMm4pWa87dblXuIdCGbSHSgzm8aVct7c8kma)(qWsmL4atRk4vya(9HGLykXbMwAcEfgGFFiyjMsCGPDkWRWa87dblXuIdmTQfVcd46OqpgGeSlclma)(qWsmL4atlnJxHbCDuOhdyJIc9ya(9HGLykXbMwfgVcdWVpeSetjgW1rHEmGHdvNLjqemjzpSWaAyfmSCma0lzIxYFKDPKKRVpv7BkObgWgYAKXWJeH1OxsWaQfhyANgEfgGFFiyjMsmGRJc9yaisisHfNgONjyaBiRrgdpsewJEjbdOcoW0srIxHb43hcwIPed46OqpgGiknN8xMKLMXa2qwJmgEKiSg9scgqfCGPDbnWRWa87dblXuIbCDuOhd4si)UOEob3elmGnK1iJHhjcRrVKGbwGdCGbg7siXRW0UaVcdWVpeSetjgqdRGHLJb0iJbkzJQpizjdw6k6tvQ9TOV19n2GG5be5ssj582UV19fUG)itt3Lw9Ke6MN53hcw2h99n2GGzKTncg7VcL5TngW1rHEmGDrcKirSqboW0QcEfgW1rHEmaP(IemmrcyPoJb43hcwIPeh4adqc2fHfEfM2f4vyaxhf6XaUXytSWa87dblXuIdCGb0scEfM2f4vya(9HGLykXaAyfmSCmWydcMhcesk2Kidzxh9nFEFHdnXrokdofOKS4(ue1(OzA03859n2GGzxc53f1Zj4MyL32yaxhf6Xa2OOqpoW0QcEfgW1rHEmWqGqYe4gQedWVpeSetjoW0stWRWaUok0JbgmKWq1R3egGFFiyjMsCGPDkWRWa87dblXuIb0Wkyy5yaf33ydcMDjKFxupNGBIvEB3h99XpdnPmhLbNcuYWvtFQ23cmGRJc9yaxc53f1Zj4MyHdmTQfVcdWVpeSetjgW1rHEmGHdvNLjqemjzpSWaAyfmSCmq4qtCKJYGtbkjlUpf1NgzmqjBu9bjlzWsxrFZN33S9nBFqVKjEj)r2LssU((uTVPGg9nFEFJniyoGBonyhwVPmKn86j9PAFluBFuqFJniy2Lq(Dr9CcUjw5TDFkuFQTVz6J((uCFKGDryXYmezAZ9rFFAKXaLSr1hKSKblDf9Pk1(02jdxnjIn)Y(OG(w03myGWHM4ivGyGWHM4ihLbNcuswmoW0sZ4vya(9HGLykXaAyfmSCmaXMfIu4qtCq6tvQ9PsF03NI7BSbbZdHl5eOydHkZB7(OVVz7tX9b9sM4L8hzxkjzwnfji9nFEFqVKjEj)r2LssgYgE9K(uTVP13859PriHez(NhcxYjqXgcvM1wo0et6JAFl6J((GEjt8s(JSlLKC99PAFZ2Nk9rb9PriHez(NhcxYjqXgcvM1wo0etsGqxhf6DrFZ0Nc1NkQTVzWaUok0JbgcxYjqXgcvIdmTkmEfgGFFiyjMsmGgwbdlhdS0HLpeCEiCjNafBiuzIO819rFFAKXaLSr1hKSKblDf9Pk1(w036(gBqW8aICjPKCEBJbCDuOhdyYcrcHYejGL6moW0on8kma)(qWsmLyanScgwogyPdlFi48q4sobk2qOYer5R7J((MTp(zOjL5Om4uGsgUA6t1(uBFZN3h)m0KY(uuFluBFZGbCDuOhdOEje1BkrSHmJdmTuK4vya(9HGLykXaAyfmSCmWshw(qW5HWLCcuSHqLjIYx3h99XpdnPmhLbNcuYWvtFQ23cmGRJc9yGHWLCcUjw4at7cAGxHb43hcwIPedOHvWWYXakUpsWUiSyz2fI(OVVLoS8HGZUXytSsA0lROqpgW1rHEmWs)lIfoW0UybEfgGFFiyjMsmGgwbdlhdO4(ib7IWILzxi6J((w6WYhco7gJnXkPrVSIc9yaxhf6XaelxIm3GfsCGdmay9fXcVct7c8kma)(qWsmLyanScgwogySbbZerP5K)YKS0CgYgE9K(uuFHdnXrokdofOKS4(OVVXgemteLMt(ltYsZziB41t6tr9nBFl6BDFAKXaLSr1hK(MPpfQVf5PHbCDuOhdqeLMt(ltYsZ4atRk4vya(9HGLykXaAyfmSCmWS9n2GGzisisHfNgONjziB41t6tru7JM03859T0HLpeCggJeKHiHOVz6J((MTVWHM4ihLbNcuswCFQ2Nk0OV5Z7BSbbZqKqKclonqptYq2WRN0NI6lCOjoYrzWPaLKf33myaxhf6XaqKqKclonqptWbMwAcEfgGFFiyjMsmGgwbdlhdm2GGz4oSemHKSHSUif6ZB7(MpVpxbWWk4SR502oPeTHjIG5LCMFFiyzFZN3NRayyfCwYUKyHIm)(qWsmGRJc9yGbhMZ8NcloXkzcoW0of4vyaxhf6XaYIy7H2cdWVpeSetjoWboWa(oSqqmaqzmvXboWya]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = "Outlaw",
    } )

end