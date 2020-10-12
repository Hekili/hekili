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
                    max_stack = 10,
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
            
            usable = function () return debuff.dispellable_enrage.up or debuff.dispellable_magic.up, "requires dispellable_enrage or dispellable_magic" end,
            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
                removeDebuff( "target", "dispellable_magic" )
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
        spec:RegisterPack( "Survival", 202010.9, [[de0(3aqiPk9iHkQlraXMuvAuOi6uOiSkHkXRiOzrG2LGFPQQHHI0Xecldf1ZeImnHkCnHO2gbuFtQImoPkkNtOsToHksnpvvUhkzFeGfIc9qHksgPqfHtkvrLvkv1mLQOQDkv6Ncve9uPmvvf7vL)sXGvLdtAXq5XqMSixgzZI6ZeA0cPtlz1eq61cLzt0TrLDR0VvmCu1XLQWYbEoOPt11HQTJs13rbJxOQZJsz9cvsZxQy)u6lI7Z1sQtxxMzkZmncMY0EkWCemnoIJ4(AoB8014vumvKU2QC01A4a2l2v514v2KJMUpxdo4aeDTOUZdJt))Vy5rXXcOH7pS4WLQxZIaA2)dlo0)RHHxsVNBpSRLuNUUmZuMzAemLP9uG5iyACehrCnf3JoGR1koCP61SXPaA2Vw0kLO9WUwIGORfNTVgoG9IDvAFXjWxNa2(Xz7lojYhmcyF9KG2hZmLzMA7B7hNTVEEIDsAFcW(ImtdxtwqhEFUwIYkU0Vpx3iUpxtrEn714WJRXvjDnAvmjLogp)6Y895AkYRzVgoKmLtCWRrRIjP0X45x3iDFUgTkMKshJxtrEn71qQuAuKxZAKf0VMSGUzvo6AOe88RBCCFUgTkMKshJxdbkNaLEnf5f7KHwIRiO99Z(y(AkYRzVgsLsJI8AwJSG(1Kf0nRYrxd6NFDJ895A0QyskDmEneOCcu61uKxStgAjUIG2NaSViUMI8A2RHuP0OiVM1ilOFnzbDZQC01qsszNo)6kW3NRPiVM9AkaPlz8baO1VgTkMKshJNFD7P7Z1uKxZEnmv0mzJdkum41OvXKu6y88ZVgssk70956gX95A0QyskDmEneOCcu61CvsRhCcWbnt2qROksC06bAvmjLSVV2xEq4q77N9LheomWPXFnf51SxlQc4Nzp)6Y895AkYRzVgdLmzG8fOC41OvXKu6y88RBKUpxJwftsPJXRHaLtGsVgaFP8aePaCWL5bisgIdJaWa1d8INNs23x7ZvGXbkFaqCATq77N9jIs23x7dnJmnmSHSubuaqCATq77N9jIsxtrEn71CfyCGYF(1noUpxJwftsPJXRHaLtGsVgaFP8aePaCWL5bisgIdJaWa1d8INNs23x7ZvGXbkFaN)AkYRzVwwQa68RBKVpxtrEn71aeCw1Rv0OaWWW1OvXKu6y88RRaFFUgTkMKshJxdbkNaLETmUuAaekQcejJxCK99Z(erPRPiVM9AmuYuUaKbB4Wo)62t3NRPiVM9AOOAmGYbVgTkMKshJNFD7z3NRrRIjP0X41qGYjqPxlnEagfO8ljnydhwWluSAfTVV2htAFPXd16eyvPbtsuQwXa0vum77N9XS91PJ9LgpaJcu(LKgSHdlaioTwO99Z(erj7JjUMI8A2RHH7OOeGTZVUX995A0QyskDmEneOCcu61sJhGrbk)ssd2WHf8cfRwXRPiVM9AifWoD(1ncMEFUgTkMKshJxdbkNaLET8GWH2Nq7dPq3airATVF2xEq4WaNg)1uKxZETePEudkQgdOCNFDJiI7Z1uKxZEn0mGuTQtjJcHkU0VgTkMKshJNFDJG57Z1OvXKu6y8Aiq5eO0RHIQarcAYaf51SQ0(eG9XCiY23x7dnJmnmSbgkzkxaYGnCyHmUuAaekQcejJxCK9ja7dYtsPXvGi5q7tGyFmFnf51Sxdd3rrjaBNFDJis3NRrRIjP0X41qGYjqPxlpiCO9j0(qk0nasKw77N9LheomWPXFnf51Sxll1nwTIgOdQy05x3iIJ7Z1OvXKu6y8AkYRzVwSsknOHJt301qGYjqPxlpiCO9j0(qk0nasKw77N9LheomWPXBFFTVmUuAaekQcejJxCK99Z(erPRHydjjJRarYHx3io)6grKVpxJwftsPJXRHaLtGsVwV2xA8adLmLlazWgoSGxOy1kEnf51SxJHsMYfGmydh25x3ie47Z1OvXKu6y8Aiq5eO0RXK2xV23sX7ggkd2WHfGrbk)ss7Rth7Rx7ZvjTEGHsMYfGm1MXH1SbAvmjLSpMW((AFOzKPHHnWqjt5cqgSHdlKXLsdGqrvGiz8IJSpbyFqEsknUcejhAFce7J5RPiVM9Ay4okkby78RBe9095A0QyskDmEneOCcu61qZitddBGHsMYfGmydhwiJlLgaHIQarY4fhzFcW(G8KuACfiso0(ei2hZxtrEn71qkGD68RBe9S7Z1uKxZETyLuAGrh)A0QyskDmE(1nI4((Cnf51Sxllv2OKbgD8RrRIjP0X45xxMz695AkYRzVMA4WbjcyMSbbggGxJwftsPJXZVUmhX95A0QyskDmEneOCcu6161(a4lLhGifwccRvKbfWg04aLNVwrJYZRa1XHbQh4fppLSVoDSV8GWH2Nq7dPq3airATpH2hZr2((zF5bHddCA8xtrEn71GorsJdu(ZVUmZ895A0QyskDmEnf51SxdsaEADd0Rv8Aiq5eO0RbOmGGrvmjzFFTpxL06HOSLak0GvofOvXKu6Ai2qsY4kqKC41nIZVUmhP7Z1uKxZEnKcyNUgTkMKshJNFDzooUpxJwftsPJXRPiVM9AXkP0GgooDtxdbkNaLET8GWH2Nq7dPq3airATVF2xEq4WaNg)1qSHKKXvGi5WRBeNFDzoY3NRrRIjP0X41uKxZEnib4P1nqVwXRHaLtGsVgGYacgvXKK991(ys7Rx7ZvjTEaRajOzYgEaXwGwftsj7Rth7Rx7ddpNdOzaPAvNsgfcvCPhW5TpMW((AFmP91R9bWxkparkaytQXGUkJraObnBEW3uTIgOdQyemq9aV45PK91PJ9Tu8UHHYGnCyb2hP6LKSVoDSpxL06bmChfLaSfOvXKuY(yc7Rth7ddpNdSx8eaAyN2HlGZFneBijzCfiso86gX5xxMf47Z1OvXKu6y8AkYRzVg3SIZajdw501qGYjqPxlry45CqQoTUHFk4SMAfOeYRzdqxrXSpbyFX91qSHKKXvGi5WRBeNFDzUNUpxJwftsPJXRPiVM9AaL3hGb6GkgDneOCcu61segEohKQtRB4NcoRPwbkH8A2a0vum7ta2xCFneBijzCfiso86gX5xxM7z3NRrRIjP0X41uKxZEnib4P1nqVwXRHaLtGsVwV2NRsA9awbsqZKn8aITaTkMKs23x7Rx7ZvjTEG9INaqd70oCbAvmjLSVV2xV2haFP8aePGuDADd)uWzn1kqjKpayG6bEXZtj77R91R9bWxkparkaytQXGUkJraObnBEW3uTIgOdQyemq9aV45P01qSHKKXvGi5WRBeNFDzoUVpxJwftsPJXRPiVM9ACZkodKmyLtxdXgssgxbIKdVUrC(1nsm9(CnAvmjLogVMI8A2RbuEFagOdQy01qSHKKXvGi5WRBeNF(1qj4956gX95A0QyskDmEneOCcu61qZitddBandivR6uYOqOIl9aG40AH2NaSViX0RPiVM9AyYzsMmoGTZVUmFFUgTkMKshJxdbkNaLEn0mY0WWgqZas1QoLmkeQ4spaioTwO9ja7lsm9AkYRzVMUic6avAqQuE(1ns3NRrRIjP0X41qGYjqPxdnJmnmSb0mGuTQtjJcHkU0daItRfAFcW(IetVMI8A2RLlaHjNjD(1noUpxtrEn71KLyuhAeO4jroA9RrRIjP0X45x3iFFUgTkMKshJxdbkNaLEn0mY0WWgqZas1QoLmkeQ4spaioTwO9ja7tGzQ91PJ95fhz8XKkY((zFrePRPiVM9AyeasGy1kE(1vGVpxJwftsPJXRHaLtGsVwUeJ6gaXP1cTVF2hZcS91PJ9HHNZb0mGuTQtjJcHkU0d48xtrEn714hVM98RBpDFUgTkMKshJxdbkNaLEnxbIKhsf01fr2NayzFc81uKxZEnfYti3mzJhLmKkkPZp)Aq)(CDJ4(CnAvmjLogVgcuobk9AUkP1dob4GMjBOvufjoA9aTkMKs23x7lpiCO99Z(Ydchg404VMI8A2Rfvb8ZSNFDz((CnAvmjLogVgcuobk9A5bHdTpH2hsHUbqI0AF)SV8GWHbonE77R9HHNZbV4nt24rjdKNuqa6kkM99Z(IK991(61(CvsRhujFu1WdOK6diqRIjP01uKxZETyLuAqdhNUPZVUr6(CnAvmjLogVgcuobk9APXdWOaLFjPbB4WcEHIvRO991(ys7lnEOwNaRknysIs1kgGUIIzF)SpMTVoDSV04byuGYVK0GnCybaXP1cTVF2NikzFmH91PJ9HHNZbUzfNbsMmoGTaoV991(WWZ5a3SIZajtghWwaqCATq77N9Lheo0(ei2xKyQ9fxSpruY(60X(CvsRhWkqcAMSHhqSfOvXKuY((AFy45CandivR6uYOqOIl9aoV991(WWZ5aAgqQw1PKrHqfx6baXP1cTVF2NikDnf51SxJBwXzGKbRC68RBCCFUgTkMKshJxdbkNaLET04byuGYVK0GnCybVqXQv0((AFmP9LgpuRtGvLgmjrPAfdqxrXSVF2hZ2xNo2xA8amkq5xsAWgoSaG40AH23p7teLSpMW(60X(CvsRhWkqcAMSHhqSfOvXKuY((AFy45CandivR6uYOqOIl9aoV991(WWZ5aAgqQw1PKrHqfx6baXP1cTVF2NikDnf51SxdO8(amqhuXOZVUr((Cnf51SxJHsMmq(cuo8A0QyskDmE(1vGVpxJwftsPJXRHaLtGsVgaFP8aePaCWL5bisgIdJaWa1d8INNs23x7ZvGXbkFaqCATq77N9jIs23x7dnJmnmSHSubuaqCATq77N9jIsxtrEn71CfyCGYF(1TNUpxJwftsPJXRHaLtGsVgaFP8aePaCWL5bisgIdJaWa1d8INNs23x7ZvGXbkFaN)AkYRzVwwQa68RBp7(Cnf51SxdndivR6uYOqOIl9RrRIjP0X45x34((Cnf51SxdqWzvVwrJcaddxJwftsPJXZVUrW07Z1uKxZETSuzJsgy0XVgTkMKshJNFDJiI7Z1OvXKu6y8Aiq5eO0RLheo0(eAFif6gajsR99Z(Ydchg404VMI8A2RLi1JAqr1yaL78RBemFFUMI8A2RfRKsdm64xJwftsPJXZVUreP7Z1OvXKu6y8Aiq5eO0RLheo0(eAFif6gajsR99Z(Ydchg404VMI8A2RLL6gRwrd0bvm68RBeXX95A0QyskDmEneOCcu61YdchAFcTpKcDdGeP1((zF5bHddCA823x7ddpNdEXBMSXJsgipPGa0vum77N9fj77R9LXLsdGqrvGiz8IJSVF2hZ2xCX(erPRPiVM9AXkP0GgooDtNFDJiY3NRPiVM9AOOAmGYbVgTkMKshJNFDJqGVpxtrEn71udhoiraZKniWWa8A0QyskDmE(1nIE6(CnAvmjLogVgcuobk9AlfVByOmydhwG9rQEjj77R9LgpajapTUb61kg8cfRwr77R9LgpajapTUb61kgaugqWOkMKUMI8A2RXqjt5cqgSHd78RBe9S7Z1OvXKu6y8Aiq5eO0RbOmGGrvmjzFFTpM0(WWZ5a3SIZajtghWwa6kkM99Z(IS91PJ91R95QKwpWnR4mqYGvofOvXKuY(yc77R9XK2xV2hgEohqZas1QoLmkeQ4spGZBFD6yF9AFUkP1dyfibnt2Wdi2c0QyskzFmH91PJ9HHNZb2lEcanSt7WfW5VMI8A2RbjapTUb61kE(1nI4((CnAvmjLogVgcuobk9AlfVByOmydhwagfO8ljTVV2xEq4q7ta2NaZu7Rth7BP4DddLbB4Wc8rjWWnlzFFTpM0(YdchAFcTpKcDdGeP1(eAFkYRzdXkP0GgooDtbKcDdGeP1(Il2xKSVF2xEq4WaNgV91PJ95QKwpWnR4mqYGvofOvXKuY((AF9AFy45CGBwXzGKjJdylGZBFmH91PJ91R9LgpWqjt5cqgSHdl4fkwTI23x7lJlLgaHIQarY4fhzF)Spru6AkYRzVgdLmLlazWgoSZVUmZ07Z1OvXKu6y8Aiq5eO0RLheo0(eAFif6gajsR99Z(Ydchg404TVV2hgEoh8I3mzJhLmqEsbbOROy23p7lsxtrEn71IvsPbnCC6Mo)6YCe3NRrRIjP0X41qGYjqPxRx7dGVuEaIuyjiSwrguaBqJduE(AfnkpVcuhhgOEGx88uY(60X(YdchAFcTpKcDdGeP1(eAFmhz77N9LheomWPXFnf51Sxd6ejnoq5p)6YmZ3NRrRIjP0X41qGYjqPxdGVuEaIuyjiSwrguaBqJduE(AfnkpVcuhhgOEGx88uY((AF5bHdTpH2hsHUbqI0AFcTpMJS99Z(Ydchg404VMI8A2R5kW4aL)8RlZr6(CnAvmjLogVgcuobk9Aa8LYdqKclbH1kYGcydACGYZxROr55vG64Wa1d8INNs23x7lpiCO9j0(qk0nasKw7tO9XCKTVF2xEq4WaNg)1uKxZETmGO4ATIghO8NFDzooUpxJwftsPJXRHaLtGsVggEoh4MvCgizY4a2c482xNo2xEq4q7tO9PiVMneRKsdA440nfqk0nasKw7ta2xEq4WaNg)1uKxZEnUzfNbsgSYPZVUmh57Z1OvXKu6y8Aiq5eO0R1R9Tu8UHHYGnCybyuGYVK0(60X(WWZ5Gx8MjB8OKbYtkiaDffZ(eG9XS91PJ9Lheo0(eAFkYRzdXkP0GgooDtbKcDdGeP1(eG9LheomWPXFnf51SxdO8(amqhuXOZVUmlW3NRrRIjP0X41qGYjqPxddpNdEXBMSXJsgipPGa0vum77N9fPRPiVM9AXkP0GgooDtNFDzUNUpxJwftsPJXRHaLtGsVwV2xA8adLmLlazWgoSGxOy1kAFFTVETpxL06bgkzkxaYuBghwZgOvXKu6AkYRzVgdLmLlazWgoSZp)A8acnCyQFFUUrCFUgTkMKshJxdbkNaLEna(s5bisb4GlZdqKmehgbGbQh4fppLUMI8A2R5kW4aL)8RlZ3NRPiVM9AqNiPXbk)1OvXKu6y88RBKUpxtrEn71qZas1QoLmkeQ4s)A0QyskDmE(1noUpxJwftsPJXRPiVM9A8JxZETeBRYvidpG4h)ArC(5NFn2jaSM96YmtzMPmnUzoYH4(AmOGTwr416544hGtj7lY2NI8Aw7twqhgS9VgKNqxxMJCKVgpyYLKUwC2(A4a2l2vP9fNaFDcy7hNTV4KiFWiG91tcAFmZuMzQTVTFC2(65j2jP9ja7lYmny7B7RiVMfg4beA4WuxiR)Ucmoq5fSYSa4lLhGifGdUmparYqCyeagOEGx88uY2xrEnlmWdi0WHPUqw)HorsJduEBFf51SWapGqdhM6cz9hndivR6uYOqOIlDBFf51SWapGqdhM6cz9NF8AwbtSTkxHm8aIFCwry7B7RiVMfgqjOqw)XKZKmzCaBcwzwOzKPHHnGMbKQvDkzuiuXLEaqCATqbejMA7RiVMfgqjOqw)1frqhOsdsLsbRml0mY0WWgqZas1QoLmkeQ4spaioTwOaIetT9vKxZcdOeuiR)5cqyYzscwzwOzKPHHnGMbKQvDkzuiuXLEaqCATqbejMA7RiVMfgqjOqw)LLyuhAeO4jroADBFf51SWakbfY6pgbGeiwTIcwzwOzKPHHnGMbKQvDkzuiuXLEaqCATqbiWmTthV4iJpMur)Iis2(kYRzHbuckK1F(XRzfSYSYLyu3aioTw4pMf4oDWWZ5aAgqQw1PKrHqfx6bCEBFf51SWakbfY6Vc5jKBMSXJsgsfLKGvMLRarYdPc66IibWsGT9T9vKxZcfY6phECnUkjBFf51SqHS(Jdjt5eh02xrEnluiR)ivknkYRznYc6cUkhXcLG2(kYRzHcz9hPsPrrEnRrwqxWv5iwqxWkZsrEXozOL4kc(JzBFf51SqHS(JuP0OiVM1ilOl4QCelKKu2jbRmlf5f7KHwIRiOaIW2xrEnluiR)kaPlz8baO1T9vKxZcfY6pMkAMSXbfkg0232xrEnlmaDHS(hvb8ZScwzwUkP1dob4GMjBOvufjoA9aTkMKsFZdch(lpiCyGtJ32xrEnlmaDHS(hRKsdA440njyLzLheouisHUbqI0(lpiCyGtJ)lgEoh8I3mzJhLmqEsbbOROy)I03EDvsRhujFu1WdOK6diqRIjPKTVI8Awya6cz9NBwXzGKbRCsWkZknEagfO8ljnydhwWluSAf)YKPXd16eyvPbtsuQwXa0vuSFm3PtA8amkq5xsAWgoSaG40AH)erjMOthm8CoWnR4mqYKXbSfW5)IHNZbUzfNbsMmoGTaG40AH)YdchkqIetJlIOuNoUkP1dyfibnt2Wdi2c0Qysk9fdpNdOzaPAvNsgfcvCPhW5)IHNZb0mGuTQtjJcHkU0daItRf(teLS9vKxZcdqxiR)aL3hGb6GkgjyLzLgpaJcu(LKgSHdl4fkwTIFzY04HADcSQ0GjjkvRya6kk2pM70jnEagfO8ljnydhwaqCATWFIOet0PJRsA9awbsqZKn8aITaTkMKsFXWZ5aAgqQw1PKrHqfx6bC(Vy45CandivR6uYOqOIl9aG40AH)erjBFf51SWa0fY6pdLmzG8fOCOTVI8Awya6cz93vGXbkVGvMfaFP8aePaCWL5bisgIdJaWa1d8INNsFDfyCGYhaeNwl8Nik9fnJmnmSHSubuaqCATWFIOKTVI8Awya6cz9plvajyLzbWxkparkahCzEaIKH4Wiamq9aV45P0xxbghO8bCEBFf51SWa0fY6pAgqQw1PKrHqfx62(kYRzHbOlK1FabNv9Afnkammy7RiVMfgGUqw)ZsLnkzGrh32xrEnlmaDHS(Ni1JAqr1yaLtWkZkpiCOqKcDdGeP9xEq4WaNgVTVI8Awya6cz9pwjLgy0XT9vKxZcdqxiR)zPUXQv0aDqfJeSYSYdchkePq3airA)LheomWPXB7RiVMfgGUqw)JvsPbnCC6MeSYSYdchkePq3airA)LheomWPX)fdpNdEXBMSXJsgipPGa0vuSFr6BgxknacfvbIKXlo6hZXfruY2xrEnlmaDHS(JIQXakh02xrEnlmaDHS(RgoCqIaMjBqGHbOTVI8Awya6cz9NHsMYfGmydhMGvM1sX7ggkd2WHfyFKQxs6BA8aKa806gOxRyWluSAf)MgpajapTUb61kgaugqWOkMKS9vKxZcdqxiR)qcWtRBGETIcwzwakdiyuftsFzsm8CoWnR4mqYKXbSfGUII9lYD60RRsA9a3SIZajdw5uGwftsjM4lt2lgEohqZas1QoLmkeQ4spGZ3PtVUkP1dyfibnt2Wdi2c0QyskXeD6GHNZb2lEcanSt7WfW5T9vKxZcdqxiR)muYuUaKbB4WeSYSwkE3WqzWgoSamkq5xs(npiCOaeyM2PZsX7ggkd2WHf4JsGHBw6ltMheouisHUbqI0kurEnBiwjLg0WXPBkGuOBaKiTXLi9lpiCyGtJVthxL06bUzfNbsgSYPaTkMKsF7fdpNdCZkodKmzCaBbCEMOtNEtJhyOKPCbid2WHf8cfRwXVzCP0aiuufisgV4OFIOKTVI8Awya6cz9pwjLg0WXPBsWkZkpiCOqKcDdGeP9xEq4WaNg)xm8Co4fVzYgpkzG8KccqxrX(fjBFf51SWa0fY6p0jsACGYlyLz1laFP8aePWsqyTImOa2GghO881kAuEEfOoomq9aV45PuNo5bHdfIuOBaKiTczoY)Ydchg404T9vKxZcdqxiR)Ucmoq5fSYSa4lLhGifwccRvKbfWg04aLNVwrJYZRa1XHbQh4fppL(MheouisHUbqI0kK5i)lpiCyGtJ32xrEnlmaDHS(NbefxRv04aLxWkZcGVuEaIuyjiSwrguaBqJduE(AfnkpVcuhhgOEGx88u6BEq4qHif6gajsRqMJ8V8GWHbonEBFf51SWa0fY6p3SIZajdw5KGvMfgEoh4MvCgizY4a2c48D6KheouOI8A2qSsknOHJt3uaPq3airAfqEq4WaNgVTVI8Awya6cz9hO8(amqhuXibRmRExkE3WqzWgoSamkq5xs2PdgEoh8I3mzJhLmqEsbbOROycG5oDYdchkurEnBiwjLg0WXPBkGuOBaKiTcipiCyGtJ32xrEnlmaDHS(hRKsdA440njyLzHHNZbV4nt24rjdKNuqa6kk2Viz7RiVMfgGUqw)zOKPCbid2WHjyLz1BA8adLmLlazWgoSGxOy1k(TxxL06bgkzkxaYuBghwZgOvXKuY232xrEnlmGKKYojK1)OkGFMvWkZYvjTEWjah0mzdTIQiXrRhOvXKu6BEq4WF5bHddCA82(kYRzHbKKu2jHS(ZqjtgiFbkhA7RiVMfgqsszNeY6VRaJduEbRmla(s5bisb4GlZdqKmehgbGbQh4fppL(6kW4aLpaioTw4pru6lAgzAyydzPcOaG40AH)erjBFf51SWassk7Kqw)Zsfqcwzwa8LYdqKcWbxMhGiziomcadupWlEEk91vGXbkFaN32xrEnlmGKKYojK1FabNv9Afnkammy7RiVMfgqsszNeY6pdLmLlazWgombRmRmUuAaekQcejJxC0pruY2xrEnlmGKKYojK1Fuungq5G2(kYRzHbKKu2jHS(JH7OOeGnbRmR04byuGYVK0GnCybVqXQv8ltMgpuRtGvLgmjrPAfdqxrX(XCNoPXdWOaLFjPbB4WcaItRf(teLycBFf51SWassk7Kqw)rkGDsWkZknEagfO8ljnydhwWluSAfT9vKxZcdijPStcz9prQh1GIQXakNGvMvEq4qHif6gajs7V8GWHbonEBFf51SWassk7Kqw)rZas1QoLmkeQ4s32xrEnlmGKKYojK1FmChfLaSjyLzHIQarcAYaf51SQuamhI8x0mY0WWgyOKPCbid2WHfY4sPbqOOkqKmEXrcaYtsPXvGi5qbcZ2(kYRzHbKKu2jHS(NL6gRwrd0bvmsWkZkpiCOqKcDdGeP9xEq4WaNgVTVI8AwyajjLDsiR)XkP0GgooDtcIydjjJRarYHSIqWkZkpiCOqKcDdGeP9xEq4WaNg)3mUuAaekQcejJxC0pruY2xrEnlmGKKYojK1FgkzkxaYGnCycwzw9MgpWqjt5cqgSHdl4fkwTI2(kYRzHbKKu2jHS(JH7OOeGnbRmlMS3LI3nmugSHdlaJcu(LKD60RRsA9adLmLlazQnJdRzd0QyskXeFrZitddBGHsMYfGmydhwiJlLgaHIQarY4fhjaipjLgxbIKdfimB7RiVMfgqsszNeY6psbStcwzwOzKPHHnWqjt5cqgSHdlKXLsdGqrvGiz8IJeaKNKsJRarYHceMT9vKxZcdijPStcz9pwjLgy0XT9vKxZcdijPStcz9plv2OKbgDCBFf51SWassk7Kqw)vdhoiraZKniWWa02xrEnlmGKKYojK1FOtK04aLxWkZQxa(s5bisHLGWAfzqbSbnoq55Rv0O88kqDCyG6bEXZtPoDYdchkePq3airAfYCK)LheomWPXB7RiVMfgqsszNeY6pKa806gOxROGi2qsY4kqKCiRieSYSaugqWOkMK(6QKwpeLTeqHgSYPaTkMKs2(kYRzHbKKu2jHS(Jua7KTVI8AwyajjLDsiR)XkP0GgooDtcIydjjJRarYHSIqWkZkpiCOqKcDdGeP9xEq4WaNgVTVI8AwyajjLDsiR)qcWtRBGETIcIydjjJRarYHSIqWkZcqzabJQys6lt2RRsA9awbsqZKn8aITaTkMKsD60lgEohqZas1QoLmkeQ4spGZZeFzYEb4lLhGifaSj1yqxLXia0GMnp4BQwrd0bvmcgOEGx88uQtNLI3nmugSHdlW(ivVKuNoUkP1dy4okkbylqRIjPet0PdgEohyV4ja0WoTdxaN32xrEnlmGKKYojK1FUzfNbsgSYjbrSHKKXvGi5qwriyLzLim8CoivNw3WpfCwtTcuc51SbOROyciUT9vKxZcdijPStcz9hO8(amqhuXibrSHKKXvGi5qwriyLzLim8CoivNw3WpfCwtTcuc51SbOROyciUT9vKxZcdijPStcz9hsaEADd0RvuqeBijzCfisoKvecwzw96QKwpGvGe0mzdpGylqRIjP03EDvsRhyV4ja0WoTdxGwftsPV9cWxkparkivNw3WpfCwtTcuc5dagOEGx88u6BVa8LYdqKca2KAmORYyeaAqZMh8nvROb6GkgbdupWlEEkz7RiVMfgqsszNeY6p3SIZajdw5KGi2qsY4kqKCiRiS9vKxZcdijPStcz9hO8(amqhuXibrSHKKXvGi5qwrC(53b]] )
    else
        spec:RegisterPack( "Survival", 20201012.1, [[dCKU2bqifQEKieDjriOnjIgLIkoLcLwfrv9kfPzru5wkQu7IKFruAyqQCmfLLbPQNjc10uujxdOY2uOW3eHKXPqrNJOkSoriKMhq6EeP9bu1bjQIQfsu8qIQi4IIqO2irvensIQO4KIqGvcuMjrvu6MevrODcj(PieIHsufPEkGPcj9vIQizVq9xKgmLomvlwfpgXKf1LrTzs9zrA0kItlz1IqQxdPmBkUne7wPFl1WvWYb9CvnDHRRsBhi(Ucz8kQ68IG1tuLMprSFcJNHrfdK9GXOGE0HE0ndDZqVcDJzIhd0JbIegymWGtqZtzmW6imga4cbPaXnyGbpbt7zmQyGVVqcJbMeXWNiQSYMwXK7rrAez)c5A8O6LaDDi7xiezXaNBzIebl(GbYEWyuqp6qp6MHUzOxHUXmXJXSefgWVXKgIbakKRXJQx5jaDDGbMu5mV4dgiZpbdKifwGleKce3iSYZC3GHcWsKcBIiKOpmuyNHE5ew0Jo0JobycWsKcR8SmiSrybvQWco0PWaM6JhJkgWh(aJkgLzyuXaojQEXaOvgd9N0bgGx)y4mwgCGrb9yuXa86hdNXYGbiWkyy5yGZvRvKUH5A9GZu)F)Ac1DqytkSZrypxTwr6gMR1dot9)9RjuqgXR9fwqf2zkWjSYxytjzHvIeH9C1A1XCH0wtd307RUdcBsH9C1A1XCH0wtd307RGmIx7lSGkSZuGtyLVWMsYc7yXaojQEXai9M29Z0tfmoWOKymQyaE9JHZyzWaeyfmSCmW5Q1ks3WCTEWzQ)VFnH6oiSjf25iSNRwRiDdZ16bNP()(1ekiJ41(clOc7mf4ew5lSPKSWkrIWEUAT6yUqARPHB69v3bHnPWEUAT6yUqARPHB69vqgXR9fwqf2zkWjSYxytjzHDSyaNevVyaOpenK(bSqJXbgL5cJkgGx)y4mwgmabwbdlhdOBY9f2PclX)Gc5uEfwqfwDtUVcXNhd4KO6fdOn(IwTP0pGfAmoWOaomQyaE9JHZyzWaojQEXaOvgdL0ii(MXaeyfmSCmG(AmuitM4WuMgfclSGkSZuGtyLVWMsYcBsHv3K7lStfwI)bfYP8kSGkS6MCFfIppgGKaXW0WHPC8yuMHdmkJbgvmaV(XWzSmyacScgwogq3K7lStfwI)bfYP8kSGkS6MCFfIppgWjr1lg4dMn0a6d4aJsIcJkgGx)y4mwgmabwbdlhdOBY9f2PclX)Gc5uEfwqfwDtUVcXNxytkSJlSrrqR2uHnPWoUWEUATcHrAyc0wtnxsLPzi7iV6oiSjf25iS6RXqHmzIdtzAuiSWcQWotboHv(cBkjlSsKiSJlS5ouJktwxqMEAKJkkcA1MkSjf2Xf2ZvRvKUH5A9GZu)F)Ac1DqyLiryhxyZDOgvMSUGm90ihvue0QnvytkSNRwRq6nT7NP6lmb1hobnHfuHDMWowHvIeHnkeMgnnxSWcQWoBmf2Kc74cBUd1OYK1fKPNg5OIIGwTPyaNevVyGrLjRlitpnYbhyugtmQyaE9JHZyzWaeyfmSCmW4cBUd1ZWbEd6h1MQIIGwTPcBsHDCH9C1AfPByUwp4m1)3VMqDhWaojQEXapdh4nOFuBkoWOipWOIb41pgoJLbd4KO6fdGwzmusJG4BgdqGvWWYXa6MCFHDQWs8pOqoLxHfuHv3K7Rq85f2Kc7Ce2ZvRvi9M29Zu9fMG6dNGMWcQWcoHvIeHv3K7lSGkSojQEvi9M29Z0tfSI0FiSJfdqsGyyA4WuoEmkZWbgLzOdJkgGx)y4mwgmabwbdlhdaznK)j(XWcBsHDCH9C1AfPByUwp4m1)3VMqDhe2Kc75Q1kKEt7(zQ(ctq9HtqtybvybhgWjr1lg4z4aVb9JAtXbgLzZWOIb41pgoJLbdqGvWWYXaJlSNRwRiDdZ16bNP()(1eQ7agWjr1lgWPixyMH0wtjWE0JdmkZqpgvmaV(XWzSmyacScgwogyCH9C1AfPByUwp4m1)3VMqDhWaojQEXaKUH5A9GZu)F)AcCGrzwIXOIb41pgoJLbdqGvWWYXaNRwRq6nT7NP6lmb1DqyLiry1n5(c7uHL4FqHCkVcl4fwDtUVcXNxyNBHDg6ewjse2ZvRvKUH5A9GZu)F)Ac1Dad4KO6fdG0BA3ptpvW4aJYS5cJkgWjr1lga6drdPFal0ymaV(XWzSm4aJYmWHrfdWRFmCgldgGaRGHLJbgxyJIGwTPyaNevVyGrLjRlitpnYbh4admsxyuXOmdJkgWjr1lgaTYyO)KoWa86hdNXYGdmkOhJkgGx)y4mwgmabwbdlhdOBY9f2PclX)Gc5uEfwqfwDtUVcXNxytkSHB4nubdrEARP8M6PmcVHIx)y4mgWjr1lgyIdh6EXbgLeJrfdWRFmCgldgGaRGHLJboxTwDmxiT10Wn9(Q7GWMuypxTwDmxiT10Wn9(kiJ41(clOcBkjJbCsu9Ibq6nT7NPNkyCGrzUWOIb41pgoJLbdqGvWWYXaNRwRoMlK2AA4MEF1DqytkSNRwRoMlK2AA4MEFfKr8AFHfuHnLKXaojQEXaqFiAi9dyHgJdmkGdJkgGx)y4mwgmabwbdlhdCUATcKAGHpfeEBe1DqytkSNRwRaPgy4tbH3grbzeV2xybvyNPaNWkFHnLKfwjse2Xf2ChQNHd8g0pQnvffbTAtXaojQEXapdh4nOFuBkoWOmgyuXa86hdNXYGbiWkyy5ya91yOqMmXHPmnkewybvyNPaNWkFHnLKf2KcRUj3xyNkSe)dkKt5vybvy1n5(keFEHvIeHDoc7YZh0rf90ihfiTXJYWcBsHn3H6z4aVb9JAtvrrqR2uHnPWM7q9mCG3G(rTPkiRH8pXpgwyLiryxE(GoQONg5OgMWWgPxwytkSJlSNRwRq6nT7NP6lmb1DqytkS6MCFHDQWs8pOqoLxHfuHv3K7Rq85f25wyDsu9QqRmgkPrq8nRi(huiNYRWkFHnXc7yXaojQEXaJktwxqMEAKdoWOKOWOIb41pgoJLbd4KO6fdGwzmusJG4BgdqGvWWYXa6MCFHDQWs8pOqoLxHfuHv3K7Rq85f25wy1n5(kiNYlgGKaXW0WHPC8yuMHdmkJjgvmGtIQxmGtrUWmdPTMsG9OhdWRFmCgldoWOipWOIb41pgoJLbdqGvWWYXa6MCFHDQWs8pOqoLxHfuHv3K7Rq85XaojQEXaFWSHgqFahyuMHomQyaE9JHZyzWaeyfmSCmG(AmuitM4WuMgfclSGkSZuGtyLVWMsYyaNevVyGrLjRlitpnYbhyuMndJkgWjr1lgG0nmxRhCM6)7xtGb41pgoJLbhyuMHEmQyaE9JHZyzWaeyfmSCmW5Q1kqQbg(uq4Tru3bHnPWM7q9mCG3G(rTPkiJ41(clOc7CjSYxytjzmGtIQxmWZWbEd6h1MIdmkZsmgvmaV(XWzSmyacScgwogi3H6Na9HLn0tJCurrqR2uHvIeH9C1AfsVPD)mvFHjO(WjOjSsfwWHbCsu9Ibq6nT7NPNkyCGrz2CHrfdWRFmCgldgGaRGHLJbwE(GoQONg5O(jqFyzJWMuyZDOEgoWBq)O2ufKr8AFHf8cl4ew5lSPKmgWjr1lgyuzY6cY0tJCWbgLzGdJkgGx)y4mwgmabwbdlhdaznK)j(XWyaNevVyGNHd8g0pQnfhyuMngyuXa86hdNXYGbiWkyy5yGXf2ZvRvi9M29Zu9fMGcYiETpgWjr1lgGmXrd6ipoWOmlrHrfd4KO6fdG0BA3ptpvWyaE9JHZyzWbgLzJjgvmGtIQxma0hIgs)awOXyaE9JHZyzWbgLzYdmQyaE9JHZyzWaeyfmSCmW5Q1kqQbg(uq4Tru3bmGtIQxmWZWbEd6h1MIdmkOhDyuXa86hdNXYGbiWkyy5yGLNpOJk6ProkqAJhLHf2KcBUd1ZWbEd6h1MQIIGwTPcRejc7YZh0rf90ih1Weg2i9YcRejc7YZh0rf90ih1pb6dlBWaojQEXaJktwxqMEAKdoWbgWhgPlmQyuMHrfd4KO6fdGwzm0FshyaE9JHZyzWbgf0JrfdWRFmCgldgGaRGHLJboxTwDmxiT10Wn9(Q7GWMuypxTwDmxiT10Wn9(kiJ41(clOcBkjJbCsu9Ibq6nT7NPNkyCGrjXyuXa86hdNXYGbiWkyy5yGZvRvhZfsBnnCtVV6oiSjf2ZvRvhZfsBnnCtVVcYiETVWcQWMsYyaNevVyaOpenK(bSqJXbgL5cJkgGx)y4mwgmabwbdlhdmUWM7q9mCG3G(rTPQOiOvBkgWjr1lg4z4aVb9JAtXbgfWHrfd4KO6fd4uKlmZqARPeyp6Xa86hdNXYGdmkJbgvmaV(XWzSmyacScgwogqFngkKjtCyktJcHfwqf2zkWjSYxytjzHvIeHv3K7lStfwI)bfYP8kSGkS6MCFfIpVWMuyNJWU88bDurpnYrbsB8OmSWMuyZDOEgoWBq)O2uvue0QnvytkS5oupdh4nOFuBQcYAi)t8JHfwjse2LNpOJk6ProQHjmSr6Lf2Kc74c75Q1kKEt7(zQ(ctqDhe2KcRUj3xyNkSe)dkKt5vybvy1n5(keFEHDUfwNevVk0kJHsAeeFZkI)bfYP8kSYxytSWowmGtIQxmWOYK1fKPNg5GdmkjkmQyaNevVyas3WCTEWzQ)VFnbgGx)y4mwgCGrzmXOIb41pgoJLbdqGvWWYXaNRwRq6nT7NP6lmbfKr8AFHnPWU88bDurpnYrnmHHnsVmgWjr1lgaP30UFMEQGXbgf5bgvmaV(XWzSmyaNevVya0kJHsAeeFZyacScgwogqFngkKjtCyktJcHfwqf2zkWjSYxytjzHnPWQBY9f2PclX)Gc5uEfwqfwDtUVcXNxyNBHf9OddqsGyyA4WuoEmkZWbgLzOdJkgGx)y4mwgmabwbdlhdOBY9f2PclX)Gc5uEfwqfwDtUVcXNhd4KO6fd8bZgAa9bCGrz2mmQyaE9JHZyzWaeyfmSCmW5Q1QOgOTMgty6pWou9HtqtyLkSjwyLiryZDO(jqFyzd90ihvue0Qnfd4KO6fda9HOH0pGfAmoWOmd9yuXa86hdNXYGbiWkyy5yGChQFc0hw2qpnYrffbTAtXaojQEXai9M29Z0tfmoWOmlXyuXa86hdNXYGbiWkyy5yGLNpOJk6ProQFc0hw2iSjfwDtUVWcEHnXOtytkS5oupdh4nOFuBQcYiETVWcEHfCcR8f2usgd4KO6fdmQmzDbz6Pro4aJYS5cJkgGx)y4mwgmabwbdlhdmUWEUATcP30UFMQVWeuqgXR9XaojQEXaKjoAqh5XbgLzGdJkgGx)y4mwgmabwbdlhdaznK)j(XWyaNevVyGNHd8g0pQnfhyuMngyuXa86hdNXYGbCsu9IbqRmgkPrq8nJbiWkyy5yaDtUVWovyj(huiNYRWcQWQBY9vi(8cBsHDoc75Q1kKEt7(zQ(ctq9HtqtybvybNWkrIWQBY9fwqfwNevVkKEt7(z6Pcwr6pe2XIbijqmmnCykhpgLz4aJYSefgvmGtIQxma0hIgs)awOXyaE9JHZyzWbgLzJjgvmaV(XWzSmyacScgwog4C1AfsVPD)mvFHjOUdcRejcRUj3xybVWoxOtyLiryZDO(jqFyzd90ihvue0Qnfd4KO6fdG0BA3ptpvW4aJYm5bgvmaV(XWzSmyacScgwogy55d6OIEAKJcK24rzyHnPWM7q9mCG3G(rTPQOiOvBQWkrIWU88bDurpnYrnmHHnsVSWkrIWU88bDurpnYr9tG(WYgHnPWQBY9fwWlSGdDyaNevVyGrLjRlitpnYbh4adqmSdcJrfJYmmQyaE9JHZyzWa9ag45O0yaNevVyaqCy5hdJbaXH01rymaXHGWusgIbiWkyy5yaNefimLxgP4xybvybhgae3CzkBEgdaomaiU5YyaNefimLxgP4hhyuqpgvmaV(XWzSmyacScgwogWLxgwbRoMlK2AA4MEFf0x0ewWlSOtytkSZrypxTwr6gMR1dot9)9Rju3bHnPWohH9C1AfPByUwp4m1)3VMqbzeV2xybvyNPaNWkFHnLKfwjse2ZvRvhZfsBnnCtVV6oiSjf2ZvRvhZfsBnnCtVVcYiETVWcQWotboHv(cBkjlSsKiSNRwRiDdZ16bNP()(1ekiJ41(cBsHDCH9C1A1XCH0wtd307RGmIx7lSJvyhlgWjr1lgaP30UFMEQGXbgLeJrfdWRFmCgldgWjr1lgaP30UFMEQGXaeyfmSCmqMpxTwz8G3Go013R6dNGMWcEHDocRtIceMYlJu8lSsKiSYdHDScBsHvxPtckKr8AFHfuH1jrbct5Lrk(fw5lSPKmgGKaXW0WHPC8yuMHdmkZfgvmGtIQxmGtrUWmdPTMsG9OhdWRFmCgldoWOaomQyaNevVyas3WCTEWzQ)VFnbgGx)y4mwgCGrzmWOIb41pgoJLbdqGvWWYXa5ou)eOpSSHEAKJkkcA1MkSjf2Xf2Wn8gQjjKH(tpvWkE9JHZcRejcBUd1pb6dlBONg5OIIGwTPcBsH1jrbct5Lrk(fwWlSGdd4KO6fdqCiimoWOKOWOIb41pgoJLbdqGvWWYXaJlSHB4nuPxgclJXPHtII8kE9JHZcRejcR(AmuitM4WuMgfclSGkSPKSWkrIWc9ktzq4nuEo)kiJ41(clOc7yiSjfwOxzkdcVHYZ5xXZxF8yaNevVyGrLjRlitpnYbhyugtmQyaE9JHZyzWaeyfmSCmazIdt5NQHojQEDJWcEHf9kWjSsKiS5ou)eOpSSHEAKJkkcA1MkSsKiSKUn5E0QgvMSUGm90ihfKr8AFHf8cRtIceMYlJu8lSZTWMsYcRejcBMpxTwDmDNPTMgtykVmsckiJ41(cRejcl0RmLbH3q558RGmIx7lSGkSGtytkSqVYugeEdLNZVINV(4XaojQEXaNBqMWWeWbgf5bgvmaV(XWzSmyaNevVyaKEt7(z6PcgdqGvWWYXaz(C1ALXdEd6qxFVQpCcAcl4f2XedqsGyyA4WuoEmkZWbgLzOdJkgWjr1lgGmXrd6ipgGx)y4mwgCGrz2mmQyaE9JHZyzWaojQEXaOvgdL0ii(MXaeyfmSCmGUj3xyNkSe)dkKt5vybvy1n5(keFEmajbIHPHdt54XOmdhyuMHEmQyaE9JHZyzWaeyfmSCmq4gEdvWqKN2AkVPEkJWBO41pgoJbCsu9IbM4WHUxCGrzwIXOIb41pgoJLbdqGvWWYXaHB4nuPxgclJXPHtII8kE9JHZyaNevVyaIdbHXbgLzZfgvmaV(XWzSmyacScgwogG0Tj3Jw1OYK1fKPNg5OGmIx7lSGxyNJW6KOaHP8Yif)cRejcl4e2XIbCsu9Ibo3GmHHjGdmkZahgvmaV(XWzSmyacScgwogq3K7lStfwI)bfYP8kSGkS6MCFfIppgWjr1lgqB8fTAtPFal0yCGrz2yGrfdWRFmCgldgGaRGHLJbYDOgvMSUGm90ihfK1q(N4hdlSsKiSHB4nuJktwxqMwR((vVkE9JHZyaNevVyGrLjRlitpnYbhyuMLOWOIb41pgoJLbd4KO6fd8mCG3G(rTPyacScgwog4C1Afi1adFki82iki7KadqsGyyA4WuoEmkZWbgLzJjgvmaV(XWzSmyacScgwogG0Tj3Jw1OYK1fKPNg5OGmIx7lSGxybXHLFmSI4qqykjdf2eHcl6XaojQEXaehccJdmkZKhyuXaojQEXaFWSHgqFadWRFmCgldoWOGE0HrfdWRFmCgldgWjr1lg4z4aVb9JAtXaeyfmSCmaK1q(N4hdlSjf2ZvRvrnqBnnMW0FGDO6dNGMWcQWMyHnPWU88bDurpnYrbsB8OmSWkrIWcznK)j(XWcBsH1LxgwbRmEWBqh667vb9fnHf8cl6WaKeigMgomLJhJYmCGrb9ZWOIb41pgoJLbd4KO6fdG0BA3ptpvWyascedtdhMYXJrzgoWOGE0JrfdWRFmCgldgWjr1lga6drdPFal0ymajbIHPHdt54XOmdh4adKzTFnbgvmkZWOIbCsu9IbqUYR8AymaV(XWzSm4aJc6XOIbCsu9IbUptRGrEmaV(XWzSm4aJsIXOIb41pgoJLbd4KO6fdqCJH6KO6LAQpWaM6d66imgGKFCGrzUWOIb41pgoJLbdqGvWWYXaojkqykVmsXVWkvyNjSjf2WHPCOIcHPrtZflSGkS6MCFHnrOWohH1jr1RcP30UFMEQGvK(dHDUfwI)bfYP8kSJvyLVWMsYyaNevVyaKEt7(z6PcghyuahgvmaV(XWzSmyacScgwogWjrbct5Lrk(fwqf2elSjf2Wn8gkYehnOJ8kE9JHZcBsHnCdVHYndtC6aKZE0qfV(XWzmGtIQxmaXngQtIQxQP(adyQpORJWyaFyKUWbgLXaJkgGx)y4mwgmabwbdlhd4KOaHP8Yif)clOcBIf2KcB4gEdfzIJg0rEfV(XWzmGtIQxmaXngQtIQxQP(adyQpORJWyGr6chyusuyuXa86hdNXYGbiWkyy5yaNefimLxgP4xybvytSWMuyhxyd3WBOCZWeNoa5ShnuXRFmCwytkSJlSHB4nuJktwxqMwR((vVkE9JHZyaNevVyaIBmuNevVut9bgWuFqxhHXaFGdmkJjgvmaV(XWzSmyacScgwogWjrbct5Lrk(fwqf2elSjf2Wn8gk3mmXPdqo7rdv86hdNf2Kc74cB4gEd1OYK1fKP1QVF1RIx)y4mgWjr1lgG4gd1jr1l1uFGbm1h01rymGp8boWOipWOIb41pgoJLbdqGvWWYXaojkqykVmsXVWcQWMyHnPWgUH3q5MHjoDaYzpAOIx)y4SWMuyd3WBOgvMSUGmTw99REv86hdNXaojQEXae3yOojQEPM6dmGP(GUocJb8Hr6chyuMHomQyaE9JHZyzWaeyfmSCmGtIceMYlJu8lSGkSjwytkSJlSHB4nuUzyIthGC2JgQ41pgolSjf2Wn8gQrLjRlitRvF)QxfV(XWzmGtIQxmaXngQtIQxQP(adyQpORJWyGr6chyuMndJkgGx)y4mwgmabwbdlhd4KOaHP8Yif)cl4f2zcBsHDCHnCdVH6uW8tBnDaYjO41pgolSsKiSojkqykVmsXVWcEHf9yaNevVyaIBmuNevVut9bgWuFqxhHXaed7GW4aJYm0Jrfd4KO6fdq6LWBa9GZuTXrymaV(XWzSm4aJYSeJrfd4KO6fd4qIVmnAiK3adWRFmCgldoWOmBUWOIbCsu9IboEkT10awe0EmaV(XWzSm4ahyas(XOIrzggvmaV(XWzSmyacScgwogG0Tj3JwfPByUwp4m1)3VMqbzeV2xybVWMy0HbCsu9IboMUZu9fMaoWOGEmQyaE9JHZyzWaeyfmSCmaPBtUhTks3WCTEWzQ)VFnHcYiETVWcEHnXOdd4KO6fd4lH)a6gkXngCGrjXyuXa86hdNXYGbiWkyy5yas3MCpAvKUH5A9GZu)F)AcfKr8AFHf8cBIrhgWjr1lgqxq(y6oJdmkZfgvmGtIQxmGPsNepnrFZPi8gyaE9JHZyzWbgfWHrfdWRFmCgldgGaRGHLJbiDBY9Ovr6gMR1dot9)9RjuqgXR9fwWlSJb6ewjse2OqyA00CXclOc7SeJbCsu9Ibom8ziA1MIdmkJbgvmaV(XWzSmyacScgwog4C1Av61H5YxARPU8YWoMOUdcBsHDoc75Q1QddFgIwTPQ7GWkrIWEUAT6y6ot1xycQ7GWkrIWoUWcDcRcyBmc7yfwjse25iSKE)lIFmSAOJQxARP39aRSHZu9fMGWMuy1v6KGczeV2xybvyhJzcRejcRUsNeuiJ41(clOcl6hdHDScRejc74cl)pVewr6nZ7ZzQP0SUHewH4j6gkSjf2ZvRvKUH5A9GZu)F)Ac1Dad4KO6fdm0r1loWOKOWOIb41pgoJLbdqGvWWYXaHdt5qLRp8LWcl4LkSJbgWjr1lgW)bMe0wtJjmL9udJdmkJjgvmaV(XWzSmyaNevVya)NaIV8tHU82qkPHUbdqGvWWYXaNRwRqyKgMaT1uZLuzAgYoYRUdcBsHvxPtckKr8AFHfuHL0Tj3JwfcJ0WeOTMAUKktZq2rEfKr8AFHDQWodCcRejc75Q1Q0RdZLV0wtD5LHDmr9HtqtyLkSGtytkS6kDsqHmIx7lSGkSKUn5E0QsVomx(sBn1Lxg2XefKr8AFHDQWIE0jSsKiSz(C1Af0L3gsjn0n0mFUATk3JwHvIeHvxPtckKr8AFHfuHf9Zewjse2ZvRvJAOjdcxlfYFV(syfKr8AFHnPWQR0jbfYiETVWcQWs62K7rRAudnzq4APq(71xcRGmIx7lStf2zJPWkrIWoUWgUH3qDky(PTMoa5eu86hdNf2KcRUsNeuiJ41(clOclPBtUhTks3WCTEWzQ)VFnHcYiETVWovyrp6e2Kc75Q1ks3WCTEWzQ)VFnHcYiETpgyDegd4)eq8LFk0L3gsjn0n4aJI8aJkgGx)y4mwgmGtIQxmqQByIBmm8PNUxmabwbdlhdq62K7rRcHrAyc0wtnxsLPzi7iVcYiETVWkrIWgUH3qnQmzDbzAT67x9Q41pgolSjfws3MCpAvKUH5A9GZu)F)AcfKr8AFHvIeHDCHL)NxcRqyKgMaT1uZLuzAgYoYRq8eDdf2KclPBtUhTks3WCTEWzQ)VFnHcYiETpgyDegdK6gM4gddF6P7fhyuMHomQyaE9JHZyzWaRJWyaxE)jo0FQU3G2A6qpIHyaNevVyaxE)jo0FQU3G2A6qpIH4aJYSzyuXa86hdNXYGbiWkyy5yaOxzkdcVHYZ5xvRWcEHvEGoHnPWQBY9fwqfwDtUVcXNxyNBHf9GtyLiryNJW6KOaHP8Yif)cl4f2zcBsHDCHnCdVH6uW8tBnDaYjO41pgolSsKiSojkqykVmsXVWcEHf9c7yf2Kc7Ce2ZvRvhZfsBnnCtVV6oiSjf2ZvRvhZfsBnnCtVVcYiETVWcEHnXcR8f2uswyLiryhxypxTwDmxiT10Wn9(Q7GWowmGtIQxmGUj3NZuxEzyfm9WocoWOmd9yuXa86hdNXYGbiWkyy5yG5iSZryHELPmi8gkpNFfKr8AFHf8cR8aDcRejc74cl0RmLbH3q558R45RpEHDScRejc7CewNefimLxgP4xybVWotytkSJlSHB4nuNcMFARPdqobfV(XWzHvIeH1jrbct5Lrk(fwWlSOxyhRWowHnPWQBY9fwqfwDtUVcXNhd4KO6fdCmDNPTMgtykVmsc4aJYSeJrfdWRFmCgldgGaRGHLJbMJWohHf6vMYGWBO8C(vqgXR9fwWlSJb6ewjse2XfwOxzkdcVHYZ5xXZxF8c7yfwjse25iSojkqykVmsXVWcEHDMWMuyhxyd3WBOofm)0wthGCckE9JHZcRejcRtIceMYlJu8lSGxyrVWowHDScBsHv3K7lSGkS6MCFfIppgWjr1lgy4clDc1Mspg)dCGrz2CHrfd4KO6fdKEDyU8L2AQlVmSJjyaE9JHZyzWbgLzGdJkgWjr1lgawddgMwl9hCcJb41pgoJLbhyuMngyuXa86hdNXYGbiWkyy5ya91yOqMmXHPmnkewybvyNjSYxytjzmGtIQxmaPxcVb0dot1ghHXbgLzjkmQyaE9JHZyzWaeyfmSCmW5Q1kitqZW)t1nKWQ7agWjr1lgiMW07E67MP6gsyCGrz2yIrfd4KO6fdmQHMmiCTui)96lHXa86hdNXYGdmkZKhyuXa86hdNXYGbiWkyy5yGWHPCOMWUjMOgiHWcEHDmrNWkrIWgomLd1e2nXe1ajewqLkSOhDcRejcB4WuourHW0OPdKGIE0jSGxytm6WaojQEXaq2hQnLQnoc)4aJc6rhgvmaV(XWzSmyacScgwogG)NxcRqyKgMaT1uZLuzAgYoYRq8eDdf2KclK1q(N4hdlSjf2ZvRvGudm8PGWBJOUdcBsHDCHL0Tj3JwfcJ0WeOTMAUKktZq2rEfKr8AFmGtIQxmWZWbEd6h1MIdmkOFggvmaV(XWzSmyacScgwogG)NxcRqyKgMaT1uZLuzAgYoYRq8eDdf2Kc74clPBtUhTkegPHjqBn1CjvMMHSJ8kiJ41(yaNevVyaKEt7(z6Pcghyuqp6XOIb41pgoJLbdqGvWWYXa8)8syfcJ0WeOTMAUKktZq2rEfINOBOWMuy1xJHczYehMY0OqyHfuHDMcCcR8f2uswytkS6MCFHfuH1jr1RcP30UFMEQGvK(dHnPWoUWs62K7rRcHrAyc0wtnxsLPzi7iVcYiETpgWjr1lgyuzY6cY0tJCWbgf0NymQyaE9JHZyzWaeyfmSCmGUj3xybvyDsu9Qq6nT7NPNkyfP)qytkSNRwRiDdZ16bNP()(1eQ7agWjr1lgaHrAyc0wtnxsLPzi7ipoWbg4dmQyuMHrfd4KO6fdGwzm0FshyaE9JHZyzWbgf0JrfdWRFmCgldgGaRGHLJbc3WBOcgI80wt5n1tzeEdfV(XWzmGtIQxmWeho09IdmkjgJkgGx)y4mwgmabwbdlhdOBY9f2PclX)Gc5uEfwqfwDtUVcXNhd4KO6fdOn(IwTP0pGfAmoWOmxyuXa86hdNXYGbiWkyy5yGZvRvKUH5A9GZu)F)Ac1DqytkSZrypxTwr6gMR1dot9)9RjuqgXR9fwqf2zkWjSYxytjzHvIeH9C1A1XCH0wtd307RUdcBsH9C1A1XCH0wtd307RGmIx7lSGkSZuGtyLVWMsYc7yXaojQEXaqFiAi9dyHgJdmkGdJkgGx)y4mwgmabwbdlhdCUATI0nmxRhCM6)7xtOUdcBsHDoc75Q1ks3WCTEWzQ)VFnHcYiETVWcQWotboHv(cBkjlSsKiSNRwRoMlK2AA4MEF1DqytkSNRwRoMlK2AA4MEFfKr8AFHfuHDMcCcR8f2uswyhlgWjr1lgaP30UFMEQGXbgLXaJkgGx)y4mwgmGtIQxmaALXqjncIVzmabwbdlhdOBY9f2PclX)Gc5uEfwqfwDtUVcXNhdqsGyyA4WuoEmkZWbgLefgvmaV(XWzSmyacScgwog4C1Afi1adFki82iQ7GWMuypxTwbsnWWNccVnIcYiETVWcQWotyLVWMsYyaNevVyGNHd8g0pQnfhyugtmQyaE9JHZyzWaeyfmSCmGUj3xyNkSe)dkKt5vybvy1n5(keFEmGtIQxmWhmBOb0hWbgf5bgvmaV(XWzSmyacScgwogq3K7lStfwI)bfYP8kSGkS6MCFfIpVWMuyHSgY)e)yyHnPWQVgdfYKjomLPrHWclOcBkjlSjf2Xf2ZvRvimsdtG2AQ5sQmndzh5v3bHvIeHv3K7lStfwI)bfYP8kSGkS6MCFfIpVWMuyNJWoUWM7qnQmzDbz6ProQOiOvBQWMuyNJWoUWEUATI0nmxRhCM6)7xtOUdcRejc75Q1kKEt7(zQ(ctq9HtqtybvyNjSsKiSrHW0OP5Ifwqf2zJPWkrIWoUWM7qnQmzDbz6ProQOiOvBQWMuyD5LHvWQrLjZWL)N(xiifiUrb9fnHf8cl6e2XkSJvytkSJlSNRwRqyKgMaT1uZLuzAgYoYRUdyaNevVyGrLjRlitpnYbhyuMHomQyaE9JHZyzWaeyfmSCmW5Q1kqQbg(uq4Tru3bHnPWM7q9mCG3G(rTPkiJ41(clOc7CjSYxytjzHvIeHn3H6z4aVb9JAtvqwd5FIFmSWMuyhxypxTwr6gMR1dot9)9Rju3bmGtIQxmWZWbEd6h1MIdmkZMHrfdWRFmCgldgGaRGHLJbgxypxTwr6gMR1dot9)9Rju3bmGtIQxmGtrUWmdPTMsG9OhhyuMHEmQyaE9JHZyzWaeyfmSCmW4c75Q1ks3WCTEWzQ)VFnH6oGbCsu9IbiDdZ16bNP()(1e4aJYSeJrfdWRFmCgldgGaRGHLJboxTwH0BA3pt1xycQ7GWkrIWQBY9f2PclX)Gc5uEfwWlS6MCFfIpVWo3cl6rNWMuyd3WBOaPgy4tbH3grXRFmCwyLiry1n5(c7uHL4FqHCkVcl4fwDtUVcXNxyNBHDMWMuyd3WBOcgI80wt5n1tzeEdfV(XWzHvIeH9C1AfPByUwp4m1)3VMqDhWaojQEXai9M29Z0tfmoWOmBUWOIbCsu9IbG(q0q6hWcngdWRFmCgldoWOmdCyuXa86hdNXYGbiWkyy5yGChQrLjRlitpnYrbznK)j(XWyaNevVyGrLjRlitpnYbhyuMngyuXa86hdNXYGbiWkyy5yGZvRvGudm8PGWBJOUdyaNevVyGNHd8g0pQnfh4admazsJC8aJkgLzyuXa86hdNXYGbwhHXaU8(tCO)uDVbT10HEedXaojQEXaU8(tCO)uDVbT10HEedXbgf0Jrfd4KO6fdKEDyU8L2AQlVmSJjyaE9JHZyzWbgLeJrfd4KO6fdq6gMR1dot9)9RjWa86hdNXYGdmkZfgvmGtIQxmWOgAYGW1sH83RVegdWRFmCgldoWOaomQyaE9JHZyzWaojQEXadDu9IbYjSosrOdqEOdmWmCGrzmWOIbCsu9Ib(GzdnG(agGx)y4mwgCGrjrHrfd4KO6fdmXHdDVyaE9JHZyzWboWbgaeg(vVyuqp6qp6MHo0LOuOFg6gZzjgdmYHBTPpgiraYqddolSJPW6KO6vyn1hVsagg4hycgf0doWHbgGTUmmgirkSaxiifiUryLN5UbdfGLif2erirFyOWod9YjSOhDOhDcWeGLifw5zzqyJWcQuHfCOtjataMtIQ3xnazsJC8yQuzVptRGrKBDewQlV)eh6pv3BqBnDOhXqbyojQEF1aKjnYXJPsLn96WC5lT1uxEzyhteG5KO69vdqM0ihpMkvws3WCTEWzQ)VFnHamNevVVAaYKg54XuPYoQHMmiCTui)96lHfG5KO69vdqM0ihpMkv2HoQELlNW6ifHoa5HoKotaMtIQ3xnazsJC8yQuz)GzdnG(GamNevVVAaYKg54XuPYoXHdDVcWeG5KO69NkvwKR8kVgwaMtIQ3FQuzVptRGrEbyojQE)PsLL4gd1jr1l1uFi36iSus(fG5KO69NkvwKEt7(z6PcwUsl1jrbct5Lrk(Lolz4WuourHW0OP5Ibv3K7NiCoojQEvi9M29Z0tfSI0Fm3e)dkKt5DSYpLKfG5KO69NkvwIBmuNevVut9HCRJWs9Hr6sUsl1jrbct5Lrk(bnXjd3WBOitC0GoYR41pgoNmCdVHYndtC6aKZE0qfV(XWzbyojQE)PsLL4gd1jr1l1uFi36iS0r6sUsl1jrbct5Lrk(bnXjd3WBOitC0GoYR41pgolaZjr17pvQSe3yOojQEPM6d5whHL(HCLwQtIceMYlJu8dAItoE4gEdLBgM40biN9OHkE9JHZjhpCdVHAuzY6cY0A13V6vXRFmCwaMtIQ3FQuzjUXqDsu9sn1hYTocl1h(qUsl1jrbct5Lrk(bnXjd3WBOCZWeNoa5ShnuXRFmCo54HB4nuJktwxqMwR((vVkE9JHZcWCsu9(tLklXngQtIQxQP(qU1ryP(WiDjxPL6KOaHP8Yif)GM4KHB4nuUzyIthGC2JgQ41pgoNmCdVHAuzY6cY0A13V6vXRFmCwaMtIQ3FQuzjUXqDsu9sn1hYToclDKUKR0sDsuGWuEzKIFqtCYXd3WBOCZWeNoa5ShnuXRFmCoz4gEd1OYK1fKP1QVF1RIx)y4SamNevV)uPYsCJH6KO6LAQpKBDewkXWoiSCLwQtIceMYlJu8d(zjhpCdVH6uW8tBnDaYjO41pgolrItIceMYlJu8dE0latawIuyLNSmgg(YjSe)dHT0c72XKAtfw28SWwVW6G4LXpgwjaZjr17pvQSKEj8gqp4mvBCewaMtIQ3FQuzDiXxMgneYBiaZjr17pvQShpL2AAalcAVambyjsHvEUzyIlSYtd5ShnuaMtIQ3x5dFifTYyO)KoeG5KO69v(WhtLklsVPD)m9ublxPLEUATI0nmxRhCM6)7xtOUdjNZ5Q1ks3WCTEWzQ)VFnHcYiETpOZuGt(PKSejNRwRoMlK2AA4MEF1Di55Q1QJ5cPTMgUP3xbzeV2h0zkWj)usEScWCsu9(kF4JPsLf6drdPFal0y5kT0ZvRvKUH5A9GZu)F)Ac1Di5CoxTwr6gMR1dot9)9RjuqgXR9bDMcCYpLKLi5C1A1XCH0wtd307RUdjpxTwDmxiT10Wn9(kiJ41(Gotbo5NsYJvaMtIQ3x5dFmvQSAJVOvBk9dyHglxPLQBY9Ns8pOqoLxq1n5(keFEbyojQEFLp8XuPYIwzmusJG4BwoscedtdhMYXlDMCLwQ(AmuitM4WuMgfcd6mf4KFkjNu3K7pL4FqHCkVGQBY9vi(8cWCsu9(kF4JPsL9dMn0a6dYvAP6MC)Pe)dkKt5fuDtUVcXNxaMtIQ3x5dFmvQSJktwxqMEAKJCLwQUj3FkX)Gc5uEbv3K7Rq85toEue0Qnn54NRwRqyKgMaT1uZLuzAgYoYRUdjNJ(AmuitM4WuMgfcd6mf4KFkjlrY45ouJktwxqMEAKJkkcA1MMC8ZvRvKUH5A9GZu)F)Ac1DqIKXZDOgvMSUGm90ihvue0Qnn55Q1kKEt7(zQ(ctq9Htqd0zJvIKOqyA00CXGoBmtoEUd1OYK1fKPNg5OIIGwTPcWCsu9(kF4JPsL9z4aVb9JAtLR0shp3H6z4aVb9JAtvrrqR20KJFUATI0nmxRhCM6)7xtOUdcWCsu9(kF4JPsLfTYyOKgbX3SCKeigMgomLJx6m5kTuDtU)uI)bfYP8cQUj3xH4ZNCoNRwRq6nT7NP6lmb1hobnqbNej6MCFqDsu9Qq6nT7NPNkyfP)yScWCsu9(kF4JPsL9z4aVb9JAtLR0sHSgY)e)y4KJFUATI0nmxRhCM6)7xtOUdjpxTwH0BA3pt1xycQpCcAGcobyojQEFLp8XuPY6uKlmZqARPeyp6LR0sh)C1AfPByUwp4m1)3VMqDheG5KO69v(WhtLklPByUwp4m1)3VMqUslD8ZvRvKUH5A9GZu)F)Ac1DqaMtIQ3x5dFmvQSi9M29Z0tfSCLw65Q1kKEt7(zQ(ctqDhKir3K7pL4FqHCkVGx3K7Rq85N7zOtIKZvRvKUH5A9GZu)F)Ac1DqaMtIQ3x5dFmvQSqFiAi9dyHglaZjr17R8HpMkv2rLjRlitpnYrUslD8OiOvBQambyjsHvEUzyIlSYtd5ShnCQWkpvzY6cYcBIGvF)QxbyojQEFLpmsxsrRmg6pPdbyojQEFLpmsxtLklsVPD)m9ublxPLEUAT6yUqARPHB69v3HKNRwRoMlK2AA4MEFfKr8AFqtjzbyojQEFLpmsxtLkl0hIgs)awOXYvAPNRwRoMlK2AA4MEF1Di55Q1QJ5cPTMgUP3xbzeV2h0uswaMtIQ3x5dJ01uPY(mCG3G(rTPYvAPJN7q9mCG3G(rTPQOiOvBQamNevVVYhgPRPsL1PixyMH0wtjWE0laZjr17R8Hr6AQuzhvMSUGm90ih5kTu91yOqMmXHPmnkeg0zkWj)uswIeDtU)uI)bfYP8cQUj3xH4ZNColpFqhv0tJCuG0gpkdNm3H6z4aVb9JAtvrrqR20K5oupdh4nOFuBQcYAi)t8JHLiz55d6OIEAKJAycdBKE5KJFUATcP30UFMQVWeu3HK6MC)Pe)dkKt5fuDtUVcXNFUDsu9QqRmgkPrq8nRi(huiNYR8t8yfG5KO69v(WiDnvQSKUH5A9GZu)F)AcbyojQEFLpmsxtLklsVPD)m9ublxPLEUATcP30UFMQVWeuqgXR9tU88bDurpnYrnmHHnsVSamNevVVYhgPRPsLfTYyOKgbX3SCKeigMgomLJx6m5kTu91yOqMmXHPmnkeg0zkWj)usoPUj3FkX)Gc5uEbv3K7Rq85NB0JobyojQEFLpmsxtLk7hmBOb0hKR0s1n5(tj(huiNYlO6MCFfIpVamNevVVYhgPRPsLf6drdPFal0y5kT0ZvRvrnqBnnMW0FGDO6dNGM0elrsUd1pb6dlBONg5OIIGwTPcWCsu9(kFyKUMkvwKEt7(z6PcwUsln3H6Na9HLn0tJCurrqR2ubyojQEFLpmsxtLk7OYK1fKPNg5ixPLU88bDurpnYr9tG(WYMK6MCFWNy0Lm3H6z4aVb9JAtvqgXR9bp4KFkjlaZjr17R8Hr6AQuzjtC0GoYlxPLo(5Q1kKEt7(zQ(ctqbzeV2xaMtIQ3x5dJ01uPY(mCG3G(rTPYvAPqwd5FIFmSamNevVVYhgPRPsLfTYyOKgbX3SCKeigMgomLJx6m5kTuDtU)uI)bfYP8cQUj3xH4ZNCoNRwRq6nT7NP6lmb1hobnqbNej6MCFqDsu9Qq6nT7NPNkyfP)yScWCsu9(kFyKUMkvwOpenK(bSqJfG5KO69v(WiDnvQSi9M29Z0tfSCLw65Q1kKEt7(zQ(ctqDhKir3K7d(5cDsKK7q9tG(WYg6ProQOiOvBQamNevVVYhgPRPsLDuzY6cY0tJCKR0sxE(GoQONg5OaPnEugozUd1ZWbEd6h1MQIIGwTPsKS88bDurpnYrnmHHnsVSejlpFqhv0tJCu)eOpSSjPUj3h8GdDcWeG5KO69vK8l9y6ot1xycYvAPKUn5E0QiDdZ16bNP()(1ekiJ41(GpXOtaMtIQ3xrY)uPY6lH)a6gkXng5kTus3MCpAvKUH5A9GZu)F)AcfKr8AFWNy0jaZjr17Ri5FQuz1fKpMUZYvAPKUn5E0QiDdZ16bNP()(1ekiJ41(GpXOtaMtIQ3xrY)uPYAQ0jXtt03CkcVHamNevVVIK)PsL9WWNHOvBQCLwkPBtUhTks3WCTEWzQ)VFnHcYiETp4hd0jrsuimnAAUyqNLybyojQEFfj)tLk7qhvVYvAPNRwRsVomx(sBn1Lxg2Xe1Di5CoxTwDy4Zq0QnvDhKi5C1A1X0DMQVWeu3bjsgh6ewfW2ygRejZH07Fr8JHvdDu9sBn9UhyLnCMQVWesQR0jbfYiETpOJXmjs0v6KGczeV2hu0pgJvIKX5)5LWksVzEFotnLM1nKWkepr3WKNRwRiDdZ16bNP()(1eQ7GamNevVVIK)PsL1)bMe0wtJjmL9udlxPLgomLdvU(WxcdEPJHamNevVVIK)PsL9(mTcgrU1ryP(pbeF5NcD5THusdDJCLw65Q1kegPHjqBn1CjvMMHSJ8Q7qsDLojOqgXR9bL0Tj3JwfcJ0WeOTMAUKktZq2rEfKr8A)PZaNejNRwRsVomx(sBn1Lxg2Xe1hobnPGlPUsNeuiJ41(Gs62K7rRk96WC5lT1uxEzyhtuqgXR9NIE0jrsMpxTwbD5THusdDdnZNRwRY9OvIeDLojOqgXR9bf9ZKi5C1A1OgAYGW1sH83RVewbzeV2pPUsNeuiJ41(Gs62K7rRAudnzq4APq(71xcRGmIx7pD2ykrY4HB4nuNcMFARPdqobfV(XW5K6kDsqHmIx7dkPBtUhTks3WCTEWzQ)VFnHcYiET)u0JUKNRwRiDdZ16bNP()(1ekiJ41(cWCsu9(ks(Nkv27Z0kye5whHLM6gM4gddF6P7vUslL0Tj3JwfcJ0WeOTMAUKktZq2rEfKr8AFjsc3WBOgvMSUGmTw99REv86hdNts62K7rRI0nmxRhCM6)7xtOGmIx7lrY48)8syfcJ0WeOTMAUKktZq2rEfINOByss3MCpAvKUH5A9GZu)F)AcfKr8AFbyojQEFfj)tLk79zAfmICRJWsD59N4q)P6EdARPd9igkatawIuyte)pVe(fG5KO69vK8pvQS6MCFotD5LHvW0d7iYvAPqVYugeEdLNZVQwWlpqxsDtUpO6MCFfIp)CJEWjrYCCsuGWuEzKIFWpl54HB4nuNcMFARPdqobfV(XWzjsCsuGWuEzKIFWJ(XMCoNRwRoMlK2AA4MEF1Di55Q1QJ5cPTMgUP3xbzeV2h8jw(PKSejJFUAT6yUqARPHB69v3HXkaZjr17Ri5FQuzpMUZ0wtJjmLxgjb5kT05mhOxzkdcVHYZ5xbzeV2h8Yd0jrY4qVYugeEdLNZVINV(4hRejZXjrbct5Lrk(b)SKJhUH3qDky(PTMoa5eu86hdNLiXjrbct5Lrk(bp6h7ytQBY9bv3K7Rq85fG5KO69vK8pvQSdxyPtO2u6X4FixPLoN5a9ktzq4nuEo)kiJ41(GFmqNejJd9ktzq4nuEo)kE(6JFSsKmhNefimLxgP4h8ZsoE4gEd1PG5N2A6aKtqXRFmCwIeNefimLxgP4h8OFSJnPUj3huDtUVcXNxaMtIQ3xrY)uPYMEDyU8L2AQlVmSJjcWCsu9(ks(NkvwynmyyAT0FWjSamNevVVIK)PsLL0lH3a6bNPAJJWYvAP6RXqHmzIdtzAuimOZKFkjlaZjr17Ri5FQuzJjm9UN(UzQUHewUsl9C1AfKjOz4)P6gsy1DqaMtIQ3xrY)uPYoQHMmiCTui)96lHfG5KO69vK8pvQSq2hQnLQnoc)YvAPHdt5qnHDtmrnqcWpMOtIKWHPCOMWUjMOgibOsrp6KijCykhQOqyA00bsqrp6aFIrNaSePWAUKklSYt0t0nuyLNSj3pFrge2Hj(ZcWCsu9(ks(Nkv2NHd8g0pQnvUslL)NxcRqyKgMaT1uZLuzAgYoYRq8eDdtcznK)j(XWjpxTwbsnWWNccVnI6oKCCs3MCpAvimsdtG2AQ5sQmndzh5vqgXR9fG5KO69vK8pvQSi9M29Z0tfSCLwk)pVewHWinmbARPMlPY0mKDKxH4j6gMCCs3MCpAvimsdtG2AQ5sQmndzh5vqgXR9fG5KO69vK8pvQSJktwxqMEAKJCLwk)pVewHWinmbARPMlPY0mKDKxH4j6gMuFngkKjtCyktJcHbDMcCYpLKtQBY9b1jr1RcP30UFMEQGvK(JKJt62K7rRcHrAyc0wtnxsLPzi7iVcYiETVamNevVVIK)PsLfHrAyc0wtnxsLPzi7iVCLwQUj3huNevVkKEt7(z6Pcwr6psEUATI0nmxRhCM6)7xtOUdcWeGjaZjr17Rig2bHLcIdl)yy5whHLsCiimLKHY1dsFokTCG4Mll1jrbct5Lrk(Lde3CzkBEwk4KJ0BUIQxPojkqykVmsXpOGtaMtIQ3xrmSdcpvQSi9M29Z0tfSCLwQlVmScwDmxiT10Wn9(kOVObE0LCoNRwRiDdZ16bNP()(1eQ7qY5CUATI0nmxRhCM6)7xtOGmIx7d6mf4KFkjlrY5Q1QJ5cPTMgUP3xDhsEUAT6yUqARPHB69vqgXR9bDMcCYpLKLi5C1AfPByUwp4m1)3VMqbzeV2p54NRwRoMlK2AA4MEFfKr8A)XowbyojQEFfXWoi8uPYI0BA3ptpvWYrsGyyA4WuoEPZKR0sZ85Q1kJh8g0HU(EvF4e0a)CCsuGWuEzKIFjsKhJnPUsNeuiJ41(G6KOaHP8Yif)YpLKfG5KO69ved7GWtLkRtrUWmdPTMsG9OxaMtIQ3xrmSdcpvQSKUH5A9GZu)F)AcbyojQEFfXWoi8uPYsCiiSCLwAUd1pb6dlBONg5OIIGwTPjhpCdVHAsczO)0tfSIx)y4Sej5ou)eOpSSHEAKJkkcA1MM0jrbct5Lrk(bp4eG5KO69ved7GWtLk7OYK1fKPNg5ixPLoE4gEdv6LHWYyCA4KOiVIx)y4Sej6RXqHmzIdtzAuimOPKSejqVYugeEdLNZVcYiETpOJrsOxzkdcVHYZ5xXZxF8cWCsu9(kIHDq4PsL9CdYegMGCLwkzIdt5NQHojQEDd4rVcCsKK7q9tG(WYg6ProQOiOvBQejKUn5E0QgvMSUGm90ihfKr8AFW7KOaHP8Yif)ZDkjlrsMpxTwDmDNPTMgtykVmsckiJ41(sKa9ktzq4nuEo)kiJ41(GcUKqVYugeEdLNZVINV(4fG5KO69ved7GWtLklsVPD)m9ublhjbIHPHdt54LotUslnZNRwRmEWBqh667v9Htqd8JPamNevVVIyyheEQuzjtC0GoYlaZjr17Rig2bHNkvw0kJHsAeeFZYrsGyyA4WuoEPZKR0s1n5(tj(huiNYlO6MCFfIpVamNevVVIyyheEQuzN4WHUx5kT0Wn8gQGHipT1uEt9ugH3qXRFmCwaMtIQ3xrmSdcpvQSehcclxPLgUH3qLEziSmgNgojkYR41pgolaZjr17Rig2bHNkv2ZnityycYvAPKUn5E0QgvMSUGm90ihfKr8AFWphNefimLxgP4xIeWnwbyojQEFfXWoi8uPYQn(IwTP0pGfASCLwQUj3FkX)Gc5uEbv3K7Rq85fG5KO69ved7GWtLk7OYK1fKPNg5ixPLM7qnQmzDbz6ProkiRH8pXpgwIKWn8gQrLjRlitRvF)QxfV(XWzbyojQEFfXWoi8uPY(mCG3G(rTPYrsGyyA4WuoEPZKR0spxTwbsnWWNccVnIcYojeG5KO69ved7GWtLklXHGWYvAPKUn5E0QgvMSUGm90ihfKr8AFWdIdl)yyfXHGWusgMie9cWCsu9(kIHDq4PsL9dMn0a6dcWCsu9(kIHDq4PsL9z4aVb9JAtLJKaXW0WHPC8sNjxPLcznK)j(XWjpxTwf1aT10yct)b2HQpCcAGM4KlpFqhv0tJCuG0gpkdlrcK1q(N4hdN0LxgwbRmEWBqh667vb9fnWJobyjsHf1wy)c5A8Gf277PSWQBOWI0BA3ptpvWcBdfwOpenK(bSqJf28fwBQWkp)hysiSTwyJjSWMi2tnSCclPhsqyzNmryBc5cH8syHT1cBmHfwNevVcRVzH1hg4nlSu2tnSWgTWgtyH1jr1RWUocReG5KO69ved7GWtLklsVPD)m9ublhjbIHPHdt54LotaMtIQ3xrmSdcpvQSqFiAi9dyHglhjbIHPHdt54LotaMamNevVV6dPOvgd9N0HamNevVV6JPsLDIdh6ELR0sd3WBOcgI80wt5n1tzeEdfV(XWzbyojQEF1htLkR24lA1Ms)awOXYvAP6MC)Pe)dkKt5fuDtUVcXNxaMtIQ3x9XuPYc9HOH0pGfASCLw65Q1ks3WCTEWzQ)VFnH6oKCoNRwRiDdZ16bNP()(1ekiJ41(Gotbo5NsYsKCUAT6yUqARPHB69v3HKNRwRoMlK2AA4MEFfKr8AFqNPaN8tj5XkalrkSO2c7xixJhSWEFpLfwDdfwKEt7(z6PcwyBOWc9HOH0pGfASWMVWAtfw55)atcHT1cBmHf2eXEQHLtyj9qccl7KjcBtixiKxclSTwyJjSW6KO6vy9nlS(WaVzHLYEQHf2Of2yclSojQEf21ryLamNevVV6JPsLfP30UFMEQGLR0spxTwr6gMR1dot9)9Rju3HKZ5C1AfPByUwp4m1)3VMqbzeV2h0zkWj)uswIKZvRvhZfsBnnCtVV6oK8C1A1XCH0wtd307RGmIx7d6mf4KFkjpwbyojQEF1htLklALXqjncIVz5ijqmmnCykhV0zYvAP6MC)Pe)dkKt5fuDtUVcXNxaMtIQ3x9XuPY(mCG3G(rTPYvAPNRwRaPgy4tbH3grDhsEUATcKAGHpfeEBefKr8AFqNj)uswaMtIQ3x9XuPY(bZgAa9b5kTuDtU)uI)bfYP8cQUj3xH4ZlaZjr17R(yQuzhvMSUGm90ih5kTuDtU)uI)bfYP8cQUj3xH4ZNeYAi)t8JHtQVgdfYKjomLPrHWGMsYjh)C1AfcJ0WeOTMAUKktZq2rE1DqIeDtU)uI)bfYP8cQUj3xH4ZNCoJN7qnQmzDbz6ProQOiOvBAY5m(5Q1ks3WCTEWzQ)VFnH6oirY5Q1kKEt7(zQ(ctq9Htqd0zsKefctJMMlg0zJPejJN7qnQmzDbz6ProQOiOvBAsxEzyfSAuzYmC5)P)fcsbIBuqFrd8OBSJn54NRwRqyKgMaT1uZLuzAgYoYRUdcWCsu9(QpMkv2NHd8g0pQnvUsl9C1Afi1adFki82iQ7qYChQNHd8g0pQnvbzeV2h05s(PKSej5oupdh4nOFuBQcYAi)t8JHto(5Q1ks3WCTEWzQ)VFnH6oiaZjr17R(yQuzDkYfMziT1ucSh9YvAPJFUATI0nmxRhCM6)7xtOUdcWCsu9(QpMkvws3WCTEWzQ)VFnHCLw64NRwRiDdZ16bNP()(1eQ7GamNevVV6JPsLfP30UFMEQGLR0spxTwH0BA3pt1xycQ7Gej6MC)Pe)dkKt5f86MCFfIp)CJE0LmCdVHcKAGHpfeEBefV(XWzjs0n5(tj(huiNYl41n5(keF(5EwYWn8gQGHipT1uEt9ugH3qXRFmCwIKZvRvKUH5A9GZu)F)Ac1DqaMtIQ3x9XuPYc9HOH0pGfASamNevVV6JPsLDuzY6cY0tJCKR0sZDOgvMSUGm90ihfK1q(N4hdlaZjr17R(yQuzFgoWBq)O2u5kT0ZvRvGudm8PGWBJOUdcWeGLifw5PktwxqwyteS67x9kaZjr17RgPlPOvgd9N0HamNevVVAKUMkv2joCO7vUslv3K7pL4FqHCkVGQBY9vi(8jd3WBOcgI80wt5n1tzeEdfV(XWzbyojQEF1iDnvQSi9M29Z0tfSCLw65Q1QJ5cPTMgUP3xDhsEUAT6yUqARPHB69vqgXR9bnLKfG5KO69vJ01uPYc9HOH0pGfASCLw65Q1QJ5cPTMgUP3xDhsEUAT6yUqARPHB69vqgXR9bnLKfG5KO69vJ01uPY(mCG3G(rTPYvAPNRwRaPgy4tbH3grDhsEUATcKAGHpfeEBefKr8AFqNPaN8tjzjsgp3H6z4aVb9JAtvrrqR2ubyojQEF1iDnvQSJktwxqMEAKJCLwQ(AmuitM4WuMgfcd6mf4KFkjNu3K7pL4FqHCkVGQBY9vi(8sKmNLNpOJk6ProkqAJhLHtM7q9mCG3G(rTPQOiOvBAYChQNHd8g0pQnvbznK)j(XWsKS88bDurpnYrnmHHnsVCYXpxTwH0BA3pt1xycQ7qsDtU)uI)bfYP8cQUj3xH4Zp3ojQEvOvgdL0ii(Mve)dkKt5v(jEScWCsu9(Qr6AQuzrRmgkPrq8nlhjbIHPHdt54LotUslv3K7pL4FqHCkVGQBY9vi(8ZTUj3xb5uEfG5KO69vJ01uPY6uKlmZqARPeyp6fG5KO69vJ01uPY(bZgAa9b5kTuDtU)uI)bfYP8cQUj3xH4ZlaZjr17RgPRPsLDuzY6cY0tJCKR0s1xJHczYehMY0OqyqNPaN8tjzbyojQEF1iDnvQSKUH5A9GZu)F)AcbyojQEF1iDnvQSpdh4nOFuBQCLw65Q1kqQbg(uq4Tru3HK5oupdh4nOFuBQcYiETpOZL8tjzbyojQEF1iDnvQSi9M29Z0tfSCLwAUd1pb6dlBONg5OIIGwTPsKCUATcP30UFMQVWeuF4e0KcobyojQEF1iDnvQSJktwxqMEAKJCLw6YZh0rf90ih1pb6dlBsM7q9mCG3G(rTPkiJ41(GhCYpLKfG5KO69vJ01uPY(mCG3G(rTPYvAPqwd5FIFmSamNevVVAKUMkvwYehnOJ8YvAPJFUATcP30UFMQVWeuqgXR9fG5KO69vJ01uPYI0BA3ptpvWcWCsu9(Qr6AQuzH(q0q6hWcnwaMtIQ3xnsxtLk7ZWbEd6h1MkxPLEUATcKAGHpfeEBe1DqaMtIQ3xnsxtLk7OYK1fKPNg5ixPLU88bDurpnYrbsB8OmCYChQNHd8g0pQnvffbTAtLiz55d6OIEAKJAycdBKEzjswE(GoQONg5O(jqFyzdoWbgd]] )
    end

end