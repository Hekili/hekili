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


    spec:RegisterPack( "Marksmanship", 20210321, [[dKKRwbqiOepcjrSjLuFsszuKGtHK6vubZIkPBjjYUq8lLedJkKJrfTmqLNHKW0KeLRHK02KevFdjrACijQohOq16KK08KK6EsQ2NKWbbfswOsspeuWfPcf9rqHuJeui4KuHQvcQAMssCtQqP2jvIFsfkzPGcfpLKMkj0vbfc9vqHOXckAVs8xOAWsDyvwmv5XKAYk1LrTzq(mumAK60QA1GcLEnjA2k62kXUf9BkdNk1XPcfwoWZHmDIRRW2bL(osmEOKopuQ1JKOmFQQ9lCXzrXI6(eU4cCocoNoIkGZjboNurLrfuTOky7MlQUpTYddxuZBHlQo2hqjA5se97UO6(WEA3UOyrfzdGMlQujrtlIBuvxzfmVqp8iABzf0VmMN8wQbhKSc6x0Ruu9g)uC8S4vu3NWfxGZrW50rubCojW5KkQmQaUI6neAduuv)fyOOs)7nNfVI6Mr6IQJ9buIwUer)UJggHrkmiG3X(aA6OHZPRrdNJGZzrD(ibvuSOkGxRerBcQOyXfNfflQCEEtExwTOQbVWG)kQYn5uiiHVn24qMEGiCEEtEh96O)ehA(yOLOxhT3acIGe(2yJdz6bIa4L7tu0vhnvlQNwEllQiHVn24iAtksXf4kkwu588M8USArvdEHb)vu1gSCEPquIn4Vm61rRnBUnkjbWilp5tm4hayuiaE5(efD1rJrVJ23pASeT2GLZlfIsSb)LrVoASeT2GLZlfs(yOfCOJJ23pATblNxkK8Xql4qhh96OviATzZTrjju(5gh5(bVGiaE5(efD1rJrVJ23pATzZTrjjcyWiAtiaE5(efDfrtvQgn1r77hTCamSqKFHXfdF)C0vhTthvupT8wwu32WBY4Y5UifxOIIIfvopVjVlRwu1GxyWFfvWizidGHjiBmHmaggNx8yaIW55n5D0RJwoaUao3eaVCFIIU6OXO3rVoATzZTrjjqZdWeaVCFIIU6OXO3f1tlVLfv5a4c4CxKIlvwrXIkNN3K3LvlQNwEllQqZdWfvn4fg8xrvoaUao3KH7OxhnyKmKbWWeKnMqgadJZlEmar488M8UOo)KX17IkCuTifxOArXI6PL3YIkJv3td9WY4iAtkQCEEtExwTifxQ8IIf1tlVLfvk)CJJC)GxqfvopVjVlRwKIluPfflQNwEllQagz5jFIb)aaJsrLZZBY7YQfP4cvErXIkNN3K3LvlQAWlm4VIQ3acIayKLN8jg8damkKH7O99JglrRny58sHOeBWFz0((rl3KtHmzH(M4iAtqeopVjVlQNwEllQWAZjJDrkUaJxuSOEA5TSO6DaWHHlQCEEtExwTifxC6OIIf1tlVLfvbmyeTjfvopVjVlRwKIloDwuSOY55n5Dz1IQg8cd(ROcgjdzammbnay(edoI2eeHZZBY7OxhTcrRnBUnkjbWilp5tm4hayuiaE5(efDfr70rr77hnwIwBWY5Lcrj2G)YO99JwUjNczYc9nXr0MGiCEEtEhn1rVoAVbeeraVwjoI2eebWl3NOOROE0mwz9qyC5x4I6PL3YIk4C)BCOhWfP4It4kkwu588M8USAr90YBzr9(fEJJOnPOQbVWG)kQEdiiIaETsCeTjicGxUprrxr9OzSY6HW4YVWrVoAfI2BabrCdy9JyCeTjiY2OKr77hn0yoXbSM(ayyC5x4ORoA9HeC5x4ODiAm6D0((r7nGGicyWiAtid3rtDrvJTEY4YbWWcQ4IZIuCXjvuuSOY55n5Dz1IQg8cd(ROcz6bkAhIwFibhWy4m6QJgY0dez5WAr90YBzrDZNqJRPpLGBPifxCwzfflQCEEtExwTOQbVWG)kQkeT2S52OKeaJS8KpXGFaGrHa4L7tu0veTthf96ObJKHmagMGgamFIbhrBcIW55n5D0((rJLO1gSCEPquIn4VmAF)OXs0GrYqgadtqdaMpXGJOnbr488M8oAF)OLBYPqMSqFtCeTjicNN3K3rtD0RJ2BabreWRvIJOnbra8Y9jk6kQhnJvwpegx(fUOEA5TSOco3)gh6bCrkU4KQfflQCEEtExwTOQbVWG)kQEdiiIaETsCeTjiY2OKr77hT3acI4gW6hX4iAtqKH7OxhnKPhOORiATHKODi6tlVLK7x4noI2eI2qs0RJwHOXs0Yn5uiA6F5yWHJOnHW55n5D0((rFA5HLX5KxEgfDfrtfrtDr90YBzrDzmLhrBsrkU4SYlkwu588M8USArvdEHb)vu9gqqe3aw)ighrBcImCh96OHm9afDfrRnKeTdrFA5TKC)cVXr0Mq0gsIED0NwEyzCo5LNrrxD0vwr90YBzrvt)lhdoCeTjfP4ItQ0IIfvopVjVlRwu1GxyWFfvVbeezZ3gNXMjBJswupT8wwuv(ZjoI2KIuCXjvErXI6PL3YI6HVmaBgGBq4AGrbvu588M8USArkU4egVOyr90YBzrfAEyZBCeTjfvopVjVlRwKIlW5OIIfvopVjVlRwupT8wwurmWnNcos(etrvdEHb)vubmeGr0N3KlQAS1tgxoagwqfxCwKIlW5SOyrLZZBY7YQfvn4fg8xrfY0du0veT2qs0oe9PL3sY9l8ghrBcrBiPOEA5TSOUmMYJOnPifxGdUIIf1tlVLfvKW3gBCeTjfvopVjVlRwKIuu3m0nMsrXIlolkwupT8wwu12ifgGJOnPOY55n5Dz1IuCbUIIfvopVjVlRwupT8wwu12ifgGJOnPOQbVWG)kQGrYqgadtqSB6bvgc3nW0ZB5K3scNN3K3r77hnYgtVp3K8X(q4IzteUB7rws488M8oAF)OviATL7Xleadldq3e3GWHmGmsMW55n5D0RJglrdgjdzammbXUPhuziC3atpVLtEljCEEtEhn1f15NmUExuPchvKIlurrXI6PL3YIQaU0Xy8ZNk7tm4iAtkQCEEtExwTifxQSIIfvopVjVlRwupT8wwu3a(2qpGXHLriEwu3msdE3YBzrfgrehTq)OOTmATzZTrjJ(HI(LAOOfAoAlNyhTLvAGys0oou0yBJOPpy5OV0eAgeTLvAG4OP8cD0x0tlXWGO1Mn3gL01OrYPvgTqFs0uEHoAfbdgrBs0uO5mAHMFq0AZMBJsIIwBj081IRrJSOPCVe9iLFg9l1qrBz0AZMBJsgTyrpqC0c9JCnAtOzaLhXrRTu(CWrlw0dehTLrRnBUnkjPOM3cxu3a(2qpGXHLriEwKIluTOyrLZZBY7YQf1tlVLfvb8PswCwu3msdE3YBzr1XHIwO5OfWNkzjA6df9fTLvAG4O9gqqUgnc7uh9lrt5f6OvemyeTjKODCOOfkw0hGJwBlUz5tmrdzGOVOvemyeTjrJWo1Ug9aXrl0C0ibyjggeTLvAG4OziiwlKODCOOVmAlR0aXr7nGGI(rrd4BJD0Edj6lnHMbrJeGLyyq0wwPbIJ2BabfnLFoJ(MilApoAaFBSJ2d7OfAoA5x4OvemyeTjrRTfgfT3PvgTbbfT2S52OKUg9aXr)s0pu0cnhnI(a8oAb8PswIwB2CBuYOPyznj6pfgaXaoAkVqhTqZrpCRTLpXeTIGbJOnjAe2PMeTJdf9LrBzLgioAVbeu0ABm3r7Xrpq8o6l3rJKFoJwBlC0ENwz0qgi6lAOHmaC0kcgmI2exJEG4OFHeTJdf9fDAzL8gqqrBzLgio6hfnGVn2Ug9aXr)s0pu0VenflRjr)PWaigWrt5f6ODBcNYFZOTSsdehT3accfTaW(tmrlw0kcgmI2KOryN6Onq0pu0cnhTj0miAb8PswI(rznj6lJ2YknqSRr)OOVOtlRK3ackAlR0aXrt5f6OVONwIHbrRnBUnkPRrBGOFuwtIgW3gBs0oou0cnhn0JHwI(rrJX(et0IfnN7O9yidWrJTnarNmwLOvemyeTjUgnm2bsIgjhqIEG(et0c4tLSGIwSOxoLC0ObGJwOzSJgdlrpq8Muu1GxyWFfvb8PswiItc9HWhig3Babf96OviAVbeeradgrBcz4o61rRq0yjAb8PswicCe6dHpqmU3ackAF)OfWNkzHiWr0Mn3gLKa4L7tu0((rlGpvYcrCs0Mn3gLKShGtElJUI6rlGpvYcrGJOnBUnkjzpaN8wgn1r77hT3acIiGbJOnHSnkz0RJwHOfWNkzHiWrOpe(aX4EdiOOxhTa(ujleboI2S52OKK9aCYBz0vupAb8PswiItI2S52OKK9aCYBz0RJwaFQKfIahrB2CBuscGxUprrxPOPA0vhT2S52OKebmyeTjeaVCFIIED0AZMBJsseWGr0Mqa8Y9jk6kIgohfTVF0c4tLSqeNeTzZTrjj7b4K3YORu0un6QJwB2CBusIagmI2ecGxUprrtD0((rlhadle5xyCXW3phD1rRnBUnkjradgrBcbWl3NOOPoAF)OXs0c4tLSqeNe6dHpqmU3ack61rRq0c4tLSqe4i0hcFGyCVbeu0RJwHO9gqqebmyeTjKTrjJ23pAb8PswicCeTzZTrjjaE5(efDfrt1OPo61rRq0AZMBJsseWGr0Mqa8Y9jk6kIgohfTVF0c4tLSqe4iAZMBJssa8Y9jk6kfnvJUIO1Mn3gLKiGbJOnHa4L7tu0uhTVF0yjAb8PswicCe6dHpqmU3ack61rRq0yjAb8PswicCe6dHRnBUnkz0((rlGpvYcrGJOnBUnkjzpaN8wgDf1JwaFQKfI4KOnBUnkjzpaN8wgTVF0c4tLSqe4iAZMBJssa8Y9jkAQJM6IuCPYlkwu588M8USArvdEHb)vufWNkzHiWrOpe(aX4EdiOOxhTcr7nGGicyWiAtid3rVoAfIglrlGpvYcrCsOpe(aX4EdiOO99JwaFQKfI4KOnBUnkjbWl3NOO99JwaFQKfIahrB2CBusYEao5Tm6kQhTa(ujleXjrB2CBusYEao5TmAQJ23pAVbeeradgrBczBuYOxhTcrlGpvYcrCsOpe(aX4EdiOOxhTa(ujleXjrB2CBusYEao5Tm6kQhTa(ujleboI2S52OKK9aCYBz0RJwaFQKfI4KOnBUnkjbWl3NOORu0un6QJwB2CBusIagmI2ecGxUprrVoATzZTrjjcyWiAtiaE5(efDfrdNJI23pAb8PswicCeTzZTrjj7b4K3YORu0un6QJwB2CBusIagmI2ecGxUprrtD0((rlhadle5xyCXW3phD1rRnBUnkjradgrBcbWl3NOOPoAF)OXs0c4tLSqe4i0hcFGyCVbeu0RJwHOfWNkzHioj0hcFGyCVbeu0RJwHO9gqqebmyeTjKTrjJ23pAb8PswiItI2S52OKeaVCFIIUIOPA0uh96OviATzZTrjjcyWiAtiaE5(efDfrdNJI23pAb8PswiItI2S52OKeaVCFIIUsrt1ORiATzZTrjjcyWiAtiaE5(efn1r77hnwIwaFQKfI4KqFi8bIX9gqqrVoAfIglrlGpvYcrCsOpeU2S52OKr77hTa(ujleXjrB2CBusYEao5Tm6kQhTa(ujleboI2S52OKK9aCYBz0((rlGpvYcrCs0Mn3gLKa4L7tu0uhn1f1tlVLfvb8PswGRifxOslkwu588M8USArvdEHb)vu9gqqebmyeTjKH7O99J2BabreWGr0Mq2gLm61rRnBUnkjradgrBcbWl3NOORiA4Cu0((rd9yOfCaVCFIIU6O1Mn3gLKiGbJOnHa4L7tur90YBzrDGy8x4furkUqLxuSOY55n5Dz1I6PL3YIQ(Mt8tlVL4Zhjf15Je88w4IQEJksXfy8IIfvopVjVlRwu1GxyWFf1tlpSmoN8YZOORoAQOOEA5TSOQV5e)0YBj(8rsrD(ibpVfUOIKIuCXPJkkwu588M8USArvdEHb)vupT8WY4CYlpJIUIOHROEA5TSOQV5e)0YBj(8rsrD(ibpVfUOkGxRerBcQifPO6gWABX7KIIfxCwuSOEA5TSO6zIm5no08WM3u(edUyy9ZIkNN3K3LvlsXf4kkwu588M8USArvdEHb)vubJKHmagMGSXeYayyCEXJbicNN3K3f1tlVLfv5a4c4CxKIlurrXIkNN3K3LvlQUbS(qcU8lCr1PJkQNwEllQBB4nzC5Cxu1GxyWFf1tlpSmoN8YZOORiANr77hnwIwBWY5Lcrj2G)YOxhnwIwUjNcbwBozSjCEEtExKIlvwrXIkNN3K3LvlQAWlm4VI6PLhwgNtE5zu0vhnve96OviASeT2GLZlfIsSb)LrVoASeTCtofcS2CYyt488M8oAF)OpT8WY4CYlpJIU6OHlAQlQNwEllQ3VWBCeTjfP4cvlkwu588M8USArvdEHb)vupT8WY4CYlpJIUIOHlAF)OviATblNxkeLyd(lJ23pA5MCkeyT5KXMW55n5D0uh96OpT8WY4CYlpJIUE0WvupT8wwurcFBSXr0MuKIuu1BurXIlolkwu588M8USArvdEHb)vu9gqqebmyeTjKH7O99Jg6Xql4aE5(efD1r7KkkQNwEllQEmaXaLFIPifxGROyrLZZBY7YQfvn4fg8xr1BabreWGr0MqgUJ23pAOhdTGd4L7tu0vhTZkVOEA5TSO6nnBJdnayxKIlurrXIkNN3K3LvlQAWlm4VIQ3acIiGbJOnHmChTVF0qpgAbhWl3NOORoANvEr90YBzr9snJeWnX13CwKIlvwrXIkNN3K3LvlQAWlm4VIQ3acIiGbJOnHmChTVF0qpgAbhWl3NOORoAy8I6PL3YIk0dyVPz7IuCHQfflQCEEtExwTOQbVWG)kQEdiiIagmI2eY2OKf1tlVLf15JHwq4WyhBmlCkfP4sLxuSOY55n5Dz1IQg8cd(RO6nGGicyWiAtiBJswupT8wwu9om4geUaETsurkUqLwuSOY55n5Dz1IQg8cd(RO6nGGicyWiAtid3rVoAVbeeXBA2Eoqcz4oAF)O9gqqebmyeTjKH7OxhTCamSqO5Bk0e3Aj6QJgohfTVF0qpgAbhWl3NOORoA4Q8I6PL3YIQBtEllsrkQiPOyXfNfflQCEEtExwTOQbVWG)kQYn5uiiHVn24qMEGiCEEtEh96OviA3agwCm6nXjbj8TXghrBs0RJ2BabrqcFBSXHm9ara8Y9jk6QJMQr77hT3acIGe(2yJdz6bISnkz0uxupT8wwurcFBSXr0MuKIlWvuSOEA5TSOQ8NtCeTjfvopVjVlRwKIlurrXIkNN3K3LvlQAWlm4VIQ2GLZlfIsSb)LrVoATzZTrjjagz5jFIb)aaJcbWl3NOORoAm6D0((rJLO1gSCEPquIn4Vm61rJLO1gSCEPqYhdTGdDC0((rRny58sHKpgAbh64OxhTcrRnBUnkjHYp34i3p4febWl3NOORoAm6D0((rRnBUnkjradgrBcbWl3NOORiAQs1OPoAF)OLdGHfI8lmUy47NJU6ODs1I6PL3YI62gEtgxo3fP4sLvuSOY55n5Dz1I6PL3YIk08aCrvdEHb)vuLdGlGZnz4o61rdgjdzammbzJjKbWW48IhdqeopVjVlQZpzC9UOchvlsXfQwuSOY55n5Dz1IQg8cd(ROcgjdzammbzJjKbWW48IhdqeopVjVJED0YbWfW5Ma4L7tu0vhng9o61rRnBUnkjbAEaMa4L7tu0vhng9UOEA5TSOkhaxaN7IuCPYlkwupT8wwuzS6EAOhwghrBsrLZZBY7YQfP4cvArXI6PL3YIkLFUXrUFWlOIkNN3K3LvlsXfQ8IIf1tlVLfvO5HnVXr0Muu588M8USArkUaJxuSOY55n5Dz1IQg8cd(ROcz6bkAhIwFibhWy4m6QJgY0dez5WAr90YBzrDZNqJRPpLGBPifxC6OIIf1tlVLf1dFza2ma3GW1aJcQOY55n5Dz1IuCXPZIIf1tlVLfvaJS8KpXGFaGrPOY55n5Dz1IuCXjCfflQCEEtExwTOQbVWG)kQkeT3acIayKLN8jg8damkKH7O99JglrRny58sHOeBWFz0((rl3KtHmzH(M4iAtqeopVjVJM6OxhTcr7nGGiUbS(rmoI2eezBuYO99Jglrl3KtHOP)LJbhoI2ecNN3K3r77h9PLhwgNtE5zu0vhnCrtDr90YBzrfwBozSlsXfNurrXIkNN3K3LvlQAWlm4VIQ3acI4gW6hX4iAtqKTrjJ23pAVbeebWilp5tm4hayuid3r77hT3acIq5NBCK7h8cImChTVF0EdiicS2CYytgUJED0NwEyzCo5LNrrxr0olQNwEllQcyWiAtksXfNvwrXIkNN3K3LvlQAWlm4VIkyKmKbWWe0aG5tm4iAtqeopVjVJED0Yn5uiibW3Y8tMW55n5D0RJwHO1Mn3gLKayKLN8jg8damkeaVCFIIUIOD6OO99JglrRny58sHOeBWFz0((rl3KtHmzH(M4iAtqeopVjVJM6I6PL3YIk4C)BCOhWfP4ItQwuSOY55n5Dz1I6PL3YI69l8ghrBsrvdEHb)vu9gqqe3aw)ighrBcISnkz0((rRq0EdiiIagmI2eYWD0((rdnMtCaRPpaggx(fo6QJgJEhTdrRpKGl)chn1rVoAfIglrl3KtHOP)LJbhoI2ecNN3K3r77h9PLhwgNtE5zu0vhnCrtD0((r7nGGic41kXr0MGiaE5(efDfrZyL1dHXLFHJED0NwEyzCo5LNrrxr0olQAS1tgxoagwqfxCwKIloR8IIfvopVjVlRwu1GxyWFfvfIwB2CBuscGrwEYNyWpaWOqa8Y9jk6kI2PJI23pASeT2GLZlfIsSb)Lr77hTCtofYKf6BIJOnbr488M8oAQJED0qMEGI2HO1hsWbmgoJU6OHm9arwoSg96OviAVbeeradgrBczBuYO99JglrdgjdzammHpmtwUPLiCbmyCitpqeopVjVJM6OxhTcr7nGGiBB4nzC5Ct2gLmAF)OLBYPqqcGVL5NmHZZBY7OPUOEA5TSOco3)gh6bCrkU4KkTOyrLZZBY7YQfvn4fg8xr1BabrCdy9JyCeTjiYWD0((rdz6bk6kIwBijAhI(0YBj5(fEJJOnHOnKuupT8wwu10)YXGdhrBsrkU4KkVOyrLZZBY7YQfvn4fg8xr1BabrCdy9JyCeTjiYWD0((rdz6bk6kIwBijAhI(0YBj5(fEJJOnHOnKuupT8wwupG(sghrBsrkU4egVOyrLZZBY7YQf1tlVLfvedCZPGJKpXuu1GxyWFfvadbye95n5OxhTCamSqKFHXfdF)C0ve9Eao5TSOQXwpzC5ayybvCXzrkUaNJkkwu588M8USArvdEHb)vupT8WY4CYlpJIUIODwupT8wwu9oa4WWfP4cColkwu588M8USArvdEHb)vuviATzZTrjjagz5jFIb)aaJcbWl3NOORiANok61rdgjdzammbnay(edoI2eeHZZBY7O99JglrRny58sHOeBWFz0((rl3KtHmzH(M4iAtqeopVjVJM6OxhnKPhOODiA9HeCaJHZORoAitpqKLdRrVoAfI2Babr22WBY4Y5MSnkz0((rl3KtHGeaFlZpzcNN3K3rtDr90YBzrfCU)no0d4IuCbo4kkwupT8wwurcFBSXr0Muu588M8USArksrkQWYa0BzXf4CeCoDev4iQ0IkLdKFIbvuHrcJcgJloUlWORA0rRinh9V42as0qgi6Ac41kr0MGQfnGDmgpG3rJSfo6Bi2Yj8oAn9LyyejGVkFYr7SQrddwcldeEhDn5MCkeywlAXIUMCtofcmjCEEtExlAfCIvQjb8v5toAQOQrddwcldeEhDnWizidGHjWSw0IfDnWizidGHjWKW55n5DTOvWjwPMeWxLp5ORSQgnmyjSmq4D01aJKHmagMaZArlw01aJKHmagMatcNN3K31I(KODmDSQs0k4eRutc4RYNC0u5vnAyWsyzGW7ORj3KtHaZArlw01KBYPqGjHZZBY7ArFs0oMowvjAfCIvQjb8v5toANoRA0WGLWYaH3rxtUjNcbM1IwSORj3KtHatcNN3K31IwbNyLAsaFv(KJ2PZQgnmyjSmq4D01aJKHmagMaZArlw01aJKHmagMatcNN3K31IwbNyLAsaFv(KJ2zLv1OHblHLbcVJUMCtofcmRfTyrxtUjNcbMeopVjVRfTcoXk1Ka(Q8jhTZkRQrddwcldeEhDnWizidGHjWSw0IfDnWizidGHjWKW55n5DTOvaoSsnjGVkFYr7KQvnAyWsyzGW7ORj3KtHaZArlw01KBYPqGjHZZBY7ArRGtSsnjGpGhgjmkymU44UaJUQrhTI0C0)IBdirdzGORTzOBmLArdyhJXd4D0iBHJ(gITCcVJwtFjggrc4RYNC0Wv1OHblHLbcVJUgyKmKbWWeywlAXIUgyKmKbWWeys488M8Uw0k4eRutc4RYNC0Wv1OHblHLbcVJUgyKmKbWWeywlAXIUgyKmKbWWeys488M8Uw0k4eRutc4RYNC0Wv1OHblHLbcVJUM2Y94fcmRfTyrxtB5E8cbMeopVjVRfTcoXk1Ka(Q8jhnCvnAyWsyzGW7ORHSX07ZnbM1IwSORHSX07ZnbMeopVjVRfTcoXk1Ka(Q8jhnvRA0WGLWYaH3rxtaFQKfItcmRfTyrxtaFQKfI4KaZArRqLJvQjb8v5toAQw1OHblHLbcVJUMa(ujle4iWSw0IfDnb8PswicCeywlAfCsfyLAsaFv(KJUYRA0WGLWYaH3rxtaFQKfItcmRfTyrxtaFQKfI4KaZArRGtQaRutc4RYNC0vEvJggSewgi8o6Ac4tLSqGJaZArlw01eWNkzHiWrGzTOvOYXk1Ka(aEyKWOGX4IJ7cm6QgD0ksZr)lUnGenKbIUMBaRTfVtQfnGDmgpG3rJSfo6Bi2Yj8oAn9LyyejGVkFYrdxvJggSewgi8o6AGrYqgadtGzTOfl6AGrYqgadtGjHZZBY7ArFs0oMowvjAfCIvQjb8v5toAQOQrddwcldeEhDn5MCkeywlAXIUMCtofcmjCEEtExl6tI2X0XQkrRGtSsnjGVkFYrxzvnAyWsyzGW7ORj3KtHaZArlw01KBYPqGjHZZBY7ArRGtSsnjGVkFYrt1QgnmyjSmq4D01KBYPqGzTOfl6AYn5uiWKW55n5DTOvWjwPMeWhWdJegfmgxCCxGrx1OJwrAo6FXTbKOHmq01qsTObSJX4b8oAKTWrFdXwoH3rRPVedJib8v5toANvnAyWsyzGW7ORj3KtHaZArlw01KBYPqGjHZZBY7ArRGtSsnjGVkFYrxzvnAyWsyzGW7ORbgjdzammbM1IwSORbgjdzammbMeopVjVRf9jr7y6yvLOvWjwPMeWxLp5OPAvJggSewgi8o6AGrYqgadtGzTOfl6AGrYqgadtGjHZZBY7ArRGtSsnjGVkFYr7eUQgnmyjSmq4D01KBYPqGzTOfl6AYn5uiWKW55n5DTOvaoSsnjGVkFYr7SYQA0WGLWYaH3rxtUjNcbM1IwSORj3KtHatcNN3K31Iwb4Wk1Ka(Q8jhTZkRQrddwcldeEhDnWizidGHjWSw0IfDnWizidGHjWKW55n5DTOvWjwPMeWxLp5ODs1QgnmyjSmq4D01KBYPqGzTOfl6AYn5uiWKW55n5DTOvWjwPMeWxLp5ODw5vnAyWsyzGW7ORj3KtHaZArlw01KBYPqGjHZZBY7ArRaCyLAsaFv(KJ2zLx1OHblHLbcVJUgyKmKbWWeywlAXIUgyKmKbWWeys488M8Uw0k4eRutc4RYNC0W5SQrddwcldeEhDn5MCkeywlAXIUMCtofcmjCEEtExlAfGdRutc4RYNC0W5SQrddwcldeEhDnWizidGHjWSw0IfDnWizidGHjWKW55n5DTOvWjwPMeWhW74lUnGW7OPA0NwElJE(ibrc4lQUbg0p5Ikvcvs0o2hqjA5se97oAyegPWGaEQeQKODSpGMoA4C6A0W5i4CgWhWFA5TerCdyTT4DId1xXZezYBCO5HnVP8jgCXW6Nb8NwElre3awBlEN4q9vKdGlGZTRpuDWizidGHjiBmHmaggNx8yakG)0YBjI4gWABX7ehQVY2gEtgxo3U6gW6dj4YVW1D6ixFO6NwEyzCo5LNrv403hlAdwoVuikXg8xUglYn5uiWAZjJDa)PL3seXnG12I3jouFL7x4noI2exFO6NwEyzCo5LNrvtfRvalAdwoVuikXg8xUglYn5uiWAZjJTV)PLhwgNtE5zu1WrDa)PL3seXnG12I3jouFfKW3gBCeTjU(q1pT8WY4CYlpJQaoFFf0gSCEPquIn4V03xUjNcbwBozSPE9PLhwgNtE5zuD4c4d4pT8wICO(kABKcdWr0MeWFA5Te5q9v02ifgGJOnX15NmUExNkCKRpuDWizidGHji2n9GkdH7gy65TCYBPVpYgtVp3K8X(q4IzteUB7rw67RG2Y94fcGHLbOBIBq4qgqgjVglGrYqgadtqSB6bvgc3nW0ZB5K3sQd4pT8wICO(kc4shJXpFQSpXGJOnjGNkjAyerC0c9JI2YO1Mn3gLm6hk6xQHIwO5OTCID0wwPbIjr74qrJTnIM(GLJ(stOzq0wwPbIJMYl0rFrpTeddIwB2CBusxJgjNwz0c9jrt5f6OvemyeTjrtHMZOfA(brRnBUnkjkATLqZxlUgnYIMY9s0Ju(z0VudfTLrRnBUnkz0If9aXrl0pY1OnHMbuEehT2s5ZbhTyrpqC0wgT2S52OKKa(tlVLihQVYaX4VWlUM3cxFd4Bd9aghwgH4zapvs0oou0cnhTa(ujlrtFOOVOTSsdehT3acY1OryN6OFjAkVqhTIGbJOnHeTJdfTqXI(aC0ABXnlFIjAide9fTIGbJOnjAe2P21OhioAHMJgjalXWGOTSsdehndbXAHeTJdf9LrBzLgioAVbeu0pkAaFBSJ2BirFPj0miAKaSeddI2YknqC0EdiOOP8Zz03ezr7Xrd4BJD0EyhTqZrl)chTIGbJOnjATTWOO9oTYOniOO1Mn3gL01Ohio6xI(HIwO5Or0hG3rlGpvYs0AZMBJsgnflRjr)PWaigWrt5f6OfAo6HBTT8jMOvemyeTjrJWo1KODCOOVmAlR0aXr7nGGIwBJ5oApo6bI3rF5oAK8Zz0ABHJ270kJgYarFrdnKbGJwrWGr0M4A0deh9lKODCOOVOtlRK3ackAlR0aXr)OOb8TX21Ohio6xI(HI(LOPyznj6pfgaXaoAkVqhTBt4u(BgTLvAG4O9gqqOOfa2FIjAXIwrWGr0Menc7uhTbI(HIwO5OnHMbrlGpvYs0pkRjrFz0wwPbIDn6hf9fDAzL8gqqrBzLgioAkVqh9f90smmiATzZTrjDnAde9JYAs0a(2ytI2XHIwO5OHEm0s0pkAm2NyIwSO5ChThdzaoASTbi6KXQeTIGbJOnX1OHXoqs0i5as0d0NyIwaFQKfu0If9YPKJgnaC0cnJD0yyj6bI3Ka(tlVLihQVIa(ujloD9HQlGpvYcXjH(q4deJ7nGGwRG3acIiGbJOnHmCVwbSiGpvYcboc9HWhig3Bab57lGpvYcboI2S52OKeaVCFI89fWNkzH4KOnBUnkjzpaN8wwrDb8PswiWr0Mn3gLKShGtElP233BabreWGr0Mq2gLCTcc4tLSqGJqFi8bIX9gqqRfWNkzHahrB2CBusYEao5TSI6c4tLSqCs0Mn3gLKShGtElxlGpvYcboI2S52OKeaVCFIQevRwB2CBusIagmI2ecGxUprR1Mn3gLKiGbJOnHa4L7tufW5iFFb8PswiojAZMBJss2dWjVLvIQvRnBUnkjradgrBcbWl3NiQ99LdGHfI8lmUy47NRwB2CBusIagmI2ecGxUpru77Jfb8Pswioj0hcFGyCVbe0AfeWNkzHahH(q4deJ7nGGwRG3acIiGbJOnHSnkPVVa(ujle4iAZMBJssa8Y9jQcQs9Af0Mn3gLKiGbJOnHa4L7tufW5iFFb8PswiWr0Mn3gLKa4L7tuLOAfAZMBJsseWGr0Mqa8Y9jIAFFSiGpvYcboc9HWhig3BabTwbSiGpvYcboc9HW1Mn3gL03xaFQKfcCeTzZTrjj7b4K3YkQlGpvYcXjrB2CBusYEao5T03xaFQKfcCeTzZTrjjaE5(ern1b8NwElrouFfb8PswGZ1hQUa(ujle4i0hcFGyCVbe0Af8gqqebmyeTjKH71kGfb8Pswioj0hcFGyCVbeKVVa(ujleNeTzZTrjjaE5(e57lGpvYcboI2S52OKK9aCYBzf1fWNkzH4KOnBUnkjzpaN8wsTVV3acIiGbJOnHSnk5AfeWNkzH4KqFi8bIX9gqqRfWNkzH4KOnBUnkjzpaN8wwrDb8PswiWr0Mn3gLKShGtElxlGpvYcXjrB2CBuscGxUprvIQvRnBUnkjradgrBcbWl3NO1AZMBJsseWGr0Mqa8Y9jQc4CKVVa(ujle4iAZMBJss2dWjVLvIQvRnBUnkjradgrBcbWl3NiQ99LdGHfI8lmUy47NRwB2CBusIagmI2ecGxUpru77Jfb8PswiWrOpe(aX4EdiO1kiGpvYcXjH(q4deJ7nGGwRG3acIiGbJOnHSnkPVVa(ujleNeTzZTrjjaE5(evbvPETcAZMBJsseWGr0Mqa8Y9jQc4CKVVa(ujleNeTzZTrjjaE5(evjQwH2S52OKebmyeTjeaVCFIO23hlc4tLSqCsOpe(aX4EdiO1kGfb8Pswioj0hcxB2CBusFFb8PswiojAZMBJss2dWjVLvuxaFQKfcCeTzZTrjj7b4K3sFFb8PswiojAZMBJssa8Y9jIAQd4pT8wICO(kdeJ)cVGC9HQ7nGGicyWiAtid3((EdiiIagmI2eY2OKR1Mn3gLKiGbJOnHa4L7tufW5iFFOhdTGd4L7tu1AZMBJsseWGr0Mqa8Y9jkG)0YBjYH6ROV5e)0YBj(8rIR5TW11Bua)PL3sKd1xrFZj(PL3s85JexZBHRJexFO6NwEyzCo5LNrvtfb8NwElrouFf9nN4NwElXNpsCnVfUUaETseTjixFO6NwEyzCo5LNrvaxaFa)PL3serVr19yaIbk)eJRpuDVbeeradgrBcz423h6Xql4aE5(evTtQiG)0YBjIO3ihQVI30Sno0aGTRpuDVbeeradgrBcz423h6Xql4aE5(evTZkpG)0YBjIO3ihQVYLAgjGBIRV501hQU3acIiGbJOnHmC77d9yOfCaVCFIQ2zLhWFA5Ter0BKd1xb6bS30STRpuDVbeeradgrBcz423h6Xql4aE5(evnmEa)PL3serVrouFL5JHwq4WyhBmlCkU(q19gqqebmyeTjKTrjd4pT8wIi6nYH6R4DyWniCb8ALixFO6EdiiIagmI2eY2OKb8NwElre9g5q9vCBYBPRpuDVbeeradgrBcz4ET3acI4nnBphiHmC777nGGicyWiAtid3RLdGHfcnFtHM4wlvdNJ89HEm0coGxUprvdxLhWhWFA5TerqsDKW3gBCeTjU(q1LBYPqqcFBSXHm9aTwb3agwCm6nXjbj8TXghrBYAVbeebj8TXghY0debWl3NOQPQVV3acIGe(2yJdz6bISnkj1b8NwElreK4q9vu(ZjoI2Ka(tlVLicsCO(kBB4nzC5C76dvxBWY5Lcrj2G)Y1AZMBJssamYYt(ed(bagfcGxUprvJrV99XI2GLZlfIsSb)LRXI2GLZlfs(yOfCOJ991gSCEPqYhdTGdD8Af0Mn3gLKq5NBCK7h8cIa4L7tu1y0BFFTzZTrjjcyWiAtiaE5(evbvPk1((YbWWcr(fgxm89Zv7KQb8NwElreK4q9vGMhGDD(jJR31HJQU(q1LdGlGZnz4EnyKmKbWWeKnMqgadJZlEmafWFA5TerqId1xroaUao3U(q1bJKHmagMGSXeYayyCEXJbO1YbWfW5Ma4L7tu1y071AZMBJssGMhGjaE5(evng9oG)0YBjIGehQVcJv3td9WY4iAtc4pT8wIiiXH6Rq5NBCK7h8ckG)0YBjIGehQVc08WM34iAtc4pT8wIiiXH6RS5tOX10NsWT46dvhY0dKd6dj4agdNvdz6bISCynG)0YBjIGehQVYHVmaBgGBq4AGrbfWFA5TerqId1xbWilp5tm4hayuc4pT8wIiiXH6RaRnNm2U(q1vWBabramYYt(ed(bagfYWTVpw0gSCEPquIn4V03xUjNczYc9nXr0MGOETcEdiiIBaRFeJJOnbr2gL03hlYn5uiA6F5yWHJOnX3)0YdlJZjV8mQA4OoG)0YBjIGehQVIagmI2exFO6EdiiIBaRFeJJOnbr2gL033BabramYYt(ed(bagfYWTVV3acIq5NBCK7h8cImC777nGGiWAZjJnz4E9PLhwgNtE5zufod4pT8wIiiXH6Rao3)gh6bSRpuDWizidGHjObaZNyWr0MGwl3KtHGeaFlZp51kOnBUnkjbWilp5tm4hayuiaE5(evHth57JfTblNxkeLyd(l99LBYPqMSqFtCeTjiQd4pT8wIiiXH6RC)cVXr0M4QgB9KXLdGHfuDNU(q19gqqe3aw)ighrBcISnkPVVcEdiiIagmI2eYWTVp0yoXbSM(ayyC5x4QXO3oOpKGl)ct9AfWICtofIM(xogC4iAt89pT8WY4CYlpJQgoQ999gqqeb8AL4iAtqeaVCFIQGXkRhcJl)cV(0YdlJZjV8mQcNb8NwElreK4q9vaN7FJd9a21hQUcAZMBJssamYYt(ed(bagfcGxUprv40r((yrBWY5Lcrj2G)sFF5MCkKjl03ehrBcI61qMEGCqFibhWy4SAitpqKLdRRvWBabreWGr0Mq2gL03hlGrYqgadt4dZKLBAjcxadghY0de1RvWBabr22WBY4Y5MSnkPVVCtofcsa8Tm)KPoG)0YBjIGehQVIM(xogC4iAtC9HQ7nGGiUbS(rmoI2eez423hY0dufAdjoCA5TKC)cVXr0Mq0gsc4pT8wIiiXH6RCa9LmoI2exFO6EdiiIBaRFeJJOnbrgU99Hm9avH2qIdNwElj3VWBCeTjeTHKa(tlVLicsCO(kig4MtbhjFIXvn26jJlhadlO6oD9HQdyiaJOpVjVwoagwiYVW4IHVFUI9aCYBza)PL3sebjouFfVdaomSRpu9tlpSmoN8YZOkCgWFA5TerqId1xbCU)no0dyxFO6kOnBUnkjbWilp5tm4hayuiaE5(evHthTgmsgYayycAaW8jgCeTjiFFSOny58sHOeBWFPVVCtofYKf6BIJOnbr9AitpqoOpKGdymCwnKPhiYYH11k4nGGiBB4nzC5Ct2gL03xUjNcbja(wMFYuhWFA5TerqId1xbj8TXghrBsaFa)PL3seraVwjI2euDKW3gBCeTjU(q1LBYPqqcFBSXHm9aT(tCO5JHww7nGGiiHVn24qMEGiaE5(evnvd4pT8wIic41kr0MGCO(kBB4nzC5C76dvxBWY5Lcrj2G)Y1AZMBJssamYYt(ed(bagfcGxUprvJrV99XI2GLZlfIsSb)LRXI2GLZlfs(yOfCOJ991gSCEPqYhdTGdD8Af0Mn3gLKq5NBCK7h8cIa4L7tu1y0BFFTzZTrjjcyWiAtiaE5(evbvPk1((YbWWcr(fgxm89Zv70rb8NwElreb8ALiAtqouFf5a4c4C76dvhmsgYayycYgtidGHX5fpgGwlhaxaNBcGxUprvJrVxRnBUnkjbAEaMa4L7tu1y07a(tlVLiIaETseTjihQVc08aSRZpzC9UoCu11hQUCaCbCUjd3RbJKHmagMGSXeYayyCEXJbOa(tlVLiIaETseTjihQVcJv3td9WY4iAtc4pT8wIic41kr0MGCO(ku(5gh5(bVGc4pT8wIic41kr0MGCO(kagz5jFIb)aaJsa)PL3seraVwjI2eKd1xbwBozSD9HQ7nGGiagz5jFIb)aaJcz423hlAdwoVuikXg8x67l3KtHmzH(M4iAtqb8NwElreb8ALiAtqouFfVdaomCa)PL3seraVwjI2eKd1xradgrBsa)PL3seraVwjI2eKd1xbCU)no0dyxFO6GrYqgadtqdaMpXGJOnbTwbTzZTrjjagz5jFIb)aaJcbWl3NOkC6iFFSOny58sHOeBWFPVVCtofYKf6BIJOnbr9AVbeeraVwjoI2eebWl3NOkQZyL1dHXLFHd4pT8wIic41kr0MGCO(k3VWBCeTjUQXwpzC5ayybv3PRpuDVbeeraVwjoI2eebWl3NOkQZyL1dHXLFHxRG3acI4gW6hX4iAtqKTrj99HgZjoG10hadJl)cxT(qcU8lSdy0BFFVbeeradgrBcz4M6a(tlVLiIaETseTjihQVYMpHgxtFkb3IRpuDitpqoOpKGdymCwnKPhiYYH1a(tlVLiIaETseTjihQVc4C)BCOhWU(q1vqB2CBuscGrwEYNyWpaWOqa8Y9jQcNoAnyKmKbWWe0aG5tm4iAtq((yrBWY5Lcrj2G)sFFSagjdzammbnay(edoI2eKVVCtofYKf6BIJOnbr9AVbeeraVwjoI2eebWl3NOkQZyL1dHXLFHd4pT8wIic41kr0MGCO(klJP8iAtC9HQ7nGGic41kXr0MGiBJs677nGGiUbS(rmoI2eez4EnKPhOk0gsC40YBj5(fEJJOnHOnKSwbSi3KtHOP)LJbhoI2eF)tlpSmoN8YZOkOcQd4pT8wIic41kr0MGCO(kA6F5yWHJOnX1hQU3acI4gW6hX4iAtqKH71qMEGQqBiXHtlVLK7x4noI2eI2qY6tlpSmoN8YZOQRSa(tlVLiIaETseTjihQVIYFoXr0M46dv3Babr28TXzSzY2OKb8NwElreb8ALiAtqouFLdFza2ma3GW1aJckG)0YBjIiGxRerBcYH6RanpS5noI2Ka(tlVLiIaETseTjihQVcIbU5uWrYNyCvJTEY4YbWWcQUtxFO6agcWi6ZBYb8NwElreb8ALiAtqouFLLXuEeTjU(q1Hm9avH2qIdNwElj3VWBCeTjeTHKa(tlVLiIaETseTjihQVcs4BJnoI2KIkYnRlUahvRSIuKsb]] )

end