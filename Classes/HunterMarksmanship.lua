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
        spec:RegisterPack( "Marksmanship", 20201015.9, [[dCui9aqiGQEevsXMiP8jQKQgLOKtjk1RefZIuXTivb1UO4xqLggjvhtuzzKk9mOQAAuj5AKQ02ivrFdQkACKQqNdQkSoQKknpG4EKK9rQQdsQcOfcv5HujL0hbQq1iPskXjPsk1kbsZeOc5MujvStOIFsQc0sbQq5PaMkq5RKQamwsvq2lK)svdMshwyXKYJrmzfUmQnlYNvrJgkNwQvdubVMkXSv0TjXUb9BjdxfooqfTCv9CLMoX1vPTlQY3PsnEOQ05fv16bQ08PI9J0OCiWqaJqyeo6QUUQNt9C43Oo(iNUiaj)dgbCeexItgbadfgb46eVlRsaxS(abCe5pRyGadbS19jmcW1qTyICSUU4I7zlyxndPuWDBL7mKUGKpscUBRqWfbOD7P4AdrAiGrimchDvxx1ZPEo8BuhFKlNEXNiG4ky1JaaAfxRiaSEmyisdbm4LGaCnuRRLlu4NADDI3LvjGlwFqb11qT6bjsPXp1Md)6qT6QUUQtbLcQRHAbhX5XtQvFQvVQBqaZELfbgcq(M4YIvYIadHtoeyiaggAtEGWdbq(w4VdeaPQ5OCdnrRWd)IvI5EqTooulPQ5OCdnFC0dFQF28Ss0WLA1NAjvnhLBOjAfE4xSsmpRenCrabr6cIag1vBYEjoqcchDrGHayyOn5bcpea5BH)oqa)fYP6pzZw3zQ(t2ZkA8VggCE7JdEqTQrTs8E5JdZZkrdxQfeQ9KmOw1OwsvZr5gAsZ4zZZkrdxQfeQ9Kmqabr6cIaK49YhhibHd(rGHayyOn5bcpea5BH)oqa)fYP6pzZw3zQ(t2ZkA8VgggAtEqTQrTs8E5JdZ9abeePlicinJNrcchxHadbeePlicWDph(9O)wweaddTjpq4Heeo6fbgciisxqeqE1CY5JayyOn5bcpKGWrprGHacI0feb88wWqA4Pp(VCJayyOn5bcpKGWbFIadbeePlicql(pozeaddTjpq4Heeo6reyiGGiDbram(EmRTZJ9lwjiaggAtEGWdjiCWhiWqamm0M8aHhcG8TWFhiasvZr5gA(4Oh(u)S5zLOHl164qTPICxQnd1gePlO5JJE4t9ZgsSI)5tgsT6tTPICxJsGVuRJd1M6tmX)Ss0WLAbHAZPxeqqKUGia5V8Ivcsq4KtDeyiaggAtEGWdbq(w4VdeG2nLmY3ex8lwjR5EqTQrTzrTA3uYC8mPx2VyLSMr5gsToouB6oN(NjyXFYEPvyQfeQLeR4LwHP2mu7jzqToouR2nLmYF5fReZ9GAZgbeePliciAfE4xSsqccNC5qGHayyOn5bcpea5BH)oqaPICxQnd1sIv8pFYqQfeQnvK7Auc8fbeePlicyWHG5jyHlFOGeeo50fbgcGHH2Khi8qaKVf(7abODtjJ8nXf)IvYAUhuRAuR2nLmJ6QnzVehMr5gIacI0feb8Xrp8P(zKGWjh(rGHayyOn5bcpea5BH)oqaA3uYiFtCXVyLSMr5gsToouR2nLmhpt6L9lwjR5EqToouBQi3LA1dtTKAfQnd1sIv8pFYqQvFQnisxqt0k8WVyLyi1kiGGiDbrak3P0lwjibHtoxHadbWWqBYdeEiaY3c)DGa0UPKzWXWZ5ZMr5gIacI0feb4spN(fReKGWjNErGHacI0febeEL7p43xjp5l3lcGHH2Khi8qccNC6jcmeqqKUGiG0mYNh(fReeaddTjpq4Heeo5WNiWqamm0M8aHhciisxqeWY)bdf)kn8ebq(w4VdeWZPNxSqBYias(Kj7L4pzzr4KdjiCYPhrGHacI0febSchJ89lwjiaggAtEGWdjibbm4uCNccmeo5qGHacI0febqQlu43VyLGayyOn5bcpKGWrxeyiaggAtEGWdbeePlicyEFx4F9nC7rx31F2jbbq(w4VdeaPQ5OCdnYF5fReZZkrdx)5L3LAbHAZPxQ1XHAt9jM4FwjA4sTGqT4xDeamuyeW8(UW)6B42JUUR)Stcsq4GFeyiaggAtEGWdbeePlicia3fl(y9Pck(k5pk38JaiFl83bcilQn1NyI)zLOHl1Qp1gePlONu1CuUHuBgQf)UIADCOwj(twmyCmfmZbrOwqOwDvNADCOwj(twmsRWEP8heXRR6uliuBo9sTztTQrTKQMJYn0i)LxSsmpRenC9NxExQfeQnNEPwhhQn1NyI)zLOHl1cc1IF9IaGHcJacWDXIpwFQGIVs(JYn)ibHJRqGHayyOn5bcpeqqKUGiG5DLVUR)SMdg6pMxL4KraKVf(7abqQAok3qJ8xEXkX8Ss0W1FE5DPwqOw9sToouBQpXe)ZkrdxQfeQvx1raWqHraZ7kFDx)znhm0FmVkXjJeeo6fbgcGHH2Khi8qabr6cIaoJjtI5K)1Rvfebq(w4VdeG2nLmYF5fReZZkrdxQvFQnNROwhhQf8uRetgkgsmNn80lySFXkznmm0M8GADCO2uFIj(NvIgUuliuBo1raWqHraNXKjXCY)61QcIeeo6jcmeaddTjpq4HacI0febelwEbKx)hGB9Es9Xebq(w4VdeG2nLmYF5fReZZkrdxQvFQnNROw1O2SOwTBkzoVXp6a6RKpax(lbZCpOwhhQf8ulVldjSHuWbdxE4NDIt1tyJsaoup1Qg1scFqKopMAZMADCO2bRDtjZhGB9Es9X0pyTBkzgLBi164qTP(et8pRenCPwqOwDvhbadfgbelwEbKx)hGB9Es9XejiCWNiWqamm0M8aHhciisxqeWrrCHLTbxE4jLYXvcPlOFW51egbq(w4Vdea4PwTBkzK)YlwjM7b1Qg1cEQL3LHe2OnRA4RKxWypdzL8nkb4q9uRJd1oyTBkz0Mvn8vYlySNHSs(M7b164qTP(et8pRenCPwqOw9IaGHcJaokIlSSn4YdpPuoUsiDb9doVMWibHJEebgcGHH2Khi8qaKVf(7abODtjJ8xEXkX8Ss0WLA1NAZ5kQ1XHAbp1kXKHIHeZzdp9cg7xSswdddTjpOwhhQn1NyI)zLOHl1cc1QR6iGGiDbra3L9TWklsq4GpqGHayyOn5bcpeqqKUGiasmN(GiDb9ZEfeWSxXddfgbqglsq4KtDeyiaggAtEGWdbq(w4VdeqqKop2ZqwP5LAbHAXpciisxqeajMtFqKUG(zVccy2R4HHcJawbjiCYLdbgcGHH2Khi8qaKVf(7abeePZJ9mKvAEPw9PwDrabr6cIaiXC6dI0f0p7vqaZEfpmuyeG8nXLfRKfjibbC8mPu0cbbgcNCiWqamm0M8aHhcG8TWFhiG)c5u9NSzR7mv)j7zfn(xddoV9Xbpqabr6cIaK49YhhibHJUiWqamm0M8aHhc44zsSIxAfgbKtDeqqKUGiGrD1MSxIdKGWb)iWqamm0M8aHhcG8TWFhiGGiDESNHSsZl1QIAZHacI0febeTcp8lwjibjiaYyrGHWjhcmeaddTjpq4HaiFl83bcGu1CuUHMpo6Hp1pBEwjA4sTGqTNKb164qTKQMJYn08Xrp8P(zZZkrdxQfeQLu1CuUHMOv4HFXkX8Ss0WLADCO2uFIj(NvIgUuliuRUQJacI0febmQR2K9sCGeeo6IadbWWqBYdeEiaY3c)DGa0UPKr(lVyLyEwjA4sT6tT5Cf1Qg1Mf1M6tmX)Ss0WLA1NAjvnhLBOrJ)LFxA4PzC)q6csTzO2X9dPli164qTzrTs8NSyW4ykyMdIqTGqT6Qo164qTGNALyYqXqINt3PpAfdddTjpO2SP2SPwhhQn1NyI)zLOHl1cc1Md)iGGiDbraA8V87sdprcch8JadbWWqBYdeEiaY3c)DGa0UPKr(lVyLyEwjA4sT6tT5Cf1Qg1Mf1M6tmX)Ss0WLA1NAjvnhLBOrBw1WNUF(MX9dPli1MHAh3pKUGuRJd1Mf1kXFYIbJJPGzoic1cc1QR6uRJd1cEQvIjdfdjEoDN(Ovmmm0M8GAZMAZMADCO2uFIj(NvIgUuliuBo9ebeePlicqBw1WNUF(ibHJRqGHayyOn5bcpea5BH)oqaA3uYi)LxSsmpRenCPw9P2CUIAvJAZIAt9jM4FwjA4sT6tTKQMJYn0eqcVYhtpjMtZ4(H0fKAZqTJ7hsxqQ1XHAZIAL4pzXGXXuWmheHAbHA1vDQ1XHAbp1kXKHIHepNUtF0kgggAtEqTztTztToouBQpXe)ZkrdxQfeQnNEIacI0febeqcVYhtpjMtKGWrViWqamm0M8aHhcG8TWFhiaTBkzK)YlwjMNvIgUuR(uBoxrTQrTzrTP(et8pRenCPw9PwsvZr5gAs9ZAZQgMX9dPli1MHAh3pKUGuRJd1Mf1kXFYIbJJPGzoic1cc1QR6uRJd1cEQvIjdfdjEoDN(Ovmmm0M8GAZMAZMADCO2uFIj(NvIgUuliul(abeePlici1pRnRAGeeo6jcmeaddTjpq4HaiFl83bcq7Msg5V8IvIzuUHiGGiDbraZ(etwp4WDCQWqbjiCWNiWqamm0M8aHhcG8TWFhiaTBkzK)YlwjMr5gIacI0febOfN(k5LVjUSibHJEebgcGHH2Khi8qaKVf(7abODtjJ8xEXkXmk3qQvnQnlQvI)KfdghtbZCqeQvFQvpQo164qTs8NSyW4ykyMdIqTGOIA1vDQ1XHAL4pzXiTc7LYFqeVUQtT6tT4xDQnBeqqKUGiGNJJgE6tZqHxKGWbFGadbWWqBYdeEiaY3c)DGaYIAjvnhLBOja3fl(y9Pck(k5pk38BEwjA4sT6tT6Qo164qTGNAzW5Tpo4Hja3fl(y9Pck(k5pk38tToouBQpXe)ZkrdxQfeQLu1CuUHMaCxS4J1NkO4RK)OCZVzC)q6csTzOw87kQvnQvI)KfdghtbZCqeQvFQvx1P2SPw1O2SOwsvZr5gAK)YlwjMNvIgU(ZlVl1cc1IFQ1XHAZIA5DziHn51BxqFL8h8NyI0f0O0W6Pw1O2uFIj(NvIgUuR(uBqKUGEsvZr5gsTzOwTBkzCx)CKh3q)ZBbdiHnJ7hsxqQnBQnBQ1XHAt9jM4FwjA4sTGqT6QociisxqeG76NJ84g6FElyajmsq4KtDeyiaggAtEGWdbq(w4Vdeqwulj8br68yQ1XHAt9jM4FwjA4sT6tTbr6c6jvnhLBi1MHAXV6uB2uRAuBwuR2nLmYF5fReZ9GADCOwsvZr5gAK)YlwjMNvIgUuliuBo9KAZMADCO2uFIj(NvIgUuliul(ZHacI0febCEJF0b0xjFaU8xcgsq4KlhcmeaddTjpq4HaiFl83bcGu1CuUHg5V8IvI5zLOHl1cc1Iprabr6cIa((4yY(g63JGWibHtoDrGHayyOn5bcpea5BH)oqaGNA1UPKr(lVyLyUhiGGiDbrakSs957RKFEj9WpEouwKGWjh(rGHayyOn5bcpea5BH)oqaA3uYi)LxSsmpheHAvJA1UPKrBw1yExX8CqeQ1XHA1UPKr(lVyLyEwjA4sT6tT5Cf1Qg1kXFYIbJJPGzoic1cc1QR6uRJd1Mf1Mf1sk4EvcTjBokPlOVs(lu77XKh(09ZNADCOwsb3RsOnzZfQ99yYdF6(5tTztTQrTP(et8pRenCPwqOw9mh164qTP(et8pRenCPwqOwD1tQnBeqqKUGiGJs6cIeeo5CfcmeaddTjpq4HaiFl83bcq7Msg5V8IvIzuUHuRAulPQ5OCdnFC0dFQF28Ss0WLADCO2uFIj(NvIgUuliuBo9IacI0febi)LxSsqcsqaRGadHtoeyiaggAtEGWdbq(w4VdeGetgkMv4yKVpvK7AyyOn5b1Qg1E8CE(tYWKZSchJ89lwjuRAuR2nLmRWXiFFQi318Ss0WLAbHA1lciisxqeWkCmY3VyLGeeo6IadbeePlicWLEo9lwjiaggAtEGWdjiCWpcmeqqKUGiGrD1MSxIdeaddTjpq4HeeoUcbgcGHH2Khi8qaKVf(7ab8xiNQ)KnBDNP6pzpROX)AyW5Tpo4b1Qg1kX7LpompRenCPwqO2tYGAvJAjvnhLBOjnJNnpRenCPwqO2tYabeePlicqI3lFCGeeo6fbgcGHH2Khi8qaKVf(7ab8xiNQ)KnBDNP6pzpROX)AyyOn5b1Qg1kX7Lpom3deqqKUGiG0mEgjiC0teyiGGiDbraU75WVh93YIayyOn5bcpKGWbFIadbeePlicinJ85HFXkbbWWqBYdeEibHJEebgcGHH2Khi8qaKVf(7abKkYDP2muljwX)8jdPwqO2urURrjWxeqqKUGiGbhcMNGfU8Hcsq4GpqGHacI0febW47XS2op2VyLGayyOn5bcpKGWjN6iWqamm0M8aHhcG8TWFhiaTBkzoEM0l7xSswZOCdPwhhQf8uRetgkgcwRe8h(fRedddTjpqabr6cIaYRMtoFKGWjxoeyiGGiDbraHx5(d(9vYt(Y9IayyOn5bcpKGWjNUiWqamm0M8aHhcG8TWFhiaTBkzoEM0l7xSswZOCdPwhhQf8uRetgkgcwRe8h(fRedddTjpqabr6cIaEElyin80h)xUrccNC4hbgcGHH2Khi8qaKVf(7abODtjZXZKEz)IvYAgLBi164qTGNALyYqXqWALG)WVyLyyyOn5bciisxqeG8xEXkbjiCY5keyiaggAtEGWdbq(w4VdeqwuB6oN(NjyXFYEPvyQfeQLeR4LwHP2mu7jzqToouR2nLmYF5fReZ9GAZMAvJAZIA1UPK54zsVSFXkznJYnKADCOwWtTsmzOyiyTsWF4xSsmmm0M8GADCOws4dI05XuB2uRJd1QDtjJ8nXf)IvYAEwjA4sT6tTm(YKRWEPvyQvnQnlQnisNh7ziR08sT6tT5OwhhQ9Vqov)jBw(pyOSsmDH)1lFtCH)8nm482hh8GAZgbeePliciAfE4xSsqccNC6fbgcGHH2Khi8qaKVf(7abODtjZOUAt2lXHzuUHuRAuBQi3LAZqTKyf)ZNmKAbHAtf5UgLaFrabr6cIa(4Oh(u)msq4KtprGHayyOn5bcpea5BH)oqaA3uYC8mPx2VyLSM7b1Qg1Mf1QDtjJ8xEXkXmk3qQ1XHAdI05XEgYknVuR(uBoQ1XHAbp1scFqKopMAZgbeePlicGG1kb)HFXkbjiCYHprGHayyOn5bcpeqqKUGiGL)dgk(vA4jcG8TWFhiGNtpVyH2KPw1Owj(twmsRWEP8JMPw9P2X9dPlicGKpzYEj(twweo5qccNC6reyiaggAtEGWdbq(w4VdeqqKop2ZqwP5LA1NAZHacI0febOf)hNmsq4KdFGadbWWqBYdeEiaY3c)DGa0UPK54zsVSFXkzn3dQvnQnlQv7Msg5V8IvIzuUHuRJd1cEQLe(GiDEm1Mnciisxqeq8KaY(fReKGWrx1rGHayyOn5bcpea5BH)oqaA3uYC8mPx2VyLSMr5gIacI0febeTcp8lwjibHJU5qGHayyOn5bcpea5BH)oqaPICxQvFQLuRqTzO2GiDbnrRWd)IvIHuRqTQrTzrTA3uYi)LxSsmJYnKADCOwWtTKWhePZJP2Srabr6cIaiyTsWF4xSsqcchD1fbgcGHH2Khi8qaKVf(7abKkYDPw9PwsTc1MHAdI0f0eTcp8lwjgsTc1Qg1Mf1QDtjJ8xEXkXmk3qQ1XHAbp1scFqKopMAZgbeePliciEsaz)Ivcsq4Ol(rGHayyOn5bcpea5BH)oqaPICxQnd1sIv8pFYqQfeQnvK7Auc8fbeePlicyfog57xSsqcchDDfcmeqqKUGiacwRe8h(fReeaddTjpq4Heeo6QxeyiGGiDbraXtci7xSsqamm0M8aHhsqcsqa5X)2feHJUQRR65upNUg8bcWD8WgEUia9a0deCmCCTXbCCxxQLAbdJP2w5OEHAt1tTUEYyD9u7ZGZB)8GA3sHP24kLsi8GAjyb8KxdfuWrnKPw8HRl16ATG5XVWdQ11lFdDHfJEidPQ5OCdD9uRuuRRNu1CuUHg9qUEQnlDX3SnuqPG6ARCuVWdQvVuBqKUGu7Sxznuqra7btq4OREDfc44RupzeGRHADTCHc)uRRt8USkbCX6dkOUgQvpirkn(P2C4xhQvx11vDkOuqDnul4iopEsT6tT6vDdfukObr6cUMJNjLIwizuHReVx(4qNoP6Vqov)jB26ot1FYEwrJ)1WGZBFCWdkObr6cUMJNjLIwizuH7OUAt2lXHohptIv8sRWQYPof0GiDbxZXZKsrlKmQWnAfE4xSs0PtQcI05XEgYknVQYrbLcAqKUGBgv4sQlu43VyLqbnisxWnJkCVl7BHv0bgkSQ59DH)13WThDDx)zNeD6KksvZr5gAK)YlwjMNvIgU(ZlVli50RJtQpXe)ZkrdxqWV6uqdI0fCZOc37Y(wyfDGHcRka3fl(y9Pck(k5pk38RtNuLvQpXe)Zkrdx9jvnhLByg87khhj(twmyCmfmZbrarx1DCK4pzXiTc7LYFqeVUQdso9MTAKQMJYn0i)LxSsmpRenC9NxExqYPxhNuFIj(NvIgUGGF9sbnisxWnJkCVl7BHv0bgkSQ5DLVUR)SMdg6pMxL4K1PtQivnhLBOr(lVyLyEwjA46pV8UGOxhNuFIj(NvIgUGOR6uqdI0fCZOc37Y(wyfDGHcR6mMmjMt(xVwvqD6KkTBkzK)YlwjMNvIgU6NZvooGxIjdfdjMZgE6fm2VyLSgggAtE44K6tmX)Ss0WfKCQtbnisxWnJkCVl7BHv0bgkSQyXYlG86)aCR3tQpM60jvA3uYi)LxSsmpRenC1pNRullTBkzoVXp6a6RKpax(lbZCpCCapVldjSHuWbdxE4NDIt1tyJsaouVAKWhePZJZ2XzWA3uY8b4wVNuFm9dw7MsMr5g64K6tmX)Ss0WfeDvNcAqKUGBgv4Ex23cROdmuyvhfXfw2gC5HNukhxjKUG(bNxtyD6KkWRDtjJ8xEXkXCpud88UmKWgTzvdFL8cg7ziRKVrjahQ3XzWA3uYOnRA4RKxWypdzL8n3dhNuFIj(NvIgUGOxkOUgQfSpFQvkQD2qMAVhuBqKoVq4b1kFdDHLLAD3cg1c2F5fRekObr6cUzuH7DzFlSYQtNuPDtjJ8xEXkX8Ss0Wv)CUYXb8smzOyiXC2WtVGX(fRK1WWqBYdhNuFIj(NvIgUGOR6uqdI0fCZOcxsmN(GiDb9ZEfDGHcRImwkObr6cUzuHljMtFqKUG(zVIoWqHvTIoDsvqKop2ZqwP5fe8tbnisxWnJkCjXC6dI0f0p7v0bgkSk5BIllwjRoDsvqKop2ZqwP5vFDPGsbnisxW1qgBgv4oQR2K9sCOtNurQAok3qZhh9WN6NnpRenCb5KmCCivnhLBO5JJE4t9ZMNvIgUGqQAok3qt0k8WVyLyEwjA464K6tmX)Ss0WfeDvNcAqKUGRHm2mQWvJ)LFxA4PoDsL2nLmYF5fReZZkrdx9Z5k1Yk1NyI)zLOHR(KQMJYn0OX)YVln80mUFiDbZmUFiDbDCYsI)KfdghtbZCqeq0vDhhWlXKHIHepNUtF0kgggAtEKD2ooP(et8pRenCbjh(PGgePl4AiJnJkC1Mvn8P7NVoDsL2nLmYF5fReZZkrdx9Z5k1Yk1NyI)zLOHR(KQMJYn0OnRA4t3pFZ4(H0fmZ4(H0f0Xjlj(twmyCmfmZbrarx1DCaVetgkgs8C6o9rRyyyOn5r2z74K6tmX)Ss0WfKC6jf0GiDbxdzSzuHBaj8kFm9Kyo1PtQ0UPKr(lVyLyEwjA4QFoxPwwP(et8pRenC1Nu1CuUHMas4v(y6jXCAg3pKUGzg3pKUGoozjXFYIbJJPGzoici6QUJd4LyYqXqINt3PpAfdddTjpYoBhNuFIj(NvIgUGKtpPGgePl4AiJnJkCt9ZAZQg60jvA3uYi)LxSsmpRenC1pNRulRuFIj(NvIgU6tQAok3qtQFwBw1WmUFiDbZmUFiDbDCYsI)KfdghtbZCqeq0vDhhWlXKHIHepNUtF0kgggAtEKD2ooP(et8pRenCbbFqbnisxW1qgBgv4o7tmz9Gd3XPcdfD6KkTBkzK)YlwjMr5gsbnisxW1qgBgv4QfN(k5LVjUS60jvA3uYi)LxSsmJYnKcAqKUGRHm2mQW954OHN(0mu4vNoPs7Msg5V8IvIzuUHQLLe)jlgmoMcM5Gi6Rhv3XrI)KfdghtbZCqequPR6oos8NSyKwH9s5piIxx11h)QNnf0GiDbxdzSzuHR76NJ84g6FElyajSoDsvwY3qxyXeG7IfFS(ubfFL8hLB(nKQMJYn08Ss0WvFDv3Xb8m482hh8WeG7IfFS(ubfFL8hLB(DCs9jM4FwjA4cI8n0fwmb4UyXhRpvqXxj)r5MFdPQ5OCdnJ7hsxWm43vQjXFYIbJJPGzoiI(6QE2QLfPQ5OCdnYF5fReZZkrdx)5L3fe874KfVldjSjVE7c6RK)G)etKUGgLgwVAP(et8pRenC1Nu1CuUHz0UPKXD9ZrECd9pVfmGe2mUFiDbZoBhNuFIj(NvIgUGOR6uqdI0fCnKXMrfUN34hDa9vYhGl)LGPtNuLfj8br68yhNuFIj(NvIgU6tQAok3Wm4x9SvllTBkzK)YlwjM7HJdPQ5OCdnYF5fReZZkrdxqYPNz74K6tmX)Ss0Wfe8NJcAqKUGRHm2mQW97JJj7BOFpccRtNurQAok3qJ8xEXkX8Ss0Wfe8jf0GiDbxdzSzuHRcRuF((k5Nxsp8JNdLvNoPc8A3uYi)LxSsm3dkObr6cUgYyZOc3Js6cQtNuPDtjJ8xEXkX8Cqe10UPKrBw1yExX8CqehhTBkzK)YlwjMNvIgU6NZvQjXFYIbJJPGzoici6QUJtwzrk4EvcTjBokPlOVs(lu77XKh(09Z3XHuW9QeAt2CHAFpM8WNUF(zRwQpXe)Zkrdxq0ZCooP(et8pRenCbrx9mBkObr6cUgYyZOcx5V8IvIoDsL2nLmYF5fReZOCdvJu1CuUHMpo6Hp1pBEwjA464K6tmX)Ss0WfKC6Lckf0GiDbxJ8nXLfRKnJkCh1vBYEjo0PtQivnhLBOjAfE4xSsm3dhhsvZr5gA(4Oh(u)S5zLOHR(KQMJYn0eTcp8lwjMNvIgUuqdI0fCnY3exwSs2mQWvI3lFCOtNu9xiNQ)KnBDNP6pzpROX)AyW5Tpo4HAs8E5JdZZkrdxqojd1ivnhLBOjnJNnpRenCb5KmOGgePl4AKVjUSyLSzuHBAgpRtNu9xiNQ)KnBDNP6pzpROX)AyyOn5HAs8E5JdZ9GcAqKUGRr(M4YIvYMrfUU75WVh93YsbnisxW1iFtCzXkzZOc38Q5KZNcAqKUGRr(M4YIvYMrfUpVfmKgE6J)l3uqdI0fCnY3exwSs2mQWvl(pozkObr6cUg5BIllwjBgv4Y47XS2op2VyLqbnisxW1iFtCzXkzZOcx5V8IvIoDsfPQ5OCdnFC0dFQF28Ss0W1XjvK7MjisxqZhh9WN6NnKyf)ZNmu)urURrjWxhNuFIj(NvIgUGKtVuqdI0fCnY3exwSs2mQWnAfE4xSs0PtQ0UPKr(M4IFXkzn3d1Ys7MsMJNj9Y(fRK1mk3qhN0Do9ptWI)K9sRWGqIv8sRWzojdhhTBkzK)YlwjM7r2uqdI0fCnY3exwSs2mQWDWHG5jyHlFOOtNuLkYDZqIv8pFYqqsf5UgLaFPGgePl4AKVjUSyLSzuH7hh9WN6N1PtQ0UPKr(M4IFXkzn3d10UPKzuxTj7L4Wmk3qkObr6cUg5BIllwjBgv4QCNsVyLOtNuPDtjJ8nXf)IvYAgLBOJJ2nLmhpt6L9lwjR5E44KkYD1dtQvYqIv8pFYq9dI0f0eTcp8lwjgsTcf0GiDbxJ8nXLfRKnJkCDPNt)IvIoDsL2nLmdogEoF2mk3qkObr6cUg5BIllwjBgv4gEL7p43xjp5l3lf0GiDbxJ8nXLfRKnJkCtZiFE4xSsOGgePl4AKVjUSyLSzuH7Y)bdf)kn8uhs(Kj7L4pzzvLtNoP650ZlwOnzkObr6cUg5BIllwjBgv4UchJ89lwjuqPGgePl4AwjJkCxHJr((fReD6KkjMmumRWXiFFQi31WWqBYd1oEop)jzyYzwHJr((fRe10UPKzfog57tf5UMNvIgUGOxkObr6cUMvYOcxx650VyLqbnisxW1Ssgv4oQR2K9sCqbnisxW1Ssgv4kX7Lpo0PtQ(lKt1FYMTUZu9NSNv04Fnm482hh8qnjEV8XH5zLOHliNKHAKQMJYn0KMXZMNvIgUGCsguqdI0fCnRKrfUPz8SoDs1FHCQ(t2S1DMQ)K9SIg)RHHH2KhQjX7Lpom3dkObr6cUMvYOcx39C43J(BzPGgePl4AwjJkCtZiFE4xSsOGgePl4AwjJkChCiyEcw4Yhk60jvPIC3mKyf)ZNmeKurURrjWxkObr6cUMvYOcxgFpM125X(fRekObr6cUMvYOc38Q5KZxNoPs7MsMJNj9Y(fRK1mk3qhhWlXKHIHG1kb)HFXkXWWqBYdkObr6cUMvYOc3WRC)b)(k5jF5EPGgePl4AwjJkCFElyin80h)xU1PtQ0UPK54zsVSFXkznJYn0Xb8smzOyiyTsWF4xSsmmm0M8GcAqKUGRzLmQWv(lVyLOtNuPDtjZXZKEz)IvYAgLBOJd4LyYqXqWALG)WVyLyyyOn5bf0GiDbxZkzuHB0k8WVyLOtNuLv6oN(NjyXFYEPvyqiXkEPv4mNKHJJ2nLmYF5fReZ9iB1Ys7MsMJNj9Y(fRK1mk3qhhWlXKHIHG1kb)HFXkXWWqBYdhhs4dI05Xz74ODtjJ8nXf)IvYAEwjA4QpJVm5kSxAfwTScI05XEgYknV6NZX5Vqov)jBw(pyOSsmDH)1lFtCH)8nm482hh8iBkObr6cUMvYOc3po6Hp1pRtNuPDtjZOUAt2lXHzuUHQLkYDZqIv8pFYqqsf5UgLaFPGgePl4AwjJkCjyTsWF4xSs0PtQ0UPK54zsVSFXkzn3d1Ys7Msg5V8IvIzuUHoobr68ypdzLMx9Z54aEs4dI05XztbnisxW1Ssgv4U8FWqXVsdp1HKpzYEj(twwv50PtQEo98IfAtwnj(twmsRWEP8JM1FC)q6csbnisxW1Ssgv4Qf)hNSoDsvqKop2ZqwP5v)CuqdI0fCnRKrfUXtci7xSs0PtQ0UPK54zsVSFXkzn3d1Ys7Msg5V8IvIzuUHooGNe(GiDEC2uqdI0fCnRKrfUrRWd)IvIoDsL2nLmhpt6L9lwjRzuUHuqdI0fCnRKrfUeSwj4p8lwj60jvPICx9j1kzcI0f0eTcp8lwjgsTIAzPDtjJ8xEXkXmk3qhhWtcFqKopoBkObr6cUMvYOc34jbK9lwj60jvPICx9j1kzcI0f0eTcp8lwjgsTIAzPDtjJ8xEXkXmk3qhhWtcFqKopoBkObr6cUMvYOc3v4yKVFXkrNoPkvK7MHeR4F(KHGKkYDnkb(sbnisxW1Ssgv4sWALG)WVyLqbnisxW1Ssgv4gpjGSFXkbjibHaa]] )
    else
        spec:RegisterPack( "Marksmanship", 20201015.1, [[dG0d8aqiikpcvqTjiPpjuLAucHtjeTkbsWRGiZsGAxu5xOsggKYXekltq6zcetdvORjOSnub(MaPgNajDoHQY6eQsmpH09eW(eehuOkOfIk1dfir(OqvvAKcKqNuOkQvcHMPqvKBkufANqQ(PqvGHkuvvTuHQQYtb1uHeFvOQkgRajQ9c1FP0GP4WIwmQ6XOmzLCzIntvFwPmAqoTKvluv51OIMTuDBKSBv9BfdxP64cvjTCGNRY0jDDPSDbvFhcgpQGCEHkRhIQ5Ju7hX4yyuWWRufm6HIwOOfdTyH5ql(4y8fJJyynUDbdVNmoZnbd)jLGHJhtaNhv(huTJH3Z46tUWOGHVPbycgMdtmqQUFXlCX1wPqnEhBO46kQwp1AEgi9kxxrX4cdZ3QUgp)yEm8kvbJEOOfkAXqlwyo0IpogFXccgoBk0aWWWfvqjmmuTwYJ5XWl5yyyomXepMaopQ8pOANyck2Evaee5Wet8aMo8cGyIfwWetOOfkAeejiYHjM4jjCPtmrdqmHHMdd3RtpmkyyfumopOrpmky0JHrbdNmTMhdZz172dAumS8jFxwyUXkg9qXOGHtMwZJHdF6DjomS8jFxwyUXkg9GGrbdNmTMhdZNaqUjyy5t(USWCJvm6CeJcgozAnpgw4q795QWf7bnkgw(KVllm3yfJEyyuWWYN8DzH5gdZaLkGkXW8nV3PGIXP9Gg9CTDIbvIHL2KPv4cXGkXW38E3AA8DXQ5URTJHtMwZJHZIsw2dAuSIrNdWOGHLp57YcZngMbkvavIH5BEVtbfJt7bn65A7edQeteetICbuQ48dRDYY6lG4Kp57YIyOPjMe5cOuXvVvHelakofIYbYNtIjeIjgXqttmjYfqPI7AGT63Sh0ONt(KVllIHMMy0SlV6ofijvVEXjFY3LfXejgozAnpggK71Y6lGGvm6bngfmS8jFxwyUXWmqPcOsmmFZ7DkOyCApOrpxBNyqLyIGy4BEVBhiS6e7bn65wdcpXqttmSz6RbH3LfLSSh0OoFR3TaHbLGnXQfLqmrjMKP18USOKL9Gg1XYtTArjednnXW38ENcAYbnQRTtmrIHtMwZJHZIsw2dAuSIrpOIrbdlFY3LfMBmmduQaQedZ38ENckgN2dA0Z12XWjtR5XWGCVwwFbeSIrp(WOGHLp57YcZngMbkvavIH5BEVtbfJt7bn65wdcpXqttm8nV3TdewDI9Gg9CTDIbvIbzedFZ7DkOjh0OU2oXqttm(H1oIjeIjOrddNmTMhdt16ADqJIvm6XqdJcgozAnpg2pS2jlBICbuQy5LKcdlFY3LfMBSIrpwmmky4KP18y49gO8Xv)MLVNNIHLp57YcZnwXOhlumky4KP18yy28m5vqQYY67jLGHLp57YcZnwXOhliyuWWYN8DzH5gdZaLkGkXW7ajC7gB5I5cF6DjoIHMMyqgXOzxE1f(07sCo5t(USigAAIrtWMOoTOeRo2vjetuIjwmmCY0AEmmFFMLD8wfsSYluXHvm6X4igfmS8jFxwyUXWmqPcOsmmFZ7DaHXzxUZ6hatCTDIHMMy4BEVdimo7YDw)ayILnTxfG70KXjXeLyIHggozAnpgwHeB75N2VS(bWeSIrpwyyuWWjtR5XWPLQbwcWoEldmiCyy5t(USWCJvm6X4amkyy5t(USWCJHzGsfqLyyG4bYbL8DHyqLyqgXKmTM3DcyxE1EA9BU6T(ETbPy4KP18y4ta7YR2tRFdRy0Jf0yuWWjtR5XWNk5ko7bnkgw(KVllm3yfRy4L4ZwxXOGrpggfmCY0AEmmBAVka7bnkgw(KVllm3yfJEOyuWWYN8DzH5gdNmTMhd3BaofWzR)QvnTZUvEfdZaLkGkXWSz6RbH3PGMCqJ6acvw)z3AYDetuIjwyednnX4Rni1ceQS(JyIsmbbnm8NucgU3aCkGZw)vRAANDR8kwXOhemkyy5t(USWCJHtMwZJHtKFqjipRFE1oE7(GGaWWmqPcOsmCeeJV2GulqOY6pIjeIjzAnVLntFni8edsetq4iXqttmAc2e1bjzxHC7mLyIsmHIgXqttmAc2e1PfLy1XUZuBOOrmrjMyHrmrsmOsmSz6RbH3PGMCqJ6acvw)z3AYDetuIjwyednnX4Rni1ceQS(JyIsmbjmm8Nucgor(bLG8S(5v74T7dccaRy05igfmS8jFxwyUXWjtR5XW92PGPD2TPVK3U3Bu5MGHzGsfqLyy2m91GW7uqtoOrDaHkR)SBn5oIjkXegXqttm(AdsTaHkR)iMOetOOHH)KsWW92PGPD2TPVK3U3Bu5MGvm6HHrbdlFY3LfMBmCY0AEm8w2fw27c4S8Z8yygOubujgMV59of0KdAuhqOY6pIjeIjghjgAAIbzeJMD5vhl7963SkKypOrpN8jFxwednnX4Rni1ceQS(JyIsmXqdd)jLGH3YUWYExaNLFMhRy05amkyy5t(USWCJHtMwZJHZdk88LZcsKpalBazhdZaLkGkXW8nV3PGMCqJ6acvw)rmHqmX4iXGkXebXW38E3wlbRkF74TjYfWOqU2oXqttmiJyK7KNjo28l5pzz7Lx8dGjoQm(naIbvIHL2KPv4cXejXqttmlHV59oqI8byzdi72LW38E3Aq4jgAAIXxBqQfiuz9hXeLycfnm8NucgopOWZxolir(aSSbKDSIrpOXOGHLp57YcZngozAnpgEFyCk6vixww2qT30uR5Tlj8IjyygOubujggzedFZ7DkOjh0OU2oXGkXGmIrUtEM447ZSSJ3QqIvEHkohvg)gaXqttmlHV59o((ml74TkKyLxOIZ12jgAAIXxBqQfiuz9hXeLycdd)jLGH3hgNIEfYLLLnu7nn1AE7scVycwXOhuXOGHLp57YcZngMbkvavIH5BEVtbn5Gg1beQS(JycHyIXrIHMMyqgXOzxE1XYEV(nRcj2dA0ZjFY3LfXqttm(AdsTaHkR)iMOetOOHHtMwZJHBNylvOoSIrp(WOGHLp57YcZngozAnpgML9UnzAnVTxNIH71P2pPemmBDyfJEm0WOGHLp57YcZngMbkvavIHtMwHlw5fQsoIjkXeemCY0AEmml7DBY0AEBVofd3RtTFsjy4tXkg9yXWOGHLp57YcZngMbkvavIHtMwHlw5fQsoIjeIjumCY0AEmml7DBY0AEBVofd3RtTFsjyyfumopOrpSIvm8oqydfFQyuWOhdJcgw(KVllm3y4DGWYtTArjy4yOHHtMwZJHxtJVlwn3Xkg9qXOGHLp57YcZng(tkbdNi)GsqEw)8QD829bbbGHtMwZJHtKFqjipRFE1oE7(GGaWkg9GGrbdNmTMhdJWa6RWL6Ta5MpFMGHLp57YcZnwXOZrmky4KP18y4Twcwv(2XBtKlGrHWWYN8DzH5gRy0ddJcgozAnpgMsOgqC2XB7nwTSlGKuhgw(KVllm3yfJohGrbdlFY3LfMBm8oqy5PwTOemCmxyy4KP18yyf0KdAummduQaQedNmTcxSYluLCetietOyfJEqJrbdlFY3LfMBmmduQaQedNmTcxSYluLCetuIjiy4KP18y4SOKL9GgfRyfdZwhgfm6XWOGHLp57YcZngMbkvavIHzZ0xdcVdK71Y6lG4acvw)rmrjMn2IyOPjg2m91GW7a5ETS(cioGqL1FetuIHntFni8USOKL9Gg1beQS(JyOPjgFTbPwGqL1FetuIju0WWjtR5XWRPX3fRM7yfJEOyuWWYN8DzH5gdZaLkGkXW8nV3PGMCqJ6acvw)rmHqmX4iXGkXebX4Rni1ceQS(JycHyyZ0xdcVJxaNa4S(n3QbsTMNyqIywnqQ18ednnXebXOjytuhKKDfYTZuIjkXekAednnXGmIrZU8QJLaX362SOCYN8Dzrmrsmrsm00eJV2GulqOY6pIjkXeliy4KP18yyEbCcGZ63Wkg9GGrbdlFY3LfMBmmduQaQedZ38ENcAYbnQdiuz9hXecXeJJedQeteeJV2GulqOY6pIjeIHntFni8o((mlRVbIZTAGuR5jgKiMvdKAnpXqttmrqmAc2e1bjzxHC7mLyIsmHIgXqttmiJy0SlV6yjq8TUnlkN8jFxwetKetKednnX4Rni1ceQS(JyIsmX4amCY0AEmmFFML13aXHvm6CeJcgw(KVllm3yygOubujgMV59of0KdAuhqOY6pIjeIjghjgujMiigFTbPwGqL1FetiedBM(Aq4D5ZKtbz3YYE3TAGuR5jgKiMvdKAnpXqttmrqmAc2e1bjzxHC7mLyIsmHIgXqttmiJy0SlV6yjq8TUnlkN8jFxwetKetKednnX4Rni1ceQS(JyIsmX4amCY0AEmC(m5uq2TSS3Xkg9WWOGHLp57YcZngMbkvavIH5BEVtbn5Gg1beQS(JycHyIXrIbvIjcIXxBqQfiuz9hXecXWMPVgeENVacFFMLB1aPwZtmirmRgi1AEIHMMyIGy0eSjQdsYUc52zkXeLycfnIHMMyqgXOzxE1XsG4BDBwuo5t(USiMijMijgAAIXxBqQfiuz9hXeLyIpmCY0AEmSVacFFMfwXOZbyuWWYN8DzH5gdZaLkGkXW8nV3PGMCqJ6wdcpgozAnpgUxBq6zJFT1gL8kwXOh0yuWWYN8DzH5gdZaLkGkXW8nV3PGMCqJ6wdcpgozAnpgMp3SJ3QGIX5Hvm6bvmkyy5t(USWCJHzGsfqLyy(M37uqtoOrDRbHNyqLyIGy0eSjQdsYUc52zkXecXeurJyOPjgnbBI6GKSRqUDMsmrdqmHIgXqttmAc2e1PfLy1XUZuBOOrmHqmbbnIjsmCY0AEmmqY963S(EsjhwXOhFyuWWYN8DzH5gdZaLkGkXWrqmSz6RbH3Li)GsqEw)8QD829bbb4acvw)rmHqmHIgXqttmiJyK41wTVllxI8dkb5z9ZR2XB3heeaXqttm(AdsTaHkR)iMOedBM(Aq4DjYpOeKN1pVAhVDFqqaUvdKAnpXGeXeeosmOsmAc2e1bjzxHC7mLycHycfnIjsIbvIjcIHntFni8of0KdAuhqOY6p7wtUJyIsmbHyOPjMiig5o5zIl86Q5TJ3UlaVW0AEhv9dGyqLy81gKAbcvw)rmHqmjtR5TSz6RbHNyqIy4BEVdHb0xHl1BbYnF(mXTAGuR5jMijMijgAAIXxBqQfiuz9hXeLycfnmCY0AEmmcdOVcxQ3cKB(8zcwXOhdnmkyy5t(USWCJHzGsfqLy4iigwAtMwHlednnX4Rni1ceQS(JycHysMwZBzZ0xdcpXGeXee0iMijgujMiig(M37uqtoOrDTDIHMMyyZ0xdcVtbn5Gg1beQS(JyIsmX4aIjsIHMMy81gKAbcvw)rmrjMGeddNmTMhdV1sWQY3oEBICbmkewXOhlggfmS8jFxwyUXWmqPcOsmmBM(Aq4DkOjh0OoGqL1FetuIjOXWjtR5XWGAFVl26T3EYeSIrpwOyuWWYN8DzH5gdZaLkGkXWiJy4BEVtbn5Gg112XWjtR5XWuc1aIZoEBVXQLDbKK6Wkg9ybbJcgw(KVllm3yygOubujgMV59of0KdAuhqsMsmOsm8nV3X3Nz1BN6asYuIHMMy4BEVtbn5Gg1beQS(JycHyIXrIbvIrtWMOoij7kKBNPetuIju0igAAIjcIjcIHn)1Os(U42hTM3oEB75b1QllRVbIJyOPjg28xJk57IR98GA1LL13aXrmrsmOsm(AdsTaHkR)iMOedheJyOPjgFTbPwGqL1FetuIjuoGyIedNmTMhdVpAnpwXOhJJyuWWYN8DzH5gdZaLkGkXW8nV3PGMCqJ6wdcpXGkXWMPVgeEhi3RL1xaXbeQS(JyOPjgFTbPwGqL1FetuIjwyy4KP18yyf0KdAuSIvm8PyuWOhdJcgw(KVllm3yygOubujgwZU8Q7ujxXz9dRDo5t(USigujMDGeUDJTCXCNk5ko7bnkXGkXW38E3PsUIZ6hw7CaHkR)iMOetyy4KP18y4tLCfN9GgfRy0dfJcgozAnpgMZQ3Th0Oyy5t(USWCJvm6bbJcgozAnpgw4q795QWf7bnkgw(KVllm3yfJohXOGHLp57YcZngMbkvavIHtMwHlw5fQsoIjeIjggozAnpgMpbGCtWkg9WWOGHtMwZJHtlvdSeGD8wgyq4WWYN8DzH5gRy05amky4KP18y4WNExIddlFY3LfMBSIrpOXOGHLp57YcZngMbkvavIHbIhihuY3fIbvIbzetY0AE3jGD5v7P1V5Q3671gKIHtMwZJHpbSlVApT(nSIrpOIrbdlFY3LfMBmmduQaQedZ38ENcAYbnQBni8ednnX4hw7iMOetqcJyOPjg)WAhXeLy4a0igujgKrmA2LxDDrHYU9Gg9CYN8Dzrm00edFZ7D1BviXcGItHOCaHkR)iMOeJWHewtfRwucgozAnpggK71Y6lGGvm6XhgfmS8jFxwyUXWmqPcOsmmFZ7DkOjh0OU2oXGkXebXW38Ex7faO(nB41vZ7onzCsmHqmCKyOPjgKrmjYfqPIR9cau)Mn86Q5DYN8Dzrmrsm00eJV2GulqOY6pIjkXelggozAnpgMVpZYoERcjw5fQ4Wkg9yOHrbdlFY3LfMBmmduQaQedJmIHV59of0KdAuxBNyOPjgFTbPwGqL1FetuIjmmCY0AEmSFyTtw2e5cOuXYljfwXOhlggfmS8jFxwyUXWmqPcOsmmFZ7DkOjh0OU2oXqttmrqm8nV3TMgFxSAU7wdcpXqttmS0MmTcxiMijgujg(M372bcRoXEqJEU1GWtm00eJV17wGWGsWMy1IsiMOedlp1QfLqmOsmSz6RbH3PGMCqJ6acvw)HHtMwZJHZIsw2dAuSIrpwOyuWWYN8DzH5gdZaLkGkXWiJy4BEVtbn5Gg112jgAAIXxBqQfiuz9hXeLycQy4KP18y49gO8Xv)MLVNNIvm6XccgfmS8jFxwyUXWmqPcOsmSFyTJyqIy8dRDoGSjpXeuGy2ylIjkX4hw7CujhIyqLy4BEVtbn5Gg1TgeEIbvIjcIbzeZAuhBEM8kivzz99KsS8nW7acvw)rmOsmiJysMwZ7yZZKxbPklRVNuIRERVxBqkXejXqttm(wVBbcdkbBIvlkHyIsmBSfXqttm(AdsTaHkR)iMOetyy4KP18yy28m5vqQYY67jLGvm6X4igfmS8jFxwyUXWmqPcOsmmFZ7DaHXzxUZ6hatCTDIHMMy4BEVdimo7YDw)ayILnTxfG70KXjXeLyIHgXqttm(AdsTaHkR)iMOetyy4KP18yyfsSTNFA)Y6hatWkg9yHHrbdlFY3LfMBmmduQaQedZ38ENcAYbnQBni8edQeteedFZ7D7aHvNypOrpxBNyqLyIGy8dRDetietyHrmrsm00eJFyTJycHyc6WigAAIXxBqQfiuz9hXeLycJyIedNmTMhdNaw(I9GgfRy0JXbyuWWYN8DzH5gdZaLkGkXW8nV3PGMCqJ6wdcpXGkXebXW38E3oqy1j2dA0Z12jgujMiig)WAhXecXewyetKednnX4hw7iMqiMGomIHMMy81gKAbcvw)rmrjMWiMiXWjtR5XWmOIkfqApOrXkg9ybngfmCY0AEm8PsUIZEqJIHLp57YcZnwXkwXWHlGRMhJEOOfkAXqlwqCXWWiKGV(Tddh)jEy8p0JNrp(B8cXqmOajetrTpaLy8dGyI3S1fVjgGeV2kGSiMBOeIjB6qLQSiggu(BY5iigpvVqmXx8cXeuA(WfGklIjERG65uuxqzhBM(Aq4J3eJoet8MntFni8UGYXBIjIq5qr6iisqmEMAFaQSiMWiMKP18etVo9CeeXW3UWWOhAyCedVdgF1fmmhMyIhtaNhv(huTtmbfBVkacICyIjEathEbqmXclyIju0cfncIee5Wet8KeU0jMObiMWqZrqKGihMyI)dewEkXOq1rm5rmsc6Xrm5rm7ZDfFxigDiM9rLxRS3JJy2Y6jM8hfsaedlpLywnq9BeJcjeJV2GuhbXKP18NBhiSHIpvKcW1AA8DXQ5EW7aHLNA1IscedncIjtR5p3oqydfFQifGR2j2sfQG)KscKi)GsqEw)8QD829bbbqqmzAn)52bcBO4tfPaCHWa6RWL6Ta5MpFMqqmzAn)52bcBO4tfPaCT1sWQY3oEBICbmkebXKP18NBhiSHIpvKcWfLqnG4SJ32BSAzxajPocIjtR5p3oqydfFQifGlf0KdA0G3bclp1QfLeiMlSGlFGKPv4IvEHQKlKqjiMmTM)C7aHnu8PIuaUYIsw2dA0GlFGKPv4IvEHQKlAqiisqmzAn)HuaUyt7vbypOrjiMmTM)qkaxTtSLkub)jLeO3aCkGZw)vRAANDR8AWLpaBM(Aq4DkOjh0OoGqL1F2TMCx0yHrt7Rni1ceQS(lAqqJGyY0A(dPaC1oXwQqf8NusGe5hucYZ6NxTJ3UpiiGGlFGi81gKAbcvw)fcBM(Aq4rkiCKMwtWMOoij7kKBNPrdfnAAnbBI60IsS6y3zQnu0IglSirLntFni8of0KdAuhqOY6p7wtUlASWOP91gKAbcvw)fniHrqmzAn)HuaUANylvOc(tkjqVDkyANDB6l5T79gvUjbx(aSz6RbH3PGMCqJ6acvw)z3AYDrdJM2xBqQfiuz9x0qrJGyY0A(dPaC1oXwQqf8NusGTSlSS3fWz5N5dU8b4BEVtbn5Gg1beQS(lKyCKMgzA2LxDSS3RFZQqI9Gg9CYN8Dzrt7Rni1ceQS(lAm0iiMmTM)qkaxTtSLkub)jLeipOWZxolir(aSSbK9GlFa(M37uqtoOrDaHkR)cjghrnc(M372Ajyv5BhVnrUagfY12PPrMCN8mXXMFj)jlBV8IFamXrLXVbGklTjtRWLiPPxcFZ7DGe5dWYgq2TlHV59U1GWtt7Rni1ceQS(lAOOrqmzAn)HuaUANylvOc(tkjW(W4u0RqUSSSHAVPPwZBxs4ftcU8bqgFZ7DkOjh0OU2oQitUtEM447ZSSJ3QqIvEHkohvg)gan9s4BEVJVpZYoERcjw5fQ4CTDAAFTbPwGqL1FrdJGihMyqbehXOdX0RxiM2oXKmTcpvzrmkOEof9igekfIyqb0KdAucIjtR5pKcWv7eBPc1fC5dW38ENcAYbnQdiuz9xiX4innY0SlV6yzVx)MvHe7bn65Kp57YIM2xBqQfiuz9x0qrJGyY0A(dPaCXYE3MmTM32Rtd(tkjaBDeetMwZFifGlw272KP182EDAWFsjbon4YhizAfUyLxOk5IgecIjtR5pKcWfl7DBY0AEBVon4pPKakOyCEqJEbx(ajtRWfR8cvjxiHsqKGyY0A(ZXwxG1047IvZ9GlFa2m91GW7a5ETS(cioGqL1Fr3ylAA2m91GW7a5ETS(cioGqL1FrzZ0xdcVllkzzpOrDaHkR)OP91gKAbcvw)fnu0iiMmTM)CS1HuaU4fWjaoRFl4YhGV59of0KdAuhqOY6VqIXruJWxBqQfiuz9xiSz6RbH3XlGtaCw)MB1aPwZJ0QbsTMNMocnbBI6GKSRqUDMgnu0OPrMMD5vhlbIV1Tzr5Kp57YkYiPP91gKAbcvw)fnwqiiMmTM)CS1HuaU47ZSS(giUGlFa(M37uqtoOrDaHkR)cjghrncFTbPwGqL1FHWMPVgeEhFFML13aX5wnqQ18iTAGuR5PPJqtWMOoij7kKBNPrdfnAAKPzxE1XsG4BDBwuo5t(USImsAAFTbPwGqL1FrJXbeetMwZFo26qkax5ZKtbz3YYEp4YhGV59of0KdAuhqOY6VqIXruJWxBqQfiuz9xiSz6RbH3LptofKDll7D3QbsTMhPvdKAnpnDeAc2e1bjzxHC7mnAOOrtJmn7YRowceFRBZIYjFY3LvKrst7Rni1ceQS(lAmoGGyY0A(ZXwhsb4YxaHVpZk4YhGV59of0KdAuhqOY6VqIXruJWxBqQfiuz9xiSz6RbH35lGW3Nz5wnqQ18iTAGuR5PPJqtWMOoij7kKBNPrdfnAAKPzxE1XsG4BDBwuo5t(USImsAAFTbPwGqL1FrJpcIjtR5phBDifGRETbPNn(1wBuYRbx(a8nV3PGMCqJ6wdcpbXKP18NJToKcWfFUzhVvbfJZl4YhGV59of0KdAu3Aq4jiMmTM)CS1HuaUasUx)M13tk5cU8b4BEVtbn5Gg1TgeEuJqtWMOoij7kKBNPHeurJMwtWMOoij7kKBNPrdekA00Ac2e1PfLy1XUZuBOOfsqqlscIjtR5phBDifGlegqFfUuVfi385ZKGlFGiuq9CkQlr(bLG8S(5v74T7dccWXMPVgeEhqOY6VqcfnAAKjXRTAFxwUe5hucYZ6NxTJ3UpiiaAAFTbPwGqL1Frvq9CkQlr(bLG8S(5v74T7dccWXMPVgeE3QbsTMhPGWru1eSjQdsYUc52zAiHIwKOgbBM(Aq4DkOjh0OoGqL1F2TMCx0GqthHCN8mXfED182XB3fGxyAnVJQ(bGQV2GulqOY6VqyZ0xdcps8nV3HWa6RWL6Ta5MpFM4wnqQ18rgjnTV2GulqOY6VOHIgbXKP18NJToKcW1wlbRkF74TjYfWOqbx(arWsBY0kCHM2xBqQfiuz9xiSz6RbHhPGGwKOgbFZ7DkOjh0OU2onnBM(Aq4DkOjh0OoGqL1FrJXbrst7Rni1ceQS(lAqIrqmzAn)5yRdPaCbQ99UyR3E7jtcU8byZ0xdcVtbn5Gg1beQS(lAqtqmzAn)5yRdPaCrjudio74T9gRw2fqsQl4Yhaz8nV3PGMCqJ6A7eetMwZFo26qkax7JwZhC5dW38ENcAYbnQdijtrLV59o((mRE7uhqsMstZ38ENcAYbnQdiuz9xiX4iQAc2e1bjzxHC7mnAOOrthreS5VgvY3f3(O182XBBppOwDzz9nqC00S5VgvY3fx75b1QllRVbIlsu91gKAbcvw)fLdIrt7Rni1ceQS(lAOCqKeetMwZFo26qkaxkOjh0Obx(a8nV3PGMCqJ6wdcpQSz6RbH3bY9Az9fqCaHkR)OP91gKAbcvw)fnwyeejiMmTM)CNg4ujxXzpOrdU8b0SlV6ovYvCw)WANt(KVllu3bs42n2YfZDQKR4Sh0OOY38E3PsUIZ6hw7CaHkR)IggbXKP18N7uKcWfNvVBpOrjiMmTM)CNIuaUeo0EFUkCXEqJsqmzAn)5ofPaCXNaqUjbx(ajtRWfR8cvjxiXiiMmTM)CNIuaUslvdSeGD8wgyq4iiMmTM)CNIuaUcF6DjocIjtR5p3PifGRta7YR2tRFl4YhaiEGCqjFxqfzjtR5DNa2LxTNw)MRERVxBqkbXKP18N7uKcWfi3RL1xaj4YhGV59of0KdAu3Aq4PP9dRDrdsy00(H1UOCaAOImn7YRUUOqz3EqJEo5t(USOP5BEVRERcjwauCkeLdiuz9xuHdjSMkwTOecIjtR5p3PifGl((ml74TkKyLxOIl4YhGV59of0KdAuxBh1i4BEVR9cau)Mn86Q5DNMmodHJ00ilrUakvCTxaG63SHxxnVt(KVlRiPP91gKAbcvw)fnwmcIjtR5p3PifGl)WANSSjYfqPILxsQGlFaKX38ENcAYbnQRTtt7Rni1ceQS(lAyeetMwZFUtrkaxzrjl7bnAWLpaFZ7DkOjh0OU2onDe8nV3TMgFxSAU7wdcpnnlTjtRWLirLV59UDGWQtSh0ONBni800(wVBbcdkbBIvlkjklp1QfLGkBM(Aq4DkOjh0OoGqL1FeetMwZFUtrkax7nq5JR(nlFppn4Yhaz8nV3PGMCqJ6A700(AdsTaHkR)IgujiMmTM)CNIuaUyZZKxbPklRVNusWLpGFyTdj)WANdiBYhuyJTI6hw7Cujhcv(M37uqtoOrDRbHh1iq2AuhBEM8kivzz99KsS8nW7acvw)HkYsMwZ7yZZKxbPklRVNuIRERVxBqAK00(wVBbcdkbBIvlkj6gBrt7Rni1ceQS(lAyeetMwZFUtrkaxkKyBp)0(L1paMeC5dW38EhqyC2L7S(bWexBNMMV59oGW4Sl3z9dGjw20EvaUttgNrJHgnTV2GulqOY6VOHrqmzAn)5ofPaCLaw(I9Ggn4YhGV59of0KdAu3Aq4rnc(M372bcRoXEqJEU2oQr4hw7cjSWIKM2pS2fsqhgnTV2GulqOY6VOHfjbXKP18N7uKcWfdQOsbK2dA0GlFa(M37uqtoOrDRbHh1i4BEVBhiS6e7bn65A7OgHFyTlKWclsAA)WAxibDy00(AdsTaHkR)IgwKeetMwZFUtrkaxNk5ko7bnkbrcIjtR5pNckgNh0OxaoRE3EqJsqmzAn)5uqX48Gg9qkaxHp9UehbXKP18NtbfJZdA0dPaCXNaqUjeetMwZFofumopOrpKcWLWH27ZvHl2dAucIjtR5pNckgNh0Ohsb4klkzzpOrdU8b4BEVtbfJt7bn65A7OYsBY0kCbv(M37wtJVlwn3DTDcIjtR5pNckgNh0Ohsb4cK71Y6lGeC5dW38ENckgN2dA0Z12rnIe5cOuX5hw7KL1xaXjFY3LfnDICbuQ4Q3QqIfafNcr5a5ZziXOPtKlGsf31aB1VzpOrpN8jFxw00A2LxDNcKKQxV4Kp57YkscIjtR5pNckgNh0Ohsb4klkzzpOrdU8b4BEVtbfJt7bn65A7OgbFZ7D7aHvNypOrp3Aq4PPzZ0xdcVllkzzpOrD(wVBbcdkbBIvlkjAY0AExwuYYEqJ6y5PwTOeAA(M37uqtoOrDT9ijiMmTM)CkOyCEqJEifGlqUxlRVasWLpaFZ7DkOyCApOrpxBNGyY0A(ZPGIX5bn6HuaUOADToOrdU8b4BEVtbfJt7bn65wdcpnnFZ7D7aHvNypOrpxBhvKX38ENcAYbnQRTtt7hw7cjOrJGyY0A(ZPGIX5bn6HuaU8dRDYYMixaLkwEjPiiMmTM)CkOyCEqJEifGR9gO8Xv)MLVNNsqmzAn)5uqX48Gg9qkaxS5zYRGuLL13tkHGyY0A(ZPGIX5bn6HuaU47ZSSJ3QqIvEHkUGlFGDGeUDJTCXCHp9UehnnY0SlV6cF6DjoN8jFxw00Ac2e1PfLy1XUkjASyeetMwZFofumopOrpKcWLcj22ZpTFz9dGjbx(a8nV3begND5oRFamX12PP5BEVdimo7YDw)ayILnTxfG70KXz0yOrqmzAn)5uqX48Gg9qkaxPLQbwcWoEldmiCeetMwZFofumopOrpKcW1jGD5v7P1VfC5daepqoOKVlOISKP18Uta7YR2tRFZvV13RniLGyY0A(ZPGIX5bn6HuaUovYvC2dAuSIvmg]] )
    end

end