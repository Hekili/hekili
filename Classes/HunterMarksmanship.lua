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


    spec:RegisterPack( "Marksmanship", 20210823, [[daLLscqicPhjucxcHQ0MisFcHmkGYPauRcHQOxju1SaQ6wiuzxG(fcLHHKYXesldapdq00iIuxJiQTjujFJisgNqj15iIO1bi8oeQcAEcf3dG2hr4FcLO6GerWcrs1dfQyIiuv5IcLiBuOKOpkuP0ifkrXjfkjTscXlfkrPzkuQBIqvODcu5NcvkgQqjHLseHEQkmvaPVIqvvJfjXEH4VQ0Gv1HPAXe1JfmzjUmQnJuFgrnAeCAfRgHQaVgjMTKUTkA3u(TOHtOoocvLLR0ZHA6KUoK2oq(oImEKKoVqSEHkvZNG9l1irrakYrXvgbCaqnaIsTynaajKAssGussT4c5qJiMroe7bkozg5W8tg5G4rFPGpDdtyeJCi2JutVGauKdCIUbg5iw0pbvfJbcIrmYJsavggYtIHNt0QRtAH1PvIHNZaXqoKrNQgRAiYihfxzeWba1aik1I1aaKqQjjbsjj1KmYHJQeYf54yoJdYbHPuydrg5OW4aYbXJ(sbF6gMWiU)yzqnL3wejbuYOyTFaasW3paudGOTiTiXHGBKzmq0IqC9doMeDIAL(LezCwbX9p4(Tu737)KdeCBc9Re4(9sjT(dUrmstT2)PBozg2IqC9ljY4iwGl97LsA9lENChns)KgLq)hZzC6xsiwrSHTiex)XM1(JLnYoUH7VW4iwOFLapB)XH4hUFCEY6CYyiYrDWkgbOih6obkycPIrakc4IIauKd2C5kxqOoYryhL3XrouVYMcXk7Lix6mGIHS5YvU0V0(h7sxhYe0(L2VmknneRSxICPZakgU8PpgU)y6xYihEqN0qoWk7LixmHurueWbacqroyZLRCbH6ihHDuEhh5yrnMoxYmuCIgiCt676X9CV0Rt(KnfdzZLRCPFP9lJstdPREeEX3tFParfJC4bDsd5GYuRxmHurueWbKiaf5GnxUYfeQJCe2r5DCKJf1y6CjZqXjAGWnPVRh3Z9sVo5t2umKnxUYfKdpOtAih0vpcxUycPIOiGtsJauKd2C5kxqOoYryhL3XroaR)qcIn3uiLi74w)s7pKzTKKm4Y40CDmYxF3KeC5tFmC)X0p5qPFbH(fT)qcIn3uiLi74w)s7x0(dji2CtH2qMGEPDUFbH(dji2CtH2qMGEPDUFP9dw)HmRLKKbjn1YflE2rXWLp9XW9ht)KdL(fe6pKzTKKmiPPwUyXZokgU8PpgUFj6hiPw)a3VGq)QVKzfQZjF18wgU)y6pk16xqO)qM1ssYGlJtZ1XiF9DtsWLp9XW9lr)rPw)s73d6aIVSXNdJ7xI(bY(bUFP9dw)I2)6t5YGytHEPGHmvhSI7xqO)1NYLbXMc9sbdx(0hd3Ve9lj7xqOFr7pKGyZnfsjYoU1pWihEqN0qokjQCLVQlgrraNKrakYbBUCLliuh5iSJY74ihlQX05sMH4eTsNlz(YNY8IHS5YvU0V0(vFV66IHlF6JH7pM(jhk9lT)qM1ssYG0vFz4YN(y4(JPFYHcYHh0jnKd13RUUyefbCXfcqroyZLRCbH6ihEqN0qoOR(YihHDuEhh5q99QRlgIkUFP9VOgtNlzgIt0kDUK5lFkZlgYMlx5cYrDm(gkihaizefbCskeGIC4bDsd5GPQ4AIhq8ftivKd2C5kxqOoIIaUyncqroyZLRCbH6ihHDuEhh5q0(xFkxgeBk0lfmKP6GvC)cc9V(uUmi2uOxky4YN(y4(LO)OuRFbH(9GoG4lB85W4(LaW(xFkxgeBk0lfmmKOM2pXZ(ba5Wd6KgYbPPwUyXZokgrraNKebOihS5YvUGqDKJWokVJJCeYSwssgCzCAUog5RVBscU8PpgU)y6NCO0V0(bRFr7x9kBkKPQ4AIhq8ftiviBUCLl9li0VmknnuUMzPIIviQ4(bUFbH(fT)qcIn3uiLi74w)cc9hYSwssgCzCAUog5RVBscU8PpgUFj6pk16xqOF5eJ7xA)0dzc6D5tFmC)X0VKro8GoPHCqYN6yKV(UjjefbCrPgcqroyZLRCbH6ihHDuEhh5aS(dzwljjdckRvocC5tFmC)X0p5qPFbH(fTF1RSPqqzTYrGS5YvU0VGq)QVKzfQZjF18wgU)y6pka9dC)s7hS(fT)1NYLbXMc9sbdzQoyf3VGq)RpLldInf6LcgU8PpgUFj6xs2VGq)Eqhq8Ln(CyC)say)RpLldInf6Lcggsut7N4z)a0pWihEqN0qowgNMRJr(67MKqueWfnkcqroyZLRCbH6ihHDuEhh5qgLMgUmonxhJ813njbrf3VGq)HmRLKKbxgNMRJr(67MKGlF6JH7xI(JsT(fe6x0(dji2CtHuISJBihEqN0qoaL1khbrraxuaqakYHh0jnKdzFxNmJCWMlx5cc1rueWffirakYbBUCLliuh5iSJY74ihYO00WLXP56yKV(UjjiQ4(fe6pKzTKKm4Y40CDmYxF3KeC5tFmC)s0FuQ1VGq)I2FibXMBkKsKDCRFbH(LtmUFP9tpKjO3Lp9XW9ht)aqnKdpOtAih6IYycPIOiGlQKgbOihS5YvUGqDKJWokVJJCSOgtNlzgIrxYJr(IjKkgYMlx5s)s7hS(dzwljjdUmonxhJ813njbx(0hd3Ve9hLA9li0VO9hsqS5McPezh36xqOFr7x9kBkSKOYv(QUyiBUCLl9dC)s7xgLMgQ7eOCXesfdx(0hd3Vea2ptvoGQ8vNtg5Wd6KgYX6INYLEwgrraxujJauKd2C5kxqOoYHh0jnKdFo5YftivKJWokVJJCiJstd1DcuUycPIHlF6JH7xca7NPkhqv(QZj3V0(bRFzuAAO4LddMVycPIHLKK1VGq)0O16D5abFjZxDo5(JP)GJ1RoNC)X3p5qPFbH(LrPPH6IYycPcrf3pWihHiHkFvFjZkgbCrrueWfnUqakYbBUCLliuh5iSJY74ih0zaf3F89hCSExMmB9ht)0zafdpDQIC4bDsd5OWUs4gi4uw)erraxujfcqroyZLRCbH6ihHDuEhh5aS(dzwljjdUmonxhJ813njbx(0hd3Ve9hLA9lT)f1y6CjZqm6sEmYxmHuXq2C5kx6xqOFr7pKGyZnfsjYoU1VGq)I2)IAmDUKzigDjpg5lMqQyiBUCLl9li0VO9RELnfwsu5kFvxmKnxUYL(bUFP9lJstd1DcuUycPIHlF6JH7xca7NPkhqv(QZjJC4bDsd5yDXt5splJOiGlASgbOihS5YvUGqDKJWokVJJCiJstd1DcuUycPIHLKK1VGq)YO00qXlhgmFXesfdrf3V0(PZakUFj6pKyT)473d6Kg0NtUCXesfgsS2V0(bRFr7x9kBkmqyoDE9lMqQq2C5kx6xqOFpOdi(YgFomUFj6hi7hyKdpOtAihNOvDWesfrraxujjcqroyZLRCbH6ihHDuEhh5qgLMgkE5WG5lMqQyiQ4(L2pDgqX9lr)HeR9hF)EqN0G(CYLlMqQWqI1(L2Vh0beFzJphg3Fm9lPro8GoPHCeimNoV(ftivefbCaqneGICWMlx5cc1roc7O8ooYHmknnSWE5YryyjjzihEqN0qoOm16ftivefbCaefbOihEqN0qo87j6w49M03WMKWihS5YvUGqDefbCaaacqro8GoPHCqx9iC5IjKkYbBUCLliuhrrahaajcqroyZLRCbH6ihEqN0qoW8kMn9I1XiJCe2r5DCKJLPxgtWLRmYrisOYx1xYSIraxuefbCaiPrakYbBUCLliuh5iSJY74ih0zaf3Ve9hsS2F897bDsd6ZjxUycPcdjw7xA)G1FiZAjjzWLXP56yKV(Ujj4YN(y4(LOFj3VGq)I2FibXMBkKsKDCRFGro8GoPHCCIw1btivefbCaizeGICWMlx5cc1roc7O8ooYXIAmDUKzOXy8yKj5Be8vxxS4XiFDXI91vumKnxUYfKdpOtAihQVxDDXikc4aiUqakYbBUCLliuh5iSJY74ihlQX05sMHgJXJrMKVrWxDDXIhJ81fl2xxrXq2C5kxqo8GoPHCqVmh3hJ8vxxmIIaoaKuiaf5GnxUYfeQJCe2r5DCKdzuAAOUOmMqQWssYqo8GoPHCi7KVj9v3jqbJOiGdGyncqroyZLRCbH6ihHDuEhh5aNOv5XkqXOyfTYxErfRtAq2C5kx6xA)YO00qDrzmHuHLKKHC4bDsd5GUYycH1PvefbCaijrakYHh0jnKdSYEjYftivKd2C5kxqOoIIOihfM2rRkcqraxueGIC4bDsd5iKOMY7ftivKd2C5kxqOoIIaoaqakYbBUCLliuh5Wd6KgYrirnL3lMqQihHDuEhh5yrnMoxYmeZIjGg3XxXBgQ(PRtAq2C5kx6xqOFCIwLhRaTjIJVAMv8vCo40GS5YvU0VGq)G1FiTc6OWLbXl2R3K(sNRIAmKnxUYL(L2VO9VOgtNlzgIzXeqJ74R4ndv)01jniBUCLl9dmYrDm(gkihaj1queWbKiaf5GnxUYfeQJC4bDsd5qx3i(qN6e3hJ8ftivKJcJd7iwN0qoIBZ(DcSx63Ts)aDDJ4dDQtCN7hCXkIt)SXNdJbF)K4(lPrK2Fj7xjm4(PZTFXvpcV4(L5GJI5(hLOs)YC)AM9Jf7NNr63Ts)K4(dUrK2)YEzQr6hORBeF9JfZHHEc9lJstJHihHDuEhh5q0(vFjZkCWxXvpcVikc4K0iaf5GnxUYfeQJCe2r5DCKJqcIn3uiLi74w)s7pKzTKKmOUOmMqQWLp9XW9lT)qM1ssYGlJtZ1XiF9DtsWLp9XW9li0VO9hsqS5McPezh36xA)HmRLKKb1fLXesfU8Ppgg5Wd6KgYrWR1Rh0jTBDWkYrDW618tg5q3XOWkgrraNKrakYbBUCLliuh5Wd6KgYrWR1Rh0jTBDWkYrDW618tg5iuWikc4IleGICWMlx5cc1roc7O8ooYHh0beFzJphg3Fm9dKihEqN0qocETE9GoPDRdwroQdwVMFYihyfrraNKcbOihS5YvUGqDKJWokVJJC4bDaXx24ZHX9lr)aGC4bDsd5i4161d6K2Toyf5Ooy9A(jJCO7eOGjKkgrruKdXlhYtzxrakc4IIauKdpOtAihYPQvUCPREeUqAmYxnP6yihS5YvUGqDefbCaGauKdpOtAih0vgtiSoTICWMlx5cc1rueWbKiaf5GnxUYfeQJCe2r5DCKJf1y6CjZqCIwPZLmF5tzEXq2C5kxqo8GoPHCO(E11fJOiGtsJauKd2C5kxqOoYH4LdowV6CYihrPgYHh0jnKJsIkx5R6Iroc7O8ooYHh0beFzJphg3Ve9hTFbH(fT)qcIn3uiLi74w)s7x0(vVYMcbL1khbYMlx5cIIaojJauKd2C5kxqOoYrkg5aZkYHh0jnKdq(oUCLroa5vug5OYKzR4Bei7KRS610WxDr5lDgqXq2C5kx6xA)yw1XiJHStUYQxt7Ij5IHS5YvUGCuyCyhX6KgYrCi4gzUFn7pA)A2pEorRUY9hlb0yLe74iwz)KzFXKCX9d0fLXesTFXlhCScroa5718tg5Gv6R4LdowrueWfxiaf5GnxUYfeQJCe2r5DCKdq(oUCLHSsFfVCWXkYHh0jnKdDrzmHurueWjPqakYbBUCLliuh5iSJY74ihEqhq8Ln(CyC)X0pq2V0(bRFr7pKGyZnfsjYoU1V0(fTF1RSPqqzTYrGS5YvU0VGq)Eqhq8Ln(CyC)X0pa9dC)s7x0(b574YvgYk9v8YbhRihEqN0qo85KlxmHurueWfRrakYbBUCLliuh5iSJY74ihEqhq8Ln(CyC)s0pa9li0py9hsqS5McPezh36xqOF1RSPqqzTYrGS5YvU0pW9lTFpOdi(YgFomUFa7hG(fe6hKVJlxziR0xXlhCSIC4bDsd5aRSxICXesfrruKJqbJaueWffbOihS5YvUGqDKJWokVJJCaw)YO00qDrzmHuHOI7xA)YO00WLXP56yKV(UjjiQ4(L2FibXMBkKsKDCRFG7xqOFW6xgLMgQlkJjKkevC)s7xgLMgsAQLlw8SJIHOI7xA)HeeBUPqBitqV0o3pW9li0py9hsqS5McbXMsiY2VGq)HeeBUPqJdBwZT0pW9lTFzuAAOUOmMqQquX9li0VCIX9lTF6Hmb9U8PpgU)y6pkq2VGq)G1FibXMBkKsKDCRFP9lJstdxgNMRJr(67MKGOI7xA)0dzc6D5tFmC)X0VKci7hyKdpOtAihY8I5LYyKrueWbacqroyZLRCbH6ihHDuEhh5qgLMgQlkJjKkevC)cc9hYSwssguxugtiv4YN(y4(LOFGKA9li0VCIX9lTF6Hmb9U8PpgU)y6pACHC4bDsd5qUMz5sJUrqueWbKiaf5GnxUYfeQJCe2r5DCKdzuAAOUOmMqQquX9li0FiZAjjzqDrzmHuHlF6JH7xI(bsQ1VGq)Yjg3V0(PhYe07YN(y4(JP)OXfYHh0jnKd3cmwxVEdETIOiGtsJauKd2C5kxqOoYryhL3XroKrPPH6IYycPcrf3VGq)HmRLKKb1fLXesfU8PpgUFj6hiPw)cc9lNyC)s7NEitqVlF6JH7pM(LKihEqN0qoONLLRzwqueWjzeGICWMlx5cc1roc7O8ooYHmknnuxugtivyjjzihEqN0qoQdzck(s8a0c5t2uefbCXfcqroyZLRCbH6ihHDuEhh5qgLMgQlkJjKkevC)s7hS(LrPPHY1mlvuScrf3VGq)QVKzfsG9QsakoO9ht)aqT(bUFbH(LtmUFP9tpKjO3Lp9XW9ht)aex9li0py9hsqS5McPezh36xA)YO00WLXP56yKV(UjjiQ4(L2p9qMGEx(0hd3Fm9lPaOFGro8GoPHCio1jnefrroWkcqraxueGICWMlx5cc1roc7O8ooYH6v2uiwzVe5sNbumKnxUYL(L2py9lEzqxYHcmkeRSxICXesTFP9lJstdXk7Lix6mGIHlF6JH7pM(LC)cc9lJstdXk7Lix6mGIHLKK1pW9lTFW6xgLMgUmonxhJ813njbljjRFbH(fT)qcIn3uiLi74w)aJC4bDsd5aRSxICXesfrrahaiaf5Wd6KgYbLPwVycPICWMlx5cc1rueWbKiaf5GnxUYfeQJCe2r5DCKdW6pKGyZnfsjYoU1V0(bR)qM1ssYGlJtZ1XiF9DtsWLp9XW9ht)KdL(bUFbH(fT)qcIn3uiLi74w)s7x0(dji2CtH2qMGEPDUFbH(dji2CtH2qMGEPDUFP9dw)HmRLKKbjn1YflE2rXWLp9XW9ht)KdL(fe6pKzTKKmiPPwUyXZokgU8PpgUFj6hiPw)a3VGq)0dzc6D5tFmC)X0Fuj3pW9lTFW6x0(xFkxgeBk0lfmKP6GvC)cc9V(uUmi2uOxkyiQ4(L2py9V(uUmi2uOxky4y9ht)rPw)s7F9PCzqSPqVuWWLp9XW9ht)az)cc9V(uUmi2uOxky4y9lr)EqN0UHmRLKK1VGq)Eqhq8Ln(CyC)s0F0(bUFbH(fT)1NYLbXMc9sbdrf3V0(bR)1NYLbXMc9sbddjQP9dy)r7xqO)1NYLbXMc9sbdhRFj63d6K2nKzTKKS(bUFGro8GoPHCusu5kFvxmIIaojncqroyZLRCbH6ihHDuEhh5q99QRlgIkUFP9VOgtNlzgIt0kDUK5lFkZlgYMlx5cYHh0jnKd6QVmIIaojJauKd2C5kxqOoYryhL3XrowuJPZLmdXjALoxY8LpL5fdzZLRCPFP9R(E11fdx(0hd3Fm9tou6xA)HmRLKKbPR(YWLp9XW9ht)KdfKdpOtAihQVxDDXikc4IleGIC4bDsd5GPQ4AIhq8ftivKd2C5kxqOoIIaojfcqroyZLRCbH6ihHDuEhh5q0(xFkxgeBk0lfmKP6GvC)cc9lA)RpLldInf6LcgIkUFP9V(uUmi2uOxkyybDDDsR)47F9PCzqSPqVuWWX6pM(bGA9li0)6t5YGytHEPGHOI7xA)RpLldInf6LcgU8PpgUFj6pQKSFbH(9GoG4lB85W4(LO)OihEqN0qoin1YflE2rXikc4I1iaf5Wd6KgYbD1JWLlMqQihS5YvUGqDefbCsseGICWMlx5cc1roc7O8ooYbDgqX9hF)bhR3LjZw)X0pDgqXWtNQihEqN0qokSReUbcoL1prueWfLAiaf5Wd6KgYHFpr3cV3K(g2Keg5GnxUYfeQJOiGlAueGICWMlx5cc1roc7O8ooYriZAjjzWLXP56yKV(Ujj4YN(y4(JPFYHs)s7hS(fTF1RSPqMQIRjEaXxmHuHS5YvU0VGq)YO00q5AMLkkwHOI7h4(fe6x0(dji2CtHuISJB9li0FiZAjjzWLXP56yKV(Ujj4YN(y4(fe6xoX4(L2p9qMGEx(0hd3Fm9lzKdpOtAihK8Pog5RVBscrraxuaqakYbBUCLliuh5iSJY74ihG1VmknnSKOYv(QUyiQ4(fe6pKzTKKmyjrLR8vDXWLp9XW9lr)rPw)cc9lA)QxztHLevUYx1fdzZLRCPFbH(PhYe07YN(y4(JP)Oa0pW9lTFW6x0(xFkxgeBk0lfmKP6GvC)cc9lA)RpLldInf6LcgIkUFP9dw)RpLldInf6LcgwqxxN06p((xFkxgeBk0lfmCS(JP)OuRFbH(xFkxgeBk0lfmmKOM2pG9hTFG7xqO)1NYLbXMc9sbdrf3V0(xFkxgeBk0lfmC5tFmC)s0VKSFbH(9GoG4lB85W4(LO)O9dmYHh0jnKJLXP56yKV(UjjefbCrbseGICWMlx5cc1roc7O8ooYHmknnCzCAUog5RVBscIkUFbH(dzwljjdUmonxhJ813njbx(0hd3Ve9hLA9li0VO9hsqS5McPezh36xA)G1Vmknnu8YHbZxmHuXWssY6xqOFr7x9kBkmqyoDE9lMqQq2C5kx6xqOFpOdi(YgFomU)y6hG(bg5Wd6KgYbOSw5iikc4IkPrakYbBUCLliuh5iSJY74ihHeeBUPqkr2XT(L2pDgqX9hF)bhR3LjZw)X0pDgqXWtNQ9lTFW6hS(dzwljjdUmonxhJ813njbx(0hd3Fm9tou6N4z)az)s7hS(fTFCIwLhRazAAu8aIVUnN(1dbUYRR5czZLRCPFbH(fTF1RSPWsIkx5R6IHS5YvU0pW9dC)cc9RELnfwsu5kFvxmKnxUYL(L2FiZAjjzWsIkx5R6IHlF6JH7pM(bY(bg5Wd6KgYbwzVe5IjKkIIaUOsgbOihS5YvUGqDKJWokVJJCiJstdfVCyW8ftivmSKKS(L2py9hsqS5McbXMsiY2VGq)HeeBUPqJdBwZT0VGq)QxztHbVwhJ8vjWxmHuXq2C5kx6h4(fe6xgLMgUmonxhJ813njbrf3VGq)HmRLKKbxgNMRJr(67MKGlF6JH7xI(JsT(fe6xgLMgsAQLlw8SJIHOI7xqOFzuAAiOSw5iquX9lTFpOdi(YgFomUFj6pA)cc9lNyC)s7NEitqVlF6JH7pM(bqYihEqN0qo0fLXesfrrax04cbOihS5YvUGqDKJWokVJJCSOgtNlzgIrxYJr(IjKkgYMlx5s)s7x9kBkeRl7N1XyiBUCLl9lTFW6pKzTKKm4Y40CDmYxF3KeC5tFmC)s0FuQ1VGq)I2FibXMBkKsKDCRFbH(fTF1RSPWsIkx5R6IHS5YvU0VGq)4eTkpwbY00O4beFDBo9RhcCLxxZfYMlx5s)aJC4bDsd5yDXt5splJOiGlQKcbOihS5YvUGqDKdpOtAih(CYLlMqQihHDuEhh5qgLMgkE5WG5lMqQyyjjz9li0py9lJstd1fLXesfIkUFbH(PrR17Ybc(sMV6CY9ht)KdL(JV)GJ1RoNC)a3V0(bRFr7x9kBkmqyoDE9lMqQq2C5kx6xqOFpOdi(YgFomU)y6hG(bUFbH(LrPPH6obkxmHuXWLp9XW9lr)mv5aQYxDo5(L2Vh0beFzJphg3Ve9hf5ieju5R6lzwXiGlkIIaUOXAeGICWMlx5cc1roc7O8ooYby9hYSwssgCzCAUog5RVBscU8PpgUFj6pk16xqOFr7pKGyZnfsjYoU1VGq)I2V6v2uyjrLR8vDXq2C5kx6xqOFCIwLhRazAAu8aIVUnN(1dbUYRR5czZLRCPFG7xA)0zaf3F89hCSExMmB9ht)0zafdpDQ2V0(bRFzuAAyjrLR8vDXWssY6xA)YO00q2jxz1RPHV6IYx6mGIHLKK1VGq)QxztHyDz)SogdzZLRCPFGro8GoPHCSU4PCPNLrueWfvsIauKd2C5kxqOoYryhL3XroKrPPHIxomy(IjKkgIkUFbH(PZakUFj6pKyT)473d6Kg0NtUCXesfgsSIC4bDsd5iqyoDE9lMqQikc4aGAiaf5GnxUYfeQJCe2r5DCKdzuAAO4LddMVycPIHOI7xqOF6mGI7xI(djw7p((9GoPb95KlxmHuHHeRihEqN0qo8n4gFXesfrraharrakYbBUCLliuh5Wd6KgYbMxXSPxSogzKJWokVJJCSm9YycUCL7xA)QVKzfQZjF18wgUFj6VGUUoPHCeIeQ8v9LmRyeWffrrahaaGauKd2C5kxqOoYryhL3Xro8GoG4lB85W4(LO)OihEqN0qoK9DDYmIIaoaaseGICWMlx5cc1roc7O8ooYby9hYSwssgCzCAUog5RVBscU8PpgUFj6pk16xA)lQX05sMHy0L8yKVycPIHS5YvU0VGq)I2FibXMBkKsKDCRFbH(fTF1RSPWsIkx5R6IHS5YvU0VGq)4eTkpwbY00O4beFDBo9RhcCLxxZfYMlx5s)a3V0(PZakU)47p4y9Umz26pM(PZakgE6uTFP9dw)YO00WsIkx5R6IHLKK1VGq)QxztHyDz)SogdzZLRCPFGro8GoPHCSU4PCPNLrueWbGKgbOihS5YvUGqDKJWokVJJCiJstd1fLXesfwssgYHh0jnKdzN8nPV6obkyefbCaizeGICWMlx5cc1roc7O8ooYborRYJvGIrXkALV8IkwN0GS5YvU0V0(LrPPH6IYycPcljjd5Wd6KgYbDLXecRtRikc4aiUqakYHh0jnKdSYEjYftivKd2C5kxqOoIIOih6ogfwXiafbCrrakYbBUCLliuh5ifJCGzf5Wd6KgYbiFhxUYihG8kkJCiJstdxgNMRJr(67MKGOI7xqOFzuAAOUOmMqQquXihG89A(jJCGJyHlQyefbCaGauKd2C5kxqOoYrkg5aZkYHh0jnKdq(oUCLroa5vug5iKGyZnfsjYoU1V0(LrPPHlJtZ1XiF9DtsquX9lTFzuAAOUOmMqQquX9li0VO9hsqS5McPezh36xA)YO00qDrzmHuHOIroa5718tg5aRBAKV4iw4IkgrrahqIauKd2C5kxqOoYrkg5aZ6qJC4bDsd5aKVJlxzKdq(En)KroW6Mg5loIfUlF6JHroc7O8ooYHmknnuxugtivyjjz9lT)qcIn3uiLi74gYbiVIYxUIzKJqM1ssYG6IYycPcx(0hdJCaYROmYriZAjjzWLXP56yKV(Ujj4YN(y4(JjwE)HmRLKKb1fLXesfU8PpggrraNKgbOihS5YvUGqDKJumYbM1Hg5Wd6KgYbiFhxUYihG89A(jJCG1nnYxCelCx(0hdJCe2r5DCKdzuAAOUOmMqQquX9lT)qcIn3uiLi74gYbiVIYxUIzKJqM1ssYG6IYycPcx(0hdJCaYROmYriZAjjzWLXP56yKV(Ujj4YN(yyefbCsgbOihS5YvUGqDKJumYbM1Hg5Wd6KgYbiFhxUYihG89A(jJCGJyH7YN(yyKJWokVJJCesqS5McPezh3qoa5vu(YvmJCeYSwssguxugtiv4YN(yyKdqEfLroczwljjdUmonxhJ813njbx(0hd3VeXY7pKzTKKmOUOmMqQWLp9XWikc4IleGICWMlx5cc1ro8GoPHCO7yuynkYryhL3XroaRFDhJcRqnkKGJVOy(kJst3VGq)HeeBUPqkr2XT(L2VUJrHvOgfsWX3qM1ssY6h4(L2py9dY3XLRmeRBAKV4iw4IkUFP9dw)I2FibXMBkKsKDCRFP9lA)6ogfwHkaqco(II5RmknD)cc9hsqS5McPezh36xA)I2VUJrHvOcaKGJVHmRLKK1VGq)6ogfwHkaWqM1ssYGlF6JH7xqOFDhJcRqnkKGJVOy(kJst3V0(bRFr7x3XOWkubasWXxumFLrPP7xqOFDhJcRqnkmKzTKKmybDDDsRFjaSFDhJcRqfayiZAjjzWc666Kw)a3VGq)6ogfwHAuibhFdzwljjRFP9lA)6ogfwHkaqco(II5RmknD)s7x3XOWkuJcdzwljjdwqxxN06xca7x3XOWkubagYSwssgSGUUoP1pW9li0VO9dY3XLRmeRBAKV4iw4IkUFP9dw)I2VUJrHvOcaKGJVOy(kJst3V0(bRFDhJcRqnkmKzTKKmybDDDsRFIRFj3Fm9dY3XLRmehXc3Lp9XW9li0piFhxUYqCelCx(0hd3Ve9R7yuyfQrHHmRLKKblORRtA9tS(bOFG7xqOFDhJcRqfaibhFrX8vgLMUFP9dw)6ogfwHAuibhFrX8vgLMUFP9R7yuyfQrHHmRLKKblORRtA9lbG9R7yuyfQaadzwljjdwqxxN06xA)G1VUJrHvOgfgYSwssgSGUUoP1pX1VK7pM(b574YvgIJyH7YN(y4(fe6hKVJlxzioIfUlF6JH7xI(1DmkSc1OWqM1ssYGf011jT(jw)a0pW9li0py9lA)6ogfwHAuibhFrX8vgLMUFbH(1DmkScvaGHmRLKKblORRtA9lbG9R7yuyfQrHHmRLKKblORRtA9dC)s7hS(1DmkScvaGHmRLKKbx2lr6xA)6ogfwHkaWqM1ssYGf011jT(jU(LC)s0piFhxUYqCelCx(0hd3V0(b574YvgIJyH7YN(y4(JPFDhJcRqfayiZAjjzWc666Kw)eRFa6xqOFr7x3XOWkubagYSwssgCzVePFP9dw)6ogfwHkaWqM1ssYGlF6JH7N46xY9ht)G8DC5kdX6Mg5loIfUlF6JH7xA)G8DC5kdX6Mg5loIfUlF6JH7xI(bGA9lTFW6x3XOWkuJcdzwljjdwqxxN06N46xY9ht)G8DC5kdXrSWD5tFmC)cc9R7yuyfQaadzwljjdU8PpgUFIRFj3Fm9dY3XLRmehXc3Lp9XW9lTFDhJcRqfayiZAjjzWc666Kw)ex)rPw)X3piFhxUYqCelCx(0hd3Fm9dY3XLRmeRBAKV4iw4U8PpgUFbH(b574YvgIJyH7YN(y4(LOFDhJcRqnkmKzTKKmybDDDsRFI1pa9li0piFhxUYqCelCrf3pW9li0VUJrHvOcamKzTKKm4YN(y4(jU(LC)s0piFhxUYqSUPr(IJyH7YN(y4(L2py9R7yuyfQrHHmRLKKblORRtA9tC9l5(JPFq(oUCLHyDtJ8fhXc3Lp9XW9li0VO9R7yuyfQrHeC8ffZxzuA6(L2py9dY3XLRmehXc3Lp9XW9lr)6ogfwHAuyiZAjjzWc666Kw)eRFa6xqOFq(oUCLH4iw4IkUFG7h4(bUFG7h4(bUFbH(LtmUFP9tpKjO3Lp9XW9ht)G8DC5kdXrSWD5tFmC)a3VGq)I2VUJrHvOgfsWXxumFLrPP7xA)I2FibXMBkKsKDCRFP9dw)6ogfwHkaqco(II5RmknD)s7hS(bRFr7hKVJlxzioIfUOI7xqOFDhJcRqfayiZAjjzWLp9XW9lr)sUFG7xA)G1piFhxUYqCelCx(0hd3Ve9da16xqOFDhJcRqfayiZAjjzWLp9XW9tC9l5(LOFq(oUCLH4iw4U8PpgUFG7h4(fe6x0(1DmkScvaGeC8ffZxzuA6(L2py9lA)6ogfwHkaqco(gYSwssw)cc9R7yuyfQaadzwljjdU8PpgUFbH(1DmkScvaGHmRLKKblORRtA9lbG9R7yuyfQrHHmRLKKblORRtA9dC)aJCGRPIro0DmkSgfrraNKcbOihS5YvUGqDKdpOtAih6ogfwba5iSJY74ihG1VUJrHvOcaKGJVOy(kJst3VGq)HeeBUPqkr2XT(L2VUJrHvOcaKGJVHmRLKK1pW9lTFW6hKVJlxziw30iFXrSWfvC)s7hS(fT)qcIn3uiLi74w)s7x0(1DmkSc1Oqco(II5RmknD)cc9hsqS5McPezh36xA)I2VUJrHvOgfsWX3qM1ssY6xqOFDhJcRqnkmKzTKKm4YN(y4(fe6x3XOWkubasWXxumFLrPP7xA)G1VO9R7yuyfQrHeC8ffZxzuA6(fe6x3XOWkubagYSwssgSGUUoP1Vea2VUJrHvOgfgYSwssgSGUUoP1pW9li0VUJrHvOcaKGJVHmRLKK1V0(fTFDhJcRqnkKGJVOy(kJst3V0(1DmkScvaGHmRLKKblORRtA9lbG9R7yuyfQrHHmRLKKblORRtA9dC)cc9lA)G8DC5kdX6Mg5loIfUOI7xA)G1VO9R7yuyfQrHeC8ffZxzuA6(L2py9R7yuyfQaadzwljjdwqxxN06N46xY9ht)G8DC5kdXrSWD5tFmC)cc9dY3XLRmehXc3Lp9XW9lr)6ogfwHkaWqM1ssYGf011jT(jw)a0pW9li0VUJrHvOgfsWXxumFLrPP7xA)G1VUJrHvOcaKGJVOy(kJst3V0(1DmkScvaGHmRLKKblORRtA9lbG9R7yuyfQrHHmRLKKblORRtA9lTFW6x3XOWkubagYSwssgSGUUoP1pX1VK7pM(b574YvgIJyH7YN(y4(fe6hKVJlxzioIfUlF6JH7xI(1DmkScvaGHmRLKKblORRtA9tS(bOFG7xqOFW6x0(1DmkScvaGeC8ffZxzuA6(fe6x3XOWkuJcdzwljjdwqxxN06xca7x3XOWkubagYSwssgSGUUoP1pW9lTFW6x3XOWkuJcdzwljjdUSxI0V0(1DmkSc1OWqM1ssYGf011jT(jU(LC)s0piFhxUYqCelCx(0hd3V0(b574YvgIJyH7YN(y4(JPFDhJcRqnkmKzTKKmybDDDsRFI1pa9li0VO9R7yuyfQrHHmRLKKbx2lr6xA)G1VUJrHvOgfgYSwssgC5tFmC)ex)sU)y6hKVJlxziw30iFXrSWD5tFmC)s7hKVJlxziw30iFXrSWD5tFmC)s0pauRFP9dw)6ogfwHkaWqM1ssYGf011jT(jU(LC)X0piFhxUYqCelCx(0hd3VGq)6ogfwHAuyiZAjjzWLp9XW9tC9l5(JPFq(oUCLH4iw4U8PpgUFP9R7yuyfQrHHmRLKKblORRtA9tC9hLA9hF)G8DC5kdXrSWD5tFmC)X0piFhxUYqSUPr(IJyH7YN(y4(fe6hKVJlxzioIfUlF6JH7xI(1DmkScvaGHmRLKKblORRtA9tS(bOFbH(b574YvgIJyHlQ4(bUFbH(1DmkSc1OWqM1ssYGlF6JH7N46xY9lr)G8DC5kdX6Mg5loIfUlF6JH7xA)G1VUJrHvOcamKzTKKmybDDDsRFIRFj3Fm9dY3XLRmeRBAKV4iw4U8PpgUFbH(fTFDhJcRqfaibhFrX8vgLMUFP9dw)G8DC5kdXrSWD5tFmC)s0VUJrHvOcamKzTKKmybDDDsRFI1pa9li0piFhxUYqCelCrf3pW9dC)a3pW9dC)a3VGq)Yjg3V0(PhYe07YN(y4(JPFq(oUCLH4iw4U8PpgUFG7xqOFr7x3XOWkubasWXxumFLrPP7xA)I2FibXMBkKsKDCRFP9dw)6ogfwHAuibhFrX8vgLMUFP9dw)G1VO9dY3XLRmehXcxuX9li0VUJrHvOgfgYSwssgC5tFmC)s0VK7h4(L2py9dY3XLRmehXc3Lp9XW9lr)aqT(fe6x3XOWkuJcdzwljjdU8PpgUFIRFj3Ve9dY3XLRmehXc3Lp9XW9dC)a3VGq)I2VUJrHvOgfsWXxumFLrPP7xA)G1VO9R7yuyfQrHeC8nKzTKKS(fe6x3XOWkuJcdzwljjdU8PpgUFbH(1DmkSc1OWqM1ssYGf011jT(LaW(1DmkScvaGHmRLKKblORRtA9dC)aJCGRPIro0DmkScaIIOikYbiEXtAiGdaQbquQfRJgRroi5RngzmYbXFjbjrWfRcU4wGO)(bkbU)5uCUA)052pr6obkycPIjQ)Lj(qNLl9JZtUFhvZtx5s)bcUrMXWwKypg3FuGO)4KgiEvU0prQxztHuHO(1SFIuVYMcPcKnxUYfI6hSOufyylsShJ7haGO)4KgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKnxUYfI6hSOufyylsShJ7hibI(JtAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2C5kxiQFx7pwkUj29dwuQcmSfj2JX9lzGO)4KgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKnxUYfI6hSOufyylsShJ7pUaI(JtAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2C5kxiQFx7pwkUj29dwuQcmSfj2JX9ljbI(JtAG4v5s)ePELnfsfI6xZ(js9kBkKkq2C5kxiQFWIsvGHTiXEmU)Oudi6poPbIxLl9tK6v2uiviQFn7Ni1RSPqQazZLRCHO(blkvbg2Ie7X4(JkPbI(JtAG4v5s)ePELnfsfI6xZ(js9kBkKkq2C5kxiQFWIsvGHTiXEmU)OsAGO)4KgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKnxUYfI6hSOufyylsShJ7pQKci6poPbIxLl9tK6v2uiviQFn7Ni1RSPqQazZLRCHO(blkvbg2Ie7X4(JkPaI(JtAG4v5s)eTOgtNlzgsfI6xZ(jArnMoxYmKkq2C5kxiQFWaGQadBrI9yC)rJ1ar)Xjnq8QCPFIuVYMcPcr9Rz)ePELnfsfiBUCLle1pyrPkWWwKypg3pasgi6poPbIxLl9t0IAmDUKziviQFn7NOf1y6CjZqQazZLRCHO(DT)yP4My3pyrPkWWwKypg3paXfq0FCsdeVkx6NOf1y6CjZqQqu)A2prlQX05sMHubYMlx5cr97A)XsXnXUFWIsvGHTiXEmUFaI1ar)Xjnq8QCPFIWjAvEScKke1VM9teorRYJvGubYMlx5cr9dwuQcmSfPfH4VKGKi4IvbxClq0F)aLa3)CkoxTF6C7NOct7OvLO(xM4dDwU0pop5(DunpDLl9hi4gzgdBrI9yC)aae9hN0aXRYL(jArnMoxYmKke1VM9t0IAmDUKzivGS5YvUqu)GfLQadBrI9yC)aae9hN0aXRYL(jArnMoxYmKke1VM9t0IAmDUKzivGS5YvUqu)GfLQadBrI9yC)aae9hN0aXRYL(jkKwbDuiviQFn7NOqAf0rHubYMlx5cr9dwuQcmSfj2JX9daq0FCsdeVkx6NiCIwLhRaPcr9Rz)eHt0Q8yfivGS5YvUqu)GfLQadBrAri(ljijcUyvWf3ce93pqjW9pNIZv7No3(js8YH8u2vI6FzIp0z5s)48K73r180vU0FGGBKzmSfj2JX9dKar)Xjnq8QCPFIwuJPZLmdPcr9Rz)eTOgtNlzgsfiBUCLle1VR9hlf3e7(blkvbg2Ie7X4(L0ar)Xjnq8QCPFIuVYMcPcr9Rz)ePELnfsfiBUCLle1VR9hlf3e7(blkvbg2Ie7X4(Luar)Xjnq8QCPFIuVYMcPcr9Rz)ePELnfsfiBUCLle1pyrPkWWwKypg3FSgi6poPbIxLl9tK6v2uiviQFn7Ni1RSPqQazZLRCHO(blkvbg2I0Iq8xsqseCXQGlUfi6VFGsG7FofNR2pDU9tewjQ)Lj(qNLl9JZtUFhvZtx5s)bcUrMXWwKypg3FuGO)4KgiEvU0prQxztHuHO(1SFIuVYMcPcKnxUYfI6hSOufyylsShJ7xsde9hN0aXRYL(jArnMoxYmKke1VM9t0IAmDUKzivGS5YvUqu)U2FSuCtS7hSOufyylsShJ7xYar)Xjnq8QCPFIwuJPZLmdPcr9Rz)eTOgtNlzgsfiBUCLle1pyrPkWWwKypg3F0Oar)Xjnq8QCPFIuVYMcPcr9Rz)ePELnfsfiBUCLle1pyrPkWWwKypg3FuaaI(JtAG4v5s)ePELnfsfI6xZ(js9kBkKkq2C5kxiQFWIsvGHTiXEmU)Oajq0FCsdeVkx6Ni1RSPqQqu)A2prQxztHubYMlx5cr9dwuQcmSfj2JX9hvsde9hN0aXRYL(js9kBkKke1VM9tK6v2uivGS5YvUqu)Gbavbg2Ie7X4(JkPbI(JtAG4v5s)eHt0Q8yfiviQFn7NiCIwLhRaPcKnxUYfI6hSOufyylsShJ7pQKbI(JtAG4v5s)ePELnfsfI6xZ(js9kBkKkq2C5kxiQFWIsvGHTiXEmU)OXfq0FCsdeVkx6Ni1RSPqQqu)A2prQxztHubYMlx5cr9dgaufyylsShJ7pACbe9hN0aXRYL(jArnMoxYmKke1VM9t0IAmDUKzivGS5YvUqu)GfLQadBrI9yC)rJlGO)4KgiEvU0pr4eTkpwbsfI6xZ(jcNOv5XkqQazZLRCHO(blkvbg2Ie7X4(JkPaI(JtAG4v5s)ePELnfsfI6xZ(js9kBkKkq2C5kxiQFWIsvGHTiXEmU)OXAGO)4KgiEvU0prQxztHuHO(1SFIuVYMcPcKnxUYfI6hmaOkWWwKypg3F0ynq0FCsdeVkx6NiCIwLhRaPcr9Rz)eHt0Q8yfivGS5YvUqu)GfLQadBrI9yC)aaKar)Xjnq8QCPFIuVYMcPcr9Rz)ePELnfsfiBUCLle1pyaqvGHTiXEmUFaasGO)4KgiEvU0prlQX05sMHuHO(1SFIwuJPZLmdPcKnxUYfI6hSOufyylsShJ7haGei6poPbIxLl9teorRYJvGuHO(1SFIWjAvEScKkq2C5kxiQFWIsvGHTiXEmUFaKmq0FCsdeVkx6NiCIwLhRaPcr9Rz)eHt0Q8yfivGS5YvUqu)GfLQadBrakbUF6SwtsJrUFhDDC)K4L7hfZL(hRFLa3Vh0jT(Rdw7xgv7NeVC)wQ9tNOwP)X6xjW97LsA9xC1LDmdeTi9tC9Zo5kREnn8vxu(sNbuClslcXFjbjrWfRcU4wGO)(bkbU)5uCUA)052pr6ogfwXe1)YeFOZYL(X5j3VJQ5PRCP)ab3iZyylsShJ7pUaI(JtAG4v5s)hZzC6hhXuNQ9t82VM9hBuV)YaAWtA9NI511C7hmIbC)GjzQcmSfj2JX9hxar)Xjnq8QCPFI0DmkScJcPcr9Rz)eP7yuyfQrHuHO(bdGOufyylsShJ7pUaI(JtAG4v5s)eP7yuyfcaKke1VM9tKUJrHvOcaKke1pyaexufyylsShJ7xsbe9hN0aXRYL(pMZ40poIPov7N4TFn7p2OE)Lb0GN06pfZRR52pyed4(btYufyylsShJ7xsbe9hN0aXRYL(js3XOWkmkKke1VM9tKUJrHvOgfsfI6hmaIlQcmSfj2JX9lPaI(JtAG4v5s)eP7yuyfcaKke1VM9tKUJrHvOcaKke1pyaeLQadBrArIvpfNRYL(JR(9GoP1FDWkg2IGCGfZbeWbGKL0ihI3KEQmYrSiw0pXJ(sbF6gMWiU)yzqnL3wKyrSOFjbuYOyTFaasW3paudGOTiTiXIyr)XHGBKzmq0IelIf9tC9doMeDIAL(LezCwbX9p4(Tu737)KdeCBc9Re4(9sjT(dUrmstT2)PBozg2IelIf9tC9ljY4iwGl97LsA9lENChns)KgLq)hZzC6xsiwrSHTiXIyr)ex)XM1(JLnYoUH7VW4iwOFLapB)XH4hUFCEY6CYyylslIh0jnmu8YH8u214bKyYPQvUCPREeUqAmYxnP6yTiEqN0WqXlhYtzxJhqIrxzmHW60AlIh0jnmu8YH8u214bKyQVxDDXGFObCrnMoxYmeNOv6CjZx(uMxClIh0jnmu8YH8u214bKyLevUYx1fdEXlhCSE15Kbmk1a)qdOh0beFzJphglrubbrdji2CtHuISJBsfv9kBkeuwRCKwKyr)XHGBK5(1S)O9Rz)45eT6k3FSeqJvsSJJyL9tM9ftYf3pqxugti1(fVCWXkSfXd6KggkE5qEk7A8asmq(oUCLbV5NmGSsFfVCWXk4b5vugWktMTIVrGStUYQxtdF1fLV0zafdzZLRCrkMvDmYyi7KRS610UysUyiBUCLlTiEqN0WqXlhYtzxJhqIPlkJjKk4hAab574YvgYk9v8YbhRTiEqN0WqXlhYtzxJhqI5ZjxUycPc(HgqpOdi(YgFomogGukyIgsqS5McPezh3KkQ6v2uiOSw5iccEqhq8Ln(CyCmaaSurb574YvgYk9v8YbhRTiEqN0WqXlhYtzxJhqIHv2lrUycPc(HgqpOdi(YgFomwcaeealKGyZnfsjYoUjiOELnfckRvocWs9GoG4lB85WyabqqaKVJlxziR0xXlhCS2I0I4bDsdhpGelKOMY7fti1wepOtA44bKyHe1uEVycPc(6y8nuaeiPg4hAaxuJPZLmdXSycOXD8v8MHQF66KMGaorRYJvG2eXXxnZk(kohCAccGfsRGokCzq8I96nPV05QOglv0f1y6CjZqmlMaAChFfVzO6NUoPbClsSO)42SFNa7L(DR0pqx3i(qN6e35(bxSI40pB85WyIh2pjU)sAeP9xY(vcdUF6C7xC1JWlUFzo4OyU)rjQ0Vm3VMz)yX(5zK(DR0pjU)GBeP9VSxMAK(b66gXx)yXCyONq)YO00yylIh0jnC8asmDDJ4dDQtCFmYxmHub)qdOOQVKzfo4R4QhH3wepOtA44bKybVwVEqN0U1bRG38tgqDhJcRyWp0agsqS5McPezh3KgYSwssguxugtiv4YN(yyPHmRLKKbxgNMRJr(67MKGlF6JHfeenKGyZnfsjYoUjnKzTKKmOUOmMqQWLp9XWTiXIyr)e)4QhPFApmg5(JKOB)Levw7h10P2FKeTFcoiUFXOA)sImonxhJC)sc7MK6VKKmW3FU9p09Re4(dzwljjR)b3VMz)10i3VM9x4QhPFApmg5(JKOB)e)suzf2FSkD)wAC)jD)kbgZ9hsRm6KgUFF5(D5k3VM9FYA)KgLWy9Re4(JsT(XCiTcU)kZK8iGVFLa3pEo7N2dmU)ij62pXVevw73r1801j41AeylsSiw0Vh0jnC8asmJjrNOw5UmoRGyWp0aIt0Q8yfOXKOtuRCxgNvqSuWKrPPHlJtZ1XiF9DtsquXccHmRLKKbxgNMRJr(67MKGlF6JHLik1eeOhYe07YN(y4yIgxa3I4bDsdhpGel4161d6K2Toyf8MFYagk4wepOtA44bKybVwVEqN0U1bRG38tgqSc(HgqpOdi(YgFomogGSfXd6KgoEajwWR1Rh0jTBDWk4n)Kbu3jqbtivm4hAa9GoG4lB85WyjaOfPfXd6KgggkyaL5fZlLXid(HgqWKrPPH6IYycPcrflvgLMgUmonxhJ813njbrflnKGyZnfsjYoUbSGayYO00qDrzmHuHOILkJstdjn1YflE2rXquXsdji2CtH2qMGEPDgybbWcji2CtHGytjezfecji2CtHgh2SMBbyPYO00qDrzmHuHOIfeKtmwk9qMGEx(0hdhtuGuqaSqcIn3uiLi74MuzuAA4Y40CDmYxF3KeevSu6Hmb9U8PpgogjfqcClIh0jnmmuWXdiXKRzwU0OBeWp0akJstd1fLXesfIkwqiKzTKKmOUOmMqQWLp9XWsaKutqqoXyP0dzc6D5tFmCmrJRwepOtAyyOGJhqI5wGX661BWRvWp0akJstd1fLXesfIkwqiKzTKKmOUOmMqQWLp9XWsaKutqqoXyP0dzc6D5tFmCmrJRwepOtAyyOGJhqIrpllxZSa(HgqzuAAOUOmMqQquXccHmRLKKb1fLXesfU8PpgwcGKAccYjglLEitqVlF6JHJrs2I4bDsdddfC8asS6qMGIVepaTq(Knf8dnGYO00qDrzmHuHLKK1I4bDsdddfC8asmXPoPb(HgqzuAAOUOmMqQquXsbtgLMgkxZSurXkevSGG6lzwHeyVQeGIdAmaqnGfeKtmwk9qMGEx(0hdhdaXLGayHeeBUPqkr2XnPYO00WLXP56yKV(UjjiQyP0dzc6D5tFmCmskaaUfPfXd6KggIvaXk7LixmHub)qdO6v2uiwzVe5sNbuSuWeVmOl5qbgfIv2lrUycPkvgLMgIv2lrU0zafdx(0hdhJKfeKrPPHyL9sKlDgqXWssYawkyYO00WLXP56yKV(UjjyjjzccIgsqS5McPezh3aUfXd6KggI14bKyuMA9IjKAlIh0jnmeRXdiXkjQCLVQlg8dnGGfsqS5McPezh3KcwiZAjjzWLXP56yKV(Ujj4YN(y4yihkaliiAibXMBkKsKDCtQOHeeBUPqBitqV0oliesqS5McTHmb9s7SuWczwljjdsAQLlw8SJIHlF6JHJHCOiieYSwssgK0ulxS4zhfdx(0hdlbqsnGfeOhYe07YN(y4yIkzGLcMORpLldInf6LcgYuDWkwqy9PCzqSPqVuWquXsbB9PCzqSPqVuWWXIjk1KU(uUmi2uOxky4YN(y4yasbH1NYLbXMc9sbdhtIqM1ssYee8GoG4lB85WyjIcSGGORpLldInf6LcgIkwkyRpLldInf6LcggsutbmQGW6t5YGytHEPGHJjriZAjjzadClIh0jnmeRXdiXOR(YGFObu99QRlgIkw6IAmDUKziorR05sMV8PmV4wepOtAyiwJhqIP(E11fd(HgWf1y6CjZqCIwPZLmF5tzEXsvFV66IHlF6JHJHCOinKzTKKmiD1xgU8PpgogYHslIh0jnmeRXdiXyQkUM4beFXesTfXd6KggI14bKyKMA5Ifp7OyWp0ak66t5YGytHEPGHmvhSIfeeD9PCzqSPqVuWquXsxFkxgeBk0lfmSGUUoPf)6t5YGytHEPGHJfdautqy9PCzqSPqVuWquXsxFkxgeBk0lfmC5tFmSerLKccEqhq8Ln(CySerBr8GoPHHynEajgD1JWLlMqQTiEqN0WqSgpGeRWUs4gi4uw)e8dnG0zafhFWX6DzYSfdDgqXWtNQTiEqN0WqSgpGeZVNOBH3BsFdBsc3I4bDsddXA8asms(uhJ813njb(HgWqM1ssYGlJtZ1XiF9DtsWLp9XWXqouKcMOQxztHmvfxt8aIVycPkiiJstdLRzwQOyfIkgybbrdji2CtHuISJBccHmRLKKbxgNMRJr(67MKGlF6JHfeKtmwk9qMGEx(0hdhJKBr8GoPHHynEaj2Y40CDmYxF3Ke4hAabtgLMgwsu5kFvxmevSGqiZAjjzWsIkx5R6IHlF6JHLik1eeev9kBkSKOYv(QUybb6Hmb9U8PpgoMOaaSuWeD9PCzqSPqVuWqMQdwXccIU(uUmi2uOxkyiQyPGT(uUmi2uOxkyybDDDsl(1NYLbXMc9sbdhlMOutqy9PCzqSPqVuWWqIAkGrbwqy9PCzqSPqVuWquXsxFkxgeBk0lfmC5tFmSessbbpOdi(YgFomwIOa3I4bDsddXA8asmqzTYra)qdOmknnCzCAUog5RVBscIkwqiKzTKKm4Y40CDmYxF3KeC5tFmSerPMGGOHeeBUPqkr2XnPGjJstdfVCyW8ftivmSKKmbbrvVYMcdeMtNx)IjKQGGh0beFzJphghdaa3I4bDsddXA8asmSYEjYftivWp0agsqS5McPezh3KsNbuC8bhR3LjZwm0zafdpDQkfmWczwljjdUmonxhJ813njbx(0hdhd5qH4jqkfmrXjAvEScKPPrXdi(62C6xpe4kVUMRGGOQxztHLevUYx1fdmWccQxztHLevUYx1flnKzTKKmyjrLR8vDXWLp9XWXaKa3I4bDsddXA8asmDrzmHub)qdOmknnu8YHbZxmHuXWssYKcwibXMBkeeBkHiRGqibXMBk04WM1ClccQxztHbVwhJ8vjWxmHuXaliiJstdxgNMRJr(67MKGOIfeczwljjdUmonxhJ813njbx(0hdlruQjiiJstdjn1YflE2rXquXccYO00qqzTYrGOIL6bDaXx24ZHXsevqqoXyP0dzc6D5tFmCmai5wepOtAyiwJhqITU4PCPNLb)qd4IAmDUKzigDjpg5lMqQyPQxztHyDz)SoglfSqM1ssYGlJtZ1XiF9DtsWLp9XWseLAccIgsqS5McPezh3eeev9kBkSKOYv(QUybbCIwLhRazAAu8aIVUnN(1dbUYRR5cClIh0jnmeRXdiX85KlxmHubFisOYx1xYSIbmk4hAaLrPPHIxomy(IjKkgwssMGayYO00qDrzmHuHOIfeOrR17Ybc(sMV6CYXqouIp4y9QZjdSuWev9kBkmqyoDE9lMqQccEqhq8Ln(CyCmaaSGGmknnu3jq5IjKkgU8PpgwcMQCav5RoNSupOdi(YgFomwIOTiEqN0WqSgpGeBDXt5spld(HgqWczwljjdUmonxhJ813njbx(0hdlruQjiiAibXMBkKsKDCtqqu1RSPWsIkx5R6IfeWjAvEScKPPrXdi(62C6xpe4kVUMlWsPZako(GJ17YKzlg6mGIHNovLcMmknnSKOYv(QUyyjjzsLrPPHStUYQxtdF1fLV0zafdljjtqq9kBkeRl7N1XyGBr8GoPHHynEajwGWC686xmHub)qdOmknnu8YHbZxmHuXquXcc0zaflriXA8EqN0G(CYLlMqQWqI1wepOtAyiwJhqI5BWn(IjKk4hAaLrPPHIxomy(IjKkgIkwqGodOyjcjwJ3d6Kg0NtUCXesfgsS2I4bDsddXA8asmmVIztVyDmYGpeju5R6lzwXagf8dnGltVmMGlxzPQVKzfQZjF18wgwIc666KwlIh0jnmeRXdiXK9DDYm4hAa9GoG4lB85WyjI2I4bDsddXA8asS1fpLl9Sm4hAablKzTKKm4Y40CDmYxF3KeC5tFmSerPM0f1y6CjZqm6sEmYxmHuXccIgsqS5McPezh3eeev9kBkSKOYv(QUybbCIwLhRazAAu8aIVUnN(1dbUYRR5cSu6mGIJp4y9Umz2IHodOy4PtvPGjJstdljQCLVQlgwssMGG6v2uiwx2pRJXa3I4bDsddXA8asmzN8nPV6obkyWp0akJstd1fLXesfwsswlIh0jnmeRXdiXORmMqyDAf8dnG4eTkpwbkgfROv(YlQyDstQmknnuxugtivyjjzTiEqN0WqSgpGedRSxICXesTfPfXd6KggQ7eOGjKkgqSYEjYftivWp0aQELnfIv2lrU0zaflDSlDDitqLkJstdXk7Lix6mGIHlF6JHJrYTiEqN0WqDNafmHuXXdiXOm16ftivWp0aUOgtNlzgkordeUj9D94EUx61jFYMILkJstdPREeEX3tFParf3I4bDsdd1DcuWesfhpGeJU6r4YftivWp0aUOgtNlzgkordeUj9D94EUx61jFYMIBr8GoPHH6obkycPIJhqIvsu5kFvxm4hAablKGyZnfsjYoUjnKzTKKm4Y40CDmYxF3KeC5tFmCmKdfbbrdji2CtHuISJBsfnKGyZnfAdzc6L2zbHqcIn3uOnKjOxANLcwiZAjjzqstTCXINDumC5tFmCmKdfbHqM1ssYGKMA5Ifp7Oy4YN(yyjasQbSGG6lzwH6CYxnVLHJjk1eeczwljjdUmonxhJ813njbx(0hdlruQj1d6aIVSXNdJLaibwkyIU(uUmi2uOxkyit1bRybH1NYLbXMc9sbdx(0hdlHKuqq0qcIn3uiLi74gWTiEqN0WqDNafmHuXXdiXuFV66Ib)qd4IAmDUKziorR05sMV8PmVyPQVxDDXWLp9XWXqouKgYSwssgKU6ldx(0hdhd5qPfXd6KggQ7eOGjKkoEajgD1xg81X4BOaiasg8dnGQVxDDXquXsxuJPZLmdXjALoxY8LpL5f3I4bDsdd1DcuWesfhpGeJPQ4AIhq8fti1wepOtAyOUtGcMqQ44bKyKMA5Ifp7OyWp0ak66t5YGytHEPGHmvhSIfewFkxgeBk0lfmC5tFmSerPMGGh0beFzJphglbGRpLldInf6LcggsutjEcqlIh0jnmu3jqbtivC8asms(uhJ813njb(HgWqM1ssYGlJtZ1XiF9DtsWLp9XWXqouKcMOQxztHmvfxt8aIVycPkiiJstdLRzwQOyfIkgybbrdji2CtHuISJBccHmRLKKbxgNMRJr(67MKGlF6JHLik1eeKtmwk9qMGEx(0hdhJKBr8GoPHH6obkycPIJhqITmonxhJ813njb(HgqWczwljjdckRvocC5tFmCmKdfbbrvVYMcbL1khrqq9LmRqDo5RM3YWXefaGLcMORpLldInf6LcgYuDWkwqy9PCzqSPqVuWWLp9XWsijfe8GoG4lB85WyjaC9PCzqSPqVuWWqIAkXtaaUfXd6KggQ7eOGjKkoEajgOSw5iGFObugLMgUmonxhJ813njbrflieYSwssgCzCAUog5RVBscU8PpgwIOutqq0qcIn3uiLi74wlIh0jnmu3jqbtivC8asmzFxNm3I4bDsdd1DcuWesfhpGetxugtivWp0akJstdxgNMRJr(67MKGOIfeczwljjdUmonxhJ813njbx(0hdlruQjiiAibXMBkKsKDCtqqoXyP0dzc6D5tFmCmaqTwepOtAyOUtGcMqQ44bKyRlEkx6zzWp0aUOgtNlzgIrxYJr(IjKkwkyHmRLKKbxgNMRJr(67MKGlF6JHLik1eeenKGyZnfsjYoUjiiQ6v2uyjrLR8vDXalvgLMgQ7eOCXesfdx(0hdlbGmv5aQYxDo5wepOtAyOUtGcMqQ44bKy(CYLlMqQGpeju5R6lzwXagf8dnGYO00qDNaLlMqQy4YN(yyjaKPkhqv(QZjlfmzuAAO4LddMVycPIHLKKjiqJwR3Lde8LmF15KJj4y9QZjhp5qrqqgLMgQlkJjKkevmWTiEqN0WqDNafmHuXXdiXkSReUbcoL1pb)qdiDgqXXhCSExMmBXqNbum80PAlIh0jnmu3jqbtivC8asS1fpLl9Sm4hAablKzTKKm4Y40CDmYxF3KeC5tFmSerPM0f1y6CjZqm6sEmYxmHuXccIgsqS5McPezh3eeeDrnMoxYmeJUKhJ8ftivSGGOQxztHLevUYx1fdSuzuAAOUtGYftivmC5tFmSeaYuLdOkF15KBr8GoPHH6obkycPIJhqIDIw1btivWp0akJstd1DcuUycPIHLKKjiiJstdfVCyW8ftivmevSu6mGILiKynEpOtAqFo5YftivyiXQuWev9kBkmqyoDE9lMqQccEqhq8Ln(CySeajWTiEqN0WqDNafmHuXXdiXceMtNx)IjKk4hAaLrPPHIxomy(IjKkgIkwkDgqXsesSgVh0jnOpNC5IjKkmKyvQh0beFzJphghJKUfXd6KggQ7eOGjKkoEajgLPwVycPc(HgqzuAAyH9YLJWWssYAr8GoPHH6obkycPIJhqI53t0TW7nPVHnjHBr8GoPHH6obkycPIJhqIrx9iC5IjKAlIh0jnmu3jqbtivC8asmmVIztVyDmYGpeju5R6lzwXagf8dnGltVmMGlx5wepOtAyOUtGcMqQ44bKyNOvDWesf8dnG0zaflriXA8EqN0G(CYLlMqQWqIvPGfYSwssgCzCAUog5RVBscU8PpgwcjliiAibXMBkKsKDCd4wepOtAyOUtGcMqQ44bKyQVxDDXGFObCrnMoxYm0ymEmYK8nc(QRlw8yKVUyX(6kkUfXd6KggQ7eOGjKkoEajg9YCCFmYxDDXGFObCrnMoxYm0ymEmYK8nc(QRlw8yKVUyX(6kkUfXd6KggQ7eOGjKkoEajMSt(M0xDNafm4hAaLrPPH6IYycPcljjRfXd6KggQ7eOGjKkoEajgDLXecRtRGFObeNOv5XkqXOyfTYxErfRtAsLrPPH6IYycPcljjRfXd6KggQ7eOGjKkoEajgwzVe5IjKAlslIh0jnmu3XOWkgqq(oUCLbV5NmG4iw4Ikg8G8kkdOmknnCzCAUog5RVBscIkwqqgLMgQlkJjKkevClIh0jnmu3XOWkoEajgiFhxUYG38tgqSUPr(IJyHlQyWdYROmGHeeBUPqkr2XnPYO00WLXP56yKV(UjjiQyPYO00qDrzmHuHOIfeenKGyZnfsjYoUjvgLMgQlkJjKkevClIh0jnmu3XOWkoEajgiFhxUYG38tgqSUPr(IJyH7YN(yyWNIbeZ6qdEqEfLbmKzTKKm4Y40CDmYxF3KeC5tFmCmXYdzwljjdQlkJjKkC5tFmm4b5vu(YvmdyiZAjjzqDrzmHuHlF6JHb)qdOmknnuxugtivyjjzsdji2CtHuISJBTiEqN0WqDhJcR44bKyG8DC5kdEZpzaX6Mg5loIfUlF6JHbFkgqmRdn4b5vugWqM1ssYGlJtZ1XiF9DtsWLp9XWGhKxr5lxXmGHmRLKKb1fLXesfU8Ppgg8dnGYO00qDrzmHuHOILgsqS5McPezh3Ar8GoPHH6ogfwXXdiXa574Yvg8MFYaIJyH7YN(yyWNIbeZ6qd(HgWqcIn3uiLi74g4b5vugWqM1ssYGlJtZ1XiF9DtsWLp9XWselpKzTKKmOUOmMqQWLp9XWGhKxr5lxXmGHmRLKKb1fLXesfU8PpgUfXd6KggQ7yuyfhpGedfZ3r5tm4X1uXaQ7yuynk4hAabt3XOWkmkKGJVOy(kJstliesqS5McPezh3KQ7yuyfgfsWX3qM1ssYawkyG8DC5kdX6Mg5loIfUOILcMOHeeBUPqkr2XnPIQ7yuyfcaKGJVOy(kJstliesqS5McPezh3KkQUJrHviaqco(gYSwssMGGUJrHviaWqM1ssYGlF6JHfe0DmkScJcj44lkMVYO00sbtuDhJcRqaGeC8ffZxzuAAbbDhJcRWOWqM1ssYGf011jnjau3XOWkeayiZAjjzWc666KgWcc6ogfwHrHeC8nKzTKKmPIQ7yuyfcaKGJVOy(kJstlv3XOWkmkmKzTKKmybDDDstca1DmkScbagYSwssgSGUUoPbSGGOG8DC5kdX6Mg5loIfUOILcMO6ogfwHaaj44lkMVYO00sbt3XOWkmkmKzTKKmybDDDsJ4KCmG8DC5kdXrSWD5tFmSGaiFhxUYqCelCx(0hdlHUJrHvyuyiZAjjzWc666KgXlaaliO7yuyfcaKGJVOy(kJstlfmDhJcRWOqco(II5RmknTuDhJcRWOWqM1ssYGf011jnjau3XOWkeayiZAjjzWc666KMuW0DmkScJcdzwljjdwqxxN0iojhdiFhxUYqCelCx(0hdliaY3XLRmehXc3Lp9XWsO7yuyfgfgYSwssgSGUUoPr8caWccGjQUJrHvyuibhFrX8vgLMwqq3XOWkeayiZAjjzWc666KMeaQ7yuyfgfgYSwssgSGUUoPbSuW0DmkScbagYSwssgCzVerQUJrHviaWqM1ssYGf011jnItYsaY3XLRmehXc3Lp9XWsb574YvgIJyH7YN(y4y0DmkScbagYSwssgSGUUoPr8cGGGO6ogfwHaadzwljjdUSxIifmDhJcRqaGHmRLKKbx(0hdtCsogq(oUCLHyDtJ8fhXc3Lp9XWsb574YvgI1nnYxCelCx(0hdlbautky6ogfwHrHHmRLKKblORRtAeNKJbKVJlxzioIfUlF6JHfe0DmkScbagYSwssgC5tFmmXj5ya574YvgIJyH7YN(yyP6ogfwHaadzwljjdwqxxN0iUOulEq(oUCLH4iw4U8Ppgogq(oUCLHyDtJ8fhXc3Lp9XWccG8DC5kdXrSWD5tFmSe6ogfwHrHHmRLKKblORRtAeVaiiaY3XLRmehXcxuXaliO7yuyfcamKzTKKm4YN(yyItYsaY3XLRmeRBAKV4iw4U8Ppgwky6ogfwHrHHmRLKKblORRtAeNKJbKVJlxziw30iFXrSWD5tFmSGGO6ogfwHrHeC8ffZxzuAAPGbY3XLRmehXc3Lp9XWsO7yuyfgfgYSwssgSGUUoPr8cGGaiFhxUYqCelCrfdmWadmWaliiNySu6Hmb9U8Ppgogq(oUCLH4iw4U8Ppggybbr1DmkScJcj44lkMVYO00sfnKGyZnfsjYoUjfmDhJcRqaGeC8ffZxzuAAPGbMOG8DC5kdXrSWfvSGGUJrHviaWqM1ssYGlF6JHLqYalfmq(oUCLH4iw4U8PpgwcaOMGGUJrHviaWqM1ssYGlF6JHjojlbiFhxUYqCelCx(0hddmWccIQ7yuyfcaKGJVOy(kJstlfmr1DmkScbasWX3qM1ssYee0DmkScbagYSwssgC5tFmSGGUJrHviaWqM1ssYGf011jnjau3XOWkmkmKzTKKmybDDDsdyGBr8GoPHH6ogfwXXdiXqX8Du(edECnvmG6ogfwba8dnGGP7yuyfcaKGJVOy(kJstliesqS5McPezh3KQ7yuyfcaKGJVHmRLKKbSuWa574YvgI1nnYxCelCrflfmrdji2CtHuISJBsfv3XOWkmkKGJVOy(kJstliesqS5McPezh3KkQUJrHvyuibhFdzwljjtqq3XOWkmkmKzTKKm4YN(yybbDhJcRqaGeC8ffZxzuAAPGjQUJrHvyuibhFrX8vgLMwqq3XOWkeayiZAjjzWc666KMeaQ7yuyfgfgYSwssgSGUUoPbSGGUJrHviaqco(gYSwssMur1DmkScJcj44lkMVYO00s1DmkScbagYSwssgSGUUoPjbG6ogfwHrHHmRLKKblORRtAaliikiFhxUYqSUPr(IJyHlQyPGjQUJrHvyuibhFrX8vgLMwky6ogfwHaadzwljjdwqxxN0iojhdiFhxUYqCelCx(0hdliaY3XLRmehXc3Lp9XWsO7yuyfcamKzTKKmybDDDsJ4faGfe0DmkScJcj44lkMVYO00sbt3XOWkeaibhFrX8vgLMwQUJrHviaWqM1ssYGf011jnjau3XOWkmkmKzTKKmybDDDstky6ogfwHaadzwljjdwqxxN0iojhdiFhxUYqCelCx(0hdliaY3XLRmehXc3Lp9XWsO7yuyfcamKzTKKmybDDDsJ4faGfeatuDhJcRqaGeC8ffZxzuAAbbDhJcRWOWqM1ssYGf011jnjau3XOWkeayiZAjjzWc666KgWsbt3XOWkmkmKzTKKm4YEjIuDhJcRWOWqM1ssYGf011jnItYsaY3XLRmehXc3Lp9XWsb574YvgIJyH7YN(y4y0DmkScJcdzwljjdwqxxN0iEbqqquDhJcRWOWqM1ssYGl7Lisbt3XOWkmkmKzTKKm4YN(yyItYXaY3XLRmeRBAKV4iw4U8PpgwkiFhxUYqSUPr(IJyH7YN(yyjaGAsbt3XOWkeayiZAjjzWc666KgXj5ya574YvgIJyH7YN(yybbDhJcRWOWqM1ssYGlF6JHjojhdiFhxUYqCelCx(0hdlv3XOWkmkmKzTKKmybDDDsJ4IsT4b574YvgIJyH7YN(y4ya574YvgI1nnYxCelCx(0hdliaY3XLRmehXc3Lp9XWsO7yuyfcamKzTKKmybDDDsJ4fabbq(oUCLH4iw4IkgybbDhJcRWOWqM1ssYGlF6JHjojlbiFhxUYqSUPr(IJyH7YN(yyPGP7yuyfcamKzTKKmybDDDsJ4KCmG8DC5kdX6Mg5loIfUlF6JHfeev3XOWkeaibhFrX8vgLMwkyG8DC5kdXrSWD5tFmSe6ogfwHaadzwljjdwqxxN0iEbqqaKVJlxzioIfUOIbgyGbgyGfeKtmwk9qMGEx(0hdhdiFhxUYqCelCx(0hddSGGO6ogfwHaaj44lkMVYO00sfnKGyZnfsjYoUjfmDhJcRWOqco(II5RmknTuWatuq(oUCLH4iw4Ikwqq3XOWkmkmKzTKKm4YN(yyjKmWsbdKVJlxzioIfUlF6JHLaaQjiO7yuyfgfgYSwssgC5tFmmXjzja574YvgIJyH7YN(yyGbwqquDhJcRWOqco(II5RmknTuWev3XOWkmkKGJVHmRLKKjiO7yuyfgfgYSwssgC5tFmSGGUJrHvyuyiZAjjzWc666KMeaQ7yuyfcamKzTKKmybDDDsdyGruefbba]] )


end