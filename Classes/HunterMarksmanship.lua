-- HunterMarksmanship.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Shadowlands Legendaries
-- [x] Eagletalon's True Focus
-- [-] Surging Shots (passive/reactive)
-- [-] Serpentstalker's Trickery (passive/reactive)
-- [-] Secrets of the Unblinking Vigil (passive/reactive)

-- Conduits
-- [x] Brutal Projectiles
-- [-] Deadly Chain
-- [-] Powerful Precision
-- [x] Sharpshooter's Focus


if UnitClassBase( "player" ) == "HUNTER" then
    local spec = Hekili:NewSpecialization( 254, true )

    spec:RegisterResource( Enum.PowerType.Focus, {
        death_chakram = {
            resource = "focus",
            aura = "death_chakram",

            last = function ()
                return state.buff.death_chakram.applied + floor( state.query_time - state.buff.death_chakram.applied )
            end,

            interval = function () return class.auras.death_chakram.tick_time end,
            value = function () return conduit.necrotic_barrage.enabled and 5 or 3 end,
        }        
    } )

    -- Talents
    spec:RegisterTalents( {
        master_marksman = 22279, -- 260309
        serpent_sting = 22501, -- 271788
        a_murder_of_crows = 22289, -- 131894

        careful_aim = 22495, -- 260228
        barrage = 22497, -- 120360
        explosive_shot = 22498, -- 212431

        trailblazer = 19347, -- 199921
        natural_mending = 19348, -- 270581
        camouflage = 23100, -- 199483

        steady_focus = 22267, -- 193533
        streamline = 22286, -- 260367
        chimaera_shot = 21998, -- 342049

        born_to_be_wild = 22268, -- 266921
        posthaste = 22276, -- 109215
        binding_shackles = 23463, -- 321468

        lethal_shots = 23063, -- 260393
        dead_eye = 23104, -- 321460
        double_tap = 22287, -- 260402

        calling_the_shots = 22274, -- 260404
        lock_and_load = 22308, -- 194595
        volley = 22288, -- 260243
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {         
        dragonscale_armor = 649, -- 202589
        survival_tactics = 651, -- 202746 
        viper_sting = 652, -- 202797
        scorpid_sting = 653, -- 202900
        spider_sting = 654, -- 202914
        scatter_shot = 656, -- 213691
        hiexplosive_trap = 657, -- 236776
        trueshot_mastery = 658, -- 203129
        roar_of_sacrifice = 3614, -- 53480
        hunting_pack = 3729, -- 203235
        rangers_finesse = 659, -- 248443
        sniper_shot = 660, -- 203155
    } )

    -- Auras
    spec:RegisterAuras( {
        a_murder_of_crows = {
            id = 131894,
            duration = 15,
            max_stack = 1,
        },
        aspect_of_the_turtle = {
            id = 186265,
            duration = 8,
            max_stack = 1,
        },
        binding_shot = {
            id = 117526,
            duration = 8,
            max_stack = 1,
        },
        bursting_shot = {
            id = 186387,
            duration = 6,
            max_stack = 1,
        },
        camouflage = {
            id = 199483,
            duration = 60,
            max_stack = 1,
        },
        concussive_shot = {
            id = 5116,
            duration = 6,
            max_stack = 1,
        },
        dead_eye = {
            id = 321461,
            duration = 3,
            max_stack = 1,
        },
        double_tap = {
            id = 260402,
            duration = 15,
            max_stack = 1,
        },
        eagle_eye = {
            id = 6197,
        },
        explosive_shot = {
            id = 212431,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        feign_death = {
            id = 5384,
            duration = 360,
            max_stack = 1,
        },
        freezing_trap = {
            id = 3355,
            duration = 60,
            max_stack = 1,
        },
        hunters_mark = {
            id = 257284,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
        },
        lethal_shots = {
            id = 260393,
            duration = 3600,
        },
        lock_and_load = {
            id = 194594,
            duration = 15,
            max_stack = 1,
        },
        lone_wolf = {
            id = 164273,
            duration = 3600,
            max_stack = 1,
        },
        master_marksman = {
            id = 269576,
            duration = 12,
            max_stack = 1,
        },
        misdirection = {
            id = 34477,
            duration = 8,
            max_stack = 1,
        },
        pathfinding = {
            id = 264656,
            duration = 3600,
            max_stack = 1,
        },
        posthaste = {
            id = 118922,
            duration = 4,
            max_stack = 1,
        },
        precise_shots = {
            id = 260242,
            duration = 15,
            max_stack = 2,
        },
        rapid_fire = {
            id = 257044,
            duration = function () return 2 * haste end,
            max_stack = 1,
        },
        serpent_sting = {
            id = 271788,
            duration = 18,
            type = "Poison",
            max_stack = 1,
        },
        steady_focus = {
            id = 193534,
            duration = 15,
            max_stack = 1,
        },
        streamline = {
            id = 342076,
            duration = 15,
            max_stack = 1,
        },
        survival_of_the_fittest = {
            id = 281195,
            duration = 6,
            max_stack = 1,
        },
        tar_trap = {
            id = 135299,
            duration = 30,
            max_stack = 1
        },
        trailblazer = {
            id = 231390,
            duration = 3600,
            max_stack = 1,
        },
        trick_shots = {
            id = 257622,
            duration = 20,
            max_stack = 1,
        },
        trueshot = {
            id = 288613,
            duration = function () return 15 * ( 1 + ( conduit.sharpshooters_focus.mod * 0.01 ) ) end,
            max_stack = 1,
        },
        volley = {
            id = 257622,
            duration = 6,
            max_stack = 1,
        }
    } )


    spec:RegisterStateExpr( "ca_execute", function ()
        return talent.careful_aim.enabled and ( target.health.pct > 70 )
    end )

    spec:RegisterStateExpr( "ca_active", function ()
        return talent.careful_aim.enabled and ( target.health.pct > 70 )
    end )


    local steady_focus_applied = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" or subtype == "SPELL_AURA_APPLIED_DOSE" ) and spellID == 193534 then -- Steady Aim.
            steady_focus_applied = GetTime()
        end
    end )

    spec:RegisterStateExpr( "last_steady_focus", function ()
        return steady_focus_applied
    end )


    spec:RegisterHook( "reset_precast", function ()
        if now - action.serpent_sting.lastCast < gcd.execute * 2 and target.unit == action.serpent_sting.lastUnit then
            applyDebuff( "target", "serpent_sting" )
        end

        last_steady_focus = nil
    end )


    spec:RegisterStateTable( "tar_trap", setmetatable( {}, {
        __index = function( t, k )
            return debuff.tar_trap[ k ]
        end
    }, state ) )


    -- Abilities
    spec:RegisterAbilities( {
        a_murder_of_crows = {
            id = 131894,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.7 or 1 ) * 20 end,
            spendType = "focus",

            startsCombat = true,
            texture = 645217,

            talent = "a_murder_of_crows",

            handler = function ()
                applyDebuff( "target", "a_murder_of_crows" )
            end,
        },


        aimed_shot = {
            id = 19434,
            cast = function ()
                if buff.lock_and_load.up then return 0 end
                return 2.5 * haste * ( buff.trueshot.up and 0.5 or 1 ) * ( buff.streamline.up and 0.7 or 1 )
            end,

            charges = 2,
            cooldown = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) end,
            recharge = function () return haste * ( buff.trueshot.up and 4.8 or 12 ) end,
            gcd = "spell",

            spend = function () return buff.lock_and_load.up and 0 or ( ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.7 or 1 ) * 35 ) end,
            spendType = "focus",

            startsCombat = true,
            texture = 135130,

            handler = function ()
                applyBuff( "precise_shots" )
                removeBuff( "lock_and_load" )
                removeBuff( "double_tap" )
                if buff.volley.down then removeBuff( "trick_shots" ) end
            end,
        },


        arcane_shot = {
            id = 185358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.7 or 1 ) * 20 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132218,

            notalent = "chimaera_shot",

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                removeStack( "precise_shots" )
            end,
        },


        aspect_of_the_cheetah = {
            id = 186257,
            cast = 0,
            cooldown = function () return ( 180 * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( talent.born_to_be_wild.enabled and 0.8 or 1 ) ) + ( conduit.cheetahs_vigor.mod * 0.001 ) end,
            gcd = "off",

            startsCombat = false,
            texture = 132242,

            handler = function ()
                applyBuff( "aspect_of_the_cheetah" )
            end,
        },


        aspect_of_the_turtle = {
            id = 186265,
            cast = 0,
            cooldown = function () return ( 180 * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( talent.born_to_be_wild.enabled and 0.8 or 1 ) ) + ( conduit.harmony_of_the_tortollan.mod * 0.001 ) end,
            gcd = "off",

            toggle = "defensives",

            startsCombat = false,
            texture = 132199,

            handler = function ()
                applyBuff( "aspect_of_the_turtle" )
                setCooldown( "global_cooldown", 5 )
            end,
        },


        barrage = {
            id = 120360,
            cast = 3,
            channeled = true,
            cooldown = 20,
            gcd = "spell",

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.7 or 1 ) * 30 end,
            spendType = "focus",

            startsCombat = true,
            texture = 236201,

            talent = "barrage",

            start = function ()
            end,
        },


        binding_shot = {
            id = 109248,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 462650,

            handler = function ()
                applyDebuff( "target", "binding_shot" )
            end,
        },


        bursting_shot = {
            id = 186387,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.7 or 1 ) * 10 end,
            spendType = "focus",

            startsCombat = true,
            texture = 1376038,

            handler = function ()
                applyDebuff( "target", "bursting_shot" )
            end,
        },


        camouflage = {
            id = 199483,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            texture = 461113,

            usable = function () return time == 0 end,
            handler = function ()
                applyBuff( "camouflage" )
            end,
        },


        concussive_shot = {
            id = 5116,
            cast = 0,
            cooldown = 5,
            gcd = "spell",

            startsCombat = true,
            texture = 135860,

            handler = function ()
                applyDebuff( "target", "concussive_shot" )
            end,
        },
       
       
        chimaera_shot = {
            id = 342049,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.7 or 1 ) * 20 end,
            spendType = "focus",

            startsCombat = true,
            texture = 236176,

            talent = "chimaera_shot",

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                removeStack( "precise_shots" )
            end,
        },


        counter_shot = {
            id = 147362,
            cast = 0,
            cooldown = 24,
            gcd = "off",

            startsCombat = true,
            texture = 249170,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                if conduit.reversal_of_fortune.enabled then
                    gain( conduit.reversal_of_fortune.mod, "focus" )
                end

                interrupt()
            end,
        },


        disengage = {
            id = 781,
            cast = 0,
            charges = 1,
            cooldown = 20,
            recharge = 20,
            gcd = "off",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                if talent.posthaste.enabled then applyBuff( "posthaste" ) end
                if conduit.tactical_retreat.enabled and target.within8 then applyDebuff( "target", "tactical_retreat" ) end
            end,
        },


        double_tap = {
            id = 260402,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 537468,

            handler = function ()
                applyBuff( "double_tap" )
            end,
        },


        --[[ eagle_eye = {
            id = 6197,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132172,

            handler = function ()
            end,
        }, ]]


        exhilaration = {
            id = 109304,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 461117,

            handler = function ()
                gain( 0.3 * health.max, "health" )
                if conduit.rejuvenating_wind.enabled then applyBuff( "rejuvenating_wind" ) end
            end,
        },


        explosive_shot = {
            id = 212431,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.7 or 1 ) * 20 end,
            spendType = "focus",

            startsCombat = false,
            texture = 236178,

            talent = "explosive_shot",
            
            handler = function ()
                applyDebuff( "target", "explosive_shot" )
            end,
        },


        --[[ Using from BM module.
        feign_death = {
            id = 5384,
            cast = 0,
            cooldown = 30,
            gcd = "off",

            startsCombat = false,
            texture = 132293,

            handler = function ()
                applyBuff( "feign_death" )
            end,
        }, ]]


        --[[ flare = {
            id = 1543,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 135815,

            handler = function ()
            end,
        }, ]]


        freezing_trap = {
            id = 187650,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 135834,

            handler = function ()
                applyDebuff( "target", "freezing_trap" )
            end,
        },


        hunters_mark = {
            id = 257284,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 236188,

            usable = function () return debuff.hunters_mark.down end,
            handler = function ()
                applyDebuff( "target", "hunters_mark" )
            end,
        },


        masters_call = {
            id = 272682,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 236189,

            handler = function ()
                applyBuff( "masters_call" )
            end,
        },


        misdirection = {
            id = 34477,
            cast = 0,
            cooldown = 30,
            gcd = "off",

            startsCombat = false,
            texture = 132180,

            handler = function ()
                applyBuff( "misdirection" )
            end,
        },


        multishot = {
            id = 257620,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.7 or 1 ) * 20 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132330,

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                if active_enemies > 2 then applyBuff( "trick_shots" ) end
                removeStack( "precise_shots" )
            end,
        },


        rapid_fire = {
            id = 257044,
            cast = function () return ( 2 * haste ) end,
            channeled = true,
            cooldown = function () return ( buff.trueshot.up and 8 or 20 ) * haste end,
            gcd = "spell",

            startsCombat = true,
            texture = 461115,

            start = function ()
                applyBuff( "rapid_fire" )
                if buff.volley.down then removeBuff( "trick_shots" ) end
                if talent.streamline.enabled then applyBuff( "streamline" ) end
                removeBuff( "brutal_projectiles" )
            end,

            finish = function ()
                removeBuff( "double_tap" )                
            end,

            auras = {
                -- Conduit
                brutal_projectiles = {
                    id = 339929,
                    duration = 3600,
                    max_stack = 1,
                },
            }
        },


        serpent_sting = {
            id = 271788,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.7 or 1 ) * 10 end,
            spendType = "focus",

            startsCombat = true,
            texture = 1033905,

            velocity = 45,

            talent = "serpent_sting",

            handler = function ()
                applyDebuff( "target", "serpent_sting" )
            end,
        },


        steady_shot = {
            id = 56641,
            cast = 1.8,
            cooldown = 0,
            gcd = "spell",

            spend = -10,
            spendType = "focus",

            startsCombat = true,
            texture = 132213,

            handler = function ()
                if talent.steady_focus.enabled and prev_gcd[1].steady_shot and action.steady_shot.lastCast > last_steady_focus then
                    applyBuff( "steady_focus" )
                    last_steady_focus = query_time
                end
                if debuff.concussive_shot.up then debuff.concussive_shot.expires = debuff.concussive_shot.expires + 3 end
            end,
        },


        summon_pet = {
            id = 883,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,

            texture = function () return GetStablePetInfo(1) or 'Interface\\ICONS\\Ability_Hunter_BeastCall' end,
            nomounted = true,

            usable = function () return false and not pet.exists end, -- turn this into a pref!
            handler = function ()
                summonPet( "made_up_pet", 3600, "ferocity" )
            end,
        },


        survival_of_the_fittest = {
            id = function () return pet.exists and 264735 or 281195 end,
            cast = 0,
            cooldown = 180,
            gcd = "off",
            known = function ()
                if not pet.exists then return 155228 end
            end,

            toggle = "defensives",

            startsCombat = false,

            usable = function ()
                return not pet.exists or pet.alive, "requires either no pet or a living pet"
            end,
            handler = function ()
                applyBuff( "survival_of_the_fittest" )
            end,

            copy = { 264735, 281195, 155228 }
        },        


        tar_trap = {
            id = 187698,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 576309,

            handler = function ()
                applyDebuff( "target", "tar_trap" )
            end,
        },


        trueshot = {
            id = 288613,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 132329,

            nobuff = function ()
                if settings.trueshot_vop_overlap then return end
                return "trueshot"
            end,

            handler = function ()
                applyBuff( "trueshot" )
                if azerite.unerring_vision.enabled then
                    applyBuff( "unerring_vision" )
                end
            end,

            meta = {
                duration_guess = function( t )
                    return talent.calling_the_shots.enabled and 90 or t.duration
                end,
            }
        },
        volley = {
            id = 260243,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 132205,

            talent = "volley",

            handler = function ()
                applyBuff( "volley" )
                applyBuff( "trick_shots", 6 )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "unbridled_fury",

        package = "Marksmanship",
    } )

    
    spec:RegisterSetting( "trueshot_vop_overlap", false, {
        name = "|T132329:0|t Trueshot Overlap (Vision of Perfection)",
        desc = "If checked, the addon will recommend |T132329:0|t Trueshot even if the buff is already applied due to a Vision of Perfection proc.\n" ..
            "This may be preferred when delaying Trueshot would cost you one or more uses of Trueshot in a given fight.",
        type = "toggle",
        width = 1.5
    } )  


    if state.level > 50 then
        spec:RegisterPack( "Marksmanship", 20201007.9, [[d8ZwRaGAKkv9yiBcP0Ui1RrK2hiLdtzCGuHzlvZxkUjiv0VajFtkjDEHKDcc7vPDd1(j5NQkfzyQk53koTKNRYGfmCH6qivCkPehtiohivAHiITbsvlgjlh4HivQ4PIAzuHwhsLk9mKkzQQkMSith1JqQuEfv0LjUoO(lvDBQ0MvLTJu13brZIkyAsjX8qkgPQsbFwv1Ory8QkvNuvPOULQsHUMusDpe1kLsDCvLsJsi1BK9ZMtglleo(LJFf5RVAvTJrIejIJBMJkw2CSHi1(LnJnxzZqNgG0Z1WhrfV5ylQ(yP9ZMVbgGKnt3ubcMJp6Uqb1FXeWuA04c1vUWDJRbJa2JH6kxeuBMcU683mEP2CYyzHWXVC8RiF9vRQDmsKiF16nBWmXa2CUCP7SzIkLe8sT5KCOnt3ubOtdq65A4JOIvHVbymlavB6Mk8nH4HsaQqR6Gk44xo(LQTQnDtf(quNkuNkWeIk0f6LUkanvO1FPc0lGRgSEZ964B)SzguispIHV9ZcrK9ZMfSr1L0sYMrGIfqzBgntpnqI1w5kj)rmSgowfAAub0m90ajwdS4k5Ffq0aX1k8PcqtfqZ0tdKyTvUsYFedRbIRv4BZgIRbV50at1fpBXlVq44(zZc2O6sAjzZiqXcOSndGXYBa)I(g4(Ba)IxCPeWPLVfUIJLKkqRkWgWZalwdexRWNkqJk8JsQaTQaAMEAGeRFDdiAG4Af(ubAuHFuAZgIRbVz2aEgyXlVqqx7NnlyJQlPLKnJaflGY2maglVb8l6BG7Vb8lEXLsaNwWgvxsQaTQaBapdSynC8MnexdEZVUbKLxiAL9ZMnexdEZqw9K)IlqX3MfSr1L0sYYleTE)SzdX1G3m9tVlrTzbBuDjTKS8cb0VF2SH4AWBgi3GnUW)Edagi3SGnQUKwswEHOv3pB2qCn4ntzaG9lBwWgvxsljlVqaDSF2SH4AWBw(ECFUIEXFedVzbBuDjTKS8cb0D)SzbBuDjTKSzeOybu2MrZ0tdKynWIRK)vardexRWNk00OcVbbFQGtvWqCnynWIRK)varJSJ9a5xWQa0uH3GGpTR9DvOPrfE1pb7bIRv4tfOrfI06nBiUg8MzaSCedV8crKV2pBwWgvxsljBgbkwaLTzk43tZGcrQ)ig(0WXQaTQq0Qaf87PJbcQoXFedF60ajwfAAuHhCV7bcIWa)INlxrfOrfq2XEUCfvWPk8JsQqtJkqb)EAgalhXWA4yvOLnBiUg8MTYvs(Jy4LxiIez)SzbBuDjTKSzeOybu2MFdc(ubNQaYo2dKFbRc0OcVbbFAx77B2qCn4nNeJj8icJuG5U8creh3pBwWgvxsljBgbkwaLTzk43tZGcrQ)ig(0WXQaTQaf87Ptdmvx8SfRtdK4nBiUg8MbwCL8VcilVqeHU2pBwWgvxsljBgbkwaLTzk43tZGcrQ)ig(0PbsSk00OcuWVNogiO6e)rm8PHJvHMgv4ni4tf(gvb0CSk4ufq2XEG8lyvaAQGH4AWARCLK)igwJMJ3SH4AWB2fUZ1rm8YlerAL9ZMfSr1L0sYMrGIfqzBMc(90jXsEjkrNgiXB2qCn4ntA17(Jy4LxiI069ZMnexdEZM3fgKeGFEEeyG82SGnQUKwswEHic0VF2SH4AWB(1TOKK)igEZc2O6sAjz5fIiT6(zZc2O6sAjzZgIRbV5taXcM9hx4)nJaflGY2mqEa5imQUSzuuOU4zd8l8Tqez5fIiqh7NnBiUg8MpwSuu(Jy4nlyJQlPLKLxEZj5zWDE)Sqez)SzdX1G3mAGXSa8hXWBwWgvxsljlVq44(zZc2O6sAjzZiqXcOSnhde69)OKoIMbWYrmSk00Oc0rfyRlywJSEVW)EMq8hXWNwWgvxsQqtJk8QFc2dexRWNkqJk44xB2qCn4ndFIVyX9wEHGU2pBwWgvxsljB2qCn4nJSE3BiUgSVxhV5EDShBUYMrPB5fIwz)SzbBuDjTKSzeOybu2Mnex0lEblULCQanQaDTzdX1G3mY6DVH4AW(ED8M71XES5kB(4LxiA9(zZc2O6sAjzZiqXcOSnBiUOx8cwCl5ubOPcoUzdX1G3mY6DVH4AW(ED8M71XES5kBMbfI0Jy4B5L3CmqqJlLX7NfIi7NnlyJQlPLKnJaflGY2maglVb8l6BG7Vb8lEXLsaNw(w4kowsB2qCn4nZgWZalE5fch3pBwWgvxsljBogii7ypxUYMJ81MnexdEZPbMQlE2IxEHGU2pBwWgvxsljB2qCn4nhpCn4nNIcBUfYhdK4H3CKLxiAL9ZMfSr1L0sYMrGIfqzB2qCrV4fS4wYPcKvHiB2qCn4nBLRK8hXWlV8MrPB)Sqez)SzbBuDjTKSzeOybu2MJbc9(FushrZay5igwfOvfIwfE1pb7bIRv4tfGMkGMPNgiXAkbCcG0c)RtWaJRbRcovHemW4AWQqtJkeTkWg4xynHyDMqhJyvGgvWXVuHMgvGoQaBDbZAKbKhC3BLRwWgvxsQqlQqlQqtJk8QFc2dexRWNkqJkeHU2SH4AWBMsaNaiTW)lVq44(zZc2O6sAjzZiqXcOSnhde69)OKoIMbWYrmSkqRkeTk8QFc2dexRWNkanvantpnqI1u9zs(hmikDcgyCnyvWPkKGbgxdwfAAuHOvb2a)cRjeRZe6yeRc0Oco(Lk00Oc0rfyRlywJmG8G7ERC1c2O6ssfArfArfAAuHx9tWEG4Af(ubAuHiq)MnexdEZu9zs(hmiQLxiOR9ZMfSr1L0sYMrGIfqzBogi07)rjDendGLJyyvGwviAv4v)eShiUwHpvaAQaAMEAGeRnmsogyDpY6DDcgyCnyvWPkKGbgxdwfAAuHOvb2a)cRjeRZe6yeRc0Oco(Lk00Oc0rfyRlywJmG8G7ERC1c2O6ssfArfArfAAuHx9tWEG4Af(ubAuHiq)MnexdEZggjhdSUhz9(YleTY(zZc2O6sAjzZiqXcOSnhde69)OKoIMbWYrmSkqRkeTk8QFc2dexRWNkanvantpnqI1Vciu9zs6emW4AWQGtvibdmUgSk00OcrRcSb(fwtiwNj0XiwfOrfC8lvOPrfOJkWwxWSgza5b39w5QfSr1LKk0Ik0Ik00OcV6NG9aX1k8Pc0Ocq3nBiUg8MFfqO6ZKwEHO17NnlyJQlPLKnJaflGY2mf87PzaSCedRtdK4nBiUg8M71pbFE6E40VRG5LxiG(9ZMfSr1L0sYMrGIfqzBMc(90mawoIH1Pbs8MnexdEZu2VFEEguisVLxiA19ZMfSr1L0sYMrGIfqzBMc(90mawoIH1aXqSkqRkqb)EAQ(mPo8XAGyiwfAAuHyGqV)hL0r0mawoIHvbAvb2a)cRjeRZe6yeRc0Oco(Lk00OcrRcrRcObFWUgvx0Xdxd2pppmMcuPUK8pyquQqtJkGg8b7AuDrdJPavQlj)dgeLk0IkqRk8QFc2dexRWNkqJka9ruHMgv4v)eShiUwHpvGgvWrOxfAzZgIRbV54HRbV8YB(49ZcrK9ZMfSr1L0sYMrGIfqzBMTUGz9XILIY)ge8PfSr1LKkqRkede69)OKoI(yXsr5pIHvbAvbk43tFSyPO8VbbFAG4Af(ubAuHwVzdX1G38XILIYFedV8cHJ7NnBiUg8MjT6D)rm8MfSr1L0sYYle01(zZgIRbV50at1fpBXBwWgvxsljlVq0k7NnlyJQlPLKnJaflGY2maglVb8l6BG7Vb8lEXLsaNw(w4kowsQaTQaBapdSynqCTcFQanQWpkPc0QcOz6PbsS(1nGObIRv4tfOrf(rPnBiUg8Mzd4zGfV8crR3pBwWgvxsljBgbkwaLTzamwEd4x03a3Fd4x8IlLaoTGnQUKubAvb2aEgyXA44nBiUg8MFDdilVqa97NnBiUg8MHS6j)fxGIVnlyJQlPLKLxiA19ZMnexdEZVUfLK8hXWBwWgvxsljlVqaDSF2SGnQUKws2mcuSakBZVbbFQGtvazh7bYVGvbAuH3GGpTR99nBiUg8MtIXeEeHrkWCxEHa6UF2SH4AWBw(ECFUIEXFedVzbBuDjTKS8crKV2pBwWgvxsljBgbkwaLTzk43thdeuDI)ig(0PbsSk00Oc0rfyRlywJikxtaM)igwlyJQlPnBiUg8MPF6DjQLxiIez)SzdX1G3S5DHbjb4NNhbgiVnlyJQlPLKLxiI44(zZc2O6sAjzZiqXcOSntb)E6yGGQt8hXWNonqIvHMgvGoQaBDbZAer5AcW8hXWAbBuDjTzdX1G3mqUbBCH)9gamqU8cre6A)SzbBuDjTKSzeOybu2MPGFpDmqq1j(Jy4tNgiXQqtJkqhvGTUGznIOCnby(JyyTGnQUK2SH4AWBMbWYrm8YlerAL9ZMfSr1L0sYMrGIfqzBoAv4b37EGGimWV45YvubAubKDSNlxrfCQc)OKk00OcuWVNMbWYrmSgowfArfOvfIwfOGFpDmqq1j(Jy4tNgiXQqtJkqhvGTUGznIOCnby(JyyTGnQUKuHMgvazEdXf9Ik0Ik00OcuWVNMbfIu)rm8PbIRv4tfGMkiFxqWS45YvubAvHOvbdXf9IxWIBjNkanviIk00OcayS8gWVOpbely(yRtQaopdkePcikT8TWvCSKuHw2SH4AWB2kxj5pIHxEHisR3pBwWgvxsljBgbkwaLTzk43tNgyQU4zlwNgiXQaTQWBqWNk4ufq2XEG8lyvGgv4ni4t7AFFZgIRbVzGfxj)RaYYlerG(9ZMfSr1L0sYMrGIfqzBMc(90XabvN4pIHpnCSkqRkeTkqb)EAgalhXW60ajwfAAubdXf9IxWIBjNkanviIk00Oc0rfqM3qCrVOcTSzdX1G3mIOCnby(Jy4LxiI0Q7NnlyJQlPLKnBiUg8Mpbely2FCH)3mcuSakBZa5bKJWO6IkqRkWg4xynxUINhFQevaAQqcgyCn4nJIc1fpBGFHVfIilVqeb6y)SzbBuDjTKSzeOybu2Mnex0lEblULCQa0uHiB2qCn4ntzaG9llVqeb6UF2SGnQUKws2mcuSakBZuWVNogiO6e)rm8PHJvbAvHOvbk43tZay5igwNgiXQqtJkqhvazEdXf9Ik0YMnexdEZgazyXFedV8cHJFTF2SGnQUKws2mcuSakBZuWVNogiO6e)rm8PtdK4nBiUg8MTYvs(Jy4LxiCmY(zZc2O6sAjzZiqXcOSn)ge8PcqtfqZXQGtvWqCnyTvUsYFedRrZXQaTQq0Qaf87PzaSCedRtdKyvOPrfOJkGmVH4IErfAzZgIRbVzer5AcW8hXWlVq4OJ7NnlyJQlPLKnJaflGY28BqWNkanvanhRcovbdX1G1w5kj)rmSgnhRc0QcrRcuWVNMbWYrmSonqIvHMgvGoQaY8gIl6fvOLnBiUg8MnaYWI)igE5fchPR9ZMfSr1L0sYMrGIfqzB(ni4tfCQci7ypq(fSkqJk8ge8PDTVVzdX1G38XILIYFedV8cHJTY(zZgIRbVzer5AcW8hXWBwWgvxsljlVq4yR3pB2qCn4nBaKHf)rm8MfSr1L0sYYlV8MPxaxn4fch)YXV(c66yR1q3ndPbWf()283SB8ayjPcTwfmexdwf61XNw1EZXG5vDzZ0nva60aKEUg(iQyv4BagZcq1MUPcFtiEOeGk0QoOco(LJFPARAt3uHpe1Pc1PcmHOcDHEPRcqtfA9xQa9c4QbRvTvTnexd(0XabnUug7KmuSb8mWIDOEKbWy5nGFrFdC)nGFXlUuc40Y3cxXXss12qCn4thde04szStYqLgyQU4zl2HyGGSJ9C5kKJ8LQTH4AWNogiOXLYyNKHkE4AWoKIcBUfYhdK4Hjhr12qCn4thde04szStYqzLRK8hXWoupYgIl6fVGf3soYruTvTnexd(Csgk0aJzb4pIHvTnexd(Csgk4t8flUNd1JCmqO3)Js6iAgalhXWnn0HTUGznY69c)7zcXFedFAbBuDj108QFc2dexRWhno(LQTH4AWNtYqHSE3BiUgSVxh7a2CfYO0PABiUg85KmuiR39gIRb771XoGnxH8XoupYgIl6fVGf3soAOlvBdX1GpNKHcz9U3qCnyFVo2bS5kKzqHi9ig(COEKnex0lEblULCqZrvBvBdX1GpnkDojdfLaobqAH)DOEKJbc9(FushrZay5igM2OF1pb7bIRv4dAOz6PbsSMsaNaiTW)6emW4AWotWaJRb30enBGFH1eI1zcDmIPXXVAAOdBDbZAKbKhC3BLRwWgvxsT0stZR(jypqCTcF0eHUuTnexd(0O05Kmuu9zs(hmikhQh5yGqV)hL0r0mawoIHPn6x9tWEG4Af(GgAMEAGeRP6ZK8pyqu6emW4AWotWaJRb30enBGFH1eI1zcDmIPXXVAAOdBDbZAKbKhC3BLRwWgvxsT0stZR(jypqCTcF0eb6vTnexd(0O05KmuggjhdSUhz9Ud1JCmqO3)Js6iAgalhXW0g9R(jypqCTcFqdntpnqI1ggjhdSUhz9UobdmUgSZemW4AWnnrZg4xynHyDMqhJyAC8RMg6WwxWSgza5b39w5QfSr1LulT008QFc2dexRWhnrGEvBdX1GpnkDojd1RacvFMKd1JCmqO3)Js6iAgalhXW0g9R(jypqCTcFqdntpnqI1Vciu9zs6emW4AWotWaJRb30enBGFH1eI1zcDmIPXXVAAOdBDbZAKbKhC3BLRwWgvxsT0stZR(jypqCTcF0aDvTnexd(0O05Kmu96NGppDpC63vWSd1Jmf87PzaSCedRtdKyvBdX1GpnkDojdfL97NNNbfI0ZH6rMc(90mawoIH1PbsSQTH4AWNgLoNKHkE4AWoupYuWVNMbWYrmSgigIPLc(90u9zsD4J1aXqCttmqO3)Js6iAgalhXW0Yg4xynHyDMqhJyAC8RMMOJgn4d21O6IoE4AW(55HXuGk1LK)bdIQPbn4d21O6IggtbQuxs(hmiQwO9v)eShiUwHpAG(innV6NG9aX1k8rJJqFlQ2Q2gIRbFAguispIHpNKHknWuDXZwSd1JmAMEAGeRTYvs(JyynCCtdAMEAGeRbwCL8VciAG4Af(GgAMEAGeRTYvs(JyynqCTcFQ2gIRbFAguispIHpNKHInGNbwSd1JmaglVb8l6BG7Vb8lEXLsaNw(w4kows0YgWZalwdexRWhn)OeTOz6PbsS(1nGObIRv4JMFus12qCn4tZGcr6rm85KmuVUbehQhzamwEd4x03a3Fd4x8IlLaoTGnQUKOLnGNbwSgow12qCn4tZGcr6rm85Kmuqw9K)IlqXNQTH4AWNMbfI0Jy4ZjzOOF6DjkvBdX1GpndkePhXWNtYqbKBWgx4FVbadKQ2gIRbFAguispIHpNKHIYaa7xuTnexd(0mOqKEedFojdL894(Cf9I)igw12qCn4tZGcr6rm85KmumawoIHDOEKrZ0tdKynWIRK)vardexRWxtZBqWNtdX1G1alUs(xbenYo2dKFbdT3GGpTR99MMx9tWEG4Af(OjsRvTnexd(0mOqKEedFojdLvUsYFed7q9itb)EAguis9hXWNgoM2OPGFpDmqq1j(Jy4tNgiXnnp4E3deeHb(fpxUcni7ypxUIZFuQPHc(90mawoIH1WXTOABiUg8PzqHi9ig(CsgQKymHhryKcmxhQh53GGpNi7ypq(fmnVbbFAx77Q2gIRbFAguispIHpNKHcyXvY)kG4q9itb)EAguis9hXWNgoMwk43tNgyQU4zlwNgiXQ2gIRbFAguispIHpNKHYfUZ1rmSd1Jmf87PzqHi1FedF60ajUPHc(90XabvN4pIHpnCCtZBqW33iAo2jYo2dKFbdndX1G1w5kj)rmSgnhRABiUg8PzqHi9ig(CsgksRE3Fed7q9itb)E6KyjVeLOtdKyvBdX1GpndkePhXWNtYqzExyqsa(55rGbYt12qCn4tZGcr6rm85KmuVUfLK8hXWQ2gIRbFAguispIHpNKH6eqSGz)Xf(3buuOU4zd8l8roId1JmqEa5imQUOABiUg8PzqHi9ig(CsgQJflfL)igw1w12qCn4tFStYqDSyPO8hXWoupYS1fmRpwSuu(3GGpTGnQUKOngi07)rjDe9XILIYFedtlf87PpwSuu(3GGpnqCTcF00AvBdX1Gp9XojdfPvV7pIHvTnexd(0h7KmuPbMQlE2IvTnexd(0h7KmuSb8mWIDOEKbWy5nGFrFdC)nGFXlUuc40Y3cxXXsIw2aEgyXAG4Af(O5hLOfntpnqI1VUbenqCTcF08JsQ2gIRbF6JDsgQx3aId1JmaglVb8l6BG7Vb8lEXLsaNwWgvxs0YgWZalwdhRABiUg8Pp2jzOGS6j)fxGIpvBdX1Gp9Xojd1RBrjj)rmSQTH4AWN(yNKHkjgt4regPaZ1H6r(ni4ZjYo2dKFbtZBqWN21(UQTH4AWN(yNKHs(ECFUIEXFedRABiUg8Pp2jzOOF6DjkhQhzk43thdeuDI)ig(0PbsCtdDyRlywJikxtaM)igwlyJQljvBdX1Gp9XojdL5DHbjb4NNhbgipvBdX1Gp9XojdfqUbBCH)9gamq6q9itb)E6yGGQt8hXWNonqIBAOdBDbZAer5AcW8hXWAbBuDjPABiUg8Pp2jzOyaSCed7q9itb)E6yGGQt8hXWNonqIBAOdBDbZAer5AcW8hXWAbBuDjPABiUg8Pp2jzOSYvs(JyyhQh5OFW9Uhiicd8lEUCfAq2XEUCfN)Outdf87PzaSCedRHJBH2OPGFpDmqq1j(Jy4tNgiXnn0HTUGznIOCnby(JyyTGnQUKAAqM3qCrV0stdf87PzqHi1FedFAG4Af(GM8DbbZINlxH2Onex0lEblULCqlstdaglVb8l6taXcMp26KkGZZGcrQaIslFlCfhlPwuTnexd(0h7KmualUs(xbehQhzk43tNgyQU4zlwNgiX0(ge85ezh7bYVGP5ni4t7AFx12qCn4tFStYqHikxtaM)ig2H6rMc(90XabvN4pIHpnCmTrtb)EAgalhXW60ajUPXqCrV4fS4wYbTinn0bzEdXf9slQ2gIRbF6JDsgQtaXcM9hx4FhqrH6INnWVWh5ioupYa5bKJWO6cTSb(fwZLR45XNkbAjyGX1GvTnexd(0h7Kmuugay)Id1JSH4IEXlyXTKdAruTnexd(0h7KmugazyXFed7q9itb)E6yGGQt8hXWNgoM2OPGFpndGLJyyDAGe30qhK5nex0lTOABiUg8Pp2jzOSYvs(JyyhQhzk43thdeuDI)ig(0PbsSQTH4AWN(yNKHcruUMam)rmSd1J8BqWh0qZXonexdwBLRK8hXWA0CmTrtb)EAgalhXW60ajUPHoiZBiUOxAr12qCn4tFStYqzaKHf)rmSd1J8BqWh0qZXonexdwBLRK8hXWA0CmTrtb)EAgalhXW60ajUPHoiZBiUOxAr12qCn4tFStYqDSyPO8hXWoupYVbbFor2XEG8lyAEdc(0U23vTnexd(0h7KmuiIY1eG5pIHvTnexd(0h7KmugazyXFedV5lwqleo26wz5L3f]] )
    else
        spec:RegisterPack( "Marksmanship", 20200925.1, [[dGKC6aqiOuEevsytOqFckjmkQuDkQuwfvseVckmlQe7IQ(fkyyqLoMczzOk9mOQAAujPRjKSnOQ4Bqj14GssNdQkzDujvmpH4EOQ2huIdsLuOfII6Hujr5JqjrAKujr6KujLALqrZKkPKBsLu0oHQ8tQKcgkusuTuOKO8uqnvOIVcLeXyPsIQ9c5VuAWuCyrlMkEmstwPUmXMf8zfmAqoTKvtLu1RrrMTIUnQSBv(TudxOoovsLwoWZv10jDDLSDufFxHA8qvPoVqQ1dLQ5Js7hXOriCqW7ufeE8IlV4ocxCXApVJgXl(XQiyn6ybbhNuMYbbbFjNGGDntatpxEpufJGJZONDUr4GG)EbOcc2vqmqQg)UomWWqPqlhpT5y4lU1m1QpkidkdFXrzab7SQP6AFihe8ovbHhV4YlUJWfxS2Z7Or8IFSgbNlfQbiy4IZvgcgQ2B5qoi4T8ueSRGyCntatpxEpuftmUsxNkacMUcIX1avBhbqmyTledV4YlUemjy6kigxlHhzsmr4tmrHRhbpRxFeoiyfuuMEOwFeoi8gHWbbNuT6dbZunN2hQveSCPZu2iMrkcpEr4GGtQw9HG5PNtjAeSCPZu2iMrkcp8JWbbNuT6db7Kaqoiiy5sNPSrmJueEUkcheCs1QpeSGVJN9x8i2hQveSCPZu2iMrkcVOq4GGLlDMYgXmcMckvavIGDwHGxbfLj7d167xXedJednTjvlEeIHrIXzfc(DVCMIvZy)kgbNuT6dbNfNSTpuRifHh(GWbblx6mLnIzemfuQaQeb7ScbVckkt2hQ13VIjggjg3jMe7cOuXhA66LTnuaXlx6mLnXWYsmj2fqPIVoRcjwau0keNhKhtedwiMredllXKyxaLk(FbgQBW(qT(E5sNPSjgwwIrZPCQ)vGKCZ6eVCPZu2eJBi4KQvFiyqgxBBOacsr4H1iCqWYLotzJygbtbLkGkrWoRqWRGIYK9HA99RyIHrIXDIXzfc(yGqRxSpuRVF3JpIHLLyODp394ZNfNSTpuR(WAoTaHcLGbXQfNqmriMKQvF(S4KT9HA1tZxTAXjedllX4ScbVcwYd1QFftmUHGtQw9HGZIt22hQvKIWdRIWbblx6mLnIzemfuQaQeb7ScbVckkt2hQ13VIrWjvR(qWGmU22qbeKIWdFHWbblx6mLnIzemfuQaQeb7ScbVckkt2hQ13V7XhXWYsmoRqWhdeA9I9HA99RyIHrIbBeJZke8kyjpuR(vmXWYsmHMUEIbledwJlcoPA1hcMBn16HAfPi8gHlcheCs1QpeCOPRx22e7cOuX6ijhcwU0zkBeZifH3OriCqWjvR(qWXlqfIUUbRZmFfblx6mLnIzKIWBeViCqWjvR(qW0(OYPGuLTnmtobblx6mLnIzKIWBe(r4GGtQw9HGDMDVTDWQqIvoHlAeSCPZu2iMrkcVrUkcheSCPZu2iMrWuqPcOseSZke8aHY0u(3gAav8RyIHLLyCwHGhiuMMY)2qdOIL2RtfG)1KYeXeHygHlcoPA1hcwHe76C61TTHgqfKIWBuuiCqWjvR(qWPLBb2cW2blf0JFeSCPZu2iMrkcVr4dcheSCPZu2iMrWuqPcOsemqca5HsNPqmmsmyJysQw95FbelNAFTUbFD2WSgGueCs1Qpe8lGy5u7R1nGueEJWAeoi4KQvFi4xLChT9HAfblx6mLnIzKIue8wc5AQiCq4ncHdcoPA1hcM2RtfG9HAfblx6mLnIzKIWJxeoiy5sNPSrmJGtQw9HGNlatc4T191U61BhQGIGPGsfqLiyA3ZDp(8kyjpuREGWL192HL8pXeHygffXWYsmHAasTaHlR7jMied(XfbFjNGGNlatc4T191U61BhQGIueE4hHdcwU0zkBeZi4KQvFi4e7pucY3g6tTDWg3JfacMckvavIGDNyc1aKAbcxw3tmyHysQw9zPDp394JyWGyWVRsmSSeJMGbr9qsoviFmvjMiedV4smSSeJMGbr9AXjwTTXu1YlUeteIzuueJBedJedT75UhFEfSKhQvpq4Y6E7Ws(NyIqmJIIyyzjMqnaPwGWL19eteIb)rHGVKtqWj2FOeKVn0NA7GnUhlaKIWZvr4GGLlDMYgXmcoPA1hcEUEf0R3o0ZTC245IlheemfuQaQebt7EU7XNxbl5HA1deUSU3oSK)jMietuedllXeQbi1ceUSUNyIqm8Ilc(sobbpxVc61Bh65woB8CXLdcsr4ffcheSCPZu2iMrWjvR(qWd5uO5CkG3609HGPGsfqLi4yGWJDGU9J8kyjpuRedllXGnIrZPCQNMZzDdwfsSpuRVxU0zkBIHLLyc1aKAbcxw3tmriMr4IGVKtqWd5uO5CkG3609HueE4dcheSCPZu2iMrWjvR(qW5dXtEYBbj2BGL2GCIGPGsfqLi4yGWJDGU9J8kyjpuRedJeJ7eJZke8dReSR8SDWMyxaTc5xXedllXGnIr(xoQ4P9TL7LTDwbj0aQ45sxFdiggjgAAtQw8ieJBedllXSfNvi4bj2BGL2GCA3IZke87E8rmSSetOgGulq4Y6EIjcXWlUi4l5eeC(q8KN8wqI9gyPniNifHhwJWbblx6mLnIzeCs1QpeCCtzs0VWUST0MlEPPw9z3cpfvqWuqPcOsem2igNvi4vWsEOw9RyIHrIbBeJ8VCuX7m7EB7GvHeRCcx0EU013aIHLLy2IZke8oZU32oyviXkNWfTFftmSSetOgGulq4Y6EIjcXefc(sobbh3uMe9lSlBlT5IxAQvF2TWtrfKIWdRIWbblx6mLnIzemfuQaQebhdeESd0TFKxbl5HALyyzjgSrmAoLt90CoRBWQqI9HA99YLotztmSSetOgGulq4Y6EIjcXWlUi4KQvFi41l2sfUhPi8WxiCqWYLotzJygbNuT6dbtZ50MuT6ZoRxrWZ6v7LCccMUFKIWBeUiCqWYLotzJygbtbLkGkrWjvlEeRCcxjpXeHyWpcoPA1hcMMZPnPA1NDwVIGN1R2l5ee8RifH3OriCqWYLotzJygbtbLkGkrWjvlEeRCcxjpXGfIHxeCs1QpemnNtBs1Qp7SEfbpRxTxYjiyfuuMEOwFKIueCmqOnNtQiCq4ncHdcwU0zkBeZi4yGqZxTAXji4r4IGtQw9HG39YzkwnJrkcpEr4GGLlDMYgXmc(sobbNy)Hsq(2qFQTd24ESaqWjvR(qWj2FOeKVn0NA7GnUhlaKIWd)iCqWjvR(qWJBWCZJuNfiFF5rfeSCPZu2iMrkcpxfHdcoPA1hcEyLGDLNTd2e7cOvieSCPZu2iMrkcVOq4GGtQw9HG5eUgeTTd25IwB7gij3JGLlDMYgXmsr4HpiCqWYLotzJygbhdeA(QvlobbpYhfcoPA1hcwbl5HAfbtbLkGkrWjvlEeRCcxjpXGfIHxKIWdRr4GGLlDMYgXmcoPA1hcoU1Qpe8o6l5kQngiXTIGhHueEyveoiy5sNPSrmJGPGsfqLi4KQfpIvoHRKNyIqm4hbNuT6dbNfNSTpuRifPiy6(r4GWBecheSCPZu2iMrWuqPcOsemT75UhFEqgxBBOaIhiCzDpXeHygOBIHLLyODp394ZdY4ABdfq8aHlR7jMiedT75UhF(S4KT9HA1deUSUNyyzjMqnaPwGWL19eteIHxCrWjvR(qW7E5mfRMXifHhViCqWYLotzJygbtbLkGkrWXaHh7aD7h5vWsEOwjggjg3jMqnaPwGWL19edwigA3ZDp(8oc4fat1n43lqQvFedgeZEbsT6Jyyzjg3jgnbdI6HKCQq(yQsmrigEXLyyzjgSrmAoLt90eiH10MfNxU0zkBIXnIXnIHLLyc1aKAbcxw3tmriMr4hbNuT6db7iGxamv3asr4HFeoiy5sNPSrmJGPGsfqLi4yGWJDGU9J8kyjpuRedJeJ7etOgGulq4Y6EIbledT75UhFENz3BBybI2VxGuR(igmiM9cKA1hXWYsmUtmAcge1dj5uH8XuLyIqm8IlXWYsmyJy0CkN6PjqcRPnloVCPZu2eJBeJBedllXeQbi1ceUSUNyIqmJWheCs1QpeSZS7TnSarJueEUkcheSCPZu2iMrWuqPcOseCmq4Xoq3(rEfSKhQvIHrIXDIjudqQfiCzDpXGfIH29C3JpFEu5vqoT0Co97fi1QpIbdIzVaPw9rmSSeJ7eJMGbr9qsoviFmvjMiedV4smSSed2ignNYPEAcKWAAZIZlx6mLnX4gX4gXWYsmHAasTaHlR7jMieZi8bbNuT6dbNhvEfKtlnNtKIWlkeoiy5sNPSrmJGPGsfqLi4yGWJDGU9J8kyjpuRedJeJ7etOgGulq4Y6EIbledT75UhF(qbeNz3B)EbsT6JyWGy2lqQvFedllX4oXOjyqupKKtfYhtvIjcXWlUedllXGnIrZPCQNMajSM2S48YLotztmUrmUrmSSetOgGulq4Y6EIjcXGVqWjvR(qWHcioZU3ifHh(GWbblx6mLnIzemfuQaQeb7ScbVcwYd1QF3JpeCs1Qpe8SgG0366x7bo5uKIWdRr4GGLlDMYgXmcMckvavIGDwHGxbl5HA1V7XhcoPA1hc2jhSDWQGIY0JueEyveoiy5sNPSrmJGPGsfqLiyNvi4vWsEOw97E8rmmsmUtmAcge1dj5uH8XuLyWcXGvXLyyzjgnbdI6HKCQq(yQsmr4tm8IlXWYsmAcge1RfNy12gtvlV4smyHyWpUeJBi4KQvFiyGKX1nydZKtEKIWdFHWbblx6mLnIzemfuQaQeb7oXq7EU7XNpX(dLG8TH(uBhSX9yb4bcxw3tmyHy4fxIHLLyWgXiUURkow2(e7pucY3g6tTDWg3JfaXWYsmHAasTaHlR7jMiedT75UhF(e7pucY3g6tTDWg3JfGFVaPw9rmyqm43vjggjgnbdI6HKCQq(yQsmyHy4fxIXnIHrIXDIH29C3JpVcwYd1QhiCzDVDyj)tmrig8tmSSeJ7eJ8VCuXZt9vF2oyJfqqOA1NNRUgqmmsmHAasTaHlR7jgSqmjvR(S0UN7E8rmyqmoRqWpUbZnpsDwG89Lhv87fi1QpIXnIXnIHLLyc1aKAbcxw3tmrigEXfbNuT6dbpUbZnpsDwG89LhvqkcVr4IWbblx6mLnIzemfuQaQeb7oXqtBs1IhHyyzjMqnaPwGWL19edwiMKQvFwA3ZDp(igmig8JlX4gXWiX4oX4ScbVcwYd1QFftmSSedT75UhFEfSKhQvpq4Y6EIjcXmcFig3igwwIjudqQfiCzDpXeHyW)ieCs1Qpe8Wkb7kpBhSj2fqRqifH3OriCqWYLotzJygbtbLkGkrW0UN7E85vWsEOw9aHlR7jMiedwJGtQw9HGbvC8uS1z)4KkifH3iEr4GGLlDMYgXmcMckvavIGXgX4ScbVcwYd1QFfJGtQw9HG5eUgeTTd25IwB7gij3JueEJWpcheSCPZu2iMrWuqPcOseSZke8kyjpuREGKuLyyKyCwHG3z29EUE1dKKQedllXedeESd0TFKxbl5HALyyKy0emiQhsYPc5JPkXeHy4fxIHLLyCNyCNyO99lU0zk(4wR(SDWUohqTNY2gwGOjgwwIH23V4sNP4xNdO2tzBdlq0eJBedJetOgGulq4Y6EIjcXGpJigwwIjudqQfiCzDpXeHy4fFig3qWjvR(qWXTw9HueEJCveoiy5sNPSrmJGPGsfqLiyNvi4vWsEOw97E8rmmsm0UN7E85bzCTTHciEGWL19edllXeQbi1ceUSUNyIqmJIcbNuT6dbRGL8qTIuKIGFfHdcVriCqWjvR(qWmvZP9HAfblx6mLnIzKIWJxeoi4KQvFiybFhp7V4rSpuRiy5sNPSrmJueE4hHdcwU0zkBeZiykOubujcoPAXJyLt4k5jgSqmJqWjvR(qWojaKdcsr45QiCqWjvR(qWPLBb2cW2blf0JFeSCPZu2iMrkcVOq4GGtQw9HG5PNtjAeSCPZu2iMrkcp8bHdcwU0zkBeZiykOubujcgibG8qPZuiggjgSrmjvR(8VaILtTVw3GVoBywdqkcoPA1hc(fqSCQ916gqkcpSgHdcwU0zkBeZiykOubujc2zfcEfSKhQv)UhFedllXeA66jMied(JIyyzjMqtxpXeHyWhCjggjgSrmAoLt9trHYP9HA99YLotztmSSeJZke81zviXcGIwH48aHlR7jMieJGVf6sfRwCccoPA1hcgKX12gkGGueEyveoiy5sNPSrmJGPGsfqLiyNvi4vWsEOw9RyIHrIXDIXzfc(1jaqDdwEQV6Z)AszIyWcX4QedllXGnIjXUakv8RtaG6gS8uF1NxU0zkBIXnIHLLyc1aKAbcxw3tmriMrJqWjvR(qWoZU32oyviXkNWfnsr4HVq4GGLlDMYgXmcMckvavIGXgX4ScbVcwYd1QFftmSSetOgGulq4Y6EIjcXefcoPA1hco001lBBIDbuQyDKKdPi8gHlcheSCPZu2iMrWuqPcOseSZke8kyjpuR(vmXWYsmUtmoRqWV7LZuSAg7394JyyzjgAAtQw8ieJBedJeJZke8XaHwVyFOwF)UhFedllXewZPfiuOemiwT4eIjcXqZxTAXjedJedT75UhFEfSKhQvpq4Y6EeCs1QpeCwCY2(qTIueEJgHWbblx6mLnIzemfuQaQebJnIXzfcEfSKhQv)kMyyzjMqnaPwGWL19eteIbRIGtQw9HGJxGkeDDdwNz(ksr4nIxeoiy5sNPSrmJGPGsfqLi4qtxpXGbXeA669azqoIXvcXmq3eteIj00175s8nXWiX4ScbVcwYd1QF3JpIHrIXDIbBeZUvpTpQCkivzBdZKtSolW5bcxw3tmmsmyJysQw95P9rLtbPkBByMCIVoBywdqkX4gXWYsmH1CAbcfkbdIvloHyIqmd0nXWYsmHAasTaHlR7jMietui4KQvFiyAFu5uqQY2gMjNGueEJWpcheSCPZu2iMrWuqPcOseSZke8aHY0u(3gAav8RyIHLLyCwHGhiuMMY)2qdOIL2RtfG)1KYeXeHygHlXWYsmHAasTaHlR7jMietui4KQvFiyfsSRZPx32gAavqkcVrUkcheSCPZu2iMrWuqPcOseSZke8kyjpuR(Dp(iggjg3jgNvi4JbcTEX(qT((vmXWiX4oXeA66jgSqmrffX4gXWYsmHMUEIbledwhfXWYsmHAasTaHlR7jMietueJBi4KQvFi4eqZtSpuRifH3OOq4GGLlDMYgXmcMckvavIGDwHGxbl5HA1V7XhXWiX4oX4ScbFmqO1l2hQ13VIjggjg3jMqtxpXGfIjQOig3igwwIj001tmyHyW6OigwwIjudqQfiCzDpXeHyIIyCdbNuT6dbtHkUuaP9HAfPi8gHpiCqWjvR(qWVk5oA7d1kcwU0zkBeZifPifbZJa(QpeE8IlV4Il(I3O84IVWfR5DecECcU6gEemwjUgXkdpxB8Wk11HyigCGeIP4IBGsmHgqmyf09JvqmaX1DvaztmFZjetU0MlvztmuO8gK3tW01QoHyWxUoeJRS(4raQSjgScfuhtI6DL7PDp394dRGy0MyWkODp394Z7khRGyCNx8TBEcMemDT5IBGkBIjkIjPA1hXmRxFpbteCmOd1uqWUcIX1mbm9C59qvmX4kDDQaiy6kigxduTDeaXG1Uqm8IlV4sWKGPRGyCTeEKjXeHpXefUEcMemDfedw5aHMVsmku9et(eJKGz0et(etC)F5mfIrBIjUv50kNZOjMHSoIjVwHeaXqZxjM9cu3aXOqcXeQbi1tWmPA137JbcT5Csfd(mS7LZuSAg7smqO5RwT4e(JWLGzs1QV3hdeAZ5Kkg8zy9ITuHZLl5e(j2FOeKVn0NA7GnUhlacMjvR(EFmqOnNtQyWNHXnyU5rQZcKVV8OcbZKQvFVpgi0MZjvm4ZWWkb7kpBhSj2fqRqemtQw99(yGqBoNuXGpdCcxdI22b7CrRTDdKK7jyMuT679XaH2CoPIbFguWsEOwDjgi08vRwCc)r(OCPc8tQw8iw5eUsESWlbZKQvFVpgi0MZjvm4ZqCRvFUSJ(sUIAJbsCR8hrWmPA137JbcT5Csfd(mKfNSTpuRUub(jvlEeRCcxjFe8tWKGzs1QVhd(mq71PcW(qTsWmPA13JbFgwVylv4C5soH)CbysaVTUV2vVE7qfuxQaFA3ZDp(8kyjpuREGWL192HL8FKrrXYgQbi1ceUSUpc(XLGzs1QVhd(mSEXwQW5YLCc)e7pucY3g6tTDWg3JfGlvGV7HAasTaHlR7XcT75UhFyGFxLLvtWGOEijNkKpMQr4fxwwnbdI61ItSABJPQLxCJmkk3yK29C3JpVcwYd1QhiCzDVDyj)hzuuSSHAasTaHlR7JG)OiyMuT67XGpdRxSLkCUCjNWFUEf0R3o0ZTC245IlhexQaFA3ZDp(8kyjpuREGWL192HL8FKOyzd1aKAbcxw3hHxCjyMuT67XGpdRxSLkCUCjNWFiNcnNtb8wNUpxQa)yGWJDGU9J8kyjpuRSSytZPCQNMZzDdwfsSpuRVxU0zkBw2qnaPwGWL19rgHlbZKQvFpg8zy9ITuHZLl5e(5dXtEYBbj2BGL2GC6sf4hdeESd0TFKxbl5HALr3DwHGFyLGDLNTd2e7cOvi)kMLfBY)YrfpTVTCVSTZkiHgqfpx66BaJ00MuT4rCJLDloRqWdsS3alTb50UfNvi4394JLnudqQfiCzDFeEXLGzs1QVhd(mSEXwQW5YLCc)4MYKOFHDzBPnx8stT6ZUfEkQ4sf4JnNvi4vWsEOw9RygXM8VCuX7m7EB7GvHeRCcx0EU013aw2T4ScbVZS7TTdwfsSYjCr7xXSSHAasTaHlR7JefbtxbXGdiAIrBIzwNqmRyIjPAXtQYMyuqDmj6tmJlfIyWbSKhQvcMjvR(Em4ZW6fBPc37sf4hdeESd0TFKxbl5HALLfBAoLt90CoRBWQqI9HA99YLotzZYgQbi1ceUSUpcV4sWmPA13JbFgO5CAtQw9zN1RUCjNWNUFcMjvR(Em4ZanNtBs1Qp7SE1Ll5e(V6sf4NuT4rSYjCL8rWpbZKQvFpg8zGMZPnPA1NDwV6YLCcFfuuMEOwFxQa)KQfpIvoHRKhl8sWKGzs1QV3t3pg8zy3lNPy1m2LkWN29C3JppiJRTnuaXdeUSUpYaDZYs7EU7XNhKX12gkG4bcxw3hH29C3JpFwCY2(qT6bcxw3ZYgQbi1ceUSUpcV4sWmPA137P7hd(m4iGxamv3GlvGFmq4Xoq3(rEfSKhQvgDpudqQfiCzDpwODp394Z7iGxamv3GFVaPw9HXEbsT6JL1DnbdI6HKCQq(yQgHxCzzXMMt5upnbsynTzX5LlDMY2n3yzd1aKAbcxw3hze(jyMuT67909JbFgCMDVTHfiAxQa)yGWJDGU9J8kyjpuRm6EOgGulq4Y6ESq7EU7XN3z292gwGO97fi1Qpm2lqQvFSSURjyqupKKtfYht1i8Illl20CkN6PjqcRPnloVCPZu2U5glBOgGulq4Y6(iJWhcMjvR(EpD)yWNH8OYRGCAP5C6sf4hdeESd0TFKxbl5HALr3d1aKAbcxw3JfA3ZDp(85rLxb50sZ50VxGuR(WyVaPw9XY6UMGbr9qsoviFmvJWlUSSytZPCQNMajSM2S48YLotz7MBSSHAasTaHlR7JmcFiyMuT67909JbFgcfqCMDVDPc8Jbcp2b62pYRGL8qTYO7HAasTaHlR7XcT75UhF(qbeNz3B)EbsT6dJ9cKA1hlR7Acge1dj5uH8XuncV4YYInnNYPEAcKWAAZIZlx6mLTBUXYgQbi1ceUSUpc(IGzs1QV3t3pg8zywdq6BD9R9aNCQlvGVZke8kyjpuR(Dp(iyMuT67909JbFgCYbBhSkOOm9Uub(oRqWRGL8qT6394JGzs1QV3t3pg8zaizCDd2Wm5K3LkW3zfcEfSKhQv)UhFm6UMGbr9qsoviFmvXcwfxwwnbdI6HKCQq(yQgHpV4YYQjyquVwCIvBBmvT8IlwWpUUrWmPA137P7hd(mmUbZnpsDwG89LhvCPc8Dxb1XKO(e7pucY3g6tTDWg3JfGN29C3Jppq4Y6ESWlUSSytCDxvCSS9j2FOeKVn0NA7GnUhlaw2qnaPwGWL19ruqDmjQpX(dLG8TH(uBhSX9yb4PDp394ZVxGuR(Wa)UkJAcge1dj5uH8Xufl8IRBm6oT75UhFEfSKhQvpq4Y6E7Ws(pc(zzDx(xoQ45P(QpBhSXciiuT6ZZvxdymudqQfiCzDpwODp394ddNvi4h3G5MhPolq((YJk(9cKA1NBUXYgQbi1ceUSUpcV4sWmPA137P7hd(mmSsWUYZ2bBIDb0kKlvGV700MuT4ryzd1aKAbcxw3JfA3ZDp(Wa)46gJU7ScbVcwYd1QFfZYs7EU7XNxbl5HA1deUSUpYi8Xnw2qnaPwGWL19rW)icMjvR(EpD)yWNbqfhpfBD2poPIlvGpT75UhFEfSKhQvpq4Y6(iynbZKQvFVNUFm4ZaNW1GOTDWox0AB3aj5ExQaFS5ScbVcwYd1QFftWmPA137P7hd(me3A1NlvGVZke8kyjpuREGKuLrNvi4DMDVNRx9ajPklBmq4Xoq3(rEfSKhQvg1emiQhsYPc5JPAeEXLL1D3P99lU0zk(4wR(SDWUohqTNY2gwGOzzP99lU0zk(15aQ9u22WceTBmgQbi1ceUSUpc(mILnudqQfiCzDFeEXh3iyMuT67909JbFguWsEOwDPc8DwHGxbl5HA1V7XhJ0UN7E85bzCTTHciEGWL19SSHAasTaHlR7JmkkcMemtQw99(xXGpdmvZP9HALGzs1QV3)kg8zqW3XZ(lEe7d1kbZKQvFV)vm4ZGtca5G4sf4NuT4rSYjCL8yzebZKQvFV)vm4ZqA5wGTaSDWsb94NGzs1QV3)kg8zGNEoLOjyMuT679VIbFgEbelNAFTUbxQaFGeaYdLotHrSLuT6Z)ciwo1(ADd(6SHznaPemtQw99(xXGpdGmU22qbexQaFNvi4vWsEOw97E8XYgA66JG)OyzdnD9rWhCzeBAoLt9trHYP9HA99YLotzZY6ScbFDwfsSaOOviopq4Y6(ic(wOlvSAXjemtQw99(xXGpdoZU32oyviXkNWfTlvGVZke8kyjpuR(vmJU7Scb)6eaOUblp1x95FnPmHfxLLfBj2fqPIFDcau3GLN6R(8YLotz7glBOgGulq4Y6(iJgrWmPA137Ffd(meA66LTnXUakvSosY5sf4JnNvi4vWsEOw9Ryw2qnaPwGWL19rIIGzs1QV3)kg8zilozBFOwDPc8DwHGxbl5HA1VIzzD3zfc(DVCMIvZy)UhFSS00MuT4rCJrNvi4JbcTEX(qT((Dp(yzdR50cekucgeRwCseA(QvloHrA3ZDp(8kyjpuREGWL19emtQw99(xXGpdXlqfIUUbRZmF1LkWhBoRqWRGL8qT6xXSSHAasTaHlR7JGvjyMuT679VIbFgO9rLtbPkBByMCIlvGFOPRhJqtxVhidY5kzGUJeA669Cj(MrNvi4vWsEOw97E8XO7yB3QN2hvofKQSTHzYjwNf48aHlR7zeBjvR(80(OYPGuLTnmtoXxNnmRbi1nw2WAoTaHcLGbXQfNezGUzzd1aKAbcxw3hjkcMjvR(E)RyWNbfsSRZPx32gAavCPc8DwHGhiuMMY)2qdOIFfZY6ScbpqOmnL)THgqflTxNka)RjLPiJWLLnudqQfiCzDFKOiyMuT679VIbFgsanpX(qT6sf47ScbVcwYd1QF3JpgD3zfc(yGqRxSpuRVFfZO7HMUESevuUXYgA66XcwhflBOgGulq4Y6(ir5gbZKQvFV)vm4ZafQ4sbK2hQvxQaFNvi4vWsEOw97E8XO7oRqWhdeA9I9HA99RygDp001JLOIYnw2qtxpwW6Oyzd1aKAbcxw3hjk3iyMuT679VIbFgEvYD02hQvcMemtQw99EfuuMEOwFm4Zat1CAFOwjyMuT679kOOm9qT(yWNbE65uIMGzs1QV3RGIY0d16JbFgCsaihecMjvR(EVckktpuRpg8zqW3XZ(lEe7d1kbZKQvFVxbfLPhQ1hd(mKfNSTpuRUub(oRqWRGIYK9HA99RygPPnPAXJWOZke87E5mfRMX(vmbZKQvFVxbfLPhQ1hd(maY4ABdfqCPc8DwHGxbfLj7d167xXm6EIDbuQ4dnD9Y2gkG4LlDMYMLnXUakv81zviXcGIwH48G8yclJyztSlGsf)Vad1nyFOwFVCPZu2SSAoLt9VcKKBwN4LlDMY2ncMjvR(EVckktpuRpg8zilozBFOwDPc8DwHGxbfLj7d167xXm6UZke8XaHwVyFOwF)UhFSS0UN7E85ZIt22hQvFynNwGqHsWGy1ItIKuT6ZNfNSTpuREA(QvloHL1zfcEfSKhQv)k2ncMjvR(EVckktpuRpg8zaKX12gkG4sf47ScbVckkt2hQ13VIjyMuT679kOOm9qT(yWNbU1uRhQvxQaFNvi4vqrzY(qT((Dp(yzDwHGpgi06f7d167xXmInNvi4vWsEOw9Ryw2qtxpwWACjyMuT679kOOm9qT(yWNHqtxVSTj2fqPI1rsocMjvR(EVckktpuRpg8ziEbQq01nyDM5RemtQw99EfuuMEOwFm4ZaTpQCkivzBdZKtiyMuT679kOOm9qT(yWNbNz3BBhSkKyLt4IMGzs1QV3RGIY0d16JbFguiXUoNEDBBObuXLkW3zfcEGqzAk)BdnGk(vmlRZke8aHY0u(3gAavS0EDQa8VMuMImcxcMjvR(EVckktpuRpg8ziTClWwa2oyPGE8tWmPA137vqrz6HA9XGpdVaILtTVw3GlvGpqca5HsNPWi2sQw95FbelNAFTUbFD2WSgGucMjvR(EVckktpuRpg8z4vj3rBFOwrWFSqr4XBuUksrkcb]] )
    end

end