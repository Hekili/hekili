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


    spec:RegisterPack( "Marksmanship", 20210629, [[d8u5acqisupcbrDjeeAtKQ(ecmkqvNcuzvufjELKOzPs4wij1UG8lvQAyQe5yuLwMK0ZqqAAufHRHGABufLVHKKghvruNdjjADQuP3rvKQAEsc3tL0(Ok8pQIK6GiiOfIKYdvPIjIGaDrQIiBKQiv(ivrfJKQiv5KufPSssKzQsu3ebbStvk9tQIknuQIK0srqepLQAQQu8veePXIKyVQ4VQQbdCyHftspMktwvUmQnJuFgrnAq50kwnvrs8AeA2sCBj1UP8BrdNeoovrvlxPNd10jUoiBhj(oImEKuDEsL1JKeMpPSFP(49CZX)fcFUT6LQ69sEwvQsKxQ6LOQvRE8fDk4JVIWrmiZhFlQ5JpHaXsexhgg2O44Ri0vY4DU54JtO1XhFc5gatef47E)9KhbgKkYL13JNAOsitAUnOL7XtT7(JVk0uepn7OE8FHWNBREPQEVKNvLQe5LQEjQQxQ6XpGey5E89N67C8HnVhBh1J)JXUJpHaXsexhgg2OObE6bzcVTskbzCdQsvErdQEPQEp(Lbl4ZnhFzhhrmSuWNBo369CZXNTqTWVd1o(UDeEN44lrHnbHfoE6(0PdcJylul8Rb6BWyF6YqgM0a9nqfIMgHfoE6(0PdcJwUogd3GkAaHp(HtM0o(yHJNUpgwkh5CB1ZnhF2c1c)ou7472r4DIJVlPWwycIOUDcRb6BGlZYljzOLXPfYyK)XUjj0Y1Xy4gurdi7EnqtRbk3axsHTWeerD7ewd03aLBGlPWwycYgYWKpDWnqtRbUKcBHjiBidt(0b3a9na(g4YS8ssgI0uEFSIzhbJwUogd3GkAaz3RbAAnWLz5LKmePP8(yfZocgTCDmgUbE0ac9snaUgOP1ajwYSGKPM)s(Fd3GkAG3l1anTg4YS8ssgAzCAHmg5FSBscTCDmgUbE0aVxQb6Bq4KHc)zJRhg3apAaHE8dNmPD8FjKAH)sO4iNBj0ZnhF2c1c)ou7472r4DIJ)czmDUKzeoHk05sM)CTkVyeBHAHFnqFdKy)YgkqlxhJHBqfnGS71a9nWLz5LKmeDjwgTCDmgUbv0aYU3XpCYK2XxI9lBO4iNB9eNBo(SfQf(DO2XpCYK2XNUelF8D7i8oXXxI9lBOabPOb6BWczmDUKzeoHk05sM)CTkVyeBHAHFh)Yy839o(vj8ro3s4Znh)WjtAhFM6kkjEOWFmSuo(SfQf(DO2ro36zNBo(HtM0o(KMY7Jvm7i4JpBHAHFhQDKZTu1ZnhF2c1c)ou7472r4DIJVlZYljzOLXPfYyK)XUjj0Y1Xy4gurdi7EnqFdGVbk3ajkSjiM6kkjEOWFmSuqSfQf(1anTgOcrtJulz(kqybbPObW1anTgOCdCjf2ctqe1TtynqtRbUmlVKKHwgNwiJr(h7MKqlxhJHBGhnW7LAGMwdutmUb6Ba9qgM8xUogd3GkAaHp(HtM0o(KIPmg5FSBs6iNB9Kp3C8zlul87qTJVBhH3jo(Qq00OxcPw4VekqqkAGMwduUbsuytqVesTWFjuGylul8RbAAnqnX4gOVb0dzyYF56ymCdQObERE8dNmPD8xgNwiJr(h7MKoY5wQYZnhF2c1c)ou7472r4DIJVkennAzCAHmg5FSBscbPObAAnq5g4skSfMGiQBNWo(HtM0o(uYsH1DKZTEV05MJF4KjTJVASBqMp(SfQf(DO2ro36175MJF4KjTJVSqmgwkhF2c1c)ou7iNB9w9CZXNTqTWVd1o(UDeEN44VqgtNlzgHHwYJr(JHLcgXwOw4xd03a4BGlZYljzOLXPfYyK)XUjj0Y1Xy4g4rd8EPgOP1aLBGlPWwycIOUDcRbAAnq5girHnb9si1c)LqbITqTWVgaxd03aviAAKSJJ4hdlfmA56ymCd84AdyQZoiH)YuZh)WjtAh)numVp9S8ro36Lqp3C8zlul87qTJF4KjTJFm187JHLYX3TJW7ehFviAAKSJJ4hdlfmA56ymCd84AdyQZoiH)YuZnqFdGVbQq00ifl7gm)XWsbJEjjRbAAnGgQu(l7Gflz(ltn3GkAGlWYxMAUbv2aYUxd00AGkennswigdlfeKIga3X3PZv4VelzwWNB9EKZTE9eNBo(SfQf(DO2X3TJW7ehF60bHBqLnWfy5Vmz2AqfnGoDqyuDq9JF4KjTJ)Jdb23bliUr9ro36LWNBo(SfQf(DO2X3TJW7ehF4BGlZYljzOxcPw4VekqlxhJHBGhnGS71apLgq4gOVblKX05sMryOL8yK)yyPGrSfQf(1anTgOCdCjf2ctqe1TtynqtRbk3ajkSjOxcPw4VekqSfQf(1a4AG(gqNoiCdQSbUal)LjZwdQOb0PdcJQdQ3a9na(gOcrtJEjKAH)sOa9sswd00AGef2eewwoQlJXi2c1c)AaCh)WjtAh)numVp9S8ro361Zo3C8zlul87qTJVBhH3jo(Qq00izhhXpgwky0ljznqtRbQq00ifl7gm)XWsbJGu0a9nGoDq4g4rdCjwAqLniCYKgkMA(9XWsb5sS0a9na(gOCdKOWMGCWM6G34JHLcITqTWVgOP1GWjdf(ZgxpmUbE0acTbWD8dNmPD8RHkYGHLYro36LQEU54ZwOw43HAhF3ocVtC8vHOPrkw2ny(JHLcgbPOb6BaD6GWnWJg4sS0GkBq4Kjnum187JHLcYLyPb6Bq4KHc)zJRhg3GkAGN44hozs747Gn1bVXhdlLJCU1RN85MJpBHAHFhQD8D7i8oXXxfIMg9449zDm6LKSJF4KjTJpXPu(yyPCKZTEPkp3C8dNmPD8JFn0(49N0F3MKWhF2c1c)ou7iNBREPZnh)WjtAhF6sOJFFmSuo(SfQf(DO2ro3w175MJpBHAHFhQD8dNmPD8X8QGn5JLXiF8D7i8oXXFz6LXWc1cF8D6Cf(lXsMf85wVh5CB1QNBo(SfQf(DO2X3TJW7ehF60bHBGhnWLyPbv2GWjtAOyQ53hdlfKlXsd03a4BGlZYljzOLXPfYyK)XUjj0Y1Xy4g4rdiCd00AGYnWLuylmbru3oH1anTgqNoiCdQSbUal)LjZwd8Ob0PdcJQdQ3a4o(HtM0o(1qfzWWs5iNBRsONBo(SfQf(DO2X3TJW7eh)fYy6CjZiJX4XitkwD4VSHcfJr(hkueBiqyeBHAHFh)WjtAhFj2VSHIJCUTQN4CZXNTqTWVd1o(UDeEN44VqgtNlzgzmgpgzsXQd)LnuOymY)qHIydbcJylul874hozs74tVmtvmg5VSHIJCUTkHp3C8zlul87qTJVBhH3jo(Qq00izHymSuqVKKD8dNmPD8vdY)K(l74iIpY52QE25MJF4KjTJpw44P7JHLYXNTqTWVd1oYro(pMoGkY5MZTEp3C8dNmPD8DjKj8(XWs54ZwOw43HAh5CB1ZnhF2c1c)ou74hozs747sit49JHLYX3TJW7eh)fYy6CjZimRagevb(RytxjQdzsdXwOw4xd00AaoHkQJ9q2OlWFjZc(RihCAi2c1c)AGMwdGVbU0EqJGwMcV4O8t6pDUcKXi2c1c)AG(gOCdwiJPZLmJWScyquf4VInDLOoKjneBHAHFnaUJFzm(7EhFc9sh5ClHEU54ZwOw43HAh)WjtAhFzdZZdnLHQymYFmSuo(pg72rHmPD89CYgeW441GWEn4Mnmpp0ugQcUb36P6DAaBC9W4lAajUbV0iqAWlBGaBWnGo3gOOe64f3av2fqyUbJqWRbQCdKmBawruxRRbH9AajUbUWiqAWYXBk6AWnByE(gGvWUHECnqfIMgJo(UDeEN44RCdKyjZcAWFfLqhVh5CRN4CZXNTqTWVd1o(UDeEN447skSfMGiQBNWAG(g4YS8ssgswigdlf0Y1Xy4gOVbUmlVKKHwgNwiJr(h7MKqlxhJHBGMwduUbUKcBHjiI62jSgOVbUmlVKKHKfIXWsbTCDmg(4hozs747Is5hozs7xgSC8ldw(wuZhFzhJil4JCULWNBo(SfQf(DO2XpCYK2X3fLYpCYK2Vmy54xgS8TOMp(Uh(iNB9SZnhF2c1c)ou7472r4DIJF4KHc)zJRhg3GkAaHE8dNmPD8DrP8dNmP9ldwo(LblFlQ5JpwoY5wQ65MJpBHAHFhQD8D7i8oXXpCYqH)SX1dJBGhnO6XpCYK2X3fLYpCYK2Vmy54xgS8TOMp(YooIyyPGpYro(kw2L1QHCU5CR3Znh)WjtAhF1uKc)(0Lqh)ing5VKuFSJpBHAHFhQDKZTvp3C8zlul87qTJVBhH3jo(4eQOo2dPaclqf(ZlKczsdXwOw43XpCYK2XNUWyyUnOLJCULqp3C8zlul87qTJVBhH3jo(lKX05sMr4eQqNlz(Z1Q8IrSfQf(D8dNmPD8Ly)YgkoY5wpX5MJpBHAHFhQD8vSSlWYxMA(479sh)WjtAh)xcPw4Veko(UDeEN44hozOWF246HXnWJg4TbAAnq5g4skSfMGiQBNWAG(gOCdKOWMGOKLcRdXwOw43ro3s4ZnhF2c1c)ou74Nko(ywo(HtM0o(uIDc1cF8Pefi(4xyYS9IvhIdYfwIsA4VSq8NoDqyeBHAHFnqFdWSiJrgJ4GCHLOK2htkuGylul874)ySBhfYK2X)oWcJm3ajBG3gizdWtnujeUbEs34P7EFFpDnGmhlMuOOb3SqmgwknqXYUalOJpLy)wuZhFwO)kw2fy5iNB9SZnhF2c1c)ou74RyzxGLVm18XV6X3TJW7ehFkXoHAHrSq)vSSlWYXxXYUalFwO)SNhAuC89E8dNmPD8LfIXWs54RyzxGLpgt)3WiE8PQh5Clv9CZXNTqTWVd1o(UDeEN44hozOWF246HXnOIgqOnqFdGVbk3axsHTWeerD7ewd03aLBGef2eeLSuyDi2c1c)AGMwdcNmu4pBC9W4gurdQ2a4AG(gOCdOe7eQfgXc9xXYUalh)WjtAh)yQ53hdlLJCU1t(CZXNTqTWVd1o(UDeEN44hozOWF246HXnWJguTbAAna(g4skSfMGiQBNWAGMwdKOWMGOKLcRdXwOw4xdGRb6Bq4KHc)zJRhg3GRnOAd00AaLyNqTWiwO)kw2fy54hozs74JfoE6(yyPCKJC8Dp85MZTEp3C8zlul87qTJVBhH3jo(Qq00izHymSuqqkAGMwdOhYWK)Y1Xy4gurd8sOh)WjtAhFvEX8sCmYh5CB1ZnhF2c1c)ou7472r4DIJVkennswigdlfeKIgOP1axMLxsYqYcXyyPGwUogd3apAaHEPgOP1a1eJBG(gqpKHj)LRJXWnOIg41Zo(HtM0o(QLmFFAOv3ro3sONBo(SfQf(DO2X3TJW7ehFviAAKSqmgwkiifnqtRbUmlVKKHKfIXWsbTCDmgUbE0ac9snqtRbQjg3a9nGEidt(lxhJHBqfnWRND8dNmPD8dZXyzJY3fLYro36jo3C8zlul87qTJVBhH3jo(Qq00izHymSuqqkAGMwdCzwEjjdjleJHLcA56ymCd8Obe6LAGMwdutmUb6Ba9qgM8xUogd3GkAav5XpCYK2XNEwwTK57iNBj85MJpBHAHFhQD8D7i8oXXxfIMgjleJHLc6LKSJF4KjTJFzidtWFpvGEKRztoY5wp7CZXNTqTWVd1o(UDeEN44RcrtJKfIXWsbbPOb6Ba8nqfIMgPwY8vGWccsrd00AGelzwqW4OiWqkCsdQObvVudGRbAAnqnX4gOVb0dzyYF56ymCdQObv9SJF4KjTJVIuM0oYro(y5CZ5wVNBo(SfQf(DO2X3TJW7ehFjkSjiSWXt3NoDqyeBHAHFnqFdGVbkwMYNS7H8IWchpDFmSuAG(gOcrtJWchpDF60bHrlxhJHBqfnGWnqtRbQq00iSWXt3NoDqy0ljznaUgOVbW3aviAA0Y40czmY)y3Ke6LKSgOP1aLBGlPWwycIOUDcRbWD8dNmPD8XchpDFmSuoY52QNBo(HtM0o(eNs5JHLYXNTqTWVd1oY5wc9CZXNTqTWVd1o(UDeEN447skSfMGiQBNWAG(gaFdCzwEjjdTmoTqgJ8p2njHwUogd3GkAaz3RbW1anTgOCdCjf2ctqe1TtynqFduUbUKcBHjiBidt(0b3anTg4skSfMGSHmm5thCd03a4BGlZYljzist59XkMDemA56ymCdQObKDVgOP1axMLxsYqKMY7Jvm7iy0Y1Xy4g4rdi0l1a4AGMwdKyjZcsMA(l5)nCdQObEj8XpCYK2X)LqQf(lHIJCU1tCU54ZwOw43HAh)WjtAhF6sS8X3TJW7ehFj2VSHceKIgOVblKX05sMr4eQqNlz(Z1Q8IrSfQf(D8lJXF374xLWh5ClHp3C8zlul87qTJVBhH3jo(lKX05sMr4eQqNlz(Z1Q8IrSfQf(1a9nqI9lBOaTCDmgUbv0aYUxd03axMLxsYq0Lyz0Y1Xy4gurdi7Eh)WjtAhFj2VSHIJCU1Zo3C8dNmPD8zQROK4Hc)XWs54ZwOw43HAh5Clv9CZXpCYK2XN0uEFSIzhbF8zlul87qTJCU1t(CZXpCYK2XNUe643hdlLJpBHAHFhQDKZTuLNBo(SfQf(DO2X3TJW7ehF60bHBqLnWfy5Vmz2AqfnGoDqyuDq9JF4KjTJ)Jdb23bliUr9ro369sNBo(HtM0o(XVgAF8(t6VBts4JpBHAHFhQDKZTE9EU54ZwOw43HAhF3ocVtC8DzwEjjdTmoTqgJ8p2njHwUogd3GkAaz3Rb6Ba8nq5girHnbXuxrjXdf(JHLcITqTWVgOP1aviAAKAjZxbcliifnaUgOP1aLBGlPWwycIOUDcRbAAnWLz5LKm0Y40czmY)y3KeA56ymCd00AGAIXnqFdOhYWK)Y1Xy4gurdi8XpCYK2XNumLXi)JDtsh5CR3QNBo(SfQf(DO2X3TJW7ehFviAA0lHul8xcfiifnqtRbk3ajkSjOxcPw4VekqSfQf(1anTgOMyCd03a6Hmm5VCDmgUbv0aVvp(HtM0o(lJtlKXi)JDtsh5CRxc9CZXNTqTWVd1o(UDeEN44RcrtJwgNwiJr(h7MKqqkAGMwduUbUKcBHjiI62jSgOVbW3aviAAKILDdM)yyPGrVKK1anTgOCdKOWMGCWM6G34JHLcITqTWVgOP1GWjdf(ZgxpmUbv0GQnaUJF4KjTJpLSuyDh5CRxpX5MJpBHAHFhQD8D7i8oXX3Luylmbru3oH1a9nGoDq4guzdCbw(ltMTgurdOthegvhuVb6Ba8na(g4YS8ssgAzCAHmg5FSBscTCDmgUbv0aYUxd8uAaH2a9na(gOCdWjurDShIPPHWdf(h2uh)W54cVHKlITqTWVgOP1aLBGef2e0lHul8xcfi2c1c)AaCnaUgOP1ajkSjOxcPw4VekqSfQf(1a9nWLz5LKm0lHul8xcfOLRJXWnOIgqOnaUJF4KjTJpw44P7JHLYro36LWNBo(SfQf(DO2X3TJW7ehFviAAKILDdM)yyPGrVKK1a9na(g4skSfMGOWMat32anTg4skSfMGm2Tzj3xd00AGef2eKlkLXi)fy8hdlfmITqTWVgaxd00AGkennAzCAHmg5FSBscbPObAAnqfIMgrAkVpwXSJGrqkAGMwduHOPruYsH1HGu0a9niCYqH)SX1dJBGhnWBd00AGAIXnqFdOhYWK)Y1Xy4gurdQs4JF4KjTJVSqmgwkh5CRxp7CZXNTqTWVd1o(UDeEN44RcrtJuSSBW8hdlfmcsrd00AaD6GWnWJg4sS0GkBq4Kjnum187JHLcYLy54hozs74VHI59PNLpY5wVu1ZnhF2c1c)ou74hozs74htn)(yyPC8D7i8oXXxfIMgPyz3G5pgwky0ljznqtRbW3aviAAKSqmgwkiifnqtRb0qLYFzhSyjZFzQ5gurdi7EnOYg4cS8LPMBaCnqFdGVbk3ajkSjihSPo4n(yyPGylul8RbAAniCYqH)SX1dJBqfnOAdGRbAAnqfIMgj74i(XWsbJwUogd3apAatD2bj8xMAUb6Bq4KHc)zJRhg3apAG3JVtNRWFjwYSGp369iNB96jFU54ZwOw43HAhF3ocVtC8HVbUmlVKKHEjKAH)sOaTCDmgUbE0aYUxd8uAaHBGMwduUbUKcBHjiI62jSgOP1aLBGef2e0lHul8xcfi2c1c)AaCnqFdOtheUbv2axGL)YKzRbv0a60bHr1b1BG(gaFduHOPrYcXyyPGEjjRbAAnq5guyYS9IvhIdYfwIsA4VSq8NoDqyeBHAHFnaUgOVbW3aviAA0lHul8xcfOxsYAGMwdKOWMGWYYrDzmgXwOw4xdG74hozs74VHI59PNLpY5wVuLNBo(SfQf(DO2X3TJW7ehFviAAKILDdM)yyPGrqkAGMwdOtheUbE0axILguzdcNmPHIPMFFmSuqUelh)WjtAhFhSPo4n(yyPCKZTvV05MJpBHAHFhQD8D7i8oXXxfIMgPyz3G5pgwkyeKIgOP1a60bHBGhnWLyPbv2GWjtAOyQ53hdlfKlXYXpCYK2Xpwxy8hdlLJCUTQ3ZnhF2c1c)ou74hozs74J5vbBYhlJr(472r4DIJ)Y0lJHfQfUb6BGelzwqYuZFj)VHBGhn4bTHmPD8D6Cf(lXsMf85wVh5CB1QNBo(SfQf(DO2X3TJW7eh)Wjdf(ZgxpmUbE0aVh)WjtAhF1y3GmFKZTvj0ZnhF2c1c)ou7472r4DIJp8nWLz5LKm0lHul8xcfOLRJXWnWJgq29AGNsdiCd03GfYy6CjZim0sEmYFmSuWi2c1c)AGMwduUbUKcBHjiI62jSgOP1aLBGef2e0lHul8xcfi2c1c)AaCnqFdOtheUbv2axGL)YKzRbv0a60bHr1b1BG(gaFduHOPrVesTWFjuGEjjRbAAnqIcBccllh1LXyeBHAHFnaUJF4KjTJ)gkM3NEw(iNBR6jo3C8zlul87qTJVBhH3jo(Qq00izHymSuqVKKD8dNmPD8vdY)K(l74iIpY52Qe(CZXNTqTWVd1o(UDeEN44JtOI6ypKciSav4pVqkKjneBHAHFnqFduHOPrYcXyyPGEjj74hozs74txymm3g0Yro3w1Zo3C8dNmPD8XchpDFmSuo(SfQf(DO2roYXx2XiYc(CZ5wVNBo(SfQf(DO2XpvC8XSC8dNmPD8Pe7eQf(4tjkq8XxfIMgTmoTqgJ8p2njHGu0anTgOcrtJKfIXWsbbP44tj2Vf18XhRZCFifh5CB1ZnhF2c1c)ou74Nko(ywo(HtM0o(uIDc1cF8Pefi(47skSfMGiQBNWAG(gOcrtJwgNwiJr(h7MKqqkAG(gOcrtJKfIXWsbbPObAAnq5g4skSfMGiQBNWAG(gOcrtJKfIXWsbbP44tj2Vf18XhlBAK)yDM7dP4iNBj0ZnhF2c1c)ou74Nko(ywg6JF4KjTJpLyNqTWhFkX(TOMp(yztJ8hRZC)LRJXWhF3ocVtC8vHOPrYcXyyPGEjj74tjkq8Nly(47YS8ssgswigdlf0Y1Xy4JpLOaXhFxMLxsYqlJtlKXi)JDtsOLRJXWnOcp1nWLz5LKmKSqmgwkOLRJXWh5CRN4CZXNTqTWVd1o(PIJpMLH(4hozs74tj2jul8XNsSFlQ5Jpw20i)X6m3F56ym8X3TJW7ehFviAAKSqmgwkiifhFkrbI)CbZhFxMLxsYqYcXyyPGwUogdF8Pefi(47YS8ssgAzCAHmg5FSBscTCDmg(iNBj85MJpBHAHFhQD8tfhFmld9XpCYK2XNsStOw4JpLy)wuZhFSoZ9xUogdF8D7i8oXX3Luylmbru3oHD8Pefi(ZfmF8DzwEjjdjleJHLcA56ym8XNsuG4JVlZYljzOLXPfYyK)XUjj0Y1Xy4g4HN6g4YS8ssgswigdlf0Y1Xy4JCU1Zo3C8zlul87qTJF4KjTJpeM)JW14JVBhH3jo(W3azhJiliXlcwG)qy(Rcrt3anTg4skSfMGiQBNWAG(gi7yezbjErWc83Lz5LKSgaxd03a4BaLyNqTWiSSPr(J1zUpKIgOVbW3aLBGlPWwycIOUDcRb6BGYnq2XiYcsQIGf4peM)Qq00nqtRbUKcBHjiI62jSgOVbk3azhJiliPkcwG)UmlVKK1anTgi7yezbjvrUmlVKKHwUogd3anTgi7yezbjErWc8hcZFviA6gOVbW3aLBGSJrKfKufblWFim)vHOPBGMwdKDmISGeVixMLxsYqpOnKjTg4X1gi7yezbjvrUmlVKKHEqBitAnaUgOP1azhJiliXlcwG)UmlVKK1a9nq5gi7yezbjvrWc8hcZFviA6gOVbYogrwqIxKlZYljzOh0gYKwd84AdKDmISGKQixMLxsYqpOnKjTgaxd00AGYnGsStOwyew20i)X6m3hsrd03a4BGYnq2XiYcsQIGf4peM)Qq00nqFdGVbYogrwqIxKlZYljzOh0gYKwdO6gq4gurdOe7eQfgH1zU)Y1Xy4gOP1akXoHAHryDM7VCDmgUbE0azhJiliXlYLz5LKm0dAdzsRb33GQnaUgOP1azhJiliPkcwG)qy(Rcrt3a9na(gi7yezbjErWc8hcZFviA6gOVbYogrwqIxKlZYljzOh0gYKwd84AdKDmISGKQixMLxsYqpOnKjTgOVbW3azhJiliXlYLz5LKm0dAdzsRbuDdiCdQObuIDc1cJW6m3F56ymCd00AaLyNqTWiSoZ9xUogd3apAGSJrKfK4f5YS8ssg6bTHmP1G7Bq1gaxd00Aa8nq5gi7yezbjErWc8hcZFviA6gOP1azhJiliPkYLz5LKm0dAdzsRbECTbYogrwqIxKlZYljzOh0gYKwdGRb6Ba8nq2XiYcsQICzwEjjdTC801a9nq2XiYcsQICzwEjjd9G2qM0Aav3ac3apAaLyNqTWiSoZ9xUogd3a9nGsStOwyewN5(lxhJHBqfnq2XiYcsQICzwEjjd9G2qM0AW9nOAd00AGYnq2XiYcsQICzwEjjdTC801a9na(gi7yezbjvrUmlVKKHwUogd3aQUbeUbv0akXoHAHryztJ8hRZC)LRJXWnqFdOe7eQfgHLnnYFSoZ9xUogd3apAq1l1a9na(gi7yezbjErUmlVKKHEqBitAnGQBaHBqfnGsStOwyewN5(lxhJHBGMwdKDmISGKQixMLxsYqlxhJHBav3ac3GkAaLyNqTWiSoZ9xUogd3a9nq2XiYcsQICzwEjjd9G2qM0Aav3aVxQbv2akXoHAHryDM7VCDmgUbv0akXoHAHryztJ8hRZC)LRJXWnqtRbuIDc1cJW6m3F56ymCd8ObYogrwqIxKlZYljzOh0gYKwdUVbvBGMwdOe7eQfgH1zUpKIgaxd00AGSJrKfKuf5YS8ssgA56ymCdO6gq4g4rdOe7eQfgHLnnYFSoZ9xUogd3a9na(gi7yezbjErUmlVKKHEqBitAnGQBaHBqfnGsStOwyew20i)X6m3F56ymCd00AGYnq2XiYcs8IGf4peM)Qq00nqFdGVbuIDc1cJW6m3F56ymCd8ObYogrwqIxKlZYljzOh0gYKwdUVbvBGMwdOe7eQfgH1zUpKIgaxdGRbW1a4AaCnaUgOP1ajwYSGKPM)s(Fd3GkAaLyNqTWiSoZ9xUogd3a4AGMwduUbYogrwqIxeSa)HW8xfIMUb6BGYnWLuylmbru3oH1a9na(gi7yezbjvrWc8hcZFviA6gOVbW3a4BGYnGsStOwyewN5(qkAGMwdKDmISGKQixMLxsYqlxhJHBGhnGWnaUgOVbW3akXoHAHryDM7VCDmgUbE0GQxQbAAnq2XiYcsQICzwEjjdTCDmgUbuDdiCd8ObuIDc1cJW6m3F56ymCdGRbW1anTgOCdKDmISGKQiyb(dH5VkenDd03a4BGYnq2XiYcsQIGf4VlZYljznqtRbYogrwqsvKlZYljzOLRJXWnqtRbYogrwqsvKlZYljzOh0gYKwd84AdKDmISGeVixMLxsYqpOnKjTgaxdG74JlPGp(Yogrw8EKZTu1ZnhF2c1c)ou74hozs74dH5)iCn(472r4DIJp8nq2XiYcsQIGf4peM)Qq00nqtRbUKcBHjiI62jSgOVbYogrwqsveSa)DzwEjjRbW1a9na(gqj2julmclBAK)yDM7dPOb6Ba8nq5g4skSfMGiQBNWAG(gOCdKDmISGeViyb(dH5VkenDd00AGlPWwycIOUDcRb6BGYnq2XiYcs8IGf4VlZYljznqtRbYogrwqIxKlZYljzOLRJXWnqtRbYogrwqsveSa)HW8xfIMUb6Ba8nq5gi7yezbjErWc8hcZFviA6gOP1azhJiliPkYLz5LKm0dAdzsRbECTbYogrwqIxKlZYljzOh0gYKwdGRbAAnq2XiYcsQIGf4VlZYljznqFduUbYogrwqIxeSa)HW8xfIMUb6BGSJrKfKuf5YS8ssg6bTHmP1apU2azhJiliXlYLz5LKm0dAdzsRbW1anTgOCdOe7eQfgHLnnYFSoZ9Hu0a9na(gOCdKDmISGeViyb(dH5VkenDd03a4BGSJrKfKuf5YS8ssg6bTHmP1aQUbeUbv0akXoHAHryDM7VCDmgUbAAnGsStOwyewN5(lxhJHBGhnq2XiYcsQICzwEjjd9G2qM0AW9nOAdGRbAAnq2XiYcs8IGf4peM)Qq00nqFdGVbYogrwqsveSa)HW8xfIMUb6BGSJrKfKuf5YS8ssg6bTHmP1apU2azhJiliXlYLz5LKm0dAdzsRb6Ba8nq2XiYcsQICzwEjjd9G2qM0Aav3ac3GkAaLyNqTWiSoZ9xUogd3anTgqj2julmcRZC)LRJXWnWJgi7yezbjvrUmlVKKHEqBitAn4(guTbW1anTgaFduUbYogrwqsveSa)HW8xfIMUbAAnq2XiYcs8ICzwEjjd9G2qM0AGhxBGSJrKfKuf5YS8ssg6bTHmP1a4AG(gaFdKDmISGeVixMLxsYqlhpDnqFdKDmISGeVixMLxsYqpOnKjTgq1nGWnWJgqj2julmcRZC)LRJXWnqFdOe7eQfgH1zU)Y1Xy4gurdKDmISGeVixMLxsYqpOnKjTgCFdQ2anTgOCdKDmISGeVixMLxsYqlhpDnqFdGVbYogrwqIxKlZYljzOLRJXWnGQBaHBqfnGsStOwyew20i)X6m3F56ymCd03akXoHAHryztJ8hRZC)LRJXWnWJgu9snqFdGVbYogrwqsvKlZYljzOh0gYKwdO6gq4gurdOe7eQfgH1zU)Y1Xy4gOP1azhJiliXlYLz5LKm0Y1Xy4gq1nGWnOIgqj2julmcRZC)LRJXWnqFdKDmISGeVixMLxsYqpOnKjTgq1nW7LAqLnGsStOwyewN5(lxhJHBqfnGsStOwyew20i)X6m3F56ymCd00AaLyNqTWiSoZ9xUogd3apAGSJrKfKuf5YS8ssg6bTHmP1G7Bq1gOP1akXoHAHryDM7dPObW1anTgi7yezbjErUmlVKKHwUogd3aQUbeUbE0akXoHAHryztJ8hRZC)LRJXWnqFdGVbYogrwqsvKlZYljzOh0gYKwdO6gq4gurdOe7eQfgHLnnYFSoZ9xUogd3anTgOCdKDmISGKQiyb(dH5VkenDd03a4BaLyNqTWiSoZ9xUogd3apAGSJrKfKuf5YS8ssg6bTHmP1G7Bq1gOP1akXoHAHryDM7dPObW1a4AaCnaUgaxdGRbAAnqILmlizQ5VK)3WnOIgqj2julmcRZC)LRJXWnaUgOP1aLBGSJrKfKufblWFim)vHOPBG(gOCdCjf2ctqe1TtynqFdGVbYogrwqIxeSa)HW8xfIMUb6Ba8na(gOCdOe7eQfgH1zUpKIgOP1azhJiliXlYLz5LKm0Y1Xy4g4rdiCdGRb6Ba8nGsStOwyewN5(lxhJHBGhnO6LAGMwdKDmISGeVixMLxsYqlxhJHBav3ac3apAaLyNqTWiSoZ9xUogd3a4AaCnqtRbk3azhJiliXlcwG)qy(Rcrt3a9na(gOCdKDmISGeViyb(7YS8sswd00AGSJrKfK4f5YS8ssgA56ymCd00AGSJrKfK4f5YS8ssg6bTHmP1apU2azhJiliPkYLz5LKm0dAdzsRbW1a4o(4sk4JVSJrKLQh5ih54tHx8K252QxQQ3l5zv9Kp(KI1gJm(4tiLqiHKB90U1Z5UnOb3aJBWuRixPb052acKDCeXWsbtqdw2Zdnl)AaoR5geqswhc)AGdwyKzmQv6YJXnW7DBWDsJcVc)AabsuytquHGgizdiqIcBcIki2c1c)iObW7L6WHALU8yCdi072G7KgfEf(1acwiJPZLmJOcbnqYgqWczmDUKzevqSfQf(rqdG3l1Hd1kD5X4g4jUBdUtAu4v4xdiyHmMoxYmIke0ajBablKX05sMrubXwOw4hbniKg4j55E5gaVxQdhQv6YJXnGQE3gCN0OWRWVgqGef2eeviObs2acKOWMGOcITqTWpcAa8EPoCOwPlpg3ap572G7KgfEf(1acKOWMGOcbnqYgqGef2eevqSfQf(rqdG3l1Hd1kD5X4g4T6DBWDsJcVc)AabsuytquHGgizdiqIcBcIki2c1c)iObW7L6WHALU8yCd8w9Un4oPrHxHFnGGfYy6CjZiQqqdKSbeSqgtNlzgrfeBHAHFe0a49sD4qTsxEmUbEj8DBWDsJcVc)AabsuytquHGgizdiqIcBcIki2c1c)iObWxL6WHALU8yCd8s472G7KgfEf(1acwiJPZLmJOcbnqYgqWczmDUKzevqSfQf(rqdG3l1Hd1kD5X4g41ZUBdUtAu4v4xdiqIcBcIke0ajBabsuytqubXwOw4hbnaEVuhouR0LhJBqvc9Un4oPrHxHFnGGfYy6CjZiQqqdKSbeSqgtNlzgrfeBHAHFe0GqAGNKN7LBa8EPoCOwPlpg3GQEI72G7KgfEf(1acwiJPZLmJOcbnqYgqWczmDUKzevqSfQf(rqdcPbEsEUxUbW7L6WHALALiKsiKqYTEA365C3g0GBGXnyQvKR0a6CBabpMoGkcbnyzpp0S8Rb4SMBqajzDi8RboyHrMXOwPlpg3GQ3Tb3jnk8k8RbeSqgtNlzgrfcAGKnGGfYy6CjZiQGylul8JGgaVxQdhQv6YJXnO6DBWDsJcVc)AablKX05sMruHGgizdiyHmMoxYmIki2c1c)iObW7L6WHALU8yCdQE3gCN0OWRWVgqGlTh0iiQqqdKSbe4s7bncIki2c1c)iObW7L6WHALU8yCdQE3gCN0OWRWVgqaoHkQJ9quHGgizdiaNqf1XEiQGylul8JGgaVxQdhQvQvIqkHqcj36PDRNZDBqdUbg3GPwrUsdOZTbeOyzxwRgcbnyzpp0S8Rb4SMBqajzDi8RboyHrMXOwPlpg3GQ3Tb3jnk8k8RbeGtOI6ypeviObs2acWjurDShIki2c1c)iObH0apjp3l3a49sD4qTsxEmUbe6DBWDsJcVc)AablKX05sMruHGgizdiyHmMoxYmIki2c1c)iObH0apjp3l3a49sD4qTsxEmUbEI72G7KgfEf(1acKOWMGOcbnqYgqGef2eevqSfQf(rqdcPbEsEUxUbW7L6WHALU8yCdOQ3Tb3jnk8k8RbeirHnbrfcAGKnGajkSjiQGylul8JGgaVxQdhQv6YJXnWt(Un4oPrHxHFnGajkSjiQqqdKSbeirHnbrfeBHAHFe0a49sD4qTsTsesjesi5wpTB9CUBdAWnW4gm1kYvAaDUnGaSqqdw2Zdnl)AaoR5geqswhc)AGdwyKzmQv6YJXnW7DBWDsJcVc)AabsuytquHGgizdiqIcBcIki2c1c)iObW7L6WHALU8yCd8e3Tb3jnk8k8RbeSqgtNlzgrfcAGKnGGfYy6CjZiQGylul8JGgesd8K8CVCdG3l1Hd1kD5X4gq472G7KgfEf(1acwiJPZLmJOcbnqYgqWczmDUKzevqSfQf(rqdG3l1Hd1kD5X4g417DBWDsJcVc)AabsuytquHGgizdiqIcBcIki2c1c)iObW7L6WHALU8yCd8w9Un4oPrHxHFnGajkSjiQqqdKSbeirHnbrfeBHAHFe0a49sD4qTsxEmUbEj072G7KgfEf(1acKOWMGOcbnqYgqGef2eevqSfQf(rqdG3l1Hd1kD5X4g41tC3gCN0OWRWVgqGef2eeviObs2acKOWMGOcITqTWpcAa8vPoCOwPlpg3aVEI72G7KgfEf(1acWjurDShIke0ajBab4eQOo2drfeBHAHFe0a49sD4qTsxEmUbEj8DBWDsJcVc)AabsuytquHGgizdiqIcBcIki2c1c)iObW7L6WHALU8yCd86z3Tb3jnk8k8RbeirHnbrfcAGKnGajkSjiQGylul8JGgaFvQdhQv6YJXnWRND3gCN0OWRWVgqWczmDUKzeviObs2acwiJPZLmJOcITqTWpcAa8EPoCOwPlpg3aVu172G7KgfEf(1acKOWMGOcbnqYgqGef2eevqSfQf(rqdG3l1Hd1kD5X4g41t(Un4oPrHxHFnGajkSjiQqqdKSbeirHnbrfeBHAHFe0a4RsD4qTsxEmUbvj072G7KgfEf(1acKOWMGOcbnqYgqGef2eevqSfQf(rqdGVk1Hd1kD5X4guLqVBdUtAu4v4xdiyHmMoxYmIke0ajBablKX05sMrubXwOw4hbnaEVuhouR0LhJBqvcF3gCN0OWRWVgqaoHkQJ9quHGgizdiaNqf1XEiQGylul8JGgaVxQdhQvQvIqkHqcj36PDRNZDBqdUbg3GPwrUsdOZTbei7yezbtqdw2Zdnl)AaoR5geqswhc)AGdwyKzmQv6YJXnWZUBdUtAu4v4xd8N670aSotcQ3acXgizdUmu0G3qzWtAnivWBi52a4VhUgapHPoCOwPlpg3ap7Un4oPrHxHFnGazhJiliViQqqdKSbei7yezbjEruHGgaFvVuhouR0LhJBGND3gCN0OWRWVgqGSJrKfuveviObs2acKDmISGKQiQqqdGVQNrD4qTsxEmUbu172G7KgfEf(1a)P(onaRZKG6nGqSbs2Gldfn4nug8Kwdsf8gsUna(7HRbWtyQdhQv6YJXnGQE3gCN0OWRWVgqGSJrKfKxeviObs2acKDmISGeViQqqdGVQNrD4qTsxEmUbu172G7KgfEf(1acKDmISGQIOcbnqYgqGSJrKfKufrfcAa8v9sD4qTsTsEA1kYv4xd8SgeozsRbLblyuR0XhRGDNBRsypXXxXM0tHp(eYeYnGqGyjIRdddBu0ap9GmH3wjczc5gOeKXnOkv5fnO6LQ6TvQvkCYKggPyzxwRgsLxVxnfPWVpDj0XpsJr(lj1hRvkCYKggPyzxwRgsLxVNUWyyUnOLlg6R4eQOo2dPaclqf(ZlKczsRvkCYKggPyzxwRgsLxVxI9lBO4IH(6czmDUKzeoHk05sM)CTkV4wPWjtAyKILDzTAivE9(xcPw4VekUqXYUalFzQ5REV0fd91Wjdf(Zgxpm2dVAAk7skSfMGiQBNW0RSef2eeLSuyDTseYn4oWcJm3ajBG3gizdWtnujeUbEs34P7EFFpDnGmhlMuOOb3SqmgwknqXYUalOwPWjtAyKILDzTAivE9EkXoHAHVWIA(kl0Ffl7cSCbLOaXxlmz2EXQdXb5clrjn8xwi(tNoimITqTWp9ywKXiJrCqUWsus7JjfkqSfQf(1kfozsdJuSSlRvdPYR3lleJHLYfkw2fy5Zc9N98qJIREVqXYUalFmM(VHr8kv9cfl7cS8LPMVw9IH(kLyNqTWiwO)kw2fyPvkCYKggPyzxwRgsLxVpMA(9XWs5IH(A4KHc)zJRhgxbHQhELDjf2ctqe1Tty6vwIcBcIswkSonTWjdf(ZgxpmUIQWPxzkXoHAHrSq)vSSlWsRu4KjnmsXYUSwnKkVEpw44P7JHLYfd91Wjdf(Zgxpm2JQAAW7skSfMGiQBNW00KOWMGOKLcRdo9Htgk8NnUEy81QAAuIDc1cJyH(RyzxGLwPwPWjtA4kVEVlHmH3pgwkTsHtM0WvE9ExczcVFmSuUOmg)DVRe6LUyOVUqgtNlzgHzfWGOkWFfB6krDitAAA4eQOo2dzJUa)Lml4VICWPPPbVlTh0iOLPWlok)K(tNRazSELxiJPZLmJWScyquf4VInDLOoKjn4ALiKBGNt2GaghVge2Rb3SH55HMYqvWn4wpvVtdyJRhg7PFdiXn4LgbsdEzdeydUb052afLqhV4gOYUacZnyecEnqLBGKzdWkI6ADniSxdiXnWfgbsdwoEtrxdUzdZZ3aSc2n0JRbQq00yuRu4KjnCLxVx2W88qtzOkgJ8hdlLlg6RklXsMf0G)kkHoEBLiKjKBaHGCj01a6Wng5gOlH2g8sivPbqMmLgOlHAaSGc3afqsdiKW40czmYnGq4UjPg8ss2fni3gm0nqGXnWLz5LKSgm4giz2GsAKBGKn4XLqxdOd3yKBGUeABaHGjKQGAGNgDdS04gK0nqGXyUbU0EJmPHBqSCdc1c3ajBqnlnG0iWgRbcmUbEVudWSlThUbfMjf6UObcmUb4PUb0HJXnqxcTnGqWesvAqajzDiJlkfDOwjczc5geozsdx517nMeDczV)Y4SqHVyOVItOI6ypKXKOti79xgNfkSE4vHOPrlJtlKXi)JDtsiifAAUmlVKKHwgNwiJr(h7MKqlxhJH9W7L00utmwp9qgM8xUogdxHxptttzxsHTWeerD7egCTsHtM0WvE9Exuk)WjtA)YGLlSOMVk7yezbFXqF1Luylmbru3oHP3Lz5LKmKSqmgwkOLRJXW6DzwEjjdTmoTqgJ8p2njHwUogdRPPSlPWwycIOUDctVlZYljzizHymSuqlxhJHBLcNmPHR869UOu(HtM0(LblxyrnF19WTsHtM0WvE9Exuk)WjtA)YGLlSOMVILlg6RHtgk8NnUEyCfeARu4KjnCLxV3fLYpCYK2Vmy5clQ5RYooIyyPGVyOVgozOWF246HXEuTvQvkCYKgg5E4RQ8I5L4yKVyOVQcrtJKfIXWsbbPqtJEidt(lxhJHRWlH2kfozsdJCpCLxVxTK57tdT6UyOVQcrtJKfIXWsbbPqtZLz5LKmKSqmgwkOLRJXWEqOxsttnXy90dzyYF56ymCfE9SwPWjtAyK7HR869H5ySSr57Is5IH(QkennswigdlfeKcnnxMLxsYqYcXyyPGwUogd7bHEjnn1eJ1tpKHj)LRJXWv41ZALcNmPHrUhUYR3tplRwY8DXqFvfIMgjleJHLccsHMMlZYljzizHymSuqlxhJH9GqVKMMAIX6PhYWK)Y1Xy4kOkBLcNmPHrUhUYR3xgYWe83tfOh5A2Klg6RQq00izHymSuqVKK1kfozsdJCpCLxVxrktAxm0xvHOPrYcXyyPGGuOhEviAAKAjZxbcliifAAsSKzbbJJIadPWjvu9sWPPPMySE6Hmm5VCDmgUIQEwRuRu4KjnmclxXchpDFmSuUyOVkrHnbHfoE6(0PdcRhEflt5t29qEryHJNUpgwk6vHOPryHJNUpD6GWOLRJXWvqynnviAAew44P7tNoim6LKm40dVkennAzCAHmg5FSBsc9ssMMMYUKcBHjiI62jm4ALcNmPHryPYR3tCkLpgwkTsHtM0WiSu517FjKAH)sO4IH(QlPWwycIOUDctp8UmlVKKHwgNwiJr(h7MKqlxhJHRGS7bNMMYUKcBHjiI62jm9k7skSfMGSHmm5thSMMlPWwycYgYWKpDW6H3Lz5LKmePP8(yfZocgTCDmgUcYUNMMlZYljzist59XkMDemA56ymShe6LGtttILmlizQ5VK)3Wv4LWTsHtM0WiSu517PlXYxugJ)U31Qe(IH(Qe7x2qbcsH(fYy6CjZiCcvOZLm)5AvEXTsHtM0WiSu517Ly)YgkUyOVUqgtNlzgHtOcDUK5pxRYlwVe7x2qbA56ymCfKDp9UmlVKKHOlXYOLRJXWvq29ALcNmPHryPYR3ZuxrjXdf(JHLsRu4KjnmclvE9Est59XkMDeCRu4KjnmclvE9E6sOJFFmSuALcNmPHryPYR3)4qG9DWcIBuFXqFLoDq4kDbw(ltMTkOthegvhuVvkCYKggHLkVEF8RH2hV)K(72KeUvkCYKggHLkVEpPykJr(h7MKUyOV6YS8ssgAzCAHmg5FSBscTCDmgUcYUNE4vwIcBcIPUIsIhk8hdlfnnviAAKAjZxbcliifWPPPSlPWwycIOUDcttZLz5LKm0Y40czmY)y3KeA56ymSMMAIX6PhYWK)Y1Xy4kiCRu4KjnmclvE9(LXPfYyK)XUjPlg6RQq00OxcPw4Vekqqk00uwIcBc6LqQf(lHcnn1eJ1tpKHj)LRJXWv4TARu4KjnmclvE9EkzPW6UyOVQcrtJwgNwiJr(h7MKqqk00u2Luylmbru3oHPhEviAAKILDdM)yyPGrVKKPPPSef2eKd2uh8gFmSu00cNmu4pBC9W4kQcxRu4KjnmclvE9ESWXt3hdlLlg6RUKcBHjiI62jm90PdcxPlWYFzYSvbD6GWO6G66HhExMLxsYqlJtlKXi)JDtsOLRJXWvq298uiu9WRmoHkQJ9qmnneEOW)WM64hohx4nKC10uwIcBc6LqQf(lHc4GtttIcBc6LqQf(lHc9UmlVKKHEjKAH)sOaTCDmgUccfUwPWjtAyewQ869YcXyyPCXqFvfIMgPyz3G5pgwky0ljz6H3LuylmbrHnbMUvtZLuylmbzSBZsUpnnjkSjixukJr(lW4pgwky400uHOPrlJtlKXi)JDtsiifAAQq00ist59XkMDemcsHMMkennIswkSoeKc9Htgk8NnUEyShE10utmwp9qgM8xUogdxrvc3kfozsdJWsLxVFdfZ7tplFXqFDHmMoxYmcdTKhJ8hdlfSEjkSjiSSCuxgJ1dVlZYljzOxcPw4VekqlxhJH9GS75PqynnLDjf2ctqe1TtyAAklrHnb9si1c)LqbCHtM0WiSu517DWM6G34JHLYfd9vviAAKILDdM)yyPGrqk00Othe2dxILkdNmPHIPMFFmSuqUelTsHtM0WiSu517JPMFFmSuUWPZv4VelzwWx9EXqFvfIMgPyz3G5pgwky0ljzAAWRcrtJKfIXWsbbPqtJgQu(l7Gflz(ltnxbz3RsxGLVm1mC6HxzjkSjihSPo4n(yyPOPfozOWF246HXvufonnviAAKSJJ4hdlfmA56ymShm1zhKWFzQz9Htgk8NnUEyShEBLcNmPHryPYR3VHI59PNLVyOVcVlZYljzOxcPw4VekqlxhJH9GS75PqynnLDjf2ctqe1TtyAAklrHnb9si1c)LqbC6PtheUsxGL)YKzRc60bHr1b11dVkennswigdlf0ljzAAkxyYS9IvhIdYfwIsA4VSq8NoDqyeBHAHFWPhEviAA0lHul8xcfOxsY00KOWMGWYYrDzmgUwPWjtAyewQ869oytDWB8XWs5IH(QkennsXYUbZFmSuWiifAA0Pdc7HlXsLHtM0qXuZVpgwkixILwPWjtAyewQ869X6cJ)yyPCXqFvfIMgPyz3G5pgwkyeKcnn60bH9WLyPYWjtAOyQ53hdlfKlXsRu4KjnmclvE9EmVkyt(yzmYx405k8xILml4REVyOVUm9YyyHAH1lXsMfKm18xY)BypEqBitATsHtM0WiSu517vJDdY8fd91Wjdf(Zgxpm2dVTsHtM0WiSu5173qX8(0ZYxm0xH3Lz5LKm0lHul8xcfOLRJXWEq298uiS(fYy6CjZim0sEmYFmSuWAAk7skSfMGiQBNW00uwIcBc6LqQf(lHc40tNoiCLUal)LjZwf0PdcJQdQRhEviAA0lHul8xcfOxsY00KOWMGWYYrDzmgUwPWjtAyewQ869Qb5Fs)LDCeXxm0xvHOPrYcXyyPGEjjRvkCYKggHLkVEpDHXWCBqlxm0xXjurDShsbewGk8NxifYKMEviAAKSqmgwkOxsYALcNmPHryPYR3JfoE6(yyP0k1kfozsdJKDCeXWsbFflC809XWs5IH(Qef2eew44P7tNoiS(X(0LHmmrVkennclC809PthegTCDmgUcc3kfozsdJKDCeXWsbx517FjKAH)sO4IH(QlPWwycIOUDctVlZYljzOLXPfYyK)XUjj0Y1Xy4ki7EAAk7skSfMGiQBNW0RSlPWwycYgYWKpDWAAUKcBHjiBidt(0bRhExMLxsYqKMY7Jvm7iy0Y1Xy4ki7EAAUmlVKKHinL3hRy2rWOLRJXWEqOxconnjwYSGKPM)s(FdxH3lPP5YS8ssgAzCAHmg5FSBscTCDmg2dVxsF4KHc)zJRhg7bH2kfozsdJKDCeXWsbx517Ly)YgkUyOVUqgtNlzgHtOcDUK5pxRYlwVe7x2qbA56ymCfKDp9UmlVKKHOlXYOLRJXWvq29ALcNmPHrYooIyyPGR8690Ly5lkJXF37AvcFXqFvI9lBOabPq)czmDUKzeoHk05sM)CTkV4wPWjtAyKSJJigwk4kVEptDfLepu4pgwkTsHtM0WizhhrmSuWvE9Est59XkMDeCRu4Kjnms2XredlfCLxVNumLXi)JDtsxm0xDzwEjjdTmoTqgJ8p2njHwUogdxbz3tp8klrHnbXuxrjXdf(JHLIMMkennsTK5RaHfeKc400u2Luylmbru3oHPP5YS8ssgAzCAHmg5FSBscTCDmg2dVxsttnXy90dzyYF56ymCfeUvkCYKggj74iIHLcUYR3VmoTqgJ8p2njDXqFvfIMg9si1c)LqbcsHMMYsuytqVesTWFjuOPPMySE6Hmm5VCDmgUcVvBLcNmPHrYooIyyPGR869uYsH1DXqFvfIMgTmoTqgJ8p2njHGuOPPSlPWwycIOUDcRvkCYKggj74iIHLcUYR3Rg7gK5wPWjtAyKSJJigwk4kVEVSqmgwkTsHtM0WizhhrmSuWvE9(numVp9S8fd91fYy6CjZim0sEmYFmSuW6H3Lz5LKm0Y40czmY)y3KeA56ymShEVKMMYUKcBHjiI62jmnnLLOWMGEjKAH)sOao9Qq00izhhXpgwky0Y1XyypUYuNDqc)LPMBLcNmPHrYooIyyPGR869XuZVpgwkx405k8xILml4REVyOVQcrtJKDCe)yyPGrlxhJH94ktD2bj8xMAwp8Qq00ifl7gm)XWsbJEjjttJgQu(l7Gflz(ltnxHlWYxMAUsYUNMMkennswigdlfeKc4ALcNmPHrYooIyyPGR869poeyFhSG4g1xm0xPtheUsxGL)YKzRc60bHr1b1BLcNmPHrYooIyyPGR869BOyEF6z5lg6RW7YS8ssg6LqQf(lHc0Y1Xyypi7EEkew)czmDUKzegAjpg5pgwkynnLDjf2ctqe1TtyAAklrHnb9si1c)LqbC6PtheUsxGL)YKzRc60bHr1b11dVkenn6LqQf(lHc0ljzAAsuytqyz5OUmgdxRu4Kjnms2XredlfCLxVVgQidgwkxm0xvHOPrYooIFmSuWOxsY00uHOPrkw2ny(JHLcgbPqpD6GWE4sSuz4Kjnum187JHLcYLyrp8klrHnb5Gn1bVXhdlfnTWjdf(Zgxpm2dcfUwPWjtAyKSJJigwk4kVEVd2uh8gFmSuUyOVQcrtJuSSBW8hdlfmcsHE60bH9WLyPYWjtAOyQ53hdlfKlXI(Wjdf(ZgxpmUcprRu4Kjnms2XredlfCLxVN4ukFmSuUyOVQcrtJEC8(Sog9sswRu4Kjnms2XredlfCLxVp(1q7J3Fs)DBsc3kfozsdJKDCeXWsbx517PlHo(9XWsPvkCYKggj74iIHLcUYR3J5vbBYhlJr(cNoxH)sSKzbF17fd91LPxgdlulCRu4Kjnms2XredlfCLxVVgQidgwkxm0xPthe2dxILkdNmPHIPMFFmSuqUel6H3Lz5LKm0Y40czmY)y3KeA56ymShewttzxsHTWeerD7eMMgD6GWv6cS8xMmBEqNoimQoOoCTsHtM0WizhhrmSuWvE9Ej2VSHIlg6RlKX05sMrgJXJrMuS6WFzdfkgJ8puOi2qGWTsHtM0WizhhrmSuWvE9E6LzQIXi)LnuCXqFDHmMoxYmYymEmYKIvh(lBOqXyK)HcfXgceUvkCYKggj74iIHLcUYR3RgK)j9x2XreFXqFvfIMgjleJHLc6LKSwPWjtAyKSJJigwk4kVEpw44P7JHLsRuRu4Kjnms2XiYc(kLyNqTWxyrnFfRZCFifxqjkq8vviAA0Y40czmY)y3KecsHMMkennswigdlfeKIwPWjtAyKSJrKfCLxVNsStOw4lSOMVILnnYFSoZ9HuCbLOaXxDjf2ctqe1Tty6vHOPrlJtlKXi)JDtsiif6vHOPrYcXyyPGGuOPPSlPWwycIOUDctVkennswigdlfeKIwPWjtAyKSJrKfCLxVNsStOw4lSOMVILnnYFSoZ9xUogdFrQ4kMLH(cxAVrM0U6skSfMGiQBNWUGsuG4RUmlVKKHwgNwiJr(h7MKqlxhJHRWtTlZYljzizHymSuqlxhJHVGsuG4pxW8vxMLxsYqYcXyyPGwUogdFXqFvfIMgjleJHLc6LKSwPWjtAyKSJrKfCLxVNsStOw4lSOMVILnnYFSoZ9xUogdFrQ4kMLH(cxAVrM0U6skSfMGiQBNWUGsuG4RUmlVKKHwgNwiJr(h7MKqlxhJHVGsuG4pxW8vxMLxsYqYcXyyPGwUogdFXqFvfIMgjleJHLccsrRu4Kjnms2XiYcUYR3tj2jul8fwuZxX6m3F56ym8fPIRywg6lCP9gzs7QlPWwycIOUDc7ckrbIV6YS8ssgAzCAHmg5FSBscTCDmg2dp1UmlVKKHKfIXWsbTCDmg(ckrbI)CbZxDzwEjjdjleJHLcA56ymCRu4Kjnms2XiYcUYR3dH5)iCn(cCjf8vzhJilEVyOVcVSJrKfKxeSa)HW8xfIMwtZLuylmbru3oHPx2XiYcYlcwG)UmlVKKbNE4Pe7eQfgHLnnYFSoZ9HuOhELDjf2ctqe1Tty6vw2XiYcQkcwG)qy(RcrtRP5skSfMGiQBNW0RSSJrKfuveSa)DzwEjjttt2XiYcQkYLz5LKm0Y1XyynnzhJiliViyb(dH5VkenTE4vw2XiYcQkcwG)qy(RcrtRPj7yezb5f5YS8ssg6bTHmP5XvzhJilOQixMLxsYqpOnKjn400KDmISG8IGf4VlZYljz6vw2XiYcQkcwG)qy(RcrtRx2XiYcYlYLz5LKm0dAdzsZJRYogrwqvrUmlVKKHEqBitAWPPPmLyNqTWiSSPr(J1zUpKc9WRSSJrKfuveSa)HW8xfIMwp8YogrwqErUmlVKKHEqBitAunHRGsStOwyewN5(lxhJH10Oe7eQfgH1zU)Y1XyypKDmISG8ICzwEjjd9G2qM0ieRcNMMSJrKfuveSa)HW8xfIMwp8YogrwqErWc8hcZFviAA9YogrwqErUmlVKKHEqBitAECv2XiYcQkYLz5LKm0dAdzstp8YogrwqErUmlVKKHEqBitAunHRGsStOwyewN5(lxhJH10Oe7eQfgH1zU)Y1XyypKDmISG8ICzwEjjd9G2qM0ieRcNMg8kl7yezb5fblWFim)vHOP10KDmISGQICzwEjjd9G2qM084QSJrKfKxKlZYljzOh0gYKgC6Hx2XiYcQkYLz5LKm0YXtNEzhJilOQixMLxsYqpOnKjnQMWEqj2julmcRZC)LRJXW6Pe7eQfgH1zU)Y1Xy4kKDmISGQICzwEjjd9G2qM0ieRQPPSSJrKfuvKlZYljzOLJNo9Wl7yezbvf5YS8ssgA56ymmvt4kOe7eQfgHLnnYFSoZ9xUogdRNsStOwyew20i)X6m3F56ymShvVKE4LDmISG8ICzwEjjd9G2qM0OAcxbLyNqTWiSoZ9xUogdRPj7yezbvf5YS8ssgA56ymmvt4kOe7eQfgH1zU)Y1Xyy9YogrwqvrUmlVKKHEqBitAuT3lvjLyNqTWiSoZ9xUogdxbLyNqTWiSSPr(J1zU)Y1XyynnkXoHAHryDM7VCDmg2dzhJiliVixMLxsYqpOnKjncXQAAuIDc1cJW6m3hsbCAAYogrwqvrUmlVKKHwUogdt1e2dkXoHAHryztJ8hRZC)LRJXW6Hx2XiYcYlYLz5LKm0dAdzsJQjCfuIDc1cJWYMg5pwN5(lxhJH10uw2XiYcYlcwG)qy(RcrtRhEkXoHAHryDM7VCDmg2dzhJiliVixMLxsYqpOnKjncXQAAuIDc1cJW6m3hsbCWbhCWbNMMelzwqYuZFj)VHRGsStOwyewN5(lxhJHHtttzzhJiliViyb(dH5VkenTELDjf2ctqe1Tty6Hx2XiYcQkcwG)qy(RcrtRhE4vMsStOwyewN5(qk00KDmISGQICzwEjjdTCDmg2dcdNE4Pe7eQfgH1zU)Y1XyypQEjnnzhJilOQixMLxsYqlxhJHPAc7bLyNqTWiSoZ9xUogddhCAAkl7yezbvfblWFim)vHOP1dVYYogrwqvrWc83Lz5LKmnnzhJilOQixMLxsYqlxhJH10KDmISGQICzwEjjd9G2qM084QSJrKfKxKlZYljzOh0gYKgCW1kfozsdJKDmISGR869qy(pcxJVaxsbFv2XiYs1lg6RWl7yezbvfblWFim)vHOP10Cjf2ctqe1Tty6LDmISGQIGf4VlZYljzWPhEkXoHAHryztJ8hRZCFif6HxzxsHTWeerD7eMELLDmISG8IGf4peM)Qq00AAUKcBHjiI62jm9kl7yezb5fblWFxMLxsY00KDmISG8ICzwEjjdTCDmgwtt2XiYcQkcwG)qy(RcrtRhELLDmISG8IGf4peM)Qq00AAYogrwqvrUmlVKKHEqBitAECv2XiYcYlYLz5LKm0dAdzsdonnzhJilOQiyb(7YS8ssMELLDmISG8IGf4peM)Qq006LDmISGQICzwEjjd9G2qM084QSJrKfKxKlZYljzOh0gYKgCAAktj2julmclBAK)yDM7dPqp8kl7yezb5fblWFim)vHOP1dVSJrKfuvKlZYljzOh0gYKgvt4kOe7eQfgH1zU)Y1XyynnkXoHAHryDM7VCDmg2dzhJilOQixMLxsYqpOnKjncXQWPPj7yezb5fblWFim)vHOP1dVSJrKfuveSa)HW8xfIMwVSJrKfuvKlZYljzOh0gYKMhxLDmISG8ICzwEjjd9G2qM00dVSJrKfuvKlZYljzOh0gYKgvt4kOe7eQfgH1zU)Y1XyynnkXoHAHryDM7VCDmg2dzhJilOQixMLxsYqpOnKjncXQWPPbVYYogrwqvrWc8hcZFviAAnnzhJiliVixMLxsYqpOnKjnpUk7yezbvf5YS8ssg6bTHmPbNE4LDmISG8ICzwEjjdTC80Px2XiYcYlYLz5LKm0dAdzsJQjShuIDc1cJW6m3F56ymSEkXoHAHryDM7VCDmgUczhJiliVixMLxsYqpOnKjncXQAAkl7yezb5f5YS8ssgA54Ptp8YogrwqErUmlVKKHwUogdt1eUckXoHAHryztJ8hRZC)LRJXW6Pe7eQfgHLnnYFSoZ9xUogd7r1lPhEzhJilOQixMLxsYqpOnKjnQMWvqj2julmcRZC)LRJXWAAYogrwqErUmlVKKHwUogdt1eUckXoHAHryDM7VCDmgwVSJrKfKxKlZYljzOh0gYKgv79svsj2julmcRZC)LRJXWvqj2julmclBAK)yDM7VCDmgwtJsStOwyewN5(lxhJH9q2XiYcQkYLz5LKm0dAdzsJqSQMgLyNqTWiSoZ9HuaNMMSJrKfKxKlZYljzOLRJXWunH9GsStOwyew20i)X6m3F56ymSE4LDmISGQICzwEjjd9G2qM0OAcxbLyNqTWiSSPr(J1zU)Y1XyynnLLDmISGQIGf4peM)Qq006HNsStOwyewN5(lxhJH9q2XiYcQkYLz5LKm0dAdzsJqSQMgLyNqTWiSoZ9HuahCWbhCWPPjXsMfKm18xY)B4kOe7eQfgH1zU)Y1Xyy400uw2XiYcQkcwG)qy(RcrtRxzxsHTWeerD7eME4LDmISG8IGf4peM)Qq006HhELPe7eQfgH1zUpKcnnzhJiliVixMLxsYqlxhJH9GWWPhEkXoHAHryDM7VCDmg2JQxstt2XiYcYlYLz5LKm0Y1XyyQMWEqj2julmcRZC)LRJXWWbNMMYYogrwqErWc8hcZFviAA9WRSSJrKfKxeSa)DzwEjjttt2XiYcYlYLz5LKm0Y1XyynnzhJiliVixMLxsYqpOnKjnpUk7yezbvf5YS8ssg6bTHmPbhCh5iNda]] )

    
end