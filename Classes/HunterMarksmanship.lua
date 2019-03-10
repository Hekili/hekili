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
            cooldown = 120,
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

        potion = "potion_of_rising_death",

        package = "Marksmanship",
    } )


    spec:RegisterPack( "Marksmanship", 20190310.0134, [[dq0hMaqibPEKGKnrQYOeP6uIKELsvZsK4wcQQDrPFPuAyQQCmsvTmbLNPurttPsDnsLSnvvPVPQQmoLk05uvfRtPsmpsf3JuAFIuoOQQkluvPhQuj1fjvQyKKkv5KcQIwjf1mjvQQBQQQQDQQyOkvsEQsMQsXvjvQ0Ev5VcnysoSKfdLhJQjlQltSzv5ZuKrdvNMQvlOk9AsHzlLBtHDd53kgUioUGQWYr55ath56s12fu57KIgpPs58cI1RubZxG9d6t)BZTYfj3NW(P)F(Tt9)z)P)o3T(6FlkKe5wjfxJYKCluzi36)lMgaJcbW9KBLuH0MkFBUfy6mUCRqbv4eLa2LTBn5eEhZYhJTa3O3kYheNvpAlWn4BVfw3Bu4j6WUvUi5(e2p9)ZVDQ)p7VF7wxH9NBvDcFy3A5g76BH75SGoSBLfa)wHcQ()IPbWOqaCpbQ096isyqZHcQWjkbSlB3AYj8oMLpgBbUrVvKpioRE0wGBW3cnhkO6)lghhQ0)xkqvy)0)pqv4dv)(Tl7omOzO5qbv7A8czsa7c0COGQWhQ(VCgQ6K3CkeOkH5dZPqGkAGQ)BxP7BHMdfuf(qLUlqGkYnKinXSlqfRiCHbveEHGkQyMeYsUHePjMDbQObQke5CpPibQeugQMhuXhdSIS3Q5acCBUfXCUga8Ha3M7J(3MBvCYh0TWkgRmj3sqfwtY33JUpHDBUvXjFq3s0TK2a8Wjra(q3sqfwtY33JUp782ClbvynjFFVfN5KW86wy93ZsmNRreGpeW2tGk9GQ0HQAheMtI9n8oqYXNZeRGkSMKHQGaOQ2bH5KyDuKWLidpec3WYkKgqvAqL(qvqauv7GWCsSGoZKJmfb4dbScQWAsgQccGkQAcISaIjLrZrIvqfwtYqvQ3Q4KpOBXQephFoto6(S7BZTeuH1K899wCMtcZRBH1FplXCUgra(qaBpbQ0dQshQW6VNnHjChira(qaBE0ebvbbqfFMwE0ezl3qYra(q2xV1ImHJxmtsKCdbQ0bQko5dYwUHKJa8HS8cqrYneOk1BvCYh0Tk3qYra(qhDF01T5wcQWAs((EloZjH51TW6VNLyoxJiaFiGTNCRIt(GUfRs8C85m5O7ZFVn3sqfwtY33BXzojmVUfw)9SeZ5Aeb4dbS5rteufeavy93ZMWeUdKiaFiGTNavbbq1B4DauLgu9VF3Q4KpOBz0BKdWh6O7Z)Un3Q4KpOBL4cJ7itra(q3sqfwtY33JUp74T5wfN8bDRkA0zzHfNxKZgnb3sqfwtY33JUp)52ClbvynjFFVfN5KW86wm5XeaEH1eOspOk0qvXjFqwGWseefbKJmzDu81Ct40Tko5d6waHLiikcihz6O7J()Un3Q4KpOBbiPYHeb4dDlbvynjFFp6OBLLx1B0T5(O)T5wcQWAs((ERIt(GUfVATyXjFqXMdOBXzojmVUvwW6VNLxaYrMS9eOkiaQYcw)9SzhKiTwH1KOrzY52EcufeavzbR)E2SdsKwRWAsuqSYKy7j3Q5akIkd5wDYBofYr3NWUn3sqfwtY33BXzojmVUfw)9SeRla8HS9eOkiaQcnurvtqKLxTMJmfjCjcWhcyfuH1KmufeavKBirAIzxGkDGQW(DRIt(GUvhirNedWr3NDEBULGkSMKVV3Q4KpOBXRwlwCYhuS5a6wnhqruzi3INbhDF29T5wcQWAs((ERIt(GUfVATyXjFqXMdOBXzojmVUvXjpCsuqIHlaOshOAN3Q5akIkd5wa6O7JUUn3sqfwtY33BvCYh0T4vRflo5dk2CaDloZjH51Tko5HtIcsmCbavPbvHDRMdOiQmKBrmNRbaFiWrhDReMWhdSIUn3h9Vn3sqfwtY33JUpHDBULGkSMKVVhDF25T5wcQWAs((E09z33MBjOcRj577r3hDDBUvXjFq3kziFq3sqfwtY33JUp)92CRIt(GUfEhrcdenkMg3sqfwtY33JUp)72ClbvynjFFVvct4fGIKBi3s)F3Q4KpOBLNowtIuLC09zhVn3sqfwtY33BLWeEbOi5gYT03QRBvCYh0Tiwxa4dDloZjH51Tko5HtIcsmCbavPbvHD095p3MBjOcRj577T4mNeMx3Q4KhojkiXWfauPduTZBvCYh0Tk3qYra(qhD0T4zWT5(O)T5wcQWAs((EloZjH51TYcw)9S4Dejmq0OyAyZJMiOspOk0qfw)9SeRla8HS9KBvCYh0TW7isyGOrX04O7ty3MBjOcRj577T4mNeMx3IptlpAISSkXZXNZeltmkhbGkDGkt8mufeav8zA5rtKLvjEo(CMyzIr5iauPduXNPLhnr2YnKCeGpKLjgLJaqvqaurUHePjMDbQ0bQc73Tko5d6w5PJ1KivjhDF25T5wcQWAs((EloZjH51TW6VNLyDbGpKTNav6bvPdvKBirAIzxGQ0Gk(mT8OjYIjmGW0WrMS5oRiFqq1EOk3zf5dcQccGQ0HkQyMeYIlvJWTjCcQ0bQc7hufeavHgQOQjiYYlM86Ty5gwbvynjdvPcvPcvbbqf5gsKMy2fOshOs)DERIt(GUfMWactdhz6O7ZUVn3sqfwtY33BXzojmVUfw)9SeRla8HS9eOspOkDOICdjstm7cuLguXNPLhnrwS2m54RZcXM7SI8bbv7HQCNvKpiOkiaQshQOIzsilUunc3MWjOshOkSFqvqaufAOIQMGilVyYR3ILByfuH1KmuLkuLkufeavKBirAIzxGkDGk9)7Tko5d6wyTzYXxNfYr3hDDBULGkSMKVV3IZCsyEDlS(7zjwxa4dz7jqLEqv6qf5gsKMy2fOknOIptlpAISfIlaIvTiVAnBUZkYheuThQYDwr(GGQGaOkDOIkMjHS4s1iCBcNGkDGQW(bvbbqvOHkQAcIS8IjVElwUHvqfwtYqvQqvQqvqaurUHePjMDbQ0bQ0)V3Q4KpOBviUaiw1I8Q1o6(83BZTeuH1K899wCMtcZRBH1FplX6caFiBpbQ0dQshQi3qI0eZUavPbv8zA5rtK95mbRnt2M7SI8bbv7HQCNvKpiOkiaQshQOIzsilUunc3MWjOshOkSFqvqaufAOIQMGilVyYR3ILByfuH1KmuLkuLkufeavKBirAIzxGkDGQ)CRIt(GU1ZzcwBM8r3N)DBUvXjFq3Q5MWjqm82ZMmeeDlbvynjFFp6(SJ3MBjOcRj577T4mNeMx3cR)EwI1fa(qwMuCcQ0dQW6VNfRntU1bKLjfNGQGaOcR)EwI1fa(q2EcuPhuXROOBcVtcufeavKBirAIzxGkDGQW01Tko5d6wjd5d6O7ZFUn3sqfwtY33BXzojmVU1B4DauLgu93FqLEqv6qfw)9SjmH7ajcWhcyZJMiOspOIptlpAISSkXZXNZeltmkhbGk9GkYnKinXSlqvAqfFMwE0ezjwxa4dzZDwr(GIM6caav7HQCNvKpiOkiaQOIzsilUunc3MWjOshOkSFqvqaufAOIQMGilVyYR3ILByfuH1KmuLkufeavKBirAIzxGkDGk911Tko5d6weRla8Ho6OBbOBZ9r)BZTko5d6wIUL0gGhojcWh6wcQWAs((E09jSBZTeuH1K899wCMtcZRBvCYdNefKy4caQsdQ0)wfN8bDlSIXktYr3NDEBUvXjFq3QIgDwwyX5f5SrtWTeuH1K899O7ZUVn3sqfwtY33BXzojmVUftEmbGxynbQ0dQcnuvCYhKfiSebrra5itwhfFn3eoDRIt(GUfqyjcIIaYrMo6(ORBZTeuH1K899wCMtcZRBH1FplX6caFiBE0ebvbbq1B4DauPdu9VF3Q4KpOBXQephFoto6(83BZTeuH1K899wCMtcZRBH1FplX6caFiBpbQ0dQW6VN1OaKWIgftdGrHS9KBvCYh0TkgVqseGp0r3N)DBULGkSMKVV3IZCsyEDlS(7zjwxa4dz7jqvqauLouH1FpBE6ynjsvInpAIGQGaOIxrr3eENeOkvOspOcR)E2eMWDGeb4dbS5rteufeavVERfzchVyMKi5gcuPduXlafj3qUvXjFq3QCdjhb4dD09zhVn3Q4KpOBL4cJ7itra(q3sqfwtY33JUp)52ClbvynjFFVfN5KW86wy93ZsSUaWhYMhnrqLEqv6qfw)9SjmH7ajcWhcy7jqLEqv6q1B4DauLguTB9HQGaOcR)EwJcqclAumnagfY2tGQuHQGaOkDO6n8oaQsdQ01pOspOQ2bH5KyFdVdKC85mXkOcRjzOkiaQEdVdGQ0GQ)PlOkvOspOkDOIptlpAISeRla8HSmXOCeaQsdQ0fufeavVH3bqvAq1o(dQsfQccGkYnKinXSlqLoqLUGQuVvXjFq3Qy8cjra(qhDF0)3T5wfN8bDlajvoKiaFOBjOcRj577rhDRo5nNc52CF0)2CRIt(GUfF6isyra(q3sqfwtY33JUpHDBUvXjFq3cimb5uiXChq3sqfwtY33JUp782CRIt(GUfizysK3ME(wcQWAs((E09z33MBvCYh0TaZq4oYuuZIe2TeuH1K899O7JUUn3Q4KpOBbgKZJyTcq3sqfwtY33JUp)92CRIt(GUfsiCHfb4dxJBjOcRj577r3N)DBUvXjFq3IJ7HxhejwHcp6EZPqULGkSMKVVhDF2XBZTko5d6wGeN5ueGpCnULGkSMKVVhDF(ZT5wfN8bDlurDMaIMyfxULGkSMKVVhD0r3kCcd4d6(e2p9)ZVW0)F2F)(TJ3sZIHCKjWTcpnsggjzO6VqvXjFqqvZbeWcnFRe288MCRqbv)FX0ayuiaUNav6EDejmO5qbv4eLa2LTBn5eEhZYhJTa3O3kYheNvpAlWn4BHMdfu9)fJJdv6)lfOkSF6)hOk8HQF)2LDhg0m0COGQDnEHmjGDbAouqv4dv)xodvDYBofcuLW8H5uiqfnq1)TR09TqZHcQcFOs3fiqf5gsKMy2fOIveUWGkcVqqfvmtczj3qI0eZUav0avfICUNuKavckdvZdQ4JbwrwOzO5qbv6o6MW7KKHkm5nmbQ4JbwrqfMyYralu9FCUKqaOcnOWhVygVEdQko5dcavdQfIfAU4KpiGnHj8XaRiTVwb0aAU4KpiGnHj8XaRO9A3wDtgcIkYhe0CXjFqaBct4Jbwr71U9ntgAouq1cvja8HGkw5zOcR)EsgQauraOctEdtGk(yGveuHjMCeaQkugQsys4Nme5itqLdGQ8Gel0CXjFqaBct4Jbwr71UfGQea(qraveaAU4KpiGnHj8XaRO9A3MmKpiO5It(Ga2eMWhdSI2RDlEhrcdenkMgqZHcQ2vmHxacQiChavfaQKI1cbQkauLmaGJ1eOIgOkzibrE1AHavMkhbvfAiCHbv8cqqvUZCKjOIWfO65MWjl0CXjFqaBct4Jbwr71UnpDSMePkjLeMWlafj3q0Q)pO5It(Ga2eMWhdSI2RDlX6caFOusycVauKCdrR(wDLI)0wCYdNefKy4ciTWGMlo5dcytycFmWkAV2TLBi5iaFOu8N2ItE4KOGedxa6StOzO5It(Ga2o5nNcrlF6isyra(qqZfN8bbSDYBofYETBbctqofsm3be0CXjFqaBN8MtHSx7wqYWKiVn9m0CXjFqaBN8MtHSx7wWmeUJmf1SiHbnxCYheW2jV5ui71UfmiNhXAfGGMlo5dcy7K3CkK9A3Iecxyra(W1aAU4KpiGTtEZPq2RDlh3dVoisScfE09MtHanxCYheW2jV5ui71UfK4mNIa8HRb0CXjFqaBN8MtHSx7wurDMaIMyfxGMHMdfuP7OBcVtsgQKWjSqGkYneOIWfOQ40WGkhavv4kVvynXcnxCYheqlVATyXjFqXMdOuqLHOTtEZPqsXFAZcw)9S8cqoYKTNeeKfS(7zZoirATcRjrJYKZT9KGGSG1FpB2bjsRvynjkiwzsS9eOzO5qbvByHav0avnhjqvpbQko5HRijdveZrAieaQ00jCOAdRla8HGMlo5dcSx72oqIojgGu8NwS(7zjwxa4dz7jbbHMQMGilVAnhzks4seGpeWkOcRj5GaYnKinXSl6e2pO5It(Ga71ULxTwS4KpOyZbukOYq0YZaO5It(Ga71ULxTwS4KpOyZbukOYq0cOu8N2ItE4KOGedxa6StO5It(Ga71ULxTwS4KpOyZbukOYq0smNRbaFiqk(tBXjpCsuqIHlG0cdAgAU4KpiGLNbAX7isyGOrX0if)Pnly93ZI3rKWarJIPHnpAI0l0y93ZsSUaWhY2tGMlo5dcy5zWETBZthRjrQssXFA5Z0YJMilRs8C85mXYeJYraDmXZbb8zA5rtKLvjEo(CMyzIr5iGo8zA5rtKTCdjhb4dzzIr5iqqa5gsKMy2fDc7h0CXjFqalpd2RDlMWactdhzkf)PfR)EwI1fa(q2EIEPtUHePjMDjn(mT8OjYIjmGW0WrMS5oRiFq7ZDwr(GccsNkMjHS4s1iCBcN0jSFbbHMQMGilVyYR3ILByfuH1KCQPgeqUHePjMDrh93j0CXjFqalpd2RDlwBMC81zHKI)0I1FplX6caFiBprV0j3qI0eZUKgFMwE0ezXAZKJVoleBUZkYh0(CNvKpOGG0PIzsilUunc3MWjDc7xqqOPQjiYYlM86Ty5gwbvynjNAQbbKBirAIzx0r))cnxCYheWYZG9A3wiUaiw1I8Q1sXFAX6VNLyDbGpKTNOx6KBirAIzxsJptlpAISfIlaIvTiVAnBUZkYh0(CNvKpOGG0PIzsilUunc3MWjDc7xqqOPQjiYYlM86Ty5gwbvynjNAQbbKBirAIzx0r))cnxCYheWYZG9A3(CMG1MjNI)0I1FplX6caFiBprV0j3qI0eZUKgFMwE0ezFotWAZKT5oRiFq7ZDwr(GccsNkMjHS4s1iCBcN0jSFbbHMQMGilVyYR3ILByfuH1KCQPgeqUHePjMDrN)anxCYheWYZG9A32Ct4eigE7ztgcIGMlo5dcy5zWETBtgYhuk(tlw)9SeRla8HSmP4KEy93ZI1Mj36aYYKItbby93ZsSUaWhY2t0Jxrr3eENKGaYnKinXSl6eMUGMlo5dcy5zWETBjwxa4dLI)0(gEhK2F)Px6y93ZMWeUdKiaFiGnpAI0JptlpAISSkXZXNZeltmkhb0JCdjstm7sA8zA5rtKLyDbGpKn3zf5dkAQlaW(CNvKpOGaQyMeYIlvJWTjCsNW(feeAQAcIS8IjVElwUHvqfwtYPgeqUHePjMDrh91f0m0CXjFqalG0k6wsBaE4KiaFiO5It(GawaTx7wSIXktsk(tBXjpCsuqIHlG00hAU4KpiGfq71UTIgDwwyX5f5Srta0CXjFqalG2RDlqyjcIIaYrMsXFAzYJja8cRj6f6It(GSaHLiikcihzY6O4R5MWjO5It(GawaTx7wwL454Zzsk(tlw)9SeRla8HS5rtuqWB4DGo)7h0CXjFqalG2RDBX4fsIa8HsXFAX6VNLyDbGpKTNOhw)9SgfGew0OyAamkKTNanxCYheWcO9A3wUHKJa8HsXFAX6VNLyDbGpKTNeeKow)9S5PJ1Kivj28OjkiGxrr3eENKu1dR)E2eMWDGeb4dbS5rtuqWR3ArMWXlMjjsUHOdVauKCdbAU4KpiGfq71UnXfg3rMIa8HGMlo5dcyb0ETBlgVqseGpuk(tlw)9SeRla8HS5rtKEPJ1FpBct4oqIa8Ha2EIEP)gEhK2U1piaR)EwJcqclAumnagfY2tsnii93W7G001p9QDqyoj23W7ajhFotScQWAsoi4n8oiT)PRu1lD(mT8OjYsSUaWhYYeJYrG00vqWB4DqA74Vudci3qI0eZUOJUsfAU4KpiGfq71UfqsLdjcWhcAgAU4KpiGLyoxda(qaTyfJvMeO5It(GawI5Cna4db2RDROBjTb4HtIa8HGMlo5dcyjMZ1aGpeyV2TSkXZXNZKu8NwS(7zjMZ1icWhcy7j6LETdcZjX(gEhi54ZzIvqfwtYbb1oimNeRJIeUez4Hq4gwwH0in9dcQDqyojwqNzYrMIa8HawbvynjheqvtqKfqmPmAosScQWAsovO5It(GawI5Cna4db2RDB5gsocWhkf)PfR)EwI5CnIa8Ha2EIEPJ1FpBct4oqIa8Ha28OjkiGptlpAISLBi5iaFi7R3ArMWXlMjjsUHOtXjFq2YnKCeGpKLxaksUHKk0CXjFqalXCUga8Ha71ULvjEo(CMKI)0I1FplXCUgra(qaBpbAU4KpiGLyoxda(qG9A3A0BKdWhkf)PfR)EwI5CnIa8Ha28OjkiaR)E2eMWDGeb4dbS9KGG3W7G0(3pO5It(GawI5Cna4db2RDBIlmUJmfb4dbnxCYheWsmNRbaFiWETBROrNLfwCEroB0eanxCYheWsmNRbaFiWETBbclrqueqoYuk(tltEmbGxynrVqxCYhKfiSebrra5itwhfFn3eobnxCYheWsmNRbaFiWETBbKu5qIa8HUfir43NW01Up6O7a]] )
end