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
            generate = function( t )
                local name, _, count, _, duration, expires, caster = FindUnitDebuffByID( "target", 259277, "PLAYER" )

                if name then
                    t.name = name
                    t.count = 1
                    t.expires = expires
                    t.applied = expires - duration
                    t.caster = caster
                    return
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,
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

        if prev_gcd[1].kill_command and pheromoneReset and cooldown.kill_command.remains > 0 and ( now - action.kill_command.lastCast < 0.25 ) then
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
                    if talent.alpha_predator.enabled then gainCharges( "kill_command", 1 )
                    else setCooldown( "kill_command", 0 ) end
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
            -- id = 270323,            
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = function () return buff.mad_bombardier.up and 0 or 18 end,
            recharge = function () return buff.mad_bombardier.up and 0 or 18 end,
            gcd = "spell",

            startsCombat = true,

            bind = "wildfire_bomb",
            talent = "wildfire_infusion",

            usable = function () return current_wildfire_bomb == "pheromone_bomb" end,
            handler = function ()
                applyDebuff( "target", "pheromone_bomb" )
                current_wildfire_bomb = "wildfire_bomb"
                removeBuff( "mad_bombardier" )
            end,
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

            handler = function ()
                removeBuff( "vipers_venom" )
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
            -- id = 270335,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = function () return buff.mad_bombardier.up and 0 or 18 end,
            recharge = function () return buff.mad_bombardier.up and 0 or 18 end,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            bind = "wildfire_bomb",

            usable = function () return current_wildfire_bomb == "shrapnel_bomb" end,
            handler = function ()
                applyDebuff( "target", "shrapnel_bomb" )
                current_wildfire_bomb = "wildfire_bomb"
                removeBuff( "mad_bombardier" )
            end,
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
            -- id = 271045,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = function () return buff.mad_bombardier.up and 0 or 18 end,
            recharge = function () return buff.mad_bombardier.up and 0 or 18 end,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            bind = "wildfire_bomb",

            usable = function () return current_wildfire_bomb == "volatile_bomb" end,
            handler = function ()
                if debuff.serpent_sting.up then applyDebuff( "target", "serpent_sting" ) end
                current_wildfire_bomb = "wildfire_bomb"
                removeBuff( "mad_bombardier" )
            end,
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
            cooldown = function () return buff.mad_bombardier.up and 0 or 18 end,
            recharge = function () return buff.mad_bombardier.up and 0 or 18 end,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            --[[ texture = function ()
                local a = current_wildfire_bomb and current_wildfire_bomb or "wildfire_bomb"
                if a == "wildfire_bomb" or not action[ a ] then return 2065634 end                
                return action[ a ].texture
            end, ]]

            aura = "wildfire_bomb",
            bind = function () return current_wildfire_bomb end,

            handler = function ()
                if current_wildfire_bomb ~= "wildfire_bomb" then
                    runHandler( current_wildfire_bomb )
                    current_wildfire_bomb = "wildfire_bomb"
                    return
                end
                applyDebuff( "target", "wildfire_bomb_dot" )
                removeBuff( "flame_infusion" )
                removeBuff( "mad_bombardier" )
            end,

            copy = { 271045, 270335, 270323, 259495 }
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
    
    spec:RegisterSetting( "ca_vop_overlap", false, {
        name = "|T2065565:0|t Coordinated Assault Overlap (Vision of Perfection)",
        desc = "If checked, the addon will recommend |T2065565:0|t Coordinated Assault even if the buff is already applied due to a Vision of Perfection proc.\n" ..
            "This may be preferred when delaying Coordinated Assault would cost you one or more uses of Coordinated Assault in a given fight.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Survival", 20220305, [[d80a7bqiPQ8iOKsxIOaBsk8jPKmkPsoLuPwfusEfuywer3sQQ0UO0VOadJIshtkAzueptQQAAsvfxtkHTruqFJOOACuu4CsjvToPKY7KsuQMhf09is7dkXbLsuTqkspKOitukrjxukrPSrkkc9rkksJKIIiNukPYkHs9sIIsZukrUjusr7ek6Nuue1qPOiyPeffpfQMkrPVkLOySuuu7LWFj1GHCyHfJWJrAYICzuBgKptsJwk1PLSAOKcVMimBrDBeTBv(TIHtIJtuOLRQNR00P66GA7evFxQY4PO68sfRhkPA(uO9dSOPqwbEkCwGPjM1etmB)nBlSn7VjTEte4EhfwGReujcvwGFbjlWXHF5L8ilWvIo5jsczf47a)uwGJ1cqTDxzBndmqT82Wew6qAWwKW5WR5OFa5gSfj1abobCL9w3jie4PWzbMMywtmXS93STW2S)M06B2pc8a2BpVahViLjbE7kL4tqiWt8sf44WV8sEKbiZKGpNFa2ynJN2gGAHKaKjM1ete45A9viRa)8qiRaZMczf4b1R5e4RZCw7FOiW5liYCsyQWfyAIqwboFbrMtctf40VC(RqG3haradbz7v5KEvQV81(mzu3cqgncqeWqq2EvoPxL6lFTptg1TaudaIoton9oRevoRPdjzCj7ZKrDRapOEnNah6zgRxNQ2)qr4cm7VqwboFbrMtctf40VC(RqG3haradbz7v5KEvQV81(mzu3cqgncqeWqq2EvoPxL6lFTptg1TaudaIoton9oRevoRPdjzCj7ZKrDRapOEnNa3Jx7FOiCHlWtmuaNDHScmBkKvGhuVMtGtcJ1X6zwGZxqK5KWuHlW0eHScC(cImNeMkWdQxZjW9pozeUYfwVov92ECbEIx6xkEnNa3mDaOOnhjakUeaj7hNmcx5cRZaeMMjitaeFmzXRKaupgGsZ1khGsda5TRfGGMhGuYrh(xaIGPb8Yau5Tkbqema5ZaqRsqs2bGIlbq9yaIgxRCa65iv5oaKSFCYiaTkmTGkkaradbTwbo9lN)ke49bqE8QSBRvRKJo8lCbM9xiRaNVGiZjHPc8G61CcCSgJdFQC9VoXRxxNvtJCwGt)Y5VcbEq9soR5JjlEbiPautaQba1faradbzPZ8P6cNt6y3ao7wyfaYOraQpaIoton9olDMpvx4Csh7gWz3(mzu3cqgncqeZUaudaYlsw7Jovmazia1FZcqDdqgncqDbqb1l5SMpMS4fGWca1eGAaqeWqq2N35cVovD8)0ZcRaqgncqeWqqw6mFQUW5Ko2nGZUfwbG6wGFbjlWXAmo8PY1)6eVEDDwnnYzHlWSFeYkWdQxZjWHxwxotUcC(cImNeMkCbMTqiRaNVGiZjHPc8G61CcCAKZ6G61C6CTUapxRRVGKf400kCbMYqHScC(cImNeMkWPF58xHapOEjN18XKfVaKHau)bOgaKhz(Clr9PvpqALN7y5liYCsGV(xuxGztbEq9AobonYzDq9AoDUwxGNR11xqYcCIrr4cmL5czf48fezojmvGt)Y5VcbEq9soR5JjlEbidbO(dqnaO(aipY85wI6tREG0kp3XYxqK5KaF9VOUaZMc8G61CcCAKZ6G61C6CTUapxRRVGKf4RlCbMMHqwboFbrMtctf40VC(RqGhuVKZA(yYIxaclaKjc81)I6cmBkWdQxZjWProRdQxZPZ16c8CTU(cswGtZCiNfUaZwVqwbEq9AobE804yTp)ZNlW5liYCsyQWfUax5z6qseUqwbMnfYkW5liYCsyQaFue4l7fKaN(LZFfcCpY85wY5uNzznr5SLVGiZjbEIx6xkEnNahRz802aulKeGmXSMyIaxE86lizbojH(xnDwxGhuVMtGlp(kiYSaxEKHznNxwGhuVMZ(HIpVE9VKGT0zDbU8idZc8G61CwY5uNzznr5SLoRlCbMMiKvGhuVMtGVWKKZPvyxGZxqK5KWuHlWS)czf4b1R5e4eJ7zoPHYrho1RovTpMxNaNVGiZjHPcxGz)iKvGhuVMtGdL5Tn9dixGZxqK5KWuHlWSfczf48fezojmvGt)Y5Vcb(dFm08QSDh4m08QSMjj4FTSmcxkkCsGhuVMtG7XR9pueUatzOqwbEq9Aob(6mN1(hkcC(cImNeMkCHlWjgfHScmBkKvGZxqK5KWubEq9Aob(YVcFUE96uf40VC(RqGtadbzLxk8VA58nK2NjJ6waQba1faradbzLxk8VA58nK2NjJ6waYqasLMaiJgbONHEEBhezgG6wGt7qZS2JxL9vGztHlW0eHScC(cImNeMkWdQxZjWLOYznDijJljWPF58xHahAOWlaHbarJ11pRYhaziabnu41sgMdqnaicyii7XBDQ9IVZQ9puuQtvhkkXho8AHvaiJgbiOHcVaegaenwx)SkFaKHae0qHxlzyoaHba10SaudaIagcYE8wNAV47SA)dfL6u1HIs8HdVwyfaQbaradbzpERtTx8DwT)HIsDQ6qrj(WHx7ZKrDlaziaPstcCAhAM1E8QSVcmBkCbM9xiRapOEnNaxIkN1B7Xf48fezojmv4cm7hHScC(cImNeMkWPF58xHahAOWlaHbarJ11pRYhaziabnu41sgMdqnaii4Cw)mTD8QS2lsgGmeGuPjaYOraIagcYsgjnXqseFQ43cRiWdQxZjW7v5eu9SMyijeUaZwiKvGZxqK5KWubo9lN)ke4qdfEbimaiASU(zv(aidbiOHcVwYWCbEq9AobouoojQtvV(xsWcxGPmuiRapOEnNahkhD4KEBpUaNVGiZjHPcxGPmxiRaNVGiZjHPcC6xo)viWF4JHMxLThVBDQ9IVZQ9puuQtvhkkXho8AzzeUuu4ea1aGGgk8cqgcqYJVcImBjj0)QPZ6c81)I6cmBkWdQxZjWProRdQxZPZ16c8CTU(cswGFEiCbMMHqwboFbrMtctf40VC(RqGdnu4fGWaGOX66Nv5dGmeGGgk8AjdZf4b1R5e4jo82AA7qIpifUaZwVqwboFbrMtctf4b1R5e4FO4ZRx)ljybo9lN)ke4eWqqw6mFQUW5Ko2nGZUfwbGAaqeWqqw6mFQUW5Ko2nGZU9zYOUfGmeGAABbaHvaKknjWPDOzw7XRY(kWSPWfy20Sczf48fezojmvGhuVMtGtoN6mlRjkNf40VC(RqGtadbzPZ8P6cNt6y3ao7wyfaQbaradbzPZ8P6cNt6y3ao72NjJ6waYqaQPTfaewbqQ0KaN2HMzThVk7RaZMcxGzZMczf4b1R5e4HMe(t8Rhin9NERaNVGiZjHPcxGztteYkW5liYCsyQapOEnNa)dfFE96FjblWPF58xHaNagcY6LIEG0EBwVkC821dQeaKuaQ)cCAhAM1E8QSVcmBkCbMn7VqwboFbrMtctf4b1R5e4KZPoZYAIYzbo9lN)ke4EK5ZTrwPDOvEof(8w(cImNaOgauxaebmeKLCo1zwwdb)DSWkaudaIagcYsoN6mlRHG)o2NjJ6waYqacAOWlazaa1fajp(kiYSLKq)RMoRdq9larJ11pRYha1naHvaKknbqDlWPDOzw7XRY(kWSPWfy2SFeYkW5liYCsyQaN(LZFfcCOHcVaegaenwx)SkFaKHae0qHxlzyoa1aG6dG8IkrDQaudaQlaccoN1ptBhVkR9IKbidbivAcGmAeG6dGsJB7v5eu9SMyijSErLOovaQbaradbzjNtDML1qWFh7ZKrDlaHfaccoN1ptBhVkR9IKbO(fGAcqyfaPstaKrJauFauACBVkNGQN1edjH1lQe1PcqnaO(aicyiil5CQZSSgc(7yFMmQBbOUbiJgbiVizTp6uXaKHautZaGAaq9bqPXT9QCcQEwtmKewVOsuNQapOEnNaVxLtq1ZAIHKq4cmB2cHScC(cImNeMkWdQxZjWLOYznDijJljWPDOzw7XRY(kWSPaN(LZFfcCOHcVaegaenwx)SkFaKHae0qHxlzyoa1aG6cG6dGE4JHMxLThVBDQ9IVZQ9puuQtvhkkXho8A5liYCcGmAeGGgk8cqgcqYJVcImBjj0)QPZ6au3c8eV0Vu8AobERdcG6mWauAUw5au7qodqyY7wNAV470QfGK9dfL6ubOwUIs8HdVscqBrQK7aq0yDasMTYzasMgsY4saubbqDgyaQ3CTYbOro)0qbGMdGmtCOWlab9djaLM6ubODSauRdcG6mWauAaO2HCgGWK3To1EX3Pvlaj7hkk1PcqTCfL4dhEbOodmaTTh4CcGOX6aKmBLZaKmnKKXLaOccG6mWpabnu4fGQfGi480dG82marN1bObcGWAoN6mldqMwodqZdqYmHIppaH7FjblCbMnLHczf48fezojmvGhuVMtGlrLZA6qsgxsGt7qZS2JxL9vGztbo9lN)ke4qdfEbimaiASU(zv(aidbiOHcVwYWCaQba9WhdnVkBpE36u7fFNv7FOOuNQouuIpC41YxqK5ea1aGOZKttVZc9mJ1Rtv7FOyFMmQBbiSaqDbqqdfEbidaOUai5XxbrMTKe6F10zDaQFbiASU(zv(aOUbiScGuPjaQBaQbarNjNMEN1Jx7FOyFMmQBbiSaqDbqqdfEbidaOUai5XxbrMTKe6F10zDaQFbiASU(zv(aOUbiScGuPjaQBaQba1fa1ha5rMp3UoZzT)HILVGiZjaYOraYJmFUDDMZA)dflFbrMtaudaIoton9o76mN1(hk2NjJ6waclauxae0qHxaYaaQlasE8vqKzljH(xnDwhG6xaIgRRFwLpaQBacRaivAcG6gG6wGN4L(LIxZjWBzkVnaHjVBDQ9IVtRwas2puuQtfGA5kkXho8cqZL7aqYSvodqY0qsgxcGkiaQZa)aK)HYcqXZa0CaeDMCA6DscqJ3M)E1Ya06JcabV1PcqYSvodqY0qsgxcGkiaQZa)aef(F(CacAOWlafKd85auTaeFdSABaYhaAHxpQdG82mafKd85a0abqErYauMHCacAEakUoa0abqDg4hG8puwaYhaIoKmanqqaeDMCA6DcxGztzUqwboFbrMtctf40VC(RqGdnu4fGWaGOX66Nv5dGmeGGgk8AjdZf4b1R5e4RZCw7FOiCbMnndHScC(cImNeMkWdQxZjWx(v4Z1RxNQaN(LZFfc8042LFf(C961PAFg65TDqKzaQba1haradbzPZ8P6cNt6y3ao7wyfaYOraYJmFUnYkTdTYZPWN3YxqK5ea1aGEg65TDqKzaQba1haradbzjNtDML1qWFhlSIaN2HMzThVk7RaZMcxGzZwVqwbEq9Aob(Z7CHxNQo(F6jW5liYCsyQWfyAIzfYkWdQxZjW7v5KEvQV8vGZxqK5KWuHlW0KMczf48fezojmvGt)Y5VcbEFaebmeKLoZNQlCoPJDd4SBHve4b1R5e40z(uDHZjDSBaNDHlW0eteYkW5liYCsyQaN(LZFfcCcyiil5CQZSSgc(7yHvaiJgbiOHcVaegauq9AoRevoRPdjzCjlnwx)SkFaewaiOHcVwYWCaYOraIagcYsN5t1foN0XUbC2TWkc8G61CcCY5uNzznr5SWfyAs)fYkW5liYCsyQapOEnNa)dfFE96FjblWPDOzw7XRY(kWSPWfyAs)iKvGZxqK5KWubo9lN)ke4PXT9QCcQEwtmKe2NHEEBhezwGhuVMtG3RYjO6znXqsiCbMM0cHScC(cImNeMkWdQxZjWx(v4Z1RxNQaN(LZFfcCcyiiR8sH)vlNVH0cRiWPDOzw7XRY(kWSPWfUaNMwHScmBkKvGZxqK5KWubo9lN)ke4EK5ZTo)KREG08PgQmjFULVGiZjaQbabnu4fGmeGGgk8AjdZf4b1R5e4TJxzMt4cmnriRaNVGiZjHPcC6xo)viWjGHGS0z(uDHZjDSBaNDlSIapOEnNaNiptsdb)DeUaZ(lKvGZxqK5KWubo9lN)ke4eWqqw6mFQUW5Ko2nGZUfwrGhuVMtGhhLx)JSMg5SWfy2pczf48fezojmvGt)Y5VcbobmeKLoZNQlCoPJDd4SBHve4b1R5e4q1Ze5zscxGzleYkWdQxZjWZLABF1ynGtQK85cC(cImNeMkCbMYqHScC(cImNeMkWPF58xHaNoton9oRevoRPdjzCjleCoRFM2oEvw7fjdqybGuPjbEq9AoborOQhiT)fvIv4cmL5czf48fezojmvGt)Y5VcbobmeKLoZNQlCoPJDd4SBHvaiJgbiVizTp6uXaKHauZ(lWdQxZjWj4F5xI6ufUatZqiRapOEnNaNegRJ1ZSaNVGiZjHPcxGzRxiRaNVGiZjHPcC6xo)viWjMDbOgaeuP221ptg1TaKHaKjTaGmAeGiGHGS0z(uDHZjDSBaNDlSIapOEnNaxz8AoHlWSPzfYkW5liYCsyQaN(LZFfc8UaiOHcVaKHaKm3SaKrJaeDMCA6Dw6mFQUW5Ko2nGZU9zYOUfGmeGuPjaQBaQba1faTdCMOUKvbED4mR5hwXR5S8fezobqgncq7aNjQlzLp5WRmR3jlNp3YxqK5ea1aGiGHGSYNC4vM17KLZNBttVdG6wGhuVMtGdL5Tn9dixGxNZ)dR46csGtBh3X56uB03oWzI6swf41HZSMFyfVMt4cmB2uiRaNVGiZjHPcC6xo)viWHgk8cqyaq0yD9ZQ8bqgcqqdfETKH5auda6HpgAEv2UdCgAEvwZKe8VwwgHlffobqnaipET)HI9zYOUfGmeGuPjaQbarNjNMENfkhpBFMmQBbidbivAcGAaqDbqb1l5SMpMS4fGWca1eGmAeGcQxYznFmzXlajfGAcqnaiVizTp6uXaewaOwaqyfaPstau3c8G61CcCpET)HIWfy20eHScC(cImNeMkWdQxZjWHYXZcC6xo)viWHgk8cqyaq0yD9ZQ8bqgcqqdfETKH5audaYJx7FOyHvaOga0dFm08QSDh4m08QSMjj4FTSmcxkkCcGAaqErYAF0PIbiSaq9daHvaKknjWZ1XAAsGBsleUaZM9xiRaNVGiZjHPcC6xo)viWdQxYznFmzXlajfGAcqnaipEv2TErYAF0PIbidbiOHcVaKbauxaK84RGiZwsc9VA6Soa1Vaenwx)SkFau3aewbqQ0KapOEnNaxIkN1B7XfUaZM9JqwboFbrMtctf40VC(RqGhuVKZA(yYIxaska1eGAaqE8QSB9IK1(OtfdqgcqqdfEbidaOUai5XxbrMTKe6F10zDaQFbiASU(zv(aOUbiScGuPjbEq9Aobo5CQZSSMOCw4cmB2cHScC(cImNeMkWPF58xHapOEjN18XKfVaKuaQja1aG84vz36fjR9rNkgGmeGGgk8cqgaqDbqYJVcImBjj0)QPZ6au)cq0yD9ZQ8bqDdqyfaPstc8G61Cc8pu851R)LeSWfy2ugkKvGZxqK5KWubo9lN)ke4E8QSBt16XrzaclsbizOapOEnNapwfM66bs7TznhQzw4cxGVUqwbMnfYkW5liYCsyQaN(LZFfcCOHcVaegaenwx)SkFaKHae0qHxlzyoa1aG6cG6dG(OsAwoFUnsP1YMxRVaKrJauFa0hvsZY5ZTrkTwyfaQba9rL0SC(CBKsRnb)HxZbqyaqFujnlNp3gP0ARdGmeGAba1naz0ia9rL0SC(CBKsRfwbGAaqFujnlNp3gP0AFMmQBbiSaq9Jzf4b1R5e4jo82AA7qIpifUatteYkW5liYCsyQapOEnNaF5xHpxVEDQcC6xo)viW7dGsJBx(v4Z1RxNQ1lQe1PcqnaipEv2TErYAF0PIbiSaqYCaYOraIagcYkVu4F1Y5BiTWkaudaIagcYkVu4F1Y5BiTptg1TaKHaKknjWPDOzw7XRY(kWSPWfy2FHSc8G61CcCOC0Ht6T94cC(cImNeMkCbM9JqwboFbrMtctf40VC(RqG3ha9rL0SC(CBKsRLnVwFbiJgbO(aOpQKMLZNBJuATWkaudaQla6JkPz5852iLwBc(dVMdGWaG(OsAwoFUnsP1whaziazIzbiJgbOpQKMLZNBJuAT0b(Caska1eG6gGmAeG(OsAwoFUnsP1cRaqnaOpQKMLZNBJuATptg1TaewaO(XSaKrJaeXSla1aG8IK1(OtfdqgcqnnRapOEnNa)5DUWRtvh)p9eUaZwiKvGZxqK5KWubo9lN)ke49bqFujnlNp3gP0AzZR1xaYOraQpa6JkPz5852iLwlSca1aG(OsAwoFUnsP1MG)WR5aimaOpQKMLZNBJuAT1bqgcqMywaYOra6JkPz5852iLwlSca1aG(OsAwoFUnsP1(mzu3cqybGmXSaKrJaeXSla1aG8IK1(OtfdqgcqMywbEq9AobEVkN0Rs9LVcxGPmuiRaNVGiZjHPcC6xo)viW7dG(OsAwoFUnsP1YMxRVaKrJaeDKZxCU9k12UgkyaQbarNjNMENTxLt6vP(Yx7ZKrDlaz0ia1harh58fNBVsTTRHcgGAaqDbq9bqFujnlNp3gP0AHvaOga0hvsZY5ZTrkT2e8hEnhaHba9rL0SC(CBKsRToaYqaQ)MfGmAeG(OsAwoFUnsP1cRaqnaOpQKMLZNBJuATptg1Taewaitmlaz0ia1ha9rL0SC(CBKsRfwbG6gGmAeGiMDbOgaKxKS2hDQyaYqaQ)MvGhuVMtGtN5t1foN0XUbC2fUatzUqwbEq9AobUevoR32JlW5liYCsyQWfyAgczf48fezojmvGt)Y5Vcbo0qHxacdaIgRRFwLpaYqacAOWRLmmxGhuVMtGdLJtI6u1R)LeSWfy26fYkWdQxZjWdnj8N4xpqA6p9wboFbrMtctfUaZMMviRaNVGiZjHPcC6xo)viWHGZz9Z02XRYAVizaYqaYeacRaivAcGAaql7AI5GxRx8BIzOnrHcqgncqeWqqwYiPjgsI4tf)wyfaYOraQpaAzxtmh8A9IFtmdTjkuaQba1fabbNZ6NPTJxL1ErYaKHaKknbqgncqqdfEbimaiASU(zv(aidbiOHcVwYWCaQba1faDS5UUxPjgscR8jhELzaQbaLg3U8RWNRxVovRxujQtfGAaqPXTl)k8561Rt1(m0ZB7GiZaKrJa0XM76ELMyijSkT5FiNJbOgauFaebmeKLCo1zwwdb)DSWkaudacAOWlaHbarJ11pRYhaziabnu41sgMdq9lafuVMZkrLZA6qsgxYsJ11pRYhaHvau)bOUbiJgbiIzxaQba5fjR9rNkgGmeGAAwaQBbEq9AobEVkNGQN1edjHWfy2SPqwboFbrMtctf4b1R5e4su5SMoKKXLe40VC(RqGVSRjMdETEXVjMH2efka1aGsJBvAZ)qohRjgscRxujQtfGAaq9bqeWqqwYiPjgsI4tf)wyfboTdnZApEv2xbMnfUaZMMiKvGZxqK5KWubo9lN)ke4b1l5SMpMS4fGWca1eGAaq9bqp8XqZRY2VtoKy9ilb)RMoh0aFP6u1R)Le8AzzeUuu4KapOEnNaNgVCw4cmB2FHScC(cImNeMkWPF58xHapOEjN18XKfVaewaOMaudaQpa6HpgAEv2(DYHeRhzj4F105Gg4lvNQE9VKGxllJWLIcNaOgaeDMCA6D2EvobvpRjgscleCoRFM2oEvw7fjdqybGwfoN1E8QSVaudaQlaI2oEvE1qFq9AUidqybGmX2caYOraknUDB)HYXznXqsy9IkrDQau3c8G61CcCcyN2M)ocxGzZ(riRaNVGiZjHPcC6xo)viWHgk8cqyaq0yD9ZQ8bqgcqqdfETKH5c8G61Cc81zoR9pueUaZMTqiRaNVGiZjHPc8G61CcCY5uNzznr5SaN(LZFfcCpY852iR0o0kpNcFElFbrMtaudaQlaIagcYsoN6mlRHG)owyfaQbaradbzjNtDML1qWFh7ZKrDlaziabnu4fGmaG6cGKhFfez2ssO)vtN1bO(fGOX66Nv5dG6gGWkasLMaOgauFaebmeKTxLt6vP(Yx7ZKrDlaz0iaradbzjNtDML1qWFh7ZKrDla1aGo2Cx3R0edjHvPn)d5Cma1TaN2HMzThVk7RaZMcxGztzOqwboFbrMtctf4b1R5e4su5SMoKKXLe40VC(RqGdbNZ6NPTJxL1ErYaKHaKknbqnaiOHcVaegaenwx)SkFaKHae0qHxlzyUaN2HMzThVk7RaZMcxGztzUqwboFbrMtctf4b1R5e4FO4ZRx)ljybo9lN)ke4eWqqwVu0dK2BZ6vHJ3UEqLaGKcq9hGmAeGsJB32FOCCwtmKewVOsuNQaN2HMzThVk7RaZMcxGztZqiRaNVGiZjHPcC6xo)viWtJB32FOCCwtmKewVOsuNQapOEnNaNCo1zwwtuolCbMnB9czf48fezojmvGhuVMtGV8RWNRxVovbo9lN)ke4pd982oiYma1aG84vz36fjR9rNkgGWcajZbiJgbicyiiR8sH)vlNVH0cRiWPDOzw7XRY(kWSPWfyAIzfYkW5liYCsyQaN(LZFfc8Jn319knXqsy32FOCCgGAaqqdfEbiSaqYJVcImBjj0)QPZ6aewbqMaqnaO042LFf(C961PAFMmQBbiSaqTaGWkasLMe4b1R5e49QCcQEwtmKecxGPjnfYkWdQxZjWPTdj(GCf48fezojmv4cmnXeHScC(cImNeMkWdQxZjWLOYznDijJljWPF58xHahAOWlaHbarJ11pRYhaziabnu41sgMlWPDOzw7XRY(kWSPWfyAs)fYkW5liYCsyQaN(LZFfc8h(yO5vz73jhsSEKLG)vtNdAGVuDQ61)scETSmcxkkCsGhuVMtG3RYjO6znXqsiCbMM0pczf48fezojmvGhuVMtGtoN6mlRjkNf40VC(RqGtadbzjNtDML1qWFhlScaz0iabnu4fGWaGcQxZzLOYznDijJlzPX66Nv5dGWcabnu41sgMdq9la1SfaKrJauAC72(dLJZAIHKW6fvI6ubiJgbicyiiBVkN0Rs9LV2NjJ6wboTdnZApEv2xbMnfUattAHqwboFbrMtctf4b1R5e4FO4ZRx)ljyboTdnZApEv2xbMnfUattKHczf48fezojmvGt)Y5VcbExa0XM76ELMyijSYNC4vMbOgauAC7YVcFUE96uTErLOovaYOra6yZDDVstmKewL28pKZXaKrJa0XM76ELMyijSB7puoodqnaiOHcVaewaOwywaQBaQba1haTSRjMdETEXVjMH2efQapOEnNaVxLtq1ZAIHKq4cxGtZCiNfYkWSPqwboFbrMtctf4b1R5e4l)k8561RtvGt)Y5VcbUhz(CB7oPpwnr5SLVGiZjaQbaradbzLxk8VA58nK2NjJ6waQbaradbzLxk8VA58nK2NjJ6waYqasLMe40o0mR94vzFfy2u4cmnriRaNVGiZjHPcC6xo)viW7dG(OsAwoFUnsP1YMxRVaKrJa0hvsZY5ZTrkT2NjJ6waclsbOMMfGmAeGcQxYznFmzXlaHfPa0hvsZY5ZTrkTw6aFoaHvaKjc8G61Cc8EvoPxL6lFfUaZ(lKvGZxqK5KWubo9lN)ke49bqFujnlNp3gP0AzZR1xaYOra6JkPz5852iLw7ZKrDlaHfPaKzaqgncqb1l5SMpMS4fGWIua6JkPz5852iLwlDGphGWkaYebEq9Aob(Z7CHxNQo(F6jCbM9JqwboFbrMtctf40VC(RqG3ha9rL0SC(CBKsRLnVwFbiJgbOpQKMLZNBJuATptg1TaewKcqnnlaz0iafuVKZA(yYIxaclsbOpQKMLZNBJuAT0b(CacRaite4b1R5e40z(uDHZjDSBaNDHlWSfczf48fezojmvGt)Y5VcboeCoRFM2oEvw7fjdqgcqQ0KapOEnNaVxLtq1ZAIHKq4cmLHczf48fezojmvGt)Y5VcbExauFa0hvsZY5ZTrkTw28A9fGmAeG(OsAwoFUnsP1(mzu3cqybGAbaz0iafuVKZA(yYIxaclsbOpQKMLZNBJuAT0b(CacRaitaOUbiJgbiOHcVaegaenwx)SkFaKHae0qHxlzyoa1aG6dGE4JHMxLTeHQEG0KWx51CRLLr4srHtc8G61Cc8ehEBnTDiXhKcxGPmxiRaNVGiZjHPcC6xo)viWF4JHMxLThVBDQ9IVZQ9puuQtvhkkXho8AzzeUuu4ea1aGGgk8cqgcqYJVcImBjj0)QPZ6c81)I6cmBkWdQxZjWProRdQxZPZ16c8CTU(cswGFEiCbMMHqwbEq9AoboTDiXhKRaNVGiZjHPcxGzRxiRaNVGiZjHPcC6xo)viWtJB32FOCCwtmKewVOsuNka1aG6cGsJBRZ5)ISMiZCQov76bvcaYqaYeaYOraknUDB)HYXznXqsyFMmQBbidbivAcG6wGhuVMtGta70283r4cmBAwHScC(cImNeMkWPF58xHapnUDB)HYXznXqsy9IkrDQaudaQpaAzxtmh8A9IFtmdTjkubEq9AobonE5SWfy2SPqwboFbrMtctf40VC(RqGtBhVkVAOpOEnxKbiSaqMyBba1aGOZKttVZ2RYjO6znXqsyHGZz9Z02XRYAVizacla0QW5S2JxL9fGmaGmrGhuVMtGta70283r4cmBAIqwboFbrMtctf40VC(RqGdnu4fGWaGOX66Nv5dGmeGGgk8AjdZf4b1R5e4q54KOov96FjblCbMn7VqwboFbrMtctf40VC(RqGtNjNMENTxLtq1ZAIHKWcbNZ6NPTJxL1ErYaewaOvHZzThVk7lazaazIapOEnNaNgVCw4cmB2pczf48fezojmvGt)Y5VcbobmeKLmsAIHKi(uXVfwrGhuVMtG3RYjO6znXqsiCbMnBHqwboFbrMtctf4b1R5e4su5SMoKKXLe40VC(RqGNg3Q0M)HCowtmKewVOsuNka1aGw21eZbVwV43eZqBIcvGt7qZS2JxL9vGztHlWSPmuiRaNVGiZjHPcC6xo)viWjGHGSq5Od)RMmEjSWkc8G61CcCjQCwVThx4cmBkZfYkW5liYCsyQapOEnNahkhD4KEBpUaN2HMzThVk7RaZMcxGztZqiRaNVGiZjHPc8G61Cc8LFf(C961PkWPF58xHa)zON32brMbOgauFaKxujQtfGAaqhBUR7vAIHKWkFYHxzgGAaqE8QSB9IK1(OtfdqybGA2caQbabnu4fGWaGOX66Nv5dGWca1)waqnaOG6LCwZhtw8cqgkfG6hbUhVk76csGlCbMnB9czf48fezojmvGhuVMtGlrLZA6qsgxsGt)Y5Vcbo0qHxacdaIgRRFwLpaYqacAOWRLmmhGAaqqW5S(zA74vzTxKmaziaPstaudaQla6HpgAEv2E8U1P2l(oR2)qrPovDOOeF4WRLLr4srHtaudaIoton9ol0ZmwVovT)HI9zYOUfGAaq0zYPP3z941(hk2NjJ6waYOraQpa6HpgAEv2E8U1P2l(oR2)qrPovDOOeF4WRLLr4srHtau3cCAhAM1E8QSVcmBkCbMMywHScC(cImNeMkWPF58xHaVpaknUTxLtq1ZAIHKW6fvI6ubOgauFa0YUMyo416f)MygAtuOaKrJaeTD8Q8QH(G61CrgGWca102FbEq9AobEVkNGQN1edjHWfyAstHScC(cImNeMkWPF58xHaVlaQpa6yZDDVstmKe2T9hkhNbiJgbO(aipY852EvobvpRRdcER5S8fezobqDdqnai6m5007S9QCcQEwtmKewi4Cw)mTD8QS2lsgGWcaTkCoR94vzFbidaite4b1R5e4eWoTn)DeUattmriRapOEnNap0KWFIF9aPP)0Bf48fezojmv4cmnP)czf48fezojmvGt)Y5Vcbo0qHxacdaIgRRFwLpaYqacAOWRLmmxGhuVMtGVoZzT)HIWfyAs)iKvGZxqK5KWubEq9Aob(YVcFUE96uf40VC(RqG)m0ZB7GiZaudaYJmFUTDN0hRMOC2YxqK5ea1aG84vz36fjR9rNkgGWcazgcCAhAM1E8QSVcmBkCbMM0cHSc8G61CcCA8YzboFbrMtctfUattKHczf48fezojmvGhuVMtGlrLZA6qsgxsGt)Y5Vcbo0qHxacdaIgRRFwLpaYqacAOWRLmmhGAaqDbqp8XqZRY2J3To1EX3z1(hkk1PQdfL4dhETSmcxkkCcGAaq0zYPP3zHEMX61PQ9puSptg1TaudaIoton9oRhV2)qX(mzu3cqgncq9bqp8XqZRY2J3To1EX3z1(hkk1PQdfL4dhETSmcxkkCcG6wGt7qZS2JxL9vGztHlW0ezUqwbEq9AobUevoR32JlW5liYCsyQWfyAIziKvGZxqK5KWubEq9Aob(YVcFUE96uf40VC(RqG)m0ZB7GiZcCAhAM1E8QSVcmBkCbMM06fYkW5liYCsyQapOEnNaNCo1zwwtuolWPDOzw7XRY(kWSPWfy2FZkKvGZxqK5KWubEq9Aob(hk(861)scwGt7qZS2JxL9vGztHlCHlWLZ)wZjW0eZAIjM1etKHc8EXF1PUc8wMwUmdMTomntBnacGKTndqfPY8oabnpa1kLNPdjr4TcGEwgHRNta0oKmafW(qgoNaiA74u51cWULQJbOMTgajtZjNFNtauR8iZNBnZTcG8bGALhz(CRz2YxqK5uRaOWbOw2mtULaOUAAE3wa2aSBzA5Ymy26W0mT1aias22mavKkZ7ae08auRwVva0ZYiC9CcG2HKbOa2hYW5earBhNkVwa2TuDma1SfTgajtZjNFNtaeErkta0258WCasgaq(aqTeCaqPsET1Ca0OWF4ZdqDzq3auxnnVBlaBa2TmTCzgmBDyAM2AaeajBBgGksL5DacAEaQv002ka6zzeUEobq7qYaua7dz4CcGOTJtLxla7wQogGAA2wdGKP5KZVZjaQv7aNjQlznZTcG8bGA1oWzI6swZSLVGiZPwbqDzI5DBby3s1XauZ(3AaKmnNC(Dobq4fPmbqBNZdZbizaa5da1sWbaLk51wZbqJc)Hppa1LbDdqD108UTaSBP6yaQz)0AaKmnNC(Dobq4fPmbqBNZdZbizaa5da1sWbaLk51wZbqJc)Hppa1LbDdqD108UTaSBP6yaQzlAnasMMto)oNai8IuMaOTZ5H5aKmaG8bGAj4aGsL8AR5aOrH)WNhG6YGUbOUAAE3wa2aSBzA5Ymy26W0mT1aias22mavKkZ7ae08auRigLwbqplJW1ZjaAhsgGcyFidNtaeTDCQ8Aby3s1XauZ(3AaKmnNC(Dobq4fPmbqBNZdZbizaa5da1sWbaLk51wZbqJc)Hppa1LbDdqD108UTaSBP6yaQzlAnasMMto)oNaOw9WhdnVkBnZTcG8bGA1dFm08QS1mB5liYCQvauxnnVBla7wQogGAkdBnasMMto)oNai8IuMaOTZ5H5aKmaG8bGAj4aGsL8AR5aOrH)WNhG6YGUbOU6V5DBby3s1XautzyRbqY0CY535ea1kpY85wZCRaiFaOw5rMp3AMT8fezo1kaQltmVBla7wQogGAkdBnasMMto)oNaOw9WhdnVkBnZTcG8bGA1dFm08QS1mB5liYCQvauxnnVBla7wQogGAAgTgajtZjNFNtauR8iZNBnZTcG8bGALhz(CRz2YxqK5uRaOUAAE3wa2aSBzA5Ymy26W0mT1aias22mavKkZ7ae08auROzoKZTcGEwgHRNta0oKmafW(qgoNaiA74u51cWULQJbOMnBnasMMto)oNai8IuMaOTZ5H5aKmaG8bGAj4aGsL8AR5aOrH)WNhG6YGUbOUAAE3wa2TuDma1S)TgajtZjNFNtaeErkta0258WCasgaq(aqTeCaqPsET1Ca0OWF4ZdqDzq3auxnnVBla7wQogGAAgTgajZWKJCobqK11AMzaI2MPsaqDDJdqH8OYbrMbO6aiMeohEnx3auxnnVBla7wQogGmPzRbqY0CY535eaHxKYeaTDopmhGKbaKpaulbhauQKxBnhank8h(8auxg0na1vtZ72cWgGDRJuzENtaKmhGcQxZbq5A91cWwGVkmvGPjTOfcCLFGQmlWXAbiC4xEjpYaKzsWNZpaBSwacRz802aulKeGmXSMycaBa2b1R5wRYZ0HKiCmKAG84RGiZsEbjlLKq)RMoRl5OiDzVGKuEKHzPb1R5SKZPoZYAIYzlDwxs5rgM1CEzPb1R5SFO4ZRx)ljylDwxs6CPYR5K6rMp3soN6mlRjkNbyhuVMBTkpthsIWXqQblmj5CAf2byhuVMBTkpthsIWXqQbeJ7zoPHYrho1RovTpMxha7G61CRv5z6qseogsnakZBB6hqoa7G61CRv5z6qseogsnWJx7FOizbj9HpgAEv2UdCgAEvwZKe8VwwgHlffobWoOEn3AvEMoKeHJHudwN5S2)qbGna7G61ClgsnGegRJ1ZmaBSwaYmDaOOnhjakUeaj7hNmcx5cRZaeMMjitaeFmzXBl7aupgGsZ1khGsda5TRfGGMhGuYrh(xaIGPb8Yau5Tkbqema5ZaqRsqs2bGIlbq9yaIgxRCa65iv5oaKSFCYiaTkmTGkkaradbTwa2b1R5wmKAG)XjJWvUW61PQ32JlzbjTppEv2T1QvYrh(byhuVMBXqQbWlRlNjL8cswkwJXHpvU(xN41RRZQProlzbjnOEjN18XKfVsB2OlcyiilDMpvx4Csh7gWz3cRy0yF0zYPP3zPZ8P6cNt6y3ao72NjJ6wJgjMDB4fjR9rNk2W(B2UnASRG6LCwZhtw8ILMniGHGSpVZfEDQ64)PNfwXOrcyiilDMpvx4Csh7gWz3cR0na7G61ClgsnaEzD5m5cWgRfRfGAzX5Odabf06ubOod8dqPbMWbi4ZRma1zGbO2HCgGuGDasMH35cVovaQL))0dGstVtsaAEaQGaiVndq0zYPP3bq1cq(mauEovaYhakX5Odabf06ubOod8dqTSgyc3cqToia6MJbObcG828YaeDUu51ClafpdqbrMbiFais2bOEL3UoaYBZautZcqltNlTauM5ErhjbiVndqBrcqqbLxaQZa)aulRbMWbOa2hYWlAKZDSaSXAXAbOG61Clgsn44Eqd8L0pVtwolzbjDh4mrDj7X9Gg4lPFENSCUrxeWqq2N35cVovD8)0ZcRy0iDMCA6D2N35cVovD8)0Z(mzu3ILMM1OrpEv2TErYAF0PInSPmSBa2b1R5wmKAanYzDq9AoDUwxYlizP00cWoOEn3IHudOroRdQxZPZ16sEbjlLyuKC9VOU0MswqsdQxYznFmzXRH9VHhz(Clr9PvpqALN7y5liYCcGDq9AUfdPgqJCwhuVMtNR1L8csw66sU(xuxAtjliPb1l5SMpMS41W(3OppY85wI6tREG0kp3XYxqK5ea7G61ClgsnGg5SoOEnNoxRl5fKSuAMd5SKR)f1L2uYcsAq9soR5JjlEXIjaSdQxZTyi1G4PXXAF(NphGna7G61CRLyuKU8RWNRxVovjPDOzw7XRY(kTPKfKucyiiR8sH)vlNVH0(mzu32OlcyiiR8sH)vlNVH0(mzu3AOknz04ZqpVTdIm3na7G61CRLyuWqQbsu5SMoKKXLKK2HMzThVk7R0MswqsHgk8Ibnwx)SkFgcnu41sgM3GagcYE8wNAV47SA)dfL6u1HIs8HdVwyfJgHgk8Ibnwx)SkFgcnu41sgMJrtZ2GagcYE8wNAV47SA)dfL6u1HIs8HdVwyLgeWqq2J36u7fFNv7FOOuNQouuIpC41(mzu3AOknbWoOEn3AjgfmKAGevoR32JdWoOEn3AjgfmKAqVkNGQN1edjHKfKuOHcVyqJ11pRYNHqdfETKH5nGGZz9Z02XRYAVizdvPjJgjGHGSKrstmKeXNk(TWkaSdQxZTwIrbdPgaLJtI6u1R)LeSKfKuOHcVyqJ11pRYNHqdfETKH5aSdQxZTwIrbdPgaLJoCsVThhGDq9AU1smkyi1aAKZ6G61C6CTUKxqYsppKC9VOU0MswqsF4JHMxLThVBDQ9IVZQ9puuQtvhkkXho8AzzeUuu4udOHcVgkp(kiYSLKq)RMoRdWoOEn3AjgfmKAqIdVTM2oK4dsjliPqdfEXGgRRFwLpdHgk8AjdZbyhuVMBTeJcgsn4dfFE96FjbljTdnZApEv2xPnLSGKsadbzPZ8P6cNt6y3ao7wyLgeWqqw6mFQUW5Ko2nGZU9zYOU1WM2wGvQ0ea7G61CRLyuWqQbKZPoZYAIYzjPDOzw7XRY(kTPKfKucyiilDMpvx4Csh7gWz3cR0GagcYsN5t1foN0XUbC2Tptg1Tg202cSsLMayhuVMBTeJcgsni0KWFIF9aPP)0BbyhuVMBTeJcgsn4dfFE96FjbljTdnZApEv2xPnLSGKsadbz9srpqAVnRxfoE76bvcP9hGDq9AU1smkyi1aY5uNzznr5SK0o0mR94vzFL2uYcsQhz(CBKvAhALNtHpVLVGiZPgDradbzjNtDML1qWFhlSsdcyiil5CQZSSgc(7yFMmQBneAOWRmOl5XxbrMTKe6F10z9(LgRRFwLVUXkvAQBa2b1R5wlXOGHud6v5eu9SMyijKSGKcnu4fdASU(zv(meAOWRLmmVrFErLOo1gDbbNZ6NPTJxL1ErYgQstgn2xACBVkNGQN1edjH1lQe1P2GagcYsoN6mlRHG)o2NjJ6wSabNZ6NPTJxL1ErY9BtSsLMmASV042EvobvpRjgscRxujQtTrFeWqqwY5uNzzne83X(mzu32TrJErYAF0PInSPz0OV042EvobvpRjgscRxujQtfGnwla16GaOodmaLMRvoa1oKZaeM8U1P2l(oTAbiz)qrPovaQLROeF4WRKa0wKk5oaenwhGKzRCgGKPHKmUeavqauNbgG6nxRCaAKZpnuaO5aiZehk8cqq)qcqPPovaAhla16GaOodmaLgaQDiNbim5DRtTx8DA1cqY(HIsDQaulxrj(WHxaQZadqB7boNaiASoajZw5majtdjzCjaQGaOod8dqqdfEbOAbicop9aiVndq0zDaAGaiSMZPoZYaKPLZa08aKmtO4Zdq4(xsWaSdQxZTwIrbdPgirLZA6qsgxssAhAM1E8QSVsBkzbjfAOWlg0yD9ZQ8zi0qHxlzyEJU67HpgAEv2E8U1P2l(oR2)qrPovDOOeF4WRrJqdfEnuE8vqKzljH(xnDwVBa2yTault5Tbim5DRtTx8DA1cqY(HIsDQaulxrj(WHxaAUChasMTYzasMgsY4saubbqDg4hG8puwakEgGMdGOZKttVtsaA8283RwgGwFuai4TovasMTYzasMgsY4saubbqDg4hGOW)ZNdqqdfEbOGCGphGQfG4BGvBdq(aql86rDaK3MbOGCGphGgiaYlsgGYmKdqqZdqX1bGgiaQZa)aK)HYcq(aq0HKbObccGOZKttVdGDq9AU1smkyi1ajQCwthsY4sss7qZS2JxL9vAtjliPqdfEXGgRRFwLpdHgk8AjdZB8WhdnVkBpE36u7fFNv7FOOuNQouuIpC4TbDMCA6DwONzSEDQA)df7ZKrDlw6cAOWRmOl5XxbrMTKe6F10z9(LgRRFwLVUXkvAQ7g0zYPP3z941(hk2NjJ6wS0f0qHxzqxYJVcImBjj0)QPZ69lnwx)SkFDJvQ0u3n6QppY8521zoR9pumA0JmFUDDMZA)dLg0zYPP3zxN5S2)qX(mzu3ILUGgk8kd6sE8vqKzljH(xnDwVFPX66Nv5RBSsLM6UBa2b1R5wlXOGHudwN5S2)qrYcsk0qHxmOX66Nv5ZqOHcVwYWCa2b1R5wlXOGHudw(v4Z1RxNQK0o0mR94vzFL2uYcsAAC7YVcFUE96uTpd982oiYCJ(iGHGS0z(uDHZjDSBaNDlSIrJEK5ZTrwPDOvEof(8nEg65TDqK5g9radbzjNtDML1qWFhlSca7G61CRLyuWqQbpVZfEDQ64)Pha7G61CRLyuWqQb9QCsVk1x(cWoOEn3AjgfmKAaDMpvx4Csh7gWzxYcsAFeWqqw6mFQUW5Ko2nGZUfwbGDq9AU1smkyi1aY5uNzznr5SKfKucyiil5CQZSSgc(7yHvmAeAOWlgb1R5Ssu5SMoKKXLS0yD9ZQ8HfOHcVwYWCJgjGHGS0z(uDHZjDSBaNDlSca7G61CRLyuWqQbFO4ZRx)ljyjPDOzw7XRY(kTja7G61CRLyuWqQb9QCcQEwtmKeswqstJB7v5eu9SMyijSpd982oiYma7G61CRLyuWqQbl)k8561RtvsAhAM1E8QSVsBkzbjLagcYkVu4F1Y5BiTWkaSbyhuVMBT00kTD8kZCswqs9iZNBD(jx9aP5tnuzs(ClFbrMtnGgk8Ai0qHxlzyoa7G61CRLMwmKAarEMKgc(7izbjLagcYsN5t1foN0XUbC2TWkaSdQxZTwAAXqQbXr51)iRProlzbjLagcYsN5t1foN0XUbC2TWkaSdQxZTwAAXqQbq1Ze5zsswqsjGHGS0z(uDHZjDSBaNDlSca7G61CRLMwmKAqUuB7RgRbCsLKphGDq9AU1stlgsnGiu1dK2)IkXkzbjLoton9oRevoRPdjzCjleCoRFM2oEvw7fjJfvAcGDq9AU1stlgsnGG)LFjQtvYcskbmeKLoZNQlCoPJDd4SBHvmA0lsw7JovSHn7pa7G61CRLMwmKAajmwhRNza2b1R5wlnTyi1aLXR5KSGKsm72aQuB76NjJ6wdnPfgnsadbzPZ8P6cNt6y3ao7wyfa2b1R5wlnTyi1aOmVTPFa5swNZ)dR46cskTDChNRtTrF7aNjQlzvGxhoZA(Hv8AojliPDbnu41qzUznAKoton9olDMpvx4Csh7gWz3(mzu3AOkn1DJU2botuxYQaVoCM18dR41CgnUdCMOUKv(KdVYSENSC(8geWqqw5to8kZ6DYY5ZTPP31na7G61CRLMwmKAGhV2)qrYcsk0qHxmOX66Nv5ZqOHcVwYW8gp8XqZRY2DGZqZRYAMKG)1YYiCPOWPgE8A)df7ZKrDRHQ0ud6m5007Sq54z7ZKrDRHQ0uJUcQxYznFmzXlwAA0yq9soR5JjlEL2SHxKS2hDQyS0cSsLM6gGDq9AU1stlgsnakhplzUowttsnPfswqsHgk8Ibnwx)SkFgcnu41sgM3WJx7FOyHvA8WhdnVkB3bodnVkRzsc(xllJWLIcNA4fjR9rNkgl9dwPstaSdQxZTwAAXqQbsu5SEBpUKfK0G6LCwZhtw8kTzdpEv2TErYAF0PIneAOWRmOl5XxbrMTKe6F10z9(LgRRFwLVUXkvAcGDq9AU1stlgsnGCo1zwwtuolzbjnOEjN18XKfVsB2WJxLDRxKS2hDQydHgk8kd6sE8vqKzljH(xnDwVFPX66Nv5RBSsLMayhuVMBT00IHud(qXNxV(xsWswqsdQxYznFmzXR0Mn84vz36fjR9rNk2qOHcVYGUKhFfez2ssO)vtN17xASU(zv(6gRuPja2b1R5wlnTyi1GyvyQRhiT3M1COMzjliPE8QSBt16XrzSivgcWgGDq9AU1sZCiNLU8RWNRxVovjPDOzw7XRY(kTPKfKupY8522DsFSAIYzlFbrMtniGHGSYlf(xTC(gs7ZKrDBdcyiiR8sH)vlNVH0(mzu3AOknbWoOEn3APzoKZyi1GEvoPxL6lFLSGK23hvsZY5ZTrkTw28A91OXpQKMLZNBJuATptg1TyrAtZA0yq9soR5JjlEXI0pQKMLZNBJuAT0b(CSYea2b1R5wlnZHCgdPg88ox41PQJ)NEswqs77JkPz5852iLwlBET(A04hvsZY5ZTrkT2NjJ6wSi1mmAmOEjN18XKfVyr6hvsZY5ZTrkTw6aFowzca7G61CRLM5qoJHudOZ8P6cNt6y3ao7swqs77JkPz5852iLwlBET(A04hvsZY5ZTrkT2NjJ6wSiTPznAmOEjN18XKfVyr6hvsZY5ZTrkTw6aFowzca7G61CRLM5qoJHud6v5eu9SMyijKSGKcbNZ6NPTJxL1ErYgQstaSdQxZTwAMd5mgsniXH3wtBhs8bPKfK0U67JkPz5852iLwlBET(A04hvsZY5ZTrkT2NjJ6wS0cJgdQxYznFmzXlwK(rL0SC(CBKsRLoWNJvM0TrJqdfEXGgRRFwLpdHgk8AjdZB03dFm08QSLiu1dKMe(kVMBTSmcxkkCcGDq9AU1sZCiNXqQb0iN1b1R505ADjVGKLEEi56FrDPnLSGK(WhdnVkBpE36u7fFNv7FOOuNQouuIpC41YYiCPOWPgqdfEnuE8vqKzljH(xnDwhGDq9AU1sZCiNXqQb02HeFqUaSdQxZTwAMd5mgsnGa2PT5VJKfK0042T9hkhN1edjH1lQe1P2OR0426C(ViRjYmNQt1UEqLWqtmAmnUDB)HYXznXqsyFMmQBnuLM6gGDq9AU1sZCiNXqQb04LZswqstJB32FOCCwtmKewVOsuNAJ(w21eZbVwV43eZqBIcfGDq9AU1sZCiNXqQbeWoTn)DKSGKsBhVkVAOpOEnxKXIj2w0Goton9oBVkNGQN1edjHfcoN1ptBhVkR9IKXYQW5S2JxL9vgyca7G61CRLM5qoJHudGYXjrDQ61)scwYcsk0qHxmOX66Nv5ZqOHcVwYWCa2b1R5wlnZHCgdPgqJxolzbjLoton9oBVkNGQN1edjHfcoN1ptBhVkR9IKXYQW5S2JxL9vgyca7G61CRLM5qoJHud6v5eu9SMyijKSGKsadbzjJKMyijIpv8BHvayhuVMBT0mhYzmKAGevoRPdjzCjjPDOzw7XRY(kTPKfK004wL28pKZXAIHKW6fvI6uBSSRjMdETEXVjMH2efka7G61CRLM5qoJHudKOYz92ECjliPeWqqwOC0H)vtgVewyfa2b1R5wlnZHCgdPgaLJoCsVThxsAhAM1E8QSVsBcWoOEn3APzoKZyi1GLFf(C961PkPhVk76cskzDT2ZKrDRKfK0NHEEBhezUrFErLOo1ghBUR7vAIHKWkFYHxzUHhVk7wVizTp6uXyPzlAanu4fdASU(zv(Ws)BrJG6LCwZhtw8AO0(bGDq9AU1sZCiNXqQbsu5SMoKKXLKK2HMzThVk7R0MswqsHgk8Ibnwx)SkFgcnu41sgM3acoN1ptBhVkR9IKnuLMA01dFm08QS94DRtTx8DwT)HIsDQ6qrj(WHxllJWLIcNAqNjNMENf6zgRxNQ2)qX(mzu32Goton9oRhV2)qX(mzu3A0yFp8XqZRY2J3To1EX3z1(hkk1PQdfL4dhETSmcxkkCQBa2b1R5wlnZHCgdPg0RYjO6znXqsizbjTV042EvobvpRjgscRxujQtTrFl7AI5GxRx8BIzOnrHA0iTD8Q8QH(G61CrglnT9hGDq9AU1sZCiNXqQbeWoTn)DKSGK2vFhBUR7vAIHKWUT)q54SrJ95rMp32RYjO6zDDqWBnNLVGiZPUBqNjNMENTxLtq1ZAIHKWcbNZ6NPTJxL1ErYyzv4Cw7XRY(kdmbGDq9AU1sZCiNXqQbHMe(t8Rhin9NEla7G61CRLM5qoJHudwN5S2)qrYcsk0qHxmOX66Nv5ZqOHcVwYWCa2b1R5wlnZHCgdPgS8RWNRxVovjPDOzw7XRY(kTPKfK0NHEEBhezUHhz(CB7oPpwnr5SLVGiZPgE8QSB9IK1(OtfJfZaGDq9AU1sZCiNXqQb04LZaSdQxZTwAMd5mgsnqIkN10HKmUKK0o0mR94vzFL2uYcsk0qHxmOX66Nv5ZqOHcVwYW8gD9WhdnVkBpE36u7fFNv7FOOuNQouuIpC41YYiCPOWPg0zYPP3zHEMX61PQ9puSptg1TnOZKttVZ6XR9puSptg1Tgn23dFm08QS94DRtTx8DwT)HIsDQ6qrj(WHxllJWLIcN6gGDq9AU1sZCiNXqQbsu5SEBpoa7G61CRLM5qoJHudw(v4Z1RxNQK0o0mR94vzFL2uYcs6ZqpVTdImdWoOEn3APzoKZyi1aY5uNzznr5SK0o0mR94vzFL2eGDq9AU1sZCiNXqQbFO4ZRx)ljyjPDOzw7XRY(kTjaBa2b1R5w75H01zoR9puayhuVMBTNhyi1aONzSEDQA)dfjliP9radbz7v5KEvQV81(mzu3A0ibmeKTxLt6vP(Yx7ZKrDBd6m5007Ssu5SMoKKXLSptg1TaSdQxZT2ZdmKAGhV2)qrYcsAFeWqq2EvoPxL6lFTptg1Tgnsadbz7v5KEvQV81(mzu32Goton9oRevoRPdjzCj7ZKrDlaBa2b1R5w76stC4T102HeFqkzbjfAOWlg0yD9ZQ8zi0qHxlzyEJU67JkPz5852iLwlBET(A0yFFujnlNp3gP0AHvA8rL0SC(CBKsRnb)HxZHXhvsZY5ZTrkT26mSfDB04hvsZY5ZTrkTwyLgFujnlNp3gP0AFMmQBXs)ywa2b1R5w76yi1GLFf(C961PkjTdnZApEv2xPnLSGK2xAC7YVcFUE96uTErLOo1gE8QSB9IK1(OtfJfzUrJeWqqw5Lc)RwoFdPfwPbbmeKvEPW)QLZ3qAFMmQBnuLMayhuVMBTRJHudGYrhoP32JdWoOEn3AxhdPg88ox41PQJ)NEswqs77JkPz5852iLwlBET(A0yFFujnlNp3gP0AHvA01hvsZY5ZTrkT2e8hEnhgFujnlNp3gP0ARZqtmRrJFujnlNp3gP0APd85sB2TrJFujnlNp3gP0AHvA8rL0SC(CBKsR9zYOUfl9JznAKy2THxKS2hDQydBAwa2b1R5w76yi1GEvoPxL6lFLSGK23hvsZY5ZTrkTw28A91OX((OsAwoFUnsP1cR04JkPz5852iLwBc(dVMdJpQKMLZNBJuAT1zOjM1OXpQKMLZNBJuATWkn(OsAwoFUnsP1(mzu3IftmRrJeZUn8IK1(OtfBOjMfGDq9AU1UogsnGoZNQlCoPJDd4SlzbjTVpQKMLZNBJuATS516RrJ0roFX52RuB7AOGBqNjNMENTxLt6vP(Yx7ZKrDRrJ9rh58fNBVsTTRHcUrx99rL0SC(CBKsRfwPXhvsZY5ZTrkT2e8hEnhgFujnlNp3gP0ARZW(BwJg)OsAwoFUnsP1cR04JkPz5852iLw7ZKrDlwmXSgn23hvsZY5ZTrkTwyLUnAKy2THxKS2hDQyd7VzbyhuVMBTRJHudKOYz92ECa2b1R5w76yi1aOCCsuNQE9VKGLSGKcnu4fdASU(zv(meAOWRLmmhGDq9AU1Uogsni0KWFIF9aPP)0BbyhuVMBTRJHud6v5eu9SMyijKSGKcbNZ6NPTJxL1ErYgAcwPstnw21eZbVwV43eZqBIc1OrcyiilzK0edjr8PIFlSIrJ9TSRjMdETEXVjMH2efAJUGGZz9Z02XRYAVizdvPjJgHgk8Ibnwx)SkFgcnu41sgM3ORJn319knXqsyLp5WRm3inUD5xHpxVEDQwVOsuNAJ042LFf(C961PAFg65TDqKzJgp2Cx3R0edjHvPn)d5CCJ(iGHGSKZPoZYAi4VJfwPb0qHxmOX66Nv5ZqOHcVwYW8(nOEnNvIkN10HKmUKLgRRFwLpSQ)DB0iXSBdVizTp6uXg20SDdWoOEn3AxhdPgirLZA6qsgxssAhAM1E8QSVsBkzbjDzxtmh8A9IFtmdTjk0gPXTkT5FiNJ1edjH1lQe1P2OpcyiilzK0edjr8PIFlSca7G61CRDDmKAanE5SKfK0G6LCwZhtw8ILMn67HpgAEv2(DYHeRhzj4F105Gg4lvNQE9VKGxllJWLIcNayhuVMBTRJHudiGDAB(7izbjnOEjN18XKfVyPzJ(E4JHMxLTFNCiX6rwc(xnDoOb(s1PQx)lj41YYiCPOWPg0zYPP3z7v5eu9SMyijSqW5S(zA74vzTxKmwwfoN1E8QSVn6I2oEvE1qFq9AUiJftSTWOX042T9hkhN1edjH1lQe1P2na7G61CRDDmKAW6mN1(hkswqsHgk8Ibnwx)SkFgcnu41sgMdWoOEn3AxhdPgqoN6mlRjkNLK2HMzThVk7R0Mswqs9iZNBJSs7qR8Ck85T8fezo1Olcyiil5CQZSSgc(7yHvAqadbzjNtDML1qWFh7ZKrDRHqdfELbDjp(kiYSLKq)RMoR3V0yD9ZQ81nwPstn6JagcY2RYj9QuF5R9zYOU1Orcyiil5CQZSSgc(7yFMmQBBCS5UUxPjgscRsB(hY54UbyhuVMBTRJHudKOYznDijJljjTdnZApEv2xPnLSGKcbNZ6NPTJxL1ErYgQstnGgk8Ibnwx)SkFgcnu41sgMdWoOEn3AxhdPg8HIpVE9VKGLK2HMzThVk7R0MswqsjGHGSEPOhiT3M1RchVD9GkH0(B0yAC72(dLJZAIHKW6fvI6ubyhuVMBTRJHudiNtDML1eLZswqstJB32FOCCwtmKewVOsuNka7G61CRDDmKAWYVcFUE96uLK2HMzThVk7R0MswqsFg65TDqK5gE8QSB9IK1(OtfJfzUrJeWqqw5Lc)RwoFdPfwbGDq9AU1UogsnOxLtq1ZAIHKqYcs6XM76ELMyijSB7puoo3aAOWlwKhFfez2ssO)vtN1XktAKg3U8RWNRxVov7ZKrDlwAbwPstaSdQxZT21XqQb02HeFqUaSdQxZT21XqQbsu5SMoKKXLKK2HMzThVk7R0MswqsHgk8Ibnwx)SkFgcnu41sgMdWoOEn3AxhdPg0RYjO6znXqsizbj9HpgAEv2(DYHeRhzj4F105Gg4lvNQE9VKGxllJWLIcNayhuVMBTRJHudiNtDML1eLZss7qZS2JxL9vAtjliPeWqqwY5uNzzne83XcRy0i0qHxmcQxZzLOYznDijJlzPX66Nv5dlqdfETKH59BZwy0yAC72(dLJZAIHKW6fvI6unAKagcY2RYj9QuF5R9zYOUfGDq9AU1Uogsn4dfFE96FjbljTdnZApEv2xPnbyhuVMBTRJHud6v5eu9SMyijKSGK21XM76ELMyijSYNC4vMBKg3U8RWNRxVovRxujQt1OXJn319knXqsyvAZ)qohB04XM76ELMyijSB7puoo3aAOWlwAHz7UrFl7AI5GxRx8BIzOnrHkCHlea]] )


end