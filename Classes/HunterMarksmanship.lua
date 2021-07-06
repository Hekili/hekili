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


    spec:RegisterPack( "Marksmanship", 20210706, [[d8KEccqicQhHaQUeci2er1NqqJcu1PavwLKa6vsIMLQe3cjr7cYVuLQHPkWXOkTmjPNPkLMgscDneOTjjOVHKGXjjqDojHkRdb4Dscj18Ok6EQI2hvH)jjq6GscLwisspuvkMOKqrxusiAJscj(OKqQrkjKKtkjewjbzMQc6Mscf2PQK(jcizOsceTujHQEkv1uvf6RiGuJfjL9Qs)vvnyGdlSyc9yQmzvCzuBgP(mImAq50kTAjbcVgrnBjUTKA3u(TOHtGJJaklxXZHA6KUoiBhj(ocnEKuDEIY6LeG5tK9l1xV3hV(Nq57RvFqvVpGk8Gke59TVLkqfj41xLjGV(cch5GeF9TOMV(vmIHmUommSvW1xqiRKX5(41hNqJJV(e4naMQcWeW7VtAvyqIixw)oERHkHUP5MGwFhV1U3V(IqBrRiSR41)ekFFT6dQ69buHhuHiVV9TuH3wHx)asHLZ13FRFZ1h2EoSDfV(hg7U(vmIHmUommSvqdQOcYuEAHecQiRbv4lnO6dQ696xwSIVpE91zDKXWsfFF8(Q37JxF2cXcFUu967Mv5zJRVgf2uew54i7tNoimITqSWNgiVbR9PlljyAdK3ariAAew54i7tNoimA46ynCd8Sbe86hoDt76JvooY(yyPE17RvVpE9zlel85s1RVBwLNnU(UKcBHPiYYMnSgiVbUmlNKOHggNwORr6hZKerdxhRHBGNnGK70ajPgiCdCjf2ctrKLnBynqEdeUbUKcBHPiBjbt)0b3ajPg4skSfMISLem9thCdK3a4BGlZYjjAiIB58Xc2zvmA46ynCd8SbKCNgij1axMLts0qe3Y5JfSZQy0W1XA4g4rdE7dAaCnqsQbAmKyfPBn)18FwUbE2aVpObssnWLz5Ken0W40cDns)yMKiA46ynCd8ObEFqdK3GWPlf(ZgxVmUbE0G3E9dNUPD9pjKyH)Ai4Q3xF79XRpBHyHpxQE9DZQ8SX1FGmMohsmcNqf6CiXFUwKhmITqSWNgiVbAmFDcbOHRJ1WnWZgqYDAG8g4YSCsIgIUedJgUowd3apBaj356hoDt76RX81jeC17RuX7JxF2cXcFUu96hoDt76txIHV(UzvE246RX81jeGGe0a5nyGmMohsmcNqf6CiXFUwKhmITqSWNRFzn(7ox)Qe8Q3xj49XRF40nTRptDbLeVu4pgwQxF2cXcFUu9Q3xRW7Jx)WPBAxFIB58Xc2zv81NTqSWNlvV69vQW9XRpBHyHpxQE9DZQ8SX13Lz5Ken0W40cDns)yMKiA46ynCd8SbKCNgiVbW3aHBGgf2uetDbLeVu4pgwQi2cXcFAGKudeHOPrILmpfiSIGe0a4AGKudeUbUKcBHPiYYMnSgij1axMLts0qdJtl01i9JzsIOHRJ1WnWJg49bnqsQbIjg3a5nGEjbt)dxhRHBGNnGGx)WPBAxFIXwwJ0pMjjE17RvW3hV(SfIf(CP613nRYZgxFriAA0jHel8xdbiibnqsQbc3ankSPOtcjw4VgcqSfIf(0ajPgiMyCdK3a6Lem9pCDSgUbE2aVvV(Ht30U(dJtl01i9JzsIx9(Af39XRpBHyHpxQE9DZQ8SX1xeIMgnmoTqxJ0pMjjIGe0ajPgiCdCjf2ctrKLnByx)WPBAxFkzPWYU69vVp4(41pC6M21xmMjiXxF2cXcFUu9Q3x969(41pC6M21xhigdl1RpBHyHpxQE17REREF86Zwiw4ZLQxF3SkpBC9hiJPZHeJWqdP1i9XWsfJylel8PbYBa8nWLz5Ken0W40cDns)yMKiA46ynCd8ObEFqdKKAGWnWLuylmfrw2SH1ajPgiCd0OWMIojKyH)AiaXwiw4tdGRbYBGiennsN1r(JHLkgnCDSgUbE8Sbm1zhKYFDR5RF40nTR)ec2ZNEh(Q3x9(27JxF2cXcFUu96hoDt76hBnF(yyPE9DZQ8SX1xeIMgPZ6i)XWsfJgUowd3apE2aM6Sds5VU1CdK3a4BGiennsWWUfZFmSuXOts0AGKudOHkL)WoyXqI)6wZnWZg4cS(1TMBqLnGK70ajPgicrtJ0bIXWsfbjObWD9DYCf(RXqIv89vVx9(QxQ49XRpBHyHpxQE9DZQ8SX1NoDq4guzdCbw)dtITg4zdOthegvhu)6hoDt76F4qH9DWcYtuF17REj49XRpBHyHpxQE9DZQ8SX1h(g4YSCsIg6KqIf(RHa0W1XA4g4rdi5onOcSbeSbYBWazmDoKyegAiTgPpgwQyeBHyHpnqsQbc3axsHTWuezzZgwdKKAGWnqJcBk6KqIf(RHaeBHyHpnaUgiVb0Pdc3GkBGlW6FysS1apBaD6GWO6G6nqEdGVbIq00Otcjw4VgcqNKO1ajPgOrHnfH1HJ6YAmITqSWNga31pC6M21Fcb75tVdF17RERW7JxF2cXcFUu967Mv5zJRViennsN1r(JHLkgDsIwdKKAGiennsWWUfZFmSuXiibnqEdOtheUbE0axI1guzdcNUPHITMpFmSurUeRnqEdGVbc3ankSPihSTo4j(yyPIylel8PbssniC6sH)SX1lJBGhn4TnaURF40nTRFnurxmSuV69vVuH7JxF2cXcFUu967Mv5zJRViennsWWUfZFmSuXiibnqEdOtheUbE0axI1guzdcNUPHITMpFmSurUeRnqEdcNUu4pBC9Y4g4zdOIx)WPBAxFhSTo4j(yyPE17RERGVpE9zlel85s1RVBwLNnU(Iq00OdhNplJrNKOD9dNUPD9jVLYhdl1REF1Bf39XRF40nTRF8RHMdp)K(7MKi(6Zwiw4ZLQx9(A1hCF86hoDt76txcz85JHL61NTqSWNlvV691QEVpE9zlel85s1RF40nTRpMhbSPFSUgPRVBwLNnU(dtpmgwiw4RVtMRWFngsSIVV69Q3xRw9(41NTqSWNlvV(UzvE246tNoiCd8ObUeRnOYgeoDtdfBnF(yyPICjwBG8gaFdCzwojrdnmoTqxJ0pMjjIgUowd3apAabBGKudeUbUKcBHPiYYMnSgij1a60bHBqLnWfy9pmj2AGhnGoDqyuDq9ga31pC6M21VgQOlgwQx9(A13EF86Zwiw4ZLQxF3SkpBC9hiJPZHeJmgJxJeXyKH)6eceSgPFiqqmHcHrSfIf(C9dNUPD91y(6ecU691QuX7JxF2cXcFUu967Mv5zJR)azmDoKyKXy8AKigJm8xNqGG1i9dbcIjuimITqSWNRF40nTRp9WCfWAK(6ecU691Qe8(41NTqSWNlvV(UzvE246lcrtJ0bIXWsfDsI21pC6M21xmi9t6VoRJm(Q3xRwH3hV(Ht30U(yLJJSpgwQxF2cXcFUu9Qx96Fy6aQO3hVV69(41pC6M213LqMYZhdl1RpBHyHpxQE17RvVpE9zlel85s1RF40nTRVlHmLNpgwQxF3SkpBC9hiJPZHeJWSayqva4VGjDLOo0nneBHyHpnqsQb4eQiU2bzRSa)1ml4VGCXPHylel8Pbssna(g4s7aTkAyk8GJYpP)05OqgJylel8PbYBGWnyGmMohsmcZcGbvbG)cM0vI6q30qSfIf(0a4U(L14V7C9F7dU6913EF86Zwiw4ZLQx)WPBAxFDcJadAlBfWAK(yyPE9pm2nRaDt76xrNniGXXPbHDAWJtyeyqBzRa4g8AfKVPbSX1lJFPbe5gCsJqTbNSbkSf3a6CAGGsiJhCdezxaH5gSkHNgiYnqZSbybrDTSge2Pbe5g4cJqTbdhNTiRbpoHrG1aSa2T0RRbIq00y013nRYZgxFHBGgdjwrl(lOeY45Q3xPI3hV(SfIf(CP613nRYZgxFxsHTWuezzZgwdK3axMLts0q6aXyyPIgUowd3a5nWLz5Ken0W40cDns)yMKiA46ynCdKKAGWnWLuylmfrw2SH1a5nWLz5KenKoqmgwQOHRJ1Wx)WPBAxFxuk)WPBA)YI1RFzX63IA(6RZAKzfF17Re8(41NTqSWNlvV(Ht30U(UOu(Ht30(LfRx)YI1Vf1813DWx9(AfEF86Zwiw4ZLQxF3SkpBC9dNUu4pBC9Y4g4zdE71pC6M213fLYpC6M2VSy96xwS(TOMV(y9Q3xPc3hV(SfIf(CP613nRYZgx)WPlf(ZgxVmUbE0GQx)WPBAxFxuk)WPBA)YI1RFzX63IA(6RZ6iJHLk(Qx96lyyxwlg69X7REVpE9dNUPD9ftvl85txcz8H4AK(As91U(SfIf(CP6vVVw9(41pC6M21NUWyyUjO1RpBHyHpxQE17RV9(41NTqSWNlvV(UzvE246pqgtNdjgHtOcDoK4pxlYdgXwiw4Z1pC6M21xJ5Rti4Q3xPI3hV(SfIf(CP61xWWUaRFDR5RV3hC9dNUPD9pjKyH)Ai467Mv5zJRF40Lc)zJRxg3apAG3gij1aHBGlPWwykISSzdRbYBGWnqJcBkIswkSmeBHyHpx9(kbVpE9zlel85s1RFk46Jz96hoDt76tjMnel81NsuG4RFHjX2jgzioivynkPH)6aXF60bHrSfIf(0a5naZQUgjmIdsfwJsAFmXqaITqSWNR)HXUzfOBAx)3almsCd0SbEBGMnaV1qLq5gur(yfL399RO0asCmyIHGg84aXyyP2abd7cSIU(uI5BrnF9zL(lyyxG1REFTcVpE9zlel85s1RVBwLNnU(uIzdXcJyL(lyyxG1RF40nTRVoqmgwQx9(kv4(41NTqSWNlvV(UzvE246hoDPWF246LXnWZg82giVbW3aHBGlPWwykISSzdRbYBGWnqJcBkIswkSmeBHyHpnqsQbHtxk8NnUEzCd8SbvBaCnqEdeUbuIzdXcJyL(lyyxG1RF40nTRFS185JHL6vVVwbFF86Zwiw4ZLQxF3SkpBC9dNUu4pBC9Y4g4rdQ2ajPgaFdCjf2ctrKLnBynqsQbAuytruYsHLHylel8PbW1a5niC6sH)SX1lJBWZguTbssnGsmBiwyeR0Fbd7cSE9dNUPD9XkhhzFmSuV6vV(Ud((49vV3hV(SfIf(CP613nRYZgxF4BGiennshigdlveKGgiVbIq00OHXPf6AK(XmjreKGgiVbUKcBHPiYYMnSgaxdKKAa8nqeIMgPdeJHLkcsqdK3ariAAeXTC(yb7SkgbjObYBGlPWwykYwsW0pDWnaUgij1a4BGlPWwykIcBkmztdKKAGlPWwykYy3KLConaUgiVbIq00iDGymSurqcAGKudetmUbYBa9scM(hUowd3apBG332ajPgaFdCjf2ctrKLnBynqEdeHOPrdJtl01i9JzsIiibnqEd0yiXks3A(R5)SCd8SbuH32a4U(Ht30U(I8G5H8AKU691Q3hV(SfIf(CP613nRYZgxFriAAKoqmgwQiibnqsQbUmlNKOH0bIXWsfnCDSgUbE0G3(Ggij1aXeJBG8gqVKGP)HRJ1WnWZg4TcV(Ht30U(ILmpFAOr2vVV(27JxF2cXcFUu967Mv5zJRViennshigdlveKGgij1axMLts0q6aXyyPIgUowd3apAWBFqdKKAGyIXnqEdOxsW0)W1XA4g4zd8wHx)WPBAx)WCmwNO8DrPC17RuX7JxF2cXcFUu967Mv5zJRViennshigdlveKGgij1axMLts0q6aXyyPIgUowd3apAWBFqdKKAGyIXnqEdOxsW0)W1XA4g4zdQ4U(Ht30U(07WILmpx9(kbVpE9zlel85s1RVBwLNnU(Iq00iDGymSurNKOD9dNUPD9lljyk(xbb0HunB6vVVwH3hV(SfIf(CP613nRYZgxFriAAKoqmgwQiibnqEdGVbIq00iXsMNcewrqcAGKud0yiXkcghffgsGtBGNnO6dAaCnqsQbIjg3a5nGEjbt)dxhRHBGNnOAf2ajPgaFdCjf2ctrKLnBynqEdeHOPrdJtl01i9JzsIiibnqEdOxsW0)W1XA4g4zdOcvBaCx)WPBAxFbPUPD1RE9X69X7REVpE9zlel85s1RVBwLNnU(AuytryLJJSpD6GWi2cXcFAG8gaFdemmLpj3b5fHvooY(yyP2a5nqeIMgHvooY(0PdcJgUowd3apBabBGKudeHOPryLJJSpD6GWOts0AaCnqEdGVbIq00OHXPf6AK(Xmjr0jjAnqsQbc3axsHTWuezzZgwdG76hoDt76JvooY(yyPE17RvVpE9dNUPD9jVLYhdl1RpBHyHpxQE17RV9(41NTqSWNlvV(UzvE2467skSfMIilB2WAG8gaFdCzwojrdnmoTqxJ0pMjjIgUowd3apBaj3PbW1ajPgiCdCjf2ctrKLnBynqEdeUbUKcBHPiBjbt)0b3ajPg4skSfMISLem9thCdK3a4BGlZYjjAiIB58Xc2zvmA46ynCd8SbKCNgij1axMLts0qe3Y5JfSZQy0W1XA4g4rdE7dAaCnqsQbAmKyfPBn)18FwUbE2aVe86hoDt76FsiXc)1qWvVVsfVpE9zlel85s1RF40nTRpDjg(67Mv5zJRVgZxNqacsqdK3GbYy6CiXiCcvOZHe)5ArEWi2cXcFU(L14V7C9RsWREFLG3hV(SfIf(CP613nRYZgx)bYy6CiXiCcvOZHe)5ArEWi2cXcFAG8gOX81jeGgUowd3apBaj3PbYBGlZYjjAi6smmA46ynCd8SbKCNRF40nTRVgZxNqWvVVwH3hV(Ht30U(m1fus8sH)yyPE9zlel85s1REFLkCF86hoDt76tClNpwWoRIV(SfIf(CP6vVVwbFF86hoDt76txcz85JHL61NTqSWNlvV691kU7JxF2cXcFUu967Mv5zJRpD6GWnOYg4cS(hMeBnWZgqNoimQoO(1pC6M21)WHc77GfKNO(Q3x9(G7Jx)WPBAx)4xdnhE(j93njr81NTqSWNlvV69vVEVpE9zlel85s1RVBwLNnU(UmlNKOHggNwORr6hZKerdxhRHBGNnGK70a5na(giCd0OWMIyQlOK4Lc)XWsfXwiw4tdKKAGiennsSK5PaHveKGgaxdKKAGWnWLuylmfrw2SH1ajPg4YSCsIgAyCAHUgPFmtsenCDSgUbssnqmX4giVb0ljy6F46ynCd8Sbe86hoDt76tm2YAK(XmjXREF1B17JxF2cXcFUu967Mv5zJRVienn6KqIf(RHaeKGgij1aHBGgf2u0jHel8xdbi2cXcFAGKudetmUbYBa9scM(hUowd3apBG3Qx)WPBAx)HXPf6AK(XmjXREF17BVpE9zlel85s1RVBwLNnU(Iq00OHXPf6AK(XmjreKGgij1aHBGlPWwykISSzdRbYBa8nqeIMgjyy3I5pgwQy0jjAnqsQbc3ankSPihSTo4j(yyPIylel8PbssniC6sH)SX1lJBGNnOAdG76hoDt76tjlfw2vVV6LkEF86Zwiw4ZLQxF3SkpBC9Djf2ctrKLnBynqEdOtheUbv2axG1)WKyRbE2a60bHr1b1BG8gaFdGVbUmlNKOHggNwORr6hZKerdxhRHBGNnGK70GkWg82giVbW3aHBaoHkIRDqmnneEPW)W264hohx4j0CqSfIf(0ajPgiCd0OWMIojKyH)AiaXwiw4tdGRbW1ajPgOrHnfDsiXc)1qaITqSWNgiVbUmlNKOHojKyH)AianCDSgUbE2G32a4U(Ht30U(yLJJSpgwQx9(QxcEF86Zwiw4ZLQxF3SkpBC9fHOPrcg2Ty(JHLkgDsIwdK3a4BGlPWwykIcBkmztdKKAGlPWwykYy3KLConqsQbAuytrUOuwJ0xHXFmSuXi2cXcFAaCnqsQbIq00OHXPf6AK(XmjreKGgij1ariAAeXTC(yb7SkgbjObssnqeIMgrjlfwgcsqdK3GWPlf(ZgxVmUbE0aVnqsQbIjg3a5nGEjbt)dxhRHBGNnOkbV(Ht30U(6aXyyPE17RERW7JxF2cXcFUu967Mv5zJRViennsWWUfZFmSuXiibnqsQb0Pdc3apAGlXAdQSbHt30qXwZNpgwQixI1RF40nTR)ec2ZNEh(Q3x9sfUpE9zlel85s1RF40nTRFS185JHL613nRYZgxFriAAKGHDlM)yyPIrNKO1ajPgaFdeHOPr6aXyyPIGe0ajPgqdvk)HDWIHe)1TMBGNnGK70GkBGlW6x3AUbW1a5na(giCd0OWMICW26GN4JHLkITqSWNgij1GWPlf(ZgxVmUbE2GQnaUgij1ariAAKoRJ8hdlvmA46ynCd8Obm1zhKYFDR5giVbHtxk8NnUEzCd8ObEV(ozUc)1yiXk((Q3REF1Bf89XRpBHyHpxQE9DZQ8SX1h(g4YSCsIg6KqIf(RHa0W1XA4g4rdi5onOcSbeSbssnq4g4skSfMIilB2WAGKudeUbAuytrNesSWFneGylel8PbW1a5nGoDq4guzdCbw)dtITg4zdOthegvhuVbYBa8nqeIMgPdeJHLk6KeTgij1aHBqHjX2jgzioivynkPH)6aXF60bHrSfIf(0a4AG8gaFdeHOPrNesSWFneGojrRbssnqJcBkcRdh1L1yeBHyHpnaURF40nTR)ec2ZNEh(Q3x9wXDF86Zwiw4ZLQxF3SkpBC9fHOPrcg2Ty(JHLkgbjObssnGoDq4g4rdCjwBqLniC6Mgk2A(8XWsf5sSE9dNUPD9DW26GN4JHL6vVVw9b3hV(SfIf(CP613nRYZgxFriAAKGHDlM)yyPIrqcAGKudOtheUbE0axI1guzdcNUPHITMpFmSurUeRx)WPBAx)yCHXFmSuV691QEVpE9zlel85s1RF40nTRpMhbSPFSUgPRVBwLNnU(dtpmgwiw4giVbAmKyfPBn)18FwUbE0Gd0e6M213jZv4VgdjwX3x9E17RvREF86Zwiw4ZLQxF3SkpBC9dNUu4pBC9Y4g4rd8E9dNUPD9fJzcs8vVVw9T3hV(SfIf(CP613nRYZgxF4BGlZYjjAOtcjw4VgcqdxhRHBGhnGK70GkWgqWgiVbdKX05qIryOH0AK(yyPIrSfIf(0ajPgiCdCjf2ctrKLnBynqsQbc3ankSPOtcjw4VgcqSfIf(0a4AG8gqNoiCdQSbUaR)HjXwd8Sb0PdcJQdQ3a5na(gicrtJojKyH)AiaDsIwdKKAGgf2uewhoQlRXi2cXcFAaCx)WPBAx)jeSNp9o8vVVwLkEF86Zwiw4ZLQxF3SkpBC9fHOPr6aXyyPIojr76hoDt76lgK(j9xN1rgF17Rvj49XRpBHyHpxQE9DZQ8SX1hNqfX1oibqyfQWFEGeOBAi2cXcFAG8gicrtJ0bIXWsfDsI21pC6M21NUWyyUjO1REFTAfEF86hoDt76JvooY(yyPE9zlel85s1RE1RVoRrMv89X7REVpE9zlel85s1RFk46Jz96hoDt76tjMnel81NsuG4RViennAyCAHUgPFmtsebjObssnqeIMgPdeJHLkcsW1NsmFlQ5RpwM5(qcU691Q3hV(SfIf(CP61pfC9XSE9dNUPD9PeZgIf(6tjkq813Luylmfrw2SH1a5nqeIMgnmoTqxJ0pMjjIGe0a5nqeIMgPdeJHLkcsqdKKAGWnWLuylmfrw2SH1a5nqeIMgPdeJHLkcsW1NsmFlQ5RpwN0i9XYm3hsWvVV(27JxF2cXcFUu96NcU(ywx6RF40nTRpLy2qSWxFkX8TOMV(yDsJ0hlZC)HRJ1WxF3SkpBC9fHOPr6aXyyPIojr76tjkq8Nly(67YSCsIgshigdlv0W1XA4RpLOaXxFxMLts0qdJtl01i9JzsIOHRJ1WnWZkOnWLz5KenKoqmgwQOHRJ1Wx9(kv8(41NTqSWNlvV(PGRpM1L(6hoDt76tjMnel81NsmFlQ5RpwN0i9XYm3F46yn813nRYZgxFriAAKoqmgwQiibxFkrbI)CbZxFxMLts0q6aXyyPIgUowdF9Pefi(67YSCsIgAyCAHUgPFmtsenCDSg(Q3xj49XRpBHyHpxQE9tbxFmRl91pC6M21NsmBiw4RpLy(wuZxFSmZ9hUowdF9DZQ8SX13Luylmfrw2SHD9Pefi(ZfmF9DzwojrdPdeJHLkA46yn81NsuG4RVlZYjjAOHXPf6AK(Xmjr0W1XA4g4rf0g4YSCsIgshigdlv0W1XA4REFTcVpE9zlel85s1RF40nTRpeM)RY14RVBwLNnU(W3aDwJmRi1lcwG)qy(lcrt3ajPg4skSfMIilB2WAG8gOZAKzfPErWc83Lz5KeTgaxdK3a4BaLy2qSWiSoPr6JLzUpKGgiVbW3aHBGlPWwykISSzdRbYBGWnqN1iZksRIGf4peM)Iq00nqsQbUKcBHPiYYMnSgiVbc3aDwJmRiTkcwG)UmlNKO1ajPgOZAKzfPvrUmlNKOHgUowd3ajPgOZAKzfPErWc8hcZFriA6giVbW3aHBGoRrMvKwfblWFim)fHOPBGKud0znYSIuVixMLts0qhOj0nTg4XZgOZAKzfPvrUmlNKOHoqtOBAnaUgij1aDwJmRi1lcwG)UmlNKO1a5nq4gOZAKzfPvrWc8hcZFriA6giVb6SgzwrQxKlZYjjAOd0e6Mwd84zd0znYSI0QixMLts0qhOj0nTgaxdKKAGWnGsmBiwyewN0i9XYm3hsqdK3a4BGWnqN1iZksRIGf4peM)Iq00nqEdGVb6SgzwrQxKlZYjjAOd0e6MwdOYgqWg4zdOeZgIfgHLzU)W1XA4gij1akXSHyHryzM7pCDSgUbE0aDwJmRi1lYLz5Ken0bAcDtRbV3GQnaUgij1aDwJmRiTkcwG)qy(lcrt3a5na(gOZAKzfPErWc8hcZFriA6giVb6SgzwrQxKlZYjjAOd0e6Mwd84zd0znYSI0QixMLts0qhOj0nTgiVbW3aDwJmRi1lYLz5Ken0bAcDtRbuzdiyd8SbuIzdXcJWYm3F46ynCdKKAaLy2qSWiSmZ9hUowd3apAGoRrMvK6f5YSCsIg6anHUP1G3Bq1gaxdKKAa8nq4gOZAKzfPErWc8hcZFriA6gij1aDwJmRiTkYLz5Ken0bAcDtRbE8Sb6SgzwrQxKlZYjjAOd0e6MwdGRbYBa8nqN1iZksRICzwojrdnCCK1a5nqN1iZksRICzwojrdDGMq30Aav2ac2apAaLy2qSWiSmZ9hUowd3a5nGsmBiwyewM5(dxhRHBGNnqN1iZksRICzwojrdDGMq30AW7nOAdKKAGWnqN1iZksRICzwojrdnCCK1a5na(gOZAKzfPvrUmlNKOHgUowd3aQSbeSbE2akXSHyHryDsJ0hlZC)HRJ1WnqEdOeZgIfgH1jnsFSmZ9hUowd3apAq1h0a5na(gOZAKzfPErUmlNKOHoqtOBAnGkBabBGNnGsmBiwyewM5(dxhRHBGKud0znYSI0QixMLts0qdxhRHBav2ac2apBaLy2qSWiSmZ9hUowd3a5nqN1iZksRICzwojrdDGMq30Aav2aVpObv2akXSHyHryzM7pCDSgUbE2akXSHyHryDsJ0hlZC)HRJ1WnqsQbuIzdXcJWYm3F46ynCd8Ob6SgzwrQxKlZYjjAOd0e6MwdEVbvBGKudOeZgIfgHLzUpKGgaxdKKAGoRrMvKwf5YSCsIgA46ynCdOYgqWg4rdOeZgIfgH1jnsFSmZ9hUowd3a5na(gOZAKzfPErUmlNKOHoqtOBAnGkBabBGNnGsmBiwyewN0i9XYm3F46ynCdKKAGWnqN1iZks9IGf4peM)Iq00nqEdGVbuIzdXcJWYm3F46ynCd8Ob6SgzwrQxKlZYjjAOd0e6MwdEVbvBGKudOeZgIfgHLzUpKGgaxdGRbW1a4AaCnaUgij1angsSI0TM)A(pl3apBaLy2qSWiSmZ9hUowd3a4AGKudeUb6SgzwrQxeSa)HW8xeIMUbYBGWnWLuylmfrw2SH1a5na(gOZAKzfPvrWc8hcZFriA6giVbW3a4BGWnGsmBiwyewM5(qcAGKud0znYSI0QixMLts0qdxhRHBGhnGGnaUgiVbW3akXSHyHryzM7pCDSgUbE0GQpObssnqN1iZksRICzwojrdnCDSgUbuzdiyd8ObuIzdXcJWYm3F46ynCdGRbW1ajPgiCd0znYSI0Qiyb(dH5VienDdK3a4BGWnqN1iZksRIGf4VlZYjjAnqsQb6SgzwrAvKlZYjjAOHRJ1WnqsQb6SgzwrAvKlZYjjAOd0e6Mwd84zd0znYSIuVixMLts0qhOj0nTgaxdG76JlPIV(6Sgzw9E17RuH7JxF2cXcFUu96hoDt76dH5)QCn(67Mv5zJRp8nqN1iZksRIGf4peM)Iq00nqsQbUKcBHPiYYMnSgiVb6SgzwrAveSa)DzwojrRbW1a5na(gqjMnelmcRtAK(yzM7djObYBa8nq4g4skSfMIilB2WAG8giCd0znYSIuViyb(dH5VienDdKKAGlPWwykISSzdRbYBGWnqN1iZks9IGf4VlZYjjAnqsQb6SgzwrQxKlZYjjAOHRJ1WnqsQb6SgzwrAveSa)HW8xeIMUbYBa8nq4gOZAKzfPErWc8hcZFriA6gij1aDwJmRiTkYLz5Ken0bAcDtRbE8Sb6SgzwrQxKlZYjjAOd0e6MwdGRbssnqN1iZksRIGf4VlZYjjAnqEdeUb6SgzwrQxeSa)HW8xeIMUbYBGoRrMvKwf5YSCsIg6anHUP1apE2aDwJmRi1lYLz5Ken0bAcDtRbW1ajPgiCdOeZgIfgH1jnsFSmZ9He0a5na(giCd0znYSIuViyb(dH5VienDdK3a4BGoRrMvKwf5YSCsIg6anHUP1aQSbeSbE2akXSHyHryzM7pCDSgUbssnGsmBiwyewM5(dxhRHBGhnqN1iZksRICzwojrdDGMq30AW7nOAdGRbssnqN1iZks9IGf4peM)Iq00nqEdGVb6SgzwrAveSa)HW8xeIMUbYBGoRrMvKwf5YSCsIg6anHUP1apE2aDwJmRi1lYLz5Ken0bAcDtRbYBa8nqN1iZksRICzwojrdDGMq30Aav2ac2apBaLy2qSWiSmZ9hUowd3ajPgqjMnelmclZC)HRJ1WnWJgOZAKzfPvrUmlNKOHoqtOBAn49guTbW1ajPgaFdeUb6SgzwrAveSa)HW8xeIMUbssnqN1iZks9ICzwojrdDGMq30AGhpBGoRrMvKwf5YSCsIg6anHUP1a4AG8gaFd0znYSIuVixMLts0qdhhznqEd0znYSIuVixMLts0qhOj0nTgqLnGGnWJgqjMnelmclZC)HRJ1WnqEdOeZgIfgHLzU)W1XA4g4zd0znYSIuVixMLts0qhOj0nTg8EdQ2ajPgiCd0znYSIuVixMLts0qdhhznqEdGVb6SgzwrQxKlZYjjAOHRJ1WnGkBabBGNnGsmBiwyewN0i9XYm3F46ynCdK3akXSHyHryDsJ0hlZC)HRJ1WnWJgu9bnqEdGVb6SgzwrAvKlZYjjAOd0e6MwdOYgqWg4zdOeZgIfgHLzU)W1XA4gij1aDwJmRi1lYLz5Ken0W1XA4gqLnGGnWZgqjMnelmclZC)HRJ1WnqEd0znYSIuVixMLts0qhOj0nTgqLnW7dAqLnGsmBiwyewM5(dxhRHBGNnGsmBiwyewN0i9XYm3F46ynCdKKAaLy2qSWiSmZ9hUowd3apAGoRrMvKwf5YSCsIg6anHUP1G3Bq1gij1akXSHyHryzM7djObW1ajPgOZAKzfPErUmlNKOHgUowd3aQSbeSbE0akXSHyHryDsJ0hlZC)HRJ1WnqEdGVb6SgzwrAvKlZYjjAOd0e6MwdOYgqWg4zdOeZgIfgH1jnsFSmZ9hUowd3ajPgiCd0znYSI0Qiyb(dH5VienDdK3a4BaLy2qSWiSmZ9hUowd3apAGoRrMvKwf5YSCsIg6anHUP1G3Bq1gij1akXSHyHryzM7djObW1a4AaCnaUgaxdGRbssnqJHeRiDR5VM)ZYnWZgqjMnelmclZC)HRJ1WnaUgij1aHBGoRrMvKwfblWFim)fHOPBG8giCdCjf2ctrKLnBynqEdGVb6SgzwrQxeSa)HW8xeIMUbYBa8na(giCdOeZgIfgHLzUpKGgij1aDwJmRi1lYLz5Ken0W1XA4g4rdiydGRbYBa8nGsmBiwyewM5(dxhRHBGhnO6dAGKud0znYSIuVixMLts0qdxhRHBav2ac2apAaLy2qSWiSmZ9hUowd3a4AaCnqsQbc3aDwJmRi1lcwG)qy(lcrt3a5na(giCd0znYSIuViyb(7YSCsIwdKKAGoRrMvK6f5YSCsIgA46ynCdKKAGoRrMvK6f5YSCsIg6anHUP1apE2aDwJmRiTkYLz5Ken0bAcDtRbW1a4U(4sQ4RVoRrM1Qx9Qx96tHh8M291QpOQ3hqfEG3RpXyS1iHV(eORyR4FTI41kAcObn4ryCd2Ab5OnGoNgqOoRJmgwQycBWWeyq7WNgGZAUbbKM1HYNg4GfgjgJAHE4ACd8san4nPrHhLpnGqnkSPiQryd0SbeQrHnfrneBHyHpe2a49sD4qTqpCnUbVLaAWBsJcpkFAaHdKX05qIruJWgOzdiCGmMohsmIAi2cXcFiSbW7L6WHAHE4ACdOIeqdEtAu4r5tdiCGmMohsmIAe2anBaHdKX05qIrudXwiw4dHni0gursG6HnaEVuhoul0dxJBavGaAWBsJcpkFAaHAuytruJWgOzdiuJcBkIAi2cXcFiSbW7L6WHAHE4ACdQGjGg8M0OWJYNgqOgf2ue1iSbA2ac1OWMIOgITqSWhcBa8EPoCOwOhUg3aVvjGg8M0OWJYNgqOgf2ue1iSbA2ac1OWMIOgITqSWhcBa8EPoCOwOhUg3aVvjGg8M0OWJYNgq4azmDoKye1iSbA2achiJPZHeJOgITqSWhcBa8EPoCOwOhUg3aVeKaAWBsJcpkFAaHAuytruJWgOzdiuJcBkIAi2cXcFiSbWxL6WHAHE4ACd8sqcObVjnk8O8PbeoqgtNdjgrncBGMnGWbYy6CiXiQHylel8HWgaVxQdhQf6HRXnWBfsan4nPrHhLpnGqnkSPiQryd0SbeQrHnfrneBHyHpe2a49sD4qTqpCnUbvFlb0G3KgfEu(0achiJPZHeJOgHnqZgq4azmDoKye1qSfIf(qydcTbvKeOEydG3l1Hd1c9W14guLksan4nPrHhLpnGWbYy6CiXiQryd0SbeoqgtNdjgrneBHyHpe2GqBqfjbQh2a49sD4qTqTqeORyR4FTI41kAcObn4ryCd2Ab5OnGoNgq4HPdOIsydgMadAh(0aCwZniG0Sou(0ahSWiXyul0dxJBqvcObVjnk8O8PbeoqgtNdjgrncBGMnGWbYy6CiXiQHylel8HWgaVxQdhQf6HRXnOkb0G3KgfEu(0achiJPZHeJOgHnqZgq4azmDoKye1qSfIf(qydG3l1Hd1c9W14guLaAWBsJcpkFAaHU0oqRIOgHnqZgqOlTd0QiQHylel8HWgaVxQdhQf6HRXnOkb0G3KgfEu(0acXjurCTdIAe2anBaH4eQiU2brneBHyHpe2a49sD4qTqTqeORyR4FTI41kAcObn4ryCd2Ab5OnGoNgqOGHDzTyOe2GHjWG2HpnaN1CdcinRdLpnWblmsmg1c9W14g8wcObVjnk8O8PbeoqgtNdjgrncBGMnGWbYy6CiXiQHylel8HWgeAdQijq9WgaVxQdhQf6HRXnGksan4nPrHhLpnGqnkSPiQryd0SbeQrHnfrneBHyHpe2GqBqfjbQh2a49sD4qTqpCnUbubcObVjnk8O8PbeQrHnfrncBGMnGqnkSPiQHylel8HWgaVxQdhQf6HRXnOcMaAWBsJcpkFAaHAuytruJWgOzdiuJcBkIAi2cXcFiSbW7L6WHAHAHiqxXwX)AfXRv0eqdAWJW4gS1cYrBaDonGqSsydgMadAh(0aCwZniG0Sou(0ahSWiXyul0dxJBGxcObVjnk8O8PbeQrHnfrncBGMnGqnkSPiQHylel8HWgaVxQdhQf6HRXnGksan4nPrHhLpnGWbYy6CiXiQryd0SbeoqgtNdjgrneBHyHpe2GqBqfjbQh2a49sD4qTqpCnUbeKaAWBsJcpkFAaHdKX05qIruJWgOzdiCGmMohsmIAi2cXcFiSbW7L6WHAHE4ACd86LaAWBsJcpkFAaHAuytruJWgOzdiuJcBkIAi2cXcFiSbW7L6WHAHE4ACd8wLaAWBsJcpkFAaHAuytruJWgOzdiuJcBkIAi2cXcFiSbW7L6WHAHE4ACd8(wcObVjnk8O8PbeQrHnfrncBGMnGqnkSPiQHylel8HWgaVxQdhQf6HRXnWlvKaAWBsJcpkFAaHAuytruJWgOzdiuJcBkIAi2cXcFiSbWxL6WHAHE4ACd8sfjGg8M0OWJYNgqioHkIRDquJWgOzdieNqfX1oiQHylel8HWgaVxQdhQf6HRXnWlbjGg8M0OWJYNgqOgf2ue1iSbA2ac1OWMIOgITqSWhcBa8EPoCOwOhUg3aVvib0G3KgfEu(0ac1OWMIOgHnqZgqOgf2ue1qSfIf(qydGVk1Hd1c9W14g4TcjGg8M0OWJYNgq4azmDoKye1iSbA2achiJPZHeJOgITqSWhcBa8EPoCOwOhUg3aVubcObVjnk8O8PbeQrHnfrncBGMnGqnkSPiQHylel8HWgaVxQdhQf6HRXnWBfmb0G3KgfEu(0ac1OWMIOgHnqZgqOgf2ue1qSfIf(qydGVk1Hd1c9W14gu9TeqdEtAu4r5tdiuJcBkIAe2anBaHAuytrudXwiw4dHna(Quhoul0dxJBq13san4nPrHhLpnGWbYy6CiXiQryd0SbeoqgtNdjgrneBHyHpe2a49sD4qTqpCnUbvjib0G3KgfEu(0acXjurCTdIAe2anBaH4eQiU2brneBHyHpe2a49sD4qTqTqeORyR4FTI41kAcObn4ryCd2Ab5OnGoNgqOoRrMvmHnyycmOD4tdWzn3GasZ6q5tdCWcJeJrTqpCnUbvib0G3KgfEu(0a)T(nnalZ0G6nGaPbA2Ghcfn4Suw8Mwdsb8eAona(3HRbWtqQdhQf6HRXnOcjGg8M0OWJYNgqOoRrMvKxe1iSbA2ac1znYSIuViQrydGVQxQdhQf6HRXnOcjGg8M0OWJYNgqOoRrMvuve1iSbA2ac1znYSI0QiQrydGVAfsD4qTqpCnUbubcObVjnk8O8Pb(B9BAawMPb1Babsd0SbpekAWzPS4nTgKc4j0CAa8VdxdGNGuhoul0dxJBavGaAWBsJcpkFAaH6SgzwrEruJWgOzdiuN1iZks9IOgHna(Qvi1Hd1c9W14gqfiGg8M0OWJYNgqOoRrMvuve1iSbA2ac1znYSI0QiQrydGVQxQdhQfQfQIOwqokFAqf2GWPBAnOSyfJAHU(ybS7(AvcsfV(cMKEl81NaNaVbvmIHmUommSvqdQOcYuEAHiWjWBGqqfznOcFPbvFqvVTqTqHt30Wibd7YAXqR857IPQf(8PlHm(qCnsFnP(ATqHt30Wibd7YAXqR8570fgdZnbT2cfoDtdJemSlRfdTYNVRX81je8Ys)CGmMohsmcNqf6CiXFUwKhClu40nnmsWWUSwm0kF((jHel8xdbViyyxG1VU18tVp4LL(z40Lc)zJRxg7HxjjHDjf2ctrKLnByYfwJcBkIswkSSwic8g8gyHrIBGMnWBd0Sb4TgQek3GkYhRO8UVFfLgqIJbtme0Ghhigdl1giyyxGvulu40nnmsWWUSwm0kF(oLy2qSWVyrn)Kv6VGHDbwFHsuG4NfMeBNyKH4GuH1OKg(Rde)PthegXwiw4JCmR6AKWioivynkP9Xedbi2cXcFAHcNUPHrcg2L1IHw5Z31bIXWs9LL(jLy2qSWiwP)cg2fyTfkC6MggjyyxwlgALpFp2A(8XWs9LL(z40Lc)zJRxg75BLdVWUKcBHPiYYMnm5cRrHnfrjlfwMKu40Lc)zJRxg7zv4KlmLy2qSWiwP)cg2fyTfkC6MggjyyxwlgALpFhRCCK9XWs9LL(z40Lc)zJRxg7rvjj4Djf2ctrKLnByssAuytruYsHLbN8WPlf(ZgxVm(zvjjkXSHyHrSs)fmSlWAlulu40nnCLpF3LqMYZhdl1wOWPBA4kF(UlHmLNpgwQVuwJ)UZZ3(Gxw6NdKX05qIrywamOka8xWKUsuh6MMKeoHkIRDq2klWFnZc(lixCAssW7s7aTkAyk8GJYpP)05Oqglx4bYy6CiXimlagufa(lysxjQdDtdUwic8gurNniGXXPbHDAWJtyeyqBzRa4g8AfKVPbSX1lJROUbe5gCsJqTbNSbkSf3a6CAGGsiJhCdezxaH5gSkHNgiYnqZSbybrDTSge2Pbe5g4cJqTbdhNTiRbpoHrG1aSa2T0RRbIq00yulu40nnCLpFxNWiWG2YwbSgPpgwQVS0pfwJHeROf)fucz80crGtG3GkMCjK1a6WTgPgilHMgCsirTbqMULgilHAaSGc3abqAdQ4zCAHUgPguXotsSbNKO9sdYPblDduyCdCzwojrRblUbAMnOKgPgOzdoCjK1a6WTgPgilHMguXmHevudQiOBGLg3GKUbkmgZnWL2z1nnCdIHBqiw4gOzdQzTbexf2AnqHXnW7dAaMDPDWnOWmXq2lnqHXnaV1nGoCmUbYsOPbvmtirTbbKM1HUUOuKHAHiWjWBq40nnCLpF3yI0jKD(dJZcf(LL(joHkIRDqgtKoHSZFyCwOWYHxeIMgnmoTqxJ0pMjjIGeij5YSCsIgAyCAHUgPFmtsenCDSg2dVpqssmXy50ljy6F46ynSNERqjjHDjf2ctrKLnByW1cfoDtdx5Z3DrP8dNUP9llwFXIA(PoRrMv8ll9txsHTWuezzZgMCxMLts0q6aXyyPIgUowdl3Lz5Ken0W40cDns)yMKiA46ynSKKWUKcBHPiYYMnm5UmlNKOH0bIXWsfnCDSgUfkC6MgUYNV7Is5hoDt7xwS(If18t3b3cfoDtdx5Z3DrP8dNUP9llwFXIA(jwFzPFgoDPWF246LXE(2wOWPBA4kF(UlkLF40nTFzX6lwuZp1zDKXWsf)Ys)mC6sH)SX1lJ9OAlulu40nnmYDWpf5bZd51i9Ys)eEriAAKoqmgwQiibYfHOPrdJtl01i9JzsIiibYDjf2ctrKLnByWjjbViennshigdlveKa5Iq00iIB58Xc2zvmcsGCxsHTWuKTKGPF6GHtscExsHTWuef2uyYgjjxsHTWuKXUjl5CGtUiennshigdlveKajjXeJLtVKGP)HRJ1WE69TssW7skSfMIilB2WKlcrtJggNwORr6hZKerqcKRXqIvKU18xZ)zzpPcVfUwOWPBAyK7GR857ILmpFAOr2ll9triAAKoqmgwQiibssUmlNKOH0bIXWsfnCDSg2J3(ajjXeJLtVKGP)HRJ1WE6TcBHcNUPHrUdUYNVhMJX6eLVlkLxw6NIq00iDGymSurqcKKCzwojrdPdeJHLkA46ynShV9bssIjglNEjbt)dxhRH90Bf2cfoDtdJChCLpFNEhwSK55LL(PiennshigdlveKajjxMLts0q6aXyyPIgUowd7XBFGKKyIXYPxsW0)W1XAypR4AHcNUPHrUdUYNVxwsWu8VccOdPA20xw6NIq00iDGymSurNKO1cfoDtdJChCLpFxqQBAVS0pfHOPr6aXyyPIGeihEriAAKyjZtbcRiibssAmKyfbJJIcdjWPEw9bWjjjMySC6Lem9pCDSg2ZQvOKe8UKcBHPiYYMnm5Iq00OHXPf6AK(XmjreKa50ljy6F46ynSNuHQW1c1cfoDtdJW6tSYXr2hdl1xw6NAuytryLJJSpD6GWYHxWWu(KChKxew54i7JHLQCriAAew54i7tNoimA46ynSNeusseIMgHvooY(0PdcJojrdo5WlcrtJggNwORr6hZKerNKOjjjSlPWwykISSzddUwOWPBAyewR857K3s5JHLAlu40nnmcRv(89tcjw4VgcEzPF6skSfMIilB2WKdVlZYjjAOHXPf6AK(Xmjr0W1XAypj5oWjjjSlPWwykISSzdtUWUKcBHPiBjbt)0blj5skSfMISLem9thSC4DzwojrdrClNpwWoRIrdxhRH9KK7ij5YSCsIgI4woFSGDwfJgUowd7XBFaCssAmKyfPBn)18Fw2tVeSfkC6MggH1kF(oDjg(LYA83DEwLGVS0p1y(6ecqqcKpqgtNdjgHtOcDoK4pxlYdUfkC6MggH1kF(UgZxNqWll9ZbYy6CiXiCcvOZHe)5ArEWY1y(6ecqdxhRH9KK7i3Lz5KeneDjggnCDSg2tsUtlu40nnmcRv(8DM6ckjEPWFmSuBHcNUPHryTYNVtClNpwWoRIBHcNUPHryTYNVtxcz85JHLAlu40nnmcRv(89dhkSVdwqEI6xw6N0PdcxPlW6FysS5jD6GWO6G6TqHt30WiSw5Z3JFn0C45N0F3KeXTqHt30WiSw5Z3jgBzns)yMK4ll9txMLts0qdJtl01i9JzsIOHRJ1WEsYDKdVWAuytrm1fus8sH)yyPkjjcrtJelzEkqyfbjaojjHDjf2ctrKLnByssUmlNKOHggNwORr6hZKerdxhRHLKetmwo9scM(hUowd7jbBHcNUPHryTYNVpmoTqxJ0pMjj(Ys)ueIMgDsiXc)1qacsGKKWAuytrNesSWFneijjMySC6Lem9pCDSg2tVvBHcNUPHryTYNVtjlfw2ll9triAA0W40cDns)yMKicsGKKWUKcBHPiYYMnm5WlcrtJemSBX8hdlvm6KenjjH1OWMICW26GN4JHLQKu40Lc)zJRxg7zv4AHcNUPHryTYNVJvooY(yyP(Ys)0Luylmfrw2SHjNoDq4kDbw)dtInpPthegvhuxo8W7YSCsIgAyCAHUgPFmtsenCDSg2tsUtf4BLdVW4eQiU2bX00q4Lc)dBRJF4CCHNqZrssynkSPOtcjw4VgcGdojjnkSPOtcjw4VgcK7YSCsIg6KqIf(RHa0W1XAypFlCTqHt30WiSw5Z31bIXWs9LL(PiennsWWUfZFmSuXOts0KdVlPWwykIcBkmzJKKlPWwykYy3KLCossAuytrUOuwJ0xHXFmSuXWjjjcrtJggNwORr6hZKerqcKKeHOPre3Y5JfSZQyeKajjriAAeLSuyziibYdNUu4pBC9Yyp8kjjMySC6Lem9pCDSg2ZQeSfkC6MggH1kF((ec2ZNEh(LL(5azmDoKyegAiTgPpgwQy5AuytryD4OUSglhExMLts0qNesSWFneGgUowd7bj3PcKGssc7skSfMIilB2WKKewJcBk6KqIf(RHa4cNUPHryTYNV7GT1bpXhdl1xw6NIq00ibd7wm)XWsfJGeijrNoiShUeRvgoDtdfBnF(yyPICjwBHcNUPHryTYNVhBnF(yyP(ItMRWFngsSIF69LL(PiennsWWUfZFmSuXOts0KKGxeIMgPdeJHLkcsGKenuP8h2blgs8x3A2tsUtLUaRFDRz4KdVWAuytroyBDWt8XWsvskC6sH)SX1lJ9SkCssIq00iDwh5pgwQy0W1XAypyQZoiL)6wZYdNUu4pBC9Yyp82cfoDtdJWALpFFcb75tVd)Ys)eExMLts0qNesSWFneGgUowd7bj3PcKGssc7skSfMIilB2WKKewJcBk6KqIf(RHa4KtNoiCLUaR)HjXMN0PdcJQdQlhEriAAKoqmgwQOts0KKeUWKy7eJmehKkSgL0WFDG4pD6GWi2cXcFGto8Iq00Otcjw4VgcqNKOjjPrHnfH1HJ6YAmCTqHt30WiSw5Z3DW26GN4JHL6ll9triAAKGHDlM)yyPIrqcKKOthe2dxI1kdNUPHITMpFmSurUeRTqHt30WiSw5Z3JXfg)XWs9LL(PiennsWWUfZFmSuXiibss0Pdc7HlXALHt30qXwZNpgwQixI1wOWPBAyewR857yEeWM(X6AKEXjZv4VgdjwXp9(Ys)Cy6HXWcXclxJHeRiDR5VM)ZYECGMq30AHcNUPHryTYNVlgZeK4xw6NHtxk8NnUEzShEBHcNUPHryTYNVpHG98P3HFzPFcVlZYjjAOtcjw4VgcqdxhRH9GK7ubsq5dKX05qIryOH0AK(yyPILKe2Luylmfrw2SHjjjSgf2u0jHel8xdbWjNoDq4kDbw)dtInpPthegvhuxo8Iq00Otcjw4VgcqNKOjjPrHnfH1HJ6YAmCTqHt30WiSw5Z3fds)K(RZ6iJFzPFkcrtJ0bIXWsfDsIwlu40nnmcRv(8D6cJH5MGwFzPFItOI4AhKaiScv4ppqc0nn5Iq00iDGymSurNKO1cfoDtdJWALpFhRCCK9XWsTfQfkC6MggPZ6iJHLk(jw54i7JHL6ll9tnkSPiSYXr2NoDqy5R9PlljyQCriAAew54i7tNoimA46ynSNeSfkC6MggPZ6iJHLkUYNVFsiXc)1qWll9txsHTWuezzZgMCxMLts0qdJtl01i9JzsIOHRJ1WEsYDKKe2Luylmfrw2SHjxyxsHTWuKTKGPF6GLKCjf2ctr2scM(Pdwo8UmlNKOHiULZhlyNvXOHRJ1WEsYDKKCzwojrdrClNpwWoRIrdxhRH94TpaojjngsSI0TM)A(pl7P3hij5YSCsIgAyCAHUgPFmtsenCDSg2dVpqE40Lc)zJRxg7XBBHcNUPHr6SoYyyPIR857AmFDcbVS0phiJPZHeJWjuHohs8NRf5blxJ5RtianCDSg2tsUJCxMLts0q0Lyy0W1XAypj5oTqHt30WiDwhzmSuXv(8D6sm8lL14V78SkbFzPFQX81jeGGeiFGmMohsmcNqf6CiXFUwKhClu40nnmsN1rgdlvCLpFNPUGsIxk8hdl1wOWPBAyKoRJmgwQ4kF(oXTC(yb7SkUfkC6MggPZ6iJHLkUYNVtm2YAK(XmjXxw6NUmlNKOHggNwORr6hZKerdxhRH9KK7ihEH1OWMIyQlOK4Lc)XWsvsseIMgjwY8uGWkcsaCssc7skSfMIilB2WKKCzwojrdnmoTqxJ0pMjjIgUowd7H3hijjMySC6Lem9pCDSg2tc2cfoDtdJ0zDKXWsfx5Z3hgNwORr6hZKeFzPFkcrtJojKyH)AiabjqssynkSPOtcjw4VgcKKetmwo9scM(hUowd7P3QTqHt30WiDwhzmSuXv(8DkzPWYEzPFkcrtJggNwORr6hZKerqcKKe2Luylmfrw2SH1cfoDtdJ0zDKXWsfx5Z3fJzcsClu40nnmsN1rgdlvCLpFxhigdl1wOWPBAyKoRJmgwQ4kF((ec2ZNEh(LL(5azmDoKyegAiTgPpgwQy5W7YSCsIgAyCAHUgPFmtsenCDSg2dVpqssyxsHTWuezzZgMKKWAuytrNesSWFneaNCriAAKoRJ8hdlvmA46ynShpzQZoiL)6wZTqHt30WiDwhzmSuXv(89yR5Zhdl1xCYCf(RXqIv8tVVS0pfHOPr6SoYFmSuXOHRJ1WE8KPo7Gu(RBnlhEriAAKGHDlM)yyPIrNKOjjrdvk)HDWIHe)1TM90fy9RBnxjj3rsseIMgPdeJHLkcsaCTqHt30WiDwhzmSuXv(89dhkSVdwqEI6xw6N0PdcxPlW6FysS5jD6GWO6G6TqHt30WiDwhzmSuXv(89jeSNp9o8ll9t4DzwojrdDsiXc)1qaA46ynShKCNkqckFGmMohsmcdnKwJ0hdlvSKKWUKcBHPiYYMnmjjH1OWMIojKyH)Aiao50PdcxPlW6FysS5jD6GWO6G6YHxeIMgDsiXc)1qa6KenjjnkSPiSoCuxwJHRfkC6MggPZ6iJHLkUYNVxdv0fdl1xw6NIq00iDwh5pgwQy0jjAssIq00ibd7wm)XWsfJGeiNoDqypCjwRmC6Mgk2A(8XWsf5sSkhEH1OWMICW26GN4JHLQKu40Lc)zJRxg7XBHRfkC6MggPZ6iJHLkUYNV7GT1bpXhdl1xw6NIq00ibd7wm)XWsfJGeiNoDqypCjwRmC6Mgk2A(8XWsf5sSkpC6sH)SX1lJ9Kk2cfoDtdJ0zDKXWsfx5Z3jVLYhdl1xw6NIq00OdhNplJrNKO1cfoDtdJ0zDKXWsfx5Z3JFn0C45N0F3KeXTqHt30WiDwhzmSuXv(8D6siJpFmSuBHcNUPHr6SoYyyPIR857yEeWM(X6AKEXjZv4VgdjwXp9(Ys)Cy6HXWcXc3cfoDtdJ0zDKXWsfx5Z3RHk6IHL6ll9t60bH9WLyTYWPBAOyR5ZhdlvKlXQC4DzwojrdnmoTqxJ0pMjjIgUowd7bbLKe2Luylmfrw2SHjjrNoiCLUaR)HjXMh0PdcJQdQdxlu40nnmsN1rgdlvCLpFxJ5Rti4LL(5azmDoKyKXy8AKigJm8xNqGG1i9dbcIjuiClu40nnmsN1rgdlvCLpFNEyUcynsFDcbVS0phiJPZHeJmgJxJeXyKH)6eceSgPFiqqmHcHBHcNUPHr6SoYyyPIR857IbPFs)1zDKXVS0pfHOPr6aXyyPIojrRfkC6MggPZ6iJHLkUYNVJvooY(yyP2c1cfoDtdJ0znYSIFsjMnel8lwuZpXYm3hsWluIce)ueIMgnmoTqxJ0pMjjIGeijjcrtJ0bIXWsfbjOfkC6MggPZAKzfx5Z3PeZgIf(flQ5NyDsJ0hlZCFibVqjkq8txsHTWuezzZgMCriAA0W40cDns)yMKicsGCriAAKoqmgwQiibssc7skSfMIilB2WKlcrtJ0bIXWsfbjOfkC6MggPZAKzfx5Z3PeZgIf(flQ5NyDsJ0hlZC)HRJ1WVKcEIzDPFXL2z1nTNUKcBHPiYYMnSxOefi(PlZYjjAOHXPf6AK(Xmjr0W1XAypRG6YSCsIgshigdlv0W1XA4xOefi(Zfm)0Lz5KenKoqmgwQOHRJ1WVS0pfHOPr6aXyyPIojrRfkC6MggPZAKzfx5Z3PeZgIf(flQ5NyDsJ0hlZC)HRJ1WVKcEIzDPFXL2z1nTNUKcBHPiYYMnSxOefi(PlZYjjAOHXPf6AK(Xmjr0W1XA4xOefi(Zfm)0Lz5KenKoqmgwQOHRJ1WVS0pfHOPr6aXyyPIGe0cfoDtdJ0znYSIR857uIzdXc)If18tSmZ9hUowd)sk4jM1L(fxANv30E6skSfMIilB2WEHsuG4NUmlNKOHggNwORr6hZKerdxhRH9OcQlZYjjAiDGymSurdxhRHFHsuG4pxW8txMLts0q6aXyyPIgUowd3cfoDtdJ0znYSIR857qy(VkxJFbxsf)uN1iZQ3xw6NWRZAKzf5fblWFim)fHOPLKCjf2ctrKLnByY1znYSI8IGf4VlZYjjAWjhEkXSHyHryDsJ0hlZCFibYHxyxsHTWuezzZgMCH1znYSIQIGf4peM)Iq00ssUKcBHPiYYMnm5cRZAKzfvfblWFxMLts0KK0znYSIQICzwojrdnCDSgwssN1iZkYlcwG)qy(lcrtlhEH1znYSIQIGf4peM)Iq00ss6SgzwrErUmlNKOHoqtOBAE8uN1iZkQkYLz5Ken0bAcDtdojjDwJmRiViyb(7YSCsIMCH1znYSIQIGf4peM)Iq00Y1znYSI8ICzwojrdDGMq3084PoRrMvuvKlZYjjAOd0e6MgCssctjMnelmcRtAK(yzM7djqo8cRZAKzfvfblWFim)fHOPLdVoRrMvKxKlZYjjAOd0e6MgvsqpPeZgIfgHLzU)W1XAyjjkXSHyHryzM7pCDSg2dDwJmRiVixMLts0qhOj0nncKQWjjPZAKzfvfblWFim)fHOPLdVoRrMvKxeSa)HW8xeIMwUoRrMvKxKlZYjjAOd0e6MMhp1znYSIQICzwojrdDGMq30KdVoRrMvKxKlZYjjAOd0e6MgvsqpPeZgIfgHLzU)W1XAyjjkXSHyHryzM7pCDSg2dDwJmRiVixMLts0qhOj0nncKQWjjbVW6SgzwrErWc8hcZFriAAjjDwJmROQixMLts0qhOj0nnpEQZAKzf5f5YSCsIg6anHUPbNC41znYSIQICzwojrdnCCKjxN1iZkQkYLz5Ken0bAcDtJkjOhuIzdXcJWYm3F46ynSCkXSHyHryzM7pCDSg2tDwJmROQixMLts0qhOj0nncKQsscRZAKzfvf5YSCsIgA44ito86SgzwrvrUmlNKOHgUowdtLe0tkXSHyHryDsJ0hlZC)HRJ1WYPeZgIfgH1jnsFSmZ9hUowd7r1hihEDwJmRiVixMLts0qhOj0nnQKGEsjMnelmclZC)HRJ1Wss6SgzwrvrUmlNKOHgUowdtLe0tkXSHyHryzM7pCDSgwUoRrMvuvKlZYjjAOd0e6Mgv69bvsjMnelmclZC)HRJ1WEsjMnelmcRtAK(yzM7pCDSgwsIsmBiwyewM5(dxhRH9qN1iZkYlYLz5Ken0bAcDtJaPQKeLy2qSWiSmZ9HeaNKKoRrMvuvKlZYjjAOHRJ1Wujb9GsmBiwyewN0i9XYm3F46ynSC41znYSI8ICzwojrdDGMq30Osc6jLy2qSWiSoPr6JLzU)W1XAyjjH1znYSI8IGf4peM)Iq00YHNsmBiwyewM5(dxhRH9qN1iZkYlYLz5Ken0bAcDtJaPQKeLy2qSWiSmZ9HeahCWbhCWjjPXqIvKU18xZ)zzpPeZgIfgHLzU)W1XAy4KKewN1iZkYlcwG)qy(lcrtlxyxsHTWuezzZgMC41znYSIQIGf4peM)Iq00YHhEHPeZgIfgHLzUpKajjDwJmROQixMLts0qdxhRH9GGWjhEkXSHyHryzM7pCDSg2JQpqssN1iZkQkYLz5Ken0W1XAyQKGEqjMnelmclZC)HRJ1WWbNKKW6SgzwrvrWc8hcZFriAA5WlSoRrMvuveSa)DzwojrtssN1iZkQkYLz5Ken0W1XAyjjDwJmROQixMLts0qhOj0nnpEQZAKzf5f5YSCsIg6anHUPbhCTqHt30WiDwJmR4kF(oeM)RY14xWLuXp1znYSw9LL(j86SgzwrvrWc8hcZFriAAjjxsHTWuezzZgMCDwJmROQiyb(7YSCsIgCYHNsmBiwyewN0i9XYm3hsGC4f2Luylmfrw2SHjxyDwJmRiViyb(dH5VienTKKlPWwykISSzdtUW6SgzwrErWc83Lz5KenjjDwJmRiVixMLts0qdxhRHLK0znYSIQIGf4peM)Iq00YHxyDwJmRiViyb(dH5VienTKKoRrMvuvKlZYjjAOd0e6MMhp1znYSI8ICzwojrdDGMq30GtssN1iZkQkcwG)UmlNKOjxyDwJmRiViyb(dH5VienTCDwJmROQixMLts0qhOj0nnpEQZAKzf5f5YSCsIg6anHUPbNKKWuIzdXcJW6KgPpwM5(qcKdVW6SgzwrErWc8hcZFriAA5WRZAKzfvf5YSCsIg6anHUPrLe0tkXSHyHryzM7pCDSgwsIsmBiwyewM5(dxhRH9qN1iZkQkYLz5Ken0bAcDtJaPkCss6SgzwrErWc8hcZFriAA5WRZAKzfvfblWFim)fHOPLRZAKzfvf5YSCsIg6anHUP5XtDwJmRiVixMLts0qhOj0nn5WRZAKzfvf5YSCsIg6anHUPrLe0tkXSHyHryzM7pCDSgwsIsmBiwyewM5(dxhRH9qN1iZkQkYLz5Ken0bAcDtJaPkCssWlSoRrMvuveSa)HW8xeIMwssN1iZkYlYLz5Ken0bAcDtZJN6SgzwrvrUmlNKOHoqtOBAWjhEDwJmRiVixMLts0qdhhzY1znYSI8ICzwojrdDGMq30Osc6bLy2qSWiSmZ9hUowdlNsmBiwyewM5(dxhRH9uN1iZkYlYLz5Ken0bAcDtJaPQKKW6SgzwrErUmlNKOHgooYKdVoRrMvKxKlZYjjAOHRJ1Wujb9KsmBiwyewN0i9XYm3F46ynSCkXSHyHryDsJ0hlZC)HRJ1WEu9bYHxN1iZkQkYLz5Ken0bAcDtJkjONuIzdXcJWYm3F46ynSKKoRrMvKxKlZYjjAOHRJ1Wujb9KsmBiwyewM5(dxhRHLRZAKzf5f5YSCsIg6anHUPrLEFqLuIzdXcJWYm3F46ynSNuIzdXcJW6KgPpwM5(dxhRHLKOeZgIfgHLzU)W1XAyp0znYSIQICzwojrdDGMq30iqQkjrjMnelmclZCFibWjjPZAKzf5f5YSCsIgA46ynmvsqpOeZgIfgH1jnsFSmZ9hUowdlhEDwJmROQixMLts0qhOj0nnQKGEsjMnelmcRtAK(yzM7pCDSgwssyDwJmROQiyb(dH5VienTC4PeZgIfgHLzU)W1XAyp0znYSIQICzwojrdDGMq30iqQkjrjMnelmclZCFibWbhCWbhCssAmKyfPBn)18Fw2tkXSHyHryzM7pCDSggojjH1znYSIQIGf4peM)Iq00Yf2Luylmfrw2SHjhEDwJmRiViyb(dH5VienTC4HxykXSHyHryzM7djqssN1iZkYlYLz5Ken0W1XAypiiCYHNsmBiwyewM5(dxhRH9O6dKK0znYSI8ICzwojrdnCDSgMkjOhuIzdXcJWYm3F46ynmCWjjjSoRrMvKxeSa)HW8xeIMwo8cRZAKzf5fblWFxMLts0KK0znYSI8ICzwojrdnCDSgwssN1iZkYlYLz5Ken0bAcDtZJN6SgzwrvrUmlNKOHoqtOBAWb3vV69c]] )

    
end