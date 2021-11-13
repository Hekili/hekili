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


    spec:RegisterPack( "Marksmanship", 20211113, [[d8udqcqicLhrOkDjGsQnrK(eczua0PaKvHKi8kQunlGQUfsc7c0VqOmmcrhJkSma8mGsnncvX1iuzBujPVrOQmoKeLZrLeToQu6DaLK08OsCpa1(iK(hHQQCqQKqlKq4HuPyIeQQ4IaLeFeOeAKeQQuNKkjyLiPEjHQkzMuj1nbkj1obk(jqjyOeQQQLIKO6PsQPcu5RijIglcv7fI)QsdwvhwyXe1JPQjlXLrTzK6ZiQrJGtRy1aLK41iXSvXTLKDt53IgorCCKePLR0ZHA6KUoK2oq(oImEKKopv06bkrZNG9l1ioqahsDjugbmaisaC4WHdWg6WHiDaG4dPwDkHrQLeEkbzgP2IkgPgS6yPGRcdtyKGuljCEYOGaoKACIUEgPw82pbvLGDlXig5rjGkd9zfXWtf6j0jn)g0kXWtLNyi1YOZrDfmezK6sOmcyaqKa4WHdhGn0Hdr6aaXdsDGQeYfPUEQCdsnHPuydrgPUWypsny1XsbxfgMWiPFXVrnL3MAWKG4kzE73byd((bqKa4OPUP2necJmJDBtnv0pyys0jQv6NkNX5be3)G73sT)O)k2tiSX3VsG7pkL063hgXinNt)vHfKzytnv0pvoJDAEU0FukP1VKDYDuN9tAuc9xpvUPFxrX)Ug2utf97Aw7x8lN7egU)cJDA((vc8S97gXp4(XzfRtfJHi1NbRyeWHuR74PGjKkgbCiGXbc4qQzlKpCbrei1(DuENaPwJdBkeRCuCEPtpkgYwiF4s)s7FSl9zitq7xA)YO00qSYrX5Lo9Oy4YvXy4(DPFXHuhEDsdPgRCuCEXesfrradaiGdPMTq(WferGu73r5DcK6f1y6CjZqjjQNWnPVBawM7LEdYvSPyiBH8Hl9lTFzuAAi9jCYl(wflfiQeK6WRtAi1uMZ5IjKkIIagWgbCi1SfYhUGicKA)okVtGuVOgtNlzgkjr9eUj9DdWYCV0BqUInfdzlKpCbPo86Kgsn9jCYLlMqQikcyepiGdPMTq(WferGu73r5DcKAa73NGylmfsX5oH1V0(9zEkjjdUmoTqhJ8n2njbxUkgd3Vl9t2x6xqOFX63NGylmfsX5oH1V0(fRFFcITWuOnKjOx6G7xqOFFcITWuOnKjOx6G7xA)a2VpZtjjzqsZPCXsMDumC5QymC)U0pzFPFbH(9zEkjjdsAoLlwYSJIHlxfJH7x0(bBr2pq9li0VglzwH6uXxnVLH73L(DiY(fe63N5PKKm4Y40cDmY3y3KeC5QymC)I2Vdr2V0(dVoG4lBC1W4(fTFWUFG6xA)a2Vy9VXuUmi2uyukyit1bR4(fe6FJPCzqSPWOuWWLRIXW9lA)UY(fe6xS(9ji2ctHuCUty9desD41jnK6sIkF4RgsqueWioeWHuZwiF4cIiqQ97O8obs9IAmDUKziorp05sMVCLmVyiBH8Hl9lTFn2RUHe4YvXy4(DPFY(s)s73N5PKKmi9jwgUCvmgUFx6NSVGuhEDsdPwJ9QBibrraJRIaoKA2c5dxqebsD41jnKA6tSmsTFhL3jqQ1yV6gsGOs6xA)lQX05sMH4e9qNlz(YvY8IHSfYhUGuFgJV(csnaIdrraJ4dbCi1HxN0qQzQk5K4beFXesfPMTq(WferGOiGHkdbCi1SfYhUGicKA)okVtGulw)BmLldInfgLcgYuDWkUFbH(3ykxgeBkmkfmC5QymC)I2Vdr2VGq)Hxhq8LnUAyC)IcC)BmLldInfgLcg6tut7Nkr)aGuhEDsdPM0CkxSKzhfJOiGXvIaoKA2c5dxqebsTFhL3jqQ9zEkjjdUmoTqhJ8n2njbxUkgd3Vl9t2x6xA)a2Vy9RXHnfYuvYjXdi(IjKkKTq(WL(fe6xgLMgkFYSCqXkevs)a1VGq)I1VpbXwykKIZDcRFbH(9zEkjjdUmoTqhJ8n2njbxUkgd3VO97qK9li0VCIX9lTF6Hmb9UCvmgUFx6xCi1HxN0qQjfZzmY3y3KeIIaghIebCi1SfYhUGicKA)okVtGudy)(mpLKKbbLNd7eUCvmgUFx6NSV0VGq)I1Vgh2uiO8CyNq2c5dx6xqOFnwYSc1PIVAEld3Vl97aG(bQFP9dy)I1)gt5YGytHrPGHmvhSI7xqO)nMYLbXMcJsbdxUkgd3VO97k7xqO)WRdi(YgxnmUFrbU)nMYLbXMcJsbd9jQP9tLOFa6hiK6WRtAi1lJtl0XiFJDtsikcyC4abCi1SfYhUGicKA)okVtGulJstdxgNwOJr(g7MKGOs6xqOFFMNssYGlJtl0XiFJDtsWLRIXW9lA)oez)cc9lw)(eeBHPqko3jmK6WRtAi1GYZHDIOiGXbaiGdPo86KgsTCSBqMrQzlKpCbreikcyCa2iGdPMTq(WferGu73r5DcKAzuAA4Y40cDmY3y3Keevs)cc97Z8ussgCzCAHog5BSBscUCvmgUFr73Hi7xqOFX63NGylmfsX5oH1VGq)Yjg3V0(PhYe07YvXy4(DPFaejsD41jnKADrzmHurueW4q8GaoKA2c5dxqebsTFhL3jqQxuJPZLmdXOl5XiFXesfdzlKpCPFP9dy)(mpLKKbxgNwOJr(g7MKGlxfJH7x0(DiY(fe6xS(9ji2ctHuCUty9li0Vy9RXHnfwsu5dF1qcKTq(WL(bQFP9lJstd1D8uUycPIHlxfJH7xuG7NPk7rv(QtfJuhEDsdPEdjt5splJOiGXH4qahsnBH8HliIaPo86KgsDmvC5IjKksTFhL3jqQLrPPH6oEkxmHuXWLRIXW9lkW9ZuL9OkF1PI7xA)a2VmknnuYY(bZxmHuXWssY6xqOFA0Z5USNqSK5RovC)U0VpW6vNkUF37NSV0VGq)YO00qDrzmHuHOs6hiKAVt)HVASKzfJaghikcyC4QiGdPMTq(WferGu73r5DcKA60JI739(9bwVltMT(DPF60JIHvbvrQdVoPHux4qjC9eckBuHOiGXH4dbCi1SfYhUGicKA)okVtGudy)(mpLKKbxgNwOJr(g7MKGlxfJH7x0(DiY(L2)IAmDUKzigDjpg5lMqQyiBH8Hl9li0Vy97tqSfMcP4CNW6xqOFX6FrnMoxYmeJUKhJ8ftivmKTq(WL(fe6xS(14WMcljQ8HVAibYwiF4s)a1V0(LrPPH6oEkxmHuXWLRIXW9lkW9ZuL9OkF1PIrQdVoPHuVHKPCPNLrueW4GkdbCi1SfYhUGicKA)okVtGulJstd1D8uUycPIHLKK1VGq)YO00qjl7hmFXesfdrL0V0(PtpkUFr73NyTF37p86KgmMkUCXesf6tS2V0(bSFX6xJdBk0tyQcEJlMqQq2c5dx6xqO)WRdi(YgxnmUFr7hS7hiK6WRtAi1vOhDWesfrraJdxjc4qQzlKpCbrei1(DuENaPwgLMgkzz)G5lMqQyiQK(L2pD6rX9lA)(eR97E)HxN0GXuXLlMqQqFI1(L2F41beFzJRgg3Vl9lEqQdVoPHu7jmvbVXftivefbmaiseWHuZwiF4cIiqQ97O8obsTmknnSWr5Yozyjjzi1HxN0qQPmNZftivefbma4abCi1HxN0qQJBf6w49M0x)MKWi1SfYhUGicefbmaaac4qQdVoPHutFcNC5IjKksnBH8HliIarradaGnc4qQzlKpCbrei1HxN0qQX8kHn9I1XiJu73r5DcK6LPxgtiKpmsT3P)WxnwYSIraJdefbmaiEqahsnBH8HliIaP2VJY7ei10Phf3VO97tS2V79hEDsdgtfxUycPc9jw7xA)a2VpZtjjzWLXPf6yKVXUjj4YvXy4(fTFX1VGq)I1VpbXwykKIZDcRFGqQdVoPHuxHE0btivefbmaioeWHuZwiF4cIiqQ97O8obs9IAmDUKzOXy8yKjfRt8v3qIKXiFdjsInuumKTq(WfK6WRtAi1ASxDdjikcyaWvrahsnBH8HliIaP2VJY7ei1lQX05sMHgJXJrMuSoXxDdjsgJ8nKij2qrXq2c5dxqQdVoPHutVmdwog5RUHeefbmai(qahsnBH8HliIaP2VJY7ei1YO00qDrzmHuHLKKHuhEDsdPwoiFt6RUJNcgrradauziGdPMTq(WferGu73r5DcKACIEKhRaLGIv0dF5fvIoPbzlKpCPFP9lJstd1fLXesfwssgsD41jnKA6dJj43GwrueWaGRebCi1HxN0qQXkhfNxmHurQzlKpCbreikIIuxy6a9OiGdbmoqahsD41jnKAFIAkVxmHurQzlKpCbreikcyaabCi1SfYhUGicK6WRtAi1(e1uEVycPIu73r5DcK6f1y6CjZqmlHakyj(kzt)jQcDsdYwiF4s)cc9Jt0J8yfOnod8vZ8GVsYbNgKTq(WL(fe6hW(9PvqhfUmiEXX5M0x6CvuJHSfYhU0V0(fR)f1y6CjZqmlHakyj(kzt)jQcDsdYwiF4s)aHuFgJV(csnylsefbmGnc4qQzlKpCbrei1HxN0qQ1nmQu05mGLJr(IjKksDHX(DKOtAi1GfZ(dcCu6pSs)GBdJkfDodyj3pye)7M(zJRggd((jX9xsJiT)s2VsyW9tNB)soHtEX9lZ(afZ9pkrL(L5(1m7hljQQC2FyL(jX97dJiT)LJYCC2p42WOs7hlH9d947xgLMgdrQ97O8obsTy9RXsMv4GVsoHtErueWiEqahsnBH8HliIaP2VJY7ei1(eeBHPqko3jS(L2VpZtjjzqDrzmHuHlxfJH7xA)(mpLKKbxgNwOJr(g7MKGlxfJH7xqOFX63NGylmfsX5oH1V0(9zEkjjdQlkJjKkC5QymmsD41jnKAFCo3WRtA3ZGvK6ZG1RfvmsTUJrHvmIIagXHaoKA2c5dxqebsD41jnKAFCo3WRtA3ZGvK6ZG1RfvmsTVGrueW4QiGdPMTq(WferGu73r5DcK6WRdi(YgxnmUFx6hSrQdVoPHu7JZ5gEDs7EgSIuFgSETOIrQXkIIagXhc4qQzlKpCbrei1(DuENaPo86aIVSXvdJ7x0(baPo86KgsTpoNB41jT7zWks9zW61IkgPw3XtbtivmIIOi1sw2NvYHIaoeW4abCi1HxN0qQLtvpC5sFcNCH0yKVAs1XqQzlKpCbreikcyaabCi1HxN0qQPpmMGFdAfPMTq(WferGOiGbSrahsnBH8HliIaP2VJY7ei1lQX05sMH4e9qNlz(YvY8IHSfYhUGuhEDsdPwJ9QBibrraJ4bbCi1SfYhUGicKAjl7dSE1PIrQDisK6WRtAi1Lev(WxnKGu73r5DcK6WRdi(YgxnmUFr73r)cc9lw)(eeBHPqko3jS(L2Vy9RXHnfckph2jKTq(WfefbmIdbCi1SfYhUGicKA)okVtGuhEDaXx24QHX97s)GD)s7hW(fRFFcITWuifN7ew)s7xS(14WMcbLNd7eYwiF4s)cc9hEDaXx24QHX97s)a0pqi1HxN0qQJPIlxmHurueW4QiGdPMTq(WferGu73r5DcK6WRdi(YgxnmUFr7hG(fe6hW(9ji2ctHuCUty9li0Vgh2uiO8CyNq2c5dx6hO(L2F41beFzJRgg3pW9dasD41jnKASYrX5ftivefrrQ9fmc4qaJdeWHuZwiF4cIiqQ97O8obsnG9lJstd1fLXesfIkPFP9lJstdxgNwOJr(g7MKGOs6xA)(eeBHPqko3jS(bQFbH(bSFzuAAOUOmMqQquj9lTFzuAAiP5uUyjZokgIkPFP97tqSfMcTHmb9shC)a1VGq)a2VpbXwykeeBkbNB)cc97tqSfMcn2V5j3s)a1V0(LrPPH6IYycPcrL0VGq)Yjg3V0(PhYe07YvXy4(DPFhGD)cc9dy)(eeBHPqko3jS(L2VmknnCzCAHog5BSBscIkPFP9tpKjO3LRIXW97s)IpWUFGqQdVoPHulZlMxkJrgrradaiGdPMTq(WferGu73r5DcKAzuAAOUOmMqQquj9li0VpZtjjzqDrzmHuHlxfJH7x0(bBr2VGq)Yjg3V0(PhYe07YvXy4(DPFhUksD41jnKA5tMLln66erradyJaoKA2c5dxqebsTFhL3jqQLrPPH6IYycPcrL0VGq)(mpLKKb1fLXesfUCvmgUFr7hSfz)cc9lNyC)s7NEitqVlxfJH73L(D4Qi1HxN0qQdZZyDJZ1hNdIIagXdc4qQzlKpCbrei1(DuENaPwgLMgQlkJjKkevs)cc97Z8ussguxugtiv4YvXy4(fTFWwK9li0VCIX9lTF6Hmb9UCvmgUFx63vIuhEDsdPMEww(KzbrraJ4qahsnBH8HliIaP2VJY7ei1YO00qDrzmHuHLKKHuhEDsdP(mKjO4lyvqlKRytrueW4QiGdPMTq(WferGu73r5DcKAzuAAOUOmMqQquj9lTFa7xgLMgkFYSCqXkevs)cc9RXsMvibookbOeV2Vl9dGi7hO(fe6xoX4(L2p9qMGExUkgd3Vl9dGR2VGq)a2VpbXwykKIZDcRFP9lJstdxgNwOJr(g7MKGOs6xA)0dzc6D5QymC)U0V4dG(bcPo86KgsTKuN0quefPgRiGdbmoqahsnBH8HliIaP2VJY7ei1ACytHyLJIZlD6rXq2c5dx6xA)a2VKLbDj7lqhqSYrX5fti1(L2VmknneRCuCEPtpkgUCvmgUFx6xC9li0VmknneRCuCEPtpkgwssw)a1V0(bSFzuAA4Y40cDmY3y3KeSKKS(fe6xS(9ji2ctHuCUty9desD41jnKASYrX5ftivefbmaGaoK6WRtAi1uMZ5IjKksnBH8HliIarradyJaoKA2c5dxqebsTFhL3jqQbSFFcITWuifN7ew)s7hW(9zEkjjdUmoTqhJ8n2njbxUkgd3Vl9t2x6hO(fe6xS(9ji2ctHuCUty9lTFX63NGylmfAdzc6Lo4(fe63NGylmfAdzc6Lo4(L2pG97Z8ussgK0CkxSKzhfdxUkgd3Vl9t2x6xqOFFMNssYGKMt5ILm7Oy4YvXy4(fTFWwK9du)cc9tpKjO3LRIXW97s)oex)a1V0(bSFX6FJPCzqSPWOuWqMQdwX9li0)gt5YGytHrPGHOs6xA)a2)gt5YGytHrPGHJ1Vl97qK9lT)nMYLbXMcJsbdxUkgd3Vl9d29li0)gt5YGytHrPGHJ1VO9hEDs76Z8ussw)cc9hEDaXx24QHX9lA)o6hO(fe6xS(3ykxgeBkmkfmevs)s7hW(3ykxgeBkmkfm0NOM2pW97OFbH(3ykxgeBkmkfmCS(fT)WRtAxFMNssY6hO(bcPo86KgsDjrLp8vdjikcyepiGdPMTq(WferGu73r5DcKAn2RUHeiQK(L2)IAmDUKziorp05sMVCLmVyiBH8Hli1HxN0qQPpXYikcyehc4qQzlKpCbrei1(DuENaPErnMoxYmeNOh6CjZxUsMxmKTq(WL(L2Vg7v3qcC5QymC)U0pzFPFP97Z8ussgK(eldxUkgd3Vl9t2xqQdVoPHuRXE1nKGOiGXvrahsD41jnKAMQsojEaXxmHurQzlKpCbreikcyeFiGdPMTq(WferGu73r5DcKAX6FJPCzqSPWOuWqMQdwX9li0Vy9VXuUmi2uyukyiQK(L2)gt5YGytHrPGHf0n0jT(DV)nMYLbXMcJsbdhRFx6har2VGq)BmLldInfgLcgIkPFP9VXuUmi2uyuky4YvXy4(fTFhUY(fe6p86aIVSXvdJ7x0(DGuhEDsdPM0CkxSKzhfJOiGHkdbCi1HxN0qQPpHtUCXesfPMTq(WferGOiGXvIaoKA2c5dxqebsTFhL3jqQPtpkUF373hy9Umz263L(PtpkgwfufPo86KgsDHdLW1tiOSrfIIaghIebCi1HxN0qQJBf6w49M0x)MKWi1SfYhUGicefbmoCGaoKA2c5dxqebsTFhL3jqQ9zEkjjdUmoTqhJ8n2njbxUkgd3Vl9t2x6xA)a2Vy9RXHnfYuvYjXdi(IjKkKTq(WL(fe6xgLMgkFYSCqXkevs)a1VGq)I1VpbXwykKIZDcRFbH(9zEkjjdUmoTqhJ8n2njbxUkgd3VGq)Yjg3V0(PhYe07YvXy4(DPFXHuhEDsdPMumNXiFJDtsikcyCaac4qQzlKpCbrei1(DuENaPgW(LrPPHLev(WxnKarL0VGq)(mpLKKbljQ8HVAibUCvmgUFr73Hi7xqOFX6xJdBkSKOYh(QHeiBH8Hl9li0p9qMGExUkgd3Vl97aG(bQFP9dy)I1)gt5YGytHrPGHmvhSI7xqOFX6FJPCzqSPWOuWquj9lTFa7FJPCzqSPWOuWWc6g6Kw)U3)gt5YGytHrPGHJ1Vl97qK9li0)gt5YGytHrPGH(e10(bUFh9du)cc9VXuUmi2uyukyiQK(L2)gt5YGytHrPGHlxfJH7x0(DL9li0F41beFzJRgg3VO97OFGqQdVoPHuVmoTqhJ8n2njHOiGXbyJaoKA2c5dxqebsTFhL3jqQLrPPHlJtl0XiFJDtsquj9li0VpZtjjzWLXPf6yKVXUjj4YvXy4(fTFhISFbH(fRFFcITWuifN7ew)s7hW(LrPPHsw2py(IjKkgwssw)cc9lw)ACytHEctvWBCXesfYwiF4s)cc9hEDaXx24QHX97s)a0pqi1HxN0qQbLNd7erraJdXdc4qQzlKpCbrei1(DuENaP2NGylmfsX5oH1V0(PtpkUF373hy9Umz263L(PtpkgwfuTFP9dy)a2VpZtjjzWLXPf6yKVXUjj4YvXy4(DPFY(s)uj6hS7xA)a2Vy9Jt0J8yfittJIhq8nSPkUH3ZhEdnxiBH8Hl9li0Vy9RXHnfwsu5dF1qcKTq(WL(bQFG6xqOFnoSPWsIkF4RgsGSfYhU0V0(9zEkjjdwsu5dF1qcC5QymC)U0py3pqi1HxN0qQXkhfNxmHurueW4qCiGdPMTq(WferGu73r5DcKAzuAAOKL9dMVycPIHLKK1V0(bSFFcITWuii2uco3(fe63NGylmfASFZtUL(fe6xJdBk0hNZyKVkb(IjKkgYwiF4s)a1VGq)YO00WLXPf6yKVXUjjiQK(fe63N5PKKm4Y40cDmY3y3KeC5QymC)I2Vdr2VGq)YO00qsZPCXsMDumevs)cc9lJstdbLNd7eIkPFP9hEDaXx24QHX9lA)o6xqOF5eJ7xA)0dzc6D5QymC)U0paIdPo86KgsTUOmMqQikcyC4QiGdPMTq(WferGu73r5DcK6f1y6CjZqm6sEmYxmHuXq2c5dx6xA)ACytHyD5O6mgdzlKpCPFP9dy)(mpLKKbxgNwOJr(g7MKGlxfJH7x0(DiY(fe6xS(9ji2ctHuCUty9li0Vy9RXHnfwsu5dF1qcKTq(WL(fe6hNOh5XkqMMgfpG4BytvCdVNp8gAUq2c5dx6hiK6WRtAi1Bizkx6zzefbmoeFiGdPMTq(WferGuhEDsdPoMkUCXesfP2VJY7ei1YO00qjl7hmFXesfdljjRFbH(bSFzuAAOUOmMqQquj9li0pn65Cx2tiwY8vNkUFx6NSV0V797dSE1PI7hO(L2pG9lw)ACytHEctvWBCXesfYwiF4s)cc9hEDaXx24QHX97s)a0pq9li0Vmknnu3Xt5IjKkgUCvmgUFr7NPk7rv(Qtf3V0(dVoG4lBC1W4(fTFhi1EN(dF1yjZkgbmoqueW4GkdbCi1SfYhUGicKA)okVtGudy)(mpLKKbxgNwOJr(g7MKGlxfJH7x0(DiY(fe6xS(9ji2ctHuCUty9li0Vy9RXHnfwsu5dF1qcKTq(WL(fe6hNOh5XkqMMgfpG4BytvCdVNp8gAUq2c5dx6hO(L2pD6rX97E)(aR3LjZw)U0pD6rXWQGQ9lTFa7xgLMgwsu5dF1qcSKKS(L2VmknnKdYhwJtA4RUO8Lo9Oyyjjz9li0Vgh2uiwxoQoJXq2c5dx6hiK6WRtAi1Bizkx6zzefbmoCLiGdPMTq(WferGu73r5DcKAzuAAOKL9dMVycPIHOs6xqOF60JI7x0(9jw739(dVoPbJPIlxmHuH(eRi1HxN0qQ9eMQG34IjKkIIagaejc4qQzlKpCbrei1(DuENaPwgLMgkzz)G5lMqQyiQK(fe6No9O4(fTFFI1(DV)WRtAWyQ4YftivOpXksD41jnK6y9HXxmHurueWaGdeWHuZwiF4cIiqQdVoPHuJ5vcB6fRJrgP2VJY7ei1ltVmMqiF4(L2VglzwH6uXxnVLH7x0(lOBOtAi1EN(dF1yjZkgbmoqueWaaaiGdPMTq(WferGu73r5DcK6WRdi(YgxnmUFr73bsD41jnKA5y3GmJOiGbaWgbCi1SfYhUGicKA)okVtGudy)(mpLKKbxgNwOJr(g7MKGlxfJH7x0(DiY(L2)IAmDUKzigDjpg5lMqQyiBH8Hl9li0Vy97tqSfMcP4CNW6xqOFX6xJdBkSKOYh(QHeiBH8Hl9li0porpYJvGmnnkEaX3WMQ4gEpF4n0CHSfYhU0pq9lTF60JI739(9bwVltMT(DPF60JIHvbv7xA)a2VmknnSKOYh(QHeyjjz9li0Vgh2uiwxoQoJXq2c5dx6hiK6WRtAi1Bizkx6zzefbmaiEqahsnBH8HliIaP2VJY7ei1YO00qDrzmHuHLKKHuhEDsdPwoiFt6RUJNcgrradaIdbCi1SfYhUGicKA)okVtGuJt0J8yfOeuSIE4lVOs0jniBH8Hl9lTFzuAAOUOmMqQWssYqQdVoPHutFymb)g0kIIagaCveWHuhEDsdPgRCuCEXesfPMTq(WferGOiksTUJrHvmc4qaJdeWHuZwiF4cIiqQtji1ywrQdVoPHudk2jKpmsnO4GYi1YO00WLXPf6yKVXUjjiQK(fe6xgLMgQlkJjKkevcsnOyVwuXi1yNM)IkbrradaiGdPMTq(WferGuNsqQXSIuhEDsdPguStiFyKAqXbLrQ9ji2ctHuCUty9lTFzuAA4Y40cDmY3y3Keevs)s7xgLMgQlkJjKkevs)cc9lw)(eeBHPqko3jS(L2VmknnuxugtiviQeKAqXETOIrQX6Mg5l2P5VOsqueWa2iGdPMTq(WferGuNsqQXSo0i1HxN0qQbf7eYhgPguSxlQyKASUPr(IDA(7YvXyyKA)okVtGulJstd1fLXesfwssw)s73NGylmfsX5oHHudkoO8LpygP2N5PKKmOUOmMqQWLRIXWi1GIdkJu7Z8ussgCzCAHog5BSBscUCvmgUFxe)1VpZtjjzqDrzmHuHlxfJHrueWiEqahsnBH8HliIaPoLGuJzDOrQdVoPHudk2jKpmsnOyVwuXi1yDtJ8f7083LRIXWi1(DuENaPwgLMgQlkJjKkevs)s73NGylmfsX5oHHudkoO8LpygP2N5PKKmOUOmMqQWLRIXWi1GIdkJu7Z8ussgCzCAHog5BSBscUCvmggrraJ4qahsnBH8HliIaPoLGuJzDOrQdVoPHudk2jKpmsnOyVwuXi1yNM)UCvmggP2VJY7ei1(eeBHPqko3jmKAqXbLV8bZi1(mpLKKb1fLXesfUCvmggPguCqzKAFMNssYGlJtl0XiFJDtsWLRIXW9lQ4V(9zEkjjdQlkJjKkC5QymmIIagxfbCi1SfYhUGicK6WRtAi16ogfwDGu73r5DcKAa7x3XOWkuDaje4lkMVYO009li0VpbXwykKIZDcRFP9R7yuyfQoGec81N5PKKS(bQFP9dy)GIDc5ddX6Mg5l2P5VOs6xA)a2Vy97tqSfMcP4CNW6xA)I1VUJrHvOcaKqGVOy(kJst3VGq)(eeBHPqko3jS(L2Vy9R7yuyfQaaje4RpZtjjz9li0VUJrHvOca0N5PKKm4YvXy4(fe6x3XOWkuDaje4lkMVYO009lTFa7xS(1DmkScvaGec8ffZxzuA6(fe6x3XOWkuDa9zEkjjdwq3qN06xuG7x3XOWkuba6Z8ussgSGUHoP1pq9li0VUJrHvO6asiWxFMNssY6xA)I1VUJrHvOcaKqGVOy(kJst3V0(1DmkScvhqFMNssYGf0n0jT(ff4(1DmkScvaG(mpLKKblOBOtA9du)cc9lw)GIDc5ddX6Mg5l2P5VOs6xA)a2Vy9R7yuyfQaaje4lkMVYO009lTFa7x3XOWkuDa9zEkjjdwq3qN06Nk6xC97s)GIDc5ddXon)D5QymC)cc9dk2jKpme7083LRIXW9lA)6ogfwHQdOpZtjjzWc6g6Kw)eRFa6hO(fe6x3XOWkubasiWxumFLrPP7xA)a2VUJrHvO6asiWxumFLrPP7xA)6ogfwHQdOpZtjjzWc6g6Kw)IcC)6ogfwHkaqFMNssYGf0n0jT(L2pG9R7yuyfQoG(mpLKKblOBOtA9tf9lU(DPFqXoH8HHyNM)UCvmgUFbH(bf7eYhgIDA(7YvXy4(fTFDhJcRq1b0N5PKKmybDdDsRFI1pa9du)cc9dy)I1VUJrHvO6asiWxumFLrPP7xqOFDhJcRqfaOpZtjjzWc6g6Kw)IcC)6ogfwHQdOpZtjjzWc6g6Kw)a1V0(bSFDhJcRqfaOpZtjjzWLJIZ(L2VUJrHvOca0N5PKKmybDdDsRFQOFX1VO9dk2jKpme7083LRIXW9lTFqXoH8HHyNM)UCvmgUFx6x3XOWkuba6Z8ussgSGUHoP1pX6hG(fe6xS(1DmkScvaG(mpLKKbxoko7xA)a2VUJrHvOca0N5PKKm4YvXy4(PI(fx)U0pOyNq(WqSUPr(IDA(7YvXy4(L2pOyNq(WqSUPr(IDA(7YvXy4(fTFaez)s7hW(1DmkScvhqFMNssYGf0n0jT(PI(fx)U0pOyNq(WqStZFxUkgd3VGq)6ogfwHkaqFMNssYGlxfJH7Nk6xC97s)GIDc5ddXon)D5QymC)s7x3XOWkuba6Z8ussgSGUHoP1pv0Vdr2V79dk2jKpme7083LRIXW97s)GIDc5ddX6Mg5l2P5VlxfJH7xqOFqXoH8HHyNM)UCvmgUFr7x3XOWkuDa9zEkjjdwq3qN06Ny9dq)cc9dk2jKpme708xuj9du)cc9R7yuyfQaa9zEkjjdUCvmgUFQOFX1VO9dk2jKpmeRBAKVyNM)UCvmgUFP9dy)6ogfwHQdOpZtjjzWc6g6Kw)ur)IRFx6huStiFyiw30iFXon)D5QymC)cc9lw)6ogfwHQdiHaFrX8vgLMUFP9dy)GIDc5ddXon)D5QymC)I2VUJrHvO6a6Z8ussgSGUHoP1pX6hG(fe6huStiFyi2P5VOs6hO(bQFG6hO(bQFG6xqOF5eJ7xA)0dzc6D5QymC)U0pOyNq(WqStZFxUkgd3pq9li0Vy9R7yuyfQoGec8ffZxzuA6(L2Vy97tqSfMcP4CNW6xA)a2VUJrHvOcaKqGVOy(kJst3V0(bSFa7xS(bf7eYhgIDA(lQK(fe6x3XOWkuba6Z8ussgC5QymC)I2V46hO(L2pG9dk2jKpme7083LRIXW9lA)aiY(fe6x3XOWkuba6Z8ussgC5QymC)ur)IRFr7huStiFyi2P5VlxfJH7hO(bQFbH(fRFDhJcRqfaiHaFrX8vgLMUFP9dy)I1VUJrHvOcaKqGV(mpLKK1VGq)6ogfwHkaqFMNssYGlxfJH7xqOFDhJcRqfaOpZtjjzWc6g6Kw)IcC)6ogfwHQdOpZtjjzWc6g6Kw)a1pqi14tQyKADhJcRoqueWi(qahsnBH8HliIaPo86KgsTUJrHvaqQ97O8obsnG9R7yuyfQaaje4lkMVYO009li0VpbXwykKIZDcRFP9R7yuyfQaaje4RpZtjjz9du)s7hW(bf7eYhgI1nnYxStZFrL0V0(bSFX63NGylmfsX5oH1V0(fRFDhJcRq1bKqGVOy(kJst3VGq)(eeBHPqko3jS(L2Vy9R7yuyfQoGec81N5PKKS(fe6x3XOWkuDa9zEkjjdUCvmgUFbH(1DmkScvaGec8ffZxzuA6(L2pG9lw)6ogfwHQdiHaFrX8vgLMUFbH(1DmkScvaG(mpLKKblOBOtA9lkW9R7yuyfQoG(mpLKKblOBOtA9du)cc9R7yuyfQaaje4RpZtjjz9lTFX6x3XOWkuDaje4lkMVYO009lTFDhJcRqfaOpZtjjzWc6g6Kw)IcC)6ogfwHQdOpZtjjzWc6g6Kw)a1VGq)I1pOyNq(WqSUPr(IDA(lQK(L2pG9lw)6ogfwHQdiHaFrX8vgLMUFP9dy)6ogfwHkaqFMNssYGf0n0jT(PI(fx)U0pOyNq(WqStZFxUkgd3VGq)GIDc5ddXon)D5QymC)I2VUJrHvOca0N5PKKmybDdDsRFI1pa9du)cc9R7yuyfQoGec8ffZxzuA6(L2pG9R7yuyfQaaje4lkMVYO009lTFDhJcRqfaOpZtjjzWc6g6Kw)IcC)6ogfwHQdOpZtjjzWc6g6Kw)s7hW(1DmkScvaG(mpLKKblOBOtA9tf9lU(DPFqXoH8HHyNM)UCvmgUFbH(bf7eYhgIDA(7YvXy4(fTFDhJcRqfaOpZtjjzWc6g6Kw)eRFa6hO(fe6hW(fRFDhJcRqfaiHaFrX8vgLMUFbH(1DmkScvhqFMNssYGf0n0jT(ff4(1DmkScvaG(mpLKKblOBOtA9du)s7hW(1DmkScvhqFMNssYGlhfN9lTFDhJcRq1b0N5PKKmybDdDsRFQOFX1VO9dk2jKpme7083LRIXW9lTFqXoH8HHyNM)UCvmgUFx6x3XOWkuDa9zEkjjdwq3qN06Ny9dq)cc9lw)6ogfwHQdOpZtjjzWLJIZ(L2pG9R7yuyfQoG(mpLKKbxUkgd3pv0V463L(bf7eYhgI1nnYxStZFxUkgd3V0(bf7eYhgI1nnYxStZFxUkgd3VO9dGi7xA)a2VUJrHvOca0N5PKKmybDdDsRFQOFX1Vl9dk2jKpme7083LRIXW9li0VUJrHvO6a6Z8ussgC5QymC)ur)IRFx6huStiFyi2P5VlxfJH7xA)6ogfwHQdOpZtjjzWc6g6Kw)ur)oez)U3pOyNq(WqStZFxUkgd3Vl9dk2jKpmeRBAKVyNM)UCvmgUFbH(bf7eYhgIDA(7YvXy4(fTFDhJcRqfaOpZtjjzWc6g6Kw)eRFa6xqOFqXoH8HHyNM)IkPFG6xqOFDhJcRq1b0N5PKKm4YvXy4(PI(fx)I2pOyNq(WqSUPr(IDA(7YvXy4(L2pG9R7yuyfQaa9zEkjjdwq3qN06Nk6xC97s)GIDc5ddX6Mg5l2P5VlxfJH7xqOFX6x3XOWkubasiWxumFLrPP7xA)a2pOyNq(WqStZFxUkgd3VO9R7yuyfQaa9zEkjjdwq3qN06Ny9dq)cc9dk2jKpme708xuj9du)a1pq9du)a1pq9li0VCIX9lTF6Hmb9UCvmgUFx6huStiFyi2P5VlxfJH7hO(fe6xS(1DmkScvaGec8ffZxzuA6(L2Vy97tqSfMcP4CNW6xA)a2VUJrHvO6asiWxumFLrPP7xA)a2pG9lw)GIDc5ddXon)fvs)cc9R7yuyfQoG(mpLKKbxUkgd3VO9lU(bQFP9dy)GIDc5ddXon)D5QymC)I2paISFbH(1DmkScvhqFMNssYGlxfJH7Nk6xC9lA)GIDc5ddXon)D5QymC)a1pq9li0Vy9R7yuyfQoGec8ffZxzuA6(L2pG9lw)6ogfwHQdiHaF9zEkjjRFbH(1DmkScvhqFMNssYGlxfJH7xqOFDhJcRq1b0N5PKKmybDdDsRFrbUFDhJcRqfaOpZtjjzWc6g6Kw)a1pqi14tQyKADhJcRaGOikIIudIx8KgcyaqKa4qKuzaqLHutkwBmYyKAQKUIu5GXvamGfDB)9docC)tLKC1(PZTFI0D8uWesftu)ltLIolx6hNvC)bQMvHYL(9ecJmJHn1UEmUFhUTF3KgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6hqhufiytTRhJ7ha32VBsdeVkx6NOf1y6CjZqItu)A2prlQX05sMHehYwiF4cr9dOdQceSP21JX9d2UTF3KgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKTq(WfI6p0(bRawW19dOdQceSP21JX9lo32VBsdeVkx6NOf1y6CjZqItu)A2prlQX05sMHehYwiF4cr9dOdQceSP21JX97QUTF3KgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKTq(WfI6p0(bRawW19dOdQceSP21JX97kDB)Ujnq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1pGoOkqWMAxpg3Vdr62(DtAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQFaDqvGGn1UEmUFhIh32VBsdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9dOdQceSP21JX97q842(DtAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQFaDqvGGn1UEmUFhIp32VBsdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9dOdQceSP21JX97q852(DtAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQFabGQabBQD9yC)oOYCB)Ujnq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1pGoOkqWMAxpg3paIZT97M0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHSfYhUqu)H2pyfWcUUFaDqvGGn1UEmUFaCv32VBsdeVkx6NOf1y6CjZqItu)A2prlQX05sMHehYwiF4cr9hA)Gval46(b0bvbc2u76X4(bGkZT97M0aXRYL(jcNOh5XkqItu)A2pr4e9ipwbsCiBH8Hle1pGoOkqWM6MAQKUIu5GXvamGfDB)9docC)tLKC1(PZTFIkmDGEuI6FzQu0z5s)4SI7pq1SkuU0VNqyKzmSP21JX9dGB73nPbIxLl9t0IAmDUKziXjQFn7NOf1y6CjZqIdzlKpCHO(b0bvbc2u76X4(bWT97M0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHSfYhUqu)a6GQabBQD9yC)a42(DtAG4v5s)e5tRGokK4e1VM9tKpTc6OqIdzlKpCHO(b0bvbc2u76X4(bWT97M0aXRYL(jcNOh5XkqItu)A2pr4e9ipwbsCiBH8Hle1pGoOkqWM6MAQKUIu5GXvamGfDB)9docC)tLKC1(PZTFIKSSpRKdLO(xMkfDwU0poR4(dunRcLl97jegzgdBQD9yC)GTB73nPbIxLl9t0IAmDUKziXjQFn7NOf1y6CjZqIdzlKpCHO(dTFWkGfCD)a6GQabBQD9yC)Ih32VBsdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9hA)Gval46(b0bvbc2u76X4(fNB73nPbIxLl9tKgh2uiXjQFn7NinoSPqIdzlKpCHO(b0bvbc2u76X4(Dv32VBsdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9dOdQceSPUPMkPRivoyCfadyr32F)GJa3)ujjxTF6C7NiSsu)ltLIolx6hNvC)bQMvHYL(9ecJmJHn1UEmUFhUTF3KgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6hqhufiytTRhJ7x842(DtAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQ)q7hScybx3pGoOkqWMAxpg3V4CB)Ujnq8QCPFIwuJPZLmdjor9Rz)eTOgtNlzgsCiBH8Hle1pGoOkqWMAxpg3VdhUTF3KgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6hqhufiytTRhJ73baUTF3KgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6hqhufiytTRhJ73by72(DtAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQFaDqvGGn1UEmUFhIh32VBsdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9diaufiytTRhJ73H4XT97M0aXRYL(jcNOh5XkqItu)A2pr4e9ipwbsCiBH8Hle1pGoOkqWMAxpg3VdX52(DtAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQFaDqvGGn1UEmUFhUQB73nPbIxLl9tKgh2uiXjQFn7NinoSPqIdzlKpCHO(beaQceSP21JX97WvDB)Ujnq8QCPFIwuJPZLmdjor9Rz)eTOgtNlzgsCiBH8Hle1pGoOkqWMAxpg3Vdx1T97M0aXRYL(jcNOh5XkqItu)A2pr4e9ipwbsCiBH8Hle1pGoOkqWMAxpg3VdXNB73nPbIxLl9tKgh2uiXjQFn7NinoSPqIdzlKpCHO(b0bvbc2u76X4(DqL52(DtAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQFabGQabBQD9yC)oOYCB)Ujnq8QCPFIWj6rEScK4e1VM9teorpYJvGehYwiF4cr9dOdQceSP21JX9day72(DtAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQFabGQabBQD9yC)aa2UTF3KgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKTq(WfI6hqhufiytTRhJ7haW2T97M0aXRYL(jcNOh5XkqItu)A2pr4e9ipwbsCiBH8Hle1pGoOkqWMAxpg3paIZT97M0aXRYL(jcNOh5XkqItu)A2pr4e9ipwbsCiBH8Hle1pGoOkqWMAWrG7NopNK0yK7pq3a3pjE5(rXCP)X6xjW9hEDsR)ZG1(Lr1(jXl3VLA)0jQv6FS(vcC)rPKw)Lqd5aZUTPUFQOFoiFynoPHV6IYx60JIBQBQPs6ksLdgxbWaw0T93p4iW9pvsYv7No3(js3XOWkMO(xMkfDwU0poR4(dunRcLl97jegzgdBQD9yC)UQB73nPbIxLl9xpvUPFSttdQ2pyD)A2VRrJ(ldObpP1FkH3qZTFajgq9dO4OkqWMAxpg3VR62(DtAG4v5s)eP7yuyf6asCI6xZ(js3XOWkuDajor9diaoOkqWMAxpg3VR62(DtAG4v5s)eP7yuyfcaK4e1VM9tKUJrHvOcaK4e1pGa4QufiytTRhJ7x852(DtAG4v5s)1tLB6h700GQ9dw3VM97A0O)YaAWtA9Ns4n0C7hqIbu)akoQceSP21JX9l(CB)Ujnq8QCPFI0DmkScDajor9Rz)eP7yuyfQoGeNO(beaxLQabBQD9yC)Ip32VBsdeVkx6NiDhJcRqaGeNO(1SFI0DmkScvaGeNO(beahufiytDtTRqLKCvU0VR2F41jT(pdwXWMAKAjBsphgPw8kE7hS6yPGRcdtyK0V43OMYBtT4v82pysqCLmV97aSbF)aisaC0u3ulEfV97gcHrMXUTPw8kE7Nk6hmmj6e1k9tLZ48aI7FW9BP2F0Ff7je247xjW9hLsA97dJyKMZP)QWcYmSPw8kE7Nk6NkNXonpx6pkL06xYo5oQZ(jnkH(RNk30VRO4FxdBQfVI3(PI(DnR9l(LZDcd3FHXonF)kbE2(DJ4hC)4SI1PIXWM6M6WRtAyOKL9zLCOUdmXKtvpC5sFcNCH0yKVAs1XAQdVoPHHsw2NvYH6oWeJ(Wyc(nO1M6WRtAyOKL9zLCOUdmX0yV6gsa)qd8IAmDUKziorp05sMVCLmV4M6WRtAyOKL9zLCOUdmXkjQ8HVAib8sw2hy9QtfdSdrc(Hg4WRdi(YgxnmwuhccI5tqSfMcP4CNWKkMgh2uiO8CyNn1HxN0Wqjl7Zk5qDhyIftfxUycPc(Hg4WRdi(Ygxnm2fWwkGI5tqSfMcP4CNWKkMgh2uiO8CyNccHxhq8LnUAySlaautD41jnmuYY(Ssou3bMyyLJIZlMqQGFObo86aIVSXvdJffabba9ji2ctHuCUtyccACytHGYZHDcK0WRdi(YgxnmgyaAQBQdVoPHDhyI5tut59IjKAtD41jnS7atmFIAkVxmHub)zm(6lad2Ie8dnWlQX05sMHywcbuWs8vYM(tuf6KMGaorpYJvG24mWxnZd(kjhCAcca6tRGokCzq8IJZnPV05QOglvSf1y6CjZqmlHakyj(kzt)jQcDsdOMAXB)GfZ(dcCu6pSs)GBdJkfDodyj3pye)7M(zJRggdw1(jX9xsJiT)s2VsyW9tNB)soHtEX9lZ(afZ9pkrL(L5(1m7hljQQC2FyL(jX97dJiT)LJYCC2p42WOs7hlH9d947xgLMgdBQdVoPHDhyIPByuPOZzalhJ8ftivWp0alMglzwHd(k5eo5TPo86Kg2DGjMpoNB41jT7zWk4TOIbw3XOWkg8dnW(eeBHPqko3jmP(mpLKKb1fLXesfUCvmgwQpZtjjzWLXPf6yKVXUjj4YvXyybbX8ji2ctHuCUtys9zEkjjdQlkJjKkC5QymCtT4v82V4h(eo7No8JrUFNj62FjrL1(rnDo97mr7NqaI7xcQ2pvoJtl0Xi3VR4UjP(ljjd89NB)dD)kbUFFMNssY6FW9Rz2)jnY9Rz)f(eo7No8JrUFNj62V4NevwH97kq3VLg3Fs3VsGXC)(0kJoPH7pwU)q(W9Rz)vS2pPrjmw)kbUFhISFm7tRG7)WmPWj47xjW9JNQ(PdpJ73zIU9l(jrL1(dunRcD8X54e2ulEfV9hEDsd7oWeZys0jQvUlJZdig8dnW4e9ipwbAmj6e1k3LX5belfqzuAA4Y40cDmY3y3KeevIGGpZtjjzWLXPf6yKVXUjj4YvXyyrDisbb6Hmb9UCvmg2fhUkqn1HxN0WUdmX8X5CdVoPDpdwbVfvmW(cUPo86Kg2DGjMpoNB41jT7zWk4TOIbgRGFObo86aIVSXvdJDbSBQdVoPHDhyI5JZ5gEDs7EgScElQyG1D8uWesfd(Hg4WRdi(YgxnmwuaAQBQdVoPHH(cgyzEX8szmYGFObgqzuAAOUOmMqQqujsLrPPHlJtl0XiFJDtsqujs9ji2ctHuCUtyajiaOmknnuxugtiviQePYO00qsZPCXsMDumevIuFcITWuOnKjOx6GbsqaqFcITWuii2ucoxbbFcITWuOX(np5wasQmknnuxugtiviQebb5eJLspKjO3LRIXWU4aSfea0NGylmfsX5oHjvgLMgUmoTqhJ8n2njbrLiLEitqVlxfJHDr8b2a1uhEDsdd9fS7atm5tMLln66e8dnWYO00qDrzmHuHOsee8zEkjjdQlkJjKkC5QymSOGTifeKtmwk9qMGExUkgd7IdxTPo86Kgg6ly3bMyH5zSUX56JZb8dnWYO00qDrzmHuHOsee8zEkjjdQlkJjKkC5QymSOGTifeKtmwk9qMGExUkgd7IdxTPo86Kgg6ly3bMy0ZYYNmlGFObwgLMgQlkJjKkevIGGpZtjjzqDrzmHuHlxfJHffSfPGGCIXsPhYe07YvXyyxCLn1HxN0WqFb7oWe7mKjO4lyvqlKRytb)qdSmknnuxugtivyjjzn1HxN0WqFb7oWetsQtAGFObwgLMgQlkJjKkevIuaLrPPHYNmlhuScrLiiOXsMvibookbOeV6caIeibb5eJLspKjO3LRIXWUaGRkiaOpbXwykKIZDctQmknnCzCAHog5BSBscIkrk9qMGExUkgd7I4daGAQBQdVoPHHyfySYrX5ftivWp0aRXHnfIvokoV0Phflfqjld6s2xGoGyLJIZlMqQsLrPPHyLJIZlD6rXWLRIXWUiobbzuAAiw5O48sNEumSKKmGKcOmknnCzCAHog5BSBscwssMGGy(eeBHPqko3jmGAQdVoPHHy1DGjgL5CUycP2uhEDsddXQ7atSsIkF4Rgsa)qdmG(eeBHPqko3jmPa6Z8ussgCzCAHog5BSBscUCvmg2fY(cqccI5tqSfMcP4CNWKkMpbXwyk0gYe0lDWcc(eeBHPqBitqV0blfqFMNssYGKMt5ILm7Oy4YvXyyxi7lcc(mpLKKbjnNYflz2rXWLRIXWIc2Ieibb6Hmb9UCvmg2fhIdiPak2gt5YGytHrPGHmvhSIfe2ykxgeBkmkfmevIua3ykxgeBkmkfmCmxCisPBmLldInfgLcgUCvmg2fWwqyJPCzqSPWOuWWXe1N5PKKmbHWRdi(Ygxnmwuhajii2gt5YGytHrPGHOsKc4gt5YGytHrPGH(e1uGDiiSXuUmi2uyuky4yI6Z8ussgqa1uhEDsddXQ7atm6tSm4hAG1yV6gsGOsKUOgtNlzgIt0dDUK5lxjZlUPo86KggIv3bMyASxDdjGFObErnMoxYmeNOh6CjZxUsMxSun2RUHe4YvXyyxi7ls9zEkjjdsFILHlxfJHDHSV0uhEDsddXQ7atmMQsojEaXxmHuBQdVoPHHy1DGjgP5uUyjZokg8dnWITXuUmi2uyukyit1bRybbX2ykxgeBkmkfmevI0nMYLbXMcJsbdlOBOtAUVXuUmi2uyuky4yUaGife2ykxgeBkmkfmevI0nMYLbXMcJsbdxUkgdlQdxPGq41beFzJRgglQJM6WRtAyiwDhyIrFcNC5IjKAtD41jnmeRUdmXkCOeUEcbLnQa)qdmD6rXU7dSExMmBUqNEumSkOAtD41jnmeRUdmXIBf6w49M0x)MKWn1HxN0WqS6oWeJumNXiFJDtsGFOb2N5PKKm4Y40cDmY3y3KeC5QymSlK9fPakMgh2uitvjNepG4lMqQccYO00q5tMLdkwHOsasqqmFcITWuifN7eMGGpZtjjzWLXPf6yKVXUjj4YvXyybb5eJLspKjO3LRIXWUiUM6WRtAyiwDhyITmoTqhJ8n2njb(HgyaLrPPHLev(WxnKarLii4Z8ussgSKOYh(QHe4YvXyyrDisbbX04WMcljQ8HVAirqGEitqVlxfJHDXbaajfqX2ykxgeBkmkfmKP6GvSGGyBmLldInfgLcgIkrkGBmLldInfgLcgwq3qN0CFJPCzqSPWOuWWXCXHife2ykxgeBkmkfm0NOMcSdGee2ykxgeBkmkfmevI0nMYLbXMcJsbdxUkgdlQRuqi86aIVSXvdJf1bqn1HxN0WqS6oWeduEoStWp0alJstdxgNwOJr(g7MKGOsee8zEkjjdUmoTqhJ8n2njbxUkgdlQdrkiiMpbXwykKIZDctkGYO00qjl7hmFXesfdljjtqqmnoSPqpHPk4nUycPkieEDaXx24QHXUaaqn1HxN0WqS6oWedRCuCEXesf8dnW(eeBHPqko3jmP0Phf7UpW6DzYS5cD6rXWQGQsbeqFMNssYGlJtl0XiFJDtsWLRIXWUq2xOsa2sbumCIEKhRazAAu8aIVHnvXn8E(WBO5kiiMgh2uyjrLp8vdjabKGGgh2uyjrLp8vdjs9zEkjjdwsu5dF1qcC5QymSlGnqn1HxN0WqS6oWetxugtivWp0alJstdLSSFW8ftivmSKKmPa6tqSfMcbXMsW5ki4tqSfMcn2V5j3IGGgh2uOpoNXiFvc8ftivmqccYO00WLXPf6yKVXUjjiQebbFMNssYGlJtl0XiFJDtsWLRIXWI6qKccYO00qsZPCXsMDumevIGGmknneuEoStiQePHxhq8LnUAySOoeeKtmwk9qMGExUkgd7caIRPo86KggIv3bMyBizkx6zzWp0aVOgtNlzgIrxYJr(IjKkwQgh2uiwxoQoJXsb0N5PKKm4Y40cDmY3y3KeC5QymSOoePGGy(eeBHPqko3jmbbX04WMcljQ8HVAirqaNOh5XkqMMgfpG4BytvCdVNp8gAUa1uhEDsddXQ7atSyQ4YftivW7D6p8vJLmRyGDa(HgyzuAAOKL9dMVycPIHLKKjiaOmknnuxugtiviQebbA0Z5USNqSK5RovSlK9f39bwV6uXajfqX04WMc9eMQG34IjKQGq41beFzJRgg7caajiiJstd1D8uUycPIHlxfJHfLPk7rv(Qtfln86aIVSXvdJf1rtD41jnmeRUdmX2qYuU0ZYGFObgqFMNssYGlJtl0XiFJDtsWLRIXWI6qKccI5tqSfMcP4CNWeeetJdBkSKOYh(QHebbCIEKhRazAAu8aIVHnvXn8E(WBO5cKu60JID3hy9Umz2CHo9OyyvqvPakJstdljQ8HVAibwssMuzuAAihKpSgN0WxDr5lD6rXWssYee04WMcX6Yr1zmgOM6WRtAyiwDhyI5jmvbVXftivWp0alJstdLSSFW8ftivmevIGaD6rXI6tS6E41jnymvC5IjKk0NyTPo86KggIv3bMyX6dJVycPc(HgyzuAAOKL9dMVycPIHOseeOtpkwuFIv3dVoPbJPIlxmHuH(eRn1HxN0WqS6oWedZRe20lwhJm49o9h(QXsMvmWoa)qd8Y0lJjeYhwQglzwH6uXxnVLHfTGUHoP1uhEDsddXQ7atm5y3Gmd(Hg4WRdi(Ygxnmwuhn1HxN0WqS6oWeBdjt5spld(Hgya9zEkjjdUmoTqhJ8n2njbxUkgdlQdrkDrnMoxYmeJUKhJ8ftivSGGy(eeBHPqko3jmbbX04WMcljQ8HVAirqaNOh5XkqMMgfpG4BytvCdVNp8gAUajLo9Oy39bwVltMnxOtpkgwfuvkGYO00WsIkF4RgsGLKKjiOXHnfI1LJQZymqn1HxN0WqS6oWetoiFt6RUJNcg8dnWYO00qDrzmHuHLKK1uhEDsddXQ7atm6dJj43Gwb)qdmorpYJvGsqXk6HV8IkrN0KkJstd1fLXesfwsswtD41jnmeRUdmXWkhfNxmHuBQBQdVoPHH6oEkycPIbgRCuCEXesf8dnWACytHyLJIZlD6rXsh7sFgYeuPYO00qSYrX5Lo9Oy4YvXyyxextD41jnmu3XtbtivS7atmkZ5CXesf8dnWlQX05sMHssupHBsF3aSm3l9gKRytXsLrPPH0NWjV4BvSuGOsAQdVoPHH6oEkycPIDhyIrFcNC5IjKk4hAGxuJPZLmdLKOEc3K(UbyzUx6nixXMIBQdVoPHH6oEkycPIDhyIvsu5dF1qc4hAGb0NGylmfsX5oHj1N5PKKm4Y40cDmY3y3KeC5QymSlK9fbbX8ji2ctHuCUtysfZNGylmfAdzc6LoybbFcITWuOnKjOx6GLcOpZtjjzqsZPCXsMDumC5QymSlK9fbbFMNssYGKMt5ILm7Oy4YvXyyrbBrcKGGglzwH6uXxnVLHDXHife8zEkjjdUmoTqhJ8n2njbxUkgdlQdrkn86aIVSXvdJffSbskGITXuUmi2uyukyit1bRybHnMYLbXMcJsbdxUkgdlQRuqqmFcITWuifN7egqn1HxN0WqDhpfmHuXUdmX0yV6gsa)qd8IAmDUKziorp05sMVCLmVyPASxDdjWLRIXWUq2xK6Z8ussgK(eldxUkgd7czFPPo86KggQ74PGjKk2DGjg9jwg8NX4RVamaId8dnWASxDdjqujsxuJPZLmdXj6HoxY8LRK5f3uhEDsdd1D8uWesf7oWeJPQKtIhq8fti1M6WRtAyOUJNcMqQy3bMyKMt5ILm7OyWp0al2gt5YGytHrPGHmvhSIfe2ykxgeBkmkfmC5QymSOoePGq41beFzJRgglkWBmLldInfgLcg6tutPsaqtD41jnmu3XtbtivS7atmsXCgJ8n2njb(HgyFMNssYGlJtl0XiFJDtsWLRIXWUq2xKcOyACytHmvLCs8aIVycPkiiJstdLpzwoOyfIkbibbX8ji2ctHuCUtycc(mpLKKbxgNwOJr(g7MKGlxfJHf1HifeKtmwk9qMGExUkgd7I4AQdVoPHH6oEkycPIDhyITmoTqhJ8n2njb(Hgya9zEkjjdckph2jC5QymSlK9fbbX04WMcbLNd7uqqJLmRqDQ4RM3YWU4aaGKcOyBmLldInfgLcgYuDWkwqyJPCzqSPWOuWWLRIXWI6kfecVoG4lBC1WyrbEJPCzqSPWOuWqFIAkvcaaQPo86KggQ74PGjKk2DGjgO8CyNGFObwgLMgUmoTqhJ8n2njbrLii4Z8ussgCzCAHog5BSBscUCvmgwuhIuqqmFcITWuifN7ewtD41jnmu3XtbtivS7atm5y3Gm3uhEDsdd1D8uWesf7oWetxugtivWp0alJstdxgNwOJr(g7MKGOsee8zEkjjdUmoTqhJ8n2njbxUkgdlQdrkiiMpbXwykKIZDctqqoXyP0dzc6D5QymSlaiYM6WRtAyOUJNcMqQy3bMyBizkx6zzWp0aVOgtNlzgIrxYJr(IjKkwkG(mpLKKbxgNwOJr(g7MKGlxfJHf1HifeeZNGylmfsX5oHjiiMgh2uyjrLp8vdjajvgLMgQ74PCXesfdxUkgdlkWmvzpQYxDQ4M6WRtAyOUJNcMqQy3bMyXuXLlMqQG370F4RglzwXa7a8dnWYO00qDhpLlMqQy4YvXyyrbMPk7rv(QtflfqzuAAOKL9dMVycPIHLKKjiqJEo3L9eILmF1PIDXhy9Qtf7ozFrqqgLMgQlkJjKkevcqn1HxN0WqDhpfmHuXUdmXkCOeUEcbLnQa)qdmD6rXU7dSExMmBUqNEumSkOAtD41jnmu3XtbtivS7atSnKmLl9Sm4hAGb0N5PKKm4Y40cDmY3y3KeC5QymSOoeP0f1y6CjZqm6sEmYxmHuXccI5tqSfMcP4CNWeeeBrnMoxYmeJUKhJ8ftivSGGyACytHLev(WxnKaKuzuAAOUJNYftivmC5QymSOaZuL9OkF1PIBQdVoPHH6oEkycPIDhyIvHE0btivWp0alJstd1D8uUycPIHLKKjiiJstdLSSFW8ftivmevIu60JIf1Ny19WRtAWyQ4YftivOpXQuaftJdBk0tyQcEJlMqQccHxhq8LnUAySOGnqn1HxN0WqDhpfmHuXUdmX8eMQG34IjKk4hAGLrPPHsw2py(IjKkgIkrkD6rXI6tS6E41jnymvC5IjKk0NyvA41beFzJRgg7I4PPo86KggQ74PGjKk2DGjgL5CUycPc(HgyzuAAyHJYLDYWssYAQdVoPHH6oEkycPIDhyIf3k0TW7nPV(njHBQdVoPHH6oEkycPIDhyIrFcNC5IjKAtD41jnmu3XtbtivS7atmmVsytVyDmYG370F4RglzwXa7a8dnWltVmMqiF4M6WRtAyOUJNcMqQy3bMyvOhDWesf8dnW0PhflQpXQ7HxN0GXuXLlMqQqFIvPa6Z8ussgCzCAHog5BSBscUCvmgwuXjiiMpbXwykKIZDcdOM6WRtAyOUJNcMqQy3bMyASxDdjGFObErnMoxYm0ymEmYKI1j(QBirYyKVHejXgkkUPo86KggQ74PGjKk2DGjg9Ymy5yKV6gsa)qd8IAmDUKzOXy8yKjfRt8v3qIKXiFdjsInuuCtD41jnmu3XtbtivS7atm5G8nPV6oEkyWp0alJstd1fLXesfwsswtD41jnmu3XtbtivS7atm6dJj43Gwb)qdmorpYJvGsqXk6HV8IkrN0KkJstd1fLXesfwsswtD41jnmu3XtbtivS7atmSYrX5fti1M6M6WRtAyOUJrHvmWGIDc5ddElQyGXon)fvc4bfhugyzuAA4Y40cDmY3y3KeevIGGmknnuxugtiviQKM6WRtAyOUJrHvS7atmqXoH8HbVfvmWyDtJ8f708xujGhuCqzG9ji2ctHuCUtysLrPPHlJtl0XiFJDtsqujsLrPPH6IYycPcrLiiiMpbXwykKIZDctQmknnuxugtiviQKM6WRtAyOUJrHvS7atmqXoH8HbVfvmWyDtJ8f7083LRIXWGpLamM1Hg8GIdkdSpZtjjzWLXPf6yKVXUjj4YvXyyxe)5Z8ussguxugtiv4YvXyyWdkoO8LpygyFMNssYG6IYycPcxUkgdd(HgyzuAAOUOmMqQWssYK6tqSfMcP4CNWAQdVoPHH6ogfwXUdmXaf7eYhg8wuXaJ1nnYxStZFxUkgdd(ucWywhAWdkoOmW(mpLKKbxgNwOJr(g7MKGlxfJHbpO4GYx(GzG9zEkjjdQlkJjKkC5Qymm4hAGLrPPH6IYycPcrLi1NGylmfsX5oH1uhEDsdd1DmkSIDhyIbk2jKpm4TOIbg7083LRIXWGpLamM1Hg8dnW(eeBHPqko3jmWdkoOmW(mpLKKbxgNwOJr(g7MKGlxfJHfv8NpZtjjzqDrzmHuHlxfJHbpO4GYx(GzG9zEkjjdQlkJjKkC5QymCtD41jnmu3XOWk2DGjgkMVJYvyWJpPIbw3XOWQdWp0adOUJrHvOdiHaFrX8vgLMwqWNGylmfsX5oHjv3XOWk0bKqGV(mpLKKbKuabf7eYhgI1nnYxStZFrLifqX8ji2ctHuCUtysft3XOWkeaiHaFrX8vgLMwqWNGylmfsX5oHjvmDhJcRqaGec81N5PKKmbbDhJcRqaG(mpLKKbxUkgdliO7yuyf6asiWxumFLrPPLcOy6ogfwHaaje4lkMVYO00cc6ogfwHoG(mpLKKblOBOtAIcSUJrHviaqFMNssYGf0n0jnGee0DmkScDaje4RpZtjjzsft3XOWkeaiHaFrX8vgLMwQUJrHvOdOpZtjjzWc6g6KMOaR7yuyfca0N5PKKmybDdDsdibbXaf7eYhgI1nnYxStZFrLifqX0DmkScbasiWxumFLrPPLcOUJrHvOdOpZtjjzWc6g6Kgvioxaf7eYhgIDA(7YvXyybbqXoH8HHyNM)UCvmgwuDhJcRqhqFMNssYGf0n0jnWAaasqq3XOWkeaiHaFrX8vgLMwkG6ogfwHoGec8ffZxzuAAP6ogfwHoG(mpLKKblOBOtAIcSUJrHviaqFMNssYGf0n0jnPaQ7yuyf6a6Z8ussgSGUHoPrfIZfqXoH8HHyNM)UCvmgwqauStiFyi2P5VlxfJHfv3XOWk0b0N5PKKmybDdDsdSgaGeeaumDhJcRqhqcb(II5RmknTGGUJrHviaqFMNssYGf0n0jnrbw3XOWk0b0N5PKKmybDdDsdiPaQ7yuyfca0N5PKKm4YrXPuDhJcRqaG(mpLKKblOBOtAuH4efuStiFyi2P5VlxfJHLck2jKpme7083LRIXWUO7yuyfca0N5PKKmybDdDsdSgabbX0DmkScba6Z8ussgC5O4ukG6ogfwHaa9zEkjjdUCvmgMkeNlGIDc5ddX6Mg5l2P5VlxfJHLck2jKpmeRBAKVyNM)UCvmgwuaePua1DmkScDa9zEkjjdwq3qN0OcX5cOyNq(WqStZFxUkgdliO7yuyfca0N5PKKm4YvXyyQqCUak2jKpme7083LRIXWs1DmkScba6Z8ussgSGUHoPrfoeP7GIDc5ddXon)D5QymSlGIDc5ddX6Mg5l2P5VlxfJHfeaf7eYhgIDA(7YvXyyr1DmkScDa9zEkjjdwq3qN0aRbqqauStiFyi2P5VOsasqq3XOWkeaOpZtjjzWLRIXWuH4efuStiFyiw30iFXon)D5QymSua1DmkScDa9zEkjjdwq3qN0OcX5cOyNq(WqSUPr(IDA(7YvXyybbX0DmkScDaje4lkMVYO00sbeuStiFyi2P5VlxfJHfv3XOWk0b0N5PKKmybDdDsdSgabbqXoH8HHyNM)IkbiGaciGasqqoXyP0dzc6D5QymSlGIDc5ddXon)D5QymmqccIP7yuyf6asiWxumFLrPPLkMpbXwykKIZDctkG6ogfwHaaje4lkMVYO00sbeqXaf7eYhgIDA(lQebbDhJcRqaG(mpLKKbxUkgdlQ4askGGIDc5ddXon)D5QymSOaisbbDhJcRqaG(mpLKKbxUkgdtfItuqXoH8HHyNM)UCvmggiGeeet3XOWkeaiHaFrX8vgLMwkGIP7yuyfcaKqGV(mpLKKjiO7yuyfca0N5PKKm4YvXyybbDhJcRqaG(mpLKKblOBOtAIcSUJrHvOdOpZtjjzWc6g6Kgqa1uhEDsdd1DmkSIDhyIHI57OCfg84tQyG1DmkSca4hAGbu3XOWkeaiHaFrX8vgLMwqWNGylmfsX5oHjv3XOWkeaiHaF9zEkjjdiPack2jKpmeRBAKVyNM)IkrkGI5tqSfMcP4CNWKkMUJrHvOdiHaFrX8vgLMwqWNGylmfsX5oHjvmDhJcRqhqcb(6Z8ussMGGUJrHvOdOpZtjjzWLRIXWcc6ogfwHaaje4lkMVYO00sbumDhJcRqhqcb(II5RmknTGGUJrHviaqFMNssYGf0n0jnrbw3XOWk0b0N5PKKmybDdDsdibbDhJcRqaGec81N5PKKmPIP7yuyf6asiWxumFLrPPLQ7yuyfca0N5PKKmybDdDstuG1DmkScDa9zEkjjdwq3qN0asqqmqXoH8HHyDtJ8f708xujsbumDhJcRqhqcb(II5RmknTua1DmkScba6Z8ussgSGUHoPrfIZfqXoH8HHyNM)UCvmgwqauStiFyi2P5VlxfJHfv3XOWkeaOpZtjjzWc6g6KgynaajiO7yuyf6asiWxumFLrPPLcOUJrHviaqcb(II5RmknTuDhJcRqaG(mpLKKblOBOtAIcSUJrHvOdOpZtjjzWc6g6KMua1DmkScba6Z8ussgSGUHoPrfIZfqXoH8HHyNM)UCvmgwqauStiFyi2P5VlxfJHfv3XOWkeaOpZtjjzWc6g6KgynaajiaOy6ogfwHaaje4lkMVYO00cc6ogfwHoG(mpLKKblOBOtAIcSUJrHviaqFMNssYGf0n0jnGKcOUJrHvOdOpZtjjzWLJItP6ogfwHoG(mpLKKblOBOtAuH4efuStiFyi2P5VlxfJHLck2jKpme7083LRIXWUO7yuyf6a6Z8ussgSGUHoPbwdGGGy6ogfwHoG(mpLKKbxokoLcOUJrHvOdOpZtjjzWLRIXWuH4CbuStiFyiw30iFXon)D5QymSuqXoH8HHyDtJ8f7083LRIXWIcGiLcOUJrHviaqFMNssYGf0n0jnQqCUak2jKpme7083LRIXWcc6ogfwHoG(mpLKKbxUkgdtfIZfqXoH8HHyNM)UCvmgwQUJrHvOdOpZtjjzWc6g6Kgv4qKUdk2jKpme7083LRIXWUak2jKpmeRBAKVyNM)UCvmgwqauStiFyi2P5VlxfJHfv3XOWkeaOpZtjjzWc6g6KgynaccGIDc5ddXon)fvcqcc6ogfwHoG(mpLKKbxUkgdtfItuqXoH8HHyDtJ8f7083LRIXWsbu3XOWkeaOpZtjjzWc6g6Kgvioxaf7eYhgI1nnYxStZFxUkgdliiMUJrHviaqcb(II5RmknTuabf7eYhgIDA(7YvXyyr1DmkScba6Z8ussgSGUHoPbwdGGaOyNq(WqStZFrLaeqabeqajiiNySu6Hmb9UCvmg2fqXoH8HHyNM)UCvmggibbX0DmkScbasiWxumFLrPPLkMpbXwykKIZDctkG6ogfwHoGec8ffZxzuAAPacOyGIDc5ddXon)fvIGGUJrHvOdOpZtjjzWLRIXWIkoGKciOyNq(WqStZFxUkgdlkaIuqq3XOWk0b0N5PKKm4YvXyyQqCIck2jKpme7083LRIXWabKGGy6ogfwHoGec8ffZxzuAAPakMUJrHvOdiHaF9zEkjjtqq3XOWk0b0N5PKKm4YvXyybbDhJcRqhqFMNssYGf0n0jnrbw3XOWkeaOpZtjjzWc6g6KgqaHuJLWEeWaG4epikIIGa]] )


end