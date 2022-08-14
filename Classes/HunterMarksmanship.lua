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
            duration = function () return ( legendary.eagletalons_true_focus.enabled and 18 or 15 ) * ( 1 + ( conduit.sharpshooters_focus.mod * 0.01 ) ) end,
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

    spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )

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


    do
        local initialized = false
        local setActive = false
        local wasOutdoors = false
        local focusedTrickeryCount = 0

        local tricksApplied = 0
        local tricksRemoved = 0

        local vigilApplied = 0
        local vigilRemoved = 0

        local doubleApplied = 0
        local doubleRemoved = 0



        local gearCheck = {
            PLAYER_ENTERING_WORLD = 1,
            PLAYER_EQUIPMENT_CHANGED = 1,
        }

        local resets = {
            PLAYER_ENTERING_WORLD = 1,
            ZONE_CHANGED_NEW_AREA = 1,
            FOG_OF_WAR_UPDATED = 1
        }

        local cleuEvents = {
            SPELL_AURA_APPLIED = 1,
            SPELL_AURA_APPLIED_DOSE = 1,
            SPELL_AURA_REMOVED_DOSE = 1,
            SPELL_CAST_START = 1,
            SPELL_CAST_SUCCESS = 1,
        }

        local ft = CreateFrame( "Frame" )

        ft:SetScript( "OnEvent", function( self, event, ... )
            if gearCheck[ event ] then
                if not initialized then
                    gearCheck.PLAYER_ENTERING_WORLD = nil
                    initialized = true
                end

                local hasSet = GetPlayerAuraBySpellID( 363666 ) ~= nil

                if hasSet ~= setActive then
                    setActive = hasSet
                    focusedTrickeryCount = 0
                end

                return
            end

            if not setActive then return end

            if event == "UNIT_DIED" then
                if UnitIsUnit( ..., "player" ) then
                    focusedTrickeryCount = 0
                end
                return
            end

            if resets[ event ] then
                local isOutdoors = IsOutdoors()

                if event == "FOG_OF_WAR_UPDATED" then
                    if isOutdoors ~= wasOutdoors then
                        wasOutdoors = isOutdoors
                        focusedTrickeryCount = 0
                    end

                    return
                end

                wasOutdoors = isOutdoors
                focusedTrickeryCount = 0
                return
            end

            if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                local _, subtype, _, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike = CombatLogGetCurrentEventInfo()

                if subtype == "UNIT_DIED" and destGUID == state.GUID then
                    focusedTrickeryCount = 0
                    return
                end

                local now = GetTime()
            end
        end )

    end

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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 20 end,
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
                return ( ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 35 )
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
                    focused_trickery_count = focused_trickery_count + ( ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 35 )
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 30 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 10 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.25 or 1 ) * 10 end,
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


    spec:RegisterPack( "Marksmanship", 20220809, [[Hekili:D3ZAZnUrY9BrLlJLWsMlj0JDxhsELJDQlEZMnxDYvL7tKecCOiYscWdpKw6If)TNEg8AMb98aKuRCYvUoBbmO7E63tJUbNoC6Vp9(f(zKPF2BGN3G3p8M(d)WnV37MP3NTBlz69B9d(I)JW)rK)g4)))0p5lPB8JsxfULEZDRJ9xqbsACEsaSGV7W8vzzBt)P3(2hdZwL)q)G4nVnnCt(A)SW4OGe)Lz0)o4TtV)H8W1z)w00hWjIHtV3ppBvCY07VpCZVm9(vHlwqkwojnqKAom)FppkJKC4J)C(J5PzhM)HRomNcWdF8Wh)Lv(rpss)PdF8hpm)ZKNxgNhT4W8)ojnE9tKdZdtpmpkgEi)dZ3qcGvhgCyE2k4w(lwehDyEGF0BFoC9A4((rahPpduaa2ffqwuVSTjHXjHz7om)zy7FyoLWpm)N)BFQy9FIa44)yxsiq0hMVG90m8eMCy(V8RW1sJ3qYc3qs7p9(1HPzPuUBwsyWxsxfZ(RpZKAKi)hwtwm9FD69bacjaiH15VMeL1pnJ4Vy3SLXb5P9lx4H5oW2mA2Y1HpUkJ9xpKVCP4AtiB8dPu2OdZVf4(burgiClwdLaMMbsjL4pjpISmob4oBJZdwnlE5Se))ioz2Ye)h3aKMi5WiGLR93rssNTbeM9Z32G1VaC7ACE9zaNnGMHZf1a)gLaVhi4JFcUfWv)ctSXi8G441lIFocyyPXrGID0JZ8tsIFwGd(yaSn3V)W8lWHc)LJOsLzl9jfpb21HNOhhQbLryhSneO1uC0AyPtom)6bhM7wS4mFGfM1NQ6nllE2Iqcdydhibl174jfRgitkB(jYmseztiPetmevSfG9DIF4IzKNOkRGHdiH(kvvVavY3JhbFqnd1Tr8UioheLZY83sLU3AHQd4(An7)AgzZdG2OGAkWAMLL4VTnxMxva0PsiYlPHMQacLIUtII4ultiI2ZLyoFldzMjyQtJiYmkM9ULIR3rXvfciFD764uQSHP6ZrdWkFp)k5vzKw3huYpTqjHJZvOju6YsKYAy)uPnZnXdRJJxSgCSZ4fUQ1d6M2kd(XPPmkAjZytHtWN9dxxdhkFy4a9UnkjHNIxVMStPJHY9F5Qe23Qmj9oR2sTmwh3(XcGWLqmJFacOkyOjZEzSf1HNycYwIeQ8exy2GOc2dd8E8QPpaGGLEIGg6q1rlW8d3RuftjLzV6KRw33mSi4mUbdLpaLNVAxImyibjXRJtwyuH1JtJnljNufIBO6yCCovYtEKU3yzAi4cSxxyc6SmB04BCs3Gj3g2elLNskPbbGUj5RKG8m4bdPjKwRj6Vfuzxgc(pP7wzF(vlZhEOY4(IMR2JZI9blFjauShHKSBwPjcWcgWzEYa72esqykPeWuEyjmYHeCsOzBs9Jxa7r0mntZk)Rl58vusHfI0AfNus2ShIJGC3YcjjEVF2nBdKdvakpKSuAIrqIMZYJEa8J9fQ47PWhdxZX9bEYUaMmH64jLMPjLzkhUQHXX4cmYKr0jKhjrS9qr6KB8)kxqzIF2QzWM9lj(ByW9Dw5)0O6M4Mfxf2GkPTp)3cv33R39jpWBuLq0ZktzOuenHU5PNk6Ycp(Xr9BSf6xCl5yYbRc34ts8rcjRidVMnfCEVSWANpQtz4Cr4YeeOdEtd1iStyhHrDSBgfbkRqaWDeglwXrs8gYhjYF2M8KfKeQzg4S(z5SM8eIBXFaeP1jh7Q(qyKKTGuzwk1uqW)nzjyJSI(a4gWEQ993nMS1ML3AvA6c6iE2KMEejnfW4Z(j7szjgVLH)TB9t8ZYroOhFw3EQ9JDcya49K)GUMA0O2TMOlCrvRh8FK5HMDsFgCu7iGM8)dHrl6VfYhohK3KK8TmPgFmBDyB5A4QSAXWq1h41n5pTVGUzg1j(sFqQvxfIAdSywXxqvOvOpl(iOPJq2Uk)psNTnjoyT)gFXDil6xfJikCNpiVaLty5XHPYlKP5gTipmd0tFcoVK)Ak3gWtgGob2My4aTKGl3PTUEawzkAsfZp6FMdhG4pQcUuudRKWTfl4VgdwERagp8VOvM63RFainGp)3(fi4rHRTRom)z4slIJEtg9FrREeT6va9Ey(2IAPaYEsGpKFYH5HzVzb9pHLfdRnDR)Mn7kXbfob(m4KayoC9Us8sxh4rEjTgyuTiATOAeqxuFYKqGXWWO(IOOTck1kO1(pSR(kQ8VOd2CkF(GJ8I)ygTkBf1ABwrrobBWOVqDFIu8aRaqmKNfeiiAgic0DEFTajyrA953rzRiH8UMA9cEqOXCTenPz1N93kSaE396ow4kGjZpcnIF8Mh8B7j5H4SmGiMveH8zMN14VggH5vbXBM4QSPQHQRKcwqezTC6gPkF9P3pCax(UnfHsp7COwLzvLiat5uVUbxcEDbr4j8nsUuaCNScrJxV(eNpAK8ZvqvUO59nMPEIfkJP3vBAJug94T0KSYAE6N8bI4bAwvp5VoNyQ(fYhqJbGkRSDrbZY3Ifp0mAXKwQjLwr(vxFf0flq2zjX04vnuVSfvj1hUeN(XauTZy9jgX28ZiRtzCafE0N9i83PCCkJXng9x0eGOeCi25Ve7ZcE9lWUeZ3GTBafuERkZ9Iq4G7a7epQIOwAFpCQyXeG)P8o9Zg2FfKQiezEgvAivOno7cPhOIO4kUtf)RVOzIf(zRaTNL0s7NPHCyUiBUjhpMltjL7(MZ8RJM4E8A4VipHLoCrPnWOGMv4Isfn7bdSfNZgfCHnsnD0rptKYpYo97iE8WzsvqfkU1etW(TfbDBjZnqLNDM5FQ4dsYmmZB97gH9lk(CBTLfSZGumezROOPGHmr5U2r5Dgzc0VTohQlmrJk3eL4crS1oKMeXITaAADdoFAkDLMLjwJIgAHKVuNeq)2901MBdbU3ZPfB)jMiXJuuOA3QhqJA9UPmQXCPjyoPfmL14XdU9cjxK(NItQG(cBvqaUwTbuKfrpJba6jfTRI0nQpvu)wKSCWmWncntU9Crze4BPZxAqhFGaxXx(o36dt7h4hSIqlSOFW)mpmH9(bj(P5jKgTv2zaQV)Z(rlk6Obi37106J0Kdls1FKYZ1ttEU2MBPso6zmpxBZ5U9ZOqap0Sa2Kc0luIciurZEWaBXyGkRPGULNlUFt9KIPGUwgrut(m4hAqdvE2zM)PIp8T5yAQZsajpxn5qCQ55AiI8fMOrLBIVj55E0AkDLMvMNRkrZ3M8CnCkfZ55QE7318CTvuympxuaDI55I7xYyEU4b3EHKlVe55ISbSipx8aawLNlM(0XNNRLANwKNR5YXDAPbD8bcuLNR35opxVI3md91DQD2g6H9EnCm8MqA3(j1btvdSwDOjpG46OZgyzF7B62GMwVGgnT15WRBJlBFBqTH27e7vl6B9KKq7iqS3pL63Er1USu9P9BYFsXegyAVDhhPq7Y7zlZt2P)13(nGu8JciGdC)1ZOVzB9D4Wle58bUxXnyfXyo6FVVIecf5nGGn4pPZ(FYxWglg9VMwuRJEO9IpxeHve)1zR6VniR4ne30r06Az57oR62IVw6TXS)nZftAMEpmMMEQE0X7I80Shdw0FyFU3TCdDQEAQkzdTwuHxDxb(BRDBJRFSWKUQEH3IDjrtZlABtsOqI0ZQg0zuzVl7QMWLc7)Qpdu68mCRy8WUm0fLH9qAmeTovoMH)PPJy8lANyB6QYxHHFQ6gAhij76p82oxhPTR5TvkIC7g3GY3Pj1PlBFZWOAVHyQhHf58FxJEOc8QByEgQAAEy9xKz9BpUoxsy2VYKgmm1DUS6M8(0gtGb8O3uBwRz6J6GpRM0EFLMondslTJLM6e4QIVWn)cCnhKMHBWKZXomrANDZQH6nRUrXTlNxNX82hhHDNEZUgXe6KYzi)2omPCcPpOAEJAKXDyYogvvdszBcv6jxGmusE0HsIEt8XvQ2mssXKJ)XnaGDRrJn77PAR1T0A(bXoQSUt0jlxMZ8u4hb8y4aYbK1aNoloPJttuDTwuUi(aWC3NNuVwx2HTMsobpfwntu4sANdThek(dyx2kN8P(wN7DcXFdTP6Fng)q2oQlcsEdCXP4s9jRuoXETyzf8hh1dByX5kCqn75)sk0A8N0m6DVcKNFsGFePH4u3m69uuTflC(Dohuso7sATby9O(kIS9HBv0(2vbs46D(KvCfpWIvpYMjt28HQ4RybArYACzXBJxA2RmT0xNCg8UvBodNyQ4d0MtGXSPuoc3YjyxB)GouZATgqR)j9gkMjzwiVQyOntb950OcjfJJjnfXDh2G4ESJZnM8Ck(axAy6s1vLi(yHkQdL6AePUqqARRUfErEfIT2X03KtGSo8e7ge)hxtaYloIowN5eHQVX5phlbeLr59muR82Z1CTUgJJAyMB1eaV1uc)sHzPyZTgL4A9nlMo5sL72V7qGGQ8ARWGY(jDQWQSISQ((GKPD8F7KjGJLPg))PmtoAlG))8WolmgNYZPi9D2cK4Mu5hdEq6agtxuX3ZURbnV7F2pjcuuGv)F)Z)9p)BF(V(thMFy(Vt)aZfUzBCsw5e8(MS6jL8n0XYT41Nw8zHdSwZZI34NrVqqXx0U(h(4NarfOAca8xIJauZU9BkLM)dakzXC)DfxdUEVHF1T(59KE(gD8AqWDjvq56Jfk(ad4F7)6tsG72JfCcq5UJfk4e1horo9WbNkaU5CdaR5iIG58iEg(UtD7ida7PdpEW8(tKo8oA(bUIM3zwX1tEdw7ATgCnxP9M8Whn46Q8JdXB6KFRZJFNxgOu9jJOgg1xWwiCM5W1JnF34XNzVYhH7h7CVBbG06y3(N3iNUS5K6yqyjcQ4J)A6UOmA(xFFbv9PCFiD3WNctzfPiEBrgDaP9wixUE3QB)v2ewd52InD61)G5q7glEEpKN3R85VJ75F35D70YpVfBhnKJvBNBStCN2rlQtnBRJoaSDgswdoX4ON6UAOS7Vodazpv2aaVtn1iTaOBEWvKyuNPIZKavgmh1M5utlQfaoYnZjN3Tmaoo6W7utF37ymZ80bGJrS2k5YotfhD2P6PJJAZCQz2(BSOb0h9Dv1e7WC2NFD420VYpXldPFOm(UV7WC8V6807G9LNNE9MV(80)6m(fOVeCD6RqF5Z0LVe909rbtjTFDkOxo(TQ(wnHV6MYWGF)QMe7QWLJBuCKBon8NTPGwxX)fzA8WbuOjwJWjd3V)cPsZ5CrP6EXRTchjnfjTnqhDTtpdaD)EPhXZfhpC1KcH692VVNeI2VxarUoIpYypobiaF(V8EQU(vLFy7gF9aj5bYxeV9718H4JrUk)075CHEqdSiqF16VoE)lVkFD84zIT)s)r5Fxi)fZtGVl9Lt7k6NINXvNaH(4YkwkB(rhJ1Xgr3xDRuAKi5lrAHRLFLa7pGH7haO(W8DX5jubr(daFeuVcxZU2H5R8PE92MNv4dSGubFuuAL(aphborPsTWLLUbBMbgQeLjWwhtFgQ)9fyO9xPOT)H5)2sQVvAGI4cGLYax0Iq2Ude4ju3SpSMuaSnuFJupN03hmd30c)NsOpcS61eYZ(7UQ8wPHBy4L(Yh4qB9XhcPCUDLoEB4NrLHaMLuebGkMBSIKUPtpvne2(9gL4tgoy)EHxZ8OH35Aw2gSWcfa4Fx8TaC8qmNIMbqt9U1aOj8EW6de24MzwHU6EYVmBhv8lhjLFxW9e(dl1GdoT7CcxEpXL9IcvEi3VhUoYyy)E67)3rsOCDBp7Q3hIp77U2vG)qdoxpknuouBkqPv)KRhGtF3jJcXrK5fdn1Z(YzcdFqgbstgtB0WC7i9qftwcgjvATY3tW0i0jItiZiVbUOKN3DNGEanNIgkL398463yf)ksZglLUrzQe8DFGtp85EXrz3mm6wyR16Mu2ORkFz0B2o4KlpPcC96Hyr66Cjas9hiZ(6z0l5iy35ILyyB7EEB8QRXHbS(NIcDonvSLaAR46ddVf4zxG3Fu733UbLKzzSzZOqYwpqjo2KGDQ9zL7ipMi0nSd(4HqVLese7VEPBYZSkfUkm4l4YYMJ64ETUb16vvhLDz72fdmIBlccJMChvwIaBf9n2KHFq(0btgQW7WG2I3QbYq2MGFukOCoMv4LnDiWOMUdq8jBnLfYIe(HoOibvlmVa5qPZfr5DPiJ3FjILOfz6GYWUvI2LF4M8he6(CGakj2MlJBE69IQGnexb7gKlZo)24HDtZdtXtIJvCQY6iDOzH2YVzpK(qQ0fFjFvOPMqoCCJ6cVe4cSwohoaksNiwQxjiwL3Bsb)K3fQTyC6zxmLFGwyal6Ohm9nx36t23Crhn98)ORL3FnTRdtpNZdoFNlHW)aUAvAR8nXFX14AGFxN6egQ6BilI2YotsBlCmbUf8o5nTGMf7GviAhT3Duk2bVtqhDRdEF1j53SPB5(wI2QGDmrCRJKOXueLa5liJ2E3Tw5SvtW7IDmiURzDwzSu4nUkWjP7rKuwX5dqoRh1UJxphu7B5J8L0NV3TNNKkgyDsfYbj5k1Pq)ywC4CL6tTok9(9TBOCQxXlRlr7PQeYfMWuaLg6RvBHpHVLWbIg1ACYa5kRozO(WjAoFKd25SuFYi9U1nAHCM93QnUOCqxM)n2f10e21(sAcJy0RoQRXsH3eABmFzXZ363YiToTptqvOHOXmI4AmAN2nf9K6XyreSLn0msjYKvfpcvehLPh8kQ6yHMHq7eBQ6nPIVlkH6Uk3IXogbe)xbeUYQ0uvtBkVs9plZ6kOcgW5liI4b0v9BHCbgK(nxwbO5ozPDaxbCmuBgJAMfhR)1UYmTTrzNnZi1tTRKmvVUlf0H7GAAkoMad)LUMnYAjGlMQxxO3ThtLMeaOQIbjSiE5KQL8NZIuWcfRVofcBd06vuJfXFDHlTuKETZyAUAlAH91kymAni(bpvAMhtPeuaQYiHQmb4oseEPjo6xMg(rnWohb3clplg(5ImKrUO6GqyDfbST5Kv2MrOB7tSwbIXcdsjo9Q)KeQtiFSTzKR(0Tih9O(yhxIwQ4t(WiQIaEmvIvJy3kXBNYMt9Ap3ke1)QFYLOMyXqkLlY5G7ymfClpk4KRvjNS7igwqiIiC0n2K8wrYVeUF4zvzsPU68QYFtXk6YHuSrCAMXyHM7TNAIog(nCvf3I)hY1Zba70PsKeCN(PteLZkpLcRfJgx9nRTSNok(e6Ef7xTlnbQL9E2gW0i(IGw4BrFjgS(DD32DDRdfCI0uPo4vXBhZ(Xs7Q6UesMkRPDt5u(xu(6kl(5m7QMFj1gBAPMvIEn2IN0oWor0ldHp5mkBq3f1TCXvSV5Xv90xrQp9YQN)f(pc0TltU46QOdiZhf)epG2jQ1ZkJECjTWkKbhIO(6CSv2(V5EIBeA0yfyT5bAEzwL17AYyemvDtxzCvTcvBqNtatxOM9Qaz90GTF82rOFzW3Vh9Yt0aQV3ZLxEOIeol8HVP7PggRSjHgkSH8raRBd9l)ZHMJgy(J3obDh4GE1rAG037rtHwfjGtCmGkWBB7(2r3nN4n4iLBwsp8eIo24WbxIZX0r9hL2J8dXQoJUDZeTCxR5EyKVMNDKWP81keVuNjRay40WK9aFE4KS)hADKqHVRAcQDBIOYpwVlKjdDYZj36QAZs7qllve43dUc2TAJR1TGKD2fMRRdVJr9)8launl)k5F4fC7s(jEI5NykNbCUXXLFIPCHKwyBwF7FsmuhR88hUrgxvRq1guN3ttyYI8tKDhObBhBSC0yETYtdJeol8HVP7PxGeArJ0iMFcAiOJk)ef(7VqjjGtCN38t6KCZs6bl)em24ls(jkYcut(jy7glZpXe3tx(jip7XKFcMjRQ8tK9aFE4KNq(jE2MFISFmD5N0wEAz(jgueuLFIYZDFmbj7SlmH8tm9ZdLY8tMEpDQkPFQ)UH9ruB6)7p]] )


end