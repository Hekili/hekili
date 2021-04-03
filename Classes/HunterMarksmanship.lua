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
            duration = function () return ( legendary.eagletalons_true_focus.enabled and 20 or 15 ) * ( 1 + ( conduit.sharpshooters_focus.mod * 0.01 ) ) end,
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

        if now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end

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


    spec:RegisterPack( "Marksmanship", 20210403, [[dKeRwbqiOepcuu1Mus9jjLrrcofsQxrfAwujDljH2fIFPKyyubogv0YGIEgsctJkOUgssBtsqFJkiACubHZHKiwNKKMNKu3ts1(KeDqKePfQK0dbf5IubjFeuuXibffCsjbwjuyMssCtqrL2jvIFsfKAPGIs9usAQKqxfuuOVckkASGc7vI)cvdwQdRYIPkpMutwPUmQndYNbvJgPoTQwnOOKxtIMTIUTsSBr)MYWPsDCKeLLd8CitN46kSDqPVJeJhkPZdLA9ijQMpv1(fU4SOyrDFcxCbthGPth4WoGkioDsfvivD4IQGTBUO6(0kp4CrnVfUOcZ9akrlxIOF3fv3h2t72fflQiBa0CrfMpAArCJQ6kRa)f6HhrBlRG(LX8K3sn4GKvq)IELIQ34NsfKfVI6(eU4cMoatNoWHDavqC6KkQqQsff1Bi0gOOQ(lWurL(3BolEf1nJ0fvyUhqjA5se97oAyggPWGadQu3GFgnMUgnMoatNf15JeurXIQaETseTjOIIfxCwuSOY55n5Dz1IQg8cd(ROk3KtHGe(2yJdz6bIW55n5D0RJ(tCO5dNwIED0Ediics4BJnoKPhicGxUprrxD0uTOEA5TSOIe(2yJJOnPifxWSOyrLZZBY7YQfvn4fg8xrvBWY5Lcrj2G)YOxhT2S52OKeaJS8KpHJFaGrHa4L7tu0vhnC9oAF)OXs0AdwoVuikXg8xg96OXs0AdwoVui5dNwWHooAF)O1gSCEPqYhoTGdDC0RJwHO1Mn3gLKq5NBCK7h8cIa4L7tu0vhnC9oAF)O1Mn3gLKiGbJOnHa4L7tu0vgnvPA0uhTVF0YbGZcr(fgxm89ZrxD0oDqr90YBzrDBdVjJlN7IuCHkkkwu588M8USArvdEHb)vubJKHmaCMGSXeYaWzCEXJbicNN3K3rVoA5a4c4Cta8Y9jk6QJgUEh96O1Mn3gLKanpata8Y9jk6QJgUExupT8wwuLdGlGZDrkU4WfflQCEEtExwTOEA5TSOcnpaxu1GxyWFfv5a4c4CtgUJED0GrYqgaotq2ycza4moV4XaeHZZBY7I68tgxVlQys1IuCHQfflQNwEllQmwDpn0dlJJOnPOY55n5Dz1IuCPclkwupT8wwuP8ZnoY9dEbvu588M8USArkU4qwuSOEA5TSOcyKLN8jC8damkfvopVjVlRwKIloefflQCEEtExwTOQbVWG)kQEdiicGrwEYNWXpaWOqgUJ23pASeT2GLZlfIsSb)Lr77hTCtofYKf6BIJOnbr488M8UOEA5TSOcRnNm2fP4cvsrXI6PL3YIQ3bahCUOY55n5Dz1IuCXPdkkwupT8wwufWGr0Muu588M8USArkU40zrXIkNN3K3LvlQAWlm4VIkyKmKbGZe0aa)t44iAtqeopVjVJED0keT2S52OKeaJS8KpHJFaGrHa4L7tu0vgTtheTVF0yjATblNxkeLyd(lJ23pA5MCkKjl03ehrBcIW55n5D0uh96O9gqqeb8AL4iAtqeaVCFIIUY6rZyL1dHXLFHlQNwEllQGZ9VXHEaxKIloXSOyrLZZBY7YQf1tlVLf17x4noI2KIQg8cd(RO6nGGic41kXr0MGiaE5(efDL1JMXkRhcJl)ch96OviAVbeeXnG1pIXr0MGiBJsgTVF0qJ5ehWA6daNXLFHJU6O1hsWLFHJ2XOHR3r77hT3acIiGbJOnHmChn1fvn26jJlhaolOIlolsXfNurrXIkNN3K3LvlQAWlm4VIkKPhOODmA9HeCadNZORoAitpqKLdRf1tlVLf1nFcnUM(ucULIuCXPdxuSOY55n5Dz1IQg8cd(ROQq0AZMBJssamYYt(eo(bagfcGxUprrxz0oDq0RJgmsgYaWzcAaG)jCCeTjicNN3K3r77hnwIwBWY5Lcrj2G)YO99Jglrdgjdza4mbnaW)eooI2eeHZZBY7O99JwUjNczYc9nXr0MGiCEEtEhn1rVoAVbeeraVwjoI2eebWl3NOORSE0mwz9qyC5x4I6PL3YIk4C)BCOhWfP4ItQwuSOY55n5Dz1IQg8cd(RO6nGGic41kXr0MGiBJsgTVF0EdiiIBaRFeJJOnbrgUJED0qMEGIUYO1gsI2XOpT8wsUFH34iAtiAdjrVoAfIglrl3KtHOP)LJbhoI2ecNN3K3r77h9PLhwgNtE5zu0vgnven1f1tlVLf1LXuEeTjfP4IZkSOyrLZZBY7YQfvn4fg8xr1BabrCdy9JyCeTjiYWD0RJgY0du0vgT2qs0og9PL3sY9l8ghrBcrBij61rFA5HLX5KxEgfD1r7Wf1tlVLfvn9VCm4Wr0MuKIloDilkwu588M8USArvdEHb)vu9gqqKnFBCgBMSnkzr90YBzrv5pN4iAtksXfNoefflQNwEllQh(YaSzaUbHRbgfurLZZBY7YQfP4ItQKIIf1tlVLfvO5HnVXr0Muu588M8USArkUGPdkkwu588M8USAr90YBzrfXa3Ck4i5t4fvn4fg8xrfWqagrFEtUOQXwpzC5aWzbvCXzrkUGPZIIfvopVjVlRwu1GxyWFfvitpqrxz0Adjr7y0NwElj3VWBCeTjeTHKI6PL3YI6YykpI2KIuCbtmlkwupT8wwurcFBSXr0Muu588M8USArksrDZq3ykfflU4SOyr90YBzrvBJuyaoI2KIkNN3K3LvlsXfmlkwu588M8USAr90YBzrvBJuyaoI2KIQg8cd(ROcgjdza4mbXUPhu5iC3atpVLtEljCEEtEhTVF0iBm9(CtYh7dHlMnr4UThzjHZZBY7O99JwHO1wUhVqamSmaDtCdchYaYizcNN3K3rVoASenyKmKbGZee7MEqLJWDdm98wo5TKW55n5D0uxuNFY46DrLkCqrkUqffflQNwEllQc4sQSXpFQ8pHJJOnPOY55n5Dz1IuCXHlkwu588M8USAr90YBzrDd4Bd9aghwgH4zrDZin4DlVLfvygrC0c9JI2YO1Mn3gLm6hk6xQHIwO5OTCID0wwXbIjrxbqrJTnIM(GLJ(stOzq0wwXbIJMYl0rFrpTeodIwB2CBusxJgjNwz0c9jrt5f6OvemyeTjrtHMZOfA(brRnBUnkjkATLqZxlUgnYIMY9s0Ju(z0VudfTLrRnBUnkz0If9aXrl0pY1OnHMbuEehT2s5ZbhTyrpqC0wgT2S52OKKIAElCrDd4Bd9aghwgH4zrkUq1IIfvopVjVlRwupT8wwufWNkzXzrDZin4DlVLf1kakAHMJwaFQKLOPpu0x0wwXbIJ2Bab5A0iStD0VenLxOJwrWGr0MqIUcGIwOyrFaoATT4MLpHhnKbI(IwrWGr0Menc7u7A0dehTqZrJeGLWzq0wwXbIJMHGyTqIUcGI(YOTSIdehT3ack6hfnGVn2r7nKOV0eAgensawcNbrBzfhioAVbeu0u(5m6BISO94Ob8TXoApSJwO5OLFHJwrWGr0MeT2wyu0ENwz0geu0AZMBJs6A0deh9lr)qrl0C0i6dW7OfWNkzjATzZTrjJMIL1KO)uyaed4OP8cD0cnh9WT2w(eE0kcgmI2KOryNAs0vau0xgTLvCG4O9gqqrRTXChThh9aX7OVChns(5mATTWr7DALrdzGOVOHgYaWrRiyWiAtCn6bIJ(fs0vau0x0PLv0BabfTLvCG4OFu0a(2y7A0deh9lr)qr)s0uSSMe9NcdGyahnLxOJ2TjCk)nJ2YkoqC0Ediiu0ca7pHhTyrRiyWiAtIgHDQJ2ar)qrl0C0MqZGOfWNkzj6hL1KOVmAlR4aXUg9JI(IoTSIEdiOOTSIdehnLxOJ(IEAjCgeT2S52OKUgTbI(rznjAaFBSjrxbqrl0C0qpCAj6hfnC7t4rlw0CUJ2JHmahn22aeDYyvIwrWGr0M4A0WSgijAKCaj6b6t4rlGpvYckAXIE5uYrJgaoAHMXoA4Se9aXBsrvdEHb)vufWNkzHioj0hcFGyCVbeu0RJwHO9gqqebmyeTjKH7OxhTcrJLOfWNkzHiysOpe(aX4EdiOO99JwaFQKfIGjrB2CBuscGxUprr77hTa(ujleXjrB2CBusYEao5Tm6kRhTa(ujlebtI2S52OKK9aCYBz0uhTVF0EdiiIagmI2eY2OKrVoAfIwaFQKfIGjH(q4deJ7nGGIED0c4tLSqemjAZMBJss2dWjVLrxz9OfWNkzHiojAZMBJss2dWjVLrVoAb8PswicMeTzZTrjjaE5(efDfJMQrxD0AZMBJsseWGr0Mqa8Y9jk61rRnBUnkjradgrBcbWl3NOORmAmDq0((rlGpvYcrCs0Mn3gLKShGtElJUIrt1ORoATzZTrjjcyWiAtiaE5(efn1r77hTCa4SqKFHXfdF)C0vhT2S52OKebmyeTjeaVCFIIM6O99JglrlGpvYcrCsOpe(aX4EdiOOxhTcrlGpvYcrWKqFi8bIX9gqqrVoAfI2BabreWGr0Mq2gLmAF)OfWNkzHiys0Mn3gLKa4L7tu0vgnvJM6OxhTcrRnBUnkjradgrBcbWl3NOORmAmDq0((rlGpvYcrWKOnBUnkjbWl3NOORy0un6kJwB2CBusIagmI2ecGxUprrtD0((rJLOfWNkzHiysOpe(aX4EdiOOxhTcrJLOfWNkzHiysOpeU2S52OKr77hTa(ujlebtI2S52OKK9aCYBz0vwpAb8PswiItI2S52OKK9aCYBz0((rlGpvYcrWKOnBUnkjbWl3NOOPoAQlsXLkSOyrLZZBY7YQfvn4fg8xrvaFQKfIGjH(q4deJ7nGGIED0keT3acIiGbJOnHmCh96OviASeTa(ujleXjH(q4deJ7nGGI23pAb8PswiItI2S52OKeaVCFII23pAb8PswicMeTzZTrjj7b4K3YORSE0c4tLSqeNeTzZTrjj7b4K3YOPoAF)O9gqqebmyeTjKTrjJED0keTa(ujleXjH(q4deJ7nGGIED0c4tLSqeNeTzZTrjj7b4K3YORSE0c4tLSqemjAZMBJss2dWjVLrVoAb8PswiItI2S52OKeaVCFIIUIrt1ORoATzZTrjjcyWiAtiaE5(ef96O1Mn3gLKiGbJOnHa4L7tu0vgnMoiAF)OfWNkzHiys0Mn3gLKShGtElJUIrt1ORoATzZTrjjcyWiAtiaE5(efn1r77hTCa4SqKFHXfdF)C0vhT2S52OKebmyeTjeaVCFIIM6O99JglrlGpvYcrWKqFi8bIX9gqqrVoAfIwaFQKfI4KqFi8bIX9gqqrVoAfI2BabreWGr0Mq2gLmAF)OfWNkzHiojAZMBJssa8Y9jk6kJMQrtD0RJwHO1Mn3gLKiGbJOnHa4L7tu0vgnMoiAF)OfWNkzHiojAZMBJssa8Y9jk6kgnvJUYO1Mn3gLKiGbJOnHa4L7tu0uhTVF0yjAb8PswiItc9HWhig3Babf96OviASeTa(ujleXjH(q4AZMBJsgTVF0c4tLSqeNeTzZTrjj7b4K3YORSE0c4tLSqemjAZMBJss2dWjVLr77hTa(ujleXjrB2CBuscGxUprrtD0uxupT8wwufWNkzbZIuCXHSOyrLZZBY7YQfvn4fg8xr1BabreWGr0MqgUJ23pAVbeeradgrBczBuYOxhT2S52OKebmyeTjeaVCFIIUYOX0br77hn0dNwWb8Y9jk6QJwB2CBusIagmI2ecGxUprf1tlVLf1bIXFHxqfP4IdrrXIkNN3K3LvlQNwEllQ6BoXpT8wIpFKuuNpsWZBHlQ6nQifxOskkwu588M8USArvdEHb)vupT8WY4CYlpJIU6OPII6PL3YIQ(Mt8tlVL4Zhjf15Je88w4IksksXfNoOOyrLZZBY7YQfvn4fg8xr90YdlJZjV8mk6kJgZI6PL3YIQ(Mt8tlVL4Zhjf15Je88w4IQaETseTjOIuKIQBaRTfVtkkwCXzrXI6PL3YIQNjYK34qZdBEt5t44IH1plQCEEtExwTifxWSOyrLZZBY7YQfvn4fg8xrfmsgYaWzcYgtidaNX5fpgGiCEEtExupT8wwuLdGlGZDrkUqffflQCEEtExwTO6gW6dj4YVWfvNoOOEA5TSOUTH3KXLZDrvdEHb)vupT8WY4CYlpJIUYODgTVF0yjATblNxkeLyd(lJED0yjA5MCkeyT5KXMW55n5DrkU4WfflQCEEtExwTOQbVWG)kQNwEyzCo5LNrrxD0ur0RJwHOXs0AdwoVuikXg8xg96OXs0Yn5uiWAZjJnHZZBY7O99J(0YdlJZjV8mk6QJgZOPUOEA5TSOE)cVXr0MuKIluTOyrLZZBY7YQfvn4fg8xr90YdlJZjV8mk6kJgZO99JwHO1gSCEPquIn4VmAF)OLBYPqG1MtgBcNN3K3rtD0RJ(0YdlJZjV8mk66rJzr90YBzrfj8TXghrBsrksrvVrfflU4SOyrLZZBY7YQfvn4fg8xr1BabreWGr0MqgUJ23pAOhoTGd4L7tu0vhTtQOOEA5TSO6Xaedu(j8IuCbZIIfvopVjVlRwu1GxyWFfvVbeeradgrBcz4oAF)OHE40coGxUprrxD0oRWI6PL3YIQ30Sno0aGDrkUqffflQCEEtExwTOQbVWG)kQEdiiIagmI2eYWD0((rd9WPfCaVCFIIU6ODwHf1tlVLf1l1msa3exFZzrkU4WfflQCEEtExwTOQbVWG)kQEdiiIagmI2eYWD0((rd9WPfCaVCFIIU6OPskQNwEllQqpG9MMTlsXfQwuSOY55n5Dz1IQg8cd(RO6nGGicyWiAtiBJswupT8wwuNpCAbHdZASHVWPuKIlvyrXIkNN3K3LvlQAWlm4VIQ3acIiGbJOnHSnkzr90YBzr17GJBq4c41krfP4IdzrXIkNN3K3LvlQAWlm4VIQ3acIiGbJOnHmCh96O9gqqeVPz75ajKH7O99J2BabreWGr0MqgUJED0YbGZcHMVPqtCRLORoAmDq0((rd9WPfCaVCFIIU6OXSclQNwEllQUn5TSifPOIKIIfxCwuSOY55n5Dz1IQg8cd(ROk3KtHGe(2yJdz6bIW55n5D0RJwHODdyyXHR3eNeKW3gBCeTjrVoAVbeebj8TXghY0debWl3NOORoAQgTVF0Ediics4BJnoKPhiY2OKrtDr90YBzrfj8TXghrBsrkUGzrXI6PL3YIQYFoXr0Muu588M8USArkUqffflQCEEtExwTOQbVWG)kQAdwoVuikXg8xg96O1Mn3gLKayKLN8jC8damkeaVCFIIU6OHR3r77hnwIwBWY5Lcrj2G)YOxhnwIwBWY5LcjF40co0Xr77hT2GLZlfs(WPfCOJJED0keT2S52OKek)CJJC)GxqeaVCFIIU6OHR3r77hT2S52OKebmyeTjeaVCFIIUYOPkvJM6O99JwoaCwiYVW4IHVFo6QJ2jvlQNwEllQBB4nzC5CxKIloCrXIkNN3K3LvlQNwEllQqZdWfvn4fg8xrvoaUao3KH7OxhnyKmKbGZeKnMqgaoJZlEmar488M8UOo)KX17IkMuTifxOArXIkNN3K3LvlQAWlm4VIkyKmKbGZeKnMqgaoJZlEmar488M8o61rlhaxaNBcGxUprrxD0W17OxhT2S52OKeO5bycGxUprrxD0W17I6PL3YIQCaCbCUlsXLkSOyr90YBzrLXQ7PHEyzCeTjfvopVjVlRwKIloKfflQNwEllQu(5gh5(bVGkQCEEtExwTifxCikkwupT8wwuHMh28ghrBsrLZZBY7YQfP4cvsrXIkNN3K3LvlQAWlm4VIkKPhOODmA9HeCadNZORoAitpqKLdRf1tlVLf1nFcnUM(ucULIuCXPdkkwupT8wwup8LbyZaCdcxdmkOIkNN3K3LvlsXfNolkwupT8wwubmYYt(eo(bagLIkNN3K3LvlsXfNywuSOY55n5Dz1IQg8cd(ROQq0EdiicGrwEYNWXpaWOqgUJ23pASeT2GLZlfIsSb)Lr77hTCtofYKf6BIJOnbr488M8oAQJED0keT3acI4gW6hX4iAtqKTrjJ23pASeTCtofIM(xogC4iAtiCEEtEhTVF0NwEyzCo5LNrrxD0ygn1f1tlVLfvyT5KXUifxCsffflQCEEtExwTOQbVWG)kQEdiiIBaRFeJJOnbr2gLmAF)O9gqqeaJS8KpHJFaGrHmChTVF0EdiicLFUXrUFWliYWD0((r7nGGiWAZjJnz4o61rFA5HLX5KxEgfDLr7SOEA5TSOkGbJOnPifxC6WfflQCEEtExwTOQbVWG)kQGrYqgaotqda8pHJJOnbr488M8o61rl3KtHGeaFlZpzcNN3K3rVoAfIwB2CBuscGrwEYNWXpaWOqa8Y9jk6kJ2PdI23pASeT2GLZlfIsSb)Lr77hTCtofYKf6BIJOnbr488M8oAQlQNwEllQGZ9VXHEaxKIloPArXIkNN3K3LvlQNwEllQ3VWBCeTjfvn4fg8xr1BabrCdy9JyCeTjiY2OKr77hTcr7nGGicyWiAtid3r77hn0yoXbSM(aWzC5x4ORoA46D0ogT(qcU8lC0uh96OviASeTCtofIM(xogC4iAtiCEEtEhTVF0NwEyzCo5LNrrxD0ygn1r77hT3acIiGxRehrBcIa4L7tu0vgnJvwpegx(fo61rFA5HLX5KxEgfDLr7SOQXwpzC5aWzbvCXzrkU4Sclkwu588M8USArvdEHb)vuviATzZTrjjagz5jFch)aaJcbWl3NOORmANoiAF)OXs0AdwoVuikXg8xgTVF0Yn5uitwOVjoI2eeHZZBY7OPo61rdz6bkAhJwFibhWW5m6QJgY0dez5WA0RJwHO9gqqebmyeTjKTrjJ23pASenyKmKbGZe(Gpz5MwIWfWGXHm9ar488M8oAQJED0keT3acISTH3KXLZnzBuYO99JwUjNcbja(wMFYeopVjVJM6I6PL3YIk4C)BCOhWfP4IthYIIfvopVjVlRwu1GxyWFfvVbeeXnG1pIXr0MGid3r77hnKPhOORmATHKODm6tlVLK7x4noI2eI2qsr90YBzrvt)lhdoCeTjfP4IthIIIfvopVjVlRwu1GxyWFfvVbeeXnG1pIXr0MGid3r77hnKPhOORmATHKODm6tlVLK7x4noI2eI2qsr90YBzr9a6lzCeTjfP4ItQKIIfvopVjVlRwupT8wwurmWnNcos(eErvdEHb)vubmeGr0N3KJED0YbGZcr(fgxm89Zrxz07b4K3YIQgB9KXLdaNfuXfNfP4cMoOOyrLZZBY7YQfvn4fg8xr90YdlJZjV8mk6kJ2zr90YBzr17aGdoxKIly6SOyrLZZBY7YQfvn4fg8xrvHO1Mn3gLKayKLN8jC8damkeaVCFIIUYOD6GOxhnyKmKbGZe0aa)t44iAtqeopVjVJ23pASeT2GLZlfIsSb)Lr77hTCtofYKf6BIJOnbr488M8oAQJED0qMEGI2XO1hsWbmCoJU6OHm9arwoSg96OviAVbeezBdVjJlNBY2OKr77hTCtofcsa8Tm)KjCEEtEhn1f1tlVLfvW5(34qpGlsXfmXSOyr90YBzrfj8TXghrBsrLZZBY7YQfPifPOcldqVLfxW0by60bubMolQuoq(jCurfMjvkmBxQaxG5u1OJwrAo6FXTbKOHmq01eWRvIOnbvlAatLnEaVJgzlC03qSLt4D0A6lHZisGrv(KJ2zvJgMSewgi8o6AYn5uiWOw0IfDn5MCkeyq488M8Uw0k4eRutcmQYNC0urvJgMSewgi8o6AGrYqgaotGrTOfl6AGrYqgaotGbHZZBY7ArRGtSsnjWOkFYr7WvnAyYsyzGW7ORbgjdza4mbg1IwSORbgjdza4mbgeopVjVRf9jr7q5qxLOvWjwPMeyuLp5ODiQA0WKLWYaH3rxtUjNcbg1IwSORj3KtHadcNN3K31I(KODOCORs0k4eRutcmQYNC0oDw1OHjlHLbcVJUMCtofcmQfTyrxtUjNcbgeopVjVRfTcoXk1KaJQ8jhTtNvnAyYsyzGW7ORbgjdza4mbg1IwSORbgjdza4mbgeopVjVRfTcoXk1KaJQ8jhTthUQrdtwcldeEhDn5MCkeyulAXIUMCtofcmiCEEtExlAfCIvQjbgv5toANoCvJgMSewgi8o6AGrYqgaotGrTOfl6AGrYqgaotGbHZZBY7ArRaMyLAsGrv(KJ2jvRA0WKLWYaH3rxtUjNcbg1IwSORj3KtHadcNN3K31IwbNyLAsGrGbmtQuy2UubUaZPQrhTI0C0)IBdirdzGORTzOBmLArdyQSXd4D0iBHJ(gITCcVJwtFjCgrcmQYNC0yw1OHjlHLbcVJUgyKmKbGZeyulAXIUgyKmKbGZeyq488M8Uw0k4eRutcmQYNC0yw1OHjlHLbcVJUgyKmKbGZeyulAXIUgyKmKbGZeyq488M8Uw0k4eRutcmQYNC0yw1OHjlHLbcVJUM2Y94fcmQfTyrxtB5E8cbgeopVjVRfTcoXk1KaJQ8jhnMvnAyYsyzGW7ORHSX07Znbg1IwSORHSX07ZnbgeopVjVRfTcoXk1KaJQ8jhnvRA0WKLWYaH3rxtaFQKfItcmQfTyrxtaFQKfI4KaJArRqfIvQjbgv5toAQw1OHjlHLbcVJUMa(ujlemjWOw0IfDnb8PswicMeyulAfCsfyLAsGrv(KJUcRA0WKLWYaH3rxtaFQKfItcmQfTyrxtaFQKfI4KaJArRGtQaRutcmQYNC0vyvJgMSewgi8o6Ac4tLSqWKaJArlw01eWNkzHiysGrTOvOcXk1KaJadyMuPWSDPcCbMtvJoAfP5O)f3gqIgYarxZnG12I3j1IgWuzJhW7Or2ch9neB5eEhTM(s4mIeyuLp5OXSQrdtwcldeEhDnWizidaNjWOw0IfDnWizidaNjWGW55n5DTOpjAhkh6QeTcoXk1KaJQ8jhnvu1OHjlHLbcVJUMCtofcmQfTyrxtUjNcbgeopVjVRf9jr7q5qxLOvWjwPMeyuLp5OD4QgnmzjSmq4D01KBYPqGrTOfl6AYn5uiWGW55n5DTOvWjwPMeyuLp5OPAvJgMSewgi8o6AYn5uiWOw0IfDn5MCkeyq488M8Uw0k4eRutcmcmGzsLcZ2LkWfyovn6OvKMJ(xCBajAideDnKulAatLnEaVJgzlC03qSLt4D0A6lHZisGrv(KJ2zvJgMSewgi8o6AYn5uiWOw0IfDn5MCkeyq488M8Uw0k4eRutcmQYNC0oCvJgMSewgi8o6AGrYqgaotGrTOfl6AGrYqgaotGbHZZBY7ArFs0ouo0vjAfCIvQjbgv5toAQw1OHjlHLbcVJUgyKmKbGZeyulAXIUgyKmKbGZeyq488M8Uw0k4eRutcmQYNC0oXSQrdtwcldeEhDn5MCkeyulAXIUMCtofcmiCEEtExlAfWeRutcmQYNC0oD4QgnmzjSmq4D01KBYPqGrTOfl6AYn5uiWGW55n5DTOvatSsnjWOkFYr70HRA0WKLWYaH3rxdmsgYaWzcmQfTyrxdmsgYaWzcmiCEEtExlAfCIvQjbgv5toANuTQrdtwcldeEhDn5MCkeyulAXIUMCtofcmiCEEtExlAfCIvQjbgv5toANvyvJgMSewgi8o6AYn5uiWOw0IfDn5MCkeyq488M8Uw0kGjwPMeyuLp5ODwHvnAyYsyzGW7ORbgjdza4mbg1IwSORbgjdza4mbgeopVjVRfTcoXk1KaJQ8jhnMoRA0WKLWYaH3rxtUjNcbg1IwSORj3KtHadcNN3K31IwbmXk1KaJQ8jhnMoRA0WKLWYaH3rxdmsgYaWzcmQfTyrxdmsgYaWzcmiCEEtExlAfCIvQjbgbgvWIBdi8oAQg9PL3YONpsqKaJIkYnRlUGjvD4IQBGb9tUOcZdZhnm3dOeTCjI(DhnmdJuyqGbmpmF0uPUb)mAmDnAmDaModmcmoT8wIiUbS2w8oXX6R4zIm5no08WM3u(eoUyy9ZaJtlVLiIBaRTfVtCS(kYbWfW521hQoyKmKbGZeKnMqgaoJZlEmafyCA5TerCdyTT4DIJ1xzBdVjJlNBxDdy9HeC5x46oDGRpu9tlpSmoN8YZOkD67JfTblNxkeLyd(lxJf5MCkeyT5KXoW40YBjI4gWABX7ehRVY9l8ghrBIRpu9tlpSmoN8YZOQPI1kGfTblNxkeLyd(lxJf5MCkeyT5KX23)0YdlJZjV8mQAmPoW40YBjI4gWABX7ehRVcs4BJnoI2exFO6NwEyzCo5LNrvIPVVcAdwoVuikXg8x67l3KtHaRnNm2uV(0YdlJZjV8mQoMbgbgNwElrowFfTnsHb4iAtcmoT8wICS(kABKcdWr0M468tgxVRtfoW1hQoyKmKbGZee7MEqLJWDdm98wo5T03hzJP3NBs(yFiCXSjc3T9il99vqB5E8cbWWYa0nXniCidiJKxJfWizidaNji2n9GkhH7gy65TCYBj1bgNwElrowFfbCjv24Npv(NWXr0MeyaZhnmJioAH(rrBz0AZMBJsg9df9l1qrl0C0woXoAlR4aXKORaOOX2grtFWYrFPj0miAlR4aXrt5f6OVONwcNbrRnBUnkPRrJKtRmAH(KOP8cD0kcgmI2KOPqZz0cn)GO1Mn3gLefT2sO5RfxJgzrt5Ej6rk)m6xQHI2YO1Mn3gLmAXIEG4Of6h5A0MqZakpIJwBP85GJwSOhioAlJwB2CBussGXPL3sKJ1xzGy8x4fxZBHRVb8THEaJdlJq8mWaMp6kakAHMJwaFQKLOPpu0x0wwXbIJ2Bab5A0iStD0VenLxOJwrWGr0MqIUcGIwOyrFaoATT4MLpHhnKbI(IwrWGr0Menc7u7A0dehTqZrJeGLWzq0wwXbIJMHGyTqIUcGI(YOTSIdehT3ack6hfnGVn2r7nKOV0eAgensawcNbrBzfhioAVbeu0u(5m6BISO94Ob8TXoApSJwO5OLFHJwrWGr0MeT2wyu0ENwz0geu0AZMBJs6A0deh9lr)qrl0C0i6dW7OfWNkzjATzZTrjJMIL1KO)uyaed4OP8cD0cnh9WT2w(eE0kcgmI2KOryNAs0vau0xgTLvCG4O9gqqrRTXChThh9aX7OVChns(5mATTWr7DALrdzGOVOHgYaWrRiyWiAtCn6bIJ(fs0vau0x0PLv0BabfTLvCG4OFu0a(2y7A0deh9lr)qr)s0uSSMe9NcdGyahnLxOJ2TjCk)nJ2YkoqC0Ediiu0ca7pHhTyrRiyWiAtIgHDQJ2ar)qrl0C0MqZGOfWNkzj6hL1KOVmAlR4aXUg9JI(IoTSIEdiOOTSIdehnLxOJ(IEAjCgeT2S52OKUgTbI(rznjAaFBSjrxbqrl0C0qpCAj6hfnC7t4rlw0CUJ2JHmahn22aeDYyvIwrWGr0M4A0WSgijAKCaj6b6t4rlGpvYckAXIE5uYrJgaoAHMXoA4Se9aXBsGXPL3sKJ1xraFQKfNU(q1fWNkzH4KqFi8bIX9gqqRvWBabreWGr0MqgUxRaweWNkzHGjH(q4deJ7nGG89fWNkzHGjrB2CBuscGxUpr((c4tLSqCs0Mn3gLKShGtElRSUa(ujlemjAZMBJss2dWjVLu777nGGicyWiAtiBJsUwbb8PswiysOpe(aX4EdiO1c4tLSqWKOnBUnkjzpaN8wwzDb8PswiojAZMBJss2dWjVLRfWNkzHGjrB2CBuscGxUprvKQvRnBUnkjradgrBcbWl3NO1AZMBJsseWGr0Mqa8Y9jQsmDGVVa(ujleNeTzZTrjj7b4K3Yks1Q1Mn3gLKiGbJOnHa4L7te1((YbGZcr(fgxm89ZvRnBUnkjradgrBcbWl3NiQ99XIa(ujleNe6dHpqmU3acATcc4tLSqWKqFi8bIX9gqqRvWBabreWGr0Mq2gL03xaFQKfcMeTzZTrjjaE5(evjvPETcAZMBJsseWGr0Mqa8Y9jQsmDGVVa(ujlemjAZMBJssa8Y9jQIuTsTzZTrjjcyWiAtiaE5(erTVpweWNkzHGjH(q4deJ7nGGwRaweWNkzHGjH(q4AZMBJs67lGpvYcbtI2S52OKK9aCYBzL1fWNkzH4KOnBUnkjzpaN8w67lGpvYcbtI2S52OKeaVCFIOM6aJtlVLihRVIa(ujly66dvxaFQKfcMe6dHpqmU3acATcEdiiIagmI2eYW9AfWIa(ujleNe6dHpqmU3acY3xaFQKfItI2S52OKeaVCFI89fWNkzHGjrB2CBusYEao5TSY6c4tLSqCs0Mn3gLKShGtElP233BabreWGr0Mq2gLCTcc4tLSqCsOpe(aX4EdiO1c4tLSqCs0Mn3gLKShGtElRSUa(ujlemjAZMBJss2dWjVLRfWNkzH4KOnBUnkjbWl3NOks1Q1Mn3gLKiGbJOnHa4L7t0ATzZTrjjcyWiAtiaE5(evjMoW3xaFQKfcMeTzZTrjj7b4K3Yks1Q1Mn3gLKiGbJOnHa4L7te1((YbGZcr(fgxm89ZvRnBUnkjradgrBcbWl3NiQ99XIa(ujlemj0hcFGyCVbe0AfeWNkzH4KqFi8bIX9gqqRvWBabreWGr0Mq2gL03xaFQKfItI2S52OKeaVCFIQKQuVwbTzZTrjjcyWiAtiaE5(evjMoW3xaFQKfItI2S52OKeaVCFIQivRuB2CBusIagmI2ecGxUpru77Jfb8Pswioj0hcFGyCVbe0AfWIa(ujleNe6dHRnBUnkPVVa(ujleNeTzZTrjj7b4K3YkRlGpvYcbtI2S52OKK9aCYBPVVa(ujleNeTzZTrjjaE5(ern1bgNwElrowFLbIXFHxqU(q19gqqebmyeTjKHBFFVbeeradgrBczBuY1AZMBJsseWGr0Mqa8Y9jQsmDGVp0dNwWb8Y9jQATzZTrjjcyWiAtiaE5(efyCA5Te5y9v03CIFA5TeF(iX18w466nkW40YBjYX6ROV5e)0YBj(8rIR5TW1rIRpu9tlpSmoN8YZOQPIaJtlVLihRVI(Mt8tlVL4ZhjUM3cxxaVwjI2eKRpu9tlpSmoN8YZOkXmWiW40YBjIO3O6EmaXaLFc31hQU3acIiGbJOnHmC77d9WPfCaVCFIQ2jveyCA5Ter0BKJ1xXBA2ghAaW21hQU3acIiGbJOnHmC77d9WPfCaVCFIQ2zfgyCA5Ter0BKJ1x5snJeWnX13C66dv3BabreWGr0MqgU99HE40coGxUprv7ScdmoT8wIi6nYX6Ra9a2BA221hQU3acIiGbJOnHmC77d9WPfCaVCFIQMkjW40YBjIO3ihRVY8HtliCywJn8fofxFO6EdiiIagmI2eY2OKbgNwElre9g5y9v8o44geUaETsKRpuDVbeeradgrBczBuYaJtlVLiIEJCS(kUn5T01hQU3acIiGbJOnHmCV2Babr8MMTNdKqgU999gqqebmyeTjKH71YbGZcHMVPqtCRLQX0b((qpCAbhWl3NOQXScdmcmoT8wIiiPos4BJnoI2exFO6Yn5uiiHVn24qMEGwRGBadloC9M4KGe(2yJJOnzT3acIGe(2yJdz6bIa4L7tu1u133BabrqcFBSXHm9ar2gLK6aJtlVLicsCS(kk)5ehrBsGXPL3sebjowFLTn8MmUCUD9HQRny58sHOeBWF5ATzZTrjjagz5jFch)aaJcbWl3NOQHR3((yrBWY5Lcrj2G)Y1yrBWY5LcjF40co0X((AdwoVui5dNwWHoETcAZMBJssO8ZnoY9dEbra8Y9jQA46TVV2S52OKebmyeTjeaVCFIQKQuLAFF5aWzHi)cJlg((5QDs1aJtlVLicsCS(kqZdWUo)KX176ysvxFO6YbWfW5MmCVgmsgYaWzcYgtidaNX5fpgGcmoT8wIiiXX6RihaxaNBxFO6GrYqgaotq2ycza4moV4Xa0A5a4c4Cta8Y9jQA469ATzZTrjjqZdWeaVCFIQgUEhyCA5TerqIJ1xHXQ7PHEyzCeTjbgNwElreK4y9vO8ZnoY9dEbfyCA5TerqIJ1xbAEyZBCeTjbgNwElreK4y9v28j04A6tj4wC9HQdz6bYr9HeCadNZQHm9arwoSgyCA5TerqIJ1x5WxgGndWniCnWOGcmoT8wIiiXX6RayKLN8jC8damkbgNwElreK4y9vG1MtgBxFO6k4nGGiagz5jFch)aaJcz423hlAdwoVuikXg8x67l3KtHmzH(M4iAtquVwbVbeeXnG1pIXr0MGiBJs67Jf5MCken9VCm4Wr0M47FA5HLX5KxEgvnMuhyCA5TerqIJ1xradgrBIRpuDVbeeXnG1pIXr0MGiBJs677nGGiagz5jFch)aaJcz4233BabrO8ZnoY9dEbrgU999gqqeyT5KXMmCV(0YdlJZjV8mQsNbgNwElreK4y9vaN7FJd9a21hQoyKmKbGZe0aa)t44iAtqRLBYPqqcGVL5N8Af0Mn3gLKayKLN8jC8damkeaVCFIQ0Pd89XI2GLZlfIsSb)L((Yn5uitwOVjoI2ee1bgNwElreK4y9vUFH34iAtCvJTEY4YbGZcQUtxFO6EdiiIBaRFeJJOnbr2gL03xbVbeeradgrBcz423hAmN4awtFa4mU8lC1W1Bh1hsWLFHPETcyrUjNcrt)lhdoCeTj((NwEyzCo5LNrvJj1((EdiiIaETsCeTjicGxUprvYyL1dHXLFHxFA5HLX5KxEgvPZaJtlVLicsCS(kGZ9VXHEa76dvxbTzZTrjjagz5jFch)aaJcbWl3NOkD6aFFSOny58sHOeBWFPVVCtofYKf6BIJOnbr9AitpqoQpKGdy4CwnKPhiYYH11k4nGGicyWiAtiBJs67JfWizidaNj8bFYYnTeHlGbJdz6bI61k4nGGiBB4nzC5Ct2gL03xUjNcbja(wMFYuhyCA5TerqIJ1xrt)lhdoCeTjU(q19gqqe3aw)ighrBcImC77dz6bQsTHehpT8wsUFH34iAtiAdjbgNwElreK4y9voG(sghrBIRpuDVbeeXnG1pIXr0MGid3((qMEGQuBiXXtlVLK7x4noI2eI2qsGXPL3sebjowFfedCZPGJKpH7QgB9KXLdaNfuDNU(q1bmeGr0N3Kxlhaole5xyCXW3px5Eao5TmW40YBjIGehRVI3bahC21hQ(PLhwgNtE5zuLodmoT8wIiiXX6Rao3)gh6bSRpuDf0Mn3gLKayKLN8jC8damkeaVCFIQ0Pdwdgjdza4mbnaW)eooI2eKVpw0gSCEPquIn4V03xUjNczYc9nXr0MGOEnKPhih1hsWbmCoRgY0dez5W6Af8gqqKTn8MmUCUjBJs67l3KtHGeaFlZpzQdmoT8wIiiXX6RGe(2yJJOnjWiW40YBjIiGxRerBcQos4BJnoI2exFO6Yn5uiiHVn24qMEGw)jo08HtlR9gqqeKW3gBCitpqeaVCFIQMQbgNwElreb8ALiAtqowFLTn8MmUCUD9HQRny58sHOeBWF5ATzZTrjjagz5jFch)aaJcbWl3NOQHR3((yrBWY5Lcrj2G)Y1yrBWY5LcjF40co0X((AdwoVui5dNwWHoETcAZMBJssO8ZnoY9dEbra8Y9jQA46TVV2S52OKebmyeTjeaVCFIQKQuLAFF5aWzHi)cJlg((5QD6GaJtlVLiIaETseTjihRVICaCbCUD9HQdgjdza4mbzJjKbGZ48IhdqRLdGlGZnbWl3NOQHR3R1Mn3gLKanpata8Y9jQA46DGXPL3seraVwjI2eKJ1xbAEa215NmUExhtQ66dvxoaUao3KH71GrYqgaotq2ycza4moV4XauGXPL3seraVwjI2eKJ1xHXQ7PHEyzCeTjbgNwElreb8ALiAtqowFfk)CJJC)GxqbgNwElreb8ALiAtqowFfaJS8KpHJFaGrjW40YBjIiGxRerBcYX6RaRnNm2U(q19gqqeaJS8KpHJFaGrHmC77JfTblNxkeLyd(l99LBYPqMSqFtCeTjOaJtlVLiIaETseTjihRVI3bahCoW40YBjIiGxRerBcYX6RiGbJOnjW40YBjIiGxRerBcYX6Rao3)gh6bSRpuDWizidaNjOba(NWXr0MGwRG2S52OKeaJS8KpHJFaGrHa4L7tuLoDGVpw0gSCEPquIn4V03xUjNczYc9nXr0MGOET3acIiGxRehrBcIa4L7tuL1zSY6HW4YVWbgNwElreb8ALiAtqowFL7x4noI2ex1yRNmUCa4SGQ701hQU3acIiGxRehrBcIa4L7tuL1zSY6HW4YVWRvWBabrCdy9JyCeTjiY2OK((qJ5ehWA6daNXLFHRwFibx(f2r46TVV3acIiGbJOnHmCtDGXPL3seraVwjI2eKJ1xzZNqJRPpLGBX1hQoKPhih1hsWbmCoRgY0dez5WAGXPL3seraVwjI2eKJ1xbCU)no0dyxFO6kOnBUnkjbWilp5t44hayuiaE5(evPthSgmsgYaWzcAaG)jCCeTjiFFSOny58sHOeBWFPVpwaJKHmaCMGga4FchhrBcY3xUjNczYc9nXr0MGOET3acIiGxRehrBcIa4L7tuL1zSY6HW4YVWbgNwElreb8ALiAtqowFLLXuEeTjU(q19gqqeb8AL4iAtqKTrj999gqqe3aw)ighrBcImCVgY0duLAdjoEA5TKC)cVXr0Mq0gswRawKBYPq00)YXGdhrBIV)PLhwgNtE5zuLub1bgNwElreb8ALiAtqowFfn9VCm4Wr0M46dv3BabrCdy9JyCeTjiYW9AitpqvQnK44PL3sY9l8ghrBcrBiz9PLhwgNtE5zu1oCGXPL3seraVwjI2eKJ1xr5pN4iAtC9HQ7nGGiB(24m2mzBuYaJtlVLiIaETseTjihRVYHVmaBgGBq4AGrbfyCA5TereWRvIOnb5y9vGMh28ghrBsGXPL3seraVwjI2eKJ1xbXa3Ck4i5t4UQXwpzC5aWzbv3PRpuDadbye95n5aJtlVLiIaETseTjihRVYYykpI2exFO6qMEGQuBiXXtlVLK7x4noI2eI2qsGXPL3seraVwjI2eKJ1xbj8TXghrBsrksPa]] )


end