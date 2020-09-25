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


    if state.level > 50 then
        spec:RegisterPack( "Marksmanship", 20200925.9, [[d4Z9RaGAPIs2esXUi1RrK2hOs)wPtlz2QY8f0nrkj5xQQ62uPVHusTtvL2RIDd1(jzusLAyicJdubNxQWZvzWImCboeIOtjvYXKQ64Gk0cbvDzIfJKLd8qPIc9urTmQqRdPKu)LQMQuLjl00r9iKsIxrf9mKs56GSnKsmnKs1MLY2PcEmKzHu1NbL5HuzKsff8DvvgncJhurNuQOOBjvuQRjvK7HOwPQIdt5Csfvp9NEtoASmFDKeoscs05o2jnjGd0UJDcomzUJazYbgIudMmzS5ktMwLbi9Cn8rubtoW64TwC6n5BHaizY0kQebZbhT6))HvmbeLgTU)VYf6zCTyeWA8)RCr)Nmfu94ot8qn5OXY81rs4ijirN7yN0Kaoq7o2jAzYgetSGjNl3oJtMOIrbputokhAY0kQeTkdq65A4JOcuPodqywaQp0kQuwcyXLsaQKJDIEvYrs4ijuFuFOvuPEe1Ps1PsmHOspXb5PsWvL6ejujheWvlwp5xD8n9MmdkePhXY30B(2F6nzbBupjoWpzeOybu2Kr7(I7pS2kxj6pIL1qbQuyOkH29f3FynWcQOVvardexRWNkbxvcT7lU)WARCLO)iwwdexRW3KnexlEYXfI6jE2cgE(640BYc2OEsCGFYiqXcOSjdGWsBbWe9TqV2cGjEXLsaNwGJqvqGevjAuj2aEgybAG4Af(uj6ujyOOkrJkH29f3FyD7zardexRWNkrNkbdfNSH4AXtMnGNbwWWZxAB6nzbBupjoWpzeOybu2KbqyPTayI(wOxBbWeV4sjGtlyJ6jrvIgvInGNbwGgkyYgIRfp52ZaYWZxAF6nzdX1IN8V6f9xqbk(MSGnQNeh4hE(2PP3KnexlEYoSVN0XKfSr9K4a)WZxAz6nzdX1INmqUfBCHH5nay)nzbBupjoWp88Lwp9MSH4AXtMYaadMmzbBupjoWp88fom9MSH4AXtwGZG3ELdI)iwEYc2OEsCGF45BNp9MSGnQNeh4NmcuSakBYODFX9hwdSGk6Bfq0aX1k8PsHHQuBrqNk5uLmexlwdSGk6Bfq0i7ypqGjyvcUQuBrqN21GtvkmuLAfmc2dexRWNkrNk1Vtt2qCT4jZai5iwE45BFsm9MSGnQNeh4NmcuSakBYuqTMMbfIu)rS8PHcujAuPUvjkOwthaeuDI)iw(0X9hwLcdvPg075bcIWaWepxUIkrNkHSJ9C5kQKtvcgkQsHHQefuRPzaKCelRHcuPUMSH4AXt2kxj6pILhE(2V)0BYc2OEsCGFYiqXcOSj3we0PsovjKDShiWeSkrNk1we0PDn4CYgIRfp5OymHhryKcm3HNV9DC6nzbBupjoWpzeOybu2KPGAnndkeP(Jy5tdfOs0OsuqTMoUqupXZwGoU)Wt2qCT4jdSGk6BfqgE(2N2MEtwWg1tId8tgbkwaLnzkOwtZGcrQ)iw(0X9hwLcdvjkOwthaeuDI)iw(0qbQuyOk1we0PsD2QeApwLCQsi7ypqGjyvcUQKH4AXARCLO)iwwJ2JNSH4AXt2f6X1rS8WZ3(0(0BYc2OEsCGFYiqXcOSjtb1A6OyrV0HOJ7p8KnexlEYKwVN)iwE45B)on9MSH4AXt28UqGOa8BZJa7VBYc2OEsCGF45BFAz6nzdX1INC7zDir)rS8KfSr9K4a)WZ3(06P3KfSr9K4a)KnexlEYNacem7pUWWMmcuSakBYaPbKJWOEYKrDGEINnamHV5B)HNV9HdtVjBiUw8KpwSyh(Jy5jlyJ6jXb(HhEYrPzqpE6nF7p9MSH4AXtgTqywa(Jy5jlyJ6jXb(HNVoo9MSGnQNeh4NmcuSakBYbaXbpmuu3xZai5iwwLcdvjsQsS9emRr27vyyEMq8hXYNwWg1tIQuyOk1kyeShiUwHpvIovYrsmzdX1INm0j(If3B45lTn9MSGnQNeh4NSH4AXtgzVN3qCTy)RoEYV6yp2CLjJI3WZxAF6nzbBupjoWpzeOybu2KnexoiEblULCQeDQeTnzdX1INmYEpVH4AX(xD8KF1XES5kt(4HNVDA6nzbBupjoWpzeOybu2KnexoiEblULCQeCvjhNSH4AXtgzVN3qCTy)RoEYV6yp2CLjZGcr6rS8n8WtoaiO1LY4P38T)0BYgIRfpzcimlGZ7AasNSGnQNeh4hE(640BYc2OEsCGFYiqXcOSjdGWsBbWe9TqV2cGjEXLsaNwGJqvqGeNSH4AXtMnGNbwWWZxAB6nzbBupjoWp5aGGSJ9C5ktUpjMSH4AXtoUqupXZwWWZxAF6nzbBupjoWpzdX1INCWY1INCSdS5wiFaqcwEY9hE(2PP3KfSr9K4a)KrGIfqzt2qC5G4fS4wYPsKvP(t2qCT4jBLRe9hXYdp8KrXB6nF7p9MSGnQNeh4NmcuSakBYrHcQ10eqywaN31aKQJ7pSkrJkrsvIcQ10masoIL1qbt2qCT4jtaHzbCExdq6WZxhNEtwWg1tId8tgbkwaLn5aG4GhgkQ7RzaKCelRs0OsDRsTcgb7bIRv4tLGRkH29f3FynLaobqAHHPJqaJRfRsovPieW4AXQuyOk1TkXgaMWAcXEmHoaXQeDQKJKqLcdvjsQsS9emRrgqAqpVvUAbBupjQsDPsDPsHHQuRGrWEG4Af(uj6uP(02KnexlEYuc4eaPfg2WZxAB6nzbBupjoWpzeOybu2KdaIdEyOOUVMbqYrSSkrJk1Tk1kyeShiUwHpvcUQeA3xC)H1uVDJ(geOdDecyCTyvYPkfHagxlwLcdvPUvj2aWewti2Jj0biwLOtLCKeQuyOkrsvITNGznYasd65TYvlyJ6jrvQlvQlvkmuLAfmc2dexRWNkrNk1NwMSH4AXtM6TB03GaDm88L2NEtwWg1tId8tgbkwaLn5aG4GhgkQ7RzaKCelRs0OsDRsTcgb7bIRv4tLGRkH29f3FyTHrYXa75r27PJqaJRfRsovPieW4AXQuyOk1TkXgaMWAcXEmHoaXQeDQKJKqLcdvjsQsS9emRrgqAqpVvUAbBupjQsDPsDPsHHQuRGrWEG4Af(uj6uP(0YKnexlEYggjhdSNhzV3WZ3on9MSGnQNeh4NmcuSakBYbaXbpmuu3xZai5iwwLOrL6wLAfmc2dexRWNkbxvcT7lU)W6wbeQ3UrDecyCTyvYPkfHagxlwLcdvPUvj2aWewti2Jj0biwLOtLCKeQuyOkrsvITNGznYasd65TYvlyJ6jrvQlvQlvkmuLAfmc2dexRWNkrNk15t2qCT4j3kGq92no88LwMEtwWg1tId8tgbkwaLnzkOwtZai5iwwh3F4jBiUw8KFfmc(8DwqryUcMhE(sRNEtwWg1tId8tgbkwaLnzkOwtZai5iwwh3F4jBiUw8KPmy(T5zqHi9gE(chMEtwWg1tId8tgbkwaLnzkOwtZai5iwwdedXQenQefuRPPE7gFqhRbIHyvkmuLcaIdEyOOUVMbqYrSSkrJkXgaMWAcXEmHoaXQeDQKJKqLcdvPUvPUvj0IpixJ6j6GLRf73MhctbQ4tI(geOdvkmuLql(GCnQNOHWuGk(KOVbb6qL6sLOrLAfmc2dexRWNkrNkrl9vPWqvQvWiypqCTcFQeDQKJ0Ik11KnexlEYblxlE4HN8XtV5B)P3KfSr9K4a)KrGIfqztMTNGz9XIf7W3we0PfSr9KOkrJkfaeh8WqrDF9XIf7WFelRs0OsuqTM(yXID4Blc60aX1k8Ps0PsDAYgIRfp5Jfl2H)iwE45RJtVjBiUw8KjTEp)rS8KfSr9K4a)WZxAB6nzdX1INCCHOEINTGjlyJ6jXb(HNV0(0BYc2OEsCGFYiqXcOSjdGWsBbWe9TqV2cGjEXLsaNwGJqvqGevjAuj2aEgybAG4Af(uj6ujyOOkrJkH29f3FyD7zardexRWNkrNkbdfNSH4AXtMnGNbwWWZ3on9MSGnQNeh4NmcuSakBYaiS0wamrFl0RTayIxCPeWPfSr9KOkrJkXgWZalqdfmzdX1INC7zaz45lTm9MSH4AXt(x9I(lOafFtwWg1tId8dpFP1tVjBiUw8KBpRdj6pILNSGnQNeh4hE(chMEtwWg1tId8tgbkwaLn52IGovYPkHSJ9abMGvj6uP2IGoTRbNt2qCT4jhfJj8icJuG5o88TZNEt2qCT4jlWzWBVYbXFelpzbBupjoWp88TpjMEtwWg1tId8tgbkwaLnzkOwthaeuDI)iw(0X9hwLcdvjsQsS9emRreLRjaZFelRfSr9K4KnexlEYoSVN0XWZ3(9NEt2qCT4jBExiqua(T5rG93nzbBupjoWp88TVJtVjlyJ6jXb(jJaflGYMmfuRPdacQoXFelF64(dRsHHQejvj2EcM1iIY1eG5pIL1c2OEsCYgIRfpzGCl24cdZBaW(B45BFAB6nzbBupjoWpzeOybu2KPGAnDaqq1j(Jy5th3FyvkmuLiPkX2tWSgruUMam)rSSwWg1tIt2qCT4jZai5iwE45BFAF6nzbBupjoWpzeOybu2K7wLAqVNhiicdat8C5kQeDQeYo2ZLROsovjyOOkfgQsuqTMMbqYrSSgkqL6sLOrL6wLOGAnDaqq1j(Jy5th3FyvkmuLiPkX2tWSgruUMam)rSSwWg1tIQuyOkHmVH4YbrL6sLcdvjkOwtZGcrQ)iw(0aX1k8PsWvLe4uqqS45YvujAuPUvjdXLdIxWIBjNkbxvQVkfgQsaiS0wamrFciqW8X2JubCEguisfqhAbocvbbsuL6AYgIRfpzRCLO)iwE45B)on9MSGnQNeh4NmcuSakBYuqTMoUqupXZwGoU)WQenQuBrqNk5uLq2XEGatWQeDQuBrqN21GZjBiUw8Kbwqf9TcidpF7tltVjlyJ6jXb(jJaflGYMmfuRPdacQoXFelFAOavIgvQBvIcQ10masoIL1X9hwLcdvjdXLdIxWIBjNkbxvQVkfgQsKuLqM3qC5GOsDnzdX1INmIOCnby(Jy5HNV9P1tVjlyJ6jXb(jBiUw8Kpbeiy2FCHHnzeOybu2KbsdihHr9evIgvInamH1C5kEE9Xsuj4QsriGX1INmQd0t8SbGj8nF7p88TpCy6nzbBupjoWpzeOybu2KnexoiEblULCQeCvP(t2qCT4jtzaGbtgE(2VZNEtwWg1tId8tgbkwaLnzkOwthaeuDI)iw(0qbQenQu3QefuRPzaKCelRJ7pSkfgQsKuLqM3qC5GOsDnzdX1INSbqgw8hXYdpFDKetVjlyJ6jXb(jJaflGYMmfuRPdacQoXFelF64(dpzdX1INSvUs0Felp881X(tVjlyJ6jXb(jJaflGYMCBrqNkbxvcThRsovjdX1I1w5kr)rSSgThRs0OsDRsuqTMMbqYrSSoU)WQuyOkrsvczEdXLdIk11KnexlEYiIY1eG5pILhE(6OJtVjlyJ6jXb(jJaflGYMCBrqNkbxvcThRsovjdX1I1w5kr)rSSgThRs0OsDRsuqTMMbqYrSSoU)WQuyOkrsvczEdXLdIk11KnexlEYgazyXFelp881rAB6nzbBupjoWpzeOybu2KBlc6ujNQeYo2deycwLOtLAlc60UgCozdX1IN8XIf7WFelp881rAF6nzdX1INmIOCnby(Jy5jlyJ6jXb(HNVo2PP3KnexlEYgazyXFelpzbBupjoWp8WdpzheWvlE(6ijCKeKOZ7tlt(NbWfg2n5ot3GfWsuL6KkziUwSk9QJpT6ZKVabnFDSt0(KdaBREYKnexl(0babTUug7K8FcimlGZ7AasvFmexl(0babTUug7K8F2aEgyb0xnYaiS0wamrFl0RTayIxCPeWPf4iufeir1hdX1IpDaqqRlLXoj)pUqupXZwa9babzh75Yvi3NeQpgIRfF6aGGwxkJDs(FWY1IPp2b2ClKpaibltUV6JH4AXNoaiO1LYyNK)BLRe9hXY0xnYgIlheVGf3soY9vFuFmexl(Cs(pAHWSa8hXYQpgIRfFoj)h6eFXI7rF1ihaeh8WqrDFndGKJy5WqsY2tWSgzVxHH5zcXFelFAbBupjgg2kyeShiUwHp6CKeQpgIRfFoj)hzVN3qCTy)RoMES5kKrXt9XqCT4Zj5)i798gIRf7F1X0JnxH8X0xnYgIlheVGf3so6On1hdX1IpNK)JS3ZBiUwS)vhtp2CfYmOqKEelF0xnYgIlheVGf3so46O6J6JH4AXNgfpNK)taHzbCExdqk9vJCuOGAnnbeMfW5DnaP64(dtdjPGAnndGKJyznuG6JH4AXNgfpNK)tjGtaKwyy0xnYbaXbpmuu3xZai5iwMMUBfmc2dexRWhCr7(I7pSMsaNaiTWW0riGX1IDgHagxlomSB2aWewti2Jj0biMohjryijz7jywJmG0GEERC1c2OEsSRUcdBfmc2dexRWhD9Pn1hdX1IpnkEoj)N6TB03GaDqF1ihaeh8WqrDFndGKJyzA6UvWiypqCTcFWfT7lU)WAQ3UrFdc0HocbmUwSZieW4AXHHDZgaMWAcXEmHoaX05ijcdjjBpbZAKbKg0ZBLRwWg1tID1vyyRGrWEG4Af(ORpTO(yiUw8PrXZj5)ggjhdSNhzVh9vJCaqCWddf191masoILPP7wbJG9aX1k8bx0UV4(dRnmsogyppYEpDecyCTyNriGX1Idd7MnamH1eI9ycDaIPZrsegss2EcM1idinON3kxTGnQNe7QRWWwbJG9aX1k8rxFAr9XqCT4tJINtY)BfqOE7gPVAKdaIdEyOOUVMbqYrSmnD3kyeShiUwHp4I29f3FyDRac1B3OocbmUwSZieW4AXHHDZgaMWAcXEmHoaX05ijcdjjBpbZAKbKg0ZBLRwWg1tID1vyyRGrWEG4Af(ORZvFmexl(0O45K8)xbJGpFNfueMRGz6RgzkOwtZai5iwwh3Fy1hdX1IpnkEoj)NYG53MNbfI0J(QrMcQ10masoIL1X9hw9XqCT4tJINtY)dwUwm9vJmfuRPzaKCelRbIHyAOGAnn1B34d6ynqmehggaeh8WqrDFndGKJyzAydatynHypMqhGy6CKeHHD3nAXhKRr9eDWY1I9BZdHPav8jrFdc0ryiAXhKRr9eneMcuXNe9niqhDrtRGrWEG4Af(OJw6hg2kyeShiUwHp6CKw6s9r9XqCT4tZGcr6rS85K8)4cr9epBb0xnYODFX9hwBLRe9hXYAOGWq0UV4(dRbwqf9TciAG4Af(GlA3xC)H1w5kr)rSSgiUwHp1hdX1IpndkePhXYNtY)zd4zGfqF1idGWsBbWe9TqV2cGjEXLsaNwGJqvqGePHnGNbwGgiUwHp6GHI0G29f3FyD7zardexRWhDWqr1hdX1IpndkePhXYNtY)Bpdi0xnYaiS0wamrFl0RTayIxCPeWPfSr9KinSb8mWc0qbQpgIRfFAguispILpNK))REr)fuGIp1hdX1IpndkePhXYNtY)DyFpPd1hdX1IpndkePhXYNtY)bYTyJlmmVba7p1hdX1IpndkePhXYNtY)PmaWGjQpgIRfFAguispILpNK)lWzWBVYbXFelR(yiUw8PzqHi9iw(Cs(pdGKJyz6Rgz0UV4(dRbwqf9TciAG4Af(cdBlc6CAiUwSgybv03kGOr2XEGatWWTTiOt7AWzyyRGrWEG4Af(ORFNuFmexl(0mOqKEelFoj)3kxj6pILPVAKPGAnndkeP(Jy5tdfqt3uqTMoaiO6e)rS8PJ7pCyyd698abryayINlxHoKDSNlxXjmummKcQ10masoIL1qbDP(yiUw8PzqHi9iw(Cs(FumMWJimsbMl9vJCBrqNtKDShiWemDTfbDAxdovFmexl(0mOqKEelFoj)hybv03kGqF1itb1AAguis9hXYNgkGgkOwthxiQN4zlqh3Fy1hdX1IpndkePhXYNtY)DHECDeltF1itb1AAguis9hXYNoU)WHHuqTMoaiO6e)rS8PHccdBlc66Sr7Xor2XEGatWW1qCTyTvUs0FelRr7XQpgIRfFAguispILpNK)tA9E(Jyz6RgzkOwthfl6LoeDC)HvFmexl(0mOqKEelFoj)38UqGOa8BZJa7Vt9XqCT4tZGcr6rS85K8)2Z6qI(Jyz1hdX1IpndkePhXYNtY)pbeiy2FCHHrpQd0t8SbGj8rUp9vJmqAa5imQNO(yiUw8PzqHi9iw(Cs()XIf7WFelR(O(yiUw8Pp2j5)hlwSd)rSm9vJmBpbZ6Jfl2HVTiOtlyJ6jrAcaIdEyOOUV(yXID4pILPHcQ10hlwSdFBrqNgiUwHp66K6JH4AXN(yNK)tA9E(Jyz1hdX1Ip9Xoj)pUqupXZwG6JH4AXN(yNK)ZgWZalG(QrgaHL2cGj6BHETfat8IlLaoTahHQGajsdBapdSanqCTcF0bdfPbT7lU)W62ZaIgiUwHp6GHIQpgIRfF6JDs(F7zaH(QrgaHL2cGj6BHETfat8IlLaoTGnQNePHnGNbwGgkq9XqCT4tFStY))vVO)ckqXN6JH4AXN(yNK)3Ewhs0FelR(yiUw8Pp2j5)rXycpIWifyU0xnYTfbDor2XEGatW01we0PDn4u9XqCT4tFStY)f4m4Tx5G4pILvFmexl(0h7K8Fh23t6G(QrMcQ10babvN4pILpDC)HddjjBpbZAer5AcW8hXYAbBupjQ(yiUw8Pp2j5)M3fcefGFBEey)DQpgIRfF6JDs(pqUfBCHH5nay)rF1itb1A6aGGQt8hXYNoU)WHHKKTNGznIOCnby(JyzTGnQNevFmexl(0h7K8FgajhXY0xnYuqTMoaiO6e)rS8PJ7pCyijz7jywJikxtaM)iwwlyJ6jr1hdX1Ip9Xoj)3kxj6pILPVAK7Ub9EEGGimamXZLRqhYo2ZLR4egkggsb1AAgajhXYAOGUOPBkOwthaeuDI)iw(0X9homKKS9emRreLRjaZFelRfSr9KyyiY8gIlhKUcdPGAnndkeP(Jy5tdexRWhCf4uqqS45YvOPBdXLdIxWIBjhC7hgcGWsBbWe9jGabZhBpsfW5zqHivaDOf4iufeiXUuFmexl(0h7K8FGfurFRac9vJmfuRPJle1t8SfOJ7pmnTfbDor2XEGatW01we0PDn4u9XqCT4tFStY)reLRjaZFeltF1itb1A6aGGQt8hXYNgkGMUPGAnndGKJyzDC)HddnexoiEblULCWTFyijrM3qC5G0L6JH4AXN(yNK)FciqWS)4cdJEuhON4zdat4JCF6RgzG0aYryupHg2aWewZLR451hlbUriGX1IvFmexl(0h7K8Fkdamyc9vJSH4YbXlyXTKdU9vFmexl(0h7K8FdGmS4pILPVAKPGAnDaqq1j(Jy5tdfqt3uqTMMbqYrSSoU)WHHKezEdXLdsxQpgIRfF6JDs(VvUs0FeltF1itb1A6aGGQt8hXYNoU)WQpgIRfF6JDs(pIOCnby(Jyz6Rg52IGo4I2JDAiUwS2kxj6pIL1O9yA6McQ10masoIL1X9homKKiZBiUCq6s9XqCT4tFStY)naYWI)iwM(QrUTiOdUO9yNgIRfRTYvI(JyznApMMUPGAnndGKJyzDC)HddjjY8gIlhKUuFmexl(0h7K8)Jfl2H)iwM(QrUTiOZjYo2deycMU2IGoTRbNQpgIRfF6JDs(pIOCnby(Jyz1hdX1Ip9Xoj)3aidl(Jy5HhEga]] )
    else
        spec:RegisterPack( "Marksmanship", 20200925.1, [[dCKv7aqiOuEevvHnHc9jQQQAuuv5uuvAvOOO8kOWSOQyxu5xOGHbv5ykQwgvPEgkQMgvvPRjuzBcv13qrPXjuLoNqvSoQQk18ek3JQyFqrDqQQIQfII8quuu9ruuensQQI0jPQQKvcLmtQQIYnPQQWoHQAOOOi1srrrYtbmvOIVIIIWyPQkI9c5VumykDyrlgv9yKMSsDzInl4ZkYOb60swnvvvEnuPzRKBJs7wLFl1WfYXPQQOLRQNdA6KUUcBNQKVROmEuu48qrwpuQMpQSFeJMJWbbStvq47nEEJhEXJ3X5WlEWJz9EocqXuKGaIskU5KGaUKvqa(h5JlKnpiyfHaIsmT6CJWbba7XtfeG)Gybvnc6FZadtLco4D0MLbyXowPw9r)mOmalwkdia(rTu)RdXJa2Pki89gpVXdV4X74C4fp4XSZJxeqouW(raaflZCeayT3YH4raBbsra(dI1)iFCHS5bbRiI1F64u5jy5piwajsfwE5j25X3hI1B88gpeWQGkeHdcq)IIleSviche(Zr4GasQw9HaWTwldeSveGCj)s2iMqkcFVr4GasQw9Ha8Qxlbtia5s(LSrmHue(mhHdciPA1hcGp)pNeeGCj)s2iMqkcF)fHdciPA1hcqygrRgwEjgiyRia5s(LSrmHue(XHWbbixYVKnIjea9lv(kra8JqWPFrX1abBf6grelJelnnjvlVeILrILFecUDp4xIrZi3icbKuT6dbKfRSnqWwrkc)4JWbbixYVKnIjea9lv(kra8JqWPFrX1abBf6grelJeRFeBID5lvCHMoGY2eQxCYL8lztSCCeBID5lvC1zuqX8GysbzDFE4sSyMyNtSCCeBID5lvCWXpv3Kbc2k0jxYVKnXYXrSAUKtDq9LKDvN4Kl5xYMy9fbKuT6db8zuTnH6fKIWNzr4GaKl5xYgXecG(LkFLia(ri40VO4AGGTcDJiILrI1pILFecUOxOfumqWwHUDp7iwooIL29A3ZoxwSY2abB1fgRL5fky(tIrlwHyJrSjvR(CzXkBdeSvhnHQrlwHy54iw(ri40FiqWwDJiI1xeqs1QpeqwSY2abBfPi8Jxeoia5s(LSrmHaOFPYxjcGFeco9lkUgiyRq3icbKuT6db8zuTnH6fKIWpEq4GaKl5xYgXecG(LkFLia(ri40VO4AGGTcD7E2rSCCel)ieCrVqlOyGGTcDJiILrIfBel)ieC6peiyRUreXYXrSHMoGelMjwMfpeqs1Qpea7yPfeSvKIWFoEiCqajvR(qaHMoGY2Kyx(sfdVKSia5s(LSrmHue(ZNJWbbKuT6dben(kGP6Mm8ReQia5s(LSrmHue(Z9gHdciPA1hcG2hvo9tv2MWkzfeGCj)s2iMqkc)5mhHdciPA1hcGF1920bJckg5ewmHaKl5xYgXesr4p3Fr4GaKl5xYgXecG(LkFLia(ri4EHI7sGqtOFQ4grelhhXYpcb3luCxceAc9tfdThNkVdQjfxIngXohpeqs1QpeGckMXX3JBBc9tfKIWFECiCqajvR(qaPHD8B5nDWq)EgebixYVKnIjKIWFE8r4GaKl5xYgXecG(LkFLiGxcVabt(LqSmsSyJytQw95GYhjNAGADtU6mHvnbQiGKQvFiaO8rYPgOw3esr4pNzr4GasQw9HaGQKBmzGGTIaKl5xYgXesrkcylHCSueoi8NJWbbKuT6dbq7XPYBGGTIaKl5xYgXesr47ncheGCj)s2iMqajvR(qaRXJR8qtDWAx9aAMQGIaOFPYxjcG29A3ZoN(dbc2Q7f2SoOzAiqiXgJyNhhXYXrSHAcunVWM1bj2yelZXdbCjRGawJhx5HM6G1U6b0mvbfPi8zocheGCj)s2iMqajvR(qaj2HG5NqtOp10btuptEea9lv(kra(rSHAcunVWM1bjwmtSjvR(m0Ux7E2rSyqSm3FjwooIvZFsuhOKlf0frvIngX6nEelhhXQ5pjQtlwXOTjIQgVXJyJrSZJJy9LyzKyPDV29SZP)qGGT6EHnRdAMgcesSXi25XrSCCeBOMavZlSzDqIngXY84qaxYkiGe7qW8tOj0NA6GjQNjpsr47ViCqaYL8lzJycbKuT6dbSgq97b0m1RTCMO1GnNeea9lv(kra0Ux7E250FiqWwDVWM1bntdbcj2yeBCelhhXgQjq18cBwhKyJrSEJhc4swbbSgq97b0m1RTCMO1GnNeKIWpoeoia5s(LSrmHasQw9HaMYLqZ1sEOHV7dbq)sLVseq0lEzMOB3CN(dbc2kXYXrSyJy1CjN6O5Av3KrbfdeSvOtUKFjBILJJyd1eOAEHnRdsSXi254HaUKvqat5sO5Ajp0W39Hue(XhHdcqUKFjBetiGKQvFiGec6vEc08j273q7pxia6xQ8vIaIEXlZeD7M70FiqWwjwgjw)iw(ri4Mg5VR8mDWKyx(wbDJiILJJyXgXkqOCuXr7Blhu2MvfKq)uXXM(V(jwgjwAAsQwEjeRVelhhXUf(ri4(e79BO9NlZw4hHGB3ZoILJJyd1eOAEHnRdsSXiwVXdbCjRGasiOx5jqZNyVFdT)CHue(mlcheGCj)s2iMqajvR(qarnfxrHf2LTH2Srdn1QpZw8QOccG(LkFLiaSrS8JqWP)qGGT6grelJel2iwbcLJko(v3BthmkOyKtyXKJn9F9tSCCe7w4hHGJF1920bJckg5ewm5grelhhXgQjq18cBwhKyJrSXHaUKvqarnfxrHf2LTH2Srdn1QpZw8QOcsr4hViCqaYL8lzJycbq)sLVseq0lEzMOB3CN(dbc2kXYXrSyJy1CjN6O5Av3KrbfdeSvOtUKFjBILJJyd1eOAEHnRdsSXiwVXdbKuT6dbmGIPuHfIue(XdcheGCj)s2iMqajvR(qa0CTmjvR(mRcQiGvbvZLSccGUHifH)C8q4GaKl5xYgXecG(LkFLiGKQLxIroHTeiXgJyzociPA1hcGMRLjPA1NzvqfbSkOAUKvqaqfPi8NphHdcqUKFjBetia6xQ8vIasQwEjg5e2sGelMjwVrajvR(qa0CTmjvR(mRcQiGvbvZLSccq)IIleSvisrkci6fAZYNkche(Zr4GasQw9HaahNkp0WMpUia5s(LSrmHue(EJWbbixYVKnIjeq0l0eQgTyfeWC8qajvR(qa7EWVeJMrifHpZr4GaKl5xYgXec4swbbKyhcMFcnH(uthmr9m5rajvR(qaj2HG5NqtOp10btuptEKIW3Fr4GasQw9HaM1)A7LuN5fyF5rfeGCj)s2iMqkc)4q4GasQw9HaMg5VR8mDWKyx(wbraYL8lzJycPi8Jpcheqs1QpeaRW2pMmDWSg0AB2VKSqeGCj)s2iMqkcFMfHdcqUKFjBetiGOxOjunAXkiG5U4qajvR(qa6peiyRia6xQ8vIasQwEjg5e2sGelMjwVrkc)4fHdcqUKFjBetiGKQvFiGOwR(qaBmDjBrnrVe1kcyosr4hpiCqaYL8lzJycbq)sLVseqs1YlXiNWwcKyJrSmhbKuT6dbKfRSnqWwrksra0neHdc)5iCqaYL8lzJycbq)sLVseWw4hHGdCCQ8qdB(4629SJyzKyXgXYpcbN(dbc2QBeHasQw9HaahNkp0WMpUifHV3iCqaYL8lzJycbq)sLVseaT71UNDUpJQTjuV4EHnRdsSXi2j6My54iwA3RDp7CFgvBtOEX9cBwhKyJrS0Ux7E25YIv2giyRUxyZ6GelhhXgQjq18cBwhKyJrSEJhciPA1hcy3d(Ly0mcPi8zocheGCj)s2iMqa0Vu5Rebe9IxMj62n3P)qGGTsSmsS(rSHAcunVWM1bjwmtS0Ux7E254LhkpU1n52Jp1QpIfdIDp(uR(iwooI1pIvZFsuhOKlf0frvIngX6nEelhhXInIvZLCQJMVegltwSo5s(LSjwFjwFjwooInutGQ5f2SoiXgJyNZCeqs1QpeaV8q5XTUjKIW3Fr4GaKl5xYgXecG(LkFLiGOx8Ymr3U5o9hceSvILrI1pInutGQ5f2SoiXIzIL29A3Zoh)Q7TjmEm52Jp1QpIfdIDp(uR(iwooI1pIvZFsuhOKlf0frvIngX6nEelhhXInIvZLCQJMVegltwSo5s(LSjwFjwFjwooInutGQ5f2SoiXgJyNhFeqs1Qpea)Q7TjmEmHue(XHWbbixYVKnIjea9lv(krarV4LzIUDZD6peiyRelJeRFeBOMavZlSzDqIfZelT71UNDU8Ocu)CzO5A52Jp1QpIfdIDp(uR(iwooI1pIvZFsuhOKlf0frvIngX6nEelhhXInIvZLCQJMVegltwSo5s(LSjwFjwFjwooInutGQ5f2SoiXgJyNhFeqs1QpeqEubQFUm0CTqkc)4JWbbixYVKnIjea9lv(krarV4LzIUDZD6peiyRelJeRFeBOMavZlSzDqIfZelT71UNDUq9c)Q7TBp(uR(iwmi294tT6Jy54iw)iwn)jrDGsUuqxevj2yeR34rSCCel2iwnxYPoA(sySmzX6Kl5xYMy9Ly9Ly54i2qnbQMxyZ6GeBmInEqajvR(qaH6f(v3BKIWNzr4GaKl5xYgXecG(LkFLia(ri40FiqWwD7E2HasQw9Haw1eOcn(VXEIvofPi8Jxeoia5s(LSrmHaOFPYxjcGFeco9hceSv3UNDiGKQvFia(CY0bJ(ffxisr4hpiCqaYL8lzJycbq)sLVsea)ieC6peiyRUDp7iwgjw)iwn)jrDGsUuqxevjwmtSXlEelhhXQ5pjQduYLc6IOkXgZdX6nEelhhXQ5pjQtlwXOTjIQgVXJyXmXYC8iwFrajvR(qaVKr1nzcRKvGifH)C8q4GaKl5xYgXecG(LkFLia)iwA3RDp7Cj2HG5NqtOp10btuptE3lSzDqIfZeR34rSCCel2iwX)CurrY2LyhcMFcnH(uthmr9m5jwooInutGQ5f2SoiXgJyPDV29SZLyhcMFcnH(uthmr9m5D7XNA1hXIbXYC)LyzKy18Ne1bk5sbDruLyXmX6nEeRVelJeRFelT71UNDo9hceSv3lSzDqZ0qGqIngXYCILJJy9JyfiuoQ48QGvFMoyIKpiuT6ZXwx)elJeBOMavZlSzDqIfZeBs1QpdT71UNDelgel)ieCZ6FT9sQZ8cSV8OIBp(uR(iwFjwFjwooInutGQ5f2SoiXgJy9gpeqs1QpeWS(xBVK6mVa7lpQGue(ZNJWbbixYVKnIjea9lv(kra(rS00KuT8siwooInutGQ5f2SoiXIzInPA1NH29A3ZoIfdIL54rS(sSmsS(rS8JqWP)qGGT6grelhhXs7ET7zNt)HabB19cBwhKyJrSZJpX6lXYXrSHAcunVWM1bj2yelZNJasQw9HaMg5VR8mDWKyx(wbrkc)5EJWbbixYVKnIjea9lv(kra0Ux7E250FiqWwDVWM1bj2yelZIasQw9Ha(kkAjM6mWOKkifH)CMJWbbixYVKnIjea9lv(krayJy5hHGt)HabB1nIqajvR(qaScB)yY0bZAqRTz)sYcrkc)5(lcheGCj)s2iMqa0Vu5RebWpcbN(dbc2Q7LKQelJel)ieC8RU3RbuDVKuLy54i2Ox8Ymr3U5o9hceSvILrIvZFsuhOKlf0frvIngX6nEelhhX6hX6hXs7doyt(L4IAT6Z0bZ44)AVKTjmEmrSCCelTp4Gn5xIBC8FTxY2egpMiwFjwgj2qnbQMxyZ6GeBmIn(ZjwooInutGQ5f2SoiXgJy9o(eRViGKQvFiGOwR(qkc)5XHWbbixYVKnIjea9lv(kra8JqWP)qGGT629SJyzKyPDV29SZ9zuTnH6f3lSzDqILJJyd1eOAEHnRdsSXi25XHasQw9Ha0FiqWwrksraqfHdc)5iCqajvR(qa4wRLbc2kcqUKFjBetifHV3iCqajvR(qacZiA1WYlXabBfbixYVKnIjKIWN5iCqaYL8lzJycbq)sLVseqs1YlXiNWwcKyXmXohbKuT6dbWN)Ntcsr47ViCqajvR(qaPHD8B5nDWq)EgebixYVKnIjKIWpoeoiGKQvFiaV61sWecqUKFjBetifHF8r4GaKl5xYgXecG(LkFLiGxcVabt(LqSmsSyJytQw95GYhjNAGADtU6mHvnbQiGKQvFiaO8rYPgOw3esr4ZSiCqaYL8lzJycbq)sLVsea)ieC6peiyRUDp7iwooIn00bKyJrSmpoILJJydnDaj2yeB8XJyzKyXgXQ5so1TefmxgiyRqNCj)s2elhhXYpcbxDgfumpiMuqw3lSzDqIngXkmdHouXOfRGasQw9Ha(mQ2Mq9csr4hViCqaYL8lzJycbq)sLVsea)ieC6peiyRUreXYiX6hXYpcb34K)RBY4vbR(CqnP4sSyMy9xILJJyXgXMyx(sf34K)RBY4vbR(CYL8lztS(sSCCeBOMavZlSzDqIngXoFociPA1hcGF1920bJckg5ewmHue(XdcheGCj)s2iMqa0Vu5RebGnILFeco9hceSv3iIy54i2qnbQMxyZ6GeBmInoeqs1QpeqOPdOSnj2LVuXWljlsr4phpeoia5s(LSrmHaOFPYxjcGFeco9hceSv3iIy54iw)iw(ri429GFjgnJC7E2rSCCelnnjvlVeI1xILrILFecUOxOfumqWwHUDp7iwooInmwlZluW8NeJwScXgJyPjunAXkelJelT71UNDo9hceSv3lSzDqeqs1QpeqwSY2abBfPi8NphHdcqUKFjBetia6xQ8vIaWgXYpcbN(dbc2QBerSCCeBOMavZlSzDqIngXgViGKQvFiGOXxbmv3KHFLqfPi8N7ncheGCj)s2iMqa0Vu5RebeA6asSyqSHMoGUxMKJyzMrSt0nXgJydnDaDSjZGyzKy5hHGt)HabB1T7zhXYiX6hXInID3QJ2hvo9tv2MWkzfd)4p3lSzDqILrIfBeBs1QphTpQC6NQSnHvYkU6mHvnbQeRVelhhXggRL5fky(tIrlwHyJrSt0nXYXrSHAcunVWM1bj2yeBCiGKQvFiaAFu50pvzBcRKvqkc)5mhHdcqUKFjBetia6xQ8vIa4hHG7fkUlbcnH(PIBerSCCel)ieCVqXDjqOj0pvm0ECQ8oOMuCj2ye7C8iwooInutGQ5f2SoiXgJyJdbKuT6dbOGIzC8942Mq)ubPi8N7ViCqaYL8lzJycbq)sLVsea)ieC6peiyRUDp7iwgjw)iw(ri4IEHwqXabBf6grelJeRFeBOPdiXIzInU4iwFjwooIn00bKyXmXYSXrSCCeBOMavZlSzDqIngXghX6lciPA1hciFAEIbc2ksr4ppoeoia5s(LSrmHaOFPYxjcGFeco9hceSv3UNDelJeRFel)ieCrVqlOyGGTcDJiILrI1pIn00bKyXmXgxCeRVelhhXgA6asSyMyz24iwooInutGQ5f2SoiXgJyJJy9fbKuT6dbqbl2u(0abBfPi8NhFeoiGKQvFiaOk5gtgiyRia5s(LSrmHuKIueGxYdR(q47nEEJhEXZ84JaML)v3eebWmH)CMPW3)cFMj9VjwIfhqHyl2O(vIn0pX6)PBO)NyFX)CuVSjwyZkeBo0MnvztSuW8MeOJGL)S6eIDoE(3elZ8(8sEv2eR)x)6WvuN)ehT71UND(FIvBI1)t7ET7zNZFI)Ny9ZBMHVocweS8VyJ6xLnXghXMuT6JyxfuHocwiGOVd1sqa(dI1)iFCHS5bbRiI1F64u5jy5piwajsfwE5jwVJZhI1B88gpcweS8heR)mXlzrSX8qSXHNJGfbRKQvFqx0l0MLpvm8Wa44u5Hg28XLGL)GyzM(fAcvIvbliXMqIvYFHjInHeBudHf)siwTj2OwLtRCTWeXoL1rS51kO8elnHkXUhFDteRckeBOMavhbRKQvFqx0l0MLpvm8WWUh8lXOzKprVqtOA0Iv8mhpcwjvR(GUOxOnlFQy4HHbumLkS(CjR4jXoem)eAc9PMoyI6zYtWkPA1h0f9cTz5tfdpmmR)12lPoZlW(YJkeSsQw9bDrVqBw(uXWddtJ83vEMoysSlFRGeSsQw9bDrVqBw(uXWddScB)yY0bZAqRTz)sYcjyLuT6d6IEH2S8PIHhg0FiqWw9j6fAcvJwSIN5U48PcEsQwEjg5e2sGy2BcwjvR(GUOxOnlFQy4HHOwR(8zJPlzlQj6LOw9mNGvs1QpOl6fAZYNkgEyilwzBGGT6tf8KuT8smYjSLaJXCcweSsQw9bXWdd0ECQ8giyReSsQw9bXWdddOykvy95swXZA84kp0uhS2vpGMPkO(ubp0Ux7E250FiqWwDVWM1bntdbcJnpooUqnbQMxyZ6GXyoEeSsQw9bXWdddOykvy95swXtIDiy(j0e6tnDWe1ZK3Nk4XVqnbQMxyZ6GyM29A3ZomyU)YXP5pjQduYLc6IOAmVXJJtZFsuNwSIrBtevnEJxS5X5lJ0Ux7E250FiqWwDVWM1bntdbcJnpooUqnbQMxyZ6GXyECeSsQw9bXWdddOykvy95swXZAa1VhqZuV2YzIwd2Cs8PcEODV29SZP)qGGT6EHnRdAMgceglooUqnbQMxyZ6GX8gpcwjvR(Gy4HHbumLkS(CjR4zkxcnxl5Hg(UpFQGNOx8Ymr3U5o9hceSvooSP5so1rZ1QUjJckgiyRqNCj)s2CCHAcunVWM1bJnhpcwjvR(Gy4HHbumLkS(CjR4jHGELNanFI9(n0(ZLpvWt0lEzMOB3CN(dbc2kJ(Xpcb30i)DLNPdMe7Y3kOBeXXHnbcLJkoAFB5GY2SQGe6Nko20)1pJ00KuT8s8LJBl8JqW9j273q7pxMTWpcb3UNDCCHAcunVWM1bJ5nEeSsQw9bXWdddOykvy95swXtutXvuyHDzBOnB0qtT6ZSfVkQ4tf8Gn(ri40FiqWwDJigXMaHYrfh)Q7TPdgfumYjSyYXM(V(542c)ieC8RU3MoyuqXiNWIj3iIJlutGQ5f2SoyS4iy5piwCEmrSAtSR6eIDerSjvlVsv2eR(1HROqIDwPGelo)qGGTsWkPA1hedpmmGIPuHf6tf8e9IxMj62n3P)qGGTYXHnnxYPoAUw1nzuqXabBf6Kl5xYMJlutGQ5f2SoymVXJGvs1QpigEyGMRLjPA1Nzvq1Nlzfp0nKGvs1QpigEyGMRLjPA1Nzvq1Nlzfpq1Nk4jPA5LyKtylbgJ5eSsQw9bXWdd0CTmjvR(mRcQ(CjR4r)IIleSvOpvWts1YlXiNWwceZEtWIGvs1QpOJUHy4HbWXPYdnS5JRpvWZw4hHGdCCQ8qdB(4629SJrSXpcbN(dbc2QBerWkPA1h0r3qm8WWUh8lXOzKpvWdT71UNDUpJQTjuV4EHnRdgBIU54ODV29SZ9zuTnH6f3lSzDWy0Ux7E25YIv2giyRUxyZ6GCCHAcunVWM1bJ5nEeSsQw9bD0nedpmWlpuECRBYNk4j6fVmt0TBUt)HabBLr)c1eOAEHnRdIzA3RDp7C8YdLh36MC7XNA1hg7XNA1hhNFA(tI6aLCPGUiQgZB844WMMl5uhnFjmwMSyDYL8lz7RVCCHAcunVWM1bJnN5eSsQw9bD0nedpmWV6EBcJht(ubprV4LzIUDZD6peiyRm6xOMavZlSzDqmt7ET7zNJF192egpMC7XNA1hg7XNA1hhNFA(tI6aLCPGUiQgZB844WMMl5uhnFjmwMSyDYL8lz7RVCCHAcunVWM1bJnp(eSsQw9bD0nedpmKhvG6NldnxlFQGNOx8Ymr3U5o9hceSvg9lutGQ5f2SoiMPDV29SZLhvG6Nldnxl3E8Pw9HXE8Pw9XX5NM)KOoqjxkOlIQX8gpooSP5so1rZxcJLjlwNCj)s2(6lhxOMavZlSzDWyZJpbRKQvFqhDdXWddH6f(v3BFQGNOx8Ymr3U5o9hceSvg9lutGQ5f2SoiMPDV29SZfQx4xDVD7XNA1hg7XNA1hhNFA(tI6aLCPGUiQgZB844WMMl5uhnFjmwMSyDYL8lz7RVCCHAcunVWM1bJfpeSsQw9bD0nedpmSQjqfA8FJ9eRCQpvWd)ieC6peiyRUDp7iyLuT6d6OBigEyGpNmDWOFrXf6tf8WpcbN(dbc2QB3ZocwjvR(Go6gIHhgEjJQBYewjRa9PcE4hHGt)HabB1T7zhJ(P5pjQduYLc6IOkMJx84408Ne1bk5sbDrunMhVXJJtZFsuNwSIrBtevnEJhMzoE(sWkPA1h0r3qm8WWS(xBVK6mVa7lpQ4tf84N(1HROUe7qW8tOj0NA6GjQNjVJ29A3Zo3lSzDqm7nECCyt8phvuKSDj2HG5NqtOp10btuptEoUqnbQMxyZ6GX0VoCf1LyhcMFcnH(uthmr9m5D0Ux7E252Jp1QpmyU)YOM)KOoqjxkOlIQy2B88Lr)ODV29SZP)qGGT6EHnRdAMgcegJ5CC(jqOCuX5vbR(mDWejFqOA1NJTU(zmutGQ5f2SoiMPDV29Sdd(ri4M1)A7LuN5fyF5rf3E8Pw95RVCCHAcunVWM1bJ5nEeSsQw9bD0nedpmmnYFx5z6GjXU8Tc6tf84hnnjvlVeoUqnbQMxyZ6GyM29A3ZomyoE(YOF8JqWP)qGGT6grCC0Ux7E250FiqWwDVWM1bJnp((YXfQjq18cBwhmgZNtWkPA1h0r3qm8WWxrrlXuNbgLuXNk4H29A3ZoN(dbc2Q7f2SoymMLGvs1QpOJUHy4HbwHTFmz6GznO12SFjzH(ubpyJFeco9hceSv3iIGvs1QpOJUHy4HHOwR(8PcE4hHGt)HabB19ssvg5hHGJF19EnGQ7LKQCCrV4LzIUDZD6peiyRmQ5pjQduYLc6IOAmVXJJZp)O9bhSj)sCrTw9z6GzC8FTxY2egpM44O9bhSj)sCJJ)R9s2MW4XKVmgQjq18cBwhmw8NZXfQjq18cBwhmM3X3xcwjvR(Go6gIHhg0FiqWw9PcE4hHGt)HabB1T7zhJ0Ux7E25(mQ2Mq9I7f2SoihxOMavZlSzDWyZJJGfbRKQvFqhuXWdd4wRLbc2kbRKQvFqhuXWddcZiA1WYlXabBLGvs1QpOdQy4Hb(8)Cs8PcEsQwEjg5e2sGyEobRKQvFqhuXWddPHD8B5nDWq)EgKGvs1QpOdQy4HbV61sWebRKQvFqhuXWddq5JKtnqTUjFQGNxcVabt(LWi2sQw95GYhjNAGADtU6mHvnbQeSsQw9bDqfdpm8zuTnH6fFQGh(ri40FiqWwD7E2XXfA6agJ5XXXfA6agl(4Xi20CjN6wIcMldeSvOtUKFjBoo(ri4QZOGI5bXKcY6EHnRdgtygcDOIrlwHGvs1QpOdQy4Hb(v3BthmkOyKtyXKpvWd)ieC6peiyRUreJ(Xpcb34K)RBY4vbR(CqnP4Iz)LJdBj2LVuXno5)6MmEvWQpNCj)s2(YXfQjq18cBwhm285eSsQw9bDqfdpmeA6akBtID5lvm8sY6tf8Gn(ri40FiqWwDJioUqnbQMxyZ6GXIJGvs1QpOdQy4HHSyLTbc2QpvWd)ieC6peiyRUrehNF8JqWT7b)smAg529SJJJMMKQLxIVmYpcbx0l0ckgiyRq3UNDCCHXAzEHcM)Ky0IvIrtOA0IvyK29A3ZoN(dbc2Q7f2SoibRKQvFqhuXWddrJVcyQUjd)kHQpvWd24hHGt)HabB1nI44c1eOAEHnRdglEjyLuT6d6GkgEyG2hvo9tv2MWkzfFQGNqthqmcnDaDVmjhZSj6owOPdOJnzgmYpcbN(dbc2QB3Zog9dB7wD0(OYPFQY2ewjRy4h)5EHnRdYi2sQw95O9rLt)uLTjSswXvNjSQjq1xoUWyTmVqbZFsmAXkXMOBoUqnbQMxyZ6GXIJGvs1QpOdQy4HbfumJJVh32e6Nk(ubp8JqW9cf3LaHMq)uXnI444hHG7fkUlbcnH(PIH2JtL3b1KIBS54XXfQjq18cBwhmwCeSsQw9bDqfdpmKpnpXabB1Nk4HFeco9hceSv3UNDm6h)ieCrVqlOyGGTcDJig9l00beZXfNVCCHMoGyMzJJJlutGQ5f2SoyS48LGvs1QpOdQy4HbkyXMYNgiyR(ubp8JqWP)qGGT629SJr)4hHGl6fAbfdeSvOBeXOFHMoGyoU48LJl00beZmBCCCHAcunVWM1bJfNVeSsQw9bDqfdpmavj3yYabBLGfbRKQvFqN(ffxiyRqm8WaU1AzGGTsWkPA1h0PFrXfc2kedpm4vVwcMiyLuT6d60VO4cbBfIHhg4Z)ZjHGvs1QpOt)IIleSvigEyqygrRgwEjgiyReSsQw9bD6xuCHGTcXWddzXkBdeSvFQGh(ri40VO4AGGTcDJigPPjPA5LWi)ieC7EWVeJMrUrebRKQvFqN(ffxiyRqm8WWNr12eQx8PcE4hHGt)IIRbc2k0nIy0Ve7YxQ4cnDaLTjuV4Kl5xYMJlXU8LkU6mkOyEqmPGSUppCX8CoUe7YxQ4GJFQUjdeSvOtUKFjBoonxYPoO(sYUQtCYL8lz7lbRKQvFqN(ffxiyRqm8WqwSY2abB1Nk4HFeco9lkUgiyRq3iIr)4hHGl6fAbfdeSvOB3ZoooA3RDp7CzXkBdeSvxySwMxOG5pjgTyLyjvR(CzXkBdeSvhnHQrlwHJJFeco9hceSv3iYxcwjvR(Go9lkUqWwHy4HHpJQTjuV4tf8WpcbN(ffxdeSvOBerWkPA1h0PFrXfc2kedpmWowAbbB1Nk4HFeco9lkUgiyRq3UNDCC8JqWf9cTGIbc2k0nIyeB8JqWP)qGGT6grCCHMoGyMzXJGvs1QpOt)IIleSvigEyi00bu2Me7YxQy4LKLGvs1QpOt)IIleSvigEyiA8vat1nz4xjujyLuT6d60VO4cbBfIHhgO9rLt)uLTjSswHGvs1QpOt)IIleSvigEyGF1920bJckg5ewmrWkPA1h0PFrXfc2kedpmOGIzC8942Mq)uXNk4HFecUxO4Uei0e6NkUrehh)ieCVqXDjqOj0pvm0ECQ8oOMuCJnhpcwjvR(Go9lkUqWwHy4HH0Wo(T8MoyOFpdsWkPA1h0PFrXfc2kedpmaLpso1a16M8PcEEj8cem5xcJylPA1NdkFKCQbQ1n5QZew1eOsWkPA1h0PFrXfc2kedpmavj3yYabBfbaJekcFVJZFrksri]] )
    end

end