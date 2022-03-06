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


    spec:RegisterPack( "Marksmanship", 20220306, [[d8uFucqicXJOQeUecv0MisFcHmka6uayvesjEfG0SqqUfcvTlq)cHYWqQYXOkTmQQEgcutdHkDnKQABaI8ncPY4OQK6CuvIwhcK3bikQ5rvX9au7Jq1)iKQQdsvjPfsi5HactKqkPlciQ6JaIsJKqQkDsQkjwjHYljKQIzsvPUjHuk7eb8tarLHcikSucPkpvsnveuFLqkvJfPs7fs)vLgSQoSWIjQhtLjlXLrTzK8zKYOHWPvSAarrEnIA2Q42sYUP8BrdNiooHuSCLEoutN01bA7q03rKXJuX5Pkwpcvy(eSFPg1lkHrRlHYOeWp987NEem9asqVIo)0ZlAT6rcJwljCKdAmATfvmATOTyjJRcdJyKGwlj8CYOGsy0ACcUogT2x0pcvLGjiIrmAJIaug6YkIHNkWtOtAUnOuIHNkhXqRLbNJ6RyOYO1Lqzuc4NE(9tpcMEajOxrNF6rpFjADaQiYfTUEQac0AetPWgQmADHXo0ArBXsgxfggXiPFrFbnL3wmrBX6q0pqIq97NE(93I1IbeicJgJjOwmIVFcWKOsqR0VOhJZdsU)b3VLA)r)vSdryJRFfb3FukP1VlmIrAoN(RclOXWwmIVFrpg7XCCP)OusRFj7K7OE6N0Oi6VEQaI(9vbYW3WwmIVFFZA)I(4zNWW9xyShZ1VIGNTFGq0kUFCwX6uXyiA9zWkgLWO16ooYyePIrjmkb8Isy0A2c5dxqffATBhL3jqR14WMcXkhfpxQ0bIHSfYhU0V0(h7sDgAi0(L2VmiffeRCu8CPshigUCvmgUFF6N(O1HtN0qRXkhfpxmIurvuc4hLWO1SfYhUGkk0A3okVtGwVGgtLlngkjbDiUj1DdIJCVuBqRInfdzlKpCPFP9ldsrbPoHhEX3QyjdbLGwhoDsdTM8CoxmIurvucqWOegTMTq(WfurHw72r5Dc06f0yQCPXqjjOdXnPUBqCK7LAdAvSPyiBH8HlO1HtN0qRPoHhUCXisfvrjaXfLWO1SfYhUGkk0A3okVtGwdy)UejBHPqYE2jS(L2VlZtjjzWLXPf6y0UXUjj4YvXy4(9PFAUs)cc9ls)UejBHPqYE2jS(L2Vi97sKSfMcTHgc9sfC)cc97sKSfMcTHgc9sfC)s7hW(DzEkjjdsAoLlwYSJIHlxfJH73N(P5k9li0VlZtjjzqsZPCXsMDumC5QymC)I3pbtV(bOFbH(1yPXkuNk(Q5TmC)(0Vx61VGq)UmpLKKbxgNwOJr7g7MKGlxfJH7x8(9sV(L2F40bjFzJRgg3V49tW9dq)s7hW(fP)nMYLrYMcJsbdz6myf3VGq)BmLlJKnfgLcgUCvmgUFX73x2VGq)I0VlrYwykKSNDcRFaqRdNoPHwxsq5dF1qcQIsa6Jsy0A2c5dxqffATBhL3jqRxqJPYLgdXj4HkxA8LRK5fdzlKpCPFP9RXE1nKaxUkgd3Vp9tZv6xA)UmpLKKbPoXYWLRIXW97t)0Cf06WPtAO1ASxDdjOkkbasOegTMTq(WfurHwhoDsdTM6elJw72r5Dc0An2RUHeiOK(L2)cAmvU0yiobpu5sJVCLmVyiBH8HlO1NX4RRGw7N(OkkbeDOegToC6KgAnthjNepi5lgrQO1SfYhUGkkufLa(AucJwZwiF4cQOqRD7O8obATi9VXuUms2uyukyitNbR4(fe6FJPCzKSPWOuWWLRIXW9lE)EPx)cc9hoDqYx24QHX9loW9VXuUms2uyukyOlbnTFrl97hToC6KgAnP5uUyjZokgvrjGVeLWO1SfYhUGkk0A3okVtGw7Y8ussgCzCAHogTBSBscUCvmgUFF6NMR0V0(bSFr6xJdBkKPJKtIhK8fJiviBH8Hl9li0Vmiffu(Kz5aIviOK(bOFbH(fPFxIKTWuizp7ew)cc97Y8ussgCzCAHogTBSBscUCvmgUFX73l96xqOF5eJ7xA)udne6D5QymC)(0p9rRdNoPHwtkMZy0UXUjjufLaEPhkHrRzlKpCbvuO1UDuENaTgW(DzEkjjdImph2dC5QymC)(0pnxPFbH(fPFnoSPqK55WEGSfYhU0VGq)AS0yfQtfF18wgUFF63R)(bOFP9dy)I0)gt5YiztHrPGHmDgSI7xqO)nMYLrYMcJsbdxUkgd3V497l7xqO)WPds(YgxnmUFXbU)nMYLrYMcJsbdDjOP9lAPF)9daAD40jn06LXPf6y0UXUjjufLaE9Isy0A2c5dxqffATBhL3jqRLbPOGlJtl0XODJDtsqqj9li0Vi97sKSfMcj7zNWqRdNoPHwJmph2dQIsaV(rjmAD40jn0A5y3GgJwZwiF4cQOqvuc4LGrjmAnBH8HlOIcT2TJY7eO1YGuuWLXPf6y0UXUjjiOK(fe63L5PKKm4Y40cDmA3y3KeC5QymC)I3Vx61VGq)I0VlrYwykKSNDcRFbH(LtmUFP9tn0qO3LRIXW97t)(PhAD40jn0ADbzmIurvuc4L4Isy0A2c5dxqffATBhL3jqRxqJPYLgdXGlTXODXisfdzlKpCPFP9dy)UmpLKKbxgNwOJr7g7MKGlxfJH7x8(9sV(fe6xK(Djs2ctHK9Sty9li0Vi9RXHnfwsq5dF1qcKTq(WL(bOFP9ldsrb1DCKVyePIHlxfJH7xCG7NPd7av(QtfJwhoDsdTEdjt5snlJQOeWl9rjmAnBH8HlOIcToC6KgADmvC5IrKkATBhL3jqRbSFzqkkOUJJ8fJivmC5QymC)IdC)mDyhOYxDQ4(fe6NkDGyUC1DCK51Z1LGM2V49tV(bOFP9dy)YGuuqjl7gmFXisfdljjRFbH(PapN7YoeXsJV6uX97t)UaRxDQ4(bA)0CL(fe6xgKIcQliJrKkeus)aGw784o8vJLgRyuc4fvrjGxGekHrRzlKpCbvuO1UDuENaTMkDG4(bA)UaR3LPXw)(0pv6aXWQGoO1HtN0qRlCOiUoeb5nQqvuc4v0Hsy0A2c5dxqffATBhL3jqRbSFxMNssYGlJtl0XODJDtsWLRIXW9lE)EPx)s7FbnMkxAmedU0gJ2fJivmKTq(WL(fe6xK(Djs2ctHK9Sty9li0Vi9VGgtLlngIbxAJr7IrKkgYwiF4s)cc9ls)ACytHLeu(WxnKazlKpCPFa6xA)YGuuqDhh5lgrQy4YvXy4(fh4(z6WoqLV6uXO1HtN0qR3qYuUuZYOkkb86RrjmAnBH8HlOIcT2TJY7eO1YGuuqDhh5lgrQyyjjz9li0VmiffuYYUbZxmIuXqqj9lTFQ0bI7x8(Djw7hO9hoDsdgtfxUyePcDjw7xA)a2Vi9RXHnf6qmvbVXfJiviBH8Hl9li0F40bjFzJRgg3V49tW9daAD40jn06kWJoyePIQOeWRVeLWO1SfYhUGkk0A3okVtGwldsrbLSSBW8fJivmeus)s7NkDG4(fVFxI1(bA)HtN0GXuXLlgrQqxI1(L2F40bjFzJRgg3Vp9tCrRdNoPHw7qmvbVXfJivufLa(PhkHrRzlKpCbvuO1UDuENaTwgKIcw4OCzpmSKKm06WPtAO1KNZ5IrKkQIsa)ErjmAD40jn064wbUfEVj11TjjmAnBH8HlOIcvrjGF)OegToC6KgAn1j8WLlgrQO1SfYhUGkkufLa(jyucJwZwiF4cQOqRdNoPHwJ5vcB6fRJrdT2TJY7eO1ltTmgriFy0ANh3HVAS0yfJsaVOkkb8tCrjmAnBH8HlOIcT2TJY7eO1uPde3V497sS2pq7pC6KgmMkUCXisf6sS2V0(bSFxMNssYGlJtl0XODJDtsWLRIXW9lE)0VFbH(fPFxIKTWuizp7ew)aGwhoDsdTUc8OdgrQOkkb8tFucJwZwiF4cQOqRD7O8obA9cAmvU0yOXy8y0ifRh8v3qIKXODdjsInuqmKTq(Wf06WPtAO1ASxDdjOkkb8dKqjmAnBH8HlOIcT2TJY7eO1lOXu5sJHgJXJrJuSEWxDdjsgJ2nKij2qbXq2c5dxqRdNoPHwtTmtCmgTRUHeufLa(fDOegTMTq(WfurHw72r5Dc0AzqkkOUGmgrQWssYqRdNoPHwlh0Uj1v3XrgJQOeWVVgLWO1SfYhUGkk0A3okVtGwJtWJ8yfOeqScE4lVGs0jniBH8Hl9lTFzqkkOUGmgrQWssYqRdNoPHwtDymc3gukQIsa)(sucJwhoDsdTgRCu8CXisfTMTq(WfurHQOkADHPcWJIsyuc4fLWO1HtN0qRDjOP8EXisfTMTq(WfurHQOeWpkHrRzlKpCbvuO1HtN0qRDjOP8EXisfT2TJY7eO1lOXu5sJHywccqId8vYMUtuf6KgKTq(WL(fe6hNGh5XkqB8e4RM5bFLKdoniBH8Hl9li0pG97sRaokCzK8IJZnPUu5QGgdzlKpCPFP9ls)lOXu5sJHywccqId8vYMUtuf6KgKTq(WL(baT(mgFDf0AcMEOkkbiyucJwZwiF4cQOqRdNoPHwRByIgW5mehJr7IrKkADHXUDKOtAO1azZ(deCu6pSs)eEdt0aoNH4G7Naazae9ZgxnmMq9tI7VKgrA)LSFfXG7Nk3(LCcp8I7xMDbiM7FuIk9lZ9Rz2pwsuv5P)Wk9tI73fgrA)lhL54PFcVHjA6hlHDd146xgKIcdrRD7O8obATi9RXsJv4GVsoHhErvucqCrjmAnBH8HlOIcT2TJY7eO1UejBHPqYE2jS(L2VlZtjjzqDbzmIuHlxfJH7xA)UmpLKKbxgNwOJr7g7MKGlxfJH7xqOFr63Lizlmfs2ZoH1V0(DzEkjjdQliJrKkC5QymmAD40jn0AxCo3WPtA3ZGv06ZG1RfvmATUJrMvmQIsa6Jsy0A2c5dxqffAD40jn0AxCo3WPtA3ZGv06ZG1RfvmATRGrvucaKqjmAnBH8HlOIcT2TJY7eO1HthK8LnUAyC)(0pbJwJ1DCkkb8IwhoDsdT2fNZnC6K29myfT(my9ArfJwJvufLaIoucJwZwiF4cQOqRD7O8obAD40bjFzJRgg3V497hTgR74uuc4fToC6KgATloNB40jT7zWkA9zW61IkgTw3XrgJivmQIQO1sw2LvYHIsyuc4fLWO1HtN0qRLtvpC5sDcpCH0y0UAsNXqRzlKpCbvuOkkb8Jsy06WPtAO1uhgJWTbLIwZwiF4cQOqvucqWOegTMTq(WfurHw72r5Dc06f0yQCPXqCcEOYLgF5kzEXq2c5dxqRdNoPHwRXE1nKGQOeG4Isy0A2c5dxqffATKLDbwV6uXO1EPhAD40jn06sckF4RgsqRD7O8obAD40bjFzJRgg3V497TFbH(fPFxIKTWuizp7ew)s7xK(14WMcrMNd7bYwiF4cQIsa6Jsy0A2c5dxqffATBhL3jqRdNoi5lBC1W4(9PFcUFP9dy)I0VlrYwykKSNDcRFP9ls)ACytHiZZH9azlKpCPFbH(dNoi5lBC1W4(9PF)9daAD40jn06yQ4YfJivufLaajucJwZwiF4cQOqRD7O8obAD40bjFzJRgg3V497VFbH(bSFxIKTWuizp7ew)cc9RXHnfImph2dKTq(WL(bOFP9hoDqYx24QHX9dC)(rRdNoPHwJvokEUyePIQOkATRGrjmkb8Isy0A2c5dxqffATBhL3jqRbSFzqkkOUGmgrQqqj9lTFzqkk4Y40cDmA3y3Keeus)s73Lizlmfs2ZoH1pa9li0pG9ldsrb1fKXisfckPFP9ldsrbjnNYflz2rXqqj9lTFxIKTWuOn0qOxQG7hG(fe6hW(Djs2ctHiztr4z7xqOFxIKTWuOXUnp5w6hG(L2VmiffuxqgJiviOK(fe6xoX4(L2p1qdHExUkgd3Vp97LG7xqOFa73Lizlmfs2ZoH1V0(LbPOGlJtl0XODJDtsqqj9lTFQHgc9UCvmgUFF6x0rW9daAD40jn0AzEX8sEmAOkkb8Jsy0A2c5dxqffATBhL3jqRLbPOG6cYyePcbL0VGq)UmpLKKb1fKXisfUCvmgUFX7NGPx)cc9lNyC)s7NAOHqVlxfJH73N(9cKqRdNoPHwlFYSCPaxpOkkbiyucJwZwiF4cQOqRD7O8obATmiffuxqgJiviOK(fe63L5PKKmOUGmgrQWLRIXW9lE)em96xqOF5eJ7xA)udne6D5QymC)(0VxGeAD40jn06WCmw34CDX5GQOeG4Isy0A2c5dxqffATBhL3jqRLbPOG6cYyePcbL0VGq)UmpLKKb1fKXisfUCvmgUFX7NGPx)cc9lNyC)s7NAOHqVlxfJH73N(9LO1HtN0qRPMLLpzwqvucqFucJwZwiF4cQOqRD7O8obATmiffuxqgJivyjjzO1HtN0qRpdnek(cKjWcTk2uufLaajucJwZwiF4cQOqRD7O8obATmiffuxqgJiviOK(L2pG9ldsrbLpzwoGyfckPFbH(1yPXkebhhfbuIt73N(9tV(bOFbH(LtmUFP9tn0qO3LRIXW97t)(bs9li0pG97sKSfMcj7zNW6xA)YGuuWLXPf6y0UXUjjiOK(L2p1qdHExUkgd3Vp9l683paO1HtN0qRLK6KgQIQO1yfLWOeWlkHrRzlKpCbvuO1UDuENaTwJdBkeRCu8CPshigYwiF4s)s7hW(LSmYlnxb6fIvokEUyeP2V0(LbPOGyLJINlv6aXWLRIXW97t)0VFbH(LbPOGyLJINlv6aXWssY6hG(L2pG9ldsrbxgNwOJr7g7MKGLKK1VGq)I0VlrYwykKSNDcRFaqRdNoPHwJvokEUyePIQOeWpkHrRdNoPHwtEoNlgrQO1SfYhUGkkufLaemkHrRzlKpCbvuO1UDuENaTgW(Djs2ctHK9Sty9lTFa73L5PKKm4Y40cDmA3y3KeC5QymC)(0pnxPFa6xqOFr63Lizlmfs2ZoH1V0(fPFxIKTWuOn0qOxQG7xqOFxIKTWuOn0qOxQG7xA)a2VlZtjjzqsZPCXsMDumC5QymC)(0pnxPFbH(DzEkjjdsAoLlwYSJIHlxfJH7x8(jy61pa9li0p1qdHExUkgd3Vp97L(9dq)s7hW(fP)nMYLrYMcJsbdz6myf3VGq)BmLlJKnfgLcgckPFP9dy)BmLlJKnfgLcgow)(0Vx61V0(3ykxgjBkmkfmC5QymC)(0pb3VGq)BmLlJKnfgLcgow)I3F40jTRlZtjjz9li0F40bjFzJRgg3V497TFa6xqOFr6FJPCzKSPWOuWqqj9lTFa7FJPCzKSPWOuWqxcAA)a3V3(fe6FJPCzKSPWOuWWX6x8(dNoPDDzEkjjRFa6ha06WPtAO1Leu(WxnKGQOeG4Isy0A2c5dxqffATBhL3jqR1yV6gsGGs6xA)lOXu5sJH4e8qLln(YvY8IHSfYhUGwhoDsdTM6elJQOeG(OegTMTq(WfurHw72r5Dc06f0yQCPXqCcEOYLgF5kzEXq2c5dx6xA)ASxDdjWLRIXW97t)0CL(L2VlZtjjzqQtSmC5QymC)(0pnxbToC6KgATg7v3qcQIsaGekHrRdNoPHwZ0rYjXds(IrKkAnBH8HlOIcvrjGOdLWO1SfYhUGkk0A3okVtGwdy)UmpLKKb1fKXisfUCvmgUFF6NMR0VGq)YGuuqDbzmIuHGs6hG(L2pG9ls)BmLlJKnfgLcgY0zWkUFbH(fP)nMYLrYMcJsbdbL0V0(3ykxgjBkmkfmSaUHoP1pq7FJPCzKSPWOuWWX63N(9tV(fe6FJPCzKSPWOuWqqj9lT)nMYLrYMcJsbdxUkgd3V4971x2VGq)HthK8LnUAyC)I3V3(bOFbH(PgAi07YvXy4(9PFFn9qRdNoPHwtAoLlwYSJIrvuc4RrjmAD40jn0AQt4HlxmIurRzlKpCbvuOkkb8LOegTMTq(WfurHw72r5Dc0AQ0bI7hO97cSExMgB97t)uPdedRc6GwhoDsdTUWHI46qeK3OcvrjGx6Hsy06WPtAO1XTcCl8EtQRBtsy0A2c5dxqffQIsaVErjmAnBH8HlOIcT2TJY7eO1UmpLKKbxgNwOJr7g7MKGlxfJH73N(P5k9lTFa7xK(14WMcz6i5K4bjFXisfYwiF4s)cc9ldsrbLpzwoGyfckPFa6xqOFr63Lizlmfs2ZoH1VGq)UmpLKKbxgNwOJr7g7MKGlxfJH7xqOF5eJ7xA)udne6D5QymC)(0p9rRdNoPHwtkMZy0UXUjjufLaE9Jsy0A2c5dxqffATBhL3jqRbSFzqkkyjbLp8vdjqqj9li0Vi9RXHnfwsq5dF1qcKTq(WL(fe6NAOHqVlxfJH73N(96VFa6xA)a2Vi9VXuUms2uyukyitNbR4(fe6xK(3ykxgjBkmkfmeus)s7hW(3ykxgjBkmkfmSaUHoP1pq7FJPCzKSPWOuWWX63N(9sV(fe6FJPCzKSPWOuWqxcAA)a3V3(bOFbH(3ykxgjBkmkfmeus)s7FJPCzKSPWOuWWLRIXW9lE)(Y(fe6pC6GKVSXvdJ7x8(92paO1HtN0qRxgNwOJr7g7MKqvuc4LGrjmAnBH8HlOIcT2TJY7eO1YGuuWLXPf6y0UXUjjiOK(fe6xK(Djs2ctHK9Sty9lTFa7xgKIckzz3G5lgrQyyjjz9li0Vi9RXHnf6qmvbVXfJiviBH8Hl9li0F40bjFzJRgg3Vp97VFaqRdNoPHwJmph2dQIsaVexucJwZwiF4cQOqRD7O8obATlrYwykKSNDcRFP9tLoqC)aTFxG17Y0yRFF6NkDGyyvqN(L2pG9dy)UmpLKKbxgNwOJr7g7MKGlxfJH73N(P5k9lAPFcUFP9dy)I0pobpYJvGmffiEqY3WMQ4gohF4n0CHSfYhU0VGq)I0Vgh2uyjbLp8vdjq2c5dx6hG(bOFbH(14WMcljO8HVAibYwiF4s)s73L5PKKmyjbLp8vdjWLRIXW97t)eC)aGwhoDsdTgRCu8CXisfvrjGx6Jsy0A2c5dxqffATBhL3jqRxqJPYLgdXGlTXODXisfdzlKpCPFP9RXHnfI1LJQZymKTq(WL(L2pG97Y8ussgCzCAHogTBSBscUCvmgUFX73l96xqOFr63Lizlmfs2ZoH1VGq)I0Vgh2uyjbLp8vdjq2c5dx6xqOFCcEKhRazkkq8GKVHnvXnCo(WBO5czlKpCPFaqRdNoPHwVHKPCPMLrvuc4fiHsy0A2c5dxqffATBhL3jqRXSELtded1Hx)(6lXvIRFP9ldsrb1DCKVyePIHLKK1V0(PshiMlxDhhzE9CDjOP97t)0VFP9ldsrbLSSBW8fJivmeucAD40jn0AhIPk4nUyePIQOeWROdLWO1SfYhUGkk0A3okVtGwJz9kNgigQdV(91xIRex)s7xgKIcQ74iFXisfdljjRFP9tLoqmxU6ooY8656sqt73N(PF)s7xgKIckzz3G5lgrQyiOe06WPtAO1X6cJVyePIQOeWRVgLWO1SfYhUGkk0A3okVtGwdy)a2VmiffuYYUbZxmIuXWssY6xqOFnoSPqxCoJr7Qi4lgrQyiBH8Hl9dq)s73LizlmfIKnfHNTFbH(Djs2ctHg728KBPFbH(DzEkjjdUmoTqhJ2n2njbxUkgd3V49tW0RFbH(DzEkjjdUmoTqhJ2n2njbxUkgd3Vp97LE9li0VlZtjjzqsZPCXsMDumC5QymC)I3pbtV(fe6xgKIcsAoLlwYSJIHGs6hG(fe6xgKIcImph2deus)s7pC6GKVSXvdJ7x8(92VGq)Yjg3V0(PgAi07YvXy4(9PF)0hToC6KgATUGmgrQOkkb86lrjmAnBH8HlOIcToC6KgADmvC5IrKkATBhL3jqRLbPOGsw2ny(IrKkgwssw)cc9dy)YGuuqDbzmIuHGs6xqOFkWZ5USdrS04RovC)(0pnxPFG2VlW6vNkUFa6xA)a2Vi9RXHnf6qmvbVXfJiviBH8Hl9li0F40bjFzJRgg3Vp97VFa6xqOFzqkkOUJJ8fJivmC5QymC)I3pth2bQ8vNkUFP9hoDqYx24QHX9lE)ErRDECh(QXsJvmkb8IQOeWp9qjmAnBH8HlOIcT2TJY7eO1a2VlZtjjzWLXPf6y0UXUjj4YvXy4(fVFV0RFbH(fPFxIKTWuizp7ew)cc9ls)ACytHLeu(WxnKazlKpCPFbH(Xj4rEScKPOaXds(g2uf3W54dVHMlKTq(WL(bOFP9tLoqC)aTFxG17Y0yRFF6NkDGyyvqN(L2pG9ldsrbljO8HVAibwssw)s7xgKIcYbTdRXjn8vxq(sLoqmSKKS(fe6xJdBkeRlhvNXyiBH8Hl9daAD40jn06nKmLl1SmQIsa)ErjmAnBH8HlOIcT2TJY7eO1YGuuqjl7gmFXisfdbL0VGq)uPde3V497sS2pq7pC6KgmMkUCXisf6sSIwhoDsdT2HyQcEJlgrQOkkb87hLWO1SfYhUGkk0A3okVtGwldsrbLSSBW8fJivmeus)cc9tLoqC)I3VlXA)aT)WPtAWyQ4YfJivOlXkAD40jn06yDHXxmIurvuc4NGrjmAnBH8HlOIcToC6KgAnMxjSPxSogn0A3okVtGwVm1YyeH8H7xA)AS0yfQtfF18wgUFX7VaUHoPHw784o8vJLgRyuc4fvrjGFIlkHrRzlKpCbvuO1UDuENaToC6GKVSXvdJ7x8(9IwhoDsdTwo2nOXOkkb8tFucJwZwiF4cQOqRD7O8obAnG97Y8ussgCzCAHogTBSBscUCvmgUFX73l96xA)lOXu5sJHyWL2y0UyePIHSfYhU0VGq)I0VlrYwykKSNDcRFbH(fPFnoSPWsckF4RgsGSfYhU0VGq)4e8ipwbYuuG4bjFdBQIB4C8H3qZfYwiF4s)a0V0(PshiUFG2VlW6DzAS1Vp9tLoqmSkOt)s7hW(LbPOGLeu(WxnKaljjRFbH(14WMcX6Yr1zmgYwiF4s)aGwhoDsdTEdjt5snlJQOeWpqcLWO1SfYhUGkk0A3okVtGwldsrb1fKXisfwssgAD40jn0A5G2nPU6ooYyufLa(fDOegTMTq(WfurHw72r5Dc0ACcEKhRaLaIvWdF5fuIoPbzlKpCPFP9ldsrb1fKXisfwssgAD40jn0AQdJr42Gsrvuc43xJsy06WPtAO1yLJINlgrQO1SfYhUGkkufvrR1DmYSIrjmkb8Isy0A2c5dxqffADkbTgZkAD40jn0AKXoH8HrRrghqgTwgKIcUmoTqhJ2n2njbbL0VGq)YGuuqDbzmIuHGsqRrg71IkgTg7XCxqjOkkb8Jsy0A2c5dxqffADkbTgZkAD40jn0AKXoH8HrRrghqgT2Lizlmfs2ZoH1V0(LbPOGlJtl0XODJDtsqqj9lTFzqkkOUGmgrQqqj9li0Vi97sKSfMcj7zNW6xA)YGuuqDbzmIuHGsqRrg71IkgTgRBA0UypM7ckbvrjabJsy0A2c5dxqffADkbTgZ6qHwhoDsdTgzStiFy0AKXETOIrRX6MgTl2J5UlxfJHrRD7O8obATmiffuxqgJivyjjz9lTFxIKTWuizp7egAnY4aYx(Gz0AxMNssYG6cYyePcxUkgdJwJmoGmATlZtjjzWLXPf6y0UXUjj4YvXy4(9r0F)UmpLKKb1fKXisfUCvmggvrjaXfLWO1SfYhUGkk06ucAnM1HcToC6KgAnYyNq(WO1iJ9ArfJwJ1nnAxShZDxUkgdJw72r5Dc0AzqkkOUGmgrQqqj9lTFxIKTWuizp7egAnY4aYx(Gz0AxMNssYG6cYyePcxUkgdJwJmoGmATlZtjjzWLXPf6y0UXUjj4YvXyyufLa0hLWO1SfYhUGkk06ucAnM1HcToC6KgAnYyNq(WO1iJ9ArfJwJ9yU7YvXyy0A3okVtGw7sKSfMcj7zNWqRrghq(YhmJw7Y8ussguxqgJiv4YvXyy0AKXbKrRDzEkjjdUmoTqhJ2n2njbxUkgd3V4I(73L5PKKmOUGmgrQWLRIXWOkkbasOegTMTq(WfurHwhoDsdTw3XiZQx0A3okVtGwdy)a2VUJrMvO6fIiWxqmFLbPO6xqOFxIKTWuizp7ew)s7x3XiZku9cre4RlZtjjz9dq)s7hW(rg7eYhgI1nnAxShZDbL0V0(bSFr63Lizlmfs2ZoH1V0(fPFDhJmRq1perGVGy(kdsr1VGq)UejBHPqYE2jS(L2Vi9R7yKzfQ(Hic81L5PKKS(fe6x3XiZku9dDzEkjjdUCvmgUFbH(1DmYScvVqeb(cI5Rmifv)s7hW(fPFDhJmRq1perGVGy(kdsr1VGq)6ogzwHQxOlZtjjzWc4g6Kw)IdC)6ogzwHQFOlZtjjzWc4g6Kw)a0VGq)6ogzwHQxiIaFDzEkjjRFP9ls)6ogzwHQFiIaFbX8vgKIQFP9R7yKzfQEHUmpLKKblGBOtA9loW9R7yKzfQ(HUmpLKKblGBOtA9dq)cc9ls)iJDc5ddX6MgTl2J5UGs6xA)a2Vi9R7yKzfQ(Hic8feZxzqkQ(L2pG9R7yKzfQEHUmpLKKblGBOtA9t89t)(9PFKXoH8HHypM7UCvmgUFbH(rg7eYhgI9yU7YvXy4(fVFDhJmRq1l0L5PKKmybCdDsRFI1V)(bOFbH(1DmYScv)qeb(cI5Rmifv)s7hW(1DmYScvVqeb(cI5Rmifv)s7x3XiZku9cDzEkjjdwa3qN06xCG7x3XiZku9dDzEkjjdwa3qN06xA)a2VUJrMvO6f6Y8ussgSaUHoP1pX3p973N(rg7eYhgI9yU7YvXy4(fe6hzStiFyi2J5UlxfJH7x8(1DmYScvVqxMNssYGfWn0jT(jw)(7hG(fe6hW(fPFDhJmRq1lerGVGy(kdsr1VGq)6ogzwHQFOlZtjjzWc4g6Kw)IdC)6ogzwHQxOlZtjjzWc4g6Kw)a0V0(bSFDhJmRq1p0L5PKKm4YrXt)s7x3XiZku9dDzEkjjdwa3qN06N47N(9lE)iJDc5ddXEm3D5QymC)s7hzStiFyi2J5UlxfJH73N(1DmYScv)qxMNssYGfWn0jT(jw)(7xqOFr6x3XiZku9dDzEkjjdUCu80V0(bSFDhJmRq1p0L5PKKm4YvXy4(j((PF)(0pYyNq(WqSUPr7I9yU7YvXy4(L2pYyNq(WqSUPr7I9yU7YvXy4(fVF)0RFP9dy)6ogzwHQxOlZtjjzWc4g6Kw)eF)0VFF6hzStiFyi2J5UlxfJH7xqOFDhJmRq1p0L5PKKm4YvXy4(j((PF)(0pYyNq(WqShZDxUkgd3V0(1DmYScv)qxMNssYGfWn0jT(j((9sV(bA)iJDc5ddXEm3D5QymC)(0pYyNq(WqSUPr7I9yU7YvXy4(fe6hzStiFyi2J5UlxfJH7x8(1DmYScvVqxMNssYGfWn0jT(jw)(7xqOFKXoH8HHypM7ckPFa6xqOFDhJmRq1p0L5PKKm4YvXy4(j((PF)I3pYyNq(WqSUPr7I9yU7YvXy4(L2pG9R7yKzfQEHUmpLKKblGBOtA9t89t)(9PFKXoH8HHyDtJ2f7XC3LRIXW9li0Vi9R7yKzfQEHic8feZxzqkQ(L2pG9Jm2jKpme7XC3LRIXW9lE)6ogzwHQxOlZtjjzWc4g6Kw)eRF)9li0pYyNq(WqShZDbL0pa9dq)a0pa9dq)a0VGq)AS0yfQtfF18wgUFF6hzStiFyi2J5UlxfJH7hG(fe6xK(1DmYScvVqeb(cI5Rmifv)s7xK(Djs2ctHK9Sty9lTFa7x3XiZku9dre4liMVYGuu9lTFa7hW(fPFKXoH8HHypM7ckPFbH(1DmYScv)qxMNssYGlxfJH7x8(PF)a0V0(bSFKXoH8HHypM7UCvmgUFX73p96xqOFDhJmRq1p0L5PKKm4YvXy4(j((PF)I3pYyNq(WqShZDxUkgd3pa9dq)cc9ls)6ogzwHQFiIaFbX8vgKIQFP9dy)I0VUJrMvO6hIiWxxMNssY6xqOFDhJmRq1p0L5PKKm4YvXy4(fe6x3XiZku9dDzEkjjdwa3qN06xCG7x3XiZku9cDzEkjjdwa3qN06hG(bOFa6xA)a2Vi9R7yKzfQEHdg6chc(Mu3WjAaNLlxD5adUmUFbH(dNoi5lBC1W4(9PF)9lTFr6xgKIcgord4SC5skSceus)cc9hoDqYx24QHX9lE)E7xA)YGuuWWjAaNLl3Gomeus)aGwJpPIrR1DmYS6fvrjGOdLWO1SfYhUGkk06WPtAO16ogzw9Jw72r5Dc0Aa7hW(1DmYScv)qeb(cI5Rmifv)cc97sKSfMcj7zNW6xA)6ogzwHQFiIaFDzEkjjRFa6xA)a2pYyNq(WqSUPr7I9yUlOK(L2pG9ls)UejBHPqYE2jS(L2Vi9R7yKzfQEHic8feZxzqkQ(fe63Lizlmfs2ZoH1V0(fPFDhJmRq1lerGVUmpLKK1VGq)6ogzwHQxOlZtjjzWLRIXW9li0VUJrMvO6hIiWxqmFLbPO6xA)a2Vi9R7yKzfQEHic8feZxzqkQ(fe6x3XiZku9dDzEkjjdwa3qN06xCG7x3XiZku9cDzEkjjdwa3qN06hG(fe6x3XiZku9dre4RlZtjjz9lTFr6x3XiZku9cre4liMVYGuu9lTFDhJmRq1p0L5PKKmybCdDsRFXbUFDhJmRq1l0L5PKKmybCdDsRFa6xqOFr6hzStiFyiw30ODXEm3fus)s7hW(fPFDhJmRq1lerGVGy(kdsr1V0(bSFDhJmRq1p0L5PKKmybCdDsRFIVF63Vp9Jm2jKpme7XC3LRIXW9li0pYyNq(WqShZDxUkgd3V49R7yKzfQ(HUmpLKKblGBOtA9tS(93pa9li0VUJrMvO6fIiWxqmFLbPO6xA)a2VUJrMvO6hIiWxqmFLbPO6xA)6ogzwHQFOlZtjjzWc4g6Kw)IdC)6ogzwHQxOlZtjjzWc4g6Kw)s7hW(1DmYScv)qxMNssYGfWn0jT(j((PF)(0pYyNq(WqShZDxUkgd3VGq)iJDc5ddXEm3D5QymC)I3VUJrMvO6h6Y8ussgSaUHoP1pX63F)a0VGq)a2Vi9R7yKzfQ(Hic8feZxzqkQ(fe6x3XiZku9cDzEkjjdwa3qN06xCG7x3XiZku9dDzEkjjdwa3qN06hG(L2pG9R7yKzfQEHUmpLKKbxokE6xA)6ogzwHQxOlZtjjzWc4g6Kw)eF)0VFX7hzStiFyi2J5UlxfJH7xA)iJDc5ddXEm3D5QymC)(0VUJrMvO6f6Y8ussgSaUHoP1pX63F)cc9ls)6ogzwHQxOlZtjjzWLJIN(L2pG9R7yKzfQEHUmpLKKbxUkgd3pX3p973N(rg7eYhgI1nnAxShZDxUkgd3V0(rg7eYhgI1nnAxShZDxUkgd3V497NE9lTFa7x3XiZku9dDzEkjjdwa3qN06N47N(97t)iJDc5ddXEm3D5QymC)cc9R7yKzfQEHUmpLKKbxUkgd3pX3p973N(rg7eYhgI9yU7YvXy4(L2VUJrMvO6f6Y8ussgSaUHoP1pX3Vx61pq7hzStiFyi2J5UlxfJH73N(rg7eYhgI1nnAxShZDxUkgd3VGq)iJDc5ddXEm3D5QymC)I3VUJrMvO6h6Y8ussgSaUHoP1pX63F)cc9Jm2jKpme7XCxqj9dq)cc9R7yKzfQEHUmpLKKbxUkgd3pX3p97x8(rg7eYhgI1nnAxShZDxUkgd3V0(bSFDhJmRq1p0L5PKKmybCdDsRFIVF63Vp9Jm2jKpmeRBA0UypM7UCvmgUFbH(fPFDhJmRq1perGVGy(kdsr1V0(bSFKXoH8HHypM7UCvmgUFX7x3XiZku9dDzEkjjdwa3qN06Ny97VFbH(rg7eYhgI9yUlOK(bOFa6hG(bOFa6hG(fe6xJLgRqDQ4RM3YW97t)iJDc5ddXEm3D5QymC)a0VGq)I0VUJrMvO6hIiWxqmFLbPO6xA)I0VlrYwykKSNDcRFP9dy)6ogzwHQxiIaFbX8vgKIQFP9dy)a2Vi9Jm2jKpme7XCxqj9li0VUJrMvO6f6Y8ussgC5QymC)I3p97hG(L2pG9Jm2jKpme7XC3LRIXW9lE)(Px)cc9R7yKzfQEHUmpLKKbxUkgd3pX3p97x8(rg7eYhgI9yU7YvXy4(bOFa6xqOFr6x3XiZku9cre4liMVYGuu9lTFa7xK(1DmYScvVqeb(6Y8ussw)cc9R7yKzfQEHUmpLKKbxUkgd3VGq)6ogzwHQxOlZtjjzWc4g6Kw)IdC)6ogzwHQFOlZtjjzWc4g6Kw)a0pa9dq)s7hW(fPFDhJmRq1pCWqx4qW3K6gord4SC5QlhyWLX9li0F40bjFzJRgg3Vp97VFP9ls)YGuuWWjAaNLlxsHvGGs6xqO)WPds(YgxnmUFX73B)s7xgKIcgord4SC5g0HHGs6ha0A8jvmATUJrMv)OkQIQO1i5fpPHsa)0ZVF6rW0J(O1KI1gJggTw0UVQOhb8viaqwcQ)(jmcU)PssUA)u52pr6ooYyePIjQ)LfnGZYL(Xzf3FaQzvOCPFhIWOXyylMVhJ73lb1pqKgsEvU0prACytH0LO(1SFI04WMcPlKTq(WfI6hqV0baylMVhJ73pb1pqKgsEvU0prlOXu5sJH0LO(1SFIwqJPYLgdPlKTq(WfI6hqV0baylMVhJ7NGjO(bI0qYRYL(jAbnMkxAmKUe1VM9t0cAmvU0yiDHSfYhUqu)H2pqEGC(UFa9shaGTy(EmUF6tq9dePHKxLl9t0cAmvU0yiDjQFn7NOf0yQCPXq6czlKpCHO(b0lDaa2I57X4(bseu)arAi5v5s)eTGgtLlngsxI6xZ(jAbnMkxAmKUq2c5dxiQ)q7hipqoF3pGEPdaWwmFpg3VVKG6hisdjVkx6NinoSPq6su)A2prACytH0fYwiF4cr9dOx6aaSfZ3JX97LEeu)arAi5v5s)ePXHnfsxI6xZ(jsJdBkKUq2c5dxiQFa9shaGTy(EmUFVexcQFGinK8QCPFI04WMcPlr9Rz)ePXHnfsxiBH8Hle1pGEPdaWwmFpg3VxIlb1pqKgsEvU0prlOXu5sJH0LO(1SFIwqJPYLgdPlKTq(WfI6hqV0baylMVhJ73ROJG6hisdjVkx6NinoSPq6su)A2prACytH0fYwiF4cr9dOx6aaSfZ3JX97v0rq9dePHKxLl9t0cAmvU0yiDjQFn7NOf0yQCPXq6czlKpCHO(b0pDaa2I57X4(96RjO(bI0qYRYL(jsJdBkKUe1VM9tKgh2uiDHSfYhUqu)a6LoaaBX89yC)(Ppb1pqKgsEvU0prlOXu5sJH0LO(1SFIwqJPYLgdPlKTq(WfI6p0(bYdKZ39dOx6aaSfZ3JX97hirq9dePHKxLl9t0cAmvU0yiDjQFn7NOf0yQCPXq6czlKpCHO(dTFG8a58D)a6LoaaBX89yC)(91eu)arAi5v5s)eHtWJ8yfiDjQFn7NiCcEKhRaPlKTq(WfI6hqV0baylwlMODFvrpc4RqaGSeu)9tyeC)tLKC1(PYTFIkmvaEuI6Fzrd4SCPFCwX9hGAwfkx63HimAmg2I57X4(9tq9dePHKxLl9t0cAmvU0yiDjQFn7NOf0yQCPXq6czlKpCHO(b0lDaa2I57X4(9tq9dePHKxLl9t0cAmvU0yiDjQFn7NOf0yQCPXq6czlKpCHO(b0lDaa2I57X4(9tq9dePHKxLl9tKlTc4Oq6su)A2prU0kGJcPlKTq(WfI6hqV0baylMVhJ73pb1pqKgsEvU0pr4e8ipwbsxI6xZ(jcNGh5Xkq6czlKpCHO(b0lDaa2I1IjA3xv0Ja(keailb1F)egb3)ujjxTFQC7Nijl7Yk5qjQ)LfnGZYL(Xzf3FaQzvOCPFhIWOXyylMVhJ7NGjO(bI0qYRYL(jAbnMkxAmKUe1VM9t0cAmvU0yiDHSfYhUqu)H2pqEGC(UFa9shaGTy(EmUFIlb1pqKgsEvU0prACytH0LO(1SFI04WMcPlKTq(WfI6p0(bYdKZ39dOx6aaSfZ3JX9tFcQFGinK8QCPFI04WMcPlr9Rz)ePXHnfsxiBH8Hle1pGEPdaWwmFpg3pqIG6hisdjVkx6NinoSPq6su)A2prACytH0fYwiF4cr9dOx6aaSfRft0UVQOhb8viaqwcQ)(jmcU)PssUA)u52pryLO(xw0aolx6hNvC)bOMvHYL(DicJgJHTy(EmUFVeu)arAi5v5s)ePXHnfsxI6xZ(jsJdBkKUq2c5dxiQFa9shaGTy(EmUFIlb1pqKgsEvU0prlOXu5sJH0LO(1SFIwqJPYLgdPlKTq(WfI6p0(bYdKZ39dOx6aaSfZ3JX9tFcQFGinK8QCPFIwqJPYLgdPlr9Rz)eTGgtLlngsxiBH8Hle1pGEPdaWwmFpg3VxVeu)arAi5v5s)ePXHnfsxI6xZ(jsJdBkKUq2c5dxiQFa9shaGTy(EmUFV(jO(bI0qYRYL(jsJdBkKUe1VM9tKgh2uiDHSfYhUqu)a6LoaaBX89yC)EjycQFGinK8QCPFI04WMcPlr9Rz)ePXHnfsxiBH8Hle1pGEPdaWwmFpg3VxIlb1pqKgsEvU0prACytH0LO(1SFI04WMcPlKTq(WfI6hq)0baylMVhJ73lXLG6hisdjVkx6NiCcEKhRaPlr9Rz)eHtWJ8yfiDHSfYhUqu)a6LoaaBX89yC)EPpb1pqKgsEvU0prACytH0LO(1SFI04WMcPlKTq(WfI6hq)0baylMVhJ73l9jO(bI0qYRYL(jAbnMkxAmKUe1VM9t0cAmvU0yiDHSfYhUqu)a6LoaaBX89yC)EPpb1pqKgsEvU0pr4e8ipwbsxI6xZ(jcNGh5Xkq6czlKpCHO(b0lDaa2I57X4(96RjO(bI0qYRYL(jsJdBkKUe1VM9tKgh2uiDHSfYhUqu)a6LoaaBX89yC)E9Leu)arAi5v5s)ePXHnfsxI6xZ(jsJdBkKUq2c5dxiQFa9shaGTy(EmUF)0JG6hisdjVkx6NinoSPq6su)A2prACytH0fYwiF4cr9dOF6aaSfZ3JX97NEeu)arAi5v5s)eHtWJ8yfiDjQFn7NiCcEKhRaPlKTq(WfI6hqV0baylMVhJ73p9jO(bI0qYRYL(jsJdBkKUe1VM9tKgh2uiDHSfYhUqu)a6NoaaBX89yC)(Ppb1pqKgsEvU0prlOXu5sJH0LO(1SFIwqJPYLgdPlKTq(WfI6hqV0baylMVhJ73p9jO(bI0qYRYL(jcNGh5Xkq6su)A2pr4e8ipwbsxiBH8Hle1pGEPdaWwmFpg3VFrhb1pqKgsEvU0pr4e8ipwbsxI6xZ(jcNGh5Xkq6czlKpCHO(b0lDaa2I1IjA3xv0Ja(keailb1F)egb3)ujjxTFQC7NiDhJmRyI6Fzrd4SCPFCwX9hGAwfkx63HimAmg2I57X4(bseu)arAi5v5s)1tfq0p2JPbD6N4SFn733Gr)Lb5GN06pLWBO52pGedG(bK(0baylMVhJ7hirq9dePHKxLl9tKUJrMvOxiDjQFn7NiDhJmRq1lKUe1pG(9thaGTy(EmUFGeb1pqKgsEvU0pr6ogzwH(H0LO(1SFI0DmYScv)q6su)a6hirhaGTy(EmUFrhb1pqKgsEvU0F9ube9J9yAqN(jo7xZ(9ny0Fzqo4jT(tj8gAU9diXaOFaPpDaa2I57X4(fDeu)arAi5v5s)eP7yKzf6fsxI6xZ(js3XiZku9cPlr9dOFGeDaa2I57X4(fDeu)arAi5v5s)eP7yKzf6hsxI6xZ(js3XiZku9dPlr9dOF)0baylwlMVsLKCvU0pqQ)WPtA9FgSIHTyO1yjSdLa(PpXfTwYMuZHrR9f(I(fTflzCvyyeJK(f9f0uEBX8f(I(fTfRdr)ajc1VF653FlwlMVWx0pqGimAmMGAX8f(I(j((jatIkbTs)IEmopi5(hC)wQ9h9xXoeHnU(veC)rPKw)UWigP5C6VkSGgdBX8f(I(j((f9yShZXL(JsjT(LStUJ6PFsJIO)6Pci63xfidFdBX8f(I(j((9nR9l6JNDcd3FHXEmx)kcE2(bcrR4(XzfRtfJHTyTyHtN0Wqjl7Yk5qbkWetov9WLl1j8WfsJr7QjDgRflC6KggkzzxwjhkqbMyuhgJWTbL2IfoDsddLSSlRKdfOatmn2RUHecnuaVGgtLlngItWdvU04lxjZlUflC6KggkzzxwjhkqbMyLeu(WxnKqijl7cSE1PIb2l9i0qbC40bjFzJRgglUxbbrCjs2ctHK9StysfrJdBkezEoSNwSWPtAyOKLDzLCOafyIftfxUyePsOHc4WPds(Ygxnm2hcwkGI4sKSfMcj7zNWKkIgh2uiY8CypccHthK8LnUAySp(bOflC6KggkzzxwjhkqbMyyLJINlgrQeAOaoC6GKVSXvdJf3VGaGUejBHPqYE2jmbbnoSPqK55WEaqA40bjFzJRggdS)wSwSWPtAyGcmXCjOP8EXisTflC6KggOatmxcAkVxmIuj0zm(6katW0JqdfWlOXu5sJHywccqId8vYMUtuf6KMGaobpYJvG24jWxnZd(kjhCAcca6sRaokCzK8IJZnPUu5QGglvKf0yQCPXqmlbbiXb(kzt3jQcDsdGwmFr)azZ(deCu6pSs)eEdt0aoNH4G7Naazae9ZgxnmgiZ9tI7VKgrA)LSFfXG7Nk3(LCcp8I7xMDbiM7FuIk9lZ9Rz2pwsuv5P)Wk9tI73fgrA)lhL54PFcVHjA6hlHDd146xgKIcdBXcNoPHbkWet3WenGZziogJ2fJivcnualIglnwHd(k5eE4TflC6KggOatmxCo3WPtA3ZGvczrfdSUJrMvmHgkGDjs2ctHK9StysDzEkjjdQliJrKkC5QymSuxMNssYGlJtl0XODJDtsWLRIXWccI4sKSfMcj7zNWK6Y8ussguxqgJiv4YvXy4wmFHVOFrR8j80pv4gJw)EsWT)sckR9dA6C63tc2pIaj3VeqTFrpgNwOJrRFF1Dts9xssgH6p3(hQ(veC)UmpLKK1)G7xZS)tA06xZ(l8j80pv4gJw)EsWTFrRjOSc73xHQFlnU)KQFfbJ5(DPvgDsd3FSC)H8H7xZ(RyTFsJIyS(veC)EPx)y2Lwb3)HzsHhc1VIG7hpv9tfog3VNeC7x0AckR9hGAwf64IZXdSfZx4l6pC6KggOatmJjrLGw5UmopizcnuaJtWJ8yfOXKOsqRCxgNhKSuaLbPOGlJtl0XODJDtsqqjccUmpLKKbxgNwOJr7g7MKGlxfJHf3l9eeOgAi07YvXyyF8cKaOflC6KggOatmxCo3WPtA3ZGvczrfdSRGBXcNoPHbkWeZfNZnC6K29myLqwuXaJvcH1DCkWEj0qbC40bjFzJRgg7db3IfoDsdduGjMloNB40jT7zWkHSOIbw3XrgJivmHW6oofyVeAOaoC6GKVSXvdJf3Flwlw40jnm0vWalZlMxYJrJqdfWakdsrb1fKXisfckrQmiffCzCAHogTBSBscckrQlrYwykKSNDcdabbaLbPOG6cYyePcbLivgKIcsAoLlwYSJIHGsK6sKSfMcTHgc9sfmacca6sKSfMcrYMIWZki4sKSfMcn2T5j3casLbPOG6cYyePcbLiiiNySuQHgc9UCvmg2hVeSGaGUejBHPqYE2jmPYGuuWLXPf6y0UXUjjiOePudne6D5QymSpIocgGwSWPtAyORGbkWet(Kz5sbUEi0qbSmiffuxqgJiviOebbxMNssYG6cYyePcxUkgdlobtpbb5eJLsn0qO3LRIXW(4fi1IfoDsddDfmqbMyH5ySUX56IZHqdfWYGuuqDbzmIuHGseeCzEkjjdQliJrKkC5QymS4em9eeKtmwk1qdHExUkgd7JxGulw40jnm0vWafyIrnllFYSqOHcyzqkkOUGmgrQqqjccUmpLKKb1fKXisfUCvmgwCcMEccYjglLAOHqVlxfJH9Xx2IfoDsddDfmqbMyNHgcfFbYeyHwfBkHgkGLbPOG6cYyePcljjRflC6Kgg6kyGcmXKK6KgHgkGLbPOG6cYyePcbLifqzqkkO8jZYbeRqqjccAS0yfIGJJIakXP(4NEaiiiNySuQHgc9UCvmg2h)ajbbaDjs2ctHK9StysLbPOGlJtl0XODJDtsqqjsPgAi07YvXyyFeD(bOfRflC6KggIvGXkhfpxmIuj0qbSgh2uiw5O45sLoqSuaLSmYlnxb6fIvokEUyePkvgKIcIvokEUuPdedxUkgd7d9feKbPOGyLJINlv6aXWssYaqkGYGuuWLXPf6y0UXUjjyjjzccI4sKSfMcj7zNWaOflC6KggIvGcmXipNZfJi1wSWPtAyiwbkWeRKGYh(QHecnuadOlrYwykKSNDctkGUmpLKKbxgNwOJr7g7MKGlxfJH9HMRaGGGiUejBHPqYE2jmPI4sKSfMcTHgc9sfSGGlrYwyk0gAi0lvWsb0L5PKKmiP5uUyjZokgUCvmg2hAUIGGlZtjjzqsZPCXsMDumC5QymS4em9aqqGAOHqVlxfJH9Xl9bqkGISXuUms2uyukyitNbRybHnMYLrYMcJsbdbLifWnMYLrYMcJsbdhZhV0t6gt5YiztHrPGHlxfJH9HGfe2ykxgjBkmkfmCmXDzEkjjtqiC6GKVSXvdJf3laccISXuUms2uyukyiOePaUXuUms2uyukyOlbnfyVccBmLlJKnfgLcgoM4UmpLKKbaaTyHtN0WqScuGjg1jwMqdfWASxDdjqqjsxqJPYLgdXj4HkxA8LRK5f3IfoDsddXkqbMyASxDdjeAOaEbnMkxAmeNGhQCPXxUsMxSun2RUHe4YvXyyFO5ksDzEkjjdsDILHlxfJH9HMR0IfoDsddXkqbMymDKCs8GKVyeP2IfoDsddXkqbMyKMt5ILm7OycnuadOlZtjjzqDbzmIuHlxfJH9HMRiiidsrb1fKXisfckbaPakYgt5YiztHrPGHmDgSIfeezJPCzKSPWOuWqqjs3ykxgjBkmkfmSaUHoPb0nMYLrYMcJsbdhZh)0tqyJPCzKSPWOuWqqjs3ykxgjBkmkfmC5QymS4E9LccHthK8LnUAyS4EbqqGAOHqVlxfJH9XxtVwSWPtAyiwbkWeJ6eE4YfJi1wSWPtAyiwbkWeRWHI46qeK3OIqdfWuPdeduxG17Y0yZhQ0bIHvbDAXcNoPHHyfOatS4wbUfEVj11TjjClw40jnmeRafyIrkMZy0UXUjjcnua7Y8ussgCzCAHogTBSBscUCvmg2hAUIuafrJdBkKPJKtIhK8fJivbbzqkkO8jZYbeRqqjaiiiIlrYwykKSNDctqWL5PKKm4Y40cDmA3y3KeC5QymSGGCIXsPgAi07YvXyyFOFlw40jnmeRafyITmoTqhJ2n2njrOHcyaLbPOGLeu(WxnKabLiiiIgh2uyjbLp8vdjccudne6D5QymSpE9dGuafzJPCzKSPWOuWqModwXccISXuUms2uyukyiOePaUXuUms2uyukyybCdDsdOBmLlJKnfgLcgoMpEPNGWgt5YiztHrPGHUe0uG9cGGWgt5YiztHrPGHGsKUXuUms2uyuky4YvXyyX9LccHthK8LnUAyS4EbOflC6KggIvGcmXqMNd7HqdfWYGuuWLXPf6y0UXUjjiOebbrCjs2ctHK9StysbugKIckzz3G5lgrQyyjjzccIOXHnf6qmvbVXfJivbHWPds(Ygxnm2h)a0IfoDsddXkqbMyyLJINlgrQeAOa2Lizlmfs2ZoHjLkDGyG6cSExMgB(qLoqmSkOJuab0L5PKKm4Y40cDmA3y3KeC5QymSp0CfrleSuafbNGh5XkqMIcepi5BytvCdNJp8gAUccIOXHnfwsq5dF1qcaaiiOXHnfwsq5dF1qIuxMNssYGLeu(WxnKaxUkgd7dbdqlw40jnmeRafyITHKPCPMLj0qb8cAmvU0yigCPngTlgrQyPACytHyD5O6mglfqxMNssYGlJtl0XODJDtsWLRIXWI7LEccI4sKSfMcj7zNWeeerJdBkSKGYh(QHebbCcEKhRazkkq8GKVHnvXnCo(WBO5cqlw40jnmeRafyI5qmvbVXfJivcnuaJz9kNgigQdV(91xIReNuzqkkOUJJ8fJivmSKKmPuPdeZLRUJJmVEUUe0uFOVuzqkkOKLDdMVyePIHGsAXcNoPHHyfOatSyDHXxmIuj0qbmM1RCAGyOo863xFjUsCsLbPOG6ooYxmIuXWssYKsLoqmxU6ooY8656sqt9H(sLbPOGsw2ny(IrKkgckPflC6KggIvGcmX0fKXisLqdfWacOmiffuYYUbZxmIuXWssYee04WMcDX5mgTRIGVyePIbqQlrYwykejBkcpRGGlrYwyk0y3MNClccUmpLKKbxgNwOJr7g7MKGlxfJHfNGPNGGlZtjjzWLXPf6y0UXUjj4YvXyyF8spbbxMNssYGKMt5ILm7Oy4YvXyyXjy6jiidsrbjnNYflz2rXqqjaiiidsrbrMNd7bckrA40bjFzJRgglUxbb5eJLsn0qO3LRIXW(4N(TyHtN0WqScuGjwmvC5IrKkHCECh(QXsJvmWEj0qbSmiffuYYUbZxmIuXWssYeeaugKIcQliJrKkeuIGaf45Cx2HiwA8vNk2hAUcqDbwV6uXaifqr04WMcDiMQG34IrKQGq40bjFzJRgg7JFaeeKbPOG6ooYxmIuXWLRIXWIZ0HDGkF1PILgoDqYx24QHXI7TflC6KggIvGcmX2qYuUuZYeAOagqxMNssYGlJtl0XODJDtsWLRIXWI7LEccI4sKSfMcj7zNWeeerJdBkSKGYh(QHebbCcEKhRazkkq8GKVHnvXnCo(WBO5cGuQ0bIbQlW6DzAS5dv6aXWQGosbugKIcwsq5dF1qcSKKmPYGuuqoODynoPHV6cYxQ0bIHLKKjiOXHnfI1LJQZymaTyHtN0WqScuGjMdXuf8gxmIuj0qbSmiffuYYUbZxmIuXqqjccuPdelUlXkqdNoPbJPIlxmIuHUeRTyHtN0WqScuGjwSUW4lgrQeAOawgKIckzz3G5lgrQyiOebbQ0bIf3LyfOHtN0GXuXLlgrQqxI1wSWPtAyiwbkWedZRe20lwhJgHCECh(QXsJvmWEj0qb8YulJreYhwQglnwH6uXxnVLHfVaUHoP1IfoDsddXkqbMyYXUbnMqdfWHthK8LnUAyS4EBXcNoPHHyfOatSnKmLl1SmHgkGb0L5PKKm4Y40cDmA3y3KeC5QymS4EPN0f0yQCPXqm4sBmAxmIuXccI4sKSfMcj7zNWeeerJdBkSKGYh(QHebbCcEKhRazkkq8GKVHnvXnCo(WBO5cGuQ0bIbQlW6DzAS5dv6aXWQGosbugKIcwsq5dF1qcSKKmbbnoSPqSUCuDgJbOflC6KggIvGcmXKdA3K6Q74iJj0qbSmiffuxqgJivyjjzTyHtN0WqScuGjg1HXiCBqPeAOagNGh5XkqjGyf8WxEbLOtAsLbPOG6cYyePcljjRflC6KggIvGcmXWkhfpxmIuBXAXcNoPHH6ooYyePIbgRCu8CXisLqdfWACytHyLJINlv6aXsh7sDgAiuPYGuuqSYrXZLkDGy4YvXyyFOFlw40jnmu3XrgJivmqbMyKNZ5IrKkHgkGxqJPYLgdLKGoe3K6UbXrUxQnOvXMILkdsrbPoHhEX3QyjdbL0IfoDsdd1DCKXisfduGjg1j8WLlgrQeAOaEbnMkxAmusc6qCtQ7geh5EP2GwfBkUflC6KggQ74iJrKkgOatSsckF4Rgsi0qbmGUejBHPqYE2jmPUmpLKKbxgNwOJr7g7MKGlxfJH9HMRiiiIlrYwykKSNDctQiUejBHPqBOHqVubli4sKSfMcTHgc9sfSuaDzEkjjdsAoLlwYSJIHlxfJH9HMRii4Y8ussgK0CkxSKzhfdxUkgdlobtpaee0yPXkuNk(Q5TmSpEPNGGlZtjjzWLXPf6y0UXUjj4YvXyyX9spPHthK8LnUAyS4emasbuKnMYLrYMcJsbdz6myfliSXuUms2uyuky4YvXyyX9LccI4sKSfMcj7zNWaOflC6KggQ74iJrKkgOatmn2RUHecnuaVGgtLlngItWdvU04lxjZlwQg7v3qcC5QymSp0CfPUmpLKKbPoXYWLRIXW(qZvAXcNoPHH6ooYyePIbkWeJ6eltOZy81va2p9j0qbSg7v3qceuI0f0yQCPXqCcEOYLgF5kzEXTyHtN0WqDhhzmIuXafyIX0rYjXds(IrKAlw40jnmu3XrgJivmqbMyKMt5ILm7OycnualYgt5YiztHrPGHmDgSIfe2ykxgjBkmkfmC5QymS4EPNGq40bjFzJRggloWBmLlJKnfgLcg6sqtfT4VflC6KggQ74iJrKkgOatmsXCgJ2n2njrOHcyxMNssYGlJtl0XODJDtsWLRIXW(qZvKcOiACytHmDKCs8GKVyePkiidsrbLpzwoGyfckbabbrCjs2ctHK9StyccUmpLKKbxgNwOJr7g7MKGlxfJHf3l9eeKtmwk1qdHExUkgd7d9BXcNoPHH6ooYyePIbkWeBzCAHogTBSBsIqdfWa6Y8ussgezEoSh4YvXyyFO5kccIOXHnfImph2JGGglnwH6uXxnVLH9XRFaKcOiBmLlJKnfgLcgY0zWkwqyJPCzKSPWOuWWLRIXWI7lfecNoi5lBC1WyXbEJPCzKSPWOuWqxcAQOf)a0IfoDsdd1DCKXisfduGjgY8CypeAOawgKIcUmoTqhJ2n2njbbLiiiIlrYwykKSNDcRflC6KggQ74iJrKkgOatm5y3Gg3IfoDsdd1DCKXisfduGjMUGmgrQeAOawgKIcUmoTqhJ2n2njbbLii4Y8ussgCzCAHogTBSBscUCvmgwCV0tqqexIKTWuizp7eMGGCIXsPgAi07YvXyyF8tVwSWPtAyOUJJmgrQyGcmX2qYuUuZYeAOaEbnMkxAmedU0gJ2fJivSuaDzEkjjdUmoTqhJ2n2njbxUkgdlUx6jiiIlrYwykKSNDctqqenoSPWsckF4RgsaqQmiffu3Xr(IrKkgUCvmgwCGz6WoqLV6uXTyHtN0WqDhhzmIuXafyIftfxUyePsiNh3HVAS0yfdSxcnuadOmiffu3Xr(IrKkgUCvmgwCGz6WoqLV6uXccuPdeZLRUJJmVEUUe0uXPhasbugKIckzz3G5lgrQyyjjzccuGNZDzhIyPXxDQyFCbwV6uXaLMRiiidsrb1fKXisfckbGwSWPtAyOUJJmgrQyGcmXkCOiUoeb5nQi0qbmv6aXa1fy9Umn28HkDGyyvqNwSWPtAyOUJJmgrQyGcmX2qYuUuZYeAOagqxMNssYGlJtl0XODJDtsWLRIXWI7LEsxqJPYLgdXGlTXODXisfliiIlrYwykKSNDctqqKf0yQCPXqm4sBmAxmIuXccIOXHnfwsq5dF1qcasLbPOG6ooYxmIuXWLRIXWIdmth2bQ8vNkUflC6KggQ74iJrKkgOatSkWJoyePsOHcyzqkkOUJJ8fJivmSKKmbbzqkkOKLDdMVyePIHGsKsLoqS4UeRanC6KgmMkUCXisf6sSkfqr04WMcDiMQG34IrKQGq40bjFzJRgglobdqlw40jnmu3XrgJivmqbMyoetvWBCXisLqdfWYGuuqjl7gmFXisfdbLiLkDGyXDjwbA40jnymvC5IrKk0LyvA40bjFzJRgg7dXTflC6KggQ74iJrKkgOatmYZ5CXisLqdfWYGuuWchLl7HHLKK1IfoDsdd1DCKXisfduGjwCRa3cV3K662KeUflC6KggQ74iJrKkgOatmQt4HlxmIuBXcNoPHH6ooYyePIbkWedZRe20lwhJgHCECh(QXsJvmWEj0qb8YulJreYhUflC6KggQ74iJrKkgOatSkWJoyePsOHcyQ0bIf3LyfOHtN0GXuXLlgrQqxIvPa6Y8ussgCzCAHogTBSBscUCvmgwC6liiIlrYwykKSNDcdGwSWPtAyOUJJmgrQyGcmX0yV6gsi0qb8cAmvU0yOXy8y0ifRh8v3qIKXODdjsInuqClw40jnmu3XrgJivmqbMyulZehJr7QBiHqdfWlOXu5sJHgJXJrJuSEWxDdjsgJ2nKij2qbXTyHtN0WqDhhzmIuXafyIjh0Uj1v3XrgtOHcyzqkkOUGmgrQWssYAXcNoPHH6ooYyePIbkWeJ6WyeUnOucnuaJtWJ8yfOeqScE4lVGs0jnPYGuuqDbzmIuHLKK1IfoDsdd1DCKXisfduGjgw5O45IrKAlwlw40jnmu3XiZkgyKXoH8HjKfvmWypM7ckHqiJdidSmiffCzCAHogTBSBscckrqqgKIcQliJrKkeuslw40jnmu3XiZkgOatmKXoH8HjKfvmWyDtJ2f7XCxqjeczCazGDjs2ctHK9StysLbPOGlJtl0XODJDtsqqjsLbPOG6cYyePcbLiiiIlrYwykKSNDctQmiffuxqgJiviOKwSWPtAyOUJrMvmqbMyiJDc5dtilQyGX6MgTl2J5UlxfJHjukbymRdfHqghqgyxMNssYGlJtl0XODJDtsWLRIXW(i63L5PKKmOUGmgrQWLRIXWeczCa5lFWmWUmpLKKb1fKXisfUCvmgMqdfWYGuuqDbzmIuHLKKj1Lizlmfs2ZoH1IfoDsdd1DmYSIbkWedzStiFyczrfdmw30ODXEm3D5QymmHsjaJzDOieY4aYa7Y8ussgCzCAHogTBSBscUCvmgMqiJdiF5dMb2L5PKKmOUGmgrQWLRIXWeAOawgKIcQliJrKkeuIuxIKTWuizp7ewlw40jnmu3XiZkgOatmKXoH8HjKfvmWypM7UCvmgMqPeGXSoueAOa2Lizlmfs2ZoHriKXbKb2L5PKKm4Y40cDmA3y3KeC5QymS4I(DzEkjjdQliJrKkC5QymmHqghq(YhmdSlZtjjzqDbzmIuHlxfJHBXcNoPHH6ogzwXafyIbI57OCfMq4tQyG1DmYS6LqdfWacOUJrMvOxiIaFbX8vgKIsqWLizlmfs2ZoHjv3XiZk0lerGVUmpLKKbGuarg7eYhgI1nnAxShZDbLifqrCjs2ctHK9Stysfr3XiZk0perGVGy(kdsrji4sKSfMcj7zNWKkIUJrMvOFiIaFDzEkjjtqq3XiZk0p0L5PKKm4YvXyybbDhJmRqVqeb(cI5RmifLuafr3XiZk0perGVGy(kdsrjiO7yKzf6f6Y8ussgSaUHoPjoW6ogzwH(HUmpLKKblGBOtAaiiO7yKzf6fIiWxxMNssYKkIUJrMvOFiIaFbX8vgKIsQUJrMvOxOlZtjjzWc4g6KM4aR7yKzf6h6Y8ussgSaUHoPbGGGiiJDc5ddX6MgTl2J5UGsKcOi6ogzwH(Hic8feZxzqkkPaQ7yKzf6f6Y8ussgSaUHoPr803hKXoH8HHypM7UCvmgwqazStiFyi2J5UlxfJHfx3XiZk0l0L5PKKmybCdDsJ40pacc6ogzwH(Hic8feZxzqkkPaQ7yKzf6fIiWxqmFLbPOKQ7yKzf6f6Y8ussgSaUHoPjoW6ogzwH(HUmpLKKblGBOtAsbu3XiZk0l0L5PKKmybCdDsJ4PVpiJDc5ddXEm3D5QymSGaYyNq(WqShZDxUkgdlUUJrMvOxOlZtjjzWc4g6KgXPFaeeaueDhJmRqVqeb(cI5RmifLGGUJrMvOFOlZtjjzWc4g6KM4aR7yKzf6f6Y8ussgSaUHoPbGua1DmYSc9dDzEkjjdUCu8iv3XiZk0p0L5PKKmybCdDsJ4PV4iJDc5ddXEm3D5QymSuKXoH8HHypM7UCvmg2hDhJmRq)qxMNssYGfWn0jnIt)ccIO7yKzf6h6Y8ussgC5O4rkG6ogzwH(HUmpLKKbxUkgdt803hKXoH8HHyDtJ2f7XC3LRIXWsrg7eYhgI1nnAxShZDxUkgdlUF6jfqDhJmRqVqxMNssYGfWn0jnIN((Gm2jKpme7XC3LRIXWcc6ogzwH(HUmpLKKbxUkgdt803hKXoH8HHypM7UCvmgwQUJrMvOFOlZtjjzWc4g6KgX7LEafzStiFyi2J5UlxfJH9bzStiFyiw30ODXEm3D5QymSGaYyNq(WqShZDxUkgdlUUJrMvOxOlZtjjzWc4g6KgXPFbbKXoH8HHypM7ckbabbDhJmRq)qxMNssYGlxfJHjE6loYyNq(WqSUPr7I9yU7YvXyyPaQ7yKzf6f6Y8ussgSaUHoPr803hKXoH8HHyDtJ2f7XC3LRIXWccIO7yKzf6fIiWxqmFLbPOKciYyNq(WqShZDxUkgdlUUJrMvOxOlZtjjzWc4g6KgXPFbbKXoH8HHypM7ckbaaaaaaaqqqJLgRqDQ4RM3YW(Gm2jKpme7XC3LRIXWaiiiIUJrMvOxiIaFbX8vgKIsQiUejBHPqYE2jmPaQ7yKzf6hIiWxqmFLbPOKciGIGm2jKpme7XCxqjcc6ogzwH(HUmpLKKbxUkgdlo9bqkGiJDc5ddXEm3D5QymS4(PNGGUJrMvOFOlZtjjzWLRIXWep9fhzStiFyi2J5UlxfJHbaabbr0DmYSc9dre4liMVYGuusbueDhJmRq)qeb(6Y8ussMGGUJrMvOFOlZtjjzWLRIXWcc6ogzwH(HUmpLKKblGBOtAIdSUJrMvOxOlZtjjzWc4g6KgaaaGuafr3XiZk0lCWqx4qW3K6gord4SC5QlhyWLXccHthK8LnUAySp(LkImiffmCIgWz5YLuyfiOebHWPds(YgxnmwCVsLbPOGHt0aolxUbDyiOeaAXcNoPHH6ogzwXafyIbI57OCfMq4tQyG1DmYS6NqdfWacOUJrMvOFiIaFbX8vgKIsqWLizlmfs2ZoHjv3XiZk0perGVUmpLKKbGuarg7eYhgI1nnAxShZDbLifqrCjs2ctHK9Stysfr3XiZk0lerGVGy(kdsrji4sKSfMcj7zNWKkIUJrMvOxiIaFDzEkjjtqq3XiZk0l0L5PKKm4YvXyybbDhJmRq)qeb(cI5RmifLuafr3XiZk0lerGVGy(kdsrjiO7yKzf6h6Y8ussgSaUHoPjoW6ogzwHEHUmpLKKblGBOtAaiiO7yKzf6hIiWxxMNssYKkIUJrMvOxiIaFbX8vgKIsQUJrMvOFOlZtjjzWc4g6KM4aR7yKzf6f6Y8ussgSaUHoPbGGGiiJDc5ddX6MgTl2J5UGsKcOi6ogzwHEHic8feZxzqkkPaQ7yKzf6h6Y8ussgSaUHoPr803hKXoH8HHypM7UCvmgwqazStiFyi2J5UlxfJHfx3XiZk0p0L5PKKmybCdDsJ40pacc6ogzwHEHic8feZxzqkkPaQ7yKzf6hIiWxqmFLbPOKQ7yKzf6h6Y8ussgSaUHoPjoW6ogzwHEHUmpLKKblGBOtAsbu3XiZk0p0L5PKKmybCdDsJ4PVpiJDc5ddXEm3D5QymSGaYyNq(WqShZDxUkgdlUUJrMvOFOlZtjjzWc4g6KgXPFaeeaueDhJmRq)qeb(cI5RmifLGGUJrMvOxOlZtjjzWc4g6KM4aR7yKzf6h6Y8ussgSaUHoPbGua1DmYSc9cDzEkjjdUCu8iv3XiZk0l0L5PKKmybCdDsJ4PV4iJDc5ddXEm3D5QymSuKXoH8HHypM7UCvmg2hDhJmRqVqxMNssYGfWn0jnIt)ccIO7yKzf6f6Y8ussgC5O4rkG6ogzwHEHUmpLKKbxUkgdt803hKXoH8HHyDtJ2f7XC3LRIXWsrg7eYhgI1nnAxShZDxUkgdlUF6jfqDhJmRq)qxMNssYGfWn0jnIN((Gm2jKpme7XC3LRIXWcc6ogzwHEHUmpLKKbxUkgdt803hKXoH8HHypM7UCvmgwQUJrMvOxOlZtjjzWc4g6KgX7LEafzStiFyi2J5UlxfJH9bzStiFyiw30ODXEm3D5QymSGaYyNq(WqShZDxUkgdlUUJrMvOFOlZtjjzWc4g6KgXPFbbKXoH8HHypM7ckbabbDhJmRqVqxMNssYGlxfJHjE6loYyNq(WqSUPr7I9yU7YvXyyPaQ7yKzf6h6Y8ussgSaUHoPr803hKXoH8HHyDtJ2f7XC3LRIXWccIO7yKzf6hIiWxqmFLbPOKciYyNq(WqShZDxUkgdlUUJrMvOFOlZtjjzWc4g6KgXPFbbKXoH8HHypM7ckbaaaaaaaqqqJLgRqDQ4RM3YW(Gm2jKpme7XC3LRIXWaiiiIUJrMvOFiIaFbX8vgKIsQiUejBHPqYE2jmPaQ7yKzf6fIiWxqmFLbPOKciGIGm2jKpme7XCxqjcc6ogzwHEHUmpLKKbxUkgdlo9bqkGiJDc5ddXEm3D5QymS4(PNGGUJrMvOxOlZtjjzWLRIXWep9fhzStiFyi2J5UlxfJHbaabbr0DmYSc9cre4liMVYGuusbueDhJmRqVqeb(6Y8ussMGGUJrMvOxOlZtjjzWLRIXWcc6ogzwHEHUmpLKKblGBOtAIdSUJrMvOFOlZtjjzWc4g6KgaaaGuafr3XiZk0pCWqx4qW3K6gord4SC5QlhyWLXccHthK8LnUAySp(LkImiffmCIgWz5YLuyfiOebHWPds(YgxnmwCVsLbPOGHt0aolxUbDyiOeaqvufffa]] )


end