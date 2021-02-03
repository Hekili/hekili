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
            aura = "death_chakram",

            last = function ()
                return state.buff.death_chakram.applied + floor( state.query_time - state.buff.death_chakram.applied )
            end,

            interval = function () return class.auras.death_chakram.tick_time end,
            value = function () return state.conduit.necrotic_barrage.enabled and 5 or 3 end,
        },
        rapid_fire = {
            channel = "rapid_fire",

            last = function ()
                local app = state.buff.casting.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.rapid_fire.tick_time ) * class.auras.rapid_fire.tick_time
            end,

            interval = function () return class.auras.rapid_fire.tick_time * ( state.buff.trueshot.up and 0.667 or 1 ) end,
            value = 1,
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
            tick_time = function ()
                return ( 2 * haste ) / ( buff.double_tap.up and 14 or 7 )
            end,
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

            cycle = function () return runeforge.serpentstalkers_trickery.enabled and "serpent_sting" or nil end,

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

            startsCombat = false,
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

            spend = 0,
            spendType = "focus",

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

            spend = function () return buff.trueshot.up and -15 or -10 end,
            spendType = "focus",

            startsCombat = true,
            texture = 132213,

            handler = function ()
                if talent.steady_focus.enabled and prev[1].steady_shot and action.steady_shot.lastCast > last_steady_focus then
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
            gcd = "off",

            spend = 0,
            spendType = "focus",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 132329,

            nobuff = function ()
                if settings.trueshot_vop_overlap then return end
                return "trueshot"
            end,

            handler = function ()
                focus.regen = focus.regen * 1.5
                reduceCooldown( "aimed_shot", ( 1 - 0.3077 ) * 12 * haste )
                reduceCooldown( "rapid_fire", ( 1 - 0.3077 ) * 20 * haste )
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


    spec:RegisterPack( "Marksmanship", 20210202, [[dSuVjbqivf8iOuLnbf(KuQrjs6uIuEfb1SOeUfjO2fr)IsLHrPkhtkzzqjpJeKPjsfxJeyBQkuFJsvLXPQqCoOuH1jsvZJs09OK2NQIoiLQswOiXdvvLMiuQQ6IuQkAJqPQYhPuvyKqPQ4KIuPvQQ0mvvf3uvHu7Ke6NuQQAPqPIEkHMkb5QqPQ0xPuvQXQQQ2lf)fQgSIdRYIfXJj1Kf1Lr2meFgsnAs60kTAvfsEnLYSLQBlf7wYVPA4KOJdLkz5aph00rDDvz7QQ8DcmEOuopu06HsLA(qY(f20YiKrmFmzuel7Hvl7HL9Ws26JOafQ1hXiYyQKmIkpTTdnzeRRHmIF0hWgS5kO6Q0iQ8WS7x2iKre6pGMmIyVyuzwjm92zh6LvFjsT3yhCBE9JxV0GdHTdUnA7mIjVTZPBzsmI5JjJIyzpSAzpSShwYwFef0YiEpw1bgrXT5Vgr1nNPYKyeZeuBeXEyVy(OpGnyZvq1vzmyFEftG4l2d7fd2pkb8oaMXGLfXGL9WQLrSVqgAeYiYGvBdQ6m0iKrXwgHmIuDjDkBsXiQbltG9mI81PILqMUmM4iU(bLuDjDkhdgXSfosFrRYXGrmjpeejKPlJjoIRFqjGAUTGXyzmkWiEAE9Yicz6YyIdvD2WgfXYiKrKQlPtztkgrnyzcSNru7)O6kwAdtWEvmyeJ29E2fusab964TqJFaGlqcOMBlymwgdADoguOI5dXO9FuDflTHjyVkgmI5dXO9FuDflRfTkJJCumOqfJ2)r1vSSw0QmoYrXGrmPgJ29E2fusbBpJdvUGLHsa1CBbJXYyqRZXGcvmA37zxqjzWJGQolbuZTfmMpJrbkiM0IbfQy4dGMyjVneo745LIXYyAzpJ4P51lJy2FjDcNpLg2OOczeYis1L0PSjfJOgSmb2ZicEfH4a0Ke6VoIdqt4utcbGsQUKoLJbJy4dGZGtPeqn3wWySmg06CmyeJ29E2fusK(bijGAUTGXyzmO1zJ4P51lJiFaCgCknSrX0XiKrKQlPtztkgrnyzcSNrKpaodoLYNYyWigWRiehGMKq)1rCaAcNAsiaus1L0PSr8086LrePFaYi23IW1zJiwkWWgfvGriJ4P51lJiHnLDhU)iCOQZgrQUKoLnPyyJIFSriJ4P51lJOGTNXHkxWYqJivxsNYMumSrr7NriJ4P51lJiGGED8wOXpaWfyeP6s6u2KIHnk(rmczepnVEze)59oHPrKQlPtztkg2Oi2HriJ4P51lJyYbahAYis1L0PSjfdBuSL9mczepnVEzezWJGQoBeP6s6u2KIHnk2QLriJivxsNYMumIAWYeypJyYdbrYGvBdhQ6mucOMBlymFAngcBK(XeoVnumyed4veIdqts4dGEl04qvNHsQUKoLJbJysEiiYS)s6eoFkLzxqzepnVEzebNYnJJSaYWgfBHLriJivxsNYMumIAWYeypJyYdbrYGvBdhQ6mucOMBlymFAngcBK(XeoVnumyetQXK8qqKkbKEHeou1zOm7cQyqHkgKxVJdiT6bqt482qXyzm6dY482qXiCmO15yqHkMKhcIKbpcQ6S8PmM0mINMxVmI32qzCOQZgrnM6oHZhanXqJITmSrXwkKriJivxsNYMumIAWYeypJiIRFWyeog9bzCaHMQySmgex)GYMdBgXtZRxgXmDSkUw9SbUgdBuSv6yeYis1L0PSjfJOgSmb2ZiM8qqKmy12WHQodLaQ52cgZNwJHWgPFmHZBdzepnVEzebNYnJJSaYWgfBPaJqgrQUKoLnPye1GLjWEgXKhcIKbR2gou1zOm7cQyqHkMKhcIujG0lKWHQodLpLXGrmiU(bJ5Zy0oKJr4yonVEjVTHY4qvNLAhYXGrmPgZhIHVovSuRUnhboCOQZsQUKoLJbfQyonV)iCQOMLGX8zmkumPzepnVEzeBEDEHQoByJIT(yJqgrQUKoLnPye1GLjWEgXKhcIujG0lKWHQodLpLXGrmiU(bJ5Zy0oKJr4yonVEjVTHY4qvNLAhYXGrmNM3FeovuZsWySmM0XiEAE9YiQv3MJahou1zdBuSL9ZiKrKQlPtztkgrnyzcSNrm5HGiZ0LXjmjz2fugXtZRxgrBBVJdvD2WgfB9rmczepnVEzep8MhitaChbxdCbqJivxsNYMumSrXwyhgHmINMxVmIi9dtkJdvD2is1L0PSjfdBuel7zeYis1L0PSjfJOgSmb2ZicieabvVKozepnVEzeHeqjvmoK3cTruJPUt48bqtm0OyldBueRwgHmIuDjDkBsXiQbltG9mIiU(bJ5Zy0oKJr4yonVEjVTHY4qvNLAhYgXtZRxgXMxNxOQZg2OiwyzeYiEAE9Yicz6YyIdvD2is1L0PSjfdByJyMqUxNnczuSLriJ4P51lJO2FftaCOQZgrQUKoLnPyyJIyzeYis1L0PSjfJOgSmb2ZicEfH4a0KeskvFy3qCLax3VMJxVKuDjDkhdkuXa9xpzRSSwmpio7EhIR0xOxsQUKoLJbfQysngTx53Ysa9JaWRJ7i4ioGFfjP6s6uogmI5dXaEfH4a0KeskvFy3qCLax3VMJxVKuDjDkhtAgXtZRxgrT)kMa4qvNnI9TiCD2iQq2ZWgfviJqgXtZRxgrgCf21B7l29wOXHQoBeP6s6u2KIHnkMogHmIuDjDkBsXiwxdzeZa6YilGW)rqi1nINMxVmIzaDzKfq4)iiK6gXmb1GvjVEzeX(cPyy1fgJxXODVNDbvmlsml3ggdRsX4vhZy8sHFqsgt6IedM(lg17hfZvoRsGy8sHFqkgblRgZft3l0eigT79SlOSigiFABXWQhhJGLvJriWJGQohJavQIHvPfeJ29E2fuWy0EH0xnBrmqpgb3YX8kE7XSCBymEfJ29E2fuXWEmpifdRUqlIXzvciyHumAV4TEumShZdsX4vmA37zxqjnSrrfyeYis1L0PSjfJOgSmb2ZiM8qqKm4rqvNLpLXGrmPgdd2YgXsULu7Ep7ckz(boE9kMpTgdd2YgXsglP29E2fuY8dC86vmOqfdd2YgXsglP29E2fusa1CBbJjTyqHkMKhcIKbpcQ6Sm7cQyWigT79SlOKm4rqvNLaQ52cgZNXGL9IbJyyWw2iwYyj1U3ZUGsMFGJxVI5tRXWGTSrSKBj1U3ZUGsMFGJxVIbJyyWw2iwYyj1U3ZUGscOMBlymkCmkiglJr7Ep7ckjdEeu1zjGAUTGXGrmFiggSLnILmwYfkZa6YilGW)rqi1JbfQysnggSLnILClP29E2fuY8dC86vmkCmkiglJr7Ep7ckjdEeu1zjGAUTGXGrmPgdd2YgXsULu7Ep7ckz(boE9kMpTgdd2YgXsglP29E2fuY8dC86vmOqfdd2YgXsglP29E2fusa1CBbJjTyslguOIHpaAIL82q4SJNxkglJr7Ep7ckjdEeu1zjGAUTGgXtZRxgrgSLnIBzeZeudwL86LrmDrIHf4X4Lc)GemMdqXaOlJzmxLJr7nkjEl0XG4GyUyec8iOQZXaXS0weZbHVgkgwLIP7fAceJohJ6bJ5IbYaVqtGyieesZXCvogLacHaXWQhhZR6eegZYTHXCDaDzmJXRy0U3ZUGYIyCwLacwifZdsXWQumErXWQh3ggJJGeJ29E2fuYysxKyUyyWw2ioMfgdGUmMXCvoMRCwLaXazGxOjqmPEq4RHYXGa8My6EHMaXODVNDbvAX4Lc)Gumc2EpMRd9ysOya0LXmMemJHvPy4THIriWJGQohJ2BiymjN2wmocsmA37zxqzrmSkvX8GumlhZIedRsXavpaLJbl7fdK0ELJrNJz5yyWIgnbGXiWR2CmBXeaHaumcwwngwLI5Pu7nBHogHapcQ6CmqmlD7CmEPWpijJjDrI5IHbBzJ4y0(RNJjHI5bPCmxLJbYBVhJ2BOysoTTyCeKy0U3ZUGkgeheZfdYJFakgHapcQ6SfXSCBymWdHIH9yEqYIyucieca2cDmSkft3l0eKJr7Ep7cQywKyybEmhGIbqxgtzmPlsmSkfdYIwLJzHXG23cDmShdv5ysiehqXGP)aXue24yec8iOQZweZh1dYXa5dWX8GBHoggSLnIHXWEmnNnkg4dqXWQeMXGM4yEqklnSrXp2iKrKQlPtztkgrnyzcSNrm5HGizWJGQolFkJbJysnggSLnILmwsT79SlOK5h441Ry(0AmmylBel5wsT79SlOK5h441RyqHkggSLnILClP29E2fusa1CBbJjTyqHkMKhcIKbpcQ6Sm7cQyWigT79SlOKm4rqvNLaQ52cgZNXGL9IbJyyWw2iwYTKA37zxqjZpWXRxX8P1yyWw2iwYyj1U3ZUGsMFGJxVIbJyyWw2iwYTKA37zxqjbuZTfmgfogfeJLXODVNDbLKbpcQ6Seqn3wWyWiMpedd2YgXsULCHYmGUmYci8Fees9yqHkMuJHbBzJyjJLu7Ep7ckz(boE9kgfogfeJLXODVNDbLKbpcQ6Seqn3wWyWiMuJHbBzJyjJLu7Ep7ckz(boE9kMpTgdd2YgXsULu7Ep7ckz(boE9kguOIHbBzJyj3sQDVNDbLeqn3wWyslM0IbfQy4dGMyjVneo745LIXYy0U3ZUGsYGhbvDwcOMBlOr8086LrKbBzJySmSrr7NriJivxsNYMumIAWYeypJyYdbrYGhbvDw(ugdkuXK8qqKm4rqvNLzxqfdgXODVNDbLKbpcQ6Seqn3wWy(mgSSxmOqfdYIwLXbuZTfmglJr7Ep7ckjdEeu1zjGAUTGgXtZRxgXhKWxMAGg2O4hXiKrKQlPtztkgXtZRxgr9174NMxVW7lKnI9fY411qgrDgAyJIyhgHmIuDjDkBsXiEAE9YiQVEh)086fEFHSrudwMa7zepnV)iCQOMLGXyzmkKrSVqgVUgYiczdBuSL9mczeP6s6u2KIr8086LruF9o(P51l8(czJOgSmb2ZiEAE)r4urnlbJ5ZyWYi2xiJxxdzezWQTbvDgAydBevciT3KCSriJITmczepnVEzetCM7ughPFyszbBHgNDSTLrKQlPtztkg2OiwgHmIuDjDkBsXiQbltG9mIGxrioanjH(RJ4a0eo1KqaOKQlPtzJ4P51lJiFaCgCknSrrfYiKrKQlPtztkgrLasFqgN3gYi2YEgXtZRxgXS)s6eoFknIAWYeypJ4P59hHtf1SemMpJPvmOqfZhIr7)O6kwAdtWEvmyeZhIHVovS8N37eMsQUKoLnSrX0XiKrKQlPtztkgrnyzcSNr808(JWPIAwcgJLXOqXGrmPgZhIr7)O6kwAdtWEvmyeZhIHVovS8N37eMsQUKoLJbfQyonV)iCQOMLGXyzmyftAgXtZRxgXBBOmou1zdBuubgHmIuDjDkBsXiQbltG9mINM3FeovuZsWy(mgSIbfQysngT)JQRyPnmb7vXGcvm81PIL)8ENWus1L0PCmPfdgXCAE)r4urnlbJXAmyzepnVEzeHmDzmXHQoBydBe1zOriJITmczeP6s6u2KIrudwMa7zetEiisg8iOQZYNYyqHkgKfTkJdOMBlymwgtlfYiEAE9YiMqaibSTfAdBuelJqgrQUKoLnPye1GLjWEgXKhcIKbpcQ6S8PmguOIbzrRY4aQ52cgJLX06JnINMxVmIjD3Z4ipaMg2OOczeYis1L0PSjfJOgSmb2ZiM8qqKm4rqvNLpLXGcvmilAvghqn3wWySmMwFSr8086Lr8knbzW1X1xVByJIPJriJivxsNYMumIAWYeypJyYdbrYGhbvDw(ugdkuXGSOvzCa1CBbJXYyWomINMxVmIilGs6UNnSrrfyeYis1L0PSjfJOgSmb2ZiM8qqKm4rqvNLzxqzepnVEze7lAvgI)r9YOBOInSrXp2iKrKQlPtztkgrnyzcSNrm5HGizWJGQolZUGYiEAE9YiMCOXDeCgSABqdBu0(zeYis1L0PSjfJOgSmb2ZiM8qqKm4rqvNLpLXGrmjpeezs39C)bz5tzmOqftYdbrYGhbvDw(ugdgXWhanXsv66SQuPMJXYyWYEXGcvmilAvghqn3wWySmgS(yJ4P51lJOsNxVmSHnIq2iKrXwgHmIuDjDkBsXiQbltG9mI81PILqMUmM4iU(bLuDjDkhdgXKAmkb0pC06SSLeY0LXehQ6CmyetYdbrcz6YyIJ46hucOMBlymwgJcIbfQysEiisitxgtCex)GYSlOIjnJ4P51lJiKPlJjou1zdBuelJqgXtZRxgrBBVJdvD2is1L0PSjfdBuuHmczeP6s6u2KIrudwMa7ze1(pQUIL2WeSxfdgXODVNDbLeqqVoEl04ha4cKaQ52cgJLXGwNJbfQy(qmA)hvxXsByc2RIbJy(qmA)hvxXYArRY4ihfdkuXO9FuDflRfTkJJCumyetQXODVNDbLuW2Z4qLlyzOeqn3wWySmg06CmOqfJ29E2fusg8iOQZsa1CBbJ5ZyuGcIjTyqHkg(aOjwYBdHZoEEPySmMwkWiEAE9YiM9xsNW5tPHnkMogHmIuDjDkBsXiQbltG9mI8bWzWPu(ugdgXaEfH4a0Ke6VoIdqt4utcbGsQUKoLnINMxVmIi9dqgX(weUoBeXsbg2OOcmczeP6s6u2KIrudwMa7zebVIqCaAsc9xhXbOjCQjHaqjvxsNYXGrm8bWzWPucOMBlymwgdADogmIr7Ep7ckjs)aKeqn3wWySmg06Sr8086LrKpaodoLg2O4hBeYiEAE9Yisytz3H7pchQ6SrKQlPtztkg2OO9ZiKr8086LruW2Z4qLlyzOrKQlPtztkg2O4hXiKr8086LrePFyszCOQZgrQUKoLnPyyJIyhgHmIuDjDkBsXiQbltG9mIiU(bJr4y0hKXbeAQIXYyqC9dkBoSzepnVEzeZ0XQ4A1Zg4AmSrXw2ZiKr8086Lr8WBEGmbWDeCnWfanIuDjDkBsXWgfB1YiKr8086LreqqVoEl04ha4cmIuDjDkBsXWgfBHLriJivxsNYMumIAWYeypJyYdbrQeq6fs4qvNHYSlOIbfQy(qm81PILA1T5iWHdvDws1L0PCmOqfZP59hHtf1SemglJblJ4P51lJ4pV3jmnSrXwkKriJivxsNYMumIAWYeypJyYdbrQeq6fs4qvNHYSlOIbfQysEiisab964TqJFaGlq(ugdkuXK8qqKc2EghQCbldLpLXGcvmjpee5pV3jmLpLXGrmNM3FeovuZsWy(mMwgXtZRxgrg8iOQZg2OyR0XiKrKQlPtztkgXtZRxgXBBOmou1zJOgtDNW5dGMyOrXwgXmb1GvjVEzefY(J93(N(yWoPFljiMtZRxsibusfJd5Tql3chPVOvzC2X5dGMyJOgSmb2ZiM8qqKkbKEHeou1zOm7cQyqHkMuJj5HGizWJGQolFkJbfQyqE9ooG0QhanHZBdfJLXGwNJr4y0hKX5THIjTyWiMuJ5dXWxNkwQv3MJahou1zjvxsNYXGcvmNM3FeovuZsWySmgSIjTyqHkMKhcIKbR2gou1zOeqn3wWy(mgcBK(XeoVnumyeZP59hHtf1SemMpJPLHnk2sbgHmIuDjDkBsXiQbltG9mIiU(bJr4y0hKXbeAQIXYyqC9dkBoSfdgXKAmjpeejdEeu1zz2fuXGcvmFigWRiehGMK0HUt819cIZGhHJ46hus1L0PCmPfdgXKAmjpeez2FjDcNpLYSlOIbfQy4RtflHmGUM(wKKQlPt5ysZiEAE9YicoLBghzbKHnk26JnczeP6s6u2KIrudwMa7zetEiisLasVqchQ6mu(ugdkuXG46hmMpJr7qogHJ5086L82gkJdvDwQDiBepnVEze1QBZrGdhQ6SHnk2Y(zeYis1L0PSjfJOgSmb2ZiM8qqKkbKEHeou1zO8PmguOIbX1pymFgJ2HCmchZP51l5TnughQ6Su7q2iEAE9YiEa9veou1zdBuS1hXiKrKQlPtztkgrnyzcSNreqiacQEjDkgmIHpaAIL82q4SJNxkMpJj)ahVEzepnVEzeHeqjvmoK3cTruJPUt48bqtm0OyldBuSf2HriJivxsNYMumIAWYeypJ4P59hHtf1SemMpJPLr8086Lrm5aGdnzyJIyzpJqgrQUKoLnPye1GLjWEgrex)GXiCm6dY4acnvXyzmiU(bLnh2IbJysnMKhcIm7VKoHZNsz2fuXGcvm81PILqgqxtFlss1L0PCmPzepnVEzebNYnJJSaYWgfXQLriJ4P51lJiKPlJjou1zJivxsNYMumSHnSr8hbGRxgfXYEyzVwyHL9mIcoqTfAOr0(2(c7uX0vr7J0htmcPsXSnkDahdIdIPndwTnOQZW2XaiSR3cOCmqVHI5ES3CmLJrREfAckJV)zlkMwPpM)61pcWuoM281PIL)3og2JPnFDQy5)sQUKoLBhtQTWwAY47F2IIrHsFm)1RFeGPCmTbVIqCaAs(F7yypM2Gxrioanj)xs1L0PC7ysTf2stgF)ZwumPt6J5VE9JamLJPn4veIdqtY)Bhd7X0g8kcXbOj5)sQUKoLBhZXXyFA))tmP2cBPjJV)zlkMwTsFm)1RFeGPCmTbVIqCaAs(F7yypM2Gxrioanj)xs1L0PC7ysTf2stgF)ZwumTuq6J5VE9JamLJPnFDQy5)TJH9yAZxNkw(VKQlPt52XKAlSLMm(gFTVTVWovmDv0(i9XeJqQumBJshWXG4GyANjK7152XaiSR3cOCmqVHI5ES3CmLJrREfAckJV)zlkgSsFm)1RFeGPCmTbVIqCaAs(F7yypM2Gxrioanj)xs1L0PC7ysTf2stgF)ZwumyL(y(Rx)iat5yAdEfH4a0K8)2XWEmTbVIqCaAs(VKQlPt52XKAlSLMm((NTOyWk9X8xV(raMYX0w7v(TS8)2XWEmT1ELFll)xs1L0PC7ysTf2stgF)ZwumyL(y(Rx)iat5yAd9xpzRS8)2XWEmTH(RNSvw(VKQlPt52XKAlSLMm((NTOyuq6J5VE9JamLJPnd2YgXYwY)Bhd7X0MbBzJyj3s(F7ysnDWwAY47F2IIrbPpM)61pcWuoM2mylBelXs(F7yypM2mylBelzSK)3oMuTFylnz89pBrX8XPpM)61pcWuoM2mylBelBj)VDmShtBgSLnILCl5)TJjv7h2stgF)ZwumFC6J5VE9JamLJPnd2YgXsSK)3og2JPnd2YgXsgl5)TJj10bBPjJVXx7B7lStftxfTpsFmXiKkfZ2O0bCmioiM2kbK2BsoUDmac76Takhd0BOyUh7nht5y0QxHMGY47F2IIbR0hZF96hbykhtBWRiehGMK)3og2JPn4veIdqtY)LuDjDk3oMJJX(0()NysTf2stgF)Zwumku6J5VE9JamLJPnFDQy5)TJH9yAZxNkw(VKQlPt52XCCm2N2))etQTWwAY47F2IIjDsFm)1RFeGPCmT5Rtfl)VDmShtB(6uXY)LuDjDk3oMuBHT0KX3)SffJcsFm)1RFeGPCmT5Rtfl)VDmShtB(6uXY)LuDjDk3oMuBHT0KX34R9T9f2PIPRI2hPpMyesLIzBu6aogehetBi3ogaHD9waLJb6num3J9MJPCmA1Rqtqz89pBrX0k9X8xV(raMYX0MVovS8)2XWEmT5Rtfl)xs1L0PC7ysTf2stgF)ZwumPt6J5VE9JamLJPn4veIdqtY)Bhd7X0g8kcXbOj5)sQUKoLBhZXXyFA))tmP2cBPjJV)zlkgfK(y(Rx)iat5yAdEfH4a0K8)2XWEmTbVIqCaAs(VKQlPt52XKAlSLMm((NTOyAHv6J5VE9JamLJPnFDQy5)TJH9yAZxNkw(VKQlPt52XKAlSLMm((NTOyALoPpM)61pcWuoM281PIL)3og2JPnFDQy5)sQUKoLBhtQTWwAY47F2IIPLcsFm)1RFeGPCmT5Rtfl)VDmShtB(6uXY)LuDjDk3oMuBHT0KX3)SfftlfK(y(Rx)iat5yAdEfH4a0K8)2XWEmTbVIqCaAs(VKQlPt52XKAlSLMm((NTOyWYEPpM)61pcWuoM281PIL)3og2JPnFDQy5)sQUKoLBhtQTWwAY4B8nDBu6aMYXOGyonVEftFHmugFnIqLK2OiwkiDmIkboY2jJi2d7fZh9bSbBUcQUkJb7ZRyceFXEyVyW(rjG3bWmgSSigSShwTIVX3tZRxqPsaP9MKJf2QDjoZDkJJ0pmPSGTqJZo22k(EAE9ckvciT3KCSWwTJpaodoLwSiwbVIqCaAsc9xhXbOjCQjHaW47P51lOujG0EtYXcB1US)s6eoFkTqjG0hKX5THS2YEwSiwpnV)iCQOMLGF2cfQpO9FuDflTHjyVcJpWxNkw(Z7DcZ47P51lOujG0EtYXcB1UBBOmou1zlweRNM3FeovuZsqlvims9dA)hvxXsByc2RW4d81PIL)8ENWefQtZ7pcNkQzjOLyLw89086fuQeqAVj5yHTAhKPlJjou1zlweRNM3FeovuZsWpXcfQu1(pQUIL2WeSxHcfFDQy5pV3jmtdJtZ7pcNkQzjOvSIVX3tZRxqHTAN2FftaCOQZX3tZRxqHTAN2FftaCOQZw03IW1zRkK9SyrScEfH4a0KeskvFy3qCLax3VMJxVqHc6VEYwzzTyEqC29oexPVqVqHkvTx53Ysa9JaWRJ7i4ioGFfHXhaVIqCaAscjLQpSBiUsGR7xZXRxPfFpnVEbf2QDm4kSR32xS7TqJdvDo(I9Ib7lKIHvxymEfJ29E2fuXSiXSCBymSkfJxDmJXlf(bjzmPlsmy6VyuVFumx5SkbIXlf(bPyeSSAmxmDVqtGy0U3ZUGYIyG8PTfdRECmcwwngHapcQ6CmcuPkgwLwqmA37zxqbJr7fsF1SfXa9yeClhZR4ThZYTHX4vmA37zxqfd7X8GumS6cTigNvjGGfsXO9I36rXWEmpifJxXODVNDbLm(EAE9ckSv7EqcFzQXI6AiRzaDzKfq4)iiK6XxSxmPlsmSapgVu4hKGXCakgaDzmJ5QCmAVrjXBHogeheZfJqGhbvDogiML2Iyoi81qXWQumDVqtGy05yupymxmqg4fAcedHGqAoMRYXOeqieigw94yEvNGWywUnmMRdOlJzmEfJ29E2fuweJZQeqWcPyEqkgwLIXlkgw942WyCeKy0U3ZUGsgt6IeZfdd2YgXXSWya0LXmMRYXCLZQeigid8cnbIj1dcFnuogeG3et3l0eigT79SlOslgVu4hKIrW27XCDOhtcfdGUmMXKGzmSkfdVnumcbEeu15y0EdbJj502IXrqIr7Ep7cklIHvPkMhKIz5ywKyyvkgO6bOCmyzVyGK2RCm6Cmlhddw0OjamgbE1MJzlMaieGIrWYQXWQumpLAVzl0Xie4rqvNJbIzPBNJXlf(bjzmPlsmxmmylBehJ2F9CmjumpiLJ5QCmqE79y0EdftYPTfJJGeJ29E2fuXG4GyUyqE8dqXie4rqvNTiMLBdJbEiumShZdsweJsaHqaWwOJHvPy6EHMGCmA37zxqfZIedlWJ5auma6YykJjDrIHvPyqw0QCmlmg0(wOJH9yOkhtcH4akgm9hiMIWghJqGhbvD2Iy(OEqogiFaoMhCl0XWGTSrmmg2JP5SrXaFakgwLWmg0ehZdszz89086fuyR2XGTSrCllweRjpeejdEeu1z5tjgPYGTSrSSLu7Ep7ckz(boE96tRmylBelXsQDVNDbLm)ahVEHcfd2YgXsSKA37zxqjbuZTfmnuOsEiisg8iOQZYSlOWq7Ep7ckjdEeu1zjGAUTGFIL9WGbBzJyjwsT79SlOK5h441RpTYGTSrSSLu7Ep7ckz(boE9cdgSLnILyj1U3ZUGscOMBlOcRal1U3ZUGsYGhbvDwcOMBligFGbBzJyjwYfkZa6YilGW)rqi1rHkvgSLnILTKA37zxqjZpWXRxkScSu7Ep7ckjdEeu1zjGAUTGyKkd2YgXYwsT79SlOK5h441RpTYGTSrSelP29E2fuY8dC86fkumylBelXsQDVNDbLeqn3wW0sdfk(aOjwYBdHZoEEjl1U3ZUGsYGhbvDwcOMBly89086fuyR2XGTSrmwwSiwtEiisg8iOQZYNsmsLbBzJyjwsT79SlOK5h441RpTYGTSrSSLu7Ep7ckz(boE9cfkgSLnILTKA37zxqjbuZTfmnuOsEiisg8iOQZYSlOWq7Ep7ckjdEeu1zjGAUTGFIL9WGbBzJyzlP29E2fuY8dC861NwzWw2iwILu7Ep7ckz(boE9cdgSLnILTKA37zxqjbuZTfuHvGLA37zxqjzWJGQolbuZTfeJpWGTSrSSLCHYmGUmYci8FeesDuOsLbBzJyjwsT79SlOK5h441lfwbwQDVNDbLKbpcQ6Seqn3wqmsLbBzJyjwsT79SlOK5h441RpTYGTSrSSLu7Ep7ckz(boE9cfkgSLnILTKA37zxqjbuZTfmT0qHIpaAIL82q4SJNxYsT79SlOKm4rqvNLaQ52cgFpnVEbf2QDpiHVm1aTyrSM8qqKm4rqvNLpLOqL8qqKm4rqvNLzxqHH29E2fusg8iOQZsa1CBb)el7HcfYIwLXbuZTf0sT79SlOKm4rqvNLaQ52cgFpnVEbf2QD6R3XpnVEH3xiBrDnKvDggFpnVEbf2QD6R3XpnVEH3xiBrDnKviBXIy908(JWPIAwcAPcfFpnVEbf2QD6R3XpnVEH3xiBrDnKvgSABqvNHwSiwpnV)iCQOMLGFIv8n(EAE9ck1zO1ecajGTTqBXIyn5HGizWJGQolFkrHczrRY4aQ52cAzlfk(EAE9ck1zOWwTlP7Egh5bW0IfXAYdbrYGhbvDw(uIcfYIwLXbuZTf0YwFC89086fuQZqHTA3vAcYGRJRVE3IfXAYdbrYGhbvDw(uIcfYIwLXbuZTf0YwFC89086fuQZqHTAhYcOKU7zlweRjpeejdEeu1z5tjkuilAvghqn3wqlXoIVNMxVGsDgkSv76lAvgI)r9YOBOITyrSM8qqKm4rqvNLzxqfFpnVEbL6muyR2LCOXDeCgSABqlweRjpeejdEeu1zz2fuX3tZRxqPodf2QDkDE9YIfXAYdbrYGhbvDw(uIrYdbrM0Dp3Fqw(uIcvYdbrYGhbvDw(uIbFa0elvPRZQsLA2sSShkuilAvghqn3wqlX6JJVX3tZRxqjKTcz6YyIdvD2IfXkFDQyjKPlJjoIRFqmsvjG(HJwNLTKqMUmM4qvNXi5HGiHmDzmXrC9dkbuZTf0sfGcvYdbrcz6YyIJ46huMDbvAX3tZRxqjKf2QD22EhhQ6C89086fuczHTAx2FjDcNpLwSiw1(pQUIL2WeSxHH29E2fusab964TqJFaGlqcOMBlOLO1zuO(G2)r1vS0gMG9km(G2)r1vSSw0QmoYrOqP9FuDflRfTkJJCegPQDVNDbLuW2Z4qLlyzOeqn3wqlrRZOqPDVNDbLKbpcQ6Seqn3wWpvGcsdfk(aOjwYBdHZoEEjlBPG47P51lOeYcB1oK(bil6Br46SvSuGflIv(a4m4ukFkXa8kcXbOjj0FDehGMWPMecaJVNMxVGsilSv74dGZGtPflIvWRiehGMKq)1rCaAcNAsiaed(a4m4ukbuZTf0s06mgA37zxqjr6hGKaQ52cAjADo(EAE9ckHSWwTJWMYUd3Feou1547P51lOeYcB1obBpJdvUGLHX3tZRxqjKf2QDi9dtkJdvDo(EAE9ckHSWwTlthRIRvpBGRXIfXkIRFqH1hKXbeAQSeX1pOS5Ww89086fuczHTA3H38azcG7i4AGlagFpnVEbLqwyR2biOxhVfA8daCbX3tZRxqjKf2QD)8ENW0IfXAYdbrQeq6fs4qvNHYSlOqH6d81PILA1T5iWHdvDgfQtZ7pcNkQzjOLyfFpnVEbLqwyR2XGhbvD2IfXAYdbrQeq6fs4qvNHYSlOqHk5HGibe0RJ3cn(baUa5tjkujpeePGTNXHkxWYq5tjkujpee5pV3jmLpLyCAE)r4urnlb)Sv8f7fJq2FS)2)0hd2j9BjbXCAE9scjGsQyCiVfA5w4i9fTkJZooFa0ehFpnVEbLqwyR2DBdLXHQoBHgtDNW5dGMyO1wwSiwtEiisLasVqchQ6muMDbfkuPM8qqKm4rqvNLpLOqH86DCaPvpaAcN3gYs06SW6dY482qPHrQFGVovSuRUnhboCOQZOqDAE)r4urnlbTeR0qHk5HGizWQTHdvDgkbuZTf8tcBK(XeoVnegNM3FeovuZsWpBfFpnVEbLqwyR2boLBghzbKflIvex)GcRpiJdi0uzjIRFqzZHnmsn5HGizWJGQolZUGcfQpaEfH4a0KKo0DIVUxqCg8iCex)GPHrQjpeez2FjDcNpLYSlOqHIVovSeYa6A6BrPfFpnVEbLqwyR2Pv3MJahou1zlweRjpeePsaPxiHdvDgkFkrHcX1p4NAhYcFAE9sEBdLXHQol1oKJVNMxVGsilSv7oG(kchQ6SflI1KhcIujG0lKWHQodLpLOqH46h8tTdzHpnVEjVTHY4qvNLAhYX3tZRxqjKf2QDqcOKkghYBH2cnM6oHZhanXqRTSyrScieabvVKoHbFa0el5THWzhpV0N5h441R47P51lOeYcB1UKdao0KflI1tZ7pcNkQzj4NTIVNMxVGsilSv7aNYnJJSaYIfXkIRFqH1hKXbeAQSeX1pOS5WggPM8qqKz)L0jC(ukZUGcfk(6uXsidORPVfLw89086fuczHTAhKPlJjou154B89086fuYGvBdQ6m0kKPlJjou1zlweR81PILqMUmM4iU(bXylCK(IwLXi5HGiHmDzmXrC9dkbuZTf0sfeFpnVEbLmy12GQodf2QDz)L0jC(uAXIyv7)O6kwAdtWEfgA37zxqjbe0RJ3cn(baUajGAUTGwIwNrH6dA)hvxXsByc2RW4dA)hvxXYArRY4ihHcL2)r1vSSw0QmoYryKQ29E2fusbBpJdvUGLHsa1CBbTeToJcL29E2fusg8iOQZsa1CBb)ubkinuO4dGMyjVneo745LSSL9IVNMxVGsgSABqvNHcB1o(a4m4uAXIyf8kcXbOjj0FDehGMWPMecaXGpaodoLsa1CBbTeToJH29E2fusK(bijGAUTGwIwNJVNMxVGsgSABqvNHcB1oK(bil6Br46SvSuGflIv(a4m4ukFkXa8kcXbOjj0FDehGMWPMecaJVNMxVGsgSABqvNHcB1ocBk7oC)r4qvNJVNMxVGsgSABqvNHcB1obBpJdvUGLHX3tZRxqjdwTnOQZqHTAhGGED8wOXpaWfeFpnVEbLmy12GQodf2QD)8ENWm(EAE9ckzWQTbvDgkSv7soa4qtX3tZRxqjdwTnOQZqHTAhdEeu1547P51lOKbR2gu1zOWwTdCk3moYcilweRjpeejdwTnCOQZqjGAUTGFALWgPFmHZBdHb4veIdqts4dGEl04qvNHyK8qqKz)L0jC(ukZUGk(EAE9ckzWQTbvDgkSv7UTHY4qvNTqJPUt48bqtm0AllweRjpeejdwTnCOQZqjGAUTGFALWgPFmHZBdHrQjpeePsaPxiHdvDgkZUGcfkKxVJdiT6bqt482qwQpiJZBdjmADgfQKhcIKbpcQ6S8PmT47P51lOKbR2gu1zOWwTlthRIRvpBGRXIfXkIRFqH1hKXbeAQSeX1pOS5Ww89086fuYGvBdQ6muyR2boLBghzbKflI1KhcIKbR2gou1zOeqn3wWpTsyJ0pMW5THIVNMxVGsgSABqvNHcB1UMxNxOQZwSiwtEiisgSAB4qvNHYSlOqHk5HGivci9cjCOQZq5tjgiU(b)u7qw4tZRxYBBOmou1zP2HmgP(b(6uXsT62Ce4WHQoJc1P59hHtf1Se8tfkT47P51lOKbR2gu1zOWwTtRUnhboCOQZwSiwtEiisLasVqchQ6mu(uIbIRFWp1oKf(086L82gkJdvDwQDiJXP59hHtf1Se0Y0j(EAE9ckzWQTbvDgkSv7ST9oou1zlweRjpeezMUmoHjjZUGk(EAE9ckzWQTbvDgkSv7o8MhitaChbxdCbW47P51lOKbR2gu1zOWwTdPFyszCOQZX3tZRxqjdwTnOQZqHTAhKakPIXH8wOTqJPUt48bqtm0AllweRacbqq1lPtX3tZRxqjdwTnOQZqHTAxZRZlu1zlweRiU(b)u7qw4tZRxYBBOmou1zP2HC89086fuYGvBdQ6muyR2bz6YyIdvD2Wg2yaa]] )

end