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

    spec:RegisterSetting( "eagletalon_swap", false, {
        name = "Use |T132329:0|t Trueshot with Eagletalon's True Focus Runeforge",
        desc = "If checked, the default priority includes usage of |T132329:0|t Trueshot pre-pull, assuming you will successfully swap " ..
            "your legendary on your own.  The addon will not tell you to swap your gear.",
        type = "toggle",
        width = "full",        
    } )


    spec:RegisterPack( "Marksmanship", 20210713, [[d8exmcqic0JOkOUKkLuBIO8jeyuGWPuPAvssi5vssnlqu3cjP2fKFHGmmQcDmQsltL4zQuQPrvaxJaABQuIVHKKgNKe15qscRtssVtscPMNKW9ujTpQI(NKeIdkjbTqcWdLe1evPKuxKQGyJufK6JQusmsQcu5KssGvIKAMsICtvkjzNGi)usc1qPkizPufipLQAQQu8vQcuglcQ9c4VanyvDyHftOhtLjRIlJAZi1NrKrdsNwPvtvGQEnsmBjUTKA3u(TOHtqhhjjA5kEoutN01b12rOVJOgpsIZtuTEjjY8jY(LAaVa3a4FcLbG0fpEXRhPQEVnYJvzV3(IhaWxLlKb8fgokbjgW3IAgW)wvmuW1HHHUcb8fgYlzCaUbWhNWJJb89W9dvvH4QsicrAvOWIixwti8wdxcDtZnbTsi8w7ieGVi8w0QadqeW)ekdaPlE8Ixpsv9EBKhRYEV9fVa(bScnhaF)TUYa(q3ZHnara)dJDa(3QIHcUomm0vy)EWbBkpn1udxK3V3Bd5(V4XlEBQBQRm0WiX4Q2ut19djMmDcBN(9GyCwiY9V4(Tu7p6VMDqdBD9Rq5(JZjT(DHriYBP0FDybjg1ut197bXy5MJp9hNtA9lC2CwvE)KxfA)(BDL7Vk0dvLqa(LfRyGBa81zDuWqtfdCdaK8cCdGpBHyHpacaW3nRYZga(AuytryLJJCq60bJrSfIf(0VS(xdKUSKGQ9lRFryAAew54ihKoDWy0W1XA4(ROFbc4hoDtdWhRCCKdIHMkGcaPla3a4Zwiw4dGaa8DZQ8SbG)aBmDoKyKWe2bfmPbNOkLdi9eKQztXi2cXcF6xw)IW00i6siNhmyDmuqWcb8dNUPb4tzlfqm0ubuaiDBGBa8zlel8bqaa(UzvE2aWFGnMohsmsyc7GcM0GtuLYbKEcs1SPyeBHyHpa(Ht30a8PlHC(aIHMkGcajpaWna(SfIf(aiaaF3SkpBa4dr)UKiBHPikYNnS(L1VlZYjjBOHXPf6AKaJzsYOHRJ1W9xr)KCN(LK6xW(Djr2ctruKpBy9lRFb73LezlmfzljOkiDW9lj1VljYwykYwsqvq6G7xw)q0VlZYjjBiYB5aIfUZQy0W1XA4(ROFsUt)ss97YSCsYgI8woGyH7SkgnCDSgUFp7)2ES)79lj1Vgdjwr6wZGAcEwU)k63Rh7xsQFxMLts2qdJtl01ibgZKKrdxhRH73Z(96X(L1F40LidYgxVmUFp7)29FVFz9dr)c2)e7bKjYMIIZbJyQSyf3VKu)tShqMiBkkohmA46ynC)E2Vxp2)Da)WPBAa(NewSWGAieqbGKabUbWNTqSWhaba47Mv5zda)b2y6CiXiCcxOZHedY1I8GrSfIf(0VS(1ya1jeIgUowd3Ff9tYD6xw)UmlNKSHOlXWOHRJ1W9xr)KCha)WPBAa(AmG6ecbuaiDla3a4Zwiw4dGaa8dNUPb4txIHb8DZQ8SbGVgdOoHqeSW(L1)aBmDoKyeoHl05qIb5ArEWi2cXcFa8lRXGUdG)fbcOaqIQcCdGF40nnaFMkcljEjYGyOPc4Zwiw4dGaauaivLbUbWNTqSWhaba47Mv5zdaFb7FI9aYeztrX5GrmvwSI7xsQ)j2ditKnffNdgnCDSgUFpV2Vxbc4hoDtdWN8woGyH7SkgqbGevbWna(SfIf(aiaaF3SkpBa47YSCsYgAyCAHUgjWyMKmA46ynC)v0pj3PFz9dr)c2Vgf2uetfHLeVezqm0urSfIf(0VKu)IW00iXsMNcmwrWc7)E)ss9ly)UKiBHPikYNnS(LK63Lz5KKn0W40cDnsGXmjz0W1XA4(9SFVESFjP(ftmUFz9tVKGQGdxhRH7VI(fiGF40nnaFYXwwJeymtsgqbGKxpcCdGpBHyHpacaW3nRYZga(q0VlZYjjBiIzPWYrdxhRH7VI(j5o9lj1VG9RrHnfrmlfwoITqSWN(LK6xmX4(L1p9scQcoCDSgU)k637L(V3VS(HOFb7FI9aYeztrX5GrmvwSI7xsQ)j2ditKnffNdgnCDSgUFpV2pvr)3b8dNUPb4pmoTqxJeymtsgqbGKxVa3a4Zwiw4dGaa8DZQ8SbGVimnnAyCAHUgjWyMKmcwy)ss9ly)UKiBHPikYNnma)WPBAa(eZsHLdOaqY7fGBa8dNUPb4lgZeKyaF2cXcFaeaGcajV3g4gaF2cXcFaeaGVBwLNna8fHPPrdJtl01ibgZKKrWc7xsQFxMLts2qdJtl01ibgZKKrdxhRH73Z(96X(LK6xW(Djr2ctruKpBy9lj1VyIX9lRF6LeufC46ynC)v0)fpc4hoDtdWxhygdnvafasE9aa3a4Zwiw4dGaa8DZQ8SbG)aBmDoKyegEiTgjqm0uXi2cXcF6xw)q0VlZYjjBOHXPf6AKaJzsYOHRJ1W97z)E9y)ss9ly)UKiBHPikYNnS(LK6xW(1OWMIojSyHb1qiITqSWN(V3VS(fHPPr6SokGyOPIrdxhRH73ZR9ZuHDWkdQBnd4hoDtdWFcH7bKEhgqbGKxbcCdGpBHyHpacaWpC6MgGFS18bednvaF3SkpBa4lcttJ0zDuaXqtfJgUowd3VNx7NPc7Gvgu3AUFz9dr)IW00iHd7wmdIHMkgDsYw)ss9tdxkGd7Ggdjgu3AU)k63fyfu3AU)Q7NK70VKu)IW00iDGzm0urWc7)oGVtURWGAmKyfdajVakaK8Ela3a4Zwiw4dGaa8DZQ8SbGpD6GX9xD)UaRGdtIT(ROF60bJr1bva8dNUPb4F4qHc6GguMOgqbGKxQkWna(SfIf(aiaaF3SkpBa4dr)UmlNKSHggNwORrcmMjjJgUowd3VN971J9lR)b2y6CiXim8qAnsGyOPIrSfIf(0VKu)c2VljYwykII8zdRFjP(fS)b2y6CiXim8qAnsGyOPIrSfIf(0VKu)c2Vgf2u0jHflmOgcrSfIf(0)9(L1VimnnsN1rbednvmA46ynC)EETFMkSdwzqDRza)WPBAa(tiCpG07WakaK8wLbUbWNTqSWhaba47Mv5zdaFryAAKoRJcigAQy0jjB9lj1Vimnns4WUfZGyOPIrWc7xw)0Pdg3VN97sS2F19hoDtdfBnFaXqtf5sS2VS(HOFb7xJcBkYbDRdEcqm0urSfIf(0VKu)HtxImiBC9Y4(9S)B3)Da)WPBAa(1WfDXqtfqbGKxQcGBa8zlel8bqaa(UzvE2aWxeMMgjCy3Izqm0uXiyH9lRF60bJ73Z(Djw7V6(dNUPHITMpGyOPICjw7xw)HtxImiBC9Y4(ROFpaGF40nnaFh0To4jaXqtfqbG0fpcCdGpBHyHpacaW3nRYZga(IW00OdhhqwoJojzdWpC6MgGpLTuaXqtfqbG0fVa3a4hoDtdWpaRHNdpGjnOBsYyaF2cXcFaeaGcaPlxaUbWpC6MgGpDjKZhqm0ub8zlel8bqaakaKUCBGBa8zlel8bqaa(Ht30a8X8iKnfeRRrcW3nRYZga(dtpmgAiwyaFNCxHb1yiXkgasEbuaiDXdaCdGpBHyHpacaW3nRYZga(0Pdg3VN97sS2F19hoDtdfBnFaXqtf5sS2VS(HOFxMLts2qdJtl01ibgZKKrdxhRH73Z(fy)ss9ly)UKiBHPikYNnS(Vd4hoDtdWVgUOlgAQakaKUiqGBa8zlel8bqaa(UzvE2aWFGnMohsmYymEnsKJroguNqOW1ibgcfgtOWyeBHyHpa(Ht30a81ya1jecOaq6YTaCdGpBHyHpacaW3nRYZga(dSX05qIrgJXRrICmYXG6ecfUgjWqOWycfgJylel8bWpC6MgGp9WCvAnsG6ecbuaiDHQcCdGpBHyHpacaW3nRYZga(IW00iDGzm0urNKSb4hoDtdWxmibM0G6SokyafasxQYa3a4Zwiw4dGaa8DZQ8SbGpoHlIRDqcHXkCHb5bwOUPHylel8PFz9lcttJ0bMXqtfDsYgGF40nnaF6cJH6MGwbuaiDHQa4ga)WPBAa(yLJJCqm0ub8zlel8bqaakGc4Fy6aUOa3aajVa3a4hoDtdW3LWMYdigAQa(SfIf(aiaafasxaUbWNTqSWhaba4hoDtdW3LWMYdigAQa(UzvE2aWFGnMohsmcZcHcxLWGcN0vI6q30qSfIf(0VKu)4eUiU2bzR8adQzwWGcZfNgITqSWN(LK6hI(DPDGxfnmrEWrbmPbPZrHngXwiw4t)Y6xW(hyJPZHeJWSqOWvjmOWjDLOo0nneBHyHp9FhWVSgd6oa(32JakaKUnWna(SfIf(aiaa)WPBAa(6egvj8w2Q0AKaXqtfW)Wy3Sc1nna)BLS)akhN(d70)ntyuLWBzRsC)qYdvL7NnUEzmK7Nm3)jnc0(pz)k0f3pDo9lSeY5b3Vi7cym3)QeC6xK7xZSFSWOUwE)HD6Nm3Vlmc0(hooBrE)3mHrv2pwi7w611Vimnngb47Mv5zdaFb7xJHeROfdkSeY5bqbGKha4gaF2cXcFaeaGVBwLNna8Djr2ctruKpBy9lRFxMLts2q6aZyOPIgUowd3VS(DzwojzdnmoTqxJeymtsgnCDSgUFjP(fSFxsKTWuef5Zgw)Y63Lz5KKnKoWmgAQOHRJ1Wa(Ht30a8DrPagoDtdSSyfWVSyf0IAgWxN1OWkgqbGKabUbWNTqSWhaba4hoDtdW3fLcy40nnWYIva)YIvqlQzaF3bdOaq6waUbWNTqSWhaba47Mv5zda)WPlrgKnUEzC)v0)Tb8dNUPb47IsbmC6MgyzXkGFzXkOf1mGpwbuairvbUbWNTqSWhaba47Mv5zda)WPlrgKnUEzC)E2)fa)WPBAa(UOuadNUPbwwSc4xwScArnd4RZ6OGHMkgqbuaFHd7YAXqbUbasEbUbWpC6MgGVyQAHpG0LqoFiVgjqnPYAa(SfIf(aiaafasxaUbWpC6MgGpDHXqDtqRa(SfIf(aiaafas3g4gaF2cXcFaeaGVBwLNna8hyJPZHeJWjCHohsmixlYdgXwiw4dGF40nnaFngqDcHakaK8aa3a4Zwiw4dGaa8foSlWkOU1mGVxpc4hoDtdW)KWIfgudHa(UzvE2aWpC6sKbzJRxg3VN97TFjP(fSFxsKTWuef5Zgw)Y6xW(1OWMIiMLclhXwiw4dGcajbcCdGpBHyHpacaWpfc4JzfWpC6MgGpXy2qSWa(eJcmd4xysSDIroIdsfwJsAyqDGzq60bJrSfIf(0VS(XSQRrcJ4GuH1OKgiMCieXwiw4dG)HXUzfQBAa(vgAyK4(1SFV9Rz)4TgUek3VhYnEOjKVVh6(jXXGjhc7)MbMXqtTFHd7cSIa8jgdOf1mGpR0Gch2fyfqbG0TaCdGpBHyHpacaW3nRYZga(eJzdXcJyLgu4WUaRa(Ht30a81bMXqtfqbGevf4gaF2cXcFaeaGVBwLNna8dNUezq246LX9xr)3UFz9dr)c2VljYwykII8zdRFz9ly)AuytreZsHLJylel8PFjP(dNUezq246LX9xr)x6)E)Y6xW(jgZgIfgXknOWHDbwb8dNUPb4hBnFaXqtfqbGuvg4gaF2cXcFaeaGVBwLNna8dNUezq246LX97z)x6xsQFi63Lezlmfrr(SH1VKu)AuytreZsHLJylel8P)79lR)WPlrgKnUEzC)x7)s)ss9tmMnelmIvAqHd7cSc4hoDtdWhRCCKdIHMkGcOa(Udg4gai5f4gaF2cXcFaeaGVBwLNna8HOFryAAKoWmgAQiyH9lRFryAA0W40cDnsGXmjzeSW(L1VljYwykII8zdR)79lj1pe9lcttJ0bMXqtfblSFz9lcttJiVLdiw4oRIrWc7xw)UKiBHPiBjbvbPdU)79lj1pe97sISfMIiYMcv(0VKu)UKiBHPiJDtwY50)9(L1VimnnshygdnveSW(LK6xmX4(L1p9scQcoCDSgU)k637T7xsQFi63Lezlmfrr(SH1VS(fHPPrdJtl01ibgZKKrWc7xw)Ijg3VS(PxsqvWHRJ1W9xr)u1B3)Da)WPBAa(I8G5HYAKauaiDb4gaF2cXcFaeaGVBwLNna8fHPPr6aZyOPIGf2VKu)UmlNKSH0bMXqtfnCDSgUFp7)2ESFjP(ftmUFz9tVKGQGdxhRH7VI(9Ela(Ht30a8flzEaPHh5akaKUnWna(SfIf(aiaaF3SkpBa4lcttJ0bMXqtfblSFjP(DzwojzdPdmJHMkA46ynC)E2)T9y)ss9lMyC)Y6NEjbvbhUowd3Ff979wa8dNUPb4hMJX6efqxukakaK8aa3a4Zwiw4dGaa8DZQ8SbGVimnnshygdnveSW(LK63Lz5KKnKoWmgAQOHRJ1W97z)32J9lj1VyIX9lRF6LeufC46ynC)v0pvbGF40nnaF6DyXsMhafasce4gaF2cXcFaeaGVBwLNna8fHPPr6aZyOPIojzdWpC6MgGFzjbvXGEWdFivZMcOaq6waUbWNTqSWhaba47Mv5zdaFryAAKoWmgAQiyH9lRFi6xeMMgjwY8uGXkcwy)ss9RXqIveuokkuKqN2Ff9FXJ9FVFjP(ftmUFz9tVKGQGdxhRH7VI(VCl9lj1pe97sISfMIOiF2W6xw)IW00OHXPf6AKaJzsYiyH9lRFXeJ7xw)0ljOk4W1XA4(ROFQ6L(Vd4hoDtdWxyQBAakGc4JvGBaGKxGBa8zlel8bqaa(UzvE2aWxJcBkcRCCKdsNoymITqSWN(L1pe9lCyIGKChKxew54ihedn1(L1VimnncRCCKdsNoymA46ynC)v0Va7xsQFryAAew54ihKoDWy0jjB9FVFz9dr)IW00OHXPf6AKaJzsYOts26xsQFb73Lezlmfrr(SH1)Da)WPBAa(yLJJCqm0ubuaiDb4ga)WPBAa(u2sbednvaF2cXcFaeaGcaPBdCdGpBHyHpacaW3nRYZga(q0VljYwykII8zdRFz9dr)UmlNKSHggNwORrcmMjjJgUowd3Ff9tYD6)E)ss9ly)UKiBHPikYNnS(L1VG97sISfMISLeufKo4(LK63LezlmfzljOkiDW9lRFi63Lz5KKne5TCaXc3zvmA46ynC)v0pj3PFjP(DzwojzdrElhqSWDwfJgUowd3VN9FBp2)9(LK6xJHeRiDRzqnbpl3Ff97vG9FVFz9dr)c2)e7bKjYMIIZbJyQSyf3VKu)tShqMiBkkohmAT(9S)B7X(LK6xW(Djr2ctruKpBy9FhWpC6MgG)jHflmOgcbuai5baUbWNTqSWhaba47Mv5zdaFngqDcHiyH9lR)b2y6CiXiCcxOZHedY1I8GrSfIf(a4hoDtdWNUeddOaqsGa3a4Zwiw4dGaa8DZQ8SbG)aBmDoKyeoHl05qIb5ArEWi2cXcF6xw)AmG6ecrdxhRH7VI(j5o9lRFxMLts2q0Lyy0W1XA4(ROFsUdGF40nnaFngqDcHakaKUfGBa8dNUPb4ZuryjXlrgednvaF2cXcFaeaGcajQkWna(SfIf(aiaaF3SkpBa4ly)tShqMiBkkohmIPYIvC)ss9pXEazISPO4CWOHRJ1W9751(9kqa)WPBAa(K3YbelCNvXakaKQYa3a4hoDtdWNUeY5digAQa(SfIf(aiaafasufa3a4Zwiw4dGaa8DZQ8SbGpD6GX9xD)UaRGdtIT(ROF60bJr1bva8dNUPb4F4qHc6GguMOgqbGKxpcCdGF40nna)aSgEo8aM0GUjjJb8zlel8bqaakaK86f4gaF2cXcFaeaGVBwLNna8DzwojzdnmoTqxJeymtsgnCDSgU)k6NK70VS(HOFb7xJcBkIPIWsIxImigAQi2cXcF6xsQFryAAKyjZtbgRiyH9FVFjP(fSFxsKTWuef5Zgw)ss97YSCsYgAyCAHUgjWyMKmA46ynC)ss9lMyC)Y6NEjbvbhUowd3Ff9lqa)WPBAa(KJTSgjWyMKmGcajVxaUbWNTqSWhaba47Mv5zdaFi6xeMMgDsyXcdQHqeSW(LK6xW(1OWMIojSyHb1qiITqSWN(LK6xJHeRiDRzqnbpl3Ff979s)37xw)q0VG9pXEazISPO4CWiMklwX9lj1)e7bKjYMIIZbJgUowd3VN9tv0)Da)WPBAa(dJtl01ibgZKKbuai592a3a4Zwiw4dGaa8DZQ8SbGVimnnAyCAHUgjWyMKmcwy)ss9ly)UKiBHPikYNnS(L1pe9lcttJeoSBXmigAQy0jjB9lj1VG9RrHnf5GU1bpbigAQi2cXcF6xsQ)WPlrgKnUEzC)v0)L(Vd4hoDtdWNywkSCafasE9aa3a4Zwiw4dGaa8DZQ8SbGVljYwykII8zdRFz9tNoyC)v3VlWk4WKyR)k6NoDWyuDqL(L1pe9dr)UmlNKSHggNwORrcmMjjJgUowd3Ff9tYD6VkQ(VD)Y6hI(fSFCcxex7GyAAy8sKbdBRdWW54cpHMdITqSWN(LK6xW(1OWMIojSyHb1qiITqSWN(V3)9(LK6xJcBk6KWIfgudHi2cXcF6xw)UmlNKSHojSyHb1qiA46ynC)v0)T7)oGF40nnaFSYXroigAQakaK8kqGBa8zlel8bqaa(UzvE2aWxeMMgjCy3Izqm0uXOts26xw)q0VljYwykIiBku5t)ss97sISfMIm2nzjNt)ss9RrHnf5IsznsGkugednvmITqSWN(V3VKu)IW00OHXPf6AKaJzsYiyH9lj1VimnnI8woGyH7SkgblSFjP(fHPPreZsHLJGf2VS(dNUezq246LX97z)E7xsQFi6xmX4(L1p9scQcoCDSgU)k6)Ia7xw)c2)e7bKjYMIIZbJyQSyf3)Da)WPBAa(6aZyOPcOaqY7TaCdGpBHyHpacaW3nRYZga(dSX05qIry4H0AKaXqtfJylel8PFz9RrHnfH1HJ6YAmITqSWN(L1pe97YSCsYgAyCAHUgjWyMKmA46ynC)E2Vxp2VKu)c2VljYwykII8zdRFjP(fSFnkSPOtclwyqneIylel8PFjP(XjCrCTdIPPHXlrgmSToadNJl8eAoi2cXcF6)oGF40nna)jeUhq6DyafasEPQa3a4Zwiw4dGaa8dNUPb4hBnFaXqtfW3nRYZga(IW00iHd7wmdIHMkgDsYw)ss9dr)IW00iDGzm0urWc7xsQFA4sbCyh0yiXG6wZ9xr)KCN(RUFxGvqDR5(V3VS(HOFb7xJcBkYbDRdEcqm0urSfIf(0VKu)HtxImiBC9Y4(RO)l9FVFjP(fHPPr6SokGyOPIrdxhRH73Z(zQWoyLb1TM7xw)HtxImiBC9Y4(9SFVa(o5UcdQXqIvmaK8cOaqYBvg4gaF2cXcFaeaGVBwLNna8HOFxMLts2qdJtl01ibgZKKrdxhRH73Z(96X(LK6xW(Djr2ctruKpBy9lj1VG9RrHnfDsyXcdQHqeBHyHp9lj1poHlIRDqmnnmEjYGHT1by4CCHNqZbXwiw4t)37xw)0Pdg3F197cScomj26VI(PthmgvhuPFz9dr)IW00OtclwyqneIojzRFjP(1OWMIW6WrDzngXwiw4t)3b8dNUPb4pHW9asVddOaqYlvbWna(SfIf(aiaaF3SkpBa4lcttJeoSBXmigAQyeSW(LK6NoDW4(9SFxI1(RU)WPBAOyR5digAQixIva)WPBAa(oOBDWtaIHMkGcaPlEe4gaF2cXcFaeaGVBwLNna8fHPPrch2Tygednvmcwy)ss9tNoyC)E2VlXA)v3F40nnuS18bednvKlXkGF40nna)yCHXGyOPcOaq6IxGBa8zlel8bqaa(Ht30a8X8iKnfeRRrcW3nRYZga(dtpmgAiw4(L1Vgdjwr6wZGAcEwUFp7)apHUPb47K7kmOgdjwXaqYlGcaPlxaUbWNTqSWhaba47Mv5zda)WPlrgKnUEzC)E2Vxa)WPBAa(IXmbjgqbG0LBdCdGpBHyHpacaW3nRYZga(q0VlZYjjBOHXPf6AKaJzsYOHRJ1W97z)E9y)Y6FGnMohsmcdpKwJeigAQyeBHyHp9lj1VG97sISfMIOiF2W6xsQFb7xJcBk6KWIfgudHi2cXcF6xsQFCcxex7GyAAy8sKbdBRdWW54cpHMdITqSWN(V3VS(PthmU)Q73fyfCysS1Ff9tNoymQoOs)Y6hI(fHPPrNewSWGAieDsYw)ss9RrHnfH1HJ6YAmITqSWN(Vd4hoDtdWFcH7bKEhgqbG0fpaWna(SfIf(aiaaF3SkpBa4lcttJ0bMXqtfDsYgGF40nnaFXGeysdQZ6OGbuaiDrGa3a4Zwiw4dGaa8DZQ8SbGpoHlIRDqcHXkCHb5bwOUPHylel8PFz9lcttJ0bMXqtfDsYgGF40nnaF6cJH6MGwbuaiD5waUbWpC6MgGpw54ihednvaF2cXcFaeaGcOa(6SgfwXa3aajVa3a4Zwiw4dGaa8tHa(ywb8dNUPb4tmMnelmGpXOaZa(IW00OHXPf6AKaJzsYiyH9lj1VimnnshygdnveSqaFIXaArnd4JLBoqyHakaKUaCdGpBHyHpacaWpfc4JzfWpC6MgGpXy2qSWa(eJcmd47sISfMIOiF2W6xw)IW00OHXPf6AKaJzsYiyH9lRFryAAKoWmgAQiyH9lj1VG97sISfMIOiF2W6xw)IW00iDGzm0urWcb8jgdOf1mGpwN0ibILBoqyHakaKUnWna(SfIf(aiaa)uiGpM1LgWpC6MgGpXy2qSWa(eJb0IAgWhRtAKaXYnh4W1XAyaF3SkpBa4lcttJ0bMXqtfDsYw)Y63Lezlmfrr(SHb4tmkWmixWmGVlZYjjBiDGzm0urdxhRHb8jgfygW3Lz5KKn0W40cDnsGXmjz0W1XA4(ROks)UmlNKSH0bMXqtfnCDSggqbGKha4gaF2cXcFaeaGFkeWhZ6sd4hoDtdWNymBiwyaFIXaArnd4J1jnsGy5MdC46ynmGVBwLNna8fHPPr6aZyOPIGf2VS(Djr2ctruKpBya(eJcmdYfmd47YSCsYgshygdnv0W1XAyaFIrbMb8DzwojzdnmoTqxJeymtsgnCDSggqbGKabUbWNTqSWhaba4Ncb8XSU0a(Ht30a8jgZgIfgWNymGwuZa(y5MdC46ynmGVBwLNna8Djr2ctruKpBya(eJcmdYfmd47YSCsYgshygdnv0W1XAyaFIrbMb8DzwojzdnmoTqxJeymtsgnCDSgUFpRI0VlZYjjBiDGzm0urdxhRHbuaiDla3a4Zwiw4dGaa8dNUPb4RZAuy1lGVBwLNna8HOFDwJcRi1lcAGbHXmOimnD)ss97sISfMIOiF2W6xw)6SgfwrQxe0ad6YSCsYw)37xw)q0pXy2qSWiSoPrcel3CGWc7xw)q0VG97sISfMIOiF2W6xw)c2VoRrHvKEbbnWGWygueMMUFjP(Djr2ctruKpBy9lRFb7xN1OWksVGGgyqxMLts26xsQFDwJcRi9cYLz5KKn0W1XA4(LK6xN1OWks9IGgyqymdkctt3VS(HOFb7xN1OWksVGGgyqymdkctt3VKu)6SgfwrQxKlZYjjBOd8e6Mw)EETFDwJcRi9cYLz5KKn0bEcDtR)79lj1VoRrHvK6fbnWGUmlNKS1VS(fSFDwJcRi9ccAGbHXmOimnD)Y6xN1OWks9ICzwojzdDGNq3063ZR9RZAuyfPxqUmlNKSHoWtOBA9FVFjP(fSFIXSHyHryDsJeiwU5aHf2VS(HOFb7xN1OWksVGGgyqymdkctt3VS(HOFDwJcRi1lYLz5KKn0bEcDtRFQUFb2Ff9tmMnelmcl3CGdxhRH7xsQFIXSHyHry5MdC46ynC)E2VoRrHvK6f5YSCsYg6apHUP1pH6)s)37xsQFDwJcRi9ccAGbHXmOimnD)Y6hI(1znkSIuViObgegZGIW009lRFDwJcRi1lYLz5KKn0bEcDtRFpV2VoRrHvKEb5YSCsYg6apHUP1VS(HOFDwJcRi1lYLz5KKn0bEcDtRFQUFb2Ff9tmMnelmcl3CGdxhRH7xsQFIXSHyHry5MdC46ynC)E2VoRrHvK6f5YSCsYg6apHUP1pH6)s)37xsQFi6xW(1znkSIuViObgegZGIW009lj1VoRrHvKEb5YSCsYg6apHUP1VNx7xN1OWks9ICzwojzdDGNq306)E)Y6hI(1znkSI0lixMLts2qdhh59lRFDwJcRi9cYLz5KKn0bEcDtRFQUFb2VN9tmMnelmcl3CGdxhRH7xw)eJzdXcJWYnh4W1XA4(ROFDwJcRi9cYLz5KKn0bEcDtRFc1)L(LK6xW(1znkSI0lixMLts2qdhh59lRFi6xN1OWksVGCzwojzdnCDSgUFQUFb2Ff9tmMnelmcRtAKaXYnh4W1XA4(L1pXy2qSWiSoPrcel3CGdxhRH73Z(V4X(L1pe9RZAuyfPErUmlNKSHoWtOBA9t19lW(ROFIXSHyHry5MdC46ynC)ss9RZAuyfPxqUmlNKSHgUowd3pv3Va7VI(jgZgIfgHLBoWHRJ1W9lRFDwJcRi9cYLz5KKn0bEcDtRFQUFVES)Q7NymBiwyewU5ahUowd3Ff9tmMnelmcRtAKaXYnh4W1XA4(LK6NymBiwyewU5ahUowd3VN9RZAuyfPErUmlNKSHoWtOBA9tO(V0VKu)eJzdXcJWYnhiSW(V3VKu)6Sgfwr6fKlZYjjBOHRJ1W9t19lW(9SFIXSHyHryDsJeiwU5ahUowd3VS(HOFDwJcRi1lYLz5KKn0bEcDtRFQUFb2Ff9tmMnelmcRtAKaXYnh4W1XA4(LK6xW(1znkSIuViObgegZGIW009lRFi6NymBiwyewU5ahUowd3VN9RZAuyfPErUmlNKSHoWtOBA9tO(V0VKu)eJzdXcJWYnhiSW(V3)9(V3)9(V3)9(LK6xmX4(L1p9scQcoCDSgU)k6NymBiwyewU5ahUowd3)9(LK6xW(1znkSIuViObgegZGIW009lRFb73Lezlmfrr(SH1VS(HOFDwJcRi9ccAGbHXmOimnD)Y6hI(HOFb7NymBiwyewU5aHf2VKu)6Sgfwr6fKlZYjjBOHRJ1W97z)cS)79lRFi6NymBiwyewU5ahUowd3VN9FXJ9lj1VoRrHvKEb5YSCsYgA46ynC)uD)cSFp7NymBiwyewU5ahUowd3)9(V3VKu)c2VoRrHvKEbbnWGWygueMMUFz9dr)c2VoRrHvKEbbnWGUmlNKS1VKu)6Sgfwr6fKlZYjjBOHRJ1W9lj1VoRrHvKEb5YSCsYg6apHUP1VNx7xN1OWks9ICzwojzdDGNq306)E)3b8XLuXa(6Sgfw9cOaqIQcCdGpBHyHpacaWpC6MgGVoRrH1la(UzvE2aWhI(1znkSI0liObgegZGIW009lj1VljYwykII8zdRFz9RZAuyfPxqqdmOlZYjjB9FVFz9dr)eJzdXcJW6KgjqSCZbclSFz9dr)c2VljYwykII8zdRFz9ly)6SgfwrQxe0adcJzqryA6(LK63Lezlmfrr(SH1VS(fSFDwJcRi1lcAGbDzwojzRFjP(1znkSIuVixMLts2qdxhRH7xsQFDwJcRi9ccAGbHXmOimnD)Y6hI(fSFDwJcRi1lcAGbHXmOimnD)ss9RZAuyfPxqUmlNKSHoWtOBA9751(1znkSIuVixMLts2qh4j0nT(V3VKu)6Sgfwr6fe0ad6YSCsYw)Y6xW(1znkSIuViObgegZGIW009lRFDwJcRi9cYLz5KKn0bEcDtRFpV2VoRrHvK6f5YSCsYg6apHUP1)9(LK6xW(jgZgIfgH1jnsGy5Mdewy)Y6hI(fSFDwJcRi1lcAGbHXmOimnD)Y6hI(1znkSI0lixMLts2qh4j0nT(P6(fy)v0pXy2qSWiSCZboCDSgUFjP(jgZgIfgHLBoWHRJ1W97z)6Sgfwr6fKlZYjjBOd8e6Mw)eQ)l9FVFjP(1znkSIuViObgegZGIW009lRFi6xN1OWksVGGgyqymdkctt3VS(1znkSI0lixMLts2qh4j0nT(98A)6SgfwrQxKlZYjjBOd8e6Mw)Y6hI(1znkSI0lixMLts2qh4j0nT(P6(fy)v0pXy2qSWiSCZboCDSgUFjP(jgZgIfgHLBoWHRJ1W97z)6Sgfwr6fKlZYjjBOd8e6Mw)eQ)l9FVFjP(HOFb7xN1OWksVGGgyqymdkctt3VKu)6SgfwrQxKlZYjjBOd8e6Mw)EETFDwJcRi9cYLz5KKn0bEcDtR)79lRFi6xN1OWks9ICzwojzdnCCK3VS(1znkSIuVixMLts2qh4j0nT(P6(fy)E2pXy2qSWiSCZboCDSgUFz9tmMnelmcl3CGdxhRH7VI(1znkSIuVixMLts2qh4j0nT(ju)x6xsQFb7xN1OWks9ICzwojzdnCCK3VS(HOFDwJcRi1lYLz5KKn0W1XA4(P6(fy)v0pXy2qSWiSoPrcel3CGdxhRH7xw)eJzdXcJW6KgjqSCZboCDSgUFp7)Ih7xw)q0VoRrHvKEb5YSCsYg6apHUP1pv3Va7VI(jgZgIfgHLBoWHRJ1W9lj1VoRrHvK6f5YSCsYgA46ynC)uD)cS)k6NymBiwyewU5ahUowd3VS(1znkSIuVixMLts2qh4j0nT(P6(96X(RUFIXSHyHry5MdC46ynC)v0pXy2qSWiSoPrcel3CGdxhRH7xsQFIXSHyHry5MdC46ynC)E2VoRrHvKEb5YSCsYg6apHUP1pH6)s)ss9tmMnelmcl3CGWc7)E)ss9RZAuyfPErUmlNKSHgUowd3pv3Va73Z(jgZgIfgH1jnsGy5MdC46ynC)Y6hI(1znkSI0lixMLts2qh4j0nT(P6(fy)v0pXy2qSWiSoPrcel3CGdxhRH7xsQFb7xN1OWksVGGgyqymdkctt3VS(HOFIXSHyHry5MdC46ynC)E2VoRrHvKEb5YSCsYg6apHUP1pH6)s)ss9tmMnelmcl3CGWc7)E)37)E)37)E)37xsQFXeJ7xw)0ljOk4W1XA4(ROFIXSHyHry5MdC46ynC)37xsQFb7xN1OWksVGGgyqymdkctt3VS(fSFxsKTWuef5Zgw)Y6hI(1znkSIuViObgegZGIW009lRFi6hI(fSFIXSHyHry5Mdewy)ss9RZAuyfPErUmlNKSHgUowd3VN9lW(V3VS(HOFIXSHyHry5MdC46ynC)E2)fp2VKu)6SgfwrQxKlZYjjBOHRJ1W9t19lW(9SFIXSHyHry5MdC46ynC)37)E)ss9ly)6SgfwrQxe0adcJzqryA6(L1pe9ly)6SgfwrQxe0ad6YSCsYw)ss9RZAuyfPErUmlNKSHgUowd3VKu)6SgfwrQxKlZYjjBOd8e6Mw)EETFDwJcRi9cYLz5KKn0bEcDtR)79FhWhxsfd4RZAuy9cGcOakGprEWBAaq6IhV41JuvpwLb8jhJTgjmGVhSQqpiivfaPBLQ2F)3aL7FRfMJ2pDo9tGoRJcgAQyc6FyQs4D4t)4SM7pG1Sou(0VdAyKymQPUsRX97TQ9x50iYJYN(jqJcBkIWe0VM9tGgf2ueHrSfIf(qq)q4Lk3rn1vAnU)lvT)kNgrEu(0pbdSX05qIreMG(1SFcgyJPZHeJimITqSWhc6hcVu5oQPUsRX9F7Q2FLtJipkF6NGb2y6CiXictq)A2pbdSX05qIregXwiw4db9hA)EivXvQFi8sL7OM6kTg3VaRA)vonI8O8PFcgyJPZHeJimb9Rz)emWgtNdjgryeBHyHpe0peEPYDutDLwJ7)wQA)vonI8O8PFcgyJPZHeJimb9Rz)emWgtNdjgryeBHyHpe0FO97HufxP(HWlvUJAQR0AC)ufvT)kNgrEu(0pbAuytreMG(1SFc0OWMIimITqSWhc6hcVu5oQPUsRX971JvT)kNgrEu(0pbAuytreMG(1SFc0OWMIimITqSWhc6hcVu5oQPUsRX971du1(RCAe5r5t)eOrHnfryc6xZ(jqJcBkIWi2cXcFiOFi8sL7OM6kTg3Vxpqv7VYPrKhLp9tWaBmDoKyeHjOFn7NGb2y6CiXicJylel8HG(HWlvUJAQR0AC)EPQvT)kNgrEu(0pbAuytreMG(1SFc0OWMIimITqSWhc6hcVu5oQPUsRX97LQw1(RCAe5r5t)emWgtNdjgryc6xZ(jyGnMohsmIWi2cXcFiOFiUqL7OM6kTg3V3QCv7VYPrKhLp9tGgf2ueHjOFn7NankSPicJylel8HG(HWlvUJAQR0AC)xeyv7VYPrKhLp9tWaBmDoKyeHjOFn7NGb2y6CiXicJylel8HG(dTFpKQ4k1peEPYDutDLwJ7)YTu1(RCAe5r5t)emWgtNdjgryc6xZ(jyGnMohsmIWi2cXcFiO)q73dPkUs9dHxQCh1uxP14(VuLRA)vonI8O8PFcWjCrCTdIWe0VM9taoHlIRDqegXwiw4db9dHxQCh1u3u7bRk0dcsvbq6wPQ93)nq5(3AH5O9tNt)eCy6aUOe0)WuLW7WN(Xzn3FaRzDO8PFh0WiXyutDLwJ7)sv7VYPrKhLp9tWaBmDoKyeHjOFn7NGb2y6CiXicJylel8HG(HWlvUJAQR0AC)xQA)vonI8O8PFcgyJPZHeJimb9Rz)emWgtNdjgryeBHyHpe0peEPYDutDLwJ7)sv7VYPrKhLp9tGlTd8Qictq)A2pbU0oWRIimITqSWhc6hcVu5oQPUsRX9FPQ9x50iYJYN(jaNWfX1oictq)A2pb4eUiU2bryeBHyHpe0peEPYDutDtThSQqpiivfaPBLQ2F)3aL7FRfMJ2pDo9tGWHDzTyOe0)WuLW7WN(Xzn3FaRzDO8PFh0WiXyutDLwJ7)2vT)kNgrEu(0pbdSX05qIreMG(1SFcgyJPZHeJimITqSWhc6p0(9qQIRu)q4Lk3rn1vAnUFpqv7VYPrKhLp9tGgf2ueHjOFn7NankSPicJylel8HG(dTFpKQ4k1peEPYDutDLwJ7NQw1(RCAe5r5t)eOrHnfryc6xZ(jqJcBkIWi2cXcFiOFi8sL7OM6kTg3FvUQ9x50iYJYN(jqJcBkIWe0VM9tGgf2ueHrSfIf(qq)q4Lk3rn1n1EWQc9GGuvaKUvQA)9FduU)TwyoA)050pbyLG(hMQeEh(0poR5(dynRdLp97GggjgJAQR0AC)ERA)vonI8O8PFc0OWMIimb9Rz)eOrHnfryeBHyHpe0peEPYDutDLwJ73du1(RCAe5r5t)emWgtNdjgryc6xZ(jyGnMohsmIWi2cXcFiO)q73dPkUs9dHxQCh1uxP14(fyv7VYPrKhLp9tWaBmDoKyeHjOFn7NGb2y6CiXicJylel8HG(HWlvUJAQR0AC)E9w1(RCAe5r5t)eOrHnfryc6xZ(jqJcBkIWi2cXcFiOFi8sL7OM6kTg3V3lvT)kNgrEu(0pbAuytreMG(1SFc0OWMIimITqSWhc6hcVu5oQPUsRX9792vT)kNgrEu(0pbAuytreMG(1SFc0OWMIimITqSWhc6hcVu5oQPUsRX971du1(RCAe5r5t)eOrHnfryc6xZ(jqJcBkIWi2cXcFiOFiUqL7OM6kTg3Vxpqv7VYPrKhLp9taoHlIRDqeMG(1SFcWjCrCTdIWi2cXcFiOFi8sL7OM6kTg3Vxbw1(RCAe5r5t)eOrHnfryc6xZ(jqJcBkIWi2cXcFiOFi8sL7OM6kTg3V3BPQ9x50iYJYN(jqJcBkIWe0VM9tGgf2ueHrSfIf(qq)qCHk3rn1vAnUFV3sv7VYPrKhLp9tWaBmDoKyeHjOFn7NGb2y6CiXicJylel8HG(HWlvUJAQR0AC)EVLQ2FLtJipkF6NaCcxex7Gimb9Rz)eGt4I4AheHrSfIf(qq)q4Lk3rn1vAnUFVu1Q2FLtJipkF6NankSPictq)A2pbAuytregXwiw4db9dHxQCh1uxP14(9wLRA)vonI8O8PFc0OWMIimb9Rz)eOrHnfryeBHyHpe0pexOYDutDLwJ73BvUQ9x50iYJYN(jaNWfX1oictq)A2pb4eUiU2bryeBHyHpe0peEPYDutDLwJ7)YTRA)vonI8O8PFc0OWMIimb9Rz)eOrHnfryeBHyHpe0pexOYDutDLwJ7)YTRA)vonI8O8PFcgyJPZHeJimb9Rz)emWgtNdjgryeBHyHpe0peEPYDutDLwJ7)YTRA)vonI8O8PFcWjCrCTdIWe0VM9taoHlIRDqegXwiw4db9dHxQCh1uxP14(ViWQ2FLtJipkF6NaCcxex7Gimb9Rz)eGt4I4AheHrSfIf(qq)q4Lk3rn1n1EWQc9GGuvaKUvQA)9FduU)TwyoA)050pb6SgfwXe0)WuLW7WN(Xzn3FaRzDO8PFh0WiXyutDLwJ7)wQA)vonI8O8PF)TUY9JLBAqL(V19Rz)vco6)Sex8Mw)PqEcnN(HGq37hcbsL7OM6kTg3)Tu1(RCAe5r5t)eOZAuyf5fryc6xZ(jqN1OWks9Iimb9dXfVu5oQPUsRX9FlvT)kNgrEu(0pb6SgfwrxqeMG(1SFc0znkSI0lictq)qC5wOYDutDLwJ7NQw1(RCAe5r5t)(BDL7hl30Gk9FR7xZ(ReC0)zjU4nT(tH8eAo9dbHU3pecKk3rn1vAnUFQAv7VYPrKhLp9tGoRrHvKxeHjOFn7NaDwJcRi1lIWe0pexUfQCh1uxP14(PQvT)kNgrEu(0pb6SgfwrxqeMG(1SFc0znkSI0lictq)qCXlvUJAQBQVbk3pbWygCvUgtq)Ht306NCG73sTF6e2o9Vw)k0f3)wlmhf1uxfulmhLp9Fl9hoDtR)YIvmQPgWhlKDaq6Ia9aa(cNKElmGVh2d3)TQyOGRdddDf2VhCWMYttTh2d3p1Wf59792qU)lE8I3M6MApShU)kdnmsmUQn1EypC)uD)qIjtNW2PFpigNfIC)lUFl1(J(Rzh0Wwx)kuU)4CsRFxyeI8wk9xhwqIrn1EypC)uD)EqmwU54t)X5Kw)cNnNvL3p5vH2V)wx5(Rc9qvjutDtD40nnms4WUSwm0QVsiXu1cFaPlHC(qEnsGAsL1AQdNUPHrch2L1IHw9vcrxymu3e0AtD40nnms4WUSwm0QVsingqDcHqEPVoWgtNdjgHt4cDoKyqUwKhCtD40nnms4WUSwm0QVsOtclwyqneczHd7cScQBnF1RhH8sFnC6sKbzJRxg7PxjjbDjr2ctruKpByYeuJcBkIywkS8MApC)vgAyK4(1SFV9Rz)4TgUek3VhYnEOjKVVh6(jXXGjhc7)MbMXqtTFHd7cSIAQdNUPHrch2L1IHw9vcrmMnelmKTOMVYknOWHDbwHmXOaZxlmj2oXihXbPcRrjnmOoWmiD6GXi2cXcFKHzvxJegXbPcRrjnqm5qiITqSWNM6WPBAyKWHDzTyOvFLq6aZyOPc5L(kXy2qSWiwPbfoSlWAtD40nnms4WUSwm0QVsOyR5digAQqEPVgoDjYGSX1lJR42YGqqxsKTWuef5ZgMmb1OWMIiMLclxskC6sKbzJRxgxXL7YeKymBiwyeR0Gch2fyTPoC6MggjCyxwlgA1xjew54ihednviV0xdNUezq246LXEErsccxsKTWuef5ZgMKKgf2ueXSuy53LfoDjYGSX1lJVErsIymBiwyeR0Gch2fyTPUPoC6MgU6ReYLWMYdigAQn1Ht30WvFLqUe2uEaXqtfYL1yq356T9iKx6RdSX05qIrywiu4Qegu4KUsuh6MMKeoHlIRDq2kpWGAMfmOWCXPjjbHlTd8QOHjYdokGjniDokSXYeCGnMohsmcZcHcxLWGcN0vI6q30U3u7H7)wj7pGYXP)Wo9FZegvj8w2Qe3pK8qv5(zJRxgxfD)K5(pPrG2)j7xHU4(PZPFHLqop4(fzxaJ5(xLGt)IC)AM9Jfg11Y7pSt)K5(DHrG2)WXzlY7)MjmQY(Xcz3sVU(fHPPXOM6WPBA4QVsiDcJQeElBvAnsGyOPc5L(QGAmKyfTyqHLqopn1Ht30WvFLqUOuadNUPbwwSczlQ5R6SgfwXqEPV6sISfMIOiF2WK5YSCsYgshygdnv0W1XAyzUmlNKSHggNwORrcmMjjJgUowdljjOljYwykII8zdtMlZYjjBiDGzm0urdxhRHBQ9WE4(VvZLqE)0HBns9lpHN(pjSO2pSPBPF5jC)qdIC)cH1(9GyCAHUgP(RcNjj3)jjBqU)C6FP7xHY97YSCsYw)lUFnZ(lPrQFn7)WLqE)0HBns9lpHN(VvNWIkQ)Qa6(T04(t6(vOmM73L2z1nnC)XW9hIfUFn7VM1(jVk016xHY971J9JzxAhC)fMjhYHC)kuUF8w3pD4yC)Yt4P)B1jSO2FaRzDORlkf5OMApShU)WPBA4QVsiJjtNW2bCyCwiYqEPVIt4I4AhKXKPty7aomolezzqicttJggNwORrcmMjjJGfkj5YSCsYgAyCAHUgjWyMKmA46ynSNE9OKKyIXYOxsqvWHRJ1Wv49wU3uhoDtdx9vc5IsbmC6MgyzXkKTOMV6o4M6WPBA4QVsixukGHt30allwHSf18vSc5L(A40LidYgxVmUIB3uhoDtdx9vc5IsbmC6MgyzXkKTOMVQZ6OGHMkgYl91WPlrgKnUEzSNxAQBQdNUPHrUd(QipyEOSgjiV0xHqeMMgPdmJHMkcwOmryAA0W40cDnsGXmjzeSqzUKiBHPikYNnS7ssqicttJ0bMXqtfbluMimnnI8woGyH7SkgbluMljYwykYwsqvq6GVljbHljYwykIiBku5JKKljYwykYy3KLCo3LjcttJ0bMXqtfblussmXyz0ljOk4W1XA4k8EBjjiCjr2ctruKpByYeHPPrdJtl01ibgZKKrWcLjMySm6LeufC46ynCfu1BFVPoC6Mgg5o4QVsiXsMhqA4roKx6RIW00iDGzm0urWcLKCzwojzdPdmJHMkA46ynSN32JssIjglJEjbvbhUowdxH3BPPoC6Mgg5o4QVsOWCmwNOa6IsbYl9vryAAKoWmgAQiyHssUmlNKSH0bMXqtfnCDSg2ZB7rjjXeJLrVKGQGdxhRHRW7T0uhoDtdJChC1xje9oSyjZdKx6RIW00iDGzm0urWcLKCzwojzdPdmJHMkA46ynSN32JssIjglJEjbvbhUowdxbvrtD40nnmYDWvFLqLLeufd6bp8HunBkKx6RIW00iDGzm0urNKS1uhoDtdJChC1xjKWu30G8sFveMMgPdmJHMkcwOmieHPPrILmpfySIGfkjPXqIveuokkuKqNwXfpExssmXyz0ljOk4W1XA4kUClssq4sISfMIOiF2WKjcttJggNwORrcmMjjJGfktmXyz0ljOk4W1XA4kOQxU3u3uhoDtdJW6vSYXroigAQqEPVQrHnfHvooYbPthmwgechMiij3b5fHvooYbXqtvMimnncRCCKdsNoymA46ynCfcusseMMgHvooYbPthmgDsY2DzqicttJggNwORrcmMjjJojztssqxsKTWuef5Zg29M6WPBAyewR(kHOSLcigAQn1Ht30WiSw9vcDsyXcdQHqiV0xHWLezlmfrr(SHjdcxMLts2qdJtl01ibgZKKrdxhRHRGK7CxssqxsKTWuef5ZgMmbDjr2ctr2scQcshSKKljYwykYwsqvq6GLbHlZYjjBiYB5aIfUZQy0W1XA4ki5ossUmlNKSHiVLdiw4oRIrdxhRH982E8UKKgdjwr6wZGAcEwUcVc8UmieCI9aYeztrX5GrmvwSILKMypGmr2uuCoy0AEEBpkjjOljYwykII8zd7EtD40nnmcRvFLq0LyyiV0x1ya1jeIGfkBGnMohsmcNWf6CiXGCTip4M6WPBAyewR(kH0ya1jec5L(6aBmDoKyeoHl05qIb5ArEWY0ya1jeIgUowdxbj3rMlZYjjBi6smmA46ynCfKCNM6WPBAyewR(kHyQiSK4LidIHMAtD40nnmcRvFLqK3YbelCNvXqEPVk4e7bKjYMIIZbJyQSyfljnXEazISPO4CWOHRJ1WEE1RaBQdNUPHryT6ReIUeY5digAQn1Ht30WiSw9vcD4qHc6GguMOgYl9v60bJR2fyfCysSvbD6GXO6Gkn1Ht30WiSw9vcfG1WZHhWKg0njzCtD40nnmcRvFLqKJTSgjWyMKmKx6RUmlNKSHggNwORrcmMjjJgUowdxbj3rgecQrHnfXuryjXlrgednvjjryAAKyjZtbgRiyH3LKe0Lezlmfrr(SHjj5YSCsYgAyCAHUgjWyMKmA46ynSKKyIXYOxsqvWHRJ1WviWM6WPBAyewR(kHggNwORrcmMjjd5L(keIW00OtclwyqneIGfkjjOgf2u0jHflmOgcLK0yiXks3AgutWZYv49YDzqi4e7bKjYMIIZbJyQSyfljnXEazISPO4CWOHRJ1WEsvCVPoC6MggH1QVsiIzPWYH8sFveMMgnmoTqxJeymtsgblussqxsKTWuef5ZgMmieHPPrch2Tygednvm6KKnjjb1OWMICq36GNaednvjPWPlrgKnUEzCfxU3uhoDtdJWA1xjew54ihednviV0xDjr2ctruKpByYOthmUAxGvWHjXwf0PdgJQdQidciCzwojzdnmoTqxJeymtsgnCDSgUcsUtvu3wgecIt4I4AhettdJxImyyBDagohx4j0CKKeuJcBk6KWIfgudH3VljPrHnfDsyXcdQHqzUmlNKSHojSyHb1qiA46ynCf3(EtD40nnmcRvFLq6aZyOPc5L(Qimnns4WUfZGyOPIrNKSjdcxsKTWuer2uOYhjjxsKTWuKXUjl5CKK0OWMICrPSgjqfkdIHMk(UKKimnnAyCAHUgjWyMKmcwOKKimnnI8woGyH7SkgblusseMMgrmlfwocwOSWPlrgKnUEzSNELKGqmXyz0ljOk4W1XA4kUiqzcoXEazISPO4CWiMklwX3BQdNUPHryT6ReAcH7bKEhgYl91b2y6CiXim8qAnsGyOPILPrHnfH1HJ6YASmiCzwojzdnmoTqxJeymtsgnCDSg2tVEussqxsKTWuef5ZgMKKGAuytrNewSWGAiuscNWfX1oiMMggVezWW26amCoUWtO5CVPoC6MggH1QVsOyR5digAQq2j3vyqngsSIV6fYl9vryAAKWHDlMbXqtfJojztsccryAAKoWmgAQiyHss0WLc4WoOXqIb1TMRGK7uTlWkOU18DzqiOgf2uKd6wh8eGyOPkjfoDjYGSX1lJR4YDjjryAAKoRJcigAQy0W1XAypzQWoyLb1TMLfoDjYGSX1lJ90BtD40nnmcRvFLqtiCpG07WqEPVcHlZYjjBOHXPf6AKaJzsYOHRJ1WE61Jssc6sISfMIOiF2WKKeuJcBk6KWIfgudHss4eUiU2bX00W4Lidg2whGHZXfEcnN7YOthmUAxGvWHjXwf0PdgJQdQidcryAA0jHflmOgcrNKSjjPrHnfH1HJ6YA89M6WPBAyewR(kHCq36GNaednviV0xfHPPrch2TygednvmcwOKeD6GXE6sSwD40nnuS18bednvKlXAtD40nnmcRvFLqX4cJbXqtfYl9vryAAKWHDlMbXqtfJGfkjrNoySNUeRvhoDtdfBnFaXqtf5sS2uhoDtdJWA1xjeMhHSPGyDnsq2j3vyqngsSIV6fYl91HPhgdnelSmngsSI0TMb1e8SSNh4j0nTM6WPBAyewR(kHeJzcsmKx6RHtxImiBC9Yyp92uhoDtdJWA1xj0ec3di9omKx6Rq4YSCsYgAyCAHUgjWyMKmA46ynSNE9OSb2y6CiXim8qAnsGyOPILKe0Lezlmfrr(SHjjjOgf2u0jHflmOgcLKWjCrCTdIPPHXlrgmSToadNJl8eAo3LrNoyC1UaRGdtITkOthmgvhurgeIW00OtclwyqneIojztssJcBkcRdh1L147n1Ht30WiSw9vcjgKatAqDwhfmKx6RIW00iDGzm0urNKS1uhoDtdJWA1xjeDHXqDtqRqEPVIt4I4AhKqyScxyqEGfQBAYeHPPr6aZyOPIojzRPoC6MggH1QVsiSYXroigAQn1n1Ht30WiDwhfm0uXxXkhh5GyOPc5L(Qgf2uew54ihKoDWyzRbsxwsqvzIW00iSYXroiD6GXOHRJ1WviWM6WPBAyKoRJcgAQ4QVsikBPaIHMkKx6RdSX05qIrctyhuWKgCIQuoG0tqQMnflteMMgrxc58GbRJHccwytD40nnmsN1rbdnvC1xjeDjKZhqm0uH8sFDGnMohsmsyc7GcM0GtuLYbKEcs1SP4M6WPBAyKoRJcgAQ4QVsOtclwyqnec5L(keUKiBHPikYNnmzUmlNKSHggNwORrcmMjjJgUowdxbj3rssqxsKTWuef5ZgMmbDjr2ctr2scQcshSKKljYwykYwsqvq6GLbHlZYjjBiYB5aIfUZQy0W1XA4ki5ossUmlNKSHiVLdiw4oRIrdxhRH982E8UKKgdjwr6wZGAcEwUcVEusYLz5KKn0W40cDnsGXmjz0W1XAyp96rzHtxImiBC9YypV9Dzqi4e7bKjYMIIZbJyQSyfljnXEazISPO4CWOHRJ1WE61J3BQdNUPHr6SokyOPIR(kH0ya1jec5L(6aBmDoKyeoHl05qIb5ArEWY0ya1jeIgUowdxbj3rMlZYjjBi6smmA46ynCfKCNM6WPBAyKoRJcgAQ4QVsi6smmKlRXGUZ1lceYl9vngqDcHiyHYgyJPZHeJWjCHohsmixlYdUPoC6MggPZ6OGHMkU6ReIPIWsIxImigAQn1Ht30WiDwhfm0uXvFLqK3YbelCNvXqEPVk4e7bKjYMIIZbJyQSyfljnXEazISPO4CWOHRJ1WEE1RaBQdNUPHr6SokyOPIR(kHihBznsGXmjziV0xDzwojzdnmoTqxJeymtsgnCDSgUcsUJmieuJcBkIPIWsIxImigAQssIW00iXsMNcmwrWcVljjOljYwykII8zdtsYLz5KKn0W40cDnsGXmjz0W1XAyp96rjjXeJLrVKGQGdxhRHRqGn1Ht30WiDwhfm0uXvFLqdJtl01ibgZKKH8sFfcxMLts2qeZsHLJgUowdxbj3rssqnkSPiIzPWYLKetmwg9scQcoCDSgUcVxUldcbNypGmr2uuCoyetLfRyjPj2ditKnffNdgnCDSg2ZRuf3BQdNUPHr6SokyOPIR(kHiMLclhYl9vryAA0W40cDnsGXmjzeSqjjbDjr2ctruKpByn1Ht30WiDwhfm0uXvFLqIXmbjUPoC6MggPZ6OGHMkU6ReshygdnviV0xfHPPrdJtl01ibgZKKrWcLKCzwojzdnmoTqxJeymtsgnCDSg2tVEussqxsKTWuef5ZgMKKyIXYOxsqvWHRJ1WvCXJn1Ht30WiDwhfm0uXvFLqtiCpG07WqEPVoWgtNdjgHHhsRrcednvSmiCzwojzdnmoTqxJeymtsgnCDSg2tVEussqxsKTWuef5ZgMKKGAuytrNewSWGAi8UmryAAKoRJcigAQy0W1XAypVYuHDWkdQBn3uhoDtdJ0zDuWqtfx9vcfBnFaXqtfYo5UcdQXqIv8vVqEPVkcttJ0zDuaXqtfJgUowd75vMkSdwzqDRzzqicttJeoSBXmigAQy0jjBss0WLc4WoOXqIb1TMRWfyfu3AUAsUJKKimnnshygdnveSW7n1Ht30WiDwhfm0uXvFLqhouOGoObLjQH8sFLoDW4QDbwbhMeBvqNoymQoOstD40nnmsN1rbdnvC1xj0ec3di9omKx6Rq4YSCsYgAyCAHUgjWyMKmA46ynSNE9OSb2y6CiXim8qAnsGyOPILKe0Lezlmfrr(SHjjj4aBmDoKyegEiTgjqm0uXsscQrHnfDsyXcdQHW7YeHPPr6SokGyOPIrdxhRH98ktf2bRmOU1CtD40nnmsN1rbdnvC1xjunCrxm0uH8sFveMMgPZ6OaIHMkgDsYMKKimnns4WUfZGyOPIrWcLrNoySNUeRvhoDtdfBnFaXqtf5sSkdcb1OWMICq36GNaednvjPWPlrgKnUEzSN3(EtD40nnmsN1rbdnvC1xjKd6wh8eGyOPc5L(Qimnns4WUfZGyOPIrWcLrNoySNUeRvhoDtdfBnFaXqtf5sSklC6sKbzJRxgxHhOPoC6MggPZ6OGHMkU6ReIYwkGyOPc5L(Qimnn6WXbKLZOts2AQdNUPHr6SokyOPIR(kHcWA45Wdysd6MKmUPoC6MggPZ6OGHMkU6ReIUeY5digAQn1Ht30WiDwhfm0uXvFLqyEeYMcI11ibzNCxHb1yiXk(QxiV0xhMEym0qSWn1Ht30WiDwhfm0uXvFLq1WfDXqtfYl9v60bJ90LyT6WPBAOyR5digAQixIvzq4YSCsYgAyCAHUgjWyMKmA46ynSNcussqxsKTWuef5Zg29M6WPBAyKoRJcgAQ4QVsingqDcHqEPVoWgtNdjgzmgVgjYXihdQtiu4AKadHcJjuyCtD40nnmsN1rbdnvC1xje9WCvAnsG6ecH8sFDGnMohsmYymEnsKJroguNqOW1ibgcfgtOW4M6WPBAyKoRJcgAQ4QVsiXGeysdQZ6OGH8sFveMMgPdmJHMk6KKTM6WPBAyKoRJcgAQ4QVsi6cJH6MGwH8sFfNWfX1oiHWyfUWG8alu30KjcttJ0bMXqtfDsYwtD40nnmsN1rbdnvC1xjew54ihedn1M6M6WPBAyKoRrHv8vIXSHyHHSf18vSCZbcleYeJcmFveMMgnmoTqxJeymtsgblusseMMgPdmJHMkcwytD40nnmsN1OWkU6ReIymBiwyiBrnFfRtAKaXYnhiSqitmkW8vxsKTWuef5ZgMmryAA0W40cDnsGXmjzeSqzIW00iDGzm0urWcLKe0Lezlmfrr(SHjteMMgPdmJHMkcwytD40nnmsN1OWkU6ReIymBiwyiBrnFfRtAKaXYnh4W1XAyiNcVIzDPHmXOaZxDzwojzdnmoTqxJeymtsgnCDSgUIQiUmlNKSH0bMXqtfnCDSggYeJcmdYfmF1Lz5KKnKoWmgAQOHRJ1WqEPVkcttJ0bMXqtfDsYMmxsKTWuef5ZgwtD40nnmsN1OWkU6ReIymBiwyiBrnFfRtAKaXYnh4W1XAyiNcVIzDPHmXOaZxDzwojzdnmoTqxJeymtsgnCDSggYeJcmdYfmF1Lz5KKnKoWmgAQOHRJ1WqEPVkcttJ0bMXqtfbluMljYwykII8zdRPoC6MggPZAuyfx9vcrmMnelmKTOMVILBoWHRJ1WqofEfZ6sd5L(QljYwykII8zddYeJcmF1Lz5KKn0W40cDnsGXmjz0W1XAypRI4YSCsYgshygdnv0W1XAyitmkWmixW8vxMLts2q6aZyOPIgUowd3uhoDtdJ0znkSIR(kHGXm4QCngY4sQ4R6Sgfw9c5L(ke6SgfwrErqdmimMbfHPPLKCjr2ctruKpByY0znkSI8IGgyqxMLts2UldcIXSHyHryDsJeiwU5aHfkdcbDjr2ctruKpByYeuN1OWk6ccAGbHXmOimnTKKljYwykII8zdtMG6SgfwrxqqdmOlZYjjBss6SgfwrxqUmlNKSHgUowdljPZAuyf5fbnWGWygueMMwgecQZAuyfDbbnWGWygueMMwssN1OWkYlYLz5KKn0bEcDtZZR6SgfwrxqUmlNKSHoWtOBA3LK0znkSI8IGgyqxMLts2KjOoRrHv0fe0adcJzqryAAz6SgfwrErUmlNKSHoWtOBAEEvN1OWk6cYLz5KKn0bEcDt7UKKGeJzdXcJW6KgjqSCZbclugecQZAuyfDbbnWGWygueMMwge6SgfwrErUmlNKSHoWtOBAuTaRGymBiwyewU5ahUowdljrmMnelmcl3CGdxhRH9uN1OWkYlYLz5KKn0bEcDt7wF5UKKoRrHv0fe0adcJzqryAAzqOZAuyf5fbnWGWygueMMwMoRrHvKxKlZYjjBOd8e6MMNx1znkSIUGCzwojzdDGNq30KbHoRrHvKxKlZYjjBOd8e6MgvlWkigZgIfgHLBoWHRJ1WsseJzdXcJWYnh4W1XAyp1znkSI8ICzwojzdDGNq30U1xUljbHG6SgfwrErqdmimMbfHPPLK0znkSIUGCzwojzdDGNq3088QoRrHvKxKlZYjjBOd8e6M2DzqOZAuyfDb5YSCsYgA44ixMoRrHv0fKlZYjjBOd8e6MgvlqpjgZgIfgHLBoWHRJ1WYigZgIfgHLBoWHRJ1WvOZAuyfDb5YSCsYg6apHUPDRVijjOoRrHv0fKlZYjjBOHJJCzqOZAuyfDb5YSCsYgA46ynmvlWkigZgIfgH1jnsGy5MdC46ynSmIXSHyHryDsJeiwU5ahUowd75fpkdcDwJcRiVixMLts2qh4j0nnQwGvqmMnelmcl3CGdxhRHLK0znkSIUGCzwojzdnCDSgMQfyfeJzdXcJWYnh4W1XAyz6SgfwrxqUmlNKSHoWtOBAuTxpwnXy2qSWiSCZboCDSgUcIXSHyHryDsJeiwU5ahUowdljrmMnelmcl3CGdxhRH9uN1OWkYlYLz5KKn0bEcDt7wFrsIymBiwyewU5aHfExssN1OWk6cYLz5KKn0W1XAyQwGEsmMnelmcRtAKaXYnh4W1XAyzqOZAuyf5f5YSCsYg6apHUPr1cScIXSHyHryDsJeiwU5ahUowdljjOoRrHvKxe0adcJzqryAAzqqmMnelmcl3CGdxhRH9uN1OWkYlYLz5KKn0bEcDt7wFrsIymBiwyewU5aHfE)(973VljjMySm6LeufC46ynCfeJzdXcJWYnh4W1XA47sscQZAuyf5fbnWGWygueMMwMGUKiBHPikYNnmzqOZAuyfDbbnWGWygueMMwgeqiiXy2qSWiSCZbclussN1OWk6cYLz5KKn0W1XAypf4DzqqmMnelmcl3CGdxhRH98IhLK0znkSIUGCzwojzdnCDSgMQfONeJzdXcJWYnh4W1XA473LKeuN1OWk6ccAGbHXmOimnTmieuN1OWk6ccAGbDzwojztssN1OWk6cYLz5KKn0W1XAyjjDwJcROlixMLts2qh4j0nnpVQZAuyf5f5YSCsYg6apHUPD)EtD40nnmsN1OWkU6RecgZGRY1yiJlPIVQZAuy9cKx6RqOZAuyfDbbnWGWygueMMwsYLezlmfrr(SHjtN1OWk6ccAGbDzwojz7UmiigZgIfgH1jnsGy5MdewOmie0Lezlmfrr(SHjtqDwJcRiViObgegZGIW00ssUKiBHPikYNnmzcQZAuyf5fbnWGUmlNKSjjPZAuyf5f5YSCsYgA46ynSKKoRrHv0fe0adcJzqryAAzqiOoRrHvKxe0adcJzqryAAjjDwJcROlixMLts2qh4j0nnpVQZAuyf5f5YSCsYg6apHUPDxssN1OWk6ccAGbDzwojztMG6SgfwrErqdmimMbfHPPLPZAuyfDb5YSCsYg6apHUP55vDwJcRiVixMLts2qh4j0nT7sscsmMnelmcRtAKaXYnhiSqzqiOoRrHvKxe0adcJzqryAAzqOZAuyfDb5YSCsYg6apHUPr1cScIXSHyHry5MdC46ynSKeXy2qSWiSCZboCDSg2tDwJcROlixMLts2qh4j0nTB9L7ss6SgfwrErqdmimMbfHPPLbHoRrHv0fe0adcJzqryAAz6SgfwrxqUmlNKSHoWtOBAEEvN1OWkYlYLz5KKn0bEcDttge6SgfwrxqUmlNKSHoWtOBAuTaRGymBiwyewU5ahUowdljrmMnelmcl3CGdxhRH9uN1OWk6cYLz5KKn0bEcDt7wF5UKeecQZAuyfDbbnWGWygueMMwssN1OWkYlYLz5KKn0bEcDtZZR6SgfwrxqUmlNKSHoWtOBA3LbHoRrHvKxKlZYjjBOHJJCz6SgfwrErUmlNKSHoWtOBAuTa9KymBiwyewU5ahUowdlJymBiwyewU5ahUowdxHoRrHvKxKlZYjjBOd8e6M2T(IKKG6SgfwrErUmlNKSHgooYLbHoRrHvKxKlZYjjBOHRJ1WuTaRGymBiwyewN0ibILBoWHRJ1WYigZgIfgH1jnsGy5MdC46ynSNx8Omi0znkSIUGCzwojzdDGNq30OAbwbXy2qSWiSCZboCDSgwssN1OWkYlYLz5KKn0W1XAyQwGvqmMnelmcl3CGdxhRHLPZAuyf5f5YSCsYg6apHUPr1E9y1eJzdXcJWYnh4W1XA4kigZgIfgH1jnsGy5MdC46ynSKeXy2qSWiSCZboCDSg2tDwJcROlixMLts2qh4j0nTB9fjjIXSHyHry5Mdew4DjjDwJcRiVixMLts2qdxhRHPAb6jXy2qSWiSoPrcel3CGdxhRHLbHoRrHv0fKlZYjjBOd8e6MgvlWkigZgIfgH1jnsGy5MdC46ynSKKG6SgfwrxqqdmimMbfHPPLbbXy2qSWiSCZboCDSg2tDwJcROlixMLts2qh4j0nTB9fjjIXSHyHry5Mdew4973VF)UKKyIXYOxsqvWHRJ1WvqmMnelmcl3CGdxhRHVljjOoRrHv0fe0adcJzqryAAzc6sISfMIOiF2WKbHoRrHvKxe0adcJzqryAAzqaHGeJzdXcJWYnhiSqjjDwJcRiVixMLts2qdxhRH9uG3LbbXy2qSWiSCZboCDSg2ZlEussN1OWkYlYLz5KKn0W1XAyQwGEsmMnelmcl3CGdxhRHVFxssqDwJcRiViObgegZGIW00YGqqDwJcRiViObg0Lz5KKnjjDwJcRiVixMLts2qdxhRHLK0znkSI8ICzwojzdDGNq3088QoRrHv0fKlZYjjBOd8e6M297akGcaa]] )

    
end