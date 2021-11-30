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


    spec:RegisterPack( "Marksmanship", 20211123, [[d8unqcqicPhreLUeqj1MisFcHmka6uaQvHqvXRaqZcOYTqOYUa9lekdJi0XOclJk1Zak10qOkxJiY2OssFJiQACerfNJkjSoaO3bussZJkX9aK9ri(hrujhKkjQfse8qaWejIICrGsIpcucnsIOO6KujrwjsQxsefLzsLu3eOKu7eO4NaLGHsevQLsefEQKAQav9veQknwKe7fI)QsdwvhwyXe1JPQjlXLrTzK6ZiQrJGtRy1aLK41iXSvXTLKDt53IgoH64iuvTCLEoutN01H02bY3rKXJK05PIwpqjA(eSFPgXbc4rQlHYiGXTeD7WHd3Gn0TBIhXZHRaPwDkMrQfhEkbzgP2IkgPgS6yPGRcdtyeJuloCEYOGaEKACIUEgPwY2pbvfJbqIrmYJsavg6ZkIHNk0tOtA(nOvIHNkpXqQLrNJ6kziYi1LqzeW4wIUD4WHBWg62nXJ45aSrQduLqUi11tfaGutykf2qKrQlm2JudwDSuWvHHjmI7xYCut5TPgmjiUsM3(Da2GRF3s0TJM6MAaGqyKzma2utC9dgMeDIAL(LmyCEaX9p4(Tu7p6VI9ecB89Re4(JsjT(9HrmsZ50Fvybzg2utC9lzWyNMNl9hLsA9lENCh1z)KgLq)1tfa0VRSKBxdBQjU(DnR9lzMZDcd3FHXonF)kbE2(bajt4(XzfRtfJHi1NbRyeWJuR74PGjKkgb8iGXbc4rQzlKpCbrci1(DuENaPwJdBkeRCuCEPtpkgYwiF4s)s7FSl9zitq7xA)YO00qSYrX5Lo9Oy4YvXy4(DPFjHuhEDsdPgRCuCEXesfrraJBeWJuZwiF4cIeqQ97O8obs9IAmDUKzO4e1t4M03nalZ9sVb5k2umKTq(WL(L2VmknnK(eo5fFRILcevmsD41jnKAkZ5CXesfrradyJaEKA2c5dxqKasTFhL3jqQxuJPZLmdfNOEc3K(UbyzUx6nixXMIHSfYhUGuhEDsdPM(eo5YftivefbmepeWJuZwiF4cIeqQ97O8obsnG97tqSfMcP4CNW6xA)(mpLKKbxgNwOJr(g7MKGlxfJH73L(j7l9li0VO97tqSfMcP4CNW6xA)I2VpbXwyk0gYe0lDW9li0VpbXwyk0gYe0lDW9lTFa73N5PKKmiP5uUyXZokgUCvmgUFx6NSV0VGq)(mpLKKbjnNYflE2rXWLRIXW9ls)GTe7h4(fe6xJLmRqDQ4RM3YW97s)oKy)cc97Z8ussgCzCAHog5BSBscUCvmgUFr63He7xA)Hxhq8LnUAyC)I0py3pW9lTFa7x0(3ykxgeBkmkfmKP6GvC)cc9VXuUmi2uyuky4YvXy4(fPFxr)cc9lA)(eeBHPqko3jS(bgPo86KgsDjrLp8vdXikcyKec4rQzlKpCbrci1(DuENaPErnMoxYmeNOh6CjZxUsMxmKTq(WL(L2Vg7v3qmC5QymC)U0pzFPFP97Z8ussgK(eldxUkgd3Vl9t2xqQdVoPHuRXE1neJOiGXvrapsnBH8HlisaPo86Kgsn9jwgP2VJY7ei1ASxDdXquX9lT)f1y6CjZqCIEOZLmF5kzEXq2c5dxqQpJXxFbP2TKqueWi5rapsD41jnKAMQIpjEaXxmHurQzlKpCbrcikcyKCqapsnBH8HlisaP2VJY7ei1I2)gt5YGytHrPGHmvhSI7xqO)nMYLbXMcJsbdxUkgd3Vi97qI9li0F41beFzJRgg3Via1)gt5YGytHrPGH(e10(j(0VBK6WRtAi1KMt5Ifp7OyefbmUceWJuZwiF4cIeqQ97O8obsTpZtjjzWLXPf6yKVXUjj4YvXy4(DPFY(s)s7hW(fTFnoSPqMQIpjEaXxmHuHSfYhU0VGq)YO00q5tMLdkwHOI7h4(fe6x0(9ji2ctHuCUty9li0VpZtjjzWLXPf6yKVXUjj4YvXy4(fPFhsSFbH(LtmUFP9tpKjO3LRIXW97s)scPo86KgsnPyoJr(g7MKqueW4qIiGhPMTq(WfejGu73r5DcKAa73N5PKKmiO8CyNWLRIXW97s)K9L(fe6x0(14WMcbLNd7eYwiF4s)cc9RXsMvOov8vZBz4(DPFhU7h4(L2pG9lA)BmLldInfgLcgYuDWkUFbH(3ykxgeBkmkfmC5QymC)I0VROFbH(dVoG4lBC1W4(fbO(3ykxgeBkmkfm0NOM2pXN(D3pWi1HxN0qQxgNwOJr(g7MKqueW4Wbc4rQzlKpCbrci1(DuENaPwgLMgUmoTqhJ8n2njbrf3VGq)(mpLKKbxgNwOJr(g7MKGlxfJH7xK(DiX(fe6x0(9ji2ctHuCUtyi1HxN0qQbLNd7erraJd3iGhPo86KgsTCSBqMrQzlKpCbrcikcyCa2iGhPMTq(WfejGu73r5DcKAzuAA4Y40cDmY3y3KeevC)cc97Z8ussgCzCAHog5BSBscUCvmgUFr63He7xqOFr73NGylmfsX5oH1VGq)Yjg3V0(PhYe07YvXy4(DPF3sePo86KgsTUOmMqQikcyCq8qapsnBH8HlisaP2VJY7ei1lQX05sMHy0L8yKVycPIHSfYhU0V0(bSFFMNssYGlJtl0XiFJDtsWLRIXW9ls)oKy)cc9lA)(eeBHPqko3jS(fe6x0(14WMcljQ8HVAigYwiF4s)a3V0(LrPPH6oEkxmHuXWLRIXW9lcq9ZuL9OkF1PIrQdVoPHuVH4PCPNLrueW4qsiGhPMTq(WfejGuhEDsdPoMkUCXesfP2VJY7ei1YO00qDhpLlMqQy4YvXy4(fbO(zQYEuLV6uX9lTFa7xgLMgkEz)G5lMqQyyjjz9li0pn65Cx2tiwY8vNkUFx63hy9Qtf3pa7NSV0VGq)YO00qDrzmHuHOI7hyKAVt)HVASKzfJaghikcyC4QiGhPMTq(WfejGu73r5DcKA60JI7hG97dSExMmB97s)0PhfdRcQIuhEDsdPUWHs46jeu2OcrraJdjpc4rQzlKpCbrci1(DuENaPgW(9zEkjjdUmoTqhJ8n2njbxUkgd3Vi97qI9lT)f1y6CjZqm6sEmYxmHuXq2c5dx6xqOFr73NGylmfsX5oH1VGq)I2)IAmDUKzigDjpg5lMqQyiBH8Hl9li0VO9RXHnfwsu5dF1qmKTq(WL(bUFP9lJstd1D8uUycPIHlxfJH7xeG6NPk7rv(QtfJuhEDsdPEdXt5splJOiGXHKdc4rQzlKpCbrci1(DuENaPwgLMgQ74PCXesfdljjRFbH(LrPPHIx2py(IjKkgIkUFP9tNEuC)I0VpXA)aS)WRtAWyQ4YftivOpXA)s7hW(fTFnoSPqpHPk4nUycPczlKpCPFbH(dVoG4lBC1W4(fPFWUFGrQdVoPHuxHE0btivefbmoCfiGhPMTq(WfejGu73r5DcKAzuAAO4L9dMVycPIHOI7xA)0Phf3Vi97tS2pa7p86KgmMkUCXesf6tS2V0(dVoG4lBC1W4(DPFIhsD41jnKApHPk4nUycPIOiGXTerapsnBH8HlisaP2VJY7ei1YO00WchLl7KHLKKHuhEDsdPMYCoxmHurueW42bc4rQdVoPHuh3k0TW7nPV(njHrQzlKpCbrcikcyC7gb8i1HxN0qQPpHtUCXesfPMTq(WfejGOiGXnyJaEKA2c5dxqKasD41jnKAmVIztVyDmYi1(DuENaPEz6LXec5dJu7D6p8vJLmRyeW4arraJBIhc4rQzlKpCbrci1(DuENaPMo9O4(fPFFI1(by)HxN0GXuXLlMqQqFI1(L2pG97Z8ussgCzCAHog5BSBscUCvmgUFr6xs9li0VO97tqSfMcP4CNW6hyK6WRtAi1vOhDWesfrraJBjHaEKA2c5dxqKasTFhL3jqQxuJPZLmdngJhJmPyDIV6gIfpg5BiwCSHIIHSfYhUGuhEDsdPwJ9QBigrraJBxfb8i1SfYhUGibKA)okVtGuVOgtNlzgAmgpgzsX6eF1nelEmY3qS4ydffdzlKpCbPo86Kgsn9Ymy5yKV6gIrueW4wYJaEKA2c5dxqKasTFhL3jqQLrPPH6IYycPcljjdPo86KgsTCq(M0xDhpfmIIag3soiGhPMTq(WfejGu73r5DcKACIEKhRafJIv0dF5fvSoPbzlKpCPFP9lJstd1fLXesfwssgsD41jnKA6dJj43GwrueW42vGaEK6WRtAi1yLJIZlMqQi1SfYhUGibefrrQlmDGEueWJaghiGhPo86KgsTprnL3lMqQi1SfYhUGibefbmUrapsnBH8HlisaPo86KgsTprnL3lMqQi1(DuENaPErnMoxYmeZIjGcwIVI30FIQqN0GSfYhU0VGq)4e9ipwbAJZaF1mp4R4CWPbzlKpCPFbH(bSFFAf0rHldIxCCUj9Loxf1yiBH8Hl9lTFr7FrnMoxYmeZIjGcwIVI30FIQqN0GSfYhU0pWi1NX4RVGud2serradyJaEKA2c5dxqKasD41jnKADdJ4hDody5yKVycPIuxySFhX6KgsnyXS)GahL(dR0p43Wi(rNZawY9dgj3aq)SXvdJbx)K4(lPrK2Fj7xjm4(PZTFXNWjV4(LzFGI5(hLOs)YC)AM9Jfhvvo7pSs)K4(9HrK2)Yrzoo7h8Bye)9JfZ(HE89lJstJHi1(DuENaPw0(1yjZkCWxXNWjVikcyiEiGhPMTq(WfejGu73r5DcKAFcITWuifN7ew)s73N5PKKmOUOmMqQWLRIXW9lTFFMNssYGlJtl0XiFJDtsWLRIXW9li0VO97tqSfMcP4CNW6xA)(mpLKKb1fLXesfUCvmggPo86KgsTpoNB41jT7zWks9zW61IkgPw3XOWkgrraJKqapsnBH8HlisaPo86KgsTpoNB41jT7zWks9zW61IkgP2xWikcyCveWJuZwiF4cIeqQ97O8obsD41beFzJRgg3Vl9d2i1yDhVIaghi1HxN0qQ9X5CdVoPDpdwrQpdwVwuXi1yfrraJKhb8i1SfYhUGibKA)okVtGuhEDaXx24QHX9ls)UrQX6oEfbmoqQdVoPHu7JZ5gEDs7EgSIuFgSETOIrQ1D8uWesfJOiksT4L9zLCOiGhbmoqapsD41jnKA5u1dxU0NWjxing5RMuDmKA2c5dxqKaIIag3iGhPo86Kgsn9HXe8BqRi1SfYhUGibefbmGnc4rQzlKpCbrci1(DuENaPErnMoxYmeNOh6CjZxUsMxmKTq(WfK6WRtAi1ASxDdXikcyiEiGhPMTq(WfejGulEzFG1RovmsTdjIuhEDsdPUKOYh(QHyKA)okVtGuhEDaXx24QHX9ls)o6xqOFr73NGylmfsX5oH1V0(fTFnoSPqq55WoHSfYhUGOiGrsiGhPMTq(WfejGu73r5DcK6WRdi(YgxnmUFx6hS7xA)a2VO97tqSfMcP4CNW6xA)I2Vgh2uiO8CyNq2c5dx6xqO)WRdi(YgxnmUFx63D)aJuhEDsdPoMkUCXesfrraJRIaEKA2c5dxqKasTFhL3jqQdVoG4lBC1W4(fPF39li0pG97tqSfMcP4CNW6xqOFnoSPqq55WoHSfYhU0pW9lT)WRdi(YgxnmUFG63nsD41jnKASYrX5ftivefrrQ9fmc4raJdeWJuZwiF4cIeqQ97O8obsnG9lJstd1fLXesfIkUFP9lJstdxgNwOJr(g7MKGOI7xA)(eeBHPqko3jS(bUFbH(bSFzuAAOUOmMqQquX9lTFzuAAiP5uUyXZokgIkUFP97tqSfMcTHmb9shC)a3VGq)a2VpbXwykeeBkbNB)cc97tqSfMcn2V5j3s)a3V0(LrPPH6IYycPcrf3VGq)Yjg3V0(PhYe07YvXy4(DPFhGD)cc9dy)(eeBHPqko3jS(L2VmknnCzCAHog5BSBscIkUFP9tpKjO3LRIXW97s)sEWUFGrQdVoPHulZlMxkJrgrraJBeWJuZwiF4cIeqQ97O8obsTmknnuxugtiviQ4(fe63N5PKKmOUOmMqQWLRIXW9ls)GTe7xqOF5eJ7xA)0dzc6D5QymC)U0VdxfPo86KgsT8jZYLgDDIOiGbSrapsnBH8HlisaP2VJY7ei1YO00qDrzmHuHOI7xqOFFMNssYG6IYycPcxUkgd3Vi9d2sSFbH(LtmUFP9tpKjO3LRIXW97s)oCvK6WRtAi1H5zSUX56JZbrradXdb8i1SfYhUGibKA)okVtGulJstd1fLXesfIkUFbH(9zEkjjdQlkJjKkC5QymC)I0pylX(fe6xoX4(L2p9qMGExUkgd3Vl97kqQdVoPHutpllFYSGOiGrsiGhPMTq(WfejGu73r5DcKAzuAAOUOmMqQWssYqQdVoPHuFgYeu8fSkOfYvSPikcyCveWJuZwiF4cIeqQ97O8obsTmknnuxugtiviQ4(L2pG9lJstdLpzwoOyfIkUFbH(1yjZkKahhLauSx73L(DlX(bUFbH(LtmUFP9tpKjO3LRIXW97s)UD1(fe6hW(9ji2ctHuCUty9lTFzuAA4Y40cDmY3y3KeevC)s7NEitqVlxfJH73L(L8U7hyK6WRtAi1ItDsdrruKASIaEeW4ab8i1SfYhUGibKA)okVtGuRXHnfIvokoV0PhfdzlKpCPFP9dy)Ixg0LSVaDaXkhfNxmHu7xA)YO00qSYrX5Lo9Oy4YvXy4(DPFj1VGq)YO00qSYrX5Lo9Oyyjjz9dC)s7hW(LrPPHlJtl0XiFJDtsWssY6xqOFr73NGylmfsX5oH1pWi1HxN0qQXkhfNxmHurueW4gb8i1HxN0qQPmNZftivKA2c5dxqKaIIagWgb8i1SfYhUGibKA)okVtGudy)(eeBHPqko3jS(L2pG97Z8ussgCzCAHog5BSBscUCvmgUFx6NSV0pW9li0VO97tqSfMcP4CNW6xA)I2VpbXwyk0gYe0lDW9li0VpbXwyk0gYe0lDW9lTFa73N5PKKmiP5uUyXZokgUCvmgUFx6NSV0VGq)(mpLKKbjnNYflE2rXWLRIXW9ls)GTe7h4(fe6NEitqVlxfJH73L(DiP(bUFP9dy)I2)gt5YGytHrPGHmvhSI7xqO)nMYLbXMcJsbdrf3V0(bS)nMYLbXMcJsbdhRFx63He7xA)BmLldInfgLcgUCvmgUFx6hS7xqO)nMYLbXMcJsbdhRFr6p86K21N5PKKS(fe6p86aIVSXvdJ7xK(D0pW9li0VO9VXuUmi2uyukyiQ4(L2pG9VXuUmi2uyukyOprnTFG63r)cc9VXuUmi2uyuky4y9ls)HxN0U(mpLKK1pW9dmsD41jnK6sIkF4RgIrueWq8qapsnBH8HlisaP2VJY7ei1ASxDdXquX9lT)f1y6CjZqCIEOZLmF5kzEXq2c5dxqQdVoPHutFILrueWijeWJuZwiF4cIeqQ97O8obs9IAmDUKziorp05sMVCLmVyiBH8Hl9lTFn2RUHy4YvXy4(DPFY(s)s73N5PKKmi9jwgUCvmgUFx6NSVGuhEDsdPwJ9QBigrraJRIaEK6WRtAi1mvfFs8aIVycPIuZwiF4cIequeWi5rapsnBH8HlisaP2VJY7ei1I2)gt5YGytHrPGHmvhSI7xqOFr7FJPCzqSPWOuWquX9lT)nMYLbXMcJsbdlOBOtA9dW(3ykxgeBkmkfmCS(DPF3sSFbH(3ykxgeBkmkfmevC)s7FJPCzqSPWOuWWLRIXW9ls)oCf9li0F41beFzJRgg3Vi97aPo86KgsnP5uUyXZokgrraJKdc4rQdVoPHutFcNC5IjKksnBH8HlisarraJRab8i1SfYhUGibKA)okVtGutNEuC)aSFFG17YKzRFx6No9OyyvqvK6WRtAi1foucxpHGYgvikcyCireWJuhEDsdPoUvOBH3BsF9BscJuZwiF4cIequeW4Wbc4rQzlKpCbrci1(DuENaP2N5PKKm4Y40cDmY3y3KeC5QymC)U0pzFPFP9dy)I2Vgh2uitvXNepG4lMqQq2c5dx6xqOFzuAAO8jZYbfRquX9dC)cc9lA)(eeBHPqko3jS(fe63N5PKKm4Y40cDmY3y3KeC5QymC)cc9lNyC)s7NEitqVlxfJH73L(LesD41jnKAsXCgJ8n2njHOiGXHBeWJuZwiF4cIeqQ97O8obsnG9lJstdljQ8HVAigIkUFbH(9zEkjjdwsu5dF1qmC5QymC)I0Vdj2VGq)I2Vgh2uyjrLp8vdXq2c5dx6xqOF6Hmb9UCvmgUFx63H7(bUFP9dy)I2)gt5YGytHrPGHmvhSI7xqOFr7FJPCzqSPWOuWquX9lTFa7FJPCzqSPWOuWWc6g6Kw)aS)nMYLbXMcJsbdhRFx63He7xqO)nMYLbXMcJsbd9jQP9du)o6h4(fe6FJPCzqSPWOuWquX9lT)nMYLbXMcJsbdxUkgd3Vi97k6xqO)WRdi(YgxnmUFr63r)aJuhEDsdPEzCAHog5BSBscrraJdWgb8i1SfYhUGibKA)okVtGulJstdxgNwOJr(g7MKGOI7xqOFFMNssYGlJtl0XiFJDtsWLRIXW9ls)oKy)cc9lA)(eeBHPqko3jS(L2pG9lJstdfVSFW8ftivmSKKS(fe6x0(14WMc9eMQG34IjKkKTq(WL(fe6p86aIVSXvdJ73L(D3pWi1HxN0qQbLNd7erraJdIhc4rQzlKpCbrci1(DuENaP2NGylmfsX5oH1V0(PtpkUFa2VpW6DzYS1Vl9tNEumSkOA)s7hW(bSFFMNssYGlJtl0XiFJDtsWLRIXW97s)K9L(j(0py3V0(bSFr7hNOh5XkqMMgfpG4BytvCdVNp8gAUq2c5dx6xqOFr7xJdBkSKOYh(QHyiBH8Hl9dC)a3VGq)ACytHLev(WxnedzlKpCPFP97Z8ussgSKOYh(QHy4YvXy4(DPFWUFGrQdVoPHuJvokoVycPIOiGXHKqapsnBH8HlisaP2VJY7ei1YO00qXl7hmFXesfdljjRFP9dy)(eeBHPqqSPeCU9li0VpbXwyk0y)MNCl9li0Vgh2uOpoNXiFvc8ftivmKTq(WL(bUFbH(LrPPHlJtl0XiFJDtsquX9li0VpZtjjzWLXPf6yKVXUjj4YvXy4(fPFhsSFbH(LrPPHKMt5Ifp7OyiQ4(fe6xgLMgckph2jevC)s7p86aIVSXvdJ7xK(D0VGq)Yjg3V0(PhYe07YvXy4(DPF3scPo86KgsTUOmMqQikcyC4QiGhPMTq(WfejGu73r5DcK6f1y6CjZqm6sEmYxmHuXq2c5dx6xA)ACytHyD5O6mgdzlKpCPFP9dy)(mpLKKbxgNwOJr(g7MKGlxfJH7xK(DiX(fe6x0(9ji2ctHuCUty9li0VO9RXHnfwsu5dF1qmKTq(WL(fe6hNOh5XkqMMgfpG4BytvCdVNp8gAUq2c5dx6hyK6WRtAi1BiEkx6zzefbmoK8iGhPMTq(WfejGuhEDsdPoMkUCXesfP2VJY7ei1YO00qXl7hmFXesfdljjRFbH(bSFzuAAOUOmMqQquX9li0pn65Cx2tiwY8vNkUFx6NSV0pa73hy9Qtf3pW9lTFa7x0(14WMc9eMQG34IjKkKTq(WL(fe6p86aIVSXvdJ73L(D3pW9li0Vmknnu3Xt5IjKkgUCvmgUFr6NPk7rv(Qtf3V0(dVoG4lBC1W4(fPFhi1EN(dF1yjZkgbmoqueW4qYbb8i1SfYhUGibKA)okVtGudy)(mpLKKbxgNwOJr(g7MKGlxfJH7xK(DiX(fe6x0(9ji2ctHuCUty9li0VO9RXHnfwsu5dF1qmKTq(WL(fe6hNOh5XkqMMgfpG4BytvCdVNp8gAUq2c5dx6h4(L2pD6rX9dW(9bwVltMT(DPF60JIHvbv7xA)a2VmknnSKOYh(QHyyjjz9lTFzuAAihKpSgN0WxDr5lD6rXWssY6xqOFnoSPqSUCuDgJHSfYhU0pWi1HxN0qQ3q8uU0ZYikcyC4kqapsnBH8HlisaP2VJY7ei1YO00qXl7hmFXesfdrf3VGq)0Phf3Vi97tS2pa7p86KgmMkUCXesf6tSIuhEDsdP2tyQcEJlMqQikcyClreWJuZwiF4cIeqQ97O8obsTmknnu8Y(bZxmHuXquX9li0pD6rX9ls)(eR9dW(dVoPbJPIlxmHuH(eRi1HxN0qQJ1hgFXesfrraJBhiGhPMTq(WfejGuhEDsdPgZRy20lwhJmsTFhL3jqQxMEzmHq(W9lTFnwYSc1PIVAEld3Vi9xq3qN0qQ9o9h(QXsMvmcyCGOiGXTBeWJuZwiF4cIeqQ97O8obsD41beFzJRgg3Vi97aPo86KgsTCSBqMrueW4gSrapsnBH8HlisaP2VJY7ei1a2VpZtjjzWLXPf6yKVXUjj4YvXy4(fPFhsSFP9VOgtNlzgIrxYJr(IjKkgYwiF4s)cc9lA)(eeBHPqko3jS(fe6x0(14WMcljQ8HVAigYwiF4s)cc9Jt0J8yfittJIhq8nSPkUH3ZhEdnxiBH8Hl9dC)s7No9O4(by)(aR3LjZw)U0pD6rXWQGQ9lTFa7xgLMgwsu5dF1qmSKKS(fe6xJdBkeRlhvNXyiBH8Hl9dmsD41jnK6nepLl9SmIIag3epeWJuZwiF4cIeqQ97O8obsTmknnuxugtivyjjzi1HxN0qQLdY3K(Q74PGrueW4wsiGhPMTq(WfejGu73r5DcKACIEKhRafJIv0dF5fvSoPbzlKpCPFP9lJstd1fLXesfwssgsD41jnKA6dJj43GwrueW42vrapsD41jnKASYrX5ftivKA2c5dxqKaIIOi16ogfwXiGhbmoqapsnBH8HlisaPofJuJzfPo86KgsnOyNq(Wi1GIdkJulJstdxgNwOJr(g7MKGOI7xqOFzuAAOUOmMqQquXi1GI9ArfJuJDA(lQyefbmUrapsnBH8HlisaPofJuJzfPo86KgsnOyNq(Wi1GIdkJu7tqSfMcP4CNW6xA)YO00WLXPf6yKVXUjjiQ4(L2VmknnuxugtiviQ4(fe6x0(9ji2ctHuCUty9lTFzuAAOUOmMqQquXi1GI9ArfJuJ1nnYxStZFrfJOiGbSrapsnBH8HlisaPofJuJzDOrQdVoPHudk2jKpmsnOyVwuXi1yDtJ8f7083LRIXWi1(DuENaPwgLMgQlkJjKkSKKS(L2VpbXwykKIZDcdPguCq5lFWmsTpZtjjzqDrzmHuHlxfJHrQbfhugP2N5PKKm4Y40cDmY3y3KeC5QymC)Ui5QFFMNssYG6IYycPcxUkgdJOiGH4HaEKA2c5dxqKasDkgPgZ6qJuhEDsdPguStiFyKAqXETOIrQX6Mg5l2P5VlxfJHrQ97O8obsTmknnuxugtiviQ4(L2VpbXwykKIZDcdPguCq5lFWmsTpZtjjzqDrzmHuHlxfJHrQbfhugP2N5PKKm4Y40cDmY3y3KeC5QymmIIagjHaEKA2c5dxqKasDkgPgZ6qJuhEDsdPguStiFyKAqXETOIrQXon)D5QymmsTFhL3jqQ9ji2ctHuCUtyi1GIdkF5dMrQ9zEkjjdQlkJjKkC5QymmsnO4GYi1(mpLKKbxgNwOJr(g7MKGlxfJH7xejx97Z8ussguxugtiv4YvXyyefbmUkc4rQzlKpCbrci1HxN0qQ1DmkS6aP2VJY7ei1a2VUJrHvO6asiWxumFLrPP7xqOFFcITWuifN7ew)s7x3XOWkuDaje4RpZtjjz9dC)s7hW(bf7eYhgI1nnYxStZFrf3V0(bSFr73NGylmfsX5oH1V0(fTFDhJcRq1nKqGVOy(kJst3VGq)(eeBHPqko3jS(L2VO9R7yuyfQUHec81N5PKKS(fe6x3XOWkuDd9zEkjjdUCvmgUFbH(1DmkScvhqcb(II5RmknD)s7hW(fTFDhJcRq1nKqGVOy(kJst3VGq)6ogfwHQdOpZtjjzWc6g6Kw)Iau)6ogfwHQBOpZtjjzWc6g6Kw)a3VGq)6ogfwHQdiHaF9zEkjjRFP9lA)6ogfwHQBiHaFrX8vgLMUFP9R7yuyfQoG(mpLKKblOBOtA9lcq9R7yuyfQUH(mpLKKblOBOtA9dC)cc9lA)GIDc5ddX6Mg5l2P5VOI7xA)a2VO9R7yuyfQUHec8ffZxzuA6(L2pG9R7yuyfQoG(mpLKKblOBOtA9tC9lP(DPFqXoH8HHyNM)UCvmgUFbH(bf7eYhgIDA(7YvXy4(fPFDhJcRq1b0N5PKKmybDdDsRFI1V7(bUFbH(1DmkScv3qcb(II5RmknD)s7hW(1DmkScvhqcb(II5RmknD)s7x3XOWkuDa9zEkjjdwq3qN06xeG6x3XOWkuDd9zEkjjdwq3qN06xA)a2VUJrHvO6a6Z8ussgSGUHoP1pX1VK63L(bf7eYhgIDA(7YvXy4(fe6huStiFyi2P5VlxfJH7xK(1DmkScvhqFMNssYGf0n0jT(jw)U7h4(fe6hW(fTFDhJcRq1bKqGVOy(kJst3VGq)6ogfwHQBOpZtjjzWc6g6Kw)Iau)6ogfwHQdOpZtjjzWc6g6Kw)a3V0(bSFDhJcRq1n0N5PKKm4YrXz)s7x3XOWkuDd9zEkjjdwq3qN06N46xs9ls)GIDc5ddXon)D5QymC)s7huStiFyi2P5VlxfJH73L(1DmkScv3qFMNssYGf0n0jT(jw)U7xqOFr7x3XOWkuDd9zEkjjdUCuC2V0(bSFDhJcRq1n0N5PKKm4YvXy4(jU(Lu)U0pOyNq(WqSUPr(IDA(7YvXy4(L2pOyNq(WqSUPr(IDA(7YvXy4(fPF3sSFP9dy)6ogfwHQdOpZtjjzWc6g6Kw)ex)sQFx6huStiFyi2P5VlxfJH7xqOFDhJcRq1n0N5PKKm4YvXy4(jU(Lu)U0pOyNq(WqStZFxUkgd3V0(1DmkScv3qFMNssYGf0n0jT(jU(DiX(by)GIDc5ddXon)D5QymC)U0pOyNq(WqSUPr(IDA(7YvXy4(fe6huStiFyi2P5VlxfJH7xK(1DmkScvhqFMNssYGf0n0jT(jw)U7xqOFqXoH8HHyNM)IkUFG7xqOFDhJcRq1n0N5PKKm4YvXy4(jU(Lu)I0pOyNq(WqSUPr(IDA(7YvXy4(L2pG9R7yuyfQoG(mpLKKblOBOtA9tC9lP(DPFqXoH8HHyDtJ8f7083LRIXW9li0VO9R7yuyfQoGec8ffZxzuA6(L2pG9dk2jKpme7083LRIXW9ls)6ogfwHQdOpZtjjzWc6g6Kw)eRF39li0pOyNq(WqStZFrf3pW9dC)a3pW9dC)a3VGq)Yjg3V0(PhYe07YvXy4(DPFqXoH8HHyNM)UCvmgUFG7xqOFr7x3XOWkuDaje4lkMVYO009lTFr73NGylmfsX5oH1V0(bSFDhJcRq1nKqGVOy(kJst3V0(bSFa7x0(bf7eYhgIDA(lQ4(fe6x3XOWkuDd9zEkjjdUCvmgUFr6xs9dC)s7hW(bf7eYhgIDA(7YvXy4(fPF3sSFbH(1DmkScv3qFMNssYGlxfJH7N46xs9ls)GIDc5ddXon)D5QymC)a3pW9li0VO9R7yuyfQUHec8ffZxzuA6(L2pG9lA)6ogfwHQBiHaF9zEkjjRFbH(1DmkScv3qFMNssYGlxfJH7xqOFDhJcRq1n0N5PKKmybDdDsRFraQFDhJcRq1b0N5PKKmybDdDsRFG7hyKA8jvmsTUJrHvhikcyK8iGhPMTq(WfejGuhEDsdPw3XOWQBKA)okVtGudy)6ogfwHQBiHaFrX8vgLMUFbH(9ji2ctHuCUty9lTFDhJcRq1nKqGV(mpLKK1pW9lTFa7huStiFyiw30iFXon)fvC)s7hW(fTFFcITWuifN7ew)s7x0(1DmkScvhqcb(II5RmknD)cc97tqSfMcP4CNW6xA)I2VUJrHvO6asiWxFMNssY6xqOFDhJcRq1b0N5PKKm4YvXy4(fe6x3XOWkuDdje4lkMVYO009lTFa7x0(1DmkScvhqcb(II5RmknD)cc9R7yuyfQUH(mpLKKblOBOtA9lcq9R7yuyfQoG(mpLKKblOBOtA9dC)cc9R7yuyfQUHec81N5PKKS(L2VO9R7yuyfQoGec8ffZxzuA6(L2VUJrHvO6g6Z8ussgSGUHoP1Via1VUJrHvO6a6Z8ussgSGUHoP1pW9li0VO9dk2jKpmeRBAKVyNM)IkUFP9dy)I2VUJrHvO6asiWxumFLrPP7xA)a2VUJrHvO6g6Z8ussgSGUHoP1pX1VK63L(bf7eYhgIDA(7YvXy4(fe6huStiFyi2P5VlxfJH7xK(1DmkScv3qFMNssYGf0n0jT(jw)U7h4(fe6x3XOWkuDaje4lkMVYO009lTFa7x3XOWkuDdje4lkMVYO009lTFDhJcRq1n0N5PKKmybDdDsRFraQFDhJcRq1b0N5PKKmybDdDsRFP9dy)6ogfwHQBOpZtjjzWc6g6Kw)ex)sQFx6huStiFyi2P5VlxfJH7xqOFqXoH8HHyNM)UCvmgUFr6x3XOWkuDd9zEkjjdwq3qN06Ny97UFG7xqOFa7x0(1DmkScv3qcb(II5RmknD)cc9R7yuyfQoG(mpLKKblOBOtA9lcq9R7yuyfQUH(mpLKKblOBOtA9dC)s7hW(1DmkScvhqFMNssYGlhfN9lTFDhJcRq1b0N5PKKmybDdDsRFIRFj1Vi9dk2jKpme7083LRIXW9lTFqXoH8HHyNM)UCvmgUFx6x3XOWkuDa9zEkjjdwq3qN06Ny97UFbH(fTFDhJcRq1b0N5PKKm4YrXz)s7hW(1DmkScvhqFMNssYGlxfJH7N46xs97s)GIDc5ddX6Mg5l2P5VlxfJH7xA)GIDc5ddX6Mg5l2P5VlxfJH7xK(DlX(L2pG9R7yuyfQUH(mpLKKblOBOtA9tC9lP(DPFqXoH8HHyNM)UCvmgUFbH(1DmkScvhqFMNssYGlxfJH7N46xs97s)GIDc5ddXon)D5QymC)s7x3XOWkuDa9zEkjjdwq3qN06N463He7hG9dk2jKpme7083LRIXW97s)GIDc5ddX6Mg5l2P5VlxfJH7xqOFqXoH8HHyNM)UCvmgUFr6x3XOWkuDd9zEkjjdwq3qN06Ny97UFbH(bf7eYhgIDA(lQ4(bUFbH(1DmkScvhqFMNssYGlxfJH7N46xs9ls)GIDc5ddX6Mg5l2P5VlxfJH7xA)a2VUJrHvO6g6Z8ussgSGUHoP1pX1VK63L(bf7eYhgI1nnYxStZFxUkgd3VGq)I2VUJrHvO6gsiWxumFLrPP7xA)a2pOyNq(WqStZFxUkgd3Vi9R7yuyfQUH(mpLKKblOBOtA9tS(D3VGq)GIDc5ddXon)fvC)a3pW9dC)a3pW9dC)cc9lNyC)s7NEitqVlxfJH73L(bf7eYhgIDA(7YvXy4(bUFbH(fTFDhJcRq1nKqGVOy(kJst3V0(fTFFcITWuifN7ew)s7hW(1DmkScvhqcb(II5RmknD)s7hW(bSFr7huStiFyi2P5VOI7xqOFDhJcRq1b0N5PKKm4YvXy4(fPFj1pW9lTFa7huStiFyi2P5VlxfJH7xK(DlX(fe6x3XOWkuDa9zEkjjdUCvmgUFIRFj1Vi9dk2jKpme7083LRIXW9dC)a3VGq)I2VUJrHvO6asiWxumFLrPP7xA)a2VO9R7yuyfQoGec81N5PKKS(fe6x3XOWkuDa9zEkjjdUCvmgUFbH(1DmkScvhqFMNssYGf0n0jT(fbO(1DmkScv3qFMNssYGf0n0jT(bUFGrQXNuXi16ogfwDJOikIIudIx8KgcyClr3oC4WbyJutkwBmYyKAIVUYsgGXvcmGfbW(7h8e4(NkX5Q9tNB)eP74PGjKkMO(xM4hDwU0poR4(dunRcLl97jegzgdBQD9yC)oaW(bG0aXRYL(jsJdBkKke1VM9tKgh2uivGSfYhUqu)a6GQadBQD9yC)UbW(bG0aXRYL(jArnMoxYmKke1VM9t0IAmDUKzivGSfYhUqu)a6GQadBQD9yC)Gna2paKgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKTq(WfI6p0(bRawW19dOdQcmSP21JX9ljaSFainq8QCPFIwuJPZLmdPcr9Rz)eTOgtNlzgsfiBH8Hle1pGoOkWWMAxpg3VRcG9daPbIxLl9t0IAmDUKziviQFn7NOf1y6CjZqQazlKpCHO(dTFWkGfCD)a6GQadBQD9yC)UcaSFainq8QCPFI04WMcPcr9Rz)ePXHnfsfiBH8Hle1pGoOkWWMAxpg3VdjcG9daPbIxLl9tKgh2uiviQFn7NinoSPqQazlKpCHO(b0bvbg2u76X4(Dq8aW(bG0aXRYL(jsJdBkKke1VM9tKgh2uivGSfYhUqu)a6GQadBQD9yC)oiEay)aqAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2c5dxiQFaDqvGHn1UEmUFhsEaSFainq8QCPFI04WMcPcr9Rz)ePXHnfsfiBH8Hle1pGoOkWWMAxpg3Vdjpa2paKgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKTq(WfI6hq3ufyytTRhJ73HKda2paKgiEvU0prACytHuHO(1SFI04WMcPcKTq(WfI6hqhufyytTRhJ73TKaW(bG0aXRYL(jArnMoxYmKke1VM9t0IAmDUKzivGSfYhUqu)H2pyfWcUUFaDqvGHn1UEmUF3Uka2paKgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKTq(WfI6p0(bRawW19dOdQcmSP21JX97wYba7hasdeVkx6NiCIEKhRaPcr9Rz)eHt0J8yfivGSfYhUqu)a6GQadBQBQj(6klzagxjWawea7VFWtG7FQeNR2pDU9tuHPd0Jsu)lt8Jolx6hNvC)bQMvHYL(9ecJmJHn1UEmUF3ay)aqAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2c5dxiQFaDqvGHn1UEmUF3ay)aqAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2c5dxiQFaDqvGHn1UEmUF3ay)aqAG4v5s)e5tRGokKke1VM9tKpTc6OqQazlKpCHO(b0bvbg2u76X4(DdG9daPbIxLl9teorpYJvGuHO(1SFIWj6rEScKkq2c5dxiQFaDqvGHn1n1eFDLLmaJReyalcG93p4jW9pvIZv7No3(js8Y(SsouI6FzIF0z5s)4SI7pq1SkuU0VNqyKzmSP21JX9d2ay)aqAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2c5dxiQ)q7hScybx3pGoOkWWMAxpg3pXda7hasdeVkx6NinoSPqQqu)A2prACytHubYwiF4cr9hA)Gval46(b0bvbg2u76X4(Lea2paKgiEvU0prACytHuHO(1SFI04WMcPcKTq(WfI6hqhufyytTRhJ73vbW(bG0aXRYL(jsJdBkKke1VM9tKgh2uivGSfYhUqu)a6GQadBQBQj(6klzagxjWawea7VFWtG7FQeNR2pDU9tewjQ)Lj(rNLl9JZkU)avZQq5s)EcHrMXWMAxpg3VdaSFainq8QCPFI04WMcPcr9Rz)ePXHnfsfiBH8Hle1pGoOkWWMAxpg3pXda7hasdeVkx6NOf1y6CjZqQqu)A2prlQX05sMHubYwiF4cr9hA)Gval46(b0bvbg2u76X4(Lea2paKgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKTq(WfI6hqhufyytTRhJ73HdaSFainq8QCPFI04WMcPcr9Rz)ePXHnfsfiBH8Hle1pGoOkWWMAxpg3Vd3ay)aqAG4v5s)ePXHnfsfI6xZ(jsJdBkKkq2c5dxiQFaDqvGHn1UEmUFhGna2paKgiEvU0prACytHuHO(1SFI04WMcPcKTq(WfI6hqhufyytTRhJ73bXda7hasdeVkx6NinoSPqQqu)A2prACytHubYwiF4cr9dOBQcmSP21JX97G4bG9daPbIxLl9teorpYJvGuHO(1SFIWj6rEScKkq2c5dxiQFaDqvGHn1UEmUFhsca7hasdeVkx6NinoSPqQqu)A2prACytHubYwiF4cr9dOdQcmSP21JX97WvbW(bG0aXRYL(jsJdBkKke1VM9tKgh2uivGSfYhUqu)a6MQadBQD9yC)oCvaSFainq8QCPFIwuJPZLmdPcr9Rz)eTOgtNlzgsfiBH8Hle1pGoOkWWMAxpg3Vdxfa7hasdeVkx6NiCIEKhRaPcr9Rz)eHt0J8yfivGSfYhUqu)a6GQadBQD9yC)oK8ay)aqAG4v5s)ePXHnfsfI6xZ(jsJdBkKkq2c5dxiQFaDqvGHn1UEmUFhsoay)aqAG4v5s)ePXHnfsfI6xZ(jsJdBkKkq2c5dxiQFaDtvGHn1UEmUFhsoay)aqAG4v5s)eHt0J8yfiviQFn7NiCIEKhRaPcKTq(WfI6hqhufyytTRhJ73nydG9daPbIxLl9tKgh2uiviQFn7NinoSPqQazlKpCHO(b0nvbg2u76X4(Dd2ay)aqAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2c5dxiQFaDqvGHn1UEmUF3Gna2paKgiEvU0pr4e9ipwbsfI6xZ(jcNOh5XkqQazlKpCHO(b0bvbg2u76X4(DljaSFainq8QCPFIWj6rEScKke1VM9teorpYJvGubYwiF4cr9dOdQcmSPg8e4(PZZjjng5(d0nW9tIxUFumx6FS(vcC)HxN06)myTFzuTFs8Y9BP2pDIAL(hRFLa3FukP1Fj0qoWma2u3pX1phKpSgN0WxDr5lD6rXn1n1eFDLLmaJReyalcG93p4jW9pvIZv7No3(js3XOWkMO(xM4hDwU0poR4(dunRcLl97jegzgdBQD9yC)Uka2paKgiEvU0F9uba9JDAAq1(bR7xZ(DnA0Fzan4jT(tX8gAU9diXaUFaLevbg2u76X4(DvaSFainq8QCPFI0DmkScDaPcr9Rz)eP7yuyfQoGuHO(b0TdQcmSP21JX97Qay)aqAG4v5s)eP7yuyf6gsfI6xZ(js3XOWkuDdPcr9dOBxLQadBQD9yC)sEaSFainq8QCP)6Pca6h700GQ9dw3VM97A0O)YaAWtA9NI5n0C7hqIbC)akjQcmSP21JX9l5bW(bG0aXRYL(js3XOWk0bKke1VM9tKUJrHvO6asfI6hq3Ukvbg2u76X4(L8ay)aqAG4v5s)eP7yuyf6gsfI6xZ(js3XOWkuDdPcr9dOBhufyytDtTRuL4CvU0VR2F41jT(pdwXWMAKAXBsphgPwYkz7hS6yPGRcdtye3VK5OMYBtTKvY2pysqCLmV97aSbx)ULOBhn1n1swjB)aaHWiZyaSPwYkz7N46hmmj6e1k9lzW48aI7FW9BP2F0Ff7je247xjW9hLsA97dJyKMZP)QWcYmSPwYkz7N46xYGXonpx6pkL06x8o5oQZ(jnkH(RNkaOFxzj3Ug2ulzLS9tC97Aw7xYmN7egU)cJDA((vc8S9dasMW9JZkwNkgdBQBQdVoPHHIx2NvYHcqGiMCQ6Hlx6t4KlKgJ8vtQowtD41jnmu8Y(SsouaceXOpmMGFdATPo86KggkEzFwjhkabIyASxDdXGBObArnMoxYmeNOh6CjZxUsMxCtD41jnmu8Y(SsouaceXkjQ8HVAigCIx2hy9QtfdKdjcUHgOWRdi(YgxnmwehccI6tqSfMcP4CNWKkQgh2uiO8CyNn1HxN0WqXl7Zk5qbiqelMkUCXesfCdnqHxhq8LnUAySlGTuaf1NGylmfsX5oHjvunoSPqq55WofecVoG4lBC1WyxCdCtD41jnmu8Y(SsouaceXWkhfNxmHub3qdu41beFzJRgglIBbba9ji2ctHuCUtyccACytHGYZHDcS0WRdi(Ygxnmgi3n1n1HxN0WaeiI5tut59IjKAtD41jnmabIy(e1uEVycPcUZy81xacSLi4gAGwuJPZLmdXSycOGL4R4n9NOk0jnbbCIEKhRaTXzGVAMh8vCo40eea0NwbDu4YG4fhNBsFPZvrnwQOlQX05sMHywmbuWs8v8M(tuf6KgWn1s2(blM9he4O0FyL(b)ggXp6CgWsUFWi5ga6NnUAymyv7Ne3FjnI0(lz)kHb3pDU9l(eo5f3Vm7dum3)Oev6xM7xZSFS4OQYz)Hv6Ne3VpmI0(xokZXz)GFdJ4VFSy2p0JVFzuAAmSPo86KggGarmDdJ4hDody5yKVycPcUHgir1yjZkCWxXNWjVn1HxN0WaeiI5JZ5gEDs7EgScolQyG0DmkSIb3qdKpbXwykKIZDctQpZtjjzqDrzmHuHlxfJHL6Z8ussgCzCAHog5BSBscUCvmgwqquFcITWuifN7eMuFMNssYG6IYycPcxUkgd3ulzLS9lzIpHZ(Pd)yK73zIU9xsuzTFutNt)ot0(jeG4(fJQ9lzW40cDmY97kVBsQ)ssYax)52)q3VsG73N5PKKS(hC)AM9FsJC)A2FHpHZ(Pd)yK73zIU9lzkrLvy)Us09BPX9N09Reym3VpTYOtA4(JL7pKpC)A2FfR9tAucJ1VsG73He7hZ(0k4(pmtkCcU(vcC)4PQF6WZ4(DMOB)sMsuzT)avZQqhFCooHn1swjB)HxN0WaeiIzmj6e1k3LX5bedUHgiCIEKhRanMeDIAL7Y48aILcOmknnCzCAHog5BSBscIkwqWN5PKKm4Y40cDmY3y3KeC5QymSioKOGa9qMGExUkgd7Idxf4M6WRtAyaceX8X5CdVoPDpdwbNfvmq(cUPo86KggGarmFCo3WRtA3ZGvWzrfdewbhw3XRa5aCdnqHxhq8LnUAySlGDtD41jnmabIy(4CUHxN0UNbRGZIkgiDhpfmHuXGdR74vGCaUHgOWRdi(Ygxnmwe3n1n1HxN0WqFbdKmVyEPmgzWn0abOmknnuxugtiviQyPYO00WLXPf6yKVXUjjiQyP(eeBHPqko3jmGfeaugLMgQlkJjKkevSuzuAAiP5uUyXZokgIkwQpbXwyk0gYe0lDWaliaOpbXwykeeBkbNRGGpbXwyk0y)MNClalvgLMgQlkJjKkevSGGCIXsPhYe07YvXyyxCa2cca6tqSfMcP4CNWKkJstdxgNwOJr(g7MKGOILspKjO3LRIXWUi5bBGBQdVoPHH(cgGarm5tMLln66eCdnqYO00qDrzmHuHOIfe8zEkjjdQlkJjKkC5QymSiGTefeKtmwk9qMGExUkgd7IdxTPo86Kgg6lyaceXcZZyDJZ1hNd4gAGKrPPH6IYycPcrfli4Z8ussguxugtiv4YvXyyraBjkiiNySu6Hmb9UCvmg2fhUAtD41jnm0xWaeiIrpllFYSaUHgizuAAOUOmMqQquXcc(mpLKKb1fLXesfUCvmgweWwIccYjglLEitqVlxfJHDXv0uhEDsdd9fmabIyNHmbfFbRcAHCfBk4gAGKrPPH6IYycPcljjRPo86Kgg6lyaceXeN6Kg4gAGKrPPH6IYycPcrflfqzuAAO8jZYbfRquXccASKzfsGJJsak2RU4wIaliiNySu6Hmb9UCvmg2f3UQGaG(eeBHPqko3jmPYO00WLXPf6yKVXUjjiQyP0dzc6D5QymSlsE3a3u3uhEDsddXkqyLJIZlMqQGBObsJdBkeRCuCEPtpkwkGIxg0LSVaDaXkhfNxmHuLkJstdXkhfNx60JIHlxfJHDrsccYO00qSYrX5Lo9OyyjjzalfqzuAA4Y40cDmY3y3KeSKKmbbr9ji2ctHuCUtya3uhEDsddXkabIyuMZ5IjKAtD41jnmeRaeiIvsu5dF1qm4gAGa0NGylmfsX5oHjfqFMNssYGlJtl0XiFJDtsWLRIXWUq2xawqquFcITWuifN7eMur9ji2ctH2qMGEPdwqWNGylmfAdzc6LoyPa6Z8ussgK0CkxS4zhfdxUkgd7czFrqWN5PKKmiP5uUyXZokgUCvmgweWwIaliqpKjO3LRIXWU4qsalfqr3ykxgeBkmkfmKP6GvSGWgt5YGytHrPGHOILc4gt5YGytHrPGHJ5IdjkDJPCzqSPWOuWWLRIXWUa2ccBmLldInfgLcgoMi(mpLKKjieEDaXx24QHXI4aybbr3ykxgeBkmkfmevSua3ykxgeBkmkfm0NOMcKdbHnMYLbXMcJsbdhteFMNssYag4M6WRtAyiwbiqeJ(eldUHgin2RUHyiQyPlQX05sMH4e9qNlz(YvY8IBQdVoPHHyfGarmn2RUHyWn0aTOgtNlzgIt0dDUK5lxjZlwQg7v3qmC5QymSlK9fP(mpLKKbPpXYWLRIXWUq2xAQdVoPHHyfGarmMQIpjEaXxmHuBQdVoPHHyfGarmsZPCXINDum4gAGeDJPCzqSPWOuWqMQdwXccIUXuUmi2uyukyiQyPBmLldInfgLcgwq3qN0a4gt5YGytHrPGHJ5IBjkiSXuUmi2uyukyiQyPBmLldInfgLcgUCvmgwehUcbHWRdi(Ygxnmwehn1HxN0WqScqGig9jCYLlMqQn1HxN0WqScqGiwHdLW1tiOSrf4gAGOtpkgG(aR3LjZMl0PhfdRcQ2uhEDsddXkabIyXTcDl8Et6RFts4M6WRtAyiwbiqeJumNXiFJDtsGBObYN5PKKm4Y40cDmY3y3KeC5QymSlK9fPakQgh2uitvXNepG4lMqQccYO00q5tMLdkwHOIbwqquFcITWuifN7eMGGpZtjjzWLXPf6yKVXUjj4YvXyybb5eJLspKjO3LRIXWUiPM6WRtAyiwbiqeBzCAHog5BSBscCdnqakJstdljQ8HVAigIkwqWN5PKKmyjrLp8vdXWLRIXWI4qIccIQXHnfwsu5dF1qSGa9qMGExUkgd7Id3alfqr3ykxgeBkmkfmKP6GvSGGOBmLldInfgLcgIkwkGBmLldInfgLcgwq3qN0a4gt5YGytHrPGHJ5IdjkiSXuUmi2uyukyOprnfihaliSXuUmi2uyukyiQyPBmLldInfgLcgUCvmgwexHGq41beFzJRgglIdGBQdVoPHHyfGarmq55Wob3qdKmknnCzCAHog5BSBscIkwqWN5PKKm4Y40cDmY3y3KeC5QymSioKOGGO(eeBHPqko3jmPakJstdfVSFW8ftivmSKKmbbr14WMc9eMQG34IjKQGq41beFzJRgg7IBGBQdVoPHHyfGarmSYrX5ftivWn0a5tqSfMcP4CNWKsNEuma9bwVltMnxOtpkgwfuvkGa6Z8ussgCzCAHog5BSBscUCvmg2fY(cXhWwkGIIt0J8yfittJIhq8nSPkUH3ZhEdnxbbr14WMcljQ8HVAigyGfe04WMcljQ8HVAiwQpZtjjzWsIkF4RgIHlxfJHDbSbUPo86KggIvaceX0fLXesfCdnqYO00qXl7hmFXesfdljjtkG(eeBHPqqSPeCUcc(eeBHPqJ9BEYTiiOXHnf6JZzmYxLaFXesfdSGGmknnCzCAHog5BSBscIkwqWN5PKKm4Y40cDmY3y3KeC5QymSioKOGGmknnK0CkxS4zhfdrfliiJstdbLNd7eIkwA41beFzJRgglIdbb5eJLspKjO3LRIXWU4wsn1HxN0WqScqGi2gINYLEwgCdnqlQX05sMHy0L8yKVycPILQXHnfI1LJQZySua9zEkjjdUmoTqhJ8n2njbxUkgdlIdjkiiQpbXwykKIZDctqqunoSPWsIkF4RgIfeWj6rEScKPPrXdi(g2uf3W75dVHMlWn1HxN0WqScqGiwmvC5IjKk48o9h(QXsMvmqoa3qdKmknnu8Y(bZxmHuXWssYeeaugLMgQlkJjKkevSGan65Cx2tiwY8vNk2fY(ca9bwV6uXalfqr14WMc9eMQG34IjKQGq41beFzJRgg7IBGfeKrPPH6oEkxmHuXWLRIXWIWuL9OkF1PILgEDaXx24QHXI4OPo86KggIvaceX2q8uU0ZYGBObcqFMNssYGlJtl0XiFJDtsWLRIXWI4qIccI6tqSfMcP4CNWeeevJdBkSKOYh(QHybbCIEKhRazAAu8aIVHnvXn8E(WBO5cSu60JIbOpW6DzYS5cD6rXWQGQsbugLMgwsu5dF1qmSKKmPYO00qoiFynoPHV6IYx60JIHLKKjiOXHnfI1LJQZymWn1HxN0WqScqGiMNWuf8gxmHub3qdKmknnu8Y(bZxmHuXquXcc0PhflIpXkadVoPbJPIlxmHuH(eRn1HxN0WqScqGiwS(W4lMqQGBObsgLMgkEz)G5lMqQyiQybb60JIfXNyfGHxN0GXuXLlMqQqFI1M6WRtAyiwbiqedZRy20lwhJm48o9h(QXsMvmqoa3qd0Y0lJjeYhwQglzwH6uXxnVLHfPGUHoP1uhEDsddXkabIyYXUbzgCdnqHxhq8LnUAySioAQdVoPHHyfGarSnepLl9Sm4gAGa0N5PKKm4Y40cDmY3y3KeC5QymSioKO0f1y6CjZqm6sEmYxmHuXccI6tqSfMcP4CNWeeevJdBkSKOYh(QHybbCIEKhRazAAu8aIVHnvXn8E(WBO5cSu60JIbOpW6DzYS5cD6rXWQGQsbugLMgwsu5dF1qmSKKmbbnoSPqSUCuDgJbUPo86KggIvaceXKdY3K(Q74PGb3qdKmknnuxugtivyjjzn1HxN0WqScqGig9HXe8BqRGBObcNOh5XkqXOyf9WxErfRtAsLrPPH6IYycPcljjRPo86KggIvaceXWkhfNxmHuBQBQdVoPHH6oEkycPIbcRCuCEXesfCdnqACytHyLJIZlD6rXsh7sFgYeuPYO00qSYrX5Lo9Oy4YvXyyxKutD41jnmu3XtbtivmabIyuMZ5IjKk4gAGwuJPZLmdfNOEc3K(UbyzUx6nixXMILkJstdPpHtEX3QyParf3uhEDsdd1D8uWesfdqGig9jCYLlMqQGBObArnMoxYmuCI6jCt67gGL5EP3GCfBkUPo86KggQ74PGjKkgGarSsIkF4RgIb3qdeG(eeBHPqko3jmP(mpLKKbxgNwOJr(g7MKGlxfJHDHSViiiQpbXwykKIZDctQO(eeBHPqBitqV0bli4tqSfMcTHmb9shSua9zEkjjdsAoLlw8SJIHlxfJHDHSVii4Z8ussgK0CkxS4zhfdxUkgdlcylrGfe0yjZkuNk(Q5TmSloKOGGpZtjjzWLXPf6yKVXUjj4YvXyyrCirPHxhq8LnUAySiGnWsbu0nMYLbXMcJsbdzQoyfliSXuUmi2uyuky4YvXyyrCfccI6tqSfMcP4CNWaUPo86KggQ74PGjKkgGarmn2RUHyWn0aTOgtNlzgIt0dDUK5lxjZlwQg7v3qmC5QymSlK9fP(mpLKKbPpXYWLRIXWUq2xAQdVoPHH6oEkycPIbiqeJ(eldUZy81xaYTKa3qdKg7v3qmevS0f1y6CjZqCIEOZLmF5kzEXn1HxN0WqDhpfmHuXaeiIXuv8jXdi(IjKAtD41jnmu3XtbtivmabIyKMt5Ifp7OyWn0aj6gt5YGytHrPGHmvhSIfe2ykxgeBkmkfmC5QymSioKOGq41beFzJRgglcqBmLldInfgLcg6tutj(4UPo86KggQ74PGjKkgGarmsXCgJ8n2njbUHgiFMNssYGlJtl0XiFJDtsWLRIXWUq2xKcOOACytHmvfFs8aIVycPkiiJstdLpzwoOyfIkgybbr9ji2ctHuCUtycc(mpLKKbxgNwOJr(g7MKGlxfJHfXHefeKtmwk9qMGExUkgd7IKAQdVoPHH6oEkycPIbiqeBzCAHog5BSBscCdnqa6Z8ussgeuEoSt4YvXyyxi7lccIQXHnfckph2PGGglzwH6uXxnVLHDXHBGLcOOBmLldInfgLcgYuDWkwqyJPCzqSPWOuWWLRIXWI4keecVoG4lBC1WyraAJPCzqSPWOuWqFIAkXh3a3uhEDsdd1D8uWesfdqGigO8CyNGBObsgLMgUmoTqhJ8n2njbrfli4Z8ussgCzCAHog5BSBscUCvmgwehsuqquFcITWuifN7ewtD41jnmu3XtbtivmabIyYXUbzUPo86KggQ74PGjKkgGarmDrzmHub3qdKmknnCzCAHog5BSBscIkwqWN5PKKm4Y40cDmY3y3KeC5QymSioKOGGO(eeBHPqko3jmbb5eJLspKjO3LRIXWU4wIn1HxN0WqDhpfmHuXaeiITH4PCPNLb3qd0IAmDUKzigDjpg5lMqQyPa6Z8ussgCzCAHog5BSBscUCvmgwehsuqquFcITWuifN7eMGGOACytHLev(WxnedSuzuAAOUJNYftivmC5QymSiaXuL9OkF1PIBQdVoPHH6oEkycPIbiqelMkUCXesfCEN(dF1yjZkgihGBObsgLMgQ74PCXesfdxUkgdlcqmvzpQYxDQyPakJstdfVSFW8ftivmSKKmbbA0Z5USNqSK5RovSl(aRxDQyas2xeeKrPPH6IYycPcrfdCtD41jnmu3XtbtivmabIyfoucxpHGYgvGBObIo9Oya6dSExMmBUqNEumSkOAtD41jnmu3XtbtivmabIyBiEkx6zzWn0abOpZtjjzWLXPf6yKVXUjj4YvXyyrCirPlQX05sMHy0L8yKVycPIfee1NGylmfsX5oHjii6IAmDUKzigDjpg5lMqQybbr14WMcljQ8HVAigyPYO00qDhpLlMqQy4YvXyyraIPk7rv(Qtf3uhEDsdd1D8uWesfdqGiwf6rhmHub3qdKmknnu3Xt5IjKkgwssMGGmknnu8Y(bZxmHuXquXsPtpkweFIvagEDsdgtfxUycPc9jwLcOOACytHEctvWBCXesvqi86aIVSXvdJfbSbUPo86KggQ74PGjKkgGarmpHPk4nUycPcUHgizuAAO4L9dMVycPIHOILsNEuSi(eRam86KgmMkUCXesf6tSkn86aIVSXvdJDH41uhEDsdd1D8uWesfdqGigL5CUycPcUHgizuAAyHJYLDYWssYAQdVoPHH6oEkycPIbiqelUvOBH3BsF9Bsc3uhEDsdd1D8uWesfdqGig9jCYLlMqQn1HxN0WqDhpfmHuXaeiIH5vmB6fRJrgCEN(dF1yjZkgihGBObAz6LXec5d3uhEDsdd1D8uWesfdqGiwf6rhmHub3qdeD6rXI4tScWWRtAWyQ4YftivOpXQua9zEkjjdUmoTqhJ8n2njbxUkgdlIKeee1NGylmfsX5oHbCtD41jnmu3XtbtivmabIyASxDdXGBObArnMoxYm0ymEmYKI1j(QBiw8yKVHyXXgkkUPo86KggQ74PGjKkgGarm6LzWYXiF1nedUHgOf1y6CjZqJX4XitkwN4RUHyXJr(gIfhBOO4M6WRtAyOUJNcMqQyaceXKdY3K(Q74PGb3qdKmknnuxugtivyjjzn1HxN0WqDhpfmHuXaeiIrFymb)g0k4gAGWj6rEScumkwrp8LxuX6KMuzuAAOUOmMqQWssYAQdVoPHH6oEkycPIbiqedRCuCEXesTPUPo86KggQ7yuyfdeOyNq(WGZIkgiStZFrfdoqXbLbsgLMgUmoTqhJ8n2njbrfliiJstd1fLXesfIkUPo86KggQ7yuyfdqGigOyNq(WGZIkgiSUPr(IDA(lQyWbkoOmq(eeBHPqko3jmPYO00WLXPf6yKVXUjjiQyPYO00qDrzmHuHOIfee1NGylmfsX5oHjvgLMgQlkJjKkevCtD41jnmu3XOWkgGarmqXoH8HbNfvmqyDtJ8f7083LRIXWGlfdeM1HgCGIdkdKpZtjjzWLXPf6yKVXUjj4YvXyyxKC5Z8ussguxugtiv4YvXyyWbkoO8LpygiFMNssYG6IYycPcxUkgddUHgizuAAOUOmMqQWssYK6tqSfMcP4CNWAQdVoPHH6ogfwXaeiIbk2jKpm4SOIbcRBAKVyNM)UCvmggCPyGWSo0GduCqzG8zEkjjdUmoTqhJ8n2njbxUkgddoqXbLV8bZa5Z8ussguxugtiv4YvXyyWn0ajJstd1fLXesfIkwQpbXwykKIZDcRPo86KggQ7yuyfdqGigOyNq(WGZIkgiStZFxUkgddUumqywhAWn0a5tqSfMcP4CNWahO4GYa5Z8ussgCzCAHog5BSBscUCvmgwejx(mpLKKb1fLXesfUCvmggCGIdkF5dMbYN5PKKmOUOmMqQWLRIXWn1HxN0WqDhJcRyaceXqX8DuUcdo8jvmq6ogfwDaUHgia1DmkScDaje4lkMVYO00cc(eeBHPqko3jmP6ogfwHoGec81N5PKKmGLciOyNq(WqSUPr(IDA(lQyPakQpbXwykKIZDctQO6ogfwHUHec8ffZxzuAAbbFcITWuifN7eMur1DmkScDdje4RpZtjjzcc6ogfwHUH(mpLKKbxUkgdliO7yuyf6asiWxumFLrPPLcOO6ogfwHUHec8ffZxzuAAbbDhJcRqhqFMNssYGf0n0jnras3XOWk0n0N5PKKmybDdDsdybbDhJcRqhqcb(6Z8ussMur1DmkScDdje4lkMVYO00s1DmkScDa9zEkjjdwq3qN0ebiDhJcRq3qFMNssYGf0n0jnGfeefuStiFyiw30iFXon)fvSuafv3XOWk0nKqGVOy(kJstlfqDhJcRqhqFMNssYGf0n0jnItsUak2jKpme7083LRIXWccGIDc5ddXon)D5QymSi6ogfwHoG(mpLKKblOBOtAG1Ubwqq3XOWk0nKqGVOy(kJstlfqDhJcRqhqcb(II5RmknTuDhJcRqhqFMNssYGf0n0jnras3XOWk0n0N5PKKmybDdDstkG6ogfwHoG(mpLKKblOBOtAeNKCbuStiFyi2P5VlxfJHfeaf7eYhgIDA(7YvXyyr0DmkScDa9zEkjjdwq3qN0aRDdSGaGIQ7yuyf6asiWxumFLrPPfe0DmkScDd9zEkjjdwq3qN0ebiDhJcRqhqFMNssYGf0n0jnGLcOUJrHvOBOpZtjjzWLJItP6ogfwHUH(mpLKKblOBOtAeNKebuStiFyi2P5VlxfJHLck2jKpme7083LRIXWUO7yuyf6g6Z8ussgSGUHoPbw7wqquDhJcRq3qFMNssYGlhfNsbu3XOWk0n0N5PKKm4YvXyyItsUak2jKpmeRBAKVyNM)UCvmgwkOyNq(WqSUPr(IDA(7YvXyyrClrPaQ7yuyf6a6Z8ussgSGUHoPrCsYfqXoH8HHyNM)UCvmgwqq3XOWk0n0N5PKKm4YvXyyItsUak2jKpme7083LRIXWs1DmkScDd9zEkjjdwq3qN0iohseGGIDc5ddXon)D5QymSlGIDc5ddX6Mg5l2P5VlxfJHfeaf7eYhgIDA(7YvXyyr0DmkScDa9zEkjjdwq3qN0aRDliak2jKpme708xuXaliO7yuyf6g6Z8ussgC5QymmXjjraf7eYhgI1nnYxStZFxUkgdlfqDhJcRqhqFMNssYGf0n0jnItsUak2jKpmeRBAKVyNM)UCvmgwqquDhJcRqhqcb(II5RmknTuabf7eYhgIDA(7YvXyyr0DmkScDa9zEkjjdwq3qN0aRDliak2jKpme708xuXadmWadmWccYjglLEitqVlxfJHDbuStiFyi2P5VlxfJHbwqquDhJcRqhqcb(II5RmknTur9ji2ctHuCUtysbu3XOWk0nKqGVOy(kJstlfqaffuStiFyi2P5VOIfe0DmkScDd9zEkjjdUCvmgwejbSuabf7eYhgIDA(7YvXyyrClrbbDhJcRq3qFMNssYGlxfJHjojjcOyNq(WqStZFxUkgddmWccIQ7yuyf6gsiWxumFLrPPLcOO6ogfwHUHec81N5PKKmbbDhJcRq3qFMNssYGlxfJHfe0DmkScDd9zEkjjdwq3qN0ebiDhJcRqhqFMNssYGf0n0jnGbUPo86KggQ7yuyfdqGigkMVJYvyWHpPIbs3XOWQBWn0abOUJrHvOBiHaFrX8vgLMwqWNGylmfsX5oHjv3XOWk0nKqGV(mpLKKbSuabf7eYhgI1nnYxStZFrflfqr9ji2ctHuCUtysfv3XOWk0bKqGVOy(kJstli4tqSfMcP4CNWKkQUJrHvOdiHaF9zEkjjtqq3XOWk0b0N5PKKm4YvXyybbDhJcRq3qcb(II5RmknTuafv3XOWk0bKqGVOy(kJstliO7yuyf6g6Z8ussgSGUHoPjcq6ogfwHoG(mpLKKblOBOtAaliO7yuyf6gsiWxFMNssYKkQUJrHvOdiHaFrX8vgLMwQUJrHvOBOpZtjjzWc6g6KMiaP7yuyf6a6Z8ussgSGUHoPbSGGOGIDc5ddX6Mg5l2P5VOILcOO6ogfwHoGec8ffZxzuAAPaQ7yuyf6g6Z8ussgSGUHoPrCsYfqXoH8HHyNM)UCvmgwqauStiFyi2P5VlxfJHfr3XOWk0n0N5PKKmybDdDsdS2nWcc6ogfwHoGec8ffZxzuAAPaQ7yuyf6gsiWxumFLrPPLQ7yuyf6g6Z8ussgSGUHoPjcq6ogfwHoG(mpLKKblOBOtAsbu3XOWk0n0N5PKKmybDdDsJ4KKlGIDc5ddXon)D5QymSGaOyNq(WqStZFxUkgdlIUJrHvOBOpZtjjzWc6g6KgyTBGfeauuDhJcRq3qcb(II5RmknTGGUJrHvOdOpZtjjzWc6g6KMiaP7yuyf6g6Z8ussgSGUHoPbSua1DmkScDa9zEkjjdUCuCkv3XOWk0b0N5PKKmybDdDsJ4KKiGIDc5ddXon)D5QymSuqXoH8HHyNM)UCvmg2fDhJcRqhqFMNssYGf0n0jnWA3ccIQ7yuyf6a6Z8ussgC5O4ukG6ogfwHoG(mpLKKbxUkgdtCsYfqXoH8HHyDtJ8f7083LRIXWsbf7eYhgI1nnYxStZFxUkgdlIBjkfqDhJcRq3qFMNssYGf0n0jnItsUak2jKpme7083LRIXWcc6ogfwHoG(mpLKKbxUkgdtCsYfqXoH8HHyNM)UCvmgwQUJrHvOdOpZtjjzWc6g6KgX5qIaeuStiFyi2P5VlxfJHDbuStiFyiw30iFXon)D5QymSGaOyNq(WqStZFxUkgdlIUJrHvOBOpZtjjzWc6g6KgyTBbbqXoH8HHyNM)IkgybbDhJcRqhqFMNssYGlxfJHjojjcOyNq(WqSUPr(IDA(7YvXyyPaQ7yuyf6g6Z8ussgSGUHoPrCsYfqXoH8HHyDtJ8f7083LRIXWccIQ7yuyf6gsiWxumFLrPPLciOyNq(WqStZFxUkgdlIUJrHvOBOpZtjjzWc6g6KgyTBbbqXoH8HHyNM)IkgyGbgyGbwqqoXyP0dzc6D5QymSlGIDc5ddXon)D5QymmWccIQ7yuyf6gsiWxumFLrPPLkQpbXwykKIZDctkG6ogfwHoGec8ffZxzuAAPacOOGIDc5ddXon)fvSGGUJrHvOdOpZtjjzWLRIXWIijGLciOyNq(WqStZFxUkgdlIBjkiO7yuyf6a6Z8ussgC5QymmXjjraf7eYhgIDA(7YvXyyGbwqquDhJcRqhqcb(II5RmknTuafv3XOWk0bKqGV(mpLKKjiO7yuyf6a6Z8ussgC5QymSGGUJrHvOdOpZtjjzWc6g6KMiaP7yuyf6g6Z8ussgSGUHoPbmWi1yXShbmULeXdrrueea]] )


end