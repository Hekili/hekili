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
        diamond_ice = 686, -- 203340
        dragonscale_armor = 3610, -- 202589
        hiexplosive_trap = 3606, -- 236776
        hunting_pack = 661, -- 203235
        mending_bandage = 662, -- 212640
        roar_of_sacrifice = 663, -- 53480
        scorpid_sting = 3609, -- 202900
        spider_sting = 3608, -- 202914
        sticky_tar = 664, -- 203264
        survival_tactics = 3607, -- 202746
        trackers_net = 665, -- 212638
        viper_sting = 3615, -- 202797
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

                if debuff.shrapnel_bomb.up then applyDebuff( "internal_bleeding", 9, min( 3, debuff.internal_bleeding.stack + 1 ) ) end
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
                removeBuff( "flayers_mark" )
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
            cooldown = 30,
            gcd = "spell",

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
            texture = function ()
                local a = current_wildfire_bomb and current_wildfire_bomb or "wildfire_bomb"
                if a == "wildfire_bomb" or not action[ a ] then return 2065634 end                
                return action[ a ].texture
            end,

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

        potion = "unbridled_fury",

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

    if state.level > 50 then
        spec:RegisterPack( "Survival", 20201016.9, [[dyeD5aqivkEKkLOlja0MuP6tcamkbLoLGkRsLs4vc0SqLAxc9lvIHHsXXqLSmuINHsPPjaQRjOyBOuPVHsfgNkLIZjazDcqzEqI7Hk2hkvDquQiTqivpuLs1hvPuQrIsfLtkaOvkrMPkL0oLO(jkvuTuvkL8uvmvvsFfLkI9QQ)sQblYHPSyiEmutwuxgzZs6Ze1OfKtl1Qfa51sWSj52OQDR0VvmCICCbvTCGNdA6uDDuSDiPVdPmEb05rjTEbOA(sO9t4NR)6FYMtFzwydlSHl2WfBJSjGytaXsa9hNvj6psgUGjt)znE6phgaQnQM6psgRQXY)1)ahgaM(ti3LGbSlxKBpedsep8xGnpJY8EwmWQ(fyZJV8heMw5bG7J8NS50xMf2WcB4InCX2iBci2eqSeM)ymEOb8NtZZOmVN92bw1)tOoNP9r(tMG4)ClfPdda1gvtjsSZywNaIs3srIDo2hecisCXwUfjwydlSrusu6wks3kHkPej2lsHHnX)OAOd)R)jtvJr5)1Vmx)1)yyVN9p8mb8aUI(dTgIIYp6V)Lz5V(hd79S)Hbs62jE4FO1quu(r)9VmB)R)Hwdrr5h9)yyVN9pytP0g27z1Qg6)r1qxVgp9hCg((xoa)x)dTgIIYp6)bdANaT9hd7nQKMwIVjOiHIiXYFmS3Z(hSPuAd79SAvd9)OAORxJN(d0F)lhM)6FO1quu(r)pyq7eOT)yyVrL00s8nbfj2lsC9hd79S)bBkL2WEpRw1q)pQg6614P)GvKHk9(xMD)R)XWEp7Fma2ws7daqR)hAnefLF0F)lZo(R)XWEp7Fqmz9u1oOXfG)Hwdrr5h93F)pyfzOs)1Vmx)1)qRHOO8J(FWG2jqB)XnfTE0japupvnTYMmXtRhP1quuwKUls1bZafjueP6GzGrElW)yyVN9pHmG0m77Fzw(R)XWEp7FqRvznuQbTd)dTgIIYp6V)Lz7F9p0Aikk)O)hmODc02FamlvhGmfHdJQoazst8ieagPWZ0ssuwKUlsUb0oWKIaI36fksOisY4SiDxKWZOYdABSQmafbeV1luKqrKKX5)yyVN9pUb0oWKE)lhG)R)Hwdrr5h9)GbTtG2(dGzP6aKPiCyu1bitAIhHaWifEMwsIYI0DrYnG2bMuKr6pg27z)tvza69VCy(R)XWEp7FaeCwZ7vwBaWG2FO1quu(r)9Vm7(x)dTgIIYp6)bdANaT9NkJsPbeoKbKjT38KiHIijJZ)XWEp7FqRv5AdinYWJ8(xMD8x)JH9E2)Gdzfagp8p0Aikk)O)(x(28x)dTgIIYp6)bdANaT9N84ryiGjTKsJm8irVXf6vwKUlsHvKYJh71jWAknIIOCVYrOB4cIekIelIuXIIuE8imeWKwsPrgEKiG4TEHIekIKmolsH7pg27z)dcJJdrawF)lhq)1)qRHOO8J(FWG2jqB)jpEegcyslP0idps0BCHEL)JH9E2)GnaQ07FzUyZF9p0Aikk)O)hmODc02FQdMbksbfjSbDnGKPvKqrKQdMbg5Ta)JH9E2)KjZdPXHScaJ)9VmxC9x)JH9E2)GNbK71CkRni0yu(FO1quu(r)9VmxS8x)dTgIIYp6)bdANaT9hCiditqDfyyVN1uIe7fjwIHrKUls4zu5bTnIwRY1gqAKHhjwzuknGWHmGmP9MNej2lsqjsP0UbKjhksxejw(JH9E2)GW44qeG13)YCX2)6FO1quu(r)pyq7eOT)uhmduKcksyd6AajtRiHIivhmdmYBb(hd79S)PQSTqVYAOd6c07FzUcW)1)qRHOO8J(FmS3Z(NcTsPXdpVT5)GbTtG2(tDWmqrkOiHnORbKmTIekIuDWmWiVfOiDxKQmkLgq4qgqM0EZtIekIKmo)hmRyfPDdito8lZ17FzUcZF9p0Aikk)O)hmODc02FUrKYJhrRv5AdinYWJe9gxOx5)yyVN9pO1QCTbKgz4rE)lZf7(x)dTgIIYp6)bdANaT9NWks3islfORrR1idpsegcyslPePIffPBej3u06r0AvU2as3BLb2ZgP1quuwKcNiDxKWZOYdABeTwLRnG0idpsSYOuAaHdzazs7npjsSxKGsKsPDditouKUisS8hd79S)bHXXHiaRV)L5ID8x)dTgIIYp6)bdANaT9h8mQ8G2grRv5AdinYWJeRmkLgq4qgqM0EZtIe7fjOePuA3aYKdfPlIel)XWEp7FWgav69Vmx3M)6FmS3Z(NcTsPHHg)p0Aikk)O)(xMRa6V(hd79S)PQmwPSggA8)qRHOO8J(7FzwyZF9pg27z)JP5zazcONQgdg0G)Hwdrr5h93)YSW1F9p0Aikk)O)hmODc02FUrKamlvhGmfxcc7vgndWku7atsQxzTjjzaZzGrk8mTKeLfPIffP6GzGIuqrcBqxdizAfPGIelHrKqrKQdMbg5Ta)JH9E2)aDIuAhysV)LzHL)6FO1quu(r)pg27z)dKas06AO3R8FWG2jqB)bqvabdziksKUlsUPO1JHyndmOgPDksRHOO8FWSIvK2nGm5WVmxV)LzHT)1)yyVN9pydGk9hAnefLF0F)lZsa(V(hAnefLF0)JH9E2)uOvknE45Tn)hmODc02FQdMbksbfjSbDnGKPvKqrKQdMbg5Ta)dMvSI0UbKjh(L569VmlH5V(hAnefLF0)JH9E2)ajGeTUg69k)hmODc02FaufqWqgIIeP7IuyfPBej3u06rKgKH6PQLaeRrAnefLfPIffPBejeMAnINbK71CkRni0yuEKrsKcNiDxKcRiDJibywQoazkcyvzfGUPkqaOgpBDy2CVYAOd6cemsHNPLKOSivSOiTuGUgTwJm8iruhL5TIePIffj3u06reghhIaSgP1quuwKcNivSOiHWuRruBjca1Os7WhzK(dMvSI0UbKjh(L569VmlS7F9p0Aikk)O)hd79S)HFw5zGKgPD6pyq7eOT)KjeMAnQmNwxlnnCwDVbic79SrOB4cIe7fPa6pywXks7gqMC4xMR3)YSWo(R)Hwdrr5h9)yyVN9patYhGg6GUa9hmODc02FYectTgvMtRRLMgoRU3aeH9E2i0nCbrI9Iua9hmRyfPDdito8lZ17FzwUn)1)qRHOO8J(FmS3Z(hibKO11qVx5)GbTtG2(ZnIKBkA9isdYq9u1saI1iTgIIYI0Dr6grYnfTEe1wIaqnQ0o8rAnefLfP7I0nIeGzP6aKPOYCADT00Wz19gGiSpayKcptljrzr6UiDJibywQoazkcyvzfGUPkqaOgpBDy2CVYAOd6cemsHNPLKO8FWSIvK2nGm5WVmxV)LzjG(R)Hwdrr5h9)yyVN9p8ZkpdK0iTt)bZkwrA3aYKd)YC9(xMTS5V(hAnefLF0)JH9E2)amjFaAOd6c0FWSIvK2nGm5WVmxV)(FWz4F9lZ1F9p0Aikk)O)hmODc02FWZOYdABepdi3R5uwBqOXO8iG4TEHIe7fj2YM)yyVN9piQzY6kdG13)YS8x)dTgIIYp6)bdANaT9h8mQ8G2gXZaY9AoL1geAmkpciERxOiXErITS5pg27z)JTyc6atPXMs9(xMT)1)qRHOO8J(FWG2jqB)bpJkpOTr8mGCVMtzTbHgJYJaI36fksSxKylB(JH9E2)uBaHOMj)(xoa)x)JH9E2)OA5qouhGyYY806)Hwdrr5h93)YH5V(hAnefLF0)dg0obA7p4zu5bTnINbK71CkRni0yuEeq8wVqrI9Ie7YgrQyrrYBEs7Jo3KiHIiXfB)JH9E2)Gqaibk0R87Fz29V(hAnefLF0)dg0obA7p1woKRbeV1luKqrKyHDfPIffjeMAnINbK71CkRni0yuEKr6pg27z)J049SV)Lzh)1)qRHOO8J(FWG2jqB)XnGm5XCdDBXKiXEoIe7(hd79S)XGse21tv7HinzYk693)d0)RFzU(R)Hwdrr5h9)GbTtG2(JBkA9OtaEOEQAALnzINwpsRHOOSiDxKQdMbksOis1bZaJ8wG)XWEp7FczaPz23)YS8x)dTgIIYp6)bdANaT9N6GzGIuqrcBqxdizAfjueP6GzGrElqr6UiHWuRrVL0tv7HinuImqe6gUGiHIiXwr6UiDJi5MIwpAkPqMwcqzZhqKwdrr5)yyVN9pfALsJhEEBZV)Lz7F9p0Aikk)O)hmODc02FYJhHHaM0sknYWJe9gxOxzr6UifwrkpESxNaRP0ikIY9khHUHlisOisSisflks5XJWqatAjLgz4rIaI36fksOisY4SiforQyrrcHPwJ8ZkpdK0vgaRrgjr6UiHWuRr(zLNbs6kdG1iG4TEHIekIuDWmqr6IiXw2is3crsgNfPIffj3u06rKgKH6PQLaeRrAnefLfP7IectTgXZaY9AoL1geAmkpYijs3fjeMAnINbK71CkRni0yuEeq8wVqrcfrsgN)JH9E2)WpR8mqsJ0o9(xoa)x)dTgIIYp6)bdANaT9N84ryiGjTKsJm8irVXf6vwKUlsHvKYJh71jWAknIIOCVYrOB4cIekIelIuXIIuE8imeWKwsPrgEKiG4TEHIekIKmolsHtKkwuKCtrRhrAqgQNQwcqSgP1quuwKUlsim1Aepdi3R5uwBqOXO8iJKiDxKqyQ1iEgqUxZPS2GqJr5raXB9cfjuejzC(pg27z)dWK8bOHoOlqV)LdZF9pg27z)dATkRHsnOD4FO1quu(r)9Vm7(x)dTgIIYp6)bdANaT9haZs1bitr4WOQdqM0epcbGrk8mTKeLfP7IKBaTdmPiG4TEHIekIKmols3fj8mQ8G2gRkdqraXB9cfjuejzC(pg27z)JBaTdmP3)YSJ)6FO1quu(r)pyq7eOT)aywQoazkchgvDaYKM4riamsHNPLKOSiDxKCdODGjfzK(JH9E2)uvgGE)lFB(R)XWEp7FWZaY9AoL1geAmk)p0Aikk)O)(xoG(R)XWEp7FaeCwZ7vwBaWG2FO1quu(r)9VmxS5V(hd79S)PQmwPSggA8)qRHOO8J(7FzU46V(hAnefLF0)dg0obA7p1bZafPGIe2GUgqY0ksOis1bZaJ8wG)XWEp7FYK5H04qwbGX)(xMlw(R)XWEp7Fk0kLggA8)qRHOO8J(7FzUy7F9p0Aikk)O)hmODc02FQdMbksbfjSbDnGKPvKqrKQdMbg5Ta)JH9E2)uv2wOxzn0bDb69Vmxb4)6FO1quu(r)pyq7eOT)uhmduKcksyd6AajtRiHIivhmdmYBbks3fjeMAn6TKEQApePHsKbIq3Wfejuej2ks3fPkJsPbeoKbKjT38KiHIiXIiDlejzC(pg27z)tHwP04HN3287FzUcZF9pg27z)doKvay8W)qRHOO8J(7FzUy3)6FmS3Z(htZZaYeqpvngmOb)dTgIIYp6V)L5ID8x)dTgIIYp6)bdANaT9NLc01O1AKHhjI6OmVvKiDxKYJhHeqIwxd9ELJEJl0RSiDxKYJhHeqIwxd9ELJaQciyidrr)XWEp7FqRv5AdinYWJ8(xMRBZF9p0Aikk)O)hmODc02FaufqWqgIIeP7IuyfjeMAnYpR8mqsxzaSgHUHlisOisHrKkwuKUrKCtrRh5NvEgiPrANI0AikklsHtKUlsHvKUrKqyQ1iEgqUxZPS2GqJr5rgjrQyrr6grYnfTEePbzOEQAjaXAKwdrrzrkCIuXIIectTgrTLiauJkTdFKr6pg27z)dKas06AO3R87FzUcO)6FO1quu(r)pyq7eOT)SuGUgTwJm8iryiGjTKsKUls1bZafj2lsSlBePIffPLc01O1AKHhjkfIad)SKiDxKcRivhmduKcksyd6AajtRifuKmS3Zgl0kLgp882MJyd6AajtRiDlej2ksOis1bZaJ8wGIuXIIKBkA9i)SYZajns7uKwdrrzr6UiDJiHWuRr(zLNbs6kdG1iJKiforQyrr6grkpEeTwLRnG0idps0BCHELfP7IuLrP0achYaYK2BEsKqrKKX5)yyVN9pO1QCTbKgz4rE)lZcB(R)Hwdrr5h9)GbTtG2(tDWmqrkOiHnORbKmTIekIuDWmWiVfOiDxKqyQ1O3s6PQ9qKgkrgicDdxqKqrKy7FmS3Z(NcTsPXdpVT53)YSW1F9p0Aikk)O)hmODc02FUrKamlvhGmfxcc7vgndWku7atsQxzTjjzaZzGrk8mTKeLfPIffP6GzGIuqrcBqxdizAfPGIelHrKqrKQdMbg5Ta)JH9E2)aDIuAhysV)LzHL)6FO1quu(r)pyq7eOT)aywQoazkUee2RmAgGvO2bMKuVYAtsYaMZaJu4zAjjkls3fP6GzGIuqrcBqxdizAfPGIelHrKqrKQdMbg5Ta)JH9E2)4gq7at69VmlS9V(hAnefLF0)dg0obA7paMLQdqMIlbH9kJMbyfQDGjj1RS2KKmG5mWifEMwsIYI0DrQoygOifuKWg01asMwrkOiXsyejueP6GzGrElW)yyVN9pvarb8EL1oWKE)lZsa(V(hAnefLF0)dg0obA7pim1AKFw5zGKUYaynYijsflks1bZafPGIKH9E2yHwP04HN32CeBqxdizAfj2ls1bZaJ8wG)XWEp7F4NvEgiPrANE)lZsy(R)Hwdrr5h9)GbTtG2(ZnI0sb6A0AnYWJeHHaM0skrQyrrcHPwJElPNQ2drAOezGi0nCbrI9IelIuXIIuDWmqrkOizyVNnwOvknE45TnhXg01asMwrI9IuDWmWiVf4FmS3Z(hGj5dqdDqxGE)lZc7(x)dTgIIYp6)bdANaT9heMAn6TKEQApePHsKbIq3Wfejuej2(hd79S)PqRuA8WZBB(9VmlSJ)6FO1quu(r)pyq7eOT)CJiLhpIwRY1gqAKHhj6nUqVYI0Dr6grYnfTEeTwLRnG09wzG9SrAnefL)JH9E2)GwRY1gqAKHh593)JeGWdpI5)1Vmx)1)qRHOO8J(FWG2jqB)bWSuDaYueomQ6aKjnXJqayKcptljr5)yyVN9pUb0oWKE)lZYF9pg27z)d0jsPDGj9hAnefLF0F)lZ2)6FmS3Z(h8mGCVMtzTbHgJY)dTgIIYp6V)(7)bvca7z)YSWgwydxSHlwIb0FqZaBVYW)WoHD6Tv5aWY32bmrsKUgIePMxAaUivhGifaa9aarcqHNPbuwKGdpjsgJp8MtzrchYwzcgfLU1EjrITbmr62Nfvc4uwKon)Tlsqwx3cuKcGIKpI0TYyIuUrTH9SI0iraZhGif2lHtKclxbgUOOKOe7e2P3wLdalFBhWejr6AisKAEPb4IuDaIuaawrgQuaGibOWZ0aklsWHNejJXhEZPSiHdzRmbJIs3AVKiXflbmr62Nfvc4uwKon)Tlsqwx3cuKcGIKpI0TYyIuUrTH9SI0iraZhGif2lHtKclxbgUOO0T2ljsCXUbmr62Nfvc4uwKon)Tlsqwx3cuKcGIKpI0TYyIuUrTH9SI0iraZhGif2lHtKclxbgUOO0T2ljsCXocyI0TplQeWPSiDA(BxKGSUUfOifafjFePBLXePCJAd7zfPrIaMparkSxcNifwUcmCrrjrPaqEPb4uwKcJizyVNvKun0HrrP)aLi8xMLWeM)ibMARO)ClfPdda1gvtjsSZywNaIs3srIDo2hecisCXwUfjwydlSrusu6wks3kHkPej2lsHHnrrjrjd79SWOeGWdpI5b5CXnG2bMe3DLdGzP6aKPiCyu1bitAIhHaWifEMwsIYIsg27zHrjaHhEeZdY5c0jsPDGjjkzyVNfgLaeE4rmpiNl4za5EnNYAdcngLlkjkzyVNfgXzyqoxquZK1vgaRC3vo4zu5bTnINbK71CkRni0yuEeq8wVq2Zw2ikzyVNfgXzyqoxSftqhykn2ukU7kh8mQ8G2gXZaY9AoL1geAmkpciERxi7zlBeLmS3ZcJ4mmiNl1gqiQzYC3vo4zu5bTnINbK71CkRni0yuEeq8wVq2Zw2ikzyVNfgXzyqoxuTCihQdqmzzEADrjd79SWioddY5ccbGeOqVYC3vo4zu5bTnINbK71CkRni0yuEeq8wVq2ZUSPyrV5jTp6CtOWfBfLmS3ZcJ4mmiNlsJ3ZYDx5uB5qUgq8wVquyHDlweHPwJ4za5EnNYAdcngLhzKeLmS3ZcJ4mmiNlguIWUEQApePjtwrC3voUbKjpMBOBlMyph2vusuYWEplmiNl8mb8aUIeLmS3ZcdY5cdK0Tt8qrjd79SWGCUGnLsByVNvRAOZ9A8ehCgkkzyVNfgKZfSPuAd79SAvdDUxJN4aDU7khd7nQKMwIVjikSikzyVNfgKZfSPuAd79SAvdDUxJN4GvKHkXDx5yyVrL00s8nbzpxIsg27zHb5CXayBjTpaaTUOKH9Ewyqoxqmz9u1oOXfGIsIsg27zHrOhKZLqgqAML7UYXnfTE0japupvnTYMmXtRhP1quu(EDWmquQdMbg5TafLmS3ZcJqpiNlfALsJhEEBZC3vo1bZadInORbKmTOuhmdmYBbEhHPwJElPNQ2drAOezGi0nCbuy79BCtrRhnLuitlbOS5disRHOOSOKH9Ewye6b5CHFw5zGKgPDI7UYjpEegcyslP0idps0BCHELVh284XEDcSMsJOik3RCe6gUakSuSyE8imeWKwsPrgEKiG4TEHOiJZHRyreMAnYpR8mqsxzaSgzKUJWuRr(zLNbs6kdG1iG4TEHOuhmdmaYw2ClKX5IfDtrRhrAqgQNQwcqSgP1quu(octTgXZaY9AoL1geAmkpYiDhHPwJ4za5EnNYAdcngLhbeV1lefzCwuYWEplmc9GCUamjFaAOd6ce3DLtE8imeWKwsPrgEKO34c9kFpS5XJ96eynLgrruUx5i0nCbuyPyX84ryiGjTKsJm8iraXB9crrgNdxXIUPO1Jinid1tvlbiwJ0AikkFhHPwJ4za5EnNYAdcngLhzKUJWuRr8mGCVMtzTbHgJYJaI36fIImolkzyVNfgHEqoxqRvznuQbTdfLmS3ZcJqpiNlUb0oWK4URCamlvhGmfHdJQoazst8ieagPWZ0ssu(UBaTdmPiG4TEHOiJZ3XZOYdABSQmafbeV1lefzCwuYWEplmc9GCUuvgG4URCamlvhGmfHdJQoazst8ieagPWZ0ssu(UBaTdmPiJKOKH9Ewye6b5Cbpdi3R5uwBqOXOCrjd79SWi0dY5cGGZAEVYAdag0eLmS3ZcJqpiNlvLXkL1WqJlkzyVNfgHEqoxYK5H04qwbGXZDx5uhmdmi2GUgqY0IsDWmWiVfOOKH9Ewye6b5CPqRuAyOXfLmS3ZcJqpiNlvLTf6vwdDqxG4URCQdMbgeBqxdizArPoygyK3cuuYWEplmc9GCUuOvknE45TnZDx5uhmdmi2GUgqY0IsDWmWiVf4DeMAn6TKEQApePHsKbIq3WfqHT3RmkLgq4qgqM0EZtOWYTqgNfLmS3ZcJqpiNl4qwbGXdfLmS3ZcJqpiNlMMNbKjGEQAmyqdkkzyVNfgHEqoxqRv5AdinYWJWDx5SuGUgTwJm8iruhL5TIUNhpcjGeTUg69kh9gxOx575XJqcirRRHEVYravbemKHOirjd79SWi0dY5cKas06AO3Rm3DLdGQacgYqu09WIWuRr(zLNbs6kdG1i0nCbuctXI34MIwpYpR8mqsJ0ofP1quuoC3d7nim1Aepdi3R5uwBqOXO8iJuXI34MIwpI0GmupvTeGynsRHOOC4kweHPwJO2seaQrL2HpYijkzyVNfgHEqoxqRv5AdinYWJWDx5SuGUgTwJm8iryiGjTK6EDWmq2ZUSPyXLc01O1AKHhjkfIad)S09Wwhmdmi2GUgqY0g0WEpBSqRuA8WZBBoInORbKmT3c2IsDWmWiVfyXIUPO1J8ZkpdK0iTtrAnefLVFdctTg5NvEgiPRmawJmsHRyXBYJhrRv5AdinYWJe9gxOx57vgLsdiCiditAV5juKXzrjd79SWi0dY5sHwP04HN32m3DLtDWmWGyd6Aajtlk1bZaJ8wG3ryQ1O3s6PQ9qKgkrgicDdxaf2kkzyVNfgHEqoxGorkTdmjU7kNBamlvhGmfxcc7vgndWku7atsQxzTjjzaZzGrk8mTKeLlwSoygyqSbDnGKPnilHbL6GzGrElqrjd79SWi0dY5IBaTdmjU7khaZs1bitXLGWELrZaSc1oWKK6vwBssgWCgyKcptljr571bZadInORbKmTbzjmOuhmdmYBbkkzyVNfgHEqoxQaIc49kRDGjXDx5aywQoazkUee2RmAgGvO2bMKuVYAtsYaMZaJu4zAjjkFVoygyqSbDnGKPnilHbL6GzGrElqrjd79SWi0dY5c)SYZajns7e3DLdctTg5NvEgiPRmawJmsflwhmdmOH9E2yHwP04HN32CeBqxdizAzFDWmWiVfOOKH9Ewye6b5Cbys(a0qh0fiU7kNBwkqxJwRrgEKimeWKwsvSictTg9wspvThI0qjYarOB4cSNLIfRdMbg0WEpBSqRuA8WZBBoInORbKmTSVoygyK3cuuYWEplmc9GCUuOvknE45TnZDx5GWuRrVL0tv7HinuImqe6gUakSvuYWEplmc9GCUGwRY1gqAKHhH7UY5M84r0AvU2asJm8irVXf6v((nUPO1JO1QCTbKU3kdSNnsRHOOSOKOKH9EwyeRidvkiNlHmG0ml3DLJBkA9OtaEOEQAALnzINwpsRHOO896GzGOuhmdmYBbkkzyVNfgXkYqLcY5cATkRHsnODOOKH9EwyeRidvkiNlUb0oWK4URCamlvhGmfHdJQoazst8ieagPWZ0ssu(UBaTdmPiG4TEHOiJZ3XZOYdABSQmafbeV1lefzCwuYWEplmIvKHkfKZLQYae3DLdGzP6aKPiCyu1bitAIhHaWifEMwsIY3DdODGjfzKeLmS3ZcJyfzOsb5CbqWznVxzTbadAIsg27zHrSImuPGCUGwRY1gqAKHhH7UYPYOuAaHdzazs7npHImolkzyVNfgXkYqLcY5coKvay8qrjd79SWiwrgQuqoxqyCCicWk3DLtE8imeWKwsPrgEKO34c9kFpS5XJ96eynLgrruUx5i0nCbuyPyX84ryiGjTKsJm8iraXB9crrgNdNOKH9EwyeRidvkiNlydGkXDx5KhpcdbmPLuAKHhj6nUqVYIsg27zHrSImuPGCUKjZdPXHScaJN7UYPoygyqSbDnGKPfL6GzGrElqrjd79SWiwrgQuqoxWZaY9AoL1geAmkxuYWEplmIvKHkfKZfeghhIaSYDx5GdzazcQRad79SMI9SedZD8mQ8G2grRv5AdinYWJeRmkLgq4qgqM0EZtShkrkL2nGm5WailIsg27zHrSImuPGCUuv2wOxzn0bDbI7UYPoygyqSbDnGKPfL6GzGrElqrjd79SWiwrgQuqoxk0kLgp882M5gZkwrA3aYKd5Wf3DLtDWmWGyd6Aajtlk1bZaJ8wG3RmkLgq4qgqM0EZtOiJZIsg27zHrSImuPGCUGwRY1gqAKHhH7UY5M84r0AvU2asJm8irVXf6vwuYWEplmIvKHkfKZfeghhIaSYDx5e2BwkqxJwRrgEKimeWKwsvS4nUPO1JO1QCTbKU3kdSNnsRHOOC4UJNrLh02iATkxBaPrgEKyLrP0achYaYK2BEI9qjsP0UbKjhgazruYWEplmIvKHkfKZfSbqL4URCWZOYdABeTwLRnG0idpsSYOuAaHdzazs7npXEOePuA3aYKddGSikzyVNfgXkYqLcY5sHwP0WqJlkzyVNfgXkYqLcY5svzSsznm04Isg27zHrSImuPGCUyAEgqMa6PQXGbnOOKH9EwyeRidvkiNlqNiL2bMe3DLZnaMLQdqMIlbH9kJMbyfQDGjj1RS2KKmG5mWifEMwsIYflwhmdmi2GUgqY0gKLWGsDWmWiVfOOKH9EwyeRidvkiNlqcirRRHEVYCJzfRiTBazYHC4I7UYbqvabdzik6UBkA9yiwZadQrANI0AikklkzyVNfgXkYqLcY5c2aOsIsg27zHrSImuPGCUuOvknE45TnZnMvSI0UbKjhYHlU7kN6GzGbXg01asMwuQdMbg5TafLmS3ZcJyfzOsb5CbsajADn07vMBmRyfPDditoKdxC3voaQciyidrr3d7nUPO1Jinid1tvlbiwJ0AikkxS4nim1Aepdi3R5uwBqOXO8iJu4Uh2BamlvhGmfbSQScq3ufiauJNTomBUxzn0bDbcgPWZ0ssuUyXLc01O1AKHhjI6OmVvuXIUPO1JimooebynsRHOOC4kweHPwJO2seaQrL2HpYijkzyVNfgXkYqLcY5c)SYZajns7e3ywXks7gqMCihU4URCYectTgvMtRRLMgoRU3aeH9E2i0nCb2hqIsg27zHrSImuPGCUamjFaAOd6ce3ywXks7gqMCihU4URCYectTgvMtRRLMgoRU3aeH9E2i0nCb2hqIsg27zHrSImuPGCUajGeTUg69kZnMvSI0UbKjhYHlU7kNBCtrRhrAqgQNQwcqSgP1quu((nUPO1JO2seaQrL2HpsRHOO89BamlvhGmfvMtRRLMgoRU3aeH9baJu4zAjjkF)gaZs1bitraRkRa0nvbca14zRdZM7vwdDqxGGrk8mTKeLfLmS3ZcJyfzOsb5CHFw5zGKgPDIBmRyfPDditoKdxIsg27zHrSImuPGCUamjFaAOd6ce3ywXks7gqMCihUE)9)b]] )
    else
        spec:RegisterPack( "Survival", 20201016.1, [[dS013bqifLEervvxIOQI2Ki6tevvYOeH6ukaRseYRaWSiQClavAxK8lIIHbPQJPiTmIQ8mfittbQUgGY2ua5BkqPXbOIZbOQwhGQW8aO7rK2hKkhubkSqIspeqv0fvavAJaQs1hjQQGrcOkXjvGIwjGmtfqv3ubur7es8tavPmufqfwkrvf6PqmviPVsuvP2lu)LWGP4WuTyv8yetwuxg1Mj1NfPrRioTKvRakVgsz2u62aTBL(TudxHooGQKwoONRQPlCDvA7kQ(UcA8kkoViy9evL5te7hPXtXOIrYEWyuKh6Lh6NI(PdKA6GpDGgegjsyKXiJobnpLXiRdYyeKlCEn3TyKrpbB7zmQyKVVqcJrMeX4d8qgzsRyY9OinOmFbETEu9sGUoK5lqImyKZTSXG5IpyKShmgf5HE5H(POF6aPMo4tNoiGHr8BmPHyeKc8A9O6f4j01bgzsLZ8IpyKm)emI8NAqUW51C3snaVC3GHuGK)udWBKOpmKAMoqYrnYd9Yd9uGOaj)PMbEEoBPgaLsnad9kmIT(4XOIr8XpWOIrzkgvmItIQxmcAL1k(jDGr41pwoJLfhyuKhgvmcV(XYzSSyecScgwog5C1AfPByUwp4SW)3V2qDhPMKutIPMZvRvKUH5A9GZc)F)AdfKb9AFQbqQzQcyutIOMusMAKiHAoxTwDSxOO1IWT9(Q7i1KKAoxTwDSxOO1IWT9(kid61(udGuZufWOMernPKm1mamItIQxmcyVPD)S4ubJdmkdcJkgHx)y5mwwmcbwbdlhJCUATI0nmxRhCw4)7xBOUJutsQjXuZ5Q1ks3WCTEWzH)VFTHcYGETp1ai1mvbmQjrutkjtnsKqnNRwRo2lu0Ar42EF1DKAssnNRwRo2lu0Ar42EFfKb9AFQbqQzQcyutIOMusMAgagXjr1lgb6JrdfFal0yCGrzWXOIr41pwoJLfJqGvWWYXi6MCFQbaQH4FiGCkVudGuJUj3xb6ZGrCsu9Ir0wFrR2uXhWcnghyuaggvmcV(XYzSSyecScgwogrFTwbKjtCyklIcKPgaPMPkGrnjIAsjzQjj1OBY9PgaOgI)HaYP8snasn6MCFfOpdgXjr1lgbTYAfKge03mgHKaXYIWHPC8yuMIdmkdegvmcV(XYzSSyecScgwogr3K7tnaqne)dbKt5LAaKA0n5(kqFgmItIQxmYhmBfb0hXbgLblgvmcV(XYzSSyecScgwogr3K7tnaqne)dbKt5LAaKA0n5(kqFgQjj1ml1efbTAtPMKuZSuZ5Q1kqgSHjiATWEjvwKHSd(Q7i1KKAsm1OVwRaYKjomLfrbYudGuZufWOMernPKm1irc1ml1K7qnSSzDbzXPbpQOiOvBk1KKAMLAoxTwr6gMR1dol8)9Rnu3rQrIeQzwQj3HAyzZ6cYItdEurrqR2uQjj1CUATcS30UFwOVWeuF4e0OgaPMPuZaOgjsOMOazr0ICXudGuZuGd1KKAMLAYDOgw2SUGS40Ghvue0QnfJ4KO6fJmSSzDbzXPbp4aJcWbJkgHx)y5mwwmcbwbdlhJml1K7q9mCK3q8rTPQOiOvBk1KKAMLAoxTwr6gMR1dol8)9Rnu3rmItIQxmYZWrEdXh1MIdmkaFmQyeE9JLZyzXieyfmSCmIUj3NAaGAi(hciNYl1ai1OBY9vG(mutsQjXuZ5Q1kWEt7(zH(ctq9HtqJAaKAag1irc1OBY9PgaPgNevVkWEt7(zXPcwr6pOMbGrCsu9IrqRSwbPbb9nJrijqSSiCykhpgLP4aJYu0JrfJWRFSCgllgHaRGHLJrGSgY)e)yzQjj1ml1CUATI0nmxRhCw4)7xBOUJutsQ5C1AfyVPD)SqFHjO(WjOrnasnadJ4KO6fJ8mCK3q8rTP4aJY0PyuXi86hlNXYIriWkyy5yKzPMZvRvKUH5A9GZc)F)Ad1DeJ4KO6fJ4cWlmZqrRfeyp8XbgLPYdJkgHx)y5mwwmcbwbdlhJml1CUATI0nmxRhCw4)7xBOUJyeNevVyes3WCTEWzH)VFTboWOmDqyuXi86hlNXYIriWkyy5yKZvRvG9M29Zc9fMG6osnsKqn6MCFQbaQH4FiGCkVud6OgDtUVc0NHAaUuZu0tnsKqnNRwRiDdZ16bNf()(1gQ7igXjr1lgbS30UFwCQGXbgLPdogvmItIQxmc0hJgk(awOXyeE9JLZyzXbgLPadJkgHx)y5mwwmcbwbdlhJml1efbTAtXiojQEXidlBwxqwCAWdoWbgzOUWOIrzkgvmItIQxmcAL1k(jDGr41pwoJLfhyuKhgvmcV(XYzSSyecScgwogr3K7tnaqne)dbKt5LAaKA0n5(kqFgQjj1eUL3qfme8fTwWBQNYG8gkE9JLZyeNevVyKjoCS7fhyugegvmcV(XYzSSyecScgwog5C1A1XEHIwlc327RUJutsQ5C1A1XEHIwlc327RGmOx7tnasnPKmgXjr1lgbS30UFwCQGXbgLbhJkgHx)y5mwwmcbwbdlhJCUAT6yVqrRfHB79v3rQjj1CUAT6yVqrRfHB79vqg0R9PgaPMusgJ4KO6fJa9XOHIpGfAmoWOammQyeE9JLZyzXieyfmSCmY5Q1Q51idFXCEBq1DKAssnNRwRMxJm8fZ5Tbvqg0R9PgaPMPkGrnjIAsjzQrIeQzwQj3H6z4iVH4JAtvrrqR2umItIQxmYZWrEdXh1MIdmkdegvmcV(XYzSSyecScgwogrFTwbKjtCyklIcKPgaPMPkGrnjIAsjzQjj1OBY9PgaOgI)HaYP8snasn6MCFfOpd1irc1KyQz5zcXWsCAWJAEB9OSm1KKAYDOEgoYBi(O2uvue0QnLAssn5oupdh5neFuBQcYAi)t8JLPgjsOMLNjedlXPbpQXjmSb7LPMKuZSuZ5Q1kWEt7(zH(ctqDhPMKuJUj3NAaGAi(hciNYl1ai1OBY9vG(mudWLACsu9QqRSwbPbb9nRi(hciNYl1KiQzquZaWiojQEXidlBwxqwCAWdoWOmyXOIr41pwoJLfJqGvWWYXi6MCFQbaQH4FiGCkVudGuJUj3xb6ZqnaxQr3K7RGCkVyeNevVye0kRvqAqqFZyescellchMYXJrzkoWOaCWOIrCsu9IrCb4fMzOO1ccSh(yeE9JLZyzXbgfGpgvmcV(XYzSSyecScgwogr3K7tnaqne)dbKt5LAaKA0n5(kqFgmItIQxmYhmBfb0hXbgLPOhJkgHx)y5mwwmcbwbdlhJOVwRaYKjomLfrbYudGuZufWOMernPKmgXjr1lgzyzZ6cYItdEWbgLPtXOIrCsu9IriDdZ16bNf()(1gyeE9JLZyzXbgLPYdJkgHx)y5mwwmcbwbdlhJCUATAEnYWxmN3guDhPMKutUd1ZWrEdXh1MQGmOx7tnasndo1KiQjLKXiojQEXipdh5neFuBkoWOmDqyuXi86hlNXYIriWkyy5yKChQFc0hx2kon4rffbTAtPgjsOMZvRvG9M29Zc9fMG6dNGg1iLAaggXjr1lgbS30UFwCQGXbgLPdogvmcV(XYzSSyecScgwogz5zcXWsCAWJ6Na9XLTutsQj3H6z4iVH4JAtvqg0R9Pg0rnaJAse1KsYyeNevVyKHLnRlilon4bhyuMcmmQyeE9JLZyzXieyfmSCmcK1q(N4hlJrCsu9IrEgoYBi(O2uCGrz6aHrfJWRFSCgllgHaRGHLJrMLAoxTwb2BA3pl0xyckid61(yeNevVyeYehnOd(4aJY0blgvmItIQxmcyVPD)S4ubJr41pwoJLfhyuMcCWOIrCsu9IrG(y0qXhWcngJWRFSCglloWOmf4JrfJWRFSCgllgHaRGHLJroxTwnVgz4lMZBdQUJyeNevVyKNHJ8gIpQnfhyuKh6XOIr41pwoJLfJqGvWWYXilptigwItdEuZBRhLLPMKutUd1ZWrEdXh1MQIIGwTPuJejuZYZeIHL40Gh14eg2G9YuJejuZYZeIHL40Gh1pb6JlBXiojQEXidlBwxqwCAWdoWbgjZA)AdmQyuMIrfJ4KO6fJaELp5ZYyeE9JLZyzXbgf5HrfJ4KO6fJCFwubd(yeE9JLZyzXbgLbHrfJWRFSCgllgXjr1lgH4wRWjr1RWwFGrS1hI1bzmcj)4aJYGJrfJWRFSCgllgHaRGHLJrCsuZzbVmyXp1iLAMsnjPMWHPCOIcKfrlYftnasn6MCFQrgQjXuJtIQxfyVPD)S4ubRi9hudWLAi(hciNYl1maQjrutkjJrCsu9Ira7nT7NfNkyCGrbyyuXi86hlNXYIrCsu9IriU1kCsu9kS1hyecScgwogXjrnNf8YGf)udGuZGOMKut4wEdfzIJg0bFfV(XYzQjj1eUL3q52XjUyeYzpAOIx)y5mgXwFiwhKXi(4qDHdmkdegvmcV(XYzSSyeNevVyeIBTcNevVcB9bgHaRGHLJrCsuZzbVmyXp1ai1miQjj1eUL3qrM4ObDWxXRFSCgJyRpeRdYyKH6chyugSyuXi86hlNXYIrCsu9IriU1kCsu9kS1hyecScgwogXjrnNf8YGf)udGuZGOMKuZSut4wEdLBhN4IriN9OHkE9JLZutsQzwQjClVHAyzZ6cYIA13V6vXRFSCgJyRpeRdYyKpWbgfGdgvmcV(XYzSSyeNevVyeIBTcNevVcB9bgHaRGHLJrCsuZzbVmyXp1ai1miQjj1eUL3q52XjUyeYzpAOIx)y5m1KKAMLAc3YBOgw2SUGSOw99REv86hlNXi26dX6GmgXh)ahyua(yuXi86hlNXYIrCsu9IriU1kCsu9kS1hyecScgwogXjrnNf8YGf)udGuZGOMKut4wEdLBhN4IriN9OHkE9JLZutsQjClVHAyzZ6cYIA13V6vXRFSCgJyRpeRdYyeFCOUWbgLPOhJkgHx)y5mwwmItIQxmcXTwHtIQxHT(aJqGvWWYXiojQ5SGxgS4NAaKAge1KKAMLAc3YBOC74exmc5ShnuXRFSCMAssnHB5nudlBwxqwuR((vVkE9JLZyeB9HyDqgJmux4aJY0PyuXi86hlNXYIrCsu9IriU1kCsu9kS1hyecScgwogXjrnNf8YGf)ud6OMPutsQzwQjClVH6uW8lATyeYjO41pwotnsKqnojQ5SGxgS4NAqh1ipmIT(qSoiJriw2NZ4aJYu5HrfJ4KO6fJq6LWBa9GZcT1bzmcV(XYzSS4aJY0bHrfJ4KO6fJ4qIVSiAiK3aJWRFSCglloWOmDWXOIrCsu9IroEQO1Iawe0EmcV(XYzSS4ahyeIL95mgvmktXOIr41pwoJLfJ0JyKNJsJrCsu9IrM7WYpwgJm3HI1bzmcXHZzbjdXiZD7LXiojQ5SGxgS4hJm3TxwW2NXiadJqGvWWYXiojQ5SGxgS4NAaKAagoWOipmQyeE9JLZyzXieyfmSCmIlFmScwDSxOO1IWT9(kOVOrnOJAqp1KKAsm1CUATI0nmxRhCw4)7xBOUJutsQjXuZ5Q1ks3WCTEWzH)VFTHcYGETp1ai1mvbmQjrutkjtnsKqnNRwRo2lu0Ar42EF1DKAssnNRwRo2lu0Ar42EFfKb9AFQbqQzQcyutIOMusMAKiHAoxTwr6gMR1dol8)9Rnuqg0R9PMKuZSuZ5Q1QJ9cfTweUT3xbzqV2NAga1mamItIQxmcyVPD)S4ubJdmkdcJkgHx)y5mwwmcbwbdlhJK5ZvRvwp4neJD99Q(WjOrnOJAsm14KOMZcEzWIFQrIeQb4tndGAssn6kDsiGmOx7tnasnojQ5SGxgS4NAse1KsYyeNevVyeWEt7(zXPcgJqsGyzr4WuoEmktXbgLbhJkgXjr1lgXfGxyMHIwliWE4Jr41pwoJLfhyuaggvmItIQxmcPByUwp4SW)3V2aJWRFSCglloWOmqyuXi86hlNXYIriWkyy5yKChQFc0hx2kon4rffbTAtPMKuZSut4wEd1KeYq)fNkyfV(XYzQrIeQj3H6Na9XLTItdEurrqR2uQjj14KOMZcEzWIFQbDudWWiojQEXiehoNXbgLblgvmcV(XYzSSyecScgwogzwQjClVHk9YqyzTUiCsuKxXRFSCMAKiHA0xRvazYehMYIOazQbqQjLKPgjsOgOxzbpN3q558RGmOx7tnasnde1KKAGELf8CEdLNZVINP(4XiojQEXidlBwxqwCAWdoWOaCWOIr41pwoJLfJqGvWWYXiKjomLFHg6KO61Tud6Og5Pag1irc1K7q9tG(4YwXPbpQOiOvBk1irc1q62M7HRAyzZ6cYItdEuqg0R9Pg0rnojQ5SGxgS4NAaUutkjtnsKqnz(C1A1X2Dw0ArmHf8YGjOGmOx7tnsKqnqVYcEoVHYZ5xbzqV2NAaKAag1KKAGELf8CEdLNZVINP(4XiojQEXiNBqMWWeWbgfGpgvmcV(XYzSSyecScgwogjZNRwRSEWBig767v9HtqJAqh1aCWiojQEXiG9M29ZItfmgHKaXYIWHPC8yuMIdmktrpgvmItIQxmczIJg0bFmcV(XYzSS4aJY0PyuXi86hlNXYIriWkyy5yeDtUp1aa1q8peqoLxQbqQr3K7Ra9zWiojQEXiOvwRG0GG(MXiKeiwweomLJhJYuCGrzQ8WOIr41pwoJLfJqGvWWYXiHB5nubdbFrRf8M6PmiVHIx)y5mgXjr1lgzIdh7EXbgLPdcJkgHx)y5mwwmcbwbdlhJeUL3qLEziSSwxeojkYR41pwoJrCsu9IrioCoJdmkthCmQyeE9JLZyzXieyfmSCmcPBBUhUQHLnRlilon4rbzqV2NAqh1KyQXjrnNf8YGf)uJejudWOMbGrCsu9Iro3GmHHjGdmktbggvmcV(XYzSSyecScgwogr3K7tnaqne)dbKt5LAaKA0n5(kqFgmItIQxmI26lA1Mk(awOX4aJY0bcJkgHx)y5mwwmcbwbdlhJK7qnSSzDbzXPbpkiRH8pXpwMAKiHAc3YBOgw2SUGSOw99REv86hlNXiojQEXidlBwxqwCAWdoWOmDWIrfJWRFSCgllgHaRGHLJroxTwnVgz4lMZBdQGStcmItIQxmYZWrEdXh1MIrijqSSiCykhpgLP4aJYuGdgvmcV(XYzSSyecScgwogH0Tn3dx1WYM1fKfNg8OGmOx7tnOJAM7WYpwwrC4CwqYqQrgQrEyeNevVyeIdNZ4aJYuGpgvmItIQxmYhmBfb0hXi86hlNXYIdmkYd9yuXi86hlNXYIriWkyy5yeiRH8pXpwMAssnNRwRIAu0ArmHf)i7q1hobnQbqQzqutsQz5zcXWsCAWJAEB9OSm1irc1aznK)j(XYutsQXLpgwbRSEWBig767vb9fnQbDud6XiojQEXipdh5neFuBkgHKaXYIWHPC8yuMIdmkYBkgvmcV(XYzSSyeNevVyeWEt7(zXPcgJqsGyzr4WuoEmktXbgf5jpmQyeE9JLZyzXiojQEXiqFmAO4dyHgJrijqSSiCykhpgLP4ahyKritAWJhyuXOmfJkgXjr1lg5VGG9kg5aJWRFSCglloWOipmQyeE9JLZyzXiRdYyex((jo0FHU3q0AXypKHyeNevVyex((jo0FHU3q0AXypKH4aJYGWOIrCsu9IrsVomx(kATWLpg2XemcV(XYzSS4aJYGJrfJ4KO6fJq6gMR1dol8)9RnWi86hlNXYIdmkadJkgXjr1lgzydT55CTci)96lHXi86hlNXYIdmkdegvmItIQxmYhmBfb0hXi86hlNXYIdmkdwmQyeNevVyKjoCS7fJWRFSCglloWbgHKFmQyuMIrfJWRFSCgllgHaRGHLJriDBZ9Wvr6gMR1dol8)9Rnuqg0R9Pg0rndc9yeNevVyKJT7SqFHjGdmkYdJkgHx)y5mwwmcbwbdlhJq62M7HRI0nmxRhCw4)7xBOGmOx7tnOJAge6XiojQEXi(s4pGUvqCRfhyugegvmcV(XYzSSyecScgwogH0Tn3dxfPByUwp4SW)3V2qbzqV2NAqh1mi0JrCsu9Ir0fKp2UZ4aJYGJrfJ4KO6fJyR0jXlgy3CkiVbgHx)y5mwwCGrbyyuXi86hlNXYIriWkyy5yes32CpCvKUH5A9GZc)F)AdfKb9AFQbDuZaHEQrIeQjkqweTixm1ai1mDqyeNevVyKddFgIwTP4aJYaHrfJWRFSCgllgHaRGHLJroxTwLEDyU8v0AHlFmSJjQ7i1KKAsm1CUAT6WWNHOvBQ6osnsKqnNRwRo2UZc9fMG6osnsKqnZsnqNWQa2wl1maQrIeQjXudP3)c6hlRg7O6v0AXDpWkB5SqFHjqnjPgDLojeqg0R9PgaPMbAk1irc1OR0jHaYGETp1ai1iVbIAga1irc1ml1W)ZlHvKEZ8(CwylnRBiHvG(aRHutsQ5C1AfPByUwp4SW)3V2qDhXiojQEXiJDu9IdmkdwmQyeE9JLZyzXieyfmSCms4Wuou56dFjm1GoPuZaHrCsu9Ir8FKjHO1Iyclyp1Y4aJcWbJkgHx)y5mwwmY6GmgX)jZ9LFb0LVgkin0TyeNevVye)Nm3x(fqx(AOG0q3IriWkyy5yKZvRvGmydtq0AH9sQSidzh8v3rQjj1OR0jHaYGETp1ai1q62M7HRcKbBycIwlSxsLfzi7GVcYGETp1aa1mfyuJejuZ5Q1Q0RdZLVIwlC5JHDmr9HtqJAKsnaJAssn6kDsiGmOx7tnasnKUT5E4QsVomx(kATWLpg2XefKb9AFQbaQrEONAKiHAY85Q1kOlFnuqAOBfz(C1AvUhUuJejuJUsNecid61(udGuJ8MsnsKqnNRwRg2qBEoxRaYFV(syfKb9AFQjj1OR0jHaYGETp1ai1q62M7HRAydT55CTci)96lHvqg0R9PgaOMPahQrIeQzwQjClVH6uW8lATyeYjO41pwotnjPgDLojeqg0R9PgaPgs32CpCvKUH5A9GZc)F)AdfKb9AFQbaQrEONAssnNRwRiDdZ16bNf()(1gkid61(4aJcWhJkgHx)y5mwwmY6Gmgj1TmXTwg(It3lgXjr1lgj1TmXTwg(It3lgHaRGHLJriDBZ9WvbYGnmbrRf2lPYImKDWxbzqV2NAKiHAc3YBOgw2SUGSOw99REv86hlNPMKudPBBUhUks3WCTEWzH)VFTHcYGETp1irc1ml1W)ZlHvGmydtq0AH9sQSidzh8vG(aRHutsQH0Tn3dxfPByUwp4SW)3V2qbzqV2hhyuMIEmQyeE9JLZyzXiRdYyex((jo0FHU3q0AXypKHyeNevVyex((jo0FHU3q0AXypKH4aJY0PyuXi86hlNXYIriWkyy5yeOxzbpN3q558RQLAqh1a8rp1KKA0n5(udGuJUj3xb6ZqnaxQrEaJAKiHAsm14KOMZcEzWIFQbDuZuQjj1ml1eUL3qDky(fTwmc5eu86hlNPgjsOgNe1CwWldw8tnOJAKh1maQjj1KyQ5C1A1XEHIwlc327RUJutsQ5C1A1XEHIwlc327RGmOx7tnOJAge1KiQjLKPgjsOMzPMZvRvh7fkATiCBVV6osndaJ4KO6fJOBY95SWLpgwbloSdIdmktLhgvmcV(XYzSSyecScgwogjXutIPgOxzbpN3q558RGmOx7tnOJAa(ONAKiHAMLAGELf8CEdLNZVINP(4PMbqnsKqnjMACsuZzbVmyXp1GoQzk1KKAMLAc3YBOofm)IwlgHCckE9JLZuJejuJtIAol4Lbl(Pg0rnYJAga1maQjj1OBY9PgaPgDtUVc0NbJ4KO6fJCSDNfTwetybVmyc4aJY0bHrfJWRFSCgllgHaRGHLJrsm1KyQb6vwWZ5nuEo)kid61(ud6OMbc9uJejuZSud0RSGNZBO8C(v8m1hp1maQrIeQjXuJtIAol4Lbl(Pg0rntPMKuZSut4wEd1PG5x0AXiKtqXRFSCMAKiHACsuZzbVmyXp1GoQrEuZaOMbqnjPgDtUp1ai1OBY9vG(myeNevVyKXlS0juBQ4y9pWbgLPdogvmItIQxms61H5YxrRfU8XWoMGr41pwoJLfhyuMcmmQyeNevVyeynoAzrTIF0jmgHx)y5mwwCGrz6aHrfJWRFSCgllgHaRGHLJr0xRvazYehMYIOazQbqQzk1KiQjLKXiojQEXiKEj8gqp4SqBDqghyuMoyXOIr41pwoJLfJqGvWWYXiNRwRGmbnl)Vq3qcRUJyeNevVyKyclU7PVBwOBiHXbgLPahmQyeNevVyKHn0MNZ1kG83RVegJWRFSCglloWOmf4JrfJWRFSCgllgHaRGHLJrchMYHAc72yIAKeud6OgGd6PgjsOMWHPCOMWUnMOgjb1aOuQrEONAKiHAchMYHkkqweTyKec5HEQbDuZGqpgXjr1lgbY(yTPcT1b5hhyuKh6XOIr41pwoJLfJqGvWWYXi8)8syfid2WeeTwyVKklYq2bFfOpWAi1KKAGSgY)e)yzQjj1CUATAEnYWxmN3guDhPMKuZSudPBBUhUkqgSHjiATWEjvwKHSd(kid61(yeNevVyKNHJ8gIpQnfhyuK3umQyeE9JLZyzXieyfmSCmc)pVewbYGnmbrRf2lPYImKDWxb6dSgsnjPMzPgs32CpCvGmydtq0AH9sQSidzh8vqg0R9XiojQEXiG9M29ZItfmoWOip5HrfJWRFSCgllgHaRGHLJr4)5LWkqgSHjiATWEjvwKHSd(kqFG1qQjj1OVwRaYKjomLfrbYudGuZufWOMernPKm1KKA0n5(udGuJtIQxfyVPD)S4ubRi9hutsQzwQH0Tn3dxfid2WeeTwyVKklYq2bFfKb9AFmItIQxmYWYM1fKfNg8GdmkYBqyuXi86hlNXYIriWkyy5yeDtUp1ai14KO6vb2BA3plovWks)b1KKAoxTwr6gMR1dol8)9Rnu3rmItIQxmcid2WeeTwyVKklYq2bFCGdmYhyuXOmfJkgXjr1lgbTYAf)KoWi86hlNXYIdmkYdJkgHx)y5mwwmcbwbdlhJeUL3qfme8fTwWBQNYG8gkE9JLZyeNevVyKjoCS7fhyugegvmcV(XYzSSyecScgwogr3K7tnaqne)dbKt5LAaKA0n5(kqFgmItIQxmI26lA1Mk(awOX4aJYGJrfJWRFSCgllgHaRGHLJroxTwr6gMR1dol8)9Rnu3rQjj1KyQ5C1AfPByUwp4SW)3V2qbzqV2NAaKAMQag1KiQjLKPgjsOMZvRvh7fkATiCBVV6osnjPMZvRvh7fkATiCBVVcYGETp1ai1mvbmQjrutkjtndaJ4KO6fJa9XOHIpGfAmoWOammQyeE9JLZyzXieyfmSCmY5Q1ks3WCTEWzH)VFTH6osnjPMetnNRwRiDdZ16bNf()(1gkid61(udGuZufWOMernPKm1irc1CUAT6yVqrRfHB79v3rQjj1CUAT6yVqrRfHB79vqg0R9PgaPMPkGrnjIAsjzQzayeNevVyeWEt7(zXPcghyugimQyeE9JLZyzXieyfmSCmIUj3NAaGAi(hciNYl1ai1OBY9vG(myeNevVye0kRvqAqqFZyescellchMYXJrzkoWOmyXOIr41pwoJLfJqGvWWYXiNRwRMxJm8fZ5Tbv3rQjj1CUATAEnYWxmN3gubzqV2NAaKAMsnjIAsjzmItIQxmYZWrEdXh1MIdmkahmQyeE9JLZyzXieyfmSCmIUj3NAaGAi(hciNYl1ai1OBY9vG(myeNevVyKpy2kcOpIdmkaFmQyeE9JLZyzXieyfmSCmIUj3NAaGAi(hciNYl1ai1OBY9vG(mutsQbYAi)t8JLPMKuJ(ATcitM4WuwefitnasnPKm1KKAMLAoxTwbYGnmbrRf2lPYImKDWxDhPgjsOgDtUp1aa1q8peqoLxQbqQr3K7Ra9zOMKutIPMzPMChQHLnRlilon4rffbTAtPMKutIPMzPMZvRvKUH5A9GZc)F)Ad1DKAKiHAoxTwb2BA3pl0xycQpCcAudGuZuQrIeQjkqweTixm1ai1mf4qnsKqnZsn5oudlBwxqwCAWJkkcA1MsnjPgx(yyfSAyzZmC5)f)foVM7wf0x0Og0rnONAga1maQjj1ml1CUATcKbBycIwlSxsLfzi7GV6oIrCsu9Irgw2SUGS40GhCGrzk6XOIr41pwoJLfJqGvWWYXiNRwRMxJm8fZ5Tbv3rQjj1K7q9mCK3q8rTPkid61(udGuZGtnjIAsjzQrIeQj3H6z4iVH4JAtvqwd5FIFSm1KKAMLAoxTwr6gMR1dol8)9Rnu3rmItIQxmYZWrEdXh1MIdmktNIrfJWRFSCgllgHaRGHLJrMLAoxTwr6gMR1dol8)9Rnu3rmItIQxmIlaVWmdfTwqG9WhhyuMkpmQyeE9JLZyzXieyfmSCmYSuZ5Q1ks3WCTEWzH)VFTH6oIrCsu9IriDdZ16bNf()(1g4aJY0bHrfJWRFSCgllgHaRGHLJroxTwb2BA3pl0xycQ7i1irc1OBY9PgaOgI)HaYP8snOJA0n5(kqFgQb4snYd9utsQjClVHAEnYWxmN3guXRFSCMAKiHA0n5(udaudX)qa5uEPg0rn6MCFfOpd1aCPMPutsQjClVHkyi4lATG3upLb5nu86hlNPgjsOMZvRvKUH5A9GZc)F)Ad1DeJ4KO6fJa2BA3plovW4aJY0bhJkgXjr1lgb6JrdfFal0ymcV(XYzSS4aJYuGHrfJWRFSCgllgHaRGHLJrYDOgw2SUGS40GhfK1q(N4hlJrCsu9Irgw2SUGS40GhCGrz6aHrfJWRFSCgllgHaRGHLJroxTwnVgz4lMZBdQUJyeNevVyKNHJ8gIpQnfh4aJ4Jd1fgvmktXOIrCsu9IrqRSwXpPdmcV(XYzSS4aJI8WOIr41pwoJLfJqGvWWYXiNRwRo2lu0Ar42EF1DKAssnNRwRo2lu0Ar42EFfKb9AFQbqQjLKXiojQEXiG9M29ZItfmoWOmimQyeE9JLZyzXieyfmSCmY5Q1QJ9cfTweUT3xDhPMKuZ5Q1QJ9cfTweUT3xbzqV2NAaKAsjzmItIQxmc0hJgk(awOX4aJYGJrfJWRFSCgllgHaRGHLJrMLAYDOEgoYBi(O2uvue0QnfJ4KO6fJ8mCK3q8rTP4aJcWWOIrCsu9IrCb4fMzOO1ccSh(yeE9JLZyzXbgLbcJkgHx)y5mwwmcbwbdlhJOVwRaYKjomLfrbYudGuZufWOMernPKm1irc1OBY9PgaOgI)HaYP8snasn6MCFfOpd1KKAsm1S8mHyyjon4rnVTEuwMAssn5oupdh5neFuBQkkcA1MsnjPMChQNHJ8gIpQnvbznK)j(XYuJejuZYZeIHL40Gh14eg2G9YutsQzwQ5C1AfyVPD)SqFHjOUJutsQr3K7tnaqne)dbKt5LAaKA0n5(kqFgQb4snojQEvOvwRG0GG(Mve)dbKt5LAse1miQzayeNevVyKHLnRlilon4bhyugSyuXiojQEXiKUH5A9GZc)F)AdmcV(XYzSS4aJcWbJkgHx)y5mwwmcbwbdlhJCUATcS30UFwOVWeuqg0R9PMKuZYZeIHL40Gh14eg2G9YyeNevVyeWEt7(zXPcghyua(yuXi86hlNXYIriWkyy5ye91AfqMmXHPSikqMAaKAMQag1KiQjLKPMKuJUj3NAaGAi(hciNYl1ai1OBY9vG(mudWLAKh6XiojQEXiOvwRG0GG(MXiKeiwweomLJhJYuCGrzk6XOIr41pwoJLfJqGvWWYXi6MCFQbaQH4FiGCkVudGuJUj3xb6ZGrCsu9Ir(GzRiG(ioWOmDkgvmcV(XYzSSyecScgwog5C1AvuJIwlIjS4hzhQ(WjOrnsPMbrnsKqn5ou)eOpUSvCAWJkkcA1MIrCsu9IrG(y0qXhWcnghyuMkpmQyeE9JLZyzXieyfmSCmsUd1pb6JlBfNg8OIIGwTPyeNevVyeWEt7(zXPcghyuMoimQyeE9JLZyzXieyfmSCmYYZeIHL40Gh1pb6JlBPMKuJUj3NAqh1mi0tnjPMChQNHJ8gIpQnvbzqV2NAqh1amQjrutkjJrCsu9Irgw2SUGS40GhCGrz6GJrfJWRFSCgllgHaRGHLJrMLAoxTwb2BA3pl0xyckid61(yeNevVyeYehnOd(4aJYuGHrfJWRFSCgllgHaRGHLJrGSgY)e)yzmItIQxmYZWrEdXh1MIdmkthimQyeE9JLZyzXieyfmSCmIUj3NAaGAi(hciNYl1ai1OBY9vG(mutsQjXuZ5Q1kWEt7(zH(ctq9HtqJAaKAag1irc1OBY9PgaPgNevVkWEt7(zXPcwr6pOMbGrCsu9IrqRSwbPbb9nJrijqSSiCykhpgLP4aJY0blgvmItIQxmc0hJgk(awOXyeE9JLZyzXbgLPahmQyeE9JLZyzXieyfmSCmY5Q1kWEt7(zH(ctqDhPgjsOgDtUp1GoQzWrp1irc1K7q9tG(4YwXPbpQOiOvBkgXjr1lgbS30UFwCQGXbgLPaFmQyeE9JLZyzXieyfmSCmYYZeIHL40Gh1826rzzQjj1K7q9mCK3q8rTPQOiOvBk1irc1S8mHyyjon4rnoHHnyVm1irc1S8mHyyjon4r9tG(4YwQjj1OBY9Pg0rnad9yeNevVyKHLnRlilon4bh4ahyK5m8REXOip0lp0pf9thKAkgzOd3AtFmI87bd5hrzWef5haEqnudQtyQPahByqn6gsnYVYS2V2q(f1azGxVfKZuZ3Gm143Ob9GZudzIVP8ROanWxltndoWdQb4zVZzyWzQbPabEsnFcB4ZqnYpPMOPMb(Rtn5AE9vVutpYqpAi1Kyzga1K4PZmaffikqYVhmKFeLbtuKFa4b1qnOoHPMcCSHb1OBi1i)IyzFol)IAGmWR3cYzQ5BqMA8B0GEWzQHmX3u(vuGg4RLPMPahGhudWZENZWGZudsbc8KA(e2WNHAKFsnrtnd8xNAY186REPMEKHE0qQjXYmaQjXtNzakkquGgmbhByWzQb4qnojQEPgB9XROaHr(rMGrrEadyyKryRllJrK)udYfoVM7wQb4L7gmKcK8NAaEJe9HHuZ0bsoQrEOxEONcefi5p1mWZZzl1aOuQbyOxrbIcKtIQ3xnczsdE8aaPY8xqWEfJCqbYjr17RgHmPbpEaGuzUplQGbLBDqwQlF)eh6Vq3BiATyShYqkqojQEF1iKjn4XdaKkt61H5YxrRfU8XWoMqbYjr17RgHmPbpEaGuziDdZ16bNf()(1guGCsu9(QritAWJhaivMHn0MNZ1kG83RVeMcKtIQ3xnczsdE8aaPY8bZwra9rkqojQEF1iKjn4XdaKkZeho29sbIcKtIQ3haPYaELp5ZYuGCsu9(aivM7ZIkyWNcKtIQ3haPYqCRv4KO6vyRpKBDqwkj)uGCsu9(aivgWEt7(zXPcwUsl1jrnNf8YGf)sNMmCykhQOazr0ICXaQBY9LFMyNevVkWEt7(zXPcwr6paUe)dbKt5DajkLKPa5KO69bqQme3AfojQEf26d5whKL6Jd1LCLwQtIAol4Lbl(bCqjd3YBOitC0Go4R41pwoNmClVHYTJtCXiKZE0qfV(XYzkqojQEFaKkdXTwHtIQxHT(qU1bzPd1LCLwQtIAol4Lbl(bCqjd3YBOitC0Go4R41pwotbYjr17dGuziU1kCsu9kS1hYToil9d5kTuNe1CwWldw8d4GsoB4wEdLBhN4IriN9OHkE9JLZjNnClVHAyzZ6cYIA13V6vXRFSCMcKtIQ3haPYqCRv4KO6vyRpKBDqwQp(HCLwQtIAol4Lbl(bCqjd3YBOC74exmc5ShnuXRFSCo5SHB5nudlBwxqwuR((vVkE9JLZuGCsu9(aivgIBTcNevVcB9HCRdYs9XH6sUsl1jrnNf8YGf)aoOKHB5nuUDCIlgHC2JgQ41pwoNmClVHAyzZ6cYIA13V6vXRFSCMcKtIQ3haPYqCRv4KO6vyRpKBDqw6qDjxPL6KOMZcEzWIFahuYzd3YBOC74exmc5ShnuXRFSCoz4wEd1WYM1fKf1QVF1RIx)y5mfiNevVpasLH4wRWjr1RWwFi36GSuIL95SCLwQtIAol4Lbl(r30KZgUL3qDky(fTwmc5eu86hlNLiXjrnNf8YGf)OtEuGOaj)PgG3lRLHVCudX)GAkn1SDmP2uQHTptn1tn(CVS(XYkkqojQEFaKkdPxcVb0dol0whKPa5KO69bqQmoK4llIgc5nOa5KO69bqQmhpv0AralcApfikqYFQzWWooXPMboGC2JgsbYjr17R8XpKIwzTIFshuGCsu9(kF8daKkdyVPD)S4ublxPLEUATI0nmxRhCw4)7xBOUJjt85Q1ks3WCTEWzH)VFTHcYGETpGtvalrPKSejNRwRo2lu0Ar42EF1Dm55Q1QJ9cfTweUT3xbzqV2hWPkGLOusEauGCsu9(kF8daKkd0hJgk(awOXYvAPNRwRiDdZ16bNf()(1gQ7yYeFUATI0nmxRhCw4)7xBOGmOx7d4ufWsukjlrY5Q1QJ9cfTweUT3xDhtEUAT6yVqrRfHB79vqg0R9bCQcyjkLKhafiNevVVYh)aaPYOT(IwTPIpGfASCLwQUj3haI)HaYP8cOUj3xb6ZqbYjr17R8XpaqQmOvwRG0GG(MLJKaXYIWHPC8sNkxPLQVwRaYKjomLfrbYaovbSeLsYj1n5(aq8peqoLxa1n5(kqFgkqojQEFLp(basL5dMTIa6JYvAP6MCFai(hciNYlG6MCFfOpdfiNevVVYh)aaPYmSSzDbzXPbpYvAP6MCFai(hciNYlG6MCFfOptYzJIGwTPjN9C1Afid2WeeTwyVKklYq2bF1DmzI1xRvazYehMYIOazaNQawIsjzjsMn3HAyzZ6cYItdEurrqR20KZEUATI0nmxRhCw4)7xBOUJsKmBUd1WYM1fKfNg8OIIGwTPjpxTwb2BA3pl0xycQpCcAaoDasKefilIwKlgWPaNKZM7qnSSzDbzXPbpQOiOvBkfiNevVVYh)aaPY8mCK3q8rTPYvAPZM7q9mCK3q8rTPQOiOvBAYzpxTwr6gMR1dol8)9Rnu3rkqojQEFLp(basLbTYAfKge03SCKeiwweomLJx6u5kTuDtUpae)dbKt5fqDtUVc0NjzIpxTwb2BA3pl0xycQpCcAacmjs0n5(a6KO6vb2BA3plovWks)XaOa5KO69v(4haivMNHJ8gIpQnvUslfYAi)t8JLto75Q1ks3WCTEWzH)VFTH6oM8C1AfyVPD)SqFHjO(WjObiWOa5KO69v(4haivgxaEHzgkATGa7HVCLw6SNRwRiDdZ16bNf()(1gQ7ifiNevVVYh)aaPYq6gMR1dol8)9RnKR0sN9C1AfPByUwp4SW)3V2qDhPa5KO69v(4haivgWEt7(zXPcwUsl9C1AfyVPD)SqFHjOUJsKOBY9bG4FiGCkVOt3K7Ra9zaUtrVejNRwRiDdZ16bNf()(1gQ7ifiNevVVYh)aaPYa9XOHIpGfAmfiNevVVYh)aaPYmSSzDbzXPbpYvAPZgfbTAtParbs(tndg2Xjo1mWbKZE0qaOg53LnRlitndMR((vVuGCsu9(kFCOUKIwzTIFshuGCsu9(kFCOUaqQmG9M29ZItfSCLw65Q1QJ9cfTweUT3xDhtEUAT6yVqrRfHB79vqg0R9bmLKPa5KO69v(4qDbGuzG(y0qXhWcnwUsl9C1A1XEHIwlc327RUJjpxTwDSxOO1IWT9(kid61(aMsYuGCsu9(kFCOUaqQmpdh5neFuBQCLw6S5oupdh5neFuBQkkcA1MsbYjr17R8XH6caPY4cWlmZqrRfeyp8Pa5KO69v(4qDbGuzgw2SUGS40Gh5kTu91AfqMmXHPSikqgWPkGLOuswIeDtUpae)dbKt5fqDtUVc0NjzIxEMqmSeNg8OM3wpklNm3H6z4iVH4JAtvrrqR20K5oupdh5neFuBQcYAi)t8JLLiz5zcXWsCAWJACcdBWE5KZEUATcS30UFwOVWeu3XK6MCFai(hciNYlG6MCFfOpdW1jr1RcTYAfKge03SI4FiGCkVjAqdGcKtIQ3x5Jd1fasLH0nmxRhCw4)7xBqbYjr17R8XH6caPYa2BA3plovWYvAPNRwRa7nT7Nf6lmbfKb9A)KlptigwItdEuJtyyd2ltbYjr17R8XH6caPYGwzTcsdc6BwoscellchMYXlDQCLwQ(ATcitM4Wuwefid4ufWsukjNu3K7daX)qa5uEbu3K7Ra9zaUYd9uGCsu9(kFCOUaqQmFWSveqFuUslv3K7daX)qa5uEbu3K7Ra9zOa5KO69v(4qDbGuzG(y0qXhWcnwUsl9C1AvuJIwlIjS4hzhQ(WjOjDqsKK7q9tG(4YwXPbpQOiOvBkfiNevVVYhhQlaKkdyVPD)S4ublxPLM7q9tG(4YwXPbpQOiOvBkfiNevVVYhhQlaKkZWYM1fKfNg8ixPLU8mHyyjon4r9tG(4Y2K6MCF0ni0Nm3H6z4iVH4JAtvqg0R9rhWsukjtbYjr17R8XH6caPYqM4ObDWxUslD2ZvRvG9M29Zc9fMGcYGETpfiNevVVYhhQlaKkZZWrEdXh1MkxPLcznK)j(XYuGCsu9(kFCOUaqQmOvwRG0GG(MLJKaXYIWHPC8sNkxPLQBY9bG4FiGCkVaQBY9vG(mjt85Q1kWEt7(zH(ctq9HtqdqGjrIUj3hqNevVkWEt7(zXPcwr6pgafiNevVVYhhQlaKkd0hJgk(awOXuGCsu9(kFCOUaqQmG9M29ZItfSCLw65Q1kWEt7(zH(ctqDhLir3K7JUbh9sKK7q9tG(4YwXPbpQOiOvBkfiNevVVYhhQlaKkZWYM1fKfNg8ixPLU8mHyyjon4rnVTEuwozUd1ZWrEdXh1MQIIGwTPsKS8mHyyjon4rnoHHnyVSejlptigwItdEu)eOpUSnPUj3hDad9uGOa5KO69vK8l9y7ol0xycYvAPKUT5E4QiDdZ16bNf()(1gkid61(OBqONcKtIQ3xrYpasLXxc)b0TcIBTYvAPKUT5E4QiDdZ16bNf()(1gkid61(OBqONcKtIQ3xrYpasLrxq(y7olxPLs62M7HRI0nmxRhCw4)7xBOGmOx7JUbHEkqojQEFfj)aivgBLojEXa7Mtb5nOa5KO69vK8dGuzom8ziA1MkxPLs62M7HRI0nmxRhCw4)7xBOGmOx7JUbc9sKefilIwKlgWPdIcKtIQ3xrYpasLzSJQx5kT0ZvRvPxhMlFfTw4Yhd7yI6oMmXNRwRom8ziA1MQUJsKCUAT6y7ol0xycQ7OejZcDcRcyBTdqIKet69VG(XYQXoQEfTwC3dSYwol0xycj1v6KqazqV2hWbAQej6kDsiGmOx7dO8gObirYS8)8syfP3mVpNf2sZ6gsyfOpWAyYZvRvKUH5A9GZc)F)Ad1DKcKtIQ3xrYpasLX)rMeIwlIjSG9ullxPLgomLdvU(WxcJoPdefiNevVVIKFaKkZ9zrfmOCRdYs9FYCF5xaD5RHcsdDRCLw65Q1kqgSHjiATWEjvwKHSd(Q7ysDLojeqg0R9bK0Tn3dxfid2WeeTwyVKklYq2bFfKb9AFaMcmjsoxTwLEDyU8v0AHlFmSJjQpCcAsbwsDLojeqg0R9bK0Tn3dxv61H5YxrRfU8XWoMOGmOx7dG8qVejz(C1Af0LVgkin0TImFUATk3dxjs0v6KqazqV2hq5nvIKZvRvdBOnpNRva5VxFjScYGETFsDLojeqg0R9bK0Tn3dx1WgAZZ5Afq(71xcRGmOx7dWuGJejZgUL3qDky(fTwmc5eu86hlNtQR0jHaYGETpGKUT5E4QiDdZ16bNf()(1gkid61(aip0N8C1AfPByUwp4SW)3V2qbzqV2NcKtIQ3xrYpasL5(SOcguU1bzPPULjU1YWxC6ELR0sjDBZ9WvbYGnmbrRf2lPYImKDWxbzqV2xIKWT8gQHLnRlilQvF)QxfV(XY5KKUT5E4QiDdZ16bNf()(1gkid61(sKml)pVewbYGnmbrRf2lPYImKDWxb6dSgMK0Tn3dxfPByUwp4SW)3V2qbzqV2NcKtIQ3xrYpasL5(SOcguU1bzPU89tCO)cDVHO1IXEidParbs(tndC)Nxc)uGCsu9(ks(bqQm6MCFolC5JHvWId7GYvAPqVYcEoVHYZ5xvl6a(OpPUj3hqDtUVc0Nb4kpGjrsIDsuZzbVmyXp6MMC2WT8gQtbZVO1IriNGIx)y5SejojQ5SGxgS4hDYBajt85Q1QJ9cfTweUT3xDhtEUAT6yVqrRfHB79vqg0R9r3GsukjlrYSNRwRo2lu0Ar42EF1DCauGCsu9(ks(bqQmhB3zrRfXewWldMGCLwAItm0RSGNZBO8C(vqg0R9rhWh9sKml0RSGNZBO8C(v8m1h)aKijXojQ5SGxgS4hDttoB4wEd1PG5x0AXiKtqXRFSCwIeNe1CwWldw8Jo5nGbKu3K7dOUj3xb6ZqbYjr17Ri5haPYmEHLoHAtfhR)HCLwAItm0RSGNZBO8C(vqg0R9r3aHEjsMf6vwWZ5nuEo)kEM6JFasKKyNe1CwWldw8JUPjNnClVH6uW8lATyeYjO41pwolrItIAol4Lbl(rN8gWasQBY9bu3K7Ra9zOa5KO69vK8dGuzsVomx(kATWLpg2XekqojQEFfj)aivgynoAzrTIF0jmfiNevVVIKFaKkdPxcVb0dol0whKLR0s1xRvazYehMYIOazaNMOusMcKtIQ3xrYpasLjMWI7E67Mf6gsy5kT0ZvRvqMGML)xOBiHv3rkqojQEFfj)aivMHn0MNZ1kG83RVeMcKtIQ3xrYpasLbY(yTPcT1b5xUslnCykhQjSBJjQrsGoGd6LijCykhQjSBJjQrsaOu5HEjschMYHkkqweTyKec5HE0ni0tbs(tn2lPYuZaN(aRHudW7n5(5l4i1moXFMcKtIQ3xrYpasL5z4iVH4JAtLR0s5)5LWkqgSHjiATWEjvwKHSd(kqFG1WKqwd5FIFSCYZvRvZRrg(I582GQ7yYzjDBZ9WvbYGnmbrRf2lPYImKDWxbzqV2NcKtIQ3xrYpasLbS30UFwCQGLR0s5)5LWkqgSHjiATWEjvwKHSd(kqFG1WKZs62M7HRcKbBycIwlSxsLfzi7GVcYGETpfiNevVVIKFaKkZWYM1fKfNg8ixPLY)ZlHvGmydtq0AH9sQSidzh8vG(aRHj1xRvazYehMYIOazaNQawIsj5K6MCFaDsu9Qa7nT7NfNkyfP)i5SKUT5E4QazWgMGO1c7LuzrgYo4RGmOx7tbYjr17Ri5haPYaYGnmbrRf2lPYImKDWxUslv3K7dOtIQxfyVPD)S4ubRi9hjpxTwr6gMR1dol8)9Rnu3rkquGOa5KO69vel7ZzPZDy5hll36GSuIdNZcsgkxpk95O0Yn3TxwQtIAol4Lbl(LBUBVSGTplfyYr6nxr1RuNe1CwWldw8diWOa5KO69vel7ZzaKkdyVPD)S4ublxPL6YhdRGvh7fkATiCBVVc6lAOd9jt85Q1ks3WCTEWzH)VFTH6oMmXNRwRiDdZ16bNf()(1gkid61(aovbSeLsYsKCUAT6yVqrRfHB79v3XKNRwRo2lu0Ar42EFfKb9AFaNQawIsjzjsoxTwr6gMR1dol8)9Rnuqg0R9to75Q1QJ9cfTweUT3xbzqV2FadGcKtIQ3xrSSpNbqQmG9M29ZItfSCKeiwweomLJx6u5kT0mFUATY6bVHySRVx1hobn0LyNe1CwWldw8lrcWFaj1v6KqazqV2hqNe1CwWldw8NOusMcKtIQ3xrSSpNbqQmUa8cZmu0Abb2dFkqojQEFfXY(CgaPYq6gMR1dol8)9RnOa5KO69vel7ZzaKkdXHZz5kT0ChQFc0hx2kon4rffbTAttoB4wEd1KeYq)fNkyfV(XYzjsYDO(jqFCzR40Ghvue0QnnPtIAol4Lbl(rhWOa5KO69vel7ZzaKkZWYM1fKfNg8ixPLoB4wEdv6LHWYADr4KOiVIx)y5Sej6R1kGmzIdtzruGmGPKSejqVYcEoVHYZ5xbzqV2hWbkj0RSGNZBO8C(v8m1hpfiNevVVIyzFodGuzo3GmHHjixPLsM4Wu(fAOtIQx3Io5PaMej5ou)eOpUSvCAWJkkcA1MkrcPBBUhUQHLnRlilon4rbzqV2hDojQ5SGxgS4h4MsYsKK5ZvRvhB3zrRfXewWldMGcYGETVejqVYcEoVHYZ5xbzqV2hqGLe6vwWZ5nuEo)kEM6JNcKtIQ3xrSSpNbqQmG9M29ZItfSCKeiwweomLJx6u5kT0mFUATY6bVHySRVx1hobn0bCOa5KO69vel7ZzaKkdzIJg0bFkqojQEFfXY(CgaPYGwzTcsdc6BwoscellchMYXlDQCLwQUj3haI)HaYP8cOUj3xb6ZqbYjr17Riw2NZaivMjoCS7vUslnClVHkyi4lATG3upLb5nu86hlNPa5KO69vel7ZzaKkdXHZz5kT0WT8gQ0ldHL16IWjrrEfV(XYzkqojQEFfXY(CgaPYCUbzcdtqUslL0Tn3dx1WYM1fKfNg8OGmOx7JUe7KOMZcEzWIFjsa2aOa5KO69vel7ZzaKkJ26lA1Mk(awOXYvAP6MCFai(hciNYlG6MCFfOpdfiNevVVIyzFodGuzgw2SUGS40Gh5kT0ChQHLnRlilon4rbznK)j(XYsKeUL3qnSSzDbzrT67x9Q41pwotbYjr17Riw2NZaivMNHJ8gIpQnvoscellchMYXlDQCLw65Q1Q51idFXCEBqfKDsqbYjr17Riw2NZaivgIdNZYvAPKUT5E4Qgw2SUGS40GhfKb9AF0n3HLFSSI4W5SGKHYpLhfiNevVVIyzFodGuz(GzRiG(ifiNevVVIyzFodGuzEgoYBi(O2u5ijqSSiCykhV0PYvAPqwd5FIFSCYZvRvrnkATiMWIFKDO6dNGgGdk5YZeIHL40Gh1826rzzjsGSgY)e)y5KU8XWkyL1dEdXyxFVkOVOHo0tbs(tnO2uZxGxRhm1CFpLPgDdPgWEt7(zXPcMAAi1a9XOHIpGfAm1KVWAtPMbJFKjb10AQjMWuZaxp1YYrnKEmbQHDYeQPjKleYlHPMwtnXeMACsu9sn(MPgFCK3m1iyp1Yut0utmHPgNevVuZ6GSIcKtIQ3xrSSpNbqQmG9M29ZItfSCKeiwweomLJx6ukqojQEFfXY(CgaPYa9XOHIpGfASCKeiwweomLJx6ukquGCsu9(QpKIwzTIFshuGCsu9(QpaqQmtC4y3RCLwA4wEdvWqWx0AbVPEkdYBO41pwotbYjr17R(aaPYOT(IwTPIpGfASCLwQUj3haI)HaYP8cOUj3xb6ZqbYjr17R(aaPYa9XOHIpGfASCLw65Q1ks3WCTEWzH)VFTH6oMmXNRwRiDdZ16bNf()(1gkid61(aovbSeLsYsKCUAT6yVqrRfHB79v3XKNRwRo2lu0Ar42EFfKb9AFaNQawIsj5bqbs(tnO2uZxGxRhm1CFpLPgDdPgWEt7(zXPcMAAi1a9XOHIpGfAm1KVWAtPMbJFKjb10AQjMWuZaxp1YYrnKEmbQHDYeQPjKleYlHPMwtnXeMACsu9sn(MPgFCK3m1iyp1Yut0utmHPgNevVuZ6GSIcKtIQ3x9basLbS30UFwCQGLR0spxTwr6gMR1dol8)9Rnu3XKj(C1AfPByUwp4SW)3V2qbzqV2hWPkGLOuswIKZvRvh7fkATiCBVV6oM8C1A1XEHIwlc327RGmOx7d4ufWsukjpakqojQEF1haivg0kRvqAqqFZYrsGyzr4WuoEPtLR0s1n5(aq8peqoLxa1n5(kqFgkqojQEF1haivMNHJ8gIpQnvUsl9C1A18AKHVyoVnO6oM8C1A18AKHVyoVnOcYGETpGttukjtbYjr17R(aaPY8bZwra9r5kTuDtUpae)dbKt5fqDtUVc0NHcKtIQ3x9basLzyzZ6cYItdEKR0s1n5(aq8peqoLxa1n5(kqFMKqwd5FIFSCs91AfqMmXHPSikqgWuso5SNRwRazWgMGO1c7LuzrgYo4RUJsKOBY9bG4FiGCkVaQBY9vG(mjt8S5oudlBwxqwCAWJkkcA1MMmXZEUATI0nmxRhCw4)7xBOUJsKCUATcS30UFwOVWeuF4e0aCQejrbYIOf5IbCkWrIKzZDOgw2SUGS40Ghvue0QnnPlFmScwnSSzgU8)I)cNxZDRc6lAOd9dyajN9C1Afid2WeeTwyVKklYq2bF1DKcKtIQ3x9basL5z4iVH4JAtLR0spxTwnVgz4lMZBdQUJjZDOEgoYBi(O2ufKb9AFah8eLsYsKK7q9mCK3q8rTPkiRH8pXpwo5SNRwRiDdZ16bNf()(1gQ7ifiNevVV6daKkJlaVWmdfTwqG9WxUslD2ZvRvKUH5A9GZc)F)Ad1DKcKtIQ3x9basLH0nmxRhCw4)7xBixPLo75Q1ks3WCTEWzH)VFTH6osbYjr17R(aaPYa2BA3plovWYvAPNRwRa7nT7Nf6lmb1DuIeDtUpae)dbKt5fD6MCFfOpdWvEOpz4wEd18AKHVyoVnOIx)y5Sej6MCFai(hciNYl60n5(kqFgG70KHB5nubdbFrRf8M6PmiVHIx)y5SejNRwRiDdZ16bNf()(1gQ7ifiNevVV6daKkd0hJgk(awOXuGCsu9(QpaqQmdlBwxqwCAWJCLwAUd1WYM1fKfNg8OGSgY)e)yzkqojQEF1haivMNHJ8gIpQnvUsl9C1A18AKHVyoVnO6osbIcK8NAKFx2SUGm1myU67x9sbYjr17RgQlPOvwR4N0bfiNevVVAOUaqQmtC4y3RCLwQUj3haI)HaYP8cOUj3xb6ZKmClVHkyi4lATG3upLb5nu86hlNPa5KO69vd1fasLbS30UFwCQGLR0spxTwDSxOO1IWT9(Q7yYZvRvh7fkATiCBVVcYGETpGPKmfiNevVVAOUaqQmqFmAO4dyHglxPLEUAT6yVqrRfHB79v3XKNRwRo2lu0Ar42EFfKb9AFatjzkqojQEF1qDbGuzEgoYBi(O2u5kT0ZvRvZRrg(I582GQ7yYZvRvZRrg(I582Gkid61(aovbSeLsYsKmBUd1ZWrEdXh1MQIIGwTPuGCsu9(QH6caPYmSSzDbzXPbpYvAP6R1kGmzIdtzruGmGtvalrPKCsDtUpae)dbKt5fqDtUVc0NrIKeV8mHyyjon4rnVTEuwozUd1ZWrEdXh1MQIIGwTPjZDOEgoYBi(O2ufK1q(N4hllrYYZeIHL40Gh14eg2G9YjN9C1AfyVPD)SqFHjOUJj1n5(aq8peqoLxa1n5(kqFgGRtIQxfAL1kiniOVzfX)qa5uEt0GgafiNevVVAOUaqQmOvwRG0GG(MLJKaXYIWHPC8sNkxPLQBY9bG4FiGCkVaQBY9vG(maxDtUVcYP8sbYjr17RgQlaKkJlaVWmdfTwqG9WNcKtIQ3xnuxaivMpy2kcOpkxPLQBY9bG4FiGCkVaQBY9vG(muGCsu9(QH6caPYmSSzDbzXPbpYvAP6R1kGmzIdtzruGmGtvalrPKmfiNevVVAOUaqQmKUH5A9GZc)F)AdkqojQEF1qDbGuzEgoYBi(O2u5kT0ZvRvZRrg(I582GQ7yYChQNHJ8gIpQnvbzqV2hWbprPKmfiNevVVAOUaqQmG9M29ZItfSCLwAUd1pb6JlBfNg8OIIGwTPsKCUATcS30UFwOVWeuF4e0KcmkqojQEF1qDbGuzgw2SUGS40Gh5kT0LNjedlXPbpQFc0hx2Mm3H6z4iVH4JAtvqg0R9rhWsukjtbYjr17RgQlaKkZZWrEdXh1MkxPLcznK)j(XYuGCsu9(QH6caPYqM4ObDWxUslD2ZvRvG9M29Zc9fMGcYGETpfiNevVVAOUaqQmG9M29ZItfmfiNevVVAOUaqQmqFmAO4dyHgtbYjr17RgQlaKkZZWrEdXh1MkxPLEUATAEnYWxmN3guDhPa5KO69vd1fasLzyzZ6cYItdEKR0sxEMqmSeNg8OM3wpklNm3H6z4iVH4JAtvrrqR2ujswEMqmSeNg8OgNWWgSxwIKLNjedlXPbpQFc0hx2IdCGXa]] )
    end

end