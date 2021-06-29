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


    spec:RegisterPack( "Marksmanship", 20210628, [[d4uu(bqicQhHekDjvPu2er1NavgfcCkqvRsvkvVss0SuL4wiHSli)svQggckhJQ0YKKEgcQMgsO6AiiBtsqFtsOmovPKoNQucRtvqVtsGuZJQO7PkAFuf(NKaXbvLs0crI8qvPyIscvCrjbQpkjensjbiNusaTscYmvf4MscvANQc9tjHWqLeGAPscv9uQQPQkPVkjaglsWEvXFvvdg4WclMqpMktwLUmQnJuFgrnAq50kwTKajVgHMTe3wsTBk)w0WjWXLeslxPNd10jDDq2os67iY4rI68eL1JekMpr2VuF8EE94FdLppwLWQ6LWQWQVvuvc3lHtOk2XxLjGp(cchXGmF8TOMp(vCJLiUommSrWXxqiRKX986XhNqRJp(uSnaMQcWp893jpkmirKlRFhp1qLqN0CBqRVJNA37hFrOPOvG2r84FdLppwLWQ6LWQWQVvuvc3lHtOQh)asHL7X3FQFZXh2CVSDep(xg7o(vCJLiUommSrqdQacYuEBHecY4gu9T(sdQsyv9E8ldwXNxp(6ooIyyPIpVEE0751JpBHyHVhkD8D7O8oXXxJcBkcRCCL9PthegXwiw4BdK3GX(0LHmmTbYBGienncRCCL9PthegTCDmgUbE2acD8dNoPD8XkhxzFmSup65XQNxp(SfIf(EO0X3TJY7ehFxsLTWuerz7ewdK3axMLBsYqlJtl0Xi)JDtsOLRJXWnWZgq2DBGKudeUbUKkBHPiIY2jSgiVbc3axsLTWuKnKHPF6GBGKudCjv2ctr2qgM(PdUbYBabnWLz5MKmePPC)ybZokgTCDmgUbE2aYUBdKKAGlZYnjzist5(XcMDumA56ymCd8ObeoH1a4BGKudetmUbYBa9qgM(xUogd3apBGxc74hoDs74FtiXc)1qWrpps4Nxp(SfIf(EO0X3TJY7eh)fYy6CjZiCcvOZLm)5ArEXi2cXcFBG8gOX(1neGwUogd3apBaz3TbYBGlZYnjzi6sSmA56ymCd8SbKD3JF40jTJVg7x3qWrppsXpVE8zlel89qPJF40jTJpDjw(472r5DIJVg7x3qacsqdK3GfYy6CjZiCcvOZLm)5ArEXi2cXcFp(LX4V7E8RsOJEEKqNxp(HtN0o(mLfus8qL)yyPE8zlel89qPJEEScpVE8dNoPD8jnL7hly2rXhF2cXcFpu6ONhRyNxp(SfIf(EO0X3TJY7ehFxMLBsYqlJtl0Xi)JDtsOLRJXWnWZgq2DBG8gqqdeUbAuytrmLfus8qL)yyPIylel8TbssnqeIMgjwY8wGWkcsqdGVbssnq4g4sQSfMIikBNWAGKudCzwUjjdTmoTqhJ8p2njHwUogd3apAGxcRbssnqmX4giVb0dzy6F56ymCd8Sbe64hoDs74tkMYyK)XUjPJEE8TEE94Zwiw47HshF3okVtC8fHOPr3esSWFneGGe0ajPgiCd0OWMIUjKyH)AiaXwiw4BdKKAGyIXnqEdOhYW0)Y1Xy4g4zd8w94hoDs74VmoTqhJ8p2njD0ZJVfNxp(SfIf(EO0X3TJY7ehFriAA0Y40cDmY)y3KecsqdKKAGWnWLuzlmfru2oHD8dNoPD8PMLcl7ONh9syNxp(HtN0o(IXUbz(4Zwiw47Hsh98OxVNxp(HtN0o(6cXyyPE8zlel89qPJEE0B1ZRhF2cXcFpu6472r5DIJ)czmDUKzegAjpg5pgwQyeBHyHVnqEdiObUml3KKHwgNwOJr(h7MKqlxhJHBGhnWlH1ajPgiCdCjv2ctreLTtynqsQbc3ankSPOBcjw4VgcqSfIf(2a4BG8gicrtJ0DCe)yyPIrlxhJHBGhpBatz2bP8xNA(4hoDs74VHG5(PNLp65rVe(51JpBHyHVhkD8dNoPD8JPMVFmSup(UDuEN44lcrtJ0DCe)yyPIrlxhJHBGhpBatz2bP8xNAUbYBabnqeIMgjyz3G5pgwQy0njznqsQb0qLYFzhSyjZFDQ5g4zdCbw)6uZnOYgq2DBGKudeHOPr6cXyyPIGe0a4p(ozUc)1yjZk(8O3JEE0lf)86XNTqSW3dLo(UDuEN44tNoiCdQSbUaR)LjZwd8Sb0PdcJQdkF8dNoPD8VCOW(oybXnQp65rVe686XNTqSW3dLo(UDuEN44tqdCzwUjjdDtiXc)1qaA56ymCd8ObKD3g82BaHAG8gSqgtNlzgHHwYJr(JHLkgXwiw4BdKKAGWnWLuzlmfru2oH1ajPgiCd0OWMIUjKyH)AiaXwiw4BdGVbYBaD6GWnOYg4cS(xMmBnWZgqNoimQoOCdK3acAGienn6MqIf(RHa0njznqsQbAuytryD5OUmgJylel8TbWF8dNoPD83qWC)0ZYh98O3k886XNTqSW3dLo(UDuEN44lcrtJ0DCe)yyPIr3KK1ajPgicrtJeSSBW8hdlvmcsqdK3a60bHBGhnWLyTbv2GWPtAOyQ57hdlvKlXAdK3acAGWnqJcBkYbBQdEJpgwQi2cXcFBGKudcNou5pBC9W4g4rdi8ga)XpC6K2XVgQOdgwQh98O3k251JpBHyHVhkD8D7O8oXXxeIMgjyz3G5pgwQyeKGgiVb0Pdc3apAGlXAdQSbHtN0qXuZ3pgwQixI1giVbHthQ8NnUEyCd8Sbu8JF40jTJVd2uh8gFmSup65rVV1ZRhF2cXcFpu6472r5DIJVienn6YX9ZYy0njzh)WPtAhFItP8XWs9ONh9(wCE94hoDs74h)AO9Y7pP)UnjHp(SfIf(EO0rppwLWoVE8dNoPD8PlHm((XWs94Zwiw47Hsh98yvVNxp(SfIf(EO0XpC6K2XhZRa20pwhJ8X3TJY7eh)LPxgdlel8X3jZv4VglzwXNh9E0ZJvREE94Zwiw47HshF3okVtC8PtheUbE0axI1guzdcNoPHIPMVFmSurUeRnqEdiObUml3KKHwgNwOJr(h7MKqlxhJHBGhnGqnqsQbc3axsLTWuerz7ewdKKAaD6GWnOYg4cS(xMmBnWJgqNoimQoOCdG)4hoDs74xdv0bdl1JEESkHFE94Zwiw47HshF3okVtC8xiJPZLmJmgJhJmPyLH)6gcemg5FiqqSHcHrSfIf(E8dNoPD81y)6gco65XQu8ZRhF2cXcFpu6472r5DIJ)czmDUKzKXy8yKjfRm8x3qGGXi)dbcInuimITqSW3JF40jTJp9YmfZyK)6gco65XQe686XNTqSW3dLo(UDuEN44lcrtJ0fIXWsfDts2XpC6K2Xxmi)t6VUJJi(ONhRwHNxp(HtN0o(yLJRSpgwQhF2cXcFpu6Oh94Fz6aQONxpp6986XpC6K2X3LqMY7hdl1JpBHyHVhkD0ZJvpVE8zlel89qPJF40jTJVlHmL3pgwQhF3okVtC8xiJPZLmJWSayqum4VGnDLOo0jneBHyHVnqsQb4eQio2fzJSa)1ml4VGCWPHylel8TbssnGGg4s7cnkAzQ8IJYpP)05QqgJylel8TbYBGWnyHmMoxYmcZcGbrXG)c20vI6qN0qSfIf(2a4p(LX4V7E8jCc7ONhj8ZRhF2cXcFpu64hoDs74RByvuOPmumJr(JHL6X)Yy3oc0jTJFfz2Gagh3ge2TbVUHvrHMYqXWn4XkGFtdyJRhg)sdiXn4MgCAdUzduydUb052abLqgV4giYUacZnyu4UnqKBGMzdWcI6AzniSBdiXnWfgCAdwoUtrwdEDdRI2aSa2n0JRbIq00y0X3TJY7ehFHBGglzwrd(lOeY49ONhP4Nxp(SfIf(EO0X3TJY7ehFxsLTWuerz7ewdK3axMLBsYq6cXyyPIwUogd3a5nWLz5MKm0Y40cDmY)y3KeA56ymCdKKAGWnWLuzlmfru2oH1a5nWLz5MKmKUqmgwQOLRJXWh)WPtAhFxuk)WPtA)YG1JFzW63IA(4R7yezfF0ZJe686XNTqSW3dLo(HtN0o(UOu(HtN0(LbRh)YG1Vf18X3DXh98yfEE94Zwiw47HshF3okVtC8dNou5pBC9W4g4zdi8JF40jTJVlkLF40jTFzW6XVmy9BrnF8X6rppwXoVE8zlel89qPJVBhL3jo(HthQ8NnUEyCd8Obvp(HtN0o(UOu(HtN0(LbRh)YG1Vf18Xx3Xredlv8rp6XxWYUSwm0ZRNh9EE94hoDs74lMQw47NUeY4lPXi)1KYJD8zlel89qPJEES651JpBHyHVhkD8D7O8oXXhNqfXXUibqyfQWFEHeOtAi2cXcFp(HtN0o(0fgdZTbTE0ZJe(51JpBHyHVhkD8D7O8oXXFHmMoxYmcNqf6CjZFUwKxmITqSW3JF40jTJVg7x3qWrppsXpVE8zlel89qPJVGLDbw)6uZhFVe2XpC6K2X)MqIf(RHGJVBhL3jo(HthQ8NnUEyCd8ObEBGKudeUbUKkBHPiIY2jSgiVbc3ankSPiQzPWYqSfIf(E0ZJe686XNTqSW3dLo(PGJpM1JF40jTJp1yNqSWhFQrbIp(fMmB3yLH4GCH1OKg(Rle)PthegXwiw4BdK3amR6yKXioixynkP9XKcbi2cXcFp(uJ9BrnF8zL(lyzxG1JEEScpVE8zlel89qPJVGLDbw)6uZh)QhF3okVtC8Pg7eIfgXk9xWYUaRhFbl7cS(zL(ZvuOrWX37XpC6K2Xxxigdl1JVGLDbw)ym9FdJ4XVID0ZJvSZRhF2cXcFpu6472r5DIJF40Hk)zJRhg3apBaH3a5nGGgiCdCjv2ctreLTtynqEdeUbAuytruZsHLHylel8TbssniC6qL)SX1dJBGNnOAdGVbYBGWnGAStiwyeR0Fbl7cSE8dNoPD8JPMVFmSup65X3651JpBHyHVhkD8D7O8oXXpC6qL)SX1dJBGhnOAdKKAabnWLuzlmfru2oH1ajPgOrHnfrnlfwgITqSW3gaFdK3GWPdv(ZgxpmUbpBq1gij1aQXoHyHrSs)fSSlW6XpC6K2XhRCCL9XWs9Oh947U4ZRNh9EE94Zwiw47HshF3okVtC8fHOPr6cXyyPIGe0ajPgqpKHP)LRJXWnWZg4LWp(HtN0o(I8I5L4yKp65XQNxp(SfIf(EO0X3TJY7ehFriAAKUqmgwQiibnqsQbUml3KKH0fIXWsfTCDmgUbE0acNWAGKudetmUbYBa9qgM(xUogd3apBG3k84hoDs74lwY8(PHwzh98iHFE94Zwiw47HshF3okVtC8fHOPr6cXyyPIGe0ajPg4YSCtsgsxigdlv0Y1Xy4g4rdiCcRbssnqmX4giVb0dzy6F56ymCd8SbERWJF40jTJFyogRBu(UOuo65rk(51JpBHyHVhkD8D7O8oXXxeIMgPleJHLkcsqdKKAGlZYnjziDHymSurlxhJHBGhnGWjSgij1aXeJBG8gqpKHP)LRJXWnWZg8wC8dNoPD8PNLflzEp65rcDE94Zwiw47HshF3okVtC8fHOPr6cXyyPIUjj74hoDs74xgYWu8VckOl5A20JEEScpVE8zlel89qPJVBhL3jo(Iq00iDHymSurqcAG8gqqdeHOPrILmVfiSIGe0ajPgOXsMvemokkmKaN2apBqvcRbW3ajPgiMyCdK3a6Hmm9VCDmgUbE2GQv4XpC6K2XxqQtAh9OhFSEE98O3ZRhF2cXcFpu6472r5DIJVgf2uew54k7tNoimITqSW3giVbe0ablt9t2DrEryLJRSpgwQnqEdeHOPryLJRSpD6GWOLRJXWnWZgqOgij1ariAAew54k7tNoim6MKSgaFdK3acAGiennAzCAHog5FSBscDtswdKKAGWnWLuzlmfru2oH1a4p(HtN0o(yLJRSpgwQh98y1ZRh)WPtAhFItP8XWs94Zwiw47Hsh98iHFE94Zwiw47HshF3okVtC8Djv2ctreLTtynqEdCzwUjjdTmoTqhJ8p2njHwUogd3apBaz3Tbssnq4g4sQSfMIikBNWAG8giCdCjv2ctr2qgM(PdUbssnWLuzlmfzdzy6No4giVbe0axMLBsYqKMY9Jfm7Oy0Y1Xy4g4zdi7UnqsQbUml3KKHinL7hly2rXOLRJXWnWJgq4ewdGVbssnqmX4giVb0dzy6F56ymCd8SbEj0XpC6K2X)MqIf(RHGJEEKIFE94Zwiw47Hsh)WPtAhF6sS8X3TJY7ehFn2VUHaeKGgiVblKX05sMr4eQqNlz(Z1I8IrSfIf(E8lJXF394xLqh98iHoVE8zlel89qPJVBhL3jo(lKX05sMr4eQqNlz(Z1I8IrSfIf(2a5nqJ9RBiaTCDmgUbE2aYUBdK3axMLBsYq0Lyz0Y1Xy4g4zdi7Uh)WPtAhFn2VUHGJEEScpVE8dNoPD8zklOK4Hk)XWs94Zwiw47Hsh98yf786XpC6K2XN0uUFSGzhfF8zlel89qPJEE8TEE94hoDs74txcz89JHL6XNTqSW3dLo65X3IZRhF2cXcFpu6472r5DIJpD6GWnOYg4cS(xMmBnWZgqNoimQoO8XpC6K2X)YHc77Gfe3O(ONh9syNxp(HtN0o(XVgAV8(t6VBts4JpBHyHVhkD0ZJE9EE94Zwiw47HshF3okVtC8DzwUjjdTmoTqhJ8p2njHwUogd3apBaz3TbYBabnq4gOrHnfXuwqjXdv(JHLkITqSW3gij1ariAAKyjZBbcRiibna(gij1aHBGlPYwykIOSDcRbssnWLz5MKm0Y40cDmY)y3KeA56ymCdKKAGyIXnqEdOhYW0)Y1Xy4g4zdi0XpC6K2XNumLXi)JDtsh98O3QNxp(SfIf(EO0X3TJY7ehFriAA0nHel8xdbiibnqsQbc3ankSPOBcjw4VgcqSfIf(2ajPgiMyCdK3a6Hmm9VCDmgUbE2aVvp(HtN0o(lJtl0Xi)JDtsh98Oxc)86XNTqSW3dLo(UDuEN44lcrtJwgNwOJr(h7MKqqcAGKudeUbUKkBHPiIY2jSgiVbe0ariAAKGLDdM)yyPIr3KK1ajPgiCd0OWMICWM6G34JHLkITqSW3gij1GWPdv(ZgxpmUbE2GQna(JF40jTJp1Suyzh98Oxk(51JpBHyHVhkD8D7O8oXX3Luzlmfru2oH1a5nGoDq4guzdCbw)ltMTg4zdOthegvhuUbYBabnGGg4YSCtsgAzCAHog5FSBscTCDmgUbE2aYUBdE7nGWBG8gqqdeUb4eQio2fX00q4Hk)dBQJF4CCH3qZfXwiw4BdKKAGWnqJcBk6MqIf(RHaeBHyHVna(gaFdKKAGgf2u0nHel8xdbi2cXcFBG8g4YSCtsg6MqIf(RHa0Y1Xy4g4zdi7Un4T3GQna(JF40jTJpw54k7JHL6rpp6LqNxp(SfIf(EO0X3TJY7ehFriAAKGLDdM)yyPIr3KK1a5nGGg4sQSfMIOYMct22ajPg4sQSfMIm2Tzj3BdKKAGgf2uKlkLXi)vy8hdlvmITqSW3gaFdKKAGiennAzCAHog5FSBscbjObssnqeIMgrAk3pwWSJIrqcAGKudeHOPruZsHLHGe0a5niC6qL)SX1dJBGhnWBdKKAGyIXnqEdOhYW0)Y1Xy4g4zdQsOJF40jTJVUqmgwQh98O3k886XNTqSW3dLo(UDuEN44lcrtJeSSBW8hdlvmcsqdKKAaD6GWnWJg4sS2GkBq40jnum189JHLkYLy94hoDs74VHG5(PNLp65rVvSZRhF2cXcFpu64hoDs74htnF)yyPE8D7O8oXXxeIMgjyz3G5pgwQy0njznqsQbe0ariAAKUqmgwQiibnqsQb0qLYFzhSyjZFDQ5g4zdi7UnOYg4cS(1PMBa8nqEdiObc3ankSPihSPo4n(yyPIylel8TbssniC6qL)SX1dJBGNnOAdGVbssnqeIMgP74i(XWsfJwUogd3apAatz2bP8xNAUbYBq40Hk)zJRhg3apAG3JVtMRWFnwYSIpp69ONh9(wpVE8zlel89qPJVBhL3jo(e0axMLBsYq3esSWFneGwUogd3apAaz3TbV9gqOgij1aHBGlPYwykIOSDcRbssnq4gOrHnfDtiXc)1qaITqSW3gaFdK3a60bHBqLnWfy9Vmz2AGNnGoDqyuDq5giVbe0ariAAKUqmgwQOBsYAGKudeUbfMmB3yLH4GCH1OKg(Rle)PthegXwiw4BdGVbYBabnqeIMgDtiXc)1qa6MKSgij1ankSPiSUCuxgJrSfIf(2a4p(HtN0o(BiyUF6z5JEE07BX51JpBHyHVhkD8D7O8oXXxeIMgjyz3G5pgwQyeKGgij1a60bHBGhnWLyTbv2GWPtAOyQ57hdlvKlX6XpC6K2X3bBQdEJpgwQh98yvc786XNTqSW3dLo(UDuEN44lcrtJeSSBW8hdlvmcsqdKKAaD6GWnWJg4sS2GkBq40jnum189JHLkYLy94hoDs74hRlm(JHL6rppw1751JpBHyHVhkD8dNoPD8X8kGn9J1XiF8D7O8oXXFz6LXWcXc3a5nqJLmRiDQ5VM)7WnWJgCH2qN0o(ozUc)1yjZk(8O3JEESA1ZRhF2cXcFpu6472r5DIJF40Hk)zJRhg3apAG3JF40jTJVySBqMp65XQe(51JpBHyHVhkD8D7O8oXXNGg4YSCtsg6MqIf(RHa0Y1Xy4g4rdi7Un4T3ac1a5nyHmMoxYmcdTKhJ8hdlvmITqSW3gij1aHBGlPYwykIOSDcRbssnq4gOrHnfDtiXc)1qaITqSW3gaFdK3a60bHBqLnWfy9Vmz2AGNnGoDqyuDq5giVbe0ariAA0nHel8xdbOBsYAGKud0OWMIW6YrDzmgXwiw4BdG)4hoDs74VHG5(PNLp65XQu8ZRhF2cXcFpu6472r5DIJViennsxigdlv0njzh)WPtAhFXG8pP)6ooI4JEESkHoVE8zlel89qPJVBhL3jo(4eQio2fjacRqf(ZlKaDsdXwiw4BdK3ariAAKUqmgwQOBsYo(HtN0o(0fgdZTbTE0ZJvRWZRh)WPtAhFSYXv2hdl1JpBHyHVhkD0JE81DmISIpVEE0751JpBHyHVhkD8tbhFmRh)WPtAhFQXoHyHp(uJceF8fHOPrlJtl0Xi)JDtsiibnqsQbIq00iDHymSurqco(uJ9BrnF8XYm3hsWrppw986XNTqSW3dLo(PGJpM1JF40jTJp1yNqSWhFQrbIp(UKkBHPiIY2jSgiVbIq00OLXPf6yK)XUjjeKGgiVbIq00iDHymSurqcAGKudeUbUKkBHPiIY2jSgiVbIq00iDHymSurqco(uJ9BrnF8X6Mg5pwM5(qco65rc)86XNTqSW3dLo(PGJpM1H(4hoDs74tn2jel8XNASFlQ5Jpw30i)XYm3F56ym8X3TJY7ehFxsLTWuerz7e2XNAuG4pxW8X3Lz5MKmKUqmgwQOLRJXWhFQrbIp(Uml3KKHwgNwOJr(h7MKqlxhJHBGNvqAGlZYnjziDHymSurlxhJHp65rk(51JpBHyHVhkD8tbhFmRd9XpC6K2XNAStiw4Jp1y)wuZhFSmZ9xUogdF8D7O8oXX3Luzlmfru2oHD8Pgfi(ZfmF8DzwUjjdPleJHLkA56ym8XNAuG4JVlZYnjzOLXPf6yK)XUjj0Y1Xy4g4rfKg4YSCtsgsxigdlv0Y1Xy4JEEKqNxp(SfIf(EO0XpC6K2XhcZ)r5A8X3TJY7ehFcAGUJrKvK6fblWFim)fHOPBGKudCjv2ctreLTtynqEd0DmISIuViyb(7YSCtswdGVbYBabnGAStiwyew30i)XYm3hsqdK3acAGWnWLuzlmfru2oH1a5nq4gO7yezfPvrWc8hcZFriA6gij1axsLTWuerz7ewdK3aHBGUJrKvKwfblWFxMLBsYAGKud0DmISI0QixMLBsYqlxhJHBGKud0DmISIuViyb(dH5VienDdK3acAGWnq3XiYksRIGf4peM)Iq00nqsQb6ogrwrQxKlZYnjzOl0g6Kwd84zd0DmISI0QixMLBsYqxOn0jTgaFdKKAGUJrKvK6fblWFxMLBsYAG8giCd0DmISI0Qiyb(dH5VienDdK3aDhJiRi1lYLz5MKm0fAdDsRbE8Sb6ogrwrAvKlZYnjzOl0g6KwdGVbssnq4gqn2jelmcRBAK)yzM7djObYBabnq4gO7yezfPvrWc8hcZFriA6giVbe0aDhJiRi1lYLz5MKm0fAdDsRbuudiud8SbuJDcXcJWYm3F56ymCdKKAa1yNqSWiSmZ9xUogd3apAGUJrKvK6f5YSCtsg6cTHoP1G3Bq1gaFdKKAGUJrKvKwfblWFim)fHOPBG8gqqd0DmISIuViyb(dH5VienDdK3aDhJiRi1lYLz5MKm0fAdDsRbE8Sb6ogrwrAvKlZYnjzOl0g6KwdK3acAGUJrKvK6f5YSCtsg6cTHoP1akQbeQbE2aQXoHyHryzM7VCDmgUbssnGAStiwyewM5(lxhJHBGhnq3XiYks9ICzwUjjdDH2qN0AW7nOAdGVbssnGGgiCd0DmISIuViyb(dH5VienDdKKAGUJrKvKwf5YSCtsg6cTHoP1apE2aDhJiRi1lYLz5MKm0fAdDsRbW3a5nGGgO7yezfPvrUml3KKHwoUYAG8gO7yezfPvrUml3KKHUqBOtAnGIAaHAGhnGAStiwyewM5(lxhJHBG8gqn2jelmclZC)LRJXWnWZgO7yezfPvrUml3KKHUqBOtAn49guTbssnq4gO7yezfPvrUml3KKHwoUYAG8gqqd0DmISI0QixMLBsYqlxhJHBaf1ac1apBa1yNqSWiSUPr(JLzU)Y1Xy4giVbuJDcXcJW6Mg5pwM5(lxhJHBGhnOkH1a5nGGgO7yezfPErUml3KKHUqBOtAnGIAaHAGNnGAStiwyewM5(lxhJHBGKud0DmISI0QixMLBsYqlxhJHBaf1ac1apBa1yNqSWiSmZ9xUogd3a5nq3XiYksRICzwUjjdDH2qN0Aaf1ac1GkBa1yNqSWiSmZ9xUogd3apBa1yNqSWiSUPr(JLzU)Y1Xy4gij1aQXoHyHryzM7VCDmgUbE0aDhJiRi1lYLz5MKm0fAdDsRbV3GQnqsQbuJDcXcJWYm3hsqdGVbssnq3XiYksRICzwUjjdTCDmgUbuudiud8ObuJDcXcJW6Mg5pwM5(lxhJHBG8gqqd0DmISIuVixMLBsYqxOn0jTgqrnGqnWZgqn2jelmcRBAK)yzM7VCDmgUbssnq4gO7yezfPErWc8hcZFriA6giVbe0aQXoHyHryzM7VCDmgUbE0aDhJiRi1lYLz5MKm0fAdDsRbV3GQnqsQbuJDcXcJWYm3hsqdGVbW3a4Ba8na(gaFdKKAGyIXnqEdOhYW0)Y1Xy4g4zdOg7eIfgHLzU)Y1Xy4gaFdKKAGWnq3XiYks9IGf4peM)Iq00nqEdeUbUKkBHPiIY2jSgiVbe0aDhJiRiTkcwG)qy(lcrt3a5nGGgqqdeUbuJDcXcJWYm3hsqdKKAGUJrKvKwf5YSCtsgA56ymCd8ObeQbW3a5nGGgqn2jelmclZC)LRJXWnWJguLWAGKud0DmISI0QixMLBsYqlxhJHBaf1ac1apAa1yNqSWiSmZ9xUogd3a4Ba8nqsQbc3aDhJiRiTkcwG)qy(lcrt3a5nGGgiCd0DmISI0Qiyb(7YSCtswdKKAGUJrKvKwf5YSCtsgA56ymCdKKAGUJrKvKwf5YSCtsg6cTHoP1apE2aDhJiRi1lYLz5MKm0fAdDsRbW3a4p(4sQ4JVUJrKvVh98yfEE94Zwiw47Hsh)WPtAhFim)hLRXhF3okVtC8jOb6ogrwrAveSa)HW8xeIMUbssnWLuzlmfru2oH1a5nq3XiYksRIGf4VlZYnjzna(giVbe0aQXoHyHryDtJ8hlZCFibnqEdiObc3axsLTWuerz7ewdK3aHBGUJrKvK6fblWFim)fHOPBGKudCjv2ctreLTtynqEdeUb6ogrwrQxeSa)DzwUjjRbssnq3XiYks9ICzwUjjdTCDmgUbssnq3XiYksRIGf4peM)Iq00nqEdiObc3aDhJiRi1lcwG)qy(lcrt3ajPgO7yezfPvrUml3KKHUqBOtAnWJNnq3XiYks9ICzwUjjdDH2qN0Aa8nqsQb6ogrwrAveSa)DzwUjjRbYBGWnq3XiYks9IGf4peM)Iq00nqEd0DmISI0QixMLBsYqxOn0jTg4XZgO7yezfPErUml3KKHUqBOtAna(gij1aHBa1yNqSWiSUPr(JLzUpKGgiVbe0aHBGUJrKvK6fblWFim)fHOPBG8gqqd0DmISI0QixMLBsYqxOn0jTgqrnGqnWZgqn2jelmclZC)LRJXWnqsQbuJDcXcJWYm3F56ymCd8Ob6ogrwrAvKlZYnjzOl0g6KwdEVbvBa8nqsQb6ogrwrQxeSa)HW8xeIMUbYBabnq3XiYksRIGf4peM)Iq00nqEd0DmISI0QixMLBsYqxOn0jTg4XZgO7yezfPErUml3KKHUqBOtAnqEdiOb6ogrwrAvKlZYnjzOl0g6KwdOOgqOg4zdOg7eIfgHLzU)Y1Xy4gij1aQXoHyHryzM7VCDmgUbE0aDhJiRiTkYLz5MKm0fAdDsRbV3GQna(gij1acAGWnq3XiYksRIGf4peM)Iq00nqsQb6ogrwrQxKlZYnjzOl0g6Kwd84zd0DmISI0QixMLBsYqxOn0jTgaFdK3acAGUJrKvK6f5YSCtsgA54kRbYBGUJrKvK6f5YSCtsg6cTHoP1akQbeQbE0aQXoHyHryzM7VCDmgUbYBa1yNqSWiSmZ9xUogd3apBGUJrKvK6f5YSCtsg6cTHoP1G3Bq1gij1aHBGUJrKvK6f5YSCtsgA54kRbYBabnq3XiYks9ICzwUjjdTCDmgUbuudiud8SbuJDcXcJW6Mg5pwM5(lxhJHBG8gqn2jelmcRBAK)yzM7VCDmgUbE0GQewdK3acAGUJrKvKwf5YSCtsg6cTHoP1akQbeQbE2aQXoHyHryzM7VCDmgUbssnq3XiYks9ICzwUjjdTCDmgUbuudiud8SbuJDcXcJWYm3F56ymCdK3aDhJiRi1lYLz5MKm0fAdDsRbuudiudQSbuJDcXcJWYm3F56ymCd8SbuJDcXcJW6Mg5pwM5(lxhJHBGKudOg7eIfgHLzU)Y1Xy4g4rd0DmISI0QixMLBsYqxOn0jTg8EdQ2ajPgqn2jelmclZCFibna(gij1aDhJiRi1lYLz5MKm0Y1Xy4gqrnGqnWJgqn2jelmcRBAK)yzM7VCDmgUbYBabnq3XiYksRICzwUjjdDH2qN0Aaf1ac1apBa1yNqSWiSUPr(JLzU)Y1Xy4gij1aHBGUJrKvKwfblWFim)fHOPBG8gqqdOg7eIfgHLzU)Y1Xy4g4rd0DmISI0QixMLBsYqxOn0jTg8EdQ2ajPgqn2jelmclZCFibna(gaFdGVbW3a4Ba8nqsQbIjg3a5nGEidt)lxhJHBGNnGAStiwyewM5(lxhJHBa8nqsQbc3aDhJiRiTkcwG)qy(lcrt3a5nq4g4sQSfMIikBNWAG8gqqd0DmISIuViyb(dH5VienDdK3acAabnq4gqn2jelmclZCFibnqsQb6ogrwrQxKlZYnjzOLRJXWnWJgqOgaFdK3acAa1yNqSWiSmZ9xUogd3apAqvcRbssnq3XiYks9ICzwUjjdTCDmgUbuudiud8ObuJDcXcJWYm3F56ymCdGVbW3ajPgiCd0DmISIuViyb(dH5VienDdK3acAGWnq3XiYks9IGf4VlZYnjznqsQb6ogrwrQxKlZYnjzOLRJXWnqsQb6ogrwrQxKlZYnjzOl0g6Kwd84zd0DmISI0QixMLBsYqxOn0jTgaFdG)4JlPIp(6ogrwRE0JE0JpvEXtANhRsyv9syvy1k2XNuS2yKXh)kaVLv8pwb(yf5dBqdEfg3GPwqUAdOZTbWP74iIHLkgUgSCffAw(2aCwZniG0Sou(2ahSWiZyul0dgJBG3h2G3KgvEv(2a40OWMIOaCnqZgaNgf2uefqSfIf(cxdiWlLHh1c9GX4gq4pSbVjnQ8Q8TbWTqgtNlzgrb4AGMnaUfYy6CjZikGylel8fUgqGxkdpQf6bJXnGI)Wg8M0OYRY3ga3czmDUKzefGRbA2a4wiJPZLmJOaITqSWx4AqOnOcUI4bnGaVugEul0dgJBqf7Hn4nPrLxLVnaonkSPikaxd0SbWPrHnfrbeBHyHVW1ac8sz4rTqpymUbV1h2G3KgvEv(2a40OWMIOaCnqZgaNgf2uefqSfIf(cxdiWlLHh1c9GX4g4T6dBWBsJkVkFBaCAuytruaUgOzdGtJcBkIci2cXcFHRbe4LYWJAHEWyCd8w9Hn4nPrLxLVnaUfYy6CjZikaxd0SbWTqgtNlzgrbeBHyHVW1ac8sz4rTqpymUbEj0dBWBsJkVkFBaCAuytruaUgOzdGtJcBkIci2cXcFHRbeuLYWJAHEWyCd8sOh2G3KgvEv(2a4wiJPZLmJOaCnqZga3czmDUKzefqSfIf(cxdiWlLHh1c9GX4g4TcFydEtAu5v5BdGtJcBkIcW1anBaCAuytruaXwiw4lCnGaVugEul0dgJBqvc)Hn4nPrLxLVnaUfYy6CjZikaxd0SbWTqgtNlzgrbeBHyHVW1GqBqfCfXdAabEPm8OwOhmg3GQu8h2G3KgvEv(2a4wiJPZLmJOaCnqZga3czmDUKzefqSfIf(cxdcTbvWvepObe4LYWJAHAHQa8wwX)yf4JvKpSbn4vyCdMAb5QnGo3ga3LPdOIcxdwUIcnlFBaoR5geqAwhkFBGdwyKzmQf6bJXnO6dBWBsJkVkFBaClKX05sMruaUgOzdGBHmMoxYmIci2cXcFHRbe4LYWJAHEWyCdQ(Wg8M0OYRY3ga3czmDUKzefGRbA2a4wiJPZLmJOaITqSWx4AabEPm8OwOhmg3GQpSbVjnQ8Q8TbW5s7cnkIcW1anBaCU0UqJIOaITqSWx4AabEPm8OwOhmg3GQpSbVjnQ8Q8TbWHtOI4yxefGRbA2a4WjurCSlIci2cXcFHRbe4LYWJAHAHQa8wwX)yf4JvKpSbn4vyCdMAb5QnGo3gaNGLDzTyOW1GLROqZY3gGZAUbbKM1HY3g4GfgzgJAHEWyCdQ(Wg8M0OYRY3gahoHkIJDruaUgOzdGdNqfXXUikGylel8fUgeAdQGRiEqdiWlLHh1c9GX4gq4pSbVjnQ8Q8TbWTqgtNlzgrb4AGMnaUfYy6CjZikGylel8fUgeAdQGRiEqdiWlLHh1c9GX4gqXFydEtAu5v5BdGtJcBkIcW1anBaCAuytruaXwiw4lCni0gubxr8GgqGxkdpQf6bJXnOI9Wg8M0OYRY3gaNgf2uefGRbA2a40OWMIOaITqSWx4AabEPm8OwOhmg3G36dBWBsJkVkFBaCAuytruaUgOzdGtJcBkIci2cXcFHRbe4LYWJAHAHQa8wwX)yf4JvKpSbn4vyCdMAb5QnGo3gahwHRblxrHMLVnaN1CdcinRdLVnWblmYmg1c9GX4g49Hn4nPrLxLVnaonkSPikaxd0SbWPrHnfrbeBHyHVW1ac8sz4rTqpymUbu8h2G3KgvEv(2a4wiJPZLmJOaCnqZga3czmDUKzefqSfIf(cxdcTbvWvepObe4LYWJAHEWyCdi0dBWBsJkVkFBaClKX05sMruaUgOzdGBHmMoxYmIci2cXcFHRbe4LYWJAHEWyCd869Hn4nPrLxLVnaonkSPikaxd0SbWPrHnfrbeBHyHVW1ac8sz4rTqpymUbER(Wg8M0OYRY3gaNgf2uefGRbA2a40OWMIOaITqSWx4AabEPm8OwOhmg3aVe(dBWBsJkVkFBaCAuytruaUgOzdGtJcBkIci2cXcFHRbe4LYWJAHEWyCd8sXFydEtAu5v5BdGtJcBkIcW1anBaCAuytruaXwiw4lCnGGQugEul0dgJBGxk(dBWBsJkVkFBaC4eQio2frb4AGMnaoCcveh7IOaITqSWx4AabEPm8OwOhmg3aVe6Hn4nPrLxLVnaonkSPikaxd0SbWPrHnfrbeBHyHVW1ac8sz4rTqpymUbERWh2G3KgvEv(2a40OWMIOaCnqZgaNgf2uefqSfIf(cxdiOkLHh1c9GX4g4TcFydEtAu5v5BdGBHmMoxYmIcW1anBaClKX05sMruaXwiw4lCnGaVugEul0dgJBG3k2dBWBsJkVkFBaCAuytruaUgOzdGtJcBkIci2cXcFHRbe4LYWJAHEWyCd8(wFydEtAu5v5BdGtJcBkIcW1anBaCAuytruaXwiw4lCnGGQugEul0dgJBqvc)Hn4nPrLxLVnaonkSPikaxd0SbWPrHnfrbeBHyHVW1acQsz4rTqpymUbvj8h2G3KgvEv(2a4wiJPZLmJOaCnqZga3czmDUKzefqSfIf(cxdiWlLHh1c9GX4guLqpSbVjnQ8Q8TbWHtOI4yxefGRbA2a4WjurCSlIci2cXcFHRbe4LYWJAHAHQa8wwX)yf4JvKpSbn4vyCdMAb5QnGo3gaNUJrKvmCny5kk0S8Tb4SMBqaPzDO8TboyHrMXOwOhmg3ac9Wg8M0OYRY3g4p1VPbyzMguUbVTgOzdEau0G7qDWtAnifWBO52acEh(gqaHOm8OwOhmg3ac9Wg8M0OYRY3gaNUJrKvKxefGRbA2a40DmISIuVikaxdiOQxkdpQf6bJXnGqpSbVjnQ8Q8TbWP7yezfvfrb4AGMnaoDhJiRiTkIcW1acQwHugEul0dgJBqf(Wg8M0OYRY3g4p1VPbyzMguUbVTgOzdEau0G7qDWtAnifWBO52acEh(gqaHOm8OwOhmg3Gk8Hn4nPrLxLVnaoDhJiRiVikaxd0SbWP7yezfPEruaUgqq1kKYWJAHEWyCdQWh2G3KgvEv(2a40DmISIQIOaCnqZgaNUJrKvKwfrb4Aabv9sz4rTqTqvG1cYv5BdQWgeoDsRbLbRyul0XxWM0tHp(uSuSnOIBSeX1HHHncAqfqqMYBleflfBdecY4gu9T(sdQsyv92c1cfoDsdJeSSlRfdTYNVlMQw47NUeY4lPXi)1KYJ1cfoDsdJeSSlRfdTYNVtxymm3g06ld9tCcveh7IeaHvOc)5fsGoP1cfoDsdJeSSlRfdTYNVRX(1ne8Yq)CHmMoxYmcNqf6CjZFUwKxClu40jnmsWYUSwm0kF((nHel8xdbViyzxG1Vo18tVe2ld9ZWPdv(Zgxpm2dVssc7sQSfMIikBNWKlSgf2ue1SuyzTqHtN0Wibl7YAXqR857uJDcXc)If18twP)cw2fy9fQrbIFwyYSDJvgIdYfwJsA4VUq8NoDqyeBHyHVYXSQJrgJ4GCH1OK2htkeGylel8TfkC6KggjyzxwlgALpFxxigdl1xeSSlW6Nv6pxrHgbp9(IGLDbw)ym9FdJ4Zk2lcw2fy9Rtn)S6ld9tQXoHyHrSs)fSSlWAlu40jnmsWYUSwm0kF(Em189JHL6ld9ZWPdv(Zgxpm2tcxobc7sQSfMIikBNWKlSgf2ue1SuyzssHthQ8NnUEySNvHxUWuJDcXcJyL(lyzxG1wOWPtAyKGLDzTyOv(8DSYXv2hdl1xg6NHthQ8NnUEyShvLKiWLuzlmfru2oHjjPrHnfrnlfwg8YdNou5pBC9W4NvLKOg7eIfgXk9xWYUaRTqTqHtN0Wv(8DxczkVFmSuBHcNoPHR857UeYuE)yyP(szm(7UpjCc7LH(5czmDUKzeMfadIIb)fSPRe1HoPjjHtOI4yxKnYc8xZSG)cYbNMKebU0UqJIwMkV4O8t6pDUkKXYfEHmMoxYmcZcGbrXG)c20vI6qN0GVfIITbvKzdcyCCBqy3g86gwffAkdfd3GhRa(nnGnUEyCf0nGe3GBAWPn4MnqHn4gqNBdeucz8IBGi7cim3GrH72arUbAMnaliQRL1GWUnGe3axyWPny54ofzn41nSkAdWcy3qpUgicrtJrTqHtN0Wv(8DDdRIcnLHIzmYFmSuFzOFkSglzwrd(lOeY4TfIILITbvC4siRb0HBmYnqwcTn4MqIAdGmDknqwc1aybvUbcG0guXZ40cDmYn4TC3KudUjj7LgKBdg6gOW4g4YSCtswdgCd0mBqjnYnqZgC5siRb0HBmYnqwcTnOItcjQOgubs3alnUbjDduymMBGlT7OtA4gel3GqSWnqZguZAdinkSXAGcJBGxcRby2L2f3GcZKczV0afg3a8u3a6WX4gilH2guXjHe1geqAwh64IsrgQfIILITbHtN0Wv(8DJjrNq29Vmolu5xg6N4eQio2fzmj6eYU)LXzHklNariAA0Y40cDmY)y3KecsGKKlZYnjzOLXPf6yK)XUjj0Y1Xyyp8syssIjglNEidt)lxhJH90BfkjjSlPYwykIOSDcd(wOWPtA4kF(UlkLF40jTFzW6lwuZp1DmISIFzOF6sQSfMIikBNWK7YSCtsgsxigdlv0Y1Xyy5Uml3KKHwgNwOJr(h7MKqlxhJHLKe2Luzlmfru2oHj3Lz5MKmKUqmgwQOLRJXWTqHtN0Wv(8Dxuk)WPtA)YG1xSOMF6U4wOWPtA4kF(UlkLF40jTFzW6lwuZpX6ld9ZWPdv(Zgxpm2tcVfkC6KgUYNV7Is5hoDs7xgS(If18tDhhrmSuXVm0pdNou5pBC9WypQ2c1cfoDsdJCx8trEX8sCmYVm0pfHOPr6cXyyPIGeijrpKHP)LRJXWE6LWBHcNoPHrUlUYNVlwY8(PHwzVm0pfHOPr6cXyyPIGeij5YSCtsgsxigdlv0Y1XyypiCctssmXy50dzy6F56ymSNERWwOWPtAyK7IR857H5ySUr57Is5LH(PiennsxigdlveKajjxMLBsYq6cXyyPIwUogd7bHtyssIjglNEidt)lxhJH90Bf2cfoDsdJCxCLpFNEwwSK59LH(PiennsxigdlveKajjxMLBsYq6cXyyPIwUogd7bHtyssIjglNEidt)lxhJH98TOfkC6Kgg5U4kF(EzidtX)kOGUKRztFzOFkcrtJ0fIXWsfDtswlu40jnmYDXv(8DbPoP9Yq)ueIMgPleJHLkcsGCceHOPrILmVfiSIGeijPXsMvemokkmKaN6zvcdEjjXeJLtpKHP)LRJXWEwTcBHAHcNoPHry9jw54k7JHL6ld9tnkSPiSYXv2NoDqy5eiyzQFYUlYlcRCCL9XWsvUienncRCCL9PthegTCDmg2tcjjjcrtJWkhxzF60bHr3KKbVCceHOPrlJtl0Xi)JDtsOBsYKKe2Luzlmfru2oHbFlu40jnmcRv(8DItP8XWsTfkC6KggH1kF((nHel8xdbVm0pDjv2ctreLTtyYDzwUjjdTmoTqhJ8p2njHwUogd7jz3vssyxsLTWuerz7eMCHDjv2ctr2qgM(PdwsYLuzlmfzdzy6Noy5e4YSCtsgI0uUFSGzhfJwUogd7jz3vsYLz5MKmePPC)ybZokgTCDmg2dcNWGxssmXy50dzy6F56ymSNEjulu40jnmcRv(8D6sS8lLX4V7(SkHEzOFQX(1neGGeiFHmMoxYmcNqf6CjZFUwKxClu40jnmcRv(8Dn2VUHGxg6NlKX05sMr4eQqNlz(Z1I8ILRX(1neGwUogd7jz3vUlZYnjzi6sSmA56ymSNKD3wOWPtAyewR857mLfus8qL)yyP2cfoDsdJWALpFN0uUFSGzhf3cfoDsdJWALpFNUeY47hdl1wOWPtAyewR857xouyFhSG4g1Vm0pPtheUsxG1)YKzZt60bHr1bLBHcNoPHryTYNVh)AO9Y7pP)UnjHBHcNoPHryTYNVtkMYyK)XUjPxg6NUml3KKHwgNwOJr(h7MKqlxhJH9KS7kNaH1OWMIyklOK4Hk)XWsvsseIMgjwY8wGWkcsa8ssc7sQSfMIikBNWKKCzwUjjdTmoTqhJ8p2njHwUogdljjMySC6Hmm9VCDmg2tc1cfoDsdJWALpFFzCAHog5FSBs6LH(Pienn6MqIf(RHaeKajjH1OWMIUjKyH)AiqssmXy50dzy6F56ymSNER2cfoDsdJWALpFNAwkSSxg6NIq00OLXPf6yK)XUjjeKajjHDjv2ctreLTtyYjqeIMgjyz3G5pgwQy0njzsscRrHnf5Gn1bVXhdlvjPWPdv(Zgxpm2ZQW3cfoDsdJWALpFhRCCL9XWs9LH(PlPYwykIOSDctoD6GWv6cS(xMmBEsNoimQoOSCciWLz5MKm0Y40cDmY)y3KeA56ymSNKD33oHlNaHXjurCSlIPPHWdv(h2uh)W54cVHMRKKWAuytr3esSWFneap8ssAuytr3esSWFnei3Lz5MKm0nHel8xdbOLRJXWEs2DF7vHVfkC6KggH1kF(UUqmgwQVm0pfHOPrcw2ny(JHLkgDtsMCcCjv2ctruztHjBLKCjv2ctrg72SK7vssJcBkYfLYyK)km(JHLkgEjjriAA0Y40cDmY)y3KecsGKKiennI0uUFSGzhfJGeijjcrtJOMLcldbjqE40Hk)zJRhg7HxjjXeJLtpKHP)LRJXWEwLqTqHtN0WiSw5Z33qWC)0ZYVm0pxiJPZLmJWql5Xi)XWsflxJcBkcRlh1LXy5e4YSCtsg6MqIf(RHa0Y1Xyypi7UVDcjjjSlPYwykIOSDctssynkSPOBcjw4VgcGpC6KggH1kF(Ud2uh8gFmSuFzOFkcrtJeSSBW8hdlvmcsGKeD6GWE4sSwz40jnum189JHLkYLyTfkC6KggH1kF(Em189JHL6lozUc)1yjZk(P3xg6NIq00ibl7gm)XWsfJUjjtsIariAAKUqmgwQiibss0qLYFzhSyjZFDQzpj7Uv6cS(1PMHxobcRrHnf5Gn1bVXhdlvjPWPdv(Zgxpm2ZQWljjcrtJ0DCe)yyPIrlxhJH9GPm7Gu(RtnlpC6qL)SX1dJ9WBlu40jnmcRv(89nem3p9S8ld9tcCzwUjjdDtiXc)1qaA56ymShKD33oHKKe2Luzlmfru2oHjjjSgf2u0nHel8xdbWlNoDq4kDbw)ltMnpPthegvhuwobIq00iDHymSur3KKjjjCHjZ2nwzioixynkPH)6cXF60bHrSfIf(cVCceHOPr3esSWFneGUjjtssJcBkcRlh1LXy4BHcNoPHryTYNV7Gn1bVXhdl1xg6NIq00ibl7gm)XWsfJGeijrNoiShUeRvgoDsdftnF)yyPICjwBHcNoPHryTYNVhRlm(JHL6ld9triAAKGLDdM)yyPIrqcKKOthe2dxI1kdNoPHIPMVFmSurUeRTqHtN0WiSw5Z3X8kGn9J1Xi)ItMRWFnwYSIF69LH(5Y0lJHfIfwUglzwr6uZFn)3H94cTHoP1cfoDsdJWALpFxm2niZVm0pdNou5pBC9Wyp82cfoDsdJWALpFFdbZ9tpl)Yq)KaxMLBsYq3esSWFneGwUogd7bz39Tti5lKX05sMryOL8yK)yyPILKe2Luzlmfru2oHjjjSgf2u0nHel8xdbWlNoDq4kDbw)ltMnpPthegvhuwobIq00OBcjw4Vgcq3KKjjPrHnfH1LJ6Yym8TqHtN0WiSw5Z3fdY)K(R74iIFzOFkcrtJ0fIXWsfDtswlu40jnmcRv(8D6cJH52GwFzOFItOI4yxKaiScv4pVqc0jn5Iq00iDHymSur3KK1cfoDsdJWALpFhRCCL9XWsTfQfkC6KggP74iIHLk(jw54k7JHL6ld9tnkSPiSYXv2NoDqy5J9PldzyQCriAAew54k7tNoimA56ymSNeQfkC6KggP74iIHLkUYNVFtiXc)1qWld9txsLTWuerz7eMCxMLBsYqlJtl0Xi)JDtsOLRJXWEs2DLKe2Luzlmfru2oHjxyxsLTWuKnKHPF6GLKCjv2ctr2qgM(PdwobUml3KKHinL7hly2rXOLRJXWEs2DLKCzwUjjdrAk3pwWSJIrlxhJH9GWjm4LKetmwo9qgM(xUogd7PxcRfkC6KggP74iIHLkUYNVRX(1ne8Yq)CHmMoxYmcNqf6CjZFUwKxSCn2VUHa0Y1Xyypj7UYDzwUjjdrxILrlxhJH9KS72cfoDsdJ0DCeXWsfx5Z3PlXYVugJ)U7ZQe6LH(Pg7x3qacsG8fYy6CjZiCcvOZLm)5ArEXTqHtN0WiDhhrmSuXv(8DMYckjEOYFmSuBHcNoPHr6ooIyyPIR857KMY9Jfm7O4wOWPtAyKUJJigwQ4kF(oPykJr(h7MKEzOF6YSCtsgAzCAHog5FSBscTCDmg2tYURCcewJcBkIPSGsIhQ8hdlvjjriAAKyjZBbcRiibWljjSlPYwykIOSDctsYLz5MKm0Y40cDmY)y3KeA56ymShEjmjjXeJLtpKHP)LRJXWEsOwOWPtAyKUJJigwQ4kF((Y40cDmY)y3K0ld9triAA0nHel8xdbiibsscRrHnfDtiXc)1qGKKyIXYPhYW0)Y1Xyyp9wTfkC6KggP74iIHLkUYNVtnlfw2ld9triAA0Y40cDmY)y3KecsGKKWUKkBHPiIY2jSwOWPtAyKUJJigwQ4kF(UySBqMBHcNoPHr6ooIyyPIR8576cXyyP2cfoDsdJ0DCeXWsfx5Z33qWC)0ZYVm0pxiJPZLmJWql5Xi)XWsflNaxMLBsYqlJtl0Xi)JDtsOLRJXWE4LWKKe2Luzlmfru2oHjjjSgf2u0nHel8xdbWlxeIMgP74i(XWsfJwUogd7XtMYSds5Vo1Clu40jnms3XredlvCLpFpMA((XWs9fNmxH)ASKzf)07ld9triAAKUJJ4hdlvmA56ymShpzkZoiL)6uZYjqeIMgjyz3G5pgwQy0njzss0qLYFzhSyjZFDQzpDbw)6uZvs2DLKeHOPr6cXyyPIGeaFlu40jnms3XredlvCLpF)YHc77Gfe3O(LH(jD6GWv6cS(xMmBEsNoimQoOClu40jnms3XredlvCLpFFdbZ9tpl)Yq)KaxMLBsYq3esSWFneGwUogd7bz39Tti5lKX05sMryOL8yK)yyPILKe2Luzlmfru2oHjjjSgf2u0nHel8xdbWlNoDq4kDbw)ltMnpPthegvhuwobIq00OBcjw4Vgcq3KKjjPrHnfH1LJ6Yym8TqHtN0WiDhhrmSuXv(89AOIoyyP(Yq)ueIMgP74i(XWsfJUjjtsseIMgjyz3G5pgwQyeKa50Pdc7HlXALHtN0qXuZ3pgwQixIv5eiSgf2uKd2uh8gFmSuLKcNou5pBC9WypiC4BHcNoPHr6ooIyyPIR857oytDWB8XWs9LH(PiennsWYUbZFmSuXiibYPthe2dxI1kdNoPHIPMVFmSurUeRYdNou5pBC9WypP4TqHtN0WiDhhrmSuXv(8DItP8XWs9LH(Pienn6YX9ZYy0njzTqHtN0WiDhhrmSuXv(894xdTxE)j93TjjClu40jnms3XredlvCLpFNUeY47hdl1wOWPtAyKUJJigwQ4kF(oMxbSPFSog5xCYCf(RXsMv8tVVm0pxMEzmSqSWTqHtN0WiDhhrmSuXv(89AOIoyyP(Yq)KoDqypCjwRmC6KgkMA((XWsf5sSkNaxMLBsYqlJtl0Xi)JDtsOLRJXWEqijjHDjv2ctreLTtyss0PdcxPlW6FzYS5bD6GWO6GYW3cfoDsdJ0DCeXWsfx5Z31y)6gcEzOFUqgtNlzgzmgpgzsXkd)1neiymY)qGGydfc3cfoDsdJ0DCeXWsfx5Z3PxMPygJ8x3qWld9ZfYy6CjZiJX4Xitkwz4VUHabJr(hceeBOq4wOWPtAyKUJJigwQ4kF(Uyq(N0FDhhr8ld9triAAKUqmgwQOBsYAHcNoPHr6ooIyyPIR857yLJRSpgwQTqTqHtN0WiDhJiR4NuJDcXc)If18tSmZ9He8c1OaXpfHOPrlJtl0Xi)JDtsiibssIq00iDHymSurqcAHcNoPHr6ogrwXv(8DQXoHyHFXIA(jw30i)XYm3hsWluJce)0Luzlmfru2oHjxeIMgTmoTqhJ8p2njHGeixeIMgPleJHLkcsGKKWUKkBHPiIY2jm5Iq00iDHymSurqcAHcNoPHr6ogrwXv(8DQXoHyHFXIA(jw30i)XYm3F56ym8lPGNywh6xCPDhDs7PlPYwykIOSDc7fQrbIF6YSCtsgAzCAHog5FSBscTCDmg2ZkiUml3KKH0fIXWsfTCDmg(fQrbI)CbZpDzwUjjdPleJHLkA56ymClu40jnms3XiYkUYNVtn2jel8lwuZpXYm3F56ym8lPGNywh6xCPDhDs7PlPYwykIOSDc7fQrbIF6YSCtsgAzCAHog5FSBscTCDmg2JkiUml3KKH0fIXWsfTCDmg(fQrbI)CbZpDzwUjjdPleJHLkA56ymClu40jnms3XiYkUYNVdH5)OCn(fCjv8tDhJiREFzOFsGUJrKvKxeSa)HW8xeIMwsYLuzlmfru2oHjx3XiYkYlcwG)Uml3KKbVCcOg7eIfgH1nnYFSmZ9HeiNaHDjv2ctreLTtyYfw3XiYkQkcwG)qy(lcrtlj5sQSfMIikBNWKlSUJrKvuveSa)DzwUjjtss3XiYkQkYLz5MKm0Y1XyyjjDhJiRiViyb(dH5VienTCcew3XiYkQkcwG)qy(lcrtljP7yezf5f5YSCtsg6cTHoP5XtDhJiROQixMLBsYqxOn0jn4LK0DmISI8IGf4VlZYnjzYfw3XiYkQkcwG)qy(lcrtlx3XiYkYlYLz5MKm0fAdDsZJN6ogrwrvrUml3KKHUqBOtAWljjm1yNqSWiSUPr(JLzUpKa5eiSUJrKvuveSa)HW8xeIMwob6ogrwrErUml3KKHUqBOtAueH8KAStiwyewM5(lxhJHLKOg7eIfgHLzU)Y1Xyyp0DmISI8ICzwUjjdDH2qN0EBvHxss3XiYkQkcwG)qy(lcrtlNaDhJiRiViyb(dH5VienTCDhJiRiVixMLBsYqxOn0jnpEQ7yezfvf5YSCtsg6cTHoPjNaDhJiRiVixMLBsYqxOn0jnkIqEsn2jelmclZC)LRJXWssuJDcXcJWYm3F56ymSh6ogrwrErUml3KKHUqBOtAVTQWljrGW6ogrwrErWc8hcZFriAAjjDhJiROQixMLBsYqxOn0jnpEQ7yezf5f5YSCtsg6cTHoPbVCc0DmISIQICzwUjjdTCCLjx3XiYkQkYLz5MKm0fAdDsJIiKhuJDcXcJWYm3F56ymSCQXoHyHryzM7VCDmg2tDhJiROQixMLBsYqxOn0jT3wvjjH1DmISIQICzwUjjdTCCLjNaDhJiROQixMLBsYqlxhJHPic5j1yNqSWiSUPr(JLzU)Y1Xyy5uJDcXcJW6Mg5pwM5(lxhJH9OkHjNaDhJiRiVixMLBsYqxOn0jnkIqEsn2jelmclZC)LRJXWss6ogrwrvrUml3KKHwUogdtreYtQXoHyHryzM7VCDmgwUUJrKvuvKlZYnjzOl0g6KgfrOkPg7eIfgHLzU)Y1XyypPg7eIfgH1nnYFSmZ9xUogdljrn2jelmclZC)LRJXWEO7yezf5f5YSCtsg6cTHoP92Qkjrn2jelmclZCFibWljP7yezfvf5YSCtsgA56ymmfripOg7eIfgH1nnYFSmZ9xUogdlNaDhJiRiVixMLBsYqxOn0jnkIqEsn2jelmcRBAK)yzM7VCDmgwssyDhJiRiViyb(dH5VienTCcOg7eIfgHLzU)Y1Xyyp0DmISI8ICzwUjjdDH2qN0EBvLKOg7eIfgHLzUpKa4HhE4HhEjjXeJLtpKHP)LRJXWEsn2jelmclZC)LRJXWWljjSUJrKvKxeSa)HW8xeIMwUWUKkBHPiIY2jm5eO7yezfvfblWFim)fHOPLtabctn2jelmclZCFibss6ogrwrvrUml3KKHwUogd7bHGxobuJDcXcJWYm3F56ymShvjmjjDhJiROQixMLBsYqlxhJHPic5b1yNqSWiSmZ9xUogddp8sscR7yezfvfblWFim)fHOPLtGW6ogrwrvrWc83Lz5MKmjjDhJiROQixMLBsYqlxhJHLK0DmISIQICzwUjjdDH2qN084PUJrKvKxKlZYnjzOl0g6Kg8W3cfoDsdJ0DmISIR857qy(pkxJFbxsf)u3XiYA1xg6NeO7yezfvfblWFim)fHOPLKCjv2ctreLTtyY1DmISIQIGf4VlZYnjzWlNaQXoHyHryDtJ8hlZCFibYjqyxsLTWuerz7eMCH1DmISI8IGf4peM)Iq00ssUKkBHPiIY2jm5cR7yezf5fblWFxMLBsYKK0DmISI8ICzwUjjdTCDmgwss3XiYkQkcwG)qy(lcrtlNaH1DmISI8IGf4peM)Iq00ss6ogrwrvrUml3KKHUqBOtAE8u3XiYkYlYLz5MKm0fAdDsdEjjDhJiROQiyb(7YSCtsMCH1DmISI8IGf4peM)Iq00Y1DmISIQICzwUjjdDH2qN084PUJrKvKxKlZYnjzOl0g6Kg8ssctn2jelmcRBAK)yzM7djqobcR7yezf5fblWFim)fHOPLtGUJrKvuvKlZYnjzOl0g6KgfripPg7eIfgHLzU)Y1XyyjjQXoHyHryzM7VCDmg2dDhJiROQixMLBsYqxOn0jT3wv4LK0DmISI8IGf4peM)Iq00Yjq3XiYkQkcwG)qy(lcrtlx3XiYkQkYLz5MKm0fAdDsZJN6ogrwrErUml3KKHUqBOtAYjq3XiYkQkYLz5MKm0fAdDsJIiKNuJDcXcJWYm3F56ymSKe1yNqSWiSmZ9xUogd7HUJrKvuvKlZYnjzOl0g6K2BRk8sseiSUJrKvuveSa)HW8xeIMwss3XiYkYlYLz5MKm0fAdDsZJN6ogrwrvrUml3KKHUqBOtAWlNaDhJiRiVixMLBsYqlhxzY1DmISI8ICzwUjjdDH2qN0Oic5b1yNqSWiSmZ9xUogdlNAStiwyewM5(lxhJH9u3XiYkYlYLz5MKm0fAdDs7TvvssyDhJiRiVixMLBsYqlhxzYjq3XiYkYlYLz5MKm0Y1XyykIqEsn2jelmcRBAK)yzM7VCDmgwo1yNqSWiSUPr(JLzU)Y1XyypQsyYjq3XiYkQkYLz5MKm0fAdDsJIiKNuJDcXcJWYm3F56ymSKKUJrKvKxKlZYnjzOLRJXWueH8KAStiwyewM5(lxhJHLR7yezf5f5YSCtsg6cTHoPrreQsQXoHyHryzM7VCDmg2tQXoHyHryDtJ8hlZC)LRJXWssuJDcXcJWYm3F56ymSh6ogrwrvrUml3KKHUqBOtAVTQssuJDcXcJWYm3hsa8ss6ogrwrErUml3KKHwUogdtreYdQXoHyHryDtJ8hlZC)LRJXWYjq3XiYkQkYLz5MKm0fAdDsJIiKNuJDcXcJW6Mg5pwM5(lxhJHLKew3XiYkQkcwG)qy(lcrtlNaQXoHyHryzM7VCDmg2dDhJiROQixMLBsYqxOn0jT3wvjjQXoHyHryzM7djaE4HhE4HxssmXy50dzy6F56ymSNuJDcXcJWYm3F56ymm8sscR7yezfvfblWFim)fHOPLlSlPYwykIOSDctob6ogrwrErWc8hcZFriAA5eqGWuJDcXcJWYm3hsGKKUJrKvKxKlZYnjzOLRJXWEqi4Lta1yNqSWiSmZ9xUogd7rvctss3XiYkYlYLz5MKm0Y1XyykIqEqn2jelmclZC)LRJXWWdVKKW6ogrwrErWc8hcZFriAA5eiSUJrKvKxeSa)DzwUjjtss3XiYkYlYLz5MKm0Y1XyyjjDhJiRiVixMLBsYqxOn0jnpEQ7yezfvf5YSCtsg6cTHoPbp8hFSa2DESkHO4h9ONda]] )

end