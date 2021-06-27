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


    spec:RegisterPack( "Survival", 20210627, [[d4K3Hbqisu9iHkIljuvTjfLpjuPrbrCkisRIefVsrAwiPULqvzxs8lKKHbb6ysILPi6zqqMgeqxtrW2eQIVPiuJJeL6CibP1bb4DcvKY8ec3Je2hsOdQielKe5HibUOqfPAJkcj(ijkXives5KcvuRur1lrckZuOc3uriv7us1pfQiPHkurILsIs6PanviQVIeunwKGyVi(lPgmkhMQfJkpgQjRWLj2mGpJQgTKYPfTAfHKEneA2cUnK2Tk)wQHtshhcQLR0Zv10PCDKA7ssFxinEHOZluwVqvA(ir7h0KkeKjGd3es9jrWjRGGXZKtCPs8mHjrikucOftviGQogrNxiGNJkeqq6TAw1deqvpwO9bbzc430lwiGXjqwnZuFeavuXNwnAUcUrP6tu6GBzF41bmQ(eftfbKJodwC(iCeWHBcP(Ki4KvqW4zYjUujEMWKi0etaDARwVeqWeLciG1YXqochbCipMacsVvZQEaYMOrFMSW5ZPpbYMCIPgYMebNScbmKV9eKjGN5eKj1RqqMa6yl7Ja(MibTTUkbuoNlidIseJuFscYeq5CUGmikraXBAYMobu5qghnaqjAgg6xn30(YkOEEpKrjLqghnaqjAgg6xn30(YkOEEpKndYWDhgD0RGygcACJI63OScQN3taDSL9rabwrI384126QeJuhHiitaLZ5cYGOebeVPjB6eqLdzC0aaLOzyOF1Ct7lRG659qgLuczC0aaLOzyOF1Ct7lRG659q2mid3Dy0rVcIziOXnkQFJYkOEEpb0Xw2hb08vBRRsmIrahcGthmcYK6viitaDSL9rarPJ34nieq5CUGmikrms9jjitaLZ5cYGOeb0Xw2hb0w)qy6mKXBE86VwBeWH84nvTSpcOYsdzEnXhqMFdid51peModz8kqw94uOaitobnLNAilQazJ(IRbzJgYSA5dza9czQbpMSpKXjyN(filT4oGmobYSUHSx1rrJbz(nGSOcKH9lUgKTIpYqmid51pegYEvbNajgY4Oba(cbeVPjB6eqLdzMV8IvYxRg8yYsmsDeIGmb0Xw2hbK(fDAc6taLZ5cYGOeXi1rGeKjGY5CbzquIa6yl7JaI9qq7yl7thY3iGH8n95OcbepEIrQpbcYeq5CUGmikraXBAYMob0Xwwv0YjOP8qweqgcbzZGmZdYzfUChVUb0QReRiNZfKbb0Xw2hbe7HG2Xw2NoKVrad5B6ZrfcixRsms94HGmbuoNlidIseq8MMSPtaDSLvfTCcAkpKfbKHqq2mit5qM5b5ScxUJx3aA1vIvKZ5cYGa6yl7JaI9qq7yl7thY3iGH8n95Ocb8nIrQpXeKjGY5CbzquIaI30KnDcOJTSQOLtqt5HmkcztsaDSL9raXEiODSL9Pd5BeWq(M(CuHaIdIxvigPUYMGmb0Xw2hb0xSFI26DLZiGY5CbzquIyeJaQUcUr5CJGmPEfcYeq5CUGmikraBvc4lwcqaXBAYMob08GCwbTp(UFrZLMuKZ5cYGaoKhVPQL9raNtFcKn5etnKnjcozfcyvF1NJkequo9(AC)gb0Xw2hbSQVPZfecyvpqlAj8cb0Xw2xzDvRx9BBIOuW9BeWQEGwiGo2Y(kO9X39lAU0KcUFJyK6tsqMa6yl7Ja(0OO9PvfJakNZfKbrjIrQJqeKjGo2Y(iGCTzbzObcEmzenpET1rMhbuoNlidIseJuhbsqMakNZfKbrjciEtt20jGl9ja9YlLVPda9YlAbLt2ViimDQQkdcOJTSpcO5R2wxLyK6tGGmb0Xw2hb8nrcABDvcOCoxqgeLigXiG4G4vfcYK6viitaLZ5cYGOeb0Xw2hb8Lvvot)wE8eq8MMSPtanpiNvQfBS(R5stkY5CbzazZGmoAaGs1uv2xxvUgTScQN3dzZGmoAaGs1uv2xxvUgTScQN3dzraz84bbehdheT5lVypPEfIrQpjbzcOJTSpcy0mm0VAUP9eq5CUGmikrmsDeIGmb0Xw2hbCLVp3YJx772rjGY5CbzquIyK6iqcYeq5CUGmikraXBAYMobeGoe0RGR5lVOTevGSiGmE8Ga6yl7JagnddGCfnxJYrms9jqqMa6yl7JaIR5iUo6taLZ5cYGOeXi1JhcYeq5CUGmikraXBAYMobC0w5RTU6jbnxJYvSeJyE8q2midjq2OTsEMSNh0Cbrg5XxEZXiczraztczusjKnAR81wx9KGMRr5kRG659qweqgpEaziLa6yl7JaYrB4AYgJyK6tmbzcOCoxqgeLiG4nnztNaoAR81wx9KGMRr5kwIrmpEcOJTSpci23QcXi1v2eKjGY5CbzquIaI30KnDciqJPFiBkKH930RWlhKfbKb0y6VG6rsaDSL9rahIB104AoIRJsmsDkucYeqhBzFeqC37ip3KH2)3PdgbuoNlidIseJuVccsqMakNZfKbrjciEtt20jG4A(YlVgyDSL95biJIq2KLjazZGmC3Hrh9krZWaixrZ1OCfa6qqVcUMV8I2subYOiK9QsiOnF5f7HmQGSjjGo2Y(iGC0gUMSXigPELkeKjGY5CbzquIaI30KnDciqJPFiBkKH930RWlhKfbKb0y6VG6rsaDSL9rabc(HyE8632erHyK6vMKGmbuoNlidIseq8MMSPtaXDhgD0RenddGCfnxJYvaOdb9k4A(YlAlrfiJIq2RkHG28LxShYOcYMeYMbzMhKZkEqTMRvxz4wVf5CUGmiGo2Y(iGyFRkeJuVccrqMakNZfKbrjcOJTSpciIziOXnkQFdciEtt20jGanM(HSPqg2FtVcVCqweqgqJP)cQhjKndYaOdb9k4A(YlAlrfilciJhpGSzqgsGSL(eGE5LYj)NhFuFJ9ABDv1841UQQVUr)fbHPtvvzazZGmC3Hrh9kaRiXBE8ABD1YkOEEpKndYWDhgD0Ry(QT1vlRG659qgLuczkhYw6ta6LxkN8FE8r9n2RT1vvZJx7QQ(6g9xeeMovvLbKHuciogoiAZxEXEs9keJuVccKGmbuoNlidIseq8MMSPtavoKnARenddGCfnxJYvSeJyE8eqhBzFeWOzyaKRO5AuoIrQxzceKjGY5CbzquIaI30KnDcisGmLdzNePPJMAUgLR81wx9KaKrjLqMYHmZdYzLOzyaKROZdG(Z(kY5CbzazifYMbz4UdJo6vIMHbqUIMRr5ka0HGEfCnF5fTLOcKrri7vLqqB(Yl2dzubztsaDSL9ra5OnCnzJrms9kXdbzcOCoxqgeLiG4nnztNaI7om6OxjAgga5kAUgLRaqhc6vW18Lx0wIkqgfHSxvcbT5lVypKrfKnjb0Xw2hbe7BvHyK6vMycYeqhBzFeqeZqq)1AJakNZfKbrjIrQxrztqMa6yl7Jace8yYq)1AJakNZfKbrjIrQxHcLGmb0Xw2hb01O07qwDdOXBh9jGY5CbzquIyK6tIGeKjGo2Y(iGVjsqBRRsaLZ5cYGOeXi1NScbzcOCoxqgeLiGo2Y(iGVSQYz63YJNaI30KnDc4kaR81CUGazZGmZdYzLAXgR)AU0KICoxqgq2miZ8LxSILOI2A9ifiJIqMYMaIJHdI28LxSNuVcXi1NCscYeqhBzFeqSVvfcOCoxqgeLigP(KiebzcOCoxqgeLiGo2Y(iGiMHGg3OO(niG4nnztNac0y6hYMczy)n9k8YbzrazanM(lOEKq2midjq2sFcqV8s5K)ZJpQVXETTUQAE8Axv1x3O)IGW0PQQmGSzqgU7WOJEfGvK4npETTUAzfupVhYMbz4UdJo6vmF126QLvq98EiJskHmLdzl9ja9YlLt(pp(O(g7126QQ5XRDvvFDJ(lcctNQQYaYqkbehdheT5lVypPEfIrQpjcKGmbuoNlidIseqhBzFeWxwv5m9B5XtaXBAYMobCfGv(AoxqiG4y4GOnF5f7j1Rqms9jNabzcOCoxqgeLiGo2Y(iGO9X39lAU0eciogoiAZxEXEs9keJuFY4HGmbuoNlidIseqhBzFeW1vTE1VTjIcbehdheT5lVypPEfIrmciE8eKj1RqqMakNZfKbrjciEtt20jGMhKZkMSOVUb0YX78cQCwroNlidiBgKb0y6hYIaYaAm9xq9ijGo2Y(iG18vT7JyK6tsqMakNZfKbrjcOJTSpc4yfFaKRORk)lbciEtt20jG4UQC(zfeJTPFq2mid3Dy0rVYkFFULhV23TJwwb1Z7HmkczvqqiJskHmLdz4UQC(zfeJTPFeWZrfc4yfFaKRORk)lbIrQJqeKjGY5CbzquIaI30KnDciU7WOJEfC37ip3KH2)3PdwzfupVhYOiKHqiib0Xw2hbKl09qdqVXigPocKGmbuoNlidIseq8MMSPtaXDhgD0RG7Eh55Mm0()oDWkRG659qgfHmecbjGo2Y(iG(HL3wpOXEiqms9jqqMakNZfKbrjciEtt20jG4UdJo6vWDVJ8CtgA)FNoyLvq98EiJIqgcHGeqhBzFeqGCfUq3dIrQhpeKjGo2Y(iGHKVM96jQ0dEu5mcOCoxqgeLigP(etqMakNZfKbrjciEtt20jG4UdJo6vqmdbnUrr9BuaOdb9k4A(YlAlrfiJIqgpEqaDSL9ra5CEDdOTnXi(eJuxztqMakNZfKbrjciEtt20jG4UdJo6vWDVJ8CtgA)FNoyLvq98EiJIqw8GGqgLuczwIkAR1JuGSiGSkieb0Xw2hbKt2xweZJNyK6uOeKjGo2Y(iGO0XB8gecOCoxqgeLigPEfeKGmbuoNlidIseq8MMSPtanF5fRyjQOTwpsbYIaYIheeYOKsiJJgaOG7Eh55Mm0()oDWk0QeqhBzFeq12Y(igPELkeKjGY5CbzquIaI30KnDciqJPFiBkKH930RWlhKfbKb0y6VG6rczZGSL(eGE5LY30bGE5fTGYj7xeeMovvLbKndYmF126QLvq98EilciJhpGSzqgU7WOJEfGGVszfupVhYIaY4XdiBgKHeiZXwwv0YjOP8qgfHSkqgLuczo2YQIwobnLhYuazvGSzqMLOI2A9ifiJIq2eGmLbY4XdidPeqhBzFeqZxTTUkXi1RmjbzcOCoxqgeLiGo2Y(iGabFfciEtt20jGanM(HSPqg2FtVcVCqweqgqJP)cQhjKndYmF126QfAviBgKT0Na0lVu(Moa0lVOfuoz)IGW0PQQmGSzqMLOI2A9ifiJIqgceYugiJhpiGH8enEqaNCceJuVccrqMakNZfKbrjciEtt20jGo2YQIwobnLhYuazvGSzqM5lVyflrfT16rkqweqgqJPFiJkidjqwvFtNlifuo9(AC)gKfFqg2FtVcVCqgsHmLbY4XdcOJTSpciIziO)ATrms9kiqcYeq5CUGmikraXBAYMob0Xwwv0YjOP8qMciRcKndYmF5fRyjQOTwpsbYIaYaAm9dzubzibYQ6B6CbPGYP3xJ73GS4dYW(B6v4LdYqkKPmqgpEqaDSL9rar7JV7x0CPjeJuVYeiitaLZ5cYGOebeVPjB6eqhBzvrlNGMYdzkGSkq2miZ8LxSILOI2A9ifilcidOX0pKrfKHeiRQVPZfKckNEFnUFdYIpid7VPxHxoidPqMYaz84bb0Xw2hbCDvRx9BBIOqms9kXdbzcOCoxqgeLiG4nnztNaA(YlwzKV5hwGmkQaYIhcOJTSpcO)Qc20nG2QjAX5dcXigbKRvjitQxHGmbuoNlidIseqhBzFeWxwv5m9B5XtaXBAYMobKJgaOunvL91vLRrlRG659q2midjqghnaqPAQk7RRkxJwwb1Z7HSiGmE8aYOKsiBfGv(AoxqGmKsaXXWbrB(Yl2tQxHyK6tsqMakNZfKbrjcOJTSpciIziOXnkQFdciEtt20jGanM(HSPqg2FtVcVCqweqgqJP)cQhjKndY4ObakN85Xh13yV2wxvnpETRQ6RB0FHwfYOKsidOX0pKnfYW(B6v4LdYIaYaAm9xq9iHSPqwfeeYMbzC0aaLt(84J6BSxBRRQMhV2vv91n6VqRczZGmoAaGYjFE8r9n2RT1vvZJx7QQ(6g9xwb1Z7HSiGmE8GaIJHdI28LxSNuVcXi1ricYeqhBzFeqeZqq)1AJakNZfKbrjIrQJajitaLZ5cYGOebeVPjB6eqGgt)q2uid7VPxHxoilcidOX0Fb1JeYMbzkhYSeJyE8q2midGoe0RGR5lVOTevGSiGmE8Ga6yl7JagnddGCfnxJYrms9jqqMakNZfKbrjciEtt20jGanM(HSPqg2FtVcVCqweqgqJP)cQhjb0Xw2hbei4hI5XRFBtefIrQhpeKjGo2Y(iGabpMm0FT2iGY5CbzquIyK6tmbzcOCoxqgeLiG4nnztNaU0Na0lVuo5)84J6BSxBRRQMhV2vv91n6ViimDQQkdiBgKb0y6hYIaYQ6B6CbPGYP3xJ73iGo2Y(iGype0o2Y(0H8ncyiFtFoQqapZjgPUYMGmbuoNlidIseq8MMSPtabAm9dztHmS)MEfE5GSiGmGgt)fupscOJTSpc4qCRMgxZrCDuIrQtHsqMakNZfKbrjcOJTSpc46QwV632erHaI30KnDcihnaqb39oYZnzO9)D6GvOvHSzqghnaqb39oYZnzO9)D6Gvwb1Z7HSiGSkLjazkdKXJheqCmCq0MV8I9K6vigPEfeKGmbuoNlidIseqhBzFeq0(47(fnxAcbeVPjB6eqoAaGcU7DKNBYq7)70bRqRczZGmoAaGcU7DKNBYq7)70bRScQN3dzrazvktaYugiJhpiG4y4GOnF5f7j1Rqms9kviitaDSL9raDnk9oKv3aA82rFcOCoxqgeLigPELjjitaLZ5cYGOeb0Xw2hbCDvRx9BBIOqaXBAYMobKJgaOyPQUb0wnr)QIVL3CmIqMcidHiG4y4GOnF5f7j1Rqms9kiebzcOCoxqgeLiG4nnztNac0y6hYMczy)n9k8YbzrazanM(lOEKq2mit5qMLyeZJhYMbzibYaOdb9k4A(YlAlrfilciJhpGmkPeYuoKnARenddGCfnxJYvSeJyE8q2miJJgaOG2hF3VObO3yLvq98EiJIqgaDiOxbxZxErBjQazXhKvbYugiJhpGmkPeYuoKnARenddGCfnxJYvSeJyE8q2mit5qghnaqbTp(UFrdqVXkRG659qgsHmkPeYSev0wRhPazrazvu2q2mit5q2OTs0mmaYv0CnkxXsmI5XtaDSL9raJMHbqUIMRr5igPEfeibzcOCoxqgeLiGo2Y(iGiMHGg3OO(niG4y4GOnF5f7j1RqaXBAYMobeOX0pKnfYW(B6v4LdYIaYaAm9xq9iHSzqgsGmLdzl9ja9YlLt(pp(O(g7126QQ5XRDvvFDJ(lY5CbzazusjKb0y6hYIaYQ6B6CbPGYP3xJ73GmKsahYJ3u1Y(iGXzailwtdzJ(IRbz18QcKvx(pp(O(glUpKH86QQ5XdztevvFDJ(PgY(evnedYW(Bqgfwgcqgf0OO(nGSeaYI10qw0(IRbzDvzXUkK1hKnrPX0pKbSnkKn684HSVlqwCgaYI10q2OHSAEvbYQl)NhFuFJf3hYqEDv184HSjIQQVUr)qwSMgY(AnDyazy)niJcldbiJcAuu)gqwcazXA6fYaAm9dz5dzCsOJczwnbYW9Bqwdazt07JV7xGmLstGSEHmLvx16fYaTnruigPELjqqMakNZfKbrjcOJTSpciIziOXnkQFdciogoiAZxEXEs9keq8MMSPtabAm9dztHmS)MEfE5GSiGmGgt)fupsiBgKT0Na0lVuo5)84J6BSxBRRQMhV2vv91n6ViNZfKbKndYWDhgD0RaSIeV5XRT1vlRG659qgfHmKazanM(HmQGmKazv9nDUGuq507RX9Bqw8bzy)n9k8YbzifYugiJhpGmKczZGmC3Hrh9kMVABD1YkOEEpKrridjqgqJPFiJkidjqwvFtNlifuo9(AC)gKfFqg2FtVcVCqgsHmLbY4XdidPq2midjqMYHmZdYzL3ejOT1vlY5CbzazusjKzEqoR8MibTTUAroNlidiBgKH7om6Ox5nrcABD1YkOEEpKrridjqgqJPFiJkidjqwvFtNlifuo9(AC)gKfFqg2FtVcVCqgsHmLbY4XdidPqgsjGd5XBQAzFeqk80Qbz1L)ZJpQVXI7dziVUQAE8q2erv1x3OFiRVqmiJcldbiJcAuu)gqwcazXA6fYS1vFiZxbY6dYWDhgD0JAiRTAYgnFbYERvHm6ppEiJcldbiJcAuu)gqwcazXA6fYW07kNbzanM(HmhTPpdYYhYKRP5Rbzwdzp9BEEqMvtGmhTPpdYAaiZsubYccGbza9cz(fdYAailwtVqMTU6dzwdz4gvGSgaaYWDhgD0JyK6vIhcYeq5CUGmikraXBAYMobeOX0pKnfYW(B6v4LdYIaYaAm9xq9ijGo2Y(iGVjsqBRRsms9ktmbzcOCoxqgeLiGo2Y(iGVSQYz63YJNaI30KnDc4OTYlRQCM(T84lRaSYxZ5ccKndYuoKXrdauWDVJ8CtgA)FNoyfAvciogoiAZxEXEs9keJuVIYMGmb0Xw2hbCLVp3YJx772rjGY5CbzquIyK6vOqjitaDSL9raJMHH(vZnTNakNZfKbrjIrQpjcsqMakNZfKbrjciEtt20jGkhY4Obak4U3rEUjdT)VthScTkb0Xw2hbe39oYZnzO9)D6Grms9jRqqMakNZfKbrjciEtt20jGC0aaf0(47(fna9gRqRczusjKb0y6hYMczo2Y(kiMHGg3OO(nky)n9k8YbzueYaAm9xq9iHmkPeY4Obak4U3rEUjdT)VthScTkb0Xw2hbeTp(UFrZLMqms9jNKGmbuoNlidIseqhBzFeW1vTE1VTjIcbehdheT5lVypPEfIrQpjcrqMakNZfKbrjciEtt20jGJ2krZWaixrZ1OCLvaw5R5CbHa6yl7JagnddGCfnxJYrms9jrGeKjGY5CbzquIa6yl7Ja(YQkNPFlpEciEtt20jGC0aaLQPQSVUQCnAHwLaIJHdI28LxSNuVcXigb8ncYK6viitaLZ5cYGOebeVPjB6eqGgt)q2uid7VPxHxoilcidOX0Fb1JKa6yl7Jaoe3QPX1CexhLyK6tsqMakNZfKbrjcOJTSpc4lRQCM(T84jG4nnztNaQCiB0w5Lvvot)wE8flXiMhpKndYmF5fRyjQOTwpsbYOiKnXqgLuczC0aaLQPQSVUQCnAHwfYMbzC0aaLQPQSVUQCnAzfupVhYIaY4XdciogoiAZxEXEs9keJuhHiitaDSL9rabcEmzO)ATraLZ5cYGOeXi1rGeKjGo2Y(iGR895wE8AF3okbuoNlidIseJuFceKjGo2Y(iGrZWq)Q5M2taLZ5cYGOeXi1JhcYeqhBzFeqC37ip3KH2)3PdgbuoNlidIseJuFIjitaDSL9rarmdb9xRncOCoxqgeLigPUYMGmbuoNlidIseq8MMSPtabAm9dztHmS)MEfE5GSiGmGgt)fupscOJTSpciqWpeZJx)2MikeJuNcLGmb0Xw2hb01O07qwDdOXBh9jGY5CbzquIyK6vqqcYeq5CUGmikraXBAYMobeGoe0RGR5lVOTevGSiGmE8aYOKsidOX0pKnfYW(B6v4LdYIaYaAm9xq9iHSzqgsGStI00rtnxJYvQ2b3YGazZGSrBLxwv5m9B5XxSeJyE8q2miB0w5Lvvot)wE8Lvaw5R5CbbYOKsi7KinD0uZ1OCf1AY2O9jq2mit5qghnaqbTp(UFrdqVXk0Qq2midOX0pKnfYW(B6v4LdYIaYaAm9xq9iHS4dYCSL9vqmdbnUrr9BuW(B6v4LdYugidHGmKczusjKzjQOTwpsbYIaYQGGeqhBzFeWOzyaKRO5AuoIrQxPcbzcOCoxqgeLiG4nnztNa6ylRkA5e0uEiJIqwfiBgKPCiBPpbOxEPSXcoIV5beL914(aA6BKhV(Tnru(IGW0PQQmiGo2Y(iGyFRkeJuVYKeKjGY5CbzquIaI30KnDcOJTSQOLtqt5HmkczvGSzqMYHSL(eGE5LYgl4i(Mhqu2xJ7dOPVrE8632er5lcctNQQYaYMbz4UdJo6vIMHbqUIMRr5ka0HGEfCnF5fTLOcKrri7vLqqB(Yl2dzZGmKaz4A(YlVgyDSL95biJIq2KLjazusjKnAR81wx9KGMRr5kwIrmpEidPeqhBzFeqoAdxt2yeJuVccrqMakNZfKbrjciEtt20jGanM(HSPqg2FtVcVCqweqgqJP)cQhjb0Xw2hb8nrcABDvIrQxbbsqMakNZfKbrjcOJTSpciAF8D)IMlnHaI30KnDcO5b5SIhuR5A1vgU1BroNlidiBgKHeiJJgaOG2hF3VObO3yfAviBgKXrdauq7JV7x0a0BSYkOEEpKfbKb0y6hYOcYqcKv1305csbLtVVg3VbzXhKH930RWlhKHuitzGmE8aYMbzkhY4ObakrZWq)Q5M2xwb1Z7HmkPeY4ObakO9X39lAa6nwzfupVhYMbzNePPJMAUgLROwt2gTpbYqkbehdheT5lVypPEfIrQxzceKjGY5CbzquIa6yl7JaIygcACJI63GaI30KnDciaDiOxbxZxErBjQazraz84bKndYaAm9dztHmS)MEfE5GSiGmGgt)fupsciogoiAZxEXEs9keJuVs8qqMakNZfKbrjcOJTSpc46QwV632erHaI30KnDcihnaqXsvDdOTAI(vfFlV5yeHmfqgcbzusjKnAR81wx9KGMRr5kwIrmpEciogoiAZxEXEs9keJuVYetqMakNZfKbrjciEtt20jGJ2kFT1vpjO5AuUILyeZJNa6yl7JaI2hF3VO5stigPEfLnbzcOCoxqgeLiGo2Y(iGVSQYz63YJNaI30KnDc4kaR81CUGazZGmZxEXkwIkAR1JuGmkcztmKrjLqghnaqPAQk7RRkxJwOvjG4y4GOnF5f7j1Rqms9kuOeKjGY5CbzquIaI30KnDc4jrA6OPMRr5kFT1vpjazZGmGgt)qgfHSQ(MoxqkOC6914(nitzGSjHSzq2OTYlRQCM(T84lRG659qgfHSjazkdKXJheqhBzFeWOzyaKRO5AuoIrQpjcsqMa6yl7JaIR5iUo6taLZ5cYGOeXi1NScbzcOCoxqgeLiGo2Y(iGiMHGg3OO(niG4nnztNac0y6hYMczy)n9k8YbzrazanM(lOEKeqCmCq0MV8I9K6vigP(KtsqMakNZfKbrjciEtt20jGl9ja9YlLnwWr8npGOSVg3hqtFJ841VTjIYxeeMovvLbb0Xw2hbmAgga5kAUgLJyK6tIqeKjGY5CbzquIa6yl7JaI2hF3VO5stiG4nnztNaYrdauq7JV7x0a0BScTkKrjLqgqJPFiBkK5yl7RGygcACJI63OG930RWlhKrridOX0Fb1JeYIpiRYeGmkPeYgTv(ARREsqZ1OCflXiMhpKrjLqghnaqjAgg6xn30(YkOEEpbehdheT5lVypPEfIrQpjcKGmbuoNlidIseqhBzFeW1vTE1VTjIcbehdheT5lVypPEfIrQp5eiitaLZ5cYGOebeVPjB6eWtI00rtnxJYvQ2b3YGazZGSrBLxwv5m9B5XxSeJyE8qgLuczNePPJMAUgLROwt2gTpbYOKsi7KinD0uZ1OCLV26QNeGSzqgqJPFiJIq2eqqcOJTSpcy0mmaYv0CnkhXigXiGvL9Z(i1NebNSccobeCscyuFV84Fcif(erzTECUUYccaYGmKRjqwIQ2Rbza9czXvDfCJY5wCHSvqy6CLbK9nQazoT1OUjdidxZpE5lW5XrEcKvbbazuqFvL1KbKfxZdYzfkK4czwdzX18GCwHcPiNZfKrCHm3GS40JtnoGmKujsKwGZHZPWNikR1JZ1vwqaqgKHCnbYsu1EnidOxilUVfxiBfeMoxzazFJkqMtBnQBYaYW18Jx(cCECKNazvqGiaiJc6RQSMmGmWeLcGSp2zEKqw8dzwdzXbTdzJSA(zFqwRkRB9cziHkKcziPsKiTaNdNtHpruwRhNRRSGaGmid5AcKLOQ9AqgqVqwCXJpUq2kimDUYaY(gvGmN2Au3KbKHR5hV8f484ipbYQGqiaiJc6RQSMmGmWeLcGSp2zEKqw8dzwdzXbTdzJSA(zFqwRkRB9cziHkKcziPsKiTaNhh5jqwfeicaYOG(QkRjdidmrPai7JDMhjKf)qM1qwCq7q2iRMF2hK1QY6wVqgsOcPqgsQejslW5XrEcKvzciaiJc6RQSMmGmWeLcGSp2zEKqw8dzwdzXbTdzJSA(zFqwRkRB9cziHkKcziPsKiTaNdNtHpruwRhNRRSGaGmid5AcKLOQ9AqgqVqwC5A14czRGW05kdi7BubYCARrDtgqgUMF8YxGZJJ8eiRccebazuqFvL1KbKf3L(eGE5LcfsCHmRHS4U0Na0lVuOqkY5CbzexidjvIePf484ipbYQmbeaKrb9vvwtgqgyIsbq2h7mpsil(HmRHS4G2HSrwn)SpiRvL1TEHmKqfsHmKGqrI0cCECKNazvMacaYOG(QkRjdilUMhKZkuiXfYSgYIR5b5ScfsroNliJ4czizYirAbopoYtGSktabazuqFvL1KbKf3L(eGE5LcfsCHmRHS4U0Na0lVuOqkY5CbzexidjvIePf4C4Ck8jIYA94CDLfeaKbzixtGSevTxdYa6fYIloiEvjUq2kimDUYaY(gvGmN2Au3KbKHR5hV8f484ipbYQGGiaiJc6RQSMmGmWeLcGSp2zEKqw8dzwdzXbTdzJSA(zFqwRkRB9cziHkKcziPsKiTaNhh5jqwLjraqgf0xvznzazGjkfazFSZ8iHS4hYSgYIdAhYgz18Z(GSwvw36fYqcvifYqsLirAbopoYtGSktabazuqFvL1KbKbMOuaK9XoZJeYIFiZAiloODiBKvZp7dYAvzDRxidjuHuidjvIePf484ipbYQepiaiJc6RQSMmGmWeLcGSp2zEKqw8dzwdzXbTdzJSA(zFqwRkRB9cziHkKcziPsKiTaNdNhNrv71KbKnXqMJTSpilKV9f4CcO62azqiGXjqgi9wnR6biBIg9zYcNhNazZPpbYMCIPgYMebNScCoCUJTSVVOUcUr5CBQcQQ6B6CbH6ZrffOC6914(nQBvfVyja1v9aTOWXw2xbTp(UFrZLMuW9Bux1d0IwcVOWXw2xzDvRx9BBIOuW9BuJ7BKw2NcZdYzf0(47(fnxAcCUJTSVVOUcUr5CBQcQEAu0(0QIbN7yl77lQRGBuo3MQGkU2SGm0abpMmIMhV26iZdo3Xw23xuxb3OCUnvbvMVABDvQtafl9ja9YlLVPda9YlAbLt2ViimDQQkd4ChBzFFrDfCJY52ufu9MibTTUkCoCUJTSVFQcQqPJ34niW5XjqMYsdzEnXhqMFdid51peModz8kqw94uOaitobnLponilQazJ(IRbzJgYSA5dza9czQbpMSpKXjyN(filT4oGmobYSUHSx1rrJbz(nGSOcKH9lUgKTIpYqmid51pegYEvbNajgY4Oba(cCUJTSVFQcQS1peModz8MhV(R1g1jGcLB(YlwjFTAWJjlCUJTSVFQcQOFrNMG(W5o2Y((PkOc7HG2Xw2NoKVr95OIc84HZDSL99tvqf2dbTJTSpDiFJ6ZrffCTk1jGchBzvrlNGMYhbcnZ8GCwHl3XRBaT6kXkY5CbzaN7yl77NQGkShcAhBzF6q(g1NJkkEJ6eqHJTSQOLtqt5JaHMPCZdYzfUChVUb0QReRiNZfKbCUJTSVFQcQWEiODSL9Pd5BuFoQOaheVQqDcOWXwwv0YjOP8uCs4ChBzF)ufu5l2prB9UYzW5W5o2Y((cxRQ4Lvvot)wE8uJJHdI28LxSxrfQtafC0aaLQPQSVUQCnAzfupVFgs4ObakvtvzFDv5A0YkOEEFe84bLuUcWkFnNliifo3Xw23x4A1PkOcXme04gf1Vb14y4GOnF5f7vuH6eqbqJP)Py)n9k8YfbqJP)cQh5moAaGYjFE8r9n2RT1vvZJx7QQ(6g9xOvPKsGgt)tX(B6v4LlcGgt)fupYPvqWzC0aaLt(84J6BSxBRRQMhV2vv91n6VqRoJJgaOCYNhFuFJ9ABDv1841UQQVUr)Lvq98(i4Xd4ChBzFFHRvNQGkeZqq)1Ado3Xw23x4A1PkOkAgga5kAUgLJ6eqbqJP)Py)n9k8YfbqJP)cQh5mLBjgX84Nbqhc6vW18Lx0wIkrWJhW5o2Y((cxRovbvab)qmpE9BBIOqDcOaOX0)uS)MEfE5IaOX0Fb1Jeo3Xw23x4A1PkOci4XKH(R1gCUJTSVVW1Qtvqf2dbTJTSpDiFJ6ZrffN5uNakw6ta6LxkN8FE8r9n2RT1vvZJx7QQ(6g9xeeMovvLXmGgt)ru1305csbLtVVg3VbN7yl77lCT6ufune3QPX1CexhL6eqbqJP)Py)n9k8YfbqJP)cQhjCUJTSVVW1Qtvq16QwV632erHACmCq0MV8I9kQqDcOGJgaOG7Eh55Mm0()oDWk0QZ4Obak4U3rEUjdT)VthSYkOEEFevktqz4Xd4ChBzFFHRvNQGk0(47(fnxAc14y4GOnF5f7vuH6eqbhnaqb39oYZnzO9)D6GvOvNXrdauWDVJ8CtgA)FNoyLvq98(iQuMGYWJhW5o2Y((cxRovbvUgLEhYQBanE7OpCUJTSVVW1Qtvq16QwV632erHACmCq0MV8I9kQqDcOGJgaOyPQUb0wnr)QIVL3CmIkqi4ChBzFFHRvNQGQOzyaKRO5AuoQtafanM(NI930RWlxeanM(lOEKZuULyeZJFgsaOdb9k4A(YlAlrLi4XdkPu5J2krZWaixrZ1OCflXiMh)moAaGcAF8D)IgGEJvwb1Z7PiaDiOxbxZxErBjQeFvugE8Gskv(OTs0mmaYv0CnkxXsmI5Xpt5C0aaf0(47(fna9gRScQN3JukP0surBTEKsevu2Zu(OTs0mmaYv0CnkxXsmI5XdNhNazXzailwtdzJ(IRbz18QcKvx(pp(O(glUpKH86QQ5XdztevvFDJ(PgY(evnedYW(Bqgfwgcqgf0OO(nGSeaYI10qw0(IRbzDvzXUkK1hKnrPX0pKbSnkKn684HSVlqwCgaYI10q2OHSAEvbYQl)NhFuFJf3hYqEDv184HSjIQQVUr)qwSMgY(AnDyazy)niJcldbiJcAuu)gqwcazXA6fYaAm9dz5dzCsOJczwnbYW9Bqwdazt07JV7xGmLstGSEHmLvx16fYaTnruGZDSL99fUwDQcQqmdbnUrr9BqnogoiAZxEXEfvOobua0y6Fk2FtVcVCra0y6VG6rodjkFPpbOxEPCY)5Xh13yV2wxvnpETRQ6RB0pLuc0y6pIQ(MoxqkOC6914(nKcNhNazu4PvdYQl)NhFuFJf3hYqEDv184HSjIQQVUr)qwFHyqgfwgcqgf0OO(nGSeaYI10lKzRR(qMVcK1hKH7om6Oh1qwB1KnA(cK9wRcz0FE8qgfwgcqgf0OO(nGSeaYI10lKHP3vodYaAm9dzoAtFgKLpKjxtZxdYSgYE6388GmRMazoAtFgK1aqMLOcKfeadYa6fY8lgK1aqwSMEHmBD1hYSgYWnQaznaaKH7om6OhCUJTSVVW1QtvqfIziOXnkQFdQXXWbrB(Yl2ROc1jGcGgt)tX(B6v4LlcGgt)fupYzl9ja9YlLt(pp(O(g7126QQ5XRDvvFDJ(NH7om6OxbyfjEZJxBRRwwb1Z7PisaAm9h)iPQVPZfKckNEFnUFl(W(B6v4LdPkdpEG0z4UdJo6vmF126QLvq98EkIeGgt)XpsQ6B6CbPGYP3xJ73IpS)MEfE5qQYWJhiDgsuU5b5SYBIe026QusP5b5SYBIe026QZWDhgD0R8MibTTUAzfupVNIibOX0F8JKQ(MoxqkOC6914(T4d7VPxHxoKQm84bsrkCUJTSVVW1Qtvq1BIe026QuNakaAm9pf7VPxHxUiaAm9xq9iHZDSL99fUwDQcQEzvLZ0VLhp14y4GOnF5f7vuH6eqXOTYlRQCM(T84lRaSYxZ5cYmLZrdauWDVJ8CtgA)FNoyfAv4ChBzFFHRvNQGQv((ClpETVBhfo3Xw23x4A1PkOkAgg6xn30E4ChBzFFHRvNQGkC37ip3KH2)3Pdg1jGcLZrdauWDVJ8CtgA)FNoyfAv4ChBzFFHRvNQGk0(47(fnxAc1jGcoAaGcAF8D)IgGEJvOvPKsGgt)tDSL9vqmdbnUrr9BuW(B6v4LJIanM(lOEKusjhnaqb39oYZnzO9)D6GvOvHZDSL99fUwDQcQwx16v)2MikuJJHdI28LxSxrf4ChBzFFHRvNQGQOzyaKRO5AuoQtafJ2krZWaixrZ1OCLvaw5R5Cbbo3Xw23x4A1PkO6Lvvot)wE8uJJHdI28LxSxrfQtafC0aaLQPQSVUQCnAHwfoho3Xw23xWJxrnFv7(OobuyEqoRyYI(6gqlhVZlOYzf5CUGmMb0y6pcGgt)fups4ChBzFFbp(PkOI(fDAck1NJkkgR4dGCfDv5FjqDcOa3vLZpRGySn9BgU7WOJELv((ClpETVBhTScQN3tXkiiLuQCCxvo)ScIX20p4ChBzFFbp(PkOIl09qdqVXOobuG7om6Oxb39oYZnzO9)D6Gvwb1Z7PicHGW5o2Y((cE8tvqLFy5T1dAShcuNakWDhgD0RG7Eh55Mm0()oDWkRG659ueHqq4ChBzFFbp(PkOcixHl09G6eqbU7WOJEfC37ip3KH2)3PdwzfupVNIieccN7yl77l4XpvbvHKVM96jQ0dEu5m4ChBzFFbp(PkOIZ51nG22eJ4tDcOa3Dy0rVcIziOXnkQFJcaDiOxbxZxErBjQqrE8ao3Xw23xWJFQcQ4K9LfX84PobuG7om6Oxb39oYZnzO9)D6Gvwb1Z7Py8GGusPLOI2A9iLiQGqW5o2Y((cE8tvqfkD8gVbbo3Xw23xWJFQcQuBl7J6eqH5lVyflrfT16rkrepiiLuYrdauWDVJ8CtgA)FNoyfAv4ChBzFFbp(PkOY8vBRRsDcOaOX0)uS)MEfE5IaOX0Fb1JC2sFcqV8s5B6aqV8Iwq5K9lcctNQQYyM5R2wxTScQN3hbpEmd3Dy0rVcqWxPScQN3hbpEmdjo2YQIwobnLNIvOKshBzvrlNGMYROYmlrfT16rkuCckdpEGu4ChBzFFbp(PkOci4RqDiprJhkMCcuNakaAm9pf7VPxHxUiaAm9xq9iNz(QT1vl0QZw6ta6LxkFtha6Lx0ckNSFrqy6uvvgZSev0wRhPqreOYWJhW5o2Y((cE8tvqfIziO)ATrDcOWXwwv0YjOP8kQmZ8LxSILOI2A9iLiaAm9h)iPQVPZfKckNEFnUFl(W(B6v4LdPkdpEaN7yl77l4XpvbvO9X39lAU0eQtafo2YQIwobnLxrLzMV8IvSev0wRhPebqJP)4hjv9nDUGuq507RX9BXh2FtVcVCivz4Xd4ChBzFFbp(PkOADvRx9BBIOqDcOWXwwv0YjOP8kQmZ8LxSILOI2A9iLiaAm9h)iPQVPZfKckNEFnUFl(W(B6v4LdPkdpEaN7yl77l4Xpvbv(Rkyt3aARMOfNpiuNakmF5fRmY38dluur8aNdN7yl77l4G4vffVSQYz63YJNACmCq0MV8I9kQqDcOW8GCwPwSX6VMlnPiNZfKXmoAaGs1uv2xxvUgTScQN3pJJgaOunvL91vLRrlRG659rWJhW5o2Y((coiEvzQcQIMHH(vZnTho3Xw23xWbXRktvq1kFFULhV23TJcN7yl77l4G4vLPkOkAgga5kAUgLJ6eqbaDiOxbxZxErBjQebpEaN7yl77l4G4vLPkOcxZrCD0ho3Xw23xWbXRktvqfhTHRjBmQtafJ2kFT1vpjO5AuUILyeZJFgsgTvYZK98GMliYip(YBogXiMKskhTv(ARREsqZ1OCLvq98(i4XdKcN7yl77l4G4vLPkOc7BvH6eqXOTYxBD1tcAUgLRyjgX84HZDSL99fCq8QYufune3QPX1CexhL6eqbqJP)Py)n9k8YfbqJP)cQhjCUJTSVVGdIxvMQGkC37ip3KH2)3PdgCUJTSVVGdIxvMQGkoAdxt2yuNakW18LxEnW6yl7ZduCYYeMH7om6OxjAgga5kAUgLRaqhc6vW18Lx0wIku8vLqqB(Yl2h)tcN7yl77l4G4vLPkOci4hI5XRFBtefQtafanM(NI930RWlxeanM(lOEKW5o2Y((coiEvzQcQW(wvOobuG7om6OxjAgga5kAUgLRaqhc6vW18Lx0wIku8vLqqB(Yl2h)toZ8GCwXdQ1CT6kd36TiNZfKbCUJTSVVGdIxvMQGkeZqqJBuu)guJJHdI28LxSxrfQtafanM(NI930RWlxeanM(lOEKZaOdb9k4A(YlAlrLi4XJzizPpbOxEPCY)5Xh13yV2wxvnpETRQ6RB0Frqy6uvvgZWDhgD0RaSIeV5XRT1vlRG659ZWDhgD0Ry(QT1vlRG659usPYx6ta6LxkN8FE8r9n2RT1vvZJx7QQ(6g9xeeMovvLbsHZDSL99fCq8QYufufnddGCfnxJYrDcOq5J2krZWaixrZ1OCflXiMhpCUJTSVVGdIxvMQGkoAdxt2yuNakqIYpjsthn1Cnkx5RTU6jbkPu5MhKZkrZWaixrNha9N9vKZ5cYaPZWDhgD0RenddGCfnxJYvaOdb9k4A(YlAlrfk(QsiOnF5f7J)jHZDSL99fCq8QYufuH9TQqDcOa3Dy0rVs0mmaYv0CnkxbGoe0RGR5lVOTevO4RkHG28LxSp(Neo3Xw23xWbXRktvqfIziO)ATbN7yl77l4G4vLPkOci4XKH(R1gCUJTSVVGdIxvMQGkxJsVdz1nGgVD0ho3Xw23xWbXRktvq1BIe026QW5o2Y((coiEvzQcQEzvLZ0VLhp14y4GOnF5f7vuH6eqXkaR81CUGmZ8GCwPwSX6VMlnPiNZfKXmZxEXkwIkAR1JuOOYgo3Xw23xWbXRktvqf23QcCUJTSVVGdIxvMQGkeZqqJBuu)guJJHdI28LxSxrfQtafanM(NI930RWlxeanM(lOEKZqYsFcqV8s5K)ZJpQVXETTUQAE8Axv1x3O)IGW0PQQmMH7om6OxbyfjEZJxBRRwwb1Z7NH7om6OxX8vBRRwwb1Z7PKsLV0Na0lVuo5)84J6BSxBRRQMhV2vv91n6ViimDQQkdKcN7yl77l4G4vLPkO6Lvvot)wE8uJJHdI28LxSxrfQtafRaSYxZ5ccCUJTSVVGdIxvMQGk0(47(fnxAc14y4GOnF5f7vubo3Xw23xWbXRktvq16QwV632erHACmCq0MV8I9kQaNdN7yl77lN5kEtKG2wxfo3Xw23xoZNQGkGvK4npETTUk1jGcLZrdauIMHH(vZnTVScQN3tjLC0aaLOzyOF1Ct7lRG659ZWDhgD0RGygcACJI63OScQN3dN7yl77lN5tvqL5R2wxL6eqHY5ObakrZWq)Q5M2xwb1Z7PKsoAaGs0mm0VAUP9Lvq98(z4UdJo6vqmdbnUrr9Buwb1Z7HZHZDSL99L3ume3QPX1CexhL6eqbqJP)Py)n9k8YfbqJP)cQhjCUJTSVV82ufu9YQkNPFlpEQXXWbrB(Yl2ROc1jGcLpAR8YQkNPFlp(ILyeZJFM5lVyflrfT16rkuCIPKsoAaGs1uv2xxvUgTqRoJJgaOunvL91vLRrlRG659rWJhW5o2Y((YBtvqfqWJjd9xRn4ChBzFF5TPkOALVp3YJx772rHZDSL99L3MQGQOzyOF1Ct7HZDSL99L3MQGkC37ip3KH2)3PdgCUJTSVV82ufuHygc6VwBW5o2Y((YBtvqfqWpeZJx)2MikuNakaAm9pf7VPxHxUiaAm9xq9iHZDSL99L3MQGkxJsVdz1nGgVD0ho3Xw23xEBQcQIMHbqUIMRr5Oobuaqhc6vW18Lx0wIkrWJhusjqJP)Py)n9k8YfbqJP)cQh5mKCsKMoAQ5AuUs1o4wgKzJ2kVSQYz63YJVyjgX84NnAR8YQkNPFlp(YkaR81CUGqjLNePPJMAUgLROwt2gTpzMY5ObakO9X39lAa6nwHwDgqJP)Py)n9k8YfbqJP)cQhz85yl7RGygcACJI63OG930RWlNYGqiLskTev0wRhPerfeeo3Xw23xEBQcQW(wvOobu4ylRkA5e0uEkwzMYx6ta6LxkBSGJ4BEarzFnUpGM(g5XRFBteLViimDQQkd4ChBzFF5TPkOIJ2W1Kng1jGchBzvrlNGMYtXkZu(sFcqV8szJfCeFZdik7RX9b003ipE9BBIO8fbHPtvvzmd3Dy0rVs0mmaYv0CnkxbGoe0RGR5lVOTevO4RkHG28LxSFgsW18LxEnW6yl7ZduCYYeOKYrBLV26QNe0CnkxXsmI5XJu4ChBzFF5TPkO6nrcABDvQtafanM(NI930RWlxeanM(lOEKW5o2Y((YBtvqfAF8D)IMlnHACmCq0MV8I9kQqDcOW8GCwXdQ1CT6kd36TiNZfKXmKWrdauq7JV7x0a0BScT6moAaGcAF8D)IgGEJvwb1Z7JaOX0F8JKQ(MoxqkOC6914(T4d7VPxHxoKQm84XmLZrdauIMHH(vZnTVScQN3tjLC0aaf0(47(fna9gRScQN3p7KinD0uZ1OCf1AY2O9jifo3Xw23xEBQcQqmdbnUrr9BqnogoiAZxEXEfvOobuaqhc6vW18Lx0wIkrWJhZaAm9pf7VPxHxUiaAm9xq9iHZDSL99L3MQGQ1vTE1VTjIc14y4GOnF5f7vuH6eqbhnaqXsvDdOTAI(vfFlV5yevGqus5OTYxBD1tcAUgLRyjgX84HZDSL99L3MQGk0(47(fnxAc1jGIrBLV26QNe0CnkxXsmI5XdN7yl77lVnvbvVSQYz63YJNACmCq0MV8I9kQqDcOyfGv(AoxqMz(YlwXsurBTEKcfNykPKJgaOunvL91vLRrl0QW5o2Y((YBtvqv0mmaYv0Cnkh1jGItI00rtnxJYv(ARREsygqJPFkw1305csbLtVVg3VPmtoB0w5Lvvot)wE8Lvq98EkobLHhpGZDSL99L3MQGkCnhX1rF4ChBzFF5TPkOcXme04gf1Vb14y4GOnF5f7vuH6eqbqJP)Py)n9k8YfbqJP)cQhjCUJTSVV82ufufnddGCfnxJYrDcOyPpbOxEPSXcoIV5beL914(aA6BKhV(Tnru(IGW0PQQmGZDSL99L3MQGk0(47(fnxAc14y4GOnF5f7vuH6eqbhnaqbTp(UFrdqVXk0QusjqJP)Po2Y(kiMHGg3OO(nky)n9k8YrrGgt)fupY4RYeOKYrBLV26QNe0CnkxXsmI5XtjLC0aaLOzyOF1Ct7lRG659W5o2Y((YBtvq16QwV632erHACmCq0MV8I9kQaN7yl77lVnvbvrZWaixrZ1OCuNakojsthn1CnkxPAhCldYSrBLxwv5m9B5XxSeJyE8us5jrA6OPMRr5kQ1KTr7tOKYtI00rtnxJYv(ARREsygqJPFkobeKa(QcMuFYjmbIrmcb]] )


end