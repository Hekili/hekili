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
                if talent.streamline.enabled then applyBuff( "streamline" ) end
                removeBuff( "brutal_projectiles" )
            end,

            finish = function ()
                if buff.volley.down then removeBuff( "trick_shots" ) end
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


    spec:RegisterPack( "Marksmanship", 20220323, [[d8KLAcqiIOhrvk1LauQ2eH6tqLgLk0PubRcqG6vasZcr4web2fOFHi1WqQQJrvzzuv9mejMgvP4AivzBac9nIGACisY5icY6au8oaLqnpQsUhuX(is9pabYbbeulKi0dbenrejLUiGsYhbuIgjGaQtciiRKi5LaciZKQuDtejf7eq1pbusnuaLGLIiP6PamverFfqaglsf7fH)kPbRQdlSyI6XuzYsCzuBgjFgQA0qXPvSAaLqEnsz2Q0Tvr7MYVfnCc54uLswUsphY0jDDG2ou67iQXJuPZtvSEaLY8jy)snHpcssaOektaC)03VF6tk(jfOFsXBKq(9gcaQhrmbarHJwGNjayXjtaGutS0qNHHWmIiaik8CZOqqscaOeCDmbaVD)yuvecyinPXpkgqzOlpjnAobVHoP52GsjnAoDKMaGm4CvGqgHmbGsOmbW9tF)(PpP4NuG(jfVrc53pbGauXKlbaaZjqsaaZukSritaOWihbasnXsdDggcZiQFGadAkVTuKAI1HPF)Kcj63p997VLQLciXegEgbmTusq)aNjtLGwPFsDgLxSC)dQFl1(J(pzhMWgx)kgU)OusRFxyKM8CV9FgwGNHTusq)K6mYJ54s)rPKw)I2j3r90p5rX0pG5ei7himWcEh2sjb97Dw7hiqE2jmu)fg5XC9Ry4z7hij1I6hLNSoNmcsa4oifrqsca6ooAimPIiijbW9rqscaSfYxUqircaUDuENGaGgx2uis5O4PsLoqeKTq(YL(f3)yvQ7GhJ2V4(LbPOGiLJINkv6arWLpJXq97v)0Jaq40jncaiLJINkctQekbW9tqscaSfYxUqircaUDuENGaWcAmvU4zOOe0HPMu1na2YTsTb(t2ueKTq(YL(f3VmiffK6gE4fvpJLgeuebGWPtAeaOn3BfHjvcLa4KcbjjaWwiF5cHeja42r5DccalOXu5INHIsqhMAsv3ayl3k1g4pztrq2c5lxiaeoDsJaa1n8WLkctQekbW9gcssaGTq(YfcjsaWTJY7eeao2VlXYwykKMNDcRFX97Y8wsYgCzuAHog(ASBsgU8zmgQFV6hVR0VGq)s2VlXYwykKMNDcRFX9lz)UelBHPqBWJrRub3VGq)UelBHPqBWJrRub3V4(p2VlZBjjBqYZTurIMDueC5Zymu)E1pExPFbH(DzEljzdsEULks0SJIGlFgJH6x6(jf63)H(fe6xJfpRqDo5QM1YW97v)(OF)cc97Y8wsYgCzuAHog(ASBsgU8zmgQFP73h97xC)HthSCLn(Cyu)s3pP0)H(f3)X(LS)nMsLXYMcJsbbz6oif1VGq)BmLkJLnfgLccU8zmgQFP7xc1VGq)s2VlXYwykKMNDcR)deacNoPraOKGYxUQHicLa40JGKeaylKVCHqIeaC7O8obbGf0yQCXZqucEPYfpx5tzErq2c5lx6xC)ASvDdrWLpJXq97v)4DL(f3VlZBjjBqQBSmC5Zymu)E1pExHaq40jncaASvDdrekbWbIeKKaaBH8LlesKaq40jncau3yzcaUDuENGaGgBv3qeeuu)I7FbnMkx8meLGxQCXZv(uMxeKTq(Yfca3X4QRqaWp9iucGlHjijbGWPtAeay6k6MOblxrysLaaBH8LlesKqjaoPIGKeacNoPraG8ClvKOzhfraGTq(YfcjsOeaxcrqscaSfYxUqircaUDuENGaGlZBjjBWLrPf6y4RXUjz4YNXyO(9QF8Us)I7)y)s2Vgx2uitxr3eny5kctQq2c5lx6xqOFzqkkO8nZYfePqqr9FOFbH(LSFxILTWuinp7ew)cc97Y8wsYgCzuAHog(ASBsgU8zmgQFP73h97xqOF5eH6xC)udEmAD5Zymu)E1p9iaeoDsJaa5yUJHVg7MKjucG7J(eKKaaBH8LlesKaGBhL3jiaCSFxM3ss2GyZ7L9ax(mgd1Vx9J3v6xqOFj7xJlBkeBEVShiBH8Ll9li0VglEwH6CYvnRLH73R(95V)d9lU)J9lz)BmLkJLnfgLccY0DqkQFbH(3ykvglBkmkfeC5Zymu)s3VeQFbH(dNoy5kB85WO(LgN(3ykvglBkmkfe0LGM2pqW97V)deacNoPrayzuAHog(ASBsMqjaUpFeKKaaBH8LlesKaGBhL3jiaidsrbxgLwOJHVg7MKHGI6xqOFj73LyzlmfsZZoHraiC6KgbaS59YEiucG7ZpbjjaeoDsJaGCSBGNjaWwiF5cHejucG7Juiijba2c5lxiKiba3okVtqaWLyzlmfsZZoH1V4(p2VmiffCzuAHog(ASBsgckQFbH(DzEljzdUmkTqhdFn2njdx(mgd1V097J(9FOFbH(Djw2ctH2GhJwPcUFX9ldsrbjp3sfjA2rrqqr9li0VlXYwykelBkgpB)cc97sSSfMcn2T5n3s)cc9lNiu)I7NAWJrRlFgJH63R(9tpcaHtN0iaOliJWKkHsaCFEdbjjaWwiF5cHeja42r5DccalOXu5INHiWf)y4RimPIGSfYxU0V4(p2VlZBjjBWLrPf6y4RXUjz4YNXyO(LUFF0VFbH(LSFxILTWuinp7ew)cc9lz)ACztHLeu(YvnebzlKVCP)d9lUFzqkkOUJJwfHjveC5Zymu)sJt)mDzhOYvDozcaHtN0iaSHOPuPMLjucG7JEeKKaaBH8LlesKaq40jncaXCYLkctQeaC7O8obbGJ9ldsrb1DC0QimPIGlFgJH6xAC6NPl7avUQZj3VGq)uPdeXLQUJJgVEQUe00(LUF63)H(f3)X(LbPOGIw2niUIWKkcwsYw)cc9tbEV1LDyIfpx15K73R(DbsR6CY9d0(X7k9li0VmiffuxqgHjviOO(fe6hXAvonqeuhE9tQQEJix)I7FbnMkx8meXULvunPQkgUcAY3XOng(k2b)CHSfYxU0)bcaopUlx1yXZkIa4(iucG7disqscaSfYxUqircaUDuENGaav6ar9d0(DbsRlJNT(9QFQ0bIGNbDjaeoDsJaqHdft1HjOTXjHsaCFsycssaGTq(YfcjsaWTJY7eeao2VlZBjjBWLrPf6y4RXUjz4YNXyO(LUFF0VFX9VGgtLlEgIax8JHVIWKkcYwiF5s)cc9lz)UelBHPqAE2jS(fe6xY(xqJPYfpdrGl(XWxrysfbzlKVCPFbH(LSFnUSPWsckF5QgIGSfYxU0)H(f3Vmiffu3XrRIWKkcU8zmgQFPXPFMUSdu5QoNmbGWPtAea2q0uQuZYekbW9rQiijba2c5lxiKiba3okVtqaqgKIcQ74OvrysfbljzRFbH(LbPOGIw2niUIWKkcckQFX9tLoqu)s3VlrA)aT)WPtAWyo5sfHjvOlrA)I7)y)s2Vgx2uOdZCg8gveMuHSfYxU0VGq)HthSCLn(Cyu)s3pP0)bcaHtN0iaCcE1bHjvcLa4(KqeKKaaBH8LlesKaGBhL3jiaidsrbfTSBqCfHjveeuu)I7NkDGO(LUFxI0(bA)HtN0GXCYLkctQqxI0(f3F40blxzJphg1Vx97neacNoPraWHzodEJkctQekbW9tFcssaGTq(YfcjsaWTJY7eeaKbPOGfokv2ddljzJaq40jnca0M7TIWKkHsaC)(iijbGWPtAeaI6j4w4TMuv3MKreaylKVCHqIekbW97NGKeacNoPraG6gE4sfHjvcaSfYxUqircLa4(jfcssaGTq(YfcjsaiC6KgbaeVIytRiDm8eaC7O8obbGLPwgHjKVmbaNh3LRAS4zfraCFekbW97neKKaaBH8LlesKaGBhL3jiaqLoqu)s3VlrA)aT)WPtAWyo5sfHjvOlrA)I7)y)UmVLKSbxgLwOJHVg7MKHlFgJH6x6(Px)cc9lz)UelBHPqAE2jS(pqaiC6KgbGtWRoimPsOea3p9iijba2c5lxiKiba3okVtqaybnMkx8m0yeAm8KJ1dQQBis0y4RHirXgkicYwiF5cbGWPtAea0yR6gIiucG7hisqscaSfYxUqircaUDuENGaWcAmvU4zOXi0y4jhRhuv3qKOXWxdrIInuqeKTq(YfcaHtN0iaqTmdSng(QUHicLa4(LWeKKaaBH8LlesKaGBhL3jiaidsrb1fKrysfwsYgbGWPtAeaKd81KQQ74OHiucG7NurqscaSfYxUqircaUDuENGaakbVYJvGIark4LR8cksN0GSfYxU0V4(LbPOG6cYimPcljzJaq40jncauxgHXTbLsOea3VeIGKeacNoPraaPCu8urysLaaBH8LlesKqjucafMkaVkbjjaUpcssaiC6KgbaxcAkVveMujaWwiF5cHejucG7NGKeaylKVCHqIeacNoPraWLGMYBfHjvcaUDuENGaWcAmvU4ziIfHbeydvfTP7gNHoPbzlKVCPFbH(rj4vESc0gpbQQzErvr5GsdYwiF5s)cc9FSFxAfWrHlJLxuCRjvLkxf0yiBH8Ll9lUFj7FbnMkx8meXIWacSHQI20DJZqN0GSfYxU0)bca3X4QRqaGuOpHsaCsHGKeaylKVCHqIeacNoPraq3W8wGZDa2gdFfHjvcafg52rKoPraayz2FGHJs)Hv6NKByElW5oaBC)ahybGSF24ZHrKOFYC)L0Wv7VK9Rygu)u52VOB4Hxu)YSlarC)JIBPFzUFnZ(rIIZtp9hwPFYC)UWWv7F5Omxp9tYnmVv)irSBOgx)YGuuiiba3okVtqaqY(1yXZkCqvr3WdVekbW9gcssaGTq(YfcjsaWTJY7eeaCjw2ctH08Sty9lUFxM3ss2G6cYimPcx(mgd1V4(DzEljzdUmkTqhdFn2njdx(mgd1VGq)s2VlXYwykKMNDcRFX97Y8wsYguxqgHjv4YNXyicaHtN0ia4I7TgoDsREhKsa4oiTAXjtaq3XOXkIqjao9iijba2c5lxiKibGWPtAeaCX9wdNoPvVdsjaChKwT4Kja4kicLa4arcssaGTq(YfcjsaWTJY7eeacNoy5kB85WO(9QFsHaas3XPea3hbGWPtAeaCX9wdNoPvVdsjaChKwT4KjaGucLa4sycssaGTq(YfcjsaWTJY7eeacNoy5kB85WO(LUF)eaq6ooLa4(iaeoDsJaGlU3A40jT6DqkbG7G0QfNmbaDhhneMurekHsaq0YU8uoucssaCFeKKaq40jncaYPQxUuPUHhUqEm8vnP7yeaylKVCHqIekbW9tqscaHtN0iaqDzeg3gukba2c5lxiKiHsaCsHGKeaylKVCHqIeaC7O8obbGf0yQCXZqucEPYfpx5tzErq2c5lxiaeoDsJaGgBv3qeHsaCVHGKeaylKVCHqIeaeTSlqAvNtMaGp6taiC6KgbGsckF5QgIia42r5DccaHthSCLn(Cyu)s3VV(fe6xY(Djw2ctH08Sty9lUFj7xJlBkeBEVShiBH8LlekbWPhbjjaWwiF5cHeja42r5DccaHthSCLn(Cyu)E1pP0V4(p2VK97sSSfMcP5zNW6xC)s2Vgx2ui28Ezpq2c5lx6xqO)WPdwUYgFomQFV63F)hiaeoDsJaqmNCPIWKkHsaCGibjjaWwiF5cHeja42r5DccaHthSCLn(Cyu)s3V)(fe6)y)UelBHPqAE2jS(fe6xJlBkeBEVShiBH8Ll9FOFX9hoDWYv24ZHr9Jt)(jaeoDsJaas5O4PIWKkHsOeaCfebjjaUpcssaGTq(YfcjsaWTJY7eeao2VmiffuxqgHjviOO(f3VmiffCzuAHog(ASBsgckQFX97sSSfMcP5zNW6)q)cc9FSFzqkkOUGmctQqqr9lUFzqkki55wQirZokcckQFX97sSSfMcTbpgTsfC)h6xqO)J97sSSfMcXYMIXZ2VGq)UelBHPqJDBEZT0)H(f3VmiffuxqgHjviOO(fe6xorO(f3p1GhJwx(mgd1Vx97Ju6xqO)J97sSSfMcP5zNW6xC)YGuuWLrPf6y4RXUjziOO(f3p1GhJwx(mgd1Vx9lHjL(pqaiC6KgbazEr8sBm8ekbW9tqscaSfYxUqircaUDuENGaGmiffuxqgHjviOO(fe63L5TKKnOUGmctQWLpJXq9lD)Kc97xqOF5eH6xC)udEmAD5Zymu)E1VpGibGWPtAeaKVzwQuGRhcLa4KcbjjaWwiF5cHeja42r5DccaYGuuqDbzeMuHGI6xqOFxM3ss2G6cYimPcx(mgd1V09tk0VFbH(LteQFX9tn4XO1LpJXq97v)(aIeacNoPraimhJ0nUvxCVekbW9gcssaGTq(YfcjsaWTJY7eeaKbPOG6cYimPcbf1VGq)UmVLKSb1fKrysfU8zmgQFP7NuOF)cc9lNiu)I7NAWJrRlFgJH63R(LqeacNoPraGAww(MzHqjao9iijba2c5lxiKiba3okVtqaqgKIcQliJWKkSKKncaHtN0iaCh8yuufyrGf8NSPekbWbIeKKaaBH8LlesKaGBhL3jiaidsrb1fKrysfckQFX9FSFzqkkO8nZYfePqqr9li0VglEwHy44QyGICA)E1VF63)H(fe6xorO(f3p1GhJwx(mgd1Vx97hi2VGq)h73LyzlmfsZZoH1V4(LbPOGlJsl0XWxJDtYqqr9lUFQbpgTU8zmgQFV6xc7V)deacNoPraquQtAekHsaaPeKKa4(iijba2c5lxiKiba3okVtqaqJlBkePCu8uPshicYwiF5s)I7)y)IwgBfVRa9brkhfpveMu7xC)YGuuqKYrXtLkDGi4YNXyO(9QF61VGq)YGuuqKYrXtLkDGiyjjB9FOFX9FSFzqkk4YO0cDm81y3KmSKKT(fe6xY(Djw2ctH08Sty9FGaq40jncaiLJINkctQekbW9tqscaHtN0iaqBU3kctQeaylKVCHqIekbWjfcssaGTq(YfcjsaWTJY7eeao2VlXYwykKMNDcRFX9FSFxM3ss2GlJsl0XWxJDtYWLpJXq97v)4DL(p0VGq)s2VlXYwykKMNDcRFX9lz)UelBHPqBWJrRub3VGq)UelBHPqBWJrRub3V4(p2VlZBjjBqYZTurIMDueC5Zymu)E1pExPFbH(DzEljzdsEULks0SJIGlFgJH6x6(jf63)H(fe6xorO(f3p1GhJwx(mgd1Vx97JE9FOFX9FSFj7FJPuzSSPWOuqqMUdsr9li0)gtPYyztHrPGGGI6)abGWPtAeakjO8LRAiIqjaU3qqscaSfYxUqircaUDuENGaGgBv3qeeuu)I7FbnMkx8meLGxQCXZv(uMxeKTq(YfcaHtN0iaqDJLjucGtpcssaGTq(YfcjsaWTJY7eeawqJPYfpdrj4Lkx8CLpL5fbzlKVCPFX9RXw1nebx(mgd1Vx9J3v6xC)UmVLKSbPUXYWLpJXq97v)4DfcaHtN0iaOXw1nerOeahisqscaHtN0iaW0v0nrdwUIWKkba2c5lxiKiHsaCjmbjjaWwiF5cHeja42r5Dccah73L5TKKnOUGmctQWLpJXq97v)4DL(fe6xgKIcQliJWKkeuu)h6xC)h7xY(3ykvglBkmkfeKP7Guu)cc9lz)BmLkJLnfgLccckQFX9FS)nMsLXYMcJsbblGBOtA9d0(3ykvglBkmkfeCS(9QF)0VFbH(3ykvglBkmkfeCS(LUFGi97)q)cc9VXuQmw2uyukiiOO(f3)gtPYyztHrPGGlFgJH6x6(9jH6xqO)WPdwUYgFomQFP73x)h6xqOF5eH6xC)udEmAD5Zymu)E1VF6taiC6KgbaYZTurIMDueHsaCsfbjjaeoDsJaa1n8WLkctQeaylKVCHqIekbWLqeKKaaBH8LlesKaGBhL3jiaqLoqu)aTFxG06Y4zRFV6NkDGi4zqxcaHtN0iau4qXuDycABCsOea3h9jijbGWPtAeaI6j4w4TMuv3MKreaylKVCHqIekbW95JGKeaylKVCHqIeaC7O8obbaxM3ss2GlJsl0XWxJDtYWLpJXq97v)4DL(f3)X(LSFnUSPqMUIUjAWYveMuHSfYxU0VGq)YGuuq5BMLlisHGI6)q)cc9lz)UelBHPqAE2jS(fe63L5TKKn4YO0cDm81y3KmC5Zymu)cc9lNiu)I7NAWJrRlFgJH63R(PhbGWPtAeaihZDm81y3KmHsaCF(jijba2c5lxiKiba3okVtqa4y)YGuuWsckF5QgIGGI6xqOFj7xJlBkSKGYxUQHiiBH8Ll9li0VCIq9lUFQbpgTU8zmgQFV63N)(p0V4(p2VK9VXuQmw2uyukiit3bPO(fe6xY(3ykvglBkmkfeeuu)I7)y)BmLkJLnfgLccwa3qN06hO9VXuQmw2uyuki4y97v)(OF)cc9VXuQmw2uyuki4y9lD)Ed97xqO)nMsLXYMcJsbbDjOP9Jt)(6)q)cc9VXuQmw2uyukiiOO(f3)gtPYyztHrPGGlFgJH6x6(Lq9li0F40blxzJphg1V097R)deacNoPrayzuAHog(ASBsMqjaUpsHGKeaylKVCHqIeaC7O8obbazqkk4YO0cDm81y3Kmeuu)cc9lz)UelBHPqAE2jS(f3)X(LbPOGIw2niUIWKkcwsYw)cc9lz)ACztHomZzWBurysfYwiF5s)cc9hoDWYv24ZHr97v)(7)q)I7)y)s2Vgx2uyjbLVCvdrq2c5lx6xqOFj7hXAvonqeuhE9tQQ(f56xqOFeRv50arqD41pPQ6nIC9li0VmiffSKGYxUQHiiOO(pqaiC6KgbaS59YEiucG7ZBiijba2c5lxiKiba3okVtqaWLyzlmfsZZoH1V4(PshiQFG2VlqADz8S1Vx9tLoqe8mOB)I7)y)h73L5TKKn4YO0cDm81y3KmC5Zymu)E1pExPFGG7Nu6xC)h7xY(rj4vEScKPOardwUg2Cg1W54lVHMlKTq(YL(fe6xY(14YMcljO8LRAicYwiF5s)h6)q)cc9RXLnfwsq5lx1qeKTq(YL(f3VlZBjjBWsckF5QgIGlFgJH63R(jL(pqaiC6KgbaKYrXtfHjvcLa4(OhbjjaWwiF5cHeja42r5Dccah7FbnMkx8mebU4hdFfHjveKTq(YL(fe6hXAvonqeuhE9tQQ(f56xC)YGuuqDhhTkctQiiOO(f3VmiffeBEVShyjjB9FOFX9RXLnfI0LJZ7ymKTq(YL(f3)X(DzEljzdUmkTqhdFn2njdx(mgd1V097J(9li0VK97sSSfMcP5zNW6xqOFj7xJlBkSKGYxUQHiiBH8Ll9li0pkbVYJvGmffiAWY1WMZOgohF5n0CHSfYxU0)bcaHtN0iaSHOPuPMLjucG7disqscaSfYxUqircaUDuENGaaI1QCAGiOo86Nuv9grU(f3Vmiffu3XrRIWKkcwsYw)I7NkDGiUu1DC041t1LGM2Vx9tV(f3Vmiffu0YUbXveMurqqreacNoPraWHzodEJkctQekbW9jHjijba2c5lxiKiba3okVtqaaXAvonqeuhE9tQQEJix)I7xgKIcQ74OvrysfbljzRFX9tLoqexQ6ooA86P6sqt73R(Px)I7xgKIckAz3G4kctQiiOicaHtN0iaeRlmUIWKkHsaCFKkcssaGTq(YfcjsaWTJY7eeao2)X(Djw2ctHyztX4z7xC)h7xgKIckAz3G4kctQiyjjB9li0pI1QCAGiOo86Nuv9grU(f3)cAmvU4ziIDlROAsvvmCf0KVJrBm8vSd(5czlKVCPFbH(14YMcDX9og(QIHRimPIGSfYxU0)H(fe63LyzlmfASBZBUL(fe63LyzlmfsZZoH1V4(p2VlZBjjBWLrPf6y4RXUjz4YNXyO(LUFsH(9li0VlZBjjBWLrPf6y4RXUjz4YNXyO(9QFF0V)d9li0VlXYwyk0g8y0kvW9lU)J97Y8wsYgK8ClvKOzhfbx(mgd1V09tk0VFbH(LbPOGKNBPIen7OiiOO(p0)H(fe6xgKIcInVx2deuu)I7pC6GLRSXNdJ6x6(91)H(f3)X(LS)nMsLXYMcJsbbz6oif1VGq)s2)gtPYyztHrPGGGI6xC)h7FJPuzSSPWOuqWc4g6Kw)aT)nMsLXYMcJsbbhRFV63p96xqO)nMsLXYMcJsbbhRFP7his)(p0VGq)BmLkJLnfgLccckQFX9VXuQmw2uyuki4YNXyO(LUFF0VFbH(dNoy5kB85WO(LUFF9FOFbH(LteQFX9tn4XO1LpJXq97v)(PhbGWPtAea0fKrysLqjaUpjebjjaWwiF5cHejaeoDsJaqmNCPIWKkba3okVtqaqgKIckAz3G4kctQiyjjB9li0)X(LbPOG6cYimPcbf1VGq)uG3BDzhMyXZvDo5(9QF8Us)aTFxG0QoNC)cc9JyTkNgicQdV(jvvVrKRFX9VGgtLlEgIy3YkQMuvfdxbn57y0gdFf7GFUq2c5lx6)q)I7)y)s2Vgx2uOdZCg8gveMuHSfYxU0VGq)HthSCLn(Cyu)E1V)(p0VGq)h7xgKIcQ74Ovrysfbx(mgd1V09Z0LDGkx15K7xqOFQ0bI4sv3XrJxpvxcAA)s3p97)q)I7pC6GLRSXNdJ6x6(9raW5XD5QglEwrea3hHsaC)0NGKeaylKVCHqIeaC7O8obbGJ97Y8wsYgCzuAHog(ASBsgU8zmgQFP73h97xqOFj73LyzlmfsZZoH1VGq)s2Vgx2uyjbLVCvdrq2c5lx6xqOFucELhRazkkq0GLRHnNrnCo(YBO5czlKVCP)d9lUFQ0bI6hO97cKwxgpB97v)uPdebpd62V4(p2VmiffSKGYxUQHiyjjB9lUFzqkkih4VSg30qvDb5kv6arWss26xqOFnUSPqKUCCEhJHSfYxU0)bcaHtN0iaSHOPuPMLjucG73hbjjaWwiF5cHeja42r5DccaYGuuqrl7gexrysfbbf1VGq)uPde1V097sK2pq7pC6KgmMtUurysf6sKsaiC6KgbahM5m4nQimPsOea3VFcssaGTq(YfcjsaWTJY7eeaKbPOGIw2niUIWKkcckQFbH(PshiQFP73LiTFG2F40jnymNCPIWKk0LiLaq40jncaX6cJRimPsOea3pPqqscaSfYxUqircaHtN0iaG4veBAfPJHNaGBhL3jiaSm1YimH8L7xC)AS4zfQZjx1SwgUFP7VaUHoPraW5XD5QglEwrea3hHsaC)EdbjjaWwiF5cHeja42r5DccaHthSCLn(Cyu)s3VpcaHtN0iaih7g4zcLa4(PhbjjaWwiF5cHeja42r5Dccah73L5TKKn4YO0cDm81y3KmC5Zymu)s3Vp63V4(xqJPYfpdrGl(XWxrysfbzlKVCPFbH(LSFxILTWuinp7ew)cc9lz)ACztHLeu(YvnebzlKVCPFbH(rj4vEScKPOardwUg2Cg1W54lVHMlKTq(YL(p0V4(PshiQFG2VlqADz8S1Vx9tLoqe8mOB)I7)y)YGuuWsckF5QgIGLKS1VGq)ACztHiD548ogdzlKVCP)deacNoPraydrtPsnltOea3pqKGKeaylKVCHqIeaC7O8obbazqkkOUGmctQWss2iaeoDsJaGCGVMuvDhhneHsaC)sycssaGTq(YfcjsaWTJY7eeaqj4vEScueisbVCLxqr6KgKTq(YL(f3VmiffuxqgHjvyjjBeacNoPraG6YimUnOucLa4(jveKKaq40jncaiLJINkctQeaylKVCHqIekHsaq3XOXkIGKea3hbjjaWwiF5cHejaKIiaGyLaq40jncayJDc5ltaaBCbzcaYGuuWLrPf6y4RXUjziOO(fe6xgKIcQliJWKkeuebaSXwT4KjaG8yUkOicLa4(jijba2c5lxiKibGuebaeReacNoPraaBStiFzcayJlitaWLyzlmfsZZoH1V4(LbPOGlJsl0XWxJDtYqqr9lUFzqkkOUGmctQqqr9li0VK97sSSfMcP5zNW6xC)YGuuqDbzeMuHGIiaGn2QfNmbaKUPHVI8yUkOicLa4KcbjjaWwiF5cHejaKIiaGyDOiaeoDsJaa2yNq(YeaWgB1ItMaas30WxrEmxD5Zymeba3okVtqaqgKIcQliJWKkSKKncayJlix5lIja4Y8wsYguxqgHjv4YNXyOkEqgHiaGnUGmbaxM3ss2GlJsl0XWxJDtYWLpJXq97fqq97Y8wsYguxqgHjv4YNXyOkEqgHiucG7neKKaaBH8LlesKaqkIaaI1HIaq40jncayJDc5ltaaBSvlozcaiDtdFf5XC1LpJXqeaC7O8obbazqkkOUGmctQqqreaWgxqUYxetaWL5TKKnOUGmctQWLpJXqv8GmcraaBCbzcaUmVLKSbxgLwOJHVg7MKHlFgJHiucGtpcssaGTq(YfcjsaifraaX6qraiC6KgbaSXoH8LjaGn2QfNmbaKhZvx(mgdraWTJY7eeaCjw2ctH08StyeaWgxqUYxetaWL5TKKnOUGmctQWLpJXqv8GmcraaBCbzcaUmVLKSbxgLwOJHVg7MKHlFgJH6xAGG63L5TKKnOUGmctQWLpJXqv8GmcrOeahisqscaSfYxUqircaHtN0iaO7y0y1hba3okVtqa4y)h7x3XOXku9bXeOkiIRYGuu9li0VlXYwykKMNDcRFX9R7y0yfQ(Gycu1L5TKKT(p0V4(p2p2yNq(YqKUPHVI8yUkOO(f3)X(LSFxILTWuinp7ew)I7xY(1DmAScv)qmbQcI4Qmifv)cc97sSSfMcP5zNW6xC)s2VUJrJvO6hIjqvxM3ss26xqOFDhJgRq1p0L5TKKn4YNXyO(fe6x3XOXku9bXeOkiIRYGuu9lU)J9lz)6ognwHQFiMavbrCvgKIQFbH(1DmAScvFqxM3ss2GfWn0jT(LgN(1DmAScv)qxM3ss2GfWn0jT(p0VGq)6ognwHQpiMavDzEljzRFX9lz)6ognwHQFiMavbrCvgKIQFX9R7y0yfQ(GUmVLKSblGBOtA9lno9R7y0yfQ(HUmVLKSblGBOtA9FOFbH(LSFSXoH8LHiDtdFf5XCvqr9lU)J9lz)6ognwHQFiMavbrCvgKIQFX9FSFDhJgRq1h0L5TKKnybCdDsRFjOF61Vx9Jn2jKVme5XC1LpJXq9li0p2yNq(YqKhZvx(mgd1V09R7y0yfQ(GUmVLKSblGBOtA9t6(93)H(fe6x3XOXku9dXeOkiIRYGuu9lU)J9R7y0yfQ(GycufeXvzqkQ(f3VUJrJvO6d6Y8wsYgSaUHoP1V040VUJrJvO6h6Y8wsYgSaUHoP1V4(p2VUJrJvO6d6Y8wsYgSaUHoP1Ve0p963R(Xg7eYxgI8yU6YNXyO(fe6hBStiFziYJ5QlFgJH6x6(1DmAScvFqxM3ss2GfWn0jT(jD)(7)q)cc9FSFj7x3XOXku9bXeOkiIRYGuu9li0VUJrJvO6h6Y8wsYgSaUHoP1V040VUJrJvO6d6Y8wsYgSaUHoP1)H(f3)X(1DmAScv)qxM3ss2Glhfp9lUFDhJgRq1p0L5TKKnybCdDsRFjOF61V09Jn2jKVme5XC1LpJXq9lUFSXoH8LHipMRU8zmgQFV6x3XOXku9dDzEljzdwa3qN06N097VFbH(LSFDhJgRq1p0L5TKKn4YrXt)I7)y)6ognwHQFOlZBjjBWLpJXq9lb9tV(9QFSXoH8LHiDtdFf5XC1LpJXq9lUFSXoH8LHiDtdFf5XC1LpJXq9lD)(PF)I7)y)6ognwHQpOlZBjjBWc4g6Kw)sq)0RFV6hBStiFziYJ5QlFgJH6xqOFDhJgRq1p0L5TKKn4YNXyO(LG(Px)E1p2yNq(YqKhZvx(mgd1V4(1DmAScv)qxM3ss2GfWn0jT(LG(9r)(bA)yJDc5ldrEmxD5Zymu)E1p2yNq(YqKUPHVI8yU6YNXyO(fe6hBStiFziYJ5QlFgJH6x6(1DmAScvFqxM3ss2GfWn0jT(jD)(7xqOFSXoH8LHipMRckQ)d9li0VUJrJvO6h6Y8wsYgC5Zymu)sq)0RFP7hBStiFzis30WxrEmxD5Zymu)I7)y)6ognwHQpOlZBjjBWc4g6Kw)sq)0RFV6hBStiFzis30WxrEmxD5Zymu)cc9R7y0yfQ(GUmVLKSblGBOtA97v)udEmAD5Zymu)I7hBStiFzis30WxrEmxD5Zymu)aTFDhJgRq1h0L5TKKnybCdDsRFP7NAWJrRlFgJH6xqOFj7x3XOXku9bXeOkiIRYGuu9lU)J9Jn2jKVme5XC1LpJXq9lD)6ognwHQpOlZBjjBWc4g6Kw)KUF)9li0p2yNq(YqKhZvbf1)H(p0)H(p0)H(p0VGq)AS4zfQZjx1SwgUFV6hBStiFziYJ5QlFgJH6)q)cc9lz)6ognwHQpiMavbrCvgKIQFX9lz)UelBHPqAE2jS(f3)X(1DmAScv)qmbQcI4Qmifv)I7)y)h7xY(Xg7eYxgI8yUkOO(fe6x3XOXku9dDzEljzdU8zmgQFP7NE9FOFX9FSFSXoH8LHipMRU8zmgQFP73p97xqOFDhJgRq1p0L5TKKn4YNXyO(LG(Px)s3p2yNq(YqKhZvx(mgd1)H(p0VGq)s2VUJrJvO6hIjqvqexLbPO6xC)h7xY(1DmAScv)qmbQ6Y8wsYw)cc9R7y0yfQ(HUmVLKSbx(mgd1VGq)6ognwHQFOlZBjjBWc4g6Kw)sJt)6ognwHQpOlZBjjBWc4g6Kw)h6)q)h6xC)h7xY(1DmAScvFWbbDHddxtQA48wGZYLQUCGaxg1VGq)s2VmiffmCElWz5sLCyfiOO(pqaaDtfraq3XOXQpcLa4sycssaGTq(YfcjsaiC6KgbaDhJgR(ja42r5Dccah7)y)6ognwHQFiMavbrCvgKIQFbH(Djw2ctH08Sty9lUFDhJgRq1petGQUmVLKS1)H(f3)X(Xg7eYxgI0nn8vKhZvbf1V4(p2VK97sSSfMcP5zNW6xC)s2VUJrJvO6dIjqvqexLbPO6xqOFxILTWuinp7ew)I7xY(1DmAScvFqmbQ6Y8wsYw)cc9R7y0yfQ(GUmVLKSbx(mgd1VGq)6ognwHQFiMavbrCvgKIQFX9FSFj7x3XOXku9bXeOkiIRYGuu9li0VUJrJvO6h6Y8wsYgSaUHoP1V040VUJrJvO6d6Y8wsYgSaUHoP1)H(fe6x3XOXku9dXeOQlZBjjB9lUFj7x3XOXku9bXeOkiIRYGuu9lUFDhJgRq1p0L5TKKnybCdDsRFPXPFDhJgRq1h0L5TKKnybCdDsR)d9li0VK9Jn2jKVmePBA4RipMRckQFX9FSFj7x3XOXku9bXeOkiIRYGuu9lU)J9R7y0yfQ(HUmVLKSblGBOtA9lb9tV(9QFSXoH8LHipMRU8zmgQFbH(Xg7eYxgI8yU6YNXyO(LUFDhJgRq1p0L5TKKnybCdDsRFs3V)(p0VGq)6ognwHQpiMavbrCvgKIQFX9FSFDhJgRq1petGQGiUkdsr1V4(1DmAScv)qxM3ss2GfWn0jT(LgN(1DmAScvFqxM3ss2GfWn0jT(f3)X(1DmAScv)qxM3ss2GfWn0jT(LG(Px)E1p2yNq(YqKhZvx(mgd1VGq)yJDc5ldrEmxD5Zymu)s3VUJrJvO6h6Y8wsYgSaUHoP1pP73F)h6xqO)J9lz)6ognwHQFiMavbrCvgKIQFbH(1DmAScvFqxM3ss2GfWn0jT(LgN(1DmAScv)qxM3ss2GfWn0jT(p0V4(p2VUJrJvO6d6Y8wsYgC5O4PFX9R7y0yfQ(GUmVLKSblGBOtA9lb9tV(LUFSXoH8LHipMRU8zmgQFX9Jn2jKVme5XC1LpJXq97v)6ognwHQpOlZBjjBWc4g6Kw)KUF)9li0VK9R7y0yfQ(GUmVLKSbxokE6xC)h7x3XOXku9bDzEljzdU8zmgQFjOF61Vx9Jn2jKVmePBA4RipMRU8zmgQFX9Jn2jKVmePBA4RipMRU8zmgQFP73p97xC)h7x3XOXku9dDzEljzdwa3qN06xc6NE97v)yJDc5ldrEmxD5Zymu)cc9R7y0yfQ(GUmVLKSbx(mgd1Ve0p963R(Xg7eYxgI8yU6YNXyO(f3VUJrJvO6d6Y8wsYgSaUHoP1Ve0Vp63pq7hBStiFziYJ5QlFgJH63R(Xg7eYxgI0nn8vKhZvx(mgd1VGq)yJDc5ldrEmxD5Zymu)s3VUJrJvO6h6Y8wsYgSaUHoP1pP73F)cc9Jn2jKVme5XCvqr9FOFbH(1DmAScvFqxM3ss2GlFgJH6xc6NE9lD)yJDc5ldr6Mg(kYJ5QlFgJH6xC)h7x3XOXku9dDzEljzdwa3qN06xc6NE97v)yJDc5ldr6Mg(kYJ5QlFgJH6xqOFDhJgRq1p0L5TKKnybCdDsRFV6NAWJrRlFgJH6xC)yJDc5ldr6Mg(kYJ5QlFgJH6hO9R7y0yfQ(HUmVLKSblGBOtA9lD)udEmAD5Zymu)cc9lz)6ognwHQFiMavbrCvgKIQFX9FSFSXoH8LHipMRU8zmgQFP7x3XOXku9dDzEljzdwa3qN06N097VFbH(Xg7eYxgI8yUkOO(p0)H(p0)H(p0)H(fe6xJfpRqDo5QM1YW97v)yJDc5ldrEmxD5Zymu)h6xqOFj7x3XOXku9dXeOkiIRYGuu9lUFj73LyzlmfsZZoH1V4(p2VUJrJvO6dIjqvqexLbPO6xC)h7)y)s2p2yNq(YqKhZvbf1VGq)6ognwHQpOlZBjjBWLpJXq9lD)0R)d9lU)J9Jn2jKVme5XC1LpJXq9lD)(PF)cc9R7y0yfQ(GUmVLKSbx(mgd1Ve0p96x6(Xg7eYxgI8yU6YNXyO(p0)H(fe6xY(1DmAScvFqmbQcI4Qmifv)I7)y)s2VUJrJvO6dIjqvxM3ss26xqOFDhJgRq1h0L5TKKn4YNXyO(fe6x3XOXku9bDzEljzdwa3qN06xAC6x3XOXku9dDzEljzdwa3qN06)q)h6)q)I7)y)s2VUJrJvO6hoiOlCy4AsvdN3cCwUu1Lde4YO(fe6xY(LbPOGHZBbolxQKdRabf1)bcaOBQica6ognw9tOekHsaalVOjncG7N((9tFsXNeMaa5yTXWJiaaeaqysDGdec4albM(7NKy4(Ntr5Q9tLB)4Q74OHWKkc3(x2Bbolx6hLNC)bOMNHYL(DycdpJGTuEFmUFFat)azAy5v5s)4QXLnfshC7xZ(XvJlBkKoq2c5lxWT)J(O7bylL3hJ73pW0pqMgwEvU0pUlOXu5INH0b3(1SFCxqJPYfpdPdKTq(YfC7)Op6Ea2s59X4(jfGPFGmnS8QCPFCxqJPYfpdPdU9Rz)4UGgtLlEgshiBH8Ll42FO9dScyT37)Op6Ea2s59X4(PhW0pqMgwEvU0pUlOXu5INH0b3(1SFCxqJPYfpdPdKTq(YfC7)Op6Ea2s59X4(bIat)azAy5v5s)4UGgtLlEgshC7xZ(XDbnMkx8mKoq2c5lxWT)q7hyfWAV3)rF09aSLY7JX9lHaM(bY0WYRYL(XvJlBkKo42VM9JRgx2uiDGSfYxUGB)h9r3dWwkVpg3Vp6dm9dKPHLxLl9JRgx2uiDWTFn7hxnUSPq6azlKVCb3(p6JUhGTuEFmUFFEdW0pqMgwEvU0pUACztH0b3(1SFC14YMcPdKTq(YfC7)Op6Ea2s59X4(95nat)azAy5v5s)4UGgtLlEgshC7xZ(XDbnMkx8mKoq2c5lxWT)J(O7bylL3hJ73h9aM(bY0WYRYL(XDbnMkx8mKo42VM9J7cAmvU4ziDGSfYxUGB)h9r3dWwkVpg3VpjmW0pqMgwEvU0pUACztH0b3(1SFC14YMcPdKTq(YfC7)Op6Ea2s59X4(9jHbM(bY0WYRYL(XDbnMkx8mKo42VM9J7cAmvU4ziDGSfYxUGB)h9t3dWwkVpg3VpsfW0pqMgwEvU0pUACztH0b3(1SFC14YMcPdKTq(YfC7)Op6Ea2s59X4(9tpGPFGmnS8QCPFCxqJPYfpdPdU9Rz)4UGgtLlEgshiBH8Ll42FO9dScyT37)Op6Ea2s59X4(9debM(bY0WYRYL(XDbnMkx8mKo42VM9J7cAmvU4ziDGSfYxUGB)H2pWkG1EV)J(O7bylL3hJ73pPcy6hitdlVkx6hxucELhRaPdU9Rz)4IsWR8yfiDGSfYxUGB)h9r3dWwQwkGaactQdCGqahyjW0F)Ked3)CkkxTFQC7h3ctfGxf3(x2Bbolx6hLNC)bOMNHYL(DycdpJGTuEFmUF)at)azAy5v5s)4UGgtLlEgshC7xZ(XDbnMkx8mKoq2c5lxWT)J(O7bylL3hJ73pW0pqMgwEvU0pUlOXu5INH0b3(1SFCxqJPYfpdPdKTq(YfC7)Op6Ea2s59X4(9dm9dKPHLxLl9JRlTc4Oq6GB)A2pUU0kGJcPdKTq(YfC7)Op6Ea2s59X4(9dm9dKPHLxLl9JlkbVYJvG0b3(1SFCrj4vEScKoq2c5lxWT)J(O7bylvlfqaaHj1boqiGdSey6VFsIH7FofLR2pvU9JROLD5PCO42)YElWz5s)O8K7pa18muU0Vdty4zeSLY7JX9tkat)azAy5v5s)4UGgtLlEgshC7xZ(XDbnMkx8mKoq2c5lxWT)q7hyfWAV3)rF09aSLY7JX97nat)azAy5v5s)4QXLnfshC7xZ(XvJlBkKoq2c5lxWT)q7hyfWAV3)rF09aSLY7JX9tpGPFGmnS8QCPFC14YMcPdU9Rz)4QXLnfshiBH8Ll42)rF09aSLY7JX9debM(bY0WYRYL(XvJlBkKo42VM9JRgx2uiDGSfYxUGB)h9r3dWwQwkGaactQdCGqahyjW0F)Ked3)CkkxTFQC7hxKIB)l7TaNLl9JYtU)auZZq5s)omHHNrWwkVpg3VpGPFGmnS8QCPFC14YMcPdU9Rz)4QXLnfshiBH8Ll42)rF09aSLY7JX97nat)azAy5v5s)4UGgtLlEgshC7xZ(XDbnMkx8mKoq2c5lxWT)q7hyfWAV3)rF09aSLY7JX9tpGPFGmnS8QCPFCxqJPYfpdPdU9Rz)4UGgtLlEgshiBH8Ll42)rF09aSLY7JX97ZhW0pqMgwEvU0pUACztH0b3(1SFC14YMcPdKTq(YfC7)Op6Ea2s59X4(95hy6hitdlVkx6hxnUSPq6GB)A2pUACztH0bYwiF5cU9F0hDpaBP8(yC)(ifGPFGmnS8QCPFC14YMcPdU9Rz)4QXLnfshiBH8Ll42)r)09aSLY7JX97ZBaM(bY0WYRYL(XvJlBkKo42VM9JRgx2uiDGSfYxUGB)h9t3dWwkVpg3VpVby6hitdlVkx6hxucELhRaPdU9Rz)4IsWR8yfiDGSfYxUGB)h9r3dWwkVpg3Vp6bm9dKPHLxLl9JRgx2uiDWTFn7hxnUSPq6azlKVCb3(p6NUhGTuEFmUFF0dy6hitdlVkx6h3f0yQCXZq6GB)A2pUlOXu5INH0bYwiF5cU9F0hDpaBP8(yC)(OhW0pqMgwEvU0pUOe8kpwbshC7xZ(XfLGx5Xkq6azlKVCb3(p6JUhGTuEFmUFFKkGPFGmnS8QCPFC14YMcPdU9Rz)4QXLnfshiBH8Ll42)rF09aSLY7JX97Jubm9dKPHLxLl9J7cAmvU4ziDWTFn7h3f0yQCXZq6azlKVCb3(p6JUhGTuEFmUFFsiGPFGmnS8QCPFC14YMcPdU9Rz)4QXLnfshiBH8Ll42)rF09aSLY7JX97tcbm9dKPHLxLl9J7cAmvU4ziDWTFn7h3f0yQCXZq6azlKVCb3(p6JUhGTuEFmUF)0hy6hitdlVkx6hxnUSPq6GB)A2pUACztH0bYwiF5cU9F0pDpaBP8(yC)(PpW0pqMgwEvU0pUOe8kpwbshC7xZ(XfLGx5Xkq6azlKVCb3(p6JUhGTuEFmUF)0dy6hitdlVkx6hxnUSPq6GB)A2pUACztH0bYwiF5cU9F0pDpaBP8(yC)(PhW0pqMgwEvU0pUlOXu5INH0b3(1SFCxqJPYfpdPdKTq(YfC7)Op6Ea2s59X4(9tpGPFGmnS8QCPFCrj4vEScKo42VM9JlkbVYJvG0bYwiF5cU9F0hDpaBP8(yC)(LWat)azAy5v5s)4IsWR8yfiDWTFn7hxucELhRaPdKTq(YfC7)Op6Ea2s1sbeaqysDGdec4albM(7NKy4(Ntr5Q9tLB)4Q7y0yfHB)l7TaNLl9JYtU)auZZq5s)omHHNrWwkVpg3pqey6hitdlVkx6hWCcK9J8yAq3(b27xZ(9oy0FzWoOjT(tr8gAU9FK0h6)i9O7bylL3hJ7hicm9dKPHLxLl9JRUJrJvOpiDWTFn7hxDhJgRq1hKo42)r)EdDpaBP8(yC)arGPFGmnS8QCPFC1DmASc9dPdU9Rz)4Q7y0yfQ(H0b3(p6his3dWwkVpg3Vegy6hitdlVkx6hWCcK9J8yAq3(b27xZ(9oy0FzWoOjT(tr8gAU9FK0h6)i9O7bylL3hJ7xcdm9dKPHLxLl9JRUJrJvOpiDWTFn7hxDhJgRq1hKo42)r)ar6Ea2s59X4(LWat)azAy5v5s)4Q7y0yf6hshC7xZ(Xv3XOXku9dPdU9F0V3q3dWwQwkGqNIYv5s)aX(dNoP1)Dqkc2sraajIDea3p98gcaI2KAUmbaVT3UFsnXsdDggcZiQFGadAkVTuEBVD)KAI1HPF)Kcj63p997VLQLYB7T7hiXegEgbmTuEBVD)sq)aNjtLGwPFsDgLxSC)dQFl1(J(pzhMWgx)kgU)OusRFxyKM8CV9FgwGNHTuEBVD)sq)K6mYJ54s)rPKw)I2j3r90p5rX0pG5ei7himWcEh2s5T929lb97Dw7hiqE2jmu)fg5XC9Ry4z7hij1I6hLNSoNmc2s1sfoDsdbfTSlpLdfO4qA5u1lxQu3Wdxipg(QM0DSwQWPtAiOOLD5PCOafhstDzeg3guAlv40jneu0YU8uouGIdP1yR6gIiXqHZcAmvU4zikbVu5INR8PmVOwQWPtAiOOLD5PCOafhsxsq5lx1qejeTSlqAvNtghF0NedfoHthSCLn(CyK0(eeK0LyzlmfsZZoHjwsnUSPqS59YEAPcNoPHGIw2LNYHcuCiDmNCPIWKkjgkCcNoy5kB85WiVifXhL0LyzlmfsZZoHjwsnUSPqS59YEeecNoy5kB85WiV8FOLkC6KgckAzxEkhkqXH0iLJINkctQKyOWjC6GLRSXNdJK2VGWrxILTWuinp7eMGGgx2ui28EzphehoDWYv24ZHr44VLQLkC6KgcO4qAxcAkVveMuBPcNoPHakoK2LGMYBfHjvsChJRUcoKc9jXqHZcAmvU4ziIfHbeydvfTP7gNHoPjiGsWR8yfOnEcuvZ8IQIYbLMGWrxAfWrHlJLxuCRjvLkxf0yXsUGgtLlEgIyryab2qvrB6UXzOtAhAP829dSm7pWWrP)Wk9tYnmVf4ChGnUFGdSaq2pB85WiGf3pzU)sA4Q9xY(vmdQFQC7x0n8WlQFz2fGiU)rXT0Vm3VMz)irX5PN(dR0pzUFxy4Q9VCuMRN(j5gM3QFKi2nuJRFzqkkeSLkC6KgcO4qADdZBbo3byBm8veMujXqHJKAS4zfoOQOB4H3wQWPtAiGIdPDX9wdNoPvVdsjHfNmo6ognwrKyOWXLyzlmfsZZoHj2L5TKKnOUGmctQWLpJXqIDzEljzdUmkTqhdFn2njdx(mgdjiiPlXYwykKMNDctSlZBjjBqDbzeMuHlFgJHAP82E7(j1Y3Wt)uHBm897jb3(ljOS2pOPZTFpjy)ycSC)Ia1(j1zuAHog((bcVBsU)ss2ir)52)q1VIH73L5TKKT(hu)AM9FtdF)A2FHVHN(Pc3y473tcU9tQnbLvy)aHO63sJ7pP6xXWiUFxALrN0q9hl3FiF5(1S)tw7N8OygRFfd3Vp63pIDPvq9FzMC4He9Ry4(rZz)uHJr97jb3(j1MGYA)bOMNHoU4E9aBP82E7(dNoPHakoK2yYujOvQlJYlwMedfoOe8kpwbAmzQe0k1Lr5fll(OmiffCzuAHog(ASBsgcksqWL5TKKn4YO0cDm81y3KmC5ZymK0(OVGa1GhJwx(mgd5LpG4HwQWPtAiGIdPDX9wdNoPvVdsjHfNmoUcQLkC6KgcO4qAxCV1WPtA17GusyXjJdsjbs3XP44JedfoHthSCLn(CyKxKslv40jneqXH0U4ERHtN0Q3bPKWItghDhhneMurKaP74uC8rIHcNWPdwUYgFomsA)TuTuHtN0qqxbHJmViEPngEsmu4CugKIcQliJWKkeuKyzqkk4YO0cDm81y3KmeuKyxILTWuinp7e2bbHJYGuuqDbzeMuHGIeldsrbjp3sfjA2rrqqrIDjw2ctH2GhJwPc(GGWrxILTWuiw2umEwbbxILTWuOXUnV5woiwgKIcQliJWKkeuKGGCIqIPg8y06YNXyiV8rkcchDjw2ctH08StyILbPOGlJsl0XWxJDtYqqrIPg8y06YNXyiVKWKYHwQWPtAiORGakoKw(MzPsbUEiXqHJmiffuxqgHjviOibbxM3ss2G6cYimPcx(mgdjnPqFbb5eHetn4XO1LpJXqE5di2sfoDsdbDfeqXH0H5yKUXT6I7LedfoYGuuqDbzeMuHGIeeCzEljzdQliJWKkC5ZymK0Kc9feKtesm1GhJwx(mgd5LpGylv40jne0vqafhstnllFZSqIHchzqkkOUGmctQqqrccUmVLKSb1fKrysfU8zmgsAsH(ccYjcjMAWJrRlFgJH8sc1sfoDsdbDfeqXH03bpgfvbweyb)jBkjgkCKbPOG6cYimPcljzRLkC6Kgc6kiGIdPfL6KgjgkCKbPOG6cYimPcbfj(Omiffu(Mz5cIuiOibbnw8ScXWXvXaf5uV8t)dccYjcjMAWJrRlFgJH8Ypquq4OlXYwykKMNDctSmiffCzuAHog(ASBsgcksm1GhJwx(mgd5Le2)HwQwQWPtAiisXbPCu8urysLedfoACztHiLJINkv6arIpkAzSv8Uc0hePCu8urysvSmiffePCu8uPshicU8zmgYl6jiidsrbrkhfpvQ0bIGLKSDq8rzqkk4YO0cDm81y3KmSKKnbbjDjw2ctH08StyhAPcNoPHGifO4qAAZ9wrysTLkC6KgcIuGIdPljO8LRAiIedfohDjw2ctH08StyIp6Y8wsYgCzuAHog(ASBsgU8zmgYl8UYbbbjDjw2ctH08StyIL0LyzlmfAdEmALkybbxILTWuOn4XOvQGfF0L5TKKni55wQirZokcU8zmgYl8UIGGlZBjjBqYZTurIMDueC5ZymK0Kc9piiiNiKyQbpgTU8zmgYlF07G4JsUXuQmw2uyukiit3bPibHnMsLXYMcJsbbbfDOLkC6KgcIuGIdPPUXYKyOWrJTQBiccks8cAmvU4zikbVu5INR8PmVOwQWPtAiisbkoKwJTQBiIedfolOXu5INHOe8sLlEUYNY8IeRXw1nebx(mgd5fExrSlZBjjBqQBSmC5ZymKx4DLwQWPtAiisbkoKMPROBIgSCfHj1wQWPtAiisbkoKM8ClvKOzhfrIHcNJUmVLKSb1fKrysfU8zmgYl8UIGGmiffuxqgHjviOOdIpk5gtPYyztHrPGGmDhKIeeKCJPuzSSPWOuqqqrIpUXuQmw2uyukiybCdDsdOBmLkJLnfgLccoMx(PVGWgtPYyztHrPGGJjnqK(hee2ykvglBkmkfeeuK4nMsLXYMcJsbbx(mgdjTpjKGq40blxzJphgjTVdccYjcjMAWJrRlFgJH8Yp9BPcNoPHGifO4qAQB4HlveMuBPcNoPHGifO4q6chkMQdtqBJtsmu4qLoqeqDbsRlJNnVOshicEg0TLkC6KgcIuGIdPJ6j4w4TMuv3MKrTuHtN0qqKcuCin5yUJHVg7MKjXqHJlZBjjBWLrPf6y4RXUjz4YNXyiVW7kIpkPgx2uitxr3eny5kctQccYGuuq5BMLlisHGIoiiiPlXYwykKMNDctqWL5TKKn4YO0cDm81y3KmC5ZymKGGCIqIPg8y06YNXyiVOxlv40jneePafhsVmkTqhdFn2njtIHcNJYGuuWsckF5QgIGGIeeKuJlBkSKGYxUQHibb5eHetn4XO1LpJXqE5Z)bXhLCJPuzSSPWOuqqMUdsrccsUXuQmw2uyukiiOiXh3ykvglBkmkfeSaUHoPb0nMsLXYMcJsbbhZlF0xqyJPuzSSPWOuqWXK2BOVGWgtPYyztHrPGGUe0uC8DqqyJPuzSSPWOuqqqrI3ykvglBkmkfeC5ZymK0sibHWPdwUYgFomsAFhAPcNoPHGifO4qAS59YEiXqHJmiffCzuAHog(ASBsgcksqqsxILTWuinp7eM4JYGuuqrl7gexrysfbljztqqsnUSPqhM5m4nQimPkieoDWYv24ZHrE5)G4JsQXLnfwsq5lx1qKGGKiwRYPbIG6WRFsv1ViNGaI1QCAGiOo86Nuv9grobbzqkkyjbLVCvdrqqrhAPcNoPHGifO4qAKYrXtfHjvsmu44sSSfMcP5zNWetLoqeqDbsRlJNnVOshicEg0v8XJUmVLKSbxgLwOJHVg7MKHlFgJH8cVRaemPi(OKOe8kpwbYuuGOblxdBoJA4C8L3qZvqqsnUSPWsckF5QgIoCqqqJlBkSKGYxUQHiXUmVLKSbljO8LRAicU8zmgYls5qlv40jneePafhsVHOPuPMLjXqHZXf0yQCXZqe4IFm8veMurcciwRYPbIG6WRFsv1ViNyzqkkOUJJwfHjveeuKyzqkki28EzpWss2oiwJlBkePlhN3XyXhDzEljzdUmkTqhdFn2njdx(mgdjTp6liiPlXYwykKMNDctqqsnUSPWsckF5QgIeeqj4vEScKPOardwUg2Cg1W54lVHM7HwQWPtAiisbkoK2HzodEJkctQKyOWbXAvonqeuhE9tQQEJiNyzqkkOUJJwfHjveSKKnXuPdeXLQUJJgVEQUe0uVONyzqkkOOLDdIRimPIGGIAPcNoPHGifO4q6yDHXveMujXqHdI1QCAGiOo86Nuv9groXYGuuqDhhTkctQiyjjBIPshiIlvDhhnE9uDjOPErpXYGuuqrl7gexrysfbbf1sfoDsdbrkqXH06cYimPsIHcNJhDjw2ctHyztX4zfFugKIckAz3G4kctQiyjjBcciwRYPbIG6WRFsv1Be5eVGgtLlEgIy3YkQMuvfdxbn57y0gdFf7GFUccACztHU4EhdFvXWveMurheeCjw2ctHg728MBrqWLyzlmfsZZoHj(OlZBjjBWLrPf6y4RXUjz4YNXyiPjf6li4Y8wsYgCzuAHog(ASBsgU8zmgYlF0)GGGlXYwyk0g8y0kvWIp6Y8wsYgK8ClvKOzhfbx(mgdjnPqFbbzqkki55wQirZokcck6Wbbbzqkki28EzpqqrIdNoy5kB85WiP9Dq8rj3ykvglBkmkfeKP7GuKGGKBmLkJLnfgLcccks8XnMsLXYMcJsbblGBOtAaDJPuzSSPWOuqWX8Yp9ee2ykvglBkmkfeCmPbI0)GGWgtPYyztHrPGGGIeVXuQmw2uyuki4YNXyiP9rFbHWPdwUYgFomsAFheeKtesm1GhJwx(mgd5LF61sfoDsdbrkqXH0XCYLkctQKW5XD5QglEwr44JedfoYGuuqrl7gexrysfbljztq4OmiffuxqgHjviOibbkW7TUSdtS45QoNSx4DfG6cKw15KfeqSwLtdeb1Hx)KQQ3iYjEbnMkx8meXULvunPQkgUcAY3XOng(k2b)Cpi(OKACztHomZzWBurysvqiC6GLRSXNdJ8Y)bbHJYGuuqDhhTkctQi4YNXyiPz6YoqLR6CYccuPdeXLQUJJgVEQUe0uPP)bXHthSCLn(CyK0(APcNoPHGifO4q6nenLk1SmjgkCo6Y8wsYgCzuAHog(ASBsgU8zmgsAF0xqqsxILTWuinp7eMGGKACztHLeu(YvnejiGsWR8yfitrbIgSCnS5mQHZXxEdn3dIPshicOUaP1LXZMxuPdebpd6k(OmiffSKGYxUQHiyjjBILbPOGCG)YACtdv1fKRuPdebljztqqJlBkePlhN3X4dTuHtN0qqKcuCiTdZCg8gveMujXqHJmiffu0YUbXveMurqqrccuPdejTlrkqdNoPbJ5KlveMuHUePTuHtN0qqKcuCiDSUW4kctQKyOWrgKIckAz3G4kctQiiOibbQ0bIK2LifOHtN0GXCYLkctQqxI0wQWPtAiisbkoKgXRi20kshdpjCECxUQXINveo(iXqHZYulJWeYxwSglEwH6CYvnRLHLUaUHoP1sfoDsdbrkqXH0YXUbEMedfoHthSCLn(CyK0(APcNoPHGifO4q6nenLk1SmjgkCo6Y8wsYgCzuAHog(ASBsgU8zmgsAF0x8cAmvU4zicCXpg(kctQibbjDjw2ctH08StyccsQXLnfwsq5lx1qKGakbVYJvGmffiAWY1WMZOgohF5n0CpiMkDGiG6cKwxgpBErLoqe8mOR4JYGuuWsckF5QgIGLKSjiOXLnfI0LJZ7y8HwQWPtAiisbkoKwoWxtQQUJJgIedfoYGuuqDbzeMuHLKS1sfoDsdbrkqXH0uxgHXTbLsIHchucELhRafbIuWlx5fuKoPjwgKIcQliJWKkSKKTwQWPtAiisbkoKgPCu8urysTLQLkC6KgcQ74OHWKkchKYrXtfHjvsmu4OXLnfIuokEQuPdejESk1DWJrfldsrbrkhfpvQ0bIGlFgJH8IETuHtN0qqDhhneMurafhstBU3kctQKyOWzbnMkx8muuc6WutQ6gaB5wP2a)jBksSmiffK6gE4fvpJLgeuulv40jneu3XrdHjveqXH0u3WdxQimPsIHcNf0yQCXZqrjOdtnPQBaSLBLAd8NSPOwQWPtAiOUJJgctQiGIdPljO8LRAiIedfohDjw2ctH08StyIDzEljzdUmkTqhdFn2njdx(mgd5fExrqqsxILTWuinp7eMyjDjw2ctH2GhJwPcwqWLyzlmfAdEmALkyXhDzEljzdsEULks0SJIGlFgJH8cVRii4Y8wsYgK8ClvKOzhfbx(mgdjnPq)dccAS4zfQZjx1Swg2lF0xqWL5TKKn4YO0cDm81y3KmC5ZymK0(OV4WPdwUYgFomsAs5G4JsUXuQmw2uyukiit3bPibHnMsLXYMcJsbbx(mgdjTesqqsxILTWuinp7e2HwQWPtAiOUJJgctQiGIdP1yR6gIiXqHZcAmvU4zikbVu5INR8PmViXASvDdrWLpJXqEH3ve7Y8wsYgK6gldx(mgd5fExPLkC6KgcQ74OHWKkcO4qAQBSmjUJXvxbh)0JedfoASvDdrqqrIxqJPYfpdrj4Lkx8CLpL5f1sfoDsdb1DC0qysfbuCintxr3eny5kctQTuHtN0qqDhhneMurafhstEULks0SJIAPcNoPHG6ooAimPIakoKMCm3XWxJDtYKyOWXL5TKKn4YO0cDm81y3KmC5ZymKx4DfXhLuJlBkKPROBIgSCfHjvbbzqkkO8nZYfePqqrheeK0LyzlmfsZZoHji4Y8wsYgCzuAHog(ASBsgU8zmgsAF0xqqoriXudEmAD5ZymKx0RLkC6KgcQ74OHWKkcO4q6LrPf6y4RXUjzsmu4C0L5TKKni28EzpWLpJXqEH3veeKuJlBkeBEVShbbnw8Sc15KRAwld7Lp)heFuYnMsLXYMcJsbbz6oifjiSXuQmw2uyuki4YNXyiPLqccHthSCLn(CyK04SXuQmw2uyukiOlbnfiy)hAPcNoPHG6ooAimPIakoKgBEVShsmu4idsrbxgLwOJHVg7MKHGIeeK0LyzlmfsZZoH1sfoDsdb1DC0qysfbuCiTCSBGNBPcNoPHG6ooAimPIakoKwxqgHjvsmu44sSSfMcP5zNWeFugKIcUmkTqhdFn2njdbfji4Y8wsYgCzuAHog(ASBsgU8zmgsAF0)GGGlXYwyk0g8y0kvWILbPOGKNBPIen7OiiOibbxILTWuiw2umEwbbxILTWuOXUnV5weeKtesm1GhJwx(mgd5LF61sfoDsdb1DC0qysfbuCi9gIMsLAwMedfolOXu5INHiWf)y4RimPIeF0L5TKKn4YO0cDm81y3KmC5ZymK0(OVGGKUelBHPqAE2jmbbj14YMcljO8LRAi6GyzqkkOUJJwfHjveC5ZymK04W0LDGkx15KBPcNoPHG6ooAimPIakoKoMtUurysLeopUlx1yXZkchFKyOW5Omiffu3XrRIWKkcU8zmgsACy6YoqLR6CYccuPdeXLQUJJgVEQUe0uPP)bXhLbPOGIw2niUIWKkcwsYMGaf49wx2Hjw8CvNt2lxG0QoNmqX7kccYGuuqDbzeMuHGIeeqSwLtdeb1Hx)KQQ3iYjEbnMkx8meXULvunPQkgUcAY3XOng(k2b)Cp0sfoDsdb1DC0qysfbuCiDHdft1HjOTXjjgkCOshicOUaP1LXZMxuPdebpd62sfoDsdb1DC0qysfbuCi9gIMsLAwMedfohDzEljzdUmkTqhdFn2njdx(mgdjTp6lEbnMkx8mebU4hdFfHjvKGGKUelBHPqAE2jmbbjxqJPYfpdrGl(XWxrysfjiiPgx2uyjbLVCvdrheldsrb1DC0QimPIGlFgJHKghMUSdu5QoNClv40jneu3XrdHjveqXH0NGxDqysLedfoYGuuqDhhTkctQiyjjBccYGuuqrl7gexrysfbbfjMkDGiPDjsbA40jnymNCPIWKk0Liv8rj14YMcDyMZG3OIWKQGq40blxzJphgjnPCOLkC6KgcQ74OHWKkcO4qAhM5m4nQimPsIHchzqkkOOLDdIRimPIGGIetLoqK0UePanC6KgmMtUurysf6sKkoC6GLRSXNdJ8YBAPcNoPHG6ooAimPIakoKM2CVveMujXqHJmiffSWrPYEyyjjBTuHtN0qqDhhneMurafhsh1tWTWBnPQUnjJAPcNoPHG6ooAimPIakoKM6gE4sfHj1wQWPtAiOUJJgctQiGIdPr8kInTI0XWtcNh3LRAS4zfHJpsmu4Sm1YimH8LBPcNoPHG6ooAimPIakoK(e8QdctQKyOWHkDGiPDjsbA40jnymNCPIWKk0Liv8rxM3ss2GlJsl0XWxJDtYWLpJXqstpbbjDjw2ctH08StyhAPcNoPHG6ooAimPIakoKwJTQBiIedfolOXu5INHgJqJHNCSEqvDdrIgdFnejk2qbrTuHtN0qqDhhneMurafhstTmdSng(QUHismu4SGgtLlEgAmcngEYX6bv1nejAm81qKOydfe1sfoDsdb1DC0qysfbuCiTCGVMuvDhhnejgkCKbPOG6cYimPcljzRLkC6KgcQ74OHWKkcO4qAQlJW42GsjXqHdkbVYJvGIark4LR8cksN0eldsrb1fKrysfwsYwlv40jneu3XrdHjveqXH0iLJINkctQTuTuHtN0qqDhJgRiCWg7eYxMewCY4G8yUkOisGnUGmoYGuuWLrPf6y4RXUjziOibbzqkkOUGmctQqqrTuHtN0qqDhJgRiGIdPXg7eYxMewCY4G0nn8vKhZvbfrcSXfKXXLyzlmfsZZoHjwgKIcUmkTqhdFn2njdbfjwgKIcQliJWKkeuKGGKUelBHPqAE2jmXYGuuqDbzeMuHGIAPcNoPHG6ognwrafhsJn2jKVmjS4KXbPBA4RipMRU8zmgIePiCqSouKWLwz0jnCCjw2ctH08StyKaBCbzCCzEljzdUmkTqhdFn2njdx(mgd5fqqUmVLKSb1fKrysfU8zmgQIhKrisGnUGCLVighxM3ss2G6cYimPcx(mgdvXdYiejgkCKbPOG6cYimPcljzRLkC6KgcQ7y0yfbuCin2yNq(YKWItghKUPHVI8yU6YNXyisKIWbX6qrcxALrN0WXLyzlmfsZZoHrcSXfKXXL5TKKn4YO0cDm81y3KmC5ZymejWgxqUYxeJJlZBjjBqDbzeMuHlFgJHQ4bzeIedfoYGuuqDbzeMuHGIAPcNoPHG6ognwrafhsJn2jKVmjS4KXb5XC1LpJXqKifHdI1HIeU0kJoPHJlXYwykKMNDcJeyJliJJlZBjjBWLrPf6y4RXUjz4YNXyiPbcYL5TKKnOUGmctQWLpJXqv8GmcrcSXfKR8fX44Y8wsYguxqgHjv4YNXyOkEqgHAPcNoPHG6ognwrafhsdI46O8jIeOBQiC0DmAS6JedfohpQ7y0yf6dIjqvqexLbPOeeCjw2ctH08StyI1DmASc9bXeOQlZBjjBheFeBStiFzis30WxrEmxfuK4Js6sSSfMcP5zNWelPUJrJvOFiMavbrCvgKIsqWLyzlmfsZZoHjwsDhJgRq)qmbQ6Y8wsYMGGUJrJvOFOlZBjjBWLpJXqcc6ognwH(GycufeXvzqkkXhLu3XOXk0petGQGiUkdsrjiO7y0yf6d6Y8wsYgSaUHoPjno6ognwH(HUmVLKSblGBOtAhee0DmASc9bXeOQlZBjjBILu3XOXk0petGQGiUkdsrjw3XOXk0h0L5TKKnybCdDstAC0DmASc9dDzEljzdwa3qN0oiiij2yNq(YqKUPHVI8yUkOiXhLu3XOXk0petGQGiUkdsrj(OUJrJvOpOlZBjjBWc4g6KMeqpVWg7eYxgI8yU6YNXyibbSXoH8LHipMRU8zmgsADhJgRqFqxM3ss2GfWn0jnGD)hee0DmASc9dXeOkiIRYGuuIpQ7y0yf6dIjqvqexLbPOeR7y0yf6d6Y8wsYgSaUHoPjno6ognwH(HUmVLKSblGBOtAIpQ7y0yf6d6Y8wsYgSaUHoPjb0ZlSXoH8LHipMRU8zmgsqaBStiFziYJ5QlFgJHKw3XOXk0h0L5TKKnybCdDsdy3)bbHJsQ7y0yf6dIjqvqexLbPOee0DmASc9dDzEljzdwa3qN0KghDhJgRqFqxM3ss2GfWn0jTdIpQ7y0yf6h6Y8wsYgC5O4rSUJrJvOFOlZBjjBWc4g6KMeqpPXg7eYxgI8yU6YNXyiXyJDc5ldrEmxD5ZymKx6ognwH(HUmVLKSblGBOtAa7(feKu3XOXk0p0L5TKKn4YrXJ4J6ognwH(HUmVLKSbx(mgdjb0ZlSXoH8LHiDtdFf5XC1LpJXqIXg7eYxgI0nn8vKhZvx(mgdjTF6l(OUJrJvOpOlZBjjBWc4g6KMeqpVWg7eYxgI8yU6YNXyibbDhJgRq)qxM3ss2GlFgJHKa65f2yNq(YqKhZvx(mgdjw3XOXk0p0L5TKKnybCdDstc8rFGIn2jKVme5XC1LpJXqEHn2jKVmePBA4RipMRU8zmgsqaBStiFziYJ5QlFgJHKw3XOXk0h0L5TKKnybCdDsdy3VGa2yNq(YqKhZvbfDqqq3XOXk0p0L5TKKn4YNXyijGEsJn2jKVmePBA4RipMRU8zmgs8rDhJgRqFqxM3ss2GfWn0jnjGEEHn2jKVmePBA4RipMRU8zmgsqq3XOXk0h0L5TKKnybCdDsZlQbpgTU8zmgsm2yNq(YqKUPHVI8yU6YNXyiGQ7y0yf6d6Y8wsYgSaUHoPjn1GhJwx(mgdjiiPUJrJvOpiMavbrCvgKIs8rSXoH8LHipMRU8zmgsADhJgRqFqxM3ss2GfWn0jnGD)ccyJDc5ldrEmxfu0HdhoC4GGGglEwH6CYvnRLH9cBStiFziYJ5QlFgJHoiiiPUJrJvOpiMavbrCvgKIsSKUelBHPqAE2jmXh1DmASc9dXeOkiIRYGuuIpEusSXoH8LHipMRcksqq3XOXk0p0L5TKKn4YNXyiPP3bXhXg7eYxgI8yU6YNXyiP9tFbbDhJgRq)qxM3ss2GlFgJHKa6jn2yNq(YqKhZvx(mgdD4GGGK6ognwH(HycufeXvzqkkXhLu3XOXk0petGQUmVLKSjiO7y0yf6h6Y8wsYgC5ZymKGGUJrJvOFOlZBjjBWc4g6KM04O7y0yf6d6Y8wsYgSaUHoPD4WbXhLu3XOXk0hCqqx4WW1KQgoVf4SCPQlhiWLrccskdsrbdN3cCwUujhwbck6qlv40jneu3XOXkcO4qAqexhLprKaDtfHJUJrJv)KyOW54rDhJgRq)qmbQcI4QmifLGGlXYwykKMNDctSUJrJvOFiMavDzEljz7G4JyJDc5ldr6Mg(kYJ5QGIeFusxILTWuinp7eMyj1DmASc9bXeOkiIRYGuuccUelBHPqAE2jmXsQ7y0yf6dIjqvxM3ss2ee0DmASc9bDzEljzdU8zmgsqq3XOXk0petGQGiUkdsrj(OK6ognwH(GycufeXvzqkkbbDhJgRq)qxM3ss2GfWn0jnPXr3XOXk0h0L5TKKnybCdDs7GGGUJrJvOFiMavDzEljztSK6ognwH(GycufeXvzqkkX6ognwH(HUmVLKSblGBOtAsJJUJrJvOpOlZBjjBWc4g6K2bbbjXg7eYxgI0nn8vKhZvbfj(OK6ognwH(GycufeXvzqkkXh1DmASc9dDzEljzdwa3qN0Ka65f2yNq(YqKhZvx(mgdjiGn2jKVme5XC1LpJXqsR7y0yf6h6Y8wsYgSaUHoPbS7)GGGUJrJvOpiMavbrCvgKIs8rDhJgRq)qmbQcI4QmifLyDhJgRq)qxM3ss2GfWn0jnPXr3XOXk0h0L5TKKnybCdDst8rDhJgRq)qxM3ss2GfWn0jnjGEEHn2jKVme5XC1LpJXqccyJDc5ldrEmxD5ZymK06ognwH(HUmVLKSblGBOtAa7(piiCusDhJgRq)qmbQcI4QmifLGGUJrJvOpOlZBjjBWc4g6KM04O7y0yf6h6Y8wsYgSaUHoPDq8rDhJgRqFqxM3ss2GlhfpI1DmASc9bDzEljzdwa3qN0Ka6jn2yNq(YqKhZvx(mgdjgBStiFziYJ5QlFgJH8s3XOXk0h0L5TKKnybCdDsdy3VGGK6ognwH(GUmVLKSbxokEeFu3XOXk0h0L5TKKn4YNXyijGEEHn2jKVmePBA4RipMRU8zmgsm2yNq(YqKUPHVI8yU6YNXyiP9tFXh1DmASc9dDzEljzdwa3qN0Ka65f2yNq(YqKhZvx(mgdjiO7y0yf6d6Y8wsYgC5ZymKeqpVWg7eYxgI8yU6YNXyiX6ognwH(GUmVLKSblGBOtAsGp6duSXoH8LHipMRU8zmgYlSXoH8LHiDtdFf5XC1LpJXqccyJDc5ldrEmxD5ZymK06ognwH(HUmVLKSblGBOtAa7(feWg7eYxgI8yUkOOdcc6ognwH(GUmVLKSbx(mgdjb0tASXoH8LHiDtdFf5XC1LpJXqIpQ7y0yf6h6Y8wsYgSaUHoPjb0ZlSXoH8LHiDtdFf5XC1LpJXqcc6ognwH(HUmVLKSblGBOtAErn4XO1LpJXqIXg7eYxgI0nn8vKhZvx(mgdbuDhJgRq)qxM3ss2GfWn0jnPPg8y06YNXyibbj1DmASc9dXeOkiIRYGuuIpIn2jKVme5XC1LpJXqsR7y0yf6h6Y8wsYgSaUHoPbS7xqaBStiFziYJ5QGIoC4WHdhee0yXZkuNtUQzTmSxyJDc5ldrEmxD5Zym0bbbj1DmASc9dXeOkiIRYGuuIL0LyzlmfsZZoHj(OUJrJvOpiMavbrCvgKIs8XJsIn2jKVme5XCvqrcc6ognwH(GUmVLKSbx(mgdjn9oi(i2yNq(YqKhZvx(mgdjTF6liO7y0yf6d6Y8wsYgC5ZymKeqpPXg7eYxgI8yU6YNXyOdheeKu3XOXk0hetGQGiUkdsrj(OK6ognwH(Gycu1L5TKKnbbDhJgRqFqxM3ss2GlFgJHee0DmASc9bDzEljzdwa3qN0KghDhJgRq)qxM3ss2GfWn0jTdhoi(OK6ognwH(Hdc6chgUMu1W5TaNLlvD5abUmsqqszqkky48wGZYLk5WkqqrhiucLGaa]] )


end