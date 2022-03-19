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
                return state.buff.death_chakram.applied + floor( ( state.query_time - state.buff.death_chakram.applied ) / class.auras.death_chakram.tick_time ) * class.auras.death_chakram.tick_time
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
            return state.debuff.tar_trap[ k ]
        end
    } ) )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364491, "tier28_4pc", 363666 )
    -- 2-Set - Focused Trickery - Trick Shots now also increases the damage of the affected shot by 30%.
    -- 4-Set - Focused Trickery - Spending 40 Focus grants you 1 charge of Trick Shots.

    local focusSpent = 0

    local FOCUS = Enum.PowerType.Focus
    local lastFocus = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "FOCUS" and state.set_bonus.tier28_4pc > 0 then
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


    spec:RegisterPack( "Marksmanship", 20220317, [[d8eqzcqiIKhrvkCjaLQnriFcsAuQqNsfSkaLGxbinleHBHKODb6xisggskhJQYYOQ6zijmnQsPRHKQTbi03iuKXrOGZrvkADakEhGsOMhvj3dsSpIu)dqGCqabzHek9qarteqaUiGsYhbusnsabKtciOwjHQxcOeYmPkv3KqH0obu9taLOHciqTucfQNcWure9vcfIXIi1Er4VsAWQ6WclMOEmvMSexg1MrQpdPgneoTIvdiG61iXSvPBRI2nLFlA4eXXjuulxPNd10jDDG2oe9De14rs68ufRhqPmFc2Vut4JGKeakHYea3p187NAuHpXa0pvqnXG36TeaupsycaschLantaWItMaGy0yPGpddJyKqaqs45MrHGKeaWj46ycaEJ(rOQemWqksHEueGYqxEsk8CcEdDsZTbTsk8C6ifbazW5QaHnczcaLqzcG7NA(9tnQWNya6NkOMyWB9taiave5saaWCcKeaqmLcBeYeakm2raqmASuWNHHrms6hiqGMYBlUy0yDi63NyIe97NA(93I3IdKicdnJbMwCQSFGZKPtqR0VymJZlsU)b3VLA)r)NSdryJRFfb3FukP1VlmsrEU3(pdlqZWwCQSFXyg7XCCP)OusRFj7K7OE6N8Oi6hWCcK9deciyVdBXPY(9oR9dSip7egU)cJ9yU(ve8S9dKabG7hNNSoNmgsa4oyftqsca6ookyePIjijbW9rqscaSfYxUqiwcaUDuENGaGgx2uiw5O4PsNoqmKTq(YL(f1)yv67GgH2VO(LbPPHyLJINkD6aXWLpJXW97v)uNaq40jncayLJINkgrQekbW9tqscaSfYxUqiwcaUDuENGaWcAmDUOzOKe0HOM01na2YTsVb6t2umKTq(YL(f1VminnK(gE4fxpJLceucbGWPtAeaOm3BfJivcLa4ubbjjaWwiF5cHyja42r5DccalOX05IMHssqhIAsx3ayl3k9gOpztXq2c5lxiaeoDsJaa9n8WLkgrQekbW9wcssaGTq(YfcXsaWTJY7eeao2VlrYwykKINDcRFr97Y8wsYgCzCAHog6ASBsgU8zmgUFV6hTR0VGq)s1VlrYwykKINDcRFr9lv)UejBHPqBqJqR0b3VGq)UejBHPqBqJqR0b3VO(p2VlZBjjBqYZTuXsMDumC5ZymC)E1pAxPFbH(DzEljzdsEULkwYSJIHlFgJH7x6(PcQ1)H(fe6xJfnRqDo5QM1YW97v)(Ow)cc97Y8wsYgCzCAHog6ASBsgU8zmgUFP73h16xu)HthKCLn(CyC)s3pv0)H(f1)X(LQ)nMsLrYMcJsbdzQoyf3VGq)BmLkJKnfgLcgU8zmgUFP73B2VGq)s1VlrYwykKINDcR)deacNoPraOKGYxUQHecLa4uNGKeaylKVCHqSeaC7O8obbGf0y6CrZqCcEPZfnx5tzEXq2c5lx6xu)ASvDdjWLpJXW97v)ODL(f1VlZBjjBq6BSmC5ZymC)E1pAxHaq40jncaASvDdjekbWbIeKKaaBH8LleILaq40jnca03yzcaUDuENGaGgBv3qceus)I6FbnMox0meNGx6CrZv(uMxmKTq(Yfca3X4QRqaWp1jucGlMiijbGWPtAeayQk5M4bjxXisLaaBH8LleILqjaUyGGKeacNoPraG8ClvSKzhftaGTq(YfcXsOea3BsqscaSfYxUqiwcaUDuENGaGlZBjjBWLXPf6yORXUjz4YNXy4(9QF0Us)I6)y)s1Vgx2uitvj3epi5kgrQq2c5lx6xqOFzqAAO8nZYfeRqqj9FOFbH(LQFxIKTWuifp7ew)cc97Y8wsYgCzCAHog6ASBsgU8zmgUFP73h16xqOF5eJ7xu)0dAeAD5ZymC)E1p1jaeoDsJaa5yUJHUg7MKjucG7JAeKKaaBH8LleILaGBhL3jiaCSFxM3ss2GiZ7L9ax(mgd3Vx9J2v6xqOFP6xJlBkezEVShiBH8Ll9li0VglAwH6CYvnRLH73R(95V)d9lQ)J9lv)BmLkJKnfgLcgYuDWkUFbH(3ykvgjBkmkfmC5ZymC)s3V3SFbH(dNoi5kB85W4(LgL(3ykvgjBkmkfm0LGM2pWc97V)deacNoPrayzCAHog6ASBsMqjaUpFeKKaaBH8LleILaGBhL3jiaidstdxgNwOJHUg7MKHGs6xqOFP63LizlmfsXZoHraiC6KgbaK59YEiucG7ZpbjjaeoDsJaGCSBGMjaWwiF5cHyjucG7Jkiijba2c5lxielba3okVtqaWLizlmfsXZoH1VO(p2VminnCzCAHog6ASBsgckPFbH(DzEljzdUmoTqhdDn2njdx(mgd3V097JA9FOFbH(Djs2ctH2GgHwPdUFr9ldstdjp3sflz2rXqqj9li0VlrYwykejBkcpB)cc97sKSfMcn2T5n3s)cc9lNyC)I6NEqJqRlFgJH73R(9tDcaHtN0iaOliJrKkHsaCFElbjjaWwiF5cHyja42r5DccalOX05IMHyWf9yORyePIHSfYxU0VO(p2VlZBjjBWLXPf6yORXUjz4YNXy4(LUFFuRFbH(LQFxIKTWuifp7ew)cc9lv)ACztHLeu(YvnKazlKVCP)d9lQFzqAAOUJJsfJivmC5ZymC)sJs)mvzhOYvDozcaHtN0iaSHKPuPNLjucG7J6eKKaaBH8LleILaq40jncaXCYLkgrQeaC7O8obbGJ9ldstd1DCuQyePIHlFgJH7xAu6NPk7avUQZj3VGq)0PdeZLQUJJcVEQUe00(LUFQ1)H(f1)X(LbPPHsw2nyUIrKkgwsYw)cc9tdEV1LDiIfnx15K73R(DbwR6CY9d0(r7k9li0VminnuxqgJiviOK(fe6hZAvonqmuhE9lgQERex)I6FbnMox0meZULvCnPRkcUcAY3XOmg6kYb9CHSfYxU0)bcaopUlx1yrZkMa4(iucG7disqscaSfYxUqiwcaUDuENGaaD6aX9d0(DbwRlJMT(9QF60bIHNbvjaeoDsJaqHdfr1HiOSXjHsaCFIjcssaGTq(YfcXsaWTJY7eeao2VlZBjjBWLXPf6yORXUjz4YNXy4(LUFFuRFr9VGgtNlAgIbx0JHUIrKkgYwiF5s)cc9lv)UejBHPqkE2jS(fe6xQ(xqJPZfndXGl6XqxXisfdzlKVCPFbH(LQFnUSPWsckF5QgsGSfYxU0)H(f1Vminnu3XrPIrKkgU8zmgUFPrPFMQSdu5QoNmbGWPtAea2qYuQ0ZYekbW9jgiijba2c5lxielba3okVtqaqgKMgQ74OuXisfdljzRFbH(LbPPHsw2nyUIrKkgckPFr9tNoqC)s3VlXA)aT)WPtAWyo5sfJivOlXA)I6)y)s1Vgx2uOdXCg8gvmIuHSfYxU0VGq)HthKCLn(CyC)s3pv0)bcaHtN0iaCcE1bJivcLa4(8MeKKaaBH8LleILaGBhL3jiaidstdLSSBWCfJivmeus)I6NoDG4(LUFxI1(bA)HtN0GXCYLkgrQqxI1(f1F40bjxzJphg3Vx97TeacNoPraWHyodEJkgrQekbW9tncssaGTq(YfcXsaWTJY7eeaKbPPHfokv2ddljzJaq40jncauM7TIrKkHsaC)(iijbGWPtAeaI6j4w4TM0v3MKXeaylKVCHqSekbW97NGKeacNoPraG(gE4sfJivcaSfYxUqiwcLa4(PccssaGTq(YfcXsaiC6KgbamVsytRyDm0eaC7O8obbGLPxgJiKVmbaNh3LRASOzftaCFekbW97TeKKaaBH8LleILaGBhL3jiaqNoqC)s3VlXA)aT)WPtAWyo5sfJivOlXA)I6)y)UmVLKSbxgNwOJHUg7MKHlFgJH7x6(PE)cc9lv)UejBHPqkE2jS(pqaiC6KgbGtWRoyePsOea3p1jijba2c5lxielba3okVtqaybnMox0m0ymEm0KJ1dUQBirYyORHejXgkigYwiF5cbGWPtAea0yR6gsiucG7hisqscaSfYxUqiwcaUDuENGaWcAmDUOzOXy8yOjhRhCv3qIKXqxdjsInuqmKTq(YfcaHtN0iaqVmdSng6QUHecLa4(fteKKaaBH8LleILaGBhL3jiaidstd1fKXisfwsYgbGWPtAeaKd01KUQ74OGjucG7xmqqscaSfYxUqiwcaUDuENGaaobVYJvGsaXk4LR8ckrN0GSfYxU0VO(LbPPH6cYyePcljzJaq40jnca0xgJWTbTsOea3V3KGKeacNoPraaRCu8uXisLaaBH8LleILqjucafMoaVkbjjaUpcssaiC6KgbaxcAkVvmIujaWwiF5cHyjucG7NGKeaylKVCHqSeacNoPraWLGMYBfJivcaUDuENGaWcAmDUOziMLGaeydxLSP7gNHoPbzlKVCPFbH(Xj4vESc0gpbUQzEXvj5GtdYwiF5s)cc9FSFxAfWrHlJKxCCRjDLoxf0yiBH8Ll9lQFP6FbnMox0meZsqacSHRs20DJZqN0GSfYxU0)bca3X4QRqaGkOgHsaCQGGKeaylKVCHqSeacNoPraq3WeZGZDa2gdDfJivcafg72rIoPraayD2FGGJs)Hv6NKByIzW5oaBC)ahiyGSF24ZHXKOFYC)L0qv7VK9RigC)052VKB4HxC)YSlaXC)JIAPFzUFnZ(XsIZtp9hwPFYC)UWqv7F5Omxp9tYnmXC)yjSBOhx)YG00yiba3okVtqaqQ(1yrZkCWvj3WdVekbW9wcssaGTq(YfcXsaWTJY7eeaCjs2ctHu8Sty9lQFxM3ss2G6cYyePcx(mgd3VO(DzEljzdUmoTqhdDn2njdx(mgd3VGq)s1VlrYwykKINDcRFr97Y8wsYguxqgJiv4YNXyycaHtN0ia4I7TgoDsREhSsa4oyTAXjtaq3XOWkMqjao1jijba2c5lxielbGWPtAeaCX9wdNoPvVdwjaChSwT4Kja4kycLa4arcssaGTq(YfcXsaWTJY7eeacNoi5kB85W4(9QFQGaaw3XPea3hbGWPtAeaCX9wdNoPvVdwjaChSwT4KjaGvcLa4IjcssaGTq(YfcXsaWTJY7eeacNoi5kB85W4(LUF)eaW6ooLa4(iaeoDsJaGlU3A40jT6DWkbG7G1QfNmbaDhhfmIuXekHsaqYYU8uoucssaCFeKKaq40jncaYPQxUuPVHhUqEm0vnP6yeaylKVCHqSekbW9tqscaHtN0iaqFzmc3g0kba2c5lxielHsaCQGGKeaylKVCHqSeaC7O8obbGf0y6CrZqCcEPZfnx5tzEXq2c5lxiaeoDsJaGgBv3qcHsaCVLGKeaylKVCHqSeaKSSlWAvNtMaGpQraiC6KgbGsckF5Qgsia42r5DccaHthKCLn(CyC)s3VV(fe6xQ(Djs2ctHu8Sty9lQFP6xJlBkezEVShiBH8LlekbWPobjjaWwiF5cHyja42r5DccaHthKCLn(CyC)E1pv0VO(p2Vu97sKSfMcP4zNW6xu)s1Vgx2uiY8Ezpq2c5lx6xqO)WPdsUYgFomUFV63F)hiaeoDsJaqmNCPIrKkHsaCGibjjaWwiF5cHyja42r5DccaHthKCLn(CyC)s3V)(fe6)y)UejBHPqkE2jS(fe6xJlBkezEVShiBH8Ll9FOFr9hoDqYv24ZHX9Js)(jaeoDsJaaw5O4PIrKkHsOeaCfmbjjaUpcssaGTq(YfcXsaWTJY7eeao2VminnuxqgJiviOK(f1VminnCzCAHog6ASBsgckPFr97sKSfMcP4zNW6)q)cc9FSFzqAAOUGmgrQqqj9lQFzqAAi55wQyjZokgckPFr97sKSfMcTbncTshC)h6xqO)J97sKSfMcrYMIWZ2VGq)UejBHPqJDBEZT0)H(f1VminnuxqgJiviOK(fe6xoX4(f1p9GgHwx(mgd3Vx97Jk6xqO)J97sKSfMcP4zNW6xu)YG00WLXPf6yORXUjziOK(f1p9GgHwx(mgd3Vx9lMOI(pqaiC6KgbazEX8szm0ekbW9tqscaSfYxUqiwcaUDuENGaGminnuxqgJiviOK(fe63L5TKKnOUGmgrQWLpJXW9lD)ub16xqOF5eJ7xu)0dAeAD5ZymC)E1VpGibGWPtAeaKVzwQ0GRhcLa4ubbjjaWwiF5cHyja42r5DccaYG00qDbzmIuHGs6xqOFxM3ss2G6cYyePcx(mgd3V09tfuRFbH(LtmUFr9tpOrO1LpJXW97v)(aIeacNoPraimhJ1nUvxCVekbW9wcssaGTq(YfcXsaWTJY7eeaKbPPH6cYyePcbL0VGq)UmVLKSb1fKXisfU8zmgUFP7NkOw)cc9lNyC)I6NEqJqRlFgJH73R(9MeacNoPraGEww(MzHqjao1jijba2c5lxielba3okVtqaqgKMgQliJrKkSKKncaHtN0iaCh0iuCfiWGf0NSPekbWbIeKKaaBH8LleILaGBhL3jiaidstd1fKXisfckPFr9FSFzqAAO8nZYfeRqqj9li0VglAwHi44QiGsCA)E1VFQ1)H(fe6xoX4(f1p9GgHwx(mgd3Vx97hi2VGq)h73LizlmfsXZoH1VO(LbPPHlJtl0XqxJDtYqqj9lQF6bncTU8zmgUFV6xm5V)deacNoPraqsQtAekHsaaReKKa4(iijba2c5lxielba3okVtqaqJlBkeRCu8uPthigYwiF5s)I6)y)swgzfTRa9bXkhfpvmIu7xu)YG00qSYrXtLoDGy4YNXy4(9QFQ3VGq)YG00qSYrXtLoDGyyjjB9FOFr9FSFzqAA4Y40cDm01y3KmSKKT(fe6xQ(Djs2ctHu8Sty9FGaq40jncayLJINkgrQekbW9tqscaHtN0iaqzU3kgrQeaylKVCHqSekbWPccssaGTq(YfcXsaWTJY7eeao2VlrYwykKINDcRFr9FSFxM3ss2GlJtl0XqxJDtYWLpJXW97v)ODL(p0VGq)s1VlrYwykKINDcRFr9lv)UejBHPqBqJqR0b3VGq)UejBHPqBqJqR0b3VO(p2VlZBjjBqYZTuXsMDumC5ZymC)E1pAxPFbH(DzEljzdsEULkwYSJIHlFgJH7x6(PcQ1)H(fe6xoX4(f1p9GgHwx(mgd3Vx97J69FOFr9FSFP6FJPuzKSPWOuWqMQdwX9li0)gtPYiztHrPGHGs6)abGWPtAeakjO8LRAiHqjaU3sqscaSfYxUqiwcaUDuENGaGgBv3qceus)I6FbnMox0meNGx6CrZv(uMxmKTq(YfcaHtN0iaqFJLjucGtDcssaGTq(YfcXsaWTJY7eeawqJPZfndXj4Lox0CLpL5fdzlKVCPFr9RXw1nKax(mgd3Vx9J2v6xu)UmVLKSbPVXYWLpJXW97v)ODfcaHtN0iaOXw1nKqOeahisqscaHtN0iaWuvYnXdsUIrKkba2c5lxielHsaCXebjjaWwiF5cHyja42r5Dccah73L5TKKnOUGmgrQWLpJXW97v)ODL(fe6xgKMgQliJrKkeus)h6xu)h7xQ(3ykvgjBkmkfmKP6GvC)cc9lv)BmLkJKnfgLcgckPFr9FS)nMsLrYMcJsbdlGBOtA9d0(3ykvgjBkmkfmCS(9QF)uRFbH(3ykvgjBkmkfmCS(LUFGi16)q)cc9VXuQms2uyukyiOK(f1)gtPYiztHrPGHlFgJH7x6(95n7xqO)WPdsUYgFomUFP73x)h6xqOF5eJ7xu)0dAeAD5ZymC)E1VFQraiC6KgbaYZTuXsMDumHsaCXabjjaeoDsJaa9n8WLkgrQeaylKVCHqSekbW9MeKKaaBH8LleILaGBhL3jiaqNoqC)aTFxG16YOzRFV6NoDGy4zqvcaHtN0iau4qruDickBCsOea3h1iijbGWPtAeaI6j4w4TM0v3MKXeaylKVCHqSekbW95JGKeaylKVCHqSeaC7O8obbaxM3ss2GlJtl0XqxJDtYWLpJXW97v)ODL(f1)X(LQFnUSPqMQsUjEqYvmIuHSfYxU0VGq)YG00q5BMLliwHGs6)q)cc9lv)UejBHPqkE2jS(fe63L5TKKn4Y40cDm01y3KmC5ZymC)cc9lNyC)I6NEqJqRlFgJH73R(PobGWPtAeaihZDm01y3KmHsaCF(jijba2c5lxielba3okVtqa4y)YG00WsckF5QgsGGs6xqOFP6xJlBkSKGYxUQHeiBH8Ll9li0VCIX9lQF6bncTU8zmgUFV63N)(p0VO(p2Vu9VXuQms2uyukyit1bR4(fe6xQ(3ykvgjBkmkfmeus)I6)y)BmLkJKnfgLcgwa3qN06hO9VXuQms2uyuky4y97v)(Ow)cc9VXuQms2uyuky4y9lD)El16xqO)nMsLrYMcJsbdDjOP9Js)(6)q)cc9VXuQms2uyukyiOK(f1)gtPYiztHrPGHlFgJH7x6(9M9li0F40bjxzJphg3V097R)deacNoPrayzCAHog6ASBsMqjaUpQGGKeaylKVCHqSeaC7O8obbazqAA4Y40cDm01y3Kmeus)cc9lv)UejBHPqkE2jS(f1)X(LbPPHsw2nyUIrKkgwsYw)cc9lv)ACztHoeZzWBuXisfYwiF5s)cc9hoDqYv24ZHX97v)(7)abGWPtAeaqM3l7HqjaUpVLGKeaylKVCHqSeaC7O8obbaxIKTWuifp7ew)I6NoDG4(bA)UaR1LrZw)E1pD6aXWZGQ9lQ)J9FSFxM3ss2GlJtl0XqxJDtYWLpJXW97v)ODL(bwOFQOFr9FSFP6hNGx5XkqMMgepi5AyZzudNJV8gAUq2c5lx6xqOFP6xJlBkSKGYxUQHeiBH8Ll9FO)d9li0Vgx2uyjbLVCvdjq2c5lx6xu)UmVLKSbljO8LRAibU8zmgUFV6Nk6)abGWPtAeaWkhfpvmIujucG7J6eKKaaBH8LleILaGBhL3jiaSGgtNlAgIbx0JHUIrKkgYwiF5s)I6xJlBkeRlhN3XyiBH8Ll9lQ)J97Y8wsYgCzCAHog6ASBsgU8zmgUFP73h16xqOFP63LizlmfsXZoH1VGq)s1Vgx2uyjbLVCvdjq2c5lx6xqOFCcELhRazAAq8GKRHnNrnCo(YBO5czlKVCP)deacNoPraydjtPspltOea3hqKGKeaylKVCHqSeaC7O8obbamRv50aXqD41VyO6TsC9lQFzqAAOUJJsfJivmSKKT(f1pD6aXCPQ74OWRNQlbnTFV6N69lQFzqAAOKLDdMRyePIHGsiaeoDsJaGdXCg8gvmIujucG7tmrqscaSfYxUqiwcaUDuENGaaM1QCAGyOo86xmu9wjU(f1Vminnu3XrPIrKkgwsYw)I6NoDGyUu1DCu41t1LGM2Vx9t9(f1VminnuYYUbZvmIuXqqjeacNoPraiwxyCfJivcLa4(edeKKaaBH8LleILaGBhL3jiaCS)J97sKSfMcrYMIWZ2VO(p2VminnuYYUbZvmIuXWss26xqOFmRv50aXqD41VyO6TsC9lQ)f0y6CrZqm7wwX1KUQi4kOjFhJYyORih0ZfYwiF5s)cc9RXLnf6I7Dm0vfbxXisfdzlKVCP)d9li0VlrYwyk0y3M3Cl9li0VlrYwykKINDcRFr9FSFxM3ss2GlJtl0XqxJDtYWLpJXW9lD)ub16xqOFxM3ss2GlJtl0XqxJDtYWLpJXW97v)(Ow)h6xqOFxIKTWuOnOrOv6G7xu)h73L5TKKni55wQyjZokgU8zmgUFP7NkOw)cc9ldstdjp3sflz2rXqqj9FO)d9li0VminnezEVShiOK(f1F40bjxzJphg3V097R)d9lQ)J9lv)BmLkJKnfgLcgYuDWkUFbH(LQ)nMsLrYMcJsbdbL0VO(p2)gtPYiztHrPGHfWn0jT(bA)BmLkJKnfgLcgow)E1VFQ3VGq)BmLkJKnfgLcgow)s3pqKA9FOFbH(3ykvgjBkmkfmeus)I6FJPuzKSPWOuWWLpJXW9lD)(Ow)cc9hoDqYv24ZHX9lD)(6)q)cc9lNyC)I6NEqJqRlFgJH73R(9tDcaHtN0iaOliJrKkHsaCFEtcssaGTq(YfcXsaiC6KgbGyo5sfJivcaUDuENGaGminnuYYUbZvmIuXWss26xqO)J9ldstd1fKXisfckPFbH(PbV36YoeXIMR6CY97v)ODL(bA)UaRvDo5(fe6hZAvonqmuhE9lgQERex)I6FbnMox0meZULvCnPRkcUcAY3XOmg6kYb9CHSfYxU0)H(f1)X(LQFnUSPqhI5m4nQyePczlKVCPFbH(dNoi5kB85W4(9QF)9FOFbH(p2Vminnu3XrPIrKkgU8zmgUFP7NPk7avUQZj3VGq)0PdeZLQUJJcVEQUe00(LUFQ1)H(f1F40bjxzJphg3V097JaGZJ7Yvnw0SIjaUpcLa4(PgbjjaWwiF5cHyja42r5Dccah73L5TKKn4Y40cDm01y3KmC5ZymC)s3VpQ1VGq)s1VlrYwykKINDcRFbH(LQFnUSPWsckF5QgsGSfYxU0VGq)4e8kpwbY00G4bjxdBoJA4C8L3qZfYwiF5s)h6xu)0Pde3pq73fyTUmA263R(PthigEguTFr9FSFzqAAyjbLVCvdjWss26xu)YG00qoqFznUPHR6cYv60bIHLKS1VGq)ACztHyD548ogdzlKVCP)deacNoPraydjtPspltOea3VpcssaGTq(YfcXsaWTJY7eeaKbPPHsw2nyUIrKkgckPFbH(PthiUFP73LyTFG2F40jnymNCPIrKk0LyLaq40jncaoeZzWBuXisLqjaUF)eKKaaBH8LleILaGBhL3jiaidstdLSSBWCfJivmeus)cc9tNoqC)s3VlXA)aT)WPtAWyo5sfJivOlXkbGWPtAeaI1fgxXisLqjaUFQGGKeaylKVCHqSeacNoPraaZRe20kwhdnba3okVtqayz6LXic5l3VO(1yrZkuNtUQzTmC)s3FbCdDsJaGZJ7Yvnw0SIjaUpcLa4(9wcssaGTq(YfcXsaWTJY7eeacNoi5kB85W4(LUFFeacNoPraqo2nqZekbW9tDcssaGTq(YfcXsaWTJY7eeao2VlZBjjBWLXPf6yORXUjz4YNXy4(LUFFuRFr9VGgtNlAgIbx0JHUIrKkgYwiF5s)cc9lv)UejBHPqkE2jS(fe6xQ(14YMcljO8LRAibYwiF5s)cc9JtWR8yfittdIhKCnS5mQHZXxEdnxiBH8Ll9FOFr9tNoqC)aTFxG16YOzRFV6NoDGy4zq1(f1)X(LbPPHLeu(YvnKaljzRFbH(14YMcX6YX5DmgYwiF5s)hiaeoDsJaWgsMsLEwMqjaUFGibjjaWwiF5cHyja42r5DccaYG00qDbzmIuHLKSraiC6Kgba5aDnPR6ookycLa4(fteKKaaBH8LleILaGBhL3jiaGtWR8yfOeqScE5kVGs0jniBH8Ll9lQFzqAAOUGmgrQWss2iaeoDsJaa9LXiCBqRekbW9lgiijbGWPtAeaWkhfpvmIujaWwiF5cHyjucLaGUJrHvmbjjaUpcssaGTq(YfcXsaiLqaaZkbGWPtAeaqg7eYxMaaY4cYeaKbPPHlJtl0XqxJDtYqqj9li0VminnuxqgJiviOecaiJTAXjtaa7XCvqjekbW9tqscaSfYxUqiwcaPecaywjaeoDsJaaYyNq(YeaqgxqMaGlrYwykKINDcRFr9ldstdxgNwOJHUg7MKHGs6xu)YG00qDbzmIuHGs6xqOFP63LizlmfsXZoH1VO(LbPPH6cYyePcbLqaazSvlozcayDtdDf7XCvqjekbWPccssaGTq(YfcXsaiLqaaZ6qtaiC6KgbaKXoH8LjaGm2QfNmbaSUPHUI9yU6YNXyycaUDuENGaGminnuxqgJivyjjBeaqgxqUYxmtaWL5TKKnOUGmgrQWLpJXWv0GmgtaazCbzcaUmVLKSbxgNwOJHUg7MKHlFgJH73lGG63L5TKKnOUGmgrQWLpJXWv0GmgtOea3Bjijba2c5lxielbGucbamRdnbGWPtAeaqg7eYxMaaYyRwCYeaW6Mg6k2J5QlFgJHja42r5DccaYG00qDbzmIuHGsiaGmUGCLVyMaGlZBjjBqDbzmIuHlFgJHRObzmMaaY4cYeaCzEljzdUmoTqhdDn2njdx(mgdtOeaN6eKKaaBH8LleILaqkHaaM1HMaq40jncaiJDc5ltaazSvlozcaypMRU8zmgMaGBhL3jia4sKSfMcP4zNWiaGmUGCLVyMaGlZBjjBqDbzmIuHlFgJHRObzmMaaY4cYeaCzEljzdUmoTqhdDn2njdx(mgd3V0ab1VlZBjjBqDbzmIuHlFgJHRObzmMqjaoqKGKeaylKVCHqSeacNoPraq3XOWQpcaUDuENGaWX(p2VUJrHvO6dIiWvqmxLbPP7xqOFxIKTWuifp7ew)I6x3XOWku9bre4QlZBjjB9FOFr9FSFKXoH8LHyDtdDf7XCvqj9lQ)J9lv)UejBHPqkE2jS(f1Vu9R7yuyfQ(HicCfeZvzqA6(fe63LizlmfsXZoH1VO(LQFDhJcRq1perGRUmVLKS1VGq)6ogfwHQFOlZBjjBWLpJXW9li0VUJrHvO6dIiWvqmxLbPP7xu)h7xQ(1DmkScv)qebUcI5QminD)cc9R7yuyfQ(GUmVLKSblGBOtA9lnk9R7yuyfQ(HUmVLKSblGBOtA9FOFbH(1DmkScvFqebU6Y8wsYw)I6xQ(1DmkScv)qebUcI5QminD)I6x3XOWku9bDzEljzdwa3qN06xAu6x3XOWku9dDzEljzdwa3qN06)q)cc9lv)iJDc5ldX6Mg6k2J5QGs6xu)h7xQ(1DmkScv)qebUcI5QminD)I6)y)6ogfwHQpOlZBjjBWc4g6Kw)uz)uVFV6hzStiFzi2J5QlFgJH7xqOFKXoH8LHypMRU8zmgUFP7x3XOWku9bDzEljzdwa3qN06Nu97V)d9li0VUJrHvO6hIiWvqmxLbPP7xu)h7x3XOWku9bre4kiMRYG009lQFDhJcRq1h0L5TKKnybCdDsRFPrPFDhJcRq1p0L5TKKnybCdDsRFr9FSFDhJcRq1h0L5TKKnybCdDsRFQSFQ3Vx9Jm2jKVme7XC1LpJXW9li0pYyNq(YqShZvx(mgd3V09R7yuyfQ(GUmVLKSblGBOtA9tQ(93)H(fe6)y)s1VUJrHvO6dIiWvqmxLbPP7xqOFDhJcRq1p0L5TKKnybCdDsRFPrPFDhJcRq1h0L5TKKnybCdDsR)d9lQ)J9R7yuyfQ(HUmVLKSbxokE6xu)6ogfwHQFOlZBjjBWc4g6Kw)uz)uVFP7hzStiFzi2J5QlFgJH7xu)iJDc5ldXEmxD5ZymC)E1VUJrHvO6h6Y8wsYgSaUHoP1pP63F)cc9lv)6ogfwHQFOlZBjjBWLJIN(f1)X(1DmkScv)qxM3ss2GlFgJH7Nk7N697v)iJDc5ldX6Mg6k2J5QlFgJH7xu)iJDc5ldX6Mg6k2J5QlFgJH7x6(9tT(f1)X(1DmkScvFqxM3ss2GfWn0jT(PY(PE)E1pYyNq(YqShZvx(mgd3VGq)6ogfwHQFOlZBjjBWLpJXW9tL9t9(9QFKXoH8LHypMRU8zmgUFr9R7yuyfQ(HUmVLKSblGBOtA9tL97JA9d0(rg7eYxgI9yU6YNXy4(9QFKXoH8LHyDtdDf7XC1LpJXW9li0pYyNq(YqShZvx(mgd3V09R7yuyfQ(GUmVLKSblGBOtA9tQ(93VGq)iJDc5ldXEmxfus)h6xqOFDhJcRq1p0L5TKKn4YNXy4(PY(PE)s3pYyNq(YqSUPHUI9yU6YNXy4(f1)X(1DmkScvFqxM3ss2GfWn0jT(PY(PE)E1pYyNq(YqSUPHUI9yU6YNXy4(fe6x3XOWku9bDzEljzdwa3qN063R(Ph0i06YNXy4(f1pYyNq(YqSUPHUI9yU6YNXy4(bA)6ogfwHQpOlZBjjBWc4g6Kw)s3p9GgHwx(mgd3VGq)s1VUJrHvO6dIiWvqmxLbPP7xu)h7hzStiFzi2J5QlFgJH7x6(1DmkScvFqxM3ss2GfWn0jT(jv)(7xqOFKXoH8LHypMRckP)d9FO)d9FO)d9FOFbH(1yrZkuNtUQzTmC)E1pYyNq(YqShZvx(mgd3)H(fe6xQ(1DmkScvFqebUcI5QminD)I6xQ(Djs2ctHu8Sty9lQ)J9R7yuyfQ(HicCfeZvzqA6(f1)X(p2Vu9Jm2jKVme7XCvqj9li0VUJrHvO6h6Y8wsYgC5ZymC)s3p17)q)I6)y)iJDc5ldXEmxD5ZymC)s3VFQ1VGq)6ogfwHQFOlZBjjBWLpJXW9tL9t9(LUFKXoH8LHypMRU8zmgU)d9FOFbH(LQFDhJcRq1perGRGyUkdst3VO(p2Vu9R7yuyfQ(HicC1L5TKKT(fe6x3XOWku9dDzEljzdU8zmgUFbH(1DmkScv)qxM3ss2GfWn0jT(LgL(1DmkScvFqxM3ss2GfWn0jT(p0)H(p0VO(p2Vu9R7yuyfQ(Gdg6chcUM01WjMbNLlvD5adUmUFbH(LQFzqAAy4eZGZYLk5Wkqqj9FGaa(MkMaGUJrHvFekbWfteKKaaBH8LleILaq40jnca6ogfw9taWTJY7eeao2)X(1DmkScv)qebUcI5QminD)cc97sKSfMcP4zNW6xu)6ogfwHQFiIaxDzEljzR)d9lQ)J9Jm2jKVmeRBAORypMRckPFr9FSFP63LizlmfsXZoH1VO(LQFDhJcRq1herGRGyUkdst3VGq)UejBHPqkE2jS(f1Vu9R7yuyfQ(GicC1L5TKKT(fe6x3XOWku9bDzEljzdU8zmgUFbH(1DmkScv)qebUcI5QminD)I6)y)s1VUJrHvO6dIiWvqmxLbPP7xqOFDhJcRq1p0L5TKKnybCdDsRFPrPFDhJcRq1h0L5TKKnybCdDsR)d9li0VUJrHvO6hIiWvxM3ss26xu)s1VUJrHvO6dIiWvqmxLbPP7xu)6ogfwHQFOlZBjjBWc4g6Kw)sJs)6ogfwHQpOlZBjjBWc4g6Kw)h6xqOFP6hzStiFziw30qxXEmxfus)I6)y)s1VUJrHvO6dIiWvqmxLbPP7xu)h7x3XOWku9dDzEljzdwa3qN06Nk7N697v)iJDc5ldXEmxD5ZymC)cc9Jm2jKVme7XC1LpJXW9lD)6ogfwHQFOlZBjjBWc4g6Kw)KQF)9FOFbH(1DmkScvFqebUcI5QminD)I6)y)6ogfwHQFiIaxbXCvgKMUFr9R7yuyfQ(HUmVLKSblGBOtA9lnk9R7yuyfQ(GUmVLKSblGBOtA9lQ)J9R7yuyfQ(HUmVLKSblGBOtA9tL9t9(9QFKXoH8LHypMRU8zmgUFbH(rg7eYxgI9yU6YNXy4(LUFDhJcRq1p0L5TKKnybCdDsRFs1V)(p0VGq)h7xQ(1DmkScv)qebUcI5QminD)cc9R7yuyfQ(GUmVLKSblGBOtA9lnk9R7yuyfQ(HUmVLKSblGBOtA9FOFr9FSFDhJcRq1h0L5TKKn4YrXt)I6x3XOWku9bDzEljzdwa3qN06Nk7N69lD)iJDc5ldXEmxD5ZymC)I6hzStiFzi2J5QlFgJH73R(1DmkScvFqxM3ss2GfWn0jT(jv)(7xqOFP6x3XOWku9bDzEljzdUCu80VO(p2VUJrHvO6d6Y8wsYgC5ZymC)uz)uVFV6hzStiFziw30qxXEmxD5ZymC)I6hzStiFziw30qxXEmxD5ZymC)s3VFQ1VO(p2VUJrHvO6h6Y8wsYgSaUHoP1pv2p173R(rg7eYxgI9yU6YNXy4(fe6x3XOWku9bDzEljzdU8zmgUFQSFQ3Vx9Jm2jKVme7XC1LpJXW9lQFDhJcRq1h0L5TKKnybCdDsRFQSFFuRFG2pYyNq(YqShZvx(mgd3Vx9Jm2jKVmeRBAORypMRU8zmgUFbH(rg7eYxgI9yU6YNXy4(LUFDhJcRq1p0L5TKKnybCdDsRFs1V)(fe6hzStiFzi2J5QGs6)q)cc9R7yuyfQ(GUmVLKSbx(mgd3pv2p17x6(rg7eYxgI1nn0vShZvx(mgd3VO(p2VUJrHvO6h6Y8wsYgSaUHoP1pv2p173R(rg7eYxgI1nn0vShZvx(mgd3VGq)6ogfwHQFOlZBjjBWc4g6Kw)E1p9GgHwx(mgd3VO(rg7eYxgI1nn0vShZvx(mgd3pq7x3XOWku9dDzEljzdwa3qN06x6(Ph0i06YNXy4(fe6xQ(1DmkScv)qebUcI5QminD)I6)y)iJDc5ldXEmxD5ZymC)s3VUJrHvO6h6Y8wsYgSaUHoP1pP63F)cc9Jm2jKVme7XCvqj9FO)d9FO)d9FO)d9li0VglAwH6CYvnRLH73R(rg7eYxgI9yU6YNXy4(p0VGq)s1VUJrHvO6hIiWvqmxLbPP7xu)s1VlrYwykKINDcRFr9FSFDhJcRq1herGRGyUkdst3VO(p2)X(LQFKXoH8LHypMRckPFbH(1DmkScvFqxM3ss2GlFgJH7x6(PE)h6xu)h7hzStiFzi2J5QlFgJH7x6(9tT(fe6x3XOWku9bDzEljzdU8zmgUFQSFQ3V09Jm2jKVme7XC1LpJXW9FO)d9li0Vu9R7yuyfQ(GicCfeZvzqA6(f1)X(LQFDhJcRq1herGRUmVLKS1VGq)6ogfwHQpOlZBjjBWLpJXW9li0VUJrHvO6d6Y8wsYgSaUHoP1V0O0VUJrHvO6h6Y8wsYgSaUHoP1)H(p0)H(f1)X(LQFDhJcRq1pCWqx4qW1KUgoXm4SCPQlhyWLX9li0Vu9ldstddNygCwUujhwbckP)deaW3uXea0DmkS6NqjucLaasEXtAea3p187NAuHpQtaGCS2yOXeaeJaesmg4aHboWAGP)(jjcU)5usUA)052pQ6ookyePIrT)LfZGZYL(X5j3FaQ5zOCPFhIWqZyylU3hJ73hW0pqMgsEvU0pQACztHKg1(1SFu14YMcjnKTq(Yfu7)OpQEa2I79X4(9dm9dKPHKxLl9J6cAmDUOziPrTFn7h1f0y6CrZqsdzlKVCb1(p6JQhGT4EFmUFQay6hitdjVkx6h1f0y6CrZqsJA)A2pQlOX05IMHKgYwiF5cQ9hA)aRaw69(p6JQhGT4EFmUFQdm9dKPHKxLl9J6cAmDUOziPrTFn7h1f0y6CrZqsdzlKVCb1(p6JQhGT4EFmUFGiW0pqMgsEvU0pQlOX05IMHKg1(1SFuxqJPZfndjnKTq(Yfu7p0(bwbS079F0hvpaBX9(yC)EtGPFGmnK8QCPFu14YMcjnQ9Rz)OQXLnfsAiBH8LlO2)rFu9aSf37JX97JAat)azAi5v5s)OQXLnfsAu7xZ(rvJlBkK0q2c5lxqT)J(O6bylU3hJ73N3cm9dKPHKxLl9JQgx2uiPrTFn7hvnUSPqsdzlKVCb1(p6JQhGT4EFmUFFElW0pqMgsEvU0pQlOX05IMHKg1(1SFuxqJPZfndjnKTq(Yfu7)OpQEa2I79X4(9rDGPFGmnK8QCPFuxqJPZfndjnQ9Rz)OUGgtNlAgsAiBH8LlO2)rFu9aSf37JX97tmbm9dKPHKxLl9JQgx2uiPrTFn7hvnUSPqsdzlKVCb1(p6JQhGT4EFmUFFIjGPFGmnK8QCPFuxqJPZfndjnQ9Rz)OUGgtNlAgsAiBH8LlO2)r)u9aSf37JX97tmam9dKPHKxLl9JQgx2uiPrTFn7hvnUSPqsdzlKVCb1(p6JQhGT4EFmUF)uhy6hitdjVkx6h1f0y6CrZqsJA)A2pQlOX05IMHKgYwiF5cQ9hA)aRaw69(p6JQhGT4EFmUF)arGPFGmnK8QCPFuxqJPZfndjnQ9Rz)OUGgtNlAgsAiBH8LlO2FO9dScyP37)OpQEa2I79X4(9lgaM(bY0qYRYL(rfNGx5XkqsJA)A2pQ4e8kpwbsAiBH8LlO2)rFu9aSfVfxmcqiXyGdeg4aRbM(7NKi4(Ntj5Q9tNB)Owy6a8QO2)YIzWz5s)48K7pa18muU0VdryOzmSf37JX97hy6hitdjVkx6h1f0y6CrZqsJA)A2pQlOX05IMHKgYwiF5cQ9F0hvpaBX9(yC)(bM(bY0qYRYL(rDbnMox0mK0O2VM9J6cAmDUOziPHSfYxUGA)h9r1dWwCVpg3VFGPFGmnK8QCPFuDPvahfsAu7xZ(r1LwbCuiPHSfYxUGA)h9r1dWwCVpg3VFGPFGmnK8QCPFuXj4vEScK0O2VM9JkobVYJvGKgYwiF5cQ9F0hvpaBXBXfJaesmg4aHboWAGP)(jjcU)5usUA)052pQsw2LNYHIA)llMbNLl9JZtU)auZZq5s)oeHHMXWwCVpg3pvam9dKPHKxLl9J6cAmDUOziPrTFn7h1f0y6CrZqsdzlKVCb1(dTFGval9E)h9r1dWwCVpg3V3cm9dKPHKxLl9JQgx2uiPrTFn7hvnUSPqsdzlKVCb1(dTFGval9E)h9r1dWwCVpg3p1bM(bY0qYRYL(rvJlBkK0O2VM9JQgx2uiPHSfYxUGA)h9r1dWwCVpg3pqey6hitdjVkx6hvnUSPqsJA)A2pQACztHKgYwiF5cQ9F0hvpaBXBXfJaesmg4aHboWAGP)(jjcU)5usUA)052pQyf1(xwmdolx6hNNC)bOMNHYL(DicdnJHT4EFmUFFat)azAi5v5s)OQXLnfsAu7xZ(rvJlBkK0q2c5lxqT)J(O6bylU3hJ73BbM(bY0qYRYL(rDbnMox0mK0O2VM9J6cAmDUOziPHSfYxUGA)H2pWkGLEV)J(O6bylU3hJ7N6at)azAi5v5s)OUGgtNlAgsAu7xZ(rDbnMox0mK0q2c5lxqT)J(O6bylU3hJ73NpGPFGmnK8QCPFu14YMcjnQ9Rz)OQXLnfsAiBH8LlO2)rFu9aSf37JX97ZpW0pqMgsEvU0pQACztHKg1(1SFu14YMcjnKTq(Yfu7)OpQEa2I79X4(9rfat)azAi5v5s)OQXLnfsAu7xZ(rvJlBkK0q2c5lxqT)J(O6bylU3hJ73N3cm9dKPHKxLl9JQgx2uiPrTFn7hvnUSPqsdzlKVCb1(p6NQhGT4EFmUFFElW0pqMgsEvU0pQ4e8kpwbsAu7xZ(rfNGx5XkqsdzlKVCb1(p6JQhGT4EFmUFFuhy6hitdjVkx6hvnUSPqsJA)A2pQACztHKgYwiF5cQ9F0pvpaBX9(yC)(OoW0pqMgsEvU0pQlOX05IMHKg1(1SFuxqJPZfndjnKTq(Yfu7)OpQEa2I79X4(9rDGPFGmnK8QCPFuXj4vEScK0O2VM9JkobVYJvGKgYwiF5cQ9F0hvpaBX9(yC)(edat)azAi5v5s)OQXLnfsAu7xZ(rvJlBkK0q2c5lxqT)J(O6bylU3hJ73Nyay6hitdjVkx6h1f0y6CrZqsJA)A2pQlOX05IMHKgYwiF5cQ9F0hvpaBX9(yC)(8Mat)azAi5v5s)OQXLnfsAu7xZ(rvJlBkK0q2c5lxqT)J(O6bylU3hJ73N3ey6hitdjVkx6h1f0y6CrZqsJA)A2pQlOX05IMHKgYwiF5cQ9F0hvpaBX9(yC)(PgW0pqMgsEvU0pQACztHKg1(1SFu14YMcjnKTq(Yfu7)OFQEa2I79X4(9tnGPFGmnK8QCPFuXj4vEScK0O2VM9JkobVYJvGKgYwiF5cQ9F0hvpaBX9(yC)(PoW0pqMgsEvU0pQACztHKg1(1SFu14YMcjnKTq(Yfu7)OFQEa2I79X4(9tDGPFGmnK8QCPFuxqJPZfndjnQ9Rz)OUGgtNlAgsAiBH8LlO2)rFu9aSf37JX97N6at)azAi5v5s)OItWR8yfiPrTFn7hvCcELhRajnKTq(Yfu7)OpQEa2I79X4(9lMaM(bY0qYRYL(rfNGx5XkqsJA)A2pQ4e8kpwbsAiBH8LlO2)rFu9aSfVfxmcqiXyGdeg4aRbM(7NKi4(Ntj5Q9tNB)OQ7yuyfJA)llMbNLl9JZtU)auZZq5s)oeHHMXWwCVpg3pqey6hitdjVkx6hWCcK9J9yAq1(b27xZ(9oy0Fzqo4jT(tj8gAU9FKuh6)i1P6bylU3hJ7hicm9dKPHKxLl9JQUJrHvOpiPrTFn7hvDhJcRq1hK0O2)r)ElvpaBX9(yC)arGPFGmnK8QCPFu1DmkSc9djnQ9Rz)OQ7yuyfQ(HKg1(p6his1dWwCVpg3Vycy6hitdjVkx6hWCcK9J9yAq1(b27xZ(9oy0Fzqo4jT(tj8gAU9FKuh6)i1P6bylU3hJ7xmbm9dKPHKxLl9JQUJrHvOpiPrTFn7hvDhJcRq1hK0O2)r)arQEa2I79X4(ftat)azAi5v5s)OQ7yuyf6hsAu7xZ(rv3XOWku9djnQ9F0V3s1dWw8wCGWNsYv5s)aX(dNoP1)DWkg2ItaqYM0ZLja4n8g9lgnwk4ZWWigj9deiqt5Tf3B4n6xmASoe97tmrI(9tn)(BXBX9gEJ(bseHHMXatlU3WB0pv2pWzY0jOv6xmMX5fj3)G73sT)O)t2HiSX1VIG7pkL063fgPip3B)NHfOzylU3WB0pv2VymJ9yoU0FukP1VKDYDup9tEue9dyobY(bcbeS3HT4EdVr)uz)EN1(bwKNDcd3FHXEmx)kcE2(bsGaW9JZtwNtgdBXBXdNoPHHsw2LNYHcuuiLCQ6Llv6B4HlKhdDvtQowlE40jnmuYYU8uouGIcPOVmgHBdATfpC6KggkzzxEkhkqrHuASvDdjKyOrzbnMox0meNGx6CrZv(uMxClE40jnmuYYU8uouGIcPkjO8LRAiHesw2fyTQZjJIpQrIHgLWPdsUYgFomwAFccs5sKSfMcP4zNWejLgx2uiY8EzpT4HtN0Wqjl7Yt5qbkkKkMtUuXisLednkHthKCLn(CySxuHOJs5sKSfMcP4zNWejLgx2uiY8EzpccHthKCLn(CySx(p0IhoDsddLSSlpLdfOOqkSYrXtfJivsm0OeoDqYv24ZHXs7xq4OlrYwykKINDctqqJlBkezEVSNdIcNoi5kB85Wyu83I3IhoDsdduuiLlbnL3kgrQT4HtN0Waffs5sqt5TIrKkjUJXvxbfQGAKyOrzbnMox0meZsqacSHRs20DJZqN0eeWj4vESc0gpbUQzEXvj5Gttq4OlTc4OWLrYloU1KUsNRcASiPwqJPZfndXSeeGaB4QKnD34m0jTdT4EJ(bwN9hi4O0FyL(j5gMygCUdWg3pWbcgi7Nn(CymWI7Nm3Fjnu1(lz)kIb3pDU9l5gE4f3Vm7cqm3)OOw6xM7xZSFSK480t)Hv6Nm3Vlmu1(xokZ1t)KCdtm3pwc7g6X1Vminng2IhoDsdduuiLUHjMbN7aSng6kgrQKyOrrknw0SchCvYn8WBlE40jnmqrHuU4ERHtN0Q3bRKWItgfDhJcRysm0O4sKSfMcP4zNWe5Y8wsYguxqgJiv4YNXyyrUmVLKSbxgNwOJHUg7MKHlFgJHfeKYLizlmfsXZoHjYL5TKKnOUGmgrQWLpJXWT4EdVr)abW3Wt)0HBm097jb3(ljOS2pOPZTFpjy)icKC)sa1(fJzCAHog6(bcTBsU)ss2ir)52)q3VIG73L5TKKT(hC)AM9FtdD)A2FHVHN(Pd3yO73tcU9deqckRW(bct3VLg3Fs3VIGXC)U0kJoPH7pwU)q(Y9Rz)NS2p5rrmw)kcUFFuRFm7sRG7)Ym5Wdj6xrW9JNZ(PdhJ73tcU9deqckR9hGAEg64I71dSf3B4n6pC6KggOOqkJjtNGwPUmoVizsm0OGtWR8yfOXKPtqRuxgNxKSOJYG00WLXPf6yORXUjziOebbxM3ss2GlJtl0XqxJDtYWLpJXWs7JAcc0dAeAD5ZymSx(aIhAXdNoPHbkkKYf3BnC6Kw9oyLewCYO4k4w8WPtAyGIcPCX9wdNoPvVdwjHfNmkyLeyDhNIIpsm0OeoDqYv24ZHXErfT4HtN0Waffs5I7TgoDsREhSsclozu0DCuWisftcSUJtrXhjgAucNoi5kB85WyP93I3IhoDsddDfmkY8I5LYyOjXqJYrzqAAOUGmgrQqqjIKbPPHlJtl0XqxJDtYqqjICjs2ctHu8Styheeokdstd1fKXisfckrKminnK8ClvSKzhfdbLiYLizlmfAdAeALo4dcchDjs2ctHiztr4zfeCjs2ctHg728MB5GizqAAOUGmgrQqqjccYjglIEqJqRlFgJH9YhviiC0LizlmfsXZoHjsgKMgUmoTqhdDn2njdbLiIEqJqRlFgJH9smrfhAXdNoPHHUcgOOqk5BMLkn46HednkYG00qDbzmIuHGseeCzEljzdQliJrKkC5ZymS0ub1eeKtmwe9GgHwx(mgd7LpGylE40jnm0vWaffsfMJX6g3QlUxsm0Oidstd1fKXisfckrqWL5TKKnOUGmgrQWLpJXWstfutqqoXyr0dAeAD5ZymSx(aIT4HtN0Wqxbduuif9SS8nZcjgAuKbPPH6cYyePcbLii4Y8wsYguxqgJiv4YNXyyPPcQjiiNySi6bncTU8zmg2lVzlE40jnm0vWaffsDh0iuCfiWGf0NSPKyOrrgKMgQliJrKkSKKTw8WPtAyORGbkkKssQtAKyOrrgKMgQliJrKkeuIOJYG00q5BMLliwHGsee0yrZkebhxfbuIt9Yp1oiiiNySi6bncTU8zmg2l)arbHJUejBHPqkE2jmrYG00WLXPf6yORXUjziOer0dAeAD5ZymSxIj)hAXBXdNoPHHyffSYrXtfJivsm0OOXLnfIvokEQ0Pdel6OKLrwr7kqFqSYrXtfJivrYG00qSYrXtLoDGy4YNXyyVOUGGminneRCu8uPthigwsY2brhLbPPHlJtl0XqxJDtYWss2eeKYLizlmfsXZoHDOfpC6KggIvGIcPOm3BfJi1w8WPtAyiwbkkKQKGYxUQHesm0OC0LizlmfsXZoHj6OlZBjjBWLXPf6yORXUjz4YNXyyVq7kheeKYLizlmfsXZoHjskxIKTWuOnOrOv6GfeCjs2ctH2GgHwPdw0rxM3ss2GKNBPILm7Oy4YNXyyVq7kccUmVLKSbjp3sflz2rXWLpJXWstfu7GGGCIXIOh0i06YNXyyV8r9dIok1gtPYiztHrPGHmvhSIfe2ykvgjBkmkfmeuYHw8WPtAyiwbkkKI(gltIHgfn2QUHeiOerlOX05IMH4e8sNlAUYNY8IBXdNoPHHyfOOqkn2QUHesm0OSGgtNlAgItWlDUO5kFkZlwKgBv3qcC5ZymSxODfrUmVLKSbPVXYWLpJXWEH2vAXdNoPHHyfOOqkMQsUjEqYvmIuBXdNoPHHyfOOqkYZTuXsMDumjgAuo6Y8wsYguxqgJiv4YNXyyVq7kccYG00qDbzmIuHGsoi6OuBmLkJKnfgLcgYuDWkwqqQnMsLrYMcJsbdbLi64gtPYiztHrPGHfWn0jnGUXuQms2uyuky4yE5NAccBmLkJKnfgLcgoM0arQDqqyJPuzKSPWOuWqqjI2ykvgjBkmkfmC5ZymS0(8MccHthKCLn(CyS0(oiiiNySi6bncTU8zmg2l)uRfpC6KggIvGIcPOVHhUuXisTfpC6KggIvGIcPkCOiQoebLnojXqJcD6aXa1fyTUmA28IoDGy4zq1w8WPtAyiwbkkKkQNGBH3AsxDBsg3IhoDsddXkqrHuKJ5og6ASBsMednkUmVLKSbxgNwOJHUg7MKHlFgJH9cTRi6OuACztHmvLCt8GKRyePkiidstdLVzwUGyfck5GGGuUejBHPqkE2jmbbxM3ss2GlJtl0XqxJDtYWLpJXWccYjglIEqJqRlFgJH9I6T4HtN0WqScuui1Y40cDm01y3KmjgAuokdstdljO8LRAibckrqqknUSPWsckF5QgseeKtmwe9GgHwx(mgd7Lp)heDuQnMsLrYMcJsbdzQoyflii1gtPYiztHrPGHGseDCJPuzKSPWOuWWc4g6Kgq3ykvgjBkmkfmCmV8rnbHnMsLrYMcJsbdhtAVLAccBmLkJKnfgLcg6sqtrX3bbHnMsLrYMcJsbdbLiAJPuzKSPWOuWWLpJXWs7nfecNoi5kB85WyP9DOfpC6KggIvGIcPqM3l7HednkYG00WLXPf6yORXUjziOebbPCjs2ctHu8StyIokdstdLSSBWCfJivmSKKnbbP04YMcDiMZG3OIrKQGq40bjxzJphg7L)dT4HtN0WqScuuifw5O4PIrKkjgAuCjs2ctHu8StyIOthigOUaR1LrZMx0PdedpdQk64rxM3ss2GlJtl0XqxJDtYWLpJXWEH2vawGkeDukCcELhRazAAq8GKRHnNrnCo(YBO5kiiLgx2uyjbLVCvdjhoiiOXLnfwsq5lx1qIixM3ss2GLeu(YvnKax(mgd7fvCOfpC6KggIvGIcP2qYuQ0ZYKyOrzbnMox0medUOhdDfJivSinUSPqSUCCEhJfD0L5TKKn4Y40cDm01y3KmC5ZymS0(OMGGuUejBHPqkE2jmbbP04YMcljO8LRAirqaNGx5XkqMMgepi5AyZzudNJV8gAUhAXdNoPHHyfOOqkhI5m4nQyePsIHgfmRv50aXqD41VyO6TsCIKbPPH6ookvmIuXWss2erNoqmxQ6ook86P6sqt9I6IKbPPHsw2nyUIrKkgckPfpC6KggIvGIcPI1fgxXisLednkywRYPbIH6WRFXq1BL4ejdstd1DCuQyePIHLKSjIoDGyUu1DCu41t1LGM6f1fjdstdLSSBWCfJivmeuslE40jnmeRaffsPliJrKkjgAuoE0LizlmfIKnfHNv0rzqAAOKLDdMRyePIHLKSjiGzTkNgigQdV(fdvVvIt0cAmDUOziMDlR4AsxveCf0KVJrzm0vKd65kiOXLnf6I7Dm0vfbxXisfFqqWLizlmfASBZBUfbbxIKTWuifp7eMOJUmVLKSbxgNwOJHUg7MKHlFgJHLMkOMGGlZBjjBWLXPf6yORXUjz4YNXyyV8rTdccUejBHPqBqJqR0bl6OlZBjjBqYZTuXsMDumC5ZymS0ub1eeKbPPHKNBPILm7OyiOKdheeKbPPHiZ7L9abLikC6GKRSXNdJL23brhLAJPuzKSPWOuWqMQdwXccsTXuQms2uyukyiOerh3ykvgjBkmkfmSaUHoPb0nMsLrYMcJsbdhZl)uxqyJPuzKSPWOuWWXKgisTdccBmLkJKnfgLcgckr0gtPYiztHrPGHlFgJHL2h1eecNoi5kB85WyP9DqqqoXyr0dAeAD5ZymSx(PElE40jnmeRaffsfZjxQyePscNh3LRASOzfJIpsm0OidstdLSSBWCfJivmSKKnbHJYG00qDbzmIuHGseeObV36YoeXIMR6CYEH2vaQlWAvNtwqaZAvonqmuhE9lgQEReNOf0y6CrZqm7wwX1KUQi4kOjFhJYyORih0Z9GOJsPXLnf6qmNbVrfJivbHWPdsUYgFom2l)heeokdstd1DCuQyePIHlFgJHLMPk7avUQZjliqNoqmxQ6ook86P6sqtLMAhefoDqYv24ZHXs7RfpC6KggIvGIcP2qYuQ0ZYKyOr5OlZBjjBWLXPf6yORXUjz4YNXyyP9rnbbPCjs2ctHu8StyccsPXLnfwsq5lx1qIGaobVYJvGmnniEqY1WMZOgohF5n0CpiIoDGyG6cSwxgnBErNoqm8mOQOJYG00WsckF5QgsGLKSjsgKMgYb6lRXnnCvxqUsNoqmSKKnbbnUSPqSUCCEhJp0IhoDsddXkqrHuoeZzWBuXisLednkYG00qjl7gmxXisfdbLiiqNoqS0UeRanC6KgmMtUuXisf6sS2IhoDsddXkqrHuX6cJRyePsIHgfzqAAOKLDdMRyePIHGseeOthiwAxIvGgoDsdgZjxQyePcDjwBXdNoPHHyfOOqkmVsytRyDm0KW5XD5QglAwXO4JednkltVmgriFzrASOzfQZjx1Swgw6c4g6KwlE40jnmeRaffsjh7gOzsm0OeoDqYv24ZHXs7RfpC6KggIvGIcP2qYuQ0ZYKyOr5OlZBjjBWLXPf6yORXUjz4YNXyyP9rnrlOX05IMHyWf9yORyePIfeKYLizlmfsXZoHjiiLgx2uyjbLVCvdjcc4e8kpwbY00G4bjxdBoJA4C8L3qZ9Gi60bIbQlWADz0S5fD6aXWZGQIokdstdljO8LRAibwsYMGGgx2uiwxooVJXhAXdNoPHHyfOOqk5aDnPR6ookysm0Oidstd1fKXisfwsYwlE40jnmeRaffsrFzmc3g0kjgAuWj4vEScuciwbVCLxqj6KMizqAAOUGmgrQWss2AXdNoPHHyfOOqkSYrXtfJi1w8w8WPtAyOUJJcgrQyuWkhfpvmIujXqJIgx2uiw5O4PsNoqSOXQ03bncvKminneRCu8uPthigU8zmg2lQ3IhoDsdd1DCuWisfduuifL5ERyePsIHgLf0y6CrZqjjOdrnPRBaSLBLEd0NSPyrYG00q6B4HxC9mwkqqjT4HtN0WqDhhfmIuXaffsrFdpCPIrKkjgAuwqJPZfndLKGoe1KUUbWwUv6nqFYMIBXdNoPHH6ookyePIbkkKQKGYxUQHesm0OC0LizlmfsXZoHjYL5TKKn4Y40cDm01y3KmC5ZymSxODfbbPCjs2ctHu8StyIKYLizlmfAdAeALoybbxIKTWuOnOrOv6GfD0L5TKKni55wQyjZokgU8zmg2l0UIGGlZBjjBqYZTuXsMDumC5ZymS0ub1oiiOXIMvOoNCvZAzyV8rnbbxM3ss2GlJtl0XqxJDtYWLpJXWs7JAIcNoi5kB85WyPPIdIok1gtPYiztHrPGHmvhSIfe2ykvgjBkmkfmC5ZymS0EtbbPCjs2ctHu8StyhAXdNoPHH6ookyePIbkkKsJTQBiHednklOX05IMH4e8sNlAUYNY8IfPXw1nKax(mgd7fAxrKlZBjjBq6BSmC5ZymSxODLw8WPtAyOUJJcgrQyGIcPOVXYK4ogxDfu8tDsm0OOXw1nKabLiAbnMox0meNGx6CrZv(uMxClE40jnmu3XrbJivmqrHumvLCt8GKRyeP2IhoDsdd1DCuWisfduuif55wQyjZokUfpC6KggQ74OGrKkgOOqkYXChdDn2njtIHgfxM3ss2GlJtl0XqxJDtYWLpJXWEH2veDuknUSPqMQsUjEqYvmIufeKbPPHY3mlxqScbLCqqqkxIKTWuifp7eMGGlZBjjBWLXPf6yORXUjz4YNXyyP9rnbb5eJfrpOrO1LpJXWEr9w8WPtAyOUJJcgrQyGIcPwgNwOJHUg7MKjXqJYrxM3ss2GiZ7L9ax(mgd7fAxrqqknUSPqK59YEee0yrZkuNtUQzTmSx(8Fq0rP2ykvgjBkmkfmKP6GvSGWgtPYiztHrPGHlFgJHL2BkieoDqYv24ZHXsJYgtPYiztHrPGHUe0uGf8FOfpC6KggQ74OGrKkgOOqkK59YEiXqJIminnCzCAHog6ASBsgckrqqkxIKTWuifp7ewlE40jnmu3XrbJivmqrHuYXUbAUfpC6KggQ74OGrKkgOOqkDbzmIujXqJIlrYwykKINDct0rzqAA4Y40cDm01y3KmeuIGGlZBjjBWLXPf6yORXUjz4YNXyyP9rTdccUejBHPqBqJqR0blsgKMgsEULkwYSJIHGseeCjs2ctHiztr4zfeCjs2ctHg728MBrqqoXyr0dAeAD5ZymSx(PElE40jnmu3XrbJivmqrHuBizkv6zzsm0OSGgtNlAgIbx0JHUIrKkw0rxM3ss2GlJtl0XqxJDtYWLpJXWs7JAccs5sKSfMcP4zNWeeKsJlBkSKGYxUQHKdIKbPPH6ookvmIuXWLpJXWsJctv2bQCvNtUfpC6KggQ74OGrKkgOOqQyo5sfJivs484UCvJfnRyu8rIHgLJYG00qDhhLkgrQy4YNXyyPrHPk7avUQZjliqNoqmxQ6ook86P6sqtLMAheDugKMgkzz3G5kgrQyyjjBcc0G3BDzhIyrZvDozVCbwR6CYafTRiiidstd1fKXisfckrqaZAvonqmuhE9lgQEReNOf0y6CrZqm7wwX1KUQi4kOjFhJYyORih0Z9qlE40jnmu3XrbJivmqrHufouevhIGYgNKyOrHoDGyG6cSwxgnBErNoqm8mOAlE40jnmu3XrbJivmqrHuBizkv6zzsm0OC0L5TKKn4Y40cDm01y3KmC5ZymS0(OMOf0y6CrZqm4IEm0vmIuXccs5sKSfMcP4zNWeeKAbnMox0medUOhdDfJivSGGuACztHLeu(YvnKCqKminnu3XrPIrKkgU8zmgwAuyQYoqLR6CYT4HtN0WqDhhfmIuXaffsDcE1bJivsm0Oidstd1DCuQyePIHLKSjiidstdLSSBWCfJivmeuIi60bIL2LyfOHtN0GXCYLkgrQqxIvrhLsJlBk0HyodEJkgrQccHthKCLn(CyS0uXHw8WPtAyOUJJcgrQyGIcPCiMZG3OIrKkjgAuKbPPHsw2nyUIrKkgckreD6aXs7sSc0WPtAWyo5sfJivOlXQOWPdsUYgFom2lVTfpC6KggQ74OGrKkgOOqkkZ9wXisLednkYG00WchLk7HHLKS1IhoDsdd1DCuWisfduuivupb3cV1KU62KmUfpC6KggQ74OGrKkgOOqk6B4HlvmIuBXdNoPHH6ookyePIbkkKcZRe20kwhdnjCECxUQXIMvmk(iXqJYY0lJreYxUfpC6KggQ74OGrKkgOOqQtWRoyePsIHgf60bIL2LyfOHtN0GXCYLkgrQqxIvrhDzEljzdUmoTqhdDn2njdx(mgdln1feKYLizlmfsXZoHDOfpC6KggQ74OGrKkgOOqkn2QUHesm0OSGgtNlAgAmgpgAYX6bx1nKizm01qIKydfe3IhoDsdd1DCuWisfduuif9YmW2yOR6gsiXqJYcAmDUOzOXy8yOjhRhCv3qIKXqxdjsInuqClE40jnmu3XrbJivmqrHuYb6Asx1DCuWKyOrrgKMgQliJrKkSKKTw8WPtAyOUJJcgrQyGIcPOVmgHBdALednk4e8kpwbkbeRGxUYlOeDstKminnuxqgJivyjjBT4HtN0WqDhhfmIuXaffsHvokEQyeP2I3IhoDsdd1DmkSIrbzStiFzsyXjJc2J5QGsibY4cYOidstdxgNwOJHUg7MKHGseeKbPPH6cYyePcbL0IhoDsdd1DmkSIbkkKczStiFzsyXjJcw30qxXEmxfucjqgxqgfxIKTWuifp7eMizqAA4Y40cDm01y3KmeuIizqAAOUGmgrQqqjccs5sKSfMcP4zNWejdstd1fKXisfckPfpC6KggQ7yuyfduuifYyNq(YKWItgfSUPHUI9yU6YNXyysKsqbZ6qtcxALrN0qXLizlmfsXZoHrcKXfKrXL5TKKn4Y40cDm01y3KmC5ZymSxab5Y8wsYguxqgJiv4YNXy4kAqgJjbY4cYv(IzuCzEljzdQliJrKkC5ZymCfniJXKyOrrgKMgQliJrKkSKKTw8WPtAyOUJrHvmqrHuiJDc5ltclozuW6Mg6k2J5QlFgJHjrkbfmRdnjCPvgDsdfxIKTWuifp7egjqgxqgfxM3ss2GlJtl0XqxJDtYWLpJXWKazCb5kFXmkUmVLKSb1fKXisfU8zmgUIgKXysm0Oidstd1fKXisfckPfpC6KggQ7yuyfduuifYyNq(YKWItgfShZvx(mgdtIuckywhAs4sRm6KgkUejBHPqkE2jmsGmUGmkUmVLKSbxgNwOJHUg7MKHlFgJHLgiixM3ss2G6cYyePcx(mgdxrdYymjqgxqUYxmJIlZBjjBqDbzmIuHlFgJHRObzmUfpC6KggQ7yuyfduuifiMRJYNysGVPIrr3XOWQpsm0OC8OUJrHvOpiIaxbXCvgKMwqWLizlmfsXZoHjs3XOWk0herGRUmVLKSDq0rKXoH8LHyDtdDf7XCvqjIokLlrYwykKINDctKu6ogfwH(HicCfeZvzqAAbbxIKTWuifp7eMiP0DmkSc9dre4QlZBjjBcc6ogfwH(HUmVLKSbx(mgdliO7yuyf6dIiWvqmxLbPPfDukDhJcRq)qebUcI5QminTGGUJrHvOpOlZBjjBWc4g6KM0OO7yuyf6h6Y8wsYgSaUHoPDqqq3XOWk0herGRUmVLKSjskDhJcRq)qebUcI5QminTiDhJcRqFqxM3ss2GfWn0jnPrr3XOWk0p0L5TKKnybCdDs7GGGuiJDc5ldX6Mg6k2J5QGseDukDhJcRq)qebUcI5QminTOJ6ogfwH(GUmVLKSblGBOtAuj19czStiFzi2J5QlFgJHfeqg7eYxgI9yU6YNXyyP1DmkSc9bDzEljzdwa3qN0a29Fqqq3XOWk0perGRGyUkdstl6OUJrHvOpiIaxbXCvgKMwKUJrHvOpOlZBjjBWc4g6KM0OO7yuyf6h6Y8wsYgSaUHoPj6OUJrHvOpOlZBjjBWc4g6KgvsDVqg7eYxgI9yU6YNXyybbKXoH8LHypMRU8zmgwADhJcRqFqxM3ss2GfWn0jnGD)heeokLUJrHvOpiIaxbXCvgKMwqq3XOWk0p0L5TKKnybCdDstAu0DmkSc9bDzEljzdwa3qN0oi6OUJrHvOFOlZBjjBWLJIhr6ogfwH(HUmVLKSblGBOtAuj1LgzStiFzi2J5QlFgJHfHm2jKVme7XC1LpJXWEP7yuyf6h6Y8wsYgSaUHoPbS7xqqkDhJcRq)qxM3ss2GlhfpIoQ7yuyf6h6Y8wsYgC5ZymmvsDVqg7eYxgI1nn0vShZvx(mgdlczStiFziw30qxXEmxD5ZymS0(PMOJ6ogfwH(GUmVLKSblGBOtAuj19czStiFzi2J5QlFgJHfe0DmkSc9dDzEljzdU8zmgMkPUxiJDc5ldXEmxD5ZymSiDhJcRq)qxM3ss2GfWn0jnQ0h1akYyNq(YqShZvx(mgd7fYyNq(YqSUPHUI9yU6YNXyybbKXoH8LHypMRU8zmgwADhJcRqFqxM3ss2GfWn0jnGD)cciJDc5ldXEmxfuYbbbDhJcRq)qxM3ss2GlFgJHPsQlnYyNq(YqSUPHUI9yU6YNXyyrh1DmkSc9bDzEljzdwa3qN0OsQ7fYyNq(YqSUPHUI9yU6YNXyybbDhJcRqFqxM3ss2GfWn0jnVOh0i06YNXyyriJDc5ldX6Mg6k2J5QlFgJHbQUJrHvOpOlZBjjBWc4g6KM00dAeAD5ZymSGGu6ogfwH(GicCfeZvzqAArhrg7eYxgI9yU6YNXyyP1DmkSc9bDzEljzdwa3qN0a29liGm2jKVme7XCvqjhoC4WHdccASOzfQZjx1Swg2lKXoH8LHypMRU8zmg(GGGu6ogfwH(GicCfeZvzqAArs5sKSfMcP4zNWeDu3XOWk0perGRGyUkdstl64rPqg7eYxgI9yUkOebbDhJcRq)qxM3ss2GlFgJHLM6heDezStiFzi2J5QlFgJHL2p1ee0DmkSc9dDzEljzdU8zmgMkPU0iJDc5ldXEmxD5Zym8HdccsP7yuyf6hIiWvqmxLbPPfDukDhJcRq)qebU6Y8wsYMGGUJrHvOFOlZBjjBWLpJXWcc6ogfwH(HUmVLKSblGBOtAsJIUJrHvOpOlZBjjBWc4g6K2HdheDukDhJcRqFWbdDHdbxt6A4eZGZYLQUCGbxgliiLminnmCIzWz5sLCyfiOKdT4HtN0WqDhJcRyGIcPaXCDu(etc8nvmk6ogfw9tIHgLJh1DmkSc9dre4kiMRYG00ccUejBHPqkE2jmr6ogfwH(HicC1L5TKKTdIoIm2jKVmeRBAORypMRckr0rPCjs2ctHu8StyIKs3XOWk0herGRGyUkdstli4sKSfMcP4zNWejLUJrHvOpiIaxDzEljztqq3XOWk0h0L5TKKn4YNXyybbDhJcRq)qebUcI5QminTOJsP7yuyf6dIiWvqmxLbPPfe0DmkSc9dDzEljzdwa3qN0KgfDhJcRqFqxM3ss2GfWn0jTdcc6ogfwH(HicC1L5TKKnrsP7yuyf6dIiWvqmxLbPPfP7yuyf6h6Y8wsYgSaUHoPjnk6ogfwH(GUmVLKSblGBOtAheeKczStiFziw30qxXEmxfuIOJsP7yuyf6dIiWvqmxLbPPfDu3XOWk0p0L5TKKnybCdDsJkPUxiJDc5ldXEmxD5ZymSGaYyNq(YqShZvx(mgdlTUJrHvOFOlZBjjBWc4g6KgWU)dcc6ogfwH(GicCfeZvzqAArh1DmkSc9dre4kiMRYG00I0DmkSc9dDzEljzdwa3qN0KgfDhJcRqFqxM3ss2GfWn0jnrh1DmkSc9dDzEljzdwa3qN0OsQ7fYyNq(YqShZvx(mgdliGm2jKVme7XC1LpJXWsR7yuyf6h6Y8wsYgSaUHoPbS7)GGWrP0DmkSc9dre4kiMRYG00cc6ogfwH(GUmVLKSblGBOtAsJIUJrHvOFOlZBjjBWc4g6K2brh1DmkSc9bDzEljzdUCu8is3XOWk0h0L5TKKnybCdDsJkPU0iJDc5ldXEmxD5ZymSiKXoH8LHypMRU8zmg2lDhJcRqFqxM3ss2GfWn0jnGD)ccsP7yuyf6d6Y8wsYgC5O4r0rDhJcRqFqxM3ss2GlFgJHPsQ7fYyNq(YqSUPHUI9yU6YNXyyriJDc5ldX6Mg6k2J5QlFgJHL2p1eDu3XOWk0p0L5TKKnybCdDsJkPUxiJDc5ldXEmxD5ZymSGGUJrHvOpOlZBjjBWLpJXWuj19czStiFzi2J5QlFgJHfP7yuyf6d6Y8wsYgSaUHoPrL(Ogqrg7eYxgI9yU6YNXyyVqg7eYxgI1nn0vShZvx(mgdliGm2jKVme7XC1LpJXWsR7yuyf6h6Y8wsYgSaUHoPbS7xqazStiFzi2J5QGsoiiO7yuyf6d6Y8wsYgC5ZymmvsDPrg7eYxgI1nn0vShZvx(mgdl6OUJrHvOFOlZBjjBWc4g6KgvsDVqg7eYxgI1nn0vShZvx(mgdliO7yuyf6h6Y8wsYgSaUHoP5f9GgHwx(mgdlczStiFziw30qxXEmxD5Zymmq1DmkSc9dDzEljzdwa3qN0KMEqJqRlFgJHfeKs3XOWk0perGRGyUkdstl6iYyNq(YqShZvx(mgdlTUJrHvOFOlZBjjBWc4g6KgWUFbbKXoH8LHypMRck5WHdhoCqqqJfnRqDo5QM1YWEHm2jKVme7XC1LpJXWheeKs3XOWk0perGRGyUkdstlskxIKTWuifp7eMOJ6ogfwH(GicCfeZvzqAArhpkfYyNq(YqShZvbLiiO7yuyf6d6Y8wsYgC5ZymS0u)GOJiJDc5ldXEmxD5ZymS0(PMGGUJrHvOpOlZBjjBWLpJXWuj1LgzStiFzi2J5QlFgJHpCqqqkDhJcRqFqebUcI5QminTOJsP7yuyf6dIiWvxM3ss2ee0DmkSc9bDzEljzdU8zmgwqq3XOWk0h0L5TKKnybCdDstAu0DmkSc9dDzEljzdwa3qN0oC4GOJsP7yuyf6hoyOlCi4AsxdNygCwUu1Ldm4YybbPKbPPHHtmdolxQKdRabLCGaawc7iaUFQ7TekHsqa]] )


end