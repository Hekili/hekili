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
        spec:RegisterPack( "Survival", 20201013.9, [[dyeD5aqivkEKkLOlja0MuP6tcamkbLoLGkRsLs4vc0SqLAxc9lvIHHsXXqLSmuINHsPPjaQRjOyBOuPVHsfgNkLIZjazDcqzEqI7Hk2hkvDquQiTqivpuLs1hvPuQrIsfLtkaOvkrMPkL0oLO(jkvuTuvkL8uvmvvsFfLkI9QQ)sQblYHPSyiEmutwuxgzZs6Ze1OfKtl1Qfa51sWSj52OQDR0VvmCICCbvTCGNdA6uDDuSDiPVdPmEb05rjTEbOA(sO9t4NR)6FYMtFzwydlSHl2WfBJSjGytaXsa9hNvj6psgUGjt)znE6phgaQnQM6psgRQXY)1)ahgaM(ti3LGbSlxKBpedsep8xGnpJY8EwmWQ(fyZJV8heMw5bG7J8NS50xMf2WcB4InCX2iBci2eqSeM)ymEOb8NtZZOmVN92bw1)tOoNP9r(tMG4)ClfPdda1gvtjsSZywNaIs3srIDo2hecisCXwUfjwydlSrusu6wks3kHkPej2lsHHnX)OAOd)R)jtvJr5)1Vmx)1)yyVN9p8mb8aUI(dTgIIYp6V)Lz5V(hd79S)Hbs62jE4FO1quu(r)9VmB)R)Hwdrr5h9)yyVN9pytP0g27z1Qg6)r1qxVgp9hCg((xoa)x)dTgIIYp6)bdANaT9hd7nQKMwIVjOiHIiXYFmS3Z(hSPuAd79SAvd9)OAORxJN(d0F)lhM)6FO1quu(r)pyq7eOT)yyVrL00s8nbfj2lsC9hd79S)bBkL2WEpRw1q)pQg6614P)GvKHk9(xMD)R)XWEp7Fma2ws7daqR)hAnefLF0F)lZo(R)XWEp7Fqmz9u1oOXfG)Hwdrr5h93F)pyfzOs)1Vmx)1)qRHOO8J(FWG2jqB)XnfTE0japupvnTYMmXtRhP1quuwKUls1bZafjueP6GzGrElW)yyVN9pHmG0m77Fzw(R)XWEp7FqRvznuQbTd)dTgIIYp6V)Lz7F9p0Aikk)O)hmODc02FamlvhGmfHdJQoazst8ieagPWZ0ssuwKUlsUb0oWKIaI36fksOisY4SiDxKWZOYdABSQmafbeV1luKqrKKX5)yyVN9pUb0oWKE)lhG)R)Hwdrr5h9)GbTtG2(dGzP6aKPiCyu1bitAIhHaWifEMwsIYI0DrYnG2bMuKr6pg27z)tvza69VCy(R)XWEp7FaeCwZ7vwBaWG2FO1quu(r)9Vm7(x)dTgIIYp6)bdANaT9NkJsPbeoKbKjT38KiHIijJZ)XWEp7FqRv5AdinYWJ8(xMD8x)JH9E2)Gdzfagp8p0Aikk)O)(x(28x)dTgIIYp6)bdANaT9N84ryiGjTKsJm8irVXf6vwKUlsHvKYJh71jWAknIIOCVYrOB4cIekIelIuXIIuE8imeWKwsPrgEKiG4TEHIekIKmolsH7pg27z)dcJJdrawF)lhq)1)qRHOO8J(FWG2jqB)jpEegcyslP0idps0BCHEL)JH9E2)GnaQ07FzUyZF9p0Aikk)O)hmODc02FQdMbksbfjSbDnGKPvKqrKQdMbg5Ta)JH9E2)KjZdPXHScaJ)9VmxC9x)JH9E2)GNbK71CkRni0yu(FO1quu(r)9VmxS8x)dTgIIYp6)bdANaT9hCiditqDfyyVN1uIe7fjwIHrKUls4zu5bTnIwRY1gqAKHhjwzuknGWHmGmP9MNej2lsqjsP0UbKjhksxejw(JH9E2)GW44qeG13)YCX2)6FO1quu(r)pyq7eOT)uhmduKcksyd6AajtRiHIivhmdmYBb(hd79S)PQSTqVYAOd6c07FzUcW)1)qRHOO8J(FmS3Z(NcTsPXdpVT5)GbTtG2(tDWmqrkOiHnORbKmTIekIuDWmWiVfOiDxKQmkLgq4qgqM0EZtIekIKmo)hmRyfPDdito8lZ17FzUcZF9p0Aikk)O)hmODc02FUrKYJhrRv5AdinYWJe9gxOx5)yyVN9pO1QCTbKgz4rE)lZf7(x)dTgIIYp6)bdANaT9NWks3islfORrR1idpsegcyslPePIffPBej3u06r0AvU2as3BLb2ZgP1quuwKcNiDxKWZOYdABeTwLRnG0idpsSYOuAaHdzazs7npjsSxKGsKsPDditouKUisS8hd79S)bHXXHiaRV)L5ID8x)dTgIIYp6)bdANaT9h8mQ8G2grRv5AdinYWJeRmkLgq4qgqM0EZtIe7fjOePuA3aYKdfPlIel)XWEp7FWgav69Vmx3M)6FmS3Z(NcTsPHHg)p0Aikk)O)(xMRa6V(hd79S)PQmwPSggA8)qRHOO8J(7FzwyZF9pg27z)JP5zazcONQgdg0G)Hwdrr5h93)YSW1F9p0Aikk)O)hmODc02FUrKamlvhGmfxcc7vgndWku7atsQxzTjjzaZzGrk8mTKeLfPIffP6GzGIuqrcBqxdizAfPGIelHrKqrKQdMbg5Ta)JH9E2)aDIuAhysV)LzHL)6FO1quu(r)pg27z)dKas06AO3R8FWG2jqB)bqvabdziksKUlsUPO1JHyndmOgPDksRHOO8FWSIvK2nGm5WVmxV)LzHT)1)yyVN9pydGk9hAnefLF0F)lZsa(V(hAnefLF0)JH9E2)uOvknE45Tn)hmODc02FQdMbksbfjSbDnGKPvKqrKQdMbg5Ta)dMvSI0UbKjh(L569VmlH5V(hAnefLF0)JH9E2)ajGeTUg69k)hmODc02FaufqWqgIIeP7IuyfPBej3u06rKgKH6PQLaeRrAnefLfPIffPBejeMAnINbK71CkRni0yuEKrsKcNiDxKcRiDJibywQoazkcyvzfGUPkqaOgpBDy2CVYAOd6cemsHNPLKOSivSOiTuGUgTwJm8iruhL5TIePIffj3u06reghhIaSgP1quuwKcNivSOiHWuRruBjca1Os7WhzK(dMvSI0UbKjh(L569VmlS7F9p0Aikk)O)hd79S)HFw5zGKgPD6pyq7eOT)KjeMAnQmNwxlnnCwDVbic79SrOB4cIe7fPa6pywXks7gqMC4xMR3)YSWo(R)Hwdrr5h9)yyVN9patYhGg6GUa9hmODc02FYectTgvMtRRLMgoRU3aeH9E2i0nCbrI9Iua9hmRyfPDdito8lZ17FzwUn)1)qRHOO8J(FmS3Z(hibKO11qVx5)GbTtG2(ZnIKBkA9isdYq9u1saI1iTgIIYI0Dr6grYnfTEe1wIaqnQ0o8rAnefLfP7I0nIeGzP6aKPOYCADT00Wz19gGiSpayKcptljrzr6UiDJibywQoazkcyvzfGUPkqaOgpBDy2CVYAOd6cemsHNPLKO8FWSIvK2nGm5WVmxV)LzjG(R)Hwdrr5h9)yyVN9p8ZkpdK0iTt)bZkwrA3aYKd)YC9(xMTS5V(hAnefLF0)JH9E2)amjFaAOd6c0FWSIvK2nGm5WVmxV)(FWz4F9lZ1F9p0Aikk)O)hmODc02FWZOYdABepdi3R5uwBqOXO8iG4TEHIe7fj2YM)yyVN9piQzY6kdG13)YS8x)dTgIIYp6)bdANaT9h8mQ8G2gXZaY9AoL1geAmkpciERxOiXErITS5pg27z)JTyc6atPXMs9(xMT)1)qRHOO8J(FWG2jqB)bpJkpOTr8mGCVMtzTbHgJYJaI36fksSxKylB(JH9E2)uBaHOMj)(xoa)x)JH9E2)OA5qouhGyYY806)Hwdrr5h93)YH5V(hAnefLF0)dg0obA7p4zu5bTnINbK71CkRni0yuEeq8wVqrI9Ie7YgrQyrrYBEs7Jo3KiHIiXfB)JH9E2)Gqaibk0R87Fz29V(hAnefLF0)dg0obA7p1woKRbeV1luKqrKyHDfPIffjeMAnINbK71CkRni0yuEKr6pg27z)J049SV)Lzh)1)qRHOO8J(FWG2jqB)XnGm5XCdDBXKiXEoIe7(hd79S)XGse21tv7HinzYk693)d0)RFzU(R)Hwdrr5h9)GbTtG2(JBkA9OtaEOEQAALnzINwpsRHOOSiDxKQdMbksOis1bZaJ8wG)XWEp7FczaPz23)YS8x)dTgIIYp6)bdANaT9N6GzGIuqrcBqxdizAfjueP6GzGrElqr6UiHWuRrVL0tv7HinuImqe6gUGiHIiXwr6UiDJi5MIwpAkPqMwcqzZhqKwdrr5)yyVN9pfALsJhEEBZV)Lz7F9p0Aikk)O)hmODc02FYJhHHaM0sknYWJe9gxOxzr6UifwrkpESxNaRP0ikIY9khHUHlisOisSisflks5XJWqatAjLgz4rIaI36fksOisY4SiforQyrrcHPwJ8ZkpdK0vgaRrgjr6UiHWuRr(zLNbs6kdG1iG4TEHIekIuDWmqr6IiXw2is3crsgNfPIffj3u06rKgKH6PQLaeRrAnefLfP7IectTgXZaY9AoL1geAmkpYijs3fjeMAnINbK71CkRni0yuEeq8wVqrcfrsgN)JH9E2)WpR8mqsJ0o9(xoa)x)dTgIIYp6)bdANaT9N84ryiGjTKsJm8irVXf6vwKUlsHvKYJh71jWAknIIOCVYrOB4cIekIelIuXIIuE8imeWKwsPrgEKiG4TEHIekIKmolsHtKkwuKCtrRhrAqgQNQwcqSgP1quuwKUlsim1Aepdi3R5uwBqOXO8iJKiDxKqyQ1iEgqUxZPS2GqJr5raXB9cfjuejzC(pg27z)dWK8bOHoOlqV)LdZF9pg27z)dATkRHsnOD4FO1quu(r)9Vm7(x)dTgIIYp6)bdANaT9haZs1bitr4WOQdqM0epcbGrk8mTKeLfP7IKBaTdmPiG4TEHIekIKmols3fj8mQ8G2gRkdqraXB9cfjuejzC(pg27z)JBaTdmP3)YSJ)6FO1quu(r)pyq7eOT)aywQoazkchgvDaYKM4riamsHNPLKOSiDxKCdODGjfzK(JH9E2)uvgGE)lFB(R)XWEp7FWZaY9AoL1geAmk)p0Aikk)O)(xoG(R)XWEp7FaeCwZ7vwBaWG2FO1quu(r)9VmxS5V(hd79S)PQmwPSggA8)qRHOO8J(7FzU46V(hAnefLF0)dg0obA7p1bZafPGIe2GUgqY0ksOis1bZaJ8wG)XWEp7FYK5H04qwbGX)(xMlw(R)XWEp7Fk0kLggA8)qRHOO8J(7FzUy7F9p0Aikk)O)hmODc02FQdMbksbfjSbDnGKPvKqrKQdMbg5Ta)JH9E2)uv2wOxzn0bDb69Vmxb4)6FO1quu(r)pyq7eOT)uhmduKcksyd6AajtRiHIivhmdmYBbks3fjeMAn6TKEQApePHsKbIq3Wfejuej2ks3fPkJsPbeoKbKjT38KiHIiXIiDlejzC(pg27z)tHwP04HN3287FzUcZF9pg27z)doKvay8W)qRHOO8J(7FzUy3)6FmS3Z(htZZaYeqpvngmOb)dTgIIYp6V)L5ID8x)dTgIIYp6)bdANaT9NLc01O1AKHhjI6OmVvKiDxKYJhHeqIwxd9ELJEJl0RSiDxKYJhHeqIwxd9ELJaQciyidrr)XWEp7FqRv5AdinYWJ8(xMRBZF9p0Aikk)O)hmODc02FaufqWqgIIeP7IuyfjeMAnYpR8mqsxzaSgHUHlisOisHrKkwuKUrKCtrRh5NvEgiPrANI0AikklsHtKUlsHvKUrKqyQ1iEgqUxZPS2GqJr5rgjrQyrr6grYnfTEePbzOEQAjaXAKwdrrzrkCIuXIIectTgrTLiauJkTdFKr6pg27z)dKas06AO3R87FzUcO)6FO1quu(r)pyq7eOT)SuGUgTwJm8iryiGjTKsKUls1bZafj2lsSlBePIffPLc01O1AKHhjkfIad)SKiDxKcRivhmduKcksyd6AajtRifuKmS3Zgl0kLgp882MJyd6AajtRiDlej2ksOis1bZaJ8wGIuXIIKBkA9i)SYZajns7uKwdrrzr6UiDJiHWuRr(zLNbs6kdG1iJKiforQyrr6grkpEeTwLRnG0idps0BCHELfP7IuLrP0achYaYK2BEsKqrKKX5)yyVN9pO1QCTbKgz4rE)lZcB(R)Hwdrr5h9)GbTtG2(tDWmqrkOiHnORbKmTIekIuDWmWiVfOiDxKqyQ1O3s6PQ9qKgkrgicDdxqKqrKy7FmS3Z(NcTsPXdpVT53)YSW1F9p0Aikk)O)hmODc02FUrKamlvhGmfxcc7vgndWku7atsQxzTjjzaZzGrk8mTKeLfPIffP6GzGIuqrcBqxdizAfPGIelHrKqrKQdMbg5Ta)JH9E2)aDIuAhysV)LzHL)6FO1quu(r)pyq7eOT)aywQoazkUee2RmAgGvO2bMKuVYAtsYaMZaJu4zAjjkls3fP6GzGIuqrcBqxdizAfPGIelHrKqrKQdMbg5Ta)JH9E2)4gq7at69VmlS9V(hAnefLF0)dg0obA7paMLQdqMIlbH9kJMbyfQDGjj1RS2KKmG5mWifEMwsIYI0DrQoygOifuKWg01asMwrkOiXsyejueP6GzGrElW)yyVN9pvarb8EL1oWKE)lZsa(V(hAnefLF0)dg0obA7pim1AKFw5zGKUYaynYijsflks1bZafPGIKH9E2yHwP04HN32CeBqxdizAfj2ls1bZaJ8wG)XWEp7F4NvEgiPrANE)lZsy(R)Hwdrr5h9)GbTtG2(ZnI0sb6A0AnYWJeHHaM0skrQyrrcHPwJElPNQ2drAOezGi0nCbrI9IelIuXIIuDWmqrkOizyVNnwOvknE45TnhXg01asMwrI9IuDWmWiVf4FmS3Z(hGj5dqdDqxGE)lZc7(x)dTgIIYp6)bdANaT9heMAn6TKEQApePHsKbIq3Wfejuej2(hd79S)PqRuA8WZBB(9VmlSJ)6FO1quu(r)pyq7eOT)CJiLhpIwRY1gqAKHhj6nUqVYI0Dr6grYnfTEeTwLRnG09wzG9SrAnefL)JH9E2)GwRY1gqAKHh593)JeGWdpI5)1Vmx)1)qRHOO8J(FWG2jqB)bWSuDaYueomQ6aKjnXJqayKcptljr5)yyVN9pUb0oWKE)lZYF9pg27z)d0jsPDGj9hAnefLF0F)lZ2)6FmS3Z(h8mGCVMtzTbHgJY)dTgIIYp6V)(7)bvca7z)YSWgwydxSHlwIb0FqZaBVYW)WoHD6Tv5aWY32bmrsKUgIePMxAaUivhGifaa9aarcqHNPbuwKGdpjsgJp8MtzrchYwzcgfLU1EjrITbmr62Nfvc4uwKon)Tlsqwx3cuKcGIKpI0TYyIuUrTH9SI0iraZhGif2lHtKclxbgUOOKOe7e2P3wLdalFBhWejr6AisKAEPb4IuDaIuaawrgQuaGibOWZ0aklsWHNejJXhEZPSiHdzRmbJIs3AVKiXflbmr62Nfvc4uwKon)Tlsqwx3cuKcGIKpI0TYyIuUrTH9SI0iraZhGif2lHtKclxbgUOO0T2ljsCXUbmr62Nfvc4uwKon)Tlsqwx3cuKcGIKpI0TYyIuUrTH9SI0iraZhGif2lHtKclxbgUOO0T2ljsCXocyI0TplQeWPSiDA(BxKGSUUfOifafjFePBLXePCJAd7zfPrIaMparkSxcNifwUcmCrrjrPaqEPb4uwKcJizyVNvKun0HrrP)aLi8xMLWeM)ibMARO)ClfPdda1gvtjsSZywNaIs3srIDo2hecisCXwUfjwydlSrusu6wks3kHkPej2lsHHnrrjrjd79SWOeGWdpI5b5CXnG2bMe3DLdGzP6aKPiCyu1bitAIhHaWifEMwsIYIsg27zHrjaHhEeZdY5c0jsPDGjjkzyVNfgLaeE4rmpiNl4za5EnNYAdcngLlkjkzyVNfgXzyqoxquZK1vgaRC3vo4zu5bTnINbK71CkRni0yuEeq8wVq2Zw2ikzyVNfgXzyqoxSftqhykn2ukU7kh8mQ8G2gXZaY9AoL1geAmkpciERxi7zlBeLmS3ZcJ4mmiNl1gqiQzYC3vo4zu5bTnINbK71CkRni0yuEeq8wVq2Zw2ikzyVNfgXzyqoxuTCihQdqmzzEADrjd79SWioddY5ccbGeOqVYC3vo4zu5bTnINbK71CkRni0yuEeq8wVq2ZUSPyrV5jTp6CtOWfBfLmS3ZcJ4mmiNlsJ3ZYDx5uB5qUgq8wVquyHDlweHPwJ4za5EnNYAdcngLhzKeLmS3ZcJ4mmiNlguIWUEQApePjtwrC3voUbKjpMBOBlMyph2vusuYWEplmiNl8mb8aUIeLmS3ZcdY5cdK0Tt8qrjd79SWGCUGnLsByVNvRAOZ9A8ehCgkkzyVNfgKZfSPuAd79SAvdDUxJN4aDU7khd7nQKMwIVjikSikzyVNfgKZfSPuAd79SAvdDUxJN4GvKHkXDx5yyVrL00s8nbzpxIsg27zHb5CXayBjTpaaTUOKH9Ewyqoxqmz9u1oOXfGIsIsg27zHrOhKZLqgqAML7UYXnfTE0japupvnTYMmXtRhP1quu(EDWmquQdMbg5TafLmS3ZcJqpiNlfALsJhEEBZC3vo1bZadInORbKmTOuhmdmYBbEhHPwJElPNQ2drAOezGi0nCbuy79BCtrRhnLuitlbOS5disRHOOSOKH9Ewye6b5CHFw5zGKgPDI7UYjpEegcyslP0idps0BCHELVh284XEDcSMsJOik3RCe6gUakSuSyE8imeWKwsPrgEKiG4TEHOiJZHRyreMAnYpR8mqsxzaSgzKUJWuRr(zLNbs6kdG1iG4TEHOuhmdmaYw2ClKX5IfDtrRhrAqgQNQwcqSgP1quu(octTgXZaY9AoL1geAmkpYiDhHPwJ4za5EnNYAdcngLhbeV1lefzCwuYWEplmc9GCUamjFaAOd6ce3DLtE8imeWKwsPrgEKO34c9kFpS5XJ96eynLgrruUx5i0nCbuyPyX84ryiGjTKsJm8iraXB9crrgNdxXIUPO1Jinid1tvlbiwJ0AikkFhHPwJ4za5EnNYAdcngLhzKUJWuRr8mGCVMtzTbHgJYJaI36fIImolkzyVNfgHEqoxqRvznuQbTdfLmS3ZcJqpiNlUb0oWK4URCamlvhGmfHdJQoazst8ieagPWZ0ssu(UBaTdmPiG4TEHOiJZ3XZOYdABSQmafbeV1lefzCwuYWEplmc9GCUuvgG4URCamlvhGmfHdJQoazst8ieagPWZ0ssu(UBaTdmPiJKOKH9Ewye6b5Cbpdi3R5uwBqOXOCrjd79SWi0dY5cGGZAEVYAdag0eLmS3ZcJqpiNlvLXkL1WqJlkzyVNfgHEqoxYK5H04qwbGXZDx5uhmdmi2GUgqY0IsDWmWiVfOOKH9Ewye6b5CPqRuAyOXfLmS3ZcJqpiNlvLTf6vwdDqxG4URCQdMbgeBqxdizArPoygyK3cuuYWEplmc9GCUuOvknE45TnZDx5uhmdmi2GUgqY0IsDWmWiVf4DeMAn6TKEQApePHsKbIq3WfqHT3RmkLgq4qgqM0EZtOWYTqgNfLmS3ZcJqpiNl4qwbGXdfLmS3ZcJqpiNlMMNbKjGEQAmyqdkkzyVNfgHEqoxqRv5AdinYWJWDx5SuGUgTwJm8iruhL5TIUNhpcjGeTUg69kh9gxOx575XJqcirRRHEVYravbemKHOirjd79SWi0dY5cKas06AO3Rm3DLdGQacgYqu09WIWuRr(zLNbs6kdG1i0nCbuctXI34MIwpYpR8mqsJ0ofP1quuoC3d7nim1Aepdi3R5uwBqOXO8iJuXI34MIwpI0GmupvTeGynsRHOOC4kweHPwJO2seaQrL2HpYijkzyVNfgHEqoxqRv5AdinYWJWDx5SuGUgTwJm8iryiGjTK6EDWmq2ZUSPyXLc01O1AKHhjkfIad)S09Wwhmdmi2GUgqY0g0WEpBSqRuA8WZBBoInORbKmT3c2IsDWmWiVfyXIUPO1J8ZkpdK0iTtrAnefLVFdctTg5NvEgiPRmawJmsHRyXBYJhrRv5AdinYWJe9gxOx57vgLsdiCiditAV5juKXzrjd79SWi0dY5sHwP04HN32m3DLtDWmWGyd6Aajtlk1bZaJ8wG3ryQ1O3s6PQ9qKgkrgicDdxaf2kkzyVNfgHEqoxGorkTdmjU7kNBamlvhGmfxcc7vgndWku7atsQxzTjjzaZzGrk8mTKeLlwSoygyqSbDnGKPnilHbL6GzGrElqrjd79SWi0dY5IBaTdmjU7khaZs1bitXLGWELrZaSc1oWKK6vwBssgWCgyKcptljr571bZadInORbKmTbzjmOuhmdmYBbkkzyVNfgHEqoxQaIc49kRDGjXDx5aywQoazkUee2RmAgGvO2bMKuVYAtsYaMZaJu4zAjjkFVoygyqSbDnGKPnilHbL6GzGrElqrjd79SWi0dY5c)SYZajns7e3DLdctTg5NvEgiPRmawJmsflwhmdmOH9E2yHwP04HN32CeBqxdizAzFDWmWiVfOOKH9Ewye6b5Cbys(a0qh0fiU7kNBwkqxJwRrgEKimeWKwsvSictTg9wspvThI0qjYarOB4cSNLIfRdMbg0WEpBSqRuA8WZBBoInORbKmTSVoygyK3cuuYWEplmc9GCUuOvknE45TnZDx5GWuRrVL0tv7HinuImqe6gUakSvuYWEplmc9GCUGwRY1gqAKHhH7UY5M84r0AvU2asJm8irVXf6v((nUPO1JO1QCTbKU3kdSNnsRHOOSOKOKH9EwyeRidvkiNlHmG0ml3DLJBkA9OtaEOEQAALnzINwpsRHOO896GzGOuhmdmYBbkkzyVNfgXkYqLcY5cATkRHsnODOOKH9EwyeRidvkiNlUb0oWK4URCamlvhGmfHdJQoazst8ieagPWZ0ssu(UBaTdmPiG4TEHOiJZ3XZOYdABSQmafbeV1lefzCwuYWEplmIvKHkfKZLQYae3DLdGzP6aKPiCyu1bitAIhHaWifEMwsIY3DdODGjfzKeLmS3ZcJyfzOsb5CbqWznVxzTbadAIsg27zHrSImuPGCUGwRY1gqAKHhH7UYPYOuAaHdzazs7npHImolkzyVNfgXkYqLcY5coKvay8qrjd79SWiwrgQuqoxqyCCicWk3DLtE8imeWKwsPrgEKO34c9kFpS5XJ96eynLgrruUx5i0nCbuyPyX84ryiGjTKsJm8iraXB9crrgNdNOKH9EwyeRidvkiNlydGkXDx5KhpcdbmPLuAKHhj6nUqVYIsg27zHrSImuPGCUKjZdPXHScaJN7UYPoygyqSbDnGKPfL6GzGrElqrjd79SWiwrgQuqoxWZaY9AoL1geAmkxuYWEplmIvKHkfKZfeghhIaSYDx5GdzazcQRad79SMI9SedZD8mQ8G2grRv5AdinYWJeRmkLgq4qgqM0EZtShkrkL2nGm5WailIsg27zHrSImuPGCUuv2wOxzn0bDbI7UYPoygyqSbDnGKPfL6GzGrElqrjd79SWiwrgQuqoxk0kLgp882M5gZkwrA3aYKd5Wf3DLtDWmWGyd6Aajtlk1bZaJ8wG3RmkLgq4qgqM0EZtOiJZIsg27zHrSImuPGCUGwRY1gqAKHhH7UY5M84r0AvU2asJm8irVXf6vwuYWEplmIvKHkfKZfeghhIaSYDx5e2BwkqxJwRrgEKimeWKwsvS4nUPO1JO1QCTbKU3kdSNnsRHOOC4UJNrLh02iATkxBaPrgEKyLrP0achYaYK2BEI9qjsP0UbKjhgazruYWEplmIvKHkfKZfSbqL4URCWZOYdABeTwLRnG0idpsSYOuAaHdzazs7npXEOePuA3aYKddGSikzyVNfgXkYqLcY5sHwP0WqJlkzyVNfgXkYqLcY5svzSsznm04Isg27zHrSImuPGCUyAEgqMa6PQXGbnOOKH9EwyeRidvkiNlqNiL2bMe3DLZnaMLQdqMIlbH9kJMbyfQDGjj1RS2KKmG5mWifEMwsIYflwhmdmi2GUgqY0gKLWGsDWmWiVfOOKH9EwyeRidvkiNlqcirRRHEVYCJzfRiTBazYHC4I7UYbqvabdzik6UBkA9yiwZadQrANI0AikklkzyVNfgXkYqLcY5c2aOsIsg27zHrSImuPGCUuOvknE45TnZnMvSI0UbKjhYHlU7kN6GzGbXg01asMwuQdMbg5TafLmS3ZcJyfzOsb5CbsajADn07vMBmRyfPDditoKdxC3voaQciyidrr3d7nUPO1Jinid1tvlbiwJ0AikkxS4nim1Aepdi3R5uwBqOXO8iJu4Uh2BamlvhGmfbSQScq3ufiauJNTomBUxzn0bDbcgPWZ0ssuUyXLc01O1AKHhjI6OmVvuXIUPO1JimooebynsRHOOC4kweHPwJO2seaQrL2HpYijkzyVNfgXkYqLcY5c)SYZajns7e3ywXks7gqMCihU4URCYectTgvMtRRLMgoRU3aeH9E2i0nCb2hqIsg27zHrSImuPGCUamjFaAOd6ce3ywXks7gqMCihU4URCYectTgvMtRRLMgoRU3aeH9E2i0nCb2hqIsg27zHrSImuPGCUajGeTUg69kZnMvSI0UbKjhYHlU7kNBCtrRhrAqgQNQwcqSgP1quu((nUPO1JO2seaQrL2HpsRHOO89BamlvhGmfvMtRRLMgoRU3aeH9baJu4zAjjkF)gaZs1bitraRkRa0nvbca14zRdZM7vwdDqxGGrk8mTKeLfLmS3ZcJyfzOsb5CHFw5zGKgPDIBmRyfPDditoKdxIsg27zHrSImuPGCUamjFaAOd6ce3ywXks7gqMCihUE)9)b]] )
    else
        spec:RegisterPack( "Survival", 20201013.1, [[dSKK3bqifPEervvxIOQI2Ki6tevvYOeH6ukaRseYRuunlIk3cqk7IKFrummifhdalJOkptb00uGQRbi2McK(McuACasCoajToaPI5bq3JiTpiLoOcuyHeLEiGuPlQarAJasv1hjQQGrcivXjvGIwjGAMkqu3ubIODcj(jGuvgQceHLsuvHEkqtfs6RevvQ9c1FjmykomvlwfpgXKf1LrTzs9zrA0kItlz1kq41qQMnLUne7wPFl1WvOJdivPLd65QA6cxxL2UIY3vqJxrY5fbRNOQmFIy)ingamQyWShmgf5Hg5HgaqdaduHgGkaObndogmsyKXGJobDpLXGRJWyqWlCwnZTyWrpbB7zmQyWVVqcJbNeX4d0rgzsRyY9OinImFHCTEu9sGUoK5leImyWZTSXG5IpyWShmgf5Hg5HgaqdaduHgGkaObnYdd63ysdXGGfY16r1lqxORdm4KkN5fFWGz(jyq5p1aEHZQzULAa65UbdPal)PgG(irFyi1aWaLJAKhAKhAOatbw(tndY8m2snakLAacAuyqB9XJrfd6JFGrfJcayuXGojQEXGOxwR4N0bgKx)y5mwwCGrrEyuXG86hlNXYIbjWkyy5yWZvRvKUH5A9GZc)F)Ad1DKAssnjMAoxTwr6gMR1dol8)9RnuqgXR9PgaPgauaHAse1KsYuJejuZ5Q1QJ9cfTweUT3xDhPMKuZ5Q1QJ9cfTweUT3xbzeV2NAaKAaqbeQjrutkjtndad6KO6fdI0BA3plovW4aJYaXOIb51pwoJLfdsGvWWYXGNRwRiDdZ16bNf()(1gQ7i1KKAsm1CUATI0nmxRhCw4)7xBOGmIx7tnasnaOac1KiQjLKPgjsOMZvRvh7fkATiCBVV6osnjPMZvRvh7fkATiCBVVcYiETp1ai1aGciutIOMusMAgag0jr1lge6JrdfFal0zCGrzWXOIb51pwoJLfdsGvWWYXG6MCFQzo1q8peqoLxQbqQr3K7Rq8PWGojQEXGARVOxBQ4dyHoJdmkabJkgKx)y5mwwmOtIQxmi6L1kincIVzmibwbdlhdQVwRaYKjomLfrHWudGudakGqnjIAsjzQjj1OBY9PM5udX)qa5uEPgaPgDtUVcXNcdssGyzr4WuoEmkaGdmkdkgvmiV(XYzSSyqcScgwogu3K7tnZPgI)HaYP8snasn6MCFfIpfg0jr1lg8dMTIa6J4aJYGfJkgKx)y5mwwmibwbdlhdQBY9PM5udX)qa5uEPgaPgDtUVcXNIAssnttnrrqV2uQjj1mn1CUATcHrAycIwlSxsLfzi7iV6osnjPMetn6R1kGmzIdtzruim1ai1aGciutIOMusMAKiHAMMAYDOgw2SUGS40ihvue0RnLAssnttnNRwRiDdZ16bNf()(1gQ7i1irc1mn1K7qnSSzDbzXProQOiOxBk1KKAoxTwH0BA3pl0xycQpCc6udGudauZaOgjsOMOqyr0ICXudGudaafQjj1mn1K7qnSSzDbzXProQOiOxBkg0jr1lgCyzZ6cYItJCWbgfGcgvmiV(XYzSSyqcScgwogCAQj3H6z4iVH4JAtvrrqV2uQjj1mn1CUATI0nmxRhCw4)7xBOUJyqNevVyWNHJ8gIpQnfhyuaQyuXG86hlNXYIbDsu9IbrVSwbPrq8nJbjWkyy5yqDtUp1mNAi(hciNYl1ai1OBY9vi(uutsQjXuZ5Q1kKEt7(zH(ctq9HtqNAaKAac1irc1OBY9PgaPgNevVkKEt7(zXPcwr6pOMbGbjjqSSiCykhpgfaWbgfaqdgvmiV(XYzSSyqcScgwogeYAi)t8JLPMKuZ0uZ5Q1ks3WCTEWzH)VFTH6osnjPMZvRvi9M29Zc9fMG6dNGo1ai1aemOtIQxm4ZWrEdXh1MIdmkaaagvmiV(XYzSSyqcScgwogCAQ5C1AfPByUwp4SW)3V2qDhXGojQEXGUa5cZmu0Abb2dFCGrba5HrfdYRFSCgllgKaRGHLJbNMAoxTwr6gMR1dol8)9Rnu3rmOtIQxmiPByUwp4SW)3V2ahyuayGyuXG86hlNXYIbjWkyy5yWZvRvi9M29Zc9fMG6osnsKqn6MCFQzo1q8peqoLxQbTuJUj3xH4trnanQba0qnsKqnNRwRiDdZ16bNf()(1gQ7ig0jr1lgeP30UFwCQGXbgfagCmQyqNevVyqOpgnu8bSqNXG86hlNXYIdmkaaemQyqE9JLZyzXGeyfmSCm40utue0Rnfd6KO6fdoSSzDbzXPro4ahyWH6cJkgfaWOIbDsu9IbrVSwXpPdmiV(XYzSS4aJI8WOIb51pwoJLfdsGvWWYXG6MCFQzo1q8peqoLxQbqQr3K7Rq8POMKut4wEdvWqKx0AbVPEkJWBO41pwoJbDsu9IbN4WXUxCGrzGyuXG86hlNXYIbjWkyy5yWZvRvh7fkATiCBVV6osnjPMZvRvh7fkATiCBVVcYiETp1ai1KsYyqNevVyqKEt7(zXPcghyugCmQyqE9JLZyzXGeyfmSCm45Q1QJ9cfTweUT3xDhPMKuZ5Q1QJ9cfTweUT3xbzeV2NAaKAsjzmOtIQxmi0hJgk(awOZ4aJcqWOIb51pwoJLfdsGvWWYXGNRwRMvJm8fZ4Tru3rQjj1CUATAwnYWxmJ3grbzeV2NAaKAaqbeQjrutkjtnsKqnttn5oupdh5neFuBQkkc61MIbDsu9IbFgoYBi(O2uCGrzqXOIb51pwoJLfdsGvWWYXG6R1kGmzIdtzruim1ai1aGciutIOMusMAssn6MCFQzo1q8peqoLxQbqQr3K7Rq8POgjsOMetnlpvigwItJCuZARhLLPMKutUd1ZWrEdXh1MQIIGETPutsQj3H6z4iVH4JAtvqwd5FIFSm1irc1S8uHyyjonYrnoHHnsVm1KKAMMAoxTwH0BA3pl0xycQ7i1KKA0n5(uZCQH4FiGCkVudGuJUj3xH4trnanQXjr1Rc9YAfKgbX3SI4FiGCkVutIOMbsndad6KO6fdoSSzDbzXPro4aJYGfJkgKx)y5mwwmOtIQxmi6L1kincIVzmibwbdlhdQBY9PM5udX)qa5uEPgaPgDtUVcXNIAaAuJUj3xb5uEXGKeiwweomLJhJca4aJcqbJkg0jr1lg0fixyMHIwliWE4Jb51pwoJLfhyuaQyuXG86hlNXYIbjWkyy5yqDtUp1mNAi(hciNYl1ai1OBY9vi(uyqNevVyWpy2kcOpIdmkaGgmQyqE9JLZyzXGeyfmSCmO(ATcitM4WuwefctnasnaOac1KiQjLKXGojQEXGdlBwxqwCAKdoWOaaayuXGojQEXGKUH5A9GZc)F)AdmiV(XYzSS4aJcaYdJkgKx)y5mwwmibwbdlhdEUATAwnYWxmJ3grDhPMKutUd1ZWrEdXh1MQGmIx7tnasndo1KiQjLKXGojQEXGpdh5neFuBkoWOaWaXOIb51pwoJLfdsGvWWYXG5ou)eOpUSvCAKJkkc61MsnsKqnNRwRq6nT7Nf6lmb1hobDQrk1aemOtIQxmisVPD)S4ubJdmkam4yuXG86hlNXYIbjWkyy5yWLNkedlXProQFc0hx2snjPMChQNHJ8gIpQnvbzeV2NAql1aeQjrutkjJbDsu9Ibhw2SUGS40ihCGrbaGGrfdYRFSCgllgKaRGHLJbHSgY)e)yzmOtIQxm4ZWrEdXh1MIdmkamOyuXG86hlNXYIbjWkyy5yWPPMZvRvi9M29Zc9fMGcYiETpg0jr1lgKmXrh6ipoWOaWGfJkg0jr1lgeP30UFwCQGXG86hlNXYIdmkaauWOIbDsu9IbH(y0qXhWcDgdYRFSCglloWOaaqfJkgKx)y5mwwmibwbdlhdEUATAwnYWxmJ3grDhXGojQEXGpdh5neFuBkoWOip0GrfdYRFSCgllgKaRGHLJbxEQqmSeNg5OM1wpkltnjPMChQNHJ8gIpQnvffb9AtPgjsOMLNkedlXProQXjmSr6LPgjsOMLNkedlXProQFc0hx2IbDsu9Ibhw2SUGS40ihCGdmyM1(1gyuXOaagvmOtIQxmiYv(KplJb51pwoJLfhyuKhgvmOtIQxm49zrfmYJb51pwoJLfhyugigvmiV(XYzSSyqNevVyqIBTcNevVcB9bg0wFiwhHXGK8JdmkdogvmiV(XYzSSyqcScgwog0jrnJf8Yif)uJuQbaQjj1eomLdvuiSiArUyQbqQr3K7tnYqnjMACsu9Qq6nT7NfNkyfP)GAaAudX)qa5uEPMbqnjIAsjzmOtIQxmisVPD)S4ubJdmkabJkgKx)y5mwwmibwbdlhd6KOMXcEzKIFQbqQzGutsQjClVHImXrh6iVIx)y5m1KKAc3YBOC74exmc5ShnuXRFSCgd6KO6fdsCRv4KO6vyRpWG26dX6img0hhQlCGrzqXOIb51pwoJLfdsGvWWYXGojQzSGxgP4NAaKAgi1KKAc3YBOitC0HoYR41pwoJbDsu9IbjU1kCsu9kS1hyqB9HyDegdoux4aJYGfJkgKx)y5mwwmibwbdlhd6KOMXcEzKIFQbqQzGutsQzAQjClVHYTJtCXiKZE0qfV(XYzQjj1mn1eUL3qnSSzDbzrT67x9Q41pwoJbDsu9IbjU1kCsu9kS1hyqB9HyDegd(boWOauWOIb51pwoJLfdsGvWWYXGojQzSGxgP4NAaKAgi1KKAc3YBOC74exmc5ShnuXRFSCMAssnttnHB5nudlBwxqwuR((vVkE9JLZyqNevVyqIBTcNevVcB9bg0wFiwhHXG(4h4aJcqfJkgKx)y5mwwmibwbdlhd6KOMXcEzKIFQbqQzGutsQjClVHYTJtCXiKZE0qfV(XYzQjj1eUL3qnSSzDbzrT67x9Q41pwoJbDsu9IbjU1kCsu9kS1hyqB9HyDegd6Jd1foWOaaAWOIb51pwoJLfdsGvWWYXGojQzSGxgP4NAaKAgi1KKAMMAc3YBOC74exmc5ShnuXRFSCMAssnHB5nudlBwxqwuR((vVkE9JLZyqNevVyqIBTcNevVcB9bg0wFiwhHXGd1foWOaaayuXG86hlNXYIbjWkyy5yqNe1mwWlJu8tnOLAaGAssnttnHB5nuNcMFrRfJqobfV(XYzQrIeQXjrnJf8Yif)udAPg5HbDsu9IbjU1kCsu9kS1hyqB9HyDegdsSSpJXbgfaKhgvmOtIQxmiPxcVb0dol0whHXG86hlNXYIdmkamqmQyqNevVyqhs8LfrdH8gyqE9JLZyzXbgfagCmQyqNevVyWJNkATiGfb9hdYRFSCglloWbgKyzFgJrfJcayuXG86hlNXYIb7rm4ZrPXGojQEXGZCy5hlJbN5qX6imgK4WzSGKHyqcScgwog0jrnJf8Yif)udGudqWGZC7LfS9zmiqWGZC7LXGojQzSGxgP4hhyuKhgvmiV(XYzSSyqcScgwog0LpgwbRo2lu0Ar42EFf0x0Pg0snOHAssnjMAoxTwr6gMR1dol8)9Rnu3rQjj1KyQ5C1AfPByUwp4SW)3V2qbzeV2NAaKAaqbeQjrutkjtnsKqnNRwRo2lu0Ar42EF1DKAssnNRwRo2lu0Ar42EFfKr8AFQbqQbafqOMernPKm1irc1CUATI0nmxRhCw4)7xBOGmIx7tnjPMPPMZvRvh7fkATiCBVVcYiETp1maQzayqNevVyqKEt7(zXPcghyugigvmiV(XYzSSyqNevVyqKEt7(zXPcgdsGvWWYXGz(C1AL1dEdXyxFVQpCc6udAPMetnojQzSGxgP4NAKiHAaQuZaOMKuJUsNeciJ41(udGuJtIAgl4Lrk(PMernPKmgKKaXYIWHPC8yuaahyugCmQyqNevVyqxGCHzgkATGa7HpgKx)y5mwwCGrbiyuXGojQEXGKUH5A9GZc)F)AdmiV(XYzSS4aJYGIrfdYRFSCgllgKaRGHLJbZDO(jqFCzR40ihvue0RnLAssnttnHB5nutsid9xCQGv86hlNPgjsOMChQFc0hx2konYrffb9AtPMKuJtIAgl4Lrk(Pg0snabd6KO6fdsC4mghyugSyuXG86hlNXYIbjWkyy5yWPPMWT8gQ0ldHL16IWjrrEfV(XYzQrIeQrFTwbKjtCyklIcHPgaPMusMAKiHAGELf8mEdLNZVcYiETp1ai1mOutsQb6vwWZ4nuEo)kEQ6Jhd6KO6fdoSSzDbzXPro4aJcqbJkgKx)y5mwwmibwbdlhdsM4Wu(fAOtIQx3snOLAKNciuJejutUd1pb6JlBfNg5OIIGETPuJejudPBBUhUQHLnRlilonYrbzeV2NAql14KOMXcEzKIFQbOrnPKm1irc1K5ZvRvhB3zrRfXewWlJKGcYiETp1irc1a9kl4z8gkpNFfKr8AFQbqQbiutsQb6vwWZ4nuEo)kEQ6Jhd6KO6fdEUbzcdtahyuaQyuXG86hlNXYIbDsu9Ibr6nT7NfNkymibwbdlhdM5ZvRvwp4neJD99Q(WjOtnOLAakyqscellchMYXJrbaCGrba0Grfd6KO6fdsM4OdDKhdYRFSCglloWOaaayuXG86hlNXYIbDsu9IbrVSwbPrq8nJbjWkyy5yqDtUp1mNAi(hciNYl1ai1OBY9vi(uyqscellchMYXJrbaCGrba5HrfdYRFSCgllgKaRGHLJbd3YBOcgI8Iwl4n1tzeEdfV(XYzmOtIQxm4eho29IdmkamqmQyqE9JLZyzXGeyfmSCmy4wEdv6LHWYADr4KOiVIx)y5mg0jr1lgK4WzmoWOaWGJrfdYRFSCgllgKaRGHLJbjDBZ9WvnSSzDbzXProkiJ41(udAPMetnojQzSGxgP4NAKiHAac1mamOtIQxm45gKjmmbCGrbaGGrfdYRFSCgllgKaRGHLJb1n5(uZCQH4FiGCkVudGuJUj3xH4tHbDsu9Ib1wFrV2uXhWcDghyuayqXOIb51pwoJLfdsGvWWYXG5oudlBwxqwCAKJcYAi)t8JLPgjsOMWT8gQHLnRlilQvF)QxfV(XYzmOtIQxm4WYM1fKfNg5GdmkamyXOIb51pwoJLfd6KO6fd(mCK3q8rTPyqcScgwog8C1A1SAKHVygVnIcYojWGKeiwweomLJhJca4aJcaafmQyqE9JLZyzXGeyfmSCmiPBBUhUQHLnRlilonYrbzeV2NAql1mZHLFSSI4WzSGKHuJmuJ8WGojQEXGehoJXbgfaaQyuXGojQEXGFWSveqFedYRFSCglloWOip0GrfdYRFSCgllg0jr1lg8z4iVH4JAtXGeyfmSCmiK1q(N4hltnjPMZvRvrnkATiMWIFKDO6dNGo1ai1mqQjj1S8uHyyjonYrnRTEuwMAKiHAGSgY)e)yzQjj14YhdRGvwp4neJD99QG(Io1GwQbnyqscellchMYXJrbaCGrrEaGrfdYRFSCgllg0jr1lgeP30UFwCQGXGKeiwweomLJhJca4aJI8KhgvmiV(XYzSSyqNevVyqOpgnu8bSqNXGKeiwweomLJhJca4ahyWritAKJhyuXOaagvmiV(XYzSSyW1rymOlF)eh6Vq3BiATyShYqmOtIQxmOlF)eh6Vq3BiATyShYqCGrrEyuXGojQEXGPxhMlFfTw4Yhd7ycgKx)y5mwwCGrzGyuXGojQEXGKUH5A9GZc)F)AdmiV(XYzSS4aJYGJrfd6KO6fdoSH28mUwbK)E9LWyqE9JLZyzXbgfGGrfd6KO6fd(bZwra9rmiV(XYzSS4aJYGIrfd6KO6fdoXHJDVyqE9JLZyzXboWGK8JrfJcayuXG86hlNXYIbjWkyy5yqs32CpCvKUH5A9GZc)F)AdfKr8AFQbTuZardg0jr1lg8y7ol0xyc4aJI8WOIb51pwoJLfdsGvWWYXGKUT5E4QiDdZ16bNf()(1gkiJ41(udAPMbIgmOtIQxmOVe(dOBfe3AXbgLbIrfdYRFSCgllgKaRGHLJbjDBZ9Wvr6gMR1dol8)9RnuqgXR9Pg0sndenyqNevVyqDb5JT7moWOm4yuXGojQEXG2kDs8IbXnNIWBGb51pwoJLfhyuacgvmiV(XYzSSyqcScgwogK0Tn3dxfPByUwp4SW)3V2qbzeV2NAql1mOOHAKiHAIcHfrlYftnasnamqmOtIQxm4HHpdrV2uCGrzqXOIb51pwoJLfdsGvWWYXGNRwRsVomx(kATWLpg2Xe1DKAssnjMAoxTwDy4Zq0RnvDhPgjsOMZvRvhB3zH(ctqDhPgjsOMPPgOtyvaBRLAga1irc1KyQH07Fr8JLvJDu9kAT4UhyLTCwOVWeOMKuJUsNeciJ41(udGuZGca1irc1OR0jHaYiETp1ai1iVbLAga1irc1mn1W)ZlHvKEZ8(CwylnRBiHvi(GOHutsQ5C1AfPByUwp4SW)3V2qDhXGojQEXGJDu9IdmkdwmQyqE9JLZyzXGeyfmSCmy4Wuou56dFjm1GwPuZGIbDsu9Ib9FKjHO1Iyclyp1Y4aJcqbJkgKx)y5mwwmOtIQxmO)tM5l)cOlFnuqAOBXGeyfmSCm45Q1kegPHjiATWEjvwKHSJ8Q7i1KKA0v6KqazeV2NAaKAiDBZ9WvHWinmbrRf2lPYImKDKxbzeV2NAMtnaaeQrIeQ5C1Av61H5YxrRfU8XWoMO(WjOtnsPgGqnjPgDLojeqgXR9PgaPgs32CpCvPxhMlFfTw4Yhd7yIcYiETp1mNAKhAOgjsOMmFUATc6YxdfKg6wrMpxTwL7Hl1irc1OR0jHaYiETp1ai1ipaOgjsOMZvRvdBOnpJRva5VxFjScYiETp1KKA0v6KqazeV2NAaKAiDBZ9WvnSH28mUwbK)E9LWkiJ41(uZCQbaGc1irc1mn1eUL3qDky(fTwmc5eu86hlNPMKuJUsNeciJ41(udGudPBBUhUks3WCTEWzH)VFTHcYiETp1mNAKhAOMKuZ5Q1ks3WCTEWzH)VFTHcYiETpgCDegd6)Kz(YVa6YxdfKg6wCGrbOIrfdYRFSCgllg0jr1lgm1TmXTwg(It3lgKaRGHLJbjDBZ9WvHWinmbrRf2lPYImKDKxbzeV2NAKiHAc3YBOgw2SUGSOw99REv86hlNPMKudPBBUhUks3WCTEWzH)VFTHcYiETp1irc1mn1W)ZlHvimsdtq0AH9sQSidzh5vi(GOHutsQH0Tn3dxfPByUwp4SW)3V2qbzeV2hdUocJbtDltCRLHV409IdmkaGgmQyqE9JLZyzXGRJWyqx((jo0FHU3q0AXypKHyqNevVyqx((jo0FHU3q0AXypKH4aJcaaGrfdYRFSCgllgKaRGHLJbHELf8mEdLNZVQwQbTudqfnutsQr3K7tnasn6MCFfIpf1a0Og5beQrIeQjXuJtIAgl4Lrk(Pg0snaqnjPMPPMWT8gQtbZVO1IriNGIx)y5m1irc14KOMXcEzKIFQbTuJ8OMbqnjPMetnNRwRo2lu0Ar42EF1DKAssnNRwRo2lu0Ar42EFfKr8AFQbTuZaPMernPKm1irc1mn1CUAT6yVqrRfHB79v3rQzayqNevVyqDtUpNfU8XWkyXHDeCGrba5HrfdYRFSCgllgKaRGHLJbtm1KyQb6vwWZ4nuEo)kiJ41(udAPgGkAOgjsOMPPgOxzbpJ3q558R4PQpEQzauJejutIPgNe1mwWlJu8tnOLAaGAssnttnHB5nuNcMFrRfJqobfV(XYzQrIeQXjrnJf8Yif)udAPg5rndGAga1KKA0n5(udGuJUj3xH4tHbDsu9Ibp2UZIwlIjSGxgjbCGrbGbIrfdYRFSCgllgKaRGHLJbtm1KyQb6vwWZ4nuEo)kiJ41(udAPMbfnuJejuZ0ud0RSGNXBO8C(v8u1hp1maQrIeQjXuJtIAgl4Lrk(Pg0snaqnjPMPPMWT8gQtbZVO1IriNGIx)y5m1irc14KOMXcEzKIFQbTuJ8OMbqndGAssn6MCFQbqQr3K7Rq8PWGojQEXGJxyPtO2uXX6FGdmkam4yuXGojQEXGPxhMlFfTw4Yhd7ycgKx)y5mwwCGrbaGGrfd6KO6fdcRXrllQv8JoHXG86hlNXYIdmkamOyuXG86hlNXYIbjWkyy5yq91AfqMmXHPSikeMAaKAaGAse1KsYyqNevVyqsVeEdOhCwOTocJdmkamyXOIb51pwoJLfdsGvWWYXGNRwRGmbDl)Vq3qcRUJyqNevVyWyclU7PVBwOBiHXbgfaakyuXGojQEXGdBOnpJRva5VxFjmgKx)y5mwwCGrbaGkgvmiV(XYzSSyqcScgwogmCykhQjSBJjQrsqnOLAakOHAKiHAchMYHAc72yIAKeudGsPg5HgQrIeQjCykhQOqyr0IrsiKhAOg0sndenyqNevVyqi7J1Mk0whHFCGrrEObJkgKx)y5mwwmibwbdlhdY)ZlHvimsdtq0AH9sQSidzh5vi(GOHutsQbYAi)t8JLPMKuZ5Q1Qz1idFXmEBe1DKAssnttnKUT5E4QqyKgMGO1c7LuzrgYoYRGmIx7JbDsu9IbFgoYBi(O2uCGrrEaGrfdYRFSCgllgKaRGHLJb5)5LWkegPHjiATWEjvwKHSJ8keFq0qQjj1mn1q62M7HRcHrAycIwlSxsLfzi7iVcYiETpg0jr1lgeP30UFwCQGXbgf5jpmQyqE9JLZyzXGeyfmSCmi)pVewHWinmbrRf2lPYImKDKxH4dIgsnjPg91AfqMmXHPSikeMAaKAaqbeQjrutkjtnjPgDtUp1ai14KO6vH0BA3plovWks)b1KKAMMAiDBZ9WvHWinmbrRf2lPYImKDKxbzeV2hd6KO6fdoSSzDbzXPro4aJI8gigvmiV(XYzSSyqcScgwogu3K7tnasnojQEvi9M29ZItfSI0FqnjPMZvRvKUH5A9GZc)F)Ad1Ded6KO6fdIWinmbrRf2lPYImKDKhh4ad(bgvmkaGrfd6KO6fdIEzTIFshyqE9JLZyzXbgf5HrfdYRFSCgllgKaRGHLJbd3YBOcgI8Iwl4n1tzeEdfV(XYzmOtIQxm4eho29IdmkdeJkgKx)y5mwwmibwbdlhdQBY9PM5udX)qa5uEPgaPgDtUVcXNcd6KO6fdQT(IETPIpGf6moWOm4yuXG86hlNXYIbjWkyy5yWZvRvKUH5A9GZc)F)Ad1DKAssnjMAoxTwr6gMR1dol8)9RnuqgXR9PgaPgauaHAse1KsYuJejuZ5Q1QJ9cfTweUT3xDhPMKuZ5Q1QJ9cfTweUT3xbzeV2NAaKAaqbeQjrutkjtndad6KO6fdc9XOHIpGf6moWOaemQyqE9JLZyzXGeyfmSCm45Q1ks3WCTEWzH)VFTH6osnjPMetnNRwRiDdZ16bNf()(1gkiJ41(udGudakGqnjIAsjzQrIeQ5C1A1XEHIwlc327RUJutsQ5C1A1XEHIwlc327RGmIx7tnasnaOac1KiQjLKPMbGbDsu9Ibr6nT7NfNkyCGrzqXOIb51pwoJLfd6KO6fdIEzTcsJG4BgdsGvWWYXG6MCFQzo1q8peqoLxQbqQr3K7Rq8PWGKeiwweomLJhJca4aJYGfJkgKx)y5mwwmibwbdlhdEUATAwnYWxmJ3grDhPMKuZ5Q1Qz1idFXmEBefKr8AFQbqQbaQjrutkjJbDsu9IbFgoYBi(O2uCGrbOGrfdYRFSCgllgKaRGHLJb1n5(uZCQH4FiGCkVudGuJUj3xH4tHbDsu9Ib)GzRiG(ioWOauXOIb51pwoJLfdsGvWWYXG6MCFQzo1q8peqoLxQbqQr3K7Rq8POMKudK1q(N4hltnjPg91AfqMmXHPSikeMAaKAsjzQjj1mn1CUATcHrAycIwlSxsLfzi7iV6osnsKqn6MCFQzo1q8peqoLxQbqQr3K7Rq8POMKutIPMPPMChQHLnRlilonYrffb9AtPMKutIPMPPMZvRvKUH5A9GZc)F)Ad1DKAKiHAoxTwH0BA3pl0xycQpCc6udGudauJejutuiSiArUyQbqQbaGc1irc1mn1K7qnSSzDbzXProQOiOxBk1KKAC5JHvWQHLnZWL)x8x4SAMBvqFrNAql1GgQzauZaOMKuZ0uZ5Q1kegPHjiATWEjvwKHSJ8Q7ig0jr1lgCyzZ6cYItJCWbgfaqdgvmiV(XYzSSyqcScgwog8C1A1SAKHVygVnI6osnjPMChQNHJ8gIpQnvbzeV2NAaKAgCQjrutkjtnsKqn5oupdh5neFuBQcYAi)t8JLPMKuZ0uZ5Q1ks3WCTEWzH)VFTH6oIbDsu9IbFgoYBi(O2uCGrbaaWOIb51pwoJLfdsGvWWYXGttnNRwRiDdZ16bNf()(1gQ7ig0jr1lg0fixyMHIwliWE4JdmkaipmQyqE9JLZyzXGeyfmSCm40uZ5Q1ks3WCTEWzH)VFTH6oIbDsu9IbjDdZ16bNf()(1g4aJcadeJkgKx)y5mwwmibwbdlhdEUATcP30UFwOVWeu3rQrIeQr3K7tnZPgI)HaYP8snOLA0n5(keFkQbOrnYdnutsQjClVHAwnYWxmJ3grXRFSCMAKiHA0n5(uZCQH4FiGCkVudAPgDtUVcXNIAaAudautsQjClVHkyiYlATG3upLr4nu86hlNPgjsOMZvRvKUH5A9GZc)F)Ad1Ded6KO6fdI0BA3plovW4aJcadogvmOtIQxmi0hJgk(awOZyqE9JLZyzXbgfaacgvmiV(XYzSSyqcScgwogm3HAyzZ6cYItJCuqwd5FIFSmg0jr1lgCyzZ6cYItJCWbgfagumQyqE9JLZyzXGeyfmSCm45Q1Qz1idFXmEBe1Ded6KO6fd(mCK3q8rTP4ahyqFCOUWOIrbamQyqNevVyq0lRv8t6adYRFSCglloWOipmQyqE9JLZyzXGeyfmSCm45Q1QJ9cfTweUT3xDhPMKuZ5Q1QJ9cfTweUT3xbzeV2NAaKAsjzmOtIQxmisVPD)S4ubJdmkdeJkgKx)y5mwwmibwbdlhdEUAT6yVqrRfHB79v3rQjj1CUAT6yVqrRfHB79vqgXR9PgaPMusgd6KO6fdc9XOHIpGf6moWOm4yuXG86hlNXYIbjWkyy5yWPPMChQNHJ8gIpQnvffb9AtXGojQEXGpdh5neFuBkoWOaemQyqNevVyqxGCHzgkATGa7HpgKx)y5mwwCGrzqXOIb51pwoJLfdsGvWWYXG6R1kGmzIdtzruim1ai1aGciutIOMusMAKiHA0n5(uZCQH4FiGCkVudGuJUj3xH4trnjPMetnlpvigwItJCuZARhLLPMKutUd1ZWrEdXh1MQIIGETPutsQj3H6z4iVH4JAtvqwd5FIFSm1irc1S8uHyyjonYrnoHHnsVm1KKAMMAoxTwH0BA3pl0xycQ7i1KKA0n5(uZCQH4FiGCkVudGuJUj3xH4trnanQXjr1Rc9YAfKgbX3SI4FiGCkVutIOMbsndad6KO6fdoSSzDbzXPro4aJYGfJkg0jr1lgK0nmxRhCw4)7xBGb51pwoJLfhyuakyuXG86hlNXYIbjWkyy5yWZvRvi9M29Zc9fMGcYiETp1KKAwEQqmSeNg5OgNWWgPxgd6KO6fdI0BA3plovW4aJcqfJkgKx)y5mwwmOtIQxmi6L1kincIVzmibwbdlhdQVwRaYKjomLfrHWudGudakGqnjIAsjzQjj1OBY9PM5udX)qa5uEPgaPgDtUVcXNIAaAuJ8qdgKKaXYIWHPC8yuaahyuaanyuXG86hlNXYIbjWkyy5yqDtUp1mNAi(hciNYl1ai1OBY9vi(uyqNevVyWpy2kcOpIdmkaaagvmiV(XYzSSyqcScgwog8C1AvuJIwlIjS4hzhQ(WjOtnsPMbsnsKqn5ou)eOpUSvCAKJkkc61MIbDsu9IbH(y0qXhWcDghyuaqEyuXG86hlNXYIbjWkyy5yWChQFc0hx2konYrffb9AtXGojQEXGi9M29ZItfmoWOaWaXOIb51pwoJLfdsGvWWYXGlpvigwItJCu)eOpUSLAssn6MCFQbTuZard1KKAYDOEgoYBi(O2ufKr8AFQbTudqOMernPKmg0jr1lgCyzZ6cYItJCWbgfagCmQyqE9JLZyzXGeyfmSCm40uZ5Q1kKEt7(zH(ctqbzeV2hd6KO6fdsM4OdDKhhyuaaiyuXG86hlNXYIbjWkyy5yqiRH8pXpwgd6KO6fd(mCK3q8rTP4aJcadkgvmiV(XYzSSyqNevVyq0lRvqAeeFZyqcScgwogu3K7tnZPgI)HaYP8snasn6MCFfIpf1KKAsm1CUATcP30UFwOVWeuF4e0PgaPgGqnsKqn6MCFQbqQXjr1RcP30UFwCQGvK(dQzayqscellchMYXJrbaCGrbGblgvmOtIQxmi0hJgk(awOZyqE9JLZyzXbgfaakyuXG86hlNXYIbjWkyy5yWZvRvi9M29Zc9fMG6osnsKqn6MCFQbTuZGJgQrIeQj3H6Na9XLTItJCurrqV2umOtIQxmisVPD)S4ubJdmkaauXOIb51pwoJLfdsGvWWYXGlpvigwItJCuZARhLLPMKutUd1ZWrEdXh1MQIIGETPuJejuZYtfIHL40ih14eg2i9YuJejuZYtfIHL40ih1pb6JlBPMKuJUj3NAql1ae0GbDsu9Ibhw2SUGS40ihCGdCGbNXWV6fJI8qJ8qdaOba5PaQyWHoCRn9XGYVhmKFeLbtuKFaOd1qnOoHPMczSHb1OBi1i)kZA)Ad5xudKb69wqotnFJWuJFJgXdotnKj(MYVIc8GCTm1m4aDOgGU9oJHbNPgWcbOl18jSHpf1i)KAIMAgKVo1KRz1x9sn9id9OHutILzautIbyQbOOatbw(9GH8JOmyII8daDOgQb1jm1uiJnmOgDdPg5xel7Zy5xudKb69wqotnFJWuJFJgXdotnKj(MYVIc8GCTm1aaqbOd1a0T3zmm4m1awiaDPMpHn8POg5Nut0uZG81PMCnR(QxQPhzOhnKAsSmdGAsmatnaffykWdMiJnm4m1auOgNevVuJT(4vuGXG)itWOipGaem4iS1LLXGYFQb8cNvZCl1a0ZDdgsbw(tna9rI(WqQbGbkh1ip0ip0qbMcS8NAgK5zSLAauk1ae0OOatb2jr17RgHmProEmxQm3NfvWiYTocl1LVFId9xO7neTwm2dzifyNevVVAeYKg54XCPYKEDyU8v0AHlFmSJjuGDsu9(QritAKJhZLkdPByUwp4SW)3V2GcStIQ3xnczsJC8yUuzg2qBEgxRaYFV(sykWojQEF1iKjnYXJ5sL5dMTIa6JuGDsu9(QritAKJhZLkZeho29sbMcStIQ3FUuzqUYN8zzkWojQE)5sL5(SOcg5Pa7KO69NlvgIBTcNevVcB9HCRJWsj5NcStIQ3FUuzq6nT7NfNky5kTuNe1mwWlJu8lfGKHdt5qffclIwKlgqDtUV8Ze7KO6vH0BA3plovWks)bqJ4FiGCkVdirPKmfyNevV)CPYqCRv4KO6vyRpKBDewQpouxYvAPojQzSGxgP4hWbMmClVHImXrh6iVIx)y5CYWT8gk3ooXfJqo7rdv86hlNPa7KO69NlvgIBTcNevVcB9HCRJWshQl5kTuNe1mwWlJu8d4atgUL3qrM4OdDKxXRFSCMcStIQ3FUuziU1kCsu9kS1hYTocl9d5kTuNe1mwWlJu8d4atoD4wEdLBhN4IriN9OHkE9JLZjNoClVHAyzZ6cYIA13V6vXRFSCMcStIQ3FUuziU1kCsu9kS1hYTocl1h)qUsl1jrnJf8Yif)aoWKHB5nuUDCIlgHC2JgQ41pwoNC6WT8gQHLnRlilQvF)QxfV(XYzkWojQE)5sLH4wRWjr1RWwFi36iSuFCOUKR0sDsuZybVmsXpGdmz4wEdLBhN4IriN9OHkE9JLZjd3YBOgw2SUGSOw99REv86hlNPa7KO69NlvgIBTcNevVcB9HCRJWshQl5kTuNe1mwWlJu8d4atoD4wEdLBhN4IriN9OHkE9JLZjd3YBOgw2SUGSOw99REv86hlNPa7KO69NlvgIBTcNevVcB9HCRJWsjw2NXYvAPojQzSGxgP4hTaKC6WT8gQtbZVO1IriNGIx)y5SejojQzSGxgP4hTYJcmfy5p1a0FzTm8LJAi(hutPPMTJj1MsnS9zQPEQXN5L1pwwrb2jr17pxQmKEj8gqp4SqBDeMcStIQ3FUuzCiXxweneYBqb2jr17pxQmhpv0Aralc6pfykWYFQzWWooXPMbjGC2Jgsb2jr17R8XpKIEzTIFshuGDsu9(kF8J5sLbP30UFwCQGLR0spxTwr6gMR1dol8)9Rnu3XKj(C1AfPByUwp4SW)3V2qbzeV2hqauajrPKSejNRwRo2lu0Ar42EF1Dm55Q1QJ9cfTweUT3xbzeV2hqauajrPK8aOa7KO69v(4hZLkd0hJgk(awOZYvAPNRwRiDdZ16bNf()(1gQ7yYeFUATI0nmxRhCw4)7xBOGmIx7diakGKOuswIKZvRvh7fkATiCBVV6oM8C1A1XEHIwlc327RGmIx7diakGKOusEauGDsu9(kF8J5sLrB9f9AtfFal0z5kTuDtU)CI)HaYP8cOUj3xH4trb2jr17R8XpMlvg0lRvqAeeFZYrsGyzr4WuoEPaixPLQVwRaYKjomLfrHWacGcijkLKtQBY9Nt8peqoLxa1n5(keFkkWojQEFLp(XCPY8bZwra9r5kTuDtU)CI)HaYP8cOUj3xH4trb2jr17R8XpMlvMHLnRlilonYrUslv3K7pN4FiGCkVaQBY9vi(ujNokc61MMC6ZvRvimsdtq0AH9sQSidzh5v3XKjwFTwbKjtCyklIcHbeafqsukjlrY05oudlBwxqwCAKJkkc61MMC6ZvRvKUH5A9GZc)F)Ad1DuIKPZDOgw2SUGS40ihvue0Rnn55Q1kKEt7(zH(ctq9HtqhqagGejrHWIOf5IbeaGsYPZDOgw2SUGS40ihvue0RnLcStIQ3x5JFmxQmpdh5neFuBQCLw605oupdh5neFuBQkkc61MMC6ZvRvKUH5A9GZc)F)Ad1DKcStIQ3x5JFmxQmOxwRG0ii(MLJKaXYIWHPC8sbqUslv3K7pN4FiGCkVaQBY9vi(ujt85Q1kKEt7(zH(ctq9HtqhqGirIUj3hqNevVkKEt7(zXPcwr6pgafyNevVVYh)yUuzEgoYBi(O2u5kTuiRH8pXpwo50NRwRiDdZ16bNf()(1gQ7yYZvRvi9M29Zc9fMG6dNGoGaHcStIQ3x5JFmxQmUa5cZmu0Abb2dF5kT0PpxTwr6gMR1dol8)9Rnu3rkWojQEFLp(XCPYq6gMR1dol8)9RnKR0sN(C1AfPByUwp4SW)3V2qDhPa7KO69v(4hZLkdsVPD)S4ublxPLEUATcP30UFwOVWeu3rjs0n5(Zj(hciNYlA1n5(keFkGgaOrIKZvRvKUH5A9GZc)F)Ad1DKcStIQ3x5JFmxQmqFmAO4dyHotb2jr17R8XpMlvMHLnRlilonYrUslD6OiOxBkfykWYFQzWWooXPMbjGC2JgoNAKFx2SUGm1myU67x9sb2jr17R8XH6sk6L1k(jDqb2jr17R8XH6AUuzq6nT7NfNky5kT0ZvRvh7fkATiCBVV6oM8C1A1XEHIwlc327RGmIx7dykjtb2jr17R8XH6AUuzG(y0qXhWcDwUsl9C1A1XEHIwlc327RUJjpxTwDSxOO1IWT9(kiJ41(aMsYuGDsu9(kFCOUMlvMNHJ8gIpQnvUslD6ChQNHJ8gIpQnvffb9AtPa7KO69v(4qDnxQmUa5cZmu0Abb2dFkWojQEFLpouxZLkZWYM1fKfNg5ixPLQVwRaYKjomLfrHWacGcijkLKLir3K7pN4FiGCkVaQBY9vi(ujt8YtfIHL40ih1S26rz5K5oupdh5neFuBQkkc61MMm3H6z4iVH4JAtvqwd5FIFSSejlpvigwItJCuJtyyJ0lNC6ZvRvi9M29Zc9fMG6oMu3K7pN4FiGCkVaQBY9vi(uanNevVk0lRvqAeeFZkI)HaYP8MOboakWojQEFLpouxZLkdPByUwp4SW)3V2GcStIQ3x5Jd11CPYG0BA3plovWYvAPNRwRq6nT7Nf6lmbfKr8A)KlpvigwItJCuJtyyJ0ltb2jr17R8XH6AUuzqVSwbPrq8nlhjbILfHdt54LcGCLwQ(ATcitM4WuwefcdiakGKOusoPUj3FoX)qa5uEbu3K7Rq8PaAYdnuGDsu9(kFCOUMlvMpy2kcOpkxPLQBY9Nt8peqoLxa1n5(keFkkWojQEFLpouxZLkd0hJgk(awOZYvAPNRwRIAu0ArmHf)i7q1hobDPduIKChQFc0hx2konYrffb9AtPa7KO69v(4qDnxQmi9M29ZItfSCLwAUd1pb6JlBfNg5OIIGETPuGDsu9(kFCOUMlvMHLnRlilonYrUslD5PcXWsCAKJ6Na9XLTj1n5(ODGOjzUd1ZWrEdXh1MQGmIx7JwGKOusMcStIQ3x5Jd11CPYqM4OdDKxUslD6ZvRvi9M29Zc9fMGcYiETpfyNevVVYhhQR5sL5z4iVH4JAtLR0sHSgY)e)yzkWojQEFLpouxZLkd6L1kincIVz5ijqSSiCykhVuaKR0s1n5(Zj(hciNYlG6MCFfIpvYeFUATcP30UFwOVWeuF4e0beisKOBY9b0jr1RcP30UFwCQGvK(Jbqb2jr17R8XH6AUuzG(y0qXhWcDMcStIQ3x5Jd11CPYG0BA3plovWYvAPNRwRq6nT7Nf6lmb1DuIeDtUpAhC0irsUd1pb6JlBfNg5OIIGETPuGDsu9(kFCOUMlvMHLnRlilonYrUslD5PcXWsCAKJAwB9OSCYChQNHJ8gIpQnvffb9AtLiz5PcXWsCAKJACcdBKEzjswEQqmSeNg5O(jqFCzBsDtUpAbcAOatb2jr17Ri5x6X2DwOVWeKR0sjDBZ9Wvr6gMR1dol8)9RnuqgXR9r7ardfyNevVVIK)5sLXxc)b0TcIBTYvAPKUT5E4QiDdZ16bNf()(1gkiJ41(ODGOHcStIQ3xrY)CPYOliFSDNLR0sjDBZ9Wvr6gMR1dol8)9RnuqgXR9r7ardfyNevVVIK)5sLXwPtIxmiU5ueEdkWojQEFfj)ZLkZHHpdrV2u5kTus32CpCvKUH5A9GZc)F)AdfKr8AF0oOOrIKOqyr0ICXacWaPa7KO69vK8pxQmJDu9kxPLEUATk96WC5RO1cx(yyhtu3XKj(C1A1HHpdrV2u1DuIKZvRvhB3zH(ctqDhLizAOtyvaBRDasKKysV)fXpwwn2r1RO1I7EGv2YzH(ctiPUsNeciJ41(aoOairIUsNeciJ41(akVbDasKmn)pVewr6nZ7ZzHT0SUHewH4dIgM8C1AfPByUwp4SW)3V2qDhPa7KO69vK8pxQm(pYKq0ArmHfSNAz5kT0WHPCOY1h(sy0kDqPa7KO69vK8pxQm3NfvWiYTocl1)jZ8LFb0LVgkin0TYvAPNRwRqyKgMGO1c7LuzrgYoYRUJj1v6KqazeV2hqs32CpCvimsdtq0AH9sQSidzh5vqgXR9NdaqKi5C1Av61H5YxrRfU8XWoMO(WjOlfij1v6KqazeV2hqs32CpCvPxhMlFfTw4Yhd7yIcYiET)C5HgjsY85Q1kOlFnuqAOBfz(C1AvUhUsKOR0jHaYiETpGYdajsoxTwnSH28mUwbK)E9LWkiJ41(j1v6KqazeV2hqs32CpCvdBOnpJRva5VxFjScYiET)CaaksKmD4wEd1PG5x0AXiKtqXRFSCoPUsNeciJ41(as62M7HRI0nmxRhCw4)7xBOGmIx7pxEOj55Q1ks3WCTEWzH)VFTHcYiETpfyNevVVIK)5sL5(SOcgrU1ryPPULjU1YWxC6ELR0sjDBZ9WvHWinmbrRf2lPYImKDKxbzeV2xIKWT8gQHLnRlilQvF)QxfV(XY5KKUT5E4QiDdZ16bNf()(1gkiJ41(sKmn)pVewHWinmbrRf2lPYImKDKxH4dIgMK0Tn3dxfPByUwp4SW)3V2qbzeV2NcStIQ3xrY)CPYCFwubJi36iSux((jo0FHU3q0AXypKHuGPal)PMbP)ZlHFkWojQEFfj)ZLkJUj3NZcx(yyfS4WoICLwk0RSGNXBO8C(v1IwGkAsQBY9bu3K7Rq8PaAYdisKKyNe1mwWlJu8JwasoD4wEd1PG5x0AXiKtqXRFSCwIeNe1mwWlJu8Jw5nGKj(C1A1XEHIwlc327RUJjpxTwDSxOO1IWT9(kiJ41(ODGjkLKLiz6ZvRvh7fkATiCBVV6ooakWojQEFfj)ZLkZX2Dw0ArmHf8YijixPLM4ed9kl4z8gkpNFfKr8AF0curJejtd9kl4z8gkpNFfpv9XpajssStIAgl4Lrk(rlajNoClVH6uW8lATyeYjO41pwolrItIAgl4Lrk(rR8gWasQBY9bu3K7Rq8POa7KO69vK8pxQmJxyPtO2uXX6FixPLM4ed9kl4z8gkpNFfKr8AF0oOOrIKPHELf8mEdLNZVINQ(4hGejj2jrnJf8Yif)OfGKthUL3qDky(fTwmc5eu86hlNLiXjrnJf8Yif)OvEdyaj1n5(aQBY9vi(uuGDsu9(ks(NlvM0RdZLVIwlC5JHDmHcStIQ3xrY)CPYaRXrllQv8JoHPa7KO69vK8pxQmKEj8gqp4SqBDewUslvFTwbKjtCyklIcHbeGeLsYuGDsu9(ks(NlvMyclU7PVBwOBiHLR0spxTwbzc6w(FHUHewDhPa7KO69vK8pxQmdBOnpJRva5VxFjmfyNevVVIK)5sLbY(yTPcT1r4xUslnCykhQjSBJjQrsGwGcAKijCykhQjSBJjQrsaOu5HgjschMYHkkeweTyKec5Hg0oq0qbw(tn2lPYuZGK(GOHudq)n5(5lYi1moXFMcStIQ3xrY)CPY8mCK3q8rTPYvAP8)8syfcJ0WeeTwyVKklYq2rEfIpiAysiRH8pXpwo55Q1Qz1idFXmEBe1Dm50KUT5E4QqyKgMGO1c7LuzrgYoYRGmIx7tb2jr17Ri5FUuzq6nT7NfNky5kTu(FEjScHrAycIwlSxsLfzi7iVcXhenm50KUT5E4QqyKgMGO1c7LuzrgYoYRGmIx7tb2jr17Ri5FUuzgw2SUGS40ih5kTu(FEjScHrAycIwlSxsLfzi7iVcXhenmP(ATcitM4WuwefcdiakGKOusoPUj3hqNevVkKEt7(zXPcwr6psonPBBUhUkegPHjiATWEjvwKHSJ8kiJ41(uGDsu9(ks(NlvgegPHjiATWEjvwKHSJ8YvAP6MCFaDsu9Qq6nT7NfNkyfP)i55Q1ks3WCTEWzH)VFTH6osbMcmfyNevVVIyzFglDMdl)yz5whHLsC4mwqYq56rPphLwUzU9YsDsuZybVmsXVCZC7LfS9zParosV5kQEL6KOMXcEzKIFabcfyNevVVIyzFgpxQmi9M29ZItfSCLwQlFmScwDSxOO1IWT9(kOVOJw0KmXNRwRiDdZ16bNf()(1gQ7yYeFUATI0nmxRhCw4)7xBOGmIx7diakGKOuswIKZvRvh7fkATiCBVV6oM8C1A1XEHIwlc327RGmIx7diakGKOuswIKZvRvKUH5A9GZc)F)AdfKr8A)KtFUAT6yVqrRfHB79vqgXR9hWaOa7KO69vel7Z45sLbP30UFwCQGLJKaXYIWHPC8sbqUslnZNRwRSEWBig767v9HtqhTj2jrnJf8Yif)sKauhqsDLojeqgXR9b0jrnJf8Yif)jkLKPa7KO69vel7Z45sLXfixyMHIwliWE4tb2jr17Riw2NXZLkdPByUwp4SW)3V2GcStIQ3xrSSpJNlvgIdNXYvAP5ou)eOpUSvCAKJkkc61MMC6WT8gQjjKH(lovWkE9JLZsKK7q9tG(4YwXProQOiOxBAsNe1mwWlJu8JwGqb2jr17Riw2NXZLkZWYM1fKfNg5ixPLoD4wEdv6LHWYADr4KOiVIx)y5Sej6R1kGmzIdtzruimGPKSejqVYcEgVHYZ5xbzeV2hWbnj0RSGNXBO8C(v8u1hpfyNevVVIyzFgpxQmNBqMWWeKR0sjtCyk)cn0jr1RBrR8uarIKChQFc0hx2konYrffb9AtLiH0Tn3dx1WYM1fKfNg5OGmIx7JwNe1mwWlJu8d0sjzjsY85Q1QJT7SO1Iycl4LrsqbzeV2xIeOxzbpJ3q558RGmIx7diqsc9kl4z8gkpNFfpv9Xtb2jr17Riw2NXZLkdsVPD)S4ublhjbILfHdt54LcGCLwAMpxTwz9G3qm213R6dNGoAbkuGDsu9(kIL9z8CPYqM4OdDKNcStIQ3xrSSpJNlvg0lRvqAeeFZYrsGyzr4WuoEPaixPLQBY9Nt8peqoLxa1n5(keFkkWojQEFfXY(mEUuzM4WXUx5kT0WT8gQGHiVO1cEt9ugH3qXRFSCMcStIQ3xrSSpJNlvgIdNXYvAPHB5nuPxgclR1fHtII8kE9JLZuGDsu9(kIL9z8CPYCUbzcdtqUslL0Tn3dx1WYM1fKfNg5OGmIx7J2e7KOMXcEzKIFjsaYaOa7KO69vel7Z45sLrB9f9AtfFal0z5kTuDtU)CI)HaYP8cOUj3xH4trb2jr17Riw2NXZLkZWYM1fKfNg5ixPLM7qnSSzDbzXProkiRH8pXpwwIKWT8gQHLnRlilQvF)QxfV(XYzkWojQEFfXY(mEUuzEgoYBi(O2u5ijqSSiCykhVuaKR0spxTwnRgz4lMXBJOGStckWojQEFfXY(mEUuzioCglxPLs62M7HRAyzZ6cYItJCuqgXR9r7mhw(XYkIdNXcsgk)uEuGDsu9(kIL9z8CPY8bZwra9rkWojQEFfXY(mEUuzEgoYBi(O2u5ijqSSiCykhVuaKR0sHSgY)e)y5KNRwRIAu0ArmHf)i7q1hobDahyYLNkedlXProQzT1JYYsKaznK)j(XYjD5JHvWkRh8gIXU(EvqFrhTOHcS8NAqTPMVqUwpyQ5(Ektn6gsni9M29ZItfm10qQb6JrdfFal0zQjFH1Msndg)itcQP1utmHPMbPEQLLJAi9ycud7KjuttixiKxctnTMAIjm14KO6LA8ntn(4iVzQrWEQLPMOPMyctnojQEPM1ryffyNevVVIyzFgpxQmi9M29ZItfSCKeiwweomLJxkauGDsu9(kIL9z8CPYa9XOHIpGf6SCKeiwweomLJxkauGPa7KO69vFif9YAf)KoOa7KO69vFmxQmtC4y3RCLwA4wEdvWqKx0AbVPEkJWBO41pwotb2jr17R(yUuz0wFrV2uXhWcDwUslv3K7pN4FiGCkVaQBY9vi(uuGDsu9(QpMlvgOpgnu8bSqNLR0spxTwr6gMR1dol8)9Rnu3XKj(C1AfPByUwp4SW)3V2qbzeV2hqauajrPKSejNRwRo2lu0Ar42EF1Dm55Q1QJ9cfTweUT3xbzeV2hqauajrPK8aOal)PguBQ5lKR1dMAUVNYuJUHudsVPD)S4ubtnnKAG(y0qXhWcDMAYxyTPuZGXpYKGAAn1etyQzqQNAz5OgspMa1Wozc10eYfc5LWutRPMyctnojQEPgFZuJpoYBMAeSNAzQjAQjMWuJtIQxQzDewrb2jr17R(yUuzq6nT7NfNky5kT0ZvRvKUH5A9GZc)F)Ad1DmzIpxTwr6gMR1dol8)9RnuqgXR9beafqsukjlrY5Q1QJ9cfTweUT3xDhtEUAT6yVqrRfHB79vqgXR9beafqsukjpakWojQEF1hZLkd6L1kincIVz5ijqSSiCykhVuaKR0s1n5(Zj(hciNYlG6MCFfIpffyNevVV6J5sL5z4iVH4JAtLR0spxTwnRgz4lMXBJOUJjpxTwnRgz4lMXBJOGmIx7diajkLKPa7KO69vFmxQmFWSveqFuUslv3K7pN4FiGCkVaQBY9vi(uuGDsu9(QpMlvMHLnRlilonYrUslv3K7pN4FiGCkVaQBY9vi(ujHSgY)e)y5K6R1kGmzIdtzruimGPKCYPpxTwHWinmbrRf2lPYImKDKxDhLir3K7pN4FiGCkVaQBY9vi(ujt805oudlBwxqwCAKJkkc61MMmXtFUATI0nmxRhCw4)7xBOUJsKCUATcP30UFwOVWeuF4e0beajsIcHfrlYfdiaafjsMo3HAyzZ6cYItJCurrqV20KU8XWky1WYMz4Y)l(lCwnZTkOVOJw0mGbKC6ZvRvimsdtq0AH9sQSidzh5v3rkWojQEF1hZLkZZWrEdXh1MkxPLEUATAwnYWxmJ3grDhtM7q9mCK3q8rTPkiJ41(ao4jkLKLij3H6z4iVH4JAtvqwd5FIFSCYPpxTwr6gMR1dol8)9Rnu3rkWojQEF1hZLkJlqUWmdfTwqG9WxUslD6ZvRvKUH5A9GZc)F)Ad1DKcStIQ3x9XCPYq6gMR1dol8)9RnKR0sN(C1AfPByUwp4SW)3V2qDhPa7KO69vFmxQmi9M29ZItfSCLw65Q1kKEt7(zH(ctqDhLir3K7pN4FiGCkVOv3K7Rq8PaAYdnjd3YBOMvJm8fZ4Tru86hlNLir3K7pN4FiGCkVOv3K7Rq8PaAaKmClVHkyiYlATG3upLr4nu86hlNLi5C1AfPByUwp4SW)3V2qDhPa7KO69vFmxQmqFmAO4dyHotb2jr17R(yUuzgw2SUGS40ih5kT0ChQHLnRlilonYrbznK)j(XYuGDsu9(QpMlvMNHJ8gIpQnvUsl9C1A1SAKHVygVnI6osbMcS8NAKFx2SUGm1myU67x9sb2jr17RgQlPOxwR4N0bfyNevVVAOUMlvMjoCS7vUslv3K7pN4FiGCkVaQBY9vi(ujd3YBOcgI8Iwl4n1tzeEdfV(XYzkWojQEF1qDnxQmi9M29ZItfSCLw65Q1QJ9cfTweUT3xDhtEUAT6yVqrRfHB79vqgXR9bmLKPa7KO69vd11CPYa9XOHIpGf6SCLw65Q1QJ9cfTweUT3xDhtEUAT6yVqrRfHB79vqgXR9bmLKPa7KO69vd11CPY8mCK3q8rTPYvAPNRwRMvJm8fZ4Tru3XKNRwRMvJm8fZ4TruqgXR9beafqsukjlrY05oupdh5neFuBQkkc61Msb2jr17RgQR5sLzyzZ6cYItJCKR0s1xRvazYehMYIOqyabqbKeLsYj1n5(Zj(hciNYlG6MCFfIpLejjE5PcXWsCAKJAwB9OSCYChQNHJ8gIpQnvffb9AttM7q9mCK3q8rTPkiRH8pXpwwIKLNkedlXProQXjmSr6Lto95Q1kKEt7(zH(ctqDhtQBY9Nt8peqoLxa1n5(keFkGMtIQxf6L1kincIVzfX)qa5uEt0ahafyNevVVAOUMlvg0lRvqAeeFZYrsGyzr4WuoEPaixPLQBY9Nt8peqoLxa1n5(keFkGMUj3xb5uEPa7KO69vd11CPY4cKlmZqrRfeyp8Pa7KO69vd11CPY8bZwra9r5kTuDtU)CI)HaYP8cOUj3xH4trb2jr17RgQR5sLzyzZ6cYItJCKR0s1xRvazYehMYIOqyabqbKeLsYuGDsu9(QH6AUuziDdZ16bNf()(1guGDsu9(QH6AUuzEgoYBi(O2u5kT0ZvRvZQrg(Iz82iQ7yYChQNHJ8gIpQnvbzeV2hWbprPKmfyNevVVAOUMlvgKEt7(zXPcwUsln3H6Na9XLTItJCurrqV2ujsoxTwH0BA3pl0xycQpCc6sbcfyNevVVAOUMlvMHLnRlilonYrUslD5PcXWsCAKJ6Na9XLTjZDOEgoYBi(O2ufKr8AF0cKeLsYuGDsu9(QH6AUuzEgoYBi(O2u5kTuiRH8pXpwMcStIQ3xnuxZLkdzIJo0rE5kT0PpxTwH0BA3pl0xyckiJ41(uGDsu9(QH6AUuzq6nT7NfNkykWojQEF1qDnxQmqFmAO4dyHotb2jr17RgQR5sL5z4iVH4JAtLR0spxTwnRgz4lMXBJOUJuGDsu9(QH6AUuzgw2SUGS40ih5kT0LNkedlXProQzT1JYYjZDOEgoYBi(O2uvue0RnvIKLNkedlXProQXjmSr6LLiz5PcXWsCAKJ6Na9XLT4ahyma]] )
    end

end