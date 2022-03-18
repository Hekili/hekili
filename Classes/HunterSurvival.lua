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

            texture = 2065635,
            bind = "wildfire_bomb",
            talent = "wildfire_infusion",

            usable = function () return current_wildfire_bomb == "pheromone_bomb" end,
            impact = function ()
                applyDebuff( "target", "pheromone_bomb" )
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
            -- id = 270335,
            known = 259495,
            cast = 0,
            charges = function () return talent.guerrilla_tactics.enabled and 2 or nil end,
            cooldown = function () return buff.mad_bombardier.up and 0 or 18 end,
            recharge = function () return buff.mad_bombardier.up and 0 or 18 end,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,

            texture = 2065637,
            bind = "wildfire_bomb",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "shrapnel_bomb" end,
            impact = function ()
                applyDebuff( "target", "shrapnel_bomb" )
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

            texture = 2065636,
            bind = "wildfire_bomb",
            velocity = 35,

            usable = function () return current_wildfire_bomb == "volatile_bomb" end,

            start = function ()
                removeBuff( "mad_bombardier" )
            end,

            impact = function ()
                if debuff.serpent_sting.up then applyDebuff( "target", "serpent_sting" ) end
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
            texture = function ()
                local a = current_wildfire_bomb and current_wildfire_bomb or "wildfire_bomb"
                if a == "wildfire_bomb" or not class.abilities[ a ] then return 2065634 end                
                return action[ a ].texture
            end,

            bind = function () return current_wildfire_bomb end,
            velocity = 35,

            start = function ()
                removeBuff( "flame_infusion" )
                removeBuff( "mad_bombardier" )
                if current_wildfire_bomb ~= "wildfire_bomb" then
                    runHandler( current_wildfire_bomb )
                end
            end,

            impact = function ()
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


    spec:RegisterPack( "Survival", 20220316, [[d8eV6bqiPsEeusvxIOaBsk8jPcgLuPoLuvwfusEfuywer3sQQ0UO0VOadJIIJjfTmkINjvvnnPI01KkQTjvv8nIIQXrrjNtQiSoOKY7OOuvnpkO7rK2huIdkvOAHuKEirrMifLQCrkkvLnsrPiFKIsPrsrPGtkveTsOuVKOO0mLkKBcLuPDcf9tkkf1qPOuOLsuu8uOAQeL(kfLkJvQqzVe(lPgmKdlSyeEmstwKlJAZG8zsA0sjNwYQHsQ41eHzlQBJODRQFR0WjXXjk0Yv55kMovxhuBNO67svgpfvNxk16jkO5tH2pWIMczf4PWzbMMygtmXm9Vz)yntNWmn7FNkW92kSaxjOseQSa)dswGJdFYl5rwGReTZBKeYkWNf(OSahRhGA5UYG1mWa1YBbtyPlPbtrcNdV2NEbKBWuKude4eWv27KVGqGNcNfyAIzmXeZ0)M9J1mDcZ0SzNqGhWER9e44fPmjWBvPe)ccbEIhQahh(KxYJmaz2a878bWgRBC0wauZ(rsaYeZyIjc8Cn(iKvG)EiKvGztHSc8G61(c8XzoR9lue48hezojmv4cmnriRaN)GiZjHPcC6voFviW7cGiGHGS9QCspk1v(ypMmQFaiJgbicyiiBVkN0JsDLp2JjJ6haQbar3nN2EVvIkN10LKm(K9yYO(rGhuV2xGdDmldRxv7xOiCbM9xiRaN)GiZjHPcC6voFviW7cGiGHGS9QCspk1v(ypMmQFaiJgbicyiiBVkN0JsDLp2JjJ6haQbar3nN2EVvIkN10LKm(K9yYO(rGhuV2xG7XP9lueUWf4jgkGZUqwbMnfYkWdQx7lWjHLHYWmlW5piYCsyQWfyAIqwbo)brMtctf4b1R9f4(fVmcx5sgwVQEATUapXd9kfV2xGB2Uau0IJeafFcGK9IxgHRCjdzactZgLjaIFMS4rsaQhdqP97GdqPfG8w1aqq7bqk5OnFdarW0aEyaQ8oKaicgG8DbOrjijBdqXNaOEmarJVdoaDCKQCBas2lEzeGgfMwqffGiGHGgRaNELZxfc8Uaipov2T1OvYrB(eUaZ(lKvGZFqK5KWubEq9AFbowN1HFvUUtN4XRV9OProlWPx58vHapOEjN18ZKfpaKuaQja1aG6gGiGHGS0DVu9HZjDmtaNDlScaz0ia1far3nN2EVLU7LQpCoPJzc4SBpMmQFaiJgbiIDgaQba5fjR9vNkgGmeG6VzaO(aiJgbOUbOG6LCwZptw8aqybGAcqnaicyii7XZ(HxVQoUB7zHvaiJgbicyiilD3lvF4CshZeWz3cRaq9jW)GKf4yDwh(v56oDIhV(2JMg5SWfy2Pczf4b1R9f4WdRlNjhbo)brMtctfUaZolKvGZFqK5KWubEq9AFbonYzDq9AFDUgxGNRX1FqYcCAAeUaZ(riRaN)GiZjHPcC6voFviWdQxYzn)mzXdazia1FaQba5rMF3suxA0lKw542w(dImNe4JFf1fy2uGhuV2xGtJCwhuV2xNRXf45AC9hKSaNyveUatzUqwbo)brMtctf40RC(QqGhuVKZA(zYIhaYqaQ)audaQlaYJm)ULOU0OxiTYXTT8hezojWh)kQlWSPapOETVaNg5SoOETVoxJlWZ146pizb(4cxGPzjKvGZFqK5KWubo9kNVke4b1l5SMFMS4bGWcazIaF8ROUaZMc8G61(cCAKZ6G61(6CnUapxJR)GKf40mhYzHlWStiKvGhuV2xGhhnEw77D87cC(dImNeMkCHlWvoMUKeHlKvGztHScC(dImNeMkWxfb(WEbjWPx58vHa3Jm)ULCF1DhwtuoB5piYCsGN4HELIx7lWX6ghTfa1SFKeGmXmMyIaxEC6pizbojH(gnDhxGhuV2xGlpUkiYSaxEKHznNhwGhuV23EHIVNE8RKGT0DCbU8idZc8G61(wY9v3Dynr5SLUJlCbMMiKvGhuV2xGpWKK7RvyxGZFqK5KWuHlWS)czf4b1R9f4eR7zoPHYrBo1REvTVMxVaN)GiZjHPcxGzNkKvGhuV2xGdL5Pf9cixGZFqK5KWuHlWSZczf48hezojmvGtVY5Rcb(b)m0EQSDw4m0EQSMjj4BSSmcxkkCsGhuV2xG7XP9lueUaZ(riRapOETVaFCMZA)cfbo)brMtctfUWf40mhYzHScmBkKvGZFqK5KWubEq9AFb(WNc)UE86vf40RC(QqG7rMF32QD6IrtuoB5piYCcGAaqeWqqw5LcFJwo)lP9yYO(bGAaqeWqqw5LcFJwo)lP9yYO(bGmeGuPjboTnnZApov2hbMnfUatteYkW5piYCsyQaNELZxfc8UaOlQKMLZVBJuASS514daz0iaDrL0SC(DBKsJ9yYO(bGWIuaQPzaiJgbOG6LCwZptw8aqyrkaDrL0SC(DBKsJLUWVdqyfazIapOETVaVxLt6rPUYhHlWS)czf48hezojmvGtVY5RcbExa0fvsZY53Trknw28A8bGmAeGUOsAwo)UnsPXEmzu)aqyrkazwaKrJauq9soR5NjlEaiSifGUOsAwo)UnsPXsx43biScGmrGhuV2xGF8SF41RQJ72EcxGzNkKvGZFqK5KWubo9kNVke4DbqxujnlNF3gP0yzZRXhaYOra6IkPz5872iLg7XKr9daHfPautZaqgncqb1l5SMFMS4bGWIua6IkPz5872iLglDHFhGWkaYebEq9AFboD3lvF4CshZeWzx4cm7Sqwbo)brMtctf40RC(QqGdbNZ6JPTItL1ErYaKHaKknjWdQx7lW7v5euDSMyjjeUaZ(riRaN)GiZjHPcC6voFviW7gG6cGUOsAwo)UnsPXYMxJpaKrJa0fvsZY53Trkn2JjJ6haclauNbiJgbOG6LCwZptw8aqyrkaDrL0SC(DBKsJLUWVdqyfazca1haz0iabTu4bGWaGOX46Jv5hGmeGGwk8yjdZbOgauxa0b)m0EQSLiu1lKMe(lV2FSSmcxkkCsGhuV2xGN4WBPPTcjUGu4cmL5czf48hezojmvGtVY5Rcb(b)m0EQS95zQxTxCThTFHIs9Q6qrjUWHhllJWLIcNaOgae0sHhaYqasECvqKzljH(gnDhxGp(vuxGztbEq9AFbonYzDq9AFDUgxGNRX1FqYc83dHlW0SeYkWdQx7lWPTcjUGCe48hezojmv4cm7eczf48hezojmvGtVY5RcbEAD706cLNZAILKW6fvI6vbOgau3auADB9oFFK1ezMt1RAhpOsaqgcqMaqgncqP1TtRluEoRjwsc7XKr9daziaPstauFc8G61(cCcyN2IV2cxGztZiKvGZFqK5KWubo9kNVke4P1TtRluEoRjwscRxujQxfGAaqDbqd7AI9HhRx8zIzPnrHkWdQx7lWPXjNfUaZMnfYkW5piYCsyQaNELZxfcCAR4u5rdDb1R9JmaHfaYeBNbOgaeD3CA792EvobvhRjwscleCoRpM2kovw7fjdqybGgfoN1ECQSpaKbaKjc8G61(cCcyN2IV2cxGztteYkW5piYCsyQaNELZxfcCOLcpaegaengxFSk)aKHae0sHhlzyUapOETVahkhVe1RQh)kjyHlWSz)fYkW5piYCsyQaNELZxfcC6U5027T9QCcQowtSKewi4CwFmTvCQS2lsgGWcankCoR94uzFaidaite4b1R9f404KZcxGzZoviRaN)GiZjHPcC6voFviWjGHGSKrstSKeXLk(SWkc8G61(c8EvobvhRjwscHlWSzNfYkW5piYCsyQapOETVaxIkN10LKm(KaNELZxfc806wLw8TK7ZAILKW6fvI6vbOga0WUMyF4X6fFMywAtuOcCABAM1ECQSpcmBkCbMn7hHScC(dImNeMkWPx58vHaNagcYcLJ28nAY4KWcRiWdQx7lWLOYz90ADHlWSPmxiRaN)GiZjHPc8G61(cCOC0Mt6P16cCABAM1ECQSpcmBkCbMnnlHScC(dImNeMkWdQx7lWh(u431JxVQaNELZxfc8JHoEAfezgGAaqDbqErLOEvaQba9S5UUxPjwscR8nhELzaQba5XPYU1lsw7RovmaHfaQzNbOgae0sHhacdaIgJRpwLFaclau)7ma1aGcQxYzn)mzXdazOuaQtf4020mR94uzFey2u4cmB2jeYkW5piYCsyQapOETVaxIkN10LKm(KaNELZxfcCOLcpaegaengxFSk)aKHae0sHhlzyoa1aGGGZz9X0wXPYAVizaYqasLMaOgau3a0b)m0EQS95zQxTxCThTFHIs9Q6qrjUWHhllJWLIcNaOgaeD3CA79wOJzzy9QA)cf7XKr9da1aGO7MtBV36XP9luShtg1paKrJauxa0b)m0EQS95zQxTxCThTFHIs9Q6qrjUWHhllJWLIcNaO(e4020mR94uzFey2u4cmnXmczf48hezojmvGtVY5RcbExauADBVkNGQJ1eljH1lQe1RcqnaOUaOHDnX(WJ1l(mXS0MOqbiJgbiAR4u5rdDb1R9JmaHfaQPT)c8G61(c8EvobvhRjwscHlW0KMczf48hezojmvGtVY5RcbE3auxa0ZM76ELMyjjStRluEodqgncqDbqEK53T9QCcQowxpe8u7B5piYCcG6dGAaq0DZPT3B7v5euDSMyjjSqW5S(yAR4uzTxKmaHfaAu4Cw7XPY(aqgaqMiWdQx7lWjGDAl(AlCbMMyIqwbEq9AFbEOjHVeF6fstVT3iW5piYCsyQWfyAs)fYkW5piYCsyQaNELZxfcCOLcpaegaengxFSk)aKHae0sHhlzyUapOETVaFCMZA)cfHlW0KoviRaN)GiZjHPc8G61(c8Hpf(D941RkWPx58vHa)yOJNwbrMbOgaKhz(DBR2Plgnr5SL)GiZjaQba5XPYU1lsw7RovmaHfaYSe4020mR94uzFey2u4cmnPZczf4b1R9f404KZcC(dImNeMkCbMM0pczf48hezojmvGhuV2xGlrLZA6ssgFsGtVY5Rcbo0sHhacdaIgJRpwLFaYqacAPWJLmmhGAaqDdqh8Zq7PY2NNPE1EX1E0(fkk1RQdfL4chESSmcxkkCcGAaq0DZPT3BHoMLH1RQ9luShtg1paudaIUBoT9ERhN2VqXEmzu)aqgncqDbqh8Zq7PY2NNPE1EX1E0(fkk1RQdfL4chESSmcxkkCcG6tGtBtZS2JtL9rGztHlW0ezUqwbEq9AFbUevoRNwRlW5piYCsyQWfyAIzjKvGZFqK5KWubEq9AFb(WNc)UE86vf40RC(QqGFm0XtRGiZcCABAM1ECQSpcmBkCbMM0jeYkW5piYCsyQapOETVaNCF1DhwtuolWPTPzw7XPY(iWSPWfy2FZiKvGZFqK5KWubEq9AFb(fk(E6XVscwGtBtZS2JtL9rGztHlCbonnczfy2uiRaN)GiZjHPcC6voFviW9iZVBD(ih9cP5xnuzs(Dl)brMtaudacAPWdaziabTu4XsgMlWdQx7lWBfNYUVWfyAIqwbo)brMtctf40RC(QqGtadbzP7EP6dNt6yMao7wyfbEq9AFborE3Kgc(AlCbM9xiRaN)GiZjHPcC6voFviWjGHGS0DVu9HZjDmtaNDlSIapOETVapEkp(fznnYzHlWStfYkW5piYCsyQaNELZxfcCcyiilD3lvF4CshZeWz3cRiWdQx7lWHQJjY7MeUaZolKvGhuV2xGNl1w(OX6aNuj53f48hezojmv4cm7hHScC(dImNeMkWPx58vHaNUBoT9ERevoRPljz8jleCoRpM2kovw7fjdqybGuPjbEq9AFborOQxiTFfvIr4cmL5czf48hezojmvGtVY5RcbobmeKLU7LQpCoPJzc4SBHvaiJgbiVizTV6uXaKHauZ(lWdQx7lWj4B4tI6vfUatZsiRapOETVaNewgkdZSaN)GiZjHPcxGzNqiRaN)GiZjHPcC6voFviWj2zaOgaeuP2Y1htg1paKHaKjDgGmAeGiGHGS0DVu9HZjDmtaNDlSIapOETVaxz9AFHlWSPzeYkW5piYCsyQaNELZxfc8UbiOLcpaKHaKm3maKrJaeD3CA79w6UxQ(W5KoMjGZU9yYO(bGmeGuPjaQpaQba1nanlCMO(KvbEC4mR5dwXR9T8hezobqgncqZcNjQpzLV5WRmRNnlNF3YFqK5ea1aGiGHGSY3C4vM1ZMLZVBtBVhG6tGhuV2xGdL5Pf9cixGxVZ3bR46csGtBf)Z56vB01SWzI6twf4XHZSMpyfV2x4cmB2uiRaN)GiZjHPcC6voFviWHwk8aqyaq0yC9XQ8dqgcqqlfESKH5auda6GFgApv2olCgApvwZKe8nwwgHlffobqnaipoTFHI9yYO(bGmeGuPjaQbar3nN2EVfkhhBpMmQFaidbivAcGAaqDdqb1l5SMFMS4bGWca1eGmAeGcQxYzn)mzXdajfGAcqnaiVizTV6uXaewaOodqyfaPstauFc8G61(cCpoTFHIWfy20eHScC(dImNeMkWdQx7lWHYXXcC6voFviWHwk8aqyaq0yC9XQ8dqgcqqlfESKH5audaYJt7xOyHvaOga0b)m0EQSDw4m0EQSMjj4BSSmcxkkCcGAaqErYAF1PIbiSaqDkaHvaKknjWZ1ZAAsGBsNfUaZM9xiRaN)GiZjHPcC6voFviWdQxYzn)mzXdajfGAcqnaipov2TErYAF1PIbidbiOLcpaKbau3aK84QGiZwsc9nA6ooa1VaengxFSk)auFaewbqQ0KapOETVaxIkN1tR1fUaZMDQqwbo)brMtctf40RC(QqGhuVKZA(zYIhaska1eGAaqECQSB9IK1(QtfdqgcqqlfEaidaOUbi5XvbrMTKe6B00DCaQFbiAmU(yv(bO(aiScGuPjbEq9AFbo5(Q7oSMOCw4cmB2zHScC(dImNeMkWPx58vHapOEjN18ZKfpaKuaQja1aG84uz36fjR9vNkgGmeGGwk8aqgaqDdqYJRcImBjj03OP74au)cq0yC9XQ8dq9bqyfaPstc8G61(c8lu890JFLeSWfy2SFeYkW5piYCsyQaNELZxfcCpov2TPA84PmaHfPau)iWdQx7lWJrHPUEH0ElwZHAMfUWf4JlKvGztHScC(dImNeMkWPx58vHahAPWdaHbarJX1hRYpaziabTu4XsgMdqnaOUbOUaOlQKMLZVBJuASS514daz0ia1faDrL0SC(DBKsJfwbGAaqxujnlNF3gP0ytWx41(aega0fvsZY53Trkn26bidbOodq9bqgncqxujnlNF3gP0yHvaOga0fvsZY53Trkn2JjJ6haclauNAgbEq9AFbEIdVLM2kK4csHlW0eHScC(dImNeMkWdQx7lWh(u431JxVQaNELZxfc8UaO062Hpf(D941RA9Ikr9QaudaYJtLDRxKS2xDQyaclaKmhGmAeGiGHGSYlf(gTC(xslSca1aGiGHGSYlf(gTC(xs7XKr9daziaPstcCABAM1ECQSpcmBkCbM9xiRapOETVahkhT5KEATUaN)GiZjHPcxGzNkKvGZFqK5KWubo9kNVke4DbqxujnlNF3gP0yzZRXhaYOraQla6IkPz5872iLglSca1aG6gGUOsAwo)UnsPXMGVWR9bimaOlQKMLZVBJuAS1dqgcqMygaYOra6IkPz5872iLglDHFhGKcqnbO(aiJgbOlQKMLZVBJuASWkauda6IkPz5872iLg7XKr9daHfaQtndaz0iarSZaqnaiVizTV6uXaKHautZiWdQx7lWpE2p86v1XDBpHlWSZczf48hezojmvGtVY5RcbExa0fvsZY53Trknw28A8bGmAeG6cGUOsAwo)UnsPXcRaqnaOlQKMLZVBJuASj4l8AFacda6IkPz5872iLgB9aKHaKjMbGmAeGUOsAwo)UnsPXcRaqnaOlQKMLZVBJuAShtg1paewaitmdaz0iarSZaqnaiVizTV6uXaKHaKjMrGhuV2xG3RYj9Oux5JWfy2pczf48hezojmvGtVY5RcbExa0fvsZY53Trknw28A8bGmAeGORC(J3TFP2Y1qbdqnai6U5027T9QCspk1v(ypMmQFaiJgbOUai6kN)4D7xQTCnuWaudaQBaQla6IkPz5872iLglSca1aGUOsAwo)UnsPXMGVWR9bimaOlQKMLZVBJuAS1dqgcq93maKrJa0fvsZY53TrknwyfaQbaDrL0SC(DBKsJ9yYO(bGWcazIzaiJgbOUaOlQKMLZVBJuASWkauFaKrJaeXoda1aG8IK1(Qtfdqgcq93mc8G61(cC6UxQ(W5KoMjGZUWfykZfYkWdQx7lWLOYz90ADbo)brMtctfUatZsiRaN)GiZjHPcC6voFviWHwk8aqyaq0yC9XQ8dqgcqqlfESKH5c8G61(cCOC8suVQE8RKGfUaZoHqwbEq9AFbEOjHVeF6fstVT3iW5piYCsyQWfy20mczf48hezojmvGtVY5RcboeCoRpM2kovw7fjdqgcqMaqyfaPstaudaAyxtSp8y9IptmlTjkuaYOraIagcYsgjnXssexQ4ZcRaqgncqDbqd7AI9HhRx8zIzPnrHcqnaOUbii4CwFmTvCQS2lsgGmeGuPjaYOracAPWdaHbarJX1hRYpaziabTu4XsgMdqnaOUbONn319knXssyLV5WRmdqnaO062Hpf(D941RA9Ikr9QaudakTUD4tHFxpE9Q2JHoEAfezgGmAeGE2Cx3R0eljHvPfFl5(ma1aG6cGiGHGSK7RU7WAi4RTfwbGAaqqlfEaimaiAmU(yv(bidbiOLcpwYWCaQFbOG61(wjQCwtxsY4twAmU(yv(biScG6pa1haz0iarSZaqnaiVizTV6uXaKHautZaq9jWdQx7lW7v5euDSMyjjeUaZMnfYkW5piYCsyQapOETVaxIkN10LKm(KaNELZxfc8HDnX(WJ1l(mXS0MOqbOgauADRsl(wY9znXssy9Ikr9QaudaQlaIagcYsgjnXssexQ4ZcRiWPTPzw7XPY(iWSPWfy20eHScC(dImNeMkWPx58vHapOEjN18ZKfpaewaOMaudaQla6GFgApv2ETZHeJhzj4B009Hw4pvVQE8RKGhllJWLIcNe4b1R9f404KZcxGzZ(lKvGZFqK5KWubo9kNVke4b1l5SMFMS4bGWca1eGAaqDbqh8Zq7PY2RDoKy8ilbFJMUp0c)P6v1JFLe8yzzeUuu4ea1aGO7MtBV32RYjO6ynXssyHGZz9X0wXPYAVizacla0OW5S2JtL9bGAaqDdq0wXPYJg6cQx7hzaclaKj2odqgncqP1TtRluEoRjwscRxujQxfG6tGhuV2xGta70w81w4cmB2Pczf48hezojmvGtVY5Rcbo0sHhacdaIgJRpwLFaYqacAPWJLmmxGhuV2xGpoZzTFHIWfy2SZczf48hezojmvGhuV2xGtUV6UdRjkNf40RC(QqG7rMF3gzLwHw54u47z5piYCcGAaqDdqeWqqwY9v3Dyne812cRaqnaicyiil5(Q7oSgc(ABpMmQFaidbiOLcpaKbau3aK84QGiZwsc9nA6ooa1VaengxFSk)auFaewbqQ0ea1aG6cGiGHGS9QCspk1v(ypMmQFaiJgbicyiil5(Q7oSgc(ABpMmQFaOga0ZM76ELMyjjSkT4Bj3NbO(e4020mR94uzFey2u4cmB2pczf48hezojmvGhuV2xGlrLZA6ssgFsGtVY5RcboeCoRpM2kovw7fjdqgcqQ0ea1aGGwk8aqyaq0yC9XQ8dqgcqqlfESKH5cCABAM1ECQSpcmBkCbMnL5czf48hezojmvGhuV2xGFHIVNE8RKGf40RC(QqGtadbz9srVqAVfRhfoo74bvcaska1FaYOrakTUDADHYZznXssy9Ikr9QcCABAM1ECQSpcmBkCbMnnlHScC(dImNeMkWPx58vHapTUDADHYZznXssy9Ikr9Qc8G61(cCY9v3Dynr5SWfy2StiKvGZFqK5KWubEq9AFb(WNc)UE86vf40RC(QqGFm0XtRGiZaudaYJtLDRxKS2xDQyaclaKmhGmAeGiGHGSYlf(gTC(xslSIaN2MMzThNk7JaZMcxGPjMriRaN)GiZjHPcC6voFviWF2Cx3R0eljHDADHYZzaQbabTu4bGWcajpUkiYSLKqFJMUJdqyfazca1aGsRBh(u431JxVQ9yYO(bGWca1zacRaivAsGhuV2xG3RYjO6ynXssiCbMM0uiRapOETVaN2kK4cYrGZFqK5KWuHlW0eteYkW5piYCsyQapOETVaxIkN10LKm(KaNELZxfcCOLcpaegaengxFSk)aKHae0sHhlzyUaN2MMzThNk7JaZMcxGPj9xiRaN)GiZjHPcC6voFviWp4NH2tLTx7CiX4rwc(gnDFOf(t1RQh)kj4XYYiCPOWjbEq9AFbEVkNGQJ1eljHWfyAsNkKvGZFqK5KWubEq9AFbo5(Q7oSMOCwGtVY5RcbobmeKLCF1DhwdbFTTWkaKrJae0sHhacdakOETVvIkN10LKm(KLgJRpwLFaclae0sHhlzyoa1VauZodqgncqP1TtRluEoRjwscRxujQxfGmAeGiGHGS9QCspk1v(ypMmQFe4020mR94uzFey2u4cmnPZczf48hezojmvGhuV2xGFHIVNE8RKGf4020mR94uzFey2u4cmnPFeYkW5piYCsyQaNELZxfc8UbONn319knXssyLV5WRmdqnaO062Hpf(D941RA9Ikr9QaKrJa0ZM76ELMyjjSkT4Bj3NbiJgbONn319knXssyNwxO8CgGAaqqlfEaiSaqD2mauFaudaQlaAyxtSp8y9IptmlTjkubEq9AFbEVkNGQJ1eljHWfUaNyveYkWSPqwbo)brMtctf4b1R9f4dFk876XRxvGtVY5RcbobmeKvEPW3OLZ)sApMmQFaOgau3aebmeKvEPW3OLZ)sApMmQFaidbivAcGmAeGog64PvqKzaQpboTnnZApov2hbMnfUatteYkW5piYCsyQapOETVaxIkN10LKm(KaNELZxfcCOLcpaegaengxFSk)aKHae0sHhlzyoa1aGiGHGSpp1R2lU2J2VqrPEvDOOex4WJfwbGmAeGGwk8aqyaq0yC9XQ8dqgcqqlfESKH5aegautZaqnaicyii7Zt9Q9IR9O9luuQxvhkkXfo8yHvaOgaebmeK95PE1EX1E0(fkk1RQdfL4chEShtg1paKHaKknjWPTPzw7XPY(iWSPWfy2FHSc8G61(cCjQCwpTwxGZFqK5KWuHlWStfYkW5piYCsyQaNELZxfcCOLcpaegaengxFSk)aKHae0sHhlzyoa1aGGGZz9X0wXPYAVizaYqasLMaiJgbicyiilzK0eljrCPIplSIapOETVaVxLtq1XAILKq4cm7Sqwbo)brMtctf40RC(QqGdTu4bGWaGOX46Jv5hGmeGGwk8yjdZf4b1R9f4q54LOEv94xjblCbM9JqwbEq9AFbouoAZj90ADbo)brMtctfUatzUqwbo)brMtctf40RC(QqGFWpdTNkBFEM6v7fx7r7xOOuVQouuIlC4XYYiCPOWjaQbabTu4bGmeGKhxfez2ssOVrt3Xf4JFf1fy2uGhuV2xGtJCwhuV2xNRXf45AC9hKSa)9q4cmnlHScC(dImNeMkWPx58vHahAPWdaHbarJX1hRYpaziabTu4XsgMlWdQx7lWtC4T00wHexqkCbMDcHScC(dImNeMkWdQx7lWVqX3tp(vsWcC6voFviWjGHGS0DVu9HZjDmtaNDlSca1aGiGHGS0DVu9HZjDmtaND7XKr9dazia102zacRaivAsGtBtZS2JtL9rGztHlWSPzeYkW5piYCsyQapOETVaNCF1DhwtuolWPx58vHaNagcYs39s1hoN0XmbC2TWkaudaIagcYs39s1hoN0XmbC2Thtg1paKHautBNbiScGuPjboTnnZApov2hbMnfUaZMnfYkWdQx7lWdnj8L4tVqA6T9gbo)brMtctfUaZMMiKvGZFqK5KWubEq9AFb(fk(E6XVscwGtVY5RcbobmeK1lf9cP9wSEu44SJhujaiPau)f4020mR94uzFey2u4cmB2FHScC(dImNeMkWdQx7lWj3xD3H1eLZcC6voFviW9iZVBJSsRqRCCk89S8hezobqnaOUbicyiil5(Q7oSgc(ABHvaOgaebmeKLCF1DhwdbFTThtg1paKHae0sHhaYaaQBasECvqKzljH(gnDhhG6xaIgJRpwLFaQpacRaivAcG6tGtBtZS2JtL9rGztHlWSzNkKvGZFqK5KWubo9kNVke4qlfEaimaiAmU(yv(bidbiOLcpwYWCaQba1fa5fvI6vbOgau3aeeCoRpM2kovw7fjdqgcqQ0eaz0ia1faLw32RYjO6ynXssy9Ikr9QaudaIagcYsUV6UdRHGV22JjJ6haclaeeCoRpM2kovw7fjdq9la1eGWkasLMaiJgbOUaO062EvobvhRjwscRxujQxfGAaqDbqeWqqwY9v3Dyne812Emzu)aq9bqgncqErYAF1PIbidbOMMfa1aG6cGsRB7v5euDSMyjjSErLOEvbEq9AFbEVkNGQJ1eljHWfy2SZczf48hezojmvGhuV2xGlrLZA6ssgFsGtBtZS2JtL9rGztbo9kNVke4qlfEaimaiAmU(yv(bidbiOLcpwYWCaQba1na1faDWpdTNkBFEM6v7fx7r7xOOuVQouuIlC4XYFqK5eaz0iabTu4bGmeGKhxfez2ssOVrt3XbO(e4jEOxP41(c8ojea1EHbO0(DWbOwHCgGWKNPE1EX1Uddaj7fkk1RcqDCfL4chEKeGMIuj3gGOX4aKmBLZaKmTKKXNaOccGAVWauV97GdqRC(OHcaTpaz20sHhac6wsakT1RcqZAbOojea1EHbO0cqTc5maHjpt9Q9IRDhgas2luuQxfG64kkXfo8aqTxyaAATW5earJXbiz2kNbizAjjJpbqfea1EHpacAPWdavdarW5Tha5TyaIUJdqleaH1DF1DhgGmTCgG2dGKzcfFpac3Vscw4cmB2pczf48hezojmvGhuV2xGlrLZA6ssgFsGtBtZS2JtL9rGztbo9kNVke4qlfEaimaiAmU(yv(bidbiOLcpwYWCaQbaDWpdTNkBFEM6v7fx7r7xOOuVQouuIlC4XYFqK5ea1aGO7MtBV3cDmldRxv7xOypMmQFaiSaqDdqqlfEaidaOUbi5XvbrMTKe6B00DCaQFbiAmU(yv(bO(aiScGuPjaQpaQbar3nN2EV1Jt7xOypMmQFaiSaqDdqqlfEaidaOUbi5XvbrMTKe6B00DCaQFbiAmU(yv(bO(aiScGuPjaQpaQba1na1fa5rMF3ooZzTFHIL)GiZjaYOraYJm)UDCMZA)cfl)brMtaudaIUBoT9E74mN1(fk2JjJ6haclau3ae0sHhaYaaQBasECvqKzljH(gnDhhG6xaIgJRpwLFaQpacRaivAcG6dG6tGN4HELIx7lWn7kVfaHjpt9Q9IRDhgas2luuQxfG64kkXfo8aq7NBdqYSvodqY0ssgFcGkiaQ9cFaKFHYaqXXa0(aeD3CA79scqR3IVE1Wa04Rcabp1RcqYSvodqY0ssgFcGkiaQ9cFaef(o(DacAPWdafKl87aunae)lSAlaYxaAGhpQhG8wmafKl87a0cbqErYauMHCacApak(2a0cbqTx4dG8lugaYxaIUKmaTqqaeD3CA79cxGztzUqwbo)brMtctf40RC(QqGdTu4bGWaGOX46Jv5hGmeGGwk8yjdZf4b1R9f4JZCw7xOiCbMnnlHScC(dImNeMkWdQx7lWh(u431JxVQaNELZxfc8062Hpf(D941RApg64PvqKzaQba1faradbzP7EP6dNt6yMao7wyfaYOraYJm)UnYkTcTYXPW3ZYFqK5ea1aGog64PvqKzaQba1faradbzj3xD3H1qWxBlSIaN2MMzThNk7JaZMcxGzZoHqwbEq9AFb(XZ(HxVQoUB7jW5piYCsyQWfyAIzeYkWdQx7lW7v5KEuQR8rGZFqK5KWuHlW0KMczf48hezojmvGtVY5RcbExaebmeKLU7LQpCoPJzc4SBHve4b1R9f40DVu9HZjDmtaNDHlW0eteYkW5piYCsyQaNELZxfcCcyiil5(Q7oSgc(ABHvaiJgbiOLcpaegauq9AFRevoRPljz8jlngxFSk)aewaiOLcpwYWCaYOraIagcYs39s1hoN0XmbC2TWkc8G61(cCY9v3Dynr5SWfyAs)fYkW5piYCsyQapOETVa)cfFp94xjblWPTPzw7XPY(iWSPWfyAsNkKvGZFqK5KWubo9kNVke4P1T9QCcQowtSKe2JHoEAfezwGhuV2xG3RYjO6ynXssiCbMM0zHScC(dImNeMkWdQx7lWh(u431JxVQaNELZxfcCcyiiR8sHVrlN)L0cRiWPTPzw7XPY(iWSPWfUWf4Y5BQ9fyAIzmXeZ0FZ0zbEV4(6vhbUzxhxMbZojMMTynacGKTfdqfPYEoabTha1bLJPljr4DaGowgHRJta0SKmafW(sgoNaiAR4v5XcWUJQNbOMynasM2xoFoNaOo4rMF32X6aa5la1bpY872oML)GiZPoaqHdqM9z2ChbqD308(SaSbyB21XLzWStIPzlwdGaizBXaurQSNdqq7bqDy8oaqhlJW1XjaAwsgGcyFjdNtaeTv8Q8yby3r1ZauZoJ1aizAF585CcGWlszcGM2VhMdqYaaYxaQJGdakvYRP2hGwf(cFpaQBd6dG6UP59zbydW2SRJlZGzNetZwSgabqY2IbOIuzphGG2dG6annDaGowgHRJta0SKmafW(sgoNaiAR4v5XcWUJQNbOMMbRbqY0(Y5Z5ea1HzHZe1NSDSoaq(cqDyw4mr9jBhZYFqK5uhaOUnX8(SaS7O6zaQz)XAaKmTVC(Cobq4fPmbqt73dZbizaa5la1rWbaLk51u7dqRcFHVha1Tb9bqD308(SaS7O6zaQzNI1aizAF585CcGWlszcGM2VhMdqYaaYxaQJGdakvYRP2hGwf(cFpaQBd6dG6UP59zby3r1ZauZoJ1aizAF585CcGWlszcGM2VhMdqYaaYxaQJGdakvYRP2hGwf(cFpaQBd6dG6UP59zbydW2SRJlZGzNetZwSgabqY2IbOIuzphGG2dG6aXQ0ba6yzeUoobqZsYaua7lz4CcGOTIxLhla7oQEgGA2FSgajt7lNpNtaeErkta00(9WCasgaq(cqDeCaqPsEn1(a0QWx47bqDBqFau3nnVpla7oQEgGA2zSgajt7lNpNtauho4NH2tLTDSoaq(cqD4GFgApv22XS8hezo1baQ7MM3NfGDhvpdqn7hSgajt7lNpNtaeErkta00(9WCasgaq(cqDeCaqPsEn1(a0QWx47bqDBqFau3938(SaS7O6zaQz)G1aizAF585CcG6Ghz(DBhRdaKVauh8iZVB7yw(dImN6aa1TjM3NfGDhvpdqn7hSgajt7lNpNtauho4NH2tLTDSoaq(cqD4GFgApv22XS8hezo1baQ7MM3NfGDhvpdqnnlSgajt7lNpNtauh8iZVB7yDaG8fG6Ghz(DBhZYFqK5uhaOUBAEFwa2aSn764Ymy2jX0SfRbqaKSTyaQiv2ZbiO9aOoqZCiN7aaDSmcxhNaOzjzakG9LmCobq0wXRYJfGDhvpdqnBI1aizAF585CcGWlszcGM2VhMdqYaaYxaQJGdakvYRP2hGwf(cFpaQBd6dG6UP59zby3r1ZauZ(J1aizAF585CcGWlszcGM2VhMdqYaaYxaQJGdakvYRP2hGwf(cFpaQBd6dG6UP59zby3r1ZaKjnXAaKmTVC(Cobq4fPmbqt73dZbizaa5la1rWbaLk51u7dqRcFHVha1Tb9bqD308(SaSby3jjv2Z5eajZbOG61(auUgFSaSf4k3cvzwGJ1dq4WN8sEKbiZgGFNpa2y9aew34OTaOM9JKaKjMXetaydWoOET)yvoMUKeHJHudKhxfezwYpizPKe6B00DCjxfPd7fKKYJmmlnOETVLCF1DhwtuoBP74skpYWSMZdlnOETV9cfFp94xjbBP74ss3pvETVupY87wY9v3Dynr5ma7G61(Jv5y6sseogsnyGjj3xRWoa7G61(Jv5y6sseogsnGyDpZjnuoAZPE1RQ9186byhuV2FSkhtxsIWXqQbqzEArVaYbyhuV2FSkhtxsIWXqQbECA)cfjliPh8Zq7PY2zHZq7PYAMKGVXYYiCPOWja2b1R9hRYX0LKiCmKAW4mN1(fkaSbyhuV2FWqQbKWYqzyMbyJ1dqMTlafT4ibqXNaizV4Lr4kxYqgGW0SrzcG4NjlEm7hG6XauA)o4auAbiVvnae0EaKsoAZ3aqemnGhgGkVdjaIGbiFxaAucsY2au8jaQhdq047GdqhhPk3gGK9IxgbOrHPfurbicyiOXcWoOET)GHud8lEzeUYLmSEv90ADjliPD5XPYUTgTsoAZha7G61(dgsnaEyD5mPKFqYsX6So8RY1D6epE9ThnnYzjliPb1l5SMFMS4rAZgDtadbzP7EP6dNt6yMao7wyfJg7IUBoT9ElD3lvF4CshZeWz3Emzu)y0iXotdVizTV6uXg2FZ0NrJDhuVKZA(zYIhS0SbbmeK94z)WRxvh3T9SWkgnsadbzP7EP6dNt6yMao7wyL(ayhuV2FWqQbWdRlNjha2y9y9aKzpohTbiOGwVka1EHpakTWeoab)ELbO2lma1kKZaKcSdqYm8SF41RcqD872EauA79scq7bqfea5TyaIUBoT9EaQgaY3fGY7Rcq(cqjohTbiOGwVka1EHpaYS3ct4waQtcbq)(maTqaK3IhgGO7NkV2FaO4yakiYma5larYoa1R8w1dqElgGAAgaAy6(PbGYm3lAlja5TyaAksackO8aqTx4dGm7TWeoafW(sgErJCUTfGnwpwpafuV2FWqQbp3dAH)K(4zZYzjliPZcNjQpzFUh0c)j9XZMLZn6MagcYE8SF41RQJ72EwyfJgP7MtBV3E8SF41RQJ72E2JjJ6hS00mgn6XPYU1lsw7RovSHn7N(ayhuV2FWqQb0iN1b1R915ACj)GKLstda7G61(dgsnGg5SoOETVoxJl5hKSuIvrYXVI6sBkzbjnOEjN18ZKfpg2)gEK53Te1Lg9cPvoUTL)GiZja2b1R9hmKAanYzDq9AFDUgxYpizPJl54xrDPnLSGKguVKZA(zYIhd7FJU8iZVBjQln6fsRCCBl)brMtaSdQx7pyi1aAKZ6G61(6CnUKFqYsPzoKZso(vuxAtjliPb1l5SMFMS4blMaWoOET)GHudIJgpR99o(Da2aSdQx7pwIvr6WNc)UE86vLK2MMzThNk7J0MswqsjGHGSYlf(gTC(xs7XKr9tJUjGHGSYlf(gTC(xs7XKr9JHQ0KrJhdD80kiYCFaSdQx7pwIvbdPgirLZA6ssgFssABAM1ECQSpsBkzbjfAPWdg0yC9XQ8Bi0sHhlzyEdcyii7Zt9Q9IR9O9luuQxvhkkXfo8yHvmAeAPWdg0yC9XQ8Bi0sHhlzyognntdcyii7Zt9Q9IR9O9luuQxvhkkXfo8yHvAqadbzFEQxTxCThTFHIs9Q6qrjUWHh7XKr9JHQ0ea7G61(JLyvWqQbsu5SEAToa7G61(JLyvWqQb9QCcQowtSKeswqsHwk8GbngxFSk)gcTu4XsgM3acoN1htBfNkR9IKnuLMmAKagcYsgjnXssexQ4ZcRaWoOET)yjwfmKAauoEjQxvp(vsWswqsHwk8GbngxFSk)gcTu4XsgMdWoOET)yjwfmKAauoAZj90ADa2b1R9hlXQGHudOroRdQx7RZ14s(bjl99qYXVI6sBkzbj9GFgApv2(8m1R2lU2J2VqrPEvDOOex4WJLLr4srHtnGwk8yO84QGiZwsc9nA6ooa7G61(JLyvWqQbjo8wAARqIliLSGKcTu4bdAmU(yv(neAPWJLmmhGDq9A)XsSkyi1Glu890JFLeSK020mR94uzFK2uYcskbmeKLU7LQpCoPJzc4SBHvAqadbzP7EP6dNt6yMao72JjJ6hdBA7mwPstaSdQx7pwIvbdPgqUV6UdRjkNLK2MMzThNk7J0MswqsjGHGS0DVu9HZjDmtaNDlSsdcyiilD3lvF4CshZeWz3Emzu)yytBNXkvAcGDq9A)XsSkyi1GqtcFj(0lKMEBVbGDq9A)XsSkyi1Glu890JFLeSK020mR94uzFK2uYcskbmeK1lf9cP9wSEu44SJhujK2Fa2b1R9hlXQGHudi3xD3H1eLZssBtZS2JtL9rAtjliPEK53TrwPvOvoof(Ew(dImNA0nbmeKLCF1DhwdbFTTWkniGHGSK7RU7WAi4RT9yYO(XqOLcpYGULhxfez2ssOVrt3X7xAmU(yv(7dRuPP(ayhuV2FSeRcgsnOxLtq1XAILKqYcsk0sHhmOX46Jv53qOLcpwYW8gD5fvI6vB0neCoRpM2kovw7fjBOknz0yxP1T9QCcQowtSKewVOsuVAdcyiil5(Q7oSgc(ABpMmQFWceCoRpM2kovw7fj3VnXkvAYOXUsRB7v5euDSMyjjSErLOE1gDradbzj3xD3H1qWxB7XKr9tFgn6fjR9vNk2WMMvJUsRB7v5euDSMyjjSErLOEva2y9auNecGAVWauA)o4auRqodqyYZuVAV4A3HbGK9cfL6vbOoUIsCHdpscqtrQKBdq0yCasMTYzasMwsY4taubbqTxyaQ3(DWbOvoF0qbG2hGmBAPWdabDljaL26vbOzTauNecGAVWauAbOwHCgGWKNPE1EX1Uddaj7fkk1RcqDCfL4chEaO2lmanTw4CcGOX4aKmBLZaKmTKKXNaOccGAVWhabTu4bGQbGi482dG8wmar3XbOfcGW6UV6UddqMwodq7bqYmHIVhaH7xjbdWoOET)yjwfmKAGevoRPljz8jjPTPzw7XPY(iTPKfKuOLcpyqJX1hRYVHqlfESKH5n6URd(zO9uz7ZZuVAV4ApA)cfL6v1HIsCHdpgncTu4Xq5XvbrMTKe6B00D8(ayJ1dqMDL3cGWKNPE1EX1Uddaj7fkk1RcqDCfL4chEaO9ZTbiz2kNbizAjjJpbqfea1EHpaYVqzaO4yaAFaIUBoT9EjbO1BXxVAyaA8vbGGN6vbiz2kNbizAjjJpbqfea1EHpaIcFh)oabTu4bGcYf(DaQgaI)fwTfa5lanWJh1dqElgGcYf(DaAHaiVizakZqoabThafFBaAHaO2l8bq(fkda5larxsgGwiiaIUBoT9Ea2b1R9hlXQGHudKOYznDjjJpjjTnnZApov2hPnLSGKcTu4bdAmU(yv(neAPWJLmmVXb)m0EQS95zQxTxCThTFHIs9Q6qrjUWHNg0DZPT3BHoMLH1RQ9luShtg1pyPBOLcpYGULhxfez2ssOVrt3X7xAmU(yv(7dRuPP(Aq3nN2EV1Jt7xOypMmQFWs3qlfEKbDlpUkiYSLKqFJMUJ3V0yC9XQ83hwPst91O7U8iZVBhN5S2VqXOrpY872XzoR9luAq3nN2EVDCMZA)cf7XKr9dw6gAPWJmOB5XvbrMTKe6B00D8(LgJRpwL)(WkvAQV(ayhuV2FSeRcgsnyCMZA)cfjliPqlfEWGgJRpwLFdHwk8yjdZbyhuV2FSeRcgsny4tHFxpE9QssBtZS2JtL9rAtjliPP1TdFk876XRx1Em0XtRGiZn6IagcYs39s1hoN0XmbC2TWkgn6rMF3gzLwHw54u4714yOJNwbrMB0fbmeKLCF1DhwdbFTTWkaSdQx7pwIvbdPgC8SF41RQJ72EaSdQx7pwIvbdPg0RYj9Oux5da7G61(JLyvWqQb0DVu9HZjDmtaNDjliPDradbzP7EP6dNt6yMao7wyfa2b1R9hlXQGHudi3xD3H1eLZswqsjGHGSK7RU7WAi4RTfwXOrOLcpyeuV23krLZA6ssgFYsJX1hRYpwGwk8yjdZnAKagcYs39s1hoN0XmbC2TWkaSdQx7pwIvbdPgCHIVNE8RKGLK2MMzThNk7J0MaSdQx7pwIvbdPg0RYjO6ynXssizbjnTUTxLtq1XAILKWEm0XtRGiZaSdQx7pwIvbdPgm8PWVRhVEvjPTPzw7XPY(iTPKfKucyiiR8sHVrlN)L0cRaWgGDq9A)XstJ0wXPS7lzbj1Jm)U15JC0lKMF1qLj53T8hezo1aAPWJHqlfESKH5aSdQx7pwAAWqQbe5DtAi4RTKfKucyiilD3lvF4CshZeWz3cRaWoOET)yPPbdPgepLh)ISMg5SKfKucyiilD3lvF4CshZeWz3cRaWoOET)yPPbdPgavhtK3njzbjLagcYs39s1hoN0XmbC2TWkaSdQx7pwAAWqQb5sTLpASoWjvs(Da2b1R9hlnnyi1aIqvVqA)kQeJKfKu6U5027Tsu5SMUKKXNSqW5S(yAR4uzTxKmwuPja2b1R9hlnnyi1ac(g(KOEvjliPeWqqw6UxQ(W5KoMjGZUfwXOrVizTV6uXg2S)aSdQx7pwAAWqQbKWYqzyMbyhuV2FS00GHuduwV2xYcskXotdOsTLRpMmQFm0KoB0ibmeKLU7LQpCoPJzc4SBHvayhuV2FS00GHudGY80IEbKlz9oFhSIRliP0wX)CUE1gDnlCMO(KvbEC4mR5dwXR9LSGK2n0sHhdL5MXOr6U5027T0DVu9HZjDmtaND7XKr9JHQ0uFn6Ew4mr9jRc84WzwZhSIx7B04SWzI6tw5Bo8kZ6zZY53BqadbzLV5WRmRNnlNF3M2EFFaSdQx7pwAAWqQbECA)cfjliPqlfEWGgJRpwLFdHwk8yjdZBCWpdTNkBNfodTNkRzsc(gllJWLIcNA4XP9luShtg1pgQstnO7MtBV3cLJJThtg1pgQstn6oOEjN18ZKfpyPPrJb1l5SMFMS4rAZgErYAF1PIXsNXkvAQpa2b1R9hlnnyi1aOCCSK56znnj1KolzbjfAPWdg0yC9XQ8Bi0sHhlzyEdpoTFHIfwPXb)m0EQSDw4m0EQSMjj4BSSmcxkkCQHxKS2xDQyS0PyLknbWoOET)yPPbdPgirLZ6P16swqsdQxYzn)mzXJ0Mn84uz36fjR9vNk2qOLcpYGULhxfez2ssOVrt3X7xAmU(yv(7dRuPja2b1R9hlnnyi1aY9v3Dynr5SKfK0G6LCwZptw8iTzdpov2TErYAF1PIneAPWJmOB5XvbrMTKe6B00D8(LgJRpwL)(WkvAcGDq9A)Xstdgsn4cfFp94xjblzbjnOEjN18ZKfpsB2WJtLDRxKS2xDQydHwk8id6wECvqKzljH(gnDhVFPX46Jv5VpSsLMayhuV2FS00GHudIrHPUEH0ElwZHAMLSGK6XPYUnvJhpLXI0(bGna7G61(JLM5qolD4tHFxpE9QssBtZS2JtL9rAtjliPEK53TTANUy0eLZw(dImNAqadbzLxk8nA58VK2JjJ6NgeWqqw5LcFJwo)lP9yYO(XqvAcGDq9A)XsZCiNXqQb9QCspk1v(izbjTRlQKMLZVBJuASS514JrJxujnlNF3gP0ypMmQFWI0MMXOXG6LCwZptw8GfPxujnlNF3gP0yPl87yLjaSdQx7pwAMd5mgsn44z)WRxvh3T9KSGK21fvsZY53Trknw28A8XOXlQKMLZVBJuAShtg1pyrQzz0yq9soR5NjlEWI0lQKMLZVBJuAS0f(DSYea2b1R9hlnZHCgdPgq39s1hoN0XmbC2LSGK21fvsZY53Trknw28A8XOXlQKMLZVBJuAShtg1pyrAtZy0yq9soR5NjlEWI0lQKMLZVBJuAS0f(DSYea2b1R9hlnZHCgdPg0RYjO6ynXssizbjfcoN1htBfNkR9IKnuLMayhuV2FS0mhYzmKAqIdVLM2kK4csjliPD31fvsZY53Trknw28A8XOXlQKMLZVBJuAShtg1pyPZgnguVKZA(zYIhSi9IkPz5872iLglDHFhRmPpJgHwk8GbngxFSk)gcTu4XsgM3ORd(zO9uzlrOQxinj8xET)yzzeUuu4ea7G61(JLM5qoJHudOroRdQx7RZ14s(bjl99qYXVI6sBkzbj9GFgApv2(8m1R2lU2J2VqrPEvDOOex4WJLLr4srHtnGwk8yO84QGiZwsc9nA6ooa7G61(JLM5qoJHudOTcjUGCayhuV2FS0mhYzmKAabStBXxBjliPP1TtRluEoRjwscRxujQxTr3P1T1789rwtKzovVQD8GkHHMy0yAD706cLNZAILKWEmzu)yOkn1ha7G61(JLM5qoJHudOXjNLSGKMw3oTUq55SMyjjSErLOE1gDnSRj2hESEXNjML2efka7G61(JLM5qoJHudiGDAl(AlzbjL2kovE0qxq9A)iJftSDUbD3CA792EvobvhRjwscleCoRpM2kovw7fjJLrHZzThNk7JmWea2b1R9hlnZHCgdPgaLJxI6v1JFLeSKfKuOLcpyqJX1hRYVHqlfESKH5aSdQx7pwAMd5mgsnGgNCwYcskD3CA792EvobvhRjwscleCoRpM2kovw7fjJLrHZzThNk7JmWea2b1R9hlnZHCgdPg0RYjO6ynXssizbjLagcYsgjnXssexQ4ZcRaWoOET)yPzoKZyi1ajQCwtxsY4tssBtZS2JtL9rAtjliPP1TkT4Bj3N1eljH1lQe1R2yyxtSp8y9IptmlTjkua2b1R9hlnZHCgdPgirLZ6P16swqsjGHGSq5OnFJMmojSWkaSdQx7pwAMd5mgsnakhT5KEATUK020mR94uzFK2eGDq9A)XsZCiNXqQbdFk876XRxvsABAM1ECQSpsBkzbj9yOJNwbrMB0LxujQxTXZM76ELMyjjSY3C4vMB4XPYU1lsw7RovmwA25gqlfEWGgJRpwLFS0)o3iOEjN18ZKfpgkTtbyhuV2FS0mhYzmKAGevoRPljz8jjPTPzw7XPY(iTPKfKuOLcpyqJX1hRYVHqlfESKH5nGGZz9X0wXPYAVizdvPPgDFWpdTNkBFEM6v7fx7r7xOOuVQouuIlC4XYYiCPOWPg0DZPT3BHoMLH1RQ9luShtg1pnO7MtBV36XP9luShtg1pgn21b)m0EQS95zQxTxCThTFHIs9Q6qrjUWHhllJWLIcN6dGDq9A)XsZCiNXqQb9QCcQowtSKeswqs7kTUTxLtq1XAILKW6fvI6vB01WUMyF4X6fFMywAtuOgnsBfNkpAOlOETFKXstB)byhuV2FS0mhYzmKAabStBXxBjliPD31ZM76ELMyjjStRluEoB0yxEK53T9QCcQowxpe8u7B5piYCQVg0DZPT3B7v5euDSMyjjSqW5S(yAR4uzTxKmwgfoN1ECQSpYatayhuV2FS0mhYzmKAqOjHVeF6fstVT3aWoOET)yPzoKZyi1GXzoR9luKSGKcTu4bdAmU(yv(neAPWJLmmhGDq9A)XsZCiNXqQbdFk876XRxvsABAM1ECQSpsBkzbj9yOJNwbrMB4rMF32QD6IrtuoB5piYCQHhNk7wVizTV6uXyXSayhuV2FS0mhYzmKAano5ma7G61(JLM5qoJHudKOYznDjjJpjjTnnZApov2hPnLSGKcTu4bdAmU(yv(neAPWJLmmVr3h8Zq7PY2NNPE1EX1E0(fkk1RQdfL4chESSmcxkkCQbD3CA79wOJzzy9QA)cf7XKr9td6U5027TECA)cf7XKr9JrJDDWpdTNkBFEM6v7fx7r7xOOuVQouuIlC4XYYiCPOWP(ayhuV2FS0mhYzmKAGevoRNwRdWoOET)yPzoKZyi1GHpf(D941RkjTnnZApov2hPnLSGKEm0XtRGiZaSdQx7pwAMd5mgsnGCF1DhwtuoljTnnZApov2hPnbyhuV2FS0mhYzmKAWfk(E6XVscwsABAM1ECQSpsBcWgGDq9A)X(EiDCMZA)cfa2b1R9h77bgsna6ywgwVQ2VqrYcsAxeWqq2EvoPhL6kFShtg1pgnsadbz7v5KEuQR8XEmzu)0GUBoT9ERevoRPljz8j7XKr9da7G61(J99adPg4XP9luKSGK2fbmeKTxLt6rPUYh7XKr9JrJeWqq2EvoPhL6kFShtg1pnO7MtBV3krLZA6ssgFYEmzu)aWgGDq9A)XoU0ehElnTviXfKswqsHwk8GbngxFSk)gcTu4XsgM3O7UUOsAwo)UnsPXYMxJpgn21fvsZY53TrknwyLgxujnlNF3gP0ytWx41(yCrL0SC(DBKsJTEd7CFgnErL0SC(DBKsJfwPXfvsZY53Trkn2JjJ6hS0PMbGDq9A)Xoogsny4tHFxpE9QssBtZS2JtL9rAtjliPDLw3o8PWVRhVEvRxujQxTHhNk7wVizTV6uXyrMB0ibmeKvEPW3OLZ)sAHvAqadbzLxk8nA58VK2JjJ6hdvPja2b1R9h74yi1aOC0Mt6P16aSdQx7p2XXqQbhp7hE9Q64UTNKfK0UUOsAwo)UnsPXYMxJpgn21fvsZY53TrknwyLgDFrL0SC(DBKsJnbFHx7JXfvsZY53Trkn26n0eZy04fvsZY53Trknw6c)U0M9z04fvsZY53TrknwyLgxujnlNF3gP0ypMmQFWsNAgJgj2zA4fjR9vNk2WMMbGDq9A)XoogsnOxLt6rPUYhjliPDDrL0SC(DBKsJLnVgFmASRlQKMLZVBJuASWknUOsAwo)UnsPXMGVWR9X4IkPz5872iLgB9gAIzmA8IkPz5872iLglSsJlQKMLZVBJuAShtg1pyXeZy0iXotdVizTV6uXgAIzayhuV2FSJJHudO7EP6dNt6yMao7swqs76IkPz5872iLglBEn(y0iDLZF8U9l1wUgk4g0DZPT3B7v5KEuQR8XEmzu)y0yx0vo)X72VuB5AOGB0DxxujnlNF3gP0yHvACrL0SC(DBKsJnbFHx7JXfvsZY53Trkn26nS)MXOXlQKMLZVBJuASWknUOsAwo)UnsPXEmzu)GftmJrJDDrL0SC(DBKsJfwPpJgj2zA4fjR9vNk2W(Bga2b1R9h74yi1ajQCwpTwhGDq9A)XoogsnakhVe1RQh)kjyjliPqlfEWGgJRpwLFdHwk8yjdZbyhuV2FSJJHudcnj8L4tVqA6T9ga2b1R9h74yi1GEvobvhRjwscjliPqW5S(yAR4uzTxKSHMGvQ0uJHDnX(WJ1l(mXS0MOqnAKagcYsgjnXssexQ4ZcRy0yxd7AI9HhRx8zIzPnrH2OBi4CwFmTvCQS2ls2qvAYOrOLcpyqJX1hRYVHqlfESKH5n6(zZDDVstSKew5Bo8kZnsRBh(u431JxVQ1lQe1R2iTUD4tHFxpE9Q2JHoEAfez2OXNn319knXssyvAX3sUp3Olcyiil5(Q7oSgc(ABHvAaTu4bdAmU(yv(neAPWJLmmVFdQx7BLOYznDjjJpzPX46Jv5hR6FFgnsSZ0Wlsw7RovSHnntFaSdQx7p2XXqQbsu5SMUKKXNKK2MMzThNk7J0Mswqsh21e7dpwV4ZeZsBIcTrADRsl(wY9znXssy9Ikr9Qn6IagcYsgjnXssexQ4ZcRaWoOET)yhhdPgqJtolzbjnOEjN18ZKfpyPzJUo4NH2tLTx7CiX4rwc(gnDFOf(t1RQh)kj4XYYiCPOWja2b1R9h74yi1acyN2IV2swqsdQxYzn)mzXdwA2ORd(zO9uz71ohsmEKLGVrt3hAH)u9Q6XVscESSmcxkkCQbD3CA792EvobvhRjwscleCoRpM2kovw7fjJLrHZzThNk7tJUPTItLhn0fuV2pYyXeBNnAmTUDADHYZznXssy9Ikr9Q9bWoOET)yhhdPgmoZzTFHIKfKuOLcpyqJX1hRYVHqlfESKH5aSdQx7p2XXqQbK7RU7WAIYzjPTPzw7XPY(iTPKfKupY872iR0k0khNcFpl)brMtn6MagcYsUV6UdRHGV2wyLgeWqqwY9v3Dyne812Emzu)yi0sHhzq3YJRcImBjj03OP749lngxFSk)9HvQ0uJUiGHGS9QCspk1v(ypMmQFmAKagcYsUV6UdRHGV22JjJ6NgpBUR7vAILKWQ0IVLCFUpa2b1R9h74yi1ajQCwtxsY4tssBtZS2JtL9rAtjliPqW5S(yAR4uzTxKSHQ0udOLcpyqJX1hRYVHqlfESKH5aSdQx7p2XXqQbxO47Ph)kjyjPTPzw7XPY(iTPKfKucyiiRxk6fs7Ty9OWXzhpOsiT)gnMw3oTUq55SMyjjSErLOEva2b1R9h74yi1aY9v3Dynr5SKfK0062P1fkpN1eljH1lQe1RcWoOET)yhhdPgm8PWVRhVEvjPTPzw7XPY(iTPKfK0JHoEAfezUHhNk7wVizTV6uXyrMB0ibmeKvEPW3OLZ)sAHvayhuV2FSJJHud6v5euDSMyjjKSGK(S5UUxPjwsc706cLNZnGwk8Gf5XvbrMTKe6B00DCSYKgP1TdFk876XRx1Emzu)GLoJvQ0ea7G61(JDCmKAaTviXfKda7G61(JDCmKAGevoRPljz8jjPTPzw7XPY(iTPKfKuOLcpyqJX1hRYVHqlfESKH5aSdQx7p2XXqQb9QCcQowtSKeswqsp4NH2tLTx7CiX4rwc(gnDFOf(t1RQh)kj4XYYiCPOWja2b1R9h74yi1aY9v3Dynr5SK020mR94uzFK2uYcskbmeKLCF1DhwdbFTTWkgncTu4bJG61(wjQCwtxsY4twAmU(yv(Xc0sHhlzyE)2SZgnMw3oTUq55SMyjjSErLOEvJgjGHGS9QCspk1v(ypMmQFayhuV2FSJJHudUqX3tp(vsWssBtZS2JtL9rAta2b1R9h74yi1GEvobvhRjwscjliPD)S5UUxPjwscR8nhEL5gP1TdFk876XRx16fvI6vnA8zZDDVstSKewLw8TK7Zgn(S5UUxPjwsc706cLNZnGwk8GLoBM(A01WUMyF4X6fFMywAtuOc8rHPcmnPZDw4cxia]] )


end