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


    spec:RegisterPack( "Marksmanship", 20210708, [[d8KYgcqiIOhrvqUecISjc1NakJcbofq1QOkqQxjj1SasDlKe2fKFbKmmQcDmQsltf8meKMgvbCnIqBtsK(gsImoeeCoQcuRtssVtsePMhvr3di2NKW)OkO0bPkOAHij9qjrnreesxuseSrQck(OKiQrkjIKtkjcTsKuZusIBIGqStvO(jcc1qLerSuKeLNsvnvviFLQaXyrqTxa)fKbRQdlSycEmvMSkDzuBgP(mIA0QOtR0QPkqYRrIzlXTLu7MYVfnCc54iiQLR45qnDsxhuBhr(ocnEIGZtKwpsIQ5tu7xQb8cCeG)nug44dE8GxpsL8iHaYRh96b7Lkb4RsfXa(IchLGmd4Brnd4tismuW1HHpxra(IcPLmUahb4Jt4XXa(EO(pvveUQGcuKx9ewa5YAqH3A4sOBAUjOvqH3AhOa8fG3IwjAaca(3qzGJp4XdE9ivYJeciVE0RhSh9Gb8dy9mhaF)TUYa(N79YgGaG)LXoaFcrIHcUom85kQ)kPGnLNMAQHls7Nqa09FWJh82u3ux5ZWiZ4Q2utf9FmtKoHTB)uzmolK4(xC)wQ9h9xZUZWwx)6j3FCVP1VlmqrClL(RdliZOMAQOFQmgl1C8T)4EtRFrZMZQs7N4QN97V1vUFp8kjvbb4xwSIbocWxN1rbFMkg4iGJ9cCeGpBHqHVaufW3nRYZga(AuytryLJRui60bJrSfcf(2V4(xdIUSKp1(f3VamnncRCCLcrNoymA46ynC)E2Veb8dNUPb4JvoUsHWNPcOahFa4iaF2cHcFbOkGVBwLNna8Djj2ctruKoBy9lUFxMLBs0qdJtl01idfZKerdxhRH73Z(j7U9ll3VK97ssSfMIOiD2W6xC)s2VljXwykYwYNkeDW9ll3VljXwykYwYNkeDW9lUFc63Lz5MeneXTCHWI2zvmA46ynC)E2pz3TFz5(DzwUjrdrClxiSODwfJgUowd3Ff9tOESFW7xwUFHeJ7xC)0l5tfA46ynC)E2Vxp2VSC)Uml3KOHggNwORrgkMjjIgUowd3Ff971J9lU)WPljgInUEzC)v0pHc4hoDtdW)MWcfgsdrakWXekWra(Sfcf(cqvaF3SkpBa4pWgtNdzgHt4cDoKziUwGhmITqOW3(f3VgdKoHi0W1XA4(9SFYUB)I73Lz5MeneDjggnCDSgUFp7NS7c4hoDtdWxJbsNqeGcCSha4iaF2cHcFbOkGVBwLNna81yG0jeHGf1V4(hyJPZHmJWjCHohYmexlWdgXwiu4lGF40nnaF6smmGcCSebocWpC6MgGplbrLeVKyi8zQa(Sfcf(cqvaf44kf4ia)WPBAa(e3YfclANvXa(Sfcf(cqvaf4yQeWra(Sfcf(cqvaF3SkpBa47YSCtIgAyCAHUgzOyMKiA46ynC)E2pz3TFX9tq)s2Vgf2uelbrLeVKyi8zQi2cHcF7xwUFbyAAKqjZBbgRiyr9dE)YY9lz)UKeBHPiksNnS(LL73Lz5Men0W40cDnYqXmjr0W1XA4(ROFVESFz5(fsmUFX9tVKpvOHRJ1W97z)seWpC6MgGpXylRrgkMjjcOahtiaCeGpBHqHVaufW3nRYZga(Uml3KOHiLLclfnCDSgUFp7NS72VSC)s2Vgf2uePSuyPi2cHcF7xwUFHeJ7xC)0l5tfA46ynC)E2V3da(Ht30a8hgNwORrgkMjjcOah7bdCeGpBHqHVaufW3nRYZga(cW00OHXPf6AKHIzsIiyr9ll3VK97ssSfMIOiD2Wa8dNUPb4tklfwkGcCSxpcCeGF40nnaFHyMGmd4Zwiu4lavbuGJ96f4iaF2cHcFbOkGVBwLNna8fGPPrdJtl01idfZKerWI6xwUFxMLBs0qdJtl01idfZKerdxhRH7VI(96X(LL7xY(Djj2ctruKoBy9ll3VqIX9lUF6L8PcnCDSgUFp7)Ghb8dNUPb4RdmJptfqbo27bGJa8zlek8fGQa(UzvE2aWFGnMohYmcdpKxJme(mvmITqOW3(f3pb97YSCtIgAyCAHUgzOyMKiA46ynC)v0Vxp2VSC)s2VljXwykII0zdRFz5(LSFnkSPOBcluyineHylek8TFW7xC)cW00iDwhfi8zQy0W1XA4(RaK(zjWoyLH0TMb8dNUPb4pHO9crVddOah7LqbocWNTqOWxaQc4hoDtdWp2A(cHptfW3nRYZga(cW00iDwhfi8zQy0W1XA4(RaK(zjWoyLH0TM7xC)e0Vamnns0WUfZq4ZuXOBs06xwUFA4sbAy3zmKziDR5(9SFxGviDR5(RUFYUB)YY9lattJ0bMXNPIGf1p4a(oPUcdPXqMvmWXEbuGJ96baocWNTqOWxaQc47Mv5zdaF60bJ7V6(DbwHgMmB97z)0PdgJQdja4hoDtdW)YHEc5odktudOah7vIahb4Zwiu4lavb8DZQ8SbGpb97YSCtIgAyCAHUgzOyMKiA46ynC)v0Vxp2V4(hyJPZHmJWWd51idHptfJylek8TFz5(LSFxsITWuefPZgw)YY9lz)dSX05qMry4H8AKHWNPIrSfcf(2VSC)s2Vgf2u0nHfkmKgIqSfcf(2p49lUFbyAAKoRJce(mvmA46ynC)vas)SeyhSYq6wZa(Ht30a8Nq0EHO3HbuGJ9wPahb4Zwiu4lavb8DZQ8SbGVamnnsN1rbcFMkgDtIw)YY9lattJenSBXme(mvmcwu)I7NoDW4(ROFxI1(RU)WPBAOyR5le(mvKlXA)I7NG(LSFnkSPi35wh8eq4ZurSfcf(2VSC)HtxsmeBC9Y4(ROFcTFWb8dNUPb4xdx0fFMkGcCSxQeWra(Sfcf(cqvaF3SkpBa4lattJenSBXme(mvmcwu)I7NoDW4(ROFxI1(RU)WPBAOyR5le(mvKlXA)I7pC6sIHyJRxg3VN97ba8dNUPb47o36GNacFMkGcCSxcbGJa8zlek8fGQa(UzvE2aWxaMMgD54cXsz0njAa(Ht30a8PSLce(mvaf4yVEWahb4hoDtdWpGQHNlpqjnKBsIyaF2cHcFbOkGcC8bpcCeGF40nnaF6siLVq4Zub8zlek8fGQakWXh8cCeGpBHqHVaufWpC6MgGpMhrSPqyDnYa(UzvE2aWFy6HXNHqHb8DsDfgsJHmRyGJ9cOahF4aWra(Sfcf(cqvaF3SkpBa4tNoyC)v0VlXA)v3F40nnuS18fcFMkYLyTFX9tq)Uml3KOHggNwORrgkMjjIgUowd3Ff9lX(LL7xY(Djj2ctruKoBy9doGF40nna)A4IU4ZubuGJpqOahb4Zwiu4lavb8DZQ8SbG)aBmDoKzKXy8AKjgJumKoHirRrgkejkMqHXi2cHcFb8dNUPb4RXaPticqbo(Gha4iaF2cHcFbOkGVBwLNna8hyJPZHmJmgJxJmXyKIH0jejAnYqHirXekmgXwiu4lGF40nnaF6HzQ81idPticqbo(GebocWNTqOWxaQc47Mv5zdaFbyAAKoWm(mv0njAa(Ht30a8fcYqjnKoRJcgqbo(qLcCeGpBHqHVaufW3nRYZga(4eUiS2fjcgRWfgIhyr6MgITqOW3(f3VamnnshygFMk6Mena)WPBAa(0fgF6MGwbuGJpqLaocWpC6MgGpw54kfcFMkGpBHqHVaufqbua)lthWff4iGJ9cCeGF40nnaFxcBkpq4Zub8zlek8fGQakWXhaocWNTqOWxaQc4hoDtdW3LWMYde(mvaF3SkpBa4pWgtNdzgHzrNWu5yirt6krDOBAi2cHcF7xwUFCcxew7ISvAGH0mlyir5ItdXwiu4B)YY9tq)U0UWRIgMep4OaL0q05OWgJylek8TFX9lz)dSX05qMryw0jmvogs0KUsuh6MgITqOW3(bhWVSgd5Ua(eQhbuGJjuGJa8zlek8fGQa(Ht30a81jmcz4TSu5RrgcFMkG)LXUzfPBAa(vYz)Xjh3(d72)rtyeYWBzPY5(pUssL7NnUEzmO7Ni3)nnW0(Vz)65I7NoN(fvcP8G7xGDbmM7FvWU9lW9Rz2pwuuxlT)WU9tK73fgyA)dh3TiT)JMWiK7hlIDl966xaMMgJa8DZQ8SbGVK9RXqMv0IHevcP8aOah7baocWNTqOWxaQc47Mv5zdaFxsITWuefPZgw)I73Lz5MenKoWm(mv0W1XA4(f3VlZYnjAOHXPf6AKHIzsIOHRJ1W9ll3VK97ssSfMIOiD2W6xC)Uml3KOH0bMXNPIgUowdd4hoDtdW3fLcu40nnOYIva)YIvilQzaFDwJcRyaf4yjcCeGpBHqHVaufWpC6MgGVlkfOWPBAqLfRa(LfRqwuZa(UlgqboUsbocWNTqOWxaQc47Mv5zda)WPljgInUEzC)E2pHc4hoDtdW3fLcu40nnOYIva)YIvilQzaFScOahtLaocWNTqOWxaQc47Mv5zda)WPljgInUEzC)v0)ba)WPBAa(UOuGcNUPbvwSc4xwSczrnd4RZ6OGptfdOakGVOHDzTqOahbCSxGJa8dNUPb4lKQw4leDjKYxIRrgstjSgGpBHqHVaufqbo(aWra(Ht30a8Plm(0nbTc4Zwiu4lavbuGJjuGJa8zlek8fGQa(UzvE2aWFGnMohYmcNWf6CiZqCTapyeBHqHVa(Ht30a81yG0jebOah7baocWNTqOWxaQc4lAyxGviDRzaFVEeWpC6MgG)nHfkmKgIa8DZQ8SbGF40LedXgxVmU)k63B)YY9lz)UKeBHPiksNnS(f3VK9RrHnfrklfwkITqOWxaf4yjcCeGpBHqHVaufWpfb4JzfWpC6MgGpPy2qOWa(KIcmd4xyYSDJrkIdYfwJsAyiDGzi60bJrSfcf(2V4(XSQRrgJ4GCH1OKgeMyicXwiu4lG)LXUzfPBAa(v(mmYC)A2V3(1SF8wdxcL7Vs4ipmGY33dt)K5yWedr9F0aZ4Zu7x0WUaRiaFsXazrnd4ZknKOHDbwbuGJRuGJa8zlek8fGQa(UzvE2aWNumBiuyeR0qIg2fyfWpC6MgGVoWm(mvaf4yQeWra(Sfcf(cqvaF3SkpBa4hoDjXqSX1lJ73Z(j0(f3pb9lz)UKeBHPiksNnS(f3VK9RrHnfrklfwkITqOW3(LL7pC6sIHyJRxg3VN9FOFW7xC)s2pPy2qOWiwPHenSlWkGF40nna)yR5le(mvaf4ycbGJa8zlek8fGQa(UzvE2aWpC6sIHyJRxg3Ff9FOFz5(jOFxsITWuefPZgw)YY9RrHnfrklfwkITqOW3(bVFX9hoDjXqSX1lJ7hK(p0VSC)KIzdHcJyLgs0WUaRa(Ht30a8XkhxPq4ZubuafW3DXahbCSxGJa8zlek8fGQa(UzvE2aWNG(fGPPr6aZ4ZurWI6xC)cW00OHXPf6AKHIzsIiyr9lUFxsITWuefPZgw)G3VSC)e0VamnnshygFMkcwu)I7xaMMgrClxiSODwfJGf1V4(Djj2ctr2s(uHOdUFW7xwUFc63LKylmfrIn9u60VSC)UKeBHPiJDtwY52p49lUFbyAAKoWm(mveSO(LL7xiX4(f3p9s(uHgUowd3VN97Lq7xwUFc63LKylmfrr6SH1V4(fGPPrdJtl01idfZKerWI6xC)cjg3V4(PxYNk0W1XA4(9SFQeH2p4a(Ht30a8f4bZdL1idOahFa4iaF2cHcFbOkGVBwLNna8fGPPr6aZ4ZurWI6xwUFxMLBs0q6aZ4ZurdxhRH7VI(jup2VSC)cjg3V4(PxYNk0W1XA4(9SFVvkGF40nnaFHsMxiA4rkGcCmHcCeGpBHqHVaufW3nRYZga(cW00iDGz8zQiyr9ll3VlZYnjAiDGz8zQOHRJ1W9xr)eQh7xwUFHeJ7xC)0l5tfA46ynC)E2V3kfWpC6MgGFyogRtuGCrPaOah7baocWNTqOWxaQc47Mv5zdaFbyAAKoWm(mveSO(LL73Lz5MenKoWm(mv0W1XA4(ROFc1J9ll3VqIX9lUF6L8PcnCDSgUFp73dgWpC6MgGp9oSqjZlGcCSebocWNTqOWxaQc47Mv5zdaFbyAAKoWm(mv0njAa(Ht30a8ll5tfd5bf8LCnBkGcCCLcCeGpBHqHVaufW3nRYZga(cW00iDGz8zQiyr9lUFc6xaMMgjuY8wGXkcwu)YY9RXqMv0jhf9ejYP97z)h8y)G3VSC)cjg3V4(PxYNk0W1XA4(9S)dvA)YY9tq)UKeBHPiksNnS(f3VamnnAyCAHUgzOyMKicwu)I7xiX4(f3p9s(uHgUowd3VN9tLo0p4a(Ht30a8fL6MgGcOa(yf4iGJ9cCeGpBHqHVaufW3nRYZga(AuytryLJRui60bJrSfcf(2V4(jOFrdtcIS7I8IWkhxPq4Zu7xC)cW00iSYXvkeD6GXOHRJ1W97z)sSFz5(fGPPryLJRui60bJr3KO1p49lUFc6xaMMgnmoTqxJmumtseDtIw)YY9lz)UKeBHPiksNnS(bhWpC6MgGpw54kfcFMkGcC8bGJa8dNUPb4tzlfi8zQa(Sfcf(cqvaf4ycf4iaF2cHcFbOkGVBwLNna8Djj2ctruKoBy9lUFc63Lz5Men0W40cDnYqXmjr0W1XA4(9SFYUB)G3VSC)s2VljXwykII0zdRFX9lz)UKeBHPiBjFQq0b3VSC)UKeBHPiBjFQq0b3V4(jOFxMLBs0qe3YfclANvXOHRJ1W97z)KD3(LL73Lz5MeneXTCHWI2zvmA46ynC)v0pH6X(bVFz5(fsmUFX9tVKpvOHRJ1W97z)ELiGF40nna)BcluyinebOah7baocWNTqOWxaQc47Mv5zdaFngiDcriyr9lU)b2y6CiZiCcxOZHmdX1c8GrSfcf(c4hoDtdWNUeddOahlrGJa8zlek8fGQa(UzvE2aWFGnMohYmcNWf6CiZqCTapyeBHqHV9lUFngiDcrOHRJ1W97z)KD3(f3VlZYnjAi6smmA46ynC)E2pz3fWpC6MgGVgdKoHiaf44kf4ia)WPBAa(Seevs8sIHWNPc4Zwiu4lavbuGJPsahb4hoDtdWN4wUqyr7SkgWNTqOWxaQcOahtiaCeGF40nnaF6siLVq4Zub8zlek8fGQakWXEWahb4Zwiu4lavb8DZQ8SbGpD6GX9xD)UaRqdtMT(9SF60bJr1Hea8dNUPb4F5qpHCNbLjQbuGJ96rGJa8dNUPb4hq1WZLhOKgYnjrmGpBHqHVaufqbo2RxGJa8zlek8fGQa(UzvE2aW3Lz5Men0W40cDnYqXmjr0W1XA4(9SFYUB)I7NG(LSFnkSPiwcIkjEjXq4ZurSfcf(2VSC)cW00iHsM3cmwrWI6h8(LL7xY(Djj2ctruKoBy9ll3VlZYnjAOHXPf6AKHIzsIOHRJ1W9ll3VqIX9lUF6L8PcnCDSgUFp7xIa(Ht30a8jgBznYqXmjraf4yVhaocWNTqOWxaQc47Mv5zdaFbyAA0nHfkmKgIqWI6xwUFj7xJcBk6MWcfgsdri2cHcF7xwUFHeJ7xC)0l5tfA46ynC)E2V3da(Ht30a8hgNwORrgkMjjcOah7LqbocWNTqOWxaQc47Mv5zdaFbyAA0W40cDnYqXmjreSO(LL7xY(Djj2ctruKoBy9lUFc6xaMMgjAy3Izi8zQy0njA9ll3VK9RrHnf5o36GNacFMkITqOW3(LL7pC6sIHyJRxg3VN9FOFWb8dNUPb4tklfwkGcCSxpaWra(Sfcf(cqvaF3SkpBa47ssSfMIOiD2W6xC)0Pdg3F197cScnmz263Z(PthmgvhsOFX9tq)e0VlZYnjAOHXPf6AKHIzsIOHRJ1W97z)KD3(9GUFcTFX9tq)s2poHlcRDrmnnmEjXqHT1bu4CCHNqZbXwiu4B)YY9lz)Auytr3ewOWqAicXwiu4B)G3p49ll3Vgf2u0nHfkmKgIqSfcf(2V4(DzwUjrdDtyHcdPHi0W1XA4(9SFcTFWb8dNUPb4JvoUsHWNPcOah7vIahb4Zwiu4lavb8DZQ8SbGVamnns0WUfZq4ZuXOBs06xC)e0VljXwykIeB6P0PFz5(Djj2ctrg7MSKZTFz5(1OWMICrPSgzi9KHWNPIrSfcf(2p49ll3VamnnAyCAHUgzOyMKicwu)YY9lattJiULlew0oRIrWI6xwUFbyAAePSuyPiyr9lU)WPljgInUEzC)v0V3(LL7xiX4(f3p9s(uHgUowd3VN9FqIa(Ht30a81bMXNPcOah7TsbocWNTqOWxaQc47Mv5zda)b2y6CiZim8qEnYq4ZuXi2cHcF7xC)AuytryD4OUSgJylek8TFX9tq)Uml3KOHggNwORrgkMjjIgUowd3Ff971J9ll3VK97ssSfMIOiD2W6xwUFj7xJcBk6MWcfgsdri2cHcF7xwUFCcxew7IyAAy8sIHcBRdOW54cpHMdITqOW3(bhWpC6MgG)eI2le9omGcCSxQeWra(Sfcf(cqva)WPBAa(XwZxi8zQa(UzvE2aWxaMMgjAy3Izi8zQy0njA9ll3pb9lattJ0bMXNPIGf1VSC)0WLc0WUZyiZq6wZ97z)KD3(RUFxGviDR5(bVFX9tq)s2Vgf2uK7CRdEci8zQi2cHcF7xwU)WPljgInUEzC)E2)H(bVFz5(fGPPr6Sokq4ZuXOHRJ1W9xr)SeyhSYq6wZ9lU)WPljgInUEzC)v0VxaFNuxHH0yiZkg4yVakWXEjeaocWNTqOWxaQc47Mv5zdaFc63Lz5Men0W40cDnYqXmjr0W1XA4(ROFVESFz5(LSFxsITWuefPZgw)YY9lz)Auytr3ewOWqAicXwiu4B)YY9Jt4IWAxettdJxsmuyBDafohx4j0CqSfcf(2p49lUF60bJ7V6(DbwHgMmB97z)0PdgJQdj0V4(jOFbyAA0nHfkmKgIq3KO1VSC)AuytryD4OUSgJylek8TFWb8dNUPb4pHO9crVddOah71dg4iaF2cHcFbOkGVBwLNna8fGPPrIg2TygcFMkgblQFz5(PthmU)k63LyT)Q7pC6Mgk2A(cHptf5sSc4hoDtdW3DU1bpbe(mvaf44dEe4iaF2cHcFbOkGVBwLNna8fGPPrIg2TygcFMkgblQFz5(PthmU)k63LyT)Q7pC6Mgk2A(cHptf5sSc4hoDtdWpgxyme(mvaf44dEbocWNTqOWxaQc4hoDtdWhZJi2uiSUgzaF3SkpBa4pm9W4ZqOW9lUFngYSI0TMH0e6UC)v0)fEcDtdW3j1vyingYSIbo2lGcC8Hdahb4Zwiu4lavb8DZQ8SbGF40LedXgxVmU)k63lGF40nnaFHyMGmdOahFGqbocWNTqOWxaQc47Mv5zdaFc63Lz5Men0W40cDnYqXmjr0W1XA4(ROFVESFX9pWgtNdzgHHhYRrgcFMkgXwiu4B)YY9lz)UKeBHPiksNnS(LL7xY(1OWMIUjSqHH0qeITqOW3(LL7hNWfH1UiMMggVKyOW26akCoUWtO5Gylek8TFW7xC)0Pdg3F197cScnmz263Z(PthmgvhsOFX9tq)cW00OBcluyineHUjrRFz5(1OWMIW6WrDzngXwiu4B)Gd4hoDtdWFcr7fIEhgqbo(Gha4iaF2cHcFbOkGVBwLNna8fGPPr6aZ4Zur3KOb4hoDtdWxiidL0q6Sokyaf44dse4iaF2cHcFbOkGVBwLNna8XjCryTlsemwHlmepWI0nneBHqHV9lUFbyAAKoWm(mv0njAa(Ht30a8Plm(0nbTcOahFOsbocWpC6MgGpw54kfcFMkGpBHqHVaufqbuaFDwJcRyGJao2lWra(Sfcf(cqva)ueGpMva)WPBAa(KIzdHcd4tkkWmGVamnnAyCAHUgzOyMKicwu)YY9lattJ0bMXNPIGfb4tkgilQzaFSuZbblcqbo(aWra(Sfcf(cqva)ueGpMva)WPBAa(KIzdHcd4tkkWmGVljXwykII0zdRFX9lattJggNwORrgkMjjIGf1V4(fGPPr6aZ4ZurWI6xwUFj73LKylmfrr6SH1V4(fGPPr6aZ4ZurWIa8jfdKf1mGpwN0idHLAoiyrakWXekWra(Sfcf(cqva)ueGpM1LgWpC6MgGpPy2qOWa(KIbYIAgWhRtAKHWsnh0W1XAyaF3SkpBa4lattJ0bMXNPIUjrRFX97ssSfMIOiD2Wa8jffygIlygW3Lz5MenKoWm(mv0W1XAyaFsrbMb8DzwUjrdnmoTqxJmumtsenCDSgUFp9W2VlZYnjAiDGz8zQOHRJ1WakWXEaGJa8zlek8fGQa(PiaFmRlnGF40nnaFsXSHqHb8jfdKf1mGpwN0idHLAoOHRJ1Wa(UzvE2aWxaMMgPdmJptfblQFX97ssSfMIOiD2Wa8jffygIlygW3Lz5MenKoWm(mv0W1XAyaFsrbMb8DzwUjrdnmoTqxJmumtsenCDSggqbowIahb4Zwiu4lavb8tra(ywxAa)WPBAa(KIzdHcd4tkgilQzaFSuZbnCDSggW3nRYZga(UKeBHPiksNnmaFsrbMH4cMb8DzwUjrdPdmJptfnCDSggWNuuGzaFxMLBs0qdJtl01idfZKerdxhRH7VcpS97YSCtIgshygFMkA46ynmGcCCLcCeGpBHqHVaufWpC6MgGVoRrHvVa(UzvE2aWNG(1znkSIuVOZadbJzibyA6(LL73LKylmfrr6SH1V4(1znkSIuVOZad5YSCtIw)G3V4(jOFsXSHqHryDsJmewQ5GGf1V4(jOFj73LKylmfrr6SH1V4(LSFDwJcRi9a6mWqWygsaMMUFz5(Djj2ctruKoBy9lUFj7xN1OWkspGodmKlZYnjA9ll3VoRrHvKEa5YSCtIgA46ynC)YY9RZAuyfPErNbgcgZqcW009lUFc6xY(1znkSI0dOZadbJzibyA6(LL7xN1OWks9ICzwUjrdDHNq306Vcq6xN1OWkspGCzwUjrdDHNq306h8(LL7xN1OWks9IodmKlZYnjA9lUFj7xN1OWkspGodmemMHeGPP7xC)6SgfwrQxKlZYnjAOl8e6Mw)vas)6Sgfwr6bKlZYnjAOl8e6Mw)G3VSC)s2pPy2qOWiSoPrgcl1CqWI6xC)e0VK9RZAuyfPhqNbgcgZqcW009lUFc6xN1OWks9ICzwUjrdDHNq306Nk6xI97z)KIzdHcJWsnh0W1XA4(LL7NumBiuyewQ5GgUowd3Ff9RZAuyfPErUml3KOHUWtOBA9dQ(p0p49ll3VoRrHvKEaDgyiymdjatt3V4(jOFDwJcRi1l6mWqWygsaMMUFX9RZAuyfPErUml3KOHUWtOBA9xbi9RZAuyfPhqUml3KOHUWtOBA9lUFc6xN1OWks9ICzwUjrdDHNq306Nk6xI97z)KIzdHcJWsnh0W1XA4(LL7NumBiuyewQ5GgUowd3Ff9RZAuyfPErUml3KOHUWtOBA9dQ(p0p49ll3pb9lz)6SgfwrQx0zGHGXmKamnD)YY9RZAuyfPhqUml3KOHUWtOBA9xbi9RZAuyfPErUml3KOHUWtOBA9dE)I7NG(1znkSI0dixMLBs0qdhxP9lUFDwJcRi9aYLz5Men0fEcDtRFQOFj2Ff9tkMnekmcl1CqdxhRH7xC)KIzdHcJWsnh0W1XA4(9SFDwJcRi9aYLz5Men0fEcDtRFq1)H(LL7xY(1znkSI0dixMLBs0qdhxP9lUFc6xN1OWkspGCzwUjrdnCDSgUFQOFj2VN9tkMnekmcRtAKHWsnh0W1XA4(f3pPy2qOWiSoPrgcl1CqdxhRH7VI(p4X(f3pb9RZAuyfPErUml3KOHUWtOBA9tf9lX(9SFsXSHqHryPMdA46ynC)YY9RZAuyfPhqUml3KOHgUowd3pv0Ve73Z(jfZgcfgHLAoOHRJ1W9lUFDwJcRi9aYLz5Men0fEcDtRFQOFVES)Q7NumBiuyewQ5GgUowd3VN9tkMnekmcRtAKHWsnh0W1XA4(LL7NumBiuyewQ5GgUowd3Ff9RZAuyfPErUml3KOHUWtOBA9dQ(p0VSC)KIzdHcJWsnheSO(bVFz5(1znkSI0dixMLBs0qdxhRH7Nk6xI9xr)KIzdHcJW6KgziSuZbnCDSgUFX9tq)6SgfwrQxKlZYnjAOl8e6Mw)ur)sSFp7NumBiuyewN0idHLAoOHRJ1W9ll3VK9RZAuyfPErNbgcgZqcW009lUFc6NumBiuyewQ5GgUowd3Ff9RZAuyfPErUml3KOHUWtOBA9dQ(p0VSC)KIzdHcJWsnheSO(bVFW7h8(bVFW7h8(LL7xiX4(f3p9s(uHgUowd3VN9tkMnekmcl1CqdxhRH7h8(LL7xY(1znkSIuVOZadbJzibyA6(f3VK97ssSfMIOiD2W6xC)e0VoRrHvKEaDgyiymdjatt3V4(jOFc6xY(jfZgcfgHLAoiyr9ll3VoRrHvKEa5YSCtIgA46ynC)v0Ve7h8(f3pb9tkMnekmcl1CqdxhRH7VI(p4X(LL7xN1OWkspGCzwUjrdnCDSgUFQOFj2Ff9tkMnekmcl1CqdxhRH7h8(bVFz5(LSFDwJcRi9a6mWqWygsaMMUFX9tq)s2VoRrHvKEaDgyixMLBs06xwUFDwJcRi9aYLz5Men0W1XA4(LL7xN1OWkspGCzwUjrdDHNq306Vcq6xN1OWks9ICzwUjrdDHNq306h8(bhWhxsfd4RZAuy1lGcCmvc4iaF2cHcFbOkGF40nnaFDwJcRha8DZQ8SbGpb9RZAuyfPhqNbgcgZqcW009ll3VljXwykII0zdRFX9RZAuyfPhqNbgYLz5MeT(bVFX9tq)KIzdHcJW6KgziSuZbblQFX9tq)s2VljXwykII0zdRFX9lz)6SgfwrQx0zGHGXmKamnD)YY97ssSfMIOiD2W6xC)s2VoRrHvK6fDgyixMLBs06xwUFDwJcRi1lYLz5Men0W1XA4(LL7xN1OWkspGodmemMHeGPP7xC)e0VK9RZAuyfPErNbgcgZqcW009ll3VoRrHvKEa5YSCtIg6cpHUP1FfG0VoRrHvK6f5YSCtIg6cpHUP1p49ll3VoRrHvKEaDgyixMLBs06xC)s2VoRrHvK6fDgyiymdjatt3V4(1znkSI0dixMLBs0qx4j0nT(RaK(1znkSIuVixMLBs0qx4j0nT(bVFz5(LSFsXSHqHryDsJmewQ5GGf1V4(jOFj7xN1OWks9IodmemMHeGPP7xC)e0VoRrHvKEa5YSCtIg6cpHUP1pv0Ve73Z(jfZgcfgHLAoOHRJ1W9ll3pPy2qOWiSuZbnCDSgU)k6xN1OWkspGCzwUjrdDHNq306hu9FOFW7xwUFDwJcRi1l6mWqWygsaMMUFX9tq)6Sgfwr6b0zGHGXmKamnD)I7xN1OWkspGCzwUjrdDHNq306Vcq6xN1OWks9ICzwUjrdDHNq306xC)e0VoRrHvKEa5YSCtIg6cpHUP1pv0Ve73Z(jfZgcfgHLAoOHRJ1W9ll3pPy2qOWiSuZbnCDSgU)k6xN1OWkspGCzwUjrdDHNq306hu9FOFW7xwUFc6xY(1znkSI0dOZadbJzibyA6(LL7xN1OWks9ICzwUjrdDHNq306Vcq6xN1OWkspGCzwUjrdDHNq306h8(f3pb9RZAuyfPErUml3KOHgoUs7xC)6SgfwrQxKlZYnjAOl8e6Mw)ur)sS)k6NumBiuyewQ5GgUowd3V4(jfZgcfgHLAoOHRJ1W97z)6SgfwrQxKlZYnjAOl8e6Mw)GQ)d9ll3VK9RZAuyfPErUml3KOHgoUs7xC)e0VoRrHvK6f5YSCtIgA46ynC)ur)sSFp7NumBiuyewN0idHLAoOHRJ1W9lUFsXSHqHryDsJmewQ5GgUowd3Ff9FWJ9lUFc6xN1OWkspGCzwUjrdDHNq306Nk6xI97z)KIzdHcJWsnh0W1XA4(LL7xN1OWks9ICzwUjrdnCDSgUFQOFj2VN9tkMnekmcl1CqdxhRH7xC)6SgfwrQxKlZYnjAOl8e6Mw)ur)E9y)v3pPy2qOWiSuZbnCDSgUFp7NumBiuyewN0idHLAoOHRJ1W9ll3pPy2qOWiSuZbnCDSgU)k6xN1OWkspGCzwUjrdDHNq306hu9FOFz5(jfZgcfgHLAoiyr9dE)YY9RZAuyfPErUml3KOHgUowd3pv0Ve7VI(jfZgcfgH1jnYqyPMdA46ynC)I7NG(1znkSI0dixMLBs0qx4j0nT(PI(Ly)E2pPy2qOWiSoPrgcl1CqdxhRH7xwUFj7xN1OWkspGodmemMHeGPP7xC)e0pPy2qOWiSuZbnCDSgU)k6xN1OWkspGCzwUjrdDHNq306hu9FOFz5(jfZgcfgHLAoiyr9dE)G3p49dE)G3p49ll3VqIX9lUF6L8PcnCDSgUFp7NumBiuyewQ5GgUowd3p49ll3VK9RZAuyfPhqNbgcgZqcW009lUFj73LKylmfrr6SH1V4(jOFDwJcRi1l6mWqWygsaMMUFX9tq)e0VK9tkMnekmcl1CqWI6xwUFDwJcRi1lYLz5Men0W1XA4(ROFj2p49lUFc6NumBiuyewQ5GgUowd3Ff9FWJ9ll3VoRrHvK6f5YSCtIgA46ynC)ur)sS)k6NumBiuyewQ5GgUowd3p49dE)YY9lz)6SgfwrQx0zGHGXmKamnD)I7NG(LSFDwJcRi1l6mWqUml3KO1VSC)6SgfwrQxKlZYnjAOHRJ1W9ll3VoRrHvK6f5YSCtIg6cpHUP1FfG0VoRrHvKEa5YSCtIg6cpHUP1p49doGpUKkgWxN1OW6bafqbuaFs8G30ao(Ghp41JujpwPa(eJXwJmgW3dIhov2XvIhxjx1(7)OtU)TwuoA)050py6Sok4ZuXG1)WeYW7W3(Xzn3FaRzDO8TF3zyKzmQPUkRX97TQ9x50iXJY3(btJcBkIWG1VM9dMgf2ueHrSfcf(cw)e4vcGJAQRYAC)eAv7VYPrIhLV9d2aBmDoKzeHbRFn7hSb2y6CiZicJylek8fS(jWReah1uxL14(9avT)kNgjEu(2pydSX05qMregS(1SFWgyJPZHmJimITqOWxW6p0(ReiexL(jWReah1uxL14(PsvT)kNgjEu(2pyAuytregS(1SFW0OWMIimITqOWxW6NaVsaCutDvwJ7NqOQ9x50iXJY3(btJcBkIWG1VM9dMgf2ueHrSfcf(cw)e4vcGJAQRYAC)Epu1(RCAK4r5B)GPrHnfryW6xZ(btJcBkIWi2cHcFbRFc8kbWrn1vznUFVhQA)vons8O8TFWgyJPZHmJimy9Rz)GnWgtNdzgryeBHqHVG1pbELa4OM6QSg3Vxjw1(RCAK4r5B)GPrHnfryW6xZ(btJcBkIWi2cHcFbRFc8kbWrn1vznUFVsSQ9x50iXJY3(bBGnMohYmIWG1VM9d2aBmDoKzeHrSfcf(cw)eCqcGJAQRYAC)ER0Q2FLtJepkF7hmnkSPicdw)A2pyAuytregXwiu4ly9tGxjaoQPUkRX9FGqRA)vons8O8TFWgyJPZHmJimy9Rz)GnWgtNdzgryeBHqHVG1FO9xjqiUk9tGxjaoQPUkRX9FWdu1(RCAK4r5B)GnWgtNdzgryW6xZ(bBGnMohYmIWi2cHcFbR)q7VsGqCv6NaVsaCutDvwJ7)qLw1(RCAK4r5B)GHt4IWAxeHbRFn7hmCcxew7IimITqOWxW6NaVsaCutDtThepCQSJRepUsUQ93)rNC)BTOC0(PZPFWUmDaxuW6Fycz4D4B)4SM7pG1Sou(2V7mmYmg1uxL14(pu1(RCAK4r5B)GnWgtNdzgryW6xZ(bBGnMohYmIWi2cHcFbRFc8kbWrn1vznU)dvT)kNgjEu(2pydSX05qMregS(1SFWgyJPZHmJimITqOWxW6NaVsaCutDvwJ7)qv7VYPrIhLV9dMlTl8Qicdw)A2pyU0UWRIimITqOWxW6NaVsaCutDvwJ7)qv7VYPrIhLV9dgoHlcRDregS(1SFWWjCryTlIWi2cHcFbRFc8kbWrn1n1Eq8WPYoUs84k5Q2F)hDY9V1IYr7NoN(bt0WUSwiuW6Fycz4D4B)4SM7pG1Sou(2V7mmYmg1uxL14(j0Q2FLtJepkF7hSb2y6CiZicdw)A2pydSX05qMregXwiu4ly9hA)vceIRs)e4vcGJAQRYAC)EGQ2FLtJepkF7hmnkSPicdw)A2pyAuytregXwiu4ly9hA)vceIRs)e4vcGJAQRYAC)uPQ2FLtJepkF7hmnkSPicdw)A2pyAuytregXwiu4ly9tGxjaoQPUkRX9tiu1(RCAK4r5B)GPrHnfryW6xZ(btJcBkIWi2cHcFbRFc8kbWrn1n1Eq8WPYoUs84k5Q2F)hDY9V1IYr7NoN(bdRG1)WeYW7W3(Xzn3FaRzDO8TF3zyKzmQPUkRX97TQ9x50iXJY3(btJcBkIWG1VM9dMgf2ueHrSfcf(cw)e4vcGJAQRYAC)EGQ2FLtJepkF7hSb2y6CiZicdw)A2pydSX05qMregXwiu4ly9hA)vceIRs)e4vcGJAQRYAC)sSQ9x50iXJY3(bBGnMohYmIWG1VM9d2aBmDoKzeHrSfcf(cw)e4vcGJAQRYAC)E9w1(RCAK4r5B)GPrHnfryW6xZ(btJcBkIWi2cHcFbRFc8kbWrn1vznUFVhQA)vons8O8TFW0OWMIimy9Rz)GPrHnfryeBHqHVG1pbELa4OM6QSg3VxcTQ9x50iXJY3(btJcBkIWG1VM9dMgf2ueHrSfcf(cw)e4vcGJAQRYAC)E9avT)kNgjEu(2pyAuytregS(1SFW0OWMIimITqOWxW6NGdsaCutDvwJ73RhOQ9x50iXJY3(bdNWfH1Uicdw)A2py4eUiS2fryeBHqHVG1pbELa4OM6QSg3Vxjw1(RCAK4r5B)GPrHnfryW6xZ(btJcBkIWi2cHcFbRFc8kbWrn1vznUFVvAv7VYPrIhLV9dMgf2ueHbRFn7hmnkSPicJylek8fS(j4Geah1uxL14(9wPvT)kNgjEu(2pydSX05qMregS(1SFWgyJPZHmJimITqOWxW6NaVsaCutDvwJ73BLw1(RCAK4r5B)GHt4IWAxeHbRFn7hmCcxew7IimITqOWxW6NaVsaCutDvwJ73lvQQ9x50iXJY3(btJcBkIWG1VM9dMgf2ueHrSfcf(cw)e4vcGJAQRYAC)EjeQA)vons8O8TFW0OWMIimy9Rz)GPrHnfryeBHqHVG1pbhKa4OM6QSg3VxcHQ2FLtJepkF7hmCcxew7Iimy9Rz)GHt4IWAxeHrSfcf(cw)e4vcGJAQRYAC)hi0Q2FLtJepkF7hmnkSPicdw)A2pyAuytregXwiu4ly9tWbjaoQPUkRX9FGqRA)vons8O8TFWgyJPZHmJimy9Rz)GnWgtNdzgryeBHqHVG1pbELa4OM6QSg3)bcTQ9x50iXJY3(bdNWfH1Uicdw)A2py4eUiS2fryeBHqHVG1pbELa4OM6QSg3)bjw1(RCAK4r5B)GHt4IWAxeHbRFn7hmCcxew7IimITqOWxW6NaVsaCutDtThepCQSJRepUsUQ93)rNC)BTOC0(PZPFW0znkSIbR)HjKH3HV9JZAU)awZ6q5B)UZWiZyutDvwJ7VsRA)vons8O8TF)TUY9JLAAiH(jK6xZ(RcC0)DjT4nT(tr8eAo9taOaVFcKOeah1uxL14(R0Q2FLtJepkF7hmDwJcRiVicdw)A2py6SgfwrQxeHbRFco4vcGJAQRYAC)vAv7VYPrIhLV9dMoRrHv0beHbRFn7hmDwJcRi9aIWG1pbhQujaoQPUkRX9tLQA)vons8O8TF)TUY9JLAAiH(jK6xZ(RcC0)DjT4nT(tr8eAo9taOaVFcKOeah1uxL14(PsvT)kNgjEu(2py6SgfwrEregS(1SFW0znkSIuVicdw)eCOsLa4OM6QSg3pvQQ9x50iXJY3(btN1OWk6aIWG1VM9dMoRrHvKEaryW6NGdELa4OM6M6Jo5(bdgZqRY1yW6pC6Mw)edC)wQ9tNW2T)16xpxC)BTOCuutDLyTOCu(2FL2F40nT(llwXOMAaFSi2bC8bj6ba8fnj9wyaFpKhQFcrIHcUom85kQ)kPGnLNMApKhQFQHls7Nqa09FWJh82u3u7H8q9x5ZWiZ4Q2u7H8q9tf9FmtKoHTB)uzmolK4(xC)wQ9h9xZUZWwx)6j3FCVP1VlmqrClL(RdliZOMApKhQFQOFQmgl1C8T)4EtRFrZMZQs7N4QN97V1vUFp8kjvb1u3uhoDtdJenSlRfcTAqaLqQAHVq0LqkFjUgzinLWAn1Ht30Wird7YAHqRgeqrxy8PBcATPoC6MggjAyxwleA1GakngiDcrGEPbzGnMohYmcNWf6CiZqCTap4M6WPBAyKOHDzTqOvdcOUjSqHH0qeOfnSlWkKU1miE9iOxAqcNUKyi246LXv4vwwsxsITWuefPZgMyj1OWMIiLLclTP2d1FLpdJm3VM97TFn7hV1WLq5(ReoYddO899W0pzogmXqu)hnWm(m1(fnSlWkQPoC6MggjAyxwleA1GaksXSHqHbTf1miSsdjAyxGvqtkkWmifMmB3yKI4GCH1OKggshygIoDWyeBHqHVIXSQRrgJ4GCH1OKgeMyicXwiu4BtD40nnms0WUSwi0Qbbu6aZ4Zub9sdcPy2qOWiwPHenSlWAtD40nnms0WUSwi0QbbuXwZxi8zQGEPbjC6sIHyJRxg7jHkMajDjj2ctruKoByILuJcBkIuwkSuz5WPljgInUEzSNhaxSKKIzdHcJyLgs0WUaRn1Ht30Wird7YAHqRgeqHvoUsHWNPc6LgKWPljgInUEzCfhKLjWLKylmfrr6SHjlRrHnfrklfwk4IdNUKyi246LXGCqwMumBiuyeR0qIg2fyTPUPoC6MgUAqaLlHnLhi8zQn1Ht30WvdcOCjSP8aHptf0L1yi3fec1JGEPbzGnMohYmcZIoHPYXqIM0vI6q30KLXjCryTlYwPbgsZSGHeLlonzzcCPDHxfnmjEWrbkPHOZrHnwSKdSX05qMryw0jmvogs0KUsuh6Mg4n1EO(RKZ(JtoU9h2T)JMWiKH3YsLZ9FCLKk3pBC9Y4kP7Ni3)nnW0(Vz)65I7NoN(fvcP8G7xGDbmM7FvWU9lW9Rz2pwuuxlT)WU9tK73fgyA)dh3TiT)JMWiK7hlIDl966xaMMgJAQdNUPHRgeqPtyeYWBzPYxJme(mvqV0GiPgdzwrlgsujKYttD40nnC1GakxukqHt30GklwbTf1mi6SgfwXGEPbXLKylmfrr6SHj2Lz5MenKoWm(mv0W1XAyXUml3KOHggNwORrgkMjjIgUowdlllPljXwykII0zdtSlZYnjAiDGz8zQOHRJ1Wn1Eipu)eIYLqA)0HBnY9lnHN(VjSG2pSPBPFPjC)NbjUFrWA)uzmoTqxJC)E4ZKe7)Menq3Fo9V09RNC)Uml3KO1)I7xZS)sAK7xZ(VCjK2pD4wJC)st4PFcrtybf1FLiD)wAC)jD)6jJ5(DPDxDtd3FmC)HqH7xZ(RzTFIREUw)6j3Vxp2pMDPDX9xyMyif09RNC)4TUF6WX4(LMWt)eIMWcA)bSM1HUUOuKIAQ9qEO(dNUPHRgeqzmr6e2UqdJZcjg0lni4eUiS2fzmr6e2UqdJZcjwmbcW00OHXPf6AKHIzsIiyrYYUml3KOHggNwORrgkMjjIgUowdxHxpkllKySy6L8PcnCDSg2tVvk4n1Ht30WvdcOCrPafoDtdQSyf0wuZG4U4M6WPBA4QbbuUOuGcNUPbvwScAlQzqWkOxAqcNUKyi246LXEsOn1Ht30WvdcOCrPafoDtdQSyf0wuZGOZ6OGptfd6LgKWPljgInUEzCfhAQBQdNUPHrUlgebEW8qznYGEPbHabyAAKoWm(mveSiXcW00OHXPf6AKHIzsIiyrIDjj2ctruKoByGlltGamnnshygFMkcwKybyAAeXTCHWI2zvmcwKyxsITWuKTKpvi6GbxwMaxsITWuej20tPJSSljXwykYy3KLCUGlwaMMgPdmJptfblswwiXyX0l5tfA46ynSNEjuzzcCjj2ctruKoByIfGPPrdJtl01idfZKerWIelKySy6L8PcnCDSg2tQeHcEtD40nnmYDXvdcOekzEHOHhPGEPbraMMgPdmJptfblsw2Lz5MenKoWm(mv0W1XA4kiupkllKySy6L8PcnCDSg2tVvAtD40nnmYDXvdcOcZXyDIcKlkfqV0GiattJ0bMXNPIGfjl7YSCtIgshygFMkA46ynCfeQhLLfsmwm9s(uHgUowd7P3kTPoC6Mgg5U4Qbbu07WcLmVGEPbraMMgPdmJptfblsw2Lz5MenKoWm(mv0W1XA4kiupkllKySy6L8PcnCDSg2tp4M6WPBAyK7IRgeqvwYNkgYdk4l5A2uqV0GiattJ0bMXNPIUjrRPoC6Mgg5U4QbbuIsDtd0lnicW00iDGz8zQiyrIjqaMMgjuY8wGXkcwKSSgdzwrNCu0tKiN65bpcUSSqIXIPxYNk0W1XAyppuPYYe4ssSfMIOiD2WelattJggNwORrgkMjjIGfjwiXyX0l5tfA46ynSNuPdG3u3uhoDtdJWkiyLJRui8zQGEPbrJcBkcRCCLcrNoySycenmjiYUlYlcRCCLcHptvSamnncRCCLcrNoymA46ynSNsuwwaMMgHvoUsHOthmgDtIg4IjqaMMgnmoTqxJmumtseDtIMSSKUKeBHPiksNnmWBQdNUPHryTAqafLTuGWNP2uhoDtdJWA1GaQBcluyineb6LgexsITWuefPZgMycCzwUjrdnmoTqxJmumtsenCDSg2tYUl4YYs6ssSfMIOiD2WelPljXwykYwYNkeDWYYUKeBHPiBjFQq0blMaxMLBs0qe3YfclANvXOHRJ1WEs2DLLDzwUjrdrClxiSODwfJgUowdxbH6rWLLfsmwm9s(uHgUowd7Pxj2uhoDtdJWA1Gak6smmOxAq0yG0jeHGfjEGnMohYmcNWf6CiZqCTap4M6WPBAyewRgeqPXaPtic0lnidSX05qMr4eUqNdzgIRf4blwJbsNqeA46ynSNKDxXUml3KOHOlXWOHRJ1WEs2DBQdNUPHryTAqaflbrLeVKyi8zQn1Ht30WiSwniGI4wUqyr7SkUPoC6MggH1Qbbu0LqkFHWNP2uhoDtdJWA1GaQlh6jK7mOmrnOxAqOthmUAxGvOHjZMN0PdgJQdj0uhoDtdJWA1GaQaQgEU8aL0qUjjIBQdNUPHryTAqafXylRrgkMjjc6LgexMLBs0qdJtl01idfZKerdxhRH9KS7kMaj1OWMIyjiQK4LedHptvwwaMMgjuY8wGXkcwe4YYs6ssSfMIOiD2WKLDzwUjrdnmoTqxJmumtsenCDSgwwwiXyX0l5tfA46ynSNsSPoC6MggH1QbbudJtl01idfZKeb9sdIamnn6MWcfgsdriyrYYsQrHnfDtyHcdPHizzHeJftVKpvOHRJ1WE69qtD40nnmcRvdcOiLLclf0lnicW00OHXPf6AKHIzsIiyrYYs6ssSfMIOiD2WetGamnns0WUfZq4ZuXOBs0KLLuJcBkYDU1bpbe(mvz5WPljgInUEzSNhaVPoC6MggH1QbbuyLJRui8zQGEPbXLKylmfrr6SHjMoDW4QDbwHgMmBEsNoymQoKGyciWLz5Men0W40cDnYqXmjr0W1XAypj7UEqtOIjqsCcxew7IyAAy8sIHcBRdOW54cpHMJSSKAuytr3ewOWqAicCWLL1OWMIUjSqHH0qKyxMLBs0q3ewOWqAicnCDSg2tcf8M6WPBAyewRgeqPdmJptf0lnicW00ird7wmdHptfJUjrtmbUKeBHPisSPNshzzxsITWuKXUjl5CLL1OWMICrPSgzi9KHWNPIbxwwaMMgnmoTqxJmumtseblswwaMMgrClxiSODwfJGfjllattJiLLclfblsC40LedXgxVmUcVYYcjglMEjFQqdxhRH98GeBQdNUPHryTAqa1eI2le9omOxAqgyJPZHmJWWd51idHptflwJcBkcRdh1L1yXe4YSCtIgAyCAHUgzOyMKiA46ynCfE9OSSKUKeBHPiksNnmzzj1OWMIUjSqHH0qKSmoHlcRDrmnnmEjXqHT1bu4CCHNqZb8M6WPBAyewRgeqfBnFHWNPcANuxHH0yiZkgeVGEPbraMMgjAy3Izi8zQy0njAYYeiattJ0bMXNPIGfjltdxkqd7oJHmdPBn7jz3TAxGviDRzWftGKAuytrUZTo4jGWNPklhoDjXqSX1lJ98a4YYcW00iDwhfi8zQy0W1XA4kyjWoyLH0TMfhoDjXqSX1lJRWBtD40nnmcRvdcOMq0EHO3Hb9sdcbUml3KOHggNwORrgkMjjIgUowdxHxpkllPljXwykII0zdtwwsnkSPOBcluyinejlJt4IWAxettdJxsmuyBDafohx4j0CaxmD6GXv7cScnmz28KoDWyuDibXeiattJUjSqHH0qe6MenzznkSPiSoCuxwJbVPoC6MggH1QbbuUZTo4jGWNPc6LgebyAAKOHDlMHWNPIrWIKLPthmUcxI1QdNUPHITMVq4ZurUeRn1Ht30WiSwniGkgxyme(mvqV0GiattJenSBXme(mvmcwKSmD6GXv4sSwD40nnuS18fcFMkYLyTPoC6MggH1QbbuyEeXMcH11idANuxHH0yiZkgeVGEPbzy6HXNHqHfRXqMvKU1mKMq3LR4cpHUP1uhoDtdJWA1GakHyMGmd6LgKWPljgInUEzCfEBQdNUPHryTAqa1eI2le9omOxAqiWLz5Men0W40cDnYqXmjr0W1XA4k86rXdSX05qMry4H8AKHWNPILLL0LKylmfrr6SHjllPgf2u0nHfkmKgIKLXjCryTlIPPHXljgkSToGcNJl8eAoGlMoDW4QDbwHgMmBEsNoymQoKGyceGPPr3ewOWqAicDtIMSSgf2uewhoQlRXG3uhoDtdJWA1GakHGmusdPZ6OGb9sdIamnnshygFMk6MeTM6WPBAyewRgeqrxy8PBcAf0lni4eUiS2fjcgRWfgIhyr6MMybyAAKoWm(mv0njAn1Ht30WiSwniGcRCCLcHptTPUPoC6MggPZ6OGptfdcw54kfcFMkOxAq0OWMIWkhxPq0PdglEni6Ys(uflattJWkhxPq0PdgJgUowd7PeBQdNUPHr6Sok4ZuXvdcOUjSqHH0qeOxAqCjj2ctruKoByIDzwUjrdnmoTqxJmumtsenCDSg2tYURSSKUKeBHPiksNnmXs6ssSfMISL8PcrhSSSljXwykYwYNkeDWIjWLz5MeneXTCHWI2zvmA46ynSNKDxzzxMLBs0qe3YfclANvXOHRJ1WvqOEeCzzHeJftVKpvOHRJ1WE61JYYUml3KOHggNwORrgkMjjIgUowdxHxpkoC6sIHyJRxgxbH2uhoDtdJ0zDuWNPIRgeqPXaPtic0lnidSX05qMr4eUqNdzgIRf4blwJbsNqeA46ynSNKDxXUml3KOHOlXWOHRJ1WEs2DBQdNUPHr6Sok4ZuXvdcOOlXWGEPbrJbsNqecwK4b2y6CiZiCcxOZHmdX1c8GBQdNUPHr6Sok4ZuXvdcOyjiQK4LedHptTPoC6MggPZ6OGptfxniGI4wUqyr7SkUPoC6MggPZ6OGptfxniGIySL1idfZKeb9sdIlZYnjAOHXPf6AKHIzsIOHRJ1WEs2DftGKAuytrSeevs8sIHWNPkllattJekzElWyfblcCzzjDjj2ctruKoByYYUml3KOHggNwORrgkMjjIgUowdxHxpkllKySy6L8PcnCDSg2tj2uhoDtdJ0zDuWNPIRgeqnmoTqxJmumtse0lniUml3KOHiLLclfnCDSg2tYURSSKAuytrKYsHLkllKySy6L8PcnCDSg2tVhAQdNUPHr6Sok4ZuXvdcOiLLclf0lnicW00OHXPf6AKHIzsIiyrYYs6ssSfMIOiD2WAQdNUPHr6Sok4ZuXvdcOeIzcYCtD40nnmsN1rbFMkUAqaLoWm(mvqV0GiattJggNwORrgkMjjIGfjl7YSCtIgAyCAHUgzOyMKiA46ynCfE9OSSKUKeBHPiksNnmzzHeJftVKpvOHRJ1WEEWJn1Ht30WiDwhf8zQ4QbbutiAVq07WGEPbzGnMohYmcdpKxJme(mvSycCzwUjrdnmoTqxJmumtsenCDSgUcVEuwwsxsITWuefPZgMSSKAuytr3ewOWqAicCXcW00iDwhfi8zQy0W1XA4kaHLa7Gvgs3AUPoC6MggPZ6OGptfxniGk2A(cHptf0oPUcdPXqMvmiEb9sdIamnnsN1rbcFMkgnCDSgUcqyjWoyLH0TMftGamnns0WUfZq4ZuXOBs0KLPHlfOHDNXqMH0TM90fyfs3AUAYURSSamnnshygFMkcwe4n1Ht30WiDwhf8zQ4Qbbuxo0ti3zqzIAqV0GqNoyC1UaRqdtMnpPthmgvhsOPoC6MggPZ6OGptfxniGAcr7fIEhg0lnie4YSCtIgAyCAHUgzOyMKiA46ynCfE9O4b2y6CiZim8qEnYq4ZuXYYs6ssSfMIOiD2WKLLCGnMohYmcdpKxJme(mvSSSKAuytr3ewOWqAicCXcW00iDwhfi8zQy0W1XA4kaHLa7Gvgs3AUPoC6MggPZ6OGptfxniGQgUOl(mvqV0GiattJ0zDuGWNPIr3KOjllattJenSBXme(mvmcwKy60bJRWLyT6WPBAOyR5le(mvKlXQycKuJcBkYDU1bpbe(mvz5WPljgInUEzCfek4n1Ht30WiDwhf8zQ4QbbuUZTo4jGWNPc6LgebyAAKOHDlMHWNPIrWIetNoyCfUeRvhoDtdfBnFHWNPICjwfhoDjXqSX1lJ90d0uhoDtdJ0zDuWNPIRgeqrzlfi8zQGEPbraMMgD54cXsz0njAn1Ht30WiDwhf8zQ4Qbbubun8C5bkPHCtse3uhoDtdJ0zDuWNPIRgeqrxcP8fcFMAtD40nnmsN1rbFMkUAqafMhrSPqyDnYG2j1vyingYSIbXlOxAqgMEy8ziu4M6WPBAyKoRJc(mvC1GaQA4IU4Zub9sdcD6GXv4sSwD40nnuS18fcFMkYLyvmbUml3KOHggNwORrgkMjjIgUowdxHeLLL0LKylmfrr6SHbEtD40nnmsN1rbFMkUAqaLgdKoHiqV0GmWgtNdzgzmgVgzIXifdPtis0AKHcrIIjuyCtD40nnmsN1rbFMkUAqaf9Wmv(AKH0jeb6LgKb2y6CiZiJX41itmgPyiDcrIwJmuisumHcJBQdNUPHr6Sok4ZuXvdcOecYqjnKoRJcg0lnicW00iDGz8zQOBs0AQdNUPHr6Sok4ZuXvdcOOlm(0nbTc6LgeCcxew7IebJv4cdXdSiDttSamnnshygFMk6MeTM6WPBAyKoRJc(mvC1GakSYXvke(m1M6M6WPBAyKoRrHvmiKIzdHcdAlQzqWsnheSiqtkkWmicW00OHXPf6AKHIzsIiyrYYcW00iDGz8zQiyrn1Ht30WiDwJcR4QbbuKIzdHcdAlQzqW6KgziSuZbblc0KIcmdIljXwykII0zdtSamnnAyCAHUgzOyMKicwKybyAAKoWm(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]] )

    
end