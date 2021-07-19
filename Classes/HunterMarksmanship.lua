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


    spec:RegisterPack( "Marksmanship", 20210715, [[d8uVpcqic4rQGWLaQO2er5tiKrbOofGSkKKeVsfQzbu1TqsQDb6xiuggrvDmH0YaWZaQ00iQIUgbQTbuHVHKeJJOk4CevPwNkKEhqfjnpvG7bq7JOY)ubr6GQGOwibYdvHyIavK6IevjTrvqeFeOIyKavK4KQGeRej1mvb1nrssYobk9tvqsdLOkrlLOk0tfQPcu8vIQeglcv7fI)QsdwvhMQftKhlyYsCzuBgP(mImAeCAfRgjjPEnsmBjDBv0UP8BrdNGoossQLR0ZHA6KUoK2oq(oIA8ijoVqSEvqQ5tO9l1irradsCXvgbSaiFaIkFQsu5nmk4kyQc4IeRreYiXc9afNeJeB(jJetvLVuWNUHjmcrIf6rQPxqadsmor3aJeFi6NGQcXhLyeJ0OeqLGH8Ky45eT66KwyDALy45mqmKyj0PQhkgIesCXvgbSaiFaIkFQsu5nmk4kyQsuWfj2rvc5IehpNhbjMWukSHiHexyCajMQkFPGpDdtye2p4uqnL3MAQrRr6pQGbF)aiFaI2u3uFecUrIXhTPMQ7hSmz6e1k9lpY4ScI7FW9BP2V3)jhi42e6xjW97LsA9hCJyKNAT)t3CsmSPMQ7xEKXrSax63lL06x4o5oAK(jpkH(JNZJ0)HS8YddrIRdwXiGbjw3jqbtivmcyqaBueWGeZMlv5cIGqId7O8oosS6v2uiwzVe5sNbumKnxQYL(L1)yx66qIG2VS(LqPPHyL9sKlDgqXWLp9XW9Fq)cgj2d6KgsmwzVe5IjKkIIawaqadsmBUuLliccjoSJY74iXlQX05sIHct0aHBsFx)qN7LEDsNSPyiBUuLl9lRFjuAAiD1JWl(E6lfiQqKypOtAiXuMA9IjKkIIawWfbmiXS5svUGiiK4WokVJJeVOgtNljgkmrdeUj9D9dDUx61jDYMIHS5svUGe7bDsdjMU6r4YftivefbSYteWGeZMlv5cIGqId7O8oosmW9hsqS5McPezh36xw)HmRLKSbxgNMRJr667MKHlF6JH7)G(jfk9lk2Va9hsqS5McPezh36xw)c0FibXMBk0gse0lTZ9lk2FibXMBk0gse0lTZ9lRFG7pKzTKKni5PwUyHZokgU8PpgU)d6NuO0VOy)HmRLKSbjp1YflC2rXWLp9XW9lx)GR87hO(ff7x9LeRqDo5RM3YW9Fq)rLF)II9hYSwsYgCzCAUogPRVBsgU8PpgUF56pQ87xw)Eqhq8Ln(CyC)Y1p42pq9lRFG7xG(xFkxgeBk0lfmKPYGvC)II9V(uUmi2uOxky4YN(y4(LRF5D)II9lq)HeeBUPqkr2XT(bcj2d6KgsCjrLQ8vDHikcyfmcyqIzZLQCbrqiXHDuEhhjErnMoxsmeNOv6CjXx(uIxmKnxQYL(L1V67vxxiC5tFmC)h0pPqPFz9hYSwsYgKU6ldx(0hd3)b9tkuqI9GoPHeR(E11fIOiGfCGagKy2CPkxqeesSh0jnKy6QVmsCyhL3XrIvFV66cHOc7xw)lQX05sIH4eTsNlj(YNs8IHS5svUGexhJVHcsmacgrralvbbmiXEqN0qIzQiSM4beFXesfjMnxQYfebHOiGvEabmiXS5svUGiiK4WokVJJelq)RpLldInf6LcgYuzWkUFrX(xFkxgeBk0lfmC5tFmC)Y1Fu53VOy)Eqhq8Ln(CyC)Yby)RpLldInf6Lcggsut7NQs)aGe7bDsdjM8ulxSWzhfJOiGvEJagKy2CPkxqeesCyhL3XrIdzwljzdUmonxhJ013njdx(0hd3)b9tku6xw)a3Va9RELnfYurynXdi(IjKkKnxQYL(ff7xcLMgkvZSurXkevy)a1VOy)c0FibXMBkKsKDCRFrX(dzwljzdUmonxhJ013njdx(0hd3VC9hv(9lk2VuIX9lRF6Heb9U8PpgU)d6xWiXEqN0qIj7tDmsxF3KmIIa2OYhbmiXS5svUGiiK4WokVJJedC)HmRLKSbbL1khbU8PpgU)d6NuO0VOy)c0V6v2uiOSw5iq2CPkx6xuSF1xsSc15KVAEld3)b9hfG(bQFz9dC)c0)6t5YGytHEPGHmvgSI7xuS)1NYLbXMc9sbdx(0hd3VC9lV7xuSFpOdi(YgFomUF5aS)1NYLbXMc9sbddjQP9tvPFa6hiKypOtAiXlJtZ1XiD9DtYikcyJgfbmiXS5svUGiiK4WokVJJelHstdxgNMRJr667MKHOc7xuSFb6pKGyZnfsjYoUHe7bDsdjguwRCeefbSrbabmiXEqN0qIL8DDsmsmBUuLliccrraBuWfbmiXS5svUGiiK4WokVJJelHstdxgNMRJr667MKHOc7xuS)qM1ss2GlJtZ1XiD9DtYWLp9XW9lx)rLF)II9lq)HeeBUPqkr2XT(ff7xkX4(L1p9qIGEx(0hd3)b9dG8rI9GoPHeRlkJjKkIIa2OYteWGeZMlv5cIGqId7O8oos8IAmDUKyigDjngPlMqQyiBUuLl9lRFG7pKzTKKn4Y40CDmsxF3KmC5tFmC)Y1Fu53VOy)c0FibXMBkKsKDCRFrX(fOF1RSPWsIkv5R6cHS5svU0pq9lRFjuAAOUtGYftivmC5tFmC)Yby)mv4aQYxDozKypOtAiXRlCkx6zzefbSrfmcyqIzZLQCbrqiXEqN0qI95KlxmHurId7O8oosSeknnu3jq5IjKkgU8PpgUF5aSFMkCav5RoNC)Y6h4(LqPPHcxomy(IjKkgwsYw)II9tJwR3Lde8LeF15K7)G(dowV6CY9FC)KcL(ff7xcLMgQlkJjKkevy)aHehIeQ8v9LeRyeWgfrraBuWbcyqIzZLQCbrqiXHDuEhhjModO4(pU)GJ17YKyR)d6NodOy4PtfKypOtAiXf2vc3abNY6NikcyJsvqadsmBUuLliccjoSJY74iXa3FiZAjjBWLXP56yKU(Ujz4YN(y4(LR)OYVFz9VOgtNljgIrxsJr6IjKkgYMlv5s)II9lq)HeeBUPqkr2XT(ff7xG(xuJPZLedXOlPXiDXesfdzZLQCPFrX(fOF1RSPWsIkv5R6cHS5svU0pq9lRFjuAAOUtGYftivmC5tFmC)Yby)mv4aQYxDozKypOtAiXRlCkx6zzefbSrLhqadsmBUuLliccjoSJY74iXsO00qDNaLlMqQyyjjB9lk2Veknnu4YHbZxmHuXquH9lRF6mGI7xU(djw7)4(9GoPb95KlxmHuHHeR9lRFG7xG(vVYMcdeMtNx)IjKkKnxQYL(ff73d6aIVSXNdJ7xU(b3(bcj2d6Kgs8jAvhmHurueWgvEJagKy2CPkxqeesCyhL3XrILqPPHcxomy(IjKkgIkSFz9tNbuC)Y1FiXA)h3Vh0jnOpNC5IjKkmKyTFz97bDaXx24ZHX9Fq)YtKypOtAiXbcZPZRFXesfrralaYhbmiXS5svUGiiK4WokVJJelHstdlSxUCegwsYgsSh0jnKyktTEXesfrralarradsSh0jnKy)EIUfEVj9nSjzmsmBUuLliccrralaaGagKypOtAiX0vpcxUycPIeZMlv5cIGqueWca4IagKy2CPkxqeesSh0jnKymVcztVyDmsiXHDuEhhjEz6LXeCPkJehIeQ8v9LeRyeWgfrralaYteWGeZMlv5cIGqId7O8oosmDgqX9lx)HeR9FC)EqN0G(CYLlMqQWqI1(L1pW9hYSwsYgCzCAUogPRVBsgU8PpgUF56xW9lk2Va9hsqS5McPezh36hiKypOtAiXNOvDWesfrralacgbmiXS5svUGiiK4WokVJJeVOgtNljgAmgpgjY(gbF11fkCmsxxOqFDffdzZLQCbj2d6KgsS67vxxiIIawaahiGbjMnxQYfebHeh2r5DCK4f1y6CjXqJX4Xir23i4RUUqHJr66cf6RROyiBUuLliXEqN0qIPxMp0Jr6QRlerralaufeWGeZMlv5cIGqId7O8oosSeknnuxugtivyjjBiXEqN0qILCs3K(Q7eOGrueWcG8acyqIzZLQCbrqiXHDuEhhjgNOvPXkqHOyfTYxErfQtAq2CPkx6xw)sO00qDrzmHuHLKSHe7bDsdjMUYycH1PvefbSaiVradsSh0jnKySYEjYftivKy2CPkxqeeIIOiXfM2rRkcyqaBueWGe7bDsdjoKOMY7ftivKy2CPkxqeeIIawaqadsmBUuLliccj2d6KgsCirnL3lMqQiXHDuEhhjErnMoxsmeZcjGEOXxHBgQ(PRtAq2CPkx6xuSFCIwLgRaTjIJVAMv8vyo40GS5svU0VOy)a3FiTc6OWLbXl2R3K(sNRIAmKnxQYL(L1Va9VOgtNljgIzHeqp04RWndv)01jniBUuLl9desCDm(gkiXGR8rueWcUiGbjMnxQYfebHe7bDsdjwx3OQrN6COhJ0ftivK4cJd7iuN0qIbNK97eyV0VBL(bZ6gvn6uNdn3pyLxEK(zJphgd((jZ9xsJiT)s2VsyW9tNB)cREeEX9lXbhfZ9pkrL(L4(1m7hl0ppJ0VBL(jZ9hCJiT)L9YuJ0pyw3OQ7hlKdd9e6xcLMgdrId7O8oosSa9R(sIv4GVcREeErueWkpradsmBUuLliccjoSJY74iXHeeBUPqkr2XT(L1FiZAjjBqDrzmHuHlF6JH7xw)HmRLKSbxgNMRJr667MKHlF6JH7xuSFb6pKGyZnfsjYoU1VS(dzwljzdQlkJjKkC5tFmmsSh0jnK4GxRxpOtA36GvK46G1R5NmsSUJrHvmIIawbJagKy2CPkxqeesSh0jnK4GxRxpOtA36GvK46G1R5NmsCOGrueWcoqadsmBUuLliccjoSJY74iXEqhq8Ln(CyC)h0p4Ie7bDsdjo4161d6K2ToyfjUoy9A(jJeJvefbSufeWGeZMlv5cIGqId7O8oosSh0beFzJphg3VC9dasSh0jnK4GxRxpOtA36GvK46G1R5NmsSUtGcMqQyefrrIfUCipLCfbmiGnkcyqI9GoPHelLQw5YLU6r4c5XiD1KkJHeZMlv5cIGqueWcacyqI9GoPHetxzmHW60ksmBUuLliccrral4IagKy2CPkxqeesCyhL3XrIxuJPZLedXjALoxs8LpL4fdzZLQCbj2d6KgsS67vxxiIIaw5jcyqIzZLQCbrqiXcxo4y9QZjJehv(iXEqN0qIljQuLVQlejoSJY74iXEqhq8Ln(CyC)Y1F0(ff7xG(dji2CtHuISJB9lRFb6x9kBkeuwRCeiBUuLlikcyfmcyqIzZLQCbrqiXPqKymRiXEqN0qIb574svgjgKxrzK4ktITIVrGStQYQxtdF1fLV0zafdzZLQCPFz9JzvhJegYoPkREnTlMSleYMlv5csCHXHDeQtAiXhHGBK4(1S)O9Rz)45eT6k3V8kyoKqS44dj9tI9ft2f2pywugti1(fUCWXkejgKVxZpzKywPVcxo4yfrral4abmiXS5svUGiiK4WokVJJedY3XLQmKv6RWLdowrI9GoPHeRlkJjKkIIawQccyqIzZLQCbrqiXHDuEhhj2d6aIVSXNdJ7)G(b3(L1pW9lq)HeeBUPqkr2XT(L1Va9RELnfckRvocKnxQYL(ff73d6aIVSXNdJ7)G(bOFG6xw)c0piFhxQYqwPVcxo4yfj2d6KgsSpNC5IjKkIIaw5beWGeZMlv5cIGqId7O8oosSh0beFzJphg3VC9dq)II9dC)HeeBUPqkr2XT(ff7x9kBkeuwRCeiBUuLl9du)Y63d6aIVSXNdJ7hW(bOFrX(b574svgYk9v4YbhRiXEqN0qIXk7LixmHuruefjouWiGbbSrradsmBUuLliccjoSJY74iXa3VeknnuxugtiviQW(L1VeknnCzCAUogPRVBsgIkSFz9hsqS5McPezh36hO(ff7h4(LqPPH6IYycPcrf2VS(LqPPHKNA5Ifo7OyiQW(L1FibXMBk0gse0lTZ9du)II9dC)HeeBUPqqSPeIS9lk2FibXMBk04WM1Cl9du)Y6xcLMgQlkJjKkevy)II9lLyC)Y6NEirqVlF6JH7)G(JcU9lk2pW9hsqS5McPezh36xw)sO00WLXP56yKU(UjziQW(L1VuIX9lRF6Heb9U8PpgU)d6NQaU9desSh0jnKyjEX8szmsikcybabmiXS5svUGiiK4WokVJJelHstd1fLXesfIkSFrX(dzwljzdQlkJjKkC5tFmC)Y1p4k)(ff7xkX4(L1p9qIGEx(0hd3)b9hfCGe7bDsdjwQMz5sJUrqueWcUiGbjMnxQYfebHeh2r5DCKyjuAAOUOmMqQquH9lk2FiZAjjBqDrzmHuHlF6JH7xU(bx53VOy)sjg3VS(Phse07YN(y4(pO)OGdKypOtAiXUfySUE9g8AfrraR8ebmiXS5svUGiiK4WokVJJelHstd1fLXesfIkSFrX(dzwljzdQlkJjKkC5tFmC)Y1p4k)(ff7xkX4(L1p9qIGEx(0hd3)b9lVrI9GoPHetpllvZSGOiGvWiGbjMnxQYfebHeh2r5DCKyjuAAOUOmMqQWss2qI9GoPHexhseu8LQA0cPt2uefbSGdeWGeZMlv5cIGqId7O8oosSeknnuxugtiviQW(L1pW9lHstdLQzwQOyfIkSFrX(vFjXkKa7vLauyq7)G(bq(9du)II9lLyC)Y6NEirqVlF6JH7)G(baC0VOy)a3FibXMBkKsKDCRFz9lHstdxgNMRJr667MKHOc7xw)sjg3VS(Phse07YN(y4(pOFQca9desSh0jnKyHPoPHOiksmwradcyJIagKy2CPkxqeesCyhL3XrIvVYMcXk7Lix6mGIHS5svU0VS(bUFHld6skuGrHyL9sKlMqQ9lRFjuAAiwzVe5sNbumC5tFmC)h0VG7xuSFjuAAiwzVe5sNbumSKKT(bQFz9dC)sO00WLXP56yKU(UjzyjjB9lk2Va9hsqS5McPezh36hiKypOtAiXyL9sKlMqQikcybabmiXEqN0qIPm16ftivKy2CPkxqeeIIawWfbmiXS5svUGiiK4WokVJJedC)HeeBUPqkr2XT(L1pW9hYSwsYgCzCAUogPRVBsgU8PpgU)d6NuO0pq9lk2Va9hsqS5McPezh36xw)c0FibXMBk0gse0lTZ9lk2FibXMBk0gse0lTZ9lRFG7pKzTKKni5PwUyHZokgU8PpgU)d6NuO0VOy)HmRLKSbjp1YflC2rXWLp9XW9lx)GR87hO(ff7x9LeRqDo5RM3YW9Fq)rfC)a1VS(bUFb6F9PCzqSPqVuWqMkdwX9lk2)6t5YGytHEPGHJ1VC9dUYVFrX(xFkxgeBk0lfmmKOM2pG9hTFrX(fO)qcIn3uiLi74w)II97bDaXx24ZHX9lx)r7hiKypOtAiXLevQYx1fIOiGvEIagKy2CPkxqeesCyhL3XrIvFV66cHOc7xw)lQX05sIH4eTsNlj(YNs8IHS5svUGe7bDsdjMU6lJOiGvWiGbjMnxQYfebHeh2r5DCK4f1y6CjXqCIwPZLeF5tjEXq2CPkx6xw)QVxDDHWLp9XW9Fq)KcL(L1FiZAjjBq6QVmC5tFmC)h0pPqbj2d6KgsS67vxxiIIawWbcyqI9GoPHeZurynXdi(IjKksmBUuLliccrralvbbmiXS5svUGiiK4WokVJJelq)RpLldInf6LcgYuzWkUFrX(fO)1NYLbXMc9sbdrf2VS(xFkxgeBk0lfmSGUUoP1)X9V(uUmi2uOxky4y9Fq)ai)(ff7F9PCzqSPqVuWquH9lR)1NYLbXMc9sbdx(0hd3VC9hvE3VOy)Eqhq8Ln(CyC)Y1FuKypOtAiXKNA5Ifo7OyefbSYdiGbj2d6KgsmD1JWLlMqQiXS5svUGiiefbSYBeWGeZMlv5cIGqId7O8oosmDgqX9FC)bhR3LjXw)h0pDgqXWtNkiXEqN0qIlSReUbcoL1prueWgv(iGbj2d6KgsSFpr3cV3K(g2KmgjMnxQYfebHOiGnAueWGeZMlv5cIGqId7O8oosCiZAjjBWLXP56yKU(Ujz4YN(y4(pOFsHs)Y6h4(fOF1RSPqMkcRjEaXxmHuHS5svU0VOy)sO00qPAMLkkwHOc7hO(ff7xG(dji2CtHuISJB9lk2FiZAjjBWLXP56yKU(Ujz4YN(y4(ff7xkX4(L1p9qIGEx(0hd3)b9lyKypOtAiXK9PogPRVBsgrraBuaqadsmBUuLliccjoSJY74iXa3VeknnSKOsv(QUqiQW(ff7xG(vVYMcljQuLVQleYMlv5s)II9R(sIvOoN8vZBz4(pO)Oa0pq9lRFG7xG(xFkxgeBk0lfmKPYGvC)II9lq)RpLldInf6LcgIkSFz9dC)RpLldInf6LcgwqxxN06)4(xFkxgeBk0lfmCS(pO)OYVFrX(xFkxgeBk0lfmmKOM2pG9hTFG6xuS)1NYLbXMc9sbdrf2VS(xFkxgeBk0lfmC5tFmC)Y1V8UFrX(9GoG4lB85W4(LR)O9desSh0jnK4LXP56yKU(UjzefbSrbxeWGeZMlv5cIGqId7O8oosSeknnCzCAUogPRVBsgIkSFrX(fO)qcIn3uiLi74w)Y6h4(LqPPHcxomy(IjKkgwsYw)II9lq)QxztHbcZPZRFXesfYMlv5s)II97bDaXx24ZHX9Fq)a0pqiXEqN0qIbL1khbrraBu5jcyqIzZLQCbrqiXHDuEhhjoKGyZnfsjYoU1VS(PZakU)J7p4y9Umj26)G(PZakgE6uPFz9dC)a3FiZAjjBWLXP56yKU(Ujz4YN(y4(pOFsHs)uv6hC7xw)a3Va9Jt0Q0yfittJIhq81T50VEiWvEDnxiBUuLl9lk2Va9RELnfwsuPkFvxiKnxQYL(bQFG6xuSF1RSPWsIkv5R6cHS5svU0VS(dzwljzdwsuPkFvxiC5tFmC)h0p42pqiXEqN0qIXk7LixmHurueWgvWiGbjMnxQYfebHeh2r5DCKyjuAAOWLddMVycPIHLKS1VS(bU)qcIn3uii2ucr2(ff7pKGyZnfACyZAUL(ff7x9kBkm416yKUkb(IjKkgYMlv5s)a1VOy)sO00WLXP56yKU(UjziQW(ff7xcLMgsEQLlw4SJIHOc7xuSFjuAAiOSw5iquH9lRFpOdi(YgFomUF56pA)II9dC)sjg3VS(Phse07YN(y4(pOFaeC)Y6xG(xFkxgeBk0lfmKPYGvC)aHe7bDsdjwxugtivefbSrbhiGbjMnxQYfebHeh2r5DCK4f1y6CjXqm6sAmsxmHuXq2CPkx6xw)QxztHyDz)SogdzZLQCPFz9dC)HmRLKSbxgNMRJr667MKHlF6JH7xU(Jk)(ff7xG(dji2CtHuISJB9lk2Va9RELnfwsuPkFvxiKnxQYL(ff7hNOvPXkqMMgfpG4RBZPF9qGR86AUq2CPkx6hiKypOtAiXRlCkx6zzefbSrPkiGbjMnxQYfebHe7bDsdj2NtUCXesfjoSJY74iXsO00qHlhgmFXesfdljzRFrX(bUFjuAAOUOmMqQquH9lk2pnATExoqWxs8vNtU)d6NuO0)X9hCSE15K7hO(L1pW9lq)QxztHbcZPZRFXesfYMlv5s)II97bDaXx24ZHX9Fq)a0pq9lk2Veknnu3jq5IjKkgU8PpgUF56NPchqv(QZj3VS(9GoG4lB85W4(LR)OiXHiHkFvFjXkgbSrrueWgvEabmiXS5svUGiiK4WokVJJedC)HmRLKSbxgNMRJr667MKHlF6JH7xU(Jk)(ff7xG(dji2CtHuISJB9lk2Va9RELnfwsuPkFvxiKnxQYL(ff7hNOvPXkqMMgfpG4RBZPF9qGR86AUq2CPkx6hO(L1pDgqX9FC)bhR3LjXw)h0pDgqXWtNk9lRFG7xcLMgwsuPkFvxiSKKT(ff7x9kBkeRl7N1XyiBUuLl9desSh0jnK41foLl9SmIIa2OYBeWGeZMlv5cIGqId7O8oosSeknnu4YHbZxmHuXquH9lk2pDgqX9lx)HeR9FC)EqN0G(CYLlMqQWqIvKypOtAiXbcZPZRFXesfrralaYhbmiXS5svUGiiK4WokVJJelHstdfUCyW8ftivmevy)II9tNbuC)Y1FiXA)h3Vh0jnOpNC5IjKkmKyfj2d6KgsSVb34lMqQikcybikcyqIzZLQCbrqiXEqN0qIX8kKn9I1XiHeh2r5DCK4LPxgtWLQC)Y6x9LeRqDo5RM3YW9lx)f011jnK4qKqLVQVKyfJa2OikcybaaeWGeZMlv5cIGqId7O8oosSh0beFzJphg3VC9hfj2d6KgsSKVRtIrueWca4IagKy2CPkxqeesCyhL3XrIbU)qM1ss2GlJtZ1XiD9DtYWLp9XW9lx)rLF)Y6FrnMoxsmeJUKgJ0ftivmKnxQYL(ff7xG(dji2CtHuISJB9lk2Va9RELnfwsuPkFvxiKnxQYL(ff7hNOvPXkqMMgfpG4RBZPF9qGR86AUq2CPkx6hO(L1pDgqX9FC)bhR3LjXw)h0pDgqXWtNk9lRFG7xcLMgwsuPkFvxiSKKT(ff7x9kBkeRl7N1XyiBUuLl9desSh0jnK41foLl9SmIIawaKNiGbjMnxQYfebHeh2r5DCKyjuAAOUOmMqQWss2qI9GoPHel5KUj9v3jqbJOiGfabJagKy2CPkxqeesCyhL3XrIXjAvAScuikwrR8LxuH6KgKnxQYL(L1VeknnuxugtivyjjBiXEqN0qIPRmMqyDAfrralaGdeWGe7bDsdjgRSxICXesfjMnxQYfebHOiksSUJrHvmcyqaBueWGeZMlv5cIGqItHiXywrI9GoPHedY3XLQmsmiVIYiXsO00WLXP56yKU(UjziQW(ff7xcLMgQlkJjKkevismiFVMFYiX4iw4IkerralaiGbjMnxQYfebHeNcrIXSIe7bDsdjgKVJlvzKyqEfLrIdji2CtHuISJB9lRFjuAA4Y40CDmsxF3Kmevy)Y6xcLMgQlkJjKkevy)II9lq)HeeBUPqkr2XT(L1VeknnuxugtiviQqKyq(En)KrIX6MgPloIfUOcrueWcUiGbjMnxQYfebHeNcrIXSo0iXEqN0qIb574svgjgKVxZpzKySUPr6IJyH7YN(yyK4WokVJJelHstd1fLXesfwsYw)Y6pKGyZnfsjYoUHedYRO8LRygjoKzTKKnOUOmMqQWLp9XWiXG8kkJehYSwsYgCzCAUogPRVBsgU8PpgU)doK2FiZAjjBqDrzmHuHlF6JHrueWkpradsmBUuLliccjofIeJzDOrI9GoPHedY3XLQmsmiFVMFYiXyDtJ0fhXc3Lp9XWiXHDuEhhjwcLMgQlkJjKkevy)Y6pKGyZnfsjYoUHedYRO8LRygjoKzTKKnOUOmMqQWLp9XWiXG8kkJehYSwsYgCzCAUogPRVBsgU8PpggrraRGradsmBUuLliccjofIeJzDOrI9GoPHedY3XLQmsmiFVMFYiX4iw4U8PpggjoSJY74iXHeeBUPqkr2XnKyqEfLVCfZiXHmRLKSb1fLXesfU8PpggjgKxrzK4qM1ss2GlJtZ1XiD9DtYWLp9XW9l3H0(dzwljzdQlkJjKkC5tFmmIIawWbcyqIzZLQCbrqiXEqN0qI1DmkSgfjoSJY74iXa3VUJrHvOgfsWXxumFLqPP7xuS)qcIn3uiLi74w)Y6x3XOWkuJcj44BiZAjjB9du)Y6h4(b574svgI1nnsxCelCrf2VS(bUFb6pKGyZnfsjYoU1VS(fOFDhJcRqfaibhFrX8vcLMUFrX(dji2CtHuISJB9lRFb6x3XOWkubasWX3qM1ss26xuSFDhJcRqfayiZAjjBWLp9XW9lk2VUJrHvOgfsWXxumFLqPP7xw)a3Va9R7yuyfQaaj44lkMVsO009lk2VUJrHvOgfgYSwsYgSGUUoP1VCa2VUJrHvOcamKzTKKnybDDDsRFG6xuSFDhJcRqnkKGJVHmRLKS1VS(fOFDhJcRqfaibhFrX8vcLMUFz9R7yuyfQrHHmRLKSblORRtA9lhG9R7yuyfQaadzwljzdwqxxN06hO(ff7xG(b574svgI1nnsxCelCrf2VS(bUFb6x3XOWkubasWXxumFLqPP7xw)a3VUJrHvOgfgYSwsYgSGUUoP1pv3VG7)G(b574svgIJyH7YN(y4(ff7hKVJlvzioIfUlF6JH7xU(1DmkSc1OWqM1ss2Gf011jT(jw)a0pq9lk2VUJrHvOcaKGJVOy(kHst3VS(bUFDhJcRqnkKGJVOy(kHst3VS(1DmkSc1OWqM1ss2Gf011jT(LdW(1DmkScvaGHmRLKSblORRtA9lRFG7x3XOWkuJcdzwljzdwqxxN06NQ7xW9Fq)G8DCPkdXrSWD5tFmC)II9dY3XLQmehXc3Lp9XW9lx)6ogfwHAuyiZAjjBWc666Kw)eRFa6hO(ff7h4(fOFDhJcRqnkKGJVOy(kHst3VOy)6ogfwHkaWqM1ss2Gf011jT(LdW(1DmkSc1OWqM1ss2Gf011jT(bQFz9dC)6ogfwHkaWqM1ss2Gl7Li9lRFDhJcRqfayiZAjjBWc666Kw)uD)cUF56hKVJlvzioIfUlF6JH7xw)G8DCPkdXrSWD5tFmC)h0VUJrHvOcamKzTKKnybDDDsRFI1pa9lk2Va9R7yuyfQaadzwljzdUSxI0VS(bUFDhJcRqfayiZAjjBWLp9XW9t19l4(pOFq(oUuLHyDtJ0fhXc3Lp9XW9lRFq(oUuLHyDtJ0fhXc3Lp9XW9lx)ai)(L1pW9R7yuyfQrHHmRLKSblORRtA9t19l4(pOFq(oUuLH4iw4U8PpgUFrX(1DmkScvaGHmRLKSbx(0hd3pv3VG7)G(b574svgIJyH7YN(y4(L1VUJrHvOcamKzTKKnybDDDsRFQU)OYV)J7hKVJlvzioIfUlF6JH7)G(b574svgI1nnsxCelCx(0hd3VOy)G8DCPkdXrSWD5tFmC)Y1VUJrHvOgfgYSwsYgSGUUoP1pX6hG(ff7hKVJlvzioIfUOc7hO(ff7x3XOWkubagYSwsYgC5tFmC)uD)cUF56hKVJlvziw30iDXrSWD5tFmC)Y6h4(1DmkSc1OWqM1ss2Gf011jT(P6(fC)h0piFhxQYqSUPr6IJyH7YN(y4(ff7xG(1DmkSc1Oqco(II5ReknD)Y6h4(b574svgIJyH7YN(y4(LRFDhJcRqnkmKzTKKnybDDDsRFI1pa9lk2piFhxQYqCelCrf2pq9du)a1pq9du)a1VOy)sjg3VS(Phse07YN(y4(pOFq(oUuLH4iw4U8PpgUFG6xuSFb6x3XOWkuJcj44lkMVsO009lRFb6pKGyZnfsjYoU1VS(bUFDhJcRqfaibhFrX8vcLMUFz9dC)a3Va9dY3XLQmehXcxuH9lk2VUJrHvOcamKzTKKn4YN(y4(LRFb3pq9lRFG7hKVJlvzioIfUlF6JH7xU(bq(9lk2VUJrHvOcamKzTKKn4YN(y4(P6(fC)Y1piFhxQYqCelCx(0hd3pq9du)II9lq)6ogfwHkaqco(II5ReknD)Y6h4(fOFDhJcRqfaibhFdzwljzRFrX(1DmkScvaGHmRLKSbx(0hd3VOy)6ogfwHkaWqM1ss2Gf011jT(LdW(1DmkSc1OWqM1ss2Gf011jT(bQFGqIX1uXiX6ogfwJIOiGLQGagKy2CPkxqeesSh0jnKyDhJcRaGeh2r5DCKyG7x3XOWkubasWXxumFLqPP7xuS)qcIn3uiLi74w)Y6x3XOWkubasWX3qM1ss26hO(L1pW9dY3XLQmeRBAKU4iw4IkSFz9dC)c0FibXMBkKsKDCRFz9lq)6ogfwHAuibhFrX8vcLMUFrX(dji2CtHuISJB9lRFb6x3XOWkuJcj44BiZAjjB9lk2VUJrHvOgfgYSwsYgC5tFmC)II9R7yuyfQaaj44lkMVsO009lRFG7xG(1DmkSc1Oqco(II5ReknD)II9R7yuyfQaadzwljzdwqxxN06xoa7x3XOWkuJcdzwljzdwqxxN06hO(ff7x3XOWkubasWX3qM1ss26xw)c0VUJrHvOgfsWXxumFLqPP7xw)6ogfwHkaWqM1ss2Gf011jT(LdW(1DmkSc1OWqM1ss2Gf011jT(bQFrX(fOFq(oUuLHyDtJ0fhXcxuH9lRFG7xG(1DmkSc1Oqco(II5ReknD)Y6h4(1DmkScvaGHmRLKSblORRtA9t19l4(pOFq(oUuLH4iw4U8PpgUFrX(b574svgIJyH7YN(y4(LRFDhJcRqfayiZAjjBWc666Kw)eRFa6hO(ff7x3XOWkuJcj44lkMVsO009lRFG7x3XOWkubasWXxumFLqPP7xw)6ogfwHkaWqM1ss2Gf011jT(LdW(1DmkSc1OWqM1ss2Gf011jT(L1pW9R7yuyfQaadzwljzdwqxxN06NQ7xW9Fq)G8DCPkdXrSWD5tFmC)II9dY3XLQmehXc3Lp9XW9lx)6ogfwHkaWqM1ss2Gf011jT(jw)a0pq9lk2pW9lq)6ogfwHkaqco(II5ReknD)II9R7yuyfQrHHmRLKSblORRtA9lhG9R7yuyfQaadzwljzdwqxxN06hO(L1pW9R7yuyfQrHHmRLKSbx2lr6xw)6ogfwHAuyiZAjjBWc666Kw)uD)cUF56hKVJlvzioIfUlF6JH7xw)G8DCPkdXrSWD5tFmC)h0VUJrHvOgfgYSwsYgSGUUoP1pX6hG(ff7xG(1DmkSc1OWqM1ss2Gl7Li9lRFG7x3XOWkuJcdzwljzdU8PpgUFQUFb3)b9dY3XLQmeRBAKU4iw4U8PpgUFz9dY3XLQmeRBAKU4iw4U8PpgUF56ha53VS(bUFDhJcRqfayiZAjjBWc666Kw)uD)cU)d6hKVJlvzioIfUlF6JH7xuSFDhJcRqnkmKzTKKn4YN(y4(P6(fC)h0piFhxQYqCelCx(0hd3VS(1DmkSc1OWqM1ss2Gf011jT(P6(Jk)(pUFq(oUuLH4iw4U8PpgU)d6hKVJlvziw30iDXrSWD5tFmC)II9dY3XLQmehXc3Lp9XW9lx)6ogfwHkaWqM1ss2Gf011jT(jw)a0VOy)G8DCPkdXrSWfvy)a1VOy)6ogfwHAuyiZAjjBWLp9XW9t19l4(LRFq(oUuLHyDtJ0fhXc3Lp9XW9lRFG7x3XOWkubagYSwsYgSGUUoP1pv3VG7)G(b574svgI1nnsxCelCx(0hd3VOy)c0VUJrHvOcaKGJVOy(kHst3VS(bUFq(oUuLH4iw4U8PpgUF56x3XOWkubagYSwsYgSGUUoP1pX6hG(ff7hKVJlvzioIfUOc7hO(bQFG6hO(bQFG6xuSFPeJ7xw)0djc6D5tFmC)h0piFhxQYqCelCx(0hd3pq9lk2Va9R7yuyfQaaj44lkMVsO009lRFb6pKGyZnfsjYoU1VS(bUFDhJcRqnkKGJVOy(kHst3VS(bUFG7xG(b574svgIJyHlQW(ff7x3XOWkuJcdzwljzdU8PpgUF56xW9du)Y6h4(b574svgIJyH7YN(y4(LRFaKF)II9R7yuyfQrHHmRLKSbx(0hd3pv3VG7xU(b574svgIJyH7YN(y4(bQFG6xuSFb6x3XOWkuJcj44lkMVsO009lRFG7xG(1DmkSc1Oqco(gYSwsYw)II9R7yuyfQrHHmRLKSbx(0hd3VOy)6ogfwHAuyiZAjjBWc666Kw)Yby)6ogfwHkaWqM1ss2Gf011jT(bQFGqIX1uXiX6ogfwbarruefjgeV4jneWcG8biQ8PkrbxKyY(AJrcJelV4qwEeShkGfCYr7VFWqG7FofMR2pDU9tKUtGcMqQyI6FzQA0z5s)48K73r180vU0FGGBKymSP(WJX9h9O9FK0aXRYL(js9kBkK4e1VM9tK6v2uiXHS5svUqu)ahLkabBQp8yC)aC0(psAG4v5s)eTOgtNljgsCI6xZ(jArnMoxsmK4q2CPkxiQFGJsfGGn1hEmUFW9O9FK0aXRYL(jArnMoxsmK4e1VM9t0IAmDUKyiXHS5svUqu)U2V86H6H7h4Oubiyt9HhJ7xWhT)JKgiEvU0prlQX05sIHeNO(1SFIwuJPZLedjoKnxQYfI6h4Oubiyt9HhJ7hCC0(psAG4v5s)eTOgtNljgsCI6xZ(jArnMoxsmK4q2CPkxiQFx7xE9q9W9dCuQaeSP(WJX9lVpA)hjnq8QCPFIuVYMcjor9Rz)ePELnfsCiBUuLle1pWrPcqWM6dpg3Fu5F0(psAG4v5s)ePELnfsCI6xZ(js9kBkK4q2CPkxiQFGJsfGGn1hEmU)OYZJ2)rsdeVkx6Ni1RSPqItu)A2prQxztHehYMlv5cr9dCuQaeSP(WJX9hvEE0(psAG4v5s)eTOgtNljgsCI6xZ(jArnMoxsmK4q2CPkxiQFGJsfGGn1hEmU)OuLJ2)rsdeVkx6Ni1RSPqItu)A2prQxztHehYMlv5cr9dCuQaeSP(WJX9hLQC0(psAG4v5s)eTOgtNljgsCI6xZ(jArnMoxsmK4q2CPkxiQFGbGkabBQp8yC)rLhoA)hjnq8QCPFIuVYMcjor9Rz)ePELnfsCiBUuLle1pWrPcqWM6dpg3pac(O9FK0aXRYL(jArnMoxsmK4e1VM9t0IAmDUKyiXHS5svUqu)U2V86H6H7h4Oubiyt9HhJ7haWXr7)iPbIxLl9t0IAmDUKyiXjQFn7NOf1y6CjXqIdzZLQCHO(DTF51d1d3pWrPcqWM6dpg3paYdhT)JKgiEvU0pr4eTknwbsCI6xZ(jcNOvPXkqIdzZLQCHO(bokvac2u3ulV4qwEeShkGfCYr7VFWqG7FofMR2pDU9tuHPD0Qsu)ltvJolx6hNNC)oQMNUYL(deCJeJHn1hEmUFaoA)hjnq8QCPFIwuJPZLedjor9Rz)eTOgtNljgsCiBUuLle1pWrPcqWM6dpg3pahT)JKgiEvU0prlQX05sIHeNO(1SFIwuJPZLedjoKnxQYfI6h4Oubiyt9HhJ7hGJ2)rsdeVkx6NOqAf0rHeNO(1SFIcPvqhfsCiBUuLle1pWrPcqWM6dpg3pahT)JKgiEvU0pr4eTknwbsCI6xZ(jcNOvPXkqIdzZLQCHO(bokvac2u3ulV4qwEeShkGfCYr7VFWqG7FofMR2pDU9tKWLd5PKRe1)Yu1OZYL(X5j3VJQ5PRCP)ab3iXyyt9HhJ7hCpA)hjnq8QCPFIwuJPZLedjor9Rz)eTOgtNljgsCiBUuLle1VR9lVEOE4(bokvac2uF4X4(LNhT)JKgiEvU0prQxztHeNO(1SFIuVYMcjoKnxQYfI631(LxpupC)ahLkabBQp8yC)uLJ2)rsdeVkx6Ni1RSPqItu)A2prQxztHehYMlv5cr9dCuQaeSP(WJX9lpC0(psAG4v5s)ePELnfsCI6xZ(js9kBkK4q2CPkxiQFGJsfGGn1n1YloKLhb7HcybNC0(7hme4(NtH5Q9tNB)eHvI6FzQA0z5s)48K73r180vU0FGGBKymSP(WJX9h9O9FK0aXRYL(js9kBkK4e1VM9tK6v2uiXHS5svUqu)ahLkabBQp8yC)YZJ2)rsdeVkx6NOf1y6CjXqItu)A2prlQX05sIHehYMlv5cr97A)YRhQhUFGJsfGGn1hEmUFbF0(psAG4v5s)eTOgtNljgsCI6xZ(jArnMoxsmK4q2CPkxiQFGJsfGGn1hEmU)OrpA)hjnq8QCPFIuVYMcjor9Rz)ePELnfsCiBUuLle1pWrPcqWM6dpg3FuaoA)hjnq8QCPFIuVYMcjor9Rz)ePELnfsCiBUuLle1pWrPcqWM6dpg3FuW9O9FK0aXRYL(js9kBkK4e1VM9tK6v2uiXHS5svUqu)ahLkabBQp8yC)rLNhT)JKgiEvU0prQxztHeNO(1SFIuVYMcjoKnxQYfI6hyaOcqWM6dpg3Fu55r7)iPbIxLl9teorRsJvGeNO(1SFIWjAvAScK4q2CPkxiQFGJsfGGn1hEmU)Oc(O9FK0aXRYL(js9kBkK4e1VM9tK6v2uiXHS5svUqu)ahLkabBQp8yC)rbhhT)JKgiEvU0prQxztHeNO(1SFIuVYMcjoKnxQYfI6hyaOcqWM6dpg3FuWXr7)iPbIxLl9t0IAmDUKyiXjQFn7NOf1y6CjXqIdzZLQCHO(bokvac2uF4X4(JcooA)hjnq8QCPFIWjAvAScK4e1VM9teorRsJvGehYMlv5cr9dCuQaeSP(WJX9hLQC0(psAG4v5s)ePELnfsCI6xZ(js9kBkK4q2CPkxiQFGJsfGGn1hEmU)OYdhT)JKgiEvU0prQxztHeNO(1SFIuVYMcjoKnxQYfI6hyaOcqWM6dpg3Fu5HJ2)rsdeVkx6NiCIwLgRajor9Rz)eHt0Q0yfiXHS5svUqu)ahLkabBQp8yC)aaUhT)JKgiEvU0prQxztHeNO(1SFIuVYMcjoKnxQYfI6hyaOcqWM6dpg3paG7r7)iPbIxLl9t0IAmDUKyiXjQFn7NOf1y6CjXqIdzZLQCHO(bokvac2uF4X4(baCpA)hjnq8QCPFIWjAvAScK4e1VM9teorRsJvGehYMlv5cr9dCuQaeSP(WJX9dGGpA)hjnq8QCPFIWjAvAScK4e1VM9teorRsJvGehYMlv5cr9dCuQaeSPUPwEXHS8iypual4KJ2F)GHa3)CkmxTF6C7NiDhJcRyI6FzQA0z5s)48K73r180vU0FGGBKymSP(WJX9dooA)hjnq8QCP)458i9JJyQtL(bN7xZ(pmQ3Fzan4jT(tH86AU9dmXaQFGfmvac2uF4X4(bhhT)JKgiEvU0pr6ogfwHrHeNO(1SFI0DmkSc1OqItu)adquQaeSP(WJX9dooA)hjnq8QCPFI0DmkScbasCI6xZ(js3XOWkubasCI6hyaahubiyt9HhJ7NQC0(psAG4v5s)XZ5r6hhXuNk9do3VM9FyuV)YaAWtA9Nc511C7hyIbu)alyQaeSP(WJX9tvoA)hjnq8QCPFI0DmkScJcjor9Rz)eP7yuyfQrHeNO(bgaWbvac2uF4X4(PkhT)JKgiEvU0pr6ogfwHaajor9Rz)eP7yuyfQaajor9dmarPcqWM6MAWqG7NiumFhLpXe1Vh0jT(j74(Tu7NorTs)J1VsyW9pNcZvHn1hkNcZv5s)GJ(9GoP1FDWkg2uJelCt6PYiXhIdr)uv5lf8PBycJW(bNcQP82uFioe9tnAns)rfm47ha5dq0M6M6dXHO)JqWnsm(On1hIdr)uD)GLjtNOwPF5rgNvqC)dUFl1(9(p5ab3Mq)kbUFVusR)GBeJ8uR9F6MtIHn1hIdr)uD)YJmoIf4s)EPKw)c3j3rJ0p5rj0F8CEK(pKLxEyytDtTh0jnmu4YH8uY1JbKysPQvUCPREeUqEmsxnPYyn1EqN0WqHlhYtjxpgqIrxzmHW60AtTh0jnmu4YH8uY1JbKyQVxDDHGFObCrnMoxsmeNOv6CjXx(uIxCtTh0jnmu4YH8uY1JbKyLevQYx1fcEHlhCSE15KbmQ8b)qdOh0beFzJphglxurrbcji2CtHuISJBYeq9kBkeuwRCKM6dr)hHGBK4(1S)O9Rz)45eT6k3V8kyoKqS44dj9tI9ft2f2pywugti1(fUCWXkSP2d6KggkC5qEk56Xasmq(oUuLbV5NmGSsFfUCWXk4b5vugWktITIVrGStQYQxtdF1fLV0zafdzZLQCrgMvDmsyi7KQS610UyYUqiBUuLln1EqN0WqHlhYtjxpgqIPlkJjKk4hAab574svgYk9v4YbhRn1EqN0WqHlhYtjxpgqI5ZjxUycPc(HgqpOdi(YgFom(aWvgWcesqS5McPezh3KjG6v2uiOSw5iIIEqhq8Ln(Cy8baaKmba574svgYk9v4YbhRn1EqN0WqHlhYtjxpgqIHv2lrUycPc(HgqpOdi(YgFomwoaefboKGyZnfsjYoUjkQELnfckRvocqY8GoG4lB85WyabqueKVJlvziR0xHlhCS2u3u7bDsdFmGelKOMY7fti1MApOtA4JbKyHe1uEVycPc(6y8nuaeCLp4hAaxuJPZLedXSqcOhA8v4MHQF66KMOiorRsJvG2eXXxnZk(kmhCAIIahsRGokCzq8I96nPV05QOgltGf1y6CjXqmlKa6HgFfUzO6NUoPbut9HOFWjz)ob2l97wPFWSUrvJo15qZ9dw5LhPF24ZHXGtTFYC)L0is7VK9RegC)052VWQhHxC)sCWrXC)JsuPFjUFnZ(Xc9ZZi97wPFYC)b3is7FzVm1i9dM1nQ6(Xc5WqpH(LqPPXWMApOtA4JbKy66gvn6uNd9yKUycPc(HgqbuFjXkCWxHvpcVn1EqN0WhdiXcETE9GoPDRdwbV5NmG6ogfwXGFObmKGyZnfsjYoUjlKzTKKnOUOmMqQWLp9XWYczwljzdUmonxhJ013njdx(0hdlkkqibXMBkKsKDCtwiZAjjBqDrzmHuHlF6JHBQpehI(bNMREK(P9WyK6psIU9xsujTFutNA)rs0(j4G4(fIQ9lpY40CDms9FiVBsU)ss2aF)52)q3VsG7pKzTKKT(hC)AM9xtJu)A2FHREK(P9WyK6psIU9doDIkPW(puO73sJ7pP7xjWyU)qALrN0W97l3Vlv5(1S)tw7N8OegRFLa3Fu53pMdPvW9xzMShb89Re4(XZz)0EGX9hjr3(bNorL0(DunpDDcETgb2uFioe97bDsdFmGeZyY0jQvUlJZkig8dnG4eTknwbAmz6e1k3LXzfeldyjuAA4Y40CDmsxF3KmevOOyiZAjjBWLXP56yKU(Ujz4YN(yy5IkFrrPeJLrpKiO3Lp9XWhefCautTh0jn8XasSGxRxpOtA36GvWB(jdyOGBQ9GoPHpgqIf8A96bDs7whScEZpzaXk4hAa9GoG4lB85W4da3MApOtA4JbKybVwVEqN0U1bRG38tgqDNafmHuXGFOb0d6aIVSXNdJLdGM6MApOtAyyOGbuIxmVugJe4hAabwcLMgQlkJjKkevOmjuAA4Y40CDmsxF3KmevOSqcIn3uiLi74gqIIalHstd1fLXesfIkuMeknnK8ulxSWzhfdrfklKGyZnfAdjc6L2zGefboKGyZnfcInLqKvumKGyZnfACyZAUfGKjHstd1fLXesfIkuuukXyz0djc6D5tFm8brbxrrGdji2CtHuISJBYKqPPHlJtZ1XiD9DtYquHYKsmwg9qIGEx(0hdFavbCbQP2d6Kgggk4JbKys1mlxA0nc4hAaLqPPH6IYycPcrfkkgYSwsYguxugtiv4YN(yy5ax5lkkLySm6Heb9U8Ppg(GOGJMApOtAyyOGpgqI5wGX661BWRvWp0akHstd1fLXesfIkuumKzTKKnOUOmMqQWLp9XWYbUYxuukXyz0djc6D5tFm8brbhn1EqN0WWqbFmGeJEwwQMzb8dnGsO00qDrzmHuHOcffdzwljzdQlkJjKkC5tFmSCGR8ffLsmwg9qIGEx(0hdFG8UP2d6Kgggk4JbKy1HebfFPQgTq6Knf8dnGsO00qDrzmHuHLKS1u7bDsdddf8XasmHPoPb(HgqjuAAOUOmMqQquHYawcLMgkvZSurXkevOOO6ljwHeyVQeGcd6baiFGefLsmwg9qIGEx(0hdFaaGdrrGdji2CtHuISJBYKqPPHlJtZ1XiD9DtYquHYKsmwg9qIGEx(0hdFavbaGAQBQ9GoPHHyfqSYEjYftivWp0aQELnfIv2lrU0zafldyHld6skuGrHyL9sKlMqQYKqPPHyL9sKlDgqXWLp9XWhiyrrjuAAiwzVe5sNbumSKKnGKbSeknnCzCAUogPRVBsgwsYMOOaHeeBUPqkr2XnGAQ9GoPHHy9yajgLPwVycP2u7bDsddX6XasSsIkv5R6cb)qdiWHeeBUPqkr2XnzahYSwsYgCzCAUogPRVBsgU8Ppg(asHcqIIcesqS5McPezh3KjqibXMBk0gse0lTZIIHeeBUPqBirqV0old4qM1ss2GKNA5Ifo7Oy4YN(y4difkIIHmRLKSbjp1YflC2rXWLp9XWYbUYhirr1xsSc15KVAEldFqubdKmGfy9PCzqSPqVuWqMkdwXIIRpLldInf6LcgoMCGR8ffxFkxgeBk0lfmmKOMcyurrbcji2CtHuISJBIIEqhq8Ln(CySCrbQP2d6KggI1JbKy0vFzWp0aQ(E11fcrfkBrnMoxsmeNOv6CjXx(uIxCtTh0jnmeRhdiXuFV66cb)qd4IAmDUKyiorR05sIV8PeVyzQVxDDHWLp9XWhqkuKfYSwsYgKU6ldx(0hdFaPqPP2d6KggI1JbKymvewt8aIVycP2u7bDsddX6XasmYtTCXcNDum4hAafy9PCzqSPqVuWqMkdwXIIcS(uUmi2uOxkyiQqzRpLldInf6LcgwqxxN0oE9PCzqSPqVuWWXoaa5lkU(uUmi2uOxkyiQqzRpLldInf6LcgU8PpgwUOYBrrpOdi(YgFomwUOn1EqN0WqSEmGeJU6r4Yfti1MApOtAyiwpgqIvyxjCdeCkRFc(Hgq6mGIpo4y9Umj2oGodOy4PtLMApOtAyiwpgqI53t0TW7nPVHnjJBQ9GoPHHy9yajgzFQJr667MKb)qdyiZAjjBWLXP56yKU(Ujz4YN(y4difkYawa1RSPqMkcRjEaXxmHuffLqPPHs1mlvuScrfcKOOaHeeBUPqkr2XnrXqM1ss2GlJtZ1XiD9DtYWLp9XWIIsjglJEirqVlF6JHpqWn1EqN0WqSEmGeBzCAUogPRVBsg8dnGalHstdljQuLVQleIkuuua1RSPWsIkv5R6cffvFjXkuNt(Q5Tm8brbaizalW6t5YGytHEPGHmvgSIfffy9PCzqSPqVuWquHYaE9PCzqSPqVuWWc666K2XRpLldInf6Lcgo2brLVO46t5YGytHEPGHHe1uaJcKO46t5YGytHEPGHOcLT(uUmi2uOxky4YN(yy5K3IIEqhq8Ln(CySCrbQP2d6KggI1JbKyGYALJa(HgqjuAA4Y40CDmsxF3KmevOOOaHeeBUPqkr2XnzalHstdfUCyW8ftivmSKKnrrbuVYMcdeMtNx)IjKQOOh0beFzJphgFaaa1u7bDsddX6XasmSYEjYftivWp0agsqS5McPezh3KrNbu8XbhR3LjX2b0zafdpDQidyGdzwljzdUmonxhJ013njdx(0hdFaPqHQc4kdybWjAvAScKPPrXdi(62C6xpe4kVUMROOaQxztHLevQYx1fceqIIQxztHLevQYx1fklKzTKKnyjrLQ8vDHWLp9XWhaUa1u7bDsddX6XasmDrzmHub)qdOeknnu4YHbZxmHuXWss2KbCibXMBkeeBkHiROyibXMBk04WM1ClIIQxztHbVwhJ0vjWxmHuXajkkHstdxgNMRJr667MKHOcffLqPPHKNA5Ifo7OyiQqrrjuAAiOSw5iquHY8GoG4lB85Wy5IkkcSuIXYOhse07YN(y4daqWYey9PCzqSPqVuWqMkdwXa1u7bDsddX6XasS1foLl9Sm4hAaxuJPZLedXOlPXiDXesflt9kBkeRl7N1XyzahYSwsYgCzCAUogPRVBsgU8PpgwUOYxuuGqcIn3uiLi74MOOaQxztHLevQYx1fkkIt0Q0yfittJIhq81T50VEiWvEDnxGAQ9GoPHHy9yajMpNC5IjKk4drcv(Q(sIvmGrb)qdOeknnu4YHbZxmHuXWss2efbwcLMgQlkJjKkevOOinATExoqWxs8vNt(asHYXbhRxDozGKbSaQxztHbcZPZRFXesvu0d6aIVSXNdJpaaGefLqPPH6obkxmHuXWLp9XWYXuHdOkF15KL5bDaXx24ZHXYfTP2d6KggI1JbKyRlCkx6zzWp0acCiZAjjBWLXP56yKU(Ujz4YN(yy5IkFrrbcji2CtHuISJBIIcOELnfwsuPkFvxOOiorRsJvGmnnkEaXx3Mt)6Hax511CbsgDgqXhhCSExMeBhqNbum80PImGLqPPHLevQYx1fcljztuu9kBkeRl7N1XyGAQ9GoPHHy9yajwGWC686xmHub)qdOeknnu4YHbZxmHuXquHII0zaflxiX6XEqN0G(CYLlMqQWqI1MApOtAyiwpgqI5BWn(IjKk4hAaLqPPHcxomy(IjKkgIkuuKodOy5cjwp2d6Kg0NtUCXesfgsS2u7bDsddX6XasmmVcztVyDmsGpeju5R6ljwXagf8dnGltVmMGlvzzQVKyfQZjF18wgwUc666KwtTh0jnmeRhdiXK8DDsm4hAa9GoG4lB85Wy5I2u7bDsddX6XasS1foLl9Sm4hAaboKzTKKn4Y40CDmsxF3KmC5tFmSCrLVSf1y6CjXqm6sAmsxmHuXIIcesqS5McPezh3effq9kBkSKOsv(QUqrrCIwLgRazAAu8aIVUnN(1dbUYRR5cKm6mGIpo4y9Umj2oGodOy4PtfzalHstdljQuLVQlewsYMOO6v2uiwx2pRJXa1u7bDsddX6XasmjN0nPV6obkyWp0akHstd1fLXesfwsYwtTh0jnmeRhdiXORmMqyDAf8dnG4eTknwbkefROv(YlQqDstMeknnuxugtivyjjBn1EqN0WqSEmGedRSxICXesTPUP2d6KggQ7eOGjKkgqSYEjYftivWp0aQELnfIv2lrU0zaflBSlDDirqLjHstdXk7Lix6mGIHlF6JHpqWn1EqN0WqDNafmHuXhdiXOm16ftivWp0aUOgtNljgkmrdeUj9D9dDUx61jDYMILjHstdPREeEX3tFParf2u7bDsdd1DcuWesfFmGeJU6r4YftivWp0aUOgtNljgkmrdeUj9D9dDUx61jDYMIBQ9GoPHH6obkycPIpgqIvsuPkFvxi4hAaboKGyZnfsjYoUjlKzTKKn4Y40CDmsxF3KmC5tFm8bKcfrrbcji2CtHuISJBYeiKGyZnfAdjc6L2zrXqcIn3uOnKiOxANLbCiZAjjBqYtTCXcNDumC5tFm8bKcfrXqM1ss2GKNA5Ifo7Oy4YN(yy5ax5dKOO6ljwH6CYxnVLHpiQ8ffdzwljzdUmonxhJ013njdx(0hdlxu5lZd6aIVSXNdJLdCbsgWcS(uUmi2uOxkyitLbRyrX1NYLbXMc9sbdx(0hdlN8wuuGqcIn3uiLi74gqn1EqN0WqDNafmHuXhdiXuFV66cb)qd4IAmDUKyiorR05sIV8PeVyzQVxDDHWLp9XWhqkuKfYSwsYgKU6ldx(0hdFaPqPP2d6KggQ7eOGjKk(yajgD1xg81X4BOaiacg8dnGQVxDDHquHYwuJPZLedXjALoxs8LpL4f3u7bDsdd1DcuWesfFmGeJPIWAIhq8fti1MApOtAyOUtGcMqQ4JbKyKNA5Ifo7OyWp0akW6t5YGytHEPGHmvgSIffxFkxgeBk0lfmC5tFmSCrLVOOh0beFzJphglhGRpLldInf6LcggsutPQaqtTh0jnmu3jqbtiv8XasmY(uhJ013njd(HgWqM1ss2GlJtZ1XiD9DtYWLp9XWhqkuKbSaQxztHmvewt8aIVycPkkkHstdLQzwQOyfIkeirrbcji2CtHuISJBIIHmRLKSbxgNMRJr667MKHlF6JHLlQ8ffLsmwg9qIGEx(0hdFGGBQ9GoPHH6obkycPIpgqITmonxhJ013njd(HgqGdzwljzdckRvocC5tFm8bKcfrrbuVYMcbL1khruu9LeRqDo5RM3YWhefaGKbSaRpLldInf6LcgYuzWkwuC9PCzqSPqVuWWLp9XWYjVff9GoG4lB85Wy5aC9PCzqSPqVuWWqIAkvfaaQP2d6KggQ7eOGjKk(yajgOSw5iGFObucLMgUmonxhJ013njdrfkkkqibXMBkKsKDCRP2d6KggQ7eOGjKk(yajMKVRtIBQ9GoPHH6obkycPIpgqIPlkJjKk4hAaLqPPHlJtZ1XiD9DtYquHIIHmRLKSbxgNMRJr667MKHlF6JHLlQ8fffiKGyZnfsjYoUjkkLySm6Heb9U8Ppg(aaKFtTh0jnmu3jqbtiv8XasS1foLl9Sm4hAaxuJPZLedXOlPXiDXesfld4qM1ss2GlJtZ1XiD9DtYWLp9XWYfv(IIcesqS5McPezh3effq9kBkSKOsv(QUqGKjHstd1DcuUycPIHlF6JHLdqMkCav5RoNCtTh0jnmu3jqbtiv8XasmFo5YftivWhIeQ8v9LeRyaJc(HgqjuAAOUtGYftivmC5tFmSCaYuHdOkF15KLbSeknnu4YHbZxmHuXWss2efPrR17Ybc(sIV6CYheCSE15KpMuOikkHstd1fLXesfIkeOMApOtAyOUtGcMqQ4JbKyf2vc3abNY6NGFObKodO4JdowVltITdOZakgE6uPP2d6KggQ7eOGjKk(yaj26cNYLEwg8dnGahYSwsYgCzCAUogPRVBsgU8PpgwUOYx2IAmDUKyigDjngPlMqQyrrbcji2CtHuISJBIIcSOgtNljgIrxsJr6IjKkwuua1RSPWsIkv5R6cbsMeknnu3jq5IjKkgU8PpgwoazQWbuLV6CYn1EqN0WqDNafmHuXhdiXorR6GjKk4hAaLqPPH6obkxmHuXWss2efLqPPHcxomy(IjKkgIkugDgqXYfsSESh0jnOpNC5IjKkmKyvgWcOELnfgimNoV(ftivrrpOdi(YgFomwoWfOMApOtAyOUtGcMqQ4JbKybcZPZRFXesf8dnGsO00qHlhgmFXesfdrfkJodOy5cjwp2d6Kg0NtUCXesfgsSkZd6aIVSXNdJpqE2u7bDsdd1DcuWesfFmGeJYuRxmHub)qdOeknnSWE5YryyjjBn1EqN0WqDNafmHuXhdiX87j6w49M03WMKXn1EqN0WqDNafmHuXhdiXOREeUCXesTP2d6KggQ7eOGjKk(yajgMxHSPxSogjWhIeQ8v9LeRyaJc(HgWLPxgtWLQCtTh0jnmu3jqbtiv8XasSt0QoycPc(Hgq6mGILlKy9ypOtAqFo5YftivyiXQmGdzwljzdUmonxhJ013njdx(0hdlNGfffiKGyZnfsjYoUbutTh0jnmu3jqbtiv8Xasm13RUUqWp0aUOgtNljgAmgpgjY(gbF11fkCmsxxOqFDff3u7bDsdd1DcuWesfFmGeJEz(qpgPRUUqWp0aUOgtNljgAmgpgjY(gbF11fkCmsxxOqFDff3u7bDsdd1DcuWesfFmGetYjDt6RUtGcg8dnGsO00qDrzmHuHLKS1u7bDsdd1DcuWesfFmGeJUYycH1PvWp0aIt0Q0yfOquSIw5lVOc1jnzsO00qDrzmHuHLKS1u7bDsdd1DcuWesfFmGedRSxICXesTPUP2d6KggQ7yuyfdiiFhxQYG38tgqCelCrfcEqEfLbucLMgUmonxhJ013njdrfkkkHstd1fLXesfIkSP2d6KggQ7yuyfFmGedKVJlvzWB(jdiw30iDXrSWfvi4b5vugWqcIn3uiLi74MmjuAA4Y40CDmsxF3KmevOmjuAAOUOmMqQquHIIcesqS5McPezh3KjHstd1fLXesfIkSP2d6KggQ7yuyfFmGedKVJlvzWB(jdiw30iDXrSWD5tFmm4tHaIzDObpiVIYagYSwsYgCzCAUogPRVBsgU8Ppg(GdPHmRLKSb1fLXesfU8Ppgg8G8kkF5kMbmKzTKKnOUOmMqQWLp9XWGFObucLMgQlkJjKkSKKnzHeeBUPqkr2XTMApOtAyOUJrHv8Xasmq(oUuLbV5NmGyDtJ0fhXc3Lp9XWGpfciM1Hg8G8kkdyiZAjjBWLXP56yKU(Ujz4YN(yyWdYRO8LRygWqM1ss2G6IYycPcx(0hdd(HgqjuAAOUOmMqQquHYcji2CtHuISJBn1EqN0WqDhJcR4JbKyG8DCPkdEZpzaXrSWD5tFmm4tHaIzDOb)qdyibXMBkKsKDCd8G8kkdyiZAjjBWLXP56yKU(Ujz4YN(yy5oKgYSwsYguxugtiv4YN(yyWdYRO8LRygWqM1ss2G6IYycPcx(0hd3u7bDsdd1DmkSIpgqIHI57O8jg84AQya1DmkSgf8dnGaR7yuyfgfsWXxumFLqPPffdji2CtHuISJBY0DmkScJcj44BiZAjjBajdyq(oUuLHyDtJ0fhXcxuHYawGqcIn3uiLi74Mmb0DmkScbasWXxumFLqPPffdji2CtHuISJBYeq3XOWkeaibhFdzwljztuu3XOWkeayiZAjjBWLp9XWII6ogfwHrHeC8ffZxjuAAzalGUJrHviaqco(II5ReknTOOUJrHvyuyiZAjjBWc666KMCaQ7yuyfcamKzTKKnybDDDsdirrDhJcRWOqco(gYSwsYMmb0DmkScbasWXxumFLqPPLP7yuyfgfgYSwsYgSGUUoPjhG6ogfwHaadzwljzdwqxxN0asuuaq(oUuLHyDtJ0fhXcxuHYawaDhJcRqaGeC8ffZxjuAAzaR7yuyfgfgYSwsYgSGUUoPr1c(aq(oUuLH4iw4U8PpgwueKVJlvzioIfUlF6JHLt3XOWkmkmKzTKKnybDDDsdCgaGef1DmkScbasWXxumFLqPPLbSUJrHvyuibhFrX8vcLMwMUJrHvyuyiZAjjBWc666KMCaQ7yuyfcamKzTKKnybDDDstgW6ogfwHrHHmRLKSblORRtAuTGpaKVJlvzioIfUlF6JHffb574svgIJyH7YN(yy50DmkScJcdzwljzdwqxxN0aNbairrGfq3XOWkmkKGJVOy(kHstlkQ7yuyfcamKzTKKnybDDDstoa1DmkScJcdzwljzdwqxxN0asgW6ogfwHaadzwljzdUSxIit3XOWkeayiZAjjBWc666Kgvly5a574svgIJyH7YN(yyzG8DCPkdXrSWD5tFm8b6ogfwHaadzwljzdwqxxN0aNbquuaDhJcRqaGHmRLKSbx2lrKbSUJrHviaWqM1ss2GlF6JHPAbFaiFhxQYqSUPr6IJyH7YN(yyzG8DCPkdX6MgPloIfUlF6JHLda5ldyDhJcRWOWqM1ss2Gf011jnQwWhaY3XLQmehXc3Lp9XWII6ogfwHaadzwljzdU8PpgMQf8bG8DCPkdXrSWD5tFmSmDhJcRqaGHmRLKSblORRtAuDu5FmiFhxQYqCelCx(0hdFaiFhxQYqSUPr6IJyH7YN(yyrrq(oUuLH4iw4U8PpgwoDhJcRWOWqM1ss2Gf011jnWzaefb574svgIJyHlQqGef1DmkScbagYSwsYgC5tFmmvly5a574svgI1nnsxCelCx(0hdldyDhJcRWOWqM1ss2Gf011jnQwWhaY3XLQmeRBAKU4iw4U8PpgwuuaDhJcRWOqco(II5ReknTmGb574svgIJyH7YN(yy50DmkScJcdzwljzdwqxxN0aNbqueKVJlvzioIfUOcbciGaciGefLsmwg9qIGEx(0hdFaiFhxQYqCelCx(0hddKOOa6ogfwHrHeC8ffZxjuAAzcesqS5McPezh3KbSUJrHviaqco(II5ReknTmGbwaq(oUuLH4iw4Ikuuu3XOWkeayiZAjjBWLp9XWYjyGKbmiFhxQYqCelCx(0hdlhaYxuu3XOWkeayiZAjjBWLp9XWuTGLdKVJlvzioIfUlF6JHbcirrb0DmkScbasWXxumFLqPPLbSa6ogfwHaaj44BiZAjjBII6ogfwHaadzwljzdU8Ppgwuu3XOWkeayiZAjjBWc666KMCaQ7yuyfgfgYSwsYgSGUUoPbeqn1EqN0WqDhJcR4JbKyOy(okFIbpUMkgqDhJcRaa(HgqG1DmkScbasWXxumFLqPPffdji2CtHuISJBY0DmkScbasWX3qM1ss2asgWG8DCPkdX6MgPloIfUOcLbSaHeeBUPqkr2XnzcO7yuyfgfsWXxumFLqPPffdji2CtHuISJBYeq3XOWkmkKGJVHmRLKSjkQ7yuyfgfgYSwsYgC5tFmSOOUJrHviaqco(II5ReknTmGfq3XOWkmkKGJVOy(kHstlkQ7yuyfcamKzTKKnybDDDstoa1DmkScJcdzwljzdwqxxN0asuu3XOWkeaibhFdzwljztMa6ogfwHrHeC8ffZxjuAAz6ogfwHaadzwljzdwqxxN0KdqDhJcRWOWqM1ss2Gf011jnGeffaKVJlvziw30iDXrSWfvOmGfq3XOWkmkKGJVOy(kHstldyDhJcRqaGHmRLKSblORRtAuTGpaKVJlvzioIfUlF6JHffb574svgIJyH7YN(yy50DmkScbagYSwsYgSGUUoPbodaqII6ogfwHrHeC8ffZxjuAAzaR7yuyfcaKGJVOy(kHstlt3XOWkeayiZAjjBWc666KMCaQ7yuyfgfgYSwsYgSGUUoPjdyDhJcRqaGHmRLKSblORRtAuTGpaKVJlvzioIfUlF6JHffb574svgIJyH7YN(yy50DmkScbagYSwsYgSGUUoPbodaqIIalGUJrHviaqco(II5ReknTOOUJrHvyuyiZAjjBWc666KMCaQ7yuyfcamKzTKKnybDDDsdizaR7yuyfgfgYSwsYgCzVerMUJrHvyuyiZAjjBWc666Kgvly5a574svgIJyH7YN(yyzG8DCPkdXrSWD5tFm8b6ogfwHrHHmRLKSblORRtAGZaikkGUJrHvyuyiZAjjBWL9sezaR7yuyfgfgYSwsYgC5tFmmvl4da574svgI1nnsxCelCx(0hdldKVJlvziw30iDXrSWD5tFmSCaiFzaR7yuyfcamKzTKKnybDDDsJQf8bG8DCPkdXrSWD5tFmSOOUJrHvyuyiZAjjBWLp9XWuTGpaKVJlvzioIfUlF6JHLP7yuyfgfgYSwsYgSGUUoPr1rL)XG8DCPkdXrSWD5tFm8bG8DCPkdX6MgPloIfUlF6JHffb574svgIJyH7YN(yy50DmkScbagYSwsYgSGUUoPbodGOiiFhxQYqCelCrfcKOOUJrHvyuyiZAjjBWLp9XWuTGLdKVJlvziw30iDXrSWD5tFmSmG1DmkScbagYSwsYgSGUUoPr1c(aq(oUuLHyDtJ0fhXc3Lp9XWIIcO7yuyfcaKGJVOy(kHstldyq(oUuLH4iw4U8PpgwoDhJcRqaGHmRLKSblORRtAGZaikcY3XLQmehXcxuHabeqabeqIIsjglJEirqVlF6JHpaKVJlvzioIfUlF6JHbsuuaDhJcRqaGeC8ffZxjuAAzcesqS5McPezh3KbSUJrHvyuibhFrX8vcLMwgWalaiFhxQYqCelCrfkkQ7yuyfgfgYSwsYgC5tFmSCcgizadY3XLQmehXc3Lp9XWYbG8ff1DmkScJcdzwljzdU8PpgMQfSCG8DCPkdXrSWD5tFmmqajkkGUJrHvyuibhFrX8vcLMwgWcO7yuyfgfsWX3qM1ss2ef1DmkScJcdzwljzdU8Ppgwuu3XOWkmkmKzTKKnybDDDstoa1DmkScbagYSwsYgSGUUoPbeqiXyHCabSaiy5jIIOiia]] )

    
end