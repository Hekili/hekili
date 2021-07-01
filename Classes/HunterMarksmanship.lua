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


    spec:RegisterPack( "Marksmanship", 20210701, [[d8etacqisupcbrDjeeAtKQ(ecmkqvNcuzvscWRKenlvc3cjr7cYVuPQHjj0XOkTmjPNHG00qsW1qqTnvI4Bsc04qsOoNKGQ1PsLENKGsnpQIUNkP9rv4FscOoiccSqKKEOkvmrvIK6IscsBusqXhvjsmsjbLCsjbXkjrMPkrDtvIKStvk9teeXqLeqAPiiONsvnvvk(kcI0yrszVQ4VQQbdCyHftspMktwvUmQnJuFgrnAq50kwTKaIxJqZwIBlP2nLFlA4KWXvjsTCLEoutN46GSDK47iY4rs15jvwpscz(KY(L6J3Znh)xi852QvSQ3kwbROxufPIRsf8s4JVOtbF8veoIbz(4BrnF8VuflrCDyyyJIJVIqxjJ35MJpoHwhF8jKBamruGV793tEeyqQixwFpEQHkHmP52GwUhp1U7p(QqtrQqSJ6X)fcFUTAfR6TIvWk6fvrQ4QubVe6XpGey5E89N67C8HnVhBh1J)JXUJ)LQyjIRdddBu0GkSGmH3wjLGk6AG3lAq1kw17XVmybFU54l74iIHLc(CZ5wVNBo(SfQf(DO6X3TJW7ehFjkSjiSWXt3NoDqyeBHAHFnqFdg7txgYWKgOVbQq00iSWXt3NoDqy0Y1Xy4g4zdi8XpCYK2XhlC809XWs5iNBREU54ZwOw43HQhF3ocVtC8Djf2ctqe1TtynqFdCzwEjjdTmoTqgJ8p2njHwUogd3apBaz3RbAAnq5g4skSfMGiQBNWAG(gOCdCjf2ctq2qgM8PdUbAAnWLuylmbzdzyYNo4gOVbW3axMLxsYqKMY7Jvm7iy0Y1Xy4g4zdi7EnqtRbUmlVKKHinL3hRy2rWOLRJXWnWJgqOvSbW1anTgiXsMfKm18xY)B4g4zd8wXgOP1axMLxsYqlJtlKXi)JDtsOLRJXWnWJg4TInqFdcNmu4pBC9W4g4rdi0JF4KjTJ)lHul8xcfh5ClHEU54ZwOw43HQhF3ocVtC8xiJPZLmJWjuHoxY8NRv5fJylul8Rb6BGe7x2qbA56ymCd8SbKDVgOVbUmlVKKHOlXYOLRJXWnWZgq29o(HtM0o(sSFzdfh5Clv4CZXNTqTWVdvp(HtM0o(0Ly5JVBhH3jo(sSFzdfiifnqFdwiJPZLmJWjuHoxY8NRv5fJylul874xgJ)U3XVkHpY5wcFU54hozs74ZuxrjXdf(JHLYXNTqTWVdvpY52l5CZXpCYK2XN0uEFSIzhbF8zlul87q1JCUTcEU54ZwOw43HQhF3ocVtC8DzwEjjdTmoTqgJ8p2njHwUogd3apBaz3Rb6Ba8nq5girHnbXuxrjXdf(JHLcITqTWVgOP1aviAAKAjZxbcliifnaUgOP1aLBGlPWwycIOUDcRbAAnWLz5LKm0Y40czmY)y3KeA56ymCd8ObERyd00AGAIXnqFdOhYWK)Y1Xy4g4zdi8XpCYK2XNumLXi)JDtsh5Clv85MJpBHAHFhQE8D7i8oXXxfIMg9si1c)Lqbcsrd00AGYnqIcBc6LqQf(lHceBHAHFnqtRbQjg3a9nGEidt(lxhJHBGNnWB1JF4KjTJ)Y40czmY)y3K0ro3wHFU54ZwOw43HQhF3ocVtC8vHOPrlJtlKXi)JDtsiifnqtRbk3axsHTWeerD7e2XpCYK2XNswkSUJCU1Bfp3C8dNmPD8vJDdY8XNTqTWVdvpY5wVEp3C8dNmPD8LfIXWs54ZwOw43HQh5CR3QNBo(SfQf(DO6X3TJW7eh)fYy6CjZim0sEmYFmSuWi2c1c)AG(gaFdCzwEjjdTmoTqgJ8p2njHwUogd3apAG3k2anTgOCdCjf2ctqe1TtynqtRbk3ajkSjOxcPw4VekqSfQf(1a4AG(gOcrtJKDCe)yyPGrlxhJHBGhxBatD2bj8xMA(4hozs74VHI59PNLpY5wVe65MJpBHAHFhQE8dNmPD8JPMFFmSuo(UDeEN44RcrtJKDCe)yyPGrlxhJHBGhxBatD2bj8xMAUb6Ba8nqfIMgPyz3G5pgwky0ljznqtRb0qLYFzhSyjZFzQ5g4zdCbw(YuZnOYgq29AGMwduHOPrYcXyyPGGu0a4o(oDUc)LyjZc(CR3JCU1lv4CZXNTqTWVdvp(UDeEN44tNoiCdQSbUal)LjZwd8Sb0PdcJQdQF8dNmPD8FCiW(oybXnQpY5wVe(CZXNTqTWVdvp(UDeEN44dFdCzwEjjd9si1c)LqbA56ymCd8ObKDVgub0ac3a9nyHmMoxYmcdTKhJ8hdlfmITqTWVgOP1aLBGlPWwycIOUDcRbAAnq5girHnb9si1c)LqbITqTWVgaxd03a60bHBqLnWfy5Vmz2AGNnGoDqyuDq9gOVbW3aviAA0lHul8xcfOxsYAGMwdKOWMGWYYrDzmgXwOw4xdG74hozs74VHI59PNLpY5wVxY5MJpBHAHFhQE8D7i8oXXxfIMgj74i(XWsbJEjjRbAAnqfIMgPyz3G5pgwkyeKIgOVb0Pdc3apAGlXsdQSbHtM0qXuZVpgwkixILgOVbW3aLBGef2eKd2uh8gFmSuqSfQf(1anTgeozOWF246HXnWJgqOnaUJF4KjTJFnurgmSuoY5wVvWZnhF2c1c)ou9472r4DIJVkennsXYUbZFmSuWiifnqFdOtheUbE0axILguzdcNmPHIPMFFmSuqUelnqFdcNmu4pBC9W4g4zdOch)WjtAhFhSPo4n(yyPCKZTEPIp3C8zlul87q1JVBhH3jo(Qq00OhhVpRJrVKKD8dNmPD8joLYhdlLJCU1Bf(5MJF4KjTJF8RH2hV)K(72Ke(4ZwOw43HQh5CB1kEU54hozs74txcD87JHLYXNTqTWVdvpY52QEp3C8zlul87q1JF4KjTJpMxfSjFSmg5JVBhH3jo(ltVmgwOw4JVtNRWFjwYSGp369iNBRw9CZXNTqTWVdvp(UDeEN44tNoiCd8ObUelnOYgeozsdftn)(yyPGCjwAG(gaFdCzwEjjdTmoTqgJ8p2njHwUogd3apAaHBGMwduUbUKcBHjiI62jSgOP1a60bHBqLnWfy5Vmz2AGhnGoDqyuDq9ga3XpCYK2XVgQidgwkh5CBvc9CZXNTqTWVdvp(UDeEN44VqgtNlzgzmgpgzsXQd)LnuOymY)qHIydbcJylul874hozs74lX(LnuCKZTvPcNBo(SfQf(DO6X3TJW7eh)fYy6CjZiJX4XitkwD4VSHcfJr(hkueBiqyeBHAHFh)WjtAhF6LzQOXi)LnuCKZTvj85MJpBHAHFhQE8D7i8oXXxfIMgjleJHLc6LKSJF4KjTJVAq(N0Fzhhr8ro3w9so3C8dNmPD8XchpDFmSuo(SfQf(DO6roYX)X0buro3CU175MJF4KjTJVlHmH3pgwkhF2c1c)ou9iNBREU54ZwOw43HQh)WjtAhFxczcVFmSuo(UDeEN44VqgtNlzgHzfWGOIWFfB6krDitAi2c1c)AGMwdWjurDShYgDb(lzwWFf5GtdXwOw4xd00Aa8nWL2dAe0Yu4fhLFs)PZvGmgXwOw4xd03aLBWczmDUKzeMvadIkc)vSPRe1HmPHylul8RbWD8lJXF374tOv8iNBj0ZnhF2c1c)ou94hozs74lByxAOPmurJr(JHLYX)Xy3okKjTJ)Ls2GaghVge2Rb3SHDPHMYqfXn42kqVtdyJRhgFrdiXn4LgbsdEzdeydUb052afLqhV4gOYUacZnyecEnqLBGKzdWkI6ADniSxdiXnWfgbsdwoEtrxdUzd7s3aSc2n0JRbQq00y0X3TJW7ehFLBGelzwqd(ROe649iNBPcNBo(SfQf(DO6X3TJW7ehFxsHTWeerD7ewd03axMLxsYqYcXyyPGwUogd3a9nWLz5LKm0Y40czmY)y3KeA56ymCd00AGYnWLuylmbru3oH1a9nWLz5LKmKSqmgwkOLRJXWh)WjtAhFxuk)WjtA)YGLJFzWY3IA(4l7yezbFKZTe(CZXNTqTWVdvp(HtM0o(UOu(HtM0(Lblh)YGLVf18X39Wh5C7LCU54ZwOw43HQhF3ocVtC8dNmu4pBC9W4g4zdi0JF4KjTJVlkLF4KjTFzWYXVmy5BrnF8XYro3wbp3C8zlul87q1JVBhH3jo(Htgk8NnUEyCd8Obvp(HtM0o(UOu(HtM0(Lblh)YGLVf18Xx2Xredlf8roYXxXYUSwnKZnNB9EU54hozs74RMIu43NUe64hPXi)LK6JD8zlul87q1JCUT65MJF4KjTJpDHXWCBqlhF2c1c)ou9iNBj0ZnhF2c1c)ou9472r4DIJ)czmDUKzeoHk05sM)CTkVyeBHAHFh)WjtAhFj2VSHIJCULkCU54ZwOw43HQhFfl7cS8LPMp(ER4XpCYK2X)LqQf(lHIJVBhH3jo(Htgk8NnUEyCd8ObEBGMwduUbUKcBHjiI62jSgOVbk3ajkSjikzPW6qSfQf(DKZTe(CZXNTqTWVdvp(PIJpMLJF4KjTJpLyNqTWhFkrbIp(fMmBVy1H4GCHLOKg(lle)PthegXwOw4xd03amlYyKXioixyjkP9XKcfi2c1c)o(pg72rHmPD8VdSWiZnqYg4Tbs2a8udvcHBqf6nvyU33VctdiZXIjfkAWnleJHLsduSSlWc64tj2Vf18XNf6VILDbwoY52l5CZXNTqTWVdvp(kw2fy5ltnF8RE8D7i8oXXNsStOwyel0Ffl7cSC8vSSlWYNf6pFPHgfhFVh)WjtAhFzHymSuo(kw2fy5JX0)nmIh)k4ro3wbp3C8zlul87q1JVBhH3jo(Htgk8NnUEyCd8SbeAd03a4BGYnWLuylmbru3oH1a9nq5girHnbrjlfwhITqTWVgOP1GWjdf(ZgxpmUbE2GQnaUgOVbk3akXoHAHrSq)vSSlWYXpCYK2XpMA(9XWs5iNBPIp3C8zlul87q1JVBhH3jo(Htgk8NnUEyCd8ObvBGMwdGVbUKcBHjiI62jSgOP1ajkSjikzPW6qSfQf(1a4AG(geozOWF246HXn4AdQ2anTgqj2julmIf6VILDbwo(HtM0o(yHJNUpgwkh5ihF3dFU5CR3ZnhF2c1c)ou9472r4DIJVkennswigdlfeKIgOP1a6Hmm5VCDmgUbE2aVe6XpCYK2XxLxmVehJ8ro3w9CZXNTqTWVdvp(UDeEN44RcrtJKfIXWsbbPObAAnWLz5LKmKSqmgwkOLRJXWnWJgqOvSbAAnqnX4gOVb0dzyYF56ymCd8SbEVKJF4KjTJVAjZ3NgA1DKZTe65MJpBHAHFhQE8D7i8oXXxfIMgjleJHLccsrd00AGlZYljzizHymSuqlxhJHBGhnGqRyd00AGAIXnqFdOhYWK)Y1Xy4g4zd8Ejh)WjtAh)WCmw2O8DrPCKZTuHZnhF2c1c)ou9472r4DIJVkennswigdlfeKIgOP1axMLxsYqYcXyyPGwUogd3apAaHwXgOP1a1eJBG(gqpKHj)LRJXWnWZguHF8dNmPD8PNLvlz(oY5wcFU54ZwOw43HQhF3ocVtC8vHOPrYcXyyPGEjj74hozs74xgYWe8VceOh5A2KJCU9so3C8zlul87q1JVBhH3jo(Qq00izHymSuqqkAG(gaFduHOPrQLmFfiSGGu0anTgiXsMfemokcmKcN0apBq1k2a4AGMwdutmUb6Ba9qgM8xUogd3apBq1l54hozs74RiLjTJCKJpwo3CU175MJpBHAHFhQE8D7i8oXXxIcBcclC809PthegXwOw4xd03a4BGILP8j7EiViSWXt3hdlLgOVbQq00iSWXt3NoDqy0Y1Xy4g4zdiCd00AGkennclC809Ptheg9sswdGRb6Ba8nqfIMgTmoTqgJ8p2njHEjjRbAAnq5g4skSfMGiQBNWAaCh)WjtAhFSWXt3hdlLJCUT65MJF4KjTJpXPu(yyPC8zlul87q1JCULqp3C8zlul87q1JVBhH3jo(UKcBHjiI62jSgOVbW3axMLxsYqlJtlKXi)JDtsOLRJXWnWZgq29AaCnqtRbk3axsHTWeerD7ewd03aLBGlPWwycYgYWKpDWnqtRbUKcBHjiBidt(0b3a9na(g4YS8ssgI0uEFSIzhbJwUogd3apBaz3RbAAnWLz5LKmePP8(yfZocgTCDmgUbE0acTInaUgOP1ajwYSGKPM)s(Fd3apBGxcF8dNmPD8FjKAH)sO4iNBPcNBo(SfQf(DO6XpCYK2XNUelF8D7i8oXXxI9lBOabPOb6BWczmDUKzeoHk05sM)CTkVyeBHAHFh)Yy839o(vj8ro3s4ZnhF2c1c)ou9472r4DIJ)czmDUKzeoHk05sM)CTkVyeBHAHFnqFdKy)YgkqlxhJHBGNnGS71a9nWLz5LKmeDjwgTCDmgUbE2aYU3XpCYK2XxI9lBO4iNBVKZnh)WjtAhFM6kkjEOWFmSuo(SfQf(DO6ro3wbp3C8dNmPD8jnL3hRy2rWhF2c1c)ou9iNBPIp3C8dNmPD8PlHo(9XWs54ZwOw43HQh5CBf(5MJpBHAHFhQE8D7i8oXXNoDq4guzdCbw(ltMTg4zdOthegvhu)4hozs74)4qG9DWcIBuFKZTER45MJF4KjTJF8RH2hV)K(72Ke(4ZwOw43HQh5CRxVNBo(SfQf(DO6X3TJW7ehFxMLxsYqlJtlKXi)JDtsOLRJXWnWZgq29AG(gaFduUbsuytqm1vus8qH)yyPGylul8RbAAnqfIMgPwY8vGWccsrdGRbAAnq5g4skSfMGiQBNWAGMwdCzwEjjdTmoTqgJ8p2njHwUogd3anTgOMyCd03a6Hmm5VCDmgUbE2acF8dNmPD8jftzmY)y3K0ro36T65MJpBHAHFhQE8D7i8oXXxfIMg9si1c)Lqbcsrd00AGYnqIcBc6LqQf(lHceBHAHFnqtRbQjg3a9nGEidt(lxhJHBGNnWB1JF4KjTJ)Y40czmY)y3K0ro36Lqp3C8zlul87q1JVBhH3jo(Qq00OLXPfYyK)XUjjeKIgOP1aLBGlPWwycIOUDcRb6Ba8nqfIMgPyz3G5pgwky0ljznqtRbk3ajkSjihSPo4n(yyPGylul8RbAAniCYqH)SX1dJBGNnOAdG74hozs74tjlfw3ro36LkCU54ZwOw43HQhF3ocVtC8Djf2ctqe1TtynqFdOtheUbv2axGL)YKzRbE2a60bHr1b1BG(gaFdGVbUmlVKKHwgNwiJr(h7MKqlxhJHBGNnGS71GkGgqOnqFdGVbk3aCcvuh7HyAAi8qH)Hn1XpCoUWBi5Iylul8RbAAnq5girHnb9si1c)LqbITqTWVgaxdGRbAAnqIcBc6LqQf(lHceBHAHFnqFdCzwEjjd9si1c)LqbA56ymCd8SbeAdG74hozs74JfoE6(yyPCKZTEj85MJpBHAHFhQE8D7i8oXXxfIMgPyz3G5pgwky0ljznqFdGVbUKcBHjikSjW0TnqtRbUKcBHjiJDBwY91anTgirHnb5IszmYFbg)XWsbJylul8RbW1anTgOcrtJwgNwiJr(h7MKqqkAGMwduHOPrKMY7Jvm7iyeKIgOP1aviAAeLSuyDiifnqFdcNmu4pBC9W4g4rd82anTgOMyCd03a6Hmm5VCDmgUbE2GQe(4hozs74lleJHLYro369so3C8zlul87q1JVBhH3jo(Qq00ifl7gm)XWsbJGu0anTgqNoiCd8ObUelnOYgeozsdftn)(yyPGCjwo(HtM0o(BOyEF6z5JCU1Bf8CZXNTqTWVdvp(HtM0o(XuZVpgwkhF3ocVtC8vHOPrkw2ny(JHLcg9sswd00Aa8nqfIMgjleJHLccsrd00AanuP8x2blwY8xMAUbE2aYUxdQSbUalFzQ5gaxd03a4BGYnqIcBcYbBQdEJpgwki2c1c)AGMwdcNmu4pBC9W4g4zdQ2a4AGMwduHOPrYooIFmSuWOLRJXWnWJgWuNDqc)LPMBG(geozOWF246HXnWJg494705k8xILml4ZTEpY5wVuXNBo(SfQf(DO6X3TJW7ehF4BGlZYljzOxcPw4VekqlxhJHBGhnGS71GkGgq4gOP1aLBGlPWwycIOUDcRbAAnq5girHnb9si1c)LqbITqTWVgaxd03a60bHBqLnWfy5Vmz2AGNnGoDqyuDq9gOVbW3aviAAKSqmgwkOxsYAGMwduUbfMmBVy1H4GCHLOKg(lle)PthegXwOw4xdGRb6Ba8nqfIMg9si1c)Lqb6LKSgOP1ajkSjiSSCuxgJrSfQf(1a4o(HtM0o(BOyEF6z5JCU1Bf(5MJpBHAHFhQE8D7i8oXXxfIMgPyz3G5pgwkyeKIgOP1a60bHBGhnWLyPbv2GWjtAOyQ53hdlfKlXYXpCYK2X3bBQdEJpgwkh5CB1kEU54ZwOw43HQhF3ocVtC8vHOPrkw2ny(JHLcgbPObAAnGoDq4g4rdCjwAqLniCYKgkMA(9XWsb5sSC8dNmPD8J1fg)XWs5iNBR69CZXNTqTWVdvp(HtM0o(yEvWM8XYyKp(UDeEN44Vm9YyyHAHBG(giXsMfKm18xY)B4g4rdEqBitAhFNoxH)sSKzbFU17ro3wT65MJpBHAHFhQE8D7i8oXXpCYqH)SX1dJBGhnW7XpCYK2Xxn2niZh5CBvc9CZXNTqTWVdvp(UDeEN44dFdCzwEjjd9si1c)LqbA56ymCd8ObKDVgub0ac3a9nyHmMoxYmcdTKhJ8hdlfmITqTWVgOP1aLBGlPWwycIOUDcRbAAnq5girHnb9si1c)LqbITqTWVgaxd03a60bHBqLnWfy5Vmz2AGNnGoDqyuDq9gOVbW3aviAA0lHul8xcfOxsYAGMwdKOWMGWYYrDzmgXwOw4xdG74hozs74VHI59PNLpY52QuHZnhF2c1c)ou9472r4DIJVkennswigdlf0ljzh)WjtAhF1G8pP)YooI4JCUTkHp3C8zlul87q1JVBhH3jo(4eQOo2dPaclqf(ZlKczsdXwOw4xd03aviAAKSqmgwkOxsYo(HtM0o(0fgdZTbTCKZTvVKZnh)WjtAhFSWXt3hdlLJpBHAHFhQEKJC8LDmISGp3CU175MJpBHAHFhQE8tfhFmlh)WjtAhFkXoHAHp(uIceF8vHOPrlJtlKXi)JDtsiifnqtRbQq00izHymSuqqko(uI9BrnF8X6m3hsXro3w9CZXNTqTWVdvp(PIJpMLJF4KjTJpLyNqTWhFkrbIp(UKcBHjiI62jSgOVbQq00OLXPfYyK)XUjjeKIgOVbQq00izHymSuqqkAGMwduUbUKcBHjiI62jSgOVbQq00izHymSuqqko(uI9BrnF8XYMg5pwN5(qkoY5wc9CZXNTqTWVdvp(PIJpMLH(4hozs74tj2jul8XNsSFlQ5Jpw20i)X6m3F56ym8X3TJW7ehFviAAKSqmgwkOxsYo(uIce)5cMp(UmlVKKHKfIXWsbTCDmg(4tjkq8X3Lz5LKm0Y40czmY)y3KeA56ymCd8ScCdCzwEjjdjleJHLcA56ym8ro3sfo3C8zlul87q1JFQ44JzzOp(HtM0o(uIDc1cF8Pe73IA(4JLnnYFSoZ9xUogdF8D7i8oXXxfIMgjleJHLccsXXNsuG4pxW8X3Lz5LKmKSqmgwkOLRJXWhFkrbIp(UmlVKKHwgNwiJr(h7MKqlxhJHpY5wcFU54ZwOw43HQh)uXXhZYqF8dNmPD8Pe7eQf(4tj2Vf18XhRZC)LRJXWhF3ocVtC8Djf2ctqe1TtyhFkrbI)CbZhFxMLxsYqYcXyyPGwUogdF8Pefi(47YS8ssgAzCAHmg5FSBscTCDmgUbEubUbUmlVKKHKfIXWsbTCDmg(iNBVKZnhF2c1c)ou94hozs74dH5)iCn(472r4DIJp8nq2XiYcs8IGf4peM)Qq00nqtRbUKcBHjiI62jSgOVbYogrwqIxeSa)DzwEjjRbW1a9na(gqj2julmclBAK)yDM7dPOb6Ba8nq5g4skSfMGiQBNWAG(gOCdKDmISGKQiyb(dH5VkenDd00AGlPWwycIOUDcRb6BGYnq2XiYcsQIGf4VlZYljznqtRbYogrwqsvKlZYljzOLRJXWnqtRbYogrwqIxeSa)HW8xfIMUb6Ba8nq5gi7yezbjvrWc8hcZFviA6gOP1azhJiliXlYLz5LKm0dAdzsRbECTbYogrwqsvKlZYljzOh0gYKwdGRbAAnq2XiYcs8IGf4VlZYljznqFduUbYogrwqsveSa)HW8xfIMUb6BGSJrKfK4f5YS8ssg6bTHmP1apU2azhJiliPkYLz5LKm0dAdzsRbW1anTgOCdOe7eQfgHLnnYFSoZ9Hu0a9na(gOCdKDmISGKQiyb(dH5VkenDd03a4BGSJrKfK4f5YS8ssg6bTHmP1aQSbeUbE2akXoHAHryDM7VCDmgUbAAnGsStOwyewN5(lxhJHBGhnq2XiYcs8ICzwEjjd9G2qM0AW9nOAdGRbAAnq2XiYcsQIGf4peM)Qq00nqFdGVbYogrwqIxeSa)HW8xfIMUb6BGSJrKfK4f5YS8ssg6bTHmP1apU2azhJiliPkYLz5LKm0dAdzsRb6Ba8nq2XiYcs8ICzwEjjd9G2qM0Aav2ac3apBaLyNqTWiSoZ9xUogd3anTgqj2julmcRZC)LRJXWnWJgi7yezbjErUmlVKKHEqBitAn4(guTbW1anTgaFduUbYogrwqIxeSa)HW8xfIMUbAAnq2XiYcsQICzwEjjd9G2qM0AGhxBGSJrKfK4f5YS8ssg6bTHmP1a4AG(gaFdKDmISGKQixMLxsYqlhpDnqFdKDmISGKQixMLxsYqpOnKjTgqLnGWnWJgqj2julmcRZC)LRJXWnqFdOe7eQfgH1zU)Y1Xy4g4zdKDmISGKQixMLxsYqpOnKjTgCFdQ2anTgOCdKDmISGKQixMLxsYqlhpDnqFdGVbYogrwqsvKlZYljzOLRJXWnGkBaHBGNnGsStOwyew20i)X6m3F56ymCd03akXoHAHryztJ8hRZC)LRJXWnWJguTInqFdGVbYogrwqIxKlZYljzOh0gYKwdOYgq4g4zdOe7eQfgH1zU)Y1Xy4gOP1azhJiliPkYLz5LKm0Y1Xy4gqLnGWnWZgqj2julmcRZC)LRJXWnqFdKDmISGKQixMLxsYqpOnKjTgqLnWBfBqLnGsStOwyewN5(lxhJHBGNnGsStOwyew20i)X6m3F56ymCd00AaLyNqTWiSoZ9xUogd3apAGSJrKfK4f5YS8ssg6bTHmP1G7Bq1gOP1akXoHAHryDM7dPObW1anTgi7yezbjvrUmlVKKHwUogd3aQSbeUbE0akXoHAHryztJ8hRZC)LRJXWnqFdGVbYogrwqIxKlZYljzOh0gYKwdOYgq4g4zdOe7eQfgHLnnYFSoZ9xUogd3anTgOCdKDmISGeViyb(dH5VkenDd03a4BaLyNqTWiSoZ9xUogd3apAGSJrKfK4f5YS8ssg6bTHmP1G7Bq1gOP1akXoHAHryDM7dPObW1a4AaCnaUgaxdGRbAAnqILmlizQ5VK)3WnWZgqj2julmcRZC)LRJXWnaUgOP1aLBGSJrKfK4fblWFim)vHOPBG(gOCdCjf2ctqe1TtynqFdGVbYogrwqsveSa)HW8xfIMUb6Ba8na(gOCdOe7eQfgH1zUpKIgOP1azhJiliPkYLz5LKm0Y1Xy4g4rdiCdGRb6Ba8nGsStOwyewN5(lxhJHBGhnOAfBGMwdKDmISGKQixMLxsYqlxhJHBav2ac3apAaLyNqTWiSoZ9xUogd3a4AaCnqtRbk3azhJiliPkcwG)qy(Rcrt3a9na(gOCdKDmISGKQiyb(7YS8sswd00AGSJrKfKuf5YS8ssgA56ymCd00AGSJrKfKuf5YS8ssg6bTHmP1apU2azhJiliXlYLz5LKm0dAdzsRbW1a4o(4sk4JVSJrKfVh5CBf8CZXNTqTWVdvp(HtM0o(qy(pcxJp(UDeEN44dFdKDmISGKQiyb(dH5VkenDd00AGlPWwycIOUDcRb6BGSJrKfKufblWFxMLxsYAaCnqFdGVbuIDc1cJWYMg5pwN5(qkAG(gaFduUbUKcBHjiI62jSgOVbk3azhJiliXlcwG)qy(Rcrt3anTg4skSfMGiQBNWAG(gOCdKDmISGeViyb(7YS8sswd00AGSJrKfK4f5YS8ssgA56ymCd00AGSJrKfKufblWFim)vHOPBG(gaFduUbYogrwqIxeSa)HW8xfIMUbAAnq2XiYcsQICzwEjjd9G2qM0AGhxBGSJrKfK4f5YS8ssg6bTHmP1a4AGMwdKDmISGKQiyb(7YS8sswd03aLBGSJrKfK4fblWFim)vHOPBG(gi7yezbjvrUmlVKKHEqBitAnWJRnq2XiYcs8ICzwEjjd9G2qM0AaCnqtRbk3akXoHAHryztJ8hRZCFifnqFdGVbk3azhJiliXlcwG)qy(Rcrt3a9na(gi7yezbjvrUmlVKKHEqBitAnGkBaHBGNnGsStOwyewN5(lxhJHBGMwdOe7eQfgH1zU)Y1Xy4g4rdKDmISGKQixMLxsYqpOnKjTgCFdQ2a4AGMwdKDmISGeViyb(dH5VkenDd03a4BGSJrKfKufblWFim)vHOPBG(gi7yezbjvrUmlVKKHEqBitAnWJRnq2XiYcs8ICzwEjjd9G2qM0AG(gaFdKDmISGKQixMLxsYqpOnKjTgqLnGWnWZgqj2julmcRZC)LRJXWnqtRbuIDc1cJW6m3F56ymCd8ObYogrwqsvKlZYljzOh0gYKwdUVbvBaCnqtRbW3aLBGSJrKfKufblWFim)vHOPBGMwdKDmISGeVixMLxsYqpOnKjTg4X1gi7yezbjvrUmlVKKHEqBitAnaUgOVbW3azhJiliXlYLz5LKm0YXtxd03azhJiliXlYLz5LKm0dAdzsRbuzdiCd8ObuIDc1cJW6m3F56ymCd03akXoHAHryDM7VCDmgUbE2azhJiliXlYLz5LKm0dAdzsRb33GQnqtRbk3azhJiliXlYLz5LKm0YXtxd03a4BGSJrKfK4f5YS8ssgA56ymCdOYgq4g4zdOe7eQfgHLnnYFSoZ9xUogd3a9nGsStOwyew20i)X6m3F56ymCd8ObvRyd03a4BGSJrKfKuf5YS8ssg6bTHmP1aQSbeUbE2akXoHAHryDM7VCDmgUbAAnq2XiYcs8ICzwEjjdTCDmgUbuzdiCd8SbuIDc1cJW6m3F56ymCd03azhJiliXlYLz5LKm0dAdzsRbuzd8wXguzdOe7eQfgH1zU)Y1Xy4g4zdOe7eQfgHLnnYFSoZ9xUogd3anTgqj2julmcRZC)LRJXWnWJgi7yezbjvrUmlVKKHEqBitAn4(guTbAAnGsStOwyewN5(qkAaCnqtRbYogrwqIxKlZYljzOLRJXWnGkBaHBGhnGsStOwyew20i)X6m3F56ymCd03a4BGSJrKfKuf5YS8ssg6bTHmP1aQSbeUbE2akXoHAHryztJ8hRZC)LRJXWnqtRbk3azhJiliPkcwG)qy(Rcrt3a9na(gqj2julmcRZC)LRJXWnWJgi7yezbjvrUmlVKKHEqBitAn4(guTbAAnGsStOwyewN5(qkAaCnaUgaxdGRbW1a4AGMwdKyjZcsMA(l5)nCd8SbuIDc1cJW6m3F56ymCdGRbAAnq5gi7yezbjvrWc8hcZFviA6gOVbk3axsHTWeerD7ewd03a4BGSJrKfK4fblWFim)vHOPBG(gaFdGVbk3akXoHAHryDM7dPObAAnq2XiYcs8ICzwEjjdTCDmgUbE0ac3a4AG(gaFdOe7eQfgH1zU)Y1Xy4g4rdQwXgOP1azhJiliXlYLz5LKm0Y1Xy4gqLnGWnWJgqj2julmcRZC)LRJXWnaUgaxd00AGYnq2XiYcs8IGf4peM)Qq00nqFdGVbk3azhJiliXlcwG)UmlVKK1anTgi7yezbjErUmlVKKHwUogd3anTgi7yezbjErUmlVKKHEqBitAnWJRnq2XiYcsQICzwEjjd9G2qM0AaCnaUJpUKc(4l7yezP6roYro(u4fpPDUTAfR6TIxs1k8JpPyTXiJp(esjeqi82kKBVuUBdAWnW4gm1kYvAaDUnGazhhrmSuWe0GLV0qZYVgGZAUbbKK1HWVg4GfgzgJALU8yCd8E3gCN0OWRWVgqGef2ee1iObs2acKOWMGOgITqTWpcAa8EPoCOwPlpg3ac9Un4oPrHxHFnGGfYy6CjZiQrqdKSbeSqgtNlzgrneBHAHFe0a49sD4qTsxEmUbuH72G7KgfEf(1acwiJPZLmJOgbnqYgqWczmDUKze1qSfQf(rqdcPbvOesUCdG3l1Hd1kD5X4gubVBdUtAu4v4xdiqIcBcIAe0ajBabsuytqudXwOw4hbnaEVuhouR0LhJBav8DBWDsJcVc)AabsuytquJGgizdiqIcBcIAi2c1c)iObW7L6WHALU8yCd8w9Un4oPrHxHFnGajkSjiQrqdKSbeirHnbrneBHAHFe0a49sD4qTsxEmUbERE3gCN0OWRWVgqWczmDUKze1iObs2acwiJPZLmJOgITqTWpcAa8EPoCOwPlpg3aVe(Un4oPrHxHFnGajkSjiQrqdKSbeirHnbrneBHAHFe0a4RsD4qTsxEmUbEj8DBWDsJcVc)AablKX05sMruJGgizdiyHmMoxYmIAi2c1c)iObW7L6WHALU8yCd8Ej3Tb3jnk8k8RbeirHnbrncAGKnGajkSjiQHylul8JGgaVxQdhQv6YJXnOkHE3gCN0OWRWVgqWczmDUKze1iObs2acwiJPZLmJOgITqTWpcAqinOcLqYLBa8EPoCOwPlpg3GQuH72G7KgfEf(1acwiJPZLmJOgbnqYgqWczmDUKze1qSfQf(rqdcPbvOesUCdG3l1Hd1k1kriLqaHWBRqU9s5UnOb3aJBWuRixPb052acEmDavecAWYxAOz5xdWzn3GasY6q4xdCWcJmJrTsxEmUbvVBdUtAu4v4xdiyHmMoxYmIAe0ajBablKX05sMrudXwOw4hbnaEVuhouR0LhJBq172G7KgfEf(1acwiJPZLmJOgbnqYgqWczmDUKze1qSfQf(rqdG3l1Hd1kD5X4gu9Un4oPrHxHFnGaxApOrquJGgizdiWL2dAee1qSfQf(rqdG3l1Hd1kD5X4gu9Un4oPrHxHFnGaCcvuh7HOgbnqYgqaoHkQJ9qudXwOw4hbnaEVuhouRuReHucbecVTc52lL72GgCdmUbtTICLgqNBdiqXYUSwnecAWYxAOz5xdWzn3GasY6q4xdCWcJmJrTsxEmUbe6DBWDsJcVc)AablKX05sMruJGgizdiyHmMoxYmIAi2c1c)iObH0GkucjxUbW7L6WHALU8yCdOc3Tb3jnk8k8RbeirHnbrncAGKnGajkSjiQHylul8JGgesdQqjKC5gaVxQdhQv6YJXnOcE3gCN0OWRWVgqGef2ee1iObs2acKOWMGOgITqTWpcAa8EPoCOwPlpg3aQ472G7KgfEf(1acKOWMGOgbnqYgqGef2ee1qSfQf(rqdG3l1Hd1k1kriLqaHWBRqU9s5UnOb3aJBWuRixPb052acWcbny5ln0S8Rb4SMBqajzDi8RboyHrMXOwPlpg3aV3Tb3jnk8k8RbeirHnbrncAGKnGajkSjiQHylul8JGgaVxQdhQv6YJXnGkC3gCN0OWRWVgqWczmDUKze1iObs2acwiJPZLmJOgITqTWpcAqinOcLqYLBa8EPoCOwPlpg3acF3gCN0OWRWVgqWczmDUKze1iObs2acwiJPZLmJOgITqTWpcAa8EPoCOwPlpg3aVEVBdUtAu4v4xdiqIcBcIAe0ajBabsuytqudXwOw4hbnaEVuhouR0LhJBG3Q3Tb3jnk8k8RbeirHnbrncAGKnGajkSjiQHylul8JGgaVxQdhQv6YJXnWlHE3gCN0OWRWVgqGef2ee1iObs2acKOWMGOgITqTWpcAa8EPoCOwPlpg3aVuH72G7KgfEf(1acKOWMGOgbnqYgqGef2ee1qSfQf(rqdGVk1Hd1kD5X4g4LkC3gCN0OWRWVgqaoHkQJ9quJGgizdiaNqf1XEiQHylul8JGgaVxQdhQv6YJXnWlHVBdUtAu4v4xdiqIcBcIAe0ajBabsuytqudXwOw4hbnaEVuhouR0LhJBG3l5Un4oPrHxHFnGajkSjiQrqdKSbeirHnbrneBHAHFe0a4RsD4qTsxEmUbEVK72G7KgfEf(1acwiJPZLmJOgbnqYgqWczmDUKze1qSfQf(rqdG3l1Hd1kD5X4g4TcE3gCN0OWRWVgqGef2ee1iObs2acKOWMGOgITqTWpcAa8EPoCOwPlpg3aVuX3Tb3jnk8k8RbeirHnbrncAGKnGajkSjiQHylul8JGgaFvQdhQv6YJXnOkHE3gCN0OWRWVgqGef2ee1iObs2acKOWMGOgITqTWpcAa8vPoCOwPlpg3GQe6DBWDsJcVc)AablKX05sMruJGgizdiyHmMoxYmIAi2c1c)iObW7L6WHALU8yCdQs472G7KgfEf(1acWjurDShIAe0ajBab4eQOo2drneBHAHFe0a49sD4qTsTsesjeqi82kKBVuUBdAWnW4gm1kYvAaDUnGazhJilycAWYxAOz5xdWzn3GasY6q4xdCWcJmJrTsxEmUbxYDBWDsJcVc)AG)uFNgG1zsq9gqi2ajBWLHIg8gkdEsRbPcEdj3ga)9W1a4jm1Hd1kD5X4gCj3Tb3jnk8k8Rbei7yezb5frncAGKnGazhJiliXlIAe0a4R6L6WHALU8yCdUK72G7KgfEf(1acKDmISGQIOgbnqYgqGSJrKfKufrncAa8vVeQdhQv6YJXnOcE3gCN0OWRWVg4p13PbyDMeuVbeInqYgCzOObVHYGN0AqQG3qYTbWFpCnaEctD4qTsxEmUbvW72G7KgfEf(1acKDmISG8IOgbnqYgqGSJrKfK4frncAa8vVeQdhQv6YJXnOcE3gCN0OWRWVgqGSJrKfuve1iObs2acKDmISGKQiQrqdGVQxQdhQvQvQcPwrUc)AWL0GWjtAnOmybJALo(yfS7CBvctfo(k2KEk8XNqMqUbxQILiUommSrrdQWcYeEBLiKjKBGsqfDnW7fnOAfR6TvQvkCYKggPyzxwRgsLxVxnfPWVpDj0XpsJr(lj1hRvkCYKggPyzxwRgsLxVNUWyyUnOLwPWjtAyKILDzTAivE9Ej2VSHIlg6RlKX05sMr4eQqNlz(Z1Q8IBLcNmPHrkw2L1QHu517FjKAH)sO4cfl7cS8LPMV6TIxm0xdNmu4pBC9Wyp8QPPSlPWwycIOUDctVYsuytquYsH11kri3G7almYCdKSbEBGKnap1qLq4guHEtfM799RW0aYCSysHIgCZcXyyP0afl7cSGALcNmPHrkw2L1QHu517Pe7eQf(clQ5RSq)vSSlWYfuIceFTWKz7fRoehKlSeL0WFzH4pD6GWi2c1c)0JzrgJmgXb5clrjTpMuOaXwOw4xRu4KjnmsXYUSwnKkVEVSqmgwkxOyzxGLpl0F(sdnkU69cfl7cS8Xy6)ggXRvWluSSlWYxMA(A1lg6RuIDc1cJyH(RyzxGLwPWjtAyKILDzTAivE9(yQ53hdlLlg6RHtgk8NnUEySNeQE4v2Luylmbru3oHPxzjkSjikzPW600cNmu4pBC9WypRcNELPe7eQfgXc9xXYUalTsHtM0Wifl7YA1qQ869yHJNUpgwkxm0xdNmu4pBC9WypQQPbVlPWwycIOUDctttIcBcIswkSo40hozOWF246HXxRQPrj2julmIf6VILDbwALALcNmPHR869UeYeE)yyP0kfozsdx517DjKj8(XWs5IYy839UsOv8IH(6czmDUKzeMvadIkc)vSPRe1HmPPPHtOI6ypKn6c8xYSG)kYbNMMg8U0EqJGwMcV4O8t6pDUcKX6vEHmMoxYmcZkGbrfH)k20vI6qM0GRvIqUbxkzdcyC8AqyVgCZg2LgAkdve3GBRa9onGnUEyCf2nGe3GxAein4LnqGn4gqNBduucD8IBGk7cim3Gri41avUbsMnaRiQR11GWEnGe3axyeiny54nfDn4MnSlDdWky3qpUgOcrtJrTsHtM0WvE9Ezd7sdnLHkAmYFmSuUyOVQSelzwqd(ROe64TvIqMqUbxQ5sORb0HBmYnqxcTn4LqQsdGmzknqxc1aybfUbkGKgqiKXPfYyKBaHGDtsn4LKSlAqUnyOBGaJBGlZYljznyWnqYSbL0i3ajBWJlHUgqhUXi3aDj02Gl1jKQGAqfcDdS04gK0nqGXyUbU0EJmPHBqSCdc1c3ajBqnlnG0iWgRbcmUbERydWSlThUbfMjf6UObcmUb4PUb0HJXnqxcTn4sDcPkniGKSoKXfLIouReHmHCdcNmPHR869gtIoHS3FzCwOWxm0xXjurDShYys0jK9(lJZcfwp8Qq00OLXPfYyK)XUjjeKcnnxMLxsYqlJtlKXi)JDtsOLRJXWE4TIAAQjgRNEidt(lxhJH907LOPPSlPWwycIOUDcdUwPWjtA4kVEVlkLF4KjTFzWYfwuZxLDmISGVyOV6skSfMGiQBNW07YS8ssgswigdlf0Y1Xyy9UmlVKKHwgNwiJr(h7MKqlxhJH10u2Luylmbru3oHP3Lz5LKmKSqmgwkOLRJXWTsHtM0WvE9Exuk)WjtA)YGLlSOMV6E4wPWjtA4kVEVlkLF4KjTFzWYfwuZxXYfd91Wjdf(Zgxpm2tcTvkCYKgUYR37Is5hozs7xgSCHf18vzhhrmSuWxm0xdNmu4pBC9WypQ2k1kfozsdJCp8vvEX8sCmYxm0xvHOPrYcXyyPGGuOPrpKHj)LRJXWE6LqBLcNmPHrUhUYR3RwY89PHwDxm0xvHOPrYcXyyPGGuOP5YS8ssgswigdlf0Y1Xyypi0kQPPMySE6Hmm5VCDmg2tVxsRu4KjnmY9WvE9(WCmw2O8DrPCXqFvfIMgjleJHLccsHMMlZYljzizHymSuqlxhJH9GqROMMAIX6PhYWK)Y1Xyyp9EjTsHtM0Wi3dx517PNLvlz(UyOVQcrtJKfIXWsbbPqtZLz5LKmKSqmgwkOLRJXWEqOvuttnXy90dzyYF56ymSNv4TsHtM0Wi3dx517ldzyc(xbc0JCnBYfd9vviAAKSqmgwkOxsYALcNmPHrUhUYR3RiLjTlg6RQq00izHymSuqqk0dVkennsTK5RaHfeKcnnjwYSGGXrrGHu4epRwr400utmwp9qgM8xUogd7z1lPvQvkCYKggHLRyHJNUpgwkxm0xLOWMGWchpDF60bH1dVILP8j7EiViSWXt3hdlf9Qq00iSWXt3NoDqy0Y1XyypjSMMkennclC809Ptheg9ssgC6HxfIMgTmoTqgJ8p2njHEjjtttzxsHTWeerD7egCTsHtM0WiSu517joLYhdlLwPWjtAyewQ869VesTWFjuCXqF1Luylmbru3oHPhExMLxsYqlJtlKXi)JDtsOLRJXWEs29GtttzxsHTWeerD7eMELDjf2ctq2qgM8PdwtZLuylmbzdzyYNoy9W7YS8ssgI0uEFSIzhbJwUogd7jz3ttZLz5LKmePP8(yfZocgTCDmg2dcTIWPPjXsMfKm18xY)Byp9s4wPWjtAyewQ8690Ly5lkJXF37AvcFXqFvI9lBOabPq)czmDUKzeoHk05sM)CTkV4wPWjtAyewQ869sSFzdfxm0xxiJPZLmJWjuHoxY8NRv5fRxI9lBOaTCDmg2tYUNExMLxsYq0Lyz0Y1Xyypj7ETsHtM0WiSu517zQROK4Hc)XWsPvkCYKggHLkVEpPP8(yfZocUvkCYKggHLkVEpDj0XVpgwkTsHtM0WiSu517FCiW(oybXnQVyOVsNoiCLUal)LjZMN0PdcJQdQ3kfozsdJWsLxVp(1q7J3Fs)DBsc3kfozsdJWsLxVNumLXi)JDtsxm0xDzwEjjdTmoTqgJ8p2njHwUogd7jz3tp8klrHnbXuxrjXdf(JHLIMMkennsTK5RaHfeKc400u2Luylmbru3oHPP5YS8ssgAzCAHmg5FSBscTCDmgwttnXy90dzyYF56ymSNeUvkCYKggHLkVE)Y40czmY)y3K0fd9vviAA0lHul8xcfiifAAklrHnb9si1c)LqHMMAIX6PhYWK)Y1Xyyp9wTvkCYKggHLkVEpLSuyDxm0xvHOPrlJtlKXi)JDtsiifAAk7skSfMGiQBNW0dVkennsXYUbZFmSuWOxsY00uwIcBcYbBQdEJpgwkAAHtgk8NnUEySNvHRvkCYKggHLkVEpw44P7JHLYfd9vxsHTWeerD7eME60bHR0fy5Vmz28KoDqyuDqD9WdVlZYljzOLXPfYyK)XUjj0Y1Xyypj7EvaeQE4vgNqf1XEiMMgcpu4FytD8dNJl8gsUAAklrHnb9si1c)LqbCWPPjrHnb9si1c)LqHExMLxsYqVesTWFjuGwUogd7jHcxRu4KjnmclvE9EzHymSuUyOVQcrtJuSSBW8hdlfm6LKm9W7skSfMGOWMat3QP5skSfMGm2Tzj3NMMef2eKlkLXi)fy8hdlfmCAAQq00OLXPfYyK)XUjjeKcnnviAAePP8(yfZocgbPqttfIMgrjlfwhcsH(Wjdf(Zgxpm2dVAAQjgRNEidt(lxhJH9SkHBLcNmPHryPYR3VHI59PNLVyOVUqgtNlzgHHwYJr(JHLcwVef2eewwoQlJX6H3Lz5LKm0lHul8xcfOLRJXWEq29QaiSMMYUKcBHjiI62jmnnLLOWMGEjKAH)sOaUWjtAyewQ869oytDWB8XWs5IH(QkennsXYUbZFmSuWiifAA0Pdc7HlXsLHtM0qXuZVpgwkixILwPWjtAyewQ869XuZVpgwkx405k8xILml4REVyOVQcrtJuSSBW8hdlfm6LKmnn4vHOPrYcXyyPGGuOPrdvk)LDWILm)LPM9KS7vPlWYxMAgo9WRSef2eKd2uh8gFmSu00cNmu4pBC9WypRcNMMkenns2Xr8JHLcgTCDmg2dM6Sds4Vm1S(Wjdf(Zgxpm2dVTsHtM0WiSu5173qX8(0ZYxm0xH3Lz5LKm0lHul8xcfOLRJXWEq29QaiSMMYUKcBHjiI62jmnnLLOWMGEjKAH)sOao90PdcxPlWYFzYS5jD6GWO6G66HxfIMgjleJHLc6LKmnnLlmz2EXQdXb5clrjn8xwi(tNoimITqTWp40dVkenn6LqQf(lHc0ljzAAsuytqyz5OUmgdxRu4KjnmclvE9EhSPo4n(yyPCXqFvfIMgPyz3G5pgwkyeKcnn60bH9WLyPYWjtAOyQ53hdlfKlXsRu4KjnmclvE9(yDHXFmSuUyOVQcrtJuSSBW8hdlfmcsHMgD6GWE4sSuz4Kjnum187JHLcYLyPvkCYKggHLkVEpMxfSjFSmg5lC6Cf(lXsMf8vVxm0xxMEzmSqTW6LyjZcsMA(l5)nShpOnKjTwPWjtAyewQ869QXUbz(IH(A4KHc)zJRhg7H3wPWjtAyewQ869BOyEF6z5lg6RW7YS8ssg6LqQf(lHc0Y1Xyypi7Evaew)czmDUKzegAjpg5pgwkynnLDjf2ctqe1TtyAAklrHnb9si1c)LqbC6PtheUsxGL)YKzZt60bHr1b11dVkenn6LqQf(lHc0ljzAAsuytqyz5OUmgdxRu4KjnmclvE9E1G8pP)YooI4lg6RQq00izHymSuqVKK1kfozsdJWsLxVNUWyyUnOLlg6R4eQOo2dPaclqf(ZlKczstVkennswigdlf0ljzTsHtM0WiSu517XchpDFmSuALALcNmPHrYooIyyPGVIfoE6(yyPCXqFvIcBcclC809Pthew)yF6YqgMOxfIMgHfoE6(0PdcJwUogd7jHBLcNmPHrYooIyyPGR869VesTWFjuCXqF1Luylmbru3oHP3Lz5LKm0Y40czmY)y3KeA56ymSNKDpnnLDjf2ctqe1Tty6v2LuylmbzdzyYNoynnxsHTWeKnKHjF6G1dVlZYljzist59XkMDemA56ymSNKDpnnxMLxsYqKMY7Jvm7iy0Y1Xyypi0kcNMMelzwqYuZFj)VH90Bf10CzwEjjdTmoTqgJ8p2njHwUogd7H3kQpCYqH)SX1dJ9GqBLcNmPHrYooIyyPGR869sSFzdfxm0xxiJPZLmJWjuHoxY8NRv5fRxI9lBOaTCDmg2tYUNExMLxsYq0Lyz0Y1Xyypj7ETsHtM0WizhhrmSuWvE9E6sS8fLX4V7DTkHVyOVkX(LnuGGuOFHmMoxYmcNqf6CjZFUwLxCRu4Kjnms2XredlfCLxVNPUIsIhk8hdlLwPWjtAyKSJJigwk4kVEpPP8(yfZocUvkCYKggj74iIHLcUYR3tkMYyK)XUjPlg6RUmlVKKHwgNwiJr(h7MKqlxhJH9KS7PhELLOWMGyQROK4Hc)XWsrttfIMgPwY8vGWccsbCAAk7skSfMGiQBNW00CzwEjjdTmoTqgJ8p2njHwUogd7H3kQPPMySE6Hmm5VCDmg2tc3kfozsdJKDCeXWsbx517xgNwiJr(h7MKUyOVQcrtJEjKAH)sOabPqttzjkSjOxcPw4Vek00utmwp9qgM8xUogd7P3QTsHtM0WizhhrmSuWvE9EkzPW6UyOVQcrtJwgNwiJr(h7MKqqk00u2Luylmbru3oH1kfozsdJKDCeXWsbx517vJDdYCRu4Kjnms2XredlfCLxVxwigdlLwPWjtAyKSJJigwk4kVE)gkM3NEw(IH(6czmDUKzegAjpg5pgwky9W7YS8ssgAzCAHmg5FSBscTCDmg2dVvuttzxsHTWeerD7eMMMYsuytqVesTWFjuaNEviAAKSJJ4hdlfmA56ymShxzQZoiH)YuZTsHtM0WizhhrmSuWvE9(yQ53hdlLlC6Cf(lXsMf8vVxm0xvHOPrYooIFmSuWOLRJXWECLPo7Ge(ltnRhEviAAKILDdM)yyPGrVKKPPrdvk)LDWILm)LPM90fy5ltnxjz3tttfIMgjleJHLccsbCTsHtM0WizhhrmSuWvE9(hhcSVdwqCJ6lg6R0PdcxPlWYFzYS5jD6GWO6G6TsHtM0WizhhrmSuWvE9(numVp9S8fd9v4DzwEjjd9si1c)LqbA56ymShKDVkacRFHmMoxYmcdTKhJ8hdlfSMMYUKcBHjiI62jmnnLLOWMGEjKAH)sOao90PdcxPlWYFzYS5jD6GWO6G66HxfIMg9si1c)Lqb6LKmnnjkSjiSSCuxgJHRvkCYKggj74iIHLcUYR3xdvKbdlLlg6RQq00izhhXpgwky0ljzAAQq00ifl7gm)XWsbJGuONoDqypCjwQmCYKgkMA(9XWsb5sSOhELLOWMGCWM6G34JHLIMw4KHc)zJRhg7bHcxRu4Kjnms2XredlfCLxV3bBQdEJpgwkxm0xvHOPrkw2ny(JHLcgbPqpD6GWE4sSuz4Kjnum187JHLcYLyrF4KHc)zJRhg7jvOvkCYKggj74iIHLcUYR3tCkLpgwkxm0xvHOPrpoEFwhJEjjRvkCYKggj74iIHLcUYR3h)AO9X7pP)UnjHBLcNmPHrYooIyyPGR8690Lqh)(yyP0kfozsdJKDCeXWsbx517X8QGn5JLXiFHtNRWFjwYSGV69IH(6Y0lJHfQfUvkCYKggj74iIHLcUYR3xdvKbdlLlg6R0Pdc7HlXsLHtM0qXuZVpgwkixIf9W7YS8ssgAzCAHmg5FSBscTCDmg2dcRPPSlPWwycIOUDcttJoDq4kDbw(ltMnpOthegvhuhUwPWjtAyKSJJigwk4kVEVe7x2qXfd91fYy6CjZiJX4XitkwD4VSHcfJr(hkueBiq4wPWjtAyKSJJigwk4kVEp9Ymv0yK)YgkUyOVUqgtNlzgzmgpgzsXQd)LnuOymY)qHIydbc3kfozsdJKDCeXWsbx517vdY)K(l74iIVyOVQcrtJKfIXWsb9sswRu4Kjnms2XredlfCLxVhlC809XWsPvQvkCYKggj7yezbFLsStOw4lSOMVI1zUpKIlOefi(QkennAzCAHmg5FSBscbPqttfIMgjleJHLccsrRu4Kjnms2XiYcUYR3tj2jul8fwuZxXYMg5pwN5(qkUGsuG4RUKcBHjiI62jm9Qq00OLXPfYyK)XUjjeKc9Qq00izHymSuqqk00u2Luylmbru3oHPxfIMgjleJHLccsrRu4Kjnms2XiYcUYR3tj2jul8fwuZxXYMg5pwN5(lxhJHVivCfZYqFHlT3itAxDjf2ctqe1Ttyxqjkq8vxMLxsYqlJtlKXi)JDtsOLRJXWEwb2Lz5LKmKSqmgwkOLRJXWxqjkq8Nly(QlZYljzizHymSuqlxhJHVyOVQcrtJKfIXWsb9sswRu4Kjnms2XiYcUYR3tj2jul8fwuZxXYMg5pwN5(lxhJHVivCfZYqFHlT3itAxDjf2ctqe1Ttyxqjkq8vxMLxsYqlJtlKXi)JDtsOLRJXWxqjkq8Nly(QlZYljzizHymSuqlxhJHVyOVQcrtJKfIXWsbbPOvkCYKggj7yezbx517Pe7eQf(clQ5RyDM7VCDmg(IuXvmld9fU0EJmPD1Luylmbru3oHDbLOaXxDzwEjjdTmoTqgJ8p2njHwUogd7rfyxMLxsYqYcXyyPGwUogdFbLOaXFUG5RUmlVKKHKfIXWsbTCDmgUvkCYKggj7yezbx517HW8FeUgFbUKc(QSJrKfVxm0xHx2XiYcYlcwG)qy(RcrtRP5skSfMGiQBNW0l7yezb5fblWFxMLxsYGtp8uIDc1cJWYMg5pwN5(qk0dVYUKcBHjiI62jm9kl7yezbvfblWFim)vHOP10Cjf2ctqe1Tty6vw2XiYcQkcwG)UmlVKKPPj7yezbvf5YS8ssgA56ymSMMSJrKfKxeSa)HW8xfIMwp8kl7yezbvfblWFim)vHOP10KDmISG8ICzwEjjd9G2qM084QSJrKfuvKlZYljzOh0gYKgCAAYogrwqErWc83Lz5LKm9kl7yezbvfblWFim)vHOP1l7yezb5f5YS8ssg6bTHmP5XvzhJilOQixMLxsYqpOnKjn400uMsStOwyew20i)X6m3hsHE4vw2XiYcQkcwG)qy(RcrtRhEzhJiliVixMLxsYqpOnKjnQKWEsj2julmcRZC)LRJXWAAuIDc1cJW6m3F56ymShYogrwqErUmlVKKHEqBitAeIvHttt2XiYcQkcwG)qy(RcrtRhEzhJiliViyb(dH5VkenTEzhJiliVixMLxsYqpOnKjnpUk7yezbvf5YS8ssg6bTHmPPhEzhJiliVixMLxsYqpOnKjnQKWEsj2julmcRZC)LRJXWAAuIDc1cJW6m3F56ymShYogrwqErUmlVKKHEqBitAeIvHttdELLDmISG8IGf4peM)Qq00AAYogrwqvrUmlVKKHEqBitAECv2XiYcYlYLz5LKm0dAdzsdo9Wl7yezbvf5YS8ssgA54PtVSJrKfuvKlZYljzOh0gYKgvsypOe7eQfgH1zU)Y1Xyy9uIDc1cJW6m3F56ymSNYogrwqvrUmlVKKHEqBitAeIv10uw2XiYcQkYLz5LKm0YXtNE4LDmISGQICzwEjjdTCDmgMkjSNuIDc1cJWYMg5pwN5(lxhJH1tj2julmclBAK)yDM7VCDmg2JQvup8YogrwqErUmlVKKHEqBitAujH9KsStOwyewN5(lxhJH10KDmISGQICzwEjjdTCDmgMkjSNuIDc1cJW6m3F56ymSEzhJilOQixMLxsYqpOnKjnQ0BfRKsStOwyewN5(lxhJH9KsStOwyew20i)X6m3F56ymSMgLyNqTWiSoZ9xUogd7HSJrKfKxKlZYljzOh0gYKgHyvnnkXoHAHryDM7dPaonnzhJilOQixMLxsYqlxhJHPsc7bLyNqTWiSSPr(J1zU)Y1Xyy9Wl7yezb5f5YS8ssg6bTHmPrLe2tkXoHAHryztJ8hRZC)LRJXWAAkl7yezb5fblWFim)vHOP1dpLyNqTWiSoZ9xUogd7HSJrKfKxKlZYljzOh0gYKgHyvnnkXoHAHryDM7dPao4Gdo4GtttILmlizQ5VK)3WEsj2julmcRZC)LRJXWWPPPSSJrKfKxeSa)HW8xfIMwVYUKcBHjiI62jm9Wl7yezbvfblWFim)vHOP1dp8ktj2julmcRZCFifAAYogrwqvrUmlVKKHwUogd7bHHtp8uIDc1cJW6m3F56ymShvROMMSJrKfuvKlZYljzOLRJXWujH9GsStOwyewN5(lxhJHHdonnLLDmISGQIGf4peM)Qq006HxzzhJilOQiyb(7YS8ssMMMSJrKfuvKlZYljzOLRJXWAAYogrwqvrUmlVKKHEqBitAECv2XiYcYlYLz5LKm0dAdzsdo4ALcNmPHrYogrwWvE9Eim)hHRXxGlPGVk7yezP6fd9v4LDmISGQIGf4peM)Qq00AAUKcBHjiI62jm9YogrwqvrWc83Lz5LKm40dpLyNqTWiSSPr(J1zUpKc9WRSlPWwycIOUDctVYYogrwqErWc8hcZFviAAnnxsHTWeerD7eMELLDmISG8IGf4VlZYljzAAYogrwqErUmlVKKHwUogdRPj7yezbvfblWFim)vHOP1dVYYogrwqErWc8hcZFviAAnnzhJilOQixMLxsYqpOnKjnpUk7yezb5f5YS8ssg6bTHmPbNMMSJrKfuveSa)DzwEjjtVYYogrwqErWc8hcZFviAA9YogrwqvrUmlVKKHEqBitAECv2XiYcYlYLz5LKm0dAdzsdonnLPe7eQfgHLnnYFSoZ9HuOhELLDmISG8IGf4peM)Qq006Hx2XiYcQkYLz5LKm0dAdzsJkjSNuIDc1cJW6m3F56ymSMgLyNqTWiSoZ9xUogd7HSJrKfuvKlZYljzOh0gYKgHyv400KDmISG8IGf4peM)Qq006Hx2XiYcQkcwG)qy(RcrtRx2XiYcQkYLz5LKm0dAdzsZJRYogrwqErUmlVKKHEqBitA6Hx2XiYcQkYLz5LKm0dAdzsJkjSNuIDc1cJW6m3F56ymSMgLyNqTWiSoZ9xUogd7HSJrKfuvKlZYljzOh0gYKgHyv400GxzzhJilOQiyb(dH5VkenTMMSJrKfKxKlZYljzOh0gYKMhxLDmISGQICzwEjjd9G2qM0Gtp8YogrwqErUmlVKKHwoE60l7yezb5f5YS8ssg6bTHmPrLe2dkXoHAHryDM7VCDmgwpLyNqTWiSoZ9xUogd7PSJrKfKxKlZYljzOh0gYKgHyvnnLLDmISG8ICzwEjjdTC80PhEzhJiliVixMLxsYqlxhJHPsc7jLyNqTWiSSPr(J1zU)Y1Xyy9uIDc1cJWYMg5pwN5(lxhJH9OAf1dVSJrKfuvKlZYljzOh0gYKgvsypPe7eQfgH1zU)Y1XyynnzhJiliVixMLxsYqlxhJHPsc7jLyNqTWiSoZ9xUogdRx2XiYcYlYLz5LKm0dAdzsJk9wXkPe7eQfgH1zU)Y1XyypPe7eQfgHLnnYFSoZ9xUogdRPrj2julmcRZC)LRJXWEi7yezbvf5YS8ssg6bTHmPriwvtJsStOwyewN5(qkGttt2XiYcYlYLz5LKm0Y1XyyQKWEqj2julmclBAK)yDM7VCDmgwp8YogrwqvrUmlVKKHEqBitAujH9KsStOwyew20i)X6m3F56ymSMMYYogrwqvrWc8hcZFviAA9Wtj2julmcRZC)LRJXWEi7yezbvf5YS8ssg6bTHmPriwvtJsStOwyewN5(qkGdo4Gdo400KyjZcsMA(l5)nSNuIDc1cJW6m3F56ymmCAAkl7yezbvfblWFim)vHOP1RSlPWwycIOUDctp8YogrwqErWc8hcZFviAA9WdVYuIDc1cJW6m3hsHMMSJrKfKxKlZYljzOLRJXWEqy40dpLyNqTWiSoZ9xUogd7r1kQPj7yezb5f5YS8ssgA56ymmvsypOe7eQfgH1zU)Y1Xyy4GtttzzhJiliViyb(dH5VkenTE4vw2XiYcYlcwG)UmlVKKPPj7yezb5f5YS8ssgA56ymSMMSJrKfKxKlZYljzOh0gYKMhxLDmISGQICzwEjjd9G2qM0GdUJCKZba]] )

    
end