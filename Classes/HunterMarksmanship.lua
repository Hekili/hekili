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


    spec:RegisterPack( "Marksmanship", 20220221, [[dafRpcqicLhrLeUeqf1MisFcHmka6uaQvHKu4vaOzbu6wijzxG(fcLHri6yurlJk1ZaQ00qsQUgHQ2gvs6BeQOXrOcDocvQ1ba9oGkqnpQe3dq2hH0)iuj1bPsISqcHhcaMiHkWfbQqTrGkq(iqfYijujPtsLe1krs9sKKIAMuj1nrskYobk(jqf0qbQawkHkXtLutfOQVsOcASiuTxi(RknyvDyHftupMQMSexg1MrQpJOgncoTIvtOsIxJeZwf3ws2nLFlA4eXXrskTCLEoutN01H02bY3rKXJK48uH1durMpb7xQrCIaEK6sOmcyCls3UfPB3oHof3uDXPBNi1QdjmsTKWtjiZi1wuXi1unflfCvyycJeKAjHJtgfeWJuJt01Zi1UI(jOQemasmIrEucOYqFwrm8uHEcDsZVbTsm8u5jgsTm6CuxzdrgPUekJag3I0TBr62TtOtXnvxC6uCePoqvc5IuxpvaasnHPuydrgPUWypsnvtXsbxfgMWiPFXvrnL3MAWbXYlASo63TtW2VBr62DtDtnaqimYmgaBQPQ(bdtIorTs)IlmopG4(hC)wQ9h9xXEcHn((vcC)rPKw)(WigP5C6VkSGmdBQPQ(fxySdZZL(JsjT(LStUJ6OFsJsO)6Pca63vcCaxdBQPQ(DnR9t1SJDcd3FHXomF)kbE2(baXb4(XzfRtfJHi1NbRyeWJuR74PGjKkgb8iGXjc4rQzlKpCbrei1(DuENaPwJdBkeRCuCCPtpkgYwiF4s)s7FSl9zitq7xA)YO00qSYrXXLo9Oy4YvXy4(DPFXJuhEDsdPgRCuCCXesfrraJBeWJuZwiF4cIiqQ97O8obs9IAmDUKzOKe1t4M03naNY9sVb5k2umKTq(WL(L2VmknnK(eo4fFRILcevcsD41jnKAkZ5CXesfrrad4IaEKA2c5dxqebsTFhL3jqQxuJPZLmdLKOEc3K(Ub4uUx6nixXMIHSfYhUGuhEDsdPM(eo4YftivefbmuDeWJuZwiF4cIiqQ97O8obsnG97tqSfMcP4yNW6xA)(mpLKKbxgNwOJr(g7MKGlxfJH73L(j7l9li0Vy97tqSfMcP4yNW6xA)I1VpbXwyk0gYe0lDW9li0VpbXwyk0gYe0lDW9lTFa73N5PKKmiP5uUyjZokgUCvmgUFx6NSV0VGq)(mpLKKbjnNYflz2rXWLRIXW9lA)GRi7h4(fe6xJLmRqDQ4RM3YW97s)ofz)cc97Z8ussgCzCAHog5BSBscUCvmgUFr73Pi7xA)Hxhq8LnUAyC)I2p42pW9lTFa7xS(3ykxgeBkmkfmKPYGvC)cc9VXuUmi2uyuky4YvXy4(fTFXD)cc9lw)(eeBHPqko2jS(bgPo86KgsDjrLp8vdjikcyepc4rQzlKpCbrei1(DuENaPErnMoxYmeNOh6CjZxUsMxmKTq(WL(L2Vg7v3qcC5QymC)U0pzFPFP97Z8ussgK(eldxUkgd3Vl9t2xqQdVoPHuRXE1nKGOiGXvrapsnBH8HliIaPo86Kgsn9jwgP2VJY7ei1ASxDdjquj9lT)f1y6CjZqCIEOZLmF5kzEXq2c5dxqQpJXxFbP2T4rueWiorapsD41jnKAMksojEaXxmHurQzlKpCbreikcyehrapsnBH8HliIaP2VJY7ei1I1)gt5YGytHrPGHmvgSI7xqO)nMYLbXMcJsbdxUkgd3VO97uK9li0F41beFzJRgg3VOa1)gt5YGytHrPGH(e10(PA0VBK6WRtAi1KMt5ILm7OyefbmIBeWJuZwiF4cIiqQ97O8obsTpZtjjzWLXPf6yKVXUjj4YvXy4(DPFY(s)s7hW(fRFnoSPqMksojEaXxmHuHSfYhU0VGq)YO00q5tMLdkwHOs6h4(fe6xS(9ji2ctHuCSty9li0VpZtjjzWLXPf6yKVXUjj4YvXy4(fTFNISFbH(LtmUFP9tpKjO3LRIXW97s)IhPo86KgsnPyoJr(g7MKqueW4uKiGhPMTq(WferGu73r5DcKAa73N5PKKmiO8CyhWLRIXW97s)K9L(fe6xS(14WMcbLNd7aYwiF4s)cc9RXsMvOov8vZBz4(DPFNU7h4(L2pG9lw)BmLldInfgLcgYuzWkUFbH(3ykxgeBkmkfmC5QymC)I2V4UFbH(dVoG4lBC1W4(ffO(3ykxgeBkmkfm0NOM2pvJ(D3pWi1HxN0qQxgNwOJr(g7MKqueW40jc4rQzlKpCbrei1(DuENaPwgLMgUmoTqhJ8n2njbrL0VGq)(mpLKKbxgNwOJr(g7MKGlxfJH7x0(DkY(fe6xS(9ji2ctHuCStyi1HxN0qQbLNd7arraJt3iGhPo86KgsTCSBqMrQzlKpCbreikcyCcUiGhPMTq(WferGu73r5DcKAzuAA4Y40cDmY3y3Keevs)cc97Z8ussgCzCAHog5BSBscUCvmgUFr73Pi7xqOFX63NGylmfsXXoH1VGq)Yjg3V0(PhYe07YvXy4(DPF3IePo86KgsTUOmMqQikcyCs1rapsnBH8HliIaP2VJY7ei1lQX05sMHy0L8yKVycPIHSfYhU0V0(bSFFMNssYGlJtl0XiFJDtsWLRIXW9lA)ofz)cc9lw)(eeBHPqko2jS(fe6xS(14WMcljQ8HVAibYwiF4s)a3V0(LrPPH6oEkxmHuXWLRIXW9lkq9ZuH9OkF1PIrQdVoPHuVHKPCPNLrueW4u8iGhPMTq(WferGuhEDsdPoMkUCXesfP2VJY7ei1YO00qDhpLlMqQy4YvXy4(ffO(zQWEuLV6uX9lTFa7xgLMgkzz)G5lMqQyyjjz9li0pn65Cx2tiwY8vNkUFx63hy9Qtf3pa7NSV0VGq)YO00qDrzmHuHOs6hyKAVd)HVASKzfJagNikcyC6QiGhPMTq(WferGu73r5DcKA60JI7hG97dSExMmB97s)0PhfdRcQGuhEDsdPUWHs46jeu2OcrraJtXjc4rQzlKpCbrei1(DuENaPgW(9zEkjjdUmoTqhJ8n2njbxUkgd3VO97uK9lT)f1y6CjZqm6sEmYxmHuXq2c5dx6xqOFX63NGylmfsXXoH1VGq)I1)IAmDUKzigDjpg5lMqQyiBH8Hl9li0Vy9RXHnfwsu5dF1qcKTq(WL(bUFP9lJstd1D8uUycPIHlxfJH7xuG6NPc7rv(QtfJuhEDsdPEdjt5splJOiGXP4ic4rQzlKpCbrei1(DuENaPwgLMgQ74PCXesfdljjRFbH(LrPPHsw2py(IjKkgIkPFP9tNEuC)I2VpXA)aS)WRtAWyQ4YftivOpXA)s7hW(fRFnoSPqpHPk4nUycPczlKpCPFbH(dVoG4lBC1W4(fTFWTFGrQdVoPHuxHE0btivefbmof3iGhPMTq(WferGu73r5DcKAzuAAOKL9dMVycPIHOs6xA)0Phf3VO97tS2pa7p86KgmMkUCXesf6tS2V0(dVoG4lBC1W4(DPFQosD41jnKApHPk4nUycPIOiGXTirapsnBH8HliIaP2VJY7ei1YO00WchLl7GHLKKHuhEDsdPMYCoxmHurueW42jc4rQdVoPHuh3k0TW7nPV(njHrQzlKpCbreikcyC7gb8i1HxN0qQPpHdUCXesfPMTq(WferGOiGXn4IaEKA2c5dxqebsD41jnKAmVsytVyDmYi1(DuENaPEz6LXec5dJu7D4p8vJLmRyeW4erraJBQoc4rQzlKpCbrei1(DuENaPMo9O4(fTFFI1(by)HxN0GXuXLlMqQqFI1(L2pG97Z8ussgCzCAHog5BSBscUCvmgUFr7x89li0Vy97tqSfMcP4yNW6hyK6WRtAi1vOhDWesfrraJBXJaEKA2c5dxqebsTFhL3jqQxuJPZLmdngJhJmPyDGV6gsKmg5BirsSHIIHSfYhUGuhEDsdPwJ9QBibrraJBxfb8i1SfYhUGicKA)okVtGuVOgtNlzgAmgpgzsX6aF1nKizmY3qIKydffdzlKpCbPo86Kgsn9Ym40yKV6gsqueW4wCIaEKA2c5dxqebsTFhL3jqQLrPPH6IYycPcljjdPo86KgsTCq(M0xDhpfmIIag3IJiGhPMTq(WferGu73r5DcKACIEKhRaLGIv0dF5fvIoPbzlKpCPFP9lJstd1fLXesfwssgsD41jnKA6dJj43GwrueW4wCJaEK6WRtAi1yLJIJlMqQi1SfYhUGicefrrQlmDGEueWJagNiGhPo86KgsTprnL3lMqQi1SfYhUGicefbmUrapsnBH8HliIaPo86KgsTprnL3lMqQi1(DuENaPErnMoxYmeZsiGcoHVs20FIQqN0GSfYhU0VGq)4e9ipwbAJJaF1mp4RKCWPbzlKpCPFbH(bSFFAf0rHldIxCCUj9Loxf1yiBH8Hl9lTFX6FrnMoxYmeZsiGcoHVs20FIQqN0GSfYhU0pWi1NX4RVGudUIerrad4IaEKA2c5dxqebsD41jnKADdJQfDod40yKVycPIuxySFhj6Kgsn4OS)GahL(dR0p43WOArNZaoX9dgWbaG(zJRggd2(jX9xsJiT)s2VsyW9tNB)soHdEX9lZ(afZ9pkrL(L5(1m7hljQQC0FyL(jX97dJiT)LJYCC0p43WOA7hlH9d947xgLMgdrQ97O8obsTy9RXsMv4GVsoHdErueWq1rapsnBH8HliIaP2VJY7ei1(eeBHPqko2jS(L2VpZtjjzqDrzmHuHlxfJH7xA)(mpLKKbxgNwOJr(g7MKGlxfJH7xqOFX63NGylmfsXXoH1V0(9zEkjjdQlkJjKkC5QymmsD41jnKAFCo3WRtA3ZGvK6ZG1RfvmsTUJrHvmIIagXJaEKA2c5dxqebsD41jnKAFCo3WRtA3ZGvK6ZG1RfvmsTVGrueW4QiGhPMTq(WferGu73r5DcK6WRdi(YgxnmUFx6hCrQX6oEfbmorQdVoPHu7JZ5gEDs7EgSIuFgSETOIrQXkIIagXjc4rQzlKpCbrei1(DuENaPo86aIVSXvdJ7x0(DJuJ1D8kcyCIuhEDsdP2hNZn86K29myfP(my9ArfJuR74PGjKkgrruKAjl7Zk5qrapcyCIaEK6WRtAi1YPQhUCPpHdUqAmYxnPYyi1SfYhUGicefbmUrapsD41jnKA6dJj43GwrQzlKpCbreikcyaxeWJuZwiF4cIiqQ97O8obs9IAmDUKziorp05sMVCLmVyiBH8Hli1HxN0qQ1yV6gsqueWq1rapsnBH8HliIaPwYY(aRxDQyKANIePo86KgsDjrLp8vdji1(DuENaPo86aIVSXvdJ7x0(D2VGq)I1VpbXwykKIJDcRFP9lw)ACytHGYZHDazlKpCbrraJ4rapsnBH8HliIaP2VJY7ei1Hxhq8LnUAyC)U0p42V0(bSFX63NGylmfsXXoH1V0(fRFnoSPqq55WoGSfYhU0VGq)Hxhq8LnUAyC)U0V7(bgPo86KgsDmvC5IjKkIIagxfb8i1SfYhUGicKA)okVtGuhEDaXx24QHX9lA)U7xqOFa73NGylmfsXXoH1VGq)ACytHGYZHDazlKpCPFG7xA)Hxhq8LnUAyC)a1VBK6WRtAi1yLJIJlMqQikIIu7lyeWJagNiGhPMTq(WferGu73r5DcKAa7xgLMgQlkJjKkevs)s7xgLMgUmoTqhJ8n2njbrL0V0(9ji2ctHuCSty9dC)cc9dy)YO00qDrzmHuHOs6xA)YO00qsZPCXsMDumevs)s73NGylmfAdzc6Lo4(bUFbH(bSFFcITWuii2uco2(fe63NGylmfASFZtUL(bUFP9lJstd1fLXesfIkPFbH(LtmUFP9tpKjO3LRIXW97s)ob3(fe6hW(9ji2ctHuCSty9lTFzuAA4Y40cDmY3y3Keevs)s7NEitqVlxfJH73L(fNGB)aJuhEDsdPwMxmVugJmIIag3iGhPMTq(WferGu73r5DcKAzuAAOUOmMqQquj9li0VpZtjjzqDrzmHuHlxfJH7x0(bxr2VGq)Yjg3V0(PhYe07YvXy4(DPFNUksD41jnKA5tMLln66arrad4IaEKA2c5dxqebsTFhL3jqQLrPPH6IYycPcrL0VGq)(mpLKKb1fLXesfUCvmgUFr7hCfz)cc9lNyC)s7NEitqVlxfJH73L(D6Qi1HxN0qQdZZyDJZ1hNdIIagQoc4rQzlKpCbrei1(DuENaPwgLMgQlkJjKkevs)cc97Z8ussguxugtiv4YvXy4(fTFWvK9li0VCIX9lTF6Hmb9UCvmgUFx6xCJuhEDsdPMEww(KzbrraJ4rapsnBH8HliIaP2VJY7ei1YO00qDrzmHuHLKKHuhEDsdP(mKjO4R4kOfYvSPikcyCveWJuZwiF4cIiqQ97O8obsTmknnuxugtiviQK(L2pG9lJstdLpzwoOyfIkPFbH(1yjZkKahhLauIx73L(DlY(bUFbH(LtmUFP9tpKjO3LRIXW97s)UD1(fe6hW(9ji2ctHuCSty9lTFzuAA4Y40cDmY3y3Keevs)s7NEitqVlxfJH73L(fNU7hyK6WRtAi1ssDsdrruKASIaEeW4eb8i1SfYhUGicKA)okVtGuRXHnfIvokoU0PhfdzlKpCPFP9dy)swg0LSVaDcXkhfhxmHu7xA)YO00qSYrXXLo9Oy4YvXy4(DPFX3VGq)YO00qSYrXXLo9Oyyjjz9dC)s7hW(LrPPHlJtl0XiFJDtsWssY6xqOFX63NGylmfsXXoH1pWi1HxN0qQXkhfhxmHurueW4gb8i1HxN0qQPmNZftivKA2c5dxqebIIagWfb8i1SfYhUGicKA)okVtGudy)(eeBHPqko2jS(L2pG97Z8ussgCzCAHog5BSBscUCvmgUFx6NSV0pW9li0Vy97tqSfMcP4yNW6xA)I1VpbXwyk0gYe0lDW9li0VpbXwyk0gYe0lDW9lTFa73N5PKKmiP5uUyjZokgUCvmgUFx6NSV0VGq)(mpLKKbjnNYflz2rXWLRIXW9lA)GRi7h4(fe6NEitqVlxfJH73L(Dk((bUFP9dy)I1)gt5YGytHrPGHmvgSI7xqO)nMYLbXMcJsbdrL0V0(bS)nMYLbXMcJsbdhRFx63Pi7xA)BmLldInfgLcgUCvmgUFx6hC7xqO)nMYLbXMcJsbdhRFr7p86K21N5PKKS(fe6p86aIVSXvdJ7x0(D2pW9li0Vy9VXuUmi2uyukyiQK(L2pG9VXuUmi2uyukyOprnTFG63z)cc9VXuUmi2uyuky4y9lA)HxN0U(mpLKK1pW9dmsD41jnK6sIkF4RgsqueWq1rapsnBH8HliIaP2VJY7ei1ASxDdjquj9lT)f1y6CjZqCIEOZLmF5kzEXq2c5dxqQdVoPHutFILrueWiEeWJuZwiF4cIiqQ97O8obs9IAmDUKziorp05sMVCLmVyiBH8Hl9lTFn2RUHe4YvXy4(DPFY(s)s73N5PKKmi9jwgUCvmgUFx6NSVGuhEDsdPwJ9QBibrraJRIaEK6WRtAi1mvKCs8aIVycPIuZwiF4cIiqueWiorapsnBH8HliIaP2VJY7ei1I1)gt5YGytHrPGHmvgSI7xqOFX6FJPCzqSPWOuWquj9lT)nMYLbXMcJsbdlOBOtA9dW(3ykxgeBkmkfmCS(DPF3ISFbH(3ykxgeBkmkfmevs)s7FJPCzqSPWOuWWLRIXW9lA)of39li0F41beFzJRgg3VO97ePo86KgsnP5uUyjZokgrraJ4ic4rQdVoPHutFchC5IjKksnBH8HliIarraJ4gb8i1SfYhUGicKA)okVtGutNEuC)aSFFG17YKzRFx6No9OyyvqfK6WRtAi1foucxpHGYgvikcyCkseWJuhEDsdPoUvOBH3BsF9BscJuZwiF4cIiqueW40jc4rQzlKpCbrei1(DuENaP2N5PKKm4Y40cDmY3y3KeC5QymC)U0pzFPFP9dy)I1Vgh2uitfjNepG4lMqQq2c5dx6xqOFzuAAO8jZYbfRquj9dC)cc9lw)(eeBHPqko2jS(fe63N5PKKm4Y40cDmY3y3KeC5QymC)cc9lNyC)s7NEitqVlxfJH73L(fpsD41jnKAsXCgJ8n2njHOiGXPBeWJuZwiF4cIiqQ97O8obsnG9lJstdljQ8HVAibIkPFbH(9zEkjjdwsu5dF1qcC5QymC)I2Vtr2VGq)I1Vgh2uyjrLp8vdjq2c5dx6xqOF6Hmb9UCvmgUFx63P7(bUFP9dy)I1)gt5YGytHrPGHmvgSI7xqOFX6FJPCzqSPWOuWquj9lTFa7FJPCzqSPWOuWWc6g6Kw)aS)nMYLbXMcJsbdhRFx63Pi7xqO)nMYLbXMcJsbd9jQP9du)o7h4(fe6FJPCzqSPWOuWquj9lT)nMYLbXMcJsbdxUkgd3VO9lU7xqO)WRdi(YgxnmUFr73z)aJuhEDsdPEzCAHog5BSBscrraJtWfb8i1SfYhUGicKA)okVtGulJstdxgNwOJr(g7MKGOs6xqOFFMNssYGlJtl0XiFJDtsWLRIXW9lA)ofz)cc9lw)(eeBHPqko2jS(L2pG9lJstdLSSFW8ftivmSKKS(fe6xS(14WMc9eMQG34IjKkKTq(WL(fe6p86aIVSXvdJ73L(D3pWi1HxN0qQbLNd7arraJtQoc4rQzlKpCbrei1(DuENaP2NGylmfsXXoH1V0(PtpkUFa2VpW6DzYS1Vl9tNEumSkOs)s7hW(bSFFMNssYGlJtl0XiFJDtsWLRIXW97s)K9L(PA0p42V0(bSFX6hNOh5XkqMMgfpG4BytvCdVNp8gAUq2c5dx6xqOFX6xJdBkSKOYh(QHeiBH8Hl9dC)a3VGq)ACytHLev(WxnKazlKpCPFP97Z8ussgSKOYh(QHe4YvXy4(DPFWTFGrQdVoPHuJvokoUycPIOiGXP4rapsnBH8HliIaP2VJY7ei1YO00qjl7hmFXesfdljjRFP9dy)(eeBHPqqSPeCS9li0VpbXwyk0y)MNCl9li0Vgh2uOpoNXiFvc8ftivmKTq(WL(bUFbH(LrPPHlJtl0XiFJDtsquj9li0VpZtjjzWLXPf6yKVXUjj4YvXy4(fTFNISFbH(LrPPHKMt5ILm7OyiQK(fe6xgLMgckph2bevs)s7p86aIVSXvdJ7x0(D2VGq)Yjg3V0(PhYe07YvXy4(DPF3IhPo86KgsTUOmMqQikcyC6QiGhPMTq(WferGu73r5DcK6f1y6CjZqm6sEmYxmHuXq2c5dx6xA)ACytHyD5O6mgdzlKpCPFP9dy)(mpLKKbxgNwOJr(g7MKGlxfJH7x0(DkY(fe6xS(9ji2ctHuCSty9li0Vy9RXHnfwsu5dF1qcKTq(WL(fe6hNOh5XkqMMgfpG4BytvCdVNp8gAUq2c5dx6hyK6WRtAi1Bizkx6zzefbmofNiGhPMTq(WferGuhEDsdPoMkUCXesfP2VJY7ei1YO00qjl7hmFXesfdljjRFbH(bSFzuAAOUOmMqQquj9li0pn65Cx2tiwY8vNkUFx6NSV0pa73hy9Qtf3pW9lTFa7xS(14WMc9eMQG34IjKkKTq(WL(fe6p86aIVSXvdJ73L(D3pW9li0Vmknnu3Xt5IjKkgUCvmgUFr7NPc7rv(Qtf3V0(dVoG4lBC1W4(fTFNi1Eh(dF1yjZkgbmorueW4uCeb8i1SfYhUGicKA)okVtGudy)(mpLKKbxgNwOJr(g7MKGlxfJH7x0(DkY(fe6xS(9ji2ctHuCSty9li0Vy9RXHnfwsu5dF1qcKTq(WL(fe6hNOh5XkqMMgfpG4BytvCdVNp8gAUq2c5dx6h4(L2pD6rX9dW(9bwVltMT(DPF60JIHvbv6xA)a2VmknnSKOYh(QHeyjjz9lTFzuAAihKpSgN0WxDr5lD6rXWssY6xqOFnoSPqSUCuDgJHSfYhU0pWi1HxN0qQ3qYuU0ZYikcyCkUrapsnBH8HliIaP2VJY7ei1YO00qjl7hmFXesfdrL0VGq)0Phf3VO97tS2pa7p86KgmMkUCXesf6tSIuhEDsdP2tyQcEJlMqQikcyClseWJuZwiF4cIiqQ97O8obsTmknnuYY(bZxmHuXquj9li0pD6rX9lA)(eR9dW(dVoPbJPIlxmHuH(eRi1HxN0qQJ1hgFXesfrraJBNiGhPMTq(WferGuhEDsdPgZRe20lwhJmsTFhL3jqQxMEzmHq(W9lTFnwYSc1PIVAEld3VO9xq3qN0qQ9o8h(QXsMvmcyCIOiGXTBeWJuZwiF4cIiqQ97O8obsD41beFzJRgg3VO97ePo86KgsTCSBqMrueW4gCrapsnBH8HliIaP2VJY7ei1a2VpZtjjzWLXPf6yKVXUjj4YvXy4(fTFNISFP9VOgtNlzgIrxYJr(IjKkgYwiF4s)cc9lw)(eeBHPqko2jS(fe6xS(14WMcljQ8HVAibYwiF4s)cc9Jt0J8yfittJIhq8nSPkUH3ZhEdnxiBH8Hl9dC)s7No9O4(by)(aR3LjZw)U0pD6rXWQGk9lTFa7xgLMgwsu5dF1qcSKKS(fe6xJdBkeRlhvNXyiBH8Hl9dmsD41jnK6nKmLl9SmIIag3uDeWJuZwiF4cIiqQ97O8obsTmknnuxugtivyjjzi1HxN0qQLdY3K(Q74PGrueW4w8iGhPMTq(WferGu73r5DcKACIEKhRaLGIv0dF5fvIoPbzlKpCPFP9lJstd1fLXesfwssgsD41jnKA6dJj43GwrueW42vrapsD41jnKASYrXXftivKA2c5dxqebIIOi16ogfwXiGhbmorapsnBH8HliIaPoLGuJzfPo86KgsnOyNq(Wi1GIdkJulJstdxgNwOJr(g7MKGOs6xqOFzuAAOUOmMqQquji1GI9ArfJuJDy(lQeefbmUrapsnBH8HliIaPoLGuJzfPo86KgsnOyNq(Wi1GIdkJu7tqSfMcP4yNW6xA)YO00WLXPf6yKVXUjjiQK(L2VmknnuxugtiviQK(fe6xS(9ji2ctHuCSty9lTFzuAAOUOmMqQquji1GI9ArfJuJ1nnYxSdZFrLGOiGbCrapsnBH8HliIaPoLGuJzDOrQdVoPHudk2jKpmsnOyVwuXi1yDtJ8f7W83LRIXWi1(DuENaPwgLMgQlkJjKkSKKS(L2VpbXwykKIJDcdPguCq5lFWmsTpZtjjzqDrzmHuHlxfJHrQbfhugP2N5PKKm4Y40cDmY3y3KeC5QymC)UiUUFFMNssYG6IYycPcxUkgdJOiGHQJaEKA2c5dxqebsDkbPgZ6qJuhEDsdPguStiFyKAqXETOIrQX6Mg5l2H5VlxfJHrQ97O8obsTmknnuxugtiviQK(L2VpbXwykKIJDcdPguCq5lFWmsTpZtjjzqDrzmHuHlxfJHrQbfhugP2N5PKKm4Y40cDmY3y3KeC5QymmIIagXJaEKA2c5dxqebsDkbPgZ6qJuhEDsdPguStiFyKAqXETOIrQXom)D5QymmsTFhL3jqQ9ji2ctHuCStyi1GIdkF5dMrQ9zEkjjdQlkJjKkC5QymmsnO4GYi1(mpLKKbxgNwOJr(g7MKGlxfJH7xuX197Z8ussguxugtiv4YvXyyefbmUkc4rQzlKpCbrei1HxN0qQ1DmkS6eP2VJY7ei1a2VUJrHvO6esiWxumFLrPP7xqOFFcITWuifh7ew)s7x3XOWkuDcje4RpZtjjz9dC)s7hW(bf7eYhgI1nnYxSdZFrL0V0(bSFX63NGylmfsXXoH1V0(fRFDhJcRq1nKqGVOy(kJst3VGq)(eeBHPqko2jS(L2Vy9R7yuyfQUHec81N5PKKS(fe6x3XOWkuDd9zEkjjdUCvmgUFbH(1DmkScvNqcb(II5RmknD)s7hW(fRFDhJcRq1nKqGVOy(kJst3VGq)6ogfwHQtOpZtjjzWc6g6Kw)Icu)6ogfwHQBOpZtjjzWc6g6Kw)a3VGq)6ogfwHQtiHaF9zEkjjRFP9lw)6ogfwHQBiHaFrX8vgLMUFP9R7yuyfQoH(mpLKKblOBOtA9lkq9R7yuyfQUH(mpLKKblOBOtA9dC)cc9lw)GIDc5ddX6Mg5l2H5VOs6xA)a2Vy9R7yuyfQUHec8ffZxzuA6(L2pG9R7yuyfQoH(mpLKKblOBOtA9tv9l((DPFqXoH8HHyhM)UCvmgUFbH(bf7eYhgIDy(7YvXy4(fTFDhJcRq1j0N5PKKmybDdDsRFI1V7(bUFbH(1DmkScv3qcb(II5RmknD)s7hW(1DmkScvNqcb(II5RmknD)s7x3XOWkuDc9zEkjjdwq3qN06xuG6x3XOWkuDd9zEkjjdwq3qN06xA)a2VUJrHvO6e6Z8ussgSGUHoP1pv1V473L(bf7eYhgIDy(7YvXy4(fe6huStiFyi2H5VlxfJH7x0(1DmkScvNqFMNssYGf0n0jT(jw)U7h4(fe6hW(fRFDhJcRq1jKqGVOy(kJst3VGq)6ogfwHQBOpZtjjzWc6g6Kw)Icu)6ogfwHQtOpZtjjzWc6g6Kw)a3V0(bSFDhJcRq1n0N5PKKm4YrXr)s7x3XOWkuDd9zEkjjdwq3qN06NQ6x89lA)GIDc5ddXom)D5QymC)s7huStiFyi2H5VlxfJH73L(1DmkScv3qFMNssYGf0n0jT(jw)U7xqOFX6x3XOWkuDd9zEkjjdUCuC0V0(bSFDhJcRq1n0N5PKKm4YvXy4(PQ(fF)U0pOyNq(WqSUPr(IDy(7YvXy4(L2pOyNq(WqSUPr(IDy(7YvXy4(fTF3ISFP9dy)6ogfwHQtOpZtjjzWc6g6Kw)uv)IVFx6huStiFyi2H5VlxfJH7xqOFDhJcRq1n0N5PKKm4YvXy4(PQ(fF)U0pOyNq(WqSdZFxUkgd3V0(1DmkScv3qFMNssYGf0n0jT(PQ(DkY(by)GIDc5ddXom)D5QymC)U0pOyNq(WqSUPr(IDy(7YvXy4(fe6huStiFyi2H5VlxfJH7x0(1DmkScvNqFMNssYGf0n0jT(jw)U7xqOFqXoH8HHyhM)IkPFG7xqOFDhJcRq1n0N5PKKm4YvXy4(PQ(fF)I2pOyNq(WqSUPr(IDy(7YvXy4(L2pG9R7yuyfQoH(mpLKKblOBOtA9tv9l((DPFqXoH8HHyDtJ8f7W83LRIXW9li0Vy9R7yuyfQoHec8ffZxzuA6(L2pG9dk2jKpme7W83LRIXW9lA)6ogfwHQtOpZtjjzWc6g6Kw)eRF39li0pOyNq(WqSdZFrL0pW9dC)a3pW9dC)a3VGq)Yjg3V0(PhYe07YvXy4(DPFqXoH8HHyhM)UCvmgUFG7xqOFX6x3XOWkuDcje4lkMVYO009lTFX63NGylmfsXXoH1V0(bSFDhJcRq1nKqGVOy(kJst3V0(bSFa7xS(bf7eYhgIDy(lQK(fe6x3XOWkuDd9zEkjjdUCvmgUFr7x89dC)s7hW(bf7eYhgIDy(7YvXy4(fTF3ISFbH(1DmkScv3qFMNssYGlxfJH7NQ6x89lA)GIDc5ddXom)D5QymC)a3pW9li0Vy9R7yuyfQUHec8ffZxzuA6(L2pG9lw)6ogfwHQBiHaF9zEkjjRFbH(1DmkScv3qFMNssYGlxfJH7xqOFDhJcRq1n0N5PKKmybDdDsRFrbQFDhJcRq1j0N5PKKmybDdDsRFG7hyKA8jvmsTUJrHvNikcyeNiGhPMTq(WferGuhEDsdPw3XOWQBKA)okVtGudy)6ogfwHQBiHaFrX8vgLMUFbH(9ji2ctHuCSty9lTFDhJcRq1nKqGV(mpLKK1pW9lTFa7huStiFyiw30iFXom)fvs)s7hW(fRFFcITWuifh7ew)s7xS(1DmkScvNqcb(II5RmknD)cc97tqSfMcP4yNW6xA)I1VUJrHvO6esiWxFMNssY6xqOFDhJcRq1j0N5PKKm4YvXy4(fe6x3XOWkuDdje4lkMVYO009lTFa7xS(1DmkScvNqcb(II5RmknD)cc9R7yuyfQUH(mpLKKblOBOtA9lkq9R7yuyfQoH(mpLKKblOBOtA9dC)cc9R7yuyfQUHec81N5PKKS(L2Vy9R7yuyfQoHec8ffZxzuA6(L2VUJrHvO6g6Z8ussgSGUHoP1VOa1VUJrHvO6e6Z8ussgSGUHoP1pW9li0Vy9dk2jKpmeRBAKVyhM)IkPFP9dy)I1VUJrHvO6esiWxumFLrPP7xA)a2VUJrHvO6g6Z8ussgSGUHoP1pv1V473L(bf7eYhgIDy(7YvXy4(fe6huStiFyi2H5VlxfJH7x0(1DmkScv3qFMNssYGf0n0jT(jw)U7h4(fe6x3XOWkuDcje4lkMVYO009lTFa7x3XOWkuDdje4lkMVYO009lTFDhJcRq1n0N5PKKmybDdDsRFrbQFDhJcRq1j0N5PKKmybDdDsRFP9dy)6ogfwHQBOpZtjjzWc6g6Kw)uv)IVFx6huStiFyi2H5VlxfJH7xqOFqXoH8HHyhM)UCvmgUFr7x3XOWkuDd9zEkjjdwq3qN06Ny97UFG7xqOFa7xS(1DmkScv3qcb(II5RmknD)cc9R7yuyfQoH(mpLKKblOBOtA9lkq9R7yuyfQUH(mpLKKblOBOtA9dC)s7hW(1DmkScvNqFMNssYGlhfh9lTFDhJcRq1j0N5PKKmybDdDsRFQQFX3VO9dk2jKpme7W83LRIXW9lTFqXoH8HHyhM)UCvmgUFx6x3XOWkuDc9zEkjjdwq3qN06Ny97UFbH(fRFDhJcRq1j0N5PKKm4YrXr)s7hW(1DmkScvNqFMNssYGlxfJH7NQ6x897s)GIDc5ddX6Mg5l2H5VlxfJH7xA)GIDc5ddX6Mg5l2H5VlxfJH7x0(DlY(L2pG9R7yuyfQUH(mpLKKblOBOtA9tv9l((DPFqXoH8HHyhM)UCvmgUFbH(1DmkScvNqFMNssYGlxfJH7NQ6x897s)GIDc5ddXom)D5QymC)s7x3XOWkuDc9zEkjjdwq3qN06NQ63Pi7hG9dk2jKpme7W83LRIXW97s)GIDc5ddX6Mg5l2H5VlxfJH7xqOFqXoH8HHyhM)UCvmgUFr7x3XOWkuDd9zEkjjdwq3qN06Ny97UFbH(bf7eYhgIDy(lQK(bUFbH(1DmkScvNqFMNssYGlxfJH7NQ6x89lA)GIDc5ddX6Mg5l2H5VlxfJH7xA)a2VUJrHvO6g6Z8ussgSGUHoP1pv1V473L(bf7eYhgI1nnYxSdZFxUkgd3VGq)I1VUJrHvO6gsiWxumFLrPP7xA)a2pOyNq(WqSdZFxUkgd3VO9R7yuyfQUH(mpLKKblOBOtA9tS(D3VGq)GIDc5ddXom)fvs)a3pW9dC)a3pW9dC)cc9lNyC)s7NEitqVlxfJH73L(bf7eYhgIDy(7YvXy4(bUFbH(fRFDhJcRq1nKqGVOy(kJst3V0(fRFFcITWuifh7ew)s7hW(1DmkScvNqcb(II5RmknD)s7hW(bSFX6huStiFyi2H5VOs6xqOFDhJcRq1j0N5PKKm4YvXy4(fTFX3pW9lTFa7huStiFyi2H5VlxfJH7x0(DlY(fe6x3XOWkuDc9zEkjjdUCvmgUFQQFX3VO9dk2jKpme7W83LRIXW9dC)a3VGq)I1VUJrHvO6esiWxumFLrPP7xA)a2Vy9R7yuyfQoHec81N5PKKS(fe6x3XOWkuDc9zEkjjdUCvmgUFbH(1DmkScvNqFMNssYGf0n0jT(ffO(1DmkScv3qFMNssYGf0n0jT(bUFGrQXNuXi16ogfwDJOikIIudIx8KgcyCls3oD60n4IutkwBmYyKAXHUsIlGXvgmGJaW(7h8e4(Nkj5Q9tNB)eP74PGjKkMO(xMQfDwU0poR4(dunRcLl97jegzgdBQD9yC)obW(bG0aXRYL(jsJdBkK4e1VM9tKgh2uiXHSfYhUqu)a6KkadBQD9yC)UbW(bG0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHSfYhUqu)a6KkadBQD9yC)Gla2paKgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKTq(WfI6p0(bhdo019dOtQamSP21JX9lEaSFainq8QCPFIwuJPZLmdjor9Rz)eTOgtNlzgsCiBH8Hle1pGoPcWWMAxpg3VRcG9daPbIxLl9t0IAmDUKziXjQFn7NOf1y6CjZqIdzlKpCHO(dTFWXGdDD)a6KkadBQD9yC)IBaSFainq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1pGoPcWWMAxpg3VtrcG9daPbIxLl9tKgh2uiXjQFn7NinoSPqIdzlKpCHO(b0jvag2u76X4(Ds1bW(bG0aXRYL(jsJdBkK4e1VM9tKgh2uiXHSfYhUqu)a6KkadBQD9yC)oP6ay)aqAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQFaDsfGHn1UEmUFNItaSFainq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1pGoPcWWMAxpg3VtXja2paKgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKTq(WfI6hq3ubyytTRhJ73P4ia2paKgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6hqNubyytTRhJ73T4bW(bG0aXRYL(jArnMoxYmK4e1VM9t0IAmDUKziXHSfYhUqu)H2p4yWHUUFaDsfGHn1UEmUF3Uka2paKgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKTq(WfI6p0(bhdo019dOtQamSP21JX97wCea7hasdeVkx6NiCIEKhRajor9Rz)eHt0J8yfiXHSfYhUqu)a6KkadBQBQfh6kjUagxzWaoca7VFWtG7FQKKR2pDU9tuHPd0Jsu)lt1Iolx6hNvC)bQMvHYL(9ecJmJHn1UEmUF3ay)aqAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQFaDsfGHn1UEmUF3ay)aqAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQFaDsfGHn1UEmUF3ay)aqAG4v5s)e5tRGokK4e1VM9tKpTc6OqIdzlKpCHO(b0jvag2u76X4(DdG9daPbIxLl9teorpYJvGeNO(1SFIWj6rEScK4q2c5dxiQFaDsfGHn1n1IdDLexaJRmyahbG93p4jW9pvsYv7No3(jsYY(SsouI6FzQw0z5s)4SI7pq1SkuU0VNqyKzmSP21JX9dUay)aqAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQ)q7hCm4qx3pGoPcWWMAxpg3pvha7hasdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9hA)GJbh66(b0jvag2u76X4(fpa2paKgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6hqNubyytTRhJ73vbW(bG0aXRYL(jsJdBkK4e1VM9tKgh2uiXHSfYhUqu)a6KkadBQBQfh6kjUagxzWaoca7VFWtG7FQKKR2pDU9tewjQ)LPArNLl9JZkU)avZQq5s)EcHrMXWMAxpg3VtaSFainq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1pGoPcWWMAxpg3pvha7hasdeVkx6NOf1y6CjZqItu)A2prlQX05sMHehYwiF4cr9hA)GJbh66(b0jvag2u76X4(fpa2paKgiEvU0prlQX05sMHeNO(1SFIwuJPZLmdjoKTq(WfI6hqNubyytTRhJ73PtaSFainq8QCPFI04WMcjor9Rz)ePXHnfsCiBH8Hle1pGoPcWWMAxpg3Vt3ay)aqAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQFaDsfGHn1UEmUFNGla2paKgiEvU0prACytHeNO(1SFI04WMcjoKTq(WfI6hqNubyytTRhJ73jvha7hasdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9dOBQamSP21JX97KQdG9daPbIxLl9teorpYJvGeNO(1SFIWj6rEScK4q2c5dxiQFaDsfGHn1UEmUFNIha7hasdeVkx6NinoSPqItu)A2prACytHehYwiF4cr9dOtQamSP21JX970vbW(bG0aXRYL(jsJdBkK4e1VM9tKgh2uiXHSfYhUqu)a6MkadBQD9yC)oDvaSFainq8QCPFIwuJPZLmdjor9Rz)eTOgtNlzgsCiBH8Hle1pGoPcWWMAxpg3Vtxfa7hasdeVkx6NiCIEKhRajor9Rz)eHt0J8yfiXHSfYhUqu)a6KkadBQD9yC)ofNay)aqAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQFaDsfGHn1UEmUFNIJay)aqAG4v5s)ePXHnfsCI6xZ(jsJdBkK4q2c5dxiQFaDtfGHn1UEmUFNIJay)aqAG4v5s)eHt0J8yfiXjQFn7NiCIEKhRajoKTq(WfI6hqNubyytTRhJ73n4cG9daPbIxLl9tKgh2uiXjQFn7NinoSPqIdzlKpCHO(b0nvag2u76X4(DdUay)aqAG4v5s)eTOgtNlzgsCI6xZ(jArnMoxYmK4q2c5dxiQFaDsfGHn1UEmUF3Gla2paKgiEvU0pr4e9ipwbsCI6xZ(jcNOh5XkqIdzlKpCHO(b0jvag2u76X4(DlEaSFainq8QCPFIWj6rEScK4e1VM9teorpYJvGehYwiF4cr9dOtQamSPUPwCORK4cyCLbd4iaS)(bpbU)PssUA)052pr6ogfwXe1)YuTOZYL(Xzf3FGQzvOCPFpHWiZyytTRhJ73vbW(bG0aXRYL(RNkaOFSdtdQ0p4C)A2VRrJ(ldObpP1FkH3qZTFajgW9dO4PcWWMAxpg3VRcG9daPbIxLl9tKUJrHvOtiXjQFn7NiDhJcRq1jK4e1pGUDsfGHn1UEmUFxfa7hasdeVkx6NiDhJcRq3qItu)A2pr6ogfwHQBiXjQFaD7QubyytTRhJ7xCcG9daPbIxLl9xpvaq)yhMguPFW5(1SFxJg9xgqdEsR)ucVHMB)asmG7hqXtfGHn1UEmUFXja2paKgiEvU0pr6ogfwHoHeNO(1SFI0DmkScvNqItu)a62vPcWWMAxpg3V4ea7hasdeVkx6NiDhJcRq3qItu)A2pr6ogfwHQBiXjQFaD7KkadBQBQDLRKKRYL(D1(dVoP1)zWkg2uJuJLWEeW4w8uDKAjBsphgP2v4k6NQPyPGRcdtyK0V4QOMYBtTRWv0p4Gy5fnwh972jy73TiD7UPUP2v4k6haiegzgdGn1Ucxr)uv)GHjrNOwPFXfgNhqC)dUFl1(J(RypHWgF)kbU)OusRFFyeJ0Co9xfwqMHn1Ucxr)uv)Ilm2H55s)rPKw)s2j3rD0pPrj0F9uba97kboGRHn1Ucxr)uv)UM1(PA2XoHH7VWyhMVFLapB)aG4aC)4SI1PIXWM6M6WRtAyOKL9zLCOaeiIjNQE4YL(eo4cPXiF1KkJ1uhEDsddLSSpRKdfGarm6dJj43GwBQdVoPHHsw2NvYHcqGiMg7v3qcyhAGwuJPZLmdXj6HoxY8LRK5f3uhEDsddLSSpRKdfGarSsIkF4RgsaRKL9bwV6uXa5uKGDObk86aIVSXvdJf1PGGy(eeBHPqko2jmPIPXHnfckph2rtD41jnmuYY(SsouaceXIPIlxmHub7qdu41beFzJRgg7c4kfqX8ji2ctHuCStysftJdBkeuEoSdbHWRdi(Ygxnm2f3a3uhEDsddLSSpRKdfGarmSYrXXftivWo0afEDaXx24QHXI6wqaqFcITWuifh7eMGGgh2uiO8Cyhaln86aIVSXvdJbYDtDtD41jnmabIy(e1uEVycP2uhEDsddqGiMprnL3lMqQG9mgF9fGaxrc2HgOf1y6CjZqmlHak4e(kzt)jQcDstqaNOh5XkqBCe4RM5bFLKdonbba9PvqhfUmiEXX5M0x6CvuJLk2IAmDUKziMLqafCcFLSP)evHoPbCtTROFWrz)bbok9hwPFWVHr1IoNbCI7hmGdaa9ZgxnmgCW9tI7VKgrA)LSFLWG7No3(LCch8I7xM9bkM7FuIk9lZ9Rz2pwsuv5O)Wk9tI73hgrA)lhL54OFWVHr12pwc7h6X3Vmknng2uhEDsddqGiMUHr1IoNbCAmYxmHub7qdKyASKzfo4RKt4G3M6WRtAyaceX8X5CdVoPDpdwbRfvmq6ogfwXGDObYNGylmfsXXoHj1N5PKKmOUOmMqQWLRIXWs9zEkjjdUmoTqhJ8n2njbxUkgdliiMpbXwykKIJDctQpZtjjzqDrzmHuHlxfJHBQDfUI(fhWNWr)0HFmY97ir3(ljQS2pQPZPFhjA)ecqC)sq1(fxyCAHog5(DL2nj1FjjzGT)C7FO7xjW97Z8ussw)dUFnZ(pPrUFn7VWNWr)0HFmY97ir3(fhKOYkSFxz6(T04(t6(vcmM73Nwz0jnC)XY9hYhUFn7VI1(jnkHX6xjW97uK9JzFAfC)hMjfoaB)kbUF8u1pD4zC)os0TFXbjQS2FGQzvOJpohhWMAxHRO)WRtAyaceXmMeDIAL7Y48aIb7qdeorpYJvGgtIorTYDzCEaXsbugLMgUmoTqhJ8n2njbrLii4Z8ussgCzCAHog5BSBscUCvmgwuNIuqGEitqVlxfJHDXPRcCtD41jnmabIy(4CUHxN0UNbRG1IkgiFb3uhEDsddqGiMpoNB41jT7zWkyTOIbcRGfR74vGCc2HgOWRdi(Ygxnm2fWTPo86KggGarmFCo3WRtA3ZGvWArfdKUJNcMqQyWI1D8kqob7qdu41beFzJRgglQ7M6M6WRtAyOVGbsMxmVugJmyhAGaugLMgQlkJjKkevIuzuAA4Y40cDmY3y3KeevIuFcITWuifh7egWccakJstd1fLXesfIkrQmknnK0CkxSKzhfdrLi1NGylmfAdzc6LoyGfea0NGylmfcInLGJvqWNGylmfASFZtUfGLkJstd1fLXesfIkrqqoXyP0dzc6D5QymSlobxbba9ji2ctHuCStysLrPPHlJtl0XiFJDtsqujsPhYe07YvXyyxeNGlWn1HxN0WqFbdqGiM8jZYLgDDa2HgizuAAOUOmMqQqujcc(mpLKKb1fLXesfUCvmgwuWvKccYjglLEitqVlxfJHDXPR2uhEDsdd9fmabIyH5zSUX56JZbSdnqYO00qDrzmHuHOsee8zEkjjdQlkJjKkC5QymSOGRifeKtmwk9qMGExUkgd7ItxTPo86Kgg6lyaceXONLLpzwa7qdKmknnuxugtiviQebbFMNssYG6IYycPcxUkgdlk4ksbb5eJLspKjO3LRIXWUiUBQdVoPHH(cgGarSZqMGIVIRGwixXMc2HgizuAAOUOmMqQWssYAQdVoPHH(cgGarmjPoPb2HgizuAAOUOmMqQqujsbugLMgkFYSCqXkevIGGglzwHe44OeGs8QlUfjWccYjglLEitqVlxfJHDXTRkiaOpbXwykKIJDctQmknnCzCAHog5BSBscIkrk9qMGExUkgd7I40nWn1n1HxN0WqScew5O44IjKkyhAG04WMcXkhfhx60JILcOKLbDj7lqNqSYrXXftivPYO00qSYrXXLo9Oy4YvXyyxeVGGmknneRCuCCPtpkgwssgWsbugLMgUmoTqhJ8n2njbljjtqqmFcITWuifh7egWn1HxN0WqScqGigL5CUycP2uhEDsddXkabIyLev(WxnKa2Hgia9ji2ctHuCStysb0N5PKKm4Y40cDmY3y3KeC5QymSlK9fGfeeZNGylmfsXXoHjvmFcITWuOnKjOx6Gfe8ji2ctH2qMGEPdwkG(mpLKKbjnNYflz2rXWLRIXWUq2xee8zEkjjdsAoLlwYSJIHlxfJHffCfjWcc0dzc6D5QymSlofpWsbuSnMYLbXMcJsbdzQmyfliSXuUmi2uyukyiQePaUXuUmi2uyuky4yU4uKs3ykxgeBkmkfmC5QymSlGRGWgt5YGytHrPGHJjQpZtjjzccHxhq8LnUAySOobwqqSnMYLbXMcJsbdrLifWnMYLbXMcJsbd9jQPa5uqyJPCzqSPWOuWWXe1N5PKKmGbUPo86KggIvaceXOpXYGDObsJ9QBibIkr6IAmDUKziorp05sMVCLmV4M6WRtAyiwbiqetJ9QBibSdnqlQX05sMH4e9qNlz(YvY8ILQXE1nKaxUkgd7czFrQpZtjjzq6tSmC5QymSlK9LM6WRtAyiwbiqeJPIKtIhq8fti1M6WRtAyiwbiqeJ0CkxSKzhfd2HgiX2ykxgeBkmkfmKPYGvSGGyBmLldInfgLcgIkr6gt5YGytHrPGHf0n0jnaUXuUmi2uyuky4yU4wKccBmLldInfgLcgIkr6gt5YGytHrPGHlxfJHf1P4wqi86aIVSXvdJf1ztD41jnmeRaeiIrFchC5IjKAtD41jnmeRaeiIv4qjC9eckBub2Hgi60JIbOpW6DzYS5cD6rXWQGkn1HxN0WqScqGiwCRq3cV3K(63KeUPo86KggIvaceXifZzmY3y3KeyhAG8zEkjjdUmoTqhJ8n2njbxUkgd7czFrkGIPXHnfYurYjXdi(IjKQGGmknnu(Kz5GIviQeGfeeZNGylmfsXXoHji4Z8ussgCzCAHog5BSBscUCvmgwqqoXyP0dzc6D5QymSlIVPo86KggIvaceXwgNwOJr(g7MKa7qdeGYO00WsIkF4RgsGOsee8zEkjjdwsu5dF1qcC5QymSOofPGGyACytHLev(WxnKiiqpKjO3LRIXWU40nWsbuSnMYLbXMcJsbdzQmyflii2gt5YGytHrPGHOsKc4gt5YGytHrPGHf0n0jnaUXuUmi2uyuky4yU4uKccBmLldInfgLcg6tutbYjWccBmLldInfgLcgIkr6gt5YGytHrPGHlxfJHfvClieEDaXx24QHXI6e4M6WRtAyiwbiqeduEoSdWo0ajJstdxgNwOJr(g7MKGOsee8zEkjjdUmoTqhJ8n2njbxUkgdlQtrkiiMpbXwykKIJDctkGYO00qjl7hmFXesfdljjtqqmnoSPqpHPk4nUycPkieEDaXx24QHXU4g4M6WRtAyiwbiqedRCuCCXesfSdnq(eeBHPqko2jmP0PhfdqFG17YKzZf60JIHvbvKciG(mpLKKbxgNwOJr(g7MKGlxfJHDHSVq1aCLcOy4e9ipwbY00O4beFdBQIB498H3qZvqqmnoSPWsIkF4RgsagybbnoSPWsIkF4RgsK6Z8ussgSKOYh(QHe4YvXyyxaxGBQdVoPHHyfGarmDrzmHub7qdKmknnuYY(bZxmHuXWssYKcOpbXwykeeBkbhRGGpbXwyk0y)MNClccACytH(4CgJ8vjWxmHuXaliiJstdxgNwOJr(g7MKGOsee8zEkjjdUmoTqhJ8n2njbxUkgdlQtrkiiJstdjnNYflz2rXqujccYO00qq55WoGOsKgEDaXx24QHXI6uqqoXyP0dzc6D5QymSlUfFtD41jnmeRaeiITHKPCPNLb7qd0IAmDUKzigDjpg5lMqQyPACytHyD5O6mglfqFMNssYGlJtl0XiFJDtsWLRIXWI6uKccI5tqSfMcP4yNWeeetJdBkSKOYh(QHebbCIEKhRazAAu8aIVHnvXn8E(WBO5cCtD41jnmeRaeiIftfxUycPcwVd)HVASKzfdKtWo0ajJstdLSSFW8ftivmSKKmbbaLrPPH6IYycPcrLiiqJEo3L9eILmF1PIDHSVaqFG1RovmWsbumnoSPqpHPk4nUycPkieEDaXx24QHXU4gybbzuAAOUJNYftivmC5QymSOmvypQYxDQyPHxhq8LnUAySOoBQdVoPHHyfGarSnKmLl9SmyhAGa0N5PKKm4Y40cDmY3y3KeC5QymSOofPGGy(eeBHPqko2jmbbX04WMcljQ8HVAirqaNOh5XkqMMgfpG4BytvCdVNp8gAUalLo9Oya6dSExMmBUqNEumSkOIuaLrPPHLev(WxnKaljjtQmknnKdYhwJtA4RUO8Lo9OyyjjzccACytHyD5O6mgdCtD41jnmeRaeiI5jmvbVXftivWo0ajJstdLSSFW8ftivmevIGaD6rXI6tScWWRtAWyQ4YftivOpXAtD41jnmeRaeiIfRpm(IjKkyhAGKrPPHsw2py(IjKkgIkrqGo9Oyr9jwby41jnymvC5IjKk0NyTPo86KggIvaceXW8kHn9I1XidwVd)HVASKzfdKtWo0aTm9YycH8HLQXsMvOov8vZBzyrlOBOtAn1HxN0WqScqGiMCSBqMb7qdu41beFzJRgglQZM6WRtAyiwbiqeBdjt5spld2Hgia9zEkjjdUmoTqhJ8n2njbxUkgdlQtrkDrnMoxYmeJUKhJ8ftivSGGy(eeBHPqko2jmbbX04WMcljQ8HVAirqaNOh5XkqMMgfpG4BytvCdVNp8gAUalLo9Oya6dSExMmBUqNEumSkOIuaLrPPHLev(WxnKaljjtqqJdBkeRlhvNXyGBQdVoPHHyfGarm5G8nPV6oEkyWo0ajJstd1fLXesfwsswtD41jnmeRaeiIrFymb)g0kyhAGWj6rEScuckwrp8Lxuj6KMuzuAAOUOmMqQWssYAQdVoPHHyfGarmSYrXXfti1M6M6WRtAyOUJNcMqQyGWkhfhxmHub7qdKgh2uiw5O44sNEuS0XU0NHmbvQmknneRCuCCPtpkgUCvmg2fX3uhEDsdd1D8uWesfdqGigL5CUycPc2HgOf1y6CjZqjjQNWnPVBaoL7LEdYvSPyPYO00q6t4Gx8Tkwkqujn1HxN0WqDhpfmHuXaeiIrFchC5IjKkyhAGwuJPZLmdLKOEc3K(Ub4uUx6nixXMIBQdVoPHH6oEkycPIbiqeRKOYh(QHeWo0abOpbXwykKIJDctQpZtjjzWLXPf6yKVXUjj4YvXyyxi7lccI5tqSfMcP4yNWKkMpbXwyk0gYe0lDWcc(eeBHPqBitqV0blfqFMNssYGKMt5ILm7Oy4YvXyyxi7lcc(mpLKKbjnNYflz2rXWLRIXWIcUIeybbnwYSc1PIVAEld7Itrki4Z8ussgCzCAHog5BSBscUCvmgwuNIuA41beFzJRgglk4cSuafBJPCzqSPWOuWqMkdwXccBmLldInfgLcgUCvmgwuXTGGy(eeBHPqko2jmGBQdVoPHH6oEkycPIbiqetJ9QBibSdnqlQX05sMH4e9qNlz(YvY8ILQXE1nKaxUkgd7czFrQpZtjjzq6tSmC5QymSlK9LM6WRtAyOUJNcMqQyaceXOpXYG9mgF9fGClEWo0aPXE1nKarLiDrnMoxYmeNOh6CjZxUsMxCtD41jnmu3XtbtivmabIymvKCs8aIVycP2uhEDsdd1D8uWesfdqGigP5uUyjZokgSdnqITXuUmi2uyukyitLbRybHnMYLbXMcJsbdxUkgdlQtrkieEDaXx24QHXIc0gt5YGytHrPGH(e1uQgUBQdVoPHH6oEkycPIbiqeJumNXiFJDtsGDObYN5PKKm4Y40cDmY3y3KeC5QymSlK9fPakMgh2uitfjNepG4lMqQccYO00q5tMLdkwHOsawqqmFcITWuifh7eMGGpZtjjzWLXPf6yKVXUjj4YvXyyrDksbb5eJLspKjO3LRIXWUi(M6WRtAyOUJNcMqQyaceXwgNwOJr(g7MKa7qdeG(mpLKKbbLNd7aUCvmg2fY(IGGyACytHGYZHDiiOXsMvOov8vZBzyxC6gyPak2gt5YGytHrPGHmvgSIfe2ykxgeBkmkfmC5QymSOIBbHWRdi(YgxnmwuG2ykxgeBkmkfm0NOMs1WnWn1HxN0WqDhpfmHuXaeiIbkph2byhAGKrPPHlJtl0XiFJDtsqujcc(mpLKKbxgNwOJr(g7MKGlxfJHf1PifeeZNGylmfsXXoH1uhEDsdd1D8uWesfdqGiMCSBqMBQdVoPHH6oEkycPIbiqetxugtivWo0ajJstdxgNwOJr(g7MKGOsee8zEkjjdUmoTqhJ8n2njbxUkgdlQtrkiiMpbXwykKIJDctqqoXyP0dzc6D5QymSlUfztD41jnmu3XtbtivmabIyBizkx6zzWo0aTOgtNlzgIrxYJr(IjKkwkG(mpLKKbxgNwOJr(g7MKGlxfJHf1PifeeZNGylmfsXXoHjiiMgh2uyjrLp8vdjalvgLMgQ74PCXesfdxUkgdlkqmvypQYxDQ4M6WRtAyOUJNcMqQyaceXIPIlxmHubR3H)WxnwYSIbYjyhAGKrPPH6oEkxmHuXWLRIXWIcetf2JQ8vNkwkGYO00qjl7hmFXesfdljjtqGg9CUl7jelz(Qtf7IpW6vNkgGK9fbbzuAAOUOmMqQquja3uhEDsdd1D8uWesfdqGiwHdLW1tiOSrfyhAGOtpkgG(aR3LjZMl0PhfdRcQ0uhEDsdd1D8uWesfdqGi2gsMYLEwgSdnqa6Z8ussgCzCAHog5BSBscUCvmgwuNIu6IAmDUKzigDjpg5lMqQybbX8ji2ctHuCStyccITOgtNlzgIrxYJr(IjKkwqqmnoSPWsIkF4RgsawQmknnu3Xt5IjKkgUCvmgwuGyQWEuLV6uXn1HxN0WqDhpfmHuXaeiIvHE0btivWo0ajJstd1D8uUycPIHLKKjiiJstdLSSFW8ftivmevIu60JIf1NyfGHxN0GXuXLlMqQqFIvPakMgh2uONWuf8gxmHufecVoG4lBC1WyrbxGBQdVoPHH6oEkycPIbiqeZtyQcEJlMqQGDObsgLMgkzz)G5lMqQyiQeP0PhflQpXkadVoPbJPIlxmHuH(eRsdVoG4lBC1WyxO6n1HxN0WqDhpfmHuXaeiIrzoNlMqQGDObsgLMgw4OCzhmSKKSM6WRtAyOUJNcMqQyaceXIBf6w49M0x)MKWn1HxN0WqDhpfmHuXaeiIrFchC5IjKAtD41jnmu3XtbtivmabIyyELWMEX6yKbR3H)WxnwYSIbYjyhAGwMEzmHq(Wn1HxN0WqDhpfmHuXaeiIvHE0btivWo0arNEuSO(eRam86KgmMkUCXesf6tSkfqFMNssYGlJtl0XiFJDtsWLRIXWIkEbbX8ji2ctHuCStya3uhEDsdd1D8uWesfdqGiMg7v3qcyhAGwuJPZLmdngJhJmPyDGV6gsKmg5BirsSHIIBQdVoPHH6oEkycPIbiqeJEzgCAmYxDdjGDObArnMoxYm0ymEmYKI1b(QBirYyKVHejXgkkUPo86KggQ74PGjKkgGarm5G8nPV6oEkyWo0ajJstd1fLXesfwsswtD41jnmu3XtbtivmabIy0hgtWVbTc2HgiCIEKhRaLGIv0dF5fvIoPjvgLMgQlkJjKkSKKSM6WRtAyOUJNcMqQyaceXWkhfhxmHuBQBQdVoPHH6ogfwXabk2jKpmyTOIbc7W8xujGfuCqzGKrPPHlJtl0XiFJDtsqujccYO00qDrzmHuHOsAQdVoPHH6ogfwXaeiIbk2jKpmyTOIbcRBAKVyhM)IkbSGIdkdKpbXwykKIJDctQmknnCzCAHog5BSBscIkrQmknnuxugtiviQebbX8ji2ctHuCStysLrPPH6IYycPcrL0uhEDsdd1DmkSIbiqeduStiFyWArfdew30iFXom)D5QymmytjaHzDOblO4GYa5Z8ussgCzCAHog5BSBscUCvmg2fX1(mpLKKb1fLXesfUCvmggSGIdkF5dMbYN5PKKmOUOmMqQWLRIXWGDObsgLMgQlkJjKkSKKmP(eeBHPqko2jSM6WRtAyOUJrHvmabIyGIDc5ddwlQyGW6Mg5l2H5VlxfJHbBkbimRdnybfhugiFMNssYGlJtl0XiFJDtsWLRIXWGfuCq5lFWmq(mpLKKb1fLXesfUCvmggSdnqYO00qDrzmHuHOsK6tqSfMcP4yNWAQdVoPHH6ogfwXaeiIbk2jKpmyTOIbc7W83LRIXWGnLaeM1HgSdnq(eeBHPqko2jmWckoOmq(mpLKKbxgNwOJr(g7MKGlxfJHfvCTpZtjjzqDrzmHuHlxfJHblO4GYx(GzG8zEkjjdQlkJjKkC5QymCtD41jnmu3XOWkgGarmumFhLRWGfFsfdKUJrHvNGDObcqDhJcRqNqcb(II5RmknTGGpbXwykKIJDctQUJrHvOtiHaF9zEkjjdyPack2jKpmeRBAKVyhM)IkrkGI5tqSfMcP4yNWKkMUJrHvOBiHaFrX8vgLMwqWNGylmfsXXoHjvmDhJcRq3qcb(6Z8ussMGGUJrHvOBOpZtjjzWLRIXWcc6ogfwHoHec8ffZxzuAAPakMUJrHvOBiHaFrX8vgLMwqq3XOWk0j0N5PKKmybDdDstuG0DmkScDd9zEkjjdwq3qN0awqq3XOWk0jKqGV(mpLKKjvmDhJcRq3qcb(II5RmknTuDhJcRqNqFMNssYGf0n0jnrbs3XOWk0n0N5PKKmybDdDsdybbXaf7eYhgI1nnYxSdZFrLifqX0DmkScDdje4lkMVYO00sbu3XOWk0j0N5PKKmybDdDsJQeVlGIDc5ddXom)D5QymSGaOyNq(WqSdZFxUkgdlQUJrHvOtOpZtjjzWc6g6Kg4SBGfe0DmkScDdje4lkMVYO00sbu3XOWk0jKqGVOy(kJstlv3XOWk0j0N5PKKmybDdDstuG0DmkScDd9zEkjjdwq3qN0KcOUJrHvOtOpZtjjzWc6g6KgvjExaf7eYhgIDy(7YvXyybbqXoH8HHyhM)UCvmgwuDhJcRqNqFMNssYGf0n0jnWz3aliaOy6ogfwHoHec8ffZxzuAAbbDhJcRq3qFMNssYGf0n0jnrbs3XOWk0j0N5PKKmybDdDsdyPaQ7yuyf6g6Z8ussgC5O4qQUJrHvOBOpZtjjzWc6g6KgvjErbf7eYhgIDy(7YvXyyPGIDc5ddXom)D5QymSl6ogfwHUH(mpLKKblOBOtAGZUfeet3XOWk0n0N5PKKm4YrXHua1DmkScDd9zEkjjdUCvmgMQeVlGIDc5ddX6Mg5l2H5VlxfJHLck2jKpmeRBAKVyhM)UCvmgwu3IukG6ogfwHoH(mpLKKblOBOtAuL4DbuStiFyi2H5VlxfJHfe0DmkScDd9zEkjjdUCvmgMQeVlGIDc5ddXom)D5QymSuDhJcRq3qFMNssYGf0n0jnQYPibiOyNq(WqSdZFxUkgd7cOyNq(WqSUPr(IDy(7YvXyybbqXoH8HHyhM)UCvmgwuDhJcRqNqFMNssYGf0n0jnWz3ccGIDc5ddXom)fvcWcc6ogfwHUH(mpLKKbxUkgdtvIxuqXoH8HHyDtJ8f7W83LRIXWsbu3XOWk0j0N5PKKmybDdDsJQeVlGIDc5ddX6Mg5l2H5VlxfJHfeet3XOWk0jKqGVOy(kJstlfqqXoH8HHyhM)UCvmgwuDhJcRqNqFMNssYGf0n0jnWz3ccGIDc5ddXom)fvcWadmWadSGGCIXsPhYe07YvXyyxaf7eYhgIDy(7YvXyyGfeet3XOWk0jKqGVOy(kJstlvmFcITWuifh7eMua1DmkScDdje4lkMVYO00sbeqXaf7eYhgIDy(lQebbDhJcRq3qFMNssYGlxfJHfv8alfqqXoH8HHyhM)UCvmgwu3Iuqq3XOWk0n0N5PKKm4YvXyyQs8Ick2jKpme7W83LRIXWadSGGy6ogfwHUHec8ffZxzuAAPakMUJrHvOBiHaF9zEkjjtqq3XOWk0n0N5PKKm4YvXyybbDhJcRq3qFMNssYGf0n0jnrbs3XOWk0j0N5PKKmybDdDsdyGBQdVoPHH6ogfwXaeiIHI57OCfgS4tQyG0DmkS6gSdnqaQ7yuyf6gsiWxumFLrPPfe8ji2ctHuCStys1DmkScDdje4RpZtjjzalfqqXoH8HHyDtJ8f7W8xujsbumFcITWuifh7eMuX0DmkScDcje4lkMVYO00cc(eeBHPqko2jmPIP7yuyf6esiWxFMNssYee0DmkScDc9zEkjjdUCvmgwqq3XOWk0nKqGVOy(kJstlfqX0DmkScDcje4lkMVYO00cc6ogfwHUH(mpLKKblOBOtAIcKUJrHvOtOpZtjjzWc6g6KgWcc6ogfwHUHec81N5PKKmPIP7yuyf6esiWxumFLrPPLQ7yuyf6g6Z8ussgSGUHoPjkq6ogfwHoH(mpLKKblOBOtAaliigOyNq(WqSUPr(IDy(lQePakMUJrHvOtiHaFrX8vgLMwkG6ogfwHUH(mpLKKblOBOtAuL4DbuStiFyi2H5VlxfJHfeaf7eYhgIDy(7YvXyyr1DmkScDd9zEkjjdwq3qN0aNDdSGGUJrHvOtiHaFrX8vgLMwkG6ogfwHUHec8ffZxzuAAP6ogfwHUH(mpLKKblOBOtAIcKUJrHvOtOpZtjjzWc6g6KMua1DmkScDd9zEkjjdwq3qN0OkX7cOyNq(WqSdZFxUkgdliak2jKpme7W83LRIXWIQ7yuyf6g6Z8ussgSGUHoPbo7gybbaft3XOWk0nKqGVOy(kJstliO7yuyf6e6Z8ussgSGUHoPjkq6ogfwHUH(mpLKKblOBOtAalfqDhJcRqNqFMNssYGlhfhs1DmkScDc9zEkjjdwq3qN0OkXlkOyNq(WqSdZFxUkgdlfuStiFyi2H5VlxfJHDr3XOWk0j0N5PKKmybDdDsdC2TGGy6ogfwHoH(mpLKKbxokoKcOUJrHvOtOpZtjjzWLRIXWuL4DbuStiFyiw30iFXom)D5QymSuqXoH8HHyDtJ8f7W83LRIXWI6wKsbu3XOWk0n0N5PKKmybDdDsJQeVlGIDc5ddXom)D5QymSGGUJrHvOtOpZtjjzWLRIXWuL4DbuStiFyi2H5VlxfJHLQ7yuyf6e6Z8ussgSGUHoPrvofjabf7eYhgIDy(7YvXyyxaf7eYhgI1nnYxSdZFxUkgdliak2jKpme7W83LRIXWIQ7yuyf6g6Z8ussgSGUHoPbo7wqauStiFyi2H5VOsawqq3XOWk0j0N5PKKm4YvXyyQs8Ick2jKpmeRBAKVyhM)UCvmgwkG6ogfwHUH(mpLKKblOBOtAuL4DbuStiFyiw30iFXom)D5QymSGGy6ogfwHUHec8ffZxzuAAPack2jKpme7W83LRIXWIQ7yuyf6g6Z8ussgSGUHoPbo7wqauStiFyi2H5VOsagyGbgyGfeKtmwk9qMGExUkgd7cOyNq(WqSdZFxUkgddSGGy6ogfwHUHec8ffZxzuAAPI5tqSfMcP4yNWKcOUJrHvOtiHaFrX8vgLMwkGakgOyNq(WqSdZFrLiiO7yuyf6e6Z8ussgC5QymSOIhyPack2jKpme7W83LRIXWI6wKcc6ogfwHoH(mpLKKbxUkgdtvIxuqXoH8HHyhM)UCvmggyGfeet3XOWk0jKqGVOy(kJstlfqX0DmkScDcje4RpZtjjzcc6ogfwHoH(mpLKKbxUkgdliO7yuyf6e6Z8ussgSGUHoPjkq6ogfwHUH(mpLKKblOBOtAadmIIOiia]] )


end