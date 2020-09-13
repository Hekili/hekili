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

    spec:RegisterStateExpr( "ca_active", function ()
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
            cooldown = 20,
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


    spec:RegisterPack( "Marksmanship", 20200913, [[duuCebqiLQ6ruLOnPszuksoLIuRIQKGxPsmlfHBrvsQDrPFbvAyufDmLkltr0ZOk00Oa11uuABkvPVrvsnoLQOZrbI1rbszEkQUhfAFuahuPkulKc6HuLe6IuGunsQsI6KuGKwPsXmPaj6MkvHStOIHsvsKNQIPQs6QuGe2lWFjzWu5WswmP8yKMSqxMyZk8zOQrtQoTuRwPk41QunBLCBOSBi)w0WPQoovjjlxvph00rDDbBxrX3vknEQs48uLA9ufmFkA)igSdCfCIflaCM0Zj90tdYopA3T3znypNfCyV9fWXVO3l8c4GkmbC2JQ)oeRqq92hC8lVxzfbxbhygEQaoEjXPZSp0GgU4IVz9GMLMy4cBSWQ4or0VgmUWgJIl4Of6fBqfb0aNyXcaNj9Csp90GSZJ2D7Dwd2ZjbNkW65doNgZRi4O3XOGaAGtuGuWXljU9O6VdXkeuV9joVYbelpzJxsChXNfmn5jUDECcIBspN0tWz1qgcUco8307q9KHGRaC2bUcofL7eboA1)fEbCeuPTKiWqadWzsWvWPOCNiWr8c)vc7zefupzWrqL2sIadbmahpcUcocQ0wseyi4q)MLVlWrlmgw(B6DfupzOn4tC3ioAPeVqObwiUBeNwymSXmOTefx(2Gp4uuUte4unMevq9KbmahdgCfCeuPTKiWqWH(nlFxGJwymS8307kOEYqBWN4UrCtrCLhKVzXosAakr1OFXkOsBjrIZ0K4kpiFZITrkwxuVU3SoM9l0DIZae3oIZ0K4kpiFZIfgE8ncVcQNm0kOsBjrIZ0K44Aji2c5xkSvJeRGkTLejUPbNIYDIaNV87OA0VayaoZcUcocQ0wseyi4q)MLVlWrlmgw(B6DfupzOn4tC3iUPioTWyy9FH2qrb1tgAJ5weXzAsC0mxXClYwnMevq9KTJWAPEHQxpErXnMqCZjUIYDISvJjrfupzlTGSIBmH4mnjoTWyy5piq9KTbFIBAWPOCNiWPAmjQG6jdyao7fCfCeuPTKiWqWH(nlFxGJwymS8307kOEYqBWhCkk3jcC(YVJQr)cGb441GRGJGkTLebgco0Vz57cC0cJHL)MExb1tgAJ5weXzAsCAHXW6)cTHIcQNm0g8jUBe3(eNwymS8heOEY2GpXzAsCJKgGeNbioV2tWPOCNiWblS4gQNmGb4SNGRGtr5orGZiPbOevLhKVzrPjfg4iOsBjrGHagGJbbCfCkk3jcC8dFp8Ur4vARcYGJGkTLebgcyao78eCfCkk3jcCOjIki(lwIQXQWeWrqL2sIadbmaND7axbNIYDIahTvMrvouSUOeKG5n4iOsBjrGHagGZUjbxbhbvAljcmeCOFZY3f4Ofgd7l07lbcvJ8PIn4tCMMeNwymSVqVVeiunYNkkAgqS8wix07e3CIBNNGtr5orGdRlQasldOOAKpvamaNDEeCfCkk3jcCkfw4JYRYHI(5wi4iOsBjrGHagGZodgCfCeuPTKiWqWH(nlFxGZlJxG6L2siUBe3(exr5orwO8(cIvqUr4TnsnwnEDgCkk3jcCGY7liwb5gHhWaC2nl4k4uuUte4azPIERG6jdocQ0wseyiGbm4eLrfwm4kaNDGRGJGkTLebgco0Vz57cCIIwymS0cYncVn4tCMMeNwymSXg6lRvPTefwHVP2GpXzAsCAHXWgBOVSwL2suc6l8In4dofL7ebo0ATufL7ePwnKbNvdzfQWeWjW9QzVbmaNjbxbhbvAljcmeCkk3jcCwH)U8qvJGDSZauHVhm4q)MLVlWHM5kMBrw(dcupz7lyvJGk8bbcjU5e3UzjottIJBmrXPk2cXnN48ONGdQWeWzf(7Ydvnc2Xodqf(EWagGJhbxbhbvAljcmeCkk3jcCkpa1RVGQrIyvou(5w5bh63S8DbotrCCJjkovXwiodqCfL7ePOzUI5weXDH48ObtCMMehxpEHT6sTyDRpLjU5e3KEsCMMehxpEHTCJjkov(uwnPNe3CIB3Se30e3nIJM5kMBrw(dcupz7lyvJGk8bbcjU5e3UzjottIJBmrXPk2cXnN484SGdQWeWP8auV(cQgjIv5q5NBLhWaCmyWvWrqL2sIadbNIYDIaNvaYFgGk85kkiL)kGv4fWH(nlFxGdnZvm3IS8heOEY2xWQgbv4dcesCZjUzjottIJBmrXPk2cXnN4M0tWbvyc4Scq(ZauHpxrbP8xbScVayaoZcUcocQ0wseyi4uuUte4GVwcTwl5HkTmrGd9Bw(Uah)xMrHNgT7S8heOEYeNPjXTpXX1sqSLwRvJWRyDrb1tgAfuPTKiXzAsCCJjkovXwiU5e3opbhuHjGd(Aj0ATKhQ0Yebyao7fCfCeuPTKiWqWPOCNiWPG6ZuibQ(Yd5RO5xlWH(nlFxGJ)lZOWtJ2Dw(dcupzI7gXnfXPfgdl(q9XUqQCOkpiFY62GpXzAsC7tCcekiQyPjkkiOevREiJ8PIfR2d5tC3ioAPeVqObwiUPjottIlkAHXW(LhYxrZVwQOOfgdBm3IiottIJBmrXPk2cXnN4M0tWbvyc4uq9zkKavF5H8v08RfGb441GRGJGkTLebgcofL7ebo(j9UWW2dsurtm)axCNivuMPPc4q)MLVlWzFItlmgw(dcupzBWN4UrC7tCcekiQy1wzgv5qX6IsqcM3wSApKpXzAsCrrlmgwTvMrvouSUOeKG5Tn4tCMMeh3yIItvSfIBoXnl4GkmbC8t6DHHThKOIMy(bU4orQOmttfadWzpbxbhbvAljcmeCOFZY3f44)Ymk80ODNL)Ga1tM4mnjU9joUwcIT0ATAeEfRlkOEYqRGkTLejottIJBmrXPk2cXnN4M0tWPOCNiWjafvZcgeWaCmiGRGJGkTLebgcofL7ebo0ATufL7ePwnKbNvdzfQWeWHgHagGZopbxbhbvAljcmeCOFZY3f4uuUNrucsWAbsCZjopcofL7ebo0ATufL7ePwnKbNvdzfQWeWbYagGZUDGRGJGkTLebgco0Vz57cCkk3ZikbjyTajodqCtcofL7ebo0ATufL7ePwnKbNvdzfQWeWH)MEhQNmeWagC8FHMyAfdUcWzh4k4uuUte4OhqS8qfw93bhbvAljcmeWaCMeCfCeuPTKiWqWX)fAbzf3yc4SZtWPOCNiWjMbTLO4YhWaC8i4k4iOsBjrGHGdQWeWP8auV(cQgjIv5q5NBLhCkk3jcCkpa1RVGQrIyvou(5w5bmahdgCfCkk3jcC2M)koJ0i1lWeviQaocQ0wseyiGb4ml4k4uuUte4GpuFSlKkhQYdYNSo4iOsBjrGHagGZEbxbNIYDIahmblFVv5qTc0oQIVuyqWrqL2sIadbmahVgCfCeuPTKiWqWX)fAbzf3yc4SZol4uuUte4WFqG6jdo0Vz57cCkk3ZikbjyTajodqCtcyao7j4k4uuUte44NCNiWrqL2sIadbmahdc4k4iOsBjrGHGd9Bw(UaNIY9mIsqcwlqIBoX5rWPOCNiWPAmjQG6jdyado0ieCfGZoWvWrqL2sIadbh63S8Dborrlmgw9aILhQWQ)UnMBre3nIBFItlmgw(dcupzBWhCkk3jcC0diwEOcR(7agGZKGRGJGkTLebgco0Vz57cCOzUI5wK9l)oQg9l2xWQgbjU5ehEAK4mnjoAMRyUfz)YVJQr)I9fSQrqIBoXrZCfZTiB1ysub1t2(cw1iiXzAsCCJjkovXwiU5e3KEcofL7eboXmOTefx(agGJhbxbhbvAljcmeCOFZY3f44)Ymk80ODNL)Ga1tM4UrCtrCC94f2YnMO4ufBH4maXrZCfZTiRM8q5V3i82y4lUteXDH4IHV4oreNPjXnfXX1JxyRUulw36tzIBoXnPNeNPjXTpXX1sqSLwVmclv1ywbvAljsCttCttCMMeh3yIItvSfIBoXTZJGtr5orGJM8q5V3i8agGJbdUcocQ0wseyi4q)MLVlWX)Lzu4Pr7ol)bbQNmXDJ4MI446XlSLBmrXPk2cXzaIJM5kMBrwTvMr1i8EBJHV4ore3fIlg(I7erCMMe3uehxpEHT6sTyDRpLjU5e3KEsCMMe3(ehxlbXwA9YiSuvJzfuPTKiXnnXnnXzAsCCJjkovXwiU5e3U9cofL7eboARmJQr49gWaCMfCfCeuPTKiWqWH(nlFxGJ)lZOWtJ2Dw(dcupzI7gXnfXX1Jxyl3yIItvSfIZaehnZvm3ISfIkq(RLIwRLng(I7erCxiUy4lUteXzAsCtrCC94f2Ql1I1T(uM4MtCt6jXzAsC7tCCTeeBP1lJWsvnMvqL2sIe30e30eNPjXXnMO4ufBH4MtC72l4uuUte4uiQa5VwkATwagGZEbxbhbvAljcmeCOFZY3f44)Ymk80ODNL)Ga1tM4UrCtrCC94f2YnMO4ufBH4maXrZCfZTi7OFrBLz0gdFXDIiUlexm8f3jI4mnjUPioUE8cB1LAX6wFktCZjUj9K4mnjU9joUwcIT06LryPQgZkOsBjrIBAIBAIZ0K44gtuCQITqCZjodc4uuUte4m6x0wzgbmahVgCfCeuPTKiWqWH(nlFxGJwymS8heOEY2yUfbofL7eboRgVodv7HqepMGyadWzpbxbhbvAljcmeCOFZY3f4Ofgdl)bbQNSnMBrGtr5orGJwHxLdf)n9oeWaCmiGRGJGkTLebgco0Vz57cC0cJHL)Ga1t2gZTiI7gXnfXX1JxyRUulw36tzIZae3E6jXzAsCC94f2Ql1I1T(uM4MBK4M0tIZ0K446XlSLBmrXPYNYQj9K4maX5rpjUPbNIYDIaNxk)gHxnwfMabmaNDEcUcocQ0wseyi4q)MLVlWzkIJM5kMBr2Ydq96lOAKiwLdLFUvE7lyvJGeNbiUj9K4mnjU9joXRk0((s0wEaQxFbvJeXQCO8ZTYtCMMeh3yIItvSfIBoXrZCfZTiB5bOE9funseRYHYp3kVng(I7erCxiopAWe3nIJRhVWwDPwSU1NYeNbiUj9K4MM4UrCtrC0mxXClYYFqG6jBFbRAeuHpiqiXnN48iXzAsCtrCcekiQyNPHDIu5q5l)qOCNilwJYN4UrCCJjkovXwiodqCfL7ePOzUI5weXDH40cJHDB(R4msJuVatuHOIng(I7erCttCttCMMeh3yIItvSfIBoXnPNGtr5orGZ28xXzKgPEbMOcrfadWz3oWvWrqL2sIadbh63S8DbotrC0sjEHqdSqCMMehxpEHTCJjkovXwiodqCfL7ePOzUI5weXDH48ONe30e3nIBkItlmgw(dcupzBWN4mnjoAMRyUfz5piq9KTVGvncsCZjUD7L4MM4mnjoUXefNQyle3CIZJ7aNIYDIah8H6JDHu5qvEq(K1bmaNDtcUcocQ0wseyi4q)MLVlWHM5kMBrw(dcupz7lyvJGe3CIZRbNIYDIaNV99xIQrkOFrfadWzNhbxbhbvAljcmeCOFZY3f4SpXPfgdl)bbQNSn4dofL7eboycw(ERYHAfODufFPWGagGZodgCfCkk3jcCEbMOIBeEv9FUfCeuPTKiWqadWz3SGRGtr5orGtukwxr1R7FHbocQ0wseyiGb4SBVGRGtr5orGZ2Efvq)(BgcocQ0wseyiGb4SZRbxbNIYDIaNXQ8wIkOEYGJGkTLebgcyao72tWvWrqL2sIadbh63S8DboAHXWYFqG6jBFPOmXDJ40cJHvBLzCfGS9LIYeNPjX5)Ymk80ODNL)Ga1tM4UrCC94f2Ql1I1T(uM4MtCt6jXzAsCtrCtrC0ebdyL2sS(j3jsLdvaP9DCjr1i8EtCMMehnrWawPTeBaP9DCjr1i8EtCttC3ioUE8cB5gtuCQITqCZjU9UJ4mnjoUXefNQyle3CIBY9sCtdofL7ebo(j3jcWaC2zqaxbhbvAljcmeCOFZY3f4Ofgdl)bbQNSnMBre3nIJM5kMBr2V87OA0VyFbRAeK4mnjoUXefNQyle3CIB3SGtr5orGd)bbQNmGbm4azWvao7axbNIYDIahXl8xjSNruq9KbhbvAljcmeWaCMeCfCeuPTKiWqWH(nlFxGtr5EgrjibRfiXzaIBh4uuUte4Ov)x4fadWXJGRGtr5orGtPWcFuEvou0p3cbhbvAljcmeWaCmyWvWrqL2sIadbh63S8DboVmEbQxAlH4UrC7tCfL7ezHY7liwb5gH32i1y141zWPOCNiWbkVVGyfKBeEadWzwWvWrqL2sIadbh63S8DboAHXWYFqG6jBJ5weXzAsCJKgGe3CIZJZsCMMe3iPbiXnN42RNe3nIBFIJRLGy7sy9APG6jdTcQ0wsK4mnjoTWyyBKI1f1R7nRJzFbRAeK4MtCIxi0alkUXeWPOCNiW5l)oQg9lagGZEbxbhbvAljcmeCOFZY3f4Ofgdl)bbQNSn4tC3iUPioTWyydi5)gHxntd7ezHCrVtCgG4myIZ0K42N4kpiFZInGK)BeE1mnStKvqL2sIe30eNPjXXnMO4ufBH4MtC72bofL7eboARmJQCOyDrjibZBadWXRbxbhbvAljcmeCOFZY3f4SpXPfgdl)bbQNSn4tCMMeh3yIItvSfIBoXnl4uuUte4msAakrv5b5BwuAsHbyao7j4k4iOsBjrGHGd9Bw(UahTWyy5piq9KTbFI7gXPfgdlwbz5vy1FhIviBWN4UrC7tCAHXWIjy57TkhQvG2rv8LcdAd(Gtr5orGt90cjkOEYagGJbbCfCeuPTKiWqWH(nlFxGJwymS8heOEY2GpXDJ40cJHfRGS8kS6VdXkKn4tC3iU9joTWyyXeS89wLd1kq7Ok(sHbTbFWPOCNiWHQ3yL8LcQNmGb4SZtWvWrqL2sIadbh63S8DboAHXWYFqG6jBd(eNPjXnfXPfgdBmdAlrXLVnMBreNPjXrlL4fcnWcXnnXDJ40cJH1)fAdffupzOnMBreNPjXncRL6fQE94ff3ycXnN4OfKvCJje3nIJM5kMBrw(dcupz7lyvJGGtr5orGt1ysub1tgWaC2TdCfCeuPTKiWqWH(nlFxGJwymS8heOEY2GpXDJ40cJHfRGS8kS6VdXkKn4tC3ioTWyyXeS89wLd1kq7Ok(sHbTbFWPOCNiWPEAHefupzadWz3KGRGJGkTLebgco0Vz57cC0cJHL)Ga1t2g8jUBeNwymSyfKLxHv)DiwHSbFI7gXPfgdlMGLV3QCOwbAhvXxkmOn4dofL7ebou9gRKVuq9KbmaNDEeCfCeuPTKiWqWH(nlFxGZ(eNwymS8heOEY2GpXzAsCCJjkovXwiU5e3EcofL7ebo(HVhE3i8kTvbzadWzNbdUcocQ0wseyi4q)MLVlWzK0aK4UqCJKgG2xWliIZRaXHNgjU5e3iPbOfR8cI7gXPfgdl)bbQNSnMBre3nIBkIBFIlMSLMiQG4VyjQgRctuAHhzFbRAeK4UrC7tCfL7ezPjIki(lwIQXQWeBJuJvJxNjUPjottIBewl1lu96XlkUXeIBoXHNgjottIJRhVWwUXefNQyle3CIBwWPOCNiWHMiQG4VyjQgRctamaNDZcUcocQ0wseyi4q)MLVlWrlmg2xO3xceQg5tfBWN4mnjoTWyyFHEFjqOAKpvu0mGy5TqUO3jU5e3opjottIJBmrXPk2cXnN4MfCkk3jcCyDrfqAzafvJ8PcGb4SBVGRGJGkTLebgco0Vz57cC0cJHL)Ga1t2gZTiI7gXnfXPfgdR)l0gkkOEYqBWN4UrCtrCJKgGeNbiUzNL4mnjoTWyyXkilVcR(7qSczd(e30eNPjXnsAasCgG486zjottIJBmrXPk2cXnN4ML4MgCkk3jcCQNwirb1tgWaC251GRGJGkTLebgco0Vz57cC0cJHL)Ga1t2gZTiI7gXnfXPfgdR)l0gkkOEYqBWN4UrCtrCJKgGeNbiUzNL4mnjoTWyyXkilVcR(7qSczd(e30eNPjXnsAasCgG486zjottIJBmrXPk2cXnN4ML4MgCkk3jcCO6nwjFPG6jdyao72tWvWPOCNiWbYsf9wb1tgCeuPTKiWqadyWjW9QzVbxb4SdCfCkk3jcCOzaXYRG6jdocQ0wseyiGb4mj4k4uuUte4aLxqn7TkgGm4iOsBjrGHagGJhbxbNIYDIahOF(IIUYqeCeuPTKiWqadWXGbxbNIYDIahyMSEJWR2wS8GJGkTLebgcyaoZcUcofL7eboWe1uL2QGm4iOsBjrGHagGZEbxbNIYDIahKW6YRG6j9o4iOsBjrGHagGJxdUcofL7ebou9Ep0qf)fYRk0RM9gCeuPTKiWqadWzpbxbNIYDIahOF)nRG6j9o4iOsBjrGHagGJbbCfCkk3jcCqfhEbQW)fvahbvAljcmeWagWGZmYd7ebWzspN0tp3ZjniGZ26rncpeCmOI5NplrIBVexr5ore3QHm0s2ao(Fo6LaoEjXThv)DiwHG6TpX5voGy5jB8sI7i(SGPjpXTZJtqCt65KEs2q24LeNxr9cHxGg0iB8sIZRM42JJrIlW9QzVjo)VZVzVjoojU9yVsguAjB8sIZRM4mOakeh3yIItvSfI7lwxEIJ1leXX1Jxyl3yIItvSfIJtIRqCtB)IfItqrIlhehnX0k2s2q24LeNbDVqObwIeNMmYxioAIPvmXPj4Be0sC7XuQ4ZqIdLiVA96XgHfXvuUteK4s0YBlzJxsCfL7ebT(VqtmTInowf8ozJxsCfL7ebT(VqtmTIVye3kGhtqCXDIiB8sIROCNiO1)fAIPv8fJ4oYms24Le3bv(q9KjUV6iXPfgdjsCqUyiXPjJ8fIJMyAftCAc(gbjUcfjo)x8Q9tMBeEIRHexmrILSXljUIYDIGw)xOjMwXxmIlev(q9KvqUyiztr5orqR)l0etR4lgXvpGy5HkS6Vt24LeNxPxOfKjowVHexbjoP(L3exbjo)ecBTLqCCsC(jliUR1YBIdF1iIRqjRlpXrlitCXW3i8ehRle3OXRZwYMIYDIGw)xOjMwXxmIBmdAlrXL)e(VqliR4gtmUZtYMIYDIGw)xOjMwXxmIBakQMfSjqfMyS8auV(cQgjIv5q5NBLNSPOCNiO1)fAIPv8fJ4Un)vCgPrQxGjQquHSPOCNiO1)fAIPv8fJ4IpuFSlKkhQYdYNSoztr5orqR)l0etR4lgXftWY3BvouRaTJQ4lfgKSPOCNiO1)fAIPv8fJ4YFqG6jpH)l0cYkUXeJ7SZorpmwuUNrucsWAbAGjjBkk3jcA9FHMyAfFXiU(j3jISPOCNiO1)fAIPv8fJ4wnMevq9KNOhglk3ZikbjyTaN7rYgYMIYDIG2a3RM92indiwEfupzYMIYDIG2a3RM9(IrCHYlOM9wfdqMSPOCNiOnW9QzVVyexOF(IIUYqKSPOCNiOnW9QzVVyexyMSEJWR2wS8KnfL7ebTbUxn79fJ4ctutvARcYKnfL7ebTbUxn79fJ4IewxEfupP3jBkk3jcAdCVA27lgXLQ37HgQ4VqEvHE1S3KnfL7ebTbUxn79fJ4c97VzfupP3jBkk3jcAdCVA27lgXfvC4fOc)xuHSHSXljod6EHqdSejozg59M44gtiowxiUIY5tCnK4QzQEvAlXs2uuUte0iTwlvr5orQvd5jqfMymW9QzVNOhgJIwymS0cYncVn4BAQfgdBSH(YAvAlrHv4BQn4BAQfgdBSH(YAvAlrjOVWl2Gpztr5orWlgXnafvZc2eOctmUc)D5HQgb7yNbOcFp4j6HrAMRyUfz5piq9KTVGvncQWheiC(Uznn5gtuCQITm3JEs2uuUte8IrCdqr1SGnbQWeJLhG61xq1irSkhk)CR8t0dJtXnMO4ufBXa0mxXCl6IhnyttUE8cB1LAX6wFkpFspnn56XlSLBmrXPYNYQj9C(UzN(gnZvm3IS8heOEY2xWQgbv4dceoF3SMMCJjkovXwM7XzjBkk3jcEXiUbOOAwWMavyIXvaYFgGk85kkiL)kGv4Lj6HrAMRyUfz5piq9KTVGvncQWheiC(SMMCJjkovXwMpPNKnfL7ebVye3auunlytGkmXi(Aj0ATKhQ0Yenrpm6)Ymk80ODNL)Ga1t20CFUwcIT0ATAeEfRlkOEYqRGkTLenn5gtuCQITmFNNKnfL7ebVye3auunlytGkmXyb1NPqcu9LhYxrZVwt0dJ(VmJcpnA3z5piq9KVnLwymS4d1h7cPYHQ8G8jRBd(MM7lqOGOILMOOGGsuT6HmYNkwSApK)nAPeVqObwM20mkAHXW(LhYxrZVwQOOfgdBm3Imn5gtuCQITmFspjBkk3jcEXiUbOOAwWMavyIr)KExyy7bjQOjMFGlUtKkkZ0uzIEyCFTWyy5piq9KTb)B7lqOGOIvBLzuLdfRlkbjyEBXQ9q(MMrrlmgwTvMrvouSUOeKG5Tn4BAYnMO4ufBz(SKnEjXD99M44K4wnsiUGpXvuUNPyjsC83O7cdjUTnRtCx)Ga1tMSPOCNi4fJ4gGIQzbdorpm6)Ymk80ODNL)Ga1t20CFUwcIT0ATAeEfRlkOEYqRGkTLenn5gtuCQITmFspjBkk3jcEXiU0ATufL7ePwnKNavyIrAes2uuUte8IrCP1APkk3jsTAipbQWeJqEIEySOCpJOeKG1cCUhjBkk3jcEXiU0ATufL7ePwnKNavyIr(B6DOEYWj6HXIY9mIsqcwlqdmjzdztr5orqlncnQhqS8qfw93NOhgJIwymS6belpuHv)DBm3IUTVwymS8heOEY2Gpztr5orqlncVye3yg0wIIl)j6HrAMRyUfz)YVJQr)I9fSQrW54PrttAMRyUfz)YVJQr)I9fSQrW50mxXClYwnMevq9KTVGvncAAYnMO4ufBz(KEs2uuUte0sJWlgXvtEO83Be(j6Hr)xMrHNgT7S8heOEY3MIRhVWwUXefNQylgGM5kMBrwn5HYFVr4TXWxCNOlXWxCNitZP46XlSvxQfRB9P88j900CFUwcIT06LryPQgZkOsBjXPN20KBmrXPk2Y8DEKSPOCNiOLgHxmIR2kZOAeEVNOhg9FzgfEA0UZYFqG6jFBkUE8cB5gtuCQITyaAMRyUfz1wzgvJW7Tng(I7eDjg(I7ezAofxpEHT6sTyDRpLNpPNMM7Z1sqSLwVmclv1ywbvAljo90MMCJjkovXwMVBVKnfL7ebT0i8IrClevG8xlfTwRj6Hr)xMrHNgT7S8heOEY3MIRhVWwUXefNQylgGM5kMBr2crfi)1srR1YgdFXDIUedFXDImnNIRhVWwDPwSU1NYZN0ttZ95Aji2sRxgHLQAmRGkTLeNEAttUXefNQylZ3TxYMIYDIGwAeEXiUJ(fTvMXj6Hr)xMrHNgT7S8heOEY3MIRhVWwUXefNQylgGM5kMBr2r)I2kZOng(I7eDjg(I7ezAofxpEHT6sTyDRpLNpPNMM7Z1sqSLwVmclv1ywbvAljo90MMCJjkovXwMBqiBkk3jcAPr4fJ4UA86muThcr8ycINOhg1cJHL)Ga1t2gZTiYMIYDIGwAeEXiUAfEvou8307Wj6HrTWyy5piq9KTXClISPOCNiOLgHxmI7lLFJWRgRctGt0dJAHXWYFqG6jBJ5w0TP46XlSvxQfRB9PSb2tpnn56XlSvxQfRB9P8CJt6PPjxpEHTCJjkov(uwnPNgWJEonztr5orqlncVye3T5VIZins9cmrfIkt0dJtrZCfZTiB5bOE9funseRYHYp3kV9fSQrqdmPNMM7lEvH23xI2Ydq96lOAKiwLdLFUvEttUXefNQylZPzUI5wKT8auV(cQgjIv5q5NBL3gdFXDIU4rd(gxpEHT6sTyDRpLnWKEo9TPOzUI5wKL)Ga1t2(cw1iOcFqGW5E00CkbcfevSZ0WorQCO8LFiuUtKfRr5FJBmrXPk2IbOzUI5w0fTWyy3M)koJ0i1lWeviQyJHV4ortpTPj3yIItvSL5t6jztr5orqlncVyex8H6JDHu5qvEq(K1NOhgNIwkXleAGfttUE8cB5gtuCQITyaAMRyUfDXJEo9TP0cJHL)Ga1t2g8nnPzUI5wKL)Ga1t2(cw1i48D7DAttUXefNQylZ94oYMIYDIGwAeEXiUF77VevJuq)Ikt0dJ0mxXClYYFqG6jBFbRAeCUxt2uuUte0sJWlgXftWY3BvouRaTJQ4lfgCIEyCFTWyy5piq9KTbFYMIYDIGwAeEXiUVatuXncVQ(p3s2uuUte0sJWlgXnkfRRO619VWiBkk3jcAPr4fJ4UTxrf0V)MHKnfL7ebT0i8IrChRYBjQG6jt2uuUte0sJWlgX1p5ort0dJAHXWYFqG6jBFPO8nTWyy1wzgxbiBFPOSPP)lZOWtJ2Dw(dcup5BC94f2Ql1I1T(uE(KEAAo1u0ebdyL2sS(j3jsLdvaP9DCjr1i8EBAstemGvAlXgqAFhxsuncV3tFJRhVWwUXefNQylZ37ottUXefNQylZNCVtt2uuUte0sJWlgXL)Ga1tEIEyulmgw(dcupzBm3IUrZCfZTi7x(Dun6xSVGvncAAYnMO4ufBz(UzjBiBkk3jcAHSrXl8xjSNruq9KjBkk3jcAH8fJ4Qv)x4Lj6HXIY9mIsqcwlqdSJSPOCNiOfYxmIBPWcFuEvou0p3cjBkk3jcAH8fJ4cL3xqScYnc)e9W4lJxG6L2sUTFr5orwO8(cIvqUr4TnsnwnEDMSPOCNiOfYxmI7x(Dun6xMOhg1cJHL)Ga1t2gZTitZrsdW5ECwtZrsdW571ZB7Z1sqSDjSETuq9KHwbvAljAAQfgdBJuSUOEDVzDm7lyvJGZfVqObwuCJjKnEjX1dJAHXWYFqG6jBd(3Mslmg2as(Vr4vZ0Worwix07gWGnn3V8G8nl2as(Vr4vZ0WorwbvAljoTPjxpEHTCJjkovXwMVBhztr5orqlKVyexTvMrvouSUOeKG59e9WOwymS8heOEY2G)TP0cJHnGK)BeE1mnStKfYf9UbmytZ9lpiFZInGK)BeE1mnStKvqL2sItBAYnMO4ufBz(UDKnfL7ebTq(IrChjnaLOQ8G8nlknPWMOhg3xlmgw(dcupzBW30KBmrXPk2Y8zjBkk3jcAH8fJ4wpTqIcQN8e9WOwymS8heOEY2G)nTWyyXkilVcR(7qSczd(32xlmgwmblFVv5qTc0oQIVuyqBWNSPOCNiOfYxmIlvVXk5lfup5j6HrTWyy5piq9KTb)BAHXWIvqwEfw93HyfYg8VTVwymSycw(ERYHAfODufFPWG2Gpztr5orqlKVye3QXKOcQN8e9WOwymS8heOEY2GVP5uAHXWgZG2suC5BJ5wKPjTuIxi0altFtlmgw)xOnuuq9KH2yUfzAocRL6fQE94ff3yYCAbzf3yYnAMRyUfz5piq9KTVGvncs2uuUte0c5lgXTEAHefup5j6HrTWyy5piq9KTb)BAHXWIvqwEfw93HyfYg8VPfgdlMGLV3QCOwbAhvXxkmOn4t2uuUte0c5lgXLQ3yL8LcQN8e9WOwymS8heOEY2G)nTWyyXkilVcR(7qSczd(30cJHftWY3BvouRaTJQ4lfg0g8jBkk3jcAH8fJ46h(E4DJWR0wfKNOhg3xlmgw(dcupzBW30KBmrXPk2Y89KSPOCNiOfYxmIlnrubXFXsunwfMmrpmosAaEzK0a0(cEb5vapnoFK0a0IvEXnTWyy5piq9KTXCl62u7ht2stevq8xSevJvHjkTWJSVGvncEB)IYDIS0erfe)flr1yvyITrQXQXRZtBAocRL6fQE94ff3yYC80OPjxpEHTCJjkovXwMplztr5orqlKVyexwxubKwgqr1iFQmrpmQfgd7l07lbcvJ8PIn4BAQfgd7l07lbcvJ8PIIMbelVfYf9(8DEAAYnMO4ufBz(SKnfL7ebTq(IrCRNwirb1tEIEyulmgw(dcupzBm3IUnLwymS(VqBOOG6jdTb)BtnsAaAGzN10ulmgwScYYRWQ)oeRq2G)0MMJKgGgWRN10KBmrXPk2Y8zNMSPOCNiOfYxmIlvVXk5lfup5j6HrTWyy5piq9KTXCl62uAHXW6)cTHIcQNm0g8Vn1iPbObMDwttTWyyXkilVcR(7qSczd(tBAosAaAaVEwttUXefNQylZNDAYMIYDIGwiFXiUqwQO3kOEYKnKnfL7ebT8307q9KHg1Q)l8cztr5orql)n9oupz4fJ4kEH)kH9mIcQNmztr5orql)n9oupz4fJ4wnMevq9KNOhg1cJHL)MExb1tgAd(3OLs8cHgy5MwymSXmOTefx(2Gpztr5orql)n9oupz4fJ4(LFhvJ(Lj6HrTWyy5VP3vq9KH2G)TPkpiFZIDK0auIQr)IvqL2sIMMLhKVzX2ifRlQx3BwhZ(f6Ub2zAwEq(Mflm84BeEfupzOvqL2sIMMCTeeBH8lf2QrIvqL2sItt2uuUte0YFtVd1tgEXiUvJjrfup5j6HrTWyy5VP3vq9KH2G)TP0cJH1)fAdffupzOnMBrMM0mxXClYwnMevq9KTJWAPEHQxpErXnMmVOCNiB1ysub1t2sliR4gtmn1cJHL)Ga1t2g8NMSPOCNiOL)MEhQNm8IrC)YVJQr)Ye9WOwymS8307kOEYqBWNSPOCNiOL)MEhQNm8IrCXclUH6jprpmQfgdl)n9UcQNm0gZTittTWyy9FH2qrb1tgAd(32xlmgw(dcupzBW30CK0a0aETNKnfL7ebT8307q9KHxmI7iPbOevLhKVzrPjfgztr5orql)n9oupz4fJ46h(E4DJWR0wfKjBkk3jcA5VP3H6jdVyexAIOcI)ILOASkmHSPOCNiOL)MEhQNm8IrC1wzgv5qX6IsqcM3KnfL7ebT8307q9KHxmIlRlQasldOOAKpvMOhg1cJH9f69LaHQr(uXg8nn1cJH9f69LaHQr(urrZaIL3c5IEF(opjBkk3jcA5VP3H6jdVye3sHf(O8QCOOFUfs2uuUte0YFtVd1tgEXiUq59feRGCJWprpm(Y4fOEPTKB7xuUtKfkVVGyfKBeEBJuJvJxNjBkk3jcA5VP3H6jdVyexilv0BfupzWb6luaotoRbdyadaa]] )


end