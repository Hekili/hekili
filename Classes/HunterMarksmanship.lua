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


    spec:RegisterPack( "Marksmanship", 20210828, [[davVscqicPhrePUecvPnrK(eczuaQtbiRcHQWRaqZcOYTaQQDb6xiuggHOJjKwMq1ZqOY0qOQUgruBdOk(grKmoHs4CcLO1ba9oGQuP5juCpaAFeH)jusYbjIilKq4HcLAIerOUOqjvBuOKuFeOkLrkusWjfkPSsKuVuOKqZeaCtGQu1obk9teQIgQqjrlLiI6PQWubk(kreYyrsSxi(RknyvDyQwmr9ybtwIlJAZi1NruJgbNwPvduLkEnsmBjDBv0UP8BrdNqDCIiy5kEoutN01H02bY3rKXJK05fI1duLmFc2VuJefbmihfxzeWgxKXJkYyr8ybuKXY4eFIFCKdnIyg5qShO4KzKdZpzKdW79Hc(0nmHvmYHypsn9ccyqoWj6eyKdjD)euvmgajgXiVkbuzyipjgEprRUUPfgNwjgEpded5qgDRASMHiJCuCLraBCrgpQiJfXJfqrglJt8j(rroCuLqoihh7zSroiSLcBiYihfghqoaV3hk4t3WewX9hRaQP80uljHsgfR9hpwaU(JlY4rBQBQJnb3iZyaSPg87hSmj6e1k9ljZ4ScI7FX9BP2V3)jhi42g6xjW97LsA9hCJyK2AT)t3CYmSPg87xsMXrSax63lL06x8S5SAK(jTkH(p2Zy3VKuSsaa2ud(9daS2FSIrM1nC)fghXc9Re4D6p2sIX9JZtw3tgdroQlwXiGb5qNnqbtivmcyqaBueWGCWMlx5cIiqocZQ8SoYH6v2uiwzVe5sNbumKnxUYL(L2)Ax66sMG2V0(LrPPHyL9sKlDgqXWHp91W9ht)sg5Wd6MgYbwzVe5IjKkIIa24iGb5GnxUYferGCeMv5zDKJb1y6CiZqXjAGWnPVJdELZLECYNSPyiBUCLl9lTFzuAAiD1JWd(E6dfiQyKdpOBAihu2A9IjKkIIawIdbmihS5YvUGicKJWSkpRJCmOgtNdzgkordeUj9DCWRCU0Jt(KnfdzZLRCb5Wd6MgYbD1JWLlMqQikcyj(iGb5GnxUYferGCeMv5zDKdG7pKGyZnfsjYSU1V0(dzwljjdomonxxJ81Njjbh(0xd3Fm9tou6xqOFr7pKGyZnfsjYSU1V0(fT)qcIn3uOTKjOxAN7xqO)qcIn3uOTKjOxAN7xA)a3FiZAjjzqsBTCXI3zvmC4tFnC)X0p5qPFbH(dzwljjdsARLlw8oRIHdF6RH7xI(jor2pq9li0V6dzwH6EYxnVLL7pM(JkY(fe6pKzTKKm4W40CDnYxFMKeC4tFnC)s0Fur2V0(9GUG4lB85Y4(LOFIRFG6xA)a3VO9p(wUmi2uOxkyit1fR4(fe6F8TCzqSPqVuWWHp91W9lr)XY(fe6x0(dji2CtHuImRB9deYHh0nnKJsIkx5R6IrueWkzeWGCWMlx5cIiqocZQ8SoYXGAmDoKziorR05qMV8PmpyiBUCLl9lTF1NRoUy4WN(A4(JPFYHs)s7pKzTKKmiD1hgo8PVgU)y6NCOGC4bDtd5q95QJlgrral4bbmihS5YvUGicKdpOBAih0vFyKJWSkpRJCO(C1Xfdrf3V0(huJPZHmdXjALohY8LpL5bdzZLRCb5OUgFdfKJ4sgrraRKcbmihEq30qoyQkUM4feFXesf5GnxUYferGOiGnwGagKd2C5kxqebYrywLN1roeT)X3YLbXMc9sbdzQUyf3VGq)JVLldInf6Lcgo8PVgUFj6pQi7xqOFpOli(YgFUmUFjaS)X3YLbXMc9sbddjQP9t8O)4ihEq30qoiT1YflENvXikcyJLiGb5GnxUYferGCeMv5zDKJqM1ssYGdJtZ11iF9zssWHp91W9ht)KdL(L2pW9lA)QxztHmvfxt8cIVycPczZLRCPFbH(LrPPHY1mlvuScrf3pq9li0VO9hsqS5McPezw36xqO)qM1ssYGdJtZ11iF9zssWHp91W9lr)rfz)cc9lNyC)s7NEjtqVdF6RH7pM(LmYHh0nnKds(wxJ81NjjHOiGnQiradYbBUCLliIa5imRYZ6iha3FiZAjjzqqzTYrGdF6RH7pM(jhk9li0VO9RELnfckRvocKnxUYL(fe6x9HmRqDp5RM3YY9ht)rJ3pq9lTFG7x0(hFlxgeBk0lfmKP6IvC)cc9p(wUmi2uOxky4WN(A4(LO)yz)cc97bDbXx24ZLX9lbG9p(wUmi2uOxkyyirnTFIh9hVFGqo8GUPHCmmonxxJ81NjjHOiGnAueWGCWMlx5cIiqocZQ8SoYHmknnCyCAUUg5RptscIkUFbH(dzwljjdomonxxJ81Njjbh(0xd3Ve9hvK9li0VO9hsqS5McPezw3qo8GUPHCakRvocIIa2OXradYHh0nnKdzFgNmJCWMlx5cIiqueWgL4qadYbBUCLliIa5imRYZ6ihYO00WHXP56AKV(mjjiQ4(fe6pKzTKKm4W40CDnYxFMKeC4tFnC)s0Fur2VGq)I2FibXMBkKsKzDRFbH(LtmUFP9tVKjO3Hp91W9ht)XfjYHh0nnKdDqzmHurueWgL4JagKd2C5kxqebYrywLN1roguJPZHmdXOd51iFXesfdzZLRCPFP9dC)HmRLKKbhgNMRRr(6ZKKGdF6RH7xI(JkY(fe6x0(dji2CtHuImRB9li0VO9RELnfwsu5kFvxmKnxUYL(bQFP9lJstd1zduUycPIHdF6RH7xca7NPkhqv(Q7jJC4bDtd5yCXB5sVdJOiGnQKradYbBUCLliIa5Wd6MgYHVNC5IjKkYrywLN1roKrPPH6SbkxmHuXWHp91W9lbG9ZuLdOkF19K7xA)a3Vmknnu8WHfZxmHuXWssY6xqOFA0A9oCGGpK5RUNC)X0FWX6v3tUFa2p5qPFbH(LrPPH6GYycPcrf3pqihHiHkFvFiZkgbSrrueWgf8GagKd2C5kxqebYrywLN1roOZakUFa2FWX6DyYS1Fm9tNbum80PkYHh0nnKJc7kHBGGtz8tefbSrLuiGb5GnxUYferGCeMv5zDKdG7pKzTKKm4W40CDnYxFMKeC4tFnC)s0Fur2V0(huJPZHmdXOd51iFXesfdzZLRCPFbH(fT)qcIn3uiLiZ6w)cc9lA)dQX05qMHy0H8AKVycPIHS5YvU0VGq)I2V6v2uyjrLR8vDXq2C5kx6hO(L2VmknnuNnq5IjKkgo8PVgUFjaSFMQCav5RUNmYHh0nnKJXfVLl9omIIa2OXceWGCWMlx5cIiqocZQ8SoYHmknnuNnq5IjKkgwssw)cc9lJstdfpCyX8ftivmevC)s7NodO4(LO)qI1(by)Eq30G(EYLlMqQWqI1(L2pW9lA)QxztHbc7PZJFXesfYMlx5s)cc97bDbXx24ZLX9lr)ex)aHC4bDtd54eTQlMqQikcyJglradYbBUCLliIa5imRYZ6ihYO00qXdhwmFXesfdrf3V0(PZakUFj6pKyTFa2Vh0nnOVNC5IjKkmKyTFP97bDbXx24ZLX9ht)eFKdpOBAihbc7PZJFXesfrraBCrIagKd2C5kxqebYrywLN1roKrPPHf2lxocdljjd5Wd6MgYbLTwVycPIOiGnEueWGC4bDtd5WVNOtHNBsFdtscJCWMlx5cIiqueWgpocyqo8GUPHCqx9iC5IjKkYbBUCLliIarraBCIdbmihS5YvUGicKdpOBAihyEeZMEX6AKrocZQ8SoYXW0dJj4Yvg5ieju5R6dzwXiGnkIIa24eFeWGCWMlx5cIiqocZQ8SoYbDgqX9lr)HeR9dW(9GUPb99KlxmHuHHeR9lTFG7pKzTKKm4W40CDnYxFMKeC4tFnC)s0VK7xqOFr7pKGyZnfsjYSU1pqihEq30qoorR6IjKkIIa24sgbmihS5YvUGicKJWSkpRJCmOgtNdzgAmgVgzs(ebF1XflEnYxxSyFCffdzZLRCb5Wd6MgYH6ZvhxmIIa24GheWGCWMlx5cIiqocZQ8SoYXGAmDoKzOXy8AKj5te8vhxS41iFDXI9XvumKnxUYfKdpOBAih0dZGxRr(QJlgrraBCjfcyqoyZLRCbreihHzvEwh5qgLMgQdkJjKkSKKmKdpOBAihYo5BsF1zduWikcyJhlqadYbBUCLliIa5imRYZ6ih4eTkVwbkgfROv(YdQyDtdYMlx5s)s7xgLMgQdkJjKkSKKmKdpOBAih0vgtimoTIOiGnESebmihEq30qoWk7LixmHuroyZLRCbreikIICuyAhTQiGbbSrradYHh0nnKJqIAkpxmHuroyZLRCbreikcyJJagKd2C5kxqebYHh0nnKJqIAkpxmHurocZQ8SoYXGAmDoKziMftaf8cFfpzO6NUUPbzZLRCPFbH(XjAvETc02io(QzwXxX5ItdYMlx5s)cc9dC)H0kORchgepyVEt6lDokQXq2C5kx6xA)I2)GAmDoKziMftaf8cFfpzO6NUUPbzZLRCPFGqoQRX3qb5G4ejIIawIdbmihS5YvUGicKdpOBAih64MKa6wxWR1iFXesf5OW4WSI1nnKdWBz)ob2l97wPFWmUjjGU1f8I7hSXkJD)SXNlJbx)K4(lPrK2Fj7xjS4(PZPFXvpcp4(L5GJI5(xLOs)YC)AM9Jf7NNr63Ts)K4(dUrK2)WEzRr6hmJBsc9JfZHLEd9lJstJHihHzvEwh5q0(vFiZkCXxXvpcpikcyj(iGb5GnxUYferGCeMv5zDKJqcIn3uiLiZ6w)s7pKzTKKmOoOmMqQWHp91W9lT)qM1ssYGdJtZ11iF9zssWHp91W9li0VO9hsqS5McPezw36xA)HmRLKKb1bLXesfo8PVgg5Wd6MgYrWR1Rh0nTBDXkYrDX618tg5qN1OWkgrraRKradYbBUCLliIa5Wd6MgYrWR1Rh0nTBDXkYrDX618tg5iuWikcybpiGb5GnxUYferGCeMv5zDKdpOli(YgFUmU)y6N4qo8GUPHCe8A96bDt7wxSICuxSEn)KroWkIIawjfcyqoyZLRCbreihHzvEwh5Wd6cIVSXNlJ7xI(JJC4bDtd5i4161d6M2TUyf5OUy9A(jJCOZgOGjKkgrruKdXdhYtzxradcyJIagKdpOBAihYPQvUCPREeUqAnYxnP6AihS5YvUGicefbSXradYHh0nnKd6kJjegNwroyZLRCbreikcyjoeWGCWMlx5cIiqocZQ8SoYXGAmDoKziorR05qMV8PmpyiBUCLlihEq30qouFU64IrueWs8radYbBUCLliIa5ifJCGzf5Wd6MgYbiFwxUYihG8kkJCuzYSv8jcKDYvw9AA4RoO8LodOyiBUCLl9lTFmR6AKXq2jxz1RPDXKCXq2C5kxqokmomRyDtd5i2eCJm3VM9hTFn7hVNOvx5(J1btSAIDCeRUFYSpysU4(bZGYycP2V4HdowHihG85A(jJCWk9v8WbhRikcyLmcyqoyZLRCbreihIho4y9Q7jJCevKihEq30qokjQCLVQlg5imRYZ6ihEqxq8Ln(CzC)s0F0(fe6x0(dji2CtHuImRB9lTFr7x9kBkeuwRCeiBUCLl9li0piFwxUYqwPVIho4yfrral4bbmihS5YvUGicKJWSkpRJCaYN1LRmKv6R4Hdowro8GUPHCOdkJjKkIIawjfcyqoyZLRCbreihHzvEwh5Wd6cIVSXNlJ7pM(jU(L2pW9lA)HeeBUPqkrM1T(L2VO9RELnfckRvocKnxUYL(fe63d6cIVSXNlJ7pM(J3pq9lTFr7hKpRlxziR0xXdhCSIC4bDtd5W3tUCXesfrraBSabmihS5YvUGicKJWSkpRJC4bDbXx24ZLX9lr)X7xqOFG7pKGyZnfsjYSU1VGq)QxztHGYALJazZLRCPFG6xA)Eqxq8Ln(CzC)a2F8(fe6hKpRlxziR0xXdhCSIC4bDtd5aRSxICXesfrruKJqbJageWgfbmihS5YvUGicKJWSkpRJCaC)YO00qDqzmHuHOI7xA)YO00WHXP56AKV(mjjiQ4(L2FibXMBkKsKzDRFG6xqOFG7xgLMgQdkJjKkevC)s7xgLMgsARLlw8oRIHOI7xA)HeeBUPqBjtqV0o3pq9li0pW9hsqS5McbXMsiY0VGq)HeeBUPqJdtwZP0pq9lTFzuAAOoOmMqQquX9li0VCIX9lTF6Lmb9o8PVgU)y6pkX1VGq)a3FibXMBkKsKzDRFP9lJstdhgNMRRr(6ZKKGOI7xA)0lzc6D4tFnC)X0VKI46hiKdpOBAihY8G5HYAKrueWghbmihS5YvUGicKJWSkpRJCiJstd1bLXesfIkUFbH(dzwljjdQdkJjKkC4tFnC)s0pXjY(fe6xoX4(L2p9sMGEh(0xd3Fm9hf8GC4bDtd5qUMz5sJorqueWsCiGb5GnxUYferGCeMv5zDKdzuAAOoOmMqQquX9li0FiZAjjzqDqzmHuHdF6RH7xI(jor2VGq)Yjg3V0(PxYe07WN(A4(JP)OGhKdpOBAihUfySoE9g8AfrralXhbmihS5YvUGicKJWSkpRJCiJstd1bLXesfIkUFbH(dzwljjdQdkJjKkC4tFnC)s0pXjY(fe6xoX4(L2p9sMGEh(0xd3Fm9hlro8GUPHCqVdlxZSGOiGvYiGb5GnxUYferGCeMv5zDKdzuAAOoOmMqQWssYqo8GUPHCuxYeu8f8oOfYNSPikcybpiGb5GnxUYferGCeMv5zDKdzuAAOoOmMqQquX9lTFG7xgLMgkxZSurXkevC)cc9R(qMvib2RkbO4G2Fm9hxK9du)cc9lNyC)s7NEjtqVdF6RH7pM(JdE6xqOFG7pKGyZnfsjYSU1V0(LrPPHdJtZ11iF9zssquX9lTF6Lmb9o8PVgU)y6xsfVFGqo8GUPHCio1nnefrroWkcyqaBueWGCWMlx5cIiqocZQ8SoYH6v2uiwzVe5sNbumKnxUYL(L2pW9lEyqxYHcmkeRSxICXesTFP9lJstdXk7Lix6mGIHdF6RH7pM(LC)cc9lJstdXk7Lix6mGIHLKK1pq9lTFG7xgLMgomonxxJ81NjjbljjRFbH(fT)qcIn3uiLiZ6w)aHC4bDtd5aRSxICXesfrraBCeWGC4bDtd5GYwRxmHuroyZLRCbreikcyjoeWGCWMlx5cIiqocZQ8SoYbW9hsqS5McPezw36xA)a3FiZAjjzWHXP56AKV(mjj4WN(A4(JPFYHs)a1VGq)I2FibXMBkKsKzDRFP9lA)HeeBUPqBjtqV0o3VGq)HeeBUPqBjtqV0o3V0(bU)qM1ssYGK2A5IfVZQy4WN(A4(JPFYHs)cc9hYSwssgK0wlxS4Dwfdh(0xd3Ve9tCISFG6xqOF6Lmb9o8PVgU)y6pQK7hO(L2pW9lA)JVLldInf6LcgYuDXkUFbH(hFlxgeBk0lfmevC)s7h4(hFlxgeBk0lfmCT(JP)OISFP9p(wUmi2uOxky4WN(A4(JPFIRFbH(hFlxgeBk0lfmCT(LOFpOBA3qM1ssY6xqOFpOli(YgFUmUFj6pA)a1VGq)I2)4B5YGytHEPGHOI7xA)a3)4B5YGytHEPGHHe10(bS)O9li0)4B5YGytHEPGHR1Ve97bDt7gYSwssw)a1pqihEq30qokjQCLVQlgrralXhbmihS5YvUGicKJWSkpRJCO(C1Xfdrf3V0(huJPZHmdXjALohY8LpL5bdzZLRCb5Wd6MgYbD1hgrraRKradYbBUCLliIa5imRYZ6ihdQX05qMH4eTsNdz(YNY8GHS5YvU0V0(vFU64IHdF6RH7pM(jhk9lT)qM1ssYG0vFy4WN(A4(JPFYHcYHh0nnKd1NRoUyefbSGheWGC4bDtd5GPQ4AIxq8ftivKd2C5kxqebIIawjfcyqoyZLRCbreihHzvEwh5q0(hFlxgeBk0lfmKP6IvC)cc9lA)JVLldInf6LcgIkUFP9p(wUmi2uOxkyybDCDtRFa2)4B5YGytHEPGHR1Fm9hxK9li0)4B5YGytHEPGHOI7xA)JVLldInf6Lcgo8PVgUFj6pASSFbH(9GUG4lB85Y4(LO)OihEq30qoiT1YflENvXikcyJfiGb5Wd6MgYbD1JWLlMqQihS5YvUGicefbSXseWGCWMlx5cIiqocZQ8SoYbDgqX9dW(dowVdtMT(JPF6mGIHNovro8GUPHCuyxjCdeCkJFIOiGnQiradYHh0nnKd)EIofEUj9nmjjmYbBUCLliIarraB0OiGb5GnxUYferGCeMv5zDKJqM1ssYGdJtZ11iF9zssWHp91W9ht)KdL(L2pW9lA)QxztHmvfxt8cIVycPczZLRCPFbH(LrPPHY1mlvuScrf3pq9li0VO9hsqS5McPezw36xqO)qM1ssYGdJtZ11iF9zssWHp91W9li0VCIX9lTF6Lmb9o8PVgU)y6xYihEq30qoi5BDnYxFMKeIIa2OXradYbBUCLliIa5imRYZ6iha3VmknnSKOYv(QUyiQ4(fe6pKzTKKmyjrLR8vDXWHp91W9lr)rfz)cc9lA)QxztHLevUYx1fdzZLRCPFbH(PxYe07WN(A4(JP)OX7hO(L2pW9lA)JVLldInf6LcgYuDXkUFbH(fT)X3YLbXMc9sbdrf3V0(bU)X3YLbXMc9sbdlOJRBA9dW(hFlxgeBk0lfmCT(JP)OISFbH(hFlxgeBk0lfmmKOM2pG9hTFG6xqO)X3YLbXMc9sbdrf3V0(hFlxgeBk0lfmC4tFnC)s0FSSFbH(9GUG4lB85Y4(LO)O9deYHh0nnKJHXP56AKV(mjjefbSrjoeWGCWMlx5cIiqocZQ8SoYHmknnCyCAUUg5RptscIkUFbH(dzwljjdomonxxJ81Njjbh(0xd3Ve9hvK9li0VO9hsqS5McPezw36xA)a3Vmknnu8WHfZxmHuXWssY6xqOFr7x9kBkmqypDE8lMqQq2C5kx6xqOFpOli(YgFUmU)y6pE)aHC4bDtd5auwRCeefbSrj(iGb5GnxUYferGCeMv5zDKJqcIn3uiLiZ6w)s7NodO4(by)bhR3HjZw)X0pDgqXWtNQ9lTFG7h4(dzwljjdomonxxJ81Njjbh(0xd3Fm9tou6N4r)ex)s7h4(fTFCIwLxRazAAu8cIVUTN(1dbUYJR5azZLRCPFbH(fTF1RSPWsIkx5R6IHS5YvU0pq9du)cc9RELnfwsu5kFvxmKnxUYL(L2FiZAjjzWsIkx5R6IHdF6RH7pM(jU(bc5Wd6MgYbwzVe5IjKkIIa2OsgbmihS5YvUGicKJWSkpRJCiJstdfpCyX8ftivmSKKS(L2pW9hsqS5McbXMsiY0VGq)HeeBUPqJdtwZP0VGq)QxztHbVwxJ8vjWxmHuXq2C5kx6hO(fe6xgLMgomonxxJ81Njjbrf3VGq)HmRLKKbhgNMRRr(6ZKKGdF6RH7xI(JkY(fe6xgLMgsARLlw8oRIHOI7xqOFzuAAiOSw5iquX9lTFpOli(YgFUmUFj6pA)cc9lNyC)s7NEjtqVdF6RH7pM(JlzKdpOBAih6GYycPIOiGnk4bbmihS5YvUGicKJWSkpRJCmOgtNdzgIrhYRr(IjKkgYMlx5s)s7x9kBkeRd7N11yiBUCLl9lTFG7pKzTKKm4W40CDnYxFMKeC4tFnC)s0Fur2VGq)I2FibXMBkKsKzDRFbH(fTF1RSPWsIkx5R6IHS5YvU0VGq)4eTkVwbY00O4feFDBp9RhcCLhxZbYMlx5s)aHC4bDtd5yCXB5sVdJOiGnQKcbmihS5YvUGicKdpOBAih(EYLlMqQihHzvEwh5qgLMgkE4WI5lMqQyyjjz9li0pW9lJstd1bLXesfIkUFbH(PrR17Wbc(qMV6EY9ht)KdL(by)bhRxDp5(bQFP9dC)I2V6v2uyGWE684xmHuHS5YvU0VGq)Eqxq8Ln(CzC)X0F8(bQFbH(LrPPH6SbkxmHuXWHp91W9lr)mv5aQYxDp5(L2Vh0feFzJpxg3Ve9hf5ieju5R6dzwXiGnkIIa2OXceWGCWMlx5cIiqocZQ8SoYbW9hYSwssgCyCAUUg5Rptsco8PVgUFj6pQi7xqOFr7pKGyZnfsjYSU1VGq)I2V6v2uyjrLR8vDXq2C5kx6xqOFCIwLxRazAAu8cIVUTN(1dbUYJR5azZLRCPFG6xA)0zaf3pa7p4y9omz26pM(PZakgE6uTFP9dC)YO00WsIkx5R6IHLKK1V0(LrPPHStUYQxtdF1bLV0zafdljjRFbH(vVYMcX6W(zDngYMlx5s)aHC4bDtd5yCXB5sVdJOiGnASebmihS5YvUGicKJWSkpRJCiJstdfpCyX8ftivmevC)cc9tNbuC)s0FiXA)aSFpOBAqFp5YftivyiXkYHh0nnKJaH905XVycPIOiGnUiradYbBUCLliIa5imRYZ6ihYO00qXdhwmFXesfdrf3VGq)0zaf3Ve9hsS2pa73d6Mg03tUCXesfgsSIC4bDtd5WNGB8ftivefbSXJIagKd2C5kxqebYHh0nnKdmpIztVyDnYihHzvEwh5yy6HXeC5k3V0(vFiZku3t(Q5TSC)s0FbDCDtd5ieju5R6dzwXiGnkIIa24XradYbBUCLliIa5imRYZ6ihEqxq8Ln(CzC)s0FuKdpOBAihY(mozgrraBCIdbmihS5YvUGicKJWSkpRJCaC)HmRLKKbhgNMRRr(6ZKKGdF6RH7xI(JkY(L2)GAmDoKzigDiVg5lMqQyiBUCLl9li0VO9hsqS5McPezw36xqOFr7x9kBkSKOYv(QUyiBUCLl9li0porRYRvGmnnkEbXx32t)6Hax5X1CGS5YvU0pq9lTF6mGI7hG9hCSEhMmB9ht)0zafdpDQ2V0(bUFzuAAyjrLR8vDXWssY6xqOF1RSPqSoSFwxJHS5YvU0pqihEq30qogx8wU07WikcyJt8radYbBUCLliIa5imRYZ6ihYO00qDqzmHuHLKKHC4bDtd5q2jFt6RoBGcgrraBCjJagKd2C5kxqebYrywLN1roWjAvETcumkwrR8LhuX6MgKnxUYL(L2VmknnuhugtivyjjzihEq30qoORmMqyCAfrraBCWdcyqo8GUPHCGv2lrUycPICWMlx5cIiquef5qN1OWkgbmiGnkcyqoyZLRCbreihPyKdmRihEq30qoa5Z6Yvg5aKxrzKdzuAA4W40CDnYxFMKeevC)cc9lJstd1bLXesfIkg5aKpxZpzKdCelCrfJOiGnocyqoyZLRCbreihPyKdmRihEq30qoa5Z6Yvg5aKxrzKJqcIn3uiLiZ6w)s7xgLMgomonxxJ81Njjbrf3V0(LrPPH6GYycPcrf3VGq)I2FibXMBkKsKzDRFP9lJstd1bLXesfIkg5aKpxZpzKdSoPr(IJyHlQyefbSehcyqoyZLRCbreihPyKdmRlnYHh0nnKdq(SUCLroa5Z18tg5aRtAKV4iw4o8PVgg5imRYZ6ihYO00qDqzmHuHLKK1V0(dji2CtHuImRBihG8kkF5kMroczwljjdQdkJjKkC4tFnmYbiVIYihHmRLKKbhgNMRRr(6ZKKGdF6RH7pMyv9hYSwssguhugtiv4WN(AyefbSeFeWGCWMlx5cIiqosXihywxAKdpOBAihG8zD5kJCaYNR5NmYbwN0iFXrSWD4tFnmYrywLN1roKrPPH6GYycPcrf3V0(dji2CtHuImRBihG8kkF5kMroczwljjdQdkJjKkC4tFnmYbiVIYihHmRLKKbhgNMRRr(6ZKKGdF6RHrueWkzeWGCWMlx5cIiqosXihywxAKdpOBAihG8zD5kJCaYNR5NmYboIfUdF6RHrocZQ8SoYribXMBkKsKzDd5aKxr5lxXmYriZAjjzqDqzmHuHdF6RHroa5vug5iKzTKKm4W40CDnYxFMKeC4tFnC)seRQ)qM1ssYG6GYycPch(0xdJOiGf8GagKd2C5kxqebYHh0nnKdDwJcRrrocZQ8SoYbW9RZAuyfQrHeC8ffZxzuA6(fe6pKGyZnfsjYSU1V0(1znkSc1Oqco(gYSwssw)a1V0(bUFq(SUCLHyDsJ8fhXcxuX9lTFG7x0(dji2CtHuImRB9lTFr7xN1OWkuJdj44lkMVYO009li0FibXMBkKsKzDRFP9lA)6SgfwHACibhFdzwljjRFbH(1znkSc14WqM1ssYGdF6RH7xqOFDwJcRqnkKGJVOy(kJst3V0(bUFr7xN1OWkuJdj44lkMVYO009li0VoRrHvOgfgYSwssgSGoUUP1Vea2VoRrHvOghgYSwssgSGoUUP1pq9li0VoRrHvOgfsWX3qM1ssY6xA)I2VoRrHvOghsWXxumFLrPP7xA)6SgfwHAuyiZAjjzWc646Mw)say)6SgfwHACyiZAjjzWc646Mw)a1VGq)I2piFwxUYqSoPr(IJyHlQ4(L2pW9lA)6SgfwHACibhFrX8vgLMUFP9dC)6SgfwHAuyiZAjjzWc646Mw)GF)sU)y6hKpRlxzioIfUdF6RH7xqOFq(SUCLH4iw4o8PVgUFj6xN1OWkuJcdzwljjdwqhx306Ny9hVFG6xqOFDwJcRqnoKGJVOy(kJst3V0(bUFDwJcRqnkKGJVOy(kJst3V0(1znkSc1OWqM1ssYGf0X1nT(LaW(1znkSc14WqM1ssYGf0X1nT(L2pW9RZAuyfQrHHmRLKKblOJRBA9d(9l5(JPFq(SUCLH4iw4o8PVgUFbH(b5Z6YvgIJyH7WN(A4(LOFDwJcRqnkmKzTKKmybDCDtRFI1F8(bQFbH(bUFr7xN1OWkuJcj44lkMVYO009li0VoRrHvOghgYSwssgSGoUUP1Vea2VoRrHvOgfgYSwssgSGoUUP1pq9lTFG7xN1OWkuJddzwljjdoSxI0V0(1znkSc14WqM1ssYGf0X1nT(b)(LC)s0piFwxUYqCelCh(0xd3V0(b5Z6YvgIJyH7WN(A4(JPFDwJcRqnomKzTKKmybDCDtRFI1F8(fe6x0(1znkSc14WqM1ssYGd7Li9lTFG7xN1OWkuJddzwljjdo8PVgUFWVFj3Fm9dYN1LRmeRtAKV4iw4o8PVgUFP9dYN1LRmeRtAKV4iw4o8PVgUFj6pUi7xA)a3VoRrHvOgfgYSwssgSGoUUP1p43VK7pM(b5Z6YvgIJyH7WN(A4(fe6xN1OWkuJddzwljjdo8PVgUFWVFj3Fm9dYN1LRmehXc3Hp91W9lTFDwJcRqnomKzTKKmybDCDtRFWV)OISFa2piFwxUYqCelCh(0xd3Fm9dYN1LRmeRtAKV4iw4o8PVgUFbH(b5Z6YvgIJyH7WN(A4(LOFDwJcRqnkmKzTKKmybDCDtRFI1F8(fe6hKpRlxzioIfUOI7hO(fe6xN1OWkuJddzwljjdo8PVgUFWVFj3Ve9dYN1LRmeRtAKV4iw4o8PVgUFP9dC)6SgfwHAuyiZAjjzWc646Mw)GF)sU)y6hKpRlxziwN0iFXrSWD4tFnC)cc9lA)6SgfwHAuibhFrX8vgLMUFP9dC)G8zD5kdXrSWD4tFnC)s0VoRrHvOgfgYSwssgSGoUUP1pX6pE)cc9dYN1LRmehXcxuX9du)a1pq9du)a1pq9li0VCIX9lTF6Lmb9o8PVgU)y6hKpRlxzioIfUdF6RH7hO(fe6x0(1znkSc1Oqco(II5RmknD)s7x0(dji2CtHuImRB9lTFG7xN1OWkuJdj44lkMVYO009lTFG7h4(fTFq(SUCLH4iw4IkUFbH(1znkSc14WqM1ssYGdF6RH7xI(LC)a1V0(bUFq(SUCLH4iw4o8PVgUFj6pUi7xqOFDwJcRqnomKzTKKm4WN(A4(b)(LC)s0piFwxUYqCelCh(0xd3pq9du)cc9lA)6SgfwHACibhFrX8vgLMUFP9dC)I2VoRrHvOghsWX3qM1ssY6xqOFDwJcRqnomKzTKKm4WN(A4(fe6xN1OWkuJddzwljjdwqhx306xca7xN1OWkuJcdzwljjdwqhx306hO(bc5axtfJCOZAuynkIIawjfcyqoyZLRCbreihEq30qo0znkSgh5imRYZ6iha3VoRrHvOghsWXxumFLrPP7xqO)qcIn3uiLiZ6w)s7xN1OWkuJdj44BiZAjjz9du)s7h4(b5Z6YvgI1jnYxCelCrf3V0(bUFr7pKGyZnfsjYSU1V0(fTFDwJcRqnkKGJVOy(kJst3VGq)HeeBUPqkrM1T(L2VO9RZAuyfQrHeC8nKzTKKS(fe6xN1OWkuJcdzwljjdo8PVgUFbH(1znkSc14qco(II5RmknD)s7h4(fTFDwJcRqnkKGJVOy(kJst3VGq)6SgfwHACyiZAjjzWc646Mw)say)6SgfwHAuyiZAjjzWc646Mw)a1VGq)6SgfwHACibhFdzwljjRFP9lA)6SgfwHAuibhFrX8vgLMUFP9RZAuyfQXHHmRLKKblOJRBA9lbG9RZAuyfQrHHmRLKKblOJRBA9du)cc9lA)G8zD5kdX6Kg5loIfUOI7xA)a3VO9RZAuyfQrHeC8ffZxzuA6(L2pW9RZAuyfQXHHmRLKKblOJRBA9d(9l5(JPFq(SUCLH4iw4o8PVgUFbH(b5Z6YvgIJyH7WN(A4(LOFDwJcRqnomKzTKKmybDCDtRFI1F8(bQFbH(1znkSc1Oqco(II5RmknD)s7h4(1znkSc14qco(II5RmknD)s7xN1OWkuJddzwljjdwqhx306xca7xN1OWkuJcdzwljjdwqhx306xA)a3VoRrHvOghgYSwssgSGoUUP1p43VK7pM(b5Z6YvgIJyH7WN(A4(fe6hKpRlxzioIfUdF6RH7xI(1znkSc14WqM1ssYGf0X1nT(jw)X7hO(fe6h4(fTFDwJcRqnoKGJVOy(kJst3VGq)6SgfwHAuyiZAjjzWc646Mw)say)6SgfwHACyiZAjjzWc646Mw)a1V0(bUFDwJcRqnkmKzTKKm4WEjs)s7xN1OWkuJcdzwljjdwqhx306h87xY9lr)G8zD5kdXrSWD4tFnC)s7hKpRlxzioIfUdF6RH7pM(1znkSc1OWqM1ssYGf0X1nT(jw)X7xqOFr7xN1OWkuJcdzwljjdoSxI0V0(bUFDwJcRqnkmKzTKKm4WN(A4(b)(LC)X0piFwxUYqSoPr(IJyH7WN(A4(L2piFwxUYqSoPr(IJyH7WN(A4(LO)4ISFP9dC)6SgfwHACyiZAjjzWc646Mw)GF)sU)y6hKpRlxzioIfUdF6RH7xqOFDwJcRqnkmKzTKKm4WN(A4(b)(LC)X0piFwxUYqCelCh(0xd3V0(1znkSc1OWqM1ssYGf0X1nT(b)(JkY(by)G8zD5kdXrSWD4tFnC)X0piFwxUYqSoPr(IJyH7WN(A4(fe6hKpRlxzioIfUdF6RH7xI(1znkSc14WqM1ssYGf0X1nT(jw)X7xqOFq(SUCLH4iw4IkUFG6xqOFDwJcRqnkmKzTKKm4WN(A4(b)(LC)s0piFwxUYqSoPr(IJyH7WN(A4(L2pW9RZAuyfQXHHmRLKKblOJRBA9d(9l5(JPFq(SUCLHyDsJ8fhXc3Hp91W9li0VO9RZAuyfQXHeC8ffZxzuA6(L2pW9dYN1LRmehXc3Hp91W9lr)6SgfwHACyiZAjjzWc646Mw)eR)49li0piFwxUYqCelCrf3pq9du)a1pq9du)a1VGq)Yjg3V0(PxYe07WN(A4(JPFq(SUCLH4iw4o8PVgUFG6xqOFr7xN1OWkuJdj44lkMVYO009lTFr7pKGyZnfsjYSU1V0(bUFDwJcRqnkKGJVOy(kJst3V0(bUFG7x0(b5Z6YvgIJyHlQ4(fe6xN1OWkuJcdzwljjdo8PVgUFj6xY9du)s7h4(b5Z6YvgIJyH7WN(A4(LO)4ISFbH(1znkSc1OWqM1ssYGdF6RH7h87xY9lr)G8zD5kdXrSWD4tFnC)a1pq9li0VO9RZAuyfQrHeC8ffZxzuA6(L2pW9lA)6SgfwHAuibhFdzwljjRFbH(1znkSc1OWqM1ssYGdF6RH7xqOFDwJcRqnkmKzTKKmybDCDtRFjaSFDwJcRqnomKzTKKmybDCDtRFG6hiKdCnvmYHoRrH14ikIIOihG4bVPHa24ImEurglItCihK8XwJmg5qsKKKKmyJ1al4naS)(bdbU)9uCoA)050pr6SbkycPIjQ)HLeq3Hl9JZtUFhvZtx5s)bcUrMXWMAaynU)Oay)Xonq8OCPFIuVYMcPcr9Rz)ePELnfsfiBUCLle1pWrPkqWMAaynU)4ay)Xonq8OCPFIguJPZHmdPcr9Rz)enOgtNdzgsfiBUCLle1pWrPkqWMAaynUFIda7p2PbIhLl9t0GAmDoKziviQFn7NOb1y6CiZqQazZLRCHO(DT)yDINaq)ahLQabBQbG14(Lma2FStdepkx6NOb1y6CiZqQqu)A2prdQX05qMHubYMlx5cr9dCuQceSPgawJ7h8aG9h70aXJYL(jAqnMohYmKke1VM9t0GAmDoKzivGS5YvUqu)U2FSoXtaOFGJsvGGn1aWAC)XsaS)yNgiEuU0prQxztHuHO(1SFIuVYMcPcKnxUYfI6h4OufiytnaSg3FurcG9h70aXJYL(js9kBkKke1VM9tK6v2uivGS5YvUqu)ahLQabBQbG14(Js8bW(JDAG4r5s)ePELnfsfI6xZ(js9kBkKkq2C5kxiQFGJsvGGn1aWAC)rj(ay)Xonq8OCPFIguJPZHmdPcr9Rz)enOgtNdzgsfiBUCLle1pWrPkqWMAaynU)OskaS)yNgiEuU0prQxztHuHO(1SFIuVYMcPcKnxUYfI6h4OufiytnaSg3Fujfa2FStdepkx6NOb1y6CiZqQqu)A2prdQX05qMHubYMlx5cr9dCCQceSPgawJ7pASaa7p2PbIhLl9tK6v2uiviQFn7Ni1RSPqQazZLRCHO(bokvbc2udaRX9hxYay)Xonq8OCPFIguJPZHmdPcr9Rz)enOgtNdzgsfiBUCLle1VR9hRt8ea6h4OufiytnaSg3FCWda2FStdepkx6NOb1y6CiZqQqu)A2prdQX05qMHubYMlx5cr97A)X6epbG(bokvbc2udaRX9hpwaG9h70aXJYL(jcNOv51kqQqu)A2pr4eTkVwbsfiBUCLle1pWrPkqWM6MAjrsssYGnwdSG3aW(7hme4(3tX5O9tNt)evyAhTQe1)WscO7WL(X5j3VJQ5PRCP)ab3iZyytnaSg3FCaS)yNgiEuU0prdQX05qMHuHO(1SFIguJPZHmdPcKnxUYfI6h4OufiytnaSg3FCaS)yNgiEuU0prdQX05qMHuHO(1SFIguJPZHmdPcKnxUYfI6h4OufiytnaSg3FCaS)yNgiEuU0prH0kORcPcr9Rz)efsRGUkKkq2C5kxiQFGJsvGGn1aWAC)XbW(JDAG4r5s)eHt0Q8AfiviQFn7NiCIwLxRaPcKnxUYfI6h4OufiytDtTKijjjzWgRbwWBay)9dgcC)7P4C0(PZPFIepCipLDLO(hwsaDhU0pop5(DunpDLl9hi4gzgdBQbG14(joaS)yNgiEuU0prdQX05qMHuHO(1SFIguJPZHmdPcKnxUYfI631(J1jEca9dCuQceSPgawJ7xYay)Xonq8OCPFIuVYMcPcr9Rz)ePELnfsfiBUCLle1pWrPkqWMAaynUFjfa2FStdepkx6Ni1RSPqQqu)A2prQxztHubYMlx5cr9dCuQceSPgawJ7pwaG9h70aXJYL(js9kBkKke1VM9tK6v2uivGS5YvUqu)ahLQabBQBQLejjjjd2ynWcEda7VFWqG7FpfNJ2pDo9tewjQ)HLeq3Hl9JZtUFhvZtx5s)bcUrMXWMAaynU)Oay)Xonq8OCPFIuVYMcPcr9Rz)ePELnfsfiBUCLle1pWrPkqWMAaynUFIpa2FStdepkx6NOb1y6CiZqQqu)A2prdQX05qMHubYMlx5cr97A)X6epbG(bokvbc2udaRX9lzaS)yNgiEuU0prdQX05qMHuHO(1SFIguJPZHmdPcKnxUYfI6h4OufiytnaSg3F0Oay)Xonq8OCPFIuVYMcPcr9Rz)ePELnfsfiBUCLle1pWrPkqWMAaynU)OXbW(JDAG4r5s)ePELnfsfI6xZ(js9kBkKkq2C5kxiQFGJsvGGn1aWAC)rjoaS)yNgiEuU0prQxztHuHO(1SFIuVYMcPcKnxUYfI6h4OufiytnaSg3FuIpa2FStdepkx6Ni1RSPqQqu)A2prQxztHubYMlx5cr9dCCQceSPgawJ7pkXha7p2PbIhLl9teorRYRvGuHO(1SFIWjAvETcKkq2C5kxiQFGJsvGGn1aWAC)rLma2FStdepkx6Ni1RSPqQqu)A2prQxztHubYMlx5cr9dCuQceSPgawJ7pk4ba7p2PbIhLl9tK6v2uiviQFn7Ni1RSPqQazZLRCHO(boovbc2udaRX9hf8aG9h70aXJYL(jAqnMohYmKke1VM9t0GAmDoKzivGS5YvUqu)ahLQabBQbG14(JcEaW(JDAG4r5s)eHt0Q8AfiviQFn7NiCIwLxRaPcKnxUYfI6h4OufiytnaSg3Fujfa2FStdepkx6Ni1RSPqQqu)A2prQxztHubYMlx5cr9dCuQceSPgawJ7pASaa7p2PbIhLl9tK6v2uiviQFn7Ni1RSPqQazZLRCHO(boovbc2udaRX9hnwaG9h70aXJYL(jcNOv51kqQqu)A2pr4eTkVwbsfiBUCLle1pWrPkqWMAaynU)4eha2FStdepkx6Ni1RSPqQqu)A2prQxztHubYMlx5cr9dCCQceSPgawJ7poXbG9h70aXJYL(jAqnMohYmKke1VM9t0GAmDoKzivGS5YvUqu)ahLQabBQbG14(JtCay)Xonq8OCPFIWjAvETcKke1VM9teorRYRvGubYMlx5cr9dCuQceSPgawJ7pUKbW(JDAG4r5s)eHt0Q8AfiviQFn7NiCIwLxRaPcKnxUYfI6h4OufiytnyiW9tN1AsAnY97OJJ7NepC)OyU0)A9Re4(9GUP1FDXA)YOA)K4H73sTF6e1k9Vw)kbUFVusR)IRUSJzaSPUFWVF2jxz1RPHV6GYx6mGIBQBQLejjjjd2ynWcEda7VFWqG7FpfNJ2pDo9tKoRrHvmr9pSKa6oCPFCEY97OAE6kx6pqWnYmg2udaRX9dEaW(JDAG4r5s)h7zS7hhXuNQ9t82VM9daOE)Lf0I306pfZJR50pWedO(bwYufiytnaSg3p4ba7p2PbIhLl9tKoRrHvyuiviQFn7NiDwJcRqnkKke1pWXJsvGGn1aWAC)GhaS)yNgiEuU0pr6SgfwHXHuHO(1SFI0znkSc14qQqu)ahh8qvGGn1aWAC)skaS)yNgiEuU0)XEg7(Xrm1PA)eV9Rz)aaQ3FzbT4nT(tX84Ao9dmXaQFGLmvbc2udaRX9lPaW(JDAG4r5s)ePZAuyfgfsfI6xZ(jsN1OWkuJcPcr9dCCWdvbc2udaRX9lPaW(JDAG4r5s)ePZAuyfghsfI6xZ(jsN1OWkuJdPcr9dC8OufiytDtDS2P4CuU0p4PFpOBA9xxSIHn1ihyXCabSXLmXh5q8K0BLroK0s6(bV3hk4t3WewX9hRaQP80ulPL09ljHsgfR9hpwaU(JlY4rBQBQL0s6(Jnb3iZyaSPwslP7h87hSmj6e1k9ljZ4ScI7FX9BP2V3)jhi42g6xjW97LsA9hCJyK2AT)t3CYmSPwslP7h87xsMXrSax63lL06x8S5SAK(jTkH(p2Zy3VKuSsaa2ulPL09d(9daS2FSIrM1nC)fghXc9Re4D6p2sIX9JZtw3tgdBQBQ9GUPHHIhoKNYUcqajMCQALlx6QhHlKwJ8vtQUwtTh0nnmu8WH8u2vaciXORmMqyCATP2d6MggkE4qEk7kabKyQpxDCXGBPbCqnMohYmeNOv6CiZx(uMhCtTKU)ytWnYC)A2F0(1SF8EIwDL7pwhmXQj2XrS6(jZ(Gj5I7hmdkJjKA)Iho4yf2u7bDtddfpCipLDfGasmq(SUCLbN5NmGSsFfpCWXk4a5vugWktMTIprGStUYQxtdF1bLV0zafdzZLRCrkMvDnYyi7KRS610UysUyiBUCLln1Eq30WqXdhYtzxbiGeRKOYv(QUyWjE4GJ1RUNmGrfj4wAa9GUG4lB85YyjIkiiAibXMBkKsKzDtQOQxztHGYALJiiaYN1LRmKv6R4HdowBQ9GUPHHIhoKNYUcqajMoOmMqQGBPbeKpRlxziR0xXdhCS2u7bDtddfpCipLDfGasmFp5YftivWT0a6bDbXx24ZLXXqCsbw0qcIn3uiLiZ6MurvVYMcbL1khrqWd6cIVSXNlJJjoqsffKpRlxziR0xXdhCS2u7bDtddfpCipLDfGasmSYEjYftivWT0a6bDbXx24ZLXsexqa4qcIn3uiLiZ6MGG6v2uiOSw5iaj1d6cIVSXNlJbmUGaiFwxUYqwPVIho4yTPUP2d6MggGasSqIAkpxmHuBQ9GUPHbiGelKOMYZftivWvxJVHcGeNib3sd4GAmDoKziMftaf8cFfpzO6NUUPjiGt0Q8AfOTrC8vZSIVIZfNMGaWH0kORchgepyVEt6lDokQXsfDqnMohYmeZIjGcEHVINmu9tx30aQPws3p4TSFNa7L(DR0pyg3Keq36cEX9d2yLXUF24ZLXG3TFsC)L0is7VK9RewC)050V4QhHhC)YCWrXC)RsuPFzUFnZ(XI9ZZi97wPFsC)b3is7FyVS1i9dMXnjH(XI5WsVH(LrPPXWMApOBAyaciX0Xnjb0TUGxRr(IjKk4wAafv9HmRWfFfx9i80u7bDtddqajwWR1Rh0nTBDXk4m)KbuN1OWkgClnGHeeBUPqkrM1nPHmRLKKb1bLXesfo8PVgwAiZAjjzWHXP56AKV(mjj4WN(Aybbrdji2CtHuImRBsdzwljjdQdkJjKkC4tFnCtTKws3VKyU6r6N2dRrU)ij60FjrL1(rnDR9hjr7NGdI7xmQ2VKmJtZ11i3VK0mjP(ljjdC9Nt)lD)kbU)qM1ssY6FX9Rz2FnnY9Rz)fU6r6N2dRrU)ij60VK4evwH9hRr3VLg3Fs3VsGXC)H0kRUPH73hUFxUY9Rz)NS2pPvjSw)kbU)OISFmhsRG7VYmjpc46xjW9J3Z(P9aJ7psIo9ljorL1(DunpDDdETgb2ulPL097bDtddqajMXKOtuRChgNvqm4wAaXjAvETc0ys0jQvUdJZkiwkWYO00WHXP56AKV(mjjiQybHqM1ssYGdJtZ11iF9zssWHp91WsevKcc0lzc6D4tFnCmrbpa1u7bDtddqajwWR1Rh0nTBDXk4m)KbmuWn1Eq30WaeqIf8A96bDt7wxScoZpzaXk4wAa9GUG4lB85Y4yiUMApOBAyaciXcETE9GUPDRlwbN5NmG6SbkycPIb3sdOh0feFzJpxglr8M6MApOBAyyOGbuMhmpuwJm4wAabwgLMgQdkJjKkevSuzuAA4W40CDnYxFMKeevS0qcIn3uiLiZ6gqccalJstd1bLXesfIkwQmknnK0wlxS4DwfdrflnKGyZnfAlzc6L2zGeeaoKGyZnfcInLqKrqiKGyZnfACyYAofGKkJstd1bLXesfIkwqqoXyP0lzc6D4tFnCmrjobbGdji2CtHuImRBsLrPPHdJtZ11iF9zssquXsPxYe07WN(A4yKuehqn1Eq30WWqbdqajMCnZYLgDIaULgqzuAAOoOmMqQquXccHmRLKKb1bLXesfo8PVgwcItKccYjglLEjtqVdF6RHJjk4PP2d6MgggkyaciXClWyD86n41k4wAaLrPPH6GYycPcrflieYSwssguhugtiv4WN(AyjiorkiiNySu6Lmb9o8PVgoMOGNMApOBAyyOGbiGeJEhwUMzbClnGYO00qDqzmHuHOIfeczwljjdQdkJjKkC4tFnSeeNifeKtmwk9sMGEh(0xdhtSSP2d6MgggkyaciXQlzck(cEh0c5t2uWT0akJstd1bLXesfwsswtTh0nnmmuWaeqIjo1nnWT0akJstd1bLXesfIkwkWYO00q5AMLkkwHOIfeuFiZkKa7vLauCqJjUibsqqoXyP0lzc6D4tFnCmXbpccahsqS5McPezw3KkJstdhgNMRRr(6ZKKGOILsVKjO3Hp91WXiPIdutDtTh0nnmeRaIv2lrUycPcULgq1RSPqSYEjYLodOyPalEyqxYHcmkeRSxICXesvQmknneRSxICPZakgo8PVgogjliiJstdXk7Lix6mGIHLKKbKuGLrPPHdJtZ11iF9zssWssYeeenKGyZnfsjYSUbutTh0nnmeRaeqIrzR1lMqQn1Eq30WqScqajwjrLR8vDXGBPbe4qcIn3uiLiZ6MuGdzwljjdomonxxJ81Njjbh(0xdhd5qbibbrdji2CtHuImRBsfnKGyZnfAlzc6L2zbHqcIn3uOTKjOxANLcCiZAjjzqsBTCXI3zvmC4tFnCmKdfbHqM1ssYGK2A5IfVZQy4WN(AyjiorcKGa9sMGEh(0xdhtujdKuGfD8TCzqSPqVuWqMQlwXccJVLldInf6LcgIkwkWJVLldInf6LcgUwmrfP0X3YLbXMc9sbdh(0xdhdXjim(wUmi2uOxky4AseYSwssMGGh0feFzJpxglruGeeeD8TCzqSPqVuWquXsbE8TCzqSPqVuWWqIAkGrfegFlxgeBk0lfmCnjczwljjdiGAQ9GUPHHyfGasm6Qpm4wAavFU64IHOILoOgtNdzgIt0kDoK5lFkZdUP2d6MggIvaciXuFU64Ib3sd4GAmDoKziorR05qMV8PmpyPQpxDCXWHp91WXqouKgYSwssgKU6ddh(0xdhd5qPP2d6MggIvaciXyQkUM4feFXesTP2d6MggIvaciXiT1YflENvXGBPbu0X3YLbXMc9sbdzQUyflii64B5YGytHEPGHOILo(wUmi2uOxkyybDCDtdGJVLldInf6LcgUwmXfPGW4B5YGytHEPGHOILo(wUmi2uOxky4WN(AyjIglfe8GUG4lB85YyjI2u7bDtddXkabKy0vpcxUycP2u7bDtddXkabKyf2vc3abNY4NGBPbKodOyagCSEhMmBXqNbum80PAtTh0nnmeRaeqI53t0PWZnPVHjjHBQ9GUPHHyfGasms(wxJ81NjjbULgWqM1ssYGdJtZ11iF9zssWHp91WXqouKcSOQxztHmvfxt8cIVycPkiiJstdLRzwQOyfIkgibbrdji2CtHuImRBccHmRLKKbhgNMRRr(6ZKKGdF6RHfeKtmwk9sMGEh(0xdhJKBQ9GUPHHyfGasSHXP56AKV(mjjWT0acSmknnSKOYv(QUyiQybHqM1ssYGLevUYx1fdh(0xdlrurkiiQ6v2uyjrLR8vDXcc0lzc6D4tFnCmrJdKuGfD8TCzqSPqVuWqMQlwXccIo(wUmi2uOxkyiQyPap(wUmi2uOxkyybDCDtdGJVLldInf6LcgUwmrfPGW4B5YGytHEPGHHe1uaJcKGW4B5YGytHEPGHOILo(wUmi2uOxky4WN(AyjILccEqxq8Ln(CzSerbQP2d6MggIvaciXaL1khbClnGYO00WHXP56AKV(mjjiQybHqM1ssYGdJtZ11iF9zssWHp91WsevKccIgsqS5McPezw3KcSmknnu8WHfZxmHuXWssYeeev9kBkmqypDE8lMqQccEqxq8Ln(CzCmXbQP2d6MggIvaciXWk7LixmHub3sdyibXMBkKsKzDtkDgqXam4y9omz2IHodOy4PtvPadCiZAjjzWHXP56AKV(mjj4WN(A4yihkepioPalkorRYRvGmnnkEbXx32t)6Hax5X1Ceeev9kBkSKOYv(QUyGasqq9kBkSKOYv(QUyPHmRLKKbljQCLVQlgo8PVgogIdOMApOBAyiwbiGethugtivWT0akJstdfpCyX8ftivmSKKmPahsqS5McbXMsiYiiesqS5McnomznNIGG6v2uyWR11iFvc8ftivmqccYO00WHXP56AKV(mjjiQybHqM1ssYGdJtZ11iF9zssWHp91WsevKccYO00qsBTCXI3zvmevSGGmknneuwRCeiQyPEqxq8Ln(CzSerfeKtmwk9sMGEh(0xdhtCj3u7bDtddXkabKyJlElx6DyWT0aoOgtNdzgIrhYRr(IjKkwQ6v2uiwh2pRRXsboKzTKKm4W40CDnYxFMKeC4tFnSerfPGGOHeeBUPqkrM1nbbrvVYMcljQCLVQlwqaNOv51kqMMgfVG4RB7PF9qGR84Aoa1u7bDtddXkabKy(EYLlMqQGleju5R6dzwXagfClnGYO00qXdhwmFXesfdljjtqayzuAAOoOmMqQquXcc0O16D4abFiZxDp5yihkam4y9Q7jdKuGfv9kBkmqypDE8lMqQccEqxq8Ln(CzCmXbsqqgLMgQZgOCXesfdh(0xdlbtvoGQ8v3twQh0feFzJpxglr0MApOBAyiwbiGeBCXB5sVddULgqGdzwljjdomonxxJ81Njjbh(0xdlrurkiiAibXMBkKsKzDtqqu1RSPWsIkx5R6IfeWjAvETcKPPrXli(62E6xpe4kpUMdqsPZakgGbhR3HjZwm0zafdpDQkfyzuAAyjrLR8vDXWssYKkJstdzNCLvVMg(QdkFPZakgwssMGG6v2uiwh2pRRXa1u7bDtddXkabKybc7PZJFXesfClnGYO00qXdhwmFXesfdrfliqNbuSeHeRa0d6Mg03tUCXesfgsS2u7bDtddXkabKy(eCJVycPcULgqzuAAO4HdlMVycPIHOIfeOZakwIqIva6bDtd67jxUycPcdjwBQ9GUPHHyfGasmmpIztVyDnYGleju5R6dzwXagfClnGdtpmMGlxzPQpKzfQ7jF18wwwIc646MwtTh0nnmeRaeqIj7Z4KzWT0a6bDbXx24ZLXseTP2d6MggIvaciXgx8wU07WGBPbe4qM1ssYGdJtZ11iF9zssWHp91WsevKshuJPZHmdXOd51iFXesfliiAibXMBkKsKzDtqqu1RSPWsIkx5R6IfeWjAvETcKPPrXli(62E6xpe4kpUMdqsPZakgGbhR3HjZwm0zafdpDQkfyzuAAyjrLR8vDXWssYeeuVYMcX6W(zDngOMApOBAyiwbiGet2jFt6RoBGcgClnGYO00qDqzmHuHLKK1u7bDtddXkabKy0vgtimoTcULgqCIwLxRafJIv0kF5bvSUPjvgLMgQdkJjKkSKKSMApOBAyiwbiGedRSxICXesTPUP2d6MggQZgOGjKkgqSYEjYftivWT0aQELnfIv2lrU0zaflDTlDDjtqLkJstdXk7Lix6mGIHdF6RHJrYn1Eq30WqD2afmHuXaeqIrzR1lMqQGBPbCqnMohYmuCIgiCt674Gx5CPhN8jBkwQmknnKU6r4bFp9HcevCtTh0nnmuNnqbtivmabKy0vpcxUycPcULgWb1y6CiZqXjAGWnPVJdELZLECYNSP4MApOBAyOoBGcMqQyaciXkjQCLVQlgClnGahsqS5McPezw3KgYSwssgCyCAUUg5Rptsco8PVgogYHIGGOHeeBUPqkrM1nPIgsqS5McTLmb9s7SGqibXMBk0wYe0lTZsboKzTKKmiPTwUyX7Skgo8PVgogYHIGqiZAjjzqsBTCXI3zvmC4tFnSeeNibsqq9HmRqDp5RM3YYXevKccHmRLKKbhgNMRRr(6ZKKGdF6RHLiQiL6bDbXx24ZLXsqCajfyrhFlxgeBk0lfmKP6IvSGW4B5YGytHEPGHdF6RHLiwkiiAibXMBkKsKzDdOMApOBAyOoBGcMqQyaciXuFU64Ib3sd4GAmDoKziorR05qMV8PmpyPQpxDCXWHp91WXqouKgYSwssgKU6ddh(0xdhd5qPP2d6MggQZgOGjKkgGasm6Qpm4QRX3qbW4sgClnGQpxDCXquXshuJPZHmdXjALohY8LpL5b3u7bDtdd1zduWesfdqajgtvX1eVG4lMqQn1Eq30WqD2afmHuXaeqIrARLlw8oRIb3sdOOJVLldInf6LcgYuDXkwqy8TCzqSPqVuWWHp91WsevKccEqxq8Ln(CzSeao(wUmi2uOxkyyirnL4r8MApOBAyOoBGcMqQyaciXi5BDnYxFMKe4wAadzwljjdomonxxJ81Njjbh(0xdhd5qrkWIQELnfYuvCnXli(IjKQGGmknnuUMzPIIviQyGeeenKGyZnfsjYSUjieYSwssgCyCAUUg5Rptsco8PVgwIOIuqqoXyP0lzc6D4tFnCmsUP2d6MggQZgOGjKkgGasSHXP56AKV(mjjWT0acCiZAjjzqqzTYrGdF6RHJHCOiiiQ6v2uiOSw5iccQpKzfQ7jF18wwoMOXbskWIo(wUmi2uOxkyit1fRybHX3YLbXMc9sbdh(0xdlrSuqWd6cIVSXNlJLaWX3YLbXMc9sbddjQPepIdutTh0nnmuNnqbtivmabKyGYALJaULgqzuAA4W40CDnYxFMKeevSGqiZAjjzWHXP56AKV(mjj4WN(AyjIksbbrdji2CtHuImRBn1Eq30WqD2afmHuXaeqIj7Z4K5MApOBAyOoBGcMqQyaciX0bLXesfClnGYO00WHXP56AKV(mjjiQybHqM1ssYGdJtZ11iF9zssWHp91WsevKccIgsqS5McPezw3eeKtmwk9sMGEh(0xdhtCr2u7bDtdd1zduWesfdqaj24I3YLEhgClnGdQX05qMHy0H8AKVycPILcCiZAjjzWHXP56AKV(mjj4WN(AyjIksbbrdji2CtHuImRBccIQELnfwsu5kFvxmqsLrPPH6SbkxmHuXWHp91WsaitvoGQ8v3tUP2d6MggQZgOGjKkgGasmFp5YftivWfIeQ8v9HmRyaJcULgqzuAAOoBGYftivmC4tFnSeaYuLdOkF19KLcSmknnu8WHfZxmHuXWssYeeOrR17Wbc(qMV6EYXeCSE19Kbi5qrqqgLMgQdkJjKkevmqn1Eq30WqD2afmHuXaeqIvyxjCdeCkJFcULgq6mGIbyWX6DyYSfdDgqXWtNQn1Eq30WqD2afmHuXaeqInU4TCP3Hb3sdiWHmRLKKbhgNMRRr(6ZKKGdF6RHLiQiLoOgtNdzgIrhYRr(IjKkwqq0qcIn3uiLiZ6MGGOdQX05qMHy0H8AKVycPIfeev9kBkSKOYv(QUyGKkJstd1zduUycPIHdF6RHLaqMQCav5RUNCtTh0nnmuNnqbtivmabKyNOvDXesfClnGYO00qD2aLlMqQyyjjzccYO00qXdhwmFXesfdrflLodOyjcjwbOh0nnOVNC5IjKkmKyvkWIQELnfgiSNop(ftivbbpOli(YgFUmwcIdOMApOBAyOoBGcMqQyaciXce2tNh)IjKk4wAaLrPPHIhoSy(IjKkgIkwkDgqXsesScqpOBAqFp5YftivyiXQupOli(YgFUmogIFtTh0nnmuNnqbtivmabKyu2A9IjKk4wAaLrPPHf2lxocdljjRP2d6MggQZgOGjKkgGasm)EIofEUj9nmjjCtTh0nnmuNnqbtivmabKy0vpcxUycP2u7bDtdd1zduWesfdqajgMhXSPxSUgzWfIeQ8v9HmRyaJcULgWHPhgtWLRCtTh0nnmuNnqbtivmabKyNOvDXesfClnG0zaflriXka9GUPb99KlxmHuHHeRsboKzTKKm4W40CDnYxFMKeC4tFnSeswqq0qcIn3uiLiZ6gqn1Eq30WqD2afmHuXaeqIP(C1XfdULgWb1y6CiZqJX41itYNi4RoUyXRr(6If7JRO4MApOBAyOoBGcMqQyaciXOhMbVwJ8vhxm4wAahuJPZHmdngJxJmjFIGV64IfVg5RlwSpUIIBQ9GUPHH6SbkycPIbiGet2jFt6RoBGcgClnGYO00qDqzmHuHLKK1u7bDtdd1zduWesfdqajgDLXecJtRGBPbeNOv51kqXOyfTYxEqfRBAsLrPPH6GYycPcljjRP2d6MggQZgOGjKkgGasmSYEjYfti1M6MApOBAyOoRrHvmGG8zD5kdoZpzaXrSWfvm4a5vugqzuAA4W40CDnYxFMKeevSGGmknnuhugtiviQ4MApOBAyOoRrHvmabKyG8zD5kdoZpzaX6Kg5loIfUOIbhiVIYagsqS5McPezw3KkJstdhgNMRRr(6ZKKGOILkJstd1bLXesfIkwqq0qcIn3uiLiZ6MuzuAAOoOmMqQquXn1Eq30WqDwJcRyaciXa5Z6YvgCMFYaI1jnYxCelCh(0xddUumGywxAWbYROmGHmRLKKbhgNMRRr(6ZKKGdF6RHJjwviZAjjzqDqzmHuHdF6RHbhiVIYxUIzadzwljjdQdkJjKkC4tFnm4wAaLrPPH6GYycPcljjtAibXMBkKsKzDRP2d6MggQZAuyfdqajgiFwxUYGZ8tgqSoPr(IJyH7WN(AyWLIbeZ6sdoqEfLbmKzTKKm4W40CDnYxFMKeC4tFnm4a5vu(YvmdyiZAjjzqDqzmHuHdF6RHb3sdOmknnuhugtiviQyPHeeBUPqkrM1TMApOBAyOoRrHvmabKyG8zD5kdoZpzaXrSWD4tFnm4sXaIzDPb3sdyibXMBkKsKzDdCG8kkdyiZAjjzWHXP56AKV(mjj4WN(AyjIvfYSwssguhugtiv4WN(AyWbYRO8LRygWqM1ssYG6GYycPch(0xd3u7bDtdd1znkSIbiGedfZ3v5tm4W1uXaQZAuynk4wAabwN1OWkmkKGJVOy(kJstliesqS5McPezw3KQZAuyfgfsWX3qM1ssYaskWG8zD5kdX6Kg5loIfUOILcSOHeeBUPqkrM1nPIQZAuyfghsWXxumFLrPPfecji2CtHuImRBsfvN1OWkmoKGJVHmRLKKjiOZAuyfghgYSwssgC4tFnSGGoRrHvyuibhFrX8vgLMwkWIQZAuyfghsWXxumFLrPPfe0znkScJcdzwljjdwqhx30KaqDwJcRW4WqM1ssYGf0X1nnGee0znkScJcj44BiZAjjzsfvN1OWkmoKGJVOy(kJstlvN1OWkmkmKzTKKmybDCDttca1znkScJddzwljjdwqhx30asqquq(SUCLHyDsJ8fhXcxuXsbwuDwJcRW4qco(II5RmknTuG1znkScJcdzwljjdwqhx30aFjhdiFwxUYqCelCh(0xdliaYN1LRmehXc3Hp91WsOZAuyfgfgYSwssgSGoUUPr8ghibbDwJcRW4qco(II5RmknTuG1znkScJcj44lkMVYO00s1znkScJcdzwljjdwqhx30KaqDwJcRW4WqM1ssYGf0X1nnPaRZAuyfgfgYSwssgSGoUUPb(sogq(SUCLH4iw4o8PVgwqaKpRlxzioIfUdF6RHLqN1OWkmkmKzTKKmybDCDtJ4noqccalQoRrHvyuibhFrX8vgLMwqqN1OWkmomKzTKKmybDCDttca1znkScJcdzwljjdwqhx30askW6SgfwHXHHmRLKKbh2lrKQZAuyfghgYSwssgSGoUUPb(swcq(SUCLH4iw4o8PVgwkiFwxUYqCelCh(0xdhJoRrHvyCyiZAjjzWc646MgXBCbbr1znkScJddzwljjdoSxIifyDwJcRW4WqM1ssYGdF6RHbFjhdiFwxUYqSoPr(IJyH7WN(AyPG8zD5kdX6Kg5loIfUdF6RHLiUiLcSoRrHvyuyiZAjjzWc646Mg4l5ya5Z6YvgIJyH7WN(AybbDwJcRW4WqM1ssYGdF6RHbFjhdiFwxUYqCelCh(0xdlvN1OWkmomKzTKKmybDCDtd8JksacYN1LRmehXc3Hp91WXaYN1LRmeRtAKV4iw4o8PVgwqaKpRlxzioIfUdF6RHLqN1OWkmkmKzTKKmybDCDtJ4nUGaiFwxUYqCelCrfdKGGoRrHvyCyiZAjjzWHp91WGVKLaKpRlxziwN0iFXrSWD4tFnSuG1znkScJcdzwljjdwqhx30aFjhdiFwxUYqSoPr(IJyH7WN(Aybbr1znkScJcj44lkMVYO00sbgKpRlxzioIfUdF6RHLqN1OWkmkmKzTKKmybDCDtJ4nUGaiFwxUYqCelCrfdeqabeqajiiNySu6Lmb9o8PVgogq(SUCLH4iw4o8PVggibbr1znkScJcj44lkMVYO00sfnKGyZnfsjYSUjfyDwJcRW4qco(II5RmknTuGbwuq(SUCLH4iw4IkwqqN1OWkmomKzTKKm4WN(AyjKmqsbgKpRlxzioIfUdF6RHLiUife0znkScJddzwljjdo8PVgg8LSeG8zD5kdXrSWD4tFnmqajiiQoRrHvyCibhFrX8vgLMwkWIQZAuyfghsWX3qM1ssYee0znkScJddzwljjdo8PVgwqqN1OWkmomKzTKKmybDCDttca1znkScJcdzwljjdwqhx30acOMApOBAyOoRrHvmabKyOy(UkFIbhUMkgqDwJcRXb3sdiW6SgfwHXHeC8ffZxzuAAbHqcIn3uiLiZ6MuDwJcRW4qco(gYSwssgqsbgKpRlxziwN0iFXrSWfvSuGfnKGyZnfsjYSUjvuDwJcRWOqco(II5RmknTGqibXMBkKsKzDtQO6SgfwHrHeC8nKzTKKmbbDwJcRWOWqM1ssYGdF6RHfe0znkScJdj44lkMVYO00sbwuDwJcRWOqco(II5RmknTGGoRrHvyCyiZAjjzWc646MMeaQZAuyfgfgYSwssgSGoUUPbKGGoRrHvyCibhFdzwljjtQO6SgfwHrHeC8ffZxzuAAP6SgfwHXHHmRLKKblOJRBAsaOoRrHvyuyiZAjjzWc646MgqccIcYN1LRmeRtAKV4iw4IkwkWIQZAuyfgfsWXxumFLrPPLcSoRrHvyCyiZAjjzWc646Mg4l5ya5Z6YvgIJyH7WN(Aybbq(SUCLH4iw4o8PVgwcDwJcRW4WqM1ssYGf0X1nnI34ajiOZAuyfgfsWXxumFLrPPLcSoRrHvyCibhFrX8vgLMwQoRrHvyCyiZAjjzWc646MMeaQZAuyfgfgYSwssgSGoUUPjfyDwJcRW4WqM1ssYGf0X1nnWxYXaYN1LRmehXc3Hp91WccG8zD5kdXrSWD4tFnSe6SgfwHXHHmRLKKblOJRBAeVXbsqayr1znkScJdj44lkMVYO00cc6SgfwHrHHmRLKKblOJRBAsaOoRrHvyCyiZAjjzWc646MgqsbwN1OWkmkmKzTKKm4WEjIuDwJcRWOWqM1ssYGf0X1nnWxYsaYN1LRmehXc3Hp91Wsb5Z6YvgIJyH7WN(A4y0znkScJcdzwljjdwqhx30iEJliiQoRrHvyuyiZAjjzWH9sePaRZAuyfgfgYSwssgC4tFnm4l5ya5Z6YvgI1jnYxCelCh(0xdlfKpRlxziwN0iFXrSWD4tFnSeXfPuG1znkScJddzwljjdwqhx30aFjhdiFwxUYqCelCh(0xdliOZAuyfgfgYSwssgC4tFnm4l5ya5Z6YvgIJyH7WN(AyP6SgfwHrHHmRLKKblOJRBAGFurcqq(SUCLH4iw4o8PVgogq(SUCLHyDsJ8fhXc3Hp91WccG8zD5kdXrSWD4tFnSe6SgfwHXHHmRLKKblOJRBAeVXfea5Z6YvgIJyHlQyGee0znkScJcdzwljjdo8PVgg8LSeG8zD5kdX6Kg5loIfUdF6RHLcSoRrHvyCyiZAjjzWc646Mg4l5ya5Z6YvgI1jnYxCelCh(0xdliiQoRrHvyCibhFrX8vgLMwkWG8zD5kdXrSWD4tFnSe6SgfwHXHHmRLKKblOJRBAeVXfea5Z6YvgIJyHlQyGaciGacibb5eJLsVKjO3Hp91WXaYN1LRmehXc3Hp91WajiiQoRrHvyCibhFrX8vgLMwQOHeeBUPqkrM1nPaRZAuyfgfsWXxumFLrPPLcmWIcYN1LRmehXcxuXcc6SgfwHrHHmRLKKbh(0xdlHKbskWG8zD5kdXrSWD4tFnSeXfPGGoRrHvyuyiZAjjzWHp91WGVKLaKpRlxzioIfUdF6RHbcibbr1znkScJcj44lkMVYO00sbwuDwJcRWOqco(gYSwssMGGoRrHvyuyiZAjjzWHp91Wcc6SgfwHrHHmRLKKblOJRBAsaOoRrHvyCyiZAjjzWc646MgqaHOikcc]] )


end