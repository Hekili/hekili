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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            spend = function () return buff.lock_and_load.up and 0 or ( ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 35 ) end,
            spendType = "focus",

            startsCombat = true,
            texture = 135130,

            cycle = function () return runeforge.serpentstalkers_treacher.enabled and "serpent_sting" or nil end,

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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 30 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 10 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 10 end,
            spendType = "focus",

            startsCombat = true,
            texture = 1033905,

            velocity = 45,

            talent = "serpent_sting",

            impact = function ()
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


    spec:RegisterPack( "Marksmanship", 20201123, [[dK0UmbqiuIEevkPnHs1NqPmkQuDkPeRIkLIEfizwujTlk9lcXWKs6ycLLrO6zesnnucUgvcBJkr9nQePXrijNJkLyDOaMhi19Oi7df0bPsewiHYdjKyIuPu4IuPu6JujIgjHKsNefiTsHQzIsOBsiPyNOq)efiwkkq5PGAQOiFLqs1yPO0EH6Vu1Gj6WIwmv8yunzL6YiBwWNLIrtWPvSAuGQxJsA2k52uy3Q8BjdhehNkLQLd8CvnDsxxQ2okQVlLA8uuCEkQwpvkMVq2pKXXWmHH3PsygfVvXBnwmXfTnMlex0XehdRMdHWWqsoRzdHHV0GWWIAsaRVrEVWabddjnFv5gZeg(RoGtyy3kskOkKNberKMrf6owEziYpg9vQtDCqgur(XGlcg2PplLb9Woy4DQeMrXBv8wJftCrBJ5cXfDRUmgo7QqbWWWJHOGHfM9MoSdgEtphd7wrsrnjG13iVxyGGKIA7NsauC3ksYyXmz4qaKuCr7kskERI3kgEnV(yMWWky4S(cL(yMWmgdZegMU0zrBSyyyoyucmjgwZfDQ9vk3M7dfV)w6sNfTrs2rY58H10iOij7iPtpeSVs52CFO493ciJCUhjHgjDbgo56uhg(vk3M7FHsXkMrXXmHHPlDw0glggMdgLatIH5fZ0LNAz1CWKhsYosYRATR2NfqFDPoxJpbGQTfqg5Cpscns2W3izuesYRATR2NfKqMTpmaYciJCUhjHgj5vT2v7ZMJbT9VqP2qFT8aIlKGgYRJbHKrrijlrs3rsnx0P2xbuASMJS0LolAJKSJKG(rHc0q2VdAMRX)cL(w6sNfTrYwqYOiKKLijVyMU8ulRMdM8WWjxN6WW7Q7SiVMqWkMrrJzcdtx6SOnwmmmhmkbMedd6hfkqdz)QVcfOH8KHdbElDPZI2ij7iPMaVcsiwazKZ9ij0izdFJKSJK8Qw7Q9zdReqwazKZ9ij0izdFJHtUo1HH1e4vqcbRygzbmtyy6sNfTXIHH5GrjWKyynbEfKqSDiij7ijOFuOanK9R(kuGgYtgoe4T0LolAJHtUo1HHdReqyfZOlWmHHtUo1HHjZazv)Wm5FHsXW0LolAJfdRygDzmty4KRtDy42ZA7Fidy0hdtx6SOnwmSIz0LIzcdNCDQdddOVUuNRXNaq1gdtx6SOnwmSIzuuHzcdNCDQddZCTwK5yy6sNfTXIHvmJUfmty4KRtDyyNeaYgcdtx6SOnwmSIzmwRyMWWjxN6WWkOtVqPyy6sNfTXIHvmJXIHzcdtx6SOnwmmmhmkbMed70dbRcgoR(xO03ciJCUhjzOjKKmdX7k51XGqs2rsq)OqbAi73bnZ14FHsFlDPZI2ij7iPtpeS7Q7SiVMqS7Q9HHtUo1HHbjKz7ddGWkMXyIJzcdtx6SOnwmmCY1PomCog02)cLIH5GrjWKyyNEiyvWWz1)cL(wazKZ9ijdnHKKziExjVogesYos6os60dbleaXNN8VqPVDxTpKmkcjd91YdiUqcAiVogescnsYZx96yqijuizdFJKrriPtpeSkOtVqP2oeKSfmm3C(I8AcAi9XmgdRygJjAmtyy6sNfTXIHH5GrjWKy4qX7pscfsYZx9aQHoKeAKmu8(BnsZGHtUo1HH3uQcEUqYkinWkMXySaMjmmDPZI2yXWWCWOeysmStpeSky4S6FHsFlGmY5EKKHMqsYmeVRKxhdcdNCDQdddsiZ2hgaHvmJXCbMjmmDPZI2yXWWCWOeysmStpeSky4S6FHsF7UAFizues60dbleaXNN8VqPVTdbjzhjdfV)ijdrsE9kscfsMCDQZMJbT9VqPwE9ksYos6osYsKuZfDQLlmgjbs)luQLU0zrBKmkcjtUomtE6iJHEKKHiPOrYwWWjxN6WWg9LoVqPyfZymxgZegMU0zrBSyyyoyucmjg2PhcwiaIpp5FHsFBhcsYosgkE)rsgIK86vKekKm56uNnhdA7FHsT86vKKDKm56Wm5PJmg6rsOrswadNCDQddZfgJKaP)fkfRygJ5sXmHHPlDw0glggMdgLatIHD6HGDt52tMt2D1(WWjxN6WWSoRL)fkfRygJjQWmHHtUo1HHdfV)02NUHaJsEhknWW0LolAJfdRygJ5wWmHHtUo1HHH0btW85A8oR8vmmDPZI2yXWkMrXBfZego56uhgMxhNofKkT9HvAqyy6sNfTXIHvmJIhdZegMU0zrBSyyyoyucmjggcGy23W32ywMR1ImhjJIqswIKAUOtTmxRfzULU0zrBKmkcjdtJG6bKro3JKqJKXIHHtUo1HHDwvT9vWRcKNoYWCSIzuCXXmHHPlDw0glggMdgLatIHD6HGfqCwx0)(qb4KTdbjJIqsNEiybeN1f9Vpuao55v)ucyFn5SIKqJKXAfdNCDQddRcKVFov)2(qb4ewXmkUOXmHHtUo1HHtVrhSjGVcEoOA)yy6sNfTXIHvmJIZcyMWWjxN6WWHvAoT9VqPyy6sNfTXIHvmJI7cmtyy6sNfTXIHHtUo1HHFcaHo1)6Cnyyoyucmjggqba9cPZIWWCZ5lYRjOH0hZymSIzuCxgZegMU0zrBSyyyoyucmjgou8(JKmej51RijuizY1PoBog02)cLA51Ry4KRtDyyJ(sNxOuSIzuCxkMjmCY1Pom8RuUn3)cLIHPlDw0glgwXkgEtHSVumtygJHzcdNCDQddZR(PeW)cLIHPlDw0glgwXmkoMjmmDPZI2yXWWjxN6WW8QFkb8VqPyyoyucmjgg0pkuGgY(eeHUBEpeqXxPrQtDw6sNfTrYOiK8R(YzUT9gZZ3RvTEpKA(6qYOiK0DKKx3UpQfqmtGpx(k4dfq7hzPlDw0gjzhjzjsc6hfkqdzFcIq3nVhcO4R0i1PolDPZI2izly41CKNVXWIUvSIzu0yMWWjxN6WW9N8JsgpgMU0zrBSyyfZilGzcdtx6SOnwmmCY1Pom8QdyLaVFUF2t1FFZeummhmkbMedZRATR2NvbD6fk1ciJCU330P)rsOrYyUajJIqYW0iOEazKZ9ij0iPOBfdFPbHHxDaRe49Z9ZEQ(7BMGIvmJUaZegMU0zrBSyy4KRtDy40nVqcY3hQt9vWdPAtammhmkbMed7osgMgb1diJCUhjzisMCDQZZRATR2hscfskAwajJIqsnbnKAfOCPcwiCfjHgjfVvKmkcj1e0qQvhdYRLhcx9I3kscnsgZfizlij7ijVQ1UAFwf0PxOulGmY5EFtN(hjHgjJ5cKmkcjdtJG6bKro3JKqJKI2fy4lnimC6Mxib57d1P(k4HuTjawXm6YyMWW0LolAJfddNCDQddV6VcQ(7BQ1MopKv3iBimmhmkbMedZRATR2NvbD6fk1ciJCU330P)rsOrsxGKrrizyAeupGmY5EKeAKu8wXWxAqy4v)vq1FFtT205HS6gzdHvmJUumtyy6sNfTXIHHtUo1HHBYfXZ1IaV3PQddZbJsGjXWo9qWQGo9cLAbKro3JKmejJXcizuesYsKuZfDQLNR1CnEvG8VqPVLU0zrBKmkcjdtJG6bKro3JKqJKXAfdFPbHHBYfXZ1IaV3PQdRygfvyMWW0LolAJfddNCDQddNVaZ5rVhKUPaEEbYfgMdgLatIHD6HGvbD6fk1ciJCUhjzisgJfqs2rs3rsNEiyB6jyp55RGpDdbkvW2HGKrrijlrs6F64KLx3MUN2(1eOqb4K1izWlasYosYtFY1HzcjBbjJIqYn50dbliDtb88cKl)MC6HGDxTpKmkcjdtJG6bKro3JKqJKI3kg(sdcdNVaZ5rVhKUPaEEbYfwXm6wWmHHPlDw0glggo56uhggsXzL0FCdT98YasxtDQZVjMhoHH5GrjWKyywIKo9qWQGo9cLA7qqs2rswIK0)0XjRZQQTVcEvG80rgMBnsg8cGKrri5MC6HG1zv12xbVkqE6idZTDiizuesgMgb1diJCUhjHgjDbg(sdcddP4Ss6pUH2EEzaPRPo153eZdNWkMXyTIzcdNCDQdd3FYpkz8yy6sNfTXIHvmJXIHzcdtx6SOnwmmCY1PommpxlFY1Po)AEfdVMx9xAqyy((XkMXyIJzcdtx6SOnwmmmhmkbMedNCDyM80rgd9ij0iPOXWjxN6WW8CT8jxN68R5vm8AE1FPbHHFfRygJjAmtyy6sNfTXIHH5GrjWKy4KRdZKNoYyOhjziskogo56uhgMNRLp56uNFnVIHxZR(lnimScgoRVqPpwXkggcG4LHtQyMWmgdZegMU0zrBSyyyoyucmjgg0pkuGgY(vFfkqd5jdhc8w6sNfTXWjxN6WWAc8kiHGvmJIJzcdtx6SOnwmmmeaXZx96yqy4yTIHtUo1HH3v3zrEnHGH5GrjWKyywIK8Iz6YtTSAoyYdjzhjDhjzjsQ5Io1YCTwK5w6sNfTrYOiKm56Wm5PJmg6rsOrsXrYwWkMrrJzcdtx6SOnwmm8LgegoDZlKG89H6uFf8qQ2eadNCDQddNU5fsq((qDQVcEivBcGvmJSaMjmCY1PomC7cS2mtZ5b0xxECcdtx6SOnwmSIz0fyMWWjxN6WWn9eSN88vWNUHaLkGHPlDw0glgwXm6YyMWWjxN6WWgKrbm3xb)QZNTFdO04XW0LolAJfdRygDPyMWW0LolAJfddZbJsGjXWjxhMjpDKXqpscnskAmCY1PomCog02)cLIvmJIkmtyy6sNfTXIHH5GrjWKy4KRdZKNoYyOhjziskogo56uhg(vk3M7FHsXkwXW89JzcZymmtyy6sNfTXIHH5GrjWKyyNEiyvqNEHsTDiizuesgMgb1diJCUhjHgjJjAmCY1PomSdbEcW6CnyfZO4yMWW0LolAJfddZbJsGjXWo9qWQGo9cLA7qqYOiKmmncQhqg5CpscnsgZLXWjxN6WWoRQ2(qhyowXmkAmtyy6sNfTXIHH5GrjWKyyNEiyvqNEHsTDiizuesgMgb1diJCUhjHgjJ5Yy4KRtDy4840RGC555AHvmJSaMjmmDPZI2yXWWCWOeysmStpeSkOtVqP2oeKmkcjdtJG6bKro3JKqJKUfmCY1PomCyaKZQQnwXm6cmtyy6sNfTXIHH5GrjWKyyNEiyvqNEHsT7Q9HHtUo1HHxtJG(Eg8(UXGofRygDzmtyy6sNfTXIHH5GrjWKyyNEiyvqNEHsT7Q9HHtUo1HHDYgFf8ky4S(yfZOlfZegMU0zrBSyyyoyucmjg2Phcwf0PxOuBhcsYos60dbRZQQ9Q)QTdbjJIqsNEiyvqNEHsTDiij7iPMGgsTcuUubleUIKqJKI3ksgfHKHPrq9aYiN7rsOrsXDzmCY1PommKsN6WkMrrfMjmmDPZI2yXWWCWOeysmStpeSkOtVqP2D1(qs2rs3rsnbnKAfOCPcwiCfjziskQAfjJIqsnbnKAfOCPcwiCfjH2eskERizuesQjOHuRogKxlpeU6fVvKKHiPOBfjBbdNCDQdddOeYCn(WknOhRygDlyMWW0LolAJfddZbJsGjXWUJK8Qw7Q9zt38cjiFFOo1xbpKQnbSaYiN7rsgIKI3ksgfHKSejj3EFGaH220nVqcY3hQt9vWdPAtaKmkcjdtJG6bKro3JKqJK8Qw7Q9zt38cjiFFOo1xbpKQnbS7oi1PoKekKu0SasYosQjOHuRaLlvWcHRijdrsXBfjBbjzhjDhj5vT2v7ZQGo9cLAbKro37B60)ij0iPOrYOiK0DKK(NoozzE(PoFf8qiqG46uN1yUcGKSJKHPrq9aYiN7rsgIKjxN688Qw7Q9HKqHKo9qW2UaRnZ0CEa91LhNS7oi1PoKSfKSfKmkcjdtJG6bKro3JKqJKI3kgo56uhgUDbwBMP58a6RlpoHvmJXAfZegMU0zrBSyyyoyucmjg2DKKN(KRdZesgfHKHPrq9aYiN7rsgIKjxN688Qw7Q9HKqHKIUvKSfKKDK0DK0Phcwf0PxOuBhcsgfHK8Qw7Q9zvqNEHsTaYiN7rsOrYyUms2csgfHKHPrq9aYiN7rsOrsrhddNCDQdd30tWEYZxbF6gcuQawXmglgMjmmDPZI2yXWWCWOeysmmVQ1UAFwf0PxOulGmY5EKeAK0LIHtUo1HHbdeilYpN)HKCcRygJjoMjmmDPZI2yXWWCWOeysmmlrsNEiyvqNEHsTDiy4KRtDyydYOaM7RGF15Z2VbuA8yfRy4xXmHzmgMjmmDPZI2yXWWCWOeysmSMl6u7RuUn3hkE)T0LolAJKSJKUJKqaeZ(g(2gZ(kLBZ9VqPij7iPtpeSVs52CFO493ciJCUhjHgjDbsgfHKo9qW(kLBZ9HI3F7UAFizly4KRtDy4xPCBU)fkfRygfhZego56uhgM1zT8VqPyy6sNfTXIHvmJIgZegMU0zrBSyyyoyucmjgMxmtxEQLvZbtEij7ijVQ1UAFwa91L6Cn(eaQ2wazKZ9ij0izdFJKrrijlrsEXmD5Pwwnhm5HKSJKUJK8Qw7Q9zZXG2(xOuBhcsgfHK8Qw7Q9zbjKz7ddGSaYiN7rsgIK8Qw7Q9zZXG2(xOulGmY5EKSfmCY1Pom8U6olYRjeSIzKfWmHHPlDw0glggMdgLatIH1e4vqcX2HGKSJKG(rHc0q2V6RqbAipz4qG3sx6SOngo56uhgoSsaHvmJUaZegMU0zrBSyyyoyucmjgg0pkuGgY(vFfkqd5jdhc8w6sNfTrs2rsnbEfKqSaYiN7rsOrYg(gjzhj5vT2v7ZgwjGSaYiN7rsOrYg(gdNCDQddRjWRGecwXm6YyMWWjxN6WWKzGSQFyM8VqPyy6sNfTXIHvmJUumty4KRtDy42ZA7Fidy0hdtx6SOnwmSIzuuHzcdNCDQddhwP502)cLIHPlDw0glgwXm6wWmHHPlDw0glggMdgLatIHdfV)ijuijpF1dOg6qsOrYqX7V1indgo56uhgEtPk45cjRG0aRygJ1kMjmmDPZI2yXWWCWOeysmStpeSqaeFEY)cL(2D1(qYOiKKLiPMl6ulxymscK(xOulDPZI2izuesMCDyM80rgd9ij0iP4y4KRtDyyMR1ImhRygJfdZego56uhgo9gDWMa(k45GQ9JHPlDw0glgwXmgtCmty4KRtDyya91L6Cn(eaQ2yy6sNfTXIHvmJXenMjmmDPZI2yXWWCWOeysmStpeSqaeFEY)cL(2D1(qYOiK0Phcwa91L6Cn(eaQ22oeKmkcjD6HGT9S2(hYag9TDiizues60dblZ1ArMB7qqs2rYKRdZKNoYyOhjzisgddNCDQddRGo9cLIvmJXybmtyy6sNfTXIHHtUo1HHZXG2(xOummhmkbMed70dbleaXNN8VqPVDxTpKmkcjDhjD6HGvbD6fk12HGKrrizOVwEaXfsqd51XGqsOrYg(gjHcj55REDmiKSfKKDK0DKKLiPMl6ulxymscK(xOulDPZI2izuesMCDyM80rgd9ij0iP4izlizues60dbRcgoR(xO03ciJCUhjzissMH4DL86yqij7izY1HzYthzm0JKmejJHH5MZxKxtqdPpMXyyfZymxGzcdtx6SOnwmmmhmkbMedhkE)rsOqsE(Qhqn0HKqJKHI3FRrAgKKDK0DK0Phcwf0PxOu7UAFizuesYsKe0pkuGgYszZI0Cv37vqN8HI3FlDPZI2izlij7iP7iPtpeS7Q7SiVMqS7Q9HKrriPMl6u7RaknwZrw6sNfTrYwWWjxN6WWGeYS9HbqyfZymxgZegMU0zrBSyyyoyucmjg2PhcwiaIpp5FHsFBhcsgfHKHI3FKKHijVEfjHcjtUo1zZXG2(xOulVEfdNCDQddZfgJKaP)fkfRygJ5sXmHHPlDw0glggMdgLatIHD6HGfcG4Zt(xO032HGKrrizO49hjzisYRxrsOqYKRtD2CmOT)fk1YRxXWjxN6WWjGNh5FHsXkMXyIkmtyy6sNfTXIHHtUo1HHFcaHo1)6Cnyyoyucmjggqba9cPZIqs2rsnbnKA1XG8A53dHKmej3DqQtDyyU58f51e0q6JzmgwXmgZTGzcdtx6SOnwmmmhmkbMedNCDyM80rgd9ijdrYyy4KRtDyyNeaYgcRygfVvmtyy6sNfTXIHH5GrjWKy4qX7pscfsYZx9aQHoKeAKmu8(BnsZGKSJKUJKo9qWURUZI8AcXUR2hsgfHKAUOtTVcO0ynhzPlDw0gjBbdNCDQdddsiZ2hgaHvmJIhdZegMU0zrBSyyyoyucmjg2Phcwf0PxOuBhcsYos6os60dbB)iayUgpZZp1zFn5SIKmejzbKmkcjzjsMUHaJs2(raWCnEMNFQZsx6SOns2csgfHKHPrq9aYiN7rsOrYyXWWjxN6WWoRQ2(k4vbYthzyowXmkU4yMWW0LolAJfddZbJsGjXWSejD6HGvbD6fk12HGKrrizyAeupGmY5EKeAK0fy4KRtDy4qX7pT9PBiWOK3HsdSIzuCrJzcdtx6SOnwmmmhmkbMedZsK0Phcwf0PxOuBhcsgfHKHPrq9aYiN7rsOrsrfgo56uhggshmbZNRX7SYxXkMrXzbmtyy6sNfTXIHH5GrjWKy4qX7pscfsgkE)TaQHoK0Tjs2W3ij0izO493AKMbjzhjD6HGvbD6fk1UR2hsYos6osYsKCxQLxhNofKkT9HvAqENo4SaYiN7rs2rswIKjxN6S8640PGuPTpSsdYoNpSMgbfjBbjJIqYqFT8aIlKGgYRJbHKqJKn8nsgfHKHPrq9aYiN7rsOrsxGHtUo1HH51XPtbPsBFyLgewXmkUlWmHHPlDw0glggMdgLatIHD6HGfqCwx0)(qb4KTdbjJIqsNEiybeN1f9Vpuao55v)ucyFn5SIKqJKXAfjJIqYW0iOEazKZ9ij0iPlWWjxN6WWQa57Nt1VTpuaoHvmJI7YyMWWjxN6WWVs52C)lukgMU0zrBSyyfRyfdZmb(PomJI3Q4TgRvXB1gdd3ob3Cnpgwu3LGbJrgugDjzaKejzsGqYXasbuKmuaKKnfmCwFHsF2qsa527dG2i5xgesMDTmsL2ijxiVg6TO4S4CesgJbqsrPoMjGsBKKnnx0PwZYgsQfsYMMl6uRzT0LolAZgs6EmZ0IffNfNJqsXzaKuuQJzcO0gjztZfDQ1SSHKAHKSP5Io1AwlDPZI2SHKUhZmTyrXzX5iKuCgajfL6yMakTrs2a9JcfOHSMLnKulKKnq)OqbAiRzT0LolAZgs6EmZ0IffNfNJqsrZaiPOuhZeqPnsYgOFuOanK1SSHKAHKSb6hfkqdznRLU0zrB2qs3JzMwSO4S4CesYcmaskk1XmbuAJKSb6hfkqdznlBiPwijBG(rHc0qwZAPlDw0MnKmvK0TLbHfrs3JzMwSO4S4CesglgdGKIsDmtaL2ijBG(rHc0qwZYgsQfsYgOFuOanK1Sw6sNfTzdjDpMzAXIIZIZrizmxWaiPOuhZeqPnsYMMl6uRzzdj1cjztZfDQ1Sw6sNfTzdjDpMzAXIIJIlQ7sWGXidkJUKmasIKmjqi5yaPaksgkasY2MczFPSHKaYT3haTrYVmiKm7AzKkTrsUqEn0BrXzX5iKuCgajfL6yMakTrs2a9JcfOHSMLnKulKKnq)OqbAiRzT0LolAZgs6U4MPflkolohHKIZaiPOuhZeqPnsYgVUDFuRzzdj1cjzJx3UpQ1Sw6sNfTzdjDpMzAXIIJIlQ7sWGXidkJUKmasIKmjqi5yaPaksgkasYgeaXldNuzdjbKBVpaAJKFzqiz21YivAJKCH8AO3IIZIZrizmgajfL6yMakTrs2a9JcfOHSMLnKulKKnq)OqbAiRzT0LolAZgsMks62YGWIiP7XmtlwuCwCocjfNbqsrPoMjGsBKKnnx0PwZYgsQfsYMMl6uRzT0LolAZgs6EmZ0Iffhfxu3LGbJrgugDjzaKejzsGqYXasbuKmuaKKn((zdjbKBVpaAJKFzqiz21YivAJKCH8AO3IIZIZriPBHbqsrPoMjGsBKKnfmhRKAnRLx1AxTp2qsTqs24vT2v7ZAw2qs3f3mTyrXrXf1DjyWyKbLrxsgajrsMeiKCmGuafjdfajz7v2qsa527dG2i5xgesMDTmsL2ijxiVg6TO4S4CesgJbqsrPoMjGsBKKnnx0PwZYgsQfsYMMl6uRzT0LolAZgs6EmZ0IffNfNJqswGbqsrPoMjGsBKKnq)OqbAiRzzdj1cjzd0pkuGgYAwlDPZI2SHKPIKUTmiSis6EmZ0IffNfNJqsxWaiPOuhZeqPnsYgOFuOanK1SSHKAHKSb6hfkqdznRLU0zrB2qs3JzMwSO4S4CesgRvgajfL6yMakTrs20CrNAnlBiPwijBAUOtTM1sx6SOnBiP7XmtlwuCwCocjJXcmaskk1XmbuAJKSP5Io1Aw2qsTqs20CrNAnRLU0zrB2qs3JzMwSO4S4CesgZfmaskk1XmbuAJKSP5Io1Aw2qsTqs20CrNAnRLU0zrB2qs3JzMwSO4S4CesgZfmaskk1XmbuAJKSb6hfkqdznlBiPwijBG(rHc0qwZAPlDw0MnK09yMPflkolohHKI3kdGKIsDmtaL2ijBAUOtTMLnKulKKnnx0PwZAPlDw0MnK09yMPflkokodQbKcO0gjDbsMCDQdjxZRVffhddbuHzryy3kskQjbS(g59cdeKuuB)ucGI7wrsglMjdhcGKIlAxrsXBv8wrXrXtUo19wiaIxgoPcLjr0e4vqcX1jyc0pkuGgY(vFfkqd5jdhc8O4jxN6EleaXldNuHYKi7Q7SiVMqCfcG45REDmitXA11jyIL8Iz6YtTSAoyYJD3zPMl6ulZ1ArMhfLCDyM80rgd9qlElO4jxN6EleaXldNuHYKi9N8JsgUEPbzkDZlKG89H6uFf8qQ2eafp56u3BHaiEz4KkuMePDbwBMP58a6RlpoHINCDQ7TqaeVmCsfktI00tWEYZxbF6gcuQakEY1PU3cbq8YWjvOmjIbzuaZ9vWV68z73aknEu8KRtDVfcG4LHtQqzsKCmOT)fk11jyk56Wm5PJmg6Hw0O4jxN6EleaXldNuHYKiVs52C)luQRtWuY1HzYthzm0ZqXrXrXtUo19qzseE1pLa(xOuuC3ksYedIBdgegajrsMeMhjBpRfsEeTrYVdbsbuKulKmxRQnskkv)ucGKWcLIKTfOdj1e0qksopsELIK8815ASO4jxN6EOmjcV6Nsa)luQRR5ipFBs0T66emb6hfkqdzFcIq3nVhcO4R0i1PUOOV6lN522BmpFVw169qQ5RlkYDED7(OwaXmb(C5RGpuaTFe7Se0pkuGgY(eeHUBEpeqXxPrQtDTGINCDQ7HYKi9N8JsgpkEY1PUhktI0FYpkz46LgKPvhWkbE)C)SNQ)(MjOUobt8Qw7Q9zvqNEHsTaYiN79nD6FOJ5IOOW0iOEazKZ9ql6wrXtUo19qzsK(t(rjdxV0GmLU5fsq((qDQVcEivBc46em5EyAeupGmY5EgYRATR2huIMfII0e0qQvGYLkyHWvOfV1OinbnKA1XG8A5HWvV4TcDmx0c78Qw7Q9zvqNEHsTaYiN79nD6FOJ5IOOW0iOEazKZ9qlAxGINCDQ7HYKi9N8JsgUEPbzA1Ffu933uRnDEiRUr2qUobt8Qw7Q9zvqNEHsTaYiN79nD6FODruuyAeupGmY5EOfVvu8KRtDpuMeP)KFuYW1lnitn5I45ArG37u156em50dbRc60luQfqg5CpdJXcrrSuZfDQLNR1CnEvG8VqPVLU0zr7OOW0iOEazKZ9qhRvu8KRtDpuMeP)KFuYW1lnit5lWCE07bPBkGNxGC56em50dbRc60luQfqg5CpdJXcS7UtpeSn9eSN88vWNUHaLky7qIIyj9pDCYYRBt3tB)AcuOaCYAKm4fGDE6tUomtTefTjNEiybPBkGNxGC53KtpeS7Q9fffMgb1diJCUhAXBffp56u3dLjr6p5hLmC9sdYeKIZkP)4gA75LbKUM6uNFtmpCY1jyILo9qWQGo9cLA7qyNL0)0XjRZQQTVcEvG80rgMBnsg8cefTjNEiyDwvT9vWRcKNoYWCBhsuuyAeupGmY5EODbkUBfjzcyosQfsUMJqYoeKm56WCQ0gjvWCSs6JKThvajzc0PxOuu8KRtDpuMeP)KFuY4rXtUo19qzseEUw(KRtD(18QRxAqM47hfp56u3dLjr45A5tUo15xZRUEPbz6vxNGPKRdZKNoYyOhArJINCDQ7HYKi8CT8jxN68R5vxV0GmPGHZ6lu676emLCDyM80rgd9muCuCu8KRtDVLVFtoe4jaRZ146em50dbRc60luQTdjkkmncQhqg5Cp0XenkEY1PU3Y3puMeXzv12h6aZDDcMC6HGvbD6fk12HeffMgb1diJCUh6yUmkEY1PU3Y3puMejpo9kixEEUwUobto9qWQGo9cLA7qIIctJG6bKro3dDmxgfp56u3B57hktIega5SQA76em50dbRc60luQTdjkkmncQhqg5Cp0Ufu8KRtDVLVFOmjYAAe03ZG33ng0PUobto9qWQGo9cLA3v7dfp56u3B57hktI4Kn(k4vWWz9DDcMC6HGvbD6fk1UR2hkEY1PU3Y3puMebsPtDUobto9qWQGo9cLA7qy3PhcwNvv7v)vBhsuKtpeSkOtVqP2oe21e0qQvGYLkyHWvOfV1OOW0iOEazKZ9qlUlJINCDQ7T89dLjrauczUgFyLg076em50dbRc60luQDxTp2DxtqdPwbkxQGfcxzOOQ1OinbnKAfOCPcwiCfAtI3AuKMGgsT6yqET8q4Qx8wzOOBTfu8KRtDVLVFOmjs7cS2mtZ5b0xxECY1jyYDfmhRKAt38cjiFFOo1xbpKQnbS8Qw7Q9zbKro3ZqXBnkILKBVpqGqBB6Mxib57d1P(k4HuTjquuyAeupGmY5EOvWCSsQnDZlKG89H6uFf8qQ2eWYRATR2ND3bPo1bLOzb21e0qQvGYLkyHWvgkERTWU78Qw7Q9zvqNEHsTaYiN79nD6FOfDuK70)0XjlZZp15RGhcbcexN6SgZva2dtJG6bKro3ZqEvRD1(GYPhc22fyTzMMZdOVU84KD3bPo11slrrHPrq9aYiN7Hw8wrXtUo19w((HYKin9eSN88vWNUHaLk46em5op9jxhMPOOW0iOEazKZ9mKx1AxTpOeDRTWU7o9qWQGo9cLA7qII4vT2v7ZQGo9cLAbKro3dDmxULOOW0iOEazKZ9ql6yO4jxN6ElF)qzseWabYI8Z5FijNCDcM4vT2v7ZQGo9cLAbKro3dTlffp56u3B57hktIyqgfWCFf8RoF2(nGsJ31jyILo9qWQGo9cLA7qqXrXtUo192xn9kLBZ9VqPUobtAUOtTVs52CFO49ND3HaiM9n8TnM9vk3M7FHsz3Phc2xPCBUpu8(BbKro3dTlIIC6HG9vk3M7dfV)2D1(Abfp56u3BFfktIW6Sw(xOuu8KRtDV9vOmjYU6olYRjexNGjEXmD5Pwwnhm5XoVQ1UAFwa91L6Cn(eaQ2wazKZ9q3W3rrSKxmtxEQLvZbtES7oVQ1UAF2CmOT)fk12HefXRATR2NfKqMTpmaYciJCUNH8Qw7Q9zZXG2(xOulGmY5(wqXtUo192xHYKiHvcixNGjnbEfKqSDiSd6hfkqdz)QVcfOH8KHdbEu8KRtDV9vOmjIMaVcsiUobtG(rHc0q2V6RqbAipz4qGNDnbEfKqSaYiN7HUHVzNx1AxTpByLaYciJCUh6g(gfp56u3BFfktIqMbYQ(HzY)cLIINCDQ7TVcLjrApRT)HmGrFu8KRtDV9vOmjsyLMtB)lukkEY1PU3(kuMeztPk45cjRG0W1jyku8(dfpF1dOg6Gou8(BnsZGINCDQ7TVcLjryUwlYCxNGjNEiyHai(8K)fk9T7Q9ffXsnx0PwUWyKei9VqPrrjxhMjpDKXqp0IJINCDQ7TVcLjrsVrhSjGVcEoOA)O4jxN6E7Rqzsea91L6Cn(eaQ2O4jxN6E7Rqzsef0PxOuxNGjNEiyHai(8K)fk9T7Q9ff50dblG(6sDUgFcavBBhsuKtpeSTN12)qgWOVTdjkYPhcwMR1Im32HWEY1HzYthzm0ZWyO4UvKKjge3gmimasYGrmpuBKm56uN9jae6u)RZ1yNZhwtJG61YRjOHuu8KRtDV9vOmjsog02)cL6k3C(I8AcAi9nfZ1jyYPhcwiaIpp5FHsF7UAFrrU70dbRc60luQTdjkk0xlpG4cjOH86yqq3W3qXZx96yqTWU7SuZfDQLlmgjbs)luAuuY1HzYthzm0dT4Tef50dbRcgoR(xO03ciJCUNHKziExjVoge7jxhMjpDKXqpdJHINCDQ7TVcLjrajKz7ddGCDcMcfV)qXZx9aQHoOdfV)wJ0mS7UtpeSkOtVqP2D1(IIyjOFuOanKLYMfP5QU3RGo5dfV)TWU7o9qWURUZI8AcXUR2xuKMl6u7RaknwZrTGINCDQ7TVcLjr4cJrsG0)cL66em50dbleaXNN8VqPVTdjkku8(ZqE9kujxN6S5yqB)luQLxVIINCDQ7TVcLjrsappY)cL66em50dbleaXNN8VqPVTdjkku8(ZqE9kujxN6S5yqB)luQLxVIINCDQ7TVcLjrEcaHo1)6CnUYnNViVMGgsFtXCDcMauaqVq6Si21e0qQvhdYRLFped3DqQtDO4jxN6E7RqzseNeaYgY1jyk56Wm5PJmg6zymu8KRtDV9vOmjciHmBFyaKRtWuO49hkE(Qhqn0bDO493AKMHD3D6HGDxDNf51eIDxTVOinx0P2xbuASMJAbfp56u3BFfktI4SQA7RGxfipDKH5Uobto9qWQGo9cLA7qy3DNEiy7hbaZ14zE(Po7RjNvgYcrrSmDdbgLS9JaG5A8mp)uNLU0zr7wIIctJG6bKro3dDSyO4jxN6E7RqzsKqX7pT9PBiWOK3HsdxNGjw60dbRc60luQTdjkkmncQhqg5Cp0Uafp56u3BFfktIaPdMG5Z14Dw5RUobtS0Phcwf0PxOuBhsuuyAeupGmY5EOfvO4jxN6E7RqzseEDC6uqQ02hwPb56emfkE)Hku8(BbudDUnB4BOdfV)wJ0mS70dbRc60luQDxTp2DNL7sT8640PGuPTpSsdY70bNfqg5Cp7Sm56uNLxhNofKkT9HvAq258H10iOTeff6RLhqCHe0qEDmiOB47OOW0iOEazKZ9q7cu8KRtDV9vOmjIkq((5u9B7dfGtUobto9qWcioRl6FFOaCY2Hef50dblG4SUO)9HcWjpV6Nsa7RjNvOJ1AuuyAeupGmY5EODbkEY1PU3(kuMe5vk3M7FHsrXrXtUo19wfmCwFHsFtVs52C)luQRtWKMl6u7RuUn3hkE)zFoFynnck7o9qW(kLBZ9HI3FlGmY5EODbkEY1PU3QGHZ6lu6dLjr2v3zrEnH46emXlMPlp1YQ5Gjp25vT2v7ZcOVUuNRXNaq12ciJCUh6g(okIx1AxTpliHmBFyaKfqg5Cp08Qw7Q9zZXG2(xOuBOVwEaXfsqd51XGIIyP7AUOtTVcO0ynhXoOFuOanK97GM5A8VqPFlrrSKxmtxEQLvZbtEO4jxN6ERcgoRVqPpuMertGxbjexNGjq)OqbAi7x9vOanKNmCiWZUMaVcsiwazKZ9q3W3SZRATR2NnSsazbKro3dDdFJINCDQ7Tky4S(cL(qzsKWkbKRtWKMaVcsi2oe2b9JcfOHSF1xHc0qEYWHapkEY1PU3QGHZ6lu6dLjriZazv)Wm5FHsrXtUo19wfmCwFHsFOmjs7zT9pKbm6JINCDQ7Tky4S(cL(qzsea91L6Cn(eaQ2O4jxN6ERcgoRVqPpuMeH5ATiZrXtUo19wfmCwFHsFOmjItcazdHINCDQ7Tky4S(cL(qzsef0PxOuu8KRtDVvbdN1xO0hktIasiZ2hga56em50dbRcgoR(xO03ciJCUNHMiZq8UsEDmi2b9JcfOHSFh0mxJ)fk9z3Phc2D1DwKxti2D1(qXtUo19wfmCwFHsFOmjsog02)cL6k3C(I8AcAi9nfZ1jyYPhcwfmCw9VqPVfqg5CpdnrMH4DL86yqS7UtpeSqaeFEY)cL(2D1(IIc91YdiUqcAiVoge088vVogeun8DuKtpeSkOtVqP2oKwqXtUo19wfmCwFHsFOmjYMsvWZfswbPHRtWuO49hkE(Qhqn0bDO493AKMbfp56u3BvWWz9fk9HYKiGeYS9HbqUobto9qWQGHZQ)fk9TaYiN7zOjYmeVRKxhdcfp56u3BvWWz9fk9HYKig9LoVqPUobto9qWQGHZQ)fk9T7Q9ff50dbleaXNN8VqPVTdH9qX7pd51RqLCDQZMJbT9VqPwE9k7UZsnx0PwUWyKei9VqPrrjxhMjpDKXqpdfDlO4jxN6ERcgoRVqPpuMeHlmgjbs)luQRtWKtpeSqaeFEY)cL(2oe2dfV)mKxVcvY1PoBog02)cLA51RSNCDyM80rgd9qZcO4jxN6ERcgoRVqPpuMeH1zT8VqPUobto9qWUPC7jZj7UAFO4jxN6ERcgoRVqPpuMeju8(tBF6gcmk5DO0afp56u3BvWWz9fk9HYKiq6Gjy(CnENv(kkEY1PU3QGHZ6lu6dLjr41XPtbPsBFyLgekEY1PU3QGHZ6lu6dLjrCwvT9vWRcKNoYWCxNGjiaIzFdFBJzzUwlY8OiwQ5Io1YCTwK5w6sNfTJIctJG6bKro3dDSyO4jxN6ERcgoRVqPpuMerfiF)CQ(T9HcWjxNGjNEiybeN1f9Vpuaoz7qIIC6HGfqCwx0)(qb4KNx9tjG91KZk0XAffp56u3BvWWz9fk9HYKiP3Od2eWxbphuTFu8KRtDVvbdN1xO0hktIewP502)cLIINCDQ7Tky4S(cL(qzsKNaqOt9VoxJRCZ5lYRjOH03umxNGjafa0lKolcfp56u3BvWWz9fk9HYKig9LoVqPUobtHI3FgYRxHk56uNnhdA7FHsT86vu8KRtDVvbdN1xO0hktI8kLBZ9VqPy4hcXXmkUlybSIvmga]] )

end