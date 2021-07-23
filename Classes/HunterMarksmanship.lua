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


    spec:RegisterPack( "Marksmanship", 20210723, [[d8uzqcqicQhrqQUeqLYMiIpHqgfG6uaYQaQu5vssnlGQUfcvTlq)cHYWis1XesldapdHktJGKUgrkBdOcFdOsghqf5CsIO1jjP3burLMNKW9aO9rK8pjrqhuseAHeepusIjcurvxKGuAJsIaFeOIYibQOItkjsSsKuZusu3eOsv2jqPFkjsAOeKIwkbj6Pc1ubk(kbPWyrsSxi(RknyvDyQwmr9ybtwIlJAZi1NruJgbNwXQbQuvVgjMTkUTKA3u(TOHtGJtqclxPNd10jDDiTDG8Dez8ijDEHy9sIuZNq7xQrIIagK4IRmcybq6aev6GlaioyuWL0bNeQGtiXAebmsSapqXjZiXMxZiXG75lfCTBycJaKybEKt6feWGeJt0nWiXc9(jOQaCvjgXipkbuzyiRjgEQrpUoPfwNwjgEQdedjwgDoALIHiJexCLralashGOshCbaXbJcUKo4KqfCHe7OkHCrIJN6QGetykf2qKrIlmoGedUNVuW1UHjmc6hCoOMYBtn1ONi9dG0bF)aiDaI2u3uxfcUrMXvTPM47hSmj6e1k9luY48aI7FW9BP2V3Fnhi42e6xjW97LsA9hCJyKMZP)A3CYmSPM47xOKXrSax63lL06xWo5oAK(jnkH(JN6Q0FLOqZkdrIpdwXiGbjw3jqbtivmcyqaBueWGeZMlF4cIqqId7O8oosS6h2uiwzVe5sNbumKnx(WL(L0)yx6ZqMG2VK(LrPPHyL9sKlDgqXWLR9XW9xr)sdj2d6KgsmwzVe5IjKkIIawaqadsmBU8HlicbjoSJY74iXlQX05sMHcs0aHBsFxVsN7LEDY1SPyiBU8Hl9lPFzuAAi9XJWl(w7lfiQaKypOtAiXuMZ5IjKkIIawIdbmiXS5YhUGieK4WokVJJeVOgtNlzgkirdeUj9D9kDUx61jxZMIHS5YhUGe7bDsdjM(4r4YftivefbScveWGeZMlF4cIqqId7O8oosmW9hsqS5McPezh36xs)HmpLKKbxgNMRJr(67MKGlx7JH7VI(jhk9lk2VW9hsqS5McPezh36xs)c3FibXMBk0gYe0lTZ9lk2FibXMBk0gYe0lTZ9lPFG7pK5PKKmiP5uUybZokgUCTpgU)k6NCO0VOy)HmpLKKbjnNYfly2rXWLR9XW9lv)eN07hO(ff7x9LmRqDQ5RM3YW9xr)rLE)II9hY8ussgCzCAUog5RVBscUCTpgUFP6pQ07xs)Eqhq8LnUEyC)s1pX1pq9lPFG7x4(xFkxgeBk0lfmKP6GvC)II9V(uUmi2uOxky4Y1(y4(LQ)kz)II9lC)HeeBUPqkr2XT(bcj2d6KgsCjrLp8vDbikcyLgcyqIzZLpCbriiXHDuEhhjErnMoxYmeNOh6CjZxUwMxmKnx(WL(L0V67vxxaC5AFmC)v0p5qPFj9hY8ussgK(4ldxU2hd3Ff9touqI9GoPHeR(E11fGOiGfCGagKy2C5dxqecsSh0jnKy6JVmsCyhL3XrIvFV66cGOc6xs)lQX05sMH4e9qNlz(Y1Y8IHS5YhUGeFgJVHcsmasdrral4cbmiXEqN0qIzQk4K4beFXesfjMnx(WfeHGOiGfCcbmiXS5YhUGieK4WokVJJelC)RpLldInf6LcgYuDWkUFrX(xFkxgeBk0lfmC5AFmC)s1FuP3VOy)Eqhq8LnUEyC)sby)RpLldInf6Lcggsut7hCx)aGe7bDsdjM0CkxSGzhfJOiGTsIagKy2C5dxqecsCyhL3XrIdzEkjjdUmonxhJ813njbxU2hd3Ff9tou6xs)a3VW9R(HnfYuvWjXdi(IjKkKnx(WL(ff7xgLMgkFYSCqXkevq)a1VOy)c3FibXMBkKsKDCRFrX(dzEkjjdUmonxhJ813njbxU2hd3Vu9hv69lk2VCIX9lPF6Hmb9UCTpgU)k6xAiXEqN0qIj5ZzmYxF3KeIIa2OshbmiXS5YhUGieK4WokVJJedC)HmpLKKbbLNdhbUCTpgU)k6NCO0VOy)c3V6h2uiO8C4iq2C5dx6xuSF1xYSc1PMVAEld3Ff9hfG(bQFj9dC)c3)6t5YGytHEPGHmvhSI7xuS)1NYLbXMc9sbdxU2hd3Vu9xj7xuSFpOdi(YgxpmUFPaS)1NYLbXMc9sbddjQP9dURFa6hiKypOtAiXlJtZ1XiF9DtsikcyJgfbmiXS5YhUGieK4WokVJJelJstdxgNMRJr(67MKGOc6xuSFH7pKGyZnfsjYoUHe7bDsdjguEoCeefbSrbabmiXEqN0qIL9DDYmsmBU8HlicbrraBuIdbmiXS5YhUGieK4WokVJJelJstdxgNMRJr(67MKGOc6xuS)qMNssYGlJtZ1XiF9DtsWLR9XW9lv)rLE)II9lC)HeeBUPqkr2XT(ff7xoX4(L0p9qMGExU2hd3Ff9dG0rI9GoPHeRlkJjKkIIa2OcveWGeZMlF4cIqqId7O8oos8IAmDUKzigDjpg5lMqQyiBU8Hl9lPFG7pK5PKKm4Y40CDmYxF3KeC5AFmC)s1FuP3VOy)c3FibXMBkKsKDCRFrX(fUF1pSPWsIkF4R6cGS5YhU0pq9lPFzuAAOUtGYftivmC5AFmC)sby)mv5aQYxDQzKypOtAiXRlykx6zzefbSrLgcyqIzZLpCbriiXEqN0qI9PMlxmHurId7O8oosSmknnu3jq5IjKkgUCTpgUFPaSFMQCav5Ro1C)s6h4(LrPPHcwomy(IjKkgwssw)II9tJEo3Lde8LmF1PM7VI(dowV6uZ9xD)KdL(ff7xgLMgQlkJjKkevq)aHehIeo8v9LmRyeWgfrraBuWbcyqIzZLpCbriiXHDuEhhjModO4(RU)GJ17YKzR)k6NodOyyTtvKypOtAiXf2vc3abNY61ikcyJcUqadsmBU8HlicbjoSJY74iXa3FiZtjjzWLXP56yKV(Ujj4Y1(y4(LQ)OsVFj9VOgtNlzgIrxYJr(IjKkgYMlF4s)II9lC)HeeBUPqkr2XT(ff7x4(xuJPZLmdXOl5XiFXesfdzZLpCPFrX(fUF1pSPWsIkF4R6cGS5YhU0pq9lPFzuAAOUtGYftivmC5AFmC)sby)mv5aQYxDQzKypOtAiXRlykx6zzefbSrbNqadsmBU8HlicbjoSJY74iXYO00qDNaLlMqQyyjjz9lk2VmknnuWYHbZxmHuXqub9lPF6mGI7xQ(djw7V6(9GoPb9PMlxmHuHHeR9lPFG7x4(v)WMcdeMANx)IjKkKnx(WL(ff73d6aIVSX1dJ7xQ(jU(bcj2d6KgsCn6rhmHurueWgTsIagKy2C5dxqecsCyhL3XrILrPPHcwomy(IjKkgIkOFj9tNbuC)s1FiXA)v3Vh0jnOp1C5IjKkmKyTFj97bDaXx246HX9xr)cvKypOtAiXbctTZRFXesfrralashbmiXS5YhUGieK4WokVJJelJstdlSxUCegwssgsSh0jnKykZ5CXesfrralarradsSh0jnKy)wJUfEVj9nSjjmsmBU8HlicbrralaaGagKypOtAiX0hpcxUycPIeZMlF4cIqqueWcaXHagKy2C5dxqecsSh0jnKymVcytVyDmYiXHDuEhhjEz6LXeC5dJehIeo8v9LmRyeWgfrralacveWGeZMlF4cIqqId7O8oosmDgqX9lv)HeR9xD)EqN0G(uZLlMqQWqI1(L0pW9hY8ussgCzCAUog5RVBscUCTpgUFP6xA9lk2VW9hsqS5McPezh36hiKypOtAiX1OhDWesfrralasdbmiXS5YhUGieK4WokVJJeVOgtNlzgAmgpgzs(gbF11fiymYxxGaFDffdzZLpCbj2d6KgsS67vxxaIIawaahiGbjMnx(WfeHGeh2r5DCK4f1y6CjZqJX4XitY3i4RUUabJr(6ce4RROyiBU8HliXEqN0qIPxMR0Jr(QRlarralaGleWGeZMlF4cIqqId7O8oosSmknnuxugtivyjjziXEqN0qILDY3K(Q7eOGrueWca4ecyqIzZLpCbriiXHDuEhhjgNOh5XkqbOyf9WxErfOtAq2C5dx6xs)YO00qDrzmHuHLKKHe7bDsdjM(WycH1PvefbSaujradsSh0jnKySYEjYftivKy2C5dxqecIIOiXfM2rpkcyqaBueWGe7bDsdjoKOMY7ftivKy2C5dxqecIIawaqadsmBU8Hlicbj2d6KgsCirnL3lMqQiXHDuEhhjErnMoxYmeZciGwPXxbBgoETRtAq2C5dx6xuSFCIEKhRaTjIJVAMh8vqo40GS5YhU0VOy)a3FiTc6OWLbXl2p3K(sNRIAmKnx(WL(L0VW9VOgtNlzgIzbeqR04RGndhV21jniBU8Hl9des8zm(gkiXeN0rueWsCiGbjMnx(WfeHGe7bDsdjwx3ekqNZuPhJ8ftivK4cJd7iqN0qIbNL97eyV0VBL(bZ6Mqb6CMkn3pyfAwL(zJRhgd((jX9xsJiT)s2VsyW9tNB)coEeEX9lZbhfZ9pkrL(L5(1m7hlWRRJ0VBL(jX9hCJiT)L9YCI0pyw3ek6hlGdd9e6xgLMgdrId7O8oosSW9R(sMv4GVcoEeErueWkuradsmBU8HlicbjoSJY74iXHeeBUPqkr2XT(L0FiZtjjzqDrzmHuHlx7JH7xs)HmpLKKbxgNMRJr(67MKGlx7JH7xuSFH7pKGyZnfsjYoU1VK(dzEkjjdQlkJjKkC5AFmmsSh0jnK4GFoxpOtA3ZGvK4ZG1R51msSUJrHvmIIawPHagKy2C5dxqecsSh0jnK4GFoxpOtA3ZGvK4ZG1R51msCOGrueWcoqadsmBU8HlicbjoSJY74iXEqhq8LnUEyC)v0pXHe7bDsdjo4NZ1d6K29myfj(my9AEnJeJvefbSGleWGeZMlF4cIqqId7O8oosSh0beFzJRhg3Vu9dasSh0jnK4GFoxpOtA3ZGvK4ZG1R51msSUtGcMqQyefrrIfSCiRLDfbmiGnkcyqI9GoPHelNQE4YL(4r4cPXiF1KQJHeZMlF4cIqqueWcacyqI9GoPHetFymHW60ksmBU8HlicbrralXHagKy2C5dxqecsCyhL3XrIxuJPZLmdXj6HoxY8LRL5fdzZLpCbj2d6KgsS67vxxaIIawHkcyqIzZLpCbriiXcwo4y9QtnJehv6iXEqN0qIljQ8HVQlajoSJY74iXEqhq8LnUEyC)s1F0(ff7x4(dji2CtHuISJB9lPFH7x9dBkeuEoCeiBU8HlikcyLgcyqIzZLpCbriiXPaKymRiXEqN0qIb574YhgjgKFqzK4dtMTIVrGSt(WQFsdF1fLV0zafdzZLpCPFj9JzvhJmgYo5dR(jTlMKlaYMlF4csCHXHDeOtAiXvHGBK5(1S)O9Rz)4Pg94k3VqlyQeqS44kb9tM9ftYf0pywugti1(fSCWXkejgKVxZRzKywPVcwo4yfrral4abmiXS5YhUGieK4WokVJJedY3XLpmKv6RGLdowrI9GoPHeRlkJjKkIIawWfcyqIzZLpCbriiXHDuEhhj2d6aIVSX1dJ7VI(jU(L0pW9lC)HeeBUPqkr2XT(L0VW9R(HnfckphocKnx(WL(ff73d6aIVSX1dJ7VI(bOFG6xs)c3piFhx(WqwPVcwo4yfj2d6KgsSp1C5IjKkIIawWjeWGeZMlF4cIqqId7O8oosSh0beFzJRhg3Vu9dq)II9dC)HeeBUPqkr2XT(ff7x9dBkeuEoCeiBU8Hl9du)s63d6aIVSX1dJ7hW(bOFrX(b574YhgYk9vWYbhRiXEqN0qIXk7LixmHuruefjouWiGbbSrradsmBU8HlicbjoSJY74iXa3VmknnuxugtiviQG(L0VmknnCzCAUog5RVBscIkOFj9hsqS5McPezh36hO(ff7h4(LrPPH6IYycPcrf0VK(LrPPHKMt5Ifm7OyiQG(L0FibXMBk0gYe0lTZ9du)II9dC)HeeBUPqqSPeIS9lk2FibXMBk04WMNCl9du)s6xgLMgQlkJjKkevq)II9lNyC)s6NEitqVlx7JH7VI(JsC9lk2pW9hsqS5McPezh36xs)YO00WLXP56yKV(UjjiQG(L0p9qMGExU2hd3Ff9dUiU(bcj2d6KgsSmVyEPmgzefbSaGagKy2C5dxqecsCyhL3XrILrPPH6IYycPcrf0VOy)HmpLKKb1fLXesfUCTpgUFP6N4KE)II9lNyC)s6NEitqVlx7JH7VI(JcoqI9GoPHelFYSCPr3iikcyjoeWGeZMlF4cIqqId7O8oosSmknnuxugtiviQG(ff7pK5PKKmOUOmMqQWLR9XW9lv)eN07xuSF5eJ7xs)0dzc6D5AFmC)v0FuWbsSh0jnKy3cmwx)Cd(5GOiGvOIagKy2C5dxqecsCyhL3XrILrPPH6IYycPcrf0VOy)HmpLKKb1fLXesfUCTpgUFP6N4KE)II9lNyC)s6NEitqVlx7JH7VI(RKiXEqN0qIPNLLpzwqueWkneWGeZMlF4cIqqId7O8oosSmknnuxugtivyjjziXEqN0qIpdzck(cUpAHCnBkIIawWbcyqIzZLpCbriiXHDuEhhjwgLMgQlkJjKkevq)s6h4(LrPPHYNmlhuScrf0VOy)QVKzfsG9JsakiO9xr)ai9(bQFrX(LtmUFj9tpKjO3LR9XW9xr)aao6xuSFG7pKGyZnfsjYoU1VK(LrPPHlJtZ1XiF9Dtsqub9lPF6Hmb9UCTpgU)k6hCbq)aHe7bDsdjwqQtAikIIeJveWGa2OiGbjMnx(WfeHGeh2r5DCKy1pSPqSYEjYLodOyiBU8Hl9lPFG7xWYGUKdfyuiwzVe5IjKA)s6xgLMgIv2lrU0zafdxU2hd3Ff9lT(ff7xgLMgIv2lrU0zafdljjRFG6xs)a3VmknnCzCAUog5RVBscwssw)II9lC)HeeBUPqkr2XT(bcj2d6KgsmwzVe5IjKkIIawaqadsSh0jnKykZ5CXesfjMnx(WfeHGOiGL4qadsmBU8HlicbjoSJY74iXa3FibXMBkKsKDCRFj9dC)HmpLKKbxgNMRJr(67MKGlx7JH7VI(jhk9du)II9lC)HeeBUPqkr2XT(L0VW9hsqS5McTHmb9s7C)II9hsqS5McTHmb9s7C)s6h4(dzEkjjdsAoLlwWSJIHlx7JH7VI(jhk9lk2FiZtjjzqsZPCXcMDumC5AFmC)s1pXj9(bQFrX(PhYe07Y1(y4(RO)OsRFG6xs)a3VW9V(uUmi2uOxkyit1bR4(ff7F9PCzqSPqVuWqub9lPFG7F9PCzqSPqVuWWX6VI(Jk9(L0)6t5YGytHEPGHlx7JH7VI(jU(ff7F9PCzqSPqVuWWX6xQ(9GoPDdzEkjjRFrX(9GoG4lBC9W4(LQ)O9du)II9lC)RpLldInf6LcgIkOFj9dC)RpLldInf6Lcggsut7hW(J2VOy)RpLldInf6Lcgow)s1Vh0jTBiZtjjz9du)aHe7bDsdjUKOYh(QUaefbScveWGeZMlF4cIqqId7O8oosS67vxxaevq)s6FrnMoxYmeNOh6CjZxUwMxmKnx(WfKypOtAiX0hFzefbSsdbmiXS5YhUGieK4WokVJJeVOgtNlzgIt0dDUK5lxlZlgYMlF4s)s6x99QRlaUCTpgU)k6NCO0VK(dzEkjjdsF8LHlx7JH7VI(jhkiXEqN0qIvFV66cqueWcoqadsSh0jnKyMQcojEaXxmHurIzZLpCbriikcybxiGbjMnx(WfeHGeh2r5DCKyH7F9PCzqSPqVuWqMQdwX9lk2VW9V(uUmi2uOxkyiQG(L0)6t5YGytHEPGHf011jT(RU)1NYLbXMc9sbdhR)k6haP3VOy)RpLldInf6LcgIkOFj9V(uUmi2uOxky4Y1(y4(LQ)OvY(ff73d6aIVSX1dJ7xQ(JIe7bDsdjM0CkxSGzhfJOiGfCcbmiXEqN0qIPpEeUCXesfjMnx(WfeHGOiGTsIagKy2C5dxqecsCyhL3XrIPZakU)Q7p4y9Umz26VI(PZakgw7ufj2d6KgsCHDLWnqWPSEnIIa2OshbmiXEqN0qI9Bn6w49M03WMKWiXS5YhUGieefbSrJIagKy2C5dxqecsCyhL3XrIdzEkjjdUmonxhJ813njbxU2hd3Ff9tou6xs)a3VW9R(HnfYuvWjXdi(IjKkKnx(WL(ff7xgLMgkFYSCqXkevq)a1VOy)c3FibXMBkKsKDCRFrX(dzEkjjdUmonxhJ813njbxU2hd3VOy)Yjg3VK(PhYe07Y1(y4(ROFPHe7bDsdjMKpNXiF9DtsikcyJcacyqIzZLpCbriiXHDuEhhjg4(LrPPHLev(Wx1farf0VOy)c3V6h2uyjrLp8vDbq2C5dx6xuSF5eJ7xs)0dzc6D5AFmC)v0Fua6hO(L0pW9lC)RpLldInf6LcgYuDWkUFrX(fU)1NYLbXMc9sbdrf0VK(bU)1NYLbXMc9sbdlORRtA9xD)RpLldInf6Lcgow)v0FuP3VOy)RpLldInf6Lcggsut7hW(J2pq9lk2)6t5YGytHEPGHOc6xs)RpLldInf6LcgUCTpgUFP6Vs2VOy)Eqhq8LnUEyC)s1F0(bcj2d6Kgs8Y40CDmYxF3KeIIa2OehcyqIzZLpCbriiXHDuEhhjwgLMgUmonxhJ813njbrf0VOy)c3FibXMBkKsKDCRFj9dC)YO00qblhgmFXesfdljjRFrX(fUF1pSPWaHP251VycPczZLpCPFrX(9GoG4lBC9W4(ROFa6hiKypOtAiXGYZHJGOiGnQqfbmiXS5YhUGieK4WokVJJehsqS5McPezh36xs)0zaf3F19hCSExMmB9xr)0zafdRDQ2VK(bUFG7pK5PKKm4Y40CDmYxF3KeC5AFmC)v0p5qPFWD9tC9lPFG7x4(Xj6rEScKPPrXdi(62u7xpe4dVUMlKnx(WL(ff7x4(v)WMcljQ8HVQlaYMlF4s)a1pq9lk2V6h2uyjrLp8vDbq2C5dx6xs)HmpLKKbljQ8HVQlaUCTpgU)k6N46hiKypOtAiXyL9sKlMqQikcyJkneWGeZMlF4cIqqId7O8oosSmknnuWYHbZxmHuXWssY6xs)a3FibXMBkeeBkHiB)II9hsqS5McnoS5j3s)II9R(Hnfg8ZzmYxLaFXesfdzZLpCPFG6xuSFzuAA4Y40CDmYxF3Keevq)II9lJstdjnNYfly2rXqub9lk2VmknneuEoCeiQG(L0Vh0beFzJRhg3Vu9hTFrX(LtmUFj9tpKjO3LR9XW9xr)ainKypOtAiX6IYycPIOiGnk4abmiXS5YhUGieK4WokVJJeVOgtNlzgIrxYJr(IjKkgYMlF4s)s6x9dBkeRl71NXyiBU8Hl9lPFG7pK5PKKm4Y40CDmYxF3KeC5AFmC)s1FuP3VOy)c3FibXMBkKsKDCRFrX(fUF1pSPWsIkF4R6cGS5YhU0VOy)4e9ipwbY00O4beFDBQ9Rhc8HxxZfYMlF4s)aHe7bDsdjEDbt5splJOiGnk4cbmiXS5YhUGieKypOtAiX(uZLlMqQiXHDuEhhjwgLMgky5WG5lMqQyyjjz9lk2pW9lJstd1fLXesfIkOFrX(PrpN7Ybc(sMV6uZ9xr)KdL(RU)GJ1Ro1C)a1VK(bUFH7x9dBkmqyQDE9lMqQq2C5dx6xuSFpOdi(YgxpmU)k6hG(bQFrX(LrPPH6obkxmHuXWLR9XW9lv)mv5aQYxDQ5(L0Vh0beFzJRhg3Vu9hfjoejC4R6lzwXiGnkIIa2OGtiGbjMnx(WfeHGeh2r5DCKyG7pK5PKKm4Y40CDmYxF3KeC5AFmC)s1FuP3VOy)c3FibXMBkKsKDCRFrX(fUF1pSPWsIkF4R6cGS5YhU0VOy)4e9ipwbY00O4beFDBQ9Rhc8HxxZfYMlF4s)a1VK(PZakU)Q7p4y9Umz26VI(PZakgw7uTFj9dC)YO00WsIkF4R6cGLKK1VOy)QFytHyDzV(mgdzZLpCPFGqI9GoPHeVUGPCPNLrueWgTsIagKy2C5dxqecsCyhL3XrILrPPHcwomy(IjKkgIkOFrX(PZakUFP6pKyT)Q73d6Kg0NAUCXesfgsSIe7bDsdjoqyQDE9lMqQikcybq6iGbjMnx(WfeHGeh2r5DCKyzuAAOGLddMVycPIHOc6xuSF6mGI7xQ(djw7V6(9GoPb9PMlxmHuHHeRiXEqN0qI9n4gFXesfrralarradsmBU8Hlicbj2d6KgsmMxbSPxSogzK4WokVJJeVm9YycU8H7xs)QVKzfQtnF18wgUFP6VGUUoPHehIeo8v9LmRyeWgfrralaaGagKy2C5dxqecsCyhL3XrI9GoG4lBC9W4(LQ)OiXEqN0qIL9DDYmIIawaioeWGeZMlF4cIqqId7O8oosmW9hY8ussgCzCAUog5RVBscUCTpgUFP6pQ07xs)lQX05sMHy0L8yKVycPIHS5YhU0VOy)c3FibXMBkKsKDCRFrX(fUF1pSPWsIkF4R6cGS5YhU0VOy)4e9ipwbY00O4beFDBQ9Rhc8HxxZfYMlF4s)a1VK(PZakU)Q7p4y9Umz26VI(PZakgw7uTFj9dC)YO00WsIkF4R6cGLKK1VOy)QFytHyDzV(mgdzZLpCPFGqI9GoPHeVUGPCPNLrueWcGqfbmiXS5YhUGieK4WokVJJelJstd1fLXesfwssgsSh0jnKyzN8nPV6obkyefbSaineWGeZMlF4cIqqId7O8oosmorpYJvGcqXk6HV8IkqN0GS5YhU0VK(LrPPH6IYycPcljjdj2d6Kgsm9HXecRtRikcybaCGagKypOtAiXyL9sKlMqQiXS5YhUGieefrrI1DmkSIradcyJIagKy2C5dxqecsCkajgZksSh0jnKyq(oU8HrIb5hugjwgLMgUmonxhJ813njbrf0VOy)YO00qDrzmHuHOcqIb5718AgjghXcxubikcybabmiXS5YhUGieK4uasmMvKypOtAiXG8DC5dJedYpOmsCibXMBkKsKDCRFj9lJstdxgNMRJr(67MKGOc6xs)YO00qDrzmHuHOc6xuSFH7pKGyZnfsjYoU1VK(LrPPH6IYycPcrfGedY3R51msmw30iFXrSWfvaIIawIdbmiXS5YhUGieK4uasmM1Hgj2d6KgsmiFhx(WiXG89AEnJeJ1nnYxCelCxU2hdJeh2r5DCKyzuAAOUOmMqQWssY6xs)HeeBUPqkr2XnKyq(bLV8bZiXHmpLKKb1fLXesfUCTpggjgKFqzK4qMNssYGlJtZ1XiF9DtsWLR9XW9xrLW(dzEkjjdQlkJjKkC5AFmmIIawHkcyqIzZLpCbriiXPaKymRdnsSh0jnKyq(oU8HrIb5718AgjgRBAKV4iw4UCTpggjoSJY74iXYO00qDrzmHuHOc6xs)HeeBUPqkr2XnKyq(bLV8bZiXHmpLKKb1fLXesfUCTpggjgKFqzK4qMNssYGlJtZ1XiF9DtsWLR9XWikcyLgcyqIzZLpCbriiXPaKymRdnsSh0jnKyq(oU8HrIb5718AgjghXc3LR9XWiXHDuEhhjoKGyZnfsjYoUHedYpO8LpygjoK5PKKmOUOmMqQWLR9XWiXG8dkJehY8ussgCzCAUog5RVBscUCTpgUFPQe2FiZtjjzqDrzmHuHlx7JHrueWcoqadsmBU8Hlicbj2d6KgsSUJrH1OiXHDuEhhjg4(1DmkSc1Oqco(II5RmknD)II9hsqS5McPezh36xs)6ogfwHAuibhFdzEkjjRFG6xs)a3piFhx(WqSUPr(IJyHlQG(L0pW9lC)HeeBUPqkr2XT(L0VW9R7yuyfQaaj44lkMVYO009lk2FibXMBkKsKDCRFj9lC)6ogfwHkaqco(gY8ussw)II9R7yuyfQaadzEkjjdUCTpgUFrX(1DmkSc1Oqco(II5RmknD)s6h4(fUFDhJcRqfaibhFrX8vgLMUFrX(1DmkSc1OWqMNssYGf011jT(LcW(1DmkScvaGHmpLKKblORRtA9du)II9R7yuyfQrHeC8nK5PKKS(L0VW9R7yuyfQaaj44lkMVYO009lPFDhJcRqnkmK5PKKmybDDDsRFPaSFDhJcRqfayiZtjjzWc666Kw)a1VOy)c3piFhx(WqSUPr(IJyHlQG(L0pW9lC)6ogfwHkaqco(II5RmknD)s6h4(1DmkSc1OWqMNssYGf011jT(j((Lw)v0piFhx(WqCelCxU2hd3VOy)G8DC5ddXrSWD5AFmC)s1VUJrHvOgfgY8ussgSGUUoP1pX6hG(bQFrX(1DmkScvaGeC8ffZxzuA6(L0pW9R7yuyfQrHeC8ffZxzuA6(L0VUJrHvOgfgY8ussgSGUUoP1Vua2VUJrHvOcamK5PKKmybDDDsRFj9dC)6ogfwHAuyiZtjjzWc666Kw)eF)sR)k6hKVJlFyioIfUlx7JH7xuSFq(oU8HH4iw4UCTpgUFP6x3XOWkuJcdzEkjjdwqxxN06Ny9dq)a1VOy)a3VW9R7yuyfQrHeC8ffZxzuA6(ff7x3XOWkubagY8ussgSGUUoP1Vua2VUJrHvOgfgY8ussgSGUUoP1pq9lPFG7x3XOWkubagY8ussgCzVePFj9R7yuyfQaadzEkjjdwqxxN06N47xA9lv)G8DC5ddXrSWD5AFmC)s6hKVJlFyioIfUlx7JH7VI(1DmkScvaGHmpLKKblORRtA9tS(bOFrX(fUFDhJcRqfayiZtjjzWL9sK(L0pW9R7yuyfQaadzEkjjdUCTpgUFIVFP1Ff9dY3XLpmeRBAKV4iw4UCTpgUFj9dY3XLpmeRBAKV4iw4UCTpgUFP6haP3VK(bUFDhJcRqnkmK5PKKmybDDDsRFIVFP1Ff9dY3XLpmehXc3LR9XW9lk2VUJrHvOcamK5PKKm4Y1(y4(j((Lw)v0piFhx(WqCelCxU2hd3VK(1DmkScvaGHmpLKKblORRtA9t89hv69xD)G8DC5ddXrSWD5AFmC)v0piFhx(WqSUPr(IJyH7Y1(y4(ff7hKVJlFyioIfUlx7JH7xQ(1DmkSc1OWqMNssYGf011jT(jw)a0VOy)G8DC5ddXrSWfvq)a1VOy)6ogfwHkaWqMNssYGlx7JH7N47xA9lv)G8DC5ddX6Mg5loIfUlx7JH7xs)a3VUJrHvOgfgY8ussgSGUUoP1pX3V06VI(b574YhgI1nnYxCelCxU2hd3VOy)c3VUJrHvOgfsWXxumFLrPP7xs)a3piFhx(WqCelCxU2hd3Vu9R7yuyfQrHHmpLKKblORRtA9tS(bOFrX(b574YhgIJyHlQG(bQFG6hO(bQFG6hO(ff7xoX4(L0p9qMGExU2hd3Ff9dY3XLpmehXc3LR9XW9du)II9lC)6ogfwHAuibhFrX8vgLMUFj9lC)HeeBUPqkr2XT(L0pW9R7yuyfQaaj44lkMVYO009lPFG7h4(fUFq(oU8HH4iw4IkOFrX(1DmkScvaGHmpLKKbxU2hd3Vu9lT(bQFj9dC)G8DC5ddXrSWD5AFmC)s1pasVFrX(1DmkScvaGHmpLKKbxU2hd3pX3V06xQ(b574YhgIJyH7Y1(y4(bQFG6xuSFH7x3XOWkubasWXxumFLrPP7xs)a3VW9R7yuyfQaaj44BiZtjjz9lk2VUJrHvOcamK5PKKm4Y1(y4(ff7x3XOWkubagY8ussgSGUUoP1Vua2VUJrHvOgfgY8ussgSGUUoP1pq9desm(Kkgjw3XOWAuefbSGleWGeZMlF4cIqqI9GoPHeR7yuyfaK4WokVJJedC)6ogfwHkaqco(II5RmknD)II9hsqS5McPezh36xs)6ogfwHkaqco(gY8ussw)a1VK(bUFq(oU8HHyDtJ8fhXcxub9lPFG7x4(dji2CtHuISJB9lPFH7x3XOWkuJcj44lkMVYO009lk2FibXMBkKsKDCRFj9lC)6ogfwHAuibhFdzEkjjRFrX(1DmkSc1OWqMNssYGlx7JH7xuSFDhJcRqfaibhFrX8vgLMUFj9dC)c3VUJrHvOgfsWXxumFLrPP7xuSFDhJcRqfayiZtjjzWc666Kw)sby)6ogfwHAuyiZtjjzWc666Kw)a1VOy)6ogfwHkaqco(gY8ussw)s6x4(1DmkSc1Oqco(II5RmknD)s6x3XOWkubagY8ussgSGUUoP1Vua2VUJrHvOgfgY8ussgSGUUoP1pq9lk2VW9dY3XLpmeRBAKV4iw4IkOFj9dC)c3VUJrHvOgfsWXxumFLrPP7xs)a3VUJrHvOcamK5PKKmybDDDsRFIVFP1Ff9dY3XLpmehXc3LR9XW9lk2piFhx(WqCelCxU2hd3Vu9R7yuyfQaadzEkjjdwqxxN06Ny9dq)a1VOy)6ogfwHAuibhFrX8vgLMUFj9dC)6ogfwHkaqco(II5RmknD)s6x3XOWkubagY8ussgSGUUoP1Vua2VUJrHvOgfgY8ussgSGUUoP1VK(bUFDhJcRqfayiZtjjzWc666Kw)eF)sR)k6hKVJlFyioIfUlx7JH7xuSFq(oU8HH4iw4UCTpgUFP6x3XOWkubagY8ussgSGUUoP1pX6hG(bQFrX(bUFH7x3XOWkubasWXxumFLrPP7xuSFDhJcRqnkmK5PKKmybDDDsRFPaSFDhJcRqfayiZtjjzWc666Kw)a1VK(bUFDhJcRqnkmK5PKKm4YEjs)s6x3XOWkuJcdzEkjjdwqxxN06N47xA9lv)G8DC5ddXrSWD5AFmC)s6hKVJlFyioIfUlx7JH7VI(1DmkSc1OWqMNssYGf011jT(jw)a0VOy)c3VUJrHvOgfgY8ussgCzVePFj9dC)6ogfwHAuyiZtjjzWLR9XW9t89lT(ROFq(oU8HHyDtJ8fhXc3LR9XW9lPFq(oU8HHyDtJ8fhXc3LR9XW9lv)ai9(L0pW9R7yuyfQaadzEkjjdwqxxN06N47xA9xr)G8DC5ddXrSWD5AFmC)II9R7yuyfQrHHmpLKKbxU2hd3pX3V06VI(b574YhgIJyH7Y1(y4(L0VUJrHvOgfgY8ussgSGUUoP1pX3FuP3F19dY3XLpmehXc3LR9XW9xr)G8DC5ddX6Mg5loIfUlx7JH7xuSFq(oU8HH4iw4UCTpgUFP6x3XOWkubagY8ussgSGUUoP1pX6hG(ff7hKVJlFyioIfUOc6hO(ff7x3XOWkuJcdzEkjjdUCTpgUFIVFP1Vu9dY3XLpmeRBAKV4iw4UCTpgUFj9dC)6ogfwHkaWqMNssYGf011jT(j((Lw)v0piFhx(WqSUPr(IJyH7Y1(y4(ff7x4(1DmkScvaGeC8ffZxzuA6(L0pW9dY3XLpmehXc3LR9XW9lv)6ogfwHkaWqMNssYGf011jT(jw)a0VOy)G8DC5ddXrSWfvq)a1pq9du)a1pq9du)II9lNyC)s6NEitqVlx7JH7VI(b574YhgIJyH7Y1(y4(bQFrX(fUFDhJcRqfaibhFrX8vgLMUFj9lC)HeeBUPqkr2XT(L0pW9R7yuyfQrHeC8ffZxzuA6(L0pW9dC)c3piFhx(WqCelCrf0VOy)6ogfwHAuyiZtjjzWLR9XW9lv)sRFG6xs)a3piFhx(WqCelCxU2hd3Vu9dG07xuSFDhJcRqnkmK5PKKm4Y1(y4(j((Lw)s1piFhx(WqCelCxU2hd3pq9du)II9lC)6ogfwHAuibhFrX8vgLMUFj9dC)c3VUJrHvOgfsWX3qMNssY6xuSFDhJcRqnkmK5PKKm4Y1(y4(ff7x3XOWkuJcdzEkjjdwqxxN06xka7x3XOWkubagY8ussgSGUUoP1pq9desm(Kkgjw3XOWkaikIIOiXG4fpPHawaKoarLo4kQ0qIj5RngzmsSqJkrHsWwPawWzvT)(bdbU)PwqUA)052pr6obkycPIjQ)LfkqNLl9JZAUFhvZAx5s)bcUrMXWM6kpg3F0Q2FvsdeVkx6Ni1pSPqQqu)A2prQFytHubYMlF4cr9dCuQceSPUYJX9dqv7VkPbIxLl9t0IAmDUKziviQFn7NOf1y6CjZqQazZLpCHO(bokvbc2ux5X4(jUQ2FvsdeVkx6NOf1y6CjZqQqu)A2prlQX05sMHubYMlF4cr97A)cTvQvUFGJsvGGn1vEmUFPv1(RsAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2C5dxiQFGJsvGGn1vEmUFWrv7VkPbIxLl9t0IAmDUKziviQFn7NOf1y6CjZqQazZLpCHO(DTFH2k1k3pWrPkqWM6kpg3FLSQ9xL0aXRYL(js9dBkKke1VM9tK6h2uivGS5YhUqu)ahLQabBQR8yC)rLEv7VkPbIxLl9tK6h2uiviQFn7Ni1pSPqQazZLpCHO(bokvbc2ux5X4(JkuRA)vjnq8QCPFIu)WMcPcr9Rz)eP(HnfsfiBU8Hle1pWrPkqWM6kpg3FuHAv7VkPbIxLl9t0IAmDUKziviQFn7NOf1y6CjZqQazZLpCHO(bokvbc2ux5X4(JcUQA)vjnq8QCPFIu)WMcPcr9Rz)eP(HnfsfiBU8Hle1pWrPkqWM6kpg3FuWvv7VkPbIxLl9t0IAmDUKziviQFn7NOf1y6CjZqQazZLpCHO(bgaQceSPUYJX9hfCQQ9xL0aXRYL(js9dBkKke1VM9tK6h2uivGS5YhUqu)ahLQabBQR8yC)aiTQ2FvsdeVkx6NOf1y6CjZqQqu)A2prlQX05sMHubYMlF4cr97A)cTvQvUFGJsvGGn1vEmUFaahvT)QKgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKnx(WfI631(fARuRC)ahLQabBQR8yC)aaov1(RsAG4v5s)eHt0J8yfiviQFn7NiCIEKhRaPcKnx(WfI6h4OufiytDtTqJkrHsWwPawWzvT)(bdbU)PwqUA)052prfM2rpkr9VSqb6SCPFCwZ97OAw7kx6pqWnYmg2ux5X4(bOQ9xL0aXRYL(jArnMoxYmKke1VM9t0IAmDUKzivGS5YhUqu)ahLQabBQR8yC)au1(RsAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2C5dxiQFGJsvGGn1vEmUFaQA)vjnq8QCPFIcPvqhfsfI6xZ(jkKwbDuivGS5YhUqu)ahLQabBQR8yC)au1(RsAG4v5s)eHt0J8yfiviQFn7NiCIEKhRaPcKnx(WfI6h4OufiytDtTqJkrHsWwPawWzvT)(bdbU)PwqUA)052prcwoK1YUsu)lluGolx6hN1C)oQM1UYL(deCJmJHn1vEmUFIRQ9xL0aXRYL(jArnMoxYmKke1VM9t0IAmDUKzivGS5YhUqu)U2VqBLAL7h4OufiytDLhJ7xOw1(RsAG4v5s)eP(HnfsfI6xZ(js9dBkKkq2C5dxiQFx7xOTsTY9dCuQceSPUYJX9dUQA)vjnq8QCPFIu)WMcPcr9Rz)eP(HnfsfiBU8Hle1pWrPkqWM6kpg3p4uv7VkPbIxLl9tK6h2uiviQFn7Ni1pSPqQazZLpCHO(bokvbc2u3ul0OsuOeSvkGfCwv7VFWqG7FQfKR2pDU9tewjQ)LfkqNLl9JZAUFhvZAx5s)bcUrMXWM6kpg3F0Q2FvsdeVkx6Ni1pSPqQqu)A2prQFytHubYMlF4cr9dCuQceSPUYJX9luRA)vjnq8QCPFIwuJPZLmdPcr9Rz)eTOgtNlzgsfiBU8Hle1VR9l0wPw5(bokvbc2ux5X4(Lwv7VkPbIxLl9t0IAmDUKziviQFn7NOf1y6CjZqQazZLpCHO(bokvbc2ux5X4(JgTQ9xL0aXRYL(js9dBkKke1VM9tK6h2uivGS5YhUqu)ahLQabBQR8yC)rbOQ9xL0aXRYL(js9dBkKke1VM9tK6h2uivGS5YhUqu)ahLQabBQR8yC)rjUQ2FvsdeVkx6Ni1pSPqQqu)A2prQFytHubYMlF4cr9dCuQceSPUYJX9hvOw1(RsAG4v5s)eP(HnfsfI6xZ(js9dBkKkq2C5dxiQFGbGQabBQR8yC)rfQvT)QKgiEvU0pr4e9ipwbsfI6xZ(jcNOh5XkqQazZLpCHO(bokvbc2ux5X4(JkTQ2FvsdeVkx6Ni1pSPqQqu)A2prQFytHubYMlF4cr9dCuQceSPUYJX9hfCu1(RsAG4v5s)eP(HnfsfI6xZ(js9dBkKkq2C5dxiQFGbGQabBQR8yC)rbhvT)QKgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKnx(WfI6h4OufiytDLhJ7pk4OQ9xL0aXRYL(jcNOh5XkqQqu)A2pr4e9ipwbsfiBU8Hle1pWrPkqWM6kpg3FuWvv7VkPbIxLl9tK6h2uiviQFn7Ni1pSPqQazZLpCHO(bokvbc2ux5X4(Jcov1(RsAG4v5s)eP(HnfsfI6xZ(js9dBkKkq2C5dxiQFGbGQabBQR8yC)rbNQA)vjnq8QCPFIWj6rEScKke1VM9teorpYJvGubYMlF4cr9dCuQceSPUYJX9daXv1(RsAG4v5s)eP(HnfsfI6xZ(js9dBkKkq2C5dxiQFGbGQabBQR8yC)aqCvT)QKgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKnx(WfI6h4OufiytDLhJ7haIRQ9xL0aXRYL(jcNOh5XkqQqu)A2pr4e9ipwbsfiBU8Hle1pWrPkqWM6kpg3pasRQ9xL0aXRYL(jcNOh5XkqQqu)A2pr4e9ipwbsfiBU8Hle1pWrPkqWM6MAHgvIcLGTsbSGZQA)9dgcC)tTGC1(PZTFI0DmkSIjQ)LfkqNLl9JZAUFhvZAx5s)bcUrMXWM6kpg3p4OQ9xL0aXRYL(JN6Q0poIPov7hCRFn7VYOE)Lb0GN06pfWRR52pWedO(bwAufiytDLhJ7hCu1(RsAG4v5s)eP7yuyfgfsfI6xZ(js3XOWkuJcPcr9dmarPkqWM6kpg3p4OQ9xL0aXRYL(js3XOWkeaiviQFn7NiDhJcRqfaiviQFGbaCqvGGn1vEmUFWvv7VkPbIxLl9hp1vPFCetDQ2p4w)A2FLr9(ldObpP1FkGxxZTFGjgq9dS0OkqWM6kpg3p4QQ9xL0aXRYL(js3XOWkmkKke1VM9tKUJrHvOgfsfI6hyaahufiytDLhJ7hCv1(RsAG4v5s)eP7yuyfcaKke1VM9tKUJrHvOcaKke1pWaeLQabBQBQbdbUFIqX8DuUgtu)EqN06NKJ73sTF6e1k9pw)kHb3)ulixf2uxPulixLl9do63d6Kw)NbRyytnsSGnPNdJel0f69dUNVuW1UHjmc6hCoOMYBtTqxO3p1ONi9dG0bF)aiDaI2u3ul0f69xfcUrMXvTPwOl07N47hSmj6e1k9luY48aI7FW9BP2V3Fnhi42e6xjW97LsA9hCJyKMZP)A3CYmSPwOl07N47xOKXrSax63lL06xWo5oAK(jnkH(JN6Q0FLOqZkdBQBQ9GoPHHcwoK1YUwnGetov9WLl9XJWfsJr(QjvhRP2d6Kggky5qwl7A1asm6dJjewNwBQ9GoPHHcwoK1YUwnGet99QRla8dnGlQX05sMH4e9qNlz(Y1Y8IBQ9GoPHHcwoK1YUwnGeRKOYh(QUaWly5GJ1Ro1mGrLo4hAa9GoG4lBC9WyPIkkkCibXMBkKsKDCtIWQFytHGYZHJ0ul07VkeCJm3VM9hTFn7hp1Ohx5(fAbtLaIfhxjOFYSVysUG(bZIYycP2VGLdowHn1EqN0WqblhYAzxRgqIbY3XLpm4nVMbKv6RGLdowbpi)GYaEyYSv8ncKDYhw9tA4RUO8LodOyiBU8HlsWSQJrgdzN8Hv)K2ftYfazZLpCPP2d6Kggky5qwl7A1asmDrzmHub)qdiiFhx(WqwPVcwo4yTP2d6Kggky5qwl7A1asmFQ5YftivWp0a6bDaXx246HXvqCsaw4qcIn3uiLi74MeHv)WMcbLNdhru0d6aIVSX1dJRaaGKimiFhx(WqwPVcwo4yTP2d6Kggky5qwl7A1asmSYEjYftivWp0a6bDaXx246HXsbGOiWHeeBUPqkr2Xnrr1pSPqq55WrasIh0beFzJRhgdiaIIG8DC5ddzL(ky5GJ1M6MApOtA4QbKyHe1uEVycP2u7bDsdxnGelKOMY7ftivWFgJVHcGeN0b)qd4IAmDUKziMfqaTsJVc2mC8AxN0efXj6rESc0Mio(QzEWxb5Gttue4qAf0rHldIxSFUj9Loxf1yjcVOgtNlzgIzbeqR04RGndhV21jnGAQf69dol73jWEPF3k9dM1nHc05mvAUFWk0Sk9ZgxpmgCU9tI7VKgrA)LSFLWG7No3(fC8i8I7xMdokM7FuIk9lZ9Rz2pwGxxhPF3k9tI7p4grA)l7L5ePFWSUju0pwahg6j0Vmknng2u7bDsdxnGetx3ekqNZuPhJ8ftivWp0akS6lzwHd(k44r4TP2d6KgUAajwWpNRh0jT7zWk4nVMbu3XOWkg8dnGHeeBUPqkr2XnjHmpLKKb1fLXesfUCTpgwsiZtjjzWLXP56yKV(Ujj4Y1(yyrrHdji2CtHuISJBsczEkjjdQlkJjKkC5AFmCtTqxO3p488XJ0pThgJC)rs0T)sIkR9JA6C6psI2pbhe3VauTFHsgNMRJrU)kXDts9xssg47p3(h6(vcC)HmpLKK1)G7xZS)tAK7xZ(l8XJ0pThgJC)rs0TFW5tuzf2FLcD)wAC)jD)kbgZ9hsRm6KgUFF5(D5d3VM9xZA)KgLWy9Re4(Jk9(XCiTcU)dZK8iGVFLa3pEQ7N2dmU)ij62p48jQS2VJQzTRtWpNiWMAHUqVFpOtA4QbKygtIorTYDzCEaXGFObeNOh5XkqJjrNOw5UmopGyjalJstdxgNMRJr(67MKGOcefdzEkjjdUmonxhJ813njbxU2hdlvuPlkspKjO3LR9XWvefCautTh0jnC1asSGFoxpOtA3ZGvWBEndyOGBQ9GoPHRgqIf8Z56bDs7EgScEZRzaXk4hAa9GoG4lBC9W4kiUMApOtA4QbKyb)CUEqN0UNbRG38AgqDNafmHuXGFOb0d6aIVSX1dJLcGM6MApOtAyyOGbuMxmVugJm4hAabwgLMgQlkJjKkevGezuAA4Y40CDmYxF3KeevGKqcIn3uiLi74gqIIalJstd1fLXesfIkqImknnK0CkxSGzhfdrfijKGyZnfAdzc6L2zGefboKGyZnfcInLqKvumKGyZnfACyZtUfGKiJstd1fLXesfIkquuoXyj0dzc6D5AFmCfrjorrGdji2CtHuISJBsKrPPHlJtZ1XiF9DtsqubsOhYe07Y1(y4kaxehqn1EqN0WWqbxnGet(Kz5sJUra)qdOmknnuxugtiviQarXqMNssYG6IYycPcxU2hdlfXjDrr5eJLqpKjO3LR9XWvefC0u7bDsdddfC1asm3cmwx)Cd(5a(HgqzuAAOUOmMqQqubIIHmpLKKb1fLXesfUCTpgwkIt6IIYjglHEitqVlx7JHRik4OP2d6Kgggk4QbKy0ZYYNmlGFObugLMgQlkJjKkevGOyiZtjjzqDrzmHuHlx7JHLI4KUOOCIXsOhYe07Y1(y4kQKn1EqN0WWqbxnGe7mKjO4l4(OfY1SPGFObugLMgQlkJjKkSKKSMApOtAyyOGRgqIji1jnWp0akJstd1fLXesfIkqcWYO00q5tMLdkwHOcefvFjZkKa7hLauqqRaaPdKOOCIXsOhYe07Y1(y4kaaCikcCibXMBkKsKDCtImknnCzCAUog5RVBscIkqc9qMGExU2hdxb4caGAQBQ9GoPHHyfqSYEjYftivWp0aQ(HnfIv2lrU0zaflbybld6souGrHyL9sKlMqQsKrPPHyL9sKlDgqXWLR9XWvinrrzuAAiwzVe5sNbumSKKmGKaSmknnCzCAUog5RVBscwssMOOWHeeBUPqkr2XnGAQ9GoPHHyTAajgL5CUycP2u7bDsddXA1asSsIkF4R6ca)qdiWHeeBUPqkr2XnjahY8ussgCzCAUog5RVBscUCTpgUcYHcqIIchsqS5McPezh3KiCibXMBk0gYe0lTZIIHeeBUPqBitqV0olb4qMNssYGKMt5Ifm7Oy4Y1(y4kihkIIHmpLKKbjnNYfly2rXWLR9XWsrCshirr6Hmb9UCTpgUIOsdijal86t5YGytHEPGHmvhSIffxFkxgeBk0lfmevGeGxFkxgeBk0lfmCSkIkDjRpLldInf6LcgUCTpgUcItuC9PCzqSPqVuWWXKkK5PKKmrrpOdi(YgxpmwQOajkk86t5YGytHEPGHOcKa86t5YGytHEPGHHe1uaJkkU(uUmi2uOxky4ysfY8ussgqa1u7bDsddXA1asm6JVm4hAavFV66cGOcKSOgtNlzgIt0dDUK5lxlZlUP2d6KggI1QbKyQVxDDbGFObCrnMoxYmeNOh6CjZxUwMxSe13RUUa4Y1(y4kihksczEkjjdsF8LHlx7JHRGCO0u7bDsddXA1asmMQcojEaXxmHuBQ9GoPHHyTAajgP5uUybZokg8dnGcV(uUmi2uOxkyit1bRyrrHxFkxgeBk0lfmevGK1NYLbXMc9sbdlORRtAvV(uUmi2uOxky4yvaG0ffxFkxgeBk0lfmevGK1NYLbXMc9sbdxU2hdlv0kPOOh0beFzJRhglv0MApOtAyiwRgqIrF8iC5IjKAtTh0jnmeRvdiXkSReUbcoL1Rb)qdiDgqXvhCSExMmBvqNbumS2PAtTh0jnmeRvdiX8Bn6w49M03WMKWn1EqN0WqSwnGeJKpNXiF9DtsGFObmK5PKKm4Y40CDmYxF3KeC5AFmCfKdfjalS6h2uitvbNepG4lMqQIIYO00q5tMLdkwHOcasuu4qcIn3uiLi74MOyiZtjjzWLXP56yKV(Ujj4Y1(yyrr5eJLqpKjO3LR9XWviTMApOtAyiwRgqITmonxhJ813njb(HgqGLrPPHLev(Wx1farfikkS6h2uyjrLp8vDbIIYjglHEitqVlx7JHRikaajbyHxFkxgeBk0lfmKP6GvSOOWRpLldInf6LcgIkqcWRpLldInf6LcgwqxxN0QE9PCzqSPqVuWWXQiQ0ffxFkxgeBk0lfmmKOMcyuGefxFkxgeBk0lfmevGK1NYLbXMc9sbdxU2hdlvLuu0d6aIVSX1dJLkkqn1EqN0WqSwnGeduEoCeWp0akJstdxgNMRJr(67MKGOceffoKGyZnfsjYoUjbyzuAAOGLddMVycPIHLKKjkkS6h2uyGWu786xmHuff9GoG4lBC9W4kaaOMApOtAyiwRgqIHv2lrUycPc(HgWqcIn3uiLi74Me6mGIRo4y9Umz2QGodOyyTtvjadCiZtjjzWLXP56yKV(Ujj4Y1(y4kihkG7iojalmorpYJvGmnnkEaXx3MA)6HaF411Cfffw9dBkSKOYh(QUaGasuu9dBkSKOYh(QUajHmpLKKbljQ8HVQlaUCTpgUcIdOMApOtAyiwRgqIPlkJjKk4hAaLrPPHcwomy(IjKkgwssMeGdji2CtHGytjezffdji2CtHgh28KBruu9dBkm4NZyKVkb(IjKkgirrzuAA4Y40CDmYxF3KeevGOOmknnK0CkxSGzhfdrfikkJstdbLNdhbIkqIh0beFzJRhglvurr5eJLqpKjO3LR9XWvaG0AQ9GoPHHyTAaj26cMYLEwg8dnGlQX05sMHy0L8yKVycPILO(HnfI1L96ZySeGdzEkjjdUmonxhJ813njbxU2hdlvuPlkkCibXMBkKsKDCtuuy1pSPWsIkF4R6cefXj6rEScKPPrXdi(62u7xpe4dVUMlqn1EqN0WqSwnGeZNAUCXesf8HiHdFvFjZkgWOGFObugLMgky5WG5lMqQyyjjzIIalJstd1fLXesfIkquKg9CUlhi4lz(Qtnxb5qP6GJ1Ro1mqsawy1pSPWaHP251VycPkk6bDaXx246HXvaaqIIYO00qDNaLlMqQy4Y1(yyPyQYbuLV6uZs8GoG4lBC9WyPI2u7bDsddXA1asS1fmLl9Sm4hAaboK5PKKm4Y40CDmYxF3KeC5AFmSurLUOOWHeeBUPqkr2XnrrHv)WMcljQ8HVQlqueNOh5XkqMMgfpG4RBtTF9qGp86AUajHodO4QdowVltMTkOZakgw7uvcWYO00WsIkF4R6cGLKKjkQ(HnfI1L96Zymqn1EqN0WqSwnGelqyQDE9lMqQGFObugLMgky5WG5lMqQyiQarr6mGILkKyTApOtAqFQ5YftivyiXAtTh0jnmeRvdiX8n4gFXesf8dnGYO00qblhgmFXesfdrfiksNbuSuHeRv7bDsd6tnxUycPcdjwBQ9GoPHHyTAajgMxbSPxSogzWhIeo8v9LmRyaJc(HgWLPxgtWLpSe1xYSc1PMVAEldlvbDDDsRP2d6KggI1QbKyY(Uozg8dnGEqhq8LnUEySurBQ9GoPHHyTAaj26cMYLEwg8dnGahY8ussgCzCAUog5RVBscUCTpgwQOsxYIAmDUKzigDjpg5lMqQyrrHdji2CtHuISJBIIcR(Hnfwsu5dFvxGOiorpYJvGmnnkEaXx3MA)6HaF411CbscDgqXvhCSExMmBvqNbumS2PQeGLrPPHLev(Wx1faljjtuu9dBkeRl71NXyGAQ9GoPHHyTAajMSt(M0xDNafm4hAaLrPPH6IYycPcljjRP2d6KggI1QbKy0hgtiSoTc(HgqCIEKhRafGIv0dF5fvGoPjrgLMgQlkJjKkSKKSMApOtAyiwRgqIHv2lrUycP2u3u7bDsdd1DcuWesfdiwzVe5IjKk4hAav)WMcXk7Lix6mGILm2L(mKjOsKrPPHyL9sKlDgqXWLR9XWviTMApOtAyOUtGcMqQ4QbKyuMZ5IjKk4hAaxuJPZLmdfKObc3K(UELo3l96KRztXsKrPPH0hpcV4BTVuGOcAQ9GoPHH6obkycPIRgqIrF8iC5IjKk4hAaxuJPZLmdfKObc3K(UELo3l96KRztXn1EqN0WqDNafmHuXvdiXkjQ8HVQla8dnGahsqS5McPezh3KeY8ussgCzCAUog5RVBscUCTpgUcYHIOOWHeeBUPqkr2XnjchsqS5McTHmb9s7SOyibXMBk0gYe0lTZsaoK5PKKmiP5uUybZokgUCTpgUcYHIOyiZtjjzqsZPCXcMDumC5AFmSueN0bsuu9LmRqDQ5RM3YWvev6IIHmpLKKbxgNMRJr(67MKGlx7JHLkQ0L4bDaXx246HXsrCajbyHxFkxgeBk0lfmKP6GvSO46t5YGytHEPGHlx7JHLQskkkCibXMBkKsKDCdOMApOtAyOUtGcMqQ4QbKyQVxDDbGFObCrnMoxYmeNOh6CjZxUwMxSe13RUUa4Y1(y4kihksczEkjjdsF8LHlx7JHRGCO0u7bDsdd1DcuWesfxnGeJ(4ld(Zy8nuaeaPb(Hgq13RUUaiQajlQX05sMH4e9qNlz(Y1Y8IBQ9GoPHH6obkycPIRgqIXuvWjXdi(IjKAtTh0jnmu3jqbtivC1asmsZPCXcMDum4hAafE9PCzqSPqVuWqMQdwXIIRpLldInf6LcgUCTpgwQOsxu0d6aIVSX1dJLcW1NYLbXMc9sbddjQPG7aOP2d6KggQ7eOGjKkUAajgjFoJr(67MKa)qdyiZtjjzWLXP56yKV(Ujj4Y1(y4kihksawy1pSPqMQcojEaXxmHuffLrPPHYNmlhuScrfaKOOWHeeBUPqkr2XnrXqMNssYGlJtZ1XiF9DtsWLR9XWsfv6IIYjglHEitqVlx7JHRqAn1EqN0WqDNafmHuXvdiXwgNMRJr(67MKa)qdiWHmpLKKbbLNdhbUCTpgUcYHIOOWQFytHGYZHJikQ(sMvOo18vZBz4kIcaqsaw41NYLbXMc9sbdzQoyflkU(uUmi2uOxky4Y1(yyPQKIIEqhq8LnUEySuaU(uUmi2uOxkyyirnfChaa1u7bDsdd1DcuWesfxnGeduEoCeWp0akJstdxgNMRJr(67MKGOceffoKGyZnfsjYoU1u7bDsdd1DcuWesfxnGet231jZn1EqN0WqDNafmHuXvdiX0fLXesf8dnGYO00WLXP56yKV(UjjiQarXqMNssYGlJtZ1XiF9DtsWLR9XWsfv6IIchsqS5McPezh3efLtmwc9qMGExU2hdxbasVP2d6KggQ7eOGjKkUAaj26cMYLEwg8dnGlQX05sMHy0L8yKVycPILaCiZtjjzWLXP56yKV(Ujj4Y1(yyPIkDrrHdji2CtHuISJBIIcR(Hnfwsu5dFvxaqsKrPPH6obkxmHuXWLR9XWsbitvoGQ8vNAUP2d6KggQ7eOGjKkUAajMp1C5IjKk4drch(Q(sMvmGrb)qdOmknnu3jq5IjKkgUCTpgwkazQYbuLV6uZsawgLMgky5WG5lMqQyyjjzII0ONZD5abFjZxDQ5kcowV6uZvtouefLrPPH6IYycPcrfautTh0jnmu3jqbtivC1asSc7kHBGGtz9AWp0asNbuC1bhR3LjZwf0zafdRDQ2u7bDsdd1DcuWesfxnGeBDbt5spld(HgqGdzEkjjdUmonxhJ813njbxU2hdlvuPlzrnMoxYmeJUKhJ8ftivSOOWHeeBUPqkr2XnrrHxuJPZLmdXOl5XiFXesflkkS6h2uyjrLp8vDbajrgLMgQ7eOCXesfdxU2hdlfGmv5aQYxDQ5MApOtAyOUtGcMqQ4QbKy1OhDWesf8dnGYO00qDNaLlMqQyyjjzIIYO00qblhgmFXesfdrfiHodOyPcjwR2d6Kg0NAUCXesfgsSkbyHv)WMcdeMANx)IjKQOOh0beFzJRhglfXbutTh0jnmu3jqbtivC1asSaHP251VycPc(HgqzuAAOGLddMVycPIHOcKqNbuSuHeRv7bDsd6tnxUycPcdjwL4bDaXx246HXviuBQ9GoPHH6obkycPIRgqIrzoNlMqQGFObugLMgwyVC5imSKKSMApOtAyOUtGcMqQ4QbKy(TgDl8Et6Byts4MApOtAyOUtGcMqQ4QbKy0hpcxUycP2u7bDsdd1DcuWesfxnGedZRa20lwhJm4drch(Q(sMvmGrb)qd4Y0lJj4YhUP2d6KggQ7eOGjKkUAajwn6rhmHub)qdiDgqXsfsSwTh0jnOp1C5IjKkmKyvcWHmpLKKbxgNMRJr(67MKGlx7JHLsAIIchsqS5McPezh3aQP2d6KggQ7eOGjKkUAajM67vxxa4hAaxuJPZLmdngJhJmjFJGV66cemg5RlqGVUIIBQ9GoPHH6obkycPIRgqIrVmxPhJ8vxxa4hAaxuJPZLmdngJhJmjFJGV66cemg5RlqGVUIIBQ9GoPHH6obkycPIRgqIj7KVj9v3jqbd(HgqzuAAOUOmMqQWssYAQ9GoPHH6obkycPIRgqIrFymHW60k4hAaXj6rEScuakwrp8Lxub6KMezuAAOUOmMqQWssYAQ9GoPHH6obkycPIRgqIHv2lrUycP2u3u7bDsdd1DmkSIbeKVJlFyWBEndioIfUOcapi)GYakJstdxgNMRJr(67MKGOcefLrPPH6IYycPcrf0u7bDsdd1DmkSIRgqIbY3XLpm4nVMbeRBAKV4iw4Ika8G8dkdyibXMBkKsKDCtImknnCzCAUog5RVBscIkqImknnuxugtiviQarrHdji2CtHuISJBsKrPPH6IYycPcrf0u7bDsdd1DmkSIRgqIbY3XLpm4nVMbeRBAKV4iw4UCTpgg8PaaXSo0GhKFqzadzEkjjdUmonxhJ813njbxU2hdxrLWqMNssYG6IYycPcxU2hddEq(bLV8bZagY8ussguxugtiv4Y1(yyWp0akJstd1fLXesfwssMKqcIn3uiLi74wtTh0jnmu3XOWkUAajgiFhx(WG38AgqSUPr(IJyH7Y1(yyWNcaeZ6qdEq(bLbmK5PKKm4Y40CDmYxF3KeC5AFmm4b5hu(YhmdyiZtjjzqDrzmHuHlx7JHb)qdOmknnuxugtiviQajHeeBUPqkr2XTMApOtAyOUJrHvC1asmq(oU8HbV51mG4iw4UCTpgg8PaaXSo0GFObmKGyZnfsjYoUbEq(bLbmK5PKKm4Y40CDmYxF3KeC5AFmSuvcdzEkjjdQlkJjKkC5AFmm4b5hu(YhmdyiZtjjzqDrzmHuHlx7JHBQ9GoPHH6ogfwXvdiXqX8DuUgdE8jvmG6ogfwJc(HgqG1DmkScJcj44lkMVYO00IIHeeBUPqkr2Xnj6ogfwHrHeC8nK5PKKmGKamiFhx(WqSUPr(IJyHlQajalCibXMBkKsKDCtIW6ogfwHaaj44lkMVYO00IIHeeBUPqkr2XnjcR7yuyfcaKGJVHmpLKKjkQ7yuyfcamK5PKKm4Y1(yyrrDhJcRWOqco(II5RmknTeGfw3XOWkeaibhFrX8vgLMwuu3XOWkmkmK5PKKmybDDDstka1DmkScbagY8ussgSGUUoPbKOOUJrHvyuibhFdzEkjjtIW6ogfwHaaj44lkMVYO00s0DmkScJcdzEkjjdwqxxN0KcqDhJcRqaGHmpLKKblORRtAajkkmiFhx(WqSUPr(IJyHlQajalSUJrHviaqco(II5RmknTeG1DmkScJcdzEkjjdwqxxN0iEPvbiFhx(WqCelCxU2hdlkcY3XLpmehXc3LR9XWsP7yuyfgfgY8ussgSGUUoPbUbaqII6ogfwHaaj44lkMVYO00saw3XOWkmkKGJVOy(kJstlr3XOWkmkmK5PKKmybDDDstka1DmkScbagY8ussgSGUUoPjbyDhJcRWOWqMNssYGf011jnIxAvaY3XLpmehXc3LR9XWIIG8DC5ddXrSWD5AFmSu6ogfwHrHHmpLKKblORRtAGBaaKOiWcR7yuyfgfsWXxumFLrPPff1DmkScbagY8ussgSGUUoPjfG6ogfwHrHHmpLKKblORRtAajbyDhJcRqaGHmpLKKbx2lrKO7yuyfcamK5PKKmybDDDsJ4LMuG8DC5ddXrSWD5AFmSeq(oU8HH4iw4UCTpgUcDhJcRqaGHmpLKKblORRtAGBaikkSUJrHviaWqMNssYGl7Lisaw3XOWkeayiZtjjzWLR9XWeV0QaKVJlFyiw30iFXrSWD5AFmSeq(oU8HHyDtJ8fhXc3LR9XWsbG0LaSUJrHvyuyiZtjjzWc666KgXlTka574YhgIJyH7Y1(yyrrDhJcRqaGHmpLKKbxU2hdt8sRcq(oU8HH4iw4UCTpgwIUJrHviaWqMNssYGf011jnIpQ0RgKVJlFyioIfUlx7JHRaKVJlFyiw30iFXrSWD5AFmSOiiFhx(WqCelCxU2hdlLUJrHvyuyiZtjjzWc666Kg4gaIIG8DC5ddXrSWfvaqII6ogfwHaadzEkjjdUCTpgM4LMuG8DC5ddX6Mg5loIfUlx7JHLaSUJrHvyuyiZtjjzWc666KgXlTka574YhgI1nnYxCelCxU2hdlkkSUJrHvyuibhFrX8vgLMwcWG8DC5ddXrSWD5AFmSu6ogfwHrHHmpLKKblORRtAGBaikcY3XLpmehXcxubabeqabeqIIYjglHEitqVlx7JHRaKVJlFyioIfUlx7JHbsuuyDhJcRWOqco(II5RmknTeHdji2CtHuISJBsaw3XOWkeaibhFrX8vgLMwcWalmiFhx(WqCelCrfikQ7yuyfcamK5PKKm4Y1(yyPKgqsagKVJlFyioIfUlx7JHLcaPlkQ7yuyfcamK5PKKm4Y1(yyIxAsbY3XLpmehXc3LR9XWabKOOW6ogfwHaaj44lkMVYO00sawyDhJcRqaGeC8nK5PKKmrrDhJcRqaGHmpLKKbxU2hdlkQ7yuyfcamK5PKKmybDDDstka1DmkScJcdzEkjjdwqxxN0acOMApOtAyOUJrHvC1asmumFhLRXGhFsfdOUJrHvaa)qdiW6ogfwHaaj44lkMVYO00IIHeeBUPqkr2Xnj6ogfwHaaj44BiZtjjzajbyq(oU8HHyDtJ8fhXcxubsaw4qcIn3uiLi74MeH1DmkScJcj44lkMVYO00IIHeeBUPqkr2XnjcR7yuyfgfsWX3qMNssYef1DmkScJcdzEkjjdUCTpgwuu3XOWkeaibhFrX8vgLMwcWcR7yuyfgfsWXxumFLrPPff1DmkScbagY8ussgSGUUoPjfG6ogfwHrHHmpLKKblORRtAajkQ7yuyfcaKGJVHmpLKKjryDhJcRWOqco(II5RmknTeDhJcRqaGHmpLKKblORRtAsbOUJrHvyuyiZtjjzWc666KgqIIcdY3XLpmeRBAKV4iw4IkqcWcR7yuyfgfsWXxumFLrPPLaSUJrHviaWqMNssYGf011jnIxAvaY3XLpmehXc3LR9XWIIG8DC5ddXrSWD5AFmSu6ogfwHaadzEkjjdwqxxN0a3aairrDhJcRWOqco(II5RmknTeG1DmkScbasWXxumFLrPPLO7yuyfcamK5PKKmybDDDstka1DmkScJcdzEkjjdwqxxN0KaSUJrHviaWqMNssYGf011jnIxAvaY3XLpmehXc3LR9XWIIG8DC5ddXrSWD5AFmSu6ogfwHaadzEkjjdwqxxN0a3aairrGfw3XOWkeaibhFrX8vgLMwuu3XOWkmkmK5PKKmybDDDstka1DmkScbagY8ussgSGUUoPbKeG1DmkScJcdzEkjjdUSxIir3XOWkmkmK5PKKmybDDDsJ4LMuG8DC5ddXrSWD5AFmSeq(oU8HH4iw4UCTpgUcDhJcRWOWqMNssYGf011jnWnaeffw3XOWkmkmK5PKKm4YEjIeG1DmkScJcdzEkjjdUCTpgM4LwfG8DC5ddX6Mg5loIfUlx7JHLaY3XLpmeRBAKV4iw4UCTpgwkaKUeG1DmkScbagY8ussgSGUUoPr8sRcq(oU8HH4iw4UCTpgwuu3XOWkmkmK5PKKm4Y1(yyIxAvaY3XLpmehXc3LR9XWs0DmkScJcdzEkjjdwqxxN0i(OsVAq(oU8HH4iw4UCTpgUcq(oU8HHyDtJ8fhXc3LR9XWIIG8DC5ddXrSWD5AFmSu6ogfwHaadzEkjjdwqxxN0a3aqueKVJlFyioIfUOcasuu3XOWkmkmK5PKKm4Y1(yyIxAsbY3XLpmeRBAKV4iw4UCTpgwcW6ogfwHaadzEkjjdwqxxN0iEPvbiFhx(WqSUPr(IJyH7Y1(yyrrH1DmkScbasWXxumFLrPPLamiFhx(WqCelCxU2hdlLUJrHviaWqMNssYGf011jnWnaefb574YhgIJyHlQaGaciGacirr5eJLqpKjO3LR9XWvaY3XLpmehXc3LR9XWajkkSUJrHviaqco(II5RmknTeHdji2CtHuISJBsaw3XOWkmkKGJVOy(kJstlbyGfgKVJlFyioIfUOcef1DmkScJcdzEkjjdUCTpgwkPbKeGb574YhgIJyH7Y1(yyPaq6II6ogfwHrHHmpLKKbxU2hdt8stkq(oU8HH4iw4UCTpggiGeffw3XOWkmkKGJVOy(kJstlbyH1DmkScJcj44BiZtjjzII6ogfwHrHHmpLKKbxU2hdlkQ7yuyfgfgY8ussgSGUUoPjfG6ogfwHaadzEkjjdwqxxN0aciKySaoGawaKMqfrruee]] )

    
end