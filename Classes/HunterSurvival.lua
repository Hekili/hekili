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

    spec:RegisterCombatLogEvent( function ( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
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
    
    local gainWildfireBombOnImpact = false


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
                if buff.mad_bombardier.up then
                    removeBuff( "mad_bombardier" )
                    gainWildfireBombOnImpact = true
                end
            end,
            impact = function ()
                if gainWildfireBombOnImpact then
                    gainCharges( "wildfire_bomb", 1 )
                    gainWildfireBombOnImpact = false
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
                if buff.mad_bombardier.up then
                    removeBuff( "mad_bombardier" )
                    gainWildfireBombOnImpact = true
                end
            end,
            impact = function ()
                if gainWildfireBombOnImpact then
                    gainCharges( "wildfire_bomb", 1 )
                    gainWildfireBombOnImpact = false
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
                if buff.mad_bombardier.up then
                    removeBuff( "mad_bombardier" )
                    gainWildfireBombOnImpact = true
                end
            end,
            impact = function ()
                if gainWildfireBombOnImpact then
                    gainCharges( "wildfire_bomb", 1 )
                    gainWildfireBombOnImpact = false
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
                    removeBuff( "mad_bombardier" )
                    gainWildfireBombOnImpact = true
                end
            end,

            impact = function ()
                if gainWildfireBombOnImpact then
                    gainCharges( "wildfire_bomb", 1 )
                    gainWildfireBombOnImpact = false
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


    spec:RegisterPack( "Survival", 20220810, [[Hekili:T3ZAZnoUr(Br1wlhPz8OXs2AMz3tsP2S5UC7E7n3vR3Qs(KPOLOSzSePcFypoLk9B)AaWhaGDdaklpZMRsQKm2Ken6UrJ(fA0(6rx)BxF1QG8WR)04Zhp(8po6YHJ(Ul)WLJV(Q8N2fE9v7cwEFWTWpehSf()VQi9HOhc2WEXtBscwXaqwsr6s4LFZHf3LNVl77F37Unk)UIBgUmz77YI2wSjipkjEzAW6C2VV8DxF1nfrBY)P4RVbhbU(QGI87ssHPmA7pE9v3fTAvO4RdZw2Gihw8FweNhME4N)HIBlYYpSy05NDybdyh(5d)8pMe)qyk801jllYoSib(TLb7oSy5DHlVhEqEYHfPHz7cxcFuC4JWB2eKbVilmppk(w4NE3HffzHvVLnoFo08Rbw4N3bWidiXHxF1MOS8mgBjopa(NpX5XblzmaGvLhgUXppny31xfghCZMWvx)hVohOE2x18KRwMgbuvuW1x17WIBkwVE4JrBw5NTlcEr2W0WTbrXaYTFVXx7byCsYMvjpgp8(OnB8HvKTbXRQ(IgmBDAy4)aiybYby0fFTXO8G0kKjhM(nHbpewZqLqSAEBy6UW4C)m26Mm(MhSbE(W7EAvAqM)nWJhwoCo6Wr2hI2fMM5)qyCYwfK1WBNEyXTlxbZ0taY5dO7THWkpGF2wptdIw5h(adPcwTkBy4NzYmcwN(7QNT5ZyY2IpIrYpe6hghUnkS8D6dCzcSX4WIxdBgA4rYRjwxKpA08JptSe2mLehWwg9dsttEKHPx(IGPpBgkilNUkcq2Wv(GEJGInmP1pnHeBxxaY8PHlVJjU4NhTnSsqsARZ2Gv(3KS9Maa2HPdl2v(UKmHq56OBVl3xwqCI6A86O0qoeyiZ7jrM6DIkJzOa5Y8xNkGjtnlmhJKi7GuyZia7pqc7(hwC0Rma9CuRlhwmqmou10EcmQioCDcqFdVj4w)K1(BlIJyufGC)9IOD7acPMoxfgKFNpWpUpnylJE)ij92a3yMTG4BFmi9PmUgSDCj5D7csdYlAMgXsPWWeWEFiaGda3HBVXhu2SmjlNzWinAzotPIeVhKGe)IpZyJWKJVWanZOd85FNSrNs0ptZKZOZjPLvj5dZUdW8yWAfxKipA59avWrzyLL9brm7UGSHpm(qypWTdZYbVf40YyXYqB4OP8ewWAWZBkYH1T0N4iNUwExrUECt3WZJboDoS7z8h9hVBjIO7iAD0yBaaHYXdNOAatDBd2wByuGZfWZlnpWDNymbntRngrEwY09MGyg97ZewUxqB6QlR(wztU6m1DaIKSnjoSnxfJLwXUX1yHBwCeTIroyas5jML2TbP3ZbIcENDxcx76iDnAsCINafX8VdF(P1x1tiUQUK6GKfUUSk9CITleYtJgoM)fT0YDyXLv6Xig4Lud8cld8916inOD2ZaamzPzeT6rH5G4WpN7)yKG5wTjUgDkDuRgSrXRl4Evx7U2Gx09FFxxnuEmZyT(NX66FTThLYOMjxkeYFhPTPAQwj4aCF5R8wxnqGEh3CpGWPALyPcal3PRctz2WxcEjQBFBSj97guNkfJgdk6kLR)mQWnsdb2v2DSbWzrwc)qqIdzlB(5j(G6tUm0hjybxQyzNllPr26QypwXQ)FKCZ7LzAnMs0yC62g6YknXeRRpScKGv2BtsYc5IdeJvxBu1ybgqEsALXESXcu2nj7oQyLnhmCFhIhU0EO8MaQLLtKGkhLaHetYivHq1VjZodb)OtEuhESpQ0N83aIPbzS4SUnmMtE8xa(68z(lzbpoOtyGJFQtzy4cxKPPJA(ymMqhFQbFcO94RRo1QSlwXvpfAM2fVJrLYlwiA0UkzKV0kIuxvtOUfhjVfksOyVxwSCeluOxBq8Sv0LuQ((sJxDYhIwXi6g3npAhdI53f6d(cgKwfz8mW)Cc0IYnds2vPBfbB2DxG)U0WvbacP4zrL26AqSUi9jfUP6BK5JLY8VJdfeX(dlERQ2XbvSDs19TIj1UYiwmbQjEWM6jRrXzIUNJdFGsh1qDonl9mprLrGP4Zht49JvdMe6Mc(Yrh)0xACyDOFx9iRskuYAkU6tU0c7iDsJ2jW2FA9HfpLuW4bXVcE)DbpaCNp1mJVca2VvoNhw8dvt6zGL9OT728KqU8WI)lGSpS4hf09HfrvW9rbCRPVeq69)qGJRtt2YMyoKZsgEyHe24oQuoeW2uXMvMrN0A(te8)Uje8ibKlUlK5HmBujWN9FxkeDyXFewOGNbd6x56FoS4QMu(qLuKN)Y)rSW7quaZfBOFokASfkXPAk6lNEIM4dvLZn8AzSu69Nw8uFJ0Fjk)o3KwtIz7Aifqz4k8vbPHInlvKcSJlbevtFmIjBMLNSJDsPCGtcRLfPPHXnhiBWwr27zs)q0ef3EN4mzZkatMrXL7fQ(k2UbHo5nHR5abazq8tI3OGTmGac9muE96gC2ssa7qIbALRlRXwXtCT8lhQNQGEg8YPkcg729PGQUFaeMPvo7GwhfNwmZNl)XkNUO2hsNpFZeTKt14h1MH08q49JAiEcWREw0YBYMRe2xDiq2Wwv)2mLij7XZxM1huASTNckzLG0BbY0e1HudqicLZueTMV(GKcczpy5z(kPiplAvOW3N6GZlawh4e2UeMgNk)2c4fQrLR1Hb3c6h57QRX(YHuNEH6LJI)X)yJEQYOwrGT4XqaGBI4wTeHyQOA9pdkxcUlmyft7ZkUw1YbW8p4)9hz6Y4PKhur(yyTRmmFiYVJPQJR4AN4WoyM9xgWlXKO8xTI9Rm1xmLG7c2U9PY5GbNLbC4KcZCetLnFE55BEz06OLcUu2qTDxL85OmFXmILyGks)VLKxeFByuAQpqXWsbyNNfnRmizFR8PomJ7FSuahMuF1tYuOXG5uoWBDpLV48ANO7JEmiJAeA0vH1CC6MW1bvL8ejhPk3gvSoMelWIADoRMo(DyFuaOm)(NGFpw1pbJmh5pSf9PNj1JDACmFgGER47df1tcvkuncaUte(WBaoiwMrCcilxLHLneAP2P8ZkZR2G6nrPRYyQwaBQpvzpT7z3HL4vS0F4aI07uJlz5nz8Wjuzo)KQ660uwAw1PlPAqbG7tXSTTCx(u3vKRTSRxOCuBMOYhJl6TCrMNZd(WeRQFCq7aqIWY3swAsrnecckGX28O1x3oRokEp0iaOye6RqTncbLuUMlNa0Q1GQqwy)0McqSAtwThidv8YzOyG8pR(luPz(xOBfpRyl8v(7c1Z5RsYWVjjphEJVifXpYJ8m5ZrXAJr5K0wVbCzIxGQAFfD6RBIkodIZN)t(HBVbSOJuirsfZOAESPQi0CHknloqXfwGFBlxBry8Tb3gUL9SqP4bAsatTJS0omr7iTnpEVztsYkUx2y(w1rGfeVe2oLgSP2wlTlWobqMZVCmSLD7nSIPlZ)VvS62TT0t5sXZPe6arjbWZhDnNsu4zm1S3JA20jAJihIxinpGSyykpTHvMvREfQ)W0gpnu5HJNy1BQMPDxc)FnBGSVSi7hkRqt3uEpvpTnSTM3ebRl7kYYlGivctl46pvZDt9N9qcRw1HVllzZd6BKeraP)fmSsPo2K1LWlso2u6Z1ZFxqCC4gybXRhjMzXMT9K0rQoQ0Dh9SKjvRin5SBtqAi6Nq6Vnw9AwhAGE5nmr54cW0ssE0lCuZfosnLw0roKgUEzZjkblDH(SFacFoh5uBCiijS694zDGlnCg1IKJwH5xdCRv(qmukGFnWp1SWKJKp9wjUyf4cmZoLOSKFVKXR2PPqyrpZsgrSC(lgQLAKxxj1R94vfP8BJdp5x6VmsuNdtQJU2rGk798LN3WjADA1uBQjZ6u5HHPM3u5JAJO(P(GeJZuXTsxtdCaOuWI1WOM9GLtmjtfwltgYAk1RgX7oLFnD9IGW5jpj7QS5y6WSFXzYL8zQVWRd44s3RHtrfS)ARL9c5zDRfBbvPQqRc8O3U3)42Xp(C897LxUcHg4NJoblrupssPb21)Hwz8rZPoLSjhybJTXcglXc0VNwglBDtKFDU)I5oUVoiu1pp67WxpYbJBn6zWvV45ZvjqOboKiNkEoX5lDK1Pfs9RPCWAwR8i64JSRXYZ0vvGsvMn7rou9ng8FrrdEvmu8xA2iNLdn1IXbQJ(ScRon1c6BTFkIVMBiAGDjsErLQQiqTkFOkPxQQMLC90Yv(PhLKcUfp1u)svpQDiGP6dXrPYJsFAtW9GX9n3hYDUpEnyGAvZ(mSCV1CJVCpKON7S3wlBxV1iEMU5q8BIgtoYWLHJ6M1DKfKRw1pqvTr)ty9kkjSB5kTtm)MCHLy3c1bLrTl2YD8bDLdDIPoCTJVGwTiisGh05A0aKitMa5DPYL7UHqpmzyKuX5Htygk0fIl)MxT07CcrxXvBMWyyJVqt0fPnFryBxsikQWjU1WKLXshU1geCoATZhJgytekvTVyU20pTvseRQITReVw4dtZebFKs1SlfAKX7Z)r5dNjp0A9oIDftQVPnDwQoxQafOpe2MXRDiMLl9htnKiFCPzpfV0VyhwgWSJby1Vbnw55Ar4qauhiM80e2gUgAsxNG0rBJrvyaQrKwDthg6ik5l5dz2LthY)2IWSmjUQ16Nz6FWTZDQeY5TpKYxygHyD5LLnGLNkxjlc6rt27LNgaLiDEPKslAP2KrA6g7ZQ8y(BgMpA4DbzSYAXNTYPLigP9BAdOc)Ko(YA3bu3Zv9AI9X9Ka9yhXL2JPbDyJr6LsSBjhKjP(Au1iojn8A43K7i2bSGHbnFXauSOHgSWw8ozyqpxw1mHh9THkVL7QN89PrEJMaliE1CBW(DYDrh3XYtoZ83v8bT1mST3MPgf6fD(g0IKv2NfS6jv2k60iyiZjPApY3m1gOFxDp9PNnCKKikNlKLT2M)0qwSpOm7VNkjLUIZ6iR1LgwM9EJPvaZK7ZxAUneKsrUdK)CBO4rUuqrTMb00wfJKvjM3ydMZBbtDjECJBVqRlA)xopbVciiqGboraeEr03QbG(Aw7QqDRYtZRkXaBSVQJ3PRsN6CbegbojD6Cd64nemqI1OU0fLnCzWY7cz5Ily5FVaIZDLFoO6nRinSeb0ZK90QKhXJIOEupYYor1ILPSFtmSbG79Bsy3ZRs8Be25uQ508ydon7QJQKlpNqNMD1b(2JHqAzKDPfBsJVqEDGGfn0Gf2IvREoJbDZPzCLWMrfBwWD08QbNJWJaXawEYzM)UIp8LjMpAxoqCA2GdjpxNMTyEVNnCKKi(I408rlP0vCM0PzQLMVmonBjKh7ontt(D1PzxxkS60mkGEMonJRxYQtZ4g3EHwxEjCAgHaCWPzCdao50mM80X70SJsNo40S9C798Cd64neq5084Fx708ySkmZYnlS2PAJ39q21RlmLDV9Uw8NwHpm(YHJU(QhdsJzv801x9x(HF9t)0N(ZF)Hfhw8BSUSr02DjPvDvJxjUvNVIDfcfKb7wYWk7GGI8KTSCNZRofabYgE4N)Li255nA83Z66h87Li79S)2nad7P4C2jE(Th4xjXFPi4WIvrpeLXx7s2fMgW7Ln9FhSc2F0Nh0aVpEIH33DQG3HF2c77MKDDK3DXPc3kH3ev49QMdr)V(kb0KFuvL48kDW8(NpADHb49QY6cQgNQ(DzeASjaCK01hpc8WX1(Yn3zDta4eWONirGT4ZLAehjrInQD)RC28Lom(XiJFC54FV04)WPLC(WrqogqhNiNlDB5E5QoUsp6CnKP(UawJlnpHCFWPwFXLNy4n5ubpRlaz5DK)Fc2Q5iQv3ba6ig2DLtbWC(V))8lsO2pXXe24)UQIt6Wc(FEIGxZAobjRJyhy)3aCGw)5ucEi6FrL(MAe7lxJhGnVc8pBynd9nZExLRRNX8yAwtfZDwYUz8Yt4mEbcmRSWSA3GboRPWdQ(O29PGZwMeVI)xiKzyDNbCuRPtfG)EQEua(x3CJIXFF1nD9SO1ZC5wUIJY1f4Re)Ewz)bGbzT(1KhwVAYt45lrFAQgSW0jUb6CbkNBNs)BFvANsYyD7wdfJZ0tVfljpKQwzIqkLYPDgyuJOy2iV(CU5s0k)z)(E1rcH9fLbyTFp7Qg4jf770loFW(99vNS5JeRCiLugabASyagLMbRQWY6Fke4fWItWsEHakApFRskUb45GwMOnL9jtrB1Cxb84FTE6b1pS5NnarNgmv0gbl7nMvHxgLvU4UjHngMMNvyt7FInTL9ZZyEThMiawghCLBWZk7YHmLkcGTf2aV4XiqmlUCUzzKklKnKmwBim8XGNoR8vzrB5ZllAqPPTwtFeBH(PHcUtdBd0bYRIvFgZFZdHmrHA7)6VSuMaDDsk4A86GA(OZ3VVD2qMo69kRJ6D7hHKBLxTm0tl1hEUij6zf94I0DhW2rD5wnK9Vg8NZ(hbX3DMOrjnBu79UtVWZuRCYo4H)1i0798aVi4EdtX8XYarTtojBo(gUPwPc)9mLYkwaAUel2LHUuyg7vtVD5Q97LQs)bktkGuY1zn2SI4vHqhN1g1pOD00fdB)E(V(MMA7EADDD)MrNpWXzXPptIBGs)mlq6VqPeOP4eTVqjcoohPAF7a1McTB3iXKGmQQlcT(RWftbhYvKr7qJiU0vhpocnTojNsxRcnmqPvf4ibP4SiPKpULtpY3vTMpA4KxJSUR495xQjT11v94yf43JOzx0zA04TjRuTI(91Wd5PvKnFz(B7JiN82MT5dyCMw6HCA7wVY7dHxFQnE9i757gW75TH2Bh9ABWRhnabpdvCm4JE0WH77()QDT3921(PWsw)EoRmS0EfMsWb81W)vNchPtHFkwKCEjQXpx0ML)8(Dq)udSY1A1xDdm971QJ2ZcEq7rnZw7gBFNMVw6vBGNJwJT6hQXEjqPwrQGTrn441E8TUKG62j1I9bZAs198RLtsTXnE2hmG4MnSwzwwhPR8WvmwQB048AVEnMIGo5PGvJRg735DwIOD4hfYz)AiekOAgWS1Wnl93S5EEkdkaJAAsMw8utFGQneZoo46MFzhhNwRXSfXi3hlfPfOuxGLwI5CfpmlbwDZQ0csQ5HYf6aQkXIQpv05j5GMLpmLkwz64jokbxYoRth7zY93Xzo1EhzOGqV40pCUuoBm5uUqFmji3VNS)vk8DeTNvoqNSKZISzRzKzw2t3Kdd1LmUj3vj5VQvAi3Vx9jZgjN7Y5t0CbVAbbG7zLnNXzJNqrb5nDes3OgPz(YxJi0whdE7mOWq82zAZDdITeR11C)YoDQAPFXNoKtmqOWLphvDAX5ZEVI2zEwSSN)j6)cS6rNAkJzMshh0mCZTkJ3wU2VNODwnFgl5SABhMH2p2E9yK5x3XIJdh(4ZbfO8pPZyXZJt0YNHULRRYtmr1cXemYL1xHum7P6ys7E3Z0riGPvIN63zg2eNzxq89OPNOrByPr9TfXIJeb5udL4aF9YAxdsu2OsqEvvFpQ25FSMSHxF2R4gYHLiFy(cznuerQPMoE)(2Ju2USjbd65ShAB5Ymf0wEA(4Ht8iK(q86sPdt9TyBD6AEDRhOTOJPB2yEyCIQGPOZdT6mxzcMpQ1Idc2FBq694Jrkr00bGqRpXuQ1WOM2BCfBO96JSKoA4ypTnZxY20I8HxQ)Hxq8HVh22tOuXdDayQ7Kff73dTTTaZIT)g(p4KkVAtf8rbuBYYUFCkE9pcDFMtfeD2DylXDE2WuFzix)1FthsotZyS5NMC2um4ZwBhpN)rkzJt0Y7)uUoICaHh1AbYWnE(myoNAoNpnJa8DyMCHij9CMEBzojxtmxHpwVXQ07oSx5HNMc9QjOCoLJk(fz6AMq5YuyMuX0G9(30LclYLKmm)dtqRvizemlFMlhtQhThSTEblsCIwg8BA3UGNozqBJPiGOIMU8CzK3f5(EKTYmm9oFaivAxBOIWWdVFOnO871YhP5irbwkUduDJo0ytg3VYDaW4X5Es5kaBb)nEwWbN9jy64xBiEWbA8g0QyqW16si4y7e63LTcJpV9wbEuEZg11njiB8hPVZX58B8C3IJrxgW(Xyy)yDSVRPMODRpx1V126)7HmK26b7iV4IUZlqMYbek21fR7uOF8bzWvXAHgBPIHV5dnkq6m0GRZJS2kqTrH2nl9OvBA80dj1rHFQGEhDbM9wb)L6m5E9fdWwThDUUwmBEbJYGnefV1a2BMvenN1XXXEQsvj37y69RAqxoY1tZeCSbXIgX)4HtWsYujNvFHRdrEX)(FhxkvEw9NgDgOCuOJs4eHSBNJA15iJ(LyyP24kNP0j2vNCvd0UT3G4oIAt3oAkHePYDoI0WRhJQsTmJ2c5dZzjvO6Ov6FDA13(YCl67yuu01nJO726A5y82rMuOyiu1UiOBJB1v7Ruwq1EUMC1KZhqjL0GGv3CHzQxySYwVq5LeJZu661FP9C8g9RLMA7mQCY0VMdutoD96wEbGqaZjbtlfiAUjDnxcoTjTMISC5oM(hCjleI(VR89YRdJkYqDJOwsFFL4bVa0LBRSVmKZ8x8LuuARoZyNXBMgvxmjrEj6NxFXWLBvjsr0vUxr97QqPbE9rBhomx2BTDRxE9Li38CP9Hvt2(9npxIzx6aeoHWkltIzTza1aRk2Y5ZqMPQxoqFUQ(ckc07zmt9OzVetwFdZ2BNmfT)1SFp6JNBauF74bYRhuOWjHp8fLMAyS6BjmGHnOpcyh0G)6DaypdW8TtMJsbEOpDQbi9TJzN0ifkGJCCGQWBBRQ3Z0lNp(8JCDZr8rgrmXghD(BW5yMW(Js6rFq8ujzIAMBK76m3dd9nm2Pk1QJXfX3yAlRcyKKW01aFA4K8)d61Xff(dOrOwgM6tPhRFpD0W0658jdOiwwMgDuqqMggOSV1ODTUzKSZQWgmWtwXO5MeME5vnDCzFoqRdF1QmSgvMId9pCqxCSzSQJn2C2aNnECo2yZjkTpS9Aw7o(gTr2tVDk95Q6lOiqtQDTnto4yJUEedZ2X6eaQXYwo4HHcNe(WxuA6fWtyutuQo2GA76OCSHWqrpsuah5oTo20P1nhXhmhBWyJVio2q4(ObhBWOghDSXg3ZKJniJ9yCSbBllLJn6AGpnCYNHJnJD1XgD9yMCSP96PJo2yrqGYXgYa2pgJKDwfMIJn26(PFHDSXCLkD9vSlbc7ppJt4nW0R))(]] )


end
