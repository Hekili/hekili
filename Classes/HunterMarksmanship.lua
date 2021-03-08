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


    spec:RegisterPack( "Marksmanship", 20210307, [[dO0ipbqikbpsHkAtQu9jvkJIsPtrP4vKuMfLOBrj0Uq5xkKgMijhJs1YaLEgQuzAGc11afTnrs13afIXbvPQZPqLADku18ejUNi1(uioiOqYcvO8qOkzIGcPUOcvOpksk1ifjf1jrLQwjOYmbfCtrsHDss1pvOswkuLspLetfvYvfjf5RkubJfQI9sXFHYGL6WQAXI4XKAYk6YeBwfFgvmAu1PvA1IKsEnjz2GCBfSBj)MQHtjDCOkvwoKNdmDKRlQTdQ67qLXJkLZdv16HQumFvY(f2y3WLrz(Kyuh2ubR9uXDPcgHblSWeM2h3gfcFRIrX6Rv9CeJs9dIrj14rQadFb4xRgfRp(q(pnCzuaEgPfJY4mAEIScg)OJYzj(Cct7dJc2Hm0tRxA0FOrb7GEuJssEHiUVmjgL5tIrDytfS2tf3LkyegSWctyAp1nkFM4DKrrzhWlJc)oNszsmktbOnkPgpsfy4la)An6uZ5IeuaxQXJ08rB3YOHnvWA3OaTacy4YOqOvRcW7eWWLrD7gUmks9jqY0mMrrJwsq7BuOhskIbi5N4JDCDgWK6tGKz03JElSd0YHNI(E0j5ZHbi5N4JDCDgWqYWVfi6uIgMgLxtRxgfaj)eFmaVtgYOoSgUmks9jqY0mMrrJwsq7Bu0o8s9fXuHpA)k67rRDhA64kgsaE90wCWEeYXXqYWVfi6uIMJEg91v0wiATdVuFrmv4J2VI(E0wiATdVuFrSA5WtyNxI(6kATdVuFrSA5WtyNxI(E02gT2DOPJRy4wOjgW6IwcWqYWVfi6uIMJEg91v0A3HMoUIrOSa4DIHKHFlq0JenmHz02e91v00J4ieJ2bbJCS5krNs02tLr5106Lrz65eibJERgYOo3z4YOi1NajtZygfnAjbTVrbLl54iocd4zOJJ4iyYqIGamP(eizg99OPhHrO3kdjd)wGOtjAo6z03Jw7o00XvSd0Jegsg(TarNs0C0tJYRP1lJc9imc9wnKrDySHlJIuFcKmnJzuEnTEzuoqpsmkA0scAFJc9imc9wzzRrFpAuUKJJ4imGNHooIJGjdjccWK6tGKPrbAlbtpnkWctdzuhMgUmkVMwVmkc3Sc5GfEbdW7KrrQpbsMMXmKr9u3WLr5106Lrb3cnXawx0saJIuFcKmnJziJ6WigUmkVMwVmkib41tBXb7rihNrrQpbsMMXmKrD8EdxgLxtRxgf4DiibFJIuFcKmnJziJ6JBdxgLxtRxgLKhHEoIrrQpbsMMXmKrD7PYWLr5106LrHqzbW7KrrQpbsMMXmKrD72nCzuK6tGKPzmJIgTKG23OKKphgHwTkmaVtagsg(Tarps6OfUj6mjy0oirFpAuUKJJ4imqgXzloyaENamP(eizg99OtYNdB65eibJERSPJRmkVMwVmkO36oXolsmKrD7WA4YOi1NajtZygLxtRxgLFhKjgG3jJIgTKG23OKKphgHwTkmaVtagsg(Tarps6OfUj6mjy0oirFpABJojFomRirVabdW7eGnDCv0xxrFYqqyirZ)iocgTds0PeT(begTds0Qfnh9m6RROtYNdJqzbW7elBnABmkA81qcg9iocbmQB3qg1TZDgUmks9jqY0mMrrJwsq7BuoUodIwTO1pGWqchPIoLOpUodydp3mkVMwVmkt5jEmn)Rc9dgYOUDySHlJIuFcKmnJzu0OLe0(gLK85Wi0QvHb4DcWqYWVfi6rshTWnrNjbJ2bXO8AA9YOGER7e7SiXqg1TdtdxgfP(eizAgZOOrljO9nkj5ZHrOvRcdW7eGnDCv0xxrNKphMvKOxGGb4DcWYwJ(E0hxNbrps0AhqrRw0VMwVy)oitmaVtmTdOOVhTTrBHOPhskIP53HxqpgG3jMuFcKmJ(6k6xtl8cMuYWkGOhjAUlABmkVMwVmkdziAb8oziJ62tDdxgfP(eizAgZOOrljO9nkj5ZHzfj6fiyaENaSS1OVh9X1zq0JeT2bu0Qf9RP1l2VdYedW7et7ak67r)AAHxWKsgwbeDkrdJnkVMwVmkA(D4f0Jb4DYqg1TdJy4YOi1NajtZygfnAjbTVrjjFoSP8tmbFHnDCLr5106Lrr1cbHb4DYqg1TJ3B4YO8AA9YO8ydz0uqy(btJCCaJIuFcKmnJziJ62h3gUmkVMwVmkhOhFzIb4DYOi1NajtZygYOoSPYWLrrQpbsMMXmkVMwVmkabzvkcdqBXXOOrljO9nki5Gea)Najgfn(AibJEehHag1TBiJ6WA3WLrrQpbsMMXmkA0scAFJYX1zq0JeT2bu0Qf9RP1l2VdYedW7et7aYO8AA9YOmKHOfW7KHmQdlSgUmkVMwVmkas(j(yaENmks9jqY0mMHmKrzkNpdrgUmQB3WLr5106Lrr75IeegG3jJIuFcKmnJziJ6WA4YOi1NajtZygLxtRxgfTNlsqyaENmkA0scAFJckxYXrCegqSYNXBaywrUg6hEA9Ij1NajZOVUIg4zOKTMSAX)byK7qamR(c8Ij1NajZOVUI22O1EnZlXqc8cc8qy(b74ikxctQpbsMrFpAlenkxYXrCegqSYNXBaywrUg6hEA9Ij1NajZOTXOaTLGPNgfUlvgYOo3z4YO8AA9YOqOVW7Yl0I3SfhmaVtgfP(eizAgZqg1HXgUmks9jqY0mMr5106LrzIKFEwKGbVaacKrzkanATsRxgLutajAIFbr7v0A3HMoUk69e9s3art8s0EbHF0EzXmqyrZ9NOX3ZrZ)Wlr)Lt8ckAVSygirJBj(O)OH8IJGIw7o00XvwgnGETQOj(NIg3s8rZfklaENIghVurt8YIIw7o00XvGO1EDGwnzz0apAC)srNlAHIEPBGO9kAT7qthxfn5rNbs0e)cSmAN4feUfirR9I2klrtE0zGeTxrRDhA64kMrP(bXOmrYpplsWGxaabYqg1HPHlJIuFcKmnJzuEnTEzui0wQeYUrzkanATsRxgfU)enXlrtOTuju08pi6pAVSygirNKphlJgGFPJEPOXTeF0CHYcG3jw0C)jAcNh9JKO1(GvH2It0hhf9hnxOSa4DkAa(L2YOZajAIxIgqiV4iOO9YIzGeTCoIMyrZ9NO)kAVSygirNKpNOxq0i5N4hDsMI(lN4fu0ac5fhbfTxwmdKOtYNt04wiOOFiGhDIens(j(rNGF0eVenTds0CHYcG3PO1(GaIo51QI2pNO1UdnDCLLrNbs0lf9EIM4LOb8psMrtOTuju0A3HMoUkACEDJIElsqhbjrJBj(OjEj6SvTpSfNO5cLfaVtrdWV0SO5(t0FfTxwmdKOtYNt0ApdnJorIodKz0FnJgqleu0AFqIo51QI(4OO)OpzkJKO5cLfaVtwgDgirVelAU)e9hD5LftYNt0EzXmqIEbrJKFIVLrNbs0lf9EIEPOX51nk6TibDeKenUL4J2Qtsr7dfTxwmdKOtYNdiAcH)wCIM8O5cLfaVtrdWV0r7OO3t0eVeTt8ckAcTLkHIEb1nk6VI2llMbILrVGO)OlVSys(CI2llMbs04wIp6pAiV4iOO1UdnDCLLr7OOxqDJIgj)eFw0C)jAIxI(SC4POxq0C8T4en5rl1m6e54ijA89mk6s4gfnxOSa4DYYOtTYakAa9ik6mylortOTujeiAYJE4vjrdYijAIxWpAocfDgitMrrJwsq7Bui0wQeIr2z8paldeSK85e99OTn6K85Wiuwa8oXYwJ(E02gTfIMqBPsigblJ)byzGGLKpNOVUIMqBPsigblt7o00XvmKm8BbI(6kAcTLkHyKDM2DOPJRyZm6P1ROhjD0eAlvcXiyzA3HMoUInZONwVI2MOVUIojFomcLfaVtSPJRI(E02gnH2sLqmcwg)dWYabljForFpAcTLkHyeSmT7qthxXMz0tRxrps6Oj0wQeIr2zA3HMoUInZONwVI(E0eAlvcXiyzA3HMoUIHKHFlq0wmAygDkrRDhA64kgHYcG3jgsg(TarFpAT7qthxXiuwa8oXqYWVfi6rIg2uf91v0eAlvcXi7mT7qthxXMz0tRxrBXOHz0PeT2DOPJRyeklaENyiz43ceTnrFDfn9iocXODqWihBUs0PeT2DOPJRyeklaENyiz43ceTnrFDfTfIMqBPsigzNX)aSmqWsYNt03J22Oj0wQeIrWY4Fawgiyj5Zj67rBB0j5ZHrOSa4DInDCv0xxrtOTujeJGLPDhA64kgsg(Tarps0WmABI(E02gT2DOPJRyeklaENyiz43ce9irdBQI(6kAcTLkHyeSmT7qthxXqYWVfiAlgnmJEKO1UdnDCfJqzbW7edjd)wGOTj6RROTq0eAlvcXiyz8paldeSK85e99OTnAlenH2sLqmcwg)dW0UdnDCv0xxrtOTujeJGLPDhA64k2mJEA9k6rshnH2sLqmYot7o00XvSzg906v0xxrtOTujeJGLPDhA64kgsg(TarBt02yiJ6PUHlJIuFcKmnJzu0OLe0(gfcTLkHyeSm(hGLbcws(CI(E02gDs(CyeklaENyzRrFpABJ2crtOTujeJSZ4Fawgiyj5Zj6RROj0wQeIr2zA3HMoUIHKHFlq0xxrtOTujeJGLPDhA64k2mJEA9k6rshnH2sLqmYot7o00XvSzg906v02e91v0j5ZHrOSa4DInDCv03J22Oj0wQeIr2z8paldeSK85e99Oj0wQeIr2zA3HMoUInZONwVIEK0rtOTujeJGLPDhA64k2mJEA9k67rtOTujeJSZ0UdnDCfdjd)wGOTy0Wm6uIw7o00XvmcLfaVtmKm8BbI(E0A3HMoUIrOSa4DIHKHFlq0JenSPk6RROj0wQeIrWY0UdnDCfBMrpTEfTfJgMrNs0A3HMoUIrOSa4DIHKHFlq02e91v00J4ieJ2bbJCS5krNs0A3HMoUIrOSa4DIHKHFlq02e91v0wiAcTLkHyeSm(hGLbcws(CI(E02gnH2sLqmYoJ)byzGGLKpNOVhTTrNKphgHYcG3j20XvrFDfnH2sLqmYot7o00XvmKm8BbIEKOHz02e99OTnAT7qthxXiuwa8oXqYWVfi6rIg2uf91v0eAlvcXi7mT7qthxXqYWVfiAlgnmJEKO1UdnDCfJqzbW7edjd)wGOTj6RROTq0eAlvcXi7m(hGLbcws(CI(E02gTfIMqBPsigzNX)amT7qthxf91v0eAlvcXi7mT7qthxXMz0tRxrps6Oj0wQeIrWY0UdnDCfBMrpTEf91v0eAlvcXi7mT7qthxXqYWVfiABI2gJYRP1lJcH2sLqWAiJ6WigUmks9jqY0mMrrJwsq7BusYNdJqzbW7elBn6RROtYNdJqzbW7eB64QOVhT2DOPJRyeklaENyiz43ce9irdBQI(6k6ZYHNWqYWVfi6uIw7o00XvmcLfaVtmKm8BbmkVMwVmkzGGTKmamKrD8EdxgfP(eizAgZO8AA9YOOFiiSxtRxyqlGmkqlGWQFqmk6jWqg1h3gUmks9jqY0mMrrJwsq7BuEnTWlysjdRaIoLO5oJYRP1lJI(HGWEnTEHbTaYOaTacR(bXOaidzu3EQmCzuK6tGKPzmJIgTKG23O8AAHxWKsgwbe9irdRr5106Lrr)qqyVMwVWGwazuGwaHv)Gyui0Qvb4DcyidzuSIeTpK8KHlJ62nCzuEnTEzusCIGKj2b6XxM42Idg5CBlJIuFcKmnJziJ6WA4YOi1NajtZygfnAjbTVrbLl54iocd4zOJJ4iyYqIGamP(eizAuEnTEzuOhHrO3QHmQZDgUmks9jqY0mMrXks0pGWODqmk2tLr5106Lrz65eibJERgfnAjbTVr510cVGjLmSci6rI2E0xxrBHO1o8s9fXuHpA)k67rBHOPhskIbVdbj4ZK6tGKPHmQdJnCzuK6tGKPzmJIgTKG23O8AAHxWKsgwbeDkrZDrFpABJ2crRD4L6lIPcF0(v03J2crtpKuedEhcsWNj1NajZOVUI(10cVGjLmSci6uIg2OTXO8AA9YO87GmXa8oziJ6W0WLrrQpbsMMXmkA0scAFJYRPfEbtkzyfq0JenSrFDfTTrRD4L6lIPcF0(v0xxrtpKuedEhcsWNj1NajZOTj67r)AAHxWKsgwbeD6OH1O8AA9YOai5N4Jb4DYqgYOONadxg1TB4YOi1NajtZygfnAjbTVrjjFomcLfaVtSS1OVUI(SC4jmKm8BbIoLOTZDgLxtRxgLebbeKQT4yiJ6WA4YOi1NajtZygfnAjbTVrjjFomcLfaVtSS1OVUI(SC4jmKm8BbIoLOTN6gLxtRxgLei3NyNmcFdzuN7mCzuK6tGKPzmJIgTKG23OKKphgHYcG3jw2A0xxrFwo8egsg(TarNs02tDJYRP1lJYxAbqOhct)qqgYOom2WLrrQpbsMMXmkA0scAFJss(CyeklaENyzRrFDf9z5Wtyiz43ceDkrpUnkVMwVmkNfjjqUpnKrDyA4YOi1NajtZygfnAjbTVrjjFomcLfaVtSPJRmkVMwVmkqlhEcGLALNCgKImKr9u3WLrrQpbsMMXmkA0scAFJss(CyeklaENythxzuEnTEzusEoy(bJqRwfWqg1HrmCzuK6tGKPzmJIgTKG23OKKphgHYcG3jw2A03JojFoSei3NqzaXYwJ(6k6K85Wiuwa8oXYwJ(E00J4ieJxEiINzvtrNs0WMQOVUI(SC4jmKm8BbIoLOHn1nkVMwVmkwDA9YqgYOaidxg1TB4YOi1NajtZygfnAjbTVrHEiPigGKFIp2X1zatQpbsMrFpABJ2ksGhJJEYSZaK8t8Xa8of99OtYNddqYpXh746mGHKHFlq0PenmJ(6k6K85WaK8t8XoUodythxfTngLxtRxgfaj)eFmaVtgYOoSgUmkVMwVmkQwiimaVtgfP(eizAgZqg15odxgfP(eizAgZOOrljO9nkAhEP(IyQWhTFf99O1UdnDCfdjaVEAloypc54yiz43ceDkrZrpJ(6kAleT2HxQViMk8r7xrFpAleT2HxQViwTC4jSZlrFDfT2HxQViwTC4jSZlrFpABJw7o00XvmCl0edyDrlbyiz43ceDkrZrpJ(6kAT7qthxXiuwa8oXqYWVfi6rIgMWmABI(6kA6rCeIr7GGro2CLOtjA7W0O8AA9YOm9CcKGrVvdzuhgB4YOi1NajtZygLxtRxgLd0JeJIgTKG23OqpcJqVvw2A03JgLl54iocd4zOJJ4iyYqIGamP(eizAuG2sW0tJcSW0qg1HPHlJIuFcKmnJzu0OLe0(gfuUKJJ4imGNHooIJGjdjccWK6tGKz03JMEegHERmKm8BbIoLO5ONrFpAT7qthxXoqpsyiz43ceDkrZrpnkVMwVmk0JWi0B1qg1tDdxgLxtRxgfHBwHCWcVGb4DYOi1NajtZygYOomIHlJYRP1lJcUfAIbSUOLagfP(eizAgZqg1X7nCzuEnTEzuoqp(YedW7KrrQpbsMMXmKr9XTHlJIuFcKmnJzu0OLe0(gLJRZGOvlA9dimKWrQOtj6JRZa2WZnJYRP1lJYuEIhtZ)Qq)GHmQBpvgUmkVMwVmkp2qgnfeMFW0ihhWOi1NajtZygYOUD7gUmkVMwVmkib41tBXb7rihNrrQpbsMMXmKrD7WA4YOi1NajtZygfnAjbTVrjjFomRirVabdW7eGnDCv0xxrBHOPhskIP53HxqpgG3jMuFcKmJ(6k6xtl8cMuYWkGOtjAynkVMwVmkW7qqc(gYOUDUZWLrrQpbsMMXmkA0scAFJss(CywrIEbcgG3jaB64QOVUIojFomKa86PT4G9iKJJLTg91v0j5ZHHBHMyaRlAjalBn6RROtYNddEhcsWNLTg99OFnTWlysjdRaIEKOTBuEnTEzuiuwa8oziJ62HXgUmks9jqY0mMr5106Lr53bzIb4DYOOXxdjy0J4ieWOUDJIgTKG23OKKphMvKOxGGb4DcWMoUk6RROTn6K85Wiuwa8oXYwJ(6k6tgccdjA(hXrWODqIoLO5ONrRw06hqy0oirBt03J22OTq00djfX087WlOhdW7etQpbsMrFDf9RPfEbtkzyfq0PenSrBt0xxrNKphgHwTkmaVtagsg(Tarps0c3eDMemAhKOVh9RPfEbtkzyfq0JeTDJYuaA0ALwVmkCnUGrpUgF04Tc8RGl6xtRxmGGSkfHbOT4W2c7aTC4jmYXOhXridzu3omnCzuK6tGKPzmJIgTKG23OCCDgeTArRFaHHeosfDkrFCDgWgEUf99OTn6K85Wiuwa8oXMoUk6RROTq0OCjhhXryYZbsOhYlagHYc2X1zatQpbsMrBt03J22OtYNdB65eibJERSPJRI(6kA6HKIyacj)a0wctQpbsMrBJr5106Lrb9w3j2zrIHmQBp1nCzuK6tGKPzmJIgTKG23OKKphMvKOxGGb4DcWYwJ(6k6JRZGOhjATdOOvl6xtRxSFhKjgG3jM2bKr5106LrrZVdVGEmaVtgYOUDyedxgfP(eizAgZOOrljO9nkj5ZHzfj6fiyaENaSS1OVUI(46mi6rIw7akA1I(106f73bzIb4DIPDazuEnTEzuEK(lbdW7KHmQBhV3WLrrQpbsMMXmkVMwVmkabzvkcdqBXXOOrljO9nki5Gea)NajrFpA6rCeIr7GGro2CLOhj6zg906LrrJVgsWOhXriGrD7gYOU9XTHlJIuFcKmnJzu0OLe0(gLxtl8cMuYWkGOhjA7gLxtRxgLKhHEoIHmQdBQmCzuK6tGKPzmJIgTKG23OCCDgeTArRFaHHeosfDkrFCDgWgEUf99OTn6K85WMEobsWO3kB64QOVUIMEiPigGqYpaTLWK6tGKz02yuEnTEzuqV1DIDwKyiJ6WA3WLr5106LrbqYpXhdW7KrrQpbsMMXmKHmKrbEbbwVmQdBQG1EQGnvWAuW9OAloaJY4amk8w15E1tThF0rZfVe9oy1ru0hhf9ncTAvaENa3Igj4D5fjZOb(Ge9NjF4jzgTM)locGfWbdBjrBF8rJxEbVGizg9n6HKIy45w0Kh9n6HKIy4Hj1NajZBrBRDUzdlGdg2sIM7gF04LxWlisMrFdLl54iocdp3IM8OVHYLCCehHHhMuFcKmVfTT25MnSaoyyljAy84JgV8cEbrYm6BOCjhhXry45w0Kh9nuUKJJ4im8WK6tGK5TOFk6XXXfmeTT25MnSaoyyljA72hF04LxWlisMrFdLl54iocdp3IM8OVHYLCCehHHhMuFcKmVfTT25MnSaoyyljA7WC8rJxEbVGizg9n6HKIy45w0Kh9n6HKIy4Hj1NajZBrBRDUzdlGlGBCagfER6CV6P2Jp6O5IxIEhS6ik6JJI(2uoFgIUfnsW7YlsMrd8bj6pt(WtYmAn)xCealGdg2sIg2XhnE5f8cIKz03q5sooIJWWZTOjp6BOCjhhXry4Hj1NajZBrBRDUzdlGdg2sIg2XhnE5f8cIKz03q5sooIJWWZTOjp6BOCjhhXry4Hj1NajZBrBRDUzdlGdg2sIg2XhnE5f8cIKz030EnZlXWZTOjp6BAVM5Ly4Hj1NajZBrBRDUzdlGdg2sIg2XhnE5f8cIKz03aEgkzRjdp3IM8OVb8muYwtgEys9jqY8w02ANB2Wc4GHTKOH54JgV8cEbrYm6BeAlvcXSZWZTOjp6BeAlvcXi7m8ClABtDUzdlGdg2sIgMJpA8Yl4fejZOVrOTujedwgEUfn5rFJqBPsigbldp3I2w7Ch3SHfWbdBjrN6JpA8Yl4fejZOVrOTujeZodp3IM8OVrOTujeJSZWZTOT1o3XnBybCWWws0P(4JgV8cEbrYm6BeAlvcXGLHNBrtE03i0wQeIrWYWZTOTn15MnSaUaUXbyu4TQZ9QNAp(OJMlEj6DWQJOOpok6BwrI2hsE6w0ibVlVizgnWhKO)m5dpjZO18FXraSaoyyljAyhF04LxWlisMrFdLl54iocdp3IM8OVHYLCCehHHhMuFcKmVf9trpooUGHOT1o3SHfWbdBjrZDJpA8Yl4fejZOVrpKuedp3IM8OVrpKuedpmP(eizEl6NIECCCbdrBRDUzdlGdg2sIggp(OXlVGxqKmJ(g9qsrm8ClAYJ(g9qsrm8WK6tGK5TOT1o3SHfWbdBjrdZXhnE5f8cIKz03OhskIHNBrtE03OhskIHhMuFcKmVfTT25MnSaUaUXbyu4TQZ9QNAp(OJMlEj6DWQJOOpok6Ba6w0ibVlVizgnWhKO)m5dpjZO18FXraSaoyyljA7JpA8Yl4fejZOVrpKuedp3IM8OVrpKuedpmP(eizElABTZnBybCWWws0W4XhnE5f8cIKz03q5sooIJWWZTOjp6BOCjhhXry4Hj1NajZBr)u0JJJlyiABTZnBybCWWws0WC8rJxEbVGizg9nuUKJJ4im8ClAYJ(gkxYXrCegEys9jqY8w02ANB2Wc4GHTKOTd74JgV8cEbrYm6B0djfXWZTOjp6B0djfXWdtQpbsM3I2w7CZgwahmSLeTDy84JgV8cEbrYm6B0djfXWZTOjp6B0djfXWdtQpbsM3I2w7CZgwahmSLeTDyo(OXlVGxqKmJ(g9qsrm8ClAYJ(g9qsrm8WK6tGK5TOT1o3SHfWbdBjrBhMJpA8Yl4fejZOVHYLCCehHHNBrtE03q5sooIJWWdtQpbsM3I2w7CZgwahmSLenSPA8rJxEbVGizg9n6HKIy45w0Kh9n6HKIy4Hj1NajZBrBRDUzdlGlGJ7hS6isMrdZOFnTEfn0cialGZOyf5NfsmkJZXz0Pgpsfy4la)An6uZ5Ieua34CCgDQXJ08rB3YOHnvWApGlG7106fGzfjAFi5j1spAIteKmXoqp(Ye3wCWiNBBfW9AA9cWSIeTpK8KAPhLEegHERwUN0OCjhhXryapdDCehbtgseeiG7106fGzfjAFi5j1sp60Zjqcg9wT0ks0pGWODqsBpvwUN0VMw4fmPKHvaJy)6YcAhEP(IyQWhTFD3c0djfXG3HGe8d4EnTEbywrI2hsEsT0J(7GmXa8oz5Es)AAHxWKsgwbKc3D3wlOD4L6lIPcF0(1DlqpKuedEhcsW)6610cVGjLmScifyTjG7106fGzfjAFi5j1spkGKFIpgG3jl3t6xtl8cMuYWkGrG96YwTdVuFrmv4J2VUUOhskIbVdbj4BZ9xtl8cMuYWkG0WgWfW9AA9cOw6r1EUibHb4DkG7106fqT0JQ9CrccdW7KLqBjy6zAUlvwUN0OCjhhXryaXkFgVbGzf5AOF4P1RRlGNHs2AYQf)hGrUdbWS6lWRRlB1EnZlXqc8cc8qy(b74ikxYDlGYLCCehHbeR8z8gaMvKRH(HNwVSjG7106fqT0JsOVW7Yl0I3SfhmaVtbCJZOtnbKOj(feTxrRDhA64QO3t0lDdenXlr7fe(r7LfZaHfn3FIgFphn)dVe9xoXlOO9YIzGenUL4J(JgYlockAT7qthxzz0a61QIM4FkAClXhnxOSa4DkAC8sfnXllkAT7qthxbIw71bA1KLrd8OX9lfDUOfk6LUbI2RO1UdnDCv0KhDgirt8lWYODIxq4wGeT2lARSen5rNbs0EfT2DOPJRybCVMwVaQLE0mqWwsgSS(bj9ej)8SibdEbaeOaUXz0C)jAIxIMqBPsOO5Fq0F0EzXmqIojFowgna)sh9srJBj(O5cLfaVtSO5(t0eop6hjrR9bRcTfNOpok6pAUqzbW7u0a8lTLrNbs0eVenGqEXrqr7LfZajA5CenXIM7pr)v0EzXmqIojForVGOrYpXp6Kmf9xoXlOObeYlockAVSygirNKpNOXTqqr)qap6ejAK8t8Job)OjEjAAhKO5cLfaVtrR9bbeDYRvfTForRDhA64klJodKOxk69enXlrd4FKmJMqBPsOO1UdnDCv0486gf9wKGocsIg3s8rt8s0zRAFylorZfklaENIgGFPzrZ9NO)kAVSygirNKpNO1EgAgDIeDgiZO)AgnGwiOO1(GeDYRvf9Xrr)rFYugjrZfklaENSm6mqIEjw0C)j6p6YllMKpNO9YIzGe9cIgj)eFlJodKOxk69e9srJZRBu0Brc6iijAClXhTvNKI2hkAVSygirNKphq0ec)T4en5rZfklaENIgGFPJ2rrVNOjEjAN4fu0eAlvcf9cQBu0FfTxwmdelJEbr)rxEzXK85eTxwmdKOXTeF0F0qEXrqrRDhA64klJ2rrVG6gfns(j(SO5(t0eVe9z5WtrVGO54BXjAYJwQz0jYXrs047zu0LWnkAUqzbW7KLrNALbu0a6ru0zWwCIMqBPsiq0Kh9WRsIgKrs0eVGF0Cek6mqMSaUxtRxa1spkH2sLq2TCpPj0wQeIzNX)aSmqWsYNZDBtYNdJqzbW7elB9UTwGqBPsigSm(hGLbcws(CUUi0wQeIblt7o00XvmKm8BbUUi0wQeIzNPDhA64k2mJEA9AK0eAlvcXGLPDhA64k2mJEA9YMRRK85Wiuwa8oXMoU6UTeAlvcXGLX)aSmqWsYNZDcTLkHyWY0UdnDCfBMrpTEnsAcTLkHy2zA3HMoUInZONwVUtOTujedwM2DOPJRyiz43cyryMI2DOPJRyeklaENyiz43cCx7o00XvmcLfaVtmKm8Bbgb2uDDrOTujeZot7o00XvSzg906LfHzkA3HMoUIrOSa4DIHKHFlGnxx0J4ieJ2bbJCS5kPODhA64kgHYcG3jgsg(Ta2CDzbcTLkHy2z8paldeSK85C3wcTLkHyWY4Fawgiyj5Z5UTj5ZHrOSa4DInDC11fH2sLqmyzA3HMoUIHKHFlWiW0M72QDhA64kgHYcG3jgsg(TaJaBQUUi0wQeIblt7o00XvmKm8BbSimhr7o00XvmcLfaVtmKm8BbS56YceAlvcXGLX)aSmqWsYNZDBTaH2sLqmyz8pat7o00XvxxeAlvcXGLPDhA64k2mJEA9AK0eAlvcXSZ0UdnDCfBMrpTEDDrOTujedwM2DOPJRyiz43cyJnbCVMwVaQLEucTLkHG1Y9KMqBPsigSm(hGLbcws(CUBBs(CyeklaENyzR3T1ceAlvcXSZ4Fawgiyj5Z56IqBPsiMDM2DOPJRyiz43cCDrOTujedwM2DOPJRyZm6P1RrstOTujeZot7o00XvSzg906Lnxxj5ZHrOSa4DInDC1DBj0wQeIzNX)aSmqWsYNZDcTLkHy2zA3HMoUInZONwVgjnH2sLqmyzA3HMoUInZONwVUtOTujeZot7o00XvmKm8BbSimtr7o00XvmcLfaVtmKm8BbURDhA64kgHYcG3jgsg(TaJaBQUUi0wQeIblt7o00XvSzg906LfHzkA3HMoUIrOSa4DIHKHFlGnxx0J4ieJ2bbJCS5kPODhA64kgHYcG3jgsg(Ta2CDzbcTLkHyWY4Fawgiyj5Z5UTeAlvcXSZ4Fawgiyj5Z5UTj5ZHrOSa4DInDC11fH2sLqm7mT7qthxXqYWVfyeyAZDB1UdnDCfJqzbW7edjd)wGrGnvxxeAlvcXSZ0UdnDCfdjd)walcZr0UdnDCfJqzbW7edjd)waBUUSaH2sLqm7m(hGLbcws(CUBRfi0wQeIzNX)amT7qthxDDrOTujeZot7o00XvSzg9061iPj0wQeIblt7o00XvSzg90611fH2sLqm7mT7qthxXqYWVfWgBc4EnTEbul9OzGGTKmaSCpPtYNdJqzbW7elB96kjFomcLfaVtSPJRURDhA64kgHYcG3jgsg(TaJaBQUUolhEcdjd)wGu0UdnDCfJqzbW7edjd)wGaUxtRxa1spQ(HGWEnTEHbTaYY6hK06jiG7106fqT0JQFiiSxtRxyqlGSS(bjnGSCpPFnTWlysjdRasH7c4EnTEbul9O6hcc7106fg0cilRFqstOvRcW7eWY9K(10cVGjLmScyeyd4c4EnTEby6jiDIGacs1wCSCpPtYNdJqzbW7elB966SC4jmKm8BbsXo3fW9AA9cW0tGAPhnbY9j2jJW3Y9KojFomcLfaVtSS1RRZYHNWqYWVfif7PEa3RP1latpbQLE0V0cGqpeM(HGSCpPtYNdJqzbW7elB966SC4jmKm8BbsXEQhW9AA9cW0tGAPh9SijbY9PL7jDs(CyeklaENyzRxxNLdpHHKHFlqkJ7aUxtRxaMEcul9OqlhEcGLALNCgKISCpPtYNdJqzbW7eB64QaUxtRxaMEcul9Ojphm)GrOvRcy5EsNKphgHYcG3j20XvbCVMwVam9eOw6rT606LL7jDs(CyeklaENyzR3tYNdlbY9jugqSS1RRK85Wiuwa8oXYwVtpIJqmE5HiEMvnLcSP666SC4jmKm8Bbsb2upGlG7106fGbO0as(j(yaENSCpPPhskIbi5N4JDCDgC3wRibEmo6jZodqYpXhdW709K85WaK8t8XoUodyiz43cKcmVUsYNddqYpXh746mGnDCLnbCVMwVamaPw6rvTqqyaENc4EnTEbyasT0Jo9CcKGrVvl3tATdVuFrmv4J2VURDhA64kgsaE90wCWEeYXXqYWVfifo651Lf0o8s9fXuHpA)6Uf0o8s9fXQLdpHDE56s7Wl1xeRwo8e25L72QDhA64kgUfAIbSUOLamKm8BbsHJEEDPDhA64kgHYcG3jgsg(TaJatyAZ1f9iocXODqWihBUsk2Hza3RP1ladqQLE0d0JelH2sW0Z0Wctl3tA6rye6TYYwVJYLCCehHb8m0XrCemzirqGaUxtRxagGul9O0JWi0B1Y9KgLl54iocd4zOJJ4iyYqIGa3PhHrO3kdjd)wGu4ON31UdnDCf7a9iHHKHFlqkC0ZaUxtRxagGul9Oc3Sc5GfEbdW7ua3RP1ladqQLEuCl0edyDrlbc4EnTEbyasT0JEGE8LjgG3PaUxtRxagGul9Ot5jEmn)Rc9dwUN0hxNbQPFaHHeosLYX1zaB45wa3RP1ladqQLE0hBiJMccZpyAKJdeW9AA9cWaKAPhfjaVEAloypc54c4EnTEbyasT0JcVdbj4B5EsNKphMvKOxGGb4DcWMoU66Yc0djfX087WlOhdW7011RPfEbtkzyfqkWgW9AA9cWaKAPhLqzbW7KL7jDs(CywrIEbcgG3jaB64QRRK85WqcWRN2Id2Jqoow261vs(Cy4wOjgW6IwcWYwVUsYNddEhcsWNLTE)10cVGjLmScye7bCJZO5ACbJECn(OXBf4xbx0VMwVyabzvkcdqBXHTf2bA5WtyKJrpIJqbCVMwVamaPw6r)DqMyaENSuJVgsWOhXriqA7wUN0j5ZHzfj6fiyaENaSPJRUUSnjFomcLfaVtSS1RRtgccdjA(hXrWODqsHJEQM(begTdIn3T1c0djfX087WlOhdW7011RPfEbtkzyfqkWAZ1vs(CyeA1QWa8obyiz43cmIWnrNjbJ2b5(RPfEbtkzyfWi2d4EnTEbyasT0JIER7e7SiXY9K(46mqn9dimKWrQuoUodydp3UBBs(CyeklaENythxDDzbuUKJJ4im55aj0d5faJqzb746mWM72MKph20Zjqcg9wzthxDDrpKuedqi5hG2sSjG7106fGbi1spQMFhEb9yaENSCpPtYNdZks0lqWa8obyzRxxhxNbJODaP2RP1l2VdYedW7et7akG7106fGbi1sp6J0FjyaENSCpPtYNdZks0lqWa8obyzRxxhxNbJODaP2RP1l2VdYedW7et7akG7106fGbi1spkqqwLIWa0wCSuJVgsWOhXriqA7wUN0i5Gea)Naj3PhXrigTdcg5yZvgzMrpTEfW9AA9cWaKAPhn5rONJy5Es)AAHxWKsgwbmI9aUxtRxagGul9OO36oXolsSCpPpUodut)acdjCKkLJRZa2WZT72MKph20Zjqcg9wzthxDDrpKuedqi5hG2sSjG7106fGbi1spkGKFIpgG3PaUaUxtRxagHwTkaVtG0as(j(yaENSCpPPhskIbi5N4JDCDgCFlSd0YHNUNKphgGKFIp2X1zadjd)wGuGza3RP1laJqRwfG3jGAPhD65eibJERwUN0AhEP(IyQWhTFDx7o00XvmKa86PT4G9iKJJHKHFlqkC0ZRllOD4L6lIPcF0(1DlOD4L6lIvlhEc78Y1L2HxQViwTC4jSZl3Tv7o00XvmCl0edyDrlbyiz43cKch986s7o00XvmcLfaVtmKm8BbgbMW0MRl6rCeIr7GGro2CLuSNQaUxtRxagHwTkaVta1spk9imc9wTCpPr5sooIJWaEg64iocMmKiiWD6rye6TYqYWVfifo65DT7qthxXoqpsyiz43cKch9mG7106fGrOvRcW7eqT0JEGEKyj0wcMEMgwyA5EstpcJqVvw26DuUKJJ4imGNHooIJGjdjcceW9AA9cWi0Qvb4DcOw6rfUzfYbl8cgG3PaUxtRxagHwTkaVta1spkUfAIbSUOLabCVMwVamcTAvaENaQLEuKa86PT4G9iKJlG7106fGrOvRcW7eqT0JcVdbj4hW9AA9cWi0Qvb4DcOw6rtEe65ibCVMwVamcTAvaENaQLEucLfaVtbCVMwVamcTAvaENaQLEu0BDNyNfjwUN0j5ZHrOvRcdW7eGHKHFlWiPfUj6mjy0oi3r5sooIJWazeNT4Gb4DcCpjFoSPNtGem6TYMoUkG7106fGrOvRcW7eqT0J(7GmXa8ozPgFnKGrpIJqG02TCpPtYNdJqRwfgG3jadjd)wGrslCt0zsWODqUBBs(CywrIEbcgG3jaB64QRRtgccdjA(hXrWODqsr)acJ2brno651vs(CyeklaENyzR2eW9AA9cWi0Qvb4DcOw6rNYt8yA(xf6hSCpPpUodut)acdjCKkLJRZa2WZTaUxtRxagHwTkaVta1spk6TUtSZIel3t6K85Wi0QvHb4DcWqYWVfyK0c3eDMemAhKaUxtRxagHwTkaVta1sp6qgIwaVtwUN0j5ZHrOvRcdW7eGnDC11vs(CywrIEbcgG3jalB9(X1zWiAhqQ9AA9I97GmXa8oX0oGUBRfOhskIP53HxqpgG3PRRxtl8cMuYWkGr4oBc4EnTEbyeA1Qa8obul9OA(D4f0Jb4DYY9KojFomRirVabdW7eGLTE)46myeTdi1EnTEX(DqMyaENyAhq3FnTWlysjdRasbghW9AA9cWi0Qvb4DcOw6rvTqqyaENSCpPtYNdBk)etWxythxfW9AA9cWi0Qvb4DcOw6rFSHmAkim)GProoqa3RP1laJqRwfG3jGAPh9a94ltmaVtbCVMwVamcTAvaENaQLEuGGSkfHbOT4yPgFnKGrpIJqG02TCpPrYbja(pbsc4EnTEbyeA1Qa8obul9OdziAb8oz5EsFCDgmI2bKAVMwVy)oitmaVtmTdOaUxtRxagHwTkaVta1spkGKFIpgG3jJcWQOnQdlmHXgYqgda]] )

end