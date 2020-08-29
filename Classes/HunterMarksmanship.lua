-- HunterMarksmanship.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'HUNTER' then
    local spec = Hekili:NewSpecialization( 254, true )

    spec:RegisterResource( Enum.PowerType.Focus )

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
        aspect_of_the_cheetah = {
            id = 186258,
            duration = 9,
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
            id = 260309,
            duration = 3600,
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
            duration = 2,
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
            duration = 10,
            max_stack = 2,
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
            duration = 15,
            max_stack = 1,
        },

    } )


    spec:RegisterStateExpr( "ca_execute", function ()
        return talent.careful_aim.enabled and ( target.health.pct > 70 )
    end )


    local steady_focus_applied = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID and ( subtype == 'SPELL_AURA_APPLIED' or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' ) and spellID == 193534 then -- Steady Aim.
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


    -- Abilities
    spec:RegisterAbilities( {
        a_murder_of_crows = {
            id = 131894,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 20,
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

            spend = function () return buff.lock_and_load.up and 0 or 35 end,
            spendType = "focus",

            startsCombat = true,
            texture = 135130,

            handler = function ()
                applyBuff( "precise_shots" )
                removeBuff( "lock_and_load" )
                removeBuff( "double_tap" )
                removeBuff( "trick_shots" )
            end,
        },


        arcane_shot = {
            id = 185358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 20,
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
            cooldown = function () return 180 * ( talent.born_to_be_wild.enabled and 0.8 or 1 ) end,
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
            cooldown = function () return 180 * ( talent.born_to_be_wild.enabled and 0.8 or 1 ) end,
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

            spend = 30,
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

            spend = 10,
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

            spend = 20,
            spendType = "focus",

            startsCombat = true,
            texture = 236176,

            talent = "chimaera_shot",

            handler = function ()
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
            end,
        },


        explosive_shot = {
            id = 212431,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 20,
            spendType = "focus",

            startsCombat = false,
            texture = 236178,

            talent = "explosive_shot",
            
            handler = function ()
                applyDebuff( "target", "explosive_shot" )
            end,
        },


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
        },


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

            spend = 20,
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
                removeBuff( "trick_shots" )
                if talent.streamline.enabled then applyBuff( "streamline" ) end
            end,

            finish = function ()
                removeBuff( "double_tap" )                
            end,
        },


        serpent_sting = {
            id = 271788,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 10,
            spendType = "focus",

            startsCombat = true,
            texture = 1033905,

            velocity = 45,

            talent = "serpent_sting",

            recheck = function () return remains - ( duration * 0.3 ), remains end,
            handler = function ()
                applyDebuff( "target", "serpent_sting" )
            end,
        },


        steady_shot = {
            id = 56641,
            cast = 1.8,
            cooldown = 0,
            gcd = "spell",

            spend = -0,
            spendType = "focus",

            startsCombat = true,
            texture = 132213,

            handler = function ()
                if talent.steady_focus.enabled and prev_gcd[1].steady_shot and action.steady_shot.lastCast > last_steady_focus then
                    addStack( "steady_focus", nil, 1 )
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

            spend = 0,
            spendType = "focus",

            startsCombat = false,
            essential = true,

            texture = function () return GetStablePetInfo(1) or 'Interface\\ICONS\\Ability_Hunter_BeastCall' end,
            nomounted = true,

            usable = function () return false and not pet.exists end, -- turn this into a pref!
            handler = function ()
                summonPet( 'made_up_pet', 3600, 'ferocity' )
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

            spend = 0,
            spendType = "focus",

            startsCombat = true,
            texture = 132205,

            talent = "volley",

            start = function ()
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


    spec:RegisterPack( "Marksmanship", 20200829, [[duuacbqivcpcfHnrQYOukCkLIwfkIQELsvZsr4wksv2fv(fkyyKQ6ykvwMIONrvstJuP6AQeTnsLY3uKsJtrQCouezDuLOAEkQUhvX(qr6GksvTqsfpurkYfrruzKuLi6KuLiSsfLzIIO4MuLiTtuOHQif1tvXuvjDvueL2RQ(ljdMshwQftkpgvtwWLj2ScFwLA0u40swTIu41OOMTsUnkTBGFlA4uvhNQeLLd65qMoY1fA7ks(UsPXtvcNNQuRNujZNI2pu)7(R)j0K8moP(tQV(t3Kmj3Ul3P)U)qE7l)XV5m33YFanR8hV0gYmITbiJY)p(T3RSd)1)GYiKl)HjWwdI8rE5mWWDrgrnhpzzavSXvtvc4WEqmGkwod)rlwlYlb41(tOj5zCs9NuF9NUjzsUDxUtF9V8pDKms4Fof700FmQqqaV2FccI)hMaB9sBiZi2gGmkFS1lzeqcepJjWwdI8rE5mWWDrgrnhpzzavSXvtvc4WEqmGkwod4zmb26L2qUb26v9NaBNu)j1hpdpJjW2PjJgCliVC8mMaBNEy70peW2ivRI8gB9HvclYBSLsSD6pnZKXHNXey70dBzYIeSLkwrrPkuc2cBYqGylz0aSLA4TqoQyffLQqjylLyBdOIx(njyRacyBoWwEYQ1K7pRcrO)6FiyXzgzKe6V(mU7V(NMtvc(JwdH9T8hb0Alj8680Z4K)1)0CQsWFeVWFLOAkrHms6pcO1ws415PNrV(x)JaATLeED(dhwKaR(pAXXWrWIZSczKeYf9Xw9WwEReVq4rsWw9WwT4y4czuBjkQ9Dr))0CQsWF6IvckKrsp9mQ7)1)iGwBjHxN)WHfjWQ)JwCmCeS4mRqgjHCrFSvpSDdST1LalsCJKhrsqnkO4eqRTKa2AAITTUeyrIRakYquqdVjdwhSbmJTmfB3HTMMyBRlbwK4qr4DbUviJKqob0AljGTMMyl1lbqoebLMDvaXjGwBjbSDZ)0CQsWFGTFfuJckp9mE5F9pcO1ws415pCyrcS6)OfhdhbloZkKrsix0hB1dB3aB1IJHZhk8cjkKrsixi3cWwttSLN5kKBbUUyLGczKKBexlfu4gn8wuuXky7CST5uLaxxSsqHmsYXBePOIvWwttSvlogocgfKrsUOp2U5FAovj4pDXkbfYiPNEg1T)6FeqRTKWRZF4WIey1)rlogocwCMviJKqUO)FAovj4pW2VcQrbLNEgN2)6FeqRTKWRZF4WIey1)rlogocwCMviJKqUqUfGTMMyRwCmC(qHxirHmsc5I(yREy7fyRwCmCemkiJKCrFS10eBhjpIWwMITtR()P5uLG)WgxuHms6PNXP7V(NMtvc(Zi5rKeuTUeyrIstA2)iGwBjHxNNEgzs)1)0CQsWF8JWA4DbUvARgr)raT2scVop9mUt))6FAovj4p8eWfabBscQXQzL)iGwBjHxNNEg3T7V(NMtvc(J2kZGkhkYqucqy9(pcO1ws415PNXDt(x)JaATLeED(dhwKaR(pAXXWbfoZlbHuJeYfx0hBnnXwT4y4GcN5LGqQrc5IINrajqhIAoZy7CSDN()P5uLG)qgIkc0YiiOgjKlp9mUZR)1)0CQsWFAfBegeOkhkom3I(JaATLeEDE6zCNU)x)JaATLeED(dhwKaR(pqzafKrRTeSvpS9cST5uLahsG(cGuiQa3UcOgR62G(tZPkb)bjqFbqkevG7NEg3D5F9pnNQe8hejDWBfYiP)iGwBjHxNNE6pbz0Xf9xFg39x)JaATLeED(dhwKaR(pbrlogoEJOcC7I(yRPj2QfhdxOq(YA1AlrX23f3f9XwttSvlogUqH8L1Q1wIsaW(wCr))0CQsWF49APAovjqTke9NvHifOzL)ePAvK3p9mo5F9pcO1ws415pnNQe8NveYSarQcGQqLrK6Ug0F4WIey1)HN5kKBbocgfKrsoOW2faPUJccHTZX2DxITMMylvSIIsvOeSDo26v9)dOzL)SIqMfisvaufQmIu31GE6z0R)1)iGwBjHxN)0CQsWFADHmAyJuJeqQCO8ZTc8pCyrcS6)Sb2sfROOufkbBzk22CQsGIN5kKBby7ES1R6o2AAITudVfYzi9ImC(CcBNJTtQp2AAITudVfYrfROOu5Zj1K6JTZX2DxITBIT6HT8mxHClWrWOGmsYbf2Uai1DuqiSDo2U7sS10eBPIvuuQcLGTZXwVE5FanR8NwxiJg2i1ibKkhk)CRaF6zu3)R)raT2scVo)P5uLG)SIicMrK6oxbbO8xr2(w(dhwKaR(p8mxHClWrWOGmsYbf2Uai1DuqiSDo2Ej2AAITuXkkkvHsW25y7K6)hqZk)zfremJi1DUccq5VIS9T80Z4L)1)iGwBjHxN)0CQsWFU7LW71sGiLwMG)WHfjWQ)JpuMsDZdUDocgfKrsyRPj2Eb2s9saKJ3RvbUvKHOqgjHCcO1wsaBnnXwQyffLQqjy7CSDN()b0SYFU7LW71sGiLwMGNEg1T)6FeqRTKWRZFAovj4pnYyQgiifS1vcv8e2R)WHfjWQ)JpuMsDZdUDocgfKrsyREy7gyRwCmC3XggQgOYHQ1LatYWf9XwttS9cSvqibWfhpbbbGKGAvdzKqU4y7PrcXw9WwEReVq4rsW2nXwttSniAXXWbBDLqfpH9sfeT4y4c5wa2AAITuXkkkvHsW25y7K6)hqZk)Prgt1abPGTUsOINWE90Z40(x)JaATLeED(tZPkb)Xp5mleQ0Leu8K1psnvjqfKPkU8hoSibw9FUaB1IJHJGrbzKKl6JT6HTxGTccjaU40wzgu5qrgIsacR3o2EAKqS10eBdIwCmCARmdQCOidrjaH1Bx0hBnnXwQyffLQqjy7CS9Y)aAw5p(jNzHqLUKGINS(rQPkbQGmvXLNEgNU)6FeqRTKWRZF4WIey1)XhktPU5b3ohbJcYijS10eBVaBPEjaYX71Qa3kYquiJKqob0AljGTMMylvSIIsvOeSDo2oP()P5uLG)erIQiHf90Zit6V(hb0Alj868NMtvc(dVxlvZPkbQvHO)SkePanR8hEa90Z4o9)R)raT2scVo)HdlsGv)NMt1uIsacBjiSDo261)0CQsWF49APAovjqTke9NvHifOzL)GONEg3T7V(hb0Alj868hoSibw9FAovtjkbiSLGWwMITt(NMtvc(dVxlvZPkbQvHO)SkePanR8hcwCMrgjHE6P)4dfEYQ10F9zC3F9pnNQe8hJiGeisX2qM)JaATLeEDE6zCY)6FeqRTKWRZF8HcVrKIkw5p70)pnNQe8Nqg1wIIA)NEg96F9pcO1ws415pGMv(tRlKrdBKAKasLdLFUvG)P5uLG)06cz0WgPgjGu5q5NBf4tpJ6(F9pnNQe8NTjCfMskGckOe0aU8hb0Alj8680Z4L)1)0CQsWFUJnmunqLdvRlbMKXFeqRTKWRZtpJ62F9pnNQe8hwHnHERYHAf5vqfGsZI(JaATLeEDE6zCA)R)raT2scVo)Xhk8grkQyL)SZD5FAovj4pemkiJK(dhwKaR(pnNQPeLae2sqyltX2jF6zC6(R)P5uLG)4NuLG)iGwBjHxNNEgzs)1)iGwBjHxN)WHfjWQ)tZPAkrjaHTee2ohB96FAovj4pDXkbfYiPNE6p8a6V(mU7V(hb0Alj868hoSibw9FcIwCmCgrajqKITHm7c5wa2Qh2Eb2QfhdhbJcYijx0)pnNQe8hJiGeisX2qMF6zCY)6FeqRTKWRZF4WIey1)HN5kKBboy7xb1OGIdkSDbqy7CS9MhWwttSLN5kKBboy7xb1OGIdkSDbqy7CSLN5kKBbUUyLGczKKdkSDbqyRPj2sfROOufkbBNJTtQ)FAovj4pHmQTef1(p9m61)6FeqRTKWRZF4WIey1)XhktPU5b3ohbJcYijSvpSDdSLA4TqoQyffLQqjyltXwEMRqUf40eisGmxGBxicBQsa2UhBdrytvcWwttSDdSLA4TqodPxKHZNty7CSDs9XwttS9cSL6LaihVHYiUuDX6eqRTKa2Uj2Uj2AAITuXkkkvHsW25y7oV(NMtvc(JMarcK5cC)0ZOU)x)JaATLeED(dhwKaR(p(qzk1np425iyuqgjHT6HTBGTudVfYrfROOufkbBzk2YZCfYTaN2kZGAeHE7crytvcW29yBicBQsa2AAITBGTudVfYzi9ImC(CcBNJTtQp2AAITxGTuVea54nugXLQlwNaATLeW2nX2nXwttSLkwrrPkuc2ohB3PB)P5uLG)OTYmOgrO3p9mE5F9pcO1ws415pCyrcS6)4dLPu38GBNJGrbzKe2Qh2Ub2sn8wihvSIIsvOeSLPylpZvi3cCnGlic2lfVxlxicBQsa2UhBdrytvcWwttSDdSLA4TqodPxKHZNty7CSDs9XwttS9cSL6LaihVHYiUuDX6eqRTKa2Uj2Uj2AAITuXkkkvHsW25y7oD7pnNQe8NgWfeb7LI3R1tpJ62F9pcO1ws415pCyrcS6)4dLPu38GBNJGrbzKe2Qh2Ub2sn8wihvSIIsvOeSLPylpZvi3cCJckARmdUqe2uLaSDp2gIWMQeGTMMy7gyl1WBHCgsVidNpNW25y7K6JTMMy7fyl1lbqoEdLrCP6I1jGwBjbSDtSDtS10eBPIvuuQcLGTZXwM0FAovj4pJckARmdp9moT)1)iGwBjHxN)WHfjWQ)JwCmCemkiJKCHCl4pnNQe8NvDBqi10igUzfa90Z409x)JaATLeED(dhwKaR(pAXXWrWOGmsYfYTG)0CQsWF06BvoueS4mJE6zKj9x)JaATLeED(dhwKaR(pAXXWrWOGmsYfYTaSvpSDdSLA4TqodPxKHZNtyltX2PtFS10eBPgElKZq6fz485e2o3d2oP(yRPj2sn8wihvSIIsLpNutQp2YuS1R6JTB(NMtvc(duA)cCRgRMvqp9mUt))6FeqRTKWRZF4WIey1)zdSLN5kKBbUwxiJg2i1ibKkhk)CRaDqHTlacBzk2oP(yRPj2Eb2kEzXY3xcUwxiJg2i1ibKkhk)CRaXwttSLkwrrPkuc2ohB5zUc5wGR1fYOHnsnsaPYHYp3kqxicBQsa2UhB9QUJT6HTudVfYzi9ImC(CcBzk2oP(y7MyREy7gylpZvi3cCemkiJKCqHTlasDhfecBNJTEfBnnX2nWwbHeaxCtvOkbQCO8f4q4uLahBbsi2Qh2sfROOufkbBzk22CQsGIN5kKBby7ESvlogUTjCfMskGckOe0aU4crytvcW2nX2nXwttSLkwrrPkuc2ohBNu))0CQsWF2MWvykPakOGsqd4YtpJ729x)JaATLeED(dhwKaR(pBGT8wjEHWJKGTMMyl1WBHCuXkkkvHsWwMITnNQeO4zUc5wa2UhB9Q(y7MyREy7gyRwCmCemkiJKCrFS10eB5zUc5wGJGrbzKKdkSDbqy7CSDNUHTBITMMylvSIIsvOeSDo261D)P5uLG)ChByOAGkhQwxcmjJNEg3n5F9pcO1ws415pCyrcS6)WZCfYTahbJcYijhuy7cGW25y70(NMtvc(dS89xIQakKFZLNEg351)6FeqRTKWRZF4WIey1)5cSvlogocgfKrsUO)FAovj4pScBc9wLd1kYRGkaLMf90Z4oD)V(NMtvc(duqjOPcCRAim3(hb0Alj8680Z4Ul)R)P5uLG)eKMmuCJMzyZ(hb0Alj8680Z4oD7V(NMtvc(Z2Afui)cwe6pcO1ws415PNXDt7F9pnNQe8NXQ9wckKrs)raT2scVop9mUB6(R)raT2scVo)HdlsGv)hT4y4iyuqgj5GsZjSvpSvlogoTvMHveroO0CcBnnXwFOmL6MhC7CemkiJKWw9WwQH3c5mKErgoFoHTZX2j1hBnnX2nW2nWwEcqr2wBjo)KQeOYHkc0Gvyjb1ic9gBnnXwEcqr2wBjUiqdwHLeuJi0BSDtSvpSLA4TqoQyffLQqjy7CSv32HTMMylvSIIsvOeSDo2oPUHTB(NMtvc(JFsvcE6zCht6V(hb0Alj868hoSibw9F0IJHJGrbzKKlKBbyREylpZvi3cCW2VcQrbfhuy7cGWwttSLkwrrPkuc2ohB3D5FAovj4pemkiJKE6P)GO)6Z4U)6FAovj4pIx4VsunLOqgj9hb0Alj8680Z4K)1)iGwBjHxN)WHfjWQ)tZPAkrjaHTee2YuSD3FAovj4pAne23YtpJE9V(NMtvc(tRyJWGav5qXH5w0FeqRTKWRZtpJ6(F9pcO1ws415pCyrcS6)aLbuqgT2sWw9W2lW2MtvcCib6lasHOcC7kGASQBd6pnNQe8hKa9faPqubUF6z8Y)6FeqRTKWRZF4WIey1)rlogocgfKrsUqUfGTMMy7i5re2ohB96LyRPj2osEeHTZXwDtFSvpS9cSL6Lai3siJEPqgjHCcO1wsaBnnXwT4y4kGImef0WBYG1bf2UaiSDo2kEHWJKOOIv(tZPkb)b2(vqnkO80ZOU9x)JaATLeED(dhwKaR(pAXXWrWOGmsYf9Xw9W2nWwT4y4IabclWTAQcvjWHOMZm2YuSv3XwttS9cST1LalsCrGaHf4wnvHQe4eqRTKa2Uj2AAITuXkkkvHsW25y7UD)P5uLG)OTYmOYHImeLaewVF6zCA)R)raT2scVo)HdlsGv)NlWwT4y4iyuqgj5I(yRPj2sfROOufkbBNJTx(NMtvc(Zi5rKeuTUeyrIstA2NEgNU)6FeqRTKWRZF4WIey1)rlogocgfKrsUOp2Qh2QfhdhBJibQyBiZi2g4I(yREy7fyRwCmCScBc9wLd1kYRGkaLMf5I()P5uLG)0qEdefYiPNEgzs)1)iGwBjHxN)WHfjWQ)JwCmCemkiJKCrFS10eB3aB1IJHlKrTLOO23fYTaS10eB5Ts8cHhjbB3eB1dB1IJHZhk8cjkKrsixi3cWwttSDexlfu4gn8wuuXky7CSL3isrfRGT6HT8mxHClWrWOGmsYbf2UaO)0CQsWF6IvckKrsp9mUt))6FeqRTKWRZF4WIey1)rlogocgfKrsUOp2Qh2QfhdhBJibQyBiZi2g4I(yREyRwCmCScBc9wLd1kYRGkaLMf5I()P5uLG)0qEdefYiPNEg3T7V(hb0Alj868hoSibw9FUaB1IJHJGrbzKKl6JTMMylvSIIsvOeSDo2oD)P5uLG)4hH1W7cCR0wnIE6zC3K)1)iGwBjHxN)WHfjWQ)Zi5re2UhBhjpICq5wayltES9MhW25y7i5rKJT9cSvpSvlogocgfKrsUqUfGT6HTBGTxGTHKC8eWfabBscQXQzfLwecCqHTlacB1dBVaBBovjWXtaxaeSjjOgRMvCfqnw1TbHTBITMMy7iUwkOWnA4TOOIvW25y7npGTMMyl1WBHCuXkkkvHsW25y7L)P5uLG)WtaxaeSjjOgRMvE6zCNx)R)raT2scVo)HdlsGv)hT4y4GcN5LGqQrc5Il6JTMMyRwCmCqHZ8sqi1iHCrXZiGeOdrnNzSDo2UtFS10eBPIvuuQcLGTZX2l)tZPkb)HmeveOLrqqnsixE6zCNU)x)JaATLeED(dhwKaR(pAXXWrWOGmsYfYTaSvpSDdSvlogoFOWlKOqgjHCrFSvpSDdSDK8icBzk2E5LyRPj2QfhdhBJibQyBiZi2g4I(y7MyRPj2osEeHTmfBN2lXwttSLkwrrPkuc2ohBVeB38pnNQe8NgYBGOqgj90Z4Ul)R)P5uLG)GiPdERqgj9hb0Alj8680t)js1QiV)RpJ7(R)P5uLG)WZiGeOczK0FeqRTKWRZtpJt(x)tZPkb)bjqbuK3Qqer)raT2scVop9m61)6FAovj4pi)ekk(kJH)iGwBjHxNNEg19)6FAovj4pOmjJcCR22Ka)JaATLeEDE6z8Y)6FAovj4pOeuCL2Qr0FeqRTKWRZtpJ62F9pnNQe8hGqgcuHmsoZ)raT2scVop9moT)1)0CQsWF4g10Oqkc2aVSyTkY7)iGwBjHxNNEgNU)6FAovj4pi)cwKczKCM)JaATLeEDE6zKj9x)tZPkb)b0ueki1nS5YFeqRTKWRZtp90FMsGOkbpJtQ)K6RVUR)U)STHGcCJ(Jxcw)essaB1nST5uLaSDvic5WZ(Jpmh1s(dtGTEPnKzeBdqgLp26LmcibINXey70pEhre2ojtAcSDs9NuF8m8mMaBNMmAWTG8YXZycSD6HTt)qaBJuTkYBS1hwjSiVXwkX2P)0mtghEgtGTtpSLjlsWwQyffLQqjylSjdbITKrdWwQH3c5OIvuuQcLGTuITnGkE53KGTciGT5aB5jRwto8m8mMaBzY5fcpssaB1KrcfSLNSAnHTAYDbqoSD6Z5IpHWwqcMEgnKDexyBZPkbiSnblVD4zmb22CQsaY5dfEYQ1KNXQrmJNXeyBZPkbiNpu4jRwt79WqhVzfa1uLa8mMaBBovja58Hcpz1AAVhggzgWZycS9aAFKrsylSRa2QfhdjGTiQje2QjJekylpz1AcB1K7cGW2geWwFOm98tIkWn2wiSnKaXHNXeyBZPkbiNpu4jRwt79Wac0(iJKuiQjeEwZPkbiNpu4jRwt79WGreqcePyBiZ4zmb2ondfEJiSLmke22iSvA4YBSTryRFIqL2sWwkXw)Keav9A5n2E3faBBqsgceB5nIW2qewGBSLmeSDu3gKdpR5uLaKZhk8KvRP9EyiKrTLOO2FcFOWBePOIv8StF8SMtvcqoFOWtwTM27HHisufjStaAwXtRlKrdBKAKasLdLFUvG4znNQeGC(qHNSAnT3ddBt4kmLuafuqjObCbpR5uLaKZhk8KvRP9Ey4o2Wq1avouTUeysg4znNQeGC(qHNSAnT3ddScBc9wLd1kYRGkaLMfHN1CQsaY5dfEYQ10EpmqWOGmsAcFOWBePOIv8SZD5e1WtZPAkrjaHTeetNepR5uLaKZhk8KvRP9EyWpPkb4znNQeGC(qHNSAnT3ddDXkbfYiPjQHNMt1uIsacBjO5EfpdpR5uLaKls1QiV9WZiGeOczKeEwZPkbixKQvrEV3ddibkGI8wfIicpR5uLaKls1QiV37HbKFcffFLXaEwZPkbixKQvrEV3ddOmjJcCR22KaXZAovja5IuTkY79EyaLGIR0wnIWZAovja5IuTkY79EyaiKHaviJKZmEwZPkbixKQvrEV3ddCJAAuifbBGxwSwf5nEwZPkbixKQvrEV3ddi)cwKczKCMXZAovja5IuTkY79Eya0ueki1nS5cEgEgtGTm58cHhjjGTYuc0BSLkwbBjdbBBoLqSTqyBpvxRwBjo8SMtvcqE49APAovjqTkenbOzfprQwf59e1Wtq0IJHJ3iQa3UOVPPwCmCHc5lRvRTefBFxCx030ulogUqH8L1Q1wIsaW(wCrF8SMtvcq79WqejQIe2janR4zfHmlqKQaOkuzePURbnrn8WZCfYTahbJcYijhuy7cGu3rbHMV7sttQyffLQqjZ9Q(4znNQeG27HHisufjStaAwXtRlKrdBKAKasLdLFUvGtudpBqfROOufkHP8mxHClyVx1DttQH3c5mKErgoFonFs9nnPgElKJkwrrPYNtQj1F(Ul3upEMRqUf4iyuqgj5GcBxaK6oki08DxAAsfROOufkzUxVepR5uLa0EpmerIQiHDcqZkEwrebZisDNRGau(RiBFltudp8mxHClWrWOGmsYbf2Uai1DuqO5xAAsfROOufkz(K6JN1CQsaAVhgIirvKWobOzfp39s49AjqKsltWe1WJpuMsDZdUDocgfKrsMMxq9saKJ3RvbUvKHOqgjHCcO1wsW0KkwrrPkuY8D6JN1CQsaAVhgIirvKWobOzfpnYyQgiifS1vcv8e2RjQHhFOmL6MhC7CemkiJK0BdT4y4UJnmunqLdvRlbMKHl6BAEHGqcGloEcccajb1QgYiHCXX2tJeQhVvIxi8ijBAAgeT4y4GTUsOINWEPcIwCmCHClW0KkwrrPkuY8j1hpR5uLa0EpmerIQiHDcqZkE8toZcHkDjbfpz9JutvcubzQIltudpxOfhdhbJcYijx0xVleesaCXPTYmOYHImeLaewVDS90iHMMbrlogoTvMbvouKHOeGW6Tl6BAsfROOufkz(L4zmb2Ef6n2sj2UkGGTrFST5unvtsaBjybywie2UTidS9kmkiJKWZAovjaT3ddrKOksyrtudp(qzk1np425iyuqgjzAEb1lbqoEVwf4wrgIczKeYjGwBjbttQyffLQqjZNuF8SMtvcq79WaVxlvZPkbQvHOjanR4Hhq4znNQeG27HbEVwQMtvcuRcrtaAwXdIMOgEAovtjkbiSLGM7v8SMtvcq79WaVxlvZPkbQvHOjanR4HGfNzKrsOjQHNMt1uIsacBjiMojEgEwZPkbihpG8yebKark2gY8e1Wtq0IJHZicibIuSnKzxi3c07cT4y4iyuqgj5I(4znNQeGC8aAVhgczuBjkQ9NOgE4zUc5wGd2(vqnkO4GcBxa08BEW0KN5kKBboy7xb1OGIdkSDbqZ5zUc5wGRlwjOqgj5GcBxaKPjvSIIsvOK5tQpEwZPkbihpG27HbnbIeiZf4EIA4XhktPU5b3ohbJcYij92GA4TqoQyffLQqjmLN5kKBbonbIeiZf42fIWMQeSpeHnvjW0CdQH3c5mKErgoFonFs9nnVG6LaihVHYiUuDX6eqRTKWMBAAsfROOufkz(oVIN1CQsaYXdO9EyqBLzqnIqVNOgE8HYuQBEWTZrWOGmssVnOgElKJkwrrPkuct5zUc5wGtBLzqnIqVDHiSPkb7drytvcmn3GA4TqodPxKHZNtZNuFtZlOEjaYXBOmIlvxSob0AljS5MMMuXkkkvHsMVt3WZAovja54b0Epm0aUGiyVu8ETMOgE8HYuQBEWTZrWOGmssVnOgElKJkwrrPkuct5zUc5wGRbCbrWEP49A5crytvc2hIWMQeyAUb1WBHCgsVidNpNMpP(MMxq9saKJ3qzexQUyDcO1wsyZnnnPIvuuQcLmFNUHN1CQsaYXdO9EyyuqrBLzyIA4XhktPU5b3ohbJcYij92GA4TqoQyffLQqjmLN5kKBbUrbfTvMbxicBQsW(qe2uLatZnOgElKZq6fz48508j1308cQxcGC8gkJ4s1fRtaT2scBUPPjvSIIsvOK5mj8SMtvcqoEaT3ddR62GqQPrmCZkaAIA4rlogocgfKrsUqUfGN1CQsaYXdO9EyqRVv5qrWIZmAIA4rlogocgfKrsUqUfGN1CQsaYXdO9EyakTFbUvJvZkOjQHhT4y4iyuqgj5c5wGEBqn8wiNH0lYW5ZjMoD6BAsn8wiNH0lYW5ZP5EMuFttQH3c5OIvuuQ85KAs9zQx1Ft8SMtvcqoEaT3ddBt4kmLuafuqjObCzIA4zdEMRqUf4ADHmAyJuJeqQCO8ZTc0bf2UaiMoP(MMxiEzXY3xcUwxiJg2i1ibKkhk)CRannPIvuuQcLmNN5kKBbUwxiJg2i1ibKkhk)CRaDHiSPkb79QURh1WBHCgsVidNpNy6K6VPEBWZCfYTahbJcYijhuy7cGu3rbHM7vtZneesaCXnvHQeOYHYxGdHtvcCSfiH6rfROOufkHP8mxHClyVwCmCBt4kmLuafuqjObCXfIWMQeS5MMMuXkkkvHsMpP(4znNQeGC8aAVhgUJnmunqLdvRlbMKXe1WZg8wjEHWJKyAsn8wihvSIIsvOeMYZCfYTG9Ev)n1BdT4y4iyuqgj5I(MM8mxHClWrWOGmsYbf2UaO570TnnnPIvuuQcLm3R7WZAovja54b0EpmalF)LOkGc53CzIA4HN5kKBbocgfKrsoOW2fanFAXZAovja54b0EpmWkSj0BvouRiVcQauAw0e1WZfAXXWrWOGmsYf9XZAovja54b0EpmafucAQa3QgcZT4znNQeGC8aAVhgcstgkUrZmSzXZAovja54b0EpmSTwbfYVGfHWZAovja54b0EpmmwT3sqHmscpR5uLaKJhq79WGFsvcMOgE0IJHJGrbzKKdknN0tlogoTvMHveroO0CY00hktPU5b3ohbJcYij9OgElKZq6fz48508j130CJn4jafzBTL48tQsGkhQiqdwHLeuJi0BttEcqr2wBjUiqdwHLeuJi07n1JA4TqoQyffLQqjZ1TDMMuXkkkvHsMpPUTjEwZPkbihpG27HbcgfKrstudpAXXWrWOGmsYfYTa94zUc5wGd2(vqnkO4GcBxaKPjvSIIsvOK57UepdpR5uLaKdrEeVWFLOAkrHmscpR5uLaKdr79WGwdH9Tmrn80CQMsucqylbX0D4znNQeGCiAVhgAfBegeOkhkom3IWZAovja5q0EpmGeOVaifIkW9e1Wdugqbz0AlrVlAovjWHeOVaifIkWTRaQXQUni8SMtvcqoeT3ddW2VcQrbLjQHhT4y4iyuqgj5c5wGP5i5r0CVEPP5i5r0CDtF9UG6Lai3siJEPqgjHCcO1wsW0ulogUcOidrbn8MmyDqHTlaAU4fcpsIIkwbpJjW2A4rlogocgfKrsUOVEBOfhdxeiqybUvtvOkboe1CMzQUBAErRlbwK4IabclWTAQcvjWjGwBjHnnnPgElKJkwrrPkuY8D7WZAovja5q0EpmOTYmOYHImeLaewVNOgE0IJHJGrbzKKl6R3gAXXWfbcewGB1ufQsGdrnNzMQ7MMx06sGfjUiqGWcCRMQqvcCcO1wsytttQyffLQqjZ3TdpR5uLaKdr79WWi5rKeuTUeyrIstA2jQHNl0IJHJGrbzKKl6BAsfROOufkz(L4znNQeGCiAVhgAiVbIczK0e1WJwCmCemkiJKCrF90IJHJTrKavSnKzeBdCrF9UqlogowHnHERYHAf5vqfGsZICrF8SMtvcqoeT3ddDXkbfYiPjQHhT4y4iyuqgj5I(MMBOfhdxiJAlrrTVlKBbMM8wjEHWJKSPEAXXW5dfEHefYijKlKBbMMJ4APGc3OH3IIkwzoVrKIkwrpEMRqUf4iyuqgj5GcBxaeEwZPkbihI27HHgYBGOqgjnrn8OfhdhbJcYijx0xpT4y4yBejqfBdzgX2ax0xpT4y4yf2e6TkhQvKxbvaknlYf9XZAovja5q0Epm4hH1W7cCR0wnIMOgEUqlogocgfKrsUOVPjvSIIsvOK5thEwZPkbihI27HbEc4cGGnjb1y1SYe1WZi5r0(rYJihuUfat(BEy(i5rKJT9c90IJHJGrbzKKlKBb6TXfHKC8eWfabBscQXQzfLwecCqHTlasVlAovjWXtaxaeSjjOgRMvCfqnw1TbTPP5iUwkOWnA4TOOIvMFZdMMudVfYrfROOufkz(L4znNQeGCiAVhgidrfbAzeeuJeYLjQHhT4y4GcN5LGqQrc5Il6BAQfhdhu4mVeesnsixu8mcib6quZzE(o9nnPIvuuQcLm)s8SMtvcqoeT3ddnK3arHmsAIA4rlogocgfKrsUqUfO3gAXXW5dfEHefYijKl6R3gJKhrm9Ylnn1IJHJTrKavSnKzeBdCr)nnnhjpIy60EPPjvSIIsvOK5xUjEwZPkbihI27HbejDWBfYij8m8SMtvcqocwCMrgjH8O1qyFl4znNQeGCeS4mJmscT3ddIx4VsunLOqgjHN1CQsaYrWIZmYij0Epm0fReuiJKMOgE0IJHJGfNzfYijKl6RhVvIxi8ij6PfhdxiJAlrrTVl6JN1CQsaYrWIZmYij0EpmaB)kOgfuMOgE0IJHJGfNzfYijKl6R3gTUeyrIBK8iscQrbfNaATLemnBDjWIexbuKHOGgEtgSoydyMP7mnBDjWIehkcVlWTczKeYjGwBjbttQxcGCickn7QaItaT2scBIN1CQsaYrWIZmYij0Epm0fReuiJKMOgE0IJHJGfNzfYijKl6R3gAXXW5dfEHefYijKlKBbMM8mxHClW1fReuiJKCJ4APGc3OH3IIkwzEZPkbUUyLGczKKJ3isrfRyAQfhdhbJcYijx0Ft8SMtvcqocwCMrgjH27Hby7xb1OGYe1WJwCmCeS4mRqgjHCrF8SMtvcqocwCMrgjH27Hb24IkKrstudpAXXWrWIZSczKeYfYTattT4y48HcVqIczKeYf917cT4y4iyuqgj5I(MMJKhrmDA1hpR5uLaKJGfNzKrsO9EyyK8iscQwxcSirPjnlEwZPkbihbloZiJKq79WGFewdVlWTsB1icpR5uLaKJGfNzKrsO9EyGNaUaiytsqnwnRGN1CQsaYrWIZmYij0EpmOTYmOYHImeLaewVXZAovja5iyXzgzKeAVhgidrfbAzeeuJeYLjQHhT4y4GcN5LGqQrc5Il6BAQfhdhu4mVeesnsixu8mcib6quZzE(o9XZAovja5iyXzgzKeAVhgAfBegeOkhkom3IWZAovja5iyXzgzKeAVhgqc0xaKcrf4EIA4bkdOGmATLO3fnNQe4qc0xaKcrf42va1yv3geEwZPkbihbloZiJKq79WaIKo4TczK0Fq(c)zCYl19NE6Fa]] )


end