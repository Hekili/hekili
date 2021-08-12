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


    spec:RegisterPack( "Survival", 20210812, [[d8usLbqiHipsOk1LeQkBce9jHOgfKOtbjSkuj1RaHzHk1Tajyxs8lurddskhtsAzqsEgQKmnqI6AGKSnHQQVbskJdvcohiPY6aj07ajvrZJKQ7rs2NqWbfcXcjP8qiPAIcvr6IGKQWgbjvLpkesgjiPQ6KcvHvcs9sujKzkeQBkufHDkP6Ncvr0qbjvPLIkH6PGAQqQ(Qqi1yfQs2lI)sQbJYHPAXi5XqnzfUmXMv0NrvJwiDArRwOkQxJkmBb3gP2Tk)wQHtIJJkrlxPNRQPt56qSDjLVljgVqLZluwpirMpKY(bMuLGobE4MqQJkudvvrnUqvuvqnUaxf)OQkb2IPieyfhZHZle4ZPfcmmYwlR5bcSIhl0(GGob(BKfle44nGf1mLhkYjN8PffHQGBAo)Kgj4w2hE9PX5N0yojWuizWIhhHIapCti1rfQHQQOgxOkQkOgxGRI)QqDeyhXI2lbgoPrDcC0CmKJqrGhYJjWWiBTSMhamO(rotwa0reeEK3amOg3agQqnuvLahY3Ec6e4ZCc6K6vjOtGDSL9rGFtKG2wxHalNtfKbrnIrQJkc6ey5CQGmiQrGXBAYMobosagfYCwQKHH(vYnTVScTN3dyOHgGrHmNLkzyOFLCt7lRq759agKagU7WORCfoYqqJBAA)gLvO98EcSJTSpc8CfbkLhV2wxHyK6CfbDcSCovqge1iW4nnztNahjaJczolvYWq)k5M2xwH2Z7bm0qdWOqMZsLmm0VsUP9LvO98Eadsad3Dy0vUchziOXnnTFJYk0EEpb2Xw2hb28vBRRqmIrGhY0rcgbDs9Qe0jWo2Y(iW0iqjOuqiWY5ubzquJyK6OIGobwoNkidIAeyhBzFeyB9JlrYqcLYJx)rBJapKhVPIL9rGJOAaZJk(aW8BayOV(XLiziHscGvhQxuhWKtOt55gWQia2OViBa2ObmlA(a2Sxatj4XK9bmkb7iVayPf5bGrjaM1nG9konDmaZVbGvramSFr2aSv8rgIbyOV(XLa2Ri4CMyaJczo)cbgVPjB6e4ibyMV8IvYxRe8yYsmsDUIGobwoNkidIAeyhBzFe4452qoEj3vpK3Yl2RXEiqGXBAYMobMczol4U3rEUjdT)VJeScIcGHgAagv)pGbjGnt(OMEfApVhWuhW4kuJaFoTqGJNBd54LCx9qElVyVg7HaXi1HYe0jWo2Y(iWiVOttOFcSCovqge1igPourqNalNtfKbrncSJTSpcm2dbTJTSpDiFJahY30Ntley84jgPE8tqNalNtfKbrncmEtt20jWo2YAIwoHoLhWuhW4kadsaZ8GCwHk3XR7PwzLyf5CQGmiWo2Y(iWype0o2Y(0H8ncCiFtFoTqGPAfIrQd1iOtGLZPcYGOgbgVPjB6eyhBznrlNqNYdyQdyCfGbjGfjaZ8GCwHk3XR7PwzLyf5CQGmiWo2Y(iWype0o2Y(0H8ncCiFtFoTqGFJyK6Cbc6ey5CQGmiQrGXBAYMob2Xwwt0Yj0P8aweamurGDSL9rGXEiODSL9Pd5Be4q(M(CAHaJdIxtigPouhbDcSJTSpcSVy)eT17kNrGLZPcYGOgXigbwzfCtt5gbDs9Qe0jWY5ubzquJa3ke4xSCsGXBAYMob28GCwHUp(UFrtLMuKZPcYGapKhVPIL9rGJii8iVbyqnUbmuHAOQkbUMV6ZPfcmnLEFnUFJa7yl7JaxZ30PccbUMhqeTeEHa7yl7RSUI1R(Tn5qk4(ncCnpGieyhBzFf6(47(fnvAsb3VrmsDurqNa7yl7Ja)i009PveJalNtfKbrnIrQZve0jWo2Y(iWuTzbzONbpMmQKhV264YJalNtfKbrnIrQdLjOtGDSL9rGNb5JIxFAey5CQGmiQrmsDOIGobwoNkidIAey8MMSPtGxKtM9YlLVrcZE5fTqtj7xeUejvuKbb2Xw2hb28vBRRqms94NGob2Xw2hb(nrcABDfcSCovqge1igXiW4G41ec6K6vjOtGLZPcYGOgb2Xw2hb(Lvrot)wE8ey8MMSPtGnpiNvIgBS(RPstkY5ubzayqcyuiZzPwQi7RRjxtxwH2Z7bmibmkK5SulvK911KRPlRq759aM6agpEqGXXWbrB(Yl2tQxLyK6OIGob2Xw2hbUsgg6xj30EcSCovqge1igPoxrqNa7yl7JaVY3NB5XR9D7key5CQGmiQrmsDOmbDcSJTSpcmU7DKNBYq7)7ibJalNtfKbrnIrQdve0jWY5ubzquJaJ30KnDc8eje0RGJ6lVOTKwam1bmE8Ga7yl7JaxjdJzUIMQPPigPE8tqNa7yl7JaJJ6CSo9tGLZPcYGOgXi1HAe0jWY5ubzquJaJ30KnDc8OTYhDDLtcAQMMQyjMJ84bmibmucyJ2k5zYEEqtfezKhF5nhZbGPoGHkadn0aSrBLp66kNe0unnvzfApVhWuhW4XdadfeyhBzFeykedhv2yeJuNlqqNalNtfKbrncmEtt20jWJ2kF01vojOPAAQILyoYJNa7yl7JaJ9TMqmsDOoc6ey5CQGmiQrGXBAYMobE2yKhWGaWW(B6v4LdWuhWMng5l0ECeyhBzFe4H4wunoQZX60eJuVkQrqNalNtfKbrncmEtt20jW4O(YlVEUo2Y(8aGfbadvfOcWGeWWDhgDLRujdJzUIMQPPktKqqVcoQV8I2sAbWIaG9ksiOnF5f7bmobmurGDSL9rGPqmCuzJrms9QvjOtGLZPcYGOgbgVPjB6e4zJrEadcad7VPxHxoatDaB2yKVq7XrGDSL9rGNb)4ipE9BBYHqms9QOIGobwoNkidIAey8MMSPtGXDhgDLRujdJzUIMQPPktKqqVcoQV8I2sAbWIaG9ksiOnF5f7bmobmubyqcyMhKZkEqjQRvwz4wVf5CQGmiWo2Y(iWyFRjeJuVkxrqNalNtfKbrncSJTSpcmhziOXnnTFdcmEtt20jWZgJ8ageag2FtVcVCaM6a2SXiFH2JdWGeWMiHGEfCuF5fTL0cGPoGXJhagKagkbSf5KzV8s5K)ZJVIVXETTUIsE8AxrXx3q(IWLiPIImamibmC3Hrx5kZveOuE8ABDLYk0EEpGbjGH7om6kxX8vBRRuwH2Z7bm0qdWIeGTiNm7LxkN8FE8v8n2RT1vuYJx7kk(6gYxeUejvuKbGHccmogoiAZxEXEs9QeJuVkuMGobwoNkidIAey8MMSPtGJeGnARujdJzUIMQPPkwI5ipEcSJTSpcCLmmM5kAQMMIyK6vHkc6ey5CQGmiQrGXBAYMobgLawKaStIZ0vsnvttv(ORRCsaWqdnalsaM5b5SsLmmM5k68MiF2xroNkidadfagKagU7WORCLkzymZv0unnvzIec6vWr9Lx0wslaweaSxrcbT5lVypGXjGHkcSJTSpcmfIHJkBmIrQxn(jOtGLZPcYGOgbgVPjB6eyC3Hrx5kvYWyMROPAAQYeje0RGJ6lVOTKwaSiayVIecAZxEXEaJtadveyhBzFeySV1eIrQxfQrqNa7yl7JaZrgc6pABey5CQGmiQrms9QCbc6eyhBzFe4zWJjd9hTncSCovqge1igPEvOoc6eyhBzFeyxtJSdz19uJ3UYtGLZPcYGOgXi1rfQrqNa7yl7Ja)MibTTUcbwoNkidIAeJuhvvjOtGLZPcYGOgb2Xw2hb(Lvrot)wE8ey8MMSPtGxzUYh1PccGbjGzEqoRen2y9xtLMuKZPcYaWGeWmF5fRyjTOTwpsbWIaGXfiW4y4GOnF5f7j1RsmsDuHkc6eyhBzFeySV1ecSCovqge1igPoQ4kc6ey5CQGmiQrGDSL9rG5idbnUPP9BqGXBAYMobE2yKhWGaWW(B6v4LdWuhWMng5l0ECagKagkbSf5KzV8s5K)ZJVIVXETTUIsE8AxrXx3q(IWLiPIImamibmC3Hrx5kZveOuE8ABDLYk0EEpGbjGH7om6kxX8vBRRuwH2Z7bm0qdWIeGTiNm7LxkN8FE8v8n2RT1vuYJx7kk(6gYxeUejvuKbGHccmogoiAZxEXEs9QeJuhvqzc6ey5CQGmiQrGDSL9rGFzvKZ0VLhpbgVPjB6e4vMR8rDQGqGXXWbrB(Yl2tQxLyK6OcQiOtGLZPcYGOgb2Xw2hbMUp(UFrtLMqGXXWbrB(Yl2tQxLyK6Ok(jOtGLZPcYGOgb2Xw2hbEDfRx9BBYHqGXXWbrB(Yl2tQxLyeJaJhpbDs9Qe0jWY5ubzquJaJ30KnDcS5b5SIjl9R7PwoENxOLZkY5ubzayqcyZgJ8aM6a2SXiFH2JJa7yl7Jah1xLUpIrQJkc6ey5CQGmiQrGXBAYMobMczol4U3rEUjdT)VJeScIcb2Xw2hbMk09qpr2yeJuNRiOtGLZPcYGOgbgVPjB6eykK5SG7Eh55Mm0()osWkikeyhBzFey)WYBRh0ypeigPouMGobwoNkidIAey8MMSPtGPqMZcU7DKNBYq7)7ibRGOqGDSL9rGN5kuHUheJuhQiOtGDSL9rGdjFu71XZidEA5mcSCovqge1igPE8tqNalNtfKbrncmEtt20jW4UdJUYv4idbnUPP9BuMiHGEfCuF5fTL0cGfbaJhpiWo2Y(iWuoVUNABtmhpXi1HAe0jWY5ubzquJaJ30KnDcmfYCwWDVJ8CtgA)Fhjyfefadn0amlPfT16rkaM6awvUIa7yl7Jatj7llh5XtmsDUabDcSJTSpcmncuckfecSCovqge1igPouhbDcSCovqge1iW4nnztNapt(OMEfApVhWuhWIFudWqdnaJczol4U3rEUjdT)VJeScIcb2Xw2hbwPTSpIrQxf1iOtGLZPcYGOgbgVPjB6eyucyZgJ8aM6agud1am0qdWWDhgDLRG7Eh55Mm0()osWkRq759aM6agpEayOaWGeWqjG9nsGkVrrb5nKGOLfrXY(kY5ubzayOHgG9nsGkVrPwhCldI(7qn5SICovqgagkiWo2Y(iWZG8rXRpncCEMSlIIPZjbgh1Vtc5XdzK(gjqL3OOG8gsq0YIOyzFeJuVAvc6ey5CQGmiQrGXBAYMobE2yKhWGaWW(B6v4LdWuhWMng5l0ECagKa2ICYSxEP8nsy2lVOfAkz)IWLiPIImamibmZxTTUszfApVhWuhW4Xdadsad3Dy0vUYm4RuwH2Z7bm1bmE8aWGeWqjG5ylRjA5e6uEalcawvadn0amhBznrlNqNYdyQaSQagKaML0I2A9ifalcagubyCnGXJhagkiWo2Y(iWMVABDfIrQxfve0jWY5ubzquJa7yl7Japd(key8MMSPtGNng5bmiamS)MEfE5am1bSzJr(cThhGbjGz(QT1vkikagKa2ICYSxEP8nsy2lVOfAkz)IWLiPIImamibmlPfT16rkaweamOmGX1agpEqGd5jA8GaJkOIyK6v5kc6ey5CQGmiQrGXBAYMob2Xwwt0Yj0P8aMkaRkGbjGz(YlwXsArBTEKcGPoGnBmYdyCcyOeWQ5B6ubPqtP3xJ73amOaGH930RWlhGHcaJRbmE8Ga7yl7JaZrgc6pABeJuVkuMGobwoNkidIAey8MMSPtGDSL1eTCcDkpGPcWQcyqcyMV8IvSKw0wRhPayQdyZgJ8agNagkbSA(Movqk0u6914(nadkayy)n9k8YbyOaW4AaJhpiWo2Y(iW09X39lAQ0eIrQxfQiOtGLZPcYGOgbgVPjB6eyhBznrlNqNYdyQaSQagKaM5lVyflPfT16rkaM6a2SXipGXjGHsaRMVPtfKcnLEFnUFdWGcag2FtVcVCagkamUgW4XdcSJTSpc86kwV632KdHyK6vJFc6ey5CQGmiQrGXBAYMob28LxSYiFZpSayrqfGf)eyhBzFey)veSP7P2IkAX5dcXigb(nc6K6vjOtGLZPcYGOgbgVPjB6e4zJrEadcad7VPxHxoatDaB2yKVq7XrGDSL9rGhIBr14OohRttmsDurqNalNtfKbrncSJTSpc8lRICM(T84jW4nnztNahjaB0w5Lvrot)wE8flXCKhpGbjGz(YlwXsArBTEKcGfbadQbyOHgGrHmNLAPISVUMCnDbrbWGeWOqMZsTur2xxtUMUScTN3dyQdy84bbghdheT5lVypPEvIrQZve0jWo2Y(iWZGhtg6pABey5CQGmiQrmsDOmbDcSJTSpc8kFFULhV23TRqGLZPcYGOgXi1Hkc6eyhBzFe4kzyOFLCt7jWY5ubzquJyK6XpbDcSJTSpcmU7DKNBYq7)7ibJalNtfKbrnIrQd1iOtGDSL9rG5idb9hTncSCovqge1igPoxGGobwoNkidIAey8MMSPtGNng5bmiamS)MEfE5am1bSzJr(cThhb2Xw2hbEg8JJ841VTjhcXi1H6iOtGDSL9rGDnnYoKv3tnE7kpbwoNkidIAeJuVkQrqNalNtfKbrncmEtt20jWtKqqVcoQV8I2sAbWuhW4Xdadn0aSzJrEadcad7VPxHxoatDaB2yKVq7XbyqcyOeWojotxj1unnvPwhCldcGbjGnAR8YQiNPFlp(ILyoYJhWGeWgTvEzvKZ0VLhFzL5kFuNkiagAObyNeNPRKAQMMQOev2MUpbWGeWIeGrHmNf6(47(f9ezJvquamibSzJrEadcad7VPxHxoatDaB2yKVq7XbyqbaZXw2xHJme04MM2Vrb7VPxHxoaJRbmUcWqbGHgAaML0I2A9ifatDaRkQrGDSL9rGRKHXmxrt10ueJuVAvc6ey5CQGmiQrGXBAYMob2Xwwt0Yj0P8aweaSQagKawKaSf5KzV8szJfCoEZdCi7RX9nBKBKhV(Tn5q(IWLiPIImiWo2Y(iWyFRjeJuVkQiOtGLZPcYGOgbgVPjB6eyhBznrlNqNYdyraWQcyqcyrcWwKtM9YlLnwW54npWHSVg33SrUrE8632Kd5lcxIKkkYaWGeWWDhgDLRujdJzUIMQPPktKqqVcoQV8I2sAbWIaG9ksiOnF5f7bmibmucy4O(YlVEUo2Y(8aGfbadvfOcWqdnaB0w5JUUYjbnvttvSeZrE8agkiWo2Y(iWuigoQSXigPEvUIGobwoNkidIAey8MMSPtGNng5bmiamS)MEfE5am1bSzJr(cThhb2Xw2hb(nrcABDfIrQxfktqNalNtfKbrncSJTSpcmDF8D)IMknHaJ30KnDcS5b5SIhuI6ALvgU1BroNkidadsadLagfYCwO7JV7x0tKnwbrbWGeWOqMZcDF8D)IEISXkRq759aM6a2SXipGXjGHsaRMVPtfKcnLEFnUFdWGcag2FtVcVCagkamUgW4XdadsalsagfYCwQKHH(vYnTVScTN3dyOHgGrHmNf6(47(f9ezJvwH2Z7bmibStIZ0vsnvttvuIkBt3NayOGaJJHdI28LxSNuVkXi1Rcve0jWY5ubzquJa7yl7JaZrgcACtt73GaJ30KnDc8eje0RGJ6lVOTKwam1bmE8aWGeWMng5bmiamS)MEfE5am1bSzJr(cThhbghdheT5lVypPEvIrQxn(jOtGLZPcYGOgb2Xw2hbEDfRx9BBYHqGXBAYMobMczolwQO7P2Ik6xr8T8MJ5aWubyCfGHgAa2OTYhDDLtcAQMMQyjMJ84jW4y4GOnF5f7j1Rsms9Qqnc6ey5CQGmiQrGXBAYMobE0w5JUUYjbnvttvSeZrE8eyhBzFey6(47(fnvAcXi1RYfiOtGLZPcYGOgb2Xw2hb(Lvrot)wE8ey8MMSPtGxzUYh1PccGbjGz(YlwXsArBTEKcGfbadQbyOHgGrHmNLAPISVUMCnDbrHaJJHdI28LxSNuVkXi1Rc1rqNalNtfKbrncmEtt20jWNeNPRKAQMMQ8rxx5KaGbjGnBmYdyraWQ5B6ubPqtP3xJ73amUgWqfGbjGnAR8YQiNPFlp(Yk0EEpGfbadQamUgW4XdcSJTSpcCLmmM5kAQMMIyK6Oc1iOtGDSL9rGXrDowN(jWY5ubzquJyK6OQkbDcSCovqge1iWo2Y(iWCKHGg300(niW4nnztNapBmYdyqayy)n9k8YbyQdyZgJ8fApocmogoiAZxEXEs9QeJuhvOIGobwoNkidIAey8MMSPtGxKtM9YlLnwW54npWHSVg33SrUrE8632Kd5lcxIKkkYGa7yl7JaxjdJzUIMQPPigPoQ4kc6ey5CQGmiQrGDSL9rGP7JV7x0uPjey8MMSPtGPqMZcDF8D)IEISXkikagAObyZgJ8ageaMJTSVchziOXnnTFJc2FtVcVCaweaSzJr(cThhGbfaSQqfGHgAa2OTYhDDLtcAQMMQyjMJ84bm0qdWOqMZsLmm0VsUP9LvO98EcmogoiAZxEXEs9QeJuhvqzc6ey5CQGmiQrGDSL9rGxxX6v)2MCieyCmCq0MV8I9K6vjgPoQGkc6ey5CQGmiQrGXBAYMob(K4mDLut10uLADWTmiagKa2OTYlRICM(T84lwI5ipEadn0aStIZ0vsnvttvuIkBt3NayOHgGDsCMUsQPAAQYhDDLtcagKa2SXipGfbadQqncSJTSpcCLmmM5kAQMMIyeJat1ke0j1RsqNalNtfKbrncSJTSpc8lRICM(T84jW4nnztNatHmNLAPISVUMCnDzfApVhWGeWqjGrHmNLAPISVUMCnDzfApVhWuhW4Xdadn0aSvMR8rDQGayOGaJJHdI28LxSNuVkXi1rfbDcSCovqge1iWo2Y(iWCKHGg300(niW4nnztNapBmYdyqayy)n9k8YbyQdyZgJ8fApoadsaJczolN85XxX3yV2wxrjpETRO4RBiFbrbWqdnaB2yKhWGaWW(B6v4LdWuhWMng5l0ECageawvudWGeWOqMZYjFE8v8n2RT1vuYJx7kk(6gYxquamibmkK5SCYNhFfFJ9ABDfL841UIIVUH8LvO98EatDaJhpiW4y4GOnF5f7j1RsmsDUIGob2Xw2hbMJme0F02iWY5ubzquJyK6qzc6ey5CQGmiQrGXBAYMobE2yKhWGaWW(B6v4LdWuhWMng5l0ECagKawKamlXCKhpGbjGnrcb9k4O(YlAlPfatDaJhpiWo2Y(iWvYWyMROPAAkIrQdve0jWY5ubzquJaJ30KnDc8SXipGbbGH930RWlhGPoGnBmYxO94iWo2Y(iWZGFCKhV(Tn5qigPE8tqNa7yl7JapdEmzO)OTrGLZPcYGOgXi1HAe0jWY5ubzquJaJ30KnDc8ICYSxEPCY)5XxX3yV2wxrjpETRO4RBiFr4sKurrgagKa2SXipGPoGvZ30PcsHMsVVg3VrGDSL9rGXEiODSL9Pd5Be4q(M(CAHaFMtmsDUabDcSCovqge1iW4nnztNapBmYdyqayy)n9k8YbyQdyZgJ8fApocSJTSpc8qClQgh15yDAIrQd1rqNalNtfKbrncSJTSpc86kwV632KdHaJ30KnDcmfYCwWDVJ8CtgA)FhjyfefadsaJczol4U3rEUjdT)VJeSYk0EEpGPoGvTavagxdy84bbghdheT5lVypPEvIrQxf1iOtGLZPcYGOgb2Xw2hbMUp(UFrtLMqGXBAYMobMczol4U3rEUjdT)VJeScIcGbjGrHmNfC37ip3KH2)3rcwzfApVhWuhWQwGkaJRbmE8GaJJHdI28LxSNuVkXi1RwLGob2Xw2hb210i7qwDp14TR8ey5CQGmiQrms9QOIGobwoNkidIAeyhBzFe41vSE1VTjhcbgVPjB6eykK5SyPIUNAlQOFfX3YBoMdatfGXveyCmCq0MV8I9K6vjgPEvUIGobwoNkidIAey8MMSPtGNng5bmiamS)MEfE5am1bSzJr(cThhGbjGfjaZsmh5XdyqcyOeWMiHGEfCuF5fTL0cGPoGXJhagAObyrcWgTvQKHXmxrt10uflXCKhpGbjGrHmNf6(47(f9ezJvwH2Z7bSiaytKqqVcoQV8I2sAbWGcawvaJRbmE8aWqdnalsa2OTsLmmM5kAQMMQyjMJ84bmibSibyuiZzHUp(UFrpr2yLvO98EadfagAObywslAR1Juam1bSQCbadsalsa2OTsLmmM5kAQMMQyjMJ84jWo2Y(iWvYWyMROPAAkIrQxfktqNalNtfKbrncSJTSpcmhziOXnnTFdcmogoiAZxEXEs9Qey8MMSPtGNng5bmiamS)MEfE5am1bSzJr(cThhGbjGHsalsa2ICYSxEPCY)5XxX3yV2wxrjpETRO4RBiFroNkidadn0aSzJrEatDaRMVPtfKcnLEFnUFdWqbbEipEtfl7JahpMawSgbWg9fzdWI61eaRU8FE8v8nwKFad91vuYJhWIikk(6gYZnG9jTsigGH93amUOmeamuVPP9Bay5eWI1iawL(ISbyDnzXUcG1hGb1xJrEaBUnnGn684bSVlaw8ycyXAeaB0awuVMay1L)ZJVIVXI8dyOVUIsE8awerrXx3qEalwJayF0gjmamS)gGXfLHaGH6nnTFdalNawSgzbSzJrEalFaJscDfaZIkagUFdW6jGfprF8D)cGPwAcG1lGXf7kwVagSTjhcXi1Rcve0jWY5ubzquJa7yl7JaZrgcACtt73GaJJHdI28LxSNuVkbgVPjB6e4zJrEadcad7VPxHxoatDaB2yKVq7XbyqcylYjZE5LYj)NhFfFJ9ABDfL841UIIVUH8f5CQGmamibmC3Hrx5kZveOuE8ABDLYk0EEpGfbadLa2SXipGXjGHsaRMVPtfKcnLEFnUFdWGcag2FtVcVCagkamUgW4XdadfagKagU7WORCfZxTTUszfApVhWIaGHsaB2yKhW4eWqjGvZ30PcsHMsVVg3Vbyqbad7VPxHxoadfagxdy84bGHcadsadLawKamZdYzL3ejOT1vkY5ubzayOHgGzEqoR8MibTTUsroNkidadsad3Dy0vUYBIe026kLvO98EalcagkbSzJrEaJtadLawnFtNkifAk9(AC)gGbfamS)MEfE5amuayCnGXJhagkamuqGhYJ3uXY(iWr0PffWQl)NhFfFJf5hWqFDfL84bSiIIIVUH8awFHyagxugcagQ300(naSCcyXAKfWS1vEaZxbW6dWWDhgDLJBaRTOYwjFbWERvamKppEaJlkdbad1BAA)gawobSynYcyyKDLZaSzJrEaZPBKZaS8bm5Ae(OaM1a2J8MNhGzrfaZPBKZaSEcywslawqMgGn7fW8lgG1talwJSaMTUYdywdy4MwaSEobmC3Hrx5igPE14NGobwoNkidIAey8MMSPtGNng5bmiamS)MEfE5am1bSzJr(cThhb2Xw2hb(nrcABDfIrQxfQrqNalNtfKbrncSJTSpc8lRICM(T84jW4nnztNapAR8YQiNPFlp(YkZv(OovqamibSibyuiZzb39oYZnzO9)DKGvquiW4y4GOnF5f7j1Rsms9QCbc6eyhBzFe4v((ClpETVBxHalNtfKbrnIrQxfQJGob2Xw2hbUsgg6xj30EcSCovqge1igPoQqnc6ey5CQGmiQrGXBAYMobosagfYCwWDVJ8CtgA)FhjyfefcSJTSpcmU7DKNBYq7)7ibJyK6OQkbDcSCovqge1iW4nnztNatHmNf6(47(f9ezJvquam0qdWMng5bmiamhBzFfoYqqJBAA)gfS)MEfE5aSiayZgJ8fApoadn0amkK5SG7Eh55Mm0()osWkikeyhBzFey6(47(fnvAcXi1rfQiOtGLZPcYGOgb2Xw2hbEDfRx9BBYHqGXXWbrB(Yl2tQxLyK6OIRiOtGLZPcYGOgbgVPjB6e4rBLkzymZv0unnvzL5kFuNkieyhBzFe4kzymZv0unnfXi1rfuMGobwoNkidIAeyhBzFe4xwf5m9B5XtGXBAYMobMczol1sfzFDn5A6cIcbghdheT5lVypPEvIrmIrGRj7N9rQJkudvvrnUaQf)e4k(E5X)e4i6icxC94r9ikOiGbyOhvaSKwPxdWM9cyrwzfCtt5wKbSv4sKCLbG9nTayoI10Ujdadh1pE5laOJ48eaRkueWq9(QjRjdalYMhKZkXRidywdyr28GCwjEvKZPcYiYaMBagupINmIbmuwnouuaqdGoIoIWfxpEupIckcyag6rfalPv61aSzVawKFlYa2kCjsUYaW(MwamhXAA3KbGHJ6hV8fa0rCEcGvfkdfbmuVVAYAYaWGtAuhW(yN5XbyXhGznGfXioGnYA5N9byTISU1lGHsorbGHYQXHIcaAa0r0reU46XJ6ruqradWqpQayjTsVgGn7fWImE8rgWwHlrYvga230cG5iwt7MmamCu)4LVaGoIZtaSQOgueWq9(QjRjdalYFJeOYBuIxrgWSgWI83ibQ8gL4vroNkiJidyOevXHIca6iopbWQYvqrad17RMSMmam4Kg1bSp2zECaw8bywdyrmIdyJSw(zFawRiRB9cyOKtuayOSACOOaGoIZtaSQqzOiGH69vtwtgagCsJ6a2h7mpoal(amRbSigXbSrwl)SpaRvK1TEbmuYjkamuwnouuaqhX5jawvOckcyOEF1K1KbGbN0OoG9XoZJdWIpaZAalIrCaBK1Yp7dWAfzDRxadLCIcadLvJdffa0aOJOJiCX1Jh1JOGIagGHEubWsALEnaB2lGfzQwjYa2kCjsUYaW(MwamhXAA3KbGHJ6hV8fa0rCEcGvfkdfbmuVVAYAYaWI8ICYSxEPeVImGznGf5f5KzV8sjEvKZPcYiYagkRghkkaOJ48eaRkubfbmuVVAYAYaWGtAuhW(yN5XbyXhGznGfXioGnYA5N9byTISU1lGHsorbGHsUkouuaqhX5jawvOckcyOEF1K1KbGfzZdYzL4vKbmRbSiBEqoReVkY5ubzezadLOkouuaqhX5jawvOckcyOEF1K1KbGf5f5KzV8sjEfzaZAalYlYjZE5Ls8QiNtfKrKbmuwnouuaqdGoIoIWfxpEupIckcyag6rfalPv61aSzVawKXbXRjrgWwHlrYvga230cG5iwt7MmamCu)4LVaGoIZtaSQOgueWq9(QjRjdadoPrDa7JDMhhGfFaM1aweJ4a2iRLF2hG1kY6wVagk5efagkRghkkaOJ48eaRkQGIagQ3xnznzayWjnQdyFSZ84aS4dWSgWIyehWgzT8Z(aSwrw36fWqjNOaWqz14qrbaDeNNayvHkOiGH69vtwtgagCsJ6a2h7mpoal(amRbSigXbSrwl)SpaRvK1TEbmuYjkamuwnouuaqhX5jaw14hkcyOEF1K1KbGbN0OoG9XoZJdWIpaZAalIrCaBK1Yp7dWAfzDRxadLCIcadLvJdffa0aOJh0k9AYaWGAaMJTSpalKV9fa0eyLTNzqiWXBadgzRL18aGb1pYzYcGoEdyreeEK3amOg3agQqnuvfanaAhBzFFrzfCtt5geQ4SMVPtfeUpNwurtP3xJ734Uvu9ILtUR5berLJTSVcDF8D)IMknPG734UMhqeTeErLJTSVY6kwV632KdPG734g33iTSpvMhKZk09X39lAQ0ea0o2Y((IYk4MMYniuX5Jqt3Nwrma0o2Y((IYk4MMYniuXjvBwqg6zWJjJk5XRToU8aq7yl77lkRGBAk3GqfNZG8rXRpna0o2Y((IYk4MMYniuXP5R2wxH7CQAroz2lVu(gjm7Lx0cnLSFr4sKurrgaODSL99fLvWnnLBqOIZ3ejOT1vaqdG2Xw23dHkoPrGsqPGaGoEdyrunG5rfFay(nam0x)4sKmKqjbWQd1lQdyYj0P8q9eWQia2OViBa2ObmlA(a2Sxatj4XK9bmkb7iVayPf5bGrjaM1nG9konDmaZVbGvramSFr2aSv8rgIbyOV(XLa2Ri4CMyaJczo)caAhBzFpeQ40w)4sKmKqP841F024oNQIK5lVyL81kbpMSaODSL99qOItKx0Pj0CFoTOkEUnKJxYD1d5T8I9AShcCNtvuiZzb39oYZnzO9)DKGvquqdnQ(FiNjFutVcTN3RoxHAaODSL99qOItKx0Pj0pa64D8gWINkbpgGnDCE8awSgzbSrJqzagYzzaWI1iawuVMaykigGXflFFULhpGfr2TRayJUYXnG1lGLtaZIkagU7WORCaw(aM1nGf6JhWSgWgsWJbythNhpGfRrwalEAJqzfalEmbSRpbW6jGzrLxamCFJ0Y(EaZxbWCQGaywdy0IbyvslAEaMfvaSQOgG9cUVXdybrQ4X4gWSOcG9jnGnDS8awSgzbS4PncLbyoI10ULypeIvaqhVJ3aMJTSVhcvCEsLzJCd9kFhQjCNtvFJeOYBuoPYSrUHELVd1eirjfYCww57ZT841(UDLcIcAOH7om6kxzLVp3YJx772vkRq759rOkQHgAMV8IvSKw0wRhPOE14hfaODSL99qOItShcAhBzF6q(g3NtlQWJhaTJTSVhcvCI9qq7yl7thY34(CArfvRWDov5ylRjA5e6uE15kinpiNvOYD86EQvwjwroNkida0o2Y(EiuXj2dbTJTSpDiFJ7ZPfvVXDov5ylRjA5e6uE15kiJK5b5ScvUJx3tTYkXkY5ubzaG2Xw23dHkoXEiODSL9Pd5BCFoTOcheVMWDov5ylRjA5e6u(iGka0o2Y(EiuXPVy)eT17kNbGgaTJTSVVq1kQEzvKZ0VLhp34y4GOnF5f7vvL7CQIczol1sfzFDn5A6Yk0EEpKOKczol1sfzFDn5A6Yk0EEV684bAOTYCLpQtfeuaG2Xw23xOAfiuXjhziOXnnTFdUXXWbrB(Yl2RQk35u1SXipey)n9k8YP(SXiFH2JdskK5SCYNhFfFJ9ABDfL841UIIVUH8fef0qB2yKhcS)MEfE5uF2yKVq7XbrvudskK5SCYNhFfFJ9ABDfL841UIIVUH8fefiPqMZYjFE8v8n2RT1vuYJx7kk(6gYxwH2Z7vNhpaq7yl77luTceQ4KJme0F02aq7yl77luTceQ4SsggZCfnvttXDovnBmYdb2FtVcVCQpBmYxO94GmswI5ipEiNiHGEfCuF5fTL0I684baAhBzFFHQvGqfNZGFCKhV(Tn5q4oNQMng5Ha7VPxHxo1Nng5l0ECaODSL99fQwbcvCodEmzO)OTbG2Xw23xOAfiuXj2dbTJTSpDiFJ7ZPfvN5CNtvlYjZE5LYj)NhFfFJ9ABDfL841UIIVUH8fHlrsffza5SXiV618nDQGuOP07RX9BaODSL99fQwbcvCoe3IQXrDowNM7CQA2yKhcS)MEfE5uF2yKVq7XbG2Xw23xOAfiuX56kwV632KdHBCmCq0MV8I9QQYDovrHmNfC37ip3KH2)3rcwbrbskK5SG7Eh55Mm0()osWkRq759QxTavCnpEaG2Xw23xOAfiuXjDF8D)IMknHBCmCq0MV8I9QQYDovrHmNfC37ip3KH2)3rcwbrbskK5SG7Eh55Mm0()osWkRq759QxTavCnpEaG2Xw23xOAfiuXPRPr2HS6EQXBx5bq7yl77luTceQ4CDfRx9BBYHWnogoiAZxEXEvv5oNQOqMZILk6EQTOI(veFlV5youXvaODSL99fQwbcvCwjdJzUIMQPP4oNQMng5Ha7VPxHxo1Nng5l0ECqgjlXCKhpKOCIec6vWr9Lx0wslQZJhOHwKgTvQKHXmxrt10uflXCKhpKuiZzHUp(UFrpr2yLvO98(imrcb9k4O(YlAlPfOqvUMhpqdTinARujdJzUIMQPPkwI5ipEiJefYCwO7JV7x0tKnwzfApVhfOHML0I2A9if1RYfGmsJ2kvYWyMROPAAQILyoYJhaD8gWIhtalwJayJ(ISbyr9AcGvx(pp(k(glYpGH(6kk5XdyreffFDd55gW(KwjedWW(BagxugcagQ300(naSCcyXAeaRsFr2aSUMSyxbW6dWG6RXipGn3MgWgDE8a23falEmbSyncGnAalQxtaS6Y)5XxX3yr(bm0xxrjpEalIOO4RBipGfRraSpAJegag2FdW4IYqaWq9MM2VbGLtalwJSa2SXipGLpGrjHUcGzrfad3Vby9eWINOp(UFbWulnbW6fW4IDfRxad22KdbaTJTSVVq1kqOItoYqqJBAA)gCJJHdI28LxSxvvUZPQzJrEiW(B6v4Lt9zJr(cThhKOmslYjZE5LYj)NhFfFJ9ABDfL841UIIVUH8OH2SXiV618nDQGuOP07RX9BOaaD8gWIOtlkGvx(pp(k(glYpGH(6kk5XdyreffFDd5bS(cXamUOmeamuVPP9Bay5eWI1ilGzRR8aMVcG1hGH7om6kh3awBrLTs(cG9wRayiFE8agxugcagQ300(naSCcyXAKfWWi7kNbyZgJ8aMt3iNby5dyY1i8rbmRbSh5nppaZIkaMt3iNby9eWSKwaSGmnaB2lG5xmaRNawSgzbmBDLhWSgWWnTay9Ccy4UdJUYbG2Xw23xOAfiuXjhziOXnnTFdUXXWbrB(Yl2RQk35u1SXipey)n9k8YP(SXiFH2JdYf5KzV8s5K)ZJVIVXETTUIsE8AxrXx3qEiXDhgDLRmxrGs5XRT1vkRq759raLZgJ8XhkR5B6ubPqtP3xJ73Gcy)n9k8YHcUMhpqbK4UdJUYvmF126kLvO98(iGYzJr(4dL18nDQGuOP07RX9BqbS)MEfE5qbxZJhOasugjZdYzL3ejOT1vqdnZdYzL3ejOT1vGe3Dy0vUYBIe026kLvO98(iGYzJr(4dL18nDQGuOP07RX9BqbS)MEfE5qbxZJhOafaODSL99fQwbcvC(MibTTUc35u1SXipey)n9k8YP(SXiFH2JdaTJTSVVq1kqOIZxwf5m9B5XZnogoiAZxEXEvv5oNQgTvEzvKZ0VLhFzL5kFuNkiqgjkK5SG7Eh55Mm0()osWkikaODSL99fQwbcvCUY3NB5XR9D7kaODSL99fQwbcvCwjdd9RKBApaAhBzFFHQvGqfN4U3rEUjdT)VJemUZPQirHmNfC37ip3KH2)3rcwbrbaTJTSVVq1kqOIt6(47(fnvAc35uffYCwO7JV7x0tKnwbrbn0Mng5HWXw2xHJme04MM2Vrb7VPxHxUimBmYxO94qdnkK5SG7Eh55Mm0()osWkikaODSL99fQwbcvCUUI1R(Tn5q4ghdheT5lVyVQQaODSL99fQwbcvCwjdJzUIMQPP4oNQgTvQKHXmxrt10uLvMR8rDQGaG2Xw23xOAfiuX5lRICM(T845ghdheT5lVyVQQCNtvuiZzPwQi7RRjxtxquaqdG2Xw23xWJxvuFv6(4oNQmpiNvmzPFDp1YX78cTCwroNkidiNng5vF2yKVq7XbG2Xw23xWJhcvCsf6EONiBmUZPkkK5SG7Eh55Mm0()osWkikaODSL99f84HqfN(HL3wpOXEiWDovrHmNfC37ip3KH2)3rcwbrbaTJTSVVGhpeQ4CMRqf6EWDovrHmNfC37ip3KH2)3rcwbrbaTJTSVVGhpeQ4mK8rTxhpJm4PLZaq7yl77l4XdHkoPCEDp12MyoEUZPkC3Hrx5kCKHGg300(nktKqqVcoQV8I2sAjc84baAhBzFFbpEiuXjLSVSCKhp35uffYCwWDVJ8CtgA)Fhjyfef0qZsArBTEKI6v5ka0o2Y((cE8qOItAeOeukiaODSL99f84HqfNkTL9XDovnt(OMEfApVx94h1qdnkK5SG7Eh55Mm0()osWkikaODSL99f84HqfNZG8rXRpnUZZKDrumDovHJ63jH84HmsFJeOYBuuqEdjiAzruSSpUZPkuoBmYRoud1qdnC3Hrx5k4U3rEUjdT)VJeSYk0EEV684bkGeLFJeOYBuuqEdjiAzruSSp0q7BKavEJsTo4wge93HAYzOaaTJTSVVGhpeQ408vBRRWDovnBmYdb2FtVcVCQpBmYxO94GCroz2lVu(gjm7Lx0cnLSFr4sKurrgqA(QT1vkRq759QZJhqI7om6kxzg8vkRq759QZJhqIshBznrlNqNYhHQOHMJTSMOLtOt5vvfslPfT16rkraQ4AE8afaODSL99f84HqfNZGVc3H8enEOcvqf35u1SXipey)n9k8YP(SXiFH2JdsZxTTUsbrbYf5KzV8s5BKWSxErl0uY(fHlrsffzaPL0I2A9iLiaL5AE8aaTJTSVVGhpeQ4KJme0F024oNQCSL1eTCcDkVQQqA(YlwXsArBTEKI6ZgJ8XhkR5B6ubPqtP3xJ73Gcy)n9k8YHcUMhpaq7yl77l4XdHkoP7JV7x0uPjCNtvo2YAIwoHoLxvvinF5fRyjTOTwpsr9zJr(4dL18nDQGuOP07RX9BqbS)MEfE5qbxZJhaODSL99f84HqfNRRy9QFBtoeUZPkhBznrlNqNYRQkKMV8IvSKw0wRhPO(SXiF8HYA(Movqk0u6914(nOa2FtVcVCOGR5Xda0o2Y((cE8qOIt)veSP7P2IkAX5dc35uL5lVyLr(MFyjcQIFa0aODSL99fCq8AIQxwf5m9B5XZnogoiAZxEXEvv5oNQmpiNvIgBS(RPstkY5ubzajfYCwQLkY(6AY10LvO98EiPqMZsTur2xxtUMUScTN3RopEaG2Xw23xWbXRjqOIZkzyOFLCt7bq7yl77l4G41eiuX5kFFULhV23TRaG2Xw23xWbXRjqOItC37ip3KH2)3rcgaAhBzFFbheVMaHkoRKHXmxrt10uCNtvtKqqVcoQV8I2sArDE8aaTJTSVVGdIxtGqfN4OohRt)aODSL99fCq8AceQ4KcXWrLng35u1OTYhDDLtcAQMMQyjMJ84HeLJ2k5zYEEqtfezKhF5nhZH6Ocn0gTv(ORRCsqt10uLvO98E15XduaG2Xw23xWbXRjqOItSV1eUZPQrBLp66kNe0unnvXsmh5XdG2Xw23xWbXRjqOIZH4wunoQZX60CNtvZgJ8qG930RWlN6ZgJ8fApoa0o2Y((coiEnbcvCsHy4OYgJ7CQch1xE51Z1Xw2NhIaQkqfK4UdJUYvQKHXmxrt10uLjsiOxbh1xErBjTeHxrcbT5lVyF8Hka0o2Y((coiEnbcvCod(XrE8632KdH7CQA2yKhcS)MEfE5uF2yKVq7XbG2Xw23xWbXRjqOItSV1eUZPkC3Hrx5kvYWyMROPAAQYeje0RGJ6lVOTKwIWRiHG28LxSp(qfKMhKZkEqjQRvwz4wVf5CQGmaq7yl77l4G41eiuXjhziOXnnTFdUXXWbrB(Yl2RQk35u1SXipey)n9k8YP(SXiFH2JdYjsiOxbh1xErBjTOopEajkxKtM9YlLt(pp(k(g7126kk5XRDffFDd5lcxIKkkYasC3Hrx5kZveOuE8ABDLYk0EEpK4UdJUYvmF126kLvO98E0qlslYjZE5LYj)NhFfFJ9ABDfL841UIIVUH8fHlrsffzGca0o2Y((coiEnbcvCwjdJzUIMQPP4oNQI0OTsLmmM5kAQMMQyjMJ84bq7yl77l4G41eiuXjfIHJkBmUZPkugPtIZ0vsnvttv(ORRCsan0IK5b5SsLmmM5k68MiF2xroNkiduajU7WORCLkzymZv0unnvzIec6vWr9Lx0wslr4vKqqB(Yl2hFOcaTJTSVVGdIxtGqfNyFRjCNtv4UdJUYvQKHXmxrt10uLjsiOxbh1xErBjTeHxrcbT5lVyF8Hka0o2Y((coiEnbcvCYrgc6pABaODSL99fCq8AceQ4Cg8yYq)rBdaTJTSVVGdIxtGqfNUMgzhYQ7PgVDLhaTJTSVVGdIxtGqfNVjsqBRRaG2Xw23xWbXRjqOIZxwf5m9B5XZnogoiAZxEXEvv5oNQwzUYh1PccKMhKZkrJnw)1uPjf5CQGmG08LxSIL0I2A9iLiWfaq7yl77l4G41eiuXj23AcaAhBzFFbheVMaHko5idbnUPP9BWnogoiAZxEXEvv5oNQMng5Ha7VPxHxo1Nng5l0ECqIYf5KzV8s5K)ZJVIVXETTUIsE8AxrXx3q(IWLiPIImGe3Dy0vUYCfbkLhV2wxPScTN3djU7WORCfZxTTUszfApVhn0I0ICYSxEPCY)5XxX3yV2wxrjpETRO4RBiFr4sKurrgOaaTJTSVVGdIxtGqfNVSkYz63YJNBCmCq0MV8I9QQYDovTYCLpQtfea0o2Y((coiEnbcvCs3hF3VOPst4ghdheT5lVyVQQaODSL99fCq8AceQ4CDfRx9BBYHWnogoiAZxEXEvvbqdG2Xw23xoZv9MibTTUcaAhBzFF5mhcvCoxrGs5XRT1v4oNQIefYCwQKHH(vYnTVScTN3JgAuiZzPsgg6xj30(Yk0EEpK4UdJUYv4idbnUPP9BuwH2Z7bq7yl77lN5qOItZxTTUc35uvKOqMZsLmm0VsUP9LvO98E0qJczolvYWq)k5M2xwH2Z7He3Dy0vUchziOXnnTFJYk0EEpaAa0o2Y((YBQgIBr14OohRtZDovnBmYdb2FtVcVCQpBmYxO94aq7yl77lVbHkoFzvKZ0VLhp34y4GOnF5f7vvL7CQksJ2kVSkYz63YJVyjMJ84H08LxSIL0I2A9iLia1qdnkK5SulvK911KRPlikqsHmNLAPISVUMCnDzfApVxDE8aaTJTSVV8geQ4Cg8yYq)rBdaTJTSVV8geQ4CLVp3YJx772vaq7yl77lVbHkoRKHH(vYnThaTJTSVV8geQ4e39oYZnzO9)DKGbG2Xw23xEdcvCYrgc6pABaODSL99L3GqfNZGFCKhV(Tn5q4oNQMng5Ha7VPxHxo1Nng5l0ECaODSL99L3GqfNUMgzhYQ7PgVDLhaTJTSVV8geQ4SsggZCfnvttXDovnrcb9k4O(YlAlPf15Xd0qB2yKhcS)MEfE5uF2yKVq7Xbjkpjotxj1unnvPwhCldcKJ2kVSkYz63YJVyjMJ84HC0w5Lvrot)wE8LvMR8rDQGGgANeNPRKAQMMQOev2MUpbYirHmNf6(47(f9ezJvquGC2yKhcS)MEfE5uF2yKVq7XbfCSL9v4idbnUPP9BuW(B6v4LJR5kuGgAwslAR1JuuVkQbG2Xw23xEdcvCI9TMWDov5ylRjA5e6u(iufYiTiNm7LxkBSGZXBEGdzFnUVzJCJ841VTjhYxeUejvuKbaAhBzFF5niuXjfIHJkBmUZPkhBznrlNqNYhHQqgPf5KzV8szJfCoEZdCi7RX9nBKBKhV(Tn5q(IWLiPIImGe3Dy0vUsLmmM5kAQMMQmrcb9k4O(YlAlPLi8ksiOnF5f7HeL4O(YlVEUo2Y(8qeqvbQqdTrBLp66kNe0unnvXsmh5XJca0o2Y((YBqOIZ3ejOT1v4oNQMng5Ha7VPxHxo1Nng5l0ECaODSL99L3GqfN09X39lAQ0eUXXWbrB(Yl2RQk35uL5b5SIhuI6ALvgU1BroNkidirjfYCwO7JV7x0tKnwbrbskK5Sq3hF3VONiBSYk0EEV6ZgJ8XhkR5B6ubPqtP3xJ73Gcy)n9k8YHcUMhpGmsuiZzPsgg6xj30(Yk0EEpAOrHmNf6(47(f9ezJvwH2Z7H8K4mDLut10ufLOY209jOaaTJTSVV8geQ4KJme04MM2Vb34y4GOnF5f7vvL7CQAIec6vWr9Lx0wslQZJhqoBmYdb2FtVcVCQpBmYxO94aq7yl77lVbHkoxxX6v)2MCiCJJHdI28LxSxvvUZPkkK5SyPIUNAlQOFfX3YBoMdvCfAOnAR8rxx5KGMQPPkwI5ipEa0o2Y((YBqOIt6(47(fnvAc35u1OTYhDDLtcAQMMQyjMJ84bq7yl77lVbHkoFzvKZ0VLhp34y4GOnF5f7vvL7CQAL5kFuNkiqA(YlwXsArBTEKseGAOHgfYCwQLkY(6AY10fefa0o2Y((YBqOIZkzymZv0unnf35u1jXz6kPMQPPkF01voja5SXiFeQ5B6ubPqtP3xJ734Aub5OTYlRICM(T84lRq759raQ4AE8aaTJTSVV8geQ4eh15yD6haTJTSVV8geQ4KJme04MM2Vb34y4GOnF5f7vvL7CQA2yKhcS)MEfE5uF2yKVq7XbG2Xw23xEdcvCwjdJzUIMQPP4oNQwKtM9YlLnwW54npWHSVg33SrUrE8632Kd5lcxIKkkYaaTJTSVV8geQ4KUp(UFrtLMWnogoiAZxEXEvv5oNQOqMZcDF8D)IEISXkikOH2SXipeo2Y(kCKHGg300(nky)n9k8YfHzJr(cThhuOkuHgAJ2kF01vojOPAAQILyoYJhn0OqMZsLmm0VsUP9LvO98Ea0o2Y((YBqOIZ1vSE1VTjhc34y4GOnF5f7vvfaTJTSVV8geQ4SsggZCfnvttXDovDsCMUsQPAAQsTo4wgeihTvEzvKZ0VLhFXsmh5XJgANeNPRKAQMMQOev2MUpbn0ojotxj1unnv5JUUYjbiNng5JauHAe4xrWK6OcQGkIrmcba]] )


end