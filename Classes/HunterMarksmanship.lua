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


    spec:RegisterPack( "Marksmanship", 20210627, [[d0enhcqiHKhHaQUesiSjH4tirJcHCkeQxHanlfu3cjXUa9leuddb4yuOLrP6ziGmnkO01aI2MqQ8nHuvJdbu6CuqfRdjW7qafAEki3diTpKu)JcQuhKckyHij9qKqDrKquFKcQQrIak4KiH0kPaZejOBIakANii)ejezOuqrzPuqHEQQyQaHRsbfvFLckYyPGSxi(lKgSKdl1IPKhlyYaUmXMr0NrkJwOoTkRMcQKxRknBfDBfA3K(nvdxboUqQYYv65qnDuxxvTDKQVduJxiLZtPSEkOkZNI2VOrmIacKhGMfeczNaSBKaIo7rFOXOdKgnSgrEyBdeKNbD4TPjipApkipey27lESvC8na5zqBB6naciqEW(FdcYdbEwXmpatbeMW0oo(Bbd(iHX34F285AyBsMW4BmqyKhR)nzkQIyH8a0SGqi7eGDJeq0zp6dngDG0ibYWb5P)CSVipp3ifJ8eFaaIIyH8ai4aYdbM9(IhBfhFdYIadFLLnnWGVkzzp6pCw2ja7grEMhMXiGa5H3l8IJDgJaceczebeipI2wtbaHQipH9yzVg5H7POmeZsdydL0dFmu02AkazfjRtrjNhTyoRizz9jjHywAaBOKE4JHRm2NIZAOSajYth4ZvKhmlnGnuCSZimcHSJacKhrBRPaGqvKNWESSxJ8eC6I2kdFTTxRzfjRG7tahScxb7AZNsdT31bdxzSpfN1qzrlaKLPzwrLvWPlARm812ETMvKSIkRGtx0wzOE0IzuYwYY0mRGtx0wzOE0IzuYwYksweLvW9jGdwHGVjakEWThJHRm2NIZAOSOfaYY0mRG7tahSc59l4yNHRm2NIZI6SajiZI4SmnZI7LMWq(gfu2rbojRHYYibG80b(Cf5bW)wtbL7bimcHiqiGa5r02Akaiuf5jShl71ip7xfsFPjqS)NK(stqLrlzXqrBRPaKvKS4Er5ThaxzSpfN1qzrlaKvKScUpbCWkKC2RaxzSpfN1qzrlaG80b(Cf5H7fL3EacJqidlciqEeTTMcacvrE6aFUI8qo7vqEc7XYEnYd3lkV9a4FqwrYA)Qq6lnbI9)K0xAcQmAjlgkABnfaKN5PcAaa5XoiryecbseqG80b(Cf5rI2GPJp6cko2zKhrBRPaGqvegHqrhciqE6aFUI8a(MaO4b3Emg5r02AkaiufHriu0hbeipDGpxrEwb7AZNsdT31bJ8iABnfaeQIWieIalciqEeTTMcacvrEc7XYEnYJ1NKeUc21MpLgAVRdg(hKLPzwrLvWPlARm812ETMLPzwCpfLHtHJ7jko2zmu02AkaipDGpxrEO7ZPydHriKHdciqE6aFUI8y1720eKhrBRPaGqvegHqgjaeqG80b(Cf5H3VGJDg5r02AkaiufHriKrJiGa5r02Akaiuf5jShl71ip7xfsFPjq8FPDknuCSZyOOT1uaYksweLvW9jGdwHRGDT5tPH276GHRm2NIZI6SmsazzAMvuzfC6I2kdFTTxRzzAMf3trz4u44EIIJDgdfTTMcqweNvKSS(KKqEVWlko2zmCLX(uCwudAws0KWNfu(gfKNoWNRipBp4aqjVvqyecz0ociqEeTTMcacvrE6aFUI803OaGIJDg5jShl71ipwFssiVx4ffh7mgUYyFkolQbnljAs4ZckFJswrYIOSS(KKWbReoSGIJDgdbCWAwMMzr(Nt0vcX9stq5BuYAOScnMr5BuYIGzrlaKLPzwwFssiVFbh7m8pilIrEc2ctbL7LMWyeczeHriKrceciqEeTTMcacvrEc7XYEnYdPh(4SiywHgZORqt0Sgklsp8XWXoAipDGpxrEaKMJrdX972JimcHmAyrabYJOT1uaqOkYtypw2RrEikRG7tahScxb7AZNsdT31bdxzSpfNf1zzKaYksw7xfsFPjq8FPDknuCSZyOOT1uaYY0mROYk40fTvg(ABVwZY0mROYA)Qq6lnbI)lTtPHIJDgdfTTMcqwMMzX9uugofoUNO4yNXqrBRPaKfXzfjlRpjjK3l8IIJDgdxzSpfNf1GMLenj8zbLVrb5Pd85kYZ2doauYBfegHqgbjciqEeTTMcacvrEc7XYEnYJ1NKeY7fErXXoJHaoynltZSS(KKWbReoSGIJDgd)dYkswKE4JZI6ScoMZIGz1b(Cf23OaGIJDggCmNvKSikROYI7POmmeFJTSnko2zOOT1uaYY0mRoWhDbvuz8eCwuNfbklIrE6aFUI8m(N8HJDgHriKXOdbeipI2wtbaHQipH9yzVg5X6tschSs4Wcko2zm8piRizr6HpolQZk4yolcMvh4ZvyFJcako2zyWXCwrYQd8rxqfvgpbN1qzzyrE6aFUI8eIVXw2gfh7mcJqiJrFeqG8iABnfaeQI8e2JL9AKhRpjjeqAauXMabCWkYth4ZvKN3BorXXoJWieYibweqG80b(Cf5Prh)lGSOojAyDWyKhrBRPaGqvegHqgnCqabYth4ZvKhYzBtaqXXoJ8iABnfaeQIWieYobGacKhrBRPaGqvKNoWNRipyzhikJI5tPH8e2JL9AKNvixbh3wtb5jylmfuUxAcJriKregHq2nIacKhrBRPaGqvKNWESSxJ8q6HpolQZk4yolcMvh4ZvyFJcako2zyWXmYth4ZvKNX)KpCSZimcHSBhbeipI2wtbaHQipH9yzVg5X6tsc59l4yNHaoyf5Pd85kYJvtd1jr59cVyegHq2jqiGa5Pd85kYdMLgWgko2zKhrBRPaGqvegHrEaeY(pzeqGqiJiGa5Pd85kYtW)kllko2zKhrBRPaGqvegHq2rabYJOT1uaqOkYth4ZvKNG)vwwuCSZipH9yzVg5z)Qq6lnbILbXFdpm6G1dZES5ZvOOT1uaYY0mlS)NwNca1ZwJrz3Ny0b(HDfkABnfGSmnZIOScUc8pgUcDzX9e1jrj9L)QafTTMcqwrYkQS2VkK(stGyzq83WdJoy9WShB(CfkABnfGSig5zEQGgaqEiqeacJqiceciqEeTTMcacvrE6aFUI8WBRrV)npdVtPHIJDg5bqWH9gWNRipg(EwDS0az1kqwGyBn69V5z4jzridZO4SevgpbpCwGLSaCLsolaplo(Wzr6BwdMTnzXzzjH(JLSoMsGSSKSy3ZcpOhhTLvRazbwYk0kLCwR0a30wwGyBn6LfEGeoYlKL1NKedrEc7XYEnYtuzX9sty4HrhmBBYIWieYWIacKhrBRPaGqvKNoWNRipaR0aK3kO0fmwMipacoS3a(Cf5XWCSKfhF4SCnRG7tahSM1rM1XuIZIJLSCDAllxPYhlWSOOKzzZ)zf30LSA15yzZYvQ8XswGpooRoRPR0KnRG7tahSoCwyUdVzXXnNf4JJZce7xWXoNf4yrZIJLBZk4(eWbR4ScUsoVapCwyplW9Xz9v(MzDmL4SCnRG7tahSMf7z9XswC8HholNJLf8HLScUYN(LSypRpwYY1ScUpbCWke5r7rb5byLgG8wbLUGXYeHrieirabYJOT1uaqOkYth4ZvKhEp9vyJipacoS3a(Cf5HIsMfhlzX7PVcNvCJZQZYvQ8XswwFsYHZcBtdzDCwGpoolqSFbh7mmlkkzwmypRELSc(4aHpLwwK(MvNfi2VGJDolSnnmCwFSKfhlzH51vAYMLRu5JLSessjWWSOOKz1AwUsLpwYY6tsM1HZALgWwwwFoRwDow2SW86knzZYvQ8XswwFsYSaFZzw9e7zzjzTsdylllBzXXsw8nkzbI9l4yNZk4JcolRo8MLtsMvW9jGdwhoRpwY64SoYS4yjlCCVcqw8E6RWzfCFc4G1Sa7kLCwNYYskRKf4JJZIJLS(dc(4P0Yce7xWXoNf2MgGzrrjZQ1SCLkFSKL1NKmRG)Nazzjz9XcqwTcKfMV5mRGpkzz1H3Si9nRolYp)xjlqSFbh78Wz9XswhdZIIsMvNL6kvS(KKz5kv(yjRdN1knGTHZ6JLSooRJmRJZcSRuYzDkllPSswGpooRbolkF9mlxPYhlzz9jjXzXRTtPLf7zbI9l4yNZcBtdz5BwhzwCSKLZXYMfVN(kCwhwPKZQ1SCLkFSmCwhoRol1vQy9jjZYvQ8XswGpooRoRPR0KnRG7tahSoCw(M1Hvk5SwPbSbZIIsMfhlzrE0I5SoCw08tPLf7zjkqwwcPVsw28)MLkrJZce7xWXopCwgU(yolm3lN1hFkTS490xHXzXEwJ9RKf(VswCSyllAcN1hlaqKNWESSxJ8W7PVcdzJW4gJ(XcQ1NKmRizruwwFssiVFbh7m8piRizruwrLfVN(kmKTdJBm6hlOwFsYSmnZI3tFfgY2Hb3NaoyfUYyFkoltZS490xHHSryW9jGdwHa)T5Z1SOg0S490xHHSDyW9jGdwHa)T5Z1SioltZSS(KKqE)co2ziGdwZksweLfVN(kmKTdJBm6hlOwFsYSIKfVN(kmKTddUpbCWke4VnFUMf1GMfVN(kmKncdUpbCWke4VnFUMvKS490xHHSDyW9jGdwHRm2NIZIkzbYSgkRG7tahSc59l4yNHRm2NIZkswb3NaoyfY7xWXodxzSpfNf1zzNaYY0mlEp9vyiBegCFc4GviWFB(CnlQKfiZAOScUpbCWkK3VGJDgUYyFkolIZY0mlUxAcd5Buqzhf4KSgkRG7tahSc59l4yNHRm2NIZI4SmnZkQS490xHHSryCJr)yb16tsMvKSiklEp9vyiBhg3y0pwqT(KKzfjlIYY6tsc59l4yNHaoynltZS490xHHSDyW9jGdwHRm2NIZI6SazweNvKSikRG7tahSc59l4yNHRm2NIZI6SStazzAMfVN(kmKTddUpbCWkCLX(uCwujlqMf1zfCFc4GviVFbh7mCLX(uCweNLPzwrLfVN(kmKTdJBm6hlOwFsYSIKfrzfvw8E6RWq2omUXOb3NaoynltZS490xHHSDyW9jGdwHa)T5Z1SOg0S490xHHSryW9jGdwHa)T5Z1SmnZI3tFfgY2Hb3NaoyfUYyFkolIZIyegHqrhciqEeTTMcacvrEc7XYEnYdVN(kmKTdJBm6hlOwFsYSIKfrzz9jjH8(fCSZW)GSIKfrzfvw8E6RWq2imUXOFSGA9jjZY0mlEp9vyiBegCFc4Gv4kJ9P4SmnZI3tFfgY2Hb3Naoyfc83MpxZIAqZI3tFfgYgHb3Naoyfc83MpxZI4SmnZY6tsc59l4yNHaoynRizruw8E6RWq2imUXOFSGA9jjZksw8E6RWq2im4(eWbRqG)285AwudAw8E6RWq2om4(eWbRqG)285AwrYI3tFfgYgHb3NaoyfUYyFkolQKfiZAOScUpbCWkK3VGJDgUYyFkoRizfCFc4GviVFbh7mCLX(uCwuNLDciltZS490xHHSDyW9jGdwHa)T5Z1SOswGmRHYk4(eWbRqE)co2z4kJ9P4SioltZS4EPjmKVrbLDuGtYAOScUpbCWkK3VGJDgUYyFkolIZY0mROYI3tFfgY2HXng9JfuRpjzwrYIOS490xHHSryCJr)yb16tsMvKSiklRpjjK3VGJDgc4G1SmnZI3tFfgYgHb3NaoyfUYyFkolQZcKzrCwrYIOScUpbCWkK3VGJDgUYyFkolQZYobKLPzw8E6RWq2im4(eWbRWvg7tXzrLSazwuNvW9jGdwH8(fCSZWvg7tXzrCwMMzfvw8E6RWq2imUXOFSGA9jjZksweLvuzX7PVcdzJW4gJgCFc4G1SmnZI3tFfgYgHb3Naoyfc83MpxZIAqZI3tFfgY2Hb3Naoyfc83MpxZY0mlEp9vyiBegCFc4Gv4kJ9P4SiolIrE6aFUI8W7PVcBhHriu0hbeipI2wtbaHQipH9yzVg5X6tsc59l4yNH)bzzAML1NKeY7xWXodbCWAwrYk4(eWbRqE)co2z4kJ9P4SOol7eqwMMzrE0Iz0vg7tXznuwb3NaoyfY7xWXodxzSpfJ80b(Cf55Jf0JLrmcJqicSiGa5r02Akaiuf5Pd85kYtONt0oWNROZdZipZdZOApkipbamcJqidheqG8iABnfaeQI8e2JL9AKNoWhDbvuz8eCwdLfbc5Pd85kYtONt0oWNROZdZipZdZOApkipygHriKrcabeipI2wtbaHQipH9yzVg5Pd8rxqfvgpbNf1zzh5Pd85kYtONt0oWNROZdZipZdZOApkip8EHxCSZyegHrEgSsWhTAgbeieYiciqE6aFUI8y5mpfauYzBtaaFknu2J2PipI2wtbaHQimcHSJacKhrBRPaGqvKNWESSxJ8SFvi9LMaX(Fs6lnbvgTKfdfTTMcaYth4ZvKhUxuE7bimcHiqiGa5r02Akaiuf5zWkHgZO8nkipgjaKNoWNRipa(3AkOCpa5jShl71ipDGp6cQOY4j4SOolJzzAMvuzfC6I2kdFTTxRzfjROYI7POmKUpNInOOT1uaqyeczyrabYJOT1uaqOkYJpa5blmYth4ZvKh69ET1uqEO3ZVG8mfAIc0RnO00Mc3txXO8(fusp8XqrBRPaKvKSWcZNsddLM2u4E6kkgCpakABnfaKh69IQ9OG8imj6GvcnMryecbseqG8iABnfaeQI8myLqJzu(gfKh7ipH9yzVg5HEVxBnfOWKOdwj0yg5zWkHgZOctIkrV)na5XiYth4ZvKhE)co2zKNbReAmJIXKOBRViprFegHqrhciqEeTTMcacvrEc7XYEnYth4JUGkQmEcoRHYIaLvKSikROYk40fTvg(ABVwZkswrLf3trziDFofBqrBRPaKLPzwDGp6cQOY4j4Sgkl7zrCwrYkQSO371wtbkmj6GvcnMrE6aFUI803OaGIJDgHriu0hbeipI2wtbaHQipH9yzVg5Pd8rxqfvgpbNf1zzpltZSikRGtx0wz4RT9AnltZS4EkkdP7ZPydkABnfGSioRiz1b(OlOIkJNGZc0SSNLPzw079ARPafMeDWkHgZipDGpxrEWS0a2qXXoJWimYtaaJaceczebeipI2wtbaHQipH9yzVg5X6tsc59l4yNH)bzzAMf5rlMrxzSpfN1qzzKaH80b(Cf5XswSSVNsdHriKDeqG8iABnfaeQI8e2JL9AKhRpjjK3VGJDg(hKLPzwKhTygDLX(uCwdLLXOd5Pd85kYJ10DauY)AdHriebcbeipI2wtbaHQipH9yzVg5X6tsc59l4yNH)bzzAMf5rlMrxzSpfN1qzzm6qE6aFUI80AqW82t0qpNimcHmSiGa5r02Akaiuf5jShl71ipwFssiVFbh7m8piltZSipAXm6kJ9P4SgkldhKNoWNRipK3kwt3bqyecbseqG8iABnfaeQI8e2JL9AKhRpjjK3VGJDgc4GvKNoWNRipZJwmJrnC9bOnkkJWiek6qabYJOT1uaqOkYtypw2RrES(KKqE)co2z4FqwrYY6tscTMUdm)yg(hKLPzwwFssiVFbh7m8piRizX9styyS0togoiWznuw2jGSmnZI8OfZORm2NIZAOSShDipDGpxrEg485kcJWipygbeieYiciqEeTTMcacvrEc7XYEnYd3trziMLgWgkPh(yOOT1uaYksweL1GvOJslaancXS0a2qXXoNvKSS(KKqmlnGnusp8XWvg7tXznuwGmltZSS(KKqmlnGnusp8XqahSMfXipDGpxrEWS0a2qXXoJWieYociqE6aFUI88EZjko2zKhrBRPaGqvegHqeieqG8iABnfaeQI8e2JL9AKNGtx0wz4RT9AnRizfCFc4Gv4kyxB(uAO9Uoy4kJ9P4SgklAbGSmnZkQScoDrBLHV22R1SIKvuzfC6I2kd1JwmJs2swMMzfC6I2kd1JwmJs2swrYIOScUpbCWke8nbqXdU9ymCLX(uCwdLfTaqwMMzfCFc4GviVFbh7mCLX(uCwuNfibzweNLPzwCV0egY3OGYokWjznuwgbjYth4ZvKha)BnfuUhGWieYWIacKhrBRPaGqvKNoWNRipKZEfKNWESSxJ8W9IYBpa(hKvKS2VkK(stGy)pj9LMGkJwYIHI2wtba5zEQGgaqESdsegHqGebeipI2wtbaHQipH9yzVg5z)Qq6lnbI9)K0xAcQmAjlgkABnfGSIKf3lkV9a4kJ9P4SgklAbGSIKvW9jGdwHKZEf4kJ9P4SgklAbaKNoWNRipCVO82dqyecfDiGa5Pd85kYJeTbthF0fuCSZipI2wtbaHQimcHI(iGa5Pd85kYd4BcGIhC7XyKhrBRPaGqvegHqeyrabYth4ZvKhYzBtaqXXoJ8iABnfaeQIWieYWbbeipI2wtbaHQipH9yzVg5H0dFCwemRqJz0vOjAwdLfPh(y4yhnKNoWNRipasZXOH4(D7regHqgjaeqG80b(Cf5Prh)lGSOojAyDWyKhrBRPaGqvegHqgnIacKNoWNRipRGDT5tPH276GrEeTTMcacvryecz0ociqEeTTMcacvrEc7XYEnYdrzz9jjHRGDT5tPH276GH)bzzAMvuzfC6I2kdFTTxRzzAMf3trz4u44EIIJDgdfTTMcqweNvKSiklRpjjCWkHdlO4yNXqahSMLPzwrLf3trzyi(gBzBuCSZqrBRPaKLPzwDGp6cQOY4j4Sgkl7zrmYth4ZvKh6(Ck2qyeczKaHacKhrBRPaGqvKNWESSxJ8y9jjHdwjCybfh7mgc4G1SmnZY6tscxb7AZNsdT31bd)dYY0mlRpjje8nbqXdU9ym8piltZSS(KKq6(Ck2G)bzfjRoWhDbvuz8eCwuNLrKNoWNRip8(fCSZimcHmAyrabYJOT1uaqOkYtypw2RrE2VkK(stG4)s7uAO4yNXqrBRPaKvKS4EkkdX8k948ubkABnfGSIKfrzfCFc4Gv4kyxB(uAO9Uoy4kJ9P4SOolJeqwMMzfvwbNUOTYWxB71AwMMzX9uugofoUNO4yNXqrBRPaKfXipDGpxrE2EWbGsERGWieYiirabYJOT1uaqOkYth4ZvKN(gfauCSZipH9yzVg5X6tschSs4Wcko2zmeWbRzzAMfrzz9jjH8(fCSZW)GSmnZI8pNOReI7LMGY3OK1qzrlaKfbZk0ygLVrjlIZksweLvuzX9uuggIVXw2gfh7mu02AkazzAMvh4JUGkQmEcoRHYYEweNLPzwwFssiVx4ffh7mgUYyFkolQZsIMe(SGY3OKvKS6aF0furLXtWzrDwgrEc2ctbL7LMWyeczeHriKXOdbeipI2wtbaHQipH9yzVg5HOScUpbCWkCfSRnFkn0ExhmCLX(uCwuNLrciltZSIkRGtx0wz4RT9AnltZS4EkkdNch3tuCSZyOOT1uaYI4SIKfPh(4SiywHgZORqt0Sgklsp8XWXoAzfjlRpjjuAAtH7PRyuE)ckPh(yiGdwZksweLL1NKec4FRPGY9aiGdwZY0mlUNIYqmVspopvGI2wtbilIrE6aFUI8S9GdaL8wbHriKXOpciqEeTTMcacvrEc7XYEnYJ1NKeoyLWHfuCSZy4FqwMMzr6HpolQZk4yolcMvh4ZvyFJcako2zyWXmYth4ZvKNq8n2Y2O4yNryeczKalciqEeTTMcacvrEc7XYEnYJ1NKeoyLWHfuCSZy4FqwMMzr6HpolQZk4yolcMvh4ZvyFJcako2zyWXmYth4ZvKNEdTkO4yNryecz0WbbeipI2wtbaHQipDGpxrEWYoqugfZNsd5jShl71ipRqUcoUTMswrYI7LMWq(gfu2rbojlQZc4VnFUI8eSfMck3lnHXieYicJqi7eaciqEeTTMcacvrEc7XYEnYth4JUGkQmEcolQZYiYth4ZvKhRE3MMGWieYUreqG8iABnfaeQI8e2JL9AKhIYk4(eWbRWvWU28P0q7DDWWvg7tXzrDwgjGSIK1(vH0xAce)xANsdfh7mgkABnfGSmnZkQScoDrBLHV22R1SmnZI7POmCkCCprXXoJHI2wtbilIZkswKE4JZIGzfAmJUcnrZAOSi9Whdh7OLvKSiklRpjjeW)wtbL7bqahSMLPzwCpfLHyELECEQafTTMcqweJ80b(Cf5z7bhak5TccJqi72rabYJOT1uaqOkYtypw2RrES(KKqE)co2ziGdwrE6aFUI8y10qDsuEVWlgHriKDceciqE6aFUI8GzPbSHIJDg5r02AkaiufHryKhEp9vymciqiKreqG8iABnfaeQI84dqEWcJ80b(Cf5HEVxBnfKh698lipwFss4kyxB(uAO9Uoy4FqwMMzz9jjH8(fCSZW)aKh69IQ9OG8GTPb0)aegHq2rabYJOT1uaqOkYJpa5blmYth4ZvKh69ET1uqEO3ZVG8eC6I2kdFTTxRzfjlRpjjCfSRnFkn0Exhm8piRizz9jjH8(fCSZW)GSmnZkQScoDrBLHV22R1SIKL1NKeY7xWXod)dqEO3lQ2JcYdMxxPHITPb0)aegHqeieqG8iABnfaeQI84dqEWcFKipDGpxrEO371wtb5HEVOApkipyEDLgk2MgqxzSpfJ8e2JL9AKNGtx0wz4RT9Af5HEp)cQmXcYtW9jGdwH8(fCSZWvg7tXip075xqEcUpbCWkCfSRnFkn0ExhmCLX(uCwdz4oRG7tahSc59l4yNHRm2NIryeczyrabYJOT1uaqOkYJpa5bl8rI80b(Cf5HEVxBnfKh69IQ9OG8GTPb0vg7tXipH9yzVg5j40fTvg(ABVwrEO3ZVGktSG8eCFc4GviVFbh7mCLX(umYd9E(fKNG7tahScxb7AZNsdT31bdxzSpfNf1gUZk4(eWbRqE)co2z4kJ9PyegHqGebeipI2wtbaHQipDGpxrE(yb9yzeJ8e2JL9AKhIYI3tFfgYgHXng9JfuRpjzwMMzfC6I2kdFTTxRzfjlEp9vyiBeg3y0G7tahSMfXzfjlIYIEVxBnfiMxxPHITPb0)GSIKfrzfvwbNUOTYWxB71AwrYkQS490xHHSDyCJr)yb16tsMLPzwbNUOTYWxB71AwrYkQS490xHHSDyCJrdUpbCWAwMMzX7PVcdz7WG7tahScxzSpfNLPzw8E6RWq2imUXOFSGA9jjZksweLvuzX7PVcdz7W4gJ(XcQ1NKmltZS490xHHSryW9jGdwHa)T5Z1SOg0S490xHHSDyW9jGdwHa)T5Z1SioltZS490xHHSryCJrdUpbCWAwrYkQS490xHHSDyCJr)yb16tsMvKS490xHHSryW9jGdwHa)T5Z1SOg0S490xHHSDyW9jGdwHa)T5Z1SioltZSIkl69ET1uGyEDLgk2Mgq)dYksweLvuzX7PVcdz7W4gJ(XcQ1NKmRizruw8E6RWq2im4(eWbRqG)285AwujlqM1qzrV3RTMceBtdORm2NIZY0ml69ET1uGyBAaDLX(uCwuNfVN(kmKncdUpbCWke4VnFUMfHZYEweNLPzw8E6RWq2omUXOFSGA9jjZksweLfVN(kmKncJBm6hlOwFsYSIKfVN(kmKncdUpbCWke4VnFUMf1GMfVN(kmKTddUpbCWke4VnFUMvKSiklEp9vyiBegCFc4GviWFB(CnlQKfiZAOSO371wtbITPb0vg7tXzzAMf9EV2AkqSnnGUYyFkolQZI3tFfgYgHb3Naoyfc83MpxZIWzzplIZY0mlIYkQS490xHHSryCJr)yb16tsMLPzw8E6RWq2om4(eWbRqG)285AwudAw8E6RWq2im4(eWbRqG)285AweNvKSiklEp9vyiBhgCFc4Gv4knGTSIKfVN(kmKTddUpbCWke4VnFUMfvYcKzrDw079ARPaX20a6kJ9P4SIKf9EV2AkqSnnGUYyFkoRHYI3tFfgY2Hb3Naoyfc83MpxZIWzzpltZSIklEp9vyiBhgCFc4Gv4knGTSIKfrzX7PVcdz7WG7tahScxzSpfNfvYcKznuw079ARPaX86knuSnnGUYyFkoRizrV3RTMceZRR0qX20a6kJ9P4SOol7eqwrYIOS490xHHSryW9jGdwHa)T5Z1SOswGmRHYIEVxBnfi2MgqxzSpfNLPzw8E6RWq2om4(eWbRWvg7tXzrLSazwdLf9EV2AkqSnnGUYyFkoRizX7PVcdz7WG7tahScb(BZNRzrLSazweml69ET1uGyBAaDLX(uCwdLf9EV2AkqmVUsdfBtdORm2NIZY0ml69ET1uGyBAaDLX(uCwuNfVN(kmKncdUpbCWke4VnFUMfHZYEwMMzrV3RTMceBtdO)bzrCwMMzX7PVcdz7WG7tahScxzSpfNfvYcKzrDw079ARPaX86knuSnnGUYyFkoRizruw8E6RWq2im4(eWbRqG)285AwujlqM1qzrV3RTMceZRR0qX20a6kJ9P4SmnZkQS490xHHSryCJr)yb16tsMvKSikl69ET1uGyBAaDLX(uCwuNfVN(kmKncdUpbCWke4VnFUMfHZYEwMMzrV3RTMceBtdO)bzrCweNfXzrCweNfXzzAMf3lnHH8nkOSJcCswdLf9EV2AkqSnnGUYyFkolIZY0mROYI3tFfgYgHXng9JfuRpjzwrYkQScoDrBLHV22R1SIKfrzX7PVcdz7W4gJ(XcQ1NKmRizruweLvuzrV3RTMceBtdO)bzzAMfVN(kmKTddUpbCWkCLX(uCwuNfiZI4SIKfrzrV3RTMceBtdORm2NIZI6SStazzAMfVN(kmKTddUpbCWkCLX(uCwujlqMf1zrV3RTMceBtdORm2NIZI4SioltZSIklEp9vyiBhg3y0pwqT(KKzfjlIYkQS490xHHSDyCJrdUpbCWAwMMzX7PVcdz7WG7tahScxzSpfNLPzw8E6RWq2om4(eWbRqG)285AwudAw8E6RWq2im4(eWbRqG)285AweNfXip4PZyKhEp9vyJimcHIoeqG8iABnfaeQI80b(Cf55Jf0JLrmYtypw2RrEiklEp9vyiBhg3y0pwqT(KKzzAMvWPlARm812ETMvKS490xHHSDyCJrdUpbCWAweNvKSikl69ET1uGyEDLgk2Mgq)dYksweLvuzfC6I2kdFTTxRzfjROYI3tFfgYgHXng9JfuRpjzwMMzfC6I2kdFTTxRzfjROYI3tFfgYgHXngn4(eWbRzzAMfVN(kmKncdUpbCWkCLX(uCwMMzX7PVcdz7W4gJ(XcQ1NKmRizruwrLfVN(kmKncJBm6hlOwFsYSmnZI3tFfgY2Hb3Naoyfc83MpxZIAqZI3tFfgYgHb3Naoyfc83MpxZI4SmnZI3tFfgY2HXngn4(eWbRzfjROYI3tFfgYgHXng9JfuRpjzwrYI3tFfgY2Hb3Naoyfc83MpxZIAqZI3tFfgYgHb3Naoyfc83MpxZI4SmnZkQSO371wtbI51vAOyBAa9piRizruwrLfVN(kmKncJBm6hlOwFsYSIKfrzX7PVcdz7WG7tahScb(BZNRzrLSazwdLf9EV2AkqSnnGUYyFkoltZSO371wtbITPb0vg7tXzrDw8E6RWq2om4(eWbRqG)285Aweol7zrCwMMzX7PVcdzJW4gJ(XcQ1NKmRizruw8E6RWq2omUXOFSGA9jjZksw8E6RWq2om4(eWbRqG)285AwudAw8E6RWq2im4(eWbRqG)285AwrYIOS490xHHSDyW9jGdwHa)T5Z1SOswGmRHYIEVxBnfi2MgqxzSpfNLPzw079ARPaX20a6kJ9P4SOolEp9vyiBhgCFc4GviWFB(CnlcNL9SioltZSikROYI3tFfgY2HXng9JfuRpjzwMMzX7PVcdzJWG7tahScb(BZNRzrnOzX7PVcdz7WG7tahScb(BZNRzrCwrYIOS490xHHSryW9jGdwHR0a2Yksw8E6RWq2im4(eWbRqG)285AwujlqMf1zrV3RTMceBtdORm2NIZksw079ARPaX20a6kJ9P4SgklEp9vyiBegCFc4GviWFB(CnlcNL9SmnZkQS490xHHSryW9jGdwHR0a2YksweLfVN(kmKncdUpbCWkCLX(uCwujlqM1qzrV3RTMceZRR0qX20a6kJ9P4SIKf9EV2AkqmVUsdfBtdORm2NIZI6SStazfjlIYI3tFfgY2Hb3Naoyfc83MpxZIkzbYSgkl69ET1uGyBAaDLX(uCwMMzX7PVcdzJWG7tahScxzSpfNfvYcKznuw079ARPaX20a6kJ9P4SIKfVN(kmKncdUpbCWke4VnFUMfvYcKzrWSO371wtbITPb0vg7tXznuw079ARPaX86knuSnnGUYyFkoltZSO371wtbITPb0vg7tXzrDw8E6RWq2om4(eWbRqG)285Aweol7zzAMf9EV2AkqSnnG(hKfXzzAMfVN(kmKncdUpbCWkCLX(uCwujlqMf1zrV3RTMceZRR0qX20a6kJ9P4SIKfrzX7PVcdz7WG7tahScb(BZNRzrLSazwdLf9EV2AkqmVUsdfBtdORm2NIZY0mROYI3tFfgY2HXng9JfuRpjzwrYIOSO371wtbITPb0vg7tXzrDw8E6RWq2om4(eWbRqG)285Aweol7zzAMf9EV2AkqSnnG(hKfXzrCweNfXzrCweNLPzwCV0egY3OGYokWjznuw079ARPaX20a6kJ9P4SioltZSIklEp9vyiBhg3y0pwqT(KKzfjROYk40fTvg(ABVwZksweLfVN(kmKncJBm6hlOwFsYSIKfrzruwrLf9EV2AkqSnnG(hKLPzw8E6RWq2im4(eWbRWvg7tXzrDwGmlIZksweLf9EV2AkqSnnGUYyFkolQZYobKLPzw8E6RWq2im4(eWbRWvg7tXzrLSazwuNf9EV2AkqSnnGUYyFkolIZI4SmnZkQS490xHHSryCJr)yb16tsMvKSikROYI3tFfgYgHXngn4(eWbRzzAMfVN(kmKncdUpbCWkCLX(uCwMMzX7PVcdzJWG7tahScb(BZNRzrnOzX7PVcdz7WG7tahScb(BZNRzrCweJ8GNoJrE490xHTJWimcJ8qxw85kcHSta2nsaGKaSJ8aUx9uAyKhdtggmmsikkHm8PGSYceXsw34aF5Si9nlk59cV4yNXuM1krV)TcqwyFuYQ)Sp2SaKviUvAcgMgqHNkzzKcYIIDLUSSaKfLCpfLHgIYSyplk5Ekkdneu02AkauMfrgJgXW0ak8ujlcefKff7kDzzbilk3VkK(stGgIYSyplk3VkK(stGgckABnfakZIiJrJyyAafEQKLHLcYIIDLUSSaKfL7xfsFPjqdrzwSNfL7xfsFPjqdbfTTMcaLz1CwuKPirHzrKXOrmmnGcpvYIalfKff7kDzzbilk5EkkdneLzXEwuY9uugAiOOT1uaOmRMZIImfjkmlImgnIHPbu4PswgnsbzrXUsxwwaYIsUNIYqdrzwSNfLCpfLHgckABnfakZIiJrJyyAafEQKLrJuqwuSR0LLfGSOC)Qq6lnbAikZI9SOC)Qq6lnbAiOOT1uaOmlImgnIHPbu4PswgnSuqwuSR0LLfGSOK7POm0quMf7zrj3trzOHGI2wtbGYSiYy0igMgqHNkzz0WsbzrXUsxwwaYIY9RcPV0eOHOml2ZIY9RcPV0eOHGI2wtbGYSiYE0igMgqHNkzzeKuqwuSR0LLfGSOK7POm0quMf7zrj3trzOHGI2wtbGYSiYy0igMgKgyyYWGHrcrrjKHpfKvwGiwY6gh4lNfPVzrjGq2)jtzwRe9(3kazH9rjR(Z(yZcqwH4wPjyyAafEQKLDkilk2v6YYcqwuUFvi9LManeLzXEwuUFvi9LManeu02AkauMfrgJgXW0ak8ujl7uqwuSR0LLfGSOC)Qq6lnbAikZI9SOC)Qq6lnbAiOOT1uaOmlImgnIHPbu4Psw2PGSOyxPlllazrzWvG)XqdrzwSNfLbxb(hdneu02AkauMfrgJgXW0ak8ujl7uqwuSR0LLfGSOe7)P1PaqdrzwSNfLy)pTofaAiOOT1uaOmlImgnIHPbu4PswGKcYIIDLUSSaKfL8E6RWqJqdrzwSNfL8E6RWq2i0quMfrrx0igMgqHNkzbskilk2v6YYcqwuY7PVcdTdneLzXEwuY7PVcdz7qdrzwezKafnIHPbu4PswrhfKff7kDzzbilk590xHHgHgIYSyplk590xHHSrOHOmlImsGIgXW0ak8ujROJcYIIDLUSSaKfL8E6RWq7qdrzwSNfL8E6RWq2o0quMfrrx0igMgKgyyYWGHrcrrjKHpfKvwGiwY6gh4lNfPVzr5Gvc(OvZuM1krV)TcqwyFuYQ)Sp2SaKviUvAcgMgqHNkzzNcYIIDLUSSaKfL7xfsFPjqdrzwSNfL7xfsFPjqdbfTTMcaLz1CwuKPirHzrKXOrmmnGcpvYIarbzrXUsxwwaYIsUNIYqdrzwSNfLCpfLHgckABnfakZQ5SOitrIcZIiJrJyyAafEQKv0rbzrXUsxwwaYIsUNIYqdrzwSNfLCpfLHgckABnfakZIiJrJyyAafEQKv0NcYIIDLUSSaKfLCpfLHgIYSyplk5Ekkdneu02AkauMfrgJgXW0G0adtggmmsikkHm8PGSYceXsw34aF5Si9nlkXmLzTs07FRaKf2hLS6p7JnlazfIBLMGHPbu4PswgPGSOyxPlllazrj3trzOHOml2ZIsUNIYqdbfTTMcaLzrKXOrmmnGcpvYYWsbzrXUsxwwaYIY9RcPV0eOHOml2ZIY9RcPV0eOHGI2wtbGYSAolkYuKOWSiYy0igMgqHNkzbskilk2v6YYcqwuUFvi9LManeLzXEwuUFvi9LManeu02AkauMfrgJgXW0ak8ujlJ2PGSOyxPlllazrj3trzOHOml2ZIsUNIYqdbfTTMcaLzrK9OrmmnGcpvYYOHLcYIIDLUSSaKfLCpfLHgIYSyplk5Ekkdneu02AkauMfr2JgXW0ak8ujlJgwkilk2v6YYcqwuUFvi9LManeLzXEwuUFvi9LManeu02AkauMfrgJgXW0ak8ujlJGKcYIIDLUSSaKfLCpfLHgIYSyplk5Ekkdneu02AkauMfrgJgXW0ak8ujlJrhfKff7kDzzbilk5EkkdneLzXEwuY9uugAiOOT1uaOmlIShnIHPbu4Psw2nsbzrXUsxwwaYIsUNIYqdrzwSNfLCpfLHgckABnfakZIi7rJyyAafEQKLDJuqwuSR0LLfGSOC)Qq6lnbAikZI9SOC)Qq6lnbAiOOT1uaOmlImgnIHPbGiwYI0Nth8P0YQ)BJZcSSswFSaK1PzXXswDGpxZAEyolRpNfyzLSuNZI0)kqwNMfhlz1aaUMfqZTvJfkinilQKL00Mc3txXO8(fusp8XPbPbgMmmyyKquucz4tbzLfiILSUXb(Yzr6BwuY7PVcJPmRvIE)BfGSW(OKv)zFSzbiRqCR0emmnGcpvYcKuqwuSR0LLfGSEUrkolSnL7OLffrwSNff(7Sao6h(CnlFGSn7BweryIZIiqgnIHPbu4PswGKcYIIDLUSSaKfL8E6RWqJqdrzwSNfL8E6RWq2i0quMfr2ngnIHPbu4PswGKcYIIDLUSSaKfL8E6RWq7qdrzwSNfL8E6RWq2o0quMfr2JUOrmmnGcpvYk6OGSOyxPlllaz9CJuCwyBk3rllkISyplk83zbC0p85Aw(azB23SiIWeNfrGmAedtdOWtLSIokilk2v6YYcqwuY7PVcdncneLzXEwuY7PVcdzJqdrzwezp6IgXW0ak8ujROJcYIIDLUSSaKfL8E6RWq7qdrzwSNfL8E6RWq2o0quMfr2ngnIHPbPbu0Xb(YcqwrxwDGpxZAEygdtdqEWdKacHSdsdlYZG1jVPG8qGtGNfbM9(IhBfhFdYIadFLLnnGaNapld(QKL9O)WzzNaSBmninOd85kgoyLGpA1mbbLWwoZtbaLC22eaWNsdL9ODAAqh4ZvmCWkbF0QzcckH5Er5Thm8rc6(vH0xAce7)jPV0euz0swCAqh4ZvmCWkbF0QzcckHb8V1uq5EWWdwj0ygLVrbuJeWWhjODGp6cQOY4jyQnAAgvWPlARm812ETgjkUNIYq6(Ck2sd6aFUIHdwj4Jwntqqjm9EV2AkdR9OaQWKOdwj0yEy698lGofAIc0RnO00Mc3txXO8(fusp8XqrBRPaeblmFknmuAAtH7PROyW9aOOT1uasd6aFUIHdwj4JwntqqjmVFbh78Wdwj0ygvysuj69VbGAC4bReAmJIXKOBRVGg9hEWkHgZO8nkGAF4Jeu69ET1uGctIoyLqJ50GoWNRy4Gvc(OvZeeuc33OaGIJDE4Je0oWhDbvuz8e8qeOiefvWPlARm812ETgjkUNIYq6(Ck2mn7aF0furLXtWdzN4irrV3RTMcuys0bReAmNg0b(CfdhSsWhTAMGGsymlnGnuCSZdFKG2b(OlOIkJNGP2UPjrbNUOTYWxB71QPj3trziDFofBehPd8rxqfvgpbdQDtt69ET1uGctIoyLqJ50G0GoWNRycckHd(xzzrXXoNg0b(CftqqjCW)kllko25HNNkObaqjqeWWhjO7xfsFPjqSmi(B4HrhSEy2JnFUAAI9)06uaOE2Amk7(eJoWpSRMMefCf4FmCf6YI7jQtIs6l)vjsu7xfsFPjqSmi(B4HrhSEy2JnFUsCAabEwg(EwDS0az1kqwGyBn69V5z4jzridZO4SevgpbtGXSalzb4kLCwaEwC8HZI03SgmBBYIZYsc9hlzDmLazzjzXUNfEqpoAlRwbYcSKvOvk5SwPbUPTSaX2A0ll8ajCKxilRpjjgMg0b(CftqqjmVTg9(38m8oLgko25HpsqJI7LMWWdJoy22KnnGapldZXswC8HZY1ScUpbCWAwhzwhtjolowYY1PTSCLkFSaZIIsMLn)NvCtxYQvNJLnlxPYhlzb(44S6SMUst2ScUpbCW6WzH5o8Mfh3CwGpoolqSFbh7CwGJfnlowUnRG7tahSIZk4k58c8WzH9Sa3hN1x5BM1XuIZY1ScUpbCWAwSN1hlzXXhE4SCowwWhwYk4kF6xYI9S(yjlxZk4(eWbRW0GoWNRycckH)yb9yzCyThfqbwPbiVvqPlySmtdiWZIIsMfhlzX7PVcNvCJZQZYvQ8XswwFsYHZcBtdzDCwGpoolqSFbh7mmlkkzwmypRELSc(4aHpLwwK(MvNfi2VGJDolSnnmCwFSKfhlzH51vAYMLRu5JLSessjWWSOOKz1AwUsLpwYY6tsM1HZALgWwwwFoRwDow2SW86knzZYvQ8XswwFsYSaFZzw9e7zzjzTsdylllBzXXsw8nkzbI9l4yNZk4JcolRo8MLtsMvW9jGdwhoRpwY64SoYS4yjlCCVcqw8E6RWzfCFc4G1Sa7kLCwNYYskRKf4JJZIJLS(dc(4P0Yce7xWXoNf2MgGzrrjZQ1SCLkFSKL1NKmRG)Nazzjz9XcqwTcKfMV5mRGpkzz1H3Si9nRolYp)xjlqSFbh78Wz9XswhdZIIsMvNL6kvS(KKz5kv(yjRdN1knGTHZ6JLSooRJmRJZcSRuYzDkllPSswGpooRbolkF9mlxPYhlzz9jjXzXRTtPLf7zbI9l4yNZcBtdz5BwhzwCSKLZXYMfVN(kCwhwPKZQ1SCLkFSmCwhoRol1vQy9jjZYvQ8XswGpooRoRPR0KnRG7tahSoCw(M1Hvk5SwPbSbZIIsMfhlzrE0I5SoCw08tPLf7zjkqwwcPVsw28)MLkrJZce7xWXopCwgU(yolm3lN1hFkTS490xHXzXEwJ9RKf(VswCSyllAcN1hlaW0GoWNRycckH590xHno8rckVN(km0imUXOFSGA9jjJqK1NKeY7xWXod)dIquu8E6RWq7W4gJ(XcQ1NK00K3tFfgAhgCFc4Gv4kJ9PyttEp9vyOryW9jGdwHa)T5ZvQbL3tFfgAhgCFc4GviWFB(CLyttRpjjK3VGJDgc4G1ieX7PVcdTdJBm6hlOwFsYi8E6RWq7WG7tahScb(BZNRudkVN(km0im4(eWbRqG)285AeEp9vyODyW9jGdwHRm2NIPcihk4(eWbRqE)co2z4kJ9P4ib3NaoyfY7xWXodxzSpftTDcW0K3tFfgAegCFc4GviWFB(CLkGCOG7tahSc59l4yNHRm2NIj20K7LMWq(gfu2rbozOG7tahSc59l4yNHRm2NIj20mkEp9vyOryCJr)yb16tsgHiEp9vyODyCJr)yb16tsgHiRpjjK3VGJDgc4GvttEp9vyODyW9jGdwHRm2NIPgKehHOG7tahSc59l4yNHRm2NIP2obyAY7PVcdTddUpbCWkCLX(umvaj1b3NaoyfY7xWXodxzSpftSPzu8E6RWq7W4gJ(XcQ1NKmcrrX7PVcdTdJBmAW9jGdwnn590xHH2Hb3Naoyfc83MpxPguEp9vyOryW9jGdwHa)T5ZvttEp9vyODyW9jGdwHRm2NIjM40GoWNRycckH590xHTp8rckVN(km0omUXOFSGA9jjJqK1NKeY7xWXod)dIquu8E6RWqJW4gJ(XcQ1NK00K3tFfgAegCFc4Gv4kJ9PyttEp9vyODyW9jGdwHa)T5ZvQbL3tFfgAegCFc4GviWFB(CLyttRpjjK3VGJDgc4G1ieX7PVcdncJBm6hlOwFsYi8E6RWqJWG7tahScb(BZNRudkVN(km0om4(eWbRqG)285AeEp9vyOryW9jGdwHRm2NIPcihk4(eWbRqE)co2z4kJ9P4ib3NaoyfY7xWXodxzSpftTDcW0K3tFfgAhgCFc4GviWFB(CLkGCOG7tahSc59l4yNHRm2NIj20K7LMWq(gfu2rbozOG7tahSc59l4yNHRm2NIj20mkEp9vyODyCJr)yb16tsgHiEp9vyOryCJr)yb16tsgHiRpjjK3VGJDgc4GvttEp9vyOryW9jGdwHRm2NIPgKehHOG7tahSc59l4yNHRm2NIP2obyAY7PVcdncdUpbCWkCLX(umvaj1b3NaoyfY7xWXodxzSpftSPzu8E6RWqJW4gJ(XcQ1NKmcrrX7PVcdncJBmAW9jGdwnn590xHHgHb3Naoyfc83MpxPguEp9vyODyW9jGdwHa)T5ZvttEp9vyOryW9jGdwHRm2NIjM40GoWNRycckH)yb9yzep8rcQ1NKeY7xWXod)dmnT(KKqE)co2ziGdwJeCFc4GviVFbh7mCLX(um12jattYJwmJUYyFkEOG7tahSc59l4yNHRm2NItdiWjWZIqcyzZYWbAmlEp9v4SMoTlKf4BoZALO3)wjlSpkz1aahFU2ZSae6Y0hmkkdtdiWjWZQd85kMGGs4qpNODGpxrNhMhw7rbuEp9vy8WhjObNUOTYWxB71AKG7tahSc59l4yNHRm2NIJeCFc4Gv4kyxB(uAO9Uoy4kJ9PytZOcoDrBLHV22R1ib3NaoyfY7xWXodxzSpfNg0b(CftqqjCONt0oWNROZdZdR9OaAaaNg0b(CftqqjCONt0oWNROZdZdR9OakMh(ibTd8rxqfvgpbpebknOd85kMGGs4qpNODGpxrNhMhw7rbuEVWlo2z8WhjODGp6cQOY4jyQTNgKg0b(CfddayqTKfl77P0g(ib16tsc59l4yNH)bMMKhTygDLX(u8qgjqPbDGpxXWaaMGGsyRP7aOK)12WhjOwFssiVFbh7m8pW0K8OfZORm2NIhYy0Lg0b(CfddaycckHBniyE7jAONZHpsqT(KKqE)co2z4FGPj5rlMrxzSpfpKXOlnOd85kggaWeeuctERynDhy4JeuRpjjK3VGJDg(hyAsE0Iz0vg7tXdz4Kg0b(CfddaycckHNhTygJA46dqBuuE4JeuRpjjK3VGJDgc4G10GoWNRyyaatqqj8aNpxh(ib16tsc59l4yNH)brS(KKqRP7aZpMH)bMMwFssiVFbh7m8pic3lnHHXsp5y4GapKDcW0K8OfZORm2NIhYE0LgKg0b(CfdXmOywAaBO4yNh(ibL7POmeZsdydL0dFCeIgScDuAbaOriMLgWgko25iwFssiMLgWgkPh(y4kJ9P4HaPPP1NKeIzPbSHs6Hpgc4GvItd6aFUIHyMGGs43BorXXoNg0b(CfdXmbbLWa(3AkOCpy4Je0Gtx0wz4RT9AnsW9jGdwHRGDT5tPH276GHRm2NIhIwaW0mQGtx0wz4RT9AnsubNUOTYq9OfZOKTyAgC6I2kd1JwmJs2seIcUpbCWke8nbqXdU9ymCLX(u8q0caMMb3NaoyfY7xWXodxzSpftnibjXMMCV0egY3OGYokWjdzeKPbDGpxXqmtqqjm5Sxz45PcAaau7GC4JeuUxuE7bW)Gi7xfsFPjqS)NK(stqLrlzXPbDGpxXqmtqqjm3lkV9GHpsq3VkK(stGy)pj9LMGkJwYIJW9IYBpaUYyFkEiAbGib3Naoyfso7vGRm2NIhIwainOd85kgIzcckHLOny64JUGIJDonOd85kgIzcckHbFtau8GBpgNg0b(CfdXmbbLWKZ2MaGIJDonOd85kgIzcckHbKMJrdX972JdFKGs6HpMGHgZORqt0Hi9Whdh7OLg0b(CfdXmbbLWn64FbKf1jrdRdgNg0b(CfdXmbbLWRGDT5tPH276Gtd6aFUIHyMGGsy6(Ck2g(ibLiRpjjCfSRnFkn0Exhm8pW0mQGtx0wz4RT9A10K7POmCkCCprXXoJjocrwFss4GvchwqXXoJHaoy10mkUNIYWq8n2Y2O4yNnn7aF0furLXtWdzN40GoWNRyiMjiOeM3VGJDE4JeuRpjjCWkHdlO4yNXqahSAAA9jjHRGDT5tPH276GH)bMMwFssi4BcGIhC7Xy4FGPP1NKes3NtXg8pish4JUGkQmEcMAJPbDGpxXqmtqqj82doauYBLHpsq3VkK(stG4)s7uAO4yNXr4EkkdX8k948ujcrb3NaoyfUc21MpLgAVRdgUYyFkMAJeGPzubNUOTYWxB71QPj3trz4u44EIIJDgtCAqh4ZvmeZeeuc33OaGIJDE4GTWuq5EPjmguJdFKGA9jjHdwjCybfh7mgc4GvttIS(KKqE)co2z4FGPj5Forxje3lnbLVrziAbacgAmJY3OqCeIII7POmmeFJTSnko2ztZoWhDbvuz8e8q2j2006tsc59cVO4yNXWvg7tXulrtcFwq5BuI0b(OlOIkJNGP2yAqh4ZvmeZeeucV9GdaL8wz4JeuIcUpbCWkCfSRnFkn0ExhmCLX(um1gjatZOcoDrBLHV22RvttUNIYWPWX9efh7mM4iKE4JjyOXm6k0eDisp8XWXoArS(KKqPPnfUNUIr59lOKE4JHaoyncrwFssiG)TMck3dGaoy10K7POmeZR0JZtfItd6aFUIHyMGGs4q8n2Y2O4yNh(ib16tschSs4Wcko2zm8pW0K0dFm1bhZeSd85kSVrbafh7mm4yonOd85kgIzcckH7n0QGIJDE4JeuRpjjCWkHdlO4yNXW)attsp8XuhCmtWoWNRW(gfauCSZWGJ50GoWNRyiMjiOegl7arzumFkTHd2ctbL7LMWyqno8rc6kKRGJBRPeH7LMWq(gfu2rboHAG)285AAqh4ZvmeZeeucB1720KHpsq7aF0furLXtWuBmnOd85kgIzcckH3EWbGsERm8rckrb3NaoyfUc21MpLgAVRdgUYyFkMAJeqK9RcPV0ei(V0oLgko2zSPzubNUOTYWxB71QPj3trz4u44EIIJDgtCesp8Xem0ygDfAIoePh(y4yhTiez9jjHa(3AkOCpac4GvttUNIYqmVspopvionOd85kgIzcckHTAAOojkVx4fp8rcQ1NKeY7xWXodbCWAAqh4ZvmeZeeucJzPbSHIJDoninOd85kgY7fEXXoJbfZsdydfh78WhjOCpfLHywAaBOKE4JJCkk58OfZrS(KKqmlnGnusp8XWvg7tXdbY0GoWNRyiVx4fh7mMGGsya)BnfuUhm8rcAWPlARm812ETgj4(eWbRWvWU28P0q7DDWWvg7tXdrlayAgvWPlARm812ETgjQGtx0wzOE0IzuYwmndoDrBLH6rlMrjBjcrb3Naoyfc(MaO4b3EmgUYyFkEiAbatZG7tahSc59l4yNHRm2NIPgKGKyttUxAcd5Buqzhf4KHmsaPbDGpxXqEVWlo2zmbbLWCVO82dg(ibD)Qq6lnbI9)K0xAcQmAjloc3lkV9a4kJ9P4HOfaIeCFc4Gvi5SxbUYyFkEiAbG0GoWNRyiVx4fh7mMGGsyYzVYWZtf0aaO2b5WhjOCVO82dG)br2VkK(stGy)pj9LMGkJwYItd6aFUIH8EHxCSZycckHLOny64JUGIJDonOd85kgY7fEXXoJjiOeg8nbqXdU9yCAqh4ZvmK3l8IJDgtqqj8kyxB(uAO9Uo40GoWNRyiVx4fh7mMGGsy6(Ck2g(ib16tscxb7AZNsdT31bd)dmnJk40fTvg(ABVwnn5EkkdNch3tuCSZ40GoWNRyiVx4fh7mMGGsyRE3MMKg0b(Cfd59cV4yNXeeucZ7xWXoNg0b(Cfd59cV4yNXeeucV9GdaL8wz4Je09RcPV0ei(V0oLgko2zCeIcUpbCWkCfSRnFkn0ExhmCLX(um1gjatZOcoDrBLHV22RvttUNIYWPWX9efh7mM4iwFssiVx4ffh7mgUYyFkMAqLOjHplO8nkPbDGpxXqEVWlo2zmbbLW9nkaO4yNhoylmfuUxAcJb14WhjOwFssiVx4ffh7mgUYyFkMAqLOjHplO8nkriY6tschSs4Wcko2zmeWbRMMK)5eDLqCV0eu(gLHcnMr5BuiiTaGPP1NKeY7xWXod)dionOd85kgY7fEXXoJjiOegqAogne3VBpo8rckPh(ycgAmJUcnrhI0dFmCSJwAqh4ZvmK3l8IJDgtqqj82doauYBLHpsqjk4(eWbRWvWU28P0q7DDWWvg7tXuBKaISFvi9LMaX)L2P0qXXoJnnJk40fTvg(ABVwnnJA)Qq6lnbI)lTtPHIJDgBAY9uugofoUNO4yNXehX6tsc59cVO4yNXWvg7tXudQenj8zbLVrjnOd85kgY7fEXXoJjiOeE8p5dh78WhjOwFssiVx4ffh7mgc4GvttRpjjCWkHdlO4yNXW)GiKE4JPo4yMGDGpxH9nkaO4yNHbhZrikkUNIYWq8n2Y2O4yNnn7aF0furLXtWutGionOd85kgY7fEXXoJjiOeoeFJTSnko25HpsqT(KKWbReoSGIJDgd)dIq6HpM6GJzc2b(Cf23OaGIJDggCmhPd8rxqfvgpbpKHnnOd85kgY7fEXXoJjiOe(9MtuCSZdFKGA9jjHasdGk2eiGdwtd6aFUIH8EHxCSZycckHB0X)cilQtIgwhmonOd85kgY7fEXXoJjiOeMC22eauCSZPbDGpxXqEVWlo2zmbbLWyzhikJI5tPnCWwykOCV0egdQXHpsqxHCfCCBnL0GoWNRyiVx4fh7mMGGs4X)KpCSZdFKGs6HpM6GJzc2b(Cf23OaGIJDggCmNg0b(Cfd59cV4yNXeeucB10qDsuEVWlE4JeuRpjjK3VGJDgc4G10GoWNRyiVx4fh7mMGGsymlnGnuCSZPbPbDGpxXqEp9vymO079ARPmS2JcOyBAa9pyy698lGA9jjHRGDT5tPH276GH)bMMwFssiVFbh7m8pinOd85kgY7PVcJjiOeMEVxBnLH1EuafZRR0qX20a6FWW075xan40fTvg(ABVwJy9jjHRGDT5tPH276GH)brS(KKqE)co2z4FGPzubNUOTYWxB71AeRpjjK3VGJDg(hKg0b(Cfd590xHXeeuctV3RTMYWApkGI51vAOyBAaDLX(u8W(aqXcFKdhCf44ZvqdoDrBLHV22R1HP3ZVaAW9jGdwHRGDT5tPH276GHRm2NIhYWDW9jGdwH8(fCSZWvg7tXdtVNFbvMyb0G7tahSc59l4yNHRm2NItd6aFUIH8E6RWycckHP371wtzyThfqX20a6kJ9P4H9bGIf(iho4kWXNRGgC6I2kdFTTxRdtVNFb0G7tahScxb7AZNsdT31bdxzSpftTH7G7tahSc59l4yNHRm2NIhMEp)cQmXcOb3NaoyfY7xWXodxzSpfNg0b(Cfd590xHXeeuc)Xc6XYiEy80zmO8E6RWgh(ibLiEp9vyOryCJr)yb16tsAAgC6I2kdFTTxRr490xHHgHXngn4(eWbRehHi69ET1uGyEDLgk2Mgq)dIquubNUOTYWxB71AKO490xHH2HXng9JfuRpjPPzWPlARm812ETgjkEp9vyODyCJrdUpbCWQPjVN(km0om4(eWbRWvg7tXMM8E6RWqJW4gJ(XcQ1NKmcrrX7PVcdTdJBm6hlOwFssttEp9vyOryW9jGdwHa)T5ZvQbL3tFfgAhgCFc4GviWFB(CLyttEp9vyOryCJrdUpbCWAKO490xHH2HXng9JfuRpjzeEp9vyOryW9jGdwHa)T5ZvQbL3tFfgAhgCFc4GviWFB(CLytZOO371wtbI51vAOyBAa9picrrX7PVcdTdJBm6hlOwFsYieX7PVcdncdUpbCWke4VnFUsfqoe9EV2AkqSnnGUYyFk20KEVxBnfi2MgqxzSpftnVN(km0im4(eWbRqG)285kfHDInn590xHH2HXng9JfuRpjzeI490xHHgHXng9JfuRpjzeEp9vyOryW9jGdwHa)T5ZvQbL3tFfgAhgCFc4GviWFB(Cncr8E6RWqJWG7tahScb(BZNRubKdrV3RTMceBtdORm2NInnP371wtbITPb0vg7tXuZ7PVcdncdUpbCWke4VnFUsryNyttIII3tFfgAeg3y0pwqT(KKMM8E6RWq7WG7tahScb(BZNRudkVN(km0im4(eWbRqG)285kXriI3tFfgAhgCFc4Gv4knGTi8E6RWq7WG7tahScb(BZNRubKutV3RTMceBtdORm2NIJqV3RTMceBtdORm2NIhI3tFfgAhgCFc4GviWFB(CLIWUPzu8E6RWq7WG7tahScxPbSfHiEp9vyODyW9jGdwHRm2NIPcihIEVxBnfiMxxPHITPb0vg7tXrO371wtbI51vAOyBAaDLX(um12jGieX7PVcdncdUpbCWke4VnFUsfqoe9EV2AkqSnnGUYyFk20K3tFfgAhgCFc4Gv4kJ9PyQaYHO371wtbITPb0vg7tXr490xHH2Hb3Naoyfc83MpxPciji9EV2AkqSnnGUYyFkEi69ET1uGyEDLgk2MgqxzSpfBAsV3RTMceBtdORm2NIPM3tFfgAegCFc4GviWFB(CLIWUPj9EV2AkqSnnG(hqSPjVN(km0om4(eWbRWvg7tXubKutV3RTMceZRR0qX20a6kJ9P4ieX7PVcdncdUpbCWke4VnFUsfqoe9EV2AkqmVUsdfBtdORm2NInnJI3tFfgAeg3y0pwqT(KKriIEVxBnfi2MgqxzSpftnVN(km0im4(eWbRqG)285kfHDtt69ET1uGyBAa9pGyIjMyIj20K7LMWq(gfu2rbozi69ET1uGyBAaDLX(umXMMrX7PVcdncJBm6hlOwFsYirfC6I2kdFTTxRriI3tFfgAhg3y0pwqT(KKriIOOO371wtbITPb0)attEp9vyODyW9jGdwHRm2NIPgKehHi69ET1uGyBAaDLX(um12jattEp9vyODyW9jGdwHRm2NIPciPMEVxBnfi2MgqxzSpftmXMMrX7PVcdTdJBm6hlOwFsYieffVN(km0omUXOb3Naoy10K3tFfgAhgCFc4Gv4kJ9PyttEp9vyODyW9jGdwHa)T5ZvQbL3tFfgAegCFc4GviWFB(CLyItd6aFUIH8E6RWycckH)yb9yzepmE6mguEp9vy7dFKGseVN(km0omUXOFSGA9jjnndoDrBLHV22R1i8E6RWq7W4gJgCFc4GvIJqe9EV2AkqmVUsdfBtdO)brikQGtx0wz4RT9Ansu8E6RWqJW4gJ(XcQ1NK00m40fTvg(ABVwJefVN(km0imUXOb3Naoy10K3tFfgAegCFc4Gv4kJ9PyttEp9vyODyCJr)yb16tsgHOO490xHHgHXng9JfuRpjPPjVN(km0om4(eWbRqG)285k1GY7PVcdncdUpbCWke4VnFUsSPjVN(km0omUXOb3Naoynsu8E6RWqJW4gJ(XcQ1NKmcVN(km0om4(eWbRqG)285k1GY7PVcdncdUpbCWke4VnFUsSPzu079ARPaX86knuSnnG(heHOO490xHHgHXng9JfuRpjzeI490xHH2Hb3Naoyfc83MpxPcihIEVxBnfi2MgqxzSpfBAsV3RTMceBtdORm2NIPM3tFfgAhgCFc4GviWFB(CLIWoXMM8E6RWqJW4gJ(XcQ1NKmcr8E6RWq7W4gJ(XcQ1NKmcVN(km0om4(eWbRqG)285k1GY7PVcdncdUpbCWke4VnFUgHiEp9vyODyW9jGdwHa)T5ZvQaYHO371wtbITPb0vg7tXMM079ARPaX20a6kJ9PyQ590xHH2Hb3Naoyfc83MpxPiStSPjrrX7PVcdTdJBm6hlOwFssttEp9vyOryW9jGdwHa)T5ZvQbL3tFfgAhgCFc4GviWFB(CL4ieX7PVcdncdUpbCWkCLgWweEp9vyOryW9jGdwHa)T5ZvQasQP371wtbITPb0vg7tXrO371wtbITPb0vg7tXdX7PVcdncdUpbCWke4VnFUsry30mkEp9vyOryW9jGdwHR0a2IqeVN(km0im4(eWbRWvg7tXubKdrV3RTMceZRR0qX20a6kJ9P4i079ARPaX86knuSnnGUYyFkMA7eqeI490xHH2Hb3Naoyfc83MpxPcihIEVxBnfi2MgqxzSpfBAY7PVcdncdUpbCWkCLX(umva5q079ARPaX20a6kJ9P4i8E6RWqJWG7tahScb(BZNRubKeKEVxBnfi2MgqxzSpfpe9EV2AkqmVUsdfBtdORm2NInnP371wtbITPb0vg7tXuZ7PVcdTddUpbCWke4VnFUsry30KEVxBnfi2Mgq)di20K3tFfgAegCFc4Gv4kJ9PyQasQP371wtbI51vAOyBAaDLX(uCeI490xHH2Hb3Naoyfc83MpxPcihIEVxBnfiMxxPHITPb0vg7tXMMrX7PVcdTdJBm6hlOwFsYierV3RTMceBtdORm2NIPM3tFfgAhgCFc4GviWFB(CLIWUPj9EV2AkqSnnG(hqmXetmXeBAY9styiFJck7OaNme9EV2AkqSnnGUYyFkMytZO490xHH2HXng9JfuRpjzKOcoDrBLHV22R1ieX7PVcdncJBm6hlOwFsYieruu079ARPaX20a6FGPjVN(km0im4(eWbRWvg7tXudsIJqe9EV2AkqSnnGUYyFkMA7eGPjVN(km0im4(eWbRWvg7tXubKutV3RTMceBtdORm2NIjMytZO490xHHgHXng9JfuRpjzeIII3tFfgAeg3y0G7tahSAAY7PVcdncdUpbCWkCLX(uSPjVN(km0im4(eWbRqG)285k1GY7PVcdTddUpbCWke4VnFUsmXimcJGa]] )

end