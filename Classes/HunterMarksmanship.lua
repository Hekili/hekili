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
            max_stack = 2,
        },
        trueshot = {
            id = 288613,
            duration = function () return ( legendary.eagletalons_true_focus.enabled and 20 or 15 ) * ( 1 + ( conduit.sharpshooters_focus.mod * 0.01 ) ) end,
            max_stack = 1,
        },
        volley = {
            id = 260243,
            duration = 6,
            max_stack = 1,
        },

        
        -- Legendaries
        nessingwarys_trapping_apparatus = {
            id = 336744,
            duration = 5,
            max_stack = 1,
            copy = { "nesingwarys_trapping_apparatus", "nesingwarys_apparatus", "nessingwarys_apparatus" }
        },

        -- stub.
        eagletalons_true_focus_stub = {
            duration = 10,
            max_stack = 1,
            copy = "eagletalons_true_focus"
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


    spec:RegisterStateTable( "tar_trap", setmetatable( {}, {
        __index = function( t, k )
            return debuff.tar_trap[ k ]
        end
    }, state ) )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364491, "tier28_4pc", 363666 )
    -- 2-Set - Focused Trickery - Trick Shots now also increases the damage of the affected shot by 30%.
    -- 4-Set - Focused Trickery - Spending 40 Focus grants you 1 charge of Trick Shots.

    local focusSpent = 0

    local FOCUS = Enum.PowerType.Focus
    local lastFocus = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "FOCUS" then
            local current = UnitPower( "player", FOCUS )

            if current < lastFocus then
                focusSpent = ( focusSpent + lastFocus - current ) % 40
            end

            lastFocus = current
        end
    end )

    spec:RegisterStateExpr( "focused_trickery_count", function ()
        return focusSpent
    end )

    spec:RegisterHook( "spend", function( amt, resource )
        if set_bonus.tier28_4pc > 0 and resource == "focus" then
            focused_trickery_count = focused_trickery_count + amt
            if focused_trickery_count >= 40 then
                applyBuff( "trick_shots" )
                focused_trickery_count = focused_trickery_count % 40
            end
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        if now - action.serpent_sting.lastCast < gcd.execute * 2 and target.unit == action.serpent_sting.lastUnit then
            applyDebuff( "target", "serpent_sting" )
        end

        if debuff.tar_trap.up then
            debuff.tar_trap.expires = debuff.tar_trap.applied + 30
        end

        if buff.nesingwarys_apparatus.up then
            state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireNesingwarysTrappingApparatus, buff.nesingwarys_apparatus.expires )
        end

        if legendary.eagletalons_true_focus.enabled then
            rawset( buff, "eagletalons_true_focus", buff.trueshot_aura )
        else
            rawset( buff, "eagletalons_true_focus", buff.eagletalons_true_focus_stub )
        end


        if now - action.volley.lastCast < 6 then applyBuff( "volley", 6 - ( now - action.volley.lastCast ) ) end

        if now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end

        last_steady_focus = nil
        focused_trickery_count = nil
    end )


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
                if buff.volley.down and buff.trick_shots.up then removeBuff( "trick_shots" ) end
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


    spec:RegisterPack( "Marksmanship", 20220226, [[daf1pcqicPhrOQCjGc1MisFcHmkvkNsL0Qqsu8kvIMfqLBHKWUa9lekdJq0XOIwgvQNbu00qsKRrOY2OssFJqv14iufohvsyDQe6DafqnpQe3tLQ9rO8pGcWbPsIAHecpuLGjsOkYfbkO2iHQu6JafOrsOkfNKkjYkrs9sKeLAMuj1nrsuYobk9tGcYqjuLQLsOk5PsQPcu1xjuf1yrOAVq8xadwvhwyXe1JPQjlXLrTzK6ZiQrJGtRy1afqEnsmBvCBjz3u(TOHtehhjr1Yv65qnDsxhsBhiFhrgpssNNkSEGcz(eSFPgXjc4rQlHYiG1TiD7wKUD7Qq3UbtQevYvGuRoKWi1scpLGmJuBrfJutLvSuWvHHjmsqQLeoozuqapsnorxpJul(6NGQsWxKyeJ8OeqLH(SIy4Pc9e6KMFdALy4PYtmKAz05OUsgImsDjugbSUfPB3I0TBxf62nysLOsorQduLqUi11t1fqQjmLcBiYi1fg7rQPYkwk4QWWegj9lEdQP82ulEllVOX6OF3obx)UfPB3n1n1xGqyKz8fBQPI(bltIorTs)IxmopG4(hC)wQ9h9xXEcHn((vcC)rPKw)(WigP5C6VkSGmdBQPI(fVySdZZL(JsjT(LStUJ6OFsJsO)6P6c97klE31WMAQOFxZA)uz7yNWW9xySdZ3VsGNT)liEc3poRyDQymeP(myfJaEKADhpfmHuXiGhbSorapsnBH8HliIaP2VJY7ei1ACytHyLJIda60JIHSfYhU0V0(hdG(mKjO9lTFzuAAiw5O4aGo9Oy4YvXy4(DPFXHuhEDsdPgRCuCaGjKkIIaw3iGhPMTq(WferGu73r5DcK6f1y6CjZqjjQNaqsdSbyuUa0BqUInfdzlKpCPFP9lJstdPpHdEXavXsbIkbPo86KgsnL5CaWesfrralyIaEKA2c5dxqebsTFhL3jqQxuJPZLmdLKOEcajnWgGr5cqVb5k2umKTq(WfK6WRtAi10NWbxaWesfrralvcb8i1SfYhUGicKA)okVtGuFRFFcITWuifh7ew)s73N5PKKm4Y40cDmYaXUjj4YvXy4(DPFY(s)cc9lA)(eeBHPqko2jS(L2VO97tqSfMcTHmbfGo4(fe63NGylmfAdzckaDW9lT)B97Z8ussgK0CkayjZokgUCvmgUFx6NSV0VGq)(mpLKKbjnNcawYSJIHlxfJH7xS(btr2)1(fe6xJLmRqDQyanbkd3Vl97uK9li0VpZtjjzWLXPf6yKbIDtsWLRIXW9lw)ofz)s7p86aIbyJRgg3Vy9dM9FTFP9FRFr7FJPaWGytHrPGHmvhSI7xqO)nMcadInfgLcgUCvmgUFX63v0VGq)I2VpbXwykKIJDcR)Ri1HxN0qQljQ8Hb0qcIIawXHaEKA2c5dxqebsTFhL3jqQxuJPZLmdXj6HoxYmaxjZlgYwiF4s)s7xJfq3qcC5QymC)U0pzFPFP97Z8ussgK(eldxUkgd3Vl9t2xqQdVoPHuRXcOBibrraRRIaEKA2c5dxqebsD41jnKA6tSmsTFhL3jqQ1yb0nKarL0V0(xuJPZLmdXj6HoxYmaxjZlgYwiF4cs9zmgWxqQDloefbSIFeWJuhEDsdPMPQKtIhqmaMqQi1SfYhUGicefbSIhiGhPMTq(WferGu73r5DcKAr7FJPaWGytHrPGHmvhSI7xqO)nMcadInfgLcgUCvmgUFX63Pi7xqO)WRdigGnUAyC)IDV)nMcadInfgLcg6tut7Nkt)UrQdVoPHutAofaSKzhfJOiG1vGaEKA2c5dxqebsTFhL3jqQ9zEkjjdUmoTqhJmqSBscUCvmgUFx6NSV0V0(V1VO9RXHnfYuvYjXdigativiBH8Hl9li0Vmknnu(Kz5GIviQK(V2VGq)I2VpbXwykKIJDcRFbH(9zEkjjdUmoTqhJmqSBscUCvmgUFX63Pi7xqOF5eJ7xA)0dzckWYvXy4(DPFXHuhEDsdPMumNXide7MKqueW6uKiGhPMTq(WferGu73r5DcK6B97Z8ussgeuEoSd4YvXy4(DPFY(s)cc9lA)ACytHGYZHDazlKpCPFbH(1yjZkuNkgqtGYW97s)oD3)1(L2)T(fT)nMcadInfgLcgYuDWkUFbH(3ykami2uyuky4YvXy4(fRFxr)cc9hEDaXaSXvdJ7xS79VXuayqSPWOuWqFIAA)uz63D)xrQdVoPHuVmoTqhJmqSBscrraRtNiGhPMTq(WferGu73r5DcKAzuAA4Y40cDmYaXUjjiQK(fe6x0(9ji2ctHuCStyi1HxN0qQbLNd7arraRt3iGhPo86KgsTCSBqMrQzlKpCbreikcyDcMiGhPMTq(WferGu73r5DcKAzuAA4Y40cDmYaXUjjiQK(fe63N5PKKm4Y40cDmYaXUjj4YvXy4(fRFNISFbH(fTFFcITWuifh7ew)cc9lNyC)s7NEitqbwUkgd3Vl97wKi1HxN0qQ1fLXesfrraRtQec4rQzlKpCbrei1(DuENaPErnMoxYmeJUKhJmaMqQyiBH8Hl9lT)B97Z8ussgCzCAHogzGy3KeC5QymC)I1Vtr2VGq)I2VpbXwykKIJDcRFbH(fTFnoSPWsIkFyanKazlKpCP)R9lTFzuAAOUJNcaMqQy4YvXy4(f7E)mvzpQYa6uXi1HxN0qQ3qYuaONLrueW6uCiGhPMTq(WferGuhEDsdPoMkUaGjKksTFhL3jqQLrPPH6oEkaycPIHlxfJH7xS79ZuL9OkdOtf3V0(V1VmknnuYY(bZaycPIHLKK1VGq)0ONdWYEcXsMb0PI73L(9bwb0PI7)Y(j7l9li0VmknnuxugtiviQK(VIu7D4pmGglzwXiG1jIIawNUkc4rQzlKpCbrei1(DuENaPMo9O4(VSFFGvGLjZw)U0pD6rXWQGQi1HxN0qQlCOea8eckBuHOiG1P4hb8i1SfYhUGicKA)okVtGuFRFFMNssYGlJtl0Xide7MKGlxfJH7xS(DkY(L2)IAmDUKzigDjpgzamHuXq2c5dx6xqOFr73NGylmfsXXoH1VGq)I2)IAmDUKzigDjpgzamHuXq2c5dx6xqOFr7xJdBkSKOYhgqdjq2c5dx6)A)s7xgLMgQ74PaGjKkgUCvmgUFXU3ptv2JQmGovmsD41jnK6nKmfa6zzefbSofpqapsnBH8HliIaP2VJY7ei1YO00qDhpfamHuXWssY6xqOFzuAAOKL9dMbWesfdrL0V0(PtpkUFX63NyT)l7p86KgmMkUaGjKk0NyTFP9FRFr7xJdBk0tyQcEdamHuHSfYhU0VGq)HxhqmaBC1W4(fRFWS)Ri1HxN0qQRqp6GjKkIIawNUceWJuZwiF4cIiqQ97O8obsTmknnuYY(bZaycPIHOs6xA)0Phf3Vy97tS2)L9hEDsdgtfxaWesf6tS2V0(dVoGya24QHX97s)ujK6WRtAi1EctvWBaGjKkIIaw3Ieb8i1SfYhUGicKA)okVtGulJstdlCuayhmSKKmK6WRtAi1uMZbativefbSUDIaEK6WRtAi1bqf6w4fiPb8BscJuZwiF4cIiqueW62nc4rQdVoPHutFchCbativKA2c5dxqebIIaw3Gjc4rQzlKpCbrei1HxN0qQX8kHnfaRJrgP2VJY7ei1ltVmMqiFyKAVd)Hb0yjZkgbSorueW6MkHaEKA2c5dxqebsTFhL3jqQPtpkUFX63NyT)l7p86KgmMkUaGjKk0NyTFP9FRFFMNssYGlJtl0Xide7MKGlxfJH7xS(fx)cc9lA)(eeBHPqko2jS(VIuhEDsdPUc9OdMqQikcyDloeWJuZwiF4cIiqQ97O8obs9IAmDUKzOXy8yKjfRdmGUHejJrgiKij2qrXq2c5dxqQdVoPHuRXcOBibrraRBxfb8i1SfYhUGicKA)okVtGuVOgtNlzgAmgpgzsX6adOBirYyKbcjsInuumKTq(WfK6WRtAi10lZGrJrgq3qcIIaw3IFeWJuZwiF4cIiqQ97O8obsTmknnuxugtivyjjzi1HxN0qQLdYajnGUJNcgrraRBXdeWJuZwiF4cIiqQ97O8obsnorpYJvGsqXk6Hb4fvIoPbzlKpCPFP9lJstd1fLXesfwssgsD41jnKA6dJj43GwrueW62vGaEK6WRtAi1yLJIdamHurQzlKpCbreikIIuxy6a9OiGhbSorapsD41jnKAFIAkVaycPIuZwiF4cIiqueW6gb8i1SfYhUGicK6WRtAi1(e1uEbWesfP2VJY7ei1lQX05sMHywcbuWimGKn9NOk0jniBH8Hl9li0porpYJvG24iWaAMhmGKCWPbzlKpCPFbH(V1VpTc6OWLbXlooajnaDUkQXq2c5dx6xA)I2)IAmDUKziMLqafmcdizt)jQcDsdYwiF4s)xrQpJXa(csnyksefbSGjc4rQzlKpCbrei1HxN0qQ1nmQC05mGrJrgativK6cJ97irN0qQbdM9he4O0FyL(b)ggvo6CgWiUFWkE)c9ZgxnmgC9tI7VKgrA)LSFLWG7No3(LCch8I7xM9bkM7FuIk9lZ9Rz2pwsuv5O)Wk9tI73hgrA)lhL54OFWVHrL3pwc7h6X3VmknngIu73r5DcKAr7xJLmRWbdi5eo4frralvcb8i1SfYhUGicKA)okVtGu7tqSfMcP4yNW6xA)(mpLKKb1fLXesfUCvmgUFP97Z8ussgCzCAHogzGy3KeC5QymC)cc9lA)(eeBHPqko2jS(L2VpZtjjzqDrzmHuHlxfJHrQdVoPHu7JZbi86KgWzWks9zWkGfvmsTUJrHvmIIawXHaEKA2c5dxqebsD41jnKAFCoaHxN0aodwrQpdwbSOIrQ9fmIIawxfb8i1SfYhUGicKA)okVtGuhEDaXaSXvdJ73L(btKASUJxraRtK6WRtAi1(4CacVoPbCgSIuFgScyrfJuJvefbSIFeWJuZwiF4cIiqQ97O8obsD41bedWgxnmUFX63nsnw3XRiG1jsD41jnKAFCoaHxN0aodwrQpdwbSOIrQ1D8uWesfJOiksTKL9zLCOiGhbSorapsD41jnKA5u1dxaOpHdUqAmYaAs1XqQzlKpCbreikcyDJaEK6WRtAi10hgtWVbTIuZwiF4cIiqueWcMiGhPMTq(WferGu73r5DcK6f1y6CjZqCIEOZLmdWvY8IHSfYhUGuhEDsdPwJfq3qcIIawQec4rQzlKpCbrei1sw2hyfqNkgP2PirQdVoPHuxsu5ddOHeKA)okVtGuhEDaXaSXvdJ7xS(D2VGq)I2VpbXwykKIJDcRFP9lA)ACytHGYZHDazlKpCbrraR4qapsnBH8HliIaP2VJY7ei1HxhqmaBC1W4(DPFWSFP9FRFr73NGylmfsXXoH1V0(fTFnoSPqq55WoGSfYhU0VGq)HxhqmaBC1W4(DPF39FfPo86KgsDmvCbativefbSUkc4rQzlKpCbrei1(DuENaPo86aIbyJRgg3Vy97UFbH(V1VpbXwykKIJDcRFbH(14WMcbLNd7aYwiF4s)x7xA)HxhqmaBC1W4(V3VBK6WRtAi1yLJIdamHuruefP2xWiGhbSorapsnBH8HliIaP2VJY7ei136xgLMgQlkJjKkevs)s7xgLMgUmoTqhJmqSBscIkPFP97tqSfMcP4yNW6)A)cc9FRFzuAAOUOmMqQquj9lTFzuAAiP5uaWsMDumevs)s73NGylmfAdzckaDW9FTFbH(V1VpbXwykeeBkbhB)cc97tqSfMcn2V5j3s)x7xA)YO00qDrzmHuHOs6xqOF5eJ7xA)0dzckWYvXy4(DPFNGz)cc9FRFFcITWuifh7ew)s7xgLMgUmoTqhJmqSBscIkPFP9tpKjOalxfJH73L(f)Gz)xrQdVoPHulZlMxkJrgrraRBeWJuZwiF4cIiqQ97O8obsTmknnuxugtiviQK(fe63N5PKKmOUOmMqQWLRIXW9lw)GPi7xqOF5eJ7xA)0dzckWYvXy4(DPFNUksD41jnKA5tMfaA01bIIawWeb8i1SfYhUGicKA)okVtGulJstd1fLXesfIkPFbH(9zEkjjdQlkJjKkC5QymC)I1pykY(fe6xoX4(L2p9qMGcSCvmgUFx63PRIuhEDsdPompJ1noa(4CqueWsLqapsnBH8HliIaP2VJY7ei1YO00qDrzmHuHOs6xqOFFMNssYG6IYycPcxUkgd3Vy9dMISFbH(LtmUFP9tpKjOalxfJH73L(Dfi1HxN0qQPNLLpzwqueWkoeWJuZwiF4cIiqQ97O8obsTmknnuxugtivyjjzi1HxN0qQpdzckgamqOfYvSPikcyDveWJuZwiF4cIiqQ97O8obsTmknnuxugtiviQK(L2)T(LrPPHYNmlhuScrL0VGq)ASKzfsGJJsakXR97s)Ufz)x7xqOF5eJ7xA)0dzckWYvXy4(DPF3UA)cc9FRFFcITWuifh7ew)s7xgLMgUmoTqhJmqSBscIkPFP9tpKjOalxfJH73L(f)U7)ksD41jnKAjPoPHOiksnwrapcyDIaEKA2c5dxqebsTFhL3jqQ14WMcXkhfha0PhfdzlKpCPFP9FRFjldcGSVaDcXkhfhaycP2V0(LrPPHyLJIda60JIHlxfJH73L(fx)cc9lJstdXkhfha0PhfdljjR)R9lT)B9lJstdxgNwOJrgi2njbljjRFbH(fTFFcITWuifh7ew)xrQdVoPHuJvokoaWesfrraRBeWJuhEDsdPMYCoaycPIuZwiF4cIiqueWcMiGhPMTq(WferGu73r5DcK6B97tqSfMcP4yNW6xA)363N5PKKm4Y40cDmYaXUjj4YvXy4(DPFY(s)x7xqOFr73NGylmfsXXoH1V0(fTFFcITWuOnKjOa0b3VGq)(eeBHPqBitqbOdUFP9FRFFMNssYGKMtbalz2rXWLRIXW97s)K9L(fe63N5PKKmiP5uaWsMDumC5QymC)I1pykY(V2VGq)0dzckWYvXy4(DPFNIR)R9lT)B9lA)BmfageBkmkfmKP6GvC)cc9VXuayqSPWOuWquj9lT)B9VXuayqSPWOuWWX63L(DkY(L2)gtbGbXMcJsbdxUkgd3Vl9dM9li0)gtbGbXMcJsbdhRFX6p86KgGpZtjjz9li0F41bedWgxnmUFX63z)x7xqOFr7FJPaWGytHrPGHOs6xA)36FJPaWGytHrPGH(e10(V3VZ(fe6FJPaWGytHrPGHJ1Vy9hEDsdWN5PKKS(V2)vK6WRtAi1Lev(WaAibrralvcb8i1SfYhUGicKA)okVtGuRXcOBibIkPFP9VOgtNlzgIt0dDUKzaUsMxmKTq(WfK6WRtAi10NyzefbSIdb8i1SfYhUGicKA)okVtGuVOgtNlzgIt0dDUKzaUsMxmKTq(WL(L2VglGUHe4YvXy4(DPFY(s)s73N5PKKmi9jwgUCvmgUFx6NSVGuhEDsdPwJfq3qcIIawxfb8i1HxN0qQzQk5K4bedGjKksnBH8HliIarraR4hb8i1SfYhUGicKA)okVtGuFRFFMNssYG6IYycPcxUkgd3Vl9t2x6xqOFzuAAOUOmMqQquj9FTFP9FRFr7FJPaWGytHrPGHmvhSI7xqOFr7FJPaWGytHrPGHOs6xA)BmfageBkmkfmSGUHoP1)L9VXuayqSPWOuWWX63L(DlY(fe6FJPaWGytHrPGHOs6xA)BmfageBkmkfmC5QymC)I1Vtxr)cc9hEDaXaSXvdJ7xS(D2)1(fe6NEitqbwUkgd3Vl9lEisK6WRtAi1KMtbalz2rXikcyfpqapsD41jnKA6t4GlaycPIuZwiF4cIiqueW6kqapsnBH8HliIaP2VJY7ei10Phf3)L97dScSmz263L(PtpkgwfufPo86KgsDHdLaGNqqzJkefbSofjc4rQdVoPHuhavOBHxGKgWVjjmsnBH8HliIarraRtNiGhPMTq(WferGu73r5DcKAFMNssYGlJtl0Xide7MKGlxfJH73L(j7l9lT)B9lA)ACytHmvLCs8aIbWesfYwiF4s)cc9lJstdLpzwoOyfIkP)R9li0VO97tqSfMcP4yNW6xqOFFMNssYGlJtl0Xide7MKGlxfJH7xqOF5eJ7xA)0dzckWYvXy4(DPFXHuhEDsdPMumNXide7MKqueW60nc4rQzlKpCbrei1(DuENaP(w)YO00WsIkFyanKarL0VGq)I2Vgh2uyjrLpmGgsGSfYhU0VGq)0dzckWYvXy4(DPFNU7)A)s7)w)I2)gtbGbXMcJsbdzQoyf3VGq)I2)gtbGbXMcJsbdrL0V0(V1)gtbGbXMcJsbdlOBOtA9Fz)BmfageBkmkfmCS(DPFNISFbH(3ykami2uyukyOprnT)797S)R9li0)gtbGbXMcJsbdrL0V0(3ykami2uyuky4YvXy4(fRFxr)cc9hEDaXaSXvdJ7xS(D2)vK6WRtAi1lJtl0Xide7MKqueW6emrapsnBH8HliIaP2VJY7ei1YO00WLXPf6yKbIDtsquj9li0VO97tqSfMcP4yNW6xA)36xgLMgkzz)GzamHuXWssY6xqOFr7xJdBk0tyQcEdamHuHSfYhU0VGq)HxhqmaBC1W4(DPF39FfPo86KgsnO8CyhikcyDsLqapsnBH8HliIaP2VJY7ei1(eeBHPqko2jS(L2pD6rX9Fz)(aRaltMT(DPF60JIHvbv7xA)36)w)(mpLKKbxgNwOJrgi2njbxUkgd3Vl9t2x6Nkt)Gz)s7)w)I2porpYJvGmnnkEaXaHnvbq498H3qZfYwiF4s)cc9lA)ACytHLev(WaAibYwiF4s)x7)A)cc9RXHnfwsu5ddOHeiBH8Hl9lTFFMNssYGLev(WaAibUCvmgUFx6hm7)ksD41jnKASYrXbaMqQikcyDkoeWJuZwiF4cIiqQ97O8obs9IAmDUKzigDjpgzamHuXq2c5dx6xA)ACytHyD5O6mgdzlKpCPFP9FRFFMNssYGlJtl0Xide7MKGlxfJH7xS(DkY(fe6x0(9ji2ctHuCSty9li0VO9RXHnfwsu5ddOHeiBH8Hl9li0porpYJvGmnnkEaXaHnvbq498H3qZfYwiF4s)xrQdVoPHuVHKPaqplJOiG1PRIaEKA2c5dxqebsTFhL3jqQV1)T(LrPPHsw2pygativmSKKS(fe6xJdBk0hNZyKbucmaMqQyiBH8Hl9FTFP97tqSfMcbXMsWX2VGq)(eeBHPqJ9BEYT0VGq)(mpLKKbxgNwOJrgi2njbxUkgd3Vy9dMISFbH(9zEkjjdUmoTqhJmqSBscUCvmgUFx63Pi7xqOFFMNssYGKMtbalz2rXWLRIXW9lw)GPi7xqOFzuAAiP5uaWsMDumevs)x7xqOFzuAAiO8Cyhquj9lT)WRdigGnUAyC)I1VZ(fe6xoX4(L2p9qMGcSCvmgUFx63T4qQdVoPHuRlkJjKkIIawNIFeWJuZwiF4cIiqQdVoPHuhtfxaWesfP2VJY7ei1YO00qjl7hmdGjKkgwssw)cc9FRFzuAAOUOmMqQquj9li0pn65aSSNqSKzaDQ4(DPFY(s)x2VpWkGovC)x7xA)36x0(14WMc9eMQG3aativiBH8Hl9li0F41bedWgxnmUFx63D)x7xqOFzuAAOUJNcaMqQy4YvXy4(fRFMQShvzaDQ4(L2F41bedWgxnmUFX63jsT3H)WaASKzfJawNikcyDkEGaEKA2c5dxqebsTFhL3jqQV1VpZtjjzWLXPf6yKbIDtsWLRIXW9lw)ofz)cc9lA)(eeBHPqko2jS(fe6x0(14WMcljQ8Hb0qcKTq(WL(fe6hNOh5XkqMMgfpGyGWMQai8E(WBO5czlKpCP)R9lTF60JI7)Y(9bwbwMmB97s)0PhfdRcQ2V0(V1VmknnSKOYhgqdjWssY6xA)YO00qoiFynoPHb0fLbOtpkgwssw)cc9RXHnfI1LJQZymKTq(WL(VIuhEDsdPEdjtbGEwgrraRtxbc4rQzlKpCbrei1(DuENaPwgLMgkzz)GzamHuXquj9li0pD6rX9lw)(eR9Fz)HxN0GXuXfamHuH(eRi1HxN0qQ9eMQG3aativefbSUfjc4rQzlKpCbrei1(DuENaPwgLMgkzz)GzamHuXquj9li0pD6rX9lw)(eR9Fz)HxN0GXuXfamHuH(eRi1HxN0qQJ1hgdGjKkIIaw3orapsnBH8HliIaPo86KgsnMxjSPayDmYi1(DuENaPEz6LXec5d3V0(1yjZkuNkgqtGYW9lw)f0n0jnKAVd)Hb0yjZkgbSorueW62nc4rQzlKpCbrei1(DuENaPo86aIbyJRgg3Vy97ePo86KgsTCSBqMrueW6gmrapsnBH8HliIaP2VJY7ei1363N5PKKm4Y40cDmYaXUjj4YvXy4(fRFNISFP9VOgtNlzgIrxYJrgativmKTq(WL(fe6x0(9ji2ctHuCSty9li0VO9RXHnfwsu5ddOHeiBH8Hl9li0porpYJvGmnnkEaXaHnvbq498H3qZfYwiF4s)x7xA)0Phf3)L97dScSmz263L(PtpkgwfuTFP9FRFzuAAyjrLpmGgsGLKK1VGq)ACytHyD5O6mgdzlKpCP)Ri1HxN0qQ3qYuaONLrueW6MkHaEKA2c5dxqebsTFhL3jqQLrPPH6IYycPcljjdPo86KgsTCqgiPb0D8uWikcyDloeWJuZwiF4cIiqQ97O8obsnorpYJvGsqXk6Hb4fvIoPbzlKpCPFP9lJstd1fLXesfwssgsD41jnKA6dJj43GwrueW62vrapsD41jnKASYrXbaMqQi1SfYhUGicefrrQ1DmkSIrapcyDIaEKA2c5dxqebsDkbPgZksD41jnKAqXoH8HrQbfhugPwgLMgUmoTqhJmqSBscIkPFbH(LrPPH6IYycPcrLGudkwalQyKASdZdGkbrraRBeWJuZwiF4cIiqQtji1ywrQdVoPHudk2jKpmsnO4GYi1(eeBHPqko2jS(L2VmknnCzCAHogzGy3Keevs)s7xgLMgQlkJjKkevs)cc9lA)(eeBHPqko2jS(L2VmknnuxugtiviQeKAqXcyrfJuJ1nnYayhMhavcIIawWeb8i1SfYhUGicK6ucsnM1HgPo86KgsnOyNq(Wi1GIfWIkgPgRBAKbWompWYvXyyKA)okVtGulJstd1fLXesfwssw)s73NGylmfsXXoHHudkoOmaFWmsTpZtjjzqDrzmHuHlxfJHrQbfhugP2N5PKKm4Y40cDmYaXUjj4YvXy4(DbmG(9zEkjjdQlkJjKkC5QymmIIawQec4rQzlKpCbrei1PeKAmRdnsD41jnKAqXoH8HrQbflGfvmsnw30idGDyEGLRIXWi1(DuENaPwgLMgQlkJjKkevs)s73NGylmfsXXoHHudkoOmaFWmsTpZtjjzqDrzmHuHlxfJHrQbfhugP2N5PKKm4Y40cDmYaXUjj4YvXyyefbSIdb8i1SfYhUGicK6ucsnM1HgPo86KgsnOyNq(Wi1GIfWIkgPg7W8alxfJHrQ97O8obsTpbXwykKIJDcdPguCqza(GzKAFMNssYG6IYycPcxUkgdJudkoOmsTpZtjjzWLXPf6yKbIDtsWLRIXW9lgya97Z8ussguxugtiv4YvXyyefbSUkc4rQzlKpCbrei1HxN0qQ1DmkS6eP2VJY7ei136x3XOWkuDcjeyaumdiJst3VGq)(eeBHPqko2jS(L2VUJrHvO6esiWa(mpLKK1)1(L2)T(bf7eYhgI1nnYayhMhavs)s7)w)I2VpbXwykKIJDcRFP9lA)6ogfwHQBiHadGIzazuA6(fe63NGylmfsXXoH1V0(fTFDhJcRq1nKqGb8zEkjjRFbH(1DmkScv3qFMNssYGlxfJH7xqOFDhJcRq1jKqGbqXmGmknD)s7)w)I2VUJrHvO6gsiWaOygqgLMUFbH(1DmkScvNqFMNssYGf0n0jT(f7E)6ogfwHQBOpZtjjzWc6g6Kw)x7xqOFDhJcRq1jKqGb8zEkjjRFP9lA)6ogfwHQBiHadGIzazuA6(L2VUJrHvO6e6Z8ussgSGUHoP1Vy37x3XOWkuDd9zEkjjdwq3qN06)A)cc9lA)GIDc5ddX6MgzaSdZdGkPFP9FRFr7x3XOWkuDdjeyaumdiJst3V0(V1VUJrHvO6e6Z8ussgSGUHoP1pv0V463L(bf7eYhgIDyEGLRIXW9li0pOyNq(WqSdZdSCvmgUFX6x3XOWkuDc9zEkjjdwq3qN06Ny97U)R9li0VUJrHvO6gsiWaOygqgLMUFP9FRFDhJcRq1jKqGbqXmGmknD)s7x3XOWkuDc9zEkjjdwq3qN06xS79R7yuyfQUH(mpLKKblOBOtA9lT)B9R7yuyfQoH(mpLKKblOBOtA9tf9lU(DPFqXoH8HHyhMhy5QymC)cc9dk2jKpme7W8alxfJH7xS(1DmkScvNqFMNssYGf0n0jT(jw)U7)A)cc9FRFr7x3XOWkuDcjeyaumdiJst3VGq)6ogfwHQBOpZtjjzWc6g6Kw)IDVFDhJcRq1j0N5PKKmybDdDsR)R9lT)B9R7yuyfQUH(mpLKKbxoko6xA)6ogfwHQBOpZtjjzWc6g6Kw)ur)IRFX6huStiFyi2H5bwUkgd3V0(bf7eYhgIDyEGLRIXW97s)6ogfwHQBOpZtjjzWc6g6Kw)eRF39li0VO9R7yuyfQUH(mpLKKbxoko6xA)36x3XOWkuDd9zEkjjdUCvmgUFQOFX1Vl9dk2jKpmeRBAKbWompWYvXy4(L2pOyNq(WqSUPrga7W8alxfJH7xS(DlY(L2)T(1DmkScvNqFMNssYGf0n0jT(PI(fx)U0pOyNq(WqSdZdSCvmgUFbH(1DmkScv3qFMNssYGlxfJH7Nk6xC97s)GIDc5ddXompWYvXy4(L2VUJrHvO6g6Z8ussgSGUHoP1pv0Vtr2)L9dk2jKpme7W8alxfJH73L(bf7eYhgI1nnYayhMhy5QymC)cc9dk2jKpme7W8alxfJH7xS(1DmkScvNqFMNssYGf0n0jT(jw)U7xqOFqXoH8HHyhMhavs)x7xqOFDhJcRq1n0N5PKKm4YvXy4(PI(fx)I1pOyNq(WqSUPrga7W8alxfJH7xA)36x3XOWkuDc9zEkjjdwq3qN06Nk6xC97s)GIDc5ddX6MgzaSdZdSCvmgUFbH(fTFDhJcRq1jKqGbqXmGmknD)s7)w)GIDc5ddXompWYvXy4(fRFDhJcRq1j0N5PKKmybDdDsRFI1V7(fe6huStiFyi2H5bqL0)1(V2)1(V2)1(V2VGq)Yjg3V0(PhYeuGLRIXW97s)GIDc5ddXompWYvXy4(V2VGq)I2VUJrHvO6esiWaOygqgLMUFP9lA)(eeBHPqko2jS(L2)T(1DmkScv3qcbgafZaYO009lT)B9FRFr7huStiFyi2H5bqL0VGq)6ogfwHQBOpZtjjzWLRIXW9lw)IR)R9lT)B9dk2jKpme7W8alxfJH7xS(DlY(fe6x3XOWkuDd9zEkjjdUCvmgUFQOFX1Vy9dk2jKpme7W8alxfJH7)A)x7xqOFr7x3XOWkuDdjeyaumdiJst3V0(V1VO9R7yuyfQUHecmGpZtjjz9li0VUJrHvO6g6Z8ussgC5QymC)cc9R7yuyfQUH(mpLKKblOBOtA9l29(1DmkScvNqFMNssYGf0n0jT(V2)vKA8jvmsTUJrHvNikcyf)iGhPMTq(WferGuhEDsdPw3XOWQBKA)okVtGuFRFDhJcRq1nKqGbqXmGmknD)cc97tqSfMcP4yNW6xA)6ogfwHQBiHad4Z8ussw)x7xA)36huStiFyiw30idGDyEauj9lT)B9lA)(eeBHPqko2jS(L2VO9R7yuyfQoHecmakMbKrPP7xqOFFcITWuifh7ew)s7x0(1DmkScvNqcbgWN5PKKS(fe6x3XOWkuDc9zEkjjdUCvmgUFbH(1DmkScv3qcbgafZaYO009lT)B9lA)6ogfwHQtiHadGIzazuA6(fe6x3XOWkuDd9zEkjjdwq3qN06xS79R7yuyfQoH(mpLKKblOBOtA9FTFbH(1DmkScv3qcbgWN5PKKS(L2VO9R7yuyfQoHecmakMbKrPP7xA)6ogfwHQBOpZtjjzWc6g6Kw)IDVFDhJcRq1j0N5PKKmybDdDsR)R9li0VO9dk2jKpmeRBAKbWompaQK(L2)T(fTFDhJcRq1jKqGbqXmGmknD)s7)w)6ogfwHQBOpZtjjzWc6g6Kw)ur)IRFx6huStiFyi2H5bwUkgd3VGq)GIDc5ddXompWYvXy4(fRFDhJcRq1n0N5PKKmybDdDsRFI1V7(V2VGq)6ogfwHQtiHadGIzazuA6(L2)T(1DmkScv3qcbgafZaYO009lTFDhJcRq1n0N5PKKmybDdDsRFXU3VUJrHvO6e6Z8ussgSGUHoP1V0(V1VUJrHvO6g6Z8ussgSGUHoP1pv0V463L(bf7eYhgIDyEGLRIXW9li0pOyNq(WqSdZdSCvmgUFX6x3XOWkuDd9zEkjjdwq3qN06Ny97U)R9li0)T(fTFDhJcRq1nKqGbqXmGmknD)cc9R7yuyfQoH(mpLKKblOBOtA9l29(1DmkScv3qFMNssYGf0n0jT(V2V0(V1VUJrHvO6e6Z8ussgC5O4OFP9R7yuyfQoH(mpLKKblOBOtA9tf9lU(fRFqXoH8HHyhMhy5QymC)s7huStiFyi2H5bwUkgd3Vl9R7yuyfQoH(mpLKKblOBOtA9tS(D3VGq)I2VUJrHvO6e6Z8ussgC5O4OFP9FRFDhJcRq1j0N5PKKm4YvXy4(PI(fx)U0pOyNq(WqSUPrga7W8alxfJH7xA)GIDc5ddX6MgzaSdZdSCvmgUFX63Ti7xA)36x3XOWkuDd9zEkjjdwq3qN06Nk6xC97s)GIDc5ddXompWYvXy4(fe6x3XOWkuDc9zEkjjdUCvmgUFQOFX1Vl9dk2jKpme7W8alxfJH7xA)6ogfwHQtOpZtjjzWc6g6Kw)ur)ofz)x2pOyNq(WqSdZdSCvmgUFx6huStiFyiw30idGDyEGLRIXW9li0pOyNq(WqSdZdSCvmgUFX6x3XOWkuDd9zEkjjdwq3qN06Ny97UFbH(bf7eYhgIDyEauj9FTFbH(1DmkScvNqFMNssYGlxfJH7Nk6xC9lw)GIDc5ddX6MgzaSdZdSCvmgUFP9FRFDhJcRq1n0N5PKKmybDdDsRFQOFX1Vl9dk2jKpmeRBAKbWompWYvXy4(fe6x0(1DmkScv3qcbgafZaYO009lT)B9dk2jKpme7W8alxfJH7xS(1DmkScv3qFMNssYGf0n0jT(jw)U7xqOFqXoH8HHyhMhavs)x7)A)x7)A)x7)A)cc9lNyC)s7NEitqbwUkgd3Vl9dk2jKpme7W8alxfJH7)A)cc9lA)6ogfwHQBiHadGIzazuA6(L2VO97tqSfMcP4yNW6xA)36x3XOWkuDcjeyaumdiJst3V0(V1)T(fTFqXoH8HHyhMhavs)cc9R7yuyfQoH(mpLKKbxUkgd3Vy9lU(V2V0(V1pOyNq(WqSdZdSCvmgUFX63Ti7xqOFDhJcRq1j0N5PKKm4YvXy4(PI(fx)I1pOyNq(WqSdZdSCvmgU)R9FTFbH(fTFDhJcRq1jKqGbqXmGmknD)s7)w)I2VUJrHvO6esiWa(mpLKK1VGq)6ogfwHQtOpZtjjzWLRIXW9li0VUJrHvO6e6Z8ussgSGUHoP1Vy37x3XOWkuDd9zEkjjdwq3qN06)A)xrQXNuXi16ogfwDJOikIIudIx8KgcyDls3UfPB3orQjfRngzmsT4zxzXlW6kbwWGxS)(bpbU)PssUA)052pr6oEkycPIjQ)LPYrNLl9JZkU)avZQq5s)EcHrMXWMAxpg3VZl2)fsdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9FZjvVcBQD9yC)UVy)xinq8QCPFIwuJPZLmdjor9Rz)eTOgtNlzgsCiBH8Hle1)nNu9kSP21JX9dMxS)lKgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKTq(WfI6p0(bddgY19FZjvVcBQD9yC)I7I9FH0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHSfYhUqu)3Cs1RWMAxpg3VREX(VqAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQ)q7hmmyix3)nNu9kSP21JX97kUy)xinq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1)nNu9kSP21JX97uKxS)lKgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6)MtQEf2u76X4(DsLUy)xinq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1)nNu9kSP21JX97KkDX(VqAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQ)BoP6vytTRhJ73P4)I9FH0aXRYL(jsJdBkK4e1VM9tKgh2uiXHSfYhUqu)3Cs1RWMAxpg3VtX)f7)cPbIxLl9t0IAmDUKziXjQFn7NOf1y6CjZqIdzlKpCHO(V5MQxHn1UEmUFNIhxS)lKgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6)MtQEf2u76X4(DlUl2)fsdeVkx6NOf1y6CjZqItu)A2prlQX05sMHehYwiF4cr9hA)GHbd56(V5KQxHn1UEmUF3U6f7)cPbIxLl9t0IAmDUKziXjQFn7NOf1y6CjZqIdzlKpCHO(dTFWWGHCD)3Cs1RWMAxpg3VBXJl2)fsdeVkx6NiCIEKhRajor9Rz)eHt0J8yfiXHSfYhUqu)3Cs1RWM6MAXZUYIxG1vcSGbVy)9dEcC)tLKC1(PZTFIkmDGEuI6FzQC0z5s)4SI7pq1SkuU0VNqyKzmSP21JX97(I9FH0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHSfYhUqu)3Cs1RWMAxpg3V7l2)fsdeVkx6NOf1y6CjZqItu)A2prlQX05sMHehYwiF4cr9FZjvVcBQD9yC)UVy)xinq8QCPFI8PvqhfsCI6xZ(jYNwbDuiXHSfYhUqu)3Cs1RWMAxpg3V7l2)fsdeVkx6NiCIEKhRajor9Rz)eHt0J8yfiXHSfYhUqu)3Cs1RWM6MAXZUYIxG1vcSGbVy)9dEcC)tLKC1(PZTFIKSSpRKdLO(xMkhDwU0poR4(dunRcLl97jegzgdBQD9yC)G5f7)cPbIxLl9t0IAmDUKziXjQFn7NOf1y6CjZqIdzlKpCHO(dTFWWGHCD)3Cs1RWMAxpg3pv6I9FH0aXRYL(jsJdBkK4e1VM9tKgh2uiXHSfYhUqu)H2pyyWqUU)BoP6vytTRhJ7xCxS)lKgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6)MtQEf2u76X4(D1l2)fsdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9FZjvVcBQBQfp7klEbwxjWcg8I93p4jW9pvsYv7No3(jcRe1)Yu5OZYL(Xzf3FGQzvOCPFpHWiZyytTRhJ735f7)cPbIxLl9tKgh2uiXjQFn7NinoSPqIdzlKpCHO(V5KQxHn1UEmUFQ0f7)cPbIxLl9t0IAmDUKziXjQFn7NOf1y6CjZqIdzlKpCHO(dTFWWGHCD)3Cs1RWMAxpg3V4Uy)xinq8QCPFIwuJPZLmdjor9Rz)eTOgtNlzgsCiBH8Hle1)nNu9kSP21JX9705f7)cPbIxLl9tKgh2uiXjQFn7NinoSPqIdzlKpCHO(V5KQxHn1UEmUFNUVy)xinq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1)nNu9kSP21JX97emVy)xinq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1)nNu9kSP21JX97KkDX(VqAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQ)BUP6vytTRhJ73jv6I9FH0aXRYL(jcNOh5XkqItu)A2pr4e9ipwbsCiBH8Hle1)nNu9kSP21JX97uCxS)lKgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6)MBQEf2u76X4(DkUl2)fsdeVkx6NOf1y6CjZqItu)A2prlQX05sMHehYwiF4cr9FZjvVcBQD9yC)of3f7)cPbIxLl9teorpYJvGeNO(1SFIWj6rEScK4q2c5dxiQ)BoP6vytTRhJ73PREX(VqAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQ)BoP6vytTRhJ73P4)I9FH0aXRYL(jsJdBkK4e1VM9tKgh2uiXHSfYhUqu)3Cs1RWMAxpg3VtXJl2)fsdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9FZnvVcBQD9yC)ofpUy)xinq8QCPFIWj6rEScK4e1VM9teorpYJvGehYwiF4cr9FZjvVcBQD9yC)UbZl2)fsdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9FZnvVcBQD9yC)UbZl2)fsdeVkx6NOf1y6CjZqItu)A2prlQX05sMHehYwiF4cr9FZjvVcBQD9yC)UbZl2)fsdeVkx6NiCIEKhRajor9Rz)eHt0J8yfiXHSfYhUqu)3Cs1RWMAxpg3VBXDX(VqAG4v5s)eHt0J8yfiXjQFn7NiCIEKhRajoKTq(WfI6)MtQEf2u3ulE2vw8cSUsGfm4f7VFWtG7FQKKR2pDU9tKUJrHvmr9Vmvo6SCPFCwX9hOAwfkx63timYmg2u76X4(D1l2)fsdeVkx6VEQUq)yhMguTFW4(1SFxJg9xgqdEsR)ucVHMB)3i21(VjoQEf2u76X4(D1l2)fsdeVkx6NiDhJcRqNqItu)A2pr6ogfwHQtiXjQ)BUDs1RWMAxpg3VREX(VqAG4v5s)eP7yuyf6gsCI6xZ(js3XOWkuDdjor9FZTRs1RWMAxpg3V4)I9FH0aXRYL(RNQl0p2HPbv7hmUFn731Or)Lb0GN06pLWBO52)nIDT)BIJQxHn1UEmUFX)f7)cPbIxLl9tKUJrHvOtiXjQFn7NiDhJcRq1jK4e1)n3UkvVcBQD9yC)I)l2)fsdeVkx6NiDhJcRq3qItu)A2pr6ogfwHQBiXjQ)BUDs1RWM6MAxPkj5QCPFxT)WRtA9FgSIHn1i1yjShbSUfhvcPwYM0ZHrQfFIV(PYkwk4QWWegj9lEdQP82ul(eF9lEllVOX6OF3obx)UfPB3n1n1IpXx)xGqyKz8fBQfFIV(PI(bltIorTs)IxmopG4(hC)wQ9h9xXEcHn((vcC)rPKw)(WigP5C6VkSGmdBQfFIV(PI(fVySdZZL(JsjT(LStUJ6OFsJsO)6P6c97klE31WMAXN4RFQOFxZA)uz7yNWW9xySdZ3VsGNT)liEc3poRyDQymSPUPo86KggkzzFwjh6L3jMCQ6Hla0NWbxingzanP6yn1HxN0Wqjl7Zk5qV8oXOpmMGFdATPo86KggkzzFwjh6L3jMglGUHeWn03xuJPZLmdXj6HoxYmaxjZlUPo86KggkzzFwjh6L3jwjrLpmGgsaNKL9bwb0PIV7uKGBOVhEDaXaSXvdJfZPGGO(eeBHPqko2jmPIQXHnfckph2rtD41jnmuYY(Sso0lVtSyQ4caMqQGBOVhEDaXaSXvdJDbmLEtuFcITWuifh7eMur14WMcbLNd7qqi86aIbyJRgg7I7Rn1HxN0Wqjl7Zk5qV8oXWkhfhaycPcUH(E41bedWgxnmwm3cc38ji2ctHuCStyccACytHGYZHDCvA41bedWgxnm(U7M6M6WRtA4lVtmFIAkVaycP2uhEDsdF5DI5tut5fativWDgJb8L7GPib3qFFrnMoxYmeZsiGcgHbKSP)evHoPjiGt0J8yfOnocmGM5bdijhCAcc38PvqhfUmiEXXbiPbOZvrnwQOlQX05sMHywcbuWimGKn9NOk0jTRn1IV(bdM9he4O0FyL(b)ggvo6CgWiUFWkE)c9ZgxnmgmW9tI7VKgrA)LSFLWG7No3(LCch8I7xM9bkM7FuIk9lZ9Rz2pwsuv5O)Wk9tI73hgrA)lhL54OFWVHrL3pwc7h6X3Vmknng2uhEDsdF5DIPByu5OZzaJgJmaMqQGBOVlQglzwHdgqYjCWBtD41jn8L3jMpohGWRtAaNbRGZIk(UUJrHvm4g67(eeBHPqko2jmP(mpLKKb1fLXesfUCvmgwQpZtjjzWLXPf6yKbIDtsWLRIXWccI6tqSfMcP4yNWK6Z8ussguxugtiv4YvXy4MAXN4RFXt8jC0pD4hJC)os0T)sIkR9JA6C63rI2pHae3VeuTFXlgNwOJrUFx5Dts9xssg46p3(h6(vcC)(mpLKK1)G7xZS)tAK7xZ(l8jC0pD4hJC)os0TFXtjQSc73vIUFlnU)KUFLaJ5(9PvgDsd3FSC)H8H7xZ(RyTFsJsyS(vcC)ofz)y2Nwb3)HzsHdW1VsG7hpv9thEg3VJeD7x8uIkR9hOAwf64JZXbSPw8j(6p86Kg(Y7eZys0jQvawgNhqm4g674e9ipwbAmj6e1kalJZdiw6nzuAA4Y40cDmYaXUjjiQebbFMNssYGlJtl0Xide7MKGlxfJHfZPifeOhYeuGLRIXWU40vV2uhEDsdF5DI5JZbi86KgWzWk4SOIV7l4M6WRtA4lVtmFCoaHxN0aodwbNfv8DScoSUJxV7eCd99WRdigGnUAySlGztD41jn8L3jMpohGWRtAaNbRGZIk(UUJNcMqQyWH1D86DNGBOVhEDaXaSXvdJfZDtDtD41jnm0xW3L5fZlLXidUH((nzuAAOUOmMqQqujsLrPPHlJtl0Xide7MKGOsK6tqSfMcP4yNWUkiCtgLMgQlkJjKkevIuzuAAiP5uaWsMDumevIuFcITWuOnKjOa0bFvq4MpbXwykeeBkbhRGGpbXwyk0y)MNClxLkJstd1fLXesfIkrqqoXyP0dzckWYvXyyxCcMcc38ji2ctHuCStysLrPPHlJtl0Xide7MKGOsKspKjOalxfJHDr8dMxBQdVoPHH(c(Y7et(KzbGgDDaUH(UmknnuxugtiviQebbFMNssYG6IYycPcxUkgdlgyksbb5eJLspKjOalxfJHDXPR2uhEDsdd9f8L3jwyEgRBCa8X5aUH(UmknnuxugtiviQebbFMNssYG6IYycPcxUkgdlgyksbb5eJLspKjOalxfJHDXPR2uhEDsdd9f8L3jg9SS8jZc4g67YO00qDrzmHuHOsee8zEkjjdQlkJjKkC5QymSyGPifeKtmwk9qMGcSCvmg2fxrtD41jnm0xWxENyNHmbfdagi0c5k2uWn03LrPPH6IYycPcljjRPo86Kgg6l4lVtmjPoPbUH(UmknnuxugtiviQeP3KrPPHYNmlhuScrLiiOXsMvibookbOeV6IBrEvqqoXyP0dzckWYvXyyxC7Qcc38ji2ctHuCStysLrPPHlJtl0Xide7MKGOsKspKjOalxfJHDr87(AtDtD41jnmeR3XkhfhaycPcUH(Ugh2uiw5O4aGo9OyP3KSmiaY(c0jeRCuCaGjKQuzuAAiw5O4aGo9Oy4YvXyyxeNGGmknneRCuCaqNEumSKKSRsVjJstdxgNwOJrgi2njbljjtqquFcITWuifh7e21M6WRtAyiwV8oXOmNdaMqQn1HxN0WqSE5DIvsu5ddOHeWn03V5tqSfMcP4yNWKEZN5PKKm4Y40cDmYaXUjj4YvXyyxi7lxfee1NGylmfsXXoHjvuFcITWuOnKjOa0bli4tqSfMcTHmbfGoyP38zEkjjdsAofaSKzhfdxUkgd7czFrqWN5PKKmiP5uaWsMDumC5QymSyGPiVkiqpKjOalxfJHDXP4Uk9MOBmfageBkmkfmKP6GvSGWgtbGbXMcJsbdrLi92gtbGbXMcJsbdhZfNIu6gtbGbXMcJsbdxUkgd7cykiSXuayqSPWOuWWXeZN5PKKmbHWRdigGnUAySyoVkii6gtbGbXMcJsbdrLi92gtbGbXMcJsbd9jQP3DkiSXuayqSPWOuWWXeZN5PKKSRxBQdVoPHHy9Y7eJ(eldUH(UglGUHeiQePlQX05sMH4e9qNlzgGRK5f3uhEDsddX6L3jMglGUHeWn03xuJPZLmdXj6HoxYmaxjZlwQglGUHe4YvXyyxi7ls9zEkjjdsFILHlxfJHDHSV0uhEDsddX6L3jgtvjNepGyamHuBQdVoPHHy9Y7eJ0CkayjZokgCd99B(mpLKKb1fLXesfUCvmg2fY(IGGmknnuxugtiviQKRsVj6gtbGbXMcJsbdzQoyflii6gtbGbXMcJsbdrLiDJPaWGytHrPGHf0n0jTl3ykami2uyuky4yU4wKccBmfageBkmkfmevI0nMcadInfgLcgUCvmgwmNUcbHWRdigGnUAySyoVkiqpKjOalxfJHDr8qKn1HxN0WqSE5DIrFchCbati1M6WRtAyiwV8oXkCOea8eckBubUH(oD6rXx6dScSmz2CHo9Oyyvq1M6WRtAyiwV8oXcGk0TWlqsd43KeUPo86KggI1lVtmsXCgJmqSBscCd9DFMNssYGlJtl0Xide7MKGlxfJHDHSVi9MOACytHmvLCs8aIbWesvqqgLMgkFYSCqXkevYvbbr9ji2ctHuCStycc(mpLKKbxgNwOJrgi2njbxUkgdliiNySu6Hmbfy5QymSlIRPo86KggI1lVtSLXPf6yKbIDtsGBOVFtgLMgwsu5ddOHeiQebbr14WMcljQ8Hb0qIGa9qMGcSCvmg2fNUVk9MOBmfageBkmkfmKP6GvSGGOBmfageBkmkfmevI0BBmfageBkmkfmSGUHoPD5gtbGbXMcJsbdhZfNIuqyJPaWGytHrPGH(e107oVkiSXuayqSPWOuWqujs3ykami2uyuky4YvXyyXCfccHxhqmaBC1WyXCETPo86KggI1lVtmq55Woa3qFxgLMgUmoTqhJmqSBscIkrqquFcITWuifh7eM0BYO00qjl7hmdGjKkgwssMGGOACytHEctvWBaGjKQGq41bedWgxnm2f3xBQdVoPHHy9Y7edRCuCaGjKk4g67(eeBHPqko2jmP0PhfFPpWkWYKzZf60JIHvbvLE7MpZtjjzWLXPf6yKbIDtsWLRIXWUq2xOYaMsVjkorpYJvGmnnkEaXaHnvbq498H3qZvqqunoSPWsIkFyanKC9QGGgh2uyjrLpmGgsK6Z8ussgSKOYhgqdjWLRIXWUaMxBQdVoPHHy9Y7eBdjtbGEwgCd99f1y6CjZqm6sEmYaycPILQXHnfI1LJQZyS0B(mpLKKbxgNwOJrgi2njbxUkgdlMtrkiiQpbXwykKIJDctqqunoSPWsIkFyanKiiGt0J8yfittJIhqmqytvaeEpF4n0CV2uhEDsddX6L3jMUOmMqQGBOVF7MmknnuYY(bZaycPIHLKKjiOXHnf6JZzmYakbgativ8vP(eeBHPqqSPeCScc(eeBHPqJ9BEYTii4Z8ussgCzCAHogzGy3KeC5QymSyGPife8zEkjjdUmoTqhJmqSBscUCvmg2fNIuqWN5PKKmiP5uaWsMDumC5QymSyGPifeKrPPHKMtbalz2rXqujxfeKrPPHGYZHDarLin86aIbyJRgglMtbb5eJLspKjOalxfJHDXT4AQdVoPHHy9Y7elMkUaGjKk48o8hgqJLmR47ob3qFxgLMgkzz)GzamHuXWssYeeUjJstd1fLXesfIkrqGg9Caw2tiwYmGovSlK9Ll9bwb0PIVk9MOACytHEctvWBaGjKQGq41bedWgxnm2f3xfeKrPPH6oEkaycPIHlxfJHfJPk7rvgqNkwA41bedWgxnmwmNn1HxN0WqSE5DITHKPaqpldUH((nFMNssYGlJtl0Xide7MKGlxfJHfZPifee1NGylmfsXXoHjiiQgh2uyjrLpmGgseeWj6rEScKPPrXdigiSPkacVNp8gAUxLsNEu8L(aRaltMnxOtpkgwfuv6nzuAAyjrLpmGgsGLKKjvgLMgYb5dRXjnmGUOmaD6rXWssYee04WMcX6Yr1zm(AtD41jnmeRxENyEctvWBaGjKk4g67YO00qjl7hmdGjKkgIkrqGo9OyX8jwVm86KgmMkUaGjKk0NyTPo86KggI1lVtSy9HXaycPcUH(UmknnuYY(bZaycPIHOseeOtpkwmFI1ldVoPbJPIlaycPc9jwBQdVoPHHy9Y7edZRe2uaSogzW5D4pmGglzwX3DcUH((Y0lJjeYhwQglzwH6uXaAcugwSc6g6KwtD41jnmeRxENyYXUbzgCd99WRdigGnUAySyoBQdVoPHHy9Y7eBdjtbGEwgCd99B(mpLKKbxgNwOJrgi2njbxUkgdlMtrkDrnMoxYmeJUKhJmaMqQybbr9ji2ctHuCStyccIQXHnfwsu5ddOHebbCIEKhRazAAu8aIbcBQcGW75dVHM7vP0PhfFPpWkWYKzZf60JIHvbvLEtgLMgwsu5ddOHeyjjzccACytHyD5O6mgFTPo86KggI1lVtm5GmqsdO74PGb3qFxgLMgQlkJjKkSKKSM6WRtAyiwV8oXOpmMGFdAfCd9DCIEKhRaLGIv0ddWlQeDstQmknnuxugtivyjjzn1HxN0WqSE5DIHvokoaWesTPUPo86KggQ74PGjKk(ow5O4aativWn0314WMcXkhfha0PhflDma6ZqMGkvgLMgIvokoaOtpkgUCvmg2fX1uhEDsdd1D8uWesfF5DIrzohamHub3qFFrnMoxYmusI6jaK0aBagLla9gKRytXsLrPPH0NWbVyGQyParL0uhEDsdd1D8uWesfF5DIrFchCbativWn03xuJPZLmdLKOEcajnWgGr5cqVb5k2uCtD41jnmu3Xtbtiv8L3jwjrLpmGgsa3qF)MpbXwykKIJDctQpZtjjzWLXPf6yKbIDtsWLRIXWUq2xeee1NGylmfsXXoHjvuFcITWuOnKjOa0bli4tqSfMcTHmbfGoyP38zEkjjdsAofaSKzhfdxUkgd7czFrqWN5PKKmiP5uaWsMDumC5QymSyGPiVkiOXsMvOovmGMaLHDXPife8zEkjjdUmoTqhJmqSBscUCvmgwmNIuA41bedWgxnmwmW8Q0BIUXuayqSPWOuWqMQdwXccBmfageBkmkfmC5QymSyUcbbr9ji2ctHuCStyxBQdVoPHH6oEkycPIV8oX0yb0nKaUH((IAmDUKziorp05sMb4kzEXs1yb0nKaxUkgd7czFrQpZtjjzq6tSmC5QymSlK9LM6WRtAyOUJNcMqQ4lVtm6tSm4oJXa(YD3IdCd9DnwaDdjqujsxuJPZLmdXj6HoxYmaxjZlUPo86KggQ74PGjKk(Y7eJPQKtIhqmaMqQn1HxN0WqDhpfmHuXxENyKMtbalz2rXGBOVl6gtbGbXMcJsbdzQoyfliSXuayqSPWOuWWLRIXWI5uKccHxhqmaBC1WyXUVXuayqSPWOuWqFIAkvg3n1HxN0WqDhpfmHuXxENyKI5mgzGy3Ke4g67(mpLKKbxgNwOJrgi2njbxUkgd7czFr6nr14WMczQk5K4bedGjKQGGmknnu(Kz5GIviQKRccI6tqSfMcP4yNWee8zEkjjdUmoTqhJmqSBscUCvmgwmNIuqqoXyP0dzckWYvXyyxextD41jnmu3Xtbtiv8L3j2Y40cDmYaXUjjWn03V5Z8ussgeuEoSd4YvXyyxi7lccIQXHnfckph2HGGglzwH6uXaAcug2fNUVk9MOBmfageBkmkfmKP6GvSGWgtbGbXMcJsbdxUkgdlMRqqi86aIbyJRggl29nMcadInfgLcg6tutPY4(AtD41jnmu3Xtbtiv8L3jgO8CyhGBOVlJstdxgNwOJrgi2njbrLiiiQpbXwykKIJDcRPo86KggQ74PGjKk(Y7eto2niZn1HxN0WqDhpfmHuXxENy6IYycPcUH(UmknnCzCAHogzGy3KeevIGGpZtjjzWLXPf6yKbIDtsWLRIXWI5uKccI6tqSfMcP4yNWeeKtmwk9qMGcSCvmg2f3ISPo86KggQ74PGjKk(Y7eBdjtbGEwgCd99f1y6CjZqm6sEmYaycPILEZN5PKKm4Y40cDmYaXUjj4YvXyyXCksbbr9ji2ctHuCStyccIQXHnfwsu5ddOHKRsLrPPH6oEkaycPIHlxfJHf7otv2JQmGovCtD41jnmu3Xtbtiv8L3jwmvCbativW5D4pmGglzwX3DcUH(Umknnu3XtbativmC5QymSy3zQYEuLb0PILEtgLMgkzz)GzamHuXWssYeeOrphGL9eILmdOtf7IpWkGov8LK9fbbzuAAOUOmMqQqujxBQdVoPHH6oEkycPIV8oXkCOea8eckBubUH(oD6rXx6dScSmz2CHo9Oyyvq1M6WRtAyOUJNcMqQ4lVtSnKmfa6zzWn03V5Z8ussgCzCAHogzGy3KeC5QymSyofP0f1y6CjZqm6sEmYaycPIfee1NGylmfsXXoHjii6IAmDUKzigDjpgzamHuXccIQXHnfwsu5ddOHKRsLrPPH6oEkaycPIHlxfJHf7otv2JQmGovCtD41jnmu3Xtbtiv8L3jwf6rhmHub3qFxgLMgQ74PaGjKkgwssMGGmknnuYY(bZaycPIHOsKsNEuSy(eRxgEDsdgtfxaWesf6tSk9MOACytHEctvWBaGjKQGq41bedWgxnmwmW8AtD41jnmu3Xtbtiv8L3jMNWuf8gaycPcUH(UmknnuYY(bZaycPIHOsKsNEuSy(eRxgEDsdgtfxaWesf6tSkn86aIbyJRgg7cvQPo86KggQ74PGjKk(Y7eJYCoaycPcUH(UmknnSWrbGDWWssYAQdVoPHH6oEkycPIV8oXcGk0TWlqsd43KeUPo86KggQ74PGjKk(Y7eJ(eo4caMqQn1HxN0WqDhpfmHuXxENyyELWMcG1XidoVd)Hb0yjZk(UtWn03xMEzmHq(Wn1HxN0WqDhpfmHuXxENyvOhDWesfCd9D60JIfZNy9YWRtAWyQ4caMqQqFIvP38zEkjjdUmoTqhJmqSBscUCvmgwmXjiiQpbXwykKIJDc7AtD41jnmu3Xtbtiv8L3jMglGUHeWn03xuJPZLmdngJhJmPyDGb0nKizmYaHejXgkkUPo86KggQ74PGjKk(Y7eJEzgmAmYa6gsa3qFFrnMoxYm0ymEmYKI1bgq3qIKXidesKeBOO4M6WRtAyOUJNcMqQ4lVtm5GmqsdO74PGb3qFxgLMgQlkJjKkSKKSM6WRtAyOUJNcMqQ4lVtm6dJj43Gwb3qFhNOh5XkqjOyf9Wa8IkrN0KkJstd1fLXesfwsswtD41jnmu3Xtbtiv8L3jgw5O4aati1M6M6WRtAyOUJrHv8DqXoH8HbNfv8DSdZdGkbCGIdkFxgLMgUmoTqhJmqSBscIkrqqgLMgQlkJjKkevstD41jnmu3XOWk(Y7eduStiFyWzrfFhRBAKbWompaQeWbkoO8DFcITWuifh7eMuzuAA4Y40cDmYaXUjjiQePYO00qDrzmHuHOseee1NGylmfsXXoHjvgLMgQlkJjKkevstD41jnmu3XOWk(Y7eduStiFyWzrfFhRBAKbWompWYvXyyWLsUJzDObhO4GY39zEkjjdUmoTqhJmqSBscUCvmg2fWa8zEkjjdQlkJjKkC5Qymm4afhugGpy(UpZtjjzqDrzmHuHlxfJHb3qFxgLMgQlkJjKkSKKmP(eeBHPqko2jSM6WRtAyOUJrHv8L3jgOyNq(WGZIk(ow30idGDyEGLRIXWGlLChZ6qdoqXbLV7Z8ussgCzCAHogzGy3KeC5Qymm4afhugGpy(UpZtjjzqDrzmHuHlxfJHb3qFxgLMgQlkJjKkevIuFcITWuifh7ewtD41jnmu3XOWk(Y7eduStiFyWzrfFh7W8alxfJHbxk5oM1HgCd9DFcITWuifh7eg4afhu(UpZtjjzWLXPf6yKbIDtsWLRIXWIbgGpZtjjzqDrzmHuHlxfJHbhO4GYa8bZ39zEkjjdQlkJjKkC5QymCtD41jnmu3XOWk(Y7edfZaJYvyWHpPIVR7yuy1j4g6730DmkScDcjeyaumdiJstli4tqSfMcP4yNWKQ7yuyf6esiWa(mpLKKDv6nqXoH8HHyDtJma2H5bqLi9MO(eeBHPqko2jmPIQ7yuyf6gsiWaOygqgLMwqWNGylmfsXXoHjvuDhJcRq3qcbgWN5PKKmbbDhJcRq3qFMNssYGlxfJHfe0DmkScDcjeyaumdiJstl9MO6ogfwHUHecmakMbKrPPfe0DmkScDc9zEkjjdwq3qN0e7UUJrHvOBOpZtjjzWc6g6K2vbbDhJcRqNqcbgWN5PKKmPIQ7yuyf6gsiWaOygqgLMwQUJrHvOtOpZtjjzWc6g6KMy31DmkScDd9zEkjjdwq3qN0UkiikOyNq(WqSUPrga7W8aOsKEtuDhJcRq3qcbgafZaYO00sVP7yuyf6e6Z8ussgSGUHoPrfIZfqXoH8HHyhMhy5QymSGaOyNq(WqSdZdSCvmgwmDhJcRqNqFMNssYGf0n0jnWy3xfe0DmkScDdjeyaumdiJstl9MUJrHvOtiHadGIzazuAAP6ogfwHoH(mpLKKblOBOtAIDx3XOWk0n0N5PKKmybDdDst6nDhJcRqNqFMNssYGf0n0jnQqCUak2jKpme7W8alxfJHfeaf7eYhgIDyEGLRIXWIP7yuyf6e6Z8ussgSGUHoPbg7(QGWnr1DmkScDcjeyaumdiJstliO7yuyf6g6Z8ussgSGUHoPj2DDhJcRqNqFMNssYGf0n0jTRsVP7yuyf6g6Z8ussgC5O4qQUJrHvOBOpZtjjzWc6g6KgvioXaf7eYhgIDyEGLRIXWsbf7eYhgIDyEGLRIXWUO7yuyf6g6Z8ussgSGUHoPbg7wqquDhJcRq3qFMNssYGlhfhsVP7yuyf6g6Z8ussgC5Qymmvioxaf7eYhgI1nnYayhMhy5QymSuqXoH8HHyDtJma2H5bwUkgdlMBrk9MUJrHvOtOpZtjjzWc6g6Kgvioxaf7eYhgIDyEGLRIXWcc6ogfwHUH(mpLKKbxUkgdtfIZfqXoH8HHyhMhy5QymSuDhJcRq3qFMNssYGf0n0jnQWPiVeuStiFyi2H5bwUkgd7cOyNq(WqSUPrga7W8alxfJHfeaf7eYhgIDyEGLRIXWIP7yuyf6e6Z8ussgSGUHoPbg7wqauStiFyi2H5bqLCvqq3XOWk0n0N5PKKm4YvXyyQqCIbk2jKpmeRBAKbWompWYvXyyP30DmkScDc9zEkjjdwq3qN0OcX5cOyNq(WqSUPrga7W8alxfJHfeev3XOWk0jKqGbqXmGmknT0BGIDc5ddXompWYvXyyX0DmkScDc9zEkjjdwq3qN0aJDliak2jKpme7W8aOsUE961RxfeKtmwk9qMGcSCvmg2fqXoH8HHyhMhy5Qym8vbbr1DmkScDcjeyaumdiJstlvuFcITWuifh7eM0B6ogfwHUHecmakMbKrPPLE7MOGIDc5ddXompaQebbDhJcRq3qFMNssYGlxfJHftCxLEduStiFyi2H5bwUkgdlMBrkiO7yuyf6g6Z8ussgC5QymmvioXaf7eYhgIDyEGLRIXWxVkiiQUJrHvOBiHadGIzazuAAP3ev3XOWk0nKqGb8zEkjjtqq3XOWk0n0N5PKKm4YvXyybbDhJcRq3qFMNssYGf0n0jnXUR7yuyf6e6Z8ussgSGUHoPD9AtD41jnmu3XOWk(Y7edfZaJYvyWHpPIVR7yuy1n4g6730DmkScDdjeyaumdiJstli4tqSfMcP4yNWKQ7yuyf6gsiWa(mpLKKDv6nqXoH8HHyDtJma2H5bqLi9MO(eeBHPqko2jmPIQ7yuyf6esiWaOygqgLMwqWNGylmfsXXoHjvuDhJcRqNqcbgWN5PKKmbbDhJcRqNqFMNssYGlxfJHfe0DmkScDdjeyaumdiJstl9MO6ogfwHoHecmakMbKrPPfe0DmkScDd9zEkjjdwq3qN0e7UUJrHvOtOpZtjjzWc6g6K2vbbDhJcRq3qcbgWN5PKKmPIQ7yuyf6esiWaOygqgLMwQUJrHvOBOpZtjjzWc6g6KMy31DmkScDc9zEkjjdwq3qN0UkiikOyNq(WqSUPrga7W8aOsKEtuDhJcRqNqcbgafZaYO00sVP7yuyf6g6Z8ussgSGUHoPrfIZfqXoH8HHyhMhy5QymSGaOyNq(WqSdZdSCvmgwmDhJcRq3qFMNssYGf0n0jnWy3xfe0DmkScDcjeyaumdiJstl9MUJrHvOBiHadGIzazuAAP6ogfwHUH(mpLKKblOBOtAIDx3XOWk0j0N5PKKmybDdDst6nDhJcRq3qFMNssYGf0n0jnQqCUak2jKpme7W8alxfJHfeaf7eYhgIDyEGLRIXWIP7yuyf6g6Z8ussgSGUHoPbg7(QGWnr1DmkScDdjeyaumdiJstliO7yuyf6e6Z8ussgSGUHoPj2DDhJcRq3qFMNssYGf0n0jTRsVP7yuyf6e6Z8ussgC5O4qQUJrHvOtOpZtjjzWc6g6KgvioXaf7eYhgIDyEGLRIXWsbf7eYhgIDyEGLRIXWUO7yuyf6e6Z8ussgSGUHoPbg7wqquDhJcRqNqFMNssYGlhfhsVP7yuyf6e6Z8ussgC5Qymmvioxaf7eYhgI1nnYayhMhy5QymSuqXoH8HHyDtJma2H5bwUkgdlMBrk9MUJrHvOBOpZtjjzWc6g6Kgvioxaf7eYhgIDyEGLRIXWcc6ogfwHoH(mpLKKbxUkgdtfIZfqXoH8HHyhMhy5QymSuDhJcRqNqFMNssYGf0n0jnQWPiVeuStiFyi2H5bwUkgd7cOyNq(WqSUPrga7W8alxfJHfeaf7eYhgIDyEGLRIXWIP7yuyf6g6Z8ussgSGUHoPbg7wqauStiFyi2H5bqLCvqq3XOWk0j0N5PKKm4YvXyyQqCIbk2jKpmeRBAKbWompWYvXyyP30DmkScDd9zEkjjdwq3qN0OcX5cOyNq(WqSUPrga7W8alxfJHfeev3XOWk0nKqGbqXmGmknT0BGIDc5ddXompWYvXyyX0DmkScDd9zEkjjdwq3qN0aJDliak2jKpme7W8aOsUE961RxfeKtmwk9qMGcSCvmg2fqXoH8HHyhMhy5Qym8vbbr1DmkScDdjeyaumdiJstlvuFcITWuifh7eM0B6ogfwHoHecmakMbKrPPLE7MOGIDc5ddXompaQebbDhJcRqNqFMNssYGlxfJHftCxLEduStiFyi2H5bwUkgdlMBrkiO7yuyf6e6Z8ussgC5QymmvioXaf7eYhgIDyEGLRIXWxVkiiQUJrHvOtiHadGIzazuAAP3ev3XOWk0jKqGb8zEkjjtqq3XOWk0j0N5PKKm4YvXyybbDhJcRqNqFMNssYGf0n0jnXUR7yuyf6g6Z8ussgSGUHoPD9kIIOii]] )


end