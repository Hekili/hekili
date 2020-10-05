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
            value = function () return conduit.necrotic_barrage.enabled and 5 or 3 end,
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
            cooldown = 20,
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
        spec:RegisterPack( "Survival", 20200925.9, [[da0s4aqivfEKQIOljeOnPQYOuvuNcfvwLqf5ve0Siq7sWVuv1Wqr5ycrldf5zcHMMQI01qPQTje03qrvnovfHZjuH1HIQqZtvP7Hs2hkvwik0drrvWirrvQtIIQOvQkzMOOkzNQIEQOMQQu7vL)sXGLQdtAXq5XqMSixgzZs5ZeA0cPtlz1cb8AHYSj62OYUv8BLgoQ64cvA5aph00P66q12jGVJcgVqvNhLY6fQOMVQW(P0xK37lNuNUNmXmMygZIdMyFGzXb7zpZ(0l7SXtxMxrXur6YJYrxoJdeOeqLxMxztUA6EFz4Idq0LJ6opK5X))flpkowaTC)HfhUu9AheqB(FyXH(Fzm8s6mpNd7Yj1P7jtmJjMXS4Gj2hywCWE2ZmMUSI7rxWLZfhUu9AhMhaAZVC0kLO5WUCIGOl)jT9moqGsavA7mVXhNa2xFsBpt8oXHraBNj2lOTZeZyIz2x2xFsBN5fjajTD2z7SNzHlllOdV3xornfx6377zK37lRiV25YC4X54SKUmnkMKshJNFpz6EFzf51oxghsMYjo4LPrXKu6y887zeV3xMgftsPJXlRiV25YivknkYRDmYc6xwwq3mkhDzucE(98tV3xMgftsPJXlJaLtGsVSI8saYqdXve02)A7mDzf51oxgPsPrrETJrwq)YYc6Mr5Old9ZVNS)EFzAumjLogVmcuobk9YkYlbidnexrqBND2EKxwrETZLrQuAuKx7yKf0VSSGUzuo6YijPcqNFpJW79LvKx7CzfG0Hm(ca04xMgftsPJXZVNm)79LvKx7Czmv0SnJdkum4LPrXKu6y88ZVmssQa09(Eg59(Y0OyskDmEzeOCcu6LDvsJhCcWbnBZqJOksC04bAumjLS9F2EBr4qB)RT3weomWPXFzf51oxoQc43Do)EY09(YkYRDUmdLmzG8fOC4LPrXKu6y887zeV3xMgftsPJXlJaLtGsVmaFO2cePaCXLTfisgIdJaWafx8INNs2(pB3vGXbkFaqCAnqB)RTlIs2(pBhTRmTmmHMubuaqCAnqB)RTlIsxwrETZLDfyCGYF(98tV3xMgftsPJXlJaLtGsVmaFO2cePaCXLTfisgIdJaWafx8INNs2(pB3vGXbkFaN)YkYRDUCtQa687j7V3xwrETZLbeCh1Rr0OaWYWLPrXKu6y887zeEVVmnkMKshJxgbkNaLE5gUuAaekQcejJxCKT)12frPlRiV25YmuYuRaKbB5Wo)EY8V3xwrETZLrr1yaLdEzAumjLogp)E(jU3xMgftsPJXlJaLtGsVCA9amkq5hsAWwoSGxOy1iA7)S9pB7P1d14eyuPbtsuQgXa0vumB)RTZKT)4HTNwpaJcu(HKgSLdlaioTgOT)12frjBN5USI8ANlJH7OOeGTZVNXX9(Y0OyskDmEzeOCcu6LtRhGrbk)qsd2YHf8cfRgXlRiV25YifiaD(9msMDVVmnkMKshJxgbkNaLE52IWH2UqBhPq3airAS9V2EBr4WaNg)LvKx7C5ePEudkQgdOCNFpJmY79LvKx7Cz0UGunQtjJcHkU0VmnkMKshJNFpJKP79LPrXKu6y8Yiq5eO0lJIQarcAAaf51oQ02zNTZuG92(pBhTRmTmmbgkzQvaYGTCyHgUuAaekQcejJxCKTZoBhYtsPXvGi5qBpcA7mDzf51oxgd3rrjaBNFpJmI37ltJIjP0X4LrGYjqPxUTiCOTl02rk0nasKgB)RT3weomWPXFzf51oxUj1jwnIgOdQy053Zi)079LPrXKu6y8YkYRDUCSsknOLJtN0LrGYjqPxUTiCOTl02rk0nasKgB)RT3weomWPXB7)S9gUuAaekQcejJxCKT)12frPlJydjjJRarYH3Zip)Egj7V3xMgftsPJXlJaLtGsV8h2EA9adLm1kazWwoSGxOy1iEzf51oxMHsMAfGmylh253ZiJW79LPrXKu6y8Yiq5eO0l)zB)dBFO4DddLbB5WcWOaLFiPT)4HT)HT7QKgpWqjtTcqMAA4WANankMKs2oZz7)SD0UY0YWeyOKPwbid2YHfA4sPbqOOkqKmEXr2o7SDipjLgxbIKdT9iOTZ0LvKx7CzmChfLaSD(9msM)9(Y0OyskDmEzeOCcu6Lr7ktldtGHsMAfGmylhwOHlLgaHIQarY4fhz7SZ2H8KuACfiso02JG2otxwrETZLrkqa687zKFI79LvKx7C5yLuAGrx)Y0OyskDmE(9mY44EFzf51oxUjv2OKbgD9ltJIjP0X453tMy29(YkYRDUSA4Wbjcy2MbbwgGxMgftsPJXZVNmf59(Y0OyskDmEzeOCcu6L)W2b4d1wGifgccRrKbfWg04aLNVgrJYZRa1XHbkU4fppLS9hpS92IWH2UqBhPq3airASDH2otS32)A7TfHddCA8xwrETZLHorsJdu(ZVNmX09(Y0OyskDmEzf51oxgsaEACd0Rr8Yiq5eO0ldOgGGrvmjz7)SDxL04HOSLak0GvofOrXKu6Yi2qsY4kqKC49mYZVNmfX79LvKx7CzKceGUmnkMKshJNFpz6tV3xMgftsPJXlRiV25YXkP0GwooDsxgbkNaLE52IWH2UqBhPq3airAS9V2EBr4WaNg)LrSHKKXvGi5W7zKNFpzI937ltJIjP0X4LvKx7Czib4PXnqVgXlJaLtGsVmGAacgvXKKT)Z2)ST)HT7QKgpGvGe0SndpGylqJIjPKT)4HT)HTJH3Ab0UGunQtjJcHkU0d482oZz7)S9pB7Fy7a8HAlqKca2KAmORYyeaAq70w8jvJOb6GkgbduCXlEEkz7pEy7dfVByOmylhwqGvQEjjB)XdB3vjnEad3rrjaBbAumjLSDMZ2F8W2XWBTGafpbGgbOz5c48xgXgssgxbIKdVNrE(9KPi8EFzAumjLogVSI8ANlZTJ4UqYGvoDzeOCcu6LtegERfKQtJB43cUJPMiaH8ANa0vumBND2ECCzeBijzCfiso8Eg553tMy(37ltJIjP0X4LvKx7CzGY7lWaDqfJUmcuobk9YjcdV1cs1PXn8Bb3XuteGqETta6kkMTZoBpoUmInKKmUcejhEpJ887jtFI79LPrXKu6y8YkYRDUmKa804gOxJ4LrGYjqPx(dB3vjnEaRajOzBgEaXwGgftsjB)NT)HT7QKgpiqXtaOraAwUankMKs2(pB)dBhGpuBbIuqQonUHFl4oMAIaeYxamqXfV45PKT)Z2)W2b4d1wGifaSj1yqxLXia0G2PT4tQgrd0bvmcgO4Ix88u6Yi2qsY4kqKC49mYZVNmfh37ltJIjP0X4LvKx7CzUDe3fsgSYPlJydjjJRarYH3Zip)EgrMDVVmnkMKshJxwrETZLbkVVad0bvm6Yi2qsY4kqKC49mYZp)YOe8EFpJ8EFzAumjLogVmcuobk9YODLPLHjG2fKQrDkzuiuXLEaqCAnqBND2Eez2LvKx7Czm5UjtdhW253tMU3xMgftsPJXlJaLtGsVmAxzAzycODbPAuNsgfcvCPhaeNwd02zNThrMDzf51oxwhebDGknivkp)EgX79LPrXKu6y8Yiq5eO0lJ2vMwgMaAxqQg1PKrHqfx6baXP1aTD2z7rKzxwrETZLBfGWK7Mo)E(P37lRiV25YYsmQdnra8Kihn(LPrXKu6y887j7V3xMgftsPJXlJaLtGsVmAxzAzycODbPAuNsgfcvCPhaeNwd02zNThHmZ2F8W29IJm(Asfz7FT9iJ4LvKx7CzmcajqSAep)EgH37ltJIjP0X4LrGYjqPxUvIrDdG40AG2(xBNPi02F8W2XWBTaAxqQg1PKrHqfx6bC(lRiV25Y8Rx7C(9K5FVVmnkMKshJxgbkNaLEzxbIKhsf01br2o7yz7r4LvKx7CzfYti3SnJhLmKkkPZp)Yq)EFpJ8EFzAumjLogVmcuobk9YUkPXdob4GMTzOrufjoA8ankMKs2(pBVTiCOT)12Blchg404VSI8ANlhvb87oNFpz6EFzAumjLogVmcuobk9YTfHdTDH2osHUbqI0y7FT92IWHbonEB)NTJH3AbV4nBZ4rjdKNuqa6kkMT)12JOT)Z2)W2DvsJhujFu1WdOK6liqJIjP0LvKx7C5yLuAqlhNoPZVNr8EFzAumjLogVmcuobk9YP1dWOaLFiPbB5WcEHIvJOT)Z2)STNwpuJtGrLgmjrPAedqxrXS9V2ot2(Jh2EA9amkq5hsAWwoSaG40AG2(xBxeLSDMZ2F8W2XWBTa3oI7cjtdhWwaN32)z7y4TwGBhXDHKPHdylaioTgOT)12BlchA7rqBpImZ2Jt2Uikz7pEy7UkPXdyfibnBZWdi2c0Oyskz7)SDm8wlG2fKQrDkzuiuXLEaN32)z7y4TwaTlivJ6uYOqOIl9aG40AG2(xBxeLUSI8ANlZTJ4UqYGvoD(98tV3xMgftsPJXlJaLtGsVCA9amkq5hsAWwoSGxOy1iA7)S9pB7P1d14eyuPbtsuQgXa0vumB)RTZKT)4HTNwpaJcu(HKgSLdlaioTgOT)12frjBN5S9hpSDxL04bScKGMTz4beBbAumjLS9F2ogERfq7cs1OoLmkeQ4spGZB7)SDm8wlG2fKQrDkzuiuXLEaqCAnqB)RTlIsxwrETZLbkVVad0bvm687j7V3xwrETZLzOKjdKVaLdVmnkMKshJNFpJW79LPrXKu6y8Yiq5eO0ldWhQTarkaxCzBbIKH4WiamqXfV45PKT)Z2DfyCGYhaeNwd02)A7IOKT)Z2r7ktldtOjvafaeNwd02)A7IO0LvKx7CzxbghO8NFpz(37ltJIjP0X4LrGYjqPxgGpuBbIuaU4Y2cejdXHrayGIlEXZtjB)NT7kW4aLpGZFzf51oxUjvaD(98tCVVSI8ANlJ2fKQrDkzuiuXL(LPrXKu6y887zCCVVSI8ANldi4oQxJOrbGLHltJIjP0X453Ziz29(YkYRDUCtQSrjdm66xMgftsPJXZVNrg59(Y0OyskDmEzeOCcu6LBlchA7cTDKcDdGePX2)A7TfHddCA8xwrETZLtK6rnOOAmGYD(9msMU3xwrETZLJvsPbgD9ltJIjP0X453ZiJ49(Y0OyskDmEzeOCcu6LBlchA7cTDKcDdGePX2)A7TfHddCA8xwrETZLBsDIvJOb6GkgD(9mYp9EFzAumjLogVmcuobk9YTfHdTDH2osHUbqI0y7FT92IWHbonEB)NTJH3AbV4nBZ4rjdKNuqa6kkMT)12JOT)Z2B4sPbqOOkqKmEXr2(xBNjBpoz7IO0LvKx7C5yLuAqlhNoPZVNrY(79LvKx7Czuungq5GxMgftsPJXZVNrgH37lRiV25YQHdhKiGzBgeyzaEzAumjLogp)EgjZ)EFzAumjLogVmcuobk9YdfVByOmylhwqGvQEjjB)NTNwpajapnUb61ig8cfRgrB)NTNwpajapnUb61igaudqWOkMKUSI8ANlZqjtTcqgSLd787zKFI79LPrXKu6y8Yiq5eO0ldOgGGrvmjz7)S9pB7y4TwGBhXDHKPHdylaDffZ2)A7S32F8W2)W2DvsJh42rCxizWkNc0Oyskz7mNT)Z2)ST)HTJH3Ab0UGunQtjJcHkU0d482(Jh2(h2URsA8awbsqZ2m8aITankMKs2oZz7pEy7y4TwqGINaqJa0SCbC(lRiV25YqcWtJBGEnINFpJmoU3xMgftsPJXlJaLtGsV8qX7ggkd2YHfGrbk)qsB)NT3weo02zNThHmZ2F8W2hkE3WqzWwoSaFucSC7q2(pB)Z2EBr4qBxOTJuOBaKin2UqBxrETtiwjLg0YXPtkGuOBaKin2ECY2JOT)12Blchg404T9hpSDxL04bUDe3fsgSYPankMKs2(pB)dBhdV1cC7iUlKmnCaBbCEBN5S9hpS9pS906bgkzQvaYGTCybVqXQr02)z7nCP0aiuufisgV4iB)RTlIsxwrETZLzOKPwbid2YHD(9KjMDVVmnkMKshJxgbkNaLE52IWH2UqBhPq3airAS9V2EBr4WaNgVT)Z2XWBTGx8MTz8OKbYtkiaDffZ2)A7r8YkYRDUCSsknOLJtN053tMI8EFzAumjLogVmcuobk9YFy7a8HAlqKcdbH1iYGcydACGYZxJOr55vG64Wafx8INNs2(Jh2EBr4qBxOTJuOBaKin2UqBNj2B7FT92IWHbon(lRiV25YqNiPXbk)53tMy6EFzAumjLogVmcuobk9Ya8HAlqKcdbH1iYGcydACGYZxJOr55vG64Wafx8INNs2(pBVTiCOTl02rk0nasKgBxOTZe7T9V2EBr4WaNg)LvKx7CzxbghO8NFpzkI37ltJIjP0X4LrGYjqPxgGpuBbIuyiiSgrguaBqJduE(AenkpVcuhhgO4Ix88uY2)z7TfHdTDH2osHUbqI0y7cTDMyVT)12Blchg404VSI8ANl3aefNRr04aL)87jtF69(Y0OyskDmEzeOCcu6LXWBTa3oI7cjtdhWwaN32F8W2BlchA7cTDf51oHyLuAqlhNoPasHUbqI0y7SZ2Blchg404VSI8ANlZTJ4UqYGvoD(9Kj2FVVmnkMKshJxgbkNaLE5pS9HI3nmugSLdlaJcu(HK2(Jh2ogERf8I3SnJhLmqEsbbOROy2o7SDMS9hpS92IWH2UqBxrETtiwjLg0YXPtkGuOBaKin2o7S92IWHbon(lRiV25YaL3xGb6GkgD(9KPi8EFzAumjLogVmcuobk9Yy4TwWlEZ2mEuYa5jfeGUIIz7FT9iEzf51oxowjLg0YXPt687jtm)79LPrXKu6y8Yiq5eO0l)HTNwpWqjtTcqgSLdl4fkwnI2(pB)dB3vjnEGHsMAfGm10WH1obAumjLUSI8ANlZqjtTcqgSLd78ZVmpGqlhM6377zK37lRiV25YrXhNaqdNcIDzAumjLogp)EY09(Y0OyskDmEzeOCcu6Lb4d1wGifGlUSTarYqCyeagO4Ix88u6YkYRDUSRaJdu(ZVNr8EFzf51oxg6ejnoq5VmnkMKshJNFp)079LvKx7Cz0UGunQtjJcHkU0VmnkMKshJNFpz)9(Y0OyskDmEzf51oxMF9ANlNyBuUcz4be)6xoYZp)8llabG1o3tMygtmJzFcMIJqKxMbfm1icVmZto(f4uY2zVTRiV2X2Lf0Hb7Rld5j09Kj2Z(lZd2wjPl)jT9moqGsavA7mVXhNa2xFsBpt8oXHraBNj2lOTZeZyIz2x2xFsBN5fjajTD2z7SNzb7l7lf51oWapGqlhM6cz9pk(4eaA4uqm7lf51oWapGqlhM6cz93vGXbkVGvJfaFO2cePaCXLTfisgIdJaWafx8INNs2xkYRDGbEaHwom1fY6p0jsACGYBFPiV2bg4beA5WuxiR)ODbPAuNsgfcvCPBFPiV2bg4beA5WuxiR)8Rx7iyITr5kKHhq8RZks7l7lf51oWakbfY6pMC3KPHdytWQXcTRmTmmb0UGunQtjJcHkU0daItRbYUiYm7lf51oWakbfY6Voic6avAqQuky1yH2vMwgMaAxqQg1PKrHqfx6baXP1azxezM9LI8AhyaLGcz9VvactUBsWQXcTRmTmmb0UGunQtjJcHkU0daItRbYUiYm7lf51oWakbfY6VSeJ6qteapjYrJBFPiV2bgqjOqw)XiaKaXQruWQXcTRmTmmb0UGunQtjJcHkU0daItRbYUiKzpE4fhz81Kk6BKr0(srETdmGsqHS(ZVETJGvJvReJ6gaXP1a)Yue(4bgERfq7cs1OoLmkeQ4spGZBFPiV2bgqjOqw)vipHCZ2mEuYqQOKeSASCfisEivqxheXowrO9L9LI8AhOqw)5WJZXzjzFPiV2bkK1FCizkN4G2xkYRDGcz9hPsPrrETJrwqxWr5iwOe0(srETduiR)ivknkYRDmYc6cokhXc6cwnwkYlbidnexrWVmzFPiV2bkK1FKkLgf51ogzbDbhLJyHKKkajy1yPiVeGm0qCfbzxK2xkYRDGcz9xbiDiJVaanU9LI8AhOqw)XurZ2moOqXG2x2xkYRDGbOlK1)OkGF3rWQXYvjnEWjah0SndnIQiXrJhOrXKu6xBr4WVTfHddCA82xkYRDGbOlK1)yLuAqlhNojbRgR2IWHcrk0nasKMVTfHddCA8)WWBTGx8MTz8OKbYtkiaDff7Be)9HRsA8Gk5JQgEaLuFbbAumjLSVuKx7adqxiR)C7iUlKmyLtcwnwP1dWOaLFiPbB5WcEHIvJ4VpNwpuJtGrLgmjrPAedqxrX(Y0JhP1dWOaLFiPbB5WcaItRb(veLyUhpWWBTa3oI7cjtdhWwaN)hgERf42rCxizA4a2caItRb(TTiCyemImlojIspE4QKgpGvGe0SndpGylqJIjP0pm8wlG2fKQrDkzuiuXLEaN)hgERfq7cs1OoLmkeQ4spaioTg4xruY(srETdmaDHS(duEFbgOdQyKGvJvA9amkq5hsAWwoSGxOy1i(7ZP1d14eyuPbtsuQgXa0vuSVm94rA9amkq5hsAWwoSaG40AGFfrjM7XdxL04bScKGMTz4beBbAumjL(HH3Ab0UGunQtjJcHkU0d48)WWBTaAxqQg1PKrHqfx6baXP1a)kIs2xkYRDGbOlK1FgkzYa5lq5q7lf51oWa0fY6VRaJduEbRgla(qTfisb4IlBlqKmehgbGbkU4fppL(5kW4aLpaioTg4xru6hAxzAzycnPcOaG40AGFfrj7lf51oWa0fY6FtQasWQXcGpuBbIuaU4Y2cejdXHrayGIlEXZtPFUcmoq5d482xkYRDGbOlK1F0UGunQtjJcHkU0TVuKx7adqxiR)acUJ61iAuayzW(srETdmaDHS(3KkBuYaJUU9LI8Ahya6cz9prQh1GIQXakNGvJvBr4qHif6gajsZ32IWHbonE7lf51oWa0fY6FSsknWORBFPiV2bgGUqw)BsDIvJOb6Gkgjy1y1weouisHUbqI08TTiCyGtJ3(srETdmaDHS(hRKsdA540jjy1y1weouisHUbqI08TTiCyGtJ)hgERf8I3SnJhLmqEsbbOROyFJ4VgUuAaekQcejJxC0xMItIOK9LI8Ahya6cz9hfvJbuoO9LI8Ahya6cz9xnC4GebmBZGaldq7lf51oWa0fY6pdLm1kazWwombRgRHI3nmugSLdliWkvVK0V06bib4PXnqVgXGxOy1i(lTEasaEACd0RrmaOgGGrvmjzFPiV2bgGUqw)HeGNg3a9AefSASaudqWOkMK(9zm8wlWTJ4UqY0WbSfGUII9L9pE8HRsA8a3oI7cjdw5uGgftsjM73N)adV1cODbPAuNsgfcvCPhW5F84dxL04bScKGMTz4beBbAumjLyUhpWWBTGafpbGgbOz5c482xkYRDGbOlK1FgkzQvaYGTCycwnwdfVByOmylhwagfO8dj)1weoKDriZE8yO4DddLbB5Wc8rjWYTd97ZTfHdfIuOBaKincvKx7eIvsPbTCC6Kcif6gajstCkIFBlchg404F8WvjnEGBhXDHKbRCkqJIjP0VpWWBTa3oI7cjtdhWwaNN5E84J06bgkzQvaYGTCybVqXQr8xdxknacfvbIKXlo6RikzFPiV2bgGUqw)JvsPbTCC6KeSASAlchkePq3airA(2weomWPX)ddV1cEXB2MXJsgipPGa0vuSVr0(srETdmaDHS(dDIKghO8cwnwFaWhQTarkmeewJidkGnOXbkpFnIgLNxbQJdduCXlEEk94rBr4qHif6gajsJqMy)32IWHbonE7lf51oWa0fY6VRaJduEbRgla(qTfisHHGWAezqbSbnoq55Rr0O88kqDCyGIlEXZtPFTfHdfIuOBaKinczI9FBlchg404TVuKx7adqxiR)narX5Aenoq5fSASa4d1wGifgccRrKbfWg04aLNVgrJYZRa1XHbkU4fppL(1weouisHUbqI0iKj2)TTiCyGtJ3(srETdmaDHS(ZTJ4UqYGvojy1yHH3AbUDe3fsMgoGTao)JhTfHdfQiV2jeRKsdA540jfqk0nasKg21weomWPXBFPiV2bgGUqw)bkVVad0bvmsWQX6JHI3nmugSLdlaJcu(HKpEGH3AbV4nBZ4rjdKNuqa6kkg7y6XJ2IWHcvKx7eIvsPbTCC6Kcif6gajsd7Alchg404TVuKx7adqxiR)XkP0GwooDscwnwy4TwWlEZ2mEuYa5jfeGUII9nI2xkYRDGbOlK1FgkzQvaYGTCycwnwFKwpWqjtTcqgSLdl4fkwnI)(WvjnEGHsMAfGm10WH1obAumjLSVSVuKx7adijPcqcz9pQc43DeSASCvsJhCcWbnBZqJOksC04bAumjL(1weo8BBr4WaNgV9LI8AhyajjvasiR)muYKbYxGYH2xkYRDGbKKubiHS(7kW4aLxWQXcGpuBbIuaU4Y2cejdXHrayGIlEXZtPFUcmoq5daItRb(veL(H2vMwgMqtQakaioTg4xruY(srETdmGKKkajK1)MubKGvJfaFO2cePaCXLTfisgIdJaWafx8INNs)CfyCGYhW5TVuKx7adijPcqcz9hqWDuVgrJcald2xkYRDGbKKubiHS(ZqjtTcqgSLdtWQXQHlLgaHIQarY4fh9veLSVuKx7adijPcqcz9hfvJbuoO9LI8AhyajjvasiR)y4okkbytWQXkTEagfO8djnylhwWluSAe)9506HACcmQ0GjjkvJya6kk2xME8iTEagfO8djnylhwaqCAnWVIOeZzFPiV2bgqssfGeY6psbcqcwnwP1dWOaLFiPbB5WcEHIvJO9LI8AhyajjvasiR)js9Oguungq5eSASAlchkePq3airA(2weomWPXBFPiV2bgqssfGeY6pAxqQg1PKrHqfx62xkYRDGbKKubiHS(JH7OOeGnbRgluufisqtdOiV2rLSJPa7)H2vMwgMadLm1kazWwoSqdxknacfvbIKXloIDqEsknUcejhgbzY(srETdmGKKkajK1)MuNy1iAGoOIrcwnwTfHdfIuOBaKinFBlchg404TVuKx7adijPcqcz9pwjLg0YXPtsqeBijzCfisoKvKcwnwTfHdfIuOBaKinFBlchg404)1WLsdGqrvGiz8IJ(kIs2xkYRDGbKKubiHS(ZqjtTcqgSLdtWQX6J06bgkzQvaYGTCybVqXQr0(srETdmGKKkajK1FmChfLaSjy1y95pgkE3WqzWwoSamkq5hs(4XhUkPXdmuYuRaKPMgoS2jqJIjPeZ9dTRmTmmbgkzQvaYGTCyHgUuAaekQcejJxCe7G8KuACfisomcYK9LI8AhyajjvasiR)ifiajy1yH2vMwgMadLm1kazWwoSqdxknacfvbIKXloIDqEsknUcejhgbzY(srETdmGKKkajK1)yLuAGrx3(srETdmGKKkajK1)MuzJsgy01TVuKx7adijPcqcz9xnC4GebmBZGaldq7lf51oWassQaKqw)HorsJduEbRgRpa4d1wGifgccRrKbfWg04aLNVgrJYZRa1XHbkU4fppLE8OTiCOqKcDdGePritS)BBr4WaNgV9LI8AhyajjvasiR)qcWtJBGEnIcIydjjJRarYHSIuWQXcqnabJQys6NRsA8qu2safAWkNc0OyskzFPiV2bgqssfGeY6psbcq2xkYRDGbKKubiHS(hRKsdA540jjiInKKmUcejhYksbRgR2IWHcrk0nasKMVTfHddCA82xkYRDGbKKubiHS(djapnUb61ikiInKKmUcejhYksbRgla1aemQIjPFF(dxL04bScKGMTz4beBbAumjLE84dm8wlG2fKQrDkzuiuXLEaNN5(95pa4d1wGifaSj1yqxLXia0G2PT4tQgrd0bvmcgO4Ix88u6XJHI3nmugSLdliWkvVK0JhUkPXdy4okkbylqJIjPeZ94bgERfeO4ja0ianlxaN3(srETdmGKKkajK1FUDe3fsgSYjbrSHKKXvGi5qwrky1yLim8wlivNg3WVfChtnrac51obOROySloSVuKx7adijPcqcz9hO8(cmqhuXibrSHKKXvGi5qwrky1yLim8wlivNg3WVfChtnrac51obOROySloSVuKx7adijPcqcz9hsaEACd0RruqeBijzCfisoKvKcwnwF4QKgpGvGe0SndpGylqJIjP0VpCvsJheO4ja0ianlxGgftsPFFaWhQTarkivNg3WVfChtnrac5lagO4Ix88u63ha8HAlqKca2KAmORYyeaAq70w8jvJOb6GkgbduCXlEEkzFPiV2bgqssfGeY6p3oI7cjdw5KGi2qsY4kqKCiRiTVuKx7adijPcqcz9hO8(cmqhuXibrSHKKXvGi5qwrE(53b]] )
    else
        spec:RegisterPack( "Survival", 20200925.1, [[dyuL3bqifQEKijCjIQOAtIuJsKuNsHsRIOQELIywevUfrvyxK8lIIHbvvhdkSmOQ8mfkMguI6AkQSnrs6BqjOXbLqNdkrwhucOMhu09is7dkPdcLaSqIspekbkxekbYgjQIOrsufPojrvuwjuQzsufj3ekbQ2juXqHsa5PaMkuPVsufH9c5VinykDyQwSkEmIjlQlJAZK6ZIy0ksNwYQfjrVgQYSP42aTBL(Tudxblh0Zv10fUUkTDfLVRqgVIQoViX6jQsZNi2pHryGWfbK9Gr4Gp8Jp8JFSe(MtHFS0CJbdSmciszGradobppHraRdYiaGlCwnZniGbpft7zeUiGVVqcJaMgXWJfyzKjPIP3JI0GY8f414r1lb66qMVajYGao3YeYZw0bbK9Gr4Gp8Jp8JFSe(MtHFS0CJbd8Ha8BmTHiaGc8A8O6flyqxhiGPvoZl6GaY8tqaPcHf4cNvZCJWkp9DdgkWoviSa8qWGhgkS4Bo5ew8HF8HFb2cStfcR8u8m2iSyvyNd)keGP(4r4Ia8Hpq4IWbdeUiaNevVia8kJH(t7abWRFmCgjlkq4GpeUiaE9JHZizraeyfmSCeW5Q1ks3WCTEWzQ)VFnH6oiSPf2ulSNRwRiDdZ16bNP()(1ekid61(clMclgQ5ew5lSjKSWkrIWEUAT6yUqARPHB69v3bHnTWEUAT6yUqARPHB69vqg0R9fwmfwmuZjSYxytizHDSiaNevViaWEt6(z6PcgfiCgdcxeaV(XWzKSiacScgwoc4C1AfPByUwp4m1)3VMqDhe20cBQf2ZvRvKUH5A9GZu)F)AcfKb9AFHftHfd1CcR8f2eswyLirypxTwDmxiT10Wn9(Q7GWMwypxTwDmxiT10Wn9(kid61(clMclgQ5ew5lSjKSWoweGtIQxea0hIgs)aw4XOaHdwgHlcGx)y4msweabwbdlhbOBY9f2jclX)Gc5eEfwmfwDtUVc0Nhb4KO6fbOn(IxTj0pGfEmkq4mhcxeaV(XWzKSiaNevVia8kJHsAqqFZiacScgwocqFngkKjtDyctJcKfwmfwmuZjSYxytizHnTWQBY9f2jclX)Gc5eEfwmfwDtUVc0NhbqsHyyA4WeoEeoyGceoPkcxeaV(XWzKSiacScgwocq3K7lStewI)bfYj8kSykS6MCFfOppcWjr1lc4dMn0a6dOaHdwicxeaV(XWzKSiacScgwocq3K7lStewI)bfYj8kSykS6MCFfOpVWMwyhxyJIGxTjcBAHDCH9C1Afid2WuOTMAUKktZq2bF1DqytlSPwy1xJHczYuhMW0OazHftHfd1CcR8f2eswyLiryhxyZDOgvMSUGm90Ghvue8QnrytlSJlSNRwRiDdZ16bNP()(1eQ7GWkrIWoUWM7qnQmzDbz6PbpQOi4vBIWMwypxTwb2Bs3pt1xykQpCcEclMclgc7yfwjse2OazA00CXclMclgyrHnTWoUWM7qnQmzDbz6PbpQOi4vBccWjr1lcyuzY6cY0tdEqbchSicxeaV(XWzKSiacScgwocyCHn3H6z4aVb9JAturrWR2eHnTWoUWEUATI0nmxRhCM6)7xtOUdiaNevViGNHd8g0pQnbfiCWsiCra86hdNrYIaCsu9IaWRmgkPbb9nJaiWkyy5iaDtUVWoryj(huiNWRWIPWQBY9vG(8cBAHn1c75Q1kWEt6(zQ(ctr9HtWtyXuyNtyLiry1n5(clMcRtIQxfyVjD)m9ubRi9hc7yraKuigMgomHJhHdgOaHdg4hHlcGx)y4msweabwbdlhbaznK)P(XWcBAHDCH9C1AfPByUwp4m1)3VMqDhe20c75Q1kWEt6(zQ(ctr9HtWtyXuyNdb4KO6fb8mCG3G(rTjOaHdgyGWfbWRFmCgjlcGaRGHLJagxypxTwr6gMR1dot9)9Rju3beGtIQxeGtbVWmdPTMsG9OhfiCWaFiCra86hdNrYIaiWkyy5iGXf2ZvRvKUH5A9GZu)F)Ac1Dab4KO6fbq6gMR1dot9)9RjqbchmgdcxeaV(XWzKSiacScgwoc4C1AfyVjD)mvFHPOUdcRejcRUj3xyNiSe)dkKt4vyXQWQBY9vG(8cR8qyXa)cRejc75Q1ks3WCTEWzQ)VFnH6oGaCsu9Iaa7nP7NPNkyuGWbdSmcxeGtIQxea0hIgs)aw4XiaE9JHZizrbchmMdHlcGx)y4msweabwbdlhbmUWgfbVAtqaojQEraJktwxqMEAWdkqbcGyyFgJWfHdgiCra86hdNrYIa6beWZrPraojQEraZCy5hdJaM5q66GmcG4WzmLKHiacScgwocWjrnJP8YGf)clMc7CiGzU5Yu28mcyoeWm3CzeGtIAgt5Lbl(rbch8HWfbWRFmCgjlcGaRGHLJaC5LHvWQJ5cPTMgUP3xb9fpHfRcl(f20cBQf2ZvRvKUH5A9GZu)F)Ac1DqytlSPwypxTwr6gMR1dot9)9Rjuqg0R9fwmfwmuZjSYxytizHvIeH9C1A1XCH0wtd307RUdcBAH9C1A1XCH0wtd307RGmOx7lSykSyOMtyLVWMqYcRejc75Q1ks3WCTEWzQ)VFnHcYGETVWMwyhxypxTwDmxiT10Wn9(kid61(c7yf2XIaCsu9Iaa7nP7NPNkyuGWzmiCra86hdNrYIaCsu9Iaa7nP7NPNkyeabwbdlhbK5ZvRvgp4nOdD99Q(Wj4jSyvytTW6KOMXuEzWIFHvIeHfljSJvytlSHdt4qffitJMMlwyXuyDsuZykVmyXVWkFHnHKraKuigMgomHJhHdgOaHdwgHlcWjr1lcWPGxyMH0wtjWE0Ja41pgoJKffiCMdHlcWjr1lcG0nmxRhCM6)7xtGa41pgoJKffiCsveUiaE9JHZizraeyfmSCeqUd1pf6dlBONg8OIIGxTjcBAHDCHnCdVHAAkzO)0tfSIx)y4SWkrIWM7q9tH(WYg6PbpQOi4vBIWMwyDsuZykVmyXVWIvHDoeGtIQxeaXHZyuGWbleHlcGx)y4msweabwbdlhbmUWgUH3qLCziSmgNgojkYR41pgolSsKiS6RXqHmzQdtyAuGSWIPWMqYcRejcl0RmLNXBO8C(vqg0R9fwmf2uvytlSqVYuEgVHYZ5xXZxF8iaNevViGrLjRlitpn4bfiCWIiCra86hdNrYIaiWkyy5iaYuhMWpvdDsu96gHfRcl(uZjSsKiS5ou)uOpSSHEAWJkkcE1MiSsKiSKUn5E0QgvMSUGm90GhfKb9AFHfRcRtIAgt5Lbl(fw5HWMqYcRejcBMpxTwDmDNPTMgtzkVmykkid61(cRejcl0RmLNXBO8C(vqg0R9fwmf25e20cl0RmLNXBO8C(v881hpcWjr1lc4CdYugMckq4GLq4Ia41pgoJKfb4KO6fba2Bs3ptpvWiacScgwociZNRwRmEWBqh667v9HtWtyXQWIfraKuigMgomHJhHdgOaHdg4hHlcWjr1lcGm1Xd6GpcGx)y4mswuGWbdmq4Ia41pgoJKfb4KO6fbGxzmusdc6BgbqGvWWYra6MCFHDIWs8pOqoHxHftHv3K7Ra95raKuigMgomHJhHdgOaHdg4dHlcGx)y4msweabwbdlhbeUH3qfme8PTMYBINWG8gkE9JHZiaNevViGPoCO7ffiCWymiCra86hdNrYIaiWkyy5iGWn8gQKldHLX40WjrrEfV(XWzeGtIQxeaXHZyuGWbdSmcxeaV(XWzKSiacScgwocG0Tj3Jw1OYK1fKPNg8OGmOx7lSyvytTW6KOMXuEzWIFHvIeHDoHDSiaNevViGZnitzykOaHdgZHWfbWRFmCgjlcGaRGHLJa0n5(c7eHL4FqHCcVclMcRUj3xb6ZJaCsu9Ia0gFXR2e6hWcpgfiCWivr4Ia41pgoJKfbqGvWWYra5ouJktwxqMEAWJcYAi)t9JHfwjse2Wn8gQrLjRlitRvF)QxfV(XWzeGtIQxeWOYK1fKPNg8GceoyGfIWfbWRFmCgjlcWjr1lc4z4aVb9JAtqaeyfmSCeW5Q1Qz1adF6mEBqfKDsGaiPqmmnCychpchmqbchmWIiCra86hdNrYIaiWkyy5ias3MCpAvJktwxqMEAWJcYGETVWIvHDMdl)yyfXHZykjdfw55cl(qaojQEraehoJrbchmWsiCraojQEraFWSHgqFabWRFmCgjlkq4Gp8JWfbWRFmCgjlcWjr1lc4z4aVb9JAtqaeyfmSCeaK1q(N6hdlSPf2ZvRvrnqBnnMY0FGDO6dNGNWIPWogHnTWU88bDurpn4rnRnEugwyLiryHSgY)u)yyHnTW6YldRGvgp4nOdD99QG(INWIvHf)iaskedtdhMWXJWbduGWbFyGWfbWRFmCgjlcWjr1lcaS3KUFMEQGraKuigMgomHJhHdgOaHd(WhcxeaV(XWzKSiaNevViaOpenK(bSWJraKuigMgomHJhHdgOafiGpq4IWbdeUiaNevVia8kJH(t7abWRFmCgjlkq4GpeUiaE9JHZizraeyfmSCeq4gEdvWqWN2AkVjEcdYBO41pgoJaCsu9IaM6WHUxuGWzmiCra86hdNrYIaiWkyy5iaDtUVWoryj(huiNWRWIPWQBY9vG(8iaNevViaTXx8QnH(bSWJrbchSmcxeaV(XWzKSiacScgwoc4C1AfPByUwp4m1)3VMqDhe20cBQf2ZvRvKUH5A9GZu)F)AcfKb9AFHftHfd1CcR8f2eswyLirypxTwDmxiT10Wn9(Q7GWMwypxTwDmxiT10Wn9(kid61(clMclgQ5ew5lSjKSWoweGtIQxea0hIgs)aw4XOaHZCiCra86hdNrYIaiWkyy5iGZvRvKUH5A9GZu)F)Ac1DqytlSPwypxTwr6gMR1dot9)9Rjuqg0R9fwmfwmuZjSYxytizHvIeH9C1A1XCH0wtd307RUdcBAH9C1A1XCH0wtd307RGmOx7lSykSyOMtyLVWMqYc7yraojQEraG9M09Z0tfmkq4KQiCra86hdNrYIaCsu9IaWRmgkPbb9nJaiWkyy5iaDtUVWoryj(huiNWRWIPWQBY9vG(8iaskedtdhMWXJWbduGWbleHlcGx)y4msweabwbdlhbCUATAwnWWNoJ3guDhe20c75Q1Qz1adF6mEBqfKb9AFHftHfdHv(cBcjJaCsu9IaEgoWBq)O2euGWblIWfbWRFmCgjlcGaRGHLJa0n5(c7eHL4FqHCcVclMcRUj3xb6ZJaCsu9Ia(GzdnG(akq4GLq4Ia41pgoJKfbqGvWWYra6MCFHDIWs8pOqoHxHftHv3K7Ra95f20clK1q(N6hdlSPfw91yOqMm1HjmnkqwyXuytizHnTWoUWEUATcKbByk0wtnxsLPzi7GV6oiSsKiS6MCFHDIWs8pOqoHxHftHv3K7Ra95f20cBQf2Xf2ChQrLjRlitpn4rffbVAte20cBQf2Xf2ZvRvKUH5A9GZu)F)Ac1DqyLirypxTwb2Bs3pt1xykQpCcEclMclgcRejcBuGmnAAUyHftHfdSOWkrIWoUWM7qnQmzDbz6PbpQOi4vBIWMwyD5LHvWQrLjZWL)N(x4SAMBuqFXtyXQWIFHDSc7yf20c74c75Q1kqgSHPqBn1CjvMMHSd(Q7acWjr1lcyuzY6cY0tdEqbchmWpcxeaV(XWzKSiacScgwoc4C1A1SAGHpDgVnO6oiSPf2ChQNHd8g0pQnrbzqV2xyXuyXYcR8f2eswyLiryZDOEgoWBq)O2efK1q(N6hdlSPf2Xf2ZvRvKUH5A9GZu)F)Ac1Dab4KO6fb8mCG3G(rTjOaHdgyGWfbWRFmCgjlcGaRGHLJagxypxTwr6gMR1dot9)9Rju3beGtIQxeGtbVWmdPTMsG9OhfiCWaFiCra86hdNrYIaiWkyy5iGXf2ZvRvKUH5A9GZu)F)Ac1Dab4KO6fbq6gMR1dot9)9RjqbchmgdcxeaV(XWzKSiacScgwoc4C1AfyVjD)mvFHPOUdcRejcRUj3xyNiSe)dkKt4vyXQWQBY9vG(8cR8qyXh(f20cB4gEd1SAGHpDgVnOIx)y4SWkrIWQBY9f2jclX)Gc5eEfwSkS6MCFfOpVWkpewme20cB4gEdvWqWN2AkVjEcdYBO41pgolSsKiSNRwRiDdZ16bNP()(1eQ7acWjr1lcaS3KUFMEQGrbchmWYiCraojQEraqFiAi9dyHhJa41pgoJKffiCWyoeUiaE9JHZizraeyfmSCeqUd1OYK1fKPNg8OGSgY)u)yyeGtIQxeWOYK1fKPNg8GceoyKQiCra86hdNrYIaiWkyy5iGZvRvZQbg(0z82GQ7acWjr1lc4z4aVb9JAtqbkqazw7xtqn1hiCr4GbcxeGtIQxea4vELxdJa41pgoJKffiCWhcxeGtIQxeW9zAfm4Ja41pgoJKffiCgdcxeaV(XWzKSiaNevViaIBmuNevVut9bcWuFqxhKraK8JceoyzeUiaE9JHZizraeyfmSCeGtIAgt5Lbl(fwPclgcBAHnCychQOazA00CXclMcRUj3xyLNlSPwyDsu9Qa7nP7NPNkyfP)qyLhclX)Gc5eEf2XkSYxytizeGtIQxeayVjD)m9ubJceoZHWfbWRFmCgjlcGaRGHLJaCsuZykVmyXVWIPWogHnTWgUH3qrM64bDWxXRFmCwytlSHB4nuUzyQthGC2JgQ41pgoJaCsu9IaiUXqDsu9sn1hiat9bDDqgb4dJ0fkq4KQiCra86hdNrYIaiWkyy5iaNe1mMYldw8lSykSJrytlSHB4nuKPoEqh8v86hdNraojQErae3yOojQEPM6deGP(GUoiJagPluGWbleHlcGx)y4msweabwbdlhb4KOMXuEzWIFHftHDmcBAHDCHnCdVHYndtD6aKZE0qfV(XWzHnTWoUWgUH3qnQmzDbzAT67x9Q41pgoJaCsu9IaiUXqDsu9sn1hiat9bDDqgb8bkq4Gfr4Ia41pgoJKfbqGvWWYraojQzmLxgS4xyXuyhJWMwyd3WBOCZWuNoa5ShnuXRFmCwytlSJlSHB4nuJktwxqMwR((vVkE9JHZiaNevViaIBmuNevVut9bcWuFqxhKra(WhOaHdwcHlcGx)y4msweabwbdlhb4KOMXuEzWIFHftHDmcBAHnCdVHYndtD6aKZE0qfV(XWzHnTWgUH3qnQmzDbzAT67x9Q41pgoJaCsu9IaiUXqDsu9sn1hiat9bDDqgb4dJ0fkq4Gb(r4Ia41pgoJKfbqGvWWYraojQzmLxgS4xyXuyhJWMwyhxyd3WBOCZWuNoa5ShnuXRFmCwytlSHB4nuJktwxqMwR((vVkE9JHZiaNevViaIBmuNevVut9bcWuFqxhKraJ0fkq4GbgiCra86hdNrYIaiWkyy5iaNe1mMYldw8lSyvyXqytlSJlSHB4nuNcMFARPdqoffV(XWzHvIeH1jrnJP8YGf)clwfw8HaCsu9IaiUXqDsu9sn1hiat9bDDqgbqmSpJrbchmWhcxeGtIQxeaPxcVb0dot1ghKra86hdNrYIceoymgeUiaNevViahs8LPrdH8giaE9JHZizrbchmWYiCraojQErahpH2AAalcEpcGx)y4mswuGceWiDHWfHdgiCraojQEra4vgd9N2bcGx)y4mswuGWbFiCra86hdNrYIaiWkyy5iaDtUVWoryj(huiNWRWIPWQBY9vG(8cBAHnCdVHkyi4tBnL3epHb5nu86hdNraojQEratD4q3lkq4mgeUiaE9JHZizraeyfmSCeW5Q1QJ5cPTMgUP3xDhe20c75Q1QJ5cPTMgUP3xbzqV2xyXuytizeGtIQxeayVjD)m9ubJceoyzeUiaE9JHZizraeyfmSCeW5Q1QJ5cPTMgUP3xDhe20c75Q1QJ5cPTMgUP3xbzqV2xyXuytizeGtIQxea0hIgs)aw4XOaHZCiCra86hdNrYIaiWkyy5iGZvRvZQbg(0z82GQ7GWMwypxTwnRgy4tNXBdQGmOx7lSykSyOMtyLVWMqYcRejc74cBUd1ZWbEd6h1MOIIGxTjiaNevViGNHd8g0pQnbfiCsveUiaE9JHZizraeyfmSCeG(AmuitM6WeMgfilSykSyOMtyLVWMqYcBAHv3K7lStewI)bfYj8kSykS6MCFfOpVWkrIWMAHD55d6OIEAWJAwB8OmSWMwyZDOEgoWBq)O2evue8QnrytlS5oupdh4nOFuBIcYAi)t9JHfwjse2LNpOJk6PbpQHPmSb7Lf20c74c75Q1kWEt6(zQ(ctrDhe20cRUj3xyNiSe)dkKt4vyXuy1n5(kqFEHvEiSojQEv4vgdL0GG(Mve)dkKt4vyLVWogHDSiaNevViGrLjRlitpn4bfiCWcr4Ia41pgoJKfb4KO6fbGxzmusdc6BgbqGvWWYra6MCFHDIWs8pOqoHxHftHv3K7Ra95fw5HWQBY9vqoHxeajfIHPHdt44r4Gbkq4Gfr4IaCsu9IaCk4fMziT1ucSh9iaE9JHZizrbchSecxeaV(XWzKSiacScgwocq3K7lStewI)bfYj8kSykS6MCFfOppcWjr1lc4dMn0a6dOaHdg4hHlcGx)y4msweabwbdlhbOVgdfYKPomHPrbYclMclgQ5ew5lSjKmcWjr1lcyuzY6cY0tdEqbchmWaHlcWjr1lcG0nmxRhCM6)7xtGa41pgoJKffiCWaFiCra86hdNrYIaiWkyy5iGZvRvZQbg(0z82GQ7GWMwyZDOEgoWBq)O2efKb9AFHftHfllSYxytizeGtIQxeWZWbEd6h1MGceoymgeUiaE9JHZizraeyfmSCeqUd1pf6dlBONg8OIIGxTjcRejc75Q1kWEt6(zQ(ctr9HtWtyLkSZHaCsu9Iaa7nP7NPNkyuGWbdSmcxeaV(XWzKSiacScgwocy55d6OIEAWJ6Nc9HLncBAHn3H6z4aVb9JAtuqg0R9fwSkSZjSYxytizeGtIQxeWOYK1fKPNg8GceoymhcxeaV(XWzKSiacScgwocaYAi)t9JHraojQErapdh4nOFuBckq4GrQIWfbWRFmCgjlcGaRGHLJagxypxTwb2Bs3pt1xykkid61(iaNevViaYuhpOd(OaHdgyHiCraojQEraG9M09Z0tfmcGx)y4mswuGWbdSicxeGtIQxea0hIgs)aw4XiaE9JHZizrbchmWsiCra86hdNrYIaiWkyy5iGZvRvZQbg(0z82GQ7acWjr1lc4z4aVb9JAtqbch8HFeUiaE9JHZizraeyfmSCeWYZh0rf90Gh1S24rzyHnTWM7q9mCG3G(rTjQOi4vBIWkrIWU88bDurpn4rnmLHnyVSWkrIWU88bDurpn4r9tH(WYgeGtIQxeWOYK1fKPNg8GcuGa8Hr6cHlchmq4IaCsu9IaWRmg6pTdeaV(XWzKSOaHd(q4Ia41pgoJKfbqGvWWYraNRwRoMlK2AA4MEF1DqytlSNRwRoMlK2AA4MEFfKb9AFHftHnHKraojQEraG9M09Z0tfmkq4mgeUiaE9JHZizraeyfmSCeW5Q1QJ5cPTMgUP3xDhe20c75Q1QJ5cPTMgUP3xbzqV2xyXuytizeGtIQxea0hIgs)aw4XOaHdwgHlcGx)y4msweabwbdlhbmUWM7q9mCG3G(rTjQOi4vBccWjr1lc4z4aVb9JAtqbcN5q4IaCsu9IaCk4fMziT1ucSh9iaE9JHZizrbcNufHlcGx)y4msweabwbdlhbOVgdfYKPomHPrbYclMclgQ5ew5lSjKSWkrIWQBY9f2jclX)Gc5eEfwmfwDtUVc0NxytlSPwyxE(GoQONg8OM1gpkdlSPf2ChQNHd8g0pQnrffbVAte20cBUd1ZWbEd6h1MOGSgY)u)yyHvIeHD55d6OIEAWJAykdBWEzHnTWoUWEUATcS3KUFMQVWuu3bHnTWQBY9f2jclX)Gc5eEfwmfwDtUVc0NxyLhcRtIQxfELXqjniOVzfX)Gc5eEfw5lSJryhlcWjr1lcyuzY6cY0tdEqbchSqeUiaNevVias3WCTEWzQ)VFnbcGx)y4mswuGWblIWfbWRFmCgjlcGaRGHLJaoxTwb2Bs3pt1xykkid61(cBAHD55d6OIEAWJAykdBWEzeGtIQxeayVjD)m9ubJceoyjeUiaE9JHZizraojQEra4vgdL0GG(MraeyfmSCeG(AmuitM6WeMgfilSykSyOMtyLVWMqYcBAHv3K7lStewI)bfYj8kSykS6MCFfOpVWkpew8HFeajfIHPHdt44r4Gbkq4Gb(r4Ia41pgoJKfbqGvWWYra6MCFHDIWs8pOqoHxHftHv3K7Ra95raojQEraFWSHgqFafiCWadeUiaE9JHZizraeyfmSCeW5Q1QOgOTMgtz6pWou9HtWtyLkSJryLiryZDO(PqFyzd90Ghvue8Qnbb4KO6fba9HOH0pGfEmkq4Gb(q4Ia41pgoJKfbqGvWWYra5ou)uOpSSHEAWJkkcE1MGaCsu9Iaa7nP7NPNkyuGWbJXGWfbWRFmCgjlcGaRGHLJawE(GoQONg8O(PqFyzJWMwy1n5(clwf2XGFHnTWM7q9mCG3G(rTjkid61(clwf25ew5lSjKmcWjr1lcyuzY6cY0tdEqbchmWYiCra86hdNrYIaiWkyy5iGXf2ZvRvG9M09Zu9fMIcYGETpcWjr1lcGm1Xd6Gpkq4GXCiCra86hdNrYIaiWkyy5iaiRH8p1pggb4KO6fb8mCG3G(rTjOaHdgPkcxeaV(XWzKSiaNevVia8kJHsAqqFZiacScgwocq3K7lStewI)bfYj8kSykS6MCFfOpVWMwytTWEUATcS3KUFMQVWuuF4e8ewmf25ewjsewDtUVWIPW6KO6vb2Bs3ptpvWks)HWoweajfIHPHdt44r4Gbkq4GbwicxeGtIQxea0hIgs)aw4XiaE9JHZizrbchmWIiCra86hdNrYIaiWkyy5iGZvRvG9M09Zu9fMI6oiSsKiS6MCFHfRclwg)cRejcBUd1pf6dlBONg8OIIGxTjiaNevViaWEt6(z6PcgfiCWalHWfbWRFmCgjlcGaRGHLJawE(GoQONg8OM1gpkdlSPf2ChQNHd8g0pQnrffbVAtewjse2LNpOJk6PbpQHPmSb7Lfwjse2LNpOJk6PbpQFk0hw2iSPfwDtUVWIvHDo8JaCsu9IagvMSUGm90GhuGceWaKjn4XdeUiCWaHlcGx)y4msweW6GmcWL3FQd9NQ7nOTMo0JyicWjr1lcWL3FQd9NQ7nOTMo0Jyikq4GpeUiaNevViGKRdZLV0wtD5LHDmfbWRFmCgjlkq4mgeUiaNevVias3WCTEWzQ)VFnbcGx)y4mswuGWblJWfb4KO6fbmQHM8mUwkK)E9LWiaE9JHZizrbcN5q4Ia41pgoJKfb4KO6fbm0r1lciNY6GfHoa5HoqayGceoPkcxeGtIQxeWhmBOb0hqa86hdNrYIceoyHiCraojQEratD4q3lcGx)y4mswuGceaj)iCr4GbcxeaV(XWzKSiacScgwocG0Tj3JwfPByUwp4m1)3VMqbzqV2xyXQWog8JaCsu9IaoMUZu9fMckq4GpeUiaE9JHZizraeyfmSCeaPBtUhTks3WCTEWzQ)VFnHcYGETVWIvHDm4hb4KO6fb4lH)a6gkXnguGWzmiCra86hdNrYIaiWkyy5ias3MCpAvKUH5A9GZu)F)AcfKb9AFHfRc7yWpcWjr1lcqxq(y6oJceoyzeUiaNevViatLmnEAQ8Mta5nqa86hdNrYIceoZHWfbWRFmCgjlcGaRGHLJaiDBY9Ovr6gMR1dot9)9Rjuqg0R9fwSkSPk(fwjse2OazA00CXclMclgJbb4KO6fbCy4Zq8QnbfiCsveUiaE9JHZizraeyfmSCeW5Q1QKRdZLV0wtD5LHDmvDhe20cBQf2ZvRvhg(meVAtu3bHvIeH9C1A1X0DMQVWuu3bHvIeHDCHf6ewfW2ye2XkSsKiSPwyj9(xq)yy1qhvV0wtV7bwzdNP6lmfHnTWQRKPbfYGETVWIPWMQyiSsKiS6kzAqHmOx7lSykS4lvf2XkSsKiSJlS8)8syfP3mVpNPMsZ6gsyfONkBOWMwypxTwr6gMR1dot9)9Rju3beGtIQxeWqhvVOaHdwicxeaV(XWzKSiacScgwociCychQC9HVewyXQuHnvraojQEra(pWKG2AAmLPSNyyuGWblIWfbWRFmCgjlcWjr1lcW)PZ8LFk0L3gsjn0niacScgwoc4C1Afid2WuOTMAUKktZq2bF1DqytlS6kzAqHmOx7lSykSKUn5E0QazWgMcT1uZLuzAgYo4RGmOx7lStewmMtyLirypxTwLCDyU8L2AQlVmSJPQpCcEcRuHDoHnTWQRKPbfYGETVWIPWs62K7rRk56WC5lT1uxEzyhtvqg0R9f2jcl(WVWkrIWM5ZvRvqxEBiL0q3qZ85Q1QCpAfwjsewDLmnOqg0R9fwmfw8HHWkrIWEUATAudn5zCTui)96lHvqg0R9f20cRUsMguid61(clMclPBtUhTQrn0KNX1sH83RVewbzqV2xyNiSyGffwjse2Xf2Wn8gQtbZpT10biNIIx)y4SWMwy1vY0GczqV2xyXuyjDBY9Ovr6gMR1dot9)9Rjuqg0R9f2jcl(WVWMwypxTwr6gMR1dot9)9Rjuqg0R9raRdYia)NoZx(PqxEBiL0q3GceoyjeUiaE9JHZizraojQErajUHjUXWWNE6EraeyfmSCeaPBtUhTkqgSHPqBn1CjvMMHSd(kid61(cRejcB4gEd1OYK1fKP1QVF1RIx)y4SWMwyjDBY9Ovr6gMR1dot9)9Rjuqg0R9fwjse2Xfw(FEjScKbByk0wtnxsLPzi7GVc0tLnuytlSKUn5E0QiDdZ16bNP()(1ekid61(iG1bzeqIByIBmm8PNUxuGWbd8JWfbWRFmCgjlcyDqgb4Y7p1H(t19g0wth6rmeb4KO6fb4Y7p1H(t19g0wth6rmefiCWadeUiaE9JHZizraeyfmSCea0RmLNXBO8C(v1kSyvyXs4xytlS6MCFHftHv3K7Ra95fw5HWIV5ewjse2ulSojQzmLxgS4xyXQWIHWMwyhxyd3WBOofm)0wthGCkkE9JHZcRejcRtIAgt5Lbl(fwSkS4tyhRWMwytTWEUAT6yUqARPHB69v3bHnTWEUAT6yUqARPHB69vqg0R9fwSkSJryLVWMqYcRejc74c75Q1QJ5cPTMgUP3xDhe2XIaCsu9Ia0n5(CM6YldRGPh2brbchmWhcxeaV(XWzKSiacScgwoci1cBQfwOxzkpJ3q558RGmOx7lSyvyXs4xyLiryhxyHELP8mEdLNZVINV(4f2XkSsKiSPwyDsuZykVmyXVWIvHfdHnTWoUWgUH3qDky(PTMoa5uu86hdNfwjsewNe1mMYldw8lSyvyXNWowHDScBAHv3K7lSykS6MCFfOppcWjr1lc4y6otBnnMYuEzWuqbchmgdcxeaV(XWzKSiacScgwoci1cBQfwOxzkpJ3q558RGmOx7lSyvytv8lSsKiSJlSqVYuEgVHYZ5xXZxF8c7yfwjse2ulSojQzmLxgS4xyXQWIHWMwyhxyd3WBOofm)0wthGCkkE9JHZcRejcRtIAgt5Lbl(fwSkS4tyhRWowHnTWQBY9fwmfwDtUVc0Nhb4KO6fbmCHLoLAtOhJ)bkq4GbwgHlcWjr1lci56WC5lT1uxEzyhtra86hdNrYIceoymhcxeGtIQxeaSggmmTw6p4egbWRFmCgjlkq4GrQIWfbWRFmCgjlcGaRGHLJa0xJHczYuhMW0OazHftHfdHv(cBcjJaCsu9Iai9s4nGEWzQ24Gmkq4GbwicxeaV(XWzKSiacScgwoc4C1AfKj4z4)P6gsy1Dab4KO6fbetz6Dp9DZuDdjmkq4GbweHlcWjr1lcyudn5zCTui)96lHra86hdNrYIceoyGLq4Ia41pgoJKfbqGvWWYraHdt4qnLDtmvnqcHfRclwe)cRejcB4Weoutz3etvdKqyXuQWIp8lSsKiSHdt4qffitJMoqck(WVWIvHDm4hb4KO6fbazFO2eQ24G8Jceo4d)iCra86hdNrYIaiWkyy5ia(FEjScKbByk0wtnxsLPzi7GVc0tLnuytlSqwd5FQFmSWMwypxTwnRgy4tNXBdQUdcBAHDCHL0Tj3Jwfid2WuOTMAUKktZq2bFfKb9AFeGtIQxeWZWbEd6h1MGceo4ddeUiaE9JHZizraeyfmSCea)pVewbYGnmfARPMlPY0mKDWxb6PYgkSPf2Xfws3MCpAvGmydtH2AQ5sQmndzh8vqg0R9raojQEraG9M09Z0tfmkq4Gp8HWfbWRFmCgjlcGaRGHLJa4)5LWkqgSHPqBn1CjvMMHSd(kqpv2qHnTWQVgdfYKPomHPrbYclMclgQ5ew5lSjKSWMwy1n5(clMcRtIQxfyVjD)m9ubRi9hcBAHDCHL0Tj3Jwfid2WuOTMAUKktZq2bFfKb9AFeGtIQxeWOYK1fKPNg8Gceo4BmiCra86hdNrYIaiWkyy5iaDtUVWIPW6KO6vb2Bs3ptpvWks)HWMwypxTwr6gMR1dot9)9Rju3beGtIQxeaid2WuOTMAUKktZq2bFuGceqM1(1eiCrbkqaZy4x9IWbF4hF4h)yr8HLuyGag5WT2KhbipdCOHbNfwSOW6KO6vyn1hVsGnc4hycch8n3CiGbyRldJasfclWfoRM5gHvE67gmuGDQqyb4HGbpmuyX3CYjS4d)4d)cSfyNkew5P4zSryXuQWoh(vcSfy7KO69vdqM0GhpMivM7Z0kyq5whKL6Y7p1H(t19g0wth6rmuGTtIQ3xnazsdE8yIuzsUomx(sBn1Lxg2Xub2ojQEF1aKjn4XJjsLH0nmxRhCM6)7xtiW2jr17RgGmPbpEmrQmJAOjpJRLc5VxFjSaBNevVVAaYKg84XePYm0r1RC5uwhSi0bip0Humey7KO69vdqM0GhpMivMpy2qdOpiW2jr17RgGmPbpEmrQmtD4q3RaBb2ojQEFvM1(1eut9XePYaELx51WcSDsu9(QmR9RjOM6JjsL5(mTcg8fy7KO69vzw7xtqn1htKkdXngQtIQxQP(qU1bzPK8lW2jr17RYS2VMGAQpMivgWEt6(z6PcwUsl1jrnJP8YGf)sXiD4WeourbY0OP5IXu3K7lpp1ojQEvG9M09Z0tfSI0Fipi(huiNW7yLFcjlW2jr17RYS2VMGAQpMivgIBmuNevVut9HCRdYs9Hr6sUsl1jrnJP8YGf)yoM0HB4nuKPoEqh8v86hdNthUH3q5MHPoDaYzpAOIx)y4SaBNevVVkZA)AcQP(yIuziUXqDsu9sn1hYToilDKUKR0sDsuZykVmyXpMJjD4gEdfzQJh0bFfV(XWzb2ojQEFvM1(1eut9XePYqCJH6KO6LAQpKBDqw6hYvAPojQzmLxgS4hZXKE8Wn8gk3mm1Pdqo7rdv86hdNtpE4gEd1OYK1fKP1QVF1RIx)y4SaBNevVVkZA)AcQP(yIuziUXqDsu9sn1hYToil1h(qUsl1jrnJP8YGf)yoM0HB4nuUzyQthGC2JgQ41pgoNE8Wn8gQrLjRlitRvF)QxfV(XWzb2ojQEFvM1(1eut9XePYqCJH6KO6LAQpKBDqwQpmsxYvAPojQzmLxgS4hZXKoCdVHYndtD6aKZE0qfV(XW50HB4nuJktwxqMwR((vVkE9JHZcSDsu9(QmR9RjOM6JjsLH4gd1jr1l1uFi36GS0r6sUsl1jrnJP8YGf)yoM0JhUH3q5MHPoDaYzpAOIx)y4C6Wn8gQrLjRlitRvF)QxfV(XWzb2ojQEFvM1(1eut9XePYqCJH6KO6LAQpKBDqwkXW(mwUsl1jrnJP8YGf)yfJ0JhUH3qDky(PTMoa5uu86hdNLiXjrnJP8YGf)yfFcSfyNkew5jlJHHVCclX)qylTWUDmT2eHLnplS1lS(mVm(XWkb2ojQEFvM1(1eut9XePYq6LWBa9GZuTXbzb2ojQEFvM1(1eut9XePY4qIVmnAiK3qGTtIQ3xLzTFnb1uFmrQmhpH2AAalcEVaBb2ojQEFfj)tKkZX0DMQVWuKR0sjDBY9Ovr6gMR1dot9)9Rjuqg0R9X6yWVaBNevVVIK)jsLXxc)b0nuIBmYvAPKUn5E0QiDdZ16bNP()(1ekid61(yDm4xGTtIQ3xrY)ePYOliFmDNLR0sjDBY9Ovr6gMR1dot9)9Rjuqg0R9X6yWVaBNevVVIK)jsLXujtJNMkV5eqEdb2ojQEFfj)tKkZHHpdXR2e5kTus3MCpAvKUH5A9GZu)F)AcfKb9AFSMQ4xIKOazA00CXyIXyey7KO69vK8prQmdDu9kxPLEUATk56WC5lT1uxEzyhtv3H0P(C1A1HHpdXR2e1DqIKZvRvht3zQ(ctrDhKizCOtyvaBJzSsKKAsV)f0pgwn0r1lT107EGv2WzQ(ctjTUsMguid61(yMQyirIUsMguid61(yIVuDSsKmo)pVewr6nZ7ZzQP0SUHewb6PYgM(C1AfPByUwp4m1)3VMqDhey7KO69vK8prQm(pWKG2AAmLPSNyy5kT0WHjCOY1h(sySknvfy7KO69vK8prQm3NPvWGYToil1)PZ8LFk0L3gsjn0nYvAPNRwRazWgMcT1uZLuzAgYo4RUdP1vY0GczqV2hts3MCpAvGmydtH2AQ5sQmndzh8vqg0R9NGXCsKCUATk56WC5lT1uxEzyhtvF4e8KoxADLmnOqg0R9XK0Tj3JwvY1H5YxARPU8YWoMQGmOx7pbF4xIKmFUATc6YBdPKg6gAMpxTwL7rRej6kzAqHmOx7Jj(WqIKZvRvJAOjpJRLc5VxFjScYGETFADLmnOqg0R9XK0Tj3Jw1OgAYZ4APq(71xcRGmOx7pbdSOejJhUH3qDky(PTMoa5uu86hdNtRRKPbfYGETpMKUn5E0QiDdZ16bNP()(1ekid61(tWh(tFUATI0nmxRhCM6)7xtOGmOx7lW2jr17Ri5FIuzUptRGbLBDqwAIByIBmm8PNUx5kTus3MCpAvGmydtH2AQ5sQmndzh8vqg0R9LijCdVHAuzY6cY0A13V6vXRFmConPBtUhTks3WCTEWzQ)VFnHcYGETVejJZ)ZlHvGmydtH2AQ5sQmndzh8vGEQSHPjDBY9Ovr6gMR1dot9)9Rjuqg0R9fy7KO69vK8prQm3NPvWGYToil1L3FQd9NQ7nOTMo0JyOaBb2PcHflO)5LWVaBNevVVIK)jsLr3K7ZzQlVmScMEyhuUslf6vMYZ4nuEo)QAXkwc)P1n5(yQBY9vG(8Yd8nNejP2jrnJP8YGf)yfJ0JhUH3qDky(PTMoa5uu86hdNLiXjrnJP8YGf)yfFJnDQpxTwDmxiT10Wn9(Q7q6ZvRvhZfsBnnCtVVcYGETpwhJ8tizjsg)C1A1XCH0wtd307RUdJvGTtIQ3xrY)ePYCmDNPTMgtzkVmykYvAPPo1qVYuEgVHYZ5xbzqV2hRyj8lrY4qVYuEgVHYZ5xXZxF8JvIKu7KOMXuEzWIFSIr6Xd3WBOofm)0wthGCkkE9JHZsK4KOMXuEzWIFSIVXo206MCFm1n5(kqFEb2ojQEFfj)tKkZWfw6uQnHEm(hYvAPPo1qVYuEgVHYZ5xbzqV2hRPk(LizCOxzkpJ3q558R45Rp(XkrsQDsuZykVmyXpwXi94HB4nuNcMFARPdqoffV(XWzjsCsuZykVmyXpwX3yhBADtUpM6MCFfOpVaBNevVVIK)jsLj56WC5lT1uxEzyhtfy7KO69vK8prQmWAyWW0AP)Gtyb2ojQEFfj)tKkdPxcVb0dot1ghKLR0s1xJHczYuhMW0OazmXq(jKSaBNevVVIK)jsLjMY07E67MP6gsy5kT0ZvRvqMGNH)NQBiHv3bb2ojQEFfj)tKkZOgAYZ4APq(71xclW2jr17Ri5FIuzGSpuBcvBCq(LR0sdhMWHAk7MyQAGeyflIFjschMWHAk7MyQAGeykfF4xIKWHjCOIcKPrthibfF4hRJb)cStfcR5sQSWIfCpv2qHvEYMC)8fCqyhM6plW2jr17Ri5FIuzEgoWBq)O2e5kTu(FEjScKbByk0wtnxsLPzi7GVc0tLnmnK1q(N6hdN(C1A1SAGHpDgVnO6oKECs3MCpAvGmydtH2AQ5sQmndzh8vqg0R9fy7KO69vK8prQmG9M09Z0tfSCLwk)pVewbYGnmfARPMlPY0mKDWxb6PYgMECs3MCpAvGmydtH2AQ5sQmndzh8vqg0R9fy7KO69vK8prQmJktwxqMEAWJCLwk)pVewbYGnmfARPMlPY0mKDWxb6PYgMwFngkKjtDyctJcKXed1CYpHKtRBY9X0jr1RcS3KUFMEQGvK(J0Jt62K7rRcKbByk0wtnxsLPzi7GVcYGETVaBNevVVIK)jsLbKbByk0wtnxsLPzi7GVCLwQUj3htNevVkWEt6(z6Pcwr6psFUATI0nmxRhCM6)7xtOUdcSfy7KO69vFmrQm4vgd9N2HaBNevVV6JjsLzQdh6ELR0sd3WBOcgc(0wt5nXtyqEdfV(XWzb2ojQEF1htKkJ24lE1Mq)aw4XYvAP6MC)je)dkKt4ftDtUVc0NxGTtIQ3x9XePYa9HOH0pGfESCLw65Q1ks3WCTEWzQ)VFnH6oKo1NRwRiDdZ16bNP()(1ekid61(yIHAo5NqYsKCUAT6yUqARPHB69v3H0NRwRoMlK2AA4MEFfKb9AFmXqnN8ti5XkWoviS42c7xGxJhSWEFpHfwDdfwWEt6(z6PcwyBOWc9HOH0pGfESWMVWAtewSa(bMecBRf2yklSyb5jgwoHL0dPiSStMkSnHCHqEjSW2AHnMYcRtIQxH13SW6dd8Mfwk7jgwyJwyJPSW6KO6vyxhKvcSDsu9(QpMivgWEt6(z6PcwUsl9C1AfPByUwp4m1)3VMqDhsN6ZvRvKUH5A9GZu)F)AcfKb9AFmXqnN8tizjsoxTwDmxiT10Wn9(Q7q6ZvRvhZfsBnnCtVVcYGETpMyOMt(jK8yfy7KO69vFmrQm4vgdL0GG(MLJKcXW0WHjC8sXqUslv3K7pH4FqHCcVyQBY9vG(8cSDsu9(QpMivMNHd8g0pQnrUsl9C1A1SAGHpDgVnO6oK(C1A1SAGHpDgVnOcYGETpMyi)eswGTtIQ3x9XePY8bZgAa9b5kTuDtU)eI)bfYj8IPUj3xb6ZlW2jr17R(yIuzgvMSUGm90Gh5kTuDtU)eI)bfYj8IPUj3xb6ZNgYAi)t9JHtRVgdfYKPomHPrbYyMqYPh)C1Afid2WuOTMAUKktZq2bF1DqIeDtU)eI)bfYj8IPUj3xb6ZNo1JN7qnQmzDbz6PbpQOi4vBs6up(5Q1ks3WCTEWzQ)VFnH6oirY5Q1kWEt6(zQ(ctr9HtWdtmKijkqMgnnxmMyGfLiz8ChQrLjRlitpn4rffbVAts7YldRGvJktMHl)p9VWz1m3OG(IhwX)yhB6XpxTwbYGnmfARPMlPY0mKDWxDhey7KO69vFmrQmpdh4nOFuBICLw65Q1Qz1adF6mEBq1DiDUd1ZWbEd6h1MOGmOx7Jjww(jKSej5oupdh4nOFuBIcYAi)t9JHtp(5Q1ks3WCTEWzQ)VFnH6oiW2jr17R(yIuzCk4fMziT1ucSh9YvAPJFUATI0nmxRhCM6)7xtOUdcSDsu9(QpMivgs3WCTEWzQ)VFnHCLw64NRwRiDdZ16bNP()(1eQ7GaBNevVV6JjsLbS3KUFMEQGLR0spxTwb2Bs3pt1xykQ7Gej6MC)je)dkKt4fR6MCFfOpV8aF4pD4gEd1SAGHpDgVnOIx)y4Sej6MC)je)dkKt4fR6MCFfOpV8aJ0HB4nubdbFARP8M4jmiVHIx)y4SejNRwRiDdZ16bNP()(1eQ7GaBNevVV6JjsLb6drdPFal8yb2ojQEF1htKkZOYK1fKPNg8ixPLM7qnQmzDbz6PbpkiRH8p1pgwGTtIQ3x9XePY8mCG3G(rTjYvAPNRwRMvdm8PZ4Tbv3bb2cStfclwaMHPUWIfiiN9OHcSDsu9(kF4JjsLbVYyO)0oey7KO69v(WhtKkdyVjD)m9ublxPLEUATI0nmxRhCM6)7xtOUdPt95Q1ks3WCTEWzQ)VFnHcYGETpMyOMt(jKSejNRwRoMlK2AA4MEF1Di95Q1QJ5cPTMgUP3xbzqV2htmuZj)esEScSDsu9(kF4JjsLb6drdPFal8y5kT0ZvRvKUH5A9GZu)F)Ac1DiDQpxTwr6gMR1dot9)9Rjuqg0R9Xed1CYpHKLi5C1A1XCH0wtd307RUdPpxTwDmxiT10Wn9(kid61(yIHAo5NqYJvGTtIQ3x5dFmrQmAJV4vBc9dyHhlxPLQBY9Nq8pOqoHxm1n5(kqFEb2ojQEFLp8XePYGxzmusdc6BwoskedtdhMWXlfd5kTu91yOqMm1HjmnkqgtmuZj)esoTUj3FcX)Gc5eEXu3K7Ra95fy7KO69v(WhtKkZhmBOb0hKR0s1n5(ti(huiNWlM6MCFfOpVaBNevVVYh(yIuzgvMSUGm90Gh5kTuDtU)eI)bfYj8IPUj3xb6ZNE8Oi4vBs6XpxTwbYGnmfARPMlPY0mKDWxDhsNA91yOqMm1HjmnkqgtmuZj)eswIKXZDOgvMSUGm90Ghvue8Qnj94NRwRiDdZ16bNP()(1eQ7GejJN7qnQmzDbz6PbpQOi4vBs6ZvRvG9M09Zu9fMI6dNGhMymwjsIcKPrtZfJjgyX0JN7qnQmzDbz6PbpQOi4vBIaBNevVVYh(yIuzEgoWBq)O2e5kT0XZDOEgoWBq)O2evue8Qnj94NRwRiDdZ16bNP()(1eQ7GaBNevVVYh(yIuzWRmgkPbb9nlhjfIHPHdt44LIHCLwQUj3FcX)Gc5eEXu3K7Ra95tN6ZvRvG9M09Zu9fMI6dNGhMZjrIUj3htNevVkWEt6(z6Pcwr6pgRaBNevVVYh(yIuzEgoWBq)O2e5kTuiRH8p1pgo94NRwRiDdZ16bNP()(1eQ7q6ZvRvG9M09Zu9fMI6dNGhMZjW2jr17R8HpMivgNcEHzgsBnLa7rVCLw64NRwRiDdZ16bNP()(1eQ7GaBNevVVYh(yIuziDdZ16bNP()(1eYvAPJFUATI0nmxRhCM6)7xtOUdcSDsu9(kF4JjsLbS3KUFMEQGLR0spxTwb2Bs3pt1xykQ7Gej6MC)je)dkKt4fR6MCFfOpV8ad8lrY5Q1ks3WCTEWzQ)VFnH6oiW2jr17R8HpMivgOpenK(bSWJfy7KO69v(WhtKkZOYK1fKPNg8ixPLoEue8QnrGTa7uHWkprzY6cYcR8SvF)Qxb2ojQEF1iDnrQm4vgd9N2HaBNevVVAKUMivMPoCO7vUslv3K7pH4FqHCcVyQBY9vG(8Pd3WBOcgc(0wt5nXtyqEdfV(XWzb2ojQEF1iDnrQmG9M09Z0tfSCLw65Q1QJ5cPTMgUP3xDhsFUAT6yUqARPHB69vqg0R9XmHKfy7KO69vJ01ePYa9HOH0pGfESCLw65Q1QJ5cPTMgUP3xDhsFUAT6yUqARPHB69vqg0R9XmHKfy7KO69vJ01ePY8mCG3G(rTjYvAPNRwRMvdm8PZ4Tbv3H0NRwRMvdm8PZ4Tbvqg0R9Xed1CYpHKLiz8ChQNHd8g0pQnrffbVAtey7KO69vJ01ePYmQmzDbz6PbpYvAP6RXqHmzQdtyAuGmMyOMt(jKCADtU)eI)bfYj8IPUj3xb6ZlrsQxE(GoQONg8OM1gpkdNo3H6z4aVb9JAturrWR2K05oupdh4nOFuBIcYAi)t9JHLiz55d6OIEAWJAykdBWE50JFUATcS3KUFMQVWuu3H06MC)je)dkKt4ftDtUVc0NxE4KO6vHxzmusdc6Bwr8pOqoHx5pMXkW2jr17RgPRjsLbVYyOKge03SCKuigMgomHJxkgYvAP6MC)je)dkKt4ftDtUVc0NxEOBY9vqoHxb2ojQEF1iDnrQmof8cZmK2Akb2JEb2ojQEF1iDnrQmFWSHgqFqUslv3K7pH4FqHCcVyQBY9vG(8cSDsu9(Qr6AIuzgvMSUGm90Gh5kTu91yOqMm1HjmnkqgtmuZj)eswGTtIQ3xnsxtKkdPByUwp4m1)3VMqGTtIQ3xnsxtKkZZWbEd6h1MixPLEUATAwnWWNoJ3guDhsN7q9mCG3G(rTjkid61(yILLFcjlW2jr17RgPRjsLbS3KUFMEQGLR0sZDO(PqFyzd90Ghvue8QnrIKZvRvG9M09Zu9fMI6dNGN05ey7KO69vJ01ePYmQmzDbz6PbpYvAPlpFqhv0tdEu)uOpSSjDUd1ZWbEd6h1MOGmOx7J15KFcjlW2jr17RgPRjsL5z4aVb9JAtKR0sHSgY)u)yyb2ojQEF1iDnrQmKPoEqh8LR0sh)C1AfyVjD)mvFHPOGmOx7lW2jr17RgPRjsLbS3KUFMEQGfy7KO69vJ01ePYa9HOH0pGfESaBNevVVAKUMivMNHd8g0pQnrUsl9C1A1SAGHpDgVnO6oiW2jr17RgPRjsLzuzY6cY0tdEKR0sxE(GoQONg8OM1gpkdNo3H6z4aVb9JAturrWR2ejswE(GoQONg8OgMYWgSxwIKLNpOJk6PbpQFk0hw2iWwGDQqyXcWmm1fwSab5ShnCIWkprzY6cYcR8SvF)Qxb2ojQEFLpmsxtKkdELXq)PDiW2jr17R8Hr6AIuza7nP7NPNky5kT0ZvRvhZfsBnnCtVV6oK(C1A1XCH0wtd307RGmOx7JzcjlW2jr17R8Hr6AIuzG(q0q6hWcpwUsl9C1A1XCH0wtd307RUdPpxTwDmxiT10Wn9(kid61(yMqYcSDsu9(kFyKUMivMNHd8g0pQnrUslD8ChQNHd8g0pQnrffbVAtey7KO69v(WiDnrQmof8cZmK2Akb2JEb2ojQEFLpmsxtKkZOYK1fKPNg8ixPLQVgdfYKPomHPrbYyIHAo5NqYsKOBY9Nq8pOqoHxm1n5(kqF(0PE55d6OIEAWJAwB8OmC6ChQNHd8g0pQnrffbVAtsN7q9mCG3G(rTjkiRH8p1pgwIKLNpOJk6PbpQHPmSb7Ltp(5Q1kWEt6(zQ(ctrDhsRBY9Nq8pOqoHxm1n5(kqFE5HtIQxfELXqjniOVzfX)Gc5eEL)ygRaBNevVVYhgPRjsLH0nmxRhCM6)7xtiW2jr17R8Hr6AIuza7nP7NPNky5kT0ZvRvG9M09Zu9fMIcYGETF6LNpOJk6PbpQHPmSb7Lfy7KO69v(WiDnrQm4vgdL0GG(MLJKcXW0WHjC8sXqUslvFngkKjtDyctJcKXed1CYpHKtRBY9Nq8pOqoHxm1n5(kqFE5b(WVaBNevVVYhgPRjsL5dMn0a6dYvAP6MC)je)dkKt4ftDtUVc0NxGTtIQ3x5dJ01ePYa9HOH0pGfESCLw65Q1QOgOTMgtz6pWou9HtWt6yKij3H6Nc9HLn0tdEurrWR2eb2ojQEFLpmsxtKkdyVjD)m9ublxPLM7q9tH(WYg6PbpQOi4vBIaBNevVVYhgPRjsLzuzY6cY0tdEKR0sxE(GoQONg8O(PqFyztADtUpwhd(tN7q9mCG3G(rTjkid61(yDo5NqYcSDsu9(kFyKUMivgYuhpOd(YvAPJFUATcS3KUFMQVWuuqg0R9fy7KO69v(WiDnrQmpdh4nOFuBICLwkK1q(N6hdlW2jr17R8Hr6AIuzWRmgkPbb9nlhjfIHPHdt44LIHCLwQUj3FcX)Gc5eEXu3K7Ra95tN6ZvRvG9M09Zu9fMI6dNGhMZjrIUj3htNevVkWEt6(z6Pcwr6pgRaBNevVVYhgPRjsLb6drdPFal8yb2ojQEFLpmsxtKkdyVjD)m9ublxPLEUATcS3KUFMQVWuu3bjs0n5(yflJFjsYDO(PqFyzd90Ghvue8QnrGTtIQ3x5dJ01ePYmQmzDbz6PbpYvAPlpFqhv0tdEuZAJhLHtN7q9mCG3G(rTjQOi4vBIejlpFqhv0tdEudtzyd2llrYYZh0rf90Gh1pf6dlBsRBY9X6C4xGTaBNevVVIyyFgprQmZCy5hdl36GSuIdNXusgkxpi95O0YnZnxwQtIAgt5Lbl(LBMBUmLnplDo5i9MRO6vQtIAgt5Lbl(XCob2ojQEFfXW(mEIuza7nP7NPNky5kTuxEzyfS6yUqARPHB69vqFXdR4pDQpxTwr6gMR1dot9)9Rju3H0P(C1AfPByUwp4m1)3VMqbzqV2htmuZj)eswIKZvRvhZfsBnnCtVV6oK(C1A1XCH0wtd307RGmOx7JjgQ5KFcjlrY5Q1ks3WCTEWzQ)VFnHcYGETF6XpxTwDmxiT10Wn9(kid61(JDScSDsu9(kIH9z8ePYa2Bs3ptpvWYrsHyyA4WeoEPyixPLM5ZvRvgp4nOdD99Q(Wj4H1u7KOMXuEzWIFjsWsJnD4WeourbY0OP5IX0jrnJP8YGf)YpHKfy7KO69ved7Z4jsLXPGxyMH0wtjWE0lW2jr17Rig2NXtKkdPByUwp4m1)3VMqGTtIQ3xrmSpJNivgIdNXYvAP5ou)uOpSSHEAWJkkcE1MKE8Wn8gQPPKH(tpvWkE9JHZsKK7q9tH(WYg6PbpQOi4vBsANe1mMYldw8J15ey7KO69ved7Z4jsLzuzY6cY0tdEKR0shpCdVHk5YqyzmonCsuKxXRFmCwIe91yOqMm1HjmnkqgZeswIeOxzkpJ3q558RGmOx7JzQMg6vMYZ4nuEo)kE(6JxGTtIQ3xrmSpJNivMZnitzykYvAPKPomHFQg6KO61nyfFQ5Kij3H6Nc9HLn0tdEurrWR2ejsiDBY9OvnQmzDbz6Pbpkid61(y1jrnJP8YGf)YJeswIKmFUAT6y6otBnnMYuEzWuuqg0R9Lib6vMYZ4nuEo)kid61(yoxAOxzkpJ3q558R45RpEb2ojQEFfXW(mEIuza7nP7NPNky5iPqmmnCychVumKR0sZ85Q1kJh8g0HU(EvF4e8WkwuGTtIQ3xrmSpJNivgYuhpOd(cSDsu9(kIH9z8ePYGxzmusdc6BwoskedtdhMWXlfd5kTuDtU)eI)bfYj8IPUj3xb6ZlW2jr17Rig2NXtKkZuho09kxPLgUH3qfme8PTMYBINWG8gkE9JHZcSDsu9(kIH9z8ePYqC4mwUslnCdVHk5YqyzmonCsuKxXRFmCwGTtIQ3xrmSpJNivMZnitzykYvAPKUn5E0QgvMSUGm90GhfKb9AFSMANe1mMYldw8lrYCJvGTtIQ3xrmSpJNivgTXx8QnH(bSWJLR0s1n5(ti(huiNWlM6MCFfOpVaBNevVVIyyFgprQmJktwxqMEAWJCLwAUd1OYK1fKPNg8OGSgY)u)yyjsc3WBOgvMSUGmTw99REv86hdNfy7KO69ved7Z4jsL5z4aVb9JAtKJKcXW0WHjC8sXqUsl9C1A1SAGHpDgVnOcYojey7KO69ved7Z4jsLH4WzSCLwkPBtUhTQrLjRlitpn4rbzqV2hRZCy5hdRioCgtjzO8C8jW2jr17Rig2NXtKkZhmBOb0hey7KO69ved7Z4jsL5z4aVb9JAtKJKcXW0WHjC8sXqUslfYAi)t9JHtFUATkQbARPXuM(dSdvF4e8WCmPxE(GoQONg8OM1gpkdlrcK1q(N6hdN2LxgwbRmEWBqh667vb9fpSIFb2PcHf3wy)c8A8Gf277jSWQBOWc2Bs3ptpvWcBdfwOpenK(bSWJf28fwBIWIfWpWKqyBTWgtzHflipXWYjSKEifHLDYuHTjKleYlHf2wlSXuwyDsu9kS(MfwFyG3SWszpXWcB0cBmLfwNevVc76GSsGTtIQ3xrmSpJNivgWEt6(z6PcwoskedtdhMWXlfdb2ojQEFfXW(mEIuzG(q0q6hWcpwoskedtdhMWXlfduGceca]] )
    end

end