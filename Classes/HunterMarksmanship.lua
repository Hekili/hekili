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
        spec:RegisterPack( "Marksmanship", 20201020.9, [[dCui9aqiGQEevsXMiP8jQKQgLOKtjk1RefZIuXTivb1UO4xqLggjvhtuzzKk9mOQAAuj5AKQ02ivrFdQkACKQqNdQkSoQKknpG4EKK9rQQdsQcOfcv5HujL0hbQq1iPskXjPsk1kbsZeOc5MujvStOIFsQc0sbQq5PaMkq5RKQamwsvq2lK)svdMshwyXKYJrmzfUmQnlYNvrJgkNwQvdubVMkXSv0TjXUb9BjdxfooqfTCv9CLMoX1vPTlQY3PsnEOQ05fv16bQ08PI9J0OCiWqaJqyeo6QUUQNt9C43Oo(iNUiaj)dgbCeexItgbadfgb46eVlRsaxS(abCe5pRyGadbS19jmcW1qTyICSUU4I7zlyxndPuWDBL7mKUGKpscUBRqWfbOD7P4AdrAiGrimchDvxx1ZPEo8BuhFKlNEXNiG4ky1JaaAfxRiaSEmyisdbm4LGaCnuRRLlu4NADDI3LvjGlwFqb11qT6bjsPXp1Md)6qT6QUUQtbLcQRHAbhX5XtQvFQvVQBqaZELfbgcq(M4YIvYIadHtoeyiaggAtEGWdbq(w4VdeaPQ5OCdnrRWd)IvI5EqTooulPQ5OCdnFC0dFQF28Ss0WLA1NAjvnhLBOjAfE4xSsmpRenCrabr6cIag1vBYEjoqcchDrGHayyOn5bcpea5BH)oqa)fYP6pzZw3zQ(t2ZkA8VggCE7JdEqTQrTs8E5JdZZkrdxQfeQ9KmOw1OwsvZr5gAsZ4zZZkrdxQfeQ9Kmqabr6cIaK49YhhibHd(rGHayyOn5bcpea5BH)oqa)fYP6pzZw3zQ(t2ZkA8VgggAtEqTQrTs8E5JdZ9abeePlicinJNrcchxHadbeePlicWDph(9O)wweaddTjpq4Heeo6fbgciisxqeqE1CY5JayyOn5bcpKGWrprGHacI0feb88wWqA4Pp(VCJayyOn5bcpKGWbFIadbeePlicql(pozeaddTjpq4Heeo6reyiGGiDbram(EmRTZJ9lwjiaggAtEGWdjiCWhiWqamm0M8aHhcG8TWFhiasvZr5gA(4Oh(u)S5zLOHl164qTPICxQnd1gePlO5JJE4t9ZgsSI)5tgsT6tTPICxJsGVuRJd1M6tmX)Ss0WLAbHAZPxeqqKUGia5V8Ivcsq4KtDeyiaggAtEGWdbq(w4VdeG2nLmY3ex8lwjR5EqTQrTzrTA3uYC8mPx2VyLSMr5gsToouB6oN(NjyXFYEPvyQfeQLeR4LwHP2mu7jzqToouR2nLmYF5fReZ9GAZgbeePliciAfE4xSsqccNC5qGHayyOn5bcpea5BH)oqaPICxQnd1sIv8pFYqQfeQnvK7Auc8fbeePlicyWHG5jyHlFOGeeo50fbgcGHH2Khi8qaKVf(7abODtjJ8nXf)IvYAUhuRAuR2nLmJ6QnzVehMr5gIacI0feb8Xrp8P(zKGWjh(rGHayyOn5bcpea5BH)oqaA3uYiFtCXVyLSMr5gsToouR2nLmhpt6L9lwjR5EqToouBQi3LA1dtTKAfQnd1sIv8pFYqQvFQnisxqt0k8WVyLyi1kiGGiDbrak3P0lwjibHtoxHadbWWqBYdeEiaY3c)DGa0UPKzWXWZ5ZMr5gIacI0feb4spN(fReKGWjNErGHacI0febeEL7p43xjp5l3lcGHH2Khi8qccNC6jcmeqqKUGiG0mYNh(fReeaddTjpq4Heeo5WNiWqamm0M8aHhciisxqeWY)bdf)kn8ebq(w4VdeWZPNxSqBYias(Kj7L4pzzr4KdjiCYPhrGHacI0febSchJ89lwjiaggAtEGWdjibbm4uCNccmeo5qGHacI0febqQlu43VyLGayyOn5bcpKGWrxeyiaggAtEGWdbeePlicyEFx4F9nC7rx31F2jbbq(w4VdeaPQ5OCdnYF5fReZZkrdx)5L3LAbHAZPxQ1XHAt9jM4FwjA4sTGqT4xDeamuyeW8(UW)6B42JUUR)Stcsq4GFeyiaggAtEGWdbeePlicia3fl(y9Pck(k5pk38JaiFl83bcilQn1NyI)zLOHl1Qp1gePlONu1CuUHuBgQf)UIADCOwj(twmyCmfmZbrOwqOwDvNADCOwj(twmsRWEP8heXRR6uliuBo9sTztTQrTKQMJYn0i)LxSsmpRenC9NxExQfeQnNEPwhhQn1NyI)zLOHl1cc1IF9IaGHcJacWDXIpwFQGIVs(JYn)ibHJRqGHayyOn5bcpeqqKUGiG5DLVUR)SMdg6pMxL4KraKVf(7abqQAok3qJ8xEXkX8Ss0W1FE5DPwqOw9sToouBQpXe)ZkrdxQfeQvx1raWqHraZ7kFDx)znhm0FmVkXjJeeo6fbgcGHH2Khi8qabr6cIaoJjtI5K)1Rvfebq(w4VdeG2nLmYF5fReZZkrdxQvFQnNROwhhQf8uRetgkgsmNn80lySFXkznmm0M8GADCO2uFIj(NvIgUuliuBo1raWqHraNXKjXCY)61QcIeeo6jcmeaddTjpq4HacI0febelwEbKx)hGB9Es9Xebq(w4VdeG2nLmYF5fReZZkrdxQvFQnNROw1O2SOwTBkzoVXp6a6RKpax(lbZCpOwhhQf8ulVldjSHuWbdxE4NDIt1tyJsaoup1Qg1scFqKopMAZMADCO2bRDtjZhGB9Es9X0pyTBkzgLBi164qTP(et8pRenCPwqOwDvhbadfgbelwEbKx)hGB9Es9XejiCWNiWqamm0M8aHhciisxqeWrrCHLTbxE4jLYXvcPlOFW51egbq(w4Vdea4PwTBkzK)YlwjM7b1Qg1cEQL3LHe2OnRA4RKxWypdzL8nkb4q9uRJd1oyTBkz0Mvn8vYlySNHSs(M7b164qTP(et8pRenCPwqOw9IaGHcJaokIlSSn4YdpPuoUsiDb9doVMWibHJEebgcGHH2Khi8qaKVf(7abODtjJ8xEXkX8Ss0WLA1NAZ5kQ1XHAbp1kXKHIHeZzdp9cg7xSswdddTjpOwhhQn1NyI)zLOHl1cc1QR6iGGiDbra3L9TWklsq4GpqGHayyOn5bcpeqqKUGiasmN(GiDb9ZEfeWSxXddfgbqglsq4KtDeyiaggAtEGWdbq(w4VdeqqKop2ZqwP5LAbHAXpciisxqeajMtFqKUG(zVccy2R4HHcJawbjiCYLdbgcGHH2Khi8qaKVf(7abeePZJ9mKvAEPw9PwDrabr6cIaiXC6dI0f0p7vqaZEfpmuyeG8nXLfRKfjibbC8mPu0cbbgcNCiWqamm0M8aHhcG8TWFhiG)c5u9NSzR7mv)j7zfn(xddoV9Xbpqabr6cIaK49YhhibHJUiWqamm0M8aHhc44zsSIxAfgbKtDeqqKUGiGrD1MSxIdKGWb)iWqamm0M8aHhcG8TWFhiGGiDESNHSsZl1QIAZHacI0febeTcp8lwjibjiaYyrGHWjhcmeaddTjpq4HaiFl83bcGu1CuUHMpo6Hp1pBEwjA4sTGqTNKb164qTKQMJYn08Xrp8P(zZZkrdxQfeQLu1CuUHMOv4HFXkX8Ss0WLADCO2uFIj(NvIgUuliuRUQJacI0febmQR2K9sCGeeo6IadbWWqBYdeEiaY3c)DGa0UPKr(lVyLyEwjA4sT6tT5Cf1Qg1Mf1M6tmX)Ss0WLA1NAjvnhLBOrJ)LFxA4PzC)q6csTzO2X9dPli164qTzrTs8NSyW4ykyMdIqTGqT6Qo164qTGNALyYqXqINt3PpAfdddTjpO2SP2SPwhhQn1NyI)zLOHl1cc1Md)iGGiDbraA8V87sdprcch8JadbWWqBYdeEiaY3c)DGa0UPKr(lVyLyEwjA4sT6tT5Cf1Qg1Mf1M6tmX)Ss0WLA1NAjvnhLBOrBw1WNUF(MX9dPli1MHAh3pKUGuRJd1Mf1kXFYIbJJPGzoic1cc1QR6uRJd1cEQvIjdfdjEoDN(Ovmmm0M8GAZMAZMADCO2uFIj(NvIgUuliuBo9ebeePlicqBw1WNUF(ibHJRqGHayyOn5bcpea5BH)oqaA3uYi)LxSsmpRenCPw9P2CUIAvJAZIAt9jM4FwjA4sT6tTKQMJYn0eqcVYhtpjMtZ4(H0fKAZqTJ7hsxqQ1XHAZIAL4pzXGXXuWmheHAbHA1vDQ1XHAbp1kXKHIHepNUtF0kgggAtEqTztTztToouBQpXe)ZkrdxQfeQnNEIacI0febeqcVYhtpjMtKGWrViWqamm0M8aHhcG8TWFhiaTBkzK)YlwjMNvIgUuR(uBoxrTQrTzrTP(et8pRenCPw9PwsvZr5gAs9ZAZQgMX9dPli1MHAh3pKUGuRJd1Mf1kXFYIbJJPGzoic1cc1QR6uRJd1cEQvIjdfdjEoDN(Ovmmm0M8GAZMAZMADCO2uFIj(NvIgUuliul(abeePlici1pRnRAGeeo6jcmeaddTjpq4HaiFl83bcq7Msg5V8IvIzuUHiGGiDbraZ(etwp4WDCQWqbjiCWNiWqamm0M8aHhcG8TWFhiaTBkzK)YlwjMr5gIacI0febOfN(k5LVjUSibHJEebgcGHH2Khi8qaKVf(7abODtjJ8xEXkXmk3qQvnQnlQvI)KfdghtbZCqeQvFQvpQo164qTs8NSyW4ykyMdIqTGOIA1vDQ1XHAL4pzXiTc7LYFqeVUQtT6tT4xDQnBeqqKUGiGNJJgE6tZqHxKGWbFGadbWWqBYdeEiaY3c)DGaYIAjvnhLBOja3fl(y9Pck(k5pk38BEwjA4sT6tT6Qo164qTGNAzW5Tpo4Hja3fl(y9Pck(k5pk38tToouBQpXe)ZkrdxQfeQLu1CuUHMaCxS4J1NkO4RK)OCZVzC)q6csTzOw87kQvnQvI)KfdghtbZCqeQvFQvx1P2SPw1O2SOwsvZr5gAK)YlwjMNvIgU(ZlVl1cc1IFQ1XHAZIA5DziHn51BxqFL8h8NyI0f0O0W6Pw1O2uFIj(NvIgUuR(uBqKUGEsvZr5gsTzOwTBkzCx)CKh3q)ZBbdiHnJ7hsxqQnBQnBQ1XHAt9jM4FwjA4sTGqT6QociisxqeG76NJ84g6FElyajmsq4KtDeyiaggAtEGWdbq(w4Vdeqwulj8br68yQ1XHAt9jM4FwjA4sT6tTbr6c6jvnhLBi1MHAXV6uB2uRAuBwuR2nLmYF5fReZ9GADCOwsvZr5gAK)YlwjMNvIgUuliuBo9KAZMADCO2uFIj(NvIgUuliul(ZHacI0febCEJF0b0xjFaU8xcgsq4KlhcmeaddTjpq4HaiFl83bcGu1CuUHg5V8IvI5zLOHl1cc1Iprabr6cIa((4yY(g63JGWibHtoDrGHayyOn5bcpea5BH)oqaGNA1UPKr(lVyLyUhiGGiDbrakSs957RKFEj9WpEouwKGWjh(rGHayyOn5bcpea5BH)oqaA3uYi)LxSsmpheHAvJA1UPKrBw1yExX8CqeQ1XHA1UPKr(lVyLyEwjA4sT6tT5Cf1Qg1kXFYIbJJPGzoic1cc1QR6uRJd1Mf1Mf1sk4EvcTjBokPlOVs(lu77XKh(09ZNADCOwsb3RsOnzZfQ99yYdF6(5tTztTQrTP(et8pRenCPwqOw9mh164qTP(et8pRenCPwqOwD1tQnBeqqKUGiGJs6cIeeo5CfcmeaddTjpq4HaiFl83bcq7Msg5V8IvIzuUHuRAulPQ5OCdnFC0dFQF28Ss0WLADCO2uFIj(NvIgUuliuBo9IacI0febi)LxSsqcsqaRGadHtoeyiaggAtEGWdbq(w4VdeGetgkMv4yKVpvK7AyyOn5b1Qg1E8CE(tYWKZSchJ89lwjuRAuR2nLmRWXiFFQi318Ss0WLAbHA1lciisxqeWkCmY3VyLGeeo6IadbeePlicWLEo9lwjiaggAtEGWdjiCWpcmeqqKUGiGrD1MSxIdeaddTjpq4HeeoUcbgcGHH2Khi8qaKVf(7ab8xiNQ)KnBDNP6pzpROX)AyW5Tpo4b1Qg1kX7LpompRenCPwqO2tYGAvJAjvnhLBOjnJNnpRenCPwqO2tYabeePlicqI3lFCGeeo6fbgcGHH2Khi8qaKVf(7ab8xiNQ)KnBDNP6pzpROX)AyyOn5b1Qg1kX7Lpom3deqqKUGiG0mEgjiC0teyiGGiDbraU75WVh93YIayyOn5bcpKGWbFIadbeePlicinJ85HFXkbbWWqBYdeEibHJEebgcGHH2Khi8qaKVf(7abKkYDP2muljwX)8jdPwqO2urURrjWxeqqKUGiGbhcMNGfU8Hcsq4GpqGHacI0febW47XS2op2VyLGayyOn5bcpKGWjN6iWqamm0M8aHhcG8TWFhiaTBkzoEM0l7xSswZOCdPwhhQf8uRetgkgcwRe8h(fRedddTjpqabr6cIaYRMtoFKGWjxoeyiGGiDbraHx5(d(9vYt(Y9IayyOn5bcpKGWjNUiWqamm0M8aHhcG8TWFhiaTBkzoEM0l7xSswZOCdPwhhQf8uRetgkgcwRe8h(fRedddTjpqabr6cIaEElyin80h)xUrccNC4hbgcGHH2Khi8qaKVf(7abODtjZXZKEz)IvYAgLBi164qTGNALyYqXqWALG)WVyLyyyOn5bciisxqeG8xEXkbjiCY5keyiaggAtEGWdbq(w4VdeqwuB6oN(NjyXFYEPvyQfeQLeR4LwHP2mu7jzqToouR2nLmYF5fReZ9GAZMAvJAZIA1UPK54zsVSFXkznJYnKADCOwWtTsmzOyiyTsWF4xSsmmm0M8GADCOws4dI05XuB2uRJd1QDtjJ8nXf)IvYAEwjA4sT6tTm(YKRWEPvyQvnQnlQnisNh7ziR08sT6tT5OwhhQ9Vqov)jBw(pyOSsmDH)1lFtCH)8nm482hh8GAZgbeePliciAfE4xSsqccNC6fbgcGHH2Khi8qaKVf(7abODtjZOUAt2lXHzuUHuRAuBQi3LAZqTKyf)ZNmKAbHAtf5UgLaFrabr6cIa(4Oh(u)msq4KtprGHayyOn5bcpea5BH)oqaA3uYC8mPx2VyLSM7b1Qg1Mf1QDtjJ8xEXkXmk3qQ1XHAdI05XEgYknVuR(uBoQ1XHAbp1scFqKopMAZgbeePlicGG1kb)HFXkbjiCYHprGHayyOn5bcpeqqKUGiGL)dgk(vA4jcG8TWFhiGNtpVyH2KPw1Owj(twmsRWEP8JMPw9P2X9dPlicGKpzYEj(twweo5qccNC6reyiaggAtEGWdbq(w4VdeqqKop2ZqwP5LA1NAZHacI0febOf)hNmsq4KdFGadbWWqBYdeEiaY3c)DGa0UPK54zsVSFXkzn3dQvnQnlQv7Msg5V8IvIzuUHuRJd1cEQLe(GiDEm1Mnciisxqeq8KaY(fReKGWrx1rGHayyOn5bcpea5BH)oqaA3uYC8mPx2VyLSMr5gIacI0febeTcp8lwjibHJU5qGHayyOn5bcpea5BH)oqaPICxQvFQLuRqTzO2GiDbnrRWd)IvIHuRqTQrTzrTA3uYi)LxSsmJYnKADCOwWtTKWhePZJP2Srabr6cIaiyTsWF4xSsqcchD1fbgcGHH2Khi8qaKVf(7abKkYDPw9PwsTc1MHAdI0f0eTcp8lwjgsTc1Qg1Mf1QDtjJ8xEXkXmk3qQ1XHAbp1scFqKopMAZgbeePliciEsaz)Ivcsq4Ol(rGHayyOn5bcpea5BH)oqaPICxQnd1sIv8pFYqQfeQnvK7Auc8fbeePlicyfog57xSsqcchDDfcmeqqKUGiacwRe8h(fReeaddTjpq4Heeo6QxeyiGGiDbraXtci7xSsqamm0M8aHhsqcsqa5X)2feHJUQRR65upNUg8bcWD8WgEUia9a0deCmCCTXbCCxxQLAbdJP2w5OEHAt1tTUEYyD9u7ZGZB)8GA3sHP24kLsi8GAjyb8KxdfuWrnKPw8HRl16ATG5XVWdQ11lFdDHfJEidPQ5OCdD9uRuuRRNu1CuUHg9qUEQnlDX3SnuqPG6ARCuVWdQvVuBqKUGu7Sxznuqra7btq4OREDfc44RupzeGRHADTCHc)uRRt8USkbCX6dkOUgQvpirkn(P2C4xhQvx11vDkOuqDnul4iopEsT6tT6vDdfukObr6cUMJNjLIwizuHReVx(4qNoP6Vqov)jB26ot1FYEwrJ)1WGZBFCWdkObr6cUMJNjLIwizuH7OUAt2lXHohptIv8sRWQYPof0GiDbxZXZKsrlKmQWnAfE4xSs0PtQcI05XEgYknVQYrbLcAqKUGBgv4sQlu43VyLqbnisxWnJkCVl7BHv0bgkSQ59DH)13WThDDx)zNeD6KksvZr5gAK)YlwjMNvIgU(ZlVli50RJtQpXe)ZkrdxqWV6uqdI0fCZOc37Y(wyfDGHcRka3fl(y9Pck(k5pk38RtNuLvQpXe)Zkrdx9jvnhLByg87khhj(twmyCmfmZbrarx1DCK4pzXiTc7LYFqeVUQdso9MTAKQMJYn0i)LxSsmpRenC9NxExqYPxhNuFIj(NvIgUGGF9sbnisxWnJkCVl7BHv0bgkSQ5DLVUR)SMdg6pMxL4K1PtQivnhLBOr(lVyLyEwjA46pV8UGOxhNuFIj(NvIgUGOR6uqdI0fCZOc37Y(wyfDGHcR6mMmjMt(xVwvqD6KkTBkzK)YlwjMNvIgU6NZvooGxIjdfdjMZgE6fm2VyLSgggAtE44K6tmX)Ss0WfKCQtbnisxWnJkCVl7BHv0bgkSQyXYlG86)aCR3tQpM60jvA3uYi)LxSsmpRenC1pNRullTBkzoVXp6a6RKpax(lbZCpCCapVldjSHuWbdxE4NDIt1tyJsaouVAKWhePZJZ2XzWA3uY8b4wVNuFm9dw7MsMr5g64K6tmX)Ss0WfeDvNcAqKUGBgv4Ex23cROdmuyvhfXfw2gC5HNukhxjKUG(bNxtyD6KkWRDtjJ8xEXkXCpud88UmKWgTzvdFL8cg7ziRKVrjahQ3XzWA3uYOnRA4RKxWypdzL8n3dhNuFIj(NvIgUGOxkOUgQfSpFQvkQD2qMAVhuBqKoVq4b1kFdDHLLAD3cg1c2F5fRekObr6cUzuH7DzFlSYQtNuPDtjJ8xEXkX8Ss0Wv)CUYXb8smzOyiXC2WtVGX(fRK1WWqBYdhNuFIj(NvIgUGOR6uqdI0fCZOcxsmN(GiDb9ZEfDGHcRImwkObr6cUzuHljMtFqKUG(zVIoWqHvTIoDsvqKop2ZqwP5fe8tbnisxWnJkCjXC6dI0f0p7v0bgkSk5BIllwjRoDsvqKop2ZqwP5vFDPGsbnisxW1qgBgv4oQR2K9sCOtNurQAok3qZhh9WN6NnpRenCb5KmCCivnhLBO5JJE4t9ZMNvIgUGqQAok3qt0k8WVyLyEwjA464K6tmX)Ss0WfeDvNcAqKUGRHm2mQWvJ)LFxA4PoDsL2nLmYF5fReZZkrdx9Z5k1Yk1NyI)zLOHR(KQMJYn0OX)YVln80mUFiDbZmUFiDbDCYsI)KfdghtbZCqeq0vDhhWlXKHIHepNUtF0kgggAtEKD2ooP(et8pRenCbjh(PGgePl4AiJnJkC1Mvn8P7NVoDsL2nLmYF5fReZZkrdx9Z5k1Yk1NyI)zLOHR(KQMJYn0OnRA4t3pFZ4(H0fmZ4(H0f0Xjlj(twmyCmfmZbrarx1DCaVetgkgs8C6o9rRyyyOn5r2z74K6tmX)Ss0WfKC6jf0GiDbxdzSzuHBaj8kFm9Kyo1PtQ0UPKr(lVyLyEwjA4QFoxPwwP(et8pRenC1Nu1CuUHMas4v(y6jXCAg3pKUGzg3pKUGoozjXFYIbJJPGzoici6QUJd4LyYqXqINt3PpAfdddTjpYoBhNuFIj(NvIgUGKtpPGgePl4AiJnJkCt9ZAZQg60jvA3uYi)LxSsmpRenC1pNRulRuFIj(NvIgU6tQAok3qtQFwBw1WmUFiDbZmUFiDbDCYsI)KfdghtbZCqeq0vDhhWlXKHIHepNUtF0kgggAtEKD2ooP(et8pRenCbbFqbnisxW1qgBgv4o7tmz9Gd3XPcdfD6KkTBkzK)YlwjMr5gsbnisxW1qgBgv4QfN(k5LVjUS60jvA3uYi)LxSsmJYnKcAqKUGRHm2mQW954OHN(0mu4vNoPs7Msg5V8IvIzuUHQLLe)jlgmoMcM5Gi6Rhv3XrI)KfdghtbZCqequPR6oos8NSyKwH9s5piIxx11h)QNnf0GiDbxdzSzuHR76NJ84g6FElyajSoDsvwY3qxyXeG7IfFS(ubfFL8hLB(nKQMJYn08Ss0WvFDv3Xb8m482hh8WeG7IfFS(ubfFL8hLB(DCs9jM4FwjA4cI8n0fwmb4UyXhRpvqXxj)r5MFdPQ5OCdnJ7hsxWm43vQjXFYIbJJPGzoiI(6QE2QLfPQ5OCdnYF5fReZZkrdx)5L3fe874KfVldjSjVE7c6RK)G)etKUGgLgwVAP(et8pRenC1Nu1CuUHz0UPKXD9ZrECd9pVfmGe2mUFiDbZoBhNuFIj(NvIgUGOR6uqdI0fCnKXMrfUN34hDa9vYhGl)LGPtNuLfj8br68yhNuFIj(NvIgU6tQAok3Wm4x9SvllTBkzK)YlwjM7HJdPQ5OCdnYF5fReZZkrdxqYPNz74K6tmX)Ss0Wfe8NJcAqKUGRHm2mQW97JJj7BOFpccRtNurQAok3qJ8xEXkX8Ss0Wfe8jf0GiDbxdzSzuHRcRuF((k5Nxsp8JNdLvNoPc8A3uYi)LxSsm3dkObr6cUgYyZOc3Js6cQtNuPDtjJ8xEXkX8Cqe10UPKrBw1yExX8CqehhTBkzK)YlwjMNvIgU6NZvQjXFYIbJJPGzoici6QUJtwzrk4EvcTjBokPlOVs(lu77XKh(09Z3XHuW9QeAt2CHAFpM8WNUF(zRwQpXe)Zkrdxq0ZCooP(et8pRenCbrx9mBkObr6cUgYyZOcx5V8IvIoDsL2nLmYF5fReZOCdvJu1CuUHMpo6Hp1pBEwjA464K6tmX)Ss0WfKC6Lckf0GiDbxJ8nXLfRKnJkCh1vBYEjo0PtQivnhLBOjAfE4xSsm3dhhsvZr5gA(4Oh(u)S5zLOHR(KQMJYn0eTcp8lwjMNvIgUuqdI0fCnY3exwSs2mQWvI3lFCOtNu9xiNQ)KnBDNP6pzpROX)AyW5Tpo4HAs8E5JdZZkrdxqojd1ivnhLBOjnJNnpRenCb5KmOGgePl4AKVjUSyLSzuHBAgpRtNu9xiNQ)KnBDNP6pzpROX)AyyOn5HAs8E5JdZ9GcAqKUGRr(M4YIvYMrfUU75WVh93YsbnisxW1iFtCzXkzZOc38Q5KZNcAqKUGRr(M4YIvYMrfUpVfmKgE6J)l3uqdI0fCnY3exwSs2mQWvl(pozkObr6cUg5BIllwjBgv4Y47XS2op2VyLqbnisxW1iFtCzXkzZOcx5V8IvIoDsfPQ5OCdnFC0dFQF28Ss0W1XjvK7MjisxqZhh9WN6NnKyf)ZNmu)urURrjWxhNuFIj(NvIgUGKtVuqdI0fCnY3exwSs2mQWnAfE4xSs0PtQ0UPKr(M4IFXkzn3d1Ys7MsMJNj9Y(fRK1mk3qhN0Do9ptWI)K9sRWGqIv8sRWzojdhhTBkzK)YlwjM7r2uqdI0fCnY3exwSs2mQWDWHG5jyHlFOOtNuLkYDZqIv8pFYqqsf5UgLaFPGgePl4AKVjUSyLSzuH7hh9WN6N1PtQ0UPKr(M4IFXkzn3d10UPKzuxTj7L4Wmk3qkObr6cUg5BIllwjBgv4QCNsVyLOtNuPDtjJ8nXf)IvYAgLBOJJ2nLmhpt6L9lwjR5E44KkYD1dtQvYqIv8pFYq9dI0f0eTcp8lwjgsTcf0GiDbxJ8nXLfRKnJkCDPNt)IvIoDsL2nLmdogEoF2mk3qkObr6cUg5BIllwjBgv4gEL7p43xjp5l3lf0GiDbxJ8nXLfRKnJkCtZiFE4xSsOGgePl4AKVjUSyLSzuH7Y)bdf)kn8uhs(Kj7L4pzzvLtNoP650ZlwOnzkObr6cUg5BIllwjBgv4UchJ89lwjuqPGgePl4AwjJkCxHJr((fReD6KkjMmumRWXiFFQi31WWqBYd1oEop)jzyYzwHJr((fRe10UPKzfog57tf5UMNvIgUGOxkObr6cUMvYOcxx650VyLqbnisxW1Ssgv4oQR2K9sCqbnisxW1Ssgv4kX7Lpo0PtQ(lKt1FYMTUZu9NSNv04Fnm482hh8qnjEV8XH5zLOHliNKHAKQMJYn0KMXZMNvIgUGCsguqdI0fCnRKrfUPz8SoDs1FHCQ(t2S1DMQ)K9SIg)RHHH2KhQjX7Lpom3dkObr6cUMvYOcx39C43J(BzPGgePl4AwjJkCtZiFE4xSsOGgePl4AwjJkChCiyEcw4Yhk60jvPIC3mKyf)ZNmeKurURrjWxkObr6cUMvYOcxgFpM125X(fRekObr6cUMvYOc38Q5KZxNoPs7MsMJNj9Y(fRK1mk3qhhWlXKHIHG1kb)HFXkXWWqBYdkObr6cUMvYOc3WRC)b)(k5jF5EPGgePl4AwjJkCFElyin80h)xU1PtQ0UPK54zsVSFXkznJYn0Xb8smzOyiyTsWF4xSsmmm0M8GcAqKUGRzLmQWv(lVyLOtNuPDtjZXZKEz)IvYAgLBOJd4LyYqXqWALG)WVyLyyyOn5bf0GiDbxZkzuHB0k8WVyLOtNuLv6oN(NjyXFYEPvyqiXkEPv4mNKHJJ2nLmYF5fReZ9iB1Ys7MsMJNj9Y(fRK1mk3qhhWlXKHIHG1kb)HFXkXWWqBYdhhs4dI05Xz74ODtjJ8nXf)IvYAEwjA4QpJVm5kSxAfwTScI05XEgYknV6NZX5Vqov)jBw(pyOSsmDH)1lFtCH)8nm482hh8iBkObr6cUMvYOc3po6Hp1pRtNuPDtjZOUAt2lXHzuUHQLkYDZqIv8pFYqqsf5UgLaFPGgePl4AwjJkCjyTsWF4xSs0PtQ0UPK54zsVSFXkzn3d1Ys7Msg5V8IvIzuUHoobr68ypdzLMx9Z54aEs4dI05XztbnisxW1Ssgv4U8FWqXVsdp1HKpzYEj(twwv50PtQEo98IfAtwnj(twmsRWEP8JM1FC)q6csbnisxW1Ssgv4Qf)hNSoDsvqKop2ZqwP5v)CuqdI0fCnRKrfUXtci7xSs0PtQ0UPK54zsVSFXkzn3d1Ys7Msg5V8IvIzuUHooGNe(GiDEC2uqdI0fCnRKrfUrRWd)IvIoDsL2nLmhpt6L9lwjRzuUHuqdI0fCnRKrfUeSwj4p8lwj60jvPICx9j1kzcI0f0eTcp8lwjgsTIAzPDtjJ8xEXkXmk3qhhWtcFqKopoBkObr6cUMvYOc34jbK9lwj60jvPICx9j1kzcI0f0eTcp8lwjgsTIAzPDtjJ8xEXkXmk3qhhWtcFqKopoBkObr6cUMvYOc3v4yKVFXkrNoPkvK7MHeR4F(KHGKkYDnkb(sbnisxW1Ssgv4sWALG)WVyLqbnisxW1Ssgv4gpjGSFXkbjibHaa]] )
    else
        spec:RegisterPack( "Marksmanship", 20201020.1, [[dG0d8aqiikpcvqTjiLpjuLAucQoLqYQqfs8kiYSee7Ik)cvYWGKoMqzzcONjaMMa01esTnub(gQqnoub5CcvvRtOkX8eI7jq7tq6GcvbTquPEiQqkFuOQKgjQqsNuOkQvcHMPqvKBkufANqQ(PqvGHkuvQwQqvP8uqnviXxfQkXyrfs1EH6VuAWuCyrlgv9yuMSsUmXMPQpRugniNwYQfQkEnQOzlv3gj7wv)wXWvQoUqvslh45QmDsxxkBxq57qW4rfIZluz9qunFKA)ighdJcgELQGrpqude1yOgiQUyXFa44a5qyynUDbdVNmoZnbd)jLGHJhtaNhv(huTJH3Z46tUWOGHVPbycgMdtmqQUFXlCX1wPqnEhBO46kQwp1AEgi9kxxrX4cdZ3QUgp)yEm8kvbJEGOgiQXqnquDXI)aWXXIHHZMcnammCrXrdddvRL8yEm8soggMdtmXJjGZJk)dQ2jgoQTxfabromXepGPdVaiMarneIjqudevcIee5Wet8KeM0jMibjMOr1HH71PhgfmSckgNh0Ohgfm6XWOGHtMwZJH5S6D7bnkgw(KVllm3yfJEGyuWWjtR5XWHn9Uehgw(KVllm3yfJEaWOGHtMwZJH5tai3emS8jFxwyUXkg9aIrbdNmTMhdlCK9(CvyI9GgfdlFY3LfMBSIrpAmkyy5t(USWCJHzGsfqLyy(M37uqX40EqJEU2oXGgXWsBY0kmHyqJy4BEVBnn(Uy1C312XWjtR5XWzrjl7bnkwXOZbyuWWYN8DzH5gdZaLkGkXW8nV3PGIXP9Gg9CTDIbnIjCIjrUakvC(H1ozz9fqCYN8Dzrm00etICbuQ4Q3QqIfafNcr5a5ZjXekXeJyOPjMe5cOuXDnWw9B2dA0ZjFY3LfXqttmA2LxDNcKKQxV4Kp57YIyIcdNmTMhddY9Az9fqWkgDogJcgw(KVllm3yygOubujgMV59ofumoTh0ONRTtmOrmHtm8nV3TdewDI9Gg9CRbHNyOPjg2m91GW7YIsw2dAuNV17wGWGsWMy1IsiMietY0AExwuYYEqJ6y5PwTOeIHMMy4BEVtbn5Gg112jMOWWjtR5XWzrjl7bnkwXOZHWOGHLp57YcZngMbkvavIH5BEVtbfJt7bn65A7y4KP18yyqUxlRVacwXOh)yuWWYN8DzH5gdZaLkGkXW8nV3PGIXP9Gg9CRbHNyOPjg(M372bcRoXEqJEU2oXGgXGmIHV59of0KdAuxBNyOPjg)WAhXekXWXOIHtMwZJHPADToOrXkg9yOIrbdNmTMhd7hw7KLnrUakvS8ssHHLp57YcZnwXOhlggfmCY0AEm8Edu(4QFZY3ZtXWYN8DzH5gRy0JfigfmCY0AEmmBEM8kivzz99KsWWYN8DzH5gRy0Jfamkyy5t(USWCJHzGsfqLy4DGeMDJTCXCHn9UehXqttmiJy0SlV6cB6DjoN8jFxwednnXOjytuNwuIvh7QeIjcXelggozAnpgMVpZYoERcjw5fQ4Wkg9ybeJcgw(KVllm3yygOubujgMV59oGW4Sl3z9dGjU2oXqttm8nV3begND5oRFamXYM2RcWDAY4KyIqmXqfdNmTMhdRqIT98t7xw)aycwXOhlAmky4KP18y40s1albyhVLbgeomS8jFxwyUXkg9yCagfmS8jFxwyUXWmqPcOsmmq8a5Gs(UqmOrmiJysMwZ7obSlVApT(nx9wFV2GumCY0AEm8jGD5v7P1VHvm6X4ymky4KP18y4tLCfN9GgfdlFY3LfMBSIvm8s8zRRyuWOhdJcgozAnpgMnTxfG9GgfdlFY3LfMBSIrpqmkyy5t(USWCJHtMwZJH7naNc4S1F1QM2z3kVIHzGsfqLyy2m91GW7uqtoOrDaHkR)SBn5oIjcXelAIHMMy81gKAbcvw)rmriMaGkg(tkbd3BaofWzR)QvnTZUvEfRy0dagfmS8jFxwyUXWjtR5XWjYpOeKN1pVAhVDFqqayygOubujgoCIXxBqQfiuz9hXekXKmTM3YMPVgeEIbjIjabKyOPjgnbBI6GKSRqUDMsmriMarLyOPjgnbBI60IsS6y3zQnqujMietSOjMOig0ig2m91GW7uqtoOrDaHkR)SBn5oIjcXelAIHMMy81gKAbcvw)rmriMaeng(tkbdNi)GsqEw)8QD829bbbGvm6beJcgw(KVllm3y4KP18y4E7uW0o720xYB37nQCtWWmqPcOsmmBM(Aq4DkOjh0OoGqL1F2TMChXeHyIMyOPjgFTbPwGqL1FeteIjquXWFsjy4E7uW0o720xYB37nQCtWkg9OXOGHLp57YcZngozAnpgEl7cl7DbCw(zEmmduQaQedZ38ENcAYbnQdiuz9hXekXelGednnXGmIrZU8QJL9E9BwfsSh0ONt(KVllIHMMy81gKAbcvw)rmriMyOIH)KsWWBzxyzVlGZYpZJvm6CagfmS8jFxwyUXWjtR5XW5bfw(YzbjYhGLnGSJHzGsfqLyy(M37uqtoOrDaHkR)iMqjMybKyqJycNy4BEVBRLGvLVD82e5cyuixBNyOPjgKrmYDYZehB(L8NSS9Yl(bWehvgFgaXGgXWsBY0kmHyIIyOPjMLW38Ehir(aSSbKD7s4BEVBni8ednnX4Rni1ceQS(JyIqmbIkg(tkbdNhuy5lNfKiFaw2aYowXOZXyuWWYN8DzH5gdNmTMhdVpmof9kKlllBO2BAQ182LewXemmduQaQedJmIHV59of0KdAuxBNyqJyqgXi3jptC89zw2XBviXkVqfNJkJpdGyOPjMLW38EhFFMLD8wfsSYluX5A7ednnX4Rni1ceQS(JyIqmrJH)KsWW7dJtrVc5YYYgQ9MMAnVDjHvmbRy05qyuWWYN8DzH5gdZaLkGkXW8nV3PGMCqJ6acvw)rmHsmXciXqttmiJy0SlV6yzVx)MvHe7bn65Kp57YIyOPjgFTbPwGqL1FeteIjquXWjtR5XWTtSLkuhwXOh)yuWWYN8DzH5gdNmTMhdZYE3MmTM32RtXW96u7NucgMToSIrpgQyuWWYN8DzH5gdZaLkGkXWjtRWeR8cvjhXeHycagozAnpgML9UnzAnVTxNIH71P2pPem8PyfJESyyuWWYN8DzH5gdZaLkGkXWjtRWeR8cvjhXekXeigozAnpgML9UnzAnVTxNIH71P2pPemSckgNh0OhwXkgEhiSHIpvmky0JHrbdlFY3LfMBm8oqy5PwTOemCmuXWjtR5XWRPX3fRM7yfJEGyuWWYN8DzH5gd)jLGHtKFqjipRFE1oE7(GGaWWjtR5XWjYpOeKN1pVAhVDFqqayfJEaWOGHtMwZJHrya9vys9wGCZNptWWYN8DzH5gRy0digfmCY0AEm8wlbRkF74TjYfWOqyy5t(USWCJvm6rJrbdNmTMhdtjudio74T9gRw2fqsQddlFY3LfMBSIrNdWOGHLp57YcZngEhiS8uRwucgoMlAmCY0AEmScAYbnkgMbkvavIHtMwHjw5fQsoIjuIjqSIrNJXOGHLp57YcZngMbkvavIHtMwHjw5fQsoIjcXeamCY0AEmCwuYYEqJIvSIHzRdJcg9yyuWWYN8DzH5gdZaLkGkXWSz6RbH3bY9Az9fqCaHkR)iMieZgBrm00edBM(Aq4DGCVwwFbehqOY6pIjcXWMPVgeExwuYYEqJ6acvw)rm00eJV2GulqOY6pIjcXeiQy4KP18y41047IvZDSIrpqmkyy5t(USWCJHzGsfqLyy(M37uqtoOrDaHkR)iMqjMybKyqJycNy81gKAbcvw)rmHsmSz6RbH3XlGtaCw)MB1aPwZtmirmRgi1AEIHMMycNy0eSjQdsYUc52zkXeHycevIHMMyqgXOzxE1XsG4BDBwuo5t(USiMOiMOigAAIXxBqQfiuz9hXeHyIfamCY0AEmmVaobWz9ByfJEaWOGHLp57YcZngMbkvavIH5BEVtbn5Gg1beQS(JycLyIfqIbnIjCIXxBqQfiuz9hXekXWMPVgeEhFFML13aX5wnqQ18edseZQbsTMNyOPjMWjgnbBI6GKSRqUDMsmriMarLyOPjgKrmA2LxDSei(w3MfLt(KVllIjkIjkIHMMy81gKAbcvw)rmriMyCagozAnpgMVpZY6BG4Wkg9aIrbdlFY3LfMBmmduQaQedZ38ENcAYbnQdiuz9hXekXelGedAet4eJV2GulqOY6pIjuIHntFni8U8zYPGSBzzV7wnqQ18edseZQbsTMNyOPjMWjgnbBI6GKSRqUDMsmriMarLyOPjgKrmA2LxDSei(w3MfLt(KVllIjkIjkIHMMy81gKAbcvw)rmriMyCagozAnpgoFMCki7ww27yfJE0yuWWYN8DzH5gdZaLkGkXW8nV3PGMCqJ6acvw)rmHsmXciXGgXeoX4Rni1ceQS(JycLyyZ0xdcVZxaHVpZYTAGuR5jgKiMvdKAnpXqttmHtmAc2e1bjzxHC7mLyIqmbIkXqttmiJy0SlV6yjq8TUnlkN8jFxwetuetuednnX4Rni1ceQS(JyIqmXpgozAnpg2xaHVpZcRy05amkyy5t(USWCJHzGsfqLyy(M37uqtoOrDRbHhdNmTMhd3Rni9SXN2AJsEfRy05ymkyy5t(USWCJHzGsfqLyy(M37uqtoOrDRbHhdNmTMhdZNB2XBvqX48WkgDoegfmS8jFxwyUXWmqPcOsmmFZ7DkOjh0OU1GWtmOrmHtmAc2e1bjzxHC7mLycLy4qOsm00eJMGnrDqs2vi3otjMibjMarLyOPjgnbBI60IsS6y3zQnqujMqjMaGkXefgozAnpggi5E9BwFpPKdRy0JFmkyy5t(USWCJHzGsfqLy4Wjg2m91GW7sKFqjipRFE1oE7(GGaCaHkR)iMqjMarLyOPjgKrms8AR23LLlr(bLG8S(5v74T7dccGyOPjgFTbPwGqL1FeteIHntFni8Ue5hucYZ6NxTJ3Upiia3QbsTMNyqIycqajg0ignbBI6GKSRqUDMsmHsmbIkXefXGgXeoXWMPVgeENcAYbnQdiuz9NDRj3rmriMaqm00et4eJCN8mXfwD182XB3fGxyAnVJQ(bqmOrm(AdsTaHkR)iMqjMKP18w2m91GWtmirm8nV3HWa6RWK6Ta5MpFM4wnqQ18etuetuednnX4Rni1ceQS(JyIqmbIkgozAnpggHb0xHj1BbYnF(mbRy0JHkgfmS8jFxwyUXWmqPcOsmC4edlTjtRWeIHMMy81gKAbcvw)rmHsmjtR5TSz6RbHNyqIycaQetuedAet4edFZ7DkOjh0OU2oXqttmSz6RbH3PGMCqJ6acvw)rmriMyCaXefXqttm(AdsTaHkR)iMietaIHHtMwZJH3Ajyv5BhVnrUagfcRy0JfdJcgw(KVllm3yygOubujgMntFni8of0KdAuhqOY6pIjcXWXy4KP18yyqTV3fB92BpzcwXOhlqmkyy5t(USWCJHzGsfqLyyKrm8nV3PGMCqJ6A7y4KP18yykHAaXzhVT3y1YUassDyfJESaGrbdlFY3LfMBmmduQaQedZ38ENcAYbnQdijtjg0ig(M3747ZS6TtDajzkXqttm8nV3PGMCqJ6acvw)rmHsmXciXGgXOjytuhKKDfYTZuIjcXeiQednnXeoXeoXWM)AujFxC7JwZBhVT98GA1LL13aXrm00edB(RrL8DX1EEqT6YY6BG4iMOig0igFTbPwGqL1FeteIHdIrm00eJV2GulqOY6pIjcXeihqmrHHtMwZJH3hTMhRy0Jfqmkyy5t(USWCJHzGsfqLyy(M37uqtoOrDRbHNyqJyyZ0xdcVdK71Y6lG4acvw)rm00eJV2GulqOY6pIjcXelAmCY0AEmScAYbnkwXkg(umky0JHrbdlFY3LfMBmmduQaQedRzxE1DQKR4S(H1oN8jFxwedAeZoqcZUXwUyUtLCfN9GgLyqJy4BEV7ujxXz9dRDoGqL1FeteIjAmCY0AEm8PsUIZEqJIvm6bIrbdNmTMhdZz172dAumS8jFxwyUXkg9aGrbdNmTMhdlCK9(CvyI9GgfdlFY3LfMBSIrpGyuWWYN8DzH5gdZaLkGkXWjtRWeR8cvjhXekXeddNmTMhdZNaqUjyfJE0yuWWjtR5XWPLQbwcWoEldmiCyy5t(USWCJvm6CagfmCY0AEmCytVlXHHLp57YcZnwXOZXyuWWYN8DzH5gdZaLkGkXWaXdKdk57cXGgXGmIjzAnV7eWU8Q9063C1B99AdsXWjtR5XWNa2LxTNw)gwXOZHWOGHLp57YcZngMbkvavIH5BEVtbn5Gg1TgeEIHMMy8dRDeteIjartm00eJFyTJyIqmCaQedAedYign7YRUUOqz3EqJEo5t(USigAAIHV59U6TkKybqXPquoGqL1FeteIr4icRPIvlkbdNmTMhddY9Az9fqWkg94hJcgw(KVllm3yygOubujgMV59of0KdAuxBNyqJycNy4BEVR9cau)MnS6Q5DNMmojMqjMasm00edYiMe5cOuX1EbaQFZgwD18o5t(USiMOigAAIXxBqQfiuz9hXeHyIfddNmTMhdZ3NzzhVvHeR8cvCyfJEmuXOGHLp57YcZngMbkvavIHrgXW38ENcAYbnQRTtm00eJV2GulqOY6pIjcXengozAnpg2pS2jlBICbuQy5LKcRy0JfdJcgw(KVllm3yygOubujgMV59of0KdAuxBNyOPjMWjg(M37wtJVlwn3DRbHNyOPjgwAtMwHjetuedAedFZ7D7aHvNypOrp3Aq4jgAAIX36DlqyqjytSArjeteIHLNA1Isig0ig2m91GW7uqtoOrDaHkR)WWjtR5XWzrjl7bnkwXOhlqmkyy5t(USWCJHzGsfqLyyKrm8nV3PGMCqJ6A7ednnX4Rni1ceQS(JyIqmCimCY0AEm8Edu(4QFZY3ZtXkg9ybaJcgw(KVllm3yygOubujg2pS2rmirm(H1ohq2KNy4OqmBSfXeHy8dRDoQKJqmOrm8nV3PGMCqJ6wdcpXGgXeoXGmIznQJnptEfKQSS(Esjw(g4DaHkR)ig0igKrmjtR5DS5zYRGuLL13tkXvV13RniLyIIyOPjgFR3TaHbLGnXQfLqmriMn2IyOPjgFTbPwGqL1FeteIjAmCY0AEmmBEM8kivzz99KsWkg9ybeJcgw(KVllm3yygOubujgMV59oGW4Sl3z9dGjU2oXqttm8nV3begND5oRFamXYM2RcWDAY4KyIqmXqLyOPjgFTbPwGqL1FeteIjAmCY0AEmScj22ZpTFz9dGjyfJESOXOGHLp57YcZngMbkvavIH5BEVtbn5Gg1TgeEIbnIjCIHV59UDGWQtSh0ONRTtmOrmHtm(H1oIjuIj6OjMOigAAIXpS2rmHsmCC0ednnX4Rni1ceQS(JyIqmrtmrHHtMwZJHtalFXEqJIvm6X4amkyy5t(USWCJHzGsfqLyy(M37uqtoOrDRbHNyqJycNy4BEVBhiS6e7bn65A7edAet4eJFyTJycLyIoAIjkIHMMy8dRDetOedhhnXqttm(AdsTaHkR)iMiet0etuy4KP18yygurLciTh0OyfJEmogJcgozAnpg(ujxXzpOrXWYN8DzH5gRyfRy4WeWvZJrpqude1yOglAxmmmcj4RF7WWXxIhgFd94z0JVgVqmedkqcXuu7dqjg)aiM4nBDXBIbiXRTcilI5gkHyYMouPklIHbL)MCocIXt1let8hVqmC0MpmbOYIyI3kOEof1Xr3XMPVge(4nXOdXeVzZ0xdcVJJE8MycpqosuocIeeJNP2hGklIjAIjzAnpX0Rtphbrm8Tlmm6bgDaXW7GXxDbdZHjM4XeW5rL)bv7edh12RcGGihMyIhW0HxaetGOgcXeiQbIkbrcICyIjEsct6etKGet0O6iisqKdtmX3bclpLyuO6iM8igjb94iM8iM95UIVleJoeZ(OYRv27XrmBz9et(JcjaIHLNsmRgO(nIrHeIXxBqQJGyY0A(ZTde2qXNksb5Ann(Uy1CpKDGWYtTArjbJHkbXKP18NBhiSHIpvKcYv7eBPcviFsjbtKFqjipRFE1oE7(GGaiiMmTM)C7aHnu8PIuqUqya9vys9wGCZNptiiMmTM)C7aHnu8PIuqU2Ajyv5BhVnrUagfIGyY0A(ZTde2qXNksb5IsOgqC2XB7nwTSlGKuhbXKP18NBhiSHIpvKcYLcAYbnAi7aHLNA1IscgZfDiLpyY0kmXkVqvYfAGeetMwZFUDGWgk(urkixzrjl7bnAiLpyY0kmXkVqvYfjaeejiMmTM)qkixSP9QaSh0OeetMwZFifKR2j2sfQq(Ksc2BaofWzR)QvnTZUvEnKYhKntFni8of0KdAuhqOY6p7wtUlsSOPP91gKAbcvw)fjaOsqmzAn)HuqUANylvOc5tkjyI8dkb5z9ZR2XB3heeqiLpy4(AdsTaHkR)cLntFni8ifGastRjytuhKKDfYTZ0ibIknTMGnrDArjwDS7m1giQrIfDuOXMPVgeENcAYbnQdiuz9NDRj3fjw000(AdsTaHkR)IeGOjiMmTM)qkixTtSLkuH8jLeS3ofmTZUn9L829EJk3KqkFq2m91GW7uqtoOrDaHkR)SBn5Uirtt7Rni1ceQS(lsGOsqmzAn)HuqUANylvOc5tkj4w2fw27c4S8Z8Hu(G8nV3PGMCqJ6acvw)fASastJmn7YRow271VzviXEqJEo5t(USOP91gKAbcvw)fjgQeetMwZFifKR2j2sfQq(KscMhuy5lNfKiFaw2aYEiLpiFZ7DkOjh0OoGqL1FHglGOfoFZ7DBTeSQ8TJ3MixaJc5A700itUtEM4yZVK)KLTxEXpaM4OY4ZaqJL2KPvysu00lHV59oqI8byzdi72LW38E3Aq4PP91gKAbcvw)fjqujiMmTM)qkixTtSLkuH8jLeCFyCk6vixww2qT30uR5TljSIjHu(GiJV59of0KdAuxBhnKj3jptC89zw2XBviXkVqfNJkJpdGMEj8nV3X3NzzhVvHeR8cvCU2onTV2GulqOY6VirtqKdtmOaIJy0Hy61letBNysMwHLQSigfupNIEedcLcrmOaAYbnkbXKP18hsb5QDITuH6cP8b5BEVtbn5Gg1beQS(l0ybKMgzA2LxDSS3RFZQqI9Gg9CYN8Dzrt7Rni1ceQS(lsGOsqmzAn)HuqUyzVBtMwZB71PH8jLeKTocIjtR5pKcYfl7DBY0AEBVonKpPKGNgs5dMmTctSYluLCrcabXKP18hsb5IL9UnzAnVTxNgYNusqfumopOrVqkFWKPvyIvEHQKl0ajisqmzAn)5yRl4AA8DXQ5EiLpiBM(Aq4DGCVwwFbehqOY6ViBSfnnBM(Aq4DGCVwwFbehqOY6ViSz6RbH3LfLSSh0OoGqL1F00(AdsTaHkR)IeiQeetMwZFo26qkix8c4eaN1Vfs5dY38ENcAYbnQdiuz9xOXciAH7Rni1ceQS(lu2m91GW74fWjaoRFZTAGuR5rA1aPwZtthUMGnrDqs2vi3otJeiQ00itZU8QJLaX362SOCYN8Dzfvu00(AdsTaHkR)IelaeetMwZFo26qkix89zwwFdexiLpiFZ7DkOjh0OoGqL1FHglGOfUV2GulqOY6VqzZ0xdcVJVpZY6BG4CRgi1AEKwnqQ1800HRjytuhKKDfYTZ0ibIknnY0SlV6yjq8TUnlkN8jFxwrffnTV2GulqOY6ViX4acIjtR5phBDifKR8zYPGSBzzVhs5dY38ENcAYbnQdiuz9xOXciAH7Rni1ceQS(lu2m91GW7YNjNcYULL9UB1aPwZJ0QbsTMNMoCnbBI6GKSRqUDMgjquPPrMMD5vhlbIV1Tzr5Kp57YkQOOP91gKAbcvw)fjghqqmzAn)5yRdPGC5lGW3Nzfs5dY38ENcAYbnQdiuz9xOXciAH7Rni1ceQS(lu2m91GW78fq47ZSCRgi1AEKwnqQ1800HRjytuhKKDfYTZ0ibIknnY0SlV6yjq8TUnlkN8jFxwrffnTV2GulqOY6ViXpbXKP18NJToKcYvV2G0ZgFARnk51qkFq(M37uqtoOrDRbHNGyY0A(ZXwhsb5Ip3SJ3QGIX5fs5dY38ENcAYbnQBni8eetMwZFo26qkixaj3RFZ67jLCHu(G8nV3PGMCqJ6wdcpAHRjytuhKKDfYTZ0q5qOstRjytuhKKDfYTZ0ibdevAAnbBI60IsS6y3zQnqudnaOgfbXKP18NJToKcYfcdOVctQ3cKB(8zsiLpy4kOEof1Li)GsqEw)8QD829bbb4yZ0xdcVdiuz9xObIknnYK41wTVllxI8dkb5z9ZR2XB3heeanTV2GulqOY6VikOEof1Li)GsqEw)8QD829bbb4yZ0xdcVB1aPwZJuaciAAc2e1bjzxHC7mn0arnk0cNntFni8of0KdAuhqOY6p7wtUlsaOPdxUtEM4cRUAE74T7cWlmTM3rv)aqZxBqQfiuz9xOSz6RbHhj(M37qya9vys9wGCZNptCRgi1A(OIIM2xBqQfiuz9xKarLGyY0A(ZXwhsb5ARLGvLVD82e5cyuOqkFWWzPnzAfMqt7Rni1ceQS(lu2m91GWJuaqnk0cNV59of0KdAuxBNMMntFni8of0KdAuhqOY6ViX4GOOP91gKAbcvw)fjaXiiMmTM)CS1HuqUa1(ExS1BV9KjHu(GSz6RbH3PGMCqJ6acvw)fHJjiMmTM)CS1HuqUOeQbeND82EJvl7cij1fs5dIm(M37uqtoOrDTDcIjtR5phBDifKR9rR5dP8b5BEVtbn5Gg1bKKPOX38EhFFMvVDQdijtPP5BEVtbn5Gg1beQS(l0ybennbBI6GKSRqUDMgjquPPdpC28xJk57IBF0AE74TTNhuRUSS(gioAA28xJk57IR98GA1LL13aXffA(AdsTaHkR)IWbXOP91gKAbcvw)fjqoikcIjtR5phBDifKlf0KdA0qkFq(M37uqtoOrDRbHhn2m91GW7a5ETS(cioGqL1F00(AdsTaHkR)IelAcIeetMwZFUtdEQKR4Sh0OHu(GA2LxDNk5koRFyTZjFY3LfA7ajm7gB5I5ovYvC2dAu04BEV7ujxXz9dRDoGqL1FrIMGyY0A(ZDksb5IZQ3Th0OeetMwZFUtrkixchzVpxfMypOrjiMmTM)CNIuqU4tai3KqkFWKPvyIvEHQKl0yeetMwZFUtrkixPLQbwcWoEldmiCeetMwZFUtrkixHn9UehbXKP18N7uKcY1jGD5v7P1Vfs5dcepqoOKVlOHSKP18Uta7YR2tRFZvV13RniLGyY0A(ZDksb5cK71Y6lGes5dY38ENcAYbnQBni800(H1UibiAAA)WAxeoav0qMMD5vxxuOSBpOrpN8jFxw008nV3vVvHelakofIYbeQS(lIWrewtfRwucbXKP18N7uKcYfFFMLD8wfsSYluXfs5dY38ENcAYbnQRTJw48nV31EbaQFZgwD18UttgNHgqAAKLixaLkU2laq9B2WQRM3jFY3Lvu00(AdsTaHkR)IelgbXKP18N7uKcYLFyTtw2e5cOuXYljviLpiY4BEVtbn5Gg112PP91gKAbcvw)fjAcIjtR5p3PifKRSOKL9GgnKYhKV59of0KdAuxBNMoC(M37wtJVlwn3DRbHNMML2KPvysuOX38E3oqy1j2dA0ZTgeEAAFR3TaHbLGnXQfLeHLNA1IsqJntFni8of0KdAuhqOY6pcIjtR5p3PifKR9gO8Xv)MLVNNgs5dIm(M37uqtoOrDTDAAFTbPwGqL1Fr4qeetMwZFUtrkixS5zYRGuLL13tkjKYh0pS2HKFyTZbKn55OSXwr8dRDoQKJGgFZ7DkOjh0OU1GWJw4iBnQJnptEfKQSS(Esjw(g4DaHkR)qdzjtR5DS5zYRGuLL13tkXvV13RninkAAFR3TaHbLGnXQfLezJTOP91gKAbcvw)fjAcIjtR5p3PifKlfsSTNFA)Y6hatcP8b5BEVdimo7YDw)ayIRTttZ38EhqyC2L7S(bWelBAVka3PjJZiXqLM2xBqQfiuz9xKOjiMmTM)CNIuqUsalFXEqJgs5dY38ENcAYbnQBni8OfoFZ7D7aHvNypOrpxBhTW9dRDHgD0rrt7hw7cLJJMM2xBqQfiuz9xKOJIGyY0A(ZDksb5IbvuPas7bnAiLpiFZ7DkOjh0OU1GWJw48nV3TdewDI9Gg9CTD0c3pS2fA0rhfnTFyTluooAAAFTbPwGqL1FrIokcIjtR5p3PifKRtLCfN9GgLGibXKP18NtbfJZdA0liNvVBpOrjiMmTM)CkOyCEqJEifKRWMExIJGyY0A(ZPGIX5bn6HuqU4tai3ecIjtR5pNckgNh0Ohsb5s4i795QWe7bnkbXKP18NtbfJZdA0dPGCLfLSSh0OHu(G8nV3PGIXP9Gg9CTD0yPnzAfMGgFZ7DRPX3fRM7U2obXKP18NtbfJZdA0dPGCbY9Az9fqcP8b5BEVtbfJt7bn65A7OfEICbuQ48dRDYY6lG4Kp57YIMorUakvC1BviXcGItHOCG85m0y00jYfqPI7AGT63Sh0ONt(KVllAAn7YRUtbss1RxCYN8DzffbXKP18NtbfJZdA0dPGCLfLSSh0OHu(G8nV3PGIXP9Gg9CTD0cNV59UDGWQtSh0ONBni800Sz6RbH3LfLSSh0OoFR3TaHbLGnXQfLejzAnVllkzzpOrDS8uRwucnnFZ7DkOjh0OU2EueetMwZFofumopOrpKcYfi3RL1xajKYhKV59ofumoTh0ONRTtqmzAn)5uqX48Gg9qkixuTUwh0OHu(G8nV3PGIXP9Gg9CRbHNMMV59UDGWQtSh0ONRTJgY4BEVtbn5Gg112PP9dRDHYXOsqmzAn)5uqX48Gg9qkix(H1ozztKlGsflVKueetMwZFofumopOrpKcY1Edu(4QFZY3ZtjiMmTM)CkOyCEqJEifKl28m5vqQYY67jLqqmzAn)5uqX48Gg9qkix89zw2XBviXkVqfxiLp4oqcZUXwUyUWMExIJMgzA2LxDHn9UeNt(KVllAAnbBI60IsS6yxLejwmcIjtR5pNckgNh0Ohsb5sHeB75N2VS(bWKqkFq(M37acJZUCN1paM4A7008nV3begND5oRFamXYM2RcWDAY4msmujiMmTM)CkOyCEqJEifKR0s1albyhVLbgeocIjtR5pNckgNh0Ohsb56eWU8Q9063cP8bbIhihuY3f0qwY0AE3jGD5v7P1V5Q3671gKsqmzAn)5uqX48Gg9qkixNk5ko7bnkwXkgd]] )
    end

end