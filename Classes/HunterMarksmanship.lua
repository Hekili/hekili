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
        spec:RegisterPack( "Marksmanship", 20201011.9, [[dCKR9aqiGQEePc1MiP8jQuvnkrLoLOkVsumlsQUfPcr7Is)cQ0Wiv6yIslJuLNrLktdQkxJurBdQQ6BqvfJJkvX5GQkToQuvmpG4EKK9rQQdcurvleQYdjvi8rGkknssfsDsQuvALaPzsLQKUjvQsTtOIFsLQelfOIkpfWubkFfOIIXsQqYEH8xQAWuCyHftkpgXKv4YO2SiFwrnAOCAPwnqf51uPmBvCBsSBq)wYWvKJduHLRQNR00jUUkTDrfFNkz8Kk48IQA9avA(uX(rAuweyiGrimch90vpDZQB2S2S4dF6eF4pcqYFIratbXTyMraWqHraU3X72QeWfRNqatr(NkgiWqaBDFcJa0XudMitR7dU4o3c2vZskfC3w5EcPli5JKG72keCraA3(iUVqKgcyecJWrpD1t3S6MnRnl(WNoXNoraXvWQhba0k6iqay9yWqKgcyWlbbOJPg374DBvc4I1tuJo6lu4NcQoMACVqKsJFQjBw1Pg90vpDPGsbvhtnGH1l10l1iym1C4C4d1Op1OtDPMC4F7cAraNELfbgcq(M42IvYIadHtweyiaggAhEGWdbq(w4VdeaPQZOCbTrRWd)IvI9ornooudPQZOCbTFm1dFQF2(Ss0WLA0NAivDgLlOnAfE4xSsSpRenCrabr6cIag1v7WEjMqcch9qGHayyOD4bcpea5BH)oqa)fYP6Nz7w3tQ(z2ZkA8VwgCC7PjEqnQrns8E5Jj7ZkrdxQbeQzMmOg1OgsvNr5cAtN4z7ZkrdxQbeQzMmqabr6cIaK49YhtibHJ7qGHayyOD4bcpea5BH)oqa)fYP6Nz7w3tQ(z2ZkA8VwggAhEqnQrns8E5Jj7DcbeePliciDINrcch8HadbeePlicWvFg(DQ)wweaddTdpq4Heeo6ebgciisxqeqo15W5JayyOD4bcpKGWb)rGHacI0feb88wWqA4Sp(VCHayyOD4bcpKGWb)GadbeePlicql(pMzeaddTdpq4HeeoUheyiGGiDbraSomDQTZH9lwjiaggAhEGWdjiCWViWqamm0o8aHhcG8TWFhiasvNr5cA)yQh(u)S9zLOHl144qnPICxQjd1eePlO9JPE4t9ZwsSI)5zgsn6tnPICxRsOduJJd1K6zmX)Ss0WLAaHAYQteqqKUGia5V8Ivcsq4KvxeyiaggAhEGWdbq(w4VdeG2nLSY3e38lwjR9ornQrn5snA3uYo9mPx2VyLS2r5csnoout6Eo(NjyXpZEPvyQbeQHeR4LwHPMmuZmzqnoouJ2nLSYF5fRe7DIAYdbeePliciAfE4xSsqccNSzrGHayyOD4bcpea5BH)oqaPICxQjd1qIv8ppZqQbeQjvK7AvcDabeePlicyWHG5jyHBFOGeeoz1dbgcGHH2Hhi8qaKVf(7abODtjR8nXn)IvYAVtuJAuJ2nLSJ6QDyVet2r5cIacI0feb8Xup8P(zKGWjR7qGHayyOD4bcpea5BH)oqaA3uYkFtCZVyLS2r5csnoouJ2nLStpt6L9lwjR9ornooutQi3LA0rsnKAfQjd1qIv8ppZqQrFQjisxqB0k8WVyLyj1kiGGiDbrak3J0lwjibHtw8HadbWWq7WdeEiaY3c)DGa0UPKDWXWZ5Z2r5cIacI0feb4wFo(fReKGWjRorGHacI0febeEL7p43xjp5lxlcGHH2Hhi8qccNS4pcmeqqKUGiG0jYNh(fReeaddTdpq4HeeozXpiWqamm0o8aHhciisxqeWY)edf)knCgbq(w4VdeWZPNxSq7Wias(Kd7L4Nzzr4KfjiCY6EqGHacI0febSchJ89lwjiaggAhEGWdjibbm4uCpccmeozrGHacI0febqQlu43VyLGayyOD4bcpKGWrpeyiaggAhEGWdbeePlic4CF34F9nC7rx31p3jbbq(w4VdeaPQZOCbTYF5fRe7Zkrdx)8L3LAaHAYQtQXXHAs9mM4FwjA4snGqnUtxeamuyeW5(UX)6B42JUURFUtcsq44oeyiaggAhEGWdbeePlicia3fl(y9Pck(k5Nkx8JaiFl83bcixQj1ZyI)zLOHl1Op1eePlONu1zuUGutgQXD4JACCOgj(zwSyCCem7erOgqOg90LACCOgj(zwSsRWEP8teXRNUudiutwDsn5rnQrnKQoJYf0k)LxSsSpRenC9ZxExQbeQjRoPghhQj1ZyI)zLOHl1ac14oDIaGHcJacWDXIpwFQGIVs(PYf)ibHd(qGHayyOD4bcpeqqKUGiGZDLVURFUodg6NoxLyMraKVf(7abqQ6mkxqR8xEXkX(Ss0W1pF5DPgqOgDsnooutQNXe)ZkrdxQbeQrpDraWqHraN7kFDx)CDgm0pDUkXmJeeo6ebgcGHH2Hhi8qabr6cIaMJdtIZH)1Rvfebq(w4VdeG2nLSYF5fRe7ZkrdxQrFQjl(OghhQb8uJehgkwsConC2lySFXkzTmm0o8GACCOMupJj(NvIgUudiutwDraWqHraZXHjX5W)61QcIeeo4pcmeaddTdpq4HacI0febelwobKx)hGB9Es9Xbbq(w4VdeG2nLSYF5fRe7ZkrdxQrFQjl(Og1OMCPgTBkzNVXp6a6RKpax(lbZENOghhQb8udVldjSLuWbdxE4pDIt1tyRsaovp1Og1qcFqKohMAYJACCOMbRDtj7hGB9Es9XXpyTBkzhLli144qnPEgt8pRenCPgqOg90fbadfgbelwobKx)hGB9Es9XbjiCWpiWqamm0o8aHhciisxqeWurCJLTbxE4jLY0vcPlOFW50egbq(w4Vdea4PgTBkzL)Ylwj27e1Og1aEQH3LHe2QDQA4RKxWypdzL8Tkb4u9uJJd1myTBkz1ovn8vYlySNHSs(27e144qnPEgt8pRenCPgqOgDIaGHcJaMkIBSSn4YdpPuMUsiDb9doNMWibHJ7bbgcGHH2Hhi8qaKVf(7abODtjR8xEXkX(Ss0WLA0NAYIpQXXHAap1iXHHILeNtdN9cg7xSswlddTdpOghhQj1ZyI)zLOHl1ac1ONUiGGiDbra3L9TWklsq4GFrGHayyOD4bcpeqqKUGiasCo(GiDb9NEfeWPxXddfgbqglsq4KvxeyiaggAhEGWdbq(w4VdeqqKoh2ZqwP5LAaHAChciisxqeajohFqKUG(tVcc40R4HHcJawbjiCYMfbgcGHH2Hhi8qaKVf(7abeePZH9mKvAEPg9Pg9qabr6cIaiX54dI0f0F6vqaNEfpmuyeG8nXTfRKfjibbm9mPu0cbbgcNSiWqamm0o8aHhcG8TWFhiG)c5u9ZSDR7jv)m7zfn(xldoU90epqabr6cIaK49YhtibHJEiWqamm0o8aHhcy6zsSIxAfgbKvxeqqKUGiGrD1oSxIjKGWXDiWqamm0o8aHhciisxqeWujDbraJ8HHst8tppvccilsq4GpeyiaggAhEGWdbq(w4VdeqqKoh2ZqwP5LAurnzrabr6cIaIwHh(fReKGeeazSiWq4KfbgcGHH2Hhi8qaKVf(7abqQ6mkxq7ht9WN6NTpRenCPgqOMzYGACCOgsvNr5cA)yQh(u)S9zLOHl1ac1qQ6mkxqB0k8WVyLyFwjA4snooutQNXe)ZkrdxQbeQrpDrabr6cIag1v7WEjMqcch9qGHayyOD4bcpea5BH)oqaA3uYk)LxSsSpRenCPg9PMS4JAuJAYLAs9mM4FwjA4sn6tnKQoJYf0QX)YVBnC2oUFiDbPMmuZ4(H0fKACCOMCPgj(zwSyCCem7erOgqOg90LACCOgWtnsCyOyjXZP7XhTILHH2HhutEutEuJJd1K6zmX)Ss0WLAaHAY6oeqqKUGian(x(DRHZibHJ7qGHayyOD4bcpea5BH)oqaA3uYk)LxSsSpRenCPg9PMS4JAuJAYLAs9mM4FwjA4sn6tnKQoJYf0QDQA4t3pF74(H0fKAYqnJ7hsxqQXXHAYLAK4NzXIXXrWSteHAaHA0txQXXHAap1iXHHILepNUhF0kwggAhEqn5rn5rnooutQNXe)ZkrdxQbeQjl(JacI0febODQA4t3pFKGWbFiWqamm0o8aHhcG8TWFhiaTBkzL)Ylwj2NvIgUuJ(utw8rnQrn5snPEgt8pRenCPg9PgsvNr5cAdiHx5JJNeNJDC)q6csnzOMX9dPli144qn5sns8ZSyX44iy2jIqnGqn6Pl144qnGNAK4WqXsINt3JpAflddTdpOM8OM8OghhQj1ZyI)zLOHl1ac1Kf)rabr6cIaciHx5JJNeNdsq4OteyiaggAhEGWdbq(w4VdeG2nLSYF5fRe7ZkrdxQrFQjl(Og1OMCPMupJj(NvIgUuJ(udPQZOCbTP(zTtvd74(H0fKAYqnJ7hsxqQXXHAYLAK4NzXIXXrWSteHAaHA0txQXXHAap1iXHHILepNUhF0kwggAhEqn5rn5rnooutQNXe)ZkrdxQbeQb)IacI0febK6N1ovnqcch8hbgcGHH2Hhi8qaKVf(7abODtjR8xEXkXokxqeqqKUGiGtpJjRhC6oMvyOGeeo4heyiaggAhEGWdbq(w4VdeG2nLSYF5fRe7OCbrabr6cIa0IzFL8Y3e3wKGWX9GadbWWq7WdeEiaY3c)DGa0UPKv(lVyLyhLli1Og1Kl1iXpZIfJJJGzNic1Op14E0LACCOgj(zwSyCCem7erOgqurn6Pl144qns8ZSyLwH9s5NiIxpDPg9Pg3Pl1KhciisxqeWZXudN9PtOWlsq4GFrGHayyOD4bcpea5BH)oqa5snKQoJYf0gG7IfFS(ubfFL8tLl(TpRenCPg9Pg90LACCOgWtnm442tt8WgG7IfFS(ubfFL8tLl(PghhQj1ZyI)zLOHl1ac1qQ6mkxqBaUlw8X6tfu8vYpvU43oUFiDbPMmuJ7Wh1Og1iXpZIfJJJGzNic1Op1ONUutEuJAutUudPQZOCbTYF5fRe7Zkrdx)8L3LAaHACh144qn5sn8UmKW2C6TlOVs(j(tmr6cAvAy9uJAutQNXe)ZkrdxQrFQjisxqpPQZOCbPMmuJ2nLSUQ)mYHBO)5TGbKW2X9dPli1Kh1Kh144qnPEgt8pRenCPgqOg90fbeePlicWv9NroCd9pVfmGegjiCYQlcmeaddTdpq4HaiFl83bcixQHe(GiDom144qnPEgt8pRenCPg9PMGiDb9KQoJYfKAYqnUtxQjpQrnQjxQr7Msw5V8IvI9ornooudPQZOCbTYF5fRe7ZkrdxQbeQjl(tn5rnooutQNXe)ZkrdxQbeQXDzrabr6cIaMVXp6a6RKpax(lbdjiCYMfbgcGHH2Hhi8qaKVf(7abqQ6mkxqR8xEXkX(Ss0WLAaHAWpiGGiDbraFpnDyFd97uqyKGWjREiWqamm0o8aHhcG8TWFhiaWtnA3uYk)LxSsS3jeqqKUGiafwP(89vYFUKE4hphklsq4K1DiWqamm0o8aHhcG8TWFhiaTBkzL)Ylwj2NdIqnQrnA3uYQDQACURyFoic144qnA3uYk)LxSsSpRenCPg9PMS4JAuJAK4NzXIXXrWSteHAaHA0txQXXHAYLAYLAifCVkH2HTtL0f0xj)fQ994WdF6(5tnooudPG7vj0oS9c1(EC4HpD)8PM8Og1OMupJj(NvIgUudiud(NLACCOMupJj(NvIgUudiuJE4p1KhciisxqeWujDbrccNS4dbgcGHH2Hhi8qaKVf(7abODtjR8xEXkXokxqQrnQHu1zuUG2pM6Hp1pBFwjA4snooutQNXe)ZkrdxQbeQjRorabr6cIaK)YlwjibjiGvqGHWjlcmeaddTdpq4HaiFl83bcqIddf7kCmY3NkYDTmm0o8GAuJAMEoh)mzyZAxHJr((fReQrnQr7Ms2v4yKVpvK7AFwjA4snGqn6ebeePlicyfog57xSsqcch9qGHacI0feb4wFo(fReeaddTdpq4HeeoUdbgciisxqeWOUAh2lXecGHH2Hhi8qcch8HadbWWq7WdeEiaY3c)DGa(lKt1pZ2TUNu9ZSNv04FTm442tt8GAuJAK49Yht2NvIgUudiuZmzqnQrnKQoJYf0MoXZ2NvIgUudiuZmzGacI0febiX7LpMqcchDIadbWWq7WdeEiaY3c)DGa(lKt1pZ2TUNu9ZSNv04FTmm0o8GAuJAK49Yht27eciisxqeq6epJeeo4pcmeqqKUGiax9z43P(Bzramm0o8aHhsq4GFqGHacI0febKor(8WVyLGayyOD4bcpKGWX9GadbWWq7WdeEiaY3c)DGasf5UutgQHeR4FEMHudiutQi31Qe6aciisxqeWGdbZtWc3(qbjiCWViWqabr6cIayDy6uBNd7xSsqamm0o8aHhsq4KvxeyiaggAhEGWdbq(w4VdeG2nLStpt6L9lwjRDuUGuJJd1aEQrIddflbRvc(d)IvILHH2HhiGGiDbra5uNdNpsq4KnlcmeqqKUGiGWRC)b)(k5jF5Aramm0o8aHhsq4KvpeyiaggAhEGWdbq(w4VdeG2nLStpt6L9lwjRDuUGuJJd1aEQrIddflbRvc(d)IvILHH2HhiGGiDbrapVfmKgo7J)lxibHtw3HadbWWq7WdeEiaY3c)DGa0UPKD6zsVSFXkzTJYfKACCOgWtnsCyOyjyTsWF4xSsSmm0o8abeePlicq(lVyLGeeozXhcmeaddTdpq4HaiFl83bcixQjDph)ZeS4NzV0km1ac1qIv8sRWutgQzMmOghhQr7Msw5V8IvI9orn5rnQrn5snA3uYo9mPx2VyLS2r5csnooud4PgjomuSeSwj4p8lwjwggAhEqnooudj8br6CyQjpQXXHA0UPKv(M4MFXkzTpRenCPg9PgwhyYvyV0km1Og1Kl1eePZH9mKvAEPg9PMSuJJd18xiNQFMTl)tmuwjoUX)6LVjUXF(wgCC7PjEqn5HacI0febeTcp8lwjibHtwDIadbWWq7WdeEiaY3c)DGa0UPKDuxTd7LyYokxqQrnQjvK7snzOgsSI)5zgsnGqnPICxRsOdiGGiDbraFm1dFQFgjiCYI)iWqamm0o8aHhcG8TWFhiaTBkzNEM0l7xSsw7DIAuJAYLA0UPKv(lVyLyhLli144qnbr6CypdzLMxQrFQjl144qnGNAiHpisNdtn5HacI0febqWALG)WVyLGeeozXpiWqamm0o8aHhciisxqeWY)edf)knCgbq(w4VdeWZPNxSq7WuJAuJe)mlwPvyVu(rZuJ(uZ4(H0febqYNCyVe)mllcNSibHtw3dcmeaddTdpq4HaiFl83bciisNd7ziR08sn6tnzrabr6cIa0I)JzgjiCYIFrGHayyOD4bcpea5BH)oqaA3uYo9mPx2VyLS27e1Og1Kl1ODtjR8xEXkXokxqQXXHAap1qcFqKohMAYdbeePliciEsaz)Ivcsq4ONUiWqamm0o8aHhcG8TWFhiaTBkzNEM0l7xSsw7OCbrabr6cIaIwHh(fReKGWrVSiWqamm0o8aHhcG8TWFhiGurUl1Op1qQvOMmutqKUG2Ov4HFXkXsQvOg1OMCPgTBkzL)Ylwj2r5csnooud4Pgs4dI05WutEiGGiDbraeSwj4p8lwjibHJE6HadbWWq7WdeEiaY3c)DGasf5UuJ(udPwHAYqnbr6cAJwHh(fRelPwHAuJAYLA0UPKv(lVyLyhLli144qnGNAiHpisNdtn5HacI0febepjGSFXkbjiC0ZDiWqamm0o8aHhcG8TWFhiGurUl1KHAiXk(NNzi1ac1KkYDTkHoGacI0febSchJ89lwjibHJE4dbgciisxqeabRvc(d)IvccGHH2Hhi8qcch90jcmeqqKUGiG4jbK9lwjiaggAhEGWdjibjiGC4F7cIWrpD1t3S6Ql(XIFraUIh2W5fbaod48GZHJ7loGZ6(qnudyym10kt1lutQEQX9tgR7NAEgCC7NhuZwkm1exPucHhudblGZ8APG6ETHm1GFDFOgDefmh(fEqnUF5BOBSy1rzjvDgLlO7NAKIAC)KQoJYf0QJY9tn5QNoKNLckfu3xLP6fEqn6KAcI0fKAo9kRLckcy6RuFyeGoMA0rFHc)uJ7D8UTkbCX6jkO6yQX9crkn(PMSzvNA0tx90LckfuDm1agwVutVuJGXuJ(uJo1LAYH)TlOLckf0GiDbx70ZKsrlKmQWvI3lFmPENu9xiNQFMTBDpP6NzpROX)AzWXTNM4bf0GiDbx70ZKsrlKmQWDuxTd7Lys9PNjXkEPvyvz1LcAqKUGRD6zsPOfsgv4ovsxq1h5ddLM4NEEQevzPGgePl4ANEMukAHKrfUrRWd)IvI6DsvqKoh2ZqwP5vvwkOuqdI0fCZOcxsDHc)(fRekObr6cUzuH7DzFlSI6WqHvDUVB8V(gU9OR76N7KOENurQ6mkxqR8xEXkX(Ss0W1pF5DbjRoDCs9mM4FwjA4cI70LcAqKUGBgv4Ex23cROomuyvb4UyXhRpvqXxj)u5IF17KQCt9mM4FwjA4QpPQZOCbZ4o854iXpZIfJJJGzNici6PRJJe)mlwPvyVu(jI41txqYQZ8uJu1zuUGw5V8IvI9zLOHRF(Y7cswD64K6zmX)Ss0Wfe3PtkObr6cUzuH7DzFlSI6WqHvDUR81D9Z1zWq)05QeZS6DsfPQZOCbTYF5fRe7Zkrdx)8L3feD64K6zmX)Ss0Wfe90LcAqKUGBgv4Ex23cROomuyvZXHjX5W)61QcQENuPDtjR8xEXkX(Ss0Wv)S4ZXb8sCyOyjX50WzVGX(fRK1YWq7WdhNupJj(NvIgUGKvxkObr6cUzuH7DzFlSI6WqHvflwobKx)hGB9Es9Xr9oPs7Msw5V8IvI9zLOHR(zXNA5QDtj78n(rhqFL8b4YFjy27KJd45DziHTKcoy4Yd)PtCQEcBvcWP6vJe(GiDoCEoodw7Ms2pa369K6JJFWA3uYokxqhNupJj(NvIgUGONUuqdI0fCZOc37Y(wyf1HHcRAQiUXY2Glp8Ksz6kH0f0p4CAcRENubETBkzL)Ylwj27KAGN3LHe2QDQA4RKxWypdzL8Tkb4u9oodw7MswTtvdFL8cg7ziRKV9o54K6zmX)Ss0WfeDsbvhtnG95tnsrnNgYuZDIAcI05ecpOg5BOBSSuJRwWOgW(lVyLqbnisxWnJkCVl7BHvw17KkTBkzL)Ylwj2NvIgU6NfFooGxIddfljoNgo7fm2VyLSwggAhE44K6zmX)Ss0Wfe90LcAqKUGBgv4sIZXhePlO)0ROomuyvKXsbnisxWnJkCjX54dI0f0F6vuhgkSQvuVtQcI05WEgYknVG4okObr6cUzuHljohFqKUG(tVI6WqHvjFtCBXkzvVtQcI05WEgYknV6RhfukObr6cUwYyZOc3rD1oSxIj17KksvNr5cA)yQh(u)S9zLOHliZKHJdPQZOCbTFm1dFQF2(Ss0WfesvNr5cAJwHh(fRe7ZkrdxhNupJj(NvIgUGONUuqdI0fCTKXMrfUA8V87wdNvVtQ0UPKv(lVyLyFwjA4QFw8PwUPEgt8pRenC1Nu1zuUGwn(x(DRHZ2X9dPlyMX9dPlOJtUs8ZSyX44iy2jIaIE664aEjomuSK45094JwXYWq7WJ8YZXj1ZyI)zLOHlizDhf0GiDbxlzSzuHR2PQHpD)8vVtQ0UPKv(lVyLyFwjA4QFw8PwUPEgt8pRenC1Nu1zuUGwTtvdF6(5Bh3pKUGzg3pKUGoo5kXpZIfJJJGzNici6PRJd4L4WqXsINt3JpAflddTdpYlphNupJj(NvIgUGKf)PGgePl4AjJnJkCdiHx5JJNeNJ6DsL2nLSYF5fRe7Zkrdx9ZIp1Yn1ZyI)zLOHR(KQoJYf0gqcVYhhpjoh74(H0fmZ4(H0f0Xjxj(zwSyCCem7erarpDDCaVehgkws8C6E8rRyzyOD4rE554K6zmX)Ss0WfKS4pf0GiDbxlzSzuHBQFw7u1q9oPs7Msw5V8IvI9zLOHR(zXNA5M6zmX)Ss0WvFsvNr5cAt9ZANQg2X9dPlyMX9dPlOJtUs8ZSyX44iy2jIaIE664aEjomuSK45094JwXYWq7WJ8YZXj1ZyI)zLOHli4xkObr6cUwYyZOc3tpJjRhC6oMvyOOENuPDtjR8xEXkXokxqkObr6cUwYyZOcxTy2xjV8nXTv9oPs7Msw5V8IvIDuUGuqdI0fCTKXMrfUphtnC2NoHcVQ3jvA3uYk)LxSsSJYfuTCL4NzXIXXrWSterF3JUoos8ZSyX44iy2jIaIk901XrIFMfR0kSxk)er86PR(Ut38OGgePl4AjJnJkCDv)zKd3q)ZBbdiHvVtQYv(g6gl2aCxS4J1NkO4RKFQCXVLu1zuUG2NvIgU6RNUooGNbh3EAIh2aCxS4J1NkO4RKFQCXVJtQNXe)ZkrdxqKVHUXIna3fl(y9Pck(k5Nkx8BjvDgLlODC)q6cMXD4tnj(zwSyCCem7er0xpDZtTCjvDgLlOv(lVyLyFwjA46NV8UG4ohNC5DziHT50BxqFL8t8NyI0f0Q0W6vl1ZyI)zLOHR(KQoJYfmJ2nLSUQ)mYHBO)5TGbKW2X9dPlyE554K6zmX)Ss0Wfe90LcAqKUGRLm2mQWD(g)OdOVs(aC5Vem17KQCjHpisNd74K6zmX)Ss0WvFsvNr5cMXD6MNA5QDtjR8xEXkXENCCivDgLlOv(lVyLyFwjA4csw8pphNupJj(NvIgUG4USuqdI0fCTKXMrfUFpnDyFd97uqy17KksvNr5cAL)Ylwj2NvIgUGGFOGgePl4AjJnJkCvyL6Z3xj)5s6HF8COSQ3jvGx7Msw5V8IvI9orbnisxW1sgBgv4ovsxq17KkTBkzL)Ylwj2NdIOM2nLSANQgN7k2NdI44ODtjR8xEXkX(Ss0Wv)S4tnj(zwSyCCem7erarpDDCYnxsb3RsODy7ujDb9vYFHAFpo8WNUF(ooKcUxLq7W2lu77XHh(09Zpp1s9mM4FwjA4cc(N1Xj1ZyI)zLOHli6H)5rbnisxW1sgBgv4k)LxSsuVtQ0UPKv(lVyLyhLlOAKQoJYf0(Xup8P(z7ZkrdxhNupJj(NvIgUGKvNuqPGgePl4ALVjUTyLSzuH7OUAh2lXK6DsfPQZOCbTrRWd)IvI9o54qQ6mkxq7ht9WN6NTpRenC1Nu1zuUG2Ov4HFXkX(Ss0WLcAqKUGRv(M42IvYMrfUs8E5Jj17KQ)c5u9ZSDR7jv)m7zfn(xldoU90eputI3lFmzFwjA4cYmzOgPQZOCbTPt8S9zLOHliZKbf0GiDbxR8nXTfRKnJkCtN4z17KQ)c5u9ZSDR7jv)m7zfn(xlddTdputI3lFmzVtuqdI0fCTY3e3wSs2mQW1vFg(DQ)wwkObr6cUw5BIBlwjBgv4MtDoC(uqdI0fCTY3e3wSs2mQW95TGH0WzF8F5IcAqKUGRv(M42IvYMrfUAX)XmtbnisxW1kFtCBXkzZOcxwhMo125W(fRekObr6cUw5BIBlwjBgv4k)LxSsuVtQivDgLlO9JPE4t9Z2NvIgUooPIC3mbr6cA)yQh(u)SLeR4FEMH6NkYDTkHo44K6zmX)Ss0WfKS6KcAqKUGRv(M42IvYMrfUrRWd)IvI6DsL2nLSY3e38lwjR9oPwUA3uYo9mPx2VyLS2r5c64KUNJ)zcw8ZSxAfgesSIxAfoZmz44ODtjR8xEXkXENYJcAqKUGRv(M42IvYMrfUdoempblC7df17KQurUBgsSI)5zgcsQi31Qe6af0GiDbxR8nXTfRKnJkC)yQh(u)S6DsL2nLSY3e38lwjR9oPM2nLSJ6QDyVet2r5csbnisxW1kFtCBXkzZOcxL7r6fRe17KkTBkzLVjU5xSsw7OCbDC0UPKD6zsVSFXkzT3jhNurURossTsgsSI)5zgQFqKUG2Ov4HFXkXsQvOGgePl4ALVjUTyLSzuHRB954xSsuVtQ0UPKDWXWZ5Z2r5csbnisxW1kFtCBXkzZOc3WRC)b)(k5jF5APGgePl4ALVjUTyLSzuHB6e5Zd)Ivcf0GiDbxR8nXTfRKnJkCx(NyO4xPHZQtYNCyVe)mlRQSQ3jvpNEEXcTdtbnisxW1kFtCBXkzZOc3v4yKVFXkHckf0GiDbx7kzuH7kCmY3VyLOENujXHHIDfog57tf5UwggAhEO20Z54NjdBw7kCmY3VyLOM2nLSRWXiFFQi31(Ss0WfeDsbnisxW1Usgv46wFo(fRekObr6cU2vYOc3rD1oSxIjkObr6cU2vYOcxjEV8XK6Ds1FHCQ(z2U19KQFM9SIg)RLbh3EAIhQjX7LpMSpRenCbzMmuJu1zuUG20jE2(Ss0WfKzYGcAqKUGRDLmQWnDINvVtQ(lKt1pZ2TUNu9ZSNv04FTmm0o8qnjEV8XK9orbnisxW1Usgv46Qpd)o1Fllf0GiDbx7kzuHB6e5Zd)Ivcf0GiDbx7kzuH7GdbZtWc3(qr9oPkvK7MHeR4FEMHGKkYDTkHoqbnisxW1Usgv4Y6W0P2oh2VyLqbnisxW1Usgv4MtDoC(Q3jvA3uYo9mPx2VyLS2r5c64aEjomuSeSwj4p8lwjwggAhEqbnisxW1Usgv4gEL7p43xjp5lxlf0GiDbx7kzuH7ZBbdPHZ(4)YL6DsL2nLStpt6L9lwjRDuUGooGxIddflbRvc(d)IvILHH2HhuqdI0fCTRKrfUYF5fRe17KkTBkzNEM0l7xSsw7OCbDCaVehgkwcwRe8h(fRelddTdpOGgePl4AxjJkCJwHh(fRe17KQCt3ZX)mbl(z2lTcdcjwXlTcNzMmCC0UPKv(lVyLyVt5PwUA3uYo9mPx2VyLS2r5c64aEjomuSeSwj4p8lwjwggAhE44qcFqKohophhTBkzLVjU5xSsw7Zkrdx9zDGjxH9sRWQLBqKoh2ZqwP5v)Soo)fYP6Nz7Y)edLvIJB8VE5BIB8NVLbh3EAIh5rbnisxW1Usgv4(Xup8P(z17KkTBkzh1v7WEjMSJYfuTurUBgsSI)5zgcsQi31Qe6af0GiDbx7kzuHlbRvc(d)IvI6DsL2nLStpt6L9lwjR9oPwUA3uYk)LxSsSJYf0XjisNd7ziR08QFwhhWtcFqKohopkObr6cU2vYOc3L)jgk(vA4S6K8jh2lXpZYQkR6Ds1ZPNxSq7WQjXpZIvAf2lLF0S(J7hsxqkObr6cU2vYOcxT4)yMvVtQcI05WEgYknV6NLcAqKUGRDLmQWnEsaz)IvI6DsL2nLStpt6L9lwjR9oPwUA3uYk)LxSsSJYf0Xb8KWhePZHZJcAqKUGRDLmQWnAfE4xSsuVtQ0UPKD6zsVSFXkzTJYfKcAqKUGRDLmQWLG1kb)HFXkr9oPkvK7QpPwjtqKUG2Ov4HFXkXsQvulxTBkzL)Ylwj2r5c64aEs4dI05W5rbnisxW1Usgv4gpjGSFXkr9oPkvK7QpPwjtqKUG2Ov4HFXkXsQvulxTBkzL)Ylwj2r5c64aEs4dI05W5rbnisxW1Usgv4UchJ89lwjQ3jvPIC3mKyf)ZZmeKurURvj0bkObr6cU2vYOcxcwRe8h(fRekObr6cU2vYOc34jbK9lwjiGDIjiC0tN4djibHa]] )
    else
        spec:RegisterPack( "Marksmanship", 20200925.1, [[dGKC6aqiOuEevsytOqFckjmkQuDkQuwfvseVckmlQe7IQ(fkyyqLoMczzOk9mOQAAujPRjKSnOQ4Bqj14GssNdQkzDujvmpH4EOQ2huIdsLuOfII6Hujr5JqjrAKujr6KujLALqrZKkPKBsLu0oHQ8tQKcgkusuTuOKO8uqnvOIVcLeXyPsIQ9c5VuAWuCyrlMkEmstwPUmXMf8zfmAqoTKvtLu1RrrMTIUnQSBv(TudxOoovsLwoWZv10jDDLSDufFxHA8qvPoVqQ1dLQ5Js7hXOriCqW7ufeE8IlV4ocxCXApVJgXl(XQiyn6ybbhNuMYbbbFjNGGDntatpxEpufJGJZONDUr4GG)EbOcc2vqmqQg)UomWWqPqlhpT5y4lU1m1QpkidkdFXrzab7SQP6AFihe8ovbHhV4YlUJWfxS2Z7Or8IFSgbNlfQbiy4IZvgcgQ2B5qoi4T8ueSRGyCntatpxEpuftmUsxNkacMUcIX1avBhbqmyTledV4YlUemjy6kigxlHhzsmr4tmrHRhbpRxFeoiyfuuMEOwFeoi8gHWbbNuT6dbZunN2hQveSCPZu2iMrkcpEr4GGtQw9HG5PNtjAeSCPZu2iMrkcp8JWbbNuT6db7Kaqoiiy5sNPSrmJueEUkcheCs1QpeSGVJN9x8i2hQveSCPZu2iMrkcVOq4GGLlDMYgXmcMckvavIGDwHGxbfLj7d167xXedJednTjvlEeIHrIXzfc(DVCMIvZy)kgbNuT6dbNfNSTpuRifHh(GWbblx6mLnIzemfuQaQeb7ScbVckkt2hQ13VIjggjg3jMe7cOuXhA66LTnuaXlx6mLnXWYsmj2fqPIVoRcjwau0keNhKhtedwiMredllXKyxaLk(FbgQBW(qT(E5sNPSjgwwIrZPCQ)vGKCZ6eVCPZu2eJBi4KQvFiyqgxBBOacsr4H1iCqWYLotzJygbtbLkGkrWoRqWRGIYK9HA99RyIHrIXDIXzfc(yGqRxSpuRVF3JpIHLLyODp394ZNfNSTpuR(WAoTaHcLGbXQfNqmriMKQvF(S4KT9HA1tZxTAXjedllX4ScbVcwYd1QFftmUHGtQw9HGZIt22hQvKIWdRIWbblx6mLnIzemfuQaQeb7ScbVckkt2hQ13VIrWjvR(qWGmU22qbeKIWdFHWbblx6mLnIzemfuQaQeb7ScbVckkt2hQ13V7XhXWYsmoRqWhdeA9I9HA99RyIHrIbBeJZke8kyjpuR(vmXWYsmHMUEIbledwJlcoPA1hcMBn16HAfPi8gHlcheCs1QpeCOPRx22e7cOuX6ijhcwU0zkBeZifH3OriCqWjvR(qWXlqfIUUbRZmFfblx6mLnIzKIWBeViCqWjvR(qW0(OYPGuLTnmtobblx6mLnIzKIWBe(r4GGtQw9HGDMDVTDWQqIvoHlAeSCPZu2iMrkcVrUkcheSCPZu2iMrWuqPcOseSZke8aHY0u(3gAav8RyIHLLyCwHGhiuMMY)2qdOIL2RtfG)1KYeXeHygHlcoPA1hcwHe76C61TTHgqfKIWBuuiCqWjvR(qWPLBb2cW2blf0JFeSCPZu2iMrkcVr4dcheSCPZu2iMrWuqPcOsemqca5HsNPqmmsmyJysQw95FbelNAFTUbFD2WSgGueCs1Qpe8lGy5u7R1nGueEJWAeoi4KQvFi4xLChT9HAfblx6mLnIzKIue8wc5AQiCq4ncHdcoPA1hcM2RtfG9HAfblx6mLnIzKIWJxeoiy5sNPSrmJGtQw9HGNlatc4T191U61BhQGIGPGsfqLiyA3ZDp(8kyjpuREGWL192HL8pXeHygffXWYsmHAasTaHlR7jMied(XfbFjNGGNlatc4T191U61BhQGIueE4hHdcwU0zkBeZi4KQvFi4e7pucY3g6tTDWg3JfacMckvavIGDNyc1aKAbcxw3tmyHysQw9zPDp394JyWGyWVRsmSSeJMGbr9qsoviFmvjMiedV4smSSeJMGbr9AXjwTTXu1YlUeteIzuueJBedJedT75UhFEfSKhQvpq4Y6E7Ws(NyIqmJIIyyzjMqnaPwGWL19eteIb)rHGVKtqWj2FOeKVn0NA7GnUhlaKIWZvr4GGLlDMYgXmcoPA1hcEUEf0R3o0ZTC245IlheemfuQaQebt7EU7XNxbl5HA1deUSU3oSK)jMietuedllXeQbi1ceUSUNyIqm8Ilc(sobbpxVc61Bh65woB8CXLdcsr4ffcheSCPZu2iMrWjvR(qWd5uO5CkG3609HGPGsfqLi4yGWJDGU9J8kyjpuRedllXGnIrZPCQNMZzDdwfsSpuRVxU0zkBIHLLyc1aKAbcxw3tmriMr4IGVKtqWd5uO5CkG3609HueE4dcheSCPZu2iMrWjvR(qW5dXtEYBbj2BGL2GCIGPGsfqLi4yGWJDGU9J8kyjpuRedJeJ7eJZke8dReSR8SDWMyxaTc5xXedllXGnIr(xoQ4P9TL7LTDwbj0aQ45sxFdiggjgAAtQw8ieJBedllXSfNvi4bj2BGL2GCA3IZke87E8rmSSetOgGulq4Y6EIjcXWlUi4l5eeC(q8KN8wqI9gyPniNifHhwJWbblx6mLnIzeCs1QpeCCtzs0VWUST0MlEPPw9z3cpfvqWuqPcOsem2igNvi4vWsEOw9RyIHrIbBeJ8VCuX7m7EB7GvHeRCcx0EU013aIHLLy2IZke8oZU32oyviXkNWfTFftmSSetOgGulq4Y6EIjcXefc(sobbh3uMe9lSlBlT5IxAQvF2TWtrfKIWdRIWbblx6mLnIzemfuQaQebhdeESd0TFKxbl5HALyyzjgSrmAoLt90CoRBWQqI9HA99YLotztmSSetOgGulq4Y6EIjcXWlUi4KQvFi41l2sfUhPi8WxiCqWYLotzJygbNuT6dbtZ50MuT6ZoRxrWZ6v7LCccMUFKIWBeUiCqWYLotzJygbtbLkGkrWjvlEeRCcxjpXeHyWpcoPA1hcMMZPnPA1NDwVIGN1R2l5ee8RifH3OriCqWYLotzJygbtbLkGkrWjvlEeRCcxjpXGfIHxeCs1QpemnNtBs1Qp7SEfbpRxTxYjiyfuuMEOwFKIueCmqOnNtQiCq4ncHdcwU0zkBeZi4yGqZxTAXji4r4IGtQw9HG39YzkwnJrkcpEr4GGLlDMYgXmc(sobbNy)Hsq(2qFQTd24ESaqWjvR(qWj2FOeKVn0NA7GnUhlaKIWd)iCqWjvR(qWJBWCZJuNfiFF5rfeSCPZu2iMrkcpxfHdcoPA1hcEyLGDLNTd2e7cOvieSCPZu2iMrkcVOq4GGtQw9HG5eUgeTTd25IwB7gij3JGLlDMYgXmsr4HpiCqWYLotzJygbhdeA(QvlobbpYhfcoPA1hcwbl5HAfbtbLkGkrWjvlEeRCcxjpXGfIHxKIWdRr4GGLlDMYgXmcoPA1hcoU1Qpe8o6l5kQngiXTIGhHueEyveoiy5sNPSrmJGPGsfqLi4KQfpIvoHRKNyIqm4hbNuT6dbNfNSTpuRifPiy6(r4GWBecheSCPZu2iMrWuqPcOsemT75UhFEqgxBBOaIhiCzDpXeHygOBIHLLyODp394ZdY4ABdfq8aHlR7jMiedT75UhF(S4KT9HA1deUSUNyyzjMqnaPwGWL19eteIHxCrWjvR(qW7E5mfRMXifHhViCqWYLotzJygbtbLkGkrWXaHh7aD7h5vWsEOwjggjg3jMqnaPwGWL19edwigA3ZDp(8oc4fat1n43lqQvFedgeZEbsT6Jyyzjg3jgnbdI6HKCQq(yQsmrigEXLyyzjgSrmAoLt90eiH10MfNxU0zkBIXnIXnIHLLyc1aKAbcxw3tmriMr4hbNuT6db7iGxamv3asr4HFeoiy5sNPSrmJGPGsfqLi4yGWJDGU9J8kyjpuRedJeJ7etOgGulq4Y6EIbledT75UhFENz3BBybI2VxGuR(igmiM9cKA1hXWYsmUtmAcge1dj5uH8XuLyIqm8IlXWYsmyJy0CkN6PjqcRPnloVCPZu2eJBeJBedllXeQbi1ceUSUNyIqmJWheCs1QpeSZS7TnSarJueEUkcheSCPZu2iMrWuqPcOseCmq4Xoq3(rEfSKhQvIHrIXDIjudqQfiCzDpXGfIH29C3JpFEu5vqoT0Co97fi1QpIbdIzVaPw9rmSSeJ7eJMGbr9qsoviFmvjMiedV4smSSed2ignNYPEAcKWAAZIZlx6mLnX4gX4gXWYsmHAasTaHlR7jMieZi8bbNuT6dbNhvEfKtlnNtKIWlkeoiy5sNPSrmJGPGsfqLi4yGWJDGU9J8kyjpuRedJeJ7etOgGulq4Y6EIbledT75UhF(qbeNz3B)EbsT6JyWGy2lqQvFedllX4oXOjyqupKKtfYhtvIjcXWlUedllXGnIrZPCQNMajSM2S48YLotztmUrmUrmSSetOgGulq4Y6EIjcXGVqWjvR(qWHcioZU3ifHh(GWbblx6mLnIzemfuQaQeb7ScbVcwYd1QF3JpeCs1Qpe8SgG0366x7bo5uKIWdRr4GGLlDMYgXmcMckvavIGDwHGxbl5HA1V7XhcoPA1hc2jhSDWQGIY0JueEyveoiy5sNPSrmJGPGsfqLiyNvi4vWsEOw97E8rmmsmUtmAcge1dj5uH8XuLyWcXGvXLyyzjgnbdI6HKCQq(yQsmr4tm8IlXWYsmAcge1RfNy12gtvlV4smyHyWpUeJBi4KQvFiyGKX1nydZKtEKIWdFHWbblx6mLnIzemfuQaQeb7oXq7EU7XNpX(dLG8TH(uBhSX9yb4bcxw3tmyHy4fxIHLLyWgXiUURkow2(e7pucY3g6tTDWg3JfaXWYsmHAasTaHlR7jMiedT75UhF(e7pucY3g6tTDWg3JfGFVaPw9rmyqm43vjggjgnbdI6HKCQq(yQsmyHy4fxIXnIHrIXDIH29C3JpVcwYd1QhiCzDVDyj)tmrig8tmSSeJ7eJ8VCuXZt9vF2oyJfqqOA1NNRUgqmmsmHAasTaHlR7jgSqmjvR(S0UN7E8rmyqmoRqWpUbZnpsDwG89Lhv87fi1QpIXnIXnIHLLyc1aKAbcxw3tmrigEXfbNuT6dbpUbZnpsDwG89LhvqkcVr4IWbblx6mLnIzemfuQaQeb7oXqtBs1IhHyyzjMqnaPwGWL19edwiMKQvFwA3ZDp(igmig8JlX4gXWiX4oX4ScbVcwYd1QFftmSSedT75UhFEfSKhQvpq4Y6EIjcXmcFig3igwwIjudqQfiCzDpXeHyW)ieCs1Qpe8Wkb7kpBhSj2fqRqifH3OriCqWYLotzJygbtbLkGkrW0UN7E85vWsEOw9aHlR7jMiedwJGtQw9HGbvC8uS1z)4KkifH3iEr4GGLlDMYgXmcMckvavIGXgX4ScbVcwYd1QFfJGtQw9HG5eUgeTTd25IwB7gij3JueEJWpcheSCPZu2iMrWuqPcOseSZke8kyjpuREGKuLyyKyCwHG3z29EUE1dKKQedllXedeESd0TFKxbl5HALyyKy0emiQhsYPc5JPkXeHy4fxIHLLyCNyCNyO99lU0zk(4wR(SDWUohqTNY2gwGOjgwwIH23V4sNP4xNdO2tzBdlq0eJBedJetOgGulq4Y6EIjcXGpJigwwIjudqQfiCzDpXeHy4fFig3qWjvR(qWXTw9HueEJCveoiy5sNPSrmJGPGsfqLiyNvi4vWsEOw97E8rmmsm0UN7E85bzCTTHciEGWL19edllXeQbi1ceUSUNyIqmJIcbNuT6dbRGL8qTIuKIGFfHdcVriCqWjvR(qWmvZP9HAfblx6mLnIzKIWJxeoi4KQvFiybFhp7V4rSpuRiy5sNPSrmJueE4hHdcwU0zkBeZiykOubujcoPAXJyLt4k5jgSqmJqWjvR(qWojaKdcsr45QiCqWjvR(qWPLBb2cW2blf0JFeSCPZu2iMrkcVOq4GGtQw9HG5PNtjAeSCPZu2iMrkcp8bHdcwU0zkBeZiykOubujcgibG8qPZuiggjgSrmjvR(8VaILtTVw3GVoBywdqkcoPA1hc(fqSCQ916gqkcpSgHdcwU0zkBeZiykOubujc2zfcEfSKhQv)UhFedllXeA66jMied(JIyyzjMqtxpXeHyWhCjggjgSrmAoLt9trHYP9HA99YLotztmSSeJZke81zviXcGIwH48aHlR7jMieJGVf6sfRwCccoPA1hcgKX12gkGGueEyveoiy5sNPSrmJGPGsfqLiyNvi4vWsEOw9RyIHrIXDIXzfc(1jaqDdwEQV6Z)AszIyWcX4QedllXGnIjXUakv8RtaG6gS8uF1NxU0zkBIXnIHLLyc1aKAbcxw3tmriMrJqWjvR(qWoZU32oyviXkNWfnsr4HVq4GGLlDMYgXmcMckvavIGXgX4ScbVcwYd1QFftmSSetOgGulq4Y6EIjcXefcoPA1hco001lBBIDbuQyDKKdPi8gHlcheSCPZu2iMrWuqPcOseSZke8kyjpuR(vmXWYsmUtmoRqWV7LZuSAg7394JyyzjgAAtQw8ieJBedJeJZke8XaHwVyFOwF)UhFedllXewZPfiuOemiwT4eIjcXqZxTAXjedJedT75UhFEfSKhQvpq4Y6EeCs1QpeCwCY2(qTIueEJgHWbblx6mLnIzemfuQaQebJnIXzfcEfSKhQv)kMyyzjMqnaPwGWL19eteIbRIGtQw9HGJxGkeDDdwNz(ksr4nIxeoiy5sNPSrmJGPGsfqLi4qtxpXGbXeA669azqoIXvcXmq3eteIj00175s8nXWiX4ScbVcwYd1QF3JpIHrIXDIbBeZUvpTpQCkivzBdZKtSolW5bcxw3tmmsmyJysQw95P9rLtbPkBByMCIVoBywdqkX4gXWYsmH1CAbcfkbdIvloHyIqmd0nXWYsmHAasTaHlR7jMietui4KQvFiyAFu5uqQY2gMjNGueEJWpcheSCPZu2iMrWuqPcOseSZke8aHY0u(3gAav8RyIHLLyCwHGhiuMMY)2qdOIL2RtfG)1KYeXeHygHlXWYsmHAasTaHlR7jMietui4KQvFiyfsSRZPx32gAavqkcVrUkcheSCPZu2iMrWuqPcOseSZke8kyjpuR(Dp(iggjg3jgNvi4JbcTEX(qT((vmXWiX4oXeA66jgSqmrffX4gXWYsmHMUEIbledwhfXWYsmHAasTaHlR7jMietueJBi4KQvFi4eqZtSpuRifH3OOq4GGLlDMYgXmcMckvavIGDwHGxbl5HA1V7XhXWiX4oX4ScbFmqO1l2hQ13VIjggjg3jMqtxpXGfIjQOig3igwwIj001tmyHyW6OigwwIjudqQfiCzDpXeHyIIyCdbNuT6dbtHkUuaP9HAfPi8gHpiCqWjvR(qWVk5oA7d1kcwU0zkBeZifPifbZJa(QpeE8IlV4Il(I3O84IVWfR5DecECcU6gEemwjUgXkdpxB8Wk11HyigCGeIP4IBGsmHgqmyf09JvqmaX1DvaztmFZjetU0MlvztmuO8gK3tW01QoHyWxUoeJRS(4raQSjgScfuhtI6DL7PDp394dRGy0MyWkODp394Z7khRGyCNx8TBEcMemDT5IBGkBIjkIjPA1hXmRxFpbteCmOd1uqWUcIX1mbm9C59qvmX4kDDQaiy6kigxduTDeaXG1Uqm8IlV4sWKGPRGyCTeEKjXeHpXefUEcMemDfedw5aHMVsmku9et(eJKGz0et(etC)F5mfIrBIjUv50kNZOjMHSoIjVwHeaXqZxjM9cu3aXOqcXeQbi1tWmPA137JbcT5Csfd(mS7LZuSAg7smqO5RwT4e(JWLGzs1QV3hdeAZ5Kkg8zy9ITuHZLl5e(j2FOeKVn0NA7GnUhlacMjvR(EFmqOnNtQyWNHXnyU5rQZcKVV8OcbZKQvFVpgi0MZjvm4ZWWkb7kpBhSj2fqRqemtQw99(yGqBoNuXGpdCcxdI22b7CrRTDdKK7jyMuT679XaH2CoPIbFguWsEOwDjgi08vRwCc)r(OCPc8tQw8iw5eUsESWlbZKQvFVpgi0MZjvm4ZqCRvFUSJ(sUIAJbsCR8hrWmPA137JbcT5Csfd(mKfNSTpuRUub(jvlEeRCcxjFe8tWKGzs1QVhd(mq71PcW(qTsWmPA13JbFgwVylv4C5soH)CbysaVTUV2vVE7qfuxQaFA3ZDp(8kyjpuREGWL192HL8FKrrXYgQbi1ceUSUpc(XLGzs1QVhd(mSEXwQW5YLCc)e7pucY3g6tTDWg3JfGlvGV7HAasTaHlR7XcT75UhFyGFxLLvtWGOEijNkKpMQr4fxwwnbdI61ItSABJPQLxCJmkk3yK29C3JpVcwYd1QhiCzDVDyj)hzuuSSHAasTaHlR7JG)OiyMuT67XGpdRxSLkCUCjNWFUEf0R3o0ZTC245IlhexQaFA3ZDp(8kyjpuREGWL192HL8FKOyzd1aKAbcxw3hHxCjyMuT67XGpdRxSLkCUCjNWFiNcnNtb8wNUpxQa)yGWJDGU9J8kyjpuRSSytZPCQNMZzDdwfsSpuRVxU0zkBw2qnaPwGWL19rgHlbZKQvFpg8zy9ITuHZLl5e(5dXtEYBbj2BGL2GC6sf4hdeESd0TFKxbl5HALr3DwHGFyLGDLNTd2e7cOvi)kMLfBY)YrfpTVTCVSTZkiHgqfpx66BaJ00MuT4rCJLDloRqWdsS3alTb50UfNvi4394JLnudqQfiCzDFeEXLGzs1QVhd(mSEXwQW5YLCc)4MYKOFHDzBPnx8stT6ZUfEkQ4sf4JnNvi4vWsEOw9RygXM8VCuX7m7EB7GvHeRCcx0EU013aw2T4ScbVZS7TTdwfsSYjCr7xXSSHAasTaHlR7JefbtxbXGdiAIrBIzwNqmRyIjPAXtQYMyuqDmj6tmJlfIyWbSKhQvcMjvR(Em4ZW6fBPc37sf4hdeESd0TFKxbl5HALLfBAoLt90CoRBWQqI9HA99YLotzZYgQbi1ceUSUpcV4sWmPA13JbFgO5CAtQw9zN1RUCjNWNUFcMjvR(Em4ZanNtBs1Qp7SE1Ll5e(V6sf4NuT4rSYjCL8rWpbZKQvFpg8zGMZPnPA1NDwV6YLCcFfuuMEOwFxQa)KQfpIvoHRKhl8sWKGzs1QV3t3pg8zy3lNPy1m2LkWN29C3JppiJRTnuaXdeUSUpYaDZYs7EU7XNhKX12gkG4bcxw3hH29C3JpFwCY2(qT6bcxw3ZYgQbi1ceUSUpcV4sWmPA137P7hd(m4iGxamv3GlvGFmq4Xoq3(rEfSKhQvgDpudqQfiCzDpwODp394Z7iGxamv3GFVaPw9HXEbsT6JL1DnbdI6HKCQq(yQgHxCzzXMMt5upnbsynTzX5LlDMY2n3yzd1aKAbcxw3hze(jyMuT67909JbFgCMDVTHfiAxQa)yGWJDGU9J8kyjpuRm6EOgGulq4Y6ESq7EU7XN3z292gwGO97fi1Qpm2lqQvFSSURjyqupKKtfYht1i8Illl20CkN6PjqcRPnloVCPZu2U5glBOgGulq4Y6(iJWhcMjvR(EpD)yWNH8OYRGCAP5C6sf4hdeESd0TFKxbl5HALr3d1aKAbcxw3JfA3ZDp(85rLxb50sZ50VxGuR(WyVaPw9XY6UMGbr9qsoviFmvJWlUSSytZPCQNMajSM2S48YLotz7MBSSHAasTaHlR7JmcFiyMuT67909JbFgcfqCMDVDPc8Jbcp2b62pYRGL8qTYO7HAasTaHlR7XcT75UhF(qbeNz3B)EbsT6dJ9cKA1hlR7Acge1dj5uH8XuncV4YYInnNYPEAcKWAAZIZlx6mLTBUXYgQbi1ceUSUpc(IGzs1QV3t3pg8zywdq6BD9R9aNCQlvGVZke8kyjpuR(Dp(iyMuT67909JbFgCYbBhSkOOm9Uub(oRqWRGL8qT6394JGzs1QV3t3pg8zaizCDd2Wm5K3LkW3zfcEfSKhQv)UhFm6UMGbr9qsoviFmvXcwfxwwnbdI6HKCQq(yQgHpV4YYQjyquVwCIvBBmvT8IlwWpUUrWmPA137P7hd(mmUbZnpsDwG89LhvCPc8Dxb1XKO(e7pucY3g6tTDWg3JfGN29C3Jppq4Y6ESWlUSSytCDxvCSS9j2FOeKVn0NA7GnUhlaw2qnaPwGWL19ruqDmjQpX(dLG8TH(uBhSX9yb4PDp394ZVxGuR(Wa)UkJAcge1dj5uH8Xufl8IRBm6oT75UhFEfSKhQvpq4Y6E7Ws(pc(zzDx(xoQ45P(QpBhSXciiuT6ZZvxdymudqQfiCzDpwODp394ddNvi4h3G5MhPolq((YJk(9cKA1NBUXYgQbi1ceUSUpcV4sWmPA137P7hd(mmSsWUYZ2bBIDb0kKlvGV700MuT4ryzd1aKAbcxw3JfA3ZDp(Wa)46gJU7ScbVcwYd1QFfZYs7EU7XNxbl5HA1deUSUpYi8Xnw2qnaPwGWL19rW)icMjvR(EpD)yWNbqfhpfBD2poPIlvGpT75UhFEfSKhQvpq4Y6(iynbZKQvFVNUFm4ZaNW1GOTDWox0AB3aj5ExQaFS5ScbVcwYd1QFftWmPA137P7hd(me3A1NlvGVZke8kyjpuREGKuLrNvi4DMDVNRx9ajPklBmq4Xoq3(rEfSKhQvg1emiQhsYPc5JPAeEXLL1D3P99lU0zk(4wR(SDWUohqTNY2gwGOzzP99lU0zk(15aQ9u22WceTBmgQbi1ceUSUpc(mILnudqQfiCzDFeEXh3iyMuT67909JbFguWsEOwDPc8DwHGxbl5HA1V7XhJ0UN7E85bzCTTHciEGWL19SSHAasTaHlR7JmkkcMemtQw99(xXGpdmvZP9HALGzs1QV3)kg8zqW3XZ(lEe7d1kbZKQvFV)vm4ZGtca5G4sf4NuT4rSYjCL8yzebZKQvFV)vm4ZqA5wGTaSDWsb94NGzs1QV3)kg8zGNEoLOjyMuT679VIbFgEbelNAFTUbxQaFGeaYdLotHrSLuT6Z)ciwo1(ADd(6SHznaPemtQw99(xXGpdGmU22qbexQaFNvi4vWsEOw97E8XYgA66JG)OyzdnD9rWhCzeBAoLt9trHYP9HA99YLotzZY6ScbFDwfsSaOOviopq4Y6(ic(wOlvSAXjemtQw99(xXGpdoZU32oyviXkNWfTlvGVZke8kyjpuR(vmJU7Scb)6eaOUblp1x95FnPmHfxLLfBj2fqPIFDcau3GLN6R(8YLotz7glBOgGulq4Y6(iJgrWmPA137Ffd(meA66LTnXUakvSosY5sf4JnNvi4vWsEOw9Ryw2qnaPwGWL19rIIGzs1QV3)kg8zilozBFOwDPc8DwHGxbl5HA1VIzzD3zfc(DVCMIvZy)UhFSS00MuT4rCJrNvi4JbcTEX(qT((Dp(yzdR50cekucgeRwCseA(QvloHrA3ZDp(8kyjpuREGWL19emtQw99(xXGpdXlqfIUUbRZmF1LkWhBoRqWRGL8qT6xXSSHAasTaHlR7JGvjyMuT679VIbFgO9rLtbPkBByMCIlvGFOPRhJqtxVhidY5kzGUJeA669Cj(MrNvi4vWsEOw97E8XO7yB3QN2hvofKQSTHzYjwNf48aHlR7zeBjvR(80(OYPGuLTnmtoXxNnmRbi1nw2WAoTaHcLGbXQfNezGUzzd1aKAbcxw3hjkcMjvR(E)RyWNbfsSRZPx32gAavCPc8DwHGhiuMMY)2qdOIFfZY6ScbpqOmnL)THgqflTxNka)RjLPiJWLLnudqQfiCzDFKOiyMuT679VIbFgsanpX(qT6sf47ScbVcwYd1QF3JpgD3zfc(yGqRxSpuRVFfZO7HMUESevuUXYgA66XcwhflBOgGulq4Y6(ir5gbZKQvFV)vm4ZafQ4sbK2hQvxQaFNvi4vWsEOw97E8XO7oRqWhdeA9I9HA99RygDp001JLOIYnw2qtxpwW6Oyzd1aKAbcxw3hjk3iyMuT679VIbFgEvYD02hQvcMemtQw99EfuuMEOwFm4Zat1CAFOwjyMuT679kOOm9qT(yWNbE65uIMGzs1QV3RGIY0d16JbFgCsaihecMjvR(EVckktpuRpg8zqW3XZ(lEe7d1kbZKQvFVxbfLPhQ1hd(mKfNSTpuRUub(oRqWRGIYK9HA99RygPPnPAXJWOZke87E5mfRMX(vmbZKQvFVxbfLPhQ1hd(maY4ABdfqCPc8DwHGxbfLj7d167xXm6EIDbuQ4dnD9Y2gkG4LlDMYMLnXUakv81zviXcGIwH48G8yclJyztSlGsf)Vad1nyFOwFVCPZu2SSAoLt9VcKKBwN4LlDMY2ncMjvR(EVckktpuRpg8zilozBFOwDPc8DwHGxbfLj7d167xXm6UZke8XaHwVyFOwF)UhFSS0UN7E85ZIt22hQvFynNwGqHsWGy1ItIKuT6ZNfNSTpuREA(QvloHL1zfcEfSKhQv)k2ncMjvR(EVckktpuRpg8zaKX12gkG4sf47ScbVckkt2hQ13VIjyMuT679kOOm9qT(yWNbU1uRhQvxQaFNvi4vqrzY(qT((Dp(yzDwHGpgi06f7d167xXmInNvi4vWsEOw9Ryw2qtxpwWACjyMuT679kOOm9qT(yWNHqtxVSTj2fqPI1rsocMjvR(EVckktpuRpg8ziEbQq01nyDM5RemtQw99EfuuMEOwFm4ZaTpQCkivzBdZKtiyMuT679kOOm9qT(yWNbNz3BBhSkKyLt4IMGzs1QV3RGIY0d16JbFguiXUoNEDBBObuXLkW3zfcEGqzAk)BdnGk(vmlRZke8aHY0u(3gAavS0EDQa8VMuMImcxcMjvR(EVckktpuRpg8ziTClWwa2oyPGE8tWmPA137vqrz6HA9XGpdVaILtTVw3GlvGpqca5HsNPWi2sQw95FbelNAFTUbFD2WSgGucMjvR(EVckktpuRpg8z4vj3rBFOwrWFSqr4XBuUksrkcb]] )
    end

end