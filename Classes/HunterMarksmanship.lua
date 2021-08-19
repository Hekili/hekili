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


    spec:RegisterPack( "Marksmanship", 20210818, [[d8K(qcqic0JekrxcjPyteXNqiJcqDkazvijL8kHQMfqLBHKKDb6xiuggrQoMqAza4zav10iG4AePSnGQ4BeqACcLW5ekjRtOsVdOkvAEcf3dG2hrY)iGQ6GeqXcjapuOIjcuLQUibuzJeqv(iqvkJeOkvCsHskRej1mfk1nrskLDcu6NcLunucOulfjPQNQctfO4ReqjJfHQ9cXFvPbRQdt1IjQhlyYsCzuBgP(mIA0i40kwnssP61iXSL0Tvr7MYVfnCc64ijvwUsphQPt66qA7a57iY4rsCEHy9avjZNq7xQrIIagKJIRmcybq6aev6XIOXciasxGiTOaGCOreYihc9afNmJCy(jJCq1MVuWNUHjmcroe6rQPxqadYbor3aJCel7NGQcXXLyeJ8OeqLHH8Ky45eT66KwyDALy45mqmKdz0PQXAgImYrXvgbSaiDaIk9yr0ybeaPlqKw0OihoQsixKJJ5moiheMsHnezKJcJdihuT5lf8PBycJW(bVdQP82ulWGsgfR9hnwaU(bq6aeTPUPooeCJmJJBtnv1pyzs0jQv6NQNXzfe3)G73sTFV)toqWTj0VsG73lL06p4gXin1A)NU5Kzytnv1pvpJJybU0VxkP1VWDYD0i9tAuc9FmNXPFbgb2XgICuhSIradYHUtGcMqQyeWGa2OiGb5GnxUYfebGCe2r5DCKd1RSPqSYEjYLodOyiBUCLl9lP)XU01HmbTFj9lJstdXk7Lix6mGIHlF6JH7pM(LgYHh0jnKdSYEjYftivefbSaGagKd2C5kxqeaYryhL3XrowuJPZLmdfMObc3K(Uo4vUx61jFYMIHS5YvU0VK(LrPPH0vpcV47PVuGOcro8GoPHCqzQ1lMqQikcybFeWGCWMlx5cIaqoc7O8ooYXIAmDUKzOWenq4M031bVY9sVo5t2umKnxUYfKdpOtAih0vpcxUycPIOiGvGGagKd2C5kxqeaYryhL3XroaU)qcIn3uiLi74w)s6pKzTKKm4Y40CDmYxF3KeC5tFmC)X0p5qPFrX(fS)qcIn3uiLi74w)s6xW(dji2CtH2qMGEPDUFrX(dji2CtH2qMGEPDUFj9dC)HmRLKKbjn1YflC2rXWLp9XW9ht)KdL(ff7pKzTKKmiPPwUyHZokgU8PpgUFP6h8LE)a1VOy)QVKzfQZjF18wgU)y6pQ07xuS)qM1ssYGlJtZ1XiF9DtsWLp9XW9lv)rLE)s63d6aIVSXNdJ7xQ(b)(bQFj9dC)c2)6t5YGytHEPGHmvgSI7xuS)1NYLbXMc9sbdx(0hd3Vu9hR6xuSFb7pKGyZnfsjYoU1pqihEqN0qokjQCLVQlerraR0qadYbBUCLlica5iSJY74ihlQX05sMH4eTsNlz(YNY8IHS5YvU0VK(vFV66cHlF6JH7pM(jhk9lP)qM1ssYG0vFz4YN(y4(JPFYHcYHh0jnKd13RUUqefbSGheWGCWMlx5cIaqo8GoPHCqx9Lroc7O8ooYH67vxxievy)s6FrnMoxYmeNOv6CjZx(uMxmKnxUYfKJ6y8nuqoaqAikcyfOiGb5Wd6KgYbtfH1epG4lMqQihS5YvUGiaefbSXceWGCWMlx5cIaqoc7O8ooYHG9V(uUmi2uOxkyitLbR4(ff7F9PCzqSPqVuWWLp9XW9lv)rLE)II97bDaXx24ZHX9lfG9V(uUmi2uOxkyyirnTFQw9daYHh0jnKdstTCXcNDumIIa2yfcyqoyZLRCbraihHDuEhh5iKzTKKm4Y40CDmYxF3KeC5tFmC)X0p5qPFj9dC)c2V6v2uitfH1epG4lMqQq2C5kx6xuSFzuAAOCnZsffRquH9du)II9ly)HeeBUPqkr2XT(ff7pKzTKKm4Y40CDmYxF3KeC5tFmC)s1FuP3VOy)Yjg3VK(PhYe07YN(y4(JPFPHC4bDsd5GKp1XiF9DtsikcyJkDeWGCWMlx5cIaqoc7O8ooYbW9hYSwssgeuwRCe4YN(y4(JPFYHs)II9ly)QxztHGYALJazZLRCPFrX(vFjZkuNt(Q5TmC)X0Fua6hO(L0pW9ly)RpLldInf6LcgYuzWkUFrX(xFkxgeBk0lfmC5tFmC)s1FSQFrX(9GoG4lB85W4(LcW(xFkxgeBk0lfmmKOM2pvR(bOFGqo8GoPHCSmonxhJ813njHOiGnAueWGCWMlx5cIaqoc7O8ooYHmknnCzCAUog5RVBscIkSFrX(fS)qcIn3uiLi74gYHh0jnKdqzTYrqueWgfaeWGC4bDsd5q231jZihS5YvUGiaefbSrbFeWGCWMlx5cIaqoc7O8ooYHmknnCzCAUog5RVBscIkSFrX(dzwljjdUmonxhJ813njbx(0hd3Vu9hv69lk2VG9hsqS5McPezh36xuSF5eJ7xs)0dzc6D5tFmC)X0pash5Wd6KgYHUOmMqQikcyJkqqadYbBUCLlica5iSJY74ihlQX05sMHy0L8yKVycPIHS5YvU0VK(bU)qM1ssYGlJtZ1XiF9DtsWLp9XW9lv)rLE)II9ly)HeeBUPqkr2XT(ff7xW(vVYMcljQCLVQleYMlx5s)a1VK(LrPPH6obkxmHuXWLp9XW9lfG9ZuHdOkF15Kro8GoPHCSUWPCPNLrueWgvAiGb5GnxUYfebGC4bDsd5WNtUCXesf5iSJY74ihYO00qDNaLlMqQy4YN(y4(LcW(zQWbuLV6CY9lPFG7xgLMgkC5WG5lMqQyyjjz9lk2pnATExoqWxY8vNtU)y6p4y9QZj3F89tou6xuSFzuAAOUOmMqQquH9deYrisOYx1xYSIraBuefbSrbpiGb5GnxUYfebGCe2r5DCKd6mGI7p((dowVltMT(JPF6mGIHNovqo8GoPHCuyxjCdeCkRFIOiGnQafbmihS5YvUGiaKJWokVJJCaC)HmRLKKbxgNMRJr(67MKGlF6JH7xQ(Jk9(L0)IAmDUKzigDjpg5lMqQyiBUCLl9lk2VG9hsqS5McPezh36xuSFb7FrnMoxYmeJUKhJ8ftivmKnxUYL(ff7xW(vVYMcljQCLVQleYMlx5s)a1VK(LrPPH6obkxmHuXWLp9XW9lfG9ZuHdOkF15Kro8GoPHCSUWPCPNLrueWgnwGagKd2C5kxqeaYryhL3XroKrPPH6obkxmHuXWssY6xuSFzuAAOWLddMVycPIHOc7xs)0zaf3Vu9hsS2F897bDsd6ZjxUycPcdjw7xs)a3VG9RELnfgimNoV(ftiviBUCLl9lk2Vh0beFzJphg3Vu9d(9deYHh0jnKJt0QoycPIOiGnAScbmihS5YvUGiaKJWokVJJCiJstdfUCyW8ftivmevy)s6NodO4(LQ)qI1(JVFpOtAqFo5YftivyiXA)s63d6aIVSXNdJ7pM(fiihEqN0qoceMtNx)IjKkIIawaKocyqoyZLRCbraihHDuEhh5qgLMgwyVC5imSKKmKdpOtAihuMA9IjKkIIawaIIagKdpOtAih(9eDl8Et6BytsyKd2C5kxqeaIIawaaabmihEqN0qoOREeUCXesf5GnxUYfebGOiGfaWhbmihS5YvUGiaKdpOtAihyEfYMEX6yKroc7O8ooYXY0lJj4Yvg5ieju5R6lzwXiGnkIIawaeiiGb5GnxUYfebGCe2r5DCKd6mGI7xQ(djw7p((9GoPb95KlxmHuHHeR9lPFG7pKzTKKm4Y40CDmYxF3KeC5tFmC)s1V06xuSFb7pKGyZnfsjYoU1pqihEqN0qoorR6GjKkIIawaKgcyqoyZLRCbraihHDuEhh5yrnMoxYm0ymEmYK8nc(QRlu4yKVUqH(6kkgYMlx5cYHh0jnKd13RUUqefbSaaEqadYbBUCLlica5iSJY74ihlQX05sMHgJXJrMKVrWxDDHchJ81fk0xxrXq2C5kxqo8GoPHCqVmdEng5RUUqefbSaiqradYbBUCLlica5iSJY74ihYO00qDrzmHuHLKKHC4bDsd5q2jFt6RUtGcgrralaXceWGCWMlx5cIaqoc7O8ooYborRYJvGcrXkALV8IkuN0GS5YvU0VK(LrPPH6IYycPcljjd5Wd6KgYbDLXecRtRikcybiwHagKdpOtAihyL9sKlMqQihS5YvUGiaefrrokmTJwveWGa2OiGb5Wd6KgYrirnL3lMqQihS5YvUGiaefbSaGagKd2C5kxqeaYHh0jnKJqIAkVxmHuroc7O8ooYXIAmDUKziMfsaf8cFfUzO6NUoPbzZLRCPFrX(XjAvESc0Mio(QzwXxH5GtdYMlx5s)II9dC)H0kOJcxgeVyVEt6lDUkQXq2C5kx6xs)c2)IAmDUKziMfsaf8cFfUzO6NUoPbzZLRCPFGqoQJX3qb5a8LoIIawWhbmihS5YvUGiaKdpOtAih66gvh6uhWRXiFXesf5OW4Woc1jnKdWBz)ob2l97wPFWSUr1Ho1b8I7hScSJt)SXNdJbx)K4(lPrK2Fj7xjm4(PZTFHvpcV4(L5GJI5(hLOs)YC)AM9Jf6NNr63Ts)K4(dUrK2)YEzQr6hmRBuD9JfYHHEc9lJstJHihHDuEhh5qW(vFjZkCWxHvpcVikcyfiiGb5GnxUYfebGCe2r5DCKJqcIn3uiLi74w)s6pKzTKKmOUOmMqQWLp9XW9lP)qM1ssYGlJtZ1XiF9DtsWLp9XW9lk2VG9hsqS5McPezh36xs)HmRLKKb1fLXesfU8Ppgg5Wd6KgYrWR1Rh0jTBDWkYrDW618tg5q3XOWkgrraR0qadYbBUCLlica5Wd6KgYrWR1Rh0jTBDWkYrDW618tg5iuWikcybpiGb5GnxUYfebGCe2r5DCKdpOdi(YgFomU)y6h8ro8GoPHCe8A96bDs7whSICuhSEn)KroWkIIawbkcyqoyZLRCbraihHDuEhh5Wd6aIVSXNdJ7xQ(ba5Wd6KgYrWR1Rh0jTBDWkYrDW618tg5q3jqbtivmIIOihcxoKNYUIageWgfbmihEqN0qoKtvRC5sx9iCH0yKVAsLXqoyZLRCbraikcybabmihEqN0qoORmMqyDAf5GnxUYfebGOiGf8radYbBUCLlica5iSJY74ihlQX05sMH4eTsNlz(YNY8IHS5YvUGC4bDsd5q99QRlerraRabbmihS5YvUGiaKdHlhCSE15KroIkDKdpOtAihLevUYx1fICe2r5DCKdpOdi(YgFomUFP6pA)II9ly)HeeBUPqkr2XT(L0VG9RELnfckRvocKnxUYfefbSsdbmihS5YvUGiaKJuiYbMvKdpOtAihG8DC5kJCaYROmYrLjZwX3iq2jxz1RPHV6IYx6mGIHS5YvU0VK(XSQJrgdzNCLvVM2ftYfczZLRCb5OW4Woc1jnKJ4qWnYC)A2F0(1SF8CIwDL7xGdmc8i2XHaV(jZ(Ij5c7hmlkJjKA)cxo4yfICaY3R5NmYbR0xHlhCSIOiGf8GagKd2C5kxqeaYryhL3Xroa574YvgYk9v4YbhRihEqN0qo0fLXesfrraRafbmihS5YvUGiaKJWokVJJC4bDaXx24ZHX9ht)GF)s6h4(fS)qcIn3uiLi74w)s6xW(vVYMcbL1khbYMlx5s)II97bDaXx24ZHX9ht)a0pq9lPFb7hKVJlxziR0xHlhCSIC4bDsd5WNtUCXesfrraBSabmihS5YvUGiaKJWokVJJC4bDaXx24ZHX9lv)a0VOy)a3FibXMBkKsKDCRFrX(vVYMcbL1khbYMlx5s)a1VK(9GoG4lB85W4(bSFa6xuSFq(oUCLHSsFfUCWXkYHh0jnKdSYEjYftivefrrocfmcyqaBueWGCWMlx5cIaqoc7O8ooYbW9lJstd1fLXesfIkSFj9lJstdxgNMRJr(67MKGOc7xs)HeeBUPqkr2XT(bQFrX(bUFzuAAOUOmMqQquH9lPFzuAAiPPwUyHZokgIkSFj9hsqS5McTHmb9s7C)a1VOy)a3FibXMBkeeBkHiB)II9hsqS5McnoSzn3s)a1VK(LrPPH6IYycPcrf2VOy)Yjg3VK(PhYe07YN(y4(JP)OGF)II9dC)HeeBUPqkr2XT(L0VmknnCzCAUog5RVBscIkSFj9tpKjO3Lp9XW9ht)cuWVFGqo8GoPHCiZlMxkJrgrralaiGb5GnxUYfebGCe2r5DCKdzuAAOUOmMqQquH9lk2FiZAjjzqDrzmHuHlF6JH7xQ(bFP3VOy)Yjg3VK(PhYe07YN(y4(JP)OGhKdpOtAihY1mlxA0ncIIawWhbmihS5YvUGiaKJWokVJJCiJstd1fLXesfIkSFrX(dzwljjdQlkJjKkC5tFmC)s1p4l9(ff7xoX4(L0p9qMGEx(0hd3Fm9hf8GC4bDsd5WTaJ11R3GxRikcyfiiGb5GnxUYfebGCe2r5DCKdzuAAOUOmMqQquH9lk2FiZAjjzqDrzmHuHlF6JH7xQ(bFP3VOy)Yjg3VK(PhYe07YN(y4(JP)yfYHh0jnKd6zz5AMfefbSsdbmihS5YvUGiaKJWokVJJCiJstd1fLXesfwssgYHh0jnKJ6qMGIVuTJwiFYMIOiGf8GagKd2C5kxqeaYryhL3XroKrPPH6IYycPcrf2VK(bUFzuAAOCnZsffRquH9lk2V6lzwHeyVQeGcdA)X0pasVFG6xuSF5eJ7xs)0dzc6D5tFmC)X0paGN(ff7h4(dji2CtHuISJB9lPFzuAA4Y40CDmYxF3Keevy)s6NEitqVlF6JH7pM(fOa0pqihEqN0qoeM6KgIIOihyfbmiGnkcyqoyZLRCbraihHDuEhh5q9kBkeRSxICPZakgYMlx5s)s6h4(fUmOl5qbgfIv2lrUycP2VK(LrPPHyL9sKlDgqXWLp9XW9ht)sRFrX(LrPPHyL9sKlDgqXWssY6hO(L0pW9lJstdxgNMRJr(67MKGLKK1VOy)c2FibXMBkKsKDCRFGqo8GoPHCGv2lrUycPIOiGfaeWGC4bDsd5GYuRxmHuroyZLRCbraikcybFeWGCWMlx5cIaqoc7O8ooYbW9hsqS5McPezh36xs)a3FiZAjjzWLXP56yKV(Ujj4YN(y4(JPFYHs)a1VOy)c2FibXMBkKsKDCRFj9ly)HeeBUPqBitqV0o3VOy)HeeBUPqBitqV0o3VK(bU)qM1ssYGKMA5Ifo7Oy4YN(y4(JPFYHs)II9hYSwssgK0ulxSWzhfdx(0hd3Vu9d(sVFG6xuSF6Hmb9U8PpgU)y6pQ06hO(L0pW9ly)RpLldInf6LcgYuzWkUFrX(xFkxgeBk0lfmevy)s6h4(xFkxgeBk0lfmCS(JP)OsVFj9V(uUmi2uOxky4YN(y4(JPFWVFrX(xFkxgeBk0lfmCS(LQFpOtA3qM1ssY6xuSFpOdi(YgFomUFP6pA)a1VOy)c2)6t5YGytHEPGHOc7xs)a3)6t5YGytHEPGHHe10(bS)O9lk2)6t5YGytHEPGHJ1Vu97bDs7gYSwssw)a1pqihEqN0qokjQCLVQlerraRabbmihS5YvUGiaKJWokVJJCO(E11fcrf2VK(xuJPZLmdXjALoxY8LpL5fdzZLRCb5Wd6KgYbD1xgrraR0qadYbBUCLlica5iSJY74ihlQX05sMH4eTsNlz(YNY8IHS5YvU0VK(vFV66cHlF6JH7pM(jhk9lP)qM1ssYG0vFz4YN(y4(JPFYHcYHh0jnKd13RUUqefbSGheWGC4bDsd5GPIWAIhq8ftivKd2C5kxqeaIIawbkcyqoyZLRCbraihHDuEhh5qW(xFkxgeBk0lfmKPYGvC)II9ly)RpLldInf6LcgIkSFj9V(uUmi2uOxkyybDDDsR)47F9PCzqSPqVuWWX6pM(bq69lk2)6t5YGytHEPGHOc7xs)RpLldInf6LcgU8PpgUFP6pASQFrX(9GoG4lB85W4(LQ)OihEqN0qoin1YflC2rXikcyJfiGb5Wd6KgYbD1JWLlMqQihS5YvUGiaefbSXkeWGCWMlx5cIaqoc7O8ooYbDgqX9hF)bhR3LjZw)X0pDgqXWtNkihEqN0qokSReUbcoL1prueWgv6iGb5Wd6KgYHFpr3cV3K(g2Keg5GnxUYfebGOiGnAueWGCWMlx5cIaqoc7O8ooYriZAjjzWLXP56yKV(Ujj4YN(y4(JPFYHs)s6h4(fSF1RSPqMkcRjEaXxmHuHS5YvU0VOy)YO00q5AMLkkwHOc7hO(ff7xW(dji2CtHuISJB9lk2FiZAjjzWLXP56yKV(Ujj4YN(y4(ff7xoX4(L0p9qMGEx(0hd3Fm9lnKdpOtAihK8Pog5RVBscrraBuaqadYbBUCLlica5iSJY74iha3VmknnSKOYv(QUqiQW(ff7xW(vVYMcljQCLVQleYMlx5s)II9lNyC)s6NEitqVlF6JH7pM(Jcq)a1VK(bUFb7F9PCzqSPqVuWqMkdwX9lk2VG9V(uUmi2uOxkyiQW(L0pW9V(uUmi2uOxkyybDDDsR)47F9PCzqSPqVuWWX6pM(Jk9(ff7F9PCzqSPqVuWWqIAA)a2F0(bQFrX(xFkxgeBk0lfmevy)s6F9PCzqSPqVuWWLp9XW9lv)XQ(ff73d6aIVSXNdJ7xQ(J2pqihEqN0qowgNMRJr(67MKqueWgf8radYbBUCLlica5iSJY74ihYO00WLXP56yKV(UjjiQW(ff7xW(dji2CtHuISJB9lPFG7xgLMgkC5WG5lMqQyyjjz9lk2VG9RELnfgimNoV(ftiviBUCLl9lk2Vh0beFzJphg3Fm9dq)aHC4bDsd5auwRCeefbSrfiiGb5GnxUYfebGCe2r5DCKJqcIn3uiLi74w)s6NodO4(JV)GJ17YKzR)y6NodOy4PtL(L0pW9dC)HmRLKKbxgNMRJr(67MKGlF6JH7pM(jhk9t1QFWVFj9dC)c2porRYJvGmnnkEaXx3Mt)6Hax511CHS5YvU0VOy)c2V6v2uyjrLR8vDHq2C5kx6hO(bQFrX(vVYMcljQCLVQleYMlx5s)s6pKzTKKmyjrLR8vDHWLp9XW9ht)GF)aHC4bDsd5aRSxICXesfrraBuPHagKd2C5kxqeaYryhL3XroKrPPHcxomy(IjKkgwssw)s6h4(dji2CtHGytjez7xuS)qcIn3uOXHnR5w6xuSF1RSPWGxRJr(Qe4lMqQyiBUCLl9du)II9lJstdxgNMRJr(67MKGOc7xuSFzuAAiPPwUyHZokgIkSFrX(LrPPHGYALJarf2VK(9GoG4lB85W4(LQ)O9lk2VCIX9lPF6Hmb9U8PpgU)y6haPHC4bDsd5qxugtivefbSrbpiGb5GnxUYfebGCe2r5DCKJf1y6CjZqm6sEmYxmHuXq2C5kx6xs)QxztHyDz)SogdzZLRCPFj9dC)HmRLKKbxgNMRJr(67MKGlF6JH7xQ(Jk9(ff7xW(dji2CtHuISJB9lk2VG9RELnfwsu5kFvxiKnxUYL(ff7hNOv5XkqMMgfpG4RBZPF9qGR86AUq2C5kx6hiKdpOtAihRlCkx6zzefbSrfOiGb5GnxUYfebGC4bDsd5WNtUCXesf5iSJY74ihYO00qHlhgmFXesfdljjRFrX(bUFzuAAOUOmMqQquH9lk2pnATExoqWxY8vNtU)y6NCO0F89hCSE15K7hO(L0pW9ly)QxztHbcZPZRFXesfYMlx5s)II97bDaXx24ZHX9ht)a0pq9lk2Vmknnu3jq5IjKkgU8PpgUFP6NPchqv(QZj3VK(9GoG4lB85W4(LQ)OihHiHkFvFjZkgbSrrueWgnwGagKd2C5kxqeaYryhL3XroaU)qM1ssYGlJtZ1XiF9DtsWLp9XW9lv)rLE)II9ly)HeeBUPqkr2XT(ff7xW(vVYMcljQCLVQleYMlx5s)II9Jt0Q8yfittJIhq81T50VEiWvEDnxiBUCLl9du)s6NodO4(JV)GJ17YKzR)y6NodOy4PtL(L0pW9lJstdljQCLVQlewssw)s6xgLMgYo5kREnn8vxu(sNbumSKKS(ff7x9kBkeRl7N1XyiBUCLl9deYHh0jnKJ1foLl9SmIIa2OXkeWGCWMlx5cIaqoc7O8ooYHmknnu4YHbZxmHuXquH9lk2pDgqX9lv)HeR9hF)EqN0G(CYLlMqQWqIvKdpOtAihbcZPZRFXesfrralashbmihS5YvUGiaKJWokVJJCiJstdfUCyW8ftivmevy)II9tNbuC)s1FiXA)X3Vh0jnOpNC5IjKkmKyf5Wd6KgYHVb34lMqQikcybikcyqoyZLRCbraihEqN0qoW8kKn9I1XiJCe2r5DCKJLPxgtWLRC)s6x9LmRqDo5RM3YW9lv)f011jnKJqKqLVQVKzfJa2OikcybaaeWGCWMlx5cIaqoc7O8ooYHh0beFzJphg3Vu9hf5Wd6KgYHSVRtMrueWca4JagKd2C5kxqeaYryhL3XroaU)qM1ssYGlJtZ1XiF9DtsWLp9XW9lv)rLE)s6FrnMoxYmeJUKhJ8ftivmKnxUYL(ff7xW(dji2CtHuISJB9lk2VG9RELnfwsu5kFvxiKnxUYL(ff7hNOv5XkqMMgfpG4RBZPF9qGR86AUq2C5kx6hO(L0pDgqX9hF)bhR3LjZw)X0pDgqXWtNk9lPFG7xgLMgwsu5kFvxiSKKS(ff7x9kBkeRl7N1XyiBUCLl9deYHh0jnKJ1foLl9SmIIawaeiiGb5GnxUYfebGCe2r5DCKdzuAAOUOmMqQWssYqo8GoPHCi7KVj9v3jqbJOiGfaPHagKd2C5kxqeaYryhL3XroWjAvEScuikwrR8LxuH6KgKnxUYL(L0VmknnuxugtivyjjzihEqN0qoORmMqyDAfrralaGheWGC4bDsd5aRSxICXesf5GnxUYfebGOikYHUJrHvmcyqaBueWGCWMlx5cIaqosHihywro8GoPHCaY3XLRmYbiVIYihYO00WLXP56yKV(UjjiQW(ff7xgLMgQlkJjKkeviYbiFVMFYih4iw4IkerralaiGb5GnxUYfebGCKcroWSIC4bDsd5aKVJlxzKdqEfLrocji2CtHuISJB9lPFzuAA4Y40CDmYxF3Keevy)s6xgLMgQlkJjKkevy)II9ly)HeeBUPqkr2XT(L0VmknnuxugtiviQqKdq(En)KroW6Mg5loIfUOcrueWc(iGb5GnxUYfebGCKcroWSo0ihEqN0qoa574Yvg5aKVxZpzKdSUPr(IJyH7YN(yyKJWokVJJCiJstd1fLXesfwssw)s6pKGyZnfsjYoUHCaYRO8LRyg5iKzTKKmOUOmMqQWLp9XWihG8kkJCeYSwssgCzCAUog5RVBscU8PpgU)ye43FiZAjjzqDrzmHuHlF6JHrueWkqqadYbBUCLlica5ifICGzDOro8GoPHCaY3XLRmYbiFVMFYihyDtJ8fhXc3Lp9XWihHDuEhh5qgLMgQlkJjKkevy)s6pKGyZnfsjYoUHCaYRO8LRyg5iKzTKKmOUOmMqQWLp9XWihG8kkJCeYSwssgCzCAUog5RVBscU8PpggrraR0qadYbBUCLlica5ifICGzDOro8GoPHCaY3XLRmYbiFVMFYih4iw4U8Ppgg5iSJY74ihHeeBUPqkr2XnKdqEfLVCfZihHmRLKKb1fLXesfU8Ppgg5aKxrzKJqM1ssYGlJtZ1XiF9DtsWLp9XW9lLa)(dzwljjdQlkJjKkC5tFmmIIawWdcyqoyZLRCbraihEqN0qo0DmkSgf5iSJY74iha3VUJrHvOgfsWXxumFLrPP7xuS)qcIn3uiLi74w)s6x3XOWkuJcj44BiZAjjz9du)s6h4(b574YvgI1nnYxCelCrf2VK(bUFb7pKGyZnfsjYoU1VK(fSFDhJcRqfaibhFrX8vgLMUFrX(dji2CtHuISJB9lPFb7x3XOWkubasWX3qM1ssY6xuSFDhJcRqfayiZAjjzWLp9XW9lk2VUJrHvOgfsWXxumFLrPP7xs)a3VG9R7yuyfQaaj44lkMVYO009lk2VUJrHvOgfgYSwssgSGUUoP1Vua2VUJrHvOcamKzTKKmybDDDsRFG6xuSFDhJcRqnkKGJVHmRLKK1VK(fSFDhJcRqfaibhFrX8vgLMUFj9R7yuyfQrHHmRLKKblORRtA9lfG9R7yuyfQaadzwljjdwqxxN06hO(ff7xW(b574YvgI1nnYxCelCrf2VK(bUFb7x3XOWkubasWXxumFLrPP7xs)a3VUJrHvOgfgYSwssgSGUUoP1pv1V06pM(b574YvgIJyH7YN(y4(ff7hKVJlxzioIfUlF6JH7xQ(1DmkSc1OWqM1ssYGf011jT(jw)a0pq9lk2VUJrHvOcaKGJVOy(kJst3VK(bUFDhJcRqnkKGJVOy(kJst3VK(1DmkSc1OWqM1ssYGf011jT(LcW(1DmkScvaGHmRLKKblORRtA9lPFG7x3XOWkuJcdzwljjdwqxxN06NQ6xA9ht)G8DC5kdXrSWD5tFmC)II9dY3XLRmehXc3Lp9XW9lv)6ogfwHAuyiZAjjzWc666Kw)eRFa6hO(ff7h4(fSFDhJcRqnkKGJVOy(kJst3VOy)6ogfwHkaWqM1ssYGf011jT(LcW(1DmkSc1OWqM1ssYGf011jT(bQFj9dC)6ogfwHkaWqM1ssYGl7Li9lPFDhJcRqfayiZAjjzWc666Kw)uv)sRFP6hKVJlxzioIfUlF6JH7xs)G8DC5kdXrSWD5tFmC)X0VUJrHvOcamKzTKKmybDDDsRFI1pa9lk2VG9R7yuyfQaadzwljjdUSxI0VK(bUFDhJcRqfayiZAjjzWLp9XW9tv9lT(JPFq(oUCLHyDtJ8fhXc3Lp9XW9lPFq(oUCLHyDtJ8fhXc3Lp9XW9lv)ai9(L0pW9R7yuyfQrHHmRLKKblORRtA9tv9lT(JPFq(oUCLH4iw4U8PpgUFrX(1DmkScvaGHmRLKKbx(0hd3pv1V06pM(b574YvgIJyH7YN(y4(L0VUJrHvOcamKzTKKmybDDDsRFQQ)OsV)47hKVJlxzioIfUlF6JH7pM(b574YvgI1nnYxCelCx(0hd3VOy)G8DC5kdXrSWD5tFmC)s1VUJrHvOgfgYSwssgSGUUoP1pX6hG(ff7hKVJlxzioIfUOc7hO(ff7x3XOWkubagYSwssgC5tFmC)uv)sRFP6hKVJlxziw30iFXrSWD5tFmC)s6h4(1DmkSc1OWqM1ssYGf011jT(PQ(Lw)X0piFhxUYqSUPr(IJyH7YN(y4(ff7xW(1DmkSc1Oqco(II5RmknD)s6h4(b574YvgIJyH7YN(y4(LQFDhJcRqnkmKzTKKmybDDDsRFI1pa9lk2piFhxUYqCelCrf2pq9du)a1pq9du)a1VOy)Yjg3VK(PhYe07YN(y4(JPFq(oUCLH4iw4U8PpgUFG6xuSFb7x3XOWkuJcj44lkMVYO009lPFb7pKGyZnfsjYoU1VK(bUFDhJcRqfaibhFrX8vgLMUFj9dC)a3VG9dY3XLRmehXcxuH9lk2VUJrHvOcamKzTKKm4YN(y4(LQFP1pq9lPFG7hKVJlxzioIfUlF6JH7xQ(bq69lk2VUJrHvOcamKzTKKm4YN(y4(PQ(Lw)s1piFhxUYqCelCx(0hd3pq9du)II9ly)6ogfwHkaqco(II5RmknD)s6h4(fSFDhJcRqfaibhFdzwljjRFrX(1DmkScvaGHmRLKKbx(0hd3VOy)6ogfwHkaWqM1ssYGf011jT(LcW(1DmkSc1OWqM1ssYGf011jT(bQFGqoW1uXih6ogfwJIOiGvGIagKd2C5kxqeaYHh0jnKdDhJcRaGCe2r5DCKdG7x3XOWkubasWXxumFLrPP7xuS)qcIn3uiLi74w)s6x3XOWkubasWX3qM1ssY6hO(L0pW9dY3XLRmeRBAKV4iw4IkSFj9dC)c2FibXMBkKsKDCRFj9ly)6ogfwHAuibhFrX8vgLMUFrX(dji2CtHuISJB9lPFb7x3XOWkuJcj44BiZAjjz9lk2VUJrHvOgfgYSwssgC5tFmC)II9R7yuyfQaaj44lkMVYO009lPFG7xW(1DmkSc1Oqco(II5RmknD)II9R7yuyfQaadzwljjdwqxxN06xka7x3XOWkuJcdzwljjdwqxxN06hO(ff7x3XOWkubasWX3qM1ssY6xs)c2VUJrHvOgfsWXxumFLrPP7xs)6ogfwHkaWqM1ssYGf011jT(LcW(1DmkSc1OWqM1ssYGf011jT(bQFrX(fSFq(oUCLHyDtJ8fhXcxuH9lPFG7xW(1DmkSc1Oqco(II5RmknD)s6h4(1DmkScvaGHmRLKKblORRtA9tv9lT(JPFq(oUCLH4iw4U8PpgUFrX(b574YvgIJyH7YN(y4(LQFDhJcRqfayiZAjjzWc666Kw)eRFa6hO(ff7x3XOWkuJcj44lkMVYO009lPFG7x3XOWkubasWXxumFLrPP7xs)6ogfwHkaWqM1ssYGf011jT(LcW(1DmkSc1OWqM1ssYGf011jT(L0pW9R7yuyfQaadzwljjdwqxxN06NQ6xA9ht)G8DC5kdXrSWD5tFmC)II9dY3XLRmehXc3Lp9XW9lv)6ogfwHkaWqM1ssYGf011jT(jw)a0pq9lk2pW9ly)6ogfwHkaqco(II5RmknD)II9R7yuyfQrHHmRLKKblORRtA9lfG9R7yuyfQaadzwljjdwqxxN06hO(L0pW9R7yuyfQrHHmRLKKbx2lr6xs)6ogfwHAuyiZAjjzWc666Kw)uv)sRFP6hKVJlxzioIfUlF6JH7xs)G8DC5kdXrSWD5tFmC)X0VUJrHvOgfgYSwssgSGUUoP1pX6hG(ff7xW(1DmkSc1OWqM1ssYGl7Li9lPFG7x3XOWkuJcdzwljjdU8PpgUFQQFP1Fm9dY3XLRmeRBAKV4iw4U8PpgUFj9dY3XLRmeRBAKV4iw4U8PpgUFP6haP3VK(bUFDhJcRqfayiZAjjzWc666Kw)uv)sR)y6hKVJlxzioIfUlF6JH7xuSFDhJcRqnkmKzTKKm4YN(y4(PQ(Lw)X0piFhxUYqCelCx(0hd3VK(1DmkSc1OWqM1ssYGf011jT(PQ(Jk9(JVFq(oUCLH4iw4U8PpgU)y6hKVJlxziw30iFXrSWD5tFmC)II9dY3XLRmehXc3Lp9XW9lv)6ogfwHkaWqM1ssYGf011jT(jw)a0VOy)G8DC5kdXrSWfvy)a1VOy)6ogfwHAuyiZAjjzWLp9XW9tv9lT(LQFq(oUCLHyDtJ8fhXc3Lp9XW9lPFG7x3XOWkubagYSwssgSGUUoP1pv1V06pM(b574YvgI1nnYxCelCx(0hd3VOy)c2VUJrHvOcaKGJVOy(kJst3VK(bUFq(oUCLH4iw4U8PpgUFP6x3XOWkubagYSwssgSGUUoP1pX6hG(ff7hKVJlxzioIfUOc7hO(bQFG6hO(bQFG6xuSF5eJ7xs)0dzc6D5tFmC)X0piFhxUYqCelCx(0hd3pq9lk2VG9R7yuyfQaaj44lkMVYO009lPFb7pKGyZnfsjYoU1VK(bUFDhJcRqnkKGJVOy(kJst3VK(bUFG7xW(b574YvgIJyHlQW(ff7x3XOWkuJcdzwljjdU8PpgUFP6xA9du)s6h4(b574YvgIJyH7YN(y4(LQFaKE)II9R7yuyfQrHHmRLKKbx(0hd3pv1V06xQ(b574YvgIJyH7YN(y4(bQFG6xuSFb7x3XOWkuJcj44lkMVYO009lPFG7xW(1DmkSc1Oqco(gYSwssw)II9R7yuyfQrHHmRLKKbx(0hd3VOy)6ogfwHAuyiZAjjzWc666Kw)sby)6ogfwHkaWqM1ssYGf011jT(bQFGqoW1uXih6ogfwbarruef5aeV4jneWcG0biQ0fOaa(ihK81gJmg5qGLadvpyJ1al4T42F)GHa3)CkmxTF6C7NiDNafmHuXe1)YuDOZYL(X5j3VJQ5PRCP)ab3iZyytDShJ7pAC7poPbIxLl9tK6v2uiXjQFn7Ni1RSPqIdzZLRCHO(bokvac2uh7X4(biU9hN0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHS5YvUqu)ahLkabBQJ9yC)GFC7poPbIxLl9t0IAmDUKziXjQFn7NOf1y6CjZqIdzZLRCHO(DTFbUy9y3pWrPcqWM6ypg3V0IB)Xjnq8QCPFIwuJPZLmdjor9Rz)eTOgtNlzgsCiBUCLle1pWrPcqWM6ypg3p4jU9hN0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHS5YvUqu)U2VaxSES7h4OubiytDShJ7pwf3(JtAG4v5s)ePELnfsCI6xZ(js9kBkK4q2C5kxiQFGJsfGGn1XEmU)OspU9hN0aXRYL(js9kBkK4e1VM9tK6v2uiXHS5YvUqu)ahLkabBQJ9yC)rfiXT)4KgiEvU0prQxztHeNO(1SFIuVYMcjoKnxUYfI6h4OubiytDShJ7pQajU9hN0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHS5YvUqu)ahLkabBQJ9yC)rfOXT)4KgiEvU0prQxztHeNO(1SFIuVYMcjoKnxUYfI6h4OubiytDShJ7pQanU9hN0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHS5YvUqu)adavac2uh7X4(JglIB)Xjnq8QCPFIuVYMcjor9Rz)ePELnfsCiBUCLle1pWrPcqWM6ypg3paslU9hN0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHS5YvUqu)U2VaxSES7h4OubiytDShJ7haWtC7poPbIxLl9t0IAmDUKziXjQFn7NOf1y6CjZqIdzZLRCHO(DTFbUy9y3pWrPcqWM6ypg3paXI42FCsdeVkx6NiCIwLhRajor9Rz)eHt0Q8yfiXHS5YvUqu)ahLkabBQBQfyjWq1d2ynWcElU93pyiW9pNcZv7No3(jQW0oAvjQ)LP6qNLl9JZtUFhvZtx5s)bcUrMXWM6ypg3paXT)4KgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKnxUYfI6h4OubiytDShJ7hG42FCsdeVkx6NOf1y6CjZqItu)A2prlQX05sMHehYMlx5cr9dCuQaeSPo2JX9dqC7poPbIxLl9tuiTc6OqItu)A2prH0kOJcjoKnxUYfI6h4OubiytDShJ7hG42FCsdeVkx6NiCIwLhRajor9Rz)eHt0Q8yfiXHS5YvUqu)ahLkabBQBQfyjWq1d2ynWcElU93pyiW9pNcZv7No3(js4YH8u2vI6FzQo0z5s)48K73r180vU0FGGBKzmSPo2JX9d(XT)4KgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKnxUYfI631(f4I1JD)ahLkabBQJ9yC)cK42FCsdeVkx6Ni1RSPqItu)A2prQxztHehYMlx5cr97A)cCX6XUFGJsfGGn1XEmUFbAC7poPbIxLl9tK6v2uiXjQFn7Ni1RSPqIdzZLRCHO(bokvac2uh7X4(JfXT)4KgiEvU0prQxztHeNO(1SFIuVYMcjoKnxUYfI6h4OubiytDtTalbgQEWgRbwWBXT)(bdbU)5uyUA)052pryLO(xMQdDwU0pop5(DunpDLl9hi4gzgdBQJ9yC)rJB)Xjnq8QCPFIuVYMcjor9Rz)ePELnfsCiBUCLle1pWrPcqWM6ypg3VajU9hN0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHS5YvUqu)U2VaxSES7h4OubiytDShJ7xAXT)4KgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKnxUYfI6h4OubiytDShJ7pA042FCsdeVkx6Ni1RSPqItu)A2prQxztHehYMlx5cr9dCuQaeSPo2JX9hfG42FCsdeVkx6Ni1RSPqItu)A2prQxztHehYMlx5cr9dCuQaeSPo2JX9hf8JB)Xjnq8QCPFIuVYMcjor9Rz)ePELnfsCiBUCLle1pWrPcqWM6ypg3FubsC7poPbIxLl9tK6v2uiXjQFn7Ni1RSPqIdzZLRCHO(bgaQaeSPo2JX9hvGe3(JtAG4v5s)eHt0Q8yfiXjQFn7NiCIwLhRajoKnxUYfI6h4OubiytDShJ7pQ0IB)Xjnq8QCPFIuVYMcjor9Rz)ePELnfsCiBUCLle1pWrPcqWM6ypg3FuWtC7poPbIxLl9tK6v2uiXjQFn7Ni1RSPqIdzZLRCHO(bgaQaeSPo2JX9hf8e3(JtAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2C5kxiQFGJsfGGn1XEmU)OGN42FCsdeVkx6NiCIwLhRajor9Rz)eHt0Q8yfiXHS5YvUqu)ahLkabBQJ9yC)rfOXT)4KgiEvU0prQxztHeNO(1SFIuVYMcjoKnxUYfI6h4OubiytDShJ7pASiU9hN0aXRYL(js9kBkK4e1VM9tK6v2uiXHS5YvUqu)adavac2uh7X4(JglIB)Xjnq8QCPFIWjAvEScK4e1VM9teorRYJvGehYMlx5cr9dCuQaeSPo2JX9da4h3(JtAG4v5s)ePELnfsCI6xZ(js9kBkK4q2C5kxiQFGbGkabBQJ9yC)aa(XT)4KgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKnxUYfI6h4OubiytDShJ7haWpU9hN0aXRYL(jcNOv5XkqItu)A2pr4eTkpwbsCiBUCLle1pWrPcqWM6ypg3paslU9hN0aXRYL(jcNOv5XkqItu)A2pr4eTkpwbsCiBUCLle1pWrPcqWMAWqG7NoR1K0yK73rxh3pjE5(rXCP)X6xjW97bDsR)6G1(Lr1(jXl3VLA)0jQv6FS(vcC)EPKw)fxDzhZXTPUFQQF2jxz1RPHV6IYx6mGIBQBQfyjWq1d2ynWcElU93pyiW9pNcZv7No3(js3XOWkMO(xMQdDwU0pop5(DunpDLl9hi4gzgdBQJ9yC)GN42FCsdeVkx6)yoJt)4iM6uPFQM(1S)yJ69xgqdEsR)uiVUMB)atmG6hyPrfGGn1XEmUFWtC7poPbIxLl9tKUJrHvyuiXjQFn7NiDhJcRqnkK4e1pWaeLkabBQJ9yC)GN42FCsdeVkx6NiDhJcRqaGeNO(1SFI0DmkScvaGeNO(bgaWdvac2uh7X4(fOXT)4KgiEvU0)XCgN(Xrm1Ps)un9Rz)Xg17VmGg8Kw)PqEDn3(bMya1pWsJkabBQJ9yC)c042FCsdeVkx6NiDhJcRWOqItu)A2pr6ogfwHAuiXjQFGba8qfGGn1XEmUFbAC7poPbIxLl9tKUJrHviaqItu)A2pr6ogfwHkaqItu)adquQaeSPUPow7uyUkx6h80Vh0jT(RdwXWMAKdSqoGawaKMab5q4M0tLroILXY(PAZxk4t3WegH9dEhut5TPowgl7xGbLmkw7pASaC9dG0biAtDtDSmw2FCi4gzgh3M6yzSSFQQFWYKOtuR0pvpJZkiU)b3VLA)E)NCGGBtOFLa3VxkP1FWnIrAQ1(pDZjZWM6yzSSFQQFQEghXcCPFVusRFH7K7Or6N0Oe6)yoJt)cmcSJnSPUP2d6KggkC5qEk7A8asm5u1kxU0vpcxing5RMuzSMApOtAyOWLd5PSRXdiXORmMqyDATP2d6KggkC5qEk7A8asm13RUUqWn0aUOgtNlzgIt0kDUK5lFkZlUP2d6KggkC5qEk7A8asSsIkx5R6cbNWLdowV6CYagv6GBOb0d6aIVSXNdJLkQOOGHeeBUPqkr2XnjcQELnfckRvostDSS)4qWnYC)A2F0(1SF8CIwDL7xGdmc8i2XHaV(jZ(Ij5c7hmlkJjKA)cxo4yf2u7bDsddfUCipLDnEajgiFhxUYGZ8tgqwPVcxo4yfCG8kkdyLjZwX3iq2jxz1RPHV6IYx6mGIHS5YvUibZQogzmKDYvw9AAxmjxiKnxUYLMApOtAyOWLd5PSRXdiX0fLXesfCdnGG8DC5kdzL(kC5GJ1MApOtAyOWLd5PSRXdiX85KlxmHub3qdOh0beFzJphghd4lbybdji2CtHuISJBseu9kBkeuwRCerrpOdi(YgFomogaasIGG8DC5kdzL(kC5GJ1MApOtAyOWLd5PSRXdiXWk7LixmHub3qdOh0beFzJphglfaIIahsqS5McPezh3efvVYMcbL1khbijEqhq8Ln(CymGaikcY3XLRmKv6RWLdowBQBQ9GoPHJhqIfsut59IjKAtTh0jnC8asSqIAkVxmHubxDm(gkac(shCdnGlQX05sMHywibuWl8v4MHQF66KMOiorRYJvG2eXXxnZk(kmhCAIIahsRGokCzq8I96nPV05QOglrWf1y6CjZqmlKak4f(kCZq1pDDsdOM6yz)G3Y(DcSx63Ts)GzDJQdDQd4f3pyfyhN(zJphgdE3(jX9xsJiT)s2VsyW9tNB)cREeEX9lZbhfZ9pkrL(L5(1m7hl0ppJ0VBL(jX9hCJiT)L9YuJ0pyw3O66hlKdd9e6xgLMgdBQ9GoPHJhqIPRBuDOtDaVgJ8ftivWn0akO6lzwHd(kS6r4TP2d6KgoEajwWR1Rh0jTBDWk4m)Kbu3XOWkgCdnGHeeBUPqkr2XnjHmRLKKb1fLXesfU8PpgwsiZAjjzWLXP56yKV(Ujj4YN(yyrrbdji2CtHuISJBsczwljjdQlkJjKkC5tFmCtDSmw2p49C1J0pThgJC)rs0T)sIkR9JA6u7psI2pbhe3VquTFQEgNMRJrUFbMDts9xssg46p3(h6(vcC)HmRLKK1)G7xZS)AAK7xZ(lC1J0pThgJC)rs0TFW7tuzf2FSgD)wAC)jD)kbgZ9hsRm6KgUFF5(D5k3VM9FYA)KgLWy9Re4(Jk9(XCiTcU)kZK8iGRFLa3pEo7N2dmU)ij62p49jQS2VJQ5PRtWR1iWM6yzSSFpOtA44bKygtIorTYDzCwbXGBObeNOv5XkqJjrNOw5UmoRGyjalJstdxgNMRJr(67MKGOcffdzwljjdUmonxhJ813njbx(0hdlvuPlkspKjO3Lp9XWXef8autTh0jnC8asSGxRxpOtA36GvWz(jdyOGBQ9GoPHJhqIf8A96bDs7whScoZpzaXk4gAa9GoG4lB85W4ya)MApOtA44bKybVwVEqN0U1bRGZ8tgqDNafmHuXGBOb0d6aIVSXNdJLcGM6MApOtAyyOGbuMxmVugJm4gAabwgLMgQlkJjKkevOezuAA4Y40CDmYxF3KeevOKqcIn3uiLi74gqIIalJstd1fLXesfIkuImknnK0ulxSWzhfdrfkjKGyZnfAdzc6L2zGefboKGyZnfcInLqKvumKGyZnfACyZAUfGKiJstd1fLXesfIkuuuoXyj0dzc6D5tFmCmrbFrrGdji2CtHuISJBsKrPPHlJtZ1XiF9DtsquHsOhYe07YN(y4yeOGpqn1EqN0WWqbhpGetUMz5sJUra3qdOmknnuxugtiviQqrXqM1ssYG6IYycPcx(0hdlf4lDrr5eJLqpKjO3Lp9XWXef80u7bDsdddfC8asm3cmwxVEdETcUHgqzuAAOUOmMqQquHIIHmRLKKb1fLXesfU8PpgwkWx6IIYjglHEitqVlF6JHJjk4PP2d6Kgggk44bKy0ZYY1mlGBObugLMgQlkJjKkevOOyiZAjjzqDrzmHuHlF6JHLc8LUOOCIXsOhYe07YN(y4yIvn1EqN0WWqbhpGeRoKjO4lv7OfYNSPGBObugLMgQlkJjKkSKKSMApOtAyyOGJhqIjm1jnWn0akJstd1fLXesfIkucWYO00q5AMLkkwHOcffvFjZkKa7vLauyqJbaPdKOOCIXsOhYe07YN(y4yaa8ikcCibXMBkKsKDCtImknnCzCAUog5RVBscIkuc9qMGEx(0hdhJafaGAQBQ9GoPHHyfqSYEjYftivWn0aQELnfIv2lrU0zaflbyHld6souGrHyL9sKlMqQsKrPPHyL9sKlDgqXWLp9XWXinrrzuAAiwzVe5sNbumSKKmGKaSmknnCzCAUog5RVBscwssMOOGHeeBUPqkr2XnGAQ9GoPHHynEajgLPwVycP2u7bDsddXA8asSsIkx5R6cb3qdiWHeeBUPqkr2XnjahYSwssgCzCAUog5RVBscU8PpgogYHcqIIcgsqS5McPezh3KiyibXMBk0gYe0lTZIIHeeBUPqBitqV0olb4qM1ssYGKMA5Ifo7Oy4YN(y4yihkIIHmRLKKbjn1YflC2rXWLp9XWsb(shirr6Hmb9U8PpgoMOsdijal46t5YGytHEPGHmvgSIffxFkxgeBk0lfmevOeGxFkxgeBk0lfmCSyIkDjRpLldInf6LcgU8PpgogWxuC9PCzqSPqVuWWXKkKzTKKmrrpOdi(YgFomwQOajkk46t5YGytHEPGHOcLa86t5YGytHEPGHHe1uaJkkU(uUmi2uOxky4ysfYSwssgqa1u7bDsddXA8asm6QVm4gAavFV66cHOcLSOgtNlzgIt0kDUK5lFkZlUP2d6KggI14bKyQVxDDHGBObCrnMoxYmeNOv6CjZx(uMxSe13RUUq4YN(y4yihksczwljjdsx9LHlF6JHJHCO0u7bDsddXA8asmMkcRjEaXxmHuBQ9GoPHHynEajgPPwUyHZokgCdnGcU(uUmi2uOxkyitLbRyrrbxFkxgeBk0lfmevOK1NYLbXMc9sbdlORRtAXV(uUmi2uOxky4yXaG0ffxFkxgeBk0lfmevOK1NYLbXMc9sbdx(0hdlv0yLOOh0beFzJphglv0MApOtAyiwJhqIrx9iC5IjKAtTh0jnmeRXdiXkSReUbcoL1pb3qdiDgqXXhCSExMmBXqNbum80PstTh0jnmeRXdiX87j6w49M03WMKWn1EqN0WqSgpGeJKp1XiF9DtsGBObmKzTKKm4Y40CDmYxF3KeC5tFmCmKdfjalO6v2uitfH1epG4lMqQIIYO00q5AMLkkwHOcbsuuWqcIn3uiLi74MOyiZAjjzWLXP56yKV(Ujj4YN(yyrr5eJLqpKjO3Lp9XWXiTMApOtAyiwJhqITmonxhJ813njbUHgqGLrPPHLevUYx1fcrfkkkO6v2uyjrLR8vDHIIYjglHEitqVlF6JHJjkaajbybxFkxgeBk0lfmKPYGvSOOGRpLldInf6LcgIkucWRpLldInf6LcgwqxxN0IF9PCzqSPqVuWWXIjQ0ffxFkxgeBk0lfmmKOMcyuGefxFkxgeBk0lfmevOK1NYLbXMc9sbdx(0hdlvSsu0d6aIVSXNdJLkkqn1EqN0WqSgpGeduwRCeWn0akJstdxgNMRJr(67MKGOcfffmKGyZnfsjYoUjbyzuAAOWLddMVycPIHLKKjkkO6v2uyGWC686xmHuff9GoG4lB85W4yaaOMApOtAyiwJhqIHv2lrUycPcUHgWqcIn3uiLi74Me6mGIJp4y9Umz2IHodOy4PtfjadCiZAjjzWLXP56yKV(Ujj4YN(y4yihkuTaFjaliorRYJvGmnnkEaXx3Mt)6Hax511Cfffu9kBkSKOYv(QUqGasuu9kBkSKOYv(QUqjHmRLKKbljQCLVQleU8PpgogWhOMApOtAyiwJhqIPlkJjKk4gAaLrPPHcxomy(IjKkgwssMeGdji2CtHGytjezffdji2CtHgh2SMBruu9kBkm416yKVkb(IjKkgirrzuAA4Y40CDmYxF3KeevOOOmknnK0ulxSWzhfdrfkkkJstdbL1khbIkuIh0beFzJphglvurr5eJLqpKjO3Lp9XWXaG0AQ9GoPHHynEaj26cNYLEwgCdnGlQX05sMHy0L8yKVycPILOELnfI1L9Z6ySeGdzwljjdUmonxhJ813njbx(0hdlvuPlkkyibXMBkKsKDCtuuq1RSPWsIkx5R6cffXjAvEScKPPrXdi(62C6xpe4kVUMlqn1EqN0WqSgpGeZNtUCXesfCHiHkFvFjZkgWOGBObugLMgkC5WG5lMqQyyjjzIIalJstd1fLXesfIkuuKgTwVlhi4lz(QZjhd5qj(GJ1RoNmqsawq1RSPWaH5051VycPkk6bDaXx24ZHXXaaqIIYO00qDNaLlMqQy4YN(yyPyQWbuLV6CYs8GoG4lB85WyPI2u7bDsddXA8asS1foLl9Sm4gAaboKzTKKm4Y40CDmYxF3KeC5tFmSurLUOOGHeeBUPqkr2XnrrbvVYMcljQCLVQluueNOv5XkqMMgfpG4RBZPF9qGR86AUajHodO44dowVltMTyOZakgE6urcWYO00WsIkx5R6cHLKKjrgLMgYo5kREnn8vxu(sNbumSKKmrr1RSPqSUSFwhJbQP2d6KggI14bKybcZPZRFXesfCdnGYO00qHlhgmFXesfdrfkksNbuSuHeRX7bDsd6ZjxUycPcdjwBQ9GoPHHynEajMVb34lMqQGBObugLMgkC5WG5lMqQyiQqrr6mGILkKynEpOtAqFo5YftivyiXAtTh0jnmeRXdiXW8kKn9I1XidUqKqLVQVKzfdyuWn0aUm9YycUCLLO(sMvOoN8vZBzyPkORRtAn1EqN0WqSgpGet231jZGBOb0d6aIVSXNdJLkAtTh0jnmeRXdiXwx4uU0ZYGBObe4qM1ssYGlJtZ1XiF9DtsWLp9XWsfv6swuJPZLmdXOl5XiFXesflkkyibXMBkKsKDCtuuq1RSPWsIkx5R6cffXjAvEScKPPrXdi(62C6xpe4kVUMlqsOZako(GJ17YKzlg6mGIHNovKaSmknnSKOYv(QUqyjjzIIQxztHyDz)SogdutTh0jnmeRXdiXKDY3K(Q7eOGb3qdOmknnuxugtivyjjzn1EqN0WqSgpGeJUYycH1PvWn0aIt0Q8yfOquSIw5lVOc1jnjYO00qDrzmHuHLKK1u7bDsddXA8asmSYEjYfti1M6MApOtAyOUtGcMqQyaXk7LixmHub3qdO6v2uiwzVe5sNbuSKXU01HmbvImknneRSxICPZakgU8PpgogP1u7bDsdd1DcuWesfhpGeJYuRxmHub3qd4IAmDUKzOWenq4M031bVY9sVo5t2uSezuAAiD1JWl(E6lfiQWMApOtAyOUtGcMqQ44bKy0vpcxUycPcUHgWf1y6CjZqHjAGWnPVRdEL7LEDYNSP4MApOtAyOUtGcMqQ44bKyLevUYx1fcUHgqGdji2CtHuISJBsczwljjdUmonxhJ813njbx(0hdhd5qruuWqcIn3uiLi74Mebdji2CtH2qMGEPDwumKGyZnfAdzc6L2zjahYSwssgK0ulxSWzhfdx(0hdhd5qrumKzTKKmiPPwUyHZokgU8PpgwkWx6ajkQ(sMvOoN8vZBz4yIkDrXqM1ssYGlJtZ1XiF9DtsWLp9XWsfv6s8GoG4lB85WyPaFGKaSGRpLldInf6LcgYuzWkwuC9PCzqSPqVuWWLp9XWsfReffmKGyZnfsjYoUbutTh0jnmu3jqbtivC8asm13RUUqWn0aUOgtNlzgIt0kDUK5lFkZlwI67vxxiC5tFmCmKdfjHmRLKKbPR(YWLp9XWXqouAQ9GoPHH6obkycPIJhqIrx9LbxDm(gkacG0a3qdO67vxxievOKf1y6CjZqCIwPZLmF5tzEXn1EqN0WqDNafmHuXXdiXyQiSM4beFXesTP2d6KggQ7eOGjKkoEajgPPwUyHZokgCdnGcU(uUmi2uOxkyitLbRyrX1NYLbXMc9sbdx(0hdlvuPlk6bDaXx24ZHXsb46t5YGytHEPGHHe1uQwa0u7bDsdd1DcuWesfhpGeJKp1XiF9DtsGBObmKzTKKm4Y40CDmYxF3KeC5tFmCmKdfjalO6v2uitfH1epG4lMqQIIYO00q5AMLkkwHOcbsuuWqcIn3uiLi74MOyiZAjjzWLXP56yKV(Ujj4YN(yyPIkDrr5eJLqpKjO3Lp9XWXiTMApOtAyOUtGcMqQ44bKylJtZ1XiF9DtsGBObe4qM1ssYGGYALJax(0hdhd5qruuq1RSPqqzTYrefvFjZkuNt(Q5TmCmrbaijal46t5YGytHEPGHmvgSIffxFkxgeBk0lfmC5tFmSuXkrrpOdi(YgFomwkaxFkxgeBk0lfmmKOMs1caGAQ9GoPHH6obkycPIJhqIbkRvoc4gAaLrPPHlJtZ1XiF9DtsquHIIcgsqS5McPezh3AQ9GoPHH6obkycPIJhqIj776K5MApOtAyOUtGcMqQ44bKy6IYycPcUHgqzuAA4Y40CDmYxF3KeevOOyiZAjjzWLXP56yKV(Ujj4YN(yyPIkDrrbdji2CtHuISJBIIYjglHEitqVlF6JHJbaP3u7bDsdd1DcuWesfhpGeBDHt5spldUHgWf1y6CjZqm6sEmYxmHuXsaoKzTKKm4Y40CDmYxF3KeC5tFmSurLUOOGHeeBUPqkr2XnrrbvVYMcljQCLVQleijYO00qDNaLlMqQy4YN(yyPaKPchqv(QZj3u7bDsdd1DcuWesfhpGeZNtUCXesfCHiHkFvFjZkgWOGBObugLMgQ7eOCXesfdx(0hdlfGmv4aQYxDozjalJstdfUCyW8ftivmSKKmrrA0A9UCGGVK5RoNCmbhRxDo54jhkIIYO00qDrzmHuHOcbQP2d6KggQ7eOGjKkoEajwHDLWnqWPS(j4gAaPZako(GJ17YKzlg6mGIHNovAQ9GoPHH6obkycPIJhqITUWPCPNLb3qdiWHmRLKKbxgNMRJr(67MKGlF6JHLkQ0LSOgtNlzgIrxYJr(IjKkwuuWqcIn3uiLi74MOOGlQX05sMHy0L8yKVycPIfffu9kBkSKOYv(QUqGKiJstd1DcuUycPIHlF6JHLcqMkCav5RoNCtTh0jnmu3jqbtivC8asSt0QoycPcUHgqzuAAOUtGYftivmSKKmrrzuAAOWLddMVycPIHOcLqNbuSuHeRX7bDsd6ZjxUycPcdjwLaSGQxztHbcZPZRFXesvu0d6aIVSXNdJLc8bQP2d6KggQ7eOGjKkoEajwGWC686xmHub3qdOmknnu4YHbZxmHuXquHsOZakwQqI149GoPb95KlxmHuHHeRs8GoG4lB85W4yein1EqN0WqDNafmHuXXdiXOm16ftivWn0akJstdlSxUCegwsswtTh0jnmu3jqbtivC8asm)EIUfEVj9nSjjCtTh0jnmu3jqbtivC8asm6QhHlxmHuBQ9GoPHH6obkycPIJhqIH5viB6fRJrgCHiHkFvFjZkgWOGBObCz6LXeC5k3u7bDsdd1DcuWesfhpGe7eTQdMqQGBObKodOyPcjwJ3d6Kg0NtUCXesfgsSkb4qM1ssYGlJtZ1XiF9DtsWLp9XWsjnrrbdji2CtHuISJBa1u7bDsdd1DcuWesfhpGet99QRleCdnGlQX05sMHgJXJrMKVrWxDDHchJ81fk0xxrXn1EqN0WqDNafmHuXXdiXOxMbVgJ8vxxi4gAaxuJPZLmdngJhJmjFJGV66cfog5RluOVUIIBQ9GoPHH6obkycPIJhqIj7KVj9v3jqbdUHgqzuAAOUOmMqQWssYAQ9GoPHH6obkycPIJhqIrxzmHW60k4gAaXjAvEScuikwrR8LxuH6KMezuAAOUOmMqQWssYAQ9GoPHH6obkycPIJhqIHv2lrUycP2u3u7bDsdd1DmkSIbeKVJlxzWz(jdioIfUOcbhiVIYakJstdxgNMRJr(67MKGOcffLrPPH6IYycPcrf2u7bDsdd1DmkSIJhqIbY3XLRm4m)KbeRBAKV4iw4IkeCG8kkdyibXMBkKsKDCtImknnCzCAUog5RVBscIkuImknnuxugtiviQqrrbdji2CtHuISJBsKrPPH6IYycPcrf2u7bDsdd1DmkSIJhqIbY3XLRm4m)KbeRBAKV4iw4U8PpggCPqaXSo0GdKxrzadzwljjdUmonxhJ813njbx(0hdhJa)qM1ssYG6IYycPcx(0hddoqEfLVCfZagYSwssguxugtiv4YN(yyWn0akJstd1fLXesfwssMKqcIn3uiLi74wtTh0jnmu3XOWkoEajgiFhxUYGZ8tgqSUPr(IJyH7YN(yyWLcbeZ6qdoqEfLbmKzTKKm4Y40CDmYxF3KeC5tFmm4a5vu(YvmdyiZAjjzqDrzmHuHlF6JHb3qdOmknnuxugtiviQqjHeeBUPqkr2XTMApOtAyOUJrHvC8asmq(oUCLbN5NmG4iw4U8PpggCPqaXSo0GBObmKGyZnfsjYoUboqEfLbmKzTKKm4Y40CDmYxF3KeC5tFmSuc8dzwljjdQlkJjKkC5tFmm4a5vu(YvmdyiZAjjzqDrzmHuHlF6JHBQ9GoPHH6ogfwXXdiXqX8Du(edoCnvmG6ogfwJcUHgqG1DmkScJcj44lkMVYO00IIHeeBUPqkr2Xnj6ogfwHrHeC8nKzTKKmGKamiFhxUYqSUPr(IJyHlQqjalyibXMBkKsKDCtIG6ogfwHaaj44lkMVYO00IIHeeBUPqkr2XnjcQ7yuyfcaKGJVHmRLKKjkQ7yuyfcamKzTKKm4YN(yyrrDhJcRWOqco(II5RmknTeGfu3XOWkeaibhFrX8vgLMwuu3XOWkmkmKzTKKmybDDDstka1DmkScbagYSwssgSGUUoPbKOOUJrHvyuibhFdzwljjtIG6ogfwHaaj44lkMVYO00s0DmkScJcdzwljjdwqxxN0KcqDhJcRqaGHmRLKKblORRtAajkkiiFhxUYqSUPr(IJyHlQqjalOUJrHviaqco(II5RmknTeG1DmkScJcdzwljjdwqxxN0OkPfdiFhxUYqCelCx(0hdlkcY3XLRmehXc3Lp9XWsP7yuyfgfgYSwssgSGUUoPr1aaqII6ogfwHaaj44lkMVYO00saw3XOWkmkKGJVOy(kJstlr3XOWkmkmKzTKKmybDDDstka1DmkScbagYSwssgSGUUoPjbyDhJcRWOWqM1ssYGf011jnQsAXaY3XLRmehXc3Lp9XWIIG8DC5kdXrSWD5tFmSu6ogfwHrHHmRLKKblORRtAunaaKOiWcQ7yuyfgfsWXxumFLrPPff1DmkScbagYSwssgSGUUoPjfG6ogfwHrHHmRLKKblORRtAajbyDhJcRqaGHmRLKKbx2lrKO7yuyfcamKzTKKmybDDDsJQKMuG8DC5kdXrSWD5tFmSeq(oUCLH4iw4U8PpgogDhJcRqaGHmRLKKblORRtAunaikkOUJrHviaWqM1ssYGl7Lisaw3XOWkeayiZAjjzWLp9XWuL0IbKVJlxziw30iFXrSWD5tFmSeq(oUCLHyDtJ8fhXc3Lp9XWsbG0LaSUJrHvyuyiZAjjzWc666KgvjTya574YvgIJyH7YN(yyrrDhJcRqaGHmRLKKbx(0hdtvslgq(oUCLH4iw4U8PpgwIUJrHviaWqM1ssYGf011jnQkQ0JhKVJlxzioIfUlF6JHJbKVJlxziw30iFXrSWD5tFmSOiiFhxUYqCelCx(0hdlLUJrHvyuyiZAjjzWc666KgvdaIIG8DC5kdXrSWfviqII6ogfwHaadzwljjdU8PpgMQKMuG8DC5kdX6Mg5loIfUlF6JHLaSUJrHvyuyiZAjjzWc666KgvjTya574YvgI1nnYxCelCx(0hdlkkOUJrHvyuibhFrX8vgLMwcWG8DC5kdXrSWD5tFmSu6ogfwHrHHmRLKKblORRtAunaikcY3XLRmehXcxuHabeqabeqIIYjglHEitqVlF6JHJbKVJlxzioIfUlF6JHbsuuqDhJcRWOqco(II5RmknTebdji2CtHuISJBsaw3XOWkeaibhFrX8vgLMwcWaliiFhxUYqCelCrfkkQ7yuyfcamKzTKKm4YN(yyPKgqsagKVJlxzioIfUlF6JHLcaPlkQ7yuyfcamKzTKKm4YN(yyQsAsbY3XLRmehXc3Lp9XWabKOOG6ogfwHaaj44lkMVYO00sawqDhJcRqaGeC8nKzTKKmrrDhJcRqaGHmRLKKbx(0hdlkQ7yuyfcamKzTKKmybDDDstka1DmkScJcdzwljjdwqxxN0acOMApOtAyOUJrHvC8asmumFhLpXGdxtfdOUJrHvaa3qdiW6ogfwHaaj44lkMVYO00IIHeeBUPqkr2Xnj6ogfwHaaj44BiZAjjzajbyq(oUCLHyDtJ8fhXcxuHsawWqcIn3uiLi74Meb1DmkScJcj44lkMVYO00IIHeeBUPqkr2XnjcQ7yuyfgfsWX3qM1ssYef1DmkScJcdzwljjdU8Ppgwuu3XOWkeaibhFrX8vgLMwcWcQ7yuyfgfsWXxumFLrPPff1DmkScbagYSwssgSGUUoPjfG6ogfwHrHHmRLKKblORRtAajkQ7yuyfcaKGJVHmRLKKjrqDhJcRWOqco(II5RmknTeDhJcRqaGHmRLKKblORRtAsbOUJrHvyuyiZAjjzWc666KgqIIccY3XLRmeRBAKV4iw4IkucWcQ7yuyfgfsWXxumFLrPPLaSUJrHviaWqM1ssYGf011jnQsAXaY3XLRmehXc3Lp9XWIIG8DC5kdXrSWD5tFmSu6ogfwHaadzwljjdwqxxN0OAaairrDhJcRWOqco(II5RmknTeG1DmkScbasWXxumFLrPPLO7yuyfcamKzTKKmybDDDstka1DmkScJcdzwljjdwqxxN0KaSUJrHviaWqM1ssYGf011jnQsAXaY3XLRmehXc3Lp9XWIIG8DC5kdXrSWD5tFmSu6ogfwHaadzwljjdwqxxN0OAaairrGfu3XOWkeaibhFrX8vgLMwuu3XOWkmkmKzTKKmybDDDstka1DmkScbagYSwssgSGUUoPbKeG1DmkScJcdzwljjdUSxIir3XOWkmkmKzTKKmybDDDsJQKMuG8DC5kdXrSWD5tFmSeq(oUCLH4iw4U8PpgogDhJcRWOWqM1ssYGf011jnQgaeffu3XOWkmkmKzTKKm4YEjIeG1DmkScJcdzwljjdU8PpgMQKwmG8DC5kdX6Mg5loIfUlF6JHLaY3XLRmeRBAKV4iw4U8PpgwkaKUeG1DmkScbagYSwssgSGUUoPrvslgq(oUCLH4iw4U8Ppgwuu3XOWkmkmKzTKKm4YN(yyQsAXaY3XLRmehXc3Lp9XWs0DmkScJcdzwljjdwqxxN0OQOspEq(oUCLH4iw4U8Ppgogq(oUCLHyDtJ8fhXc3Lp9XWIIG8DC5kdXrSWD5tFmSu6ogfwHaadzwljjdwqxxN0OAaqueKVJlxzioIfUOcbsuu3XOWkmkmKzTKKm4YN(yyQsAsbY3XLRmeRBAKV4iw4U8PpgwcW6ogfwHaadzwljjdwqxxN0OkPfdiFhxUYqSUPr(IJyH7YN(yyrrb1DmkScbasWXxumFLrPPLamiFhxUYqCelCx(0hdlLUJrHviaWqM1ssYGf011jnQgaefb574YvgIJyHlQqGaciGacirr5eJLqpKjO3Lp9XWXaY3XLRmehXc3Lp9XWajkkOUJrHviaqco(II5RmknTebdji2CtHuISJBsaw3XOWkmkKGJVOy(kJstlbyGfeKVJlxzioIfUOcff1DmkScJcdzwljjdU8PpgwkPbKeGb574YvgIJyH7YN(yyPaq6II6ogfwHrHHmRLKKbx(0hdtvstkq(oUCLH4iw4U8PpggiGeffu3XOWkmkKGJVOy(kJstlbyb1DmkScJcj44BiZAjjzII6ogfwHrHHmRLKKbx(0hdlkQ7yuyfgfgYSwssgSGUUoPjfG6ogfwHaadzwljjdwqxxN0aciefrrqa]] )

    
end