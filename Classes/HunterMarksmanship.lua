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
        secrets_of_the_unblinking_vigil = {
            id = 336892,
            duration = 20,
            max_stack = 1,
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

            spend = function ()
                if buff.lock_and_load.up or buff.secrets_of_the_unblinking_vigil.up then return 0 end
                return ( ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 35 )
            end,
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
                removeBuff( "double_tap" )
                if buff.volley.down and buff.trick_shots.up then removeBuff( "trick_shots" ) end
                if action.aimed_shot.cost == 0 and set_bonus.tier28_4pc > 0 then
                    focused_trickery_count = focused_trickery_count + ( ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.5 or 1 ) * 35 )
                    if focused_trickery_count >= 40 then
                        applyBuff( "trick_shots" )
                        focused_trickery_count = focused_trickery_count % 40
                    end
                end
                if buff.lock_and_load.up then removeBuff( "lock_and_load" )
                elseif buff.secrets_of_the_unblinking_vigil.up then removeBuff( "secrets_of_the_unblinking_vigil" ) end
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


    spec:RegisterPack( "Marksmanship", 20220326, [[d8u0BcqiIKhrvQ4sivK2eH6tqLgLk0PubRcqj4vasZcr4web2fOFHizyiv5yuvwgvvpdPctJQuCnKQABuLsFJQuPXbOuNJiiRdqX7auc18Ok5Eqf7Ji1)OkvjhKQuvwirOhciAIuLQWfbus(iGsQrsvQICsQsv1kjIEjGsiZeq4MivuANaQ(jGs0qPkvPwksfvpfGPIi6RivumweP2lc)vsdwvhwyXe1JPYKL4YO2ms(mu1OHItRy1uLQOEnsz2Q0Tvr7MYVfnCc54eb1Yv65qMoPRd02HsFhrnEKkDEQI1JurmFc2Vut4JGKeakHYea3p987NE0HFVf6JE(PN3aSjaOEeXeaefoAbEMaGfNmba6SXsdDggcZiIaGOWZnJcbjjaGsW1Xea8o9JrvriGHuKc)OyaLHU8KuO5e8g6KMBdkLuO50rkcaYGZv9(nczcaLqzcG7NE(9tp6WV3c9rp)0ZB8UeacqftUeaamNajbamtPWgHmbGcJCeaOZgln0zyimJO(9Ec0uEBjPZgRdt)(9ws0VF653FlzljqIjm8mcyAjLG(botMkbTs)05mkVy5(hu)wQ9h9FYomHnU(vmC)rPKw)UWif55E7)mSapdBjLG(PZzKhZXL(JsjT(fTtUJ6PFYJIPFaZjq2V3N3BGa2skb9deS2pWI8StyO(lmYJ56xXWZ2pq69a1pkpzDozeKaWDqkIGKea0DC0qysfrqscG7JGKeaylKVCHqIeaC7O8obbanUSPqKYrXtLkDGiiBH8Ll9lU)XQu3bpgTFX9ldsrbrkhfpvQ0bIGlFgJH63R(PpbGWPtAeaqkhfpveMujucG7NGKeaylKVCHqIeaC7O8obbGf0yQCXZqrjOdtnPQBqNKBLAd8NSPiiBH8Ll9lUFzqkki1n8WlQEglniOicaHtN0iaqBU3kctQekbWPdcssaGTq(YfcjsaWTJY7eeawqJPYfpdfLGom1KQUbDsUvQnWFYMIGSfYxUqaiC6KgbaQB4HlveMujucG7neKKaaBH8LlesKaGBhL3jiaCSFxILTWuinp7ew)I73L5TKKn4YO0cDm81y3KmC5Zymu)E1pExPFbH(LQFxILTWuinp7ew)I7xQ(Djw2ctH2GhJwPcUFbH(Djw2ctH2GhJwPcUFX9FSFxM3ss2GKNBPIen7Oi4YNXyO(9QF8Us)cc97Y8wsYgK8ClvKOzhfbx(mgd1V09th0R)d9li0VglEwH6CYvnRLH73R(9rV(fe63L5TKKn4YO0cDm81y3KmC5Zymu)s3Vp61V4(dNoy5kB85WO(LUF6O)d9lU)J9lv)BmLkJLnfgLccY0DqkQFbH(3ykvglBkmkfeC5Zymu)s3VeQFbH(LQFxILTWuinp7ew)hiaeoDsJaqjbLVCvdrekbWPpbjjaWwiF5cHeja42r5DccalOXu5INHOe8sLlEUYNY8IGSfYxU0V4(1yR6gIGlFgJH63R(X7k9lUFxM3ss2Gu3yz4YNXyO(9QF8UcbGWPtAea0yR6gIiucG7TeKKaaBH8LlesKaq40jncau3yzcaUDuENGaGgBv3qeeuu)I7FbnMkx8meLGxQCXZv(uMxeKTq(Yfca3X4QRqaWp9jucG7DjijbGWPtAeay6k6MOblxrysLaaBH8LlesKqjaoWMGKeacNoPraG8ClvKOzhfraGTq(YfcjsOeaxcrqscaSfYxUqircaUDuENGaGlZBjjBWLrPf6y4RXUjz4YNXyO(9QF8Us)I7)y)s1Vgx2uitxr3eny5kctQq2c5lx6xqOFzqkkO8nZYfePqqr9FOFbH(LQFxILTWuinp7ew)cc97Y8wsYgCzuAHog(ASBsgU8zmgQFP73h96xqOF5eH6xC)udEmAD5Zymu)E1p9jaeoDsJaa5yUJHVg7MKjucG7JEeKKaaBH8LlesKaGBhL3jiaCSFxM3ss2GyZ7L9ax(mgd1Vx9J3v6xqOFP6xJlBkeBEVShiBH8Ll9li0VglEwH6CYvnRLH73R(95V)d9lU)J9lv)BmLkJLnfgLccY0DqkQFbH(3ykvglBkmkfeC5Zymu)s3VeQFbH(dNoy5kB85WO(LgN(3ykvglBkmkfe0LGM2pWc97V)deacNoPrayzuAHog(ASBsMqjaUpFeKKaaBH8LlesKaGBhL3jiaidsrbxgLwOJHVg7MKHGI6xqOFP63LyzlmfsZZoHraiC6KgbaS59YEiucG7ZpbjjaeoDsJaGCSBGNjaWwiF5cHejucG7Joiijba2c5lxiKiba3okVtqaWLyzlmfsZZoH1V4(p2VmiffCzuAHog(ASBsgckQFbH(DzEljzdUmkTqhdFn2njdx(mgd1V097JE9FOFbH(Djw2ctH2GhJwPcUFX9ldsrbjp3sfjA2rrqqr9li0VlXYwykelBkgpB)cc97sSSfMcn2T5n3s)cc9lNiu)I7NAWJrRlFgJH63R(9tFcaHtN0iaOliJWKkHsaCFEdbjjaWwiF5cHeja42r5DccalOXu5INHiWf)y4RimPIGSfYxU0V4(p2VlZBjjBWLrPf6y4RXUjz4YNXyO(LUFF0RFbH(LQFxILTWuinp7ew)cc9lv)ACztHLeu(YvnebzlKVCP)d9lUFzqkkOUJJwfHjveC5Zymu)sJt)mDzhOYvDozcaHtN0iaSHOPuPMLjucG7J(eKKaaBH8LlesKaq40jncaXCYLkctQeaC7O8obbGJ9ldsrb1DC0QimPIGlFgJH6xAC6NPl7avUQZj3VGq)uPdeXLQUJJgVEQUe00(LUF61)H(f3)X(LbPOGIw2niUIWKkcwsYw)cc9tbEV1LDyIfpx15K73R(DbsR6CY9d0(X7k9li0VmiffuxqgHjviOO(fe6hXAvonqeuhE9dSREJix)I7FbnMkx8meXULvunPQkgUcAY3XOng(k2b)CHSfYxU0)bcaopUlx1yXZkIa4(iucG7ZBjijba2c5lxiKiba3okVtqaGkDGO(bA)UaP1LXZw)E1pv6arWZGUeacNoPraOWHIP6We024KqjaUpVlbjjaWwiF5cHeja42r5Dccah73L5TKKn4YO0cDm81y3KmC5Zymu)s3Vp61V4(xqJPYfpdrGl(XWxrysfbzlKVCPFbH(LQFxILTWuinp7ew)cc9lv)lOXu5INHiWf)y4RimPIGSfYxU0VGq)s1Vgx2uyjbLVCvdrq2c5lx6)q)I7xgKIcQ74Ovrysfbx(mgd1V040ptx2bQCvNtMaq40jncaBiAkvQzzcLa4(a2eKKaaBH8LlesKaGBhL3jiaidsrb1DC0QimPIGLKS1VGq)YGuuqrl7gexrysfbbf1V4(PshiQFP73LiTFG2F40jnymNCPIWKk0LiTFX9FSFP6xJlBk0HzodEJkctQq2c5lx6xqO)WPdwUYgFomQFP7No6)abGWPtAeaobV6GWKkHsaCFsicssaGTq(YfcjsaWTJY7eeaKbPOGIw2niUIWKkcckQFX9tLoqu)s3VlrA)aT)WPtAWyo5sfHjvOlrA)I7pC6GLRSXNdJ63R(9gcaHtN0ia4WmNbVrfHjvcLa4(PhbjjaWwiF5cHeja42r5DccaYGuuWchLk7HHLKSraiC6KgbaAZ9wrysLqjaUFFeKKaq40jncar9eCl8wtQQBtYicaSfYxUqircLa4(9tqscaHtN0iaqDdpCPIWKkba2c5lxiKiHsaC)0bbjjaWwiF5cHejaeoDsJaaIxrSPvKogEcaUDuENGaWYulJWeYxMaGZJ7Yvnw8SIiaUpcLa4(9gcssaGTq(YfcjsaWTJY7eeaOshiQFP73LiTFG2F40jnymNCPIWKk0LiTFX9FSFxM3ss2GlJsl0XWxJDtYWLpJXq9lD)0VFbH(LQFxILTWuinp7ew)hiaeoDsJaWj4vheMujucG7N(eKKaaBH8LlesKaGBhL3jiaSGgtLlEgAmcngEYX6bv1nejAm81qKOydfebzlKVCHaq40jncaASvDdrekbW97TeKKaaBH8LlesKaGBhL3jiaSGgtLlEgAmcngEYX6bv1nejAm81qKOydfebzlKVCHaq40jncaulZ0jJHVQBiIqjaUFVlbjjaWwiF5cHeja42r5DccaYGuuqDbzeMuHLKSraiC6Kgba5aFnPQ6ooAicLa4(b2eKKaaBH8LlesKaGBhL3jiaGsWR8yfOiqKcE5kVGI0jniBH8Ll9lUFzqkkOUGmctQWss2iaeoDsJaa1LryCBqPekbW9lHiijbGWPtAeaqkhfpveMujaWwiF5cHejucLaqHPcWRsqscG7JGKeacNoPraWLGMYBfHjvcaSfYxUqircLa4(jijba2c5lxiKibGWPtAeaCjOP8wrysLaGBhL3jiaSGgtLlEgIyryaPtqvrB6UXzOtAq2c5lx6xqOFucELhRaTXtGQAMxuvuoO0GSfYxU0VGq)h73LwbCu4Yy5ff3AsvPYvbngYwiF5s)I7xQ(xqJPYfpdrSimG0jOQOnD34m0jniBH8Ll9FGaWDmU6keaOd6rOeaNoiijba2c5lxiKibGWPtAea0nmjm4Ch6KXWxrysLaqHrUDePtAeaawN9hy4O0FyL(j5gMegCUdDc3pW9EdK9ZgFomIe9tM7VKgUA)LSFfZG6Nk3(fDdp8I6xMDbiI7FuCl9lZ9Rz2psuCE6P)Wk9tM73fgUA)lhL56PFsUHjH7hjIDd146xgKIcbja42r5Dccas1VglEwHdQk6gE4LqjaU3qqscaSfYxUqircaUDuENGaGlXYwykKMNDcRFX97Y8wsYguxqgHjv4YNXyO(f3VlZBjjBWLrPf6y4RXUjz4YNXyO(fe6xQ(Djw2ctH08Sty9lUFxM3ss2G6cYimPcx(mgdraiC6KgbaxCV1WPtA17Guca3bPvlozca6ognwrekbWPpbjjaWwiF5cHejaeoDsJaGlU3A40jT6DqkbG7G0QfNmbaxbrOea3Bjijba2c5lxiKiba3okVtqaiC6GLRSXNdJ63R(PdcaiDhNsaCFeacNoPraWf3BnC6Kw9oiLaWDqA1ItMaasjucG7Djijba2c5lxiKiba3okVtqaiC6GLRSXNdJ6x6(9taaP74ucG7Jaq40jncaU4ERHtN0Q3bPeaUdsRwCYea0DC0qysfrOekbarl7Yt5qjijbW9rqscaHtN0iaiNQE5sL6gE4c5XWx1KUJraGTq(YfcjsOea3pbjjaeoDsJaa1LryCBqPeaylKVCHqIekbWPdcssaGTq(YfcjsaWTJY7eeawqJPYfpdrj4Lkx8CLpL5fbzlKVCHaq40jncaASvDdrekbW9gcssaGTq(Yfcjsaq0YUaPvDozca(OhbGWPtAeakjO8LRAiIaGBhL3jiaeoDWYv24ZHr9lD)(6xqOFP63LyzlmfsZZoH1V4(LQFnUSPqS59YEGSfYxUqOeaN(eKKaaBH8LlesKaGBhL3jiaeoDWYv24ZHr97v)0r)I7)y)s1VlXYwykKMNDcRFX9lv)ACztHyZ7L9azlKVCPFbH(dNoy5kB85WO(9QF)9FGaq40jncaXCYLkctQekbW9wcssaGTq(YfcjsaWTJY7eeacNoy5kB85WO(LUF)9li0)X(Djw2ctH08Sty9li0Vgx2ui28Ezpq2c5lx6)q)I7pC6GLRSXNdJ6hN(9taiC6KgbaKYrXtfHjvcLqja4kicssaCFeKKaaBH8LlesKaGBhL3jiaCSFzqkkOUGmctQqqr9lUFzqkk4YO0cDm81y3Kmeuu)I73LyzlmfsZZoH1)H(fe6)y)YGuuqDbzeMuHGI6xC)YGuuqYZTurIMDueeuu)I73LyzlmfAdEmALk4(p0VGq)h73LyzlmfILnfJNTFbH(Djw2ctHg728MBP)d9lUFzqkkOUGmctQqqr9li0VCIq9lUFQbpgTU8zmgQFV63hD0VGq)h73LyzlmfsZZoH1V4(LbPOGlJsl0XWxJDtYqqr9lUFQbpgTU8zmgQFV637sh9FGaq40jncaY8I4L2y4jucG7NGKeaylKVCHqIeaC7O8obbazqkkOUGmctQqqr9li0VlZBjjBqDbzeMuHlFgJH6x6(Pd61VGq)Yjc1V4(Pg8y06YNXyO(9QFFElbGWPtAeaKVzwQuGRhcLa40bbjjaWwiF5cHeja42r5DccaYGuuqDbzeMuHGI6xqOFxM3ss2G6cYimPcx(mgd1V09th0RFbH(LteQFX9tn4XO1LpJXq97v)(8wcaHtN0iaeMJr6g3QlUxcLa4EdbjjaWwiF5cHeja42r5DccaYGuuqDbzeMuHGI6xqOFxM3ss2G6cYimPcx(mgd1V09th0RFbH(LteQFX9tn4XO1LpJXq97v)sicaHtN0iaqnllFZSqOeaN(eKKaaBH8LlesKaGBhL3jiaidsrb1fKrysfwsYgbGWPtAeaUdEmkQ69myb)jBkHsaCVLGKeaylKVCHqIeaC7O8obbazqkkOUGmctQqqr9lU)J9ldsrbLVzwUGifckQFbH(1yXZkedhxfduKt73R(9tV(p0VGq)Yjc1V4(Pg8y06YNXyO(9QF)EB)cc9FSFxILTWuinp7ew)I7xgKIcUmkTqhdFn2njdbf1V4(Pg8y06YNXyO(9QFVR)(pqaiC6KgbarPoPrOekbaKsqscG7JGKeaylKVCHqIeaC7O8obbanUSPqKYrXtLkDGiiBH8Ll9lU)J9lAzSv8Uc0hePCu8urysTFX9ldsrbrkhfpvQ0bIGlFgJH63R(PF)cc9ldsrbrkhfpvQ0bIGLKS1)H(f3)X(LbPOGlJsl0XWxJDtYWss26xqOFP63LyzlmfsZZoH1)bcaHtN0iaGuokEQimPsOea3pbjjaeoDsJaaT5ERimPsaGTq(YfcjsOeaNoiijba2c5lxiKiba3okVtqa4y)UelBHPqAE2jS(f3)X(DzEljzdUmkTqhdFn2njdx(mgd1Vx9J3v6)q)cc9lv)UelBHPqAE2jS(f3Vu97sSSfMcTbpgTsfC)cc97sSSfMcTbpgTsfC)I7)y)UmVLKSbjp3sfjA2rrWLpJXq97v)4DL(fe63L5TKKni55wQirZokcU8zmgQFP7NoOx)h6xqOF5eH6xC)udEmAD5Zymu)E1Vp63)H(f3)X(LQ)nMsLXYMcJsbbz6oif1VGq)BmLkJLnfgLccckQ)deacNoPraOKGYxUQHicLa4EdbjjaWwiF5cHeja42r5DccaASvDdrqqr9lU)f0yQCXZqucEPYfpx5tzErq2c5lxiaeoDsJaa1nwMqjao9jijba2c5lxiKiba3okVtqaybnMkx8meLGxQCXZv(uMxeKTq(YL(f3VgBv3qeC5Zymu)E1pExPFX97Y8wsYgK6gldx(mgd1Vx9J3viaeoDsJaGgBv3qeHsaCVLGKeacNoPraGPROBIgSCfHjvcaSfYxUqircLa4ExcssaGTq(YfcjsaWTJY7eeao2VlZBjjBqDbzeMuHlFgJH63R(X7k9li0VmiffuxqgHjviOO(p0V4(p2Vu9VXuQmw2uyukiit3bPO(fe6xQ(3ykvglBkmkfeeuu)I7)y)BmLkJLnfgLccwa3qN06hO9VXuQmw2uyuki4y97v)(Px)cc9VXuQmw2uyuki4y9lD)El96)q)cc9VXuQmw2uyukiiOO(f3)gtPYyztHrPGGlFgJH6x6(9jH6xqO)WPdwUYgFomQFP73x)h6xqOF5eH6xC)udEmAD5Zymu)E1VF6raiC6KgbaYZTurIMDueHsaCGnbjjaeoDsJaa1n8WLkctQeaylKVCHqIekbWLqeKKaaBH8LlesKaGBhL3jiaqLoqu)aTFxG06Y4zRFV6NkDGi4zqxcaHtN0iau4qXuDycABCsOea3h9iijbGWPtAeaI6j4w4TMuv3MKreaylKVCHqIekbW95JGKeaylKVCHqIeaC7O8obbaxM3ss2GlJsl0XWxJDtYWLpJXq97v)4DL(f3)X(LQFnUSPqMUIUjAWYveMuHSfYxU0VGq)YGuuq5BMLlisHGI6)q)cc9lv)UelBHPqAE2jS(fe63L5TKKn4YO0cDm81y3KmC5Zymu)cc9lNiu)I7NAWJrRlFgJH63R(PpbGWPtAeaihZDm81y3KmHsaCF(jijba2c5lxiKiba3okVtqa4y)YGuuWsckF5QgIGGI6xqOFP6xJlBkSKGYxUQHiiBH8Ll9li0VCIq9lUFQbpgTU8zmgQFV63N)(p0V4(p2Vu9VXuQmw2uyukiit3bPO(fe6xQ(3ykvglBkmkfeeuu)I7)y)BmLkJLnfgLccwa3qN06hO9VXuQmw2uyuki4y97v)(Ox)cc9VXuQmw2uyuki4y9lD)Ed96xqO)nMsLXYMcJsbbDjOP9Jt)(6)q)cc9VXuQmw2uyukiiOO(f3)gtPYyztHrPGGlFgJH6x6(Lq9li0F40blxzJphg1V097R)deacNoPrayzuAHog(ASBsMqjaUp6GGKeaylKVCHqIeaC7O8obbazqkk4YO0cDm81y3Kmeuu)cc9lv)UelBHPqAE2jS(f3)X(LbPOGIw2niUIWKkcwsYw)cc9lv)ACztHomZzWBurysfYwiF5s)cc9hoDWYv24ZHr97v)(7)q)I7)y)s1Vgx2uyjbLVCvdrq2c5lx6xqOFP6hXAvonqeuhE9dSR(f56xqOFeRv50arqD41pWU6nIC9li0VmiffSKGYxUQHiiOO(pqaiC6KgbaS59YEiucG7ZBiijba2c5lxiKiba3okVtqaWLyzlmfsZZoH1V4(PshiQFG2VlqADz8S1Vx9tLoqe8mOB)I7)y)h73L5TKKn4YO0cDm81y3KmC5Zymu)E1pExPFGf6No6xC)h7xQ(rj4vEScKPOardwUg2Cg1W54lVHMlKTq(YL(fe6xQ(14YMcljO8LRAicYwiF5s)h6)q)cc9RXLnfwsq5lx1qeKTq(YL(f3VlZBjjBWsckF5QgIGlFgJH63R(PJ(pqaiC6KgbaKYrXtfHjvcLa4(OpbjjaWwiF5cHeja42r5Dccah7FbnMkx8mebU4hdFfHjveKTq(YL(fe6hXAvonqeuhE9dSR(f56xC)YGuuqDhhTkctQiiOO(f3VmiffeBEVShyjjB9FOFX9RXLnfI0LJZ7ymKTq(YL(f3)X(DzEljzdUmkTqhdFn2njdx(mgd1V097JE9li0Vu97sSSfMcP5zNW6xqOFP6xJlBkSKGYxUQHiiBH8Ll9li0pkbVYJvGmffiAWY1WMZOgohF5n0CHSfYxU0)bcaHtN0iaSHOPuPMLjucG7ZBjijba2c5lxiKiba3okVtqaaXAvonqeuhE9dSREJix)I7xgKIcQ74OvrysfbljzRFX9tLoqexQ6ooA86P6sqt73R(PF)I7xgKIckAz3G4kctQiiOicaHtN0ia4WmNbVrfHjvcLa4(8UeKKaaBH8LlesKaGBhL3jiaGyTkNgicQdV(b2vVrKRFX9ldsrb1DC0QimPIGLKS1V4(PshiIlvDhhnE9uDjOP97v)0VFX9ldsrbfTSBqCfHjveeuebGWPtAeaI1fgxrysLqjaUpGnbjjaWwiF5cHeja42r5Dccah7)y)UelBHPqSSPy8S9lU)J9ldsrbfTSBqCfHjveSKKT(fe6hXAvonqeuhE9dSREJix)I7FbnMkx8meXULvunPQkgUcAY3XOng(k2b)CHSfYxU0VGq)ACztHU4EhdFvXWveMurq2c5lx6)q)cc97sSSfMcn2T5n3s)cc97sSSfMcP5zNW6xC)h73L5TKKn4YO0cDm81y3KmC5Zymu)s3pDqV(fe63L5TKKn4YO0cDm81y3KmC5Zymu)E1Vp61)H(fe63LyzlmfAdEmALk4(f3)X(DzEljzdsEULks0SJIGlFgJH6x6(Pd61VGq)YGuuqYZTurIMDueeuu)h6)q)cc9ldsrbXM3l7bckQFX9hoDWYv24ZHr9lD)(6)q)I7)y)s1)gtPYyztHrPGGmDhKI6xqOFP6FJPuzSSPWOuqqqr9lU)J9VXuQmw2uyukiybCdDsRFG2)gtPYyztHrPGGJ1Vx97N(9li0)gtPYyztHrPGGJ1V097T0R)d9li0)gtPYyztHrPGGGI6xC)BmLkJLnfgLccU8zmgQFP73h96xqO)WPdwUYgFomQFP73x)h6xqOF5eH6xC)udEmAD5Zymu)E1VF6taiC6KgbaDbzeMujucG7tcrqscaSfYxUqircaHtN0iaeZjxQimPsaWTJY7eeaKbPOGIw2niUIWKkcwsYw)cc9FSFzqkkOUGmctQqqr9li0pf49wx2Hjw8CvNtUFV6hVR0pq73fiTQZj3VGq)iwRYPbIG6WRFGD1Be56xC)lOXu5INHi2TSIQjvvXWvqt(ogTXWxXo4NlKTq(YL(p0V4(p2Vu9RXLnf6WmNbVrfHjviBH8Ll9li0F40blxzJphg1Vx97V)d9li0)X(LbPOG6ooAveMurWLpJXq9lD)mDzhOYvDo5(fe6NkDGiUu1DC041t1LGM2V09tV(p0V4(dNoy5kB85WO(LUFFeaCECxUQXINvebW9rOea3p9iijba2c5lxiKiba3okVtqaqgKIcIuokEQuPdebx(mgd1Vx9t)(f3Vgx2uis5O4PsLoqeKTq(YL(f3VmiffCzuAHog(ASBsgwsYgbGWPtAeaqkhfpveMujucG73hbjjaWwiF5cHeja42r5Dccah73L5TKKn4YO0cDm81y3KmC5Zymu)s3Vp61VGq)s1VlXYwykKMNDcRFbH(LQFnUSPWsckF5QgIGSfYxU0VGq)Oe8kpwbYuuGOblxdBoJA4C8L3qZfYwiF5s)h6xC)uPde1pq73fiTUmE263R(PshicEg0TFX9FSFzqkkyjbLVCvdrWss26xC)YGuuqoWFznUPHQ6cYvQ0bIGLKS1VGq)ACztHiD548ogdzlKVCP)deacNoPraydrtPsnltOea3VFcssaGTq(YfcjsaWTJY7eeaKbPOGIw2niUIWKkcckQFbH(PshiQFP73LiTFG2F40jnymNCPIWKk0LiLaq40jncaomZzWBurysLqjaUF6GGKeaylKVCHqIeaC7O8obbazqkkOOLDdIRimPIGGI6xqOFQ0bI6x6(Djs7hO9hoDsdgZjxQimPcDjsjaeoDsJaqSUW4kctQekbW97neKKaaBH8LlesKaq40jncaiEfXMwr6y4ja42r5DccaltTmctiF5(f3VglEwH6CYvnRLH7x6(lGBOtAeaCECxUQXINvebW9rOea3p9jijba2c5lxiKiba3okVtqaiC6GLRSXNdJ6x6(9raiC6Kgba5y3aptOea3V3sqscaSfYxUqircaUDuENGaWX(DzEljzdUmkTqhdFn2njdx(mgd1V097JE9lU)f0yQCXZqe4IFm8veMurq2c5lx6xqOFP63LyzlmfsZZoH1VGq)s1Vgx2uyjbLVCvdrq2c5lx6xqOFucELhRazkkq0GLRHnNrnCo(YBO5czlKVCP)d9lUFQ0bI6hO97cKwxgpB97v)uPdebpd62V4(p2VmiffSKGYxUQHiyjjB9li0Vgx2uisxooVJXq2c5lx6)abGWPtAea2q0uQuZYekbW97Djijba2c5lxiKiba3okVtqaqgKIcQliJWKkSKKncaHtN0iaih4Rjvv3XrdrOea3pWMGKeaylKVCHqIeaC7O8obbaucELhRafbIuWlx5fuKoPbzlKVCPFX9ldsrb1fKrysfwsYgbGWPtAeaOUmcJBdkLqjaUFjebjjaeoDsJaas5O4PIWKkba2c5lxiKiHsOea0DmASIiijbW9rqscaSfYxUqircaPicaiwjaeoDsJaa2yNq(YeaWgxqMaGmiffCzuAHog(ASBsgckQFbH(LbPOG6cYimPcbfraaBSvlozcaipMRckIqjaUFcssaGTq(YfcjsaifraaXkbGWPtAeaWg7eYxMaa24cYeaCjw2ctH08Sty9lUFzqkk4YO0cDm81y3Kmeuu)I7xgKIcQliJWKkeuu)cc9lv)UelBHPqAE2jS(f3VmiffuxqgHjviOicayJTAXjtaaPBA4RipMRckIqjaoDqqscaSfYxUqircaPicaiwhkcaHtN0iaGn2jKVmbaSXwT4KjaG0nn8vKhZvx(mgdraWTJY7eeaKbPOG6cYimPcljzJaa24cYv(IycaUmVLKSb1fKrysfU8zmgQIhKricayJlitaWL5TKKn4YO0cDm81y3KmC5Zymu)E59QFxM3ss2G6cYimPcx(mgdvXdYieHsaCVHGKeaylKVCHqIeasreaqSoueacNoPraaBStiFzcayJTAXjtaaPBA4RipMRU8zmgIaGBhL3jiaidsrb1fKrysfckIaa24cYv(IycaUmVLKSb1fKrysfU8zmgQIhKricayJlitaWL5TKKn4YO0cDm81y3KmC5ZymeHsaC6tqscaSfYxUqircaPicaiwhkcaHtN0iaGn2jKVmbaSXwT4KjaG8yU6YNXyicaUDuENGaGlXYwykKMNDcJaa24cYv(IycaUmVLKSb1fKrysfU8zmgQIhKricayJlitaWL5TKKn4YO0cDm81y3KmC5Zymu)s79QFxM3ss2G6cYimPcx(mgdvXdYieHsaCVLGKeaylKVCHqIeacNoPraq3XOXQpcaUDuENGaWX(p2VUJrJvO6dIjqvqexLbPO6xqOFxILTWuinp7ew)I7x3XOXku9bXeOQlZBjjB9FOFX9FSFSXoH8LHiDtdFf5XCvqr9lU)J9lv)UelBHPqAE2jS(f3Vu9R7y0yfQ(HycufeXvzqkQ(fe63LyzlmfsZZoH1V4(LQFDhJgRq1petGQUmVLKS1VGq)6ognwHQFOlZBjjBWLpJXq9li0VUJrJvO6dIjqvqexLbPO6xC)h7xQ(1DmAScv)qmbQcI4Qmifv)cc9R7y0yfQ(GUmVLKSblGBOtA9lno9R7y0yfQ(HUmVLKSblGBOtA9FOFbH(1DmAScvFqmbQ6Y8wsYw)I7xQ(1DmAScv)qmbQcI4Qmifv)I7x3XOXku9bDzEljzdwa3qN06xAC6x3XOXku9dDzEljzdwa3qN06)q)cc9lv)yJDc5ldr6Mg(kYJ5QGI6xC)h7xQ(1DmAScv)qmbQcI4Qmifv)I7)y)6ognwHQpOlZBjjBWc4g6Kw)sq)0VFV6hBStiFziYJ5QlFgJH6xqOFSXoH8LHipMRU8zmgQFP7x3XOXku9bDzEljzdwa3qN06Nu97V)d9li0VUJrJvO6hIjqvqexLbPO6xC)h7x3XOXku9bXeOkiIRYGuu9lUFDhJgRq1h0L5TKKnybCdDsRFPXPFDhJgRq1p0L5TKKnybCdDsRFX9FSFDhJgRq1h0L5TKKnybCdDsRFjOF63Vx9Jn2jKVme5XC1LpJXq9li0p2yNq(YqKhZvx(mgd1V09R7y0yfQ(GUmVLKSblGBOtA9tQ(93)H(fe6)y)s1VUJrJvO6dIjqvqexLbPO6xqOFDhJgRq1p0L5TKKnybCdDsRFPXPFDhJgRq1h0L5TKKnybCdDsR)d9lU)J9R7y0yfQ(HUmVLKSbxokE6xC)6ognwHQFOlZBjjBWc4g6Kw)sq)0VFP7hBStiFziYJ5QlFgJH6xC)yJDc5ldrEmxD5Zymu)E1VUJrJvO6h6Y8wsYgSaUHoP1pP63F)cc9lv)6ognwHQFOlZBjjBWLJIN(f3)X(1DmAScv)qxM3ss2GlFgJH6xc6N(97v)yJDc5ldr6Mg(kYJ5QlFgJH6xC)yJDc5ldr6Mg(kYJ5QlFgJH6x6(9tV(f3)X(1DmAScvFqxM3ss2GfWn0jT(LG(PF)E1p2yNq(YqKhZvx(mgd1VGq)6ognwHQFOlZBjjBWLpJXq9lb9t)(9QFSXoH8LHipMRU8zmgQFX9R7y0yfQ(HUmVLKSblGBOtA9lb97JE9d0(Xg7eYxgI8yU6YNXyO(9QFSXoH8LHiDtdFf5XC1LpJXq9li0p2yNq(YqKhZvx(mgd1V09R7y0yfQ(GUmVLKSblGBOtA9tQ(93VGq)yJDc5ldrEmxfuu)h6xqOFDhJgRq1p0L5TKKn4YNXyO(LG(PF)s3p2yNq(YqKUPHVI8yU6YNXyO(f3)X(1DmAScvFqxM3ss2GfWn0jT(LG(PF)E1p2yNq(YqKUPHVI8yU6YNXyO(fe6x3XOXku9bDzEljzdwa3qN063R(Pg8y06YNXyO(f3p2yNq(YqKUPHVI8yU6YNXyO(bA)6ognwHQpOlZBjjBWc4g6Kw)s3p1GhJwx(mgd1VGq)s1VUJrJvO6dIjqvqexLbPO6xC)h7hBStiFziYJ5QlFgJH6x6(1DmAScvFqxM3ss2GfWn0jT(jv)(7xqOFSXoH8LHipMRckQ)d9FO)d9FO)d9FOFbH(1yXZkuNtUQzTmC)E1p2yNq(YqKhZvx(mgd1)H(fe6xQ(1DmAScvFqmbQcI4Qmifv)I7xQ(Djw2ctH08Sty9lU)J9R7y0yfQ(HycufeXvzqkQ(f3)X(p2Vu9Jn2jKVme5XCvqr9li0VUJrJvO6h6Y8wsYgC5Zymu)s3p97)q)I7)y)yJDc5ldrEmxD5Zymu)s3VF61VGq)6ognwHQFOlZBjjBWLpJXq9lb9t)(LUFSXoH8LHipMRU8zmgQ)d9FOFbH(LQFDhJgRq1petGQGiUkdsr1V4(p2Vu9R7y0yfQ(Hycu1L5TKKT(fe6x3XOXku9dDzEljzdU8zmgQFbH(1DmAScv)qxM3ss2GfWn0jT(LgN(1DmAScvFqxM3ss2GfWn0jT(p0)H(p0V4(p2Vu9R7y0yfQ(Gdc6chgUMu1WjHbNLlvD5abUmQFbH(LQFzqkky4KWGZYLk5Wkqqr9FGaa6MkIaGUJrJvFekbW9UeKKaaBH8LlesKaq40jnca6ognw9taWTJY7eeao2)X(1DmAScv)qmbQcI4Qmifv)cc97sSSfMcP5zNW6xC)6ognwHQFiMavDzEljzR)d9lU)J9Jn2jKVmePBA4RipMRckQFX9FSFP63LyzlmfsZZoH1V4(LQFDhJgRq1hetGQGiUkdsr1VGq)UelBHPqAE2jS(f3Vu9R7y0yfQ(Gycu1L5TKKT(fe6x3XOXku9bDzEljzdU8zmgQFbH(1DmAScv)qmbQcI4Qmifv)I7)y)s1VUJrJvO6dIjqvqexLbPO6xqOFDhJgRq1p0L5TKKnybCdDsRFPXPFDhJgRq1h0L5TKKnybCdDsR)d9li0VUJrJvO6hIjqvxM3ss26xC)s1VUJrJvO6dIjqvqexLbPO6xC)6ognwHQFOlZBjjBWc4g6Kw)sJt)6ognwHQpOlZBjjBWc4g6Kw)h6xqOFP6hBStiFzis30WxrEmxfuu)I7)y)s1VUJrJvO6dIjqvqexLbPO6xC)h7x3XOXku9dDzEljzdwa3qN06xc6N(97v)yJDc5ldrEmxD5Zymu)cc9Jn2jKVme5XC1LpJXq9lD)6ognwHQFOlZBjjBWc4g6Kw)KQF)9FOFbH(1DmAScvFqmbQcI4Qmifv)I7)y)6ognwHQFiMavbrCvgKIQFX9R7y0yfQ(HUmVLKSblGBOtA9lno9R7y0yfQ(GUmVLKSblGBOtA9lU)J9R7y0yfQ(HUmVLKSblGBOtA9lb9t)(9QFSXoH8LHipMRU8zmgQFbH(Xg7eYxgI8yU6YNXyO(LUFDhJgRq1p0L5TKKnybCdDsRFs1V)(p0VGq)h7xQ(1DmAScv)qmbQcI4Qmifv)cc9R7y0yfQ(GUmVLKSblGBOtA9lno9R7y0yfQ(HUmVLKSblGBOtA9FOFX9FSFDhJgRq1h0L5TKKn4YrXt)I7x3XOXku9bDzEljzdwa3qN06xc6N(9lD)yJDc5ldrEmxD5Zymu)I7hBStiFziYJ5QlFgJH63R(1DmAScvFqxM3ss2GfWn0jT(jv)(7xqOFP6x3XOXku9bDzEljzdUCu80V4(p2VUJrJvO6d6Y8wsYgC5Zymu)sq)0VFV6hBStiFzis30WxrEmxD5Zymu)I7hBStiFzis30WxrEmxD5Zymu)s3VF61V4(p2VUJrJvO6h6Y8wsYgSaUHoP1Ve0p973R(Xg7eYxgI8yU6YNXyO(fe6x3XOXku9bDzEljzdU8zmgQFjOF63Vx9Jn2jKVme5XC1LpJXq9lUFDhJgRq1h0L5TKKnybCdDsRFjOFF0RFG2p2yNq(YqKhZvx(mgd1Vx9Jn2jKVmePBA4RipMRU8zmgQFbH(Xg7eYxgI8yU6YNXyO(LUFDhJgRq1p0L5TKKnybCdDsRFs1V)(fe6hBStiFziYJ5QGI6)q)cc9R7y0yfQ(GUmVLKSbx(mgd1Ve0p97x6(Xg7eYxgI0nn8vKhZvx(mgd1V4(p2VUJrJvO6h6Y8wsYgSaUHoP1Ve0p973R(Xg7eYxgI0nn8vKhZvx(mgd1VGq)6ognwHQFOlZBjjBWc4g6Kw)E1p1GhJwx(mgd1V4(Xg7eYxgI0nn8vKhZvx(mgd1pq7x3XOXku9dDzEljzdwa3qN06x6(Pg8y06YNXyO(fe6xQ(1DmAScv)qmbQcI4Qmifv)I7)y)yJDc5ldrEmxD5Zymu)s3VUJrJvO6h6Y8wsYgSaUHoP1pP63F)cc9Jn2jKVme5XCvqr9FO)d9FO)d9FO)d9li0VglEwH6CYvnRLH73R(Xg7eYxgI8yU6YNXyO(p0VGq)s1VUJrJvO6hIjqvqexLbPO6xC)s1VlXYwykKMNDcRFX9FSFDhJgRq1hetGQGiUkdsr1V4(p2)X(LQFSXoH8LHipMRckQFbH(1DmAScvFqxM3ss2GlFgJH6x6(PF)h6xC)h7hBStiFziYJ5QlFgJH6x6(9tV(fe6x3XOXku9bDzEljzdU8zmgQFjOF63V09Jn2jKVme5XC1LpJXq9FO)d9li0Vu9R7y0yfQ(GycufeXvzqkQ(f3)X(LQFDhJgRq1hetGQUmVLKS1VGq)6ognwHQpOlZBjjBWLpJXq9li0VUJrJvO6d6Y8wsYgSaUHoP1V040VUJrJvO6h6Y8wsYgSaUHoP1)H(p0)H(f3)X(LQFDhJgRq1pCqqx4WW1KQgojm4SCPQlhiWLr9li0Vu9ldsrbdNegCwUujhwbckQ)deaq3urea0DmAS6NqjucLaawErtAea3p987NE0HF6Gaa5yTXWJiaqNX7Joh4E)ahynW0F)Ked3)CkkxTFQC7hxDhhneMur42)YsyWz5s)O8K7pa18muU0Vdty4zeSLeigJ73hW0pqMgwEvU0pUACztHKg3(1SFC14YMcjnKTq(YfC7)Op6Ea2sceJX97hy6hitdlVkx6h3f0yQCXZqsJB)A2pUlOXu5INHKgYwiF5cU9F0hDpaBjbIX4(PdGPFGmnS8QCPFCxqJPYfpdjnU9Rz)4UGgtLlEgsAiBH8Ll42FO9dScyjq0)rF09aSLeigJ7N(at)azAy5v5s)4UGgtLlEgsAC7xZ(XDbnMkx8mK0q2c5lxWT)J(O7byljqmg3V3cm9dKPHLxLl9J7cAmvU4ziPXTFn7h3f0yQCXZqsdzlKVCb3(dTFGvalbI(p6JUhGTKaXyC)siGPFGmnS8QCPFC14YMcjnU9Rz)4QXLnfsAiBH8Ll42)rF09aSLeigJ73h9aM(bY0WYRYL(XvJlBkK042VM9JRgx2uiPHSfYxUGB)h9r3dWwsGymUFFEdW0pqMgwEvU0pUACztHKg3(1SFC14YMcjnKTq(YfC7)Op6Ea2sceJX97ZBaM(bY0WYRYL(XDbnMkx8mK042VM9J7cAmvU4ziPHSfYxUGB)h9r3dWwsGymUFF0hy6hitdlVkx6h3f0yQCXZqsJB)A2pUlOXu5INHKgYwiF5cU9F0hDpaBjbIX4(95DbM(bY0WYRYL(XvJlBkK042VM9JRgx2uiPHSfYxUGB)h9r3dWwsGymUFFExGPFGmnS8QCPFCxqJPYfpdjnU9Rz)4UGgtLlEgsAiBH8Ll42)r)09aSLeigJ73hWgy6hitdlVkx6hxnUSPqsJB)A2pUACztHKgYwiF5cU9F0hDpaBjbIX4(9tFGPFGmnS8QCPFCxqJPYfpdjnU9Rz)4UGgtLlEgsAiBH8Ll42FO9dScyjq0)rF09aSLeigJ73V3cm9dKPHLxLl9J7cAmvU4ziPXTFn7h3f0yQCXZqsdzlKVCb3(dTFGvalbI(p6JUhGTKaXyC)(b2at)azAy5v5s)4IsWR8yfiPXTFn7hxucELhRajnKTq(YfC7)Op6Ea2s2ssNX7Joh4E)ahynW0F)Ked3)CkkxTFQC7h3ctfGxf3(xwcdolx6hLNC)bOMNHYL(DycdpJGTKaXyC)(bM(bY0WYRYL(XDbnMkx8mK042VM9J7cAmvU4ziPHSfYxUGB)h9r3dWwsGymUF)at)azAy5v5s)4UGgtLlEgsAC7xZ(XDbnMkx8mK0q2c5lxWT)J(O7byljqmg3VFGPFGmnS8QCPFCDPvahfsAC7xZ(X1LwbCuiPHSfYxUGB)h9r3dWwsGymUF)at)azAy5v5s)4IsWR8yfiPXTFn7hxucELhRajnKTq(YfC7)Op6Ea2s2ssNX7Joh4E)ahynW0F)Ked3)CkkxTFQC7hxrl7Yt5qXT)LLWGZYL(r5j3FaQ5zOCPFhMWWZiyljqmg3pDam9dKPHLxLl9J7cAmvU4ziPXTFn7h3f0yQCXZqsdzlKVCb3(dTFGvalbI(p6JUhGTKaXyC)EdW0pqMgwEvU0pUACztHKg3(1SFC14YMcjnKTq(YfC7p0(bwbSei6)Op6Ea2sceJX9tFGPFGmnS8QCPFC14YMcjnU9Rz)4QXLnfsAiBH8Ll42)rF09aSLeigJ73BbM(bY0WYRYL(XvJlBkK042VM9JRgx2uiPHSfYxUGB)h9r3dWwYws6mEF05a37h4aRbM(7NKy4(Ntr5Q9tLB)4IuC7Fzjm4SCPFuEY9hGAEgkx63Hjm8mc2sceJX97dy6hitdlVkx6hxnUSPqsJB)A2pUACztHKgYwiF5cU9F0hDpaBjbIX4(9gGPFGmnS8QCPFCxqJPYfpdjnU9Rz)4UGgtLlEgsAiBH8Ll42FO9dScyjq0)rF09aSLeigJ7N(at)azAy5v5s)4UGgtLlEgsAC7xZ(XDbnMkx8mK0q2c5lxWT)J(O7byljqmg3VpFat)azAy5v5s)4QXLnfsAC7xZ(XvJlBkK0q2c5lxWT)J(O7byljqmg3Vp)at)azAy5v5s)4QXLnfsAC7xZ(XvJlBkK0q2c5lxWT)J(O7byljqmg3Vp6ay6hitdlVkx6hxnUSPqsJB)A2pUACztHKgYwiF5cU9F0pDpaBjbIX4(95nat)azAy5v5s)4QXLnfsAC7xZ(XvJlBkK0q2c5lxWT)J(P7byljqmg3VpVby6hitdlVkx6hxucELhRajnU9Rz)4IsWR8yfiPHSfYxUGB)h9r3dWwsGymUFF0hy6hitdlVkx6hxnUSPqsJB)A2pUACztHKgYwiF5cU9F0pDpaBjbIX4(9rFGPFGmnS8QCPFCxqJPYfpdjnU9Rz)4UGgtLlEgsAiBH8Ll42)rF09aSLeigJ73h9bM(bY0WYRYL(XfLGx5XkqsJB)A2pUOe8kpwbsAiBH8Ll42)rF09aSLeigJ73hWgy6hitdlVkx6hxnUSPqsJB)A2pUACztHKgYwiF5cU9F0hDpaBjbIX4(9bSbM(bY0WYRYL(XDbnMkx8mK042VM9J7cAmvU4ziPHSfYxUGB)h9r3dWwsGymUFFsiGPFGmnS8QCPFC14YMcjnU9Rz)4QXLnfsAiBH8Ll42)rF09aSLeigJ73Necy6hitdlVkx6h3f0yQCXZqsJB)A2pUlOXu5INHKgYwiF5cU9F0hDpaBjbIX4(9tpGPFGmnS8QCPFC14YMcjnU9Rz)4QXLnfsAiBH8Ll42)rF09aSLeigJ73VpGPFGmnS8QCPFC14YMcjnU9Rz)4QXLnfsAiBH8Ll42)r)09aSLeigJ73VpGPFGmnS8QCPFCrj4vEScK042VM9JlkbVYJvGKgYwiF5cU9F0hDpaBjbIX4(97Tat)azAy5v5s)4QXLnfsAC7xZ(XvJlBkK0q2c5lxWT)J(P7byljqmg3VFVfy6hitdlVkx6h3f0yQCXZqsJB)A2pUlOXu5INHKgYwiF5cU9F0hDpaBjbIX4(97Tat)azAy5v5s)4IsWR8yfiPXTFn7hxucELhRajnKTq(YfC7)Op6Ea2sceJX97hydm9dKPHLxLl9JlkbVYJvGKg3(1SFCrj4vEScK0q2c5lxWT)J(O7bylzljDgVp6CG79dCG1at)9tsmC)ZPOC1(PYTFC1DmASIWT)LLWGZYL(r5j3FaQ5zOCPFhMWWZiyljqmg3V3cm9dKPHLxLl9dyobY(rEmnOB)0P9Rz)aby0FzWoOjT(tr8gAU9FKuh6)i9P7byljqmg3V3cm9dKPHLxLl9JRUJrJvOpiPXTFn7hxDhJgRq1hK042)r)EdDpaBjbIX4(9wGPFGmnS8QCPFC1DmASc9djnU9Rz)4Q7y0yfQ(HKg3(p63BP7byljqmg3V3fy6hitdlVkx6hWCcK9J8yAq3(Pt7xZ(bcWO)YGDqtA9NI4n0C7)iPo0)r6t3dWwsGymUFVlW0pqMgwEvU0pU6ognwH(GKg3(1SFC1DmAScvFqsJB)h97T09aSLeigJ737cm9dKPHLxLl9JRUJrJvOFiPXTFn7hxDhJgRq1pK042)r)EdDpaBjBj9(pfLRYL(92(dNoP1)Dqkc2ssaajIDea3p99gcaI2KAUmbaVJ3PF6SXsdDggcZiQFVNanL3wsVJ3PF6SX6W0VFVLe97NE(93s2s6D8o9dKycdpJaMwsVJ3PFjOFGZKPsqR0pDoJYlwU)b1VLA)r)NSdtyJRFfd3FukP1VlmsrEU3(pdlWZWwsVJ3PFjOF6Cg5XCCP)OusRFr7K7OE6N8Oy6hWCcK97959giGTKEhVt)sq)abR9dSip7egQ)cJ8yU(vm8S9dKEpq9JYtwNtgbBjBjdNoPHGIw2LNYHcuCiLCQ6LlvQB4HlKhdFvt6owlz40jneu0YU8uouGIdPOUmcJBdkTLmC6KgckAzxEkhkqXHuASvDdrKyOWzbnMkx8meLGxQCXZv(uMxulz40jneu0YU8uouGIdPkjO8LRAiIeIw2fiTQZjJJp6rIHcNWPdwUYgFomsAFccs5sSSfMcP5zNWelLgx2ui28EzpTKHtN0qqrl7Yt5qbkoKkMtUurysLedfoHthSCLn(CyKx0H4Js5sSSfMcP5zNWelLgx2ui28EzpccHthSCLn(CyKx(p0sgoDsdbfTSlpLdfO4qkKYrXtfHjvsmu4eoDWYv24ZHrs7xq4OlXYwykKMNDctqqJlBkeBEVSNdIdNoy5kB85WiC83s2sgoDsdbuCiLlbnL3kctQTKHtN0qafhs5sqt5TIWKkjUJXvxbh6GEKyOWzbnMkx8meXIWasNGQI20DJZqN0eeqj4vESc0gpbQQzErvr5Gstq4OlTc4OWLXYlkU1KQsLRcASyPwqJPYfpdrSimG0jOQOnD34m0jTdTKEN(bwN9hy4O0FyL(j5gMegCUdDc3pW9EdK9ZgFomcyX9tM7VKgUA)LSFfZG6Nk3(fDdp8I6xMDbiI7FuCl9lZ9Rz2psuCE6P)Wk9tM73fgUA)lhL56PFsUHjH7hjIDd146xgKIcbBjdNoPHakoKs3WKWGZDOtgdFfHjvsmu4iLglEwHdQk6gE4TLmC6KgcO4qkxCV1WPtA17GusyXjJJUJrJvejgkCCjw2ctH08StyIDzEljzdQliJWKkC5ZymKyxM3ss2GlJsl0XWxJDtYWLpJXqccs5sSSfMcP5zNWe7Y8wsYguxqgHjv4YNXyOwsVJ3PFVh8n80pv4gdF)EsWT)sckR9dA6C73tc2pMal3ViqTF6CgLwOJHVFVVDtY9xsYgj6p3(hQ(vmC)UmVLKS1)G6xZS)BA47xZ(l8n80pv4gdF)EsWTFVhjOSc737NQFlnU)KQFfdJ4(DPvgDsd1FSC)H8L7xZ(pzTFYJIzS(vmC)(Ox)i2Lwb1)LzYHhs0VIH7hnN9tfog1VNeC737rckR9hGAEg64I71dSL074D6pC6KgcO4qkJjtLGwPUmkVyzsmu4GsWR8yfOXKPsqRuxgLxSS4JYGuuWLrPf6y4RXUjziOibbxM3ss2GlJsl0XWxJDtYWLpJXqs7JEccudEmAD5ZymKx(82dTKHtN0qafhs5I7TgoDsREhKsclozCCfulz40jneqXHuU4ERHtN0Q3bPKWItghKscKUJtXXhjgkCcNoy5kB85WiVOJwYWPtAiGIdPCX9wdNoPvVdsjHfNmo6ooAimPIibs3XP44JedfoHthSCLn(CyK0(BjBjdNoPHGUcchzEr8sBm8KyOW5OmiffuxqgHjviOiXYGuuWLrPf6y4RXUjziOiXUelBHPqAE2jSdcchLbPOG6cYimPcbfjwgKIcsEULks0SJIGGIe7sSSfMcTbpgTsf8bbHJUelBHPqSSPy8SccUelBHPqJDBEZTCqSmiffuxqgHjviOibb5eHetn4XO1LpJXqE5Joeeo6sSSfMcP5zNWeldsrbxgLwOJHVg7MKHGIetn4XO1LpJXqE5DPJdTKHtN0qqxbbuCiL8nZsLcC9qIHchzqkkOUGmctQqqrccUmVLKSb1fKrysfU8zmgsA6GEccYjcjMAWJrRlFgJH8YN32sgoDsdbDfeqXHuH5yKUXT6I7LedfoYGuuqDbzeMuHGIeeCzEljzdQliJWKkC5ZymK00b9eeKtesm1GhJwx(mgd5LpVTLmC6Kgc6kiGIdPOMLLVzwiXqHJmiffuxqgHjviOibbxM3ss2G6cYimPcx(mgdjnDqpbb5eHetn4XO1LpJXqEjHAjdNoPHGUccO4qQ7GhJIQEpdwWFYMsIHchzqkkOUGmctQWss2AjdNoPHGUccO4qkrPoPrIHchzqkkOUGmctQqqrIpkdsrbLVzwUGifcksqqJfpRqmCCvmqro1l)07GGGCIqIPg8y06YNXyiV87TcchDjw2ctH08StyILbPOGlJsl0XWxJDtYqqrIPg8y06YNXyiV8U(p0s2sgoDsdbrkoiLJINkctQKyOWrJlBkePCu8uPshis8rrlJTI3vG(GiLJINkctQILbPOGiLJINkv6arWLpJXqErFbbzqkkis5O4PsLoqeSKKTdIpkdsrbxgLwOJHVg7MKHLKSjiiLlXYwykKMNDc7qlz40jneePafhsrBU3kctQTKHtN0qqKcuCivjbLVCvdrKyOW5OlXYwykKMNDct8rxM3ss2GlJsl0XWxJDtYWLpJXqEH3voiiiLlXYwykKMNDctSuUelBHPqBWJrRubli4sSSfMcTbpgTsfS4JUmVLKSbjp3sfjA2rrWLpJXqEH3veeCzEljzdsEULks0SJIGlFgJHKMoO3bbb5eHetn4XO1LpJXqE5J(heFuQnMsLXYMcJsbbz6oifjiSXuQmw2uyukiiOOdTKHtN0qqKcuCif1nwMedfoASvDdrqqrIxqJPYfpdrj4Lkx8CLpL5f1sgoDsdbrkqXHuASvDdrKyOWzbnMkx8meLGxQCXZv(uMxKyn2QUHi4YNXyiVW7kIDzEljzdsDJLHlFgJH8cVR0sgoDsdbrkqXHumDfDt0GLRimP2sgoDsdbrkqXHuKNBPIen7Oismu4C0L5TKKnOUGmctQWLpJXqEH3veeKbPOG6cYimPcbfDq8rP2ykvglBkmkfeKP7GuKGGuBmLkJLnfgLcccks8XnMsLXYMcJsbblGBOtAaDJPuzSSPWOuqWX8Yp9ee2ykvglBkmkfeCmP9w6DqqyJPuzSSPWOuqqqrI3ykvglBkmkfeC5ZymK0(KqccHthSCLn(CyK0(oiiiNiKyQbpgTU8zmgYl)0RLmC6KgcIuGIdPOUHhUurysTLmC6KgcIuGIdPkCOyQombTnojXqHdv6ara1fiTUmE28IkDGi4zq3wYWPtAiisbkoKkQNGBH3AsvDBsg1sgoDsdbrkqXHuKJ5og(ASBsMedfoUmVLKSbxgLwOJHVg7MKHlFgJH8cVRi(OuACztHmDfDt0GLRimPkiidsrbLVzwUGifck6GGGuUelBHPqAE2jmbbxM3ss2GlJsl0XWxJDtYWLpJXqccYjcjMAWJrRlFgJH8I(TKHtN0qqKcuCi1YO0cDm81y3KmjgkCokdsrbljO8LRAiccksqqknUSPWsckF5QgIeeKtesm1GhJwx(mgd5Lp)heFuQnMsLXYMcJsbbz6oifjii1gtPYyztHrPGGGIeFCJPuzSSPWOuqWc4g6Kgq3ykvglBkmkfeCmV8rpbHnMsLXYMcJsbbhtAVHEccBmLkJLnfgLcc6sqtXX3bbHnMsLXYMcJsbbbfjEJPuzSSPWOuqWLpJXqslHeecNoy5kB85WiP9DOLmC6KgcIuGIdPWM3l7HedfoYGuuWLrPf6y4RXUjziOibbPCjw2ctH08StyIpkdsrbfTSBqCfHjveSKKnbbP04YMcDyMZG3OIWKQGq40blxzJphg5L)dIpkLgx2uyjbLVCvdrccsHyTkNgicQdV(b2v)ICcciwRYPbIG6WRFGD1Be5eeKbPOGLeu(YvnebbfDOLmC6KgcIuGIdPqkhfpveMujXqHJlXYwykKMNDctmv6ara1fiTUmE28IkDGi4zqxXhp6Y8wsYgCzuAHog(ASBsgU8zmgYl8UcWc0H4JsHsWR8yfitrbIgSCnS5mQHZXxEdnxbbP04YMcljO8LRAi6WbbbnUSPWsckF5QgIe7Y8wsYgSKGYxUQHi4YNXyiVOJdTKHtN0qqKcuCi1gIMsLAwMedfohxqJPYfpdrGl(XWxrysfjiGyTkNgicQdV(b2v)ICILbPOG6ooAveMurqqrILbPOGyZ7L9aljz7GynUSPqKUCCEhJfF0L5TKKn4YO0cDm81y3KmC5ZymK0(ONGGuUelBHPqAE2jmbbP04YMcljO8LRAisqaLGx5XkqMIceny5AyZzudNJV8gAUhAjdNoPHGifO4qkhM5m4nQimPsIHcheRv50arqD41pWU6nICILbPOG6ooAveMurWss2etLoqexQ6ooA86P6sqt9I(ILbPOGIw2niUIWKkcckQLmC6KgcIuGIdPI1fgxrysLedfoiwRYPbIG6WRFGD1Be5eldsrb1DC0QimPIGLKSjMkDGiUu1DC041t1LGM6f9fldsrbfTSBqCfHjveeuulz40jneePafhsPliJWKkjgkCoE0LyzlmfILnfJNv8rzqkkOOLDdIRimPIGLKSjiGyTkNgicQdV(b2vVrKt8cAmvU4ziIDlROAsvvmCf0KVJrBm8vSd(5kiOXLnf6I7Dm8vfdxrysfDqqWLyzlmfASBZBUfbbxILTWuinp7eM4JUmVLKSbxgLwOJHVg7MKHlFgJHKMoONGGlZBjjBWLrPf6y4RXUjz4YNXyiV8rVdccUelBHPqBWJrRubl(OlZBjjBqYZTurIMDueC5ZymK00b9eeKbPOGKNBPIen7OiiOOdheeKbPOGyZ7L9abfjoC6GLRSXNdJK23bXhLAJPuzSSPWOuqqMUdsrccsTXuQmw2uyukiiOiXh3ykvglBkmkfeSaUHoPb0nMsLXYMcJsbbhZl)0xqyJPuzSSPWOuqWXK2BP3bbHnMsLXYMcJsbbbfjEJPuzSSPWOuqWLpJXqs7JEccHthSCLn(CyK0(oiiiNiKyQbpgTU8zmgYl)0VLmC6KgcIuGIdPI5KlveMujHZJ7Yvnw8SIWXhjgkCKbPOGIw2niUIWKkcwsYMGWrzqkkOUGmctQqqrccuG3BDzhMyXZvDozVW7ka1fiTQZjliGyTkNgicQdV(b2vVrKt8cAmvU4ziIDlROAsvvmCf0KVJrBm8vSd(5Eq8rP04YMcDyMZG3OIWKQGq40blxzJphg5L)dcchLbPOG6ooAveMurWLpJXqsZ0LDGkx15KfeOshiIlvDhhnE9uDjOPstVdIdNoy5kB85WiP91sgoDsdbrkqXHuiLJINkctQKyOWrgKIcIuokEQuPdebx(mgd5f9fRXLnfIuokEQuPdejwgKIcUmkTqhdFn2njdljzRLmC6KgcIuGIdP2q0uQuZYKyOW5OlZBjjBWLrPf6y4RXUjz4YNXyiP9rpbbPCjw2ctH08StyccsPXLnfwsq5lx1qKGakbVYJvGmffiAWY1WMZOgohF5n0CpiMkDGiG6cKwxgpBErLoqe8mOR4JYGuuWsckF5QgIGLKSjwgKIcYb(lRXnnuvxqUsLoqeSKKnbbnUSPqKUCCEhJp0sgoDsdbrkqXHuomZzWBurysLedfoYGuuqrl7gexrysfbbfjiqLoqK0UePanC6KgmMtUurysf6sK2sgoDsdbrkqXHuX6cJRimPsIHchzqkkOOLDdIRimPIGGIeeOshisAxIuGgoDsdgZjxQimPcDjsBjdNoPHGifO4qkeVIytRiDm8KW5XD5QglEwr44JedfoltTmctiFzXAS4zfQZjx1Swgw6c4g6Kwlz40jneePafhsjh7g4zsmu4eoDWYv24ZHrs7RLmC6KgcIuGIdP2q0uQuZYKyOW5OlZBjjBWLrPf6y4RXUjz4YNXyiP9rpXlOXu5INHiWf)y4RimPIeeKYLyzlmfsZZoHjiiLgx2uyjbLVCvdrccOe8kpwbYuuGOblxdBoJA4C8L3qZ9GyQ0bIaQlqADz8S5fv6arWZGUIpkdsrbljO8LRAicwsYMGGgx2uisxooVJXhAjdNoPHGifO4qk5aFnPQ6ooAismu4idsrb1fKrysfwsYwlz40jneePafhsrDzeg3gukjgkCqj4vEScueisbVCLxqr6KMyzqkkOUGmctQWss2AjdNoPHGifO4qkKYrXtfHj1wYwYWPtAiOUJJgctQiCqkhfpveMujXqHJgx2uis5O4PsLoqK4XQu3bpgvSmiffePCu8uPshicU8zmgYl63sgoDsdb1DC0qysfbuCifT5ERimPsIHcNf0yQCXZqrjOdtnPQBqNKBLAd8NSPiXYGuuqQB4Hxu9mwAqqrTKHtN0qqDhhneMurafhsrDdpCPIWKkjgkCwqJPYfpdfLGom1KQUbDsUvQnWFYMIAjdNoPHG6ooAimPIakoKQKGYxUQHismu4C0LyzlmfsZZoHj2L5TKKn4YO0cDm81y3KmC5ZymKx4DfbbPCjw2ctH08StyILYLyzlmfAdEmALkybbxILTWuOn4XOvQGfF0L5TKKni55wQirZokcU8zmgYl8UIGGlZBjjBqYZTurIMDueC5ZymK00b9oiiOXINvOoNCvZAzyV8rpbbxM3ss2GlJsl0XWxJDtYWLpJXqs7JEIdNoy5kB85WiPPJdIpk1gtPYyztHrPGGmDhKIee2ykvglBkmkfeC5ZymK0sibbPCjw2ctH08StyhAjdNoPHG6ooAimPIakoKsJTQBiIedfolOXu5INHOe8sLlEUYNY8IeRXw1nebx(mgd5fExrSlZBjjBqQBSmC5ZymKx4DLwYWPtAiOUJJgctQiGIdPOUXYK4ogxDfC8tFsmu4OXw1nebbfjEbnMkx8meLGxQCXZv(uMxulz40jneu3XrdHjveqXHumDfDt0GLRimP2sgoDsdb1DC0qysfbuCif55wQirZokQLmC6KgcQ74OHWKkcO4qkYXChdFn2njtIHchxM3ss2GlJsl0XWxJDtYWLpJXqEH3veFuknUSPqMUIUjAWYveMufeKbPOGY3mlxqKcbfDqqqkxILTWuinp7eMGGlZBjjBWLrPf6y4RXUjz4YNXyiP9rpbb5eHetn4XO1LpJXqEr)wYWPtAiOUJJgctQiGIdPwgLwOJHVg7MKjXqHZrxM3ss2GyZ7L9ax(mgd5fExrqqknUSPqS59YEee0yXZkuNtUQzTmSx(8Fq8rP2ykvglBkmkfeKP7GuKGWgtPYyztHrPGGlFgJHKwcjieoDWYv24ZHrsJZgtPYyztHrPGGUe0uGf8FOLmC6KgcQ74OHWKkcO4qkS59YEiXqHJmiffCzuAHog(ASBsgcksqqkxILTWuinp7ewlz40jneu3XrdHjveqXHuYXUbEULmC6KgcQ74OHWKkcO4qkDbzeMujXqHJlXYwykKMNDct8rzqkk4YO0cDm81y3KmeuKGGlZBjjBWLrPf6y4RXUjz4YNXyiP9rVdccUelBHPqBWJrRublwgKIcsEULks0SJIGGIeeCjw2ctHyztX4zfeCjw2ctHg728MBrqqoriXudEmAD5ZymKx(PFlz40jneu3XrdHjveqXHuBiAkvQzzsmu4SGgtLlEgIax8JHVIWKks8rxM3ss2GlJsl0XWxJDtYWLpJXqs7JEccs5sSSfMcP5zNWeeKsJlBkSKGYxUQHOdILbPOG6ooAveMurWLpJXqsJdtx2bQCvNtULmC6KgcQ74OHWKkcO4qQyo5sfHjvs484UCvJfpRiC8rIHcNJYGuuqDhhTkctQi4YNXyiPXHPl7avUQZjliqLoqexQ6ooA86P6sqtLMEheFugKIckAz3G4kctQiyjjBccuG3BDzhMyXZvDozVCbsR6CYafVRiiidsrb1fKrysfcksqaXAvonqeuhE9dSREJiN4f0yQCXZqe7wwr1KQQy4kOjFhJ2y4Ryh8Z9qlz40jneu3XrdHjveqXHufoumvhMG2gNKyOWHkDGiG6cKwxgpBErLoqe8mOBlz40jneu3XrdHjveqXHuBiAkvQzzsmu4C0L5TKKn4YO0cDm81y3KmC5ZymK0(ON4f0yQCXZqe4IFm8veMurccs5sSSfMcP5zNWeeKAbnMkx8mebU4hdFfHjvKGGuACztHLeu(YvneDqSmiffu3XrRIWKkcU8zmgsACy6YoqLR6CYTKHtN0qqDhhneMurafhsDcE1bHjvsmu4idsrb1DC0QimPIGLKSjiidsrbfTSBqCfHjveeuKyQ0bIK2LifOHtN0GXCYLkctQqxIuXhLsJlBk0HzodEJkctQccHthSCLn(CyK00XHwYWPtAiOUJJgctQiGIdPCyMZG3OIWKkjgkCKbPOGIw2niUIWKkccksmv6ars7sKc0WPtAWyo5sfHjvOlrQ4WPdwUYgFomYlVPLmC6KgcQ74OHWKkcO4qkAZ9wrysLedfoYGuuWchLk7HHLKS1sgoDsdb1DC0qysfbuCivupb3cV1KQ62KmQLmC6KgcQ74OHWKkcO4qkQB4HlveMuBjdNoPHG6ooAimPIakoKcXRi20kshdpjCECxUQXINveo(iXqHZYulJWeYxULmC6KgcQ74OHWKkcO4qQtWRoimPsIHchQ0bIK2LifOHtN0GXCYLkctQqxIuXhDzEljzdUmkTqhdFn2njdx(mgdjn9feKYLyzlmfsZZoHDOLmC6KgcQ74OHWKkcO4qkn2QUHismu4SGgtLlEgAmcngEYX6bv1nejAm81qKOydfe1sgoDsdb1DC0qysfbuCif1YmDYy4R6gIiXqHZcAmvU4zOXi0y4jhRhuv3qKOXWxdrIInuqulz40jneu3XrdHjveqXHuYb(Asv1DC0qKyOWrgKIcQliJWKkSKKTwYWPtAiOUJJgctQiGIdPOUmcJBdkLedfoOe8kpwbkcePGxUYlOiDstSmiffuxqgHjvyjjBTKHtN0qqDhhneMurafhsHuokEQimP2s2sgoDsdb1DmASIWbBStiFzsyXjJdYJ5QGIib24cY4idsrbxgLwOJHVg7MKHGIeeKbPOG6cYimPcbf1sgoDsdb1DmASIakoKcBStiFzsyXjJds30WxrEmxfuejWgxqghxILTWuinp7eMyzqkk4YO0cDm81y3KmeuKyzqkkOUGmctQqqrccs5sSSfMcP5zNWeldsrb1fKrysfckQLmC6KgcQ7y0yfbuCif2yNq(YKWItghKUPHVI8yU6YNXyisKIWbX6qrcxALrN0WXLyzlmfsZZoHrcSXfKXXL5TKKn4YO0cDm81y3KmC5ZymKxEVCzEljzdQliJWKkC5ZymufpiJqKaBCb5kFrmoUmVLKSb1fKrysfU8zmgQIhKrismu4idsrb1fKrysfwsYwlz40jneu3XOXkcO4qkSXoH8LjHfNmoiDtdFf5XC1LpJXqKifHdI1HIeU0kJoPHJlXYwykKMNDcJeyJliJJlZBjjBWLrPf6y4RXUjz4YNXyisGnUGCLVighxM3ss2G6cYimPcx(mgdvXdYiejgkCKbPOG6cYimPcbf1sgoDsdb1DmASIakoKcBStiFzsyXjJdYJ5QlFgJHirkcheRdfjCPvgDsdhxILTWuinp7egjWgxqghxM3ss2GlJsl0XWxJDtYWLpJXqs79YL5TKKnOUGmctQWLpJXqv8GmcrcSXfKR8fX44Y8wsYguxqgHjv4YNXyOkEqgHAjdNoPHG6ognwrafhsbI46O8jIeOBQiC0DmAS6JedfohpQ7y0yf6dIjqvqexLbPOeeCjw2ctH08StyI1DmASc9bXeOQlZBjjBheFeBStiFzis30WxrEmxfuK4Js5sSSfMcP5zNWelLUJrJvOFiMavbrCvgKIsqWLyzlmfsZZoHjwkDhJgRq)qmbQ6Y8wsYMGGUJrJvOFOlZBjjBWLpJXqcc6ognwH(GycufeXvzqkkXhLs3XOXk0petGQGiUkdsrjiO7y0yf6d6Y8wsYgSaUHoPjno6ognwH(HUmVLKSblGBOtAhee0DmASc9bXeOQlZBjjBILs3XOXk0petGQGiUkdsrjw3XOXk0h0L5TKKnybCdDstAC0DmASc9dDzEljzdwa3qN0oiiif2yNq(YqKUPHVI8yUkOiXhLs3XOXk0petGQGiUkdsrj(OUJrJvOpOlZBjjBWc4g6KMeqFVWg7eYxgI8yU6YNXyibbSXoH8LHipMRU8zmgsADhJgRqFqxM3ss2GfWn0jn6u)hee0DmASc9dXeOkiIRYGuuIpQ7y0yf6dIjqvqexLbPOeR7y0yf6d6Y8wsYgSaUHoPjno6ognwH(HUmVLKSblGBOtAIpQ7y0yf6d6Y8wsYgSaUHoPjb03lSXoH8LHipMRU8zmgsqaBStiFziYJ5QlFgJHKw3XOXk0h0L5TKKnybCdDsJo1)bbHJsP7y0yf6dIjqvqexLbPOee0DmASc9dDzEljzdwa3qN0KghDhJgRqFqxM3ss2GfWn0jTdIpQ7y0yf6h6Y8wsYgC5O4rSUJrJvOFOlZBjjBWc4g6KMeqFPXg7eYxgI8yU6YNXyiXyJDc5ldrEmxD5ZymKx6ognwH(HUmVLKSblGBOtA0P(feKs3XOXk0p0L5TKKn4YrXJ4J6ognwH(HUmVLKSbx(mgdjb03lSXoH8LHiDtdFf5XC1LpJXqIXg7eYxgI0nn8vKhZvx(mgdjTF6j(OUJrJvOpOlZBjjBWc4g6KMeqFVWg7eYxgI8yU6YNXyibbDhJgRq)qxM3ss2GlFgJHKa67f2yNq(YqKhZvx(mgdjw3XOXk0p0L5TKKnybCdDstc8rpGIn2jKVme5XC1LpJXqEHn2jKVmePBA4RipMRU8zmgsqaBStiFziYJ5QlFgJHKw3XOXk0h0L5TKKnybCdDsJo1VGa2yNq(YqKhZvbfDqqq3XOXk0p0L5TKKn4YNXyijG(sJn2jKVmePBA4RipMRU8zmgs8rDhJgRqFqxM3ss2GfWn0jnjG(EHn2jKVmePBA4RipMRU8zmgsqq3XOXk0h0L5TKKnybCdDsZlQbpgTU8zmgsm2yNq(YqKUPHVI8yU6YNXyiGQ7y0yf6d6Y8wsYgSaUHoPjn1GhJwx(mgdjiiLUJrJvOpiMavbrCvgKIs8rSXoH8LHipMRU8zmgsADhJgRqFqxM3ss2GfWn0jn6u)ccyJDc5ldrEmxfu0HdhoC4GGGglEwH6CYvnRLH9cBStiFziYJ5QlFgJHoiiiLUJrJvOpiMavbrCvgKIsSuUelBHPqAE2jmXh1DmASc9dXeOkiIRYGuuIpEukSXoH8LHipMRcksqq3XOXk0p0L5TKKn4YNXyiPP)bXhXg7eYxgI8yU6YNXyiP9tpbbDhJgRq)qxM3ss2GlFgJHKa6ln2yNq(YqKhZvx(mgdD4GGGu6ognwH(HycufeXvzqkkXhLs3XOXk0petGQUmVLKSjiO7y0yf6h6Y8wsYgC5ZymKGGUJrJvOFOlZBjjBWc4g6KM04O7y0yf6d6Y8wsYgSaUHoPD4WbXhLs3XOXk0hCqqx4WW1KQgojm4SCPQlhiWLrccsjdsrbdNegCwUujhwbck6qlz40jneu3XOXkcO4qkqexhLprKaDtfHJUJrJv)KyOW54rDhJgRq)qmbQcI4QmifLGGlXYwykKMNDctSUJrJvOFiMavDzEljz7G4JyJDc5ldr6Mg(kYJ5QGIeFukxILTWuinp7eMyP0DmASc9bXeOkiIRYGuuccUelBHPqAE2jmXsP7y0yf6dIjqvxM3ss2ee0DmASc9bDzEljzdU8zmgsqq3XOXk0petGQGiUkdsrj(Ou6ognwH(GycufeXvzqkkbbDhJgRq)qxM3ss2GfWn0jnPXr3XOXk0h0L5TKKnybCdDs7GGGUJrJvOFiMavDzEljztSu6ognwH(GycufeXvzqkkX6ognwH(HUmVLKSblGBOtAsJJUJrJvOpOlZBjjBWc4g6K2bbbPWg7eYxgI0nn8vKhZvbfj(Ou6ognwH(GycufeXvzqkkXh1DmASc9dDzEljzdwa3qN0Ka67f2yNq(YqKhZvx(mgdjiGn2jKVme5XC1LpJXqsR7y0yf6h6Y8wsYgSaUHoPrN6)GGGUJrJvOpiMavbrCvgKIs8rDhJgRq)qmbQcI4QmifLyDhJgRq)qxM3ss2GfWn0jnPXr3XOXk0h0L5TKKnybCdDst8rDhJgRq)qxM3ss2GfWn0jnjG(EHn2jKVme5XC1LpJXqccyJDc5ldrEmxD5ZymK06ognwH(HUmVLKSblGBOtA0P(piiCukDhJgRq)qmbQcI4QmifLGGUJrJvOpOlZBjjBWc4g6KM04O7y0yf6h6Y8wsYgSaUHoPDq8rDhJgRqFqxM3ss2GlhfpI1DmASc9bDzEljzdwa3qN0Ka6ln2yNq(YqKhZvx(mgdjgBStiFziYJ5QlFgJH8s3XOXk0h0L5TKKnybCdDsJo1VGGu6ognwH(GUmVLKSbxokEeFu3XOXk0h0L5TKKn4YNXyijG(EHn2jKVmePBA4RipMRU8zmgsm2yNq(YqKUPHVI8yU6YNXyiP9tpXh1DmASc9dDzEljzdwa3qN0Ka67f2yNq(YqKhZvx(mgdjiO7y0yf6d6Y8wsYgC5ZymKeqFVWg7eYxgI8yU6YNXyiX6ognwH(GUmVLKSblGBOtAsGp6buSXoH8LHipMRU8zmgYlSXoH8LHiDtdFf5XC1LpJXqccyJDc5ldrEmxD5ZymK06ognwH(HUmVLKSblGBOtA0P(feWg7eYxgI8yUkOOdcc6ognwH(GUmVLKSbx(mgdjb0xASXoH8LHiDtdFf5XC1LpJXqIpQ7y0yf6h6Y8wsYgSaUHoPjb03lSXoH8LHiDtdFf5XC1LpJXqcc6ognwH(HUmVLKSblGBOtAErn4XO1LpJXqIXg7eYxgI0nn8vKhZvx(mgdbuDhJgRq)qxM3ss2GfWn0jnPPg8y06YNXyibbP0DmASc9dXeOkiIRYGuuIpIn2jKVme5XC1LpJXqsR7y0yf6h6Y8wsYgSaUHoPrN6xqaBStiFziYJ5QGIoC4WHdhee0yXZkuNtUQzTmSxyJDc5ldrEmxD5Zym0bbbP0DmASc9dXeOkiIRYGuuILYLyzlmfsZZoHj(OUJrJvOpiMavbrCvgKIs8XJsHn2jKVme5XCvqrcc6ognwH(GUmVLKSbx(mgdjn9pi(i2yNq(YqKhZvx(mgdjTF6jiO7y0yf6d6Y8wsYgC5ZymKeqFPXg7eYxgI8yU6YNXyOdheeKs3XOXk0hetGQGiUkdsrj(Ou6ognwH(Gycu1L5TKKnbbDhJgRqFqxM3ss2GlFgJHee0DmASc9bDzEljzdwa3qN0KghDhJgRq)qxM3ss2GfWn0jTdhoi(Ou6ognwH(Hdc6chgUMu1WjHbNLlvD5abUmsqqkzqkky4KWGZYLk5WkqqrhiucLGaa]] )


end