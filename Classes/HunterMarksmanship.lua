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
        spec:RegisterPack( "Marksmanship", 20201013.9, [[dCui9aqiGQEevsXMiP8jQKQgLOKtjk1RefZIuXTivb1UO4xqLggjvhtuzzKk9mOQAAuj5AKQ02ivrFdQkACKQqNdQkSoQKknpG4EKK9rQQdsQcOfcv5HujL0hbQq1iPskXjPsk1kbsZeOc5MujvStOIFsQc0sbQq5PaMkq5RKQamwsvq2lK)svdMshwyXKYJrmzfUmQnlYNvrJgkNwQvdubVMkXSv0TjXUb9BjdxfooqfTCv9CLMoX1vPTlQY3PsnEOQ05fv16bQ08PI9J0OCiWqaJqyeo6QUUQNt9C43Oo(iNUiaj)dgbCeexItgbadfgb46eVlRsaxS(abCe5pRyGadbS19jmcW1qTyICSUU4I7zlyxndPuWDBL7mKUGKpscUBRqWfbOD7P4AdrAiGrimchDvxx1ZPEo8BuhFKlNEXNiG4ky1JaaAfxRiaSEmyisdbm4LGaCnuRRLlu4NADDI3LvjGlwFqb11qT6bjsPXp1Md)6qT6QUUQtbLcQRHAbhX5XtQvFQvVQBqaZELfbgcq(M4YIvYIadHtoeyiaggAtEGWdbq(w4VdeaPQ5OCdnrRWd)IvI5EqTooulPQ5OCdnFC0dFQF28Ss0WLA1NAjvnhLBOjAfE4xSsmpRenCrabr6cIag1vBYEjoqcchDrGHayyOn5bcpea5BH)oqa)fYP6pzZw3zQ(t2ZkA8VggCE7JdEqTQrTs8E5JdZZkrdxQfeQ9KmOw1OwsvZr5gAsZ4zZZkrdxQfeQ9Kmqabr6cIaK49YhhibHd(rGHayyOn5bcpea5BH)oqa)fYP6pzZw3zQ(t2ZkA8VgggAtEqTQrTs8E5JdZ9abeePlicinJNrcchxHadbeePlicWDph(9O)wweaddTjpq4Heeo6fbgciisxqeqE1CY5JayyOn5bcpKGWrprGHacI0feb88wWqA4Pp(VCJayyOn5bcpKGWbFIadbeePlicql(pozeaddTjpq4Heeo6reyiGGiDbram(EmRTZJ9lwjiaggAtEGWdjiCWhiWqamm0M8aHhcG8TWFhiasvZr5gA(4Oh(u)S5zLOHl164qTPICxQnd1gePlO5JJE4t9ZgsSI)5tgsT6tTPICxJsGVuRJd1M6tmX)Ss0WLAbHAZPxeqqKUGia5V8Ivcsq4KtDeyiaggAtEGWdbq(w4VdeG2nLmY3ex8lwjR5EqTQrTzrTA3uYC8mPx2VyLSMr5gsToouB6oN(NjyXFYEPvyQfeQLeR4LwHP2mu7jzqToouR2nLmYF5fReZ9GAZgbeePliciAfE4xSsqccNC5qGHayyOn5bcpea5BH)oqaPICxQnd1sIv8pFYqQfeQnvK7Auc8fbeePlicyWHG5jyHlFOGeeo50fbgcGHH2Khi8qaKVf(7abODtjJ8nXf)IvYAUhuRAuR2nLmJ6QnzVehMr5gIacI0feb8Xrp8P(zKGWjh(rGHayyOn5bcpea5BH)oqaA3uYiFtCXVyLSMr5gsToouR2nLmhpt6L9lwjR5EqToouBQi3LA1dtTKAfQnd1sIv8pFYqQvFQnisxqt0k8WVyLyi1kiGGiDbrak3P0lwjibHtoxHadbWWqBYdeEiaY3c)DGa0UPKzWXWZ5ZMr5gIacI0feb4spN(fReKGWjNErGHacI0febeEL7p43xjp5l3lcGHH2Khi8qccNC6jcmeqqKUGiG0mYNh(fReeaddTjpq4Heeo5WNiWqamm0M8aHhciisxqeWY)bdf)kn8ebq(w4VdeWZPNxSqBYias(Kj7L4pzzr4KdjiCYPhrGHacI0febSchJ89lwjiaggAtEGWdjibbm4uCNccmeo5qGHacI0febqQlu43VyLGayyOn5bcpKGWrxeyiaggAtEGWdbeePlicyEFx4F9nC7rx31F2jbbq(w4VdeaPQ5OCdnYF5fReZZkrdx)5L3LAbHAZPxQ1XHAt9jM4FwjA4sTGqT4xDeamuyeW8(UW)6B42JUUR)Stcsq4GFeyiaggAtEGWdbeePlicia3fl(y9Pck(k5pk38JaiFl83bcilQn1NyI)zLOHl1Qp1gePlONu1CuUHuBgQf)UIADCOwj(twmyCmfmZbrOwqOwDvNADCOwj(twmsRWEP8heXRR6uliuBo9sTztTQrTKQMJYn0i)LxSsmpRenC9NxExQfeQnNEPwhhQn1NyI)zLOHl1cc1IF9IaGHcJacWDXIpwFQGIVs(JYn)ibHJRqGHayyOn5bcpeqqKUGiG5DLVUR)SMdg6pMxL4KraKVf(7abqQAok3qJ8xEXkX8Ss0W1FE5DPwqOw9sToouBQpXe)ZkrdxQfeQvx1raWqHraZ7kFDx)znhm0FmVkXjJeeo6fbgcGHH2Khi8qabr6cIaoJjtI5K)1Rvfebq(w4VdeG2nLmYF5fReZZkrdxQvFQnNROwhhQf8uRetgkgsmNn80lySFXkznmm0M8GADCO2uFIj(NvIgUuliuBo1raWqHraNXKjXCY)61QcIeeo6jcmeaddTjpq4HacI0febelwEbKx)hGB9Es9Xebq(w4VdeG2nLmYF5fReZZkrdxQvFQnNROw1O2SOwTBkzoVXp6a6RKpax(lbZCpOwhhQf8ulVldjSHuWbdxE4NDIt1tyJsaoup1Qg1scFqKopMAZMADCO2bRDtjZhGB9Es9X0pyTBkzgLBi164qTP(et8pRenCPwqOwDvhbadfgbelwEbKx)hGB9Es9XejiCWNiWqamm0M8aHhciisxqeWrrCHLTbxE4jLYXvcPlOFW51egbq(w4Vdea4PwTBkzK)YlwjM7b1Qg1cEQL3LHe2OnRA4RKxWypdzL8nkb4q9uRJd1oyTBkz0Mvn8vYlySNHSs(M7b164qTP(et8pRenCPwqOw9IaGHcJaokIlSSn4YdpPuoUsiDb9doVMWibHJEebgcGHH2Khi8qaKVf(7abODtjJ8xEXkX8Ss0WLA1NAZ5kQ1XHAbp1kXKHIHeZzdp9cg7xSswdddTjpOwhhQn1NyI)zLOHl1cc1QR6iGGiDbra3L9TWklsq4GpqGHayyOn5bcpeqqKUGiasmN(GiDb9ZEfeWSxXddfgbqglsq4KtDeyiaggAtEGWdbq(w4VdeqqKop2ZqwP5LAbHAXpciisxqeajMtFqKUG(zVccy2R4HHcJawbjiCYLdbgcGHH2Khi8qaKVf(7abeePZJ9mKvAEPw9PwDrabr6cIaiXC6dI0f0p7vqaZEfpmuyeG8nXLfRKfjibbC8mPu0cbbgcNCiWqamm0M8aHhcG8TWFhiG)c5u9NSzR7mv)j7zfn(xddoV9Xbpqabr6cIaK49YhhibHJUiWqamm0M8aHhc44zsSIxAfgbKtDeqqKUGiGrD1MSxIdKGWb)iWqamm0M8aHhcG8TWFhiGGiDESNHSsZl1QIAZHacI0febeTcp8lwjibjiaYyrGHWjhcmeaddTjpq4HaiFl83bcGu1CuUHMpo6Hp1pBEwjA4sTGqTNKb164qTKQMJYn08Xrp8P(zZZkrdxQfeQLu1CuUHMOv4HFXkX8Ss0WLADCO2uFIj(NvIgUuliuRUQJacI0febmQR2K9sCGeeo6IadbWWqBYdeEiaY3c)DGa0UPKr(lVyLyEwjA4sT6tT5Cf1Qg1Mf1M6tmX)Ss0WLA1NAjvnhLBOrJ)LFxA4PzC)q6csTzO2X9dPli164qTzrTs8NSyW4ykyMdIqTGqT6Qo164qTGNALyYqXqINt3PpAfdddTjpO2SP2SPwhhQn1NyI)zLOHl1cc1Md)iGGiDbraA8V87sdprcch8JadbWWqBYdeEiaY3c)DGa0UPKr(lVyLyEwjA4sT6tT5Cf1Qg1Mf1M6tmX)Ss0WLA1NAjvnhLBOrBw1WNUF(MX9dPli1MHAh3pKUGuRJd1Mf1kXFYIbJJPGzoic1cc1QR6uRJd1cEQvIjdfdjEoDN(Ovmmm0M8GAZMAZMADCO2uFIj(NvIgUuliuBo9ebeePlicqBw1WNUF(ibHJRqGHayyOn5bcpea5BH)oqaA3uYi)LxSsmpRenCPw9P2CUIAvJAZIAt9jM4FwjA4sT6tTKQMJYn0eqcVYhtpjMtZ4(H0fKAZqTJ7hsxqQ1XHAZIAL4pzXGXXuWmheHAbHA1vDQ1XHAbp1kXKHIHepNUtF0kgggAtEqTztTztToouBQpXe)ZkrdxQfeQnNEIacI0febeqcVYhtpjMtKGWrViWqamm0M8aHhcG8TWFhiaTBkzK)YlwjMNvIgUuR(uBoxrTQrTzrTP(et8pRenCPw9PwsvZr5gAs9ZAZQgMX9dPli1MHAh3pKUGuRJd1Mf1kXFYIbJJPGzoic1cc1QR6uRJd1cEQvIjdfdjEoDN(Ovmmm0M8GAZMAZMADCO2uFIj(NvIgUuliul(abeePlici1pRnRAGeeo6jcmeaddTjpq4HaiFl83bcq7Msg5V8IvIzuUHiGGiDbraZ(etwp4WDCQWqbjiCWNiWqamm0M8aHhcG8TWFhiaTBkzK)YlwjMr5gIacI0febOfN(k5LVjUSibHJEebgcGHH2Khi8qaKVf(7abODtjJ8xEXkXmk3qQvnQnlQvI)KfdghtbZCqeQvFQvpQo164qTs8NSyW4ykyMdIqTGOIA1vDQ1XHAL4pzXiTc7LYFqeVUQtT6tT4xDQnBeqqKUGiGNJJgE6tZqHxKGWbFGadbWWqBYdeEiaY3c)DGaYIAjvnhLBOja3fl(y9Pck(k5pk38BEwjA4sT6tT6Qo164qTGNAzW5Tpo4Hja3fl(y9Pck(k5pk38tToouBQpXe)ZkrdxQfeQLu1CuUHMaCxS4J1NkO4RK)OCZVzC)q6csTzOw87kQvnQvI)KfdghtbZCqeQvFQvx1P2SPw1O2SOwsvZr5gAK)YlwjMNvIgU(ZlVl1cc1IFQ1XHAZIA5DziHn51BxqFL8h8NyI0f0O0W6Pw1O2uFIj(NvIgUuR(uBqKUGEsvZr5gsTzOwTBkzCx)CKh3q)ZBbdiHnJ7hsxqQnBQnBQ1XHAt9jM4FwjA4sTGqT6QociisxqeG76NJ84g6FElyajmsq4KtDeyiaggAtEGWdbq(w4Vdeqwulj8br68yQ1XHAt9jM4FwjA4sT6tTbr6c6jvnhLBi1MHAXV6uB2uRAuBwuR2nLmYF5fReZ9GADCOwsvZr5gAK)YlwjMNvIgUuliuBo9KAZMADCO2uFIj(NvIgUuliul(ZHacI0febCEJF0b0xjFaU8xcgsq4KlhcmeaddTjpq4HaiFl83bcGu1CuUHg5V8IvI5zLOHl1cc1Iprabr6cIa((4yY(g63JGWibHtoDrGHayyOn5bcpea5BH)oqaGNA1UPKr(lVyLyUhiGGiDbrakSs957RKFEj9WpEouwKGWjh(rGHayyOn5bcpea5BH)oqaA3uYi)LxSsmpheHAvJA1UPKrBw1yExX8CqeQ1XHA1UPKr(lVyLyEwjA4sT6tT5Cf1Qg1kXFYIbJJPGzoic1cc1QR6uRJd1Mf1Mf1sk4EvcTjBokPlOVs(lu77XKh(09ZNADCOwsb3RsOnzZfQ99yYdF6(5tTztTQrTP(et8pRenCPwqOw9mh164qTP(et8pRenCPwqOwD1tQnBeqqKUGiGJs6cIeeo5CfcmeaddTjpq4HaiFl83bcq7Msg5V8IvIzuUHuRAulPQ5OCdnFC0dFQF28Ss0WLADCO2uFIj(NvIgUuliuBo9IacI0febi)LxSsqcsqaRGadHtoeyiaggAtEGWdbq(w4VdeGetgkMv4yKVpvK7AyyOn5b1Qg1E8CE(tYWKZSchJ89lwjuRAuR2nLmRWXiFFQi318Ss0WLAbHA1lciisxqeWkCmY3VyLGeeo6IadbeePlicWLEo9lwjiaggAtEGWdjiCWpcmeqqKUGiGrD1MSxIdeaddTjpq4HeeoUcbgcGHH2Khi8qaKVf(7ab8xiNQ)KnBDNP6pzpROX)AyW5Tpo4b1Qg1kX7LpompRenCPwqO2tYGAvJAjvnhLBOjnJNnpRenCPwqO2tYabeePlicqI3lFCGeeo6fbgcGHH2Khi8qaKVf(7ab8xiNQ)KnBDNP6pzpROX)AyyOn5b1Qg1kX7Lpom3deqqKUGiG0mEgjiC0teyiGGiDbraU75WVh93YIayyOn5bcpKGWbFIadbeePlicinJ85HFXkbbWWqBYdeEibHJEebgcGHH2Khi8qaKVf(7abKkYDP2muljwX)8jdPwqO2urURrjWxeqqKUGiGbhcMNGfU8Hcsq4GpqGHacI0febW47XS2op2VyLGayyOn5bcpKGWjN6iWqamm0M8aHhcG8TWFhiaTBkzoEM0l7xSswZOCdPwhhQf8uRetgkgcwRe8h(fRedddTjpqabr6cIaYRMtoFKGWjxoeyiGGiDbraHx5(d(9vYt(Y9IayyOn5bcpKGWjNUiWqamm0M8aHhcG8TWFhiaTBkzoEM0l7xSswZOCdPwhhQf8uRetgkgcwRe8h(fRedddTjpqabr6cIaEElyin80h)xUrccNC4hbgcGHH2Khi8qaKVf(7abODtjZXZKEz)IvYAgLBi164qTGNALyYqXqWALG)WVyLyyyOn5bciisxqeG8xEXkbjiCY5keyiaggAtEGWdbq(w4VdeqwuB6oN(NjyXFYEPvyQfeQLeR4LwHP2mu7jzqToouR2nLmYF5fReZ9GAZMAvJAZIA1UPK54zsVSFXkznJYnKADCOwWtTsmzOyiyTsWF4xSsmmm0M8GADCOws4dI05XuB2uRJd1QDtjJ8nXf)IvYAEwjA4sT6tTm(YKRWEPvyQvnQnlQnisNh7ziR08sT6tT5OwhhQ9Vqov)jBw(pyOSsmDH)1lFtCH)8nm482hh8GAZgbeePliciAfE4xSsqccNC6fbgcGHH2Khi8qaKVf(7abODtjZOUAt2lXHzuUHuRAuBQi3LAZqTKyf)ZNmKAbHAtf5UgLaFrabr6cIa(4Oh(u)msq4KtprGHayyOn5bcpea5BH)oqaA3uYC8mPx2VyLSM7b1Qg1Mf1QDtjJ8xEXkXmk3qQ1XHAdI05XEgYknVuR(uBoQ1XHAbp1scFqKopMAZgbeePlicGG1kb)HFXkbjiCYHprGHayyOn5bcpeqqKUGiGL)dgk(vA4jcG8TWFhiGNtpVyH2KPw1Owj(twmsRWEP8JMPw9P2X9dPlicGKpzYEj(twweo5qccNC6reyiaggAtEGWdbq(w4VdeqqKop2ZqwP5LA1NAZHacI0febOf)hNmsq4KdFGadbWWqBYdeEiaY3c)DGa0UPK54zsVSFXkzn3dQvnQnlQv7Msg5V8IvIzuUHuRJd1cEQLe(GiDEm1Mnciisxqeq8KaY(fReKGWrx1rGHayyOn5bcpea5BH)oqaA3uYC8mPx2VyLSMr5gIacI0febeTcp8lwjibHJU5qGHayyOn5bcpea5BH)oqaPICxQvFQLuRqTzO2GiDbnrRWd)IvIHuRqTQrTzrTA3uYi)LxSsmJYnKADCOwWtTKWhePZJP2Srabr6cIaiyTsWF4xSsqcchD1fbgcGHH2Khi8qaKVf(7abKkYDPw9PwsTc1MHAdI0f0eTcp8lwjgsTc1Qg1Mf1QDtjJ8xEXkXmk3qQ1XHAbp1scFqKopMAZgbeePliciEsaz)Ivcsq4Ol(rGHayyOn5bcpea5BH)oqaPICxQnd1sIv8pFYqQfeQnvK7Auc8fbeePlicyfog57xSsqcchDDfcmeqqKUGiacwRe8h(fReeaddTjpq4Heeo6QxeyiGGiDbraXtci7xSsqamm0M8aHhsqcsqa5X)2feHJUQRR65upNUg8bcWD8WgEUia9a0deCmCCTXbCCxxQLAbdJP2w5OEHAt1tTUEYyD9u7ZGZB)8GA3sHP24kLsi8GAjyb8KxdfuWrnKPw8HRl16ATG5XVWdQ11lFdDHfJEidPQ5OCdD9uRuuRRNu1CuUHg9qUEQnlDX3SnuqPG6ARCuVWdQvVuBqKUGu7Sxznuqra7btq4OREDfc44RupzeGRHADTCHc)uRRt8USkbCX6dkOUgQvpirkn(P2C4xhQvx11vDkOuqDnul4iopEsT6tT6vDdfukObr6cUMJNjLIwizuHReVx(4qNoP6Vqov)jB26ot1FYEwrJ)1WGZBFCWdkObr6cUMJNjLIwizuH7OUAt2lXHohptIv8sRWQYPof0GiDbxZXZKsrlKmQWnAfE4xSs0PtQcI05XEgYknVQYrbLcAqKUGBgv4sQlu43VyLqbnisxWnJkCVl7BHv0bgkSQ59DH)13WThDDx)zNeD6KksvZr5gAK)YlwjMNvIgU(ZlVli50RJtQpXe)ZkrdxqWV6uqdI0fCZOc37Y(wyfDGHcRka3fl(y9Pck(k5pk38RtNuLvQpXe)Zkrdx9jvnhLByg87khhj(twmyCmfmZbrarx1DCK4pzXiTc7LYFqeVUQdso9MTAKQMJYn0i)LxSsmpRenC9NxExqYPxhNuFIj(NvIgUGGF9sbnisxWnJkCVl7BHv0bgkSQ5DLVUR)SMdg6pMxL4K1PtQivnhLBOr(lVyLyEwjA46pV8UGOxhNuFIj(NvIgUGOR6uqdI0fCZOc37Y(wyfDGHcR6mMmjMt(xVwvqD6KkTBkzK)YlwjMNvIgU6NZvooGxIjdfdjMZgE6fm2VyLSgggAtE44K6tmX)Ss0WfKCQtbnisxWnJkCVl7BHv0bgkSQyXYlG86)aCR3tQpM60jvA3uYi)LxSsmpRenC1pNRullTBkzoVXp6a6RKpax(lbZCpCCapVldjSHuWbdxE4NDIt1tyJsaouVAKWhePZJZ2XzWA3uY8b4wVNuFm9dw7MsMr5g64K6tmX)Ss0WfeDvNcAqKUGBgv4Ex23cROdmuyvhfXfw2gC5HNukhxjKUG(bNxtyD6KkWRDtjJ8xEXkXCpud88UmKWgTzvdFL8cg7ziRKVrjahQ3XzWA3uYOnRA4RKxWypdzL8n3dhNuFIj(NvIgUGOxkOUgQfSpFQvkQD2qMAVhuBqKoVq4b1kFdDHLLAD3cg1c2F5fRekObr6cUzuH7DzFlSYQtNuPDtjJ8xEXkX8Ss0Wv)CUYXb8smzOyiXC2WtVGX(fRK1WWqBYdhNuFIj(NvIgUGOR6uqdI0fCZOcxsmN(GiDb9ZEfDGHcRImwkObr6cUzuHljMtFqKUG(zVIoWqHvTIoDsvqKop2ZqwP5fe8tbnisxWnJkCjXC6dI0f0p7v0bgkSk5BIllwjRoDsvqKop2ZqwP5vFDPGsbnisxW1qgBgv4oQR2K9sCOtNurQAok3qZhh9WN6NnpRenCb5KmCCivnhLBO5JJE4t9ZMNvIgUGqQAok3qt0k8WVyLyEwjA464K6tmX)Ss0WfeDvNcAqKUGRHm2mQWvJ)LFxA4PoDsL2nLmYF5fReZZkrdx9Z5k1Yk1NyI)zLOHR(KQMJYn0OX)YVln80mUFiDbZmUFiDbDCYsI)KfdghtbZCqeq0vDhhWlXKHIHepNUtF0kgggAtEKD2ooP(et8pRenCbjh(PGgePl4AiJnJkC1Mvn8P7NVoDsL2nLmYF5fReZZkrdx9Z5k1Yk1NyI)zLOHR(KQMJYn0OnRA4t3pFZ4(H0fmZ4(H0f0Xjlj(twmyCmfmZbrarx1DCaVetgkgs8C6o9rRyyyOn5r2z74K6tmX)Ss0WfKC6jf0GiDbxdzSzuHBaj8kFm9Kyo1PtQ0UPKr(lVyLyEwjA4QFoxPwwP(et8pRenC1Nu1CuUHMas4v(y6jXCAg3pKUGzg3pKUGoozjXFYIbJJPGzoici6QUJd4LyYqXqINt3PpAfdddTjpYoBhNuFIj(NvIgUGKtpPGgePl4AiJnJkCt9ZAZQg60jvA3uYi)LxSsmpRenC1pNRulRuFIj(NvIgU6tQAok3qtQFwBw1WmUFiDbZmUFiDbDCYsI)KfdghtbZCqeq0vDhhWlXKHIHepNUtF0kgggAtEKD2ooP(et8pRenCbbFqbnisxW1qgBgv4o7tmz9Gd3XPcdfD6KkTBkzK)YlwjMr5gsbnisxW1qgBgv4QfN(k5LVjUS60jvA3uYi)LxSsmJYnKcAqKUGRHm2mQW954OHN(0mu4vNoPs7Msg5V8IvIzuUHQLLe)jlgmoMcM5Gi6Rhv3XrI)KfdghtbZCqequPR6oos8NSyKwH9s5piIxx11h)QNnf0GiDbxdzSzuHR76NJ84g6FElyajSoDsvwY3qxyXeG7IfFS(ubfFL8hLB(nKQMJYn08Ss0WvFDv3Xb8m482hh8WeG7IfFS(ubfFL8hLB(DCs9jM4FwjA4cI8n0fwmb4UyXhRpvqXxj)r5MFdPQ5OCdnJ7hsxWm43vQjXFYIbJJPGzoiI(6QE2QLfPQ5OCdnYF5fReZZkrdx)5L3fe874KfVldjSjVE7c6RK)G)etKUGgLgwVAP(et8pRenC1Nu1CuUHz0UPKXD9ZrECd9pVfmGe2mUFiDbZoBhNuFIj(NvIgUGOR6uqdI0fCnKXMrfUN34hDa9vYhGl)LGPtNuLfj8br68yhNuFIj(NvIgU6tQAok3Wm4x9SvllTBkzK)YlwjM7HJdPQ5OCdnYF5fReZZkrdxqYPNz74K6tmX)Ss0Wfe8NJcAqKUGRHm2mQW97JJj7BOFpccRtNurQAok3qJ8xEXkX8Ss0Wfe8jf0GiDbxdzSzuHRcRuF((k5Nxsp8JNdLvNoPc8A3uYi)LxSsm3dkObr6cUgYyZOc3Js6cQtNuPDtjJ8xEXkX8Cqe10UPKrBw1yExX8CqehhTBkzK)YlwjMNvIgU6NZvQjXFYIbJJPGzoici6QUJtwzrk4EvcTjBokPlOVs(lu77XKh(09Z3XHuW9QeAt2CHAFpM8WNUF(zRwQpXe)Zkrdxq0ZCooP(et8pRenCbrx9mBkObr6cUgYyZOcx5V8IvIoDsL2nLmYF5fReZOCdvJu1CuUHMpo6Hp1pBEwjA464K6tmX)Ss0WfKC6Lckf0GiDbxJ8nXLfRKnJkCh1vBYEjo0PtQivnhLBOjAfE4xSsm3dhhsvZr5gA(4Oh(u)S5zLOHR(KQMJYn0eTcp8lwjMNvIgUuqdI0fCnY3exwSs2mQWvI3lFCOtNu9xiNQ)KnBDNP6pzpROX)AyW5Tpo4HAs8E5JdZZkrdxqojd1ivnhLBOjnJNnpRenCb5KmOGgePl4AKVjUSyLSzuHBAgpRtNu9xiNQ)KnBDNP6pzpROX)AyyOn5HAs8E5JdZ9GcAqKUGRr(M4YIvYMrfUU75WVh93YsbnisxW1iFtCzXkzZOc38Q5KZNcAqKUGRr(M4YIvYMrfUpVfmKgE6J)l3uqdI0fCnY3exwSs2mQWvl(pozkObr6cUg5BIllwjBgv4Y47XS2op2VyLqbnisxW1iFtCzXkzZOcx5V8IvIoDsfPQ5OCdnFC0dFQF28Ss0W1XjvK7MjisxqZhh9WN6NnKyf)ZNmu)urURrjWxhNuFIj(NvIgUGKtVuqdI0fCnY3exwSs2mQWnAfE4xSs0PtQ0UPKr(M4IFXkzn3d1Ys7MsMJNj9Y(fRK1mk3qhN0Do9ptWI)K9sRWGqIv8sRWzojdhhTBkzK)YlwjM7r2uqdI0fCnY3exwSs2mQWDWHG5jyHlFOOtNuLkYDZqIv8pFYqqsf5UgLaFPGgePl4AKVjUSyLSzuH7hh9WN6N1PtQ0UPKr(M4IFXkzn3d10UPKzuxTj7L4Wmk3qkObr6cUg5BIllwjBgv4QCNsVyLOtNuPDtjJ8nXf)IvYAgLBOJJ2nLmhpt6L9lwjR5E44KkYD1dtQvYqIv8pFYq9dI0f0eTcp8lwjgsTcf0GiDbxJ8nXLfRKnJkCDPNt)IvIoDsL2nLmdogEoF2mk3qkObr6cUg5BIllwjBgv4gEL7p43xjp5l3lf0GiDbxJ8nXLfRKnJkCtZiFE4xSsOGgePl4AKVjUSyLSzuH7Y)bdf)kn8uhs(Kj7L4pzzvLtNoP650ZlwOnzkObr6cUg5BIllwjBgv4UchJ89lwjuqPGgePl4AwjJkCxHJr((fReD6KkjMmumRWXiFFQi31WWqBYd1oEop)jzyYzwHJr((fRe10UPKzfog57tf5UMNvIgUGOxkObr6cUMvYOcxx650VyLqbnisxW1Ssgv4oQR2K9sCqbnisxW1Ssgv4kX7Lpo0PtQ(lKt1FYMTUZu9NSNv04Fnm482hh8qnjEV8XH5zLOHliNKHAKQMJYn0KMXZMNvIgUGCsguqdI0fCnRKrfUPz8SoDs1FHCQ(t2S1DMQ)K9SIg)RHHH2KhQjX7Lpom3dkObr6cUMvYOcx39C43J(BzPGgePl4AwjJkCtZiFE4xSsOGgePl4AwjJkChCiyEcw4Yhk60jvPIC3mKyf)ZNmeKurURrjWxkObr6cUMvYOcxgFpM125X(fRekObr6cUMvYOc38Q5KZxNoPs7MsMJNj9Y(fRK1mk3qhhWlXKHIHG1kb)HFXkXWWqBYdkObr6cUMvYOc3WRC)b)(k5jF5EPGgePl4AwjJkCFElyin80h)xU1PtQ0UPK54zsVSFXkznJYn0Xb8smzOyiyTsWF4xSsmmm0M8GcAqKUGRzLmQWv(lVyLOtNuPDtjZXZKEz)IvYAgLBOJd4LyYqXqWALG)WVyLyyyOn5bf0GiDbxZkzuHB0k8WVyLOtNuLv6oN(NjyXFYEPvyqiXkEPv4mNKHJJ2nLmYF5fReZ9iB1Ys7MsMJNj9Y(fRK1mk3qhhWlXKHIHG1kb)HFXkXWWqBYdhhs4dI05Xz74ODtjJ8nXf)IvYAEwjA4QpJVm5kSxAfwTScI05XEgYknV6NZX5Vqov)jBw(pyOSsmDH)1lFtCH)8nm482hh8iBkObr6cUMvYOc3po6Hp1pRtNuPDtjZOUAt2lXHzuUHQLkYDZqIv8pFYqqsf5UgLaFPGgePl4AwjJkCjyTsWF4xSs0PtQ0UPK54zsVSFXkzn3d1Ys7Msg5V8IvIzuUHoobr68ypdzLMx9Z54aEs4dI05XztbnisxW1Ssgv4U8FWqXVsdp1HKpzYEj(twwv50PtQEo98IfAtwnj(twmsRWEP8JM1FC)q6csbnisxW1Ssgv4Qf)hNSoDsvqKop2ZqwP5v)CuqdI0fCnRKrfUXtci7xSs0PtQ0UPK54zsVSFXkzn3d1Ys7Msg5V8IvIzuUHooGNe(GiDEC2uqdI0fCnRKrfUrRWd)IvIoDsL2nLmhpt6L9lwjRzuUHuqdI0fCnRKrfUeSwj4p8lwj60jvPICx9j1kzcI0f0eTcp8lwjgsTIAzPDtjJ8xEXkXmk3qhhWtcFqKopoBkObr6cUMvYOc34jbK9lwj60jvPICx9j1kzcI0f0eTcp8lwjgsTIAzPDtjJ8xEXkXmk3qhhWtcFqKopoBkObr6cUMvYOc3v4yKVFXkrNoPkvK7MHeR4F(KHGKkYDnkb(sbnisxW1Ssgv4sWALG)WVyLqbnisxW1Ssgv4gpjGSFXkbjibHaa]] )
    else
        spec:RegisterPack( "Marksmanship", 20201013.1, [[dG0D6aqiikpcIQAtiL(eeqnkQQ6uuvzvuLe8kiYSOQ0Ue8lKkdds5ycLLrvQNbjAAuL4AcjBdIkFJQKACuLKoheOwheqmpH4Euf7JQIdcbGwisvpKQKiFecK0iPkj0jHauRecntia5Mqa0oHu9tiayOqGuTuiqkpfutfs6RqGeJLQKO2lu)LsdMIdlAXOQhJYKvQltSzQ8zLy0GCAjRgceVgPy2k62iz3Q63snCL0XHaslh45QmDsxxHTlK67cvJhIQCEiO1djmFuz)ighdJkgENQGr3B08gTyOfdLb0qWX8gLihgwr4QGHxtgn5IGH)KsWWiatanhv(huTIHxteo7CJrfdF9aWemmYNyGuD9qGqhDlLcn4dSMIUROgZuR(zG0P0DffJomm)OMkc4hZJH3Pky09gnVrlgAXqzaneCmVrPxWW5qHAaggUO8kHHHQ9wEmpgElhddJ8jgeGjGMJk)dQwjgVIJxfabrKpXGaatBEbqmXqPVeJ3O5nAeejiI8jgeqs0YKyI4HyIcTagEwNEyuXWkOy0CqTEyuXOhdJkgozA1pgMMAoThuRyy5t(PSX0Jvm6EJrfdNmT6hdhDpNccXWYN8tzJPhRy0rjgvmCY0QFmmFca5IGHLp5NYgtpwXO7fmQy4KPv)yyb5To7RIwShuRyy5t(PSX0Jvm6rHrfdlFYpLnMEmmduQaQedZpCUGckgn2dQ1lmwjgAjgwAtMwrledTed)W5c7EWpfRMRHXkgozA1pgolkzBpOwXkgDKdJkgw(KFkBm9yygOubujgMF4CbfumAShuRxySsm0sm(tmjkeqPsW1SXjBRRasq(KFkBIHJJysuiGsLq9wfsSaieQqubq(0qm(qmXigooIjrHakvc3aSu)I9GA9cYN8tztmCCeJMt51WPajPM1lb5t(PSjg)WWjtR(XWGCT2wxbeSIr3RXOIHLp5NYgtpgMbkvavIH5hoxqbfJg7b16fgRedTeJ)ed)W5cRaHvNypOwVWUJ)edhhXW6EU74FilkzBpOwdUXCAbcdkblIvlkHyIqmjtR(dzrjB7b1AGLNA1IsigooIHF4CbfmKdQ1WyLy8ddNmT6hdNfLSThuRyfJUxfJkgw(KFkBm9yygOubujgMF4CbfumAShuRxySIHtMw9JHb5ATTUciyfJocgJkgw(KFkBm9yygOubujgMF4CbfumAShuRxy3XFIHJJy4hoxyfiS6e7b16fgRedTedYig(HZfuWqoOwdJvIHJJyCnBCeJpeJxJggozA1pgMAm16GAfRy0JHggvmCY0QFmSRzJt22efcOuXYljfgw(KFkBm9yfJESyyuXWjtR(XWRdq5qy9lw(zEkgw(KFkBm9yfJEmVXOIHtMw9JHz9ZKxbPkBRBMucgw(KFkBm9yfJEmuIrfdNmT6hdZp7EBBNvHeR8cfcXWYN8tzJPhRy0J5fmQyy5t(PSX0JHzGsfqLyy(HZfacJMPCN11aMegRedhhXWpCUaqy0mL7SUgWelRhVkGWPjJgIjcXednmCY0QFmScj2XZ3JFBDnGjyfJESOWOIHtMw9JHtl1aSfGTDwgOJFyy5t(PSX0Jvm6XqomQyy5t(PSX0JHzGsfqLyyG4aYbL8tHyOLyqgXKmT6pCcyvE1EA9lH6TUzTaPy4KPv)y4taRYR2tRFbRy0J51yuXWjtR(XWNk5gH2dQvmS8j)u2y6XkwXWBXLJPIrfJEmmQy4KPv)yywpEva2dQvmS8j)u2y6XkgDVXOIHLp5NYgtpgozA1pgEoa0iGZw)v7QhNDPCkgMbkvavIHzDp3D8pOGHCqTgacvw)zxgYDeteIjwuedhhX4Qfi1ceQS(JyIqmOenm8NucgEoa0iGZw)v7QhNDPCkwXOJsmQyy5t(PSX0JHtMw9JHtuCqjipRRF12o7AhxayygOubujg2FIXvlqQfiuz9hX4dXKmT63Y6EU74pXGeXGsVqmCCeJMGfrdqsovOWktjMieJ3OrmCCeJMGfrdArjwTTRm16nAeteIjwueJFedTedR75UJ)bfmKdQ1aqOY6p7YqUJyIqmXIIy44igxTaPwGqL1FeteIbLrHH)KsWWjkoOeKN11VABNDTJlaSIr3lyuXWYN8tzJPhdNmT6hdphNc6Xzx65wE76CqLlcgMbkvavIHzDp3D8pOGHCqTgacvw)zxgYDeteIjkIHJJyC1cKAbcvw)rmrigVrdd)jLGHNJtb94Sl9ClVDDoOYfbRy0JcJkgw(KFkBm9y4KPv)y4LCkSCofWz57(XWmqPcOsmm)W5ckyihuRbGqL1FeJpetmVqmCCedYignNYRbwoN1VyviXEqTEb5t(PSjgooIXvlqQfiuz9hXeHyIHgg(tkbdVKtHLZPaolF3pwXOJCyuXWYN8tzJPhdNmT6hdNhu05lNfKOObwwdYjgMbkvavIH5hoxqbd5GAnaeQS(Jy8HyI5fIHwIXFIHF4CHLrc2v(22ztuiGwHcJvIHJJyqgXi3jptcS(3YFY2olN4AatcujcsdigAjgwAtMwrleJFedhhXSf(HZfajkAGL1GCA3c)W5c7o(tmCCeJRwGulqOY6pIjcX4nAy4pPemCEqrNVCwqIIgyzniNyfJUxJrfdlFYpLnMEmCY0QFm8AZOr0RqHSTSMADOPw9B3s0ftWWmqPcOsmmYig(HZfuWqoOwdJvIHwIbzeJCN8mjWp7EBBNvHeR8cfcdujcsdigooIzl8dNlWp7EBBNvHeR8cfcdJvIHJJyC1cKAbcvw)rmriMOWWFsjy41MrJOxHczBzn16qtT63ULOlMGvm6EvmQyy5t(PSX0JHzGsfqLyy(HZfuWqoOwdaHkR)igFiMyEHy44igKrmAoLxdSCoRFXQqI9GA9cYN8tztmCCeJRwGulqOY6pIjcX4nAy4KPv)y4Xj2sfQdRy0rWyuXWYN8tzJPhdNmT6hdZY50MmT63oRtXWZ6u7NucgMTpSIrpgAyuXWYN8tzJPhdZaLkGkXWjtROfR8cvjhXeHyqjgozA1pgMLZPnzA1VDwNIHN1P2pPem8PyfJESyyuXWYN8tzJPhdZaLkGkXWjtROfR8cvjhX4dX4ngozA1pgMLZPnzA1VDwNIHN1P2pPemSckgnhuRhwXkgEfiSMIpvmQy0JHrfdlFYpLnMEm8kqy5PwTOemCm0WWjtR(XW7EWpfRMRyfJU3yuXWYN8tzJPhd)jLGHtuCqjipRRF12o7Ahxay4KPv)y4efhucYZ66xTTZU2XfawXOJsmQy4KPv)y44nyUJwQ3cKR)8zcgw(KFkBm9yfJUxWOIHtMw9JHxgjyx5BBNnrHaAfcdlFYpLnMESIrpkmQy4KPv)yykHQbi02o7CWQTDdKK6WWYN8tzJPhRy0romQyy5t(PSX0JHxbclp1QfLGHJfIcdNmT6hdRGHCqTIHzGsfqLy4KPv0IvEHQKJy8Hy8gRy09AmQyy5t(PSX0JHzGsfqLy4KPv0IvEHQKJyIqmOedNmT6hdNfLSThuRyfRyy2(WOIrpggvmS8j)u2y6XWmqPcOsmmR75UJ)bqUwBRRasaiuz9hXeHywyBIHJJyyDp3D8paY1ABDfqcaHkR)iMiedR75UJ)HSOKT9GAnaeQS(Jy44igxTaPwGqL1FeteIXB0WWjtR(XW7EWpfRMRyfJU3yuXWYN8tzJPhdZaLkGkXW8dNlOGHCqTgacvw)rm(qmX8cXqlX4pX4Qfi1ceQS(Jy8HyyDp3D8pWlGta0u)sypaPw9tmirm7bi1QFIHJJy8Ny0eSiAasYPcfwzkXeHy8gnIHJJyqgXO5uEnWsG4gtBwub5t(PSjg)ig)igooIXvlqQfiuz9hXeHyIHsmCY0QFmmVaobqt9lyfJokXOIHLp5NYgtpgMbkvavIH5hoxqbd5GAnaeQS(Jy8HyI5fIHwIXFIXvlqQfiuz9hX4dXW6EU74FGF2926gaeg2dqQv)edseZEasT6Ny44ig)jgnblIgGKCQqHvMsmrigVrJy44igKrmAoLxdSeiUX0Mfvq(KFkBIXpIXpIHJJyC1cKAbcvw)rmriMyihgozA1pgMF2926gaeIvm6EbJkgw(KFkBm9yygOubujgMF4CbfmKdQ1aqOY6pIXhIjMxigAjg)jgxTaPwGqL1FeJpedR75UJ)H8zYPGCAz5Cg2dqQv)edseZEasT6Ny44ig)jgnblIgGKCQqHvMsmrigVrJy44igKrmAoLxdSeiUX0Mfvq(KFkBIXpIXpIHJJyC1cKAbcvw)rmriMyihgozA1pgoFMCkiNwwoNyfJEuyuXWYN8tzJPhdZaLkGkXW8dNlOGHCqTgacvw)rm(qmX8cXqlX4pX4Qfi1ceQS(Jy8HyyDp3D8p4kGWp7Eh2dqQv)edseZEasT6Ny44ig)jgnblIgGKCQqHvMsmrigVrJy44igKrmAoLxdSeiUX0Mfvq(KFkBIXpIXpIHJJyC1cKAbcvw)rmrigemgozA1pg2vaHF29gRy0romQyy5t(PSX0JHzGsfqLyy(HZfuWqoOwd7o(JHtMw9JHN1cKEweKXEHsEfRy09AmQyy5t(PSX0JHzGsfqLyy(HZfuWqoOwd7o(JHtMw9JH5ZfB7SkOy0CyfJUxfJkgw(KFkBm9yygOubujgMF4CbfmKdQ1WUJ)edTeJ)eJMGfrdqsovOWktjgFigVkAedhhXOjyr0aKKtfkSYuIjIhIXB0igooIrtWIObTOeR22vMA9gnIXhIbLOrm(HHtMw9JHbsUw)I1ntk5WkgDemgvmS8j)u2y6XWmqPcOsmS)edR75UJ)HefhucYZ66xTTZU2Xfqaiuz9hX4dX4nAedhhXGmIrqGoQ1vzhsuCqjipRRF12o7AhxaedhhX4Qfi1ceQS(JyIqmSUN7o(hsuCqjipRRF12o7AhxaH9aKA1pXGeXGsVqm0smAcwenaj5uHcRmLy8Hy8gnIXpIHwIXFIH19C3X)GcgYb1Aaiuz9NDzi3rmrigusmCCeJ)eJCN8mjeDDv)22zxfGtyA1FGQ(gqm0smUAbsTaHkR)igFiMKPv)ww3ZDh)jgKig(HZfI3G5oAPElqU(ZNjH9aKA1pX4hX4hXWXrmUAbsTaHkR)iMieJ3OHHtMw9JHJ3G5oAPElqU(ZNjyfJEm0WOIHLp5NYgtpgMbkvavIH9NyyPnzAfTqmCCeJRwGulqOY6pIXhIjzA1VL19C3XFIbjIbLOrm(rm0sm(tm8dNlOGHCqTggRedhhXW6EU74Fqbd5GAnaeQS(JyIqmXqoIXpIHJJyC1cKAbcvw)rmrigugddNmT6hdVmsWUY32oBIcb0kewXOhlggvmS8j)u2y6XWmqPcOsmmR75UJ)bfmKdQ1aqOY6pIjcX41y4KPv)yyqTUofB92BnzcwXOhZBmQyy5t(PSX0JHzGsfqLyyKrm8dNlOGHCqTggRy4KPv)yykHQbi02o7CWQTDdKK6Wkg9yOeJkgw(KFkBm9yygOubujgMF4CbfmKdQ1aqsMsm0sm8dNlWp7EphNgasYuIHJJy4hoxqbd5GAnaeQS(Jy8HyI5fIHwIrtWIObijNkuyLPeteIXB0igooIXFIXFIH1)nOs(PewBT632o745b1EkBRBaqiXWXrmS(VbvYpLW45b1EkBRBaqiX4hXqlX4Qfi1ceQS(JyIqmixmIHJJyC1cKAbcvw)rmrigVroIXpmCY0QFm8ARv)yfJEmVGrfdlFYpLnMEmmduQaQedZpCUGcgYb1Ay3XFIHwIH19C3X)aixRT1vajaeQS(Jy44igxTaPwGqL1FeteIjwuy4KPv)yyfmKdQvSIvm8PyuXOhdJkgozA1pgMMAoThuRyy5t(PSX0Jvm6EJrfdNmT6hdliV1zFv0I9GAfdlFYpLnMESIrhLyuXWYN8tzJPhdZaLkGkXWjtROfR8cvjhX4dXeddNmT6hdZNaqUiyfJUxWOIHtMw9JHtl1aSfGTDwgOJFyy5t(PSX0Jvm6rHrfdNmT6hdhDpNccXWYN8tzJPhRy0romQyy5t(PSX0JHzGsfqLyyG4aYbL8tHyOLyqgXKmT6pCcyvE1EA9lH6TUzTaPy4KPv)y4taRYR2tRFbRy09AmQyy5t(PSX0JHzGsfqLyy(HZfuWqoOwd7o(tmCCeJRzJJyIqmOmkIHJJyCnBCeteIb5qJyOLyqgXO5uEnmffkN2dQ1liFYpLnXWXrm8dNluVvHelacHkevaiuz9hXeHyeKNWgQy1IsWWjtR(XWGCT2wxbeSIr3RIrfdlFYpLnMEmmduQaQedZpCUGcgYb1AySsm0sm(tm8dNlmEbaQFXgDDv)HttgneJpeJxigooIbzetIcbuQegVaa1VyJUUQ)G8j)u2eJFedhhX4Qfi1ceQS(JyIqmXIHHtMw9JH5NDVTTZQqIvEHcHyfJocgJkgw(KFkBm9yygOubujggzed)W5ckyihuRHXkXWXrmUAbsTaHkR)iMietuy4KPv)yyxZgNSTjkeqPILxskSIrpgAyuXWYN8tzJPhdZaLkGkXW8dNlOGHCqTggRedhhX4pXWpCUWUh8tXQ5Ay3XFIHJJyyPnzAfTqm(rm0sm8dNlScewDI9GA9c7o(tmCCeJBmNwGWGsWIy1IsiMiedlp1QfLqm0smSUN7o(huWqoOwdaHkR)WWjtR(XWzrjB7b1kwXOhlggvmS8j)u2y6XWmqPcOsmmYig(HZfuWqoOwdJvIHJJyC1cKAbcvw)rmrigVkgozA1pgEDakhcRFXYpZtXkg9yEJrfdlFYpLnMEmmduQaQed7A24igKigxZgxailYtmEfiMf2MyIqmUMnUavI8igAjg(HZfuWqoOwd7o(tm0sm(tmiJy2Tgy9ZKxbPkBRBMuILFa(aqOY6pIHwIbzetY0Q)aRFM8kivzBDZKsc1BDZAbsjg)igooIXnMtlqyqjyrSArjeteIzHTjgooIXvlqQfiuz9hXeHyIcdNmT6hdZ6NjVcsv2w3mPeSIrpgkXOIHLp5NYgtpgMbkvavIH5hoxaimAMYDwxdysySsmCCed)W5caHrZuUZ6AatSSE8QacNMmAiMietm0igooIXvlqQfiuz9hXeHyIcdNmT6hdRqID88943wxdycwXOhZlyuXWYN8tzJPhdZaLkGkXW8dNlOGHCqTg2D8NyOLy8Ny4hoxyfiS6e7b16fgRedTeJ)eJRzJJy8HyIkkIXpIHJJyCnBCeJpeJxhfXWXrmUAbsTaHkR)iMietueJFy4KPv)y4eWYxShuRyfJESOWOIHLp5NYgtpgMbkvavIH5hoxqbd5GAnS74pXqlX4pXWpCUWkqy1j2dQ1lmwjgAjg)jgxZghX4dXevueJFedhhX4A24igFigVokIHJJyC1cKAbcvw)rmriMOig)WWjtR(XWmOIkfqApOwXkg9yihgvmCY0QFm8PsUrO9GAfdlFYpLnMESIvSIHJwax1pgDVrZB0IHwmVdiymC8e81VCyyeuqaebn0raJocQiqigIbviHykQ1gOeJRbedcmBFiWedqqGokGSjMRPeIjhAtLQSjggu(lYfiiIaQEHyqWiqigVs9hTauztmiWkOEAen4voW6EU74pcmXOnXGaZ6EU74FWRmcmX4V3ip)ceejiIaMATbQSjMOiMKPv)eZSo9ceeXW3QWWO7DuEbdVcAxnfmmYNyqaMaAoQ8pOALy8koEvaeer(edcamT5faXedL(smEJM3OrqKGiYNyqajrltIjIhIjk0ceejiI8jge0bclpLyuO6iM8igjbtesm5rmR9Df)uigTjM1wLxRCoriXSK1tm53kKaigwEkXShG6xigfsigxTaPbcIjtR(VWkqynfFQi5HUDp4NIvZvFxbclp1QfL4jgAeetMw9FHvGWAk(urYdDJtSLku((jL4jrXbLG8SU(vB7SRDCbqqmzA1)fwbcRP4tfjp0fVbZD0s9wGC9NptiiMmT6)cRaH1u8PIKh6wgjyx5BBNnrHaAfIGyY0Q)lScewtXNksEOJsOAacTTZohSAB3ajPocIjtR(VWkqynfFQi5HofmKdQvFxbclp1QfL4jwikFlNNKPv0IvEHQKZhVjiMmT6)cRaH1u8PIKh6YIs22dQvFlNNKPv0IvEHQKlckjisqmzA1)HKh6y94vbypOwjiMmT6)qYdDJtSLku((jL4zoa0iGZw)v7QhNDPCQVLZdR75UJ)bfmKdQ1aqOY6p7YqUlsSO44C1cKAbcvw)fbLOrqmzA1)HKh6gNylvO89tkXtIIdkb5zD9R22zx74cW3Y5XFxTaPwGqL1F(W6EU74psO0lCCAcwenaj5uHcRmnI3OXXPjyr0GwuIvB7ktTEJwKyr5hTSUN7o(huWqoOwdaHkR)Sld5UiXIIJZvlqQfiuz9xeugfbXKPv)hsEOBCITuHY3pPepZXPGEC2LEUL3Uohu5I4B58W6EU74Fqbd5GAnaeQS(ZUmK7IefhNRwGulqOY6ViEJgbXKPv)hsEOBCITuHY3pPepl5uy5CkGZY397B58WpCUGcgYb1Aaiuz9NpX8chhY0CkVgy5Cw)IvHe7b16fKp5NYMJZvlqQfiuz9xKyOrqmzA1)HKh6gNylvO89tkXtEqrNVCwqIIgyzniN(wop8dNlOGHCqTgacvw)5tmVqR)8dNlSmsWUY32oBIcb0kuySYXHm5o5zsG1)w(t22z5exdysGkrqAaTS0MmTIw8JJBl8dNlasu0alRb50Uf(HZf2D8NJZvlqQfiuz9xeVrJGyY0Q)djp0noXwQq57NuIN1MrJOxHczBzn16qtT63ULOlM4B58Gm(HZfuWqoOwdJvArMCN8mjWp7EBBNvHeR8cfcdujcsd442c)W5c8ZU322zviXkVqHWWyLJZvlqQfiuz9xKOiiI8jgubiKy0MyM1leZyLysMwrNQSjgfupnIEet8sHigubd5GALGyY0Q)djp0noXwQqD(wop8dNlOGHCqTgacvw)5tmVWXHmnNYRbwoN1VyviXEqTEb5t(PS54C1cKAbcvw)fXB0iiMmT6)qYdDSCoTjtR(TZ6uF)Ks8W2hbXKPv)hsEOJLZPnzA1VDwN67NuINt9TCEsMwrlw5fQsUiOKGyY0Q)djp0XY50MmT63oRt99tkXJckgnhuRNVLZtY0kAXkVqvY5J3eejiMmT6)cS95z3d(Py1C13Y5H19C3X)aixRT1vajaeQS(lYcBZXX6EU74FaKR126kGeacvw)fH19C3X)qwuY2EqTgacvw)XX5Qfi1ceQS(lI3OrqmzA1)fy7djp0XlGta0u)IVLZd)W5ckyihuRbGqL1F(eZl06VRwGulqOY6pFyDp3D8pWlGta0u)sypaPw9J0EasT6NJZFnblIgGKCQqHvMgXB044qMMt51albIBmTzrfKp5NY2p)44C1cKAbcvw)fjgkjiMmT6)cS9HKh64NDVTUbaH(wop8dNlOGHCqTgacvw)5tmVqR)UAbsTaHkR)8H19C3X)a)S7T1naimShGuR(rApaPw9ZX5VMGfrdqsovOWktJ4nACCitZP8AGLaXnM2SOcYN8tz7NFCCUAbsTaHkR)Ied5iiMmT6)cS9HKh6YNjNcYPLLZPVLZd)W5ckyihuRbGqL1F(eZl06VRwGulqOY6pFyDp3D8pKptofKtllNZWEasT6hP9aKA1phN)Acwenaj5uHcRmnI3OXXHmnNYRbwce3yAZIkiFYpLTF(XX5Qfi1ceQS(lsmKJGyY0Q)lW2hsEOZvaHF2923Y5HF4CbfmKdQ1aqOY6pFI5fA93vlqQfiuz9NpSUN7o(hCfq4NDVd7bi1QFK2dqQv)CC(Rjyr0aKKtfkSY0iEJghhY0CkVgyjqCJPnlQG8j)u2(5hhNRwGulqOY6ViiycIjtR(VaBFi5HUzTaPNfbzSxOKx9TCE4hoxqbd5GAnS74pbXKPv)xGTpK8qhFUyBNvbfJMZ3Y5HF4CbfmKdQ1WUJ)eetMw9Fb2(qYdDajxRFX6MjLC(wop8dNlOGHCqTg2D8Nw)1eSiAasYPcfwzQpEv0440eSiAasYPcfwzAepEJghNMGfrdArjwTTRm16nA(Gs08JGyY0Q)lW2hsEOlEdM7OL6Ta56pFM4B584VcQNgrdjkoOeKN11VABNDTJlGaR75UJ)bGqL1F(4nACCitqGoQ1vzhsuCqjipRRF12o7AhxaCCUAbsTaHkR)IOG6Pr0qIIdkb5zD9R22zx74ciW6EU74FypaPw9Jek9cTAcwenaj5uHcRm1hVrZpA9N19C3X)GcgYb1Aaiuz9NDzi3fbLCC(l3jptcrxx1VTD2vb4eMw9hOQVb06Qfi1ceQS(Zhw3ZDh)rIF4CH4nyUJwQ3cKR)8zsypaPw97NFCCUAbsTaHkR)I4nAeetMw9Fb2(qYdDlJeSR8TTZMOqaTc5B584plTjtROfooxTaPwGqL1F(W6EU74psOen)O1F(HZfuWqoOwdJvoow3ZDh)dkyihuRbGqL1FrIHC(XX5Qfi1ceQS(lckJrqmzA1)fy7djp0bQ11PyR3ERjt8TCEyDp3D8pOGHCqTgacvw)fXRjiMmT6)cS9HKh6OeQgGqB7SZbR22nqsQZ3Y5bz8dNlOGHCqTggReetMw9Fb2(qYdDRTw97B58WpCUGcgYb1AaijtPLF4Cb(z37540aqsMYXXpCUGcgYb1Aaiuz9NpX8cTAcwenaj5uHcRmnI3OXX5V)S(VbvYpLWARv)22zhppO2tzBDdac54y9FdQKFkHXZdQ9u2w3aGq)O1vlqQfiuz9xeKlghNRwGulqOY6ViEJC(rqmzA1)fy7djp0PGHCqT6B58WpCUGcgYb1Ay3XFAzDp3D8paY1ABDfqcaHkR)44C1cKAbcvw)fjwueejiMmT6)cN6HMAoThuReetMw9FHtrYdDcYBD2xfTypOwjiMmT6)cNIKh64taixeFlNNKPv0IvEHQKZNyeetMw9FHtrYdDPLAa2cW2old0XpcIjtR(VWPi5HUO75uqibXKPv)x4uK8q3jGv5v7P1V4B58aehqoOKFk0ISKPv)HtaRYR2tRFjuV1nRfiLGyY0Q)lCksEOdKR126kG4B58WpCUGcgYb1Ay3XFooxZgxeugfhNRzJlcYHgTitZP8AykkuoThuRxq(KFkBoo(HZfQ3QqIfaHqfIkaeQS(lIG8e2qfRwucbXKPv)x4uK8qh)S7TTDwfsSYlui03Y5HF4CbfmKdQ1WyLw)5hoxy8cau)In66Q(dNMmA8XlCCilrHakvcJxaG6xSrxx1Fq(KFkB)44C1cKAbcvw)fjwmcIjtR(VWPi5HoxZgNSTjkeqPILxskFlNhKXpCUGcgYb1AySYX5Qfi1ceQS(lsueetMw9FHtrYdDzrjB7b1QVLZd)W5ckyihuRHXkhN)8dNlS7b)uSAUg2D8NJJL2KPv0IF0YpCUWkqy1j2dQ1lS74phNBmNwGWGsWIy1IsIWYtTArj0Y6EU74Fqbd5GAnaeQS(JGyY0Q)lCksEOBDakhcRFXYpZt9TCEqg)W5ckyihuRHXkhNRwGulqOY6ViEvcIjtR(VWPi5How)m5vqQY26MjL4B584A24qY1SXfaYI8Efwy7iUMnUavI8OLF4CbfmKdQ1WUJ)06pY2Tgy9ZKxbPkBRBMuILFa(aqOY6pArwY0Q)aRFM8kivzBDZKsc1BDZAbs9JJZnMtlqyqjyrSArjrwyBooxTaPwGqL1FrIIGyY0Q)lCksEOtHe7457XVTUgWeFlNh(HZfacJMPCN11aMegRCC8dNlaegnt5oRRbmXY6XRciCAYOjsm044C1cKAbcvw)fjkcIjtR(VWPi5HUeWYxShuR(wop8dNlOGHCqTg2D8Nw)5hoxyfiS6e7b16fgR06VRzJZNOIYpooxZgNpEDuCCUAbsTaHkR)IeLFeetMw9FHtrYdDmOIkfqApOw9TCE4hoxqbd5GAnS74pT(ZpCUWkqy1j2dQ1lmwP1FxZgNprfLFCCUMnoF86O44C1cKAbcvw)fjk)iiMmT6)cNIKh6ovYncThuReejiMmT6)ckOy0CqTEEOPMt7b1kbXKPv)xqbfJMdQ1djp0fDpNccjiMmT6)ckOy0CqTEi5Ho(eaYfHGyY0Q)lOGIrZb16HKh6eK36SVkAXEqTsqmzA1)fuqXO5GA9qYdDzrjB7b1QVLZd)W5ckOy0ypOwVWyLwwAtMwrl0YpCUWUh8tXQ5AySsqmzA1)fuqXO5GA9qYdDGCT2wxbeFlNh(HZfuqXOXEqTEHXkT(NOqaLkbxZgNSTUcib5t(PS54suiGsLq9wfsSaieQqubq(04tmoUefcOujCdWs9l2dQ1liFYpLnhNMt51WPajPM1lb5t(PS9JGyY0Q)lOGIrZb16HKh6YIs22dQvFlNh(HZfuqXOXEqTEHXkT(ZpCUWkqy1j2dQ1lS74phhR75UJ)HSOKT9GAn4gZPfimOeSiwTOKijtR(dzrjB7b1AGLNA1Is444hoxqbd5GAnmw9JGyY0Q)lOGIrZb16HKh6a5ATTUci(wop8dNlOGIrJ9GA9cJvcIjtR(VGckgnhuRhsEOJAm16GA13Y5HF4CbfumAShuRxy3XFoo(HZfwbcRoXEqTEHXkTiJF4CbfmKdQ1WyLJZ1SX5JxJgbXKPv)xqbfJMdQ1djp05A24KTnrHakvS8ssrqmzA1)fuqXO5GA9qYdDRdq5qy9lw(zEkbXKPv)xqbfJMdQ1djp0X6NjVcsv2w3mPecIjtR(VGckgnhuRhsEOJF2922oRcjw5fkesqmzA1)fuqXO5GA9qYdDkKyhpFp(T11aM4B58WpCUaqy0mL7SUgWKWyLJJF4CbGWOzk3zDnGjwwpEvaHttgnrIHgbXKPv)xqbfJMdQ1djp0LwQbylaB7Smqh)iiMmT6)ckOy0CqTEi5HUtaRYR2tRFX3Y5bioGCqj)uOfzjtR(dNawLxTNw)sOERBwlqkbXKPv)xqbfJMdQ1djp0DQKBeApOwXkwXy]] )
    end

end