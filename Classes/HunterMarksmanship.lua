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
            value = function () return state.conduit.necrotic_barrage.enabled and 5 or 3 end,
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

        potion = "spectral_agility",

        package = "Marksmanship",
    } )

    
    spec:RegisterSetting( "prevent_hardcasts", false, {
        name = "Prevent Hardcasts of |T135130:0|t Aimed Shot During Movement",
        desc = "If checked, the addon will not recommend |T135130:0|t Aimed Shot if it has a cast time and you are moving.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Marksmanship", 20201216, [[dOuq)aqibQEeujztqfFcaJse1PerEfuLzrHClOsQDrYVeGHjG6yIWYOapdQetJckxJcY2OGQVbquJdGiNdqjwNaL5rH6EuI9bqDqbK0cfipeqXefqOlkGeFeGaJeGGCsaLALIKzcq6MaeYorj9tbKAPakPNIIPcv1vbiO(QacgluP2lQ(lugmKdlzXuQhtQjl0Lr2Sk(mqnAk60kwnaH61aYSf1Tf0UL63unCuQJlGOwoONRQPtCDvA7IuFNsA8aQopkX6fqK5dK9R08eC85mXsioRgeydcCcdsy4QadizygGlggNryHnXzyxAGkWeNPRqIZaiQGa9Hv)MdBod7ILSxro(CM3VqnXzWvlYue2FWciaWJyETvApmGFcV5sgV1W6ib8tOoaoJ9DYcWU52CMyjeNvdcSbboHbjmCvGbKmmdWfCHZuxX0HCgMjey4mMtmsn3MZePxZzWvlcqubb6dR(nh2lcqOBleCtHRwuGiPPqBcUOegUrlYGaBqG5m55LNJpNrGJgO30LNJpN1eC85mux2zkYdIZOHJqWP4msLPwuVqvKfSJRVVI6YotXfHZIMg7KhWMYIWzr23Zr9cvrwWoU((kifwt)lY4fziotPLXBoZlufzb7nDHlCwnGJpNH6YotrEqCgnCecofNr7PPUArbelWP6fHZI0UNJU1wbP37sMgmwbHUvfKcRP)fz8IaRJlceOff8fP90uxTOaIf4u9IWzrbFrApn1vlQEaBkyNIweiqls7PPUAr1dytb7u0IWzrjViT75OBTvwNCe7zpWrEfKcRP)fz8IaRJlceOfPDphDRTsGx6nDrbPWA6FraErgYqlkPfbc0IKccMeLmHeM4yXHwKXlkrG5mLwgV5mr)ANjmPyZfoR4chFod1LDMI8G4mA4ieCkod820XHGj1738XHGjmk0MGVI6YotXfHZIKcIjWITcsH10)ImErG1XfHZI0UNJU1wDYfKuqkSM(xKXlcSoYzkTmEZzKcIjWInx4SAyC85mux2zkYdIZuAz8MZCYfK4mA4ieCkoJuqmbwSvx2lcNfbVnDCiys9(nFCiycJcTj4ROUSZuKZKNMW0roJbgIlCwnehFotPLXBodbC2z)N0e2B6cNH6YotrEqCHZQHZXNZuAz8MZyDYrSN9ah55mux2zkYdIlCwbK54ZzkTmEZzG07DjtdgRGq3kNH6YotrEqCHZkGehFotPLXBotApNjw4mux2zkYdIlCwbw44ZzkTmEZzSliSatCgQl7mf5bXfoRjcmhFotPLXBoJaV0B6cNH6YotrEqCHZAIeC85mux2zkYdIZOHJqWP4m23ZrjWrde2B6YRGuyn9ViaBzreWj9vimzcPfHZIG3MooemP(le80GXEtxEf1LDMIlcNfzFphv0V2zctk2QOBT5mLwgV5mWI9eXodK4cN1egWXNZqDzNPipiotPLXBotnHue7nDHZOHJqWP4m23ZrjWrde2B6YRGuyn9ViaBzreWj9vimzcPfHZIsEr23ZrXgs65jS30LxfDR9IabArNBoJbjTzbbtyYeslY4fPRxWKjKweElcSoUiqGwK99Cuc8sVPlQl7fLeNrZIotysbbtYZznbx4SMax44ZzOUSZuKheNrdhHGtXzoU((lcVfPRxWGeyQxKXl6467RclGZzkTmEZzIujMyAZciyfYfoRjmmo(CgQl7mf5bXz0Wri4uCg775Oe4Obc7nD5vqkSM(xeGTSic4K(keMmHeNP0Y4nNbwSNi2zGex4SMWqC85mux2zkYdIZOHJqWP4m23ZrjWrde2B6YRIU1ErGaTi775Oydj98e2B6YRUSxeol6467ViaViT)YIWBrLwgVv1esrS30fL2Fzr4SOKxuWxKuzQfL2CclcwyVPlkQl7mfxeiqlQ0YKMWOMch6xeGxeUSOK4mLwgV5mH3SmVPlCHZAcdNJpNH6YotrEqCgnCecofNX(Eok2qsppH9MU8Ql7fHZIoU((lcWls7VSi8wuPLXBvnHue7nDrP9xweolQ0YKMWOMch6xKXlYW4mLwgV5mAZjSiyH9MUWfoRjaK54ZzOUSZuKheNrdhHGtXzSVNJksveJyHur3AZzkTmEZzaAYzS30fUWznbGehFotPLXBotHfEHrcI5hmn0T(CgQl7mf5bXfoRjaw44ZzkTmEZzo5IfkI9MUWzOUSZuKhex4SAqG54ZzOUSZuKheNP0Y4nN5jiBQfSxMgmNrdhHGtXzG0bsVzzNjoJMfDMWKccMKNZAcUWz1GeC85mux2zkYdIZOHJqWP4mhxF)fb4fP9xweElQ0Y4TQMqkI9MUO0(lCMslJ3CMWBwM30fUWz1ad44ZzkTmEZzEHQilyVPlCgQl7mf5bXfUWzI0PUzHJpN1eC85mLwgV5mA)2cbXEtx4mux2zkYdIlCwnGJpNH6YotrEqCMslJ3CgTFBHGyVPlCgnCecofNbEB64qWK6j2M3aPhJn015kSKXBf1LDMIlceOf9(nBpDu1dl1JjUNFm2(8EROUSZuCrGaTOKxK274DefKstWVYy(b74q52KI6YotXfHZIc(IG3MooemPEIT5nq6XydDDUclz8wrDzNP4IsIZKNMW0rodUeyUWzfx44ZzOUSZuKheNPRqIZeHufpdKWst)tzotPLXBotesv8mqcln9pL5cNvdJJpNH6YotrEqCgnCecofNX(EokbEP30f1L9IabAr23ZrjWl9MUOIU1Er4SiT75OBTvc8sVPlkifwt)lcWlYGaViqGw0zaBkyqkSM(xKXls7Eo6wBLaV0B6IcsH10pNP0Y4nN5(e2iu4ZfoRgIJpNH6YotrEqCMslJ3CgDLZyLwgVXYZlCM88cwxHeNrhFUWz1W54ZzOUSZuKheNrdhHGtXzkTmPjmQPWH(fz8IWfotPLXBoJUYzSslJ3y55fotEEbRRqIZ8cx4SciZXNZqDzNPipioJgocbNIZuAzstyutHd9lcWlYaotPLXBoJUYzSslJ3y55fotEEbRRqIZiWrd0B6YZfUWzydjThAxchFoRj44ZzkTmEZzSDrYue7KlwOO1PbJjoWNMZqDzNPipiUWz1ao(CgQl7mf5bXz0Wri4uCg4TPJdbtQ3V5JdbtyuOnbFf1LDMICMslJ3CgPGycSyZfoR4chFod1LDMI8G4mSHKUEbtMqIZKiWCMslJ3CMOFTZeMuS5mA4ieCkotPLjnHrnfo0ViaVOelceOff8fP90uxTOaIf4u9IWzrbFrsLPwuP9CMyrrDzNPix4SAyC85mux2zkYdIZOHJqWP4mLwM0eg1u4q)ImEr4YIWzrjVOGViTNM6QffqSaNQxeolk4lsQm1IkTNZelkQl7mfxeiqlQ0YKMWOMch6xKXlYGfLeNP0Y4nNPMqkI9MUWfoRgIJpNH6YotrEqCgnCecofNP0YKMWOMch6xeGxKblceOfL8I0EAQRwuaXcCQErGaTiPYulQ0EotSOOUSZuCrjTiCwuPLjnHrnfo0VillYaotPLXBoZlufzb7nDHlCHZOJphFoRj44ZzOUSZuKheNrdhHGtXzSVNJsGx6nDrDzViqGw0zaBkyqkSM(xKXlkbUWzkTmEZzSj4tqGMgmx4SAahFod1LDMI8G4mA4ieCkoJ99Cuc8sVPlQl7fbc0IodytbdsH10)ImErjmCotPLXBoJD29i25czHlCwXfo(CgQl7mf5bXz0Wri4uCg775Oe4LEtxux2lceOfDgWMcgKcRP)fz8Isy4CMslJ3CMQ10lWkJPRCMlCwnmo(CgQl7mf5bXz0Wri4uCg775Oe4LEtxux2lceOfDgWMcgKcRP)fz8Iaw4mLwgV5mNbs2z3JCHZQH44ZzOUSZuKheNrdhHGtXzSVNJsGx6nDrfDRnNP0Y4nNjpGnLhdq8ncoKAHlCwnCo(CgQl7mf5bXz0Wri4uCg775Oe4LEtxur3AZzkTmEZzSlWy(btGJgONlCwbK54ZzOUSZuKheNrdhHGtXzSVNJsGx6nDrDzViCwK99Cu2z3J57lQl7fbc0ISVNJsGx6nDrDzViCwKuqWKOmPklMk2AzrgVidc8IabArNbSPGbPWA6FrgVidmCotPLXBodBxgV5cx4mVWXNZAco(CgQl7mf5bXz0Wri4uCgPYulQxOkYc2X13xrDzNP4IWzrjVi2qkngyDuLq9cvrwWEtxweolY(EoQxOkYc2X13xbPWA6FrgVidTiqGwK99CuVqvKfSJRVVk6w7fLeNP0Y4nN5fQISG9MUWfoRgWXNZuAz8MZa0KZyVPlCgQl7mf5bXfoR4chFod1LDMI8G4mA4ieCkoJ2ttD1IciwGt1lcNfPDphDRTcsV3LmnySccDRkifwt)lY4fbwhxeiqlk4ls7PPUArbelWP6fHZIc(I0EAQRwu9a2uWofTiqGwK2ttD1IQhWMc2POfHZIsErA3Zr3ARSo5i2ZEGJ8kifwt)lY4fbwhxeiqls7Eo6wBLaV0B6IcsH10)Ia8ImKHwuslceOfjfemjkzcjmXXIdTiJxucdXzkTmEZzI(1otysXMlCwnmo(CgQl7mf5bXzkTmEZzo5csCgnCecofNrkiMal2Ql7fHZIG3MooemPE)MpoemHrH2e8vux2zkYzYtty6iNXadXfoRgIJpNH6YotrEqCgnCecofNbEB64qWK69B(4qWegfAtWxrDzNP4IWzrsbXeyXwbPWA6FrgViW64IWzrA3Zr3ARo5cskifwt)lY4fbwh5mLwgV5msbXeyXMlCwnCo(CMslJ3Cgc4SZ(pPjS30fod1LDMI8G4cNvazo(CMslJ3CgRtoI9Sh4ipNH6YotrEqCHZkGehFotPLXBoZjxSqrS30fod1LDMI8G4cNvGfo(CgQl7mf5bXz0Wri4uCMJRV)IWBr66fmibM6fz8IoU((QWc4CMslJ3CMivIjM2SacwHCHZAIaZXNZuAz8MZuyHxyKGy(btdDRpNH6YotrEqCHZAIeC85mLwgV5mq69UKPbJvqOBLZqDzNPipiUWznHbC85mux2zkYdIZOHJqWP4m23ZrXgs65jS30LxfDR9IabArbFrsLPwuAZjSiyH9MUOOUSZuCrGaTOsltAcJAkCOFrgVid4mLwgV5mP9CMyHlCwtGlC85mux2zkYdIZOHJqWP4m23ZrXgs65jS30LxfDR9IabAr23ZrbP37sMgmwbHUv1L9IabAr23ZrzDYrSN9ah5vx2lceOfzFphvApNjwux2lcNfvAzstyutHd9lcWlkbNP0Y4nNrGx6nDHlCwtyyC85mux2zkYdIZuAz8MZutifXEtx4mA4ieCkoJ99CuSHKEEc7nD5vr3AViqGwuYlY(EokbEP30f1L9IabArNBoJbjTzbbtyYeslY4fbwhxeElsxVGjtiTOKweolk5ff8fjvMArPnNWIGf2B6II6YotXfbc0IkTmPjmQPWH(fz8ImyrjTiqGwK99CucC0aH9MU8kifwt)lcWlIaoPVcHjtiTiCwuPLjnHrnfo0ViaVOeCgnl6mHjfemjpN1eCHZAcdXXNZqDzNPipioJgocbNIZCC99xeElsxVGbjWuViJx0X13xfwaFr4SOKxK99Cuc8sVPlQOBTxeiqlk4lcEB64qWKIkWzsQS3pMaVe2X13xrDzNP4IsAr4SOKxK99Cur)ANjmPyRIU1ErGaTiPYulQxGufMNMuux2zkUOK4mLwgV5mWI9eXodK4cN1egohFod1LDMI8G4mA4ieCkoJ99CuSHKEEc7nD5vx2lceOfDC99xeGxK2Fzr4TOslJ3QAcPi2B6Is7VWzkTmEZz0MtyrWc7nDHlCwtaiZXNZqDzNPipioJgocbNIZyFphfBiPNNWEtxE1L9IabArhxF)fb4fP9xweElQ0Y4TQMqkI9MUO0(lCMslJ3CMcQRMWEtx4cN1easC85mux2zkYdIZuAz8MZ8eKn1c2ltdMZOHJqWP4mq6aP3SSZ0IWzrsbbtIsMqctCS4qlcWlkEHLmEZz0SOZeMuqWK8CwtWfoRjaw44ZzOUSZuKheNrdhHGtXzkTmPjmQPWH(fb4fLGZuAz8MZyxqybM4cNvdcmhFod1LDMI8G4mA4ieCkoZX13Fr4TiD9cgKat9ImErhxFFvyb8fHZIsEr23Zrf9RDMWKITk6w7fbc0IKktTOEbsvyEAsrDzNP4IsIZuAz8MZal2te7mqIlCwnibhFotPLXBoZlufzb7nDHZqDzNPipiUWfUWzstWF8MZQbb2GaNWGegoNXAb7Pb)CMaHavGvwb2SciiylAr4BslAcz7qzrhhUiae4Ob6nD5byrqkq(oqkUO3dPfvxXdlHIlsBwny6vBkaDAArjc2IagVttqHIlcaPYulkCdWIeFraivMArHBf1LDMIaSOKta8KuBkaDAAr4sWweW4DAckuCraaVnDCiysHBawK4lca4TPJdbtkCROUSZueGfLCcGNKAtbOttlYWc2IagVttqHIlca4TPJdbtkCdWIeFraaVnDCiysHBf1LDMIaSOswuGsGgqxuYjaEsQnfGonTOejc2IagVttqHIlca4TPJdbtkCdWIeFraaVnDCiysHBf1LDMIaSOKta8KuBkaDAArjmuWweW4DAckuCraivMArHBawK4lcaPYulkCROUSZueGfLCcGNKAtTPcecubwzfyZkGGGTOfHVjTOjKTdLfDC4IaisN6MfaweKcKVdKIl69qAr1v8WsO4I0MvdME1McqNMwKbbBraJ3PjOqXfba820XHGjfUbyrIViaG3MooemPWTI6YotrawuYjaEsQnfGonTidc2IagVttqHIlca4TPJdbtkCdWIeFraaVnDCiysHBf1LDMIaSOKta8KuBkaDAArgeSfbmENMGcfxeaAVJ3ru4gGfj(Iaq7D8oIc3kQl7mfbyrjNa4jP2ua600Imiylcy8onbfkUiaE)MTNoQWnals8fbW73S90rfUvux2zkcWIsobWtsTP2ubcbQaRScSzfqqWw0IW3Kw0eY2HYIooCraWgsAp0UeaweKcKVdKIl69qAr1v8WsO4I0MvdME1McqNMwKbbBraJ3PjOqXfba820XHGjfUbyrIViaG3MooemPWTI6YotrawujlkqjqdOlk5eapj1McqNMweUeSfbmENMGcfxeasLPwu4gGfj(IaqQm1Ic3kQl7mfbyrLSOaLanGUOKta8KuBkaDAArgwWweW4DAckuCraivMArHBawK4lcaPYulkCROUSZueGfLCcGNKAtbOttlYqbBraJ3PjOqXfbGuzQffUbyrIViaKktTOWTI6YotrawuYjaEsQn1MkqiqfyLvGnRacc2Iwe(M0IMq2ouw0XHlcGxayrqkq(oqkUO3dPfvxXdlHIlsBwny6vBkaDAArjc2IagVttqHIlcaPYulkCdWIeFraivMArHBf1LDMIaSOKta8KuBkaDAArgwWweW4DAckuCraaVnDCiysHBawK4lca4TPJdbtkCROUSZueGfvYIcuc0a6IsobWtsTPa0PPfzOGTiGX70euO4IaaEB64qWKc3aSiXxeaWBthhcMu4wrDzNPialk5eapj1McqNMwucdc2IagVttqHIlcaPYulkCdWIeFraivMArHBf1LDMIaSOKta8KuBkaDAArjmSGTiGX70euO4IaqQm1Ic3aSiXxeasLPwu4wrDzNPialk5eapj1McqNMwucdfSfbmENMGcfxeasLPwu4gGfj(IaqQm1Ic3kQl7mfbyrjNa4jP2ua600IsyOGTiGX70euO4IaaEB64qWKc3aSiXxeaWBthhcMu4wrDzNPialk5eapj1McqNMwKbboylcy8onbfkUiaKktTOWnals8fbGuzQffUvux2zkcWIsobWtsTP2ua7q2ouO4Im0IkTmEVO88YR2uCMNnP5SAGHmmodBOFMmXzWvlcqubb6dR(nh2lcqOBleCtHRwuGiPPqBcUOegUrlYGaBqG3uBQslJ3VInK0EODj4zjaBxKmfXo5IfkADAWyId8P3uLwgVFfBiP9q7sWZsasbXeyX2O5ybEB64qWK69B(4qWegfAtWFtvAz8(vSHK2dTlbplbe9RDMWKITrSHKUEbtMqYsIaB0CSuAzstyutHd9aobiqbx7PPUArbelWPACcUuzQfvApNjw2uLwgVFfBiP9q7sWZsa1esrS30fJMJLsltAcJAkCO3yCbNKdU2ttD1IciwGt14eCPYulQ0EotSacuPLjnHrnfo0BSbjTPkTmE)k2qs7H2LGNLaEHQilyVPlgnhlLwM0eg1u4qpGnaeOK1EAQRwuaXcCQgeiPYulQ0EotSKeoLwM0eg1u4qVfd2uBQslJ3pEwcq73wii2B6YMcxTi8d0bIb6GTOfHV58lY6KZlQjkUO)YMTdLfj(IQC2TUiGXVTqWfXy6YISAs9IKccMKfn)IAxwKUEzAWQnvPLX7hplbO9Blee7nDXO80eMoAbxcSrZXc820XHGj1tSnVbspgBORZvyjJ3Ga9(nBpDu1dl1JjUNFm2(8EdcuYAVJ3ruqknb)kJ5hSJdLBt4eC4TPJdbtQNyBEdKEm2qxNRWsgVtAtHRweGWpTiXC(f59I0UNJU1ErZzrJaWViXKwK3zwwK3467tQfbSplIf)UiZknTOQDXKGlYBC99PfzDeZfvlk7nycUiT75OBTnArVuAGwKywYISoI5IWhEP30Lfz1K6fjM0axK29C0T2)I0EFYJwmArVViR1il62YKx0ia8lY7fPDphDR9IeFr3NwKyoVrlYftcADEArAVLPV0IeFr3NwK3ls7Eo6wB1MQ0Y49JNLaUpHncfAuxHKLiKQ4zGewA6FkVPWvlcyFwKy1xK3467t)IkiTiivrwwu1XfP9q2Kmn4fDC4IQfHp8sVPll6zP1gTO6)BiTiXKwu2BWeCr64ImRFr1IEb6nycUi6CiTSOQJlInKoeCrIzjl62z6)fnca)IQmKQillY7fPDphDRTrlYftcADEAr3NwKyslYBArIzja8lYpNfPDphDRTAra7ZIQfjWPbIKfn)IGufzzrvhxu1UysWf9c0BWeCrjx)FdP4IoqpCrzVbtWfPDphDRDslYBC99PfzDY5fv53xKnTiivrwwKnllsmPfjtiTi8Hx6nDzrApK(fzxAGwKFols7Eo6wBJwKys9IUpTOrw0CwKysl6nlifxKbbErpP9oUiDCrJSiboGbtWFrw9gazrtle8qqArwhXCrIjTOlBThon4fHp8sVPll6zP1aexK3467tQfbSplQwKaNgiswK2V54ISPfDFkUOQJl6LjNxK2dPfzxAGwKFols7Eo6w7fDC4IQfDUYfslcF4LEtxmArJaWVOVo0IeFr3NmArSH0HGWPbViXKwu2BW0lls7Eo6w7fnNfjw9fvqArqQISOweW(SiXKw0zaBklA(fb2Ng8IeFruhxKnDCiTiw8lCrnbCzr4dV0B6Irlcq89Lf9sbLfD)PbVibonqK8ls8ffwarl6VqArIjXYIatYIUpfvBkC1IkTmE)4zjG7tyJqHVrF2L3IaNgissy0CSyFphLaV0B6I6YgNKf40arIkHs7Eo6wBv8clz8gWwe40arIYaL29C0T2Q4fwY4niqcCAGirzGs7Eo6wBfKcRP)KabY(EokbEP30fv0T24ODphDRTsGx6nDrbPWA6hWgeyCe40arIYaL29C0T2Q4fwY4nGTiWPbIevcL29C0T2Q4fwY4nocCAGirzGs7Eo6wBfKcRPFCTHmw7Eo6wBLaV0B6IcsH10pobxGtdejkduZRIqQINbsyPP)PmiqjlWPbIevcL29C0T2Q4fwY4nU2qgRDphDRTsGx6nDrbPWA6hNKf40arIkHs7Eo6wBv8clz8gWwe40arIYaL29C0T2Q4fwY4niqcCAGirzGs7Eo6wBfKcRP)KsceiPGGjrjtiHjowCiJ1UNJU1wjWl9MUOGuyn9VPWvlQ0Y49JNLaUpHncf(g9zxElcCAGiXaJMJf775Oe4LEtxux24KSaNgisugO0UNJU1wfVWsgVbSfbonqKOsO0UNJU1wfVWsgVbbsGtdejQekT75OBTvqkSM(tcei775Oe4LEtxur3AJJ29C0T2kbEP30ffKcRPFaBqGXrGtdejQekT75OBTvXlSKXBaBrGtdejkduA3Zr3ARIxyjJ34iWPbIevcL29C0T2kifwt)4AdzS29C0T2kbEP30ffKcRPFCcUaNgisujuZRIqQINbsyPP)PmiqjlWPbIeLbkT75OBTvXlSKXBCTHmw7Eo6wBLaV0B6IcsH10pojlWPbIeLbkT75OBTvXlSKXBaBrGtdejQekT75OBTvXlSKXBqGe40arIkHs7Eo6wBfKcRP)KsceiPGGjrjtiHjowCiJ1UNJU1wjWl9MUOGuyn9VPkTmE)4zjG7tyJqHVrZXI99Cuc8sVPlQlBqGSVNJsGx6nDrfDRnoA3Zr3ARe4LEtxuqkSM(bSbbgeOZa2uWGuyn9BS29C0T2kbEP30ffKcRP)nvPLX7hplbORCgR0Y4nwEEXOUcjl64VPkTmE)4zjaDLZyLwgVXYZlg1viz5fJMJLsltAcJAkCO3yCztvAz8(XZsa6kNXkTmEJLNxmQRqYIahnqVPlVrZXsPLjnHrnfo0dyd2uBQslJ3VshFl2e8jiqtd2O5yX(EokbEP30f1LniqNbSPGbPWA634e4YMQ0Y49R0XhplbyNDpIDUqwmAowSVNJsGx6nDrDzdc0zaBkyqkSM(noHHVPkTmE)kD8XZsavRPxGvgtx5SrZXI99Cuc8sVPlQlBqGodytbdsH10VXjm8nvPLX7xPJpEwc4mqYo7E0O5yX(EokbEP30f1LniqNbSPGbPWA63yGLnvPLX7xPJpEwcipGnLhdq8ncoKAXO5yX(EokbEP30fv0T2BQslJ3VshF8SeGDbgZpycC0a9gnhl23ZrjWl9MUOIU1EtvAz8(v64JNLay7Y4TrZXI99Cuc8sVPlQlBCSVNJYo7EmFFrDzdcK99Cuc8sVPlQlBCKccMeLjvzXuXwlgBqGbb6mGnfmifwt)gBGHVP2uLwgVF1lwEHQilyVPlgnhlsLPwuVqvKfSJRVpojZgsPXaRJQeQxOkYc2B6co23Zr9cvrwWoU((kifwt)gBiqGSVNJ6fQISGDC99vr3AN0MQ0Y49REbplba0KZyVPlBQslJ3V6f8Seq0V2zctk2gnhlApn1vlkGybovJJ29C0T2ki9ExY0GXki0TQGuyn9BmyDeeOGR90uxTOaIf4unobx7PPUAr1dytb7ueiqApn1vlQEaBkyNIWjzT75OBTvwNCe7zpWrEfKcRPFJbRJGaPDphDRTsGx6nDrbPWA6hWgYqjbcKuqWKOKjKWehloKXjm0MQ0Y49REbplbCYfKmkpnHPJwmWqgnhlsbXeyXwDzJd820XHGj1738XHGjmk0MG)MQ0Y49REbplbifetGfBJMJf4TPJdbtQ3V5JdbtyuOnbFCKcIjWITcsH10VXG1rC0UNJU1wDYfKuqkSM(ngSoUPkTmE)QxWZsaeWzN9FstyVPlBQslJ3V6f8SeG1jhXE2dCKFtvAz8(vVGNLao5IfkI9MUSPkTmE)QxWZsarQetmTzbeScnAowoU((4PRxWGeyQn(467RclGVPkTmE)QxWZsafw4fgjiMFW0q36VPkTmE)QxWZsaq69UKPbJvqOBDtvAz8(vVGNLas75mXIrZXI99CuSHKEEc7nD5vr3AdcuWLktTO0MtyrWc7nDbeOsltAcJAkCO3yd2uLwgVF1l4zjabEP30fJMJf775Oydj98e2B6YRIU1gei775OG07DjtdgRGq3Q6Ygei775OSo5i2ZEGJ8QlBqGSVNJkTNZelQlBCkTmPjmQPWHEaNytHRwe(b6aXaDWweWkLEiRlQ0Y4T6jiBQfSxMgSAAStEaBkyIJjfemjBQslJ3V6f8SeqnHue7nDXinl6mHjfemjVLegnhl23ZrXgs65jS30LxfDRniqjBFphLaV0B6I6YgeOZnNXGK2SGGjmzcjJbRJ4PRxWKjKscNKdUuzQfL2CclcwyVPlGavAzstyutHd9gBqsGazFphLahnqyVPlVcsH10pGjGt6RqyYes4uAzstyutHd9aoXMQ0Y49REbplbal2te7mqYO5y5467JNUEbdsGP24JRVVkSaoojBFphLaV0B6Ik6wBqGco820XHGjfvGZKuzVFmbEjSJRVFs4KS99Cur)ANjmPyRIU1geiPYulQxGufMNMsAtvAz8(vVGNLa0MtyrWc7nDXO5yX(Eok2qsppH9MU8QlBqGoU((aw7VGxPLXBvnHue7nDrP9x2uLwgVF1l4zjGcQRMWEtxmAowSVNJInK0ZtyVPlV6YgeOJRVpG1(l4vAz8wvtifXEtxuA)LnvPLX7x9cEwc4jiBQfSxMgSrAw0zctkiysEljmAowG0bsVzzNjCKccMeLmHeM4yXHaC8clz8EtvAz8(vVGNLaSliSatgnhlLwM0eg1u4qpGtSPkTmE)QxWZsaWI9eXodKmAowoU((4PRxWGeyQn(467RclGJtY23Zrf9RDMWKITk6wBqGKktTOEbsvyEAkPnvPLX7x9cEwc4fQISG9MUSP2uLwgVFLahnqVPlVLxOkYc2B6IrZXIuzQf1lufzb7467JZ0yN8a2uWX(EoQxOkYc2X13xbPWA63ydTPkTmE)kboAGEtxE8Seq0V2zctk2gnhlApn1vlkGybovJJ29C0T2ki9ExY0GXki0TQGuyn9BmyDeeOGR90uxTOaIf4unobx7PPUAr1dytb7ueiqApn1vlQEaBkyNIWjzT75OBTvwNCe7zpWrEfKcRPFJbRJGaPDphDRTsGx6nDrbPWA6hWgYqjbcKuqWKOKjKWehloKXjc8MQ0Y49Re4Ob6nD5XZsasbXeyX2O5ybEB64qWK69B(4qWegfAtWhhPGycSyRGuyn9BmyDehT75OBTvNCbjfKcRPFJbRJBQslJ3VsGJgO30LhplbCYfKmkpnHPJwmWqgnhlsbXeyXwDzJd820XHGj1738XHGjmk0MG)MQ0Y49Re4Ob6nD5XZsaeWzN9FstyVPlBQslJ3VsGJgO30LhplbyDYrSN9ah53uLwgVFLahnqVPlpEwcasV3LmnySccDRBQslJ3VsGJgO30LhplbK2ZzILnvPLX7xjWrd0B6YJNLaSliSatBQslJ3VsGJgO30LhplbiWl9MUSPkTmE)kboAGEtxE8SeaSyprSZajJMJf775Oe4Obc7nD5vqkSM(bSfc4K(keMmHeoWBthhcMu)fcEAWyVPlpo23Zrf9RDMWKITk6w7nvPLX7xjWrd0B6YJNLaQjKIyVPlgPzrNjmPGGj5TKWO5yX(EokboAGWEtxEfKcRPFaBHaoPVcHjtiHtY23ZrXgs65jS30LxfDRniqNBoJbjTzbbtyYesgRRxWKjKWdSoccK99Cuc8sVPlQl7K2uLwgVFLahnqVPlpEwcisLyIPnlGGvOrZXYX13hpD9cgKatTXhxFFvyb8nvPLX7xjWrd0B6YJNLaGf7jIDgiz0CSyFphLahnqyVPlVcsH10pGTqaN0xHWKjK2uLwgVFLahnqVPlpEwci8ML5nDXO5yX(EokboAGWEtxEv0T2GazFphfBiPNNWEtxE1LnohxFFaR9xWR0Y4TQMqkI9MUO0(l4KCWLktTO0MtyrWc7nDbeOsltAcJAkCOhW4ssBQslJ3VsGJgO30LhplbOnNWIGf2B6IrZXI99CuSHKEEc7nD5vx24CC99bS2FbVslJ3QAcPi2B6Is7VGtPLjnHrnfo0BSHTPkTmE)kboAGEtxE8SeaqtoJ9MUy0CSyFphvKQigXcPIU1EtvAz8(vcC0a9MU84zjGcl8cJeeZpyAOB93uLwgVFLahnqVPlpEwc4KlwOi2B6YMQ0Y49Re4Ob6nD5XZsapbztTG9Y0GnsZIotysbbtYBjHrZXcKoq6nl7mTPkTmE)kboAGEtxE8Seq4nlZB6IrZXYX13hWA)f8kTmERQjKIyVPlkT)YMQ0Y49Re4Ob6nD5XZsaVqvKfS30fUWfoha]] )

end