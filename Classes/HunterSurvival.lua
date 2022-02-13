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


    -- Tier 28:
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


    spec:RegisterPack( "Survival", 20211123, [[d80xNbqiHqpssK6ssIYMaKpje1OGKCkirRcvQ8kamluj3ssuTlj(fQOHHkvDmH0YaOEgKqtdGKRbjyBOsHVbqQXjeHZHkL06ai8ouPi08iP6EKK9jeCqjryHKuEiKunrjrKUiQueSruPi5JOsPmsuPi1jfIOvcOEjQuuZuis3useHDkP6NsIiAOOsr0srLs8uGMkKQVIkLQXkjs2lI)sQbJYHPAXi5XqnzfUmXMv0NrvJwOCArRwse1RrfMTGBJu7wv)wQHtIJdjLLR0Zvz6uUoeBxs57ssJxs48cvRhGO5dPSFqtIsqNaoCti1bm3d4OrJcyuSayadOqbadycOfxriGkoMdNxiGVtleqqKTwwZdeqfpEO9bbDc41ilwiGvAilMzkhGGto5tlgcvb30CEjnsWTSF86tJZlPXCsaPqYGfjFcfbC4MqQdyUhWrJgfWOybWagqHcrb0eqhXI1lbemPrDcySCmKNqrahYHjGGiBTSMhGmUPrEtwiW17AcnLSqwuuKlidWCpGJsad5zhbDc4BobDs9Oe0jGo2Y(jGNjsqBRRqaL3PcYGOgXi1bmbDcO8ovqge1iG4nnztNagriJczolvZWqFk5M2vwH2Z)Gm0qdYOqMZs1mm0NsUPDLvO98pidiid3Dy0v)chziOXnnT)JYk0E(hb0Xw2pbCUIaiZNxBRRqmsDuKGobuENkidIAeq8MMSPtaJiKrHmNLQzyOpLCt7kRq75FqgAObzuiZzPAgg6tj30UYk0E(hKbeKH7om6QFHJme04MM2)rzfAp)Ja6yl7NaA(QT1vigXiGdz6ibJGoPEuc6eqhBz)eqAeajGmieq5DQGmiQrmsDatqNakVtfKbrncOJTSFcOT(JAizibK5ZRVyTrahYH3uXY(jGCBnK5XeFaz(pGm0x)rnKmKasbYQZnjQdzYl0PCCbzvfiB0FKniB0qMflpiB2lKPe84YEqgLGDKtGS0I8aYOeiZ6gYofNMooK5)aYQkqg2)iBq2k(idXHm0x)rni7ueCotmKrHmNxHaI30KnDcyeHmZxEXk5PvcECzjgPoksqNakVtfKbrncOJTSFcyLCBipVK7QhYz5h)0ypeiG4nnztNasHmNfC37iF3KH2VZrcwbrbYqdniJQVdYacYMjFmtVcTN)bzQdzOi3taFNwiGvYTH88sUREiNLF8tJ9qGyK6akc6eqhBz)eqKt0Pj0hbuENkidIAeJuhfiOtaL3PcYGOgb0Xw2pbe7HG2Xw2VoKNrad5z63PfciECeJuNBqqNakVtfKbrnciEtt20jGo2YAIwEHoLdYuhYqridiiZ8G8wHk3XP7PwzL4f5DQGmiGNTj2i1JsaDSL9taXEiODSL9Rd5zeWqEM(DAHas1keJuhqtqNakVtfKbrnciEtt20jGo2YAIwEHoLdYuhYqridiilIqM5b5TcvUJt3tTYkXlY7ubzqapBtSrQhLa6yl7NaI9qq7yl7xhYZiGH8m970cb8mIrQhjiOtaL3PcYGOgbeVPjB6eqhBznrlVqNYbzraYamb8SnXgPEucOJTSFci2dbTJTSFDipJagYZ0VtleqCq8AcXi15wjOtaDSL9ta9f7VOTEx5ncO8ovqge1igXiGkRGBAk3iOtQhLGobuENkidIAeWwHaEILtciEtt20jGMhK3k09Z39jAQ0KI8ovqgeWHC4nvSSFcy9UMqtjlKfff5cYam3d4OeWA(QFNwiG0u6904(mcOJTSFcynFtNkieWAEar0s4ecOJTS)Y6kwV6Z2KdPG7ZiG18aIqaDSL9xO7NV7t0uPjfCFgXi1bmbDcOJTSFc4Hqt3VwrmcO8ovqge1igPoksqNa6yl7Nas1MfKHEg84YOA(8ARRiFcO8ovqge1igPoGIGob0Xw2pbCgKlgE9PraL3PcYGOgXi1rbc6eq5DQGmiQraXBAYMobCrEz2lVuUgjm7Lx0cnLSxrqnKurrgeqhBz)eqZxTTUcXi15ge0jGo2Y(jGNjsqBRRqaL3PcYGOgXigb8mc6K6rjOtaL3PcYGOgbeVPjB6eWzJroidaid7NPxHxEitDiB2yKRq7vqaDSL9tahIBX04yohRttmsDatqNakVtfKbrncOJTSFc4jRI8M(S85jG4nnztNagriB0w5KvrEtFw(8flXCKppKbeKz(YlwXsArBTEKcKfbidqdzOHgKrHmNLAPISNUM8nDbrbYacYOqMZsTur2txt(MUScTN)bzQdz84bbehhheT5lVyhPEuIrQJIe0jGo2Y(jGZGhxg6lwBeq5DQGmiQrmsDafbDcOJTSFc4kx)ULpV23TRsaL3PcYGOgXi1rbc6eqhBz)eWQzyOpLCt7iGY7ubzquJyK6Cdc6eqhBz)eqC37iF3KH2VZrcgbuENkidIAeJuhqtqNa6yl7NaYrgc6lwBeq5DQGmiQrms9ibbDcO8ovqge1iG4nnztNaoBmYbzaazy)m9k8YdzQdzZgJCfAVccOJTSFc4m4ph5ZRpBtoeIrQZTsqNa6yl7Na6AAKDiRUNA82vpcO8ovqge1igPEuUNGobuENkidIAeq8MMSPtaNiHGEfCmF5fTL0cKPoKXJhqgAObzZgJCqgaqg2ptVcV8qM6q2SXixH2RaYacYqfK9sfMUAQPAAQsTo4wgeidiiB0w5KvrEtFw(8flXCKppKbeKnARCYQiVPplF(YkZvUyovqGm0qdYEPctxn1unnvrjMSnD)cKbeKfriJczol09Z39j6jYgVGOazabzZgJCqgaqg2ptVcV8qM6q2SXixH2RaYQCiZXw2FHJme04MM2)rb7NPxHxEiJ7GmueYqjKHgAqML0I2A9ifitDilk3taDSL9taRMHXmxrt10ueJupAuc6eq5DQGmiQraXBAYMob0Xwwt0Yl0PCqweGSOqgqqweHSf5LzV8szJhCooZdCi7PX9pBKFKpV(Sn5qUIGAiPIImiGo2Y(jGyFRjeJupkGjOtaL3PcYGOgbeVPjB6eqhBznrlVqNYbzraYIczabzreYwKxM9YlLnEW54mpWHSNg3)Sr(r(86Z2Kd5kcQHKkkYaYacYWDhgD1VundJzUIMQPPktKqqVcoMV8I2sAbYIaKDksiOnF5f7GmGGmubz4y(YlNEUo2Y(9aKfbidWfuaYqdniB0w5ITUYlbnvttvSeZr(8qgkjGo2Y(jGuigoMSXjgPEuuKGobuENkidIAeq8MMSPtaNng5GmaGmSFMEfE5Hm1HSzJrUcTxbb0Xw2pb8mrcABDfIrQhfqrqNakVtfKbrncOJTSFciD)8DFIMknHaI30KnDcO5b5TIhuI5ALvgU1BrENkididiidvqgfYCwO7NV7t0tKnEbrbYacYOqMZcD)8DFIEISXlRq75FqM6q2SXihKXjKHkiRMVPtfKcnLEpnUpdYQCid7NPxHxEidLqg3bz84bKbeKfriJczolvZWqFk5M2vwH2Z)Gm0qdYOqMZcD)8DFIEISXlRq75Fqgqq2lvy6QPMQPPkkXKTP7xGmusaXXXbrB(Yl2rQhLyK6rrbc6eq5DQGmiQraDSL9ta5idbnUPP9FqaXBAYMobCIec6vWX8Lx0wslqM6qgpEazabzZgJCqgaqg2ptVcV8qM6q2SXixH2RGaIJJdI28LxSJupkXi1JYniOtaL3PcYGOgb0Xw2pbCDfRx9zBYHqaXBAYMobKczolwQO7P2Ij6tr8TCMJ5aYubzOiKHgAq2OTYfBDLxcAQMMQyjMJ85jG444GOnF5f7i1Jsms9OaAc6eq5DQGmiQraXBAYMobC0w5ITUYlbnvttvSeZr(8eqhBz)eq6(57(envAcXi1JgjiOtaL3PcYGOgb0Xw2pb8KvrEtFw(8eq8MMSPtaxzUYfZPccKbeKz(YlwXsArBTEKcKfbidqdzOHgKrHmNLAPISNUM8nDbrHaIJJdI28LxSJupkXi1JYTsqNakVtfKbrnciEtt20jGVuHPRMAQMMQCXwx5LaKbeKnBmYbzraYQ5B6ubPqtP3tJ7ZGmUdYamKbeKnARCYQiVPplF(Yk0E(hKfbidfGmUdY4XdcOJTSFcy1mmM5kAQMMIyK6aM7jOtaDSL9taXXCowN(iGY7ubzquJyK6aokbDcO8ovqge1iGo2Y(jGCKHGg300(piG4nnztNaoBmYbzaazy)m9k8YdzQdzZgJCfAVccioooiAZxEXos9OeJuhWaMGobuENkidIAeq8MMSPtaxKxM9YlLnEW54mpWHSNg3)Sr(r(86Z2Kd5kcQHKkkYGa6yl7NawndJzUIMQPPigPoGrrc6eq5DQGmiQraDSL9taP7NV7t0uPjeq8MMSPtaPqMZcD)8DFIEISXlikqgAObzZgJCqgaqMJTS)chziOXnnT)Jc2ptVcV8qweGSzJrUcTxbKv5qwuuaYqdniB0w5ITUYlbnvttvSeZr(8qgAObzuiZzPAgg6tj30UYk0E(hbehhheT5lVyhPEuIrQdyafbDcO8ovqge1iGo2Y(jGRRy9QpBtoecioooiAZxEXos9OeJuhWOabDcO8ovqge1iG4nnztNa(sfMUAQPAAQsTo4wgeidiiB0w5KvrEtFw(8flXCKppKHgAq2lvy6QPMQPPkkXKTP7xGm0qdYEPctxn1unnv5ITUYlbidiiB2yKdYIaKHcCpb0Xw2pbSAggZCfnvttrmIraXJJGoPEuc6eq5DQGmiQraXBAYMob08G8wXKL(09ulpVZl0YBf5DQGmGmGGSzJroitDiB2yKRq7vqaDSL9taJ5Rs3pXi1bmbDcO8ovqge1iG4nnztNasHmNfC37iF3KH2VZrcwbrHa6yl7Nasf6EONiBCIrQJIe0jGY7ubzquJaI30KnDcifYCwWDVJ8DtgA)ohjyfefcOJTSFcO)y5S1dAShceJuhqrqNakVtfKbrnciEtt20jGuiZzb39oY3nzO97CKGvquiGo2Y(jGZCfQq3dIrQJce0jGo2Y(jGHKpMD6kzKbpT8gbuENkidIAeJuNBqqNakVtfKbrnciEtt20jG4UdJU6x4idbnUPP9FuMiHGEfCmF5fTL0cKfbiJhpiGo2Y(jGuoVUNABtmhhXi1b0e0jGY7ubzquJaI30KnDcifYCwWDVJ8DtgA)ohjyfefidn0GmlPfT16rkqM6qwuuKa6yl7Nasj7jlh5Ztms9ibbDcOJTSFcincGeqgecO8ovqge1igPo3kbDcO8ovqge1iG4nnztNaot(yMEfAp)dYuhY4gCpKHgAqgfYCwWDVJ8DtgA)ohjyfefcOJTSFcOsBz)eJupk3tqNakVtfKbrnciEtt20jGOcYMng5Gm1Hman3dzOHgKH7om6QFb39oY3nzO97CKGvwH2Z)Gm1HmE8aYqjKbeKHki7AKav(JIcYzibrllIIL9xK3PcYaYqdni7AKav(JsTo4wge91HAYBf5DQGmGmusaDSL9taNb5IHxFAeW8nzxeftNtcioM)VeYNhOiEnsGk)rrb5mKGOLfrXY(jgPE0Oe0jGY7ubzquJaI30KnDc4SXihKbaKH9Z0RWlpKPoKnBmYvO9kGmGGSf5LzV8s5AKWSxErl0uYEfb1qsffzazabzMVABDLYk0E(hKPoKXJhqgqqgU7WOR(LzWxPScTN)bzQdz84bKbeKHkiZXwwt0Yl0PCqweGSOqgAObzo2YAIwEHoLdYubzrHmGGmlPfT16rkqweGmuaY4oiJhpGmusaDSL9tanF126keJupkGjOtaL3PcYGOgb0Xw2pbCg8viG4nnztNaoBmYbzaazy)m9k8YdzQdzZgJCfAVcidiiZ8vBRRuquGmGGSf5LzV8s5AKWSxErl0uYEfb1qsffzazabzwslAR1JuGSiazakiJ7GmE8GagYx04bbeWOaXi1JIIe0jGY7ubzquJaI30KnDcOJTSMOLxOt5GmvqwuidiiZ8LxSIL0I2A9ifitDiB2yKdY4eYqfKvZ30PcsHMsVNg3NbzvoKH9Z0RWlpKHsiJ7GmE8Ga6yl7NaYrgc6lwBeJupkGIGobuENkidIAeq8MMSPtaDSL1eT8cDkhKPcYIczabzMV8IvSKw0wRhPazQdzZgJCqgNqgQGSA(Movqk0u6904(miRYHmSFMEfE5HmuczChKXJheqhBz)eq6(57(envAcXi1JIce0jGY7ubzquJaI30KnDcOJTSMOLxOt5GmvqwuidiiZ8LxSIL0I2A9ifitDiB2yKdY4eYqfKvZ30PcsHMsVNg3NbzvoKH9Z0RWlpKHsiJ7GmE8Ga6yl7NaUUI1R(Sn5qigPEuUbbDcO8ovqge1iG4nnztNaA(YlwzKN5pwGSiOcY4geqhBz)eq)ueSP7P2IjAX5dcXigbKQviOtQhLGobuENkidIAeqhBz)eWtwf5n9z5ZtaXBAYMobKczol1sfzpDn5B6Yk0E(hKbeKHkiJczol1sfzpDn5B6Yk0E(hKPoKXJhqgAObzRmx5I5ubbYqjbehhheT5lVyhPEuIrQdyc6eq5DQGmiQraDSL9ta5idbnUPP9FqaXBAYMobC2yKdYaaYW(z6v4LhYuhYMng5k0EfqgqqgfYCwE5YNVQVXpTTUIs(8AxrXx3qUcIcKHgAq2SXihKbaKH9Z0RWlpKPoKnBmYvO9kGmaGSOCpKbeKrHmNLxU85R6B8tBRROKpV2vu81nKRGOazabzuiZz5LlF(Q(g)026kk5ZRDffFDd5kRq75FqM6qgpEqaXXXbrB(Yl2rQhLyK6OibDcOJTSFcihziOVyTraL3PcYGOgXi1bue0jGY7ubzquJaI30KnDc4SXihKbaKH9Z0RWlpKPoKnBmYvO9kGmGGSiczwI5iFEidiiBIec6vWX8Lx0wslqM6qgpEqaDSL9taRMHXmxrt10ueJuhfiOtaL3PcYGOgbeVPjB6eWzJroidaid7NPxHxEitDiB2yKRq7vqaDSL9taNb)5iFE9zBYHqmsDUbbDcOJTSFc4m4XLH(I1gbuENkidIAeJuhqtqNakVtfKbrnciEtt20jGlYlZE5LYl3LpFvFJFABDfL851UIIVUHCfb1qsffzazabzZgJCqM6qwnFtNkifAk9EACFgb8SnXgPEucOJTSFci2dbTJTSFDipJagYZ0VtleW3CIrQhjiOtaL3PcYGOgbeVPjB6eWzJroidaid7NPxHxEitDiB2yKRq7vqaDSL9tahIBX04yohRttmsDUvc6eq5DQGmiQraDSL9taxxX6vF2MCieq8MMSPtaPqMZcU7DKVBYq735ibRGOazabzuiZzb39oY3nzO97CKGvwH2Z)Gm1HSOfuaY4oiJhpiG444GOnF5f7i1Jsms9OCpbDcO8ovqge1iGo2Y(jG09Z39jAQ0eciEtt20jGuiZzb39oY3nzO97CKGvquGmGGmkK5SG7Eh57Mm0(DosWkRq75FqM6qw0ckazChKXJheqCCCq0MV8IDK6rjgPE0Oe0jGo2Y(jGUMgzhYQ7PgVD1JakVtfKbrnIrQhfWe0jGY7ubzquJa6yl7NaUUI1R(Sn5qiG4nnztNasHmNflv09uBXe9Pi(woZXCazQGmuKaIJJdI28LxSJupkXi1JIIe0jGY7ubzquJaI30KnDc4SXihKbaKH9Z0RWlpKPoKnBmYvO9kGmGGSiczwI5iFEidiidvq2eje0RGJ5lVOTKwGm1HmE8aYqdnilIq2OTs1mmM5kAQMMQyjMJ85HmGGmkK5Sq3pF3NONiB8Yk0E(hKfbiBIec6vWX8Lx0wslqwLdzrHmUdY4Xdidn0GSiczJ2kvZWyMROPAAQILyoYNhYacYIiKrHmNf6(57(e9ezJxwH2Z)GmuczOHgKzjTOTwpsbYuhYIgjGmGGSiczJ2kvZWyMROPAAQILyoYNNa6yl7NawndJzUIMQPPigPEuafbDcO8ovqge1iGo2Y(jGCKHGg300(piG444GOnF5f7i1JsaXBAYMobC2yKdYaaYW(z6v4LhYuhYMng5k0EfqgqqgQGSiczlYlZE5LYl3LpFvFJFABDfL851UIIVUHCf5DQGmGm0qdYMng5Gm1HSA(Movqk0u6904(midLeWHC4nvSSFcyKCczXBeiB0FKnilMxtGS6YD5Zx134r(Gm0xxrjFEiRsOO4RBihxq2L0kH4qg2pdY4MZqaYq9MM2)bKLtilEJazv7pYgK11Kf7kqw)qg3ung5GS520q2OZNhYUUazrYjKfVrGSrdzX8AcKvxUlF(Q(gpYhKH(6kk5ZdzvcffFDd5GS4ncKDXAKWaYW(zqg3CgcqgQ300(pGSCczXBKfYMng5GS8Gmkj0vHmlMaz4(miRNqwLe9Z39jqMAPjqwVqg3IRy9czG2MCieJupkkqqNakVtfKbrncOJTSFcihziOXnnT)dcioooiAZxEXos9Oeq8MMSPtaNng5GmaGmSFMEfE5Hm1HSzJrUcTxbKbeKTiVm7LxkVCx(8v9n(PT1vuYNx7kk(6gYvK3PcYaYacYWDhgD1VmxraK5ZRT1vkRq75FqweGmubzZgJCqgNqgQGSA(Movqk0u6904(miRYHmSFMEfE5HmuczChKXJhqgkHmGGmC3Hrx9lMVABDLYk0E(hKfbidvq2SXihKXjKHkiRMVPtfKcnLEpnUpdYQCid7NPxHxEidLqg3bz84bKHsidiidvqweHmZdYBLZejOT1vkY7ubzazOHgKzEqERCMibTTUsrENkididiid3Dy0v)YzIe026kLvO98pilcqgQGSzJroiJtidvqwnFtNkifAk9EACFgKv5qg2ptVcV8qgkHmUdY4XdidLqgkjGd5WBQyz)eqU90Ibz1L7YNVQVXJ8bzOVUIs(8qwLqrXx3qoiR)qCiJBodbid1BAA)hqwoHS4nYcz26khK5Raz9dz4UdJU6ZfK1wmzRMNazN1kqgYLppKXnNHaKH6nnT)dilNqw8gzHmmYUYBq2SXihK50nYBqwEqM8ncFmiZAi7qoZZhYSycK50nYBqwpHmlPfilitdYM9cz(hhY6jKfVrwiZwx5GmRHmCtlqwpNqgU7WOR(eJupk3GGobuENkidIAeq8MMSPtaNng5GmaGmSFMEfE5Hm1HSzJrUcTxbb0Xw2pb8mrcABDfIrQhfqtqNakVtfKbrncOJTSFc4jRI8M(S85jG4nnztNaoARCYQiVPplF(YkZvUyovqGmGGSiczuiZzb39oY3nzO97CKGvquiG444GOnF5f7i1Jsms9Orcc6eqhBz)eWvU(DlFETVBxLakVtfKbrnIrQhLBLGob0Xw2pbSAgg6tj30ocO8ovqge1igPoG5Ec6eq5DQGmiQraXBAYMobmIqgfYCwWDVJ8DtgA)ohjyfefcOJTSFciU7DKVBYq735ibJyK6aokbDcO8ovqge1iG4nnztNasHmNf6(57(e9ezJxquGm0qdYMng5GmaGmhBz)foYqqJBAA)hfSFMEfE5HSiazZgJCfAVcidn0GmkK5SG7Eh57Mm0(DosWkikeqhBz)eq6(57(envAcXi1bmGjOtaL3PcYGOgb0Xw2pbCDfRx9zBYHqaXXXbrB(Yl2rQhLyK6agfjOtaL3PcYGOgbeVPjB6eWrBLQzymZv0unnvzL5kxmNkieqhBz)eWQzymZv0unnfXi1bmGIGobuENkidIAeqhBz)eWtwf5n9z5ZtaXBAYMobKczol1sfzpDn5B6cIcbehhheT5lVyhPEuIrmcioiEnHGoPEuc6eq5DQGmiQraDSL9tapzvK30NLppbeVPjB6eqZdYBLyXhRFAQ0KI8ovqgqgqqgfYCwQLkYE6AY30LvO98pidiiJczol1sfzpDn5B6Yk0E(hKPoKXJheqCCCq0MV8IDK6rjgPoGjOtaDSL9taRMHH(uYnTJakVtfKbrnIrQJIe0jGo2Y(jGRC97w(8AF3UkbuENkidIAeJuhqrqNa6yl7NaI7Eh57Mm0(DosWiGY7ubzquJyK6OabDcO8ovqge1iG4nnztNaorcb9k4y(YlAlPfitDiJhpiGo2Y(jGvZWyMROPAAkIrQZniOtaL3PcYGOgbeVPjB6eWf5LzV8s5L7YNVQVXpTTUIs(8AxrXx3qUIGAiPIImGmGGSzJroitDiRMVPtfKcnLEpnUpJaE2MyJupkb0Xw2pbe7HG2Xw2VoKNrad5z63Pfc4BoXi1b0e0jGo2Y(jG4yohRtFeq5DQGmiQrms9ibbDcO8ovqge1iG4nnztNaoARCXwx5LGMQPPkwI5iFEidiidvq2OTs(MSVh0ubrg5ZxoZXCazQdzagYqdniB0w5ITUYlbnvttvwH2Z)Gm1HmE8aYqjb0Xw2pbKcXWXKnoXi15wjOtaL3PcYGOgbeVPjB6eWrBLl26kVe0unnvXsmh5ZtaDSL9taX(wtigPEuUNGobuENkidIAeq8MMSPtaNng5GmaGmSFMEfE5Hm1HSzJrUcTxbb0Xw2pbCiUftJJ5CSonXi1JgLGobuENkidIAeq8MMSPtaXX8Lxo9CDSL97bilcqgGlOaKbeKH7om6QFPAggZCfnvttvMiHGEfCmF5fTL0cKfbi7uKqqB(Yl2bzCczaMa6yl7NasHy4yYgNyK6rbmbDcO8ovqge1iG4nnztNaoBmYbzaazy)m9k8YdzQdzZgJCfAVccOJTSFc4m4ph5ZRpBtoeIrQhffjOtaL3PcYGOgbeVPjB6eqC3Hrx9lvZWyMROPAAQYeje0RGJ5lVOTKwGSiazNIecAZxEXoiJtidWqgqqM5b5TIhuI5ALvgU1BrENkidcOJTSFci23AcXi1JcOiOtaL3PcYGOgb0Xw2pbKJme04MM2)bbeVPjB6eWzJroidaid7NPxHxEitDiB2yKRq7vazabztKqqVcoMV8I2sAbYuhY4Xdidiidvq2I8YSxEP8YD5Zx134N2wxrjFETRO4RBixrqnKurrgqgqqgU7WOR(L5kcGmFETTUszfAp)dYacYWDhgD1Vy(QT1vkRq75FqgAObzreYwKxM9YlLxUlF(Q(g)026kk5ZRDffFDd5kcQHKkkYaYqjbehhheT5lVyhPEuIrQhffiOtaL3PcYGOgbeVPjB6eWiczJ2kvZWyMROPAAQILyoYNNa6yl7NawndJzUIMQPPigPEuUbbDcO8ovqge1iG4nnztNaIkilIq2lvy6QPMQPPkxS1vEjazOHgKfriZ8G8wPAggZCfD(tKl7ViVtfKbKHsidiid3Dy0v)s1mmM5kAQMMQmrcb9k4y(YlAlPfilcq2PiHG28LxSdY4eYamb0Xw2pbKcXWXKnoXi1JcOjOtaL3PcYGOgbeVPjB6eqC3Hrx9lvZWyMROPAAQYeje0RGJ5lVOTKwGSiazNIecAZxEXoiJtidWeqhBz)eqSV1eIrQhnsqqNa6yl7NaYrgc6lwBeq5DQGmiQrms9OCRe0jGo2Y(jGZGhxg6lwBeq5DQGmiQrmsDaZ9e0jGo2Y(jGUMgzhYQ7PgVD1JakVtfKbrnIrQd4Oe0jGo2Y(jGNjsqBRRqaL3PcYGOgXi1bmGjOtaL3PcYGOgbeVPjB6eWzJroidaid7NPxHxEitDiB2yKRq7vqaDSL9taptKG2wxHyK6agfjOtaL3PcYGOgb0Xw2pb8KvrEtFw(8eq8MMSPtaxzUYfZPccKbeKzEqERel(y9ttLMuK3PcYaYacYmF5fRyjTOTwpsbYIaKfjiG444GOnF5f7i1JsmsDadOiOtaDSL9taX(wtiGY7ubzquJyK6agfiOtaL3PcYGOgb0Xw2pbKJme04MM2)bbeVPjB6eWzJroidaid7NPxHxEitDiB2yKRq7vazabzOcYwKxM9YlLxUlF(Q(g)026kk5ZRDffFDd5kcQHKkkYaYacYWDhgD1VmxraK5ZRT1vkRq75FqgqqgU7WOR(fZxTTUszfAp)dYqdnilIq2I8YSxEP8YD5Zx134N2wxrjFETRO4RBixrqnKurrgqgkjG444GOnF5f7i1JsmsDaZniOtaL3PcYGOgb0Xw2pb8KvrEtFw(8eq8MMSPtaxzUYfZPccbehhheT5lVyhPEuIrQdyanbDcO8ovqge1iGo2Y(jG09Z39jAQ0ecioooiAZxEXos9OeJuhWrcc6eq5DQGmiQraDSL9taxxX6vF2MCieqCCCq0MV8IDK6rjgXigbSMSx2pPoG5EahnAuUpkbSQVF(8hbKBVsWTupswNBdqazqg6XeilPv61GSzVqwKvwb30uUfziBfudjxzazxtlqMJynTBYaYWX8NxUce4inFbYIciGmuV)AYAYaYIS5b5TsLkYqM1qwKnpiVvQuf5DQGmImK5gKXnHkjJuidvrRaLfiWqG52ReCl1JK152aeqgKHEmbYsALEniB2lKf5ZImKTcQHKRmGSRPfiZrSM2nzaz4y(ZlxbcCKMVazrbuacid17VMSMmGmWKg1HSl(BEfqwLbzwdzrkIdzJSwEz)qwRiRB9czOItuczOkAfOSabgcm3ELGBPEKSo3gGaYGm0JjqwsR0RbzZEHSiJhxKHSvqnKCLbKDnTazoI10UjdidhZFE5kqGJ08filk3diGmuV)AYAYaYI81ibQ8hLkvKHmRHSiFnsGk)rPsvK3PcYiYqgQaCfOSabosZxGSOOiGaYq9(RjRjdidmPrDi7I)MxbKvzqM1qwKI4q2iRLx2pK1kY6wVqgQ4eLqgQIwbklqGJ08filkGcqazOE)1K1KbKbM0OoKDXFZRaYQmiZAilsrCiBK1Yl7hYAfzDRxidvCIsidvrRaLfiWrA(cKfffaeqgQ3FnznzazGjnQdzx838kGSkdYSgYIuehYgzT8Y(HSwrw36fYqfNOeYqv0kqzbcmeyU9kb3s9izDUnabKbzOhtGSKwPxdYM9czrMQvImKTcQHKRmGSRPfiZrSM2nzaz4y(ZlxbcCKMVazrbuacid17VMSMmGSiViVm7LxkvQidzwdzrErEz2lVuQuf5DQGmImKHQOvGYce4inFbYIIcacid17VMSMmGmWKg1HSl(BEfqwLbzwdzrkIdzJSwEz)qwRiRB9czOItuczOcfRaLfiWrA(cKfffaeqgQ3Fnznzazr28G8wPsfziZAilYMhK3kvQI8ovqgrgYqfGRaLfiWrA(cKfffaeqgQ3FnznzazrErEz2lVuQurgYSgYI8I8YSxEPuPkY7ubzezidvrRaLfiWqG52ReCl1JK152aeqgKHEmbYsALEniB2lKfzCq8AsKHSvqnKCLbKDnTazoI10UjdidhZFE5kqGJ08filAuabKH69xtwtgqgysJ6q2f)nVciRYGmRHSifXHSrwlVSFiRvK1TEHmuXjkHmufTcuwGahP5lqwuueqazOE)1K1KbKbM0OoKDXFZRaYQmiZAilsrCiBK1Yl7hYAfzDRxidvCIsidvrRaLfiWrA(cKfLBaiGmuV)AYAYaYatAuhYU4V5vazvgKznKfPioKnYA5L9dzTISU1lKHkorjKHQOvGYce4inFbYIcObeqgQ3FnznzazGjnQdzx838kGSkdYSgYIuehYgzT8Y(HSwrw36fYqfNOeYqv0kqzbcme4ijTsVMmGmanK5yl7hYc5zxbcmb8uemPoGrbuGaQS9mdcbSsdzGiBTSMhGmUPrEtwiWvAiRExtOPKfYIIICbzaM7bCuiWqGDSL9FfLvWnnLBaOIZA(Movq46DArfnLEpnUpJRwr1jwo5QMhqevo2Y(l09Z39jAQ0KcUpJRAEar0s4evo2Y(lRRy9QpBtoKcUpJlC)J0Y(vzEqERq3pF3NOPstGa7yl7)kkRGBAk3aqfNhcnD)AfXGa7yl7)kkRGBAk3aqfNuTzbzONbpUmQMpV26kYhcSJTS)ROScUPPCdavCodYfdV(0Ga7yl7)kkRGBAk3aqfNMVABDfUYPQf5LzV8s5AKWSxErl0uYEfb1qsffzab2Xw2)vuwb30uUbGkoptKG2wxbcmeyhBz)haQ4Kgbqcidce4knKXT1qMht8bK5)aYqF9h1qYqcifiRo3KOoKjVqNYXnriRQazJ(JSbzJgYSy5bzZEHmLGhx2dYOeSJCcKLwKhqgLazw3q2P400XHm)hqwvbYW(hzdYwXhzioKH(6pQbzNIGZzIHmkK58kqGDSL9FaOItB9h1qYqciZNxFXAJRCQkIMV8IvYtRe84Ycb2Xw2)bGkororNMqZ170IQk52qEEj3vpKZYp(PXEiWvovrHmNfC37iF3KH2VZrcwbrbn0O67aAM8Xm9k0E(N6Oi3db2Xw2)bGkororNMqFqGR0vAiRsQe84q20X5ZdzXBKfYgncLbziVLbilEJazX8AcKPGyqg3IC97w(8qwLy3UkKn6QpxqwVqwoHmlMaz4UdJU6dz5bzw3qwOFEiZAiBibpoKnDC(8qw8gzHSkPncLvGSi5eY((fiRNqMftobYW9psl7)GmFfiZPccKznKrlgKvnTy5dzwmbYIY9q2j4(hhKfePQhNliZIjq2L0q20XYbzXBKfYQK2iugK5iwt7wI9qiEbcCLUsdzo2Y(pauX5lvNnYp0RCDOMWvovDnsGk)r5LQZg5h6vUoutacvuiZzzLRF3YNx772vlikOHgU7WOR(LvU(DlFETVBxTScTN)fHOCpAOz(YlwXsArBTEKI6r5gOecSJTS)davCI9qq7yl7xhYZ46DArfECqGDSL9FaOItShcAhBz)6qEgxVtlQOAfUoBtSPkkx5uLJTSMOLxOt5uhfbY8G8wHk3XP7PwzL4f5DQGmGa7yl7)aqfNype0o2Y(1H8mUENwuDgxNTj2ufLRCQYXwwt0Yl0PCQJIafrZdYBfQChNUNALvIxK3PcYacSJTS)davCI9qq7yl7xhYZ46DArfoiEnHRZ2eBQIYvov5ylRjA5f6uUiayiWo2Y(pauXPVy)fT17kVbbgcSJTS)Rq1kQozvK30NLppx444GOnF5f7ufLRCQIczol1sfzpDn5B6Yk0E(hqOIczol1sfzpDn5B6Yk0E(N684bAOTYCLlMtfeucb2Xw2)vOAfauXjhziOXnnT)dUWXXbrB(Yl2Pkkx5u1SXihay)m9k8YR(SXixH2RaikK5S8YLpFvFJFABDfL851UIIVUHCfef0qB2yKdaSFMEfE5vF2yKRq7vaquUhikK5S8YLpFvFJFABDfL851UIIVUHCfefGOqMZYlx(8v9n(PT1vuYNx7kk(6gYvwH2Z)uNhpGa7yl7)kuTcaQ4KJme0xS2Ga7yl7)kuTcaQ4SAggZCfnvttXvovnBmYba2ptVcV8QpBmYvO9kakIwI5iFEGMiHGEfCmF5fTL0I684beyhBz)xHQvaqfNZG)CKpV(Sn5q4kNQMng5aa7NPxHxE1Nng5k0EfqGDSL9FfQwbavCodECzOVyTbb2Xw2)vOAfauXj2dbTJTSFDipJR3PfvV5CD2MytvuUYPQf5LzV8s5L7YNVQVXpTTUIs(8AxrXx3qUIGAiPIImaA2yKt9A(Movqk0u6904(miWo2Y(VcvRaGkohIBX04yohRtZvovnBmYba2ptVcV8QpBmYvO9kGa7yl7)kuTcaQ4CDfRx9zBYHWfoooiAZxEXovr5kNQOqMZcU7DKVBYq735ibRGOaefYCwWDVJ8DtgA)ohjyLvO98p1JwqbUJhpGa7yl7)kuTcaQ4KUF(UprtLMWfoooiAZxEXovr5kNQOqMZcU7DKVBYq735ibRGOaefYCwWDVJ8DtgA)ohjyLvO98p1JwqbUJhpGa7yl7)kuTcaQ4010i7qwDp14TREqGDSL9FfQwbavCUUI1R(Sn5q4chhheT5lVyNQOCLtvuiZzXsfDp1wmrFkIVLZCmhQqriWo2Y(VcvRaGkoRMHXmxrt10uCLtvZgJCaG9Z0RWlV6ZgJCfAVcGIOLyoYNhiunrcb9k4y(YlAlPf15Xd0qlIJ2kvZWyMROPAAQILyoYNhikK5Sq3pF3NONiB8Yk0E(xeMiHGEfCmF5fTL0sLhL74Xd0qlIJ2kvZWyMROPAAQILyoYNhOisHmNf6(57(e9ezJxwH2Z)qjAOzjTOTwpsr9OrcGI4OTs1mmM5kAQMMQyjMJ85HaxPHSi5eYI3iq2O)iBqwmVMaz1L7YNVQVXJ8bzOVUIs(8qwLqrXx3qoUGSlPvcXHmSFgKXnNHaKH6nnT)dilNqw8gbYQ2FKniRRjl2vGS(HmUPAmYbzZTPHSrNppKDDbYIKtilEJazJgYI51eiRUCx(8v9nEKpid91vuYNhYQekk(6gYbzXBei7I1iHbKH9ZGmU5meGmuVPP9Faz5eYI3ilKnBmYbz5bzusORczwmbYW9zqwpHSkj6NV7tGm1stGSEHmUfxX6fYaTn5qGa7yl7)kuTcaQ4KJme04MM2)bx444GOnF5f7ufLRCQA2yKdaSFMEfE5vF2yKRq7vaeQI4I8YSxEP8YD5Zx134N2wxrjFETRO4RBihAOnBmYPEnFtNkifAk9EACFgkHaxPHmU90Ibz1L7YNVQVXJ8bzOVUIs(8qwLqrXx3qoiR)qCiJBodbid1BAA)hqwoHS4nYcz26khK5Raz9dz4UdJU6ZfK1wmzRMNazN1kqgYLppKXnNHaKH6nnT)dilNqw8gzHmmYUYBq2SXihK50nYBqwEqM8ncFmiZAi7qoZZhYSycK50nYBqwpHmlPfilitdYM9cz(hhY6jKfVrwiZwx5GmRHmCtlqwpNqgU7WOR(qGDSL9FfQwbavCYrgcACtt7)GlCCCq0MV8IDQIYvovnBmYba2ptVcV8QpBmYvO9kaArEz2lVuE5U85R6B8tBRROKpV2vu81nKdiC3Hrx9lZveaz(8ABDLYk0E(xeq1SXixLHQA(Movqk0u6904(Skh7NPxHxEuYD84bkbc3Dy0v)I5R2wxPScTN)fbunBmYvzOQMVPtfKcnLEpnUpRYX(z6v4LhLChpEGsGqvenpiVvotKG2wxbn0mpiVvotKG2wxbiC3Hrx9lNjsqBRRuwH2Z)IaQMng5QmuvZ30PcsHMsVNg3Nv5y)m9k8YJsUJhpqjkHa7yl7)kuTcaQ48mrcABDfUYPQzJroaW(z6v4Lx9zJrUcTxbeyhBz)xHQvaqfNNSkYB6ZYNNlCCCq0MV8IDQIYvovnARCYQiVPplF(YkZvUyovqakIuiZzb39oY3nzO97CKGvquGa7yl7)kuTcaQ4CLRF3YNx772vHa7yl7)kuTcaQ4SAgg6tj30oiWo2Y(VcvRaGkoXDVJ8DtgA)ohjyCLtvrKczol4U3r(UjdTFNJeScIceyhBz)xHQvaqfN09Z39jAQ0eUYPkkK5Sq3pF3NONiB8cIcAOnBmYbGJTS)chziOXnnT)Jc2ptVcV8ry2yKRq7vGgAuiZzb39oY3nzO97CKGvquGa7yl7)kuTcaQ4CDfRx9zBYHWfoooiAZxEXovrHa7yl7)kuTcaQ4SAggZCfnvttXvovnARundJzUIMQPPkRmx5I5ubbcSJTS)Rq1kaOIZtwf5n9z5ZZfoooiAZxEXovr5kNQOqMZsTur2txt(MUGOabgcSJTS)RGhNQy(Q09ZvovzEqERyYsF6EQLN35fA5TI8ovqganBmYP(SXixH2RacSJTS)RGhhaQ4Kk09qpr24CLtvuiZzb39oY3nzO97CKGvquGa7yl7)k4XbGko9hlNTEqJ9qGRCQIczol4U3r(UjdTFNJeScIceyhBz)xbpoauX5mxHk09GRCQIczol4U3r(UjdTFNJeScIceyhBz)xbpoauXzi5JzNUsgzWtlVbb2Xw2)vWJdavCs586EQTnXCCCLtv4UdJU6x4idbnUPP9FuMiHGEfCmF5fTL0se4XdiWo2Y(VcECaOItkzpz5iFEUYPkkK5SG7Eh57Mm0(DosWkikOHML0I2A9if1JIIqGDSL9Ff84aqfN0iasazqGa7yl7)k4XbGkovAl7NRCQAM8Xm9k0E(N6CdUhn0OqMZcU7DKVBYq735ibRGOab2Xw2)vWJdavCodYfdV(04kFt2frX05ufoM)VeYNhOiEnsGk)rrb5mKGOLfrXY(5kNQq1SXiN6aAUhn0WDhgD1VG7Eh57Mm0(DosWkRq75FQZJhOeiuDnsGk)rrb5mKGOLfrXY(rdTRrcu5pk16GBzq0xhQjVHsiWo2Y(VcECaOItZxTTUcx5u1SXihay)m9k8YR(SXixH2RaOf5LzV8s5AKWSxErl0uYEfb1qsffzaK5R2wxPScTN)PopEaeU7WOR(LzWxPScTN)PopEaeQCSL1eT8cDkxeIIgAo2YAIwEHoLtvuGSKw0wRhPebuG74Xducb2Xw2)vWJdavCod(kCfYx04HkaJcCLtvZgJCaG9Z0RWlV6ZgJCfAVcGmF126kfefGwKxM9YlLRrcZE5fTqtj7veudjvuKbqwslAR1JuIaGI74XdiWo2Y(VcECaOItoYqqFXAJRCQYXwwt0Yl0PCQIcK5lVyflPfT16rkQpBmYvzOQMVPtfKcnLEpnUpRYX(z6v4LhLChpEab2Xw2)vWJdavCs3pF3NOPst4kNQCSL1eT8cDkNQOaz(YlwXsArBTEKI6ZgJCvgQQ5B6ubPqtP3tJ7ZQCSFMEfE5rj3XJhqGDSL9Ff84aqfNRRy9QpBtoeUYPkhBznrlVqNYPkkqMV8IvSKw0wRhPO(SXixLHQA(Movqk0u6904(Skh7NPxHxEuYD84beyhBz)xbpoauXPFkc209uBXeT48bHRCQY8LxSYipZFSebvCdiWqGDSL9FfCq8AIQtwf5n9z5ZZfoooiAZxEXovr5kNQmpiVvIfFS(PPstkY7ubzaefYCwQLkYE6AY30LvO98pGOqMZsTur2txt(MUScTN)PopEab2Xw2)vWbXRjaOIZQzyOpLCt7Ga7yl7)k4G41eauX5kx)ULpV23TRcb2Xw2)vWbXRjaOItC37iF3KH2VZrcgeyhBz)xbheVMaGkoRMHXmxrt10uCLtvtKqqVcoMV8I2sArDE8acSJTS)RGdIxtaqfNype0o2Y(1H8mUENwu9MZ1zBInvr5kNQwKxM9YlLxUlF(Q(g)026kk5ZRDffFDd5kcQHKkkYaOzJro1R5B6ubPqtP3tJ7ZGa7yl7)k4G41eauXjoMZX60heyhBz)xbheVMaGkoPqmCmzJZvovnARCXwx5LGMQPPkwI5iFEGq1OTs(MSVh0ubrg5ZxoZXCOoGrdTrBLl26kVe0unnvzfAp)tDE8aLqGDSL9FfCq8AcaQ4e7BnHRCQA0w5ITUYlbnvttvSeZr(8qGDSL9FfCq8AcaQ4CiUftJJ5CSonx5u1SXihay)m9k8YR(SXixH2RacSJTS)RGdIxtaqfNuigoMSX5kNQWX8Lxo9CDSL97Hia4ckaeU7WOR(LQzymZv0unnvzIec6vWX8Lx0wslr4uKqqB(Yl2vzagcSJTS)RGdIxtaqfNZG)CKpV(Sn5q4kNQMng5aa7NPxHxE1Nng5k0EfqGDSL9FfCq8AcaQ4e7BnHRCQc3Dy0v)s1mmM5kAQMMQmrcb9k4y(YlAlPLiCksiOnF5f7QmadK5b5TIhuI5ALvgU1BrENkidiWo2Y(VcoiEnbavCYrgcACtt7)GlCCCq0MV8IDQIYvovnBmYba2ptVcV8QpBmYvO9kaAIec6vWX8Lx0wslQZJhaHQf5LzV8s5L7YNVQVXpTTUIs(8AxrXx3qUIGAiPIImac3Dy0v)YCfbqMpV2wxPScTN)beU7WOR(fZxTTUszfAp)dn0I4I8YSxEP8YD5Zx134N2wxrjFETRO4RBixrqnKurrgOecSJTS)RGdIxtaqfNvZWyMROPAAkUYPQioARundJzUIMQPPkwI5iFEiWo2Y(VcoiEnbavCsHy4yYgNRCQcvr8LkmD1ut10uLl26kVeqdTiAEqERundJzUIo)jYL9xK3PcYaLaH7om6QFPAggZCfnvttvMiHGEfCmF5fTL0seofje0MV8IDvgGHa7yl7)k4G41eauXj23Acx5ufU7WOR(LQzymZv0unnvzIec6vWX8Lx0wslr4uKqqB(Yl2vzagcSJTS)RGdIxtaqfNCKHG(I1geyhBz)xbheVMaGkoNbpUm0xS2Ga7yl7)k4G41eauXPRPr2HS6EQXBx9Ga7yl7)k4G41eauX5zIe026kqGDSL9FfCq8AcaQ48mrcABDfUYPQzJroaW(z6v4Lx9zJrUcTxbeyhBz)xbheVMaGkopzvK30NLppx444GOnF5f7ufLRCQAL5kxmNkiazEqERel(y9ttLMuK3PcYaiZxEXkwslAR1JuIqKacSJTS)RGdIxtaqfNyFRjqGDSL9FfCq8AcaQ4KJme04MM2)bx444GOnF5f7ufLRCQA2yKdaSFMEfE5vF2yKRq7vaeQwKxM9YlLxUlF(Q(g)026kk5ZRDffFDd5kcQHKkkYaiC3Hrx9lZveaz(8ABDLYk0E(hq4UdJU6xmF126kLvO98p0qlIlYlZE5LYl3LpFvFJFABDfL851UIIVUHCfb1qsffzGsiWo2Y(VcoiEnbavCEYQiVPplFEUWXXbrB(Yl2Pkkx5u1kZvUyovqGa7yl7)k4G41eauXjD)8DFIMknHlCCCq0MV8IDQIcb2Xw2)vWbXRjaOIZ1vSE1NTjhcx444GOnF5f7uffcmeyhBz)x5nx1zIe026kqGDSL9FL3CauX5CfbqMpV2wxHRCQkIuiZzPAgg6tj30UYk0E(hAOrHmNLQzyOpLCt7kRq75FaH7om6QFHJme04MM2)rzfAp)dcSJTS)R8MdGkonF126kCLtvrKczolvZWqFk5M2vwH2Z)qdnkK5Sundd9PKBAxzfAp)diC3Hrx9lCKHGg300(pkRq75FqGHa7yl7)kNPAiUftJJ5CSonx5u1SXihay)m9k8YR(SXixH2RacSJTS)RCgaQ48KvrEtFw(8CHJJdI28LxStvuUYPQioARCYQiVPplF(ILyoYNhiZxEXkwslAR1JuIaGgn0OqMZsTur2txt(MUGOaefYCwQLkYE6AY30LvO98p15XdiWo2Y(VYzaOIZzWJld9fRniWo2Y(VYzaOIZvU(DlFETVBxfcSJTS)RCgaQ4SAgg6tj30oiWo2Y(VYzaOItC37iF3KH2VZrcgeyhBz)x5mauXjhziOVyTbb2Xw2)vodavCod(Zr(86Z2KdHRCQA2yKdaSFMEfE5vF2yKRq7vab2Xw2)vodavC6AAKDiRUNA82vpiWo2Y(VYzaOIZQzymZv0unnfx5u1eje0RGJ5lVOTKwuNhpqdTzJroaW(z6v4Lx9zJrUcTxbqO6LkmD1ut10uLADWTmianARCYQiVPplF(ILyoYNhOrBLtwf5n9z5ZxwzUYfZPccAO9sfMUAQPAAQIsmzB6(fGIifYCwO7NV7t0tKnEbrbOzJroaW(z6v4Lx9zJrUcTxrL7yl7VWrgcACtt7)OG9Z0RWlp3HIOen0SKw0wRhPOEuUhcSJTS)RCgaQ4e7BnHRCQYXwwt0Yl0PCrikqrCrEz2lVu24bNJZ8ahYEAC)Zg5h5ZRpBtoKRiOgsQOidiWo2Y(VYzaOItkedht24CLtvo2YAIwEHoLlcrbkIlYlZE5LYgp4CCMh4q2tJ7F2i)iFE9zBYHCfb1qsffzaeU7WOR(LQzymZv0unnvzIec6vWX8Lx0wslr4uKqqB(Yl2beQWX8Lxo9CDSL97Hia4ckGgAJ2kxS1vEjOPAAQILyoYNhLqGDSL9FLZaqfNNjsqBRRWvovnBmYba2ptVcV8QpBmYvO9kGa7yl7)kNbGkoP7NV7t0uPjCHJJdI28LxStvuUYPkZdYBfpOeZ1kRmCR3I8ovqgaHkkK5Sq3pF3NONiB8cIcquiZzHUF(Uprpr24LvO98p1Nng5QmuvZ30PcsHMsVNg3Nv5y)m9k8YJsUJhpakIuiZzPAgg6tj30UYk0E(hAOrHmNf6(57(e9ezJxwH2Z)a6LkmD1ut10ufLyY209lOecSJTS)RCgaQ4KJme04MM2)bx444GOnF5f7ufLRCQAIec6vWX8Lx0wslQZJhanBmYba2ptVcV8QpBmYvO9kGa7yl7)kNbGkoxxX6vF2MCiCHJJdI28LxStvuUYPkkK5SyPIUNAlMOpfX3YzoMdvOiAOnARCXwx5LGMQPPkwI5iFEiWo2Y(VYzaOIt6(57(envAcx5u1OTYfBDLxcAQMMQyjMJ85Ha7yl7)kNbGkopzvK30NLppx444GOnF5f7ufLRCQAL5kxmNkiaz(YlwXsArBTEKsea0OHgfYCwQLkYE6AY30fefiWo2Y(VYzaOIZQzymZv0unnfx5u1lvy6QPMQPPkxS1vEja0SXixeQ5B6ubPqtP3tJ7Z4oad0OTYjRI8M(S85lRq75Fraf4oE8acSJTS)RCgaQ4ehZ5yD6dcSJTS)RCgaQ4KJme04MM2)bx444GOnF5f7ufLRCQA2yKdaSFMEfE5vF2yKRq7vab2Xw2)vodavCwndJzUIMQPP4kNQwKxM9YlLnEW54mpWHSNg3)Sr(r(86Z2Kd5kcQHKkkYacSJTS)RCgaQ4KUF(UprtLMWfoooiAZxEXovr5kNQOqMZcD)8DFIEISXlikOH2SXihao2Y(lCKHGg300(pky)m9k8YhHzJrUcTxrLhffqdTrBLl26kVe0unnvXsmh5ZJgAuiZzPAgg6tj30UYk0E(heyhBz)x5mauX56kwV6Z2KdHlCCCq0MV8IDQIcb2Xw2)vodavCwndJzUIMQPP4kNQEPctxn1unnvPwhCldcqJ2kNSkYB6ZYNVyjMJ85rdTxQW0vtnvttvuIjBt3VGgAVuHPRMAQMMQCXwx5LaqZgJCraf4EIrmcba]] )


end