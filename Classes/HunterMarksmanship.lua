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

        if debuff.tar_trap.up then
            debuff.tar_trap.expires = debuff.tar_trap.applied + 30
        end

        if now - action.volley.lastCast < 6 then applyBuff( "volley", 6 - ( now - action.volley.lastCast ) ) end

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

            usable = function ()
                if action.aimed_shot.cast > 0 and moving and settings.prevent_hardcasts then return false, "prevent_hardcasts is checked and player is moving" end
                return true
            end,

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
            cooldown = function () return level > 55 and 25 or 30 end,
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

        potion = "spectral_agility",

        package = "Marksmanship",
    } )

    
    spec:RegisterSetting( "prevent_hardcasts", false, {
        name = "Prevent Hardcasts of |T135130:0|t Aimed Shot During Movement",
        desc = "If checked, the addon will not recommend |T135130:0|t Aimed Shot if it has a cast time and you are moving.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Marksmanship", 20201213, [[dOu26aqiQk8iOkLnHO8jfXOOQ0PuK8kOsZIuXTGQKAxu6xKknmkuogvPLrL4zuj10OqvxJufBJcv(gvfLXrvr15OQiwhvsMhPQUhfSpOkoiPkjlKc5Hks1ejvj6IKQK6JKQuzKKQuLtcvjwjvQzQiLBsvrYoHQ6NKQuwkuLKNIWuHIUkPkv1xjvjmwOq7fP)c0GbDyrlMIEmjtwHlJAZs5ZkQrtkNwPvtvrQxJOA2s1TPIDRYVfgoICCOkvwoKNRQPtCDaBNQQVtvmEOGZdvSEOkvnFO0(Lm1lftkXifMIVlgZfJ51fVU2611gZ4CnLqWHetjiLkYZzMsCPdtj8Pse5VtEV2sIsqkXPh5GIjL4daKIPe4TcQjcP3v6Q78kAaMwv4O7Voa9u24uOSj6(RJsxkHjW2f8YrnPeJuyk(UymxmMxx86ARxxBmJZfFoLibeTarjiwNPtj02XGpQjLyWVIsG3kOpvIi)DY71wsfuVhWjmQCJ3kOEjRyhtgvqVUwNc6IXCXyuI((YtXKsiOvr(RfYtXKIVxkMuc(sZopOgrjuOvy0Mucj78j2x4CGdyluaVLV0SZJcswb3dS13znPGKvqtGwZ(cNdCaBHc4Ti2j37lO(fupuIujBCuIx4CGd4RfcvO47cftkbFPzNhuJOek0kmAtkHk8ZxEILCCqBEfKScQIOpcpNfXFCPS3myIqHhlIDY9(cQFbNvJcIfBb9rbvHF(YtSKJdAZRGKvqFuqv4NV8e7TZAcyl5cIfBbvHF(YtS3oRjGTKlizf03cQIOpcpN1Z2hGpPfTYBrStU3xq9l4SAuqSylOkI(i8CwbbWVwiwe7K79fepfup6PGtvqSylOKOzwSY6WGsaowUG6xqVgJsKkzJJsmcaZodkjjQqX31umPe8LMDEqnIsOqRWOnPeiGJBbAMTFa0BbAMbzhtg9w(sZopkizfuseOGsswe7K79fu)coRgfKScQIOpcpNT1teBrStU3xq9l4SAqjsLSXrjKebkOKevO4B8umPe8LMDEqnIsKkzJJs06jIPek0kmAtkHKiqbLKSaKkizfebCClqZS9dGElqZmi7yYO3YxA25bLOVhdQgucx0dvO4RhkMuIujBCucgdK6XV(zWxlekbFPzNhuJOcfFJJIjLivYghLWZ2hGpPfTYtj4ln78GAevO47ZOysjsLSXrjq8hxk7ndMiu4HsWxA25b1iQqX3NtXKsKkzJJs4p6DghkbFPzNhuJOcfFFcftkrQKnokHzIq5mtj4ln78GAevO471yumPePs24OeccGFTqOe8LMDEqnIku896LIjLGV0SZdQrucfAfgTjLWeO1ScAvKd(AH8we7K79fepgkiJbwbimOSoCbjRGiGJBbAMTpaAEVzWxlK3YxA25rbjRGMaTMDeaMDguss2r45OePs24OeOK0oaBlIPcfFVUqXKsWxA25b1ikrQKnokrUo8a81cHsOqRWOnPeMaTMvqRICWxlK3IyNCVVG4XqbzmWkaHbL1Hlizf03cAc0AwsiwTpd(AH82r45kiwSfSb07GiwPLOzguwhUG6xqv(cOSoCbXTGZQrbXITGMaTMvqa8RfIfGubNIsOWr1zqjrZS8u89sfk(EDnftkbFPzNhuJOek0kmAtkrluaFbXTGQ8fqepZxb1VGTqb8wNeduIujBCuIbNIgOsljhLouHIVxJNIjLGV0SZdQrucfAfgTjLWeO1ScAvKd(AH8we7K79fepgkiJbwbimOSomLivYghLaLK2byBrmvO47vpumPe8LMDEqnIsOqRWOnPeMaTMvqRICWxlK3ocpxbXITGMaTMLeIv7ZGVwiVfGubjRGTqb8fepfufVuqClyQKnoBUo8a81cXQIxkizf03c6JckzNpXQ0wNKrj4RfILV0SZJcIfBbtLS(zq(yNL)cINc66cofLivYghLWbOl7RfcvO4714Oysj4ln78GAeLqHwHrBsjmbAnljeR2NbFTqElaPcswbBHc4liEkOkEPG4wWujBC2CD4b4RfIvfVuqYkyQK1pdYh7S8xq9lOXtjsLSXrjuARtYOe81cHku896ZOysj4ln78GAeLqHwHrBsjmbAn7GZbiJdBhHNJsKkzJJsq(27GVwiuHIVxFoftkrQKnokrc6aGgmcmAGku45Pe8LMDEqnIku896tOysjsLSXrjA9ehEa(AHqj4ln78GAevO47IXOysj4ln78GAeLivYghL4zej(eWx2BMsOqRWOnPeiUH4xln7mLqHJQZGsIMz5P47Lku8DXlftkbFPzNhuJOek0kmAtkrluaFbXtbvXlfe3cMkzJZMRdpaFTqSQ4fkrQKnokHdqx2xleQqX3fxOysjsLSXrjEHZboGVwiuc(sZopOgrfQqjgClb6cftk(EPysjsLSXrjubWjmc81cHsWxA25b1iQqX3fkMuc(sZopOgrjsLSXrjubWjmc81cHsOqRWOnPeiGJBbAMTptsdaV)bjHcvpDszJZYxA25rbXITGFa0n3ByVfN8bLi6piPy)4kiwSf03cQIBaSIfX(z0NDWOb2cKaCSLV0SZJcswb9rbrah3c0mBFMKgaE)dscfQE6KYgNLV0SZJcofLOVhdQgucxBmQqX31umPe8LMDEqnIsCPdtjgiohTfXG(5)5oLivYghLyG4C0wed6N)N7uHIVXtXKsWxA25b1ikHcTcJ2Ksyc0AwbbWVwiwasfel2cAc0AwbbWVwi2r45kizfufrFeEoRGa4xlelIDY9(cINc6IXkiwSfSTZAciIDY9(cQFbvr0hHNZkia(1cXIyNCVNsKkzJJsa8m4kSZtfk(6HIjLGV0SZdQruIujBCucv27GPs24a77luI((c4LomLqnEQqX34Oysj4ln78GAeLqHwHrBsjsLS(zq(yNL)cQFbDnLivYghLqL9oyQKnoW((cLOVVaEPdtjEHku89zumPe8LMDEqnIsOqRWOnPePsw)miFSZYFbXtbDHsKkzJJsOYEhmvYghyFFHs03xaV0HPecAvK)AH8uHkucsiwfoMPqXKIVxkMuIujBCucZqKopaB9ehE4zVzqjWWEuc(sZopOgrfk(UqXKsWxA25b1ikHcTcJ2KsGaoUfOz2(bqVfOzgKDmz0B5ln78GsKkzJJsijcuqjjQqX31umPe8LMDEqnIsqcXQ8fqzDykHxJrjsLSXrjgbGzNbLKeLqHwHrBsjsLS(zq(yNL)cINc6TGyXwqFuqv4NV8el54G28kizf0hfuYoFI1F07mow(sZopOcfFJNIjLGV0SZdQrucfAfgTjLivY6Nb5JDw(lO(f01fKSc6Bb9rbvHF(YtSKJdAZRGKvqFuqj78jw)rVZ4y5ln78OGyXwWujRFgKp2z5VG6xqxk4uuIujBCuICD4b4RfcvO4RhkMuc(sZopOgrjuOvy0MuIujRFgKp2z5VG4PGUuqSylOVfuf(5lpXsooOnVcIfBbLSZNy9h9oJJLV0SZJcovbjRGPsw)miFSZYFbnuqxOePs24OeVW5ahWxleQqfkHA8umP47LIjLGV0SZdQrucfAfgTjLWeO1SccGFTqSaKkiwSfSTZAciIDY9(cQFb96AkrQKnokHjJEgr(EZuHIVlumPe8LMDEqnIsOqRWOnPeMaTMvqa8RfIfGubXITGTDwtarStU3xq9lOxJJsKkzJJsy2Jya2aq4qfk(UMIjLGV0SZdQrucfAfgTjLWeO1SccGFTqSaKkiwSfSTZAciIDY9(cQFb9ACuIujBCuI8u8lOSdQYENku8nEkMuc(sZopOgrjuOvy0MuctGwZkia(1cXcqQGyXwW2oRjGi2j37lO(f0NqjsLSXrjAlIn7rmOcfF9qXKsWxA25b1ikHcTcJ2Ksyc0AwbbWVwi2r45OePs24Oe9DwtEqFAGXSdFcvO4BCumPe8LMDEqnIsOqRWOnPeMaTMvqa8RfIDeEokrQKnokHzodgnqbTkYFQqX3NrXKsWxA25b1ikHcTcJ2Ksyc0AwbbWVwiwasfKScAc0AwZEeJoWlwasfel2cAc0AwbbWVwiwasfKSckjAMfRgNDrZssjfu)c6IXkiwSfSTZAciIDY9(cQFbDX4OePs24OeKczJJkuHs8cftk(EPysj4ln78GAeLqHwHrBsjKSZNyFHZboGTqb8w(sZopkizf03cscX(bNvdRx7lCoWb81cPGKvqtGwZ(cNdCaBHc4Ti2j37lO(fupfel2cAc0A2x4CGdyluaVDeEUcofLivYghL4foh4a(AHqfk(UqXKsKkzJJsq(27GVwiuc(sZopOgrfk(UMIjLGV0SZdQrucfAfgTjLqf(5lpXsooOnVcswbvr0hHNZI4pUu2BgmrOWJfXo5EFb1VGZQrbXITG(OGQWpF5jwYXbT5vqYkOpkOk8ZxEI92znbSLCbXITGQWpF5j2BN1eWwYfKSc6Bbvr0hHNZ6z7dWN0Iw5Ti2j37lO(fCwnkiwSfufrFeEoRGa4xlelIDY9(cINcQh9uWPkiwSfus0mlwzDyqjahlxq9lOx9qjsLSXrjgbGzNbLKevO4B8umPe8LMDEqnIsKkzJJs06jIPek0kmAtkHKiqbLKSaKkizfebCClqZS9dGElqZmi7yYO3YxA25bLOVhdQgucx0dvO4RhkMuc(sZopOgrjuOvy0MuceWXTanZ2pa6TanZGSJjJElFPzNhfKSckjcuqjjlIDY9(cQFbNvJcswbvr0hHNZ26jITi2j37lO(fCwnOePs24OesIafusIku8nokMuIujBCucgdK6XV(zWxlekbFPzNhuJOcfFFgftkrQKnokHNTpaFslALNsWxA25b1iQqX3NtXKsKkzJJs06jo8a81cHsWxA25b1iQqX3NqXKsWxA25b1ikHcTcJ2Ks0cfWxqClOkFbeXZ8vq9lyluaV1jXaLivYghLyWPObQ0sYrPdvO471yumPePs24OejOdaAWiWObQqHNNsWxA25b1iQqX3RxkMuIujBCuce)XLYEZGjcfEOe8LMDEqnIku896cftkbFPzNhuJOek0kmAtkHjqRzjHy1(m4RfYBhHNRGyXwqFuqj78jwL26KmkbFTqS8LMDEuqSylyQK1pdYh7S8xq9lOluIujBCuc)rVZ4qfk(EDnftkbFPzNhuJOek0kmAtkHjqRzjHy1(m4RfYBhHNRGyXwqtGwZI4pUu2BgmrOWJfGubXITGMaTM1Z2hGpPfTYBbivqSylOjqRz9h9oJJfGubjRGPsw)miFSZYFbXtb9sjsLSXrjeea)AHqfk(EnEkMuc(sZopOgrjsLSXrjY1HhGVwiucfAfgTjLWeO1SKqSAFg81c5TJWZvqSylOVf0eO1SccGFTqSaKkiwSfSb07GiwPLOzguwhUG6xWz1OG4wqv(cOSoCbNQGKvqFlOpkOKD(eRsBDsgLGVwiw(sZopkiwSfmvY6Nb5JDw(lO(f0LcovbXITGMaTMvqRICWxlK3IyNCVVG4PGmgyfGWGY6WfKScMkz9ZG8Xol)fepf0lLqHJQZGsIMz5P47Lku89QhkMuc(sZopOgrjuOvy0MuIwOa(cIBbv5lGiEMVcQFbBHc4Tojgkizf03cAc0AwbbWVwi2r45kiwSf0hfebCClqZSLZ5olzpUhuqamyluaVLV0SZJcovbjRG(wqtGwZocaZodkjj7i8Cfel2ckzNpX(cItN(ESLV0SZJcofLivYghLaLK2byBrmvO4714Oysj4ln78GAeLqHwHrBsjmbAnljeR2NbFTqElaPcIfBbBHc4liEkOkEPG4wWujBC2CD4b4RfIvfVqjsLSXrjuARtYOe81cHku896ZOysj4ln78GAeLqHwHrBsjmbAnljeR2NbFTqElaPcIfBbBHc4liEkOkEPG4wWujBC2CD4b4RfIvfVqjsLSXrjsKkpg81cHku896ZPysj4ln78GAeLivYghL4zej(eWx2BMsOqRWOnPeiUH4xln7CbjRGsIMzXkRddkb4y5cINcoaqPSXrju4O6mOKOzwEk(EPcfFV(ekMuc(sZopOgrjuOvy0MuIujRFgKp2z5VG4PGEPePs24OeMjcLZmvO47IXOysj4ln78GAeLqHwHrBsjAHc4liUfuLVaI4z(kO(fSfkG36KyOGKvqFlOjqRzhbGzNbLKKDeEUcIfBbLSZNyFbXPtFp2YxA25rbNIsKkzJJsGss7aSTiMku8DXlftkrQKnokXlCoWb81cHsWxA25b1iQqfQqj8ZOFJJIVlgZfJ51fJ5tOeEs0T38tj0l0RWRWhVGVENRkybXuJl46qkqsbBbQGte0Qi)1c5NuqeJ3bSiEuWpC4cMas4KcpkOslVz(TL7PThxqVUQGtpo)ms4rbNizNpXIXjfuIcorYoFIfJw(sZopMuqF9IHPSL7PThxqx7Qco948ZiHhfCcc44wGMzlgNuqjk4eeWXTanZwmA5ln78ysb91lgMYwUN2ECbnExvWPhNFgj8OGtqah3c0mBX4KckrbNGaoUfOz2IrlFPzNhtkykfuVwVnTc6RxmmLTCpT94c61RRk40JZpJeEuWjiGJBbAMTyCsbLOGtqah3c0mBXOLV0SZJjf0xVyykB5EA7Xf0RECvbNEC(zKWJcorYoFIfJtkOefCIKD(elgT8LMDEmPG(6fdtzl3LB9c9k8k8Xl4R35Qcwqm14cUoKcKuWwGk4Kb3sGUmPGigVdyr8OGF4WfmbKWjfEuqLwEZ8Bl3tBpUGU4Qco948ZiHhfCcc44wGMzlgNuqjk4eeWXTanZwmA5ln78ysb91lgMYwUN2ECbDXvfC6X5Nrcpk4eeWXTanZwmoPGsuWjiGJBbAMTy0YxA25XKc6RxmmLTCpT94c6IRk40JZpJeEuWjQ4gaRyX4KckrbNOIBaSIfJw(sZopMuqF9IHPSL7YTEHEfEf(4f817CvbliMACbxhsbskylqfCcjeRchZuMuqeJ3bSiEuWpC4cMas4KcpkOslVz(TL7PThxqxCvbNEC(zKWJcobbCClqZSfJtkOefCcc44wGMzlgT8LMDEmPGPuq9A920kOVEXWu2Y902JlORDvbNEC(zKWJcorYoFIfJtkOefCIKD(elgT8LMDEmPGPuq9A920kOVEXWu2Y902JlOX7Qco948ZiHhfCIKD(elgNuqjk4ej78jwmA5ln78ysb91lgMYwUN2ECb1JRk40JZpJeEuWjs25tSyCsbLOGtKSZNyXOLV0SZJjf0xVyykB5UCRxOxHxHpEbF9oxvWcIPgxW1HuGKc2cubN8YKcIy8oGfXJc(HdxWeqcNu4rbvA5nZVTCpT94c61vfC6X5Nrcpk4ej78jwmoPGsuWjs25tSy0YxA25XKc6RxmmLTCpT94cA8UQGtpo)ms4rbNGaoUfOz2IXjfuIcobbCClqZSfJw(sZopMuWukOETEBAf0xVyykB5EA7XfupUQGtpo)ms4rbNGaoUfOz2IXjfuIcobbCClqZSfJw(sZopMuqF9IHPSL7PThxqVU4Qco948ZiHhfCIKD(elgNuqjk4ej78jwmA5ln78ysb91lgMYwUN2ECb9A8UQGtpo)ms4rbNizNpXIXjfuIcorYoFIfJw(sZopMuqF9IHPSL7PThxqV6XvfC6X5Nrcpk4ej78jwmoPGsuWjs25tSy0YxA25XKc6RxmmLTCpT94c6vpUQGtpo)ms4rbNGaoUfOz2IXjfuIcobbCClqZSfJw(sZopMuqF9IHPSL7PThxqxmMRk40JZpJeEuWjs25tSyCsbLOGtKSZNyXOLV0SZJjf0xVyykB5UCJxCifiHhfupfmvYgxb77lVTCtjEsSIIVl6X4PeKqrB7mLaVvqFQer(7K3RTKkOEpGtyu5gVvq9swXoMmQGEDTof0fJ5IXk3L7ujBCVLeIvHJzk4AqxZqKopaB9ehE4zVzqjWWEL7ujBCVLeIvHJzk4AqxjrGckjPZ2mGaoUfOz2(bqVfOzgKDmz0xUtLSX9wsiwfoMPGRbDhbGzNbLKKoKqSkFbuwh2GxJPZ2mKkz9ZG8Xol)4XlwS(qf(5lpXsooOnpY8HKD(eR)O3zCk3Ps24EljeRchZuW1GU56WdWxleD2MHujRFgKp2z5xFxtMV(qf(5lpXsooOnpY8HKD(eR)O3zCWInvY6Nb5JDw(13LPk3Ps24EljeRchZuW1GUVW5ahWxleD2MHujRFgKp2z5hpUGfRVQWpF5jwYXbT5HfRKD(eR)O3zCMISujRFgKp2z53GlL7YDQKnUhxd6QcGtye4Rfs5gVvqm1B6L6nxvWcIP2(f0Z27f8yEuWhGePajfuIcM9E4PGtpaoHrfKqlKc6rJVckjAMLcUFbVqkOkFzVzB5ovYg3JRbDvbWjmc81crN(EmOAyW1gtNTzabCClqZS9zsAa49pijuO6PtkBCyX(bq3CVH9wCYhuIO)GKI9JdlwFvXnawXIy)m6Zoy0aBbsaoMmFGaoUfOz2(mjna8(hKeku90jLnUPk34TcQ3)5ckA7xW4kOkI(i8CfCBfCLjFbfnUGX1XPGXHxd8STG4LwbXjakOw6NlyEHOXOcghEnWZf0ZkAfmlypUzgvqve9r450PGVKkYlOOLsb9SIwbXebWVwif0JgFfu04fvqve9r45(cQIR1xLOtb)OGEYvkiWjBVGRm5lyCfufrFeEUckrbbEUGI2(6uWq0yKN95cQIt2dGlOefe45cgxbvr0hHNZwUtLSX94AqxGNbxHD05sh2WaX5OTig0p)p3l34TcIxAfu8efmo8AGN)cMiUGioh4uW8gfufoKyzV5c2cubZcIjcGFTqk4JZP0PG5)aoCbfnUG94MzubvJcQLFbZc(ckUzgvqU1yLuW8gfKeIBmQGIwkfe468)fCLjFbZoIZbofmUcQIOpcpNofmeng5zFUGapxqrJlyCCbfTuM8fmATcQIOpcpNTG4LwbZckO9iNLcUFbrCoWPG5nkyEHOXOc(ckUzgvqFZ)bC4rbBOWPG94Mzubvr0hHNBQcghEnWZf0Z27fm7FuqtUGioh4uqtCkOOXfuwhUGyIa4xlKcQch(lOzQiVGrRvqve9r450PGIgFfe45cUsbf0EKZsb3wbfnUGVwI4rbDXyf8zvCJcQgfCLckODEMrFb9e3ePG7jmQXiUGEwrRGIgxqasQWzV5cIjcGFTqk4JZPMmkyC41apBliEPvWSGcApYzPGQaOpkOjxqGNhfmVrbFz79cQchUGMPI8cgTwbvr0hHNRGTavWSGnabaXfetea)AHOtbxzYxWpBCbLOGapRtbjH4gJq7nxqrJlypUz(LcQIOpcpxb3wbfprbtexqeNdCSfeV0kOOXfSTZAsb3VGZXEZfuIcY3OGMClqCbXjaqf8ymifetea)AHOtb9PbEPGVKiPGa)EZfuq7rolFbLOGoj5CbFaexqrJXPGZSuqGNh2YDQKnUhxd6c8m4kSZRZ2myc0AwbbWVwiwasyXAc0AwbbWVwi2r45itfrFeEoRGa4xlelIDY9E84IXWITTZAciIDY9E9vr0hHNZkia(1cXIyNCVVCNkzJ7X1GUQS3btLSXb23x05sh2GA8L7ujBCpUg0vL9oyQKnoW((Iox6WgErNTzivY6Nb5JDw(131L7ujBCpUg0vL9oyQKnoW((Iox6Wge0Qi)1c51zBgsLS(zq(yNLF84s5UCNkzJ7TQXBWKrpJiFVzD2MbtGwZkia(1cXcqcl22oRjGi2j3713RRl3Ps24ERA84AqxZEedWgachD2MbtGwZkia(1cXcqcl22oRjGi2j3713RXvUtLSX9w14X1GU5P4xqzhuL9UoBZGjqRzfea)AHybiHfBBN1eqe7K796714k3Ps24ERA84Aq32IyZEedD2MbtGwZkia(1cXcqcl22oRjGi2j3713NuUtLSX9w14X1GU9DwtEqFAGXSdFIoBZGjqRzfea)AHyhHNRCNkzJ7TQXJRbDnZzWObkOvr(RZ2myc0AwbbWVwi2r45k3Ps24ERA84AqxsHSXPZ2myc0AwbbWVwiwasKzc0AwZEeJoWlwasyXAc0AwbbWVwiwasKjjAMfRgNDrZssj67IXWITTZAciIDY9E9DX4k3L7ujBCV9fdVW5ahWxleD2Mbj78j2x4CGdyluapz(scX(bNvdRx7lCoWb81cHmtGwZ(cNdCaBHc4Ti2j371xpyXAc0A2x4CGdyluaVDeEUPk3Ps24E7l4AqxY3Eh81cPCNkzJ7TVGRbDhbGzNbLKKoBZGk8ZxEILCCqBEKPIOpcpNfXFCPS3myIqHhlIDY9E9NvdSy9Hk8ZxEILCCqBEK5dv4NV8e7TZAcylzSyvHF(YtS3oRjGTKjZxve9r45SE2(a8jTOvElIDY9E9NvdSyvr0hHNZkia(1cXIyNCVhp6rptHfRKOzwSY6WGsaowwFV6PCNkzJ7TVGRbDB9eX603JbvddUOhD2MbjrGckjzbirgc44wGMz7ha9wGMzq2XKrF5ovYg3BFbxd6kjcuqjjD2MbeWXTanZ2pa6TanZGSJjJEYKebkOKKfXo5EV(ZQbzQi6JWZzB9eXwe7K796pRgL7ujBCV9fCnOlJbs94x)m4Rfs5ovYg3BFbxd66z7dWN0Iw5l3Ps24E7l4Aq3wpXHhGVwiL7ujBCV9fCnO7GtrduPLKJshD2MHwOaECv5lGiEMp9BHc4Tojgk3Ps24E7l4Aq3e0banyey0avOWZxUtLSX92xW1GUi(JlL9Mbtek8uUtLSX92xW1GU(JENXrNTzWeO1SKqSAFg81c5TJWZHfRpKSZNyvARtYOe81cbl2ujRFgKp2z5xFxk3Ps24E7l4AqxbbWVwi6SndMaTMLeIv7ZGVwiVDeEoSynbAnlI)4szVzWeHcpwasyXAc0AwpBFa(Kw0kVfGewSMaTM1F07mowasKLkz9ZG8Xol)4XB5gVvqm1B6L6nxvq8k2)YEkyQKno7Zis8jGVS3SDpWwFN1eqjaLenZs5ovYg3BFbxd6MRdpaFTq0rHJQZGsIMz5n4vNTzWeO1SKqSAFg81c5TJWZHfRVMaTMvqa8RfIfGewSnGEheXkTenZGY6W6pRg4QYxaL1HNImF9HKD(eRsBDsgLGVwiyXMkz9ZG8Xol)67YuyXAc0AwbTkYbFTqElIDY9E8WyGvacdkRdtwQK1pdYh7S8JhVL7ujBCV9fCnOlkjTdW2IyD2MHwOaECv5lGiEMp9BHc4TojgiZxtGwZkia(1cXocphwS(abCClqZSLZ5olzpUhuqamylua)uK5RjqRzhbGzNbLKKDeEoSyLSZNyFbXPtFpEQYDQKnU3(cUg0vPTojJsWxleD2MbtGwZscXQ9zWxlK3cqcl2wOaE8OIxWnvYgNnxhEa(AHyvXlL7ujBCV9fCnOBIu5XGVwi6SndMaTMLeIv7ZGVwiVfGewSTqb84rfVGBQKnoBUo8a81cXQIxk3Ps24E7l4Aq3NrK4taFzVzDu4O6mOKOzwEdE1zBgqCdXVwA2zYKenZIvwhgucWXY4zaGszJRCNkzJ7TVGRbDntekNzD2MHujRFgKp2z5hpEl3Ps24E7l4AqxusAhGTfX6SndTqb84QYxar8mF63cfWBDsmqMVMaTMDeaMDguss2r45WIvYoFI9feNo994Pk3Ps24E7l4Aq3x4CGd4Rfs5UCNkzJ7TcAvK)AH8gEHZboGVwi6Snds25tSVW5ahWwOaEY2dS13znHmtGwZ(cNdCaBHc4Ti2j371xpL7ujBCVvqRI8xlKhxd6ocaZodkjjD2Mbv4NV8el54G28itfrFeEolI)4szVzWeHcpwe7K796pRgyX6dv4NV8el54G28iZhQWpF5j2BN1eWwYyXQc)8LNyVDwtaBjtMVQi6JWZz9S9b4tArR8we7K796pRgyXQIOpcpNvqa8RfIfXo5EpE0JEMclwjrZSyL1HbLaCSS(Enw5ovYg3Bf0Qi)1c5X1GUsIafussNTzabCClqZS9dGElqZmi7yYONmjrGckjzrStU3R)SAqMkI(i8C2wprSfXo5EV(ZQr5ovYg3Bf0Qi)1c5X1GUTEIyD67XGQHbx0JoBZGKiqbLKSaKidbCClqZS9dGElqZmi7yYOVCNkzJ7TcAvK)AH84AqxgdK6XV(zWxlKYDQKnU3kOvr(RfYJRbD9S9b4tArR8L7ujBCVvqRI8xlKhxd6I4pUu2BgmrOWt5ovYg3Bf0Qi)1c5X1GU(JENXPCNkzJ7TcAvK)AH84AqxZeHYzUCNkzJ7TcAvK)AH84AqxbbWVwiL7ujBCVvqRI8xlKhxd6Iss7aSTiwNTzWeO1ScAvKd(AH8we7K794XaJbwbimOSomziGJBbAMTpaAEVzWxlKNmtGwZocaZodkjj7i8CL7ujBCVvqRI8xlKhxd6MRdpaFTq0rHJQZGsIMz5n4vNTzWeO1ScAvKd(AH8we7K794XaJbwbimOSomz(Ac0AwsiwTpd(AH82r45WITb07GiwPLOzguwhwFv(cOSomUZQbwSMaTMvqa8RfIfG0uL7ujBCVvqRI8xlKhxd6o4u0avAj5O0rNTzOfkGhxv(ciIN5t)wOaERtIHYDQKnU3kOvr(RfYJRbDrjPDa2weRZ2myc0AwbTkYbFTqElIDY9E8yGXaRaeguwhUCNkzJ7TcAvK)AH84AqxhGUSVwi6SndMaTMvqRICWxlK3ocphwSMaTMLeIv7ZGVwiVfGezTqb84rfVGBQKnoBUo8a81cXQIxiZxFizNpXQ0wNKrj4RfcwSPsw)miFSZYpEC9uL7ujBCVvqRI8xlKhxd6Q0wNKrj4RfIoBZGjqRzjHy1(m4RfYBbirwluapEuXl4MkzJZMRdpaFTqSQ4fYsLS(zq(yNLF9n(YDQKnU3kOvr(RfYJRbDjF7DWxleD2MbtGwZo4CaY4W2r45k3Ps24ERGwf5VwipUg0nbDaqdgbgnqfk88L7ujBCVvqRI8xlKhxd626jo8a81cPCNkzJ7TcAvK)AH84Aq3NrK4taFzVzDu4O6mOKOzwEdE1zBgqCdXVwA25YDQKnU3kOvr(RfYJRbDDa6Y(AHOZ2m0cfWJhv8cUPs24S56WdWxleRkEPCNkzJ7TcAvK)AH84Aq3x4CGd4RfcvOcLca]] )

end