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


    spec:RegisterPack( "Survival", 20210703, [[d80uMbqisQ6rssPUKKuzta0NeIAuqqNccSkuj1RaWSqL6wac2Le)cv0WaK6ysILbr6zqeMgQeCnajBdquFdqOXHkjohQKuRdqK3HkHqZtiCpsY(iPYbLKclKKYdHiAIssr6IOsiyJOsi5JcrWirLqQtkerReq9sujuZuis3uskc7us1pLKIOHIkHOLIkj5PanvuHVkeHgRKuYEr8xsnyuomvlgjpgQjRWLj2SI(mQA0cvNw0QLKI61quZwWTrQDRYVLA4K44Os0Yv65QA6uUoK2UKY3fkJxsY5fsRxsQA(qO9dAsfcheWHBcPosbAKwbObIansuQGeanxPcsjGwufHaQ4yKDEHaEoTqabr3Aznpqav8OH2heoiGFJUyHawTHS4MP8ajo5KpT4OufCtZ5N0Ob3Y(WRpno)KgZjbKcndwK8iueWHBcPosbAKwbObIansuQGeanxbO5keqh1I3lbemPrscy8CmKJqrahYJjGGOBTSMhGmUOrptwiWaJgIczib3qgsbAKwHagY3EcheWZCchK6viCqaDSL9raFtKG2wxHakNtfKbrnIrQJucheq5CQGmiQraXBAYMobu9qgf6CwILHH(vYnTVScTN3dziIiKrHoNLyzyOFLCt7lRq759qgGqgU7WOJDfKZqqJBAA)gLvO98EcOJTSpc4CfP6ZJxBRRqmsDKGWbbuoNkidIAeq8MMSPtavpKrHoNLyzyOFLCt7lRq759qgIiczuOZzjwgg6xj30(Yk0EEpKbiKH7om6yxb5me04MM2VrzfApVNa6yl7JaA(QT1vigXiGdz6ObJWbPEfcheqhBzFeqA0QV6dcbuoNkidIAeJuhPeoiGY5ubzquJa6yl7JaARFCjAgYQppE9hVnc4qE8Mkw2hbmsOHmpU4diZVbKXX6hxIMHS6fiRoxKijKjNqNYZnKftGSrFr2GSrdzw88HSzVqMsWJk7dzuc2rFbYslYdiJsGmRBi7vCA6OqMFdilMazy)ISbzR4JmefY4y9JlHSxrW5mXqgf6C(fciEtt20jGQhYmF5fRKVwj4rLLyK6ibHdcOJTSpci6l60e6NakNtfKbrnIrQZfiCqaLZPcYGOgb0Xw2hbe7HG2Xw2NoKVrad5B6ZPfciE8eJuhOiCqaLZPcYGOgbeVPjB6eqhBznrlNqNYdzrazibKbiKzEqoRqL7419uRSs0ICovqgeqhBzFeqShcAhBzF6q(gbmKVPpNwiGuTcXi1bYeoiGY5ubzquJaI30KnDcOJTSMOLtOt5HSiGmKaYaeYupKzEqoRqL7419uRSs0ICovqgeqhBzFeqShcAhBzF6q(gbmKVPpNwiGVrmsDGiHdcOCovqge1iG4nnztNa6ylRjA5e6uEitDqgsjGo2Y(iGype0o2Y(0H8ncyiFtFoTqaXbXRjeJuNRq4Ga6yl7Ja6l2prB9UYzeq5CQGmiQrmIravwb30uUr4GuVcHdcOCovqge1iGTcb8flNeq8MMSPtanpiNvO7JV7x0uPjf5CQGmiGd5XBQyzFeqGrdrHmKGBidPansRqaR5R(CAHastP3xJ73iGo2Y(iG18nDQGqaR5burlHxiGo2Y(kRRy9QFBtKLcUFJawZdOcb0Xw2xHUp(UFrtLMuW9BeJuhPeoiGo2Y(iGpknDFAfXiGY5ubzquJyK6ibHdcOJTSpcivBwqg6zWJkJy5XRTUQ8iGY5ubzquJyK6CbcheqhBzFeWzq(441NgbuoNkidIAeJuhOiCqaLZPcYGOgbeVPjB6eWf9KzV8s5B0WSxErl0uY(fHlrtffzqaDSL9ranF126keJuhit4Ga6yl7Ja(MibTTUcbuoNkidIAeJyeW3iCqQxHWbbuoNkidIAeq8MMSPtaNng9HmaGmS)MEfE5GSiGSzJr)cTxfb0Xw2hbCiUfxJJ7iVonXi1rkHdcOCovqge1iGo2Y(iGVSkYz63YJNaI30KnDcO6HSrBLxwf5m9B5XxSeJCE8qgGqM5lVyflPfT16rkqM6GmGiKHiIqgf6CwQLkY(6AY10fufidqiJcDol1sfzFDn5A6Yk0EEpKfbKXJheqCuCq0MV8I9K6vigPosq4Ga6yl7JaodEuzO)4TraLZPcYGOgXi15ceoiGo2Y(iGR895wE8AF3ogbuoNkidIAeJuhOiCqaDSL9raJLHH(vYnTNakNtfKbrnIrQdKjCqaDSL9raXDVJ8CtgA)Fhnyeq5CQGmiQrmsDGiHdcOJTSpciYziO)4TraLZPcYGOgXi15keoiGY5ubzquJaI30KnDc4SXOpKbaKH930RWlhKfbKnBm6xO9QiGo2Y(iGZGFiNhV(TnrwigPoxnHdcOJTSpcORPr3HS6EQXBh7jGY5ubzquJyK6vaAcheq5CQGmiQraXBAYMobCIgc6vWX9Lx0wslqweqgpEaziIiKnBm6dzaazy)n9k8YbzrazZgJ(fAVkidqidHq2jvz6yPMQPPk16GBzqGmaHSrBLxwf5m9B5XxSeJCE8qgGq2OTYlRICM(T84lRmx5J7ubbYqeri7KQmDSut10ufL4Y209jqgGqM6Hmk05Sq3hF3VONOB0cQcKbiKnBm6dzaazy)n9k8YbzrazZgJ(fAVkidiazo2Y(kiNHGg300(nky)n9k8YbzCnKHeqgcGmereYSKw0wRhPazrazvaAcOJTSpcySmmM5kAQMMIyK6vQq4GakNtfKbrnciEtt20jGo2YAIwoHoLhYuhKvbYaeYupKTONm7LxkB0GJ8BEazzFnUVzJEJ841VTjYYxeUenvuKbb0Xw2hbe7BnHyK6vqkHdcOCovqge1iG4nnztNa6ylRjA5e6uEitDqwfidqit9q2IEYSxEPSrdoYV5bKL914(Mn6nYJx)2MilFr4s0urrgqgGqgU7WOJDLyzymZv0unnvzIgc6vWX9Lx0wslqM6GSxrcbT5lVypKbiKHqidh3xE51Z1Xw2NhGm1bziTauqgIiczJ2kF81vojOPAAQILyKZJhYqab0Xw2hbKc1WXLnkXi1RGeeoiGY5ubzquJaI30KnDc4SXOpKbaKH930RWlhKfbKnBm6xO9QiGo2Y(iGVjsqBRRqms9kCbcheq5CQGmiQraDSL9raP7JV7x0uPjeq8MMSPtanpiNv8GsCxRSYWTElY5ubzazaczieYOqNZcDF8D)IEIUrlOkqgGqgf6CwO7JV7x0t0nAzfApVhYIaYMng9HmoHmecz18nDQGuOP07RX9BqgqaYW(B6v4LdYqaKX1qgpEazaczQhYOqNZsSmm0VsUP9LvO98EidreHmk05Sq3hF3VONOB0Yk0EEpKbiKDsvMowQPAAQIsCzB6(eidbeqCuCq0MV8I9K6vigPEfGIWbbuoNkidIAeqhBzFeqKZqqJBAA)geq8MMSPtaNOHGEfCCF5fTL0cKfbKXJhqgGq2SXOpKbaKH930RWlhKfbKnBm6xO9QiG4O4GOnF5f7j1Rqms9kazcheq5CQGmiQraDSL9raxxX6v)2Mileq8MMSPtaPqNZILk6EQT4I(veFlV5yKHmvqgsaziIiKnAR8Xxx5KGMQPPkwIropEciokoiAZxEXEs9keJuVcqKWbbuoNkidIAeq8MMSPtahTv(4RRCsqt10uflXiNhpb0Xw2hbKUp(UFrtLMqms9kCfcheq5CQGmiQraDSL9raFzvKZ0VLhpbeVPjB6eWvMR8XDQGazaczMV8IvSKw0wRhPazQdYaIqgIiczuOZzPwQi7RRjxtxqviG4O4GOnF5f7j1Rqms9kC1eoiGY5ubzquJaI30KnDc4jvz6yPMQPPkF81vojazaczZgJ(qM6GSA(Movqk0u6914(niJRHmKczaczJ2kVSkYz63YJVScTN3dzQdYakiJRHmE8Ga6yl7JagldJzUIMQPPigPosbAcheqhBzFeqCCh51PFcOCovqge1igPosRq4GakNtfKbrncOJTSpciYziOXnnTFdciEtt20jGZgJ(qgaqg2FtVcVCqweq2SXOFH2RIaIJIdI28LxSNuVcXi1rksjCqaLZPcYGOgbeVPjB6eWf9KzV8szJgCKFZdil7RX9nB0BKhV(Tnrw(IWLOPIImiGo2Y(iGXYWyMROPAAkIrQJuKGWbbuoNkidIAeqhBzFeq6(47(fnvAcbeVPjB6eqk05Sq3hF3VONOB0cQcKHiIq2SXOpKbaK5yl7RGCgcACtt73OG930RWlhKPoiB2y0Vq7vbzabiRcqbziIiKnAR8Xxx5KGMQPPkwIropEidreHmk05Seldd9RKBAFzfApVNaIJIdI28LxSNuVcXi1rkxGWbbuoNkidIAeqhBzFeW1vSE1VTjYcbehfheT5lVypPEfIrQJuGIWbbuoNkidIAeq8MMSPtapPkthl1unnvPwhCldcKbiKnAR8YQiNPFlp(ILyKZJhYqeri7KQmDSut10ufL4Y209jqgIiczNuLPJLAQMMQ8Xxx5KaKbiKnBm6dzQdYakGMa6yl7JagldJzUIMQPPigXiG4Xt4GuVcHdcOCovqge1iG4nnztNaAEqoRyYs)6EQLJ35fA5SICovqgqgGq2SXOpKfbKnBm6xO9QiGo2Y(iGX9vP7JyK6iLWbbuoNkidIAeqhBzFeWXk(yMRORj)lbciEtt20jG4UMC(zfKJUPFqgGqgU7WOJDLv((ClpETVBhRScTN3dzQdYQa0qgIiczQhYWDn58ZkihDt)iGNtleWXk(yMRORj)lbIrQJeeoiGY5ubzquJa6yl7Jawn3g6Xl5U6H8wErFn2dbciEtt20jGuOZzb39oYZnzO9)D0GvqvGmereYSKw0wRhPazrazirfc450cbSAUn0JxYD1d5T8I(AShceJuNlq4GakNtfKbrnciEtt20jGuOZzb39oYZnzO9)D0GvqviGo2Y(iGuHUh6j6gLyK6afHdcOCovqge1iG4nnztNasHoNfC37ip3KH2)3rdwbvHa6yl7Ja6hwEB9Gg7HaXi1bYeoiGY5ubzquJaI30KnDcif6CwWDVJ8CtgA)FhnyfufcOJTSpc4mxHk09GyK6archeqhBzFeWqYh3ED1m6GNwoJakNtfKbrnIrQZviCqaLZPcYGOgbeVPjB6eqC3Hrh7kiNHGg300(nkt0qqVcoUV8I2sAbYuhKXJheqhBzFeqkNx3tTTjg5NyK6C1eoiGY5ubzquJaI30KnDcif6CwWDVJ8CtgA)FhnyfufidreHmlPfT16rkqweqwfKGa6yl7Jasj7llY5Xtms9kanHdcOJTSpcinA1x9bHakNtfKbrnIrQxPcHdcOCovqge1iG4nnztNaot(4MEfApVhYIaYaYanKHiIqgf6CwWDVJ8CtgA)FhnyfufcOJTSpcOsBzFeJuVcsjCqaLZPcYGOgbeVPjB6eqeczZgJ(qweqgqeOHmereYWDhgDSRG7Eh55Mm0()oAWkRq759qweqgpEaziaYaeYqiK9nAGkVrrb9n0GOLfvXY(kY5ubzaziIiK9nAGkVrPwhCldI(7qn5SICovqgqgciGo2Y(iGZG8XXRpncyEMSlQIPZjbeh3Vtc5XdO6)gnqL3OOG(gAq0YIQyzFeJuVcsq4GakNtfKbrnciEtt20jGZgJ(qgaqg2FtVcVCqweq2SXOFH2RcYaeYw0tM9YlLVrdZE5fTqtj7xeUenvuKbKbiKz(QT1vkRq759qweqgpEazacz4UdJo2vMbFLYk0EEpKfbKXJhqgGqgcHmhBznrlNqNYdzQdYQaziIiK5ylRjA5e6uEitfKvbYaeYSKw0wRhPazQdYakiJRHmE8aYqab0Xw2hb08vBRRqms9kCbcheq5CQGmiQraDSL9raNbFfciEtt20jGZgJ(qgaqg2FtVcVCqweq2SXOFH2RcYaeYmF126kfufidqiBrpz2lVu(gnm7Lx0cnLSFr4s0urrgqgGqML0I2A9ifitDqgxaY4AiJhpiGH8enEqarkqrms9kafHdcOCovqge1iG4nnztNa6ylRjA5e6uEitfKvbYaeYmF5fRyjTOTwpsbYIaYMng9HmoHmecz18nDQGuOP07RX9BqgqaYW(B6v4LdYqaKX1qgpEqaDSL9rarodb9hVnIrQxbit4GakNtfKbrnciEtt20jGo2YAIwoHoLhYubzvGmaHmZxEXkwslAR1JuGSiGSzJrFiJtidHqwnFtNkifAk9(AC)gKbeGmS)MEfE5GmeazCnKXJheqhBzFeq6(47(fnvAcXi1RaejCqaLZPcYGOgbeVPjB6eqhBznrlNqNYdzQGSkqgGqM5lVyflPfT16rkqweq2SXOpKXjKHqiRMVPtfKcnLEFnUFdYacqg2FtVcVCqgcGmUgY4XdcOJTSpc46kwV632ezHyK6v4keoiGY5ubzquJaI30KnDcO5lVyLr(MFybYuNkiditaDSL9ra9xrWMUNAlUOfNpieJyeqQwHWbPEfcheq5CQGmiQraDSL9raFzvKZ0VLhpbeVPjB6eqk05SulvK911KRPlRq759qgGqgcHmk05SulvK911KRPlRq759qweqgpEaziIiKTYCLpUtfeidbeqCuCq0MV8I9K6vigPosjCqaLZPcYGOgb0Xw2hbe5me04MM2VbbeVPjB6eWzJrFidaid7VPxHxoilciB2y0Vq7vbzaczuOZz5Kpp(y(g9126kk5XRDffFDd9lOkqgIiczZgJ(qgaqg2FtVcVCqweq2SXOFH2RcYaaYQa0qgGqgf6Cwo5ZJpMVrFTTUIsE8AxrXx3q)cQcKbiKrHoNLt(84J5B0xBRROKhV2vu81n0VScTN3dzraz84bbehfheT5lVypPEfIrQJeeoiGo2Y(iGiNHG(J3gbuoNkidIAeJuNlq4GakNtfKbrnciEtt20jGZgJ(qgaqg2FtVcVCqweq2SXOFH2RcYaeYupKzjg584HmaHSjAiOxbh3xErBjTazraz84bb0Xw2hbmwggZCfnvttrmsDGIWbbuoNkidIAeq8MMSPtaNng9HmaGmS)MEfE5GSiGSzJr)cTxfb0Xw2hbCg8d5841VTjYcXi1bYeoiGo2Y(iGZGhvg6pEBeq5CQGmiQrmsDGiHdcOCovqge1iG4nnztNaUONm7LxkN8FE8X8n6RT1vuYJx7kk(6g6xeUenvuKbKbiKnBm6dzraz18nDQGuOP07RX9BeqhBzFeqShcAhBzF6q(gbmKVPpNwiGN5eJuNRq4GakNtfKbrnciEtt20jGZgJ(qgaqg2FtVcVCqweq2SXOFH2RIa6yl7Jaoe3IRXXDKxNMyK6C1eoiGY5ubzquJa6yl7JaUUI1R(TnrwiG4nnztNasHoNfC37ip3KH2)3rdwbvbYaeYOqNZcU7DKNBYq7)7ObRScTN3dzrazvkafKX1qgpEqaXrXbrB(Yl2tQxHyK6vaAcheq5CQGmiQraDSL9raP7JV7x0uPjeq8MMSPtaPqNZcU7DKNBYq7)7ObRGQazaczuOZzb39oYZnzO9)D0GvwH2Z7HSiGSkfGcY4AiJhpiG4O4GOnF5f7j1Rqms9kviCqaDSL9raDnn6oKv3tnE7ypbuoNkidIAeJuVcsjCqaLZPcYGOgb0Xw2hbCDfRx9BBISqaXBAYMobKcDolwQO7P2Il6xr8T8MJrgYubzibbehfheT5lVypPEfIrQxbjiCqaLZPcYGOgbeVPjB6eWzJrFidaid7VPxHxoilciB2y0Vq7vbzaczQhYSeJCE8qgGqgcHSjAiOxbh3xErBjTazraz84bKHiIqM6HSrBLyzymZv0unnvXsmY5XdzaczuOZzHUp(UFrpr3OLvO98EitDq2ene0RGJ7lVOTKwGmGaKvbY4AiJhpGmereYupKnAReldJzUIMQPPkwIropEidqit9qgf6CwO7JV7x0t0nAzfApVhYqaKHiIqML0I2A9ifilciRcxbYaeYupKnAReldJzUIMQPPkwIropEcOJTSpcySmmM5kAQMMIyK6v4ceoiGY5ubzquJa6yl7JaICgcACtt73GaIJIdI28LxSNuVcbeVPjB6eWzJrFidaid7VPxHxoilciB2y0Vq7vbzaczieYupKTONm7LxkN8FE8X8n6RT1vuYJx7kk(6g6xKZPcYaYqeriB2y0hYIaYQ5B6ubPqtP3xJ73GmeqahYJ3uXY(iGrYjKfTrHSrFr2GS4EnbYQl)NhFmFJg5hY4yDfL84HSQHIIVUH(CdzFsReIczy)niJlodbidjBAA)gqwoHSOnkKfRViBqwxtwSRaz9bzCr1y0hYMBtdzJopEi77cKfjNqw0gfYgnKf3RjqwD5)84J5B0i)qghRROKhpKvnuu81n0hYI2Oq2hVrddid7VbzCXziaziztt73aYYjKfTrxiB2y0hYYhYOKqhdYS4cKH73GSEczvt0hF3VazQLMaz9czCvUI1lKbABISqms9kafHdcOCovqge1iGo2Y(iGiNHGg300(niG4O4GOnF5f7j1RqaXBAYMobC2y0hYaaYW(B6v4LdYIaYMng9l0EvqgGq2IEYSxEPCY)5XhZ3OV2wxrjpETRO4RBOFroNkididqid3Dy0XUYCfP6ZJxBRRuwH2Z7Hm1bzieYMng9HmoHmecz18nDQGuOP07RX9BqgqaYW(B6v4LdYqaKX1qgpEaziaYaeYWDhgDSRy(QT1vkRq759qM6GmeczZgJ(qgNqgcHSA(Movqk0u6914(nidiazy)n9k8YbziaY4AiJhpGmeazaczieYupKzEqoR8MibTTUsroNkididreHmZdYzL3ejOT1vkY5ubzazacz4UdJo2vEtKG2wxPScTN3dzQdYqiKnBm6dzCczieYQ5B6ubPqtP3xJ73GmGaKH930RWlhKHaiJRHmE8aYqaKHac4qE8Mkw2hbmsmT4qwD5)84J5B0i)qghRROKhpKvnuu81n0hY6lefY4IZqaYqYMM2VbKLtilAJUqMTUYdz(kqwFqgU7WOJDCdzTfx2y5lq2BTcKH(5XdzCXziaziztt73aYYjKfTrxidJURCgKnBm6dzoDJEgKLpKjxJYhhYSgYE0388GmlUazoDJEgK1tiZsAbYcY0GSzVqMFrHSEczrB0fYS1vEiZAid30cK1ZjKH7om6yhXi1RaKjCqaLZPcYGOgbeVPjB6eWzJrFidaid7VPxHxoilciB2y0Vq7vraDSL9raFtKG2wxHyK6vaIeoiGY5ubzquJa6yl7Ja(YQiNPFlpEciEtt20jGJ2kVSkYz63YJVSYCLpUtfeidqit9qgf6CwWDVJ8CtgA)FhnyfufciokoiAZxEXEs9keJuVcxHWbb0Xw2hbCLVp3YJx772XiGY5ubzquJyK6v4QjCqaDSL9raJLHH(vYnTNakNtfKbrnIrQJuGMWbbuoNkidIAeq8MMSPtavpKrHoNfC37ip3KH2)3rdwbvHa6yl7JaI7Eh55Mm0()oAWigPosRq4GakNtfKbrnciEtt20jGuOZzHUp(UFrpr3OfufidreHSzJrFidaiZXw2xb5me04MM2Vrb7VPxHxoitDq2SXOFH2RcYqeriJcDol4U3rEUjdT)VJgScQcb0Xw2hbKUp(UFrtLMqmsDKIucheq5CQGmiQraDSL9raxxX6v)2MileqCuCq0MV8I9K6vigPosrccheq5CQGmiQraXBAYMobC0wjwggZCfnvttvwzUYh3Pccb0Xw2hbmwggZCfnvttrmsDKYfiCqaLZPcYGOgb0Xw2hb8Lvrot)wE8eq8MMSPtaPqNZsTur2xxtUMUGQqaXrXbrB(Yl2tQxHyeJaIdIxtiCqQxHWbbuoNkidIAeqhBzFeWxwf5m9B5XtaXBAYMob08GCwjE0X6VMknPiNtfKbKbiKrHoNLAPISVUMCnDzfApVhYaeYOqNZsTur2xxtUMUScTN3dzraz84bbehfheT5lVypPEfIrQJucheqhBzFeWyzyOFLCt7jGY5ubzquJyK6ibHdcOJTSpc4kFFULhV23TJraLZPcYGOgXi15ceoiGY5ubzquJaI30KnDc4ene0RGJ7lVOTKwGSiGmE8Ga6yl7JagldJzUIMQPPigPoqr4Ga6yl7JaIJ7iVo9taLZPcYGOgXi1bYeoiGY5ubzquJaI30KnDc4OTYhFDLtcAQMMQyjg584HmaHmeczJ2k5zYEEqtfezKhF5nhJmKfbKHuidreHSrBLp(6kNe0unnvzfApVhYIaY4XdidbeqhBzFeqkudhx2OeJuhis4GakNtfKbrnciEtt20jGJ2kF81vojOPAAQILyKZJNa6yl7JaI9TMqmsDUcHdcOCovqge1iG4nnztNaoBm6dzaazy)n9k8YbzrazZgJ(fAVkcOJTSpc4qClUgh3rEDAIrQZvt4Ga6yl7JaI7Eh55Mm0()oAWiGY5ubzquJyK6vaAcheq5CQGmiQraXBAYMobeh3xE51Z1Xw2NhGm1bziTauqgGqgU7WOJDLyzymZv0unnvzIgc6vWX9Lx0wslqM6GSxrcbT5lVypKXjKHucOJTSpcifQHJlBuIrQxPcHdcOCovqge1iG4nnztNaoBm6dzaazy)n9k8YbzrazZgJ(fAVkcOJTSpc4m4hY5XRFBtKfIrQxbPeoiGY5ubzquJaI30KnDciU7WOJDLyzymZv0unnvzIgc6vWX9Lx0wslqM6GSxrcbT5lVypKXjKHuidqiZ8GCwXdkXDTYkd36TiNtfKbb0Xw2hbe7BnHyK6vqccheq5CQGmiQraDSL9rarodbnUPP9BqaXBAYMobC2y0hYaaYW(B6v4LdYIaYMng9l0EvqgGq2ene0RGJ7lVOTKwGSiGmE8aYaeYqiKTONm7LxkN8FE8X8n6RT1vuYJx7kk(6g6xeUenvuKbKbiKH7om6yxzUIu95XRT1vkRq759qgGqgU7WOJDfZxTTUszfApVhYqerit9q2IEYSxEPCY)5XhZ3OV2wxrjpETRO4RBOFr4s0urrgqgciG4O4GOnF5f7j1Rqms9kCbcheq5CQGmiQraXBAYMobu9q2OTsSmmM5kAQMMQyjg584jGo2Y(iGXYWyMROPAAkIrQxbOiCqaLZPcYGOgbeVPjB6eqeczQhYoPkthl1unnv5JVUYjbidreHm1dzMhKZkXYWyMROZBI(zFf5CQGmGmeazacz4UdJo2vILHXmxrt10uLjAiOxbh3xErBjTazQdYEfje0MV8I9qgNqgsjGo2Y(iGuOgoUSrjgPEfGmHdcOCovqge1iG4nnztNaI7om6yxjwggZCfnvttvMOHGEfCCF5fTL0cKPoi7vKqqB(Yl2dzCcziLa6yl7JaI9TMqms9karcheqhBzFeqKZqq)XBJakNtfKbrnIrQxHRq4Ga6yl7JaodEuzO)4TraLZPcYGOgXi1RWvt4Ga6yl7Ja6AA0DiRUNA82XEcOCovqge1igPosbAcheqhBzFeW3ejOT1viGY5ubzquJyK6iTcHdcOCovqge1iGo2Y(iGVSkYz63YJNaI30KnDc4kZv(4ovqGmaHmZdYzL4rhR)AQ0KICovqgqgGqM5lVyflPfT16rkqM6GmUcbehfheT5lVypPEfIrQJuKs4Ga6yl7JaI9TMqaLZPcYGOgXi1rksq4GakNtfKbrncOJTSpciYziOXnnTFdciEtt20jGZgJ(qgaqg2FtVcVCqweq2SXOFH2RcYaeYqiKTONm7LxkN8FE8X8n6RT1vuYJx7kk(6g6xeUenvuKbKbiKH7om6yxzUIu95XRT1vkRq759qgGqgU7WOJDfZxTTUszfApVhYqerit9q2IEYSxEPCY)5XhZ3OV2wxrjpETRO4RBOFr4s0urrgqgciG4O4GOnF5f7j1RqmsDKYfiCqaLZPcYGOgb0Xw2hb8Lvrot)wE8eq8MMSPtaxzUYh3PccbehfheT5lVypPEfIrQJuGIWbbuoNkidIAeqhBzFeq6(47(fnvAcbehfheT5lVypPEfIrQJuGmHdcOCovqge1iGo2Y(iGRRy9QFBtKfciokoiAZxEXEs9keJyeJawt2p7JuhPansRa0arGUcbmMVxE8pbmsSAWvvpswpsaibzqghXfilPv61GSzVqwKvwb30uUfziBfUenxzazFtlqMJAnTBYaYWX9Jx(ce4inpbYQaKGmKSVAYAYaYIS5b5Ss1kYqM1qwKnpiNvQwf5CQGmImK5gKXfHQjJuidHvQcbfiWqGJeRgCv1JK1JeasqgKXrCbYsALEniB2lKf53ImKTcxIMRmGSVPfiZrTM2nzaz44(XlFbcCKMNazv4cajidj7RMSMmGmWKgjHSp6zEvqw1bzwdzrkQdzJSw(zFqwRiRB9cziKteaziSsviOabgcCKy1GRQEKSEKaqcYGmoIlqwsR0RbzZEHSiJhFKHSv4s0CLbK9nTazoQ10Ujdidh3pE5lqGJ08eiRcsbsqgs2xnznzazr(B0avEJs1kYqM1qwK)gnqL3OuTkY5ubzezidHiTkeuGahP5jqwfGcibzizF1K1KbKbM0ijK9rpZRcYQoiZAilsrDiBK1Yp7dYAfzDRxidHCIaidHvQcbfiWrAEcKvbidKGmKSVAYAYaYatAKeY(ON5vbzvhKznKfPOoKnYA5N9bzTISU1lKHqoraKHWkvHGce4inpbYQaebsqgs2xnznzazGjnsczF0Z8QGSQdYSgYIuuhYgzT8Z(GSwrw36fYqiNiaYqyLQqqbcme4iXQbxv9iz9ibGeKbzCexGSKwPxdYM9czrMQvImKTcxIMRmGSVPfiZrTM2nzaz44(XlFbcCKMNazv4cajidj7RMSMmGSiVONm7LxkvRidzwdzrErpz2lVuQwf5CQGmImKHWkvHGce4inpbYQauajidj7RMSMmGmWKgjHSp6zEvqw1bzwdzrkQdzJSw(zFqwRiRB9cziKteaziejQcbfiWrAEcKvbOasqgs2xnznzazr28GCwPAfziZAilYMhKZkvRICovqgrgYqisRcbfiWrAEcKvbOasqgs2xnznzazrErpz2lVuQwrgYSgYI8IEYSxEPuTkY5ubzezidHvQcbfiWqGJeRgCv1JK1JeasqgKXrCbYsALEniB2lKfzCq8AsKHSv4s0CLbK9nTazoQ10Ujdidh3pE5lqGJ08eiRcqdKGmKSVAYAYaYatAKeY(ON5vbzvhKznKfPOoKnYA5N9bzTISU1lKHqoraKHWkvHGce4inpbYQGuGeKHK9vtwtgqgysJKq2h9mVkiR6GmRHSif1HSrwl)SpiRvK1TEHmeYjcGmewPkeuGahP5jqwfGcibzizF1K1KbKbM0ijK9rpZRcYQoiZAilsrDiBK1Yp7dYAfzDRxidHCIaidHvQcbfiWrAEcKvbidKGmKSVAYAYaYatAKeY(ON5vbzvhKznKfPOoKnYA5N9bzTISU1lKHqoraKHWkvHGceyiWrsALEnzazariZXw2hKfY3(ceyc4RiysDKcuafbuz7zgecy1gYar3AznpazCrJEMSqGR2qgWOHOqgsWnKHuGgPvGadb2Xw23xuwb30uUbGkoR5B6ubH7ZPfv0u6914(nUBfvVy5K7AEavu5yl7Rq3hF3VOPstk4(nUR5burlHxu5yl7RSUI1R(Tnrwk4(nUX9nsl7tL5b5ScDF8D)IMknbcSJTSVVOScUPPCdavC(O009PvedcSJTSVVOScUPPCdavCs1MfKHEg8OYiwE8ARRkpiWo2Y((IYk4MMYnauX5miFC86tdcSJTSVVOScUPPCdavCA(QT1v4oNQw0tM9YlLVrdZE5fTqtj7xeUenvuKbeyhBzFFrzfCtt5gaQ48nrcABDfiWqGDSL99aOItA0QV6dce4QnKfj0qMhx8bK53aY4y9JlrZqw9cKvNlsKeYKtOt55IiKftGSrFr2GSrdzw88HSzVqMsWJk7dzuc2rFbYslYdiJsGmRBi7vCA6OqMFdilMazy)ISbzR4JmefY4y9JlHSxrW5mXqgf6C(fiWo2Y(EauXPT(XLOziR(841F824oNQuV5lVyL81kbpQSqGDSL99aOIt0x0Pj0pe4QD1gYQMkbpkKnDCE8qw0gDHSrJszqg6zzaYI2OqwCVMazkOgKXvjFFULhpKvn2TJbzJo2XnK1lKLtiZIlqgU7WOJDqw(qM1nKf6JhYSgYgsWJczthNhpKfTrxiRAAJszfilsoHSRpbY6jKzXLxGmCFJ0Y(EiZxbYCQGazwdz0IbzXslEEqMfxGSkanK9cUVXdzbrI5r5gYS4cK9jnKnDS8qw0gDHSQPnkLbzoQ10ULypeIwGaxTR2qMJTSVhavCEsSzJEd9kFhQjCNtvFJgOYBuoj2SrVHELVd1earif6Cww57ZT841(UDScQcIiI7om6yxzLVp3YJx772XkRq759QRcqJiIMV8IvSKw0wRhPerfGmcGa7yl77bqfNype0o2Y(0H8nUpNwuHhpeyhBzFpaQ4e7HG2Xw2NoKVX950IkQwH7CQYXwwt0Yj0P8rGeaAEqoRqL7419uRSs0ICovqgqGDSL99aOItShcAhBzF6q(g3NtlQEJ7CQYXwwt0Yj0P8rGeaQEZdYzfQChVUNALvIwKZPcYacSJTSVhavCI9qq7yl7thY34(CArfoiEnH7CQYXwwt0Yj0P8QdPqGDSL99aOItFX(jAR3vodcmeyhBzFFHQvu9YQiNPFlpEUXrXbrB(Yl2RQc35uff6CwQLkY(6AY10LvO98Earif6CwQLkY(6AY10LvO98(i4XderCL5kFCNkiiacSJTSVVq1kaOItKZqqJBAA)gCJJIdI28LxSxvfUZPQzJrFaW(B6v4LlIzJr)cTxfGuOZz5Kpp(y(g9126kk5XRDffFDd9lOkiI4SXOpay)n9k8YfXSXOFH2RcGkanGuOZz5Kpp(y(g9126kk5XRDffFDd9lOkasHoNLt(84J5B0xBRROKhV2vu81n0VScTN3hbpEab2Xw23xOAfauXjYziO)4Tbb2Xw23xOAfauXzSmmM5kAQMMI7CQA2y0haS)MEfE5Iy2y0Vq7vbO6TeJCE8aordb9k44(YlAlPLi4XdiWo2Y((cvRaGkoNb)qopE9BBISWDovnBm6da2FtVcVCrmBm6xO9QGa7yl77luTcaQ4Cg8OYq)XBdcSJTSVVq1kaOItShcAhBzF6q(g3NtlQoZ5oNQw0tM9YlLt(pp(y(g9126kk5XRDffFDd9lcxIMkkYaWzJr)iQ5B6ubPqtP3xJ73Ga7yl77luTcaQ4CiUfxJJ7iVon35u1SXOpay)n9k8YfXSXOFH2RccSJTSVVq1kaOIZ1vSE1VTjYc34O4GOnF5f7vvH7CQIcDol4U3rEUjdT)VJgScQcGuOZzb39oYZnzO9)D0GvwH2Z7JOsbO4AE8acSJTSVVq1kaOIt6(47(fnvAc34O4GOnF5f7vvH7CQIcDol4U3rEUjdT)VJgScQcGuOZzb39oYZnzO9)D0GvwH2Z7JOsbO4AE8acSJTSVVq1kaOItxtJUdz19uJ3o2db2Xw23xOAfauX56kwV632ezHBCuCq0MV8I9QQWDovrHoNflv09uBXf9Ri(wEZXiRcjGa7yl77luTcaQ4mwggZCfnvttXDovnBm6da2FtVcVCrmBm6xO9Qau9wIropEar4ene0RGJ7lVOTKwIGhpqer1pAReldJzUIMQPPkwIropEaPqNZcDF8D)IEIUrlRq759QBIgc6vWX9Lx0wslaHkCnpEGiIQF0wjwggZCfnvttvSeJCE8aQEk05Sq3hF3VONOB0Yk0EEpcqerlPfT16rkruHRaO6hTvILHXmxrt10uflXiNhpe4QnKfjNqw0gfYg9fzdYI71eiRU8FE8X8nAKFiJJ1vuYJhYQgkk(6g6ZnK9jTsikKH93GmU4meGmKSPP9Baz5eYI2OqwS(ISbzDnzXUcK1hKXfvJrFiBUnnKn684HSVlqwKCczrBuiB0qwCVMaz1L)ZJpMVrJ8dzCSUIsE8qw1qrXx3qFilAJczF8gnmGmS)gKXfNHaKHKnnTFdilNqw0gDHSzJrFilFiJscDmiZIlqgUFdY6jKvnrF8D)cKPwAcK1lKXv5kwVqgOTjYceyhBzFFHQvaqfNiNHGg300(n4ghfheT5lVyVQkCNtvZgJ(aG930RWlxeZgJ(fAVkarO6x0tM9YlLt(pp(y(g9126kk5XRDffFDd9reXzJr)iQ5B6ubPqtP3xJ73qae4QnKfjMwCiRU8FE8X8nAKFiJJ1vuYJhYQgkk(6g6dz9fIczCXziaziztt73aYYjKfTrxiZwx5HmFfiRpid3Dy0XoUHS2IlBS8fi7TwbYq)84HmU4meGmKSPP9Baz5eYI2OlKHr3vodYMng9HmNUrpdYYhYKRr5Jdzwdzp6BEEqMfxGmNUrpdY6jKzjTazbzAq2SxiZVOqwpHSOn6cz26kpKznKHBAbY65eYWDhgDSdcSJTSVVq1kaOItKZqqJBAA)gCJJIdI28LxSxvfUZPQzJrFaW(B6v4LlIzJr)cTxfGl6jZE5LYj)NhFmFJ(ABDfL841UIIVUH(aI7om6yxzUIu95XRT1vkRq759QdHZgJ(vhcR5B6ubPqtP3xJ73acy)n9k8YHaUMhpqaG4UdJo2vmF126kLvO98E1HWzJr)QdH18nDQGuOP07RX9BabS)MEfE5qaxZJhiaqeQEZdYzL3ejOT1vqerZdYzL3ejOT1vae3Dy0XUYBIe026kLvO98E1HWzJr)QdH18nDQGuOP07RX9BabS)MEfE5qaxZJhiabqGDSL99fQwbavC(MibTTUc35u1SXOpay)n9k8YfXSXOFH2RccSJTSVVq1kaOIZxwf5m9B5XZnokoiAZxEXEvv4oNQgTvEzvKZ0VLhFzL5kFCNkiaQEk05SG7Eh55Mm0()oAWkOkqGDSL99fQwbavCUY3NB5XR9D7yqGDSL99fQwbavCgldd9RKBApeyhBzFFHQvaqfN4U3rEUjdT)VJgmUZPk1tHoNfC37ip3KH2)3rdwbvbcSJTSVVq1kaOIt6(47(fnvAc35uff6CwO7JV7x0t0nAbvbreNng9bWXw2xb5me04MM2Vrb7VPxHxo1nBm6xO9Qqerk05SG7Eh55Mm0()oAWkOkqGDSL99fQwbavCUUI1R(Tnrw4ghfheT5lVyVQkqGDSL99fQwbavCgldJzUIMQPP4oNQgTvILHXmxrt10uLvMR8XDQGab2Xw23xOAfauX5lRICM(T845ghfheT5lVyVQkCNtvuOZzPwQi7RRjxtxqvGadb2Xw23xWJxvCFv6(4oNQmpiNvmzPFDp1YX78cTCwroNkidaNng9Jy2y0Vq7vbb2Xw23xWJhavCI(IonHM7ZPfvJv8Xmxrxt(xcCNtv4UMC(zfKJUPFaI7om6yxzLVp3YJx772XkRq759QRcqJiIQh31KZpRGC0n9dcSJTSVVGhpaQ4e9fDAcn3NtlQQMBd94LCx9qElVOVg7Ha35uff6CwWDVJ8CtgA)Fhnyfufer0sArBTEKseirfiWo2Y((cE8aOItQq3d9eDJYDovrHoNfC37ip3KH2)3rdwbvbcSJTSVVGhpaQ40pS826bn2dbUZPkk05SG7Eh55Mm0()oAWkOkqGDSL99f84bqfNZCfQq3dUZPkk05SG7Eh55Mm0()oAWkOkqGDSL99f84bqfNHKpU96Qz0bpTCgeyhBzFFbpEauXjLZR7P22eJ8ZDovH7om6yxb5me04MM2VrzIgc6vWX9Lx0wslQJhpGa7yl77l4XdGkoPK9Lf5845oNQOqNZcU7DKNBYq7)7ObRGQGiIwslAR1JuIOcsab2Xw23xWJhavCsJw9vFqGa7yl77l4XdGkovAl7J7CQAM8Xn9k0EEFeazGgrePqNZcU7DKNBYq7)7ObRGQab2Xw23xWJhavCodYhhV(04opt2fvX05ufoUFNeYJhq1)nAGkVrrb9n0GOLfvXY(4oNQq4SXOFearGgreXDhgDSRG7Eh55Mm0()oAWkRq759rWJhiaqe(nAGkVrrb9n0GOLfvXY(qeXVrdu5nk16GBzq0FhQjNHaiWo2Y((cE8aOItZxTTUc35u1SXOpay)n9k8YfXSXOFH2RcWf9KzV8s5B0WSxErl0uY(fHlrtffzaO5R2wxPScTN3hbpEaiU7WOJDLzWxPScTN3hbpEaicDSL1eTCcDkV6QGiIo2YAIwoHoLxvfaTKw0wRhPOoGIR5Xdeab2Xw23xWJhavCod(kChYt04HkKcuCNtvZgJ(aG930RWlxeZgJ(fAVkanF126kfufax0tM9YlLVrdZE5fTqtj7xeUenvuKbGwslAR1JuuhxGR5XdiWo2Y((cE8aOItKZqq)XBJ7CQYXwwt0Yj0P8QQaO5lVyflPfT16rkrmBm6xDiSMVPtfKcnLEFnUFdiG930RWlhc4AE8acSJTSVVGhpaQ4KUp(UFrtLMWDov5ylRjA5e6uEvva08LxSIL0I2A9iLiMng9RoewZ30PcsHMsVVg3VbeW(B6v4LdbCnpEab2Xw23xWJhavCUUI1R(Tnrw4oNQCSL1eTCcDkVQkaA(YlwXsArBTEKseZgJ(vhcR5B6ubPqtP3xJ73acy)n9k8YHaUMhpGa7yl77l4XdGko9xrWMUNAlUOfNpiCNtvMV8Ivg5B(Hf1PcidbgcSJTSVVGdIxtu9YQiNPFlpEUXrXbrB(Yl2RQc35uL5b5Ss8OJ1FnvAsroNkidaPqNZsTur2xxtUMUScTN3dif6CwQLkY(6AY10LvO98(i4XdiWo2Y((coiEnbavCgldd9RKBApeyhBzFFbheVMaGkox57ZT841(UDmiWo2Y((coiEnbavCgldJzUIMQPP4oNQMOHGEfCCF5fTL0se84beyhBzFFbheVMaGkoXXDKxN(Ha7yl77l4G41eauXjfQHJlBuUZPQrBLp(6kNe0unnvXsmY5XdichTvYZK98GMkiYip(YBog5iqkIioAR8Xxx5KGMQPPkRq759rWJhiacSJTSVVGdIxtaqfNyFRjCNtvJ2kF81vojOPAAQILyKZJhcSJTSVVGdIxtaqfNdXT4ACCh51P5oNQMng9ba7VPxHxUiMng9l0EvqGDSL99fCq8AcaQ4e39oYZnzO9)D0Gbb2Xw23xWbXRjaOItkudhx2OCNtv44(YlVEUo2Y(8G6qAbOae3Dy0XUsSmmM5kAQMMQmrdb9k44(YlAlPf19ksiOnF5f7RoKcb2Xw23xWbXRjaOIZzWpKZJx)2MilCNtvZgJ(aG930RWlxeZgJ(fAVkiWo2Y((coiEnbavCI9TMWDovH7om6yxjwggZCfnvttvMOHGEfCCF5fTL0I6Efje0MV8I9vhsb08GCwXdkXDTYkd36TiNtfKbeyhBzFFbheVMaGkorodbnUPP9BWnokoiAZxEXEvv4oNQMng9ba7VPxHxUiMng9l0Evaordb9k44(YlAlPLi4Xdar4IEYSxEPCY)5XhZ3OV2wxrjpETRO4RBOFr4s0urrgaI7om6yxzUIu95XRT1vkRq759aI7om6yxX8vBRRuwH2Z7rer1VONm7LxkN8FE8X8n6RT1vuYJx7kk(6g6xeUenvuKbcGa7yl77l4G41eauXzSmmM5kAQMMI7CQs9J2kXYWyMROPAAQILyKZJhcSJTSVVGdIxtaqfNuOgoUSr5oNQqO6pPkthl1unnv5JVUYjberu9MhKZkXYWyMROZBI(zFf5CQGmqaG4UdJo2vILHXmxrt10uLjAiOxbh3xErBjTOUxrcbT5lVyF1HuiWo2Y((coiEnbavCI9TMWDovH7om6yxjwggZCfnvttvMOHGEfCCF5fTL0I6Efje0MV8I9vhsHa7yl77l4G41eauXjYziO)4Tbb2Xw23xWbXRjaOIZzWJkd9hVniWo2Y((coiEnbavC6AA0DiRUNA82XEiWo2Y((coiEnbavC(MibTTUceyhBzFFbheVMaGkoFzvKZ0VLhp34O4GOnF5f7vvH7CQAL5kFCNkiaAEqoRep6y9xtLMuKZPcYaqZxEXkwslAR1JuuhxbcSJTSVVGdIxtaqfNyFRjqGDSL99fCq8AcaQ4e5me04MM2Vb34O4GOnF5f7vvH7CQA2y0haS)MEfE5Iy2y0Vq7vbicx0tM9YlLt(pp(y(g9126kk5XRDffFDd9lcxIMkkYaqC3Hrh7kZvKQppETTUszfApVhqC3Hrh7kMVABDLYk0EEpIiQ(f9KzV8s5K)ZJpMVrFTTUIsE8AxrXx3q)IWLOPIImqaeyhBzFFbheVMaGkoFzvKZ0VLhp34O4GOnF5f7vvH7CQAL5kFCNkiqGDSL99fCq8AcaQ4KUp(UFrtLMWnokoiAZxEXEvvGa7yl77l4G41eauX56kwV632ezHBCuCq0MV8I9QQabgcSJTSVVCMR6nrcABDfiWo2Y((YzoaQ4CUIu95XRT1v4oNQupf6CwILHH(vYnTVScTN3JiIuOZzjwgg6xj30(Yk0EEpG4UdJo2vqodbnUPP9BuwH2Z7Ha7yl77lN5aOItZxTTUc35uL6PqNZsSmm0VsUP9LvO98EerKcDolXYWq)k5M2xwH2Z7be3Dy0XUcYziOXnnTFJYk0EEpeyiWo2Y((YBQgIBX144oYRtZDovnBm6da2FtVcVCrmBm6xO9QGa7yl77lVbGkoFzvKZ0VLhp34O4GOnF5f7vvH7CQs9J2kVSkYz63YJVyjg584b08LxSIL0I2A9if1bererk05SulvK911KRPlOkasHoNLAPISVUMCnDzfApVpcE8acSJTSVV8gaQ4Cg8OYq)XBdcSJTSVV8gaQ4CLVp3YJx772XGa7yl77lVbGkoJLHH(vYnThcSJTSVV8gaQ4e39oYZnzO9)D0Gbb2Xw23xEdavCICgc6pEBqGDSL99L3aqfNZGFiNhV(Tnrw4oNQMng9ba7VPxHxUiMng9l0EvqGDSL99L3aqfNUMgDhYQ7PgVDShcSJTSVV8gaQ4mwggZCfnvttXDovnrdb9k44(YlAlPLi4XderC2y0haS)MEfE5Iy2y0Vq7vbicpPkthl1unnvPwhCldcGJ2kVSkYz63YJVyjg584bC0w5Lvrot)wE8LvMR8XDQGGiINuLPJLAQMMQOex2MUpbq1tHoNf6(47(f9eDJwqvaC2y0haS)MEfE5Iy2y0Vq7vbeCSL9vqodbnUPP9BuW(B6v4LJRrceGiIwslAR1JuIOcqdb2Xw23xEdavCI9TMWDov5ylRjA5e6uE1vbq1VONm7LxkB0GJ8BEazzFnUVzJEJ841VTjYYxeUenvuKbeyhBzFF5nauXjfQHJlBuUZPkhBznrlNqNYRUkaQ(f9KzV8szJgCKFZdil7RX9nB0BKhV(Tnrw(IWLOPIImae3Dy0XUsSmmM5kAQMMQmrdb9k44(YlAlPf19ksiOnF5f7beH44(YlVEUo2Y(8G6qAbOqeXrBLp(6kNe0unnvXsmY5XJaiWo2Y((YBaOIZ3ejOT1v4oNQMng9ba7VPxHxUiMng9l0EvqGDSL99L3aqfN09X39lAQ0eUXrXbrB(Yl2RQc35uL5b5SIhuI7ALvgU1BroNkidarif6CwO7JV7x0t0nAbvbqk05Sq3hF3VONOB0Yk0EEFeZgJ(vhcR5B6ubPqtP3xJ73acy)n9k8YHaUMhpau9uOZzjwgg6xj30(Yk0EEpIisHoNf6(47(f9eDJwwH2Z7b8KQmDSut10ufL4Y209jiacSJTSVV8gaQ4e5me04MM2Vb34O4GOnF5f7vvH7CQAIgc6vWX9Lx0wslrWJhaoBm6da2FtVcVCrmBm6xO9QGa7yl77lVbGkoxxX6v)2MilCJJIdI28LxSxvfUZPkk05SyPIUNAlUOFfX3YBogzvibIioAR8Xxx5KGMQPPkwIropEiWo2Y((YBaOIt6(47(fnvAc35u1OTYhFDLtcAQMMQyjg584Ha7yl77lVbGkoFzvKZ0VLhp34O4GOnF5f7vvH7CQAL5kFCNkiaA(YlwXsArBTEKI6aIiIif6CwQLkY(6AY10fufiWo2Y((YBaOIZyzymZv0unnf35u1jvz6yPMQPPkF81voja4SXOV6Q5B6ubPqtP3xJ734AKc4OTYlRICM(T84lRq759QdO4AE8acSJTSVV8gaQ4eh3rED6hcSJTSVV8gaQ4e5me04MM2Vb34O4GOnF5f7vvH7CQA2y0haS)MEfE5Iy2y0Vq7vbb2Xw23xEdavCgldJzUIMQPP4oNQw0tM9YlLnAWr(npGSSVg33SrVrE8632ez5lcxIMkkYacSJTSVV8gaQ4KUp(UFrtLMWnokoiAZxEXEvv4oNQOqNZcDF8D)IEIUrlOkiI4SXOpao2Y(kiNHGg300(nky)n9k8YPUzJr)cTxfqOcqHiIJ2kF81vojOPAAQILyKZJhrePqNZsSmm0VsUP9LvO98EiWo2Y((YBaOIZ1vSE1VTjYc34O4GOnF5f7vvbcSJTSVV8gaQ4mwggZCfnvttXDovDsvMowQPAAQsTo4wgeahTvEzvKZ0VLhFXsmY5XJiINuLPJLAQMMQOex2MUpbrepPkthl1unnv5JVUYjbaNng9vhqb0eJyec]] )


end