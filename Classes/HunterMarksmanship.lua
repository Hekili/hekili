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


    spec:RegisterPack( "Marksmanship", 20181212.2345, [[dyKDGaqikcpskfBsezuIOCkruTkPuIEfGAwKuDlss1Ui1VeHHjf6yKelJI0ZGcnnOu5AKuSnkI8nkIACKKY5KsPwhjLY8Ks19ir7tkXbHsrlek6HKuQMOukHlssjAJqPQyKsPKojuQQwjf1njPK2jGmuOuLLcLcpvstvk6QqPQ0Ev6Vs1GP0HPAXa9yIMSexgzZG8zsy0q1PfwnjLWRHsMTOUnf2TQ(TkdxKwoKNRy6OUoO2ouW3LcgpukDEsswVusZhG9t4vLT5wlotlqM2OkQMkMQIPAtXi2PgmIXTYQkL2AQlXYvqB9DdARQvhH1y4)GhPBn1vv(8Y2CRZbJK0wBJWIZC6O2sKqrW4WGA5zKycd4SZX9sKdXjMWqMamFGjaHCvVqyirk6GImnjWEicB4rzsG9Wg92k8ZeQRwDewJH)dEKQNWqUvq4iZy))cU1IZ0cKPnQIQPIPQyQ2umIDQXuvBRomJFOTwdd1(wXJsH(fCRfAKBTncRA1ryng(p4rQW2wHFMqcZTryXzoDuBjsOiyCyqT8msmHbC254EjYH4etyitaMpWeGqUQximKifDqrMMeypeHn8OmjWEyJEBf(zc1vRocRXW)bps1tyifMBJW2wqsYaKqcRkMQUWAAJQOAcRQlSMIr1g2HDcZcZTryv74(RGg1MWCBewvxyXMLcvew1(b)mHe2k(XAH52iSQUWInlfQiSydpnkcl2Narc7HbcjSyZWGkcBf)yHnGewvDWcRJiH14Wq8k0cZTryvDHf77qclhguNVEjiHf5moHewg3FHLDKcI1CyqD(6LGew(ew)5qgPotcl9fH9Gew5za6SwyUncRQlSTfX4GzQiS(lSytK0FsyR4hlSfysy5tyBIGPb)yHfewHWMsiHTggQDHfoT4mP3AogE2MBLrHeRb)4zBUaPY2CRUKJ73kOJqUcAR07GzQSyU8cKPBZT6soUFRe2MMVjWa1h8J3k9oyMklMlVaHXT5wP3bZuzXCRsuWek8TccdbPzuiXQp4hpA4uHnjHnzcR3kHcM0qNeEOshkqKMEhmtfHfaaH1BLqbt647mo1r4QIXn0i)XsyBryvrybaqy9wjuWKEGrkIxrFWpE007GzQiSaaiSSNPN1dJi3ihpPP3bZuryt(wDjh3VvKNgLouGOLxGWUT5wP3bZuzXCRsuWek8TccdbPzuiXQp4hpA4uHnjHfegcsNIizmuFWpE0LRHFRUKJ73QhguPp4hV8cKA2MBLEhmtLfZTkrbtOW3kimeKMrHeR(GF8OHt3Ql54(TI80O0HceT8cKjTn3k9oyMklMBvIcMqHVvqyiinJcjw9b)4rxUgEHfaaHfegcsNIizmuFWpE0WPclaacl0jHhHTfH1KBCRUKJ73QbCMJb)4LxGm5T5wDjh3V10GqY4v0h8J3k9oyMklMlVaPABZT6soUFRE3agviu)G6s01WSv6DWmvwmxEbQT3MBLEhmtLfZTkrbtOW3kIGq0G7GzsytsynHW6soUxpekLEUpC8k0X3HYHcCERUKJ736qOu65(WXRy5fivACBUvxYX9BDyYlQQp4hVv6DWmvwmxE5TwiihoZBZfiv2MB1LCC)wLh8ZeQp4hVv6DWmvwmxEbY0T5wDjh3Vv4H6btgZwP3bZuzXC5fimUn3k9oyMklMB1LCC)wLEo3Djh33ZXWBnhd3F3G2QSmlVaHDBZTsVdMPYI5wLOGju4B1LCGbQtpze0iSTlSyCRUKJ73Q0Z5Ul54(EogER5y4(7g0whE5fi1Sn3k9oyMklMBvIcMqHVvxYbgOo9KrqJW2IWA6wDjh3VvPNZDxYX99Cm8wZXW93nOTYOqI1GF8S8YBnfrYZa05T5cKkBZTsVdMPYI5YlqMUn3k9oyMklMlVaHXT5wP3bZuzXC5fiSBBUv6DWmvwm3QefmHcFRUKdmqD6jJGgHTDHfJB1LCC)whydJ77PeV8cKA2MBLEhmtLfZLxGmPT5wDjh3V10JJ73k9oyMklMlVazYBZT6soUFR4WptOPB4iS2k9oyMklMlVaPABZTsVdMPYI5wtrK0hUZHbTvvACRUKJ73A5GbZuN90LxGA7T5wP3bZuzXCRPis6d35WG2QkA1SvxYX9BLrW0GF8wLOGju4B1LCGbQtpze0iSTiSMU8cKknUn3k9oyMklMBvIcMqHVvxYbgOo9KrqJW2UWIXT6soUFREyqL(GF8YlVvzz2MlqQSn3k9oyMklMBvIcMqHV1cbcdbPXHFMqt3WryPlxd)wDjh3VvC4Nj00nCewlVaz62CR07GzQSyUvjkycf(w5WG681lbjSTlSQOgHfaaHvExUCn8ApmOsFWpwJidp(ryBxyvilcBscBYewqyiinJGPb)ynCQWcaGWAcHL9m9Sw65C8k6mo1h8Jhn9oyMkcBYf2Ke2KjSMqy9wjuWKEGrkIxrFWpE007GzQiSjjSMqyzptpRhgrUroEstVdMPIWMKWAcH1BLqbtAOtcpuPdfistVdMPIWM8T6soUFRLdgmtD2txEbcJBZTsVdMPYI5wLOGju4BvExUCn8AKNgLouGinIm84hHTDHvHSiSjjSjtybHHG0mcMg8J1WPclaacRjew2Z0ZAPNZXROZ4uFWpE007GzQiSjxytsytMW6TsOGj9aJueVI(GF8OP3bZurybaqyzptpRhgrUroEstVdMPIWcaGW6TsOGjn0jHhQ0HcePP3bZuryt(wDjh3V1YbdMPo7PlVaHDBZTsVdMPYI5wLOGju4BvExUCn8Agbtd(XAez4XpcBlcRj14wDjh3VvqcnecR4vS8cKA2MBLEhmtLfZTkrbtOW3Q8UC5A41mcMg8J1iYWJFe2wewm24wDjh3VvW8DLoemsvlVazsBZTsVdMPYI5wLOGju4BvExUCn8Agbtd(XAez4XpcBlclgBCRUKJ73Q)sAyKN7spNxEbYK3MBLEhmtLfZTkrbtOW3Q8UC5A41mcMg8J1iYWJFe2wewm24wDjh3VvOarG57klVaPABZT6soUFR5qbopD1c4Icd65TsVdMPYI5YlqT92CR07GzQSyUvjkycf(wbHHG0mcMg8J1iYLSWMKWccdbPbZ3vYWdRrKlzHfaaHfegcsZiyAWpwdNkSjjSSJuqSgN8mJRtLSW2UWAAJcBscl7z6zT0reeCU7HHMEhmtfHfaaHLddQZxVeKW2UWAQA2Ql54(TMECC)YlqQ042CR07GzQSyUvjkycf(wbHHG0G57kz4H1WPclaaclhguNVEjiHTfHvExUCn8Agbtd(X6cmY54(UcyAgHfyHTaJCoUxybaqytMWYosbXACYZmUovYcB7cRPnkSaaiSMqyzptpRLoIGGZDpm007GzQiSjxybaqy5WG681lbjSTlSQOMT6soUFRmcMg8JxE5To82CbsLT5wDjh3VvcBtZ3eyG6d(XBLEhmtLfZLxGmDBUv6DWmvwm3QefmHcFRUKdmqD6jJGgHTfHvLT6soUFRGoc5kOLxGW42CRUKJ73Q3nGrfc1pOUeDnmBLEhmtLfZLxGWUT5wP3bZuzXCRsuWek8TIiien4oyMe2KewtiSUKJ71dHsPN7dhVcD8DOCOaN3Ql54(ToekLEUpC8kwEbsnBZTsVdMPYI5wLOGju4BfegcsBCyGmON1WPcBscBYewOtcpclWcR0hUJif0lSTlSqNeE0go2kSaaiSERekysdDs4HkDOarA6DWmvewaaewVvcfmPJVZ4uhHRkg3qJ8hlHTfHvfHfaaH1BLqbt6bgPiEf9b)4rtVdMPIWcaGWYEMEwpmICJC8KMEhmtfHn5B1LCC)wrEAu6qbIwEbYK2MBLEhmtLfZTkrbtOW3kimeKofrYyO(GF8Olxd)wDjh3VvpmOsFWpE5fitEBUv6DWmvwm3QefmHcFRqNeEewGfwPpChrkOxyBxyHoj8OnCSvybaqy9wjuWKg6KWdv6qbI007GzQiSaaiSERekyshFNXPocxvmUHg5pwcBlcRkclaacR3kHcM0dmsr8k6d(XJMEhmtfHfaaHL9m9SEye5g54jn9oyMkB1LCC)wrEAu6qbIwEbs12MB1LCC)wtdcjJxrFWpER07GzQSyU8cuBVn3k9oyMklMBvIcMqHVvOtcpcBlcRj1OWcaGWccdbPtrKmgQp4hpA40T6soUFRos6p1h8JxEbsLg3MB1LCC)whM8IQ6d(XBLEhmtLfZLxE5TIbcnX9lqM2OkQMkMQIk6gBBtn5T2GJ(4vmBf73i9qmvew1iSUKJ7f2Cm8OfM3Ak6GImT12iSQLyljHzQiSGe0HiHvEgGolSGKI4hTWInLskLhH9Vx1XDKbeCwyDjh3pc79zvPfMDjh3p6uejpdqNvcL9blHzxYX9JofrYZa0zGvMWHvyqp7CCVWSl54(rNIi5za6mWktaDxry2LCC)OtrK8maDgyLjgydJ77PeREaP0LCGbQtpze00ogfMBJWwFpDWpwyrEuewqyiiQiSd78iSGe0HiHvEgGolSGKI4hH1)IWMIivp9yoEfcBmcB5Eslm7soUF0PisEgGodSYeZ7Pd(X9HDEeMDjh3p6uejpdqNbwzI0JJ7fMDjh3p6uejpdqNbwzcC4Nj00nCewcZTryXEis6dlSmEmcRpcl5OSQewFe20BMamtclFcB6X0ZHNZQsyv4XlS(FmoHewPpSWwGrXRqyzCsyHcf4Swy2LCC)OtrK8maDgyLjkhmyM6SNQEkIK(WDomiLQ0OWSl54(rNIi5za6mWktWiyAWpw9uej9H7CyqkvrRg1diLUKdmqD6jJGMwmvy2LCC)OtrK8maDgyLj8WGk9b)y1diLUKdmqD6jJGM2XOWSWCBew1sSLKWmvewcdesvclhgKWY4KW6s(qcBmcRJbpYoyM0cZUKJ7hLYd(zc1h8JfMDjh3paRmb8q9GjJry2LCC)aSYespN7UKJ775yy1F3GuklJWSl54(byLjKEo3Djh33ZXWQ)UbPCy1diLUKdmqD6jJGM2XOWSl54(byLjKEo3Djh33ZXWQ)UbPKrHeRb)4r9asPl5aduNEYiOPftfMfMDjh3pAzzuId)mHMUHJWs9aszHaHHG04WptOPB4iS0LRHxy2LCC)OLLbyLjkhmyM6SNQEaPKddQZxVeu7QOgaaK3LlxdV2ddQ0h8J1iYWJFAxHSKuYaHHG0mcMg8J1WPaayc2Z0ZAPNZXROZ4uFWpE007GzQK8KsMj8wjuWKEGrkIxrFWpE007GzQKKjyptpRhgrUroEstVdMPssMWBLqbtAOtcpuPdfistVdMPsYfMDjh3pAzzawzIYbdMPo7PQhqkL3LlxdVg5PrPdfisJidp(PDfYssjdegcsZiyAWpwdNcaGjyptpRLEohVIoJt9b)4rtVdMPsYtkzERekyspWifXROp4hpA6DWmvaaG9m9SEye5g54jn9oyMkaa4TsOGjn0jHhQ0HcePP3bZuj5cZUKJ7hTSmaRmbiHgcHv8kupGukVlxUgEnJGPb)ynIm84NwmPgfMDjh3pAzzawzcW8DLoemsvQhqkL3LlxdVMrW0GFSgrgE8tlySrHzxYX9JwwgGvMWFjnmYZDPNZQhqkL3LlxdVMrW0GFSgrgE8tlySrHzxYX9JwwgGvMakqey(UI6bKs5D5Y1WRzemn4hRrKHh)0cgBuy2LCC)OLLbyLjYHcCE6QfWffg0ZcZUKJ7hTSmaRmr6XX9QhqkbHHG0mcMg8J1iYLCsGWqqAW8DLm8WAe5sgaaqyiinJGPb)ynCAsSJuqSgN8mJRtLC7M2ysSNPN1shrqW5UhgA6DWmvaaGddQZxVeu7MQgHzxYX9JwwgGvMGrW0GFS6bKsqyiiny(UsgEynCkaaCyqD(6LGArExUCn8Agbtd(X6cmY54(UcyAgGlWiNJ7baizSJuqSgN8mJRtLC7M2iaaMG9m9Sw6icco39WqtVdMPsYbaGddQZxVeu7QOgHzHzxYX9JEyLe2MMVjWa1h8JfMDjh3p6HbwzcqhHCfK6bKsxYbgOo9KrqtlQim7soUF0ddSYeE3agviu)G6s01Wim7soUF0ddSYedHsPN7dhVc1diLiccrdUdMPKmHl54E9qOu65(WXRqhFhkhkWzH52iSUKJ7h9WaRmHJK(t9b)y1diLGWqq6uejJH6d(XJgonj5D5Y1WR9WGk9b)yneCo3rKe3rkOohgu7kKL2sqyiiDkIKXq9b)4rpSlXcyxYX9ApmOsFWpwl9H7CyqcZUKJ7h9WaRmbYtJshkqK6bKsqyiiTXHbYGEwdNMuYGoj8aS0hUJif03o0jHhTHJTaa4TsOGjn0jHhQ0HcePP3bZubaaVvcfmPJVZ4uhHRkg3qJ8hRwubaaVvcfmPhyKI4v0h8Jhn9oyMkaaWEMEwpmICJC8KMEhmtLKlm7soUF0ddSYeEyqL(GFS6bKsqyiiDkIKXq9b)4rxUgEHzxYX9JEyGvMa5PrPdfis9asj0jHhGL(WDePG(2Hoj8OnCSfaaVvcfmPHoj8qLouGin9oyMkaa4TsOGjD8DgN6iCvX4gAK)y1Ikaa4TsOGj9aJueVI(GF8OP3bZubaa2Z0Z6HrKBKJN007GzQim7soUF0ddSYePbHKXROp4hlm7soUF0ddSYeos6p1h8JvpGucDs4PftQraaaHHG0Pisgd1h8JhnCQWSl54(rpmWktmm5fv1h8JfMfMDjh3pAgfsSg8JhLGoc5kiHzxYX9JMrHeRb)4byLjiSnnFtGbQp4hlm7soUF0mkKyn4hpaRmbYtJshkqK6bKsqyiinJcjw9b)4rdNMuY8wjuWKg6KWdv6qbI007GzQaaG3kHcM0X3zCQJWvfJBOr(JvlQaaG3kHcM0dmsr8k6d(XJMEhmtfaayptpRhgrUroEstVdMPsYfMDjh3pAgfsSg8JhGvMWddQ0h8JvpGuccdbPzuiXQp4hpA40KaHHG0Pisgd1h8JhD5A4fMDjh3pAgfsSg8JhGvMa5PrPdfis9asjimeKMrHeR(GF8OHtfMDjh3pAgfsSg8JhGvMWaoZXGFS6bKsqyiinJcjw9b)4rxUgEaaaHHG0Pisgd1h8JhnCkaaqNeEAXKBuy2LCC)OzuiXAWpEawzI0GqY4v0h8JfMDjh3pAgfsSg8JhGvMW7gWOcH6huxIUggHzxYX9JMrHeRb)4byLjgcLsp3hoEfQhqkreeIgChmtjzcxYX96HqP0Z9HJxHo(ououGZcZUKJ7hnJcjwd(XdWktmm5fv1h8J36KsYfitvd2T8Y7c]] )
end