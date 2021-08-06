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


    spec:RegisterPack( "Survival", 20210806, [[d8usLbqiHipsOu6scLQnbiFsOKrbj6uqcRcvs9kaAwOsDlaGDjXVqfnmauhtsAzqkEgQeMgasxdaABcr13qLeJdvs6COsuToaqVdvIGMhjv3JKSpHGdkeIfss5HqkzIcrjDrujcSrujI8rHqYirLiQtkefReq9sujsZuiu3uikHDkP6NcrjAOOseAPOsuEkqtfs1xfcPgRqPyVi(lPgmkhMQfJKhd1Kv4YeBwrFgvnAH0PfTAHOuVgvy2cUnsTBv(TudNehhsPwUspxvtNY1Hy7skFxsmEHIZluTEaeZhsA)GMuLGobC4MqQJgagnvbyUkah5faMRcGv5IiNaAXvecOIJ5W5fc450cbeezRL18abuXJhAFqqNa(nYIfcySfYIAMYda5Kt(0IIqvWnnNFsJeCl7dV(048tAmNeqkKmyrMJqrahUjK6ObGrtvaMRcWrEbG5QayvUaajGoIfTxciysJweWO5yihHIaoKhtabr2AznpazCjJCMSqGJii8iVbzro3qgAay0uLagY3Ec6eWZCc6K6vjOtaDSL9raFtKG2wxHakNtfKbrnIrQJgc6eq5CQGmiQraXBAYMobmsqgfYCwQKHH(vYnTVScTN3dzOIkKrHmNLkzyOFLCt7lRq759qgqqgU7WORCfoYqqJBAA)gLvO98EcOJTSpc4CfbGKhV2wxHyK6CbbDcOCovqge1iG4nnztNagjiJczolvYWq)k5M2xwH2Z7HmurfYOqMZsLmm0VsUP9LvO98Eidiid3Dy0vUchziOXnnTFJYk0EEpb0Xw2hb08vBRRqmIrahY0rcgbDs9Qe0jGo2Y(iG0iaeasqiGY5ubzquJyK6OHGobuoNkidIAeqhBzFeqB9dTrYqcqYJx)rBJaoKhVPIL9raJOAiZJk(aY8BazOV(H2izibicKvNlr0cYKtOt55gYQiq2OVyzq2OHmlA(q2Sxitj4XL9Hmkb7iVazPfRbKrjqM1nK9konDCiZVbKvrGmSFXYGSv8rgIdzOV(H2q2Ri4CMyiJczo)cbeVPjB6eWibzMV8IvYxRe84YsmsDUGGobuoNkidIAeqhBzFeWi72qoEj3vpK3Yl(RXEiqaXBAYMobKczol4U3rEUjdT)VJeScIcKHkQqgv)pKbeKnt(OMEfApVhYuhY4caMaEoTqaJSBd54LCx9qElV4Vg7HaXi1bOe0jGo2Y(iGiVOttOFcOCovqge1igPoasqNakNtfKbrncOJTSpci2dbTJTSpDiFJagY30Ntleq84jgPEKtqNakNtfKbrnciEtt20jGo2YAIwoHoLhYuhY4cidiiZ8GCwHk3XR7PwzL4f5CQGmiGo2Y(iGype0o2Y(0H8ncyiFtFoTqaPAfIrQZviOtaLZPcYGOgbeVPjB6eqhBznrlNqNYdzQdzCbKbeKfjiZ8GCwHk3XR7PwzL4f5CQGmiGo2Y(iGype0o2Y(0H8ncyiFtFoTqaFJyK6Cvc6eq5CQGmiQraXBAYMob0Xwwt0Yj0P8qweGm0qaDSL9raXEiODSL9Pd5BeWq(M(CAHaIdIxtigPoxobDcOJTSpcOVy)eT17kNraLZPcYGOgXigbuzfCtt5gbDs9Qe0jGY5ubzquJa2keWxSCsaXBAYMob08GCwHUp(UFrtLMuKZPcYGaoKhVPIL9raJii8iVbzro3qgAay0uLawZx950cbKMsVVg3VraDSL9raR5B6ubHawZdiIwcVqaDSL9vwxX6v)2MCifC)gbSMhqecOJTSVcDF8D)IMknPG73igPoAiOtaDSL9raFeA6(0kIraLZPcYGOgXi15cc6eqhBzFeqQ2SGm0ZGhxgvYJxBDm5raLZPcYGOgXi1bOe0jGo2Y(iGZG8rXRpncOCovqge1igPoasqNakNtfKbrnciEtt20jGlYjZE5LY3iHzV8IwOPK9lcAJKkkYGa6yl7JaA(QT1vigPEKtqNa6yl7Ja(MibTTUcbuoNkidIAeJyeqCq8AcbDs9Qe0jGY5ubzquJa6yl7Ja(YQiNPFlpEciEtt20jGMhKZkrJpw)1uPjf5CQGmGmGGmkK5SulvK911KRPlRq759qgqqgfYCwQLkY(6AY10LvO98EitDiJhpiG444GOnF5f7j1RsmsD0qqNa6yl7Jawjdd9RKBApbuoNkidIAeJuNliOtaDSL9rax57ZT841(UDfcOCovqge1igPoaLGobuoNkidIAeq8MMSPtaNiHGEfCuF5fTL0cKPoKXJheqhBzFeWkzymZv0unnfXi1bqc6eqhBzFeqCuNJ1PFcOCovqge1igPEKtqNakNtfKbrnciEtt20jGJ2kF01vojOPAAQILyoYJhYacYqjKnARKNj75bnvqKrE8L3CmhqM6qgAGmurfYgTv(ORRCsqt10uLvO98EitDiJhpGmuqaDSL9raPqmCuzJtmsDUcbDcOCovqge1iG4nnztNaoAR8rxx5KGMQPPkwI5ipEcOJTSpci23AcXi15Qe0jGY5ubzquJaI30KnDc4SXipKbiKH930RWlhKPoKnBmYxO9yiGo2Y(iGdXTOACuNJ1PjgPoxobDcOJTSpciU7DKNBYq7)7ibJakNtfKbrnIrQxfGjOtaLZPcYGOgbeVPjB6eqCuF5LxpxhBzFEaYIaKHMcaczabz4UdJUYvQKHXmxrt10uLjsiOxbh1xErBjTazraYEfje0MV8I9qgNqgAiGo2Y(iGuigoQSXjgPE1Qe0jGY5ubzquJaI30KnDc4SXipKbiKH930RWlhKPoKnBmYxO9yiGo2Y(iGZGFCKhV(Tn5qigPEv0qqNakNtfKbrnciEtt20jG4UdJUYvQKHXmxrt10uLjsiOxbh1xErBjTazraYEfje0MV8I9qgNqgAGmGGmZdYzfpOe11kRmCR3ICovqgeqhBzFeqSV1eIrQxLliOtaLZPcYGOgb0Xw2hbKJme04MM2VbbeVPjB6eWzJrEidqid7VPxHxoitDiB2yKVq7XazabztKqqVcoQV8I2sAbYuhY4XdidiidLq2ICYSxEPCY)5XxX34V2wxrjpETRO4RBiFrqBKurrgqgqqgU7WORCL5kcajpETTUszfApVhYacYWDhgDLRy(QT1vkRq759qgQOczrcYwKtM9YlLt(pp(k(g)126kk5XRDffFDd5lcAJKkkYaYqbbehhheT5lVypPEvIrQxfGsqNakNtfKbrnciEtt20jGrcYgTvQKHXmxrt10uflXCKhpb0Xw2hbSsggZCfnvttrms9QaibDcOCovqge1iG4nnztNaIsilsq2jXy6kPMQPPkF01vojazOIkKfjiZ8GCwPsggZCfDEtKp7RiNtfKbKHcidiid3Dy0vUsLmmM5kAQMMQmrcb9k4O(YlAlPfilcq2RiHG28LxShY4eYqdb0Xw2hbKcXWrLnoXi1Rg5e0jGY5ubzquJaI30KnDciU7WORCLkzymZv0unnvzIec6vWr9Lx0wslqweGSxrcbT5lVypKXjKHgcOJTSpci23AcXi1RYviOtaDSL9ra5idb9hTncOCovqge1igPEvUkbDcOJTSpc4m4XLH(J2gbuoNkidIAeJuVkxobDcOJTSpcORPr2HS6EQXBx5jGY5ubzquJyK6ObGjOtaDSL9raFtKG2wxHakNtfKbrnIrQJMQe0jGY5ubzquJa6yl7Ja(YQiNPFlpEciEtt20jGRmx5J6ubbYacYmpiNvIgFS(RPstkY5ubzazabzMV8IvSKw0wRhPazraY4QeqCCCq0MV8I9K6vjgPoAqdbDcOJTSpci23AcbuoNkidIAeJuhnCbbDcOCovqge1iGo2Y(iGCKHGg300(niG4nnztNaoBmYdzaczy)n9k8YbzQdzZgJ8fApgidiidLq2ICYSxEPCY)5XxX34V2wxrjpETRO4RBiFrqBKurrgqgqqgU7WORCL5kcajpETTUszfApVhYacYWDhgDLRy(QT1vkRq759qgQOczrcYwKtM9YlLt(pp(k(g)126kk5XRDffFDd5lcAJKkkYaYqbbehhheT5lVypPEvIrQJgakbDcOCovqge1iGo2Y(iGVSkYz63YJNaI30KnDc4kZv(OovqiG444GOnF5f7j1RsmsD0aGe0jGY5ubzquJa6yl7Jas3hF3VOPstiG444GOnF5f7j1RsmsD0e5e0jGY5ubzquJa6yl7JaUUI1R(Tn5qiG444GOnF5f7j1RsmIraXJNGoPEvc6eq5CQGmiQraXBAYMob08GCwXKL(19ulhVZl0Yzf5CQGmGmGGSzJrEitDiB2yKVq7XqaDSL9raJ6Rs3hXi1rdbDcOCovqge1iG4nnztNasHmNfC37ip3KH2)3rcwbrHa6yl7Jasf6EONiBCIrQZfe0jGY5ubzquJaI30KnDcifYCwWDVJ8CtgA)FhjyfefcOJTSpcOFy5T1dAShceJuhGsqNakNtfKbrnciEtt20jGuiZzb39oYZnzO9)DKGvquiGo2Y(iGZCfQq3dIrQdGe0jGo2Y(iGHKpQ96iBKbpTCgbuoNkidIAeJupYjOtaLZPcYGOgbeVPjB6eqC3Hrx5kCKHGg300(nktKqqVcoQV8I2sAbYIaKXJheqhBzFeqkNx3tTTjMJNyK6Cfc6eq5CQGmiQraXBAYMobKczol4U3rEUjdT)VJeScIcKHkQqML0I2A9ifitDiRkxqaDSL9raPK9LLJ84jgPoxLGob0Xw2hbKgbGaqccbuoNkidIAeJuNlNGobuoNkidIAeq8MMSPtaNjFutVcTN3dzQdzroadzOIkKrHmNfC37ip3KH2)3rcwbrHa6yl7JaQ0w2hXi1RcWe0jGY5ubzquJaI30KnDcikHSzJrEitDiJRaWqgQOcz4UdJUYvWDVJ8CtgA)FhjyLvO98EitDiJhpGmuazabzOeY(gjqL3OOG8gsq0YIOyzFf5CQGmGmurfY(gjqL3OuRdULbr)DOMCwroNkididfeqhBzFeWzq(O41Ngbmpt2frX05KaIJ63jH84bksFJeOYBuuqEdjiAzruSSpIrQxTkbDcOCovqge1iG4nnztNaoBmYdzaczy)n9k8YbzQdzZgJ8fApgidiiBroz2lVu(gjm7Lx0cnLSFrqBKurrgqgqqM5R2wxPScTN3dzQdz84bKbeKH7om6kxzg8vkRq759qM6qgpEazabzOeYCSL1eTCcDkpKfbiRkKHkQqMJTSMOLtOt5HmvqwvidiiZsArBTEKcKfbidaHmUgY4XdidfeqhBzFeqZxTTUcXi1RIgc6eq5CQGmiQraDSL9raNbFfciEtt20jGZgJ8qgGqg2FtVcVCqM6q2SXiFH2JbYacYmF126kfefidiiBroz2lVu(gjm7Lx0cnLSFrqBKurrgqgqqML0I2A9ifilcqgafY4AiJhpiGH8enEqardasms9QCbbDcOCovqge1iG4nnztNa6ylRjA5e6uEitfKvfYacYmF5fRyjTOTwpsbYuhYMng5HmoHmucz18nDQGuOP07RX9BqgaaYW(B6v4LdYqbKX1qgpEqaDSL9ra5idb9hTnIrQxfGsqNakNtfKbrnciEtt20jGo2YAIwoHoLhYubzvHmGGmZxEXkwslAR1JuGm1HSzJrEiJtidLqwnFtNkifAk9(AC)gKbaGmS)MEfE5GmuazCnKXJheqhBzFeq6(47(fnvAcXi1RcGe0jGY5ubzquJaI30KnDcOJTSMOLtOt5HmvqwvidiiZ8LxSIL0I2A9ifitDiB2yKhY4eYqjKvZ30PcsHMsVVg3Vbzaaid7VPxHxoidfqgxdz84bb0Xw2hbCDfRx9BBYHqms9QrobDcOCovqge1iG4nnztNaA(YlwzKV5hwGSiOcYICcOJTSpcO)kc209uBrfT48bHyeJas1ke0j1RsqNakNtfKbrncOJTSpc4lRICM(T84jG4nnztNasHmNLAPISVUMCnDzfApVhYacYqjKrHmNLAPISVUMCnDzfApVhYuhY4XdidvuHSvMR8rDQGazOGaIJJdI28LxSNuVkXi1rdbDcOCovqge1iGo2Y(iGCKHGg300(niG4nnztNaoBmYdzaczy)n9k8YbzQdzZgJ8fApgidiiJczolN85XxX34V2wxrjpETRO4RBiFbrbYqfviB2yKhYaeYW(B6v4LdYuhYMng5l0EmqgGqwvagYacYOqMZYjFE8v8n(RT1vuYJx7kk(6gYxquGmGGmkK5SCYNhFfFJ)ABDfL841UIIVUH8LvO98EitDiJhpiG444GOnF5f7j1RsmsDUGGob0Xw2hbKJme0F02iGY5ubzquJyK6auc6eq5CQGmiQraXBAYMobC2yKhYaeYW(B6v4LdYuhYMng5l0EmqgqqwKGmlXCKhpKbeKnrcb9k4O(YlAlPfitDiJhpiGo2Y(iGvYWyMROPAAkIrQdGe0jGY5ubzquJaI30KnDc4SXipKbiKH930RWlhKPoKnBmYxO9yiGo2Y(iGZGFCKhV(Tn5qigPEKtqNa6yl7JaodECzO)OTraLZPcYGOgXi15ke0jGY5ubzquJaI30KnDc4ICYSxEPCY)5XxX34V2wxrjpETRO4RBiFrqBKurrgqgqq2SXipKPoKvZ30PcsHMsVVg3VraDSL9raXEiODSL9Pd5BeWq(M(CAHaEMtmsDUkbDcOCovqge1iG4nnztNaoBmYdzaczy)n9k8YbzQdzZgJ8fApgcOJTSpc4qClQgh15yDAIrQZLtqNakNtfKbrncOJTSpc46kwV632KdHaI30KnDcifYCwWDVJ8CtgA)FhjyfefidiiJczol4U3rEUjdT)VJeSYk0EEpKPoKvTaGqgxdz84bbehhheT5lVypPEvIrQxfGjOtaLZPcYGOgb0Xw2hbKUp(UFrtLMqaXBAYMobKczol4U3rEUjdT)VJeScIcKbeKrHmNfC37ip3KH2)3rcwzfApVhYuhYQwaqiJRHmE8GaIJJdI28LxSNuVkXi1RwLGob0Xw2hb010i7qwDp14TR8eq5CQGmiQrms9QOHGobuoNkidIAeqhBzFeW1vSE1VTjhcbeVPjB6eqkK5SyPIUNAlQOFfX3YBoMditfKXfeqCCCq0MV8I9K6vjgPEvUGGobuoNkidIAeq8MMSPtaNng5HmaHmS)MEfE5Gm1HSzJr(cThdKbeKfjiZsmh5XdzabzOeYMiHGEfCuF5fTL0cKPoKXJhqgQOczrcYgTvQKHXmxrt10uflXCKhpKbeKrHmNf6(47(f9ezJxwH2Z7HSiaztKqqVcoQV8I2sAbYaaqwviJRHmE8aYqfvilsq2OTsLmmM5kAQMMQyjMJ84HmGGSibzuiZzHUp(UFrpr24LvO98EidfqgQOczwslAR1JuGm1HSQCvidiilsq2OTsLmmM5kAQMMQyjMJ84jGo2Y(iGvYWyMROPAAkIrQxfGsqNakNtfKbrncOJTSpcihziOXnnTFdcioooiAZxEXEs9Qeq8MMSPtaNng5HmaHmS)MEfE5Gm1HSzJr(cThdKbeKHsilsq2ICYSxEPCY)5XxX34V2wxrjpETRO4RBiFroNkididvuHSzJrEitDiRMVPtfKcnLEFnUFdYqbbCipEtfl7JagzMqw8gbYg9fldYI61eiRU8FE8v8nESEid91vuYJhYIikk(6gYZnK9jTsioKH93GmU0meGm0QPP9Baz5eYI3iqwL(ILbzDnzXUcK1hKXLuJrEiBUnnKn684HSVlqwKzczXBeiB0qwuVMaz1L)ZJVIVXJ1dzOVUIsE8qwerrXx3qEilEJazF0gjmGmS)gKXLMHaKHwnnTFdilNqw8gzHSzJrEilFiJscDfiZIkqgUFdY6jKfzrF8D)cKPwAcK1lKXL5kwVqgOTjhcXi1RcGe0jGY5ubzquJa6yl7JaYrgcACtt73GaIJJdI28LxSNuVkbeVPjB6eWzJrEidqid7VPxHxoitDiB2yKVq7XazabzlYjZE5LYj)NhFfFJ)ABDfL841UIIVUH8f5CQGmGmGGmC3Hrx5kZveasE8ABDLYk0EEpKfbidLq2SXipKXjKHsiRMVPtfKcnLEFnUFdYaaqg2FtVcVCqgkGmUgY4XdidfqgqqgU7WORCfZxTTUszfApVhYIaKHsiB2yKhY4eYqjKvZ30PcsHMsVVg3Vbzaaid7VPxHxoidfqgxdz84bKHcidiidLqwKGmZdYzL3ejOT1vkY5ubzazOIkKzEqoR8MibTTUsroNkididiid3Dy0vUYBIe026kLvO98EilcqgkHSzJrEiJtidLqwnFtNkifAk9(AC)gKbaGmS)MEfE5GmuazCnKXJhqgkGmuqahYJ3uXY(iGr0PffYQl)NhFfFJhRhYqFDfL84HSiIIIVUH8qwFH4qgxAgcqgA100(nGSCczXBKfYS1vEiZxbY6dYWDhgDLJBiRTOYwjFbYERvGmKppEiJlndbidTAAA)gqwoHS4nYczyKDLZGSzJrEiZPBKZGS8Hm5Ae(OqM1q2J8MNhKzrfiZPBKZGSEczwslqwqMgKn7fY8loK1tilEJSqMTUYdzwdz4MwGSEoHmC3Hrx5igPE1iNGobuoNkidIAeq8MMSPtaNng5HmaHmS)MEfE5Gm1HSzJr(cThdb0Xw2hb8nrcABDfIrQxLRqqNakNtfKbrncOJTSpc4lRICM(T84jG4nnztNaoAR8YQiNPFlp(YkZv(OovqGmGGSibzuiZzb39oYZnzO9)DKGvquiG444GOnF5f7j1Rsms9QCvc6eqhBzFeWv((ClpETVBxHakNtfKbrnIrQxLlNGob0Xw2hbSsgg6xj30EcOCovqge1igPoAayc6eq5CQGmiQraXBAYMobmsqgfYCwWDVJ8CtgA)FhjyfefcOJTSpciU7DKNBYq7)7ibJyK6OPkbDcOCovqge1iG4nnztNasHmNf6(47(f9ezJxquGmurfYMng5HmaHmhBzFfoYqqJBAA)gfS)MEfE5GSiazZgJ8fApgidvuHmkK5SG7Eh55Mm0()osWkikeqhBzFeq6(47(fnvAcXi1rdAiOtaLZPcYGOgb0Xw2hbCDfRx9BBYHqaXXXbrB(Yl2tQxLyK6OHliOtaLZPcYGOgbeVPjB6eWrBLkzymZv0unnvzL5kFuNkieqhBzFeWkzymZv0unnfXi1rdaLGobuoNkidIAeqhBzFeWxwf5m9B5XtaXBAYMobKczol1sfzFDn5A6cIcbehhheT5lVypPEvIrmc4Be0j1RsqNakNtfKbrnciEtt20jGZgJ8qgGqg2FtVcVCqM6q2SXiFH2JHa6yl7Jaoe3IQXrDowNMyK6OHGobuoNkidIAeqhBzFeWxwf5m9B5XtaXBAYMobmsq2OTYlRICM(T84lwI5ipEidiiZ8LxSIL0I2A9ifilcqgxbYqfviJczol1sfzFDn5A6cIcKbeKrHmNLAPISVUMCnDzfApVhYuhY4XdcioooiAZxEXEs9QeJuNliOtaDSL9raNbpUm0F02iGY5ubzquJyK6auc6eqhBzFeWv((ClpETVBxHakNtfKbrnIrQdGe0jGo2Y(iGvYWq)k5M2taLZPcYGOgXi1JCc6eqhBzFeqC37ip3KH2)3rcgbuoNkidIAeJuNRqqNa6yl7JaYrgc6pABeq5CQGmiQrmsDUkbDcOCovqge1iG4nnztNaoBmYdzaczy)n9k8YbzQdzZgJ8fApgcOJTSpc4m4hh5XRFBtoeIrQZLtqNa6yl7Ja6AAKDiRUNA82vEcOCovqge1igPEvaMGobuoNkidIAeq8MMSPtaNiHGEfCuF5fTL0cKPoKXJhqgQOczZgJ8qgGqg2FtVcVCqM6q2SXiFH2JbYacYqjKDsmMUsQPAAQsTo4wgeidiiB0w5Lvrot)wE8flXCKhpKbeKnAR8YQiNPFlp(YkZv(OovqGmurfYojgtxj1unnvrjQSnDFcKbeKfjiJczol09X39l6jYgVGOazabzZgJ8qgGqg2FtVcVCqM6q2SXiFH2JbYaaqMJTSVchziOXnnTFJc2FtVcVCqgxdzCbKHcidvuHmlPfT16rkqM6qwvaMa6yl7JawjdJzUIMQPPigPE1Qe0jGY5ubzquJaI30KnDcOJTSMOLtOt5HSiazvHmGGSibzlYjZE5LYgp4C8Mh4q2xJ7B2i3ipE9BBYH8fbTrsffzqaDSL9raX(wtigPEv0qqNakNtfKbrnciEtt20jGo2YAIwoHoLhYIaKvfYacYIeKTiNm7LxkB8GZXBEGdzFnUVzJCJ841VTjhYxe0gjvuKbKbeKH7om6kxPsggZCfnvttvMiHGEfCuF5fTL0cKfbi7vKqqB(Yl2dzabzOeYWr9LxE9CDSL95bilcqgAkaiKHkQq2OTYhDDLtcAQMMQyjMJ84HmuqaDSL9raPqmCuzJtms9QCbbDcOCovqge1iG4nnztNaoBmYdzaczy)n9k8YbzQdzZgJ8fApgcOJTSpc4BIe026keJuVkaLGobuoNkidIAeqhBzFeq6(47(fnvAcbeVPjB6eqZdYzfpOe11kRmCR3ICovqgqgqqgkHmkK5Sq3hF3VONiB8cIcKbeKrHmNf6(47(f9ezJxwH2Z7Hm1HSzJrEiJtidLqwnFtNkifAk9(AC)gKbaGmS)MEfE5GmuazCnKXJhqgqqwKGmkK5Sujdd9RKBAFzfApVhYqfviJczol09X39l6jYgVScTN3dzabzNeJPRKAQMMQOev2MUpbYqbbehhheT5lVypPEvIrQxfajOtaLZPcYGOgb0Xw2hbKJme04MM2VbbeVPjB6eWjsiOxbh1xErBjTazQdz84bKbeKnBmYdzaczy)n9k8YbzQdzZgJ8fApgcioooiAZxEXEs9QeJuVAKtqNakNtfKbrncOJTSpc46kwV632KdHaI30KnDcifYCwSur3tTfv0VI4B5nhZbKPcY4cidvuHSrBLp66kNe0unnvXsmh5XtaXXXbrB(Yl2tQxLyK6v5ke0jGY5ubzquJaI30KnDc4OTYhDDLtcAQMMQyjMJ84jGo2Y(iG09X39lAQ0eIrQxLRsqNakNtfKbrncOJTSpc4lRICM(T84jG4nnztNaUYCLpQtfeidiiZ8LxSIL0I2A9ifilcqgxbYqfviJczol1sfzFDn5A6cIcbehhheT5lVypPEvIrQxLlNGobuoNkidIAeq8MMSPtapjgtxj1unnv5JUUYjbidiiB2yKhYIaKvZ30PcsHMsVVg3VbzCnKHgidiiB0w5Lvrot)wE8LvO98EilcqgaczCnKXJheqhBzFeWkzymZv0unnfXi1rdatqNa6yl7JaIJ6CSo9taLZPcYGOgXi1rtvc6eq5CQGmiQraDSL9ra5idbnUPP9BqaXBAYMobC2yKhYaeYW(B6v4LdYuhYMng5l0EmeqCCCq0MV8I9K6vjgPoAqdbDcOCovqge1iG4nnztNaUiNm7LxkB8GZXBEGdzFnUVzJCJ841VTjhYxe0gjvuKbb0Xw2hbSsggZCfnvttrmsD0Wfe0jGY5ubzquJa6yl7Jas3hF3VOPstiG4nnztNasHmNf6(47(f9ezJxquGmurfYMng5HmaHmhBzFfoYqqJBAA)gfS)MEfE5GSiazZgJ8fApgidaazvbqidvuHSrBLp66kNe0unnvXsmh5XdzOIkKrHmNLkzyOFLCt7lRq759eqCCCq0MV8I9K6vjgPoAaOe0jGY5ubzquJa6yl7JaUUI1R(Tn5qiG444GOnF5f7j1RsmsD0aGe0jGY5ubzquJaI30KnDc4jXy6kPMQPPk16GBzqGmGGSrBLxwf5m9B5XxSeZrE8qgQOczNeJPRKAQMMQOev2MUpbYqfvi7KymDLut10uLp66kNeGmGGSzJrEilcqgacWeqhBzFeWkzymZv0unnfXigXiG1K9Z(i1rdaJMQamxbG5ccyfFV84FcyeDeHlREKPEefaeYGm0JkqwsR0RbzZEHSyPScUPPClwq2kOnsUYaY(MwGmhXAA3KbKHJ6hV8fiWrCEcKvfaczOvF1K1KbKflZdYzLytSGmRHSyzEqoReBkY5ubzeliZniJlbrwgXqgkRgdkkqGHahrhr4YQhzQhrbaHmid9OcKL0k9Aq2SxilwVfliBf0gjxzazFtlqMJynTBYaYWr9Jx(ce4iopbYQcqbGqgA1xnznzazGjnAbzF8Z8yGSyhYSgYIyehYgzT8Z(GSwrw36fYqjNOaYqz1yqrbcme4i6icxw9it9ikaiKbzOhvGSKwPxdYM9czXcp(ybzRG2i5kdi7BAbYCeRPDtgqgoQF8YxGahX5jqwvagaczOvF1K1KbKfRVrcu5nkXMybzwdzX6BKavEJsSPiNtfKrSGmuIMyqrbcCeNNazv5caiKHw9vtwtgqgysJwq2h)mpgil2HmRHSigXHSrwl)SpiRvK1TEHmuYjkGmuwnguuGahX5jqwvakaeYqR(QjRjdidmPrli7JFMhdKf7qM1qweJ4q2iRLF2hK1kY6wVqgk5efqgkRgdkkqGJ48eiRkacaHm0QVAYAYaYatA0cY(4N5XazXoKznKfXioKnYA5N9bzTISU1lKHsorbKHYQXGIceyiWr0reUS6rM6ruaqidYqpQazjTsVgKn7fYIfvReliBf0gjxzazFtlqMJynTBYaYWr9Jx(ce4iopbYQcqbGqgA1xnznzazXAroz2lVuInXcYSgYI1ICYSxEPeBkY5ubzelidLvJbffiWrCEcKvfabGqgA1xnznzazGjnAbzF8Z8yGSyhYSgYIyehYgzT8Z(GSwrw36fYqjNOaYqjxedkkqGJ48eiRkacaHm0QVAYAYaYIL5b5SsSjwqM1qwSmpiNvInf5CQGmIfKHs0edkkqGJ48eiRkacaHm0QVAYAYaYI1ICYSxEPeBIfKznKfRf5KzV8sj2uKZPcYiwqgkRgdkkqGHahrhr4YQhzQhrbaHmid9OcKL0k9Aq2Sxilw4G41KybzRG2i5kdi7BAbYCeRPDtgqgoQF8YxGahX5jqwvagaczOvF1K1KbKbM0OfK9XpZJbYIDiZAilIrCiBK1Yp7dYAfzDRxidLCIcidLvJbffiWrCEcKvfnaqidT6RMSMmGmWKgTGSp(zEmqwSdzwdzrmIdzJSw(zFqwRiRB9czOKtuazOSAmOOaboIZtGSQaiaeYqR(QjRjdidmPrli7JFMhdKf7qM1qweJ4q2iRLF2hK1kY6wVqgk5efqgkRgdkkqGJ48eiRAKdaHm0QVAYAYaYatA0cY(4N5XazXoKznKfXioKnYA5N9bzTISU1lKHsorbKHYQXGIceyiWrgALEnzazCfiZXw2hKfY3(ceycOY2ZmieWylKbIS1YAEaY4sg5mzHahBHSiccpYBqwKZnKHgagnvHadb2Xw23xuwb30uUbOkoR5B6ubH7ZPfv0u6914(nUBfvVy5K7AEaru5yl7Rq3hF3VOPstk4(nUR5berlHxu5yl7RSUI1R(Tn5qk4(nUX9nsl7tL5b5ScDF8D)IMknbcSJTSVVOScUPPCdqvC(i009PvedcSJTSVVOScUPPCdqvCs1MfKHEg84YOsE8ARJjpiWo2Y((IYk4MMYnavX5miFu86tdcSJTSVVOScUPPCdqvCA(QT1v4oNQwKtM9YlLVrcZE5fTqtj7xe0gjvuKbeyhBzFFrzfCtt5gGQ48nrcABDfiWqGDSL99aQItAeacajiqGJTqwevdzEuXhqMFdid91p0gjdjarGS6CjIwqMCcDkpxcHSkcKn6lwgKnAiZIMpKn7fYucECzFiJsWoYlqwAXAazucKzDdzVItthhY8Bazveid7xSmiBfFKH4qg6RFOnK9kcoNjgYOqMZVab2Xw23dOkoT1p0gjdjajpE9hTnUZPQiz(YlwjFTsWJlleyhBzFpGQ4e5fDAcn3NtlQISBd54LCx9qElV4Vg7Ha35uffYCwWDVJ8CtgA)FhjyfefurLQ)hOzYh10Rq759QZfameyhBzFpGQ4e5fDAc9dbo2gBHSiRsWJdzthNhpKfVrwiB0iugKHCwgGS4ncKf1RjqMcIbzCzY3NB5XdzrKD7kq2ORCCdz9cz5eYSOcKH7om6khKLpKzDdzH(4HmRHSHe84q20X5XdzXBKfYIS2iuwbYImti76tGSEczwu5fid33iTSVhY8vGmNkiqM1qgTyqwL0IMhKzrfiRkadzVG7B8qwqKkECUHmlQazFsdzthlpKfVrwilYAJqzqMJynTBj2dH4fiWX2ylK5yl77bufNNuz2i3qVY3HAc35u13ibQ8gLtQmBKBOx57qnbiusHmNLv((ClpETVBxPGOGkQ4UdJUYvw57ZT841(UDLYk0EEFeQcWOIQ5lVyflPfT16rkQxnYrbeyhBzFpGQ4e7HG2Xw2NoKVX950Ik84Ha7yl77bufNype0o2Y(0H8nUpNwur1kCNtvo2YAIwoHoLxDUaiZdYzfQChVUNALvIxKZPcYacSJTSVhqvCI9qq7yl7thY34(CAr1BCNtvo2YAIwoHoLxDUaOizEqoRqL7419uRSs8ICovqgqGDSL99aQItShcAhBzF6q(g3NtlQWbXRjCNtvo2YAIwoHoLpcObcSJTSVhqvC6l2prB9UYzqGHa7yl77luTIQxwf5m9B5XZnoooiAZxEXEvv5oNQOqMZsTur2xxtUMUScTN3dekPqMZsTur2xxtUMUScTN3RopEGkQRmx5J6ubbfqGDSL99fQwbqvCYrgcACtt73GBCCCq0MV8I9QQYDovnBmYdi2FtVcVCQpBmYxO9yaIczolN85XxX34V2wxrjpETRO4RBiFbrbvuNng5be7VPxHxo1Nng5l0EmawfGbIczolN85XxX34V2wxrjpETRO4RBiFbrbikK5SCYNhFfFJ)ABDfL841UIIVUH8LvO98E15XdiWo2Y((cvRaOko5idb9hTniWo2Y((cvRaOkoRKHXmxrt10uCNtvZgJ8aI930RWlN6ZgJ8fApgGIKLyoYJhOjsiOxbh1xErBjTOopEab2Xw23xOAfavX5m4hh5XRFBtoeUZPQzJrEaX(B6v4Lt9zJr(cThdeyhBzFFHQvaufNZGhxg6pABqGDSL99fQwbqvCI9qq7yl7thY34(CAr1zo35u1ICYSxEPCY)5XxX34V2wxrjpETRO4RBiFrqBKurrganBmYREnFtNkifAk9(AC)geyhBzFFHQvaufNdXTOACuNJ1P5oNQMng5be7VPxHxo1Nng5l0EmqGDSL99fQwbqvCUUI1R(Tn5q4ghhheT5lVyVQQCNtvuiZzb39oYZnzO9)DKGvquaIczol4U3rEUjdT)VJeSYk0EEV6vlaixZJhqGDSL99fQwbqvCs3hF3VOPst4ghhheT5lVyVQQCNtvuiZzb39oYZnzO9)DKGvquaIczol4U3rEUjdT)VJeSYk0EEV6vlaixZJhqGDSL99fQwbqvC6AAKDiRUNA82vEiWo2Y((cvRaOkoxxX6v)2MCiCJJJdI28LxSxvvUZPkkK5SyPIUNAlQOFfX3YBoMdvCbeyhBzFFHQvaufNvYWyMROPAAkUZPQzJrEaX(B6v4Lt9zJr(cThdqrYsmh5XdekNiHGEfCuF5fTL0I684bQOgPrBLkzymZv0unnvXsmh5XdefYCwO7JV7x0tKnEzfApVpctKqqVcoQV8I2sAbauLR5XdurnsJ2kvYWyMROPAAQILyoYJhOirHmNf6(47(f9ezJxwH2Z7rbQOAjTOTwpsr9QCvGI0OTsLmmM5kAQMMQyjMJ84HahBHSiZeYI3iq2OVyzqwuVMaz1L)ZJVIVXJ1dzOVUIsE8qwerrXx3qEUHSpPvcXHmS)gKXLMHaKHwnnTFdilNqw8gbYQ0xSmiRRjl2vGS(GmUKAmYdzZTPHSrNhpK9DbYImtilEJazJgYI61eiRU8FE8v8nESEid91vuYJhYIikk(6gYdzXBei7J2iHbKH93GmU0meGm0QPP9Baz5eYI3ilKnBmYdz5dzusORazwubYW9BqwpHSil6JV7xGm1stGSEHmUmxX6fYaTn5qGa7yl77luTcGQ4KJme04MM2Vb3444GOnF5f7vvL7CQA2yKhqS)MEfE5uF2yKVq7XaekJ0ICYSxEPCY)5XxX34V2wxrjpETRO4RBipQOoBmYREnFtNkifAk9(AC)gkGahBHSi60Icz1L)ZJVIVXJ1dzOVUIsE8qwerrXx3qEiRVqCiJlndbidTAAA)gqwoHS4nYcz26kpK5Raz9bz4UdJUYXnK1wuzRKVazV1kqgYNhpKXLMHaKHwnnTFdilNqw8gzHmmYUYzq2SXipK50nYzqw(qMCncFuiZAi7rEZZdYSOcK50nYzqwpHmlPfilitdYM9cz(fhY6jKfVrwiZwx5HmRHmCtlqwpNqgU7WORCqGDSL99fQwbqvCYrgcACtt73GBCCCq0MV8I9QQYDovnBmYdi2FtVcVCQpBmYxO9yaAroz2lVuo5)84R4B8xBRROKhV2vu81nKhiC3Hrx5kZveasE8ABDLYk0EEFeq5SXiFSJYA(Movqk0u6914(naa2FtVcVCOGR5XduaeU7WORCfZxTTUszfApVpcOC2yKp2rznFtNkifAk9(AC)gaa7VPxHxouW184bkacLrY8GCw5nrcABDfur18GCw5nrcABDfGWDhgDLR8MibTTUszfApVpcOC2yKp2rznFtNkifAk9(AC)gaa7VPxHxouW184bkqbeyhBzFFHQvaufNVjsqBRRWDovnBmYdi2FtVcVCQpBmYxO9yGa7yl77luTcGQ48Lvrot)wE8CJJJdI28LxSxvvUZPQrBLxwf5m9B5XxwzUYh1PccqrIczol4U3rEUjdT)VJeScIceyhBzFFHQvaufNR895wE8AF3UceyhBzFFHQvaufNvYWq)k5M2db2Xw23xOAfavXjU7DKNBYq7)7ibJ7CQksuiZzb39oYZnzO9)DKGvquGa7yl77luTcGQ4KUp(UFrtLMWDovrHmNf6(47(f9ezJxquqf1zJrEaDSL9v4idbnUPP9BuW(B6v4LlcZgJ8fApgurLczol4U3rEUjdT)VJeScIceyhBzFFHQvaufNRRy9QFBtoeUXXXbrB(Yl2RQkeyhBzFFHQvaufNvYWyMROPAAkUZPQrBLkzymZv0unnvzL5kFuNkiqGDSL99fQwbqvC(YQiNPFlpEUXXXbrB(Yl2RQk35uffYCwQLkY(6AY10fefiWqGDSL99f84vf1xLUpUZPkZdYzftw6x3tTC8oVqlNvKZPcYaOzJrE1Nng5l0EmqGDSL99f84bufNuHUh6jYgN7CQIczol4U3rEUjdT)VJeScIceyhBzFFbpEavXPFy5T1dAShcCNtvuiZzb39oYZnzO9)DKGvquGa7yl77l4XdOkoN5kuHUhCNtvuiZzb39oYZnzO9)DKGvquGa7yl77l4XdOkodjFu71r2idEA5miWo2Y((cE8aQItkNx3tTTjMJN7CQc3Dy0vUchziOXnnTFJYeje0RGJ6lVOTKwIapEab2Xw23xWJhqvCsj7llh5XZDovrHmNfC37ip3KH2)3rcwbrbvuTKw0wRhPOEvUacSJTSVVGhpGQ4KgbGaqcceyhBzFFbpEavXPsBzFCNtvZKpQPxH2Z7vpYbyurLczol4U3rEUjdT)VJeScIceyhBzFFbpEavX5miFu86tJ78mzxeftNtv4O(DsipEGI03ibQ8gffK3qcIwwefl7J7CQcLZgJ8QZvayurf3Dy0vUcU7DKNBYq7)7ibRScTN3RopEGcGq53ibQ8gffK3qcIwwefl7dvu)gjqL3OuRdULbr)DOMCgkGa7yl77l4XdOkonF126kCNtvZgJ8aI930RWlN6ZgJ8fApgGwKtM9YlLVrcZE5fTqtj7xe0gjvuKbqMVABDLYk0EEV684bq4UdJUYvMbFLYk0EEV684bqO0Xwwt0Yj0P8rOkQO6ylRjA5e6uEvvbYsArBTEKseaqUMhpqbeyhBzFFbpEavX5m4RWDiprJhQqdaYDovnBmYdi2FtVcVCQpBmYxO9yaY8vBRRuquaAroz2lVu(gjm7Lx0cnLSFrqBKurrgazjTOTwpsjcauUMhpGa7yl77l4XdOko5idb9hTnUZPkhBznrlNqNYRQkqMV8IvSKw0wRhPO(SXiFSJYA(Movqk0u6914(naa2FtVcVCOGR5XdiWo2Y((cE8aQIt6(47(fnvAc35uLJTSMOLtOt5vvfiZxEXkwslAR1JuuF2yKp2rznFtNkifAk9(AC)gaa7VPxHxouW184beyhBzFFbpEavX56kwV632KdH7CQYXwwt0Yj0P8QQcK5lVyflPfT16rkQpBmYh7OSMVPtfKcnLEFnUFdaG930RWlhk4AE8acSJTSVVGhpGQ40FfbB6EQTOIwC(GWDovz(YlwzKV5hwIGQihcmeyhBzFFbheVMO6Lvrot)wE8CJJJdI28LxSxvvUZPkZdYzLOXhR)AQ0KICovqgarHmNLAPISVUMCnDzfApVhikK5SulvK911KRPlRq759QZJhqGDSL99fCq8AcGQ4Ssgg6xj30EiWo2Y((coiEnbqvCUY3NB5XR9D7kqGDSL99fCq8AcGQ4SsggZCfnvttXDovnrcb9k4O(YlAlPf15XdiWo2Y((coiEnbqvCIJ6CSo9db2Xw23xWbXRjaQItkedhv24CNtvJ2kF01vojOPAAQILyoYJhiuoARKNj75bnvqKrE8L3CmhQJgurD0w5JUUYjbnvttvwH2Z7vNhpqbeyhBzFFbheVMaOkoX(wt4oNQgTv(ORRCsqt10uflXCKhpeyhBzFFbheVMaOkohIBr14OohRtZDovnBmYdi2FtVcVCQpBmYxO9yGa7yl77l4G41eavXjU7DKNBYq7)7ibdcSJTSVVGdIxtaufNuigoQSX5oNQWr9LxE9CDSL95HiGMcaceU7WORCLkzymZv0unnvzIec6vWr9Lx0wslr4vKqqB(Yl2h7ObcSJTSVVGdIxtaufNZGFCKhV(Tn5q4oNQMng5be7VPxHxo1Nng5l0EmqGDSL99fCq8AcGQ4e7BnH7CQc3Dy0vUsLmmM5kAQMMQmrcb9k4O(YlAlPLi8ksiOnF5f7JD0aK5b5SIhuI6ALvgU1BroNkidiWo2Y((coiEnbqvCYrgcACtt73GBCCCq0MV8I9QQYDovnBmYdi2FtVcVCQpBmYxO9yaAIec6vWr9Lx0wslQZJhaHYf5KzV8s5K)ZJVIVXFTTUIsE8AxrXx3q(IG2iPIImac3Dy0vUYCfbGKhV2wxPScTN3deU7WORCfZxTTUszfApVhvuJ0ICYSxEPCY)5XxX34V2wxrjpETRO4RBiFrqBKurrgOacSJTSVVGdIxtaufNvYWyMROPAAkUZPQinARujdJzUIMQPPkwI5ipEiWo2Y((coiEnbqvCsHy4OYgN7CQcLr6KymDLut10uLp66kNeqf1izEqoRujdJzUIoVjYN9vKZPcYafaH7om6kxPsggZCfnvttvMiHGEfCuF5fTL0seEfje0MV8I9XoAGa7yl77l4G41eavXj23Ac35ufU7WORCLkzymZv0unnvzIec6vWr9Lx0wslr4vKqqB(Yl2h7ObcSJTSVVGdIxtaufNCKHG(J2geyhBzFFbheVMaOkoNbpUm0F02Ga7yl77l4G41eavXPRPr2HS6EQXBx5Ha7yl77l4G41eavX5BIe026kqGDSL99fCq8AcGQ48Lvrot)wE8CJJJdI28LxSxvvUZPQvMR8rDQGaK5b5Ss04J1FnvAsroNkidGmF5fRyjTOTwpsjcCviWo2Y((coiEnbqvCI9TMab2Xw23xWbXRjaQItoYqqJBAA)gCJJJdI28LxSxvvUZPQzJrEaX(B6v4Lt9zJr(cThdqOCroz2lVuo5)84R4B8xBRROKhV2vu81nKViOnsQOidGWDhgDLRmxrai5XRT1vkRq759aH7om6kxX8vBRRuwH2Z7rf1iTiNm7LxkN8FE8v8n(RT1vuYJx7kk(6gYxe0gjvuKbkGa7yl77l4G41eavX5lRICM(T845ghhheT5lVyVQQCNtvRmx5J6ubbcSJTSVVGdIxtaufN09X39lAQ0eUXXXbrB(Yl2RQkeyhBzFFbheVMaOkoxxX6v)2MCiCJJJdI28LxSxvviWqGDSL99LZCvVjsqBRRab2Xw23xoZbufNZveasE8ABDfUZPQirHmNLkzyOFLCt7lRq759OIkfYCwQKHH(vYnTVScTN3deU7WORCfoYqqJBAA)gLvO98EiWo2Y((YzoGQ408vBRRWDovfjkK5Sujdd9RKBAFzfApVhvuPqMZsLmm0VsUP9LvO98EGWDhgDLRWrgcACtt73OScTN3dbgcSJTSVV8MQH4wunoQZX60CNtvZgJ8aI930RWlN6ZgJ8fApgiWo2Y((YBaQIZxwf5m9B5XZnoooiAZxEXEvv5oNQI0OTYlRICM(T84lwI5ipEGmF5fRyjTOTwpsjcCfurLczol1sfzFDn5A6cIcquiZzPwQi7RRjxtxwH2Z7vNhpGa7yl77lVbOkoNbpUm0F02Ga7yl77lVbOkox57ZT841(UDfiWo2Y((YBaQIZkzyOFLCt7Ha7yl77lVbOkoXDVJ8CtgA)FhjyqGDSL99L3aufNCKHG(J2geyhBzFF5navX5m4hh5XRFBtoeUZPQzJrEaX(B6v4Lt9zJr(cThdeyhBzFF5navXPRPr2HS6EQXBx5Ha7yl77lVbOkoRKHXmxrt10uCNtvtKqqVcoQV8I2sArDE8avuNng5be7VPxHxo1Nng5l0EmaHYtIX0vsnvttvQ1b3YGa0OTYlRICM(T84lwI5ipEGgTvEzvKZ0VLhFzL5kFuNkiOI6jXy6kPMQPPkkrLTP7taksuiZzHUp(UFrpr24fefGMng5be7VPxHxo1Nng5l0EmaahBzFfoYqqJBAA)gfS)MEfE54AUafOIQL0I2A9if1RcWqGDSL99L3aufNyFRjCNtvo2YAIwoHoLpcvbkslYjZE5LYgp4C8Mh4q2xJ7B2i3ipE9BBYH8fbTrsffzab2Xw23xEdqvCsHy4OYgN7CQYXwwt0Yj0P8rOkqrAroz2lVu24bNJ38ahY(ACFZg5g5XRFBtoKViOnsQOidGWDhgDLRujdJzUIMQPPktKqqVcoQV8I2sAjcVIecAZxEXEGqjoQV8YRNRJTSppeb0uaqurD0w5JUUYjbnvttvSeZrE8OacSJTSVV8gGQ48nrcABDfUZPQzJrEaX(B6v4Lt9zJr(cThdeyhBzFF5navXjDF8D)IMknHBCCCq0MV8I9QQYDovzEqoR4bLOUwzLHB9wKZPcYaiusHmNf6(47(f9ezJxquaIczol09X39l6jYgVScTN3R(SXiFSJYA(Movqk0u6914(naa2FtVcVCOGR5XdGIefYCwQKHH(vYnTVScTN3JkQuiZzHUp(UFrpr24LvO98EGojgtxj1unnvrjQSnDFckGa7yl77lVbOko5idbnUPP9BWnoooiAZxEXEvv5oNQMiHGEfCuF5fTL0I684bqZgJ8aI930RWlN6ZgJ8fApgiWo2Y((YBaQIZ1vSE1VTjhc3444GOnF5f7vvL7CQIczolwQO7P2Ik6xr8T8MJ5qfxGkQJ2kF01vojOPAAQILyoYJhcSJTSVV8gGQ4KUp(UFrtLMWDovnAR8rxx5KGMQPPkwI5ipEiWo2Y((YBaQIZxwf5m9B5XZnoooiAZxEXEvv5oNQwzUYh1PccqMV8IvSKw0wRhPebUcQOsHmNLAPISVUMCnDbrbcSJTSVV8gGQ4SsggZCfnvttXDovDsmMUsQPAAQYhDDLtcanBmYhHA(Movqk0u6914(nUgnanAR8YQiNPFlp(Yk0EEFeaqUMhpGa7yl77lVbOkoXrDowN(Ha7yl77lVbOko5idbnUPP9BWnoooiAZxEXEvv5oNQMng5be7VPxHxo1Nng5l0EmqGDSL99L3aufNvYWyMROPAAkUZPQf5KzV8szJhCoEZdCi7RX9nBKBKhV(Tn5q(IG2iPIImGa7yl77lVbOkoP7JV7x0uPjCJJJdI28LxSxvvUZPkkK5Sq3hF3VONiB8cIcQOoBmYdOJTSVchziOXnnTFJc2FtVcVCry2yKVq7XaaQcGOI6OTYhDDLtcAQMMQyjMJ84rfvkK5Sujdd9RKBAFzfApVhcSJTSVV8gGQ4CDfRx9BBYHWnoooiAZxEXEvvHa7yl77lVbOkoRKHXmxrt10uCNtvNeJPRKAQMMQuRdULbbOrBLxwf5m9B5XxSeZrE8OI6jXy6kPMQPPkkrLTP7tqf1tIX0vsnvttv(ORRCsaOzJr(iaGamb8vemPoAaqaKyeJqa]] )


end