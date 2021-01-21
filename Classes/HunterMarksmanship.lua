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
            aura = "death_chakram",

            last = function ()
                return state.buff.death_chakram.applied + floor( state.query_time - state.buff.death_chakram.applied )
            end,

            interval = function () return class.auras.death_chakram.tick_time end,
            value = function () return state.conduit.necrotic_barrage.enabled and 5 or 3 end,
        },
        rapid_fire = {
            channel = "rapid_fire",

            last = function ()
                local app = state.buff.casting.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.rapid_fire.tick_time ) * class.auras.rapid_fire.tick_time
            end,

            interval = function () return class.auras.rapid_fire.tick_time * ( state.buff.trueshot.up and 0.667 or 1 ) end,
            value = 1,
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
            tick_time = function ()
                return ( 2 * haste ) / ( buff.double_tap.up and 14 or 7 )
            end,
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

        if debuff.tar_trap.up then
            debuff.tar_trap.expires = debuff.tar_trap.applied + 30
        end

        if now - action.volley.lastCast < 6 then applyBuff( "volley", 6 - ( now - action.volley.lastCast ) ) end

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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            spend = function () return buff.lock_and_load.up and 0 or ( ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 35 ) end,
            spendType = "focus",

            startsCombat = true,
            texture = 135130,

            cycle = function () return runeforge.serpentstalkers_trickery.enabled and "serpent_sting" or nil end,

            usable = function ()
                if action.aimed_shot.cast > 0 and moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
                return true
            end,

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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 30 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 10 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            startsCombat = false,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            spend = 0,
            spendType = "focus",

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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 10 end,
            spendType = "focus",

            startsCombat = true,
            texture = 1033905,

            velocity = 45,

            talent = "serpent_sting",

            impact = function ()
                applyDebuff( "target", "serpent_sting" )
            end,
        },


        steady_shot = {
            id = 56641,
            cast = 1.8,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.trueshot.up and -15 or -10 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132213,

            handler = function ()
                if talent.steady_focus.enabled and prev[1].steady_shot and action.steady_shot.lastCast > last_steady_focus then
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
            cooldown = function () return level > 55 and 25 or 30 end,
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
            gcd = "off",

            spend = 0,
            spendType = "focus",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 132329,

            nobuff = function ()
                if settings.trueshot_vop_overlap then return end
                return "trueshot"
            end,

            handler = function ()
                focus.regen = focus.regen * 1.5
                reduceCooldown( "aimed_shot", ( 1 - 0.3077 ) * 12 * haste )
                reduceCooldown( "rapid_fire", ( 1 - 0.3077 ) * 20 * haste )
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

            spend = 0,
            spendType = "focus",

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

        potion = "spectral_agility",

        package = "Marksmanship",
    } )

    
    spec:RegisterSetting( "prevent_hardcasts", false, {
        name = "Prevent Hardcasts of |T135130:0|t Aimed Shot During Movement",
        desc = "If checked, the addon will not recommend |T135130:0|t Aimed Shot if it has a cast time and you are moving.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Marksmanship", 20201220, [[dOuJ)aqikv1JGQk2euXNaWOeHoLi4vqLMffYTOuc7IKFrPyyuGoMiAzuqpdQQAAukvxJcyBae(gGcnoOQsohLsX6OuL5rH6EuI9bqDqkLKwiLkpeqPjsPe5Iukj(iLsjJKsPuojGIwPizMaKUjarStus)Ksj1sHQk1trXuHQCvkLs1xPuIASqvzVO6VqzWqoSKflWJj1Kf6YiBwfFgOgnfDAfRgGi9Aaz2I62cA3s9BQgok1XbiQLd65QA6exxL2Ui13PKgpGQZJsSEafmFGSFLMNKJhNjwcXz1qdAObtAOHguzqBJbSDdMKZiSWM4mSlnqfyIZ0viXzaKuqG(WQFZHnNHDXs2RihpoZ7xOM4m4Nfzkc73E2yd4rmVbkThAZpH3CjJ3AyDeB(juBdNj4ozby28aotSeIZQHg0qdM0qdnOYG2gdG)gWaCM6kMoKZWmHalNXCIrQ5bCMi9Aod(zraskiqFy1V5WEr22UTqWnf(zr2sKMcdi4Im0GgTidnOHgKZKNxEoECgboAGEtxEoECwtYXJZqDfKPi3ooJgocbNIZivMAr9cvrwWoU((kQRGmfxeolAAStEaBklcNffCph1lufzb7467RGuyn9ViJxKb4mLwgV5mVqvKfS30fUWz1qoECgQRGmf52Xz0Wri4uCgTNM6QffqSaNQxeols7Eo6wBfKEVlzAWyfe6wvqkSM(xKXlcSoUiqGwK9xK2ttD1IciwGt1lcNfz)fP90uxTO6bSPGDkArGaTiTNM6QfvpGnfStrlcNfL4I0UNJU1wzDYrSN9ah5vqkSM(xKXlcSoUiqGwK29C0T2kbEP30ffKcRP)fb4fzadSOeweiqlskiysuYesyIJfhArgVOKgKZuAz8MZe9BqMWKInx4SI)C84muxbzkYTJZOHJqWP4mWBthhcMuVFZhhcMWOWac(kQRGmfxeolskiMal2kifwt)lY4fbwhxeols7Eo6wB1jxqsbPWA6FrgViW6iNP0Y4nNrkiMal2CHZQTZXJZqDfKPi3ootPLXBoZjxqIZOHJqWP4msbXeyXwDzViCwe820XHGj1738XHGjmkmGGVI6kitrotEActh5mgAaUWz1aC84mLwgV5meWzN9FstyVPlCgQRGmf52XfoRacoECMslJ3CgRtoI9Sh4ipNH6kitrUDCHZkWihpotPLXBodKEVlzAWyfe6w5muxbzkYTJlCwXV44XzkTmEZzs75mXcNH6kitrUDCHZQTHJhNP0Y4nNjOGWcmXzOUcYuKBhx4SM0GC84mLwgV5mc8sVPlCgQRGmf52XfoRjtYXJZqDfKPi3ooJgocbNIZeCphLahnqyVPlVcsH10)IaSLfraN0xHWKjKweolcEB64qWK6VqWtdg7nD5vuxbzkUiCwuW9Cur)gKjmPyRIU1MZuAz8MZal2te7mqIlCwtAihpod1vqMIC74mLwgV5m1esrS30foJgocbNIZeCphLahnqyVPlVcsH10)IaSLfraN0xHWKjKweolkXffCphfBiPNNWEtxEv0T2lceOfDU5mgK0MfemHjtiTiJxKUEbtMqAr4UiW64IabArb3ZrjWl9MUOUSxucCgnl6mHjfemjpN1KCHZAs8NJhNH6kitrUDCgnCecofN5467ViCxKUEbdsGPErgVOJRVVkSaoNP0Y4nNjsLyIPnlGGvix4SM0254XzOUcYuKBhNrdhHGtXzcUNJsGJgiS30LxbPWA6Fra2YIiGt6RqyYesCMslJ3CgyXEIyNbsCHZAsdWXJZqDfKPi3ooJgocbNIZeCphLahnqyVPlVk6w7fbc0IcUNJInK0ZtyVPlV6YEr4SOJRV)Ia8I0(llc3fvAz8wvtifXEtxuA)LfHZIsCr2FrsLPwuAZjSiyH9MUOOUcYuCrGaTOsltAcJAkCOFraEr4)IsGZuAz8MZeEZY8MUWfoRjbeC84muxbzkYTJZOHJqWP4mb3ZrXgs65jS30LxDzViCw0X13FraErA)LfH7IkTmERQjKIyVPlkT)YIWzrLwM0eg1u4q)ImEr2oNP0Y4nNrBoHfblS30fUWznjWihpod1vqMIC74mA4ieCkotW9CurQIyelKk6wBotPLXBodqtoJ9MUWfoRjXV44XzkTmEZzkSWlmsqm)GPHU1NZqDfKPi3oUWznPTHJhNP0Y4nN5KlwOi2B6cNH6kitrUDCHZQHgKJhNH6kitrUDCMslJ3CMNGSPwWEzAWCgnCecofNbshi9MvqM4mAw0zctkiysEoRj5cNvdtYXJZqDfKPi3ooJgocbNIZCC99xeGxK2Fzr4UOslJ3QAcPi2B6Is7VWzkTmEZzcVzzEtx4cNvdnKJhNP0Y4nN5fQISG9MUWzOUcYuKBhx4cNjsN6MfoECwtYXJZuAz8MZO9Blee7nDHZqDfKPi3oUWz1qoECgQRGmf52XzkTmEZz0(TfcI9MUWz0Wri4uCg4TPJdbtQNyBEbgEm2qxNRWsgVvuxbzkUiqGw073CW0rvpSupM4E(Xy7Z7TI6kitXfbc0IsCrAVJ3ruqknb)kJ5hSJdLBtkQRGmfxeolY(lcEB64qWK6j2MxGHhJn015kSKXBf1vqMIlkbotEActh5m4Vb5cNv8NJhNP0Y4nNrGvdiFN8ammnyS30fod1vqMIC74cNvBNJhNH6kitrUDCMUcjotesv8mqcln9pL5mLwgV5mrivXZajS00)uMlCwnahpod1vqMIC74mA4ieCkotW9Cuc8sVPlQl7fbc0IcUNJsGx6nDrfDR9IWzrA3Zr3ARe4LEtxuqkSM(xeGxKHgCrGaTOZa2uWGuyn9ViJxK29C0T2kbEP30ffKcRPFotPLXBoZ9jSrOWNlCwbeC84muxbzkYTJZuAz8MZORCgR0Y4nwEEHZKNxW6kK4m64ZfoRaJC84muxbzkYTJZOHJqWP4mLwM0eg1u4q)ImEr4pNP0Y4nNrx5mwPLXBS88cNjpVG1viXzEHlCwXV44XzOUcYuKBhNrdhHGtXzkTmPjmQPWH(fb4fziNP0Y4nNrx5mwPLXBS88cNjpVG1viXze4Ob6nD55cx4mSHK2ddkHJhN1KC84mLwgV5mbUizkIDYflu060GXeh4tZzOUcYuKBhx4SAihpod1vqMIC74mA4ieCkod820XHGj1738XHGjmkmGGVI6kitrotPLXBoJuqmbwS5cNv8NJhNH6kitrUDCg2qsxVGjtiXzsAqotPLXBot0Vbzctk2CgnCecofNP0YKMWOMch6xeGxuYfbc0IS)I0EAQRwuaXcCQEr4Si7ViPYulQ0EotSOOUcYuKlCwTDoECgQRGmf52Xz0Wri4uCMsltAcJAkCOFrgVi8Fr4SOexK9xK2ttD1IciwGt1lcNfz)fjvMArL2ZzIff1vqMIlceOfvAzstyutHd9lY4fz4IsGZuAz8MZutifXEtx4cNvdWXJZqDfKPi3ooJgocbNIZuAzstyutHd9lcWlYWfbc0IsCrApn1vlkGybovViqGwKuzQfvApNjwuuxbzkUOeweolQ0YKMWOMch6xKLfziNP0Y4nN5fQISG9MUWfUWz0XNJhN1KC84muxbzkYTJZOHJqWP4mb3ZrjWl9MUOUSxeiql6mGnfmifwt)lY4fLe)5mLwgV5mbe8jiqtdMlCwnKJhNH6kitrUDCgnCecofNj4EokbEP30f1L9IabArNbSPGbPWA6FrgVOKacotPLXBotq29i25czHlCwXFoECgQRGmf52Xz0Wri4uCMG75Oe4LEtxux2lceOfDgWMcgKcRP)fz8Isci4mLwgV5mvRPxGvgtx5mx4SA7C84muxbzkYTJZOHJqWP4mb3ZrjWl9MUOUSxeiql6mGnfmifwt)lY4fzB4mLwgV5mNbsbz3JCHZQb44XzOUcYuKBhNrdhHGtXzcUNJsGx6nDrfDRnNP0Y4nNjpGnLhdq6ncoKAHlCwbeC84muxbzkYTJZOHJqWP4mb3ZrjWl9MUOIU1MZuAz8MZeuGX8dMahnqpx4ScmYXJZqDfKPi3ooJgocbNIZeCphLaV0B6I6YEr4SOG75OcYUhZ3xux2lceOffCphLaV0B6I6YEr4SiPGGjrzsvwmvS1YImErgAWfbc0IodytbdsH10)ImErgci4mLwgV5mSDz8MlCHZ8chpoRj54XzOUcYuKBhNrdhHGtXzKktTOEHQilyhxFFf1vqMIlcNfL4IydP0yG1rvs1lufzb7nDzr4SOG75OEHQilyhxFFfKcRP)fz8ImWIabArb3Zr9cvrwWoU((QOBTxucCMslJ3CMxOkYc2B6cx4SAihpotPLXBodqtoJ9MUWzOUcYuKBhx4SI)C84muxbzkYTJZOHJqWP4mApn1vlkGybovViCwK29C0T2ki9ExY0GXki0TQGuyn9ViJxeyDCrGaTi7ViTNM6QffqSaNQxeolY(ls7PPUAr1dytb7u0IabArApn1vlQEaBkyNIweolkXfPDphDRTY6KJyp7boYRGuyn9ViJxeyDCrGaTiT75OBTvc8sVPlkifwt)lcWlYagyrjSiqGwKuqWKOKjKWehlo0ImErjnaNP0Y4nNj63GmHjfBUWz1254XzOUcYuKBhNP0Y4nN5KliXz0Wri4uCgPGycSyRUSxeolcEB64qWK69B(4qWegfgqWxrDfKPiNjpnHPJCgdnax4SAaoECgQRGmf52Xz0Wri4uCg4TPJdbtQ3V5JdbtyuyabFf1vqMIlcNfjfetGfBfKcRP)fz8IaRJlcNfPDphDRT6KliPGuyn9ViJxeyDKZuAz8MZifetGfBUWzfqWXJZuAz8MZqaND2)jnH9MUWzOUcYuKBhx4ScmYXJZuAz8MZyDYrSN9ah55muxbzkYTJlCwXV44XzkTmEZzo5IfkI9MUWzOUcYuKBhx4SAB44XzOUcYuKBhNrdhHGtXzoU((lc3fPRxWGeyQxKXl6467RclGZzkTmEZzIujMyAZciyfYfoRjnihpotPLXBotHfEHrcI5hmn0T(CgQRGmf52XfoRjtYXJZuAz8MZaP37sMgmwbHUvod1vqMIC74cN1KgYXJZqDfKPi3ooJgocbNIZeCphfBiPNNWEtxEv0T2lceOfz)fjvMArPnNWIGf2B6II6kitXfbc0IkTmPjmQPWH(fz8ImKZuAz8MZK2ZzIfUWznj(ZXJZqDfKPi3ooJgocbNIZeCphfBiPNNWEtxEv0T2lceOffCphfKEVlzAWyfe6wvx2lceOffCphL1jhXE2dCKxDzViqGwuW9CuP9CMyrDzViCwuPLjnHrnfo0ViaVOKCMslJ3CgbEP30fUWznPTZXJZqDfKPi3ootPLXBotnHue7nDHZOHJqWP4mb3ZrXgs65jS30LxfDR9IabArjUOG75Oe4LEtxux2lceOfDU5mgK0MfemHjtiTiJxeyDCr4UiD9cMmH0Isyr4SOexK9xKuzQfL2CclcwyVPlkQRGmfxeiqlQ0YKMWOMch6xKXlYWfLWIabArb3ZrjWrde2B6YRGuyn9ViaVic4K(keMmH0IWzrLwM0eg1u4q)Ia8IsYz0SOZeMuqWK8CwtYfoRjnahpod1vqMIC74mA4ieCkoZX13Fr4UiD9cgKat9ImErhxFFvyb8fHZIsCrb3ZrjWl9MUOIU1ErGaTi7Vi4TPJdbtkQaNjPYE)yc8syhxFFf1vqMIlkHfHZIsCrb3Zrf9BqMWKITk6w7fbc0IKktTOEbsvyEAsrDfKP4IsGZuAz8MZal2te7mqIlCwtci44XzOUcYuKBhNrdhHGtXzcUNJInK0ZtyVPlV6YErGaTOJRV)Ia8I0(llc3fvAz8wvtifXEtxuA)fotPLXBoJ2CclcwyVPlCHZAsGroECgQRGmf52Xz0Wri4uCMG75Oydj98e2B6YRUSxeiql6467ViaViT)YIWDrLwgVv1esrS30fL2FHZuAz8MZuqD1e2B6cx4SMe)IJhNH6kitrUDCMslJ3CMNGSPwWEzAWCgnCecofNbshi9MvqMweolskiysuYesyIJfhAraErXlSKXBoJMfDMWKccMKNZAsUWznPTHJhNH6kitrUDCgnCecofNP0YKMWOMch6xeGxusotPLXBotqbHfyIlCwn0GC84muxbzkYTJZOHJqWP4mhxF)fH7I01lyqcm1lY4fDC99vHfWxeolkXffCphv0Vbzctk2QOBTxeiqlsQm1I6fivH5Pjf1vqMIlkbotPLXBodSyprSZajUWz1WKC84mLwgV5mVqvKfS30fod1vqMIC74cx4cNjnb)XBoRgAqdnysdtci4mwlypn4NZylBRIFZkWKvBl7TOfHNjTOjKTdLfDC4IaqGJgO30LhGfbja57aP4IEpKwuDfpSekUiTz1GPxTPa0PPfL0Elcy9onbfkUiaKktTOWhals8fbGuzQff(uuxbzkcWIsmjWtqTPa0PPfH)2BraR3PjOqXfba820XHGjf(ayrIViaG3MooemPWNI6kitrawuIjbEcQnfGonTiB3Elcy9onbfkUiaG3MooemPWhals8fba820XHGjf(uuxbzkcWIkzr2k2AaDrjMe4jO2ua600IsM0Elcy9onbfkUiaG3MooemPWhals8fba820XHGjf(uuxbzkcWIsmjWtqTPa0PPfL0a2BraR3PjOqXfbGuzQff(ayrIViaKktTOWNI6kitrawuIjbEcQn1MYw2wf)MvGjR2w2BrlcptArtiBhkl64WfbqKo1nlaSiibiFhifx07H0IQR4HLqXfPnRgm9QnfGonTidT3IawVttqHIlca4TPJdbtk8bWIeFraaVnDCiysHpf1vqMIaSOetc8euBkaDAArgAVfbSENMGcfxeaWBthhcMu4dGfj(IaaEB64qWKcFkQRGmfbyrjMe4jO2ua600Im0Elcy9onbfkUia0EhVJOWhals8fbG274Def(uuxbzkcWIsmjWtqTPa0PPfzO9weW6DAckuCra8(nhmDuHpawK4lcG3V5GPJk8POUcYueGfLysGNGAtTPSLTvXVzfyYQTL9w0IWZKw0eY2HYIooCraWgsApmOeaweKaKVdKIl69qAr1v8WsO4I0MvdME1McqNMwKH2BraR3PjOqXfba820XHGjf(ayrIViaG3MooemPWNI6kitrawujlYwXwdOlkXKapb1McqNMwe(BVfbSENMGcfxeasLPwu4dGfj(IaqQm1IcFkQRGmfbyrLSiBfBnGUOetc8euBkaDAAr2U9weW6DAckuCraivMArHpawK4lcaPYulk8POUcYueGfLysGNGAtbOttlYa2BraR3PjOqXfbGuzQff(ayrIViaKktTOWNI6kitrawuIjbEcQn1MYw2wf)MvGjR2w2BrlcptArtiBhkl64WfbWlaSiibiFhifx07H0IQR4HLqXfPnRgm9QnfGonTOK2BraR3PjOqXfbGuzQff(ayrIViaKktTOWNI6kitrawuIjbEcQnfGonTiB3Elcy9onbfkUiaG3MooemPWhals8fba820XHGjf(uuxbzkcWIkzr2k2AaDrjMe4jO2ua600ImG9weW6DAckuCraaVnDCiysHpawK4lca4TPJdbtk8POUcYueGfLysGNGAtbOttlkPH2BraR3PjOqXfbGuzQff(ayrIViaKktTOWNI6kitrawuIjbEcQnfGonTOK2U9weW6DAckuCraivMArHpawK4lcaPYulk8POUcYueGfLysGNGAtbOttlkPbS3IawVttqHIlcaPYulk8bWIeFraivMArHpf1vqMIaSOetc8euBkaDAArjnG9weW6DAckuCraaVnDCiysHpawK4lca4TPJdbtk8POUcYueGfLysGNGAtbOttlYqdAVfbSENMGcfxeasLPwu4dGfj(IaqQm1IcFkQRGmfbyrjMe4jO2uBkGziBhkuCrgyrLwgVxuEE5vBkodBOFMmXzWplcqsbb6dR(nh2lY22TfcUPWplYwI0uyabxKHg0OfzObn0GBQnvPLX7xXgsApmOeCTytGlsMIyNCXcfTonymXb(0BQslJ3VInK0Eyqj4AXgPGycSyB0CSaVnDCiys9(nFCiycJcdi4VPkTmE)k2qs7HbLGRfBI(nitysX2i2qsxVGjtizjPbnAowkTmPjmQPWHEaNeei7R90uxTOaIf4uno2xQm1IkTNZelBQslJ3VInK0Eyqj4AXMAcPi2B6IrZXsPLjnHrnfo0Bm(JtI2x7PPUArbelWPACSVuzQfvApNjwabQ0YKMWOMch6n2We2uLwgVFfBiP9WGsW1InVqvKfS30fJMJLsltAcJAkCOhWgccuIApn1vlkGybovdcKuzQfvApNjwsaNsltAcJAkCO3IHBQnvPLX7hxl2O9Blee7nDztHFweE2ABjBT9w0IWZC(fzDY5f1efx0FzZ2HYIeFrvo7wxeW63wi4IymDzrwnPErsbbtYIMFrTllsxVmny1MQ0Y49JRfB0(TfcI9MUyuEActhTG)g0O5ybEB64qWK6j2MxGHhJn015kSKXBqGE)MdMoQ6HL6Xe3ZpgBFEVbbkrT3X7ikiLMGFLX8d2XHYTjCSp820XHGj1tSnVadpgBORZvyjJ3jSPkTmE)4AXgbwnG8DYdWW0GXEtx2u4NfzB)PfjMZViVxK29C0T2lAolAea(fjM0I8oZYI82wCFsTiG5zrS43fzwPPfvTlMeCrEBlUpTiRJyUOArzVbtWfPDphDRTrl6Lsd0IeZswK1rmxeEWl9MUSiRMuViXKg4I0UNJU1(xK27tE0Irl69fzTgzr3wM8IgbGFrEViT75OBTxK4l6(0IeZ5nArUysqRZtls7Tm9LwK4l6(0I8ErA3Zr3AR2uLwgVFCTyZ9jSrOqJ6kKSeHufpdKWst)t5nf(zraZZIeR(I82wCF6xubPfbPkYYIQoUiThYMKPbVOJdxuTi8Gx6nDzrplT2Ofv)FdPfjM0IYEdMGlshxKz9lQw0lqVbtWfrNdPLfvDCrSH0HGlsmlzr3ot)VOra4xuLHufzzrEViT75OBTnArUysqRZtl6(0IetArEtlsmlbGFr(5SiT75OBTvlcyEwuTibonqKSO5xeKQillQ64IQ2ftcUOxGEdMGlkX6)Bifx0b6Hlk7nycUiT75OBTtyrEBlUpTiRtoVOk)(IcOfbPkYYIcyzrIjTizcPfHh8sVPlls7H0VOGsd0I8ZzrA3Zr3AB0IetQx09PfnYIMZIetArVzbP4Im0Gl6jT3XfPJlAKfjWbmyc(lYQ3ailAAHGhcslY6iMlsmPfDzR9WPbVi8Gx6nDzrplTgG4I82wCFsTiG5zr1Ie40arYI0(nhxuaTO7tXfvDCrVm58I0EiTOGsd0I8ZzrA3Zr3AVOJdxuTOZvUqAr4bV0B6IrlAea(f91HwK4l6(KrlInKoeeon4fjM0IYEdMEzrA3Zr3AVO5SiXQVOcslcsvKf1IaMNfjM0IodytzrZViW(0GxK4lI64IcOJdPfXIFHlQjGllcp4LEtxmArasVVSOxkOSO7pn4fjWPbIKFrIVOWciAr)fslsmjwweysw09POAtHFwuPLX7hxl2CFcBek8n6ZU8we40arssJMJLG75Oe4LEtxux24KOaNgisujvA3Zr3ARIxyjJ3a2IaNgisugQ0UNJU1wfVWsgVbbsGtdejkdvA3Zr3ARGuyn9Naiqb3ZrjWl9MUOIU1ghT75OBTvc8sVPlkifwt)a2qdIJaNgisugQ0UNJU1wfVWsgVbSfbonqKOsQ0UNJU1wfVWsgVXrGtdejkdvA3Zr3ARGuyn9BlmGXA3Zr3ARe4LEtxuqkSM(XX(cCAGirzOAEvesv8mqcln9pLbbkrbonqKOsQ0UNJU1wfVWsgVTfgWyT75OBTvc8sVPlkifwt)4KOaNgisujvA3Zr3ARIxyjJ3a2IaNgisugQ0UNJU1wfVWsgVbbsGtdejkdvA3Zr3ARGuyn9NqcGajfemjkzcjmXXIdzS29C0T2kbEP30ffKcRP)nf(zrLwgVFCTyZ9jSrOW3Op7YBrGtdejgA0CSeCphLaV0B6I6YgNef40arIYqL29C0T2Q4fwY4nGTiWPbIevsL29C0T2Q4fwY4niqcCAGirLuPDphDRTcsH10FcGafCphLaV0B6Ik6wBC0UNJU1wjWl9MUOGuyn9dydniocCAGirLuPDphDRTkEHLmEdylcCAGirzOs7Eo6wBv8clz8ghbonqKOsQ0UNJU1wbPWA63wyaJ1UNJU1wjWl9MUOGuyn9JJ9f40arIkPAEvesv8mqcln9pLbbkrbonqKOmuPDphDRTkEHLmEBlmGXA3Zr3ARe4LEtxuqkSM(XjrbonqKOmuPDphDRTkEHLmEdylcCAGirLuPDphDRTkEHLmEdcKaNgisujvA3Zr3ARGuyn9NqcGajfemjkzcjmXXIdzS29C0T2kbEP30ffKcRP)nvPLX7hxl2CFcBek8nAowcUNJsGx6nDrDzdcuW9Cuc8sVPlQOBTXr7Eo6wBLaV0B6IcsH10pGn0GGaDgWMcgKcRPFJ1UNJU1wjWl9MUOGuyn9VPkTmE)4AXgDLZyLwgVXYZlg1vizrh)nvPLX7hxl2ORCgR0Y4nwEEXOUcjlVy0CSuAzstyutHd9gJ)BQslJ3pUwSrx5mwPLXBS88IrDfswe4Ob6nD5nAowkTmPjmQPWHEaB4MAtvAz8(v64BjGGpbbAAWgnhlb3ZrjWl9MUOUSbb6mGnfmifwt)gNe)3uLwgVFLo(4AXMGS7rSZfYIrZXsW9Cuc8sVPlQlBqGodytbdsH10VXjbeBQslJ3VshFCTyt1A6fyLX0voB0CSeCphLaV0B6I6YgeOZa2uWGuyn9BCsaXMQ0Y49R0Xhxl2CgifKDpA0CSeCphLaV0B6I6YgeOZa2uWGuyn9BSTztvAz8(v64JRfBYdyt5XaKEJGdPwmAowcUNJsGx6nDrfDR9MQ0Y49R0Xhxl2euGX8dMahnqVrZXsW9Cuc8sVPlQOBT3uLwgVFLo(4AXg2UmEB0CSeCphLaV0B6I6YgNG75OcYUhZ3xux2GafCphLaV0B6I6YghPGGjrzsvwmvS1IXgAqqGodytbdsH10VXgci2uBQslJ3V6flVqvKfS30fJMJfPYulQxOkYc2X13hNezdP0yG1rvs1lufzb7nDbNG75OEHQilyhxFFfKcRPFJnaiqb3Zr9cvrwWoU((QOBTtytvAz8(vVGRfBaAYzS30LnvPLX7x9cUwSj63GmHjfBJMJfTNM6QffqSaNQXr7Eo6wBfKEVlzAWyfe6wvqkSM(ngSoccK91EAQRwuaXcCQgh7R90uxTO6bSPGDkceiTNM6QfvpGnfStr4KO29C0T2kRtoI9Sh4iVcsH10VXG1rqG0UNJU1wjWl9MUOGuyn9dydyGeabskiysuYesyIJfhY4KgytvAz8(vVGRfBo5csgLNMW0rlgAaJMJfPGycSyRUSXbEB64qWK69B(4qWegfgqWFtvAz8(vVGRfBKcIjWITrZXc820XHGj1738XHGjmkmGGposbXeyXwbPWA63yW6ioA3Zr3ARo5cskifwt)gdwh3uLwgVF1l4AXgc4SZ(pPjS30LnvPLX7x9cUwSX6KJyp7boYVPkTmE)QxW1InNCXcfXEtx2uLwgVF1l4AXMivIjM2SacwHgnhlhxFFC11lyqcm1gFC99vHfW3uLwgVF1l4AXMcl8cJeeZpyAOB93uLwgVF1l4AXgi9ExY0GXki0TUPkTmE)QxW1InP9CMyXO5yj4Eok2qsppH9MU8QOBTbbY(sLPwuAZjSiyH9MUacuPLjnHrnfo0BSHBQslJ3V6fCTyJaV0B6IrZXsW9CuSHKEEc7nD5vr3AdcuW9Cuq69UKPbJvqOBvDzdcuW9CuwNCe7zpWrE1Lniqb3ZrL2ZzIf1LnoLwM0eg1u4qpGtUPWplcpBTTKT2Elc)MspK1fvAz8w9eKn1c2ltdwnn2jpGnfmXXKccMKnvPLX7x9cUwSPMqkI9MUyKMfDMWKccMK3ssJMJLG75Oydj98e2B6YRIU1geOedUNJsGx6nDrDzdc05MZyqsBwqWeMmHKXG1rC11lyYesjGtI2xQm1IsBoHfblS30fqGkTmPjmQPWHEJnmbqGcUNJsGJgiS30LxbPWA6hWeWj9vimzcjCkTmPjmQPWHEaNCtvAz8(vVGRfBGf7jIDgiz0CSCC99XvxVGbjWuB8X13xfwahNedUNJsGx6nDrfDRniq2hEB64qWKIkWzsQS3pMaVe2X13pbCsm4EoQOFdYeMuSvr3AdcKuzQf1lqQcZttjSPkTmE)QxW1InAZjSiyH9MUy0CSeCphfBiPNNWEtxE1LniqhxFFaR9xWT0Y4TQMqkI9MUO0(lBQslJ3V6fCTytb1vtyVPlgnhlb3ZrXgs65jS30LxDzdc0X13hWA)fClTmERQjKIyVPlkT)YMQ0Y49REbxl28eKn1c2ltd2inl6mHjfemjVLKgnhlq6aP3ScYeosbbtIsMqctCS4qaoEHLmEVPkTmE)QxW1InbfewGjJMJLsltAcJAkCOhWj3uLwgVF1l4AXgyXEIyNbsgnhlhxFFC11lyqcm1gFC99vHfWXjXG75OI(nitysXwfDRniqsLPwuVaPkmpnLWMQ0Y49REbxl28cvrwWEtx2uBQslJ3VsGJgO30L3Ylufzb7nDXO5yrQm1I6fQISGDC99XzAStEaBk4eCph1lufzb7467RGuyn9BSb2uLwgVFLahnqVPlpUwSj63GmHjfBJMJfTNM6QffqSaNQXr7Eo6wBfKEVlzAWyfe6wvqkSM(ngSoccK91EAQRwuaXcCQgh7R90uxTO6bSPGDkceiTNM6QfvpGnfStr4KO29C0T2kRtoI9Sh4iVcsH10VXG1rqG0UNJU1wjWl9MUOGuyn9dydyGeabskiysuYesyIJfhY4KgCtvAz8(vcC0a9MU84AXgPGycSyB0CSaVnDCiys9(nFCiycJcdi4JJuqmbwSvqkSM(ngSoIJ29C0T2QtUGKcsH10VXG1XnvPLX7xjWrd0B6YJRfBo5csgLNMW0rlgAaJMJfPGycSyRUSXbEB64qWK69B(4qWegfgqWFtvAz8(vcC0a9MU84AXgc4SZ(pPjS30LnvPLX7xjWrd0B6YJRfBSo5i2ZEGJ8BQslJ3VsGJgO30Lhxl2aP37sMgmwbHU1nvPLX7xjWrd0B6YJRfBs75mXYMQ0Y49Re4Ob6nD5X1InbfewGPnvPLX7xjWrd0B6YJRfBe4LEtx2uLwgVFLahnqVPlpUwSbwSNi2zGKrZXsW9CucC0aH9MU8kifwt)a2cbCsFfctMqch4TPJdbtQ)cbpnyS30LhNG75OI(nitysXwfDR9MQ0Y49Re4Ob6nD5X1In1esrS30fJ0SOZeMuqWK8wsA0CSeCphLahnqyVPlVcsH10pGTqaN0xHWKjKWjXG75Oydj98e2B6YRIU1geOZnNXGK2SGGjmzcjJ11lyYes4cwhbbk4EokbEP30f1LDcBQslJ3VsGJgO30Lhxl2ePsmX0MfqWk0O5y5467JRUEbdsGP24JRVVkSa(MQ0Y49Re4Ob6nD5X1InWI9eXodKmAowcUNJsGJgiS30LxbPWA6hWwiGt6RqyYesBQslJ3VsGJgO30Lhxl2eEZY8MUy0CSeCphLahnqyVPlVk6wBqGcUNJInK0ZtyVPlV6YgNJRVpG1(l4wAz8wvtifXEtxuA)fCs0(sLPwuAZjSiyH9MUacuPLjnHrnfo0dy8pHnvPLX7xjWrd0B6YJRfB0MtyrWc7nDXO5yj4Eok2qsppH9MU8QlBCoU((aw7VGBPLXBvnHue7nDrP9xWP0YKMWOMch6n223uLwgVFLahnqVPlpUwSbOjNXEtxmAowcUNJksveJyHur3AVPkTmE)kboAGEtxECTytHfEHrcI5hmn0T(BQslJ3VsGJgO30Lhxl2CYflue7nDztvAz8(vcC0a9MU84AXMNGSPwWEzAWgPzrNjmPGGj5TK0O5ybshi9MvqM2uLwgVFLahnqVPlpUwSj8ML5nDXO5y5467dyT)cULwgVv1esrS30fL2FztvAz8(vcC0a9MU84AXMxOkYc2B6cN5ztAoRgAaBNlCHZba]] )

end