-- HunterSurvival.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Shadowlands Legendaries
-- [x] Wildfire Cluster
-- [-] Rylakstalker's Confounding Strikes (passive/reactive)
-- [x] Latent Poison Injectors
-- [x] Butcher's Bone Fragments

-- Conduits
-- [x] Deadly Tandem
-- [x] Flame Infusion
-- [-] Stinging Strike
-- [-] Strength of the Pack


if UnitClassBase( "player" ) == "HUNTER" then
    local spec = Hekili:NewSpecialization( 255 )

    spec:RegisterResource( Enum.PowerType.Focus, {
        terms_of_engagement = {
            aura = "terms_of_engagement",

            last = function ()
                local app = state.buff.terms_of_engagement.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 2,
        },

        death_chakram = {
            resource = "focus",
            aura = "death_chakram",

            last = function ()
                return state.buff.death_chakram.applied + floor( ( state.query_time - state.buff.death_chakram.applied ) / class.auras.death_chakram.tick_time ) * class.auras.death_chakram.tick_time
            end,

            interval = function () return class.auras.death_chakram.tick_time end,
            value = function () return state.conduit.necrotic_barrage.enabled and 5 or 3 end,
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        vipers_venom = 22275, -- 268501
        terms_of_engagement = 22283, -- 265895
        alpha_predator = 22296, -- 269737

        guerrilla_tactics = 21997, -- 264332
        hydras_bite = 22769, -- 260241
        butchery = 22297, -- 212436

        trailblazer = 19347, -- 199921
        natural_mending = 19348, -- 270581
        camouflage = 23100, -- 199483

        bloodseeker = 22277, -- 260248
        steel_trap = 19361, -- 162488
        a_murder_of_crows = 22299, -- 131894

        born_to_be_wild = 22268, -- 266921
        posthaste = 22276, -- 109215
        binding_shot = 22499, -- 109248

        tip_of_the_spear = 22300, -- 260285
        mongoose_bite = 22278, -- 259387
        flanking_strike = 22271, -- 269751

        birds_of_prey = 22272, -- 260331
        wildfire_infusion = 22301, -- 271014
        chakrams = 23105, -- 259391
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {
        chimaeral_sting = 3609, -- 356719
        diamond_ice = 686, -- 203340
        dragonscale_armor = 3610, -- 202589
        hiexplosive_trap = 3606, -- 236776
        hunting_pack = 661, -- 203235
        mending_bandage = 662, -- 212640
        roar_of_sacrifice = 663, -- 53480
        sticky_tar = 664, -- 203264
        survival_tactics = 3607, -- 202746
        trackers_net = 665, -- 212638
        tranquilizing_darts = 5420, -- 356015
        wild_kingdom = 5443, -- 356707
    } )

    -- Auras
    spec:RegisterAuras( {
        a_murder_of_crows = {
            id = 131894,
            duration = 15,
            max_stack = 1,
        },
        aspect_of_the_eagle = {
            id = 186289,
            duration = 15,
            max_stack = 1,
        },
        aspect_of_the_turtle = {
            id = 186265,
            duration = 8,
            max_stack = 1,
        },
        binding_shot = {
            id = 117405,
            duration = 3600,
            max_stack = 1,
        },
        camouflage = {
            id = 199483,
            duration = 60,
            max_stack = 1,
        },
        coordinated_assault = {
            id = 266779,
            duration = function () return 20 + ( conduit.deadly_tandem.mod * 0.001 ) end,
            max_stack = 1,
        },
        eagle_eye = {
            id = 6197,
        },
        feign_death = {
            id = 5384,
            duration = 360,
            max_stack = 1,
        },
        freezing_trap = {
            id = 3355,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        growl = {
            id = 2649,
            duration = 3,
            max_stack = 1,
        },
        harpoon = {
            id = 190927,
            duration = 3,
            max_stack = 1,
        },
        hunters_mark = {
            id = 257284,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
        },
        internal_bleeding = {
            id = 270343,
            duration = 9,
            max_stack = 3
        },
        intimidation = {
            id = 24394,
            duration = 5,
            max_stack = 1,
        },
        kill_command = {
            id = 259277,
            duration = 8,
            max_stack = 1,
            copy = "bloodseeker"
        },
        masters_call = {
            id = 54216,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },
        misdirection = {
            id = 35079,
            duration = 8,
            max_stack = 1,
        },
        mongoose_fury = {
            id = 259388,
            duration = 14,
            max_stack = 5,
        },
        pathfinding = {
            id = 264656,
            duration = 3600,
            max_stack = 1,
        },
        pheromone_bomb = {
            id = 270332,
            duration = 6,
            max_stack = 1,
        },
        posthaste = {
            id = 118922,
            duration = 4,
            max_stack = 1,
        },
        predator = {
            id = 260249,
            duratinon = 3600,
            max_stack = 10,
        },
        serpent_sting = {
            id = 259491,
            duration = function () return 12 * haste end,
            tick_time = function () return 3 * haste end,
            type = "Poison",
            max_stack = 1,
        },
        shrapnel_bomb = {
            id = 270339,
            duration = 6,
            max_stack = 1,
        },
        steel_trap = {
            id = 162487,
            duration = 20,
            max_stack = 1,
        },
        steel_trap_immobilize = {
            id = 162480,
            duration = 20,
            max_stack = 1,
        },
        tar_trap = {
            id = 135299,
            duration = 3600,
            max_stack = 1,
        },
        terms_of_engagement = {
            id = 265898,
            duration = 10,
            max_stack = 1,
        },
        tip_of_the_spear = {
            id = 260286,
            duration = 10,
            max_stack = 3,
        },
        trailblazer = {
            id = 231390,
            duration = 3600,
            max_stack = 1,
        },
        vipers_venom = {
            id = 268552,
            duration = 8,
            max_stack = 1,
        },
        volatile_bomb = {
            id = 271049,
            duration = 6,
            max_stack = 1,
        },
        wildfire_bomb_dot = {
            id = 269747,
            duration = 6,
            max_stack = 1,
        },
        wildfire_bomb = {
            alias = { "wildfire_bomb_dot", "shrapnel_bomb", "pheromone_bomb", "volatile_bomb" },
            aliasType = "debuff",
            aliasMode = "longest"
        },
        wing_clip = {
            id = 195645,
            duration = 15,
            max_stack = 1,
        },

        -- AZERITE POWERS
        blur_of_talons = {
            id = 277969,
            duration = 6,
            max_stack = 5,
        },

        latent_poison = {
            id = 273286,
            duration = 20,
            max_stack = 10
        },

        primeval_intuition = {
            id = 288573,
            duration = 12,
            max_stack = 5,
        },

        -- Legendaries
        latent_poison_injection = {
            id = 336903,
            duration = 15,
            max_stack = 10
        },

        nessingwarys_trapping_apparatus = {
            id = 336744,
            duration = 5,
            max_stack = 1,
            copy = { "nesingwarys_trapping_apparatus", "nesingwarys_apparatus", "nessingwarys_apparatus" }
        },

        -- Conduits
        strength_of_the_pack = {
            id = 341223,
            duration = 4,
            max_stack = 1
        }
    } )


    spec:RegisterHook( "runHandler", function( action, pool )
        if buff.camouflage.up and action ~= "camouflage" then removeBuff( "camouflage" ) end
        if buff.feign_death.up and action ~= "feign_death" then removeBuff( "feign_death" ) end
    end )


    spec:RegisterStateExpr( "current_wildfire_bomb", function () return "wildfire_bomb" end )

    spec:RegisterStateExpr( "check_focus_overcap", function ()
        if settings.allow_focus_overcap then return true end
        if not this_action then return focus.current + focus.regen * gcd.max <= focus.max end
        return focus.current + cast_regen <= focus.max
    end )


    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID
    end

    state.IsActiveSpell = IsActiveSpell


    local pheromoneReset = 0
    local FindUnitDebuffByID = ns.FindUnitDebuffByID

    local madBombardierSpent = 0
    local bombImpactIds = {
        [270329] = true, -- Pheromone Bomb
        [270338] = true, -- Shrapnel Bomb
        [271048] = true, -- Volatile Bomb
        [265157] = true, -- Wildfire Bomb
    }

    spec:RegisterCombatLogEvent( function ( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        -- Reset Kill Command after
        if sourceGUID == state.GUID then
            if spellID == 259489 and subtype == "SPELL_CAST_SUCCESS" then
                pheromoneReset = FindUnitDebuffByID( "target", 270332 ) and GetTime() or 0
            elseif bombImpactIds[ spellID ] and state.set_bonus.tier28 > 1 and subtype == "SPELL_DAMAGE" then
                -- Mad Bombardier doesn't get removed until even after it impacts the target, but we want to know it should've been consumed.
                madBombardierSpent = GetPlayerAuraBySpellID( 363805 ) and GetTime() or 0
            end
        end
    end )


    local ExpireNesingwarysTrappingApparatus = setfenv( function()
        focus.regen = focus.regen * 0.5
        forecastResources( "focus" )
    end, state )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364490, "tier28_4pc", 363667 )
    -- 2-Set - Mad Bombardier - When Kill Command resets, it has a 40% chance to make your next Wildfire Bomb incur no cooldown.
    -- 4-Set - Mad Bombardier - Your Wildfire Bombs deal 30% additional damage. This bonus is increased to 80% for bombs empowered by Mad Bombardier.
    spec:RegisterAura( "mad_bombardier", {
        id = 363805,
        duration = 20,
        max_stack = 1,
    } )


    -- Create a flag that WfB's CD should reset based on the set bonus, so we can remove the buff to help the addon's priority logic.
    spec:RegisterStateExpr( "will_reset_wildfire_bomb", function ()
        return buff.mad_bombardier.up
    end )


    spec:RegisterHook( "reset_precast", function()
        if talent.wildfire_infusion.enabled then
            if IsActiveSpell( 270335 ) then current_wildfire_bomb = "shrapnel_bomb"
            elseif IsActiveSpell( 270323 ) then current_wildfire_bomb = "pheromone_bomb"
            elseif IsActiveSpell( 271045 ) then current_wildfire_bomb = "volatile_bomb"
            else current_wildfire_bomb = "wildfire_bomb" end
        else
            current_wildfire_bomb = "wildfire_bomb"
        end

        if now - pheromoneReset < 0.3 then
            setCooldown( "kill_command", 0 )
        end

        will_reset_wildfire_bomb = nil

        -- If an actual WfB has cast but not landed, remove the buff but flag WfB to reset upon impact.
        if buff.mad_bombardier.up then
            -- Remove if we just had a bomb impact but the buff didn't wipe yet.
            if now - madBombardierSpent < 0.3 then
                removeBuff( "mad_bombardier" )
            -- Remove if we have a bomb in flight that will consume it, but flag will_reset_wildfire_bomb so the impact event knows what to do.
            elseif ( action.wildfire_bomb.in_flight or action.shrapnel_bomb.in_flight or action.pheromone_bomb.in_flight or action.volatile_bomb.in_flight ) then
                removeBuff( "mad_bombardier" )
                will_reset_wildfire_bomb = true
            end
        end

        if now - action.harpoon.lastCast < 1.5 then
            setDistance( 5 )
        end

        if debuff.tar_trap.up then
            debuff.tar_trap.expires = debuff.tar_trap.applied + 30
        end

        if buff.nesingwarys_apparatus.up then
            state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireNesingwarysTrappingApparatus, buff.nesingwarys_apparatus.expires )
        end

        if now - action.resonating_arrow.lastCast < 6 then applyBuff( "resonating_arrow", 10 - ( now - action.resonating_arrow.lastCast ) ) end
    end )

    spec:RegisterHook( "specializationChanged", function ()
        current_wildfire_bomb = nil
    end )

    spec:RegisterStateTable( "next_wi_bomb", setmetatable( {}, {
        __index = function( t, k )
            if k == "shrapnel" then return current_wildfire_bomb == "shrapnel_bomb"
            elseif k == "pheromone" then return current_wildfire_bomb == "pheromone_bomb"
            elseif k == "volatile" then return current_wildfire_bomb == "volatile_bomb" end
            return false
        end
    } ) )

    spec:RegisterStateTable( "bloodseeker", setmetatable( {}, {
        __index = function( t, k )
            if k == "count" then
                return active_dot.kill_command
            end

            return debuff.kill_command[ k ]
        end,
    } ) )


    spec:RegisterStateExpr( "bloodseeker", function () return debuff.bloodseeker end )


    -- Abilities
    spec:RegisterAbilities( {
        a_murder_of_crows = {
            id = 131894,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 30,
            spendType = "focus",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 645217,

            talent = "a_murder_of_crows",

            handler = function ()
                applyDebuff( "target", "a_murder_of_crows" )
            end,
        },


        aspect_of_the_cheetah = {
            id = 186257,
            cast = 0,
            cooldown = function () return ( 180 * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( talent.born_to_be_wild.enabled and 0.8 or 1 ) ) + ( conduit.cheetahs_vigor.mod * 0.001 ) end,
            gcd = "spell",

            startsCombat = false,
            texture = 132242,

            handler = function ()
                applyBuff( "aspect_of_the_cheetah_sprint" )
                applyBuff( "aspect_of_the_cheetah" )
            end,
        },


        aspect_of_the_eagle = {
            id = 186289,
            cast = 0,
            cooldown = function () return 90 * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( talent.born_to_be_wild.enabled and 0.8 or 1 ) end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 612363,

            handler = function ()
                applyBuff( "aspect_of_the_eagle" )
            end,
        },


        aspect_of_the_turtle = {
            id = 186265,
            cast = 0,
            cooldown = function () return ( 180 * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * ( talent.born_to_be_wild.enabled and 0.8 or 1 ) ) + ( conduit.harmony_of_the_tortollan.mod * 0.001 ) end,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 132199,

            handler = function ()
                applyBuff( "aspect_of_the_turtle" )
                setCooldown( "global_cooldown", 8 )
            end,
        },


        binding_shot = {
            id = 109248,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = false,
            texture = 462650,

            handler = function ()
                applyDebuff( "target", "binding_shot" )
            end,
        },


        butchery = {
            id = 212436,
            cast = 0,
            charges = 3,
            cooldown = 9,
            recharge = 9,
            hasteCD = true,
            gcd = "spell",

            spend = 30,
            spendType = "focus",

            startsCombat = true,
            texture = 999948,

            aura = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
            cycle = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,

            talent = "butchery",

            usable = function () return charges > 1 or active_enemies > 1 or target.time_to_die < ( 9 * haste ) end,
            handler = function ()
                gainChargeTime( "wildfire_bomb", min( 5, active_enemies ) )
                gainChargeTime( "shrapnel_bomb", min( 5, active_enemies ) )
                gainChargeTime( "volatile_bomb", min( 5, active_enemies ) )
                gainChargeTime( "pheromone_bomb", min( 5, active_enemies ) )

                if talent.birds_of_prey.enabled and buff.coordinated_assault.up and UnitIsUnit( "pettarget", "target" ) then
                    buff.coordinated_assault.expires = buff.coordinated_assault.expires + 1.5
                end

                if debuff.shrapnel_bomb.up then applyDebuff( "target", "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end

                removeBuff( "butchers_bone_fragments" )

                if conduit.flame_infusion.enabled then
                    addStack( "flame_infusion", nil, 1 )
                end
            end,
        },


        camouflage = {
            id = 199483,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            texture = 461113,

            talent = "camouflage",

            usable = function () return time == 0 end,
            handler = function ()
                applyBuff( "camouflage" )
            end,
        },


        carve = {
            id = 187708,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",

            spend = 35,
            spendType = "focus",

            startsCombat = true,
            texture = 1376039,

            -- aura = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
            -- cycle = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,

            notalent = "butchery",

            handler = function ()
                gainChargeTime( "wildfire_bomb", min( 5, active_enemies ) )
                gainChargeTime( "shrapnel_bomb", min( 5, active_enemies ) )
                gainChargeTime( "volatile_bomb", min( 5, active_enemies ) )
                gainChargeTime( "pheromone_bomb", min( 5, active_enemies ) )

                if debuff.shrapnel_bomb.up then applyDebuff( "target", "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end

                if talent.birds_of_prey.enabled and buff.coordinated_assault.up and UnitIsUnit( "pettarget", "target" ) then
                    buff.coordinated_assault.expires = buff.coordinated_assault.expires + 1.5
                end

                removeBuff( "butchers_bone_fragments" )

                if conduit.flame_infusion.enabled then
                    addStack( "flame_infusion", nil, 1 )
                end
            end,

            auras = {
                -- Conduit
                flame_infusion = {
                    id = 341401,
                    duration = 8,
                    max_stack = 2,
                }
            }
        },


        chakrams = {
            id = 259391,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = 15,
            spendType = "focus",

            startsCombat = true,
            texture = 648707,

            talent = "chakrams",

            handler = function ()
            end,
        },


        coordinated_assault = {
            id = 266779,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( legendary.call_of_the_wild.enabled and 0.75 or 1 ) * 120 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 2065565,

            nobuff = function ()
                if settings.ca_vop_overlap then return end
                return "coordinated_assault"
            end,

            usable = function () return pet.alive end,
            handler = function ()
                applyBuff( "coordinated_assault" )
            end,
        },


        disengage = {
            id = 781,
            cast = 0,
            cooldown = 20,
            gcd = "off",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                setDistance( 15 )
                if talent.posthaste.enabled then applyBuff( "posthaste" ) end
                if conduit.tactical_retreat.enabled and target.within8 then applyDebuff( "target", "tactical_retreat" ) end
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


        flanking_strike = {
            id = 269751,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = -30,
            spendType = "focus",

            startsCombat = true,
            texture = 236184,

            talent = "flanking_strike",

            usable = function () return pet.alive end,
        },


        --[[ flare = {
            id = 1543,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 135815,

            handler = function ()
                applyDebuff( "target", "flare" )
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

            startsCombat = false,
            texture = 135834,

            handler = function ()
                applyDebuff( "target", "freezing_trap" )
            end,
        },


        harpoon = {
            id = 190925,
            cast = 0,
            charges = 1,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            startsCombat = true,
            texture = 1376040,

            usable = function () return settings.use_harpoon and target.distance > 8, "harpoon disabled or target too close" end,
            handler = function ()
                applyDebuff( "target", "harpoon" )
                if talent.terms_of_engagement.enabled then applyBuff( "terms_of_engagement" ) end
                setDistance( 5 )
            end,
        },


        hunters_mark = {
            id = 257284,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 236188,

            handler = function ()
                applyDebuff( "target", "hunters_mark" )
            end,
        },


        intimidation = {
            id = 19577,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 132111,

            usable = function () return pet.alive, "requires a living pet" end,
            handler = function ()
                applyDebuff( "target", "intimidation" )
            end,
        },


        kill_command = {
            id = 259489,
            cast = 0,
            charges = function () return talent.alpha_predator.enabled and 2 or nil end,
            cooldown = 6,
            recharge = 6,
            hasteCD = true,
            gcd = "spell",

            spend = -15,
            spendType = "focus",

            startsCombat = true,
            texture = 132176,

            cycle = function () return talent.bloodseeker.enabled and "kill_command" or nil end,

            usable = function () return pet.alive, "requires a living pet" end,
            handler = function ()
                if talent.bloodseeker.enabled then
                    applyBuff( "predator", 8 )
                    applyDebuff( "target", "kill_command", 8 )
                end

                if talent.tip_of_the_spear.enabled then addStack( "tip_of_the_spear", 20, 1 ) end

                if debuff.pheromone_bomb.up then
                    gainCharges( "kill_command", 1 )
                end

                if debuff.shrapnel_bomb.up then applyDebuff( "target", "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end
            end,
        },


        kill_shot = {
            id = 320976,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = function () return buff.flayers_mark.up and 0 or 10 end,
            spendType = "focus",

            startsCombat = true,
            texture = 236174,

            usable = function () return buff.flayers_mark.up or target.health_pct < 20, "requires target health below 20 percent" end,
            handler = function ()
                if buff.flayers_mark.up and legendary.pouch_of_razor_fragments.enabled then
                    applyDebuff( "target", "pouch_of_razor_fragments" )
                    removeBuff( "flayers_mark" )
                end
            end,
        },


        masters_call = {
            id = 272682,
            cast = 0,
            cooldown = 45,
            gcd = "off",

            startsCombat = false,
            texture = 236189,

            usable = function () return pet.alive, "requires a living pet" end,
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

            usable = function () return pet.alive or group, "requires a living pet or ally" end,
            handler = function ()
                applyBuff( "misdirection" )
            end,
        },


        mongoose_bite = {
            id = 259387,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "focus",

            startsCombat = true,
            texture = 1376044,

            aura = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
            cycle = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,

            talent = "mongoose_bite",

            handler = function ()
                if buff.mongoose_fury.down then applyBuff( "mongoose_fury" )
                else applyBuff( "mongoose_fury", buff.mongoose_fury.remains, min( 5, buff.mongoose_fury.stack + 1 ) ) end
                if debuff.shrapnel_bomb.up then
                    if debuff.internal_bleeding.up then applyDebuff( "target", "internal_bleeding", 9, debuff.internal_bleeding.stack + 1 ) end
                end

                removeDebuff( "target", "latent_poison" )
                removeDebuff( "target", "latent_poison_injection" )

                if azerite.wilderness_survival.enabled then
                    gainChargeTime( "wildfire_bomb", 1 )
                    if talent.wildfire_infusion.enabled then
                        gainChargeTime( "shrapnel_bomb", 1 )
                        gainChargeTime( "pheromone_bomb", 1 )
                        gainChargeTime( "volatile_bomb", 1 )
                    end
                end

                if azerite.primeval_intuition.enabled then
                    addStack( "primeval_intuition", nil, 1 )
                end

                if azerite.blur_of_talons.enabled and buff.coordinated_assault.up then
                    addStack( "blur_of_talons", nil, 1)
                end

                if legendary.butchers_bone_fragments.enabled then
                    addStack( "butchers_bone_fragments", nil, 1 )
                end
            end,

            copy = { 265888, "mongoose_bite_eagle" }
        },


        muzzle = {
            id = 187707,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            startsCombat = true,
            texture = 1376045,

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


        pheromone_bomb = {
            id = 270323,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,

            gcd = "spell",

            startsCombat = true,

            bind = "wildfire_bomb",
            talent = "wildfire_infusion",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "pheromone_bomb" end,
            start = function ()
                removeBuff( "flame_infusion" )
                if buff.mad_bombardier.up then
                    will_reset_wildfire_bomb = true
                    removeBuff( "mad_bombardier" )
                end
            end,
            impact = function ()
                if will_reset_wildfire_bomb then
                    gainCharges( "wildfire_bomb", 1 )
                    will_reset_wildfire_bomb = nil
                    removeBuff( "mad_bombardier" )
                end
                applyDebuff( "target", "pheromone_bomb" )
            end,

            copy = 270329,

            unlisted = true,
        },


        raptor_strike = {
            id = 186270,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "focus",

            startsCombat = true,
            texture = 1376046,

            aura = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
            cycle = function () return debuff.shrapnel_bomb.up and "internal_bleeding" or nil end,
            indicator = function () return debuff.latent_poison_injection.down and active_dot.latent_poison_injection > 0 and "cycle" or nil end,

            notalent = "mongoose_bite",

            handler = function ()
                removeBuff( "tip_of_the_spear" )

                if debuff.shrapnel_bomb.up then
                    if debuff.internal_bleeding.up then applyDebuff( "target", "internal_bleeding", 9, debuff.internal_bleeding.stack + 1 ) end
                end

                if talent.birds_of_prey.enabled and buff.coordinated_assault.up and UnitIsUnit( "pettarget", "target" ) then
                    buff.coordinated_assault.expires = buff.coordinated_assault.expires + 1.5
                end

                removeDebuff( "target", "latent_poison" )
                removeDebuff( "target", "latent_poison_injection" )

                if azerite.wilderness_survival.enabled then
                    gainChargeTime( "wildfire_bomb", 1 )
                    if talent.wildfire_infusion.enabled then
                        gainChargeTime( "shrapnel_bomb", 1 )
                        gainChargeTime( "pheromone_bomb", 1 )
                        gainChargeTime( "volatile_bomb", 1 )
                    end
                end

                if azerite.primeval_intuition.enabled then
                    addStack( "primeval_intuition", nil, 1 )
                end

                if azerite.blur_of_talons.enabled and buff.coordinated_assault.up then
                    addStack( "blur_of_talons", nil, 1)
                end

                if legendary.butchers_bone_fragments.enabled then
                    addStack( "butchers_bone_fragments", nil, 1 )
                end
            end,

            copy = { "raptor_strike_eagle", 265189 },

            auras = {
                butchers_bone_fragments = {
                    id = 336908,
                    duration = 12,
                    max_stack = 6,
                },
            }
        },


        serpent_sting = {
            id = 259491,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.vipers_venom.up and 0 or 20 end,
            spendType = "focus",

            startsCombat = true,
            texture = 1033905,

            velocity = 60,

            start = function ()
                removeBuff( "vipers_venom" )
            end,

            impact = function ()
                applyDebuff( "target", "serpent_sting" )

                if azerite.latent_poison.enabled then
                    applyDebuff( "target", "latent_poison" )
                end

                if legendary.latent_poison_injectors.enabled then
                    applyDebuff( "target", "latent_poison_injection", nil, debuff.latent_poison_injection.stack + 1 )
                end
            end,
        },


        shrapnel_bomb = {
            id = 270335,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            bind = "wildfire_bomb",
            talent = "wildfire_infusion",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "shrapnel_bomb" end,
            start = function ()
                removeBuff( "flame_infusion" )
                if buff.mad_bombardier.up then
                    will_reset_wildfire_bomb = true
                    removeBuff( "mad_bombardier" )
                end
            end,
            impact = function ()
                if will_reset_wildfire_bomb then
                    gainCharges( "wildfire_bomb", 1 )
                    will_reset_wildfire_bomb = nil
                    removeBuff( "mad_bombardier" )
                end
                applyDebuff( "target", "shrapnel_bomb" )
            end,

            copy = 270338,

            unlisted = true,
        },


        steady_shot = {
            id = 56641,
            cast = 1.75,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132213,

            handler = function ()
            end,
        },


        steel_trap = {
            id = 162488,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function ()
                if legendary.nessingwarys_trapping_apparatus.enabled then
                    return -45, "focus"
                end
            end,

            startsCombat = false,
            texture = 1467588,

            handler = function ()
                applyDebuff( "target", "steel_trap" )
            end,
        },


        summon_pet = {
            id = 883,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "focus",

            startsCombat = false,
            texture = 'Interface\\ICONS\\Ability_Hunter_BeastCall',

            essential = true,
            nomounted = true,

            usable = function () return not pet.exists end,
            handler = function ()
                summonPet( "made_up_pet", 3600, "ferocity" )
            end,
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

            startsCombat = false,
            texture = 576309,

            handler = function ()
                applyDebuff( "target", "tar_trap" )
            end,
        },


        tranquilizing_shot = {
            id = 19801,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = true,
            texture = 136020,

            toggle = "interrupts",

            usable = function () return buff.dispellable_enrage.up or buff.dispellable_magic.up, "requires dispellable_enrage or dispellable_magic" end,
            handler = function ()
                removeBuff( "dispellable_enrage" )
                removeBuff( "dispellable_magic" )
                if level > 53 then gain( 10, "focus" ) end
            end,
        },


        volatile_bomb = {
            id = 271045,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            bind = "wildfire_bomb",
            talent = "wildfire_infusion",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "volatile_bomb" end,

            start = function ()
                removeBuff( "flame_infusion" )
                if buff.mad_bombardier.up then
                    will_reset_wildfire_bomb = true
                    removeBuff( "mad_bombardier" )
                end
            end,
            impact = function ()
                if will_reset_wildfire_bomb then
                    gainCharges( "wildfire_bomb", 1 )
                    will_reset_wildfire_bomb = nil
                    removeBuff( "mad_bombardier" )
                end
                applyDebuff( "target", "volatile_bomb" )
                if debuff.serpent_sting.up then applyDebuff( "target", "serpent_sting" ) end
            end,

            copy = 271048,

            unlisted = true,
        },


        wildfire_bomb = {
            id = function ()
                if current_wildfire_bomb == "wildfire_bomb" then return 259495
                elseif current_wildfire_bomb == "pheromone_bomb" then return 270323
                elseif current_wildfire_bomb == "shrapnel_bomb" then return 270335
                elseif current_wildfire_bomb == "volatile_bomb" then return 271045 end
                return 259495
            end,
            flash = { 270335, 270323, 271045, 259495 },
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            bind = function () return current_wildfire_bomb end,
            velocity = 35,

            start = function ()
                removeBuff( "flame_infusion" )
                if buff.mad_bombardier.up then
                    will_reset_wildfire_bomb = true
                    removeBuff( "mad_bombardier" )
                end
            end,

            impact = function ()
                if current_wildfire_bomb == "wildfire_bomb" then
                    if will_reset_wildfire_bomb then
                        gainCharges( "wildfire_bomb", 1 )
                        will_reset_wildfire_bomb = nil
                    end
                    applyDebuff( "target", "wildfire_bomb_dot" )
                else class.abilities[ current_wildfire_bomb ].impact() end
                current_wildfire_bomb = "wildfire_bomb"
            end,

            impactSpell = function ()
                if not talent.wildfire_infusion.enabled then return "wildfire_bomb" end
                if IsActiveSpell( 270335 ) then return "shrapnel_bomb" end
                if IsActiveSpell( 270323 ) then return "pheromone_bomb" end
                if IsActiveSpell( 271045 ) then return "volatile_bomb" end
                return "wildfire_bomb"
            end,

            impactSpells = {
                wildfire_bomb = true,
                shrapnel_bomb = true,
                pheromone_bomb = true,
                volatile_bomb = true
            },

            copy = { 259495, 265157 } -- { 271045, 270335, 270323, 259495 }
        },


        wing_clip = {
            id = 195645,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 20,
            spendType = "focus",

            startsCombat = true,
            texture = 132309,

            handler = function ()
                applyDebuff( "target", "wing_clip" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "spectral_agility",

        package = "Survival"
    } )


    spec:RegisterSetting( "use_harpoon", true, {
        name = "|T1376040:0|t Use Harpoon",
        desc = "If checked, the addon will recommend |T1376040:0|t Harpoon when you are out of range and Harpoon is available.",
        type = "toggle",
        width = 1.49
    } )

    --[[ spec:RegisterSetting( "ca_vop_overlap", false, {
        name = "|T2065565:0|t Coordinated Assault Overlap (Vision of Perfection)",
        desc = "If checked, the addon will recommend |T2065565:0|t Coordinated Assault even if the buff is already applied due to a Vision of Perfection proc.\n" ..
            "This may be preferred when delaying Coordinated Assault would cost you one or more uses of Coordinated Assault in a given fight.",
        type = "toggle",
        width = "full"
    } ) ]]

    spec:RegisterSetting( "allow_focus_overcap", false, {
        name = "Allow Focus Overcap",
        desc = "The default priority tries to avoid overcapping Focus by default.  In simulations, this helps to avoid wasting Focus.  In actual gameplay, this can " ..
            "result in trying to use Focus spenders when other important buttons (Wildfire Bomb, Kill Command) are available to push.  On average, enabling this feature " ..
            "appears to be DPS neutral vs. the default setting, but has higher variance.  Your mileage may vary.\n\n" ..
            "The default setting is |cFFFFD100unchecked|r.",
        type = "toggle",
        width = 1.49
    })


    spec:RegisterPack( "Survival", 20220821, [[Hekili:T3ZAZnUns(BrvQWrY2JglARzMKZsBLn7D7LC5M7Q4u1TFYu0su2CTePo(WECkv63(1aGpaa7gGKwEMSxTBTjzgcGgD3Or)cnGUzYn)2nxVYpl4Mp5EUR75F0DY4jF3KV7IP3CD2Z7cU56D(lFW)o4pe5Vf(3xNN8y4J(Byn88My)vmaKgNNSeA8BoS4(SSDPF)7E3DHz3NF74LXBFxA428n(zHXrlt8xNX(7lF3nxFBE4MSFk6MBXrGj3CTFE29XjWCgU9hV567dxTkq09G0L1yYHf)75rzbjh(5Fi)U80SdlCp)m2)Y19WpF4N)X4OhdsGVUoEzE6HfXWFBP)UdlwEFWYhGpKfFyrsq6UGLqNIcEcAzJFk0qAqwwy0DWF6DhwKNgu2kBCECO5vbSGpVdGrkqJJV56nHPzPm(suMp8F(eNj7VKXbaEvwqWgVSe)D3CDqK)TBcwDZF(MmG8z9Q(lxVmjeOQq)BUEWHf3MVE94Nc3SYlDxi0q64KGT(HraYTFVXMDamooEZQ4NIg)q4MnEWsYw)OvL9OgZwNee87ablqoaJU4RngL5NuImzW0VjW)XGkgQeIvXBds2feL5LYw3KX3m)nW3hF)ZRs8t9Uf(84IHZrhoY(y4UGKuVhdII3QGSgA9QdlUB5kyMEgqopaDVlaw5b8Z26zIF4kVGhziL)QvPJd(mtMrW60BRA2Mp7WIjNl6eJKFmWlikyByqrB6dCzmSX4WItGnd18i51eRlY9gn)4lelHntXr(SLrp)KK4Nyy6LVky6lMHcYYjRcbKnyLhO3WpFdtA9ttjX215GmFsWY7zIlEzHBdkfKK26S1FL3TXBV1hGDqY48DfTfNkekxhE39zEYcItvxJxhMeWHadzEpjYuTtuzmJfixQ36ebmzQzH5yIez7NaBgby)bsyp8WIEVYa0tVwxoSyKyCOQPDeyuEuW6yG(gFR)DEXR92MhfYOka5(FZd3TdiKk6CvGF29Ea)4He)Tm69JK0BnCJy2cIU7j)KNt5AW2XLK3TZpXplVEAelLcdta79rFaoaChV9wpqzZY40mMbJKWLzmLks8Eqcs8x8ygBeMC8ewOzgDGU)DYgDkq)untotoNKwwfNno9EaZJaRvCrISWLpaubhLHvwwhcz2Dbzdpy8bWEG7gNMbUlWPfxXYqt4OP8ewWQXZBZZG1TKN5iNUw(2ICd4MUHVhbC6my3J7h9C3Ter0DcToASnaGqP74PQgWu32GT1ggf4Cb89cZdC3jCjOzATXiYZsMU34hXOFpMWYdcAtxDzzFLn5QZu3bis824OGMCvmwAj7gxJfUzXj0kg5GbiLNzwA36N8ahik4D69XCTRt01OjXjEgueZ7h(8tRVAGqCvDjTfsw46Yk1Zj2UqipnzSlVhn0YDyXLL6Xig4Lud8cld89v6inOD2XaamzPzcT6rH5GOGpN59uOG5wUjUcDkCuRcSHrRZ5Evx5U2Ox19FFxxnu2NzSs)JRU(xB7rPmQzYLcH8xpTnvr1kbhG7lFP36QbcmOFZ9icNQvILYhSCNSkiHzdFj4LOU9nxt63nOovkgngu0vkx1nQWnsca2v69SbWzrwc)qqIJzlBEzXEG6tUm0hjybxQyzNllPr26Qy7Ry1)psU59YmTAtjAmoDBdDzLMyI11hwcsWk7DXXPbCXbIXQRnQCSadiloP0yp2ybk724D9kwzZbdpSfXdxypuEta1YYrsqLJsGqIjzKYqOgwNzNXGF0XpPdpwNk8j)uqm1pLfN1DbrCYJ3a4RZN5nYcECuNWGw21wLHHlAJmnDuZ9XycD8Pg8jG2JVU6uRYUyfx9uOzAx86JkLxTq0ODvYiFPrePTvnH6wCK8wOiHI1USy5ewOqNyq8Sr0LuQ((sJxDYhIgXi2oUBw4ogeZUpWd8f0pPmY4zG)5eOfLBgKSRc3k83S7EFVDjbR8besXZIsT1vGyDEYZkCt1wK5JfY8VJdfeX(dlERQ2XrLSDs19nIj1UYiwmbQjEWM6jRrXzIUNJdFGsNutDTAwgyEIkIatXNpMW7hlhmj0nf8vlD8tFPPfRdd7QhzLsHswtXvFYLwyhPts4ob2(tRpS454Cgpi6nq737)iWD(u9m(gay)wXCEyXpuoPNbw2d3UBZZc5Ydl(paY(WIFuq3hwewc3NeWTI(IbP3)nboUojElBI5qonE8Hfsyt7rLIHa2MY3SYm6KuXFcH)52aWJeqU4(aMhYSrfdD7)Sqi6WI)mSqbFdg0VY1)CyX11P8HkPiV8L)ESW3IOaMl2q)su0yluIJ1umuo9e1XhQkNBOzzSuQ9JlEQVr6)jm7(2jTghX21qkGYWvOx(jbInlLKcSJlgevtEkKjBMMfVJDsPCGtcRL5jjbr1hiR)wr27zs)q0e53DV4mztZbtMHrf7fk7fB3GqN8MG1CGaG0p6zrlkyldiGqpdLxVUgNTKeWoKyGg56YASv8exl34y9ufmWGxoLrWy3Upfu19dGWmTYzh04O40Iz(C5oRC6IADKoF(MjAjNQXpQndP5HW7h1q8eGx9SOL3KnxjSVQqGSHTQ(Tzkrs2JNViRpO0ytpfuYkbP3cKPjQdPgGqekJPiAnF9bjfeYEWYZ8vCEwA4QaHVpvbNNdSoWjSDXmnoL(T5ZluJsxRd8Vd0pY3vxH9fdPk9cvlh5)(VVrpvzuRiWw8iiaWnHCRwIqmvuT(xbLl(3h4VIP9zfxRAXay(h8F)JmDz8uYdQiFkOYvgMpez3Zu1XvCTtCyhmZ(l95Lysy2BwX(Rm1xmLG783U95I5GbNL(C4KaZCitLnFE55BEz46WLcUu6yTDxf85WupXmILyGss)VhNLhDxqysIhqXWsbyNNfnRmiz9v(uhMX9pwkGdtQVgizk0yWCkh4TUNYxCELt0drpgKj1cn6QWQpoDt46OYAEIKJuMBJswhtIfyrnoNvth)oSpYhuM)WZWFps1pbJmh5o2G(0ZKAFNMwMpdqVv0dbI6jHkfQgba3jcpOfGdILzKwbKLRsXYgcTu7v8ZkZPYG6THjRszQwaBQpxApT7z3HL4vS0F0cezWXgxsZQZ4rRqL58tQQRttrPzvLUKYb5dUpfX22YD5tDxrM2YUEHYrTzIkFmTrVvBK558Gpm1Q6NwODairy5BjlnPOgcbbfWyBw46BAMvhfVhQfaumc9vO2gHGskwZLtaA5AqzilS)0MCqSAtALhiJv8YzSyG8Uv1dvAM3dDR4P5BHE5TlqpNVkjd)24SmOfprkIFIh5z8NdJ0gJYjPTEd4YeVcv16fD6RRJkofIZN)N8c2ElyrhPqIKkMr18ytvrOzskwPfEiz(fUR1hBFYlZPphT0lFh2op7yaMDhASYugEvCEGaOTGyYsIz(Zvtt6oakTLeJQWauLTYwKiBHRQYBoAJkjV7YHnGsCvR29V6p1od8fqgXDWxzgHyD51LnGT5TTKfb9Oj796tdG1OoVus7U5qUZYfAvgNnz89(PmJVES1PIYgcz3L2akXgPCJvLRk1DysPoddUdKaTBlXLMJPgD4jhPUrjMRK7WKuFDw(mHtsdVc(RYt43Vbr1PIHb19yekwutdwylohnmyqBw1mHhdTHkVLxeVYz9xEBLaliAAUny)o5A9T9y5rNz(hk(G2Ag22BZuJc9IoFJAqYk7Z8x9SkBfDAemK5KuTdzlxzd0VRQYJhydhjjII5czzRPXonKfRdSqQo)4jP0vCwhzTU0WkQLtnTcyMCF5sZnHapDmTM8NBdf75sbf1Agqx14YAyvI5uBWCEdyQlXJBC7vADr7)loJIM10iTy5OwraeErm0QbGHAw7krDRYtIRHcIxoyBWTcnBQ9gHYiWjPJNBq93qWiTdhTU)HPJx6V8(awcS8xcHcNa(RMbQEtZtckqaKKG5whlx1OEIDAmLlwizRAsPObXWgjNuFocoblnLK(i3w)sjxnoI(i3w)1BogcHJj2foSj89k5KbcwutdwylwnY1AmOB(iJRZ1mQyZGDlTMAWxi8aomGLhDM5FO4dFzcXJ2ddeFKn4)Xl1hzlwZhydhjjIVi(i3BjLUIZK(itT08LXhzlr4y3hzAYVR(i32LcR(iJcOxOpY46LS6JmUXTxP1LxdFKriGw4JmUbGw5JmM8u)9rULsNTWhz7PY7L5gu)neq5JS7FS9r2f7u4TCEN2pjwKtNx58m)nELXuw0S8JLuuAFSZj(WcXzQXgkRwdbsHxWVrldyNtlRshlqE4RBIzx7sE9k6VPWCM)s(7eaRe5whNmg7KM5h6wQLIwYsjsB45oaP5cpj1)CTm0PnBmuOXCA1wHwcu5nJxEEn934cLqDe7Kfg2GIl6VsPnkxn8exXXpiX4mD)Zzejx2f5zXWr7ofxbJk2dFKALTw9Ui73KTbMV979JYVH(kDHW5jVSjdlOct33KxDMCbFMQhoDahR0IA)AwlugEI1BM2bQRJI2X)tDBYOp))EVDFy)2XxAbL49prufEVeDcfSrQIEzIKsdSxOh6dES3CQJjBQfSaxBSaxjwG(tPKXxwctKFLhBrChwx7l20OSxa)z2Aa5GXTg9c4Qx8Y5Qei0il88lK45lXlb8EEvkrUIPk1(U1lhiDn(zxJLJPxtekvz2Shn0(fKZG)lkAWFmM9Q9vCdcmBKZY9AWIXHbe3oHsS64CDTFR9c9)eUHOr2Li537BvfbQxepQBDp1fBNC90YRYZakjfClEQvNj1vg3WRqKPGlQRgUKN34)ayCFZdb8semAnyGAv9(mSYJR(rzI(MoCSN9MAz76d7sHtlgESOyYrgEVQOE8R65DMx7ckrDHa)hWRuSKWULxDsI53KlSe7wOQLDQDXwEgEqx5qNyQ6FV)35ClcIe4bDT0Bas4czzgEUJAZZRIqpmzyKuX5HtygUlAeVpvovsVZjeDpPm3mygdvYvMQiT53QUM3Alfv4epSFK30So8WQqW5O1o3hnWMiuQRNM5NpIJ7L9JLQF7kXRe(W0mrWhPun3M7cOXdVUx(WzYdTgTrSRyA1JHtNLQzVvFRqRY9gMMG)2w(fJji6o)7c2Y(MS9P63AGQLX65v)UbIor8vsK4mglF5oVDtC8kUmgwAB6iW8Jwgal4(BQstk9USwbqgVLJHv5VOSLnSGet9(75RUJX600B0I3jwLnoeojXF6vQ4uI3yvqEE5dwct2aTjedB4h(fsZdORjiHBcQmGWkngyx9tABBgEKDDNkTB32QWUy()1CCIdLfz)W5LjeOGBJnfnYrz1bmWUfk3gcRl7YtZYb9gbj58uRR(mfu1TsTdEPXBEuFJKWAQEpeNEIKxRYxBg(7blBk94xPP79JaTeWcIZasmdnAj75AVf38Mshg0EOfK9hRKlVEJFsaAxgsDEkm(OElv3cwD)tMQ8Y4uY5KVqqKVYqCuRnCKkknVJCinC9Y6hpjyPlWJ9hatXDlSWAob(rC2)abWIETBbn(La3A46RH45(AGFQozGfPOSDxoASkeCOJFwBSZ989sgVAEJ85w0z3UpqAJ1NIFAhyPp(j)KiwUCU56)NF4x)0p9P)63FyXHf)g7j(iC7U4KYN0J3iUsPVHD)ffhxjtVfZ(IFEw8wF(X4X0WaXDp(Wp)lHmpvM4(9SNCe(LIK1o7hocyyphLX8L7BpWVpK)sUp4ku4JHmu7WIyiCbF(dPZW3bCQHt(8OA49XJm8(UJf8o8ZwyF3gVRJ8Ulow4wb8MQcV3uRq6V9gb0K)uPPN3OdM3)YrRlmaV3u4wzfov(3LrixtaON01h7bE0Y1(IJbpTBcahbg9ujcSbFUOYhMirI1LxXFJZMVSfJ3fz8UfJ)9sJ)dhxY5d9GCmGoTICUSDl3qKtDBLEY5AitL3zv4s9xi3hCS1xC5rgEtpwWZ6cqAwh5)hHTATe1QE(b6ig2DLt(WC(V(F9lsO2pXXe24)UY0UCyb)3gjOz2lJq86qwuzFdWbA8B5e8r0FoN(Mke7l3REaBEf4F64kg6PZExPZxNXkmQz1EGDw8Uz87y8z8B57SIuo181n4S6BpCzNA(ijC2Y4Ov8FEsMH90qGJA1ptc4Tt9ajG376y8WBVm2JZcxpRnXDGJYvhDHe)EwrgByqw7XIYb7HIYruHBepsuvGfMorob4cuT(TC6F5RYB5Kmw38DPIXzgO)(ojpKYQBtiLsvBEmWOgjYSjodnKMJ97h0MSuSFplBkosbXC1fNpA)(HQt28jIvoK3fcac0yXimknfwvHL1)saWlGfh)L8uCkEBaxfNFlWZbTmHBkEKofVPN7YHp)RvtpO(Hn)SbiEMdteVHHfpmNLLrAyAXI7My2yyAEwHnT)f20w8yIgXZQASayPCWvSbpTSKfVDtGayBzvZ4tHGywuXCZo650a2qszVbIbp5)8zfnLgULpVSOiLM2kn9HSf6Nhl4o1Snqhip)8EmM)MhdyIcv2)1BSqMaDDsQiAXFmdMp5897Bgw7vtEVY6O(tnKqYT0Rwg6PvIZoTrs0Xk6XfP7oGTJ6YVZr27n4pN9obX3DM4vAA2KM7DV6chtVJu2bp8Fnc9bVmWlcU3Wum3vgiQpJuYMJVLBQv6inot5ateGMSmpleMXA6Q7wUA)EPZFCKYKciLCIWXMveVke64S(ReaOD0ujVSFp)VEADoEUQ6OooDY5JA5S0QUjXnqPFMfi9guoChkorZtoqWXjQ7jTPqRUTiMeKrvwIN6nHlMcoKRiJ2Hxb5cxDC4i0vyPPtddukc7wsqkolsk5JB50HSTY18jJNEcY6UI3NFPM0gfIx)yf4viXSl6mnASozkuROFs0o0vNIyd83oero5T1BZhX4mn0d1QTBdkoPxNHuB8gq(GZBaVN3eAVDYj2G3aAacEgQ4yWhDOHd339)5BfF3FR4pgwYgoO1kdlSxHPeCeFn8F(mLJ8mLFmwKA9suTFUOVu)Zh2b9t1Ws)Wx7gygoOXZPpl4bTpvpBnFv97081qVAn8AP1yR(HASkPl0ksfSnQbhNMJVr5pPBNul2hmRjLvWudNKAIB8SpyQSnmAyT0SSosx6HRySu1Q18kVEnMIGo5PGvJRgFS17SerZWpYLZ(1yiuq1mGzReOk83SIZOakaJQlBjlEQPpq1suQJdUQCK6440kwPgeJCLfjslq7ksP5kEywaSQYhYcsQ5HYf6aQmXIQFvulqCqZYhMsLfDL70wkbxWoRsh7zYvCZSwvWnmuqOx8QpCUuoBm5uUqFmji3VNSIIe(oIwfrJ0jl5SiB2AgzMLD0n5WqDjJBY15dVPgPHC)E1VmBICUlNpvZf8YfeaUNvuUmZCNsrbs1Ot7OgPz(YtqeARIbVzguyiEZmT1EdIneR11C)6oDQAPF1NoKtmqOWnrU2xMp79kAN5zXYE(NO)5F1Ho1ugZmLooOz4MBvg)chUFpXf1B(mwYz12omd9MMEIlY8R7yr)WHp(sqbk)t6mw8Y4en8zOB56Q4etuTqmfJCz3ykfZEQoM08wjD1eeW0iXtd7mdBARzxq89OPNOwByHr9T5rIJeb5udL4aF9YAxnsuCfmqAQ8gDv58p21hWziRjUHCyjYdMVa2vLqKAQRC3VV5iLTlBsWGEohGEHdntbnLNM7oEQdH0hIxxk3DUVfBRtxZRB1aTfDm91O0bJtugmfDEOvN5stW8rTwCqWEB9tEaFmsjIMoaeA9jMsTgg10CJRydTZqKL0jJDD02mFjBtlshVuVJxq0X3dB7juQ4Goam1DYIIdhGEHuGzPWwBf3jmADoViokS4o6OkVAtfCVaQnz52FCkod7HUpZPcIo7oSL4opByQVmKR)Q(0HKZupgB(PjNnfd(S10XZ5FKs24iT8(pKRJihqyVwlqgUXZNbZ5uZ58PEeGVdZKlejPVZ0BlZj5AI5k8XU1FfE3H1KdEAk0RMGI5uoQ4xLPREcLltHzsftdw7N2LclQnjzy(hMIwRqYiyA2S2CmPo0EW2ObwK4epgkN28Hq5QPJAAmfbeL00LNlJ8TrUFa5L0etVZhasL21gQimCWVPNJk6Vw(inhjkWsXDGQB0HgBY4(vUdagpo3Jkxbyl4T4ybhATpbx5EIH4bhPXBqRIbbxRlHGJTtyyx2k4EEZTc8O8MnPRBsq24prFNtRZVXlDlogDza7DXWExDSVRPMO5J6KQFRn1)pazin1d2rEXfDNxGmLJiuSRlw3Pq)4dYGRIvcn2sfdFZhAuG0zObxNhzTvGAJc9E67qR204PhsQJc)ubD6DbM9wb)L6m5o5IryR2toxxlMnVGrzWgII3Aa71ZkIMZQ44yFvPQKh0Nx1cnOlh56Xzc6BqSOr87oEkwsMk4S6lCDiYlE))dCPu5y1FA0zGYrHokHteYUDoQvNJm6xIHLAJRCMsNyxDYvnq7MEdI7iQnD7OPesKk35isdN4IQsTiJ2c5dZzjvO6Or6FB1QV9L5g0xFuu01nJO726A5y82jMuOyiu1UiOBJB1v7Ruwq1(UMC10ZhrjLuJGL3CHzQxySINy9IljgNP01R)sZ54u9RLwQYpBjftM(1CGAYPRx3IlaecyokyAHar9nPR(sWPnPvuKLl3Xv)P2KfcXpIMY3lVomQqd1nIAj99vIh8kqxTBL91HCM)QVKIsBf)rrEigMvDrWL)jiqkcUI9gQ9Refg5me9N5cMl6n2EniR6sJBEU06y5KTFF93LyUfo8GtiSYWKywRhqfWkJLC(mKzQSXr6ZvzpOiqNxWmnGM9smzdnmBVD6vO)UuSFp6NNBauFR7i51dku4OWh(Ist1mw9TegWWA0hbSJQXF9FipDmaZ3oDokf4G(1RmaPV1LDYIuOaoYXbQcVTPQDhtno398EUU1s8rgrmXgNC(P4CmtyFVKE0hep1rMOM5g5UTM7HH(gg7vk1MJXfXtnTLvbmssy6AGpoCs()d963Ic)r0iuddtdP0JnCGoAyA9C(0ruellZITuqqMggPSV1ODTUzKSZQWgnYrwXO5F8F0lNQRClExd0(L7PrzxnPiLg6DCKjhzCvDKXMZf4ST(5iJnNM06yZ1OM)YnrBu94BxsFUk7bfbAsnRTzQfoYOR3WWS1xJ(OghB4qhgkCu4dFrPPxbpFrnjP6idQTQE5idHHHbKOaoYDCDKPtRBTeFWCKbJn(Q4idH7IgCKbJAAPJm24EMCKbzS9XrgSTSuoYORb(4WjFboY42whz01JzYrMMRNT0rglccuoYqgGEFms2zvykoYy7xXWVqoY0UkrIFxJ)I(tmOrKn9MRzx6e2dD)u(ZL6n)F]] )


end