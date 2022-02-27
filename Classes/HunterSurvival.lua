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
                return state.buff.death_chakram.applied + floor( state.query_time - state.buff.death_chakram.applied )
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


    spec:RegisterPack( "Survival", 20220226, [[d8Kv5bqiPs9iIa5sqjQnjf(KukgLujNskvRsQQ6vqHzrKClPQu7Is)IOQHrrPJjLSmIupdkHPreW1KQITjvv8nIq14OOW5icuRtQQ07OOOQMhfX9ik7dkPdkvLyHuKEiritKIIkxKIIQSrPQK6JuuugjffHoPukLvcL6LeHIzkLsUjffb7ek6Nuue1qPOiYsjcLEkunvIkFLII0yLsPAVe(lPgmKdt1Ir4XinzrUmQndYNPWOLkoTKvlvLKxtenBrDBeTBv9BfdNehNiOLRYZvA6cxhuBNK8DPkJNIQZlfTEOez(Ku7hyrlHCc8KhSatPnR0sBwPLUFSslnw0pslWJMkSaxXPs6gSa)DswGJdFQkvEwGR4nZJNeYjW3b(OSaxccG6eHY2VYlVrfDGjS0Hu(TiHZEuZtphkKFlsQ8cCc4khTTxqiWtEWcmL2SslTzLw6(XkT0yr)0cle4oC0zoboErkrc8ovkXVGqGN4LkWXHpvLkpdqMjc)bFaS7RzId2VMaK09rkasAZkT0c8CTXkKtG)HlKtGzlHCcCNg18c8nyoRJZve487ezojmvecmLwiNaNFNiZjHPcC6vbFLlW7gGiGHGS9QCsVk1vXApM0RFbi1QbicyiiBVkN0RsDvS2Jj96xaQbarNjNMEVvYkN10HK0)K9ysV(vG70OMxGdDmJLQ3qhNRicbMyHqobo)orMtctf40Rc(kxG3naradbz7v5KEvQRI1EmPx)cqQvdqeWqq2EvoPxL6QyTht61VaudaIoton9ERKvoRPdjP)j7XKE9Ra3PrnVap8thNRicriWtmKdNdHCcmBjKtG70OMxGtcJLWszwGZVtK5KWuriWuAHCcC(DImNeMkWDAuZlWJZFjeUYfwQEd92zcbEIx6vkrnVa3mBaiVd7jaY)eaj35Vecx5clXaeMMjjrae)mzXRuaupgGsZ3MaGsdafDQfGGMdGuYEt(waIGPo8YaufTjbqemafZaqRIts2eG8pbq9yaI6FBca6ypv5MaKCN)siaTkmTGkkaradbTwbo9QGVYf4DdqHFgCyRvRK9M8jcbMyHqobo)orMtctf4onQ5f49vta)gCDNoXBuFZvt9CwGtVk4RCbUtJsfR5NjlEbizaulaQba1faradbzPZCP69GtAFxhohwyfasTAaQBaIoton9ElDMlvVhCs776W5WEmPx)cqQvdqeZUaudakkswhJovmazcaHfMfGAhGuRgG6cGCAuQyn)mzXlaHvaQfa1aGiGHGShVZ7r9gA)UPNfwbGuRgGiGHGS0zUu9EWjTVRdNdlSca1Ua)DswG3xnb8BW1D6eVr9nxn1ZzriWuciKtG70OMxGdVSUcMCf487ezojmvecm7Jqobo)orMtctf4onQ5f4upN1onQ515AdbEU2q)ojlWPPvecm7hHCcC(DImNeMkWPxf8vUa3PrPI18ZKfVaKjaewaqnaOWZ8hwI6sREG0kh30YVtK5KaFJROHaZwcCNg18cCQNZANg186CTHapxBOFNKf4eJIieykXfYjW53jYCsyQaNEvWx5cCNgLkwZptw8cqMaqyba1aG6gGcpZFyjQlT6bsRCCtl)orMtc8nUIgcmBjWDAuZlWPEoRDAuZRZ1gc8CTH(DswGVHieyAgc5e487ezojmvGtVk4RCbUtJsfR5NjlEbiScqslW34kAiWSLa3PrnVaN65S2PrnVoxBiWZ1g63jzbonZUkwecmLGfYjWDAuZlW9J6pRJ5o(dbo)orMtctfHie4khthscpeYjWSLqobo)orMtctf4JIaF5OGe40Rc(kxGhEM)WsoVXmlRjQGT87ezojWt8sVsjQ5f491mXb7xtas6(ifajTzLwAbUk)0VtYcCsc9TA6SHa3PrnVaxLFLtKzbUkpdZAoVSa3PrnV9CLyo9gxjjBPZgcCvEgMf4onQ5TKZBmZYAIkylD2qecmLwiNa3PrnVaFHjjNxRWHaNFNiZjHPIqGjwiKtG70OMxGtmrK5Kgk7n5uV6n0XyE9cC(DImNeMkcbMsaHCcCNg18cCOmVDONdfcC(DImNeMkcbM9riNaNFNiZjHPcC6vbFLlWp4NHMZGT7aNHMZG1mjbFRLLq4srHtcCNg18c8WpDCUIiey2pc5e4onQ5f4BWCwhNRiW53jYCsyQieHaFdHCcmBjKtGZVtK5KWubo9QGVYf4qdfEbimaiQVH(yd(bitaiOHcVws3CaQba1fa1naDEL0Sk(dRNsRLnV2ybi1QbOUbOZRKMvXFy9uATWkauda68kPzv8hwpLwBc(8OMhGWaGoVsAwf)H1tP1wpazca1haQDasTAa68kPzv8hwpLwlSca1aGoVsAwf)H1tP1EmPx)cqyfGKaMvG70OMxGNyp6OPDCjpNuecmLwiNaNFNiZjHPcCNg18c8Lpf(d9g1BiWPxf8vUaVBaknHD5tH)qVr9g2OOswVba1aGc)m4WgfjRJrNkgGWkajXbi1QbicyiiRQsHVvRI)H0cRaqnaicyiiRQsHVvRI)H0EmPx)cqMaqg0KaN2KMzD4NbhRaZwIqGjwiKtG70OMxGdL9MCsVDMqGZVtK5KWuriWuciKtGZVtK5KWubo9QGVYf4DdqNxjnRI)W6P0AzZRnwasTAaQBa68kPzv8hwpLwlSca1aG6cGoVsAwf)H1tP1MGppQ5bimaOZRKMvXFy9uAT1dqMaqsBwasTAa68kPzv8hwpLwlDG)aGKbqTaO2bi1QbOZRKMvXFy9uATWkauda68kPzv8hwpLw7XKE9laHvascywasTAaIy2fGAaqrrY6y0PIbitaOwMvG70OMxGF8oVh1BO97MEIqGzFeYjW53jYCsyQaNEvWx5c8UbOZRKMvXFy9uATS51glaPwna1naDEL0Sk(dRNsRfwbGAaqNxjnRI)W6P0AtWNh18aega05vsZQ4pSEkT26bitaiPnlaPwnaDEL0Sk(dRNsRfwbGAaqNxjnRI)W6P0ApM0RFbiScqsBwasTAaIy2fGAaqrrY6y0PIbitaiPnRa3PrnVaVxLt6vPUkwriWSFeYjW53jYCsyQaNEvWx5c8UbOZRKMvXFy9uATS51glaPwnarhv87Fy)YOtOHCgGAaq0zYPP3B7v5KEvQRI1EmPx)cqQvdqDdq0rf)(h2Vm6eAiNbOgauxau3a05vsZQ4pSEkTwyfaQbaDEL0Sk(dRNsRnbFEuZdqyaqNxjnRI)W6P0ARhGmbGWcZcqQvdqNxjnRI)W6P0AHvaOga05vsZQ4pSEkT2Jj96xacRaK0MfGuRgG6gGoVsAwf)H1tP1cRaqTdqQvdqeZUaudakkswhJovmazcaHfMvG70OMxGtN5s17bN0(UoCoeHatjUqobUtJAEbUKvoR3otiW53jYCsyQieyAgc5e487ezojmvGtVk4RCbo0qHxacdaI6BOp2GFaYeacAOWRL0nxG70OMxGdL9xY6n0BCLKSieykblKtG70OMxG7As4lXNEG00B6TcC(DImNeMkcbMTmRqobo)orMtctf40Rc(kxGdbNZ6JPD8ZG1rrYaKjaK0au)bidAcGAaqlhAI5HxBu8jTzOLwHcqQvdqeWqqwspPjgsc)sfFwyfasTAaQBaA5qtmp8AJIpPndT0kuaQba1fabbNZ6JPD8ZG1rrYaKjaKbnbqQvdqqdfEbimaiQVH(yd(bitaiOHcVws3CaQba1fa9S5HUxPjgscRQj7rLzaQbaLMWU8PWFO3OEdBuujR3aGAaqPjSlFk8h6nQ3WEm0XBhNiZaKA1a0ZMh6ELMyijSkD4BiNNbOgau3aebmeKLCEJzwwdbFnTWkaudacAOWlaHbar9n0hBWpazcabnu41s6Mdq9na50OM3kzLZA6qs6FYs9n0hBWpa1FaclaO2bi1QbiIzxaQbaffjRJrNkgGmbGAzwaQDbUtJAEbEVkNGQJ1edjHiey2QLqobo)orMtctf4onQ5f4sw5SMoKK(Ne40Rc(kxGVCOjMhETrXN0MHwAfka1aGstyv6W3qopRjgscBuujR3aGAaqDdqeWqqwspPjgsc)sfFwyfboTjnZ6WpdowbMTeHaZwslKtGZVtK5KWubo9QGVYf4onkvSMFMS4fGWka1cGAaqDdqh8ZqZzW2Rz2LCdpljFRMop0a)P6n0BCLK8AzjeUuu4Ka3PrnVaN6NkwecmBHfc5e487ezojmvGtVk4RCbUtJsfR5NjlEbiScqTaOgau3a0b)m0CgS9AMDj3WZsY3QPZdnWFQEd9gxjjVwwcHlffobqnai6m5007T9QCcQowtmKewi4CwFmTJFgSoksgGWkaTkCoRd)m4ybOgauxaeTJFg8QHoNg18EgGWkajTTpaKA1auAc725CLNZAIHKWgfvY6naO2f4onQ5f4eWbTdFnfHaZwsaHCcC(DImNeMkWPxf8vUahAOWlaHbar9n0hBWpazcabnu41s6MlWDAuZlW3G5SooxrecmB1hHCcC(DImNeMkWDAuZlWjN3yML1evWcC6vbFLlWdpZFy9SshxRCCYJ5S87ezobqnaOUaicyiil58gZSSgc(AAHvaOgaebmeKLCEJzwwdbFnTht61VaKjae0qHxasEaQlasLFLtKzljH(wnD2aG6BaI6BOp2GFaQDaQ)aKbnbqnaOUbicyiiBVkN0RsDvS2Jj96xasTAaIagcYsoVXmlRHGVM2Jj96xaQba9S5HUxPjgscRsh(gY5zaQDboTjnZ6WpdowbMTeHaZw9Jqobo)orMtctf4onQ5f4sw5SMoKK(Ne40Rc(kxGdbNZ6JPD8ZG1rrYaKjaKbnbqnaiOHcVaegae13qFSb)aKjae0qHxlPBUaN2KMzD4NbhRaZwIqGzljUqobo)orMtctf4onQ5f4NReZP34kjzbo9QGVYf4eWqq2Ou0dKo6W6vH9ZUHtLeGKbqybaPwnaLMWUDox55SMyijSrrLSEdboTjnZ6WpdowbMTeHaZwMHqobo)orMtctf40Rc(kxGNMWUDox55SMyijSrrLSEdbUtJAEbo58gZSSMOcwecmBjblKtGZVtK5KWubUtJAEb(YNc)HEJ6ne40Rc(kxGFm0XBhNiZaudak8ZGdBuKSogDQyacRaKehGuRgGiGHGSQkf(wTk(hslSIaN2KMzD4NbhRaZwIqGP0MviNaNFNiZjHPcC6vbFLlWF28q3R0edjHD7CUYZzaQbabnu4fGWkaPYVYjYSLKqFRMoBaq9hGKgGAaqPjSlFk8h6nQ3WEmPx)cqyfG6da1FaYGMe4onQ5f49QCcQowtmKeIqGP0TeYjWDAuZlWPDCjpNCf487ezojmvecmLwAHCcC(DImNeMkWDAuZlWLSYznDij9pjWPxf8vUahAOWlaHbar9n0hBWpazcabnu41s6MlWPnPzwh(zWXkWSLieyknwiKtGZVtK5KWubo9QGVYf4h8ZqZzW2Rz2LCdpljFRMop0a)P6n0BCLK8AzjeUuu4Ka3PrnVaVxLtq1XAIHKqecmLwciKtGZVtK5KWubUtJAEbo58gZSSMOcwGtVk4RCbobmeKLCEJzwwdbFnTWkaKA1ae0qHxacdaYPrnVvYkN10HK0)KL6BOp2GFacRae0qHxlPBoa13auR(aqQvdqPjSBNZvEoRjgscBuujR3aGuRgGiGHGS9QCsVk1vXApM0RFf40M0mRd)m4yfy2secmLUpc5e487ezojmvG70OMxGFUsmNEJRKKf40M0mRd)m4yfy2secmLUFeYjW53jYCsyQaNEvWx5c8UaONnp09knXqsyvnzpQmdqnaO0e2Lpf(d9g1ByJIkz9gaKA1a0ZMh6ELMyijSkD4BiNNbi1QbONnp09knXqsy3oNR8CgGAaqqdfEbiScq9XSau7audaQBaA5qtmp8AJIpPndT0kubUtJAEbEVkNGQJ1edjHieHaNMwHCcmBjKtGZVtK5KWubo9QGVYf4HN5pSbFKREG08B4gmj)HLFNiZjaQbabnu4fGmbGGgk8AjDZf4onQ5f4D8tzMxecmLwiNaNFNiZjHPcC6vbFLlWjGHGS0zUu9EWjTVRdNdlSIa3PrnVaNiptsdbFnfHatSqiNaNFNiZjHPcC6vbFLlWjGHGS0zUu9EWjTVRdNdlSIa3PrnVa3FkVX5zn1ZzriWuciKtGZVtK5KWubo9QGVYf4eWqqw6mxQEp4K231HZHfwrG70OMxGdvhtKNjjcbM9riNa3PrnVapxgDIv3xbNmi5pe487ezojmvecm7hHCcC(DImNeMkWPxf8vUaNoton9ERKvoRPdjP)jleCoRpM2XpdwhfjdqyfGmOjbUtJAEboHBOhiDCfvYvecmL4c5e487ezojmvGtVk4RCbobmeKLoZLQ3doP9DD4CyHvai1QbOOizDm6uXaKjaulSqG70OMxGtW3YNK1BicbMMHqobUtJAEbojmwclLzbo)orMtctfHatjyHCcC(DImNeMkWPxf8vUaNy2fGAaqqLrNqFmPx)cqMaqs3hasTAaIagcYsN5s17bN0(UoCoSWkcCNg18cCLjQ5fHaZwMviNaNFNiZjHPcC6vbFLlW7cGGgk8cqMaqsCZcqQvdq0zYPP3BPZCP69GtAFxhoh2Jj96xaYeaYGMaO2bOgauxa0oWzI6twf4nGZSMpyLOM3YVtK5eaPwnaTdCMO(Kv1K9OYSENSk(dl)orMtaudaIagcYQAYEuzwVtwf)Hnn9EaQDbUtJAEbouM3o0ZHcbE9bFhSsOliboTJ)pNR3Or37aNjQpzvG3aoZA(GvIAEriWSvlHCcC(DImNeMkWPxf8vUahAOWlaHbar9n0hBWpazcabnu41s6MdqnaOd(zO5my7oWzO5myntsW3AzjeUuu4ea1aGc)0X5k2Jj96xaYeaYGMaOgaeDMCA69wOSFS9ysV(fGmbGmOjaQba1fa50OuXA(zYIxacRaulasTAaYPrPI18ZKfVaKmaQfa1aGIIK1XOtfdqyfG6da1FaYGMaO2f4onQ5f4HF64CfriWSL0c5e487ezojmvG70OMxGdL9Jf40Rc(kxGdnu4fGWaGO(g6Jn4hGmbGGgk8AjDZbOgau4NooxXcRaqnaOd(zO5my7oWzO5myntsW3AzjeUuu4ea1aGIIK1XOtfdqyfGKaau)bidAsGNRN10Kax6(icbMTWcHCcC(DImNeMkWPxf8vUa3PrPI18ZKfVaKmaQfa1aGc)m4WgfjRJrNkgGmbGGgk8cqYdqDbqQ8RCImBjj03QPZgauFdquFd9Xg8dqTdq9hGmOjbUtJAEbUKvoR3oticbMTKac5e487ezojmvGtVk4RCbUtJsfR5NjlEbizaulaQbaf(zWHnkswhJovmazcabnu4fGKhG6cGu5x5ez2ssOVvtNnaO(gGO(g6Jn4hGAhG6pazqtcCNg18cCY5nMzznrfSiey2Qpc5e487ezojmvGtVk4RCbUtJsfR5NjlEbizaulaQbaf(zWHnkswhJovmazcabnu4fGKhG6cGu5x5ez2ssOVvtNnaO(gGO(g6Jn4hGAhG6pazqtcCNg18c8ZvI50BCLKSiey2QFeYjW53jYCsyQaNEvWx5c8WpdoSPAd)PmaHvzau)iWDAuZlW9vHPHEG0rhwZUrMfHie4eJIqobMTeYjW53jYCsyQa3PrnVaF5tH)qVr9gcC6vbFLlWjGHGSQkf(wTk(hs7XKE9la1aG6cGiGHGSQkf(wTk(hs7XKE9lazcazqtaKA1a0XqhVDCImdqTlWPnPzwh(zWXkWSLieykTqobo)orMtctf4onQ5f4sw5SMoKK(Ne40Rc(kxGdnu4fGWaGO(g6Jn4hGmbGGgk8AjDZbOgaebmeK95TEJE(1C1X5kk1BODff)8aETWkaKA1ae0qHxacdaI6BOp2GFaYeacAOWRL0nhGWaGAzwaQbaradbzFER3ONFnxDCUIs9gAxrXppGxlSca1aGiGHGSpV1B0ZVMRooxrPEdTRO4NhWR9ysV(fGmbGmOjboTjnZ6WpdowbMTeHatSqiNa3PrnVaxYkN1BNje487ezojmvecmLac5e487ezojmvGtVk4RCbo0qHxacdaI6BOp2GFaYeacAOWRL0nhGAaqqW5S(yAh)myDuKmazcazqtaKA1aebmeKL0tAIHKWVuXNfwrG70OMxG3RYjO6ynXqsicbM9riNaNFNiZjHPcC6vbFLlWHgk8cqyaquFd9Xg8dqMaqqdfETKU5cCNg18cCOS)swVHEJRKKfHaZ(riNa3PrnVahk7n5KE7mHaNFNiZjHPIqGPexiNaNFNiZjHPcC6vbFLlWp4NHMZGTpVB9g98R5QJZvuQ3q7kk(5b8AzjeUuu4ea1aGGgk8cqMaqQ8RCImBjj03QPZgc8nUIgcmBjWDAuZlWPEoRDAuZRZ1gc8CTH(DswG)HlcbMMHqobo)orMtctf40Rc(kxGdnu4fGWaGO(g6Jn4hGmbGGgk8AjDZf4onQ5f4j2JoAAhxYZjfHatjyHCcC(DImNeMkWDAuZlWpxjMtVXvsYcC6vbFLlWjGHGS0zUu9EWjTVRdNdlSca1aGiGHGS0zUu9EWjTVRdNd7XKE9lazca1Y2haQ)aKbnjWPnPzwh(zWXkWSLiey2YSc5e487ezojmvG70OMxGtoVXmlRjQGf40Rc(kxGtadbzPZCP69GtAFxhohwyfaQbaradbzPZCP69GtAFxhoh2Jj96xaYeaQLTpau)bidAsGtBsZSo8ZGJvGzlriWSvlHCcCNg18cCxtcFj(0dKMEtVvGZVtK5KWuriWSL0c5e487ezojmvG70OMxGFUsmNEJRKKf40Rc(kxGtadbzJsrpq6OdRxf2p7govsasgaHfcCAtAM1HFgCScmBjcbMTWcHCcC(DImNeMkWDAuZlWjN3yML1evWcC6vbFLlWdpZFy9SshxRCCYJ5S87ezobqnaOUaicyiil58gZSSgc(AAHvaOgaebmeKLCEJzwwdbFnTht61VaKjae0qHxasEaQlasLFLtKzljH(wnD2aG6BaI6BOp2GFaQDaQ)aKbnbqTlWPnPzwh(zWXkWSLiey2sciKtGZVtK5KWubo9QGVYf4qdfEbimaiQVH(yd(bitaiOHcVws3CaQba1naffvY6naOgauxaeeCoRpM2XpdwhfjdqMaqg0eaPwna1naLMW2RYjO6ynXqsyJIkz9gaudaIagcYsoVXmlRHGVM2Jj96xacRaeeCoRpM2Xpdwhfjdq9na1cG6pazqtaKA1au3auAcBVkNGQJ1edjHnkQK1BaqnaOUbicyiil58gZSSgc(AApM0RFbO2bi1QbOOizDm6uXaKjaulZaGAaqDdqPjS9QCcQowtmKe2OOswVHa3PrnVaVxLtq1XAIHKqecmB1hHCcC(DImNeMkWDAuZlWLSYznDij9pjWPnPzwh(zWXkWSLaNEvWx5cCOHcVaegae13qFSb)aKjae0qHxlPBoa1aG6cG6gGo4NHMZGTpVB9g98R5QJZvuQ3q7kk(5b8A53jYCcGuRgGGgk8cqMaqQ8RCImBjj03QPZgau7c8eV0RuIAEbEBdcGAoWauA(2eauhxfdqyY7wVrp)A2MfGK7CfL6naO(IIIFEaVsbqBrQKBcquFdasIPYzasIgss)taubbqnhyaQ38TjaOrfFuxbGMhG6Rhk8cqq3qcqPPEdaAhla12GaOMdmaLgaQJRIbim5DR3ONFnBZcqYDUIs9gauFrrXppGxaQ5adqBNboNaiQVbajXu5majrdjP)jaQGaOMd8bqqdfEbOAbicop9aOOddq0zdaAGaiZeM3yMLbitRGbO5aijwxjMdGWJRKKfHaZw9Jqobo)orMtctf4onQ5f4sw5SMoKK(Ne40M0mRd)m4yfy2sGtVk4RCbo0qHxacdaI6BOp2GFaYeacAOWRL0nhGAaqh8ZqZzW2N3TEJE(1C1X5kk1BODff)8aET87ezobqnai6m5007TqhZyP6n0X5k2Jj96xacRauxae0qHxasEaQlasLFLtKzljH(wnD2aG6BaI6BOp2GFaQDaQ)aKbnbqTdqnai6m5007THF64Cf7XKE9laHvaQlacAOWlajpa1faPYVYjYSLKqFRMoBaq9nar9n0hBWpa1oa1FaYGMaO2bOgauxau3au4z(d7gmN1X5kw(DImNai1QbOWZ8h2nyoRJZvS87ezobqnai6m5007TBWCwhNRypM0RFbiScqDbqqdfEbi5bOUaiv(vorMTKe6B10zdaQVbiQVH(yd(bO2bO(dqg0ea1oa1UapXl9kLOMxGBMwrhactE36n65xZ2SaKCNROuVba1xuu8Zd4fGMp3eGKyQCgGKOHK0)eavqauZb(aO4CLfG8JbO5bi6m5007LcGMOdF9QLbOngfacER3aGKyQCgGKOHK0)eavqauZb(aik8D8hae0qHxaYjh4paOAbi(hyJoauma0cVHxpafDyaYjh4paObcGIIKbOmdfae0CaK)nbObcGAoWhafNRSaumaeDizaAGGai6m5007fHaZwsCHCcC(DImNeMkWPxf8vUahAOWlaHbar9n0hBWpazcabnu41s6MlWDAuZlW3G5SooxrecmBzgc5e487ezojmvG70OMxGV8PWFO3OEdbo9QGVYf4PjSlFk8h6nQ3WEm0XBhNiZaudaQBaIagcYsN5s17bN0(UoCoSWkaKA1au4z(dRNv64ALJtEmNLFNiZjaQbaDm0XBhNiZaudaQBaIagcYsoVXmlRHGVMwyfboTjnZ6WpdowbMTeHaZwsWc5e4onQ5f4hVZ7r9gA)UPNaNFNiZjHPIqGP0MviNa3PrnVaVxLt6vPUkwbo)orMtctfHatPBjKtGZVtK5KWubo9QGVYf4DdqeWqqw6mxQEp4K231HZHfwrG70OMxGtN5s17bN0(UoCoeHatPLwiNaNFNiZjHPcC6vbFLlWjGHGSKZBmZYAi4RPfwbGuRgGGgk8cqyaqonQ5Tsw5SMoKK(NSuFd9Xg8dqyfGGgk8AjDZbi1QbicyiilDMlvVhCs776W5WcRiWDAuZlWjN3yML1evWIqGP0yHqobo)orMtctf4onQ5f4NReZP34kjzboTjnZ6WpdowbMTeHatPLac5e487ezojmvGtVk4RCbEAcBVkNGQJ1edjH9yOJ3oorMf4onQ5f49QCcQowtmKeIqGP09riNaNFNiZjHPcCNg18c8Lpf(d9g1BiWPxf8vUaNagcYQQu4B1Q4FiTWkcCAtAM1HFgCScmBjcriWPz2vXc5ey2siNaNFNiZjHPcCNg18c8Lpf(d9g1BiWPxf8vUap8m)HTtZ05RMOc2YVtK5ea1aGiGHGSQkf(wTk(hs7XKE9la1aGiGHGSQkf(wTk(hs7XKE9lazcazqtcCAtAM1HFgCScmBjcbMslKtGZVtK5KWubo9QGVYf4DdqNxjnRI)W6P0AzZRnwasTAa68kPzv8hwpLw7XKE9laHvzaulZcqQvdqonkvSMFMS4fGWQma68kPzv8hwpLwlDG)aG6pajTa3PrnVaVxLt6vPUkwriWeleYjW53jYCsyQaNEvWx5c8UbOZRKMvXFy9uATS51glaPwnaDEL0Sk(dRNsR9ysV(fGWQmaYmai1QbiNgLkwZptw8cqyvgaDEL0Sk(dRNsRLoWFaq9hGKwG70OMxGF8oVh1BO97MEIqGPeqiNaNFNiZjHPcC6vbFLlW7gGoVsAwf)H1tP1YMxBSaKA1a05vsZQ4pSEkT2Jj96xacRYaOwMfGuRgGCAuQyn)mzXlaHvza05vsZQ4pSEkTw6a)ba1FasAbUtJAEboDMlvVhCs776W5qecm7Jqobo)orMtctf40Rc(kxGdbNZ6JPD8ZG1rrYaKjaKbnjWDAuZlW7v5euDSMyijeHaZ(riNaNFNiZjHPcC6vbFLlW7cG6gGoVsAwf)H1tP1YMxBSaKA1a05vsZQ4pSEkT2Jj96xacRauFai1QbiNgLkwZptw8cqyvgaDEL0Sk(dRNsRLoWFaq9hGKgGAhGuRgGGgk8cqyaquFd9Xg8dqMaqqdfETKU5audaQBa6GFgAod2s4g6bstc)vuZVwwcHlffojWDAuZlWtShD00oUKNtkcbMsCHCcC(DImNeMkWPxf8vUa)GFgAod2(8U1B0ZVMRooxrPEdTRO4NhWRLLq4srHtaudacAOWlazcaPYVYjYSLKqFRMoBiW34kAiWSLa3PrnVaN65S2PrnVoxBiWZ1g63jzb(hUieyAgc5e4onQ5f40oUKNtUcC(DImNeMkcbMsWc5e487ezojmvGtVk4RCbEAc725CLNZAIHKWgfvY6naOgauxauAcB9bFVN1ezMt1By3WPscqMaqsdqQvdqPjSBNZvEoRjgsc7XKE9lazcazqtau7cCNg18cCc4G2HVMIqGzlZkKtGZVtK5KWubo9QGVYf4PjSBNZvEoRjgscBuujR3aGAaqDdqlhAI5HxBu8jTzOLwHkWDAuZlWP(PIfHaZwTeYjW53jYCsyQaNEvWx5cCAh)m4vdDonQ59maHvasABFaOgaeDMCA692EvobvhRjgscleCoRpM2XpdwhfjdqyfGwfoN1HFgCSaK8aK0cCNg18cCc4G2HVMIqGzlPfYjW53jYCsyQaNEvWx5cCOHcVaegae13qFSb)aKjae0qHxlPBUa3PrnVahk7VK1BO34kjzriWSfwiKtGZVtK5KWubo9QGVYf40zYPP3B7v5euDSMyijSqW5S(yAh)myDuKmaHvaAv4Cwh(zWXcqYdqslWDAuZlWP(PIfHaZwsaHCcC(DImNeMkWPxf8vUaNagcYs6jnXqs4xQ4ZcRiWDAuZlW7v5euDSMyijeHaZw9riNaNFNiZjHPcCNg18cCjRCwthss)tcC6vbFLlWttyv6W3qopRjgscBuujR3aGAaqlhAI5HxBu8jTzOLwHkWPnPzwh(zWXkWSLiey2QFeYjW53jYCsyQaNEvWx5cCcyiilu2BY3Qj9tslSIa3PrnVaxYkN1BNjeHaZwsCHCcC(DImNeMkWDAuZlWHYEtoP3otiWPnPzwh(zWXkWSLiey2YmeYjW53jYCsyQa3PrnVaxYkN10HK0)KaNEvWx5cCOHcVaegae13qFSb)aKjae0qHxlPBoa1aGGGZz9X0o(zW6OizaYeaYGMaOgauxa0b)m0CgS95DR3ONFnxDCUIs9gAxrXppGxllHWLIcNaOgaeDMCA69wOJzSu9g64Cf7XKE9la1aGOZKttV3g(PJZvSht61VaKA1au3a0b)m0CgS95DR3ONFnxDCUIs9gAxrXppGxllHWLIcNaO2f40M0mRd)m4yfy2secmBjblKtGZVtK5KWubo9QGVYf4DdqPjS9QCcQowtmKe2OOswVba1aG6gGwo0eZdV2O4tAZqlTcfGuRgGOD8ZGxn050OM3ZaewbOwwSqG70OMxG3RYjO6ynXqsicbMsBwHCcC(DImNeMkWPxf8vUaVlaQBa6zZdDVstmKe2TZ5kpNbi1QbOUbOWZ8h2EvobvhRRhcER5T87ezobqTdqnai6m5007T9QCcQowtmKewi4CwFmTJFgSoksgGWkaTkCoRd)m4ybi5biPf4onQ5f4eWbTdFnfHatPBjKtG70OMxG7As4lXNEG00B6TcC(DImNeMkcbMslTqobo)orMtctf40Rc(kxGdnu4fGWaGO(g6Jn4hGmbGGgk8AjDZf4onQ5f4BWCwhNRicbMsJfc5e487ezojmvG70OMxGV8PWFO3OEdbo9QGVYf4hdD82XjYma1aGcpZFy70mD(QjQGT87ezobqnaOWpdoSrrY6y0PIbiScqMHaN2KMzD4NbhRaZwIqGP0saHCcCNg18cCQFQybo)orMtctfHatP7Jqobo)orMtctf4onQ5f4sw5SMoKK(Ne40Rc(kxGdnu4fGWaGO(g6Jn4hGmbGGgk8AjDZbOgauxa0b)m0CgS95DR3ONFnxDCUIs9gAxrXppGxllHWLIcNaOgaeDMCA69wOJzSu9g64Cf7XKE9la1aGOZKttV3g(PJZvSht61VaKA1au3a0b)m0CgS95DR3ONFnxDCUIs9gAxrXppGxllHWLIcNaO2f40M0mRd)m4yfy2secmLUFeYjWDAuZlWLSYz92zcbo)orMtctfHatPL4c5e487ezojmvG70OMxGV8PWFO3OEdbo9QGVYf4hdD82XjYSaN2KMzD4NbhRaZwIqGP0MHqobo)orMtctf4onQ5f4KZBmZYAIkyboTjnZ6WpdowbMTeHatPLGfYjW53jYCsyQa3PrnVa)CLyo9gxjjlWPnPzwh(zWXkWSLieHie4Q4BR5fykTzLwAZkT0Te4987R3yf4MP9fjwmBByAM1VaeajxhgGksL5cacAoaQnkhthscpAdaDSecxhNaODizaYHJH0dobq0o(BWRfGDBvpdqT6xasIMxfFbNaO2eEM)W22Bdafda1MWZ8h22ULFNiZP2aqEaqM5zMCBbqD1Y82TaSbyBM2xKyXSTHPzw)cqaKCDyaQivMlaiO5aO2SrBaOJLq464eaTdjdqoCmKEWjaI2XFdETaSBR6zaQvF6xasIMxfFbNai8IuIaOT5hU5aewgGIbGAlyhGsLQAR5bOrHppMdG6s(2bOUAzE7wa2aSnt7lsSy22W0mRFbiasUomavKkZfae0CauBOPTna0XsiCDCcG2HKbihogsp4ear74VbVwa2Tv9ma1YS9lajrZRIVGtauB2botuFY22Bdafda1MDGZe1NSTDl)orMtTbG6sAZB3cWUTQNbOwyr)cqs08Q4l4eaHxKseaTn)WnhGWYaumauBb7auQuvBnpank85XCauxY3oa1vlZB3cWUTQNbOwsG(fGKO5vXxWjacViLiaAB(HBoaHLbOyaO2c2bOuPQ2AEaAu4ZJ5aOUKVDaQRwM3UfGDBvpdqT6t)cqs08Q4l4eaHxKseaTn)WnhGWYaumauBb7auQuvBnpank85XCauxY3oa1vlZB3cWgGTzAFrIfZ2gMMz9labqY1HbOIuzUaGGMdGAdXO0ga6yjeUoobq7qYaKdhdPhCcGOD83Gxla72QEgGAHf9lajrZRIVGtaeErkra028d3CacldqXaqTfSdqPsvT18a0OWNhZbqDjF7auxTmVDla72QEgGA1N(fGKO5vXxWjaQnh8ZqZzW22EBaOyaO2CWpdnNbBB7w(DImNAda1vlZB3cWUTQNbOw9t)cqs08Q4l4eaHxKseaTn)WnhGWYaumauBb7auQuvBnpank85XCauxY3oa1fwyE7wa2Tv9ma1QF6xasIMxfFbNaO2eEM)W22Bdafda1MWZ8h22ULFNiZP2aqDjT5TBby3w1ZauR(PFbijAEv8fCcGAZb)m0CgSTT3gakgaQnh8ZqZzW22ULFNiZP2aqD1Y82TaSBR6zaQLz0VaKenVk(cobqTj8m)HTT3gakgaQnHN5pSTDl)orMtTbG6QL5TBbydW2mTViXIzBdtZS(fGai56WaurQmxaqqZbqTHMzxf3ga6yjeUoobq7qYaKdhdPhCcGOD83Gxla72QEgGA1QFbijAEv8fCcGWlsjcG2MF4MdqyzakgaQTGDakvQQTMhGgf(8yoaQl5BhG6QL5TBby3w1ZaulSOFbijAEv8fCcGWlsjcG2MF4MdqyzakgaQTGDakvQQTMhGgf(8yoaQl5BhG6QL5TBby3w1ZaK0MTFbijAEv8fCcGWlsjcG2MF4MdqyzakgaQTGDakvQQTMhGgf(8yoaQl5BhG6QL5TBbydWUTrQmxWjasIdqonQ5bOCTXAbylWxfMkWu6(0hbUYnqvMf4sqaeo8PQu5zaYmr4p4dGTeea1xZehSFnbiP7JuaK0MvAPbydW2Prn)AvoMoKeEGHm5v5x5ezwQ3jzzKe6B10zdPgfzlhfKuQ8mmlZPrnVLCEJzwwtubBPZgsPYZWSMZllZPrnV9CLyo9gxjjBPZgsrNpvrnVSWZ8hwY5nMzznrfmaBNg18Rv5y6qs4bgYKFHjjNxRWbaBNg18Rv5y6qs4bgYKNyIiZjnu2BYPE1BOJX86by70OMFTkhthscpWqM8qzE7qphkay70OMFTkhthscpWqM8HF64CfPkizh8ZqZzW2DGZqZzWAMKGV1YsiCPOWja2onQ5xRYX0HKWdmKj)gmN1X5kaSby70OMFXqM8KWyjSuMbylbbqMzda5Dypbq(Nai5o)Lq4kxyjgGW0mjjcG4NjlEnZhG6XauA(2eauAaOOtTae0CaKs2BY3cqem1HxgGQOnjaIGbOygaAvCsYMaK)jaQhdqu)Btaqh7Pk3eGK78xcbOvHPfurbicyiO1cW2Prn)IHm5JZFjeUYfwQEd92zcPkizDh(zWHTwTs2BYhaBNg18lgYKhEzDfmPuVtYY6RMa(n46oDI3O(MRM65SufKmNgLkwZptw8kRvJUiGHGS0zUu9EWjTVRdNdlSIA1DtNjNMEVLoZLQ3doP9DD4CypM0RFvRMy2TruKSogDQytWcZ2UA1D50OuXA(zYIxS2QbbmeK94DEpQ3q73n9SWkQvtadbzPZCP69GtAFxhohwyL2by70OMFXqM8WlRRGjxa2sqsqaKzoo7nbiiNwVba1CGpaknWebab)rLbOMdma1XvXaKcCaqsS8oVh1Baq9L7MEauA69sbqZbqfeafDyaIoton9EaQwakMbGYZBaqXaqjo7nbiiNwVba1CGpaYm3atewaQTbbq)8manqau0HxgGOZNQOMFbi)yaYjYmafdarYba1RIo1dqrhgGAzwaAz68PfGYm3ZBkfafDyaAlsacYP8cqnh4dGmZnWeba5WXq6rr9CUPfGTeKeea50OMFXqM8p3dAG)K(4DYQyPkiz7aNjQpzFUh0a)j9X7KvXn6IagcYE8oVh1BO97MEwyf1QPZKttV3E8oVh1BO97ME2Jj96xS2YSQvh(zWHnkswhJovSjT6N2by70OMFXqM8upN1onQ515AdPENKLrtlaBNg18lgYKN65S2PrnVoxBi17KSmIrrQnUIgYAjvbjZPrPI18ZKfVMGfncpZFyjQlT6bsRCCtl)orMtaSDAuZVyitEQNZANg186CTHuVtYY2qQnUIgYAjvbjZPrPI18ZKfVMGfn6o8m)HLOU0QhiTYXnT87ezobW2Prn)IHm5PEoRDAuZRZ1gs9ojlJMzxfl1gxrdzTKQGK50OuXA(zYIxSknaBNg18lgYK3pQ)SoM74paydW2Prn)AjgfzlFk8h6nQ3qkAtAM1HFgCSYAjvbjJagcYQQu4B1Q4FiTht61Vn6IagcYQQu4B1Q4FiTht61VMyqtQvFm0XBhNiZTdW2Prn)AjgfmKjVKvoRPdjP)jPOnPzwh(zWXkRLufKmOHcVyq9n0hBWVjqdfETKU5niGHGSpV1B0ZVMRooxrPEdTRO4NhWRfwrTAOHcVyq9n0hBWVjqdfETKU5y0YSniGHGSpV1B0ZVMRooxrPEdTRO4NhWRfwPbbmeK95TEJE(1C1X5kk1BODff)8aETht61VMyqtaSDAuZVwIrbdzYlzLZ6TZeaSDAuZVwIrbdzY3RYjO6ynXqsivbjdAOWlguFd9Xg8Bc0qHxlPBEdi4CwFmTJFgSoks2edAsTAcyiilPN0edjHFPIplScaBNg18RLyuWqM8qz)LSEd9gxjjlvbjdAOWlguFd9Xg8Bc0qHxlPBoaBNg18RLyuWqM8qzVjN0BNjay70OMFTeJcgYKN65S2PrnVoxBi17KSSpCP24kAiRLufKSd(zO5my7Z7wVrp)AU64CfL6n0UIIFEaVwwcHlffo1aAOWRjQ8RCImBjj03QPZgaSDAuZVwIrbdzYNyp6OPDCjpNuQcsg0qHxmO(g6Jn43eOHcVws3Ca2onQ5xlXOGHm5pxjMtVXvsYsrBsZSo8ZGJvwlPkizeWqqw6mxQEp4K231HZHfwPbbmeKLoZLQ3doP9DD4CypM0RFnPLTp93GMay70OMFTeJcgYKNCEJzwwtublfTjnZ6WpdowzTKQGKradbzPZCP69GtAFxhohwyLgeWqqw6mxQEp4K231HZH9ysV(1Kw2(0FdAcGTtJA(1smkyitExtcFj(0dKMEtVfGTtJA(1smkyit(ZvI50BCLKSu0M0mRd)m4yL1sQcsgbmeKnkf9aPJoSEvy)SB4ujLHfaSDAuZVwIrbdzYtoVXmlRjQGLI2KMzD4NbhRSwsvqYcpZFy9SshxRCCYJ5S87ezo1Olcyiil58gZSSgc(AAHvAqadbzjN3yML1qWxt7XKE9RjqdfEXYDPYVYjYSLKqFRMoB03uFd9Xg83E)nOP2by70OMFTeJcgYKVxLtq1XAIHKqQcsg0qHxmO(g6Jn43eOHcVws38gDhfvY6nA0feCoRpM2XpdwhfjBIbnPwD3PjS9QCcQowtmKe2OOswVrdcyiil58gZSSgc(AApM0RFXkeCoRpM2Xpdwhfj33T6VbnPwD3PjS9QCcQowtmKe2OOswVrJUjGHGSKZBmZYAi4RP9ysV(TD1QJIK1XOtfBslZOr3PjS9QCcQowtmKe2OOswVbaBjiaQTbbqnhyaknFBcaQJRIbim5DR3ONFnBZcqYDUIs9gauFrrXppGxPaOTivYnbiQVbajXu5majrdjP)jaQGaOMdma1B(2ea0OIpQRaqZdq91dfEbiOBibO0uVbaTJfGABqauZbgGsda1XvXaeM8U1B0ZVMTzbi5oxrPEdaQVOO4NhWla1CGbOTZaNtae13aGKyQCgGKOHK0)eavqauZb(aiOHcVauTaebNNEau0Hbi6SbanqaKzcZBmZYaKPvWa0CaKeRReZbq4XvsYaSDAuZVwIrbdzYlzLZA6qs6FskAtAM1HFgCSYAjvbjdAOWlguFd9Xg8Bc0qHxlPBEJU6(GFgAod2(8U1B0ZVMRooxrPEdTRO4NhWRA1qdfEnrLFLtKzljH(wnD2ODa2sqaKzAfDaim5DR3ONFnBZcqYDUIs9gauFrrXppGxaA(CtasIPYzasIgss)taubbqnh4dGIZvwaYpgGMhGOZKttVxkaAIo81RwgG2yuai4TEdasIPYzasIgss)taubbqnh4dGOW3XFaqqdfEbiNCG)aGQfG4FGn6aqXaql8gE9au0HbiNCG)aGgiakksgGYmuaqqZbq(3eGgiaQ5aFauCUYcqXaq0HKbObccGOZKttVhGTtJA(1smkyitEjRCwthss)tsrBsZSo8ZGJvwlPkizqdfEXG6BOp2GFtGgk8AjDZBCWpdnNbBFE36n65xZvhNROuVH2vu8Zd4TbDMCA69wOJzSu9g64Cf7XKE9lw7cAOWlwUlv(vorMTKe6B10zJ(M6BOp2G)27Vbn1Ed6m5007THF64Cf7XKE9lw7cAOWlwUlv(vorMTKe6B10zJ(M6BOp2G)27Vbn1EJU6o8m)HDdMZ64Cf1QdpZFy3G5SooxPbDMCA692nyoRJZvSht61VyTlOHcVy5Uu5x5ez2ssOVvtNn6BQVH(yd(BV)g0u7TdW2Prn)AjgfmKj)gmN1X5ksvqYGgk8Ib13qFSb)Manu41s6MdW2Prn)AjgfmKj)YNc)HEJ6nKI2KMzD4NbhRSwsvqYstyx(u4p0BuVH9yOJ3oorMB0nbmeKLoZLQ3doP9DD4CyHvuRo8m)H1ZkDCTYXjpMRXXqhVDCIm3OBcyiil58gZSSgc(AAHvay70OMFTeJcgYK)4DEpQ3q73n9ay70OMFTeJcgYKVxLt6vPUkwa2onQ5xlXOGHm5PZCP69GtAFxhohsvqY6MagcYsN5s17bN0(UoCoSWkaSDAuZVwIrbdzYtoVXmlRjQGLQGKradbzjN3yML1qWxtlSIA1qdfEXWPrnVvYkN10HK0)KL6BOp2GFScnu41s6MRwnbmeKLoZLQ3doP9DD4CyHvay70OMFTeJcgYK)CLyo9gxjjlfTjnZ6WpdowzTay70OMFTeJcgYKVxLtq1XAIHKqQcswAcBVkNGQJ1edjH9yOJ3oorMby70OMFTeJcgYKF5tH)qVr9gsrBsZSo8ZGJvwlPkizeWqqwvLcFRwf)dPfwbGnaBNg18RLMwzD8tzMxQcsw4z(dBWh5Qhin)gUbtYFy53jYCQb0qHxtGgk8AjDZby70OMFT00IHm5jYZK0qWxtPkizeWqqw6mxQEp4K231HZHfwbGTtJA(1stlgYK3FkVX5zn1ZzPkizeWqqw6mxQEp4K231HZHfwbGTtJA(1stlgYKhQoMiptsQcsgbmeKLoZLQ3doP9DD4CyHvay70OMFT00IHm5ZLrNy19vWjds(da2onQ5xlnTyitEc3qpq64kQKRufKm6m5007Tsw5SMoKK(NSqW5S(yAh)myDuKmwnOja2onQ5xlnTyitEc(w(KSEdPkizeWqqw6mxQEp4K231HZHfwrT6OizDm6uXM0clay70OMFT00IHm5jHXsyPmdW2Prn)APPfdzYRmrnVufKmIz3gqLrNqFmPx)AI09rTAcyiilDMlvVhCs776W5WcRaW2Prn)APPfdzYdL5Td9COqQ6d(oyLqxqYOD8)5C9gn6Eh4mr9jRc8gWzwZhSsuZlvbjRlOHcVMiXnRA10zYPP3BPZCP69GtAFxhoh2Jj96xtmOP2B01oWzI6twf4nGZSMpyLOMxT6DGZe1NSQMShvM17KvXF0GagcYQAYEuzwVtwf)Hnn9(2by70OMFT00IHm5d)0X5ksvqYGgk8Ib13qFSb)Manu41s6M34GFgAod2UdCgAodwZKe8TwwcHlffo1i8thNRypM0RFnXGMAqNjNMEVfk7hBpM0RFnXGMA0LtJsfR5NjlEXAl1QDAuQyn)mzXRSwnIIK1XOtfJ1(0FdAQDa2onQ5xlnTyitEOSFSu56znnjt6(ivbjdAOWlguFd9Xg8Bc0qHxlPBEJWpDCUIfwPXb)m0CgSDh4m0CgSMjj4BTSecxkkCQruKSogDQySkb6VbnbW2Prn)APPfdzYlzLZ6TZesvqYCAuQyn)mzXRSwnc)m4WgfjRJrNk2eOHcVy5Uu5x5ez2ssOVvtNn6BQVH(yd(BV)g0eaBNg18RLMwmKjp58gZSSMOcwQcsMtJsfR5NjlEL1Qr4Nbh2OizDm6uXManu4fl3Lk)kNiZwsc9TA6SrFt9n0hBWF793GMay70OMFT00IHm5pxjMtVXvsYsvqYCAuQyn)mzXRSwnc)m4WgfjRJrNk2eOHcVy5Uu5x5ez2ssOVvtNn6BQVH(yd(BV)g0eaBNg18RLMwmKjVVkmn0dKo6WA2nYSufKSWpdoSPAd)PmwL1paSby70OMFT0m7QyzlFk8h6nQ3qkAtAM1HFgCSYAjvbjl8m)HTtZ05RMOc2YVtK5udcyiiRQsHVvRI)H0EmPx)2GagcYQQu4B1Q4FiTht61VMyqtaSDAuZVwAMDvmgYKVxLt6vPUkwPkizDFEL0Sk(dRNsRLnV2yvR(8kPzv8hwpLw7XKE9lwL1YSQv70OuXA(zYIxSk78kPzv8hwpLwlDG)O)sdW2Prn)APz2vXyit(J359OEdTF30tQcsw3NxjnRI)W6P0AzZRnw1QpVsAwf)H1tP1EmPx)IvzMHA1onkvSMFMS4fRYoVsAwf)H1tP1sh4p6V0aSDAuZVwAMDvmgYKNoZLQ3doP9DD4CivbjR7ZRKMvXFy9uATS51gRA1NxjnRI)W6P0ApM0RFXQSwMvTANgLkwZptw8IvzNxjnRI)W6P0APd8h9xAa2onQ5xlnZUkgdzY3RYjO6ynXqsivbjdcoN1ht74NbRJIKnXGMay70OMFT0m7QymKjFI9OJM2XL8CsPkizD195vsZQ4pSEkTw28AJvT6ZRKMvXFy9uATht61VyTpQv70OuXA(zYIxSk78kPzv8hwpLwlDG)O)s3UA1qdfEXG6BOp2GFtGgk8AjDZB09b)m0CgSLWn0dKMe(ROMFTSecxkkCcGTtJA(1sZSRIXqM8upN1onQ515AdPENKL9Hl1gxrdzTKQGKDWpdnNbBFE36n65xZvhNROuVH2vu8Zd41YsiCPOWPgqdfEnrLFLtKzljH(wnD2aGTtJA(1sZSRIXqM80oUKNtUaSDAuZVwAMDvmgYKNaoOD4RPufKS0e2TZ5kpN1edjHnkQK1B0OR0e26d(EpRjYmNQ3WUHtL0ePvRonHD7CUYZznXqsypM0RFnXGMAhGTtJA(1sZSRIXqM8u)uXsvqYsty3oNR8CwtmKe2OOswVrJUxo0eZdV2O4tAZqlTcfGTtJA(1sZSRIXqM8eWbTdFnLQGKr74NbVAOZPrnVNXQ02(0Goton9EBVkNGQJ1edjHfcoN1ht74NbRJIKX6QW5So8ZGJfllnaBNg18RLMzxfJHm5HY(lz9g6nUsswQcsg0qHxmO(g6Jn43eOHcVws3Ca2onQ5xlnZUkgdzYt9tflvbjJoton9EBVkNGQJ1edjHfcoN1ht74NbRJIKX6QW5So8ZGJfllnaBNg18RLMzxfJHm57v5euDSMyijKQGKradbzj9KMyij8lv8zHvay70OMFT0m7QymKjVKvoRPdjP)jPOnPzwh(zWXkRLufKS0ewLo8nKZZAIHKWgfvY6nASCOjMhETrXN0MHwAfkaBNg18RLMzxfJHm5LSYz92zcPkizeWqqwOS3KVvt6NKwyfa2onQ5xlnZUkgdzYdL9MCsVDMqkAtAM1HFgCSYAbW2Prn)APz2vXyitEjRCwthss)tsrBsZSo8ZGJvwlPkizqdfEXG6BOp2GFtGgk8AjDZBabNZ6JPD8ZG1rrYMyqtn66GFgAod2(8U1B0ZVMRooxrPEdTRO4NhWRLLq4srHtnOZKttV3cDmJLQ3qhNRypM0RFBqNjNMEVn8thNRypM0RFvRU7d(zO5my7Z7wVrp)AU64CfL6n0UIIFEaVwwcHlffo1oaBNg18RLMzxfJHm57v5euDSMyijKQGK1DAcBVkNGQJ1edjHnkQK1B0O7LdnX8WRnk(K2m0sRqvRM2XpdE1qNtJAEpJ1wwSaGTtJA(1sZSRIXqM8eWbTdFnLQGK1v3pBEO7vAIHKWUDox55SA1DhEM)W2RYjO6yD9qWBnVLFNiZP2BqNjNMEVTxLtq1XAIHKWcbNZ6JPD8ZG1rrYyDv4Cwh(zWXILLgGTtJA(1sZSRIXqM8UMe(s8Phin9MElaBNg18RLMzxfJHm53G5SooxrQcsg0qHxmO(g6Jn43eOHcVws3Ca2onQ5xlnZUkgdzYV8PWFO3OEdPOnPzwh(zWXkRLufKSJHoE74ezUr4z(dBNMPZxnrfSLFNiZPgHFgCyJIK1XOtfJvZaGTtJA(1sZSRIXqM8u)uXaSDAuZVwAMDvmgYKxYkN10HK0)Ku0M0mRd)m4yL1sQcsg0qHxmO(g6Jn43eOHcVws38gDDWpdnNbBFE36n65xZvhNROuVH2vu8Zd41YsiCPOWPg0zYPP3BHoMXs1BOJZvSht61VnOZKttV3g(PJZvSht61VQv39b)m0CgS95DR3ONFnxDCUIs9gAxrXppGxllHWLIcNAhGTtJA(1sZSRIXqM8sw5SE7mbaBNg18RLMzxfJHm5x(u4p0BuVHu0M0mRd)m4yL1sQcs2XqhVDCImdW2Prn)APz2vXyitEY5nMzznrfSu0M0mRd)m4yL1cGTtJA(1sZSRIXqM8NReZP34kjzPOnPzwh(zWXkRfaBa2onQ5x7hUSnyoRJZvay70OMFTF4yitEOJzSu9g64CfPkizDtadbz7v5KEvQRI1EmPx)QwnbmeKTxLt6vPUkw7XKE9Bd6m5007Tsw5SMoKK(NSht61VaSDAuZV2pCmKjF4NooxrQcsw3eWqq2EvoPxL6QyTht61VQvtadbz7v5KEvQRI1EmPx)2Goton9ERKvoRPdjP)j7XKE9laBa2onQ5x7gYsShD00oUKNtkvbjdAOWlguFd9Xg8Bc0qHxlPBEJU6(8kPzv8hwpLwlBETXQwD3NxjnRI)W6P0AHvACEL0Sk(dRNsRnbFEuZJX5vsZQ4pSEkT26nPpTRw95vsZQ4pSEkTwyLgNxjnRI)W6P0ApM0RFXQeWSaSDAuZV2nWqM8lFk8h6nQ3qkAtAM1HFgCSYAjvbjR70e2Lpf(d9g1ByJIkz9gnc)m4WgfjRJrNkgRsC1QjGHGSQkf(wTk(hslSsdcyiiRQsHVvRI)H0EmPx)AIbnbW2Prn)A3adzYdL9MCsVDMaGTtJA(1UbgYK)4DEpQ3q73n9KQGK195vsZQ4pSEkTw28AJvT6UpVsAwf)H1tP1cR0ORZRKMvXFy9uATj4ZJAEmoVsAwf)H1tP1wVjsBw1QpVsAwf)H1tP1sh4pK1QD1QpVsAwf)H1tP1cR048kPzv8hwpLw7XKE9lwLaMvTAIz3grrY6y0PInPLzby70OMFTBGHm57v5KEvQRIvQcsw3NxjnRI)W6P0AzZRnw1Q7(8kPzv8hwpLwlSsJZRKMvXFy9uATj4ZJAEmoVsAwf)H1tP1wVjsBw1QpVsAwf)H1tP1cR048kPzv8hwpLw7XKE9lwL2SQvtm72ikswhJovSjsBwa2onQ5x7gyitE6mxQEp4K231HZHufKSUpVsAwf)H1tP1YMxBSQvthv87Fy)YOtOHCUbDMCA692EvoPxL6QyTht61VQv3nDuXV)H9lJoHgY5gD195vsZQ4pSEkTwyLgNxjnRI)W6P0AtWNh18yCEL0Sk(dRNsRTEtWcZQw95vsZQ4pSEkTwyLgNxjnRI)W6P0ApM0RFXQ0MvT6UpVsAwf)H1tP1cR0UA1eZUnIIK1XOtfBcwywa2onQ5x7gyitEjRCwVDMaGTtJA(1UbgYKhk7VK1BO34kjzPkizqdfEXG6BOp2GFtGgk8AjDZby70OMFTBGHm5Dnj8L4tpqA6n9wa2onQ5x7gyit(EvobvhRjgscPkizqW5S(yAh)myDuKSjs3FdAQXYHMyE41gfFsBgAPvOQvtadbzj9KMyij8lv8zHvuRU7LdnX8WRnk(K2m0sRqB0feCoRpM2XpdwhfjBIbnPwn0qHxmO(g6Jn43eOHcVws38gD9S5HUxPjgscRQj7rL5gPjSlFk8h6nQ3WgfvY6nAKMWU8PWFO3OEd7XqhVDCImRw9ZMh6ELMyijSkD4BiNNB0nbmeKLCEJzwwdbFnTWknGgk8Ib13qFSb)Manu41s6M33onQ5Tsw5SMoKK(NSuFd9Xg83FSOD1QjMDBefjRJrNk2KwMTDa2onQ5x7gyitEjRCwthss)tsrBsZSo8ZGJvwlPkizlhAI5HxBu8jTzOLwH2inHvPdFd58SMyijSrrLSEJgDtadbzj9KMyij8lv8zHvay70OMFTBGHm5P(PILQGK50OuXA(zYIxS2Qr3h8ZqZzW2Rz2LCdpljFRMop0a)P6n0BCLK8AzjeUuu4eaBNg18RDdmKjpbCq7WxtPkizonkvSMFMS4fRTA09b)m0CgS9AMDj3WZsY3QPZdnWFQEd9gxjjVwwcHlffo1Goton9EBVkNGQJ1edjHfcoN1ht74NbRJIKX6QW5So8ZGJTrx0o(zWRg6CAuZ7zSkTTpQvNMWUDox55SMyijSrrLSEJ2by70OMFTBGHm53G5SooxrQcsg0qHxmO(g6Jn43eOHcVws3Ca2onQ5x7gyitEY5nMzznrfSu0M0mRd)m4yL1sQcsw4z(dRNv64ALJtEmNLFNiZPgDradbzjN3yML1qWxtlSsdcyiil58gZSSgc(AApM0RFnbAOWlwUlv(vorMTKe6B10zJ(M6BOp2G)27Vbn1OBcyiiBVkN0RsDvS2Jj96x1QjGHGSKZBmZYAi4RP9ysV(TXZMh6ELMyijSkD4BiNNBhGTtJA(1UbgYKxYkN10HK0)Ku0M0mRd)m4yL1sQcsgeCoRpM2XpdwhfjBIbn1aAOWlguFd9Xg8Bc0qHxlPBoaBNg18RDdmKj)5kXC6nUsswkAtAM1HFgCSYAjvbjJagcYgLIEG0rhwVkSF2nCQKYWc1Qtty3oNR8CwtmKe2OOswVbaBNg18RDdmKjp58gZSSMOcwQcswAc725CLNZAIHKWgfvY6nay70OMFTBGHm5x(u4p0BuVHu0M0mRd)m4yL1sQcs2XqhVDCIm3i8ZGdBuKSogDQySkXvRMagcYQQu4B1Q4FiTWkaSDAuZV2nWqM89QCcQowtmKesvqYE28q3R0edjHD7CUYZ5gqdfEXQk)kNiZwsc9TA6Sr)LUrAc7YNc)HEJ6nSht61VyTp93GMay70OMFTBGHm5PDCjpNCby70OMFTBGHm5LSYznDij9pjfTjnZ6WpdowzTKQGKbnu4fdQVH(yd(nbAOWRL0nhGTtJA(1UbgYKVxLtq1XAIHKqQcs2b)m0CgS9AMDj3WZsY3QPZdnWFQEd9gxjjVwwcHlffobW2Prn)A3adzYtoVXmlRjQGLI2KMzD4NbhRSwsvqYiGHGSKZBmZYAi4RPfwrTAOHcVy40OM3kzLZA6qs6FYs9n0hBWpwHgk8AjDZ77w9rT60e2TZ5kpN1edjHnkQK1BOwnbmeKTxLt6vPUkw7XKE9laBNg18RDdmKj)5kXC6nUsswkAtAM1HFgCSYAbW2Prn)A3adzY3RYjO6ynXqsivbjRRNnp09knXqsyvnzpQm3inHD5tH)qVr9g2OOswVHA1pBEO7vAIHKWQ0HVHCEwT6Nnp09knXqsy3oNR8CUb0qHxS2hZ2EJUxo0eZdV2O4tAZqlTcveIqia]] )


end