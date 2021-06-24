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
        dire_beast_basilisk = 825, -- 205691
        dire_beast_hawk = 824, -- 208652
        dragonscale_armor = 3600, -- 202589
        hiexplosive_trap = 3605, -- 236776
        hunting_pack = 3730, -- 203235
        interlope = 1214, -- 248518
        roar_of_sacrifice = 3612, -- 53480
        scorpid_sting = 3604, -- 202900
        spider_sting = 3603, -- 202914
        survival_tactics = 3599, -- 202746
        the_beast_within = 693, -- 212668
        viper_sting = 3602, -- 202797
        wild_protector = 821, -- 204190
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
        },

        
        -- Legendaries
        nessingwarys_trapping_apparatus = {
            id = 336744,
            duration = 5,
            max_stack = 1,
            copy = { "nesingwarys_trapping_apparatus", "nesingwarys_apparatus", "nessingwarys_apparatus" }
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

    
    local ExpireNesingwarysTrappingApparatus = setfenv( function()
        focus.regen = focus.regen * 0.5
        forecastResources( "focus" )
    end, state )


    spec:RegisterHook( "reset_precast", function ()
        if now - action.serpent_sting.lastCast < gcd.execute * 2 and target.unit == action.serpent_sting.lastUnit then
            applyDebuff( "target", "serpent_sting" )
        end

        if debuff.tar_trap.up then
            debuff.tar_trap.expires = debuff.tar_trap.applied + 30
        end

        if buff.nesingwarys_apparatus.up then
            state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireCelestialAlignment, buff.nesingwarys_apparatus.expires )
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

            spend = function ()
                if legendary.nessingwarys_trapping_apparatus.enabled then
                    return -45, "focus"
                end
            end,

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

            spend = function ()
                if legendary.nessingwarys_trapping_apparatus.enabled then
                    return -45, "focus"
                end
            end,

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


    spec:RegisterPack( "Marksmanship", 20210502, [[dSKlybqiOuEess0MuQ6tssJIeCkKuVsanlbPBjjQDH4xkvAycGJjOwgOQNHKuttPICnKeBtsK(MaenobiCoKKuRtsH3HKKuZtsP7jPAFschuPIsleu4Hkv4IcqPpkajJuPIIoPKiwjuYmLu0nfGIDki(PaKAOijjzPkvu5PK0ujHUQsff(kssIXckAVs8xOAWsDyvwSqEmPMSsUmQndYNHIrJuNwvRwPIQEnjA2k62kLDl63unCb64cq1YbEoKPtCDf2oOY3rIXdLQZdkTEKKW8fQ9t5s4IIf11jCje4da8Hdavca8KWuHQPsy4lQcSb5IAWtR8WWf1824IAaZbuI2Uer)blQbpyN(Tkkwur(aO5IkvP10IeevJD3fZl0JiI232f9BJ5jVNAWbj7I(n9Uf1OXpLkjlrf11jCje4da8Hdavca8KWuHQPs4Wf1Bi0oOOQ(B7OOs)RfNLOI6Ir6IAaZbuI2Uer)bTEN5ifgyyfWCWAn8HAn8ba(Wf15JeurXIQaETseTlOIILqcxuSOY5fn5vbgfvn4fg8xrvUjNcbj8TGfhY1deHZlAYlR3B9N4qZhdTy9ERJgqqeKW3cwCixpqeaVDFISUwRPsr90Y7zrfj8TGfhr7srkHaFrXIkNx0Kxfyuu1GxyWFfvTdhNxkeLWc(lTEV1A3NlNssamYZt(ed(baofcG3UprwxR1y0lRJJTgBwRD448sHOewWFP17TgBwRD448sHKpgAbh6yRJJTw7WX5LcjFm0co0XwV3AfSw7(C5uscLFUWrbFWlicG3UprwxR1y0lRJJTw7(C5usIagmI2fcG3UprwxH1uHkwtT1XXwlhadle53yCXXxpBDTwhoaf1tlVNf1LpIMmUCblsjeQUOyrLZlAYRcmkQAWlm4VIkyKmKdWWeKpMqoadJZBrmar48IM8Y69wlhaxaxqcG3UprwxR1y0lR3BT295YPKeO5bycG3UprwxR1y0RI6PL3ZIQCaCbCblsjKDQOyrLZlAYRcmkQNwEplQqZdWfvn4fg8xrvoaUaUGKrqR3BnyKmKdWWeKpMqoadJZBrmar48IM8QOo)KX1RIk8uPiLqOsrXI6PL3ZIkJ9Gth9WX4iAxkQCErtEvGrrkHuPfflQNwEplQu(5chf8bVGkQCErtEvGrrkHeqwuSOEA59SOcyKNN8jg8daCkfvoVOjVkWOiLqcikkwu58IM8QaJIQg8cd(ROgnGGiag55jFIb)aaNcze064yRXM1AhooVuikHf8xADCS1Yn5uitwOVjoI2feHZlAYRI6PL3ZIkC(CYWwKsiu1fflQNwEplQrhaCy4IkNx0KxfyuKsiHdqrXI6PL3ZIQagmI2LIkNx0KxfyuKsiHdxuSOY5fn5vbgfvn4fg8xrfmsgYbyycAaW8jgCeTlicNx0KxwV3AfSw7(C5uscGrEEYNyWpaWPqa829jY6kSoCaSoo2ASzT2HJZlfIsyb)LwhhBTCtofYKf6BIJODbr48IM8YAQTEV1rdiiIaETsCeTlicG3UprwxrDRzSZ6HW4YVXf1tlVNfvWf8x4qpGlsjKWWxuSOY5fn5vbgf1tlVNf1734foI2LIQg8cd(ROgnGGic41kXr0UGiaE7(ezDf1TMXoRhcJl)gB9ERvW6ObeejiG1pIXr0UGilNsADCS1qJ5ehWA6dGHXLFJTUwR1hsWLFJToqRXOxwhhBD0acIiGbJODHmcAn1fvnS6jJlhadlOsiHlsjKWuDrXIkNx0Kxfyuu1GxyWFfvixpqwhO16dj4agdNwxR1qUEGiBh2lQNwEplQl(eACn9PeCBfPes4DQOyrLZlAYRcmkQAWlm4VIQcwRDFUCkjbWipp5tm4ha4uiaE7(ezDfwhoawV3AWizihGHjObaZNyWr0UGiCErtEzDCS1yZATdhNxkeLWc(lToo2ASznyKmKdWWe0aG5tm4iAxqeoVOjVSoo2A5MCkKjl03ehr7cIW5fn5L1uB9ERJgqqeb8AL4iAxqeaVDFISUI6wZyN1dHXLFJlQNwEplQGl4VWHEaxKsiHPsrXIkNx0Kxfyuu1GxyWFf1ObeeraVwjoI2fez5usRJJToAabrccy9JyCeTliYiO17TgY1dK1vyT2rI1bA9PL3tY9B8chr7cr7iX69wRG1yZA5MCken9VDm4Wr0Uq48IM8Y64yRpT8WX4CYBpJSUcRPARPUOEA59SOUnMYJODPiLqcxPfflQCErtEvGrrvdEHb)vuJgqqKGaw)ighr7cImcA9ERHC9azDfwRDKyDGwFA59KC)gVWr0Uq0osSEV1NwE4yCo5TNrwxR17ur90Y7zrvt)BhdoCeTlfPes4aYIIfvoVOjVkWOOQbVWG)kQrdiiYIVfodltwoLSOEA59SOQ8NtCeTlfPes4aIIIf1tlVNf1dFBawma3HW1aNcQOY5fn5vbgfPesyQ6IIf1tlVNfvO5blVWr0Uuu58IM8QaJIucb(auuSOY5fn5vbgf1tlVNfvedcYPGJKpXuu1GxyWFfvadbye9fn5IQgw9KXLdGHfujKWfPec8Hlkwu58IM8QaJIQg8cd(ROc56bY6kSw7iX6aT(0Y7j5(nEHJODHODKuupT8Ewu3gt5r0UuKsiWdFrXI6PL3ZIks4BbloI2LIkNx0KxfyuKIuuxm0nMsrXsiHlkwupT8Ewu1(ifgGJODPOY5fn5vbgfPec8fflQCErtEvGrr90Y7zrv7JuyaoI2LIQg8cd(ROcgjd5ammbXbPhufi8GaxpVTtEpjCErtEzDCS1iFmJ(CrYh2dHlUpr4b9h5jHZlAYlRJJTwbR1EUgVqamCmaDtChchYbYizcNx0KxwV3ASznyKmKdWWeehKEqvGWdcC982o59KW5fn5L1uxuNFY46vrLQdqrkHq1fflQCErtEvGrr90Y7zrvaxgWh)8Pk(edoI2LI6IrAWhuEplQbuU1hnFlRVCzTIGld4JF(ufS1Hqv1oSMtE7zuOwtHTE5zvX6LBTq)iRHCG1bNhSmazDeRVbIT(LQlRJyRf3Tgf822G16lxwtHTwFzvXAaFRFcR1kcUmGBnkiRFOxBD0accrkQAWlm4VIk2Swoagwipcp48GLbfPeYovuSOY5fn5vbgf1tlVNf1fGVf0dyC4yeINf1fJ0GpO8Ewu3zGyRf6hzTNwRDFUCkP1pK1VufzTqZw75ewR9SYdetSUsGSgwFyn9bhB9LUqZaR9SYdeBnLxOT(SE6jggyT295YPKHAnsoTsRf6tSMYl0wRiyWiAxSMcnNwl08dSw7(C5usK1ApHMVwc1AKBnL7fRhP8tRFPkYApTw7(C5usRf36bITwOFuOw7cndO8i2ATNYNd2AXTEGyR90AT7ZLtjjf1824I6cW3c6bmoCmcXZIucHkfflQCErtEvGrr90Y7zrvaFQKLWf1fJ0GpO8EwuReiRfA2Ab8PswSM(qwFw7zLhi26ObeuOwJGn1w)I1uEH2Afbdgr7cX6kbYAHIB9byR1(wqw(eJ1qoW6ZAfbdgr7I1iytDOwpqS1cnBnsaEIHbw7zLhi2AgcI1cX6kbY6lT2ZkpqS1rdiiRFK1a(wWAD0qS(sxOzG1ib4jggyTNvEGyRJgqqwt5NtRVjYToITgW3cwRJG1AHMTw(n2Afbdgr7I1AFJrwhDALw7qqwRDFUCkzOwpqS1Vy9dzTqZwJOpaVSwaFQKfR1UpxoL0AkEwvS(tHbqmGTMYl0wl0S1JGAF7tmwRiyWiAxSgbBQjwxjqwFP1Ew5bIToAabzT2hZL1rS1deVS(YL1i5NtR1(gBD0PvAnKdS(SgAidaBTIGbJODjuRhi26xiwxjqwFwNEw5ObeK1Ew5bIT(rwd4BbBOwpqS1Vy9dz9lwtXZQI1FkmaIbS1uEH26GUWP830ApR8aXwhnGGqwlay)eJ1IBTIGbJODXAeSP2Ahy9dzTqZw7cndSwaFQKfRFuwvS(sR9SYdehQ1pY6Z60ZkhnGGS2ZkpqS1uEH26Z6PNyyG1A3NlNsgQ1oW6hLvfRb8TGLyDLazTqZwd9yOfRFK1y8pXyT4wZ5Y6igYbS1W6dG1jJDXAfbdgr7sOwVZpqI1i5aI1d0NySwaFQKfK1IB92PKTgnaS1cndR1yyX6bIxKIQg8cd(ROkGpvYcrctOpe(aX4rdiiR3BTcwhnGGicyWiAxiJGwV3AfSgBwlGpvYcrGNqFi8bIXJgqqwhhBTa(ujlebEI295YPKeaVDFISoo2Ab8PswisyI295YPKK1aCY7P1vu3Ab8Pswic8eT7ZLtjjRb4K3tRP264yRJgqqebmyeTlKLtjTEV1kyTa(ujlebEc9HWhigpAabz9ERfWNkzHiWt0UpxoLKSgGtEpTUI6wlGpvYcrct0UpxoLKSgGtEpTEV1c4tLSqe4jA3NlNssa829jY6kBnvSUwR1UpxoLKiGbJODHa4T7tK17Tw7(C5usIagmI2fcG3UprwxH1WhaRJJTwaFQKfIeMODFUCkjznaN8EADLTMkwxR1A3NlNsseWGr0Uqa829jYAQToo2A5ayyHi)gJlo(6zRR1AT7ZLtjjcyWiAxiaE7(ezn1whhBn2SwaFQKfIeMqFi8bIXJgqqwV3AfSwaFQKfIapH(q4deJhnGGSEV1kyD0acIiGbJODHSCkP1XXwlGpvYcrGNODFUCkjbWB3NiRRWAQyn1wV3AfSw7(C5usIagmI2fcG3UprwxH1WhaRJJTwaFQKfIapr7(C5uscG3UprwxzRPI1vyT295YPKebmyeTleaVDFISMARJJTgBwlGpvYcrGNqFi8bIXJgqqwV3AfSgBwlGpvYcrGNqFiCT7ZLtjToo2Ab8Pswic8eT7ZLtjjRb4K3tRROU1c4tLSqKWeT7ZLtjjRb4K3tRJJTwaFQKfIapr7(C5uscG3UprwtT1uxKsivArXIkNx0Kxfyuu1GxyWFfvb8Pswic8e6dHpqmE0acY69wRG1rdiiIagmI2fYiO17TwbRXM1c4tLSqKWe6dHpqmE0acY64yRfWNkzHiHjA3NlNssa829jY64yRfWNkzHiWt0UpxoLKSgGtEpTUI6wlGpvYcrct0UpxoLKSgGtEpTMARJJToAabreWGr0UqwoL069wRG1c4tLSqKWe6dHpqmE0acY69wlGpvYcrct0UpxoLKSgGtEpTUI6wlGpvYcrGNODFUCkjznaN8EA9ERfWNkzHiHjA3NlNssa829jY6kBnvSUwR1UpxoLKiGbJODHa4T7tK17Tw7(C5usIagmI2fcG3UprwxH1WhaRJJTwaFQKfIapr7(C5usYAao5906kBnvSUwR1UpxoLKiGbJODHa4T7tK1uBDCS1YbWWcr(ngxC81ZwxR1A3NlNsseWGr0Uqa829jYAQToo2ASzTa(ujlebEc9HWhigpAabz9ERvWAb8Pswisyc9HWhigpAabz9ERvW6Obeeradgr7cz5usRJJTwaFQKfIeMODFUCkjbWB3NiRRWAQyn1wV3AfSw7(C5usIagmI2fcG3UprwxH1WhaRJJTwaFQKfIeMODFUCkjbWB3NiRRS1uX6kSw7(C5usIagmI2fcG3UprwtT1XXwJnRfWNkzHiHj0hcFGy8ObeK17TwbRXM1c4tLSqKWe6dHRDFUCkP1XXwlGpvYcrct0UpxoLKSgGtEpTUI6wlGpvYcrGNODFUCkjznaN8EADCS1c4tLSqKWeT7ZLtjjaE7(ezn1wtDr90Y7zrvaFQKf4lsjKaYIIfvoVOjVkWOOQbVWG)kQrdiiIagmI2fYiO1XXwhnGGicyWiAxilNsA9ER1UpxoLKiGbJODHa4T7tK1vyn8bW64yRHEm0coG3UprwxR1A3NlNsseWGr0Uqa829jQOEA59SOoqm(l8gQiLqcikkwu58IM8QaJI6PL3ZIQ(Mt8tlVN4Zhjf15Je8824IQEHksjeQ6IIfvoVOjVkWOOQbVWG)kQNwE4yCo5TNrwxR1uDr90Y7zrvFZj(PL3t85JKI68rcEEBCrfjfPes4auuSOY5fn5vbgfvn4fg8xr90YdhJZjV9mY6kSg(I6PL3ZIQ(Mt8tlVN4Zhjf15Je8824IQaETseTlOIuKIAqaR9TOtkkwcjCrXI6PL3ZIAKlYKx4qZdwEr5tm4IJ9plQCErtEvGrrkHaFrXIkNx0Kxfyuu1GxyWFfvWizihGHjiFmHCaggN3IyaIW5fn5vr90Y7zrvoaUaUGfPecvxuSOY5fn5vbgf1GawFibx(nUOgoaf1tlVNf1LpIMmUCblQAWlm4VI6PLhogNtE7zK1vyDyRJJTgBwRD448sHOewWFP17TgBwl3KtHaNpNmSeoVOjVksjKDQOyrLZlAYRcmkQAWlm4VI6PLhogNtE7zK11AnvB9ERvWASzT2HJZlfIsyb)LwV3ASzTCtofcC(CYWs48IM8Y64yRpT8WX4CYBpJSUwRH3AQlQNwEplQ3VXlCeTlfPecvkkwu58IM8QaJIQg8cd(ROEA5HJX5K3EgzDfwdV1XXwRG1AhooVuikHf8xADCS1Yn5uiW5ZjdlHZlAYlRP269wFA5HJX5K3EgzDDRHVOEA59SOIe(wWIJODPifPOQxOIILqcxuSOY5fn5vbgfvn4fg8xrnAabreWGr0UqgbToo2AOhdTGd4T7tK11ADyQUOEA59SOgXaedu(jMIucb(IIfvoVOjVkWOOQbVWG)kQrdiiIagmI2fYiO1XXwd9yOfCaVDFISUwRdxPf1tlVNf1OP7lCOba2IucHQlkwu58IM8QaJIQg8cd(ROgnGGicyWiAxiJGwhhBn0JHwWb829jY6AToCLwupT8EwuVuZibCtC9nNfPeYovuSOY5fn5vbgfvn4fg8xrnAabreWGr0UqgbToo2AOhdTGd4T7tK11AnvDr90Y7zrf6bC009vrkHqLIIfvoVOjVkWOOQbVWG)kQrdiiIagmI2fYYPKf1tlVNf15JHwq478JfMnoLIucPslkwu58IM8QaJIQg8cd(ROgnGGicyWiAxilNswupT8EwuJom4oeUaETsurkHeqwuSOY5fn5vbgfvn4fg8xrnAabreWGr0UqgbTEV1rdiis0091CGeYiO1XXwhnGGicyWiAxiJGwV3A5ayyHqZ3uOjb1I11An8bW64yRHEm0coG3UprwxR1WxPf1tlVNf1GU8EwKIuursrXsiHlkwu58IM8QaJIQg8cd(ROk3KtHGe(wWId56bIW5fn5L17TwbRdcy4WXOxKWeKW3cwCeTlwV36Obeebj8TGfhY1debWB3NiRR1AQyDCS1rdiics4BbloKRhiYYPKwtDr90Y7zrfj8TGfhr7srkHaFrXI6PL3ZIQYFoXr0Uuu58IM8QaJIucHQlkwu58IM8QaJIQg8cd(ROQD448sHOewWFP17Tw7(C5uscGrEEYNyWpaWPqa829jY6ATgJEzDCS1yZATdhNxkeLWc(lTEV1yZATdhNxkK8Xql4qhBDCS1AhooVui5JHwWHo269wRG1A3NlNssO8Zfok4dEbra829jY6ATgJEzDCS1A3NlNsseWGr0Uqa829jY6kSMkuXAQToo2A5ayyHi)gJlo(6zRR16WuPOEA59SOU8r0KXLlyrkHStfflQCErtEvGrr90Y7zrfAEaUOQbVWG)kQYbWfWfKmcA9ERbJKHCagMG8XeYbyyCElIbicNx0Kxf15NmUEvuHNkfPecvkkwu58IM8QaJIQg8cd(ROcgjd5ammb5JjKdWW48wedqeoVOjVSEV1YbWfWfKa4T7tK11Ang9Y69wRDFUCkjbAEaMa4T7tK11Ang9QOEA59SOkhaxaxWIucPslkwupT8EwuzShC6Ohoghr7srLZlAYRcmksjKaYIIf1tlVNfvk)CHJc(GxqfvoVOjVkWOiLqcikkwupT8EwuHMhS8chr7srLZlAYRcmksjeQ6IIfvoVOjVkWOOQbVWG)kQqUEGSoqR1hsWbmgoTUwRHC9ar2oSxupT8Ewux8j04A6tj42ksjKWbOOyr90Y7zr9W3gGfdWDiCnWPGkQCErtEvGrrkHeoCrXI6PL3ZIkGrEEYNyWpaWPuu58IM8QaJIucjm8fflQCErtEvGrrvdEHb)vuvW6ObeebWipp5tm4ha4uiJGwhhBn2Sw7WX5LcrjSG)sRJJTwUjNczYc9nXr0UGiCErtEzn1wV3AfSoAabrccy9JyCeTliYYPKwhhBn2SwUjNcrt)BhdoCeTleoVOjVSoo26tlpCmoN82ZiRR1A4TM6I6PL3ZIkC(CYWwKsiHP6IIfvoVOjVkWOOQbVWG)kQrdiisqaRFeJJODbrwoL064yRJgqqeaJ88KpXGFaGtHmcADCS1rdiicLFUWrbFWliYiO1XXwhnGGiW5Zjdlze069wFA5HJX5K3EgzDfwhUOEA59SOkGbJODPiLqcVtfflQCErtEvGrrvdEHb)vubJKHCagMGgamFIbhr7cIW5fn5L17TwUjNcbja(2MFYeoVOjVSEV1kyT295YPKeaJ88KpXGFaGtHa4T7tK1vyD4ayDCS1yZATdhNxkeLWc(lToo2A5MCkKjl03ehr7cIW5fn5L1uxupT8EwubxWFHd9aUiLqctLIIfvoVOjVkWOOEA59SOE)gVWr0Uuu1GxyWFf1ObeejiG1pIXr0UGilNsADCS1kyD0acIiGbJODHmcADCS1qJ5ehWA6dGHXLFJTUwRXOxwhO16dj4YVXwtT17TwbRXM1Yn5uiA6F7yWHJODHW5fn5L1XXwFA5HJX5K3EgzDTwdV1uBDCS1rdiiIaETsCeTlicG3UprwxH1m2z9qyC53yR3B9PLhogNtE7zK1vyD4IQgw9KXLdGHfujKWfPes4kTOyrLZlAYRcmkQAWlm4VIQcwRDFUCkjbWipp5tm4ha4uiaE7(ezDfwhoawhhBn2Sw7WX5LcrjSG)sRJJTwUjNczYc9nXr0UGiCErtEzn1wV3AixpqwhO16dj4agdNwxR1qUEGiBh2TEV1kyD0acIiGbJODHSCkP1XXwJnRbJKHCagMWhMjl30teUagmoKRhicNx0KxwtT17TwbRJgqqKLpIMmUCbjlNsADCS1Yn5uiibW328tMW5fn5L1uxupT8EwubxWFHd9aUiLqchqwuSOY5fn5vbgfvn4fg8xrnAabrccy9JyCeTliYiO1XXwd56bY6kSw7iX6aT(0Y7j5(nEHJODHODKuupT8Ewu10)2XGdhr7srkHeoGOOyrLZlAYRcmkQAWlm4VIA0acIeeW6hX4iAxqKrqRJJTgY1dK1vyT2rI1bA9PL3tY9B8chr7cr7iPOEA59SOEa9LmoI2LIucjmvDrXIkNx0KxfyuupT8EwurmiiNcos(etrvdEHb)vubmeGr0x0KTEV1YbWWcr(ngxC81ZwxH1Rb4K3ZIQgw9KXLdGHfujKWfPec8bOOyrLZlAYRcmkQAWlm4VI6PLhogNtE7zK1vyD4I6PL3ZIA0bahgUiLqGpCrXIkNx0Kxfyuu1GxyWFfvfSw7(C5uscGrEEYNyWpaWPqa829jY6kSoCaSEV1GrYqoadtqdaMpXGJODbr48IM8Y64yRXM1AhooVuikHf8xADCS1Yn5uitwOVjoI2feHZlAYlRP269wd56bY6aTwFibhWy406ATgY1dez7WU17TwbRJgqqKLpIMmUCbjlNsADCS1Yn5uiibW328tMW5fn5L1uxupT8EwubxWFHd9aUiLqGh(IIf1tlVNfvKW3cwCeTlfvoVOjVkWOifPifv4ya69Sec8ba(WbyNcavxuPCG8tmOIkvLD2DUqQKqcOQH1wRinB9Vf0bI1qoW6Qc41kr0UGQAnGd4JhWlRr(gB9neF7eEzTM(smmIyyvZpzRdxdR3HNWXaHxwxvUjNcbMvTwCRRk3KtHatcNx0KxvTwHWyNAIHvn)KTMQRH17Wt4yGWlRRcgjd5ammbMvTwCRRcgjd5ammbMeoVOjVQATcHXo1edRA(jB9ovdR3HNWXaHxwxfmsgYbyycmRAT4wxfmsgYbyycmjCErtEv16tSoGnGUMwRqyStnXWQMFYwhqudR3HNWXaHxwxvUjNcbMvTwCRRk3KtHatcNx0KxvT(eRdydORP1keg7utmSQ5NS1HdxdR3HNWXaHxwxvUjNcbMvTwCRRk3KtHatcNx0KxvTwHWyNAIHvn)KToC4Ay9o8eogi8Y6QGrYqoadtGzvRf36QGrYqoadtGjHZlAYRQwRqyStnXWQMFYwhENQH17Wt4yGWlRRk3KtHaZQwlU1vLBYPqGjHZlAYRQwRqyStnXWQMFYwhENQH17Wt4yGWlRRcgjd5ammbMvTwCRRcgjd5ammbMeoVOjVQATcWJDQjgw18t26WuPgwVdpHJbcVSUQCtofcmRAT4wxvUjNcbMeoVOjVQATcHXo1edldlQk7S7CHujHeqvdRTwrA26FlOdeRHCG1vxm0nMsvRbCaF8aEznY3yRVH4BNWlR10xIHredRA(jBn81W6D4jCmq4L1vbJKHCagMaZQwlU1vbJKHCagMatcNx0KxvTwHWyNAIHvn)KTg(Ay9o8eogi8Y6QGrYqoadtGzvRf36QGrYqoadtGjHZlAYRQwRqyStnXWQMFYwdFnSEhEchdeEzDvTNRXleyw1AXTUQ2Z14fcmjCErtEv1AfcJDQjgw18t2A4RH17Wt4yGWlRRI8Xm6ZfbMvTwCRRI8Xm6ZfbMeoVOjVQATcHXo1edRA(jBnvQH17Wt4yGWlRRkGpvYcjmbMvTwCRRkGpvYcrctGzvRvOsXo1edRA(jBnvQH17Wt4yGWlRRkGpvYcbEcmRAT4wxvaFQKfIapbMvTwHWun2PMyyvZpzRR0Ay9o8eogi8Y6Qc4tLSqctGzvRf36Qc4tLSqKWeyw1Afct1yNAIHvn)KTUsRH17Wt4yGWlRRkGpvYcbEcmRAT4wxvaFQKfIapbMvTwHkf7utmSmSOQSZUZfsLesavnS2AfPzR)TGoqSgYbwxniG1(w0jvTgWb8Xd4L1iFJT(gIVDcVSwtFjggrmSQ5NS1WxdR3HNWXaHxwxfmsgYbyycmRAT4wxfmsgYbyycmjCErtEv16tSoGnGUMwRqyStnXWQMFYwt11W6D4jCmq4L1vLBYPqGzvRf36QYn5uiWKW5fn5vvRpX6a2a6AATcHXo1edRA(jB9ovdR3HNWXaHxwxvUjNcbMvTwCRRk3KtHatcNx0KxvTwHWyNAIHvn)KTMk1W6D4jCmq4L1vLBYPqGzvRf36QYn5uiWKW5fn5vvRvim2PMyyzyrvzNDNlKkjKaQAyT1ksZw)BbDGynKdSUksQAnGd4JhWlRr(gB9neF7eEzTM(smmIyyvZpzRdxdR3HNWXaHxwxvUjNcbMvTwCRRk3KtHatcNx0KxvTwHWyNAIHvn)KTENQH17Wt4yGWlRRcgjd5ammbMvTwCRRcgjd5ammbMeoVOjVQA9jwhWgqxtRvim2PMyyvZpzRPsnSEhEchdeEzDvWizihGHjWSQ1IBDvWizihGHjWKW5fn5vvRvim2PMyyvZpzRddFnSEhEchdeEzDv5MCkeyw1AXTUQCtofcmjCErtEv1AfGh7utmSQ5NS1H3PAy9o8eogi8Y6QYn5uiWSQ1IBDv5MCkeys48IM8QQ1kap2PMyyvZpzRdVt1W6D4jCmq4L1vbJKHCagMaZQwlU1vbJKHCagMatcNx0KxvTwHWyNAIHvn)KTomvQH17Wt4yGWlRRk3KtHaZQwlU1vLBYPqGjHZlAYRQwRqyStnXWQMFYwhUsRH17Wt4yGWlRRk3KtHaZQwlU1vLBYPqGjHZlAYRQwRa8yNAIHvn)KToCLwdR3HNWXaHxwxfmsgYbyycmRAT4wxfmsgYbyycmjCErtEv1AfcJDQjgw18t2A4dxdR3HNWXaHxwxvUjNcbMvTwCRRk3KtHatcNx0KxvTwb4Xo1edRA(jBn8HRH17Wt4yGWlRRcgjd5ammbMvTwCRRcgjd5ammbMeoVOjVQATcHXo1edldRkzlOdeEznvS(0Y7P1ZhjiIHvrniWH(jxuPkPkToG5akrBxIO)GwVZCKcdmSOkPkToG5G1A4d1A4da8HnSmSoT8EIibbS23IojW67g5Im5fo08GLxu(edU4y)tdRtlVNisqaR9TOtcS(UYbWfWfm0hQoyKmKdWWeKpMqoadJZBrmazyDA59erccyTVfDsG13D5JOjJlxWqdcy9HeC5346HdqOpu9tlpCmoN82ZOkchhJnTdhNxkeLWc(l3Jn5MCke485KH1W60Y7jIeeWAFl6KaRV79B8chr7sOpu9tlpCmoN82ZOAP69kGnTdhNxkeLWc(l3Jn5MCke485KHno(0YdhJZjV9mQw4P2W60Y7jIeeWAFl6KaRVls4BbloI2LqFO6NwE4yCo5TNrvaFCScAhooVuikHf8xghl3KtHaNpNmSuV)0YdhJZjV9mQo8gwgwNwEprbwFxTpsHb4iAxmSoT8EIcS(UAFKcdWr0Ue68tgxVQt1bi0hQoyKmKdWWeehKEqvGWdcC982o59mog5Jz0Nls(WEiCX9jcpO)ipJJvq75A8cbWWXa0nXDiCihiJK3JnWizihGHjioi9GQaHhe465TDY7j1gwuLwhq5wF08TS(YL1kcUmGp(5tvWwhcvv7WAo5TNruvBnf26LNvfRxU1c9JSgYbwhCEWYaK1rS(gi26xQUSoITwC3AuWBBdwRVCznf2A9LvfRb8T(jSwRi4YaU1OGS(HET1rdiieXW60Y7jkW67kGld4JF(ufFIbhr7sOpuDSjhadlKhHhCEWYadlQsR3zGyRf6hzTNwRDFUCkP1pK1VufzTqZw75ewR9SYdetSUsGSgwFyn9bhB9LUqZaR9SYdeBnLxOT(SE6jggyT295YPKHAnsoTsRf6tSMYl0wRiyWiAxSMcnNwl08dSw7(C5usK1ApHMVwc1AKBnL7fRhP8tRFPkYApTw7(C5usRf36bITwOFuOw7cndO8i2ATNYNd2AXTEGyR90AT7ZLtjjgwNwEprbwF3bIXFH3cnVnU(cW3c6bmoCmcXtdlQsRReiRfA2Ab8PswSM(qwFw7zLhi26ObeuOwJGn1w)I1uEH2Afbdgr7cX6kbYAHIB9byR1(wqw(eJ1qoW6ZAfbdgr7I1iytDOwpqS1cnBnsaEIHbw7zLhi2AgcI1cX6kbY6lT2ZkpqS1rdiiRFK1a(wWAD0qS(sxOzG1ib4jggyTNvEGyRJgqqwt5NtRVjYToITgW3cwRJG1AHMTw(n2Afbdgr7I1AFJrwhDALw7qqwRDFUCkzOwpqS1Vy9dzTqZwJOpaVSwaFQKfR1UpxoL0AkEwvS(tHbqmGTMYl0wl0S1JGAF7tmwRiyWiAxSgbBQjwxjqwFP1Ew5bIToAabzT2hZL1rS1deVS(YL1i5NtR1(gBD0PvAnKdS(SgAidaBTIGbJODjuRhi26xiwxjqwFwNEw5ObeK1Ew5bIT(rwd4BbBOwpqS1Vy9dz9lwtXZQI1FkmaIbS1uEH26GUWP830ApR8aXwhnGGqwlay)eJ1IBTIGbJODXAeSP2Ahy9dzTqZw7cndSwaFQKfRFuwvS(sR9SYdehQ1pY6Z60ZkhnGGS2ZkpqS1uEH26Z6PNyyG1A3NlNsgQ1oW6hLvfRb8TGLyDLazTqZwd9yOfRFK1y8pXyT4wZ5Y6igYbS1W6dG1jJDXAfbdgr7sOwVZpqI1i5aI1d0NySwaFQKfK1IB92PKTgnaS1cndR1yyX6bIxedRtlVNOaRVRa(ujlHd9HQlGpvYcjmH(q4deJhnGG2Rq0acIiGbJODHmcUxbSjGpvYcbEc9HWhigpAabfhlGpvYcbEI295YPKeaVDFIIJfWNkzHeMODFUCkjznaN8EwrDb8PswiWt0UpxoLKSgGtEpPoooAabreWGr0UqwoLCVcc4tLSqGNqFi8bIXJgqq7fWNkzHapr7(C5usYAao59SI6c4tLSqct0UpxoLKSgGtEp3lGpvYcbEI295YPKeaVDFIQmvQv7(C5usIagmI2fcG3Upr71UpxoLKiGbJODHa4T7tufWhG4yb8PswiHjA3NlNsswdWjVNvMk1QDFUCkjradgr7cbWB3NiQJJLdGHfI8BmU44RNRv7(C5usIagmI2fcG3UpruhhJnb8PswiHj0hcFGy8Obe0EfeWNkzHapH(q4deJhnGG2Rq0acIiGbJODHSCkzCSa(ujle4jA3NlNssa829jQcQq9Ef0UpxoLKiGbJODHa4T7tufWhG4yb8PswiWt0UpxoLKa4T7tuLPsfA3NlNsseWGr0Uqa829jI64ySjGpvYcbEc9HWhigpAabTxbSjGpvYcbEc9HW1UpxoLmowaFQKfc8eT7ZLtjjRb4K3ZkQlGpvYcjmr7(C5usYAao59mowaFQKfc8eT7ZLtjjaE7(ern1gwNwEprbwFxb8PswGp0hQUa(ujle4j0hcFGy8Obe0EfIgqqebmyeTlKrW9kGnb8PswiHj0hcFGy8ObeuCSa(ujlKWeT7ZLtjjaE7(efhlGpvYcbEI295YPKK1aCY7zf1fWNkzHeMODFUCkjznaN8EsDCC0acIiGbJODHSCk5EfeWNkzHeMqFi8bIXJgqq7fWNkzHeMODFUCkjznaN8EwrDb8PswiWt0UpxoLKSgGtEp3lGpvYcjmr7(C5uscG3UprvMk1QDFUCkjradgr7cbWB3NO9A3NlNsseWGr0Uqa829jQc4dqCSa(ujle4jA3NlNsswdWjVNvMk1QDFUCkjradgr7cbWB3NiQJJLdGHfI8BmU44RNRv7(C5usIagmI2fcG3UpruhhJnb8PswiWtOpe(aX4rdiO9kiGpvYcjmH(q4deJhnGG2Rq0acIiGbJODHSCkzCSa(ujlKWeT7ZLtjjaE7(evbvOEVcA3NlNsseWGr0Uqa829jQc4dqCSa(ujlKWeT7ZLtjjaE7(evzQuH295YPKebmyeTleaVDFIOoogBc4tLSqctOpe(aX4rdiO9kGnb8PswiHj0hcx7(C5uY4yb8PswiHjA3NlNsswdWjVNvuxaFQKfc8eT7ZLtjjRb4K3Z4yb8PswiHjA3NlNssa829jIAQnSoT8EIcS(UdeJ)cVHc9HQhnGGicyWiAxiJGXXrdiiIagmI2fYYPK71UpxoLKiGbJODHa4T7tufWhG4yOhdTGd4T7tuTA3NlNsseWGr0Uqa829jYW60Y7jkW67QV5e)0Y7j(8rsO5TX11lKH1PL3tuG13vFZj(PL3t85JKqZBJRJKqFO6NwE4yCo5TNr1s1gwNwEprbwFx9nN4NwEpXNpscnVnUUaETseTlOqFO6NwE4yCo5TNrvaVHLH1PL3terVq1JyaIbk)etOpu9Obeeradgr7czemog6Xql4aE7(evByQ2W60Y7jIOxOaRVB009fo0aaBOpu9Obeeradgr7czemog6Xql4aE7(evB4k1W60Y7jIOxOaRV7LAgjGBIRV5m0hQE0acIiGbJODHmcghd9yOfCaVDFIQnCLAyDA59er0luG13f6bC009vOpu9Obeeradgr7czemog6Xql4aE7(evlvTH1PL3terVqbwF35JHwq478JfMnoLqFO6rdiiIagmI2fYYPKgwNwEpre9cfy9DJom4oeUaETsuOpu9Obeeradgr7cz5usdRtlVNiIEHcS(UbD59m0hQE0acIiGbJODHmcUpAabrIMUVMdKqgbJJJgqqebmyeTlKrW9YbWWcHMVPqtcQLAHpaXXqpgAbhWB3NOAHVsnSmSoT8EIiiPos4BbloI2LqFO6Yn5uiiHVfS4qUEG2Rqqadhog9IeMGe(wWIJODzF0acIGe(wWId56bIa4T7tuTujooAabrqcFlyXHC9arwoLKAdRtlVNicscS(Uk)5ehr7IH1PL3tebjbwF3LpIMmUCbd9HQRD448sHOewWF5ET7ZLtjjag55jFIb)aaNcbWB3NOAXOxXXyt7WX5LcrjSG)Y9yt7WX5LcjFm0co0XXXAhooVui5JHwWHoEVcA3NlNssO8Zfok4dEbra829jQwm6vCS295YPKebmyeTleaVDFIQGkuH64y5ayyHi)gJlo(65AdtfdRtlVNicscS(UqZdWHo)KX1R6WtLqFO6YbWfWfKmcUhmsgYbyycYhtihGHX5TigGmSoT8EIiijW67khaxaxWqFO6GrYqoadtq(yc5ammoVfXa0E5a4c4csa829jQwm61ET7ZLtjjqZdWeaVDFIQfJEzyDA59erqsG13LXEWPJE4yCeTlgwNwEpreKey9DP8Zfok4dEbzyDA59erqsG13fAEWYlCeTlgwNwEpreKey9Dx8j04A6tj42c9HQd56bkq9HeCaJHZAHC9ar2oSByDA59erqsG139W3gGfdWDiCnWPGmSoT8EIiijW67cyKNN8jg8daCkgwNwEpreKey9DHZNtg2qFO6kenGGiag55jFIb)aaNczemogBAhooVuikHf8xghl3KtHmzH(M4iAxquVxHObeejiG1pIXr0UGilNsghJn5MCken9VDm4Wr0UehFA5HJX5K3Egvl8uByDA59erqsG13vadgr7sOpu9ObeejiG1pIXr0UGilNsghhnGGiag55jFIb)aaNczemooAabrO8Zfok4dEbrgbJJJgqqe485KHLmcU)0YdhJZjV9mQIWgwNwEpreKey9DbxWFHd9ao0hQoyKmKdWWe0aG5tm4iAxq7LBYPqqcGVT5N8Ef0UpxoLKayKNN8jg8daCkeaVDFIQiCaIJXM2HJZlfIsyb)LXXYn5uitwOVjoI2fe1gwNwEpreKey9DVFJx4iAxcvdREY4YbWWcQE4qFO6rdiisqaRFeJJODbrwoLmowHObeeradgr7czemogAmN4awtFammU8BCTy0Ra1hsWLFJPEVcytUjNcrt)BhdoCeTlXXNwE4yCo5TNr1cp1XXrdiiIaETsCeTlicG3UprvWyN1dHXLFJ3FA5HJX5K3EgvrydRtlVNicscS(UGl4VWHEah6dvxbT7ZLtjjag55jFIb)aaNcbWB3NOkchG4ySPD448sHOewWFzCSCtofYKf6BIJODbr9EixpqbQpKGdymCwlKRhiY2H99kenGGicyWiAxilNsghJnWizihGHj8HzYYn9eHlGbJd56bI69kenGGilFenzC5cswoLmowUjNcbja(2MFYuByDA59erqsG13vt)BhdoCeTlH(q1JgqqKGaw)ighr7cImcghd56bQcTJKapT8EsUFJx4iAxiAhjgwNwEpreKey9DpG(sghr7sOpu9ObeejiG1pIXr0UGiJGXXqUEGQq7ijWtlVNK734foI2fI2rIH1PL3tebjbwFxedcYPGJKpXeQgw9KXLdGHfu9WH(q1bmeGr0x0K3lhadle53yCXXxpxXAao590W60Y7jIGKaRVB0bahgo0hQ(PLhogNtE7zufHnSoT8EIiijW67cUG)ch6bCOpuDf0UpxoLKayKNN8jg8daCkeaVDFIQiCa2dgjd5ammbnay(edoI2fuCm20oCCEPqucl4VmowUjNczYc9nXr0UGOEpKRhOa1hsWbmgoRfY1dez7W(EfIgqqKLpIMmUCbjlNsghl3KtHGeaFBZpzQnSoT8EIiijW67Ie(wWIJODXWYW60Y7jIiGxRer7cQos4BbloI2LqFO6Yn5uiiHVfS4qUEG2)jo08Xql7JgqqeKW3cwCixpqeaVDFIQLkgwNwEpreb8ALiAxqbwF3LpIMmUCbd9HQRD448sHOewWF5ET7ZLtjjag55jFIb)aaNcbWB3NOAXOxXXyt7WX5LcrjSG)Y9yt7WX5LcjFm0co0XXXAhooVui5JHwWHoEVcA3NlNssO8Zfok4dEbra829jQwm6vCS295YPKebmyeTleaVDFIQGkuH64y5ayyHi)gJlo(65AdhadRtlVNiIaETseTlOaRVRCaCbCbd9HQdgjd5ammb5JjKdWW48wedq7LdGlGlibWB3NOAXOx71UpxoLKanpata829jQwm6LH1PL3teraVwjI2fuG13fAEao05NmUEvhEQe6dvxoaUaUGKrW9GrYqoadtq(yc5ammoVfXaKH1PL3teraVwjI2fuG13LXEWPJE4yCeTlgwNwEpreb8ALiAxqbwFxk)CHJc(GxqgwNwEpreb8ALiAxqbwFxaJ88KpXGFaGtXW60Y7jIiGxRer7ckW67cNpNmSH(q1JgqqeaJ88KpXGFaGtHmcghJnTdhNxkeLWc(lJJLBYPqMSqFtCeTlidRtlVNiIaETseTlOaRVB0bahg2W60Y7jIiGxRer7ckW67kGbJODXW60Y7jIiGxRer7ckW67cUG)ch6bCOpuDWizihGHjObaZNyWr0UG2RG295YPKeaJ88KpXGFaGtHa4T7tufHdqCm20oCCEPqucl4VmowUjNczYc9nXr0UGOEF0acIiGxRehr7cIa4T7tuf1zSZ6HW4YVXgwNwEpreb8ALiAxqbwF3734foI2Lq1WQNmUCamSGQho0hQE0acIiGxRehr7cIa4T7tuf1zSZ6HW4YVX7viAabrccy9JyCeTliYYPKXXqJ5ehWA6dGHXLFJRvFibx(noqm6vCC0acIiGbJODHmcsTH1PL3teraVwjI2fuG13DXNqJRPpLGBl0hQoKRhOa1hsWbmgoRfY1dez7WUH1PL3teraVwjI2fuG13fCb)fo0d4qFO6kODFUCkjbWipp5tm4ha4uiaE7(evr4aShmsgYbyycAaW8jgCeTlO4ySPD448sHOewWFzCm2aJKHCagMGgamFIbhr7ckowUjNczYc9nXr0UGOEF0acIiGxRehr7cIa4T7tuf1zSZ6HW4YVXgwNwEpreb8ALiAxqbwF3TXuEeTlH(q1Jgqqeb8AL4iAxqKLtjJJJgqqKGaw)ighr7cImcUhY1dufAhjbEA59KC)gVWr0Uq0os2Ra2KBYPq00)2XGdhr7sC8PLhogNtE7zufun1gwNwEpreb8ALiAxqbwFxn9VDm4Wr0Ue6dvpAabrccy9JyCeTliYi4EixpqvODKe4PL3tY9B8chr7cr7iz)PLhogNtE7zuT7KH1PL3teraVwjI2fuG13v5pN4iAxc9HQhnGGil(w4mSmz5usdRtlVNiIaETseTlOaRV7HVnalgG7q4AGtbzyDA59ereWRvIODbfy9DHMhS8chr7IH1PL3teraVwjI2fuG13fXGGCk4i5tmHQHvpzC5ayybvpCOpuDadbye9fnzdRtlVNiIaETseTlOaRV72ykpI2LqFO6qUEGQq7ijWtlVNK734foI2fI2rIH1PL3teraVwjI2fuG13fj8TGfhr7srffK1LqGNk7urksPaa]] )

end