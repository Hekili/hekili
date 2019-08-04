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


    spec:RegisterPack( "Marksmanship", 20190803, [[duKO4aqijLEKKcBcrAusQCkjvTkerKxPk1SKeUfIiTlQ8lvHHjj6yiultvINjqzAQsQRHOY2Ku03eimovjX5eizDcezEiO7rj2hIWbfiQfIO8qbsPlIicgPQKuojIi0kLKMPQKKUPQKe7eHmubsXtvQPQk6QiIO2Rk)LIbtQdRyXQQhJ0KL4YeBwOplGrtsNw0QfivVgbMTsUnj2nOFl1Wf0XvLKQLd1ZbMoQRtvBhrvFNsQXJiQZtjz9cunFk1(H8r8982LHLJOxQK4GQYxPYG5EH4GvZGr8TzRcLBhoucMaYTHJIC7xLbtaqzGa1m82HJvREk3ZBdApMk3UgiTkZHGG0Jhbsw1)D0w5biv8RHZgsXtKFasf6JB)95IjjcV)TldlhrVujXbvLVsLbZ9cXbRMVee3E8SAJV9ovcAVTAwkc8(3Uia6TRbs)QmycakdeOMHi9RMhYcgvTgiTkZHGG0Jhbsw1)D0w5biv8RHZgsXtKFasf6du1AG0bzFapGr6Gvbs)sLehuinjfPdQGe5EnQkQAnq6Gw1bgqabju1AG0KuKoixkiTNZvYwH0H4SXjBfsZnshKdAEvDOQ1aPjPinjzGG0CQigUnLuqA8WQcgPz1bI08GdiSJtfXWTPKcsZnspqoPz4WcslWcs3rKM2k)HD3ELagCpVnJtkba1Mb3ZJiIVN3EOC2WB)hmEci3wGZFjLJSJpIE5EE7HYzdVTqYHRgKKxma1MVTaN)skhzhFefS75Tf48xs5i72uCYcoNB)9XOJXjLadqTzGZhI0KI00XiKSq9SG0KI0FFm6kT)VedpHoF4ThkNn82tQifdqT5JpIE9982cC(lPCKDBkozbNZT)(y0X4KsGbO2mW5drAsr66q6j4cozXfBQhiftmXItGZFjfK22gPNGl4KfxcnSQyWQwXQko8ajaPjbstmsBBJ0tWfCYId4XbsyadqTzGtGZFjfK22gP5zjq2bySmkRekobo)Luq66V9q5SH3gpHzXetSC8re5UN3wGZFjLJSBtXjl4CU93hJogNucma1MboFistksxhs)9XOlel0eigGAZaxPTgI022inT7vPTg6MurkgGAZUOFTmyHQo4aIHtfbPjePhkNn0nPIuma1MD0bWgoveK22gP)(y0XyVauB25dr66V9q5SH3EsfPyaQnF8runVN3wGZFjLJSBtXjl4CU93hJogNucma1MboF4ThkNn824jmlMyILJpIcI75Tf48xs5i72uCYcoNB)9XOJXjLadqTzGR0wdrABBK(7JrxiwOjqma1MboFistksxls)9XOJXEbO2SZhI022iDSPEastcKoiQ82dLZgEBf)ItGAZhFe9k3ZBpuoB4TJn1dKIzcUGtwmFzuUTaN)skhzhFefu3ZBpuoB4Td94mAvcdy(RbW3wGZFjLJSJpIiUY75ThkNn820gsfiJhwkM4AuKBlW5VKYr2Xhret8982dLZgE7)Q7IPJgwvmcuuS62cC(lPCKD8reXVCpVTaN)skhz3MItwW5C7VpgDyHsWsaatSXuX5drABBK(7JrhwOeSeaWeBmvm02dzb7a8qjaPjePjUYBpuoB4TzvX4H)2dlMyJPYXhrehS75ThkNn82HPGPjmGbO28Tf48xs5i74JiIF9982dLZgE7XO4XfbB6OHIBRb3wGZFjLJSJpIiMC3ZBlW5VKYr2TP4KfCo3glrSauN)sqAsr6Ar6HYzdDabhkq2a4egWLqtCLbu5BpuoB4TbcouGSbWjmWXhrexZ75ThkNn82awMIvgGAZ3wGZFjLJSJp(2fjo(fFppIi(EEBbo)LuoYUnfNSGZ52f57JrhDaCcd48HiTTnsxKVpgDLeekR18xIrzcKuNpePTTr6I89XORKGqzTM)smcepbeNp82dLZgEB6SwMHYzdnReW3ELa2ahf52EoxjB1XhrVCpVTaN)skhz3EOC2WBhywcDwlbdm)UH3MItwW5C7VpgDm2la1MD(qK22gPRfP5zjq2rN1kHbmSQyaQndCcC(lPG022inNkIHBtjfKMqKM4kVnCuKBhywcDwlbdm)UHhFefS75Tf48xs5i72dLZgE7WMsGWGm4sXqBLqppC2qtriFsLBtXjl4CUDTi93hJog7fGAZoFistksxhsxlslaGaPI7V6Uy6OHvfJaffRCktqVXiTTnsxlslaGaPI7V6Uy6OHvfJaffRC4bsastcliDWq66rABBKUiFFm6(RUlMoAyvXiqrXkNpePTTrAoved3MskinHin5UnCuKBh2ucegKbxkgARe65HZgAkc5tQC8r0RVN3wGZFjLJSBtXjl4CU93hJog7fGAZoFisBBJ01I08Sei7OZALWagwvma1Mbobo)LuqABBKMtfXWTPKcstis)sL3EOC2WB7bIjzrbC8re5UN3wGZFjLJSBpuoB4TPZAzgkNn0SsaF7vcydCuKBtlGJpIQ5982cC(lPCKDBkozbNZThkNKxmcuusbG0eI0b72dLZgEB6SwMHYzdnReW3ELa2ahf52a(4JOG4EEBbo)LuoYUnfNSGZ52dLtYlgbkkPaqAsG0VC7HYzdVnDwlZq5SHMvc4BVsaBGJICBgNucaQndo(4BhIfAR8h(EEer8982dLZgE7WMZgEBbo)LuoYo(i6L75ThkNn82QEilyGrzWeCBbo)LuoYo(iky3ZBlW5VKYr2TdXcDaSHtf52ex5ThkNn82L2)xIHNWJpIE9982dLZgEBRB8QqEjHgSaA4aPYTf48xs5i74JiYDpV9q5SH3oGFWLCGMoAMGl4MvVTaN)skhzhFevZ75ThkNn82kIsJTY0rZYtZIPGLrbCBbo)LuoYo(ikiUN3wGZFjLJSBdhf52tWbQdEaMydzthnHT1c(2dLZgE7j4a1bpatSHSPJMW2AbF8r0RCpVTaN)skhz3oel0bWgovKBtSJC3EOC2WBZyVauB(2uCYcoNBpuojVyeOOKcaPjbs)YXhrb1982cC(lPCKDBkozbNZThkNKxmcuusbG0eI0b72dLZgE7jvKIbO28XhFBAbCppIi(EEBbo)LuoYUnfNSGZ52f57JrNQhYcgyugmbUsBnePjfPRfP)(y0XyVauB25dV9q5SH3w1dzbdmkdMGJpIE5EEBbo)LuoYUnfNSGZ520UxL2AOdpHzXetS4WIYKqastishGwqABBKM29Q0wdD4jmlMyIfhwuMecqAcrAA3RsBn0nPIuma1MDyrzsiaPTTrAoved3MskinHi9lvE7HYzdVDP9)Ly4j84JOGDpVTaN)skhz3MItwW5C7VpgDm2la1MD(qKMuKUoKMtfXWTPKcstcKM29Q0wdDFbdembjmGR4XdNnePFJ0fpE4SHiTTnsxhsZdoGWovzwSQlKYinHi9lvI022iDTinplbYo6GLOFzMuXjW5VKcsxpsxpsBBJ0CQigUnLuqAcrAId2ThkNn82FbdembjmWXhrV(EEBbo)LuoYUnfNSGZ52FFm6ySxaQn78HinPiDDinNkIHBtjfKMeinT7vPTg6(RUlMOhBLR4XdNnePFJ0fpE4SHiTTnsxhsZdoGWovzwSQlKYinHi9lvI022iDTinplbYo6GLOFzMuXjW5VKcsxpsxpsBBJ0CQigUnLuqAcrAIR5ThkNn82)v3ft0JT64JiYDpVTaN)skhz3MItwW5C7VpgDm2la1MD(qKMuKUoKMtfXWTPKcstcKM29Q0wdDdKkagpldDwlxXJhoBis)gPlE8WzdrABBKUoKMhCaHDQYSyvxiLrAcr6xQePTTr6ArAEwcKD0blr)YmPItGZFjfKUEKUEK22gP5urmCBkPG0eI0exZBpuoB4ThivamEwg6SwhFevZ75Tf48xs5i72uCYcoNB)9XOJXEbO2SZhI0KI01H0CQigUnLuqAsG00UxL2AOlMy5V6U4kE8Wzdr63iDXJhoBisBBJ01H08GdiStvMfR6cPmstis)sLiTTnsxlsZZsGSJoyj6xMjvCcC(lPG01J01J022inNkIHBtjfKMqKoOU9q5SH3oMy5V6UC8ruqCpV9q5SH3ELbuzGjO7lbueiFBbo)LuoYo(i6vUN3wGZFjLJSBtXjl4CU93hJUvgL)Q7IdWdLaKMqK(1inPiDTi93hJog7fGAZoF4ThkNn82w34vH8scnyb0WbsLJpIcQ75Tf48xs5i72uCYcoNBxhsthJqYc1ZcsBBJ0CQigUnLuqAsG0VqCLiD9inPiDDi93hJog7fGAZoFisBBJ00UxL2AOJXEbO2SdlktcbinHinX1ePRhPTTrAoved3MskinHiDWQ82dLZgE7a(bxYbA6OzcUGBw94JiIR8EEBbo)LuoYUnfNSGZ520UxL2AOJXEbO2SdlktcbinHiDqC7HYzdVnoddxIjHgq4qLJpIiM475Tf48xs5i72uCYcoNBxls)9XOJXEbO2SZhE7HYzdVTIO0yRmD0S80SykyzuahFer8l3ZBlW5VKYr2TP4KfCo3(7JrhJ9cqTzhwgkJ0KI0FFm6(RUllpGDyzOmsBBJ0FFm6ySxaQn78HinPinDmcjlupliTTnsxhstBiWRm)L4cBoBOPJgp8JZYskMOhBfstksZPIy42usbPjePRjXiTTnsZPIy42usbPjePFPMiD93EOC2WBh2C2WJpIioy3ZBlW5VKYr2TP4KfCo3o2upaPjbsxZkrAsr66q6VpgDHyHMaXauBg4kT1qKMuKM29Q0wdD4jmlMyIfhwuMecqAsrAoved3MskinjqAA3RsBn0XyVauB2v84HZgAc4faaPFJ0fpE4SHiTTnsZdoGWovzwSQlKYinHi9lvI022iDTinplbYo6GLOFzMuXjW5VKcsxpsBBJ0CQigUnLuqAcrAIj3ThkNn82m2la1Mp(4Bd475reX3ZBpuoB4TfsoC1GK8IbO28Tf48xs5i74JOxUN3wGZFjLJSBtXjl4CU9q5K8IrGIskaKMeinX3EOC2WB)hmEcihFefS75ThkNn82JrXJlc20rdf3wdUTaN)skhzhFe9675Tf48xs5i72uCYcoNBJLiwaQZFjinPiDTi9q5SHoGGdfiBaCcd4sOjUYaQ8ThkNn82abhkq2a4eg44JiYDpVTaN)skhz3MItwW5C7VpgDm2la1MDL2AisBBJ0XM6binHiDqu5ThkNn824jmlMyILJpIQ5982cC(lPCKDBkozbNZT)(y0XyVauB25drAsr66q6VpgDEOGXjmGH8jiBOdWdLaKMei9RrABBKUwKEcUGtwCEOGXjmGH8jiBOtGZFjfKUEK22gP5urmCBkPG0eI0et8ThkNn82)v3fthnSQyeOOy1XhrbX982cC(lPCKDBkozbNZTRfP)(y0XyVauB25drABBKMtfXWTPKcstistUBpuoB4TJn1dKIzcUGtwmFzuo(i6vUN3wGZFjLJSBtXjl4CU93hJog7fGAZoFistks)9XOtzaSGnkdMaGYaD(qKMuKUwK(7JrNIO0yRmD0S80SykyzuaoF4ThkNn82dMoqXauB(4JOG6EEBbo)LuoYUnfNSGZ52FFm6ySxaQn78HiTTnsxhs)9XOR0()sm8e6kT1qK22gPPJrizH6zbPRhPjfP)(y0fIfAcedqTzGR0wdrABBKo6xldwOQdoGy4urqAcrA6aydNkcstkst7EvARHog7fGAZoSOmjeC7HYzdV9KksXauB(4JiIR8EEBbo)LuoYUnfNSGZ52FFm6ySxaQn78HinPi93hJoLbWc2Omycakd05drAsr6VpgDkIsJTY0rZYtZIPGLrb48H3EOC2WBpy6afdqT5JpIiM475ThkNn82HPGPjmGbO28Tf48xs5i74JiIF5EEBbo)LuoYUnfNSGZ521I0FFm6ySxaQn78HiTTnsZPIy42usbPjePFLBpuoB4Td94mAvcdy(RbWhFerCWUN3wGZFjLJSBtXjl4CUDSPEas)gPJn1dCyjGarAssiDaAbPjePJn1dCkdjJ0KI0FFm6ySxaQn7kT1qKMuKUoKUwKU0SJ2qQaz8WsXexJIy(Em0HfLjHaKMuKUwKEOC2qhTHubY4HLIjUgfXLqtCLbuzKUEK22gPJ(1YGfQ6GdigoveKMqKoaTG022inp4ac74urmCBkPG0eI0K72dLZgEBAdPcKXdlftCnkYXhre)675Tf48xs5i72uCYcoNB)9XOdlucwcayInMkoFisBBJ0FFm6WcLGLaaMyJPIH2EilyhGhkbinHinXvI022inNkIHBtjfKMqKMC3EOC2WBZQIXd)ThwmXgtLJpIiMC3ZBlW5VKYr2TP4KfCo3(7JrhJ9cqTzxPTgI0KI01H0FFm6cXcnbIbO2mW5drAsr66q6yt9aKMei9RjgPTTr6VpgDkdGfSrzWeaugOZhI01J022iDDiDSPEastcKMCvI0KI0tWfCYIl2upqkMyIfNaN)skiTTnshBQhG0KaPdcYH01J0KI01H00UxL2AOJXEbO2SdlktcbinjqAYH022iDSPEastcK(vQePRhPTTrAoved3MskinHin5q66V9q5SH3EW0bkgGAZhFerCnVN3EOC2WBdyzkwzaQnFBbo)LuoYo(4B75CLSv3ZJiIVN3EOC2WBtBpKfSbO28Tf48xs5i74JOxUN3EOC2WBdeSat2ktXd4BlW5VKYr2Xhrb7EE7HYzdVniSXIHUAF52cC(lPCKD8r0RVN3EOC2WBd6MvtyaJ1dl4BlW5VKYr2XhrK7EE7HYzdVnOHj18xdGVTaN)skhzhFevZ75ThkNn82qHvfSbO2ucUTaN)skhzhFefe3ZBpuoB4TPQzqpbggpWxDFUs2QBlW5VKYr2XhrVY982dLZgEBqyIt2auBkb3wGZFjLJSJpIcQ75ThkNn82WH9ybycGhQCBbo)LuoYo(4JVn5fmiB4r0lvsCqvzq8YRCBRhmmHba3MKOsyJzPG01ePhkNnePxjGbou1Bdcf6r0lK713oe3XCj3Ugi9RYGjaOmqGAgI0VAEilyu1AG0QmhccspEeizv)3rBLhGuXVgoBifpr(bivOpqvRbshK9b8agPdwfi9lvsCqH0KuKoOcsK71OQOQ1aPdAvhyabeKqvRbstsr6GCPG0EoxjBfshIZgNSvin3iDqoO5v1HQwdKMKI0KKbcsZPIy42usbPXdRkyKMvhisZdoGWooved3Mskin3i9a5KMHdliTaliDhrAAR8h2HQIQwdKMKajluplfK(lXglinTv(dJ0FjqcboKoitPsidqAydjPQdwj6xi9q5SHaKUHlRCOQ1aPhkNne4cXcTv(dBjUgabOQ1aPhkNne4cXcTv(d)2YJXhqrG8WzdrvRbspuoBiWfIfAR8h(TLhXUlOQ1aP3WjeO2msJNSG0FFmkfKgWddq6VeBSG00w5pms)LajeG0dSG0HyHKg2mNWaiDcq6sdfhQAnq6HYzdbUqSqBL)WVT8aaNqGAZgapmavDOC2qGlel0w5p8BlpcBoBiQ6q5SHaxiwOTYF43wEO6HSGbgLbtaQAnq6GgSqhaJ0SAcq6bG0YGxwH0daPdBai)lbP5gPdBwGCoRLviDGjHi9aBwvWinDamsx84egaPzvbPJzav2HQouoBiWfIfAR8h(TLhL2)xIHNWkcXcDaSHtfXcXvIQouoBiWfIfAR8h(TLhw34vH8scnyb0Wbsfu1HYzdbUqSqBL)WVT8iGFWLCGMoAMGl4MvrvhkNne4cXcTv(d)2YdfrPXwz6Oz5PzXuWYOaqvhkNne4cXcTv(d)2YdpqmjlkvahfXYeCG6GhGj2q20rtyBTGrvhkNne4cXcTv(d)2Ydg7fGAZveIf6aydNkIfIDKRImAzOCsEXiqrjfajEbvDOC2qGlel0w5p8BlpMurkgGAZvKrldLtYlgbkkPaimyOQOQdLZgcCEoxjBLfA7HSGna1MrvhkNne48CUs2Q3wEaeSat2ktXdyu1HYzdbopNRKT6TLhGWglg6Q9fu1HYzdbopNRKT6TLhGUz1egWy9WcgvDOC2qGZZ5kzREB5bOHj18xdGrvhkNne48CUs2Q3wEafwvWgGAtjavDOC2qGZZ5kzREB5bvnd6jWW4b(Q7ZvYwHQouoBiW55CLSvVT8aeM4Kna1MsaQ6q5SHaNNZvYw92Yd4WESambWdvqvrvRbstsGKfQNLcslKxWwH0CQiinRki9q5gJ0jaPhYp5A(lXHQouoBiWcDwlZq5SHMvc4kGJIyXZ5kzRQiJwkY3hJo6a4egW5dTTlY3hJUsccL1A(lXOmbsQZhABxKVpgDLeekR18xIrG4jG48HOQdLZgcEB5HhiMKfLkGJIyjWSe6Swcgy(DdRiJw((y0XyVauB25dTTRLNLazhDwRegWWQIbO2mWjW5VKITnNkIHBtjfcjUsu1HYzdbVT8WdetYIsfWrrSe2ucegKbxkgARe65HZgAkc5tQurgTu73hJog7fGAZoFiP1vRaacKkU)Q7IPJgwvmcuuSYPmb9gBBxRaacKkU)Q7IPJgwvmcuuSYHhibKWsWQ32UiFFm6(RUlMoAyvXiqrXkNp02MtfXWTPKcHKdvTgi9tSvin3i9kHcs7dr6HYj5hwkinJtibcdqARtwfPFI9cqTzu1HYzdbVT8WdetYIcOImA57JrhJ9cqTzNp02UwEwcKD0zTsyadRkgGAZaNaN)sk22CQigUnLui8LkrvhkNne82Yd6SwMHYzdnReWvahfXcTaqvhkNne82Yd6SwMHYzdnReWvahfXcGRiJwgkNKxmcuusbqyWqvhkNne82Yd6SwMHYzdnReWvahfXcJtkba1MbvKrldLtYlgbkkPaiXlOQOQdLZgcC0cWIQhYcgyugmbvKrlf57JrNQhYcgyugmbUsBnK0A)(y0XyVauB25drvhkNne4OfWBlpkT)VedpHvKrl0UxL2AOdpHzXetS4WIYKqaHbOfBBA3RsBn0HNWSyIjwCyrzsiGqA3RsBn0nPIuma1MDyrzsiW2MtfXWTPKcHVujQ6q5SHahTaEB5XxWabtqcdurgT89XOJXEbO2SZhsADCQigUnLuibT7vPTg6(cgiycsyaxXJhoB47IhpC2qB764bhqyNQmlw1fszcFPsB7A5zjq2rhSe9lZKkobo)LuQVEBBoved3MskesCWqvhkNne4OfWBlp(RUlMOhBvfz0Y3hJog7fGAZoFiP1XPIy42usHe0UxL2AO7V6UyIESvUIhpC2W3fpE4SH221XdoGWovzwSQlKYe(sL221YZsGSJoyj6xMjvCcC(lPuF922CQigUnLuiK4AIQouoBiWrlG3wEmqQay8Sm0zTQiJw((y0XyVauB25djTooved3MskKG29Q0wdDdKkagpldDwlxXJhoB47IhpC2qB764bhqyNQmlw1fszcFPsB7A5zjq2rhSe9lZKkobo)LuQVEBBoved3MskesCnrvhkNne4OfWBlpIjw(RUlvKrlFFm6ySxaQn78HKwhNkIHBtjfsq7EvARHUyIL)Q7IR4XdNn8DXJhoBOTDD8GdiStvMfR6cPmHVuPTDT8Sei7OdwI(LzsfNaN)sk1xVTnNkIHBtjfcdku1HYzdboAb82YJvgqLbMGUVeqrGmQ6q5SHahTaEB5H1nEviVKqdwanCGuPImA57Jr3kJYF1DXb4HsaHVM0A)(y0XyVauB25drvhkNne4OfWBlpc4hCjhOPJMj4cUz1kYOL6OJrizH6zX2MtfXWTPKcjEH4kRN06((y0XyVauB25dTTPDVkT1qhJ9cqTzhwuMeciK4AwVTnNkIHBtjfcdwLOQdLZgcC0c4TLh4mmCjMeAaHdvQiJwODVkT1qhJ9cqTzhwuMecimiqvhkNne4OfWBlpueLgBLPJMLNMftblJcOImAP2VpgDm2la1MD(qu1HYzdboAb82YJWMZgwrgT89XOJXEbO2SdldLj97Jr3F1Dz5bSdldLTT)(y0XyVauB25djLogHKfQNfB76One4vM)sCHnNn00rJh(Xzzjft0JTIuoved3MskewtITT5urmCBkPq4l1SEu1HYzdboAb82Ydg7fGAZvKrlXM6bKOMvsADFFm6cXcnbIbO2mWvARHKs7EvARHo8eMftmXIdlktcbKYPIy42usHe0UxL2AOJXEbO2SR4XdNn0eWlaW7IhpC2qBBEWbe2PkZIvDHuMWxQ02UwEwcKD0blr)YmPItGZFjL6TT5urmCBkPqiXKdvfvDOC2qGdWwesoC1GK8IbO2mQ6q5SHahGFB5XFW4jGurgTmuojVyeOOKcGeeJQouoBiWb43wEmgfpUiythnuCBnavDOC2qGdWVT8ai4qbYgaNWavKrlyjIfG68xcP1ouoBOdi4qbYgaNWaUeAIRmGkJQouoBiWb43wEGNWSyIjwQiJw((y0XyVauB2vARH22XM6begevIQwdKoJw((y0XyVauB25djTUVpgDEOGXjmGH8jiBOdWdLas8AB7ANGl4KfNhkyCcdyiFcYg6e48xsPEBBEWbe2XPIy42usHqIjgvDOC2qGdWVT84V6Uy6OHvfJaffRQiJw((y0XyVauB25djTUVpgDEOGXjmGH8jiBOdWdLas8AB7ANGl4KfNhkyCcdyiFcYg6e48xsPEBBoved3MskesmXOQdLZgcCa(TLhXM6bsXmbxWjlMVmkvKrl1(9XOJXEbO2SZhABZPIy42usHqYHQouoBiWb43wEmy6afdqT5kYOLVpgDm2la1MD(qs)(y0PmawWgLbtaqzGoFiP1(9XOtruASvMoAwEAwmfSmkaNpevDOC2qGdWVT8ysfPyaQnxrgT89XOJXEbO2SZhABx33hJUs7)lXWtOR0wdTTPJrizH6zPEs)(y0fIfAcedqTzGR0wdTTJ(1YGfQ6GdigovecPdGnCQiKs7EvARHog7fGAZoSOmjeGQouoBiWb43wEmy6afdqT5kYOLVpgDm2la1MD(qs)(y0PmawWgLbtaqzGoFiPFFm6ueLgBLPJMLNMftblJcW5drvhkNne4a8BlpctbttyadqTzu1HYzdboa)2YJqpoJwLWaM)AaCfz0sTFFm6ySxaQn78H22CQigUnLui8vqvhkNne4a8BlpOnKkqgpSumX1OivKrlXM6bVJn1dCyjGajjfGwim2upWPmKmPFFm6ySxaQn7kT1qsRR2sZoAdPcKXdlftCnkI57XqhwuMeciT2HYzdD0gsfiJhwkM4AuexcnXvgqLR32o6xldwOQdoGy4urimaTyBZdoGWooved3Mskesou1HYzdboa)2YdwvmE4V9WIj2yQurgT89XOdlucwcayInMkoFOT93hJoSqjyjaGj2yQyOThYc2b4HsaHexPTnNkIHBtjfcjhQ6q5SHahGFB5XGPduma1MRiJw((y0XyVauB2vARHKw33hJUqSqtGyaQndC(qsRl2upGeVMyB7VpgDkdGfSrzWeaugOZhwVTDDXM6bKGCvs6eCbNS4In1dKIjMyXjW5VKITDSPEajccYvpP1r7EvARHog7fGAZoSOmjeqcYzBhBQhqIxPY6TT5urmCBkPqi5QhvDOC2qGdWVT8aWYuSYauBgvfvDOC2qGJXjLaGAZal)bJNacQ6q5SHahJtkba1MbVT8qi5WvdsYlgGAZOQdLZgcCmoPeauBg82YJjvKIbO2Cfz0Y3hJogNucma1MboFiP0XiKSq9Sq63hJUs7)lXWtOZhIQouoBiWX4KsaqTzWBlpWtywmXelvKrlFFm6yCsjWauBg48HKw3eCbNS4In1dKIjMyXjW5VKIT9eCbNS4sOHvfdw1kwvXHhibKGyB7j4cozXb84ajmGbO2mWjW5VKITnplbYoaJLrzLqXjW5VKs9OQdLZgcCmoPeauBg82YJjvKIbO2Cfz0Y3hJogNucma1MboFiP199XOlel0eigGAZaxPTgABt7EvARHUjvKIbO2Sl6xldwOQdoGy4uriCOC2q3KksXauB2rhaB4urST)(y0XyVauB25dRhvDOC2qGJXjLaGAZG3wEGNWSyIjwQiJw((y0X4KsGbO2mW5drvhkNne4yCsjaO2m4TLhk(fNa1MRiJw((y0X4KsGbO2mWvARH22FFm6cXcnbIbO2mW5djT2VpgDm2la1MD(qB7yt9aseevIQouoBiWX4KsaqTzWBlpIn1dKIzcUGtwmFzuqvhkNne4yCsjaO2m4TLhHECgTkHbm)1ayu1HYzdbogNucaQndEB5bTHubY4HLIjUgfbvDOC2qGJXjLaGAZG3wE8xDxmD0WQIrGIIvOQdLZgcCmoPeauBg82YdwvmE4V9WIj2yQurgT89XOdlucwcayInMkoFOT93hJoSqjyjaGj2yQyOThYc2b4HsaHexjQ6q5SHahJtkba1MbVT8imfmnHbma1MrvhkNne4yCsjaO2m4TLhJrXJlc20rdf3wdqvhkNne4yCsjaO2m4TLhabhkq2a4egOImAblrSauN)siT2HYzdDabhkq2a4egWLqtCLbuzu1HYzdbogNucaQndEB5bGLPyLbO28XhFh]] )


end