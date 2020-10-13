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
        spec:RegisterPack( "Survival", 20201012.9, [[dye15aqivkEKqvYLqLuTjvQ(eQKKrjK0PeQyvcvPELqmluP2LGFPsmmHehdLQLbP6zOuAAOuORjuvBdLI(MkL04uPu5CQuI1jufMhK4EOI9HkXbvPuLfIs8quk4JOsImsujHojQKuRuImtvkLDkr9tujrTuujbpvstvL0xvPuv7vv)LudwKdtzXq8yOMSOUmYMvXNjQrluoTuRgvs51sWSj52OQDR0VvmCICCHkTCGNdA6uDDuSDiPVdPmEHuNhL06fQIMVeA)e(z)V(1S50xg9OGEuypkSJEaD2zl6S9w(QZQe9vjdxWKPVUgp91kda1gvt9vjJv1y5)6xHddatFnM7sW4XLlYThJbjGh(lWMNrzEplgyh)cS5Xx(kctRCU69r(A2C6lJEuqpkShf2rpGo7SfD2YMF1y8yd4R1MNrzEplBayh)RX6CM2h5RzcI)A8sKQmauBunLiXvKzDcikfVejUYyFqiGiDRClsOhf0JIOKOu8sKUncvsjsCrKIFucFv1qh(x)AMogJY)RFz2)RF1WEp7x5zINXtf9vAnefLFwE)lJ(F9Rg27z)kdK0Tt8WVsRHOO8ZY7Fz2(x)kTgIIYplF1WEp7xXMsPnS3ZQvn0)QQHUEnE6R4m89VmB8V(vAnefLFw(kg0obA7Rg2BujnTeFtqrcfrc9VAyVN9RytP0g27z1Qg6Fv1qxVgp9vO)(xo()1VsRHOO8ZYxXG2jqBF1WEJkPPL4BcksCrKy)Rg27z)k2ukTH9EwTQH(xvn01RXtFfRidv69VmB(x)QH9E2VAaSTK2haGw)R0Aikk)S8(x(w)RF1WEp7xrmz9C0oOXfGFLwdrr5NL3F)RyfzOs)1Vm7)1VsRHOO8ZYxXG2jqBF1nfTEWjapuphnTYMmXtRhO1quuwKUlsNbZafjuePZGzGbEl6VAyVN9RXmG0m77Fz0)RF1WEp7xrRvznuQbTd)kTgIIYplV)Lz7F9R0Aikk)S8vmODc02xbmlDgGmfGdJ6mazst8ieagO4Y0ssuwKUlsUb0oWKcaI36fksOisY4SiDxKWZOYdAB4OmafaeV1luKqrKKX5VAyVN9RUb0oWKE)lZg)RFLwdrr5NLVIbTtG2(kGzPZaKPaCyuNbitAIhHaWafxMwsIYI0DrYnG2bMuGr6Rg27z)6rza69VC8)RF1WEp7xbeCwZ7vwBaWG2xP1quu(z59VmB(x)kTgIIYplFfdANaT91dJsPbeoMbKjT38KiHIijJZF1WEp7xrRv5tdinYWJ8(x(w)RF1WEp7xXXScaJh(vAnefLFwE)lF7(RFLwdrr5NLVIbTtG2(AE8amgWKwsPrgEKG34c9kls3fPOks5Xd96eynLgrruUx5a0nCbrcfrcDrQyrrkpEagdyslP0idpsaq8wVqrcfrsgNfP48vd79SFfHXXXiaRV)LVL)6xP1quu(z5Ryq7eOTVMhpaJbmPLuAKHhj4nUqVYF1WEp7xXgav69Vm7r5V(vAnefLFw(kg0obA7RNbZafPiIe2GUgqY0ksOisNbZad8w0F1WEp7xZK5X04ywbGX)(xMD2)RF1WEp7xXZaY9AoL1geAmk)R0Aikk)S8(xMD0)RFLwdrr5NLVIbTtG2(koMbKjO(amS3ZAkrIlIe6H4ls3fj8mQ8G2gqRv5tdinYWJeomkLgq4ygqM0EZtIexejOePuA3aYKdfPlIe6F1WEp7xryCCmcW67Fz2z7F9R0Aikk)S8vmODc02xpdMbksrejSbDnGKPvKqrKodMbg4TO)QH9E2VEu2wOxzn0bDb69Vm7SX)6xP1quu(z5Rg27z)AHwP04HN328xXG2jqBF9mygOifrKWg01asMwrcfr6mygyG3IwKUlshgLsdiCmditAV5jrcfrsgN)kMvSI0UbKjh(Lz)9Vm7X)V(vAnefLFw(kg0obA7R3is5XdO1Q8PbKgz4rcEJl0R8xnS3Z(v0Av(0asJm8iV)LzNn)RFLwdrr5NLVIbTtG2(AufPBePLI21O1AKHhjaJbmPLuIuXII0nIKBkA9aATkFAaP79Wa7zd0AikklsXrKUls4zu5bTnGwRYNgqAKHhjCyuknGWXmGmP9MNejUisqjsP0UbKjhksxej0)QH9E2VIW44yeG13)YSFR)1VsRHOO8ZYxXG2jqBFfpJkpOTb0Av(0asJm8iHdJsPbeoMbKjT38KiXfrckrkL2nGm5qr6IiH(xnS3Z(vSbqLE)lZ(T7V(vd79SFTqRuAySX)kTgIIYplV)Lz)w(RF1WEp7xpkJvkRHXg)R0Aikk)S8(xg9O8x)QH9E2VAAEgqMa65OXGbn4xP1quu(z59Vm6S)x)kTgIIYplFfdANaT91BejaZsNbitHLGWELrZaSc1oWKK6vwBssgWCgyGIltljrzrQyrr6mygOifrKWg01asMwrkIiHE8fjuePZGzGbEl6VAyVN9RqNiL2bM07Fz0r)V(vAnefLFw(QH9E2VcjGeTUg69k)vmODc02xb0bqWygIIeP7IKBkA9qmwZadQrANc0Aikk)vmRyfPDdito8lZ(7Fz0z7F9Rg27z)k2aOsFLwdrr5NL3)YOZg)RFLwdrr5NLVAyVN9RfALsJhEEBZFfdANaT91ZGzGIuercBqxdizAfjuePZGzGbEl6VIzfRiTBazYHFz2F)lJE8)RFLwdrr5NLVAyVN9RqcirRRHEVYFfdANaT9vaDaemMHOir6Uifvr6grYnfTEaPbzOEoAjaXAGwdrrzrQyrr6grcH5Cc4za5EnNYAdcngLhyKeP4is3fPOks3isaMLodqMcawvwbOBQceaQXZEgMn3RSg6GUabduCzAjjklsflkslfTRrR1idpsa1rzERirQyrrYnfTEaHXXXiaRbAnefLfP4isflksimNta1wIaqnQ0o8bgPVIzfRiTBazYHFz2F)lJoB(x)kTgIIYplF1WEp7x5NvEgiPrAN(kg0obA7RzcH5CckZP11stdNv3lxJWEpBa6gUGiXfr6w(kMvSI0UbKjh(Lz)9Vm636F9R0Aikk)S8vd79SFfys(a0qh0fOVIbTtG2(AMqyoNGYCADT00Wz19Y1iS3ZgGUHlisCrKULVIzfRiTBazYHFz2F)lJ(T7V(vAnefLFw(QH9E2VcjGeTUg69k)vmODc02xVrKCtrRhqAqgQNJwcqSgO1quuwKUls3isUPO1dO2seaQrL2HpqRHOOSiDxKUrKamlDgGmfuMtRRLMgoRUxUgH9baduCzAjjkls3fPBejaZsNbitbaRkRa0nvbca14zpdZM7vwdDqxGGbkUmTKeL)kMvSI0UbKjh(Lz)9Vm63YF9R0Aikk)S8vd79SFLFw5zGKgPD6RywXks7gqMC4xM93)YSnk)1VsRHOO8ZYxnS3Z(vGj5dqdDqxG(kMvSI0UbKjh(Lz)93)kod)RFz2)RFLwdrr5NLVIbTtG2(kEgvEqBd4za5EnNYAdcngLhaeV1luK4IiX2O8vd79SFfrntwFyaS((xg9)6xP1quu(z5Ryq7eOTVINrLh02aEgqUxZPS2GqJr5baXB9cfjUisSnkF1WEp7xTftqhykn2uQ3)YS9V(vAnefLFw(kg0obA7R4zu5bTnGNbK71CkRni0yuEaq8wVqrIlIeBJYxnS3Z(1tdie1m53)YSX)6xnS3Z(vvlhZHAUgtwMNw)R0Aikk)S8(xo()1VsRHOO8ZYxXG2jqBFfpJkpOTb8mGCVMtzTbHgJYdaI36fksCrKyZOisflksEZtAF05Mejuej2z7xnS3Z(vecajqHELF)lZM)1VsRHOO8ZYxXG2jqBF90YXCnG4TEHIekIe6SPivSOiHWCob8mGCVMtzTbHgJYdmsF1WEp7xLgVN99V8T(x)kTgIIYplFfdANaT9v3aYKhYn0TftIex4isS5xnS3Z(vdkryxphThJ0KjRO3F)Rq)V(Lz)V(vAnefLFw(kg0obA7RUPO1dob4H65OPv2KjEA9aTgIIYI0Dr6mygOiHIiDgmdmWBr)vd79SFnMbKMzF)lJ(F9R0Aikk)S8vmODc02xpdMbksrejSbDnGKPvKqrKodMbg4TOfP7IecZ5e8wsphThJ0qjYabOB4cIekIeBfP7I0nIKBkA9GPKIzAjaLnFabAnefL)QH9E2VwOvknE45Tn)(xMT)1VsRHOO8ZYxXG2jqBFnpEagdyslP0idpsWBCHELfP7IuufP84HEDcSMsJOik3RCa6gUGiHIiHUivSOiLhpaJbmPLuAKHhjaiERxOiHIijJZIuCePIffjeMZjWpR8mqsFyaSgyKeP7IecZ5e4NvEgiPpmawdaI36fksOisNbZafPlIeBJIifVfjzCwKkwuKCtrRhqAqgQNJwcqSgO1quuwKUlsimNtapdi3R5uwBqOXO8aJKiDxKqyoNaEgqUxZPS2GqJr5baXB9cfjuejzC(Rg27z)k)SYZajns707Fz24F9R0Aikk)S8vmODc02xZJhGXaM0sknYWJe8gxOxzr6UifvrkpEOxNaRP0ikIY9khGUHlisOisOlsflks5XdWyatAjLgz4rcaI36fksOisY4SifhrQyrrYnfTEaPbzOEoAjaXAGwdrrzr6UiHWCob8mGCVMtzTbHgJYdmsI0DrcH5Cc4za5EnNYAdcngLhaeV1luKqrKKX5VAyVN9RatYhGg6GUa9(xo()1VAyVN9RO1QSgk1G2HFLwdrr5NL3)YS5F9R0Aikk)S8vmODc02xbmlDgGmfGdJ6mazst8ieagO4Y0ssuwKUlsUb0oWKcaI36fksOisY4SiDxKWZOYdAB4OmafaeV1luKqrKKX5VAyVN9RUb0oWKE)lFR)1VsRHOO8ZYxXG2jqBFfWS0zaYuaomQZaKjnXJqayGIltljrzr6Ui5gq7atkWi9vd79SF9Oma9(x(29x)QH9E2VINbK71CkRni0yu(xP1quu(z59V8T8x)QH9E2Vci4SM3RS2aGbTVsRHOO8ZY7Fz2JYF9Rg27z)6rzSsznm24FLwdrr5NL3)YSZ(F9R0Aikk)S8vmODc02xpdMbksrejSbDnGKPvKqrKodMbg4TO)QH9E2VMjZJPXXScaJ)9Vm7O)x)QH9E2VwOvknm24FLwdrr5NL3)YSZ2)6xP1quu(z5Ryq7eOTVEgmduKIisyd6AajtRiHIiDgmdmWBr)vd79SF9OSTqVYAOd6c07Fz2zJ)1VsRHOO8ZYxXG2jqBF9mygOifrKWg01asMwrcfr6mygyG3IwKUlsimNtWBj9C0EmsdLideGUHlisOisSvKUlshgLsdiCmditAV5jrcfrcDrkElsY48xnS3Z(1cTsPXdpVT53)YSh))6xnS3Z(vCmRaW4HFLwdrr5NL3)YSZM)1VAyVN9RMMNbKjGEoAmyqd(vAnefLFwE)lZ(T(x)kTgIIYplFfdANaT91LI21O1AKHhjG6OmVvKiDxKYJhGeqIwxd9ELdEJl0RSiDxKYJhGeqIwxd9ELda6aiymdrrF1WEp7xrRv5tdinYWJ8(xM9B3F9R0Aikk)S8vmODc02xb0bqWygIIeP7IuufjeMZjWpR8mqsFyaSgGUHlisOisXxKkwuKUrKCtrRh4NvEgiPrANc0AikklsXrKUlsrvKUrKqyoNaEgqUxZPS2GqJr5bgjrQyrr6grYnfTEaPbzOEoAjaXAGwdrrzrkoIuXIIecZ5eqTLiauJkTdFGr6Rg27z)kKas06AO3R87Fz2VL)6xP1quu(z5Ryq7eOTVUu0UgTwJm8ibymGjTKsKUlsNbZafjUisSzuePIffPLI21O1AKHhjifJad)SKiDxKIQiDgmduKIisyd6AajtRifrKmS3Zgk0kLgp882Mdyd6AajtRifVfj2ksOisNbZad8w0IuXIIKBkA9a)SYZajns7uGwdrrzr6UiDJiHWCob(zLNbs6ddG1aJKifhrQyrr6grkpEaTwLpnG0idpsWBCHELfP7I0HrP0achZaYK2BEsKqrKKX5VAyVN9RO1Q8PbKgz4rE)lJEu(RFLwdrr5NLVIbTtG2(6zWmqrkIiHnORbKmTIekI0zWmWaVfTiDxKqyoNG3s65O9yKgkrgiaDdxqKqrKy7xnS3Z(1cTsPXdpVT53)YOZ(F9R0Aikk)S8vmODc02xVrKamlDgGmfwcc7vgndWku7atsQxzTjjzaZzGbkUmTKeLfPIffPZGzGIuercBqxdizAfPiIe6XxKqrKodMbg4TO)QH9E2VcDIuAhysV)Lrh9)6xP1quu(z5Ryq7eOTVcyw6mazkSee2RmAgGvO2bMKuVYAtsYaMZaduCzAjjkls3fPZGzGIuercBqxdizAfPiIe6XxKqrKodMbg4TO)QH9E2V6gq7at69Vm6S9V(vAnefLFw(kg0obA7RaMLodqMclbH9kJMbyfQDGjj1RS2KKmG5mWafxMwsIYI0Dr6mygOifrKWg01asMwrkIiHE8fjuePZGzGbEl6VAyVN9RharXZEL1oWKE)lJoB8V(vAnefLFw(kg0obA7RimNtGFw5zGK(WaynWijsflksNbZafPiIKH9E2qHwP04HN32CaBqxdizAfjUisNbZad8w0F1WEp7x5NvEgiPrANE)lJE8)RFLwdrr5NLVIbTtG2(6nI0sr7A0AnYWJeGXaM0skrQyrrcH5CcElPNJ2JrAOezGa0nCbrIlIe6IuXII0zWmqrkIizyVNnuOvknE45TnhWg01asMwrIlI0zWmWaVf9xnS3Z(vGj5dqdDqxGE)lJoB(x)kTgIIYplFfdANaT9veMZj4TKEoApgPHsKbcq3Wfejuej2(vd79SFTqRuA8WZBB(9Vm636F9R0Aikk)S8vmODc02xVrKYJhqRv5tdinYWJe8gxOxzr6UiDJi5MIwpGwRYNgq6EpmWE2aTgIIYF1WEp7xrRv5tdinYWJ8(7Fvcq4HhX8)6xM9)6xP1quu(z5Ryq7eOTVcyw6mazkahg1zaYKM4riamqXLPLKO8xnS3Z(v3aAhysV)Lr)V(vd79SFf6eP0oWK(kTgIIYplV)Lz7F9Rg27z)kEgqUxZPS2GqJr5FLwdrr5NL3)YSX)6xP1quu(z5Rg27z)Q049SFnZ6A8nwlbiPX)k7V)(7Ffvca7z)YOhf0Jc7rHD0d3YxrZaBVYWVE7F7XvOmxDzUsXdrsKUgJePMxAaUiDgGiXvbDUkrcqXLPbuwKGdpjsgJp8MtzrchZwzcgeLUTEjrITXdrInmlQeWPSivBE2GibzDDlArIRls(is3gJjs5g1g2ZksJebmFaIuuVehrkQShDCcIsIs3(3ECfkZvxMRu8qKePRXirQ5LgGlsNbisCvyfzOsCvIeGIltdOSibhEsKmgF4nNYIeoMTYemikDB9sIe7Ohpej2WSOsaNYIuT5zdIeK11TOfjUUi5JiDBmMiLBuBypRinseW8bisr9sCePOYE0XjikDB9sIe7Sz8qKydZIkbCkls1MNnisqwx3IwK46IKpI0TXyIuUrTH9SI0iraZhGif1lXrKIk7rhNGO0T1ljsSFRXdrInmlQeWPSivBE2GibzDDlArIRls(is3gJjs5g1g2ZksJebmFaIuuVehrkQShDCcIsIsC18sdWPSifFrYWEpRiPAOddIsFfkr4Vm6Xp(FvcmNwrFnEjsvgaQnQMsK4kYSobeLIxIexzSpieqKUvUfj0Jc6rrusukEjs3gHkPejUisXpkbrjrjd79SWGeGWdpI5r4CXnG2bMe39HdGzPZaKPaCyuNbitAIhHaWafxMwsIYIsg27zHbjaHhEeZJW5c0jsPDGjjkzyVNfgKaeE4rmpcNl4za5EnNYAdcngLlkzyVNfgKaeE4rmpcNlsJ3ZYDM114BSwcqsJZHDrjrjd79SWaodJW5cIAMS(WayL7(WbpJkpOTb8mGCVMtzTbHgJYdaI36fYf2gfrjd79SWaodJW5ITyc6atPXMsXDF4GNrLh02aEgqUxZPS2GqJr5baXB9c5cBJIOKH9EwyaNHr4C50acrntM7(WbpJkpOTb8mGCVMtzTbHgJYdaI36fYf2gfrjd79SWaodJW5IQLJ5qnxJjlZtRlkzyVNfgWzyeoxqiaKaf6vM7(WbpJkpOTb8mGCVMtzTbHgJYdaI36fYf2mkfl6npP9rNBcf2zROKH9EwyaNHr4CrA8EwU7dNtlhZ1aI36fIc6SzXIimNtapdi3R5uwBqOXO8aJKOKH9EwyaNHr4CXGse21Zr7XinzYkI7(WXnGm5HCdDBXex4WMIsIsg27zHr4CHNjEgpvKOKH9EwyeoxyGKUDIhkkzyVNfgHZfSPuAd79SAvdDUxJN4GZqrjd79SWiCUGnLsByVNvRAOZ9A8ehOZDF4yyVrL00s8nbrbDrjd79SWiCUGnLsByVNvRAOZ9A8ehSImujU7dhd7nQKMwIVjixyxuYWEplmcNlgaBlP9baO1fLmS3ZcJW5cIjRNJ2bnUauusuYWEplma9iCUeZasZSC3hoUPO1dob4H65OPv2KjEA9aTgIIY3pdMbIYzWmWaVfTOKH9Ewya6r4CPqRuA8WZBBM7(W5mygyeSbDnGKPfLZGzGbEl67imNtWBj9C0EmsdLideGUHlGcBVFJBkA9GPKIzAjaLnFabAnefLfLmS3ZcdqpcNl8ZkpdK0iTtC3ho5XdWyatAjLgz4rcEJl0R89OMhp0RtG1uAefr5ELdq3Wfqb9IfZJhGXaM0sknYWJeaeV1lefzCooflIWCob(zLNbs6ddG1aJ0DeMZjWpR8mqsFyaSgaeV1leLZGzGCD2gL4TmoxSOBkA9asdYq9C0saI1aTgIIY3ryoNaEgqUxZPS2GqJr5bgP7imNtapdi3R5uwBqOXO8aG4TEHOiJZIsg27zHbOhHZfGj5dqdDqxG4UpCYJhGXaM0sknYWJe8gxOx57rnpEOxNaRP0ikIY9khGUHlGc6flMhpaJbmPLuAKHhjaiERxikY4CCkw0nfTEaPbzOEoAjaXAGwdrr57imNtapdi3R5uwBqOXO8aJ0DeMZjGNbK71CkRni0yuEaq8wVquKXzrjd79SWa0JW5cATkRHsnODOOKH9Ewya6r4CXnG2bMe39HdGzPZaKPaCyuNbitAIhHaWafxMwsIY3DdODGjfaeV1lefzC(oEgvEqBdhLbOaG4TEHOiJZIsg27zHbOhHZLJYae39HdGzPZaKPaCyuNbitAIhHaWafxMwsIY3DdODGjfyKeLmS3ZcdqpcNl4za5EnNYAdcngLlkzyVNfgGEeoxaeCwZ7vwBaWGMOKH9Ewya6r4C5OmwPSggBCrjd79SWa0JW5sMmpMghZkamEU7dNZGzGrWg01asMwuodMbg4TOfLmS3ZcdqpcNlfALsdJnUOKH9Ewya6r4C5OSTqVYAOd6ce39HZzWmWiyd6AajtlkNbZad8w0Isg27zHbOhHZLcTsPXdpVTzU7dNZGzGrWg01asMwuodMbg4TOVJWCobVL0Zr7XinuImqa6gUakS9(HrP0achZaYK2BEcf0J3Y4SOKH9Ewya6r4CbhZkamEOOKH9Ewya6r4CX08mGmb0ZrJbdAqrjd79SWa0JW5cATkFAaPrgEeU7dNLI21O1AKHhjG6OmVv0984bibKO11qVx5G34c9kFppEasajADn07voaOdGGXmefjkzyVNfgGEeoxGeqIwxd9EL5UpCa0bqWygIIUhveMZjWpR8mqsFyaSgGUHlGs8lw8g3u06b(zLNbsAK2PaTgIIYX5EuVbH5Cc4za5EnNYAdcngLhyKkw8g3u06bKgKH65OLaeRbAnefLJtXIimNta1wIaqnQ0o8bgjrjd79SWa0JW5cATkFAaPrgEeU7dNLI21O1AKHhjaJbmPLu3pdMbYf2mkflUu0UgTwJm8ibPyey4NLUh1ZGzGrWg01asM2ig27zdfALsJhEEBZbSbDnGKPnEZwuodMbg4TOlw0nfTEGFw5zGKgPDkqRHOO89BqyoNa)SYZaj9HbWAGrkoflEtE8aATkFAaPrgEKG34c9kF)WOuAaHJzazs7npHImolkzyVNfgGEeoxk0kLgp882M5UpCodMbgbBqxdizAr5mygyG3I(ocZ5e8wsphThJ0qjYabOB4cOWwrjd79SWa0JW5c0jsPDGjXDF4CdGzPZaKPWsqyVYOzawHAhyss9kRnjjdyodmqXLPLKOCXINbZaJGnORbKmTrqp(OCgmdmWBrlkzyVNfgGEeoxCdODGjXDF4ayw6mazkSee2RmAgGvO2bMKuVYAtsYaMZaduCzAjjkF)mygyeSbDnGKPnc6XhLZGzGbElArjd79SWa0JW5Ybqu8SxzTdmjU7dhaZsNbitHLGWELrZaSc1oWKK6vwBssgWCgyGIltljr57NbZaJGnORbKmTrqp(OCgmdmWBrlkzyVNfgGEeox4NvEgiPrAN4UpCqyoNa)SYZaj9HbWAGrQyXZGzGrmS3Zgk0kLgp882Mdyd6AajtlxodMbg4TOfLmS3ZcdqpcNlatYhGg6GUaXDF4CZsr7A0AnYWJeGXaM0sQIfryoNG3s65O9yKgkrgiaDdxGlOxS4zWmWig27zdfALsJhEEBZbSbDnGKPLlNbZad8w0Isg27zHbOhHZLcTsPXdpVTzU7dheMZj4TKEoApgPHsKbcq3WfqHTIsg27zHbOhHZf0Av(0asJm8iC3ho3KhpGwRYNgqAKHhj4nUqVY3VXnfTEaTwLpnG09EyG9SbAnefLfLeLmS3ZcdyfzOsr4CjMbKMz5UpCCtrRhCcWd1ZrtRSjt806bAnefLVFgmdeLZGzGbElArjd79SWawrgQueoxqRvznuQbTdfLmS3ZcdyfzOsr4CXnG2bMe39HdGzPZaKPaCyuNbitAIhHaWafxMwsIY3DdODGjfaeV1lefzC(oEgvEqBdhLbOaG4TEHOiJZIsg27zHbSImuPiCUCugG4UpCamlDgGmfGdJ6mazst8ieagO4Y0ssu(UBaTdmPaJKOKH9EwyaRidvkcNlacoR59kRnayqtuYWEplmGvKHkfHZf0Av(0asJm8iC3hohgLsdiCmditAV5juKXzrjd79SWawrgQueoxWXScaJhkkzyVNfgWkYqLIW5ccJJJraw5UpCYJhGXaM0sknYWJe8gxOx57rnpEOxNaRP0ikIY9khGUHlGc6flMhpaJbmPLuAKHhjaiERxikY4CCeLmS3ZcdyfzOsr4CbBaujU7dN84bymGjTKsJm8ibVXf6vwuYWEplmGvKHkfHZLmzEmnoMvay8C3hoNbZaJGnORbKmTOCgmdmWBrlkzyVNfgWkYqLIW5cEgqUxZPS2GqJr5Isg27zHbSImuPiCUGW44yeGvU7dhCmditq9byyVN1uCb9q8VJNrLh02aATkFAaPrgEKWHrP0achZaYK2BEIlqjsP0UbKjhY1rxuYWEplmGvKHkfHZLJY2c9kRHoOlqC3hoNbZaJGnORbKmTOCgmdmWBrlkzyVNfgWkYqLIW5sHwP04HN32m3ywXks7gqMCih25UpCodMbgbBqxdizAr5mygyG3I((HrP0achZaYK2BEcfzCwuYWEplmGvKHkfHZf0Av(0asJm8iC3ho3KhpGwRYNgqAKHhj4nUqVYIsg27zHbSImuPiCUGW44yeGvU7dNOEZsr7A0AnYWJeGXaM0sQIfVXnfTEaTwLpnG09EyG9SbAnefLJZD8mQ8G2gqRv5tdinYWJeomkLgq4ygqM0EZtCbkrkL2nGm5qUo6Isg27zHbSImuPiCUGnaQe39HdEgvEqBdO1Q8PbKgz4rchgLsdiCmditAV5jUaLiLs7gqMCixhDrjd79SWawrgQueoxk0kLggBCrjd79SWawrgQueoxokJvkRHXgxuYWEplmGvKHkfHZftZZaYeqphngmObfLmS3ZcdyfzOsr4Cb6eP0oWK4UpCUbWS0zaYuyjiSxz0maRqTdmjPEL1MKKbmNbgO4Y0ssuUyXZGzGrWg01asM2iOhFuodMbg4TOfLmS3ZcdyfzOsr4CbsajADn07vMBmRyfPDditoKd7C3hoa6aiymdrr3DtrRhIXAgyqns7uGwdrrzrjd79SWawrgQueoxWgavsuYWEplmGvKHkfHZLcTsPXdpVTzUXSIvK2nGm5qoSZDF4Cgmdmc2GUgqY0IYzWmWaVfTOKH9EwyaRidvkcNlqcirRRHEVYCJzfRiTBazYHCyN7(WbqhabJzik6EuVXnfTEaPbzOEoAjaXAGwdrr5IfVbH5Cc4za5EnNYAdcngLhyKIZ9OEdGzPZaKPaGvLva6MQabGA8SNHzZ9kRHoOlqWafxMwsIYflUu0UgTwJm8ibuhL5TIkw0nfTEaHXXXiaRbAnefLJtXIimNta1wIaqnQ0o8bgjrjd79SWawrgQueox4NvEgiPrAN4gZkwrA3aYKd5Wo39HtMqyoNGYCADT00Wz19Y1iS3ZgGUHlWLBruYWEplmGvKHkfHZfGj5dqdDqxG4gZkwrA3aYKd5Wo39HtMqyoNGYCADT00Wz19Y1iS3ZgGUHlWLBruYWEplmGvKHkfHZfibKO11qVxzUXSIvK2nGm5qoSZDF4CJBkA9asdYq9C0saI1aTgIIY3VXnfTEa1wIaqnQ0o8bAnefLVFdGzPZaKPGYCADT00Wz19Y1iSpayGIltljr573ayw6mazkayvzfGUPkqaOgp7zy2CVYAOd6cemqXLPLKOSOKH9EwyaRidvkcNl8ZkpdK0iTtCJzfRiTBazYHCyxuYWEplmGvKHkfHZfGj5dqdDqxG4gZkwrA3aYKd5W(7V)pa]] )
    else
        spec:RegisterPack( "Survival", 20201012.1, [[dS083bqifLEervvxIOQI2Ki6tevvYOeH6ukaRseYRaWSiQClavAxK8lIIHruLJPiTmiv9mfqtdqfxdqzBkq6BkqPXPavNdqvToavH5bq3JiTpivoOcuyHeLEiGQOlQarAJaQs1hjQQGrcOkXjvGIwjGmtfiQBQar0oHe)eqvkdvbIWsjQQqpfOPcj9vIQk1EH6VegmfhMQfRIhJyYI6YO2mP(SinAfXPLSAfi8AiLztPBdXUv63snCf64aQsA5GEUQMUW1vPTRO67kOXRO48IG1tuvMprSFKgpfJkgm7bJrb9Yd9YBQ8MIEf6NoWbof9yWiHrgdo6e08ugdUocJbbVW51C3Ibh9eSTNXOIb)(cjmgCseJpWdzKjTIj3JI0iY8fY16r1lb66qMVqiYGbp3YgdMl(GbZEWyuqV8qV8MkVPOxH(PdCGtXG(nM0qmiyHCTEu9c8e66adoPYzEXhmyMFcgu(tnGx48AUBPgGxUBWqkqYFQb4ns0hgsntrVCud6Lh6LhfikqYFQzqMNZwQbqPudWKNcdARpEmQyqF8dmQyuMIrfd6KO6fdIwzTIFshyqE9JLZyzXbgf0JrfdYRFSCgllgKaRGHLJbpxTwr6gMR1dol8)9Rnu3rQjj1KyQ5C1AfPByUwp4SW)3V2qbzeV2NAaKAMQag1KiQjLKPgjsOMZvRvh7fkATiCBVV6osnjPMZvRvh7fkATiCBVVcYiETp1ai1mvbmQjrutkjtndad6KO6fdI0BA3plovW4aJYaXOIb51pwoJLfdsGvWWYXGNRwRiDdZ16bNf()(1gQ7i1KKAsm1CUATI0nmxRhCw4)7xBOGmIx7tnasntvaJAse1KsYuJejuZ5Q1QJ9cfTweUT3xDhPMKuZ5Q1QJ9cfTweUT3xbzeV2NAaKAMQag1KiQjLKPMbGbDsu9IbH(y0qXhWcnghyuaoyuXG86hlNXYIbjWkyy5yqDtUp1aa1q8peqoLxQbqQr3K7Rq8zWGojQEXGARVOvBQ4dyHgJdmkadJkgKx)y5mwwmOtIQxmiAL1kincIVzmibwbdlhdQVwRaYKjomLfrHWudGuZufWOMernPKm1KKA0n5(udaudX)qa5uEPgaPgDtUVcXNbdssGyzr4WuoEmktXbgLbfJkgKx)y5mwwmibwbdlhdQBY9PgaOgI)HaYP8snasn6MCFfIpdg0jr1lg8dMTIa6J4aJYGfJkgKx)y5mwwmibwbdlhdQBY9PgaOgI)HaYP8snasn6MCFfIpd1KKAMLAIIGwTPutsQzwQ5C1AfcJ0WeeTwyVKklYq2rE1DKAssnjMA0xRvazYehMYIOqyQbqQzQcyutIOMusMAKiHAMLAYDOgw2SUGS40ihvue0QnLAssnZsnNRwRiDdZ16bNf()(1gQ7i1irc1ml1K7qnSSzDbzXProQOiOvBk1KKAoxTwH0BA3pl0xycQpCcAudGuZuQzauJejutuiSiArUyQbqQz6GtnjPMzPMChQHLnRlilonYrffbTAtXGojQEXGdlBwxqwCAKdoWOm4yuXG86hlNXYIbjWkyy5yWzPMChQNHJ8gIpQnvffbTAtPMKuZSuZ5Q1ks3WCTEWzH)VFTH6oIbDsu9IbFgoYBi(O2uCGrb4JrfdYRFSCgllg0jr1lgeTYAfKgbX3mgKaRGHLJb1n5(udaudX)qa5uEPgaPgDtUVcXNHAssnjMAoxTwH0BA3pl0xycQpCcAudGudWOgjsOgDtUp1ai14KO6vH0BA3plovWks)b1mamijbILfHdt54XOmfhyuMkpmQyqE9JLZyzXGeyfmSCmiK1q(N4hltnjPMzPMZvRvKUH5A9GZc)F)Ad1DKAssnNRwRq6nT7Nf6lmb1hobnQbqQbyyqNevVyWNHJ8gIpQnfhyuMofJkgKx)y5mwwmibwbdlhdol1CUATI0nmxRhCw4)7xBOUJyqNevVyqxGCHzgkATGa7HpoWOmf9yuXG86hlNXYIbjWkyy5yWzPMZvRvKUH5A9GZc)F)Ad1Ded6KO6fds6gMR1dol8)9RnWbgLPdeJkgKx)y5mwwmibwbdlhdEUATcP30UFwOVWeu3rQrIeQr3K7tnaqne)dbKt5LAqh1OBY9vi(mudWLAMkpQrIeQ5C1AfPByUwp4SW)3V2qDhXGojQEXGi9M29ZItfmoWOmf4Grfd6KO6fdc9XOHIpGfAmgKx)y5mwwCGrzkWWOIb51pwoJLfdsGvWWYXGZsnrrqR2umOtIQxm4WYM1fKfNg5GdCGbhQlmQyuMIrfd6KO6fdIwzTIFshyqE9JLZyzXbgf0JrfdYRFSCgllgKaRGHLJb1n5(udaudX)qa5uEPgaPgDtUVcXNHAssnHB5nubdrErRf8M6PmcVHIx)y5mg0jr1lgCIdh7EXbgLbIrfdYRFSCgllgKaRGHLJbpxTwDSxOO1IWT9(Q7i1KKAoxTwDSxOO1IWT9(kiJ41(udGutkjJbDsu9Ibr6nT7NfNkyCGrb4GrfdYRFSCgllgKaRGHLJbpxTwDSxOO1IWT9(Q7i1KKAoxTwDSxOO1IWT9(kiJ41(udGutkjJbDsu9IbH(y0qXhWcnghyuaggvmiV(XYzSSyqcScgwog8C1A18AKHVyoVnI6osnjPMZvRvZRrg(I582ikiJ41(udGuZufWOMernPKm1irc1ml1K7q9mCK3q8rTPQOiOvBkg0jr1lg8z4iVH4JAtXbgLbfJkgKx)y5mwwmibwbdlhdQVwRaYKjomLfrHWudGuZufWOMernPKm1KKA0n5(udaudX)qa5uEPgaPgDtUVcXNHAKiHAsm1S8mHyyjonYrnVTEuwMAssn5oupdh5neFuBQkkcA1MsnjPMChQNHJ8gIpQnvbznK)j(XYuJejuZYZeIHL40ih14eg2i9YutsQzwQ5C1AfsVPD)SqFHjOUJutsQr3K7tnaqne)dbKt5LAaKA0n5(keFgQb4snojQEvOvwRG0ii(Mve)dbKt5LAse1mqQzayqNevVyWHLnRlilonYbhyugSyuXG86hlNXYIbDsu9IbrRSwbPrq8nJbjWkyy5yqDtUp1aa1q8peqoLxQbqQr3K7Rq8zOgGl1OBY9vqoLxmijbILfHdt54XOmfhyugCmQyqNevVyqxGCHzgkATGa7HpgKx)y5mwwCGrb4JrfdYRFSCgllgKaRGHLJb1n5(udaudX)qa5uEPgaPgDtUVcXNbd6KO6fd(bZwra9rCGrzQ8WOIb51pwoJLfdsGvWWYXG6R1kGmzIdtzruim1ai1mvbmQjrutkjJbDsu9Ibhw2SUGS40ihCGrz6umQyqNevVyqs3WCTEWzH)VFTbgKx)y5mwwCGrzk6XOIb51pwoJLfdsGvWWYXGNRwRMxJm8fZ5Tru3rQjj1K7q9mCK3q8rTPkiJ41(udGudWHAse1KsYyqNevVyWNHJ8gIpQnfhyuMoqmQyqE9JLZyzXGeyfmSCmyUd1pb6JlBfNg5OIIGwTPuJejuZ5Q1kKEt7(zH(ctq9HtqJAKsnadd6KO6fdI0BA3plovW4aJYuGdgvmiV(XYzSSyqcScgwogC5zcXWsCAKJ6Na9XLTutsQj3H6z4iVH4JAtvqgXR9Pg0rnaJAse1KsYyqNevVyWHLnRlilonYbhyuMcmmQyqE9JLZyzXGeyfmSCmiK1q(N4hlJbDsu9IbFgoYBi(O2uCGrz6GIrfdYRFSCgllgKaRGHLJbNLAoxTwH0BA3pl0xyckiJ41(yqNevVyqYehnOJ84aJY0blgvmOtIQxmisVPD)S4ubJb51pwoJLfhyuMo4yuXGojQEXGqFmAO4dyHgJb51pwoJLfhyuMc8XOIb51pwoJLfdsGvWWYXGNRwRMxJm8fZ5Tru3rmOtIQxm4ZWrEdXh1MIdmkOxEyuXG86hlNXYIbjWkyy5yWLNjedlXProQ5T1JYYutsQj3H6z4iVH4JAtvrrqR2uQrIeQz5zcXWsCAKJACcdBKEzQrIeQz5zcXWsCAKJ6Na9XLTyqNevVyWHLnRlilonYbh4adMzTFTbgvmktXOIbDsu9IbrUYN8zzmiV(XYzSS4aJc6XOIbDsu9IbVplQGrEmiV(XYzSS4aJYaXOIb51pwoJLfd6KO6fdsCRv4KO6vyRpWG26dX6imgKKFCGrb4GrfdYRFSCgllgKaRGHLJbDsuZzbVmsXp1iLAMsnjPMWHPCOIcHfrlYftnasn6MCFQrgQjXuJtIQxfsVPD)S4ubRi9hudWLAi(hciNYl1maQjrutkjJbDsu9Ibr6nT7NfNkyCGrbyyuXG86hlNXYIbjWkyy5yqNe1CwWlJu8tnasndKAssnHB5nuKjoAqh5v86hlNPMKut4wEdLBhN4IriN9OHkE9JLZyqNevVyqIBTcNevVcB9bg0wFiwhHXG(4qDHdmkdkgvmiV(XYzSSyqcScgwog0jrnNf8Yif)udGuZaPMKut4wEdfzIJg0rEfV(XYzmOtIQxmiXTwHtIQxHT(adARpeRJWyWH6chyugSyuXG86hlNXYIbjWkyy5yqNe1CwWlJu8tnasndKAssnZsnHB5nuUDCIlgHC2JgQ41pwotnjPMzPMWT8gQHLnRlilQvF)QxfV(XYzmOtIQxmiXTwHtIQxHT(adARpeRJWyWpWbgLbhJkgKx)y5mwwmibwbdlhd6KOMZcEzKIFQbqQzGutsQjClVHYTJtCXiKZE0qfV(XYzQjj1ml1eUL3qnSSzDbzrT67x9Q41pwoJbDsu9IbjU1kCsu9kS1hyqB9HyDegd6JFGdmkaFmQyqE9JLZyzXGeyfmSCmOtIAol4Lrk(PgaPMbsnjPMWT8gk3ooXfJqo7rdv86hlNPMKut4wEd1WYM1fKf1QVF1RIx)y5mg0jr1lgK4wRWjr1RWwFGbT1hI1rymOpoux4aJYu5HrfdYRFSCgllgKaRGHLJbDsuZzbVmsXp1ai1mqQjj1ml1eUL3q52XjUyeYzpAOIx)y5m1KKAc3YBOgw2SUGSOw99REv86hlNXGojQEXGe3AfojQEf26dmOT(qSocJbhQlCGrz6umQyqE9JLZyzXGeyfmSCmOtIAol4Lrk(Pg0rntPMKuZSut4wEd1PG5x0AXiKtqXRFSCMAKiHACsuZzbVmsXp1GoQb9yqNevVyqIBTcNevVcB9bg0wFiwhHXGel7ZzCGrzk6XOIbDsu9Ibj9s4nGEWzH26imgKx)y5mwwCGrz6aXOIbDsu9IbDiXxweneYBGb51pwoJLfhyuMcCWOIbDsu9IbpEQO1Iawe0EmiV(XYzSS4ahyqIL95mgvmktXOIb51pwoJLfd2JyWNJsJbDsu9IbN7WYpwgdo3HI1rymiXHZzbjdXGeyfmSCmOtIAol4Lrk(PgaPgGHbN72lly7ZyqGHbN72lJbDsuZzbVmsXpoWOGEmQyqE9JLZyzXGeyfmSCmOlFmScwDSxOO1IWT9(kOVOrnOJAKh1KKAsm1CUATI0nmxRhCw4)7xBOUJutsQjXuZ5Q1ks3WCTEWzH)VFTHcYiETp1ai1mvbmQjrutkjtnsKqnNRwRo2lu0Ar42EF1DKAssnNRwRo2lu0Ar42EFfKr8AFQbqQzQcyutIOMusMAKiHAoxTwr6gMR1dol8)9RnuqgXR9PMKuZSuZ5Q1QJ9cfTweUT3xbzeV2NAga1mamOtIQxmisVPD)S4ubJdmkdeJkgKx)y5mwwmOtIQxmisVPD)S4ubJbjWkyy5yWmFUATY6bVHySRVx1hobnQbDutIPgNe1CwWlJu8tnsKqnaFQzautsQrxPtcbKr8AFQbqQXjrnNf8Yif)utIOMusgdssGyzr4WuoEmktXbgfGdgvmOtIQxmOlqUWmdfTwqG9WhdYRFSCglloWOammQyqNevVyqs3WCTEWzH)VFTbgKx)y5mwwCGrzqXOIb51pwoJLfdsGvWWYXG5ou)eOpUSvCAKJkkcA1MsnjPMzPMWT8gQjjKH(lovWkE9JLZuJejutUd1pb6JlBfNg5OIIGwTPutsQXjrnNf8Yif)ud6OgGHbDsu9IbjoCoJdmkdwmQyqE9JLZyzXGeyfmSCm4Sut4wEdv6LHWYADr4KOiVIx)y5m1irc1OVwRaYKjomLfrHWudGutkjtnsKqnqVYcEoVHYZ5xbzeV2NAaKAguQjj1a9kl458gkpNFfpt9XJbDsu9Ibhw2SUGS40ihCGrzWXOIb51pwoJLfdsGvWWYXGKjomLFHg6KO61Tud6Og0Rag1irc1K7q9tG(4YwXProQOiOvBk1irc1q62M7HRAyzZ6cYItJCuqgXR9Pg0rnojQ5SGxgP4NAaUutkjtnsKqnz(C1A1X2Dw0ArmHf8YijOGmIx7tnsKqnqVYcEoVHYZ5xbzeV2NAaKAag1KKAGELf8CEdLNZVINP(4XGojQEXGNBqMWWeWbgfGpgvmiV(XYzSSyqNevVyqKEt7(zXPcgdsGvWWYXGz(C1AL1dEdXyxFVQpCcAud6OMbhdssGyzr4WuoEmktXbgLPYdJkg0jr1lgKmXrd6ipgKx)y5mwwCGrz6umQyqE9JLZyzXGojQEXGOvwRG0ii(MXGeyfmSCmOUj3NAaGAi(hciNYl1ai1OBY9vi(myqscellchMYXJrzkoWOmf9yuXG86hlNXYIbjWkyy5yWWT8gQGHiVO1cEt9ugH3qXRFSCgd6KO6fdoXHJDV4aJY0bIrfdYRFSCgllgKaRGHLJbd3YBOsVmewwRlcNef5v86hlNXGojQEXGehoNXbgLPahmQyqE9JLZyzXGeyfmSCmiPBBUhUQHLnRlilonYrbzeV2NAqh1KyQXjrnNf8Yif)uJejudWOMbGbDsu9Ibp3GmHHjGdmktbggvmiV(XYzSSyqcScgwogu3K7tnaqne)dbKt5LAaKA0n5(keFgmOtIQxmO26lA1Mk(awOX4aJY0bfJkgKx)y5mwwmibwbdlhdM7qnSSzDbzXProkiRH8pXpwMAKiHAc3YBOgw2SUGSOw99REv86hlNXGojQEXGdlBwxqwCAKdoWOmDWIrfdYRFSCgllg0jr1lg8z4iVH4JAtXGeyfmSCm45Q1Q51idFXCEBefKDsGbjjqSSiCykhpgLP4aJY0bhJkgKx)y5mwwmibwbdlhds62M7HRAyzZ6cYItJCuqgXR9Pg0rnZDy5hlRioColizi1id1GEmOtIQxmiXHZzCGrzkWhJkg0jr1lg8dMTIa6JyqE9JLZyzXbgf0lpmQyqE9JLZyzXGojQEXGpdh5neFuBkgKaRGHLJbHSgY)e)yzQjj1CUATkQrrRfXew8JSdvF4e0OgaPMbsnjPMLNjedlXProQ5T1JYYuJejudK1q(N4hltnjPgx(yyfSY6bVHySRVxf0x0Og0rnYddssGyzr4WuoEmktXbgf0pfJkgKx)y5mwwmOtIQxmisVPD)S4ubJbjjqSSiCykhpgLP4aJc6rpgvmiV(XYzSSyqNevVyqOpgnu8bSqJXGKeiwweomLJhJYuCGdm4iKjnYXdmQyuMIrfdYRFSCgllgCDegd6Y3pXH(l09gIwlg7Hmed6KO6fd6Y3pXH(l09gIwlg7HmehyuqpgvmOtIQxmy61H5YxrRfU8XWoMGb51pwoJLfhyugigvmOtIQxmiPByUwp4SW)3V2adYRFSCglloWOaCWOIbDsu9Ibh2qBEoxRaYFV(symiV(XYzSS4aJcWWOIb51pwoJLfd6KO6fdo2r1lgmNW6ifrmc5XoWGtXbgLbfJkg0jr1lg8dMTIa6JyqE9JLZyzXbgLblgvmOtIQxm4eho29Ib51pwoJLfh4adsYpgvmktXOIb51pwoJLfdsGvWWYXGKUT5E4QiDdZ16bNf()(1gkiJ41(ud6OMbkpmOtIQxm4X2DwOVWeWbgf0JrfdYRFSCgllgKaRGHLJbjDBZ9Wvr6gMR1dol8)9RnuqgXR9Pg0rnduEyqNevVyqFj8hq3kiU1IdmkdeJkgKx)y5mwwmibwbdlhds62M7HRI0nmxRhCw4)7xBOGmIx7tnOJAgO8WGojQEXG6cYhB3zCGrb4Grfd6KO6fdAR0jXlge3CkcVbgKx)y5mwwCGrbyyuXG86hlNXYIbjWkyy5yqs32CpCvKUH5A9GZc)F)AdfKr8AFQbDuZGkpQrIeQjkeweTixm1ai1mDGyqNevVyWddFgIwTP4aJYGIrfdYRFSCgllgKaRGHLJbpxTwLEDyU8v0AHlFmSJjQ7i1KKAsm1CUAT6WWNHOvBQ6osnsKqnNRwRo2UZc9fMG6osnsKqnZsnqNWQa2wl1maQrIeQjXudP3)I4hlRg7O6v0AXDpWkB5SqFHjqnjPgDLojeqgXR9PgaPMbDk1irc1OR0jHaYiETp1ai1G(bLAga1irc1ml1W)ZlHvKEZ8(CwylnRBiHvi(GOHutsQ5C1AfPByUwp4SW)3V2qDhXGojQEXGJDu9IdmkdwmQyqE9JLZyzXGeyfmSCmy4Wuou56dFjm1GoPuZGIbDsu9Ib9FKjHO1Iyclyp1Y4aJYGJrfdYRFSCgllg0jr1lg0)jZ9LFb0LVgkin0TyqcScgwog8C1AfcJ0WeeTwyVKklYq2rE1DKAssn6kDsiGmIx7tnasnKUT5E4QqyKgMGO1c7LuzrgYoYRGmIx7tnaqntbg1irc1CUATk96WC5RO1cx(yyhtuF4e0OgPudWOMKuJUsNeciJ41(udGudPBBUhUQ0RdZLVIwlC5JHDmrbzeV2NAaGAqV8OgjsOMmFUATc6YxdfKg6wrMpxTwL7Hl1irc1OR0jHaYiETp1ai1G(PuJejuZ5Q1QHn0MNZ1kG83RVewbzeV2NAssn6kDsiGmIx7tnasnKUT5E4Qg2qBEoxRaYFV(syfKr8AFQbaQz6GtnsKqnZsnHB5nuNcMFrRfJqobfV(XYzQjj1OR0jHaYiETp1ai1q62M7HRI0nmxRhCw4)7xBOGmIx7tnaqnOxEutsQ5C1AfPByUwp4SW)3V2qbzeV2hdUocJb9FYCF5xaD5RHcsdDloWOa8XOIb51pwoJLfd6KO6fdM6wM4wldFXP7fdsGvWWYXGKUT5E4QqyKgMGO1c7LuzrgYoYRGmIx7tnsKqnHB5nudlBwxqwuR((vVkE9JLZutsQH0Tn3dxfPByUwp4SW)3V2qbzeV2NAKiHAMLA4)5LWkegPHjiATWEjvwKHSJ8keFq0qQjj1q62M7HRI0nmxRhCw4)7xBOGmIx7JbxhHXGPULjU1YWxC6EXbgLPYdJkgKx)y5mwwm46img0LVFId9xO7neTwm2dzig0jr1lg0LVFId9xO7neTwm2dzioWOmDkgvmiV(XYzSSyqcScgwoge6vwWZ5nuEo)QAPg0rnaF5rnjPgDtUp1ai1OBY9vi(mudWLAqpWOgjsOMetnojQ5SGxgP4NAqh1mLAssnZsnHB5nuNcMFrRfJqobfV(XYzQrIeQXjrnNf8Yif)ud6Og0tndGAssnjMAoxTwDSxOO1IWT9(Q7i1KKAoxTwDSxOO1IWT9(kiJ41(ud6OMbsnjIAsjzQrIeQzwQ5C1A1XEHIwlc327RUJuZaWGojQEXG6MCFolC5JHvWId7i4aJYu0JrfdYRFSCgllgKaRGHLJbtm1KyQb6vwWZ5nuEo)kiJ41(ud6OgGV8OgjsOMzPgOxzbpN3q558R4zQpEQzauJejutIPgNe1CwWlJu8tnOJAMsnjPMzPMWT8gQtbZVO1IriNGIx)y5m1irc14KOMZcEzKIFQbDud6PMbqndGAssn6MCFQbqQr3K7Rq8zWGojQEXGhB3zrRfXewWlJKaoWOmDGyuXG86hlNXYIbjWkyy5yWetnjMAGELf8CEdLNZVcYiETp1GoQzqLh1irc1ml1a9kl458gkpNFfpt9XtndGAKiHAsm14KOMZcEzKIFQbDuZuQjj1ml1eUL3qDky(fTwmc5eu86hlNPgjsOgNe1CwWlJu8tnOJAqp1maQzautsQr3K7tnasn6MCFfIpdg0jr1lgC8clDc1Mkow)dCGrzkWbJkg0jr1lgm96WC5RO1cx(yyhtWG86hlNXYIdmktbggvmOtIQxmiSghTSOwXp6egdYRFSCglloWOmDqXOIb51pwoJLfdsGvWWYXG6R1kGmzIdtzruim1ai1mLAse1KsYyqNevVyqsVeEdOhCwOTocJdmkthSyuXG86hlNXYIbjWkyy5yWZvRvqMGML)xOBiHv3rmOtIQxmymHf3903nl0nKW4aJY0bhJkg0jr1lgCydT55CTci)96lHXG86hlNXYIdmktb(yuXG86hlNXYIbjWkyy5yWWHPCOMWUnMOgjb1GoQzWLh1irc1eomLd1e2TXe1ijOgaLsnOxEuJejut4WuourHWIOfJKqGE5rnOJAgO8WGojQEXGq2hRnvOToc)4aJc6LhgvmiV(XYzSSyqcScgwogK)NxcRqyKgMGO1c7LuzrgYoYRq8brdPMKudK1q(N4hltnjPMZvRvZRrg(I582iQ7i1KKAMLAiDBZ9WvHWinmbrRf2lPYImKDKxbzeV2hd6KO6fd(mCK3q8rTP4aJc6NIrfdYRFSCgllgKaRGHLJb5)5LWkegPHjiATWEjvwKHSJ8keFq0qQjj1ml1q62M7HRcHrAycIwlSxsLfzi7iVcYiETpg0jr1lgeP30UFwCQGXbgf0JEmQyqE9JLZyzXGeyfmSCmi)pVewHWinmbrRf2lPYImKDKxH4dIgsnjPg91AfqMmXHPSikeMAaKAMQag1KiQjLKPMKuJUj3NAaKACsu9Qq6nT7NfNkyfP)GAssnZsnKUT5E4QqyKgMGO1c7LuzrgYoYRGmIx7JbDsu9Ibhw2SUGS40ihCGrb9deJkgKx)y5mwwmibwbdlhdQBY9PgaPgNevVkKEt7(zXPcwr6pOMKuZ5Q1ks3WCTEWzH)VFTH6oIbDsu9IbryKgMGO1c7LuzrgYoYJdCGb)aJkgLPyuXGojQEXGOvwR4N0bgKx)y5mwwCGrb9yuXG86hlNXYIbjWkyy5yWWT8gQGHiVO1cEt9ugH3qXRFSCgd6KO6fdoXHJDV4aJYaXOIb51pwoJLfdsGvWWYXG6MCFQbaQH4FiGCkVudGuJUj3xH4ZGbDsu9Ib1wFrR2uXhWcnghyuaoyuXG86hlNXYIbjWkyy5yWZvRvKUH5A9GZc)F)Ad1DKAssnjMAoxTwr6gMR1dol8)9RnuqgXR9PgaPMPkGrnjIAsjzQrIeQ5C1A1XEHIwlc327RUJutsQ5C1A1XEHIwlc327RGmIx7tnasntvaJAse1KsYuZaWGojQEXGqFmAO4dyHgJdmkadJkgKx)y5mwwmibwbdlhdEUATI0nmxRhCw4)7xBOUJutsQjXuZ5Q1ks3WCTEWzH)VFTHcYiETp1ai1mvbmQjrutkjtnsKqnNRwRo2lu0Ar42EF1DKAssnNRwRo2lu0Ar42EFfKr8AFQbqQzQcyutIOMusMAgag0jr1lgeP30UFwCQGXbgLbfJkgKx)y5mwwmOtIQxmiAL1kincIVzmibwbdlhdQBY9PgaOgI)HaYP8snasn6MCFfIpdgKKaXYIWHPC8yuMIdmkdwmQyqE9JLZyzXGeyfmSCm45Q1Q51idFXCEBe1DKAssnNRwRMxJm8fZ5TruqgXR9PgaPMPutIOMusgd6KO6fd(mCK3q8rTP4aJYGJrfdYRFSCgllgKaRGHLJb1n5(udaudX)qa5uEPgaPgDtUVcXNbd6KO6fd(bZwra9rCGrb4JrfdYRFSCgllgKaRGHLJb1n5(udaudX)qa5uEPgaPgDtUVcXNHAssnqwd5FIFSm1KKA0xRvazYehMYIOqyQbqQjLKPMKuZSuZ5Q1kegPHjiATWEjvwKHSJ8Q7i1irc1OBY9PgaOgI)HaYP8snasn6MCFfIpd1KKAsm1ml1K7qnSSzDbzXProQOiOvBk1KKAsm1ml1CUATI0nmxRhCw4)7xBOUJuJejuZ5Q1kKEt7(zH(ctq9HtqJAaKAMsnsKqnrHWIOf5IPgaPMPdo1irc1ml1K7qnSSzDbzXProQOiOvBk1KKAC5JHvWQHLnZWL)x8x48AUBvqFrJAqh1ipQzauZaOMKuZSuZ5Q1kegPHjiATWEjvwKHSJ8Q7ig0jr1lgCyzZ6cYItJCWbgLPYdJkgKx)y5mwwmibwbdlhdEUATAEnYWxmN3grDhPMKutUd1ZWrEdXh1MQGmIx7tnasnahQjrutkjtnsKqn5oupdh5neFuBQcYAi)t8JLPMKuZSuZ5Q1ks3WCTEWzH)VFTH6oIbDsu9IbFgoYBi(O2uCGrz6umQyqE9JLZyzXGeyfmSCm4SuZ5Q1ks3WCTEWzH)VFTH6oIbDsu9IbDbYfMzOO1ccSh(4aJYu0JrfdYRFSCgllgKaRGHLJbNLAoxTwr6gMR1dol8)9Rnu3rmOtIQxmiPByUwp4SW)3V2ahyuMoqmQyqE9JLZyzXGeyfmSCm45Q1kKEt7(zH(ctqDhPgjsOgDtUp1aa1q8peqoLxQbDuJUj3xH4ZqnaxQb9YJAssnHB5nuZRrg(I582ikE9JLZuJejuJUj3NAaGAi(hciNYl1GoQr3K7Rq8zOgGl1mLAssnHB5nubdrErRf8M6PmcVHIx)y5m1irc1CUATI0nmxRhCw4)7xBOUJyqNevVyqKEt7(zXPcghyuMcCWOIbDsu9IbH(y0qXhWcngdYRFSCglloWOmfyyuXG86hlNXYIbjWkyy5yWChQHLnRlilonYrbznK)j(XYyqNevVyWHLnRlilonYbhyuMoOyuXG86hlNXYIbjWkyy5yWZvRvZRrg(I582iQ7ig0jr1lg8z4iVH4JAtXboWG(4qDHrfJYumQyqNevVyq0kRv8t6adYRFSCglloWOGEmQyqE9JLZyzXGeyfmSCm45Q1QJ9cfTweUT3xDhPMKuZ5Q1QJ9cfTweUT3xbzeV2NAaKAsjzmOtIQxmisVPD)S4ubJdmkdeJkgKx)y5mwwmibwbdlhdEUAT6yVqrRfHB79v3rQjj1CUAT6yVqrRfHB79vqgXR9PgaPMusgd6KO6fdc9XOHIpGfAmoWOaCWOIb51pwoJLfdsGvWWYXGZsn5oupdh5neFuBQkkcA1MIbDsu9IbFgoYBi(O2uCGrbyyuXGojQEXGUa5cZmu0Abb2dFmiV(XYzSS4aJYGIrfdYRFSCgllgKaRGHLJb1xRvazYehMYIOqyQbqQzQcyutIOMusMAKiHA0n5(udaudX)qa5uEPgaPgDtUVcXNHAssnjMAwEMqmSeNg5OM3wpkltnjPMChQNHJ8gIpQnvffbTAtPMKutUd1ZWrEdXh1MQGSgY)e)yzQrIeQz5zcXWsCAKJACcdBKEzQjj1ml1CUATcP30UFwOVWeu3rQjj1OBY9PgaOgI)HaYP8snasn6MCFfIpd1aCPgNevVk0kRvqAeeFZkI)HaYP8snjIAgi1mamOtIQxm4WYM1fKfNg5GdmkdwmQyqNevVyqs3WCTEWzH)VFTbgKx)y5mwwCGrzWXOIb51pwoJLfdsGvWWYXGNRwRq6nT7Nf6lmbfKr8AFQjj1S8mHyyjonYrnoHHnsVmg0jr1lgeP30UFwCQGXbgfGpgvmiV(XYzSSyqNevVyq0kRvqAeeFZyqcScgwoguFTwbKjtCyklIcHPgaPMPkGrnjIAsjzQjj1OBY9PgaOgI)HaYP8snasn6MCFfIpd1aCPg0lpmijbILfHdt54XOmfhyuMkpmQyqE9JLZyzXGeyfmSCmOUj3NAaGAi(hciNYl1ai1OBY9vi(myqNevVyWpy2kcOpIdmktNIrfdYRFSCgllgKaRGHLJbpxTwf1OO1Iycl(r2HQpCcAuJuQzGuJejutUd1pb6JlBfNg5OIIGwTPyqNevVyqOpgnu8bSqJXbgLPOhJkgKx)y5mwwmibwbdlhdM7q9tG(4YwXProQOiOvBkg0jr1lgeP30UFwCQGXbgLPdeJkgKx)y5mwwmibwbdlhdU8mHyyjonYr9tG(4YwQjj1OBY9Pg0rnduEutsQj3H6z4iVH4JAtvqgXR9Pg0rnaJAse1KsYyqNevVyWHLnRlilonYbhyuMcCWOIb51pwoJLfdsGvWWYXGZsnNRwRq6nT7Nf6lmbfKr8AFmOtIQxmizIJg0rECGrzkWWOIb51pwoJLfdsGvWWYXGqwd5FIFSmg0jr1lg8z4iVH4JAtXbgLPdkgvmiV(XYzSSyqNevVyq0kRvqAeeFZyqcScgwogu3K7tnaqne)dbKt5LAaKA0n5(keFgQjj1KyQ5C1AfsVPD)SqFHjO(WjOrnasnaJAKiHA0n5(udGuJtIQxfsVPD)S4ubRi9huZaWGKeiwweomLJhJYuCGrz6GfJkg0jr1lge6JrdfFal0ymiV(XYzSS4aJY0bhJkgKx)y5mwwmibwbdlhdEUATcP30UFwOVWeu3rQrIeQr3K7tnOJAaoYJAKiHAYDO(jqFCzR40ihvue0Qnfd6KO6fdI0BA3plovW4aJYuGpgvmiV(XYzSSyqcScgwogC5zcXWsCAKJAEB9OSm1KKAYDOEgoYBi(O2uvue0QnLAKiHAwEMqmSeNg5OgNWWgPxMAKiHAwEMqmSeNg5O(jqFCzl1KKA0n5(ud6OgGjpmOtIQxm4WYM1fKfNg5GdCGdm4Cg(vVyuqV8qV8MkVPOxb8XGdD4wB6JbLFpyi)ikdMOi)aWdQHAqDctnfYyddQr3qQr(vM1(1gYVOgid86TGCMA(gHPg)gnIhCMAit8nLFffOb5AzQb4a8GAaE27CggCMAaleGNuZNWg(muJ8tQjAQzq(6utUMxF1l10Jm0JgsnjwMbqnjE6mdqrbIcK87bd5hrzWef5haEqnudQtyQPqgByqn6gsnYViw2NZYVOgid86TGCMA(gHPg)gnIhCMAit8nLFffOb5AzQz6Gd8GAaE27CggCMAaleGNuZNWg(muJ8tQjAQzq(6utUMxF1l10Jm0JgsnjwMbqnjE6mdqrbIc0GjYyddotndo14KO6LAS1hVIceg8hzcgf0dmGHbhHTUSmgu(tnGx48AUBPgGxUBWqkqYFQb4ns0hgsntrVCud6Lh6LhfikqYFQzqMNZwQbqPudWKNIcefiNevVVAeYKg54basL5(SOcgrU1ryPU89tCO)cDVHO1IXEidPa5KO69vJqM0ihpaqQmPxhMlFfTw4Yhd7ycfiNevVVAeYKg54basLH0nmxRhCw4)7xBqbYjr17RgHmProEaGuzg2qBEoxRaYFV(sykqojQEF1iKjnYXdaKkZyhvVYLtyDKIigH8yhsNsbYjr17RgHmProEaGuz(GzRiG(ifiNevVVAeYKg54basLzIdh7EParbYjr17dGuzqUYN8zzkqojQEFaKkZ9zrfmYtbYjr17dGuziU1kCsu9kS1hYToclLKFkqojQEFaKkdsVPD)S4ublxPL6KOMZcEzKIFPttgomLdvuiSiArUya1n5(YptStIQxfsVPD)S4ubRi9haxI)HaYP8oGeLsYuGCsu9(aivgIBTcNevVcB9HCRJWs9XH6sUsl1jrnNf8Yif)aoWKHB5nuKjoAqh5v86hlNtgUL3q52XjUyeYzpAOIx)y5mfiNevVpasLH4wRWjr1RWwFi36iS0H6sUsl1jrnNf8Yif)aoWKHB5nuKjoAqh5v86hlNPa5KO69bqQme3AfojQEf26d5whHL(HCLwQtIAol4Lrk(bCGjNnClVHYTJtCXiKZE0qfV(XY5KZgUL3qnSSzDbzrT67x9Q41pwotbYjr17dGuziU1kCsu9kS1hYTocl1h)qUsl1jrnNf8Yif)aoWKHB5nuUDCIlgHC2JgQ41pwoNC2WT8gQHLnRlilQvF)QxfV(XYzkqojQEFaKkdXTwHtIQxHT(qU1ryP(4qDjxPL6KOMZcEzKIFahyYWT8gk3ooXfJqo7rdv86hlNtgUL3qnSSzDbzrT67x9Q41pwotbYjr17dGuziU1kCsu9kS1hYToclDOUKR0sDsuZzbVmsXpGdm5SHB5nuUDCIlgHC2JgQ41pwoNmClVHAyzZ6cYIA13V6vXRFSCMcKtIQ3haPYqCRv4KO6vyRpKBDewkXY(CwUsl1jrnNf8Yif)OBAYzd3YBOofm)IwlgHCckE9JLZsK4KOMZcEzKIF0HEkquGK)udW7L1YWxoQH4FqnLMA2oMuBk1W2NPM6PgFUxw)yzffiNevVpasLH0lH3a6bNfARJWuGCsu9(aivghs8LfrdH8guGCsu9(aivMJNkATiGfbTNcefi5p1myyhN4uZGeqo7rdPa5KO69v(4hsrRSwXpPdkqojQEFLp(basLbP30UFwCQGLR0spxTwr6gMR1dol8)9Rnu3XKj(C1AfPByUwp4SW)3V2qbzeV2hWPkGLOuswIKZvRvh7fkATiCBVV6oM8C1A1XEHIwlc327RGmIx7d4ufWsukjpakqojQEFLp(basLb6JrdfFal0y5kT0ZvRvKUH5A9GZc)F)Ad1DmzIpxTwr6gMR1dol8)9RnuqgXR9bCQcyjkLKLi5C1A1XEHIwlc327RUJjpxTwDSxOO1IWT9(kiJ41(aovbSeLsYdGcKtIQ3x5JFaGuz0wFrR2uXhWcnwUslv3K7daX)qa5uEbu3K7Rq8zOa5KO69v(4haivg0kRvqAeeFZYrsGyzr4WuoEPtLR0s1xRvazYehMYIOqyaNQawIsj5K6MCFai(hciNYlG6MCFfIpdfiNevVVYh)aaPY8bZwra9r5kTuDtUpae)dbKt5fqDtUVcXNHcKtIQ3x5JFaGuzgw2SUGS40ih5kTuDtUpae)dbKt5fqDtUVcXNj5SrrqR20KZEUATcHrAycIwlSxsLfzi7iV6oMmX6R1kGmzIdtzruimGtvalrPKSejZM7qnSSzDbzXProQOiOvBAYzpxTwr6gMR1dol8)9Rnu3rjsMn3HAyzZ6cYItJCurrqR20KNRwRq6nT7Nf6lmb1hobnaNoajsIcHfrlYfd40bp5S5oudlBwxqwCAKJkkcA1MsbYjr17R8XpaqQmpdh5neFuBQCLw6S5oupdh5neFuBQkkcA1MMC2ZvRvKUH5A9GZc)F)Ad1DKcKtIQ3x5JFaGuzqRSwbPrq8nlhjbILfHdt54LovUslv3K7daX)qa5uEbu3K7Rq8zsM4ZvRvi9M29Zc9fMG6dNGgGatIeDtUpGojQEvi9M29ZItfSI0FmakqojQEFLp(basL5z4iVH4JAtLR0sHSgY)e)y5KZEUATI0nmxRhCw4)7xBOUJjpxTwH0BA3pl0xycQpCcAacmkqojQEFLp(basLXfixyMHIwliWE4lxPLo75Q1ks3WCTEWzH)VFTH6osbYjr17R8XpaqQmKUH5A9GZc)F)Ad5kT0zpxTwr6gMR1dol8)9Rnu3rkqojQEFLp(basLbP30UFwCQGLR0spxTwH0BA3pl0xycQ7Oej6MCFai(hciNYl60n5(keFgG7u5jrY5Q1ks3WCTEWzH)VFTH6osbYjr17R8XpaqQmqFmAO4dyHgtbYjr17R8XpaqQmdlBwxqwCAKJCLw6SrrqR2ukquGK)uZGHDCItndsa5ShneaQr(DzZ6cYuZG5QVF1lfiNevVVYhhQlPOvwR4N0bfiNevVVYhhQlaKkdsVPD)S4ublxPLEUAT6yVqrRfHB79v3XKNRwRo2lu0Ar42EFfKr8AFatjzkqojQEFLpouxaivgOpgnu8bSqJLR0spxTwDSxOO1IWT9(Q7yYZvRvh7fkATiCBVVcYiETpGPKmfiNevVVYhhQlaKkZZWrEdXh1MkxPLoBUd1ZWrEdXh1MQIIGwTPuGCsu9(kFCOUaqQmUa5cZmu0Abb2dFkqojQEFLpouxaivMHLnRlilonYrUslvFTwbKjtCyklIcHbCQcyjkLKLir3K7daX)qa5uEbu3K7Rq8zsM4LNjedlXProQ5T1JYYjZDOEgoYBi(O2uvue0QnnzUd1ZWrEdXh1MQGSgY)e)yzjswEMqmSeNg5OgNWWgPxo5SNRwRq6nT7Nf6lmb1DmPUj3haI)HaYP8cOUj3xH4ZaCDsu9QqRSwbPrq8nRi(hciNYBIg4aOa5KO69v(4qDbGuziDdZ16bNf()(1guGCsu9(kFCOUaqQmi9M29ZItfSCLw65Q1kKEt7(zH(ctqbzeV2p5YZeIHL40ih14eg2i9YuGCsu9(kFCOUaqQmOvwRG0ii(MLJKaXYIWHPC8sNkxPLQVwRaYKjomLfrHWaovbSeLsYj1n5(aq8peqoLxa1n5(keFgGl6LhfiNevVVYhhQlaKkZhmBfb0hLR0s1n5(aq8peqoLxa1n5(keFgkqojQEFLpouxaivgOpgnu8bSqJLR0spxTwf1OO1Iycl(r2HQpCcAshOej5ou)eOpUSvCAKJkkcA1MsbYjr17R8XH6caPYG0BA3plovWYvAP5ou)eOpUSvCAKJkkcA1MsbYjr17R8XH6caPYmSSzDbzXProYvAPlptigwItJCu)eOpUSnPUj3hDduEjZDOEgoYBi(O2ufKr8AF0bSeLsYuGCsu9(kFCOUaqQmKjoAqh5LR0sN9C1AfsVPD)SqFHjOGmIx7tbYjr17R8XH6caPY8mCK3q8rTPYvAPqwd5FIFSmfiNevVVYhhQlaKkdAL1kincIVz5ijqSSiCykhV0PYvAP6MCFai(hciNYlG6MCFfIptYeFUATcP30UFwOVWeuF4e0aeysKOBY9b0jr1RcP30UFwCQGvK(JbqbYjr17R8XH6caPYa9XOHIpGfAmfiNevVVYhhQlaKkdsVPD)S4ublxPLEUATcP30UFwOVWeu3rjs0n5(Od4ipjsYDO(jqFCzR40ihvue0QnLcKtIQ3x5Jd1fasLzyzZ6cYItJCKR0sxEMqmSeNg5OM3wpklNm3H6z4iVH4JAtvrrqR2ujswEMqmSeNg5OgNWWgPxwIKLNjedlXProQFc0hx2Mu3K7JoGjpkquGCsu9(ks(LESDNf6lmb5kTus32CpCvKUH5A9GZc)F)AdfKr8AF0nq5rbYjr17Ri5haPY4lH)a6wbXTw5kTus32CpCvKUH5A9GZc)F)AdfKr8AF0nq5rbYjr17Ri5haPYOliFSDNLR0sjDBZ9Wvr6gMR1dol8)9RnuqgXR9r3aLhfiNevVVIKFaKkJTsNeVyqCZPi8guGCsu9(ks(bqQmhg(meTAtLR0sjDBZ9Wvr6gMR1dol8)9RnuqgXR9r3GkpjsIcHfrlYfd40bsbYjr17Ri5haPYm2r1RCLw65Q1Q0RdZLVIwlC5JHDmrDhtM4ZvRvhg(meTAtv3rjsoxTwDSDNf6lmb1DuIKzHoHvbST2birsIj9(xe)yz1yhvVIwlU7bwzlNf6lmHK6kDsiGmIx7d4GovIeDLojeqgXR9be9d6aKizw(FEjSI0BM3NZcBPzDdjScXhenm55Q1ks3WCTEWzH)VFTH6osbYjr17Ri5haPY4)itcrRfXewWEQLLR0sdhMYHkxF4lHrN0bLcKtIQ3xrYpasL5(SOcgrU1ryP(pzUV8lGU81qbPHUvUsl9C1AfcJ0WeeTwyVKklYq2rE1DmPUsNeciJ41(as62M7HRcHrAycIwlSxsLfzi7iVcYiETpatbMejNRwRsVomx(kATWLpg2Xe1hobnPalPUsNeciJ41(as62M7HRk96WC5RO1cx(yyhtuqgXR9ba9YtIKmFUATc6YxdfKg6wrMpxTwL7HRej6kDsiGmIx7di6NkrY5Q1QHn0MNZ1kG83RVewbzeV2pPUsNeciJ41(as62M7HRAydT55CTci)96lHvqgXR9by6GlrYSHB5nuNcMFrRfJqobfV(XY5K6kDsiGmIx7diPBBUhUks3WCTEWzH)VFTHcYiETpaOxEjpxTwr6gMR1dol8)9RnuqgXR9Pa5KO69vK8dGuzUplQGrKBDewAQBzIBTm8fNUx5kTus32CpCvimsdtq0AH9sQSidzh5vqgXR9LijClVHAyzZ6cYIA13V6vXRFSCojPBBUhUks3WCTEWzH)VFTHcYiETVejZY)ZlHvimsdtq0AH9sQSidzh5vi(GOHjjDBZ9Wvr6gMR1dol8)9RnuqgXR9Pa5KO69vK8dGuzUplQGrKBDewQlF)eh6Vq3BiATyShYqkquGK)uZG0)5LWpfiNevVVIKFaKkJUj3NZcx(yyfS4WoICLwk0RSGNZBO8C(v1IoGV8sQBY9bu3K7Rq8zaUOhysKKyNe1CwWlJu8JUPjNnClVH6uW8lATyeYjO41pwolrItIAol4Lrk(rh6hqYeFUAT6yVqrRfHB79v3XKNRwRo2lu0Ar42EFfKr8AF0nWeLsYsKm75Q1QJ9cfTweUT3xDhhafiNevVVIKFaKkZX2Dw0ArmHf8YijixPLM4ed9kl458gkpNFfKr8AF0b8LNejZc9kl458gkpNFfpt9XpajssStIAol4Lrk(r30KZgUL3qDky(fTwmc5eu86hlNLiXjrnNf8Yif)Od9dyaj1n5(aQBY9vi(muGCsu9(ks(bqQmJxyPtO2uXX6FixPLM4ed9kl458gkpNFfKr8AF0nOYtIKzHELf8CEdLNZVINP(4hGejj2jrnNf8Yif)OBAYzd3YBOofm)IwlgHCckE9JLZsK4KOMZcEzKIF0H(bmGK6MCFa1n5(keFgkqojQEFfj)aivM0RdZLVIwlC5JHDmHcKtIQ3xrYpasLbwJJwwuR4hDctbYjr17Ri5haPYq6LWBa9GZcT1ry5kTu91AfqMmXHPSikegWPjkLKPa5KO69vK8dGuzIjS4UN(UzHUHewUsl9C1AfKjOz5)f6gsy1DKcKtIQ3xrYpasLzydT55CTci)96lHPa5KO69vK8dGuzGSpwBQqBDe(LR0sdhMYHAc72yIAKeOBWLNejHdt5qnHDBmrnscaLIE5jrs4WuourHWIOfJKqGE5HUbkpkqYFQXEjvMAgK0henKAaEVj3pFrgPMXj(ZuGCsu9(ks(bqQmpdh5neFuBQCLwk)pVewHWinmbrRf2lPYImKDKxH4dIgMeYAi)t8JLtEUATAEnYWxmN3grDhtolPBBUhUkegPHjiATWEjvwKHSJ8kiJ41(uGCsu9(ks(bqQmi9M29ZItfSCLwk)pVewHWinmbrRf2lPYImKDKxH4dIgMCws32CpCvimsdtq0AH9sQSidzh5vqgXR9Pa5KO69vK8dGuzgw2SUGS40ih5kTu(FEjScHrAycIwlSxsLfzi7iVcXhenmP(ATcitM4Wuwefcd4ufWsukjNu3K7dOtIQxfsVPD)S4ubRi9hjNL0Tn3dxfcJ0WeeTwyVKklYq2rEfKr8AFkqojQEFfj)aivgegPHjiATWEjvwKHSJ8YvAP6MCFaDsu9Qq6nT7NfNkyfP)i55Q1ks3WCTEWzH)VFTH6osbIcefiNevVVIyzFolDUdl)yz5whHLsC4CwqYq56rPphLwU5U9YsDsuZzbVmsXVCZD7LfS9zPatosV5kQEL6KOMZcEzKIFabgfiNevVVIyzFodGuzq6nT7NfNky5kTux(yyfS6yVqrRfHB79vqFrdDYlzIpxTwr6gMR1dol8)9Rnu3XKj(C1AfPByUwp4SW)3V2qbzeV2hWPkGLOuswIKZvRvh7fkATiCBVV6oM8C1A1XEHIwlc327RGmIx7d4ufWsukjlrY5Q1ks3WCTEWzH)VFTHcYiETFYzpxTwDSxOO1IWT9(kiJ41(dyauGCsu9(kIL95masLbP30UFwCQGLJKaXYIWHPC8sNkxPLM5ZvRvwp4neJD99Q(WjOHUe7KOMZcEzKIFjsa(diPUsNeciJ41(a6KOMZcEzKI)eLsYuGCsu9(kIL95masLXfixyMHIwliWE4tbYjr17Riw2NZaivgs3WCTEWzH)VFTbfiNevVVIyzFodGuzioColxPLM7q9tG(4YwXProQOiOvBAYzd3YBOMKqg6V4ubR41pwolrsUd1pb6JlBfNg5OIIGwTPjDsuZzbVmsXp6agfiNevVVIyzFodGuzgw2SUGS40ih5kT0zd3YBOsVmewwRlcNef5v86hlNLirFTwbKjtCyklIcHbmLKLib6vwWZ5nuEo)kiJ41(aoOjHELf8CEdLNZVINP(4Pa5KO69vel7ZzaKkZ5gKjmmb5kTuYehMYVqdDsu96w0HEfWKij3H6Na9XLTItJCurrqR2ujsiDBZ9WvnSSzDbzXProkiJ41(OZjrnNf8Yif)a3uswIKmFUAT6y7olATiMWcEzKeuqgXR9Lib6vwWZ5nuEo)kiJ41(acSKqVYcEoVHYZ5xXZuF8uGCsu9(kIL95masLbP30UFwCQGLJKaXYIWHPC8sNkxPLM5ZvRvwp4neJD99Q(WjOHUbNcKtIQ3xrSSpNbqQmKjoAqh5Pa5KO69vel7ZzaKkdAL1kincIVz5ijqSSiCykhV0PYvAP6MCFai(hciNYlG6MCFfIpdfiNevVVIyzFodGuzM4WXUx5kT0WT8gQGHiVO1cEt9ugH3qXRFSCMcKtIQ3xrSSpNbqQmehoNLR0sd3YBOsVmewwRlcNef5v86hlNPa5KO69vel7ZzaKkZ5gKjmmb5kTus32CpCvdlBwxqwCAKJcYiETp6sStIAol4Lrk(LibydGcKtIQ3xrSSpNbqQmARVOvBQ4dyHglxPLQBY9bG4FiGCkVaQBY9vi(muGCsu9(kIL95masLzyzZ6cYItJCKR0sZDOgw2SUGS40ihfK1q(N4hllrs4wEd1WYM1fKf1QVF1RIx)y5mfiNevVVIyzFodGuzEgoYBi(O2u5ijqSSiCykhV0PYvAPNRwRMxJm8fZ5Truq2jbfiNevVVIyzFodGuzioColxPLs62M7HRAyzZ6cYItJCuqgXR9r3Chw(XYkIdNZcsgk)e9uGCsu9(kIL95masL5dMTIa6JuGCsu9(kIL95masL5z4iVH4JAtLJKaXYIWHPC8sNkxPLcznK)j(XYjpxTwf1OO1Iycl(r2HQpCcAaoWKlptigwItJCuZBRhLLLibYAi)t8JLt6YhdRGvwp4neJD99QG(Ig6Khfi5p1GAtnFHCTEWuZ99uMA0nKAq6nT7NfNkyQPHud0hJgk(awOXut(cRnLAgm(rMeutRPMyctnds9ullh1q6XeOg2jtOMMqUqiVeMAAn1etyQXjr1l14BMA8XrEZuJG9ultnrtnXeMACsu9snRJWkkqojQEFfXY(CgaPYG0BA3plovWYrsGyzr4WuoEPtPa5KO69vel7ZzaKkd0hJgk(awOXYrsGyzr4WuoEPtParbYjr17R(qkAL1k(jDqbYjr17R(aaPYmXHJDVYvAPHB5nubdrErRf8M6PmcVHIx)y5mfiNevVV6daKkJ26lA1Mk(awOXYvAP6MCFai(hciNYlG6MCFfIpdfiNevVV6daKkd0hJgk(awOXYvAPNRwRiDdZ16bNf()(1gQ7yYeFUATI0nmxRhCw4)7xBOGmIx7d4ufWsukjlrY5Q1QJ9cfTweUT3xDhtEUAT6yVqrRfHB79vqgXR9bCQcyjkLKhafi5p1GAtnFHCTEWuZ99uMA0nKAq6nT7NfNkyQPHud0hJgk(awOXut(cRnLAgm(rMeutRPMyctnds9ullh1q6XeOg2jtOMMqUqiVeMAAn1etyQXjr1l14BMA8XrEZuJG9ultnrtnXeMACsu9snRJWkkqojQEF1haivgKEt7(zXPcwUsl9C1AfPByUwp4SW)3V2qDhtM4ZvRvKUH5A9GZc)F)AdfKr8AFaNQawIsjzjsoxTwDSxOO1IWT9(Q7yYZvRvh7fkATiCBVVcYiETpGtvalrPK8aOa5KO69vFaGuzqRSwbPrq8nlhjbILfHdt54LovUslv3K7daX)qa5uEbu3K7Rq8zOa5KO69vFaGuzEgoYBi(O2u5kT0ZvRvZRrg(I582iQ7yYZvRvZRrg(I582ikiJ41(aonrPKmfiNevVV6daKkZhmBfb0hLR0s1n5(aq8peqoLxa1n5(keFgkqojQEF1haivMHLnRlilonYrUslv3K7daX)qa5uEbu3K7Rq8zscznK)j(XYj1xRvazYehMYIOqyatj5KZEUATcHrAycIwlSxsLfzi7iV6okrIUj3haI)HaYP8cOUj3xH4ZKmXZM7qnSSzDbzXProQOiOvBAYep75Q1ks3WCTEWzH)VFTH6okrY5Q1kKEt7(zH(ctq9HtqdWPsKefclIwKlgWPdUejZM7qnSSzDbzXProQOiOvBAsx(yyfSAyzZmC5)f)foVM7wf0x0qN8gWaso75Q1kegPHjiATWEjvwKHSJ8Q7ifiNevVV6daKkZZWrEdXh1MkxPLEUATAEnYWxmN3grDhtM7q9mCK3q8rTPkiJ41(acCsukjlrsUd1ZWrEdXh1MQGSgY)e)y5KZEUATI0nmxRhCw4)7xBOUJuGCsu9(QpaqQmUa5cZmu0Abb2dF5kT0zpxTwr6gMR1dol8)9Rnu3rkqojQEF1haivgs3WCTEWzH)VFTHCLw6SNRwRiDdZ16bNf()(1gQ7ifiNevVV6daKkdsVPD)S4ublxPLEUATcP30UFwOVWeu3rjs0n5(aq8peqoLx0PBY9vi(max0lVKHB5nuZRrg(I582ikE9JLZsKOBY9bG4FiGCkVOt3K7Rq8zaUttgUL3qfme5fTwWBQNYi8gkE9JLZsKCUATI0nmxRhCw4)7xBOUJuGCsu9(QpaqQmqFmAO4dyHgtbYjr17R(aaPYmSSzDbzXProYvAP5oudlBwxqwCAKJcYAi)t8JLPa5KO69vFaGuzEgoYBi(O2u5kT0ZvRvZRrg(I582iQ7ifikqYFQr(DzZ6cYuZG5QVF1lfiNevVVAOUKIwzTIFshuGCsu9(QH6caPYmXHJDVYvAP6MCFai(hciNYlG6MCFfIptYWT8gQGHiVO1cEt9ugH3qXRFSCMcKtIQ3xnuxaivgKEt7(zXPcwUsl9C1A1XEHIwlc327RUJjpxTwDSxOO1IWT9(kiJ41(aMsYuGCsu9(QH6caPYa9XOHIpGfASCLw65Q1QJ9cfTweUT3xDhtEUAT6yVqrRfHB79vqgXR9bmLKPa5KO69vd1fasL5z4iVH4JAtLR0spxTwnVgz4lMZBJOUJjpxTwnVgz4lMZBJOGmIx7d4ufWsukjlrYS5oupdh5neFuBQkkcA1MsbYjr17RgQlaKkZWYM1fKfNg5ixPLQVwRaYKjomLfrHWaovbSeLsYj1n5(aq8peqoLxa1n5(keFgjss8YZeIHL40ih1826rz5K5oupdh5neFuBQkkcA1MMm3H6z4iVH4JAtvqwd5FIFSSejlptigwItJCuJtyyJ0lNC2ZvRvi9M29Zc9fMG6oMu3K7daX)qa5uEbu3K7Rq8zaUojQEvOvwRG0ii(Mve)dbKt5nrdCauGCsu9(QH6caPYGwzTcsJG4BwoscellchMYXlDQCLwQUj3haI)HaYP8cOUj3xH4ZaC1n5(kiNYlfiNevVVAOUaqQmUa5cZmu0Abb2dFkqojQEF1qDbGuz(GzRiG(OCLwQUj3haI)HaYP8cOUj3xH4ZqbYjr17RgQlaKkZWYM1fKfNg5ixPLQVwRaYKjomLfrHWaovbSeLsYuGCsu9(QH6caPYq6gMR1dol8)9RnOa5KO69vd1fasL5z4iVH4JAtLR0spxTwnVgz4lMZBJOUJjZDOEgoYBi(O2ufKr8AFabojkLKPa5KO69vd1fasLbP30UFwCQGLR0sZDO(jqFCzR40ihvue0QnvIKZvRvi9M29Zc9fMG6dNGMuGrbYjr17RgQlaKkZWYM1fKfNg5ixPLU8mHyyjonYr9tG(4Y2K5oupdh5neFuBQcYiETp6awIsjzkqojQEF1qDbGuzEgoYBi(O2u5kTuiRH8pXpwMcKtIQ3xnuxaivgYehnOJ8YvAPZEUATcP30UFwOVWeuqgXR9Pa5KO69vd1fasLbP30UFwCQGPa5KO69vd1fasLb6JrdfFal0ykqojQEF1qDbGuzEgoYBi(O2u5kT0ZvRvZRrg(I582iQ7ifiNevVVAOUaqQmdlBwxqwCAKJCLw6YZeIHL40ih1826rz5K5oupdh5neFuBQkkcA1MkrYYZeIHL40ih14eg2i9YsKS8mHyyjonYr9tG(4YwCGdmg]] )
    end

end