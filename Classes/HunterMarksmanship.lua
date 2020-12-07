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


    spec:RegisterPack( "Marksmanship", 20201205, [[dGKJ1aqiQqEevOytiKprv1OubofvLELkLzrfSlk(fPWWivPJrfTmsv9mvqMgPK6AiO2gvO6BQGIXrkrCosjQ1rQI5rk6EKk7tfQdskHSqsPEivfnrsjsxKuc1hjLKmsvqLojvO0kPkMjvfUjPKu7uLQFskjwQkO0tbmve4RQGQgRkK9c1FvyWiDyHftjpMKjROlJAZs5ZQKrtPoTKvRcQ41iQMTuDBQ0Uv63IgoICCsjOLd55QA6exhOTtv67iuJhb58ikRNucmFv0(bn2jMamWmegFxF9QVEDQVEjSXPtc7u)dHbeYiXyasHI84IXaB4YyaT6ar(7g7BxKWaKcY6zmXeGb(eePymGJbsTfH0Rhn04QeBqlJkD14lxWEivUku0en(YvPbgWcS6IJDXwyGzim(U(6vF96uF9syJtNe2P(6JbcqXoryaGY1Nya7Ao5fBHbM8RWaogivRoqK)UX(2fji9WfCfgb94yGuTuwXUwmcsjSdqQ(6vF9Ib61lpMamGGkf5VDkpMa8DNycWa8gwDEI1gdOqLWOkWas05vmVWXKSrlvGVH3WQZtiLiiT2rRxx2cKseKAb2AMx4ys2OLkW3Gy3O2hs1esjmgiusLlg4foMKnE7uWc(U(ycWa8gwDEI1gdOqLWOkWaQ0lVXkgYjdvXcPebPQm7ZK41G4p3qQ9AeiusSbXUrTpKQjKEPMq65jK6iivLE5nwXqozOkwiLii1rqQk9YBSIzRlBz0cgsppHuv6L3yfZwx2YOfmKseKEaKQYSptIxdXvFoEsfQK3Gy3O2hs1esVuti98esvz2NjXRrqG8BNIbXUrTpKEmKsycdP(cPNNqQeOlwms5YdjhZIHunHuN6fdekPYfdmtqRopKGewW3peMamaVHvNNyTXakujmQcmacC5wIUyZNG9wIU4b7AXO3WBy15jKseKkbAiOGKbXUrTpKQjKEPMqkrqQkZ(mjEnTEGydIDJAFivti9snXaHsQCXasGgckiHf8DTgtagG3WQZtS2yafQegvbgqc0qqbjdijiLiifbUClrxS5tWElrx8GDTy0B4nS68edekPYfd06bIXc(oHXeGbcLu5IbycrQNF5LhVDkyaEdRopXAJf8DhhtagiusLlgG4QphpPcvYJb4nS68eRnwW3pmycWaHsQCXai(ZnKAVgbcLeJb4nS68eRnwW31sWeGbcLu5Ib8M9otggG3WQZtS2ybFxlJjadekPYfdyfiuCXyaEdRopXAJf8DN6ftagiusLlgqqG8BNcgG3WQZtS2ybF3PtmbyaEdRopXAJbuOsyufyalWwZiOsr(4Tt5ni2nQ9H0J1bPmHyfOWdPCziLiifbUClrxS5brx1EnE7uEdVHvNNqkrqQfyRzMjOvNhsqYmtIxmqOKkxmakivZrRqmwW3DQpMamaVHvNNyTXaHsQCXar5YZXBNcgqHkHrvGbSaBnJGkf5J3oL3Gy3O2hspwhKYeIvGcpKYLHuIG0dGulWwZqcXQ65XBNYBMjXlKEEcPnWEFGyLDGU4HuUmKQjKQIxgs5Yq6ni9snH0Zti1cS1mccKF7umGKGuFXakYuDEib6ILhF3jwW3DEimbyaEdRopXAJbuOsyufyGwQaFi9gKQIxgi(IxivtiTLkW34gecdekPYfdm5qShk7GCu4If8DNAnMamaVHvNNyTXakujmQcmGfyRzeuPiF82P8ge7g1(q6X6GuMqScu4HuUmgiusLlgafKQ5Ovigl47ojmMamaVHvNNyTXakujmQcmGfyRzeuPiF82P8Mzs8cPNNqQfyRziHyv984Tt5nGKGuIG0wQaFi9yivLVaP3G0qjvUMOC554TtXOYxGuIG0dGuhbPs05vmk7YnyumE7um8gwDEcPNNqAOKYlp4LDl(H0JH0dbP(IbcLu5IbCb7s92PGf8DNooMamaVHvNNyTXakujmQcmGfyRziHyv984Tt5nGKGuIG0wQaFi9yivLVaP3G0qjvUMOC554TtXOYxGuIG0qjLxEWl7w8dPAcPAngiusLlgqzxUbJIXBNcwW3DEyWeGb4nS68eRngqHkHrvGbSaBnZKJ5GjJnZK4fdekPYfdqE17J3ofSGV7ulbtagiusLlgigUGOjJgzBOqjXpgG3WQZtS2ybF3PwgtagiusLlgO1dY454TtbdWBy15jwBSGVRVEXeGb4nS68eRngiusLlg4zejELXl1EHbuOsyufyae3q8BhwDgdOit15HeOlwE8DNybFxFNycWa8gwDEI1gdOqLWOkWaTub(q6XqQkFbsVbPHsQCnr5YZXBNIrLVGbcLu5IbCb7s92PGf8D91htagiusLlg4foMKnE7uWa8gwDEI1glybdm5wa2fmb47oXeGbcLu5Ibuj4kmA82PGb4nS68eRnwW31htagG3WQZtS2yGqjvUyavcUcJgVDkyafQegvbgabUClrxS5zs2GAb)Gekv9WnKkxdVHvNNq65jK(jy3Q2PzlYIFiz2)bPS(CH0Zti9aivL7eSedI9YOp6JSnAjsax2WBy15jKseK6iifbUClrxS5zs2GAb)Gekv9WnKkxdVHvNNqQVyGET8qnXahsVybF)qycWa8gwDEI1gdSHlJbMioMTcXdV8)ChdekPYfdmrCmBfIhE5)5owW31AmbyaEdRopXAJbuOsyufyalWwZiiq(TtXascsppHuvM9zs8Aeei)2PyqSBu7dPhdPewldPNNqQeOlwms5YdjhZIHunHu91lgiusLlga85rjS7Jf8DcJjadWBy15jwBmqOKkxmGk69rOKk3rVEbd0RxgB4Yya18Xc(UJJjadWBy15jwBmGcvcJQadekP8YdEz3IFivti9qyGqjvUyav07JqjvUJE9cgOxVm2WLXaVGf89ddMamaVHvNNyTXakujmQcmqOKYlp4LDl(H0JHu9XaHsQCXaQO3hHsQCh96fmqVEzSHlJbeuPi)Tt5XcwWaKqSkDTcbta(UtmbyaEdRopXAJbuOsyufyae4YTeDXMpb7TeDXd21IrVH3WQZtmqOKkxmGeOHGcsybFxFmbyaEdRopXAJbiHyv8Yqkxgd4uVyGqjvUyGzcA15HeKWakujmQcmqOKYlp4LDl(H0JHuNq65jK6iivLE5nwXqozOkwiLii1rqQeDEfJ3S3zYm8gwDEIf89dHjadWBy15jwBmGcvcJQadekP8YdEz3IFivti9qqkrq6bqQJGuv6L3yfd5KHQyHuIGuhbPs05vmEZENjZWBy15jKEEcPHskV8Gx2T4hs1es1hs9fdekPYfdeLlphVDkybFxRXeGb4nS68eRngqHkHrvGbcLuE5bVSBXpKEmKQpKEEcPhaPQ0lVXkgYjdvXcPNNqQeDEfJ3S3zYm8gwDEcP(cPebPHskV8Gx2T4hs1bP6JbcLu5IbEHJjzJ3ofSGfmGA(ycW3DIjadWBy15jwBmGcvcJQadyb2AgbbYVDkgqsq65jK2QlBzGy3O2hs1esDEimqOKkxmGfJEgrETxybFxFmbyaEdRopXAJbuOsyufyalWwZiiq(TtXascsppH0wDzlde7g1(qQMqQthhdekPYfdy1ZCoAGiYWc((HWeGb4nS68eRngqHkHrvGbSaBnJGa53ofdiji98esB1LTmqSBu7dPAcPoDCmqOKkxmqSk(fu0hQO3Xc(UwJjadWBy15jwBmGcvcJQadyb2AgbbYVDkgqsq65jK2QlBzGy3O2hs1es1YyGqjvUyGwHyREMtSGVtymbyaEdRopXAJbuOsyufyalWwZiiq(TtXmtIxmqOKkxmqVUSLFC4aoVC5vWc(UJJjadWBy15jwBmGcvcJQadyb2AgbbYVDkMzs8IbcLu5IbSIRr2gcQuK)ybF)WGjadWBy15jwBmGcvcJQadyb2AgbbYVDkgqsqkrqQfyRzS6zo7GVyajbPNNqQfyRzeei)2PyajbPebPsGUyXyZrxSnKucKQjKQVEH0ZtiTvx2YaXUrTpKQjKQVJJbcLu5IbiLsLlwWcg4fmb47oXeGb4nS68eRngqHkHrvGbKOZRyEHJjzJwQaFdVHvNNqkrq6bqkje7DCPMgNMx4ys24TtbsjcsTaBnZlCmjB0sf4BqSBu7dPAcPegsppHulWwZ8chtYgTub(Mzs8cP(IbcLu5IbEHJjzJ3ofSGVRpMamqOKkxma5vVpE7uWa8gwDEI1gl47hctagG3WQZtS2yafQegvbgqLE5nwXqozOkwiLiivLzFMeVge)5gsTxJaHsIni2nQ9HunH0l1esppHuhbPQ0lVXkgYjdvXcPebPocsvPxEJvmBDzlJwWq65jKQsV8gRy26YwgTGHuIG0dGuvM9zs8AiU6ZXtQqL8ge7g1(qQMq6LAcPNNqQkZ(mjEnccKF7umi2nQ9H0JHuctyi1xi98esLaDXIrkxEi5ywmKQjK6KWyGqjvUyGzcA15HeKWc(UwJjadWBy15jwBmGcvcJQadibAiOGKbKeKseKIaxULOl28jyVLOlEWUwm6n8gwDEIbcLu5IbA9aXybFNWycWa8gwDEI1gdOqLWOkWaiWLBj6InFc2Bj6IhSRfJEdVHvNNqkrqQeOHGcsge7g1(qQMq6LAcPebPQm7ZK4106bIni2nQ9HunH0l1edekPYfdibAiOGewW3DCmbyGqjvUyaMqK65xE5XBNcgG3WQZtS2ybF)WGjadekPYfdqC1NJNuHk5Xa8gwDEI1gl47AjycWaHsQCXaTEqgphVDkyaEdRopXAJf8DTmMamaVHvNNyTXakujmQcmqlvGpKEdsvXldeFXlKQjK2sf4BCdcHbcLu5IbMCi2dLDqokCXc(Ut9IjadekPYfdedxq0KrJSnuOK4hdWBy15jwBSGV70jMamqOKkxmaI)CdP2RrGqjXyaEdRopXAJf8DN6JjadWBy15jwBmGcvcJQadyb2AgsiwvppE7uEZmjEH0Zti1rqQeDEfJYUCdgfJ3ofdVHvNNq65jKgkP8YdEz3IFivtivFmqOKkxmG3S3zYWc(UZdHjadWBy15jwBmGcvcJQadyb2AgsiwvppE7uEZmjEH0Zti1cS1mi(ZnKAVgbcLeBajbPNNqQfyRziU6ZXtQqL8gqsq65jKAb2AgVzVZKzajbPebPHskV8Gx2T4hspgsDIbcLu5Ibeei)2PGf8DNAnMamaVHvNNyTXaHsQCXar5YZXBNcgqHkHrvGbSaBndjeRQNhVDkVzMeVq65jKEaKAb2AgbbYVDkgqsq65jK2a79bIv2b6Ihs5YqQMq6LAcP3Guv8Yqkxgs9fsjcspasDeKkrNxXOSl3GrX4TtXWBy15jKEEcPHskV8Gx2T4hs1es1hs9fsppHulWwZiOsr(4Tt5ni2nQ9H0JHuMqScu4HuUmKseKgkP8YdEz3IFi9yi1jgqrMQZdjqxS847oXc(UtcJjadWBy15jwBmGcvcJQad0sf4dP3Guv8YaXx8cPAcPTub(g3Gqqkrq6bqQfyRzeei)2PyMjXlKEEcPocsrGl3s0fB44QZs0Z9hccKhTub(gEdRopHuFHuIG0dGulWwZmtqRopKGKzMeVq65jKkrNxX8cId3ETSH3WQZti1xmqOKkxmakivZrRqmwW3D64ycWa8gwDEI1gdOqLWOkWawGTMHeIv1ZJ3oL3ascsppH0wQaFi9yivLVaP3G0qjvUMOC554TtXOYxWaHsQCXak7YnyumE7uWc(UZddMamaVHvNNyTXakujmQcmGfyRziHyv984Tt5nGKG0ZtiTLkWhspgsv5lq6ninusLRjkxEoE7umQ8fmqOKkxmqGuXYJ3ofSGV7ulbtagG3WQZtS2yGqjvUyGNrK4vgVu7fgqHkHrvGbqCdXVDy1ziLiivc0flgPC5HKJzXq6Xq6eefsLlgqrMQZdjqxS847oXc(UtTmMamaVHvNNyTXakujmQcmqOKYlp4LDl(H0JHuNyGqjvUyaRaHIlgl476RxmbyaEdRopXAJbuOsyufyGwQaFi9gKQIxgi(IxivtiTLkW34gecsjcspasTaBnZmbT68qcsMzs8cPNNqQeDEfZlioC71YgEdRopHuFXaHsQCXaOGunhTcXybFxFNycWaHsQCXaVWXKSXBNcgG3WQZtS2yblybd4LrFLl(U(6vF960P(hcdqCG2AVEmWHxl6WE3XExRspqkKsGndPLlPejqAlrqQFbvkYF7uE)qkI1cblepH0pDzinaL0neEcPk7yV43a94JAzi1PEGuFMRxgj8es9lrNxXCKFivsi1VeDEfZrgEdRop9dPh4Kq(AGE8rTmKEi9aP(mxVms4jK6hbUClrxS5i)qQKqQFe4YTeDXMJm8gwDE6hspWjH81a94JAzivR1dK6ZC9YiHNqQFe4YTeDXMJ8dPscP(rGl3s0fBoYWBy15PFineivlwR4di9aNeYxd0JpQLHuNo1dK6ZC9YiHNqQFe4YTeDXMJ8dPscP(rGl3s0fBoYWBy15PFi9aNeYxd0JpQLHuNewpqQpZ1lJeEcP(LOZRyoYpKkjK6xIoVI5idVHvNN(H0dCsiFnqpqphETOd7Dh7DTk9aPqkb2mKwUKsKaPTebP(NCla7IFifXAHGfINq6NUmKgGs6gcpHuLDSx8BGE8rTmKQVEGuFMRxgj8es9JaxULOl2CKFivsi1pcC5wIUyZrgEdRop9dPh4Kq(AGE8rTmKQVEGuFMRxgj8es9JaxULOl2CKFivsi1pcC5wIUyZrgEdRop9dPh4Kq(AGE8rTmKQVEGuFMRxgj8es9RYDcwI5i)qQKqQFvUtWsmhz4nS680pKEGtc5Rb6b65WRfDyV7yVRvPhifsjWMH0YLuIeiTLii1pjeRsxRq8dPiwleSq8es)0LH0aus3q4jKQSJ9IFd0JpQLHuN6bs9zUEzKWti1pcC5wIUyZr(HujHu)iWLBj6Inhz4nS680pKgcKQfRv8bKEGtc5Rb6Xh1YqQ(6bs9zUEzKWti1VeDEfZr(HujHu)s05vmhz4nS680pKgcKQfRv8bKEGtc5Rb6Xh1Yq6H0dK6ZC9YiHNqQFj68kMJ8dPscP(LOZRyoYWBy15PFi9aNeYxd0JpQLHuTwpqQpZ1lJeEcP(LOZRyoYpKkjK6xIoVI5idVHvNN(H0dCsiFnqpqphETOd7Dh7DTk9aPqkb2mKwUKsKaPTebP(FXpKIyTqWcXti9txgsdqjDdHNqQYo2l(nqp(OwgsDQhi1N56LrcpHu)s05vmh5hsLes9lrNxXCKH3WQZt)q6bojKVgOhFuldPATEGuFMRxgj8es9JaxULOl2CKFivsi1pcC5wIUyZrgEdRop9dPHaPAXAfFaPh4Kq(AGE8rTmKsy9aP(mxVms4jK6hbUClrxS5i)qQKqQFe4YTeDXMJm8gwDE6hspWjH81a94JAzi1P(6bs9zUEzKWti1VeDEfZr(HujHu)s05vmhz4nS680pKEGtc5Rb6Xh1YqQtTwpqQpZ1lJeEcP(LOZRyoYpKkjK6xIoVI5idVHvNN(H0dCsiFnqp(OwgsDsy9aP(mxVms4jK6xIoVI5i)qQKqQFj68kMJm8gwDE6hspWjH81a94JAzi1jH1dK6ZC9YiHNqQFe4YTeDXMJ8dPscP(rGl3s0fBoYWBy15PFi9aNeYxd0JpQLHu91REGuFMRxgj8es9lrNxXCKFivsi1VeDEfZrgEdRop9dPh4Kq(AGEGECSUKsKWtiLWqAOKkxiTxV8gOhmaju2QoJbCmqQwDGi)DJ9Tlsq6Hl4kmc6XXaPAPSIDTyeKsyhGu91R(6f6b6jusL7BiHyv6AfYnDAibAiOGKdvthcC5wIUyZNG9wIU4b7AXOh6jusL7BiHyv6AfYnDAmtqRopKGKdKqSkEziLlRZPEDOA6cLuE5bVSBX)XoppDKk9YBSIHCYqvSe5ij68kgVzVZKb9ekPY9nKqSkDTc5MonIYLNJ3ofhQMUqjLxEWl7w8R5Hi6ahPsV8gRyiNmuflrosIoVIXB27mzNNHskV8Gx2T4xt99f6jusL7BiHyv6AfYnDA8chtYgVDkounDHskV8Gx2T4)y9pppqLE5nwXqozOk2Ztj68kgVzVZK5lrHskV8Gx2T4xN(qpqpHsQC)B60qLGRWOXBNc0JJbsjqROLQv0dKcPeyxpKsC17q6Y8esFqsKsKaPscPrVNedP(mbxHrqkGDkqkX28cPsGUybsRhs3uGuv8sTxgONqjvU)nDAOsWvy04TtXHET8qn1Di96q10HaxULOl28mjBqTGFqcLQE4gsL755NGDRANMTil(HKz)hKY6Z988avUtWsmi2lJ(OpY2OLibCzICecC5wIUyZZKSb1c(bjuQ6HBivU(c9ekPY9VPtdWNhLWUoSHlRBI4y2kep8Y)ZDONqjvU)nDAa(8Oe29DOA6SaBnJGa53ofdiPZtvM9zs8Aeei)2PyqSBu7FmH1YNNsGUyXiLlpKCmlwt91l0tOKk3)MonurVpcLu5o61loSHlRtnFONqjvU)nDAOIEFekPYD0RxCydxw3lounDHskV8Gx2T4xZdb9ekPY9VPtdv07JqjvUJE9IdB4Y6euPi)Tt5DOA6cLuE5bVSBX)X6d9a9ekPY9nQ5RZIrpJiV2lhQMolWwZiiq(TtXas68Svx2YaXUrTVMope0tOKk33OM)nDAy1ZCoAGiYCOA6SaBnJGa53ofdiPZZwDzlde7g1(A60XHEcLu5(g18VPtJyv8lOOpurV7q10zb2AgbbYVDkgqsNNT6Ywgi2nQ910PJd9ekPY9nQ5FtNgTcXw9mNounDwGTMrqG8BNIbK05zRUSLbIDJAFn1YqpHsQCFJA(30PrVUSLFC4aoVC5vCOA6SaBnJGa53ofZmjEHEcLu5(g18VPtdR4AKTHGkf5VdvtNfyRzeei)2PyMjXl0tOKk33OM)nDAqkLkxhQMolWwZiiq(TtXasIilWwZy1ZC2bFXas680cS1mccKF7umGKisc0flgBo6ITHKs0uF9EE2QlBzGy3O2xt9DCOhONqjvUV5fDVWXKSXBNIdvtNeDEfZlCmjB0sf4t0bKqS3XLAACAEHJjzJ3ofISaBnZlCmjB0sf4BqSBu7RjHppTaBnZlCmjB0sf4BMjXRVqpHsQCFZl30Pb5vVpE7uGEcLu5(MxUPtJzcA15HeKCOA6uPxEJvmKtgQILivM9zs8Aq8NBi1Encekj2Gy3O2xZl1880rQ0lVXkgYjdvXsKJuPxEJvmBDzlJwWNNQ0lVXkMTUSLrlyIoqLzFMeVgIR(C8KkujVbXUrTVMxQ55PkZ(mjEnccKF7umi2nQ9pMWe23ZtjqxSyKYLhsoMfRPtcd9ekPY9nVCtNgTEGyhQMojqdbfKmGKicbUClrxS5tWElrx8GDTy0d9ekPY9nVCtNgsGgcki5q10HaxULOl28jyVLOlEWUwm6jsc0qqbjdIDJAFnVutIuz2NjXRP1deBqSBu7R5LAc9ekPY9nVCtNgmHi1ZV8YJ3ofONqjvUV5LB60G4QphpPcvYd9ekPY9nVCtNgTEqgphVDkqpHsQCFZl30PXKdXEOSdYrHRdvtxlvG)nv8YaXx8QzlvGVXnie0tOKk338YnDAedxq0KrJSnuOK4h6jusL7BE5Monq8NBi1Encekjg6jusL7BE5Mon8M9otMdvtNfyRziHyv984Tt5nZK4980rs05vmk7YnyumE7uopdLuE5bVSBXVM6d9ekPY9nVCtNgccKF7uCOA6SaBndjeRQNhVDkVzMeVNNwGTMbXFUHu71iqOKydiPZtlWwZqC1NJNuHk5nGKopTaBnJ3S3zYmGKikus5Lh8YUf)h7e6XXaPeOv0s1k6bspSS3IjgsdLu5AEgrIxz8sTxMAhTEDzldjhsGUyb6jusL7BE5MonIYLNJ3ofhuKP68qc0flVoNounDwGTMHeIv1ZJ3oL3mtI3ZZdSaBnJGa53ofdiPZZgyVpqSYoqx8qkxwZl18MkEziLl7lrh4ij68kgLD5gmkgVDkNNHskV8Gx2T4xt99980cS1mcQuKpE7uEdIDJA)JzcXkqHhs5YefkP8YdEz3I)JDc9ekPY9nVCtNgOGunhTcXounDTub(3uXldeFXRMTub(g3GqeDGfyRzeei)2PyMjX75PJqGl3s0fB44QZs0Z9hccKhTub((s0bwGTMzMGwDEibjZmjEppLOZRyEbXHBVw2xONqjvUV5LB60qzxUbJIXBNIdvtNfyRziHyv984Tt5nGKopBPc8pwLVClusLRjkxEoE7umQ8fONqjvUV5LB60iqQy5XBNIdvtNfyRziHyv984Tt5nGKopBPc8pwLVClusLRjkxEoE7umQ8fONqjvUV5LB604zejELXl1E5GImvNhsGUy5150HQPdXne)2HvNjsc0flgPC5HKJzXhpbrHu5c9ekPY9nVCtNgwbcfxSdvtxOKYlp4LDl(p2j0tOKk338YnDAGcs1C0ke7q101sf4FtfVmq8fVA2sf4BCdcr0bwGTMzMGwDEibjZmjEppLOZRyEbXHBVw2xONqjvUV5LB604foMKnE7uGEGEcLu5(gbvkYF7uEDVWXKSXBNIdvtNeDEfZlCmjB0sf4tuTJwVUSfISaBnZlCmjB0sf4BqSBu7RjHHEcLu5(gbvkYF7u(B60yMGwDEibjhQMov6L3yfd5KHQyjsLzFMeVge)5gsTxJaHsIni2nQ918snppDKk9YBSIHCYqvSe5iv6L3yfZwx2YOf85Pk9YBSIzRlBz0cMOduz2NjXRH4QphpPcvYBqSBu7R5LAEEQYSptIxJGa53ofdIDJA)JjmH998uc0flgPC5HKJzXA6uVqpHsQCFJGkf5VDk)nDAibAiOGKdvthcC5wIUyZNG9wIU4b7AXONijqdbfKmi2nQ918snjsLzFMeVMwpqSbXUrTVMxQj0tOKk33iOsr(BNYFtNgTEGyhQMojqdbfKmGKicbUClrxS5tWElrx8GDTy0d9ekPY9ncQuK)2P830Pbtis98lV84Ttb6jusL7BeuPi)Tt5VPtdIR(C8Kkujp0tOKk33iOsr(BNYFtNgi(ZnKAVgbcLed9ekPY9ncQuK)2P830PH3S3zYGEcLu5(gbvkYF7u(B60WkqO4IHEcLu5(gbvkYF7u(B60qqG8BNc0tOKk33iOsr(BNYFtNgOGunhTcXounDwGTMrqLI8XBNYBqSBu7FSoMqScu4HuUmriWLBj6Inpi6Q2RXBNYtKfyRzMjOvNhsqYmtIxONqjvUVrqLI83oL)MonIYLNJ3ofhuKP68qc0flVoNounDwGTMrqLI8XBNYBqSBu7FSoMqScu4HuUmrhyb2AgsiwvppE7uEZmjEppBG9(aXk7aDXdPCznvXldPC5BxQ55PfyRzeei)2Pyaj5l0tOKk33iOsr(BNYFtNgtoe7HYoihfUounDTub(3uXldeFXRMTub(g3GqqpHsQCFJGkf5VDk)nDAGcs1C0ke7q10zb2AgbvkYhVDkVbXUrT)X6ycXkqHhs5YqpHsQCFJGkf5VDk)nDA4c2L6TtXHQPZcS1mcQuKpE7uEZmjEppTaBndjeRQNhVDkVbKerTub(hRYxUfkPY1eLlphVDkgv(crh4ij68kgLD5gmkgVDkNNHskV8Gx2T4)4d5l0tOKk33iOsr(BNYFtNgk7YnyumE7uCOA6SaBndjeRQNhVDkVbKerTub(hRYxUfkPY1eLlphVDkgv(crHskV8Gx2T4xtTg6jusL7BeuPi)Tt5VPtdYREF82P4q10zb2AMjhZbtgBMjXl0tOKk33iOsr(BNYFtNgXWfenz0iBdfkj(HEcLu5(gbvkYF7u(B60O1dY454Ttb6jusL7BeuPi)Tt5VPtJNrK4vgVu7LdkYuDEib6ILxNthQMoe3q8BhwDg6jusL7BeuPi)Tt5VPtdxWUuVDkounDTub(hRYxUfkPY1eLlphVDkgv(c0tOKk33iOsr(BNYFtNgVWXKSXBNcg4jXk8D9jSwJfSGXa]] )

end