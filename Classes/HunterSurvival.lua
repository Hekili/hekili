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
            state:QueueAuraExpiration( "nesingwarys_apparatus", ExpireCelestialAlignment, buff.nesingwarys_apparatus.expires )
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
            cooldown = 18,
            recharge = 18,
            gcd = "spell",

            startsCombat = true,
            texture = 2065635,

            bind = "wildfire_bomb",
            talent = "wildfire_infusion",

            usable = function () return current_wildfire_bomb == "pheromone_bomb" end,
            handler = function ()
                applyDebuff( "target", "pheromone_bomb" )
                current_wildfire_bomb = "wildfire_bomb"
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
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 2065637,

            bind = "wildfire_bomb",

            usable = function () return current_wildfire_bomb == "shrapnel_bomb" end,
            handler = function ()
                applyDebuff( "target", "shrapnel_bomb" )
                current_wildfire_bomb = "wildfire_bomb"
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
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 2065636,

            bind = "wildfire_bomb",

            usable = function () return current_wildfire_bomb == "volatile_bomb" end,
            handler = function ()
                if debuff.serpent_sting.up then applyDebuff( "target", "serpent_sting" ) end
                current_wildfire_bomb = "wildfire_bomb"
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
            cooldown = 18,
            recharge = 18,
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

            usable = function () return current_wildfire_bomb ~= "pheromone_bomb" or debuff.serpent_sting.up end,
            handler = function ()
                if current_wildfire_bomb ~= "wildfire_bomb" then
                    runHandler( current_wildfire_bomb )
                    current_wildfire_bomb = "wildfire_bomb"
                    return
                end
                applyDebuff( "target", "wildfire_bomb_dot" )
                removeBuff( "flame_infusion" )
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


    spec:RegisterPack( "Survival", 20210701, [[d8uYLbqisKEKKQKljPcBsr5tcrnkiOtbbwfjcVsrAwOuDljvYUK4xOugMqvDmjPLbH8musAAsQORjPQ2Mqv6BqOyCKiY5eIG1jPs9oseLAEcH7rc7dLuhuOkSqsupecvtusvkUOKQuYgjru0hfIqJKerjNuiIwPIQxcHsMPqKUjjIc7ur8tjvPudvsvQSuiuQNcQPIs8vsevJvOkAVi(lPgmshMQfJkpgQjRWLj2miFgvnAjXPfTAjvPQxdrnBb3gf7wPFl1WjPJJsILRYZv10PCDiTDjLVlKgVqLZluwVKQy(qK9dmPkHfc8WnHmbrXhrvJpIj(vlXxjHO6S(igcSftviWQogzNxiWRZieyy0RwwZdeyvpwO9bHfc83OhwiW1laTIzQFDZgB8PvbLRGBg2(Kbn4w2l(CiJTpzWSrG5qZGfjxchbE4MqMGO4JOQXhXe)QL4RKquDwFcSJAv6JadNmiobUsogYs4iWd5Xeyy0RwwZdaQswORjhy(C0qmaTk7akIIpIQsGd5BpHfc8AoHfYKQewiWo2YEjWVjsqBNRsGL15cYGOmXitqeHfcSSoxqgeLjW4ln5sNaRuaLdfcQendd9RMxAF5egp3hqrcjaLdfcQendd9RMxAF5egp3hqNbO4UdJo6wqodbnUzy8DuoHXZ9jWo2YEjWqNi1tU8A7CvIrMWQewiWY6CbzquMaJV0KlDcSsbuouiOs0mm0VAEP9Lty8CFafjKauouiOs0mm0VAEP9Lty8CFaDgGI7om6OBb5me04MHX3r5egp3Na7yl7LaB(PTZvjgXiWdbYrdgHfYKQewiWo2YEjWmO1t9eecSSoxqgeLjgzcIiSqGL15cYGOmb2Xw2lb2oFzf0mK1tU86VsBe4H84lvTSxcCKydOEfXhaQVdaLLZxwbndz9ia6K6DioGkRWKYZoGgva0rVr2a0rdOwL8buO(au1GhtUhq5eSJ(cGMwKhakNaOw3a6R6mmXauFhaAubqX(gzdqpXhzigGYY5lRaOVQGtOedOCOqqFHaJV0KlDcSsbuZpEXk5RvdEm5igzcRsyHa7yl7LaJ(IonH5jWY6CbzquMyKj1jHfcSSoxqgeLjWo2YEjWype0o2YE1H8ncCiFtVoJqGXJNyKj1NWcbwwNlidIYey8LMCPtGDSL1eTSctkpGgbGYQa6ma18GSwHlVXRBiT6jXkY6CbzqGDSL9sGXEiODSL9Qd5Be4q(MEDgHaZ1QeJmjEjSqGL15cYGOmbgFPjx6eyhBznrlRWKYdOraOSkGodqvkGAEqwRWL341nKw9KyfzDUGmiWo2YEjWype0o2YE1H8ncCiFtVoJqGFJyKjigcleyzDUGmiktGXxAYLob2Xwwt0YkmP8akRbuerGDSL9sGXEiODSL9Qd5Be4q(MEDgHaJdIxtigzIsIWcb2Xw2lb2pSVI267K1iWY6CbzquMyeJaREcUz4CJWczsvcleyzDUGmiktGBvc8lwcrGXxAYLob28GSwHPx(UFrZLMuK15cYGapKhFPQL9sGNJgIbOvzhqru8ruvcCn)0RZieygo99AC)gb2Xw2lbUMFPZfecCnpGkAj8cb2Xw2B5CvRp9BxISuW9Be4AEaviWo2YElm9Y39lAU0KcUFJyKjiIWcb2Xw2lb(rzy6vRkgbwwNlidIYeJmHvjSqGDSL9sG5AZcYqdf8yYiAU8ARJlxcSSoxqgeLjgzsDsyHa7yl7LadfKVc(CiJalRZfKbrzIrMuFcleyzDUGmiktGXxAYLob(qxbQpEP8nAaQpErlmCY9fHvqtvvzqGDSL9sGn)025QeJmjEjSqGDSL9sGFtKG2oxLalRZfKbrzIrmcmxRsyHmPkHfcSSoxqgeLjWo2YEjWVCQYA63YLNaJV0KlDcmhkeuPwQk3RRjBZuoHXZ9b0zakcbuouiOsTuvUxxt2MPCcJN7dOraO84bGIesa6jqN8vCUGaOiGaJJHdI28JxSNmPkXitqeHfcSSoxqgeLjWo2YEjWiNHGg3mm(oiW4ln5sNad1y0hqNcOy)n9j8YcOraOqng9lmECa6maLdfcQSYNlFu)I9A7Cv1C51UQQFUH(fuvafjKauOgJ(a6uaf7VPpHxwancafQXOFHXJdqNcOvJpGodq5qHGkR85Yh1VyV2oxvnxETRQ6NBOFbvfqNbOCOqqLv(C5J6xSxBNRQMlV2vv9Zn0VCcJN7dOraO84bbghdheT5hVypzsvIrMWQewiWo2YEjWiNHG(R0gbwwNlidIYeJmPojSqGL15cYGOmbgFPjx6eyOgJ(a6uaf7VPpHxwancafQXOFHXJdqNbOkfqTeJCU8a6mafcne0NGR4hVOTKra0iauE8Ga7yl7LahnddO8enxZWrmYK6tyHalRZfKbrzcm(stU0jWqng9b0Pak2FtFcVSaAeakuJr)cJhhb2Xw2lbgk4lY5YRF7sKfIrMeVewiWo2YEjWqbpMm0FL2iWY6CbzquMyKjigcleyzDUGmiktGXxAYLob(qxbQpEPSY)5Yh1VyV2oxvnxETRQ6NBOFryf0uvvga6mafQXOpGgbGwZV05csHHtFVg3VrGDSL9sGXEiODSL9Qd5Be4q(MEDgHaVMtmYeLeHfcSSoxqgeLjW4ln5sNad1y0hqNcOy)n9j8YcOraOqng9lmECeyhBzVe4H4wfnUIJ85meJmjsGWcbwwNlidIYeyhBzVe4ZvT(0VDjYcbgFPjx6eyouiOcU7BKRBYq7)7ObRGQcOZauouiOcU7BKRBYq7)7ObRCcJN7dOraOvl1hqvcaLhpiW4y4GOn)4f7jtQsmYKQXNWcbwwNlidIYeyhBzVeyME57(fnxAcbgFPjx6eyouiOcU7BKRBYq7)7ObRGQcOZauouiOcU7BKRBYq7)7ObRCcJN7dOraOvl1hqvcaLhpiW4y4GOn)4f7jtQsmYKQvjSqGDSL9sGDnd6nKt3qA81rFcSSoxqgeLjgzsveryHalRZfKbrzcSJTSxc85QwF63UezHaJV0KlDcmhkeuXsvDdPTkI(vf)kV5yKbufakRsGXXWbrB(Xl2tMuLyKjvzvcleyzDUGmiktGXxAYLobgQXOpGofqX(B6t4LfqJaqHAm6xy84a0zaQsbulXiNlpGodqriGcHgc6tWv8Jx0wYiaAeakpEaOiHeGQuaD0wjAggq5jAUMHRyjg5C5b0zakhkeuHPx(UFrdHEXkNW45(akRbui0qqFcUIF8I2sgbqRlaTkGQeakpEaOiHeGQuaD0wjAggq5jAUMHRyjg5C5b0zaQsbuouiOctV8D)Igc9IvoHXZ9bueaOiHeGAjJOTwpsbqJaqRQKa0zaQsb0rBLOzyaLNO5AgUILyKZLNa7yl7LahnddO8enxZWrmYKQ1jHfcSSoxqgeLjWo2YEjWiNHGg3mm(oiW4y4GOn)4f7jtQsGXxAYLobgQXOpGofqX(B6t4LfqJaqHAm6xy84a0zakcbuLcOh6kq9XlLv(px(O(f7125QQ5YRDvv)Cd9lY6CbzaOiHeGc1y0hqJaqR5x6CbPWWPVxJ73aueqGhYJVu1YEjWrsianwJcOJEJSbOv8AcGor(px(O(flYpGYY5QQ5YdOXdvv)Cd9zhq)KrnedqX(BakIvgcakI3mm(oa0ecqJ1OaA0EJSbODn5WUkG2lGQKzJrFaf6AgaD05YdOFxa0ijeGgRrb0rdOv8AcGor(px(O(flYpGYY5QQ5YdOXdvv)Cd9b0ynkG(vA0WaqX(BakIvgcakI3mm(oa0ecqJ1OhGc1y0hqZhq5KqhfqTkcGI73a0gcqvYOx(UFbqvonbq7dqrSDvRpaf2UezHyKjvRpHfcSSoxqgeLjWo2YEjWiNHGg3mm(oiW4y4GOn)4f7jtQsGXxAYLobgQXOpGofqX(B6t4LfqJaqHAm6xy84a0za6HUcuF8szL)ZLpQFXETDUQAU8Axv1p3q)ISoxqga6maf3Dy0r3c0js9KlV2oxTCcJN7dOSgqriGc1y0hqzdqriGwZV05csHHtFVg3VbO1fGI930NWllGIaavjauE8aqraGodqXDhgD0Ty(PTZvlNW45(akRbuecOqng9bu2auecO18lDUGuy403RX9BaADbOy)n9j8YcOiaqvcaLhpaueaOZauecOkfqnpiRvEtKG2oxTiRZfKbGIesaQ5bzTYBIe025QfzDUGma0zakU7WOJUL3ejOTZvlNW45(akRbuecOqng9bu2auecO18lDUGuy403RX9BaADbOy)n9j8YcOiaqvcaLhpaueaOiGapKhFPQL9sGvYtRcGor(px(O(flYpGYY5QQ5YdOXdvv)Cd9b0EdXaueRmeaueVzy8DaOjeGgRrpa1ox9bu)eaTxaf3Dy0rx2b02Qix08fa9Twfqr)C5bueRmeaueVzy8DaOjeGgRrpafJENSgGc1y0hqDMgDnanFav2gLVcGAnG(OV55cOwfbqDMgDnaTHaulzeaniqgGc1hG6BmaTHa0yn6bO25QpGAnGIBgbqBiiaf3Dy0rxIrMunEjSqGL15cYGOmbgFPjx6eyOgJ(a6uaf7VPpHxwancafQXOFHXJJa7yl7La)MibTDUkXitQIyiSqGL15cYGOmb2Xw2lb(Ltvwt)wU8ey8LMCPtGhTvE5uL10VLlF5eOt(koxqa0zaQsbuouiOcU7BKRBYq7)7ObRGQsGXXWbrB(Xl2tMuLyKjvvsewiWo2YEjWN896wU8A)UokbwwNlidIYeJmPAKaHfcSJTSxcC0mm0VAEP9eyzDUGmiktmYeefFcleyzDUGmiktGXxAYLobwPakhkeub39nY1nzO9)D0GvqvjWo2YEjW4UVrUUjdT)VJgmIrMGOQewiWY6CbzquMaJV0KlDcmhkeuHPx(UFrdHEXkOQaksibOqng9b0PaQJTS3cYziOXndJVJc2FtFcVSakRbuOgJ(fgpoafjKauouiOcU7BKRBYq7)7ObRGQsGDSL9sGz6LV7x0CPjeJmbriIWcbwwNlidIYeyhBzVe4ZvT(0VDjYcbghdheT5hVypzsvIrMGiwLWcbwwNlidIYey8LMCPtGhTvIMHbuEIMRz4kNaDYxX5ccb2Xw2lboAggq5jAUMHJyKjiQojSqGL15cYGOmb2Xw2lb(Ltvwt)wU8ey8LMCPtG5qHGk1sv5EDnzBMcQkbghdheT5hVypzsvIrmcmE8ewitQsyHalRZfKbrzcm(stU0jWMhK1kMCmVUH0YY78cJSwrwNlidaDgGc1y0hqJaqHAm6xy84iWo2YEjWv8tT7LyKjiIWcbwwNlidIYeyhBzVe4Xj(akprxt(xcey8LMCPtGXDnz91kih7sFb0zakU7WOJULt(EDlxETFxhTCcJN7dOSgqRgFafjKauLcO4UMS(AfKJDPVe41zec84eFaLNORj)lbIrMWQewiWY6CbzquMaJV0KlDcmU7WOJUfC33ix3KH2)3rdw5egp3hqznGYQXNa7yl7LaZf6EOHqVyeJmPojSqGL15cYGOmbgFPjx6eyC3HrhDl4UVrUUjdT)VJgSYjmEUpGYAaLvJpb2Xw2lb2xS825bn2dbIrMuFcleyzDUGmiktGXxAYLobg3Dy0r3cU7BKRBYq7)7ObRCcJN7dOSgqz14tGDSL9sGHYt4cDpigzs8syHa7yl7Lahs(k2RR3Jo4zK1iWY6CbzquMyKjigcleyzDUGmiktGXxAYLobg3Dy0r3cYziOXndJVJceAiOpbxXpErBjJaOSgq5XdcSJTSxcmNZRBiTDjg5NyKjkjcleyzDUGmiktGXxAYLobg3Dy0r3cU7BKRBYq7)7ObRCcJN7dOSgqJ34dOiHeGAjJOTwpsbqJaqRYQeyhBzVeyo5E5qoxEIrMejqyHa7yl7LaZGwp1tqiWY6CbzquMyKjvJpHfcSSoxqgeLjW4ln5sNadL8vm9jmEUpGgbGgVXhqrcjaLdfcQG7(g56Mm0()oAWkOQeyhBzVey12YEjgzs1QewiWY6CbzquMaJV0KlDcmcbuOgJ(aAeakIj(aksibO4UdJo6wWDFJCDtgA)FhnyLty8CFancaLhpaueaOZauecOFJg4YDuurFdniA5qvTS3ISoxqgaksibOFJg4YDuQ1b3YGO)outwRiRZfKbGIacSJTSxcmuq(k4ZHmcCUMChQQPticmUIVReYLFMs)gnWL7OOI(gAq0YHQAzVeJmPkIiSqGL15cYGOmbgFPjx6eyOgJ(a6uaf7VPpHxwancafQXOFHXJdqNbOh6kq9XlLVrdq9XlAHHtUViScAQQkdaDgGA(PTZvlNW45(aAeakpEaOZauC3HrhDlqb)KYjmEUpGgbGYJha6mafHaQJTSMOLvys5buwdOvbuKqcqDSL1eTSctkpGQaqRcOZaulzeT16rkakRb06dOkbGYJhakciWo2YEjWMFA7CvIrMuLvjSqGL15cYGOmb2Xw2lbgk4NqGXxAYLobgQXOpGofqX(B6t4LfqJaqHAm6xy84a0zaQ5N2oxTGQcOZa0dDfO(4LY3ObO(4fTWWj3xewbnvvLbGodqTKr0wRhPaOSgqRtavjauE8GahYv04bbgr1NyKjvRtcleyzDUGmiktGXxAYLob2Xwwt0YkmP8aQcaTkGodqn)4fRyjJOTwpsbqJaqHAm6dOSbOieqR5x6CbPWWPVxJ73a06cqX(B6t4LfqraGQeakpEqGDSL9sGrodb9xPnIrMuT(ewiWY6CbzquMaJV0KlDcSJTSMOLvys5bufaAvaDgGA(XlwXsgrBTEKcGgbGc1y0hqzdqriGwZV05csHHtFVg3VbO1fGI930NWllGIaavjauE8Ga7yl7LaZ0lF3VO5stigzs14LWcbwwNlidIYey8LMCPtGDSL1eTSctkpGQaqRcOZauZpEXkwYiAR1Jua0iauOgJ(akBakcb0A(LoxqkmC6714(naTUauS)M(eEzbueaOkbGYJheyhBzVe4ZvT(0VDjYcXitQIyiSqGL15cYGOmbgFPjx6eyZpEXkJ8nFXcGYAfaA8sGDSL9sG9xvWMUH0wfrloFqigXiWVryHmPkHfcSSoxqgeLjW4ln5sNad1y0hqNcOy)n9j8YcOraOqng9lmECeyhBzVe4H4wfnUIJ85meJmbrewiWY6CbzquMa7yl7La)YPkRPFlxEcm(stU0jWkfqhTvE5uL10VLlFXsmY5YdOZauZpEXkwYiAR1JuauwdOigafjKauouiOsTuvUxxt2MPGQcOZauouiOsTuvUxxt2MPCcJN7dOraO84bbghdheT5hVypzsvIrMWQewiWo2YEjWqbpMm0FL2iWY6CbzquMyKj1jHfcSJTSxc8jFVULlV2VRJsGL15cYGOmXitQpHfcSJTSxcC0mm0VAEP9eyzDUGmiktmYK4LWcb2Xw2lbg39nY1nzO9)D0GrGL15cYGOmXitqmewiWo2YEjWiNHG(R0gbwwNlidIYeJmrjryHalRZfKbrzcm(stU0jWqng9b0Pak2FtFcVSaAeakuJr)cJhhb2Xw2lbgk4lY5YRF7sKfIrMejqyHa7yl7La7Ag0BiNUH04RJ(eyzDUGmiktmYKQXNWcbwwNlidIYey8LMCPtGHqdb9j4k(XlAlzeancaLhpauKqcqHAm6dOtbuS)M(eEzb0iauOgJ(fgpoaDgGIqaDL4mD0uZ1mCLADWTmia6maD0w5Ltvwt)wU8flXiNlpGodqhTvE5uL10VLlF5eOt(koxqauKqcqxjothn1CndxrTICntVcGodqvkGYHcbvy6LV7x0qOxScQkGodqHAm6dOtbuS)M(eEzb0iauOgJ(fgpoaTUauhBzVfKZqqJBggFhfS)M(eEzbuLaqzvafbaksibOwYiAR1Jua0ia0QXNa7yl7LahnddO8enxZWrmYKQvjSqGL15cYGOmbgFPjx6eyhBznrlRWKYdOSgqRcOZauLcOh6kq9XlLlwWr(npGSCVg3luJUJC51VDjYYxewbnvvLbb2Xw2lbg7xnHyKjvreHfcSSoxqgeLjW4ln5sNa7ylRjAzfMuEaL1aAvaDgGQua9qxbQpEPCXcoYV5bKL714EHA0DKlV(Tlrw(IWkOPQQma0zakU7WOJULOzyaLNO5AgUceAiOpbxXpErBjJaOSgqFvje0MF8I9a6mafHakUIF8YRHohBzVEaqznGIOs9buKqcqhTv(kNRUsqZ1mCflXiNlpGIacSJTSxcmhQHRixmIrMuLvjSqGL15cYGOmbgFPjx6eyOgJ(a6uaf7VPpHxwancafQXOFHXJJa7yl7La)MibTDUkXitQwNewiWY6CbzquMa7yl7LaZ0lF3VO5stiW4ln5sNaBEqwR4b1kUw9KHB9vK15cYaqNbOieq5qHGkm9Y39lAi0lwbvfqNbOCOqqfME57(fne6fRCcJN7dOraOqng9bu2auecO18lDUGuy403RX9BaADbOy)n9j8YcOiaqvcaLhpa0zaQsbuouiOs0mm0VAEP9Lty8CFafjKauouiOctV8D)Igc9IvoHXZ9b0za6kXz6OPMRz4kQvKRz6vaueqGXXWbrB(Xl2tMuLyKjvRpHfcSSoxqgeLjWo2YEjWiNHGg3mm(oiW4ln5sNadHgc6tWv8Jx0wYiaAeakpEaOZauOgJ(a6uaf7VPpHxwancafQXOFHXJJaJJHdI28JxSNmPkXitQgVewiWY6CbzquMa7yl7LaFUQ1N(TlrwiW4ln5sNaZHcbvSuv3qARIOFvXVYBogzavbGYQaksibOJ2kFLZvxjO5AgUILyKZLNaJJHdI28JxSNmPkXitQIyiSqGL15cYGOmbgFPjx6e4rBLVY5QRe0CndxXsmY5YtGDSL9sGz6LV7x0CPjeJmPQsIWcbwwNlidIYeyhBzVe4xovzn9B5YtGXxAYLob(eOt(koxqa0zaQ5hVyflzeT16rkakRbuedGIesakhkeuPwQk3RRjBZuqvjW4y4GOn)4f7jtQsmYKQrcewiWY6CbzquMaJV0KlDc8kXz6OPMRz4kFLZvxjaOZauOgJ(akRb0A(LoxqkmC6714(navjauebOZa0rBLxovzn9B5YxoHXZ9buwdO1hqvcaLhpiWo2YEjWrZWakprZ1mCeJmbrXNWcb2Xw2lbgxXr(CMNalRZfKbrzIrMGOQewiWY6CbzquMa7yl7LaJCgcACZW47GaJV0KlDcmuJrFaDkGI930NWllGgbGc1y0VW4XrGXXWbrB(Xl2tMuLyKjicrewiWY6CbzquMaJV0KlDc8HUcuF8s5IfCKFZdil3RX9c1O7ixE9BxIS8fHvqtvvzqGDSL9sGJMHbuEIMRz4igzcIyvcleyzDUGmiktGDSL9sGz6LV7x0CPjey8LMCPtG5qHGkm9Y39lAi0lwbvfqrcjafQXOpGofqDSL9wqodbnUzy8DuW(B6t4LfqznGc1y0VW4XbO1fGwT(aksibOJ2kFLZvxjO5AgUILyKZLhqrcjaLdfcQendd9RMxAF5egp3NaJJHdI28JxSNmPkXitquDsyHalRZfKbrzcSJTSxc85QwF63UezHaJJHdI28JxSNmPkXitqu9jSqGL15cYGOmbgFPjx6e4vIZ0rtnxZWvQ1b3YGaOZa0rBLxovzn9B5YxSeJCU8aksibOReNPJMAUMHROwrUMPxbqrcjaDL4mD0uZ1mCLVY5QRea0zakuJrFaL1aA9Jpb2Xw2lboAggq5jAUMHJyeJaJdIxtiSqMuLWcbwwNlidIYeyhBzVe4xovzn9B5YtGXxAYLob28GSwPsSX5VMlnPiRZfKbGodq5qHGk1sv5EDnzBMYjmEUpGodq5qHGk1sv5EDnzBMYjmEUpGgbGYJheyCmCq0MF8I9KjvjgzcIiSqGDSL9sGJMHH(vZlTNalRZfKbrzIrMWQewiWo2YEjWN896wU8A)UokbwwNlidIYeJmPojSqGL15cYGOmbgFPjx6eyi0qqFcUIF8I2sgbqJaq5XdcSJTSxcC0mmGYt0CndhXitQpHfcSJTSxcmUIJ85mpbwwNlidIYeJmjEjSqGL15cYGOmbgFPjx6e4rBLVY5QRe0CndxXsmY5YdOZauecOJ2k5AYTEqZfezKlF5nhJmGgbGIiafjKa0rBLVY5QRe0Cndx5egp3hqJaq5XdafbeyhBzVeyoudxrUyeJmbXqyHalRZfKbrzcm(stU0jWJ2kFLZvxjO5AgUILyKZLNa7yl7LaJ9RMqmYeLeHfcSSoxqgeLjW4ln5sNad1y0hqNcOy)n9j8YcOraOqng9lmECeyhBzVe4H4wfnUIJ85meJmjsGWcb2Xw2lbg39nY1nzO9)D0GrGL15cYGOmXitQgFcleyzDUGmiktGXxAYLobgxXpE51qNJTSxpaOSgqruP(a6maf3Dy0r3s0mmGYt0Cndxbcne0NGR4hVOTKrauwdOVQecAZpEXEaLnafreyhBzVeyoudxrUyeJmPAvcleyzDUGmiktGXxAYLobgQXOpGofqX(B6t4LfqJaqHAm6xy84iWo2YEjWqbFroxE9BxISqmYKQiIWcbwwNlidIYey8LMCPtGXDhgD0TenddO8enxZWvGqdb9j4k(XlAlzeaL1a6RkHG28JxShqzdqreGodqnpiRv8GAfxREYWT(kY6CbzqGDSL9sGX(vtigzsvwLWcbwwNlidIYeyhBzVeyKZqqJBggFhey8LMCPtGHAm6dOtbuS)M(eEzb0iauOgJ(fgpoaDgGcHgc6tWv8Jx0wYiaAeakpEaOZauecOh6kq9XlLv(px(O(f7125QQ5YRDvv)Cd9lcRGMQQYaqNbO4UdJo6wGorQNC5125QLty8CFaDgGI7om6OBX8tBNRwoHXZ9buKqcqvkGEORa1hVuw5)C5J6xSxBNRQMlV2vv9Zn0ViScAQQkdafbeyCmCq0MF8I9Kjvjgzs16KWcbwwNlidIYey8LMCPtGvkGoARenddO8enxZWvSeJCU8eyhBzVe4OzyaLNO5AgoIrMuT(ewiWY6CbzquMaJV0KlDcmcbuLcOReNPJMAUMHR8voxDLaGIesaQsbuZdYALOzyaLNOZfc9ZElY6CbzaOiaqNbO4UdJo6wIMHbuEIMRz4kqOHG(eCf)4fTLmcGYAa9vLqqB(Xl2dOSbOiIa7yl7LaZHA4kYfJyKjvJxcleyzDUGmiktGXxAYLobg3Dy0r3s0mmGYt0Cndxbcne0NGR4hVOTKrauwdOVQecAZpEXEaLnafreyhBzVeySF1eIrMufXqyHa7yl7LaJCgc6VsBeyzDUGmiktmYKQkjcleyhBzVeyOGhtg6VsBeyzDUGmiktmYKQrcewiWo2YEjWUMb9gYPBin(6OpbwwNlidIYeJmbrXNWcb2Xw2lb(nrcA7CvcSSoxqgeLjgzcIQsyHalRZfKbrzcSJTSxc8lNQSM(TC5jW4ln5sNaFc0jFfNlia6ma18GSwPsSX5VMlnPiRZfKbGodqn)4fRyjJOTwpsbqznGQKiW4y4GOn)4f7jtQsmYeeHicleyhBzVeySF1ecSSoxqgeLjgzcIyvcleyzDUGmiktGDSL9sGrodbnUzy8DqGXxAYLobgQXOpGofqX(B6t4LfqJaqHAm6xy84a0zakcb0dDfO(4LYk)NlFu)I9A7Cv1C51UQQFUH(fHvqtvvzaOZauC3HrhDlqNi1tU8A7C1YjmEUpGodqXDhgD0Ty(PTZvlNW45(aksibOkfqp0vG6JxkR8FU8r9l2RTZvvZLx7QQ(5g6xewbnvvLbGIacmogoiAZpEXEYKQeJmbr1jHfcSSoxqgeLjWo2YEjWVCQYA63YLNaJV0KlDc8jqN8vCUGqGXXWbrB(Xl2tMuLyKjiQ(ewiWY6CbzquMa7yl7LaZ0lF3VO5stiW4y4GOn)4f7jtQsmYeefVewiWY6CbzquMa7yl7LaFUQ1N(TlrwiW4y4GOn)4f7jtQsmIrmcCn5(SxYeefFevn(XlIuse4O(T5Y)eyL84bI9Ki5KiX6gqbuwQiaAYO2NbOq9bOrw9eCZW5wKb0tyf08KbG(nJaOoQ1mUjdafxXxE5lG5rAUcGwTUbueV3AYzYaqJS5bzTs8mYaQ1aAKnpiRvINfzDUGmImG6gGwVv92rkGIWQXHGcyoyUsE8aXEsKCsKyDdOaklveanzu7ZauO(a0i)wKb0tyf08KbG(nJaOoQ1mUjdafxXxE5lG5rAUcGwToRBafX7TMCMmau4KbXb0p2AECaADaOwdOrkQdOJSw(zVaARkNB9bOiKneaOiSACiOaMdMRKhpqSNejNejw3akGYsfbqtg1(mafQpanY4Xhza9ewbnpzaOFZiaQJAnJBYaqXv8Lx(cyEKMRaOvRw3akI3Bn5mzaOr(B0axUJs8mYaQ1aAK)gnWL7OeplY6CbzezafHikoeuaZJ0CfaTADw3akI3Bn5mzaOWjdIdOFS184a06aqTgqJuuhqhzT8ZEb0wvo36dqriBiaqry14qqbmpsZva0Q1VUbueV3AYzYaqHtgehq)yR5XbO1bGAnGgPOoGoYA5N9cOTQCU1hGIq2qaGIWQXHGcyEKMRaOvJ36gqr8ERjNjdafozqCa9JTMhhGwhaQ1aAKI6a6iRLF2lG2QY5wFakczdbakcRghckG5G5k5Xde7jrYjrI1nGcOSura0KrTpdqH6dqJmxRgza9ewbnpzaOFZiaQJAnJBYaqXv8Lx(cyEKMRaOvRZ6gqr8ERjNjdanYh6kq9XlL4zKbuRb0iFORa1hVuINfzDUGmImGIWQXHGcyEKMRaOvRFDdOiEV1KZKbGcNmioG(XwZJdqRda1AansrDaDK1Yp7fqBv5CRpafHSHaafHSACiOaMhP5kaA16x3akI3Bn5mzaOr28GSwjEgza1AanYMhK1kXZISoxqgrgqriIIdbfW8inxbqRw)6gqr8ERjNjdanYh6kq9XlL4zKbuRb0iFORa1hVuINfzDUGmImGIWQXHGcyoyUsE8aXEsKCsKyDdOaklveanzu7ZauO(a0iJdIxtImGEcRGMNma0Vzea1rTMXnzaO4k(YlFbmpsZva0QXVUbueV3AYzYaqHtgehq)yR5XbO1bGAnGgPOoGoYA5N9cOTQCU1hGIq2qaGIWQXHGcyEKMRaOvruDdOiEV1KZKbGcNmioG(XwZJdqRda1AansrDaDK1Yp7fqBv5CRpafHSHaafHvJdbfW8inxbqRw)6gqr8ERjNjdafozqCa9JTMhhGwhaQ1aAKI6a6iRLF2lG2QY5wFakczdbakcRghckG5rAUcGwnERBafX7TMCMmau4KbXb0p2AECaADaOwdOrkQdOJSw(zVaARkNB9bOiKneaOiSACiOaMdMhjzu7ZKbGIyauhBzVaAiF7lG5e4xvWKjiQ(1NaREnugecC9cqHrVAznpaOkzHUMCG51laDoAigGwLDafrXhrvbZbZDSL9(f1tWndNBtvWwn)sNliSVoJOGHtFVg3VXERQ4flHyVMhqffo2YElm9Y39lAU0KcUFJ9AEav0s4ffo2YElNRA9PF7sKLcUFJDCVJ0YEvyEqwRW0lF3VO5staZDSL9(f1tWndNBtvW2JYW0RwvmWChBzVFr9eCZW52ufSX1MfKHgk4XKr0C51whxUG5o2YE)I6j4MHZTPkydkiFf85qgyUJTS3VOEcUz4CBQc2m)025QSNqko0vG6JxkFJgG6Jx0cdNCFryf0uvvgG5o2YE)I6j4MHZTPky7nrcA7CvWCWChBzV)ufSXGwp1tqaZRxaAKydOEfXhaQVdaLLZxwbndz9ia6K6DioGkRWKYRKnGgva0rVr2a0rdOwL8buO(au1GhtUhq5eSJ(cGMwKhakNaOw3a6R6mmXauFhaAubqX(gzdqpXhzigGYY5lRaOVQGtOedOCOqqFbm3Xw27pvbB25lRGMHSEYLx)vAJ9esHsn)4fRKVwn4XKdm3Xw27pvbBOVOttyEW86v9cqR3ibpgGc54C5b0yn6bOJgLZau01YaGgRrb0kEnbqvrnafXw(EDlxEanECxhfqhD0LDaTpanHauRIaO4UdJo6cO5dOw3aAOxEa1AaDibpgGc54C5b0yn6bO1BAuoRaOrsiaD7va0gcqTkYlakU3rAzVpG6NaOoxqauRbugXa0OPvjxa1QiaA14dOVG7D8aAqKOEm2buRIaOFYaOqowEanwJEaA9MgLZauh1Ag3sShcXkG51R6fG6yl79NQGTvIc1O7qFY3HAc7jKIVrdC5okRefQr3H(KVd1KziKdfcQCY3RB5YR976OfuvKqc3Dy0r3YjFVULlV2VRJwoHXZ9zD14JesMF8IvSKr0wRhPer14fbG5o2YE)Pkyd7HG2Xw2RoKVX(6mIc84bZDSL9(tvWg2dbTJTSxDiFJ91zefCTk7jKchBznrlRWKYhbRoZ8GSwHlVXRBiT6jXkY6CbzaM7yl79NQGnShcAhBzV6q(g7RZikEJ9esHJTSMOLvys5JGvNPuZdYAfU8gVUH0QNeRiRZfKbyUJTS3FQc2WEiODSL9Qd5BSVoJOaheVMWEcPWXwwt0YkmP8SgrG5o2YE)PkyZpSVI267K1aZbZDSL9(fUwvXlNQSM(TC5zhhdheT5hVyVIQSNqk4qHGk1sv5EDnzBMYjmEU)meYHcbvQLQY96AY2mLty8C)i4XdKq6eOt(koxqqayUJTS3VW1QtvWgYziOXndJVd2XXWbrB(Xl2ROk7jKcOgJ(tX(B6t4LncOgJ(fgpUzCOqqLv(C5J6xSxBNRQMlV2vv9Zn0VGQIesqng9NI930NWlBeqng9lmECtRg)zCOqqLv(C5J6xSxBNRQMlV2vv9Zn0VGQoJdfcQSYNlFu)I9A7Cv1C51UQQFUH(Lty8C)i4XdWChBzVFHRvNQGnKZqq)vAdm3Xw27x4A1PkylAggq5jAUMHJ9esbuJr)Py)n9j8YgbuJr)cJh3mLAjg5C5NbHgc6tWv8Jx0wYirWJhG5o2YE)cxRovbBqbFroxE9BxISWEcPaQXO)uS)M(eEzJaQXOFHXJdm3Xw27x4A1Pkydk4XKH(R0gyUJTS3VW1QtvWg2dbTJTSxDiFJ91zefR5SNqko0vG6JxkR8FU8r9l2RTZvvZLx7QQ(5g6xewbnvvLXmOgJ(ruZV05csHHtFVg3VbM7yl79lCT6ufSne3QOXvCKpNH9esbuJr)Py)n9j8YgbuJr)cJhhyUJTS3VW1QtvW25QwF63UezHDCmCq0MF8I9kQYEcPGdfcQG7(g56Mm0()oAWkOQZ4qHGk4UVrUUjdT)VJgSYjmEUFevl1xj4XdWChBzVFHRvNQGnME57(fnxAc74y4GOn)4f7vuL9esbhkeub39nY1nzO9)D0GvqvNXHcbvWDFJCDtgA)FhnyLty8C)iQwQVsWJhG5o2YE)cxRovbBUMb9gYPBin(6OpyUJTS3VW1QtvW25QwF63UezHDCmCq0MF8I9kQYEcPGdfcQyPQUH0wfr)QIFL3CmYkyvWChBzVFHRvNQGTOzyaLNO5Ago2tifqng9NI930NWlBeqng9lmECZuQLyKZLFgcHqdb9j4k(XlAlzKi4XdKqsPJ2krZWakprZ1mCflXiNl)mouiOctV8D)Igc9IvoHXZ9zneAiOpbxXpErBjJuxvvcE8ajKu6OTs0mmGYt0CndxXsmY5YptPCOqqfME57(fne6fRCcJN7JaKqYsgrBTEKsevvsZu6OTs0mmGYt0CndxXsmY5YdMxVa0ijeGgRrb0rVr2a0kEnbqNi)NlFu)If5hqz5Cv1C5b04HQQFUH(SdOFYOgIbOy)nafXkdbafXBggFhaAcbOXAuanAVr2a0UMCyxfq7fqvYSXOpGcDndGo6C5b0VlaAKecqJ1Oa6Ob0kEnbqNi)NlFu)If5hqz5Cv1C5b04HQQFUH(aASgfq)knAyaOy)nafXkdbafXBggFhaAcbOXA0dqHAm6dO5dOCsOJcOwfbqX9BaAdbOkz0lF3VaOkNMaO9bOi2UQ1hGcBxISaM7yl79lCT6ufSHCgcACZW47GDCmCq0MF8I9kQYEcPaQXO)uS)M(eEzJaQXOFHXJBgcv6HUcuF8szL)ZLpQFXETDUQAU8Axv1p3qFKqcQXOFe18lDUGuy403RX9BiamVEbOk5PvbqNi)NlFu)If5hqz5Cv1C5b04HQQFUH(aAVHyakIvgcakI3mm(oa0ecqJ1OhGANR(aQFcG2lGI7om6Ol7aABvKlA(cG(wRcOOFU8akIvgcakI3mm(oa0ecqJ1OhGIrVtwdqHAm6dOotJUgGMpGkBJYxbqTgqF038CbuRIaOotJUgG2qaQLmcGgeidqH6dq9ngG2qaASg9au7C1hqTgqXnJaOneeGI7om6OlyUJTS3VW1QtvWgYziOXndJVd2XXWbrB(Xl2ROk7jKcOgJ(tX(B6t4LncOgJ(fgpUzh6kq9XlLv(px(O(f7125QQ5YRDvv)Cd9NH7om6OBb6ePEYLxBNRwoHXZ9zncHAm6xhiSMFPZfKcdN(EnUFRUW(B6t4LfbkbpEGGz4UdJo6wm)025QLty8CFwJqOgJ(1bcR5x6CbPWWPVxJ73QlS)M(eEzrGsWJhiygcvQ5bzTYBIe025QiHK5bzTYBIe025QZWDhgD0T8MibTDUA5egp3N1ieQXOFDGWA(LoxqkmC6714(T6c7VPpHxweOe84bcqayUJTS3VW1QtvW2BIe025QSNqkGAm6pf7VPpHx2iGAm6xy84aZDSL9(fUwDQc2E5uL10VLlp74y4GOn)4f7vuL9esXOTYlNQSM(TC5lNaDYxX5cYmLYHcbvWDFJCDtgA)FhnyfuvWChBzVFHRvNQGTt(EDlxETFxhfm3Xw27x4A1PkylAgg6xnV0EWChBzVFHRvNQGnC33ix3KH2)3rdg7jKcLYHcbvWDFJCDtgA)FhnyfuvWChBzVFHRvNQGnME57(fnxAc7jKcouiOctV8D)Igc9IvqvrcjOgJ(tDSL9wqodbnUzy8DuW(B6t4LL1qng9lmECiHehkeub39nY1nzO9)D0GvqvbZDSL9(fUwDQc2ox16t)2LilSJJHdI28JxSxrvWChBzVFHRvNQGTOzyaLNO5Ago2tifJ2krZWakprZ1mCLtGo5R4Cbbm3Xw27x4A1Pky7Ltvwt)wU8SJJHdI28JxSxrv2tifCOqqLAPQCVUMSntbvfmhm3Xw27xWJxrf)u7EzpHuyEqwRyYX86gsllVZlmYAfzDUGmMb1y0pcOgJ(fgpoWChBzVFbp(Pkyd9fDAcd7RZikgN4dO8eDn5FjWEcPa31K1xRGCSl9DgU7WOJULt(EDlxETFxhTCcJN7Z6QXhjKukURjRVwb5yx6lyUJTS3VGh)ufSXf6EOHqVySNqkWDhgD0TG7(g56Mm0()oAWkNW45(SMvJpyUJTS3VGh)ufS5lwE78Gg7Ha7jKcC3HrhDl4UVrUUjdT)VJgSYjmEUpRz14dM7yl79l4XpvbBq5jCHUhSNqkWDhgD0TG7(g56Mm0()oAWkNW45(SMvJpyUJTS3VGh)ufSfs(k2RR3Jo4zK1aZDSL9(f84NQGnoNx3qA7smYp7jKcC3HrhDliNHGg3mm(okqOHG(eCf)4fTLmcR5XdWChBzVFbp(PkyJtUxoKZLN9esbU7WOJUfC33ix3KH2)3rdw5egp3N1XB8rcjlzeT16rkruLvbZDSL9(f84NQGng06PEccyUJTS3VGh)ufSP2w2l7jKcOKVIPpHXZ9JiEJpsiXHcbvWDFJCDtgA)FhnyfuvWChBzVFbp(PkydkiFf85qg75AYDOQMoHuGR47kHC5NP0VrdC5okQOVHgeTCOQw2l7jKcec1y0pcet8rcjC3HrhDl4UVrUUjdT)VJgSYjmEUFe84bcMHWVrdC5okQOVHgeTCOQw2lsi9nAGl3rPwhCldI(7qnzneaM7yl79l4XpvbBMFA7Cv2tifqng9NI930NWlBeqng9lmECZo0vG6JxkFJgG6Jx0cdNCFryf0uvvgZm)025QLty8C)i4XJz4UdJo6wGc(jLty8C)i4XJzi0Xwwt0YkmP8SUksi5ylRjAzfMuEfvNzjJOTwpsH11xj4XdeaM7yl79l4XpvbBqb)e2d5kA8qbIQp7jKcOgJ(tX(B6t4LncOgJ(fgpUzMFA7C1cQ6SdDfO(4LY3ObO(4fTWWj3xewbnvvLXmlzeT16rkSUovcE8am3Xw27xWJFQc2qodb9xPn2tifo2YAIwwHjLxr1zMF8IvSKr0wRhPebuJr)6aH18lDUGuy403RX9B1f2FtFcVSiqj4XdWChBzVFbp(PkyJPx(UFrZLMWEcPWXwwt0YkmP8kQoZ8JxSILmI2A9iLiGAm6xhiSMFPZfKcdN(EnUFRUW(B6t4LfbkbpEaM7yl79l4XpvbBNRA9PF7sKf2tifo2YAIwwHjLxr1zMF8IvSKr0wRhPebuJr)6aH18lDUGuy403RX9B1f2FtFcVSiqj4XdWChBzVFbp(PkyZFvbB6gsBveT48bH9esH5hVyLr(MVyH1kIxWCWChBzVFbheVMO4Ltvwt)wU8SJJHdI28JxSxrv2tifMhK1kvIno)1CPjfzDUGmMXHcbvQLQY96AY2mLty8C)zCOqqLAPQCVUMSnt5egp3pcE8am3Xw27xWbXRjtvWw0mm0VAEP9G5o2YE)coiEnzQc2o571TC51(DDuWChBzVFbheVMmvbBrZWakprZ1mCSNqkGqdb9j4k(XlAlzKi4XdWChBzVFbheVMmvbB4koYNZ8G5o2YE)coiEnzQc24qnCf5IXEcPy0w5RCU6kbnxZWvSeJCU8Zq4OTsUMCRh0Cbrg5YxEZXihbIqcPrBLVY5QRe0Cndx5egp3pcE8abG5o2YE)coiEnzQc2W(vtypHumAR8voxDLGMRz4kwIroxEWChBzVFbheVMmvbBdXTkACfh5ZzypHua1y0Fk2FtFcVSra1y0VW4XbM7yl79l4G41KPkyd39nY1nzO9)D0GbM7yl79l4G41KPkyJd1WvKlg7jKcCf)4LxdDo2YE9aRruP(ZWDhgD0TenddO8enxZWvGqdb9j4k(XlAlzew)QsiOn)4f7RdebM7yl79l4G41KPkydk4lY5YRF7sKf2tifqng9NI930NWlBeqng9lmECG5o2YE)coiEnzQc2W(vtypHuG7om6OBjAggq5jAUMHRaHgc6tWv8Jx0wYiS(vLqqB(Xl2xhiAM5bzTIhuR4A1tgU1xrwNlidWChBzVFbheVMmvbBiNHGg3mm(oyhhdheT5hVyVIQSNqkGAm6pf7VPpHx2iGAm6xy84MbHgc6tWv8Jx0wYirWJhZq4HUcuF8szL)ZLpQFXETDUQAU8Axv1p3q)IWkOPQQmMH7om6OBb6ePEYLxBNRwoHXZ9NH7om6OBX8tBNRwoHXZ9rcjLEORa1hVuw5)C5J6xSxBNRQMlV2vv9Zn0ViScAQQkdeaM7yl79l4G41KPkylAggq5jAUMHJ9esHshTvIMHbuEIMRz4kwIroxEWChBzVFbheVMmvbBCOgUICXypHuGqLUsCMoAQ5AgUYx5C1vciHKsnpiRvIMHbuEIoxi0p7TiRZfKbcMH7om6OBjAggq5jAUMHRaHgc6tWv8Jx0wYiS(vLqqB(Xl2xhicm3Xw27xWbXRjtvWg2VAc7jKcC3HrhDlrZWakprZ1mCfi0qqFcUIF8I2sgH1VQecAZpEX(6arG5o2YE)coiEnzQc2qodb9xPnWChBzVFbheVMmvbBqbpMm0FL2aZDSL9(fCq8AYufS5Ag0BiNUH04RJ(G5o2YE)coiEnzQc2EtKG2oxfm3Xw27xWbXRjtvW2lNQSM(TC5zhhdheT5hVyVIQSNqkob6KVIZfKzMhK1kvIno)1CPjfzDUGmMz(XlwXsgrBTEKcRvsG5o2YE)coiEnzQc2W(vtaZDSL9(fCq8AYufSHCgcACZW47GDCmCq0MF8I9kQYEcPaQXO)uS)M(eEzJaQXOFHXJBgcp0vG6JxkR8FU8r9l2RTZvvZLx7QQ(5g6xewbnvvLXmC3HrhDlqNi1tU8A7C1YjmEU)mC3HrhDlMFA7C1YjmEUpsiP0dDfO(4LYk)NlFu)I9A7Cv1C51UQQFUH(fHvqtvvzGaWChBzVFbheVMmvbBVCQYA63YLNDCmCq0MF8I9kQYEcP4eOt(koxqaZDSL9(fCq8AYufSX0lF3VO5styhhdheT5hVyVIQG5o2YE)coiEnzQc2ox16t)2LilSJJHdI28JxSxrvWCWChBzVFznxXBIe025QG5o2YE)YA(ufSbDIup5YRTZvzpHuOuouiOs0mm0VAEP9Lty8CFKqIdfcQendd9RMxAF5egp3FgU7WOJUfKZqqJBggFhLty8CFWChBzVFznFQc2m)025QSNqkukhkeujAgg6xnV0(YjmEUpsiXHcbvIMHH(vZlTVCcJN7pd3Dy0r3cYziOXndJVJYjmEUpyoyUJTS3V8MIH4wfnUIJ85mSNqkGAm6pf7VPpHx2iGAm6xy84aZDSL9(L3MQGTxovzn9B5YZoogoiAZpEXEfvzpHuO0rBLxovzn9B5YxSeJCU8Zm)4fRyjJOTwpsH1igKqIdfcQulvL711KTzkOQZ4qHGk1sv5EDnzBMYjmEUFe84byUJTS3V82ufSbf8yYq)vAdm3Xw27xEBQc2o571TC51(DDuWChBzVF5TPkylAgg6xnV0EWChBzVF5TPkyd39nY1nzO9)D0GbM7yl79lVnvbBiNHG(R0gyUJTS3V82ufSbf8f5C51VDjYc7jKcOgJ(tX(B6t4LncOgJ(fgpoWChBzVF5TPkyZ1mO3qoDdPXxh9bZDSL9(L3MQGTOzyaLNO5Ago2tifqOHG(eCf)4fTLmse84bsib1y0Fk2FtFcVSra1y0VW4XndHReNPJMAUMHRuRdULbz2OTYlNQSM(TC5lwIrox(zJ2kVCQYA63YLVCc0jFfNliiH0kXz6OPMRz4kQvKRz6vMPuouiOctV8D)Igc9IvqvNb1y0Fk2FtFcVSra1y0VW4Xvxo2YEliNHGg3mm(oky)n9j8YQeSkcqcjlzeT16rkrun(G5o2YE)YBtvWg2VAc7jKchBznrlRWKYZ6QZu6HUcuF8s5IfCKFZdil3RX9c1O7ixE9BxIS8fHvqtvvzaM7yl79lVnvbBCOgUICXypHu4ylRjAzfMuEwxDMsp0vG6JxkxSGJ8BEaz5EnUxOgDh5YRF7sKLViScAQQkJz4UdJo6wIMHbuEIMRz4kqOHG(eCf)4fTLmcRFvje0MF8I9ZqiUIF8YRHohBzVEG1iQuFKqA0w5RCU6kbnxZWvSeJCU8iam3Xw27xEBQc2EtKG2oxL9esbuJr)Py)n9j8YgbuJr)cJhhyUJTS3V82ufSX0lF3VO5styhhdheT5hVyVIQSNqkmpiRv8GAfxREYWT(kY6CbzmdHCOqqfME57(fne6fRGQoJdfcQW0lF3VOHqVyLty8C)iGAm6xhiSMFPZfKcdN(EnUFRUW(B6t4LfbkbpEmtPCOqqLOzyOF18s7lNW45(iHehkeuHPx(UFrdHEXkNW45(Zwjothn1CndxrTICntVccaZDSL9(L3MQGnKZqqJBggFhSJJHdI28JxSxrv2tifqOHG(eCf)4fTLmse84XmOgJ(tX(B6t4LncOgJ(fgpoWChBzVF5TPky7CvRp9BxISWoogoiAZpEXEfvzpHuWHcbvSuv3qARIOFvXVYBogzfSksinAR8voxDLGMRz4kwIroxEWChBzVF5TPkyJPx(UFrZLMWEcPy0w5RCU6kbnxZWvSeJCU8G5o2YE)YBtvW2lNQSM(TC5zhhdheT5hVyVIQSNqkob6KVIZfKzMF8IvSKr0wRhPWAedsiXHcbvQLQY96AY2mfuvWChBzVF5TPkylAggq5jAUMHJ9esXkXz6OPMRz4kFLZvxjmdQXOpRR5x6CbPWWPVxJ73ucenB0w5Ltvwt)wU8Lty8CFwxFLGhpaZDSL9(L3MQGnCfh5ZzEWChBzVF5TPkyd5me04MHX3b74y4GOn)4f7vuL9esbuJr)Py)n9j8YgbuJr)cJhhyUJTS3V82ufSfnddO8enxZWXEcP4qxbQpEPCXcoYV5bKL714EHA0DKlV(Tlrw(IWkOPQQmaZDSL9(L3MQGnME57(fnxAc74y4GOn)4f7vuL9esbhkeuHPx(UFrdHEXkOQiHeuJr)Po2YEliNHGg3mm(oky)n9j8YYAOgJ(fgpU6QA9rcPrBLVY5QRe0CndxXsmY5YJesCOqqLOzyOF18s7lNW45(G5o2YE)YBtvW25QwF63UezHDCmCq0MF8I9kQcM7yl79lVnvbBrZWakprZ1mCSNqkwjothn1CndxPwhCldYSrBLxovzn9B5YxSeJCU8iH0kXz6OPMRz4kQvKRz6vqcPvIZ0rtnxZWv(kNRUsyguJrFwx)4tmIria]] )


end