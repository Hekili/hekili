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

    
    spec:RegisterPack( "Outlaw", 20180819.1405, [[d8K7IaqisipsjL2esvFIKQsgLsQofsWQib8kLWSOs5wIQYUOQFHummKkoMKQLrs8msQY0qc11iHABKa9nKkLXjQQohsLQ1PKImpsq3djTpsshKkv1crIEivQutejKUisiAJkPGpssvrNKKQQwPOYljPQuZKKQkDtQuHDIu6NivsdLkvYrjPQWsPsvEQsnvLORQKIARKuvXxvsHCwLuO2lWFfzWGomLflXJj1Kj6YO2SQ6ZujJwuoTuRgjeEnjLzt42uXUv53qgUKCCQurlhQNJy6cxxv2UsY3fvz8Ku58KO1JujMVKY(vmOoyjylTGb0QcDQNF6K)60DFDkUoDt9upWouwXGDLPvZCXG9zomytxFHWYdSRmLcKjblbBc6H1myNfrfznrdnU6i7v8AKdnK25jSOrNgB)Ggs7OPPiqfAkFlFsEfnvy0VfmHMLnJvPonlvPEY9qUECIU(cHLNN0oAWU8ArO(FGcylTGb0QcDQNF6K)60DFDkMokMIPyWMuXAaTQOG0bSLmrd2lZAYaBYaJmEGs(Bprmq3xhn6gO7Y0QnWpcpq66lewEd09qUEmzG9nqkTie8a)i8aDF6cJrrMFYn5CFjfXJeo8fK10KlFd09yh0kEGHHDXrQ)d8Jrod0Dyy1y5a)i8aPOSfz(jx(gO7lLdu9DRvBGbAGs(Bprmqthn6gOOjHFYLVb6oqRy5a3bBIiBG2py8aDFjMpt0hpq37rY8GDfg9Bbd2RDGuKQJ1VGLdSWFeMhOg5uSyGf2vFe)aDFTMRcYap0LVmd78FIbA6OrhzGOtO0p5mD0OJ4RWSg5uSG6xye1MCMoA0r8vywJCkwSGkn2ZLdFHfn6MCMoA0r8vywJCkwSGknFeso5w7a3NvrYqXaXwlhy59)SCGKWcYal8hH5bQroflgyHD1hzG2jhyfMZxfkI(CnWMmqj6y)KZ0rJoIVcZAKtXIfuPHCwfjdfjsybzYz6OrhXxHznYPyXcQ0uHIgDtothn6i(kmRroflwqLghdRgltFeojzlYCRcZAKtXIeH1OtsOQy36pvS1YeVIVWBsjX3NQumDMCMoA0r8vywJCkwSGknyKqKImovqhtCRcZAKtXIeH1OtsOQYKZ0rJoIVcZAKtXIfuPHiAnNStMKTMDRcZAKtXIeH1OtsOQYKZ0rJoIVcZAKtXIfuPXKy(mrFCc)izUvHznYPyrIWA0jjuRp5mD0OJ4RWSg5uSybvAibBIiBYn5w7aPivhRFblhiVIXkhy0o8aJmEGMoq4b2KbARSwyfb7NCMoA0rOQwRvBYT2b6Emgjed8JWduLfdS8(FYaZRJSbQ(fzswoqkAR5b(Q8dKUgzmoVMWdeZyKqmWpcpqvwmqeEGQpX2jhO7GfmpqeEGU3lYemHmq3fM1nPrNFYz6OrhzbvAwz42kc2TZCyQ4OKWmgjeUTYepMkokPY7)jkuf6xV8(FVazswMKTM9VQA1uu59)Exy7KjhwWS)vrVIkV)3JFrMGjKufM1nPrN)vrHjNPJgDKfuPzLHBRiy3oZHPAoLhjlPrNSJgDUTYepMQg5uqPkuFbXl5FR7qvQQSqffy9We8fExzisiuMibUvJ98zfblPxJqcjkVZ7kdrcHYejWTAShZowFefwNclkV)3xWitsAj7Fv0ZhJDPuvfKo0ROY7)9e1EcrYozsJresbDmX)QMCRDGRrDKnqNNi6kbpWWWU4G42aJSMmWvgUTIGhytgOoJ1QXYbgObkzDl5bMxghzmEGeKdpq3nfLmqsg6jKdSWdKO80SCG51r2aPuysEGRbXdJvo5mD0OJSGknRmCBfb72zom1IWKC6lEySYer5PDBLjEmvsflePWWU4G4lctYPV4HXkvOk0JTwM4v8fEtkj((uvf6uRw59)(IWKC6lEySs)RAYz6OrhzbvA0MqKmD0OljAs42zomvsWMiYCR)ujbBIiJLEtiMCMoA0rwqLgTjejthn6sIMeUDMdtvljtU1oW1qFnjBGwmqhtDTZZzGUB3LFG7xHeythdeD8a)i8aztNnqkXitsAjpq7KdKUwvHWX76q5aZlJVbQ(41A1giffB5nWMmqclyDWYbANCGUJpfDGnzGhkgiMnPYbA)GXdmY4bES6Ibsyn6K(jNPJgDKfuPrBcrY0rJUKOjHBN5Wu)91Km36pvnYPGsvO(cIQu1vjhtDjsfFY8TE59)(cgzsslz)RAr59)EuvfchVRdL(xffuG1dtWx4DNVwRwsIT888zfblPFDffMGVW7yy1yz6JWjjBrMNpRiyzTAAesir5DEhdRgltFeojzlY8y2X6JOADkqHjNPJgDKfuPrBcrY0rJUKOjHBN5WulVwiNCMoA0rwqLgdRTJtbcJ5lCR)u5JXUu6L8V1DOk16kEbFm2LspMDX3KZ0rJoYcQ0yyTDCQ6ji8KZ0rJoYcQ0iAxzbjrr8KUC4lMCtU1oqkFTqYyYKZ0rJoIV8AHKAvtcKirYqHB9NQg5uqPkuFbXl5FR7qvQ1xuE)VVGrMK0s2)QweMGVW7oFTwTKeB555ZkcwsF59)EuvfchVRdL(x1KZ0rJoIV8AHCbvAi91KGXjsGB14j3KBTd0DJqcjkVJm5mD0OJ41sc1ku0OZT(tT8(FFrGqsXJeEmB6OwTWWU4WhTdNcus2ScPQG0PwTY7)9MeZNj6Jt4hjZ)QMCMoA0r8AjzbvAkcesM(pSYjNPJgDeVwswqLMcJjmwT(Cn5mD0OJ41sYcQ08BmxeiKCYz6OrhXRLKfuPXontcSjsAtiMCMoA0r8AjzbvAmjMpt0hNWpsMB9NQIkV)3BsmFMOpoHFKm)RIE(ySlL(OD4uGsoM6uT(KZ0rJoIxljlOsJJHvJLPpcNKSfzU1FQHHDXHpAhofOKSzfQrofuQc1xq8s(36oQvB91Xwlt8k(cVjLeFFQsX0PwTY7)9b(XPcB4(C5XSJ1hr16koFL3)7njMpt0hNWpsM)vPakMc0RisWMiYyPhJC9y61iNckvH6liEj)BDhQsvxLCm1Liv8jZxDkm5w7aPuysEGRbXdJvoq0nqvwmq(yNMj(bUg1r2anPKSMg4AMWdS)dmYyLdKeMYb(r4bM)fdKWA0jjdeHhy)hOs0dpWJvxmqDMHDXdmVwigyHhiMnPYb23aJ2Hh4hHhyKXd8y1fdmpBf7NCMoA0r8AjzbvAkctYPV4HXkDR)ujvSqKcd7IdIQuvHEfvE)VVimjN(IhgR0)QOFDfHTwM4v8fEtkjEwDnji1QHTwM4v8fEtkjEm7y9run)1QPriHeL35lctYPV4HXk96md7IjuRtp2AzIxXx4nPK47t11vjFAesir5D(IWKC6lEySsVoZWUys6JnD0OZeuqburXuyYz6OrhXRLKfuPXvgIecLjsGB1y36p1vgUTIG9fHj50x8WyLjIYttVg5uqPkuFbXl5FR7qvQ1xuE)VVGrMK0s2)QMCMoA0r8AjzbvAuRfI(CLivyMDR)uxz42kc2xeMKtFXdJvMikpn9RZhJDP0hTdNcuYXuNQkUwn(ySlLkSUIPWKZ0rJoIxljlOstrysoHFKm36p1vgUTIG9fHj50x8WyLjIYttpFm2LsF0oCkqjhtDQwFYT2bUMj95AGQFSRjz04(oLhjBGnzGOtOCG2axXyLdm6t5a7tJzJWUnqcAG9nqmBIou62avIEQVW8aTcbjEbluoWFF8ad0aFeEGDmqJmqBGVOfDOCGKkwi8tothn6iETKSGknRSRjzU1FQkIeSjImw6nHG(vgUTIG9Mt5rYsA0j7Or3KZ0rJoIxljlOsdjZKO8CyH0T(tvrKGnrKXsVje0VYWTveS3CkpswsJozhn6MCtU1oW1qFnjJXKjNPJgDe)VVMKrLiAnNStMKTMDR)ulV)3teTMt2jtYwZEm7y9ruyyyxC4J2HtbkjBM(Y7)9erR5KDYKS1ShZowFefUE9fAKtbLQq9fekOa195FYz6OrhX)7RjzlOsdgjePiJtf0Xe36p11lV)3JrcrkY4ubDmXJzhRpIcPQE1QTYWTveShhLeMXiHGc0VEyyxC4J2HtbkjBwvvOtTAL3)7XiHifzCQGoM4XSJ1hrHHHDXHpAhofOKSzkm5w7aPCjf5aZRJSbgz8aDVxKjyczGUlmRBsJUbwE))a)yKZaDVGYbIWdmVoYgyKXd0918axZvdCng9WdClyEfpqeEGuu2KKmumWaBDq8tothn6i(FFnjBbvAkCKhZxkY4eRKjU1FQL3)7XVitWesQcZ6M0OZ)QQvZOlmUd2BAo9QskrpCIiyEf75ZkcwwRMrxyChSxYMKKHcpFwrWYjNPJgDe)VVMKTGknYMuzHoBYn5w7a3bBIiBYz6OrhXtc2ergvZP8izG9kgtA0bOvf6up)0HUPs(91vW6kgSZZWxFUiGT6VtfchSCGk4anD0OBGIMee)KdSfnjiGLGTK)2teGLaARdwc2MoA0b2Q1A1aB(SIGLakbbGwvalb7vM4XGnokPY7)jduHduLbs)axFGL3)7fitYYKS1S)vnWA1gOIgy59)Exy7KjhwWS)vnq6hOIgy59)E8lYemHKQWSUjn68VQbsbWMpRiyjGsW20rJoWELHBRiyWELHtN5WGnokjmJrcbia0QEGLG9kt8yWwJCkOufQVG4L8V1DmqvPoqvg4IbQYavGbU(adtWx4DLHiHqzIe4wn2ZNveSCG0pqncjKO8oVRmejektKa3QXEm7y9rgOchy9bsHbUyGL3)7lyKjjTK9VQbs)a5JXUuoqvhOcsNbs)av0alV)3tu7jej7Kjngrif0Xe)RcS5ZkcwcOeSnD0OdSxz42kcgSxz40zomyBoLhjlPrNSJgDGaqlfdwc2RmXJbBsflePWWU4G4lctYPV4HXkhOchOkdK(bITwM4v8fEtkj((gOQduf6mWA1gy59)(IWKC6lEySs)RcS5ZkcwcOeSnD0OdSxz42kcgSxz40zomyxeMKtFXdJvMikpnia0QyWsWMpRiyjGsW20rJoWwBcrY0rJUKOjbyRXDW42aBsWMiYyP3ecWw0KiDMdd2KGnrKbcaTkiyjyZNveSeqjyB6OrhyRnHiz6Orxs0KaSfnjsN5WGTwsabGw6gyjyZNveSeqjyB6OrhyRnHiz6Orxs0KaS14oyCBGTg5uqPkuFbzGQsDG6QKJPUePIp5aZ3axFGL3)7lyKjjTK9VQbUyGL3)7rvviC8Uou6FvdKcdubg46dmmbFH3D(ATAjj2YZZNveSCG0pW1hOIgyyc(cVJHvJLPpcNKSfzE(SIGLdSwTbQriHeL35DmSASm9r4KKTiZJzhRpYavDG1hifgifaBrtI0zomy)7RjzGaqB(blbB(SIGLakbBthn6aBTjejthn6sIMeGTOjr6mhgSlVwibbGw6oyjyZNveSeqjyRXDW42aB(ySlLEj)BDhduvQdSUIh4IbYhJDP0Jzx8b2MoA0b2gwBhNcegZxacaT1PdyjyB6OrhyByTDCQ6jimyZNveSeqjia0wVoyjyB6OrhylAxzbjrr8KUC4laB(SIGLakbbia7kmRroflalb0whSeS5ZkcwcOeeaAvbSeS5ZkcwcOeeaAvpWsWMpRiyjGsqaOLIblbB(SIGLakbbGwfdwc2MoA0b2vOOrhyZNveSeqjia0QGGLGnFwrWsaLGTg3bJBdSXwlt8k(cVjLeFFdu1bsX0bSnD0OdSDmSASm9r4KKTidSRWSg5uSiryn6KeWwXGaqlDdSeS5ZkcwcOeSnD0OdSXiHifzCQGoMa2vywJCkwKiSgDscyRcia0MFWsWMpRiyjGsW20rJoWMiAnNStMKTMb7kmRroflsewJojbSvbeaAP7GLGnFwrWsaLGTPJgDGTjX8zI(4e(rYa7kmRroflsewJojbSRdcaT1PdyjyB6Orhytc2ergyZNveSeqjiabyxETqcwcOToyjyZNveSeqjyRXDW42aBnYPGsvO(cIxY)w3XavL6aRpWfdS8(FFbJmjPLS)vnWfdmmbFH3D(ATAjj2YZZNveSCG0pWY7)9OQkeoExhk9VkW20rJoWUQjbsKizOaeaAvbSeSnD0OdSj91KGXjsGB1yWMpRiyjGsqacWMeSjImWsaT1blbBthn6aBZP8izGnFwrWsaLGaeGTwsalb0whSeS5ZkcwcOeS14oyCBGD59)(IaHKIhj8y20XaRvBGHHDXHpAhofOKS5bQqQdubPZaRvBGL3)7njMpt0hNWpsM)vb2MoA0b2vOOrhia0QcyjyB6OrhyxeiKm9FyLGnFwrWsaLGaqR6bwc2MoA0b2fgtySA95cS5ZkcwcOeeaAPyWsW20rJoW(3yUiqijyZNveSeqjia0QyWsW20rJoW2ontcSjsAtiaB(SIGLakbbGwfeSeS5ZkcwcOeS14oyCBGTIgy59)EtI5Ze9Xj8JK5FvdK(bYhJDP0hTdNcuYXu3avDG1bBthn6aBtI5Ze9Xj8JKbcaT0nWsWMpRiyjGsWwJ7GXTb2HHDXHpAhofOKS5bQWbQrofuQc1xq8s(36ogyTAdC9bU(aXwlt8k(cVjLeFFdu1bsX0zG1QnWY7)9b(XPcB4(C5XSJ1hzGQoW6kEG5BGL3)7njMpt0hNWpsM)vnqfyGkEGuyG0pqfnqsWMiYyPhJC94bs)a1iNckvH6liEj)BDhduvQduxLCm1Liv8jhy(gy9bsbW20rJoW2XWQXY0hHts2ImqaOn)GLGnFwrWsaLGTg3bJBdSjvSqKcd7IdYavL6avzG0pqfnWY7)9fHj50x8WyL(x1aPFGRpqfnqS1YeVIVWBsjXZQRjbzG1QnqS1YeVIVWBsjXJzhRpYavDG5FG1QnqncjKO8oFryso9fpmwPxNzyxmzGuhy9bs)aXwlt8k(cVjLeFFdu1bU(avzG5BGAesir5D(IWKC6lEySsVoZWUys6JnD0OZedKcdubgOkkEGuaSnD0OdSlctYPV4HXkbbGw6oyjyZNveSeqjyRXDW42a7vgUTIG9fHj50x8WyLjIYtpq6hOg5uqPkuFbXl5FR7yGQsDG1h4IbwE)VVGrMK0s2)QaBthn6aBxzisiuMibUvJbbG260bSeS5ZkcwcOeS14oyCBG9kd3wrW(IWKC6lEySYer5Phi9dC9bYhJDP0hTdNcuYXu3avDGkEG1Qnq(ySlLduHdSUIhifaBthn6aB1AHOpxjsfMzqaOTEDWsWMpRiyjGsWwJ7GXTb2RmCBfb7lctYPV4HXkteLNEG0pq(ySlL(OD4uGsoM6gOQdSoyB6OrhyxeMKt4hjdeaARRcyjyZNveSeqjyRXDW42aBfnqsWMiYyP3eIbs)axz42kc2BoLhjlPrNSJgDGTPJgDG9k7Asgia0wx9albB(SIGLakbBnUdg3gyRObsc2ergl9Mqmq6h4kd3wrWEZP8izjn6KD0OdSnD0OdSjzMeLNdlKGaeG9VVMKbwcOToyjyZNveSeqjyRXDW42a7Y7)9erR5KDYKS1ShZowFKbQWbgg2fh(OD4uGsYMhi9dS8(Fpr0AozNmjBn7XSJ1hzGkCGRpW6dCXa1iNckvH6lidKcdubgyDF(bBthn6aBIO1CYozs2AgeaAvbSeS5ZkcwcOeS14oyCBG96dS8(FpgjePiJtf0XepMDS(iduHuhO6nWA1g4kd3wrWECusygJeIbsHbs)axFGHHDXHpAhofOKS5bQ6avHodSwTbwE)VhJeIuKXPc6yIhZowFKbQWbgg2fh(OD4uGsYMhifaBthn6aBmsisrgNkOJjGaqR6bwc28zfblbuc2AChmUnWU8(Fp(fzcMqsvyw3KgD(x1aRvBGgDHXDWEtZPxvsj6HtebZRypFwrWYbwR2an6cJ7G9s2KKmu45Zkcwc2MoA0b2foYJ5lfzCIvYeqaOLIblbBthn6aBztQSqNb28zfblbuccqacW2Ergcd272XDdcqaa]] )


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