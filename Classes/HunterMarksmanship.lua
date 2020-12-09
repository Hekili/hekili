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

        potion = "unbridled_fury",

        package = "Marksmanship",
    } )

    
    spec:RegisterSetting( "prevent_hardcasts", false, {
        name = "Prevent Hardcasts of |T135130:0|t Aimed Shot During Movement",
        desc = "If checked, the addon will not recommend |T135130:0|t Aimed Shot if it has a cast time and you are moving.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Marksmanship", 20201209, [[dOKD6aqiQK6rqPQ2eIYNOQAukLCkQk9kOkZIuPBbLQyxu6xKQmmkuoMsXYOs8mOuzAuOQRrQOTrvH(gPcmoOuLohvfSoQKmpsvDpkyFqfoiPcLfsH8qLs1ejvqDrkujFKuH0iPqLYjvkLwjvQzsvr3uPuWoHQ6NuOILQuk6PimvOKRsHkvFLuHQXcv0Er6VGAWahwYIPOhtYKvYLrTzP8zLQrtkNwXQvkf61iQMTuDBQy3Q8BHHJihNubz5qEUQMoX1bz7uL(ovX4Hs58qLwpPcX8HI9lA6gkwuIvjmfFxmMlgBJlgZhSgZhWoDGo1bucbxsmLGuPiV2zkXvomLyBOqK)o19AdjkbPc3EulkwuIpGqkMsG9tGMiKExPNE7JObzAvHJE)4a1lzItHQMO3pok9OeMqtx22JAsjwLWu8DXyUySnUymFWAmFa70b6uNuIcs0ceLGyC2oLqBwl(OMuIf)kkb2pbBdfI83PUxBiLaJBqNWO0n2pb6WSIDmzuc8bDtGlgZfJrj6ZlpflkHGgf5Vwipflk(BOyrj4Rm78IAeLqHgHrtrjKQZNyFHRfUWTqb9w(kZoVsazjyo4wF21KeqwcmHAn7lCTWfUfkO3IyNAUpb6NaDsjkLmXrjEHRfUWVwiuHIVluSOe8vMDErnIsOqJWOPOeQWlF1jwYXfn1LaYsGkI(k8Cwe)XvYC7WfcfESi2PM7tG(jyxTsagmjW1jqfE5RoXsoUOPUeqwcCDcuHx(QtS3SRjWTItagmjqfE5RoXEZUMa3kobKLGTsGkI(k8CwptFb)Kg0iVfXo1CFc0pb7QvcWGjbQi6RWZzfee)AHyrStn3NaCKaDQZe4BcWGjbsH2zXkJddlb8A4eOFc2ymkrPKjokXkGm7mSuKOcfFSJIfLGVYSZlQrucfAegnfLabDClq7S9dOElq7mm7yYO3Yxz25vcilbsHGfurYIyNAUpb6NGD1kbKLave9v45STEHylIDQ5(eOFc2vlkrPKjokHuiybvKOcfFJNIfLGVYSZlQruIsjtCuIwVqmLqHgHrtrjKcblOIKfIucilbiOJBbANTFa1BbANHzhtg9w(kZoVOe95yy1Is4IoPcfFDsXIsukzIJsWyJup(Xld)AHqj4Rm78IAevO47JuSOeLsM4OeEM(c(jnOrEkbFLzNxuJOcfFDaflkrPKjokbI)4kzUD4cHcpuc(kZoVOgrfk(yVuSOeLsM4OeEJENXLsWxz25f1iQqX3hOyrjkLmXrjmleQ2zkbFLzNxuJOcf)ngJIfLOuYehLqqq8RfcLGVYSZlQruHI)MnuSOe8vMDErnIsOqJWOPOeMqTMvqJIC4xlK3IyNAUpb4WqcySXkiHHLXHtazjabDClq7S9Hq7ZTd)AH8w(kZoVsazjWeQ1SRaYSZWsrYUcphLOuYehLavKMfCBqmvO4VXfkwuc(kZoVOgrjkLmXrjQXHxWVwiucfAegnfLWeQ1ScAuKd)AH8we7uZ9jahgsaJnwbjmSmoCcilbBLatOwZscXQ5z4xlK3UcpxcWGjbnOEhgXkTcTZWY4Wjq)eOQxGLXHtaEjyxTsagmjWeQ1SccIFTqSqKsGVucfUQodlfANLNI)gQqXFd2rXIsWxz25f1ikHcncJMIs0cf0Na8sGQEbgX78La9tqluqV1PWgLOuYehLyXLObR0kYrLdvO4VX4Pyrj4Rm78IAeLqHgHrtrjmHAnRGgf5WVwiVfXo1CFcWHHeWyJvqcdlJdtjkLmXrjqfPzb3getfk(B0jflkbFLzNxuJOek0imAkkHjuRzf0Oih(1c5TRWZLamysGjuRzjHy18m8RfYBHiLaYsqluqFcWrcuXljaVeukzIZwJdVGFTqSQ4Leqwc2kbUobs15tSkTXPyub)AHy5Rm78kbyWKGsjJxgMp2z4pb4ibyxc8LsukzIJs4a1L51cHku834JuSOe8vMDErnIsOqJWOPOeMqTMLeIvZZWVwiVfIucilbTqb9jahjqfVKa8sqPKjoBno8c(1cXQIxsazjOuY4LH5JDg(tG(jW4PeLsM4OekTXPyub)AHqfk(B0buSOe8vMDErnIsOqJWOPOeMqTMDX1cMXLTRWZrjkLmXrjiF6D4xleQqXFd2lflkrPKjokrb7aHwmcoAWku45Pe8vMDErnIku834duSOeLsM4OeTEHlVGFTqOe8vMDErnIku8DXyuSOe8vMDErnIsukzIJs8mIeFc8lZTtjuOry0uuce3q8RvMDMsOWv1zyPq7S8u83qfk(USHIfLGVYSZlQrucfAegnfLOfkOpb4ibQ4LeGxckLmXzRXHxWVwiwv8cLOuYehLWbQlZRfcvO47IluSOeLsM4OeVW1cx4xlekbFLzNxuJOcvOelUvqDHIff)nuSOeLsM4OeQa6egb)AHqj4Rm78IAevO47cflkbFLzNxuJOeLsM4OeQa6egb)AHqjuOry0uuce0XTaTZ2NjPbPJ8WKqHQxoLmXz5Rm78kbyWKGpG6MZTS3GB9Wse9hMumFCjadMeSvcuXTGgXIyVm6RoC0GBbsGo2Yxz25vcilbUobiOJBbANTptsdsh5HjHcvVCkzIZYxz25vc8Ls0NJHvlkb2zmQqXh7Oyrj4Rm78IAeL4khMsSqCTAdIH9Y)ZDkrPKjokXcX1Qnig2l)p3PcfFJNIfLGVYSZlQrucfAegnfLWeQ1SccIFTqSqKsagmjWeQ1SccIFTqSRWZLaYsGkI(k8CwbbXVwiwe7uZ9jahjWfJLamysqB21eye7uZ9jq)eOIOVcpNvqq8RfIfXo1CpLOuYehLa6z4ryNNku81jflkbFLzNxuJOeLsM4OeQQ3HlLmXb3NxOe95f4RCykHA9uHIVpsXIsWxz25f1ikHcncJMIsukz8YW8Xod)jq)eGDuIsjtCucv17WLsM4G7ZluI(8c8vomL4fQqXxhqXIsWxz25f1ikHcncJMIsukz8YW8Xod)jahjWfkrPKjokHQ6D4sjtCW95fkrFEb(khMsiOrr(RfYtfQqjiHyv4ywcflk(BOyrj4Rm78IAeLqHgHrtrjqqh3c0oB)aQ3c0odZoMm6T8vMDErjkLmXrjKcblOIevO47cflkbFLzNxuJOeKqSQEbwghMsSXyuIsjtCuIvaz2zyPirjuOry0uuIsjJxgMp2z4pb4ibBsagmjW1jqfE5RoXsoUOPUeqwcCDcKQZNy9g9oJRLVYSZlQqXh7Oyrj4Rm78IAeLqHgHrtrjkLmEzy(yNH)eOFcWUeqwc2kbUobQWlF1jwYXfn1LaYsGRtGuD(eR3O3zCT8vMDELamysqPKXldZh7m8Na9tGljWxkrPKjokrno8c(1cHku8nEkwuc(kZoVOgrjuOry0uuIsjJxgMp2z4pb4ibUKamysWwjqfE5RoXsoUOPUeGbtcKQZNy9g9oJRLVYSZRe4BcilbLsgVmmFSZWFcmKaxOeLsM4OeVW1cx4xleQqfkHA9uSO4VHIfLGVYSZlQrucfAegnfLWeQ1SccIFTqSqKsagmjOn7AcmIDQ5(eOFc2GDuIsjtCuctg9mI852PcfFxOyrj4Rm78IAeLqHgHrtrjmHAnRGG4xlelePeGbtcAZUMaJyNAUpb6NGn(iLOuYehLWShXcUbHWLku8Xokwuc(kZoVOgrjuOry0uuctOwZkii(1cXcrkbyWKG2SRjWi2PM7tG(jyJpsjkLmXrjQtXVGQoSQ6DQqX34Pyrj4Rm78IAeLqHgHrtrjmHAnRGG4xlelePeGbtcAZUMaJyNAUpb6NaFGsukzIJs0geB2Jyrfk(6KIfLGVYSZlQrucfAegnfLWeQ1SccIFTqSRWZrjkLmXrj6ZUM8WBJqRDh(eQqX3hPyrj4Rm78IAeLqHgHrtrjmHAnRGG4xle7k8CuIsjtCucZAhoAWcAuK)uHIVoGIfLGVYSZlQrucfAegnfLWeQ1SccIFTqSqKsazjWeQ1SM9iwDOxSqKsagmjWeQ1SccIFTqSqKsazjqk0olwnU6IMLKssG(jWfJLamysqB21eye7uZ9jq)e4IpsjkLmXrjifYehvOcL4fkwu83qXIsWxz25f1ikHcncJMIsivNpX(cxlCHBHc6T8vMDELaYsWwjGeI9cVRw2n2x4AHl8RfscilbMqTM9fUw4c3cf0BrStn3Na9tGotagmjWeQ1SVW1cx4wOGE7k8CjWxkrPKjokXlCTWf(1cHku8DHIfLOuYehLG8P3HFTqOe8vMDErnIku8Xokwuc(kZoVOgrjuOry0uucv4LV6el54IM6sazjqfrFfEolI)4kzUD4cHcpwe7uZ9jq)eSRwjadMe46eOcV8vNyjhx0uxcilbUobQWlF1j2B21e4wXjadMeOcV8vNyVzxtGBfNaYsWwjqfrFfEoRNPVGFsdAK3IyNAUpb6NGD1kbyWKave9v45SccIFTqSi2PM7taosGo1zc8nbyWKaPq7SyLXHHLaEnCc0pbB0jLOuYehLyfqMDgwksuHIVXtXIsWxz25f1ikrPKjokrRxiMsOqJWOPOesHGfurYcrkbKLae0XTaTZ2pG6TaTZWSJjJElFLzNxuI(CmSArjCrNuHIVoPyrj4Rm78IAeLqHgHrtrjqqh3c0oB)aQ3c0odZoMm6T8vMDELaYsGuiybvKSi2PM7tG(jyxTsazjqfrFfEoBRxi2IyNAUpb6NGD1IsukzIJsifcwqfjQqX3hPyrjkLmXrjySrQh)4LHFTqOe8vMDErnIku81buSOeLsM4OeEM(c(jnOrEkbFLzNxuJOcfFSxkwuIsjtCuIwVWLxWVwiuc(kZoVOgrfk((aflkbFLzNxuJOek0imAkkrluqFcWlbQ6fyeVZxc0pbTqb9wNcBuIsjtCuIfxIgSsRihvouHI)gJrXIsukzIJsuWoqOfJGJgScfEEkbFLzNxuJOcf)nBOyrjkLmXrjq8hxjZTdxiu4HsWxz25f1iQqXFJluSOe8vMDErnIsOqJWOPOeMqTMLeIvZZWVwiVDfEUeGbtcCDcKQZNyvAJtXOc(1cXYxz25vcWGjbLsgVmmFSZWFc0pbUqjkLmXrj8g9oJlvO4Vb7Oyrj4Rm78IAeLqHgHrtrjmHAnljeRMNHFTqE7k8CjadMeyc1Awe)XvYC7WfcfESqKsagmjWeQ1SEM(c(jnOrElePeGbtcmHAnR3O3zCTqKsazjOuY4LH5JDg(taosWgkrPKjokHGG4xleQqXFJXtXIsWxz25f1ikrPKjokrno8c(1cHsOqJWOPOeMqTMLeIvZZWVwiVDfEUeGbtc2kbMqTMvqq8RfIfIucWGjbnOEhgXkTcTZWY4Wjq)eSRwjaVeOQxGLXHtGVjGSeSvcCDcKQZNyvAJtXOc(1cXYxz25vcWGjbLsgVmmFSZWFc0pbUKaFtagmjWeQ1ScAuKd)AH8we7uZ9jahjGXgRGegwghobKLGsjJxgMp2z4pb4ibBOekCvDgwk0olpf)nuHI)gDsXIsWxz25f1ikHcncJMIs0cf0Na8sGQEbgX78La9tqluqV1PWwcilbBLatOwZkii(1cXUcpxcWGjbUobiOJBbANTCT3zP6X9WccIHBHc6T8vMDELaFtazjyReyc1A2vaz2zyPizxHNlbyWKaP68j2xqC50NJT8vMDELaFPeLsM4OeOI0SGBdIPcf)n(iflkbFLzNxuJOek0imAkkHjuRzjHy18m8RfYBHiLamysqluqFcWrcuXljaVeukzIZwJdVGFTqSQ4fkrPKjokHsBCkgvWVwiuHI)gDaflkbFLzNxuJOek0imAkkHjuRzjHy18m8RfYBHiLamysqluqFcWrcuXljaVeukzIZwJdVGFTqSQ4fkrPKjokrHu1XWVwiuHI)gSxkwuc(kZoVOgrjkLmXrjEgrIpb(L52Pek0imAkkbIBi(1kZoNaYsGuODwSY4WWsaVgob4ibliujtCucfUQodlfANLNI)gQqXFJpqXIsWxz25f1ikHcncJMIsukz8YW8Xod)jahjydLOuYehLWSqOANPcfFxmgflkbFLzNxuJOek0imAkkrluqFcWlbQ6fyeVZxc0pbTqb9wNcBjGSeSvcmHAn7kGm7mSuKSRWZLamysGuD(e7liUC6ZXw(kZoVsGVuIsjtCucurAwWTbXuHIVlBOyrjkLmXrjEHRfUWVwiuc(kZoVOgrfQqfkHxg9tCu8DXyUySnUymSxkHNcDZT)ucDCDSTj(Bl(6OUkbjalnobJdPajjOfOe4xqJI8xlK3FcqSoe0G4vc(WHtqbjHtj8kbkT6253MU95CCc24QeS948YiHxjWVuD(elo9NajsGFP68jwCA5Rm78YFc2Ad281MU95CCcWoxLGThNxgj8kb(rqh3c0oBXP)eirc8JGoUfOD2ItlFLzNx(tWwBWMV20TpNJtGX7QeS948YiHxjWpc64wG2zlo9NajsGFe0XTaTZwCA5Rm78YFckjbgxghFMGT2GnFTPBFohNGnBCvc2ECEzKWRe4hbDClq7SfN(tGejWpc64wG2zloT8vMDE5pbBTbB(At3(CoobB0PRsW2JZlJeELa)s15tS40FcKib(LQZNyXPLVYSZl)jyRnyZxB6oDRJRJTnXFBXxh1vjibyPXjyCifijbTaLa)lUvqDXFcqSoe0G4vc(WHtqbjHtj8kbkT6253MU95CCcCXvjy7X5LrcVsGFe0XTaTZwC6pbsKa)iOJBbANT40Yxz25L)eS1gS5RnD7Z54e4IRsW2JZlJeELa)iOJBbANT40FcKib(rqh3c0oBXPLVYSZl)jyRnyZxB62NZXjWfxLGThNxgj8kb(vXTGgXIt)jqIe4xf3cAeloT8vMDE5pbBTbB(At3PBDCDSTj(Bl(6OUkbjalnobJdPajjOfOe4NeIvHJzj(taI1HGgeVsWhoCckijCkHxjqPv3o)20TpNJtWgxLGThNxgj8kb(rqh3c0oBXP)eirc8JGoUfOD2ItlFLzNx(tqjjW4Y44ZeS1gS5RnD7Z54e4IRsW2JZlJeELa)s15tS40FcKib(LQZNyXPLVYSZl)jOKeyCzC8zc2Ad281MU95CCcWoxLGThNxgj8kb(LQZNyXP)eirc8lvNpXItlFLzNx(tWwBWMV20TpNJtGX7QeS948YiHxjWVuD(elo9NajsGFP68jwCA5Rm78YFc2Ad281MUt3646yBt83w81rDvcsawACcghsbssqlqjW)l(taI1HGgeVsWhoCckijCkHxjqPv3o)20TpNJtWgxLGThNxgj8kb(LQZNyXP)eirc8lvNpXItlFLzNx(tWwBWMV20TpNJtGX7QeS948YiHxjWpc64wG2zlo9NajsGFe0XTaTZwCA5Rm78YFckjbgxghFMGT2GnFTPBFohNaD6QeS948YiHxjWpc64wG2zlo9NajsGFe0XTaTZwCA5Rm78YFc2Ad281MU95CCc24IRsW2JZlJeELa)s15tS40FcKib(LQZNyXPLVYSZl)jyRnyZxB62NZXjyJX7QeS948YiHxjWVuD(elo9NajsGFP68jwCA5Rm78YFc2Ad281MU95CCc2OtxLGThNxgj8kb(LQZNyXP)eirc8lvNpXItlFLzNx(tWwBWMV20TpNJtWgD6QeS948YiHxjWpc64wG2zlo9NajsGFe0XTaTZwCA5Rm78YFc2Ad281MU95CCcCXyUkbBpoVms4vc8lvNpXIt)jqIe4xQoFIfNw(kZoV8NGT2GnFTP70926qkqcVsGotqPKjUe0NxEB6MsqcfTPZucSFc2gke5VtDV2qkbg3GoHrPBSFc0Hzf7yYOe4d6MaxmMlglDNUlLmX9wsiwfoMLGNb9KcblOIKUtZac64wG2z7hq9wG2zy2XKrF6UuYe3BjHyv4ywcEg0BfqMDgwks6scXQ6fyzCydBmMUtZqPKXldZh7m8JJnyW4Av4LV6el54IM6iZ1s15tSEJENXnDxkzI7TKqSkCmlbpd6vJdVGFTq0DAgkLmEzy(yNHF9XoY2Y1QWlF1jwYXfn1rMRLQZNy9g9oJlgmLsgVmmFSZWV(U4B6UuYe3BjHyv4ywcEg07fUw4c)AHO70mukz8YW8Xod)4Wfmy2sfE5RoXsoUOPomyKQZNy9g9oJRVKvkz8YW8Xod)gCjDNUlLmX94zqpvaDcJGFTqs3y)eGLXrh244QeKaS0MpbEMEpbhZRe8qKifijbsKGQ3dpjy7b0jmkbeAHKapA8LaPq7SKG5tWfscu1lZTBt3LsM4E8mONkGoHrWVwi62NJHvldyNX0DAgqqh3c0oBFMKgKoYdtcfQE5uYehgmFa1nNBzVb36HLi6pmPy(4WGzlvClOrSi2lJ(Qdhn4wGeOJjZ1iOJBbANTptsdsh5HjHcvVCkzIZ30n2pbg3FobI28jiUeOIOVcpxcMwcgX)NarJtqCDCtqCypqpBtW22saUbuc0kVCcQlengLG4WEGEobEgrlbvc6XTZOeOIOVcpNUj4LsrEceTssGNr0sawii(1cjbE04lbIgpOeOIOVcp3NavCT(OeDtWhjWtnscGoz6jye)FcIlbQi6RWZLajsa0Zjq0Mx3eeIgJ8mpNavCYCqCcKibqpNG4sGkI(k8C20DPKjUhpd6b9m8iSJUx5WgwiUwTbXWE5)5E6g7NGTTLaXtKG4WEGE(tqH4eG4AHBcQBLav4qIL52tqlqjOsawii(1cjbpUNs3eu)d5Wjq04e0JBNrjqTsGw9jOsWlO42zuc4wJvscQBLasiUXOeiALKaORZ)NGr8)jO6iUw4MG4sGkI(k8C6MGq0yKN55ea9CcenobXXjq0kX)NGO1sGkI(k8C2eSTTeujqqZroljy(eG4AHBcQBLG6crJrj4fuC7mkbBv)d5WRe0qHtc6XTZOeOIOVcpNVjioShONtGNP3tq1)ibMCcqCTWnbM4MarJtGmoCcWcbXVwijqfo8NaZsrEcIwlbQi6RWZPBcen(sa0ZjyKeiO5iNLemTeiACcETcXRe4IXsWZQ4wjqTsWijqqZ(oJ(e4jo)scMtyuJrCc8mIwcenobqKuHZC7jalee)AHKGh3t5FLG4WEGE2MGTTLGkbcAoYzjbQaQVsGjNaONxjOUvcEz69eOchobMLI8eeTwcur0xHNlbTaLGkbnibcXjalee)AHOBcgX)NGVACcKibqpRBciH4gJqZTNarJtqpUD(LeOIOVcpxcMwceprckeNaexlCTjyBBjq04e0MDnjbZNG9yU9eirc4BLatUfiob4gqOeCm2KeGfcIFTq0nbBJqVKGxkKKaOFU9eiO5iNLpbsKaNICobpeItGOX4MGDwsa0ZlB6UuYe3JNb9GEgEe251DAgmHAnRGG4xlelejmymHAnRGG4xle7k8CKPIOVcpNvqq8RfIfXo1CpoCXyyW0MDnbgXo1CV(Qi6RWZzfee)AHyrStn3NUlLmX94zqpv17WLsM4G7Zl6ELdBqT(0DPKjUhpd6PQEhUuYehCFEr3RCydVO70mukz8YW8Xod)6JDP7sjtCpEg0tv9oCPKjo4(8IUx5Wge0Oi)1c51DAgkLmEzy(yNHFC4s6oDxkzI7TQ1BWKrpJiFUDDNMbtOwZkii(1cXcrcdM2SRjWi2PM71Fd2LUlLmX9w16XZGEM9iwWnieU6ondMqTMvqq8RfIfIegmTzxtGrStn3R)gFmDxkzI7TQ1JNb9QtXVGQoSQ6DDNMbtOwZkii(1cXcrcdM2SRjWi2PM71FJpMUlLmX9w16XZGETbXM9iw6ondMqTMvqq8RfIfIegmTzxtGrStn3RVpKUlLmX9w16XZGE9zxtE4TrO1UdFIUtZGjuRzfee)AHyxHNlDxkzI7TQ1JNb9mRD4OblOrr(R70myc1AwbbXVwi2v45s3LsM4ERA94zqpsHmXP70myc1AwbbXVwiwisKzc1AwZEeRo0lwisyWyc1AwbbXVwiwisKjfANfRgxDrZssj67IXWGPn7AcmIDQ5E9DXht3P7sjtCV9fdVW1cx4xleDNMbP68j2x4AHlCluqpzBrcXEH3vl7g7lCTWf(1cHmtOwZ(cxlCHBHc6Ti2PM71xNyWyc1A2x4AHlCluqVDfEoFt3LsM4E7l4zqpYNEh(1cjDxkzI7TVGNb9wbKzNHLIKUtZGk8YxDILCCrtDKPIOVcpNfXFCLm3oCHqHhlIDQ5E93vlmyCTk8YxDILCCrtDK5Av4LV6e7n7AcCRymyuHx(QtS3SRjWTIjBlve9v45SEM(c(jnOrElIDQ5E93vlmyur0xHNZkii(1cXIyNAUhh6uN(IbJuODwSY4WWsaVgw)n6mDxkzI7TVGNb9A9cX62NJHvldUOtDNMbPqWcQizHirgc64wG2z7hq9wG2zy2XKrF6UuYe3BFbpd6jfcwqfjDNMbe0XTaTZ2pG6TaTZWSJjJEYKcblOIKfXo1CV(7QfzQi6RWZzB9cXwe7uZ96VRwP7sjtCV9f8mOhJns94hVm8Rfs6UuYe3BFbpd65z6l4N0Gg5t3LsM4E7l4zqVwVWLxWVwiP7sjtCV9f8mO3IlrdwPvKJkhDNMHwOGE8u1lWiENp9BHc6Tof2s3LsM4E7l4zqVc2bcTyeC0GvOWZNUlLmX92xWZGEi(JRK52Hlek8KUlLmX92xWZGEEJENXv3PzWeQ1SKqSAEg(1c5TRWZHbJRLQZNyvAJtXOc(1cbdMsjJxgMp2z4xFxs3LsM4E7l4zqpbbXVwi6ondMqTMLeIvZZWVwiVDfEomymHAnlI)4kzUD4cHcpwisyWyc1AwptFb)Kg0iVfIegmMqTM1B07mUwisKvkz8YW8Xod)4yt6g7NaSmo6WghxLGTj7DypjOuYeN9zej(e4xMB3ohCRp7AcSeWsH2zjDxkzI7TVGNb9QXHxWVwi6QWv1zyPq7S8g2O70myc1Awsiwnpd)AH82v45WGzltOwZkii(1cXcrcdMguVdJyLwH2zyzCy93vl8u1lWY4W(s2wUwQoFIvPnofJk4xlemykLmEzy(yNHF9DXxmymHAnRGgf5WVwiVfXo1CpoySXkiHHLXHjRuY4LH5JDg(XXM0DPKjU3(cEg0dvKMfCBqSUtZqluqpEQ6fyeVZN(Tqb9wNcBKTLjuRzfee)AHyxHNddgxJGoUfOD2Y1ENLQh3dliigUfkO3xY2YeQ1SRaYSZWsrYUcphgms15tSVG4YPph7B6UuYe3BFbpd6P0gNIrf8RfIUtZGjuRzjHy18m8RfYBHiHbtluqpouXl4vkzIZwJdVGFTqSQ4L0DPKjU3(cEg0RqQ6y4xleDNMbtOwZscXQ5z4xlK3crcdMwOGECOIxWRuYeNTghEb)AHyvXlP7sjtCV9f8mO3Zis8jWVm3UUkCvDgwk0olVHn6ondiUH4xRm7mzsH2zXkJddlb8AyCSGqLmXLUlLmX92xWZGEMfcv7SUtZqPKXldZh7m8JJnP7sjtCV9f8mOhQinl42GyDNMHwOGE8u1lWiENp9BHc6Tof2iBltOwZUciZodlfj7k8CyWivNpX(cIlN(CSVP7sjtCV9f8mO3lCTWf(1cjDNUlLmX9wbnkYFTqEdVW1cx4xleDNMbP68j2x4AHlCluqpzZb36ZUMqMjuRzFHRfUWTqb9we7uZ96RZ0DPKjU3kOrr(RfYJNb9wbKzNHLIKUtZGk8YxDILCCrtDKPIOVcpNfXFCLm3oCHqHhlIDQ5E93vlmyCTk8YxDILCCrtDK5Av4LV6e7n7AcCRymyuHx(QtS3SRjWTIjBlve9v45SEM(c(jnOrElIDQ5E93vlmyur0xHNZkii(1cXIyNAUhh6uN(IbJuODwSY4WWsaVgw)nglDxkzI7TcAuK)AH84zqpPqWcQiP70mGGoUfOD2(buVfODgMDmz0tMuiybvKSi2PM71FxTitfrFfEoBRxi2IyNAUx)D1kDxkzI7TcAuK)AH84zqVwVqSU95yy1YGl6u3PzqkeSGkswisKHGoUfOD2(buVfODgMDmz0NUlLmX9wbnkYFTqE8mOhJns94hVm8Rfs6UuYe3Bf0Oi)1c5XZGEEM(c(jnOr(0DPKjU3kOrr(RfYJNb9q8hxjZTdxiu4jDxkzI7TcAuK)AH84zqpVrVZ4MUlLmX9wbnkYFTqE8mONzHq1oNUlLmX9wbnkYFTqE8mONGG4xlK0DPKjU3kOrr(RfYJNb9qfPzb3geR70myc1AwbnkYHFTqElIDQ5ECyGXgRGegwghMme0XTaTZ2hcTp3o8RfYtMjuRzxbKzNHLIKDfEU0DPKjU3kOrr(RfYJNb9QXHxWVwi6QWv1zyPq7S8g2O70myc1AwbnkYHFTqElIDQ5ECyGXgRGegwghMSTmHAnljeRMNHFTqE7k8CyW0G6DyeR0k0odlJdRVQEbwghgVD1cdgtOwZkii(1cXcrY30DPKjU3kOrr(RfYJNb9wCjAWkTICu5O70m0cf0JNQEbgX78PFluqV1PWw6UuYe3Bf0Oi)1c5XZGEOI0SGBdI1DAgmHAnRGgf5WVwiVfXo1CpomWyJvqcdlJdNUlLmX9wbnkYFTqE8mONduxMxleDNMbtOwZkOrro8RfYBxHNddgtOwZscXQ5z4xlK3crISwOGECOIxWRuYeNTghEb)AHyvXlKTLRLQZNyvAJtXOc(1cbdMsjJxgMp2z4hhyNVP7sjtCVvqJI8xlKhpd6P0gNIrf8RfIUtZGjuRzjHy18m8RfYBHirwluqpouXl4vkzIZwJdVGFTqSQ4fYkLmEzy(yNHF9n(0DPKjU3kOrr(RfYJNb9iF6D4xleDNMbtOwZU4AbZ4Y2v45s3LsM4ERGgf5VwipEg0RGDGqlgbhnyfk88P7sjtCVvqJI8xlKhpd616fU8c(1cjDxkzI7TcAuK)AH84zqVNrK4tGFzUDDv4Q6mSuODwEdB0DAgqCdXVwz250DPKjU3kOrr(RfYJNb9CG6Y8AHO70m0cf0Jdv8cELsM4S14Wl4xleRkEjDxkzI7TcAuK)AH84zqVx4AHl8RfcL4jXkk(UOtJNkuHsb]] )

end