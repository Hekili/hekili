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

    
    spec:RegisterSetting( "prevent_hardcasts", false, {
        name = "Prevent Hardcasts of |T135130:0|t Aimed Shot During Movement",
        desc = "If checked, the addon will not recommend |T135130:0|t Aimed Shot if it has a cast time and you are moving.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Marksmanship", 20201208, [[dOKr6aqiQK6rqvv2eIYNuGrPGCkQQ6vqLMfPk3sbv1UO0VivAyuOCmQslJkXZGQktJubxJcvBJQk6BuvHghPI05ivuwhvsMhPQUhfSpOuDqsfQwifYdvqzIKkexKuHYhjvuzKKkQYjvqLvsLAMuvPBsvfyNqv(jPIyPkOkpfHPcLCvsfv1xHQQQXcvL9I0Fb1GboSKftrpMKjROlJAZs5Zk0OjLtR0QPQc61iQMTuDBQy3Q8BHHJihhQQklhYZv10jUoiBNQY3PkgpukNhQy9KkKMpuSFrt9sXIsmlHP45IXCXyEDXy6uRxDMo41fJtjeCiXucsLI8AKPex5Wuc)Gcr(7u3RTKOeKkC6rnPyrj(acPykb(lbAIq6DLU6oUIgKPvfo6(RduVKnofQAIU)6O0LsycTDz4oQjLywctXZfJ5IX86IX0PwV6mDWRl6aLOGeTarjiwNHrj025KpQjLyYVIsG)sGFqHi)DQ71wsjqNh0jmkDJ)sGocRyhtgLaDQEjWfJ5IXOe99LNIfLqqRI8xlKNIffpVuSOe8vMDEsnIsOqRWOTOes15tSVW1eh4wOGElFLzNNjGSeShCRVJAscilbMqTM9fUM4a3cf0BrStT3Na9tGXPeLs24OeVW1eh4xleQqXZfkwuc(kZopPgrjuOvy0wucv4JV6el54G26sazjqfrFgEolI)4kzVr4cHcpwe7u79jq)emQMjadMe46eOcF8vNyjhh0wxcilbUobQWhF1j2Bh1e4wXjadMeOcF8vNyVDutGBfNaYsWqjqfrFgEoRNTpHFslAL3IyNAVpb6NGr1mbyWKave9z45SccIFTqSi2P27ta2tGXnEc8pbyWKaPqJSyL1HHLaEUCc0pbEngLOuYghLygqMDgwksuHIh(rXIsWxz25j1ikHcTcJ2IsGGoUfOr2(buVfOrgMDmz0B5Rm78mbKLaPqWcQizrStT3Na9tWOAMaYsGkI(m8C2wVqSfXo1EFc0pbJQjLOuYghLqkeSGksuHINoqXIsWxz25j1ikHcTcJ2IsifcwqfjlePeqwcqqh3c0iB)aQ3c0idZoMm6T8vMDEsjkLSXrjA9cXuHINXPyrjkLSXrjySrQh)6JHFTqOe8vMDEsnIku88tkwuIsjBCucpBFc)Kw0kpLGVYSZtQruHINFKIfLOuYghLaXFCLS3iCHqHhkbFLzNNuJOcfpDkflkrPKnokHVO3zCOe8vMDEsnIku80zuSOeLs24OeMfcvJmLGVYSZtQruHINxJrXIsukzJJsiii(1cHsWxz25j1iQqXZRxkwuc(kZopPgrjuOvy0wuctOwZkOvro8RfYBrStT3NaSBibm2yfKWWY6WjGSeGGoUfOr2(qOX9gHFTqElFLzNNjGSeyc1A2zaz2zyPizNHNJsukzJJsGks7eUTiMku886cflkbFLzNNuJOeLs24Oe16Wt4xlekHcTcJ2Isyc1AwbTkYHFTqElIDQ9(eGDdjGXgRGegwwhobKLGHsGjuRzjHy1(m8RfYBNHNlbyWKGguVdJyLwHgzyzD4eOFcu1lWY6Wja3emQMjadMeyc1AwbbXVwiwisjWFkHchvNHLcnYYtXZlvO45f)Oyrj4Rm78KAeLqHwHrBrjAHc6taUjqvVaJ4r(sG(jOfkO36uyJsukzJJsm5s0GvAf5OYHku88QduSOe8vMDEsnIsOqRWOTOeMqTMvqRIC4xlK3IyNAVpby3qcySXkiHHL1HPeLs24OeOI0oHBlIPcfpVgNIfLGVYSZtQrucfAfgTfLWeQ1ScAvKd)AH82z45sagmjWeQ1SKqSAFg(1c5TqKsazjOfkOpbypbQ4LeGBckLSXzR1HNWVwiwv8scilbdLaxNaP68jwL26umQGFTqS8vMDEMamysqPK1hdZh7S8NaSNa8lb(tjkLSXrjCG6Y(AHqfkEE9tkwuc(kZopPgrjuOvy0wuctOwZscXQ9z4xlK3crkbKLGwOG(eG9eOIxsaUjOuYgNTwhEc)AHyvXljGSeukz9XW8Xol)jq)eOduIsjBCucL26umQGFTqOcfpV(rkwuc(kZopPgrjuOvy0wuctOwZo5AcZ4W2z45OeLs24OeKV9o8RfcvO45vNsXIsukzJJsuWoqOjJGJgScfEEkbFLzNNuJOcfpV6mkwuIsjBCuIwVWHNWVwiuc(kZopPgrfkEUymkwuc(kZopPgrjkLSXrjEgrIpb(L9gPek0kmAlkbIBi(1kZotju4O6mSuOrwEkEEPcfpx8sXIsWxz25j1ikHcTcJ2Is0cf0NaSNav8scWnbLs24S16Wt4xleRkEHsukzJJs4a1L91cHku8CXfkwuIsjBCuIx4AId8RfcLGVYSZtQruHkuIj3kOUqXIINxkwuIsjBCucvaDcJGFTqOe8vMDEsnIku8CHIfLGVYSZtQruIsjBCucvaDcJGFTqOek0kmAlkbc64wGgz7ZK0G0rFysOq1lNs24S8vMDEMamysWhqDZ9M2BXPEyjI(dtk2pUeGbtcgkbQ4MqRyrSpg9vhoAWTajqhB5Rm78mbKLaxNae0XTanY2NjPbPJ(WKqHQxoLSXz5Rm78mb(tj67XWQjLa)mgvO4HFuSOe8vMDEsnIsCLdtjMiUMTfXW(4)5oLOuYghLyI4A2wed7J)N7uHINoqXIsWxz25j1ikHcTcJ2Isyc1AwbbXVwiwisjadMeyc1AwbbXVwi2z45sazjqfrFgEoRGG4xlelIDQ9(eG9e4IXsagmjOTJAcmIDQ9(eOFcur0NHNZkii(1cXIyNAVNsukzJJsa9m8kSZtfkEgNIfLGVYSZtQruIsjBCucv17WLs24G77luI((c8vomLqnFQqXZpPyrj4Rm78KAeLqHwHrBrjkLS(yy(yNL)eOFcWpkrPKnokHQ6D4sjBCW99fkrFFb(khMs8cvO45hPyrj4Rm78KAeLqHwHrBrjkLS(yy(yNL)eG9e4cLOuYghLqv9oCPKno4((cLOVVaFLdtje0Qi)1c5PcvOeKqSkCmlHIffpVuSOe8vMDEsnIsOqRWOTOeiOJBbAKTFa1BbAKHzhtg9w(kZopPeLs24OesHGfurIku8CHIfLGVYSZtQrucsiwvValRdtj8AmkrPKnokXmGm7mSuKOek0kmAlkrPK1hdZh7S8NaSNaVjadMe46eOcF8vNyjhh0wxcilbUobs15tS(IENXXYxz25jvO4HFuSOe8vMDEsnIsOqRWOTOeLswFmmFSZYFc0pb4xcilbdLaxNav4JV6el54G26sazjW1jqQoFI1x07mow(kZoptagmjOuY6JH5JDw(tG(jWLe4pLOuYghLOwhEc)AHqfkE6aflkbFLzNNuJOek0kmAlkrPK1hdZh7S8NaSNaxsagmjyOeOcF8vNyjhh0wxcWGjbs15tS(IENXXYxz25zc8pbKLGsjRpgMp2z5pbgsGluIsjBCuIx4AId8RfcvOcLqnFkwu88sXIsWxz25j1ikHcTcJ2Isyc1AwbbXVwiwisjadMe02rnbgXo1EFc0pbEXpkrPKnokHjJEgr(EJuHINluSOe8vMDEsnIsOqRWOTOeMqTMvqq8RfIfIucWGjbTDutGrStT3Na9tGx)KsukzJJsy2Jyc3Gq4qfkE4hflkbFLzNNuJOek0kmAlkHjuRzfee)AHyHiLamysqBh1eye7u79jq)e41pPeLs24Oe1P4xqvhwv9ovO4PduSOe8vMDEsnIsOqRWOTOeMqTMvqq8RfIfIucWGjbTDutGrStT3Na9tGoJsukzJJs0weB2JysfkEgNIfLGVYSZtQrucfAfgTfLWeQ1SccIFTqSZWZrjkLSXrj67OM8W(HqZrh(eQqXZpPyrj4Rm78KAeLqHwHrBrjmHAnRGG4xle7m8CuIsjBCucZAeoAWcAvK)uHINFKIfLGVYSZtQrucfAfgTfLWeQ1SccIFTqSqKsazjWeQ1SM9iMDOxSqKsagmjWeQ1SccIFTqSqKsazjqk0ilwnU6IMLKssG(jWfJLamysqBh1eye7u79jq)e4IFsjkLSXrjifYghvOcL4fkwu88sXIsWxz25j1ikHcTcJ2IsivNpX(cxtCGBHc6T8vMDEMaYsWqjGeI9bpQMwV2x4AId8RfscilbMqTM9fUM4a3cf0BrStT3Na9tGXtagmjWeQ1SVW1eh4wOGE7m8CjWFkrPKnokXlCnXb(1cHku8CHIfLOuYghLG8T3HFTqOe8vMDEsnIku8Wpkwuc(kZopPgrjuOvy0wucv4JV6el54G26sazjqfrFgEolI)4kzVr4cHcpwe7u79jq)emQMjadMe46eOcF8vNyjhh0wxcilbUobQWhF1j2Bh1e4wXjadMeOcF8vNyVDutGBfNaYsWqjqfrFgEoRNTpHFslAL3IyNAVpb6NGr1mbyWKave9z45SccIFTqSi2P27ta2tGXnEc8pbyWKaPqJSyL1HHLaEUCc0pbEnoLOuYghLygqMDgwksuHINoqXIsWxz25j1ikHcTcJ2IsifcwqfjlePeqwcqqh3c0iB)aQ3c0idZoMm6T8vMDEsjkLSXrjA9cXuHINXPyrj4Rm78KAeLqHwHrBrjqqh3c0iB)aQ3c0idZoMm6T8vMDEMaYsGuiybvKSi2P27tG(jyuntazjqfrFgEoBRxi2IyNAVpb6NGr1KsukzJJsifcwqfjQqXZpPyrjkLSXrjySrQh)6JHFTqOe8vMDEsnIku88JuSOeLs24OeE2(e(jTOvEkbFLzNNuJOcfpDkflkrPKnokrRx4Wt4xlekbFLzNNuJOcfpDgflkbFLzNNuJOek0kmAlkrluqFcWnbQ6fyepYxc0pbTqb9wNcBuIsjBCuIjxIgSsRihvouHINxJrXIsukzJJsuWoqOjJGJgScfEEkbFLzNNuJOcfpVEPyrjkLSXrjq8hxj7ncxiu4HsWxz25j1iQqXZRluSOe8vMDEsnIsOqRWOTOeMqTMLeIv7ZWVwiVDgEUeGbtcCDcKQZNyvARtXOc(1cXYxz25zcWGjbLswFmmFSZYFc0pbUqjkLSXrj8f9oJdvO45f)Oyrj4Rm78KAeLqHwHrBrjmHAnljeR2NHFTqE7m8CjadMeyc1Awe)XvYEJWfcfESqKsagmjWeQ1SE2(e(jTOvElePeGbtcmHAnRVO3zCSqKsazjOuY6JH5JDw(ta2tGxkrPKnokHGG4xleQqXZRoqXIsWxz25j1ikrPKnokrTo8e(1cHsOqRWOTOeMqTMLeIv7ZWVwiVDgEUeGbtcgkbMqTMvqq8RfIfIucWGjbnOEhgXkTcnYWY6Wjq)emQMja3eOQxGL1HtG)jGSemucCDcKQZNyvARtXOc(1cXYxz25zcWGjbLswFmmFSZYFc0pbUKa)tagmjWeQ1ScAvKd)AH8we7u79ja7jGXgRGegwwhobKLGsjRpgMp2z5pbypbEPekCuDgwk0ilpfpVuHINxJtXIsWxz25j1ikHcTcJ2Is0cf0NaCtGQEbgXJ8La9tqluqV1PWwcilbdLatOwZkii(1cXodpxcWGjbUobiOJBbAKTCn2zP6X9WccIHBHc6T8vMDEMa)tazjyOeyc1A2zaz2zyPizNHNlbyWKaP68j2xqC503JT8vMDEMa)PeLs24OeOI0oHBlIPcfpV(jflkbFLzNNuJOek0kmAlkHjuRzjHy1(m8RfYBHiLamysqluqFcWEcuXlja3eukzJZwRdpHFTqSQ4fkrPKnokHsBDkgvWVwiuHINx)iflkbFLzNNuJOek0kmAlkHjuRzjHy1(m8RfYBHiLamysqluqFcWEcuXlja3eukzJZwRdpHFTqSQ4fkrPKnokrHu1XWVwiuHINxDkflkbFLzNNuJOeLs24OepJiXNa)YEJucfAfgTfLaXne)ALzNtazjqk0ilwzDyyjGNlNaSNGjeQKnokHchvNHLcnYYtXZlvO45vNrXIsWxz25j1ikHcTcJ2Isukz9XW8Xol)ja7jWlLOuYghLWSqOAKPcfpxmgflkbFLzNNuJOek0kmAlkrluqFcWnbQ6fyepYxc0pbTqb9wNcBjGSemucmHAn7mGm7mSuKSZWZLamysGuD(e7liUC67Xw(kZoptG)uIsjBCucurANWTfXuHINlEPyrjkLSXrjEHRjoWVwiuc(kZopPgrfQqfkHpg9BCu8CXyUymVUymJtj8uOBVXNsG)RJp8WB4WtNZvjibyPXjyDifijbTaLGbcAvK)AH8dsaIX)GweptWhoCckijCkHNjqPv3i)20TF3JtGxxLGHfNpgj8mbdKQZNyX3GeircgivNpXIplFLzNNdsWqEXM)20TF3Jta(5QemS48XiHNjyac64wGgzl(gKajsWae0XTanYw8z5Rm78CqcgYl283MU97ECc0bxLGHfNpgj8mbdqqh3c0iBX3GeircgGGoUfOr2IplFLzNNdsqjjqhtN43emKxS5VnD7394e41RRsWWIZhJeEMGbiOJBbAKT4BqcKibdqqh3c0iBXNLVYSZZbjyiVyZFB62V7XjWRXDvcgwC(yKWZemqQoFIfFdsGejyGuD(el(S8vMDEoibd5fB(Bt3PB8FD8HhEdhE6CUkbjalnobRdPajjOfOemyYTcQldsaIX)GweptWhoCckijCkHNjqPv3i)20TF3JtGlUkbdloFms4zcgGGoUfOr2IVbjqIemabDClqJSfFw(kZophKGH8In)TPB)UhNaxCvcgwC(yKWZemabDClqJSfFdsGejyac64wGgzl(S8vMDEoibd5fB(Bt3(DpobU4QemS48XiHNjyGkUj0kw8nibsKGbQ4MqRyXNLVYSZZbjyiVyZFB6oDJ)RJp8WB4WtNZvjibyPXjyDifijbTaLGbKqSkCmlzqcqm(h0I4zc(WHtqbjHtj8mbkT6g53MU97ECc86QemS48XiHNjyac64wGgzl(gKajsWae0XTanYw8z5Rm78Cqckjb6y6e)MGH8In)TPB)UhNaxCvcgwC(yKWZemqQoFIfFdsGejyGuD(el(S8vMDEoibLKaDmDIFtWqEXM)20TF3Jta(5QemS48XiHNjyGuD(el(gKajsWaP68jw8z5Rm78CqcgYl283MU97ECc0bxLGHfNpgj8mbdKQZNyX3GeircgivNpXIplFLzNNdsWqEXM)20D6g)xhF4H3WHNoNRsqcWsJtW6qkqscAbkbdEzqcqm(h0I4zc(WHtqbjHtj8mbkT6g53MU97ECc86QemS48XiHNjyGuD(el(gKajsWaP68jw8z5Rm78CqcgYl283MU97ECc0bxLGHfNpgj8mbdqqh3c0iBX3GeircgGGoUfOr2IplFLzNNdsqjjqhtN43emKxS5VnD7394eyCxLGHfNpgj8mbdqqh3c0iBX3GeircgGGoUfOr2IplFLzNNdsWqEXM)20TF3JtGxxCvcgwC(yKWZemqQoFIfFdsGejyGuD(el(S8vMDEoibd5fB(Bt3(DpobE1bxLGHfNpgj8mbdKQZNyX3GeircgivNpXIplFLzNNdsWqEXM)20TF3JtGxJ7QemS48XiHNjyGuD(el(gKajsWaP68jw8z5Rm78CqcgYl283MU97ECc8ACxLGHfNpgj8mbdqqh3c0iBX3GeircgGGoUfOr2IplFLzNNdsWqEXM)20TF3JtGlgZvjyyX5JrcptWaP68jw8nibsKGbs15tS4ZYxz255GemKxS5VnDNUhohsbs4zcmEckLSXLG((YBt3ucsOOTDMsG)sGFqHi)DQ71wsjqNh0jmkDJ)sGocRyhtgLaDQEjWfJ5IXs3P7sjBCVLeIvHJzj4AqxPqWcQiP32mGGoUfOr2(buVfOrgMDmz0NUlLSX9wsiwfoMLGRbDNbKzNHLIKEKqSQEbwwh2GxJP32mukz9XW8Xol)y3lgmUwf(4RoXsooOToYCTuD(eRVO3zCs3Ls24EljeRchZsW1GU16Wt4xle92MHsjRpgMp2z5xF8JSHCTk8XxDILCCqBDK5AP68jwFrVZ4GbtPK1hdZh7S8RVl(NUlLSX9wsiwfoMLGRbDFHRjoWVwi6TndLswFmmFSZYp2DbdMHuHp(QtSKJdARddgP68jwFrVZ44pzLswFmmFSZYVbxs3P7sjBCpUg0vfqNWi4xlK0n(lbyPt0r0jUkbjalT9tGNT3tWX8mbpejsbssGejO69WtcgwaDcJsaHwijWJgFjqk0iljy)eCHKav9YEJ20DPKnUhxd6QcOtye8RfIE99yy10a(zm92Mbe0XTanY2NjPbPJ(WKqHQxoLSXHbZhqDZ9M2BXPEyjI(dtk2pomygsf3eAflI9XOV6WrdUfib6yYCnc64wGgz7ZK0G0rFysOq1lNs248pDJ)sGo)NtGOTFcIlbQi6ZWZLGTLGvg8jq04eexhNee3Wh6zBcgUwcWjGsGw5JtqDHOXOee3Wh65e4zfTeujOh3iJsGkI(m8C6LGxkf5jq0kjbEwrlbyHG4xlKe4rJVeiA8IsGkI(m8CFcuX16Rs0lbFKap1kja6KTNGvg8jiUeOIOpdpxcKibqpNarBF9sqiAmYZ(CcuXj7bXjqIea9CcIlbQi6ZWZzt3Ls24ECnOl0ZWRWo6DLdByI4A2wed7J)N7PB8xcgUwceprcIB4d98NGcXjaX1eNeu3mbQWHel7nMGwGsqLaSqq8RfscECoLEjO(hYHtGOXjOh3iJsGAMaT6tqLGxqXnYOeWTgRKeu3mbKqCJrjq0kjbqxN)pbRm4tq1rCnXjbXLave9z450lbHOXip7Zja65eiACcIJtGOvYGpbrRLave9z45Sjy4AjOsGG2JCwsW(jaX1eNeu3mb1fIgJsWlO4gzucgQ(hYHNjOHcNe0JBKrjqfrFgEo)tqCdFONtGNT3tq1)ibMCcqCnXjbM4KarJtGSoCcWcbXVwijqfo8NaZsrEcIwlbQi6ZWZPxcen(sa0ZjyLeiO9iNLeSTeiACcETcXZe4IXsWZQ4MjqntWkjqq74iJ(e4jUbsc2tyuJrCc8SIwcenobqKuHZEJjalee)AHKGhNtnyMG4g(qpBtWW1sqLabTh5SKava1NjWKta0ZZeu3mbVS9EcuHdNaZsrEcIwlbQi6ZWZLGwGsqLGgKaH4eGfcIFTq0lbRm4tWxnobsKaON1lbKqCJrO9gtGOXjOh3i)scur0NHNlbBlbINibfItaIRjo2emCTeiACcA7OMKG9tWyS3ycKib8ntGj3ceNaCciucogBscWcbXVwi6La)qOxsWlfssa0V3yce0EKZYNajsGtroNGhcXjq0yCsWilja65PnDxkzJ7X1GUqpdVc786TndMqTMvqq8RfIfIegmMqTMvqq8RfIDgEoYur0NHNZkii(1cXIyNAVh7UymmyA7OMaJyNAVxFve9z45SccIFTqSi2P27t3Ls24ECnORQ6D4sjBCW99f9UYHnOMF6UuYg3JRbDvvVdxkzJdUVVO3voSHx0BBgkLS(yy(yNLF9XV0DPKnUhxd6QQEhUuYghCFFrVRCydcAvK)AH86TndLswFmmFSZYp2DjDNUlLSX9w18nyYONrKV3OEBZGjuRzfee)AHyHiHbtBh1eye7u7967f)s3Ls24ERA(4AqxZEet4gech92MbtOwZkii(1cXcrcdM2oQjWi2P2713RFMUlLSX9w18X1GU1P4xqvhwv9UEBZGjuRzfee)AHyHiHbtBh1eye7u79671pt3Ls24ERA(4Aq32IyZEet92MbtOwZkii(1cXcrcdM2oQjWi2P271xNLUlLSX9w18X1GU9DutEy)qO5OdFIEBZGjuRzfee)AHyNHNlDxkzJ7TQ5JRbDnRr4OblOvr(R32myc1AwbbXVwi2z45s3Ls24ERA(4AqxsHSXP32myc1AwbbXVwiwisKzc1AwZEeZo0lwisyWyc1AwbbXVwiwisKjfAKfRgxDrZssj67IXWGPTJAcmIDQ9E9DXpt3P7sjBCV9fdVW1eh4xle92MbP68j2x4AIdCluqpzdrcX(GhvtRx7lCnXb(1cHmtOwZ(cxtCGBHc6Ti2P27134yWyc1A2x4AIdCluqVDgEo)t3Ls24E7l4AqxY3Eh(1cjDxkzJ7TVGRbDNbKzNHLIKEBZGk8XxDILCCqBDKPIOpdpNfXFCLS3iCHqHhlIDQ9E9hvtmyCTk8XxDILCCqBDK5Av4JV6e7TJAcCRymyuHp(QtS3oQjWTIjBive9z45SE2(e(jTOvElIDQ9E9hvtmyur0NHNZkii(1cXIyNAVh7g34(JbJuOrwSY6WWsapxwFVgpDxkzJ7TVGRbDB9cX6TndsHGfurYcrIme0XTanY2pG6TanYWSJjJ(0DPKnU3(cUg0vkeSGks6TndiOJBbAKTFa1BbAKHzhtg9KjfcwqfjlIDQ9E9hvtYur0NHNZ26fITi2P271Funt3Ls24E7l4AqxgBK6XV(y4xlK0DPKnU3(cUg01Z2NWpPfTYNUlLSX92xW1GUTEHdpHFTqs3Ls24E7l4Aq3jxIgSsRihvo6TndTqb94QQxGr8iF63cf0BDkSLUlLSX92xW1GUfSdeAYi4ObRqHNpDxkzJ7TVGRbDr8hxj7ncxiu4jDxkzJ7TVGRbD9f9oJJEBZGjuRzjHy1(m8RfYBNHNddgxlvNpXQ0wNIrf8RfcgmLswFmmFSZYV(UKUlLSX92xW1GUccIFTq0BBgmHAnljeR2NHFTqE7m8CyWyc1Awe)XvYEJWfcfESqKWGXeQ1SE2(e(jTOvElejmymHAnRVO3zCSqKiRuY6JH5JDw(XU30n(lbyPt0r0jUkbdp23YEsqPKno7Zis8jWVS3ODp4wFh1eyjGLcnYs6UuYg3BFbxd6wRdpHFTq0tHJQZWsHgz5n4vVTzWeQ1SKqSAFg(1c5TZWZHbZqMqTMvqq8RfIfIegmnOEhgXkTcnYWY6W6pQM4QQxGL1H9NSHCTuD(eRsBDkgvWVwiyWukz9XW8Xol)67I)yWyc1AwbTkYHFTqElIDQ9ESZyJvqcdlRdtwPK1hdZh7S8JDVP7sjBCV9fCnOlQiTt42Iy92MHwOGECv1lWiEKp9BHc6Tof2iBitOwZkii(1cXodphgmUgbDClqJSLRXolvpUhwqqmCluqV)KnKjuRzNbKzNHLIKDgEomyKQZNyFbXLtFp2)0DPKnU3(cUg0vPTofJk4xle92MbtOwZscXQ9z4xlK3crcdMwOGESRIxWTuYgNTwhEc)AHyvXlP7sjBCV9fCnOBHu1XWVwi6TndMqTMLeIv7ZWVwiVfIegmTqb9yxfVGBPKnoBTo8e(1cXQIxs3Ls24E7l4Aq3NrK4tGFzVr9u4O6mSuOrwEdE1BBgqCdXVwz2zYKcnYIvwhgwc45YyFcHkzJlDxkzJ7TVGRbDnleQgz92MHsjRpgMp2z5h7Et3Ls24E7l4AqxurANWTfX6TndTqb94QQxGr8iF63cf0BDkSr2qMqTMDgqMDgwks2z45WGrQoFI9fexo99y)t3Ls24E7l4Aq3x4AId8Rfs6oDxkzJ7TcAvK)AH8gEHRjoWVwi6Tnds15tSVW1eh4wOGEY2dU13rnHmtOwZ(cxtCGBHc6Ti2P27134P7sjBCVvqRI8xlKhxd6odiZodlfj92Mbv4JV6el54G26itfrFgEolI)4kzVr4cHcpwe7u796pQMyW4Av4JV6el54G26iZ1QWhF1j2Bh1e4wXyWOcF8vNyVDutGBft2qQi6ZWZz9S9j8tArR8we7u796pQMyWOIOpdpNvqq8RfIfXo1Ep2nUX9hdgPqJSyL1HHLaEUS(Enw6UuYg3Bf0Qi)1c5X1GUsHGfursVTzabDClqJS9dOElqJmm7yYONmPqWcQizrStT3R)OAsMkI(m8C2wVqSfXo1EV(JQz6UuYg3Bf0Qi)1c5X1GUTEHy92MbPqWcQizHirgc64wGgz7hq9wGgzy2XKrF6UuYg3Bf0Qi)1c5X1GUm2i1JF9XWVwiP7sjBCVvqRI8xlKhxd66z7t4N0Iw5t3Ls24ERGwf5VwipUg0fXFCLS3iCHqHN0DPKnU3kOvr(RfYJRbD9f9oJt6UuYg3Bf0Qi)1c5X1GUMfcvJC6UuYg3Bf0Qi)1c5X1GUccIFTqs3Ls24ERGwf5VwipUg0fvK2jCBrSEBZGjuRzf0Qih(1c5Ti2P27XUbgBScsyyzDyYqqh3c0iBFi04EJWVwipzMqTMDgqMDgwks2z45s3Ls24ERGwf5VwipUg0TwhEc)AHONchvNHLcnYYBWREBZGjuRzf0Qih(1c5Ti2P27XUbgBScsyyzDyYgYeQ1SKqSAFg(1c5TZWZHbtdQ3HrSsRqJmSSoS(Q6fyzDyChvtmymHAnRGG4xlelej)t3Ls24ERGwf5VwipUg0DYLObR0kYrLJEBZqluqpUQ6fyepYN(Tqb9wNcBP7sjBCVvqRI8xlKhxd6Iks7eUTiwVTzWeQ1ScAvKd)AH8we7u79y3aJnwbjmSSoC6UuYg3Bf0Qi)1c5X1GUoqDzFTq0BBgmHAnRGwf5WVwiVDgEomymHAnljeR2NHFTqElejYAHc6XUkEb3sjBC2AD4j8RfIvfVq2qUwQoFIvPTofJk4xlemykLS(yy(yNLFSJF(NUlLSX9wbTkYFTqECnORsBDkgvWVwi6TndMqTMLeIv7ZWVwiVfIezTqb9yxfVGBPKnoBTo8e(1cXQIxiRuY6JH5JDw(1xhs3Ls24ERGwf5VwipUg0L8T3HFTq0BBgmHAn7KRjmJdBNHNlDxkzJ7TcAvK)AH84Aq3c2bcnzeC0GvOWZNUlLSX9wbTkYFTqECnOBRx4Wt4xlK0DPKnU3kOvr(RfYJRbDFgrIpb(L9g1tHJQZWsHgz5n4vVTzaXne)ALzNt3Ls24ERGwf5VwipUg01bQl7RfIEBZqluqp2vXl4wkzJZwRdpHFTqSQ4L0DPKnU3kOvr(RfYJRbDFHRjoWVwiuINeRO45IX1bQqfkfa]] )

end