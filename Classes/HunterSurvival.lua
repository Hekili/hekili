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


    spec:RegisterPack( "Survival", 20210628, [[d8uKJbqisKEKqu6scvLnPO8jHQmkiItbrAvKi8kfXSqP6wksyxs8lukdtrkhtsSmiWZuKQPbbX1uK02eIQVjeHXbbLZrIiwNIe9osePAEcH7rc7dLuhuikwijQhIsstecs4IqqISrsej9rseLrsIiLtkerRur1lHGkZuis3KerIDkP6NqqIAOqqswkeK6PGAQquFLer1yHGQ2lI)sQbJ0HPAXOYJHAYkCzIndYNrvJws60IwneKuVgcnBb3gs7wLFl1WjPJJsILR0Zv10PCDuSDjLVlKgVqLZluwVqv18rj2pWKkeKjWd3esDemneuzArocqyfem9ktDAviWwmvHaR6yeDEHaFoQqGHz2AznpqGv9yH2heKjWFZSyHahzb0QMP(tjBSXNwvgUcUrz7tuMGBzF41Hm2(efZgbMJjdwK8iCe4HBcPocMgcQmTihbiSccMEfeY0vsiWoJvTxcmCIYQe4Q5yihHJapKhtGHz2AznpaOkPXCMSG5ZzobqracJDafbtdbviWH8TNGmb(mNGmPEfcYeyhBzFe43ejOT1vjWY5CbzquMyK6iGGmbwoNlidIYey8MMSPtGvkGYXabvIMHH(vZnTVScQN3dOSWcGYXabvIMHH(vZnTVScQN3dOZauC3Hrh9kiMHGg3OO(nkRG659eyhBzFeyOvK4ppETTUkXi1NobzcSCoxqgeLjW4nnztNaRuaLJbcQendd9RMBAFzfupVhqzHfaLJbcQendd9RMBAFzfupVhqNbO4UdJo6vqmdbnUrr9Buwb1Z7jWo2Y(iWMVABDvIrmc8qGCMGrqMuVcbzcSJTSpcmkt8h)bHalNZfKbrzIrQJacYey5CUGmiktGDSL9rGT1pwHjdz8NhV(R2gbEipEtvl7JaRK1aQxv8bG63aqrE9JvyYqg)cGwhHkwfqLtqt5zhqJka6OV4za6ObuRA(akuVaQAWJj7dOCc2zEbqtlEdaLtauRBa9vDu0yaQFdanQaOy)INbOR4JmedqrE9Jva0xvWjuIbuogiOVqGXBAYMobwPaQ5lVyL81QbpMSeJuF6eKjWo2Y(iWmVOttqFcSCoxqgeLjgPocHGmbwoNlidIYeyhBzFeyShcAhBzF6q(gboKVPphviW4Xtms9PsqMalNZfKbrzcmEtt20jWo2YAIwobnLhqJaqNoGodqnpiNv4YD86gsRUsSICoxqgeyhBzFeyShcAhBzF6q(gboKVPphviWCTkXi1JCcYey5CUGmiktGXBAYMob2Xwwt0YjOP8aAea60b0zaQsbuZdYzfUChVUH0QReRiNZfKbb2Xw2hbg7HG2Xw2NoKVrGd5B6Zrfc8BeJupsqqMalNZfKbrzcmEtt20jWo2YAIwobnLhqznGIacSJTSpcm2dbTJTSpDiFJahY30NJkeyCq8AcXi1ryeKjWo2Y(iW(I9t0wVRCgbwoNlidIYeJyey1vWnkNBeKj1RqqMalNZfKbrzcCRsGFXsicmEtt20jWMhKZkO9X39lAU0KICoxqge4H84nvTSpc8CMtaueGWyhqrW0qqfcCnF1NJkeyuo9(AC)gb2Xw2hbUMVPZfecCnpWiAj8cb2Xw2xzDvRx9BBIOuW9Be4AEGriWo2Y(kO9X39lAU0KcUFJyK6iGGmb2Xw2hb(zqr7tRkgbwoNlidIYeJuF6eKjWo2Y(iWCTzbzOHcEmzenpET1XLhbwoNlidIYeJuhHqqMalNZfKbrzcmEtt20jWlZjq9YlLVzcq9YlAbLt2ViSctQQkdcSJTSpcS5R2wxLyK6tLGmb2Xw2hb(nrcABDvcSCoxqgeLjgXiWVrqMuVcbzcSCoxqgeLjW4nnztNad1yMhqNaOy)n9k8YbOraOqnM5lOECeyhBzFe4H4wvnUQJ46OeJuhbeKjWY5CbzquMa7yl7Ja)YQkNPFlpEcmEtt20jWkfqhTvEzvLZ0VLhFXsmI5XdOZauZxEXkwIkAR1JuauwdOrcaLfwauogiOsTuv2xxtUgTWOcOZauogiOsTuv2xxtUgTScQN3dOraO84bbghdheT5lVypPEfIrQpDcYeyhBzFeyOGhtg6VABey5CUGmiktmsDecbzcSJTSpc8kFFULhV23TJsGLZ5cYGOmXi1NkbzcSJTSpcC0mm0VAUP9ey5CUGmiktms9iNGmb2Xw2hbg39oYZnzO9)DMGrGLZ5cYGOmXi1JeeKjWo2Y(iWiMHG(R2gbwoNlidIYeJuhHrqMalNZfKbrzcmEtt20jWqnM5b0jak2FtVcVCaAeakuJz(cQhhb2Xw2hbgk4hI5XRFBtefIrQRKqqMa7yl7Ja7AuMDiRUH04TJ(ey5CUGmiktms9ktJGmbwoNlidIYey8MMSPtGHycb9k4Q(YlAlrfancaLhpauwybqHAmZdOtauS)MEfE5a0iauOgZ8fupoaDgGIea9K4mD0uZ1OCLADWTmia6maD0w5Lvvot)wE8flXiMhpGodqhTvEzvLZ0VLhFzfOv(Qoxqauwybqpjothn1CnkxrTQSnAFcGodqvkGYXabvq7JV7x0qmBScJkGodqHAmZdOtauS)MEfE5a0iauOgZ8fupoaDkauhBzFfeZqqJBuu)gfS)MEfE5auLaqNoGIuaLfwaulrfT16rkaAeaALPrGDSL9rGJMHbuUIMRr5igPELkeKjWY5CbzquMaJ30KnDcSJTSMOLtqt5buwdOva0zaQsb0L5eOE5LYgl4i(Mhqu2xJ7dQzUrE8632er5lcRWKQQYGa7yl7JaJ9TMqms9kiGGmbwoNlidIYey8MMSPtGDSL1eTCcAkpGYAaTcGodqvkGUmNa1lVu2ybhX38aIY(ACFqnZnYJx)2MikFryfMuvvga6maf3Dy0rVs0mmGYv0CnkxbIje0RGR6lVOTevauwdOVQecAZxEXEaDgGIeafx1xE51qRJTSppaOSgqrqzQaklSaOJ2kF11vpjO5AuUILyeZJhqrkb2Xw2hbMJXWvLngXi1RmDcYey5CUGmiktGXBAYMobgQXmpGobqX(B6v4LdqJaqHAmZxq94iWo2Y(iWVjsqBRRsms9kiecYey5CUGmiktGDSL9rGr7JV7x0CPjey8MMSPtGnpiNv8GAvxRUYWTElY5CbzaOZauKaOCmqqf0(47(fneZgRWOcOZauogiOcAF8D)IgIzJvwb1Z7b0iauOgZ8akBaksa0A(MoxqkOC6914(naDkauS)MEfE5auKcOkbGYJha6mavPakhdeujAgg6xn30(YkOEEpGYclakhdeubTp(UFrdXSXkRG659a6ma9K4mD0uZ1OCf1QY2O9jaksjW4y4GOnF5f7j1Rqms9ktLGmbwoNlidIYeyhBzFeyeZqqJBuu)gey8MMSPtGHycb9k4Q(YlAlrfancaLhpa0zakuJzEaDcGI930RWlhGgbGc1yMVG6XrGXXWbrB(Yl2tQxHyK6vICcYey5CUGmiktGDSL9rGxx16v)2Mikey8MMSPtG5yGGkwQQBiTvv0VQ4B5nhJiGQaqNoGYcla6OTYxDD1tcAUgLRyjgX84jW4y4GOnF5f7j1Rqms9krccYey5CUGmiktGXBAYMobE0w5RUU6jbnxJYvSeJyE8eyhBzFey0(47(fnxAcXi1RGWiitGLZ5cYGOmb2Xw2hb(Lvvot)wE8ey8MMSPtGxbALVQZfeaDgGA(YlwXsurBTEKcGYAansaOSWcGYXabvQLQY(6AY1OfgvcmogoiAZxEXEs9keJuVIscbzcSCoxqgeLjW4nnztNaFsCMoAQ5AuUYxDD1tca6mafQXmpGYAaTMVPZfKckNEFnUFdqvcafba6maD0w5Lvvot)wE8Lvq98EaL1a6ubuLaq5XdcSJTSpcC0mmGYv0CnkhXi1rW0iitGDSL9rGXvDexh9jWY5CbzquMyK6iOcbzcSCoxqgeLjWo2Y(iWiMHGg3OO(niW4nnztNad1yMhqNaOy)n9k8YbOraOqnM5lOECeyCmCq0MV8I9K6vigPocqabzcSCoxqgeLjW4nnztNaVmNa1lVu2ybhX38aIY(ACFqnZnYJx)2MikFryfMuvvgeyhBzFe4OzyaLRO5AuoIrQJGPtqMalNZfKbrzcSJTSpcmAF8D)IMlnHaJ30KnDcmhdeubTp(UFrdXSXkmQaklSaOqnM5b0jaQJTSVcIziOXnkQFJc2FtVcVCakRbuOgZ8fupoaDka0ktfqzHfaD0w5RUU6jbnxJYvSeJyE8aklSaOCmqqLOzyOF1Ct7lRG659eyCmCq0MV8I9K6vigPocqieKjWY5CbzquMa7yl7JaVUQ1R(TnruiW4y4GOnF5f7j1RqmsDemvcYey5CUGmiktGXBAYMob(K4mD0uZ1OCLADWTmia6maD0w5Lvvot)wE8flXiMhpGYcla6jXz6OPMRr5kQvLTr7tauwybqpjothn1Cnkx5RUU6jbaDgGc1yMhqznGo1PrGDSL9rGJMHbuUIMRr5igXiW4XtqMuVcbzcSCoxqgeLjW4nnztNaBEqoRyYI(6gslhVZlOYzf5CUGma0zakuJzEancafQXmFb1JJa7yl7Jax1x1UpIrQJacYey5CUGmiktGDSL9rGhR4dOCfDn5FjqGXBAYMobg31KZpRGySn9dqNbO4UdJo6vw57ZT841(UD0YkOEEpGYAaTY0auwybqvkGI7AY5Nvqm2M(rGphviWJv8buUIUM8VeigP(0jitGLZ5cYGOmbgVPjB6eyC3Hrh9k4U3rEUjdT)VZeSYkOEEpGYAaD6tJa7yl7JaZf6EOHy2yeJuhHqqMalNZfKbrzcmEtt20jW4UdJo6vWDVJ8CtgA)FNjyLvq98EaL1a60Ngb2Xw2hb2pS826bn2dbIrQpvcYey5CUGmiktGXBAYMobg3Dy0rVcU7DKNBYq7)7mbRScQN3dOSgqN(0iWo2Y(iWq5kCHUheJupYjitGDSL9rGdjFv71iuZm4rLZiWY5CbzquMyK6rccYey5CUGmiktGXBAYMobg3Dy0rVcIziOXnkQFJcetiOxbx1xErBjQaOSgq5XdcSJTSpcmNZRBiTTjgXNyK6imcYey5CUGmiktGXBAYMobg3Dy0rVcU7DKNBYq7)7mbRScQN3dOSgqJ8PbOSWcGAjQOTwpsbqJaqRmDcSJTSpcmNSVSiMhpXi1vsiitGDSL9rGrzI)4piey5CUGmiktms9ktJGmbwoNlidIYey8MMSPtGnF5fRyjQOTwpsbqJaqJ8PbOSWcGYXabvWDVJ8CtgA)FNjyfgvcSJTSpcSABzFeJuVsfcYey5CUGmiktGXBAYMobgQXmpGobqX(B6v4LdqJaqHAmZxq94a0za6YCcuV8s5BMauV8Iwq5K9lcRWKQQYaqNbOMVABD1YkOEEpGgbGYJha6maf3Dy0rVcuWxPScQN3dOraO84bGodqrcG6ylRjA5e0uEaL1aAfaLfwauhBznrlNGMYdOka0ka6ma1surBTEKcGYAaDQaQsaO84bGIucSJTSpcS5R2wxLyK6vqabzcSCoxqgeLjWo2Y(iWqbFfcmEtt20jWqnM5b0jak2FtVcVCaAeakuJz(cQhhGodqnF126QfgvaDgGUmNa1lVu(Mja1lVOfuoz)IWkmPQQma0zaQLOI2A9ifaL1akcbqvcaLhpiWH8enEqGrWujgPELPtqMalNZfKbrzcmEtt20jWo2YAIwobnLhqvaOva0zaQ5lVyflrfT16rkaAeakuJzEaLnafjaAnFtNlifuo9(AC)gGofak2FtVcVCaksbuLaq5XdcSJTSpcmIziO)QTrms9kiecYey5CUGmiktGXBAYMob2Xwwt0YjOP8aQcaTcGodqnF5fRyjQOTwpsbqJaqHAmZdOSbOibqR5B6CbPGYP3xJ73a0PaqX(B6v4LdqrkGQeakpEqGDSL9rGr7JV7x0CPjeJuVYujitGLZ5cYGOmbgVPjB6eyhBznrlNGMYdOka0ka6ma18LxSILOI2A9ifancafQXmpGYgGIeaTMVPZfKckNEFnUFdqNcaf7VPxHxoafPaQsaO84bb2Xw2hbEDvRx9BBIOqms9krobzcSCoxqgeLjW4nnztNaB(YlwzKV5hwauwRaqJCcSJTSpcS)Qc20nK2QkAX5dcXigbMRvjitQxHGmbwoNlidIYeyhBzFe4xwv5m9B5XtGXBAYMobMJbcQulvL911KRrlRG659a6mafjakhdeuPwQk7RRjxJwwb1Z7b0iauE8aqzHfaDfOv(QoxqauKsGXXWbrB(Yl2tQxHyK6iGGmbwoNlidIYeyhBzFeyeZqqJBuu)gey8MMSPtGHAmZdOtauS)MEfE5a0iauOgZ8fupoaDgGYXabvo5ZJpQVXETTUQAE8Axv1x3y(cJkGYclakuJzEaDcGI930RWlhGgbGc1yMVG6XbOta0ktdqNbOCmqqLt(84J6BSxBRRQMhV2vv91nMVWOcOZauogiOYjFE8r9n2RT1vvZJx7QQ(6gZxwb1Z7b0iauE8GaJJHdI28LxSNuVcXi1NobzcSJTSpcmIziO)QTrGLZ5cYGOmXi1rieKjWY5CbzquMaJ30KnDcmuJzEaDcGI930RWlhGgbGc1yMVG6XbOZauLcOwIrmpEaDgGcXec6vWv9Lx0wIkaAeakpEqGDSL9rGJMHbuUIMRr5igP(ujitGLZ5cYGOmbgVPjB6eyOgZ8a6eaf7VPxHxoancafQXmFb1JJa7yl7Jadf8dX841VTjIcXi1JCcYeyhBzFeyOGhtg6VABey5CUGmiktms9ibbzcSCoxqgeLjW4nnztNaVmNa1lVuo5)84J6BSxBRRQMhV2vv91nMViSctQQkdaDgGc1yMhqJaqR5B6CbPGYP3xJ73iWo2Y(iWype0o2Y(0H8ncCiFtFoQqGpZjgPocJGmbwoNlidIYey8MMSPtGHAmZdOtauS)MEfE5a0iauOgZ8fupocSJTSpc8qCRQgx1rCDuIrQRKqqMalNZfKbrzcSJTSpc86QwV632erHaJ30KnDcmhdeub39oYZnzO9)DMGvyub0zakhdeub39oYZnzO9)DMGvwb1Z7b0ia0kLPcOkbGYJheyCmCq0MV8I9K6vigPELPrqMalNZfKbrzcSJTSpcmAF8D)IMlnHaJ30KnDcmhdeub39oYZnzO9)DMGvyub0zakhdeub39oYZnzO9)DMGvwb1Z7b0ia0kLPcOkbGYJheyCmCq0MV8I9K6vigPELkeKjWo2Y(iWUgLzhYQBinE7OpbwoNlidIYeJuVcciitGLZ5cYGOmb2Xw2hbEDvRx9BBIOqGXBAYMobMJbcQyPQUH0wvr)QIVL3CmIaQcaD6eyCmCq0MV8I9K6vigPELPtqMalNZfKbrzcmEtt20jWqnM5b0jak2FtVcVCaAeakuJz(cQhhGodqvkGAjgX84b0zaksauiMqqVcUQV8I2subqJaq5XdaLfwauLcOJ2krZWakxrZ1OCflXiMhpGodq5yGGkO9X39lAiMnwzfupVhqznGcXec6vWv9Lx0wIka6uaOvauLaq5XdaLfwauLcOJ2krZWakxrZ1OCflXiMhpGodqvkGYXabvq7JV7x0qmBSYkOEEpGIuaLfwaulrfT16rkaAeaAfegGodqvkGoARenddOCfnxJYvSeJyE8eyhBzFe4OzyaLRO5AuoIrQxbHqqMalNZfKbrzcSJTSpcmIziOXnkQFdcmogoiAZxEXEs9key8MMSPtGHAmZdOtauS)MEfE5a0iauOgZ8fupoaDgGIeavPa6YCcuV8s5K)ZJpQVXETTUQAE8Axv1x3y(ICoxqgaklSaOqnM5b0ia0A(MoxqkOC6914(nafPe4H84nvTSpcCKecqJ1ma6OV4zaAvVMaO1L)ZJpQVXI3dOiVUQAE8aAKrv1x3yE2b0prvdXauS)gGIWLHaGYQnkQFdanHa0yndGgTV4zaAxtwSRcO9bOkP2yMhqH2gfqhDE8a63fanscbOXAgaD0aAvVMaO1L)ZJpQVXI3dOiVUQAE8aAKrv1x3yEanwZaOF1MjmauS)gGIWLHaGYQnkQFdanHa0ynZcOqnM5b08buoj0rbuRQaO4(naTHauLu6JV7xauLtta0EbueAx16fqHTnruigPELPsqMalNZfKbrzcSJTSpcmIziOXnkQFdcmogoiAZxEXEs9key8MMSPtGHAmZdOtauS)MEfE5a0iauOgZ8fupoaDgGUmNa1lVuo5)84J6BSxBRRQMhV2vv91nMViNZfKbGodqXDhgD0RaTIe)5XRT1vlRG659akRbuKaOqnM5bu2auKaO18nDUGuq507RX9Ba6uaOy)n9k8YbOifqvcaLhpauKcOZauC3Hrh9kMVABD1YkOEEpGYAafjakuJzEaLnafjaAnFtNlifuo9(AC)gGofak2FtVcVCaksbuLaq5XdafPa6mafjaQsbuZdYzL3ejOT1vlY5CbzaOSWcGAEqoR8MibTTUAroNlidaDgGI7om6Ox5nrcABD1YkOEEpGYAafjakuJzEaLnafjaAnFtNlifuo9(AC)gGofak2FtVcVCaksbuLaq5XdafPaksjWd5XBQAzFeyL80QcO1L)ZJpQVXI3dOiVUQAE8aAKrv1x3yEaTVqmafHldbaLvBuu)gaAcbOXAMfqT1vFa1xbq7dqXDhgD0JDaTTQYgnFbqFRvbuMppEafHldbaLvBuu)gaAcbOXAMfqXm7kNbOqnM5buhTzodqZhqLRz4RcOwdOpZBEEaQvvauhTzodqBia1subqdcKbOq9cO(fdqBianwZSaQTU6dOwdO4gva0gccqXDhgD0JyK6vICcYey5CUGmiktGXBAYMobgQXmpGobqX(B6v4LdqJaqHAmZxq94iWo2Y(iWVjsqBRRsms9krccYey5CUGmiktGDSL9rGFzvLZ0VLhpbgVPjB6e4rBLxwv5m9B5XxwbALVQZfeaDgGQuaLJbcQG7Eh55Mm0()otWkmQeyCmCq0MV8I9K6vigPEfegbzcSJTSpc8kFFULhV23TJsGLZ5cYGOmXi1ROKqqMa7yl7Jahndd9RMBApbwoNlidIYeJuhbtJGmbwoNlidIYey8MMSPtGvkGYXabvWDVJ8CtgA)FNjyfgvcSJTSpcmU7DKNBYq7)7mbJyK6iOcbzcSCoxqgeLjW4nnztNaZXabvq7JV7x0qmBScJkGYclakuJzEaDcG6yl7RGygcACJI63OG930RWlhGYAafQXmFb1JdqzHfaLJbcQG7Eh55Mm0()otWkmQeyhBzFey0(47(fnxAcXi1raciitGLZ5cYGOmb2Xw2hbEDvRx9BBIOqGXXWbrB(Yl2tQxHyK6iy6eKjWY5CbzquMaJ30KnDc8OTs0mmGYv0CnkxzfOv(QoxqiWo2Y(iWrZWakxrZ1OCeJuhbiecYey5CUGmiktGDSL9rGFzvLZ0VLhpbgVPjB6eyogiOsTuv2xxtUgTWOsGXXWbrB(Yl2tQxHyeJaJdIxtiitQxHGmbwoNlidIYeyhBzFe4xwv5m9B5XtGXBAYMob28GCwPASX6VMlnPiNZfKbGodq5yGGk1svzFDn5A0YkOEEpGodq5yGGk1svzFDn5A0YkOEEpGgbGYJheyCmCq0MV8I9K6vigPociitGDSL9rGJMHH(vZnTNalNZfKbrzIrQpDcYeyhBzFe4v((ClpETVBhLalNZfKbrzIrQJqiitGLZ5cYGOmbgVPjB6eyiMqqVcUQV8I2subqJaq5XdcSJTSpcC0mmGYv0CnkhXi1NkbzcSJTSpcmUQJ46OpbwoNlidIYeJupYjitGLZ5cYGOmbgVPjB6e4rBLV66QNe0CnkxXsmI5XdOZauKaOJ2k5zYEEqZfezKhF5nhJiGgbGIaaLfwa0rBLV66QNe0CnkxzfupVhqJaq5XdafPeyhBzFeyogdxv2yeJupsqqMalNZfKbrzcmEtt20jWJ2kF11vpjO5AuUILyeZJNa7yl7JaJ9TMqmsDegbzcSCoxqgeLjW4nnztNad1yMhqNaOy)n9k8YbOraOqnM5lOECeyhBzFe4H4wvnUQJ46OeJuxjHGmb2Xw2hbg39oYZnzO9)DMGrGLZ5cYGOmXi1RmncYey5CUGmiktGXBAYMobgx1xE51qRJTSppaOSgqrqzQa6maf3Dy0rVs0mmGYv0CnkxbIje0RGR6lVOTevauwdOVQecAZxEXEaLnafbeyhBzFeyogdxv2yeJuVsfcYey5CUGmiktGXBAYMobgQXmpGobqX(B6v4LdqJaqHAmZxq94iWo2Y(iWqb)qmpE9BBIOqms9kiGGmbwoNlidIYey8MMSPtGXDhgD0RenddOCfnxJYvGycb9k4Q(YlAlrfaL1a6RkHG28LxShqzdqraGodqnpiNv8GAvxRUYWTElY5CbzqGDSL9rGX(wtigPELPtqMalNZfKbrzcSJTSpcmIziOXnkQFdcmEtt20jWqnM5b0jak2FtVcVCaAeakuJz(cQhhGodqHycb9k4Q(YlAlrfancaLhpa0zaksa0L5eOE5LYj)NhFuFJ9ABDv1841UQQVUX8fHvysvvzaOZauC3Hrh9kqRiXFE8ABD1YkOEEpGodqXDhgD0Ry(QT1vlRG659aklSaOkfqxMtG6LxkN8FE8r9n2RT1vvZJx7QQ(6gZxewHjvvLbGIucmogoiAZxEXEs9keJuVccHGmbwoNlidIYey8MMSPtGvkGoARenddOCfnxJYvSeJyE8eyhBzFe4OzyaLRO5AuoIrQxzQeKjWY5CbzquMaJ30KnDcmsauLcONeNPJMAUgLR8vxx9KaGYclaQsbuZdYzLOzyaLROZdI5Z(kY5CbzaOifqNbO4UdJo6vIMHbuUIMRr5kqmHGEfCvF5fTLOcGYAa9vLqqB(Yl2dOSbOiGa7yl7JaZXy4QYgJyK6vICcYey5CUGmiktGXBAYMobg3Dy0rVs0mmGYv0CnkxbIje0RGR6lVOTevauwdOVQecAZxEXEaLnafbeyhBzFeySV1eIrQxjsqqMa7yl7JaJygc6VABey5CUGmiktms9kimcYeyhBzFeyOGhtg6VABey5CUGmiktms9kkjeKjWo2Y(iWUgLzhYQBinE7OpbwoNlidIYeJuhbtJGmb2Xw2hb(nrcABDvcSCoxqgeLjgPocQqqMalNZfKbrzcSJTSpc8lRQCM(T84jW4nnztNaVc0kFvNlia6ma18GCwPASX6VMlnPiNZfKbGodqnF5fRyjQOTwpsbqznGIWiW4y4GOnF5f7j1RqmsDeGacYeyhBzFeySV1ecSCoxqgeLjgPocMobzcSCoxqgeLjWo2Y(iWiMHGg3OO(niW4nnztNad1yMhqNaOy)n9k8YbOraOqnM5lOECa6mafja6YCcuV8s5K)ZJpQVXETTUQAE8Axv1x3y(IWkmPQQma0zakU7WOJEfOvK4ppETTUAzfupVhqNbO4UdJo6vmF126QLvq98EaLfwauLcOlZjq9YlLt(pp(O(g7126QQ5XRDvvFDJ5lcRWKQQYaqrkbghdheT5lVypPEfIrQJaecbzcSCoxqgeLjWo2Y(iWVSQYz63YJNaJ30KnDc8kqR8vDUGqGXXWbrB(Yl2tQxHyK6iyQeKjWY5CbzquMa7yl7JaJ2hF3VO5stiW4y4GOnF5f7j1RqmsDee5eKjWY5CbzquMa7yl7JaVUQ1R(TnruiW4y4GOnF5f7j1RqmIrmcCnz)SpsDemneuzArocIee4O(E5X)eyL8idcD9izDLSPeqbuKRkaAIQ2RbOq9cOXtDfCJY5w8a0vyfMCLbG(nQaOoJ1OUjdafx1pE5lG5rAEcGwzkbuwTVAYAYaqJN5b5SccF8auRb04zEqoRGWxKZ5cYiEaQBakcLqOCKcOiPsCiTaMdMRKhzqORhjRRKnLakGICvbqtu1EnafQxanEVfpaDfwHjxzaOFJkaQZynQBYaqXv9Jx(cyEKMNaOvqitjGYQ9vtwtgakCIYQa6h7mpoan(auRb0iLXb0rwl)SpaTvL1TEbuKWgsbuKujoKwaZbZvYJmi01JK1vYMsafqrUQaOjQAVgGc1lGgp84JhGUcRWKRma0Vrfa1zSg1nzaO4Q(XlFbmpsZta0ktFkbuwTVAYAYaqHtuwfq)yN5XbOXhGAnGgPmoGoYA5N9bOTQSU1lGIe2qkGIKkXH0cyEKMNaOvqitjGYQ9vtwtgakCIYQa6h7mpoan(auRb0iLXb0rwl)SpaTvL1TEbuKWgsbuKujoKwaZJ08eaTYuNsaLv7RMSMmau4eLvb0p2zECaA8bOwdOrkJdOJSw(zFaARkRB9cOiHnKcOiPsCiTaMdMRKhzqORhjRRKnLakGICvbqtu1EnafQxanECTA8a0vyfMCLbG(nQaOoJ1OUjdafx1pE5lG5rAEcGwbHmLakR2xnznzaOXBzobQxEPGWhpa1AanElZjq9Ylfe(ICoxqgXdqrsL4qAbmpsZta0ktDkbuwTVAYAYaqHtuwfq)yN5XbOXhGAnGgPmoGoYA5N9bOTQSU1lGIe2qkGIKPhhslG5rAEcGwzQtjGYQ9vtwtgaA8mpiNvq4JhGAnGgpZdYzfe(ICoxqgXdqrccIdPfW8inpbqRm1Peqz1(QjRjdanElZjq9Ylfe(4bOwdOXBzobQxEPGWxKZ5cYiEaksQehslG5G5k5rge66rY6kztjGcOixva0evTxdqH6fqJhoiEnjEa6kSctUYaq)gvauNXAu3KbGIR6hV8fW8inpbqRmTPeqz1(QjRjdaforzva9JDMhhGgFaQ1aAKY4a6iRLF2hG2QY6wVaksydPaksQehslG5rAEcGwbbtjGYQ9vtwtgakCIYQa6h7mpoan(auRb0iLXb0rwl)SpaTvL1TEbuKWgsbuKujoKwaZJ08eaTYuNsaLv7RMSMmau4eLvb0p2zECaA8bOwdOrkJdOJSw(zFaARkRB9cOiHnKcOiPsCiTaMhP5jaALiFkbuwTVAYAYaqHtuwfq)yN5XbOXhGAnGgPmoGoYA5N9bOTQSU1lGIe2qkGIKkXH0cyoyEKevTxtgaAKaqDSL9bOH8TVaMtGFvbtQJGPovcS62qzqiWrwafMzRL18aGQKgZzYcMhzb05mNaOiaHXoGIGPHGkG5G5o2Y((I6k4gLZTjkyRMVPZfe2phvuGYP3xJ73yVvv8ILqSxZdmIchBzFf0(47(fnxAsb3VXEnpWiAj8IchBzFL1vTE1VTjIsb3VXoUVrAzFkmpiNvq7JV7x0CPjG5o2Y((I6k4gLZTjky7zqr7tRkgyUJTSVVOUcUr5CBIc24AZcYqdf8yYiAE8ARJlpWChBzFFrDfCJY52efSz(QT1vzpHuSmNa1lVu(Mja1lVOfuoz)IWkmPQQmaZDSL99f1vWnkNBtuW2BIe026QG5G5o2Y((jkydLj(J)GaMhzbuLSgq9QIpau)gakYRFSctgY4xa06iuXQaQCcAkVs6aAubqh9fpdqhnGAvZhqH6fqvdEmzFaLtWoZlaAAXBaOCcGADdOVQJIgdq9BaOrfaf7x8maDfFKHyakYRFScG(QcoHsmGYXab9fWChBzF)efSzRFSctgY4ppE9xTn2tifk18LxSs(A1GhtwWChBzF)efSX8Ionb9bZJSrwafHcj4XauihNhpGgRzwaD0mCgGYCwga0yndGw1RjaQkJbOi0Y3NB5XdOrMD7Oa6OJESdO9cOjeGAvfaf3Dy0rpanFa16gqd9XdOwdOdj4XauihNhpGgRzwafHIMHZkaAKecqV(eaTHauRQ8cGI7BKw23dO(kaQZfea1AafvmanAAvZdqTQcGwzAa6l4(gpGgejQhJDa1Qka6NOakKJLhqJ1mlGIqrZWzaQZynQBj2dHyfW8iBKfqDSL99tuW2jrHAMBOx57qnH9esX3mbU8gLtIc1m3qVY3HAYmKWXabvw57ZT841(UD0cJklSG7om6OxzLVp3YJx772rlRG659SUY0yHfZxEXkwIkAR1JuIOsKJuWChBzF)efSH9qq7yl7thY3y)CurbE8G5o2Y((jkyd7HG2Xw2NoKVX(5OIcUwL9esHJTSMOLtqt5Jy6ZmpiNv4YD86gsRUsSICoxqgG5o2Y((jkyd7HG2Xw2NoKVX(5OII3ypHu4ylRjA5e0u(iM(mLAEqoRWL741nKwDLyf5CUGmaZDSL99tuWg2dbTJTSpDiFJ9Zrff4G41e2tifo2YAIwobnLN1iam3Xw23prbB(I9t0wVRCgyoyUJTSVVW1QkEzvLZ0VLhp74y4GOnF5f7vuH9esbhdeuPwQk7RRjxJwwb1Z7NHeogiOsTuv2xxtUgTScQN3hbpEWclRaTYx15ccsbZDSL99fUwDIc2qmdbnUrr9BWoogoiAZxEXEfvypHua1yMFc2FtVcVCra1yMVG6XnJJbcQCYNhFuFJ9ABDv1841UQQVUX8fgvwybQXm)eS)MEfE5IaQXmFb1JBsLPnJJbcQCYNhFuFJ9ABDv1841UQQVUX8fg1zCmqqLt(84J6BSxBRRQMhV2vv91nMVScQN3hbpEaM7yl77lCT6efSHygc6VABG5o2Y((cxRorbBrZWakxrZ1OCSNqkGAmZpb7VPxHxUiGAmZxq94MPulXiMh)miMqqVcUQV8I2sujcE8am3Xw23x4A1jkydk4hI5XRFBtef2tifqnM5NG930RWlxeqnM5lOECG5o2Y((cxRorbBqbpMm0F12aZDSL99fUwDIc2WEiODSL9Pd5BSFoQO4mN9esXYCcuV8s5K)ZJpQVXETTUQAE8Axv1x3y(IWkmPQQmMb1yMpIA(MoxqkOC6914(nWChBzFFHRvNOGTH4wvnUQJ46OSNqkGAmZpb7VPxHxUiGAmZxq94aZDSL99fUwDIc2wx16v)2MikSJJHdI28LxSxrf2tifCmqqfC37ip3KH2)3zcwHrDghdeub39oYZnzO9)DMGvwb1Z7JOszQkbpEaM7yl77lCT6efSH2hF3VO5styhhdheT5lVyVIkSNqk4yGGk4U3rEUjdT)VZeScJ6mogiOcU7DKNBYq7)7mbRScQN3hrLYuvcE8am3Xw23x4A1jkyZ1Om7qwDdPXBh9bZDSL99fUwDIc2wx16v)2MikSJJHdI28LxSxrf2tifCmqqflv1nK2Qk6xv8T8MJruX0bZDSL99fUwDIc2IMHbuUIMRr5ypHua1yMFc2FtVcVCra1yMVG6XntPwIrmp(zibIje0RGR6lVOTevIGhpyHfLoARenddOCfnxJYvSeJyE8Z4yGGkO9X39lAiMnwzfupVN1qmHGEfCvF5fTLOYuurj4XdwyrPJ2krZWakxrZ1OCflXiMh)mLYXabvq7JV7x0qmBSYkOEEpszHflrfT16rkrubHntPJ2krZWakxrZ1OCflXiMhpyEKfqJKqaASMbqh9fpdqR61eaTU8FE8r9nw8Eaf51vvZJhqJmQQ(6gZZoG(jQAigGI93aueUmeauwTrr9BaOjeGgRza0O9fpdq7AYIDvaTpavj1gZ8ak02Oa6OZJhq)UaOrsianwZaOJgqR61eaTU8FE8r9nw8Eaf51vvZJhqJmQQ(6gZdOXAga9R2mHbGI93aueUmeauwTrr9BaOjeGgRzwafQXmpGMpGYjHokGAvfaf3VbOneGQKsF8D)cGQCAcG2lGIq7QwVakSTjIcyUJTSVVW1QtuWgIziOXnkQFd2XXWbrB(Yl2ROc7jKcOgZ8tW(B6v4LlcOgZ8fupUzirPlZjq9YlLt(pp(O(g7126QQ5XRDvvFDJ5zHfOgZ8ruZ305csbLtVVg3VHuW8ilGQKNwvaTU8FE8r9nw8Eaf51vvZJhqJmQQ(6gZdO9fIbOiCziaOSAJI63aqtianwZSaQTU6dO(kaAFakU7WOJESdOTvv2O5la6BTkGY85XdOiCziaOSAJI63aqtianwZSakMzx5mafQXmpG6OnZzaA(aQCndFva1Aa9zEZZdqTQcG6OnZzaAdbOwIkaAqGmafQxa1VyaAdbOXAMfqT1vFa1Aaf3OcG2qqakU7WOJEG5o2Y((cxRorbBiMHGg3OO(nyhhdheT5lVyVIkSNqkGAmZpb7VPxHxUiGAmZxq94MTmNa1lVuo5)84J6BSxBRRQMhV2vv91nMFgU7WOJEfOvK4ppETTUAzfupVN1ibQXmF8HKA(MoxqkOC6914(TPa7VPxHxoKQe84bsNH7om6OxX8vBRRwwb1Z7znsGAmZhFiPMVPZfKckNEFnUFBkW(B6v4LdPkbpEG0zirPMhKZkVjsqBRRYclMhKZkVjsqBRRod3Dy0rVYBIe026QLvq98EwJeOgZ8XhsQ5B6CbPGYP3xJ73McS)MEfE5qQsWJhifPG5o2Y((cxRorbBVjsqBRRYEcPaQXm)eS)MEfE5IaQXmFb1Jdm3Xw23x4A1jky7Lvvot)wE8SJJHdI28LxSxrf2tifJ2kVSQYz63YJVSc0kFvNliZukhdeub39oYZnzO9)DMGvyubZDSL99fUwDIc2w57ZT841(UDuWChBzFFHRvNOGTOzyOF1Ct7bZDSL99fUwDIc2WDVJ8CtgA)FNjySNqkukhdeub39oYZnzO9)DMGvyubZDSL99fUwDIc2q7JV7x0CPjSNqk4yGGkO9X39lAiMnwHrLfwGAmZpXXw2xbXme04gf1Vrb7VPxHxowd1yMVG6XXclCmqqfC37ip3KH2)3zcwHrfm3Xw23x4A1jkyBDvRx9BBIOWoogoiAZxEXEfvaZDSL99fUwDIc2IMHbuUIMRr5ypHumARenddOCfnxJYvwbALVQZfeWChBzFFHRvNOGTxwv5m9B5XZoogoiAZxEXEfvypHuWXabvQLQY(6AY1OfgvWCWChBzFFbpEfv9vT7J9esH5b5SIjl6RBiTC8oVGkNvKZ5cYyguJz(iGAmZxq94aZDSL99f84NOGnMx0PjOSFoQOySIpGYv01K)La7jKcCxto)ScIX20Vz4UdJo6vw57ZT841(UD0YkOEEpRRmnwyrP4UMC(zfeJTPFG5o2Y((cE8tuWgxO7HgIzJXEcPa3Dy0rVcU7DKNBYq7)7mbRScQN3Z6PpnWChBzFFbp(jkyZpS826bn2db2tif4UdJo6vWDVJ8CtgA)FNjyLvq98Ewp9PbM7yl77l4XprbBq5kCHUhSNqkWDhgD0RG7Eh55Mm0()otWkRG659SE6tdm3Xw23xWJFIc2cjFv71iuZm4rLZaZDSL99f84NOGnoNx3qABtmIp7jKcC3Hrh9kiMHGg3OO(nkqmHGEfCvF5fTLOcR5XdWChBzFFbp(jkyJt2xweZJN9esbU7WOJEfC37ip3KH2)3zcwzfupVN1r(0yHflrfT16rkruz6G5o2Y((cE8tuWgkt8h)bbm3Xw23xWJFIc2uBl7J9esH5lVyflrfT16rkre5tJfw4yGGk4U3rEUjdT)VZeScJkyUJTSVVGh)efSz(QT1vzpHua1yMFc2FtVcVCra1yMVG6XnBzobQxEP8ntaQxErlOCY(fHvysvvzmZ8vBRRwwb1Z7JGhpMH7om6Oxbk4Ruwb1Z7JGhpMHehBznrlNGMYZ6kSWIJTSMOLtqt5vuzMLOI2A9ifwpvLGhpqkyUJTSVVGh)efSbf8vypKNOXdfiyQSNqkGAmZpb7VPxHxUiGAmZxq94Mz(QT1vlmQZwMtG6LxkFZeG6Lx0ckNSFryfMuvvgZSev0wRhPWAeIsWJhG5o2Y((cE8tuWgIziO)QTXEcPWXwwt0YjOP8kQmZ8LxSILOI2A9iLiGAmZhFiPMVPZfKckNEFnUFBkW(B6v4LdPkbpEaM7yl77l4XprbBO9X39lAU0e2tifo2YAIwobnLxrLzMV8IvSev0wRhPebuJz(4dj18nDUGuq507RX9Btb2FtVcVCivj4XdWChBzFFbp(jkyBDvRx9BBIOWEcPWXwwt0YjOP8kQmZ8LxSILOI2A9iLiGAmZhFiPMVPZfKckNEFnUFBkW(B6v4LdPkbpEaM7yl77l4XprbB(Rkyt3qARQOfNpiSNqkmF5fRmY38dlSwrKdMdM7yl77l4G41efVSQYz63YJNDCmCq0MV8I9kQWEcPW8GCwPASX6VMlnPiNZfKXmogiOsTuv2xxtUgTScQN3pJJbcQulvL911KRrlRG659rWJhG5o2Y((coiEnzIc2IMHH(vZnThm3Xw23xWbXRjtuW2kFFULhV23TJcM7yl77l4G41KjkylAggq5kAUgLJ9esbetiOxbx1xErBjQebpEaM7yl77l4G41Kjkydx1rCD0hm3Xw23xWbXRjtuWghJHRkBm2tifJ2kF11vpjO5AuUILyeZJFgsgTvYZK98GMliYip(YBogXiqalSmAR8vxx9KGMRr5kRG659rWJhifm3Xw23xWbXRjtuWg23Ac7jKIrBLV66QNe0CnkxXsmI5XdM7yl77l4G41KjkyBiUvvJR6iUok7jKcOgZ8tW(B6v4LlcOgZ8fupoWChBzFFbheVMmrbB4U3rEUjdT)VZemWChBzFFbheVMmrbBCmgUQSXypHuGR6lV8AO1Xw2NhyncktDgU7WOJELOzyaLRO5AuUcetiOxbx1xErBjQW6xvcbT5lVyF8HaWChBzFFbheVMmrbBqb)qmpE9BBIOWEcPaQXm)eS)MEfE5IaQXmFb1Jdm3Xw23xWbXRjtuWg23Ac7jKcC3Hrh9krZWakxrZ1OCfiMqqVcUQV8I2suH1VQecAZxEX(4dbZmpiNv8GAvxRUYWTElY5CbzaM7yl77l4G41KjkydXme04gf1Vb74y4GOnF5f7vuH9esbuJz(jy)n9k8YfbuJz(cQh3miMqqVcUQV8I2sujcE8ygswMtG6LxkN8FE8r9n2RT1vvZJx7QQ(6gZxewHjvvLXmC3Hrh9kqRiXFE8ABD1YkOEE)mC3Hrh9kMVABD1YkOEEplSO0L5eOE5LYj)NhFuFJ9ABDv1841UQQVUX8fHvysvvzGuWChBzFFbheVMmrbBrZWakxrZ1OCSNqku6OTs0mmGYv0CnkxXsmI5XdM7yl77l4G41KjkyJJXWvLng7jKcKO0tIZ0rtnxJYv(QRREsGfwuQ5b5Ss0mmGYv05bX8zFf5CUGmq6mC3Hrh9krZWakxrZ1OCfiMqqVcUQV8I2suH1VQecAZxEX(4dbG5o2Y((coiEnzIc2W(wtypHuG7om6OxjAggq5kAUgLRaXec6vWv9Lx0wIkS(vLqqB(Yl2hFiam3Xw23xWbXRjtuWgIziO)QTbM7yl77l4G41Kjkydk4XKH(R2gyUJTSVVGdIxtMOGnxJYSdz1nKgVD0hm3Xw23xWbXRjtuW2BIe026QG5o2Y((coiEnzIc2EzvLZ0VLhp74y4GOnF5f7vuH9esXkqR8vDUGmZ8GCwPASX6VMlnPiNZfKXmZxEXkwIkAR1Juyncdm3Xw23xWbXRjtuWg23AcyUJTSVVGdIxtMOGneZqqJBuu)gSJJHdI28LxSxrf2tifqnM5NG930RWlxeqnM5lOECZqYYCcuV8s5K)ZJpQVXETTUQAE8Axv1x3y(IWkmPQQmMH7om6OxbAfj(ZJxBRRwwb1Z7NH7om6OxX8vBRRwwb1Z7zHfLUmNa1lVuo5)84J6BSxBRRQMhV2vv91nMViSctQQkdKcM7yl77l4G41Kjky7Lvvot)wE8SJJHdI28LxSxrf2tifRaTYx15ccyUJTSVVGdIxtMOGn0(47(fnxAc74y4GOnF5f7vubm3Xw23xWbXRjtuW26QwV632erHDCmCq0MV8I9kQaMdM7yl77lN5kEtKG2wxfm3Xw23xoZNOGnOvK4ppETTUk7jKcLYXabvIMHH(vZnTVScQN3ZclCmqqLOzyOF1Ct7lRG659ZWDhgD0RGygcACJI63OScQN3dM7yl77lN5tuWM5R2wxL9esHs5yGGkrZWq)Q5M2xwb1Z7zHfogiOs0mm0VAUP9Lvq98(z4UdJo6vqmdbnUrr9Buwb1Z7bZbZDSL99L3ume3QQXvDexhL9esbuJz(jy)n9k8YfbuJz(cQhhyUJTSVV82efS9YQkNPFlpE2XXWbrB(Yl2ROc7jKcLoAR8YQkNPFlp(ILyeZJFM5lVyflrfT16rkSosWclCmqqLAPQSVUMCnAHrDghdeuPwQk7RRjxJwwb1Z7JGhpaZDSL99L3MOGnOGhtg6VABG5o2Y((YBtuW2kFFULhV23TJcM7yl77lVnrbBrZWq)Q5M2dM7yl77lVnrbB4U3rEUjdT)VZemWChBzFF5TjkydXme0F12aZDSL99L3MOGnOGFiMhV(TnruypHua1yMFc2FtVcVCra1yMVG6XbM7yl77lVnrbBUgLzhYQBinE7OpyUJTSVV82efSfnddOCfnxJYXEcPaIje0RGR6lVOTevIGhpyHfOgZ8tW(B6v4LlcOgZ8fupUzi5K4mD0uZ1OCLADWTmiZgTvEzvLZ0VLhFXsmI5XpB0w5Lvvot)wE8LvGw5R6CbHfwojothn1CnkxrTQSnAFYmLYXabvq7JV7x0qmBScJ6mOgZ8tW(B6v4LlcOgZ8fupUPWXw2xbXme04gf1Vrb7VPxHxoLy6iLfwSev0wRhPerLPbM7yl77lVnrbByFRjSNqkCSL1eTCcAkpRRmtPlZjq9YlLnwWr8npGOSVg3huZCJ841VTjIYxewHjvvLbyUJTSVV82efSXXy4QYgJ9esHJTSMOLtqt5zDLzkDzobQxEPSXcoIV5beL914(GAMBKhV(Tnru(IWkmPQQmMH7om6OxjAggq5kAUgLRaXec6vWv9Lx0wIkS(vLqqB(Yl2pdj4Q(YlVgADSL95bwJGYuzHLrBLV66QNe0CnkxXsmI5XJuWChBzFF5Tjky7nrcABDv2tifqnM5NG930RWlxeqnM5lOECG5o2Y((YBtuWgAF8D)IMlnHDCmCq0MV8I9kQWEcPW8GCwXdQvDT6kd36TiNZfKXmKWXabvq7JV7x0qmBScJ6mogiOcAF8D)IgIzJvwb1Z7JaQXmF8HKA(MoxqkOC6914(TPa7VPxHxoKQe84XmLYXabvIMHH(vZnTVScQN3ZclCmqqf0(47(fneZgRScQN3p7K4mD0uZ1OCf1QY2O9jifm3Xw23xEBIc2qmdbnUrr9BWoogoiAZxEXEfvypHuaXec6vWv9Lx0wIkrWJhZGAmZpb7VPxHxUiGAmZxq94aZDSL99L3MOGT1vTE1VTjIc74y4GOnF5f7vuH9esbhdeuXsvDdPTQI(vfFlV5yevmDwyz0w5RUU6jbnxJYvSeJyE8G5o2Y((YBtuWgAF8D)IMlnH9esXOTYxDD1tcAUgLRyjgX84bZDSL99L3MOGTxwv5m9B5XZoogoiAZxEXEfvypHuSc0kFvNliZmF5fRyjQOTwpsH1rcwyHJbcQulvL911KRrlmQG5o2Y((YBtuWw0mmGYv0Cnkh7jKItIZ0rtnxJYv(QRREsyguJzEwxZ305csbLtVVg3VPeiy2OTYlRQCM(T84lRG659SEQkbpEaM7yl77lVnrbB4QoIRJ(G5o2Y((YBtuWgIziOXnkQFd2XXWbrB(Yl2ROc7jKcOgZ8tW(B6v4LlcOgZ8fupoWChBzFF5TjkylAggq5kAUgLJ9esXYCcuV8szJfCeFZdik7RX9b1m3ipE9BBIO8fHvysvvzaM7yl77lVnrbBO9X39lAU0e2XXWbrB(Yl2ROc7jKcogiOcAF8D)IgIzJvyuzHfOgZ8tCSL9vqmdbnUrr9BuW(B6v4LJ1qnM5lOECtrLPYclJ2kF11vpjO5AuUILyeZJNfw4yGGkrZWq)Q5M2xwb1Z7bZDSL99L3MOGT1vTE1VTjIc74y4GOnF5f7vubm3Xw23xEBIc2IMHbuUIMRr5ypHuCsCMoAQ5AuUsTo4wgKzJ2kVSQYz63YJVyjgX84zHLtIZ0rtnxJYvuRkBJ2NWclNeNPJMAUgLR8vxx9KWmOgZ8SEQtJyeJqa]] )


end