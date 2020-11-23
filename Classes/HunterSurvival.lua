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

    spec:RegisterPack( "Survival", 20201123.1, [[dW0JtbqiuuEKsHytss(eimkjHtjjAvIKOxbIMLiv3IueAxu8lsHHPu0XKuTmcQNrkQPjskxtPKTjjv(gPiACkLkNtKuToLcMhkY9iL2NiHdkjvzHeKhQuktuKKQlkss(OsH0ifjP4KkfkRuszMss5MIKuQDIc(PijmurskzPKIGNcQPIc9vLcvJffvNvsQQ9c1FjzWeDyHfJspgvtwjxgzZs8zrz0I40sTALsvVgK0SP0Tjv7wXVvz4IQJtkslxvphY0P66eA7GuFNaJxKOZlsz9GeZxPA)aJRJzedVcNWmi8McVz96cRzt9TewynRzmSNwoHHZdouJmcdpHoHHHfFOBOdlgopsZEXcZiggDIpNWWjUNJ2GgAK1EIiRHF6AGADrB49n8pkUgOwNRbgMvST(gBWSy4v4eMbH3u4nRxxynBQVLW1fwymCi6j3JHHBDrB49nB7JIJHt61IgmlgEriogEJaKWIp0n0Hfit1ioo9GABeGKHdAsNLEGuynNoqk8McVjOgO2gbiHtI1jWgZcbKpzParaz(333EAazfcApbitvienCcvPbdBBKJWmIHxujeToMrmd1XmIHdU33GH5N440RqjNJHPjyT0cle2XmimMrmmnbRLwyHWWb37BWW8tCC6vOKZXW8VD67ad)IdvUpJmikprekiv(FCBOhEFJHMG1slGCFhirNOLTNLz60cKYVZIu5xJUbi33bYkas(nlX2npbn9OWQUIQCVloKHMG1slGSkGKza5lou5(mYGO8erOGu5)XTHE49ngAcwlTaYkXW2EifFHH18MyhZGMXmIHdU33GHfrKQDshHHPjyT0cle2XmKAygXWb37BWW(hJMk22gk9KPqjNJHPjyT0cle2XmSfMrmmnbRLwyHWW8VD67adN)e0Qm(Yu3eOCI7QRO8esjOTlGCFhilDwIREsp6bbKmbKcVjgo4EFdgwerQ2jDe2XmuDygXW0eSwAHfcdhCVVbdhqbLeFGuLBC1vu5Na6XW8VD67adZVZUobJjq5e3vxr5jKsqBxMN0JEqQmrcHasMaY6BbKvbKLolXvpPh9GaYuaK13edpHoHHdOGsIpqQYnU6kQ8ta9yhZGMeZigMMG1slSqy4G79ny4aLaDmes9buUxXVpSyy(3o9DGHxeRyPy(ak3R43hw1IyflfJyoqwfqwbqYmGK0uXopNwMakOK4dKQCJRUIk)eqpqUVdK87SRtWycOGsIpqQYnU6kQ8ta9MN0JEqazkaYTR6aY9DGKqiA4KH1E3sDfLNqkAi90m6X2FpqwjqwfqwbqM)e0Qm(Yu3eOCI7QRO8esjOTlGCFhizgqsAQyNNtldpnU98)MMRyTbYbYQaswXsXeOCI7QRO8esjOTlZt6rpiGmfazQdKvcKvbKvaKmdijeIgoz43SObrlLTlu5Eoz0JT)EGCFhizflftMy8Rog1vubuO)8eJyoqwjqwfqwbq6XNrUjHcRNyY5oqYeqQ5TaY9DGKzajHq0Wjd)MfniAPSDHk3ZjJES93dK77ajZaspS04gO2wl9QEqEpC3qtWAPfqwjqUVdKvaKlIvSumFaL7v87dRArSILIzDcgGCFhilDwIREsp6bbKmbKcxDazLazvazPZsC1t6rpiGmfazfaPWPgqMkbYkas(D21jym8042Z)BAUI1gi38KE0dciHeitnGKjGS0zjU6j9OheqwjqwjgEcDcdhOeOJHqQpGY9k(9Hf7yg2omJyyAcwlTWcHHdU33GH5PXTN)30CfRnqogM)TtFhyywXsXWsiVdRsWhEIzDcgGCFhilDwIREsp6bbKmbKBHHPsH4UAcDcdZtJBp)VP5kwBGCSJzi1XmIHPjyT0clego4EFdgMhwRk4EFJY2ihdBBKRMqNWW8fc7ygQVjMrmmnbRLwyHWW8VD67adhCVHMu0q6nHasMasHXWb37BWW8WAvb37Bu2g5yyBJC1e6egg5yhZq96ygXW0eSwAHfcdZ)2PVdmCW9gAsrdP3ecitbqwhdhCVVbdZdRvfCVVrzBKJHTnYvtOtyyULcOjSJDmC(t8tNnCmJygQJzedhCVVbdJe11VrLtogMMG1slSqyhZGWygXW0eSwAHfcdpHoHHdOGsIpqQYnU6kQ8ta9y4G79ny4akOK4dKQCJRUIk)eqp2XmOzmJy4G79nyyb3Bxqt9OEcDtmCcdttWAPfwiSJzi1WmIHPjyT0clego)jEGCL36egUUzlmCW9(gmShVY)ihdZ)2PVdm8lou5(mYGorB5(msr6S0Jm0eSwAbK77a5lou5(mYmec1tMG4tdP8pYZ7jtf55XhUiYqtWAPf2XmSfMrmmnbRLwyHWW5pXdKR8wNWW1nBHHdU33GHzjK3Hvj4dpbdZ)2PVdmmZaspS04geNgxDffR9ULHMG1slGSkGKza5lou5(mYGorB5(msr6S0Jm0eSwAHDmdvhMrmCW9(gmCMy8Rog1vubuO)8emmnbRLwyHWoMbnjMrmCW9(gmSoPFFAQROSI8EPwpf6immnbRLwyHWoMHTdZigMMG1slSqy4G79nyyEAC75)nnxXAdKJH5F703bgMza5h9srqtJB6bAr7qFWAjdLYg5iGSkGScG0)EGk5M6MKaP43zxNGbiHei9VhOsUrytsGu87SRtWaKmbKcdK77ajPPIDEoTmqhFhSws1JtdQ90uzDwa9zD1H4T1gEpzQNcUFpqwjgMkfI7Qj0jmmpnU98)MMRyTbYXoMHuhZigMMG1slSqyy(3o9DGHzgq(rVue004MEGw0o0hSwYqPSrocdhCVVbdxoUiIwQak03oPyPqh7ygQVjMrmmnbRLwyHWW5pXdKR8wNWW1nAgdhCVVbdhOCI7QRO8esjOTlmm)BN(oWWmdidOqF7Kj)B9WQ6b59WDKHMG1slGSkGKzajHq0WjdHq0Wj1vuEcPkhxe1tMQ)gz0JT)EGSkGScGK0uXopNwMakOK4dKQCJRUIk)eqpqUVdKmdijnvSZZPLHNg3E(FtZvS2a5azLyhZq96ygXW0eSwAHfcdN)epqUYBDcdx3Sfgo4EFdgMLqEhwLGp8emm)BN(oWWbuOVDYK)TEyv9G8E4oYqtWAPfqwfqYmGKqiA4KHqiA4K6kkpHuLJlI6jt1FJm6X2FpqwfqwbqsAQyNNtltafus8bsvUXvxrLFcOhi33bsMbKKMk2550YWtJBp)VP5kwBGCGSsSJDmmFHWmIzOoMrmmnbRLwyHWW8VD67adZVZUobJHLqEhwLGp8eZt6rpiGmfaPM3edhCVVbdhdNq(hwfpSwSJzqymJyyAcwlTWcHH5F703bgMFNDDcgdlH8oSkbF4jMN0JEqazkasnVjgo4EFdgU0pXAVBHDmdAgZigMMG1slSqyy(3o9DGHRaizflfJG2UuO8(BhzeZbY9DGKzaj)GMMyCZ0zjUQeeqwfqYkwkMaLtCxDfLNqkbTDzeZbYQaswXsXWsiVdRsWhEIrmhiReiRciRailDwIREsp6bbKPai53zxNGXWspIEO2tMzj(H33aKqcKlXp8(gGCFhiRai94Zi3KqH1tm5Chizci18wa5(oqYmG0dlnUbQT1sVQhK3d3n0eSwAbKvcKvcK77azPZsC1t6rpiGKjGSUMXWb37BWWS0JOhQ9KHDmdPgMrmmnbRLwyHWW8VD67adxbqYkwkgbTDPq593oYiMdK77ajZas(bnnX4MPZsCvjiGSkGKvSumbkN4U6kkpHucA7YiMdKvbKSILIHLqEhwLGp8eJyoqwjqwfqwbqw6Sex9KE0dcitbqYVZUobJH1E3sve)0mlXp8(gGesGCj(H33aK77azfaPhFg5MekSEIjN7ajtaPM3ci33bsMbKEyPXnqTTw6v9G8E4UHMG1slGSsGSsGCFhilDwIREsp6bbKmbK1RomCW9(gmmR9ULQi(PHDmdBHzedhCVVbdB7SehP2EXvMonogMMG1slSqyhZq1HzedttWAPfwimm)BN(oWWSILIjq5e3vxr5jKsqBxgXCGCFhilDwIREsp6bbKmbKcxDy4G79ny48Z7BWoMbnjMrmmnbRLwyHWW8VD67adxbqM)e0Qm(Yu3eOCI7QRO8esjOTlGCFhi53zxNGXeOCI7QRO8esjOTlZt6rpiGKjGmJVaY9DGS0zjU6j9OheqYeqk8MazLa5(oqYmGKqiA4Kb6g13OUIkN(cX9(gJEp3JHdU33GHfCVDbn1J6j0nXWjSJzy7WmIHPjyT0clegM)TtFhyy(D21jymbkN4U6kkpHucA7Y8KE0dcizciRVjqUVdKLolXvpPh9GaYuaKb37Bu87SRtWaKqcKlXp8(gGCFhilDwIREsp6bbKmbKAEtmCW9(gmCMy8Rog1vubuO)8eSJzi1XmIHdU33GH)op3sQEuO8GtyyAcwlTWcHDmd13eZigo4EFdgwN0Vpn1vuwrEVuRNcDegMMG1slSqyhZq96ygXW0eSwAHfcdZ)2PVdmShFg5MekSEIjN7azkaYTBtGCFhi94Zi3KqH1tm5Chizslqk8Ma5(oq6XNrUXBDs5NkN7kH3eitbqQ5nXWb37BWWpf59KPk2qNqyh7yyKJzeZqDmJy4G79ny4aLtCxDfLNqkbTDHHPjyT0cle2XmimMrmmnbRLwyHWW8VD67adZkwkMYtdusZiMdKvbKSILIP80aL0mpPh9GasM0cKz8fgo4EFdgMnEwAPqjNJDmdAgZigMMG1slSqyy(3o9DGHFXHk3Nrg0jAl3NrksNLEKHMG1slGSkG0Jx5FKBEsp6bbKmbKz8fqwfqYVZUobJPyJNmpPh9GasMaYm(cdhCVVbd7XR8pYXoMHudZigMMG1slSqyy(3o9DGH94v(h5gXCGSkG8fhQCFgzqNOTCFgPiDw6rgAcwlTWWb37BWWfB8e2XmSfMrmCW9(gmmR9UfkHwyyAcwlTWcHDmdvhMrmCW9(gmSG2UuO8(BhHHPjyT0cle2XmOjXmIHdU33GHl2inAPqjNJHPjyT0cle2XmSDygXW0eSwAHfcdZ)2PVdmmRyPyk2in6rk94HQ5j9OheqYeqUfqUVdKE8zKBsOW6jMCUdKmPfifEtmCW9(gmmuBRvHsoh7ygsDmJyyAcwlTWcHH5F703bgUcGKFNDDcgJG2UuO8(BhzEsp6bbKPailIwR6jEs8zKYBDci33bsMbK8dAAIXntNL4QsqazLazvazfaj)o76emgwc5Dyvc(WtmpPh9GasMaY6cdKPsGKNeFgHuLp4EFtybsibYm(ciRci9WsJBqCAC1vuS27wgAcwlTaY9DGSiATQN4jXNrkV1jGKjGmJVaYQas(D21jymSeY7WQe8HNyEsp6bbKvcK77aPhFg5gV1jLFQvtajtazQJHdU33GHzJNLwkuY5yhZq9nXmIHPjyT0clegM)TtFhy4YXfrajKajpqU6PmAasMaYYXfrg9iLy4G79ny4ffEIINeq9dDSJzOEDmJyyAcwlTWcHH5F703bgMvSumbkN4U6kkpHucA7YiMdK77azPZsC1t6rpiGKjGS(wy4G79nyyKh650IWoMH6cJzedttWAPfwimm)BN(oWWLJlIasibYYXfrMNYObitLazgFbKmbKLJlIm6rkbYQaswXsXWsiVdRsWhEIzDcgGSkGScGKza56Cd)gon(hoTufBOtkwXFmpPh9GaYQasMbKb37Bm8B404F40svSHoz6rvSDwIdKvcK77azr0AvpXtIpJuERtajtazgFbK77azPZsC1t6rpiGKjGClmCW9(gmm)gon(hoTufBOtyhZqDnJzedhCVVbdhkDXFrV6kk(FcqyyAcwlTWcHDmd1tnmJyyAcwlTWcHH5F703bgMvSumSeY7WQe8HNyeZbY9DGS0zjU6j9OheqYeqwFtmCW9(gm8tOBcVNmv8)ja7ygQVfMrmmnbRLwyHWW8VD67adZVZUobJrqBxkuE)TJmpPh9GaYuaK13ci33bsMbK8dAAIXntNL4Qsqa5(oqw6Sex9KE0dcizciRVfgo4EFdgMLqEhwLGp8eSJzOE1HzedhCVVbdZtA9G(qHsohdttWAPfwiSJzOUMeZigMMG1slSqyy(3o9DGHzflfdlH8oSkbF4jM1jyaY9DGS0zjU6j9OheqYeqUfgo4EFdgUCCreTubuOVDsXsHo2XmuF7WmIHPjyT0clegM)TtFhyywXsX8ehQwcHuL75Krmhi33bswXsX8ehQwcHuL75KIFIJtVb5bhQajtaz9nbY9DGS0zjU6j9OheqYeqUfgo4EFdg2tiL4WEIZsvUNtyhZq9uhZigMMG1slSqyy(3o9DGHzflfdlH8oSkbF4jgXCGCFhilDwIREsp6bbKmbK13edhCVVbd)e6MW7jtf)FcWoMbH3eZigMMG1slSqyy(3o9DGH53zxNGXiOTlfkV)2rMN0JEqazkaY6BbK77ajZas(bnnX4MPZsCvjiGCFhilDwIREsp6bbKmbK13cdhCVVbdZsiVdRsWhEc2XmiCDmJy4G79nyyEsRh0hkuY5yyAcwlTWcHDmdclmMrmmnbRLwyHWW8VD67adZkwkMaLtCxDfLNqkbTDzEsp6bbKPaiRVjqcjqMXxa5(oqw6Sex9KE0dcizciRVjqcjqMXxy4G79nyyw7Dl1vuEcPOH0td7ygewZygXWb37BWWqTTwf)01JzHHPjyT0cle2XmiCQHzedttWAPfwimm)BN(oWWSILIHLqEhwLGp8eZ6ema5(oqw6Sex9KE0dcizci3cdhCVVbdZgzQRO8V5qfHDmdcVfMrmCW9(gm8QFsXsbYXW0eSwAHfc7ygeU6WmIHPjyT0clegM)TtFhy4kaYYXfraPMiqYpKdKqcKLJlImpLrdqMkbYkas(D21jymqTTwf)01JzzEsp6bbKAIazDGSsGmfazW9(gduBRvXpD9ywg(HCGCFhi53zxNGXa12Av8txpML5j9OheqMcGSoqcjqMXxazLa5(oqwbqYkwkgwc5Dyvc(WtmI5a5(oqYkwkMHqOEYeeFAiL)rEEpzQipp(WfrgXCGSsGSkGKza5lou5(mYOPrUnu0tlXrjiE19l6n0eSwAbK77azPZsC1t6rpiGKjGuZy4G79nyy(X(HcLCo2XmiSMeZigMMG1slSqyy(3o9DGHzflfJG2UuO8(BhzeZXWb37BWWSXZslfk5CSJzq4TdZigMMG1slSqyy(3o9DGHzflfdlH8oSkbF4jM1jyaY9DGS0zjU6j9OheqYeqUfgo4EFdgoEEmKkx0IiSJzq4uhZigMMG1slSqyy(3o9DGHFXHk3Nrg0jAl3NrksNLEKHMG1slGCFhiFXHk3NrMHqOEYeeFAiL)rEEpzQipp(WfrgAcwlTWWb37BWWE8k)JCSJzqZBIzedttWAPfwimm)BN(oWWV4qL7ZiZqiupzcIpnKY)ipVNmvKNhF4IidnbRLwy4G79ny4Yteu6jt5FKJDSJH5wkGMWmIzOoMrmCW9(gmCGYjURUIYtiLG2UWW0eSwAHfc7ygegZigMMG1slSqy4G79nyy24zPLcLCogM)TtFhyywXsXuEAGsAgXCGSkGKvSumLNgOKM5j9OheqYKwGmJVWW804ws5XNrocZqDSJzqZygXW0eSwAHfcdZ)2PVdmCgFbKAIajRyPyyPa5kULcOjZt6rpiGmfa5MgH3cdhCVVbdRlA9gLCo2XmKAygXW0eSwAHfcdZ)2PVdm8lou5(mYGorB5(msr6S0Jm0eSwAbKvbKE8k)JCZt6rpiGKjGmJVaYQas(D21jymfB8K5j9OheqYeqMXxy4G79nyypEL)ro2XmSfMrmmnbRLwyHWW8VD67ad7XR8pYnI5azva5lou5(mYGorB5(msr6S0Jm0eSwAHHdU33GHl24jSJzO6WmIHPjyT0clegM)TtFhy4YXfrajKajpqU6PmAasMaYYXfrg9iLy4G79ny4ffEIINeq9dDSJzqtIzedhCVVbdlOTlfkV)2ryyAcwlTWcHDmdBhMrmmnbRLwyHWWb37BWWSXZslfk5Cmm)BN(oWWfrRv9epj(ms5TobKmbKz8fqwfqYVZUobJHLqEhwLGp8eZt6rpiGCFhi53zxNGXWsiVdRsWhEI5j9OheqYeqwxyGesGmJVaYQaspS04geNgxDffR9ULHMG1slmmpnULuE8zKJWmuh7ygsDmJy4G79nyywc5Dyvc(WtWW0eSwAHfc7ygQVjMrmCW9(gm8tOBcVNmv8)jadttWAPfwiSJzOEDmJyyAcwlTWcHH5F703bgMvSumbkN4U6kkpHucA7YiMdK77azPZsC1t6rpiGKjGS(wy4G79nyyKh650IWoMH6cJzedhCVVbdxSrA0sHsohdttWAPfwiSJzOUMXmIHdU33GHHABTkuY5yyAcwlTWcHDmd1tnmJy4G79nyyEsRh0hkuY5yyAcwlTWcHDmd13cZigo4EFdgM1E3cLqlmmnbRLwyHWoMH6vhMrmCW9(gmCO0f)f9QRO4)jaHHPjyT0cle2XmuxtIzedttWAPfwimm)BN(oWWSILIP80aL0mpPh9GaYuaKukjUOtkV1jmCW9(gmmB8FKryhZq9TdZigMMG1slSqyy(3o9DGHlhxebKPai5hYbsibYG79ngDrR3OKZn8d5y4G79nyyO2wRIF66XSWoMH6PoMrmmnbRLwyHWW8VD67adZkwkgwc5Dyvc(WtmRtWaK77azPZsC1t6rpiGKjGClmCW9(gmmBKPUIY)Mdve2Xmi8MygXWb37BWWR(jflfihdttWAPfwiSJzq46ygXW0eSwAHfcdhCVVbdZgplTuOKZXW8VD67ad7XNrUXBDs5NA1eqYeqM6yyEAClP84ZihHzOo2XmiSWygXW0eSwAHfcdZ)2PVdmC54IiJ36KYpLEKsGKjGmJVaYujqkmgo4EFdgMFSFOqjNJDmdcRzmJyyAcwlTWcHH5F703bg(fhQCFgzqNOTCFgPiDw6rgAcwlTaY9DG8fhQCFgzgcH6jtq8PHu(h559KPI884dxezOjyT0cdhCVVbd7XR8pYXoMbHtnmJyyAcwlTWcHH5F703bg(fhQCFgzgcH6jtq8PHu(h559KPI884dxezOjyT0cdhCVVbdxEIGspzk)JCSJzq4TWmIHdU33GHlhxerlvaf6BNuSuOJHPjyT0cle2XmiC1HzedhCVVbdNl(DjTEYuS2a5yyAcwlTWcHDmdcRjXmIHdU33GH53WPX)WPLQydDcdttWAPfwiSJzq4TdZigo4EFdgM1E3sDfLNqkAi90WW0eSwAHfc7ygeo1XmIHPjyT0clegM)TtFhyywXsX8ehQwcHuL75Krmhi33bswXsX8ehQwcHuL75KIFIJtVb5bhQajtaz9nXWb37BWWEcPeh2tCwQY9Cc7yh7yyOPh13Gzq4nfEZ61fEtmSG4NEYqy4nE1ttGHngdB0naKajJjeq26537az5EGeIfvcrRdbq(KMk2pTas0Ptazi6NE40ci5jXKridOw16HasH3aqUTBGMENwajeV4qL7ZidZHai9diH4fhQCFgzyUHMG1sliaYkeoLvAa1Qwpeqk8gaYTDd0070ciHGFZsSDdZHai9diHGFZsSDdZn0eSwAbbqwr9uwPbuRA9qaPMCda52UbA6DAbKq4HLg3WCias)asi8WsJByUHMG1sliaYkQNYknGAvRhci1KBai32nqtVtlGec)7bQKByUHFNDDcgias)asi43zxNGXWCiaYkQNYknGAGAB8QNMadBmg2OBaibsgtiGS1ZV3bYY9aje5pXpD2WHaiFstf7Nwaj60jGme9tpCAbK8KyYiKbuRA9qazQTbGCB3an9oTasiEXHk3NrgMdbq6hqcXlou5(mYWCdnbRLwqaKvupLvAa1QwpeqMABai32nqtVtlGeIxCOY9zKH5qaK(bKq8IdvUpJmm3qtWAPfeaz4azQkvunGSI6PSsdOw16HaYT2aqUTBGMENwajeEyPXnmhcG0pGecpS04gMBOjyT0ccGSI6PSsdOw16HaYT2aqUTBGMENwajeV4qL7ZidZHai9diH4fhQCFgzyUHMG1sliaYWbYuvQOAazf1tzLgqnqTnE1ttGHngdB0naKajJjeq26537az5EGec(cbbq(KMk2pTas0Ptazi6NE40ci5jXKridOw16HasnVbGCB3an9oTasi8WsJByoeaPFajeEyPXnm3qtWAPfeazf1tzLgqTQ1dbKP2gaYTDd0070ciHWdlnUH5qaK(bKq4HLg3WCdnbRLwqaKvupLvAa1a124vpnbg2ymSr3aqcKmMqazRNFVdKL7bsiqoea5tAQy)0cirNobKHOF6HtlGKNetgHmGAvRhcifEda52UbA6DAbKqKtUH5MQVXyGai9diHO6BmgiaYkeoLvAa1QwpeqQ5naKB7gOP3PfqcXlou5(mYWCias)asiEXHk3NrgMBOjyT0ccGSI6PSsdOw16HaYuBda52UbA6DAbKq8IdvUpJmmhcG0pGeIxCOY9zKH5gAcwlTGaidhitvPIQbKvupLvAa1QwpeqM6Bai32nqtVtlGecpS04gMdbq6hqcHhwACdZn0eSwAbbqwr9uwPbuRA9qaPWv3gaYTDd0070ciH4fhQCFgzyoeaPFajeV4qL7ZidZn0eSwAbbqwr9uwPbuRA9qaPWP(gaYTDd0070ciH4fhQCFgzyoeaPFajeV4qL7ZidZn0eSwAbbqwr9uwPbuRA9qaPWP(gaYTDd0070ciH4fhQCFgzyoeaPFajeV4qL7ZidZn0eSwAbbqgoqMQsfvdiROEkR0aQvTEiGuZBUbGCB3an9oTasiEXHk3NrgMdbq6hqcXlou5(mYWCdnbRLwqaKHdKPQur1aYkQNYknGAGAB8QNMadBmg2OBaibsgtiGS1ZV3bYY9ajeClfqtqaKpPPI9tlGeD6eqgI(PhoTasEsmzeYaQvTEiGu4naKB7gOP3Pfqcro5gMBQ(gJbcG0pGeIQVXyGaiRq4uwPbuRA9qaPM3aqUTBGMENwaje5KByUP6Bmgias)asiQ(gJbcGSI6PSsdOw16HaYuBda52UbA6DAbKq8IdvUpJmmhcG0pGeIxCOY9zKH5gAcwlTGaiROEkR0aQvTEiGCRnaKB7gOP3PfqcXlou5(mYWCias)asiEXHk3NrgMBOjyT0ccGmCGmvLkQgqwr9uwPbuRA9qa52TbGCB3an9oTasi8WsJByoeaPFajeEyPXnm3qtWAPfeaz4azQkvunGSI6PSsdOw16HaY6AYnaKB7gOP3Pfqcro5gMBQ(gJbcG0pGeIQVXyGaiROEkR0aQvTEiGuynVbGCB3an9oTasiEXHk3NrgMdbq6hqcXlou5(mYWCdnbRLwqaKvupLvAa1QwpeqkSM3aqUTBGMENwajeV4qL7ZidZHai9diH4fhQCFgzyUHMG1sliaYWbYuvQOAazf1tzLgqTQ1dbKcNABai32nqtVtlGeIxCOY9zKH5qaK(bKq8IdvUpJmm3qtWAPfeaz4azQkvunGSI6PSsdOgO2gtp)ENwa5wazW9(gG02ihza1WW5)vAlHH3iaPquGCGmv7a50NgqMQrCC6b12iajdh0Kol9aPWAoDGu4nfEtqnqTG79nit(t8tNnCi1Qbsux)gvo5GAb37BqM8N4NoB4qQvdrePAN0tFcDsBafus8bsvUXvxrLFcOhul4EFdYK)e)0zdhsTAi4E7cAQh1tOBIHtGAb37BqM8N4NoB4qQvdpEL)rE65pXdKR8wN0w3Sv6Dr7lou5(mYGorB5(msr6S0J23FXHk3NrMHqOEYeeFAiL)rEEpzQipp(WfrGAb37BqM8N4NoB4qQvdwc5Dyvc(Wtsp)jEGCL36K26MTsVlAzMhwACdItJRUII1E3QkM9IdvUpJmOt0wUpJuKol9iqTG79nit(t8tNnCi1QrMy8Rog1vubuO)8eqTG79nit(t8tNnCi1QHoPFFAQROSI8EPwpf6iqTG79nit(t8tNnCi1QHiIuTt6PtLcXD1e6KwEAC75)nnxXAdKNEx0YSp6LIGMg30d0I2H(G1sgkLnYrvvH)9avYn1njbsXVZUobdK(3duj3iSjjqk(D21jyys49Dstf78CAzGo(oyTKQhNgu7PPY6Sa6Z6QdXBRn8EYupfC)(kb1cU33Gm5pXpD2WHuRgLJlIOLkGc9Ttkwk0tVlAz2h9srqtJB6bAr7qFWAjdLYg5iqTncqw9wBViYraPNqa5s8dVVbiJzbK87SRtWaKxbiREOCI7a5vaspHaYnEBxazmlGmvRV1dlqUXgK3d3rajBAaPNqa5s8dVVbiVcqgdqkojbYPfqUr3wQoqkiHgG0tO0G4jGuerlGm)j(PZgUbifI4HiIaYQhkN4oqEfG0tiGCJ32fq(0sKtiGCJUTuDGKnnGu4n3uhLoq6jnciBeqw3OzGer8BwidOwW9(gKj)j(PZgoKA1iq5e3vxr5jKsqBxPN)epqUYBDsBDJMtVlAzwaf6BNm5FRhwvpiVhUJm0eSwAvfZieIgozieIgoPUIYtiv54IOEYu93iJES93xvfKMk2550YeqbLeFGuLBC1vu5Na633zgPPIDEoTm8042Z)BAUI1giVsqTncqw9wBViYraPNqa5s8dVVbiJzbK87SRtWaKxbifIqEhwGCJ)HNaKXSaYunbuiG8kaPMqKrajBAaPNqa5s8dVVbiVcqgdqkojbYPfqUr3wQoqkiHgG0tO0G4jGuerlGm)j(PZgUbul4EFdYK)e)0zdhsTAWsiVdRsWhEs65pXdKR8wN0w3Sv6DrBaf6BNm5FRhwvpiVhUJm0eSwAvfZieIgozieIgoPUIYtiv54IOEYu93iJES93xvfKMk2550YeqbLeFGuLBC1vu5Na633zgPPIDEoTm8042Z)BAUI1giVsqnqTG79nii1Qb)ehNEfk5CqTncqYyQivpvSbGKXKgbKcARfihIwaj60jGuW9qnDGe1dNas(joo9kuY5ajpH4qfbKL7bYai5bYngdOwW9(geKA1GFIJtVcLCE62EifFPvZBMEx0(IdvUpJmikprekiv(FCBOhEFZ(o6eTS9SmtNwGu(DwKk)A0n77vWVzj2U5jOPhfw1vuL7DXHQIzV4qL7ZidIYteHcsL)h3g6H33ujOwW9(geKA1qerQ2jDeOwW9(geKA1W)y0uX22qPNmfk5CqTG79nii1QHiIuTt6O07I28NGwLXxM6MaLtCxDfLNqkbTDTVx6Sex9KE0dIjH3eul4EFdcsTAiIiv7KE6tOtAdOGsIpqQYnU6kQ8ta9P3fT87SRtWycuoXD1vuEcPe02L5j9OhKktKqiMQVvvLolXvpPh9Gsr9nb1cU33GGuRgIis1oPN(e6K2aLaDmes9buUxXVpSP3fTlIvSumFaL7v87dRArSILIrmVQkygPPIDEoTmbuqjXhiv5gxDfv(jG(9D)7bQKBcOGsIpqQYnU6kQ8ta9g(D21jympPh9GsX2vD77ecrdNmS27wQRO8esrdPNMrp2(7RSQkYFcAvgFzQBcuoXD1vuEcPe021(oZinvSZZPLHNg3E(FtZvS2a5vXkwkMaLtCxDfLNqkbTDzEsp6bLIuVYQQGzecrdNm8Bw0GOLY2fQCpNm6X2F)(oRyPyYeJF1XOUIkGc9NNyeZRSQk84Zi3KqH1tm5CNjnV1(oZieIgoz43SObrlLTlu5Eoz0JT)(9DM5HLg3a12APx1dY7H7vUVxXIyflfZhq5Ef)(WQweRyPywNGzFV0zjU6j9OhetcxDvwvPZsC1t6rpOuuHWPwQSc(D21jym8042Z)BAUI1gi38KE0dcYuJPsNL4QN0JEqvwjOwW9(geKA1qerQ2j90PsH4UAcDslpnU98)MMRyTbYtVlAzflfdlH8oSkbF4jM1jy23lDwIREsp6bX0wGAb37BqqQvdEyTQG79nkBJ80NqN0YxiqTG79nii1QbpSwvW9(gLTrE6tOtArE6DrBW9gAsrdP3eIjHb1cU33GGuRg8WAvb37Bu2g5PpHoPLBPaAk9UOn4EdnPOH0BcLI6GAGAb37Bqg(cPngoH8pSkEyTP3fT87SRtWyyjK3Hvj4dpX8KE0dkfAEtqTG79nidFHGuRgL(jw7DR07Iw(D21jymSeY7WQe8HNyEsp6bLcnVjOwW9(gKHVqqQvdw6r0d1EYsVlARGvSumcA7sHY7VDKrmFFNz8dAAIXntNL4QsqvXkwkMaLtCxDfLNqkbTDzeZRIvSumSeY7WQe8HNyeZRSQkkDwIREsp6bLc(D21jymS0JOhQ9KzwIF49nqUe)W7B23RWJpJCtcfwpXKZDM08w77mZdlnUbQT1sVQhK3d3RSY99sNL4QN0JEqmvxZGAb37Bqg(cbPwnyT3TufXpT07I2kyflfJG2UuO8(BhzeZ33zg)GMMyCZ0zjUQeuvSILIjq5e3vxr5jKsqBxgX8QyflfdlH8oSkbF4jgX8kRQIsNL4QN0JEqPGFNDDcgdR9ULQi(PzwIF49nqUe)W7B23RWJpJCtcfwpXKZDM08w77mZdlnUbQT1sVQhK3d3RSY99sNL4QN0JEqmvV6a1cU33Gm8fcsTAy7SehP2EXvMonoOwW9(gKHVqqQvJ8Z7BsVlAzflftGYjURUIYtiLG2UmI577LolXvpPh9Gys4Qdul4EFdYWxii1QHG7TlOPEupHUjgoLEx0wr(tqRY4ltDtGYjURUIYtiLG2U2353zxNGXeOCI7QRO8esjOTlZt6rpiMY4R99sNL4QN0JEqmj8MvUVZmcHOHtgOBuFJ6kQC6le37Bm69CpOwW9(gKHVqqQvJmX4xDmQROcOq)5jP3fT87SRtWycuoXD1vuEcPe02L5j9Ohet13CFV0zjU6j9Ohuk43zxNGbYL4hEFZ(EPZsC1t6rpiM08MGAb37Bqg(cbPwn(op3sQEuO8GtGAb37Bqg(cbPwn0j97ttDfLvK3l16PqhbQfCVVbz4leKA14PiVNmvXg6ek9UO1JpJCtcfwpXKZ9uSDBUV7XNrUjHcRNyY5otAfEZ9Dp(mYnERtk)u5Cxj8MPqZBcQbQfCVVbz4wkGM0gOCI7QRO8esjOTlqTG79nid3sb0eKA1GnEwAPqjNNopnULuE8zKJ0wp9UOnNCJE0JHvSumLNgOKMrmVQCYn6rpgwXsXuEAGsAMN0JEqmPnJVa1cU33GmClfqtqQvdDrR3OKZtVlAZ4lnXCYn6rpgwXsXWsbYvClfqtMN0JEqPytJWBbQfCVVbz4wkGMGuRgE8k)J807I2xCOY9zKbDI2Y9zKI0zPhvLhVY)i38KE0dIPm(Qk(D21jymfB8K5j9Ohetz8fOwW9(gKHBPaAcsTAuSXtP3fTE8k)JCJyEvV4qL7Zid6eTL7ZifPZspcul4EFdYWTuanbPwnwu4jkEsa1p0tVlAlhxebjpqU6PmAyQCCrKrpsjOwW9(gKHBPaAcsTAiOTlfkV)2rGAb37BqgULcOji1QbB8S0sHsopDEAClP84ZihPTE6DrBr0AvpXtIpJuERtmLXxvXVZUobJHLqEhwLGp8eZt6rpO9D(D21jymSeY7WQe8HNyEsp6bXuDHHmJVQYdlnUbXPXvxrXAVBbQfCVVbz4wkGMGuRgSeY7WQe8HNaQfCVVbz4wkGMGuRgpHUj8EYuX)NaqTG79nid3sb0eKA1a5HEoTO07IwwXsXeOCI7QRO8esjOTlJy((EPZsC1t6rpiMQVfOwW9(gKHBPaAcsTAuSrA0sHsohul4EFdYWTuanbPwnGABTkuY5GAb37BqgULcOji1QbpP1d6dfk5CqTG79nid3sb0eKA1G1E3cLqlqTG79nid3sb0eKA1iu6I)IE1vu8)eGa1cU33GmClfqtqQvd24)iJsVlAZj3Oh9yyflft5PbkPzEsp6bLckLex0jL36eOwW9(gKHBPaAcsTAa12Av8txpMv6DrB54IOuWpKdzW9(gJUO1BuY5g(HCqTG79nid3sb0eKA1GnYuxr5FZHkk9UOLvSumSeY7WQe8HNywNGzFV0zjU6j9OhetBbQfCVVbz4wkGMGuRgR(jflfihul4EFdYWTuanbPwnyJNLwkuY5PZtJBjLhFg5iT1tVlA94Zi34ToP8tTAIPuhul4EFdYWTuanbPwn4h7hkuY5P3fTLJlImERtk)u6rkzkJVsLcdQfCVVbz4wkGMGuRgE8k)J807I2xCOY9zKbDI2Y9zKI0zPhTV)IdvUpJmdHq9Kji(0qk)J88EYurEE8HlIa1cU33GmClfqtqQvJYteu6jt5FKNEx0(IdvUpJmdHq9Kji(0qk)J88EYurEE8HlIa1cU33GmClfqtqQvJYXfr0sfqH(2jflf6GAb37BqgULcOji1QrU43L06jtXAdKdQfCVVbz4wkGMGuRg8B404F40svSHobQfCVVbz4wkGMGuRgS27wQRO8esrdPNgOwW9(gKHBPaAcsTA4jKsCypXzPk3ZP07IwwXsX8ehQwcHuL75KrmFFNvSumpXHQLqiv5EoP4N440BqEWHkt13eudul4EFdYGCTbkN4U6kkpHucA7cul4EFdYGCi1QbB8S0sHsop9UOnNCJE0JHvSumLNgOKMrmVQCYn6rpgwXsXuEAGsAMN0JEqmPnJVa1cU33GmihsTA4XR8pYtVlAFXHk3Nrg0jAl3NrksNLEuvE8k)JCZt6rpiMY4RQ43zxNGXuSXtMN0JEqmLXxGAb37BqgKdPwnk24P07IwpEL)rUrmVQxCOY9zKbDI2Y9zKI0zPhbQfCVVbzqoKA1G1E3cLqlqTG79nidYHuRgcA7sHY7VDeOwW9(gKb5qQvJInsJwkuY5GAb37BqgKdPwnGABTkuY5P3fTSILIPyJ0OhP0JhQMN0JEqmT1(UhFg5MekSEIjN7mPv4nb1cU33GmihsTAWgplTuOKZtVlARGFNDDcgJG2UuO8(BhzEsp6bLIIO1QEINeFgP8wN23zg)GMMyCZ0zjUQeuLvvb)o76emgwc5Dyvc(WtmpPh9GyQUWPsEs8zesv(G79nHfYm(QkpS04geNgxDffR9U1(Er0AvpXtIpJuERtmLXxvXVZUobJHLqEhwLGp8eZt6rpOk3394Zi34ToP8tTAIPuhul4EFdYGCi1QXIcprXtcO(HE6DrB54Iii5bYvpLrdtLJlIm6rkb1cU33GmihsTAG8qpNwu6DrlRyPycuoXD1vuEcPe02LrmFFV0zjU6j9Ohet13cul4EFdYGCi1Qb)gon(hoTufBOtP3fTLJlIGSCCrK5PmAsLz8ftLJlIm6rkRIvSumSeY7WQe8HNywNGPQky26Cd)gon(hoTufBOtkwXFmpPh9GQIzb37Bm8B404F40svSHoz6rvSDwIx5(Er0AvpXtIpJuERtmLXx77LolXvpPh9GyAlqTG79nidYHuRgHsx8x0RUII)NaeOwW9(gKb5qQvJNq3eEpzQ4)tq6DrlRyPyyjK3Hvj4dpXiMVVx6Sex9KE0dIP6BcQfCVVbzqoKA1GLqEhwLGp8K07Iw(D21jymcA7sHY7VDK5j9OhukQV1(oZ4h00eJBMolXvLG23lDwIREsp6bXu9Ta1cU33GmihsTAWtA9G(qHsohul4EFdYGCi1Qr54IiAPcOqF7KILc907IwwXsXWsiVdRsWhEIzDcM99sNL4QN0JEqmTfOwW9(gKb5qQvdpHuId7jolv5EoLEx0YkwkMN4q1siKQCpNmI577SILI5jouTecPk3Zjf)ehNEdYdouzQ(M77LolXvpPh9GyAlqTG79nidYHuRgpHUj8EYuX)NG07IwwXsXWsiVdRsWhEIrmFFV0zjU6j9Ohet13eul4EFdYGCi1QblH8oSkbF4jP3fT87SRtWye02LcL3F7iZt6rpOuuFR9DMXpOPjg3mDwIRkbTVx6Sex9KE0dIP6BbQfCVVbzqoKA1GN06b9HcLCoOwW9(gKb5qQvdw7Dl1vuEcPOH0tl9UOLvSumbkN4U6kkpHucA7Y8KE0dkf13eYm(AFV0zjU6j9Ohet13eYm(cul4EFdYGCi1QbuBRvXpD9ywGAb37BqgKdPwnyJm1vu(3COIsVlAzflfdlH8oSkbF4jM1jy23lDwIREsp6bX0wGAb37BqgKdPwnw9tkwkqoOwW9(gKb5qQvd(X(HcLCE6DrBfLJlI0e5hYHSCCrK5PmAsLvWVZUobJbQT1Q4NUEmlZt6rpinX6vMIG79ngO2wRIF66XSm8d57787SRtWyGABTk(PRhZY8KE0dkf1HmJVQCFVcwXsXWsiVdRsWhEIrmFFNvSumdHq9Kji(0qk)J88EYurEE8HlImI5vwfZEXHk3NrgnnYTHIEAjokbXRUFr)(EPZsC1t6rpiM0mOwW9(gKb5qQvd24zPLcLCE6DrlRyPye02LcL3F7iJyoOwW9(gKb5qQvJ45XqQCrlIsVlAzflfdlH8oSkbF4jM1jy23lDwIREsp6bX0wGAb37BqgKdPwn84v(h5P3fTV4qL7Zid6eTL7ZifPZspAF)fhQCFgzgcH6jtq8PHu(h559KPI884dxebQfCVVbzqoKA1O8ebLEYu(h5P3fTV4qL7ZiZqiupzcIpnKY)ipVNmvKNhF4IimmkN4ygeERTWo2Xya]] )

end