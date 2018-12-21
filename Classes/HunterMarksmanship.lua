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
            duration = PTR and 6 or 4,
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
        trueshot = PTR and {
            id = 288613,
            duration = 15,
            max_stack = 1,
        } or {
            id = 193526,
            duration = 15,
            max_stack = 1,
        },


        -- Azerite Powers
        unerring_vision = {
            id = 274447,
            duration = function () return buff.trueshot.duration end,
            max_stack = 10,
            meta = {
                stack = function () return max( 1, ceil( query_time - buff.trueshot.applied ) ) end,
            }
        },
    } )


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
            gcd = "spell",
            
            startsCombat = true,
            texture = 249170,

            toggle = "interrupts",
            
            usable = function () return target.casting end,
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
            cast = function () return 3 * ( talent.streamline.enabled and ( PTR and 1.2 or 1.3 ) or 1 ) * haste end,
            channeled = true,
            cooldown = function () return ( PTR and buff.trueshot.up ) and ( haste * 8 ) or 20 end,
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

            spend = PTR and -10 or nil,
            spendType = PTR and "focus" or nil,
            
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
        

        trueshot = PTR and {
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
        } or {
            id = 193526,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 132329,
            
            handler = function ()
                applyBuff( "trueshot" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        potion = "potion_of_rising_death",

        package = "Marksmanship",
    } )


    spec:RegisterPack( "Marksmanship", 20181220.1708, [[due(IaqiruEeLeBseAuQc5uss6vqrZseClvjAxK6xuQgMiYXqLSmjHNrjLPjjHRHkvBtvcFtevghuOohLuP1PkuMNKu3JsSpvjDqjjAHqjpKssmrkjvDrkPcBKssLrsjjDskjLwjLYnvfQ2PQudvevTukPQNkLPQk6QusfTxL(RunykomvlgupMKjlQlJSzq(mQy0q1PfwnLKIxdLA2sCBu1Ub(TkdxKwoKNRy6exxvTDvbFxs04Hc58Osz9qbZxsTFuE5AFUTSl0(UIK4cJ5QIkssZvYLuYXDmEBc3sPTL6kSDo02aopTTh3ryp8oyWJ0TL6CRCEEFUT5(ifTnRWm4IKopMD7Ccb)dRvhV9j4)fxIdOqoKyFcELD4YbBhgYFzMEWEk6GIcn2tEez9EKh7jV13TQFGqO(J7iShEhm4rQEcE12G)rrSAbl82YUq77ksIlmMRkQijnxVG7yCfCTn)l4hABTG3QSn8iNjWcVTmnQTzfM5XDe2dVdg8iLzSQFGqiMnRWm4IKopMD7Ccb)dRvhV9j4)fxIdOqoKyFcELD4YbBhgYFzMEWEk6GIcn2tEez9EKh7jV13TQFGqO(J7iShEhm4rQEcEfZMvygREsr8WeIzQiPeyMksIlmMzEjZW1lEmU)cMnMnRWmwfChWHMhJzZkmZlzMQmNPmZyvUpqieZ0WprZSzfM5LmtvMZuMzSEpnYmJvxGiM5EGqmtvg8uMzA4NWmbeZWT7ZmoIyg(7HaWrZSzfM5LmJ15qmJe8uxUEoiMb5coHygb3bmJ4ioKOLGN6Y1ZbXmYXmoqcvK6cXmeiZmheZOoEyx0BReJm7ZTjOqH9GFYSp33CTp3MRK4aBd2riNdTnc4WfkVyTY(UI952CLehyBegLwUjEG6d(jBJaoCHYlwRSVT2(CBeWHluEXABkuiek8Tb)HG0ckuy3h8tg9pLzsKzEeZ4yGqHqAOt9hk3HcePjGdxOmZuxZmogiuiKoaDbN6iCUj48AKdWMzELz4IzQRzghdekespFeNaWPp4NmAc4WfkZm11mJ4fci6rqKZxcaPjGdxOmZu1T5kjoW2qEAK7qbIwzFxf7ZTrahUq5fRTPqHqOW3g8hcslOqHDFWpz0)uMjrMb(dbPtrKkgQp4Nm68vjyBUsIdSnp4PCFWpzL9n33NBJaoCHYlwBtHcHqHVn4peKwqHc7(GFYO)PBZvsCGTH80i3HceTY((f7ZTrahUq5fRTPqHqOW3g8hcslOqHDFWpz05RsaZuxZmWFiiDkIuXq9b)Kr)tzM6AMb6u)HzELzsUK2MRK4aBJ)xKyWpzL9DYTp3MRK4aBlniKkaC6d(jBJaoCHYlwRSVX4952CLehyBEN)JYeQFqDf6QC2gbC4cLxSwzFBD3NBJaoCHYlwBtHcHqHVnebHOb3HleZKiZKmMXvsCa9qOuci9rcahDa6qLGdUSnxjXb22qOuci9rcaNv23CL0(CBUsIdSTripZT(GFY2iGdxO8I1kRSTmb5)ISp33CTp3MRK4aBtDFGqO(GFY2iGdxO8I1k77k2NBZvsCGT9hQhcXpBJaoCHYlwRSVT2(CBeWHluEXABUsIdSnLxkDxjXb6LyKTvIr6aNN2MkpRSVRI952iGdxO8I12CLehyBkVu6UsId0lXiBtHcHqHVnxjXduNaeFqdZunZyTTvIr6aNN22iRSV5((CBeWHluEXABUsIdSnLxkDxjXb6LyKTPqHqOW3MRK4bQtaIpOHzELzQyBLyKoW5PTjOqH9GFYSYkBlfrQJh2L95(MR952iGdxO8I1k77k2NBJaoCHYlwRSVT2(CBeWHluEXAL9DvSp3gbC4cLxS2McfcHcFBUsIhOobi(GgMPAMXABZvsCGTnFE(d0tjzL9n33NBJaoCHYlwRSVFX(CBUsIdST0tIdSnc4WfkVyTY(o52NBZvsCGTH)bcHMoVJWEBeWHluEXAL9ngVp3gbC4cLxS2wkIu(iDj4PTXvsBZvsCGTLVpCH6INUY(26Up3gbC4cLxS2wkIu(iDj4PTXLM7BZvsCGTjOpn4NSnfkecf(2CLepqDcq8bnmZRmtfRSV5kP952iGdxO8I12uOqiu4BZvs8a1jaXh0WmvZmwBBUsIdSnp4PCFWpzLv2Mkp7Z9nx7ZTrahUq5fRTPqHqOW3wMG)qqA8pqi005De268vjyBUsIdSn8pqi005De2RSVRyFUnc4WfkVyTnfkecf(2KGN6Y1ZbXmvZmCXDMPUMzu3vYxLaTh8uUp4NOreVhGHzQMz4OYmtImZJyg4peKwqFAWpr)tzM6AMjzmJ4fciALxkbGtxWP(GFYOjGdxOmZuvMjrM5rmtYyghdekespFeNaWPp4NmAc4WfkZmjYmjJzeVqarpcIC(sainbC4cLzMezMKXmogiuiKg6u)HYDOarAc4WfkZmvDBUsIdST89Hlux80v23wBFUnc4WfkVyTnfkecf(2u3vYxLanYtJChkqKgr8EagMPAMHJkZmjYmpIzG)qqAb9Pb)e9pLzQRzMKXmIxiGOvEPeaoDbN6d(jJMaoCHYmtvzMezMhXmogiuiKE(iobGtFWpz0eWHluMzQRzgXleq0JGiNVeastahUqzMPUMzCmqOqin0P(dL7qbI0eWHluMzQ62CLehyB57dxOU4PRSVRI952iGdxO8I12uOqiu4BtDxjFvc0c6td(jAeX7byyMxzMxK02CLehyBWeAie2bGZk7BUVp3gbC4cLxS2McfcHcFBQ7k5RsGwqFAWprJiEpadZ8kZyTK2MRK4aBdUCxUd9rCBL99l2NBJaoCHYlwBtHcHqHVn1DL8vjqlOpn4NOreVhGHzELzSwsBZvsCGT5afncYlDLxkRSVtU952iGdxO8I12uOqiu4BtDxjFvc0c6td(jAeX7byyMxzgRL02CLehyBqbIGl3LxzFJX7ZT5kjoW2kbhCz6wn)mhEciBJaoCHYlwRSVTU7ZTrahUq5fRTPqHqOW3g8hcslOpn4NOrKReMjrMb(dbPHl3Ll)r0iYvcZuxZmWFiiTG(0GFI(NYmjYmIJ4qIgN8IGRtvcZunZursmtImJ4fciALJiOFP7bVMaoCHYmtDnZibp1LRNdIzQMzQG7BZvsCGTLEsCGv23CL0(CBeWHluEXABkuiek8Tb)HG0WL7YL)i6FkZuxZmsWtD565GyMxzg1DL8vjqlOpn4NOZFKlXb6C(0mmdMmt(JCjoaZuxZmpIzehXHeno5fbxNQeMPAMPIKyM6AMjzmJ4fciALJiOFP7bVMaoCHYmtvzM6AMrcEQlxpheZunZWf33MRK4aBtqFAWpzLv22i7Z9nx7ZT5kjoW2imkTCt8a1h8t2gbC4cLxSwzFxX(CBeWHluEXABkuiek8T5kjEG6eG4dAyMxzgU2MRK4aBd2riNdTY(2A7ZT5kjoW28o)hLju)G6k0v5Snc4WfkVyTY(Uk2NBJaoCHYlwBtHcHqHVnebHOb3HleZKiZKmMXvsCa9qOuci9rcahDa6qLGdUSnxjXb22qOuci9rcaNv23CFFUnc4WfkVyTnfkecf(2G)qqAEFec15De2dVd0)uMjrMb6u)HzWKzu(iDeXHamt1md0P(JM3XOT5kjoW2CKYbuFWpzL99l2NBJaoCHYlwBtHcHqHVn4peKM)EG4jGO)PmtImZJygOt9hMbtMr5J0rehcWmvZmqN6pAEhJyM6AMXXaHcH0qN6puUdfistahUqzMPUMzCmqOqiDa6co1r4CtW51ihGnZ8kZWfZuxZmogiuiKE(iobGtFWpz0eWHluMzQRzgXleq0JGiNVeastahUqzMPUMzG)qqAb9Pb)e9pLzQ62CLehyBipnYDOarRSVtU952iGdxO8I12uOqiu4Bd(dbPtrKkgQp4Nm68vjGzQRzg1DL8vjq7bpL7d(jAOFP0rKc3rCOUe8eZunZ4kjoG2dEk3h8t0kFKUe8eZuxZmWFiinC5UC5pI(NUnxjXb2Mh8uUp4NSY(gJ3NBJaoCHYlwBtHcHqHVnOt9hMbtMr5J0rehcWmvZmqN6pAEhJyM6AMXXaHcH0qN6puUdfistahUqzMPUMzCmqOqiDa6co1r4CtW51ihGnZ8kZWfZuxZmogiuiKE(iobGtFWpz0eWHluMzQRzgXleq0JGiNVeastahUqzMPUMzG)qqAb9Pb)e9pDBUsIdSnKNg5ouGOv23w3952CLehyBPbHubGtFWpzBeWHluEXAL9nxjTp3gbC4cLxS2McfcHcFBqN6pmZRmZlsIzQRzg4peKofrQyO(GFYO)PmtImd8hcslOpn4NOZxLGT5kjoW2CKYbuFWpzL9nxCTp3MRK4aBBeYZCRp4NSnc4WfkVyTYkRSThi0ehyFxrsCHXCvbxvORWAvb33wLoceaoZ2SA5tpKqzMH7mJRK4amtjgz0mBBBsj1(UcUxfBlfDqrH2MvyMh3ryp8oyWJuMXQ(bcHy2ScZGls68y2TZje8pSwD82NG)xCjoGc5qI9j4v2HlhSDyi)Lz6b7POdkk0yp5rK17rESN8wF3Q(bcH6pUJWE4DWGhP6j4vmBwHzS6jfXdtiMPIKsGzQijUWyM5LmdxV4X4(ly2y2ScZyvWDahAEmMnRWmVKzQYCMYmJv5(aHqmtd)enZMvyMxYmvzotzMX690iZmwDbIyM7bcXmvzWtzMPHFcZeqmd3UpZ4iIz4VhcahnZMvyMxYmwNdXmsWtD565GygKl4eIzeChWmIJ4qIwcEQlxpheZihZ4ajurQleZqGmZCqmJ64HDrZSXSzfMX6aJi1xOmZatqhIyg1Xd7cZatCcWOzMQuPOuzygWbEjUJ4H(fMXvsCGHzoqHBAMnxjXbgDkIuhpSlwGk(GnZMRK4aJofrQJh2fmTy3)C4jG4sCaMnxjXbgDkIuhpSlyAXo0DzMnxjXbgDkIuhpSlyAX(855pqpLKecilUsIhOobi(GMQTgZMvyMgWth8tygKhzMb(dbrzMzexgMbMGoeXmQJh2fMbM4eGHzCqMzsr0ltprcahMjgMjFasZS5kjoWOtrK64HDbtl2hGNo4N0hXLHzZvsCGrNIi1Xd7cMwSNEsCaMnxjXbgDkIuhpSlyAXo(hieA68ocBMnRWmjpIu(imJGhdZ4dZqoQWnMXhMj9MjGleZihZKEcbKWlfUXmC8aWmo4eCcXmkFeMj)rbGdZi4eZafCWfnZMRK4aJofrQJh2fmTypFF4c1fpnHueP8r6sWtw4kjMnxjXbgDkIuhpSlyAXUG(0GFscPis5J0LGNSWLM7jeqwCLepqDcq8bnVwbZMRK4aJofrQJh2fmTy3dEk3h8tsiGS4kjEG6eG4dAQ2AmBmBwHzSoWis9fkZm0deIBmJe8eZi4eZ4k5qmtmmJ)GhfhUqAMnxjXbglQ7dec1h8ty2CLehyW0I9)q9qi(HzZvsCGbtl2vEP0DLehOxIrsa48KfvEy2CLehyW0IDLxkDxjXb6LyKeaopzzKecilUsIhOobi(GMQTgZMRK4adMwSR8sP7kjoqVeJKaW5jlckuyp4NmjeqwCLepqDcq8bnVwbZgZMRK4aJwLhl4FGqOPZ7iStiGSKj4peKg)decnDEhHToFvcy2CLehy0Q8GPf757dxOU4PjeqwKGN6Y1ZbvnxCVUwDxjFvc0EWt5(GFIgr8EaMQ5OYj(i4peKwqFAWpr)tRRtM4fciALxkbGtxWP(GFYOjGdxOCvt8rjZXaHcH0ZhXjaC6d(jJMaoCHYjMmXleq0JGiNVeastahUq5etMJbcfcPHo1FOChkqKMaoCHYvLzZvsCGrRYdMwSNVpCH6INMqazrDxjFvc0ipnYDOarAeX7byQMJkN4JG)qqAb9Pb)e9pTUozIxiGOvEPeaoDbN6d(jJMaoCHYvnXh5yGqHq65J4eao9b)KrtahUq56AXleq0JGiNVeastahUq56AhdekesdDQ)q5ouGinbC4cLRkZMRK4aJwLhmTyhMqdHWoaCsiGSOURKVkbAb9Pb)enI49amV(IKy2CLehy0Q8GPf7WL7YDOpIBjeqwu3vYxLaTG(0GFIgr8EaMxTwsmBUsIdmAvEW0IDhOOrqEPR8sjHaYI6Us(QeOf0Ng8t0iI3dW8Q1sIzZvsCGrRYdMwSdficUCxoHaYI6Us(QeOf0Ng8t0iI3dW8Q1sIzZvsCGrRYdMwSxco4Y0TA(zo8eqy2CLehy0Q8GPf7PNehiHaYc8hcslOpn4NOrKRKeH)qqA4YD5YFenICLuxd)HG0c6td(j6FAIIJ4qIgN8IGRtvs1vKuIIxiGOvoIG(LUh8Ac4Wfkxxlbp1LRNdQ6k4oZMRK4aJwLhmTyxqFAWpjHaYc8hcsdxUlx(JO)P11sWtD565GEvDxjFvc0c6td(j68h5sCGoNpndM5pYL4a11psCehs04KxeCDQsQUIKQRtM4fciALJiOFP7bVMaoCHYvTUwcEQlxphu1CXDMnMnxjXbg9iwimkTCt8a1h8ty2CLehy0JGPf7Woc5COecilUsIhOobi(GMx5IzZvsCGrpcMwS7D(pktO(b1vORYHzZvsCGrpcMwSpekLasFKaWjHaYcIGq0G7WfkXK5kjoGEiukbK(ibGJoaDOsWbxy2CLehy0JGPf7os5aQp4NKqazb(dbP59riuN3ryp8oq)tte6u)btLpshrCiq1qN6pAEhJy2CLehy0JGPf7ipnYDOarjeqwG)qqA(7bINaI(NM4JGo1FWu5J0rehcun0P(JM3XO6AhdekesdDQ)q5ouGinbC4cLRRDmqOqiDa6co1r4CtW51ihG9RCvx7yGqHq65J4eao9b)KrtahUq56AXleq0JGiNVeastahUq56A4peKwqFAWpr)tRkZMRK4aJEemTy3dEk3h8tsiGSa)HG0Pisfd1h8tgD(QeuxRURKVkbAp4PCFWprd9lLoIu4oId1LGNQ2vsCaTh8uUp4NOv(iDj4P6A4peKgUCxU8hr)tz2CLehy0JGPf7ipnYDOarjeqwGo1FWu5J0rehcun0P(JM3XO6AhdekesdDQ)q5ouGinbC4cLRRDmqOqiDa6co1r4CtW51ihG9RCvx7yGqHq65J4eao9b)KrtahUq56AXleq0JGiNVeastahUq56A4peKwqFAWpr)tz2CLehy0JGPf7PbHubGtFWpHzZvsCGrpcMwS7iLdO(GFscbKfOt9NxFrs11WFiiDkIuXq9b)Kr)tte(dbPf0Ng8t05RsaZMRK4aJEemTyFeYZCRp4NWSXS5kjoWOfuOWEWpzSa7iKZHy2CLehy0ckuyp4NmyAXoHrPLBIhO(GFcZMRK4aJwqHc7b)Kbtl2rEAK7qbIsiGSa)HG0ckuy3h8tg9pnXh5yGqHqAOt9hk3HcePjGdxOCDTJbcfcPdqxWPocNBcoVg5aSFLR6AhdekespFeNaWPp4NmAc4WfkxxlEHaIEee58LaqAc4WfkxvMnxjXbgTGcf2d(jdMwS7bpL7d(jjeqwG)qqAbfkS7d(jJ(NMi8hcsNIivmuFWpz05RsaZMRK4aJwqHc7b)Kbtl2rEAK7qbIsiGSa)HG0ckuy3h8tg9pLzZvsCGrlOqH9GFYGPf78)Ied(jjeqwG)qqAbfkS7d(jJoFvcQRH)qq6uePIH6d(jJ(NwxdDQ)8AYLeZMRK4aJwqHc7b)Kbtl2tdcPcaN(GFcZMRK4aJwqHc7b)Kbtl29o)hLju)G6k0v5WS5kjoWOfuOWEWpzW0I9HqPeq6JeaojeqwqeeIgChUqjMmxjXb0dHsjG0hjaC0bOdvco4cZMRK4aJwqHc7b)Kbtl2hH8m36d(jRSYUa]] )
end