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


    spec:RegisterPack( "Marksmanship", 20220305, [[d8KdscqiKupIqv1LqsGnrK(eczua0PaWQqsqEfGYSGOClKeTlq)cHYWieogvPLrv1ZaKmncvPRriABaI6BuvcJJqv4CuvswhGuVJQsk18OQ4EqK9rO8pQkP4GuvISqcvEiGWersqDrar4JaIOrsvjLCsQkrTscPxsOQeZKQsDtcvr2jGQFsvjvdLqvPwkHQINkPMkevFLqvuJfjP9cP)QsdwvhwyXe1JPYKL4YO2ms9ze1OrWPvSAcvL0RrIzRIBlj7MYVfnCI44ij0Yv65qnDsxhOTdHVJiJhHQZtvSEarA(eSFPg1lkYrRlHYOa3Vi87xeaLiej0lqbu(fHirRvpsy0AjHJsqMrRTOIrRfpflfCvyycJe0AjHNtgfuKJwJtW1XO1I)(jOQemqtmIrEucGYqxwrm8ubEcDsZTbTsm8u5igATm4CuFzdvgTUekJcC)IWVFrauIqKqVafq5xeIx06aujKlAD9ubeO1eMsHnuz06cJDO1INILcUkmmHrs)(AbAkVTOINI1rOFrIS(9lc)(BrBrbccHrMXaDlkv2pWzs0jOv6x8HX5bb3)G73sT)O)k2riSX1VsG7pkL063fgXinNt)vHfKzylkv2V4dJ9yoU0FukP1VKDYDup9tAuc9xpvar)(sIV9nSfLk733S2V4lE2jmC)fg7XC9Re4z7hiOcJ7hNvSovmgIwFgSIrroATUJJcMqQyuKJcCVOihTMTq(WfuXHw72r5Dc0AnoSPqSYrXZLoDGyiBH8Hl9lT)XU0NHmbTFP9ldstdXkhfpx60bIHlxfJH73N(fjAD40jn0ASYrXZftivuff4(rroAnBH8HlOIdT2TJY7eO1lOX05sMHssqhHBsF3ain3l9gKRytXq2c5dx6xA)YG00q6t4Hx8TkwkqqjO1HtN0qRPmNZftivuff4afkYrRzlKpCbvCO1UDuENaTEbnMoxYmusc6iCt67gaP5EP3GCfBkgYwiF4cAD40jn0A6t4HlxmHurvuGlErroAnBH8HlOIdT2TJY7eO1a2VlrWwykKINDcRFP97Y8ussgCzCAHog5BSBscUCvmgUFF6NSR0VGq)u3VlrWwykKINDcRFP9tD)UebBHPqBitqV0b3VGq)UebBHPqBitqV0b3V0(bSFxMNssYGKMt5ILm7Oy4YvXy4(9PFYUs)cc97Y8ussgK0CkxSKzhfdxUkgd3Vy9duIOFa6xqOFnwYSc1PIVAEld3Vp97ve9li0VlZtjjzWLXPf6yKVXUjj4YvXy4(fRFVIOFP9hoDqWx24QHX9lw)av)a0V0(bSFQ7FJPCzeSPWOuWqM4dwX9li0)gt5YiytHrPGHlxfJH7xS(9v9li0p197seSfMcP4zNW6ha06WPtAO1Leu(WxnKGQOaxKOihTMTq(WfuXHw72r5Dc06f0y6CjZqCcEOZLmF5kzEXq2c5dx6xA)ASxDdjWLRIXW97t)KDL(L2VlZtjjzq6tSmC5QymC)(0pzxbToC6KgATg7v3qcQIcCGmkYrRzlKpCbvCO1HtN0qRPpXYO1UDuENaTwJ9QBibckPFP9VGgtNlzgItWdDUK5lxjZlgYwiF4cA9zm(6kO1(fjQIcCFbkYrRdNoPHwZexYjXdc(IjKkAnBH8HlOIdvrbU4bkYrRzlKpCbvCO1UDuENaTM6(3ykxgbBkmkfmKj(GvC)cc9VXuUmc2uyuky4YvXy4(fRFVIOFbH(dNoi4lBC1W4(fdP(3ykxgbBkmkfm0LGM2pvO(9JwhoDsdTM0CkxSKzhfJQOa3xHIC0A2c5dxqfhATBhL3jqRDzEkjjdUmoTqhJ8n2njbxUkgd3Vp9t2v6xA)a2p19RXHnfYexYjXdc(IjKkKTq(WL(fe6xgKMgkFYSCaXkeus)a0VGq)u3VlrWwykKINDcRFbH(DzEkjjdUmoTqhJ8n2njbxUkgd3Vy97ve9li0VCIX9lTF6Hmb9UCvmgUFF6xKO1HtN0qRjfZzmY3y3KeQIcCVIaf5O1SfYhUGko0A3okVtGwdy)UmpLKKbrKNd7bUCvmgUFF6NSR0VGq)u3Vgh2uiI8Cypq2c5dx6xqOFnwYSc1PIVAEld3Vp971F)a0V0(bSFQ7FJPCzeSPWOuWqM4dwX9li0)gt5YiytHrPGHlxfJH7xS(9v9li0F40bbFzJRgg3Vyi1)gt5YiytHrPGHUe00(Pc1V)(baToC6KgA9Y40cDmY3y3KeQIcCVErroAnBH8HlOIdT2TJY7eO1YG00WLXPf6yKVXUjjiOK(fe6N6(Djc2ctHu8StyO1HtN0qRrKNd7bvrbUx)OihToC6KgATCSBqMrRzlKpCbvCOkkW9cuOihTMTq(WfuXHw72r5Dc0AzqAA4Y40cDmY3y3Keeus)cc97Y8ussgCzCAHog5BSBscUCvmgUFX63Ri6xqOFQ73LiylmfsXZoH1VGq)Yjg3V0(PhYe07YvXy4(9PF)IaToC6KgATUGmMqQOkkW9kErroAnBH8HlOIdT2TJY7eO1lOX05sMHyWL8yKVycPIHSfYhU0V0(bSFxMNssYGlJtl0XiFJDtsWLRIXW9lw)Efr)cc9tD)UebBHPqkE2jS(fe6N6(14WMcljO8HVAibYwiF4s)a0V0(LbPPH6ookxmHuXWLRIXW9lgs9ZeNDGkF1PIrRdNoPHwVHKPCPNLrvuG7vKOihTMTq(WfuXHwhoDsdToMkUCXesfT2TJY7eO1YG00qDhhLlMqQy4YvXy4(fdP(zIZoqLV6uX9lTFa7xgKMgkzz3G5lMqQyyjjz9li0pn45Cx2riwY8vNkUFF63fy9Qtf3pW6NSR0VGq)YG00qDbzmHuHGs6ha0ANh3HVASKzfJcCVOkkW9cKrroAnBH8HlOIdT2TJY7eO10Pde3pW63fy9Umz263N(PthigwfehToC6KgADHdLW1riOSrfQIcCV(cuKJwZwiF4cQ4qRD7O8obAnG97Y8ussgCzCAHog5BSBscUCvmgUFX63Ri6xA)lOX05sMHyWL8yKVycPIHSfYhU0VGq)u3VlrWwykKINDcRFbH(PU)f0y6CjZqm4sEmYxmHuXq2c5dx6xqOFQ7xJdBkSKGYh(QHeiBH8Hl9dq)s7xgKMgQ74OCXesfdxUkgd3Vyi1ptC2bQ8vNkgToC6KgA9gsMYLEwgvrbUxXduKJwZwiF4cQ4qRD7O8obATminnu3Xr5IjKkgwssw)cc9ldstdLSSBW8ftivmeus)s7NoDG4(fRFxI1(bw)HtN0GXuXLlMqQqxI1(L2pG9tD)ACytHoctvWBCXesfYwiF4s)cc9hoDqWx24QHX9lw)av)aGwhoDsdTUc8OdMqQOkkW96RqroAnBH8HlOIdT2TJY7eO1YG00qjl7gmFXesfdbL0V0(PthiUFX63LyTFG1F40jnymvC5IjKk0LyTFP9hoDqWx24QHX97t)Ix06WPtAO1octvWBCXesfvrbUFrGIC0A2c5dxqfhATBhL3jqRLbPPHfokx2ddljjdToC6KgAnL5CUycPIQOa3VxuKJwhoDsdToUvGBH3BsFDBscJwZwiF4cQ4qvuG73pkYrRdNoPHwtFcpC5IjKkAnBH8HlOIdvrbUFGcf5O1SfYhUGko06WPtAO1yELWMEX6yKrRD7O8obA9Y0lJjeYhgT25XD4RglzwXOa3lQIcC)IxuKJwZwiF4cQ4qRD7O8obAnD6aX9lw)UeR9dS(dNoPbJPIlxmHuHUeR9lTFa73L5PKKm4Y40cDmY3y3KeC5QymC)I1Vi7xqOFQ73LiylmfsXZoH1paO1HtN0qRRap6GjKkQIcC)Ief5O1SfYhUGko0A3okVtGwVGgtNlzgAmgpgzsX6bF1nKizmY3qIKydfedzlKpCbToC6KgATg7v3qcQIcC)azuKJwZwiF4cQ4qRD7O8obA9cAmDUKzOXy8yKjfRh8v3qIKXiFdjsInuqmKTq(Wf06WPtAO10lZaPJr(QBibvrbUFFbkYrRzlKpCbvCO1UDuENaTwgKMgQliJjKkSKKm06WPtAO1Yb5BsF1DCuWOkkW9lEGIC0A2c5dxqfhATBhL3jqRXj4rEScuciwbp8Lxqj6KgKTq(WL(L2VminnuxqgtivyjjzO1HtN0qRPpmMGBdAfvrbUFFfkYrRdNoPHwJvokEUycPIwZwiF4cQ4qvufTUW0b4rrrokW9IIC06WPtAO1Ue0uEVycPIwZwiF4cQ4qvuG7hf5O1SfYhUGko06WPtAO1Ue0uEVycPIw72r5Dc06f0y6CjZqmlHaiqk(kzt3jQcDsdYwiF4s)cc9JtWJ8yfOnEc8vZ8GVsYbNgKTq(WL(fe6hW(DPvahfUmcEXX5M0x6CvqJHSfYhU0V0(PU)f0y6CjZqmlHaiqk(kzt3jQcDsdYwiF4s)aGwFgJVUcAnqjcuff4afkYrRzlKpCbvCO1HtN0qR1nmQi4CgG0XiFXesfTUWy3os0jn0AGKz)bbok9hwPFKVHrfbNZaKY9dCX3ar)SXvdJrw)K4(lPrK2Fj7xjm4(PZTFjNWdV4(LzxaI5(hLOs)YC)AM9JLevvE6pSs)K4(DHrK2)YrzoE6h5ByuX(Xsy3qpU(LbPPXq0A3okVtGwtD)ASKzfo4RKt4Hxuff4IxuKJwZwiF4cQ4qRD7O8obATlrWwykKINDcRFP97Y8ussguxqgtiv4YvXy4(L2VlZtjjzWLXPf6yKVXUjj4YvXy4(fe6N6(Djc2ctHu8Sty9lTFxMNssYG6cYycPcxUkgdJwhoDsdT2fNZnC6K29myfT(my9ArfJwR7yuyfJQOaxKOihTMTq(WfuXHwhoDsdT2fNZnC6K29myfT(my9ArfJw7kyuff4azuKJwZwiF4cQ4qRD7O8obAD40bbFzJRgg3Vp9duO1yDhNIcCVO1HtN0qRDX5CdNoPDpdwrRpdwVwuXO1yfvrbUVaf5O1SfYhUGko0A3okVtGwhoDqWx24QHX9lw)(rRX6ooff4ErRdNoPHw7IZ5goDs7EgSIwFgSETOIrR1DCuWesfJQOkATKLDzLCOOihf4ErroAD40jn0A5u1dxU0NWdxing5RMeFm0A2c5dxqfhQIcC)OihToC6KgAn9HXeCBqRO1SfYhUGkouff4afkYrRzlKpCbvCO1UDuENaTEbnMoxYmeNGh6CjZxUsMxmKTq(Wf06WPtAO1ASxDdjOkkWfVOihTMTq(WfuXHwlzzxG1RovmATxrGwhoDsdTUKGYh(QHe0A3okVtGwhoDqWx24QHX9lw)E7xqOFQ73LiylmfsXZoH1V0(PUFnoSPqe55WEGSfYhUGQOaxKOihTMTq(WfuXHw72r5Dc06WPdc(YgxnmUFF6hO6xA)a2p197seSfMcP4zNW6xA)u3Vgh2uiI8Cypq2c5dx6xqO)WPdc(YgxnmUFF63F)aGwhoDsdToMkUCXesfvrboqgf5O1SfYhUGko0A3okVtGwhoDqWx24QHX9lw)(7xqOFa73LiylmfsXZoH1VGq)ACytHiYZH9azlKpCPFa6xA)Hthe8LnUAyC)i1VF06WPtAO1yLJINlMqQOkQIw7kyuKJcCVOihTMTq(WfuXHw72r5Dc0Aa7xgKMgQliJjKkeus)s7xgKMgUmoTqhJ8n2njbbL0V0(Djc2ctHu8Sty9dq)cc9dy)YG00qDbzmHuHGs6xA)YG00qsZPCXsMDumeus)s73LiylmfAdzc6Lo4(bOFbH(bSFxIGTWuic2ucE2(fe63LiylmfASBZtUL(bOFP9ldstd1fKXesfckPFbH(LtmUFP9tpKjO3LRIXW97t)EbQ(fe6hW(Djc2ctHu8Sty9lTFzqAA4Y40cDmY3y3Keeus)s7NEitqVlxfJH73N(9fav)aGwhoDsdTwMxmVugJmQIcC)OihTMTq(WfuXHw72r5Dc0AzqAAOUGmMqQqqj9li0VlZtjjzqDbzmHuHlxfJH7xS(bkr0VGq)Yjg3V0(PhYe07YvXy4(9PFVaz06WPtAO1YNmlxAW1dQIcCGcf5O1SfYhUGko0A3okVtGwldstd1fKXesfckPFbH(DzEkjjdQliJjKkC5QymC)I1pqjI(fe6xoX4(L2p9qMGExUkgd3Vp97fiJwhoDsdTomhJ1noxxCoOkkWfVOihTMTq(WfuXHw72r5Dc0AzqAAOUGmMqQqqj9li0VlZtjjzqDbzmHuHlxfJH7xS(bkr0VGq)Yjg3V0(PhYe07YvXy4(9PFFfAD40jn0A6zz5tMfuff4Ief5O1SfYhUGko0A3okVtGwldstd1fKXesfwssgAD40jn06ZqMGIVIVcwixXMIQOahiJIC0A2c5dxqfhATBhL3jqRLbPPH6cYycPcbL0V0(bSFzqAAO8jZYbeRqqj9li0VglzwHe44OeGsCA)(0VFr0pa9li0VCIX9lTF6Hmb9UCvmgUFF63pqUFbH(bSFxIGTWuifp7ew)s7xgKMgUmoTqhJ8n2njbbL0V0(PhYe07YvXy4(9PFFH)(baToC6KgATKuN0qvufTgROihf4ErroAnBH8HlOIdT2TJY7eO1ACytHyLJINlD6aXq2c5dx6xA)a2VKLrCj7kqVqSYrXZfti1(L2VminneRCu8CPthigUCvmgUFF6xK9li0VminneRCu8CPthigwssw)a0V0(bSFzqAA4Y40cDmY3y3KeSKKS(fe6N6(Djc2ctHu8Sty9daAD40jn0ASYrXZftivuff4(rroAD40jn0AkZ5CXesfTMTq(WfuXHQOahOqroAnBH8HlOIdT2TJY7eO1a2VlrWwykKINDcRFP9dy)UmpLKKbxgNwOJr(g7MKGlxfJH73N(j7k9dq)cc9tD)UebBHPqkE2jS(L2p197seSfMcTHmb9shC)cc97seSfMcTHmb9shC)s7hW(DzEkjjdsAoLlwYSJIHlxfJH73N(j7k9li0VlZtjjzqsZPCXsMDumC5QymC)I1pqjI(bOFbH(PhYe07YvXy4(9PFVISFa6xA)a2p19VXuUmc2uyukyit8bR4(fe6FJPCzeSPWOuWqqj9lTFa7FJPCzeSPWOuWWX63N(9kI(L2)gt5YiytHrPGHlxfJH73N(bQ(fe6FJPCzeSPWOuWWX6xS(dNoPDDzEkjjRFbH(dNoi4lBC1W4(fRFV9dq)cc9tD)BmLlJGnfgLcgckPFP9dy)BmLlJGnfgLcg6sqt7hP(92VGq)BmLlJGnfgLcgow)I1F40jTRlZtjjz9dq)aGwhoDsdTUKGYh(QHeuff4IxuKJwZwiF4cQ4qRD7O8obATg7v3qceus)s7FbnMoxYmeNGh6CjZxUsMxmKTq(Wf06WPtAO10Nyzuff4Ief5O1SfYhUGko0A3okVtGwVGgtNlzgItWdDUK5lxjZlgYwiF4s)s7xJ9QBibUCvmgUFF6NSR0V0(DzEkjjdsFILHlxfJH73N(j7kO1HtN0qR1yV6gsqvuGdKrroAD40jn0AM4sojEqWxmHurRzlKpCbvCOkkW9fOihTMTq(WfuXHw72r5Dc0Aa73L5PKKmOUGmMqQWLRIXW97t)KDL(fe6xgKMgQliJjKkeus)a0V0(bSFQ7FJPCzeSPWOuWqM4dwX9li0p19VXuUmc2uyukyiOK(L2)gt5YiytHrPGHfWn0jT(bw)BmLlJGnfgLcgow)(0VFr0VGq)BmLlJGnfgLcgckPFP9VXuUmc2uyuky4YvXy4(fRFV(Q(fe6pC6GGVSXvdJ7xS(92pa9li0p9qMGExUkgd3Vp9lEic06WPtAO1KMt5ILm7Oyuff4IhOihToC6KgAn9j8WLlMqQO1SfYhUGkouff4(kuKJwZwiF4cQ4qRD7O8obAnD6aX9dS(DbwVltMT(9PF60bIHvbXrRdNoPHwx4qjCDeckBuHQOa3RiqroAD40jn064wbUfEVj91TjjmAnBH8HlOIdvrbUxVOihTMTq(WfuXHw72r5Dc0AxMNssYGlJtl0XiFJDtsWLRIXW97t)KDL(L2pG9tD)ACytHmXLCs8GGVycPczlKpCPFbH(LbPPHYNmlhqScbL0pa9li0p197seSfMcP4zNW6xqOFxMNssYGlJtl0XiFJDtsWLRIXW9li0VCIX9lTF6Hmb9UCvmgUFF6xKO1HtN0qRjfZzmY3y3KeQIcCV(rroAnBH8HlOIdT2TJY7eO1a2VminnSKGYh(QHeiOK(fe6N6(14WMcljO8HVAibYwiF4s)cc9tpKjO3LRIXW97t)E93pa9lTFa7N6(3ykxgbBkmkfmKj(GvC)cc9tD)BmLlJGnfgLcgckPFP9dy)BmLlJGnfgLcgwa3qN06hy9VXuUmc2uyuky4y97t)Efr)cc9VXuUmc2uyukyOlbnTFK63B)a0VGq)BmLlJGnfgLcgckPFP9VXuUmc2uyuky4YvXy4(fRFFv)cc9hoDqWx24QHX9lw)E7ha06WPtAO1lJtl0XiFJDtsOkkW9cuOihTMTq(WfuXHw72r5Dc0AzqAA4Y40cDmY3y3Keeus)cc9tD)UebBHPqkE2jS(L2pG9ldstdLSSBW8ftivmSKKS(fe6N6(14WMcDeMQG34IjKkKTq(WL(fe6pC6GGVSXvdJ73N(93paO1HtN0qRrKNd7bvrbUxXlkYrRzlKpCbvCO1UDuENaT2LiylmfsXZoH1V0(PthiUFG1VlW6DzYS1Vp9tNoqmSkiE)s7hW(bSFxMNssYGlJtl0XiFJDtsWLRIXW97t)KDL(Pc1pq1V0(bSFQ7hNGh5XkqMMgepi4BytvCdNJp8gAUq2c5dx6xqOFQ7xJdBkSKGYh(QHeiBH8Hl9dq)a0VGq)ACytHLeu(WxnKazlKpCPFP97Y8ussgSKGYh(QHe4YvXy4(9PFGQFaqRdNoPHwJvokEUycPIQOa3RirroAnBH8HlOIdT2TJY7eO1lOX05sMHyWL8yKVycPIHSfYhU0V0(14WMcX6Yr1zmgYwiF4s)s7hW(DzEkjjdUmoTqhJ8n2njbxUkgd3Vy97ve9li0p197seSfMcP4zNW6xqOFQ7xJdBkSKGYh(QHeiBH8Hl9li0pobpYJvGmnniEqW3WMQ4gohF4n0CHSfYhU0paO1HtN0qR3qYuU0ZYOkkW9cKrroAnBH8HlOIdT2TJY7eO1a2pG9ldstdLSSBW8ftivmSKKS(fe6xJdBk0fNZyKVkb(IjKkgYwiF4s)a0V0(Djc2ctHiytj4z7xqOFxIGTWuOXUnp5w6xqOFxMNssYGlJtl0XiFJDtsWLRIXW9lw)aLi6xqOFxMNssYGlJtl0XiFJDtsWLRIXW97t)Efr)cc97Y8ussgK0CkxSKzhfdxUkgd3Vy9duIOFbH(LbPPHKMt5ILm7OyiOK(bOFbH(LbPPHiYZH9abL0V0(dNoi4lBC1W4(fRFV9li0VCIX9lTF6Hmb9UCvmgUFF63VirRdNoPHwRliJjKkQIcCV(cuKJwZwiF4cQ4qRdNoPHwhtfxUycPIw72r5Dc0AzqAAOKLDdMVycPIHLKK1VGq)a2VminnuxqgtiviOK(fe6Ng8CUl7ielz(Qtf3Vp9t2v6hy97cSE1PI7hG(L2pG9tD)ACytHoctvWBCXesfYwiF4s)cc9hoDqWx24QHX97t)(7hG(fe6xgKMgQ74OCXesfdxUkgd3Vy9ZeNDGkF1PI7xA)Hthe8LnUAyC)I1Vx0ANh3HVASKzfJcCVOkkW9kEGIC0A2c5dxqfhATBhL3jqRbSFxMNssYGlJtl0XiFJDtsWLRIXW9lw)Efr)cc9tD)UebBHPqkE2jS(fe6N6(14WMcljO8HVAibYwiF4s)cc9JtWJ8yfittdIhe8nSPkUHZXhEdnxiBH8Hl9dq)s7NoDG4(bw)UaR3LjZw)(0pD6aXWQG49lTFa7xgKMgwsq5dF1qcSKKS(L2VminnKdYhwJtA4RUG8LoDGyyjjz9li0Vgh2uiwxoQoJXq2c5dx6ha06WPtAO1Bizkx6zzuff4E9vOihTMTq(WfuXHw72r5Dc0AzqAAOKLDdMVycPIHGs6xqOF60bI7xS(Djw7hy9hoDsdgtfxUycPcDjwrRdNoPHw7imvbVXftivuff4(fbkYrRzlKpCbvCO1UDuENaTwgKMgkzz3G5lMqQyiOK(fe6NoDG4(fRFxI1(bw)HtN0GXuXLlMqQqxIv06WPtAO1X6cJVycPIQOa3VxuKJwZwiF4cQ4qRdNoPHwJ5vcB6fRJrgT2TJY7eO1ltVmMqiF4(L2VglzwH6uXxnVLH7xS(lGBOtAO1opUdF1yjZkgf4ErvuG73pkYrRzlKpCbvCO1UDuENaToC6GGVSXvdJ7xS(9IwhoDsdTwo2niZOkkW9duOihTMTq(WfuXHw72r5Dc0Aa73L5PKKm4Y40cDmY3y3KeC5QymC)I1Vxr0V0(xqJPZLmdXGl5XiFXesfdzlKpCPFbH(PUFxIGTWuifp7ew)cc9tD)ACytHLeu(WxnKazlKpCPFbH(Xj4rEScKPPbXdc(g2uf3W54dVHMlKTq(WL(bOFP9tNoqC)aRFxG17YKzRFF6NoDGyyvq8(L2pG9ldstdljO8HVAibwssw)cc9RXHnfI1LJQZymKTq(WL(baToC6KgA9gsMYLEwgvrbUFXlkYrRzlKpCbvCO1UDuENaTwgKMgQliJjKkSKKm06WPtAO1Yb5BsF1DCuWOkkW9lsuKJwZwiF4cQ4qRD7O8obAnobpYJvGsaXk4HV8ckrN0GSfYhU0V0(LbPPH6cYycPcljjdToC6KgAn9HXeCBqROkkW9dKrroAD40jn0ASYrXZftiv0A2c5dxqfhQIQO16ogfwXOihf4ErroAnBH8HlOIdToLGwJzfToC6KgAnIyNq(WO1iIdiJwldstdxgNwOJr(g7MKGGs6xqOFzqAAOUGmMqQqqjO1iI9ArfJwJ9yUlOeuff4(rroAnBH8HlOIdToLGwJzfToC6KgAnIyNq(WO1iIdiJw7seSfMcP4zNW6xA)YG00WLXPf6yKVXUjjiOK(L2VminnuxqgtiviOK(fe6N6(Djc2ctHu8Sty9lTFzqAAOUGmMqQqqjO1iI9ArfJwJ1nnYxShZDbLGQOahOqroAnBH8HlOIdToLGwJzDOrRdNoPHwJi2jKpmAnIyVwuXO1yDtJ8f7XC3LRIXWO1UDuENaTwgKMgQliJjKkSKKS(L2VlrWwykKINDcdTgrCa5lFWmATlZtjjzqDbzmHuHlxfJHrRrehqgT2L5PKKm4Y40cDmY3y3KeC5QymC)(4RPFxMNssYG6cYycPcxUkgdJQOax8IIC0A2c5dxqfhADkbTgZ6qJwhoDsdTgrStiFy0AeXETOIrRX6Mg5l2J5UlxfJHrRD7O8obATminnuxqgtiviOK(L2VlrWwykKINDcdTgrCa5lFWmATlZtjjzqDbzmHuHlxfJHrRrehqgT2L5PKKm4Y40cDmY3y3KeC5QymmQIcCrIIC0A2c5dxqfhADkbTgZ6qJwhoDsdTgrStiFy0AeXETOIrRXEm3D5QymmATBhL3jqRDjc2ctHu8StyO1iIdiF5dMrRDzEkjjdQliJjKkC5QymmAnI4aYO1UmpLKKbxgNwOJr(g7MKGlxfJH7xmFn97Y8ussguxqgtiv4YvXyyuff4azuKJwZwiF4cQ4qRdNoPHwR7yuy1lATBhL3jqRbSFa7x3XOWku9cje4liMVYG009li0VlrWwykKINDcRFP9R7yuyfQEHec81L5PKKS(bOFP9dy)iIDc5ddX6Mg5l2J5UGs6xA)a2p197seSfMcP4zNW6xA)u3VUJrHvO6hsiWxqmFLbPP7xqOFxIGTWuifp7ew)s7N6(1DmkScv)qcb(6Y8ussw)cc9R7yuyfQ(HUmpLKKbxUkgd3VGq)6ogfwHQxiHaFbX8vgKMUFP9dy)u3VUJrHvO6hsiWxqmFLbPP7xqOFDhJcRq1l0L5PKKmybCdDsRFXqQFDhJcRq1p0L5PKKmybCdDsRFa6xqOFDhJcRq1lKqGVUmpLKK1V0(PUFDhJcRq1pKqGVGy(kdst3V0(1DmkScvVqxMNssYGfWn0jT(fdP(1DmkScv)qxMNssYGfWn0jT(bOFbH(PUFeXoH8HHyDtJ8f7XCxqj9lTFa7N6(1DmkScv)qcb(cI5RminD)s7hW(1DmkScvVqxMNssYGfWn0jT(PY(fz)(0pIyNq(WqShZDxUkgd3VGq)iIDc5ddXEm3D5QymC)I1VUJrHvO6f6Y8ussgSaUHoP1pX63F)a0VGq)6ogfwHQFiHaFbX8vgKMUFP9dy)6ogfwHQxiHaFbX8vgKMUFP9R7yuyfQEHUmpLKKblGBOtA9lgs9R7yuyfQ(HUmpLKKblGBOtA9lTFa7x3XOWku9cDzEkjjdwa3qN06Nk7xK97t)iIDc5ddXEm3D5QymC)cc9Ji2jKpme7XC3LRIXW9lw)6ogfwHQxOlZtjjzWc4g6Kw)eRF)9dq)cc9dy)u3VUJrHvO6fsiWxqmFLbPP7xqOFDhJcRq1p0L5PKKmybCdDsRFXqQFDhJcRq1l0L5PKKmybCdDsRFa6xA)a2VUJrHvO6h6Y8ussgC5O4PFP9R7yuyfQ(HUmpLKKblGBOtA9tL9lY(fRFeXoH8HHypM7UCvmgUFP9Ji2jKpme7XC3LRIXW97t)6ogfwHQFOlZtjjzWc4g6Kw)eRF)9li0p19R7yuyfQ(HUmpLKKbxokE6xA)a2VUJrHvO6h6Y8ussgC5QymC)uz)ISFF6hrStiFyiw30iFXEm3D5QymC)s7hrStiFyiw30iFXEm3D5QymC)I1VFr0V0(bSFDhJcRq1l0L5PKKmybCdDsRFQSFr2Vp9Ji2jKpme7XC3LRIXW9li0VUJrHvO6h6Y8ussgC5QymC)uz)ISFF6hrStiFyi2J5UlxfJH7xA)6ogfwHQFOlZtjjzWc4g6Kw)uz)Efr)aRFeXoH8HHypM7UCvmgUFF6hrStiFyiw30iFXEm3D5QymC)cc9Ji2jKpme7XC3LRIXW9lw)6ogfwHQxOlZtjjzWc4g6Kw)eRF)9li0pIyNq(WqShZDbL0pa9li0VUJrHvO6h6Y8ussgC5QymC)uz)ISFX6hrStiFyiw30iFXEm3D5QymC)s7hW(1DmkScvVqxMNssYGfWn0jT(PY(fz)(0pIyNq(WqSUPr(I9yU7YvXy4(fe6N6(1DmkScvVqcb(cI5RminD)s7hW(re7eYhgI9yU7YvXy4(fRFDhJcRq1l0L5PKKmybCdDsRFI1V)(fe6hrStiFyi2J5UGs6hG(bOFa6hG(bOFa6xqOFnwYSc1PIVAEld3Vp9Ji2jKpme7XC3LRIXW9dq)cc9tD)6ogfwHQxiHaFbX8vgKMUFP9tD)UebBHPqkE2jS(L2pG9R7yuyfQ(Hec8feZxzqA6(L2pG9dy)u3pIyNq(WqShZDbL0VGq)6ogfwHQFOlZtjjzWLRIXW9lw)ISFa6xA)a2pIyNq(WqShZDxUkgd3Vy97xe9li0VUJrHvO6h6Y8ussgC5QymC)uz)ISFX6hrStiFyi2J5UlxfJH7hG(bOFbH(PUFDhJcRq1pKqGVGy(kdst3V0(bSFQ7x3XOWku9dje4RlZtjjz9li0VUJrHvO6h6Y8ussgC5QymC)cc9R7yuyfQ(HUmpLKKblGBOtA9lgs9R7yuyfQEHUmpLKKblGBOtA9dq)a0pa9lTFa7N6(1DmkScvVWbdDHJaFt6B4OIGZYLRUCGbxg3VGq)Hthe8LnUAyC)(0V)(L2p19ldstddhveCwUCjfwbckPFbH(dNoi4lBC1W4(fRFV9lTFzqAAy4OIGZYLBqCgckPFaqRXNuXO16ogfw9IQOa3xGIC0A2c5dxqfhAD40jn0ADhJcR(rRD7O8obAnG9dy)6ogfwHQFiHaFbX8vgKMUFbH(Djc2ctHu8Sty9lTFDhJcRq1pKqGVUmpLKK1pa9lTFa7hrStiFyiw30iFXEm3fus)s7hW(PUFxIGTWuifp7ew)s7N6(1DmkScvVqcb(cI5RminD)cc97seSfMcP4zNW6xA)u3VUJrHvO6fsiWxxMNssY6xqOFDhJcRq1l0L5PKKm4YvXy4(fe6x3XOWku9dje4liMVYG009lTFa7N6(1DmkScvVqcb(cI5RminD)cc9R7yuyfQ(HUmpLKKblGBOtA9lgs9R7yuyfQEHUmpLKKblGBOtA9dq)cc9R7yuyfQ(Hec81L5PKKS(L2p19R7yuyfQEHec8feZxzqA6(L2VUJrHvO6h6Y8ussgSaUHoP1Vyi1VUJrHvO6f6Y8ussgSaUHoP1pa9li0p19Ji2jKpmeRBAKVypM7ckPFP9dy)u3VUJrHvO6fsiWxqmFLbPP7xA)a2VUJrHvO6h6Y8ussgSaUHoP1pv2Vi73N(re7eYhgI9yU7YvXy4(fe6hrStiFyi2J5UlxfJH7xS(1DmkScv)qxMNssYGfWn0jT(jw)(7hG(fe6x3XOWku9cje4liMVYG009lTFa7x3XOWku9dje4liMVYG009lTFDhJcRq1p0L5PKKmybCdDsRFXqQFDhJcRq1l0L5PKKmybCdDsRFP9dy)6ogfwHQFOlZtjjzWc4g6Kw)uz)ISFF6hrStiFyi2J5UlxfJH7xqOFeXoH8HHypM7UCvmgUFX6x3XOWku9dDzEkjjdwa3qN06Ny97VFa6xqOFa7N6(1DmkScv)qcb(cI5RminD)cc9R7yuyfQEHUmpLKKblGBOtA9lgs9R7yuyfQ(HUmpLKKblGBOtA9dq)s7hW(1DmkScvVqxMNssYGlhfp9lTFDhJcRq1l0L5PKKmybCdDsRFQSFr2Vy9Ji2jKpme7XC3LRIXW9lTFeXoH8HHypM7UCvmgUFF6x3XOWku9cDzEkjjdwa3qN06Ny97VFbH(PUFDhJcRq1l0L5PKKm4YrXt)s7hW(1DmkScvVqxMNssYGlxfJH7Nk7xK97t)iIDc5ddX6Mg5l2J5UlxfJH7xA)iIDc5ddX6Mg5l2J5UlxfJH7xS(9lI(L2pG9R7yuyfQ(HUmpLKKblGBOtA9tL9lY(9PFeXoH8HHypM7UCvmgUFbH(1DmkScvVqxMNssYGlxfJH7Nk7xK97t)iIDc5ddXEm3D5QymC)s7x3XOWku9cDzEkjjdwa3qN06Nk73Ri6hy9Ji2jKpme7XC3LRIXW97t)iIDc5ddX6Mg5l2J5UlxfJH7xqOFeXoH8HHypM7UCvmgUFX6x3XOWku9dDzEkjjdwa3qN06Ny97VFbH(re7eYhgI9yUlOK(bOFbH(1DmkScvVqxMNssYGlxfJH7Nk7xK9lw)iIDc5ddX6Mg5l2J5UlxfJH7xA)a2VUJrHvO6h6Y8ussgSaUHoP1pv2Vi73N(re7eYhgI1nnYxShZDxUkgd3VGq)u3VUJrHvO6hsiWxqmFLbPP7xA)a2pIyNq(WqShZDxUkgd3Vy9R7yuyfQ(HUmpLKKblGBOtA9tS(93VGq)iIDc5ddXEm3fus)a0pa9dq)a0pa9dq)cc9RXsMvOov8vZBz4(9PFeXoH8HHypM7UCvmgUFa6xqOFQ7x3XOWku9dje4liMVYG009lTFQ73LiylmfsXZoH1V0(bSFDhJcRq1lKqGVGy(kdst3V0(bSFa7N6(re7eYhgI9yUlOK(fe6x3XOWku9cDzEkjjdUCvmgUFX6xK9dq)s7hW(re7eYhgI9yU7YvXy4(fRF)IOFbH(1DmkScvVqxMNssYGlxfJH7Nk7xK9lw)iIDc5ddXEm3D5QymC)a0pa9li0p19R7yuyfQEHec8feZxzqA6(L2pG9tD)6ogfwHQxiHaFDzEkjjRFbH(1DmkScvVqxMNssYGlxfJH7xqOFDhJcRq1l0L5PKKmybCdDsRFXqQFDhJcRq1p0L5PKKmybCdDsRFa6hG(bOFP9dy)u3VUJrHvO6hoyOlCe4BsFdhveCwUC1Ldm4Y4(fe6pC6GGVSXvdJ73N(93V0(PUFzqAAy4OIGZYLlPWkqqj9li0F40bbFzJRgg3Vy97TFP9ldstddhveCwUCdIZqqj9daAn(KkgTw3XOWQFufvrv0Ae8IN0qbUFr43Vi87hiJwtkwBmYy0AXZ(sIpa3xg4ajb6(7h5e4(Nkj5Q9tNB)eP74OGjKkMO(xMkcolx6hNvC)bOMvHYL(DecJmJHTO(EmUFVaD)arAi4v5s)ePXHnfsvI6xZ(jsJdBkKQq2c5dxiQFa9sCaGTO(EmUF)aD)arAi4v5s)eTGgtNlzgsvI6xZ(jAbnMoxYmKQq2c5dxiQFa9sCaGTO(EmUFGcO7hisdbVkx6NOf0y6CjZqQsu)A2prlOX05sMHufYwiF4cr9hA)aj819D)a6L4aaBr99yC)IeO7hisdbVkx6NOf0y6CjZqQsu)A2prlOX05sMHufYwiF4cr9dOxIdaSf13JX9dKb6(bI0qWRYL(jAbnMoxYmKQe1VM9t0cAmDUKzivHSfYhUqu)H2pqcFDF3pGEjoaWwuFpg3VVcO7hisdbVkx6NinoSPqQsu)A2prACytHufYwiF4cr9dOxIdaSf13JX97veaD)arAi4v5s)ePXHnfsvI6xZ(jsJdBkKQq2c5dxiQFa9sCaGTO(EmUFVIxGUFGine8QCPFI04WMcPkr9Rz)ePXHnfsviBH8Hle1pGEjoaWwuFpg3VxXlq3pqKgcEvU0prlOX05sMHuLO(1SFIwqJPZLmdPkKTq(WfI6hqVehaylQVhJ73RVaO7hisdbVkx6NinoSPqQsu)A2prACytHufYwiF4cr9dOxIdaSf13JX971xa09dePHGxLl9t0cAmDUKzivjQFn7NOf0y6CjZqQczlKpCHO(b0pXba2I67X4(9kEa09dePHGxLl9tKgh2uivjQFn7NinoSPqQczlKpCHO(b0lXba2I67X4(9lsGUFGine8QCPFIwqJPZLmdPkr9Rz)eTGgtNlzgsviBH8Hle1FO9dKWx339dOxIdaSf13JX97hid09dePHGxLl9t0cAmDUKzivjQFn7NOf0y6CjZqQczlKpCHO(dTFGe(6(UFa9sCaGTO(EmUF)IhaD)arAi4v5s)eHtWJ8yfivjQFn7NiCcEKhRaPkKTq(WfI6hqVehaylAlQ4zFjXhG7ldCGKaD)9JCcC)tLKC1(PZTFIkmDaEuI6FzQi4SCPFCwX9hGAwfkx63rimYmg2I67X4(9d09dePHGxLl9t0cAmDUKzivjQFn7NOf0y6CjZqQczlKpCHO(b0lXba2I67X4(9d09dePHGxLl9t0cAmDUKzivjQFn7NOf0y6CjZqQczlKpCHO(b0lXba2I67X4(9d09dePHGxLl9tKlTc4OqQsu)A2prU0kGJcPkKTq(WfI6hqVehaylQVhJ73pq3pqKgcEvU0pr4e8ipwbsvI6xZ(jcNGh5XkqQczlKpCHO(b0lXba2I2IkE2xs8b4(Yahijq3F)iNa3)ujjxTF6C7Nijl7Yk5qjQ)LPIGZYL(Xzf3FaQzvOCPFhHWiZyylQVhJ7hOa6(bI0qWRYL(jAbnMoxYmKQe1VM9t0cAmDUKzivHSfYhUqu)H2pqcFDF3pGEjoaWwuFpg3V4fO7hisdbVkx6NinoSPqQsu)A2prACytHufYwiF4cr9hA)aj819D)a6L4aaBr99yC)IeO7hisdbVkx6NinoSPqQsu)A2prACytHufYwiF4cr9dOxIdaSf13JX9dKb6(bI0qWRYL(jsJdBkKQe1VM9tKgh2uivHSfYhUqu)a6L4aaBrBrfp7lj(aCFzGdKeO7VFKtG7FQKKR2pDU9tewjQ)LPIGZYL(Xzf3FaQzvOCPFhHWiZyylQVhJ73lq3pqKgcEvU0prACytHuLO(1SFI04WMcPkKTq(WfI6hqVehaylQVhJ7x8c09dePHGxLl9t0cAmDUKzivjQFn7NOf0y6CjZqQczlKpCHO(dTFGe(6(UFa9sCaGTO(EmUFrc09dePHGxLl9t0cAmDUKzivjQFn7NOf0y6CjZqQczlKpCHO(b0lXba2I67X4(96fO7hisdbVkx6NinoSPqQsu)A2prACytHufYwiF4cr9dOxIdaSf13JX971pq3pqKgcEvU0prACytHuLO(1SFI04WMcPkKTq(WfI6hqVehaylQVhJ73lqb09dePHGxLl9tKgh2uivjQFn7NinoSPqQczlKpCHO(b0lXba2I67X4(9kEb6(bI0qWRYL(jsJdBkKQe1VM9tKgh2uivHSfYhUqu)a6N4aaBr99yC)EfVaD)arAi4v5s)eHtWJ8yfivjQFn7NiCcEKhRaPkKTq(WfI6hqVehaylQVhJ73Rib6(bI0qWRYL(jsJdBkKQe1VM9tKgh2uivHSfYhUqu)a6N4aaBr99yC)Efjq3pqKgcEvU0prlOX05sMHuLO(1SFIwqJPZLmdPkKTq(WfI6hqVehaylQVhJ73Rib6(bI0qWRYL(jcNGh5XkqQsu)A2pr4e8ipwbsviBH8Hle1pGEjoaWwuFpg3VxGmq3pqKgcEvU0prACytHuLO(1SFI04WMcPkKTq(WfI6hqVehaylQVhJ73RVaO7hisdbVkx6NinoSPqQsu)A2prACytHufYwiF4cr9dOxIdaSf13JX97v8aO7hisdbVkx6NinoSPqQsu)A2prACytHufYwiF4cr9dOFIdaSf13JX97v8aO7hisdbVkx6NiCcEKhRaPkr9Rz)eHtWJ8yfivHSfYhUqu)a6L4aaBr99yC)(bkGUFGine8QCPFI04WMcPkr9Rz)ePXHnfsviBH8Hle1pG(joaWwuFpg3VFGcO7hisdbVkx6NOf0y6CjZqQsu)A2prlOX05sMHufYwiF4cr9dOxIdaSf13JX97hOa6(bI0qWRYL(jcNGh5XkqQsu)A2pr4e8ipwbsviBH8Hle1pGEjoaWwuFpg3VFrc09dePHGxLl9teobpYJvGuLO(1SFIWj4rEScKQq2c5dxiQFa9sCaGTOTOIN9LeFaUVmWbsc093pYjW9pvsYv7No3(js3XOWkMO(xMkcolx6hNvC)bOMvHYL(DecJmJHTO(EmUFGmq3pqKgcEvU0F9ube9J9yAq8(Pc6xZ(9ny0Fzqm4jT(tj8gAU9diXaOFafjXba2I67X4(bYaD)arAi4v5s)eP7yuyf6fsvI6xZ(js3XOWku9cPkr9dOF)ehaylQVhJ7hid09dePHGxLl9tKUJrHvOFivjQFn7NiDhJcRq1pKQe1pG(bYehaylQVhJ73xa09dePHGxLl9xpvar)ypMgeVFQG(1SFFdg9xgedEsR)ucVHMB)asma6hqrsCaGTO(EmUFFbq3pqKgcEvU0pr6ogfwHEHuLO(1SFI0DmkScvVqQsu)a6hitCaGTO(EmUFFbq3pqKgcEvU0pr6ogfwH(HuLO(1SFI0DmkScv)qQsu)a63pXba2I2I6lxjjxLl9dK7pC6Kw)NbRyylkAnwc7qbUFrkErRLSj9Cy0AXV4VFXtXsbxfgMWiPFFTanL3wuXV4VFXtX6i0Virw)(fHF)TOTOIFXF)abHWiZyGUfv8l(7Nk7h4mj6e0k9l(W48GG7FW9BP2F0Ff7ie246xjW9hLsA97cJyKMZP)QWcYmSfv8l(7Nk7x8HXEmhx6pkL06xYo5oQN(jnkH(RNkGOFFjX3(g2Ik(f)9tL97Bw7x8fp7egU)cJ9yU(vc8S9deuHX9JZkwNkgdBrBrdNoPHHsw2LvYHcmKiMCQ6Hlx6t4HlKgJ8vtIpwlA40jnmuYYUSsouGHeXOpmMGBdATfnC6KggkzzxwjhkWqIyASxDdjiBOrAbnMoxYmeNGh6CjZxUsMxClA40jnmuYYUSsouGHeXkjO8HVAibzsw2fy9QtfJKxrGSHgPWPdc(YgxnmwmVccu7seSfMcP4zNWKsTgh2uiI8CypTOHtN0Wqjl7Yk5qbgselMkUCXesfzdnsHthe8LnUAySpaLuaP2LiylmfsXZoHjLAnoSPqe55WEeecNoi4lBC1WyF8dqlA40jnmuYYUSsouGHeXWkhfpxmHur2qJu40bbFzJRgglMFbbaDjc2ctHu8StyccACytHiYZH9aG0WPdc(Ygxnmgj)TOTOHtN0WadjI5sqt59IjKAlA40jnmWqIyUe0uEVycPISZy81vqcOebYgAKwqJPZLmdXSecGaP4RKnDNOk0jnbbCcEKhRaTXtGVAMh8vso40eea0LwbCu4Yi4fhNBsFPZvbnwk1lOX05sMHywcbqGu8vYMUtuf6KgaTOI)(bsM9he4O0FyL(r(ggveCodqk3pWfFde9Zgxnm2x7(jX9xsJiT)s2VsyW9tNB)soHhEX9lZUaeZ9pkrL(L5(1m7hljQQ80FyL(jX97cJiT)LJYC80pY3WOI9JLWUHEC9ldstJHTOHtN0WadjIPByurW5maPJr(IjKkYgAKOwJLmRWbFLCcp82IgoDsddmKiMloNB40jT7zWkYSOIrs3XOWkgzdnsUebBHPqkE2jmPUmpLKKb1fKXesfUCvmgwQlZtjjzWLXPf6yKVXUjj4YvXyybbQDjc2ctHu8StysDzEkjjdQliJjKkC5QymClQ4x83pvy(eE6NoCJrUFpj42FjbL1(bnDo97jb7NqGG7xcO2V4dJtl0Xi3VV0UjP(ljjdz9NB)dD)kbUFxMNssY6FW9Rz2)jnY9Rz)f(eE6NoCJrUFpj42pv4euwH97lt3VLg3Fs3VsGXC)U0kJoPH7pwU)q(W9Rz)vS2pPrjmw)kbUFVIOFm7sRG7)WmPWdY6xjW9JNQ(PdhJ73tcU9tfobL1(dqnRcDCX54b2Ik(f)9hoDsddmKiMXKOtqRCxgNhemYgAKWj4rESc0ys0jOvUlJZdcwkGYG00WLXPf6yKVXUjjiOebbxMNssYGlJtl0XiFJDtsWLRIXWI5vecc0dzc6D5QymSpEbYa0IgoDsddmKiMloNB40jT7zWkYSOIrYvWTOHtN0WadjI5IZ5goDs7EgSImlQyKWkYW6oofjViBOrkC6GGVSXvdJ9bOArdNoPHbgseZfNZnC6K29myfzwuXiP74OGjKkgzyDhNIKxKn0ifoDqWx24QHXI5VfTfnC6Kgg6kyKK5fZlLXiJSHgjaLbPPH6cYycPcbLivgKMgUmoTqhJ8n2njbbLi1LiylmfsXZoHbGGaGYG00qDbzmHuHGsKkdstdjnNYflz2rXqqjsDjc2ctH2qMGEPdgabbaDjc2ctHiytj4zfeCjc2ctHg728KBbaPYG00qDbzmHuHGseeKtmwk9qMGExUkgd7JxGsqaqxIGTWuifp7eMuzqAA4Y40cDmY3y3KeeuIu6Hmb9UCvmg2hFbqbqlA40jnm0vWadjIjFYSCPbxpiBOrsgKMgQliJjKkeuIGGlZtjjzqDbzmHuHlxfJHfdOeHGGCIXsPhYe07YvXyyF8cKBrdNoPHHUcgyirSWCmw34CDX5GSHgjzqAAOUGmMqQqqjccUmpLKKb1fKXesfUCvmgwmGseccYjglLEitqVlxfJH9XlqUfnC6Kgg6kyGHeXONLLpzwq2qJKminnuxqgtiviOebbxMNssYG6cYycPcxUkgdlgqjcbb5eJLspKjO3LRIXW(4RArdNoPHHUcgyirSZqMGIVIVcwixXMISHgjzqAAOUGmMqQWssYArdNoPHHUcgyirmjPoPHSHgjzqAAOUGmMqQqqjsbugKMgkFYSCaXkeuIGGglzwHe44OeGsCQp(fbaccYjglLEitqVlxfJH9XpqwqaqxIGTWuifp7eMuzqAA4Y40cDmY3y3KeeuIu6Hmb9UCvmg2hFHFaArBrdNoPHHyfjSYrXZftivKn0iPXHnfIvokEU0PdelfqjlJ4s2vGEHyLJINlMqQsLbPPHyLJINlD6aXWLRIXW(isbbzqAAiw5O45sNoqmSKKmaKcOminnCzCAHog5BSBscwssMGa1UebBHPqkE2jmaArdNoPHHyfyirmkZ5CXesTfnC6KggIvGHeXkjO8HVAibzdnsa6seSfMcP4zNWKcOlZtjjzWLXPf6yKVXUjj4YvXyyFi7kaiiqTlrWwykKINDctk1UebBHPqBitqV0bli4seSfMcTHmb9shSuaDzEkjjdsAoLlwYSJIHlxfJH9HSRii4Y8ussgK0CkxSKzhfdxUkgdlgqjcaeeOhYe07YvXyyF8ksaKci1BmLlJGnfgLcgYeFWkwqyJPCzeSPWOuWqqjsbCJPCzeSPWOuWWX8XRiKUXuUmc2uyuky4YvXyyFakbHnMYLrWMcJsbdhtmxMNssYeecNoi4lBC1WyX8cGGa1BmLlJGnfgLcgckrkGBmLlJGnfgLcg6sqtrYRGWgt5YiytHrPGHJjMlZtjjzaaqlA40jnmeRadjIrFILr2qJKg7v3qceuI0f0y6CjZqCcEOZLmF5kzEXTOHtN0WqScmKiMg7v3qcYgAKwqJPZLmdXj4HoxY8LRK5flvJ9QBibUCvmg2hYUIuxMNssYG0Nyz4YvXyyFi7kTOHtN0WqScmKigtCjNepi4lMqQTOHtN0WqScmKigP5uUyjZokgzdnsa6Y8ussguxqgtiv4YvXyyFi7kccYG00qDbzmHuHGsaqkGuVXuUmc2uyukyit8bRybbQ3ykxgbBkmkfmeuI0nMYLrWMcJsbdlGBOtAaBJPCzeSPWOuWWX8XViee2ykxgbBkmkfmeuI0nMYLrWMcJsbdxUkgdlMxFLGq40bbFzJRgglMxaeeOhYe07YvXyyFeperlA40jnmeRadjIrFcpC5IjKAlA40jnmeRadjIv4qjCDeckBuHSHgj60bIbMlW6DzYS5dD6aXWQG4TOHtN0WqScmKiwCRa3cV3K(62KeUfnC6KggIvGHeXifZzmY3y3KeYgAKCzEkjjdUmoTqhJ8n2njbxUkgd7dzxrkGuRXHnfYexYjXdc(IjKQGGminnu(Kz5aIviOeaeeO2LiylmfsXZoHji4Y8ussgCzCAHog5BSBscUCvmgwqqoXyP0dzc6D5QymSpISfnC6KggIvGHeXwgNwOJr(g7MKq2qJeGYG00WsckF4RgsGGseeOwJdBkSKGYh(QHebb6Hmb9UCvmg2hV(bqkGuVXuUmc2uyukyit8bRybbQ3ykxgbBkmkfmeuIua3ykxgbBkmkfmSaUHoPbSnMYLrWMcJsbdhZhVIqqyJPCzeSPWOuWqxcAksEbqqyJPCzeSPWOuWqqjs3ykxgbBkmkfmC5QymSy(kbHWPdc(YgxnmwmVa0IgoDsddXkWqIyiYZH9GSHgjzqAA4Y40cDmY3y3KeeuIGa1UebBHPqkE2jmPakdstdLSSBW8ftivmSKKmbbQ14WMcDeMQG34IjKQGq40bbFzJRgg7JFaArdNoPHHyfyirmSYrXZftivKn0i5seSfMcP4zNWKsNoqmWCbwVltMnFOthigwfexkGa6Y8ussgCzCAHog5BSBscUCvmg2hYUcviGskGuJtWJ8yfittdIhe8nSPkUHZXhEdnxbbQ14WMcljO8HVAibaaee04WMcljO8HVAirQlZtjjzWsckF4RgsGlxfJH9bOaOfnC6KggIvGHeX2qYuU0ZYiBOrAbnMoxYmedUKhJ8ftivSunoSPqSUCuDgJLcOlZtjjzWLXPf6yKVXUjj4YvXyyX8kcbbQDjc2ctHu8StyccuRXHnfwsq5dF1qIGaobpYJvGmnniEqW3WMQ4gohF4n0CbOfnC6KggIvGHeX0fKXesfzdnsacOminnuYYUbZxmHuXWssYee04WMcDX5mg5RsGVycPIbqQlrWwykebBkbpRGGlrWwyk0y3MNClccUmpLKKbxgNwOJr(g7MKGlxfJHfdOeHGGlZtjjzWLXPf6yKVXUjj4YvXyyF8kcbbxMNssYGKMt5ILm7Oy4YvXyyXakriiidstdjnNYflz2rXqqjaiiidstdrKNd7bckrA40bbFzJRgglMxbb5eJLspKjO3LRIXW(4xKTOHtN0WqScmKiwmvC5IjKkYCECh(QXsMvmsEr2qJKminnuYYUbZxmHuXWssYeeaugKMgQliJjKkeuIGan45Cx2riwY8vNk2hYUcWCbwV6uXaifqQ14WMcDeMQG34IjKQGq40bbFzJRgg7JFaeeKbPPH6ookxmHuXWLRIXWIXeNDGkF1PILgoDqWx24QHXI5TfnC6KggIvGHeX2qYuU0ZYiBOrcqxMNssYGlJtl0XiFJDtsWLRIXWI5veccu7seSfMcP4zNWeeOwJdBkSKGYh(QHebbCcEKhRazAAq8GGVHnvXnCo(WBO5cGu60bIbMlW6DzYS5dD6aXWQG4sbugKMgwsq5dF1qcSKKmPYG00qoiFynoPHV6cYx60bIHLKKjiOXHnfI1LJQZymaTOHtN0WqScmKiMJWuf8gxmHur2qJKminnuYYUbZxmHuXqqjcc0PdelMlXkWcNoPbJPIlxmHuHUeRTOHtN0WqScmKiwSUW4lMqQiBOrsgKMgkzz3G5lMqQyiOebb60bIfZLyfyHtN0GXuXLlMqQqxI1w0WPtAyiwbgsedZRe20lwhJmYCECh(QXsMvmsEr2qJ0Y0lJjeYhwQglzwH6uXxnVLHfRaUHoP1IgoDsddXkWqIyYXUbzgzdnsHthe8LnUAySyEBrdNoPHHyfyirSnKmLl9SmYgAKa0L5PKKm4Y40cDmY3y3KeC5QymSyEfH0f0y6CjZqm4sEmYxmHuXccu7seSfMcP4zNWeeOwJdBkSKGYh(QHebbCcEKhRazAAq8GGVHnvXnCo(WBO5cGu60bIbMlW6DzYS5dD6aXWQG4sbugKMgwsq5dF1qcSKKmbbnoSPqSUCuDgJbOfnC6KggIvGHeXKdY3K(Q74OGr2qJKminnuxqgtivyjjzTOHtN0WqScmKig9HXeCBqRiBOrcNGh5XkqjGyf8WxEbLOtAsLbPPH6cYycPcljjRfnC6KggIvGHeXWkhfpxmHuBrBrdNoPHH6ookycPIrcRCu8CXesfzdnsACytHyLJINlD6aXsh7sFgYeuPYG00qSYrXZLoDGy4YvXyyFezlA40jnmu3XrbtivmWqIyuMZ5IjKkYgAKwqJPZLmdLKGoc3K(UbqAUx6nixXMILkdstdPpHhEX3QyPabL0IgoDsdd1DCuWesfdmKig9j8WLlMqQiBOrAbnMoxYmusc6iCt67gaP5EP3GCfBkUfnC6KggQ74OGjKkgyirSsckF4Rgsq2qJeGUebBHPqkE2jmPUmpLKKbxgNwOJr(g7MKGlxfJH9HSRiiqTlrWwykKINDctk1UebBHPqBitqV0bli4seSfMcTHmb9shSuaDzEkjjdsAoLlwYSJIHlxfJH9HSRii4Y8ussgK0CkxSKzhfdxUkgdlgqjcaee0yjZkuNk(Q5TmSpEfHGGlZtjjzWLXPf6yKVXUjj4YvXyyX8kcPHthe8LnUAySyafasbK6nMYLrWMcJsbdzIpyfliSXuUmc2uyuky4YvXyyX8vccu7seSfMcP4zNWaOfnC6KggQ74OGjKkgyirmn2RUHeKn0iTGgtNlzgItWdDUK5lxjZlwQg7v3qcC5QymSpKDfPUmpLKKbPpXYWLRIXW(q2vArdNoPHH6ookycPIbgseJ(elJSZy81vqYVir2qJKg7v3qceuI0f0y6CjZqCcEOZLmF5kzEXTOHtN0WqDhhfmHuXadjIXexYjXdc(IjKAlA40jnmu3XrbtivmWqIyKMt5ILm7OyKn0ir9gt5YiytHrPGHmXhSIfe2ykxgbBkmkfmC5QymSyEfHGq40bbFzJRgglgsBmLlJGnfgLcg6sqtPc5VfnC6KggQ74OGjKkgyirmsXCgJ8n2njHSHgjxMNssYGlJtl0XiFJDtsWLRIXW(q2vKci1ACytHmXLCs8GGVycPkiidstdLpzwoGyfckbabbQDjc2ctHu8StyccUmpLKKbxgNwOJr(g7MKGlxfJHfZRieeKtmwk9qMGExUkgd7JiBrdNoPHH6ookycPIbgseBzCAHog5BSBsczdnsa6Y8ussgerEoSh4YvXyyFi7kccuRXHnfIiph2JGGglzwH6uXxnVLH9XRFaKci1BmLlJGnfgLcgYeFWkwqyJPCzeSPWOuWWLRIXWI5ReecNoi4lBC1WyXqAJPCzeSPWOuWqxcAkvi)a0IgoDsdd1DCuWesfdmKigI8CypiBOrsgKMgUmoTqhJ8n2njbbLiiqTlrWwykKINDcRfnC6KggQ74OGjKkgyirm5y3Gm3IgoDsdd1DCuWesfdmKiMUGmMqQiBOrsgKMgUmoTqhJ8n2njbbLii4Y8ussgCzCAHog5BSBscUCvmgwmVIqqGAxIGTWuifp7eMGGCIXsPhYe07YvXyyF8lIw0WPtAyOUJJcMqQyGHeX2qYuU0ZYiBOrAbnMoxYmedUKhJ8ftivSuaDzEkjjdUmoTqhJ8n2njbxUkgdlMxriiqTlrWwykKINDctqGAnoSPWsckF4RgsaqQminnu3Xr5IjKkgUCvmgwmKyIZoqLV6uXTOHtN0WqDhhfmHuXadjIftfxUycPImNh3HVASKzfJKxKn0ijdstd1DCuUycPIHlxfJHfdjM4Sdu5RovSuaLbPPHsw2ny(IjKkgwssMGan45Cx2riwY8vNk2hxG1RovmWi7kccYG00qDbzmHuHGsaOfnC6KggQ74OGjKkgyirSchkHRJqqzJkKn0irNoqmWCbwVltMnFOthigwfeVfnC6KggQ74OGjKkgyirSnKmLl9SmYgAKa0L5PKKm4Y40cDmY3y3KeC5QymSyEfH0f0y6CjZqm4sEmYxmHuXccu7seSfMcP4zNWeeOEbnMoxYmedUKhJ8ftivSGa1ACytHLeu(WxnKaGuzqAAOUJJYftivmC5QymSyiXeNDGkF1PIBrdNoPHH6ookycPIbgseRc8OdMqQiBOrsgKMgQ74OCXesfdljjtqqgKMgkzz3G5lMqQyiOeP0PdelMlXkWcNoPbJPIlxmHuHUeRsbKAnoSPqhHPk4nUycPkieoDqWx24QHXIbua0IgoDsdd1DCuWesfdmKiMJWuf8gxmHur2qJKminnuYYUbZxmHuXqqjsPthiwmxIvGfoDsdgtfxUycPcDjwLgoDqWx24QHX(iEBrdNoPHH6ookycPIbgseJYCoxmHur2qJKminnSWr5YEyyjjzTOHtN0WqDhhfmHuXadjIf3kWTW7nPVUnjHBrdNoPHH6ookycPIbgseJ(eE4Yfti1w0WPtAyOUJJcMqQyGHeXW8kHn9I1XiJmNh3HVASKzfJKxKn0iTm9YycH8HBrdNoPHH6ookycPIbgseRc8OdMqQiBOrIoDGyXCjwbw40jnymvC5IjKk0LyvkGUmpLKKbxgNwOJr(g7MKGlxfJHftKccu7seSfMcP4zNWaOfnC6KggQ74OGjKkgyirmn2RUHeKn0iTGgtNlzgAmgpgzsX6bF1nKizmY3qIKydfe3IgoDsdd1DCuWesfdmKig9Ymq6yKV6gsq2qJ0cAmDUKzOXy8yKjfRh8v3qIKXiFdjsInuqClA40jnmu3XrbtivmWqIyYb5BsF1DCuWiBOrsgKMgQliJjKkSKKSw0WPtAyOUJJcMqQyGHeXOpmMGBdAfzdns4e8ipwbkbeRGh(YlOeDstQminnuxqgtivyjjzTOHtN0WqDhhfmHuXadjIHvokEUycP2I2IgoDsdd1DmkSIrcrStiFyKzrfJe2J5UGsqgI4aYijdstdxgNwOJr(g7MKGGseeKbPPH6cYycPcbL0IgoDsdd1DmkSIbgsedrStiFyKzrfJew30iFXEm3fucYqehqgjxIGTWuifp7eMuzqAA4Y40cDmY3y3KeeuIuzqAAOUGmMqQqqjccu7seSfMcP4zNWKkdstd1fKXesfckPfnC6KggQ7yuyfdmKigIyNq(WiZIkgjSUPr(I9yU7YvXyyKLsqcZ6qJmeXbKrYL5PKKm4Y40cDmY3y3KeC5QymSp(ACzEkjjdQliJjKkC5QymmYqehq(YhmJKlZtjjzqDbzmHuHlxfJHr2qJKminnuxqgtivyjjzsDjc2ctHu8StyTOHtN0WqDhJcRyGHeXqe7eYhgzwuXiH1nnYxShZDxUkgdJSucsywhAKHioGmsUmpLKKbxgNwOJr(g7MKGlxfJHrgI4aYx(GzKCzEkjjdQliJjKkC5QymmYgAKKbPPH6cYycPcbLi1LiylmfsXZoH1IgoDsdd1DmkSIbgsedrStiFyKzrfJe2J5UlxfJHrwkbjmRdnYgAKCjc2ctHu8StyidrCazKCzEkjjdUmoTqhJ8n2njbxUkgdlMVgxMNssYG6cYycPcxUkgdJmeXbKV8bZi5Y8ussguxqgtiv4YvXy4w0WPtAyOUJrHvmWqIyGy(okxHrg(KkgjDhJcREr2qJeGaQ7yuyf6fsiWxqmFLbPPfeCjc2ctHu8Stys1DmkSc9cje4RlZtjjzaifqeXoH8HHyDtJ8f7XCxqjsbKAxIGTWuifp7eMuQ1DmkSc9dje4liMVYG00ccUebBHPqkE2jmPuR7yuyf6hsiWxxMNssYee0DmkSc9dDzEkjjdUCvmgwqq3XOWk0lKqGVGy(kdstlfqQ1DmkSc9dje4liMVYG00cc6ogfwHEHUmpLKKblGBOtAIHKUJrHvOFOlZtjjzWc4g6Kgacc6ogfwHEHec81L5PKKmPuR7yuyf6hsiWxqmFLbPPLQ7yuyf6f6Y8ussgSaUHoPjgs6ogfwH(HUmpLKKblGBOtAaiiqnIyNq(WqSUPr(I9yUlOePasTUJrHvOFiHaFbX8vgKMwkG6ogfwHEHUmpLKKblGBOtAuPi9brStiFyi2J5UlxfJHfeqe7eYhgI9yU7YvXyyX0DmkSc9cDzEkjjdwa3qN0Oc8dGGGUJrHvOFiHaFbX8vgKMwkG6ogfwHEHec8feZxzqAAP6ogfwHEHUmpLKKblGBOtAIHKUJrHvOFOlZtjjzWc4g6KMua1DmkSc9cDzEkjjdwa3qN0Osr6dIyNq(WqShZDxUkgdliGi2jKpme7XC3LRIXWIP7yuyf6f6Y8ussgSaUHoPrf4habbaPw3XOWk0lKqGVGy(kdstliO7yuyf6h6Y8ussgSaUHoPjgs6ogfwHEHUmpLKKblGBOtAaifqDhJcRq)qxMNssYGlhfps1DmkSc9dDzEkjjdwa3qN0OsrkgIyNq(WqShZDxUkgdlfrStiFyi2J5UlxfJH9r3XOWk0p0L5PKKmybCdDsJkWVGa16ogfwH(HUmpLKKbxokEKcOUJrHvOFOlZtjjzWLRIXWuPi9brStiFyiw30iFXEm3D5QymSueXoH8HHyDtJ8f7XC3LRIXWI5xesbu3XOWk0l0L5PKKmybCdDsJkfPpiIDc5ddXEm3D5QymSGGUJrHvOFOlZtjjzWLRIXWuPi9brStiFyi2J5UlxfJHLQ7yuyf6h6Y8ussgSaUHoPrLEfbWqe7eYhgI9yU7YvXyyFqe7eYhgI1nnYxShZDxUkgdliGi2jKpme7XC3LRIXWIP7yuyf6f6Y8ussgSaUHoPrf4xqarStiFyi2J5UGsaqqq3XOWk0p0L5PKKm4YvXyyQuKIHi2jKpmeRBAKVypM7UCvmgwkG6ogfwHEHUmpLKKblGBOtAuPi9brStiFyiw30iFXEm3D5QymSGa16ogfwHEHec8feZxzqAAPaIi2jKpme7XC3LRIXWIP7yuyf6f6Y8ussgSaUHoPrf4xqarStiFyi2J5UGsaaaaaaaaee0yjZkuNk(Q5TmSpiIDc5ddXEm3D5QymmaccuR7yuyf6fsiWxqmFLbPPLsTlrWwykKINDctkG6ogfwH(Hec8feZxzqAAPaci1iIDc5ddXEm3fuIGGUJrHvOFOlZtjjzWLRIXWIjsaKciIyNq(WqShZDxUkgdlMFriiO7yuyf6h6Y8ussgC5QymmvksXqe7eYhgI9yU7YvXyyaaqqGADhJcRq)qcb(cI5RminTuaPw3XOWk0pKqGVUmpLKKjiO7yuyf6h6Y8ussgC5QymSGGUJrHvOFOlZtjjzWc4g6KMyiP7yuyf6f6Y8ussgSaUHoPbaaaifqQ1DmkSc9chm0foc8nPVHJkcolxU6YbgCzSGq40bbFzJRgg7JFPuldstddhveCwUCjfwbckrqiC6GGVSXvdJfZRuzqAAy4OIGZYLBqCgckbGw0WPtAyOUJrHvmWqIyGy(okxHrg(KkgjDhJcR(r2qJeGaQ7yuyf6hsiWxqmFLbPPfeCjc2ctHu8Stys1DmkSc9dje4RlZtjjzaifqeXoH8HHyDtJ8f7XCxqjsbKAxIGTWuifp7eMuQ1DmkSc9cje4liMVYG00ccUebBHPqkE2jmPuR7yuyf6fsiWxxMNssYee0DmkSc9cDzEkjjdUCvmgwqq3XOWk0pKqGVGy(kdstlfqQ1DmkSc9cje4liMVYG00cc6ogfwH(HUmpLKKblGBOtAIHKUJrHvOxOlZtjjzWc4g6Kgacc6ogfwH(Hec81L5PKKmPuR7yuyf6fsiWxqmFLbPPLQ7yuyf6h6Y8ussgSaUHoPjgs6ogfwHEHUmpLKKblGBOtAaiiqnIyNq(WqSUPr(I9yUlOePasTUJrHvOxiHaFbX8vgKMwkG6ogfwH(HUmpLKKblGBOtAuPi9brStiFyi2J5UlxfJHfeqe7eYhgI9yU7YvXyyX0DmkSc9dDzEkjjdwa3qN0Oc8dGGGUJrHvOxiHaFbX8vgKMwkG6ogfwH(Hec8feZxzqAAP6ogfwH(HUmpLKKblGBOtAIHKUJrHvOxOlZtjjzWc4g6KMua1DmkSc9dDzEkjjdwa3qN0Osr6dIyNq(WqShZDxUkgdliGi2jKpme7XC3LRIXWIP7yuyf6h6Y8ussgSaUHoPrf4habbaPw3XOWk0pKqGVGy(kdstliO7yuyf6f6Y8ussgSaUHoPjgs6ogfwH(HUmpLKKblGBOtAaifqDhJcRqVqxMNssYGlhfps1DmkSc9cDzEkjjdwa3qN0OsrkgIyNq(WqShZDxUkgdlfrStiFyi2J5UlxfJH9r3XOWk0l0L5PKKmybCdDsJkWVGa16ogfwHEHUmpLKKbxokEKcOUJrHvOxOlZtjjzWLRIXWuPi9brStiFyiw30iFXEm3D5QymSueXoH8HHyDtJ8f7XC3LRIXWI5xesbu3XOWk0p0L5PKKmybCdDsJkfPpiIDc5ddXEm3D5QymSGGUJrHvOxOlZtjjzWLRIXWuPi9brStiFyi2J5UlxfJHLQ7yuyf6f6Y8ussgSaUHoPrLEfbWqe7eYhgI9yU7YvXyyFqe7eYhgI1nnYxShZDxUkgdliGi2jKpme7XC3LRIXWIP7yuyf6h6Y8ussgSaUHoPrf4xqarStiFyi2J5UGsaqqq3XOWk0l0L5PKKm4YvXyyQuKIHi2jKpmeRBAKVypM7UCvmgwkG6ogfwH(HUmpLKKblGBOtAuPi9brStiFyiw30iFXEm3D5QymSGa16ogfwH(Hec8feZxzqAAPaIi2jKpme7XC3LRIXWIP7yuyf6h6Y8ussgSaUHoPrf4xqarStiFyi2J5UGsaaaaaaaaee0yjZkuNk(Q5TmSpiIDc5ddXEm3D5QymmaccuR7yuyf6hsiWxqmFLbPPLsTlrWwykKINDctkG6ogfwHEHec8feZxzqAAPaci1iIDc5ddXEm3fuIGGUJrHvOxOlZtjjzWLRIXWIjsaKciIyNq(WqShZDxUkgdlMFriiO7yuyf6f6Y8ussgC5QymmvksXqe7eYhgI9yU7YvXyyaaqqGADhJcRqVqcb(cI5RminTuaPw3XOWk0lKqGVUmpLKKjiO7yuyf6f6Y8ussgC5QymSGGUJrHvOxOlZtjjzWc4g6KMyiP7yuyf6h6Y8ussgSaUHoPbaaaifqQ1DmkSc9dhm0foc8nPVHJkcolxU6YbgCzSGq40bbFzJRgg7JFPuldstddhveCwUCjfwbckrqiC6GGVSXvdJfZRuzqAAy4OIGZYLBqCgckbaufvrrb]] )


end