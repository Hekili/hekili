-- HunterSurvival.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

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


    local pheromoneReset = false
    local FindUnitDebuffByID = ns.FindUnitDebuffByID

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function ()
        local _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID and spellID == 259489 and subtype == "SPELL_CAST_SUCCESS" then
            pheromoneReset = FindUnitDebuffByID( "target", 270332 ) and true or false
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


    spec:RegisterHook( "reset_precast", function()
        if talent.wildfire_infusion.enabled then
            if IsActiveSpell( 270335 ) then current_wildfire_bomb = "shrapnel_bomb"
            elseif IsActiveSpell( 270323 ) then current_wildfire_bomb = "pheromone_bomb"
            elseif IsActiveSpell( 271045 ) then current_wildfire_bomb = "volatile_bomb"
            else current_wildfire_bomb = "wildfire_bomb" end
        else
            current_wildfire_bomb = "wildfire_bomb"
        end

        if prev_gcd[1].kill_command and pheromoneReset and ( now - action.kill_command.lastCast < 0.25 ) then
            setCooldown( "kill_command", 0 )
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
            start = function () end,
            impact = function ()
                if buff.mad_bombardier.up then
                    gainCharges( "wildfire_bomb", 1 )
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
            start = function () end,
            impact = function ()
                if buff.mad_bombardier.up then
                    gainCharges( "wildfire_bomb", 1 )
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
            end,

            impact = function ()
                if buff.mad_bombardier.up then
                    gainCharges( "wildfire_bomb", 1 )
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
            end,

            impact = function ()
                if not talent.wildfire_infusion.enabled and buff.mad_bombardier.up then
                    gainCharges( "wildfire_bomb", 1 )
                    removeBuff( "mad_bombardier" )
                end
                if current_wildfire_bomb == "wildfire_bomb" then applyDebuff( "target", "wildfire_bomb_dot" )
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

            copy = 259495, -- { 271045, 270335, 270323, 259495 }
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


    spec:RegisterPack( "Survival", 20220323, [[da1dWcqibQhrQuXLaPInru9jqcJIO4uesRIuP8kffZsGClqsTle)sKyyGKCmr0Yuu9mcbtdKQ6AKkzBeI03ejLgNiP6CGeH1bsvEhHiQmpfLUNa2NiL)bse1bjeHfcs5HeIAIeIOCrcrKAJGer6JGujgjireNeKk1kjv8sqIKzcsu3KqeXojk9tcru1qjerYsjvQ0tjLPks1xbjsnwrsXEf1FjzWqomvlMGhJ0Kf6YO2mu9zfz0IWPLSAqQKEnuA2kCBISBP(TsdxqhNqOLRYZbMoLRdQTdfFNqnErsopPQ1tQu18bX(v15K50ZAr34SSZHQ5ZHkryUiqMlc6AUUMN1m9HCwl0Py9joR1UeN10GpmfgFK1cD9J1J50ZAGf(OCwt35rjmlea9sjLPYsalqORukGscE4wTn9CClfqjrtjRjaxdd6UZczTOBCw25q185qLimxeiZfbDnh6lcznh2sSxwtRKe5SwIkg5olK1ImGM10GpmfgF8iOKa3gFVoIK4hnXJMlcb9O5q185VoVoI82y4ZEe(sHbpAXWh1dFenbtXcEKTp6yqitTh1S4hrhoa8iaBw1tGhLYJGb8JAw8JOjykwf(sHbQfdFup8rCQcpgaQTjzTrbmqo9SgWYPNLnzo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9Whj)rY8OGF05vuXy42iEmciCQkGbEeeipk4hDEfvmgUnIhJacC4JK)OZROIXWTr8yeqIWNB12pAMhDEfvmgUnIhJas1pA2hPRhj6JGa5rNxrfJHBJ4XiGah(i5p68kQymCBepgbKJL8QbpkThb9HQSMtTA7SwKDlHIMWXEUu2YYopNEwJBxyWXm0YAo1QTZAa(c52uaR6PSg9kJVYZAb)O4AeaFHCBkGv9eXkk2QNEK8hz(nXgXkjwzRkw8Js7rP2hbbYJeGXXjyQq(akmCVse4Whj)rcW44emviFafgUxjYXsE1Ghn7JMOXSgvpDWkZVj2azztMTSSIqo9SMtTA7Sg(W1ZrfiXAznUDHbhZqlBzzH(50ZAC7cdoMHwwJELXx5zTGF05vuXy42iEmciCQkGbEeeipk4hDEfvmgUnIhJacC4JK)izE05vuXy42iEmcir4ZTA7hnZJoVIkgd3gXJraP6hn7JMdvpccKhDEfvmgUnIhJacDHB7rbEuYhj6JGa5rNxrfJHBJ4XiGah(i5p68kQymCBepgbKJL8QbpkThb9HQhbbYJewa4rYFKvsSYwvS4hn7JscvznNA12zTJbB7w1tk)UvC2YYQRC6znUDHbhZqlRrVY4R8SwWp68kQymCBepgbeovfWapccKhf8JoVIkgd3gXJrabo8rYF05vuXy42iEmcir4ZTA7hnZJoVIkgd3gXJraP6hn7JMdvpccKhDEfvmgUnIhJacC4JK)OZROIXWTr8yeqowYRg8O0E0CO6rqG8iHfaEK8hzLeRSvfl(rZ(O5qvwZPwTDwtCnIkqyDLbYwwwrAo9Sg3UWGJzOL1Oxz8vEwl4hDEfvmgUnIhJacNQcyGhbbYJOlgU92iDnLWu4o)i5pIU7iUIBI4AevGW6kdqowYRg8iiqEuWpIUy42BJ01uctH78JK)izEuWp68kQymCBepgbe4Whj)rNxrfJHBJ4XiGeHp3QTF0mp68kQymCBepgbKQF0SpseGQhbbYJoVIkgd3gXJrabo8rYF05vuXy42iEmcihl5vdEuApAou9iiqEuWp68kQymCBepgbe4Whj6JGa5rcla8i5pYkjwzRkw8JM9rIauL1CQvBN1O7EXQDJJkhaC4HLTSSP2C6znNA12znS1yOajwlRXTlm4ygAzllBQNtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFupmR5uR2oRHp8gB1tkGDfwoBzzHsKtpR5uR2oR5kj4lYNAXv0BfdYAC7cdoMHw2YYMeQYPN142fgCmdTSg9kJVYZA4WJH6yAc)MyLvs8JM9rZFKU9OjA8rYFeGnLW2WaIv8np1vZdPpccKhjaJJtK8OsyLe8lw8rGdFeeipk4hbytjSnmGyfFZtD18q6JK)izEeo8yOoMMWVjwzLe)OzF0en(iiqEenbtXQWxkmqTy4J6Hps(JK5rnNktjUucRKabZoCRg8JK)O4AeaFHCBkGv9eXkk2QNEK8hfxJa4lKBtbSQNihJFmiHlm4hbbYJAovMsCPewjbsyc(wPT5hj)rb)ibyCCI02t7cyfo8PNah(i5psMhbyZQEcq8XyfRWxkmqTy4J6HpccKhHVuyWJM5ruhyQJN4(rZ(i8LcdisEQEeu)iNA12eS1yOORKK3rc1bM64jUFKU9ir4rI(irFeeipsybGhj)rwjXkBvXIF0Spkju9irZAo1QTZAIRreVowjSsczllBYK50ZAC7cdoMHwwZPwTDwdBngk6kj5DmRrVY4R8SgGnLW2WaIv8np1vZdPps(JIRrctW3kTnRewjbIvuSvp9i5pk4hjaJJtK8OsyLe8lw8rGdZAu90bRm)MydKLnz2YYMCEo9Sg3UWGJzOL1Oxz8vEwZPwHHvCZsfdEuApk5JK)OGF0b3m(Etm50pCSaZhy5dOOBJVWDS6jfWUcldiSicxHHCmR5uR2oRr9ddNTSSjfHC6znUDHbhZqlRrVY4R8SMtTcdR4MLkg8O0EuYhj)rb)OdUz89MyYPF4ybMpWYhqr3gFH7y1tkGDfwgqyreUcd54JK)i6UJ4kUjIRreVowjSsceC4XqDmnHFtSYkj(rP9iqipgkZVj2aps(JK5r0e(nXaf(5uR22hpkThnNORhbbYJIRrajopS5HsyLeiwrXw90JenR5uR2oRjaB0e8PpBzztc9ZPN142fgCmdTSg9kJVYZA0emfRcFPWa1IHpQhM1CQvBN1agZdLDEy2YYMux50ZAC7cdoMHwwZPwTDwtA7PDbSsOmoRrVY4R8SM5dUnIpct4QWJJUThHBxyWXhj)rY8ibyCCI02t7cyfo8PNah(i5psaghNiT90UawHdF6jhl5vdE0SpcFPWGhLYJK5ry8RCHbtKeuhqrxG9iO(ruhyQJN4(rI(iD7rt04JK)OGFKamoorCnIkqyDLbihl5vdEeeipsaghNiT90UawHdF6jhl5vdEK8h1CQmL4sjSscKWe8TsBZps0SgvpDWkZVj2azztMTSSjfP50ZAC7cdoMHwwZPwTDwdBngk6kj5DmRrVY4R8Sgo8yOoMMWVjwzLe)OzF0en(i5pIMGPyv4lfgOwm8r9WSgvpDWkZVj2azztMTSSjtT50ZAC7cdoMHwwZPwTDw78qBpfWUclN1Oxz8vEwtaghNyvOAXvwcwbcz)iaZPyFuGhjcpccKhfxJasCEyZdLWkjqSIIT6PSgvpDWkZVj2azztMTSSjt9C6znUDHbhZqlRrVY4R8SwCnciX5HnpucRKaXkk2QNYAo1QTZAsBpTlGvcLXzllBsOe50ZAC7cdoMHwwZPwTDwdWxi3McyvpL1Oxz8vEw7y8JbjCHb)i5pY8BInIvsSYwvS4hL2JsTpccKhjaJJtWuH8buy4ELiWHznQE6GvMFtSbYYMmBzzNdv50ZAC7cdoMHwwJELXx5zTMtLPexkHvsGasCEyZJhj)r4lfg8O0Eeg)kxyWejb1bu0fyps3E08hj)rX1ia(c52uaR6jYXsE1GhL2J01J0ThnrJps(Jc(ra2ucBddiwX38uxnpKM1CQvBN1exJiEDSsyLeYww25jZPN1CQvBN1OjCSNlbYAC7cdoMHw2YYoFEo9Sg3UWGJzOL1CQvBN1WwJHIUssEhZA0Rm(kpRrtWuSk8Lcdulg(OEywJQNoyL53eBGSSjZww25Iqo9Sg3UWGJzOL1Oxz8vEw7GBgFVjMC6howG5dS8bu0TXx4ow9KcyxHLbeweHRWqoM1CQvBN1exJiEDSsyLeYww25q)C6znUDHbhZqlR5uR2oRjT90UawjugN1Oxz8vEwtaghNiT90UawHdF6jWHpccKhHVuyWJM5ro1QTjyRXqrxjjVJeQdm1XtC)O0Ee(sHbejpvpcQFusD9iiqEuCnciX5HnpucRKaXkk2QNEeeipsaghNiUgrfiSUYaKJL8QbznQE6GvMFtSbYYMmBzzNRRC6znUDHbhZqlR5uR2oRDEOTNcyxHLZAu90bRm)MydKLnz2YYoxKMtpRXTlm4ygAzn6vgFLN1K5rnNktjUucRKabZoCRg8JK)O4AeaFHCBkGv9eXkk2QNEeeipQ5uzkXLsyLeiHj4BL2MFeeipQ5uzkXLsyLeiGeNh284rYFe(sHbpkThPlO6rI(i5pk4hbytjSnmGyfFZtD18qAwZPwTDwtCnI41XkHvsiBzlR1MNtplBYC6znNA12znGX8qzNhM142fgCmdTSLLDEo9Sg3UWGJzOL1Oxz8vEwl4hjaJJtexJOcewxzaYXsE1GhbbYJeGXXjIRrubcRRma5yjVAWJK)i6UJ4kUjyRXqrxjjVJKJL8QbznNA12zn8JzDF1tk78WSLLveYPN142fgCmdTSg9kJVYZAb)ibyCCI4AevGW6kdqowYRg8iiqEKamoorCnIkqyDLbihl5vdEK8hr3DexXnbBngk6kj5DKCSKxniR5uR2oRz(PSZdZw2YArg3Hhwo9SSjZPN142fgCmdTSg9kJVYZAMFtSrwyduro1FK8hbyZQEcqGbSkHFH72ps(JeGXXjoiKPMAXvwcwX(0GjXvCN1CQvBN1s4x4UD2YYopNEwZPwTDwtcw3R7hCwJBxyWXm0YwwwriNEwJBxyWXm0YAo1QTZA25TicxJs3x9KcKyTSwKb0RcTA7Sg0L9rEc2JpY74Js)8weHRrP75hjRiPe5hXnlvmiOhjMFuCBOWEuCFKLOapcFVhfoC98bEKatDya)OYGI4Je4hz7(iqOljP)rEhFKy(ruVHc7rh7XAO)rPFElIpceY0cVOpsaghhqYA0Rm(kpRf8Jm)MyJuav4W1Zx2YYc9ZPN142fgCmdTSMtTA7Sg011G7jUUtfzGvTEGI6JrwJELXx5znNAfgwXnlvm4rbEuYhj)rY8ibyCCcD3lwTBCu5aGdpmcC4JGa5rb)i6UJ4kUj0DVy1UXrLdao8Wihl5vdEeeipsybGhj)rwjXkBvXIF0SpseGQhj6JGa5rY8iNAfgwXnlvm4rP9OKps(JeGXXjhd22TQNu(DRycC4JGa5rcW44e6UxSA34OYbahEye4WhjAwRDjoRbDDn4EIR7urgyvRhOO(yKTSS6kNEwZPwTDwdgWQYyjqwJBxyWXm0YwwwrAo9Sg3UWGJzOL1Oxz8vEwJUy42BJGv)vE)i5pIU7iUIBcD3lwTBCu5aGdpmYXsE1Ghj)r0DhXvCtogSTBvpP87wXKJL8QbpccKhf8JOlgU92iy1FL3ps(JO7oIR4Mq39Iv7ghvoa4WdJCSKxniR5uR2oRr9Xq5uR2wnkGL1gfWuTlXzn7QglBGSLLn1MtpRXTlm4ygAznNA12znQpgkNA12QrbSS2OaMQDjoRrJGSLLn1ZPN142fgCmdTSg9kJVYZAo1kmSIBwQyWJM9rIWJK)iZhCBeH6Ia1IRcpwpHBxyWXSgWUIAzztM1CQvBN1O(yOCQvBRgfWYAJcyQ2L4SMWgMTSSqjYPN142fgCmdTSg9kJVYZAo1kmSIBwQyWJM9rIWJK)OGFK5dUnIqDrGAXvHhRNWTlm4ywdyxrTSSjZAo1QTZAuFmuo1QTvJcyzTrbmv7sCwdyzllBsOkNEwJBxyWXm0YA0Rm(kpR5uRWWkUzPIbpkThnpRbSROww2KznNA12znQpgkNA12QrbSS2OaMQDjoRrhSJHZww2KjZPN1CQvBN18J6nRS9oUTSg3UWGJzOLTSL1cpMUscULtplBYC6znUDHbhZqlRTHznaBfEwJELXx5znZhCBePTN2fWkHYyc3UWGJzTidOxfA12znrEBm8zpcFPWGhTy4J6HpIMGPybpY2hDmiKP2JAw8JOdhaEeGnR6jWJs5rWa(rnl(r0emfRcFPWa1IHpQh(iovHhda12KSgg)uTlXznjb1bu0fyznNA12znm(vUWGZAy8bmR4bGZAo1QTjNhA7Pa2vyzcDbwwdJpG5SMtTABI02t7cyLqzmHUalBzzNNtpR5uR2oRbGLK2wfYwwJBxyWXm0YwwwriNEwZPwTDwtynBWrf(W1ZrXvpPSnvvN142fgCmdTSLLf6NtpR5uR2oRHpyqc654wwJBxyWXm0YwwwDLtpRXTlm4ygAzn6vgFLN1o4MX3BIjGfEGV3eRyjb(aeweHRWqoM1CQvBN1m)u25HzllRinNEwZPwTDwdympu25HznUDHbhZqlBzlRzx1yzdKtplBYC6znUDHbhZqlRTHznaBznNA12znm(vUWGZAy8bmN1eGXXjhd22TQNu(DRycC4JGa5rcW44e6UxSA34OYbahEye4WSgg)uTlXznG(MQGdZww2550ZAC7cdoMHwwBdZAa2YAo1QTZAy8RCHbN1W4dyoRrxmC7TrWQ)kVFK8hjaJJtogSTBvpP87wXe4Whj)rcW44e6UxSA34OYbahEye4WhbbYJc(r0fd3EBeS6VY7hj)rcW44e6UxSA34OYbahEye4WSgg)uTlXznGDBpPa6BQcomBzzfHC6znUDHbhZqlRTHznaBfEwZPwTDwdJFLlm4Sgg)uTlXznGDBpPa6BQ6yjVAqwJELXx5znbyCCcD3lwTBCu5aGdpmsCf3znm(aMv8aWzn6UJ4kUj0DVy1UXrLdao8Wihl5vdutWmaK1W4dyoRr3DexXn5yW2Uv9KYVBftowYRg8OzHs(r0DhXvCtO7EXQDJJkhaC4HrowYRgOMGzaiBzzH(50ZAC7cdoMHwwBdZAa2k8SMtTA7Sgg)kxyWznm(PAxIZAa72Esb03u1XsE1GSg9kJVYZAcW44e6UxSA34OYbahEye4WSggFaZkEa4SgD3rCf3e6UxSA34OYbahEyKJL8QbQjygaYAy8bmN1O7oIR4MCmyB3QEs53TIjhl5vdYwwwDLtpRXTlm4ygAzTnmRbyRWZAo1QTZAy8RCHbN1W4NQDjoRb03u1XsE1GSg9kJVYZA0fd3EBeS6VY7SggFaZkEa4SgD3rCf3e6UxSA34OYbahEyKJL8QbQjygaYAy8bmN1O7oIR4MCmyB3QEs53TIjhl5vdEuAqj)i6UJ4kUj0DVy1UXrLdao8Wihl5vdutWmaKTSSI0C6znUDHbhZqlR5uR2oRzx1yzlzwJELXx5znzEKmpYUQXYgXsss4afmGvcW44pccKhrxmC7TrWQ)kVFK8hzx1yzJyjjjCGIU7iUI7hj6JK)izEeg)kxyWeGDBpPa6BQco8rYFKmpk4hrxmC7TrWQ)kVFK8hf8JSRASSrS5KeoqbdyLamo(JGa5r0fd3EBeS6VY7hj)rb)i7QglBeBojHdu0DhXvC)iiqEKDvJLnInNq3DexXn5yjVAWJGa5r2vnw2iwsschOGbSsagh)rYFKmpk4hzx1yzJyZjjCGcgWkbyC8hbbYJSRASSrSKe6UJ4kUjr4ZTA7hLwGhzx1yzJyZj0DhXvCtIWNB12ps0hbbYJSRASSrSKKeoqr3DexX9JK)OGFKDvJLnInNKWbkyaReGXXFK8hzx1yzJyjj0DhXvCtIWNB12pkTapYUQXYgXMtO7oIR4MeHp3QTFKOpccKhf8JW4x5cdMaSB7jfqFtvWHps(JK5rb)i7QglBeBojHduWawjaJJ)i5psMhzx1yzJyjj0DhXvCtIWNB12pcQFKUE0SpcJFLlmycqFtvhl5vdEeeipcJFLlmycqFtvhl5vdEuApYUQXYgXssO7oIR4MeHp3QTFukpA(Je9rqG8i7QglBeBojHduWawjaJJ)i5psMhzx1yzJyjjjCGcgWkbyC8hj)r2vnw2iwscD3rCf3Ki85wT9JslWJSRASSrS5e6UJ4kUjr4ZTA7hj)rY8i7QglBeljHU7iUIBse(CR2(rq9J01JM9ry8RCHbta6BQ6yjVAWJGa5ry8RCHbta6BQ6yjVAWJs7r2vnw2iwscD3rCf3Ki85wT9Js5rZFKOpccKhjZJc(r2vnw2iwsschOGbSsagh)rqG8i7QglBeBoHU7iUIBse(CR2(rPf4r2vnw2iwscD3rCf3Ki85wT9Je9rYFKmpYUQXYgXMtO7oIR4MCSh1)i5pYUQXYgXMtO7oIR4MeHp3QTFeu)iD9O0Eeg)kxyWeG(MQowYRg8i5pcJFLlmycqFtvhl5vdE0SpYUQXYgXMtO7oIR4MeHp3QTFukpA(JGa5rb)i7QglBeBoHU7iUIBYXEu)JK)izEKDvJLnInNq3DexXn5yjVAWJG6hPRhn7JW4x5cdMaSB7jfqFtvhl5vdEK8hHXVYfgmby32tkG(MQowYRg8O0E0CO6rYFKmpYUQXYgXssO7oIR4MeHp3QTFeu)iD9OzFeg)kxyWeG(MQowYRg8iiqEKDvJLnInNq3DexXn5yjVAWJG6hPRhn7JW4x5cdMa03u1XsE1Ghj)r2vnw2i2CcD3rCf3Ki85wT9JG6hLeQE0mpcJFLlmycqFtvhl5vdE0SpcJFLlmycWUTNua9nvDSKxn4rqG8im(vUWGja9nvDSKxn4rP9i7QglBeljHU7iUIBse(CR2(rP8O5pccKhHXVYfgmbOVPk4Whj6JGa5r2vnw2i2CcD3rCf3KJL8QbpcQFKUEuApcJFLlmycWUTNua9nvDSKxn4rYFKmpYUQXYgXssO7oIR4MeHp3QTFeu)iD9OzFeg)kxyWeGDBpPa6BQ6yjVAWJGa5r2vnw2iwscD3rCf3Ki85wT9JM9r41uctDSKxn4rYFeg)kxyWeGDBpPa6BQ6yjVAWJM5r2vnw2iwscD3rCf3Ki85wT9Js7r41uctDSKxn4rqG8OGFKDvJLnILKKWbkyaReGXXFK8hjZJW4x5cdMa03u1XsE1GhL2JSRASSrSKe6UJ4kUjr4ZTA7hLYJM)iiqEeg)kxyWeG(MQGdFKOps0hj6Je9rI(irFeeipY8BInIvsSYwvS4hn7JW4x5cdMa03u1XsE1Ghj6JGa5rb)i7QglBeljjHduWawjaJJ)i5pk4hrxmC7TrWQ)kVFK8hjZJSRASSrS5KeoqbdyLamo(JK)izEKmpk4hHXVYfgmbOVPk4WhbbYJSRASSrS5e6UJ4kUjhl5vdEuApsxps0hj)rY8im(vUWGja9nvDSKxn4rP9O5q1JGa5r2vnw2i2CcD3rCf3KJL8QbpcQFKUEuApcJFLlmycqFtvhl5vdEKOps0hbbYJc(r2vnw2i2CschOGbSsagh)rYFKmpk4hzx1yzJyZjjCGIU7iUI7hbbYJSRASSrS5e6UJ4kUjhl5vdEeeipYUQXYgXMtO7oIR4MeHp3QTFuAbEKDvJLnILKq3DexXnjcFUvB)irFKOps0hj)rY8OGFKDvJLnILKuac1Pjy1IRCQicxhhv2Xoa(yWJGa5ro1kmSIBwQyWJM9rZFK8hjaJJtCQicxhhvI9osGdFeeipYPwHHvCZsfdEuApk5JK)OGFKamooXPIiCDCuj27ibo8rIM1aJ1azn7QglBjZww2uBo9Sg3UWGJzOL1CQvBN1SRASSnpRrVY4R8SMmpsMhzx1yzJyZjjCGcgWkbyC8hbbYJOlgU92iy1FL3ps(JSRASSrS5Keoqr3DexX9Je9rYFKmpcJFLlmycWUTNua9nvbh(i5psMhf8JOlgU92iy1FL3ps(Jc(r2vnw2iwsschOGbSsagh)rqG8i6IHBVncw9x59JK)OGFKDvJLnILKKWbk6UJ4kUFeeipYUQXYgXssO7oIR4MCSKxn4rqG8i7QglBeBojHduWawjaJJ)i5psMhf8JSRASSrSKKeoqbdyLamo(JGa5r2vnw2i2CcD3rCf3Ki85wT9JslWJSRASSrSKe6UJ4kUjr4ZTA7hj6JGa5r2vnw2i2CschOO7oIR4(rYFuWpYUQXYgXsss4afmGvcW44ps(JSRASSrS5e6UJ4kUjr4ZTA7hLwGhzx1yzJyjj0DhXvCtIWNB12ps0hbbYJc(ry8RCHbta2T9KcOVPk4Whj)rY8OGFKDvJLnILKKWbkyaReGXXFK8hjZJSRASSrS5e6UJ4kUjr4ZTA7hb1psxpA2hHXVYfgmbOVPQJL8QbpccKhHXVYfgmbOVPQJL8QbpkThzx1yzJyZj0DhXvCtIWNB12pkLhn)rI(iiqEKDvJLnILKKWbkyaReGXXFK8hjZJSRASSrS5KeoqbdyLamo(JK)i7QglBeBoHU7iUIBse(CR2(rPf4r2vnw2iwscD3rCf3Ki85wT9JK)izEKDvJLnInNq3DexXnjcFUvB)iO(r66rZ(im(vUWGja9nvDSKxn4rqG8im(vUWGja9nvDSKxn4rP9i7QglBeBoHU7iUIBse(CR2(rP8O5ps0hbbYJK5rb)i7QglBeBojHduWawjaJJ)iiqEKDvJLnILKq3DexXnjcFUvB)O0c8i7QglBeBoHU7iUIBse(CR2(rI(i5psMhzx1yzJyjj0DhXvCto2J6FK8hzx1yzJyjj0DhXvCtIWNB12pcQFKUEuApcJFLlmycqFtvhl5vdEK8hHXVYfgmbOVPQJL8QbpA2hzx1yzJyjj0DhXvCtIWNB12pkLhn)rqG8OGFKDvJLnILKq3DexXn5ypQ)rYFKmpYUQXYgXssO7oIR4MCSKxn4rq9J01JM9ry8RCHbta2T9KcOVPQJL8Qbps(JW4x5cdMaSB7jfqFtvhl5vdEuApAou9i5psMhzx1yzJyZj0DhXvCtIWNB12pcQFKUE0SpcJFLlmycqFtvhl5vdEeeipYUQXYgXssO7oIR4MCSKxn4rq9J01JM9ry8RCHbta6BQ6yjVAWJK)i7QglBeljHU7iUIBse(CR2(rq9JscvpAMhHXVYfgmbOVPQJL8QbpA2hHXVYfgmby32tkG(MQowYRg8iiqEeg)kxyWeG(MQowYRg8O0EKDvJLnInNq3DexXnjcFUvB)OuE08hbbYJW4x5cdMa03ufC4Je9rqG8i7QglBeljHU7iUIBYXsE1Ghb1psxpkThHXVYfgmby32tkG(MQowYRg8i5psMhzx1yzJyZj0DhXvCtIWNB12pcQFKUE0SpcJFLlmycWUTNua9nvDSKxn4rqG8i7QglBeBoHU7iUIBse(CR2(rZ(i8AkHPowYRg8i5pcJFLlmycWUTNua9nvDSKxn4rZ8i7QglBeBoHU7iUIBse(CR2(rP9i8AkHPowYRg8iiqEuWpYUQXYgXMts4afmGvcW44ps(JK5ry8RCHbta6BQ6yjVAWJs7r2vnw2i2CcD3rCf3Ki85wT9Js5rZFeeipcJFLlmycqFtvWHps0hj6Je9rI(irFKOpccKhz(nXgXkjwzRkw8JM9ry8RCHbta6BQ6yjVAWJe9rqG8OGFKDvJLnInNKWbkyaReGXXFK8hf8JOlgU92iy1FL3ps(JK5r2vnw2iwsschOGbSsagh)rYFKmpsMhf8JW4x5cdMa03ufC4JGa5r2vnw2iwscD3rCf3KJL8QbpkThPRhj6JK)izEeg)kxyWeG(MQowYRg8O0E0CO6rqG8i7QglBeljHU7iUIBYXsE1Ghb1psxpkThHXVYfgmbOVPQJL8Qbps0hj6JGa5rb)i7QglBeljjHduWawjaJJ)i5psMhf8JSRASSrSKKeoqr3DexX9JGa5r2vnw2iwscD3rCf3KJL8QbpccKhzx1yzJyjj0DhXvCtIWNB12pkTapYUQXYgXMtO7oIR4MeHp3QTFKOps0hj6JK)izEuWpYUQXYgXMtkaH60eSAXvoveHRJJk7yhaFm4rqG8iNAfgwXnlvm4rZ(O5ps(JeGXXjoveHRJJkXEhjWHpccKh5uRWWkUzPIbpkThL8rYFuWpsaghN4ureUooQe7DKah(irZAGXAGSMDvJLT5zllBQNtpRXTlm4ygAzT2L4Sg011G7jUUtfzGvTEGI6JrwZPwTDwd66AW9ex3PImWQwpqr9XiBzlRrJGC6zztMtpRXTlm4ygAzn6vgFLN1mFWTrm(KaQfxX9KpXsCBeUDHbhFK8hHVuyWJM9r4lfgqK8uL1CQvBN1s4x4UD2YYopNEwJBxyWXm0YA0Rm(kpRjaJJtO7EXQDJJkhaC4HrGdZAo1QTZAcJDJkC4tF2YYkc50ZAC7cdoMHwwJELXx5znbyCCcD3lwTBCu5aGdpmcCywZPwTDwZBkdSZhkQpgzlll0pNEwJBxyWXm0YA0Rm(kpRjaJJtO7EXQDJJkhaC4HrGdZAo1QTZA41XcJDJzllRUYPN1CQvBN1g1ucdOGUchNK42YAC7cdoMHw2YYksZPN142fgCmdTSg9kJVYZA0DhXvCtWwJHIUssEhj4WJH6yAc)MyLvs8Js7rt0ywZPwTDwtWNulUYUIIfKTSSP2C6znUDHbhZqlRrVY4R8SMamooHU7fR2noQCaWHhgbo8rqG8iRKyLTQyXpA2hLueYAo1QTZAc8b4dB1tzllBQNtpR5uR2oRjbR719doRXTlm4ygAzllluIC6znUDHbhZqlRrVY4R8SMWcaps(JWRPeM6yjVAWJM9rZ11JGa5rcW44e6UxSA34OYbahEye4WSMtTA7Sw4A12zllBsOkNEwJBxyWXm0YA0Rm(kpRjZJWxkm4rZ(Oulu9iiqEeD3rCf3e6UxSA34OYbahEyKJL8QbpA2hnrJps0hj)rY8iWcpeQoscHbg8Gv8bhA12eUDHbhFeeipcSWdHQJem7WTAWkWoWWTr42fgC8rYFKamoobZoCRgScSdmCBK4kUFKOznNA12zn8bdsqph3YAvB8DWHMQWZA0eE38O6j5bdw4Hq1rsimWGhSIp4qR2oBzztMmNEwJBxyWXm0YA0Rm(kpRrtWuSk8Lcdulg(OE4JK)OdUz89MycyHh47nXkwsGpaHfr4kmKJps(Jm)u25HKJL8QbpA2hnrJps(JO7oIR4MGp8Jjhl5vdE0SpAIgFK8hjZJCQvyyf3SuXGhL2Js(iiqEKtTcdR4MLkg8Oapk5JK)iRKyLTQyXpkThPRhPBpAIgFKOznNA12znZpLDEy2YYMCEo9Sg3UWGJzOL1CQvBN1Wh(Xzn6vgFLN1Ojykwf(sHbQfdFup8rYFK5NYopKah(i5p6GBgFVjMaw4b(EtSILe4dqyreUcd54JK)iRKyLTQyXpkThb9FKU9OjAmRnQMv0ywBUUYww2KIqo9Sg3UWGJzOL1Oxz8vEwZPwHHvCZsfdEuGhL8rYFK53eBeRKyLTQyXpA2hHVuyWJs5rY8im(vUWGjscQdOOlWEeu)iQdm1XtC)irFKU9OjAmR5uR2oRHTgdfiXAzllBsOFo9Sg3UWGJzOL1Oxz8vEwZPwHHvCZsfdEuGhL8rYFK53eBeRKyLTQyXpA2hHVuyWJs5rY8im(vUWGjscQdOOlWEeu)iQdm1XtC)irFKU9OjAmR5uR2oRjT90UawjugNTSSj1vo9Sg3UWGJzOL1Oxz8vEwZPwHHvCZsfdEuGhL8rYFK53eBeRKyLTQyXpA2hHVuyWJs5rY8im(vUWGjscQdOOlWEeu)iQdm1XtC)irFKU9OjAmR5uR2oRDEOTNcyxHLZww2KI0C6znUDHbhZqlRrVY4R8SM53eBKybmVP8JslWJePznNA12znheYutT4klbRyFAWzlBznHnmNEw2K50ZAC7cdoMHwwZPwTDwdWxi3McyvpL1Oxz8vEwtaghNGPc5dOWW9krowYRg8i5psMhjaJJtWuH8buy4ELihl5vdE0SpAIgFeeip6y8JbjCHb)irZAu90bRm)MydKLnz2YYopNEwJBxyWXm0YAo1QTZAyRXqrxjjVJzn6vgFLN1Ojykwf(sHbQfdFup8rYFKamooPzq1tI9tpqzNhgw9KYdd9Znyabo8rqG8izEeGnR6jaXhJvScFPWa1IHpQh(iiqEe(sHbpAMhrDGPoEI7hn7JWxkmGi5P6rZ8OKq1Je9rYFKamooPzq1tI9tpqzNhgw9KYdd9Znyabo8rYFKamooPzq1tI9tpqzNhgw9KYdd9Znya5yjVAWJM9rt0ywJQNoyL53eBGSSjZwwwriNEwZPwTDwdBngkqI1YAC7cdoMHw2YYc9ZPN142fgCmdTSg9kJVYZA0emfRcFPWa1IHpQh(i5pchEmuhtt43eRSsIF0SpAIgFeeipsaghNi5rLWkj4xS4JahM1CQvBN1exJiEDSsyLeYwwwDLtpRXTlm4ygAzn6vgFLN1Ojykwf(sHbQfdFupmR5uR2oRHp8gB1tkGDfwoBzzfP50ZAo1QTZA4dxphvGeRL142fgCmdTSLLn1MtpRXTlm4ygAzn6vgFLN1o4MX3BIjndavpj2p9aLDEyy1tkpm0p3GbeweHRWqo(i5pcFPWGhn7JW4x5cdMijOoGIUalRbSROww2KznNA12znQpgkNA12QrbSS2OaMQDjoR1MNTSSPEo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9WSMtTA7SwKDlHIMWXEUu2YYcLiNEwJBxyWXm0YAo1QTZANhA7Pa2vy5Sg9kJVYZAcW44e6UxSA34OYbahEye4Whj)rcW44e6UxSA34OYbahEyKJL8QbpA2hLKORhPBpAIgZAu90bRm)MydKLnz2YYMeQYPN142fgCmdTSMtTA7SM02t7cyLqzCwJELXx5znbyCCcD3lwTBCu5aGdpmcC4JK)ibyCCcD3lwTBCu5aGdpmYXsE1Ghn7Jss01J0ThnrJznQE6GvMFtSbYYMmBzztMmNEwZPwTDwZvsWxKp1IRO3kgK142fgCmdTSLLn58C6znUDHbhZqlR5uR2oRDEOTNcyxHLZA0Rm(kpRjaJJtSkuT4klbRaHSFeG5uSpkWJeHSgvpDWkZVj2azztMTSSjfHC6znUDHbhZqlR5uR2oRjT90UawjugN1Oxz8vEwZ8b3gXhHjCv4Xr32JWTlm44JK)izEKamoorA7PDbSch(0tGdFK8hjaJJtK2EAxaRWHp9KJL8QbpA2hHVuyWJs5rY8im(vUWGjscQdOOlWEeu)iQdm1XtC)irFKU9OjA8rIM1O6Pdwz(nXgilBYSLLnj0pNEwJBxyWXm0YA0Rm(kpRrtWuSk8Lcdulg(OE4JK)OGFKvuSvp9i5psMhHdpgQJPj8BIvwjXpA2hnrJpccKhf8JIRrexJiEDSsyLeiwrXw90JK)ibyCCI02t7cyfo8PNCSKxn4rP9iC4XqDmnHFtSYkj(rq9Js(iD7rt04JGa5rb)O4AeX1iIxhRewjbIvuSvp9i5pk4hjaJJtK2EAxaRWHp9KJL8Qbps0hbbYJSsIv2QIf)OzFuYu)rYFuWpkUgrCnI41XkHvsGyffB1tznNA12znX1iIxhRewjHSLLnPUYPN142fgCmdTSMtTA7Sg2Amu0vsY7ywJQNoyL53eBGSSjZA0Rm(kpRrtWuSk8Lcdulg(OE4JK)izEuWp6GBgFVjM0mau9Ky)0du25HHvpP8Wq)Cdgq42fgC8rqG8i8LcdE0SpcJFLlmyIKG6ak6cShjAwlYa6vHwTDwd6g)r6x4hf3gkShLWXWpswgaQEsSF6HcWJs)8WWQNEKiryOFUbdc6rGskCO)ruhypckvngpsKxjjVJpQWFK(f(rI3gkShTy4J6HpA7hbL0LcdEe(TspkUvp9iWsEe0n(J0VWpkUpkHJHFKSmau9Ky)0dfGhL(5HHvp9irIWq)Cdg8i9l8Jajw4r8ruhypckvngpsKxjjVJpQWFK(f(Ee(sHbpQapsGhR4hzj4hrxG9Of)rIKS90Ua(rqRm(r79iDxp027rA2vy5SLLnPinNEwJBxyWXm0YAo1QTZAyRXqrxjjVJznQE6GvMFtSbYYMmRrVY4R8SgnbtXQWxkmqTy4J6Hps(Jo4MX3BIjndavpj2p9aLDEyy1tkpm0p3GbeUDHbhFK8hr3DexXnb)yw3x9KYopKCSKxn4rP9izEe(sHbpkLhjZJW4x5cdMijOoGIUa7rq9JOoWuhpX9Je9r62JMOXhj6JK)i6UJ4kUjMFk78qYXsE1GhL2JK5r4lfg8OuEKmpcJFLlmyIKG6ak6cShb1pI6atD8e3ps0hPBpAIgFKOps(JK5rb)iZhCBeGX8qzNhs42fgC8rqG8iZhCBeGX8qzNhs42fgC8rYFeD3rCf3eGX8qzNhsowYRg8O0EKmpcFPWGhLYJK5ry8RCHbtKeuhqrxG9iO(ruhyQJN4(rI(iD7rt04Je9rIM1ImGEvOvBN1GsxwIhjldavpj2p9qb4rPFEyy1tpsKim0p3GbpA7H(hbLQgJhjYRKK3Xhv4ps)cFpYope8i)4hT9JO7oIR4oOhTwc(exa(raBdFemO6PhbLQgJhjYRKK3Xhv4ps)cFpIcFh32JWxkm4rU0c32JkWJ4EHNs8iBFeagyE1pYsWpYLw42E0I)iRK4hnyC7r479iV1)Of)r6x47r25HGhz7JORe)Ofh)r0DhXvCNTSSjtT50ZAC7cdoMHwwJELXx5znAcMIvHVuyGAXWh1dZAo1QTZAaJ5HYopmBzztM650ZAC7cdoMHwwZPwTDwdWxi3McyvpL1Oxz8vEwlUgbWxi3Mcyvprog)yqcxyWps(Jc(rcW44e6UxSA34OYbahEye4WhbbYJmFWTr8rycxfEC0T9iC7cdo(i5p6y8JbjCHb)i5pk4hjaJJtK2EAxaRWHp9e4WSgvpDWkZVj2azztMTSSjHsKtpR5uR2oRDmyB3QEs53TIZAC7cdoMHw2YYohQYPN1CQvBN1exJOcewxzGSg3UWGJzOLTSSZtMtpRXTlm4ygAzn6vgFLN1c(rcW44e6UxSA34OYbahEye4WSMtTA7SgD3lwTBCu5aGdpSSLLD(8C6znUDHbhZqlRrVY4R8SMamoorA7PDbSch(0tGdFeeipcFPWGhnZJCQvBtWwJHIUssEhjuhyQJN4(rP9i8LcdisEQEeeipsaghNq39Iv7ghvoa4WdJahM1CQvBN1K2EAxaRekJZww25Iqo9Sg3UWGJzOL1CQvBN1op02tbSRWYznQE6GvMFtSbYYMmBzzNd9ZPN142fgCmdTSg9kJVYZAX1iIRreVowjSscKJXpgKWfgCwZPwTDwtCnI41XkHvsiBzzNRRC6znUDHbhZqlR5uR2oRb4lKBtbSQNYA0Rm(kpRjaJJtWuH8buy4ELiWHznQE6GvMFtSbYYMmBzlRrhSJHZPNLnzo9Sg3UWGJzOL1CQvBN1a8fYTPaw1tzn6vgFLN1mFWTrsOpEoqjugt42fgC8rYFKamoobtfYhqHH7vICSKxn4rYFKamoobtfYhqHH7vICSKxn4rZ(OjAmRr1thSY8BInqw2Kzll78C6znUDHbhZqlRrVY4R8SwWp68kQymCBepgbeovfWapccKhDEfvmgUnIhJaYXsE1GhLwGhLeQEeeipYPwHHvCZsfdEuAbE05vuXy42iEmci0fUThPBpAEwZPwTDwtCnIkqyDLbYwwwriNEwJBxyWXm0YA0Rm(kpRf8JoVIkgd3gXJraHtvbmWJGa5rNxrfJHBJ4XiGCSKxn4rPf4rP(JGa5ro1kmSIBwQyWJslWJoVIkgd3gXJraHUWT9iD7rZZAo1QTZAhd22TQNu(DR4SLLf6NtpRXTlm4ygAzn6vgFLN1c(rNxrfJHBJ4XiGWPQag4rqG8OZROIXWTr8yeqowYRg8O0c8OKq1JGa5ro1kmSIBwQyWJslWJoVIkgd3gXJraHUWT9iD7rZZAo1QTZA0DVy1UXrLdao8WYwwwDLtpRXTlm4ygAzn6vgFLN1WHhd1X0e(nXkRK4hn7JMOXSMtTA7SM4AeXRJvcRKq2YYksZPN142fgCmdTSg9kJVYZAY8OGF05vuXy42iEmciCQkGbEeeip68kQymCBepgbKJL8QbpkThPRhbbYJCQvyyf3SuXGhLwGhDEfvmgUnIhJacDHB7r62JM)irFeeipIMGPyv4lfgOwm8r9Whj)rb)OdUz89MyIGpPwCLeCxwTnGWIiCfgYXSMtTA7SwKDlHIMWXEUu2YYMAZPN142fgCmdTSg9kJVYZAhCZ47nXKMbGQNe7NEGYopmS6jLhg6NBWaclIWvyihFK8hHVuyWJM9ry8RCHbtKeuhqrxGL1a2vullBYSMtTA7Sg1hdLtTAB1OawwBuat1UeN1AZZww2upNEwZPwTDwJMWXEUeiRXTlm4ygAzllluIC6znUDHbhZqlRrVY4R8SwCnciX5HnpucRKaXkk2QNEK8hjZJIRrQ24R9HsyWCS6jcWCk2hn7JM)iiqEuCnciX5HnpucRKa5yjVAWJM9rt04JenR5uR2oRjaB0e8PpBzztcv50ZAC7cdoMHwwJELXx5zT4AeqIZdBEOewjbIvuSvp9i5pk4hbytjSnmGyfFZtD18qAwZPwTDwJ6hgoBzztMmNEwJBxyWXm0YA0Rm(kpRrt43edu4NtTABF8O0E0CIUEK8hr3DexXnrCnI41XkHvsGGdpgQJPj8BIvwjXpkThbc5Xqz(nXg4rP8O5znNA12znbyJMGp9zllBY550ZAC7cdoMHwwJELXx5znAcMIvHVuyGAXWh1dZAo1QTZA4dVXw9KcyxHLZww2KIqo9Sg3UWGJzOL1Oxz8vEwJU7iUIBI4AeXRJvcRKabhEmuhtt43eRSsIFuApceYJHY8BInWJs5rZZAo1QTZAu)WWzllBsOFo9Sg3UWGJzOL1Oxz8vEwtaghNi5rLWkj4xS4JahM1CQvBN1exJiEDSsyLeYww2K6kNEwJBxyWXm0YAo1QTZAyRXqrxjjVJzn6vgFLN1IRrctW3kTnRewjbIvuSvp9i5pcWMsyByaXk(MN6Q5H0SgvpDWkZVj2azztMTSSjfP50ZAC7cdoMHwwJELXx5znbyCCc(W1Zhqj5hwcCywZPwTDwdBngkqI1Yww2KP2C6znUDHbhZqlR5uR2oRHpC9CubsSwwJQNoyL53eBGSSjZww2KPEo9Sg3UWGJzOL1CQvBN1a8fYTPaw1tzn6vgFLN1og)yqcxyWps(Jc(rwrXw90JK)OMtLPexkHvsGGzhUvd(rYFK53eBeRKyLTQyXpkThLuxps(JWxkm4rZ8iQdm1XtC)O0EKiORhj)ro1kmSIBwQyWJMnWJG(znQE6GvMFtSbYYMmBzztcLiNEwJBxyWXm0YAo1QTZAyRXqrxjjVJzn6vgFLN1Ojykwf(sHbQfdFup8rYFeo8yOoMMWVjwzLe)OzF0en(i5psMhDWnJV3etAgaQEsSF6bk78WWQNuEyOFUbdiSicxHHC8rYFeD3rCf3e8JzDF1tk78qYXsE1Ghj)r0DhXvCtm)u25HKJL8QbpccKhf8Jo4MX3BIjndavpj2p9aLDEyy1tkpm0p3GbeweHRWqo(irZAu90bRm)MydKLnz2YYohQYPN142fgCmdTSg9kJVYZAb)O4AeX1iIxhRewjbIvuSvp9i5pk4hbytjSnmGyfFZtD18q6JGa5r0e(nXaf(5uR22hpkThLKicznNA12znX1iIxhRewjHSLLDEYC6znUDHbhZqlRrVY4R8SMmpk4h1CQmL4sjSsceqIZdBE8iiqEuWpY8b3grCnI41XQQXHb12eUDHbhFKOps(JO7oIR4MiUgr86yLWkjqWHhd1X0e(nXkRK4hL2JaH8yOm)Myd8OuE08SMtTA7SMaSrtWN(SLLD(8C6znNA12znxjbFr(ulUIERyqwJBxyWXm0Yww25Iqo9Sg3UWGJzOL1Oxz8vEwJMGPyv4lfgOwm8r9WSMtTA7SgWyEOSZdZww25q)C6znUDHbhZqlR5uR2oRb4lKBtbSQNYA0Rm(kpRDm(XGeUWGFK8hz(GBJKqF8CGsOmMWTlm44JK)iZVj2iwjXkBvXIFuApk1ZAu90bRm)MydKLnz2YYoxx50ZAo1QTZAu)WWznUDHbhZqlBzzNlsZPN142fgCmdTSMtTA7Sg2Amu0vsY7ywJELXx5znAcMIvHVuyGAXWh1dFK8hjZJo4MX3BIjndavpj2p9aLDEyy1tkpm0p3GbeweHRWqo(i5pIU7iUIBc(XSUV6jLDEi5yjVAWJK)i6UJ4kUjMFk78qYXsE1GhbbYJc(rhCZ47nXKMbGQNe7NEGYopmS6jLhg6NBWaclIWvyihFKOznQE6GvMFtSbYYMmBzzNNAZPN1CQvBN1WwJHcKyTSg3UWGJzOLTSSZt9C6znUDHbhZqlR5uR2oRb4lKBtbSQNYA0Rm(kpRDm(XGeUWGZAu90bRm)MydKLnz2YYohkro9Sg3UWGJzOL1CQvBN1K2EAxaRekJZAu90bRm)MydKLnz2YYkcqvo9Sg3UWGJzOL1CQvBN1op02tbSRWYznQE6GvMFtSbYYMmBzlBznm8bQTZYohQMphQeHKPEwtSFD1tGSguArcDxzHULf6c07rpk9e8JkPW9ShHV3JGc7QglBaO4rhlIW1XXhbwj(roSTsUXXhrt49ediVoq5Q5hjsHEpsK3gdFghFKwjjYpcOVnpvpc68iBFeug2FuSWuGA7hTH852EpsMue9rYORujk51bkxn)irk07rI82y4Z44JGc7QglBKKKudu8iBFeuyx1yzJyjjPgO4rYmh6NkrjVoq5Q5hjsHEpsK3gdFghFeuyx1yzJmNKAGIhz7JGc7QglBeBoj1afpsM5I0ujk51bkxn)Oul07rI82y4Z44J0kjr(ra9T5P6rqNhz7JGYW(JIfMcuB)OnKp327rYKIOpsgDLkrjVoq5Q5hLAHEpsK3gdFghFeuyx1yzJKKKAGIhz7JGc7QglBeljj1afpsM5I0ujk51bkxn)Oul07rI82y4Z44JGc7QglBK5Kudu8iBFeuyx1yzJyZjPgO4rYmh6NkrjVoVoqPfj0DLf6wwOlqVh9O0tWpQKc3ZEe(EpckcpMUscUbfp6yreUoo(iWkXpYHTvYno(iAcVNya51bkxn)OKqVhjYBJHpJJpckmFWTrsnqXJS9rqH5dUnsQHWTlm4iu8i3EKiPfjpu(rYKmvIsEDEDGslsO7kl0TSqxGEp6rPNGFujfUN9i89EeuamO4rhlIW1XXhbwj(roSTsUXXhrt49ediVoq5Q5hLuxqVhjYBJHpJJpsRKe5hb03MNQhbDEKTpckd7pkwykqT9J2q(CBVhjtkI(izsMkrjVoVoqPfj0DLf6wwOlqVh9O0tWpQKc3ZEe(EpckOrau8OJfr4644JaRe)ih2wj344JOj8EIbKxhOC18JscvqVhjYBJHpJJpckal8qO6ij1afpY2hbfGfEiuDKKAiC7cdocfpsM5PsuYRduUA(rjfbO3Je5TXWNXXhPvsI8Ja6BZt1JGopY2hbLH9hflmfO2(rBiFUT3JKjfrFKmjtLOKxhOC18Jsc9HEpsK3gdFghFKwjjYpcOVnpvpc68iBFeug2FuSWuGA7hTH852EpsMue9rYKmvIsEDGYvZpkPUGEpsK3gdFghFKwjjYpcOVnpvpc68iBFeug2FuSWuGA7hTH852EpsMue9rYKmvIsEDEDGslsO7kl0TSqxGEp6rPNGFujfUN9i89EeuiSHqXJoweHRJJpcSs8JCyBLCJJpIMW7jgqEDGYvZpkPia9EKiVng(mo(iTssKFeqFBEQEe05r2(iOmS)OyHPa12pAd5ZT9EKmPi6JKjzQeL86aLRMFusDb9EKiVng(mo(iO4GBgFVjMKAGIhz7JGIdUz89MysQHWTlm4iu8izsMkrjVoq5Q5hLuKc9EKiVng(mo(iTssKFeqFBEQEe05r2(iOmS)OyHPa12pAd5ZT9EKmPi6JKresLOKxhOC18JsksHEpsK3gdFghFeuy(GBJKAGIhz7JGcZhCBKudHBxyWrO4rYmpvIsEDGYvZpkPif69irEBm8zC8rqXb3m(Etmj1afpY2hbfhCZ47nXKudHBxyWrO4rYKmvIsEDGYvZpkzQd9EKiVng(mo(iOW8b3gj1afpY2hbfMp42iPgc3UWGJqXJKjzQeL8686aLwKq3vwOBzHUa9E0Jspb)OskCp7r479iOGoyhddfp6yreUoo(iWkXpYHTvYno(iAcVNya51bkxn)OKjHEpsK3gdFghFKwjjYpcOVnpvpc68iBFeug2FuSWuGA7hTH852EpsMue9rYKmvIsEDGYvZpkPia9EKiVng(mo(iTssKFeqFBEQEe05r2(iOmS)OyHPa12pAd5ZT9EKmPi6JKjzQeL86aLRMF08KqVhjYBJHpJJpsRKe5hb03MNQhbDEKTpckd7pkwykqT9J2q(CBVhjtkI(izsMkrjVoVoq3sH7zC8rP(JCQvB)Orbma51jRbczAw256sxzTWBXRbN10DEKg8HPW4JhbLe42471r35rIK4hnXJMlcb9O5q185VoVo6opsK3gdF2JWxkm4rlg(OE4JOjykwWJS9rhdczQ9OMf)i6WbGhbyZQEc8OuEemGFuZIFenbtXQWxkmqTy4J6HpItv4XaqTn5151XPwTnGeEmDLeCBMaPGXVYfgCqTlXbKeuhqrxGf0ggaWwHhegFaZbCQvBtK2EAxaRekJj0fybHXhWSIhaoGtTABY5H2EkGDfwMqxGfeD7yz12bmFWTrK2EAxaRekJFDCQvBdiHhtxjb3MjqkayjPTvHS964uR2gqcpMUscUntGuewZgCuHpC9CuC1tkBtv1Voo1QTbKWJPRKGBZeif8bdsqph3EDCQvBdiHhtxjb3MjqkMFk78WGk8ahCZ47nXeWcpW3BIvSKaFaclIWvyihFDCQvBdiHhtxjb3MjqkaJ5HYop8151XPwTniqc)c3TdQWdy(nXgzHnqf5uxoGnR6jabgWQe(fUBlxaghN4GqMAQfxzjyf7tdMexX9RJtTABWmbsrcw3R7h8RJUZJGUSpYtWE8rEhFu6N3IiCnkDp)izfjLi)iUzPIbIK7rI5hf3gkShf3hzjkWJW37rHdxpFGhjWuhgWpQmOi(ib(r2Upce6ss6FK3XhjMFe1BOWE0XESg6Fu6N3I4JaHmTWl6JeGXXbKxhNA12GzcKIDElIW1O09vpPajwlOcpqWMFtSrkGkC46571XPwTnyMaPadyvzSuqTlXbGUUgCpX1DQidSQ1duuFmcQWd4uRWWkUzPIbbskxgbyCCcD3lwTBCu5aGdpmcCieibt3DexXnHU7fR2noQCaWHhg5yjVAaeiclai3kjwzRkw8SIaujkeiY4uRWWkUzPIbPLuUamoo5yW2Uv9KYVBftGdHaraghNq39Iv7ghvoa4WdJahk6RJtTABWmbsbgWQYyjWRJUJUZJejJhU(hH70QNEK(f(EuCHfShb3wnEK(f(rjCm8JcHThP7YGTDR6PhjsC3k(rXvCh0J27rf(JSe8JO7oIR4(rf4r2UpAS90JS9rrE46FeUtRE6r6x47rIKTWcg5rq34pQ3MF0I)ilbd4hr3owwTn4r(XpYfg8JS9rsS9iXLLO6hzj4hLeQEeGPBhbpAWSyxFqpYsWpcuspc3Pm4r6x47rIKTWc2JCyBLCRO(yON86O7O78iNA12GzcKsZIXx4oQogSdmCqfEaWcpeQosAwm(c3r1XGDGHLlJamoo5yW2Uv9KYVBftGdHaHU7iUIBYXGTDR6jLF3kMCSKxniTKqfeiMFtSrSsIv2QIfpBsrQOVoo1QTbZeifQpgkNA12QrbSGAxIdyx1yzdeuHhGUy42BJGv)vElNU7iUIBcD3lwTBCu5aGdpmYXsE1a50DhXvCtogSTBvpP87wXKJL8QbqGemDXWT3gbR(R8woD3rCf3e6UxSA34OYbahEyKJL8QbVoo1QTbZeifQpgkNA12QrbSGAxIdqJGxhNA12GzcKc1hdLtTAB1OawqTlXbe2WGa2vulqYGk8ao1kmSIBwQyWSIGCZhCBeH6Ia1IRcpwpHBxyWXxhNA12GzcKc1hdLtTAB1OawqTlXbawqa7kQfizqfEaNAfgwXnlvmywrqEWMp42ic1fbQfxfESEc3UWGJVoo1QTbZeifQpgkNA12QrbSGAxIdqhSJHdcyxrTajdQWd4uRWWkUzPIbPn)1XPwTnyMaP4h1Bwz7DCBVoVoo1QTbeHnmaGVqUnfWQEkiQE6GvMFtSbcKmOcpGamoobtfYhqHH7vICSKxnqUmcW44emviFafgUxjYXsE1GzNOriqog)yqcxyWI(64uR2gqe2WzcKc2Amu0vsY7yqu90bRm)MydeizqfEaAcMIvHVuyGAXWh1dLlaJJtAgu9Ky)0du25HHvpP8Wq)CdgqGdHargaBw1taIpgRyf(sHbQfdFupece8LcdMH6atD8e3ZIVuyarYt1mjHkrLlaJJtAgu9Ky)0du25HHvpP8Wq)CdgqGdLlaJJtAgu9Ky)0du25HHvpP8Wq)CdgqowYRgm7en(64uR2gqe2WzcKc2AmuGeR964uR2gqe2WzcKI4AeXRJvcRKqqfEaAcMIvHVuyGAXWh1dLJdpgQJPj8BIvwjXZorJqGiaJJtK8OsyLe8lw8rGdFDCQvBdicB4mbsbF4n2QNua7kSCqfEaAcMIvHVuyGAXWh1dFDCQvBdicB4mbsbF465OcKyTxhNA12aIWgotGuO(yOCQvBRgfWcQDjoqBEqa7kQfizqfEGdUz89MysZaq1tI9tpqzNhgw9KYdd9ZnyaHfr4kmKJYXxkmywm(vUWGjscQdOOlWEDCQvBdicB4mbsjYULqrt4ypxkOcpanbtXQWxkmqTy4J6HVoo1QTbeHnCMaPCEOTNcyxHLdIQNoyL53eBGajdQWdiaJJtO7EXQDJJkhaC4HrGdLlaJJtO7EXQDJJkhaC4HrowYRgmBsIU0TjA81XPwTnGiSHZeifPTN2fWkHY4GO6Pdwz(nXgiqYGk8acW44e6UxSA34OYbahEye4q5cW44e6UxSA34OYbahEyKJL8QbZMKOlDBIgFDCQvBdicB4mbsXvsWxKp1IRO3kg864uR2gqe2WzcKY5H2EkGDfwoiQE6GvMFtSbcKmOcpGamooXQq1IRSeSceY(raMtXgqeEDCQvBdicB4mbsrA7PDbSsOmoiQE6GvMFtSbcKmOcpG5dUnIpct4QWJJUThHBxyWr5YiaJJtK2EAxaRWHp9e4q5cW44ePTN2fWkC4tp5yjVAWS4lfgaDKbJFLlmyIKG6ak6cmOM6atD8e3IQBt0OOVoo1QTbeHnCMaPiUgr86yLWkjeuHhGMGPyv4lfgOwm8r9q5bBffB1tYLbhEmuhtt43eRSsINDIgHaj44AeX1iIxhRewjbIvuSvpjxaghNiT90UawHdF6jhl5vdsdhEmuhtt43eRSsIH6K62encbsWX1iIRreVowjSsceROyREsEWcW44ePTN2fWkC4tp5yjVAGOqGyLeRSvflE2KPU8GJRrexJiEDSsyLeiwrXw90RJUZJGUXFK(f(rXTHc7rjCm8JKLbGQNe7NEOa8O0ppmS6Phjseg6NBWGGEeOKch6Fe1b2JGsvJXJe5vsY74Jk8hPFHFK4THc7rlg(OE4J2(rqjDPWGhHFR0JIB1tpcSKhbDJ)i9l8JI7Js4y4hjldavpj2p9qb4rPFEyy1tpsKim0p3Gbps)c)iqIfEeFe1b2JGsvJXJe5vsY74Jk8hPFHVhHVuyWJkWJe4Xk(rwc(r0fypAXFKijBpTlGFe0kJF0Eps31dT9EKMDfw(1XPwTnGiSHZeifS1yOORKK3XGO6Pdwz(nXgiqYGk8a0emfRcFPWa1IHpQhkxMGp4MX3BIjndavpj2p9aLDEyy1tkpm0p3GbqGGVuyWSy8RCHbtKeuhqrxGj6RJUZJGsxwIhjldavpj2p9qb4rPFEyy1tpsKim0p3GbpA7H(hbLQgJhjYRKK3Xhv4ps)cFpYope8i)4hT9JO7oIR4oOhTwc(exa(raBdFemO6PhbLQgJhjYRKK3Xhv4ps)cFpIcFh32JWxkm4rU0c32JkWJ4EHNs8iBFeagyE1pYsWpYLw42E0I)iRK4hnyC7r479iV1)Of)r6x47r25HGhz7JORe)Ofh)r0DhXvC)64uR2gqe2WzcKc2Amu0vsY7yqu90bRm)MydeizqfEaAcMIvHVuyGAXWh1dLFWnJV3etAgaQEsSF6bk78WWQNuEyOFUbdKt3DexXnb)yw3x9KYopKCSKxninzWxkma6idg)kxyWejb1bu0fyqn1bM64jUfv3MOrrLt3DexXnX8tzNhsowYRgKMm4lfgaDKbJFLlmyIKG6ak6cmOM6atD8e3IQBt0OOYLjyZhCBeGX8qzNhcbI5dUncWyEOSZdLt3DexXnbympu25HKJL8QbPjd(sHbqhzW4x5cdMijOoGIUadQPoWuhpXTO62enkQOVoo1QTbeHnCMaPamMhk78WGk8a0emfRcFPWa1IHpQh(64uR2gqe2WzcKcGVqUnfWQEkiQE6GvMFtSbcKmOcpqCncGVqUnfWQEICm(XGeUWGLhSamooHU7fR2noQCaWHhgboeceZhCBeFeMWvHhhDBp5hJFmiHlmy5blaJJtK2EAxaRWHp9e4WxhNA12aIWgotGuogSTBvpP87wXVoo1QTbeHnCMaPiUgrfiSUYaVoo1QTbeHnCMaPq39Iv7ghvoa4WdlOcpqWcW44e6UxSA34OYbahEye4WxhNA12aIWgotGuK2EAxaRekJdQWdiaJJtK2EAxaRWHp9e4qiqWxkmygNA12eS1yOORKK3rc1bM64jUtdFPWaIKNkiqeGXXj0DVy1UXrLdao8WiWHVoo1QTbeHnCMaPCEOTNcyxHLdIQNoyL53eBGajFDCQvBdicB4mbsrCnI41XkHvsiOcpqCnI4AeXRJvcRKa5y8JbjCHb)64uR2gqe2WzcKcGVqUnfWQEkiQE6GvMFtSbcKmOcpGamoobtfYhqHH7vIah(6864uR2gqOrqGe(fUBhuHhW8b3gX4tcOwCf3t(elXTr42fgCuo(sHbZIVuyarYt1RJtTABaHgbZeifHXUrfo8PpOcpGamooHU7fR2noQCaWHhgbo81XPwTnGqJGzcKI3ugyNpuuFmcQWdiaJJtO7EXQDJJkhaC4HrGdFDCQvBdi0iyMaPGxhlm2nguHhqaghNq39Iv7ghvoa4WdJah(64uR2gqOrWmbszutjmGc6kCCsIB71XPwTnGqJGzcKIGpPwCLDffliOcpaD3rCf3eS1yOORKK3rco8yOoMMWVjwzLeN2en(64uR2gqOrWmbsrGpaFyREkOcpGamooHU7fR2noQCaWHhgboeceRKyLTQyXZMueEDCQvBdi0iyMaPibR719d(1XPwTnGqJGzcKs4A12bv4bewaqoEnLWuhl5vdMDUUGaraghNq39Iv7ghvoa4WdJah(64uR2gqOrWmbsbFWGe0ZXTGQ247GdnvHhGMW7MhvpjpyWcpeQoscHbg8Gv8bhA12bv4bKbFPWGztTqfei0DhXvCtO7EXQDJJkhaC4HrowYRgm7enkQCzal8qO6ijegyWdwXhCOvBdbcyHhcvhjy2HB1GvGDGHBtUamoobZoCRgScSdmCBK4kUf91XPwTnGqJGzcKI5NYopmOcpanbtXQWxkmqTy4J6HYp4MX3BIjGfEGV3eRyjb(aeweHRWqok38tzNhsowYRgm7enkNU7iUIBc(WpMCSKxny2jAuUmo1kmSIBwQyqAjHaXPwHHvCZsfdcKuUvsSYwvS400LUnrJI(64uR2gqOrWmbsbF4hh0OAwrJbMRRGk8a0emfRcFPWa1IHpQhk38tzNhsGdLFWnJV3etal8aFVjwXsc8biSicxHHCuUvsSYwvS40G(62en(64uR2gqOrWmbsbBngkqI1cQWd4uRWWkUzPIbbsk38BInIvsSYwvS4zXxkma6idg)kxyWejb1bu0fyqn1bM64jUfv3MOXxhNA12acncMjqksBpTlGvcLXbv4bCQvyyf3SuXGajLB(nXgXkjwzRkw8S4lfgaDKbJFLlmyIKG6ak6cmOM6atD8e3IQBt04RJtTABaHgbZeiLZdT9ua7kSCqfEaNAfgwXnlvmiqs5MFtSrSsIv2QIfpl(sHbqhzW4x5cdMijOoGIUadQPoWuhpXTO62en(64uR2gqOrWmbsXbHm1ulUYsWk2NgCqfEaZVj2iXcyEt50cisFDEDCQvBdi0b7y4aa(c52uaR6PGO6Pdwz(nXgiqYGk8aMp42ij0hphOekJjC7cdokxaghNGPc5dOWW9krowYRgixaghNGPc5dOWW9krowYRgm7en(64uR2gqOd2XWZeifX1iQaH1vgiOcpqWNxrfJHBJ4XiGWPQagacKZROIXWTr8yeqowYRgKwGKqfeio1kmSIBwQyqAboVIkgd3gXJraHUWTPBZFDCQvBdi0b7y4zcKYXGTDR6jLF3koOcpqWNxrfJHBJ4XiGWPQagacKZROIXWTr8yeqowYRgKwGuhceNAfgwXnlvmiTaNxrfJHBJ4XiGqx420T5Voo1QTbe6GDm8mbsHU7fR2noQCaWHhwqfEGGpVIkgd3gXJraHtvbmaeiNxrfJHBJ4XiGCSKxniTajHkiqCQvyyf3SuXG0cCEfvmgUnIhJacDHBt3M)64uR2gqOd2XWZeifX1iIxhRewjHGk8a4WJH6yAc)MyLvs8St04RJtTABaHoyhdptGuISBju0eo2ZLcQWditWNxrfJHBJ4XiGWPQagacKZROIXWTr8yeqowYRgKMUGaXPwHHvCZsfdslW5vuXy42iEmci0fUnDBUOqGqtWuSk8Lcdulg(OEO8Gp4MX3BIjc(KAXvsWDz12aclIWvyihFDCQvBdi0b7y4zcKc1hdLtTAB1OawqTlXbAZdcyxrTajdQWdCWnJV3etAgaQEsSF6bk78WWQNuEyOFUbdiSicxHHCuo(sHbZIXVYfgmrsqDafDb2RJtTABaHoyhdptGuOjCSNlbEDCQvBdi0b7y4zcKIaSrtWN(Gk8aX1iGeNh28qjSsceROyREsUmX1ivB81(qjmyow9ebyof7SZHajUgbK48WMhkHvsGCSKxny2jAu0xhNA12acDWogEMaPq9ddhuHhiUgbK48WMhkHvsGyffB1tYdgWMsyByaXk(MN6Q5H0xhNA12acDWogEMaPiaB0e8PpOcpanHFtmqHFo1QT9rAZj6soD3rCf3eX1iIxhRewjbco8yOoMMWVjwzLeNgiKhdL53eBaOZ8xhNA12acDWogEMaPGp8gB1tkGDfwoOcpanbtXQWxkmqTy4J6HVoo1QTbe6GDm8mbsH6hgoOcpaD3rCf3eX1iIxhRewjbco8yOoMMWVjwzLeNgiKhdL53eBaOZ8xhNA12acDWogEMaPiUgr86yLWkjeuHhqaghNi5rLWkj4xS4Jah(64uR2gqOd2XWZeifS1yOORKK3XGO6Pdwz(nXgiqYGk8aX1iHj4BL2MvcRKaXkk2QNKdytjSnmGyfFZtD18q6RJtTABaHoyhdptGuWwJHcKyTGk8acW44e8HRNpGsYpSe4WxhNA12acDWogEMaPGpC9CubsSwqu90bRm)Mydei5RJtTABaHoyhdptGua8fYTPaw1tbr1thSY8BInqGKbv4bog)yqcxyWYd2kk2QNK3CQmL4sjSscem7WTAWYn)MyJyLeRSvfloTK6so(sHbZqDGPoEI70ebDj3PwHHvCZsfdMna0)1XPwTnGqhSJHNjqkyRXqrxjjVJbr1thSY8BInqGKbv4bOjykwf(sHbQfdFupuoo8yOoMMWVjwzLep7enkxMdUz89MysZaq1tI9tpqzNhgw9KYdd9ZnyaHfr4kmKJYP7oIR4MGFmR7REszNhsowYRgiNU7iUIBI5NYopKCSKxnacKGp4MX3BIjndavpj2p9aLDEyy1tkpm0p3GbeweHRWqok6RJtTABaHoyhdptGuexJiEDSsyLecQWdeCCnI4AeXRJvcRKaXkk2QNKhmGnLW2WaIv8np1vZdPqGqt43edu4NtTABFKwsIi864uR2gqOd2XWZeifbyJMGp9bv4bKj4MtLPexkHvsGasCEyZdiqc28b3grCnI41XQQXHb12eUDHbhfvoD3rCf3eX1iIxhRewjbco8yOoMMWVjwzLeNgiKhdL53eBaOZ8xhNA12acDWogEMaP4kj4lYNAXv0BfdEDCQvBdi0b7y4zcKcWyEOSZddQWdqtWuSk8Lcdulg(OE4RJtTABaHoyhdptGua8fYTPaw1tbr1thSY8BInqGKbv4bog)yqcxyWYnFWTrsOpEoqjugt42fgCuU53eBeRKyLTQyXPL6Voo1QTbe6GDm8mbsH6hg(1XPwTnGqhSJHNjqkyRXqrxjjVJbr1thSY8BInqGKbv4bOjykwf(sHbQfdFupuUmhCZ47nXKMbGQNe7NEGYopmS6jLhg6NBWaclIWvyihLt3DexXnb)yw3x9KYopKCSKxnqoD3rCf3eZpLDEi5yjVAaeibFWnJV3etAgaQEsSF6bk78WWQNuEyOFUbdiSicxHHCu0xhNA12acDWogEMaPGTgdfiXAVoo1QTbe6GDm8mbsbWxi3McyvpfevpDWkZVj2absguHh4y8JbjCHb)64uR2gqOd2XWZeifPTN2fWkHY4GO6Pdwz(nXgiqYxhNA12acDWogEMaPCEOTNcyxHLdIQNoyL53eBGajFDEDCQvBdiT5bagZdLDE4RJtTABaPnFMaPGFmR7REszNhguHhiybyCCI4AevGW6kdqowYRgabIamoorCnIkqyDLbihl5vdKt3DexXnbBngk6kj5DKCSKxn41XPwTnG0MptGum)u25Hbv4bcwaghNiUgrfiSUYaKJL8QbqGiaJJtexJOcewxzaYXsE1a50DhXvCtWwJHIUssEhjhl5vdEDEDCQvBdialqKDlHIMWXEUuqfEaAcMIvHVuyGAXWh1dLltWNxrfJHBJ4XiGWPQagacKGpVIkgd3gXJrabou(5vuXy42iEmcir4ZTA7zoVIkgd3gXJraP6z1LOqGCEfvmgUnIhJacCO8ZROIXWTr8yeqowYRgKg0hQEDCQvBdiaBMaPa4lKBtbSQNcIQNoyL53eBGajdQWdeCCncGVqUnfWQEIyffB1tYn)MyJyLeRSvfloTuleicW44emviFafgUxjcCOCbyCCcMkKpGcd3Re5yjVAWSt04RJtTABabyZeif8HRNJkqI1EDCQvBdiaBMaPCmyB3QEs53TIdQWde85vuXy42iEmciCQkGbGaj4ZROIXWTr8yeqGdLlZ5vuXy42iEmcir4ZTA7zoVIkgd3gXJraP6zNdvqGCEfvmgUnIhJacDHBlqsrHa58kQymCBepgbe4q5NxrfJHBJ4XiGCSKxninOpubbIWcaYTsIv2QIfpBsO61XPwTnGaSzcKI4AevGW6kdeuHhi4ZROIXWTr8yeq4uvadabsWNxrfJHBJ4XiGahk)8kQymCBepgbKi85wT9mNxrfJHBJ4XiGu9SZHkiqoVIkgd3gXJrabou(5vuXy42iEmcihl5vdsBoubbIWcaYTsIv2QIfp7CO61XPwTnGaSzcKcD3lwTBCu5aGdpSGk8abFEfvmgUnIhJacNQcyaiqOlgU92iDnLWu4olNU7iUIBI4AevGW6kdqowYRgabsW0fd3EBKUMsykCNLltWNxrfJHBJ4XiGahk)8kQymCBepgbKi85wT9mNxrfJHBJ4XiGu9SIaubbY5vuXy42iEmciWHYpVIkgd3gXJra5yjVAqAZHkiqc(8kQymCBepgbe4qrHaryba5wjXkBvXINveGQxhNA12acWMjqkyRXqbsS2RJtTABabyZeif8H3yREsbSRWYbv4bOjykwf(sHbQfdFup81XPwTnGaSzcKIRKGViFQfxrVvm41XPwTnGaSzcKI4AeXRJvcRKqqfEaC4XqDmnHFtSYkjE2562enkhWMsyByaXk(MN6Q5HuiqeGXXjsEujSsc(fl(iWHqGemGnLW2WaIv8np1vZdPYLbhEmuhtt43eRSsINDIgHaHMGPyv4lfgOwm8r9q5Y0CQmL4sjSscem7WTAWYJRra8fYTPaw1teROyREsECncGVqUnfWQEICm(XGeUWGHaP5uzkXLsyLeiHj4BL2MLhSamoorA7PDbSch(0tGdLldGnR6jaXhJvScFPWa1IHpQhcbc(sHbZqDGPoEI7zXxkmGi5PcQDQvBtWwJHIUssEhjuhyQJN4w3ebrffceHfaKBLeRSvflE2KqLOVoo1QTbeGntGuWwJHIUssEhdIQNoyL53eBGajdQWdaytjSnmGyfFZtD18qQ84AKWe8TsBZkHvsGyffB1tYdwaghNi5rLWkj4xS4Jah(64uR2gqa2mbsH6hgoOcpGtTcdR4MLkgKws5bFWnJV3eto9dhlW8bw(ak624lChREsbSRWYaclIWvyihFDCQvBdiaBMaPiaB0e8PpOcpGtTcdR4MLkgKws5bFWnJV3eto9dhlW8bw(ak624lChREsbSRWYaclIWvyihLt3DexXnrCnI41XkHvsGGdpgQJPj8BIvwjXPbc5Xqz(nXgqUm0e(nXaf(5uR22hPnNOliqIRrajopS5HsyLeiwrXw9KOVoo1QTbeGntGuagZdLDEyqfEaAcMIvHVuyGAXWh1dFDCQvBdiaBMaPiT90UawjughevpDWkZVj2absguHhW8b3gXhHjCv4Xr32JWTlm4OCzeGXXjsBpTlGv4WNEcCOCbyCCI02t7cyfo8PNCSKxnyw8LcdGoYGXVYfgmrsqDafDbgutDGPoEIBr1TjAuEWcW44eX1iQaH1vgGCSKxnacebyCCI02t7cyfo8PNCSKxnqEZPYuIlLWkjqctW3kTnl6RJtTABabyZeifS1yOORKK3XGO6Pdwz(nXgiqYGk8a4WJH6yAc)MyLvs8St0OCAcMIvHVuyGAXWh1dFDCQvBdiaBMaPCEOTNcyxHLdIQNoyL53eBGajdQWdiaJJtSkuT4klbRaHSFeG5uSbebiqIRrajopS5HsyLeiwrXw90RJtTABabyZeifPTN2fWkHY4Gk8aX1iGeNh28qjSsceROyRE61XPwTnGaSzcKcGVqUnfWQEkiQE6GvMFtSbcKmOcpWX4hds4cdwU53eBeRKyLTQyXPLAHaraghNGPc5dOWW9krGdFDCQvBdiaBMaPiUgr86yLWkjeuHhO5uzkXLsyLeiGeNh28qo(sHbPHXVYfgmrsqDafDbMUnxECncGVqUnfWQEICSKxninDPBt0O8GbSPe2ggqSIV5PUAEi91XPwTnGaSzcKcnHJ9CjWRJtTABabyZeifS1yOORKK3XGO6Pdwz(nXgiqYGk8a0emfRcFPWa1IHpQh(64uR2gqa2mbsrCnI41XkHvsiOcpWb3m(Etm50pCSaZhy5dOOBJVWDS6jfWUcldiSicxHHC81XPwTnGaSzcKI02t7cyLqzCqu90bRm)MydeizqfEabyCCI02t7cyfo8PNahcbc(sHbZ4uR2MGTgdfDLK8osOoWuhpXDA4lfgqK8ub1j1feiX1iGeNh28qjSsceROyREccebyCCI4AevGW6kdqowYRg864uR2gqa2mbs58qBpfWUclhevpDWkZVj2abs(64uR2gqa2mbsrCnI41XkHvsiOcpGmnNktjUucRKabZoCRgS84AeaFHCBkGv9eXkk2QNGaP5uzkXLsyLeiHj4BL2MHaP5uzkXLsyLeiGeNh28qo(sHbPPlOsu5bdytjSnmGyfFZtD18q6RZRJtTABaXUQXYgiag)kxyWb1UehaOVPk4WGW4dyoGamoo5yW2Uv9KYVBftGdHaraghNq39Iv7ghvoa4WdJah(64uR2gqSRASSbMjqky8RCHbhu7sCaGDBpPa6BQcomim(aMdqxmC7TrWQ)kVLlaJJtogSTBvpP87wXe4q5cW44e6UxSA34OYbahEye4qiqcMUy42BJGv)vElxaghNq39Iv7ghvoa4WdJah(64uR2gqSRASSbMjqky8RCHbhu7sCaGDBpPa6BQ6yjVAqqByaaBfEq0TJLvBhGUy42BJGv)vEhegFaZbO7oIR4MCmyB3QEs53TIjhl5vdMfkz6UJ4kUj0DVy1UXrLdao8Wihl5vdutWmaeegFaZkEa4a0DhXvCtO7EXQDJJkhaC4HrowYRgOMGzaiOcpGamooHU7fR2noQCaWHhgjUI7xhNA12aIDvJLnWmbsbJFLlm4GAxIdaSB7jfqFtvhl5vdcAddayRWdIUDSSA7a0fd3EBeS6VY7GW4dyoaD3rCf3KJbB7w1tk)Uvm5yjVAqqy8bmR4bGdq3DexXnHU7fR2noQCaWHhg5yjVAGAcMbGGk8acW44e6UxSA34OYbahEye4WxhNA12aIDvJLnWmbsbJFLlm4GAxIda03u1XsE1GG2Waa2k8GOBhlR2oaDXWT3gbR(R8oim(aMdq3DexXn5yW2Uv9KYVBftowYRgKguY0DhXvCtO7EXQDJJkhaC4HrowYRgOMGzaiim(aMv8aWbO7oIR4Mq39Iv7ghvoa4WdJCSKxnqnbZaWRJtTABaXUQXYgyMaPadyvzSeiiWynqa7QglBjdQWdiJm2vnw2ijjjCGcgWkbyCCiqOlgU92iy1FL3YTRASSrsss4afD3rCf3Ikxgm(vUWGja72Esb03ufCOCzcMUy42BJGv)vElpy7QglBK5KeoqbdyLamooei0fd3EBeS6VYB5bBx1yzJmNKWbk6UJ4kUHaXUQXYgzoHU7iUIBYXsE1aiqSRASSrsss4afmGvcW44YLjy7QglBK5KeoqbdyLamooei2vnw2ijj0DhXvCtIWNB12PfWUQXYgzoHU7iUIBse(CR2wuiqSRASSrsss4afD3rCf3Yd2UQXYgzojHduWawjaJJl3UQXYgjjHU7iUIBse(CR2oTa2vnw2iZj0DhXvCtIWNB12IcbsWy8RCHbta2T9KcOVPk4q5YeSDvJLnYCschOGbSsaghxUm2vnw2ijj0DhXvCtIWNB12qTUMfJFLlmycqFtvhl5vdGabJFLlmycqFtvhl5vdsZUQXYgjjHU7iUIBse(CR2g6mxuiqSRASSrMts4afmGvcW44YLXUQXYgjjjHduWawjaJJl3UQXYgjjHU7iUIBse(CR2oTa2vnw2iZj0DhXvCtIWNB12YLXUQXYgjjHU7iUIBse(CR2gQ11Sy8RCHbta6BQ6yjVAaeiy8RCHbta6BQ6yjVAqA2vnw2ijj0DhXvCtIWNB12qN5IcbImbBx1yzJKKKWbkyaReGXXHaXUQXYgzoHU7iUIBse(CR2oTa2vnw2ijj0DhXvCtIWNB12Ikxg7QglBK5e6UJ4kUjh7r9YTRASSrMtO7oIR4MeHp3QTHADLgg)kxyWeG(MQowYRgihJFLlmycqFtvhl5vdM1UQXYgzoHU7iUIBse(CR2g6mhcKGTRASSrMtO7oIR4MCSh1lxg7QglBK5e6UJ4kUjhl5vdGADnlg)kxyWeGDBpPa6BQ6yjVAGCm(vUWGja72Esb03u1XsE1G0MdvYLXUQXYgjjHU7iUIBse(CR2gQ11Sy8RCHbta6BQ6yjVAaei2vnw2iZj0DhXvCtowYRga16Awm(vUWGja9nvDSKxnqUDvJLnYCcD3rCf3Ki85wTnuNeQMbJFLlmycqFtvhl5vdMfJFLlmycWUTNua9nvDSKxnacem(vUWGja9nvDSKxnin7QglBKKe6UJ4kUjr4ZTABOZCiqW4x5cdMa03ufCOOqGyx1yzJmNq3DexXn5yjVAauRR0W4x5cdMaSB7jfqFtvhl5vdKlJDvJLnsscD3rCf3Ki85wTnuRRzX4x5cdMaSB7jfqFtvhl5vdGaXUQXYgjjHU7iUIBse(CR2Ew8AkHPowYRgihJFLlmycWUTNua9nvDSKxnyg7QglBKKe6UJ4kUjr4ZTA70WRPeM6yjVAaeibBx1yzJKKKWbkyaReGXXLldg)kxyWeG(MQowYRgKMDvJLnsscD3rCf3Ki85wTn0zoeiy8RCHbta6BQcouurfvurffceZVj2iwjXkBvXINfJFLlmycqFtvhl5vdefcKGTRASSrsss4afmGvcW44YdMUy42BJGv)vElxg7QglBK5KeoqbdyLamoUCzKjym(vUWGja9nvbhcbIDvJLnYCcD3rCf3KJL8QbPPlrLldg)kxyWeG(MQowYRgK2COcce7QglBK5e6UJ4kUjhl5vdGADLgg)kxyWeG(MQowYRgiQOqGeSDvJLnYCschOGbSsaghxUmbBx1yzJmNKWbk6UJ4kUHaXUQXYgzoHU7iUIBYXsE1aiqSRASSrMtO7oIR4MeHp3QTtlGDvJLnsscD3rCf3Ki85wTTOIkQCzc2UQXYgjjPaeQttWQfx5ureUooQSJDa8XaiqCQvyyf3SuXGzNlxaghN4ureUooQe7DKahcbItTcdR4MLkgKws5blaJJtCQicxhhvI9osGdf91XPwTnGyx1yzdmtGuGbSQmwceeySgiGDvJLT5bv4bKrg7QglBK5KeoqbdyLamooei0fd3EBeS6VYB52vnw2iZjjCGIU7iUIBrLldg)kxyWeGDBpPa6BQcouUmbtxmC7TrWQ)kVLhSDvJLnssschOGbSsaghhce6IHBVncw9x5T8GTRASSrsss4afD3rCf3qGyx1yzJKKq3DexXn5yjVAaei2vnw2iZjjCGcgWkbyCC5YeSDvJLnssschOGbSsaghhce7QglBK5e6UJ4kUjr4ZTA70cyx1yzJKKq3DexXnjcFUvBlkei2vnw2iZjjCGIU7iUIB5bBx1yzJKKKWbkyaReGXXLBx1yzJmNq3DexXnjcFUvBNwa7QglBKKe6UJ4kUjr4ZTABrHajym(vUWGja72Esb03ufCOCzc2UQXYgjjjHduWawjaJJlxg7QglBK5e6UJ4kUjr4ZTABOwxZIXVYfgmbOVPQJL8QbqGGXVYfgmbOVPQJL8QbPzx1yzJmNq3DexXnjcFUvBdDMlkei2vnw2ijjjCGcgWkbyCC5Yyx1yzJmNKWbkyaReGXXLBx1yzJmNq3DexXnjcFUvBNwa7QglBKKe6UJ4kUjr4ZTAB5Yyx1yzJmNq3DexXnjcFUvBd16Awm(vUWGja9nvDSKxnacem(vUWGja9nvDSKxnin7QglBK5e6UJ4kUjr4ZTABOZCrHarMGTRASSrMts4afmGvcW44qGyx1yzJKKq3DexXnjcFUvBNwa7QglBK5e6UJ4kUjr4ZTABrLlJDvJLnsscD3rCf3KJ9OE52vnw2ijj0DhXvCtIWNB12qTUsdJFLlmycqFtvhl5vdKJXVYfgmbOVPQJL8QbZAx1yzJKKq3DexXnjcFUvBdDMdbsW2vnw2ijj0DhXvCto2J6LlJDvJLnsscD3rCf3KJL8QbqTUMfJFLlmycWUTNua9nvDSKxnqog)kxyWeGDBpPa6BQ6yjVAqAZHk5Yyx1yzJmNq3DexXnjcFUvBd16Awm(vUWGja9nvDSKxnace7QglBKKe6UJ4kUjhl5vdGADnlg)kxyWeG(MQowYRgi3UQXYgjjHU7iUIBse(CR2gQtcvZGXVYfgmbOVPQJL8QbZIXVYfgmby32tkG(MQowYRgabcg)kxyWeG(MQowYRgKMDvJLnYCcD3rCf3Ki85wTn0zoeiy8RCHbta6BQcouuiqSRASSrssO7oIR4MCSKxnaQ1vAy8RCHbta2T9KcOVPQJL8QbYLXUQXYgzoHU7iUIBse(CR2gQ11Sy8RCHbta2T9KcOVPQJL8QbqGyx1yzJmNq3DexXnjcFUvBplEnLWuhl5vdKJXVYfgmby32tkG(MQowYRgmJDvJLnYCcD3rCf3Ki85wTDA41uctDSKxnacKGTRASSrMts4afmGvcW44YLbJFLlmycqFtvhl5vdsZUQXYgzoHU7iUIBse(CR2g6mhcem(vUWGja9nvbhkQOIkQOIcbI53eBeRKyLTQyXZIXVYfgmbOVPQJL8QbIcbsW2vnw2iZjjCGcgWkbyCC5btxmC7TrWQ)kVLlJDvJLnssschOGbSsaghxUmYemg)kxyWeG(MQGdHaXUQXYgjjHU7iUIBYXsE1G00LOYLbJFLlmycqFtvhl5vdsBoubbIDvJLnsscD3rCf3KJL8QbqTUsdJFLlmycqFtvhl5vdevuiqc2UQXYgjjjHduWawjaJJlxMGTRASSrsss4afD3rCf3qGyx1yzJKKq3DexXn5yjVAaei2vnw2ijj0DhXvCtIWNB12PfWUQXYgzoHU7iUIBse(CR2wurfvUmbBx1yzJmNuac1Pjy1IRCQicxhhv2Xoa(yaeio1kmSIBwQyWSZLlaJJtCQicxhhvI9osGdHaXPwHHvCZsfdslP8GfGXXjoveHRJJkXEhjWHI(64uR2gqSRASSbMjqkWawvglfu7sCaORRb3tCDNkYaRA9af1hJSLTCga]] )


end