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
        volley = 22497, -- 260243
        explosive_shot = 22498, -- 212431

        trailblazer = 19347, -- 199921
        natural_mending = 19348, -- 270581
        camouflage = 23100, -- 199483

        steady_focus = 22267, -- 193533
        streamline = 22286, -- 260367
        hunters_mark = 21998, -- 257284

        born_to_be_wild = 22268, -- 266921
        posthaste = 22276, -- 109215
        binding_shot = 22499, -- 109248

        lethal_shots = 23063, -- 260393
        barrage = 23104, -- 120360
        double_tap = 22287, -- 260402

        calling_the_shots = 22274, -- 260404
        lock_and_load = 22308, -- 194595
        piercing_shot = 22288, -- 198670
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3564, -- 196029
        adaptation = 3563, -- 214027
        gladiators_medallion = 3565, -- 208683

        trueshot_mastery = 658, -- 203129
        hiexplosive_trap = 657, -- 236776
        scatter_shot = 656, -- 213691
        spider_sting = 654, -- 202914
        scorpid_sting = 653, -- 202900
        viper_sting = 652, -- 202797
        survival_tactics = 651, -- 202746
        dragonscale_armor = 649, -- 202589
        roar_of_sacrifice = 3614, -- 53480
        rangers_finesse = 659, -- 248443
        sniper_shot = 660, -- 203155
        hunting_pack = 3729, -- 203235
    } )

    -- Auras
    spec:RegisterAuras( {
        a_murder_of_crows = {
            id = 131894,
            duration = 15,
            max_stack = 1,
        },
        aspect_of_the_cheetah = {
            id = 186257,
            duration = 9,
            max_stack = 1,
        },
        aspect_of_the_turtle = {
            id = 186265,
            duration = 8,
            max_stack = 1,
        },
        binding_shot = {
            id = 117405,
            duration = 3600,
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
            id = 260395,
            duration = 15,
            max_stack = 1,
        },
        lock_and_load = {
            id = 194594,
            duration = 15,
            max_stack = 1,
        },
        lone_wolf = {
            id = 155228,
            duration = 3600,
            max_stack = 1,
        },
        master_marksman = {
            id = 269576,
            duration = 12,
            max_stack = 1,
        },
        misdirection = {
            id = 35079,
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
            duration = 2.97,
            max_stack = 1,
        },
        serpent_sting = {
            id = 271788,
            duration = 12,
            type = "Poison",
            max_stack = 1,
        },
        steady_focus = {
            id = 193534,
            duration = 12,
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


        -- Azerite Powers
        unerring_vision = {
            id = 274447,
            duration = function () return buff.trueshot.duration end,
            max_stack = 10,
            meta = {
                stack = function () return buff.unerring_vision.up and max( 1, ceil( query_time - buff.trueshot.applied ) ) end,
            }
        },
    } )


    spec:RegisterStateExpr( "ca_execute", function ()
        return talent.careful_aim.enabled and ( target.health.pct > 80 or target.health.pct < 20 )
    end )


    spec:RegisterHook( "reset_precast", function ()
        if now - action.serpent_sting.lastCast < gcd.execute * 2 and target.unit == action.serpent_sting.lastUnit then
            applyDebuff( "target", "serpent_sting" )
        end
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
            cast = function () return buff.lock_and_load.up and 0 or ( 2.5 * haste ) end,
            charges = 2,
            cooldown = function () return haste * ( ( PTR and buff.trueshot.up ) and 4.8 or 12 ) end,
            recharge = function () return haste * ( ( PTR and buff.trueshot.up ) and 4.8 or 12 ) end,
            gcd = "spell",

            spend = function () return buff.lock_and_load.up and 0 or 30 end,
            spendType = "focus",

            startsCombat = true,
            texture = 135130,

            handler = function ()
                applyBuff( "precise_shots" )
                if talent.master_marksman.enabled then applyBuff( "master_marksman" ) end
                removeBuff( "lock_and_load" )
                removeBuff( "steady_focus" )
                removeBuff( "lethal_shots" )
                removeBuff( "double_tap" )
            end,
        },


        arcane_shot = {
            id = 185358,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.master_marksman.up and 0 or 15 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132218,

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                removeBuff( "master_marksman" )
                removeStack( "precise_shots" )
                removeBuff( "steady_focus" )
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

            handler = function ()
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
                removeBuff( "steady_focus" )
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
            gcd = "spell",

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
            cooldown = function () return azerite.natures_salve.enabled and 105 or 120 end,
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

            handler = function ()
                applyDebuff( "target", "explosive_shot" )
                removeBuff( "steady_focus" )
            end,
        },


        explosive_shot_detonate = not PTR and {
            id = 212679,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1044088,

            usable = function () return prev_gcd[1].explosive_shot end,
            handler = function ()
            end,
        } or nil,


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

            talent = "hunters_mark",

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

            spend = function () return buff.master_marksman.up and 0 or 15 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132330,

            handler = function ()
                if talent.calling_the_shots.enabled then cooldown.trueshot.expires = max( 0, cooldown.trueshot.expires - 2.5 ) end
                if active_enemies > 2 then applyBuff( "trick_shots" ) end
                removeBuff( "master_marksman" )
                removeStack( "precise_shots" )
                removeBuff( "steady_focus" )
            end,
        },


        piercing_shot = {
            id = 198670,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 35,
            spendType = "focus",

            startsCombat = true,
            texture = 132092,

            handler = function ()
                removeBuff( "steady_focus" )
            end,
        },


        rapid_fire = {
            id = 257044,
            cast = function () return ( 3 * haste ) + ( talent.streamline.enabled and 0.6 or 0 ) end,
            channeled = true,
            cooldown = function () return buff.trueshot.up and ( haste * 8 ) or 20 end,
            gcd = "spell",

            startsCombat = true,
            texture = 461115,

            handler = function ()
                applyBuff( "rapid_fire" )
                removeBuff( "lethal_shots" )
                removeBuff( "trick_shots" )
            end,
            postchannel = function () removeBuff( "double_tap" ) end,
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
                removeBuff( "steady_focus" )
            end,
        },


        steady_shot = {
            id = 56641,
            cast = 1.75,
            cooldown = 0,
            gcd = "spell",

            spend = -10,
            spendType = "focus",

            startsCombat = true,
            texture = 132213,

            handler = function ()
                if talent.steady_focus.enabled then applyBuff( "steady_focus", 12, min( 2, buff.steady_focus.stack + 1 ) ) end
                if debuff.concussive_shot.up then debuff.concussive_shot.expires = debuff.concussive_shot.expires + 4 end
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

            usable = function () return false and not pet.exists end, -- turn this into a pref!
            handler = function ()
                summonPet( 'made_up_pet', 3600, 'ferocity' )
            end,
        },


        survival_of_the_fittest = {
            id = 281195,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136094,

            usable = function () return not pet.alive end,
            handler = function ()
                applyBuff( "survival_of_the_fittest" )
            end,
        },


        tar_trap = {
            id = 187698,
            cast = 0,
            cooldown = 30,
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 132329,

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


    spec:RegisterPack( "Marksmanship", 20190722.0001, [[dquX1aqijLEKKcBcQ0OKu1PKu5vqHzjj5wui0Ui1VufgMG4yqjltsQNPkvMMQu11OqABqf6Bqfmobj5CcszDuiQ5rbDpOQ9PkLdkivTqOupKcr6IuiiJKcb6KuiGvkOMjfIWnfKuTtOOHkiP8uLAQQIUkfcQ9QYFPYGP0HLAXQQhJ0KL4YeBwOpljgnjoTOvlivETQKzRKBts7g0VvmCboofIOLd55ath11PQTdv03PqnEbjopfy9skA(u0(r8H1982LMLdZQdbRqleCO6Q1HGfwV3O3MniqUDqtF1vKBdBv52H6n6fqTHaLm42bTbRPl3ZBdgpIk3UgeRcZbaJ8JhvswX)10r9biv9RMZbsrDKFasv6JB)95IncaV)TlnlhMvhcwHwi4q1vRdbRqcnJA0B3Ewzq3ENQgP3wjlfbE)Bxea921Gyd1B0lGAdbkzaXAe0dzbrcxdIvH5aGr(XJkjR4)A6O(aKQ(vZ5aPOoYpaPk9bjCni2W(LbeB1yvfXwDiyfAeRrKyRoeJ87nkjmjCniwJuLgwragzs4AqSgrIn0xkeRNZvYgqSbOCqjBaXYdXg6d1msOjHRbXAejwJWaHy5uvC84kPqSOMveeXYknKy5gvrynNQIJhxjfILhITHCsZGMfIvGfIDIelDu)nRV9kbm4EEBgL0xaLHb3ZdtSUN3UPCoWB)BeQRi3wG9FjLd7JpmR(EE7MY5aVTekbRbK4uCaLHVTa7)skh2hFy(U75Tfy)xs5W(2uuYck7B)9XOMrj9LdOmmq7diwCjwA7KqrOEwiwCj2Vpg1LX)xIJ7aTp42nLZbE7ovLIdOm8XhMV)EEBb2)LuoSVnfLSGY(2FFmQzusF5akdd0(aIfxITEITRPGsw0XH6bsXftKOfy)xsHynnj2UMckzrNqhRioKIbSIQg1Wxe7BelweRPjX21uqjlAGhvjHvCaLHbAb2)LuiwttIL7LaznGrsRUsOOfy)xsHyR72nLZbEBuhKfxmrYXhMg9EEBb2)LuoSVnfLSGY(2FFmQzusF5akdd0(aIfxITEI97JrDasOjqCaLHb6YymKynnjw6mRYymu3PQuCaLH1r)A5qcvPrvehNQcXAiX2uohOUtvP4akdRPnGDCQkeRPjX(9XOMrEbOmS2hqS1D7MY5aVDNQsXbug(4dtC8EEBb2)LuoSVnfLSGY(2FFmQzusF5akdd0(GB3uoh4TrDqwCXejhFyId3ZBlW(VKYH9TPOKfu23(7JrnJs6lhqzyGUmgdjwttI97JrDasOjqCaLHbAFaXIlXwlX(9XOMrEbOmS2hqSMMeBCOEaX(gXIdHC7MY5aVTQFXjqz4Jpmdv3ZB3uoh4TJd1dKIRRPGswCFPvVTa7)skh2hFygA3ZB3uoh4Td8OmAqcR4(RgW3wG9FjLd7JpmXkK75TBkNd820bsfiJAwkU4QvLBlW(VKYH9XhMyH1982nLZbE7)AMIBIowrCcuun42cS)lPCyF8HjwvFpVTa7)skh23MIswqzF7Vpg1iH(AjaGloiQO9beRPjX(9XOgj0xlbaCXbrfhD8qwqAa30xeRHelwHC7MY5aVnRiop8pEyXfhevo(WeR3DpVDt5CG3oifenHvCaLHVTa7)skh2hFyI17VN3UPCoWB3ovpQii3eDu0ym42cS)lPCyF8Hjwg9EEBb2)LuoSVnfLSGY(2ijIeGs)xcXIlXwlX2uohOgiOabYoaNWk6e6IRSIcF7MY5aVnqqbcKDaoHvo(WelC8EE7MY5aVnGLUyGdOm8Tfy)xs5W(4JVDrITFX3ZdtSUN3wG9FjLd7BtrjlOSVDr((yutBaNWkAFaXAAsSf57JrDjbbYA1)L4u7kjv7diwttITiFFmQljiqwR(VeNarDfr7dUDt5CG3M2RLRPCoq3kb8TxjGDWwvUTNZvYgC8Hz13ZBlW(VKYH9TPOKfu23(7JrnJ8cqzyTpGynnj2AjwUxcK10ETsyfhRioGYWaTa7)skeRPjXYPQ44XvsHynKyXkKBdBv52v6Lq71sqa3Fg4TBkNd82v6Lq71sqa3Fg4XhMV7EEBb2)LuoSVnfLSGY(21sSFFmQzKxakdR9belUeB9eBTeRaacKk6)AMIBIowrCcuunqR2HUbrSMMeBTeRaacKk6)AMIBIowrCcuunqJA4lI9n8e77i26iwttITiFFmQ)RzkUj6yfXjqr1aTpGynnjwovfhpUskeRHeRrVnSvLBhm0xcdYAkfhDud8CZ5aDfbNjvUDt5CG3oyOVegK1uko6Og45MZb6kcotQC8H57VN3wG9FjLd7BtrjlOSV93hJAg5fGYWAFaXAAsS1sSCVeiRP9ALWkowrCaLHbAb2)LuiwttILtvXXJRKcXAiXwDi3UPCoWB7bIlzrfC8HPrVN3wG9FjLd7B3uoh4TP9A5AkNd0TsaF7vcyhSvLBtlGJpmXX75Tfy)xs5W(2uuYck7B3uoXP4eOOMcGynKyF3TBkNd820ETCnLZb6wjGV9kbSd2QYTb8XhM4W982cS)lPCyFBkkzbL9TBkN4uCcuutbqSVrSvF7MY5aVnTxlxt5CGUvc4BVsa7GTQCBgL0xaLHbhF8TdqcDu)nFppmX6EE7MY5aVDWW5aVTa7)skh2hFyw9982nLZbEBfpKfeWP2Ox3wG9FjLd7JpmF3982cS)lPCyF7aKqBa74uvUnwHC7MY5aVDz8)L44o44dZ3FpVDt5CG324bTk4usOdjGb2qQCBb2)LuoSp(W0O3ZB3uoh4TR4BujBOBIUUMcAyLBlW(VKYH9XhM44982nLZbEBvrDqg4MOB5PzXvqsRcUTa7)skh2hFyId3ZBlW(VKYH9TdqcTbSJtv52yPn6TBkNd82mYlaLHVnfLSGY(2nLtCkobkQPai23i2Qp(WmuDpVTa7)skh23MIswqzF7MYjofNaf1uaeRHe77UDt5CG3UtvP4akdF8X3Mwa3ZdtSUN3wG9FjLd7BtrjlOSVDr((yuR4HSGao1g9sxgJHelUeBTe73hJAg5fGYWAFWTBkNd82kEiliGtTrVo(WS675Tfy)xs5W(2uuYck7BtNzvgJHAuhKfxmrIgjQDcbeRHeBfAHynnjw6mRYymuJ6GS4Ijs0irTtiGynKyPZSkJXqDNQsXbugwJe1oHaI10Ky5uvC84kPqSgsSvhYTBkNd82LX)xIJ7GJpmF3982cS)lPCyFBkkzbL9T)(yuZiVaugw7diwCj26jwovfhpUske7BelDMvzmgQ)cciOxjSIU4rnNdKyXGylEuZ5ajwttITEILBufH1ksVyfDaLjwdj2QdHynnj2AjwUxcK10gjr)Y1PQwG9FjfIToIToI10Ky5uvC84kPqSgsSy9UB3uoh4T)cciOxjSYXhMV)EEBb2)LuoSVnfLSGY(2FFmQzKxakdR9belUeB9elNQIJhxjfI9nILoZQmgd1)1mfx0Jmqx8OMZbsSyqSfpQ5CGeRPjXwpXYnQIWAfPxSIoGYeRHeB1HqSMMeBTel3lbYAAJKOF56uvlW(VKcXwhXwhXAAsSCQkoECLuiwdjwSWXB3uoh4T)RzkUOhzWXhMg9EEBb2)LuoSVnfLSGY(2FFmQzKxakdR9belUeB9elNQIJhxjfI9nILoZQmgd1nKkag1lhTxlDXJAohiXIbXw8OMZbsSMMeB9el3OkcRvKEXk6aktSgsSvhcXAAsS1sSCVeiRPnsI(LRtvTa7)skeBDeBDeRPjXYPQ44XvsHynKyXchVDt5CG3UHubWOE5O9AD8HjoEpVTa7)skh23MIswqzF7Vpg1mYlaLH1(aIfxITEILtvXXJRKcX(gXsNzvgJH6yIK)AMIU4rnNdKyXGylEuZ5ajwttITEILBufH1ksVyfDaLjwdj2QdHynnj2AjwUxcK10gjr)Y1PQwG9FjfIToIToI10Ky5uvC84kPqSgsSH2TBkNd82Xej)1mLJpmXH75TBkNd82RSIcdCHoFPIQa5BlW(VKYH9XhMHQ75Tfy)xs5W(2uuYck7B)9XOELr5VMPObCtFrSgsSVNyXLyRLy)(yuZiVaugw7dUDt5CG324bTk4usOdjGb2qQC8HzODpVTa7)skh23MIswqzF76jwA7KqrOEwiwttILtvXXJRKcX(gXwnwHqS1rS4sS1tSFFmQzKxakdR9beRPjXsNzvgJHAg5fGYWAKO2jeqSgsSyHJeBDeRPjXYPQ44XvsHynKyFxi3UPCoWBxX3Os2q3eDDnf0WkhFyIvi3ZBlW(VKYH9TPOKfu23MoZQmgd1mYlaLH1irTtiGynKyXHB3uoh4TrzqWsCj0bcAQC8HjwyDpVTa7)skh23MIswqzF7Aj2Vpg1mYlaLH1(GB3uoh4Tvf1bzGBIULNMfxbjTk44dtSQ(EEBb2)LuoSVnfLSGY(2FFmQzKxakdRrstzIfxI97Jr9Fntz5bSgjnLjwttI97JrnJ8cqzyTpGyXLyPTtcfH6zHynnjwovfhpUskeRHeB1g92nLZbE7GHZbE8HjwV7EEBb2)LuoSVnfLSGY(2XH6be7BelogcXIlXwpX(9XOoaj0eioGYWaDzmgsS4sS0zwLXyOg1bzXftKOrIANqaXIlXYPQ44XvsHyFJyPZSkJXqnJ8cqzyDXJAohORIxaaIfdIT4rnNdKynnjwUrvewRi9Iv0buMynKyRoeI10KyRLy5EjqwtBKe9lxNQAb2)Lui26iwttILtvXXJRKcXAiXILrVDt5CG3MrEbOm8XhFBaFppmX6EE7MY5aVTekbRbK4uCaLHVTa7)skh2hFyw9982cS)lPCyFBkkzbL9TBkN4uCcuutbqSVrSyD7MY5aV9VrOUIC8H57UN3UPCoWB3ovpQii3eDu0ym42cS)lPCyF8H57VN3wG9FjLd7BtrjlOSVnsIibO0)LqS4sS1sSnLZbQbckqGSdWjSIoHU4kROW3UPCoWBdeuGazhGtyLJpmn6982cS)lPCyFBkkzbL9T)(yuZiVaugwxgJHeRPjXghQhqSgsS4qi3UPCoWBJ6GS4Ijso(WehVN3wG9FjLd7BtrjlOSV93hJAg5fGYWAFaXIlXwpX(9XO2dfekHvC4mb5a1aUPVi23i23tSMMeBTeBxtbLSO9qbHsyfhotqoqTa7)skeBDeRPjXYPQ44XvsHynKyXcRB3uoh4T)RzkUj6yfXjqr1GJpmXH75Tfy)xs5W(2uuYck7BxlX(9XOMrEbOmS2hC7MY5aVDCOEGuCDnfuYI7lT6XhMHQ75Tfy)xs5W(2uuYck7B)9XOMrEbOmS2hqS4sSFFmQvBaliNAJEbuBO2hqS4sS1sSFFmQvf1bzGBIULNMfxbjTkq7dUDt5CG3Ur0gkoGYWhFygA3ZBlW(VKYH9TPOKfu23(7JrnJ8cqzyTpGynnj26j2Vpg1LX)xIJ7aDzmgsSMMelTDsOiupleBDelUe73hJ6aKqtG4akdd0LXyiXAAsSr)A5qcvPrvehNQcXAiXsBa74uviwCjw6mRYymuZiVaugwJe1oHGB3uoh4T7uvkoGYWhFyIvi3ZBlW(VKYH9TPOKfu23(7JrnJ8cqzyTpGyXLy)(yuR2awqo1g9cO2qTpGyXLy)(yuRkQdYa3eDlpnlUcsAvG2hC7MY5aVDJOnuCaLHp(WelSUN3UPCoWBhKcIMWkoGYW3wG9FjLd7JpmXQ675Tfy)xs5W(2uuYck7BxlX(9XOMrEbOmS2hC7MY5aVDGhLrdsyf3F1a(4dtSE3982cS)lPCyFBkkzbL9TRLy)(yuZiVaugw7dUDt5CG3MoqQazuZsXfxTQC8HjwV)EEBb2)LuoSVnfLSGY(2FFmQrc91saaxCqur7diwttI97JrnsOVwca4IdIko64HSG0aUPViwdjwSc52nLZbEBwrCE4F8WIloiQC8Hjwg9EEBb2)LuoSVnfLSGY(2FFmQzKxakdRlJXqIfxITEI97JrDasOjqCaLHbAFaXIlXwpXghQhqSVrSVhlI10Ky)(yuR2awqo1g9cO2qTpGyRJynnj26j24q9aI9nI1OHqS4sSDnfuYIooupqkUyIeTa7)skeRPjXghQhqSVrS4Grj26iwCj26jw6mRYymuZiVaugwJe1oHaI9nI1OeRPjXghQhqSVrSHQqi26iwttILtvXXJRKcXAiXAuITUB3uoh4TBeTHIdOm8XhMyHJ3ZB3uoh4TbS0fdCaLHVTa7)skh2hF8T9CUs2G75Hjw3ZB3uoh4TPJhYcYbug(2cS)lPCyF8Hz13ZB3uoh4TbcsGjBGR4b8Tfy)xs5W(4dZ3DpVDt5CG3gemiXrxJVCBb2)LuoSp(W893ZB3uoh4TbZWkjSIZ4Mf0Tfy)xs5W(4dtJEpVDt5CG3gmWK6(RgW3wG9FjLd7JpmXX75TBkNd82qHveKdOm0x3wG9FjLd7JpmXH75TBkNd82uLm0LahJAOrsFUs2GBlW(VKYH9XhMHQ75TBkNd82GGeLSdOm0x3wG9FjLd7JpmdT75TBkNd82WM9ib4QGAQCBb2)LuoSp(4JVnofeih4Hz1HGvOfcouD1324gbtyfWTncOgmiwkelosSnLZbsSReWanj8TdqtmxYTRbXgQ3Oxa1gcuYaI1iOhYcIeUgeRcZbaJ8JhvswX)10r9biv9RMZbsrDKFasv6ds4AqSH9ldi2QXQkIT6qWk0iwJiXwDig53Busys4AqSgPknSIamYKW1GynIeBOVuiwpNRKnGydq5Gs2aILhIn0hQzKqtcxdI1isSgHbcXYPQ44XvsHyrnRiiILvAiXYnQIWAovfhpUskelpeBd5KMbnleRale7ejw6O(BwtctcxdI1iuOiuplfI9lXbjelDu)ntSFPscbAIn0tPsadiw4anIknsn6xeBt5CGaIDGld0KW1GyBkNdeOdqcDu)nJpUAWls4AqSnLZbc0biHoQ)MXa)J2xrvGCZ5ajHRbX2uohiqhGe6O(Bgd8pIZuiHRbXUHDaqzyIf1zHy)(yukelGBgqSFjoiHyPJ6VzI9lvsiGyByHydqIrmyyoHvi2eqSLbkAs4AqSnLZbc0biHoQ)MXa)daSdakd7aCZas4MY5ab6aKqh1FZyG)rWW5ajHBkNdeOdqcDu)nJb(hkEiliGtTrViHRbXgQHeAdyILvsaX2aIvA0YaITbeBWaa5FjelpeBWWcKZETmGyR0jKyB4WkcIyPnGj2IhLWkelRieBmROWAs4MY5ab6aKqh1FZyG)rz8)L44oOQaKqBa74uvWJviKWnLZbc0biHoQ)MXa)dJh0QGtjHoKagydPcjCt5CGaDasOJ6VzmW)OIVrLSHUj66AkOHviHBkNdeOdqcDu)nJb(hQI6GmWnr3YtZIRGKwfqc3uohiqhGe6O(Bgd8pyKxakdxvasOnGDCQk4XsB0QYi(MYjofNaf1uaVvnjCt5CGaDasOJ6VzmW)OtvP4akdxvgX3uoXP4eOOMcWW3rctc3uohiq75CLSb4PJhYcYbugMeUPCoqG2Z5kzdWa)dGGeyYg4kEatc3uohiq75CLSbyG)biyqIJUgFHeUPCoqG2Z5kzdWa)dWmSscR4mUzbrc3uohiq75CLSbyG)byGj19xnGjHBkNdeO9CUs2amW)akSIGCaLH(IeUPCoqG2Z5kzdWa)dQsg6sGJrn0iPpxjBajCt5CGaTNZvYgGb(hGGeLSdOm0xKWnLZbc0EoxjBag4FaB2JeGRcQPcjmjCniwJqHIq9SuiwbNcYaILtvHyzfHyBkpiInbeBJZox9FjAs4MY5ab4P9A5AkNd0TsaxfSvf8EoxjBqvzeFr((yutBaNWkAFGPzr((yuxsqGSw9Fjo1Uss1(atZI89XOUKGazT6)sCce1veTpGeUPCoqag4F4bIlzrTkyRk4R0lH2RLGaU)mWQYi(Vpg1mYlaLH1(atZA5Ejqwt71kHvCSI4akdd0cS)lPyAYPQ44XvsXqScHeUPCoqag4F4bIlzrTkyRk4dg6lHbznLIJoQbEU5CGUIGZKkvLr81(9XOMrEbOmS2hGB91kaGaPI(VMP4MOJveNafvd0QDOBqMM1kaGaPI(VMP4MOJveNafvd0Og(6n8VRotZI89XO(VMP4MOJveNafvd0(attovfhpUskgAus4AqSprgqS8qSRekeRpGyBkN4SzPqSmkHVegqSgNScX(e5fGYWKWnLZbcWa)dpqCjlQGQYi(Vpg1mYlaLH1(atZA5Ejqwt71kHvCSI4akdd0cS)lPyAYPQ44XvsXWQdHeUPCoqag4Fq71Y1uohOBLaUkyRk4PfajCt5CGamW)G2RLRPCoq3kbCvWwvWd4QYi(MYjofNaf1uag(os4MY5abyG)bTxlxt5CGUvc4QGTQGNrj9fqzyqvzeFt5eNItGIAkG3QMeMeUPCoqGMwa4v8qwqaNAJEvvgXxKVpg1kEiliGtTrV0LXyiU1(9XOMrEbOmS2hqc3uohiqtlamW)Om()sCChuvgXtNzvgJHAuhKfxmrIgjQDcbgwHwmnPZSkJXqnQdYIlMirJe1oHadPZSkJXqDNQsXbugwJe1oHattovfhpUskgwDiKWnLZbc00cad8p(cciOxjSsvze)3hJAg5fGYWAFaU1ZPQ44Xvs5n6mRYymu)feqqVsyfDXJAohigfpQ5CGMM1ZnQIWAfPxSIoGYgwDiMM1Y9sGSM2ij6xUov1cS)lPuxDMMCQkoECLumeR3rc3uohiqtlamW)4VMP4IEKbvLr8FFmQzKxakdR9b4wpNQIJhxjL3OZSkJXq9FntXf9id0fpQ5CGyu8OMZbAAwp3OkcRvKEXk6akBy1HyAwl3lbYAAJKOF56uvlW(VKsD1zAYPQ44XvsXqSWrs4MY5abAAbGb(hnKkag1lhTxRQYi(Vpg1mYlaLH1(aCRNtvXXJRKYB0zwLXyOUHubWOE5O9APlEuZ5aXO4rnNd00SEUrvewRi9Iv0bu2WQdX0SwUxcK10gjr)Y1PQwG9FjL6QZ0KtvXXJRKIHyHJKWnLZbc00cad8pIjs(RzkvLr8FFmQzKxakdR9b4wpNQIJhxjL3OZSkJXqDmrYFntrx8OMZbIrXJAohOPz9CJQiSwr6fROdOSHvhIPzTCVeiRPnsI(LRtvTa7)sk1vNPjNQIJhxjfddns4MY5abAAbGb(hRSIcdCHoFPIQazs4MY5abAAbGb(hgpOvbNscDibmWgsLQYi(Vpg1Rmk)1mfnGB6ldFpU1(9XOMrEbOmS2hqc3uohiqtlamW)OIVrLSHUj66AkOHvQkJ4RN2ojueQNfttovfhpUskVvnwHuhU1)9XOMrEbOmS2hyAsNzvgJHAg5fGYWAKO2jeyiw4yDMMCQkoECLum8DHqc3uohiqtlamW)aLbblXLqhiOPsvzepDMvzmgQzKxakdRrIANqGH4ajCt5CGanTaWa)dvrDqg4MOB5PzXvqsRcQkJ4R97JrnJ8cqzyTpGeUPCoqGMwayG)rWW5aRkJ4)(yuZiVaugwJKMY4(9XO(VMPS8awJKMYMMFFmQzKxakdR9b4sBNekc1ZIPjNQIJhxjfdR2OKWnLZbc00cad8pyKxakdxvgXhhQh8gogcU1)9XOoaj0eioGYWaDzmgIlDMvzmgQrDqwCXejAKO2jeGlNQIJhxjL3OZSkJXqnJ8cqzyDXJAohORIxaamkEuZ5ann5gvryTI0lwrhqzdRoetZA5EjqwtBKe9lxNQAb2)LuQZ0KtvXXJRKIHyzusys4MY5abAaJxcLG1asCkoGYWKWnLZbc0agd8p(nc1vKQYi(MYjofNaf1uaVHfjCt5CGanGXa)J2P6rfb5MOJIgJbKWnLZbc0agd8packqGSdWjSsvzepsIibO0)LGBTnLZbQbckqGSdWjSIoHU4kROWKWnLZbc0agd8pqDqwCXejvLr8FFmQzKxakdRlJXqtZ4q9adXHqiHRbXMr8FFmQzKxakdR9b4w)3hJApuqOewXHZeKdud4M(6T3BAwBxtbLSO9qbHsyfhotqoqTa7)sk1zAYnQIWAovfhpUskgIfwKWnLZbc0agd8p(RzkUj6yfXjqr1GQYi(Vpg1mYlaLH1(aCR)7JrThkiucR4WzcYbQbCtF927nnRTRPGsw0EOGqjSIdNjihOwG9FjL6mn5uvC84kPyiwyrc3uohiqdymW)ioupqkUUMckzX9LwTQmIV2Vpg1mYlaLH1(as4MY5abAaJb(hnI2qXbugUQmI)7JrnJ8cqzyTpa3Vpg1QnGfKtTrVaQnu7dWT2Vpg1QI6GmWnr3YtZIRGKwfO9bKWnLZbc0agd8p6uvkoGYWvLr8FFmQzKxakdR9bMM1)9XOUm()sCChOlJXqttA7KqrOEwQd3Vpg1biHMaXbuggOlJXqtZOFTCiHQ0OkIJtvXqAdyhNQcU0zwLXyOMrEbOmSgjQDcbKWnLZbc0agd8pAeTHIdOmCvze)3hJAg5fGYWAFaUFFmQvBaliNAJEbuBO2hG73hJAvrDqg4MOB5PzXvqsRc0(as4MY5abAaJb(hbPGOjSIdOmmjCt5CGanGXa)JapkJgKWkU)QbCvzeFTFFmQzKxakdR9bKWnLZbc0agd8pOdKkqg1SuCXvRkvLr81(9XOMrEbOmS2hqc3uohiqdymW)GveNh(hpS4IdIkvLr8FFmQrc91saaxCqur7dmn)(yuJe6RLaaU4GOIJoEilinGB6ldXkes4MY5abAaJb(hnI2qXbugUQmI)7JrnJ8cqzyDzmgIB9FFmQdqcnbIdOmmq7dWT(4q9G3EpwMMFFmQvBaliNAJEbuBO2huNPz9XH6bVz0qWTRPGsw0XH6bsXftKOfy)xsX0moup4nCWO1HB90zwLXyOMrEbOmSgjQDcbVzutZ4q9G3cvHuNPjNQIJhxjfdnADKWnLZbc0agd8paS0fdCaLHjHjHBkNdeOzusFbuggG)3iuxriHBkNdeOzusFbuggGb(hsOeSgqItXbugMeUPCoqGMrj9fqzyag4F0PQuCaLHRkJ4)(yuZOK(YbuggO9b4sBNekc1ZcUFFmQlJ)Veh3bAFajCt5CGanJs6lGYWamW)a1bzXftKuvgX)9XOMrj9LdOmmq7dWT(UMckzrhhQhifxmrIwG9FjftZUMckzrNqhRioKIbSIQg1WxVHLPzxtbLSObEuLewXbuggOfy)xsX0K7LaznGrsRUsOOfy)xsPos4MY5abAgL0xaLHbyG)rNQsXbugUQmI)7JrnJs6lhqzyG2hGB9FFmQdqcnbIdOmmqxgJHMM0zwLXyOUtvP4akdRJ(1YHeQsJQioovfdBkNdu3PQuCaLH10gWoovftZVpg1mYlaLH1(G6iHBkNdeOzusFbuggGb(hOoilUyIKQYi(Vpg1mkPVCaLHbAFajCt5CGanJs6lGYWamW)q1V4eOmCvze)3hJAgL0xoGYWaDzmgAA(9XOoaj0eioGYWaTpa3A)(yuZiVaugw7dmnJd1dEdhcHeUPCoqGMrj9fqzyag4FehQhifxxtbLS4(sRsc3uohiqZOK(cOmmad8pc8OmAqcR4(RgWKWnLZbc0mkPVakddWa)d6aPcKrnlfxC1QcjCt5CGanJs6lGYWamW)4VMP4MOJveNafvdiHBkNdeOzusFbuggGb(hSI48W)4HfxCquPQmI)7JrnsOVwca4IdIkAFGP53hJAKqFTeaWfhevC0XdzbPbCtFziwHqc3uohiqZOK(cOmmad8pcsbrtyfhqzys4MY5abAgL0xaLHbyG)r7u9OIGCt0rrJXas4MY5abAgL0xaLHbyG)bqqbcKDaoHvQkJ4rsejaL(VeCRTPCoqnqqbcKDaoHv0j0fxzffMeUPCoqGMrj9fqzyag4FayPlg4akdFBqGqpmR2OV)4JVda]] )
end