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
        spec:RegisterPack( "Marksmanship", 20201012.9, [[dCKR9aqiGQEePc1MiP8jQuvnkrLoLOkVsumlsQUfPcr7Is)cQ0Wiv6yIslJuLNrLktdQkxJurBdQQ6BqvfJJkvX5GQkToQuvmpG4EKK9rQQdcurvleQYdjvi8rGkknssfsDsQuvALaPzsLQKUjvQsTtOIFsLQelfOIkpfWubkFfOIIXsQqYEH8xQAWuCyHftkpgXKv4YO2SiFwrnAOCAPwnqf51uPmBvCBsSBq)wYWvKJduHLRQNR00jUUkTDrfFNkz8Kk48IQA9avA(uX(rAuweyiGrimch90vpDZQB2S2S4dF6eF4pcqYFIratbXTyMraWqHraU3X72QeWfRNqatr(NkgiWqaBDFcJa0XudMitR7dU4o3c2vZskfC3w5EcPli5JKG72keCraA3(iUVqKgcyecJWrpD1t3S6MnRnl(WNoXNoraXvWQhba0k6iqay9yWqKgcyWlbbOJPg374DBvc4I1tuJo6lu4NcQoMACVqKsJFQjBw1Pg90vpDPGsbvhtnGH1l10l1iym1C4C4d1Op1OtDPMC4F7cAraNELfbgcq(M42IvYIadHtweyiaggAhEGWdbq(w4VdeaPQZOCbTrRWd)IvI9ornooudPQZOCbTFm1dFQF2(Ss0WLA0NAivDgLlOnAfE4xSsSpRenCrabr6cIag1v7WEjMqcch9qGHayyOD4bcpea5BH)oqa)fYP6Nz7w3tQ(z2ZkA8VwgCC7PjEqnQrns8E5Jj7ZkrdxQbeQzMmOg1OgsvNr5cAtN4z7ZkrdxQbeQzMmqabr6cIaK49YhtibHJ7qGHayyOD4bcpea5BH)oqa)fYP6Nz7w3tQ(z2ZkA8VwggAhEqnQrns8E5Jj7DcbeePliciDINrcch8HadbeePlicWvFg(DQ)wweaddTdpq4Heeo6ebgciisxqeqo15W5JayyOD4bcpKGWb)rGHacI0feb88wWqA4Sp(VCHayyOD4bcpKGWb)GadbeePlicql(pMzeaddTdpq4HeeoUheyiGGiDbraSomDQTZH9lwjiaggAhEGWdjiCWViWqamm0o8aHhcG8TWFhiasvNr5cA)yQh(u)S9zLOHl144qnPICxQjd1eePlO9JPE4t9ZwsSI)5zgsn6tnPICxRsOduJJd1K6zmX)Ss0WLAaHAYQteqqKUGia5V8Ivcsq4KvxeyiaggAhEGWdbq(w4VdeG2nLSY3e38lwjR9ornQrn5snA3uYo9mPx2VyLS2r5csnoout6Eo(NjyXpZEPvyQbeQHeR4LwHPMmuZmzqnoouJ2nLSYF5fRe7DIAYdbeePliciAfE4xSsqccNSzrGHayyOD4bcpea5BH)oqaPICxQjd1qIv8ppZqQbeQjvK7AvcDabeePlicyWHG5jyHBFOGeeoz1dbgcGHH2Hhi8qaKVf(7abODtjR8nXn)IvYAVtuJAuJ2nLSJ6QDyVet2r5cIacI0feb8Xup8P(zKGWjR7qGHayyOD4bcpea5BH)oqaA3uYkFtCZVyLS2r5csnoouJ2nLStpt6L9lwjR9ornooutQi3LA0rsnKAfQjd1qIv8ppZqQrFQjisxqB0k8WVyLyj1kiGGiDbrak3J0lwjibHtw8HadbWWq7WdeEiaY3c)DGa0UPKDWXWZ5Z2r5cIacI0feb4wFo(fReKGWjRorGHacI0febeEL7p43xjp5lxlcGHH2Hhi8qccNS4pcmeqqKUGiG0jYNh(fReeaddTdpq4HeeozXpiWqamm0o8aHhciisxqeWY)edf)knCgbq(w4VdeWZPNxSq7Wias(Kd7L4Nzzr4KfjiCY6EqGHacI0febSchJ89lwjiaggAhEGWdjibbm4uCpccmeozrGHacI0febqQlu43VyLGayyOD4bcpKGWrpeyiaggAhEGWdbeePlic4CF34F9nC7rx31p3jbbq(w4VdeaPQZOCbTYF5fRe7Zkrdx)8L3LAaHAYQtQXXHAs9mM4FwjA4snGqnUtxeamuyeW5(UX)6B42JUURFUtcsq44oeyiaggAhEGWdbeePlicia3fl(y9Pck(k5Nkx8JaiFl83bcixQj1ZyI)zLOHl1Op1eePlONu1zuUGutgQXD4JACCOgj(zwSyCCem7erOgqOg90LACCOgj(zwSsRWEP8teXRNUudiutwDsn5rnQrnKQoJYf0k)LxSsSpRenC9ZxExQbeQjRoPghhQj1ZyI)zLOHl1ac14oDIaGHcJacWDXIpwFQGIVs(PYf)ibHd(qGHayyOD4bcpeqqKUGiGZDLVURFUodg6NoxLyMraKVf(7abqQ6mkxqR8xEXkX(Ss0W1pF5DPgqOgDsnooutQNXe)ZkrdxQbeQrpDraWqHraN7kFDx)CDgm0pDUkXmJeeo6ebgcGHH2Hhi8qabr6cIaMJdtIZH)1Rvfebq(w4VdeG2nLSYF5fRe7ZkrdxQrFQjl(OghhQb8uJehgkwsConC2lySFXkzTmm0o8GACCOMupJj(NvIgUudiutwDraWqHraZXHjX5W)61QcIeeo4pcmeaddTdpq4HacI0febelwobKx)hGB9Es9Xbbq(w4VdeG2nLSYF5fRe7ZkrdxQrFQjl(Og1OMCPgTBkzNVXp6a6RKpax(lbZENOghhQb8udVldjSLuWbdxE4pDIt1tyRsaovp1Og1qcFqKohMAYJACCOMbRDtj7hGB9Es9XXpyTBkzhLli144qnPEgt8pRenCPgqOg90fbadfgbelwobKx)hGB9Es9XbjiCWpiWqamm0o8aHhciisxqeWurCJLTbxE4jLY0vcPlOFW50egbq(w4Vdea4PgTBkzL)Ylwj27e1Og1aEQH3LHe2QDQA4RKxWypdzL8Tkb4u9uJJd1myTBkz1ovn8vYlySNHSs(27e144qnPEgt8pRenCPgqOgDIaGHcJaMkIBSSn4YdpPuMUsiDb9doNMWibHJ7bbgcGHH2Hhi8qaKVf(7abODtjR8xEXkX(Ss0WLA0NAYIpQXXHAap1iXHHILeNtdN9cg7xSswlddTdpOghhQj1ZyI)zLOHl1ac1ONUiGGiDbra3L9TWklsq4GFrGHayyOD4bcpeqqKUGiasCo(GiDb9NEfeWPxXddfgbqglsq4KvxeyiaggAhEGWdbq(w4VdeqqKoh2ZqwP5LAaHAChciisxqeajohFqKUG(tVcc40R4HHcJawbjiCYMfbgcGHH2Hhi8qaKVf(7abeePZH9mKvAEPg9Pg9qabr6cIaiX54dI0f0F6vqaNEfpmuyeG8nXTfRKfjibbm9mPu0cbbgcNSiWqamm0o8aHhcG8TWFhiG)c5u9ZSDR7jv)m7zfn(xldoU90epqabr6cIaK49YhtibHJEiWqamm0o8aHhcy6zsSIxAfgbKvxeqqKUGiGrD1oSxIjKGWXDiWqamm0o8aHhciisxqeWujDbraJ8HHst8tppvccilsq4GpeyiaggAhEGWdbq(w4VdeqqKoh2ZqwP5LAurnzrabr6cIaIwHh(fReKGeeazSiWq4KfbgcGHH2Hhi8qaKVf(7abqQ6mkxq7ht9WN6NTpRenCPgqOMzYGACCOgsvNr5cA)yQh(u)S9zLOHl1ac1qQ6mkxqB0k8WVyLyFwjA4snooutQNXe)ZkrdxQbeQrpDrabr6cIag1v7WEjMqcch9qGHayyOD4bcpea5BH)oqaA3uYk)LxSsSpRenCPg9PMS4JAuJAYLAs9mM4FwjA4sn6tnKQoJYf0QX)YVBnC2oUFiDbPMmuZ4(H0fKACCOMCPgj(zwSyCCem7erOgqOg90LACCOgWtnsCyOyjXZP7XhTILHH2HhutEutEuJJd1K6zmX)Ss0WLAaHAY6oeqqKUGian(x(DRHZibHJ7qGHayyOD4bcpea5BH)oqaA3uYk)LxSsSpRenCPg9PMS4JAuJAYLAs9mM4FwjA4sn6tnKQoJYf0QDQA4t3pF74(H0fKAYqnJ7hsxqQXXHAYLAK4NzXIXXrWSteHAaHA0txQXXHAap1iXHHILepNUhF0kwggAhEqn5rn5rnooutQNXe)ZkrdxQbeQjl(JacI0febODQA4t3pFKGWbFiWqamm0o8aHhcG8TWFhiaTBkzL)Ylwj2NvIgUuJ(utw8rnQrn5snPEgt8pRenCPg9PgsvNr5cAdiHx5JJNeNJDC)q6csnzOMX9dPli144qn5sns8ZSyX44iy2jIqnGqn6Pl144qnGNAK4WqXsINt3JpAflddTdpOM8OM8OghhQj1ZyI)zLOHl1ac1Kf)rabr6cIaciHx5JJNeNdsq4OteyiaggAhEGWdbq(w4VdeG2nLSYF5fRe7ZkrdxQrFQjl(Og1OMCPMupJj(NvIgUuJ(udPQZOCbTP(zTtvd74(H0fKAYqnJ7hsxqQXXHAYLAK4NzXIXXrWSteHAaHA0txQXXHAap1iXHHILepNUhF0kwggAhEqn5rn5rnooutQNXe)ZkrdxQbeQb)IacI0febK6N1ovnqcch8hbgcGHH2Hhi8qaKVf(7abODtjR8xEXkXokxqeqqKUGiGtpJjRhC6oMvyOGeeo4heyiaggAhEGWdbq(w4VdeG2nLSYF5fRe7OCbrabr6cIa0IzFL8Y3e3wKGWX9GadbWWq7WdeEiaY3c)DGa0UPKv(lVyLyhLli1Og1Kl1iXpZIfJJJGzNic1Op14E0LACCOgj(zwSyCCem7erOgqurn6Pl144qns8ZSyLwH9s5NiIxpDPg9Pg3Pl1KhciisxqeWZXudN9PtOWlsq4GFrGHayyOD4bcpea5BH)oqa5snKQoJYf0gG7IfFS(ubfFL8tLl(TpRenCPg9Pg90LACCOgWtnm442tt8WgG7IfFS(ubfFL8tLl(PghhQj1ZyI)zLOHl1ac1qQ6mkxqBaUlw8X6tfu8vYpvU43oUFiDbPMmuJ7Wh1Og1iXpZIfJJJGzNic1Op1ONUutEuJAutUudPQZOCbTYF5fRe7Zkrdx)8L3LAaHACh144qn5sn8UmKW2C6TlOVs(j(tmr6cAvAy9uJAutQNXe)ZkrdxQrFQjisxqpPQZOCbPMmuJ2nLSUQ)mYHBO)5TGbKW2X9dPli1Kh1Kh144qnPEgt8pRenCPgqOg90fbeePlicWv9NroCd9pVfmGegjiCYQlcmeaddTdpq4HaiFl83bcixQHe(GiDom144qnPEgt8pRenCPg9PMGiDb9KQoJYfKAYqnUtxQjpQrnQjxQr7Msw5V8IvI9ornooudPQZOCbTYF5fRe7ZkrdxQbeQjl(tn5rnooutQNXe)ZkrdxQbeQXDzrabr6cIaMVXp6a6RKpax(lbdjiCYMfbgcGHH2Hhi8qaKVf(7abqQ6mkxqR8xEXkX(Ss0WLAaHAWpiGGiDbraFpnDyFd97uqyKGWjREiWqamm0o8aHhcG8TWFhiaWtnA3uYk)LxSsS3jeqqKUGiafwP(89vYFUKE4hphklsq4K1DiWqamm0o8aHhcG8TWFhiaTBkzL)Ylwj2NdIqnQrnA3uYQDQACURyFoic144qnA3uYk)LxSsSpRenCPg9PMS4JAuJAK4NzXIXXrWSteHAaHA0txQXXHAYLAYLAifCVkH2HTtL0f0xj)fQ994WdF6(5tnooudPG7vj0oS9c1(EC4HpD)8PM8Og1OMupJj(NvIgUudiud(NLACCOMupJj(NvIgUudiuJE4p1KhciisxqeWujDbrccNS4dbgcGHH2Hhi8qaKVf(7abODtjR8xEXkXokxqQrnQHu1zuUG2pM6Hp1pBFwjA4snooutQNXe)ZkrdxQbeQjRorabr6cIaK)YlwjibjiGvqGHWjlcmeaddTdpq4HaiFl83bcqIddf7kCmY3NkYDTmm0o8GAuJAMEoh)mzyZAxHJr((fReQrnQr7Ms2v4yKVpvK7AFwjA4snGqn6ebeePlicyfog57xSsqcch9qGHacI0feb4wFo(fReeaddTdpq4HeeoUdbgciisxqeWOUAh2lXecGHH2Hhi8qcch8HadbWWq7WdeEiaY3c)DGa(lKt1pZ2TUNu9ZSNv04FTm442tt8GAuJAK49Yht2NvIgUudiuZmzqnQrnKQoJYf0MoXZ2NvIgUudiuZmzGacI0febiX7LpMqcchDIadbWWq7WdeEiaY3c)DGa(lKt1pZ2TUNu9ZSNv04FTmm0o8GAuJAK49Yht27eciisxqeq6epJeeo4pcmeqqKUGiax9z43P(Bzramm0o8aHhsq4GFqGHacI0febKor(8WVyLGayyOD4bcpKGWX9GadbWWq7WdeEiaY3c)DGasf5UutgQHeR4FEMHudiutQi31Qe6aciisxqeWGdbZtWc3(qbjiCWViWqabr6cIayDy6uBNd7xSsqamm0o8aHhsq4KvxeyiaggAhEGWdbq(w4VdeG2nLStpt6L9lwjRDuUGuJJd1aEQrIddflbRvc(d)IvILHH2HhiGGiDbra5uNdNpsq4KnlcmeqqKUGiGWRC)b)(k5jF5Aramm0o8aHhsq4KvpeyiaggAhEGWdbq(w4VdeG2nLStpt6L9lwjRDuUGuJJd1aEQrIddflbRvc(d)IvILHH2HhiGGiDbrapVfmKgo7J)lxibHtw3HadbWWq7WdeEiaY3c)DGa0UPKD6zsVSFXkzTJYfKACCOgWtnsCyOyjyTsWF4xSsSmm0o8abeePlicq(lVyLGeeozXhcmeaddTdpq4HaiFl83bcixQjDph)ZeS4NzV0km1ac1qIv8sRWutgQzMmOghhQr7Msw5V8IvI9orn5rnQrn5snA3uYo9mPx2VyLS2r5csnooud4PgjomuSeSwj4p8lwjwggAhEqnooudj8br6CyQjpQXXHA0UPKv(M4MFXkzTpRenCPg9PgwhyYvyV0km1Og1Kl1eePZH9mKvAEPg9PMSuJJd18xiNQFMTl)tmuwjoUX)6LVjUXF(wgCC7PjEqn5HacI0febeTcp8lwjibHtwDIadbWWq7WdeEiaY3c)DGa0UPKDuxTd7LyYokxqQrnQjvK7snzOgsSI)5zgsnGqnPICxRsOdiGGiDbraFm1dFQFgjiCYI)iWqamm0o8aHhcG8TWFhiaTBkzNEM0l7xSsw7DIAuJAYLA0UPKv(lVyLyhLli144qnbr6CypdzLMxQrFQjl144qnGNAiHpisNdtn5HacI0febqWALG)WVyLGeeozXpiWqamm0o8aHhciisxqeWY)edf)knCgbq(w4VdeWZPNxSq7WuJAuJe)mlwPvyVu(rZuJ(uZ4(H0febqYNCyVe)mllcNSibHtw3dcmeaddTdpq4HaiFl83bciisNd7ziR08sn6tnzrabr6cIa0I)JzgjiCYIFrGHayyOD4bcpea5BH)oqaA3uYo9mPx2VyLS27e1Og1Kl1ODtjR8xEXkXokxqQXXHAap1qcFqKohMAYdbeePliciEsaz)Ivcsq4ONUiWqamm0o8aHhcG8TWFhiaTBkzNEM0l7xSsw7OCbrabr6cIaIwHh(fReKGWrVSiWqamm0o8aHhcG8TWFhiGurUl1Op1qQvOMmutqKUG2Ov4HFXkXsQvOg1OMCPgTBkzL)Ylwj2r5csnooud4Pgs4dI05WutEiGGiDbraeSwj4p8lwjibHJE6HadbWWq7WdeEiaY3c)DGasf5UuJ(udPwHAYqnbr6cAJwHh(fRelPwHAuJAYLA0UPKv(lVyLyhLli144qnGNAiHpisNdtn5HacI0febepjGSFXkbjiC0ZDiWqamm0o8aHhcG8TWFhiGurUl1KHAiXk(NNzi1ac1KkYDTkHoGacI0febSchJ89lwjibHJE4dbgciisxqeabRvc(d)IvccGHH2Hhi8qcch90jcmeqqKUGiG4jbK9lwjiaggAhEGWdjibjiGC4F7cIWrpD1t3S6Ql(XIFraUIh2W5fbaod48GZHJ7loGZ6(qnudyym10kt1lutQEQX9tgR7NAEgCC7NhuZwkm1exPucHhudblGZ8APG6ETHm1GFDFOgDefmh(fEqnUF5BOBSy1rzjvDgLlO7NAKIAC)KQoJYf0QJY9tn5QNoKNLckfu3xLP6fEqn6KAcI0fKAo9kRLckcy6RuFyeGoMA0rFHc)uJ7D8UTkbCX6jkO6yQX9crkn(PMSzvNA0tx90LckfuDm1agwVutVuJGXuJ(uJo1LAYH)TlOLckf0GiDbx70ZKsrlKmQWvI3lFmPENu9xiNQFMTBDpP6NzpROX)AzWXTNM4bf0GiDbx70ZKsrlKmQWDuxTd7Lys9PNjXkEPvyvz1LcAqKUGRD6zsPOfsgv4ovsxq1h5ddLM4NEEQevzPGgePl4ANEMukAHKrfUrRWd)IvI6DsvqKoh2ZqwP5vvwkOuqdI0fCZOcxsDHc)(fRekObr6cUzuH7DzFlSI6WqHvDUVB8V(gU9OR76N7KOENurQ6mkxqR8xEXkX(Ss0W1pF5DbjRoDCs9mM4FwjA4cI70LcAqKUGBgv4Ex23cROomuyvb4UyXhRpvqXxj)u5IF17KQCt9mM4FwjA4QpPQZOCbZ4o854iXpZIfJJJGzNici6PRJJe)mlwPvyVu(jI41txqYQZ8uJu1zuUGw5V8IvI9zLOHRF(Y7cswD64K6zmX)Ss0Wfe3PtkObr6cUzuH7DzFlSI6WqHvDUR81D9Z1zWq)05QeZS6DsfPQZOCbTYF5fRe7Zkrdx)8L3feD64K6zmX)Ss0Wfe90LcAqKUGBgv4Ex23cROomuyvZXHjX5W)61QcQENuPDtjR8xEXkX(Ss0Wv)S4ZXb8sCyOyjX50WzVGX(fRK1YWq7WdhNupJj(NvIgUGKvxkObr6cUzuH7DzFlSI6WqHvflwobKx)hGB9Es9Xr9oPs7Msw5V8IvI9zLOHR(zXNA5QDtj78n(rhqFL8b4YFjy27KJd45DziHTKcoy4Yd)PtCQEcBvcWP6vJe(GiDoCEoodw7Ms2pa369K6JJFWA3uYokxqhNupJj(NvIgUGONUuqdI0fCZOc37Y(wyf1HHcRAQiUXY2Glp8Ksz6kH0f0p4CAcRENubETBkzL)Ylwj27KAGN3LHe2QDQA4RKxWypdzL8Tkb4u9oodw7MswTtvdFL8cg7ziRKV9o54K6zmX)Ss0WfeDsbvhtnG95tnsrnNgYuZDIAcI05ecpOg5BOBSSuJRwWOgW(lVyLqbnisxWnJkCVl7BHvw17KkTBkzL)Ylwj2NvIgU6NfFooGxIddfljoNgo7fm2VyLSwggAhE44K6zmX)Ss0Wfe90LcAqKUGBgv4sIZXhePlO)0ROomuyvKXsbnisxWnJkCjX54dI0f0F6vuhgkSQvuVtQcI05WEgYknVG4okObr6cUzuHljohFqKUG(tVI6WqHvjFtCBXkzvVtQcI05WEgYknV6RhfukObr6cUwYyZOc3rD1oSxIj17KksvNr5cA)yQh(u)S9zLOHliZKHJdPQZOCbTFm1dFQF2(Ss0WfesvNr5cAJwHh(fRe7ZkrdxhNupJj(NvIgUGONUuqdI0fCTKXMrfUA8V87wdNvVtQ0UPKv(lVyLyFwjA4QFw8PwUPEgt8pRenC1Nu1zuUGwn(x(DRHZ2X9dPlyMX9dPlOJtUs8ZSyX44iy2jIaIE664aEjomuSK45094JwXYWq7WJ8YZXj1ZyI)zLOHlizDhf0GiDbxlzSzuHR2PQHpD)8vVtQ0UPKv(lVyLyFwjA4QFw8PwUPEgt8pRenC1Nu1zuUGwTtvdF6(5Bh3pKUGzg3pKUGoo5kXpZIfJJJGzNici6PRJd4L4WqXsINt3JpAflddTdpYlphNupJj(NvIgUGKf)PGgePl4AjJnJkCdiHx5JJNeNJ6DsL2nLSYF5fRe7Zkrdx9ZIp1Yn1ZyI)zLOHR(KQoJYf0gqcVYhhpjoh74(H0fmZ4(H0f0Xjxj(zwSyCCem7erarpDDCaVehgkws8C6E8rRyzyOD4rE554K6zmX)Ss0WfKS4pf0GiDbxlzSzuHBQFw7u1q9oPs7Msw5V8IvI9zLOHR(zXNA5M6zmX)Ss0WvFsvNr5cAt9ZANQg2X9dPlyMX9dPlOJtUs8ZSyX44iy2jIaIE664aEjomuSK45094JwXYWq7WJ8YZXj1ZyI)zLOHli4xkObr6cUwYyZOc3tpJjRhC6oMvyOOENuPDtjR8xEXkXokxqkObr6cUwYyZOcxTy2xjV8nXTv9oPs7Msw5V8IvIDuUGuqdI0fCTKXMrfUphtnC2NoHcVQ3jvA3uYk)LxSsSJYfuTCL4NzXIXXrWSterF3JUoos8ZSyX44iy2jIaIk901XrIFMfR0kSxk)er86PR(Ut38OGgePl4AjJnJkCDv)zKd3q)ZBbdiHvVtQYv(g6gl2aCxS4J1NkO4RKFQCXVLu1zuUG2NvIgU6RNUooGNbh3EAIh2aCxS4J1NkO4RKFQCXVJtQNXe)ZkrdxqKVHUXIna3fl(y9Pck(k5Nkx8BjvDgLlODC)q6cMXD4tnj(zwSyCCem7er0xpDZtTCjvDgLlOv(lVyLyFwjA46NV8UG4ohNC5DziHT50BxqFL8t8NyI0f0Q0W6vl1ZyI)zLOHR(KQoJYfmJ2nLSUQ)mYHBO)5TGbKW2X9dPlyE554K6zmX)Ss0Wfe90LcAqKUGRLm2mQWD(g)OdOVs(aC5Vem17KQCjHpisNd74K6zmX)Ss0WvFsvNr5cMXD6MNA5QDtjR8xEXkXENCCivDgLlOv(lVyLyFwjA4csw8pphNupJj(NvIgUG4USuqdI0fCTKXMrfUFpnDyFd97uqy17KksvNr5cAL)Ylwj2NvIgUGGFOGgePl4AjJnJkCvyL6Z3xj)5s6HF8COSQ3jvGx7Msw5V8IvI9orbnisxW1sgBgv4ovsxq17KkTBkzL)Ylwj2NdIOM2nLSANQgN7k2NdI44ODtjR8xEXkX(Ss0Wv)S4tnj(zwSyCCem7erarpDDCYnxsb3RsODy7ujDb9vYFHAFpo8WNUF(ooKcUxLq7W2lu77XHh(09Zpp1s9mM4FwjA4cc(N1Xj1ZyI)zLOHli6H)5rbnisxW1sgBgv4k)LxSsuVtQ0UPKv(lVyLyhLlOAKQoJYf0(Xup8P(z7ZkrdxhNupJj(NvIgUGKvNuqPGgePl4ALVjUTyLSzuH7OUAh2lXK6DsfPQZOCbTrRWd)IvI9o54qQ6mkxq7ht9WN6NTpRenC1Nu1zuUG2Ov4HFXkX(Ss0WLcAqKUGRv(M42IvYMrfUs8E5Jj17KQ)c5u9ZSDR7jv)m7zfn(xldoU90eputI3lFmzFwjA4cYmzOgPQZOCbTPt8S9zLOHliZKbf0GiDbxR8nXTfRKnJkCtN4z17KQ)c5u9ZSDR7jv)m7zfn(xlddTdputI3lFmzVtuqdI0fCTY3e3wSs2mQW1vFg(DQ)wwkObr6cUw5BIBlwjBgv4MtDoC(uqdI0fCTY3e3wSs2mQW95TGH0WzF8F5IcAqKUGRv(M42IvYMrfUAX)XmtbnisxW1kFtCBXkzZOcxwhMo125W(fRekObr6cUw5BIBlwjBgv4k)LxSsuVtQivDgLlO9JPE4t9Z2NvIgUooPIC3mbr6cA)yQh(u)SLeR4FEMH6NkYDTkHo44K6zmX)Ss0WfKS6KcAqKUGRv(M42IvYMrfUrRWd)IvI6DsL2nLSY3e38lwjR9oPwUA3uYo9mPx2VyLS2r5c64KUNJ)zcw8ZSxAfgesSIxAfoZmz44ODtjR8xEXkXENYJcAqKUGRv(M42IvYMrfUdoempblC7df17KQurUBgsSI)5zgcsQi31Qe6af0GiDbxR8nXTfRKnJkC)yQh(u)S6DsL2nLSY3e38lwjR9oPM2nLSJ6QDyVet2r5csbnisxW1kFtCBXkzZOcxL7r6fRe17KkTBkzLVjU5xSsw7OCbDC0UPKD6zsVSFXkzT3jhNurURossTsgsSI)5zgQFqKUG2Ov4HFXkXsQvOGgePl4ALVjUTyLSzuHRB954xSsuVtQ0UPKDWXWZ5Z2r5csbnisxW1kFtCBXkzZOc3WRC)b)(k5jF5APGgePl4ALVjUTyLSzuHB6e5Zd)Ivcf0GiDbxR8nXTfRKnJkCx(NyO4xPHZQtYNCyVe)mlRQSQ3jvpNEEXcTdtbnisxW1kFtCBXkzZOc3v4yKVFXkHckf0GiDbx7kzuH7kCmY3VyLOENujXHHIDfog57tf5UwggAhEO20Z54NjdBw7kCmY3VyLOM2nLSRWXiFFQi31(Ss0WfeDsbnisxW1Usgv46wFo(fRekObr6cU2vYOc3rD1oSxIjkObr6cU2vYOcxjEV8XK6Ds1FHCQ(z2U19KQFM9SIg)RLbh3EAIhQjX7LpMSpRenCbzMmuJu1zuUG20jE2(Ss0WfKzYGcAqKUGRDLmQWnDINvVtQ(lKt1pZ2TUNu9ZSNv04FTmm0o8qnjEV8XK9orbnisxW1Usgv46Qpd)o1Fllf0GiDbx7kzuHB6e5Zd)Ivcf0GiDbx7kzuH7GdbZtWc3(qr9oPkvK7MHeR4FEMHGKkYDTkHoqbnisxW1Usgv4Y6W0P2oh2VyLqbnisxW1Usgv4MtDoC(Q3jvA3uYo9mPx2VyLS2r5c64aEjomuSeSwj4p8lwjwggAhEqbnisxW1Usgv4gEL7p43xjp5lxlf0GiDbx7kzuH7ZBbdPHZ(4)YL6DsL2nLStpt6L9lwjRDuUGooGxIddflbRvc(d)IvILHH2HhuqdI0fCTRKrfUYF5fRe17KkTBkzNEM0l7xSsw7OCbDCaVehgkwcwRe8h(fRelddTdpOGgePl4AxjJkCJwHh(fRe17KQCt3ZX)mbl(z2lTcdcjwXlTcNzMmCC0UPKv(lVyLyVt5PwUA3uYo9mPx2VyLS2r5c64aEjomuSeSwj4p8lwjwggAhE44qcFqKohophhTBkzLVjU5xSsw7Zkrdx9zDGjxH9sRWQLBqKoh2ZqwP5v)Soo)fYP6Nz7Y)edLvIJB8VE5BIB8NVLbh3EAIh5rbnisxW1Usgv4(Xup8P(z17KkTBkzh1v7WEjMSJYfuTurUBgsSI)5zgcsQi31Qe6af0GiDbx7kzuHlbRvc(d)IvI6DsL2nLStpt6L9lwjR9oPwUA3uYk)LxSsSJYf0XjisNd7ziR08QFwhhWtcFqKohopkObr6cU2vYOc3L)jgk(vA4S6K8jh2lXpZYQkR6Ds1ZPNxSq7WQjXpZIvAf2lLF0S(J7hsxqkObr6cU2vYOcxT4)yMvVtQcI05WEgYknV6NLcAqKUGRDLmQWnEsaz)IvI6DsL2nLStpt6L9lwjR9oPwUA3uYk)LxSsSJYf0Xb8KWhePZHZJcAqKUGRDLmQWnAfE4xSsuVtQ0UPKD6zsVSFXkzTJYfKcAqKUGRDLmQWLG1kb)HFXkr9oPkvK7QpPwjtqKUG2Ov4HFXkXsQvulxTBkzL)Ylwj2r5c64aEs4dI05W5rbnisxW1Usgv4gpjGSFXkr9oPkvK7QpPwjtqKUG2Ov4HFXkXsQvulxTBkzL)Ylwj2r5c64aEs4dI05W5rbnisxW1Usgv4UchJ89lwjQ3jvPIC3mKyf)ZZmeKurURvj0bkObr6cU2vYOcxcwRe8h(fRekObr6cU2vYOc34jbK9lwjiGDIjiC0tN4djibHa]] )
    else
        spec:RegisterPack( "Marksmanship", 20201012.1, [[dGu26aqiOuEeuQQnHu6tqbLrrLQtrLYQOIk4vqjZIkXUe8lKkddQ0XeklJkYZGQ00OIY1es2guQ8nQOQXbfKZrfvADqbI5je3JkSpQKoiua0crQ6Hurf5JqbvAKurf6KqbuRekAMqbKBcfG2juv)ekamuOGQAPqbv5PGAQqfFfkOIXsfvu7fYFP0GP4WIwmQ6XOmzL6YeBMQ(SsA0GCAjRgkq9AKIzROBJKDRYVLA4kXXHcKwoWZv10jDDf2UqQVlunEOuLZdfA9qvmFuz)igfdHdcENQGW3jCDc3y4gZPaUyi8gZjSdbRyCrqWljJMCvqWxsjiymGjGMNkVhQwqWljgNDUr4GG)Eayccg7tmqQU8yqOJU1sHg8bwtr3xuJzQvFmq6v6(IIrhcMFutfd8H4rW7ufe(oHRt4gd3yofWfdH3yofdbNdfQbiy4IY5ecgQ2B5q8i4T8mem2NyWaMaAEQ8EOAHyCooovaemX(edgamT5faXeZjxigNW1jCjysWe7tmyGKOLjXeXbXefUbe8SE9r4GGvqXO5HA9r4GWpgcheCY0Qpemn1CAFOwrWYL8tzJOhPi8DcHdcozA1hco6EofmIGLl5NYgrpsr4Jxeoi4KPvFiy(eaYvbblxYpLnIEKIW3ziCqWjtR(qWc2Bz2FfTyFOwrWYL8tzJOhPi8JcHdcwUKFkBe9iygOubujcMF49bfumASpuRFySqm0smS0MmTIwigAjg(H3h29GFkwnxcJfeCY0QpeCwuY2(qTIue(yhcheSCj)u2i6rWmqPcOsem)W7dkOy0yFOw)WyHyOLyCNys8iGsLGVzJx2wFbKGCj)u2edhhXK4raLkH6SkKybqyuHOcG8OHyCLyIrmCCetIhbuQe(byTUv7d16hKl5NYMy44ignNYPHxbssnRtcYL8tztmUHGtMw9HGb5sTT(ciifHVZJWbblxYpLnIEemduQaQebZp8(Gckgn2hQ1pmwigAjg3jg(H3hwacREX(qT(HDh)igooIH19C3XVqwuY2(qTg8J50cegucwfRwucXeHysMw9fYIs22hQ1alF1QfLqmCCed)W7dkyipuRHXcX4gcozA1hcolkzBFOwrkcFmecheSCj)u2i6rWmqPcOsem)W7dkOy0yFOw)WybbNmT6dbdYLAB9fqqkcFNlcheSCj)u2i6rWmqPcOsem)W7dkOy0yFOw)WUJFedhhXWp8(Wcqy1l2hQ1pmwigAjgSrm8dVpOGH8qTggledhhX4B24jgxjgNhxeCY0Qpem1yQ1d1ksr4hdxeoi4KPvFiyFZgVSTjEeqPILxskeSCj)u2i6rkc)yXq4GGtMw9HGxgGYJX6wT8Z8veSCj)u2i6rkc)yoHWbbNmT6dbZ6JjNcsv2w)mPeeSCj)u2i6rkc)y4fHdcozA1hcMF2922ERcjw5ekmIGLl5NYgrpsr4hZziCqWYL8tzJOhbZaLkGkrW8dVpaegnt5FRVbmjmwigooIHF49bGWOzk)B9nGjwwpovaHxtgneteIjgUi4KPvFiyfsSJJVh326Batqkc)yrHWbbNmT6dbNwQbylaB7Tmqh)rWYL8tzJOhPi8JHDiCqWYL8tzJOhbZaLkGkrWaXdKhk5NcXqlXGnIjzA1x4fWICQ916wd1z9ZAfsrWjtR(qWVawKtTVw3ksr4hZ5r4GGtMw9HGFvYngTpuRiy5s(PSr0JuKIG3IphtfHdc)yiCqWjtR(qWSECQaSpuRiy5s(PSr0Jue(oHWbblxYpLnIEeCY0Qpe8CaOraVTUV2vpE7A5vemduQaQebZ6EU74xqbd5HAnaeQSU3UoK)jMietSOigooIXxRqQfiuzDpXeHyWlUi4lPee8CaOraVTUV2vpE7A5vKIWhViCqWYL8tzJOhbNmT6dbN45Hsq(wFFQT92LoUaqWmqPcOseS7eJVwHulqOY6EIXvIjzA1NL19C3XpIblIbVoJy44ignbRIgGKCQqHfMsmrigNWLy44ignbRIg0IsSABxyQ1jCjMietSOig3igAjgw3ZDh)ckyipuRbGqL1921H8pXeHyIffXWXrm(AfsTaHkR7jMiedEJcbFjLGGt88qjiFRVp12E7shxaifHVZq4GGLl5NYgrpcozA1hcEoEf0J3U2ZTC2L5GkxfemduQaQebZ6EU74xqbd5HAnaeQSU3UoK)jMietuedhhX4Rvi1ceQSUNyIqmoHlc(skbbphVc6XBx75wo7YCqLRcsr4hfcheSCj)u2i6rWjtR(qWR5uy5CkG3Y39HGzGsfqLiy(H3huWqEOwdaHkR7jgxjMyoJy44igSrmAoLtdSCoRB1QqI9HA9dYL8tztmCCeJVwHulqOY6EIjcXedxe8LuccEnNclNtb8w(UpKIWh7q4GGLl5NYgrpcozA1hcoFOOZtEliXtdSSgKtemduQaQebZp8(GcgYd1AaiuzDpX4kXeZzedTeJ7ed)W7dRJeSR8ST3M4raTcfgledhhXGnIr(xoMey9TL7LTDwEX3aMeOsm4gqm0smS0MmTIwig3igooIzl8dVpas80alRb50Uf(H3h2D8Jy44igFTcPwGqL19eteIXjCrWxsji48HIop5TGepnWYAqorkcFNhHdcwUKFkBe9i4KPvFi4LMrJOFHhzBzn1YqtT6ZULOlMGGzGsfqLiySrm8dVpOGH8qTggledTed2ig5F5ysGF2922ERcjw5ekmgOsm4gqmCCeZw4hEFGF2922ERcjw5ekmggledhhX4Rvi1ceQSUNyIqmrHGVKsqWlnJgr)cpY2YAQLHMA1NDlrxmbPi8XqiCqWYL8tzJOhbZaLkGkrW8dVpOGH8qTgacvw3tmUsmXCgXWXrmyJy0CkNgy5Cw3QvHe7d16hKl5NYMy44igFTcPwGqL19eteIXjCrWjtR(qWJxSLkupsr47Cr4GGLl5NYgrpcozA1hcMLZPnzA1NDwVIGN1R2lPeemB)ifHFmCr4GGLl5NYgrpcMbkvavIGtMwrlw5eQsEIjcXGxeCY0QpemlNtBY0Qp7SEfbpRxTxsji4xrkc)yXq4GGLl5NYgrpcMbkvavIGtMwrlw5eQsEIXvIXjeCY0QpemlNtBY0Qp7SEfbpRxTxsjiyfumAEOwFKIue8cqynfFQiCq4hdHdcwUKFkBe9i4fGWYxTArji4y4IGtMw9HG39GFkwnxqkcFNq4GGLl5NYgrpc(skbbN45Hsq(wFFQT92LoUaqWjtR(qWjEEOeKV13NABVDPJlaKIWhViCqWjtR(qWXBWChTuNfiFF5XeeSCj)u2i6rkcFNHWbbNmT6dbVosWUYZ2EBIhb0kecwUKFkBe9ifHFuiCqWjtR(qWucvdWOT925GvB7gij1JGLl5NYgrpsr4JDiCqWYL8tzJOhbVaew(QvlkbbhlefcozA1hcwbd5HAfbZaLkGkrWjtROfRCcvjpX4kX4esr478iCqWYL8tzJOhbNmT6dbV0A1hcEJXlPkMDbilTIGJHue(yieoiy5s(PSr0JGzGsfqLi4KPv0IvoHQKNyIqm4fbNmT6dbNfLSTpuRifPiy2(r4GWpgcheSCj)u2i6rWmqPcOsemR75UJFbqUuBRVasaiuzDpXeHywzBIHJJyyDp3D8laYLAB9fqcaHkR7jMiedR75UJFHSOKT9HAnaeQSUNy44igFTcPwGqL19eteIXjCrWjtR(qW7EWpfRMlifHVtiCqWYL8tzJOhbZaLkGkrW8dVpOGH8qTgacvw3tmUsmXCgXqlX4oX4Rvi1ceQSUNyCLyyDp3D8lWlGxa0u3AypaPw9rmyrm7bi1QpIHJJyCNy0eSkAasYPcfwykXeHyCcxIHJJyWgXO5uonWsG4htBwub5s(PSjg3ig3igooIXxRqQfiuzDpXeHyIHxeCY0QpemVaEbqtDRifHpEr4GGLl5NYgrpcMbkvavIG5hEFqbd5HAnaeQSUNyCLyI5mIHwIXDIXxRqQfiuzDpX4kXW6EU74xGF2926hamg2dqQvFedweZEasT6Jy44ig3jgnbRIgGKCQqHfMsmrigNWLy44igSrmAoLtdSei(X0MfvqUKFkBIXnIXnIHJJy81kKAbcvw3tmriMyyhcozA1hcMF2926hamIue(odHdcwUKFkBe9iygOubujcMF49bfmKhQ1aqOY6EIXvIjMZigAjg3jgFTcPwGqL19eJRedR75UJFH8yYRGCAz5Cg2dqQvFedweZEasT6Jy44ig3jgnbRIgGKCQqHfMsmrigNWLy44igSrmAoLtdSei(X0MfvqUKFkBIXnIXnIHJJy81kKAbcvw3tmriMyyhcozA1hcopM8kiNwwoNifHFuiCqWYL8tzJOhbZaLkGkrW8dVpOGH8qTgacvw3tmUsmXCgXqlX4oX4Rvi1ceQSUNyCLyyDp3D8l4lGWp7Eh2dqQvFedweZEasT6Jy44ig3jgnbRIgGKCQqHfMsmrigNWLy44igSrmAoLtdSei(X0MfvqUKFkBIXnIXnIHJJy81kKAbcvw3tmrigNlcozA1hc2xaHF29gPi8Xoeoiy5s(PSr0JGzGsfqLiy(H3huWqEOwd7o(HGtMw9HGN1kK(wm4XELsofPi8DEeoiy5s(PSr0JGzGsfqLiy(H3huWqEOwd7o(HGtMw9HG5ZvB7TkOy08ifHpgcHdcwUKFkBe9iygOubujcMF49bfmKhQ1WUJFedTeJ7eJMGvrdqsovOWctjgxjgmeUedhhXOjyv0aKKtfkSWuIjIdIXjCjgooIrtWQObTOeR22fMADcxIXvIbV4smUHGtMw9HGbsUu3Q1ptk5rkcFNlcheSCj)u2i6rWmqPcOseS7edR75UJFHeppucY367tTT3U0XfqaiuzDpX4kX4eUedhhXGnIrWGoQLfzhs88qjiFRVp12E7shxaedhhX4Rvi1ceQSUNyIqmSUN7o(fs88qjiFRVp12E7shxaH9aKA1hXGfXGxNrm0smAcwfnaj5uHclmLyCLyCcxIXnIHwIXDIH19C3XVGcgYd1AaiuzDVDDi)tmrig8smCCeJ7eJ8VCmjeD9vF22BxeGxyA1xGQUgqm0sm(AfsTaHkR7jgxjMKPvFww3ZDh)igSig(H3hI3G5oAPolq((YJjH9aKA1hX4gX4gXWXrm(AfsTaHkR7jMieJt4IGtMw9HGJ3G5oAPolq((YJjifHFmCr4GGLl5NYgrpcMbkvavIGDNyyPnzAfTqmCCeJVwHulqOY6EIXvIjzA1NL19C3XpIblIbV4smUrm0smUtm8dVpOGH8qTggledhhXW6EU74xqbd5HAnaeQSUNyIqmXWoIXnIHJJy81kKAbcvw3tmrig8gdbNmT6dbVosWUYZ2EBIhb0kesr4hlgcheSCj)u2i6rWmqPcOsemR75UJFbfmKhQ1aqOY6EIjcX48i4KPvFiyqTSmfBD2Fjzcsr4hZjeoiy5s(PSr0JGzGsfqLiySrm8dVpOGH8qTggli4KPvFiykHQby02E7CWQTDdKK6rkc)y4fHdcwUKFkBe9iygOubujcMF49bfmKhQ1aqsMsm0sm8dVpWp7EphVgasYuIHJJy4hEFqbd5HAnaeQSUNyCLyI5mIHwIrtWQObijNkuyHPeteIXjCjgooIXDIXDIH13pOs(PewAT6Z2E744b1EkBRFaWiXWXrmS((bvYpLW44b1EkBRFaWiX4gXqlX4Rvi1ceQSUNyIqmyxmIHJJy81kKAbcvw3tmrigNWoIXneCY0Qpe8sRvFifHFmNHWbblxYpLnIEemduQaQebZp8(GcgYd1Ay3XpIHwIH19C3XVaixQT1xajaeQSUNy44igFTcPwGqL19eteIjwui4KPvFiyfmKhQvKIue8RiCq4hdHdcozA1hcMMAoTpuRiy5s(PSr0Jue(oHWbbNmT6dblyVLz)v0I9HAfblxYpLnIEKIWhViCqWYL8tzJOhbZaLkGkrWjtROfRCcvjpX4kXedbNmT6dbZNaqUkifHVZq4GGtMw9HGtl1aSfGT9wgOJ)iy5s(PSr0Jue(rHWbbNmT6dbhDpNcgrWYL8tzJOhPi8Xoeoiy5s(PSr0JGzGsfqLiyG4bYdL8tHyOLyWgXKmT6l8cyro1(ADRH6S(zTcPi4KPvFi4xalYP2xRBfPi8DEeoiy5s(PSr0JGzGsfqLiy(H3huWqEOwd7o(rmCCeJVzJNyIqm4nkIHJJy8nB8eteIb7WLyOLyWgXO5uonmffkN2hQ1pixYpLnXWXrm8dVpuNvHelacJkevaiuzDpXeHyeSNWgQy1IsqWjtR(qWGCP2wFbeKIWhdHWbblxYpLnIEemduQaQebZp8(GcgYd1AySqm0smUtm8dVpmobaQB1gD9vFHxtgneJReJZigooIbBetIhbuQegNaa1TAJU(QVGCj)u2eJBedhhX4Rvi1ceQSUNyIqmXIHGtMw9HG5NDVTT3QqIvoHcJifHVZfHdcwUKFkBe9iygOubujcgBed)W7dkyipuRHXcXWXrm(AfsTaHkR7jMietui4KPvFiyFZgVSTjEeqPILxskKIWpgUiCqWYL8tzJOhbZaLkGkrW8dVpOGH8qTggledhhX4oXWp8(WUh8tXQ5sy3XpIHJJyyPnzAfTqmUrm0sm8dVpSaew9I9HA9d7o(rmCCeJFmNwGWGsWQy1IsiMiedlF1QfLqm0smSUN7o(fuWqEOwdaHkR7rWjtR(qWzrjB7d1ksr4hlgcheSCj)u2i6rWmqPcOsem2ig(H3huWqEOwdJfIHJJy81kKAbcvw3tmrigmecozA1hcEzakpgRB1YpZxrkc)yoHWbblxYpLnIEemduQaQeb7B24jgSigFZgFaiRYrmohiMv2MyIqm(Mn(avI9igAjg(H3huWqEOwd7o(rm0smUtmyJy2Tgy9XKtbPkBRFMuILFaUaqOY6EIHwIbBetY0QVaRpMCkivzB9ZKsc1z9ZAfsjg3igooIXpMtlqyqjyvSArjeteIzLTjgooIXxRqQfiuzDpXeHyIcbNmT6dbZ6JjNcsv2w)mPeKIWpgEr4GGLl5NYgrpcMbkvavIG5hEFaimAMY)wFdysySqmCCed)W7daHrZu(36BatSSECQacVMmAiMietmCjgooIXxRqQfiuzDpXeHyIcbNmT6dbRqIDC8942wFdycsr4hZziCqWYL8tzJOhbZaLkGkrW8dVpOGH8qTg2D8JyOLyCNy4hEFybiS6f7d16hgledTeJ7eJVzJNyCLyIkkIXnIHJJy8nB8eJReJZhfXWXrm(AfsTaHkR7jMietueJBi4KPvFi4eWYtSpuRifHFSOq4GGLl5NYgrpcMbkvavIG5hEFqbd5HAnS74hXqlX4oXWp8(Wcqy1l2hQ1pmwigAjg3jgFZgpX4kXevueJBedhhX4B24jgxjgNpkIHJJy81kKAbcvw3tmriMOig3qWjtR(qWmOIkfqAFOwrkc)yyhcheCY0Qpe8RsUXO9HAfblxYpLnIEKIuKIGJwaF1hcFNW1jCJHBSybNlcoEcU6wFemgoyaIHh(yGXhdxmiedXGdKqmf1sduIX3aIbdJTFmmIbiyqhfq2eZ3ucXKdTPsv2eddkVv5demXavNqmoxmieJZP(IwaQSjgmmfuhnIgCohyDp3D8ddJy0MyWWyDp3D8l4CgdJyC3jSNBbcMemXatT0av2etuetY0QpIzwV(bcMi4fq7RPGGX(edgWeqZtL3dvleJZXXPcGGj2NyWaGPnVaiMyo5cX4eUoHlbtcMyFIbdKeTmjMioiMOWnqWKGj2NyWWhiS8vIrHQNyYNyKemXiXKpXS0)x8tHy0MywAvoTY5eJeZAwhXKxRqcGyy5ReZEaQBLyuiHy81kKgiyMmT67dlaH1u8PILd629GFkwnxCzbiS8vRwuIJy4sWmzA13hwacRP4tflh0nEXwQq5YLuIJeppucY367tTT3U0XfabZKPvFFybiSMIpvSCqx8gm3rl1zbY3xEmHGzY0QVpSaewtXNkwoOBDKGDLNT92epcOvicMjtR((WcqynfFQy5GokHQby02E7CWQTDdKK6jyMmT67dlaH1u8PILd6uWqEOwDzbiS8vRwuIJyHOCP8osMwrlw5eQsExDIGzY0QVpSaewtXNkwoOBP1Qpx2y8sQIzxaYsRoIrWmzA13hwacRP4tflh0LfLSTpuRUuEhjtROfRCcvjFe8sWKGzY0QVhlh0X6XPcW(qTsWmzA13JLd6gVylvOC5skXXCaOraVTUV2vpE7A5vxkVdw3ZDh)ckyipuRbGqL1921H8FKyrXX5Rvi1ceQSUpcEXLGzY0QVhlh0nEXwQq5YLuIJeppucY367tTT3U0XfGlL3H7(AfsTaHkR7DL19C3XpSWRZ440eSkAasYPcfwyAeNWLJttWQObTOeR22fMADc3iXIYnAzDp3D8lOGH8qTgacvw3BxhY)rIffhNVwHulqOY6(i4nkcMjtR(ESCq34fBPcLlxsjoMJxb94TR9ClNDzoOYvXLY7G19C3XVGcgYd1AaiuzDVDDi)hjkooFTcPwGqL19rCcxcMjtR(ESCq34fBPcLlxsjowZPWY5uaVLV7ZLY7GF49bfmKhQ1aqOY6ExJ5mooSP5uonWY5SUvRcj2hQ1pixYpLnhNVwHulqOY6(iXWLGzY0QVhlh0nEXwQq5YLuIJ8HIop5TGepnWYAqoDP8o4hEFqbd5HAnaeQSU31yoJw35hEFyDKGDLNT92epcOvOWyHJdBY)YXKaRVTCVSTZYl(gWKavIb3aAzPnzAfT4gh3w4hEFaK4PbwwdYPDl8dVpS74hhNVwHulqOY6(ioHlbZKPvFpwoOB8ITuHYLlPehlnJgr)cpY2YAQLHMA1NDlrxmXLY7aB8dVpOGH8qTggl0In5F5ysGF2922ERcjw5ekmgOsm4gWXTf(H3h4NDVTT3QqIvoHcJHXchNVwHulqOY6(irrWe7tm4aWiXOnXmRtiMXcXKmTIovztmkOoAe9jM4Lcrm4agYd1kbZKPvFpwoOB8ITuH6DP8o4hEFqbd5HAnaeQSU31yoJJdBAoLtdSCoRB1QqI9HA9dYL8tzZX5Rvi1ceQSUpIt4sWmzA13JLd6y5CAtMw9zN1RUCjL4GTFcMjtR(ESCqhlNtBY0Qp7SE1LlPehV6s5DKmTIwSYjuL8rWlbZKPvFpwoOJLZPnzA1NDwV6YLuIdfumAEOwFxkVJKPv0IvoHQK3vNiysWmzA13hy73XUh8tXQ5IlL3bR75UJFbqUuBRVasaiuzDFKv2MJJ19C3XVaixQT1xajaeQSUpcR75UJFHSOKT9HAnaeQSUNJZxRqQfiuzDFeNWLGzY0QVpW2pwoOJxaVaOPUvxkVd(H3huWqEOwdaHkR7DnMZO1DFTcPwGqL19UY6EU74xGxaVaOPU1WEasT6dR9aKA1hhN7Acwfnaj5uHclmnIt4YXHnnNYPbwce)yAZIkixYpLTBUXX5Rvi1ceQSUpsm8sWmzA13hy7hlh0Xp7EB9dagDP8o4hEFqbd5HAnaeQSU31yoJw391kKAbcvw37kR75UJFb(z3BRFaWyypaPw9H1EasT6JJZDnbRIgGKCQqHfMgXjC54WMMt50albIFmTzrfKl5NY2n34481kKAbcvw3hjg2rWmzA13hy7hlh0LhtEfKtllNtxkVd(H3huWqEOwdaHkR7DnMZO1DFTcPwGqL19UY6EU74xipM8kiNwwoNH9aKA1hw7bi1Qpoo31eSkAasYPcfwyAeNWLJdBAoLtdSei(X0MfvqUKFkB3CJJZxRqQfiuzDFKyyhbZKPvFFGTFSCqNVac)S7TlL3b)W7dkyipuRbGqL19UgZz06UVwHulqOY6ExzDp3D8l4lGWp7Eh2dqQvFyThGuR(44CxtWQObijNkuyHPrCcxooSP5uonWsG4htBwub5s(PSDZnooFTcPwGqL19rCUemtMw99b2(XYbDZAfsFlg8yVsjN6s5DWp8(GcgYd1Ay3XpcMjtR((aB)y5Go(C12ERckgnVlL3b)W7dkyipuRHDh)iyMmT67dS9JLd6asUu3Q1ptk5DP8o4hEFqbd5HAnS74hTURjyv0aKKtfkSWuxXq4YXPjyv0aKKtfkSW0ioCcxoonbRIg0IsSABxyQ1jCDfV46gbZKPvFFGTFSCqx8gm3rl1zbY3xEmXLY7WDfuhnIgs88qjiFRVp12E7shxabw3ZDh)caHkR7D1jC54WMGbDullYoK45Hsq(wFFQT92LoUa4481kKAbcvw3hrb1rJOHeppucY367tTT3U0XfqG19C3XVWEasT6dl86mA1eSkAasYPcfwyQRoHRB06oR75UJFbfmKhQ1aqOY6E76q(pcE54Cx(xoMeIU(QpB7TlcWlmT6lqvxdO1xRqQfiuzDVRSUN7o(Hf)W7dXBWChTuNfiFF5XKWEasT6Zn34481kKAbcvw3hXjCjyMmT67dS9JLd6whjyx5zBVnXJaAfYLY7WDwAtMwrlCC(AfsTaHkR7DL19C3XpSWlUUrR78dVpOGH8qTgglCCSUN7o(fuWqEOwdaHkR7Jed7CJJZxRqQfiuzDFe8gJGzY0QVpW2pwoOdulltXwN9xsM4s5DW6EU74xqbd5HAnaeQSUpIZtWmzA13hy7hlh0rjunaJ22BNdwTTBGKuVlL3b24hEFqbd5HAnmwiyMmT67dS9JLd6wAT6ZLY7GF49bfmKhQ1aqsMsl)W7d8ZU3ZXRbGKmLJJF49bfmKhQ1aqOY6ExJ5mA1eSkAasYPcfwyAeNWLJZD3z99dQKFkHLwR(ST3ooEqTNY26hamYXX67huj)ucJJhu7PST(baJUrRVwHulqOY6(iyxmooFTcPwGqL19rCc7CJGzY0QVpW2pwoOtbd5HA1LY7GF49bfmKhQ1WUJF0Y6EU74xaKl126lGeacvw3ZX5Rvi1ceQSUpsSOiysWmzA13hE1bn1CAFOwjyMmT67dVILd6eS3YS)kAX(qTsWmzA13hEflh0XNaqUkUuEhjtROfRCcvjVRXiyMmT67dVILd6sl1aSfGT9wgOJ)emtMw99HxXYbDr3ZPGrcMjtR((WRy5GUxalYP2xRB1LY7aiEG8qj)uOfBjtR(cVawKtTVw3AOoRFwRqkbZKPvFF4vSCqhixQT1xaXLY7GF49bfmKhQ1WUJFCC(Mn(i4nkooFZgFeSdxAXMMt50WuuOCAFOw)GCj)u2CC8dVpuNvHelacJkevaiuzDFeb7jSHkwTOecMjtR((WRy5Go(z3BB7TkKyLtOWOlL3b)W7dkyipuRHXcTUZp8(W4eaOUvB01x9fEnz04QZ44WwIhbuQegNaa1TAJU(QVGCj)u2UXX5Rvi1ceQSUpsSyemtMw99HxXYbD(MnEzBt8iGsflVKuUuEhyJF49bfmKhQ1WyHJZxRqQfiuzDFKOiyMmT67dVILd6YIs22hQvxkVd(H3huWqEOwdJfoo35hEFy3d(Py1CjS74hhhlTjtROf3OLF49HfGWQxSpuRFy3Xpoo)yoTaHbLGvXQfLeHLVA1IsOL19C3XVGcgYd1AaiuzDpbZKPvFF4vSCq3YauEmw3QLFMV6s5DGn(H3huWqEOwdJfooFTcPwGqL19rWqemtMw99HxXYbDS(yYPGuLT1ptkXLY7W3SXJLVzJpaKv5CoSY2r8nB8bQe7rl)W7dkyipuRHDh)O1DSTBnW6JjNcsv2w)mPel)aCbGqL190ITKPvFbwFm5uqQY26NjLeQZ6N1kK6ghNFmNwGWGsWQy1IsISY2CC(AfsTaHkR7JefbZKPvFF4vSCqNcj2XX3JBB9nGjUuEh8dVpaegnt5FRVbmjmw444hEFaimAMY)wFdyIL1Jtfq41KrtKy4YX5Rvi1ceQSUpsuemtMw99HxXYbDjGLNyFOwDP8o4hEFqbd5HAnS74hTUZp8(Wcqy1l2hQ1pmwO1DFZgVRrfLBCC(MnExD(O4481kKAbcvw3hjk3iyMmT67dVILd6yqfvkG0(qT6s5DWp8(GcgYd1Ay3XpADNF49HfGWQxSpuRFySqR7(MnExJkk3448nB8U68rXX5Rvi1ceQSUpsuUrWmzA13hEflh09QKBmAFOwjysWmzA13huqXO5HA9DqtnN2hQvcMjtR((GckgnpuRpwoOl6EofmsWmzA13huqXO5HA9XYbD8jaKRcbZKPvFFqbfJMhQ1hlh0jyVLz)v0I9HALGzY0QVpOGIrZd16JLd6YIs22hQvxkVd(H3huqXOX(qT(HXcTS0MmTIwOLF49HDp4NIvZLWyHGzY0QVpOGIrZd16JLd6a5sTT(ciUuEh8dVpOGIrJ9HA9dJfADpXJakvc(MnEzB9fqcYL8tzZXL4raLkH6SkKybqyuHOcG8OX1yCCjEeqPs4hG16wTpuRFqUKFkBoonNYPHxbssnRtcYL8tz7gbZKPvFFqbfJMhQ1hlh0LfLSTpuRUuEh8dVpOGIrJ9HA9dJfADNF49HfGWQxSpuRFy3Xpoow3ZDh)czrjB7d1AWpMtlqyqjyvSArjrsMw9fYIs22hQ1alF1QfLWXXp8(GcgYd1AyS4gbZKPvFFqbfJMhQ1hlh0bYLAB9fqCP8o4hEFqbfJg7d16hglemtMw99bfumAEOwFSCqh1yQ1d1QlL3b)W7dkOy0yFOw)WUJFCC8dVpSaew9I9HA9dJfAXg)W7dkyipuRHXchNVzJ3vNhxcMjtR((GckgnpuRpwoOZ3SXlBBIhbuQy5LKIGzY0QVpOGIrZd16JLd6wgGYJX6wT8Z8vcMjtR((GckgnpuRpwoOJ1htofKQST(zsjemtMw99bfumAEOwFSCqh)S7TT9wfsSYjuyKGzY0QVpOGIrZd16JLd6uiXoo(ECBRVbmXLY7GF49bGWOzk)B9nGjHXchh)W7daHrZu(36BatSSECQacVMmAIedxcMjtR((GckgnpuRpwoOlTudWwa22BzGo(tWmzA13huqXO5HA9XYbDVawKtTVw3QlL3bq8a5Hs(Pql2sMw9fEbSiNAFTU1qDw)SwHucMjtR((GckgnpuRpwoO7vj3y0(qTIG)fHHW3POCgsrkcb]] )
    end

end