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


    spec:RegisterPack( "Marksmanship", 20220315, [[d8KMvcqicXJOQeDjisPnrK(eczuaYPaOvrOk4vaWSGOCleQAxG(fcLHHKQJrvAzuv9meQmnis11qszBqK03OQeghHQY5OQKSoauVdIeuZJQI7bO2hHY)iuvvhKQsklKqLhcGmrcvrUiejQpcrImscvvPtsvjvRKq6LqKGmtQk1njuf1oHi(jej0qHibwkHQkpvsnviQ(kHQqJfjXEH0FvXGv1Hfwmr9yQmzjUmQnJuFgrnAiCAfRMqvv8AKy2Q0TLKDt53IgorCCcvPLR0ZHA6KUoqBhbFhrgpssNNQy9qKI5tW(LAuVOihTUekJIe)u3VFQtCEPg0R4J6IpVO1QhjmATKWrjiZO1wuXO1INJLcUkmmIrcATKWZnJckYrRXj46y0AFz)iuvcgGjgXipkcqzOlRigEQaVHoP52GwjgEQCedTwgCUQVUHkJwxcLrrIFQ73p1joVud6v8rDXh1PgADaQiYfTUEQai0AetPWgQmADHXo0AXZXsbxfggXiPFXFbnL3wuXZX6q0VxQHS(9tD)(BrBrbieHrMXaClkX3psys0jOv6x8JX5La3)G73sT)O)k2HiSX1VIG7pkL063fgXin3B)vHfKzylkX3V4hJ9yoU0FukP1VKDYDup9tAue9xpvau)(Aif4BylkX3VVzTFKc5zNWW9xyShZ1VIGNTFas8eUFCwX6uXyiA9DWkgf5O16ookyePIrroks8IIC0A2c5lxqfhATBhL3jqR14YMcXkhfph60bIHSfYxU0V0(h7qFhYi0(L2VminneRCu8COthigUCvmgUFF6NAO1HtN0qRXkhfphmIurvuK4hf5O1SfYxUGko0A3okVtGwVGgtNlzgkjbDioj9zdKMCp0BqUInfdzlKVCPFP9ldstdPVHhEXNQyPabLGwhoDsdTMYCVhmIurvuKqCOihTMTq(YfuXHw72r5Dc06f0y6CjZqjjOdXjPpBG0K7HEdYvSPyiBH8LlO1HtN0qRPVHhUCWisfvrrcshf5O1SfYxUGko0A3okVtGwdu)UKaBHPqkE2jS(L2VlZBjjzWLXPf6yKpXUjj4YvXy4(9PFYUs)cc9ls)UKaBHPqkE2jS(L2Vi97scSfMcTHmc9qhC)cc97scSfMcTHmc9qhC)s7hO(DzEljjdsAULdwYSJIHlxfJH73N(j7k9li0VlZBjjzqsZTCWsMDumC5QymC)I1pXr9(bSFbH(1yjZkuNk(O5PmC)(0VxQ3VGq)UmVLKKbxgNwOJr(e7MKGlxfJH7xS(9s9(L2F40HaFyJRgg3Vy9tC9dy)s7hO(fP)nMYHjWMcJsbdzQoyf3VGq)BmLdtGnfgLcgUCvmgUFX63x1VGq)I0VljWwykKINDcRFarRdNoPHwxsq5lF0qcQIIeQHIC0A2c5lxqfhATBhL3jqRxqJPZLmdXj4LoxY8HRK5fdzlKVCPFP9RXE0nKaxUkgd3Vp9t2v6xA)UmVLKKbPVXYWLRIXW97t)KDf06WPtAO1AShDdjOkksqQOihTMTq(YfuXHwhoDsdTM(glJw72r5Dc0An2JUHeiOK(L2)cAmDUKziobV05sMpCLmVyiBH8LlO13X4JRGw7NAOkks8fOihToC6KgAntvj3epe4dgrQO1SfYxUGkouffjIpuKJwZwiF5cQ4qRD7O8obATi9VXuomb2uyukyit1bR4(fe6FJPCycSPWOuWWLRIXW9lw)EPE)cc9hoDiWh24QHX9lgW9VXuomb2uyukyOlbnTFXd97hToC6KgAnP5woyjZokgvrrIVcf5O1SfYxUGko0A3okVtGw7Y8wssgCzCAHog5tSBscUCvmgUFF6NSR0V0(bQFr6xJlBkKPQKBIhc8bJiviBH8Ll9li0Vminnu(Mz5cIviOK(bSFbH(fPFxsGTWuifp7ew)cc97Y8wssgCzCAHog5tSBscUCvmgUFX63l17xqOF5eJ7xA)0dze6z5QymC)(0p1qRdNoPHwtkM7yKpXUjjuffjEPokYrRzlKVCbvCO1UDuENaTgO(DzEljjdsiVx2dC5QymC)(0pzxPFbH(fPFnUSPqc59YEGSfYxU0VGq)ASKzfQtfF08ugUFF63R)(bSFP9du)I0)gt5WeytHrPGHmvhSI7xqO)nMYHjWMcJsbdxUkgd3Vy97R6xqO)WPdb(WgxnmUFXaU)nMYHjWMcJsbdDjOP9lEOF)9diAD40jn06LXPf6yKpXUjjuffjE9IIC0A2c5lxqfhATBhL3jqRLbPPHlJtl0XiFIDtsqqj9li0Vi97scSfMcP4zNWqRdNoPHwtiVx2dQIIeV(rroAD40jn0A5y3GmJwZwiF5cQ4qvuK4L4qroAnBH8LlOIdT2TJY7eO1YG00WLXPf6yKpXUjjiOK(fe63L5TKKm4Y40cDmYNy3KeC5QymC)I1VxQ3VGq)I0VljWwykKINDcRFbH(LtmUFP9tpKrONLRIXW97t)(PoAD40jn0ADbzmIurvuK4fPJIC0A2c5lxqfhATBhL3jqRxqJPZLmdXGl5XiFWisfdzlKVCPFP9du)UmVLKKbxgNwOJr(e7MKGlxfJH7xS(9s9(fe6xK(Djb2ctHu8Sty9li0Vi9RXLnfwsq5lF0qcKTq(YL(bSFP9ldstd1DCuoyePIHlxfJH7xmG7NPk7av(OtfJwhoDsdTEdjt5qplJQOiXl1qroAnBH8LlOIdToC6KgADmvC5GrKkATBhL3jqRbQFzqAAOUJJYbJivmC5QymC)IbC)mvzhOYhDQ4(fe6NoDGyUC0DCu41ZXLGM2Vy9t9(bSFP9du)YG00qjl7gmFWisfdljjRFbH(PbV3ZYoeXsMp6uX97t)UaRhDQ4(bq)KDL(fe6xgKMgQliJrKkeus)aIw784U8rJLmRyuK4fvrrIxKkkYrRzlKVCbvCO1UDuENaTMoDG4(bq)UaRNLjZw)(0pD6aXWQGQO1HtN0qRlCOiooebLnQqvuK41xGIC0A2c5lxqfhATBhL3jqRbQFxM3ssYGlJtl0XiFIDtsWLRIXW9lw)EPE)s7FbnMoxYmedUKhJ8bJivmKTq(YL(fe6xK(Djb2ctHu8Sty9li0Vi9VGgtNlzgIbxYJr(GrKkgYwiF5s)cc9ls)ACztHLeu(YhnKazlKVCPFa7xA)YG00qDhhLdgrQy4YvXy4(fd4(zQYoqLp6uXO1HtN0qR3qYuo0ZYOkks8k(qroAnBH8LlOIdT2TJY7eO1YG00qDhhLdgrQyyjjz9li0VminnuYYUbZhmIuXqqj9lTF60bI7xS(Djw7ha9hoDsdgtfxoyePcDjw7xA)a1Vi9RXLnf6qmvbVXbJiviBH8Ll9li0F40HaFyJRgg3Vy9tC9diAD40jn06kWRoyePIQOiXRVcf5O1SfYxUGko0A3okVtGwldstdLSSBW8bJivmeus)s7NoDG4(fRFxI1(bq)HtN0GXuXLdgrQqxI1(L2F40HaFyJRgg3Vp9J0rRdNoPHw7qmvbVXbJivuffj(PokYrRzlKVCbvCO1UDuENaTwgKMgw4OCypmSKKm06WPtAO1uM79GrKkQIIe)ErroAD40jn064ubUfEpj9XTjjmAnBH8LlOIdvrrIF)OihToC6KgAn9n8WLdgrQO1SfYxUGkouffj(jouKJwZwiF5cQ4qRdNoPHwJ5vcB6bRJrgT2TJY7eO1ltVmgriFz0ANh3LpASKzfJIeVOkks8J0rroAnBH8LlOIdT2TJY7eO10Pde3Vy97sS2pa6pC6KgmMkUCWisf6sS2V0(bQFxM3ssYGlJtl0XiFIDtsWLRIXW9lw)uRFbH(fPFxsGTWuifp7ew)aIwhoDsdTUc8QdgrQOkks8tnuKJwZwiF5cQ4qRD7O8obA9cAmDUKzOXy8yKjfRh8r3qIKXiFcjsInuqmKTq(Yf06WPtAO1AShDdjOkks8JurroAnBH8LlOIdT2TJY7eO1lOX05sMHgJXJrMuSEWhDdjsgJ8jKij2qbXq2c5lxqRdNoPHwtVmJ0mg5JUHeuffj(9fOihTMTq(YfuXHw72r5Dc0AzqAAOUGmgrQWssYqRdNoPHwlhKpj9r3XrbJQOiXV4df5O1SfYxUGko0A3okVtGwJtWR8yfOeqScE5dVGs0jniBH8Ll9lTFzqAAOUGmgrQWssYqRdNoPHwtFzmc3g0kQIIe)(kuKJwhoDsdTgRCu8CWisfTMTq(YfuXHQOkADHPdWRIICuK4ff5O1HtN0qRDjOP8EWisfTMTq(YfuXHQOiXpkYrRzlKVCbvCO1HtN0qRDjOP8EWisfT2TJY7eO1lOX05sMHywccqKg8rYMUBuf6KgKTq(YL(fe6hNGx5XkqB8e4JM5fFKKdoniBH8Ll9li0pq97sRaokCzc8IJ7jPp05QGgdzlKVCPFP9ls)lOX05sMHywccqKg8rYMUBuf6KgKTq(YL(beT(ogFCf0AIJ6OkksiouKJwZwiF5cQ4qRdNoPHwRByIxW5oinJr(GrKkADHXUDKOtAO1iLY(deCu6pSs)iFdt8co3bPH7hjifaq9Zgxnmgz9tI7VKgrA)LSFfXG7No3(LCdp8I7xMDbiM7FuIk9lZ9Rz2pwsuv5P)Wk9tI73fgrA)lhL56PFKVHjE7hlHDd946xgKMgdrRD7O8obATi9RXsMv4GpsUHhErvuKG0rroAnBH8LlOIdT2TJY7eO1UKaBHPqkE2jS(L2VlZBjjzqDbzmIuHlxfJH7xA)UmVLKKbxgNwOJr(e7MKGlxfJH7xqOFr63LeylmfsXZoH1V0(DzEljjdQliJrKkC5QymmAD40jn0AxCVNWPtAN7Gv067G1JfvmATUJrHvmQIIeQHIC0A2c5lxqfhAD40jn0AxCVNWPtAN7Gv067G1JfvmATRGrvuKGurroAnBH8LlOIdT2TJY7eO1Hthc8HnUAyC)(0pXHwJ1DCkks8IwhoDsdT2f37jC6K25oyfT(oy9yrfJwJvuffj(cuKJwZwiF5cQ4qRD7O8obAD40HaFyJRgg3Vy97hTgR74uuK4fToC6KgATlU3t40jTZDWkA9DW6XIkgTw3XrbJivmQIQO1sw2LvYHIICuK4ff5O1HtN0qRLtvVC5qFdpCH0yKpAs1XqRzlKVCbvCOkks8JIC06WPtAO10xgJWTbTIwZwiF5cQ4qvuKqCOihTMTq(YfuXHw72r5Dc06f0y6CjZqCcEPZLmF4kzEXq2c5lxqRdNoPHwRXE0nKGQOibPJIC0A2c5lxqfhATKLDbwp6uXO1EPoAD40jn06sckF5JgsqRD7O8obAD40HaFyJRgg3Vy97TFbH(fPFxsGTWuifp7ew)s7xK(14YMcjK3l7bYwiF5cQIIeQHIC0A2c5lxqfhATBhL3jqRdNoe4dBC1W4(9PFIRFP9du)I0VljWwykKINDcRFP9ls)ACztHeY7L9azlKVCPFbH(dNoe4dBC1W4(9PF)9diAD40jn06yQ4YbJivuffjivuKJwZwiF5cQ4qRD7O8obAD40HaFyJRgg3Vy97VFbH(bQFxsGTWuifp7ew)cc9RXLnfsiVx2dKTq(YL(bSFP9hoDiWh24QHX9dC)(rRdNoPHwJvokEoyePIQOkATRGrroks8IIC0A2c5lxqfhATBhL3jqRbQFzqAAOUGmgrQqqj9lTFzqAA4Y40cDmYNy3Keeus)s73LeylmfsXZoH1pG9li0pq9ldstd1fKXisfckPFP9ldstdjn3Yblz2rXqqj9lTFxsGTWuOnKrOh6G7hW(fe6hO(Djb2ctHeytr4z7xqOFxsGTWuOXUnV5w6hW(L2VminnuxqgJiviOK(fe6xoX4(L2p9qgHEwUkgd3Vp97L46xqOFG63LeylmfsXZoH1V0(LbPPHlJtl0XiFIDtsqqj9lTF6Hmc9SCvmgUFF63xqC9diAD40jn0AzEX8szmYOkks8JIC0A2c5lxqfhATBhL3jqRLbPPH6cYyePcbL0VGq)UmVLKKb1fKXisfUCvmgUFX6N4OE)cc9lNyC)s7NEiJqplxfJH73N(9IurRdNoPHwlFZSCObxpOkksiouKJwZwiF5cQ4qRD7O8obATminnuxqgJiviOK(fe63L5TKKmOUGmgrQWLRIXW9lw)eh17xqOF5eJ7xA)0dze6z5QymC)(0VxKkAD40jn06WCmw34ECX9IQOibPJIC0A2c5lxqfhATBhL3jqRLbPPH6cYyePcbL0VGq)UmVLKKb1fKXisfUCvmgUFX6N4OE)cc9lNyC)s7NEiJqplxfJH73N(9vO1HtN0qRPNLLVzwqvuKqnuKJwZwiF5cQ4qRD7O8obATminnuxqgJivyjjzO1HtN0qRVdzek(i(dyHCfBkQIIeKkkYrRzlKVCbvCO1UDuENaTwgKMgQliJrKkeus)s7hO(LbPPHY3mlxqScbL0VGq)ASKzfIGJRIakXP97t)(PE)a2VGq)Yjg3V0(PhYi0ZYvXy4(9PF)i1(fe6hO(Djb2ctHu8Sty9lTFzqAA4Y40cDmYNy3Keeus)s7NEiJqplxfJH73N(9f(7hq06WPtAO1ssDsdvrv0ASIICuK4ff5O1SfYxUGko0A3okVtGwRXLnfIvokEo0PdedzlKVCPFP9du)swMWHSRa9cXkhfphmIu7xA)YG00qSYrXZHoDGy4YvXy4(9PFQ1VGq)YG00qSYrXZHoDGyyjjz9dy)s7hO(LbPPHlJtl0XiFIDtsWssY6xqOFr63LeylmfsXZoH1pGO1HtN0qRXkhfphmIurvuK4hf5O1HtN0qRPm37bJiv0A2c5lxqfhQIIeIdf5O1SfYxUGko0A3okVtGwdu)UKaBHPqkE2jS(L2pq97Y8wssgCzCAHog5tSBscUCvmgUFF6NSR0pG9li0Vi97scSfMcP4zNW6xA)I0VljWwyk0gYi0dDW9li0VljWwyk0gYi0dDW9lTFG63L5TKKmiP5woyjZokgUCvmgUFF6NSR0VGq)UmVLKKbjn3Yblz2rXWLRIXW9lw)eh17hW(fe6NEiJqplxfJH73N(9sT(bSFP9du)I0)gt5WeytHrPGHmvhSI7xqO)nMYHjWMcJsbdbL0V0(bQ)nMYHjWMcJsbdhRFF63l17xA)BmLdtGnfgLcgUCvmgUFF6N46xqO)nMYHjWMcJsbdhRFX6pC6K2XL5TKKS(fe6pC6qGpSXvdJ7xS(92pG9li0Vi9VXuomb2uyukyiOK(L2pq9VXuomb2uyukyOlbnTFG73B)cc9VXuomb2uyuky4y9lw)HtN0oUmVLKK1pG9diAD40jn06sckF5JgsqvuKG0rroAnBH8LlOIdT2TJY7eO1AShDdjqqj9lT)f0y6CjZqCcEPZLmF4kzEXq2c5lxqRdNoPHwtFJLrvuKqnuKJwZwiF5cQ4qRD7O8obA9cAmDUKziobV05sMpCLmVyiBH8Ll9lTFn2JUHe4YvXy4(9PFYUs)s73L5TKKmi9nwgUCvmgUFF6NSRGwhoDsdTwJ9OBibvrrcsff5O1HtN0qRzQk5M4HaFWisfTMTq(YfuXHQOiXxGIC0A2c5lxqfhATBhL3jqRbQFxM3ssYG6cYyePcxUkgd3Vp9t2v6xqOFzqAAOUGmgrQqqj9dy)s7hO(fP)nMYHjWMcJsbdzQoyf3VGq)I0)gt5WeytHrPGHGs6xA)BmLdtGnfgLcgwa3qN06ha9VXuomb2uyuky4y97t)(PE)cc9VXuomb2uyukyiOK(L2)gt5WeytHrPGHlxfJH7xS(96R6xqO)WPdb(WgxnmUFX63B)a2VGq)0dze6z5QymC)(0V4J6O1HtN0qRjn3Yblz2rXOkkseFOihToC6KgAn9n8WLdgrQO1SfYxUGkouffj(kuKJwZwiF5cQ4qRD7O8obAnD6aX9dG(DbwpltMT(9PF60bIHvbvrRdNoPHwx4qrCCickBuHQOiXl1rroAD40jn064ubUfEpj9XTjjmAnBH8LlOIdvrrIxVOihTMTq(YfuXHw72r5Dc0AxM3ssYGlJtl0XiFIDtsWLRIXW97t)KDL(L2pq9ls)ACztHmvLCt8qGpyePczlKVCPFbH(LbPPHY3mlxqScbL0pG9li0Vi97scSfMcP4zNW6xqOFxM3ssYGlJtl0XiFIDtsWLRIXW9li0VCIX9lTF6Hmc9SCvmgUFF6NAO1HtN0qRjfZDmYNy3KeQIIeV(rroAnBH8LlOIdT2TJY7eO1a1VminnSKGYx(OHeiOK(fe6xK(14YMcljO8LpAibYwiF5s)cc9tpKrONLRIXW97t)E93pG9lTFG6xK(3ykhMaBkmkfmKP6GvC)cc9ls)BmLdtGnfgLcgckPFP9du)BmLdtGnfgLcgwa3qN06ha9VXuomb2uyuky4y97t)EPE)cc9VXuomb2uyukyOlbnTFG73B)a2VGq)BmLdtGnfgLcgckPFP9VXuomb2uyuky4YvXy4(fRFFv)cc9hoDiWh24QHX9lw)E7hq06WPtAO1lJtl0XiFIDtsOkks8sCOihTMTq(YfuXHw72r5Dc0AzqAA4Y40cDmYNy3Keeus)cc9ls)UKaBHPqkE2jS(L2pq9ldstdLSSBW8bJivmSKKS(fe6xK(14YMcDiMQG34GrKkKTq(YL(fe6pC6qGpSXvdJ73N(93pGO1HtN0qRjK3l7bvrrIxKokYrRzlKVCbvCO1UDuENaT2LeylmfsXZoH1V0(PthiUFa0VlW6zzYS1Vp9tNoqmSkOA)s7hO(bQFxM3ssYGlJtl0XiFIDtsWLRIXW97t)KDL(fp0pX1V0(bQFr6hNGx5XkqMMgepe4tytvCcNJV8gAUq2c5lx6xqOFr6xJlBkSKGYx(OHeiBH8Ll9dy)a2VGq)ACztHLeu(YhnKazlKVCPFP97Y8wssgSKGYx(OHe4YvXy4(9PFIRFarRdNoPHwJvokEoyePIQOiXl1qroAnBH8LlOIdT2TJY7eO1lOX05sMHyWL8yKpyePIHSfYxU0V0(14YMcX6Yr1DmgYwiF5s)s7hO(DzEljjdUmoTqhJ8j2njbxUkgd3Vy97L69li0Vi97scSfMcP4zNW6xqOFr6xJlBkSKGYx(OHeiBH8Ll9li0pobVYJvGmnniEiWNWMQ4eohF5n0CHSfYxU0pGO1HtN0qR3qYuo0ZYOkks8IurroAnBH8LlOIdT2TJY7eO1ywpYPbIH6WRFX3bPlX1V0(LbPPH6ookhmIuXWssY6xA)0PdeZLJUJJcVEoUe00(9PFQ1V0(LbPPHsw2ny(GrKkgckbToC6KgATdXuf8ghmIurvuK41xGIC0A2c5lxqfhATBhL3jqRXSEKtded1Hx)IVdsxIRFP9ldstd1DCuoyePIHLKK1V0(PthiMlhDhhfE9CCjOP97t)uRFP9ldstdLSSBW8bJivmeucAD40jn06yDHXhmIurvuK4v8HIC0A2c5lxqfhATBhL3jqRbQFG6xgKMgkzz3G5dgrQyyjjz9li0Vgx2uOlU3XiFue8bJivmKTq(YL(bSFP97scSfMcjWMIWZ2VGq)UKaBHPqJDBEZT0VGq)UmVLKKbxgNwOJr(e7MKGlxfJH7xS(joQ3VGq)UmVLKKbxgNwOJr(e7MKGlxfJH73N(9s9(fe63L5TKKmiP5woyjZokgUCvmgUFX6N4OE)cc9ldstdjn3Yblz2rXqqj9dy)cc9ldstdjK3l7bckPFP9hoDiWh24QHX9lw)E7xqOF5eJ7xA)0dze6z5QymC)(0VFQHwhoDsdTwxqgJivuffjE9vOihTMTq(YfuXHwhoDsdToMkUCWisfT2TJY7eO1YG00qjl7gmFWisfdljjRFbH(bQFzqAAOUGmgrQqqj9li0pn49Ew2HiwY8rNkUFF6NSR0pa63fy9Otf3pG9lTFG6xK(14YMcDiMQG34GrKkKTq(YL(fe6pC6qGpSXvdJ73N(93pG9li0Vminnu3Xr5GrKkgUCvmgUFX6NPk7av(Otf3V0(dNoe4dBC1W4(fRFVO1opUlF0yjZkgfjErvuK4N6OihTMTq(YfuXHw72r5Dc0AG63L5TKKm4Y40cDmYNy3KeC5QymC)I1VxQ3VGq)I0VljWwykKINDcRFbH(fPFnUSPWsckF5JgsGSfYxU0VGq)4e8kpwbY00G4HaFcBQIt4C8L3qZfYwiF5s)a2V0(PthiUFa0VlW6zzYS1Vp9tNoqmSkOA)s7hO(LbPPHLeu(YhnKaljjRFP9ldstd5G8L14Mg(OliFOthigwssw)cc9RXLnfI1LJQ7ymKTq(YL(beToC6KgA9gsMYHEwgvrrIFVOihTMTq(YfuXHw72r5Dc0AzqAAOKLDdMpyePIHGs6xqOF60bI7xS(Djw7ha9hoDsdgtfxoyePcDjwrRdNoPHw7qmvbVXbJivuffj(9JIC0A2c5lxqfhATBhL3jqRLbPPHsw2ny(GrKkgckPFbH(PthiUFX63LyTFa0F40jnymvC5GrKk0LyfToC6KgADSUW4dgrQOkks8tCOihTMTq(YfuXHwhoDsdTgZRe20dwhJmATBhL3jqRxMEzmIq(Y9lTFnwYSc1PIpAEkd3Vy9xa3qN0qRDECx(OXsMvmks8IQOiXpshf5O1SfYxUGko0A3okVtGwhoDiWh24QHX9lw)ErRdNoPHwlh7gKzuffj(PgkYrRzlKVCbvCO1UDuENaTgO(DzEljjdUmoTqhJ8j2njbxUkgd3Vy97L69lT)f0y6CjZqm4sEmYhmIuXq2c5lx6xqOFr63LeylmfsXZoH1VGq)I0Vgx2uyjbLV8rdjq2c5lx6xqOFCcELhRazAAq8qGpHnvXjCo(YBO5czlKVCPFa7xA)0Pde3pa63fy9Smz263N(PthigwfuTFP9du)YG00WsckF5JgsGLKK1VGq)ACztHyD5O6ogdzlKVCPFarRdNoPHwVHKPCONLrvuK4hPIIC0A2c5lxqfhATBhL3jqRLbPPH6cYyePcljjdToC6KgATCq(K0hDhhfmQIIe)(cuKJwZwiF5cQ4qRD7O8obAnobVYJvGsaXk4Lp8ckrN0GSfYxU0V0(LbPPH6cYyePcljjdToC6KgAn9LXiCBqROkks8l(qroAD40jn0ASYrXZbJiv0A2c5lxqfhQIQO16ogfwXOihfjErroAnBH8LlOIdToLGwJzfToC6KgAnHyNq(YO1eIliJwldstdxgNwOJr(e7MKGGs6xqOFzqAAOUGmgrQqqjO1eI9yrfJwJ9yUdOeuffj(rroAnBH8LlOIdToLGwJzfToC6KgAnHyNq(YO1eIliJw7scSfMcP4zNW6xA)YG00WLXPf6yKpXUjjiOK(L2VminnuxqgJiviOK(fe6xK(Djb2ctHu8Sty9lTFzqAAOUGmgrQqqjO1eI9yrfJwJ1nnYhShZDaLGQOiH4qroAnBH8LlOIdToLGwJzDOrRdNoPHwti2jKVmAnHypwuXO1yDtJ8b7XCNLRIXWO1UDuENaTwgKMgQliJrKkSKKm0AcXfKp8fZO1UmVLKKb1fKXisfUCvmg(qgKXy0AcXfKrRDzEljjdUmoTqhJ8j2njbxUkgd3VpI)73L5TKKmOUGmgrQWLRIXWhYGmgJQOibPJIC0A2c5lxqfhADkbTgZ6qJwhoDsdTMqStiFz0AcXESOIrRX6Mg5d2J5olxfJHrRD7O8obATminnuxqgJiviOe0AcXfKp8fZO1UmVLKKb1fKXisfUCvmg(qgKXy0AcXfKrRDzEljjdUmoTqhJ8j2njbxUkgdJQOiHAOihTMTq(YfuXHwNsqRXSo0O1HtN0qRje7eYxgTMqShlQy0AShZDwUkgdJw72r5Dc0AxsGTWuifp7egAnH4cYh(Iz0AxM3ssYG6cYyePcxUkgdFidYymAnH4cYO1UmVLKKbxgNwOJr(e7MKGlxfJH7xmX)97Y8wssguxqgJiv4YvXy4dzqgJrvuKGurroAnBH8LlOIdToC6KgATUJrHvVO1UDuENaTgO(bQFDhJcRq1lerGpGy(idst3VGq)UKaBHPqkE2jS(L2VUJrHvO6fIiWhxM3ssY6hW(L2pq9ti2jKVmeRBAKpypM7akPFP9du)I0VljWwykKINDcRFP9ls)6ogfwHQFiIaFaX8rgKMUFbH(Djb2ctHu8Sty9lTFr6x3XOWku9dre4JlZBjjz9li0VUJrHvO6h6Y8wssgC5QymC)cc9R7yuyfQEHic8beZhzqA6(L2pq9ls)6ogfwHQFiIaFaX8rgKMUFbH(1DmkScvVqxM3ssYGfWn0jT(fd4(1DmkScv)qxM3ssYGfWn0jT(bSFbH(1DmkScvVqeb(4Y8wssw)s7xK(1DmkScv)qeb(aI5JminD)s7x3XOWku9cDzEljjdwa3qN06xmG7x3XOWku9dDzEljjdwa3qN06hW(fe6xK(je7eYxgI1nnYhShZDaL0V0(bQFr6x3XOWku9dre4diMpYG009lTFG6x3XOWku9cDzEljjdwa3qN06N47NA97t)eIDc5ldXEm3z5QymC)cc9ti2jKVme7XCNLRIXW9lw)6ogfwHQxOlZBjjzWc4g6Kw)eRF)9dy)cc9R7yuyfQ(Hic8beZhzqA6(L2pq9R7yuyfQEHic8beZhzqA6(L2VUJrHvO6f6Y8wssgSaUHoP1Vya3VUJrHvO6h6Y8wssgSaUHoP1V0(bQFDhJcRq1l0L5TKKmybCdDsRFIVFQ1Vp9ti2jKVme7XCNLRIXW9li0pHyNq(YqShZDwUkgd3Vy9R7yuyfQEHUmVLKKblGBOtA9tS(93pG9li0pq9ls)6ogfwHQxiIaFaX8rgKMUFbH(1DmkScv)qxM3ssYGfWn0jT(fd4(1DmkScvVqxM3ssYGfWn0jT(bSFP9du)6ogfwHQFOlZBjjzWLJIN(L2VUJrHvO6h6Y8wssgSaUHoP1pX3p16xS(je7eYxgI9yUZYvXy4(L2pHyNq(YqShZDwUkgd3Vp9R7yuyfQ(HUmVLKKblGBOtA9tS(93VGq)I0VUJrHvO6h6Y8wssgC5O4PFP9du)6ogfwHQFOlZBjjzWLRIXW9t89tT(9PFcXoH8LHyDtJ8b7XCNLRIXW9lTFcXoH8LHyDtJ8b7XCNLRIXW9lw)(PE)s7hO(1DmkScvVqxM3ssYGfWn0jT(j((Pw)(0pHyNq(YqShZDwUkgd3VGq)6ogfwHQFOlZBjjzWLRIXW9t89tT(9PFcXoH8LHypM7SCvmgUFP9R7yuyfQ(HUmVLKKblGBOtA9t897L69dG(je7eYxgI9yUZYvXy4(9PFcXoH8LHyDtJ8b7XCNLRIXW9li0pHyNq(YqShZDwUkgd3Vy9R7yuyfQEHUmVLKKblGBOtA9tS(93VGq)eIDc5ldXEm3bus)a2VGq)6ogfwHQFOlZBjjzWLRIXW9t89tT(fRFcXoH8LHyDtJ8b7XCNLRIXW9lTFG6x3XOWku9cDzEljjdwa3qN06N47NA97t)eIDc5ldX6Mg5d2J5olxfJH7xqOFDhJcRq1l0L5TKKmybCdDsRFF6NEiJqplxfJH7xA)eIDc5ldX6Mg5d2J5olxfJH7ha9R7yuyfQEHUmVLKKblGBOtA9lw)0dze6z5QymC)cc9ls)6ogfwHQxiIaFaX8rgKMUFP9du)eIDc5ldXEm3z5QymC)I1VUJrHvO6f6Y8wssgSaUHoP1pX63F)cc9ti2jKVme7XChqj9dy)a2pG9dy)a2pG9li0VglzwH6uXhnpLH73N(je7eYxgI9yUZYvXy4(bSFbH(fPFDhJcRq1lerGpGy(idst3V0(fPFxsGTWuifp7ew)s7hO(1DmkScv)qeb(aI5JminD)s7hO(bQFr6NqStiFzi2J5oGs6xqOFDhJcRq1p0L5TKKm4YvXy4(fRFQ1pG9lTFG6NqStiFzi2J5olxfJH7xS(9t9(fe6x3XOWku9dDzEljjdUCvmgUFIVFQ1Vy9ti2jKVme7XCNLRIXW9dy)a2VGq)I0VUJrHvO6hIiWhqmFKbPP7xA)a1Vi9R7yuyfQ(Hic8XL5TKKS(fe6x3XOWku9dDzEljjdUCvmgUFbH(1DmkScv)qxM3ssYGfWn0jT(fd4(1DmkScvVqxM3ssYGfWn0jT(bSFa7hW(L2pq9ls)6ogfwHQx4GHUWHGpj9jCIxWz5YrxoWGlJ7xqOFr6xgKMggoXl4SC5qkSceus)aIwJVPIrR1DmkS6fvrrIVaf5O1SfYxUGko06WPtAO16ogfw9Jw72r5Dc0AG6hO(1DmkScv)qeb(aI5JminD)cc97scSfMcP4zNW6xA)6ogfwHQFiIaFCzEljjRFa7xA)a1pHyNq(YqSUPr(G9yUdOK(L2pq9ls)UKaBHPqkE2jS(L2Vi9R7yuyfQEHic8beZhzqA6(fe63LeylmfsXZoH1V0(fPFDhJcRq1lerGpUmVLKK1VGq)6ogfwHQxOlZBjjzWLRIXW9li0VUJrHvO6hIiWhqmFKbPP7xA)a1Vi9R7yuyfQEHic8beZhzqA6(fe6x3XOWku9dDzEljjdwa3qN06xmG7x3XOWku9cDzEljjdwa3qN06hW(fe6x3XOWku9dre4JlZBjjz9lTFr6x3XOWku9cre4diMpYG009lTFDhJcRq1p0L5TKKmybCdDsRFXaUFDhJcRq1l0L5TKKmybCdDsRFa7xqOFr6NqStiFziw30iFWEm3bus)s7hO(fPFDhJcRq1lerGpGy(idst3V0(bQFDhJcRq1p0L5TKKmybCdDsRFIVFQ1Vp9ti2jKVme7XCNLRIXW9li0pHyNq(YqShZDwUkgd3Vy9R7yuyfQ(HUmVLKKblGBOtA9tS(93pG9li0VUJrHvO6fIiWhqmFKbPP7xA)a1VUJrHvO6hIiWhqmFKbPP7xA)6ogfwHQFOlZBjjzWc4g6Kw)IbC)6ogfwHQxOlZBjjzWc4g6Kw)s7hO(1DmkScv)qxM3ssYGfWn0jT(j((Pw)(0pHyNq(YqShZDwUkgd3VGq)eIDc5ldXEm3z5QymC)I1VUJrHvO6h6Y8wssgSaUHoP1pX63F)a2VGq)a1Vi9R7yuyfQ(Hic8beZhzqA6(fe6x3XOWku9cDzEljjdwa3qN06xmG7x3XOWku9dDzEljjdwa3qN06hW(L2pq9R7yuyfQEHUmVLKKbxokE6xA)6ogfwHQxOlZBjjzWc4g6Kw)eF)uRFX6NqStiFzi2J5olxfJH7xA)eIDc5ldXEm3z5QymC)(0VUJrHvO6f6Y8wssgSaUHoP1pX63F)cc9ls)6ogfwHQxOlZBjjzWLJIN(L2pq9R7yuyfQEHUmVLKKbxUkgd3pX3p163N(je7eYxgI1nnYhShZDwUkgd3V0(je7eYxgI1nnYhShZDwUkgd3Vy97N69lTFG6x3XOWku9dDzEljjdwa3qN06N47NA97t)eIDc5ldXEm3z5QymC)cc9R7yuyfQEHUmVLKKbxUkgd3pX3p163N(je7eYxgI9yUZYvXy4(L2VUJrHvO6f6Y8wssgSaUHoP1pX3VxQ3pa6NqStiFzi2J5olxfJH73N(je7eYxgI1nnYhShZDwUkgd3VGq)eIDc5ldXEm3z5QymC)I1VUJrHvO6h6Y8wssgSaUHoP1pX63F)cc9ti2jKVme7XChqj9dy)cc9R7yuyfQEHUmVLKKbxUkgd3pX3p16xS(je7eYxgI1nnYhShZDwUkgd3V0(bQFDhJcRq1p0L5TKKmybCdDsRFIVFQ1Vp9ti2jKVmeRBAKpypM7SCvmgUFbH(1DmkScv)qxM3ssYGfWn0jT(9PF6Hmc9SCvmgUFP9ti2jKVmeRBAKpypM7SCvmgUFa0VUJrHvO6h6Y8wssgSaUHoP1Vy9tpKrONLRIXW9li0Vi9R7yuyfQ(Hic8beZhzqA6(L2pq9ti2jKVme7XCNLRIXW9lw)6ogfwHQFOlZBjjzWc4g6Kw)eRF)9li0pHyNq(YqShZDaL0pG9dy)a2pG9dy)a2VGq)ASKzfQtfF08ugUFF6NqStiFzi2J5olxfJH7hW(fe6xK(1DmkScv)qeb(aI5JminD)s7xK(Djb2ctHu8Sty9lTFG6x3XOWku9cre4diMpYG009lTFG6hO(fPFcXoH8LHypM7akPFbH(1DmkScvVqxM3ssYGlxfJH7xS(Pw)a2V0(bQFcXoH8LHypM7SCvmgUFX63p17xqOFDhJcRq1l0L5TKKm4YvXy4(j((Pw)I1pHyNq(YqShZDwUkgd3pG9dy)cc9ls)6ogfwHQxiIaFaX8rgKMUFP9du)I0VUJrHvO6fIiWhxM3ssY6xqOFDhJcRq1l0L5TKKm4YvXy4(fe6x3XOWku9cDzEljjdwa3qN06xmG7x3XOWku9dDzEljjdwa3qN06hW(bSFa7xA)a1Vi9R7yuyfQ(Hdg6chc(K0NWjEbNLlhD5adUmUFbH(fPFzqAAy4eVGZYLdPWkqqj9diAn(MkgTw3XOWQFufvrv0Ac8IN0qrIFQ73p1joQJurRjfRngzmAT4rFnXpK4RJeKsaC)9JCeC)tLKC1(PZTFI0DCuWisftu)llEbNLl9JZkU)auZQq5s)oeHrMXWwuFpg3VxaUFaknc8QCPFI04YMcPcr9Rz)ePXLnfsfiBH8Lle1pqEPkGWwuFpg3VFaUFaknc8QCPFIwqJPZLmdPcr9Rz)eTGgtNlzgsfiBH8Lle1pqEPkGWwuFpg3pXbW9dqPrGxLl9t0cAmDUKziviQFn7NOf0y6CjZqQazlKVCHO(dTFKYif9D)a5LQacBr99yC)udG7hGsJaVkx6NOf0y6CjZqQqu)A2prlOX05sMHubYwiF5cr9dKxQciSf13JX9Jub4(bO0iWRYL(jAbnMoxYmKke1VM9t0cAmDUKzivGSfYxUqu)H2pszKI(UFG8svaHTO(EmUFFfa3paLgbEvU0prACztHuHO(1SFI04YMcPcKTq(YfI6hiVufqylQVhJ73l1b4(bO0iWRYL(jsJlBkKke1VM9tKgx2uivGSfYxUqu)a5LQacBr99yC)Er6aC)auAe4v5s)ePXLnfsfI6xZ(jsJlBkKkq2c5lxiQFG8svaHTO(EmUFViDaUFaknc8QCPFIwqJPZLmdPcr9Rz)eTGgtNlzgsfiBH8Lle1pqEPkGWwuFpg3VxFba3paLgbEvU0prACztHuHO(1SFI04YMcPcKTq(YfI6hiVufqylQVhJ73RVaG7hGsJaVkx6NOf0y6CjZqQqu)A2prlOX05sMHubYwiF5cr9dKFQciSf13JX97v8bW9dqPrGxLl9tKgx2uiviQFn7NinUSPqQazlKVCHO(bYlvbe2I67X4(9tnaUFaknc8QCPFIwqJPZLmdPcr9Rz)eTGgtNlzgsfiBH8Lle1FO9JugPOV7hiVufqylQVhJ73psfG7hGsJaVkx6NOf0y6CjZqQqu)A2prlOX05sMHubYwiF5cr9hA)iLrk67(bYlvbe2I67X4(9l(a4(bO0iWRYL(jcNGx5XkqQqu)A2pr4e8kpwbsfiBH8Lle1pqEPkGWw0wuXJ(AIFiXxhjiLa4(7h5i4(Nkj5Q9tNB)evy6a8Qe1)YIxWz5s)4SI7pa1SkuU0VdryKzmSf13JX97hG7hGsJaVkx6NOf0y6CjZqQqu)A2prlOX05sMHubYwiF5cr9dKxQciSf13JX97hG7hGsJaVkx6NOf0y6CjZqQqu)A2prlOX05sMHubYwiF5cr9dKxQciSf13JX97hG7hGsJaVkx6NixAfWrHuHO(1SFICPvahfsfiBH8Lle1pqEPkGWwuFpg3VFaUFaknc8QCPFIWj4vEScKke1VM9teobVYJvGubYwiF5cr9dKxQciSfTfv8OVM4hs81rcsjaU)(rocU)PssUA)052prsw2LvYHsu)llEbNLl9JZkU)auZQq5s)oeHrMXWwuFpg3pXbW9dqPrGxLl9t0cAmDUKziviQFn7NOf0y6CjZqQazlKVCHO(dTFKYif9D)a5LQacBr99yC)iDaUFaknc8QCPFI04YMcPcr9Rz)ePXLnfsfiBH8Lle1FO9JugPOV7hiVufqylQVhJ7NAaC)auAe4v5s)ePXLnfsfI6xZ(jsJlBkKkq2c5lxiQFG8svaHTO(EmUFKka3paLgbEvU0prACztHuHO(1SFI04YMcPcKTq(YfI6hiVufqylAlQ4rFnXpK4RJeKsaC)9JCeC)tLKC1(PZTFIWkr9VS4fCwU0poR4(dqnRcLl97qegzgdBr99yC)Eb4(bO0iWRYL(jsJlBkKke1VM9tKgx2uivGSfYxUqu)a5LQacBr99yC)iDaUFaknc8QCPFIwqJPZLmdPcr9Rz)eTGgtNlzgsfiBH8Lle1FO9JugPOV7hiVufqylQVhJ7NAaC)auAe4v5s)eTGgtNlzgsfI6xZ(jAbnMoxYmKkq2c5lxiQFG8svaHTO(EmUFVEb4(bO0iWRYL(jsJlBkKke1VM9tKgx2uivGSfYxUqu)a5LQacBr99yC)E9dW9dqPrGxLl9tKgx2uiviQFn7NinUSPqQazlKVCHO(bYlvbe2I67X4(9sCaC)auAe4v5s)ePXLnfsfI6xZ(jsJlBkKkq2c5lxiQFG8svaHTO(EmUFViDaUFaknc8QCPFI04YMcPcr9Rz)ePXLnfsfiBH8Lle1pq(PkGWwuFpg3VxKoa3paLgbEvU0pr4e8kpwbsfI6xZ(jcNGx5XkqQazlKVCHO(bYlvbe2I67X4(9snaUFaknc8QCPFI04YMcPcr9Rz)ePXLnfsfiBH8Lle1pq(PkGWwuFpg3VxQbW9dqPrGxLl9t0cAmDUKziviQFn7NOf0y6CjZqQazlKVCHO(bYlvbe2I67X4(9snaUFaknc8QCPFIWj4vEScKke1VM9teobVYJvGubYwiF5cr9dKxQciSf13JX97v8bW9dqPrGxLl9tKgx2uiviQFn7NinUSPqQazlKVCHO(bYlvbe2I67X4(96Ra4(bO0iWRYL(jsJlBkKke1VM9tKgx2uivGSfYxUqu)a5LQacBr99yC)(Poa3paLgbEvU0prACztHuHO(1SFI04YMcPcKTq(YfI6hi)ufqylQVhJ73p1b4(bO0iWRYL(jcNGx5XkqQqu)A2pr4e8kpwbsfiBH8Lle1pqEPkGWwuFpg3VFQbW9dqPrGxLl9tKgx2uiviQFn7NinUSPqQazlKVCHO(bYpvbe2I67X4(9tnaUFaknc8QCPFIwqJPZLmdPcr9Rz)eTGgtNlzgsfiBH8Lle1pqEPkGWwuFpg3VFQbW9dqPrGxLl9teobVYJvGuHO(1SFIWj4vEScKkq2c5lxiQFG8svaHTO(EmUF)(caUFaknc8QCPFIWj4vEScKke1VM9teobVYJvGubYwiF5cr9dKxQciSfTfv8OVM4hs81rcsjaU)(rocU)PssUA)052pr6ogfwXe1)YIxWz5s)4SI7pa1SkuU0VdryKzmSf13JX9Jub4(bO0iWRYL(RNkaQFShtdQ2psB)A2VVbJ(ldHbpP1FkH3qZTFGigG9de1OkGWwuFpg3psfG7hGsJaVkx6NiDhJcRqVqQqu)A2pr6ogfwHQxiviQFG8J0PkGWwuFpg3psfG7hGsJaVkx6NiDhJcRq)qQqu)A2pr6ogfwHQFiviQFG8JuPkGWwuFpg3VVaG7hGsJaVkx6VEQaO(XEmnOA)iT9Rz)(gm6Vmeg8Kw)PeEdn3(bIya2pquJQacBr99yC)(caUFaknc8QCPFI0DmkSc9cPcr9Rz)eP7yuyfQEHuHO(bYpsLQacBr99yC)(caUFaknc8QCPFI0DmkSc9dPcr9Rz)eP7yuyfQ(HuHO(bYpsNQacBrBr91RKKRYL(rQ9hoDsR)7GvmSffTglHDOiXp1q6O1s2KEUmATV0x2V45yPGRcdJyK0V4VGMYBlQV0x2V45yDi63l1qw)(PUF)TOTO(sFz)aeIWiZyaUf1x6l7N47hjmj6e0k9l(X48sG7FW9BP2F0Ff7qe246xrW9hLsA97cJyKM7T)QWcYmSf1x6l7N47x8JXEmhx6pkL06xYo5oQN(jnkI(RNkaQFFnKc8nSf1x6l7N4733S2psH8Sty4(lm2J56xrWZ2pajEc3poRyDQymSfTfnC6KggkzzxwjhkaaMyYPQxUCOVHhUqAmYhnP6yTOHtN0Wqjl7Yk5qbaWeJ(YyeUnO1w0WPtAyOKLDzLCOaayIPXE0nKGSHg4f0y6CjZqCcEPZLmF4kzEXTOHtN0Wqjl7Yk5qbaWeRKGYx(OHeKjzzxG1JovmWEPoYgAGdNoe4dBC1WyX8kiiIljWwykKINDctQiACztHeY7L90IgoDsddLSSlRKdfaatSyQ4YbJivKn0ahoDiWh24QHX(qCsbsexsGTWuifp7eMur04YMcjK3l7rqiC6qGpSXvdJ9XpGTOHtN0Wqjl7Yk5qbaWedRCu8CWisfzdnWHthc8HnUAySy(feaYLeylmfsXZoHjiOXLnfsiVx2dGsdNoe4dBC1WyG93I2IgoDsddaGjMlbnL3dgrQTOHtN0WaayI5sqt59GrKkYUJXhxbyIJ6iBObEbnMoxYmeZsqaI0Gps20DJQqN0eeWj4vESc0gpb(OzEXhj5GttqaixAfWrHltGxCCpj9Hoxf0yPISGgtNlzgIzjiarAWhjB6UrvOtAa2I6l7hPu2FGGJs)Hv6h5ByIxW5oinC)ibPaaQF24QHXifUFsC)L0is7VK9RigC)052VKB4HxC)YSlaXC)JsuPFzUFnZ(XsIQkp9hwPFsC)UWis7F5Omxp9J8nmXB)yjSBOhx)YG00yylA40jnmaaMy6gM4fCUdsZyKpyePISHgyr0yjZkCWhj3WdVTOHtN0WaayI5I79eoDs7ChSImlQyG1DmkSIr2qdSljWwykKINDctQlZBjjzqDbzmIuHlxfJHL6Y8wssgCzCAHog5tSBscUCvmgwqqexsGTWuifp7eMuxM3ssYG6cYyePcxUkgd3I6l9L9lEIVHN(Pd3yK73tcU9xsqzTFqtNB)EsW(ree4(LaQ9l(X40cDmY97RTBsQ)ssYqw)52)q3VIG73L5TKKS(hC)AM9FtJC)A2FHVHN(Pd3yK73tcU9lEkbLvy)(609BPX9N09Riym3VlTYOtA4(JL7pKVC)A2FfR9tAueJ1VIG73l17hZU0k4(Vmtk8GS(veC)4PQF6WX4(9KGB)INsqzT)auZQqhxCVEGTO(sFz)HtN0WaayIzmj6e0kNLX5LaJSHgyCcELhRanMeDcALZY48sGLcKminnCzCAHog5tSBscckrqWL5TKKm4Y40cDmYNy3KeC5QymSyEPUGa9qgHEwUkgd7JxKkGTOHtN0WaayI5I79eoDs7ChSImlQyGDfClA40jnmaaMyU4EpHtN0o3bRiZIkgySImSUJtb2lYgAGdNoe4dBC1WyFiUw0WPtAyaamXCX9EcNoPDUdwrMfvmW6ookyePIrgw3XPa7fzdnWHthc8HnUAySy(BrBrdNoPHHUcgyzEX8szmYiBObgizqAAOUGmgrQqqjsLbPPHlJtl0XiFIDtsqqjsDjb2ctHu8StyakiaKminnuxqgJiviOePYG00qsZTCWsMDumeuIuxsGTWuOnKrOh6GbuqaixsGTWuib2ueEwbbxsGTWuOXUnV5wauQminnuxqgJiviOebb5eJLspKrONLRIXW(4L4eeaYLeylmfsXZoHjvgKMgUmoTqhJ8j2njbbLiLEiJqplxfJH9XxqCa2IgoDsddDfmaaMyY3mlhAW1dYgAGLbPPH6cYyePcbLii4Y8wssguxqgJiv4YvXyyXioQliiNySu6Hmc9SCvmg2hVi1w0WPtAyORGbaWelmhJ1nUhxCViBObwgKMgQliJrKkeuIGGlZBjjzqDbzmIuHlxfJHfJ4OUGGCIXsPhYi0ZYvXyyF8IuBrdNoPHHUcgaatm6zz5BMfKn0aldstd1fKXisfckrqWL5TKKmOUGmgrQWLRIXWIrCuxqqoXyP0dze6z5QymSp(Qw0WPtAyORGbaWe7oKrO4J4pGfYvSPiBObwgKMgQliJrKkSKKSw0WPtAyORGbaWetsQtAiBObwgKMgQliJrKkeuIuGKbPPHY3mlxqScbLiiOXsMvicoUkcOeN6JFQdOGGCIXsPhYi0ZYvXyyF8JufeaYLeylmfsXZoHjvgKMgUmoTqhJ8j2njbbLiLEiJqplxfJH9Xx4hWw0w0WPtAyiwbgRCu8CWisfzdnWACztHyLJINdD6aXsbsYYeoKDfOxiw5O45GrKQuzqAAiw5O45qNoqmC5QymSputqqgKMgIvokEo0PdedljjdqPajdstdxgNwOJr(e7MKGLKKjiiIljWwykKINDcdWw0WPtAyiwbaWeJYCVhmIuBrdNoPHHyfaatSsckF5Jgsq2qdmqUKaBHPqkE2jmPa5Y8wssgCzCAHog5tSBscUCvmg2hYUcGccI4scSfMcP4zNWKkIljWwyk0gYi0dDWccUKaBHPqBiJqp0blfixM3ssYGKMB5GLm7Oy4YvXyyFi7kccUmVLKKbjn3Yblz2rXWLRIXWIrCuhqbb6Hmc9SCvmg2hVudqPajYgt5WeytHrPGHmvhSIfe2ykhMaBkmkfmeuIuG2ykhMaBkmkfmCmF8sDPBmLdtGnfgLcgUCvmg2hItqyJPCycSPWOuWWXeZL5TKKmbHWPdb(WgxnmwmVakiiYgt5WeytHrPGHGsKc0gt5WeytHrPGHUe0uG9kiSXuomb2uyuky4yI5Y8wssgGa2IgoDsddXkaaMy03yzKn0aRXE0nKabLiDbnMoxYmeNGx6CjZhUsMxClA40jnmeRaayIPXE0nKGSHg4f0y6CjZqCcEPZLmF4kzEXs1yp6gsGlxfJH9HSRi1L5TKKmi9nwgUCvmg2hYUslA40jnmeRaayIXuvYnXdb(GrKAlA40jnmeRaayIrAULdwYSJIr2qdmqUmVLKKb1fKXisfUCvmg2hYUIGGminnuxqgJiviOeaLcKiBmLdtGnfgLcgYuDWkwqqKnMYHjWMcJsbdbLiDJPCycSPWOuWWc4g6Kga2ykhMaBkmkfmCmF8tDbHnMYHjWMcJsbdbLiDJPCycSPWOuWWLRIXWI51xjieoDiWh24QHXI5fqbb6Hmc9SCvmg2hXh1BrdNoPHHyfaatm6B4HlhmIuBrdNoPHHyfaatSchkIJdrqzJkKn0atNoqmaCbwpltMnFOthigwfuTfnC6KggIvaamXItf4w49K0h3MKWTOHtN0WqScaGjgPyUJr(e7MKq2qdSlZBjjzWLXPf6yKpXUjj4YvXyyFi7ksbsenUSPqMQsUjEiWhmIufeKbPPHY3mlxqScbLaOGGiUKaBHPqkE2jmbbxM3ssYGlJtl0XiFIDtsWLRIXWccYjglLEiJqplxfJH9HATOHtN0WqScaGj2Y40cDmYNy3KeYgAGbsgKMgwsq5lF0qceuIGGiACztHLeu(YhnKiiqpKrONLRIXW(41pGsbsKnMYHjWMcJsbdzQoyfliiYgt5WeytHrPGHGsKc0gt5WeytHrPGHfWn0jnaSXuomb2uyuky4y(4L6ccBmLdtGnfgLcg6sqtb2lGccBmLdtGnfgLcgckr6gt5WeytHrPGHlxfJHfZxjieoDiWh24QHXI5fWw0WPtAyiwbaWeJqEVShKn0aldstdxgNwOJr(e7MKGGseeeXLeylmfsXZoHjfizqAAOKLDdMpyePIHLKKjiiIgx2uOdXuf8ghmIufecNoe4dBC1WyF8dylA40jnmeRaayIHvokEoyePISHgyxsGTWuifp7eMu60bIbGlW6zzYS5dD6aXWQGQsbcixM3ssYGlJtl0XiFIDtsWLRIXW(q2vepqCsbseCcELhRazAAq8qGpHnvXjCo(YBO5kiiIgx2uyjbLV8rdjacOGGgx2uyjbLV8rdjsDzEljjdwsq5lF0qcC5QymSpehGTOHtN0WqScaGj2gsMYHEwgzdnWlOX05sMHyWL8yKpyePILQXLnfI1LJQ7ySuGCzEljjdUmoTqhJ8j2njbxUkgdlMxQliiIljWwykKINDctqqenUSPWsckF5JgseeWj4vEScKPPbXdb(e2ufNW54lVHMlGTOHtN0WqScaGjMdXuf8ghmIur2qdmM1JCAGyOo86x8Dq6sCsLbPPH6ookhmIuXWssYKsNoqmxo6ook8654sqt9HAsLbPPHsw2ny(GrKkgckPfnC6KggIvaamXI1fgFWisfzdnWywpYPbIH6WRFX3bPlXjvgKMgQ74OCWisfdljjtkD6aXC5O74OWRNJlbn1hQjvgKMgkzz3G5dgrQyiOKw0WPtAyiwbaWetxqgJivKn0adeqYG00qjl7gmFWisfdljjtqqJlBk0f37yKpkc(GrKkgqPUKaBHPqcSPi8SccUKaBHPqJDBEZTii4Y8wssgCzCAHog5tSBscUCvmgwmIJ6ccUmVLKKbxgNwOJr(e7MKGlxfJH9Xl1feCzEljjdsAULdwYSJIHlxfJHfJ4OUGGminnK0ClhSKzhfdbLaOGGminnKqEVShiOePHthc8HnUAySyEfeKtmwk9qgHEwUkgd7JFQ1IgoDsddXkaaMyXuXLdgrQiZ5XD5JglzwXa7fzdnWYG00qjl7gmFWisfdljjtqaizqAAOUGmgrQqqjcc0G37zzhIyjZhDQyFi7kaWfy9OtfdOuGerJlBk0HyQcEJdgrQccHthc8HnUAySp(buqqgKMgQ74OCWisfdxUkgdlgtv2bQ8rNkwA40HaFyJRgglM3w0WPtAyiwbaWeBdjt5qplJSHgyGCzEljjdUmoTqhJ8j2njbxUkgdlMxQliiIljWwykKINDctqqenUSPWsckF5JgseeWj4vEScKPPbXdb(e2ufNW54lVHMlGsPthigaUaRNLjZMp0PdedRcQkfizqAAyjbLV8rdjWssYKkdstd5G8L14Mg(OliFOthigwssMGGgx2uiwxoQUJXa2IgoDsddXkaaMyoetvWBCWisfzdnWYG00qjl7gmFWisfdbLiiqNoqSyUeRaiC6KgmMkUCWisf6sS2IgoDsddXkaaMyX6cJpyePISHgyzqAAOKLDdMpyePIHGseeOthiwmxIvaeoDsdgtfxoyePcDjwBrdNoPHHyfaatmmVsytpyDmYiZ5XD5JglzwXa7fzdnWltVmgriFzPASKzfQtfF08ugwSc4g6KwlA40jnmeRaayIjh7gKzKn0ahoDiWh24QHXI5TfnC6KggIvaamX2qYuo0ZYiBObgixM3ssYGlJtl0XiFIDtsWLRIXWI5L6sxqJPZLmdXGl5XiFWisfliiIljWwykKINDctqqenUSPWsckF5JgseeWj4vEScKPPbXdb(e2ufNW54lVHMlGsPthigaUaRNLjZMp0PdedRcQkfizqAAyjbLV8rdjWssYee04YMcX6Yr1DmgWw0WPtAyiwbaWetoiFs6JUJJcgzdnWYG00qDbzmIuHLKK1IgoDsddXkaaMy0xgJWTbTISHgyCcELhRaLaIvWlF4fuIoPjvgKMgQliJrKkSKKSw0WPtAyiwbaWedRCu8CWisTfTfnC6KggQ74OGrKkgySYrXZbJivKn0aRXLnfIvokEo0PdelDSd9DiJqLkdstdXkhfph60bIHlxfJH9HATOHtN0WqDhhfmIuXaayIrzU3dgrQiBObEbnMoxYmusc6qCs6Zgin5EO3GCfBkwQminnK(gE4fFQILceuslA40jnmu3XrbJivmaaMy03WdxoyePISHg4f0y6CjZqjjOdXjPpBG0K7HEdYvSP4w0WPtAyOUJJcgrQyaamXkjO8LpAibzdnWa5scSfMcP4zNWK6Y8wssgCzCAHog5tSBscUCvmg2hYUIGGiUKaBHPqkE2jmPI4scSfMcTHmc9qhSGGljWwyk0gYi0dDWsbYL5TKKmiP5woyjZokgUCvmg2hYUIGGlZBjjzqsZTCWsMDumC5QymSyeh1buqqJLmRqDQ4JMNYW(4L6ccUmVLKKbxgNwOJr(e7MKGlxfJHfZl1LgoDiWh24QHXIrCakfir2ykhMaBkmkfmKP6GvSGWgt5WeytHrPGHlxfJHfZxjiiIljWwykKINDcdWw0WPtAyOUJJcgrQyaamX0yp6gsq2qd8cAmDUKziobV05sMpCLmVyPAShDdjWLRIXW(q2vK6Y8wssgK(gldxUkgd7dzxPfnC6KggQ74OGrKkgaatm6BSmYUJXhxby)udzdnWAShDdjqqjsxqJPZLmdXj4LoxY8HRK5f3IgoDsdd1DCuWisfdaGjgtvj3epe4dgrQTOHtN0WqDhhfmIuXaayIrAULdwYSJIr2qdSiBmLdtGnfgLcgYuDWkwqyJPCycSPWOuWWLRIXWI5L6ccHthc8HnUAySyaVXuomb2uyukyOlbnv8G)w0WPtAyOUJJcgrQyaamXifZDmYNy3KeYgAGDzEljjdUmoTqhJ8j2njbxUkgd7dzxrkqIOXLnfYuvYnXdb(GrKQGGminnu(Mz5cIviOeafeeXLeylmfsXZoHji4Y8wssgCzCAHog5tSBscUCvmgwmVuxqqoXyP0dze6z5QymSpuRfnC6KggQ74OGrKkgaatSLXPf6yKpXUjjKn0adKlZBjjzqc59YEGlxfJH9HSRiiiIgx2uiH8EzpccASKzfQtfF08ug2hV(bukqISXuomb2uyukyit1bRybHnMYHjWMcJsbdxUkgdlMVsqiC6qGpSXvdJfd4nMYHjWMcJsbdDjOPIh8dylA40jnmu3XrbJivmaaMyeY7L9GSHgyzqAA4Y40cDmYNy3KeeuIGGiUKaBHPqkE2jSw0WPtAyOUJJcgrQyaamXKJDdYClA40jnmu3XrbJivmaaMy6cYyePISHgyzqAA4Y40cDmYNy3KeeuIGGlZBjjzWLXPf6yKpXUjj4YvXyyX8sDbbrCjb2ctHu8StyccYjglLEiJqplxfJH9Xp1BrdNoPHH6ookyePIbaWeBdjt5qplJSHg4f0y6CjZqm4sEmYhmIuXsbYL5TKKm4Y40cDmYNy3KeC5QymSyEPUGGiUKaBHPqkE2jmbbr04YMcljO8LpAibqPYG00qDhhLdgrQy4YvXyyXaMPk7av(Otf3IgoDsdd1DCuWisfdaGjwmvC5GrKkYCECx(OXsMvmWEr2qdmqYG00qDhhLdgrQy4YvXyyXaMPk7av(OtfliqNoqmxo6ook8654sqtfJ6akfizqAAOKLDdMpyePIHLKKjiqdEVNLDiILmF0PI9Xfy9OtfdaYUIGGminnuxqgJiviOeaBrdNoPHH6ookyePIbaWeRWHI44qeu2OczdnW0PdedaxG1ZYKzZh60bIHvbvBrdNoPHH6ookyePIbaWeBdjt5qplJSHgyGCzEljjdUmoTqhJ8j2njbxUkgdlMxQlDbnMoxYmedUKhJ8bJivSGGiUKaBHPqkE2jmbbrwqJPZLmdXGl5XiFWisfliiIgx2uyjbLV8rdjakvgKMgQ74OCWisfdxUkgdlgWmvzhOYhDQ4w0WPtAyOUJJcgrQyaamXQaV6GrKkYgAGLbPPH6ookhmIuXWssYeeKbPPHsw2ny(GrKkgckrkD6aXI5sScGWPtAWyQ4YbJivOlXQuGerJlBk0HyQcEJdgrQccHthc8HnUAySyehGTOHtN0WqDhhfmIuXaayI5qmvbVXbJivKn0aldstdLSSBW8bJivmeuIu60bIfZLyfaHtN0GXuXLdgrQqxIvPHthc8HnUAySpi9w0WPtAyOUJJcgrQyaamXOm37bJivKn0aldstdlCuoShgwsswlA40jnmu3XrbJivmaaMyXPcCl8Es6JBts4w0WPtAyOUJJcgrQyaamXOVHhUCWisTfnC6KggQ74OGrKkgaatmmVsytpyDmYiZ5XD5JglzwXa7fzdnWltVmgriF5w0WPtAyOUJJcgrQyaamXQaV6GrKkYgAGPthiwmxIvaeoDsdgtfxoyePcDjwLcKlZBjjzWLXPf6yKpXUjj4YvXyyXOMGGiUKaBHPqkE2jmaBrdNoPHH6ookyePIbaWetJ9OBibzdnWlOX05sMHgJXJrMuSEWhDdjsgJ8jKij2qbXTOHtN0WqDhhfmIuXaayIrVmJ0mg5JUHeKn0aVGgtNlzgAmgpgzsX6bF0nKizmYNqIKydfe3IgoDsdd1DCuWisfdaGjMCq(K0hDhhfmYgAGLbPPH6cYyePcljjRfnC6KggQ74OGrKkgaatm6lJr42Gwr2qdmobVYJvGsaXk4Lp8ckrN0Kkdstd1fKXisfwsswlA40jnmu3XrbJivmaaMyyLJINdgrQTOTOHtN0WqDhJcRyGje7eYxgzwuXaJ9yUdOeKriUGmWYG00WLXPf6yKpXUjjiOebbzqAAOUGmgrQqqjTOHtN0WqDhJcRyaamXie7eYxgzwuXaJ1nnYhShZDaLGmcXfKb2LeylmfsXZoHjvgKMgUmoTqhJ8j2njbbLivgKMgQliJrKkeuIGGiUKaBHPqkE2jmPYG00qDbzmIuHGsArdNoPHH6ogfwXaayIri2jKVmYSOIbgRBAKpypM7SCvmggzPeGXSo0iZLwz0jnGDjb2ctHu8StyiJqCbzGDzEljjdUmoTqhJ8j2njbxUkgd7J4FxM3ssYG6cYyePcxUkgdFidYymYiexq(WxmdSlZBjjzqDbzmIuHlxfJHpKbzmgzdnWYG00qDbzmIuHLKK1IgoDsdd1DmkSIbaWeJqStiFzKzrfdmw30iFWEm3z5QymmYsjaJzDOrMlTYOtAa7scSfMcP4zNWqgH4cYa7Y8wssgCzCAHog5tSBscUCvmggzeIliF4lMb2L5TKKmOUGmgrQWLRIXWhYGmgJSHgyzqAAOUGmgrQqqjTOHtN0WqDhJcRyaamXie7eYxgzwuXaJ9yUZYvXyyKLsagZ6qJmxALrN0a2LeylmfsXZoHHmcXfKb2L5TKKm4Y40cDmYNy3KeC5QymSyI)DzEljjdQliJrKkC5Qym8HmiJXiJqCb5dFXmWUmVLKKb1fKXisfUCvmg(qgKX4w0WPtAyOUJrHvmaaMyGy(mkxHrg(MkgyDhJcREr2qdmqaP7yuyf6fIiWhqmFKbPPfeCjb2ctHu8Stys1DmkSc9cre4JlZBjjzakficXoH8LHyDtJ8b7XChqjsbsexsGTWuifp7eMur0DmkSc9dre4diMpYG00ccUKaBHPqkE2jmPIO7yuyf6hIiWhxM3ssYee0DmkSc9dDzEljjdUCvmgwqq3XOWk0lerGpGy(idstlfir0DmkSc9dre4diMpYG00cc6ogfwHEHUmVLKKblGBOtAIbSUJrHvOFOlZBjjzWc4g6KgGcc6ogfwHEHic8XL5TKKmPIO7yuyf6hIiWhqmFKbPPLQ7yuyf6f6Y8wssgSaUHoPjgW6ogfwH(HUmVLKKblGBOtAakiicHyNq(YqSUPr(G9yUdOePajIUJrHvOFiIaFaX8rgKMwkq6ogfwHEHUmVLKKblGBOtAep18HqStiFzi2J5olxfJHfeie7eYxgI9yUZYvXyyX0DmkSc9cDzEljjdwa3qN0qA9dOGGUJrHvOFiIaFaX8rgKMwkq6ogfwHEHic8beZhzqAAP6ogfwHEHUmVLKKblGBOtAIbSUJrHvOFOlZBjjzWc4g6KMuG0DmkSc9cDzEljjdwa3qN0iEQ5dHyNq(YqShZDwUkgdliqi2jKVme7XCNLRIXWIP7yuyf6f6Y8wssgSaUHoPH06hqbbGer3XOWk0lerGpGy(idstliO7yuyf6h6Y8wssgSaUHoPjgW6ogfwHEHUmVLKKblGBOtAakfiDhJcRq)qxM3ssYGlhfps1DmkSc9dDzEljjdwa3qN0iEQjgHyNq(YqShZDwUkgdlLqStiFzi2J5olxfJH9r3XOWk0p0L5TKKmybCdDsdP1VGGi6ogfwH(HUmVLKKbxokEKcKUJrHvOFOlZBjjzWLRIXWep18HqStiFziw30iFWEm3z5QymSucXoH8LHyDtJ8b7XCNLRIXWI5N6sbs3XOWk0l0L5TKKmybCdDsJ4PMpeIDc5ldXEm3z5QymSGGUJrHvOFOlZBjjzWLRIXWep18HqStiFzi2J5olxfJHLQ7yuyf6h6Y8wssgSaUHoPr8EPoaie7eYxgI9yUZYvXyyFie7eYxgI1nnYhShZDwUkgdliqi2jKVme7XCNLRIXWIP7yuyf6f6Y8wssgSaUHoPH06xqGqStiFzi2J5oGsauqq3XOWk0p0L5TKKm4YvXyyINAIri2jKVmeRBAKpypM7SCvmgwkq6ogfwHEHUmVLKKblGBOtAep18HqStiFziw30iFWEm3z5QymSGGUJrHvOxOlZBjjzWc4g6KMp0dze6z5QymSucXoH8LHyDtJ8b7XCNLRIXWaq3XOWk0l0L5TKKmybCdDstm6Hmc9SCvmgwqqeDhJcRqVqeb(aI5JminTuGie7eYxgI9yUZYvXyyX0DmkSc9cDzEljjdwa3qN0qA9liqi2jKVme7XChqjaciGaciGccASKzfQtfF08ug2hcXoH8LHypM7SCvmggqbbr0DmkSc9cre4diMpYG00sfXLeylmfsXZoHjfiDhJcRq)qeb(aI5JminTuGasecXoH8LHypM7akrqq3XOWk0p0L5TKKm4YvXyyXOgGsbIqStiFzi2J5olxfJHfZp1fe0DmkSc9dDzEljjdUCvmgM4PMyeIDc5ldXEm3z5QymmGakiiIUJrHvOFiIaFaX8rgKMwkqIO7yuyf6hIiWhxM3ssYee0DmkSc9dDzEljjdUCvmgwqq3XOWk0p0L5TKKmybCdDstmG1DmkSc9cDzEljjdwa3qN0aeqaLcKi6ogfwHEHdg6chc(K0NWjEbNLlhD5adUmwqqezqAAy4eVGZYLdPWkqqja2IgoDsdd1DmkSIbaWedeZNr5kmYW3uXaR7yuy1pYgAGbciDhJcRq)qeb(aI5JminTGGljWwykKINDctQUJrHvOFiIaFCzEljjdqPari2jKVmeRBAKpypM7akrkqI4scSfMcP4zNWKkIUJrHvOxiIaFaX8rgKMwqWLeylmfsXZoHjveDhJcRqVqeb(4Y8wssMGGUJrHvOxOlZBjjzWLRIXWcc6ogfwH(Hic8beZhzqAAPajIUJrHvOxiIaFaX8rgKMwqq3XOWk0p0L5TKKmybCdDstmG1DmkSc9cDzEljjdwa3qN0auqq3XOWk0perGpUmVLKKjveDhJcRqVqeb(aI5JminTuDhJcRq)qxM3ssYGfWn0jnXaw3XOWk0l0L5TKKmybCdDsdqbbrie7eYxgI1nnYhShZDaLifir0DmkSc9cre4diMpYG00sbs3XOWk0p0L5TKKmybCdDsJ4PMpeIDc5ldXEm3z5QymSGaHyNq(YqShZDwUkgdlMUJrHvOFOlZBjjzWc4g6KgsRFafe0DmkSc9cre4diMpYG00sbs3XOWk0perGpGy(idstlv3XOWk0p0L5TKKmybCdDstmG1DmkSc9cDzEljjdwa3qN0KcKUJrHvOFOlZBjjzWc4g6KgXtnFie7eYxgI9yUZYvXyybbcXoH8LHypM7SCvmgwmDhJcRq)qxM3ssYGfWn0jnKw)akiaKi6ogfwH(Hic8beZhzqAAbbDhJcRqVqxM3ssYGfWn0jnXaw3XOWk0p0L5TKKmybCdDsdqPaP7yuyf6f6Y8wssgC5O4rQUJrHvOxOlZBjjzWc4g6KgXtnXie7eYxgI9yUZYvXyyPeIDc5ldXEm3z5QymSp6ogfwHEHUmVLKKblGBOtAiT(feer3XOWk0l0L5TKKm4YrXJuG0DmkSc9cDzEljjdUCvmgM4PMpeIDc5ldX6Mg5d2J5olxfJHLsi2jKVmeRBAKpypM7SCvmgwm)uxkq6ogfwH(HUmVLKKblGBOtAep18HqStiFzi2J5olxfJHfe0DmkSc9cDzEljjdUCvmgM4PMpeIDc5ldXEm3z5QymSuDhJcRqVqxM3ssYGfWn0jnI3l1baHyNq(YqShZDwUkgd7dHyNq(YqSUPr(G9yUZYvXyybbcXoH8LHypM7SCvmgwmDhJcRq)qxM3ssYGfWn0jnKw)cceIDc5ldXEm3bucGcc6ogfwHEHUmVLKKbxUkgdt8utmcXoH8LHyDtJ8b7XCNLRIXWsbs3XOWk0p0L5TKKmybCdDsJ4PMpeIDc5ldX6Mg5d2J5olxfJHfe0DmkSc9dDzEljjdwa3qN08HEiJqplxfJHLsi2jKVmeRBAKpypM7SCvmgga6ogfwH(HUmVLKKblGBOtAIrpKrONLRIXWccIO7yuyf6hIiWhqmFKbPPLceHyNq(YqShZDwUkgdlMUJrHvOFOlZBjjzWc4g6KgsRFbbcXoH8LHypM7akbqabeqabuqqJLmRqDQ4JMNYW(qi2jKVme7XCNLRIXWakiiIUJrHvOFiIaFaX8rgKMwQiUKaBHPqkE2jmPaP7yuyf6fIiWhqmFKbPPLceqIqi2jKVme7XChqjcc6ogfwHEHUmVLKKbxUkgdlg1aukqeIDc5ldXEm3z5QymSy(PUGGUJrHvOxOlZBjjzWLRIXWep1eJqStiFzi2J5olxfJHbeqbbr0DmkSc9cre4diMpYG00sbseDhJcRqVqeb(4Y8wssMGGUJrHvOxOlZBjjzWLRIXWcc6ogfwHEHUmVLKKblGBOtAIbSUJrHvOFOlZBjjzWc4g6KgGacOuGer3XOWk0pCWqx4qWNK(eoXl4SC5OlhyWLXccIidstddN4fCwUCifwbckbqufvrrb]] )


end