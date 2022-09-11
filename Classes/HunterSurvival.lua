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


    spec:RegisterPack( "Survival", 20220911, [[Hekili:T3vBZnooY5FlQ2A1iz7rJPS1mZUXsxT3Ejx2nBMKA9wvUpzkkjklEwIuHVypElv63EAaWxaa7gGKwEM9sDPsYoMKOrJgn6(PB0a6oN7(T7UDLxQ)DFA8LJhF5354mYX5Y3F1K7Un959(3D7EVLp4Dp8pc92b))Vnl(XGh92YEXZBJ8wXiqsuw8s4LFZX5Bst3N89V7D3hKUjBXOLr7ExsWUSTEPbrHlJ9wNY(7LV7UBxKfSn9NcVBbod4C3TEzPBIIH(my3pE3TBcwTYx85(jlR4KJZ)3Zct9Jp(Z36Vp1F3c4Fo3X5IJZze84pF8N)XOWh9JtpoFD0YSKJZJG)AP3(JZxUXF5dWdsJoop2pzV)s4Jc9FcEZwVe4fj(PPbH3d)R3DCEwIFXBzTZLtn3sI5)59ansGH5O7UDBqsAct0eM6b)NpXLZElzcbqCL67V1nn2B)D36h6TyR)Q7(Z3Lcsa2xv9KBxghadSaV7UT3X5lYwVE0tbBx5MSpaErYOy)DEbHaZD4GXx3h44OOTRIEkC0dbB36cZk78cxv8fvC26yF)FhgWcMd4OR(AZrPEXfmtk09B99E0VuGkXyLYw)49(HPUjS5nz(n1Bl88rBEEvSxI7c4XJYBoND4m7Jb79JtCF0pmANcZA4T3CC(9lxb90ZaZ5cS79(WmpWF2MpJ9cw56)iJP8wTkzK)Nz6mcrN(7k7TztbD7lfFeBi)OVRFO)Ua)83P3WLrWAJJZpdwmujJKNtSoj3z28JVqUewmff6XMgD9IJJEIXPx)QWPVybkOlhVkayw)vUGDdVSTmT1pnHKBlv(ztfRdI9DxeTBXO1zWsHy)LByArUPb7adoZooFcxhempbVnxbJ)8RL4aVyyDb0NVVTRlI9Hf9jBynG3nIoyeRZDtJCxfi4bhbte6)5u3NceS7(n(Xr7Ic9vxq3OXe5AMpqk0WOKy1NK9MDER49RhmH4hpkBF(7IseRKxhC)Mux5vVtuxyuY5mM5JTDguWCjURJf0K5Ec6dhKzQVJK2dooVZQZCTLoOmFC(qr7q9T1xWrzH(RJGX3OfE37gT2DxwyaBubm3)BwW(9WaPCCUY3lDJlipEi2BhB86Cj5aUIWHmpOH3)Kx8ZjC7(75R)3V3l2lnRQFeZLc35G89rpGoaDhTBHlyIEzuskZnBCWswhll8bviXF4YCrlCu7kG2WCvZ(CfF15dGenp1o0M2xfLokzdW6HGtEUsrAWYhGHbNNH5w2heWqSaAhUq79bth3pkjfaAXhmJfte1PJMphykRIpxKLcZCXpZzoAd6MzUECepWZdbrDkS(z8hDhVFjIYRdTLySLaGA54rt6GzcnJEVtXSRYy2GX26A0siE26fYg)UmTLheJnkBOYiv0fQL2cRlvXePfIBCBw4wgDOnnYjdmuEMbqzNx8dCIOW3jBI4oLC0TPjjjEg8FX)o8(N2IvpH6Q6uAd0SWTMvyPtSCHqFYz0y(xuZoh4xSWsgrdVMQHxzPHVV0kPb7Z9nqat(AgtBFu4qqX3BXI4s2jhFBjzdcxNXdgPeL7WxZ1FJ1bKB1vzx6Xs7pJ1T)ABnkLBntGke6FD05u5OwjMk8qGkcYrn(PEDRVhIV6D8vYU18aF3XR8JzEXxcGR19Vn2K9DdMtLcTLrfDJYDanQXO2iaR(rcrW7v8SZ1L0g26My7QA1)psV5JYcTkxjAcoDFdTzMgVJVs3EybjbVS3hfL4ZvhiAlv6babqAuCHZES2cJSfr77ukgmNdHbninc5(dLxeqnTCIuu5SeOKyshPiiQbvjeBeaKo6jD6X(OCq5NdQPEjSiTU3pKp84VaW68z(lzXCpSvCqd)0gLyMRAIoDRmbA1zcDeQgWeC6a1Qy6tbQNYyMgIzxmP8QfJMH4YnjxQftkLvlDZeQlXrs3JIgk27LvlDyHcDMb1ZAHktz67lnF50gme1IrUzs30G9mkMUX3fWc6fxez8uaFobBPhVRvXvoScVT7345Up2FLhWqkilkSwxsI1zXpRinvFJSCmxN)DCQGO2FC(BvTooSqStAU3y82KjSrlXd2mpznkotJ7z40hgPovJUg1l9m3r5rGPG5JP8(XIgtsDdgARL(ac)P6tnnyEyqBrKvOfk5nf38jxBHTzyXb7fC7pT(48NJYyYGW3aVFJ3JG05tv94BaI9B595X5)qrNEb4zpy3(Tpl0lpo))ag2hN)JIX9X5bf09jbDlhFrG27)MGhxhhTJ1XCkNen64CjUP5SsEtaFtzBxzMDIlLpbW)3cFarcOxSXNHqM1Qi4Z(pZvIoo)pdtuWZGg9RC7phNFBRt5thM(7WeFdIcyMyb9lXqJTqjovDXa50tufFOQEUHxlZLsV)0YN6lK(Fcs30mT1Oq2QgsfugVcFLxSVyXsXqbwXfbQQXpfW0ntsJ2Z2GzoXjP1YS4y)WQ9X2BNi)9mTFiAIS73i2k7KmWLzqy(AHIVITAqytER)Aoras6f(S4nkClJiGspJLxVUINTKeYwKyaYKqsgBfpX1YVCKEQc6zaLtrem297trvDCaeUP)ozas12btTyMVu(Jv2uwTpKo3AMh0sGQX3HYAPrtdlwD0pQH4jiV6w4lViBMsyFLHazJBvXTvM8QgaLelszAOt1rkOKvcs0cTpVw1J8NqfkLziAnF(bjfeYiy5z(kklnjyLVa7tzW5zGOdaHTpIzXPa3MhV(wkGw77DpyFKVQUK7ZBsz6fkNoY(9FFREQYOMrGL4HqaGBd4ETeHyQyA9Vcgx8247TIz9zf3QAEdy4d(V)rMTmEk5btKp5xcLHHHiDdZuh3W1EXMDWC7V0JxzobPVzf7pzMVygb37TB3Z59bJol940jg65aMjBE)YZ38YG1blfsPKrARUYLZbjUIEelXafd9)EuAw49(bXXUWigMka)8SOzLjj7BL31HPC8XsbCyY8vpjxHgdMtzlV1rkF1LLGOhGUniovkn6MWQ2qDt86WIQfJuIuKBJcrhtJfer12NvDCzY7QaSoYdmM)WZWFhQItWOWr(dRn(0ZKAx7MgMpdWUv4d(IYWHk3ZgjaheHl8gqcILzKgrKLRsWYgcTw7n89kRFPd1fbXRsyMwaFQpx4pT9z3HL4vS0F0agP3PMxssRY4rJyLz8DQQTDtEfTvMUKIg5bWNczlB5q(uxvKQnTRxFHulMOYhttSB1eDEUm4dtSA(PbwhGHim9TKLMuuhHGIc4Snny9D1ZQJc6HkfafNqFfkjuiOK85C5eGwmhueYc7FTnduR2MuIazKckNrIgY)SYVqDmZ)cDV4jz7GVYDVVEoFvsg(IO0u4nUIue)epYZOpheQ1MRLBZ6TaKjET9Q9v0PVUkQ4eioF()YLx6UyLsuAvnGQMhBQcPnvYWkTYdPWphUwx89jpnN8C4s3S9yR8SZby(DO5ktz4vb8abrBWGjnoIHNRAmPdauAjj2OcJqL(kBqISfqvLxC0etsU3NblaLKQw97FZFQzo4ZPmcCWxzbHyE51vmGT4TPdlIXJMU3R)ya8g16PsA4Md4GLZTQmk1z0gVeMZxx28uEzdHS6sRbfCJuUXkZvL6kmPuNHr3EsKECd5L6TPID4jhP6Lscxj4WKJ(QS8zINKAEj9xLfZpziI6tfJdQ(IHOCr1yWIyP)jJd61Kznt8XaBSYB5LXRCw)Lxwj4cIxnZgTFNC1(2CU8Klm)dLCqBodB5T5rJY4fT)gwBiRSoZB1ZQIv0UriqMroQ7t(MBSr63vw5X9SXJKdI8(czARUZonMf7dyHuD5PttPT8SoZADQHvulNBAgW8W9LRnxNc80X04H)mBSyhNkOgTMj0n1oUgw1yo3gnNvJM6A84o3ELMx0(Ff7rr9AAKwTCyJgaeOigy1bWanVDfSUv9jXbrbbLd2cCRuZMzVHOcc8H0Pdgu3DemuBZrR((GKrl9wUXNLalVLqOWXaE1uW0BswSFodGKeSXvXYv2QNy7gtXKfs2QCkuniA2q5K6ZzqlhqRbM1OSIrwF24eIrUP41R3gcLdh7kh2u(ELazGWfvJblIfRo5Amh0omY42CnZk2Cy3qVPgWcHhWHbU8Klm)dLC4ltiE0imqWiBa)XlfJSfV59SXJKdIViyK7SMsB5zsmYutnFzWiBjch7yKPh(TfJCtNkSIrgLqVqmY42LSIrg352R08YRbgzKbqdWiJ7aOryKX0N6og5gQD2amY2tL3ldgu3DeqHrE8FSXipgBx4TSFN23jwKDNxz)m)nELXuu0S8TLuuAFS9j(4CXEQXAkRwdHHcVGFdx6Z2NwwLoMZ8Wt3gXo2L86v0BBU7mVL8BkawjYTokEe2onZ30TelfTKLsK2WfEaYRZrsQ)4kDOZR)YaHfZjLlfAirLxmE9LvJ)AhOeQTyNSWW6LFq)vkTr5QHN4io(bjbNPZFoBqY1DrUym6tFFEmuQLALTw1Qi7NKTEMp97DBKFh9r6crYtEytgKpkmDEtE1fY5YzdxRknMhlTIA)ywlmgEM1tM2rQJJI22)tDAYO3))oVCFq3wXx4bL4gqrufEVeBc5IrQIEXrYOb2fBe9gp2zj1Pum1arWyBIGXsIa9BGk6Ckzz4xIylKdyDTNyrJYAb8BNSEKng3B0lqQE1lxQsWqdTiZVssMVeVeW74rPe5iMQu77wpCG014NDlw9nDBIqzkZM)Ob2pGCgWVOyb)Xi29Dy(jiWStolNRbloh6rC6ek4QtZX1(T2l0)Z4oIgAxJKFUVvneOEq8Oo19uhSDY5tl3kp9O0uW94PwDMuhzCd38sMcUOQA4IFER3dGZ9Tp4ZlrWW1GdQvvRZWkpUMCPmDQ796wzB7f7soOfdxwum9id3xvux(vD8mZRDaLOoqG)d4rkwsz3YL1jr)BcclXQL2EpQy5A4bDMdTJPQ)9UFMZTOisWh01sVbkHRKLIC3qznUYgETo(b648WhygolAe3pv9l1ENrO6EwrUzWCgQKRmvvAZ3vD1p1wkMWjUy)ipPzT4IvHqYrBDUlwGnnqPoEAMV(ioTh2V3kUZqTyeVu5dZYeHCKY0CtolGg386oHHZecTAVJyvXKYldNwRvZUR(wHwL71Cnb)1o(bJXp8EV793XEMS)PQ7AGYPXQ(v)SbI2r8zsK4mgjF4oxSnkAfxhdlTnTKyEHl9HjCVTLPjLEvwJiit2Y5WY8xu8MTSGetC)7zRUNj60SBy6GQLJsszHJPRf3sjL4wwf0Nx(GLWKnm2eQH1WHFLu)a2A8J5UGkciS0Ib2r)K23MHRz3XtKwTBBwyFe))AooXbYQSF4YIecKlTX6IA5OSCdgyNcLfbW8Y(SK0mWUHFCgp16QxtbLFwH1b3KOTpQVqs4nv)le7EIeQv5Jnd)(GL1LU8J00gVqWkbmH0VhjNHgTK9CT3GtEtbGbTlAbz8yfs51B9I9r)Kbu7NctoQ)MYtbRo(Kjk3mofso5dee5TmeN1AIePCKM1sjKgVED1LNem157Y(hGR42fwyLKaFlo7EGayrV2UGg)sWB1G(AiEUVg8NkidSifL97YzJvbaGo(ETX23Z3l58Q(jYN7rND6(aTn23i(rX4JaQ7BFYloKLlN7U9)5h(1p9tF6V(9hNFC(VXUIpc2TpkU4k94nIJu6ByNFrX2vYSBX8V4LLgTZJVnEmlmqC3Jo(Z)sadPIZ1Fp7khHFOizVN9tUb0SNdtzy5(2J8Zd5VK5bqHcEmGXAhNhbHl4XViDg8oqsnW5ZdlP34lpX0Z5urVJ)SfX3IO9Tu2D1PI3YP3ev69Mkds)T3iOM8JkC98gDY8(xoBDLb69MCyLL8uXFlZqJnrGooU(yh4Jgo3NVn4jTtb4eiONinaRjNZR8bhPHyv5v834I5RBq7hJ0(X5T)9sT)dN2HZh6WWXa70OHZ1nB6gICQDZ0oAM1Etj6SsEP6jKRdo12loX2U1T)0D6zDcijTLY)tWsTgYALx)aTKdBVXjpOp)x)V(fjw7N4CcR9FxrAxooN)tkf8A2nJq06awuzFdibQ9RGf7He)qy9nL82xUl(aw)kgcjJkLPNp9Df4VUGvButRaHDr0(P8Jz8f8d6708Sov)co4IQdqCXhv)Es4ILrHR4)gLmf72HaN1QUPeWFp1DKa(xxfMh(7lc)4IG1tBsOh4SC5UxijVNMN0ggL1UVO6JDxr1xuKBe3tuLKf6orAb4kun(6C6F5RY15Kmxx)QPIjz6PFfpj3KIcCtOLsvEEmYOgmYuN(dmKPJdh61KevC4alHk9LIJ5MRUC4Hddu7SzoIzoKRgcGc0CXqSrAcmRctR)fFqwatoEl5z5uC9aUkkBbiZbdnbBZVNofxRN7ZGh)RLD)X5)aR)znqCthglUgdZVBolQK0GK8j3TrS2WS8ScRB)lSUn)(enKNy1ibXs4KlFbEsrvlUyRVGy7yf04tbGAwyEFZ295eFwtsyxdI(p598f5VkjyhVFzbsk1TLg7dyt0ppsiDQeBGnqEk6Dzc)Tp6ZufkHaO)YCDc05jP6Of)(myMZLhoupY2BCEVY8O(TnKqZTaylJ90QY5(nrtSVv2JRs3EcBN1LVQJS)1aKo7FeeI3fIlQPPo1x7EZv9nDvszN8W)1i179YiVi(EdDXSXYer9MKs2D8cURwPD14cL9mrqAYk9mxzg7v3C)YvhoiTfKdv6uGPKZfowVIGQqyJZ6puaG1rtv9YHd8)88Q08Ct5UDCUZLdByV0OptsAGo(zEG0FHY(7qjjQV5bcjorPpP1fALUfrNG0QIQ8u)v4QPaMCfD0wCriNd1PpNHUbltDACGsDy3WbKcyrsnFCpN9jFxXCUZOjNHmVRG(8lvNwRw86MOaVijMEvRhJglvMCZk6BgDF6curSa(BhGON82QL5dzsMA2HA0YTE5B2B)bul86rENZBGVNvNAV15mB0RhnbbKHkad(yFA6WXU)pVU4B)1f)PWt2GEn2yyU)kmJGd5ZH)ZBQCKBQ8tXKuJNIQW5IEz9pBqlSpvrl99FTDKzqVA3O(SGh0EuvVv)I1Vv9xn7Qv0RHEJTId1yHsNBvKkyBuho9R3(AvaLUFsTyFW8Muuet1ajvN34zFWuLBy0XAHBzDMUaHROTuLR1SsuVgtrqRqky15QX7B9wRrup8Jm5SFnccfundy2QcQC8MLsgfsbCuvLlzbPMEdvRsPw24YksQLTtRELQnyKlUirAbAwDkntbHzoXkRGilmPgcLR0jurIfvFQOCG4KMLpmLIl6MXtAOgCU4SmDSxix0ntBun3WybHDXB(WLs5SXeOCH9yssE4azrfjWoIwird1hwYzr2S3mYml3x3LdJ1LCUjxQp8xvlnKhoO(KPoY5UC2eni4ftiaDViVIzMoEc1iqQmDA2OrQNV(meL2YyWRNbfgJxptBn3Hyn1ADl3VUDNQv6x9UdzhdegCJLl)LztFVI1zEwSSN)j6Fby7tNAkJzMsNh0CCZ9kJFMdpCG4S6nBkl5SAlhMIEytpBms)RdSOB8WhFjSaf(KwZfVmjb)WmP4oY2HlA2K(khTOzxJqwRQzYGbRV4yMZK(4f5D)MZN0QEkGKAxY9Y3IivxIt6GGT(jX6gheYultBdATgYKgRFmeCXILpMkZ)5Oy2Lfk2diKTjvsc81lnLvmr(Xob5vfNITYODWoYe9hWEfh5cmf5c9Np74HiYf3nJpCOElLbIysXGUp7HEilnpcQRpnB8OjTy5IYI6VfZwrBtKDzdTLoa6JoAFmjrr0J0jExTNlWCWB1AXoF7UZl(b82iL5D6iUOTNykxIyJM6lCflO7pazk1z04(AlMVMTOf5dVw)dVI4dFpSSNWOsF0gGzUtwvCqp0dHd0l5GlkLobHRZ4vTsoeJHNu9vBMG7erTPl389pQ)Goy7ZCUVOtNfBkU19gM5ldBUrL3)MNnQUIyGeKkcyIpsPBCIME)hY5rKDeTtZfin34gsHHg3CsUQAbGDyQCLxj9CMDBzjj3sm3Gp2jDmhDh2R6JNxg9YNiVpLtdWRs3v1HY1LXuPQhc79N3MkPQjzvz2hMGwCuYmys60MSVW9PrWw7fSupqCbWCE9l)LBMmSUZuesumMU(szMVj699ipyQy2D(amuPH2qfHbrGpdZ)ETeWAo0BqKIdGQDJdnXKX1RCaag3)6tQubelebkAHhAmMGBgFMH4bhQjBqlBdHuRn5CaBLWG2Suy8L1xkWJYBQtBxKGSW3rFLtJtOZlDjo24Ya3pgJ7hRZ9Tnxm1ViRuXTw3(FpKMu3oylLfx1EzbsxoKWWUUADRc9J3idqflvASLkg(Ip0OaPZqdUnpYIjb1hf6DtqFAZMg3UusBu4BdA)oxrDVviFP2eYZUAi2STZL6wXSHcgvaBikERbSx1RiwolJJJ9uLYWUxxUjp0OUCKRNMoORbXIgX)4rtWsYuUKvFIRfrEX)()ax7y9TINgThOak0snCIq2TlrTcoYiUedt1gN5mLoX2cY1sQ5)aoquB22rtjKivUZq0goBmQj18mAl0pmNLuHPJAP)TrZ(2NMRn(6IHI2UyeD1wBR)K36yYGIHqvBJIUnPvB9Vs5bv75A6vtUCiLwsfdwCunMQEc5YVw5ZpvCCHsBpVp17JZ1phEjk)uTK3z6NRdQoNUaLZpXtiK5KWP5kevhDWQt9NwNwoISCAwU5p1KSqi(Hdv(Gi2IwfyOqzuRHXVsYGxHXvZMzFDgoZE1NsrhB5)trEigKwE43L)zxqkcU81gQFxblmS)a0FApyq0RT8QxA5bL3CFP9HfD2Hdvpxs4Md4bFGWQ7uIETQbLeRiwYztr6PIxouVVk(cQby)xqp1Jw8s0zdm0BVDYnO)wCC4a6JNzGuF74HYZhuSWjro8fDmvjy1xsyGdRyFeYoSI)1)XlTVbA(2jZqhb9rF6ngO03oMTZIuSaoZXjQISTUP9(ME5SXx2X5TgYpYmIjXOZLNJlXmX9Ds7rVr8uhzA0mZO0TXspm23qBVrP2CmojEUPLSkKrsdt3c8PrsY)FqpVXO0FindvZX0ak7yd6PZgMMpNnzi1GLLzXgQiipggQSU1OFT25KS1MWgoSVSHrZ)GhPxov3mo)ICq7xROALDLtEkn0)WHMaYmwfiJnWf4ITUbKXgOjTpS(Cu9FTQODQE69lP3xfFb1a0KzwB9udaYOB3WqV1vN(OohRbOdJfojYHVOJPxbKVOUKubYG6RQtaziCm0JKfWzUtlqMwnV1q(bdidMy8vbidbCrdazWgnneiJnPNjGmiTTlazWwYsbKr3c8Prs(caYmUPaz0TJzcit95ZgcKXIIafqgYa07ItYwBctbiJTF5g)cbKPzvIe)Wv)f9NvrJmBYD3YoLnSl3)j8Ri27()(d]] )


end