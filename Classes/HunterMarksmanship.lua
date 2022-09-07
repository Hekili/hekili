-- HunterMarksmanship.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 20 end,
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
                return ( ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 35 )
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
                    focused_trickery_count = focused_trickery_count + ( ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 35 )
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 30 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 10 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 20 end,
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

            spend = function () return ( legendary.eagletalons_true_focus.enabled and buff.trueshot.up and 0.75 or 1 ) * 10 end,
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


    spec:RegisterPack( "Marksmanship", 20220821, [[Hekili:D3ZAtoUnY9BzkxMRONXAL48y31rsx5yN6I3SzZv34QY9jjXHcAeZkrQJpMzLlv83EAa(caSXd9y2XjPsDRhsGUB0VrZgqtho93NE)c)mY0p7nWZBW79g2F4hg((BF307Z2TLm9(T(bFX)r4)iYFd8)(F6N8L0n(rPRc3sF5U1X(lOajnopjagW3vmFvw220F6TV9XWSv5p0piEZBtd3KV2plmokiXFzg9VdE707FipCD2Vfn9bCI4MP37NNTkoz693hU5xME)QWfliLdNKgisnfZ)3ZJYijfF8NZFmpnRyU3GRO)pEEfFS4J)Yk)OhjP)uXh)XI5FM88Y48OffZ)7K041prkMhMwmpkgMLFX8nKay0HbfZZwbVYFXI4OI5b(rV95W1RH37hbSK(mqbayxuazrZW2MegNeMTRy(ZW6VyoLYlM)Z)Tpvo(praC8FSljeO6I5lyZMHNWKI5)YVcplnEdjlCdjT)07xhMMLszVzjHbFjDvm7V(mtSrI8FynzX0)1P3haiKaGegN)Asuw)0mI)IDZwghKN2VAGfZDGLz0SLRdFCvg7VEiF5sXXMq24hsPSrfZVfy)buzgiDlhdLaMMbIjL4pjpISmob4oBJZdwnlE5Se))ioz2Ye)h3aKMi5WiGLR93rssNTbKM9Z32I1VaC7gCE9zaNTGMHZfna)gLaVhi4JFcEfWv)ctSXi8G441lIFocyyPXrGMD0JZ8tsIFwGd(yaSm3VVy(f4qH)XruPYSL(KYzG9Cyg94qnOmcRGTHaTMIJwddDsX8Rhum3TCWz(almRpv1Bww8SfHegWgoqcwQxXtkhnqMu28tKzKiYMqsfMyiQCjaR7e)WfZiprvwbdhqc9vQQEjQKFhpc(GAgQBR4DrCoikNL5VLkDV1cvhW)1A2)1mYMhaTrb1uG1mllXFBxUmVQaOtLqKhslnvdekfDNefXPwMqeTNRWC(wgYmtWuNgrKzum7DlfxVJIRAeq(621XPuzdt1NJgGr(E(rYRYinUpOKFAHschNRutOYLLiL1Y(PsBMBIhwhhVyn4zNXlCvRhCyARm4hNMYOOLmJnfobF2pCDdCO8HHd072OIeEkE9AYoLogQw)vJsyDRYK07SAl1XyDC3PfaHlHyg)aeqvWqtM9YylQdpXeKDeju5jUWSfrLShg494vtFaabl)ebn0HQJwG5hUxLkMskZE1jxTUVzyrWzClgQMaLNVAxImyibjXRJtwyuH1JtJnljNuhIBO6yCCovYtEKU2yzAi4cS3HWe0zz2QX36KUftUTSjwkpvuslcaDtYxjb5zWedPzK2Oj6Vfuzxgc(pPRwzF(1dZhMuvCFrZv7Xz56GLVeak2uij7MvzIaSGbCMNmWUnHeeMsQamLhwbJCibNeA2Mu)4LWEentZ0SQ)6soFfvuyPiTrXjLKn7H4ii3TSqsI37NDZ2a5qfGYdjlLMyeKO5S8Oha)yFHk(Ek8XW1CCFGNSlGjtOoEsPzAszMYHRAzCmUaJmzeDc5rseBnuMo5g)VYfuM4NTAgSy)sI)ggCFNv(pnQUjUyXvHnOsA78)wO6(E9Up5bERQeIEwvkdvIOj0fpDBrxw6XpoQFRTq)Yxjhtoyv4gFsIpsizfz41UOGn8Lf248rDkdNlcxMGaDWBAPgHvcBlmQJDZOiqzfcaUJWyXk2sI3q(ir(Z2KNSGKqnZaN1plN1KNqCl(nGino5yxnBcJKSfKkZsPMcc(VjlbBKv0jGBa7P23)HXKT2S8wRstxqhXZM00JiPPagF2pzxklX4Tm8VDRFIFwoYg94Z62tTFStadaVN8h0X0Gg1U1eDHlQA9G)Jmp0SD6ZGJAhb0K)FimAr)Tq(W5G8MKKVLj14JzRdBlxdpLvmggQ(aVUj)U9f0nZOoXx6dsTMQq0yGfZQ(cQcTc9zXPGMocz7Q8)iD22K4G1(B8fxHSOF1mIOWD(G8cuoHHhhMkpqMMB0I8Wmqp9jy)s(RPCBapza6eyBIHd0scUC7266byLPOnvm)O)zoSbI)Oo4szrSsc3woG)Amy5Tcy8W)qRm1V3mbinGp)3(fi4rPRTRkM)m8OfXrVjJ(p0QhrREfqVfZ3wwlfq2tc8H8tkMhM9Mf0)egwmm20T(B2SRchu4e4ZGtcG5W17QWlDCGh5L0AGr1IO1IQvaDrZotcbgddJ6lII2kO0OG24)WU6ROY)IoyZP85doYl)Jz0QSvwRTzLv5eSbJ(c19jsXdScaXqEwqGGOzGiq3(91cKGfPn7FhLTIeY7AQ1l4bHgZ1s0KM1S3FRWc4D37WXcxbmz(rOr8J38GFxpjpeNLbeXSYiKpZ8Sg)1WimVkiEZehLnvnuDLuWcIiRLtxi15Rp9(Hd4Y3TTiu6zNd1QmRQebykN61n4sW7qqeEcFJKlfa3oRq041RpX5Jgj)CfuLlAEFJzQNyHYy6DuJkTvqVh2gTC0vGahSKCAwrQbwN6a4Gx3a3UChJfjWfjbG6DmQP4bdVwTKWepOl0EN4ocO2wKe6(oXYkqvssDkbt34fv1X20A7oosHwlXzlZt2P3jX3asXpkGaotH0rO(p1hh9fIC(aNJuytOmMJEVl6YSK95LsN9)KVG9Xx07ma16OhAfFl9eWs7astAD2Q(BdYk9d1w3nDfg7UZQUTOZVTXS)L5IPj7be)mXBP7JlRDIp5duWd0nU9K)6CIPsKkZVyaOoq(UOGz5BXmUmJ2dMLGRlQi0IwYoljMMsCl1lBpwr9HlXPFma1KVNEDw2IFgzDkJdOWmA2JWFNYXPmMA6O)IgRYkWHyO)sSol51VaRsmhe2Uauq5Dk()lcHdEfTt8O2RvpMxKk78(zd7Vc27jKQ)mkVxkOmNvG0eQjbUQfxZT6lAuyrIB1G2ZsAP7CAjhMN22xYXr526LYvFdPQLM4MEd8xKNW2FDzTsXOG2r4IsfTRbdSfNZgfCHnsnD0rptKYpYkN2iE8WzavsfkE1etW(TLzX3rMBGkp7mZ)uXhKKzyM36xncRxu852zjlyNb7zrKTIIMsgYeLRAhLVzKjq)2MnLDHjAu5IOcxiITUbWKiwSbmPmrVZLMYHsZYeRrrd9ltDPojG(L7PRn3fcCnoHfl)jMiXJuuOA1QhqJ6KfUrnMlnbZjDGPSgpEWTxi5I0)p3gEK7aefeGRvlafzr0ZyaGEsr7QjDJ6tLFqiKSCWmWncntU9Crze4lPZxAqhFGa3cHU5HB8HP9d8dwrOFPc)G)zoS5CAdhq8tZtiTARSm(BE)Z(rlkBrk(V(adMd1xp5E6vcmMwRmd8mMwRTPy3DokKNdnlpnPV8cLxacv0UgmWwmgxYAk4WsRf3nPEsXumwldaQj9f89iOHkp7mZ)uXh(2SRm1jfGKwRMugo10Anea(ct0OYfX3K0ApAnLdLMvMwRkrZ3M0AnSPeZP1QE5FOP1AROWyATOa6etRf3VKX0AXdU9cjxEjsRfzbyrAT4baSkTwm9PJpTwl1oTiTwZvF70sd64deOkTwVZEATEynWGqZ187SoKjDvC(6ffZz9fJFe4NN1NgfZjao2ULovyqzaAVc(3WOac9dkrpexvicE66yAN17NqHW6QOf(bLTY0cwt40VL(OIfi56nv98qAM(p9SPdVvp6PlJ80Shdw0FyFUpTn7Tm2L6dZvjBT7GkvkAKuSb0P05TAoywzUQ(E7InPrBVtABpA0tPjnNwRPdAIRAcxYRXR(rWs3Nm(wrZPd5mFiz1iE4Ou)1MpMZEuBd54x2nZ20uNVcN9Q6xO98qzx7P39RUpsBt7BRue51TB(s(nTEEVS7ldJA(m5yQhHLPmCxREOc8Q7Senu1HjI1EtM1V94ACkHJEwM05stDJtRUhZpTtPWaE0BQlV1C4NoaFwTrnFLoCCgKwApvCQ7SN64lChFcUghqZzRWKZXd4aXD2nRgQ3S6gfVU64cnM3(4iS70B21kMqpOEgA8Pd4G6jK(GQJ7uRm(aoyjJQlHHSnHk9KlqotuE0Zef9L4NwQgZijfto(h35p8W6ZzZ(E42hIfwM1Ui(bXg6SPr4jlxMZ8u4hb8yi)6aYAGtNbjMkZM0FyMA2QMYbXhaM798K616YoSZH0tWtHvhjlCjTtr3ZHfFBlv1jP8P(2K7nKt)gAp9)AC6hzROdrqYBGlEiYu38kkpWGDyzL8hh1N1XY9v4GA2ZFro050xP5K)9kqE(jb(rKwItDVWxBLwjzFQUnCTW5358CAYzxsBAuwlYVIiBF4whTVEBmINH4JFNvCDvQfJEKnhmAZBQIVvwP85oDpDRllEB8kZELPL(6KZG3TAZz4etfFG2CcmMnLYtqUCc2n2pONPATwd9u1aPkos0SqE1XqBpe2NtJkKumoM0uexDyNd4J90KJjpNIFEpnC4w1vLi(yHkQdL6AePUqqApWfw4f5vi26bM(MCcKnHNyVG4)4AcqEXr0tvAorO6BC(ZXsarzuEpdhIIUhR6gDngh1Wr(vta8ohs5xkmlfBUZjzUrFZIdhDLYD3p9aqq1ETvyqz)bTQ0QSMSQVEsY0E6Jpitahltn()tzMC0wa))5ZATWPiv(ys2(TfKMgmr65BMoOQ7tVbFGwMMKiqrbg9)9p)3)8V95)6pvmVy(VtVF7c3SnojR6ae)MSMdQ5BONk4YV(s5TshyTMNfVXN9LockVq96x8XpbIkq1ea4VehbOM963ujn)hauYI5(7AUg88Ed)QBZ89KMFRoEdi4EKkOC9XcfFGb8V9F9jjWD7XcobOC3XcfCI6dNiNE4Gtfa3CUbG1CerWCEepdF3PUCKbG90HhpyE)jshEhn)axrZ7mR46jVaBCT2aU2N0Drw8rdUUQUBkEZb5368435Lbk13yfnWO5b2cHZmhU5u7Fy84ZSx5JW9JDU3TaqADSB)8nYPR64GdmiSebvE3ZMUlkJM)13xsvFk3hs3n8PWuwrkI3wMrhqAVfYLR3T6wFv9WXqULyBJI8pyo0UXI57HmFVQ5Fh38F35D50XpVflhnKJvlNBStCNEGwuNA2whDay7mKSgCIXrp1v1qz3FhmaK9uzda8o1uJ0cGdZdUIeJoyQ4mjqLbZrTyo10I6aGJCXCY5DldGJJo8o1039ogZmpDa4yeRDsU8GPIJo7u90XrTyo1mB)nw0a6uFxDnXkMZU93HxtVKHIxgspe9F33vmh)wVN(g0B(E6lAV97P)1z8gWVcCh0TGF1CoKBcF66OKRK2Vjh0lh)wv3vu4JUTom4VVUlXUkC54wnh5UtdFUTv06k(BeQXdhqHMyrcNmC)(lKQnNZfv67LF3kCK0wL0UaD01o9ma097LMINloE4kkfc17TFFpjeTFVaICDeNYypobiaF(B(pvp)QQlwVXxpqsEGCJ8TFVMlcqg5Q8Q)Z5c9GgyrG(Q13oF)lVk3oF8mXU30Gu(3fY3yFc8DPBUTRO3thJR3ccD6Ykwk7(rhJfYgr3xDVuAKi5RrAPRLFLaRpGH7haOUy(U48eQGi)bGpcQxHRzpRy(kFQxVT5zL(aljvWhfLwPt45iWjkvQfUSYnyBp0tLOmb26y6COo4xGH2FLI2(fZ)TLuFR0ifXLalLbUOfHSvxDdL)WAsjW2q9ns9Cs)GWmCtR8FkHofy0RjKN93Dv1Rsd3WWl9RpWH2M9pes5C7QC82YpJQcbmlPmcavm3Afj9sNEQ6iS97nkXNmCW(9cFN5rdVZ1SSnyHfkaW)wExeoEiMtrZaOTG3Aa0eEpy9bcBC7TzgD09K)A2oQ4xosk)UG7j8jl1HdoDBDcxEpXvnJcvEi3WhUoYyy)EAda4ijuUURND1RdX5(URDf4p0GZnxYAuouxkqPv)KRhGtF3jJcXlpTxm00CRODMWWhKrG0DMwx0WC7inPY7CmmsQYALVPGPrOteV70g5nWfL88U7e0dO5u0sP8UNh38jR4hrA2yP0nQsLGV9dC6HFWxCu2odJUfwADEjLn6QYxg9LDdo5YtQaxV5uSi9CUeaP(dKzF9m6LCeS6CXsmSRDpVnE9Z4WawdurHoNMk2qaTvC9HH3c8SlWBqQ9772HsYSm2HZOuY2CIsCSjb7u7Zk3r(CIqxWo4Npe6RKqIyd2l9sEMvLWvHbFjxw2Cuh3RZlOwVQAPSl72VyGrCxrqy0K7OYseyROXXMm8dY7oyYqfEhg0v8wFImKTj4plfuohZk8Y2weyuB7bioZohZczrc)PoOmbvlmVa5qLZfr5DLiJ3FjILOfz6GYWUvI2LNCB(dcTFoqaveB7JXnp9ErvWgIRGDdYJz7FB8WdtZdtXtIJvURYMiDOzH2XVzpKgrQYfFfFvORMq2CCR6cVe4cSEoh2aksRiwPxjiwLxBsb)KxfQTyC6zxmLFGwyalAPhm9nx3MD23(qhnn9)ORLxFT9RdtpNZdoFRlHW)aUADAR8DXF5Z46GFxNMegQBCilI2Y2tsxlCmbUf8o5fTGMfBJviAhDxDuk2bVvqhDRdEJ1j53STD5(wI26GDmrCNTKOXueLa5liJ2M3Tr5StxW7ITniUNzDwzSu4nokWjP7rKuw5(dq2Rh1UJxphu774J8L0NV3TNNKkgyDsfYbj5k1PqdzwU5CL6tD2k9(9D7OCQxXlBkr7PQeYfMWuaLw6RtFHpHVNWbIg1ACYa5kRozO(WjA2FKd2(SuVZi9U1nAHCM93QnUOCqxM)n2d10f2n(sAdJy0RoQRXkH3eAFmFz5878BPKwN2NjOk0r0ygrCDgTt3UIEsZ5yreSvD0msjYKvfpcvehLPh8kQ6yHMHq)eBQ6nPIFlkH6Uk3JXogbe)1acxzvARQPnLxP5NfADfubd48ferCd6Q(TyUeds)MpRa0C7S0oGRaogQnJrnZYT1)AxzMU2OS9MzK6P2vsMQxFif0HBJAAkoMad)LUMnYAjGlM6pxO3ThtLMeaOQIbjmiE5KQH8NZIuWcfRVofcld06v0GfXFDJRSuK(SZyAUAlAH91kymAni(bpvAMhtPeuaQQiHQmb42seEPjo6pMg(wnW2hb3aR2lg((ImKrUO6GqyDfbSTzNv2MrOB3DSwdIXcNKsC6v)ojuNq(yBZix9UBr26rZ2oUeTuXN8Mrufb8yQeRgXUvI3dkBo1J9CRq08RokxIAIfdPsUiNdUJXuWTCRGtUwLCYUTyybHiIWr3ytYBLj)s4(HVvLjL6QZRk)nfJ4q2KInItZmgl0CV9ut0XWVHSQ4w8)qYEoa4bTRejb3PV7er5SYDPWAXOX135Lv90r5vW5vSFsF0eOw27zxatJ4lcAH7Y6kmy936UR76oBk4ePPkDWRI3oM9lP0vnDjKmv2q7MYP8VO8Zvw(BD0vT)mln20qnRe9ASepPvGDIOxgcFYzu2GUkQ(plt1PxwZbEH)sJTBzXfhxnEHmDuCLWJ25Pnhog94sAG1id20qZZ5yJS1B77exi0OVkWA7eA)4vv13AYyemv)sxzCvpcvlqNtatxOM9Qaz90GTF82rO3KW73J(4jAa1375YlpurcNf(W301ulJv2Kqdf2s(iG1TL(L)1sYrdm)XBNGUcCqF6inq679OPmRIeWjogqf4TDDx7O7Lt8gCKYnlPhEcrhBC4GlX5y6O(Js7rEsSQXOB1mrl31AUhg5RzUJe2vVwH4L6mzfadNgMSh4ZdNK9)Hw3iu47QMG62wiQ8J17czYqN8CYTUQwS0oYYsfb(1GRGDR24AhwqYd2fMRRdVJr9xx7avZYNs(IA3vx(iEI5Jykhb8v)XLpIPCFKgyxwD3RmF1Xgp)HxKXv9iuTa15T0eMSiFezZFny7yJDJgJRtEzyKWzHp8nDn9cKalAKfX8rqd5Cu5JOW)(fkjbCI78MpYbj3SKEWYhbJn(IKpIIS(0Kpc2QXY8rmX90LpcYCpM8rWmzvLpISh4ZdN8eYhXZ28rK9JPlFKUYtlZhXGIGQ8ruUp7Jji5b7ctiFet)8XOjFKVJE1B8n8hcg0mGAoemtVNEkoP3TG3WU12M()(]] )


end