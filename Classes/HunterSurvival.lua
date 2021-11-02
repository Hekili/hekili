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


    spec:RegisterPack( "Survival", 20211101, [[d8edNbqiHipssu6sacTja6tcrnkifNcs0QqLQEfaMfQKBjjQ2Le)cv0WqLshtiTmiHNHkfttsKUgGKTbPu(gGiJtieNdvQO1biQ3bPuHMhjv3JKSpHGdkeslKKYdHuYeLer6IqkvWgHuQKpIkvYiHuQuNusewjG6LqkvntHqDtjre2PKQFkjIOHcPurlfvQWtbAQqQ(kQuPgRKOyVi(lPgmkhMQfJKhd1Kv4YeBwrFgvnAHYPfTAjruVgvy2cUnsTBv(TudNehhqQLR0Zv10PCDi2UKY3LKgVKW5fQwpGG5djTFqtIsqNaoCti1rb3IIOrJYTrlOiALcKaQOeqlUIqavCmhoVqapNwiGGiBTSMhiGkE8q7dc6eWVrwSqaRSqwmZuEGmNCYNwmeQcUP58tAKGBzF41NgNFsJ5KasHKbRsCekc4WnHuhfClkIgnk3gTGIOvkqQsbseqhXI1lbemPrlcySCmKJqrahYJjGGiBTSMhGm0UrotwiW17AcnLSqwuUGmuWTOikbmKV9e0jGN5e0j1JsqNa6yl7Ja(MibTTUcbuoNkidIAeJuhfe0jGY5ubzquJaI30KnDcyKGmkK5Sundd9RKBAFzfApVhYqfviJczolvZWq)k5M2xwH2Z7HmaHmC3Hrx9kCKHGg300(nkRq759eqhBzFeW5kcqipETTUcXi15gc6eq5CQGmiQraXBAYMobmsqgfYCwQMHH(vYnTVScTN3dzOIkKrHmNLQzyOFLCt7lRq759qgGqgU7WOREfoYqqJBAA)gLvO98EcOJTSpcO5R2wxHyeJaoKPJemc6K6rjOtaDSL9raPracaHGqaLZPcYGOgXi1rbbDcOCovqge1iGo2Y(iG26hqJKHeiKhV(J1gbCipEtfl7JaYD1qMht8bK53aYqF9dOrYqceeiRoANOfKjNqNYZfKvvGSrFr2GSrdzwS8HSzVqMsWJl7dzuc2rEbYslYdiJsGmRBi7vCA64qMFdiRQazy)ISbzR4JmehYqF9dOHSxrW5mXqgfYC(fciEtt20jGrcYmF5fRKVwj4XLLyK6CdbDcOCovqge1iGo2Y(iGvYTHC8sUREiVLx8xJ9qGaI30KnDcifYCwWDVJ8CtgA)FhjyfefidvuHmQ(FidqiBM8Xm9k0EEpKPoKXnClb8CAHawj3gYXl5U6H8wEXFn2dbIrQxPe0jGo2Y(iGiVOttOFcOCovqge1igPoqrqNakNtfKbrncOJTSpci2dbTJTSpDiFJagY30Ntleq84jgPoAJGobuoNkidIAeq8MMSPtaDSL1eTCcDkpKPoKXnqgGqM5b5ScvUJx3tTYkXlY5ubzqaDSL9raXEiODSL9Pd5BeWq(M(CAHas1keJuhirqNakNtfKbrnciEtt20jGo2YAIwoHoLhYuhY4gidqilsqM5b5ScvUJx3tTYkXlY5ubzqaDSL9raXEiODSL9Pd5BeWq(M(CAHa(gXi1Jie0jGY5ubzquJaI30KnDcOJTSMOLtOt5HSiazOGa6yl7JaI9qq7yl7thY3iGH8n950cbeheVMqmsDUtc6eqhBzFeqFX(jAR3voJakNtfKbrnIrmcOYk4MMYnc6K6rjOtaLZPcYGOgbSviGVy5KaI30KnDcO5b5ScDF8D)IMknPiNtfKbbCipEtfl7JawVRj0uYczr5cYqb3IIOeWA(QpNwiG0u6914(ncOJTSpcynFtNkieWAEar0s4fcOJTSVY6kwV632KdPG73iG18aIqaDSL9vO7JV7x0uPjfC)gXi1rbbDcOJTSpc4Jqt3NwrmcOCovqge1igPo3qqNa6yl7Jas1MfKHEg84YOAE8ARRipcOCovqge1igPELsqNa6yl7JaodYhdV(0iGY5ubzquJyK6afbDcOCovqge1iG4nnztNaUiNm7LxkFJeM9YlAHMs2ViansQOidcOJTSpcO5R2wxHyK6Onc6eqhBzFeW3ejOT1viGY5ubzquJyeJas1ke0j1JsqNakNtfKbrncOJTSpc4lRICM(T84jG4nnztNasHmNLAPISVUMCnDzfApVhYaeYqdKrHmNLAPISVUMCnDzfApVhYuhY4XdidvuHSvMR8XCQGazOKaIJJdI28LxSNupkXi1rbbDcOCovqge1iGo2Y(iGCKHGg300(niG4nnztNaoBmYdzaazy)n9k8YbzQdzZgJ8fAVcidqiJczolN85Xx134V2wxrjpETRO4RBiFbrbYqfviB2yKhYaaYW(B6v4LdYuhYMng5l0EfqgaqwuUfYaeYOqMZYjFE8v9n(RT1vuYJx7kk(6gYxquGmaHmkK5SCYNhFvFJ)ABDfL841UIIVUH8LvO98EitDiJhpiG444GOnF5f7j1JsmsDUHGob0Xw2hbKJme0FS2iGY5ubzquJyK6vkbDcOCovqge1iG4nnztNaoBmYdzaazy)n9k8YbzQdzZgJ8fAVcidqilsqMLyoYJhYaeYMiHGEfCmF5fTL0cKPoKXJheqhBzFeWQzymZv0unnfXi1bkc6eq5CQGmiQraXBAYMobC2yKhYaaYW(B6v4LdYuhYMng5l0EfeqhBzFeWzWpoYJx)2MCieJuhTrqNa6yl7JaodECzO)yTraLZPcYGOgXi1bse0jGY5ubzquJaI30KnDc4ICYSxEPCY)5Xx134V2wxrjpETRO4RBiFraAKurrgqgGq2SXipKPoKvZ30PcsHMsVVg3VraDSL9raXEiODSL9Pd5BeWq(M(CAHaEMtms9icbDcOCovqge1iG4nnztNaoBmYdzaazy)n9k8YbzQdzZgJ8fAVccOJTSpc4qClMghZ5yDAIrQZDsqNakNtfKbrncOJTSpc46kwV632KdHaI30KnDcifYCwWDVJ8CtgA)FhjyfefidqiJczol4U3rEUjdT)VJeSYk0EEpKPoKfTauqg3dz84bbehhheT5lVypPEuIrQhLBjOtaLZPcYGOgb0Xw2hbKUp(UFrtLMqaXBAYMobKczol4U3rEUjdT)VJeScIcKbiKrHmNfC37ip3KH2)3rcwzfApVhYuhYIwakiJ7HmE8GaIJJdI28LxSNupkXi1JgLGob0Xw2hb010i7qwDp14TR(eq5CQGmiQrms9OOGGobuoNkidIAeqhBzFeW1vSE1VTjhcbeVPjB6eqkK5SyPIUNAlMOFfX3YBoMditfKXneqCCCq0MV8I9K6rjgPEuUHGobuoNkidIAeq8MMSPtaNng5HmaGmS)MEfE5Gm1HSzJr(cTxbKbiKfjiZsmh5XdzaczObYMiHGEfCmF5fTL0cKPoKXJhqgQOczrcYgTvQMHXmxrt10uflXCKhpKbiKrHmNf6(47(f9ezJxwH2Z7HSiaztKqqVcoMV8I2sAbYQCilkKX9qgpEazOIkKfjiB0wPAggZCfnvttvSeZrE8qgGqwKGmkK5Sq3hF3VONiB8Yk0EEpKHsidvuHmlPfT16rkqM6qw0icKbiKfjiB0wPAggZCfnvttvSeZrE8eqhBzFeWQzymZv0unnfXi1JwPe0jGY5ubzquJa6yl7JaYrgcACtt73GaIJJdI28LxSNupkbeVPjB6eWzJrEidaid7VPxHxoitDiB2yKVq7vazaczObYIeKTiNm7LxkN8FE8v9n(RT1vuYJx7kk(6gYxKZPcYaYqfviB2yKhYuhYQ5B6ubPqtP3xJ73GmusahYJ3uXY(iGvIjKfVrGSrFr2GSyEnbYQl)NhFvFJh5hYqFDfL84HSiQIIVUH8CbzFsReIdzy)nidTpdbidTAAA)gqwoHS4ncKvTViBqwxtwSRaz9bzOD1yKhYMBtdzJopEi77cKvjMqw8gbYgnKfZRjqwD5)84R6B8i)qg6RROKhpKfrvu81nKhYI3iq2hRrcdid7VbzO9ziazOvtt73aYYjKfVrwiB2yKhYYhYOKqxfYSycKH73GSEczvs0hF3VazQLMaz9czChUI1lKbABYHqms9OafbDcOCovqge1iGo2Y(iGCKHGg300(niG444GOnF5f7j1JsaXBAYMobC2yKhYaaYW(B6v4LdYuhYMng5l0EfqgGq2ICYSxEPCY)5Xx134V2wxrjpETRO4RBiFroNkididqid3Dy0vVYCfbiKhV2wxPScTN3dzraYqdKnBmYdzCczObYQ5B6ubPqtP3xJ73GSkhYW(B6v4LdYqjKX9qgpEazOeYaeYWDhgD1Ry(QT1vkRq759qweGm0azZgJ8qgNqgAGSA(Movqk0u6914(niRYHmS)MEfE5GmuczCpKXJhqgkHmaHm0azrcYmpiNvEtKG2wxPiNtfKbKHkQqM5b5SYBIe026kf5CQGmGmaHmC3Hrx9kVjsqBRRuwH2Z7HSiazObYMng5HmoHm0az18nDQGuOP07RX9BqwLdzy)n9k8YbzOeY4EiJhpGmuczOKaoKhVPIL9ra5UtlgKvx(pp(Q(gpYpKH(6kk5XdzruffFDd5HS(cXHm0(meGm0QPP9Baz5eYI3ilKzRR8qMVcK1hKH7om6QhxqwBXKTA(cK9wRaziFE8qgAFgcqgA100(nGSCczXBKfYWi7kNbzZgJ8qMt3iNbz5dzY1i8XGmRHSh5nppiZIjqMt3iNbz9eYSKwGSGmniB2lK5xCiRNqw8gzHmBDLhYSgYWnTaz9Ccz4UdJU6rms9OOnc6eq5CQGmiQraXBAYMobC2yKhYaaYW(B6v4LdYuhYMng5l0EfeqhBzFeW3ejOT1vigPEuGebDcOCovqge1iGo2Y(iGVSkYz63YJNaI30KnDc4OTYlRICM(T84lRmx5J5ubbYaeYIeKrHmNfC37ip3KH2)3rcwbrHaIJJdI28LxSNupkXi1JgriOtaDSL9rax57ZT841(UDvcOCovqge1igPEuUtc6eqhBzFeWQzyOFLCt7jGY5ubzquJyK6OGBjOtaLZPcYGOgbeVPjB6eWibzuiZzb39oYZnzO9)DKGvquiGo2Y(iG4U3rEUjdT)VJemIrQJIOe0jGY5ubzquJaI30KnDcifYCwO7JV7x0tKnEbrbYqfviB2yKhYaaYCSL9v4idbnUPP9BuW(B6v4LdYIaKnBmYxO9kGmurfYOqMZcU7DKNBYq7)7ibRGOqaDSL9raP7JV7x0uPjeJuhfOGGobuoNkidIAeqhBzFeW1vSE1VTjhcbehhheT5lVypPEuIrQJcUHGobuoNkidIAeq8MMSPtahTvQMHXmxrt10uLvMR8XCQGqaDSL9raRMHXmxrt10ueJuhfvkbDcOCovqge1iGo2Y(iGVSkYz63YJNaI30KnDcifYCwQLkY(6AY10fefcioooiAZxEXEs9OeJyeq84jOtQhLGobuoNkidIAeq8MMSPtanpiNvmzPFDp1YX78cTCwroNkididqiB2yKhYuhYMng5l0EfeqhBzFeWy(Q09rmsDuqqNakNtfKbrnciEtt20jGuiZzb39oYZnzO9)DKGvquiGo2Y(iGuHUh6jYgNyK6CdbDcOCovqge1iG4nnztNasHmNfC37ip3KH2)3rcwbrHa6yl7Ja6hwEB9Gg7HaXi1Ruc6eq5CQGmiQraXBAYMobKczol4U3rEUjdT)VJeScIcb0Xw2hbCMRqf6EqmsDGIGob0Xw2hbmK8XSxxjJm4PLZiGY5ubzquJyK6Onc6eq5CQGmiQraXBAYMobe3Dy0vVchziOXnnTFJYeje0RGJ5lVOTKwGSiaz84bb0Xw2hbKY519uBBI54jgPoqIGobuoNkidIAeq8MMSPtaPqMZcU7DKNBYq7)7ibRGOazOIkKzjTOTwpsbYuhYIYneqhBzFeqkzFz5ipEIrQhriOtaDSL9raPracaHGqaLZPcYGOgXi15ojOtaLZPcYGOgbeVPjB6eWzYhZ0Rq759qM6qgAJBHmurfYOqMZcU7DKNBYq7)7ibRGOqaDSL9ravAl7JyK6r5wc6eq5CQGmiQraXBAYMobenq2SXipKPoKbK4widvuHmC3Hrx9k4U3rEUjdT)VJeSYk0EEpKPoKXJhqgkHmaHm0azFJeOYBuuqEdjiAzruSSVICovqgqgQOczFJeOYBuQ1b3YGO)outoRiNtfKbKHscOJTSpc4miFm86tJaMNj7IOy6CsaXX87KqE8agPVrcu5nkkiVHeeTSikw2hXi1JgLGobuoNkidIAeq8MMSPtaNng5HmaGmS)MEfE5Gm1HSzJr(cTxbKbiKTiNm7LxkFJeM9YlAHMs2ViansQOididqiZ8vBRRuwH2Z7Hm1HmE8aYaeYWDhgD1Rmd(kLvO98EitDiJhpGmaHm0azo2YAIwoHoLhYIaKffYqfviZXwwt0Yj0P8qMkilkKbiKzjTOTwpsbYIaKbuqg3dz84bKHscOJTSpcO5R2wxHyK6rrbbDcOCovqge1iGo2Y(iGZGVcbeVPjB6eWzJrEidaid7VPxHxoitDiB2yKVq7vazaczMVABDLcIcKbiKTiNm7LxkFJeM9YlAHMs2ViansQOididqiZsArBTEKcKfbiRsHmUhY4XdcyiprJhequaueJupk3qqNakNtfKbrnciEtt20jGo2YAIwoHoLhYubzrHmaHmZxEXkwslAR1JuGm1HSzJrEiJtidnqwnFtNkifAk9(AC)gKv5qg2FtVcVCqgkHmUhY4XdcOJTSpcihziO)yTrms9OvkbDcOCovqge1iG4nnztNa6ylRjA5e6uEitfKffYaeYmF5fRyjTOTwpsbYuhYMng5HmoHm0az18nDQGuOP07RX9BqwLdzy)n9k8YbzOeY4EiJhpiGo2Y(iG09X39lAQ0eIrQhfOiOtaLZPcYGOgbeVPjB6eqhBznrlNqNYdzQGSOqgGqM5lVyflPfT16rkqM6q2SXipKXjKHgiRMVPtfKcnLEFnUFdYQCid7VPxHxoidLqg3dz84bb0Xw2hbCDfRx9BBYHqms9OOnc6eq5CQGmiQraXBAYMob08LxSYiFZpSazrqfKH2iGo2Y(iG(Riyt3tTft0IZheIrmc4Be0j1JsqNakNtfKbrnciEtt20jGZgJ8qgaqg2FtVcVCqM6q2SXiFH2RGa6yl7Jaoe3IPXXCowNMyK6OGGobuoNkidIAeqhBzFeWxwf5m9B5XtaXBAYMobmsq2OTYlRICM(T84lwI5ipEidqiZ8LxSIL0I2A9ifilcqgqcYqfviJczol1sfzFDn5A6cIcKbiKrHmNLAPISVUMCnDzfApVhYuhY4XdcioooiAZxEXEs9OeJuNBiOtaDSL9raNbpUm0FS2iGY5ubzquJyK6vkbDcOJTSpc4kFFULhV23TRsaLZPcYGOgXi1bkc6eqhBzFeWQzyOFLCt7jGY5ubzquJyK6Onc6eqhBzFeqC37ip3KH2)3rcgbuoNkidIAeJuhirqNa6yl7JaYrgc6pwBeq5CQGmiQrms9icbDcOCovqge1iG4nnztNaoBmYdzaazy)n9k8YbzQdzZgJ8fAVccOJTSpc4m4hh5XRFBtoeIrQZDsqNa6yl7Ja6AAKDiRUNA82vFcOCovqge1igPEuULGobuoNkidIAeq8MMSPtaNiHGEfCmF5fTL0cKPoKXJhqgQOczZgJ8qgaqg2FtVcVCqM6q2SXiFH2RaYaeYqdKDsfMUAQPAAQsTo4wgeidqiB0w5Lvrot)wE8flXCKhpKbiKnAR8YQiNPFlp(YkZv(yovqGmurfYoPctxn1unnvrjMSnDFcKbiKfjiJczol09X39l6jYgVGOazaczZgJ8qgaqg2FtVcVCqM6q2SXiFH2RaYQCiZXw2xHJme04MM2Vrb7VPxHxoiJ7HmUbYqjKHkQqML0I2A9ifitDilk3saDSL9raRMHXmxrt10ueJupAuc6eq5CQGmiQraXBAYMob0Xwwt0Yj0P8qweGSOqgGqwKGSf5KzV8szJhCoEZdCi7RX9nBKBKhV(Tn5q(Ia0iPIImiGo2Y(iGyFRjeJupkkiOtaLZPcYGOgbeVPjB6eqhBznrlNqNYdzraYIczaczrcYwKtM9YlLnEW54npWHSVg33SrUrE8632Kd5lcqJKkkYaYaeYWDhgD1RundJzUIMQPPktKqqVcoMV8I2sAbYIaK9ksiOnF5f7HmaHm0az4y(YlVEUo2Y(8aKfbidffGcYqfviB0w5JTUYjbnvttvSeZrE8qgkjGo2Y(iGuigoMSXjgPEuUHGobuoNkidIAeq8MMSPtaNng5HmaGmS)MEfE5Gm1HSzJr(cTxbb0Xw2hb8nrcABDfIrQhTsjOtaLZPcYGOgb0Xw2hbKUp(UFrtLMqaXBAYMob08GCwXdkXCTYkd36TiNtfKbKbiKHgiJczol09X39l6jYgVGOazaczuiZzHUp(UFrpr24LvO98EitDiB2yKhY4eYqdKvZ30PcsHMsVVg3VbzvoKH930RWlhKHsiJ7HmE8aYaeYIeKrHmNLQzyOFLCt7lRq759qgQOczuiZzHUp(UFrpr24LvO98Eidqi7KkmD1ut10ufLyY209jqgkjG444GOnF5f7j1Jsms9OafbDcOCovqge1iGo2Y(iGCKHGg300(niG4nnztNaorcb9k4y(YlAlPfitDiJhpGmaHSzJrEidaid7VPxHxoitDiB2yKVq7vqaXXXbrB(Yl2tQhLyK6rrBe0jGY5ubzquJa6yl7JaUUI1R(Tn5qiG4nnztNasHmNflv09uBXe9Ri(wEZXCazQGmUbYqfviB0w5JTUYjbnvttvSeZrE8eqCCCq0MV8I9K6rjgPEuGebDcOCovqge1iG4nnztNaoAR8Xwx5KGMQPPkwI5ipEcOJTSpciDF8D)IMknHyK6rJie0jGY5ubzquJa6yl7Ja(YQiNPFlpEciEtt20jGRmx5J5ubbYaeYmF5fRyjTOTwpsbYIaKbKGmurfYOqMZsTur2xxtUMUGOqaXXXbrB(Yl2tQhLyK6r5ojOtaLZPcYGOgbeVPjB6eWtQW0vtnvttv(yRRCsaYaeYMng5HSiaz18nDQGuOP07RX9Bqg3dzOaYaeYgTvEzvKZ0VLhFzfApVhYIaKbuqg3dz84bb0Xw2hbSAggZCfnvttrmsDuWTe0jGo2Y(iG4yohRt)eq5CQGmiQrmsDueLGobuoNkidIAeqhBzFeqoYqqJBAA)geq8MMSPtaNng5HmaGmS)MEfE5Gm1HSzJr(cTxbbehhheT5lVypPEuIrQJcuqqNakNtfKbrnciEtt20jGlYjZE5LYgp4C8Mh4q2xJ7B2i3ipE9BBYH8fbOrsffzqaDSL9raRMHXmxrt10ueJuhfCdbDcOCovqge1iGo2Y(iG09X39lAQ0eciEtt20jGuiZzHUp(UFrpr24fefidvuHSzJrEidaiZXw2xHJme04MM2Vrb7VPxHxoilcq2SXiFH2RaYQCilkqbzOIkKnAR8Xwx5KGMQPPkwI5ipEidvuHmkK5Sundd9RKBAFzfApVNaIJJdI28LxSNupkXi1rrLsqNakNtfKbrncOJTSpc46kwV632KdHaIJJdI28LxSNupkXi1rbqrqNakNtfKbrnciEtt20jGNuHPRMAQMMQuRdULbbYaeYgTvEzvKZ0VLhFXsmh5XdzOIkKDsfMUAQPAAQIsmzB6(eidvuHStQW0vtnvttv(yRRCsaYaeYMng5HSiazaf3saDSL9raRMHXmxrt10ueJyeqCq8AcbDs9Oe0jGY5ubzquJa6yl7Ja(YQiNPFlpEciEtt20jGMhKZkXIpw)1uPjf5CQGmGmaHmkK5SulvK911KRPlRq759qgGqgfYCwQLkY(6AY10LvO98EitDiJhpiG444GOnF5f7j1JsmsDuqqNa6yl7Jawndd9RKBApbuoNkidIAeJuNBiOtaDSL9rax57ZT841(UDvcOCovqge1igPELsqNa6yl7JaI7Eh55Mm0()osWiGY5ubzquJyK6afbDcOCovqge1iG4nnztNaorcb9k4y(YlAlPfitDiJhpiGo2Y(iGvZWyMROPAAkIrQJ2iOtaLZPcYGOgbeVPjB6eWf5KzV8s5K)ZJVQVXFTTUIsE8AxrXx3q(Ia0iPIImGmaHSzJrEitDiRMVPtfKcnLEFnUFJa(2MyJupkb0Xw2hbe7HG2Xw2NoKVrad5B6ZPfc4zoXi1bse0jGo2Y(iG4yohRt)eq5CQGmiQrms9icbDcOCovqge1iG4nnztNaoAR8Xwx5KGMQPPkwI5ipEidqidnq2OTsEMSNh0ubrg5XxEZXCazQdzOaYqfviB0w5JTUYjbnvttvwH2Z7Hm1HmE8aYqjb0Xw2hbKcXWXKnoXi15ojOtaLZPcYGOgbeVPjB6eWrBLp26kNe0unnvXsmh5XtaDSL9raX(wtigPEuULGobuoNkidIAeq8MMSPtaNng5HmaGmS)MEfE5Gm1HSzJr(cTxbb0Xw2hbCiUftJJ5CSonXi1JgLGobuoNkidIAeq8MMSPtaXX8LxE9CDSL95bilcqgkkafKbiKH7om6QxPAggZCfnvttvMiHGEfCmF5fTL0cKfbi7vKqqB(Yl2dzCczOGa6yl7JasHy4yYgNyK6rrbbDcOCovqge1iG4nnztNaoBmYdzaazy)n9k8YbzQdzZgJ8fAVccOJTSpc4m4hh5XRFBtoeIrQhLBiOtaLZPcYGOgbeVPjB6eqC3Hrx9kvZWyMROPAAQYeje0RGJ5lVOTKwGSiazVIecAZxEXEiJtidfqgGqM5b5SIhuI5ALvgU1BroNkidcOJTSpci23AcXi1JwPe0jGY5ubzquJa6yl7JaYrgcACtt73GaI30KnDc4SXipKbaKH930RWlhKPoKnBmYxO9kGmaHSjsiOxbhZxErBjTazQdz84bKbiKHgiBroz2lVuo5)84R6B8xBRROKhV2vu81nKViansQOididqid3Dy0vVYCfbiKhV2wxPScTN3dzacz4UdJU6vmF126kLvO98EidvuHSibzlYjZE5LYj)NhFvFJ)ABDfL841UIIVUH8fbOrsffzazOKaIJJdI28LxSNupkXi1Jcue0jGY5ubzquJaI30KnDcyKGSrBLQzymZv0unnvXsmh5XtaDSL9raRMHXmxrt10ueJupkAJGobuoNkidIAeq8MMSPtardKfji7KkmD1ut10uLp26kNeGmurfYIeKzEqoRundJzUIoVjYN9vKZPcYaYqjKbiKH7om6QxPAggZCfnvttvMiHGEfCmF5fTL0cKfbi7vKqqB(Yl2dzCczOGa6yl7JasHy4yYgNyK6rbse0jGY5ubzquJaI30KnDciU7WORELQzymZv0unnvzIec6vWX8Lx0wslqweGSxrcbT5lVypKXjKHccOJTSpci23AcXi1JgriOtaDSL9ra5idb9hRncOCovqge1igPEuUtc6eqhBzFeWzWJld9hRncOCovqge1igPok4wc6eqhBzFeqxtJSdz19uJ3U6taLZPcYGOgXi1rruc6eqhBzFeW3ejOT1viGY5ubzquJyK6Oafe0jGY5ubzquJaI30KnDc4SXipKbaKH930RWlhKPoKnBmYxO9kiGo2Y(iGVjsqBRRqmsDuWne0jGY5ubzquJa6yl7Ja(YQiNPFlpEciEtt20jGRmx5J5ubbYaeYmpiNvIfFS(RPstkY5ubzazaczMV8IvSKw0wRhPazraYIieqCCCq0MV8I9K6rjgPokQuc6eqhBzFeqSV1ecOCovqge1igPokakc6eq5CQGmiQraDSL9ra5idbnUPP9BqaXBAYMobC2yKhYaaYW(B6v4LdYuhYMng5l0EfqgGqgAGSf5KzV8s5K)ZJVQVXFTTUIsE8AxrXx3q(Ia0iPIImGmaHmC3Hrx9kZveGqE8ABDLYk0EEpKbiKH7om6QxX8vBRRuwH2Z7HmurfYIeKTiNm7LxkN8FE8v9n(RT1vuYJx7kk(6gYxeGgjvuKbKHscioooiAZxEXEs9OeJuhfOnc6eq5CQGmiQraDSL9raFzvKZ0VLhpbeVPjB6eWvMR8XCQGqaXXXbrB(Yl2tQhLyK6OairqNakNtfKbrncOJTSpciDF8D)IMknHaIJJdI28LxSNupkXi1rreHGobuoNkidIAeqhBzFeW1vSE1VTjhcbehhheT5lVypPEuIrmIraRj7N9rQJcUffr52isuuqaR67Lh)ta5UJOCh1Re15UaYqgKHEmbYsALEniB2lKfzLvWnnLBrgYwbOrYvgq230cK5iwt7MmGmCm)4LVaboIZtGSOazidT6RMSMmGSiBEqoRuzImKznKfzZdYzLktroNkiJidzUbzODOsYigYqt0kqzbcmeyU7ik3r9krDUlGmKbzOhtGSKwPxdYM9czr(TidzRa0i5kdi7BAbYCeRPDtgqgoMF8YxGahX5jqw0kfidzOvF1K1KbKbM0OfK9XpZRaYaIqM1qweJ4q2iRLF2hK1kY6wVqgA4eLqgAIwbklqGHaZDhr5oQxjQZDbKHmid9ycKL0k9Aq2SxilY4XhziBfGgjxzazFtlqMJynTBYaYWX8Jx(ce4iopbYIYTazidT6RMSMmGSi)nsGkVrPYeziZAilYFJeOYBuQmf5CQGmImKHguubklqGJ48eilk3aKHm0QVAYAYaYatA0cY(4N5vazariZAilIrCiBK1Yp7dYAfzDRxidnCIsidnrRaLfiWrCEcKfTsbYqgA1xnznzazGjnAbzF8Z8kGmGiKznKfXioKnYA5N9bzTISU1lKHgorjKHMOvGYce4iopbYIcuazidT6RMSMmGmWKgTGSp(zEfqgqeYSgYIyehYgzT8Z(GSwrw36fYqdNOeYqt0kqzbcmeyU7ik3r9krDUlGmKbzOhtGSKwPxdYM9czrMQvImKTcqJKRmGSVPfiZrSM2nzaz4y(XlFbcCeNNazrRuGmKHw9vtwtgqwKxKtM9YlLktKHmRHSiViNm7LxkvMICovqgrgYqt0kqzbcCeNNazrbkGmKHw9vtwtgqgysJwq2h)mVcidiczwdzrmIdzJSw(zFqwRiRB9czOHtuczOHBQaLfiWrCEcKffOaYqgA1xnznzazr28GCwPYeziZAilYMhKZkvMICovqgrgYqdkQaLfiWrCEcKffOaYqgA1xnznzazrEroz2lVuQmrgYSgYI8ICYSxEPuzkY5ubzezidnrRaLfiWqG5UJOCh1Re15UaYqgKHEmbYsALEniB2lKfzCq8AsKHSvaAKCLbK9nTazoI10UjdidhZpE5lqGJ48eilAuGmKHw9vtwtgqgysJwq2h)mVcidiczwdzrmIdzJSw(zFqwRiRB9czOHtuczOjAfOSaboIZtGSOCdqgYqR(QjRjdidmPrli7JFMxbKbeHmRHSigXHSrwl)SpiRvK1TEHm0WjkHm0eTcuwGahX5jqwu0gqgYqR(QjRjdidmPrli7JFMxbKbeHmRHSigXHSrwl)SpiRvK1TEHm0WjkHm0eTcuwGahX5jqwuGeqgYqR(QjRjdidmPrli7JFMxbKbeHmRHSigXHSrwl)SpiRvK1TEHm0WjkHm0eTcuwGadbUsqR0Rjdidibzo2Y(GSq(2xGataFfbtQJcGcOiGkBpZGqaRSqgiYwlR5bidTBKZKfcCLfYQ31eAkzHSOCbzOGBrruiWqGDSL99fLvWnnLBaOIZA(Movq46CArfnLEFnUFJRwr1lwo5QMhqevo2Y(k09X39lAQ0KcUFJRAEar0s4fvo2Y(kRRy9QFBtoKcUFJlCFJ0Y(uzEqoRq3hF3VOPstGa7yl77lkRGBAk3aqfNpcnDFAfXGa7yl77lkRGBAk3aqfNuTzbzONbpUmQMhV26kYdcSJTSVVOScUPPCdavCodYhdV(0Ga7yl77lkRGBAk3aqfNMVABDfUYPQf5KzV8s5BKWSxErl0uY(fbOrsffzab2Xw23xuwb30uUbGkoFtKG2wxbcmeyhBzFpaQ4Kgbiaecce4klKXD1qMht8bK53aYqF9dOrYqceeiRoANOfKjNqNYJ2riRQazJ(ISbzJgYSy5dzZEHmLGhx2hYOeSJ8cKLwKhqgLazw3q2R400XHm)gqwvbYW(fzdYwXhzioKH(6hqdzVIGZzIHmkK58lqGDSL99aOItB9dOrYqceYJx)XAJRCQksMV8IvYxRe84Ycb2Xw23dGkorErNMqZ150IQk52qoEj3vpK3Yl(RXEiWvovrHmNfC37ip3KH2)3rcwbrbvuP6)bCM8Xm9k0EEV6Cd3cb2Xw23dGkorErNMq)qGRSvwiRsQe84q20X5XdzXBKfYgncLbziNLbilEJazX8AcKPGyqg3H895wE8qweD3UkKn6QhxqwVqwoHmlMaz4UdJU6bz5dzw3qwOpEiZAiBibpoKnDCE8qw8gzHSkPncLvGSkXeYU(eiRNqMftEbYW9nsl77HmFfiZPccKznKrlgKvnTy5bzwmbYIYTq2l4(gpKfePQhNliZIjq2N0q20XYdzXBKfYQK2iugK5iwt7wI9qiEbcCLTYczo2Y(EauX5jvNnYn0R8DOMWvov9nsGkVr5KQZg5g6v(outaenuiZzzLVp3YJx772vlikOIkU7WORELv((ClpETVBxTScTN3hHOClQOA(YlwXsArBTEKI6rrBOecSJTSVhavCI9qq7yl7thY346CArfE8qGDSL99aOItShcAhBzF6q(gxNtlQOAfUYPkhBznrlNqNYRo3aO5b5ScvUJx3tTYkXlY5ubzab2Xw23dGkoXEiODSL9Pd5BCDoTO6nUYPkhBznrlNqNYRo3ayKmpiNvOYD86EQvwjEroNkidiWo2Y(EauXj2dbTJTSpDiFJRZPfv4G41eUYPkhBznrlNqNYhbuab2Xw23dGko9f7NOTEx5miWqGDSL99fQwr1lRICM(T845chhheT5lVyVQOCLtvuiZzPwQi7RRjxtxwH2Z7benuiZzPwQi7RRjxtxwH2Z7vNhpqf1vMR8XCQGGsiWo2Y((cvRaGko5idbnUPP9BWfoooiAZxEXEvr5kNQMng5ba7VPxHxo1Nng5l0EfasHmNLt(84R6B8xBRROKhV2vu81nKVGOGkQZgJ8aG930RWlN6ZgJ8fAVcaIYTasHmNLt(84R6B8xBRROKhV2vu81nKVGOaifYCwo5ZJVQVXFTTUIsE8AxrXx3q(Yk0EEV684beyhBzFFHQvaqfNCKHG(J1geyhBzFFHQvaqfNvZWyMROPAAkUYPQzJrEaW(B6v4Lt9zJr(cTxbGrYsmh5Xd4eje0RGJ5lVOTKwuNhpGa7yl77luTcaQ4Cg8JJ841VTjhcx5u1SXipay)n9k8YP(SXiFH2RacSJTSVVq1kaOIZzWJld9hRniWo2Y((cvRaGkoXEiODSL9Pd5BCDoTO6mNRCQAroz2lVuo5)84R6B8xBRROKhV2vu81nKViansQOidaNng5vVMVPtfKcnLEFnUFdcSJTSVVq1kaOIZH4wmnoMZX60CLtvZgJ8aG930RWlN6ZgJ8fAVciWo2Y((cvRaGkoxxX6v)2MCiCHJJdI28LxSxvuUYPkkK5SG7Eh55Mm0()osWkikasHmNfC37ip3KH2)3rcwzfApVx9OfGI75XdiWo2Y((cvRaGkoP7JV7x0uPjCHJJdI28LxSxvuUYPkkK5SG7Eh55Mm0()osWkikasHmNfC37ip3KH2)3rcwzfApVx9OfGI75XdiWo2Y((cvRaGkoDnnYoKv3tnE7QpeyhBzFFHQvaqfNRRy9QFBtoeUWXXbrB(Yl2Rkkx5uffYCwSur3tTft0VI4B5nhZHkUbcSJTSVVq1kaOIZQzymZv0unnfx5u1SXipay)n9k8YP(SXiFH2RaWizjMJ84bentKqqVcoMV8I2sArDE8avuJ0OTs1mmM5kAQMMQyjMJ84bKczol09X39l6jYgVScTN3hHjsiOxbhZxErBjTu5r5EE8avuJ0OTs1mmM5kAQMMQyjMJ84bmsuiZzHUp(UFrpr24LvO98EuIkQwslAR1JuupAebWinARundJzUIMQPPkwI5ipEiWvwiRsmHS4ncKn6lYgKfZRjqwD5)84R6B8i)qg6RROKhpKfrvu81nKNli7tALqCid7VbzO9ziazOvtt73aYYjKfVrGSQ9fzdY6AYIDfiRpidTRgJ8q2CBAiB05XdzFxGSkXeYI3iq2OHSyEnbYQl)NhFvFJh5hYqFDfL84HSiQIIVUH8qw8gbY(ynsyazy)nidTpdbidTAAA)gqwoHS4nYczZgJ8qw(qgLe6QqMftGmC)gK1tiRsI(47(fitT0eiRxiJ7WvSEHmqBtoeiWo2Y((cvRaGko5idbnUPP9BWfoooiAZxEXEvr5kNQMng5ba7VPxHxo1Nng5l0EfaIMiTiNm7LxkN8FE8v9n(RT1vuYJx7kk(6gYJkQZgJ8QxZ30PcsHMsVVg3VHsiWvwiJ7oTyqwD5)84R6B8i)qg6RROKhpKfrvu81nKhY6lehYq7ZqaYqRMM2VbKLtilEJSqMTUYdz(kqwFqgU7WORECbzTft2Q5lq2BTcKH85XdzO9ziazOvtt73aYYjKfVrwidJSRCgKnBmYdzoDJCgKLpKjxJWhdYSgYEK388GmlMazoDJCgK1tiZsAbYcY0GSzVqMFXHSEczXBKfYS1vEiZAid30cK1ZjKH7om6QheyhBzFFHQvaqfNCKHGg300(n4chhheT5lVyVQOCLtvZgJ8aG930RWlN6ZgJ8fAVcaxKtM9YlLt(pp(Q(g)126kk5XRDffFDd5be3Dy0vVYCfbiKhV2wxPScTN3hb0mBmYdertnFtNkifAk9(AC)wLJ930RWlhk5EE8aLaI7om6QxX8vBRRuwH2Z7JaAMng5bIOPMVPtfKcnLEFnUFRYX(B6v4LdLCppEGsartKmpiNvEtKG2wxbvunpiNvEtKG2wxbqC3Hrx9kVjsqBRRuwH2Z7JaAMng5bIOPMVPtfKcnLEFnUFRYX(B6v4LdLCppEGsucb2Xw23xOAfauX5BIe026kCLtvZgJ8aG930RWlN6ZgJ8fAVciWo2Y((cvRaGkoFzvKZ0VLhpx444GOnF5f7vfLRCQA0w5Lvrot)wE8LvMR8XCQGayKOqMZcU7DKNBYq7)7ibRGOab2Xw23xOAfauX5kFFULhV23TRcb2Xw23xOAfauXz1mm0VsUP9qGDSL99fQwbavCI7Eh55Mm0()osW4kNQIefYCwWDVJ8CtgA)FhjyfefiWo2Y((cvRaGkoP7JV7x0uPjCLtvuiZzHUp(UFrpr24fefurD2yKhahBzFfoYqqJBAA)gfS)MEfE5IWSXiFH2RavuPqMZcU7DKNBYq7)7ibRGOab2Xw23xOAfauX56kwV632KdHlCCCq0MV8I9QIcb2Xw23xOAfauXz1mmM5kAQMMIRCQA0wPAggZCfnvttvwzUYhZPcceyhBzFFHQvaqfNVSkYz63YJNlCCCq0MV8I9QIYvovrHmNLAPISVUMCnDbrbcmeyhBzFFbpEvX8vP7JRCQY8GCwXKL(19ulhVZl0Yzf5CQGmaC2yKx9zJr(cTxbeyhBzFFbpEauXjvO7HEISX5kNQOqMZcU7DKNBYq7)7ibRGOab2Xw23xWJhavC6hwEB9Gg7Hax5uffYCwWDVJ8CtgA)FhjyfefiWo2Y((cE8aOIZzUcvO7bx5uffYCwWDVJ8CtgA)FhjyfefiWo2Y((cE8aOIZqYhZEDLmYGNwodcSJTSVVGhpaQ4KY519uBBI545kNQWDhgD1RWrgcACtt73Omrcb9k4y(YlAlPLiWJhqGDSL99f84bqfNuY(YYrE8CLtvuiZzb39oYZnzO9)DKGvquqfvlPfT16rkQhLBGa7yl77l4XdGkoPracaHGab2Xw23xWJhavCQ0w2hx5u1m5Jz6vO98E1rBClQOsHmNfC37ip3KH2)3rcwbrbcSJTSVVGhpaQ4CgKpgE9PXvEMSlIIPZPkCm)ojKhpGr6BKavEJIcYBibrllIIL9XvovHMzJrE1bsClQOI7om6Qxb39oYZnzO9)DKGvwH2Z7vNhpqjGO5BKavEJIcYBibrllIIL9HkQFJeOYBuQ1b3YGO)outodLqGDSL99f84bqfNMVABDfUYPQzJrEaW(B6v4Lt9zJr(cTxbGlYjZE5LY3iHzV8IwOPK9lcqJKkkYaqZxTTUszfApVxDE8aqC3Hrx9kZGVszfApVxDE8aq04ylRjA5e6u(iefvuDSL1eTCcDkVQOaAjTOTwpsjcaf3ZJhOecSJTSVVGhpaQ4Cg8v4kKNOXdvOaO4kNQMng5ba7VPxHxo1Nng5l0EfaA(QT1vkikaUiNm7LxkFJeM9YlAHMs2ViansQOidaTKw0wRhPeHkL75XdiWo2Y((cE8aOItoYqq)XAJRCQYXwwt0Yj0P8QIcO5lVyflPfT16rkQpBmYdertnFtNkifAk9(AC)wLJ930RWlhk5EE8acSJTSVVGhpaQ4KUp(UFrtLMWvov5ylRjA5e6uEvrb08LxSIL0I2A9if1Nng5bIOPMVPtfKcnLEFnUFRYX(B6v4LdLCppEab2Xw23xWJhavCUUI1R(Tn5q4kNQCSL1eTCcDkVQOaA(YlwXsArBTEKI6ZgJ8ar0uZ30PcsHMsVVg3Vv5y)n9k8YHsUNhpGa7yl77l4XdGko9xrWMUNAlMOfNpiCLtvMV8Ivg5B(HLiOcTbbgcSJTSVVGdIxtu9YQiNPFlpEUWXXbrB(Yl2Rkkx5uL5b5SsS4J1FnvAsroNkidaPqMZsTur2xxtUMUScTN3difYCwQLkY(6AY10LvO98E15XdiWo2Y((coiEnbavCwndd9RKBApeyhBzFFbheVMaGkox57ZT841(UDviWo2Y((coiEnbavCI7Eh55Mm0()osWGa7yl77l4G41eauXz1mmM5kAQMMIRCQAIec6vWX8Lx0wslQZJhqGDSL99fCq8AcaQ4e7HG2Xw2NoKVX150IQZCUEBtSPkkx5u1ICYSxEPCY)5Xx134V2wxrjpETRO4RBiFraAKurrgaoBmYREnFtNkifAk9(AC)geyhBzFFbheVMaGkoXXCowN(Ha7yl77l4G41eauXjfIHJjBCUYPQrBLp26kNe0unnvXsmh5XdiAgTvYZK98GMkiYip(YBoMd1rbQOoAR8Xwx5KGMQPPkRq759QZJhOecSJTSVVGdIxtaqfNyFRjCLtvJ2kFS1vojOPAAQILyoYJhcSJTSVVGdIxtaqfNdXTyACmNJ1P5kNQMng5ba7VPxHxo1Nng5l0EfqGDSL99fCq8AcaQ4KcXWXKnox5ufoMV8YRNRJTSppebuuakaXDhgD1RundJzUIMQPPktKqqVcoMV8I2sAjcVIecAZxEXEGikGa7yl77l4G41eauX5m4hh5XRFBtoeUYPQzJrEaW(B6v4Lt9zJr(cTxbeyhBzFFbheVMaGkoX(wt4kNQWDhgD1RundJzUIMQPPktKqqVcoMV8I2sAjcVIecAZxEXEGika08GCwXdkXCTYkd36TiNtfKbeyhBzFFbheVMaGko5idbnUPP9BWfoooiAZxEXEvr5kNQMng5ba7VPxHxo1Nng5l0Efaorcb9k4y(YlAlPf15XdarZICYSxEPCY)5Xx134V2wxrjpETRO4RBiFraAKurrgaI7om6QxzUIaeYJxBRRuwH2Z7be3Dy0vVI5R2wxPScTN3JkQrAroz2lVuo5)84R6B8xBRROKhV2vu81nKViansQOiducb2Xw23xWbXRjaOIZQzymZv0unnfx5uvKgTvQMHXmxrt10uflXCKhpeyhBzFFbheVMaGkoPqmCmzJZvovHMiDsfMUAQPAAQYhBDLtcOIAKmpiNvQMHXmxrN3e5Z(kY5ubzGsaXDhgD1RundJzUIMQPPktKqqVcoMV8I2sAjcVIecAZxEXEGikGa7yl77l4G41eauXj23Acx5ufU7WORELQzymZv0unnvzIec6vWX8Lx0wslr4vKqqB(Yl2derbeyhBzFFbheVMaGko5idb9hRniWo2Y((coiEnbavCodECzO)yTbb2Xw23xWbXRjaOItxtJSdz19uJ3U6db2Xw23xWbXRjaOIZ3ejOT1vGa7yl77l4G41eauX5BIe026kCLtvZgJ8aG930RWlN6ZgJ8fAVciWo2Y((coiEnbavC(YQiNPFlpEUWXXbrB(Yl2Rkkx5u1kZv(yovqa08GCwjw8X6VMknPiNtfKbGMV8IvSKw0wRhPeHiceyhBzFFbheVMaGkoX(wtGa7yl77l4G41eauXjhziOXnnTFdUWXXbrB(Yl2Rkkx5u1SXipay)n9k8YP(SXiFH2Raq0SiNm7LxkN8FE8v9n(RT1vuYJx7kk(6gYxeGgjvuKbG4UdJU6vMRiaH84126kLvO98EaXDhgD1Ry(QT1vkRq759OIAKwKtM9YlLt(pp(Q(g)126kk5XRDffFDd5lcqJKkkYaLqGDSL99fCq8AcaQ48Lvrot)wE8CHJJdI28LxSxvuUYPQvMR8XCQGab2Xw23xWbXRjaOIt6(47(fnvAcx444GOnF5f7vffcSJTSVVGdIxtaqfNRRy9QFBtoeUWXXbrB(Yl2RkkeyiWo2Y((YzUQ3ejOT1vGa7yl77lN5aOIZ5kcqipETTUcx5uvKOqMZs1mm0VsUP9LvO98EurLczolvZWq)k5M2xwH2Z7be3Dy0vVchziOXnnTFJYk0EEpeyhBzFF5mhavCA(QT1v4kNQIefYCwQMHH(vYnTVScTN3JkQuiZzPAgg6xj30(Yk0EEpG4UdJU6v4idbnUPP9BuwH2Z7Hadb2Xw23xEt1qClMghZ5yDAUYPQzJrEaW(B6v4Lt9zJr(cTxbeyhBzFF5nauX5lRICM(T845chhheT5lVyVQOCLtvrA0w5Lvrot)wE8flXCKhpGMV8IvSKw0wRhPebGeQOsHmNLAPISVUMCnDbrbqkK5SulvK911KRPlRq759QZJhqGDSL99L3aqfNZGhxg6pwBqGDSL99L3aqfNR895wE8AF3UkeyhBzFF5nauXz1mm0VsUP9qGDSL99L3aqfN4U3rEUjdT)VJemiWo2Y((YBaOItoYqq)XAdcSJTSVV8gaQ4Cg8JJ841VTjhcx5u1SXipay)n9k8YP(SXiFH2RacSJTSVV8gaQ4010i7qwDp14TR(qGDSL99L3aqfNvZWyMROPAAkUYPQjsiOxbhZxErBjTOopEGkQZgJ8aG930RWlN6ZgJ8fAVcarZjvy6QPMQPPk16GBzqaC0w5Lvrot)wE8flXCKhpGJ2kVSkYz63YJVSYCLpMtfeur9KkmD1ut10ufLyY209jagjkK5Sq3hF3VONiB8cIcGZgJ8aG930RWlN6ZgJ8fAVIk3Xw2xHJme04MM2Vrb7VPxHxoUNBqjQOAjTOTwpsr9OCleyhBzFF5nauXj23Acx5uLJTSMOLtOt5JquaJ0ICYSxEPSXdohV5boK914(MnYnYJx)2MCiFraAKurrgqGDSL99L3aqfNuigoMSX5kNQCSL1eTCcDkFeIcyKwKtM9YlLnEW54npWHSVg33SrUrE8632Kd5lcqJKkkYaqC3Hrx9kvZWyMROPAAQYeje0RGJ5lVOTKwIWRiHG28LxShq0GJ5lV8656yl7ZdraffGcvuhTv(yRRCsqt10uflXCKhpkHa7yl77lVbGkoFtKG2wxHRCQA2yKhaS)MEfE5uF2yKVq7vab2Xw23xEdavCs3hF3VOPst4chhheT5lVyVQOCLtvMhKZkEqjMRvwz4wVf5CQGmaenuiZzHUp(UFrpr24fefaPqMZcDF8D)IEISXlRq759QpBmYdertnFtNkifAk9(AC)wLJ930RWlhk5EE8aWirHmNLQzyOFLCt7lRq759OIkfYCwO7JV7x0tKnEzfApVhWtQW0vtnvttvuIjBt3NGsiWo2Y((YBaOItoYqqJBAA)gCHJJdI28LxSxvuUYPQjsiOxbhZxErBjTOopEa4SXipay)n9k8YP(SXiFH2RacSJTSVV8gaQ4CDfRx9BBYHWfoooiAZxEXEvr5kNQOqMZILk6EQTyI(veFlV5youXnOI6OTYhBDLtcAQMMQyjMJ84Ha7yl77lVbGkoP7JV7x0uPjCLtvJ2kFS1vojOPAAQILyoYJhcSJTSVV8gaQ48Lvrot)wE8CHJJdI28LxSxvuUYPQvMR8XCQGaO5lVyflPfT16rkraiHkQuiZzPwQi7RRjxtxquGa7yl77lVbGkoRMHXmxrt10uCLtvNuHPRMAQMMQ8Xwx5KaGZgJ8rOMVPtfKcnLEFnUFJ7rbGJ2kVSkYz63YJVScTN3hbGI75XdiWo2Y((YBaOItCmNJ1PFiWo2Y((YBaOItoYqqJBAA)gCHJJdI28LxSxvuUYPQzJrEaW(B6v4Lt9zJr(cTxbeyhBzFF5nauXz1mmM5kAQMMIRCQAroz2lVu24bNJ38ahY(ACFZg5g5XRFBtoKViansQOidiWo2Y((YBaOIt6(47(fnvAcx444GOnF5f7vfLRCQIczol09X39l6jYgVGOGkQZgJ8a4yl7RWrgcACtt73OG930RWlxeMng5l0EfvEuGcvuhTv(yRRCsqt10uflXCKhpQOsHmNLQzyOFLCt7lRq759qGDSL99L3aqfNRRy9QFBtoeUWXXbrB(Yl2RkkeyhBzFF5nauXz1mmM5kAQMMIRCQ6KkmD1ut10uLADWTmiaoAR8YQiNPFlp(ILyoYJhvupPctxn1unnvrjMSnDFcQOEsfMUAQPAAQYhBDLtcaoBmYhbGIBjgXie]] )


end